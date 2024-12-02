const std = @import("std");
const read_input = @import("main.zig").read_input;

const Allocator = std.mem.Allocator;

fn part1(left: *std.ArrayListAligned(usize, null), right: *std.ArrayListAligned(usize, null)) void {
    var result: usize = 0;

    for (left.items, right.items) |item1, item2| {
        var num_inner: usize = 0;
        if (item1 >= item2) {
            num_inner += item1 - item2;
        } else {
            num_inner += item2 - item1;
        }

        result += num_inner;
    }

    std.debug.print("part 1 = {d}\n", .{result});
}

fn part2(left: *std.ArrayListAligned(usize, null), right: *std.ArrayListAligned(usize, null)) void {
    var result: usize = 0;
    for (left.items) |item1| {
        var multiplicator: usize = 0;
        for (right.items) |item2| {
            if (item1 == item2) {
                multiplicator += 1;
            }
        }
        result += item1 * multiplicator;
    }

    std.debug.print("part 2 = {d}\n", .{result});
}

fn parse_input(input: []const u8, alloc: *const Allocator) !void {
    var iter = std.mem.splitSequence(u8, input, "\n");

    var left = std.ArrayList(usize).init(alloc.*);
    var right = std.ArrayList(usize).init(alloc.*);
    defer left.deinit();
    defer right.deinit();

    while (iter.next()) |line| {
        var iter2 = std.mem.splitSequence(u8, line, " ");
        var idx: usize = 0;
        while (iter2.next()) |char| {
            if (char.len > 0) {
                const num = try std.fmt.parseInt(usize, char, 10);
                if (idx == 0) {
                    try left.append(num);
                } else if (idx == 3) {
                    try right.append(num);
                }
            }
            idx += 1;
        }
    }

    std.mem.sort(usize, left.items, {}, comptime std.sort.asc(usize));
    std.mem.sort(usize, right.items, {}, comptime std.sort.asc(usize));

    part1(&left, &right);
    part2(&left, &right);
}

pub fn run(alloc: *const Allocator) !void {
    const input = try read_input("puzzle_input/day1.txt", alloc);
    defer alloc.free(input);

    try parse_input(input, alloc);
}
