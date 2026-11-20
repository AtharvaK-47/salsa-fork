
# ============================================================
# EXPERIMENT 4: Fenwick Tree HLS Experiments
#
# Variants:
#   0 - plain
#   1 - cyclic16
#   2 - block16
#   3 - cyclic16_depfalse
#
# Workloads:
#   itch
#   genome
#
# Target: xczu7ev-ffvc1156-2-e
# Clock:  3.333 ns
# ============================================================

# Experiment configuration
set variants  {0 1 2 3}
set names     {plain cyclic16 block16 cyclic16_depfalse}
set workloads {itch genome}

# Optional Vivado implementation
set impl [expr {
    [info exists ::env(HLS_IMPL)] && $::env(HLS_IMPL) == 1
}]

# Resolve paths relative to this Tcl script
set here [file normalize [file dirname [info script]]]

set src [file join $here fenwick.cpp]
set hdr [file join $here fenwick.h]
set tb  [file join $here tb.cpp]

# Verify required source files
foreach f [list $src $hdr $tb] {
    if {![file exists $f]} {
        error "Required source file not found: $f"
    }
}

puts "============================================"
puts "EXP 4: FENWICK TREE HLS"
puts "============================================"
puts "Project directory: $here"
puts "Design source:     $src"
puts "Header:            $hdr"
puts "Testbench:         $tb"
puts "Implementation:    $impl"

# ============================================================
# Run all variants and workloads
# ============================================================

foreach v $variants name $names {

    foreach w $workloads {

        set trace [file join $here traces ${w}.bin]

        if {![file exists $trace]} {
            error "Trace file not found: $trace"
        }

        set project_dir [file normalize \
            [file join $here proj ${name}_${w}]]

        puts "\n"
        puts "============================================"
        puts "VARIANT:  $name (VARIANT=$v)"
        puts "WORKLOAD: $w"
        puts "============================================"

        # ----------------------------------------------------
        # Create/reset project
        # ----------------------------------------------------

        open_project -reset $project_dir
        set_top fenwick_top

        # Copy design source and header into project directory
        set local_src [file join $project_dir fenwick.cpp]
        set local_hdr [file join $project_dir fenwick.h]

        file copy -force $src $local_src
        file copy -force $hdr $local_hdr

        # ----------------------------------------------------
        # Register source files from project directory
        # ----------------------------------------------------

        # Change working directory to project directory.
        # This avoids incorrect relative source paths.
        cd $project_dir

        # Design source
        add_files -cflags "-DVARIANT=$v" fenwick.cpp

        # Include design source in C simulation
        add_files -tb -cflags "-DVARIANT=$v" fenwick.cpp

        # Testbench source
        add_files -tb -cflags "-DVARIANT=$v" $tb

        # ----------------------------------------------------
        # Configure solution
        # ----------------------------------------------------

        open_solution -reset sol -flow_target vivado

        set_part xczu7ev-ffvc1156-2-e
        create_clock -period 3.333 -name default

        # ----------------------------------------------------
        # C Simulation
        # ----------------------------------------------------

        puts "\n--- C SIMULATION: $name / $w ---"

        csim_design -argv $trace

        # ----------------------------------------------------
        # C Synthesis
        # ----------------------------------------------------

        puts "\n--- C SYNTHESIS: $name / $w ---"

        csynth_design

        # ----------------------------------------------------
        # C/RTL Co-simulation
        # ----------------------------------------------------

        puts "\n--- CO-SIMULATION: $name / $w ---"

        cosim_design -argv $trace

        # ----------------------------------------------------
        # Optional implementation
        # ----------------------------------------------------

        if {$impl} {
            puts "\n--- IMPLEMENTATION: $name / $w ---"

            export_design -flow impl -rtl verilog
        }

        # ----------------------------------------------------
        # Close project and restore working directory
        # ----------------------------------------------------

        close_project
        cd $here

        puts "\nCOMPLETED: $name / $w"
    }
}

puts "\n"
puts "============================================"
puts "ALL EXPERIMENTS COMPLETED"
puts "============================================"

exit
