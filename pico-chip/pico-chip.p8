pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- pico-chip
-- @aquova
-- a chip-8 emulator written for pico-8

-- include p8 file with rom data
#include tetris.p8

-- constants
scrn={w=64,h=32}
num_keys=16
num_v=16
byte=8
digit=byte/2

function _init()
	poke(0x5f2d,1)
 chip8=init_cpu()
 paused=false
 chip8:load_game(game)
end

function _update60()
 if paused then return end

 clear_keys()
 while stat(30) do
 	handle_key(stat(31))
 end
 
 chip8:tick()
 
 if chip8.dt>0 then
 	chip8.dt-=1
 end
 
 if chip8.st>0 then
 	if chip8.st==1 then
 		-- beep here
 	end
 	chip8.st-=1
 end
end

function _draw()
	cls()
 for i=1,scrn.h*scrn.w do
 	local x=(i-1)%scrn.w
 	local y=flr((i-1)/scrn.w)
 	local pixel=chip8.gfx[i]
 	
 	local c=(pixel==1 and 7 or 0)
 	rectfill(
 		2*x,32+2*y,
 		2*(x+1),32+2*(y+1),
 		c
 	)
 end
end

local key_tbl={
	'x','1','2','3','q',
	'w','e','a','s','d',
	'z','c','4','r','f','v'
}

function index_of(tbl,key)
	for i,v in ipairs(tbl) do
		if v==key then
			return i
		end
	end
	return nil
end

function clear_keys()
	for i=0,15 do
		chip8:set_key(i,0)
	end
end

function handle_key(k)
 local key=index_of(key_tbl,k)
 if key~=nil then
 	chip8:set_key(key,1)
 end
end
-->8
-- cpu

local fontset={
 0xf0,0x90,0x90,0x90,0xf0, -- 0
 0x20,0x60,0x20,0x20,0x70, -- 1
 0xf0,0x10,0xf0,0x80,0xf0, -- 2
 0xf0,0x10,0xf0,0x10,0xf0, -- 3
 0x90,0x90,0xf0,0x10,0x10, -- 4
 0xf0,0x80,0xf0,0x10,0xf0, -- 5
 0xf0,0x80,0xf0,0x90,0xf0, -- 6
 0xf0,0x10,0x20,0x40,0x40, -- 7
 0xf0,0x90,0xf0,0x90,0xf0, -- 8
 0xf0,0x90,0xf0,0x10,0xf0, -- 9
 0xf0,0x90,0xf0,0x90,0x90, -- a
 0xe0,0x90,0xe0,0x90,0xe0, -- b
 0xf0,0x80,0x80,0x80,0xf0, -- c
 0xe0,0x90,0x90,0x90,0xe0, -- d
 0xf0,0x80,0xf0,0x80,0xf0, -- e
 0xf0,0x80,0xf0,0x80,0x80  -- f
}

function init_cpu()
	local cpu={}
	
	cpu.pc=0x200
	cpu.op=0
	cpu.i=0
	cpu.sp=1
	cpu.dt=0
	cpu.st=0
	cpu.stack={}
	
	cpu.gfx={}
	for i=1,scrn.h*scrn.w do
		cpu.gfx[i]=0
	end
	
	cpu.v={}
	for i=1,num_v do
		cpu.v[i]=0
	end
	
	cpu.mem={}
	for i=1,4096 do
		cpu.mem[i]=0
	end
	
	for i=1,80 do
		cpu.mem[i]=fontset[i]
	end
	
	cpu.keys={}
	for i=1,num_keys do
		cpu.keys[i]=0
	end
	
	-- since lua is 1-indexed,
	-- here are helper functions
	function cpu:get_v(n)
		return self.v[n+1]
	end
	
	function cpu:set_v(n,val)
		self.v[n+1]=val
	end
	
	function cpu:read_mem(addr)
		return self.mem[addr+1]
	end
	
	function cpu:write_mem(addr,val)
		self.mem[addr+1]=val
	end
	
	function cpu:get_key(key)
		return self.keys[key+1]
	end
	
	function cpu:set_key(key,val)
		self.keys[key+1]=val
	end
	
	function cpu:get_gfx(i)
		return self.gfx[i+1]
	end
	
	function cpu:set_gfx(i,val)
		self.gfx[i+1]=val
	end
	
	function cpu:push(val)
	 self.stack[self.sp]=val
	 self.sp+=1
	end
	
	function cpu:pop()
		self.sp-=1
		return self.stack[self.sp]
	end
	
	-- updates gfx for drawing pixel
	-- at (x,y). returns true if
	-- (x,y) went from set to cleared
	function cpu:draw_pixel(x,y)
		local idx=x+scrn.w*y
		local start=self:get_gfx(idx)
		local new=start^^1
		self:set_gfx(idx,new)
		return start==1
	end
	
	function cpu:load_game(rom)
		local idx=0x200
		for i=1,#rom do
			self:write_mem(idx+i-1,rom[i])
		end
	end
	
	function cpu:tick()
		local high=self:read_mem(self.pc)
		local low=self:read_mem(self.pc+1)
		self.op=(high<<8)|low
		self.pc+=2
		
		-- get opcode in form for array indexing
  local opcode=self.op&0xf000
  if opcode==0x0000 or opcode==0xe000 or opcode==0xf000 then
   local nn=self.op&0x00ff
   opcode|=nn
  elseif opcode==0x8000 then
   local n=self.op&0x000f
   opcode|=n
  end
  
  op[opcode](self)
	end
	
	return cpu
