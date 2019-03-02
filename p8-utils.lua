-- p8-utils
-- Helpful functions for Pico-8
-- by aquova, 2019


--[[
Usage:
On Pico-8 0.1.12 or later, simply put this file in the same directory as your
cart, and add this line at the top of the file:
#INCLUDE p8-utils.lua
--]]

-- Pico-8 screen size
local scrn=128

--[[
ctext
Calculates x-value for centering text

Params:
_t:  Text
_x1: Left-hand x-value
_x2: Right-hand x-value
--]]
function ctext(_t, _x1, _x2)
    return ((_x2-_x1)/2-#_t*2)
end

--[[
printc
Prints center-aligned text

Params:
_t: Text to print
_y: Y-position for text
_c: Color
--]]
function printf(_t, _y, _c)
    print(_t, ctext(_t, 0, scrn), _y, _c)
end

--[[
printr
Prints right-aligned text

Params:
_t: Text to print
_y: Y-position for text
_c: Color
--]]
function printr(_t, _y, _c)
    local _x = scrn - #_t * 4 - 1
    print(_t, _x, _y, _c)
end
