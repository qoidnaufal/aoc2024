const std = @import("std");
const read_input = @import("main.zig").read_input;
const Allocator = std.mem.Allocator;

pub extern fn process_in_rust(c_input: [*c]const u8, len: usize) void;

fn parseInput(input: [*c]const u8, len: usize) void {
    process_in_rust(input, len);
}

pub fn run(alloc: *const Allocator) !void {
    const input = try read_input("puzzle_input/day5.txt", alloc);
    defer alloc.free(input);

    const len = input.len;
    const c_input: [*c]const u8 = @ptrCast(input);

    parseInput(c_input, len);
}