end
-->8
-- opcodes
op={}

-- 0x0000 - nop
op[0x0000]=function(c)
	return
end

-- 0x00e0 - cls
op[0x00e0]=function(c)
	for i=1,scrn.w*scrn.h do
		c.gfx[i]=0
	end
end

-- 0x00ee - ret
op[0x00ee]=function(c)
	c.pc=c:pop()
end

-- 0x1nnn - jmp nnn
op[0x1000]=function(c)
	local nnn=c.op&0x0fff
	c.pc=nnn
end

-- 0x2nnn - call nnn
op[0x2000]=function(c)
	local nnn=c.op&0x0fff
	c:push(c.pc)
	c.pc=nnn
end

-- 0x3xnn - skip next if vx==nn
op[0x3000]=function(c)
	local x=(c.op&0x0f00)>>byte
	local vx=c:get_v(x)
	local nn=c.op&0x00ff
	if vx==nn then
		c.pc+=2
	end
end

-- 0x4xnn - skip next if vx~=nn
op[0x4000]=function(c)
	local x=(c.op&0x0f00)>>byte
	local vx=c:get_v(x)
	local nn=c.op&0x00ff
	if vx~=nn then
		c.pc+=2
	end
end

-- 0x5xy0 - skip next if vx==vy
op[0x5000]=function(c)
 local x=(c.op&0x0f00)>>byte
	local vx=c:get_v(x)
	local y=(c.op&0x00f0)>>digit
	local vy=c:get_v(y)
	if vx==vy then
		c.pc+=2
	end
end

-- 0x6xnn - vx=nn
op[0x6000]=function(c)
	local nn=c.op&0x00ff
	local x=(c.op&0x0f00)>>byte
	c:set_v(x,nn)
end

-- 0x7xnn - vx+=nn
op[0x7000]=function(c)
	local x=(c.op&0x0f00)>>byte
	local nn=c.op&0x00ff
	local new_x=(c:get_v(x)+nn)%0x100
	c:set_v(x,new_x)
end

-- 0x8xy0 - vx=vy
op[0x8000]=function(c)
	local x=(c.op&0x0f00)>>byte
	local y=(c.op&0x00f0)>>digit
	local vy=c:get_v(y)
	c:set_v(x,vy)
end

-- 0x8xy1 - vx|=vy
op[0x8001]=function(c)
	local x=(c.op&0x0f00)>>byte
 local y=(c.op&0x00f0)>>digit
	local new_x=c:get_v(x)|c:get_v(y)
	c:set_v(x,new_x)
end

-- 0x8xy2 - vx&=vy
op[0x8002]=function(c)
	local x=(c.op&0x0f00)>>byte
 local y=(c.op&0x00f0)>>digit
	local new_x=c:get_v(x)&c:get_v(y)
	c:set_v(x,new_x)
end

-- 0x8xy3 - vx^=vy
op[0x8003]=function(c)
	local x=(c.op&0x0f00)>>byte
 local y=(c.op&0x00f0)>>digit
	local new_x=c:get_v(x)^^c:get_v(y)
	c:set_v(x,new_x)
end

-- 0x8xy4 - vx+=vy
op[0x8004]=function(c)
	local x=(c.op&0x0f00)>>byte
 local y=(c.op&0x00f0)>>digit
	local new_x=c:get_v(x)+c:get_v(y)
	local new_f=(new_x>0xff) and 1 or 0
	c:set_v(x,new_x%0x100)
	c:set_v(0xf,new_f)
end

-- 0x8xy5 - vx-=vy
op[0x8005]=function(c)
	local x=(c.op&0x0f00)>>byte
 local y=(c.op&0x00f0)>>digit
	local diff=c:get_v(x)-c:get_v(y)
	local carry=(diff>0) and 1 or 0
	c:set_v(x,diff%0x100)
	c:set_v(0xf,carry)
end

-- 0x8xy6 - vx>>=1
op[0x8006]=function(c)
	local x=(c.op&0x0f00)>>byte
	local vx=c:get_v(x)
	local lsb=vx&1
	c:set_v(x,vx>>1)
	c:set_v(0xf,lsb)
end

