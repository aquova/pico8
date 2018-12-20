pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- snowman
-- @aquova

function _init()
	cartdata("aquova_snowman")
	
	screen=128
	reset_time=30 -- frames held before reset
	_upd=update_title
	_drw=draw_title
	
	load_data()	
	level_snow=0
	reset_frames=0
	
	transition=false
	title_ptr=0
	
	-- level select values
	lvl_margin={x=9,y=30}
	box_size=22
	row_num=(screen-2*lvl_margin.x)/box_size
	lvl_ptr=0
	
	board={}
	p1={} -- in board coords
	margin={}
end

function _update()
	_upd()
end

function _draw()
	_drw()
end
-->8
-- title screen / lvl select

function update_title()
	if btnp(🅾️) then
		if title_ptr==0 then
		 level=1
			init_level(level)
			_upd=update_main
			_drw=draw_main
		else
			-- add instructions here
			_upd=update_lvlselect
			_drw=draw_lvlselect
		end
	end

	if btnp(⬆️) then
		title_ptr=(title_ptr-1)%3
	elseif btnp(⬇️) then
		title_ptr=(title_ptr+1)%3
	end
end

function draw_title()
	cls(7)
	printc("snowman",screen/4,12)
	print("new game",25,screen/2,12)
	print("level select",25,screen/2+10,12)
	print("instructions",25,screen/2+20,12)
	print("🅾️",15,screen/2+10*title_ptr,4)
end

function update_lvlselect()
	local max_lvl=max_level()

	if btnp(🅾️) then
	 if lvl_ptr < max_lvl then
	 	level=lvl_ptr+1
	 	init_level(level)
			_upd=update_main
			_drw=draw_main
		end
	elseif btnp(❎) then
		_upd=update_title
		_drw=draw_title
	elseif btnp(⬅️) then
		lvl_ptr=(lvl_ptr-1)%max_lvl
	elseif btnp(➡️) then
		lvl_ptr=(lvl_ptr+1)%max_lvl
	elseif btnp(⬇️) then
		lvl_ptr=(lvl_ptr+row_num)%max_lvl
	elseif btnp(⬆️) then
		lvl_ptr=(lvl_ptr-row_num)%max_lvl
	end
end

function draw_lvlselect()
	-- this works really well for 20 levels
	cls(7)
	printc("level select",10,12)
	for lvl=0,max_level()-1 do
		local x=lvl_margin.x+box_size*(lvl%row_num)
		local y=lvl_margin.y+box_size*flr(lvl/row_num)
		rect(x,y,x+box_size-1,y+box_size-1,6)
		print(lvl+1,x+ctext(""..lvl+1,x,x+box_size),y+3,8)
		local score_txt=high_scores[lvl+1].."/"..get_max_score(lvl+1)
		print(score_txt,x+ctext(score_txt,x,x+box_size),y+12,8)
	end
	
	local ptr_x=lvl_margin.x+box_size*(lvl_ptr%row_num)
	local ptr_y=lvl_margin.y+box_size*flr(lvl_ptr/row_num)
	rect(ptr_x,ptr_y,ptr_x+box_size-1,ptr_y+box_size-1,10)
end
-->8
-- main game

function update_main()
	if transition then
		if btnp(🅾️) then
			if level==max_level() then
				_upd=update_title
				_drw=draw_title
				return
			end
			transition=false
			level+=1
			max_unlocked=max(max_unlocked,level) -- should save to cdata
			init_level(level)
		elseif btnp(❎) then
		 transition=false
			_upd=update_title
			_drw=draw_title
		end
		return
	end
	
	-- reset level if ❎ pressed
	if btn(❎) then
		reset_frames+=1
		if reset_frames==reset_time then
			reset_frames=0
			init_level(level)
		end
		return
	end

	reset_frames=0
	main_input()
	update_board()
	if not remaining_moves() then
		transition=true
		high_scores[level]=max(high_scores[level],level_snow)
		save_game()
	end
end

