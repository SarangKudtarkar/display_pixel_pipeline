package display_env_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class display_transaction extends uvm_sequence_item;
        rand bit [7:0] addr;
        rand bit [31:0] data;
        rand bit write;

        `uvm_object_utils_begin(display_transaction)
            `uvm_field_int(addr, UVM_ALL_ON)
            `uvm_field_int(data, UVM_ALL_ON)
            `uvm_field_int(write, UVM_ALL_ON)
        `uvm_object_utils_end

        function new(string name = "display_transaction");
            super.new(name);
        endfunction
    endclass

    class display_monitor extends uvm_monitor;
        `uvm_component_utils(display_monitor)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual task run_phase(uvm_phase phase);
            `uvm_info("MONITOR", "Display monitor started", UVM_LOW)
        endtask
    endclass

    class display_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(display_scoreboard)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
    endclass

    class display_env extends uvm_env;
        `uvm_component_utils(display_env)

        display_monitor monitor;
        display_scoreboard scoreboard;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            monitor = display_monitor::type_id::create("monitor", this);
            scoreboard = display_scoreboard::type_id::create("scoreboard", this);
        endfunction
    endclass

endpackage
