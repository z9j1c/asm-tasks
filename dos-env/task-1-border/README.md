## Task: draw border via direct writing into process video memory

### Ver. 3

Version with several borders feature.

Code is divided into three procedures that require arguments through the stack:
+ `DrawEnclosuredBorders(x, y, h, w)` - takes start position and height/width for the external border and draws several borders
+ `DrawBorder(x, y, h, w)` - takes start position and height/width for the current border and draws the border
+ `DrawLine(len, left_sym, mid_sym, right_sym)` - takes length, left, middle and right symbols and draws line with given symbols

### Ver. 2

Border drawing based on ASM macro that requires three symbols and length for drawing single horizontal line.

The problem is divided into three parts:
+ Top line
+ Middle lines
+ Bottom line

#### Ver. 1

Knotty code with three auxiliary procedures:
+ `HorLineDraw` - draw horizontal line
+ `VertLineDraw` - draw vertical line
+ `FillRect` - fill middle rectangle within the border

All these procedures require correctly set `se:di`, `ax`, `cx` for direct writing into video memory as long as `cx` isn't zero.