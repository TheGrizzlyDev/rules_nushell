"""This module implements a nushell based genrule.
"""

def _build_nuenv(ctx, substitutions):
    nuenv = ctx.actions.declare_file("_gen_%s_env.nu" % (ctx.attr.name))
    ctx.actions.expand_template(
        template = ctx.file._nuenv_template,
        output = nuenv,
        substitutions = substitutions,
    )
    return nuenv

def _build_nuconfig(ctx, substitutions):
    nuconfig = ctx.actions.declare_file("_gen_%s_config.nu" % (ctx.attr.name))
    ctx.actions.expand_template(
        template = ctx.file._nuconfig_template,
        output = nuconfig,
        substitutions = substitutions,
    )
    return nuconfig

def _nushell_genrule_impl(ctx):
    build_path_list = lambda files: "{%s}" % (",".join(["\"%s\": \"%s\"" % (out.short_path, out.path) for out in files]))
    nutemplate_params = {
        "env_declared_ins": build_path_list(ctx.files.srcs),
        "env_declared_tools": build_path_list(ctx.files.tools),
        "env_declared_outs": build_path_list(ctx.outputs.outs),
    }

    nuconfig = _build_nuconfig(ctx, nutemplate_params)
    nuenv = _build_nuenv(ctx, nutemplate_params)

    nuscript = ctx.actions.declare_file("_gen_%s_cmd.nu" % (ctx.attr.name))
    ctx.actions.write(nuscript, ctx.attr.cmd, is_executable = True)
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

def _nushell_genrule_repl_impl(ctx):
    build_path_list = lambda files: "{%s}" % (",".join(["\"%s\": \"%s\"" % (out.short_path, out.short_path) for out in files]))
    nutemplate_params = {
        "env_declared_ins": build_path_list(ctx.files.srcs),
        "env_declared_tools": build_path_list(ctx.files.tools),
        "env_declared_outs": "{%s}" % (",".join(["\"%s\": \"%s\"" % (out, out) for out in ctx.attr.outs])),
    }

    nuconfig = _build_nuconfig(ctx, nutemplate_params)
    nuenv = _build_nuenv(ctx, nutemplate_params)

    nurepl = ctx.actions.declare_file("_gen_%s.nu" % (ctx.attr.name))
    ctx.actions.expand_template(
        template = ctx.file._nurepl_template,
        output = nurepl,
        is_executable = True,
        substitutions = {
            "nushell_bin": "/opt/nu/nu",
            "nushell_env": nuenv.short_path,
            "nushell_config": nuconfig.short_path,
        },
    )

    # TODO: collect tools runfiles and transitive deps
    runfiles = ctx.runfiles([nuenv, nuconfig] + ctx.files.srcs)

    return [
        DefaultInfo(
            executable = nurepl,
            runfiles = runfiles,
        ),
    ]

NUSHELL_GENRULE_COMMON_ATTRS = {
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
}

nushell_genrule = rule(
    implementation = _nushell_genrule_impl,
    attrs = NUSHELL_GENRULE_COMMON_ATTRS | {
        "cmd": attr.string(),
        "outs": attr.output_list(allow_empty = False),
    },
)

nushell_genrule_repl = rule(
    implementation = _nushell_genrule_repl_impl,
    attrs = NUSHELL_GENRULE_COMMON_ATTRS | {
        "_nurepl_template": attr.label(
            default = "repl.tmpl.nu",
            allow_single_file = True,
        ),
        "outs": attr.string_list(allow_empty = False),
    },
    executable = True,
)
