pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- snowman
-- @aquova

function _init()
	cartdata("aquova_snowman")
	menuitem(2,"main menu",return_2_title)
	menuitem(3,"level select",goto_lvlselect)

	screen=128
	reset_time=30 -- frames held before reset

 max_unlocked=1
	load_data()
	level_snow=0
	reset_frames=0

	transition=false
	trans_y=-100
	title_ptr=0
	snowflakes={}

	-- level select values
	lvl_margin={x=9,y=30}
	box_size=22
	row_num=(screen-2*lvl_margin.x)/box_size
	lvl_ptr=0

	board={}
	p1={} -- in board coords
	margin={}
	
	-- set transparent colors
	palt(0,false)
	palt(14,true)
	
	create_snow()
	_upd=update_title
	_drw=draw_title
end

function _update()
	_upd()
end

function _draw()
	_drw()
end

-- menu item functions
function return_2_title()
	_upd=update_title
	_drw=draw_title
end

function goto_lvlselect()
 lvl_ptr=0
	_upd=update_lvlselect
	_drw=draw_lvlselect
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
			sfx(0)
		else
			_upd=update_lvlselect
			_drw=draw_lvlselect
			sfx(2)
		end
	end

	if btnp(⬆️) then
		title_ptr=(title_ptr-1)%2
		sfx(3)
	elseif btnp(⬇️) then
		title_ptr=(title_ptr+1)%2
		sfx(3)
	end
	
	for s in all(snowflakes) do
		s:update()
		if s.y > screen then
			del(snowflakes,s)
			local new_x=flr(rnd(screen))
			add(snowflakes,new_snowflake(new_x,0))
		end
	end
end

function draw_title()
	cls(6)

	for s in all(snowflakes) do
		s:draw()
	end

	spr(32,20,20,11,3)
	printb("by aquova",70,42,7,0)
	printb("start game",25,screen/2,7,0)
	printb("level select",25,screen/2+10,7,0)
	printb("🅾️",14,screen/2+10*title_ptr,12,0)
	circfill(screen/2,3*screen,2.25*screen,7)
	spr(17,90,90,2,1)
	spr(16,105,92)
end

function update_lvlselect()
	local max_lvl=max_level()

	if btnp(🅾️) then
	 if lvl_ptr < max_lvl then
	 	level=lvl_ptr+1
	 	init_level(level)
			_upd=update_main
			_drw=draw_main
			sfx(0)
		end
	elseif btnp(❎) then
		_upd=update_title
		_drw=draw_title
		sfx(2)
	elseif btnp(⬅️) then
		lvl_ptr=(lvl_ptr-1)%(max_unlocked-1)
		sfx(3)
	elseif btnp(➡️) then
		lvl_ptr=(lvl_ptr+1)%(max_unlocked-1)
		sfx(3)
	elseif btnp(⬇️) then
		lvl_ptr=(lvl_ptr+row_num)%max_unlocked
		sfx(3)
	elseif btnp(⬆️) then
		lvl_ptr=(lvl_ptr-row_num)%max_unlocked
		sfx(3)
	end
	
	for s in all(snowflakes) do
		s:update()
		if s.y > screen then
			del(snowflakes,s)
			local new_x=flr(rnd(screen))
			add(snowflakes,new_snowflake(new_x,0))
		end
	end
end

