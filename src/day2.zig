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
    Unsafe,
};

const State = enum {
    Descending,
    Ascending,
};

const Result = struct {
    idx: usize,
    safety: Safety
};

fn safety_check(items: []const usize, alloc: *const Allocator) !Result {
    const len = items.len;
    const state = try alloc.alloc(State, len - 1);
    defer alloc.free(state);

    for (0..state.len) |idx| {
        const curr: isize = @intCast(items[idx]);
        const next: isize = @intCast(items[idx + 1]);

        const delta_next: usize = @abs(curr - next);

        switch (next > curr) {
            true => state[idx] = .Ascending,
            false => state[idx] = .Descending,
        }

        if (delta_next > 3 or delta_next < 1) {
            return .{ .idx = idx + 1, .safety = .Unsafe };
        }
        
        if (idx > 0 and state[idx - 1] != state[idx]) {
            return .{ .idx = idx + 1, .safety = .Unsafe };
        }
    }

    return .{ .idx = 0, .safety = .Safe };
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
    for (datalist.items()) |num_list| {
        const safety = try safety_check(num_list.items, alloc);
        if (safety.safety == .Safe) {
            accumulator += 1;
        }
    }
    std.debug.print("part 1 = {d}\n", .{accumulator});
}

fn dampened_safety_checker(
    num_list: std.ArrayListAligned(usize, null),
    accumulator: *usize,
    alloc: *const Allocator
) !void {
    const safety = try safety_check(num_list.items, alloc);
    std.debug.print("initial | {d}\n", .{num_list.items});

    switch (safety.safety) {
        .Unsafe => {
            defer std.debug.print("terminated\n", .{});
            for (0..num_list.items.len) |idx| {
                var new_list = try num_list.clone();
                defer new_list.deinit();

                _ = new_list.orderedRemove(idx);
                std.debug.print("attempt | {d}\n", .{new_list.items});
                const safety_2 = try safety_check(new_list.items, alloc);

                switch (safety_2.safety) {
                    .Unsafe => {
                    },
                    .Safe => {
                        std.debug.print("safe\n", .{});
                        accumulator.* += 1;
                        return;
                    },
                }
            }
        },
        .Safe => {
            std.debug.print("safe\n", .{});
            accumulator.* += 1;
        }
    }
}

fn part2(datalist: *const DataList, alloc: *const Allocator) !void {
    var accumulator: usize = 0;
    for (datalist.items()) |num_list| {
        try dampened_safety_checker(num_list, &accumulator, alloc);
    }

    std.debug.print("part 2 = {d}\n", .{accumulator});
}

pub fn run(alloc: *const Allocator) !void {
    const input = try read_input("puzzle_input/day2.txt", alloc);
    defer alloc.free(input);

    const datalist = try parse_input(input, alloc);
    defer datalist.deinit();

    try part1(&datalist, alloc);
    try part2(&datalist, alloc);
}
