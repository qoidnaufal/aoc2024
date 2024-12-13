const std = @import("std");
const read_input = @import("main.zig").read_input;
const Allocator = std.mem.Allocator;

const Direction = enum {
    Up,
    Right,
    Left,
    Down,

    const Self = @This();

    fn from(ptr: u8) ?Self {
        switch (ptr) {
            '^' => return .Up,
            '>' => return .Right,
            'v' => return .Down,
            '<' => return .Left,
            else => return null,
        }
    }

    fn to_char(self: Self) u8 {
        const char: u8 = switch (self) {
           Self.Up  => '^',
           Self.Right  => '>',
           Self.Down  => 'v',
           else  => '<',
        };

        return char;
    }

    fn rotate(self: Self) Self {
        return switch (self) {
            .Up => .Right,
            .Right => .Down,
            .Down => .Left,
            else => .Up,
        };
    }

    fn isNinetyDegree(self: Self, other: Self) bool {
        const is_it = switch (self) {
           Self.Up  => other == .Right,
           Self.Right  => other == .Down,
           Self.Down  => other == .Left,
           else  => other == .Up,
        };

        return is_it;
    }
};

const Map = struct {
    data: std.ArrayListAligned(u8, null),
    width: usize,
    height: usize,
    start_idx: usize,
    last_idx: usize,
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
            .start_idx = 0,
            .last_idx = 0,
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

    fn printFinalGrid(self: *Self) void {
        self.data.items[self.last_idx] = 'E';
        self.data.items[self.start_idx] = 'S';

        var line_count: usize = 0;
        var row_count: usize = 0;
        for (self.data.items) |c| {
            if (row_count % self.width == 0) {
                std.debug.print("{d: >4} | ", .{line_count});
                line_count += 1;
            }
            row_count += 1;
            std.debug.print("{c}", .{c});
            if (row_count % self.width == 0) {
                if (line_count == (self.start_idx - (self.start_idx % self.width)) / self.width + 1) std.debug.print(" <<-- Start", .{});
                if (line_count == (self.last_idx - (self.last_idx % self.width)) / self.width + 1) std.debug.print(" <<-- End", .{});
                std.debug.print("\n", .{});
            }
        }
    }

    fn setCursor(self: *Self, idx: usize, direction: Direction) void {
        self.start_idx = idx;
        self.cursor = .{
            .idx = idx,
            .direction = direction,
        };
    }

    fn nextIndex(self: *const Self) usize {
        switch (self.cursor.direction) {
            .Up => return self.cursor.idx - self.width,
            .Right => return self.cursor.idx + 1,
            .Down => return self.cursor.idx + self.width,
            .Left => return self.cursor.idx - 1,
        }
    }

    fn changeDirection(self: *Self) void {
        self.cursor.direction = self.cursor.direction.rotate();
    }

    fn isHittingEdge(self: *const Self) bool {
        return (self.cursor.idx % self.width == 0 and self.cursor.direction == .Left)
            or (self.cursor.idx % self.width == self.width - 1 and self.cursor.direction == .Right)
            or (self.cursor.idx < self.width and self.cursor.direction == .Up)
            or (self.cursor.idx >= self.width * (self.height - 1) and self.cursor.direction == .Down);
    }

    fn nextSpot(self: *const Self) u8 {
        return self.data.items[self.nextIndex()];
    }

    fn leftSpot(self: *const Self) usize {
        return switch (self.cursor.direction) {
            .Up => self.cursor.idx - 1,
            .Right => self.cursor.idx - self.width,
            .Down => self.cursor.idx + 1,
            .Left => self.cursor.idx + self.width,
        };
    }

    fn rightSpot(self: *const Self) usize {
        return switch (self.cursor.direction) {
            .Up => self.cursor.idx + 1,
            .Right => self.cursor.idx + self.width,
            .Down => self.cursor.idx - 1,
            .Left => self.cursor.idx - self.width,
        };
    }

    fn anticipateLoop(self: *const Self, buffer: *const []AdjacentWall) bool {
        const curr = self.cursor.direction;
        var is_it = false;
        for (buffer.*) |wall| {
            switch (curr) {
                .Up, => {
                    if (self.cursor.idx - (self.cursor.idx % self.width) == wall.idx - (wall.idx % self.width)
                        and self.cursor.idx < wall.idx
                        and ((wall.dir == .Right and wall.hit) or (wall.dir == .Down and !wall.hit))
                    ) {
                        is_it = true;
                        break;
                    }
                },
                .Down => {
                    if (self.cursor.idx - (self.cursor.idx % self.width) == wall.idx - (wall.idx % self.width)
                        and self.cursor.idx > wall.idx
                        and ((wall.dir == .Left and wall.hit) or (wall.dir == .Up and !wall.hit))
                    ) {
                        is_it = true;
                        break;
                    }
                },
                .Left => {
                    if (self.cursor.idx % self.width == wall.idx % self.width
                        and self.cursor.idx > wall.idx
                        and ((wall.dir == .Up and wall.hit) or (wall.dir == .Right and !wall.hit))
                    ) {
                        is_it = true;
                        break;
                    }
                },
                .Right => {
                    if (self.cursor.idx % self.width == wall.idx % self.width
                        and self.cursor.idx < wall.idx
                        and ((wall.dir == .Down and wall.hit) or (wall.dir == .Left and !wall.hit))
                    ) {
                        is_it = true;
                        break;
                    }
                }
            }
        }
        const sect = Direction.from(self.data.items[self.rightSpot()]) orelse self.cursor.direction;
        return (curr.isNinetyDegree(sect) or is_it) and self.nextSpot() != '#' and self.nextIndex() != self.start_idx;
    }
};

