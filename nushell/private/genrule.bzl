"""This module implements a nushell based genrule.
"""

def nushell_genrule_impl(_):
    pass

nushell_genrule = rule(
    implementation = nushell_genrule_impl,
    attrs = {
    },
)