function draw_lvlselect()
	cls(6)
	
	for s in all(snowflakes) do
		s:draw()
	end
	
	printbc("level select",10,7,0)
	for lvl=0,max_level()-1 do
		local x=lvl_margin.x+box_size*(lvl%row_num)
		local y=lvl_margin.y+box_size*flr(lvl/row_num)
		rectfill(x,y,x+box_size-1,y+box_size-1,6)

		if lvl+1 > max_unlocked then
			fillp(0xa5a5.8)
			rectfill(x,y,x+box_size-1,y+box_size-1,5)
   fillp()			
		else
			local high=high_scores[lvl+1]
			local lvl_max=get_max_score(lvl+1)
			local pen_color=(high==lvl_max) and 9 or 8
			printb(high,x+ctext(""..high,x,x+box_size),y+3,pen_color,0)
			line(x+3,y+10,x+box_size-4,y+10,0)
			printb(lvl_max,x+ctext(""..lvl_max,x,x+box_size),y+14,pen_color,0)
		end

		rect(x,y,x+box_size-1,y+box_size-1,0)
		--printb(lvl+1,x+ctext(""..lvl+1,x,x+box_size),y+3,8,0)
	end

	local ptr_x=lvl_margin.x+box_size*(lvl_ptr%row_num)
	local ptr_y=lvl_margin.y+box_size*flr(lvl_ptr/row_num)
	rect(ptr_x,ptr_y,ptr_x+box_size-1,ptr_y+box_size-1,11)

	local back_txt="🅾️ select ❎ back"
	printb(back_txt,ctext(back_txt,0,screen)-2,screen-10,7,0)
	printb("❎",72,screen-10,8,0)
	printb("🅾️",32,screen-10,12,0)
end

function create_snow()
	snowflakes={}
	for _=1,50 do
	 local x=flr(rnd(screen))
	 local y=flr(rnd(screen))
		add(snowflakes,new_snowflake(x,y))
	end
end
-->8
-- main game

function update_main()
	if transition then
		trans_y=min(0,trans_y+5)
		if trans_y==0 then	
			if btnp(🅾️) then
				if level==max_level() then
 				_upd=update_title
 				_drw=draw_title
 				return
 			end
 			transition=false
 			level+=1
 			init_level(level)
 		elseif btnp(❎) then
 		 transition=false
 		 init_level(level)
 		end
 	end
		return
	end
	
	-- reset level if ❎ held
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
		max_unlocked=max(max_unlocked,level+1)
		save_game()
	end
end

