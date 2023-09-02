"""Provides a simple way to test your rules as an external workspace.
Add a basic smoke-test target below.
"""

load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@rules_nushell//nushell:defs.bzl", "nu_genrule")

nu_genrule(
    name = "test_generate_yml",
    outs = ["test.yml"],
    cmd = "{foo: 'bar'} | to yaml | save $bazel.outs.'test.yml'",
)

build_test(
    name = "smoke_test",
    targets = [
        ":test_generate_yml",
    ],
)
