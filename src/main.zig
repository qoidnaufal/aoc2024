const std = @import("std");

const day1 = @import("day1.zig");
const day2 = @import("day2.zig");

const Allocator = std.mem.Allocator;

pub fn read_input(file_path: []const u8, alloc: *const Allocator) ![]const u8 {
    var path_buffer: [1024]u8 = undefined;
    const path = try std.fs.realpath(file_path, &path_buffer);
    var file = try std.fs.openFileAbsolute(path, .{.mode = .read_only});
    defer file.close();

    const file_size = (try file.metadata()).size();
    const reader = file.reader();

    const buffer = try alloc.alloc(u8, @intCast(file_size));
    const len = try reader.readAll(buffer);

    return buffer[0..len];
}

const Day = enum {
    day1,
    day2
};

pub fn main() !void {
    var gp = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gp.deinit();
    const alloc = gp.allocator();

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    if (args.len == 1) {
        std.debug.print("Can't show any result, specify which day to run! (eg: day1, day2, etc)\n", .{});
    } else {
        const day = std.meta.stringToEnum(Day, args[1]);
        if (day) |d| {
            switch (d) {
                .day1 => try day1.run(&alloc),
                .day2 => try day2.run(&alloc),
            }
        } else {
            std.debug.print("{s} is not available yet!\n", .{args[1]});
        }
    }
}
