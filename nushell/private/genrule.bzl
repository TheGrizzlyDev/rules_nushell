"""This module implements a nushell based genrule.
"""

def nushell_genrule_impl(ctx):
    """
    Implementation of a genrule based on nushell

    Args:
        ctx: bazel's rule ctx
    """
    nuscript = ctx.actions.declare_file("_gen_%s_cmd.nu" % (ctx.attr.name))
    ctx.actions.write(nuscript, ctx.attr.cmd, is_executable = True)

    build_path_list = lambda files: "{%s}" % (",".join(["\"%s\": \"%s\"" % (out.short_path, out.path) for out in files]))
    nutemplate_params = {
        "env_declared_outs": build_path_list(ctx.outputs.outs),
        "env_declared_ins": build_path_list(ctx.files.srcs),
        "env_declared_tools": build_path_list(ctx.files.tools),
    }

    nuconfig = ctx.actions.declare_file("_gen_%s_config.nu" % (ctx.attr.name))
    ctx.actions.expand_template(
        template = ctx.file._nuconfig_template,
        output = nuconfig,
        substitutions = nutemplate_params,
    )

    nuenv = ctx.actions.declare_file("_gen_%s_env.nu" % (ctx.attr.name))
    ctx.actions.expand_template(
        template = ctx.file._nuenv_template,
        output = nuenv,
        substitutions = nutemplate_params,
    )

    ctx.actions.run(
        outputs = ctx.outputs.outs,
        executable = "/opt/nu/nu",
        inputs = [nuscript, nuconfig, nuenv] + ctx.files.tools + ctx.files.srcs,
        arguments = [
            "--config",
            nuconfig.path,
            "--env-config",
            nuenv.path,
            nuscript.path,
        ],
    )

nushell_genrule = rule(
    implementation = nushell_genrule_impl,
    attrs = {
        "cmd": attr.string(),
        "outs": attr.output_list(allow_empty = False),
        "srcs": attr.label_list(cfg = "target"),
        "tools": attr.label_list(cfg = "exec"),
        "_nuconfig_template": attr.label(
            default = "config.tmpl.nu",
            allow_single_file = True,
        ),
        "_nuenv_template": attr.label(
            default = "env.tmpl.nu",
            allow_single_file = True,
        ),
    },
)
