pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
::◆::
cls()
srand() 
-- draw moon
circfill(32,60,18,7)
circfill(38,60,16,0)

-- draw sail
for i=0,13 do 
	line(84,85+i,84+i*.7,85+i,7)
end

for x=0,128 do 
	-- draw boat
	rectfill(80,99,95,98,12)
	-- draw stars
	pset(rnd(128),rnd(95),5+rnd(2))
	-- draw water and reflection
	for y=99,128 do 
		pset(x,y,mid(pget(x+sin(t()*.4+x*8+y*.4)*2,398-y*3),6,1))
	end 
end 
flip()
goto ◆
