package display_pkg;

    typedef enum logic [1:0] {
        RGB565 = 2'b00,
        RGB888 = 2'b01,
        ARGB8888 = 2'b10
    } pixel_format_t;

    typedef enum logic [1:0] {
        PM_ACTIVE = 2'b00,
        PM_IDLE   = 2'b01,
        PM_GATED  = 2'b10,
        PM_WAKE   = 2'b11
    } power_state_t;

    parameter int DATA_WIDTH = 24;
    parameter int FIFO_DEPTH = 16;

endpackage
