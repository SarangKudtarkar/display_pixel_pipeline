import uvm_pkg::*;
import display_env_pkg::*;

class display_base_test extends uvm_test;
    `uvm_component_utils(display_base_test)

    display_env env;

    function new(string name = "display_base_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = display_env::type_id::create("env", this);
    endfunction

endclass
