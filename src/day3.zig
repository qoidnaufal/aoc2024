const std = @import("std");
const read_input = @import("main.zig").read_input;

const Allocator = std.mem.Allocator;

const Pair = struct {
    left: std.ArrayListAligned(u32, null),
    right: std.ArrayListAligned(u32, null),

    const DataErr = error{
        UnequalLeftHasMoreItems,
        UnequalRightHasMoreItems,
    };

    const Self = @This();
    fn init(alloc: *const Allocator) Self {
        return Self {
            .left =  std.ArrayList(u32).init(alloc.*),
            .right = std.ArrayList(u32).init(alloc.*)
        };
    }

    fn deinit(self: *const Self) void {
        self.left.deinit();
        self.right.deinit();
    }

    fn appendFromToken(self: *Self, token1: []const u8, token2: []const u8) !void {
        const num1 = try std.fmt.parseInt(u32, token1, 10);
        const num2 = try std.fmt.parseInt(u32, token2, 10);
        try self.left.append(num1);
        try self.right.append(num2);
    }

    fn len(self: *const Self) DataErr!usize {
        if (self.left.items.len > self.right.items.len) return DataErr.UnequalLeftHasMoreItems;
        if (self.left.items.len < self.right.items.len) return DataErr.UnequalRightHasMoreItems;
        return self.left.items.len;
    }

    fn multiply(self: *const Self, idx: usize) u32 {
        return self.left.items[idx] * self.right.items[idx];
    }
};

fn part1(input: []const u8) !void {
    var accumulator: usize = 0;

    var iter = std.mem.splitAny(u8, input, "\n");
    while (iter.next()) |line| {
        try scan_line(line, &accumulator);
    }

    std.debug.print("{d}", .{ accumulator });
}

fn scan_line(line: []const u8, accumulator: *usize) !void {
    var cursor: usize = 0;
    while (cursor < line.len): (cursor += 1) {
        if (line[cursor] != 'm') continue;

        const mul = line[cursor..cursor + 3];
        if (std.mem.eql(u8, mul, "mul")) cursor += 3;
        if (line[cursor] != '(') continue;

        const comma = std.mem.indexOfScalar(u8, line[cursor..], ',') orelse continue;
        const token1 = line[cursor + 1..cursor + comma];
        if (token1.len > 3) continue;

        const close = std.mem.indexOfScalar(u8, line[cursor + comma..], ')') orelse continue;
        const token2 = line[cursor + comma + 1..cursor + comma + close];
        if (token2.len > 3) continue;

        std.debug.print("token: {s},{s}\n", .{token1, token2});
        const num1 = std.fmt.parseInt(u32, token1, 10) catch continue;
        const num2 = std.fmt.parseInt(u32, token2, 10) catch continue;
        accumulator.* += num1 * num2;
    }
}


pub fn run(alloc: *const Allocator) !void {
    const input = try read_input("puzzle_input/day3.txt", alloc);
    defer alloc.free(input);

    try part1(input);
}
