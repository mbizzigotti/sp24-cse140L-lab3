package light_package;

// colors = 2'b00 mapped to red, etc.
// colors = 2'b11 mapped to itself (no color name)
typedef enum logic[1:0] {red,yellow,green} colors;

endpackage