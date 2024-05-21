// traffic light controller
// CSE140L 3-street, 12-state version
// inserts all-red after each yellow
// uses enumerated variables for states and for red-yellow-green
// 5 after traffic, 10 max cycles for green after conflict
// starter (shell) -- you need to complete the always_comb logic
import light_package ::*;           // defines red, yellow, green

// same as Harris & Harris 4-state, but we have added two all-reds
module traffic_light_controller(
  input  clk, reset, 
         s_s, l_s, n_s,  // traffic sensors, east-west straight, east-west left, north-south 
  output colors str_light, left_light, ns_light);    // traffic lights, east-west straight, east-west left, north-south

// HRR = red-red following YRR; RRH = red-red following RRY;
// ZRR = 2nd cycle yellow, follows YRR, etc. 
  typedef enum {GRR, YRR, ZRR, HRR,              // ES+WS
                RGR, RYR, RZR, RHR, 	         // EL+WL
                RRG, RRY, RRZ, RRH} tlc_states;  // NS
  tlc_states    present_state, next_state;
  int     ctr5, next_ctr5,       //  5 sec timeout when my traffic goes away
          ctr10, next_ctr10;     // 10 sec limit when other traffic presents

  logic      ctr5en,      ctr10en;
  logic next_ctr5en, next_ctr10en;


// sequential part of our state machine (register between C1 and C2 in Harris & Harris Moore machine diagram
// combinational part will reset or increment the counters and figure out the next_state
  always_ff @(posedge clk)
    if(reset) begin
	    present_state <= RRH;
      ctr5          <= 0;
      ctr10         <= 0;
      ctr5en        <= 0;
      ctr10en       <= 0;
    end  
	else begin
	    present_state <= next_state;
      ctr5          <= next_ctr5;
      ctr10         <= next_ctr10;
      ctr5en        <= next_ctr5en;
      ctr10en       <= next_ctr10en;
    end

// combinational part of state machine ("C1" block in the Harris & Harris Moore machine diagram)
// default needed because only 6 of 8 possible states are defined/used
  always_comb begin
    next_state   = HRR;            // default to reset state
    next_ctr5    = 0; 	         // default to clearing counters
    next_ctr10   = 0;
    next_ctr5en  = 0;
    next_ctr10en = 0;
    case (present_state)
    // --  Green States --
	  GRR: begin 
      next_ctr5en  = ctr5en  || (!s_s);
      next_ctr10en = ctr10en || (l_s || n_s);

      next_ctr5  = next_ctr5en  ? ctr5  + 1 : ctr5;
      next_ctr10 = next_ctr10en ? ctr10 + 1 : ctr10;

      if ((next_ctr5 >= 5) || (next_ctr10 >= 10)) begin
        next_state = YRR;
        next_ctr5  = 0;
        next_ctr10 = 0;
      end else next_state = GRR;
    end
	  RGR: begin
      next_ctr5en  = ctr5en  || (!l_s);
      next_ctr10en = ctr10en || (s_s || n_s);

      next_ctr5  = next_ctr5en  ? ctr5  + 1 : ctr5;
      next_ctr10 = next_ctr10en ? ctr10 + 1 : ctr10;

      if ((next_ctr5 >= 5) || (next_ctr10 >= 10)) begin
        next_state = RYR;
        next_ctr5  = 0;
        next_ctr10 = 0;
      end else next_state = RGR;
    end
	  RRG: begin
      next_ctr5en  = ctr5en  || (!n_s);
      next_ctr10en = ctr10en || (s_s || l_s);

      next_ctr5  = next_ctr5en  ? ctr5  + 1 : ctr5;
      next_ctr10 = next_ctr10en ? ctr10 + 1 : ctr10;

      if ((next_ctr5 >= 5) || (next_ctr10 >= 10)) begin
        next_state = RRY;
        next_ctr5  = 0;
        next_ctr10 = 0;
      end else next_state = RRG;
    end
    // -------------------

    // -- Yellow States --
    YRR: next_state = ZRR;
    ZRR: next_state = HRR;

    RYR: next_state = RZR;
    RZR: next_state = RHR;

    RRY: next_state = RRZ;
    RRZ: next_state = RRH;
    // -------------------
    
    // --   Red  States --
    HRR:
           if (l_s) next_state = RGR;
      else if (n_s) next_state = RRG;
      else if (s_s) next_state = GRR;
      else          next_state = HRR;
    RHR:
           if (n_s) next_state = RRG;
      else if (s_s) next_state = GRR;
      else if (l_s) next_state = RGR;
      else          next_state = RHR;
    RRH:
           if (s_s) next_state = GRR;
      else if (l_s) next_state = RGR;
      else if (n_s) next_state = RRG;
      else          next_state = RRH;
    // -------------------
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