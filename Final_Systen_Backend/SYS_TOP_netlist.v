/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : O-2018.06-SP1
// Date      : Sun Oct 11 01:43:02 2026
/////////////////////////////////////////////////////////////


module RST_Sync_0 ( RST, CLK, SYNC_RST );
  input RST, CLK;
  output SYNC_RST;
  wire   sync_reg_0_;

  DFFRQX2M sync_reg_reg_1_ ( .D(sync_reg_0_), .CK(CLK), .RN(RST), .Q(SYNC_RST)
         );
  DFFRQX2M sync_reg_reg_0_ ( .D(1'b1), .CK(CLK), .RN(RST), .Q(sync_reg_0_) );
endmodule


module RST_Sync_1 ( RST, CLK, SYNC_RST );
  input RST, CLK;
  output SYNC_RST;
  wire   sync_reg_0_;

  DFFRQX2M sync_reg_reg_1_ ( .D(sync_reg_0_), .CK(CLK), .RN(RST), .Q(SYNC_RST)
         );
  DFFRQX2M sync_reg_reg_0_ ( .D(1'b1), .CK(CLK), .RN(RST), .Q(sync_reg_0_) );
endmodule


module Multi_FF ( CLK, RST, async_data, sync_data );
  input CLK, RST, async_data;
  output sync_data;
  wire   sync_reg_0_;

  DFFRQX2M sync_reg_reg_1_ ( .D(sync_reg_0_), .CK(CLK), .RN(RST), .Q(sync_data) );
  DFFRQX2M sync_reg_reg_0_ ( .D(async_data), .CK(CLK), .RN(RST), .Q(
        sync_reg_0_) );
endmodule


module Pulse_Gen_Pos ( CLK, RST, lvl_sig, pulse_sig );
  input CLK, RST, lvl_sig;
  output pulse_sig;
  wire   rcv_sig;

  DFFRQX2M rcv_sig_reg ( .D(lvl_sig), .CK(CLK), .RN(RST), .Q(rcv_sig) );
  NOR2BX2M U3 ( .AN(lvl_sig), .B(rcv_sig), .Y(pulse_sig) );
endmodule


module FF ( CLK, RST, IN_FF, OUT );
  input CLK, RST, IN_FF;
  output OUT;


  DFFRQX2M OUT_reg ( .D(IN_FF), .CK(CLK), .RN(RST), .Q(OUT) );
endmodule


module MUX_21_REG ( CLK, RST, MUX_IN, sel, REG_OUT );
  input [7:0] MUX_IN;
  output [7:0] REG_OUT;
  input CLK, RST, sel;
  wire   n2, n3, n4, n5, n6, n7, n8, n9, n1;

  DFFRQX2M REG_OUT_reg_7_ ( .D(n9), .CK(CLK), .RN(RST), .Q(REG_OUT[7]) );
  DFFRQX2M REG_OUT_reg_5_ ( .D(n7), .CK(CLK), .RN(RST), .Q(REG_OUT[5]) );
  DFFRQX2M REG_OUT_reg_4_ ( .D(n6), .CK(CLK), .RN(RST), .Q(REG_OUT[4]) );
  DFFRQX2M REG_OUT_reg_6_ ( .D(n8), .CK(CLK), .RN(RST), .Q(REG_OUT[6]) );
  DFFRQX2M REG_OUT_reg_3_ ( .D(n5), .CK(CLK), .RN(RST), .Q(REG_OUT[3]) );
  DFFRQX2M REG_OUT_reg_2_ ( .D(n4), .CK(CLK), .RN(RST), .Q(REG_OUT[2]) );
  DFFRQX2M REG_OUT_reg_0_ ( .D(n2), .CK(CLK), .RN(RST), .Q(REG_OUT[0]) );
  DFFRQX2M REG_OUT_reg_1_ ( .D(n3), .CK(CLK), .RN(RST), .Q(REG_OUT[1]) );
  INVX2M U2 ( .A(sel), .Y(n1) );
  AO22X1M U3 ( .A0(REG_OUT[0]), .A1(n1), .B0(sel), .B1(MUX_IN[0]), .Y(n2) );
  AO22X1M U4 ( .A0(REG_OUT[1]), .A1(n1), .B0(MUX_IN[1]), .B1(sel), .Y(n3) );
  AO22X1M U5 ( .A0(REG_OUT[2]), .A1(n1), .B0(MUX_IN[2]), .B1(sel), .Y(n4) );
  AO22X1M U6 ( .A0(REG_OUT[3]), .A1(n1), .B0(MUX_IN[3]), .B1(sel), .Y(n5) );
  AO22X1M U7 ( .A0(REG_OUT[4]), .A1(n1), .B0(MUX_IN[4]), .B1(sel), .Y(n6) );
  AO22X1M U8 ( .A0(REG_OUT[5]), .A1(n1), .B0(MUX_IN[5]), .B1(sel), .Y(n7) );
  AO22X1M U9 ( .A0(REG_OUT[6]), .A1(n1), .B0(MUX_IN[6]), .B1(sel), .Y(n8) );
  AO22X1M U10 ( .A0(REG_OUT[7]), .A1(n1), .B0(MUX_IN[7]), .B1(sel), .Y(n9) );
endmodule


module Data_Sync ( CLK, RST, unsync_bus, bus_enable, enable_pulse, sync_bus );
  input [7:0] unsync_bus;
  output [7:0] sync_bus;
  input CLK, RST, bus_enable;
  output enable_pulse;
  wire   MFF_OUT, pulse_sig;

  Multi_FF u_Multi_FF ( .CLK(CLK), .RST(RST), .async_data(bus_enable), 
        .sync_data(MFF_OUT) );
  Pulse_Gen_Pos u_Pulse_Gen ( .CLK(CLK), .RST(RST), .lvl_sig(MFF_OUT), 
        .pulse_sig(pulse_sig) );
  FF u_FF ( .CLK(CLK), .RST(RST), .IN_FF(pulse_sig), .OUT(enable_pulse) );
  MUX_21_REG u_MUX_21_REG ( .CLK(CLK), .RST(RST), .MUX_IN(unsync_bus), .sel(
        pulse_sig), .REG_OUT(sync_bus) );
endmodule


module FIFO_MEM_CNTRL ( W_CLK, W_CLKEN, waddr, raddr, wdata, rdata );
  input [2:0] waddr;
  input [2:0] raddr;
  input [7:0] wdata;
  output [7:0] rdata;
  input W_CLK, W_CLKEN;
  wire   n11, n12, n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23, n24,
         n25, n26, n27, n28, n29, n30, n31, n32, n33, n34, n35, n36, n37, n38,
         n39, n40, n41, n42, n43, n44, n45, n46, n47, n48, n49, n50, n51, n52,
         n53, n54, n55, n56, n57, n58, n59, n60, n61, n62, n63, n64, n65, n66,
         n67, n68, n69, n70, n71, n72, n73, n74, n75, n76, n77, n78, n79, n80,
         n81, n82, n83, n84, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n85, n86,
         n87, n88, n89, n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100,
         n101, n102, n103, n104, n105, n106, n107, n108, n109, n110, n111,
         n112, n113, n114, n115, n116, n117, n118, n119, n120, n121, n122,
         n123, n124, n125, n126, n127;
  wire   [63:0] mem;

  DFFQX2M mem_reg_0__7_ ( .D(n84), .CK(W_CLK), .Q(mem[63]) );
  DFFQX2M mem_reg_0__6_ ( .D(n83), .CK(W_CLK), .Q(mem[62]) );
  DFFQX2M mem_reg_0__5_ ( .D(n82), .CK(W_CLK), .Q(mem[61]) );
  DFFQX2M mem_reg_0__4_ ( .D(n81), .CK(W_CLK), .Q(mem[60]) );
  DFFQX2M mem_reg_0__3_ ( .D(n80), .CK(W_CLK), .Q(mem[59]) );
  DFFQX2M mem_reg_0__2_ ( .D(n79), .CK(W_CLK), .Q(mem[58]) );
  DFFQX2M mem_reg_0__1_ ( .D(n78), .CK(W_CLK), .Q(mem[57]) );
  DFFQX2M mem_reg_0__0_ ( .D(n77), .CK(W_CLK), .Q(mem[56]) );
  DFFQX2M mem_reg_1__7_ ( .D(n76), .CK(W_CLK), .Q(mem[55]) );
  DFFQX2M mem_reg_1__6_ ( .D(n75), .CK(W_CLK), .Q(mem[54]) );
  DFFQX2M mem_reg_1__5_ ( .D(n74), .CK(W_CLK), .Q(mem[53]) );
  DFFQX2M mem_reg_1__4_ ( .D(n73), .CK(W_CLK), .Q(mem[52]) );
  DFFQX2M mem_reg_1__3_ ( .D(n72), .CK(W_CLK), .Q(mem[51]) );
  DFFQX2M mem_reg_1__2_ ( .D(n71), .CK(W_CLK), .Q(mem[50]) );
  DFFQX2M mem_reg_1__1_ ( .D(n70), .CK(W_CLK), .Q(mem[49]) );
  DFFQX2M mem_reg_1__0_ ( .D(n69), .CK(W_CLK), .Q(mem[48]) );
  DFFQX2M mem_reg_4__7_ ( .D(n52), .CK(W_CLK), .Q(mem[31]) );
  DFFQX2M mem_reg_4__6_ ( .D(n51), .CK(W_CLK), .Q(mem[30]) );
  DFFQX2M mem_reg_4__5_ ( .D(n50), .CK(W_CLK), .Q(mem[29]) );
  DFFQX2M mem_reg_4__4_ ( .D(n49), .CK(W_CLK), .Q(mem[28]) );
  DFFQX2M mem_reg_4__3_ ( .D(n48), .CK(W_CLK), .Q(mem[27]) );
  DFFQX2M mem_reg_4__2_ ( .D(n47), .CK(W_CLK), .Q(mem[26]) );
  DFFQX2M mem_reg_4__1_ ( .D(n46), .CK(W_CLK), .Q(mem[25]) );
  DFFQX2M mem_reg_4__0_ ( .D(n45), .CK(W_CLK), .Q(mem[24]) );
  DFFQX2M mem_reg_5__7_ ( .D(n44), .CK(W_CLK), .Q(mem[23]) );
  DFFQX2M mem_reg_5__6_ ( .D(n43), .CK(W_CLK), .Q(mem[22]) );
  DFFQX2M mem_reg_5__5_ ( .D(n42), .CK(W_CLK), .Q(mem[21]) );
  DFFQX2M mem_reg_5__4_ ( .D(n41), .CK(W_CLK), .Q(mem[20]) );
  DFFQX2M mem_reg_5__3_ ( .D(n40), .CK(W_CLK), .Q(mem[19]) );
  DFFQX2M mem_reg_5__2_ ( .D(n39), .CK(W_CLK), .Q(mem[18]) );
  DFFQX2M mem_reg_5__1_ ( .D(n38), .CK(W_CLK), .Q(mem[17]) );
  DFFQX2M mem_reg_5__0_ ( .D(n37), .CK(W_CLK), .Q(mem[16]) );
  DFFQX2M mem_reg_6__7_ ( .D(n36), .CK(W_CLK), .Q(mem[15]) );
  DFFQX2M mem_reg_6__6_ ( .D(n35), .CK(W_CLK), .Q(mem[14]) );
  DFFQX2M mem_reg_6__5_ ( .D(n34), .CK(W_CLK), .Q(mem[13]) );
  DFFQX2M mem_reg_6__4_ ( .D(n33), .CK(W_CLK), .Q(mem[12]) );
  DFFQX2M mem_reg_6__3_ ( .D(n32), .CK(W_CLK), .Q(mem[11]) );
  DFFQX2M mem_reg_6__2_ ( .D(n31), .CK(W_CLK), .Q(mem[10]) );
  DFFQX2M mem_reg_6__1_ ( .D(n30), .CK(W_CLK), .Q(mem[9]) );
  DFFQX2M mem_reg_6__0_ ( .D(n29), .CK(W_CLK), .Q(mem[8]) );
  DFFQX2M mem_reg_7__7_ ( .D(n28), .CK(W_CLK), .Q(mem[7]) );
  DFFQX2M mem_reg_7__6_ ( .D(n27), .CK(W_CLK), .Q(mem[6]) );
  DFFQX2M mem_reg_7__5_ ( .D(n26), .CK(W_CLK), .Q(mem[5]) );
  DFFQX2M mem_reg_7__4_ ( .D(n25), .CK(W_CLK), .Q(mem[4]) );
  DFFQX2M mem_reg_7__3_ ( .D(n24), .CK(W_CLK), .Q(mem[3]) );
  DFFQX2M mem_reg_7__2_ ( .D(n23), .CK(W_CLK), .Q(mem[2]) );
  DFFQX2M mem_reg_7__1_ ( .D(n22), .CK(W_CLK), .Q(mem[1]) );
  DFFQX2M mem_reg_7__0_ ( .D(n21), .CK(W_CLK), .Q(mem[0]) );
  DFFQX2M mem_reg_2__7_ ( .D(n68), .CK(W_CLK), .Q(mem[47]) );
  DFFQX2M mem_reg_2__6_ ( .D(n67), .CK(W_CLK), .Q(mem[46]) );
  DFFQX2M mem_reg_2__5_ ( .D(n66), .CK(W_CLK), .Q(mem[45]) );
  DFFQX2M mem_reg_2__4_ ( .D(n65), .CK(W_CLK), .Q(mem[44]) );
  DFFQX2M mem_reg_2__3_ ( .D(n64), .CK(W_CLK), .Q(mem[43]) );
  DFFQX2M mem_reg_2__2_ ( .D(n63), .CK(W_CLK), .Q(mem[42]) );
  DFFQX2M mem_reg_2__1_ ( .D(n62), .CK(W_CLK), .Q(mem[41]) );
  DFFQX2M mem_reg_2__0_ ( .D(n61), .CK(W_CLK), .Q(mem[40]) );
  DFFQX2M mem_reg_3__7_ ( .D(n60), .CK(W_CLK), .Q(mem[39]) );
  DFFQX2M mem_reg_3__6_ ( .D(n59), .CK(W_CLK), .Q(mem[38]) );
  DFFQX2M mem_reg_3__5_ ( .D(n58), .CK(W_CLK), .Q(mem[37]) );
  DFFQX2M mem_reg_3__4_ ( .D(n57), .CK(W_CLK), .Q(mem[36]) );
  DFFQX2M mem_reg_3__3_ ( .D(n56), .CK(W_CLK), .Q(mem[35]) );
  DFFQX2M mem_reg_3__2_ ( .D(n55), .CK(W_CLK), .Q(mem[34]) );
  DFFQX2M mem_reg_3__1_ ( .D(n54), .CK(W_CLK), .Q(mem[33]) );
  DFFQX2M mem_reg_3__0_ ( .D(n53), .CK(W_CLK), .Q(mem[32]) );
  BUFX2M U2 ( .A(n16), .Y(n116) );
  BUFX2M U3 ( .A(n18), .Y(n115) );
  BUFX2M U4 ( .A(n19), .Y(n114) );
  BUFX2M U5 ( .A(n13), .Y(n117) );
  NAND3X2M U6 ( .A(n118), .B(n119), .C(n12), .Y(n15) );
  NAND3X2M U7 ( .A(n118), .B(n119), .C(n17), .Y(n20) );
  NOR2X2M U8 ( .A(n111), .B(n112), .Y(n107) );
  NAND3X2M U9 ( .A(n12), .B(n119), .C(waddr[0]), .Y(n14) );
  NAND3X2M U10 ( .A(waddr[0]), .B(n12), .C(waddr[1]), .Y(n11) );
  NOR2BX2M U11 ( .AN(W_CLKEN), .B(waddr[2]), .Y(n17) );
  INVX2M U12 ( .A(wdata[0]), .Y(n120) );
  INVX2M U13 ( .A(wdata[1]), .Y(n121) );
  INVX2M U14 ( .A(wdata[2]), .Y(n122) );
  INVX2M U15 ( .A(wdata[3]), .Y(n123) );
  INVX2M U16 ( .A(wdata[4]), .Y(n124) );
  INVX2M U17 ( .A(wdata[5]), .Y(n125) );
  INVX2M U18 ( .A(wdata[6]), .Y(n126) );
  INVX2M U19 ( .A(wdata[7]), .Y(n127) );
  OAI2BB2X1M U20 ( .B0(n11), .B1(n120), .A0N(mem[0]), .A1N(n11), .Y(n21) );
  OAI2BB2X1M U21 ( .B0(n11), .B1(n121), .A0N(mem[1]), .A1N(n11), .Y(n22) );
  OAI2BB2X1M U22 ( .B0(n11), .B1(n122), .A0N(mem[2]), .A1N(n11), .Y(n23) );
  OAI2BB2X1M U23 ( .B0(n11), .B1(n123), .A0N(mem[3]), .A1N(n11), .Y(n24) );
  OAI2BB2X1M U24 ( .B0(n11), .B1(n124), .A0N(mem[4]), .A1N(n11), .Y(n25) );
  OAI2BB2X1M U25 ( .B0(n11), .B1(n125), .A0N(mem[5]), .A1N(n11), .Y(n26) );
  OAI2BB2X1M U26 ( .B0(n11), .B1(n126), .A0N(mem[6]), .A1N(n11), .Y(n27) );
  OAI2BB2X1M U27 ( .B0(n11), .B1(n127), .A0N(mem[7]), .A1N(n11), .Y(n28) );
  OAI2BB2X1M U28 ( .B0(n120), .B1(n14), .A0N(mem[16]), .A1N(n14), .Y(n37) );
  OAI2BB2X1M U29 ( .B0(n121), .B1(n14), .A0N(mem[17]), .A1N(n14), .Y(n38) );
  OAI2BB2X1M U30 ( .B0(n122), .B1(n14), .A0N(mem[18]), .A1N(n14), .Y(n39) );
  OAI2BB2X1M U31 ( .B0(n123), .B1(n14), .A0N(mem[19]), .A1N(n14), .Y(n40) );
  OAI2BB2X1M U32 ( .B0(n124), .B1(n14), .A0N(mem[20]), .A1N(n14), .Y(n41) );
  OAI2BB2X1M U33 ( .B0(n125), .B1(n14), .A0N(mem[21]), .A1N(n14), .Y(n42) );
  OAI2BB2X1M U34 ( .B0(n126), .B1(n14), .A0N(mem[22]), .A1N(n14), .Y(n43) );
  OAI2BB2X1M U35 ( .B0(n127), .B1(n14), .A0N(mem[23]), .A1N(n14), .Y(n44) );
  OAI2BB2X1M U36 ( .B0(n120), .B1(n20), .A0N(mem[56]), .A1N(n20), .Y(n77) );
  OAI2BB2X1M U37 ( .B0(n121), .B1(n20), .A0N(mem[57]), .A1N(n20), .Y(n78) );
  OAI2BB2X1M U38 ( .B0(n122), .B1(n20), .A0N(mem[58]), .A1N(n20), .Y(n79) );
  OAI2BB2X1M U39 ( .B0(n123), .B1(n20), .A0N(mem[59]), .A1N(n20), .Y(n80) );
  OAI2BB2X1M U40 ( .B0(n124), .B1(n20), .A0N(mem[60]), .A1N(n20), .Y(n81) );
  OAI2BB2X1M U41 ( .B0(n125), .B1(n20), .A0N(mem[61]), .A1N(n20), .Y(n82) );
  OAI2BB2X1M U42 ( .B0(n126), .B1(n20), .A0N(mem[62]), .A1N(n20), .Y(n83) );
  OAI2BB2X1M U43 ( .B0(n127), .B1(n20), .A0N(mem[63]), .A1N(n20), .Y(n84) );
  OAI2BB2X1M U44 ( .B0(n120), .B1(n15), .A0N(mem[24]), .A1N(n15), .Y(n45) );
  OAI2BB2X1M U45 ( .B0(n121), .B1(n15), .A0N(mem[25]), .A1N(n15), .Y(n46) );
  OAI2BB2X1M U46 ( .B0(n122), .B1(n15), .A0N(mem[26]), .A1N(n15), .Y(n47) );
  OAI2BB2X1M U47 ( .B0(n123), .B1(n15), .A0N(mem[27]), .A1N(n15), .Y(n48) );
  OAI2BB2X1M U48 ( .B0(n124), .B1(n15), .A0N(mem[28]), .A1N(n15), .Y(n49) );
  OAI2BB2X1M U49 ( .B0(n125), .B1(n15), .A0N(mem[29]), .A1N(n15), .Y(n50) );
  OAI2BB2X1M U50 ( .B0(n126), .B1(n15), .A0N(mem[30]), .A1N(n15), .Y(n51) );
  OAI2BB2X1M U51 ( .B0(n127), .B1(n15), .A0N(mem[31]), .A1N(n15), .Y(n52) );
  OAI2BB2X1M U52 ( .B0(n120), .B1(n117), .A0N(mem[8]), .A1N(n117), .Y(n29) );
  OAI2BB2X1M U53 ( .B0(n121), .B1(n117), .A0N(mem[9]), .A1N(n117), .Y(n30) );
  OAI2BB2X1M U54 ( .B0(n122), .B1(n117), .A0N(mem[10]), .A1N(n117), .Y(n31) );
  OAI2BB2X1M U55 ( .B0(n123), .B1(n117), .A0N(mem[11]), .A1N(n117), .Y(n32) );
  OAI2BB2X1M U56 ( .B0(n124), .B1(n117), .A0N(mem[12]), .A1N(n117), .Y(n33) );
  OAI2BB2X1M U57 ( .B0(n125), .B1(n117), .A0N(mem[13]), .A1N(n117), .Y(n34) );
  OAI2BB2X1M U58 ( .B0(n126), .B1(n117), .A0N(mem[14]), .A1N(n117), .Y(n35) );
  OAI2BB2X1M U59 ( .B0(n127), .B1(n117), .A0N(mem[15]), .A1N(n117), .Y(n36) );
  OAI2BB2X1M U60 ( .B0(n120), .B1(n116), .A0N(mem[32]), .A1N(n116), .Y(n53) );
  OAI2BB2X1M U61 ( .B0(n121), .B1(n116), .A0N(mem[33]), .A1N(n116), .Y(n54) );
  OAI2BB2X1M U62 ( .B0(n122), .B1(n116), .A0N(mem[34]), .A1N(n116), .Y(n55) );
  OAI2BB2X1M U63 ( .B0(n123), .B1(n116), .A0N(mem[35]), .A1N(n116), .Y(n56) );
  OAI2BB2X1M U64 ( .B0(n124), .B1(n116), .A0N(mem[36]), .A1N(n116), .Y(n57) );
  OAI2BB2X1M U65 ( .B0(n125), .B1(n116), .A0N(mem[37]), .A1N(n116), .Y(n58) );
  OAI2BB2X1M U66 ( .B0(n126), .B1(n116), .A0N(mem[38]), .A1N(n116), .Y(n59) );
  OAI2BB2X1M U67 ( .B0(n127), .B1(n116), .A0N(mem[39]), .A1N(n116), .Y(n60) );
  OAI2BB2X1M U68 ( .B0(n120), .B1(n115), .A0N(mem[40]), .A1N(n115), .Y(n61) );
  OAI2BB2X1M U69 ( .B0(n121), .B1(n115), .A0N(mem[41]), .A1N(n115), .Y(n62) );
  OAI2BB2X1M U70 ( .B0(n122), .B1(n115), .A0N(mem[42]), .A1N(n115), .Y(n63) );
  OAI2BB2X1M U71 ( .B0(n123), .B1(n115), .A0N(mem[43]), .A1N(n115), .Y(n64) );
  OAI2BB2X1M U72 ( .B0(n124), .B1(n115), .A0N(mem[44]), .A1N(n115), .Y(n65) );
  OAI2BB2X1M U73 ( .B0(n125), .B1(n115), .A0N(mem[45]), .A1N(n115), .Y(n66) );
  OAI2BB2X1M U74 ( .B0(n126), .B1(n115), .A0N(mem[46]), .A1N(n115), .Y(n67) );
  OAI2BB2X1M U75 ( .B0(n127), .B1(n115), .A0N(mem[47]), .A1N(n115), .Y(n68) );
  OAI2BB2X1M U76 ( .B0(n120), .B1(n114), .A0N(mem[48]), .A1N(n114), .Y(n69) );
  OAI2BB2X1M U77 ( .B0(n121), .B1(n114), .A0N(mem[49]), .A1N(n114), .Y(n70) );
  OAI2BB2X1M U78 ( .B0(n122), .B1(n114), .A0N(mem[50]), .A1N(n114), .Y(n71) );
  OAI2BB2X1M U79 ( .B0(n123), .B1(n114), .A0N(mem[51]), .A1N(n114), .Y(n72) );
  OAI2BB2X1M U80 ( .B0(n124), .B1(n114), .A0N(mem[52]), .A1N(n114), .Y(n73) );
  OAI2BB2X1M U81 ( .B0(n125), .B1(n114), .A0N(mem[53]), .A1N(n114), .Y(n74) );
  OAI2BB2X1M U82 ( .B0(n126), .B1(n114), .A0N(mem[54]), .A1N(n114), .Y(n75) );
  OAI2BB2X1M U83 ( .B0(n127), .B1(n114), .A0N(mem[55]), .A1N(n114), .Y(n76) );
  AND2X2M U84 ( .A(waddr[2]), .B(W_CLKEN), .Y(n12) );
  NAND3X2M U85 ( .A(n12), .B(n118), .C(waddr[1]), .Y(n13) );
  NAND3X2M U86 ( .A(waddr[1]), .B(waddr[0]), .C(n17), .Y(n16) );
  NAND3X2M U87 ( .A(waddr[1]), .B(n118), .C(n17), .Y(n18) );
  NAND3X2M U88 ( .A(waddr[0]), .B(n119), .C(n17), .Y(n19) );
  INVX2M U89 ( .A(waddr[1]), .Y(n119) );
  INVX2M U90 ( .A(waddr[0]), .Y(n118) );
  NOR2X2M U91 ( .A(n111), .B(raddr[1]), .Y(n108) );
  NOR2X2M U92 ( .A(n112), .B(raddr[2]), .Y(n105) );
  NOR2X2M U93 ( .A(raddr[1]), .B(raddr[2]), .Y(n104) );
  INVX2M U94 ( .A(raddr[1]), .Y(n112) );
  INVX2M U95 ( .A(raddr[2]), .Y(n111) );
  INVX2M U96 ( .A(raddr[0]), .Y(n113) );
  AO22X1M U97 ( .A0(mem[32]), .A1(n105), .B0(mem[48]), .B1(n104), .Y(n1) );
  AOI221XLM U98 ( .A0(mem[16]), .A1(n108), .B0(mem[0]), .B1(n107), .C0(n1), 
        .Y(n4) );
  AO22X1M U99 ( .A0(mem[40]), .A1(n105), .B0(mem[56]), .B1(n104), .Y(n2) );
  AOI221XLM U100 ( .A0(mem[24]), .A1(n108), .B0(mem[8]), .B1(n107), .C0(n2), 
        .Y(n3) );
  OAI22X1M U101 ( .A0(n113), .A1(n4), .B0(raddr[0]), .B1(n3), .Y(rdata[0]) );
  AO22X1M U102 ( .A0(mem[33]), .A1(n105), .B0(mem[49]), .B1(n104), .Y(n5) );
  AOI221XLM U103 ( .A0(mem[17]), .A1(n108), .B0(mem[1]), .B1(n107), .C0(n5), 
        .Y(n8) );
  AO22X1M U104 ( .A0(mem[41]), .A1(n105), .B0(mem[57]), .B1(n104), .Y(n6) );
  AOI221XLM U105 ( .A0(mem[25]), .A1(n108), .B0(mem[9]), .B1(n107), .C0(n6), 
        .Y(n7) );
  OAI22X1M U106 ( .A0(n113), .A1(n8), .B0(raddr[0]), .B1(n7), .Y(rdata[1]) );
  AO22X1M U107 ( .A0(mem[34]), .A1(n105), .B0(mem[50]), .B1(n104), .Y(n9) );
  AOI221XLM U108 ( .A0(mem[18]), .A1(n108), .B0(mem[2]), .B1(n107), .C0(n9), 
        .Y(n86) );
  AO22X1M U109 ( .A0(mem[42]), .A1(n105), .B0(mem[58]), .B1(n104), .Y(n10) );
  AOI221XLM U110 ( .A0(mem[26]), .A1(n108), .B0(mem[10]), .B1(n107), .C0(n10), 
        .Y(n85) );
  OAI22X1M U111 ( .A0(n113), .A1(n86), .B0(raddr[0]), .B1(n85), .Y(rdata[2])
         );
  AO22X1M U112 ( .A0(mem[35]), .A1(n105), .B0(mem[51]), .B1(n104), .Y(n87) );
  AOI221XLM U113 ( .A0(mem[19]), .A1(n108), .B0(mem[3]), .B1(n107), .C0(n87), 
        .Y(n90) );
  AO22X1M U114 ( .A0(mem[43]), .A1(n105), .B0(mem[59]), .B1(n104), .Y(n88) );
  AOI221XLM U115 ( .A0(mem[27]), .A1(n108), .B0(mem[11]), .B1(n107), .C0(n88), 
        .Y(n89) );
  OAI22X1M U116 ( .A0(n113), .A1(n90), .B0(raddr[0]), .B1(n89), .Y(rdata[3])
         );
  AO22X1M U117 ( .A0(mem[36]), .A1(n105), .B0(mem[52]), .B1(n104), .Y(n91) );
  AOI221XLM U118 ( .A0(mem[20]), .A1(n108), .B0(mem[4]), .B1(n107), .C0(n91), 
        .Y(n94) );
  AO22X1M U119 ( .A0(mem[44]), .A1(n105), .B0(mem[60]), .B1(n104), .Y(n92) );
  AOI221XLM U120 ( .A0(mem[28]), .A1(n108), .B0(mem[12]), .B1(n107), .C0(n92), 
        .Y(n93) );
  OAI22X1M U121 ( .A0(n113), .A1(n94), .B0(raddr[0]), .B1(n93), .Y(rdata[4])
         );
  AO22X1M U122 ( .A0(mem[37]), .A1(n105), .B0(mem[53]), .B1(n104), .Y(n95) );
  AOI221XLM U123 ( .A0(mem[21]), .A1(n108), .B0(mem[5]), .B1(n107), .C0(n95), 
        .Y(n98) );
  AO22X1M U124 ( .A0(mem[45]), .A1(n105), .B0(mem[61]), .B1(n104), .Y(n96) );
  AOI221XLM U125 ( .A0(mem[29]), .A1(n108), .B0(mem[13]), .B1(n107), .C0(n96), 
        .Y(n97) );
  OAI22X1M U126 ( .A0(n113), .A1(n98), .B0(raddr[0]), .B1(n97), .Y(rdata[5])
         );
  AO22X1M U127 ( .A0(mem[38]), .A1(n105), .B0(mem[54]), .B1(n104), .Y(n99) );
  AOI221XLM U128 ( .A0(mem[22]), .A1(n108), .B0(mem[6]), .B1(n107), .C0(n99), 
        .Y(n102) );
  AO22X1M U129 ( .A0(mem[46]), .A1(n105), .B0(mem[62]), .B1(n104), .Y(n100) );
  AOI221XLM U130 ( .A0(mem[30]), .A1(n108), .B0(mem[14]), .B1(n107), .C0(n100), 
        .Y(n101) );
  OAI22X1M U131 ( .A0(n113), .A1(n102), .B0(raddr[0]), .B1(n101), .Y(rdata[6])
         );
  AO22X1M U132 ( .A0(mem[39]), .A1(n105), .B0(mem[55]), .B1(n104), .Y(n103) );
  AOI221XLM U133 ( .A0(mem[23]), .A1(n108), .B0(mem[7]), .B1(n107), .C0(n103), 
        .Y(n110) );
  AO22X1M U134 ( .A0(mem[47]), .A1(n105), .B0(mem[63]), .B1(n104), .Y(n106) );
  AOI221XLM U135 ( .A0(mem[31]), .A1(n108), .B0(mem[15]), .B1(n107), .C0(n106), 
        .Y(n109) );
  OAI22X1M U136 ( .A0(n110), .A1(n113), .B0(raddr[0]), .B1(n109), .Y(rdata[7])
         );
endmodule


module FIFO_WR ( W_CLK, W_RST, W_INC, wq2_rptr, waddr, wptr, wfull );
  input [3:0] wq2_rptr;
  output [2:0] waddr;
  output [3:0] wptr;
  input W_CLK, W_RST, W_INC;
  output wfull;
  wire   wbin_3_, wfull_val, n1, n2, n3, n4, n5, n6, n7, n8;
  wire   [3:0] wbin_next;
  wire   [2:0] wgray_next;

  DFFRQX2M wbin_reg_3_ ( .D(wbin_next[3]), .CK(W_CLK), .RN(W_RST), .Q(wbin_3_)
         );
  DFFRQX2M wbin_reg_2_ ( .D(wbin_next[2]), .CK(W_CLK), .RN(W_RST), .Q(waddr[2]) );
  DFFRQX2M wbin_reg_1_ ( .D(wbin_next[1]), .CK(W_CLK), .RN(W_RST), .Q(waddr[1]) );
  DFFRQX2M wfull_reg ( .D(wfull_val), .CK(W_CLK), .RN(W_RST), .Q(wfull) );
  DFFRQX2M wbin_reg_0_ ( .D(wbin_next[0]), .CK(W_CLK), .RN(W_RST), .Q(waddr[0]) );
  DFFRQX2M wptr_reg_3_ ( .D(wbin_next[3]), .CK(W_CLK), .RN(W_RST), .Q(wptr[3])
         );
  DFFRQX2M wptr_reg_0_ ( .D(wgray_next[0]), .CK(W_CLK), .RN(W_RST), .Q(wptr[0]) );
  DFFRQX2M wptr_reg_2_ ( .D(wgray_next[2]), .CK(W_CLK), .RN(W_RST), .Q(wptr[2]) );
  DFFRQX2M wptr_reg_1_ ( .D(wgray_next[1]), .CK(W_CLK), .RN(W_RST), .Q(wptr[1]) );
  CLKXOR2X2M U3 ( .A(wbin_next[2]), .B(wbin_next[1]), .Y(wgray_next[1]) );
  CLKXOR2X2M U4 ( .A(wbin_next[1]), .B(wbin_next[0]), .Y(wgray_next[0]) );
  CLKXOR2X2M U5 ( .A(wbin_next[3]), .B(wbin_next[2]), .Y(wgray_next[2]) );
  NOR4X1M U6 ( .A(n1), .B(n2), .C(n3), .D(n4), .Y(wfull_val) );
  XNOR2X2M U7 ( .A(wbin_next[3]), .B(wq2_rptr[3]), .Y(n2) );
  XNOR2X2M U8 ( .A(wgray_next[2]), .B(wq2_rptr[2]), .Y(n1) );
  CLKXOR2X2M U9 ( .A(wq2_rptr[0]), .B(wgray_next[0]), .Y(n3) );
  NOR2BX2M U10 ( .AN(W_INC), .B(wfull), .Y(n8) );
  AND2X2M U11 ( .A(waddr[0]), .B(n8), .Y(n6) );
  CLKXOR2X2M U12 ( .A(n6), .B(waddr[1]), .Y(wbin_next[1]) );
  CLKXOR2X2M U13 ( .A(wq2_rptr[1]), .B(wgray_next[1]), .Y(n4) );
  XNOR2X2M U14 ( .A(n7), .B(waddr[2]), .Y(wbin_next[2]) );
  NAND2X2M U15 ( .A(waddr[1]), .B(n6), .Y(n7) );
  XNOR2X2M U16 ( .A(n5), .B(wbin_3_), .Y(wbin_next[3]) );
  NAND3X2M U17 ( .A(waddr[1]), .B(n6), .C(waddr[2]), .Y(n5) );
  CLKXOR2X2M U18 ( .A(n8), .B(waddr[0]), .Y(wbin_next[0]) );
endmodule


module FIFO_RD ( R_CLK, R_RST, R_INC, rq2_wptr, raddr, rptr, rempty );
  input [3:0] rq2_wptr;
  output [2:0] raddr;
  output [3:0] rptr;
  input R_CLK, R_RST, R_INC;
  output rempty;
  wire   rbin_3_, rempty_val, n1, n2, n3, n4, n5, n6, n7, n8;
  wire   [3:0] rbin_next;
  wire   [2:0] rgray_next;

  DFFRQX2M rbin_reg_3_ ( .D(rbin_next[3]), .CK(R_CLK), .RN(R_RST), .Q(rbin_3_)
         );
  DFFSQX2M rempty_reg ( .D(rempty_val), .CK(R_CLK), .SN(R_RST), .Q(rempty) );
  DFFRQX2M rbin_reg_0_ ( .D(rbin_next[0]), .CK(R_CLK), .RN(R_RST), .Q(raddr[0]) );
  DFFRQX2M rbin_reg_2_ ( .D(rbin_next[2]), .CK(R_CLK), .RN(R_RST), .Q(raddr[2]) );
  DFFRQX2M rbin_reg_1_ ( .D(rbin_next[1]), .CK(R_CLK), .RN(R_RST), .Q(raddr[1]) );
  DFFRQX2M rptr_reg_3_ ( .D(rbin_next[3]), .CK(R_CLK), .RN(R_RST), .Q(rptr[3])
         );
  DFFRQX2M rptr_reg_0_ ( .D(rgray_next[0]), .CK(R_CLK), .RN(R_RST), .Q(rptr[0]) );
  DFFRQX2M rptr_reg_2_ ( .D(rgray_next[2]), .CK(R_CLK), .RN(R_RST), .Q(rptr[2]) );
  DFFRQX2M rptr_reg_1_ ( .D(rgray_next[1]), .CK(R_CLK), .RN(R_RST), .Q(rptr[1]) );
  CLKXOR2X2M U3 ( .A(rbin_next[3]), .B(rbin_next[2]), .Y(rgray_next[2]) );
  CLKXOR2X2M U4 ( .A(rbin_next[2]), .B(rbin_next[1]), .Y(rgray_next[1]) );
  CLKXOR2X2M U5 ( .A(rbin_next[1]), .B(rbin_next[0]), .Y(rgray_next[0]) );
  XNOR2X2M U6 ( .A(n5), .B(rbin_3_), .Y(rbin_next[3]) );
  NAND3X2M U7 ( .A(raddr[1]), .B(n6), .C(raddr[2]), .Y(n5) );
  XNOR2X2M U8 ( .A(n7), .B(raddr[2]), .Y(rbin_next[2]) );
  NAND2X2M U9 ( .A(raddr[1]), .B(n6), .Y(n7) );
  NOR4X1M U10 ( .A(n1), .B(n2), .C(n3), .D(n4), .Y(rempty_val) );
  CLKXOR2X2M U11 ( .A(rq2_wptr[3]), .B(rbin_next[3]), .Y(n2) );
  CLKXOR2X2M U12 ( .A(rq2_wptr[2]), .B(rgray_next[2]), .Y(n1) );
  CLKXOR2X2M U13 ( .A(rq2_wptr[1]), .B(rgray_next[1]), .Y(n4) );
  NOR2BX2M U14 ( .AN(R_INC), .B(rempty), .Y(n8) );
  AND2X2M U15 ( .A(raddr[0]), .B(n8), .Y(n6) );
  CLKXOR2X2M U16 ( .A(rq2_wptr[0]), .B(rgray_next[0]), .Y(n3) );
  CLKXOR2X2M U17 ( .A(n6), .B(raddr[1]), .Y(rbin_next[1]) );
  CLKXOR2X2M U18 ( .A(n8), .B(raddr[0]), .Y(rbin_next[0]) );
endmodule


module DF_SYNC_0 ( CLK, RST, D, Q );
  input [3:0] D;
  output [3:0] Q;
  input CLK, RST;

  wire   [3:0] meta;

  DFFRQX2M Q_reg_2_ ( .D(meta[2]), .CK(CLK), .RN(RST), .Q(Q[2]) );
  DFFRQX2M Q_reg_3_ ( .D(meta[3]), .CK(CLK), .RN(RST), .Q(Q[3]) );
  DFFRQX2M Q_reg_1_ ( .D(meta[1]), .CK(CLK), .RN(RST), .Q(Q[1]) );
  DFFRQX2M Q_reg_0_ ( .D(meta[0]), .CK(CLK), .RN(RST), .Q(Q[0]) );
  DFFRQX2M meta_reg_3_ ( .D(D[3]), .CK(CLK), .RN(RST), .Q(meta[3]) );
  DFFRQX2M meta_reg_2_ ( .D(D[2]), .CK(CLK), .RN(RST), .Q(meta[2]) );
  DFFRQX2M meta_reg_1_ ( .D(D[1]), .CK(CLK), .RN(RST), .Q(meta[1]) );
  DFFRQX2M meta_reg_0_ ( .D(D[0]), .CK(CLK), .RN(RST), .Q(meta[0]) );
endmodule


module DF_SYNC_1 ( CLK, RST, D, Q );
  input [3:0] D;
  output [3:0] Q;
  input CLK, RST;

  wire   [3:0] meta;

  DFFRQX2M Q_reg_3_ ( .D(meta[3]), .CK(CLK), .RN(RST), .Q(Q[3]) );
  DFFRQX2M Q_reg_2_ ( .D(meta[2]), .CK(CLK), .RN(RST), .Q(Q[2]) );
  DFFRQX2M Q_reg_1_ ( .D(meta[1]), .CK(CLK), .RN(RST), .Q(Q[1]) );
  DFFRQX2M Q_reg_0_ ( .D(meta[0]), .CK(CLK), .RN(RST), .Q(Q[0]) );
  DFFRQX2M meta_reg_3_ ( .D(D[3]), .CK(CLK), .RN(RST), .Q(meta[3]) );
  DFFRQX2M meta_reg_2_ ( .D(D[2]), .CK(CLK), .RN(RST), .Q(meta[2]) );
  DFFRQX2M meta_reg_1_ ( .D(D[1]), .CK(CLK), .RN(RST), .Q(meta[1]) );
  DFFRQX2M meta_reg_0_ ( .D(D[0]), .CK(CLK), .RN(RST), .Q(meta[0]) );
endmodule


module ASYNC_FIFO_f ( W_CLK, W_RST, W_INC, R_CLK, R_RST, R_INC, WR_DATA, 
        RD_DATA, FULL, EMPTY );
  input [7:0] WR_DATA;
  output [7:0] RD_DATA;
  input W_CLK, W_RST, W_INC, R_CLK, R_RST, R_INC;
  output FULL, EMPTY;
  wire   n_0_net_;
  wire   [2:0] waddr;
  wire   [2:0] raddr;
  wire   [3:0] wq2_rptr;
  wire   [3:0] wptr;
  wire   [3:0] rq2_wptr;
  wire   [3:0] rptr;

  FIFO_MEM_CNTRL u_mem ( .W_CLK(W_CLK), .W_CLKEN(n_0_net_), .waddr(waddr), 
        .raddr(raddr), .wdata(WR_DATA), .rdata(RD_DATA) );
  FIFO_WR u_wr ( .W_CLK(W_CLK), .W_RST(W_RST), .W_INC(W_INC), .wq2_rptr(
        wq2_rptr), .waddr(waddr), .wptr(wptr), .wfull(FULL) );
  FIFO_RD u_rd ( .R_CLK(R_CLK), .R_RST(R_RST), .R_INC(R_INC), .rq2_wptr(
        rq2_wptr), .raddr(raddr), .rptr(rptr), .rempty(EMPTY) );
  DF_SYNC_0 sync_r2w ( .CLK(W_CLK), .RST(W_RST), .D(rptr), .Q(wq2_rptr) );
  DF_SYNC_1 sync_w2r ( .CLK(R_CLK), .RST(R_RST), .D(wptr), .Q(rq2_wptr) );
  NOR2BX2M U1 ( .AN(W_INC), .B(FULL), .Y(n_0_net_) );
endmodule


module Async_fifo ( i_w_clk, i_w_rstn, i_w_inc, i_w_data, i_r_clk, i_r_rstn, 
        i_r_inc, o_r_data, o_full, o_empty );
  input [7:0] i_w_data;
  output [7:0] o_r_data;
  input i_w_clk, i_w_rstn, i_w_inc, i_r_clk, i_r_rstn, i_r_inc;
  output o_full, o_empty;
  wire   n1, n2;

  ASYNC_FIFO_f u_fifo ( .W_CLK(i_w_clk), .W_RST(n1), .W_INC(i_w_inc), .R_CLK(
        i_r_clk), .R_RST(n2), .R_INC(i_r_inc), .WR_DATA(i_w_data), .RD_DATA(
        o_r_data), .FULL(o_full), .EMPTY(o_empty) );
  BUFX2M U1 ( .A(i_r_rstn), .Y(n2) );
  BUFX2M U2 ( .A(i_w_rstn), .Y(n1) );
endmodule


module Pulse_Gen ( CLK, RST, lvl_sig, pulse_sig );
  input CLK, RST, lvl_sig;
  output pulse_sig;
  wire   lvl_q;

  DFFRQX2M lvl_q_reg ( .D(lvl_sig), .CK(CLK), .RN(RST), .Q(lvl_q) );
  NOR2BX2M U3 ( .AN(lvl_sig), .B(lvl_q), .Y(pulse_sig) );
endmodule


module Clock_Divider_0_DW01_inc_0 ( A, SUM );
  input [7:0] A;
  output [7:0] SUM;

  wire   [7:2] carry;

  ADDHX1M U1_1_6 ( .A(A[6]), .B(carry[6]), .CO(carry[7]), .S(SUM[6]) );
  ADDHX1M U1_1_5 ( .A(A[5]), .B(carry[5]), .CO(carry[6]), .S(SUM[5]) );
  ADDHX1M U1_1_4 ( .A(A[4]), .B(carry[4]), .CO(carry[5]), .S(SUM[4]) );
  ADDHX1M U1_1_3 ( .A(A[3]), .B(carry[3]), .CO(carry[4]), .S(SUM[3]) );
  ADDHX1M U1_1_2 ( .A(A[2]), .B(carry[2]), .CO(carry[3]), .S(SUM[2]) );
  ADDHX1M U1_1_1 ( .A(A[1]), .B(A[0]), .CO(carry[2]), .S(SUM[1]) );
  CLKXOR2X2M U1 ( .A(carry[7]), .B(A[7]), .Y(SUM[7]) );
  CLKINVX1M U2 ( .A(A[0]), .Y(SUM[0]) );
endmodule


module Clock_Divider_0 ( i_ref_clk, i_rst_n, i_clk_en, i_div_ratio, o_div_clk
 );
  input [7:0] i_div_ratio;
  input i_ref_clk, i_rst_n, i_clk_en;
  output o_div_clk;
  wire   div_clk, N8, N10, N11, N12, N13, N14, N15, N16, N17, N33, N34, N35,
         N36, N37, N38, N39, N40, N41, N42, N43, N44, N45, N46, N47, N48, n13,
         n14, n15, n16, n17, n18, n19, n20, n1, n2, n3, n4, n5, n6, n7, n8, n9,
         n10, n11, n12, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30, n31,
         n32, n33, n34, n35, n36, n37, n38, n39, n40, n41;
  wire   [7:0] count;

  Clock_Divider_0_DW01_inc_0 add_37 ( .A(count), .SUM({N40, N39, N38, N37, N36, 
        N35, N34, N33}) );
  DFFRQX2M count_reg_7_ ( .D(N48), .CK(i_ref_clk), .RN(i_rst_n), .Q(count[7])
         );
  DFFRQX2M div_clk_reg ( .D(n20), .CK(i_ref_clk), .RN(i_rst_n), .Q(div_clk) );
  DFFRQX2M count_reg_2_ ( .D(N43), .CK(i_ref_clk), .RN(i_rst_n), .Q(count[2])
         );
  DFFRQX2M count_reg_1_ ( .D(N42), .CK(i_ref_clk), .RN(i_rst_n), .Q(count[1])
         );
  DFFRQX2M count_reg_0_ ( .D(N41), .CK(i_ref_clk), .RN(i_rst_n), .Q(count[0])
         );
  DFFRQX2M count_reg_3_ ( .D(N44), .CK(i_ref_clk), .RN(i_rst_n), .Q(count[3])
         );
  DFFRQX2M count_reg_4_ ( .D(N45), .CK(i_ref_clk), .RN(i_rst_n), .Q(count[4])
         );
  DFFRQX2M count_reg_5_ ( .D(N46), .CK(i_ref_clk), .RN(i_rst_n), .Q(count[5])
         );
  DFFRQX2M count_reg_6_ ( .D(N47), .CK(i_ref_clk), .RN(i_rst_n), .Q(count[6])
         );
  NOR4X1M U3 ( .A(i_div_ratio[3]), .B(i_div_ratio[2]), .C(i_div_ratio[1]), .D(
        n19), .Y(n14) );
  OAI32X1M U4 ( .A0(n15), .A1(n38), .A2(n40), .B0(n41), .B1(n16), .Y(n20) );
  NAND2X2M U5 ( .A(n39), .B(n41), .Y(n15) );
  INVX2M U6 ( .A(n16), .Y(n38) );
  AND2X2M U7 ( .A(N39), .B(n38), .Y(N47) );
  AND2X2M U8 ( .A(N38), .B(n38), .Y(N46) );
  AND2X2M U9 ( .A(N37), .B(n38), .Y(N45) );
  AND2X2M U10 ( .A(N36), .B(n38), .Y(N44) );
  AND2X2M U11 ( .A(N35), .B(n38), .Y(N43) );
  AND2X2M U12 ( .A(N34), .B(n38), .Y(N42) );
  INVX2M U13 ( .A(n14), .Y(n39) );
  NOR2X2M U14 ( .A(n13), .B(n40), .Y(o_div_clk) );
  OAI2B11X2M U15 ( .A1N(N16), .A0(n17), .B0(i_clk_en), .C0(n18), .Y(n16) );
  AOI21X2M U16 ( .A0(N17), .A1(n17), .B0(n14), .Y(n18) );
  AND2X2M U17 ( .A(i_div_ratio[0]), .B(n41), .Y(n17) );
  INVX2M U18 ( .A(div_clk), .Y(n41) );
  INVX2M U19 ( .A(count[0]), .Y(n26) );
  AND2X2M U20 ( .A(N33), .B(n38), .Y(N41) );
  AND2X2M U21 ( .A(N40), .B(n38), .Y(N48) );
  AOI22X1M U22 ( .A0(i_ref_clk), .A1(n14), .B0(div_clk), .B1(n39), .Y(n13) );
  OR4X1M U23 ( .A(i_div_ratio[5]), .B(i_div_ratio[4]), .C(i_div_ratio[7]), .D(
        i_div_ratio[6]), .Y(n19) );
  OR2X2M U24 ( .A(i_div_ratio[2]), .B(i_div_ratio[1]), .Y(n2) );
  AOI21BX2M U25 ( .A0(i_div_ratio[1]), .A1(i_div_ratio[2]), .B0N(n2), .Y(n1)
         );
  INVX2M U26 ( .A(i_clk_en), .Y(n40) );
  CLKINVX1M U27 ( .A(i_div_ratio[1]), .Y(N8) );
  OR2X1M U28 ( .A(n2), .B(i_div_ratio[3]), .Y(n3) );
  OAI2BB1X1M U29 ( .A0N(n2), .A1N(i_div_ratio[3]), .B0(n3), .Y(N10) );
  OR2X1M U30 ( .A(n3), .B(i_div_ratio[4]), .Y(n4) );
  OAI2BB1X1M U31 ( .A0N(n3), .A1N(i_div_ratio[4]), .B0(n4), .Y(N11) );
  OR2X1M U32 ( .A(n4), .B(i_div_ratio[5]), .Y(n5) );
  OAI2BB1X1M U33 ( .A0N(n4), .A1N(i_div_ratio[5]), .B0(n5), .Y(N12) );
  XNOR2X1M U34 ( .A(i_div_ratio[6]), .B(n5), .Y(N13) );
  NOR3X1M U35 ( .A(i_div_ratio[6]), .B(i_div_ratio[7]), .C(n5), .Y(N15) );
  OAI21X1M U36 ( .A0(i_div_ratio[6]), .A1(n5), .B0(i_div_ratio[7]), .Y(n6) );
  NAND2BX1M U37 ( .AN(N15), .B(n6), .Y(N14) );
  XNOR2X1M U38 ( .A(N10), .B(count[2]), .Y(n25) );
  NOR2X1M U39 ( .A(n26), .B(N8), .Y(n7) );
  OAI22X1M U40 ( .A0(count[1]), .A1(n7), .B0(n7), .B1(n1), .Y(n24) );
  CLKNAND2X2M U41 ( .A(N8), .B(n26), .Y(n8) );
  AOI22X1M U42 ( .A0(n8), .A1(n1), .B0(n8), .B1(count[1]), .Y(n9) );
  NOR3X1M U43 ( .A(n9), .B(N15), .C(count[7]), .Y(n23) );
  CLKXOR2X2M U44 ( .A(N11), .B(count[3]), .Y(n21) );
  CLKXOR2X2M U45 ( .A(N12), .B(count[4]), .Y(n12) );
  CLKXOR2X2M U46 ( .A(N13), .B(count[5]), .Y(n11) );
  CLKXOR2X2M U47 ( .A(N14), .B(count[6]), .Y(n10) );
  NOR4X1M U48 ( .A(n21), .B(n12), .C(n11), .D(n10), .Y(n22) );
  AND4X1M U49 ( .A(n25), .B(n24), .C(n23), .D(n22), .Y(N16) );
  NOR2BX1M U50 ( .AN(count[0]), .B(i_div_ratio[1]), .Y(n27) );
  OAI2B2X1M U51 ( .A1N(i_div_ratio[2]), .A0(n27), .B0(count[1]), .B1(n27), .Y(
        n31) );
  XNOR2X1M U52 ( .A(i_div_ratio[3]), .B(count[2]), .Y(n30) );
  NOR2BX1M U53 ( .AN(i_div_ratio[1]), .B(count[0]), .Y(n28) );
  OAI2B2X1M U54 ( .A1N(count[1]), .A0(n28), .B0(i_div_ratio[2]), .B1(n28), .Y(
        n29) );
  NAND4BX1M U55 ( .AN(count[7]), .B(n31), .C(n30), .D(n29), .Y(n37) );
  XNOR2X1M U56 ( .A(i_div_ratio[7]), .B(count[6]), .Y(n35) );
  XNOR2X1M U57 ( .A(i_div_ratio[6]), .B(count[5]), .Y(n34) );
  XNOR2X1M U58 ( .A(i_div_ratio[5]), .B(count[4]), .Y(n33) );
  XNOR2X1M U59 ( .A(i_div_ratio[4]), .B(count[3]), .Y(n32) );
  NAND4X1M U60 ( .A(n35), .B(n34), .C(n33), .D(n32), .Y(n36) );
  NOR2X1M U61 ( .A(n37), .B(n36), .Y(N17) );
endmodule


module CLKDIV_MUX ( IN, OUT );
  input [5:0] IN;
  output [7:0] OUT;
  wire   n1, n2, n3;

  INVX2M U3 ( .A(1'b1), .Y(OUT[7]) );
  INVX2M U5 ( .A(1'b1), .Y(OUT[6]) );
  INVX2M U7 ( .A(1'b1), .Y(OUT[5]) );
  INVX2M U9 ( .A(1'b1), .Y(OUT[4]) );
  INVX2M U11 ( .A(1'b1), .Y(OUT[3]) );
  OAI21X2M U13 ( .A0(n1), .A1(n3), .B0(n2), .Y(OUT[0]) );
  AND2X2M U14 ( .A(n2), .B(n3), .Y(OUT[1]) );
  AND2X2M U15 ( .A(n1), .B(n2), .Y(OUT[2]) );
  NOR3BX2M U16 ( .AN(IN[4]), .B(IN[3]), .C(IN[5]), .Y(n3) );
  NOR3BX2M U17 ( .AN(IN[3]), .B(IN[4]), .C(IN[5]), .Y(n1) );
  NOR3X2M U18 ( .A(IN[2]), .B(IN[1]), .C(IN[0]), .Y(n2) );
endmodule


module Clock_Divider_1_DW01_inc_0 ( A, SUM );
  input [7:0] A;
  output [7:0] SUM;

  wire   [7:2] carry;

  ADDHX1M U1_1_6 ( .A(A[6]), .B(carry[6]), .CO(carry[7]), .S(SUM[6]) );
  ADDHX1M U1_1_5 ( .A(A[5]), .B(carry[5]), .CO(carry[6]), .S(SUM[5]) );
  ADDHX1M U1_1_4 ( .A(A[4]), .B(carry[4]), .CO(carry[5]), .S(SUM[4]) );
  ADDHX1M U1_1_3 ( .A(A[3]), .B(carry[3]), .CO(carry[4]), .S(SUM[3]) );
  ADDHX1M U1_1_2 ( .A(A[2]), .B(carry[2]), .CO(carry[3]), .S(SUM[2]) );
  ADDHX1M U1_1_1 ( .A(A[1]), .B(A[0]), .CO(carry[2]), .S(SUM[1]) );
  CLKXOR2X2M U1 ( .A(carry[7]), .B(A[7]), .Y(SUM[7]) );
  CLKINVX1M U2 ( .A(A[0]), .Y(SUM[0]) );
endmodule


module Clock_Divider_1 ( i_ref_clk, i_rst_n, i_clk_en, i_div_ratio, o_div_clk
 );
  input [7:0] i_div_ratio;
  input i_ref_clk, i_rst_n, i_clk_en;
  output o_div_clk;
  wire   div_clk, N8, N10, N11, N12, N13, N14, N15, N16, N17, N33, N34, N35,
         N36, N37, N38, N39, N40, N41, N42, N43, N44, N45, N46, N47, N48, n1,
         n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n21, n22, n23, n24,
         n25, n26, n27, n28, n29, n30, n31, n32, n33, n34, n35, n36, n37, n38,
         n39, n40, n41, n42, n43, n44, n45, n46, n47, n48, n49;
  wire   [7:0] count;

  Clock_Divider_1_DW01_inc_0 add_37 ( .A(count), .SUM({N40, N39, N38, N37, N36, 
        N35, N34, N33}) );
  DFFRQX2M count_reg_7_ ( .D(N48), .CK(i_ref_clk), .RN(i_rst_n), .Q(count[7])
         );
  DFFRQX2M div_clk_reg ( .D(n42), .CK(i_ref_clk), .RN(i_rst_n), .Q(div_clk) );
  DFFRQX2M count_reg_2_ ( .D(N43), .CK(i_ref_clk), .RN(i_rst_n), .Q(count[2])
         );
  DFFRQX2M count_reg_1_ ( .D(N42), .CK(i_ref_clk), .RN(i_rst_n), .Q(count[1])
         );
  DFFRQX2M count_reg_3_ ( .D(N44), .CK(i_ref_clk), .RN(i_rst_n), .Q(count[3])
         );
  DFFRQX2M count_reg_4_ ( .D(N45), .CK(i_ref_clk), .RN(i_rst_n), .Q(count[4])
         );
  DFFRQX2M count_reg_5_ ( .D(N46), .CK(i_ref_clk), .RN(i_rst_n), .Q(count[5])
         );
  DFFRQX2M count_reg_6_ ( .D(N47), .CK(i_ref_clk), .RN(i_rst_n), .Q(count[6])
         );
  DFFRX1M count_reg_0_ ( .D(N41), .CK(i_ref_clk), .RN(i_rst_n), .Q(count[0]), 
        .QN(n26) );
  NOR4X1M U3 ( .A(i_div_ratio[3]), .B(i_div_ratio[2]), .C(i_div_ratio[1]), .D(
        n43), .Y(n48) );
  OR2X2M U4 ( .A(i_div_ratio[2]), .B(i_div_ratio[1]), .Y(n2) );
  AOI21BX2M U5 ( .A0(i_div_ratio[1]), .A1(i_div_ratio[2]), .B0N(n2), .Y(n1) );
  OAI32X1M U6 ( .A0(n47), .A1(n38), .A2(n41), .B0(n39), .B1(n46), .Y(n42) );
  NAND2X2M U7 ( .A(n40), .B(n39), .Y(n47) );
  INVX2M U8 ( .A(n46), .Y(n38) );
  AND2X2M U9 ( .A(N39), .B(n38), .Y(N47) );
  AND2X2M U10 ( .A(N38), .B(n38), .Y(N46) );
  AND2X2M U11 ( .A(N37), .B(n38), .Y(N45) );
  AND2X2M U12 ( .A(N36), .B(n38), .Y(N44) );
  AND2X2M U13 ( .A(N35), .B(n38), .Y(N43) );
  AND2X2M U14 ( .A(N34), .B(n38), .Y(N42) );
  INVX2M U15 ( .A(n48), .Y(n40) );
  NOR2X2M U16 ( .A(n49), .B(n41), .Y(o_div_clk) );
  OAI2B11X2M U17 ( .A1N(N16), .A0(n45), .B0(i_clk_en), .C0(n44), .Y(n46) );
  AOI21X2M U18 ( .A0(N17), .A1(n45), .B0(n48), .Y(n44) );
  AND2X2M U19 ( .A(i_div_ratio[0]), .B(n39), .Y(n45) );
  INVX2M U20 ( .A(div_clk), .Y(n39) );
  AND2X2M U21 ( .A(N33), .B(n38), .Y(N41) );
  AND2X2M U22 ( .A(N40), .B(n38), .Y(N48) );
  AOI22X1M U23 ( .A0(i_ref_clk), .A1(n48), .B0(div_clk), .B1(n40), .Y(n49) );
  OR4X1M U24 ( .A(i_div_ratio[5]), .B(i_div_ratio[4]), .C(i_div_ratio[7]), .D(
        i_div_ratio[6]), .Y(n43) );
  INVX2M U25 ( .A(i_clk_en), .Y(n41) );
  CLKINVX1M U26 ( .A(i_div_ratio[1]), .Y(N8) );
  OR2X1M U27 ( .A(n2), .B(i_div_ratio[3]), .Y(n3) );
  OAI2BB1X1M U28 ( .A0N(n2), .A1N(i_div_ratio[3]), .B0(n3), .Y(N10) );
  OR2X1M U29 ( .A(n3), .B(i_div_ratio[4]), .Y(n4) );
  OAI2BB1X1M U30 ( .A0N(n3), .A1N(i_div_ratio[4]), .B0(n4), .Y(N11) );
  OR2X1M U31 ( .A(n4), .B(i_div_ratio[5]), .Y(n5) );
  OAI2BB1X1M U32 ( .A0N(n4), .A1N(i_div_ratio[5]), .B0(n5), .Y(N12) );
  XNOR2X1M U33 ( .A(i_div_ratio[6]), .B(n5), .Y(N13) );
  NOR3X1M U34 ( .A(i_div_ratio[6]), .B(i_div_ratio[7]), .C(n5), .Y(N15) );
  OAI21X1M U35 ( .A0(i_div_ratio[6]), .A1(n5), .B0(i_div_ratio[7]), .Y(n6) );
  NAND2BX1M U36 ( .AN(N15), .B(n6), .Y(N14) );
  XNOR2X1M U37 ( .A(N10), .B(count[2]), .Y(n25) );
  NOR2X1M U38 ( .A(n26), .B(N8), .Y(n7) );
  OAI22X1M U39 ( .A0(count[1]), .A1(n7), .B0(n7), .B1(n1), .Y(n24) );
  CLKNAND2X2M U40 ( .A(N8), .B(n26), .Y(n8) );
  AOI22X1M U41 ( .A0(n8), .A1(n1), .B0(n8), .B1(count[1]), .Y(n9) );
  NOR3X1M U42 ( .A(n9), .B(N15), .C(count[7]), .Y(n23) );
  CLKXOR2X2M U43 ( .A(N11), .B(count[3]), .Y(n21) );
  CLKXOR2X2M U44 ( .A(N12), .B(count[4]), .Y(n12) );
  CLKXOR2X2M U45 ( .A(N13), .B(count[5]), .Y(n11) );
  CLKXOR2X2M U46 ( .A(N14), .B(count[6]), .Y(n10) );
  NOR4X1M U47 ( .A(n21), .B(n12), .C(n11), .D(n10), .Y(n22) );
  AND4X1M U48 ( .A(n25), .B(n24), .C(n23), .D(n22), .Y(N16) );
  NOR2BX1M U49 ( .AN(count[0]), .B(i_div_ratio[1]), .Y(n27) );
  OAI2B2X1M U50 ( .A1N(i_div_ratio[2]), .A0(n27), .B0(count[1]), .B1(n27), .Y(
        n31) );
  XNOR2X1M U51 ( .A(i_div_ratio[3]), .B(count[2]), .Y(n30) );
  NOR2BX1M U52 ( .AN(i_div_ratio[1]), .B(count[0]), .Y(n28) );
  OAI2B2X1M U53 ( .A1N(count[1]), .A0(n28), .B0(i_div_ratio[2]), .B1(n28), .Y(
        n29) );
  NAND4BX1M U54 ( .AN(count[7]), .B(n31), .C(n30), .D(n29), .Y(n37) );
  XNOR2X1M U55 ( .A(i_div_ratio[7]), .B(count[6]), .Y(n35) );
  XNOR2X1M U56 ( .A(i_div_ratio[6]), .B(count[5]), .Y(n34) );
  XNOR2X1M U57 ( .A(i_div_ratio[5]), .B(count[4]), .Y(n33) );
  XNOR2X1M U58 ( .A(i_div_ratio[4]), .B(count[3]), .Y(n32) );
  NAND4X1M U59 ( .A(n35), .B(n34), .C(n33), .D(n32), .Y(n36) );
  NOR2X1M U60 ( .A(n37), .B(n36), .Y(N17) );
endmodule


module TX_FSM ( CLK, RST, serial_done, PAR_EN, DATA_VALID, serial_en, MUX_sel, 
        BUSY );
  output [1:0] MUX_sel;
  input CLK, RST, serial_done, PAR_EN, DATA_VALID;
  output serial_en, BUSY;
  wire   n6, n7, n8, n9, n10, n11, n12, n13, n1, n2, n3, n4, n5;
  wire   [2:0] current_state;
  wire   [2:0] next_state;

  DFFRQX2M current_state_reg_0_ ( .D(next_state[0]), .CK(CLK), .RN(RST), .Q(
        current_state[0]) );
  DFFRQX2M current_state_reg_2_ ( .D(next_state[2]), .CK(CLK), .RN(RST), .Q(
        current_state[2]) );
  DFFRQX2M current_state_reg_1_ ( .D(next_state[1]), .CK(CLK), .RN(RST), .Q(
        current_state[1]) );
  AND2X2M U3 ( .A(n8), .B(n4), .Y(n11) );
  INVX2M U4 ( .A(n6), .Y(serial_en) );
  INVX2M U5 ( .A(serial_done), .Y(n1) );
  OAI21X2M U6 ( .A0(n2), .A1(n3), .B0(n12), .Y(MUX_sel[1]) );
  OAI32X1M U7 ( .A0(n1), .A1(PAR_EN), .A2(n7), .B0(n3), .B1(n8), .Y(
        next_state[2]) );
  OAI31X1M U8 ( .A0(n5), .A1(n1), .A2(n6), .B0(n10), .Y(next_state[0]) );
  INVX2M U9 ( .A(PAR_EN), .Y(n5) );
  NAND3X2M U10 ( .A(n11), .B(n3), .C(DATA_VALID), .Y(n10) );
  OAI22X1M U11 ( .A0(current_state[1]), .A1(n8), .B0(n9), .B1(n7), .Y(
        next_state[1]) );
  NOR2X2M U12 ( .A(PAR_EN), .B(n1), .Y(n9) );
  NAND3X2M U13 ( .A(n2), .B(n4), .C(current_state[1]), .Y(n7) );
  NAND2X2M U14 ( .A(current_state[0]), .B(n4), .Y(n8) );
  NAND3X2M U15 ( .A(n7), .B(n8), .C(n13), .Y(BUSY) );
  NAND3X2M U16 ( .A(n2), .B(n3), .C(current_state[2]), .Y(n13) );
  INVX2M U17 ( .A(current_state[1]), .Y(n3) );
  NAND2X2M U18 ( .A(current_state[1]), .B(n11), .Y(n6) );
  INVX2M U19 ( .A(current_state[0]), .Y(n2) );
  INVX2M U20 ( .A(current_state[2]), .Y(n4) );
  NAND2X2M U21 ( .A(n12), .B(n7), .Y(MUX_sel[0]) );
  AOI21X2M U22 ( .A0(n3), .A1(n2), .B0(current_state[2]), .Y(n12) );
endmodule


module serializer ( CLK, RST, P_DATA, load, serial_en, ser_out, serial_done, 
        data_reg );
  input [7:0] P_DATA;
  output [7:0] data_reg;
  input CLK, RST, load, serial_en;
  output ser_out, serial_done;
  wire   N2, N3, N4, N11, N12, N13, n1, n4, n6, n7, n8, n9, n10, n11, n12, n13,
         n14, n2, n3, n5, n15, n16, n17, n18, n19, n20, n21, n22;

  DFFRQX2M data_reg_reg_1_ ( .D(n8), .CK(CLK), .RN(RST), .Q(data_reg[1]) );
  DFFRQX2M data_reg_reg_0_ ( .D(n7), .CK(CLK), .RN(RST), .Q(data_reg[0]) );
  DFFRQX2M data_reg_reg_3_ ( .D(n10), .CK(CLK), .RN(RST), .Q(data_reg[3]) );
  DFFRQX2M data_reg_reg_2_ ( .D(n9), .CK(CLK), .RN(RST), .Q(data_reg[2]) );
  DFFRQX2M count_reg_2_ ( .D(N13), .CK(CLK), .RN(RST), .Q(N4) );
  DFFRQX2M count_reg_1_ ( .D(N12), .CK(CLK), .RN(RST), .Q(N3) );
  DFFRQX2M data_reg_reg_5_ ( .D(n12), .CK(CLK), .RN(RST), .Q(data_reg[5]) );
  DFFRQX2M data_reg_reg_4_ ( .D(n11), .CK(CLK), .RN(RST), .Q(data_reg[4]) );
  DFFRQX2M data_reg_reg_7_ ( .D(n14), .CK(CLK), .RN(RST), .Q(data_reg[7]) );
  DFFRQX2M data_reg_reg_6_ ( .D(n13), .CK(CLK), .RN(RST), .Q(data_reg[6]) );
  DFFRQX2M count_reg_0_ ( .D(N11), .CK(CLK), .RN(RST), .Q(N2) );
  INVX2M U3 ( .A(load), .Y(n21) );
  INVX2M U4 ( .A(serial_en), .Y(n22) );
  NOR2X2M U5 ( .A(n1), .B(n20), .Y(serial_done) );
  AO22X1M U6 ( .A0(data_reg[0]), .A1(n21), .B0(load), .B1(P_DATA[0]), .Y(n7)
         );
  AO22X1M U7 ( .A0(data_reg[7]), .A1(n21), .B0(P_DATA[7]), .B1(load), .Y(n14)
         );
  OAI22X1M U8 ( .A0(N4), .A1(n1), .B0(n4), .B1(n20), .Y(N13) );
  AOI2BB1X2M U9 ( .A0N(N3), .A1N(n22), .B0(N11), .Y(n4) );
  NAND3X2M U10 ( .A(N3), .B(N2), .C(serial_en), .Y(n1) );
  NOR2X2M U11 ( .A(n22), .B(N2), .Y(N11) );
  INVX2M U12 ( .A(N2), .Y(n19) );
  AO22X1M U13 ( .A0(data_reg[1]), .A1(n21), .B0(P_DATA[1]), .B1(load), .Y(n8)
         );
  AO22X1M U14 ( .A0(data_reg[2]), .A1(n21), .B0(P_DATA[2]), .B1(load), .Y(n9)
         );
  AO22X1M U15 ( .A0(data_reg[3]), .A1(n21), .B0(P_DATA[3]), .B1(load), .Y(n10)
         );
  AO22X1M U16 ( .A0(data_reg[4]), .A1(n21), .B0(P_DATA[4]), .B1(load), .Y(n11)
         );
  AO22X1M U17 ( .A0(data_reg[5]), .A1(n21), .B0(P_DATA[5]), .B1(load), .Y(n12)
         );
  AO22X1M U18 ( .A0(data_reg[6]), .A1(n21), .B0(P_DATA[6]), .B1(load), .Y(n13)
         );
  NOR2X2M U19 ( .A(n6), .B(n22), .Y(N12) );
  XNOR2X2M U20 ( .A(N2), .B(N3), .Y(n6) );
  INVX2M U21 ( .A(N4), .Y(n20) );
  INVX2M U22 ( .A(N3), .Y(n18) );
  AOI22X1M U23 ( .A0(data_reg[2]), .A1(n19), .B0(data_reg[3]), .B1(N2), .Y(n3)
         );
  AOI22X1M U24 ( .A0(data_reg[0]), .A1(n19), .B0(data_reg[1]), .B1(N2), .Y(n2)
         );
  OA22X1M U25 ( .A0(n18), .A1(n3), .B0(N3), .B1(n2), .Y(n17) );
  AOI22X1M U26 ( .A0(data_reg[6]), .A1(n19), .B0(data_reg[7]), .B1(N2), .Y(n15) );
  AOI22X1M U27 ( .A0(data_reg[4]), .A1(n19), .B0(data_reg[5]), .B1(N2), .Y(n5)
         );
  OAI22X1M U28 ( .A0(n15), .A1(n18), .B0(N3), .B1(n5), .Y(n16) );
  OAI2BB2X1M U29 ( .B0(n17), .B1(N4), .A0N(N4), .A1N(n16), .Y(ser_out) );
endmodule


module parity_calc ( data, PAR_TYP, par_bit );
  input [7:0] data;
  input PAR_TYP;
  output par_bit;
  wire   n1, n2, n3, n4;

  XNOR2X2M U1 ( .A(data[7]), .B(data[6]), .Y(n4) );
  XOR3XLM U2 ( .A(PAR_TYP), .B(n1), .C(n2), .Y(par_bit) );
  XOR3XLM U3 ( .A(data[1]), .B(data[0]), .C(n3), .Y(n2) );
  XOR3XLM U4 ( .A(data[5]), .B(data[4]), .C(n4), .Y(n1) );
  XNOR2X2M U5 ( .A(data[3]), .B(data[2]), .Y(n3) );
endmodule


module UART_TX ( CLK, RST, PAR_EN, PAR_TYP, P_DATA, DATA_VALID, TX_OUT, Busy
 );
  input [7:0] P_DATA;
  input CLK, RST, PAR_EN, PAR_TYP, DATA_VALID;
  output TX_OUT, Busy;
  wire   serial_done, serial_en, n_0_net_, ser_out, par_bit, mux_out, n1;
  wire   [1:0] MUX_sel;
  wire   [7:0] data_reg;

  TX_FSM u_fsm ( .CLK(CLK), .RST(RST), .serial_done(serial_done), .PAR_EN(
        PAR_EN), .DATA_VALID(DATA_VALID), .serial_en(serial_en), .MUX_sel(
        MUX_sel), .BUSY(Busy) );
  serializer u_ser ( .CLK(CLK), .RST(RST), .P_DATA(P_DATA), .load(n_0_net_), 
        .serial_en(serial_en), .ser_out(ser_out), .serial_done(serial_done), 
        .data_reg(data_reg) );
  parity_calc u_par ( .data(data_reg), .PAR_TYP(PAR_TYP), .par_bit(par_bit) );
  DFFSQX2M TX_OUT_reg ( .D(mux_out), .CK(CLK), .SN(RST), .Q(TX_OUT) );
  NOR2BX2M U3 ( .AN(DATA_VALID), .B(Busy), .Y(n_0_net_) );
  OAI2BB1X2M U4 ( .A0N(ser_out), .A1N(MUX_sel[0]), .B0(n1), .Y(mux_out) );
  OAI21X2M U5 ( .A0(MUX_sel[0]), .A1(par_bit), .B0(MUX_sel[1]), .Y(n1) );
endmodule


module RX_FSM ( CLK, RST, RX_IN, PAR_EN, bit_cnt, edge_cnt, par_err, stp_err, 
        strt_glitch, prescale, edge_bit_en, dat_samp_en, par_check_en, 
        stp_check_en, strt_check_en, deser_en, data_valid );
  input [3:0] bit_cnt;
  input [4:0] edge_cnt;
  input [5:0] prescale;
  input CLK, RST, RX_IN, PAR_EN, par_err, stp_err, strt_glitch;
  output edge_bit_en, dat_samp_en, par_check_en, stp_check_en, strt_check_en,
         deser_en, data_valid;
  wire   N18, N19, N20, N21, N22, N23, last_edge, N26, N27, N28, N29, pre_edge,
         N84, N85, n12, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28,
         n29, n30, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n13, n14, n15,
         n16, n17, n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42,
         n43, n44, n45, n46;
  wire   [2:0] current_state;
  wire   [2:0] next_state;
  wire   [5:3] sub_33_carry;

  DFFRX1M stop_done_d_reg ( .D(N84), .CK(CLK), .RN(RST), .QN(n12) );
  DFFRQX2M current_state_reg_1_ ( .D(next_state[1]), .CK(CLK), .RN(RST), .Q(
        current_state[1]) );
  DFFRQX2M current_state_reg_2_ ( .D(next_state[2]), .CK(CLK), .RN(RST), .Q(
        current_state[2]) );
  DFFRQX2M current_state_reg_0_ ( .D(next_state[0]), .CK(CLK), .RN(RST), .Q(
        current_state[0]) );
  DFFRQX2M data_valid_reg ( .D(N85), .CK(CLK), .RN(RST), .Q(data_valid) );
  INVX2M U3 ( .A(par_check_en), .Y(n42) );
  OAI21X2M U4 ( .A0(n18), .A1(n42), .B0(n19), .Y(next_state[2]) );
  AOI32X1M U5 ( .A0(deser_en), .A1(n46), .A2(n39), .B0(stp_check_en), .B1(n20), 
        .Y(n19) );
  INVX2M U6 ( .A(n18), .Y(n38) );
  INVX2M U7 ( .A(n25), .Y(n39) );
  NOR2X2M U8 ( .A(n29), .B(n43), .Y(par_check_en) );
  NOR2X2M U9 ( .A(n21), .B(n20), .Y(N84) );
  INVX2M U10 ( .A(prescale[1]), .Y(n2) );
  NOR3BX2M U11 ( .AN(last_edge), .B(bit_cnt[1]), .C(bit_cnt[2]), .Y(n28) );
  OAI211X2M U12 ( .A0(current_state[2]), .A1(n43), .B0(n29), .C0(n21), .Y(
        edge_bit_en) );
  NOR3BX2M U13 ( .AN(n28), .B(bit_cnt[0]), .C(bit_cnt[3]), .Y(n24) );
  NAND3X2M U14 ( .A(n28), .B(n40), .C(bit_cnt[3]), .Y(n25) );
  INVX2M U15 ( .A(n21), .Y(stp_check_en) );
  NAND3X2M U16 ( .A(bit_cnt[3]), .B(n28), .C(bit_cnt[0]), .Y(n18) );
  OAI211X2M U17 ( .A0(n38), .A1(n42), .B0(n22), .C0(n23), .Y(next_state[1]) );
  OAI21X2M U18 ( .A0(PAR_EN), .A1(n25), .B0(deser_en), .Y(n22) );
  NAND4BX1M U19 ( .AN(strt_glitch), .B(n45), .C(n24), .D(current_state[0]), 
        .Y(n23) );
  OAI21X2M U20 ( .A0(n38), .A1(n42), .B0(n26), .Y(next_state[0]) );
  AOI33X2M U21 ( .A0(n44), .A1(n45), .A2(n27), .B0(n39), .B1(deser_en), .B2(
        PAR_EN), .Y(n26) );
  OAI22X1M U22 ( .A0(current_state[0]), .A1(RX_IN), .B0(n24), .B1(n43), .Y(n27) );
  INVX2M U23 ( .A(current_state[0]), .Y(n43) );
  NAND4BX1M U24 ( .AN(bit_cnt[2]), .B(pre_edge), .C(bit_cnt[3]), .D(n30), .Y(
        n20) );
  OAI33X2M U25 ( .A0(n41), .A1(bit_cnt[0]), .A2(n46), .B0(n40), .B1(bit_cnt[1]), .B2(PAR_EN), .Y(n30) );
  INVX2M U26 ( .A(bit_cnt[1]), .Y(n41) );
  NOR3X2M U27 ( .A(n43), .B(current_state[2]), .C(current_state[1]), .Y(
        strt_check_en) );
  NOR2X2M U28 ( .A(n29), .B(current_state[0]), .Y(deser_en) );
  NAND3X2M U29 ( .A(n43), .B(n44), .C(current_state[2]), .Y(n21) );
  NAND2X2M U30 ( .A(current_state[1]), .B(n45), .Y(n29) );
  INVX2M U31 ( .A(bit_cnt[0]), .Y(n40) );
  INVX2M U32 ( .A(current_state[2]), .Y(n45) );
  INVX2M U33 ( .A(current_state[1]), .Y(n44) );
  AOI211X2M U34 ( .A0(par_err), .A1(PAR_EN), .B0(n12), .C0(stp_err), .Y(N85)
         );
  OR2X2M U35 ( .A(prescale[1]), .B(prescale[0]), .Y(n3) );
  INVX2M U36 ( .A(PAR_EN), .Y(n46) );
  INVX2M U37 ( .A(prescale[3]), .Y(n7) );
  BUFX2M U38 ( .A(edge_bit_en), .Y(dat_samp_en) );
  XNOR2X1M U39 ( .A(prescale[5]), .B(sub_33_carry[5]), .Y(N29) );
  OR2X1M U40 ( .A(prescale[4]), .B(sub_33_carry[4]), .Y(sub_33_carry[5]) );
  XNOR2X1M U41 ( .A(sub_33_carry[4]), .B(prescale[4]), .Y(N28) );
  OR2X1M U42 ( .A(prescale[3]), .B(sub_33_carry[3]), .Y(sub_33_carry[4]) );
  XNOR2X1M U43 ( .A(sub_33_carry[3]), .B(prescale[3]), .Y(N27) );
  OR2X1M U44 ( .A(prescale[2]), .B(prescale[1]), .Y(sub_33_carry[3]) );
  XNOR2X1M U45 ( .A(prescale[1]), .B(prescale[2]), .Y(N26) );
  CLKINVX1M U46 ( .A(prescale[0]), .Y(N18) );
  OAI2BB1X1M U47 ( .A0N(prescale[0]), .A1N(prescale[1]), .B0(n3), .Y(N19) );
  NOR2X1M U48 ( .A(n3), .B(prescale[2]), .Y(n4) );
  AO21XLM U49 ( .A0(n3), .A1(prescale[2]), .B0(n4), .Y(N20) );
  CLKNAND2X2M U50 ( .A(n4), .B(n7), .Y(n5) );
  OAI21X1M U51 ( .A0(n4), .A1(n7), .B0(n5), .Y(N21) );
  XNOR2X1M U52 ( .A(prescale[4]), .B(n5), .Y(N22) );
  NOR2X1M U53 ( .A(prescale[4]), .B(n5), .Y(n6) );
  CLKXOR2X2M U54 ( .A(prescale[5]), .B(n6), .Y(N23) );
  NOR2BX1M U55 ( .AN(N18), .B(edge_cnt[0]), .Y(n8) );
  OAI2B2X1M U56 ( .A1N(edge_cnt[1]), .A0(n8), .B0(N19), .B1(n8), .Y(n11) );
  NOR2BX1M U57 ( .AN(edge_cnt[0]), .B(N18), .Y(n9) );
  OAI2B2X1M U58 ( .A1N(N19), .A0(n9), .B0(edge_cnt[1]), .B1(n9), .Y(n10) );
  NAND3BX1M U59 ( .AN(N23), .B(n11), .C(n10), .Y(n16) );
  CLKXOR2X2M U60 ( .A(N22), .B(edge_cnt[4]), .Y(n15) );
  CLKXOR2X2M U61 ( .A(N20), .B(edge_cnt[2]), .Y(n14) );
  CLKXOR2X2M U62 ( .A(N21), .B(edge_cnt[3]), .Y(n13) );
  NOR4X1M U63 ( .A(n16), .B(n15), .C(n14), .D(n13), .Y(last_edge) );
  NOR2BX1M U64 ( .AN(prescale[0]), .B(edge_cnt[0]), .Y(n17) );
  OAI2B2X1M U65 ( .A1N(edge_cnt[1]), .A0(n17), .B0(n2), .B1(n17), .Y(n33) );
  NOR2BX1M U66 ( .AN(edge_cnt[0]), .B(prescale[0]), .Y(n31) );
  OAI2B2X1M U67 ( .A1N(n2), .A0(n31), .B0(edge_cnt[1]), .B1(n31), .Y(n32) );
  NAND3BX1M U68 ( .AN(N29), .B(n33), .C(n32), .Y(n37) );
  CLKXOR2X2M U69 ( .A(N28), .B(edge_cnt[4]), .Y(n36) );
  CLKXOR2X2M U70 ( .A(N26), .B(edge_cnt[2]), .Y(n35) );
  CLKXOR2X2M U71 ( .A(N27), .B(edge_cnt[3]), .Y(n34) );
  NOR4X1M U72 ( .A(n37), .B(n36), .C(n35), .D(n34), .Y(pre_edge) );
endmodule


module edge_bit_counter ( CLK, RST, enable, prescale, bit_cnt, edge_cnt );
  input [5:0] prescale;
  output [3:0] bit_cnt;
  output [4:0] edge_cnt;
  input CLK, RST, enable;
  wire   N7, N8, N9, N10, N11, N12, N13, N19, N20, N21, N22, N23, N34, N35,
         N36, N37, N38, n10, n11, n12, n13, n14, n15, n16, n17, n18, n19, n1,
         n2, n3, n4, n5, n6, n7, n8, n9, n20, n21, n22, n23, n24, n25, n26,
         n27, n28, n29, n30;
  wire   [4:2] add_23_carry;

  DFFRQX2M bit_cnt_reg_2_ ( .D(n17), .CK(CLK), .RN(RST), .Q(bit_cnt[2]) );
  DFFRQX2M bit_cnt_reg_1_ ( .D(n18), .CK(CLK), .RN(RST), .Q(bit_cnt[1]) );
  DFFRQX2M bit_cnt_reg_3_ ( .D(n16), .CK(CLK), .RN(RST), .Q(bit_cnt[3]) );
  DFFRQX2M bit_cnt_reg_0_ ( .D(n19), .CK(CLK), .RN(RST), .Q(bit_cnt[0]) );
  DFFRQX2M edge_cnt_reg_4_ ( .D(N38), .CK(CLK), .RN(RST), .Q(edge_cnt[4]) );
  DFFRQX2M edge_cnt_reg_0_ ( .D(N34), .CK(CLK), .RN(RST), .Q(edge_cnt[0]) );
  DFFRQX2M edge_cnt_reg_3_ ( .D(N37), .CK(CLK), .RN(RST), .Q(edge_cnt[3]) );
  DFFRQX2M edge_cnt_reg_2_ ( .D(N36), .CK(CLK), .RN(RST), .Q(edge_cnt[2]) );
  DFFRQX2M edge_cnt_reg_1_ ( .D(N35), .CK(CLK), .RN(RST), .Q(edge_cnt[1]) );
  INVX2M U3 ( .A(n15), .Y(n24) );
  NOR2X2M U4 ( .A(n30), .B(N13), .Y(n15) );
  AOI21X2M U5 ( .A0(n26), .A1(enable), .B0(n15), .Y(n14) );
  AND2X2M U6 ( .A(N20), .B(n15), .Y(N35) );
  AND2X2M U7 ( .A(N21), .B(n15), .Y(N36) );
  AND2X2M U8 ( .A(N22), .B(n15), .Y(N37) );
  NOR3X2M U9 ( .A(n27), .B(n26), .C(n28), .Y(n11) );
  INVX2M U10 ( .A(enable), .Y(n30) );
  OAI32X1M U11 ( .A0(n30), .A1(bit_cnt[0]), .A2(n15), .B0(n26), .B1(n24), .Y(
        n19) );
  OAI32X1M U12 ( .A0(n12), .A1(bit_cnt[2]), .A2(n27), .B0(n13), .B1(n28), .Y(
        n17) );
  OA21X2M U13 ( .A0(n30), .A1(bit_cnt[1]), .B0(n14), .Y(n13) );
  OAI22X1M U14 ( .A0(n29), .A1(n24), .B0(n10), .B1(n30), .Y(n16) );
  AOI32X1M U15 ( .A0(n11), .A1(n29), .A2(N13), .B0(bit_cnt[3]), .B1(n25), .Y(
        n10) );
  INVX2M U16 ( .A(bit_cnt[3]), .Y(n29) );
  INVX2M U17 ( .A(n11), .Y(n25) );
  OAI22X1M U18 ( .A0(n14), .A1(n27), .B0(bit_cnt[1]), .B1(n12), .Y(n18) );
  NAND3X2M U19 ( .A(bit_cnt[0]), .B(n24), .C(enable), .Y(n12) );
  AND2X2M U20 ( .A(N23), .B(n15), .Y(N38) );
  AND2X2M U21 ( .A(N19), .B(n15), .Y(N34) );
  INVX2M U22 ( .A(bit_cnt[0]), .Y(n26) );
  INVX2M U23 ( .A(bit_cnt[1]), .Y(n27) );
  INVX2M U24 ( .A(bit_cnt[2]), .Y(n28) );
  ADDHX1M U25 ( .A(edge_cnt[1]), .B(edge_cnt[0]), .CO(add_23_carry[2]), .S(N20) );
  ADDHX1M U26 ( .A(edge_cnt[2]), .B(add_23_carry[2]), .CO(add_23_carry[3]), 
        .S(N21) );
  ADDHX1M U27 ( .A(edge_cnt[3]), .B(add_23_carry[3]), .CO(add_23_carry[4]), 
        .S(N22) );
  OR2X2M U28 ( .A(prescale[1]), .B(prescale[0]), .Y(n1) );
  INVX2M U29 ( .A(prescale[3]), .Y(n5) );
  CLKINVX1M U30 ( .A(prescale[0]), .Y(N7) );
  OAI2BB1X1M U31 ( .A0N(prescale[0]), .A1N(prescale[1]), .B0(n1), .Y(N8) );
  NOR2X1M U32 ( .A(n1), .B(prescale[2]), .Y(n2) );
  AO21XLM U33 ( .A0(n1), .A1(prescale[2]), .B0(n2), .Y(N9) );
  CLKNAND2X2M U34 ( .A(n2), .B(n5), .Y(n3) );
  OAI21X1M U35 ( .A0(n2), .A1(n5), .B0(n3), .Y(N10) );
  XNOR2X1M U36 ( .A(prescale[4]), .B(n3), .Y(N11) );
  NOR2X1M U37 ( .A(prescale[4]), .B(n3), .Y(n4) );
  CLKXOR2X2M U38 ( .A(prescale[5]), .B(n4), .Y(N12) );
  CLKINVX1M U39 ( .A(edge_cnt[0]), .Y(N19) );
  CLKXOR2X2M U40 ( .A(add_23_carry[4]), .B(edge_cnt[4]), .Y(N23) );
  NOR2BX1M U41 ( .AN(N7), .B(edge_cnt[0]), .Y(n6) );
  OAI2B2X1M U42 ( .A1N(edge_cnt[1]), .A0(n6), .B0(N8), .B1(n6), .Y(n9) );
  NOR2BX1M U43 ( .AN(edge_cnt[0]), .B(N7), .Y(n7) );
  OAI2B2X1M U44 ( .A1N(N8), .A0(n7), .B0(edge_cnt[1]), .B1(n7), .Y(n8) );
  NAND3BX1M U45 ( .AN(N12), .B(n9), .C(n8), .Y(n23) );
  CLKXOR2X2M U46 ( .A(N11), .B(edge_cnt[4]), .Y(n22) );
  CLKXOR2X2M U47 ( .A(N9), .B(edge_cnt[2]), .Y(n21) );
  CLKXOR2X2M U48 ( .A(N10), .B(edge_cnt[3]), .Y(n20) );
  NOR4X1M U49 ( .A(n23), .B(n22), .C(n21), .D(n20), .Y(N13) );
endmodule


module data_sampling ( CLK, RST, RX_IN, dat_samp_en, prescale, edge_cnt, 
        sampled_bit );
  input [5:0] prescale;
  input [4:0] edge_cnt;
  input CLK, RST, RX_IN, dat_samp_en;
  output sampled_bit;
  wire   s0, s1, s2, N9, N10, N11, N13, N15, N16, N17, N18, N19, N20, N21, n11,
         n13, n14, n16, n17, n18, n19, n20, n21, n22, n1, n2, n3, n4, n5, n6,
         n7, n8, n9, n10, n12, n15, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42;
  wire   [4:3] sub_21_carry;

  DFFSQX2M s2_reg ( .D(n20), .CK(CLK), .SN(RST), .Q(s2) );
  DFFSQX2M s0_reg ( .D(n22), .CK(CLK), .SN(RST), .Q(s0) );
  DFFSQX2M s1_reg ( .D(n21), .CK(CLK), .SN(RST), .Q(s1) );
  DFFSQX2M sampled_bit_reg ( .D(n19), .CK(CLK), .SN(RST), .Q(sampled_bit) );
  NOR2X2M U3 ( .A(prescale[5]), .B(sub_21_carry[4]), .Y(n1) );
  INVX2M U4 ( .A(dat_samp_en), .Y(n41) );
  INVX2M U5 ( .A(prescale[2]), .Y(n3) );
  NOR2X2M U6 ( .A(n41), .B(N13), .Y(n16) );
  INVX2M U7 ( .A(prescale[1]), .Y(n2) );
  OAI2BB2X1M U8 ( .B0(n42), .B1(n18), .A0N(n18), .A1N(s0), .Y(n22) );
  NAND2X2M U9 ( .A(N13), .B(dat_samp_en), .Y(n18) );
  OAI2BB2X1M U10 ( .B0(n42), .B1(n17), .A0N(n17), .A1N(s1), .Y(n21) );
  NAND2X2M U11 ( .A(N20), .B(n16), .Y(n17) );
  OAI2BB2X1M U12 ( .B0(n14), .B1(n42), .A0N(n14), .A1N(s2), .Y(n20) );
  NAND3BX2M U13 ( .AN(N20), .B(n16), .C(N21), .Y(n14) );
  OAI2BB2X1M U14 ( .B0(n11), .B1(n41), .A0N(sampled_bit), .A1N(n41), .Y(n19)
         );
  AOI21X2M U15 ( .A0(s1), .A1(s0), .B0(n13), .Y(n11) );
  OA21X2M U16 ( .A0(s1), .A1(s0), .B0(s2), .Y(n13) );
  INVX2M U17 ( .A(RX_IN), .Y(n42) );
  XNOR2X1M U18 ( .A(sub_21_carry[4]), .B(prescale[5]), .Y(N11) );
  OR2X1M U19 ( .A(prescale[4]), .B(sub_21_carry[3]), .Y(sub_21_carry[4]) );
  XNOR2X1M U20 ( .A(sub_21_carry[3]), .B(prescale[4]), .Y(N10) );
  OR2X1M U21 ( .A(prescale[3]), .B(prescale[2]), .Y(sub_21_carry[3]) );
  XNOR2X1M U22 ( .A(prescale[2]), .B(prescale[3]), .Y(N9) );
  NAND2BX1M U23 ( .AN(prescale[2]), .B(n2), .Y(n4) );
  OAI2BB1X1M U24 ( .A0N(prescale[1]), .A1N(prescale[2]), .B0(n4), .Y(N15) );
  OR2X1M U25 ( .A(n4), .B(prescale[3]), .Y(n5) );
  OAI2BB1X1M U26 ( .A0N(n4), .A1N(prescale[3]), .B0(n5), .Y(N16) );
  XNOR2X1M U27 ( .A(prescale[4]), .B(n5), .Y(N17) );
  NOR3X1M U28 ( .A(prescale[4]), .B(prescale[5]), .C(n5), .Y(N19) );
  OAI21X1M U29 ( .A0(prescale[4]), .A1(n5), .B0(prescale[5]), .Y(n6) );
  NAND2BX1M U30 ( .AN(N19), .B(n6), .Y(N18) );
  NOR2BX1M U31 ( .AN(prescale[1]), .B(edge_cnt[0]), .Y(n7) );
  OAI2B2X1M U32 ( .A1N(edge_cnt[1]), .A0(n7), .B0(n3), .B1(n7), .Y(n10) );
  NOR2BX1M U33 ( .AN(edge_cnt[0]), .B(prescale[1]), .Y(n8) );
  OAI2B2X1M U34 ( .A1N(n3), .A0(n8), .B0(edge_cnt[1]), .B1(n8), .Y(n9) );
  NAND3BX1M U35 ( .AN(n1), .B(n10), .C(n9), .Y(n24) );
  CLKXOR2X2M U36 ( .A(N11), .B(edge_cnt[4]), .Y(n23) );
  CLKXOR2X2M U37 ( .A(N9), .B(edge_cnt[2]), .Y(n15) );
  CLKXOR2X2M U38 ( .A(N10), .B(edge_cnt[3]), .Y(n12) );
  NOR4X1M U39 ( .A(n24), .B(n23), .C(n15), .D(n12), .Y(N13) );
  NOR2BX1M U40 ( .AN(n2), .B(edge_cnt[0]), .Y(n25) );
  OAI2B2X1M U41 ( .A1N(edge_cnt[1]), .A0(n25), .B0(N15), .B1(n25), .Y(n28) );
  NOR2BX1M U42 ( .AN(edge_cnt[0]), .B(n2), .Y(n26) );
  OAI2B2X1M U43 ( .A1N(N15), .A0(n26), .B0(edge_cnt[1]), .B1(n26), .Y(n27) );
  NAND3BX1M U44 ( .AN(N19), .B(n28), .C(n27), .Y(n32) );
  CLKXOR2X2M U45 ( .A(N18), .B(edge_cnt[4]), .Y(n31) );
  CLKXOR2X2M U46 ( .A(N16), .B(edge_cnt[2]), .Y(n30) );
  CLKXOR2X2M U47 ( .A(N17), .B(edge_cnt[3]), .Y(n29) );
  NOR4X1M U48 ( .A(n32), .B(n31), .C(n30), .D(n29), .Y(N20) );
  CLKXOR2X2M U49 ( .A(prescale[3]), .B(edge_cnt[2]), .Y(n40) );
  NOR2BX1M U50 ( .AN(prescale[1]), .B(edge_cnt[0]), .Y(n33) );
  OAI2B2X1M U51 ( .A1N(edge_cnt[1]), .A0(n33), .B0(prescale[2]), .B1(n33), .Y(
        n36) );
  NOR2BX1M U52 ( .AN(edge_cnt[0]), .B(prescale[1]), .Y(n34) );
  OAI2B2X1M U53 ( .A1N(prescale[2]), .A0(n34), .B0(edge_cnt[1]), .B1(n34), .Y(
        n35) );
  CLKNAND2X2M U54 ( .A(n36), .B(n35), .Y(n39) );
  CLKXOR2X2M U55 ( .A(prescale[4]), .B(edge_cnt[3]), .Y(n38) );
  CLKXOR2X2M U56 ( .A(prescale[5]), .B(edge_cnt[4]), .Y(n37) );
  NOR4X1M U57 ( .A(n40), .B(n39), .C(n38), .D(n37), .Y(N21) );
endmodule


module deserializer ( CLK, RST, sampled_bit, Enable, edge_count, Prescale, 
        P_DATA );
  input [4:0] edge_count;
  input [5:0] Prescale;
  output [7:0] P_DATA;
  input CLK, RST, sampled_bit, Enable;
  wire   N0, N1, N2, N3, N4, N5, sample_point, n1, n10, n11, n12, n13, n14,
         n15, n16, n17, n2, n3, n4, n5, n6, n7, n8, n9, n18, n19, n20, n21,
         n22, n23, n24, n25, n26, n27, n28, n29, n30;

  DFFRQX2M P_DATA_reg_0_ ( .D(n10), .CK(CLK), .RN(RST), .Q(P_DATA[0]) );
  DFFRQX2M P_DATA_reg_5_ ( .D(n15), .CK(CLK), .RN(RST), .Q(P_DATA[5]) );
  DFFRQX2M P_DATA_reg_1_ ( .D(n11), .CK(CLK), .RN(RST), .Q(P_DATA[1]) );
  DFFRQX2M P_DATA_reg_4_ ( .D(n14), .CK(CLK), .RN(RST), .Q(P_DATA[4]) );
  DFFRQX2M P_DATA_reg_7_ ( .D(n17), .CK(CLK), .RN(RST), .Q(P_DATA[7]) );
  DFFRQX2M P_DATA_reg_3_ ( .D(n13), .CK(CLK), .RN(RST), .Q(P_DATA[3]) );
  DFFRQX2M P_DATA_reg_6_ ( .D(n16), .CK(CLK), .RN(RST), .Q(P_DATA[6]) );
  DFFRQX2M P_DATA_reg_2_ ( .D(n12), .CK(CLK), .RN(RST), .Q(P_DATA[2]) );
  OAI22X1M U3 ( .A0(n30), .A1(n29), .B0(n1), .B1(n28), .Y(n11) );
  OAI22X1M U4 ( .A0(n30), .A1(n28), .B0(n1), .B1(n27), .Y(n12) );
  OAI22X1M U5 ( .A0(n30), .A1(n27), .B0(n1), .B1(n26), .Y(n13) );
  OAI22X1M U6 ( .A0(n30), .A1(n26), .B0(n1), .B1(n25), .Y(n14) );
  OAI22X1M U7 ( .A0(n30), .A1(n25), .B0(n1), .B1(n24), .Y(n15) );
  OAI22X1M U8 ( .A0(n30), .A1(n24), .B0(n1), .B1(n23), .Y(n16) );
  INVX2M U9 ( .A(n1), .Y(n30) );
  NAND2X2M U10 ( .A(sample_point), .B(Enable), .Y(n1) );
  OAI2BB2X1M U11 ( .B0(n1), .B1(n29), .A0N(P_DATA[0]), .A1N(n1), .Y(n10) );
  OAI2BB2X1M U12 ( .B0(n30), .B1(n23), .A0N(sampled_bit), .A1N(n30), .Y(n17)
         );
  INVX2M U13 ( .A(P_DATA[2]), .Y(n28) );
  INVX2M U14 ( .A(P_DATA[6]), .Y(n24) );
  INVX2M U15 ( .A(P_DATA[7]), .Y(n23) );
  INVX2M U16 ( .A(P_DATA[3]), .Y(n27) );
  INVX2M U17 ( .A(P_DATA[1]), .Y(n29) );
  INVX2M U18 ( .A(P_DATA[4]), .Y(n26) );
  INVX2M U19 ( .A(P_DATA[5]), .Y(n25) );
  OR2X2M U20 ( .A(Prescale[1]), .B(Prescale[0]), .Y(n2) );
  INVX2M U21 ( .A(Prescale[3]), .Y(n6) );
  CLKINVX1M U22 ( .A(Prescale[0]), .Y(N0) );
  OAI2BB1X1M U23 ( .A0N(Prescale[0]), .A1N(Prescale[1]), .B0(n2), .Y(N1) );
  NOR2X1M U24 ( .A(n2), .B(Prescale[2]), .Y(n3) );
  AO21XLM U25 ( .A0(n2), .A1(Prescale[2]), .B0(n3), .Y(N2) );
  CLKNAND2X2M U26 ( .A(n3), .B(n6), .Y(n4) );
  OAI21X1M U27 ( .A0(n3), .A1(n6), .B0(n4), .Y(N3) );
  XNOR2X1M U28 ( .A(Prescale[4]), .B(n4), .Y(N4) );
  NOR2X1M U29 ( .A(Prescale[4]), .B(n4), .Y(n5) );
  CLKXOR2X2M U30 ( .A(Prescale[5]), .B(n5), .Y(N5) );
  NOR2BX1M U31 ( .AN(N0), .B(edge_count[0]), .Y(n7) );
  OAI2B2X1M U32 ( .A1N(edge_count[1]), .A0(n7), .B0(N1), .B1(n7), .Y(n18) );
  NOR2BX1M U33 ( .AN(edge_count[0]), .B(N0), .Y(n8) );
  OAI2B2X1M U34 ( .A1N(N1), .A0(n8), .B0(edge_count[1]), .B1(n8), .Y(n9) );
  NAND3BX1M U35 ( .AN(N5), .B(n18), .C(n9), .Y(n22) );
  CLKXOR2X2M U36 ( .A(N4), .B(edge_count[4]), .Y(n21) );
  CLKXOR2X2M U37 ( .A(N2), .B(edge_count[2]), .Y(n20) );
  CLKXOR2X2M U38 ( .A(N3), .B(edge_count[3]), .Y(n19) );
  NOR4X1M U39 ( .A(n22), .B(n21), .C(n20), .D(n19), .Y(sample_point) );
endmodule


module strt_check ( CLK, RST, strt_chk_en, sampled_bit, prescale, edge_cnt, 
        strt_glitch );
  input [5:0] prescale;
  input [4:0] edge_cnt;
  input CLK, RST, strt_chk_en, sampled_bit;
  output strt_glitch;
  wire   N7, N8, N9, N10, N11, n6, n7, n1, n2, n3, n4, n5, n8, n9, n10, n11,
         n12;
  wire   [5:3] sub_16_carry;

  DFFRQX2M strt_glitch_reg ( .D(n7), .CK(CLK), .RN(RST), .Q(strt_glitch) );
  INVX2M U3 ( .A(prescale[1]), .Y(n1) );
  NOR2BX2M U4 ( .AN(strt_chk_en), .B(n6), .Y(n7) );
  AOI22X1M U5 ( .A0(strt_glitch), .A1(n12), .B0(sampled_bit), .B1(N11), .Y(n6)
         );
  INVX2M U6 ( .A(N11), .Y(n12) );
  XNOR2X1M U7 ( .A(prescale[5]), .B(sub_16_carry[5]), .Y(N10) );
  OR2X1M U8 ( .A(prescale[4]), .B(sub_16_carry[4]), .Y(sub_16_carry[5]) );
  XNOR2X1M U9 ( .A(sub_16_carry[4]), .B(prescale[4]), .Y(N9) );
  OR2X1M U10 ( .A(prescale[3]), .B(sub_16_carry[3]), .Y(sub_16_carry[4]) );
  XNOR2X1M U11 ( .A(sub_16_carry[3]), .B(prescale[3]), .Y(N8) );
  OR2X1M U12 ( .A(prescale[2]), .B(prescale[1]), .Y(sub_16_carry[3]) );
  XNOR2X1M U13 ( .A(prescale[1]), .B(prescale[2]), .Y(N7) );
  NOR2BX1M U14 ( .AN(prescale[0]), .B(edge_cnt[0]), .Y(n2) );
  OAI2B2X1M U15 ( .A1N(edge_cnt[1]), .A0(n2), .B0(n1), .B1(n2), .Y(n5) );
  NOR2BX1M U16 ( .AN(edge_cnt[0]), .B(prescale[0]), .Y(n3) );
  OAI2B2X1M U17 ( .A1N(n1), .A0(n3), .B0(edge_cnt[1]), .B1(n3), .Y(n4) );
  NAND3BX1M U18 ( .AN(N10), .B(n5), .C(n4), .Y(n11) );
  CLKXOR2X2M U19 ( .A(N9), .B(edge_cnt[4]), .Y(n10) );
  CLKXOR2X2M U20 ( .A(N7), .B(edge_cnt[2]), .Y(n9) );
  CLKXOR2X2M U21 ( .A(N8), .B(edge_cnt[3]), .Y(n8) );
  NOR4X1M U22 ( .A(n11), .B(n10), .C(n9), .D(n8), .Y(N11) );
endmodule


module par_check ( CLK, RST, strt_chk_en, par_chk_en, PAR_TYP, sampled_bit, 
        P_DATA, prescale, edge_cnt, par_err );
  input [7:0] P_DATA;
  input [5:0] prescale;
  input [4:0] edge_cnt;
  input CLK, RST, strt_chk_en, par_chk_en, PAR_TYP, sampled_bit;
  output par_err;
  wire   N9, N10, N11, N12, N13, n5, n6, n7, n8, n9, n10, n11, n12, n13, n1,
         n2, n3, n4, n14, n15, n16, n17, n18;
  wire   [5:3] sub_22_carry;

  DFFRQX2M par_err_reg ( .D(n13), .CK(CLK), .RN(RST), .Q(par_err) );
  INVX2M U3 ( .A(prescale[1]), .Y(n1) );
  OAI31X1M U4 ( .A0(n5), .A1(strt_chk_en), .A2(n6), .B0(n7), .Y(n13) );
  XOR3XLM U5 ( .A(n8), .B(n9), .C(n10), .Y(n5) );
  NAND2X2M U6 ( .A(par_err), .B(n6), .Y(n7) );
  AOI21X2M U7 ( .A0(par_chk_en), .A1(N13), .B0(strt_chk_en), .Y(n6) );
  XOR3XLM U8 ( .A(P_DATA[5]), .B(P_DATA[4]), .C(n11), .Y(n9) );
  XNOR2X2M U9 ( .A(P_DATA[7]), .B(P_DATA[6]), .Y(n11) );
  XOR3XLM U10 ( .A(P_DATA[1]), .B(P_DATA[0]), .C(n12), .Y(n8) );
  XNOR2X2M U11 ( .A(P_DATA[3]), .B(P_DATA[2]), .Y(n12) );
  XNOR2X2M U12 ( .A(sampled_bit), .B(PAR_TYP), .Y(n10) );
  XNOR2X1M U13 ( .A(prescale[5]), .B(sub_22_carry[5]), .Y(N12) );
  OR2X1M U14 ( .A(prescale[4]), .B(sub_22_carry[4]), .Y(sub_22_carry[5]) );
  XNOR2X1M U15 ( .A(sub_22_carry[4]), .B(prescale[4]), .Y(N11) );
  OR2X1M U16 ( .A(prescale[3]), .B(sub_22_carry[3]), .Y(sub_22_carry[4]) );
  XNOR2X1M U17 ( .A(sub_22_carry[3]), .B(prescale[3]), .Y(N10) );
  OR2X1M U18 ( .A(prescale[2]), .B(prescale[1]), .Y(sub_22_carry[3]) );
  XNOR2X1M U19 ( .A(prescale[1]), .B(prescale[2]), .Y(N9) );
  NOR2BX1M U20 ( .AN(prescale[0]), .B(edge_cnt[0]), .Y(n2) );
  OAI2B2X1M U21 ( .A1N(edge_cnt[1]), .A0(n2), .B0(n1), .B1(n2), .Y(n14) );
  NOR2BX1M U22 ( .AN(edge_cnt[0]), .B(prescale[0]), .Y(n3) );
  OAI2B2X1M U23 ( .A1N(n1), .A0(n3), .B0(edge_cnt[1]), .B1(n3), .Y(n4) );
  NAND3BX1M U24 ( .AN(N12), .B(n14), .C(n4), .Y(n18) );
  CLKXOR2X2M U25 ( .A(N11), .B(edge_cnt[4]), .Y(n17) );
  CLKXOR2X2M U26 ( .A(N9), .B(edge_cnt[2]), .Y(n16) );
  CLKXOR2X2M U27 ( .A(N10), .B(edge_cnt[3]), .Y(n15) );
  NOR4X1M U28 ( .A(n18), .B(n17), .C(n16), .D(n15), .Y(N13) );
endmodule


module stp_check ( CLK, RST, strt_chk_en, stp_chk_en, sampled_bit, prescale, 
        edge_cnt, stp_err );
  input [5:0] prescale;
  input [4:0] edge_cnt;
  input CLK, RST, strt_chk_en, stp_chk_en, sampled_bit;
  output stp_err;
  wire   N4, N5, N6, N7, N8, n5, n6, n7, n1, n2, n3, n4, n8, n9, n10, n11, n12
;
  wire   [5:3] sub_18_carry;

  DFFRQX2M stp_err_reg ( .D(n7), .CK(CLK), .RN(RST), .Q(stp_err) );
  INVX2M U3 ( .A(prescale[1]), .Y(n1) );
  NOR2X2M U4 ( .A(strt_chk_en), .B(n5), .Y(n7) );
  AOI2BB2XLM U5 ( .B0(stp_err), .B1(n6), .A0N(sampled_bit), .A1N(n6), .Y(n5)
         );
  NAND2X2M U6 ( .A(stp_chk_en), .B(N8), .Y(n6) );
  XNOR2X1M U7 ( .A(prescale[5]), .B(sub_18_carry[5]), .Y(N7) );
  OR2X1M U8 ( .A(prescale[4]), .B(sub_18_carry[4]), .Y(sub_18_carry[5]) );
  XNOR2X1M U9 ( .A(sub_18_carry[4]), .B(prescale[4]), .Y(N6) );
  OR2X1M U10 ( .A(prescale[3]), .B(sub_18_carry[3]), .Y(sub_18_carry[4]) );
  XNOR2X1M U11 ( .A(sub_18_carry[3]), .B(prescale[3]), .Y(N5) );
  OR2X1M U12 ( .A(prescale[2]), .B(prescale[1]), .Y(sub_18_carry[3]) );
  XNOR2X1M U13 ( .A(prescale[1]), .B(prescale[2]), .Y(N4) );
  NOR2BX1M U14 ( .AN(prescale[0]), .B(edge_cnt[0]), .Y(n2) );
  OAI2B2X1M U15 ( .A1N(edge_cnt[1]), .A0(n2), .B0(n1), .B1(n2), .Y(n8) );
  NOR2BX1M U16 ( .AN(edge_cnt[0]), .B(prescale[0]), .Y(n3) );
  OAI2B2X1M U17 ( .A1N(n1), .A0(n3), .B0(edge_cnt[1]), .B1(n3), .Y(n4) );
  NAND3BX1M U18 ( .AN(N7), .B(n8), .C(n4), .Y(n12) );
  CLKXOR2X2M U19 ( .A(N6), .B(edge_cnt[4]), .Y(n11) );
  CLKXOR2X2M U20 ( .A(N4), .B(edge_cnt[2]), .Y(n10) );
  CLKXOR2X2M U21 ( .A(N5), .B(edge_cnt[3]), .Y(n9) );
  NOR4X1M U22 ( .A(n12), .B(n11), .C(n10), .D(n9), .Y(N8) );
endmodule


module UART_RX ( CLK, RST, Prescale, PAR_EN, PAR_TYP, RX_IN, P_DATA, 
        data_valid, par_err, stp_err );
  input [5:0] Prescale;
  output [7:0] P_DATA;
  input CLK, RST, PAR_EN, PAR_TYP, RX_IN;
  output data_valid, par_err, stp_err;
  wire   rx_s, rx_m, strt_glitch, edge_bit_en, dat_samp_en, par_chk_en,
         stp_chk_en, strt_chk_en, deser_en, sampled_bit, n1, n2, n3, n4, n5,
         n6;
  wire   [3:0] bit_cnt;
  wire   [4:0] edge_cnt;

  RX_FSM u_fsm ( .CLK(CLK), .RST(n5), .RX_IN(rx_s), .PAR_EN(PAR_EN), .bit_cnt(
        bit_cnt), .edge_cnt(edge_cnt), .par_err(par_err), .stp_err(stp_err), 
        .strt_glitch(strt_glitch), .prescale({Prescale[5:3], n3, n1, 
        Prescale[0]}), .edge_bit_en(edge_bit_en), .dat_samp_en(dat_samp_en), 
        .par_check_en(par_chk_en), .stp_check_en(stp_chk_en), .strt_check_en(
        strt_chk_en), .deser_en(deser_en), .data_valid(data_valid) );
  edge_bit_counter u_cnt ( .CLK(CLK), .RST(n5), .enable(edge_bit_en), 
        .prescale({Prescale[5:3], n3, n1, Prescale[0]}), .bit_cnt(bit_cnt), 
        .edge_cnt(edge_cnt) );
  data_sampling u_samp ( .CLK(CLK), .RST(n5), .RX_IN(rx_s), .dat_samp_en(
        dat_samp_en), .prescale({Prescale[5:3], n3, n1, Prescale[0]}), 
        .edge_cnt(edge_cnt), .sampled_bit(sampled_bit) );
  deserializer u_deser ( .CLK(CLK), .RST(n5), .sampled_bit(sampled_bit), 
        .Enable(deser_en), .edge_count(edge_cnt), .Prescale({Prescale[5:3], n3, 
        n1, Prescale[0]}), .P_DATA(P_DATA) );
  strt_check u_strt ( .CLK(CLK), .RST(n5), .strt_chk_en(strt_chk_en), 
        .sampled_bit(sampled_bit), .prescale({Prescale[5:3], n3, n1, 
        Prescale[0]}), .edge_cnt(edge_cnt), .strt_glitch(strt_glitch) );
  par_check u_par ( .CLK(CLK), .RST(n5), .strt_chk_en(strt_chk_en), 
        .par_chk_en(par_chk_en), .PAR_TYP(PAR_TYP), .sampled_bit(sampled_bit), 
        .P_DATA(P_DATA), .prescale({Prescale[5:3], n3, n1, Prescale[0]}), 
        .edge_cnt(edge_cnt), .par_err(par_err) );
  stp_check u_stp ( .CLK(CLK), .RST(n5), .strt_chk_en(strt_chk_en), 
        .stp_chk_en(stp_chk_en), .sampled_bit(sampled_bit), .prescale({
        Prescale[5:3], n3, n1, Prescale[0]}), .edge_cnt(edge_cnt), .stp_err(
        stp_err) );
  DFFSQX2M rx_s_reg ( .D(rx_m), .CK(CLK), .SN(n5), .Q(rx_s) );
  DFFSQX2M rx_m_reg ( .D(RX_IN), .CK(CLK), .SN(n5), .Q(rx_m) );
  INVX2M U3 ( .A(n2), .Y(n1) );
  INVX2M U4 ( .A(n6), .Y(n5) );
  INVX2M U5 ( .A(RST), .Y(n6) );
  INVX2M U6 ( .A(n4), .Y(n3) );
  INVX2M U7 ( .A(Prescale[2]), .Y(n4) );
  INVX2M U8 ( .A(Prescale[1]), .Y(n2) );
endmodule


module UART ( RST, TX_CLK, RX_CLK, parity_enable, parity_type, Prescale, 
        RX_IN_S, RX_OUT_P, RX_OUT_V, TX_IN_P, TX_IN_V, TX_OUT_S, TX_OUT_V, 
        parity_error, stop_error );
  input [5:0] Prescale;
  output [7:0] RX_OUT_P;
  input [7:0] TX_IN_P;
  input RST, TX_CLK, RX_CLK, parity_enable, parity_type, RX_IN_S, TX_IN_V;
  output RX_OUT_V, TX_OUT_S, TX_OUT_V, parity_error, stop_error;
  wire   n1, n2, n3, n4, n5;

  UART_TX u_tx ( .CLK(TX_CLK), .RST(n4), .PAR_EN(parity_enable), .PAR_TYP(
        parity_type), .P_DATA(TX_IN_P), .DATA_VALID(TX_IN_V), .TX_OUT(TX_OUT_S), .Busy(TX_OUT_V) );
  UART_RX u_rx ( .CLK(RX_CLK), .RST(n4), .Prescale({Prescale[5], n3, 
        Prescale[3], n2, n1, Prescale[0]}), .PAR_EN(parity_enable), .PAR_TYP(
        parity_type), .RX_IN(RX_IN_S), .P_DATA(RX_OUT_P), .data_valid(RX_OUT_V), .par_err(parity_error), .stp_err(stop_error) );
  INVX2M U1 ( .A(n5), .Y(n4) );
  INVX2M U2 ( .A(RST), .Y(n5) );
  BUFX2M U3 ( .A(Prescale[2]), .Y(n2) );
  BUFX2M U4 ( .A(Prescale[1]), .Y(n1) );
  BUFX2M U5 ( .A(Prescale[4]), .Y(n3) );
endmodule


module SYS_CTRL ( CLK, RST, ALU_OUT, ALU_OUT_Valid, ALU_FUN, ALU_EN, CLKG_EN, 
        Address, WrEn, RdEn, WrData, RdData, RdData_Valid, RX_P_DATA, RX_D_VLD, 
        TX_P_DATA, TX_D_VLD, FIFO_FULL, clk_div_en );
  input [15:0] ALU_OUT;
  output [3:0] ALU_FUN;
  output [3:0] Address;
  output [7:0] WrData;
  input [7:0] RdData;
  input [7:0] RX_P_DATA;
  output [7:0] TX_P_DATA;
  input CLK, RST, ALU_OUT_Valid, RdData_Valid, RX_D_VLD, FIFO_FULL;
  output ALU_EN, CLKG_EN, WrEn, RdEn, TX_D_VLD, clk_div_en;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n18, n19, n20, n21, n22, n23, n24,
         n25, n26, n27, n28, n29, n30, n31, n32, n33, n41, n42, n43, n44, n45,
         n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58, n59,
         n60, n61, n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72, n73,
         n74, n75, n76, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86, n87,
         n88, n89, n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100,
         n101, n102, n103, n104, n105, n106, n107, n108, n109, n110, n111,
         n112, n113, n114, n35, n36, n37, n38, n39, n40, n115, n116, n117,
         n118, n119, n120, n121, n122, n123, n124, n125, n126, n127, n128,
         n129, n130, n131, n132, n133;
  wire   [3:0] current_state;
  wire   [3:0] addr_reg;

  DFFRX1M alu_res_reg_7_ ( .D(n86), .CK(CLK), .RN(n36), .QN(n26) );
  DFFRX1M alu_res_reg_6_ ( .D(n85), .CK(CLK), .RN(n36), .QN(n27) );
  DFFRX1M alu_res_reg_5_ ( .D(n84), .CK(CLK), .RN(n36), .QN(n28) );
  DFFRX1M alu_res_reg_4_ ( .D(n83), .CK(CLK), .RN(n36), .QN(n29) );
  DFFRX1M alu_res_reg_3_ ( .D(n82), .CK(CLK), .RN(n36), .QN(n30) );
  DFFRX1M alu_res_reg_2_ ( .D(n81), .CK(CLK), .RN(n36), .QN(n31) );
  DFFRX1M alu_res_reg_1_ ( .D(n80), .CK(CLK), .RN(n36), .QN(n32) );
  DFFRX1M alu_res_reg_0_ ( .D(n79), .CK(CLK), .RN(n35), .QN(n33) );
  DFFRX1M alu_res_reg_15_ ( .D(n94), .CK(CLK), .RN(n35), .QN(n18) );
  DFFRX1M alu_res_reg_14_ ( .D(n93), .CK(CLK), .RN(n35), .QN(n19) );
  DFFRX1M alu_res_reg_13_ ( .D(n92), .CK(CLK), .RN(n35), .QN(n20) );
  DFFRX1M alu_res_reg_12_ ( .D(n91), .CK(CLK), .RN(n35), .QN(n21) );
  DFFRX1M alu_res_reg_11_ ( .D(n90), .CK(CLK), .RN(n36), .QN(n22) );
  DFFRX1M alu_res_reg_10_ ( .D(n89), .CK(CLK), .RN(n36), .QN(n23) );
  DFFRX1M alu_res_reg_9_ ( .D(n88), .CK(CLK), .RN(n36), .QN(n24) );
  DFFRX1M alu_res_reg_8_ ( .D(n87), .CK(CLK), .RN(n36), .QN(n25) );
  DFFRX1M rd_reg_reg_1_ ( .D(n95), .CK(CLK), .RN(n36), .QN(n7) );
  DFFRX1M rd_reg_reg_2_ ( .D(n96), .CK(CLK), .RN(n35), .QN(n6) );
  DFFRX1M rd_reg_reg_3_ ( .D(n97), .CK(CLK), .RN(n35), .QN(n5) );
  DFFRX1M rd_reg_reg_4_ ( .D(n98), .CK(CLK), .RN(n35), .QN(n4) );
  DFFRX1M rd_reg_reg_5_ ( .D(n99), .CK(CLK), .RN(n35), .QN(n3) );
  DFFRX1M rd_reg_reg_6_ ( .D(n100), .CK(CLK), .RN(n35), .QN(n2) );
  DFFRX1M rd_reg_reg_7_ ( .D(n101), .CK(CLK), .RN(n35), .QN(n1) );
  DFFRX1M rd_reg_reg_0_ ( .D(n102), .CK(CLK), .RN(n35), .QN(n8) );
  DFFRQX2M addr_reg_reg_2_ ( .D(n108), .CK(CLK), .RN(n35), .Q(addr_reg[2]) );
  DFFRQX2M addr_reg_reg_3_ ( .D(n109), .CK(CLK), .RN(n36), .Q(addr_reg[3]) );
  DFFRQX2M fun_reg_reg_0_ ( .D(n106), .CK(CLK), .RN(n35), .Q(ALU_FUN[0]) );
  DFFRQX2M fun_reg_reg_1_ ( .D(n103), .CK(CLK), .RN(n36), .Q(ALU_FUN[1]) );
  DFFRQX2M fun_reg_reg_3_ ( .D(n105), .CK(CLK), .RN(n35), .Q(ALU_FUN[3]) );
  DFFRQX2M fun_reg_reg_2_ ( .D(n104), .CK(CLK), .RN(n36), .Q(ALU_FUN[2]) );
  DFFRQX2M addr_reg_reg_0_ ( .D(n110), .CK(CLK), .RN(n35), .Q(addr_reg[0]) );
  DFFRQX2M addr_reg_reg_1_ ( .D(n107), .CK(CLK), .RN(n35), .Q(addr_reg[1]) );
  DFFRQX2M current_state_reg_2_ ( .D(n111), .CK(CLK), .RN(n35), .Q(
        current_state[2]) );
  DFFRQX2M current_state_reg_0_ ( .D(n114), .CK(CLK), .RN(n35), .Q(
        current_state[0]) );
  DFFRQX2M current_state_reg_3_ ( .D(n113), .CK(CLK), .RN(n35), .Q(
        current_state[3]) );
  DFFRQX2M current_state_reg_1_ ( .D(n112), .CK(CLK), .RN(n35), .Q(
        current_state[1]) );
  INVX2M U3 ( .A(1'b0), .Y(clk_div_en) );
  BUFX2M U5 ( .A(n43), .Y(n39) );
  INVX2M U6 ( .A(n37), .Y(n36) );
  NAND2X2M U7 ( .A(n77), .B(n130), .Y(n72) );
  INVX2M U8 ( .A(n66), .Y(n130) );
  INVX2M U9 ( .A(n67), .Y(n128) );
  INVX2M U10 ( .A(n44), .Y(n127) );
  BUFX2M U11 ( .A(n38), .Y(n37) );
  INVX2M U12 ( .A(n38), .Y(n35) );
  NOR2X2M U13 ( .A(n132), .B(n129), .Y(n77) );
  NAND2X2M U14 ( .A(n77), .B(n78), .Y(n75) );
  NAND3X2M U15 ( .A(n62), .B(n76), .C(n75), .Y(n70) );
  INVX2M U16 ( .A(n52), .Y(n119) );
  NOR2X2M U17 ( .A(n126), .B(n72), .Y(RdEn) );
  OAI211X2M U18 ( .A0(n119), .A1(n133), .B0(n48), .C0(n49), .Y(n111) );
  OAI21X2M U19 ( .A0(n127), .A1(n50), .B0(n119), .Y(n48) );
  NAND3X2M U20 ( .A(n129), .B(n132), .C(n73), .Y(n44) );
  NAND3X2M U21 ( .A(n129), .B(n132), .C(n78), .Y(n67) );
  NAND2X2M U22 ( .A(n77), .B(n73), .Y(n71) );
  NAND2X2M U23 ( .A(n133), .B(n131), .Y(n66) );
  NAND3X2M U24 ( .A(n125), .B(n121), .C(n53), .Y(n49) );
  NAND2X2M U25 ( .A(n72), .B(n61), .Y(n50) );
  NAND3BX2M U26 ( .AN(n56), .B(n61), .C(n75), .Y(CLKG_EN) );
  NAND4X2M U27 ( .A(n71), .B(n62), .C(n67), .D(n42), .Y(n56) );
  INVX2M U28 ( .A(n42), .Y(ALU_EN) );
  INVX2M U29 ( .A(RST), .Y(n38) );
  INVX2M U30 ( .A(n116), .Y(n118) );
  INVX2M U31 ( .A(current_state[0]), .Y(n129) );
  NOR2BX2M U32 ( .AN(n70), .B(FIFO_FULL), .Y(TX_D_VLD) );
  OAI221X1M U33 ( .A0(ALU_OUT_Valid), .A1(n42), .B0(RdData_Valid), .B1(n44), 
        .C0(n68), .Y(n52) );
  AOI22X1M U34 ( .A0(n69), .A1(n126), .B0(FIFO_FULL), .B1(n70), .Y(n68) );
  NAND4BX1M U35 ( .AN(n50), .B(n71), .C(n67), .D(n66), .Y(n69) );
  NOR2X2M U36 ( .A(n133), .B(current_state[3]), .Y(n73) );
  OAI21X2M U37 ( .A0(n119), .A1(n131), .B0(n55), .Y(n113) );
  AOI32X1M U38 ( .A0(n53), .A1(RX_P_DATA[0]), .A2(RX_P_DATA[4]), .B0(n119), 
        .B1(n56), .Y(n55) );
  NOR2X2M U39 ( .A(n131), .B(current_state[2]), .Y(n78) );
  AOI31X2M U40 ( .A0(n61), .A1(n71), .A2(n74), .B0(n126), .Y(WrEn) );
  NAND3X2M U41 ( .A(n130), .B(n129), .C(current_state[1]), .Y(n74) );
  OAI221X1M U42 ( .A0(n51), .A1(n52), .B0(n119), .B1(n132), .C0(n49), .Y(n112)
         );
  AOI211X2M U43 ( .A0(n47), .A1(current_state[0]), .B0(n54), .C0(ALU_EN), .Y(
        n51) );
  NAND3X2M U44 ( .A(n78), .B(n129), .C(current_state[1]), .Y(n62) );
  OAI22X1M U45 ( .A0(n119), .A1(n129), .B0(n59), .B1(n52), .Y(n114) );
  NOR4X1M U46 ( .A(n127), .B(n128), .C(n60), .D(n54), .Y(n59) );
  NOR4BX1M U47 ( .AN(RX_P_DATA[5]), .B(n65), .C(n124), .D(n58), .Y(n60) );
  NAND4X2M U48 ( .A(n125), .B(n123), .C(n121), .D(n120), .Y(n65) );
  NAND3X2M U49 ( .A(n78), .B(n132), .C(current_state[0]), .Y(n42) );
  NOR2X2M U50 ( .A(n66), .B(current_state[1]), .Y(n47) );
  OAI222X1M U51 ( .A0(n33), .A1(n62), .B0(n25), .B1(n75), .C0(n8), .C1(n76), 
        .Y(TX_P_DATA[0]) );
  OAI222X1M U52 ( .A0(n32), .A1(n62), .B0(n24), .B1(n75), .C0(n7), .C1(n76), 
        .Y(TX_P_DATA[1]) );
  OAI222X1M U53 ( .A0(n31), .A1(n62), .B0(n23), .B1(n75), .C0(n6), .C1(n76), 
        .Y(TX_P_DATA[2]) );
  OAI222X1M U54 ( .A0(n30), .A1(n62), .B0(n22), .B1(n75), .C0(n5), .C1(n76), 
        .Y(TX_P_DATA[3]) );
  OAI222X1M U55 ( .A0(n29), .A1(n62), .B0(n21), .B1(n75), .C0(n4), .C1(n76), 
        .Y(TX_P_DATA[4]) );
  OAI222X1M U56 ( .A0(n28), .A1(n62), .B0(n20), .B1(n75), .C0(n3), .C1(n76), 
        .Y(TX_P_DATA[5]) );
  OAI222X1M U57 ( .A0(n27), .A1(n62), .B0(n19), .B1(n75), .C0(n2), .C1(n76), 
        .Y(TX_P_DATA[6]) );
  OAI222X1M U58 ( .A0(n26), .A1(n62), .B0(n18), .B1(n75), .C0(n1), .C1(n76), 
        .Y(TX_P_DATA[7]) );
  NOR4BX1M U59 ( .AN(n57), .B(RX_P_DATA[1]), .C(RX_P_DATA[5]), .D(n123), .Y(
        n53) );
  NOR3X2M U60 ( .A(n120), .B(n52), .C(n58), .Y(n57) );
  NAND3X2M U61 ( .A(current_state[0]), .B(n132), .C(n73), .Y(n76) );
  NAND3X2M U62 ( .A(n73), .B(n129), .C(current_state[1]), .Y(n61) );
  NAND4X2M U63 ( .A(RX_P_DATA[7]), .B(n47), .C(RX_P_DATA[3]), .D(n129), .Y(n58) );
  INVX2M U64 ( .A(current_state[1]), .Y(n132) );
  INVX2M U65 ( .A(current_state[2]), .Y(n133) );
  INVX2M U66 ( .A(current_state[3]), .Y(n131) );
  INVX2M U67 ( .A(RX_D_VLD), .Y(n126) );
  NOR2BX2M U68 ( .AN(ALU_OUT_Valid), .B(n42), .Y(n41) );
  NAND3X2M U69 ( .A(n61), .B(n62), .C(n63), .Y(n54) );
  NAND4BX1M U70 ( .AN(n58), .B(RX_P_DATA[4]), .C(RX_P_DATA[5]), .D(n64), .Y(
        n63) );
  NOR4X1M U71 ( .A(RX_P_DATA[6]), .B(RX_P_DATA[2]), .C(n124), .D(n125), .Y(n64) );
  NAND3X2M U72 ( .A(RX_D_VLD), .B(current_state[0]), .C(n47), .Y(n46) );
  NAND2X2M U73 ( .A(RX_D_VLD), .B(n128), .Y(n45) );
  OAI2BB2X1M U74 ( .B0(n125), .B1(n46), .A0N(addr_reg[0]), .A1N(n46), .Y(n110)
         );
  OAI2BB2X1M U75 ( .B0(n122), .B1(n46), .A0N(addr_reg[3]), .A1N(n46), .Y(n109)
         );
  OAI2BB2X1M U76 ( .B0(n123), .B1(n46), .A0N(addr_reg[2]), .A1N(n46), .Y(n108)
         );
  OAI2BB2X1M U77 ( .B0(n124), .B1(n46), .A0N(addr_reg[1]), .A1N(n46), .Y(n107)
         );
  OAI2BB2X1M U78 ( .B0(n45), .B1(n122), .A0N(ALU_FUN[3]), .A1N(n45), .Y(n105)
         );
  INVX2M U79 ( .A(RX_P_DATA[0]), .Y(n125) );
  OAI2BB2X1M U80 ( .B0(n45), .B1(n123), .A0N(ALU_FUN[2]), .A1N(n45), .Y(n104)
         );
  OAI2BB2X1M U81 ( .B0(n45), .B1(n125), .A0N(ALU_FUN[0]), .A1N(n45), .Y(n106)
         );
  OAI2BB2X1M U82 ( .B0(n45), .B1(n124), .A0N(ALU_FUN[1]), .A1N(n45), .Y(n103)
         );
  OAI2BB2X1M U83 ( .B0(n41), .B1(n33), .A0N(ALU_OUT[0]), .A1N(n41), .Y(n79) );
  OAI2BB2X1M U84 ( .B0(n41), .B1(n32), .A0N(ALU_OUT[1]), .A1N(n41), .Y(n80) );
  OAI2BB2X1M U85 ( .B0(n41), .B1(n31), .A0N(ALU_OUT[2]), .A1N(n41), .Y(n81) );
  OAI2BB2X1M U86 ( .B0(n41), .B1(n30), .A0N(ALU_OUT[3]), .A1N(n41), .Y(n82) );
  OAI2BB2X1M U87 ( .B0(n41), .B1(n29), .A0N(ALU_OUT[4]), .A1N(n41), .Y(n83) );
  OAI2BB2X1M U88 ( .B0(n41), .B1(n28), .A0N(ALU_OUT[5]), .A1N(n41), .Y(n84) );
  OAI2BB2X1M U89 ( .B0(n41), .B1(n27), .A0N(ALU_OUT[6]), .A1N(n41), .Y(n85) );
  OAI2BB2X1M U90 ( .B0(n41), .B1(n26), .A0N(ALU_OUT[7]), .A1N(n41), .Y(n86) );
  OAI2BB2X1M U91 ( .B0(n41), .B1(n25), .A0N(ALU_OUT[8]), .A1N(n41), .Y(n87) );
  OAI2BB2X1M U92 ( .B0(n41), .B1(n24), .A0N(ALU_OUT[9]), .A1N(n41), .Y(n88) );
  OAI2BB2X1M U93 ( .B0(n41), .B1(n23), .A0N(ALU_OUT[10]), .A1N(n41), .Y(n89)
         );
  OAI2BB2X1M U94 ( .B0(n41), .B1(n22), .A0N(ALU_OUT[11]), .A1N(n41), .Y(n90)
         );
  OAI2BB2X1M U95 ( .B0(n41), .B1(n21), .A0N(ALU_OUT[12]), .A1N(n41), .Y(n91)
         );
  OAI2BB2X1M U96 ( .B0(n41), .B1(n20), .A0N(ALU_OUT[13]), .A1N(n41), .Y(n92)
         );
  OAI2BB2X1M U97 ( .B0(n41), .B1(n19), .A0N(ALU_OUT[14]), .A1N(n41), .Y(n93)
         );
  OAI2BB2X1M U98 ( .B0(n41), .B1(n18), .A0N(ALU_OUT[15]), .A1N(n41), .Y(n94)
         );
  OAI2BB2X1M U99 ( .B0(n39), .B1(n8), .A0N(RdData[0]), .A1N(n39), .Y(n102) );
  OAI2BB2X1M U100 ( .B0(n39), .B1(n1), .A0N(RdData[7]), .A1N(n39), .Y(n101) );
  OAI2BB2X1M U101 ( .B0(n39), .B1(n2), .A0N(RdData[6]), .A1N(n39), .Y(n100) );
  OAI2BB2X1M U102 ( .B0(n39), .B1(n3), .A0N(RdData[5]), .A1N(n39), .Y(n99) );
  OAI2BB2X1M U103 ( .B0(n39), .B1(n4), .A0N(RdData[4]), .A1N(n39), .Y(n98) );
  OAI2BB2X1M U104 ( .B0(n39), .B1(n5), .A0N(RdData[3]), .A1N(n39), .Y(n97) );
  OAI2BB2X1M U105 ( .B0(n39), .B1(n6), .A0N(RdData[2]), .A1N(n39), .Y(n96) );
  OAI2BB2X1M U106 ( .B0(n39), .B1(n7), .A0N(RdData[1]), .A1N(n39), .Y(n95) );
  NOR2BX2M U107 ( .AN(RdData_Valid), .B(n44), .Y(n43) );
  INVX2M U108 ( .A(RX_P_DATA[1]), .Y(n124) );
  INVX2M U109 ( .A(RX_P_DATA[2]), .Y(n123) );
  INVX2M U110 ( .A(RX_P_DATA[6]), .Y(n120) );
  INVX2M U111 ( .A(RX_P_DATA[4]), .Y(n121) );
  INVX2M U112 ( .A(RX_P_DATA[3]), .Y(n122) );
  BUFX2M U113 ( .A(RX_P_DATA[7]), .Y(WrData[7]) );
  BUFX2M U114 ( .A(RX_P_DATA[6]), .Y(WrData[6]) );
  BUFX2M U115 ( .A(RX_P_DATA[5]), .Y(WrData[5]) );
  BUFX2M U116 ( .A(RX_P_DATA[4]), .Y(WrData[4]) );
  BUFX2M U117 ( .A(RX_P_DATA[3]), .Y(WrData[3]) );
  BUFX2M U118 ( .A(RX_P_DATA[2]), .Y(WrData[2]) );
  BUFX2M U119 ( .A(RX_P_DATA[1]), .Y(WrData[1]) );
  BUFX2M U120 ( .A(RX_P_DATA[0]), .Y(WrData[0]) );
  NOR2BX1M U121 ( .AN(current_state[1]), .B(current_state[3]), .Y(n115) );
  OAI21X1M U122 ( .A0(current_state[2]), .A1(current_state[0]), .B0(n115), .Y(
        n117) );
  OAI211X1M U123 ( .A0(current_state[2]), .A1(RX_P_DATA[0]), .B0(
        current_state[0]), .C0(n115), .Y(n40) );
  OAI2BB1X1M U124 ( .A0N(addr_reg[0]), .A1N(n117), .B0(n40), .Y(Address[0]) );
  NAND3BX1M U125 ( .AN(current_state[2]), .B(n115), .C(current_state[0]), .Y(
        n116) );
  AO22X1M U126 ( .A0(addr_reg[1]), .A1(n117), .B0(RX_P_DATA[1]), .B1(n118), 
        .Y(Address[1]) );
  AO22X1M U127 ( .A0(addr_reg[2]), .A1(n117), .B0(RX_P_DATA[2]), .B1(n118), 
        .Y(Address[2]) );
  AO22X1M U128 ( .A0(addr_reg[3]), .A1(n117), .B0(RX_P_DATA[3]), .B1(n118), 
        .Y(Address[3]) );
endmodule


module RegFile ( CLK, RST, WrEn, RdEn, Address, WrData, RdData, RdData_Valid, 
        REG0, REG1, REG2, REG3 );
  input [3:0] Address;
  input [7:0] WrData;
  output [7:0] RdData;
  output [7:0] REG0;
  output [7:0] REG1;
  output [7:0] REG2;
  output [7:0] REG3;
  input CLK, RST, WrEn, RdEn;
  output RdData_Valid;
  wire   regArr_15__7_, regArr_15__6_, regArr_15__5_, regArr_15__4_,
         regArr_15__3_, regArr_15__2_, regArr_15__1_, regArr_15__0_,
         regArr_14__7_, regArr_14__6_, regArr_14__5_, regArr_14__4_,
         regArr_14__3_, regArr_14__2_, regArr_14__1_, regArr_14__0_,
         regArr_13__7_, regArr_13__6_, regArr_13__5_, regArr_13__4_,
         regArr_13__3_, regArr_13__2_, regArr_13__1_, regArr_13__0_,
         regArr_12__7_, regArr_12__6_, regArr_12__5_, regArr_12__4_,
         regArr_12__3_, regArr_12__2_, regArr_12__1_, regArr_12__0_,
         regArr_11__7_, regArr_11__6_, regArr_11__5_, regArr_11__4_,
         regArr_11__3_, regArr_11__2_, regArr_11__1_, regArr_11__0_,
         regArr_10__7_, regArr_10__6_, regArr_10__5_, regArr_10__4_,
         regArr_10__3_, regArr_10__2_, regArr_10__1_, regArr_10__0_,
         regArr_9__7_, regArr_9__6_, regArr_9__5_, regArr_9__4_, regArr_9__3_,
         regArr_9__2_, regArr_9__1_, regArr_9__0_, regArr_8__7_, regArr_8__6_,
         regArr_8__5_, regArr_8__4_, regArr_8__3_, regArr_8__2_, regArr_8__1_,
         regArr_8__0_, regArr_7__7_, regArr_7__6_, regArr_7__5_, regArr_7__4_,
         regArr_7__3_, regArr_7__2_, regArr_7__1_, regArr_7__0_, regArr_6__7_,
         regArr_6__6_, regArr_6__5_, regArr_6__4_, regArr_6__3_, regArr_6__2_,
         regArr_6__1_, regArr_6__0_, regArr_5__7_, regArr_5__6_, regArr_5__5_,
         regArr_5__4_, regArr_5__3_, regArr_5__2_, regArr_5__1_, regArr_5__0_,
         regArr_4__7_, regArr_4__6_, regArr_4__5_, regArr_4__4_, regArr_4__3_,
         regArr_4__2_, regArr_4__1_, regArr_4__0_, N19, N20, N21, N22, N23,
         N24, N25, N26, n12, n13, n14, n15, n16, n17, n18, n19, n20, n21, n22,
         n23, n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34, n35, n36,
         n37, n38, n39, n40, n41, n42, n43, n44, n45, n46, n47, n48, n49, n50,
         n51, n52, n53, n54, n55, n56, n57, n58, n59, n60, n61, n62, n63, n64,
         n65, n66, n67, n68, n69, n70, n71, n72, n73, n74, n75, n76, n77, n78,
         n79, n80, n81, n82, n83, n84, n85, n86, n87, n88, n89, n90, n91, n92,
         n93, n94, n95, n96, n97, n98, n99, n100, n101, n102, n103, n104, n105,
         n106, n107, n108, n109, n110, n111, n112, n113, n114, n115, n116,
         n117, n118, n119, n120, n121, n122, n123, n124, n125, n126, n127,
         n128, n129, n130, n131, n132, n133, n134, n135, n136, n137, n138,
         n139, n140, n141, n142, n143, n144, n145, n146, n147, n148, n149,
         n150, n151, n152, n153, n154, n155, n156, n157, n158, n159, n160,
         n161, n162, n163, n164, n165, n166, n167, n168, n169, n170, n171,
         n172, n173, n174, n175, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11,
         n176, n177, n178, n179, n180, n181, n182, n183, n184, n185, n186,
         n187, n188, n189, n190, n191, n192, n193, n194, n195, n196, n197,
         n198, n199, n200, n201, n202, n203, n204, n205, n206, n207, n208,
         n209, n210, n211, n212, n213, n214, n215, n216, n217, n218, n219,
         n220, n221, n222, n223, n224, n225, n226, n227, n228, n229, n230,
         n231, n232, n233, n234, n235, n236, n237, n238, n239, n240, n241,
         n242, n243, n244, n245, n246, n247, n248, n249, n250, n251, n252,
         n253, n254, n255, n256, n257, n258, n259, n260, n261, n262, n263,
         n264, n265, n266, n267, n268, n269, n270, n271, n272, n273, n274,
         n275, n276, n277, n278, n279, n280, n281, n282, n283, n284, n285,
         n286, n287, n288, n289, n290, n291, n292, n293, n294, n295, n296,
         n297, n298, n299, n300;

  DFFRQX2M RdData_reg_7_ ( .D(n175), .CK(CLK), .RN(n285), .Q(RdData[7]) );
  DFFRQX2M RdData_reg_6_ ( .D(n174), .CK(CLK), .RN(n277), .Q(RdData[6]) );
  DFFRQX2M RdData_reg_5_ ( .D(n173), .CK(CLK), .RN(n281), .Q(RdData[5]) );
  DFFRQX2M RdData_reg_4_ ( .D(n172), .CK(CLK), .RN(n278), .Q(RdData[4]) );
  DFFRQX2M RdData_reg_3_ ( .D(n171), .CK(CLK), .RN(n278), .Q(RdData[3]) );
  DFFRQX2M RdData_reg_2_ ( .D(n170), .CK(CLK), .RN(n278), .Q(RdData[2]) );
  DFFRQX2M RdData_reg_1_ ( .D(n169), .CK(CLK), .RN(n278), .Q(RdData[1]) );
  DFFRQX2M RdData_reg_0_ ( .D(n168), .CK(CLK), .RN(n278), .Q(RdData[0]) );
  DFFRQX2M regArr_reg_15__7_ ( .D(n167), .CK(CLK), .RN(n277), .Q(regArr_15__7_) );
  DFFRQX2M regArr_reg_15__6_ ( .D(n166), .CK(CLK), .RN(n277), .Q(regArr_15__6_) );
  DFFRQX2M regArr_reg_15__5_ ( .D(n165), .CK(CLK), .RN(n277), .Q(regArr_15__5_) );
  DFFRQX2M regArr_reg_15__4_ ( .D(n164), .CK(CLK), .RN(n277), .Q(regArr_15__4_) );
  DFFRQX2M regArr_reg_15__3_ ( .D(n163), .CK(CLK), .RN(n277), .Q(regArr_15__3_) );
  DFFRQX2M regArr_reg_15__2_ ( .D(n162), .CK(CLK), .RN(n277), .Q(regArr_15__2_) );
  DFFRQX2M regArr_reg_15__1_ ( .D(n161), .CK(CLK), .RN(n277), .Q(regArr_15__1_) );
  DFFRQX2M regArr_reg_15__0_ ( .D(n160), .CK(CLK), .RN(n277), .Q(regArr_15__0_) );
  DFFRQX2M regArr_reg_13__7_ ( .D(n151), .CK(CLK), .RN(n278), .Q(regArr_13__7_) );
  DFFRQX2M regArr_reg_13__6_ ( .D(n150), .CK(CLK), .RN(n278), .Q(regArr_13__6_) );
  DFFRQX2M regArr_reg_13__5_ ( .D(n149), .CK(CLK), .RN(n278), .Q(regArr_13__5_) );
  DFFRQX2M regArr_reg_13__4_ ( .D(n148), .CK(CLK), .RN(n278), .Q(regArr_13__4_) );
  DFFRQX2M regArr_reg_13__3_ ( .D(n147), .CK(CLK), .RN(n278), .Q(regArr_13__3_) );
  DFFRQX2M regArr_reg_13__2_ ( .D(n146), .CK(CLK), .RN(n278), .Q(regArr_13__2_) );
  DFFRQX2M regArr_reg_13__1_ ( .D(n145), .CK(CLK), .RN(n278), .Q(regArr_13__1_) );
  DFFRQX2M regArr_reg_13__0_ ( .D(n144), .CK(CLK), .RN(n278), .Q(regArr_13__0_) );
  DFFRQX2M regArr_reg_11__7_ ( .D(n135), .CK(CLK), .RN(n279), .Q(regArr_11__7_) );
  DFFRQX2M regArr_reg_11__6_ ( .D(n134), .CK(CLK), .RN(n279), .Q(regArr_11__6_) );
  DFFRQX2M regArr_reg_11__5_ ( .D(n133), .CK(CLK), .RN(n279), .Q(regArr_11__5_) );
  DFFRQX2M regArr_reg_11__4_ ( .D(n132), .CK(CLK), .RN(n279), .Q(regArr_11__4_) );
  DFFRQX2M regArr_reg_11__3_ ( .D(n131), .CK(CLK), .RN(n279), .Q(regArr_11__3_) );
  DFFRQX2M regArr_reg_11__2_ ( .D(n130), .CK(CLK), .RN(n279), .Q(regArr_11__2_) );
  DFFRQX2M regArr_reg_11__1_ ( .D(n129), .CK(CLK), .RN(n279), .Q(regArr_11__1_) );
  DFFRQX2M regArr_reg_11__0_ ( .D(n128), .CK(CLK), .RN(n279), .Q(regArr_11__0_) );
  DFFRQX2M regArr_reg_9__7_ ( .D(n119), .CK(CLK), .RN(n280), .Q(regArr_9__7_)
         );
  DFFRQX2M regArr_reg_9__6_ ( .D(n118), .CK(CLK), .RN(n280), .Q(regArr_9__6_)
         );
  DFFRQX2M regArr_reg_9__5_ ( .D(n117), .CK(CLK), .RN(n280), .Q(regArr_9__5_)
         );
  DFFRQX2M regArr_reg_9__4_ ( .D(n116), .CK(CLK), .RN(n280), .Q(regArr_9__4_)
         );
  DFFRQX2M regArr_reg_9__3_ ( .D(n115), .CK(CLK), .RN(n280), .Q(regArr_9__3_)
         );
  DFFRQX2M regArr_reg_9__2_ ( .D(n114), .CK(CLK), .RN(n280), .Q(regArr_9__2_)
         );
  DFFRQX2M regArr_reg_9__1_ ( .D(n113), .CK(CLK), .RN(n280), .Q(regArr_9__1_)
         );
  DFFRQX2M regArr_reg_9__0_ ( .D(n112), .CK(CLK), .RN(n282), .Q(regArr_9__0_)
         );
  DFFRQX2M regArr_reg_7__7_ ( .D(n103), .CK(CLK), .RN(n281), .Q(regArr_7__7_)
         );
  DFFRQX2M regArr_reg_7__6_ ( .D(n102), .CK(CLK), .RN(n281), .Q(regArr_7__6_)
         );
  DFFRQX2M regArr_reg_7__5_ ( .D(n101), .CK(CLK), .RN(n281), .Q(regArr_7__5_)
         );
  DFFRQX2M regArr_reg_7__4_ ( .D(n100), .CK(CLK), .RN(n281), .Q(regArr_7__4_)
         );
  DFFRQX2M regArr_reg_7__3_ ( .D(n99), .CK(CLK), .RN(n281), .Q(regArr_7__3_)
         );
  DFFRQX2M regArr_reg_7__2_ ( .D(n98), .CK(CLK), .RN(n283), .Q(regArr_7__2_)
         );
  DFFRQX2M regArr_reg_7__1_ ( .D(n97), .CK(CLK), .RN(n283), .Q(regArr_7__1_)
         );
  DFFRQX2M regArr_reg_7__0_ ( .D(n96), .CK(CLK), .RN(n283), .Q(regArr_7__0_)
         );
  DFFRQX2M regArr_reg_5__7_ ( .D(n87), .CK(CLK), .RN(n282), .Q(regArr_5__7_)
         );
  DFFRQX2M regArr_reg_5__6_ ( .D(n86), .CK(CLK), .RN(n282), .Q(regArr_5__6_)
         );
  DFFRQX2M regArr_reg_5__5_ ( .D(n85), .CK(CLK), .RN(n282), .Q(regArr_5__5_)
         );
  DFFRQX2M regArr_reg_5__4_ ( .D(n84), .CK(CLK), .RN(n282), .Q(regArr_5__4_)
         );
  DFFRQX2M regArr_reg_5__3_ ( .D(n83), .CK(CLK), .RN(n284), .Q(regArr_5__3_)
         );
  DFFRQX2M regArr_reg_5__2_ ( .D(n82), .CK(CLK), .RN(n284), .Q(regArr_5__2_)
         );
  DFFRQX2M regArr_reg_5__1_ ( .D(n81), .CK(CLK), .RN(n284), .Q(regArr_5__1_)
         );
  DFFRQX2M regArr_reg_5__0_ ( .D(n80), .CK(CLK), .RN(n284), .Q(regArr_5__0_)
         );
  DFFRQX2M regArr_reg_14__7_ ( .D(n159), .CK(CLK), .RN(n277), .Q(regArr_14__7_) );
  DFFRQX2M regArr_reg_14__6_ ( .D(n158), .CK(CLK), .RN(n277), .Q(regArr_14__6_) );
  DFFRQX2M regArr_reg_14__5_ ( .D(n157), .CK(CLK), .RN(n279), .Q(regArr_14__5_) );
  DFFRQX2M regArr_reg_14__4_ ( .D(n156), .CK(CLK), .RN(n279), .Q(regArr_14__4_) );
  DFFRQX2M regArr_reg_14__3_ ( .D(n155), .CK(CLK), .RN(n279), .Q(regArr_14__3_) );
  DFFRQX2M regArr_reg_14__2_ ( .D(n154), .CK(CLK), .RN(n279), .Q(regArr_14__2_) );
  DFFRQX2M regArr_reg_14__1_ ( .D(n153), .CK(CLK), .RN(n279), .Q(regArr_14__1_) );
  DFFRQX2M regArr_reg_14__0_ ( .D(n152), .CK(CLK), .RN(n278), .Q(regArr_14__0_) );
  DFFRQX2M regArr_reg_12__7_ ( .D(n143), .CK(CLK), .RN(n278), .Q(regArr_12__7_) );
  DFFRQX2M regArr_reg_12__6_ ( .D(n142), .CK(CLK), .RN(n280), .Q(regArr_12__6_) );
  DFFRQX2M regArr_reg_12__5_ ( .D(n141), .CK(CLK), .RN(n280), .Q(regArr_12__5_) );
  DFFRQX2M regArr_reg_12__4_ ( .D(n140), .CK(CLK), .RN(n280), .Q(regArr_12__4_) );
  DFFRQX2M regArr_reg_12__3_ ( .D(n139), .CK(CLK), .RN(n280), .Q(regArr_12__3_) );
  DFFRQX2M regArr_reg_12__2_ ( .D(n138), .CK(CLK), .RN(n280), .Q(regArr_12__2_) );
  DFFRQX2M regArr_reg_12__1_ ( .D(n137), .CK(CLK), .RN(n279), .Q(regArr_12__1_) );
  DFFRQX2M regArr_reg_12__0_ ( .D(n136), .CK(CLK), .RN(n279), .Q(regArr_12__0_) );
  DFFRQX2M regArr_reg_10__7_ ( .D(n127), .CK(CLK), .RN(n281), .Q(regArr_10__7_) );
  DFFRQX2M regArr_reg_10__6_ ( .D(n126), .CK(CLK), .RN(n281), .Q(regArr_10__6_) );
  DFFRQX2M regArr_reg_10__5_ ( .D(n125), .CK(CLK), .RN(n281), .Q(regArr_10__5_) );
  DFFRQX2M regArr_reg_10__4_ ( .D(n124), .CK(CLK), .RN(n281), .Q(regArr_10__4_) );
  DFFRQX2M regArr_reg_10__3_ ( .D(n123), .CK(CLK), .RN(n281), .Q(regArr_10__3_) );
  DFFRQX2M regArr_reg_10__2_ ( .D(n122), .CK(CLK), .RN(n280), .Q(regArr_10__2_) );
  DFFRQX2M regArr_reg_10__1_ ( .D(n121), .CK(CLK), .RN(n280), .Q(regArr_10__1_) );
  DFFRQX2M regArr_reg_10__0_ ( .D(n120), .CK(CLK), .RN(n280), .Q(regArr_10__0_) );
  DFFRQX2M regArr_reg_8__7_ ( .D(n111), .CK(CLK), .RN(n282), .Q(regArr_8__7_)
         );
  DFFRQX2M regArr_reg_8__6_ ( .D(n110), .CK(CLK), .RN(n282), .Q(regArr_8__6_)
         );
  DFFRQX2M regArr_reg_8__5_ ( .D(n109), .CK(CLK), .RN(n282), .Q(regArr_8__5_)
         );
  DFFRQX2M regArr_reg_8__4_ ( .D(n108), .CK(CLK), .RN(n282), .Q(regArr_8__4_)
         );
  DFFRQX2M regArr_reg_8__3_ ( .D(n107), .CK(CLK), .RN(n282), .Q(regArr_8__3_)
         );
  DFFRQX2M regArr_reg_8__2_ ( .D(n106), .CK(CLK), .RN(n281), .Q(regArr_8__2_)
         );
  DFFRQX2M regArr_reg_8__1_ ( .D(n105), .CK(CLK), .RN(n281), .Q(regArr_8__1_)
         );
  DFFRQX2M regArr_reg_8__0_ ( .D(n104), .CK(CLK), .RN(n281), .Q(regArr_8__0_)
         );
  DFFRQX2M regArr_reg_6__7_ ( .D(n95), .CK(CLK), .RN(n283), .Q(regArr_6__7_)
         );
  DFFRQX2M regArr_reg_6__6_ ( .D(n94), .CK(CLK), .RN(n283), .Q(regArr_6__6_)
         );
  DFFRQX2M regArr_reg_6__5_ ( .D(n93), .CK(CLK), .RN(n283), .Q(regArr_6__5_)
         );
  DFFRQX2M regArr_reg_6__4_ ( .D(n92), .CK(CLK), .RN(n282), .Q(regArr_6__4_)
         );
  DFFRQX2M regArr_reg_6__3_ ( .D(n91), .CK(CLK), .RN(n282), .Q(regArr_6__3_)
         );
  DFFRQX2M regArr_reg_6__2_ ( .D(n90), .CK(CLK), .RN(n282), .Q(regArr_6__2_)
         );
  DFFRQX2M regArr_reg_6__1_ ( .D(n89), .CK(CLK), .RN(n282), .Q(regArr_6__1_)
         );
  DFFRQX2M regArr_reg_6__0_ ( .D(n88), .CK(CLK), .RN(n282), .Q(regArr_6__0_)
         );
  DFFRQX2M regArr_reg_4__7_ ( .D(n79), .CK(CLK), .RN(n284), .Q(regArr_4__7_)
         );
  DFFRQX2M regArr_reg_4__6_ ( .D(n78), .CK(CLK), .RN(n284), .Q(regArr_4__6_)
         );
  DFFRQX2M regArr_reg_4__5_ ( .D(n77), .CK(CLK), .RN(n283), .Q(regArr_4__5_)
         );
  DFFRQX2M regArr_reg_4__4_ ( .D(n76), .CK(CLK), .RN(n283), .Q(regArr_4__4_)
         );
  DFFRQX2M regArr_reg_4__3_ ( .D(n75), .CK(CLK), .RN(n283), .Q(regArr_4__3_)
         );
  DFFRQX2M regArr_reg_4__2_ ( .D(n74), .CK(CLK), .RN(n283), .Q(regArr_4__2_)
         );
  DFFRQX2M regArr_reg_4__1_ ( .D(n73), .CK(CLK), .RN(n283), .Q(regArr_4__1_)
         );
  DFFRQX2M regArr_reg_4__0_ ( .D(n72), .CK(CLK), .RN(n283), .Q(regArr_4__0_)
         );
  DFFSQX2M regArr_reg_3__5_ ( .D(n69), .CK(CLK), .SN(n277), .Q(REG3[5]) );
  DFFRQX2M RdData_Valid_reg ( .D(n300), .CK(CLK), .RN(n281), .Q(RdData_Valid)
         );
  DFFRQX2M regArr_reg_3__0_ ( .D(n64), .CK(CLK), .RN(n285), .Q(REG3[0]) );
  DFFRQX2M regArr_reg_2__1_ ( .D(n57), .CK(CLK), .RN(n284), .Q(REG2[1]) );
  DFFRQX2M regArr_reg_3__4_ ( .D(n68), .CK(CLK), .RN(n283), .Q(REG3[4]) );
  DFFRQX2M regArr_reg_3__7_ ( .D(n71), .CK(CLK), .RN(n283), .Q(REG3[7]) );
  DFFRQX2M regArr_reg_3__6_ ( .D(n70), .CK(CLK), .RN(n283), .Q(REG3[6]) );
  DFFRQX2M regArr_reg_2__6_ ( .D(n62), .CK(CLK), .RN(n285), .Q(REG2[6]) );
  DFFSQX2M regArr_reg_2__7_ ( .D(n63), .CK(CLK), .SN(n277), .Q(REG2[7]) );
  DFFRQX2M regArr_reg_2__3_ ( .D(n59), .CK(CLK), .RN(n284), .Q(REG2[3]) );
  DFFRQX2M regArr_reg_3__3_ ( .D(n67), .CK(CLK), .RN(n285), .Q(REG3[3]) );
  DFFRQX2M regArr_reg_3__2_ ( .D(n66), .CK(CLK), .RN(n285), .Q(REG3[2]) );
  DFFRQX2M regArr_reg_2__4_ ( .D(n60), .CK(CLK), .RN(n284), .Q(REG2[4]) );
  DFFRQX2M regArr_reg_3__1_ ( .D(n65), .CK(CLK), .RN(n285), .Q(REG3[1]) );
  DFFSQX2M regArr_reg_2__0_ ( .D(n56), .CK(CLK), .SN(n277), .Q(REG2[0]) );
  DFFRQX2M regArr_reg_2__5_ ( .D(n61), .CK(CLK), .RN(n285), .Q(REG2[5]) );
  DFFRQX2M regArr_reg_2__2_ ( .D(n58), .CK(CLK), .RN(n284), .Q(REG2[2]) );
  DFFRQX2M regArr_reg_0__1_ ( .D(n41), .CK(CLK), .RN(n285), .Q(REG0[1]) );
  DFFRQX2M regArr_reg_0__0_ ( .D(n40), .CK(CLK), .RN(n285), .Q(REG0[0]) );
  DFFRQX2M regArr_reg_0__2_ ( .D(n42), .CK(CLK), .RN(n285), .Q(REG0[2]) );
  DFFRQX2M regArr_reg_0__3_ ( .D(n43), .CK(CLK), .RN(n285), .Q(REG0[3]) );
  DFFRQX2M regArr_reg_0__4_ ( .D(n44), .CK(CLK), .RN(n285), .Q(REG0[4]) );
  DFFRQX2M regArr_reg_0__5_ ( .D(n45), .CK(CLK), .RN(n285), .Q(REG0[5]) );
  DFFRQX2M regArr_reg_0__6_ ( .D(n46), .CK(CLK), .RN(n277), .Q(REG0[6]) );
  DFFRQX2M regArr_reg_1__7_ ( .D(n55), .CK(CLK), .RN(n284), .Q(REG1[7]) );
  DFFRQX2M regArr_reg_1__1_ ( .D(n49), .CK(CLK), .RN(n286), .Q(REG1[1]) );
  DFFRQX2M regArr_reg_1__0_ ( .D(n48), .CK(CLK), .RN(n285), .Q(REG1[0]) );
  DFFRQX2M regArr_reg_0__7_ ( .D(n47), .CK(CLK), .RN(n285), .Q(REG0[7]) );
  DFFRQX2M regArr_reg_1__2_ ( .D(n50), .CK(CLK), .RN(n286), .Q(REG1[2]) );
  DFFRQX2M regArr_reg_1__3_ ( .D(n51), .CK(CLK), .RN(n284), .Q(REG1[3]) );
  DFFRQX2M regArr_reg_1__5_ ( .D(n53), .CK(CLK), .RN(n284), .Q(REG1[5]) );
  DFFRQX2M regArr_reg_1__6_ ( .D(n54), .CK(CLK), .RN(n284), .Q(REG1[6]) );
  DFFRQX2M regArr_reg_1__4_ ( .D(n52), .CK(CLK), .RN(n284), .Q(REG1[4]) );
  NOR2BX2M U3 ( .AN(n26), .B(n269), .Y(n17) );
  NOR2BX2M U4 ( .AN(n38), .B(Address[0]), .Y(n30) );
  NOR2BX2M U5 ( .AN(n26), .B(Address[0]), .Y(n15) );
  NOR2BX2M U6 ( .AN(Address[2]), .B(Address[1]), .Y(n22) );
  NOR2X2M U7 ( .A(n270), .B(Address[2]), .Y(n19) );
  NOR2X2M U8 ( .A(Address[1]), .B(Address[2]), .Y(n14) );
  NOR2BX2M U9 ( .AN(Address[2]), .B(n270), .Y(n25) );
  INVX2M U10 ( .A(WrData[3]), .Y(n296) );
  INVX2M U11 ( .A(WrData[0]), .Y(n299) );
  INVX2M U12 ( .A(WrData[4]), .Y(n295) );
  INVX2M U13 ( .A(WrData[1]), .Y(n298) );
  INVX2M U14 ( .A(WrData[2]), .Y(n297) );
  INVX2M U15 ( .A(WrData[5]), .Y(n294) );
  INVX2M U16 ( .A(WrData[6]), .Y(n293) );
  INVX2M U17 ( .A(WrData[7]), .Y(n292) );
  INVX2M U18 ( .A(n1), .Y(n273) );
  OR2X2M U19 ( .A(n270), .B(n269), .Y(n1) );
  INVX2M U20 ( .A(n2), .Y(n274) );
  INVX2M U21 ( .A(n3), .Y(n276) );
  INVX2M U22 ( .A(n4), .Y(n275) );
  NOR2BX2M U23 ( .AN(n38), .B(n269), .Y(n32) );
  NAND2X2M U24 ( .A(n19), .B(n15), .Y(n18) );
  NAND2X2M U25 ( .A(n22), .B(n15), .Y(n21) );
  NAND2X2M U26 ( .A(n25), .B(n15), .Y(n24) );
  NAND2X2M U27 ( .A(n17), .B(n14), .Y(n16) );
  NAND2X2M U28 ( .A(n30), .B(n14), .Y(n29) );
  NAND2X2M U29 ( .A(n32), .B(n14), .Y(n31) );
  NAND2X2M U30 ( .A(n30), .B(n19), .Y(n33) );
  NAND2X2M U31 ( .A(n32), .B(n19), .Y(n34) );
  NAND2X2M U32 ( .A(n30), .B(n22), .Y(n35) );
  NAND2X2M U33 ( .A(n32), .B(n22), .Y(n36) );
  NAND2X2M U34 ( .A(n19), .B(n17), .Y(n20) );
  NAND2X2M U35 ( .A(n22), .B(n17), .Y(n23) );
  NAND2X2M U36 ( .A(n25), .B(n17), .Y(n27) );
  NAND2X2M U37 ( .A(n30), .B(n25), .Y(n37) );
  NAND2X2M U38 ( .A(n32), .B(n25), .Y(n39) );
  NAND2X2M U39 ( .A(n14), .B(n15), .Y(n13) );
  INVX2M U40 ( .A(n12), .Y(n300) );
  BUFX2M U41 ( .A(n291), .Y(n277) );
  BUFX2M U42 ( .A(n288), .Y(n284) );
  BUFX2M U43 ( .A(n288), .Y(n283) );
  BUFX2M U44 ( .A(n289), .Y(n282) );
  BUFX2M U45 ( .A(n290), .Y(n280) );
  BUFX2M U46 ( .A(n290), .Y(n279) );
  BUFX2M U47 ( .A(n291), .Y(n278) );
  BUFX2M U48 ( .A(n289), .Y(n281) );
  BUFX2M U49 ( .A(n287), .Y(n285) );
  BUFX2M U50 ( .A(n287), .Y(n286) );
  OR2X2M U51 ( .A(n270), .B(Address[0]), .Y(n2) );
  OR2X2M U52 ( .A(Address[0]), .B(Address[1]), .Y(n3) );
  OR2X2M U53 ( .A(n269), .B(Address[1]), .Y(n4) );
  INVX2M U54 ( .A(Address[1]), .Y(n270) );
  INVX2M U55 ( .A(Address[0]), .Y(n269) );
  INVX2M U56 ( .A(Address[2]), .Y(n271) );
  INVX2M U57 ( .A(Address[3]), .Y(n272) );
  AND2X2M U58 ( .A(Address[3]), .B(n28), .Y(n38) );
  NAND2BX2M U59 ( .AN(WrEn), .B(RdEn), .Y(n12) );
  NOR2BX2M U60 ( .AN(n28), .B(Address[3]), .Y(n26) );
  NOR2BX2M U61 ( .AN(WrEn), .B(RdEn), .Y(n28) );
  BUFX2M U62 ( .A(RST), .Y(n288) );
  BUFX2M U63 ( .A(RST), .Y(n290) );
  BUFX2M U64 ( .A(RST), .Y(n289) );
  BUFX2M U65 ( .A(RST), .Y(n291) );
  BUFX2M U66 ( .A(RST), .Y(n287) );
  AO22X1M U67 ( .A0(N26), .A1(n300), .B0(RdData[0]), .B1(n12), .Y(n168) );
  AO22X1M U68 ( .A0(N25), .A1(n300), .B0(RdData[1]), .B1(n12), .Y(n169) );
  AO22X1M U69 ( .A0(N24), .A1(n300), .B0(RdData[2]), .B1(n12), .Y(n170) );
  AO22X1M U70 ( .A0(N23), .A1(n300), .B0(RdData[3]), .B1(n12), .Y(n171) );
  AO22X1M U71 ( .A0(N22), .A1(n300), .B0(RdData[4]), .B1(n12), .Y(n172) );
  AO22X1M U72 ( .A0(N21), .A1(n300), .B0(RdData[5]), .B1(n12), .Y(n173) );
  AO22X1M U73 ( .A0(N20), .A1(n300), .B0(RdData[6]), .B1(n12), .Y(n174) );
  AO22X1M U74 ( .A0(N19), .A1(n300), .B0(RdData[7]), .B1(n12), .Y(n175) );
  OAI2BB2X1M U75 ( .B0(n299), .B1(n29), .A0N(regArr_8__0_), .A1N(n29), .Y(n104) );
  OAI2BB2X1M U76 ( .B0(n298), .B1(n29), .A0N(regArr_8__1_), .A1N(n29), .Y(n105) );
  OAI2BB2X1M U77 ( .B0(n297), .B1(n29), .A0N(regArr_8__2_), .A1N(n29), .Y(n106) );
  OAI2BB2X1M U78 ( .B0(n296), .B1(n29), .A0N(regArr_8__3_), .A1N(n29), .Y(n107) );
  OAI2BB2X1M U79 ( .B0(n295), .B1(n29), .A0N(regArr_8__4_), .A1N(n29), .Y(n108) );
  OAI2BB2X1M U80 ( .B0(n294), .B1(n29), .A0N(regArr_8__5_), .A1N(n29), .Y(n109) );
  OAI2BB2X1M U81 ( .B0(n293), .B1(n29), .A0N(regArr_8__6_), .A1N(n29), .Y(n110) );
  OAI2BB2X1M U82 ( .B0(n292), .B1(n29), .A0N(regArr_8__7_), .A1N(n29), .Y(n111) );
  OAI2BB2X1M U83 ( .B0(n299), .B1(n33), .A0N(regArr_10__0_), .A1N(n33), .Y(
        n120) );
  OAI2BB2X1M U84 ( .B0(n298), .B1(n33), .A0N(regArr_10__1_), .A1N(n33), .Y(
        n121) );
  OAI2BB2X1M U85 ( .B0(n297), .B1(n33), .A0N(regArr_10__2_), .A1N(n33), .Y(
        n122) );
  OAI2BB2X1M U86 ( .B0(n296), .B1(n33), .A0N(regArr_10__3_), .A1N(n33), .Y(
        n123) );
  OAI2BB2X1M U87 ( .B0(n295), .B1(n33), .A0N(regArr_10__4_), .A1N(n33), .Y(
        n124) );
  OAI2BB2X1M U88 ( .B0(n294), .B1(n33), .A0N(regArr_10__5_), .A1N(n33), .Y(
        n125) );
  OAI2BB2X1M U89 ( .B0(n293), .B1(n33), .A0N(regArr_10__6_), .A1N(n33), .Y(
        n126) );
  OAI2BB2X1M U90 ( .B0(n292), .B1(n33), .A0N(regArr_10__7_), .A1N(n33), .Y(
        n127) );
  OAI2BB2X1M U91 ( .B0(n299), .B1(n35), .A0N(regArr_12__0_), .A1N(n35), .Y(
        n136) );
  OAI2BB2X1M U92 ( .B0(n298), .B1(n35), .A0N(regArr_12__1_), .A1N(n35), .Y(
        n137) );
  OAI2BB2X1M U93 ( .B0(n297), .B1(n35), .A0N(regArr_12__2_), .A1N(n35), .Y(
        n138) );
  OAI2BB2X1M U94 ( .B0(n296), .B1(n35), .A0N(regArr_12__3_), .A1N(n35), .Y(
        n139) );
  OAI2BB2X1M U95 ( .B0(n295), .B1(n35), .A0N(regArr_12__4_), .A1N(n35), .Y(
        n140) );
  OAI2BB2X1M U96 ( .B0(n294), .B1(n35), .A0N(regArr_12__5_), .A1N(n35), .Y(
        n141) );
  OAI2BB2X1M U97 ( .B0(n293), .B1(n35), .A0N(regArr_12__6_), .A1N(n35), .Y(
        n142) );
  OAI2BB2X1M U98 ( .B0(n292), .B1(n35), .A0N(regArr_12__7_), .A1N(n35), .Y(
        n143) );
  OAI2BB2X1M U99 ( .B0(n299), .B1(n37), .A0N(regArr_14__0_), .A1N(n37), .Y(
        n152) );
  OAI2BB2X1M U100 ( .B0(n298), .B1(n37), .A0N(regArr_14__1_), .A1N(n37), .Y(
        n153) );
  OAI2BB2X1M U101 ( .B0(n297), .B1(n37), .A0N(regArr_14__2_), .A1N(n37), .Y(
        n154) );
  OAI2BB2X1M U102 ( .B0(n296), .B1(n37), .A0N(regArr_14__3_), .A1N(n37), .Y(
        n155) );
  OAI2BB2X1M U103 ( .B0(n295), .B1(n37), .A0N(regArr_14__4_), .A1N(n37), .Y(
        n156) );
  OAI2BB2X1M U104 ( .B0(n294), .B1(n37), .A0N(regArr_14__5_), .A1N(n37), .Y(
        n157) );
  OAI2BB2X1M U105 ( .B0(n293), .B1(n37), .A0N(regArr_14__6_), .A1N(n37), .Y(
        n158) );
  OAI2BB2X1M U106 ( .B0(n292), .B1(n37), .A0N(regArr_14__7_), .A1N(n37), .Y(
        n159) );
  OAI2BB2X1M U107 ( .B0(n13), .B1(n299), .A0N(REG0[0]), .A1N(n13), .Y(n40) );
  OAI2BB2X1M U108 ( .B0(n13), .B1(n298), .A0N(REG0[1]), .A1N(n13), .Y(n41) );
  OAI2BB2X1M U109 ( .B0(n13), .B1(n297), .A0N(REG0[2]), .A1N(n13), .Y(n42) );
  OAI2BB2X1M U110 ( .B0(n13), .B1(n296), .A0N(REG0[3]), .A1N(n13), .Y(n43) );
  OAI2BB2X1M U111 ( .B0(n13), .B1(n295), .A0N(REG0[4]), .A1N(n13), .Y(n44) );
  OAI2BB2X1M U112 ( .B0(n13), .B1(n294), .A0N(REG0[5]), .A1N(n13), .Y(n45) );
  OAI2BB2X1M U113 ( .B0(n13), .B1(n293), .A0N(REG0[6]), .A1N(n13), .Y(n46) );
  OAI2BB2X1M U114 ( .B0(n13), .B1(n292), .A0N(REG0[7]), .A1N(n13), .Y(n47) );
  OAI2BB2X1M U115 ( .B0(n298), .B1(n18), .A0N(REG2[1]), .A1N(n18), .Y(n57) );
  OAI2BB2X1M U116 ( .B0(n297), .B1(n18), .A0N(REG2[2]), .A1N(n18), .Y(n58) );
  OAI2BB2X1M U117 ( .B0(n296), .B1(n18), .A0N(REG2[3]), .A1N(n18), .Y(n59) );
  OAI2BB2X1M U118 ( .B0(n295), .B1(n18), .A0N(REG2[4]), .A1N(n18), .Y(n60) );
  OAI2BB2X1M U119 ( .B0(n294), .B1(n18), .A0N(REG2[5]), .A1N(n18), .Y(n61) );
  OAI2BB2X1M U120 ( .B0(n293), .B1(n18), .A0N(REG2[6]), .A1N(n18), .Y(n62) );
  OAI2BB2X1M U121 ( .B0(n299), .B1(n21), .A0N(regArr_4__0_), .A1N(n21), .Y(n72) );
  OAI2BB2X1M U122 ( .B0(n298), .B1(n21), .A0N(regArr_4__1_), .A1N(n21), .Y(n73) );
  OAI2BB2X1M U123 ( .B0(n297), .B1(n21), .A0N(regArr_4__2_), .A1N(n21), .Y(n74) );
  OAI2BB2X1M U124 ( .B0(n296), .B1(n21), .A0N(regArr_4__3_), .A1N(n21), .Y(n75) );
  OAI2BB2X1M U125 ( .B0(n295), .B1(n21), .A0N(regArr_4__4_), .A1N(n21), .Y(n76) );
  OAI2BB2X1M U126 ( .B0(n294), .B1(n21), .A0N(regArr_4__5_), .A1N(n21), .Y(n77) );
  OAI2BB2X1M U127 ( .B0(n293), .B1(n21), .A0N(regArr_4__6_), .A1N(n21), .Y(n78) );
  OAI2BB2X1M U128 ( .B0(n292), .B1(n21), .A0N(regArr_4__7_), .A1N(n21), .Y(n79) );
  OAI2BB2X1M U129 ( .B0(n299), .B1(n24), .A0N(regArr_6__0_), .A1N(n24), .Y(n88) );
  OAI2BB2X1M U130 ( .B0(n298), .B1(n24), .A0N(regArr_6__1_), .A1N(n24), .Y(n89) );
  OAI2BB2X1M U131 ( .B0(n297), .B1(n24), .A0N(regArr_6__2_), .A1N(n24), .Y(n90) );
  OAI2BB2X1M U132 ( .B0(n296), .B1(n24), .A0N(regArr_6__3_), .A1N(n24), .Y(n91) );
  OAI2BB2X1M U133 ( .B0(n295), .B1(n24), .A0N(regArr_6__4_), .A1N(n24), .Y(n92) );
  OAI2BB2X1M U134 ( .B0(n294), .B1(n24), .A0N(regArr_6__5_), .A1N(n24), .Y(n93) );
  OAI2BB2X1M U135 ( .B0(n293), .B1(n24), .A0N(regArr_6__6_), .A1N(n24), .Y(n94) );
  OAI2BB2X1M U136 ( .B0(n292), .B1(n24), .A0N(regArr_6__7_), .A1N(n24), .Y(n95) );
  OAI2BB2X1M U137 ( .B0(n299), .B1(n23), .A0N(regArr_5__0_), .A1N(n23), .Y(n80) );
  OAI2BB2X1M U138 ( .B0(n298), .B1(n23), .A0N(regArr_5__1_), .A1N(n23), .Y(n81) );
  OAI2BB2X1M U139 ( .B0(n297), .B1(n23), .A0N(regArr_5__2_), .A1N(n23), .Y(n82) );
  OAI2BB2X1M U140 ( .B0(n296), .B1(n23), .A0N(regArr_5__3_), .A1N(n23), .Y(n83) );
  OAI2BB2X1M U141 ( .B0(n295), .B1(n23), .A0N(regArr_5__4_), .A1N(n23), .Y(n84) );
  OAI2BB2X1M U142 ( .B0(n294), .B1(n23), .A0N(regArr_5__5_), .A1N(n23), .Y(n85) );
  OAI2BB2X1M U143 ( .B0(n293), .B1(n23), .A0N(regArr_5__6_), .A1N(n23), .Y(n86) );
  OAI2BB2X1M U144 ( .B0(n292), .B1(n23), .A0N(regArr_5__7_), .A1N(n23), .Y(n87) );
  OAI2BB2X1M U145 ( .B0(n299), .B1(n20), .A0N(REG3[0]), .A1N(n20), .Y(n64) );
  OAI2BB2X1M U146 ( .B0(n298), .B1(n20), .A0N(REG3[1]), .A1N(n20), .Y(n65) );
  OAI2BB2X1M U147 ( .B0(n297), .B1(n20), .A0N(REG3[2]), .A1N(n20), .Y(n66) );
  OAI2BB2X1M U148 ( .B0(n296), .B1(n20), .A0N(REG3[3]), .A1N(n20), .Y(n67) );
  OAI2BB2X1M U149 ( .B0(n295), .B1(n20), .A0N(REG3[4]), .A1N(n20), .Y(n68) );
  OAI2BB2X1M U150 ( .B0(n293), .B1(n20), .A0N(REG3[6]), .A1N(n20), .Y(n70) );
  OAI2BB2X1M U151 ( .B0(n292), .B1(n20), .A0N(REG3[7]), .A1N(n20), .Y(n71) );
  OAI2BB2X1M U152 ( .B0(n299), .B1(n16), .A0N(REG1[0]), .A1N(n16), .Y(n48) );
  OAI2BB2X1M U153 ( .B0(n298), .B1(n16), .A0N(REG1[1]), .A1N(n16), .Y(n49) );
  OAI2BB2X1M U154 ( .B0(n297), .B1(n16), .A0N(REG1[2]), .A1N(n16), .Y(n50) );
  OAI2BB2X1M U155 ( .B0(n296), .B1(n16), .A0N(REG1[3]), .A1N(n16), .Y(n51) );
  OAI2BB2X1M U156 ( .B0(n295), .B1(n16), .A0N(REG1[4]), .A1N(n16), .Y(n52) );
  OAI2BB2X1M U157 ( .B0(n294), .B1(n16), .A0N(REG1[5]), .A1N(n16), .Y(n53) );
  OAI2BB2X1M U158 ( .B0(n293), .B1(n16), .A0N(REG1[6]), .A1N(n16), .Y(n54) );
  OAI2BB2X1M U159 ( .B0(n292), .B1(n16), .A0N(REG1[7]), .A1N(n16), .Y(n55) );
  OAI2BB2X1M U160 ( .B0(n299), .B1(n31), .A0N(regArr_9__0_), .A1N(n31), .Y(
        n112) );
  OAI2BB2X1M U161 ( .B0(n298), .B1(n31), .A0N(regArr_9__1_), .A1N(n31), .Y(
        n113) );
  OAI2BB2X1M U162 ( .B0(n297), .B1(n31), .A0N(regArr_9__2_), .A1N(n31), .Y(
        n114) );
  OAI2BB2X1M U163 ( .B0(n296), .B1(n31), .A0N(regArr_9__3_), .A1N(n31), .Y(
        n115) );
  OAI2BB2X1M U164 ( .B0(n295), .B1(n31), .A0N(regArr_9__4_), .A1N(n31), .Y(
        n116) );
  OAI2BB2X1M U165 ( .B0(n294), .B1(n31), .A0N(regArr_9__5_), .A1N(n31), .Y(
        n117) );
  OAI2BB2X1M U166 ( .B0(n293), .B1(n31), .A0N(regArr_9__6_), .A1N(n31), .Y(
        n118) );
  OAI2BB2X1M U167 ( .B0(n292), .B1(n31), .A0N(regArr_9__7_), .A1N(n31), .Y(
        n119) );
  OAI2BB2X1M U168 ( .B0(n299), .B1(n36), .A0N(regArr_13__0_), .A1N(n36), .Y(
        n144) );
  OAI2BB2X1M U169 ( .B0(n298), .B1(n36), .A0N(regArr_13__1_), .A1N(n36), .Y(
        n145) );
  OAI2BB2X1M U170 ( .B0(n297), .B1(n36), .A0N(regArr_13__2_), .A1N(n36), .Y(
        n146) );
  OAI2BB2X1M U171 ( .B0(n296), .B1(n36), .A0N(regArr_13__3_), .A1N(n36), .Y(
        n147) );
  OAI2BB2X1M U172 ( .B0(n295), .B1(n36), .A0N(regArr_13__4_), .A1N(n36), .Y(
        n148) );
  OAI2BB2X1M U173 ( .B0(n294), .B1(n36), .A0N(regArr_13__5_), .A1N(n36), .Y(
        n149) );
  OAI2BB2X1M U174 ( .B0(n293), .B1(n36), .A0N(regArr_13__6_), .A1N(n36), .Y(
        n150) );
  OAI2BB2X1M U175 ( .B0(n292), .B1(n36), .A0N(regArr_13__7_), .A1N(n36), .Y(
        n151) );
  OAI2BB2X1M U176 ( .B0(n299), .B1(n34), .A0N(regArr_11__0_), .A1N(n34), .Y(
        n128) );
  OAI2BB2X1M U177 ( .B0(n298), .B1(n34), .A0N(regArr_11__1_), .A1N(n34), .Y(
        n129) );
  OAI2BB2X1M U178 ( .B0(n297), .B1(n34), .A0N(regArr_11__2_), .A1N(n34), .Y(
        n130) );
  OAI2BB2X1M U179 ( .B0(n296), .B1(n34), .A0N(regArr_11__3_), .A1N(n34), .Y(
        n131) );
  OAI2BB2X1M U180 ( .B0(n295), .B1(n34), .A0N(regArr_11__4_), .A1N(n34), .Y(
        n132) );
  OAI2BB2X1M U181 ( .B0(n294), .B1(n34), .A0N(regArr_11__5_), .A1N(n34), .Y(
        n133) );
  OAI2BB2X1M U182 ( .B0(n293), .B1(n34), .A0N(regArr_11__6_), .A1N(n34), .Y(
        n134) );
  OAI2BB2X1M U183 ( .B0(n292), .B1(n34), .A0N(regArr_11__7_), .A1N(n34), .Y(
        n135) );
  OAI2BB2X1M U184 ( .B0(n299), .B1(n27), .A0N(regArr_7__0_), .A1N(n27), .Y(n96) );
  OAI2BB2X1M U185 ( .B0(n298), .B1(n27), .A0N(regArr_7__1_), .A1N(n27), .Y(n97) );
  OAI2BB2X1M U186 ( .B0(n297), .B1(n27), .A0N(regArr_7__2_), .A1N(n27), .Y(n98) );
  OAI2BB2X1M U187 ( .B0(n296), .B1(n27), .A0N(regArr_7__3_), .A1N(n27), .Y(n99) );
  OAI2BB2X1M U188 ( .B0(n295), .B1(n27), .A0N(regArr_7__4_), .A1N(n27), .Y(
        n100) );
  OAI2BB2X1M U189 ( .B0(n294), .B1(n27), .A0N(regArr_7__5_), .A1N(n27), .Y(
        n101) );
  OAI2BB2X1M U190 ( .B0(n293), .B1(n27), .A0N(regArr_7__6_), .A1N(n27), .Y(
        n102) );
  OAI2BB2X1M U191 ( .B0(n292), .B1(n27), .A0N(regArr_7__7_), .A1N(n27), .Y(
        n103) );
  OAI2BB2X1M U192 ( .B0(n299), .B1(n39), .A0N(regArr_15__0_), .A1N(n39), .Y(
        n160) );
  OAI2BB2X1M U193 ( .B0(n298), .B1(n39), .A0N(regArr_15__1_), .A1N(n39), .Y(
        n161) );
  OAI2BB2X1M U194 ( .B0(n297), .B1(n39), .A0N(regArr_15__2_), .A1N(n39), .Y(
        n162) );
  OAI2BB2X1M U195 ( .B0(n296), .B1(n39), .A0N(regArr_15__3_), .A1N(n39), .Y(
        n163) );
  OAI2BB2X1M U196 ( .B0(n295), .B1(n39), .A0N(regArr_15__4_), .A1N(n39), .Y(
        n164) );
  OAI2BB2X1M U197 ( .B0(n294), .B1(n39), .A0N(regArr_15__5_), .A1N(n39), .Y(
        n165) );
  OAI2BB2X1M U198 ( .B0(n293), .B1(n39), .A0N(regArr_15__6_), .A1N(n39), .Y(
        n166) );
  OAI2BB2X1M U199 ( .B0(n292), .B1(n39), .A0N(regArr_15__7_), .A1N(n39), .Y(
        n167) );
  OAI2BB2X1M U200 ( .B0(n299), .B1(n18), .A0N(REG2[0]), .A1N(n18), .Y(n56) );
  OAI2BB2X1M U201 ( .B0(n292), .B1(n18), .A0N(REG2[7]), .A1N(n18), .Y(n63) );
  OAI2BB2X1M U202 ( .B0(n294), .B1(n20), .A0N(REG3[5]), .A1N(n20), .Y(n69) );
  AOI22X1M U203 ( .A0(regArr_10__0_), .A1(n274), .B0(regArr_11__0_), .B1(n273), 
        .Y(n6) );
  AOI22X1M U204 ( .A0(regArr_8__0_), .A1(n276), .B0(regArr_9__0_), .B1(n275), 
        .Y(n5) );
  CLKNAND2X2M U205 ( .A(Address[3]), .B(n271), .Y(n253) );
  AOI21X1M U206 ( .A0(n6), .A1(n5), .B0(n253), .Y(n180) );
  AOI22X1M U207 ( .A0(regArr_14__0_), .A1(n274), .B0(regArr_15__0_), .B1(n273), 
        .Y(n8) );
  AOI22X1M U208 ( .A0(regArr_12__0_), .A1(n276), .B0(regArr_13__0_), .B1(n275), 
        .Y(n7) );
  CLKNAND2X2M U209 ( .A(Address[3]), .B(Address[2]), .Y(n256) );
  AOI21X1M U210 ( .A0(n8), .A1(n7), .B0(n256), .Y(n179) );
  AOI22X1M U211 ( .A0(REG2[0]), .A1(n274), .B0(REG3[0]), .B1(n273), .Y(n10) );
  AOI22X1M U212 ( .A0(REG0[0]), .A1(n276), .B0(REG1[0]), .B1(n275), .Y(n9) );
  CLKNAND2X2M U213 ( .A(n271), .B(n272), .Y(n259) );
  AOI21X1M U214 ( .A0(n10), .A1(n9), .B0(n259), .Y(n178) );
  AOI22X1M U215 ( .A0(regArr_6__0_), .A1(n274), .B0(regArr_7__0_), .B1(n273), 
        .Y(n176) );
  AOI22X1M U216 ( .A0(regArr_4__0_), .A1(n276), .B0(regArr_5__0_), .B1(n275), 
        .Y(n11) );
  CLKNAND2X2M U217 ( .A(Address[2]), .B(n272), .Y(n262) );
  AOI21X1M U218 ( .A0(n176), .A1(n11), .B0(n262), .Y(n177) );
  OR4X1M U219 ( .A(n180), .B(n179), .C(n178), .D(n177), .Y(N26) );
  AOI22X1M U220 ( .A0(regArr_10__1_), .A1(n274), .B0(regArr_11__1_), .B1(n273), 
        .Y(n182) );
  AOI22X1M U221 ( .A0(regArr_8__1_), .A1(n276), .B0(regArr_9__1_), .B1(n275), 
        .Y(n181) );
  AOI21X1M U222 ( .A0(n182), .A1(n181), .B0(n253), .Y(n192) );
  AOI22X1M U223 ( .A0(regArr_14__1_), .A1(n274), .B0(regArr_15__1_), .B1(n273), 
        .Y(n184) );
  AOI22X1M U224 ( .A0(regArr_12__1_), .A1(n276), .B0(regArr_13__1_), .B1(n275), 
        .Y(n183) );
  AOI21X1M U225 ( .A0(n184), .A1(n183), .B0(n256), .Y(n191) );
  AOI22X1M U226 ( .A0(REG2[1]), .A1(n274), .B0(REG3[1]), .B1(n273), .Y(n186)
         );
  AOI22X1M U227 ( .A0(REG0[1]), .A1(n276), .B0(REG1[1]), .B1(n275), .Y(n185)
         );
  AOI21X1M U228 ( .A0(n186), .A1(n185), .B0(n259), .Y(n190) );
  AOI22X1M U229 ( .A0(regArr_6__1_), .A1(n274), .B0(regArr_7__1_), .B1(n273), 
        .Y(n188) );
  AOI22X1M U230 ( .A0(regArr_4__1_), .A1(n276), .B0(regArr_5__1_), .B1(n275), 
        .Y(n187) );
  AOI21X1M U231 ( .A0(n188), .A1(n187), .B0(n262), .Y(n189) );
  OR4X1M U232 ( .A(n192), .B(n191), .C(n190), .D(n189), .Y(N25) );
  AOI22X1M U233 ( .A0(regArr_10__2_), .A1(n274), .B0(regArr_11__2_), .B1(n273), 
        .Y(n194) );
  AOI22X1M U234 ( .A0(regArr_8__2_), .A1(n276), .B0(regArr_9__2_), .B1(n275), 
        .Y(n193) );
  AOI21X1M U235 ( .A0(n194), .A1(n193), .B0(n253), .Y(n204) );
  AOI22X1M U236 ( .A0(regArr_14__2_), .A1(n274), .B0(regArr_15__2_), .B1(n273), 
        .Y(n196) );
  AOI22X1M U237 ( .A0(regArr_12__2_), .A1(n276), .B0(regArr_13__2_), .B1(n275), 
        .Y(n195) );
  AOI21X1M U238 ( .A0(n196), .A1(n195), .B0(n256), .Y(n203) );
  AOI22X1M U239 ( .A0(REG2[2]), .A1(n274), .B0(REG3[2]), .B1(n273), .Y(n198)
         );
  AOI22X1M U240 ( .A0(REG0[2]), .A1(n276), .B0(REG1[2]), .B1(n275), .Y(n197)
         );
  AOI21X1M U241 ( .A0(n198), .A1(n197), .B0(n259), .Y(n202) );
  AOI22X1M U242 ( .A0(regArr_6__2_), .A1(n274), .B0(regArr_7__2_), .B1(n273), 
        .Y(n200) );
  AOI22X1M U243 ( .A0(regArr_4__2_), .A1(n276), .B0(regArr_5__2_), .B1(n275), 
        .Y(n199) );
  AOI21X1M U244 ( .A0(n200), .A1(n199), .B0(n262), .Y(n201) );
  OR4X1M U245 ( .A(n204), .B(n203), .C(n202), .D(n201), .Y(N24) );
  AOI22X1M U246 ( .A0(regArr_10__3_), .A1(n274), .B0(regArr_11__3_), .B1(n273), 
        .Y(n206) );
  AOI22X1M U247 ( .A0(regArr_8__3_), .A1(n276), .B0(regArr_9__3_), .B1(n275), 
        .Y(n205) );
  AOI21X1M U248 ( .A0(n206), .A1(n205), .B0(n253), .Y(n216) );
  AOI22X1M U249 ( .A0(regArr_14__3_), .A1(n274), .B0(regArr_15__3_), .B1(n273), 
        .Y(n208) );
  AOI22X1M U250 ( .A0(regArr_12__3_), .A1(n276), .B0(regArr_13__3_), .B1(n275), 
        .Y(n207) );
  AOI21X1M U251 ( .A0(n208), .A1(n207), .B0(n256), .Y(n215) );
  AOI22X1M U252 ( .A0(REG2[3]), .A1(n274), .B0(REG3[3]), .B1(n273), .Y(n210)
         );
  AOI22X1M U253 ( .A0(REG0[3]), .A1(n276), .B0(REG1[3]), .B1(n275), .Y(n209)
         );
  AOI21X1M U254 ( .A0(n210), .A1(n209), .B0(n259), .Y(n214) );
  AOI22X1M U255 ( .A0(regArr_6__3_), .A1(n274), .B0(regArr_7__3_), .B1(n273), 
        .Y(n212) );
  AOI22X1M U256 ( .A0(regArr_4__3_), .A1(n276), .B0(regArr_5__3_), .B1(n275), 
        .Y(n211) );
  AOI21X1M U257 ( .A0(n212), .A1(n211), .B0(n262), .Y(n213) );
  OR4X1M U258 ( .A(n216), .B(n215), .C(n214), .D(n213), .Y(N23) );
  AOI22X1M U259 ( .A0(regArr_10__4_), .A1(n274), .B0(regArr_11__4_), .B1(n273), 
        .Y(n218) );
  AOI22X1M U260 ( .A0(regArr_8__4_), .A1(n276), .B0(regArr_9__4_), .B1(n275), 
        .Y(n217) );
  AOI21X1M U261 ( .A0(n218), .A1(n217), .B0(n253), .Y(n228) );
  AOI22X1M U262 ( .A0(regArr_14__4_), .A1(n274), .B0(regArr_15__4_), .B1(n273), 
        .Y(n220) );
  AOI22X1M U263 ( .A0(regArr_12__4_), .A1(n276), .B0(regArr_13__4_), .B1(n275), 
        .Y(n219) );
  AOI21X1M U264 ( .A0(n220), .A1(n219), .B0(n256), .Y(n227) );
  AOI22X1M U265 ( .A0(REG2[4]), .A1(n274), .B0(REG3[4]), .B1(n273), .Y(n222)
         );
  AOI22X1M U266 ( .A0(REG0[4]), .A1(n276), .B0(REG1[4]), .B1(n275), .Y(n221)
         );
  AOI21X1M U267 ( .A0(n222), .A1(n221), .B0(n259), .Y(n226) );
  AOI22X1M U268 ( .A0(regArr_6__4_), .A1(n274), .B0(regArr_7__4_), .B1(n273), 
        .Y(n224) );
  AOI22X1M U269 ( .A0(regArr_4__4_), .A1(n276), .B0(regArr_5__4_), .B1(n275), 
        .Y(n223) );
  AOI21X1M U270 ( .A0(n224), .A1(n223), .B0(n262), .Y(n225) );
  OR4X1M U271 ( .A(n228), .B(n227), .C(n226), .D(n225), .Y(N22) );
  AOI22X1M U272 ( .A0(regArr_10__5_), .A1(n274), .B0(regArr_11__5_), .B1(n273), 
        .Y(n230) );
  AOI22X1M U273 ( .A0(regArr_8__5_), .A1(n276), .B0(regArr_9__5_), .B1(n275), 
        .Y(n229) );
  AOI21X1M U274 ( .A0(n230), .A1(n229), .B0(n253), .Y(n240) );
  AOI22X1M U275 ( .A0(regArr_14__5_), .A1(n274), .B0(regArr_15__5_), .B1(n273), 
        .Y(n232) );
  AOI22X1M U276 ( .A0(regArr_12__5_), .A1(n276), .B0(regArr_13__5_), .B1(n275), 
        .Y(n231) );
  AOI21X1M U277 ( .A0(n232), .A1(n231), .B0(n256), .Y(n239) );
  AOI22X1M U278 ( .A0(REG2[5]), .A1(n274), .B0(REG3[5]), .B1(n273), .Y(n234)
         );
  AOI22X1M U279 ( .A0(REG0[5]), .A1(n276), .B0(REG1[5]), .B1(n275), .Y(n233)
         );
  AOI21X1M U280 ( .A0(n234), .A1(n233), .B0(n259), .Y(n238) );
  AOI22X1M U281 ( .A0(regArr_6__5_), .A1(n274), .B0(regArr_7__5_), .B1(n273), 
        .Y(n236) );
  AOI22X1M U282 ( .A0(regArr_4__5_), .A1(n276), .B0(regArr_5__5_), .B1(n275), 
        .Y(n235) );
  AOI21X1M U283 ( .A0(n236), .A1(n235), .B0(n262), .Y(n237) );
  OR4X1M U284 ( .A(n240), .B(n239), .C(n238), .D(n237), .Y(N21) );
  AOI22X1M U285 ( .A0(regArr_10__6_), .A1(n274), .B0(regArr_11__6_), .B1(n273), 
        .Y(n242) );
  AOI22X1M U286 ( .A0(regArr_8__6_), .A1(n276), .B0(regArr_9__6_), .B1(n275), 
        .Y(n241) );
  AOI21X1M U287 ( .A0(n242), .A1(n241), .B0(n253), .Y(n252) );
  AOI22X1M U288 ( .A0(regArr_14__6_), .A1(n274), .B0(regArr_15__6_), .B1(n273), 
        .Y(n244) );
  AOI22X1M U289 ( .A0(regArr_12__6_), .A1(n276), .B0(regArr_13__6_), .B1(n275), 
        .Y(n243) );
  AOI21X1M U290 ( .A0(n244), .A1(n243), .B0(n256), .Y(n251) );
  AOI22X1M U291 ( .A0(REG2[6]), .A1(n274), .B0(REG3[6]), .B1(n273), .Y(n246)
         );
  AOI22X1M U292 ( .A0(REG0[6]), .A1(n276), .B0(REG1[6]), .B1(n275), .Y(n245)
         );
  AOI21X1M U293 ( .A0(n246), .A1(n245), .B0(n259), .Y(n250) );
  AOI22X1M U294 ( .A0(regArr_6__6_), .A1(n274), .B0(regArr_7__6_), .B1(n273), 
        .Y(n248) );
  AOI22X1M U295 ( .A0(regArr_4__6_), .A1(n276), .B0(regArr_5__6_), .B1(n275), 
        .Y(n247) );
  AOI21X1M U296 ( .A0(n248), .A1(n247), .B0(n262), .Y(n249) );
  OR4X1M U297 ( .A(n252), .B(n251), .C(n250), .D(n249), .Y(N20) );
  AOI22X1M U298 ( .A0(regArr_10__7_), .A1(n274), .B0(regArr_11__7_), .B1(n273), 
        .Y(n255) );
  AOI22X1M U299 ( .A0(regArr_8__7_), .A1(n276), .B0(regArr_9__7_), .B1(n275), 
        .Y(n254) );
  AOI21X1M U300 ( .A0(n255), .A1(n254), .B0(n253), .Y(n268) );
  AOI22X1M U301 ( .A0(regArr_14__7_), .A1(n274), .B0(regArr_15__7_), .B1(n273), 
        .Y(n258) );
  AOI22X1M U302 ( .A0(regArr_12__7_), .A1(n276), .B0(regArr_13__7_), .B1(n275), 
        .Y(n257) );
  AOI21X1M U303 ( .A0(n258), .A1(n257), .B0(n256), .Y(n267) );
  AOI22X1M U304 ( .A0(REG2[7]), .A1(n274), .B0(REG3[7]), .B1(n273), .Y(n261)
         );
  AOI22X1M U305 ( .A0(REG0[7]), .A1(n276), .B0(REG1[7]), .B1(n275), .Y(n260)
         );
  AOI21X1M U306 ( .A0(n261), .A1(n260), .B0(n259), .Y(n266) );
  AOI22X1M U307 ( .A0(regArr_6__7_), .A1(n274), .B0(regArr_7__7_), .B1(n273), 
        .Y(n264) );
  AOI22X1M U308 ( .A0(regArr_4__7_), .A1(n276), .B0(regArr_5__7_), .B1(n275), 
        .Y(n263) );
  AOI21X1M U309 ( .A0(n264), .A1(n263), .B0(n262), .Y(n265) );
  OR4X1M U310 ( .A(n268), .B(n267), .C(n266), .D(n265), .Y(N19) );
endmodule


module ALU_DW_div_uns_0 ( a, b, quotient, remainder, divide_by_0 );
  input [7:0] a;
  input [7:0] b;
  output [7:0] quotient;
  output [7:0] remainder;
  output divide_by_0;
  wire   u_div_SumTmp_1__0_, u_div_SumTmp_1__1_, u_div_SumTmp_1__2_,
         u_div_SumTmp_1__3_, u_div_SumTmp_1__4_, u_div_SumTmp_1__5_,
         u_div_SumTmp_1__6_, u_div_SumTmp_2__0_, u_div_SumTmp_2__1_,
         u_div_SumTmp_2__2_, u_div_SumTmp_2__3_, u_div_SumTmp_2__4_,
         u_div_SumTmp_2__5_, u_div_SumTmp_3__0_, u_div_SumTmp_3__1_,
         u_div_SumTmp_3__2_, u_div_SumTmp_3__3_, u_div_SumTmp_3__4_,
         u_div_SumTmp_4__0_, u_div_SumTmp_4__1_, u_div_SumTmp_4__2_,
         u_div_SumTmp_4__3_, u_div_SumTmp_5__0_, u_div_SumTmp_5__1_,
         u_div_SumTmp_5__2_, u_div_SumTmp_6__0_, u_div_SumTmp_6__1_,
         u_div_SumTmp_7__0_, u_div_CryTmp_0__1_, u_div_CryTmp_0__2_,
         u_div_CryTmp_0__3_, u_div_CryTmp_0__4_, u_div_CryTmp_0__5_,
         u_div_CryTmp_0__6_, u_div_CryTmp_0__7_, u_div_CryTmp_1__1_,
         u_div_CryTmp_1__2_, u_div_CryTmp_1__3_, u_div_CryTmp_1__4_,
         u_div_CryTmp_1__5_, u_div_CryTmp_1__6_, u_div_CryTmp_1__7_,
         u_div_CryTmp_2__1_, u_div_CryTmp_2__2_, u_div_CryTmp_2__3_,
         u_div_CryTmp_2__4_, u_div_CryTmp_2__5_, u_div_CryTmp_2__6_,
         u_div_CryTmp_3__1_, u_div_CryTmp_3__2_, u_div_CryTmp_3__3_,
         u_div_CryTmp_3__4_, u_div_CryTmp_3__5_, u_div_CryTmp_4__1_,
         u_div_CryTmp_4__2_, u_div_CryTmp_4__3_, u_div_CryTmp_4__4_,
         u_div_CryTmp_5__1_, u_div_CryTmp_5__2_, u_div_CryTmp_5__3_,
         u_div_CryTmp_6__1_, u_div_CryTmp_6__2_, u_div_CryTmp_7__1_,
         u_div_PartRem_1__1_, u_div_PartRem_1__2_, u_div_PartRem_1__3_,
         u_div_PartRem_1__4_, u_div_PartRem_1__5_, u_div_PartRem_1__6_,
         u_div_PartRem_1__7_, u_div_PartRem_2__1_, u_div_PartRem_2__2_,
         u_div_PartRem_2__3_, u_div_PartRem_2__4_, u_div_PartRem_2__5_,
         u_div_PartRem_2__6_, u_div_PartRem_3__1_, u_div_PartRem_3__2_,
         u_div_PartRem_3__3_, u_div_PartRem_3__4_, u_div_PartRem_3__5_,
         u_div_PartRem_4__1_, u_div_PartRem_4__2_, u_div_PartRem_4__3_,
         u_div_PartRem_4__4_, u_div_PartRem_5__1_, u_div_PartRem_5__2_,
         u_div_PartRem_5__3_, u_div_PartRem_6__1_, u_div_PartRem_6__2_,
         u_div_PartRem_7__1_, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11,
         n12, n13, n14, n15, n16, n17, n18, n19, n20, n21;

  ADDFX2M u_div_u_fa_PartRem_0_1_6 ( .A(u_div_PartRem_2__6_), .B(n12), .CI(
        u_div_CryTmp_1__6_), .CO(u_div_CryTmp_1__7_), .S(u_div_SumTmp_1__6_)
         );
  ADDFX2M u_div_u_fa_PartRem_0_2_5 ( .A(u_div_PartRem_3__5_), .B(n13), .CI(
        u_div_CryTmp_2__5_), .CO(u_div_CryTmp_2__6_), .S(u_div_SumTmp_2__5_)
         );
  ADDFX2M u_div_u_fa_PartRem_0_4_3 ( .A(u_div_PartRem_5__3_), .B(n15), .CI(
        u_div_CryTmp_4__3_), .CO(u_div_CryTmp_4__4_), .S(u_div_SumTmp_4__3_)
         );
  ADDFX2M u_div_u_fa_PartRem_0_5_2 ( .A(u_div_PartRem_6__2_), .B(n16), .CI(
        u_div_CryTmp_5__2_), .CO(u_div_CryTmp_5__3_), .S(u_div_SumTmp_5__2_)
         );
  ADDFX2M u_div_u_fa_PartRem_0_6_1 ( .A(u_div_PartRem_7__1_), .B(n17), .CI(
        u_div_CryTmp_6__1_), .CO(u_div_CryTmp_6__2_), .S(u_div_SumTmp_6__1_)
         );
  ADDFX2M u_div_u_fa_PartRem_0_3_4 ( .A(u_div_PartRem_4__4_), .B(n14), .CI(
        u_div_CryTmp_3__4_), .CO(u_div_CryTmp_3__5_), .S(u_div_SumTmp_3__4_)
         );
  ADDFX2M u_div_u_fa_PartRem_0_0_1 ( .A(u_div_PartRem_1__1_), .B(n17), .CI(
        u_div_CryTmp_0__1_), .CO(u_div_CryTmp_0__2_) );
  ADDFX2M u_div_u_fa_PartRem_0_1_1 ( .A(u_div_PartRem_2__1_), .B(n17), .CI(
        u_div_CryTmp_1__1_), .CO(u_div_CryTmp_1__2_), .S(u_div_SumTmp_1__1_)
         );
  ADDFX2M u_div_u_fa_PartRem_0_2_1 ( .A(u_div_PartRem_3__1_), .B(n17), .CI(
        u_div_CryTmp_2__1_), .CO(u_div_CryTmp_2__2_), .S(u_div_SumTmp_2__1_)
         );
  ADDFX2M u_div_u_fa_PartRem_0_3_1 ( .A(u_div_PartRem_4__1_), .B(n17), .CI(
        u_div_CryTmp_3__1_), .CO(u_div_CryTmp_3__2_), .S(u_div_SumTmp_3__1_)
         );
  ADDFX2M u_div_u_fa_PartRem_0_4_1 ( .A(u_div_PartRem_5__1_), .B(n17), .CI(
        u_div_CryTmp_4__1_), .CO(u_div_CryTmp_4__2_), .S(u_div_SumTmp_4__1_)
         );
  ADDFX2M u_div_u_fa_PartRem_0_5_1 ( .A(u_div_PartRem_6__1_), .B(n17), .CI(
        u_div_CryTmp_5__1_), .CO(u_div_CryTmp_5__2_), .S(u_div_SumTmp_5__1_)
         );
  ADDFX2M u_div_u_fa_PartRem_0_0_6 ( .A(u_div_PartRem_1__6_), .B(n12), .CI(
        u_div_CryTmp_0__6_), .CO(u_div_CryTmp_0__7_) );
  ADDFX2M u_div_u_fa_PartRem_0_0_7 ( .A(u_div_PartRem_1__7_), .B(n11), .CI(
        u_div_CryTmp_0__7_), .CO(quotient[0]) );
  ADDFX2M u_div_u_fa_PartRem_0_0_4 ( .A(u_div_PartRem_1__4_), .B(n14), .CI(
        u_div_CryTmp_0__4_), .CO(u_div_CryTmp_0__5_) );
  ADDFX2M u_div_u_fa_PartRem_0_0_5 ( .A(u_div_PartRem_1__5_), .B(n13), .CI(
        u_div_CryTmp_0__5_), .CO(u_div_CryTmp_0__6_) );
  ADDFX2M u_div_u_fa_PartRem_0_1_5 ( .A(u_div_PartRem_2__5_), .B(n13), .CI(
        u_div_CryTmp_1__5_), .CO(u_div_CryTmp_1__6_), .S(u_div_SumTmp_1__5_)
         );
  ADDFX2M u_div_u_fa_PartRem_0_1_4 ( .A(u_div_PartRem_2__4_), .B(n14), .CI(
        u_div_CryTmp_1__4_), .CO(u_div_CryTmp_1__5_), .S(u_div_SumTmp_1__4_)
         );
  ADDFX2M u_div_u_fa_PartRem_0_0_2 ( .A(u_div_PartRem_1__2_), .B(n16), .CI(
        u_div_CryTmp_0__2_), .CO(u_div_CryTmp_0__3_) );
  ADDFX2M u_div_u_fa_PartRem_0_0_3 ( .A(u_div_PartRem_1__3_), .B(n15), .CI(
        u_div_CryTmp_0__3_), .CO(u_div_CryTmp_0__4_) );
  ADDFX2M u_div_u_fa_PartRem_0_2_4 ( .A(u_div_PartRem_3__4_), .B(n14), .CI(
        u_div_CryTmp_2__4_), .CO(u_div_CryTmp_2__5_), .S(u_div_SumTmp_2__4_)
         );
  ADDFX2M u_div_u_fa_PartRem_0_1_3 ( .A(u_div_PartRem_2__3_), .B(n15), .CI(
        u_div_CryTmp_1__3_), .CO(u_div_CryTmp_1__4_), .S(u_div_SumTmp_1__3_)
         );
  ADDFX2M u_div_u_fa_PartRem_0_2_3 ( .A(u_div_PartRem_3__3_), .B(n15), .CI(
        u_div_CryTmp_2__3_), .CO(u_div_CryTmp_2__4_), .S(u_div_SumTmp_2__3_)
         );
  ADDFX2M u_div_u_fa_PartRem_0_1_2 ( .A(u_div_PartRem_2__2_), .B(n16), .CI(
        u_div_CryTmp_1__2_), .CO(u_div_CryTmp_1__3_), .S(u_div_SumTmp_1__2_)
         );
  ADDFX2M u_div_u_fa_PartRem_0_3_3 ( .A(u_div_PartRem_4__3_), .B(n15), .CI(
        u_div_CryTmp_3__3_), .CO(u_div_CryTmp_3__4_), .S(u_div_SumTmp_3__3_)
         );
  ADDFX2M u_div_u_fa_PartRem_0_2_2 ( .A(u_div_PartRem_3__2_), .B(n16), .CI(
        u_div_CryTmp_2__2_), .CO(u_div_CryTmp_2__3_), .S(u_div_SumTmp_2__2_)
         );
  ADDFX2M u_div_u_fa_PartRem_0_3_2 ( .A(u_div_PartRem_4__2_), .B(n16), .CI(
        u_div_CryTmp_3__2_), .CO(u_div_CryTmp_3__3_), .S(u_div_SumTmp_3__2_)
         );
  ADDFX2M u_div_u_fa_PartRem_0_4_2 ( .A(u_div_PartRem_5__2_), .B(n16), .CI(
        u_div_CryTmp_4__2_), .CO(u_div_CryTmp_4__3_), .S(u_div_SumTmp_4__2_)
         );
  XNOR2X2M U1 ( .A(n18), .B(a[7]), .Y(u_div_SumTmp_7__0_) );
  XNOR2X2M U2 ( .A(n18), .B(a[6]), .Y(u_div_SumTmp_6__0_) );
  XNOR2X2M U3 ( .A(n18), .B(a[5]), .Y(u_div_SumTmp_5__0_) );
  XNOR2X2M U4 ( .A(n18), .B(a[4]), .Y(u_div_SumTmp_4__0_) );
  XNOR2X2M U5 ( .A(n18), .B(a[3]), .Y(u_div_SumTmp_3__0_) );
  XNOR2X2M U6 ( .A(n18), .B(a[2]), .Y(u_div_SumTmp_2__0_) );
  INVX2M U7 ( .A(b[0]), .Y(n18) );
  OR2X2M U8 ( .A(n18), .B(a[7]), .Y(u_div_CryTmp_7__1_) );
  INVX2M U9 ( .A(b[1]), .Y(n17) );
  NAND2X2M U10 ( .A(n3), .B(n4), .Y(u_div_CryTmp_5__1_) );
  INVX2M U11 ( .A(a[5]), .Y(n4) );
  INVX2M U12 ( .A(n18), .Y(n3) );
  NAND2X2M U13 ( .A(n5), .B(n6), .Y(u_div_CryTmp_4__1_) );
  INVX2M U14 ( .A(a[4]), .Y(n6) );
  INVX2M U15 ( .A(n18), .Y(n5) );
  NAND2X2M U16 ( .A(n5), .B(n7), .Y(u_div_CryTmp_3__1_) );
  INVX2M U17 ( .A(a[3]), .Y(n7) );
  NAND2X2M U18 ( .A(n5), .B(n8), .Y(u_div_CryTmp_2__1_) );
  INVX2M U19 ( .A(a[2]), .Y(n8) );
  NAND2X2M U20 ( .A(n5), .B(n9), .Y(u_div_CryTmp_1__1_) );
  INVX2M U21 ( .A(a[1]), .Y(n9) );
  NAND2X2M U22 ( .A(n5), .B(n10), .Y(u_div_CryTmp_0__1_) );
  INVX2M U23 ( .A(a[0]), .Y(n10) );
  NAND2X2M U24 ( .A(n1), .B(n2), .Y(u_div_CryTmp_6__1_) );
  INVX2M U25 ( .A(a[6]), .Y(n2) );
  INVX2M U26 ( .A(n18), .Y(n1) );
  XNOR2X2M U27 ( .A(n18), .B(a[1]), .Y(u_div_SumTmp_1__0_) );
  INVX2M U28 ( .A(b[7]), .Y(n11) );
  INVX2M U29 ( .A(b[2]), .Y(n16) );
  INVX2M U30 ( .A(b[3]), .Y(n15) );
  INVX2M U31 ( .A(b[4]), .Y(n14) );
  INVX2M U32 ( .A(b[5]), .Y(n13) );
  INVX2M U33 ( .A(b[6]), .Y(n12) );
  CLKMX2X2M U34 ( .A(u_div_PartRem_2__6_), .B(u_div_SumTmp_1__6_), .S0(
        quotient[1]), .Y(u_div_PartRem_1__7_) );
  CLKMX2X2M U35 ( .A(u_div_PartRem_3__5_), .B(u_div_SumTmp_2__5_), .S0(
        quotient[2]), .Y(u_div_PartRem_2__6_) );
  CLKMX2X2M U36 ( .A(u_div_PartRem_4__4_), .B(u_div_SumTmp_3__4_), .S0(
        quotient[3]), .Y(u_div_PartRem_3__5_) );
  CLKMX2X2M U37 ( .A(u_div_PartRem_5__3_), .B(u_div_SumTmp_4__3_), .S0(
        quotient[4]), .Y(u_div_PartRem_4__4_) );
  CLKMX2X2M U38 ( .A(u_div_PartRem_6__2_), .B(u_div_SumTmp_5__2_), .S0(
        quotient[5]), .Y(u_div_PartRem_5__3_) );
  CLKMX2X2M U39 ( .A(u_div_PartRem_7__1_), .B(u_div_SumTmp_6__1_), .S0(
        quotient[6]), .Y(u_div_PartRem_6__2_) );
  CLKMX2X2M U40 ( .A(a[7]), .B(u_div_SumTmp_7__0_), .S0(quotient[7]), .Y(
        u_div_PartRem_7__1_) );
  CLKMX2X2M U41 ( .A(u_div_PartRem_2__5_), .B(u_div_SumTmp_1__5_), .S0(
        quotient[1]), .Y(u_div_PartRem_1__6_) );
  CLKMX2X2M U42 ( .A(u_div_PartRem_3__4_), .B(u_div_SumTmp_2__4_), .S0(
        quotient[2]), .Y(u_div_PartRem_2__5_) );
  CLKMX2X2M U43 ( .A(u_div_PartRem_4__3_), .B(u_div_SumTmp_3__3_), .S0(
        quotient[3]), .Y(u_div_PartRem_3__4_) );
  CLKMX2X2M U44 ( .A(u_div_PartRem_5__2_), .B(u_div_SumTmp_4__2_), .S0(
        quotient[4]), .Y(u_div_PartRem_4__3_) );
  CLKMX2X2M U45 ( .A(u_div_PartRem_6__1_), .B(u_div_SumTmp_5__1_), .S0(
        quotient[5]), .Y(u_div_PartRem_5__2_) );
  CLKMX2X2M U46 ( .A(a[6]), .B(u_div_SumTmp_6__0_), .S0(quotient[6]), .Y(
        u_div_PartRem_6__1_) );
  CLKMX2X2M U47 ( .A(u_div_PartRem_2__4_), .B(u_div_SumTmp_1__4_), .S0(
        quotient[1]), .Y(u_div_PartRem_1__5_) );
  CLKMX2X2M U48 ( .A(u_div_PartRem_3__3_), .B(u_div_SumTmp_2__3_), .S0(
        quotient[2]), .Y(u_div_PartRem_2__4_) );
  CLKMX2X2M U49 ( .A(u_div_PartRem_4__2_), .B(u_div_SumTmp_3__2_), .S0(
        quotient[3]), .Y(u_div_PartRem_3__3_) );
  CLKMX2X2M U50 ( .A(u_div_PartRem_5__1_), .B(u_div_SumTmp_4__1_), .S0(
        quotient[4]), .Y(u_div_PartRem_4__2_) );
  CLKMX2X2M U51 ( .A(a[5]), .B(u_div_SumTmp_5__0_), .S0(quotient[5]), .Y(
        u_div_PartRem_5__1_) );
  CLKMX2X2M U52 ( .A(u_div_PartRem_2__3_), .B(u_div_SumTmp_1__3_), .S0(
        quotient[1]), .Y(u_div_PartRem_1__4_) );
  CLKMX2X2M U53 ( .A(u_div_PartRem_3__2_), .B(u_div_SumTmp_2__2_), .S0(
        quotient[2]), .Y(u_div_PartRem_2__3_) );
  CLKMX2X2M U54 ( .A(u_div_PartRem_4__1_), .B(u_div_SumTmp_3__1_), .S0(
        quotient[3]), .Y(u_div_PartRem_3__2_) );
  CLKMX2X2M U55 ( .A(a[4]), .B(u_div_SumTmp_4__0_), .S0(quotient[4]), .Y(
        u_div_PartRem_4__1_) );
  CLKMX2X2M U56 ( .A(u_div_PartRem_2__2_), .B(u_div_SumTmp_1__2_), .S0(
        quotient[1]), .Y(u_div_PartRem_1__3_) );
  CLKMX2X2M U57 ( .A(u_div_PartRem_3__1_), .B(u_div_SumTmp_2__1_), .S0(
        quotient[2]), .Y(u_div_PartRem_2__2_) );
  CLKMX2X2M U58 ( .A(a[3]), .B(u_div_SumTmp_3__0_), .S0(quotient[3]), .Y(
        u_div_PartRem_3__1_) );
  CLKMX2X2M U59 ( .A(u_div_PartRem_2__1_), .B(u_div_SumTmp_1__1_), .S0(
        quotient[1]), .Y(u_div_PartRem_1__2_) );
  CLKMX2X2M U60 ( .A(a[2]), .B(u_div_SumTmp_2__0_), .S0(quotient[2]), .Y(
        u_div_PartRem_2__1_) );
  CLKMX2X2M U61 ( .A(a[1]), .B(u_div_SumTmp_1__0_), .S0(quotient[1]), .Y(
        u_div_PartRem_1__1_) );
  AND4X1M U62 ( .A(u_div_CryTmp_7__1_), .B(n19), .C(n17), .D(n16), .Y(
        quotient[7]) );
  AND3X1M U63 ( .A(n19), .B(n16), .C(u_div_CryTmp_6__2_), .Y(quotient[6]) );
  AND2X1M U64 ( .A(u_div_CryTmp_5__3_), .B(n19), .Y(quotient[5]) );
  AND2X1M U65 ( .A(n20), .B(n15), .Y(n19) );
  AND2X1M U66 ( .A(u_div_CryTmp_4__4_), .B(n20), .Y(quotient[4]) );
  AND3X1M U67 ( .A(n21), .B(n14), .C(n13), .Y(n20) );
  AND3X1M U68 ( .A(n21), .B(n13), .C(u_div_CryTmp_3__5_), .Y(quotient[3]) );
  AND2X1M U69 ( .A(u_div_CryTmp_2__6_), .B(n21), .Y(quotient[2]) );
  NOR2X1M U70 ( .A(b[6]), .B(b[7]), .Y(n21) );
  AND2X1M U71 ( .A(u_div_CryTmp_1__7_), .B(n11), .Y(quotient[1]) );
endmodule


module ALU_DW01_sub_0 ( A, B, CI, DIFF, CO );
  input [8:0] A;
  input [8:0] B;
  output [8:0] DIFF;
  input CI;
  output CO;
  wire   n1, n2, n3, n4, n5, n6, n7, n8, n9;
  wire   [8:1] carry;

  ADDFX2M U2_6 ( .A(A[6]), .B(n3), .CI(carry[6]), .CO(carry[7]), .S(DIFF[6])
         );
  ADDFX2M U2_5 ( .A(A[5]), .B(n4), .CI(carry[5]), .CO(carry[6]), .S(DIFF[5])
         );
  ADDFX2M U2_4 ( .A(A[4]), .B(n5), .CI(carry[4]), .CO(carry[5]), .S(DIFF[4])
         );
  ADDFX2M U2_3 ( .A(A[3]), .B(n6), .CI(carry[3]), .CO(carry[4]), .S(DIFF[3])
         );
  ADDFX2M U2_2 ( .A(A[2]), .B(n7), .CI(carry[2]), .CO(carry[3]), .S(DIFF[2])
         );
  ADDFX2M U2_7 ( .A(A[7]), .B(n2), .CI(carry[7]), .CO(carry[8]), .S(DIFF[7])
         );
  ADDFX2M U2_1 ( .A(A[1]), .B(n8), .CI(carry[1]), .CO(carry[2]), .S(DIFF[1])
         );
  INVX2M U1 ( .A(B[1]), .Y(n8) );
  NAND2X2M U2 ( .A(B[0]), .B(n1), .Y(carry[1]) );
  INVX2M U3 ( .A(A[0]), .Y(n1) );
  INVX2M U4 ( .A(B[7]), .Y(n2) );
  INVX2M U5 ( .A(B[0]), .Y(n9) );
  XNOR2X2M U6 ( .A(n9), .B(A[0]), .Y(DIFF[0]) );
  INVX2M U7 ( .A(B[2]), .Y(n7) );
  INVX2M U8 ( .A(B[3]), .Y(n6) );
  INVX2M U9 ( .A(B[4]), .Y(n5) );
  INVX2M U10 ( .A(B[5]), .Y(n4) );
  INVX2M U11 ( .A(B[6]), .Y(n3) );
  CLKINVX1M U12 ( .A(carry[8]), .Y(DIFF[8]) );
endmodule


module ALU_DW01_add_0 ( A, B, CI, SUM, CO );
  input [8:0] A;
  input [8:0] B;
  output [8:0] SUM;
  input CI;
  output CO;
  wire   n1;
  wire   [7:2] carry;

  ADDFX2M U1_6 ( .A(A[6]), .B(B[6]), .CI(carry[6]), .CO(carry[7]), .S(SUM[6])
         );
  ADDFX2M U1_5 ( .A(A[5]), .B(B[5]), .CI(carry[5]), .CO(carry[6]), .S(SUM[5])
         );
  ADDFX2M U1_4 ( .A(A[4]), .B(B[4]), .CI(carry[4]), .CO(carry[5]), .S(SUM[4])
         );
  ADDFX2M U1_3 ( .A(A[3]), .B(B[3]), .CI(carry[3]), .CO(carry[4]), .S(SUM[3])
         );
  ADDFX2M U1_2 ( .A(A[2]), .B(B[2]), .CI(carry[2]), .CO(carry[3]), .S(SUM[2])
         );
  ADDFX2M U1_7 ( .A(A[7]), .B(B[7]), .CI(carry[7]), .CO(SUM[8]), .S(SUM[7]) );
  ADDFX2M U1_1 ( .A(A[1]), .B(B[1]), .CI(n1), .CO(carry[2]), .S(SUM[1]) );
  AND2X2M U1 ( .A(B[0]), .B(A[0]), .Y(n1) );
  CLKXOR2X2M U2 ( .A(B[0]), .B(A[0]), .Y(SUM[0]) );
endmodule


module ALU_DW01_add_1 ( A, B, CI, SUM, CO );
  input [13:0] A;
  input [13:0] B;
  output [13:0] SUM;
  input CI;
  output CO;
  wire   n1, n8, n9, n10, n11, n12, n13, n14, n15, n16, n17, n18, n19, n20,
         n21, n22, n23, n24, n25, n26, n27;

  AOI21BX2M U2 ( .A0(n18), .A1(A[12]), .B0N(n19), .Y(n1) );
  NAND2X2M U3 ( .A(A[7]), .B(B[7]), .Y(n15) );
  XNOR2X2M U4 ( .A(B[13]), .B(n1), .Y(SUM[13]) );
  XNOR2X2M U5 ( .A(A[7]), .B(n8), .Y(SUM[7]) );
  INVX2M U6 ( .A(B[7]), .Y(n8) );
  INVX2M U7 ( .A(n9), .Y(SUM[6]) );
  INVX2M U8 ( .A(A[6]), .Y(n9) );
  BUFX2M U9 ( .A(A[0]), .Y(SUM[0]) );
  BUFX2M U10 ( .A(A[1]), .Y(SUM[1]) );
  BUFX2M U11 ( .A(A[2]), .Y(SUM[2]) );
  BUFX2M U12 ( .A(A[3]), .Y(SUM[3]) );
  BUFX2M U13 ( .A(A[4]), .Y(SUM[4]) );
  BUFX2M U14 ( .A(A[5]), .Y(SUM[5]) );
  XNOR2X1M U15 ( .A(n10), .B(n11), .Y(SUM[9]) );
  NOR2X1M U16 ( .A(n12), .B(n13), .Y(n11) );
  CLKXOR2X2M U17 ( .A(n14), .B(n15), .Y(SUM[8]) );
  NAND2BX1M U18 ( .AN(n16), .B(n17), .Y(n14) );
  OAI21X1M U19 ( .A0(A[12]), .A1(n18), .B0(B[12]), .Y(n19) );
  XOR3XLM U20 ( .A(B[12]), .B(A[12]), .C(n18), .Y(SUM[12]) );
  OAI21BX1M U21 ( .A0(n20), .A1(n21), .B0N(n22), .Y(n18) );
  XNOR2X1M U22 ( .A(n21), .B(n23), .Y(SUM[11]) );
  NOR2X1M U23 ( .A(n22), .B(n20), .Y(n23) );
  NOR2X1M U24 ( .A(B[11]), .B(A[11]), .Y(n20) );
  AND2X1M U25 ( .A(B[11]), .B(A[11]), .Y(n22) );
  OA21X1M U26 ( .A0(n24), .A1(n25), .B0(n26), .Y(n21) );
  CLKXOR2X2M U27 ( .A(n27), .B(n25), .Y(SUM[10]) );
  AOI2BB1X1M U28 ( .A0N(n10), .A1N(n13), .B0(n12), .Y(n25) );
  AND2X1M U29 ( .A(B[9]), .B(A[9]), .Y(n12) );
  NOR2X1M U30 ( .A(B[9]), .B(A[9]), .Y(n13) );
  OA21X1M U31 ( .A0(n15), .A1(n16), .B0(n17), .Y(n10) );
  CLKNAND2X2M U32 ( .A(B[8]), .B(A[8]), .Y(n17) );
  NOR2X1M U33 ( .A(B[8]), .B(A[8]), .Y(n16) );
  NAND2BX1M U34 ( .AN(n24), .B(n26), .Y(n27) );
  CLKNAND2X2M U35 ( .A(B[10]), .B(A[10]), .Y(n26) );
  NOR2X1M U36 ( .A(B[10]), .B(A[10]), .Y(n24) );
endmodule


module ALU_DW02_mult_0 ( A, B, TC, PRODUCT );
  input [7:0] A;
  input [7:0] B;
  output [15:0] PRODUCT;
  input TC;
  wire   ab_7__7_, ab_7__6_, ab_7__5_, ab_7__4_, ab_7__3_, ab_7__2_, ab_7__1_,
         ab_7__0_, ab_6__7_, ab_6__6_, ab_6__5_, ab_6__4_, ab_6__3_, ab_6__2_,
         ab_6__1_, ab_6__0_, ab_5__7_, ab_5__6_, ab_5__5_, ab_5__4_, ab_5__3_,
         ab_5__2_, ab_5__1_, ab_5__0_, ab_4__7_, ab_4__6_, ab_4__5_, ab_4__4_,
         ab_4__3_, ab_4__2_, ab_4__1_, ab_4__0_, ab_3__7_, ab_3__6_, ab_3__5_,
         ab_3__4_, ab_3__3_, ab_3__2_, ab_3__1_, ab_3__0_, ab_2__7_, ab_2__6_,
         ab_2__5_, ab_2__4_, ab_2__3_, ab_2__2_, ab_2__1_, ab_2__0_, ab_1__7_,
         ab_1__6_, ab_1__5_, ab_1__4_, ab_1__3_, ab_1__2_, ab_1__1_, ab_1__0_,
         ab_0__7_, ab_0__6_, ab_0__5_, ab_0__4_, ab_0__3_, ab_0__2_, ab_0__1_,
         CARRYB_7__6_, CARRYB_7__5_, CARRYB_7__4_, CARRYB_7__3_, CARRYB_7__2_,
         CARRYB_7__1_, CARRYB_7__0_, CARRYB_6__6_, CARRYB_6__5_, CARRYB_6__4_,
         CARRYB_6__3_, CARRYB_6__2_, CARRYB_6__1_, CARRYB_6__0_, CARRYB_5__6_,
         CARRYB_5__5_, CARRYB_5__4_, CARRYB_5__3_, CARRYB_5__2_, CARRYB_5__1_,
         CARRYB_5__0_, CARRYB_4__6_, CARRYB_4__5_, CARRYB_4__4_, CARRYB_4__3_,
         CARRYB_4__2_, CARRYB_4__1_, CARRYB_4__0_, CARRYB_3__6_, CARRYB_3__5_,
         CARRYB_3__4_, CARRYB_3__3_, CARRYB_3__2_, CARRYB_3__1_, CARRYB_3__0_,
         CARRYB_2__6_, CARRYB_2__5_, CARRYB_2__4_, CARRYB_2__3_, CARRYB_2__2_,
         CARRYB_2__1_, CARRYB_2__0_, SUMB_7__6_, SUMB_7__5_, SUMB_7__4_,
         SUMB_7__3_, SUMB_7__2_, SUMB_7__1_, SUMB_7__0_, SUMB_6__6_,
         SUMB_6__5_, SUMB_6__4_, SUMB_6__3_, SUMB_6__2_, SUMB_6__1_,
         SUMB_5__6_, SUMB_5__5_, SUMB_5__4_, SUMB_5__3_, SUMB_5__2_,
         SUMB_5__1_, SUMB_4__6_, SUMB_4__5_, SUMB_4__4_, SUMB_4__3_,
         SUMB_4__2_, SUMB_4__1_, SUMB_3__6_, SUMB_3__5_, SUMB_3__4_,
         SUMB_3__3_, SUMB_3__2_, SUMB_3__1_, SUMB_2__6_, SUMB_2__5_,
         SUMB_2__4_, SUMB_2__3_, SUMB_2__2_, SUMB_2__1_, SUMB_1__6_,
         SUMB_1__5_, SUMB_1__4_, SUMB_1__3_, SUMB_1__2_, SUMB_1__1_, A1_12_,
         A1_11_, A1_10_, A1_9_, A1_8_, A1_7_, A1_6_, A1_4_, A1_3_, A1_2_,
         A1_1_, A1_0_, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14,
         n15, n16, n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28,
         n29, n30, n31, n32, n33, n34, n35, n36, n37, n38;

  ALU_DW01_add_1 FS_1 ( .A({1'b0, A1_12_, A1_11_, A1_10_, A1_9_, A1_8_, A1_7_, 
        A1_6_, SUMB_7__0_, A1_4_, A1_3_, A1_2_, A1_1_, A1_0_}), .B({n10, n16, 
        n13, n14, n15, n12, n11, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0}), 
        .CI(1'b0), .SUM(PRODUCT[15:2]) );
  ADDFX2M S5_6 ( .A(ab_7__6_), .B(CARRYB_6__6_), .CI(ab_6__7_), .CO(
        CARRYB_7__6_), .S(SUMB_7__6_) );
  ADDFX2M S3_6_6 ( .A(ab_6__6_), .B(CARRYB_5__6_), .CI(ab_5__7_), .CO(
        CARRYB_6__6_), .S(SUMB_6__6_) );
  ADDFX2M S2_6_5 ( .A(ab_6__5_), .B(CARRYB_5__5_), .CI(SUMB_5__6_), .CO(
        CARRYB_6__5_), .S(SUMB_6__5_) );
  ADDFX2M S3_5_6 ( .A(ab_5__6_), .B(CARRYB_4__6_), .CI(ab_4__7_), .CO(
        CARRYB_5__6_), .S(SUMB_5__6_) );
  ADDFX2M S3_4_6 ( .A(ab_4__6_), .B(CARRYB_3__6_), .CI(ab_3__7_), .CO(
        CARRYB_4__6_), .S(SUMB_4__6_) );
  ADDFX2M S4_5 ( .A(ab_7__5_), .B(CARRYB_6__5_), .CI(SUMB_6__6_), .CO(
        CARRYB_7__5_), .S(SUMB_7__5_) );
  ADDFX2M S4_4 ( .A(ab_7__4_), .B(CARRYB_6__4_), .CI(SUMB_6__5_), .CO(
        CARRYB_7__4_), .S(SUMB_7__4_) );
  ADDFX2M S2_6_2 ( .A(ab_6__2_), .B(CARRYB_5__2_), .CI(SUMB_5__3_), .CO(
        CARRYB_6__2_), .S(SUMB_6__2_) );
  ADDFX2M S2_5_3 ( .A(ab_5__3_), .B(CARRYB_4__3_), .CI(SUMB_4__4_), .CO(
        CARRYB_5__3_), .S(SUMB_5__3_) );
  ADDFX2M S2_4_4 ( .A(ab_4__4_), .B(CARRYB_3__4_), .CI(SUMB_3__5_), .CO(
        CARRYB_4__4_), .S(SUMB_4__4_) );
  ADDFX2M S2_5_2 ( .A(ab_5__2_), .B(CARRYB_4__2_), .CI(SUMB_4__3_), .CO(
        CARRYB_5__2_), .S(SUMB_5__2_) );
  ADDFX2M S2_3_5 ( .A(ab_3__5_), .B(CARRYB_2__5_), .CI(SUMB_2__6_), .CO(
        CARRYB_3__5_), .S(SUMB_3__5_) );
  ADDFX2M S2_4_2 ( .A(ab_4__2_), .B(CARRYB_3__2_), .CI(SUMB_3__3_), .CO(
        CARRYB_4__2_), .S(SUMB_4__2_) );
  ADDFX2M S2_4_3 ( .A(ab_4__3_), .B(CARRYB_3__3_), .CI(SUMB_3__4_), .CO(
        CARRYB_4__3_), .S(SUMB_4__3_) );
  ADDFX2M S2_3_2 ( .A(ab_3__2_), .B(CARRYB_2__2_), .CI(SUMB_2__3_), .CO(
        CARRYB_3__2_), .S(SUMB_3__2_) );
  ADDFX2M S2_3_4 ( .A(ab_3__4_), .B(CARRYB_2__4_), .CI(SUMB_2__5_), .CO(
        CARRYB_3__4_), .S(SUMB_3__4_) );
  ADDFX2M S2_2_2 ( .A(ab_2__2_), .B(n5), .CI(SUMB_1__3_), .CO(CARRYB_2__2_), 
        .S(SUMB_2__2_) );
  ADDFX2M S2_6_4 ( .A(ab_6__4_), .B(CARRYB_5__4_), .CI(SUMB_5__5_), .CO(
        CARRYB_6__4_), .S(SUMB_6__4_) );
  ADDFX2M S2_5_5 ( .A(ab_5__5_), .B(CARRYB_4__5_), .CI(SUMB_4__6_), .CO(
        CARRYB_5__5_), .S(SUMB_5__5_) );
  ADDFX2M S2_6_3 ( .A(ab_6__3_), .B(CARRYB_5__3_), .CI(SUMB_5__4_), .CO(
        CARRYB_6__3_), .S(SUMB_6__3_) );
  ADDFX2M S2_5_4 ( .A(ab_5__4_), .B(CARRYB_4__4_), .CI(SUMB_4__5_), .CO(
        CARRYB_5__4_), .S(SUMB_5__4_) );
  ADDFX2M S2_4_5 ( .A(ab_4__5_), .B(CARRYB_3__5_), .CI(SUMB_3__6_), .CO(
        CARRYB_4__5_), .S(SUMB_4__5_) );
  ADDFX2M S3_3_6 ( .A(ab_3__6_), .B(CARRYB_2__6_), .CI(ab_2__7_), .CO(
        CARRYB_3__6_), .S(SUMB_3__6_) );
  ADDFX2M S2_3_3 ( .A(ab_3__3_), .B(CARRYB_2__3_), .CI(SUMB_2__4_), .CO(
        CARRYB_3__3_), .S(SUMB_3__3_) );
  ADDFX2M S3_2_6 ( .A(ab_2__6_), .B(n9), .CI(ab_1__7_), .CO(CARRYB_2__6_), .S(
        SUMB_2__6_) );
  ADDFX2M S2_2_3 ( .A(ab_2__3_), .B(n4), .CI(SUMB_1__4_), .CO(CARRYB_2__3_), 
        .S(SUMB_2__3_) );
  ADDFX2M S2_2_4 ( .A(ab_2__4_), .B(n8), .CI(SUMB_1__5_), .CO(CARRYB_2__4_), 
        .S(SUMB_2__4_) );
  ADDFX2M S2_2_5 ( .A(ab_2__5_), .B(n7), .CI(SUMB_1__6_), .CO(CARRYB_2__5_), 
        .S(SUMB_2__5_) );
  ADDFX2M S4_3 ( .A(ab_7__3_), .B(CARRYB_6__3_), .CI(SUMB_6__4_), .CO(
        CARRYB_7__3_), .S(SUMB_7__3_) );
  ADDFX2M S4_2 ( .A(ab_7__2_), .B(CARRYB_6__2_), .CI(SUMB_6__3_), .CO(
        CARRYB_7__2_), .S(SUMB_7__2_) );
  ADDFX2M S1_6_0 ( .A(ab_6__0_), .B(CARRYB_5__0_), .CI(SUMB_5__1_), .CO(
        CARRYB_6__0_), .S(A1_4_) );
  ADDFX2M S1_5_0 ( .A(ab_5__0_), .B(CARRYB_4__0_), .CI(SUMB_4__1_), .CO(
        CARRYB_5__0_), .S(A1_3_) );
  ADDFX2M S1_4_0 ( .A(ab_4__0_), .B(CARRYB_3__0_), .CI(SUMB_3__1_), .CO(
        CARRYB_4__0_), .S(A1_2_) );
  ADDFX2M S1_3_0 ( .A(ab_3__0_), .B(CARRYB_2__0_), .CI(SUMB_2__1_), .CO(
        CARRYB_3__0_), .S(A1_1_) );
  ADDFX2M S1_2_0 ( .A(ab_2__0_), .B(n6), .CI(SUMB_1__1_), .CO(CARRYB_2__0_), 
        .S(A1_0_) );
  ADDFX2M S2_6_1 ( .A(ab_6__1_), .B(CARRYB_5__1_), .CI(SUMB_5__2_), .CO(
        CARRYB_6__1_), .S(SUMB_6__1_) );
  ADDFX2M S2_5_1 ( .A(ab_5__1_), .B(CARRYB_4__1_), .CI(SUMB_4__2_), .CO(
        CARRYB_5__1_), .S(SUMB_5__1_) );
  ADDFX2M S2_4_1 ( .A(ab_4__1_), .B(CARRYB_3__1_), .CI(SUMB_3__2_), .CO(
        CARRYB_4__1_), .S(SUMB_4__1_) );
  ADDFX2M S2_3_1 ( .A(ab_3__1_), .B(CARRYB_2__1_), .CI(SUMB_2__2_), .CO(
        CARRYB_3__1_), .S(SUMB_3__1_) );
  ADDFX2M S2_2_1 ( .A(ab_2__1_), .B(n3), .CI(SUMB_1__2_), .CO(CARRYB_2__1_), 
        .S(SUMB_2__1_) );
  ADDFX2M S4_0 ( .A(ab_7__0_), .B(CARRYB_6__0_), .CI(SUMB_6__1_), .CO(
        CARRYB_7__0_), .S(SUMB_7__0_) );
  ADDFX2M S4_1 ( .A(ab_7__1_), .B(CARRYB_6__1_), .CI(SUMB_6__2_), .CO(
        CARRYB_7__1_), .S(SUMB_7__1_) );
  AND2X2M U2 ( .A(ab_0__2_), .B(ab_1__1_), .Y(n3) );
  AND2X2M U3 ( .A(ab_0__4_), .B(ab_1__3_), .Y(n4) );
  AND2X2M U4 ( .A(ab_0__3_), .B(ab_1__2_), .Y(n5) );
  AND2X2M U5 ( .A(ab_0__1_), .B(ab_1__0_), .Y(n6) );
  AND2X2M U6 ( .A(ab_0__6_), .B(ab_1__5_), .Y(n7) );
  AND2X2M U7 ( .A(ab_0__5_), .B(ab_1__4_), .Y(n8) );
  AND2X2M U8 ( .A(ab_0__7_), .B(ab_1__6_), .Y(n9) );
  AND2X2M U9 ( .A(CARRYB_7__6_), .B(ab_7__7_), .Y(n10) );
  INVX2M U10 ( .A(ab_0__7_), .Y(n22) );
  AND2X2M U11 ( .A(CARRYB_7__0_), .B(SUMB_7__1_), .Y(n11) );
  CLKXOR2X2M U12 ( .A(CARRYB_7__0_), .B(SUMB_7__1_), .Y(A1_6_) );
  CLKXOR2X2M U13 ( .A(ab_1__0_), .B(ab_0__1_), .Y(PRODUCT[1]) );
  CLKXOR2X2M U14 ( .A(CARRYB_7__1_), .B(SUMB_7__2_), .Y(A1_7_) );
  CLKXOR2X2M U15 ( .A(CARRYB_7__2_), .B(SUMB_7__3_), .Y(A1_8_) );
  INVX2M U16 ( .A(ab_0__3_), .Y(n18) );
  INVX2M U17 ( .A(ab_0__6_), .Y(n21) );
  INVX2M U18 ( .A(ab_0__5_), .Y(n20) );
  INVX2M U19 ( .A(ab_0__4_), .Y(n19) );
  XNOR2X2M U20 ( .A(ab_1__2_), .B(n18), .Y(SUMB_1__2_) );
  AND2X2M U21 ( .A(CARRYB_7__1_), .B(SUMB_7__2_), .Y(n12) );
  CLKXOR2X2M U22 ( .A(CARRYB_7__4_), .B(SUMB_7__5_), .Y(A1_10_) );
  CLKXOR2X2M U23 ( .A(CARRYB_7__5_), .B(SUMB_7__6_), .Y(A1_11_) );
  INVX2M U24 ( .A(ab_0__2_), .Y(n17) );
  XNOR2X2M U25 ( .A(ab_1__1_), .B(n17), .Y(SUMB_1__1_) );
  AND2X2M U26 ( .A(CARRYB_7__4_), .B(SUMB_7__5_), .Y(n13) );
  CLKXOR2X2M U27 ( .A(CARRYB_7__3_), .B(SUMB_7__4_), .Y(A1_9_) );
  AND2X2M U28 ( .A(CARRYB_7__3_), .B(SUMB_7__4_), .Y(n14) );
  AND2X2M U29 ( .A(CARRYB_7__2_), .B(SUMB_7__3_), .Y(n15) );
  CLKXOR2X2M U30 ( .A(CARRYB_7__6_), .B(ab_7__7_), .Y(A1_12_) );
  AND2X2M U31 ( .A(CARRYB_7__5_), .B(SUMB_7__6_), .Y(n16) );
  XNOR2X2M U32 ( .A(ab_1__6_), .B(n22), .Y(SUMB_1__6_) );
  XNOR2X2M U33 ( .A(ab_1__5_), .B(n21), .Y(SUMB_1__5_) );
  XNOR2X2M U34 ( .A(ab_1__4_), .B(n20), .Y(SUMB_1__4_) );
  XNOR2X2M U35 ( .A(ab_1__3_), .B(n19), .Y(SUMB_1__3_) );
  INVX2M U36 ( .A(A[1]), .Y(n37) );
  INVX2M U37 ( .A(A[0]), .Y(n38) );
  INVX2M U38 ( .A(B[7]), .Y(n23) );
  INVX2M U39 ( .A(A[3]), .Y(n35) );
  INVX2M U40 ( .A(A[2]), .Y(n36) );
  INVX2M U41 ( .A(A[4]), .Y(n34) );
  INVX2M U42 ( .A(B[0]), .Y(n30) );
  INVX2M U43 ( .A(B[1]), .Y(n29) );
  INVX2M U44 ( .A(A[5]), .Y(n33) );
  INVX2M U45 ( .A(A[7]), .Y(n31) );
  INVX2M U46 ( .A(A[6]), .Y(n32) );
  INVX2M U47 ( .A(B[4]), .Y(n26) );
  INVX2M U48 ( .A(B[6]), .Y(n24) );
  INVX2M U49 ( .A(B[5]), .Y(n25) );
  INVX2M U50 ( .A(B[3]), .Y(n27) );
  INVX2M U51 ( .A(B[2]), .Y(n28) );
  NOR2X1M U53 ( .A(n31), .B(n23), .Y(ab_7__7_) );
  NOR2X1M U54 ( .A(n31), .B(n24), .Y(ab_7__6_) );
  NOR2X1M U55 ( .A(n31), .B(n25), .Y(ab_7__5_) );
  NOR2X1M U56 ( .A(n31), .B(n26), .Y(ab_7__4_) );
  NOR2X1M U57 ( .A(n31), .B(n27), .Y(ab_7__3_) );
  NOR2X1M U58 ( .A(n31), .B(n28), .Y(ab_7__2_) );
  NOR2X1M U59 ( .A(n31), .B(n29), .Y(ab_7__1_) );
  NOR2X1M U60 ( .A(n31), .B(n30), .Y(ab_7__0_) );
  NOR2X1M U61 ( .A(n23), .B(n32), .Y(ab_6__7_) );
  NOR2X1M U62 ( .A(n24), .B(n32), .Y(ab_6__6_) );
  NOR2X1M U63 ( .A(n25), .B(n32), .Y(ab_6__5_) );
  NOR2X1M U64 ( .A(n26), .B(n32), .Y(ab_6__4_) );
  NOR2X1M U65 ( .A(n27), .B(n32), .Y(ab_6__3_) );
  NOR2X1M U66 ( .A(n28), .B(n32), .Y(ab_6__2_) );
  NOR2X1M U67 ( .A(n29), .B(n32), .Y(ab_6__1_) );
  NOR2X1M U68 ( .A(n30), .B(n32), .Y(ab_6__0_) );
  NOR2X1M U69 ( .A(n23), .B(n33), .Y(ab_5__7_) );
  NOR2X1M U70 ( .A(n24), .B(n33), .Y(ab_5__6_) );
  NOR2X1M U71 ( .A(n25), .B(n33), .Y(ab_5__5_) );
  NOR2X1M U72 ( .A(n26), .B(n33), .Y(ab_5__4_) );
  NOR2X1M U73 ( .A(n27), .B(n33), .Y(ab_5__3_) );
  NOR2X1M U74 ( .A(n28), .B(n33), .Y(ab_5__2_) );
  NOR2X1M U75 ( .A(n29), .B(n33), .Y(ab_5__1_) );
  NOR2X1M U76 ( .A(n30), .B(n33), .Y(ab_5__0_) );
  NOR2X1M U77 ( .A(n23), .B(n34), .Y(ab_4__7_) );
  NOR2X1M U78 ( .A(n24), .B(n34), .Y(ab_4__6_) );
  NOR2X1M U79 ( .A(n25), .B(n34), .Y(ab_4__5_) );
  NOR2X1M U80 ( .A(n26), .B(n34), .Y(ab_4__4_) );
  NOR2X1M U81 ( .A(n27), .B(n34), .Y(ab_4__3_) );
  NOR2X1M U82 ( .A(n28), .B(n34), .Y(ab_4__2_) );
  NOR2X1M U83 ( .A(n29), .B(n34), .Y(ab_4__1_) );
  NOR2X1M U84 ( .A(n30), .B(n34), .Y(ab_4__0_) );
  NOR2X1M U85 ( .A(n23), .B(n35), .Y(ab_3__7_) );
  NOR2X1M U86 ( .A(n24), .B(n35), .Y(ab_3__6_) );
  NOR2X1M U87 ( .A(n25), .B(n35), .Y(ab_3__5_) );
  NOR2X1M U88 ( .A(n26), .B(n35), .Y(ab_3__4_) );
  NOR2X1M U89 ( .A(n27), .B(n35), .Y(ab_3__3_) );
  NOR2X1M U90 ( .A(n28), .B(n35), .Y(ab_3__2_) );
  NOR2X1M U91 ( .A(n29), .B(n35), .Y(ab_3__1_) );
  NOR2X1M U92 ( .A(n30), .B(n35), .Y(ab_3__0_) );
  NOR2X1M U93 ( .A(n23), .B(n36), .Y(ab_2__7_) );
  NOR2X1M U94 ( .A(n24), .B(n36), .Y(ab_2__6_) );
  NOR2X1M U95 ( .A(n25), .B(n36), .Y(ab_2__5_) );
  NOR2X1M U96 ( .A(n26), .B(n36), .Y(ab_2__4_) );
  NOR2X1M U97 ( .A(n27), .B(n36), .Y(ab_2__3_) );
  NOR2X1M U98 ( .A(n28), .B(n36), .Y(ab_2__2_) );
  NOR2X1M U99 ( .A(n29), .B(n36), .Y(ab_2__1_) );
  NOR2X1M U100 ( .A(n30), .B(n36), .Y(ab_2__0_) );
  NOR2X1M U101 ( .A(n23), .B(n37), .Y(ab_1__7_) );
  NOR2X1M U102 ( .A(n24), .B(n37), .Y(ab_1__6_) );
  NOR2X1M U103 ( .A(n25), .B(n37), .Y(ab_1__5_) );
  NOR2X1M U104 ( .A(n26), .B(n37), .Y(ab_1__4_) );
  NOR2X1M U105 ( .A(n27), .B(n37), .Y(ab_1__3_) );
  NOR2X1M U106 ( .A(n28), .B(n37), .Y(ab_1__2_) );
  NOR2X1M U107 ( .A(n29), .B(n37), .Y(ab_1__1_) );
  NOR2X1M U108 ( .A(n30), .B(n37), .Y(ab_1__0_) );
  NOR2X1M U109 ( .A(n23), .B(n38), .Y(ab_0__7_) );
  NOR2X1M U110 ( .A(n24), .B(n38), .Y(ab_0__6_) );
  NOR2X1M U111 ( .A(n25), .B(n38), .Y(ab_0__5_) );
  NOR2X1M U112 ( .A(n26), .B(n38), .Y(ab_0__4_) );
  NOR2X1M U113 ( .A(n27), .B(n38), .Y(ab_0__3_) );
  NOR2X1M U114 ( .A(n28), .B(n38), .Y(ab_0__2_) );
  NOR2X1M U115 ( .A(n29), .B(n38), .Y(ab_0__1_) );
  NOR2X1M U116 ( .A(n30), .B(n38), .Y(PRODUCT[0]) );
endmodule


module ALU ( CLK, RST, A, B, ALU_FUN, EN, ALU_OUT, OUT_VALID );
  input [7:0] A;
  input [7:0] B;
  input [3:0] ALU_FUN;
  output [15:0] ALU_OUT;
  input CLK, RST, EN;
  output OUT_VALID;
  wire   N66, N67, N68, N69, N70, N71, N72, N73, N74, N75, N76, N77, N78, N79,
         N80, N81, N82, N83, N84, N85, N86, N87, N88, N89, N90, N91, N92, N93,
         N94, N95, N96, N97, N98, N99, N101, N102, N103, N104, N105, N106,
         N107, N108, N117, N118, N135, N136, N137, N138, N139, N140, N141,
         N142, N143, N144, N145, N146, N147, N148, N149, N150, n32, n33, n34,
         n35, n36, n37, n38, n39, n40, n41, n42, n43, n44, n45, n46, n47, n48,
         n49, n50, n51, n52, n53, n54, n55, n56, n57, n58, n59, n60, n61, n62,
         n63, n64, n65, n66, n67, n68, n69, n70, n71, n72, n73, n74, n75, n76,
         n77, n78, n79, n80, n81, n82, n83, n84, n85, n86, n87, n88, n89, n90,
         n91, n92, n93, n94, n95, n96, n97, n98, n99, n100, n101, n102, n103,
         n104, n105, n106, n107, n108, n109, n110, n111, n3, n4, n5, n6, n7,
         n8, n9, n10, n11, n12, n13, n14, n15, n16, n17, n18, n19, n20, n21,
         n22, n23, n24, n25, n26, n27, n28, n29, n30, n31, n112, n113, n114,
         n115, n116, n117, n118, n119, n120, n121, n122, n123, n124, n125,
         n126, n127, n128, n129, n130, n131, n132, n133, n134,
         SYNOPSYS_UNCONNECTED_1, SYNOPSYS_UNCONNECTED_2,
         SYNOPSYS_UNCONNECTED_3, SYNOPSYS_UNCONNECTED_4,
         SYNOPSYS_UNCONNECTED_5, SYNOPSYS_UNCONNECTED_6,
         SYNOPSYS_UNCONNECTED_7, SYNOPSYS_UNCONNECTED_8;

  ALU_DW_div_uns_0 div_34 ( .a({n13, n12, n11, n10, n9, n8, n7, n6}), .b({n5, 
        B[6:2], n4, n3}), .quotient({N108, N107, N106, N105, N104, N103, N102, 
        N101}), .remainder({SYNOPSYS_UNCONNECTED_1, SYNOPSYS_UNCONNECTED_2, 
        SYNOPSYS_UNCONNECTED_3, SYNOPSYS_UNCONNECTED_4, SYNOPSYS_UNCONNECTED_5, 
        SYNOPSYS_UNCONNECTED_6, SYNOPSYS_UNCONNECTED_7, SYNOPSYS_UNCONNECTED_8}) );
  ALU_DW01_sub_0 sub_32 ( .A({1'b0, n13, n12, n11, n10, n9, n8, n7, n6}), .B({
        1'b0, n5, B[6:2], n4, n3}), .CI(1'b0), .DIFF({N83, N82, N81, N80, N79, 
        N78, N77, N76, N75}) );
  ALU_DW01_add_0 add_31 ( .A({1'b0, n13, n12, n11, n10, n9, n8, n7, n6}), .B({
        1'b0, n5, B[6:2], n4, n3}), .CI(1'b0), .SUM({N74, N73, N72, N71, N70, 
        N69, N68, N67, N66}) );
  ALU_DW02_mult_0 mult_33 ( .A({n13, n12, n11, n10, n9, n8, n7, n6}), .B({n5, 
        B[6:2], n4, n3}), .TC(1'b0), .PRODUCT({N99, N98, N97, N96, N95, N94, 
        N93, N92, N91, N90, N89, N88, N87, N86, N85, N84}) );
  DFFRQX2M ALU_OUT_reg_15_ ( .D(N150), .CK(CLK), .RN(RST), .Q(ALU_OUT[15]) );
  DFFRQX2M ALU_OUT_reg_14_ ( .D(N149), .CK(CLK), .RN(RST), .Q(ALU_OUT[14]) );
  DFFRQX2M ALU_OUT_reg_13_ ( .D(N148), .CK(CLK), .RN(RST), .Q(ALU_OUT[13]) );
  DFFRQX2M ALU_OUT_reg_12_ ( .D(N147), .CK(CLK), .RN(RST), .Q(ALU_OUT[12]) );
  DFFRQX2M ALU_OUT_reg_11_ ( .D(N146), .CK(CLK), .RN(RST), .Q(ALU_OUT[11]) );
  DFFRQX2M ALU_OUT_reg_10_ ( .D(N145), .CK(CLK), .RN(RST), .Q(ALU_OUT[10]) );
  DFFRQX2M ALU_OUT_reg_9_ ( .D(N144), .CK(CLK), .RN(RST), .Q(ALU_OUT[9]) );
  DFFRQX2M ALU_OUT_reg_8_ ( .D(N143), .CK(CLK), .RN(RST), .Q(ALU_OUT[8]) );
  DFFRQX2M ALU_OUT_reg_7_ ( .D(N142), .CK(CLK), .RN(RST), .Q(ALU_OUT[7]) );
  DFFRQX2M ALU_OUT_reg_6_ ( .D(N141), .CK(CLK), .RN(RST), .Q(ALU_OUT[6]) );
  DFFRQX2M ALU_OUT_reg_5_ ( .D(N140), .CK(CLK), .RN(RST), .Q(ALU_OUT[5]) );
  DFFRQX2M ALU_OUT_reg_4_ ( .D(N139), .CK(CLK), .RN(RST), .Q(ALU_OUT[4]) );
  DFFRQX2M ALU_OUT_reg_3_ ( .D(N138), .CK(CLK), .RN(RST), .Q(ALU_OUT[3]) );
  DFFRQX2M ALU_OUT_reg_2_ ( .D(N137), .CK(CLK), .RN(RST), .Q(ALU_OUT[2]) );
  DFFRQX2M ALU_OUT_reg_1_ ( .D(N136), .CK(CLK), .RN(RST), .Q(ALU_OUT[1]) );
  DFFRQX2M ALU_OUT_reg_0_ ( .D(N135), .CK(CLK), .RN(RST), .Q(ALU_OUT[0]) );
  DFFRQX2M OUT_VALID_reg ( .D(EN), .CK(CLK), .RN(RST), .Q(OUT_VALID) );
  BUFX2M U3 ( .A(A[7]), .Y(n13) );
  BUFX2M U4 ( .A(A[1]), .Y(n7) );
  BUFX2M U5 ( .A(A[0]), .Y(n6) );
  OAI2BB1X2M U8 ( .A0N(N98), .A1N(n32), .B0(n33), .Y(N149) );
  OAI2BB1X2M U9 ( .A0N(N99), .A1N(n32), .B0(n33), .Y(N150) );
  OAI2BB1X2M U10 ( .A0N(N95), .A1N(n32), .B0(n33), .Y(N146) );
  OAI2BB1X2M U11 ( .A0N(N96), .A1N(n32), .B0(n33), .Y(N147) );
  OAI2BB1X2M U12 ( .A0N(N97), .A1N(n32), .B0(n33), .Y(N148) );
  OAI2BB1X2M U13 ( .A0N(N93), .A1N(n32), .B0(n33), .Y(N144) );
  OAI2BB1X2M U14 ( .A0N(N94), .A1N(n32), .B0(n33), .Y(N145) );
  NAND3X2M U15 ( .A(n36), .B(EN), .C(N83), .Y(n33) );
  INVX2M U16 ( .A(n49), .Y(n128) );
  INVX2M U17 ( .A(n42), .Y(n132) );
  INVX2M U18 ( .A(EN), .Y(n126) );
  AOI31X2M U19 ( .A0(n97), .A1(n98), .A2(n99), .B0(n126), .Y(N135) );
  AOI22X1M U20 ( .A0(N75), .A1(n36), .B0(N66), .B1(n37), .Y(n97) );
  AOI222X1M U21 ( .A0(N84), .A1(n14), .B0(n131), .B1(n125), .C0(n6), .C1(n132), 
        .Y(n98) );
  AOI221XLM U22 ( .A0(n3), .A1(n100), .B0(n7), .B1(n53), .C0(n101), .Y(n99) );
  AOI31X2M U23 ( .A0(n87), .A1(n88), .A2(n89), .B0(n126), .Y(N136) );
  AOI22X1M U24 ( .A0(N76), .A1(n36), .B0(N67), .B1(n37), .Y(n87) );
  AOI222X1M U25 ( .A0(N85), .A1(n14), .B0(n131), .B1(n124), .C0(n7), .C1(n132), 
        .Y(n88) );
  AOI211X2M U26 ( .A0(n8), .A1(n53), .B0(n90), .C0(n91), .Y(n89) );
  AOI31X2M U27 ( .A0(n79), .A1(n80), .A2(n81), .B0(n126), .Y(N137) );
  AOI22X1M U28 ( .A0(N77), .A1(n36), .B0(N68), .B1(n37), .Y(n79) );
  AOI222X1M U29 ( .A0(N86), .A1(n14), .B0(n131), .B1(n112), .C0(n8), .C1(n132), 
        .Y(n80) );
  AOI221XLM U30 ( .A0(n7), .A1(n133), .B0(n9), .B1(n53), .C0(n82), .Y(n81) );
  AOI31X2M U31 ( .A0(n72), .A1(n73), .A2(n74), .B0(n126), .Y(N138) );
  AOI22X1M U32 ( .A0(N78), .A1(n36), .B0(N69), .B1(n37), .Y(n72) );
  AOI222X1M U33 ( .A0(N87), .A1(n14), .B0(n131), .B1(n113), .C0(n9), .C1(n132), 
        .Y(n73) );
  AOI221XLM U34 ( .A0(n8), .A1(n133), .B0(n10), .B1(n53), .C0(n75), .Y(n74) );
  AOI31X2M U35 ( .A0(n65), .A1(n66), .A2(n67), .B0(n126), .Y(N139) );
  AOI22X1M U36 ( .A0(N79), .A1(n36), .B0(N70), .B1(n37), .Y(n65) );
  AOI222X1M U37 ( .A0(N88), .A1(n14), .B0(n131), .B1(n123), .C0(n10), .C1(n132), .Y(n66) );
  AOI221XLM U38 ( .A0(n9), .A1(n133), .B0(n53), .B1(n11), .C0(n68), .Y(n67) );
  AOI31X2M U39 ( .A0(n58), .A1(n59), .A2(n60), .B0(n126), .Y(N140) );
  AOI22X1M U40 ( .A0(N80), .A1(n36), .B0(N71), .B1(n37), .Y(n58) );
  AOI222X1M U41 ( .A0(N89), .A1(n14), .B0(n131), .B1(n122), .C0(n11), .C1(n132), .Y(n59) );
  AOI221XLM U42 ( .A0(n10), .A1(n133), .B0(n53), .B1(n12), .C0(n61), .Y(n60)
         );
  AOI31X2M U43 ( .A0(n50), .A1(n51), .A2(n52), .B0(n126), .Y(N141) );
  AOI22X1M U44 ( .A0(N81), .A1(n36), .B0(N72), .B1(n37), .Y(n50) );
  AOI221XLM U45 ( .A0(n11), .A1(n133), .B0(n53), .B1(n13), .C0(n54), .Y(n52)
         );
  AOI222X1M U46 ( .A0(N90), .A1(n14), .B0(n131), .B1(n121), .C0(n132), .C1(n12), .Y(n51) );
  AOI31X2M U47 ( .A0(n38), .A1(n39), .A2(n40), .B0(n126), .Y(N142) );
  AOI22X1M U48 ( .A0(n12), .A1(n133), .B0(n131), .B1(n120), .Y(n38) );
  AOI222X1M U49 ( .A0(n5), .A1(n43), .B0(N108), .B1(n44), .C0(n45), .C1(n116), 
        .Y(n39) );
  AOI221XLM U50 ( .A0(N82), .A1(n36), .B0(N73), .B1(n37), .C0(n41), .Y(n40) );
  OAI21X2M U51 ( .A0(n35), .A1(n126), .B0(n33), .Y(N143) );
  AOI222X1M U52 ( .A0(N74), .A1(n37), .B0(n13), .B1(n133), .C0(N92), .C1(n14), 
        .Y(n35) );
  OAI2BB2X1M U53 ( .B0(n120), .B1(n42), .A0N(N91), .A1N(n14), .Y(n41) );
  INVX2M U54 ( .A(n8), .Y(n112) );
  OAI221X1M U55 ( .A0(n8), .A1(n46), .B0(n47), .B1(n112), .C0(n48), .Y(n85) );
  OAI221X1M U56 ( .A0(n9), .A1(n46), .B0(n47), .B1(n113), .C0(n48), .Y(n78) );
  OAI221X1M U57 ( .A0(n10), .A1(n46), .B0(n47), .B1(n123), .C0(n48), .Y(n71)
         );
  OAI221X1M U58 ( .A0(n11), .A1(n46), .B0(n47), .B1(n122), .C0(n48), .Y(n64)
         );
  OAI221X1M U59 ( .A0(n12), .A1(n46), .B0(n47), .B1(n121), .C0(n48), .Y(n57)
         );
  OAI221X1M U60 ( .A0(n13), .A1(n46), .B0(n120), .B1(n47), .C0(n48), .Y(n45)
         );
  AOI21X2M U61 ( .A0(n111), .A1(n93), .B0(n109), .Y(n49) );
  OAI2B2X1M U62 ( .A1N(n4), .A0(n92), .B0(n86), .B1(n125), .Y(n91) );
  AOI221XLM U63 ( .A0(n130), .A1(n124), .B0(n7), .B1(n128), .C0(n132), .Y(n92)
         );
  INVX2M U64 ( .A(n46), .Y(n129) );
  INVX2M U65 ( .A(n47), .Y(n130) );
  INVX2M U66 ( .A(n9), .Y(n113) );
  OAI221X1M U67 ( .A0(n49), .A1(n125), .B0(n6), .B1(n47), .C0(n42), .Y(n100)
         );
  OAI221X1M U68 ( .A0(n49), .A1(n120), .B0(n13), .B1(n47), .C0(n42), .Y(n43)
         );
  NAND2X2M U69 ( .A(n93), .B(n105), .Y(n42) );
  NOR2BX2M U70 ( .AN(n14), .B(n126), .Y(n32) );
  AND2X2M U71 ( .A(n105), .B(n110), .Y(n36) );
  AND2X2M U72 ( .A(n110), .B(n111), .Y(n37) );
  INVX2M U73 ( .A(n48), .Y(n131) );
  INVX2M U74 ( .A(n86), .Y(n133) );
  INVX2M U75 ( .A(n6), .Y(n125) );
  INVX2M U76 ( .A(n13), .Y(n120) );
  INVX2M U77 ( .A(n11), .Y(n122) );
  INVX2M U78 ( .A(n7), .Y(n124) );
  INVX2M U79 ( .A(n12), .Y(n121) );
  INVX2M U80 ( .A(n10), .Y(n123) );
  INVX2M U81 ( .A(n5), .Y(n116) );
  OAI21X2M U82 ( .A0(n3), .A1(n102), .B0(n103), .Y(n101) );
  AOI221XLM U83 ( .A0(n6), .A1(n130), .B0(n129), .B1(n125), .C0(n131), .Y(n102) );
  AOI32X1M U84 ( .A0(N117), .A1(ALU_FUN[3]), .A2(n104), .B0(N101), .B1(n44), 
        .Y(n103) );
  NOR3X2M U85 ( .A(n127), .B(ALU_FUN[2]), .C(ALU_FUN[0]), .Y(n104) );
  BUFX2M U86 ( .A(B[0]), .Y(n3) );
  BUFX2M U87 ( .A(B[7]), .Y(n5) );
  BUFX2M U88 ( .A(B[1]), .Y(n4) );
  BUFX2M U89 ( .A(A[6]), .Y(n12) );
  OAI21X2M U90 ( .A0(n4), .A1(n94), .B0(n95), .Y(n90) );
  AOI221XLM U91 ( .A0(n7), .A1(n130), .B0(n129), .B1(n124), .C0(n131), .Y(n94)
         );
  AOI32X1M U92 ( .A0(N118), .A1(ALU_FUN[3]), .A2(n96), .B0(N102), .B1(n44), 
        .Y(n95) );
  NOR3X2M U93 ( .A(n134), .B(ALU_FUN[2]), .C(n127), .Y(n96) );
  BUFX2M U94 ( .A(A[5]), .Y(n11) );
  OAI21X2M U95 ( .A0(n83), .A1(n119), .B0(n84), .Y(n82) );
  AOI221XLM U96 ( .A0(n130), .A1(n112), .B0(n8), .B1(n128), .C0(n132), .Y(n83)
         );
  AOI22X1M U97 ( .A0(N103), .A1(n44), .B0(n85), .B1(n119), .Y(n84) );
  INVX2M U98 ( .A(B[2]), .Y(n119) );
  BUFX2M U99 ( .A(A[4]), .Y(n10) );
  BUFX2M U100 ( .A(A[3]), .Y(n9) );
  OAI21X2M U101 ( .A0(n76), .A1(n118), .B0(n77), .Y(n75) );
  AOI221XLM U102 ( .A0(n130), .A1(n113), .B0(n9), .B1(n128), .C0(n132), .Y(n76) );
  AOI22X1M U103 ( .A0(N104), .A1(n44), .B0(n78), .B1(n118), .Y(n77) );
  INVX2M U104 ( .A(B[3]), .Y(n118) );
  BUFX2M U105 ( .A(A[2]), .Y(n8) );
  OAI21X2M U106 ( .A0(n69), .A1(n114), .B0(n70), .Y(n68) );
  AOI221XLM U107 ( .A0(n130), .A1(n123), .B0(n10), .B1(n128), .C0(n132), .Y(
        n69) );
  AOI22X1M U108 ( .A0(N105), .A1(n44), .B0(n71), .B1(n114), .Y(n70) );
  OAI21X2M U109 ( .A0(n62), .A1(n117), .B0(n63), .Y(n61) );
  AOI221XLM U110 ( .A0(n130), .A1(n122), .B0(n11), .B1(n128), .C0(n132), .Y(
        n62) );
  AOI22X1M U111 ( .A0(N106), .A1(n44), .B0(n64), .B1(n117), .Y(n63) );
  INVX2M U112 ( .A(B[5]), .Y(n117) );
  INVX2M U113 ( .A(B[6]), .Y(n115) );
  INVX2M U114 ( .A(B[4]), .Y(n114) );
  OAI21X2M U115 ( .A0(n55), .A1(n115), .B0(n56), .Y(n54) );
  AOI221XLM U116 ( .A0(n130), .A1(n121), .B0(n12), .B1(n128), .C0(n132), .Y(
        n55) );
  AOI22X1M U117 ( .A0(N107), .A1(n44), .B0(n57), .B1(n115), .Y(n56) );
  AOI31X2M U118 ( .A0(ALU_FUN[2]), .A1(ALU_FUN[1]), .A2(n105), .B0(n109), .Y(
        n46) );
  NOR2BX2M U119 ( .AN(ALU_FUN[2]), .B(ALU_FUN[1]), .Y(n93) );
  NOR2X2M U120 ( .A(ALU_FUN[3]), .B(ALU_FUN[0]), .Y(n111) );
  NOR2X2M U121 ( .A(ALU_FUN[2]), .B(ALU_FUN[1]), .Y(n110) );
  NOR2X2M U122 ( .A(n134), .B(ALU_FUN[3]), .Y(n105) );
  NAND3X2M U123 ( .A(n110), .B(n134), .C(ALU_FUN[3]), .Y(n47) );
  AND3X2M U124 ( .A(n105), .B(ALU_FUN[1]), .C(n106), .Y(n44) );
  AOI21X2M U125 ( .A0(n107), .A1(n108), .B0(ALU_FUN[2]), .Y(n106) );
  NOR4X1M U126 ( .A(n5), .B(B[6]), .C(B[5]), .D(B[4]), .Y(n108) );
  NOR4X1M U127 ( .A(B[3]), .B(B[2]), .C(n4), .D(n3), .Y(n107) );
  INVX2M U128 ( .A(ALU_FUN[0]), .Y(n134) );
  AND3X2M U129 ( .A(n110), .B(ALU_FUN[0]), .C(ALU_FUN[3]), .Y(n109) );
  NAND3X2M U130 ( .A(ALU_FUN[1]), .B(n111), .C(ALU_FUN[2]), .Y(n48) );
  AND3X2M U131 ( .A(n93), .B(n134), .C(ALU_FUN[3]), .Y(n53) );
  NAND3X2M U132 ( .A(n93), .B(ALU_FUN[0]), .C(ALU_FUN[3]), .Y(n86) );
  INVX2M U133 ( .A(ALU_FUN[1]), .Y(n127) );
  BUFX2M U134 ( .A(n34), .Y(n14) );
  NOR3BX2M U135 ( .AN(n111), .B(ALU_FUN[2]), .C(n127), .Y(n34) );
  NOR2BX1M U136 ( .AN(n3), .B(n6), .Y(n15) );
  OAI2B2X1M U137 ( .A1N(n7), .A0(n15), .B0(n4), .B1(n15), .Y(n16) );
  NAND2BX1M U138 ( .AN(n12), .B(B[6]), .Y(n27) );
  CLKNAND2X2M U139 ( .A(B[5]), .B(n122), .Y(n26) );
  NAND2BX1M U140 ( .AN(n10), .B(B[4]), .Y(n23) );
  NAND4X1M U141 ( .A(n16), .B(n27), .C(n26), .D(n23), .Y(n31) );
  CLKNAND2X2M U142 ( .A(B[3]), .B(n113), .Y(n22) );
  CLKNAND2X2M U143 ( .A(B[2]), .B(n112), .Y(n17) );
  CLKNAND2X2M U144 ( .A(n22), .B(n17), .Y(n30) );
  NOR2BX1M U145 ( .AN(n5), .B(n13), .Y(n29) );
  NOR2BX1M U146 ( .AN(n6), .B(n3), .Y(n19) );
  OAI2BB1X1M U147 ( .A0N(n19), .A1N(n7), .B0(n4), .Y(n18) );
  OAI211X1M U148 ( .A0(n7), .A1(n19), .B0(n18), .C0(n17), .Y(n20) );
  OAI221X1M U149 ( .A0(B[2]), .A1(n112), .B0(B[3]), .B1(n113), .C0(n20), .Y(
        n21) );
  AOI32X1M U150 ( .A0(n23), .A1(n22), .A2(n21), .B0(n10), .B1(n114), .Y(n24)
         );
  OAI21X1M U151 ( .A0(B[5]), .A1(n122), .B0(n24), .Y(n25) );
  AOI32X1M U152 ( .A0(n27), .A1(n26), .A2(n25), .B0(n12), .B1(n115), .Y(n28)
         );
  OAI2B2X1M U153 ( .A1N(n13), .A0(n5), .B0(n29), .B1(n28), .Y(N118) );
  NOR4X1M U154 ( .A(n31), .B(n30), .C(N118), .D(n29), .Y(N117) );
endmodule


module CLK_GATE ( CLK_EN, CLK, GATED_CLK );
  input CLK_EN, CLK;
  output GATED_CLK;


  TLATNCAX12M u_icg ( .E(CLK_EN), .CK(CLK), .ECK(GATED_CLK) );
endmodule


module SYS_TOP ( RST_N, UART_CLK, REF_CLK, UART_RX_IN, UART_TX_O, parity_error, 
        framing_error );
  input RST_N, UART_CLK, REF_CLK, UART_RX_IN;
  output UART_TX_O, parity_error, framing_error;
  wire   SYNC_UART_RST, SYNC_REF_RST, UART_RX_V_OUT, UART_RX_V_SYNC,
         UART_TX_VLD, UART_TX_CLK, UART_TX_Busy_PULSE, FIFO_FULL,
         UART_TX_V_SYNC, UART_TX_Busy, UART_RX_CLK, RF_RdData_VLD, RF_WrEn,
         RF_RdEn, ALU_EN, ALU_OUT_VLD, CLKG_EN, ALU_CLK, n1, n2, n3, n4, n5,
         n6, n7, SYNOPSYS_UNCONNECTED_1, SYNOPSYS_UNCONNECTED_2,
         SYNOPSYS_UNCONNECTED_3, SYNOPSYS_UNCONNECTED_4,
         SYNOPSYS_UNCONNECTED_5;
  wire   [7:0] UART_RX_OUT;
  wire   [7:0] UART_RX_SYNC;
  wire   [7:0] UART_TX_IN;
  wire   [7:0] UART_TX_SYNC;
  wire   [7:0] DIV_RATIO;
  wire   [7:0] UART_Config;
  wire   [7:0] DIV_RATIO_RX;
  wire   [7:0] RF_RdData;
  wire   [3:0] RF_Address;
  wire   [7:0] RF_WrData;
  wire   [3:0] ALU_FUN;
  wire   [15:0] ALU_OUT;
  wire   [7:0] Operand_A;
  wire   [7:0] Operand_B;

  RST_Sync_0 U0_RST_SYNC ( .RST(RST_N), .CLK(UART_CLK), .SYNC_RST(
        SYNC_UART_RST) );
  RST_Sync_1 U1_RST_SYNC ( .RST(RST_N), .CLK(REF_CLK), .SYNC_RST(SYNC_REF_RST)
         );
  Data_Sync U0_ref_sync ( .CLK(REF_CLK), .RST(n4), .unsync_bus(UART_RX_OUT), 
        .bus_enable(UART_RX_V_OUT), .enable_pulse(UART_RX_V_SYNC), .sync_bus(
        UART_RX_SYNC) );
  Async_fifo U0_UART_FIFO ( .i_w_clk(REF_CLK), .i_w_rstn(n4), .i_w_inc(
        UART_TX_VLD), .i_w_data(UART_TX_IN), .i_r_clk(UART_TX_CLK), .i_r_rstn(
        n6), .i_r_inc(UART_TX_Busy_PULSE), .o_r_data(UART_TX_SYNC), .o_full(
        FIFO_FULL), .o_empty(UART_TX_V_SYNC) );
  Pulse_Gen U0_PULSE_GEN ( .CLK(UART_TX_CLK), .RST(n6), .lvl_sig(UART_TX_Busy), 
        .pulse_sig(UART_TX_Busy_PULSE) );
  Clock_Divider_0 U0_ClkDiv ( .i_ref_clk(UART_CLK), .i_rst_n(n6), .i_clk_en(
        1'b1), .i_div_ratio(DIV_RATIO), .o_div_clk(UART_TX_CLK) );
  CLKDIV_MUX U0_CLKDIV_MUX ( .IN({UART_Config[7:5], n2, UART_Config[3:2]}), 
        .OUT({SYNOPSYS_UNCONNECTED_1, SYNOPSYS_UNCONNECTED_2, 
        SYNOPSYS_UNCONNECTED_3, SYNOPSYS_UNCONNECTED_4, SYNOPSYS_UNCONNECTED_5, 
        DIV_RATIO_RX[2:0]}) );
  Clock_Divider_1 U1_ClkDiv ( .i_ref_clk(UART_CLK), .i_rst_n(n6), .i_clk_en(
        1'b1), .i_div_ratio({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, DIV_RATIO_RX[2:0]}), 
        .o_div_clk(UART_RX_CLK) );
  UART U0_UART ( .RST(n6), .TX_CLK(UART_TX_CLK), .RX_CLK(UART_RX_CLK), 
        .parity_enable(UART_Config[0]), .parity_type(UART_Config[1]), 
        .Prescale({UART_Config[7:5], n2, UART_Config[3:2]}), .RX_IN_S(
        UART_RX_IN), .RX_OUT_P(UART_RX_OUT), .RX_OUT_V(UART_RX_V_OUT), 
        .TX_IN_P(UART_TX_SYNC), .TX_IN_V(n1), .TX_OUT_S(UART_TX_O), .TX_OUT_V(
        UART_TX_Busy), .parity_error(parity_error), .stop_error(framing_error)
         );
  SYS_CTRL U0_SYS_CTRL ( .CLK(REF_CLK), .RST(n4), .ALU_OUT(ALU_OUT), 
        .ALU_OUT_Valid(ALU_OUT_VLD), .ALU_FUN(ALU_FUN), .ALU_EN(ALU_EN), 
        .CLKG_EN(CLKG_EN), .Address(RF_Address), .WrEn(RF_WrEn), .RdEn(RF_RdEn), .WrData(RF_WrData), .RdData(RF_RdData), .RdData_Valid(RF_RdData_VLD), 
        .RX_P_DATA(UART_RX_SYNC), .RX_D_VLD(UART_RX_V_SYNC), .TX_P_DATA(
        UART_TX_IN), .TX_D_VLD(UART_TX_VLD), .FIFO_FULL(FIFO_FULL) );
  RegFile U0_RegFile ( .CLK(REF_CLK), .RST(n4), .WrEn(RF_WrEn), .RdEn(RF_RdEn), 
        .Address(RF_Address), .WrData(RF_WrData), .RdData(RF_RdData), 
        .RdData_Valid(RF_RdData_VLD), .REG0(Operand_A), .REG1(Operand_B), 
        .REG2(UART_Config), .REG3(DIV_RATIO) );
  ALU U0_ALU ( .CLK(ALU_CLK), .RST(n4), .A(Operand_A), .B(Operand_B), 
        .ALU_FUN(ALU_FUN), .EN(ALU_EN), .ALU_OUT(ALU_OUT), .OUT_VALID(
        ALU_OUT_VLD) );
  CLK_GATE U0_CLK_GATE ( .CLK_EN(CLKG_EN), .CLK(REF_CLK), .GATED_CLK(ALU_CLK)
         );
  INVX2M U2 ( .A(n5), .Y(n4) );
  INVX2M U3 ( .A(UART_TX_V_SYNC), .Y(n1) );
  INVX2M U4 ( .A(SYNC_REF_RST), .Y(n5) );
  INVX2M U5 ( .A(n7), .Y(n6) );
  INVX2M U6 ( .A(SYNC_UART_RST), .Y(n7) );
  INVX2M U7 ( .A(n3), .Y(n2) );
  INVX2M U8 ( .A(UART_Config[4]), .Y(n3) );
endmodule