const Result = struct {
    visited: usize,
    loop: usize,
};

const AdjacentWall = struct {
    idx: usize,
    dir: Direction,
    hit: bool,
};

fn solve(map: *Map, alloc: *const Allocator, print: Print) !Result {
    var wallCount: usize = 0;
    var wallBuffer = try alloc.alloc(AdjacentWall, map.width * map.height);
    defer alloc.free(wallBuffer);

    var grid = try alloc.dupe(u8, map.data.items);
    defer alloc.free(grid);

    var visited: usize = 1;
    var loop: usize = 0;
    while (!map.isHittingEdge()) {
        if (map.nextSpot() == '#') {
            wallBuffer[wallCount] = .{ .idx = map.nextIndex(), .hit = true, .dir = map.cursor.direction };
            wallCount += 1;
            map.changeDirection();
        }
        if (map.data.items[map.leftSpot()] == '#') {
            wallBuffer[wallCount] = .{ .idx = map.leftSpot(), .hit = false, .dir = map.cursor.direction };
            wallCount += 1;
        }

        const next = map.nextIndex();
        if (map.data.items[next] == '.') visited += 1;
        if (map.anticipateLoop(&wallBuffer[0..wallCount])) {
            // std.debug.print("blocker: {}\n", .{next});
            grid[next] = 'O';
            loop += 1;
        }

        map.data.items[next] = map.cursor.direction.to_char();
        map.cursor.idx = next;
    }

    map.last_idx = map.cursor.idx;
    switch (print) {
        .Loop => printGrid(&grid, map.width, map.start_idx, map.last_idx),
        .Yes => map.printFinalGrid(),
        .No => {}
    }
    
    return .{ .visited = visited, .loop = loop };
}

fn printGrid(grid: *[]u8, width: usize, start_idx: usize, last_idx: usize) void {
    var line_count: usize = 0;
    var row_count: usize = 0;
    for (grid.*) |c| {
        if (row_count % width == 0) {
            std.debug.print("{d: >4} | ", .{line_count});
            line_count += 1;
        }
        row_count += 1;
        std.debug.print("{c}", .{c});
        if (row_count % width == 0) {
            if (line_count == (start_idx - (start_idx % width)) / width + 1) std.debug.print(" <<-- Start", .{});
            if (line_count == (last_idx - (last_idx % width)) / width + 1) std.debug.print(" <<-- End", .{});
            std.debug.print("\n", .{});
        }
    }
}

fn parse_input(input: []const u8, alloc: *const Allocator) !Map {
    var iter = std.mem.splitScalar(u8, input, '\n');
    var map = Map.init(alloc);

    var height: usize = 0;
    while (iter.next()) |line| {
        if (line.len > 0) {
            for (line, 0..) |char, idx| {
                if (Direction.from(char)) |direction| {
                    map.setCursor((height * line.len) + idx, direction);
                }
                try map.append(char);
            }
            map.width = line.len;
            height += 1;
        }
    }
    map.height = height;
    return map;
}

test "day6" {
    const test_input =
\\....#.....
\\.........#
\\..........
\\..#.......
\\.......#..
\\..........
\\.#..^.....
\\........#.
\\#.........
\\......#...
;
    var gp = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gp.deinit();

    const alloc = gp.allocator();
    var map = try parse_input(test_input, &alloc);
    defer map.deinit();

    const result = try solve(&map, &alloc, Print.Loop);

    const expect: usize = 6;

    std.testing.expect(result.loop == expect) catch {
        std.debug.print("expected {}, got {}\n", .{expect, result.loop});
    };
}

const Print = enum {
    Loop,
    Yes,
    No
};

pub fn run(alloc: *const Allocator) !void {
    const input = try read_input("puzzle_input/day6.txt", alloc);
    defer alloc.free(input);

    var map = try parse_input(input, alloc);
    defer map.deinit();

    const result = try solve(&map, alloc, Print.Loop);

    // part 1 = 5318
    // part 2 = [ 2064 -> too high, 822 -> too low, 2683 -> F!!!, 1903 -> wrong ]
    std.debug.print("part1: {}, part2: {}\n", .{result.visited, result.loop});
}
