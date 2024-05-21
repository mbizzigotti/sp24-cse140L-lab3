// traffic light controller solution stretch
// CSE140L 3-street, 20-state version, ew str/left decouple
// inserts all-red after each yellow
// uses enumerated variables for states and for red-yellow-green
// 5 after traffic, 10 max cycles for green when other traffic present
import light_package ::*;           // defines red, yellow, green

// same as Harris & Harris 4-state, but we have added two all-reds
module traffic_light_controller(
  input clk, reset, e_str_sensor, w_str_sensor, e_left_sensor, 
        w_left_sensor, ns_sensor,             // traffic sensors, east-west str, east-west left, north-south 
  output colors e_str_light, w_str_light, e_left_light, w_left_light, ns_light);     // traffic lights, east-west str, east-west left, north-south

  logic s, sb, e, eb, w, wb, l, lb, n, nb;	 // shorthand for traffic combinations:

  assign s  = e_str_sensor || w_str_sensor;					 // str E or W
  assign sb = e_left_sensor || w_left_sensor || ns_sensor;			     // 3 directions which conflict with s
  assign e  = e_left_sensor || e_str_sensor;					     // E str or L
  assign eb = w_left_sensor || w_str_sensor || ns_sensor;			 // conflicts with e
  assign w  = w_left_sensor || w_str_sensor;
  assign wb = e_left_sensor || e_str_sensor || ns_sensor;
  assign l  = e_left_sensor || w_left_sensor;
  assign lb = e_str_sensor || w_str_sensor || ns_sensor;
  assign n  = ns_sensor;
  assign nb = s || l; 

// 20 suggested states, 4 per direction   Y, Z = easy way to get 2-second yellows
// HRRRR = red-red following ZRRRR; ZRRRR = second yellow following YRRRR; 
// RRRRH = red-red following RRRRZ;
  typedef enum {GRRRR, YRRRR, ZRRRR, HRRRR, 	           // ES+WS
  	            RGRRR, RYRRR, RZRRR, RHRRR, 			   // EL+ES
	            RRGRR, RRYRR, RRZRR, RRHRR,				   // WL+WS
	            RRRGR, RRRYR, RRRZR, RRRHR, 			   // WL+EL
	            RRRRG, RRRRY, RRRRZ, RRRRH} tlc_states;    // NS
	tlc_states    present_state, next_state;
	int     ctr5, next_ctr5,       //  5 sec timeout when my traffic goes away
			ctr10, next_ctr10;     // 10 sec limit when other traffic presents

  logic      ctr5en,      ctr10en;
  logic next_ctr5en, next_ctr10en;

  logic change_light;
  assign change_light = (next_ctr5 >= 5) || (next_ctr10 >= 10);

