<div align=center>
<img src="imgs/theme.jpeg" alt="singularity" width="100%">
</div>

---

Static recompilation of the Xbox 360 version of Singularity (2010) using rexglue-sdk.

The project is fully vibecoded.

The end goal is to port the game to the Switch, but this repo is released as a ready-to-use rexglue-sdk recipe for recompiling and playing your **legally owned and purchased** Xbox 360 copy of Singularity on PC, using emulated Xbox 360 rendering.

On a laptop with an RTX 3050 GPU, the game runs at a steady 30 fps throughout.

Contributions that make the PC version run better, such as a native renderer, are welcome and appreciated. I hope the recompilation work Claude and I have done will help with that.

The game has not yet been tested from start to finish.

### Instructions

Requirements: Linux, clang-20, CMake 3.25+, Ninja, a Vulkan GPU.

1. Clone the repo with its submodules. rexglue-sdk is pinned to upstream commit `bd833a2`
   in `thirdparty/rexglue-sdk`. Then apply the SDK patches:

   ```bash
   git clone --recursive <this repo's URL> singularity-recomp
   cd singularity-recomp
   tools/apply_patches.sh
   ```

2. Extract your copy of the game (`default.xex` and its data files) into
   `singularity-extract/` (it is gitignored). Only the v1.0 `default.xex` with SHA-256
   `d55636b840319ca8b6b9b6e8c4fc06981803787af61c331ea56eacfb7ad5dac5` is supported.

   ```text
   singularity-recomp/
     singularity-extract/
       default.xex
     thirdparty/rexglue-sdk/
   ```

3. Build. The SDK is built as part of the project. The first build runs codegen
   (about 10 minutes) and then compiles the recompiled game, which takes a while.

   ```bash
   cmake --preset linux-amd64-release
   cmake --build --preset linux-amd64-release
   ```

4. Run:

   ```bash
   tools/run.sh
   ```

   The script removes guest memory segments left in `/dev/shm` by crashed runs and selects
   the NVIDIA GPU on hybrid laptops. Runtime settings are in `config/singularity.toml`.

### Changes

rexglue-sdk patches (`patches/`, on top of upstream `bd833a2`):

| Patch | What was wrong | Effect in game | Source |
|---|---|---|---|
| `0001` | On GPUs without `VK_EXT_shader_stencil_export` (NVIDIA), stencil copies between render targets never discarded pixels, so stencil saturated at 255 | Lighting masked by stencil turned into "liquid" noise and red blotches, some scenes were black | Xenia Canary `24f90c0ef` |
| `0002` | Texture `exp_adjust` was read from the wrong fetch constant word | White patches flashing over textures | Upstream PR #490 |
| `0003` | Depth written by pixel shaders was not remapped for float24 depth buffers; UE3 restores scene depth this way | Missing water, explosions, projector images, title screen vortex and beam | Xenia Canary `b15fcc73e` |
| `0004` | The achievement popup existed for the whole session, so the window repainted at the monitor rate | FPS counters showed the monitor rate (e.g. 144) instead of the game's 30 | — |

Config (`config/singularity.toml`):

| Setting | Effect in game |
|---|---|
| `readback_memexport = false`, `clear_memory_page_state = false` (Xenia Canary's defaults) | Scenes with GPU particles, such as the burning helicopter at the start, went from ~13 fps to a steady 30 |
| `vulkan_allow_present_mode_immediate/mailbox = false` | Presents with vsync instead of redrawing the same frame hundreds of times per second |

`overrides.toml` declares 277 function entry points the codegen analyzer misses. Without
them the game stops with "call to invalid or unregistered function" when one is called.

| Count | How it was found |
|---:|---|
| 4 | Tail-call branch targets, reported by codegen as unresolved calls |
| 2 | Functions reached only through vtables, from runtime errors |
| 252 | Code addresses in the game's data sections (mostly vtables) pointing into gaps between detected functions, found by scanning the loaded image |
| 19 | Function addresses built in code with `lis`+`addi`, found by the same scan |
