pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- fancy pong
-- @aquova

function _init()
	screen=128
	p1=newpaddle(8,screen/2-16)
	p2=newpaddle(screen-8-4,screen/2-16)
	b=newball(screen/2,screen/2)
end

function _update60()
	p1:update()
	p2:cpuupdate(b.y)
	b:update()
end

function _draw()
	cls(1)
	p1:draw()
	p2:draw()
	b:draw()
end
-->8
-- paddles

function newpaddle(startx,starty)
	local p={
		x=startx,
		y=starty,
		w=4,
		h=32,
		spd=1
	}
	
	-- call if player
	function p:update()
		if btn(⬆️) then
			p.y=max(0,p.y-p.spd)
		elseif btn(⬇️) then
			p.y=min(p.y+p.spd,screen-p.h)
		end
	end
	
	-- call if cpu
	function p:cpuupdate()
		local midpt=p.y+p.h/2
		if b.dx>0 then
			if b.y<midpt then
				p.y=max(0,p.y-p.spd)
			else
				p.y=min(p.y+p.spd,screen-p.h)
			end
		end
	end
	
	function p:draw()
		rectfill(p.x,p.y,p.x+p.w,p.y+p.h,7)
	end
	
	return p
end
-->8
-- ball

function newball(startx,starty)
	local b={
		x=startx,
		y=starty,
		dx=1,
		dy=1,
		size=4
	}
	
	function b:update()
		if b.x<=0 or b.x>=screen-b.size then
			b.dx*=-1
		elseif b.y<=0 or b.y>=screen-b.size then
			b.dy*=-1
		end
		
		b.x=mid(0,b.x+b.dx,screen-b.size)
		b.y=mid(0,b.y+b.dy,screen-b.size)
	end
	
	function b:draw()
		rectfill(b.x,b.y,b.x+b.size,b.y+b.size,7)
	end
	
	return b
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
