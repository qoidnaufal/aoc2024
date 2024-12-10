const std = @import("std");

const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");
const day4 = @import("day4.zig");
const day5 = @import("day5.zig");
const day6 = @import("day6.zig");

const Allocator = std.mem.Allocator;

pub fn read_input(file_path: []const u8, alloc: *const Allocator) ![]const u8 {
    var path_buffer: [1024]u8 = undefined;
    const path = try std.fs.realpath(file_path, &path_buffer);
    var file = try std.fs.openFileAbsolute(path, .{.mode = .read_only});
    errdefer file.close();
    defer file.close();

    const file_size = (try file.metadata()).size();
    const reader = file.reader();

    const buffer = try alloc.alloc(u8, @intCast(file_size));
    const len = try reader.readAll(buffer);

    return buffer[0..len];
}

const Day = enum {
    day1,
    day2,
    day3,
    day4,
    day5,
    day6,
};

pub fn main() !void {
    var gp = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gp.deinit();
    errdefer _ = gp.deinit();
    const alloc = gp.allocator();

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);
    errdefer std.process.argsFree(alloc, args);

    switch (args.len) {
        1 => std.debug.print(
            "Can't show any result, specify which day to run! (eg: day1, day2, etc)\n",
            .{}
        ),
        2 => {
            const day = std.meta.stringToEnum(Day, args[1]) orelse {
                std.debug.print(
                    "Wrong args: [{s}]! Specify which day to run! (eg: day1, day2, etc)\n",
                    .{args[1]}
                );
                return;
            };
            switch (day) {
                .day1 => try day1.run(&alloc),
                .day2 => try day2.run(&alloc),
                .day3 => try day3.run(&alloc),
                .day4 => try day4.run(&alloc),
                .day5 => try day5.run(&alloc),
                .day6 => try day6.run(&alloc),
            }
        },
        else => std.debug.print(
            "Too many args! Specify which day to run! (eg: day1, or day2, etc)\n",
            .{}
        )
    }
}
