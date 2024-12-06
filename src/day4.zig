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

const XMAS_LEN = 4;
const MAS_LEN = 3;

fn solve(array: [][]const u8) void {
    var counter_part1: usize = 0;
    var counter_part2: usize = 0;

    for (0..array.len) |line_idx| {
        for (0..array[line_idx].len) |cursor| {
            // look horizontally
            if (cursor > 2) {
                const horizontal = array[line_idx][cursor - 3..cursor + 1];
                if (std.mem.eql(u8, horizontal, "XMAS") or std.mem.eql(u8, horizontal, "SAMX")) counter_part1 += 1;
            }

            // look vertically and diagonally
            if (line_idx < array.len - 3) {
                var vtBuffer: [4]u8 = undefined;
                var drBuffer: [4]u8 = undefined;
                var dlBuffer: [4]u8 = undefined;

                for (0..XMAS_LEN) |idx| {
                    vtBuffer[idx] = array[line_idx + idx][cursor];
                    if (cursor < array[line_idx].len - 3) {
                        drBuffer[idx] = array[line_idx + idx][cursor + idx];
                        dlBuffer[idx] = array[line_idx + (3 - idx)][cursor + idx];
                    }
                }

                if (std.mem.eql(u8, &vtBuffer, "XMAS") or std.mem.eql(u8, &vtBuffer, "SAMX")) counter_part1 += 1;  
                if (std.mem.eql(u8, &drBuffer, "XMAS") or std.mem.eql(u8, &drBuffer, "SAMX")) counter_part1 += 1;
                if (std.mem.eql(u8, &dlBuffer, "XMAS") or std.mem.eql(u8, &dlBuffer, "SAMX")) counter_part1 += 1;
            }

            if (line_idx < array.len - 2 and cursor < array[line_idx].len - 2) {
                var drBuffer: [3]u8 = undefined;
                var dlBuffer: [3]u8 = undefined;

                for (0..MAS_LEN) |idx| {
                    drBuffer[idx] = array[line_idx + idx][cursor + idx];
                    dlBuffer[idx] = array[line_idx + (2 - idx)][cursor + idx];
                }

                if (
                    (std.mem.eql(u8, &drBuffer, "MAS") or std.mem.eql(u8, &drBuffer, "SAM"))
                    and (std.mem.eql(u8, &dlBuffer, "MAS") or std.mem.eql(u8, &dlBuffer, "SAM"))
                ) counter_part2 += 1;
            }
        }
    }

    // 2654
    // 1990
    std.debug.print("part 1 = {d}, part 2 = {d}\n", .{counter_part1, counter_part2});
}

pub fn run(alloc: *const Allocator) !void {
    const input = try read_input("puzzle_input/day4.txt", alloc);
    defer alloc.free(input);

    const array = try parseInput(input, alloc);
    defer array.deinit();

    solve(array.items);
}
