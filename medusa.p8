pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- medusa
-- @aquova

function _init()
	screen=128
	
	p1=init_player(screen/2,screen/2)
end

function _update()
	p1:move()
end

function _draw()
	cls(12)
	p1:draw()
end
-->8
-- player

function init_player(startx,starty)
	local p={x=startx,y=starty}
	p.size=8
	
	p.move=function(this)
		if (btn(⬆️)) p.y=max(0,p.y-1)
		if (btn(⬇️)) p.y=min(screen-p.size,p.y+1)
		if (btn(➡️)) p.x=min(screen-p.size,p.x+1)
		if (btn(⬅️)) p.x=max(0,p.x-1)
	end
	
	p.draw=function(this)
		spr(1,p.x,p.y)
	end
	
	return p
end
-->8
-- medusa
__gfx__
000000000aaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000aaaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700aa0aa0aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000aaaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000aaaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700aaa000aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000aaaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000