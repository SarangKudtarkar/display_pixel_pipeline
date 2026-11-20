`timescale 1ns/1ps

module display_sva_checker (
    input logic        clk,
    input logic        rst_n,

    input logic        display_enable,
    input logic        active_video,
    input logic        frame_start,

    input logic [15:0] pixel_x,
    input logic [15:0] pixel_y,

    input logic [15:0] h_active,
    input logic [15:0] v_active,

    input logic        pready,
    input logic        hsync,
    input logic        vsync
);

    // --------------------------------------------------------
    // Assertion 1:
    // Display must remain inactive when disabled.
    // --------------------------------------------------------
    property p_display_disabled;
        @(posedge clk)
        disable iff (!rst_n)
        !display_enable |-> !active_video;
    endproperty

    a_display_disabled:
        assert property (p_display_disabled)
        else $error("SVA ERROR: Active video asserted while display disabled");


    // --------------------------------------------------------
    // Assertion 2:
    // Active video coordinates must be inside configured area.
    // --------------------------------------------------------
    property p_active_coordinates_valid;
        @(posedge clk)
        disable iff (!rst_n)
        active_video |->
            ((pixel_x < h_active) && (pixel_y < v_active));
    endproperty

    a_active_coordinates_valid:
        assert property (p_active_coordinates_valid)
        else $error("SVA ERROR: Active video coordinate out of range");


    // --------------------------------------------------------
    // Assertion 3:
    // Frame start must occur at coordinate (0,0).
    // --------------------------------------------------------
    property p_frame_start_coordinates;
        @(posedge clk)
        disable iff (!rst_n)
        frame_start |-> ((pixel_x == 16'd0) && (pixel_y == 16'd0));
    endproperty

    a_frame_start_coordinates:
        assert property (p_frame_start_coordinates)
        else $error("SVA ERROR: Frame start at incorrect coordinates");


    // --------------------------------------------------------
    // Assertion 4:
    // APB must always be ready.
    // --------------------------------------------------------
    property p_apb_ready;
        @(posedge clk)
        disable iff (!rst_n)
        pready == 1'b1;
    endproperty

    a_apb_ready:
        assert property (p_apb_ready)
        else $error("SVA ERROR: APB PREADY is not asserted");


    // --------------------------------------------------------
    // Assertion 5:
    // Important outputs must not contain X/Z during operation.
    // --------------------------------------------------------
    property p_outputs_known;
        @(posedge clk)
        disable iff (!rst_n)
        !$isunknown({
            active_video,
            frame_start,
            hsync,
            vsync,
            display_enable
        });
    endproperty

    a_outputs_known:
        assert property (p_outputs_known)
        else $error("SVA ERROR: Unknown value detected on display outputs");


    // --------------------------------------------------------
    // Assertion 6:
    // Timing configuration must be non-zero during operation.
    // --------------------------------------------------------
    property p_valid_timing_configuration;
        @(posedge clk)
        disable iff (!rst_n)
        (display_enable == 1'b1) |->
            ((h_active > 0) && (v_active > 0));
    endproperty

    a_valid_timing_configuration:
        assert property (p_valid_timing_configuration)
        else $error("SVA ERROR: Invalid active display dimensions");


    // --------------------------------------------------------
    // Assertion coverage
    // --------------------------------------------------------
    c_frame_start:
        cover property (
            @(posedge clk)
            disable iff (!rst_n)
            frame_start
        );

    c_active_video:
        cover property (
            @(posedge clk)
            disable iff (!rst_n)
            active_video
        );

    c_display_disabled:
        cover property (
            @(posedge clk)
            disable iff (!rst_n)
            !display_enable
        );

endmodule
