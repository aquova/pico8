pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- doom fire
-- @aquova

-- https://fabiensanglard.net/doom_fire_psx/

pal({0,128,130,132,2,136,8,137,9,10,135,7},1)
cls()
print("@aquova",5,5,3)
line(0,127,127,127,12)
::★::
for x=0,127 do
	for y=127,64,-1 do
		local rx=flr(rnd(3))-1
		local rc=flr(rnd(3))==0 and 1 or 0
		local c=pget(x,y)
		pset(x+rx,y-1,max(c-rc,0))
	end
end
flip()
goto ★
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000