const std = @import("std");
const read_input = @import("main.zig").read_input;
const Allocator = std.mem.Allocator;

fn parseInput(input: []const u8, alloc: *const Allocator) !std.ArrayListAligned([]const u8, null) {
    var iter = std.mem.splitScalar(u8, input, '\n');

    var array = std.ArrayList([]const u8).init(alloc.*);

    while (iter.next()) |line| {
        if (line.len > 0) try array.append(line);
    }

    return array;
}

const WORD_LEN = 4;

fn part1(array: [][]const u8) void {
    var count: usize = 0;

    for (0..array.len) |line_idx| {
        for (0..array[line_idx].len) |cursor| {
            // look horizontally
            if (cursor > 2) {
                const horizontal = array[line_idx][cursor - 3..cursor + 1];
                if (std.mem.eql(u8, horizontal, "XMAS") or std.mem.eql(u8, horizontal, "SAMX")) {
                    count += 1;
                    std.debug.print("hz | line: {d}, cursor: {d} => {s}\n", .{line_idx, cursor - 3, horizontal});
                }
            }

            // look vertically and diagonally
            if (line_idx < array.len - 3) {
                var vtBuffer: [4]u8 = undefined;
                var drBuffer: [4]u8 = undefined;
                var dlBuffer: [4]u8 = undefined;

                for (0..WORD_LEN) |idx| {
                    vtBuffer[idx] = array[line_idx + idx][cursor];
                    if (cursor < array[line_idx].len - 3) {
                        drBuffer[idx] = array[line_idx + idx][cursor + idx];
                        dlBuffer[idx] = array[line_idx + (3 - idx)][cursor + idx];
                    }
                }

                if (std.mem.eql(u8, &vtBuffer, "XMAS") or std.mem.eql(u8, &vtBuffer, "SAMX")) {
                    count += 1;
                    std.debug.print("vt | line: {d}, cursor: {d} => {s}\n", .{line_idx, cursor, vtBuffer});
                }
                if (std.mem.eql(u8, &drBuffer, "XMAS") or std.mem.eql(u8, &drBuffer, "SAMX")) {
                    count += 1;
                    std.debug.print("dr | line: {d}, cursor: {d} => {s}\n", .{line_idx, cursor, drBuffer});
                }
                if (std.mem.eql(u8, &dlBuffer, "XMAS") or std.mem.eql(u8, &dlBuffer, "SAMX")) {
                    count += 1;
                    std.debug.print("dl | line: {d}, cursor: {d} => {s}\n", .{line_idx, cursor, dlBuffer});
                }
            }
        }
    }

    // 2654
    std.debug.print("part 1 = {d}\n", .{count});
}

pub fn run(alloc: *const Allocator) !void {
    const input = try read_input("puzzle_input/day4.txt", alloc);
    defer alloc.free(input);

    const array = try parseInput(input, alloc);
    defer array.deinit();

    part1(array.items);
}
