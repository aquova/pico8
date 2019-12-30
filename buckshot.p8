pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- buckshot
-- @aquova

-- consts
screen=128
border=5
bottom=25

function _init()
	_upd=update_main
	_drw=draw_main
	palt(0,false)
	
	reset_game()
end

function _update()
	_upd()
end

function _draw()
	_drw()
end
-->8
-- main behavior

function update_main()
	if not bottom_sel then
		if btnp(⬅️) then
			sel=(sel-1)%9
		elseif btnp(➡️) then
			sel=(sel+1)%9
		end
		
		if btnp(🅾️) then
			local num=sel+1
			if contains(num,curr_down) then
				curr_roll+=num
				nums[num]=true
				del(curr_down,num)
				del(down,num)
			end
		end
	end
	
	if btnp(⬆️) then
		bottom_sel=false
	elseif btnp(⬇️) and curr_roll==0 then
		bottom_sel=true
	end
	
	if btnp(❎) then
		local num=sel+1
		if bottom_sel then
			for die in all(dice) do
				die:roll()
			end
			bottom_sel=false
			curr_roll=calc_roll()
			curr_down={}
		elseif curr_roll-num>=0 and not contains(num,down) then
			curr_roll-=num
			nums[num]=false
			add(curr_down,num)
			add(down,num)
		end
	end
end

function reset_game()
	nums={}
	for i=1,9 do
		nums[i]=true
	end
	
	sel=0
	bottom_sel=false
	
	dice={}
	for _=1,2 do
		local die=new_die()
		die:roll()
		add(dice,die)
	end
	
	curr_roll=0
	curr_down={}
	down={}
end

function calc_roll()
	local total=0
	for die in all(dice) do
		total+=die:get_roll()
	end
	return total
end

function contains(val,tbl)
	for i in all(tbl) do
		if i==val then
			return true
		end
	end
	return false
end

-- this is the subset sum problem
-- this is not how you do the subset sum problem well
-- however, there are only 9 values max, so eh.
function calc_moves(roll)
	local values={}
	for i=1,#nums do
		if nums[i] then
			add(values,i)
		end
	end
	
	
end
-->8
-- drawing

function draw_main()
	cls(4)
	rectfill(
		border,
		border,
		screen-border,
		screen-border,
		3
	)
	
	for i=0,8 do
			draw_num(7+i*13,8,i+1)
	end
	
	rectfill(0,bottom,screen,bottom+border,4)
	
	if bottom_sel then
		rect(border,bottom+border,screen-border,screen-border,8)
	end
	
	for die in all(dice) do
		die:draw()
	end
end

function draw_num(x,y,n)
	if nums[n] then
		if sel+1==n and not bottom_sel then
			rectfill(x-1,y-1,x+11,y+18,8)
		end
		rectfill(x,y,x+10,y+18,0)
		rectfill(x+1,y+1,x+9,y+18,7)
		print(n,x+4,y+3,0)
	else
		if sel+1==n and not bottom_sel then
			rectfill(x-1,y+14,x+11,y+18,8)
		end
		rectfill(x,y+15,x+10,y+18,0)
		rectfill(x+1,y+16,x+9,y+18,7)
	end
end

function draw_dice(x,y,n)
	rectfill(x,y,x+10,y+10,0)
	rectfill(x+1,y+1,y+9,y+9,7)
end
-->8
-- dice

function new_die()
	local die={
		x=bottom,
		y=bottom,
		size=11,
		n=1
	}
	
	function die:roll()
		self.n=flr(rnd(5))+1
		self.x=flr(
			rnd(
				screen-self.size-2*border
		 ))+border
		 
		self.y=flr(
			rnd(
				screen-bottom-self.size-2*border
			))+bottom+border
	end
	
	function die:draw()
		rectfill(
			self.x,
			self.y,
			self.x+self.size,
			self.y+self.size,
			0
		)
		rectfill(
			self.x+1,
			self.y+1,
			self.x+self.size-1,
			self.y+self.size-1,
			7
		)
		spr(self.n,self.x+2,self.y+2)
	end
	
	function die:get_roll()
		return self.n
	end
	
	return die
end
-->8
-- title screen

function update_title()

end

function draw_title()

end
__gfx__
00000000777777777777777777777777777777777777777770077007000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777777007777770077777700770077007700770077007000000000000000000000000000000000000000000000000000000000000000000000000
00700700777777777007777770077777700770077007700777777777000000000000000000000000000000000000000000000000000000000000000000000000
00077000777007777777777777700777777777777770077770077007000000000000000000000000000000000000000000000000000000000000000000000000
00077000777007777777777777700777777777777770077770077007000000000000000000000000000000000000000000000000000000000000000000000000
00700700777777777777700777777007700770077007700777777777000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777777777700777777007700770077007700770077007000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777777777777777777777777777777777777770077007000000000000000000000000000000000000000000000000000000000000000000000000
