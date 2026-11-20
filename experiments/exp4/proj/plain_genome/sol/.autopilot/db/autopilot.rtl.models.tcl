set SynModuleInfo {
  {SRCNAME fenwick_top MODELNAME fenwick_top RTLNAME fenwick_top IS_TOP 1
    SUBMODULES {
      {MODELNAME tree_RAM_AUTO_1R1W RTLNAME fenwick_top_tree_RAM_AUTO_1R1W BINDTYPE storage TYPE ram IMPL auto LATENCY 2 ALLOW_PRAGMA 1}
      {MODELNAME flow_control_loop_pipe RTLNAME fenwick_top_flow_control_loop_pipe BINDTYPE interface TYPE internal_upc_flow_control INSTNAME fenwick_top_flow_control_loop_pipe_U}
    }
  }
}