function main_input()
	-- store initial position
	local startx,starty=p1.x,p1.y
	if btnp(⬅️) then
		p1.x=max(1,p1.x-1)
	elseif btnp(➡️) then
		p1.x=min(p1.x+1,#board[1])
	end
	
	if btnp(⬆️) then
		p1.y=max(1,p1.y-1)
	elseif btnp(⬇️) then
		p1.y=min(p1.y+1,#board)
	end
	
	-- if move would move off snow, don't move
	if board[p1.y][p1.x]~=1 then
		p1.x,p1.y=startx,starty
		return
	end
	
	level_snow+=1
end

function update_board()
	if board[p1.y][p1.x]==1 then
		board[p1.y][p1.x]=2
	end
end

function remaining_moves()
	-- check if there are any moves left
	if p1.x > 1 and board[p1.y][p1.x-1]==1 then
		return true
	end
	
	if p1.x < #board[1] and board[p1.y][p1.x+1]==1 then
		return true
	end
	
	if p1.y > 1 and board[p1.y-1][p1.x]==1 then
		return true
	end
	
	if p1.y < #board and board[p1.y+1][p1.x]==1 then
		return true
	end
	
	return false
end
-->8
-- levels

-- level values:
-- these match up with sprite numbers
-- 1 - snow
-- 2 - grass
-- 3 - rock
-- 4 - ice
_levels={
	{
		{1,1,1,1,1},
		{1,1,1,1,1},
		{1,1,2,1,1},
		{1,1,1,1,1},
		{1,1,1,1,1}			
	},
	{
		{3,1,1,1,1,1,1,3},
		{1,1,1,1,1,1,1,1},
		{1,1,1,2,1,1,1,1},
		{1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1},
		{3,1,1,1,1,1,1,3},		
	},
	{
		{2,1,1,1,1},
		{1,1,1,1,1},
		{1,1,3,1,1},
		{1,1,3,1,1},
		{1,1,3,1,1},
		{1,1,1,1,1},
		{1,1,1,1,1},
	},
	{
		{3,3,1,1,1,3,3},
		{3,1,1,3,1,1,3},
		{1,1,1,1,1,1,1},
		{1,3,1,2,1,3,1},
		{1,1,1,1,1,1,1},
		{3,1,1,3,1,1,3},
		{3,3,1,1,1,3,3},
	}
}

_meta_levels={
	-- top score, start x, start y
	{24,3,3},
	{43,4,3},
	{31,1,1},
	{32,4,4}
}

function get_level(val)	
	return _levels[val]
end

function get_max_score(val)
	return _meta_levels[val][1]
end

function max_level()
 --return 20
	return #_levels
end

function init_level(val)
	level_snow=0
	board=copy_lvl(get_level(val))
	p1.x=_meta_levels[val][2]
	p1.y=_meta_levels[val][3]
	calc_margin(val)
end

function calc_margin(val)
	local current_board=get_level(val)
	margin.x=4*(screen/8-#current_board[1]-1)
	margin.y=4*(screen/8-#current_board-1)
end

-- makes a deep copy of src into tar
-- this is assuming a 2d array
function copy_lvl(_src)
	local _tar={}
	for row=1,#_src do
	 _tar[row]={}
	 for col=1,#_src[row] do
	 	_tar[row][col]=_src[row][col]
	 end
	end
	return _tar
end
-->8
-- drawing

function draw_main()
	cls(7)
	
	draw_bar()
	draw_board()
	draw_border()
	print("웃",margin.x+8*p1.x+1,margin.y+8*p1.y+1,12)

	if transition then
		draw_transition()
	end
	
	-- resetting level
	if reset_frames > 5 then
		local mes="hold ❎ to reset"
		printb(mes,ctext(mes,0,screen),screen/2-10,7,5)
		rectfill(screen/5,screen/2,4*screen/5,screen/2+10,8)
		local bar_width=(reset_frames/reset_time)*3*screen/5
		rectfill(screen/5+1,screen/2+1,screen/5+bar_width+1,screen/2+9,9)
	end
end

function draw_board()
	for y=1,#board do
		for x=1,#board[y] do
			spr(board[y][x],margin.x+8*x,margin.y+8*y)
		end
	end
end

function draw_border()
	for i=0,#board[1]+1 do
		spr(16,margin.x+8*i,margin.y)
		spr(16,margin.x+8*i,margin.y+8*(#board+1))
	end	

	for i=1,#board do
		spr(16,margin.x,margin.y+8*i)
		spr(16,margin.x+8*(#board[1]+1),margin.y+8*i)
	end	
end

function draw_bar()
	rectfill(0,0,screen,8,5)
	print("level: "..level,2,2,6)
	printr("size: "..level_snow,2,6)
end

function draw_transition()
		local lvl_max=get_max_score(level)
		rectfill(20,20,screen-20,screen-20,6)
		printc("level: "..level,30,12)
		printc("snowman size: "..level_snow,45,12)
		printc("possible max: "..lvl_max,55,12)
		if level_snow==lvl_max then
			printc("perfect score!",75,4)
		end
		
		printc("🅾️ next level",screen-40,4)
		printc("❎ main menu",screen-30,4)
end


-->8
-- utilities

-- calcs x for centering text between two values
function ctext(_t,_x1,_x2)
	return ((_x2-_x1)/2)-#_t*2
end

-- prints text to center of screen
function printc(_t,_y,_c)
	print(_t,ctext(_t,0,screen),_y,_c)
end

-- prints right aligned text
function printr(_t,_y,_c)
	local _x=screen-#_t*4-1
	print(_t,_x,_y,_c)
end

-- prints text with a border
function printb(_t,_x,_y,_cinner,_couter)
	for i=-1,1 do
		for j=-1,1 do
			print(_t,_x+i,_y+j,_couter)
		end
	end
	
	print(_t,_x,_y,_cinner)
end


-->8
-- saving local data

function save_game()
	-- save data format
	-- 0 - number of unlocked levels (default to 1)
 -- 1-#levels - player score of respective level
 dset(0,max_unlocked)
 for i,v in pairs(high_scores) do
 	dset(i,v)
 end
end

function load_data()
	-- if unitialized
	if dget(0)==0 then
		reset_data()
	else
		max_unlocked=dget(0)
		high_scores={}
		for i=1,max_level() do
			add(high_scores,dget(i))
		end
	end
end

function reset_data()
	dset(0,1)
	high_scores={}
	for i=1,20 do
	 add(high_scores,0)
		dset(i,0)
	end
end
__gfx__
0000000077777777bbbbbbbb44444444cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000077777777bbbbbbbb44444444c7cccc7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070077777777bbbbbbbb44444444ccccc7cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700077777777bbbbbbbb44444444cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700077777777bbbbbbbb44444444cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070077777777bbbbbbbb44444444cc7ccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000077777777bbbbbbbb44444444c7cccc7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000077777777bbbbbbbb44444444cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
