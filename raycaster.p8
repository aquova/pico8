pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- raycasting
-- @aquova

-- based very heavily on this course:
-- https://courses.pikuma.com/courses/raycasting

-- constants
screen=128
pi=3.14
tile_size=8
num_rows=16
num_cols=16

fov_angle=60/360

strip_width=1
num_rays=screen/strip_width

function _init()
	grid=new_map()
	player=new_player()
	rays={}
	stars=gen_stars()
end

function _update()
	player:keys()
	player:update()
	castallrays()
end

function _draw()
	--cls()
	draw_bkgd()
	render3d()
	--[[
	grid:render()
	for ray in all(rays) do
		ray:render()
	end
	player:render()
	]]
end

function castallrays()
	local col=0
	local rayangle=player.rotangle-(fov_angle/2)
	rays={}

	for i=1,num_rays do
		local ray=new_ray(rayangle)
		ray:cast(col)
		add(rays,ray)
		rayangle+=fov_angle/num_rays
		col+=1
	end
end

-->8
-- map

function new_map()
	local m={}

	m.grid={
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,3,3,3,3,3,0,0,0,2,0,3,3,0,0,1},
		{1,0,0,0,0,0,0,0,0,2,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,2,0,0,0,0,0,1},
		{1,0,0,2,2,2,0,0,0,2,0,0,0,0,0,1},
		{1,0,0,2,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,2,0,0,0,0,0,2,2,2,2,2,2,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,4,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,4,0,0,2,2,2,0,0,4,0,2,0,0,1},
		{1,0,0,0,0,0,3,0,0,0,4,0,0,0,0,1},
		{1,0,0,0,0,0,3,0,0,0,4,0,0,0,0,1},
	 {1,0,0,0,0,0,3,0,0,0,4,0,0,0,0,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	}

	function m:getwallat(x,y)
		local indx=flr(x/tile_size)
		local indy=flr(y/tile_size)
		return self.grid[indy+1][indx+1]
	end

	function m:render()
		for y=1,num_rows do
			for x=1,num_cols do
				local tiley=(y-1)*tile_size
				local tilex=(x-1)*tile_size
				local col=self.grid[y][x]==1 and 12 or 7
				rectfill(tilex,tiley,tilex+tile_size-1,tiley+tile_size-1,col)
			end
		end
	end

	return m
end
-->8
-- player

function new_player()
	local p={}
	p.x=screen/2
	p.y=screen/2
	p.rad=2
	p.turndir=0 -- 1 if left, -1 if right
	p.walkdir=0 -- -1 if back, +1 if front
	p.rotangle=1/4
	p.spd=2
	p.rotspd=3/360

	function p:update()
		self.rotangle+=self.turndir*self.rotspd

		local movestep=self.walkdir*self.spd

	 local newx=self.x+cos(self.rotangle)*movestep
		local newy=self.y+sin(self.rotangle)*movestep

		if grid:getwallat(newx,newy)==0 then
			self.x=newx
			self.y=newy
		end
	end

	function p:keys()
		if btn(⬆️) then
			self.walkdir=1
		elseif btn(⬇️) then
			self.walkdir=-1
		else
			self.walkdir=0
		end

		if btn(➡️) then
			self.turndir=1
		elseif btn(⬅️) then
			self.turndir=-1
		else
			self.turndir=0
		end
	end

	function p:render()
		circfill(self.x,self.y,self.rad,8)
		-- line(
		-- 	self.x,
		-- 	self.y,
		-- 	self.x+cos(self.rotangle)*30,
		-- 	self.y+sin(self.rotangle)*30,
		-- 	9
		-- )
	end

	return p
end
-->8
-- ray

