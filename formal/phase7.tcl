clear -all

puts "=============================================="
puts "PHASE 7 FORMAL VERIFICATION"
puts "=============================================="

analyze -sv {
    rtl/bus/apb_regs.sv
    rtl/display/vga_timing_gen.sv
    rtl/display/pixel_fifo.sv
    rtl/display/color_converter.sv
    rtl/display/display_top.sv
    rtl/top/display_subsystem_top.sv
    formal/display_properties.sv
    formal/display_formal_top.sv
}

# Explicitly select the formal top.
elaborate -top display_formal_top

clock pclk
reset -expression {!presetn}

puts "Starting formal proofs..."
prove -all

puts "Starting cover analysis..."
cover -all

report -summary -force -result \
    -file logs/phase7_formal_report.txt

puts "PHASE 7 ANALYSIS FINISHED"

exit