function main_input()
 -- ignore input on ice
 -- may want to allow input when stationary
 if board[p1.y][p1.x]==4 then
 	if p1.d=="u" then
			p1.y=max(1,p1.y-1)
  elseif p1.d=="d" then
			p1.y=min(p1.y+1,#board)
  elseif p1.d=="l" then
			p1.x=max(1,p1.x-1)
  elseif p1.d=="r" then
			p1.x=min(p1.x+1,#board[1])
  end
 	return
 end
	-- store initial position
	local startx,starty=p1.x,p1.y
	if btnp(⬅️) then
		p1.x=max(1,p1.x-1)
		p1.d="l"
	elseif btnp(➡️) then
		p1.x=min(p1.x+1,#board[1])
		p1.d="r"
	end

	if btnp(⬆️) then
		p1.y=max(1,p1.y-1)
		p1.d="u"
	elseif btnp(⬇️) then
		p1.y=min(p1.y+1,#board)
		p1.d="d"
	end

	-- if move would move off snow, don't move
	local valid_tiles={1,4}
	if not contains(valid_tiles,board[p1.y][p1.x]) then
		p1.x,p1.y=startx,starty
		return
	end

	level_snow+=1
	sfx(1)
end

function update_board()
	if board[p1.y][p1.x]==1 then
		board[p1.y][p1.x]=2
	end
end

function remaining_moves()
	-- check if there are any moves left
	-- need to follow ice paths to see if snow exists on the other side
 if p1.x > 1 then
  for i=p1.x-1,1,-1 do
   if board[p1.y][i]==1 then
    return true
   elseif board[p1.y][i]~=4 then
    break
   end
  end
 end

 if p1.x < #board[1] then
  for i=p1.x+1,#board[1] do
   if board[p1.y][i]==1 then
    return true
   elseif board[p1.y][i]~=4 then
    break
   end
  end
 end

 if p1.y > 1 then
  for i=p1.y-1,1,-1 do
   if board[i][p1.x]==1 then
    return true
   elseif board[i][p1.x]~=4 then
    break
   end
  end
 end

 if p1.y < #board then
  for i=p1.y+1,#board do
   if board[i][p1.x]==1 then
    return true
   elseif board[i][p1.x]~=4 then
    break
   end
  end
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
	},
	{
		{1,1,3,3,3,3,3},
		{1,2,1,4,4,4,1},
		{1,1,1,3,3,3,3}
	},
	{
		{1,4,4,1,4,4,1},
		{4,4,4,4,4,4,4},
		{1,4,4,2,4,4,1},
		{1,4,4,1,4,4,1},
		{1,4,4,4,4,4,1},
		{4,4,4,4,4,4,4},
		{1,1,1,1,1,1,1}
	},
	{
		{1,1,1,1,1},
		{1,4,1,4,1},
		{1,4,1,4,1},
		{1,4,2,4,1},
		{1,1,4,1,1},
		{1,4,1,4,1},
		{1,4,1,4,1},
		{1,4,1,4,1},
		{1,1,1,1,1}
	},
	{
		{1,1,1,1,1,2},
		{1,3,3,1,1,1},
		{1,3,1,1,1,1},
  {1,1,1,1,1,1},
  {1,1,1,1,3,1},
  {1,1,1,3,3,1},
		{1,1,1,1,1,1}  		
	}
}

_meta_levels={
	-- top score, start x, start y
	{24,3,3},
	{43,4,3},
	{31,1,1},
	{32,4,4},
	{8,2,2},
	{17,4,3},
	{31,3,4},
	{35,6,1}
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
	transition=false
	trans_y=-100
	board=copy_lvl(get_level(val))
	p1.x=_meta_levels[val][2]
	p1.y=_meta_levels[val][3]
	p1.d="n" -- neutral direction
	calc_margin(val)
end

function calc_margin(val)
	local current_board=get_level(val)
	margin.x=8*ceil((screen/8-#current_board[1])/2-1)
	margin.y=8*ceil((screen/8-#current_board)/2-1)
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

	draw_border()
	draw_board()
	draw_bar()
	printb("웃",margin.x+8*p1.x+1,margin.y+8*p1.y+1,12,0)
	--draw_player()

	if transition then
		draw_transition(0,trans_y)
	end

	-- resetting level
	if reset_frames > 5 then
		printbc("hold ❎ to reset",screen/2-10,7,0)
  printb("❎",54,screen/2-10,8,0)
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
	for x=0,screen/8-1 do
	 for y=0,screen/8-1 do
	 	spr(16,8*x,8*y)
	 end
	end
end

function draw_bar()
	rectfill(0,0,screen,8,5)
	print("level: "..level,2,2,6)
	printr("size: "..level_snow,2,6)
end

function draw_transition(_x,_y)
		local lvl_max=get_max_score(level)
		rectfill(_x+15,_y+15,_x+screen-15,_y+screen-15,1)
		rectfill(_x+20,_y+20,_x+screen-20,_y+screen-20,6)
		printbc("level: "..level,_y+24,8,0)
		line(_x+25,_y+32,_x+screen-25,_y+32,0)
		printbc("snowman size: "..level_snow,_y+40,7,0)
		printbc("possible max: "..lvl_max,_y+50,7,0)
		if level_snow==lvl_max then
		 sspr(24,16,13,19,_x+screen/2-6,_y+60)
			printbc("perfect score!",_y+82,9,0)
		end

		printbc("🅾️ next level",_y+screen-36,7)
		printb("🅾️",_x+40,_y+screen-36,12,0)
		printbc("❎ restart",_y+screen-28,7)
		printb("❎",_x+46,_y+screen-28,8,0)
end

function new_snowflake(_x,_y)
	local s={x=_x,y=_y,ang=rnd(1),spd=rnd(0.5)+0.5}
	
	s.update=function(this)
		s.y+=s.spd
		s.ang+=0.05
	end
	
	s.draw=function(this)
		circfill(s.x+sin(s.ang),s.y,1,7)
	end
	
	return s
end

function draw_player()
 if p1.d~="n" then
 	circfill(margin.x+8*p1.x+4,margin.y+8*p1.y+4,3,0)
 	circfill(margin.x+8*p1.x+4,margin.y+8*p1.y+4,2,7)
	end

	if p1.d=="u" then
		
	elseif p1.d=="d" then
	
	elseif p1.d=="l" then
	 spr(17,margin.x+8*(p1.x+1)+1,margin.y+8*p1.y+1)
	elseif p1.d=="r" then
	 spr(17,margin.x+8*(p1.x-1)+1,margin.y+8*p1.y+1,1,1,true)
	else
	
	end
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

-- print both with a border and centered
function printbc(_t,_y,_cinner,_couter)
	local x=ctext(_t,0,screen)
	printb(_t,x,_y,_cinner,_couter)
end

-- checks if a table contains an element
function contains(_tbl,_e)
	for item in all(_tbl) do
		if item==_e then
			return true
		end
	end
	return false
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
0000000077777777bbb7bb3b77777777cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777777bbbb3bb77000777c7cccc7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700777777777b3bb3bb70777077ccccc7cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700077777777b3bbbbbb04444707cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700077777777b3bbb3bb04444440cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070077777777bb7b37bb04444440cc7ccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777777bbb37bb70000007c7cccc7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000077777777bbbbbbbb77777777cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eee33eeeeee77777777eeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee3333eeee5555555557eeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e333333ee111111111117eee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333355555555555557ee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee3333eeeedddddddeefeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e333333eee8558448eefeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333eed55d44deefeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eee44eeeee8888448eefeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee00000eeeeeeeeeeeeeeeeeeee000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
ee007777700eeeeeeeeeeeeeeeee07770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
e07777777770eeeeeeeeeeeeeee0777770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
e077777777760eeeeeeeeeeeee070770760eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
0777700077760eeeeeeeeeeeee077777760eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
07770eee00660eeeeeeeeeeeee079977760eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
07770eeeee00eeeeeeeeeeeeeee0777760eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
0777700eeeeeeeeeeeeeeeeeeee0066600eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
e07777700eeeeeeeeeeeeeeeee007000700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
ee007777700eeeeeeeeeeeeee07777777770eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
eeee00777770ee000e000eeee07770777770eee00eee0eee00ee000e00e0000eeeee000000eee000e000eeee0000000000000000000000000000000000000000
eeeeee0077760e07707770ee0777777777760e0770e070e0770e077077077770eee07777770ee07707770eee0000000000000000000000000000000000000000
e00eeeee07760e077777770e0777707777760e0770e070e0760e0777777777770e0776007770e077777770ee0000000000000000000000000000000000000000
07700eee07760e077607760e0777777777760e0770e070e0760e0776077607760e0770ee0760e077607760ee0000000000000000000000000000000000000000
0777700077760e0760e0760e0777707777760e0770e070e0760e0760e070e0760e0770ee0760e0760e0760ee0000000000000000000000000000000000000000
077777777760ee0760e0760ee07777777760ee0777077707760e0760e060e0760e0777007760e0760e0760ee0000000000000000000000000000000000000000
e07777777660ee0760e0760ee07777777660ee0777776777660e0760e060e0760ee077777760e0760e0760ee0000000000000000000000000000000000000000
ee006666600eee0660e0660eee006666600eeee06666066660ee0660e060e0660eee06660660e0660e0660ee0000000000000000000000000000000000000000
eeee00000eeeeee00eee00eeeeee00000eeeeeee0000e0000eeee00eee0eee00eeeee000e000ee00eee00eee0000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
__sfx__
000400003005030050300502d0502d0502d050300503005030050350503505035050000000000000000000001d0001e0002000023000260002b0002f000000000000000000000000000000000000000000000000
010400000365403655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002505025050220502205022000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001f15024150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
