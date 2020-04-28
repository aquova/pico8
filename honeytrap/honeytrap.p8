pico-8 cartridge // http://www.pico-8.com
version 21
__lua__
-- honeytrap
-- by austin and kristin

-- global consts
screen=128
half_scrn=screen/2
mapsize={w=4*screen,h=2*screen}
trans_c=14
maxpts=20
max_shdw=5
max_parallax=20

fade_tbl={0,1,1,2,1,13,6,4,4,9,3,13,14}

function _init()
	frames=0
	set_trans()

	_upd=update_title
	_drw=draw_title
	init_title()
end

function _update()
	frames+=1
	_upd()
end

function _draw()
	_drw()
end

function init_main()
	bee=make_bee(half_scrn,half_scrn,bee_states.flying)
	pollen_g=new_gauge(screen-15,10,10,screen-20,9)
	flowers={}
	-- todo: make this a loop
	add(flowers,new_flower(50,50))
	add(flowers,new_flower(0,0))
	add(flowers,new_flower(100,100))
	add(flowers,new_flower(100,0))
	add(flowers,new_flower(0,100))
	
	tar_f_idx=ceil(rnd(#flowers))
	
	cam={
		x=bee.x-half_scrn,
		y=bee.y-half_scrn
	}
	camera(cam.x,cam.y)
end

function update_main()
	bee:update()
	set_cam()
end

function draw_main()
	cls(3)
	for f in all(flowers) do
		f:draw()
	end
	--pollen_g:draw()
	bee:draw()
	local f=flowers[tar_f_idx]
	draw_arrow(bee.x,bee.y,f.x,f.y,f.size)
end

function set_cam()
	-- i have no idea why i need to round x
	-- without it, the x is very twitchy
	-- but if you round y, then y becomes twitchy
	cam.x=round(bee.x-half_scrn)
	cam.y=bee.y-half_scrn
	camera(cam.x,cam.y)
end

function set_trans()
	palt(0,false)
	palt(trans_c,true)
end

function draw_debug()
	cursor(cam.x+5,cam.y+5,8)
	print("pos "..bee.x.. " "..bee.y)
end
-->8
-- bee stuff

bee_states={
	flying=0,
	landing=1,
	landed=2,
	liftoff=3,
	demo=4
}

function make_bee(_x,_y,_state)
	local b={
		x=_x,
		y=_y,
		a=rnd(1),
		spd=1,
		a_spd=0.03,
		spt=1,
		size=8,
		state=_state,
		pts=queue(),
		buf={x=24,y=0}, -- pixel coords on sprite map
		shdw=(_state==bee_states.demo and 1 or max_shdw),
		pollen=0,
		my_flower=nil,
	}

	function b:update()
		if self.state==bee_states.flying then
			self:rot()
			self:move()
			--sfx(0) -- oh dear god
			if btnp(❎) then
				bee:tryland(flowers)
			end
		elseif self.state==bee_states.landed then
			self:rot()
			if btnp(❎) then
				self.state=bee_states.liftoff
				self.my_flower=nil
			end
		elseif self.state==bee_states.landing then
			self.shdw-=1
			self.x+=1
			self.y+=1
			if self.shdw==1 then
				self.state=bee_states.landed
			end
			self:addlines()
		elseif self.state==bee_states.liftoff then
			self.shdw+=1
			self.x-=1
			self.y-=1
			if self.shdw==max_shdw then
				self.state=bee_states.flying
			end
			self:addlines()
		elseif self.state==bee_states.demo then
			local rng=flr(rnd(10))
			if rng==0 then
				self:forward()
			elseif frames%5==0 then
				-- returns +1 or -1
				local mag=sgn(rnd(2)-1)
				self.a+=mag*self.a_spd
			end
		end
	end

	function b:rot()
		local moved=false
		if btn(⬅️) then
			self.a-=self.a_spd
			moved=true
		end
		if btn(➡️) then
			self.a+=self.a_spd
			moved=true
		end
		self.a%=1

		if btn(⬆️) and self.state==bee_states.landed then
			self:forward()
			self:addlines()
			moved=true
		end

		if moved and self.state==bee_states.landed then
			local shx=self.x+self.size/2+self.shdw
			local shy=self.y+self.size/2+self.shdw

			if self.my_flower==flowers[tar_f_idx] then
				if frames%10==0 then
					self.pollen+=10
					pollen_g:update(self.pollen)
				end
			end

			if not self.my_flower:onflower(shx,shy) then
				self.state=bee_states.liftoff
				self.my_flower=nil
			end
		end
	end

	function b:move()
		self:forward()
		self:anim()
		self:addlines()
	end

	function b:forward()
		local dx=self.spd*cos(self.a)
		local dy=self.spd*-sin(self.a)
		--self.x=round(self.x+dx)
		self.x+=dx
		self.y+=dy
	end

	function b:tryland(_flowers)
		local shx=self.x+self.size/2+self.shdw
		local shy=self.y+self.size/2+self.shdw

		for f in all(_flowers) do
			if f:onflower(shx,shy) then
				self.state=bee_states.landing
				self.my_flower=f
				return
			end
		end
	end

	function b:addlines()
		if self.pts:len()>maxpts then
			self.pts:pop()
		end

		if frames%10>5 then
			local lx=self.x+self.size/2
			local ly=self.y+self.size/2
			self.pts:push({x=lx,y=ly})
		end
	end

	function b:anim()
		if frames%4>2 then
			self.spt=1
		else
			self.spt=2
		end
	end

	function b:draw()
		self:drawlines()
		self:drawshadow()
		self:drawbee()
	end

	function b:drawbee()
		local sx=(self.spt%16)*8
		local sy=flr(self.spt/8)*8
		rspr(
			sx,sy,
			self.size,self.size,
			self.x+self.size/2,
			self.y+self.size/2,
			self.a,false
		)
	end

	function b:drawshadow()
		local sx=(self.spt%16)*8
		local sy=flr(self.spt/8)*8

		rspr(
			sx,sy,
			self.size,self.size,
			self.x+self.size/2+self.shdw,
			self.y+self.size/2+self.shdw,
			self.a,true
		)
	end

	function b:drawlines()
		for p in b.pts:iter() do
			pset(p.x,p.y,0)
		end
	end

	return b
end
-->8
-- flower stuff

function new_flower(_x,_y)
	local f={
		x=_x,
		y=_y,
		size=16, -- in pixels
		leaf_spt=7,
		spt_x=40,
		spt_y=0
	}

	function f:draw()
		local cx,cy=get_center_screen()
		local dx,dy=self.x-cx,self.y-cy
		local px,py=dx/half_scrn,dy/half_scrn
		local fx,fy=px*max_parallax,py*max_parallax

		local gnd_x,gnd_y=self.x+8,self.y+4
		local leaf_x,leaf_y=self.x+fx/2,self.y+fy/2-4
		local flower_x=self.x+fx-self.size/2
		local flower_y=self.y+fy-self.size/2
		line(gnd_x,gnd_y,leaf_x+8,leaf_y+4,4)
		spr(self.leaf_spt,leaf_x-8,leaf_y,2,2)
		spr(self.leaf_spt,leaf_x+8,leaf_y,2,2,true,false)
		line(flower_x+self.size,flower_y+self.size,4)
		sspr(
			self.spt_x,self.spt_y,
			self.size,self.size,
			flower_x,
			flower_y,
			2*self.size,2*self.size
		)
	end

	function f:getcenter()
		local cx=self.x+self.size/2
		local cy=self.y+self.size/2
		return cx,cy
	end

	function f:onflower(x,y)
		local cx,cy=self:getcenter()
		local d=dist(x,y,cx,cy)
		return d<=self.size/2
	end

	return f
end
-->8
-- gauges

function new_gauge(_x,_y,_w,_h,_c)
	local g={
		x=_x,
		y=_y,
		w=_w,
		h=_h,
		col=_c,
		val=0 -- in %
	}

	function g:draw()
		local gx=cam.x+self.x
		local gy=cam.y+self.y

		-- draw background
		rectfill(
			gx,
			gy-1,
			gx+self.w,
			gy+self.h+1,
			0
		)
		rectfill(
			gx-1,
			gy,
			gx+self.w+1,
			gy+self.h,
			0
		)

		-- draw fluid level
		if flr(self.val)>0 then
			local fh=ceil(self.val*(self.h/100))
			local fy=cam.y+self.y+(self.h-fh)
			rectfill(
				gx+1,
				fy,
				gx+self.w-1,
				gy+self.h,
				self.col
			)
			rectfill(
				gx,
				fy+1,
				gx+self.w,
				gy+self.h-1,
				self.col
			)
		end

		line(gx+self.w/2,gy+2,gx+self.w-2,gy+2,7)
		pset(gx+self.w-1,gy+3,7)
	end

	function g:update(_v)
		local nv=mid(0,_v,100)
		self.val=nv
	end

	return g
end
-->8
-- utils

function queue()
	local q={
		data={}
	}

	function q:push(_val)
		add(self.data,_val)
	end

	function q:pop()
		local val=self.data[1]
		del(self.data,val)
		return val
	end

	function q:get(_i)
		return self.data[_i]
	end

	function q:len()
		return #q.data
	end

	function q:iter()
		return all(self.data)
	end

	return q
end

-- manhattan dist
function dist(_x1,_y1,_x2,_y2)
	local dx=abs(_x1-_x2)
	local dy=abs(_y1-_y2)
	return dx+dy
end

function get_center_screen()
	local cx=cam.x+half_scrn
	local cy=cam.y+half_scrn
	return cx,cy
end

function fade(_num)
	pal()
	for i=1,15 do
		local col=i
		for _=1,_num do
			col=fade_tbl[col]
			pal(i,col)
		end
	end
end

-- sprite rotation
-- from jwinslow23 on discord
-- modified to take extra shdw paramter
-- if true, draws "shadow" rather than sprite
-- _sx and _sy are sprite number (in pixels)
-- _sw and _sh are size in pixels
-- _dx and _dy are screen coords of center of sprite
-- _a is angle
function rspr(_sx,_sy,_sw,_sh,_dx,_dy,_a,_shdw)
	local cw,ch=(_sw+.5)/2,(_sh+.5)/2
	local sa,ca=sin(_a),cos(_a)
	local r=sqrt(cw*cw+ch*ch)
	for x=-r,r do
		for y=-r,r do
			local xx=x*ca-y*sa+cw
			if (xx>=0 and xx<_sw) then
				local yy=x*sa+y*ca+ch
				if (yy>=0 and yy<_sh) then
					local c=sget(_sx+xx,_sy+yy)
					if c~=trans_c then
						if _shdw then
							c=pget(_dx+x-0.5,_dy+y)
							pset(_dx+x-0.5,_dy+y,fade_tbl[c])
						else
							pset(_dx+x-0.5,_dy+y,c)
						end
					end
				end
			end
		end
	end
end

-- centers text between x1 and x2
function ctext(_t,_x1,_x2)
	return ((_x2-_x1)/2)-#_t*2
end

-- prints text w/border
function printb(_t,_x,_y,_ci,_co)
	for i=-1,1 do
		for j=-1,1 do
			print(_t,_x+i,_y+j,_co)
		end
	end
	
	print(_t,_x,_y,_ci)
end

function round(_x)
	local frac=_x-flr(_x)
	if frac<0.5 then
		return flr(_x)
	else
		return ceil(_x)
	end
end
-->8
-- title screen

function init_title()
	demo_bees=make_demo_bees()
end

function update_title()
	for bee in all(demo_bees) do
		bee:update()
	end

	if btnp(❎) or btnp(🅾️) then
		_upd=update_main
		_drw=draw_main
		init_main()
	end
end

function draw_title()
	cls()
	map(0,0,0,0,16,16)
	--[[
	local text="honeytrap"
	local tx=ctext(text,0,screen)
	printb("honeytrap",tx,half_scrn-4,0,7)
	--]]
	sspr(0,32,64,32,35,48)
	for bee in all(demo_bees) do
		bee:draw()
	end
end

function make_demo_bees()
	-- todo: make this a loop
	local b1=make_bee(
		flr(rnd(half_scrn)),
		flr(rnd(half_scrn)),
		bee_states.demo)

	local b2=make_bee(
		flr(rnd(half_scrn)+half_scrn),
		flr(rnd(half_scrn)),
		bee_states.demo)

	local b3=make_bee(
		flr(rnd(half_scrn)),
		flr(rnd(half_scrn)+half_scrn),
		bee_states.demo)

	local b4=make_bee(
		flr(rnd(half_scrn)+half_scrn),
		flr(rnd(half_scrn)+half_scrn),
		bee_states.demo)

	return {b1,b2,b3,b4}
end
-->8
-- misc drawing

function draw_arrow(_bx,_by,_tx,_ty,_tsize)
	local spr_x=_bx+4
	local spr_y=_by-10

	local d=dist(_bx,_by,_tx,_ty)
	if d<=_tsize then
		spr(20,spr_x-4,spr_y-4)
	else
		local dx,dy=_tx-_bx,_by-_ty
		local ang=atan2(dx,dy)
		rspr(24,8,8,8,spr_x,spr_y,ang,false)
	end
end
__gfx__
00000000eee666eeeeeeeeee0000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
00000000eee666eeeee666ee0000000000000000eeeeee99ee99eeeeeeeeeeebbbbbeeee00000000000000000000000000000000000000000000000000000000
00700700ea0a0aeeea0a0aee0000000000000000eee999aa99aa9eeeeeeeeebbbbbbbeee00000000000000000000000000000000000000000000000000000000
000770000a0a0a000a0a0a000000000000000000ee9aa9aa9aaa9eeeeeeeebb3bbbbbeee00000000000000000000000000000000000000000000000000000000
000770000a0a0a000a0a0a000000000000000000ee9aaa4444a999eeeeeebbbb3bbbbbee00000000000000000000000000000000000000000000000000000000
00700700ea0a0aeeea0a0aee0000000000000000ee9994fff44aaa9eeeebbbbbb3bb3bee00000000000000000000000000000000000000000000000000000000
00000000eee666eeeee666ee0000000000000000e9aa4ff44444aa9eeebbbbbbb3bb3bbe00000000000000000000000000000000000000000000000000000000
00000000eee666eeeeeeeeee0000000000000000e9aa4f44444499eeebb333333333333300000000000000000000000000000000000000000000000000000000
3333333333388333333cc333eee00eeeee0000eeee9944444444aa9eebbbbbb3bbb3bbbb00000000000000000000000000000000000000000000000000000000
333333333388883333cccc33eee080eee0bbbb0ee9aa44444444a99eeebbbb33bbb3bbbe00000000000000000000000000000000000000000000000000000000
33333333388998833cc11cc3eee0880e0bbbb0b0e9aaa444444a99eeeeebbbb3bb3bbbee00000000000000000000000000000000000000000000000000000000
33333333388998833cc11cc3000088800bbb0bb0e9aa9a44449aa9eeeeeebb3bbb3bbbee00000000000000000000000000000000000000000000000000000000
333333333388883333cccc33000088800b0b0bb0ee999aa9aa9aa9eeeeeeebbbb3bbbeee00000000000000000000000000000000000000000000000000000000
3333333333388333333cc333eee0880e0bb0bbb0eeee9aa9aa999eeeeeeeeebbbbbbbeee00000000000000000000000000000000000000000000000000000000
333333333333bb3333bb3333eee080eee0bbbb0eeeeee99e99eeeeeeeeeeeeebbbbbeeee00000000000000000000000000000000000000000000000000000000
333333333333b333333b3333eee00eeeee0000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
aaaa44444aaaaaaaaaaa44444aaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaa4999994aaaaaaaaa4aaaaa4aaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa499999994aaaaaaa4aaaaaaa4aaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a49999999994aaaaa4aaaaaaaaa4aaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
49999999999944444aaaaaaaaaaa4444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a49999999994aaaaa4aaaaaaaaa4aaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa499999994aaaaaaa4aaaaaaa4aaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaa4999994aaaaaaaaa4aaaaa4aaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaa4aaaaaaaaaaa44444aaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaaa4aaaaaaaaaaaaaaaaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaaaa4aaaaaaaaaaaaaaaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaaaaa4aaaaaaaaaaaaaaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaaaaaa4aaaaaaaaaaaaaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaaaaa4aaaaaaaaaaaaaaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaaaa4aaaaaaaaaaaaaaaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaaa4aaaaaaaaaaaaaaaaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee0eeee0eeeeeeeeeeeeeeeeeeeeeeeee00000000000eeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee0eeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee0eeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee0eeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee0eeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee0eeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee0eeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee0eeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee0eeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee0eeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee0eeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee0eeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee0eeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee0eeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee0eeee0000000eee00000000e0eeee0eeeeee0eee0eee0ee00000000000eee0000000000000000000000000000000000000000000000000000000000000000
eee0eeee0eeeee00000eeeeee0e0eeee0eeeeee0eee0e00eeeeeee00eeee0eee0000000000000000000000000000000000000000000000000000000000000000
eee0eeee0eeeee0eee0eeeeee0e0eeee0eeeeee0eee00eeeeeee0000eeee0eee0000000000000000000000000000000000000000000000000000000000000000
eee0eeee0eeeee0eee00000000e0eeee0eeeeee0eee0eeeee000ee00eeee0eee0000000000000000000000000000000000000000000000000000000000000000
eee0eeee0eeeee0eee0eeeeeeee0eeee0eeeeee0eee0eeeee0eeee0000000eee0000000000000000000000000000000000000000000000000000000000000000
eee0eeee0eeeee0eee0eeeeeeee0eeee0eeeeee0eee0eeeee0eeee00eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee0eeee0eeeee0eee0eeeeeeee0eeee0eeeeee0eee0eeeee0eeee00eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee0eeee0000000eee000000000000000eeeeee0eee0eeeee0000000eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeee0eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeee0eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeee0eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeee0eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
__map__
2223222322232223222322232223222300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2223202122232223222322232223222300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2223222322232223222322232223222300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2223222322232223222322232223222300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2223222322232223222320212223222300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2223222322232223222322232223222300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2223223132333233323332333223222300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2223223130303030303030303023202100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2223223130303030303030303023222300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2021223130303030303030303023222300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2223222322232223222322232223222300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2223222322232223222322232021222300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2223202122232223222320212223222300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2223222322232223222322232223222300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2223222322232223222322232223222300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2223222322232021222322232223222300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000d2200f22011220112201022010220112200f2000f2000e2000e2000f2000f2000f2000e2000f20010200102000f2000e2000d2000d2000c2000c2000c20000000000000000000000000000000000000
