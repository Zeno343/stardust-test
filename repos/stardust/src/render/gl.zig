pub usingnamespace @cImport({
    @cDefine("GL_GLEXT_PROTOTYPES", "");
    @cInclude("SDL_opengl.h");
    @cInclude("GL/gl.h");
    @cInclude("GL/glext.h");
});
