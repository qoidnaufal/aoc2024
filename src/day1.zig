const std = @import("std");
const read_input = @import("main.zig").read_input;

const Allocator = std.mem.Allocator;

fn part1(data: *const Data) void {
    var result: usize = 0;

    for (data.left.items, data.right.items) |item1, item2| {
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

fn part2(data: *const Data) void {
    var result: usize = 0;
    for (data.left.items) |item1| {
        var multiplicator: usize = 0;
        for (data.right.items) |item2| {
            if (item1 == item2) {
                multiplicator += 1;
            }
        }
        result += item1 * multiplicator;
    }

    std.debug.print("part 2 = {d}\n", .{result});
}

const Data = struct {
    left: std.ArrayListAligned(usize, null),
    right: std.ArrayListAligned(usize, null),

    fn init(alloc: *const Allocator) Data {
        return Data {
            .left = std.ArrayList(usize).init(alloc.*),
            .right = std.ArrayList(usize).init(alloc.*),
        };
    }

    fn sort(self: *Data) void {
        std.mem.sort(usize, self.left.items, {}, comptime std.sort.asc(usize));
        std.mem.sort(usize, self.right.items, {}, comptime std.sort.asc(usize));
    }

    fn deinit(self: *const Data) void {
        self.left.deinit();
        self.right.deinit();
    }
};

fn parse_input(input: []const u8, alloc: *const Allocator) !Data {
    var iter = std.mem.splitSequence(u8, input, "\n");
    var data = Data.init(alloc);

    while (iter.next()) |line| {
        var iter2 = std.mem.tokenizeAny(u8, line, " ");
        var idx: usize = 0;
        while (iter2.next()) |char| {
            const num = try std.fmt.parseInt(usize, char, 10);
            switch (idx) {
                0 => try data.left.append(num),
                1 => try data.right.append(num),
                else => break
            }
            idx += 1;
        }
    }

    data.sort();
    return data;
}

pub fn run(alloc: *const Allocator) !void {
    const input = try read_input("puzzle_input/day1.txt", alloc);
    defer alloc.free(input);

    const data = try parse_input(input, alloc);
    defer data.deinit();

    part1(&data);
    part2(&data);
}
