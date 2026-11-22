// trace.vh: debug prints are off unless you compile with +define+TRACE (make trace)
`ifndef TRACE_VH
`define TRACE_VH
`ifdef TRACE
  `define TRACE_ON 1'b1
`else
  `define TRACE_ON 1'b0
`endif
`endif
