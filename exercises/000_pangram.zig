// To start off my learning I jumped in with a prompt I found online
// https://exercism.org/tracks/zig/exercises/pangram

const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main() !void {
    const str = "the quick brown fox jumps over a lazy dog";
    const pangram = try isPangram(str);

    if (pangram) {
        std.debug.print("\"{s}\" is a pangram", .{str});
    } else {
        std.debug.print("\"{s}\" is not a pangram", .{str});
    }
}

fn isPangram(string: []const u8) !bool {
    var buffer: [100]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    var seen: [26]bool = undefined;
    fill(&seen, false);
    var seenCount: u8 = 0;

    for (string) |char| {
        var keycode = getKeycode(allocator, char);
        offsetKeycodeToAlphabet(&keycode);
        if (keycode == 0) {
            continue;
        }

        keycode -= 1;

        if (!seen[keycode]) {
            seen[keycode] = true;
            seenCount += 1;
        }
        
        if (seenCount == 26) {
            break;
        }
    }

    return seenCount == 26;
}

fn fill(array: *[26]bool, init: bool) void {
    for (array, 0..) |_, i| {
        array.*[i] = init;
    }
}

fn offsetKeycodeToAlphabet(keycode: *u8) void {
    const a = 97;
    const z = 122;
    const A = 65;
    const Z = 90;
    const lowercase = keycode.* >= a and keycode.* <= z;
    const uppercase = keycode.* >= A and keycode.* <= Z;

    if (!lowercase and !uppercase) {
        keycode.* = 0;
    }

    if (lowercase) {
        keycode.* -= a - 1;
    }

    if (uppercase) {
        keycode.* -= A - 1;
    }
}

fn getKeycode(allocator: Allocator, char: u8) u8 {
    const unicode: []u8 = std.fmt.allocPrint(allocator, "{u}", .{char}) catch {
        return 0;
    };
    return unicode[0];
}
