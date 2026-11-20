`timescale 1ns/1ps

package display_uvm_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // ========================================================
    // APB SEQUENCE ITEM
    // ========================================================
    class apb_item extends uvm_sequence_item;

        rand bit write;
        rand bit [7:0] addr;
        rand bit [31:0] data;

        bit [31:0] read_data;
        bit error;

        `uvm_object_utils_begin(apb_item)
            `uvm_field_int(write, UVM_ALL_ON)
            `uvm_field_int(addr, UVM_ALL_ON)
            `uvm_field_int(data, UVM_ALL_ON)
            `uvm_field_int(read_data, UVM_ALL_ON)
            `uvm_field_int(error, UVM_ALL_ON)
        `uvm_object_utils_end

        function new(string name = "apb_item");
            super.new(name);
        endfunction

    endclass


    // ========================================================
    // APB SEQUENCER
    // ========================================================
    class apb_sequencer extends uvm_sequencer #(apb_item);

        `uvm_component_utils(apb_sequencer)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

    endclass


    // ========================================================
    // APB DRIVER
    // ========================================================
    class apb_driver extends uvm_driver #(apb_item);

        `uvm_component_utils(apb_driver)

        virtual apb_if vif;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            if (!uvm_config_db#(virtual apb_if)::get(
                    this, "", "vif", vif))
                `uvm_fatal("APB_DRV", "APB virtual interface not found")
        endfunction

        task run_phase(uvm_phase phase);

            apb_item req;

            vif.psel    = 0;
            vif.penable = 0;
            vif.pwrite  = 0;
            vif.paddr   = 0;
            vif.pwdata  = 0;

            wait (vif.presetn == 1'b1);

            forever begin

                seq_item_port.get_next_item(req);

                // APB SETUP phase
                @(negedge vif.pclk);

                vif.psel    = 1;
                vif.penable = 0;
                vif.pwrite  = req.write;
                vif.paddr   = req.addr;
                vif.pwdata  = req.data;

                // APB ACCESS phase
                @(negedge vif.pclk);
                vif.penable = 1;

                // Wait for transfer completion
                @(posedge vif.pclk);
                while (vif.pready !== 1'b1)
                    @(posedge vif.pclk);

                @(negedge vif.pclk);

                vif.psel    = 0;
                vif.penable = 0;
                vif.pwrite  = 0;
                vif.paddr   = 0;
                vif.pwdata  = 0;

                seq_item_port.item_done();

            end
        endtask

    endclass


    // ========================================================
    // APB MONITOR
    // ========================================================
    class apb_monitor extends uvm_monitor;

        `uvm_component_utils(apb_monitor)

        virtual apb_if vif;

        uvm_analysis_port #(apb_item) analysis_port;

        function new(string name, uvm_component parent);
            super.new(name, parent);
            analysis_port = new("analysis_port", this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            if (!uvm_config_db#(virtual apb_if)::get(
                    this, "", "vif", vif))
                `uvm_fatal("APB_MON", "APB virtual interface not found")
        endfunction

        task run_phase(uvm_phase phase);

            apb_item tr;

            forever begin
                @(posedge vif.pclk);

                if (vif.presetn &&
                    vif.psel &&
                    vif.penable &&
                    vif.pready) begin

                    tr = apb_item::type_id::create("tr");

                    tr.write     = vif.pwrite;
                    tr.addr      = vif.paddr;
                    tr.data      = vif.pwdata;
                    tr.read_data = vif.prdata;
                    tr.error     = vif.pslverr;

                    `uvm_info("APB_MON",
                        $sformatf(
                            "APB %s addr=0x%02h data=0x%08h read=0x%08h error=%0b",
                            tr.write ? "WRITE" : "READ",
                            tr.addr,
                            tr.data,
                            tr.read_data,
                            tr.error
                        ),
                        UVM_MEDIUM
                    )

                    analysis_port.write(tr);
                end
            end

        endtask

    endclass


    // ========================================================
    // APB AGENT
    // ========================================================
    class apb_agent extends uvm_agent;

        `uvm_component_utils(apb_agent)

        apb_sequencer sequencer;
        apb_driver driver;
        apb_monitor monitor;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            sequencer = apb_sequencer::type_id::create(
                "sequencer", this);

            driver = apb_driver::type_id::create(
                "driver", this);

            monitor = apb_monitor::type_id::create(
                "monitor", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);

            driver.seq_item_port.connect(
                sequencer.seq_item_export);
        endfunction

    endclass


    // ========================================================
    // SCOREBOARD
    // ========================================================
    class apb_scoreboard extends uvm_scoreboard;

        `uvm_component_utils(apb_scoreboard)

        uvm_analysis_imp #(apb_item, apb_scoreboard) analysis_export;

        bit [31:0] expected [bit [7:0]];

        int write_count;
        int read_count;
        int error_count;

        function new(string name, uvm_component parent);
            super.new(name, parent);

            analysis_export = new("analysis_export", this);

            write_count = 0;
            read_count  = 0;
            error_count = 0;
        endfunction

        function void write(apb_item tr);

            if (tr.error) begin
                error_count++;
                `uvm_error("APB_SB",
                    $sformatf("APB slave error at address 0x%02h",
                              tr.addr))
                return;
            end

            if (tr.write) begin

                expected[tr.addr] = tr.data;
                write_count++;

                `uvm_info("APB_SB",
                    $sformatf(
                        "WRITE recorded: addr=0x%02h data=0x%08h",
                        tr.addr, tr.data),
                    UVM_MEDIUM
                )

            end
            else begin

                read_count++;

                if (!expected.exists(tr.addr)) begin
                    `uvm_warning("APB_SB",
                        $sformatf(
                            "Read without scoreboard write: addr=0x%02h",
                            tr.addr))
                end
                else if (tr.read_data !== expected[tr.addr]) begin

                    error_count++;

                    `uvm_error("APB_SB",
                        $sformatf(
                            "READ MISMATCH addr=0x%02h expected=0x%08h actual=0x%08h",
                            tr.addr,
                            expected[tr.addr],
                            tr.read_data
                        )
                    )

                end
                else begin

                    `uvm_info("APB_SB",
                        $sformatf(
                            "READ MATCH addr=0x%02h data=0x%08h",
                            tr.addr, tr.read_data),
                        UVM_MEDIUM
                    )

                end
            end

        endfunction

        function void report_phase(uvm_phase phase);
            super.report_phase(phase);

            `uvm_info("APB_SB",
                $sformatf(
                    "SUMMARY writes=%0d reads=%0d errors=%0d",
                    write_count, read_count, error_count),
                UVM_NONE
            )

            if (error_count != 0)
                `uvm_error("APB_SB", "Scoreboard reported errors")
        endfunction

    endclass


    // ========================================================
    // UVM ENVIRONMENT
    // ========================================================
    class display_env extends uvm_env;

        `uvm_component_utils(display_env)

        apb_agent agent;
        apb_scoreboard scoreboard;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            agent = apb_agent::type_id::create("agent", this);

            scoreboard = apb_scoreboard::type_id::create(
                "scoreboard", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);

            agent.monitor.analysis_port.connect(
                scoreboard.analysis_export);
        endfunction

    endclass


    // ========================================================
    // APB CONFIGURATION SEQUENCE
    // ========================================================
    class display_config_sequence extends uvm_sequence #(apb_item);

        `uvm_object_utils(display_config_sequence)

        function new(string name = "display_config_sequence");
            super.new(name);
        endfunction

        task access(
            bit wr,
            bit [7:0] addr,
            bit [31:0] data
        );

            apb_item req;

            req = apb_item::type_id::create("req");

            start_item(req);

            req.write = wr;
            req.addr  = addr;
            req.data  = data;

            finish_item(req);

        endtask

        task body();

            `uvm_info("APB_SEQ",
                "Starting display configuration sequence",
                UVM_LOW)

            // Configure small simulation timing.
            access(1, 8'h04, 32'd4);
            access(1, 8'h08, 32'd1);
            access(1, 8'h0C, 32'd1);
            access(1, 8'h10, 32'd1);

            access(1, 8'h14, 32'd3);
            access(1, 8'h18, 32'd1);
            access(1, 8'h1C, 32'd1);
            access(1, 8'h20, 32'd1);

            // Enable display and select pixel format 2.
            access(1, 8'h00, 32'h0000_0005);

            // Read back programmed registers.
            access(0, 8'h04, 32'd0);
            access(0, 8'h08, 32'd0);
            access(0, 8'h0C, 32'd0);
            access(0, 8'h10, 32'd0);

            access(0, 8'h14, 32'd0);
            access(0, 8'h18, 32'd0);
            access(0, 8'h1C, 32'd0);
            access(0, 8'h20, 32'd0);

            access(0, 8'h00, 32'd0);

            // Disable display.
            access(1, 8'h00, 32'h0000_0004);
            access(0, 8'h00, 32'd0);

            `uvm_info("APB_SEQ",
                "Display configuration sequence completed",
                UVM_LOW)

        endtask

    endclass


    // ========================================================
    // UVM TEST
    // ========================================================
    class display_base_test extends uvm_test;

        `uvm_component_utils(display_base_test)

        display_env env;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            env = display_env::type_id::create("env", this);
        endfunction

        task run_phase(uvm_phase phase);

            display_config_sequence seq;

            phase.raise_objection(this);

            seq = display_config_sequence::type_id::create("seq");

            `uvm_info("DISPLAY_TEST",
                "Starting Phase 5 UVM test",
                UVM_LOW)

            seq.start(env.agent.sequencer);

            repeat (5)
                @(posedge env.agent.driver.vif.pclk);

            `uvm_info("DISPLAY_TEST",
                "PHASE5_UVM_SEQUENCE_COMPLETED",
                UVM_NONE)

            phase.drop_objection(this);

        endtask

    endclass

endpackage
