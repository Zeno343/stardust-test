const gl = @import("gl.zig");

pub const Uniform = @This();

pub fn uniform(location: gl.GLint, value: gl.GLuint) void {
    gl.glUniform1ui(location, value);
}
