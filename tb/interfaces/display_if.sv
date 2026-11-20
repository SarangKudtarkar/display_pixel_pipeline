interface display_if(input logic clk);

    logic hsync;
    logic vsync;
    logic hblank;
    logic vblank;
    logic active_video;
    logic pixel_valid;
    logic [15:0] pixel_x;
    logic [15:0] pixel_y;

    logic clock_enable;
    logic [1:0] power_state;

    clocking mon_cb @(posedge clk);
        input hsync, vsync, hblank, vblank;
        input active_video, pixel_valid;
        input pixel_x, pixel_y;
        input clock_enable, power_state;
    endclocking

endinterface
