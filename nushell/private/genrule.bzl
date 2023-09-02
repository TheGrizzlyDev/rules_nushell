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

    nutemplate_params = {
        "env_declared_outs": "{%s}" % (",".join(["\"%s\": \"%s\"" % (out.short_path, out.path) for out in ctx.outputs.outs])),
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
        inputs = [nuscript, nuconfig, nuenv],
        arguments = [
            "--config",
            nuconfig.path,
            "--env-config",
            nuenv.path,
            nuscript.path,
        ],  # output file needs to be replaced in the script
    )

nushell_genrule = rule(
    implementation = nushell_genrule_impl,
    attrs = {
        "cmd": attr.string(),
        "outs": attr.output_list(allow_empty = False),
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
