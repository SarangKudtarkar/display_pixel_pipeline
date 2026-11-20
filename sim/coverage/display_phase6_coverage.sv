module display_phase6_coverage (
    input logic        pclk,
    input logic        presetn,

    input logic        psel,
    input logic        penable,
    input logic        pwrite,
    input logic [7:0]  paddr,
    input logic        pslverr,

    input logic [1:0]  pixel_format,
    input logic        display_enable,

    input logic        active_video,
    input logic        frame_start
);

    logic apb_access;

    assign apb_access = psel && penable;

    // --------------------------------------------------------
    // APB transaction coverage
    // --------------------------------------------------------

    covergroup apb_cg @(posedge pclk);
        option.per_instance = 1;

        cp_apb_direction: coverpoint pwrite iff (presetn && apb_access) {
            bins read  = {0};
            bins write = {1};
        }

        cp_apb_address: coverpoint paddr iff (presetn && apb_access) {
            bins control = {8'h00};

            bins h_active = {8'h04};
            bins h_front  = {8'h08};
            bins h_sync   = {8'h0C};
            bins h_back   = {8'h10};

            bins v_active = {8'h14};
            bins v_front  = {8'h18};
            bins v_sync   = {8'h1C};
            bins v_back   = {8'h20};

            bins invalid_address = default;
        }

        cp_apb_error: coverpoint pslverr iff (presetn && apb_access) {
            bins no_error = {0};
            bins error    = {1};
        }

        direction_address_cross:
            cross cp_apb_direction, cp_apb_address;
    endgroup

    // --------------------------------------------------------
    // Display configuration coverage
    // --------------------------------------------------------

    covergroup display_config_cg @(posedge pclk);
        option.per_instance = 1;

        cp_display_enable: coverpoint display_enable iff (presetn) {
            bins disabled = {0};
            bins enabled  = {1};
        }

        cp_pixel_format: coverpoint pixel_format iff (presetn) {
            bins format_0 = {0};
            bins format_1 = {1};
            bins format_2 = {2};
            bins format_3 = {3};
        }

        enable_format_cross:
            cross cp_display_enable, cp_pixel_format;
    endgroup

    // --------------------------------------------------------
    // Display activity coverage
    // --------------------------------------------------------

    covergroup display_activity_cg @(posedge pclk);
        option.per_instance = 1;

        cp_active_video: coverpoint active_video iff (presetn) {
            bins inactive = {0};
            bins active   = {1};
        }

        cp_frame_start: coverpoint frame_start iff (presetn) {
            bins no_frame_start = {0};
            bins frame_start_seen = {1};
        }

        active_frame_cross:
            cross cp_active_video, cp_frame_start;
    endgroup

    apb_cg             apb_cov;
    display_config_cg  config_cov;
    display_activity_cg activity_cov;

    initial begin
        apb_cov      = new();
        config_cov   = new();
        activity_cov = new();
    end

endmodule


// Bind the coverage model to the existing subsystem.
// The original RTL hierarchy and port names remain unchanged.

bind display_subsystem_top display_phase6_coverage
    u_display_phase6_coverage (
        .pclk           (pclk),
        .presetn        (presetn),
        .psel           (psel),
        .penable        (penable),
        .pwrite         (pwrite),
        .paddr          (paddr),
        .pslverr        (pslverr),
        .pixel_format   (pixel_format),
        .display_enable (display_enable),
        .active_video   (active_video),
        .frame_start    (frame_start)
    );
