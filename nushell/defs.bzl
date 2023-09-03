"Public API re-exports"

load("//nushell/private:genrule.bzl", "nushell_genrule_repl", nushell_genrule_rule = "nushell_genrule")

def nushell_genrule(name, cmd, **kwargs):
    """nushell based replacement for genrule"""
    nushell_genrule_rule(name = name, cmd = cmd, **kwargs)
    nushell_genrule_repl(name = "%s.repl" % (name), **kwargs)

nu_genrule = nushell_genrule
