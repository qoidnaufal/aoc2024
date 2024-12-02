const std = @import("std");
const read_input = @import("main.zig").read_input;

const Allocator = std.mem.Allocator;

const DataList = struct {
    list: std.ArrayListAligned(std.ArrayListAligned(usize, null), null),

    const Self = @This();
    fn init(alloc: *const Allocator) Self {
        return Self {
            .list = std.ArrayList(std.ArrayList(usize)).init(alloc.*)
        };
    }

    fn append(self: *DataList, num_list: std.ArrayListAligned(usize, null)) !void {
        try self.list.append(num_list);
    }

    fn items(self: *const DataList) @TypeOf(self.list.items) {
        return self.list.items;
    }

    fn deinit(self: *const DataList) void {
        defer self.list.deinit();
        for (self.items()) |arr| {
            arr.deinit();
        }
    }
};

const Safety = enum {
    Safe,
    Unsafe
};

const State = enum {
    Ascending,
    Descending
};

fn safety_check(items: []const usize, alloc: *const Allocator) !Safety {
    const len = items.len;
    const checker = try alloc.alloc(State, len - 1);
    defer alloc.free(checker);

    for (0..checker.len) |idx| {
        const curr: isize = @intCast(items[idx]);
        const next: isize = @intCast(items[idx + 1]);
        const delta: usize = @abs(curr - next);

        switch (next > curr) {
            true => checker[idx] = State.Ascending,
            false => checker[idx] = State.Descending,
        }

        if (delta > 3 or delta < 1) {
            return Safety.Unsafe;
        } else if (idx > 0 and checker[idx - 1] != checker[idx]) {
            return Safety.Unsafe;
        }
    }
    return Safety.Safe;
}

fn parse_input(input: []const u8, alloc: *const Allocator) !DataList {
    var iter = std.mem.splitSequence(u8, input, "\n");
    var dataList = DataList.init(alloc);
    while (iter.next()) |line| {
        var token = std.mem.splitAny(u8, line, " ");
        var num_list = std.ArrayList(usize).init(alloc.*);
        while (token.next()) |char| {
            const num = std.fmt.parseInt(usize, char, 10) catch break;
            try num_list.append(num);
        }
        if (num_list.items.len > 0) {
            try dataList.append(num_list);
        }
    }
    return dataList;
}

fn part1(datalist: *const DataList, alloc: *const Allocator) !void {
    var accumulator: usize = 0;
    for (datalist.items()) |arr| {
        const safety = try safety_check(arr.items, alloc);
        if (safety == Safety.Safe) {
            accumulator += 1;
        }
    }
    std.debug.print("part 1 = {d}\n", .{accumulator});
}

pub fn run(alloc: *const Allocator) !void {
    const input = try read_input("puzzle_input/day2.txt", alloc);
    defer alloc.free(input);

    const datalist = try parse_input(input, alloc);
    defer datalist.deinit();

    try part1(&datalist, alloc);
}
