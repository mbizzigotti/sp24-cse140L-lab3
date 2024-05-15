// test bench for Lab 3  -- write to file version
// CSE140L   
// expanded version -- try the simpler traffic_tb first if
//  you do not pass this one
`timescale 1ns/1ns
import light_package::*;
module lab3_part1_tb;
//timeprecision 1ns; 
 
bit  clk;
bit  reset = 1'b1;		   // should put your design in all-red
bit  ew_left_sensor,  // left traffic on e-w street
	   ew_str_sensor,  // thru traffic on e-w street
	   ns_sensor;  // traffic on n-s street
colors ew_left_light,          // left arrow e-w turn onto n-s
	   ew_str_light,	       // straight ahead e-w
	   ns_light;	           // n-s (no left/thru differentiation)
colors ew_left_light1,          // left arrow e-w turn onto n-s
	   ew_str_light1,	       // straight ahead e-w
	   ns_light1;	           // n-s (no left/thru differentiation)
//typedef enum logic[1:0] {red,yellow,green} color;

// your controller goes here
// input ports = logics above
// output ports = colors (each 2 bits wide)
traffic_light_controller dut(.clk(clk),.reset(reset),
  .s_s(ew_str_sensor), .l_s(ew_left_sensor), .n_s(ns_sensor),
  .str_light(ew_str_light),.left_light(ew_left_light),.ns_light);
/*
traffic_light_controller1 dut1(.clk(clk),.reset(reset),
  .s_s(ew_str_sensor), .l_s(ew_left_sensor), .n_s(ns_sensor),
  .str_light(ew_str_light1),.left_light(ew_left_light1),.ns_light(ns_light1));
  */
int fi,fj;
int test_cnt;          // lets testbench track tests
initial begin
  fi = $fopen("lab3_part1_results.txt","w");
//  fj = $fopen("lab3_part1_results1.txt","w");
  $fdisplay(fi,"t   t   t   e   e   n");	   // header for y, g status display
  $fdisplay(fj,"t   t   t   e   e   n");	   // header for y, g status display
  $fdisplay(fi,"s   l   n   w   w   s");
  $fdisplay(fj,"s   l   n   w   w   s");
  $fdisplay(fi,"            s   l    ");
  $fdisplay(fj,"            s   l    ");
  $fmonitor(fi, "Test Case: %d", test_cnt);
  $fmonitor(fj, "Test Case: %d", test_cnt);
  #20ns reset    = 1'b0;
  #10ns;
// Test EW_LEFT to EW_STR without more traffic
  test_cnt++                  ;
  ew_left_sensor       = 1'b1 ;
  fork
    begin
      #10ns ew_str_sensor = 1'b1;
      wait   (ew_str_light == green);
	  #25ns ew_str_sensor = 1'b0;
	end
    begin
      wait 	(ew_left_light == green);
      #15ns ew_left_sensor = 1'b0 ;
	end
  join
  #200ns;

// Now set traffic at NS. Green NS lasts past sensor falling
  test_cnt++                  ;
  ns_sensor           = 1'b1  ;
  wait (ns_light == green);
  #35ns ns_sensor     = 1'b0  ;
  #200ns;

// Check NS again, but hold for more than 5 cycles.
//   NS should cycle green-yellow-red when side traffic appears
  test_cnt++;
  ns_sensor              = 1'b1;
  #100ns  ew_left_sensor = 1'b1;
  #200ns ns_sensor       = 1'b0;
  #10ns ew_left_sensor  = 1'b0;
  #200ns;

// All three sensors become 1 at once.
//  EW_STR should come first, then LEFT, then NS
  test_cnt++;
  ew_left_sensor = 1'b1;
  ew_str_sensor  = 1'b1;
  ns_sensor      = 1'b1;
  #1000ns;
  ew_left_sensor = 1'b0;
  #200ns;
  ew_str_sensor  = 1'b0;
  ns_sensor      = 1'b0;
  #200ns;

// All
  test_cnt++;
  $stop;
end

always begin
  #5ns clk = 1'b1;
  #3ns;
// print active sensors into result file
  if(ew_str_sensor) begin
    $fwrite(fi,"es  ");
    $fwrite(fj,"es  ");
  end
  else begin
    $fwrite(fi,"    ");
    $fwrite(fj,"    ");
  end
  if(ew_left_sensor) begin
    $fwrite(fi,"el  ");
    $fwrite(fj,"el  ");
  end
  else begin
    $fwrite(fi,"    ");
    $fwrite(fj,"    ");
  end
  if(ns_sensor) begin
    $fwrite(fi,"ns  ");
    $fwrite(fj,"ns  ");
  end
  else begin
    $fwrite(fi,"    ");
    $fwrite(fj,"    ");
  end
// print yellow and green states into result file
  case({ew_str_light,ew_left_light,ns_light})
    {red,red,red}   : $fdisplay(fi,"             %t",$time);
	{yellow,red,red}: $fdisplay(fi,"sy           %t",$time);
	{green,red,red} : $fdisplay(fi,"sg           %t",$time);
	{red,yellow,red}: $fdisplay(fi,"    ly       %t",$time);
	{red,green,red} : $fdisplay(fi,"    lg       %t",$time);
	{red,red,yellow}: $fdisplay(fi,"        ny   %t",$time);
	{red,red,green} : $fdisplay(fi,"        ng   %t",$time);
	default    : $fdisplay(fi,"***ERROR**   %t",$time);
  endcase
  case({ew_str_light1,ew_left_light1,ns_light1})
    {red,red,red}   : $fdisplay(fj,"             %t",$time);
	{yellow,red,red}: $fdisplay(fj,"sy           %t",$time);
	{green,red,red} : $fdisplay(fj,"sg           %t",$time);
	{red,yellow,red}: $fdisplay(fj,"    ly       %t",$time);
	{red,green,red} : $fdisplay(fj,"    lg       %t",$time);
	{red,red,yellow}: $fdisplay(fj,"        ny   %t",$time);
	{red,red,green} : $fdisplay(fj,"        ng   %t",$time);
	default    : $fdisplay(fj,"***ERROR**   %t",$time);
  endcase
  #2ns clk = 1'b0; 
end

endmodule
