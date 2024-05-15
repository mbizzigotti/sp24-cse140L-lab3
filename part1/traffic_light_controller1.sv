// traffic light controller
// CSE140L 3-street, 12-state version
// inserts all-red after each yellow
// uses enumerated variables for states and for red-yellow-green
// 5 after traffic, 10 max cycles for green after conflict
// starter (shell) -- you need to complete the always_comb logic
import light_package ::*;           // defines red, yellow, green

// same as Harris & Harris 4-state, but we have added two all-reds
module traffic_light_controller1(
  input  clk, reset, 
         s_s, l_s, n_s,  // traffic sensors, east-west straight, east-west left, north-south 
  output colors ew_str_light, ew_left_light, ns_light);    // traffic lights, east-west straight, east-west left, north-south

// HRR = red-red following YRR; RRH = red-red following RRY;
// ZRR = 2nd cycle yellow, follows YRR, etc. 
  typedef enum {GRR, YRR, ZRR, HRR,              // ES+WS
                RGR, RYR, RZR, RHR, 	         // EL+WL
                RRG, RRY, RRZ, RRH} tlc_states;  // NS
  tlc_states    present_state, next_state;
  int     ctr5, next_ctr5,       //  5 sec timeout when my traffic goes away
          ctr10, next_ctr10;     // 10 sec limit when other traffic presents

// sequential part of our state machine (register between C1 and C2 in Harris & Harris Moore machine diagram
// combinational part will reset or increment the counters and figure out the next_state
  always_ff @(posedge clk)
    if(reset) begin
	  present_state <= RRH;
      ctr5          <= 0;
      ctr10         <= 0;
    end  
	else begin
	  present_state <= next_state;
      ctr5          <= next_ctr5;
      ctr10         <= next_ctr10;
    end  

// combinational part of state machine ("C1" block in the Harris & Harris Moore machine diagram)
// default needed because only 6 of 8 possible states are defined/used
  always_comb begin
    next_state = RRH;            // default to reset state
    next_ctr5  = 0; 	         // default to clearing counters
    next_ctr10 = 0;
    case(present_state)
/* ************* Fill in the case statements ************** */
	  GRR: begin 
         // when is next_state GRR? YRR?
         // what does ctr5 do? ctr10?
      end  
     // etc. 
    endcase
  end

// combination output driver  ("C2" block in the Harris & Harris Moore machine diagram)
  always_comb begin
    str_light  = red;      // cover all red plus undefined cases
	left_light = red;	   // default to red, then call out exceptions in case
	ns_light   = red;
    case(present_state)    // Moore machine
      GRR:     str_light  = green;
	  YRR,ZRR: str_light  = yellow;  // my dual yellow states -- brute force way to make yellow last 2 cycles
	  RGR:     left_light = green;
	  RYR,RZR: left_light = yellow;
	  RRG:     ns_light   = green;
	  RRY,RRZ: ns_light   = yellow;
    endcase
  end

endmodule