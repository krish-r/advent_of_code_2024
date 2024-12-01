const std = @import("std");

pub fn main() !void {
    var arena_instance = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_instance.deinit();
    const arena = arena_instance.allocator();

    const data = @embedFile("data/day01.txt");

    const total_distance = try day01_part01(arena, data);
    std.debug.print("part01: total distance: {d}\n", .{total_distance});

    const similarity_score = try day01_part02(arena, data);
    std.debug.print("part02: similarity score: {d}\n", .{similarity_score});
}

fn lessThan(context: void, a: isize, b: isize) std.math.Order {
    _ = context;
    return std.math.order(a, b);
}

fn day01_part01(allocator: std.mem.Allocator, data: []const u8) !usize {
    var total_distance: usize = 0;

    const priority_queue = std.PriorityQueue(isize, void, lessThan);

    var left = priority_queue.init(allocator, {});
    defer left.deinit();
    var right = priority_queue.init(allocator, {});
    defer right.deinit();

    var line_it = std.mem.tokenizeScalar(u8, data, '\n');
    while (line_it.next()) |line| {
        var it = std.mem.tokenizeScalar(u8, line, ' ');

        try left.add(try std.fmt.parseInt(isize, it.next().?, 10));
        try right.add(try std.fmt.parseInt(isize, it.next().?, 10));
    }

    std.debug.assert(left.count() == right.count());
    for (0..left.count()) |_| {
        total_distance += @abs(left.remove() - right.remove());
    }

    return total_distance;
}

fn day01_part02(allocator: std.mem.Allocator, data: []const u8) !usize {
    var similarity_score: usize = 0;

    var left = std.ArrayList(usize).init(allocator);
    defer left.deinit();
    var right = std.AutoHashMap(usize, usize).init(allocator);
    defer right.deinit();

    var line_it = std.mem.tokenizeScalar(u8, data, '\n');
    while (line_it.next()) |line| {
        var it = std.mem.tokenizeScalar(u8, line, ' ');

        try left.append(try std.fmt.parseInt(usize, it.next().?, 10));
        const entry = try right.getOrPutValue(try std.fmt.parseInt(usize, it.next().?, 10), 0);
        entry.value_ptr.* += 1;
    }

    for (left.items) |item| {
        similarity_score += (item * (right.get(item) orelse 0));
    }

    return similarity_score;
}

test "day01 part01" {
    const data =
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
    ;
    try std.testing.expectEqual(11, try day01_part01(std.testing.allocator, data));
}

test "day01 part02" {
    const data =
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
    ;
    try std.testing.expectEqual(31, try day01_part02(std.testing.allocator, data));
}
