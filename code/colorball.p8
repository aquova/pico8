pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
width=128
height=128
rad=3
cols={}

function _init()
	cls()
	x=width/2
	y=height/2
	cols[0]=0
	cols[8]=9
	cols[9]=10
	cols[10]=6
	cols[6]=5
	cols[5]=0
end

function _update()
	if btn(0) then
		x-=2
		if x < 0 then
		 x=0
		end
	end
	if btn(1) then
		x+=2
		if x > width then
		 x=width
		end
	end
	if btn(2) then
		y-=2
		if y < 0 then
		 y=0
		end
	end
	if btn(3) then
		y+=2
		if y > height then
		 y=height
		end
	end

	
	for i=0,2000 do
		local x=flr(rnd(width))
		local y=flr(rnd(height))
		col=pget(x,y)
		pset(x,y,cols[col])
	end
end

function _draw()
	circfill(x,y,rad,8)
end
