pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- visual novel
-- by aquova

function _init()
	screen=128
	xmargin=10
	ymargin=10
	
	_upd=update_title
	_drw=draw_title
end

function _update()
	_upd()
end

function _draw()
	_drw()
end
-->8
-- main functions

function update_main()

end

function draw_main()
	cls()
	draw_borders()
end
-->8
-- title screen

function update_title()
	if btnp(❎) or btnp(🅾️) then
		_upd=update_main
		_drw=draw_main
	end
end

function draw_title()
	cls()
	printc(screen/2,"visual novel",12)
end
-->8
-- text
-->8
-- helper functions

-- print center
function printc(_y,_t,_c)
	print(_t,ctext(0,screen,_t),_y,_c)
end

-- calculate y-pos for centering text
function ctext(_x1,_x2,_t)
 return _x1+((_x2-_x1)/2)-#_t*2+1
end

-- takes in a text string, breaks into table of lines
function text2lines(_t)
	local lines={}
	-- 4 pixels / char
	local charperline=(screen-2*xmargin)/4
	for i=0,(#_t/charperline) do
		-- this may not be right
		add(lines,sub(_t,i*charperline,(i+1)*charperline-1))
	end
	return lines
end
-->8
-- drawing functions

function draw_borders()
	rect(xmargin/2,ymargin/2,screen-xmargin/2,0.75*screen-ymargin/2,9)
	rect(xmargin/2,0.75*screen+ymargin/2,screen-xmargin/2,screen-ymargin/2,9)
end