// sequential part of our state machine (register between C1 and C2 in Harris & Harris Moore machine diagram
// combinational part will reset or increment the counters and figure out the next_state
  always_ff @(posedge clk)
	if(reset) begin
	  present_state <= RRRRH;
	  ctr5          <= 'd0;
	  ctr10         <= 'd0;
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
	next_state = RRRRH;                            // default to reset state
	next_ctr5  = 'd0; 							   // default: reset counters
	next_ctr10 = 'd0;
    next_ctr5en  = 0;
    next_ctr10en = 0;
	case (present_state)

	// ***** GREEN *********************************
	GRRRR: begin
		next_ctr5en  = ctr5en  || (!s);
		next_ctr10en = ctr10en || (sb);
		next_ctr5  = next_ctr5en  ? ctr5  + 1 : ctr5;
		next_ctr10 = next_ctr10en ? ctr10 + 1 : ctr10;

		if ((next_ctr5 >= 5) || (next_ctr10 >= 10)) begin
			next_state = YRRRR;
			next_ctr5 = 0;
			next_ctr10 = 0;
		end else next_state = GRRRR;
	end
	RGRRR: begin
		next_ctr5en  = ctr5en  || (!e);
		next_ctr10en = ctr10en || (eb);
		next_ctr5  = next_ctr5en  ? ctr5  + 1 : ctr5;
		next_ctr10 = next_ctr10en ? ctr10 + 1 : ctr10;

		if ((next_ctr5 >= 5) || (next_ctr10 >= 10)) begin
			next_state = RYRRR;
			next_ctr5 = 0;
			next_ctr10 = 0;
		end else next_state = RGRRR;
	end
	RRGRR: begin
		next_ctr5en  = ctr5en  || (!w);
		next_ctr10en = ctr10en || (wb);
		next_ctr5  = next_ctr5en  ? ctr5  + 1 : ctr5;
		next_ctr10 = next_ctr10en ? ctr10 + 1 : ctr10;

		if ((next_ctr5 >= 5) || (next_ctr10 >= 10)) begin
			next_state = RRYRR;
			next_ctr5 = 0;
			next_ctr10 = 0;
		end else next_state = RRGRR;
	end
	RRRGR: begin
		next_ctr5en  = ctr5en  || (!l);
		next_ctr10en = ctr10en || (lb);
		next_ctr5  = next_ctr5en  ? ctr5  + 1 : ctr5;
		next_ctr10 = next_ctr10en ? ctr10 + 1 : ctr10;

		if ((next_ctr5 >= 5) || (next_ctr10 >= 10)) begin
			next_state = RRRYR;
			next_ctr5 = 0;
			next_ctr10 = 0;
		end else next_state = RRRGR;
	end
	RRRRG: begin
		next_ctr5en  = ctr5en  || (!n);
		next_ctr10en = ctr10en || (nb);
		next_ctr5  = next_ctr5en  ? ctr5  + 1 : ctr5;
		next_ctr10 = next_ctr10en ? ctr10 + 1 : ctr10;

		if ((next_ctr5 >= 5) || (next_ctr10 >= 10)) begin
			next_state = RRRRY;
			next_ctr5 = 0;
			next_ctr10 = 0;
		end else next_state = RRRRG;
	end

	// ***** YELLOW *********************************
	  YRRRR: next_state = ZRRRR;
	  ZRRRR: next_state = HRRRR;

	  RYRRR: next_state = RZRRR;
	  RZRRR: next_state = RHRRR;

	  RRYRR: next_state = RRZRR;
	  RRZRR: next_state = RRHRR;

	  RRRYR: next_state = RRRZR;
	  RRRZR: next_state = RRRHR;

	  RRRRY: next_state = RRRRZ;
	  RRRRZ: next_state = RRRRH;

	// ***** RED *********************************
    HRRRR:
           if (e) next_state = RGRRR;
      else if (w) next_state = RRGRR;
      else if (l) next_state = RRRGR;
      else if (n) next_state = RRRRG;
	  else if (s) next_state = GRRRR;
      else        next_state = RRRRH;
    RHRRR:
           if (w) next_state = RRGRR;
      else if (l) next_state = RRRGR;
      else if (n) next_state = RRRRG;
	  else if (s) next_state = GRRRR;
	  else if (e) next_state = RGRRR;
      else        next_state = RRRRH;
    RRHRR:
           if (l) next_state = RRRGR;
      else if (n) next_state = RRRRG;
	  else if (s) next_state = GRRRR;
	  else if (e) next_state = RGRRR;
      else if (w) next_state = RRGRR;
      else        next_state = RRRRH;
    RRRHR:
           if (n) next_state = RRRRG;
	  else if (s) next_state = GRRRR;
	  else if (e) next_state = RGRRR;
      else if (w) next_state = RRGRR;
      else if (l) next_state = RRRGR;
      else        next_state = RRRRH;
    RRRRH:
           if (s) next_state = GRRRR;
      else if (e) next_state = RGRRR;
      else if (w) next_state = RRGRR;
      else if (l) next_state = RRRGR;
      else if (n) next_state = RRRRG;
      else        next_state = RRRRH;
    endcase
  end

// combination output driver  ("C2" block in the Harris & Harris Moore machine diagram)
	always_comb begin
	  e_str_light  = red;                // cover all red plus undefined cases
	  w_str_light  = red;				 // no need to list them below this block
	  e_left_light = red;
	  w_left_light = red;
	  ns_light     = red;
	  case(present_state)      // Moore machine
		GRRRR: begin
			e_str_light = green;
			w_str_light = green;
		end
		YRRRR,ZRRRR: begin
			e_str_light = yellow;
			w_str_light = yellow;
		end
		RGRRR: begin
			e_left_light = green;
			e_str_light  = green;
		end
		RYRRR,RZRRR: begin
			e_left_light = yellow;
			e_str_light  = yellow;
		end
		RRGRR: begin
			w_left_light = green;
			w_str_light  = green;
		end
		RRYRR,RRZRR: begin
			w_left_light = yellow;
			w_str_light  = yellow;
		end
		RRRGR: begin
			e_left_light = green;
			w_left_light = green;
		end
		RRRYR,RRRZR: begin
			e_left_light = yellow;
			w_left_light = yellow;
		end
		RRRRG: begin
			ns_light = green;
		end
		RRRRY,RRRRZ: begin
			ns_light = yellow;
		end
	  endcase
	end

endmodule