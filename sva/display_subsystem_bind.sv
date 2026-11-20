`timescale 1ns/1ps

bind display_subsystem_top
    display_sva_checker u_display_sva_checker (
        .clk            (pclk),
        .rst_n          (presetn),

        .display_enable (display_enable),
        .active_video   (active_video),
        .frame_start    (frame_start),

        .pixel_x        (pixel_x),
        .pixel_y        (pixel_y),

        .h_active       (h_active),
        .v_active       (v_active),

        .pready         (pready),
        .hsync          (hsync),
        .vsync          (vsync)
    );
