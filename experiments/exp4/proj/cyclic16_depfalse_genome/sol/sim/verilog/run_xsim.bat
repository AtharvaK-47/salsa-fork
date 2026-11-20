
set PATH=
call C:/AMDDesignTools/2026.1/Vivado/bin/xelab xil_defaultlib.apatb_fenwick_top_top xil_defaultlib.glbl -Oenable_linking_all_libraries -prj fenwick_top.prj -L smartconnect_v1_0 -L axi_protocol_checker_v1_1_12 -L axi_protocol_checker_v1_1_13 -L axis_protocol_checker_v1_1_11 -L axis_protocol_checker_v1_1_12 -L xil_defaultlib -L unisims_ver -L xpm  -L floating_point_v7_1_22 -L floating_point_v7_0_27 --lib "ieee_proposed=./ieee_proposed" -L uvm -relax -i ./svr -i ./axivip -i ./svtb -i ./file_agent -i ./fenwick_top_subsystem  -s fenwick_top 
call C:/AMDDesignTools/2026.1/Vivado/bin/xsim -testplusarg "UVM_VERBOSITY=UVM_NONE" -testplusarg "UVM_TESTNAME=fenwick_top_test_lib" -testplusarg "UVM_TIMEOUT=20000000000000" --noieeewarnings fenwick_top -tclbatch fenwick_top.tcl 

