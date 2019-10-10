pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- demo
-- by @aquova

-- runs once, when program starts
function _init()
	screen=128

	dude={
		x=screen/2,
		y=screen/2,
		spd=2,
		size=8,
		sprite=1
	}

	other={
		x=20,
		y=50,
		size=8,
		sprite=2
	}
end

-- where math goes
-- runs once per frame
function _update()
	local startx,starty=dude.x,dude.y
	-- move left/right
	if btn(⬅️) then
		dude.x=max(dude.x-dude.spd,0)
	elseif btn(➡️) then
		dude.x=min(dude.x+dude.spd,screen-dude.size)
	end

	-- move up/down
	if btn(⬆️) then
		dude.y=max(dude.y-dude.spd,0)
	elseif btn(⬇️) then
		dude.y=min(dude.y+dude.spd,screen-dude.size)
	end
	
	if mget(flr(dude.x/8),flr(dude.y/8))~=0 then
		dude.x,dude.y=startx,starty
	end
end

-- where drawing to screen goes
-- runs once per frame
-- after _update
function _draw()
	cls(12)
	map(0,0,0,0,16,16)
	spr(dude.sprite,dude.x,dude.y)
	spr(other.sprite,other.x,other.y)
	print("x "..dude.x.." y "..dude.y,5,5,8)
end

-- returns true or false
-- if two objects will overlap
--[[
function is_colliding(
	thing1_x,
	thing1_y,
	thing1_w,
	thing1_h,
	thing2_x,
	thing2_y,
	thing2_w,
	thing2_h
)
	-- if any of the corners overlap, they must be touching
	if thing1_


end
]]
__gfx__
000000000aaaa9a00200e88000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000aaa9aaaa80090002000bbb00000aa00a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700aa0aa0a980a00a0000bb3b000a9990a90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770009a0aa0a9e007709000bb3b00a09999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000aaaaaaaa0907700e000bbbb0999889990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700a9a9aa9a00a00a08000bb300099890990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000aaa00aaa2000900800b3b000000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000009aaa9a0088e008200b3bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000b3bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000bbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000bb3b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000bb3b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000bbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000bb300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000b3bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0013000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0013000000030000000000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0013000000130000030000000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0013000000130000130000000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0013000000130000130000000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
