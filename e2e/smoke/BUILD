"""Provides a simple way to test your rules as an external workspace.
Add a basic smoke-test target below.
"""

load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@rules_nushell//nushell:defs.bzl", "nu_genrule")

nu_genrule(
    name = "test_no_inputs_no_tools",
    outs = ["test.yml"],
    cmd = "{foo: 'bar'} | to yaml | save $bazel.outs.'test.yml'",
)

sh_binary(
    name = "hello_world_tool",
    srcs = ["hello_world_tool.sh"],
)

nu_genrule(
    name = "test_with_tool",
    outs = ["hello.txt"],
    cmd = "run-external $bazel.tools.'hello_world_tool' --redirect-stdout | save $bazel.outs.'hello.txt'",
    tools = [":hello_world_tool"],
)

build_test(
    name = "smoke_test",
    targets = [
        ":test_no_inputs_no_tools",
        ":test_with_tool",
    ],
)
