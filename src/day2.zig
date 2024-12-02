const std = @import("std");
const read_input = @import("main.zig").read_input;

const Allocator = std.mem.Allocator;

pub fn run(alloc: *const Allocator) !void {
    const input = try read_input("puzzle_input/day1.txt", alloc);
    defer alloc.free(input);

    std.debug.print("Hello World", .{});
}
