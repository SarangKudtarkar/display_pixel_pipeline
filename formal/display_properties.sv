module display_properties (
    input logic pclk,
    input logic presetn,
    input logic display_enable,
    input logic active_video,
    input logic frame_start,
    input logic pready
);

    default clocking cb @(posedge pclk);
    endclocking

    // Display disabled: active video must be low.
    assert_display_disabled:
        assert property (
            disable iff (!presetn)
            !display_enable |-> !active_video
        );

    // APB slave must always be ready.
    assert_apb_ready:
        assert property (pready == 1'b1);

    // Frame start must remain low during reset.
    assert_no_frame_start_during_reset:
        assert property (!presetn |-> !frame_start);

    // Reachability coverage.
    cover_display_enabled:
        cover property (presetn && display_enable);

    cover_active_video:
        cover property (presetn && active_video);

    cover_frame_start:
        cover property (presetn && frame_start);

endmodule