-- 0x8xy7 - vx=vy-vx
op[0x8007]=function(c)
	local x=(c.op&0x0f00)>>byte
 local y=(c.op&0x00f0)>>digit
	local diff=c:get_v(y)-c:get_v(x)
	local carry=(diff>0) and 1 or 0
	c:set_v(x,diff%0x100)
	c:set_v(0xf,carry)
end

-- 0x8xye - vx<<=1
op[0x800e]=function(c)
	local x=(c.op&0x0f00)>>byte
	local vx=c:get_v(x)
	local msb=(vx>>7)&1
	local new_x=(vx<<1)&0xff
	c:set_v(x,new_x)
	c:set_v(0xf,msb)
end

-- 0x9xy0 - skip next if vx~=vy
op[0x9000]=function(c)
 local x=(c.op&0x0f00)>>byte
	local vx=c:get_v(x)
	local y=(c.op&0x00f0)>>digit
	local vy=c:get_v(y)
	if vx~=vy then
		c.pc+=2
	end
end

-- 0xannn - i=nnn
op[0xa000]=function(c)
	c.i=c.op&0x0fff
end

-- 0xbnnn - jmp v0+nnn
op[0xb000]=function(c)
	local nnn=c.op&0x0fff
	c.pc=c:get_v(0)+nnn
end

-- 0xcxnn - vx=rnd()&n
op[0xc000]=function(c)
	local rand=flr(rnd(0x100))
 local x=(c.op&0x0f00)>>byte
 local nn=c.op&0x00ff
 c:set_v(x,rand&nn)
end

-- 0xdxyn - draw sprite at (vx,vy)
-- 8xn pixels, based on mem addr i
op[0xd000]=function(c)
 local x=(c.op&0x0f00)>>byte
	local vx=c:get_v(x)
	local y=(c.op&0x00f0)>>digit
	local vy=c:get_v(y)
	local n=c.op&0x000f
	
	local collision=false
	for y_line=0,n-1 do
		local pixel=c:read_mem(c.i+y_line)
		for x_line=0,7 do
			if pixel&(0x80>>x_line)~=0 then
				local status=c:draw_pixel((vx+x_line)%scrn.w,(vy+y_line)%scrn.h)
				collision=collision or status
			end
		end
	end
	local carry=collision and 1 or 0
	c:set_v(0xf,carry)
end

-- 0xex9e - skip next if key vx pressed
op[0xe09e]=function(c)
 local x=(c.op&0x0f00)>>byte
	local vx=c:get_v(x)
	if c:get_key(vx)==1 then
		c.pc+=2
	end
end

-- 0xexa1 - skip next if key vx released
op[0xe0a1]=function(c)
 local x=(c.op&0x0f00)>>byte
	local vx=c:get_v(x)
	if c:get_key(vx)~=1 then
		c.pc+=2
	end
end

-- 0xf007 - vx=dt
op[0xf007]=function(c)
 local x=(c.op&0x0f00)>>byte
 c:set_v(x,c.dt)
end

-- 0xf00a - await key press (blocking)
op[0xf00a]=function(c)
 local x=(c.op&0x0f00)>>byte
 local pressed=false
 for key=0,num_keys-1 do
 	if c:get_key(0)==1 then
 		c:set_v(x,key)
 		pressed=true
 		break
 	end
 end
 
 if not pressed then
 	-- redo opcode
 	c.pc-=2
 end
end

-- 0xfx15 - dt=vx
op[0xf015]=function(c)
 local x=(c.op&0x0f00)>>byte
 c.dt=c:get_v(x)
end

-- 0xfx18 - st=vx
op[0xf018]=function(c)
 local x=(c.op&0x0f00)>>byte
 c.st=c:get_v(x)
end

-- 0xfx1e - i+=vx
op[0xf01e]=function(c)
 local x=(c.op&0x0f00)>>byte
 c.i+=c:get_v(x)
end

-- 0xfx29 - i=spr location for vx
op[0xf029]=function(c)
 local x=(c.op&0x0f00)>>byte
 local char=c:get_v(x)
 c.i=char*5
end

-- 0xfx33 - store bcd of vx in mem addr i
op[0xf033]=function(c)
 local x=(c.op&0x0f00)>>byte
	local vx=c:get_v(x)
	c:write_mem(c.i,flr(vx/100))
	c:write_mem(c.i+1,flr((vx/10)%10))
	c:write_mem(c.i+2,flr(vx%10))
end

-- 0xfx55 - store v0-vx in mem addr i
op[0xf055]=function(c)
 local x=(c.op&0x0f00)>>byte
 for i=0,x do
 	local v=c:get_v(i)
 	c:write_mem(c.i+i,v)
 end
end

-- 0xfx65 - fill v0-vx with vals from mem addr i
op[0xf065]=function(c)
	local x=(c.op&0x0f00)>>byte
	for i=0,x do
		local v=c:read_mem(c.i+i)
		c:set_v(i,v)
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
