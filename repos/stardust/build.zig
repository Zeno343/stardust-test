const std = @import("std");

pub fn build(b: *std.Build) void {
    const web_deps = std.process.getEnvVarOwned(b.allocator, "WEB_DEPS") catch {
        @panic("No wasm dependencies provided");
    };
    const cache = ".cache";

    const c_main = b.addSystemCommand(&.{ "emcc", "--cache", cache });
    c_main.addArg("-o");
    //const main_wasm = c_main.addOutputFileArg("main.wasm");

    const ctcf_web = b.addStaticLibrary(.{
        .name = "catchfire_web",
        .root_source_file = b.path("src/lib.zig"),
        .target = b.resolveTargetQuery(
            .{ .cpu_arch = .wasm32, .os_tag = .emscripten },
        ),
        .optimize = .ReleaseFast,
        .link_libc = true,
    });
    ctcf_web.addIncludePath(.{ .cwd_relative = b.pathJoin(&.{ web_deps, "include", "SDL2" }) });
    ctcf_web.addIncludePath(.{ .cwd_relative = b.pathJoin(&.{ web_deps, "include-config-", "SDL2" }) });
    ctcf_web.addIncludePath(.{ .cwd_relative = b.pathJoin(&.{ web_deps, "include", "emscripten", "include" }) });
    ctcf_web.addLibraryPath(.{ .cwd_relative = web_deps });
    const wasm_lib = b.addInstallArtifact(ctcf_web, .{});

    const web_build = b.addWriteFiles();
    const web = b.addSystemCommand(&.{ "emcc", "--cache", cache });
    web.addFileArg(b.path("src/web/main.c"));
    web.addArg("-sFULL_ES3");
    web.addArg("-sMIN_WEBGL_VERSION=2");
    web.addArtifactArg(ctcf_web);
    web.addArg("-lSDL2");
    web.addArg("-L");
    web.addArg(web_deps);
    web.addArg("-o");
    web.addArg("index.js");
    web.setCwd(web_build.getDirectory());

    web.step.dependOn(&wasm_lib.step);

    const install_html = b.addInstallFile(
        b.path("src/web/index.html"),
        "web/index.html",
    );
    install_html.step.dependOn(&web.step);
    const install_js = b.addInstallFile(
        web_build.getDirectory().path(b, "index.js"),
        "web/index.js",
    );
    install_js.step.dependOn(&web.step);
    const install_wasm = b.addInstallFile(
        web_build.getDirectory().path(b, "index.wasm"),
        "web/index.wasm",
    );
    install_wasm.step.dependOn(&web.step);

    const build_web = b.step("stardustWeb", "build wasm");

    build_web.dependOn(&install_js.step);
    build_web.dependOn(&install_wasm.step);
    build_web.dependOn(&install_html.step);
    build_web.dependOn(&web.step);

    const bin = b.addExecutable(.{ .name = "stardust", .root_source_file = b.path("src/main.zig"), .target = b.standardTargetOptions(.{}), .optimize = .ReleaseFast });
    bin.linkSystemLibrary("GL");
    bin.linkSystemLibrary("SDL2");
    bin.linkLibC();

    b.step("stardust", "desktop engine build").dependOn(&b.addInstallArtifact(bin, .{}).step);
    b.step("run:stardust", "run the desktop editor").dependOn(&b.addRunArtifact(bin).step);
}
