#include <iostream>
#include <array>

#include <SDL2/SDL.h>

#include "Vtt_um_nvious_graphics.h"
#include "verilated.h"

// VGA Timings Reference: https://martin.hinner.info/vga/timing.html

#define VGA_HORZ_ACTIVE     640
#define VGA_HORZ_FRONT_PORCH 16
#define VGA_HORZ_SYNC_PULSE  96
#define VGA_HORZ_BACK_PORCH  48

#define VGA_VERT_ACTIVE     480
#define VGA_VERT_FRONT_PORCH 11
#define VGA_VERT_SYNC_PULSE   2
#define VGA_VERT_BACK_PORCH  31

#define VGA_HZ 60
#define VGA_FRAME_CYCLES ((VGA_HORZ_ACTIVE + VGA_HORZ_FRONT_PORCH + VGA_HORZ_SYNC_PULSE + VGA_HORZ_BACK_PORCH) * (VGA_HORZ_ACTIVE + VGA_HORZ_FRONT_PORCH + VGA_HORZ_SYNC_PULSE + VGA_HORZ_BACK_PORCH))

struct RGB888_t { uint8_t b, g, r, a; } __attribute__((packed));

int main(int argc, char **argv) {

	std::array<RGB888_t, VGA_HORZ_ACTIVE * VGA_VERT_ACTIVE> framebuffer;

	Verilated::commandArgs(argc, argv);

	Vtt_um_nvious_graphics *top = new Vtt_um_nvious_graphics;

	// Reset module
	top->clk = 0;
	top->eval();
	top->rst_n = 0;
	top->clk = 1;
	top->eval();
	top->rst_n = 1;

	SDL_Init(SDL_INIT_VIDEO);

	SDL_Window* window =
	    SDL_CreateWindow(
	        "Tiny Tapeout VGA",
	        SDL_WINDOWPOS_UNDEFINED,
	        SDL_WINDOWPOS_UNDEFINED,
	        VGA_HORZ_ACTIVE,
	        VGA_VERT_ACTIVE,
	        0
	    );

	SDL_Renderer* renderer =
	    SDL_CreateRenderer(
	        window,
	        -1,
	        SDL_RENDERER_ACCELERATED
	    );

	SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL_ALPHA_OPAQUE);
	SDL_RenderClear(renderer);

	SDL_Event e;

	SDL_Texture* texture =
	    SDL_CreateTexture(
	        renderer,
	        SDL_PIXELFORMAT_ARGB8888,
	        SDL_TEXTUREACCESS_STREAMING,
	        VGA_HORZ_ACTIVE,
	        VGA_VERT_ACTIVE
	    );

	bool quit = false;

	int hnum = 0;
	int vnum = 0;
	int polarity = 1;

	while (!quit) {
		int last_ticks = SDL_GetTicks();
		uint8_t ui_in = 0;

		while (SDL_PollEvent(&e) == 1) {
			if (e.type == SDL_QUIT) {
				quit = true;
			} else if (e.type == SDL_KEYDOWN) {
				switch (e.key.keysym.sym) {
					case SDLK_ESCAPE:
					case SDLK_q:
						quit = true;
						break;
					case SDLK_f:
						static Uint32 mode = SDL_WINDOW_FULLSCREEN;
						SDL_SetWindowFullscreen(window, mode);
						mode = mode ? 0 : SDL_WINDOW_FULLSCREEN;
						break;
					case SDLK_p: // swap VGA sync polarity
						polarity = polarity ? 0 : 1;
						break;
					default:
						break;
				}
			}
		}

		auto keystate = SDL_GetKeyboardState(NULL);
		int rst_n = !keystate[SDL_SCANCODE_R];
		ui_in |= keystate[SDL_SCANCODE_0] << 0;
		ui_in |= keystate[SDL_SCANCODE_1] << 1;
		ui_in |= keystate[SDL_SCANCODE_2] << 2;
		ui_in |= keystate[SDL_SCANCODE_3] << 3;
		ui_in |= keystate[SDL_SCANCODE_4] << 4;
		ui_in |= keystate[SDL_SCANCODE_5] << 5;
		ui_in |= keystate[SDL_SCANCODE_6] << 6;
		ui_in |= keystate[SDL_SCANCODE_7] << 7;

		for (int i = 0; i < VGA_FRAME_CYCLES; i++) {

			top->clk = 0;
			top->eval();
			if (rst_n == 0) top->rst_n = 0;
			top->ui_in = ui_in;
			top->clk = 1;
			top->eval();
			if (rst_n == 0) top->rst_n = 1;
			top->ui_in = ui_in;

			uint8_t uo_out = top->uo_out; // {hsync, b0, g0, r0, vsync, b1, g1, r1}:
			uint8_t hsync = (uo_out & 0b10000000) >> 7;
			uint8_t vsync = (uo_out & 0b00001000) >> 3;

			// h and v blank logic
			if (hsync == polarity && vsync == polarity) { // XXX Sync polarity positive or negative?
				hnum = -VGA_HORZ_BACK_PORCH;
				vnum = -VGA_VERT_BACK_PORCH - VGA_VERT_SYNC_PULSE; // XXX include SYNC_PULSE???
			}

			// active frame
			if ((hnum >= 0) && (hnum < VGA_HORZ_ACTIVE) && (vnum >= 0) && (vnum < VGA_VERT_ACTIVE)) {
				uint8_t rr = (((uo_out & 0b00000001) << 1) | ((uo_out & 0b00010000) >> 4)) * 85;
				uint8_t gg = (((uo_out & 0b00000010) << 0) | ((uo_out & 0b00100000) >> 5)) * 85;
				uint8_t bb = (((uo_out & 0b00000100) >> 1) | ((uo_out & 0b01000000) >> 6)) * 85;
				RGB888_t rrggbb = { .b = bb, .g = gg, .r = rr };
				framebuffer[vnum * VGA_HORZ_ACTIVE + hnum] = rrggbb;
			}

			// keep track of encountered fields
			hnum++;
			if (hnum >= VGA_HORZ_ACTIVE + VGA_HORZ_FRONT_PORCH + VGA_HORZ_SYNC_PULSE) {
				hnum = -VGA_HORZ_BACK_PORCH;
				vnum++;
			}

		}

		SDL_UpdateTexture(
		    texture,
		    NULL,
		    framebuffer.data(),
		    VGA_HORZ_ACTIVE * sizeof(RGB888_t)
		);

		SDL_RenderCopy(
		    renderer,
		    texture,
		    NULL,
		    NULL
		);

		SDL_RenderPresent(renderer);

		int ticks = SDL_GetTicks();
		static int last_update_ticks = 0;
		if (ticks - last_update_ticks > 1000) {
			last_update_ticks = ticks;
			std::string fps = "Tiny Tapeout VGA (" + std::to_string((int)1000.0/(ticks - last_ticks)) + " FPS)";
			SDL_SetWindowTitle(window, fps.c_str());
		}
	}

	top->final();
	delete top;

	SDL_DestroyRenderer(renderer);
	SDL_DestroyWindow(window);
	SDL_Quit();

	return EXIT_SUCCESS;
}
