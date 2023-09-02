"Public API re-exports"

load("//nushell/private:genrule.bzl", nushell_genrule_rule = "nushell_genrule")

def nushell_genrule(**kwargs):
    """nushell based replacement for genrule"""
    nushell_genrule_rule(**kwargs)

nu_genrule = nushell_genrule
