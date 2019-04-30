pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- ring
-- @aquova

function _init()
	screen=128
	frames=0
	health=3
	hcols={8,10,11}
	score=0
	
	p1={
		ang=0.25,
		irad=10,
		orad=50,
		blue=true
	}
	
	enemies={}
	
end

function _update60()
	frames+=1
	
	if frames%180==0 then
		frames=0
		add(enemies,newenemy())
	end


	if btn(➡️) then p1.ang-=0.01 end
	if btn(⬅️) then p1.ang+=0.01 end

	if btnp(❎) then p1.blue=not p1.blue end

	for e in all(enemies) do
		e:update()
		if e:checkcollision() then
			del(enemies,e)
			score+=1
		elseif e:isdead() then
			del(enemies,e)
			health-=1
			if health==0 then
				gameover()
			end
		end
	end
end

function _draw()
	cls(5)
	circfill(screen/2,screen/2,p1.orad,0)
	
	drawplayer()
	circfill(screen/2,screen/2,p1.irad,8)
	circ(screen/2,screen/2,p1.orad,hcols[health])

	for e in all(enemies) do
		e:draw()
	end
	
	printc(""..score,5,13)
end

function drawplayer()
	local x1,y1=polar2xy(p1.irad,p1.ang)
	local x2,y2=polar2xy(p1.orad,p1.ang)
	local c=p1.blue and 12 or 9
	
	line(x1,y1,x2,y2,c)
end

function newenemy()
	local e={}
	
	e.ang=rnd(1)
	e.rad=p1.irad
	e.spd=0.5
	e.size=3
	
	function e:draw()
		local x,y=polar2xy(self.rad,self.ang)
		circ(x,y,self.size,8)
	end

	function e:update()
		e.rad+=e.spd
	end
	
	function e:checkcollision()
		-- calc cross product, 0 if on line
		local x,y=polar2xy(self.rad,self.ang)
		-- outer xy
		local ox,oy=polar2xy(p1.orad,p1.ang)
		local ix,iy=polar2xy(p1.irad,p1.ang)
		
		local disto=dist(x,y,ox,oy)
		local disti=dist(x,y,ix,iy)
		
		return (disto+disti)-dist(ox,oy,ix,iy)<self.size
	end
	
	function e:isdead()
		return e.rad>=p1.orad
	end
	
	return e
end

function gameover()

end
-->8
-- utilities

function ctext(t,x1,x2)
	return ((x2-x1)/2)-#t*2
end

function printc(t,y,c)
	print(t,ctext(t,0,screen),y,c)
end

function dist(x1,y1,x2,y2)
	return sqrt((x1-x2)^2+(y1-y2)^2)
end

function polar2xy(rad,ang)
	local x=screen/2+rad*cos(ang)
	local y=screen/2+rad*sin(ang)
	
	return x,y
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
