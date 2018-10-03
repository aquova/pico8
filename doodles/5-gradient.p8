pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function gradient(_x,_y,_w,_h,_c1,_c2)
	local c=_c1*16+_c2
	local patterns={0x0000,0x8282,0xe5a4,0x5a5a,0x1a5b,0xd7d7,0xffff}
	rectfill(_x,_y,_x+_w,_y+_h,c)
	for i=0,#patterns-1 do
		fillp(patterns[i+1])
		rectfill(_x,_y+i*(_h/#patterns),_x+_w,_y+(i+1)*(_h/#patterns)+1,c)
	end
end

cls()
gradient(0,0,128,128,3,11)
