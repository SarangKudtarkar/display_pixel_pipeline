module display_formal_top;

    (* gclk *) logic pclk;

    (* anyseq *) logic presetn;

    (* anyseq *) logic psel;
    (* anyseq *) logic penable;
    (* anyseq *) logic pwrite;
    (* anyseq *) logic [7:0] paddr;
    (* anyseq *) logic [31:0] pwdata;

    (* anyseq *) logic pixel_wr_en;
    (* anyseq *) logic [23:0] pixel_data;

    logic [31:0] prdata;
    logic pready;
    logic pslverr;

    logic pixel_ready;
    logic [9:0] pixel_x;
    logic [9:0] pixel_y;
    logic [23:0] pixel_out;

    logic hsync;
    logic vsync;
    logic active_video;
    logic frame_start;
    logic display_enable;

    display_subsystem_top #(
        .FIFO_DEPTH(16)
    ) dut (
        .pclk           (pclk),
        .presetn        (presetn),
        .psel           (psel),
        .penable        (penable),
        .pwrite         (pwrite),
        .paddr          (paddr),
        .pwdata         (pwdata),
        .prdata         (prdata),
        .pready         (pready),
        .pslverr        (pslverr),
        .pixel_wr_en    (pixel_wr_en),
        .pixel_data     (pixel_data),
        .pixel_ready    (pixel_ready),
        .pixel_x        (pixel_x),
        .pixel_y        (pixel_y),
        .pixel_out      (pixel_out),
        .hsync          (hsync),
        .vsync          (vsync),
        .active_video   (active_video),
        .frame_start    (frame_start),
        .display_enable (display_enable)
    );

    display_properties u_display_properties (
        .pclk           (pclk),
        .presetn        (presetn),
        .display_enable (display_enable),
        .active_video   (active_video),
        .frame_start    (frame_start),
        .pready         (pready)
    );

endmodule
