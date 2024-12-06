const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "aoc2024",
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src-zig/main.zig"),
    });

    b.installArtifact(exe);

    const cargo_cmd = b.addSystemCommand(&.{"cargo", "build"});
    exe.step.dependOn(&cargo_cmd.step);
    exe.addObjectFile(b.path("target/debug/librust_helper.a"));
}
