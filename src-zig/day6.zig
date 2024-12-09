const std = @import("std");
const read_input = @import("main.zig").read_input;
const Allocator = std.mem.Allocator;

const Direction = enum {
    Up,
    Right,
    Left,
    Down,

    const PointerParseError = error{
        InvalidChar,
    };

    const Self = @This();

    fn from(ptr: u8) PointerParseError!Self {
        switch (ptr) {
            '^' => return .Up,
            '>' => return .Right,
            'v' => return .Down,
            '<' => return .Left,
            else => return error.InvalidChar,
        }
    }
};

const Map = struct {
    data: std.ArrayListAligned(u8, null),
    width: usize,
    height: usize,
    cursor: struct {
        idx: usize,
        direction: Direction,
    },

    const Self = @This();

    fn init(alloc: *const Allocator) Self {
        return Self {
            .data = std.ArrayList(u8).init(alloc.*),
            .width = 0,
            .height = 0,
            .cursor = .{
                .idx = 0,
                .direction = .Up,
            },
        };
    }

    fn deinit(self: *const Self) void {
        self.data.deinit();
    }

    fn append(self: *Self, char: u8) !void {
        try self.data.append(char);
    }

    fn setCursor(self: *Self, idx: usize, direction: Direction) void {
        self.cursor = .{
            .idx = idx,
            .direction = direction,
        };
    }

    fn nextDirection(self: *const Self) @TypeOf(self.cursor) {
        switch (self.cursor.direction) {
            .Up => return .{
                .idx = self.cursor.idx - self.height,
                .direction = self.cursor.direction
            },
            .Right => return .{
                .idx = self.cursor.idx + 1,
                .direction = self.cursor.direction
            },
            .Down => return .{
                .idx = self.cursor.idx + self.height,
                .direction = self.cursor.direction
            },
            .Left => return .{
                .idx = self.cursor.idx - 1,
                .direction = self.cursor.direction
            },
        }
    }

    fn moveCursor(self: *Self) void {
        self.cursor = self.nextDirection();
        if (self.isHittingEdge() or self.nextSpot() == '#') self.changeDirection();
        // if (self.nextSpot() == '#') self.changeDirection();
    }

    fn changeDirection(self: *Self) void {
        switch (self.cursor.direction) {
            .Up => self.cursor.direction = .Right,
            .Right => self.cursor.direction = .Down,
            .Down => self.cursor.direction = .Left,
            .Left => self.cursor.direction = .Up,
        }
    }

    fn isHittingEdge(self: *const Self) bool {
        const hittin_gedge = (
            (self.cursor.idx % self.width == 0 and self.cursor.direction == .Left)
            or (self.cursor.idx % self.width == self.width - 1 and self.cursor.direction == .Right)
            or ((self.cursor.idx - (self.cursor.idx % self.width)) == 0 and self.cursor.direction == .Up)
            or ((self.cursor.idx - (self.cursor.idx % self.width)) == self.width * (self.height - 1) and self.cursor.direction == .Down)
        );
        return hittin_gedge;
    }

    fn nextSpot(self: *const Self) u8 {
        const next = self.data.items[self.nextDirection().idx];
        return next;
    }

    fn canMove(self: *const Self) bool {
        if (self.isHittingEdge() or self.nextSpot() == '#') return false;
        return true;
    }
};

fn part1(map: *Map, alloc: *const Allocator) !void {
    var grid = try alloc.dupe(u8, @constCast(map.data.items));
    errdefer alloc.free(grid);
    defer alloc.free(grid);

    const start_idx = map.cursor.idx;

    var counter: usize = 0;
    while (map.canMove()) {
        const idx = map.nextDirection().idx;
        if (grid[idx] == '.' or grid[idx] == map.data.items[start_idx]) {
            counter += 1;
            grid[idx] = 'X';
        }
        std.debug.print("{d}\r", .{counter});
        if (counter % 5000 == 0) std.debug.print("\n", .{});
        map.moveCursor();
        // if (counter % 5355 == 0) break;
    }

    const last_idx = map.cursor.idx;
    grid[last_idx] = switch (map.cursor.direction) {
        .Up => '^',
        .Right => '>',
        .Down => 'v',
        .Left => '<'
    };

    // 5317 -> too low
    std.debug.print(
        "[Terminated], final pos: [{d}, {d}] {} total visited: {d}\n",
        .{(last_idx - (last_idx % map.width)) / map.height, last_idx % map.width, map.cursor.direction, counter}
    );

    var row_count: usize = 0;
    var line_count: usize = 0;
    for (grid) |c| {
        if (row_count % map.width == 0) {
            std.debug.print("{d: >4} | ", .{line_count});
            line_count += 1;
        }
        std.debug.print("{c}", .{c});
        row_count += 1;
        if (row_count % map.width == 0) {
            if (line_count * map.width == start_idx - (start_idx % map.width) + map.width) std.debug.print(" <<-- Start", .{});
            if (line_count * map.width == last_idx - (last_idx % map.width) + map.width) std.debug.print(" <<-- End", .{});
            std.debug.print("\n", .{});
        }
    }
}

fn parse_input(input: []const u8, alloc: *const Allocator) !Map {
    var iter = std.mem.splitScalar(u8, input, '\n');
    var map = Map.init(alloc);
    errdefer map.deinit();

    var height: usize = 0;
    while (iter.next()) |line| {
        if (line.len > 0) {
            for (line, 0..) |char, idx| {
                if (char == '^' or char == '>' or char == 'v' or char == '<') {
                    map.setCursor((height * line.len) + idx, try Direction.from(char));
                }
                try map.append(char);
            }
            map.width = line.len;
            height += 1;
        }
    }
    map.height = height;
    // std.debug.print("{}\n", .{map});
    return map;
}

pub fn run(alloc: *const Allocator) !void {
    const input = try read_input("puzzle_input/day6.txt", alloc);
    defer alloc.free(input);
    errdefer alloc.free(input);

    var map = try parse_input(input, alloc);
    defer map.deinit();
    errdefer map.deinit();

    try part1(&map, alloc);
}
