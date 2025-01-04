const std = @import("std");
const Device = @import("device/mod.zig");
const Window = Device.Window;
const Render = @import("render/mod.zig");

const NAME = "stardust v0.1";
const VERT_SRC = @embedFile("shaders/rgb.vert");
const FRAG_SRC = @embedFile("shaders/rgb.frag");

const VertexType = struct { [2]f32, [3]f32 };

pub fn main() !void {
    std.debug.print("{s}\n", .{NAME});
    const window = Window.init(NAME, null) catch return error.WindowInitFailed;
    const draw_size = window.size();
    std.debug.print("window size: ({d}, {d})\n", .{ draw_size[0], draw_size[1] });

    const shader = Render.Shader.compile(VERT_SRC, FRAG_SRC);

    const verts = Render.Buffer(VertexType).from_verts(&.{
        .{ .{ 0.5, -0.5 }, .{ 1.0, 0.0, 0.0 } },
        .{ .{ -0.5, -0.5 }, .{ 0.0, 1.0, 0.0 } },
        .{ .{ 0.0, 0.5 }, .{ 0.0, 0.0, 1.0 } },
    });
    verts.bind();

    const mesh = Render.Mesh.new().with_vertex_attrs(&.{
        Render.VertexAttr{ .n_components = 2, .type = Render.VertexType.Float },
        Render.VertexAttr{ .n_components = 3, .type = Render.VertexType.Float },
    });

    std.debug.print("runtime initialized, entering main loop\n", .{});

    var quit = false;
    while (!quit) {
        Render.viewport(0, 0, draw_size[0], draw_size[1]);
        Render.clear();

        shader.bind();
        mesh.draw(3, Render.Topology.Triangles);
        window.swap();

        while (Device.poll()) |event| {
            switch (event) {
                .Quit => {
                    quit = true;
                },

                .KeyDown => |keycode| {
                    switch (keycode) {
                        .Esc => {
                            quit = true;
                        },
                    }
                },
            }
        }
    }

    std.debug.print("exiting\n", .{});
    shader.drop();
    window.drop();

    std.debug.print("exited main loop\n", .{});
}