function new_ray(angle)
	local r={}

	r.angle=normalize(angle)
	r.wallhit={x=0,y=0}
	r.dist=0
	r.washitvertical=false
	r.hitwallcolor=0

	r.israydown=r.angle<1 and r.angle>0.5
	r.israyright=r.angle<0.25 or r.angle>0.75

	function r:cast(col)
		local xintercept, yintercept
		local delta={}

		-- horizontal ray intersection
		local foundhorzwallhit=false
		local horzwallhit={x=0,y=0}
		local horzwallcolor=0

		yintercept=flr(player.y/tile_size)*tile_size
		yintercept+=(self.israydown and tile_size or 0)
		xintercept=player.x+(yintercept-player.y)/tan(self.angle)

		delta.y=tile_size
		delta.y*=(not self.israydown and -1 or 1)

		delta.x=tile_size/tan(self.angle)
		delta.x*=((not self.israyright and delta.x>0) and -1 or 1)
		delta.x*=((self.israyright and delta.x<0) and -1 or 1)

		local nexthorztouch={x=xintercept,y=yintercept}

		if not self.israydown then
			nexthorztouch.y-=1
		end

		while (nexthorztouch.x>=0 and nexthorztouch.x<=screen and nexthorztouch.y>=0 and nexthorztouch.y<=screen) do
			local wallgridcontent=grid:getwallat(nexthorztouch.x,nexthorztouch.y)
			if wallgridcontent~=0 then
				foundhorzwallhit=true
				horzwallhit.x=nexthorztouch.x
				horzwallhit.y=nexthorztouch.y
				horzwallcolor=wallgridcontent
				break
			else
				nexthorztouch.x+=delta.x
				nexthorztouch.y+=delta.y
			end
		end

		-- vertical ray intersection
		local foundvertwallhit=false
		local vertwallhit={x=0,y=0}
		local vertwallcolor=0

		xintercept=flr(player.x/tile_size)*tile_size
		xintercept+=(self.israyright and tile_size or 0)

		yintercept=player.y+(xintercept-player.x)*tan(self.angle)

		delta.x=tile_size
		delta.x*=(not self.israyright and -1 or 1)

		delta.y=tile_size*tan(self.angle)
		delta.y*=((not self.israydown and delta.y>0) and -1 or 1)
		delta.y*=((self.israydown and delta.y<0) and -1 or 1)

		local nextverttouch={x=xintercept,y=yintercept}
		if not self.israyright then
			nextverttouch.x-=1
		end

		while (nextverttouch.x>=0 and nextverttouch.x<=screen and nextverttouch.y>=0 and nextverttouch.y<=screen) do
			local wallgridcontent=grid:getwallat(nextverttouch.x,nextverttouch.y)
			if wallgridcontent~=0 then
				foundvertwallhit=true
				vertwallhit.x=nextverttouch.x
				vertwallhit.y=nextverttouch.y
				vertwallcolor=wallgridcontent
				break
			else
				nextverttouch.x+=delta.x
				nextverttouch.y+=delta.y
			end
		end

		local horzhitdist=foundhorzwallhit and dist(player.x,player.y,horzwallhit.x,horzwallhit.y) or 9999
		local verthitdist=foundvertwallhit and dist(player.x,player.y,vertwallhit.x,vertwallhit.y) or 9999

		if verthitdist<horzhitdist then
			self.wallhit.x=vertwallhit.x
			self.wallhit.y=vertwallhit.y
			self.dist=verthitdist
			self.hitwallcolor=vertwallcolor
			self.washitvertical=true
		else
			self.wallhit.x=horzwallhit.x
			self.wallhit.y=horzwallhit.y
			self.dist=horzhitdist
			self.hitwallcolor=horzwallcolor
			self.washitvertical=false
		end
	end

	function r:render()
		line(player.x,player.y,self.wallhit.x,self.wallhit.y,8)
	end

	return r
end
-->8
-- utils

-- keep angle between 0 and 1
function normalize(ang)
	return ang%1
end

-- apparently pico-8 doesnt have tan builtin
function tan(ang)
	return sin(ang)/cos(ang)
end

-- find dist between two points
function dist(x1,y1,x2,y2)
	return sqrt((x2-x1)^2+(y2-y1)^2)
end
-->8
-- 3d

function render3d()
	for i=1,num_rays do
		local ray=rays[i]
		local dist=ray.dist*cos(ray.angle-player.rotangle)
		local distplane=(screen/2)/tan(fov_angle/2)

		local strip_height=abs((tile_size/dist)*distplane)
		local y=(screen/2)-(strip_height/2)
		
		local col=7
		if ray.hitwallcolor==2 then
			col=8
		elseif ray.hitwallcolor==3 then
			col=11
		elseif ray.hitwallcolor==4 then
			col=12
		end
		
		rectfill(
			(i-1)*strip_width,
			y,
			i*strip_width,
			y+strip_height,
			col
		)
	end
end

function draw_bkgd()
	cls()
	rectfill(0,screen/2,screen,screen,3)
	
	for star in all(stars) do
		pset(star.x,star.y,6)
	end
	
	circfill(3*screen/4,screen/4,15,7)
	circfill(3*screen/4+4,screen/4-4,10,0)	
end

function gen_stars()
	local stars={}
	for _=1,50 do
		local x=flr(rnd()*screen)
		local y=flr(rnd()*screen/2)
		add(stars,{x=x,y=y})
	end
	return stars
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
