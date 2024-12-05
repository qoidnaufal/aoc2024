const std = @import("std");
const read_input = @import("main.zig").read_input;

const Allocator = std.mem.Allocator;

const State = enum {
    Scan,
    Parse,
};

const Command = enum {
    Do,
    Dont
};

const Accumulator = struct {
    command: Command,
    state: State,
    part1: u32,
    part2: u32,

    const Self = @This();

    fn setCommand(self: *Self, command: Command) void {
        self.command = command;
    }

    fn accumulate(self: *Self, num: u32) void {
        self.part1 += num;
        if (self.command == .Do) self.part2 += num;
    }
};

fn solve(input: []const u8) void {
    var acc = Accumulator {
            .state = .Scan,
            .command = .Do,
            .part1 = 0,
            .part2 = 0
        };

    var iter = std.mem.splitAny(u8, input, "\n");
    var line_number: u8 = 0;

    while (iter.next()) |line| {
        std.debug.print(">> New scan: {d}\n", .{line_number});
        scan_line(line, &acc);
        line_number += 1;
    }

    // part 1: 157621318
    // part 2: 79845780
    std.debug.print("part1 = {d}, part2 = {d}\n", .{ acc.part1, acc.part2 });
}

fn scan_line(line: []const u8, acc: *Accumulator) void {
    var cursor: usize = 0;

    while (cursor < line.len): (cursor += 1) {
        switch (acc.state) {
            .Scan => {
                if (std.mem.startsWith(u8, line[cursor..], "mul(")) {
                    cursor += 3;
                    acc.state = .Parse;
                    continue;
                }

                if (std.mem.startsWith(u8, line[cursor..], "do()")) {
                    std.debug.print(">> {s}\n", .{line[cursor..cursor + 4]});
                    cursor += 3;
                    acc.setCommand(.Do);
                }

                if (std.mem.startsWith(u8, line[cursor..], "don't()")) {
                    std.debug.print(">> {s}\n", .{line[cursor..cursor + 7]});
                    cursor += 6;
                    acc.setCommand(.Dont);
                }
            },
            .Parse => {
                // when we arrive here, we know the cursor is currently pointing after '('
                const comma = std.mem.indexOfScalar(u8, line[cursor..], ',') orelse break;
                const token1 = line[cursor..cursor + comma];
                const num1 = std.fmt.parseInt(u32, token1, 10) catch {
                    cursor -= 1;
                    acc.state = .Scan;
                    continue;
                };
                cursor += comma + 1;

                const close = std.mem.indexOfScalar(u8, line[cursor..], ')') orelse break;
                const token2 = line[cursor..cursor + close];
                const num2 = std.fmt.parseInt(u32, token2, 10) catch {
                    cursor -= 1;
                    acc.state = .Scan;
                    continue;
                };
                std.debug.print("   command: {}, token: {d},{d}\n", .{acc.command, num1, num2});

                // make sure on next scan we don't miss any mul(, do() or don't()
                cursor += close;

                acc.accumulate(num1 * num2);
                acc.state = .Scan;
            },
        }
    }
}

pub fn run(alloc: *const Allocator) !void {
    const input = try read_input("puzzle_input/day3.txt", alloc);
    defer alloc.free(input);

    solve(input);
}
