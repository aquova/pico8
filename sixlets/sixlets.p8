pico-8 cartridge // http://www.pico-8.com
version 23
__lua__
-- sixlets
-- @aquova

-- constants
screen=128
fps=30
board_margin=16
board_tab=10
board_size=(screen-2*board_margin)/8
pts_digits=10
timed_len=180 -- in sec
max_score=0xffff
a_ord=97

modes={
	score=1,
	timed=2
}

diffs={
	easy=1,
	med=2,
	hard=3
}

function _init()
	cartdata("aquova_sixlets_1")
	reset()
end

function _update()
	_upd()
end

function _draw()
	draw_bg()
	draw_modes()
	_drw()
end

function reset()
	_upd=update_title
	_drw=draw_title
	t_cursor=0
	t_state=title_states.mode

	game_mode=nil
	game_diff=nil

	g_cursor={x=0,y=0}
	high_scores=load_hs()
end

function init_game()
	if game_diff==diffs.easy then
		match_min=3
		num_colors=5
	elseif game_diff==diffs.med then
		match_min=4
		num_colors=5
	elseif game_diff==diffs.hard then
		match_min=4
		num_colors=6
	else
		assert(false,"invalid difficulty")
	end

	-- it's unlikely we'll have an
	-- invalid generation, but we
	-- should check
	repeat
		grid=populate_grid()
	until not is_gameover()

	pts=0
	time_goal=timed_len
	floating={}
	start_time=0
	shake=0
end

function update_game()
	if game_mode==modes.timed then
		time_goal=max(time_goal-1/fps,0)
		pts+=(1/fps)
		if is_timeover() then
			gameover()
		end
	end

	game_input()
	update_floating()

	if btnp(❎) then
		local grid_changed=on_click()
		if grid_changed then
			fall_tiles()
			if is_gameover() then
				gameover()
			end
		end
	end
end

function draw_game()
	draw_board()
	draw_tiles()

	if game_mode==modes.score then
		print_points()
	elseif game_mode==modes.timed then
		print_time()
	else
		assert(false,"invalid game mode")
	end

	for f in all(floating) do
		f:draw()
	end
	highlight_tile()
	screen_shake()
end

function game_input()
	if btnp(⬅️) then
		g_cursor.x=(g_cursor.x-1)%board_size
		sfx(0)
	elseif btnp(➡️) then
		g_cursor.x=(g_cursor.x+1)%board_size
		sfx(0)
	end

	if btnp(⬆️) then
		g_cursor.y=(g_cursor.y-1)%board_size
		sfx(0)
	elseif btnp(⬇️) then
		g_cursor.y=(g_cursor.y+1)%board_size
		sfx(0)
	end
end
-->8
-- drawing

function draw_bg()
	cls(5)
	local x_offset=(15*t())%16
	--local x_offset=5*cos(0.5*t())
	local y_offset=3*sin(0.5*t())
	for x=x_offset-16,screen,16 do
		for y=y_offset-8,screen,16 do
			rectfill(x,y,x+7,y+7,1)
		end
	end

	for x=x_offset-8,screen,16 do
		for y=y_offset,screen,16 do
			rectfill(x,y,x+7,y+7,1)
		end
	end
end

function draw_modes()
	local y=screen-10
	if game_mode~=nil then
		printb(mode_txt[game_mode],board_margin,y,6,0)
	end

	if game_diff~=nil then
		local dt=diff_txt[game_diff]
		local x=rtext(dt,board_margin)
		printb(dt,x,y,6,0)
	end
end

function draw_board()
	local x1,y1=board_margin,board_margin
	local x2=screen-board_margin-1
	local y2=screen-board_margin-1
	rectfill(screen/2-1,y1-board_tab-1,x2+1,y2+1,6)
	rectfill(x1-1,y1-1,screen/2+1,y2+1,6)
	rectfill(screen/2,y1-board_tab,x2,y2,0)
	rectfill(x1,y1,screen/2,y2,0)
end

function draw_tiles()
	for x=1,board_size do
		for y=1,board_size do
			local sprt=grid[x][y]
			spr(
				sprt,
				board_margin+8*(x-1),
				board_margin+8*(y-1)
			)
		end
	end
end

function highlight_tile()
	local cx,cy=get_cursor_cel()
	rect(cx,cy,cx+7,cy+7,7)
end

function print_points()
	local pts_t=""..pts
	local pts_len=#pts_t
	for i=0,pts_digits-pts_len do
		pts_t="0"..pts_t
	end
	print(pts_t,screen/2+3,board_margin-board_tab+3,7)
end

function print_time()
	local time_t=format_t(time_goal)
	local x=rtext(time_t,board_margin+2)
	print(time_t,x,board_margin-board_tab+3,7)
end
-->8
-- gameplay

function rnd_tile()
	return ceil(rnd(num_colors))
end

function populate_grid()
	local g={}

	for x=0,board_size-1 do
		local row={}
		for y=0,board_size-1 do
			local c=rnd_tile()
			add(row,c)
		end
		add(g,row)
	end

	return g
end

function on_click()
	local cx,cy=get_cursor_cel()
	local gx=(cx-board_margin)/8+1
	local gy=(cy-board_margin)/8+1
	local curr=grid[gx][gy]
	if curr==0 then return false end
	local grid_copy=deep_2d_copy(grid)
	local cnt=flood_fill(grid_copy,gx,gy,curr)

	if cnt>=match_min then
		grid=grid_copy
		calc_bonus(cnt)
		sfx(2)
		return true
	end
end

function fall_tiles()
	for x=1,board_size do
		local empty={}
		for y=board_size,1,-1 do
			if grid[x][y]==0 then
				-- remove tile
				add(empty,y)
				explosion(board_margin+8*(x-1)+4,board_margin+8*(y-1)+4)
			elseif #empty~=0 then
				-- move tile down
				local y2=empty[1]
				grid[x][y],grid[x][y2]=grid[x][y2],grid[x][y]
				del(empty,y2)
				add(empty,y)
			end
		end
		for i in all(empty) do
			-- repopulate empty slots at top
			grid[x][i]=rnd_tile()
		end
	end
end

function calc_bonus(_cnt)
	local adj=_cnt-match_min+1
	local reward=adj*adj+1
	if game_mode==modes.score then
		pts+=reward
	elseif game_mode==modes.timed then
		time_goal+=reward
	else
		assert(false,"invalid game mode")
	end
	add(floating,make_label(reward,get_cursor_cel()))
	shake+=1
end

function is_gameover()
	local max_cnt=0
	local grid_copy=deep_2d_copy(grid)
	for x=1,board_size do
		for y=1,board_size do
			local c=grid_copy[x][y]
			if c~=0 then
				local cnt=flood_fill(grid_copy,x,y,c)
				max_cnt=max(max_cnt,cnt)
			end
		end
	end

	return max_cnt<match_min
end

function is_timeover()
	if game_mode==modes.timed and time_goal<=0 then
		return true
	end
	return false
end

function gameover()
	_upd=update_results
	_drw=draw_results
	start_time=t()
	if is_hs() then
		sfx(3)
	else
		sfx(4)
	end
end

function update_floating()
	for f in all(floating) do
		f:update()
		if f:should_die() then
			del(floating,f)
		end
	end
end

function update_results()
	update_floating()
	if t()-start_time>5 then
		if btnp(❎) then
			if is_hs() then
				_upd=update_name_entry()
				_drw=draw_name_entry()
			else
				reset()
			end
		end
	end
end

function draw_results()
	draw_game()
	local x=ctext("game over")
	printb("game over",x,screen/2,8,0)
end

-->8
-- utils

function get_cursor_cel()
	local cx=board_margin+g_cursor.x*8
	local cy=board_margin+g_cursor.y*8
	return cx,cy
end

function flood_fill(_g,_x,_y,_t)
	if _x<1 or _x>board_size then
		return 0
	elseif _y<1 or _y>board_size then
		return 0
	end

	local curr=_g[_x][_y]
	if curr~=_t then
		return 0
	end

	_g[_x][_y]=0
	local cnt=1
	cnt+=flood_fill(_g,_x-1,_y,_t)
	cnt+=flood_fill(_g,_x+1,_y,_t)
	cnt+=flood_fill(_g,_x,_y-1,_t)
	cnt+=flood_fill(_g,_x,_y+1,_t)
	return cnt
end

-- from here:https://www.lexaloffle.com/bbs/?tid=28306
function screen_shake()
	-- generate random vals between -4 and 4
	local sx=1-rnd(2)
	local sy=1-rnd(2)

	sx*=shake
	sy*=shake

	camera(sx,sy)

	shake*=0.75
	-- if shake falls below threshold, stop
	if shake<0.1 then
		shake=0
	end
end

function deep_2d_copy(_g)
	local copy={}

	for col in all(_g) do
		local row={}
		for val in all(col) do
			add(row,val)
		end
		add(copy,row)
	end

	return copy
end

function printb(_t,_x,_y,_ci,_co)
	for x=_x-1,_x+1 do
		for y=_y-1,_y+1 do
			print(_t,x,y,_co)
		end
	end

	print(_t,_x,_y,_ci)
end

function ctext(_t)
	return screen/2-2*#_t
end

function rtext(_t,_x)
	return screen-_x-4*#_t+1
end

function format_t(_t)
	local minutes=""..flr(_t/60)
	if #minutes==1 then
		minutes="0"..minutes
	end

	local seconds=""..flr(_t%60)
	if #seconds==1 then
		seconds="0"..seconds
	end

	return minutes..":"..seconds
end
-->8
-- effects

-- todo: learn how lua inheritance works
function make_label(_p,_x,_y)
	local l={
		text="".._p,
		age=0,
		max_age=20
	}

	l.x=_x-#l.text/2
	l.y=_y-5
	if game_mode==modes.timed then
		l.text="+"..l.text
	end

	function l:update()
		self.y-=1
		self.age+=1
	end

	function l:should_die()
		return self.age>self.max_age
	end

	function l:draw()
		printb(self.text,self.x,self.y,7,0)
	end

	return l
end

function make_particle(_x,_y)
	local p={
		x=_x,
		y=_y,
		col=rnd({8,9,3,12,13,6}),
		age=0,
		a=rnd(),
		spd=1+rnd(2),
		max_age=15+rnd(5)
	}

	p.dx=sin(p.a)*p.spd
	p.dy=cos(p.a)*p.spd

	function p:update()
		self.x+=self.dx
		self.y+=self.dy
		self.age+=1
		--gravity
		self.dy+=0.15
	end

	function p:should_die()
		return self.age>self.max_age
	end

	function p:draw()
		line(self.x,self.y,self.x+self.dx,self.y+self.dy,self.col)
	end

	return p
end

function explosion(_x,_y)
	for _=1,20 do
		local p=make_particle(_x,_y)
		add(floating,p)
	end
end
-->8
-- title screen

diff_txt={
	"easy",
	"medium",
	"hard"
}

mode_txt={
	"score",
	"timed"
}

menu_txt={
	"begin",
	"records"
}

title_states={
	mode=1,
	diff=2,
	menu=3
}

txt_tbl={
	mode_txt,
	diff_txt,
	menu_txt
}

function update_title()
	if btnp(⬆️) then
		t_cursor=(t_cursor-1)%#txt_tbl[t_state]
		sfx(0)
	elseif btnp(⬇️) then
		t_cursor=(t_cursor+1)%#txt_tbl[t_state]
		sfx(0)
	end

	if btnp(❎) then
		if t_state==title_states.mode then
			t_state=title_states.diff
			game_mode=t_cursor+1
		elseif t_state==title_states.diff then
			t_state=title_states.menu
			game_diff=t_cursor+1
		elseif t_state==title_states.menu then
			if t_cursor==0 then
				init_game()
				_upd=update_game
				_drw=draw_game
			else
				_upd=update_hs
				_drw=draw_hs
			end
		else
			assert(false,"invalid state")
		end
		t_cursor=0
		sfx(1)
	end

	if btnp(🅾️) then
		if t_state==title_states.diff then
			t_state=title_states.mode
			game_mode=nil
			t_cursor=0
			sfx(1)
		elseif t_state==title_states.menu then
			t_state=title_states.diff
			game_diff=nil
			t_cursor=0
			sfx(1)
		elseif t_state==title_states.mode then
			-- do nothing
		else
			assert(false,"invalid state")
		end
	end
end

function draw_title()
	local x=10
	local y=12
	rectfill(x,y-3,screen-x,y+50,6)
	rectfill(x+1,y-4,screen-x-1,y+51,6)

	rectfill(x+1,y-2,screen-x-1,y+49,0)
	rectfill(x+2,y-3,screen-x-2,y+50,0)
	sspr(0,16,56,24,36,y)
	sspr(0,40,96,24,19,y+25)
	local t="by aquova"
	local tx=rtext(t,x)
	printb(t,tx,y+54,6,0)

	local start_x=x
	local start_y=screen/2+20
	for s=1,t_state do
		local x=screen/3*(s-1)+start_x
		for i=0,#txt_tbl[s]-1 do
			local y=10*i+start_y
			printb(txt_tbl[s][i+1],x,y,6,0)
			if t_cursor==i and s==t_state then
				printb(">",x-6,y,6,0)
			end
		end
	end
end
-->8
-- results

default_hs={
	-- points scores
	-- easy
	{1000,ord("a"),ord("s"),ord("b")},
	{500,ord("a"),ord("s"),ord("b")},
	{250,ord("a"),ord("s"),ord("b")},
	{100,ord("a"),ord("s"),ord("b")},
	{50,ord("a"),ord("s"),ord("b")},
-- medium
	{1000,ord("a"),ord("s"),ord("b")},
	{500,ord("a"),ord("s"),ord("b")},
	{250,ord("a"),ord("s"),ord("b")},
	{100,ord("a"),ord("s"),ord("b")},
	{50,ord("a"),ord("s"),ord("b")},
-- hard
	{1000,ord("a"),ord("s"),ord("b")},
	{500,ord("a"),ord("s"),ord("b")},
	{250,ord("a"),ord("s"),ord("b")},
	{100,ord("a"),ord("s"),ord("b")},
	{50,ord("a"),ord("s"),ord("b")},
	-- timed scores
	-- easy
	{300,ord("a"),ord("s"),ord("b")},
	{150,ord("a"),ord("s"),ord("b")},
	{100,ord("a"),ord("s"),ord("b")},
	{60,ord("a"),ord("s"),ord("b")},
	{30,ord("a"),ord("s"),ord("b")},
-- medium
	{300,ord("a"),ord("s"),ord("b")},
	{150,ord("a"),ord("s"),ord("b")},
	{100,ord("a"),ord("s"),ord("b")},
	{60,ord("a"),ord("s"),ord("b")},
	{30,ord("a"),ord("s"),ord("b")},
-- hard
	{300,ord("a"),ord("s"),ord("b")},
	{150,ord("a"),ord("s"),ord("b")},
	{100,ord("a"),ord("s"),ord("b")},
	{60,ord("a"),ord("s"),ord("b")},
	{30,ord("a"),ord("s"),ord("b")},
}

function update_hs()
	if btnp(🅾️) then
		_upd=update_title
		_drw=draw_title
		sfx(0)
	end
end

function draw_hs()
	local idx=game_mode==modes.timed and #default_hs/2 or 0
	if game_diff==diffs.med then
		idx+=#default_hs/6
	elseif game_diff==diffs.hard then
		idx+=#default_hs/3
	end

	printb("high scores",ctext("high scores"),10,6,0)
	local start_x=20
	local start_y=27
	for i=1,5 do
		local score=high_scores[idx+i]
		local pts=score[1]
		if game_mode==modes.timed then
			pts=format_t(pts)
		end

		local y=start_y+10*(i-1)
		printb(pts,start_x,y,6,0)
		for j=2,4 do
			local let=chr(score[j])
			printb(let,start_x+screen/2+5*j,y,6,0)
		end
	end
end

function update_name_entry()
	if btnp(❎) then
		reset()
	end
end

function draw_name_entry()
	cls()
	print("this is the name entry screen. wow.",5,5,8)
end

function reset_hs()
	save_hs(default_hs)
	dset(0,1)
end

function save_hs(_tbl)
	for i=1,#_tbl do
		save_score(_tbl[i],i)
	end
end

function save_score(_tbl,_idx)
	local e_size=#default_hs[1]
	local f_idx=e_size*(_idx-1)
	for i=1,e_size do
		dset(f_idx+i,_tbl[i])
	end
end

function load_hs()
	local esize=4
	if dget(0)==0 then
		reset_hs()
		return default_hs
	else
		scores={}
		for i=0,#default_hs-1 do
			local idx=esize*i+1
			local score={}
			add(score,dget(idx))
			for j=1,esize-1 do
				add(score,dget(idx+j))
			end
			add(scores,score)
		end
		return scores
	end
end

function is_hs()
	local idx=game_mode==modes.timed and #default_hs or #default_hs/2
	return pts>high_scores[idx+1][1]
end

function add_score(_tbl,_score)
	local idx=game_mode==modes.timed and #default_hs/2 or 0
	if game_diff==diffs.med then
		idx+=#default_hs/6
	elseif game_diff==diffs.hard then
		idx+=#default_hs/3
	end

	local val=_score[1]
	local hs_found=false
	local tmp=nil
	for i=1,#default_hs/6 do
		local cur_hs=_tbl[idx+i]
		if not hs_found then
			if val>cur_hs[1] then
				tmp=cur_hs
				_tbl[idx+i]=_score
				hs_found=true
			end
		else
			_tbl[idx+i]=tmp
			tmp=cur_hs
		end
	end

	if hs_found then
		save_hs(_tbl)
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000088ee000033bb000099aa0000cc770000ddee0000667700000000000000000000000000000000000000000000000000000000000000000000000000
00000000088888e0033333b0099999a00ccccc700ddddde006666670000000000000000000000000000000000000000000000000000000000000000000000000
000000000888888003333330099999900cccccc00dddddd006666660000000000000000000000000000000000000000000000000000000000000000000000000
0000000002888880013333300499999001ccccc002ddddd005666660000000000000000000000000000000000000000000000000000000000000000000000000
00000000022888800113333004499990011cccc0022dddd005566660000000000000000000000000000000000000000000000000000000000000000000000000
00000000002222000011110000444400001111000022220000555500000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000880cc099088099000000000088000000000066000000000099000000000000000000000000000000000000000000000000000000000000000000000000000
000880cc099088099000000000088000000000066000000000099000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
990dd0330dd0cc0880dd0000330660dd0000990880cc0000660cc0cc000000000000000000000000000000000000000000000000000000000000000000000000
990dd0330dd0cc0880dd0000330660dd0000990880cc0000660cc0cc000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
660880660000000990cc0000880330cc0000000990dd0cc099088000000000000000000000000000000000000000000000000000000000000000000000000000
660880660000000990cc0000880330cc0000000990dd0cc099088000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000660990330000000000000cc0990880000000000330880dd000000000000000000000000000000000000000000000000000000000000000000000000000000
000660990330000000000000cc0990880000000000330880dd000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000660cc0000000000880cc0990000000000990cc099000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000660cc0000000000880cc0990000000000990cc099000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
330cc0000000330990dd0000660cc0dd0000000cc0330000880cc000000000000000000000000000000000000000000000000000000000000000000000000000
330cc0000000330990dd0000660cc0dd0000000cc0330000880cc000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
990cc0880990cc0880dd0000dd0330dd0000660330dd000066099033000000000000000000000000000000000000000000000000000000000000000000000000
990cc0880990cc0880dd0000dd0330dd0000660330dd000066099033000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000660dd0330880990000000000660000000000dd000000000033000000000000000000000000000000000000000000000000000000000000000000000000000
000660dd0330880990000000000660000000000dd000000000033000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000880000000000000000000000330cc0660880660000000000000330000000000000000000880cc099088099000000000000000000000000000000000000000
000880000000000000000000000330cc0660880660000000000000330000000000000000000880cc099088099000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc0cc0000000000000000000cc0880880000cc0990880000000990990000000000000000990dd0330dd0cc0880dd000000000000000000000000000000000000
cc0cc0000000000000000000cc0880880000cc0990880000000990990000000000000000990dd0330dd0cc0880dd000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
880660000000000000000000660cc0000000000330dd0000330cc0880660dd0330000000660880660000000990cc000000000000000000000000000000000000
880660000000000000000000660cc0000000000330dd0000330cc0880660dd0330000000660880660000000990cc000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd0990000000000000000000660dd0dd0000990cc0cc0000000330dd099000000000000000066099033000000000000000000000000000000000000000000000
dd0990000000000000000000660dd0dd0000990cc0cc0000000330dd099000000000000000066099033000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
330990000000000000000000330cc0880660330dd0000000000dd0330000000000000000000000000660cc000000000000000000000000000000000000000000
330990000000000000000000330cc0880660330dd0000000000dd0330000000000000000000000000660cc000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd0880330000000000000000990990000000000000000000000660880000000000660000330cc0000000330990dd000000000000000000000000000000000000
dd0880330000000000000000990990000000000000000000000660880000000000660000330cc0000000330990dd000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
990660dd0000330880cc0000990330330000990cc0990000000330880660000330cc0000990cc0880990cc0880dd000000000000000000000000000000000000
990660dd0000330880cc0000990330330000990cc0990000000330880660000330cc0000990cc0880990cc0880dd000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000330880660990880000000000dd0880880330330000000000000cc0990990cc0000000000660dd033088099000000000000000000000000000000000000000
000330880660990880000000000dd0880880330330000000000000cc0990990cc0000000000660dd033088099000000000000000000000000000000000000000
__label__
11111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555
11111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555
11111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555
11111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555
11111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555
55555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111
55555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111
55555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111
55555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111
55555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111
55555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111
55555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111
55555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111
11111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555
11111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555
11111111555555566666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666111111155555555
11111111555555560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006111111155555555
111111115555555600cc77000099aa0000ddee000088ee0000ddee000033bb0000cc770000cc770000cc770000ddee000088ee000033bb006111111155555555
11111111555555560ccccc70099999a00ddddde0088888e00ddddde0033333b00ccccc700ccccc700ccccc700ddddde0088888e0033333b06111111155555555
11111111555555560cccccc0099999900dddddd0088888800dddddd0033333300cccccc00cccccc00cccccc00dddddd008888880033333306111111155555555
111111115555555601ccccc00499999002ddddd00288888002ddddd00133333001ccccc001ccccc001ccccc002ddddd002888880013333306111111155555555
5555555511111116011cccc004499990022dddd002288880022dddd001133330011cccc0011cccc0011cccc0022dddd002288880011333306555555511111111
55555555111111160011110000444400002222000022220000222200001111000011110000111100001111000022220000222200001111006555555511111111
55555555111111160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006555555511111111
55555555111111160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006555555511111111
55555555111111160088ee000033bb0000cc770000cc770000cc77000088ee0000ddee0000cc770000cc770000ddee000088ee0000ddee006555555511111111
5555555511111116088888e0033333b00ccccc700ccccc700ccccc70088888e00ddddde00ccccc700ccccc700ddddde0088888e00ddddde06555555511111111
555555551111111608888880033333300cccccc00cccccc00cccccc0088888800dddddd00cccccc00cccccc00dddddd0088888800dddddd06555555511111111
5555555511111116028888800133333001ccccc001ccccc001ccccc00288888002ddddd001ccccc001ccccc002ddddd00288888002ddddd06555555511111111
11111111555555560228888001133330011cccc0011cccc0011cccc002288880022dddd0011cccc0011cccc0022dddd002288880022dddd06111111155555555
11111111555555560022220000111100001111000011110000111100002222000022220000111100001111000022220000222200002222006111111155555555
11111111555555560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006111111155555555
11111111555555560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006111111155555555
111111115555555600ddee0000cc77000099aa000033bb000088ee000088ee0000ddee000033bb0000ddee0000ddee000033bb000033bb006111111155555555
11111111555555560ddddde00ccccc70099999a0033333b0088888e0088888e00ddddde0033333b00ddddde00ddddde0033333b0033333b06111111155555555
11111111555555560dddddd00cccccc0099999900333333008888880088888800dddddd0033333300dddddd00dddddd003333330033333306111111155555555
111111115555555602ddddd001ccccc00499999001333330028888800288888002ddddd00133333002ddddd002ddddd001333330013333306111111155555555
5555555511111116022dddd0011cccc004499990011333300228888002288880022dddd001133330022dddd0022dddd001133330011333306555555511111111
55555555111111160022220000111100004444000011110000222200002222000022220000111100002222000022220000111100001111006555555511111111
55555555111111160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006555555511111111
55555555111111160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006555555511111111
55555555111111160033bb000033bb000033bb000099aa000033bb0000cc77000088ee000088ee0000ddee0000ddee000099aa0000cc77006555555511111111
5555555511111116033333b0033333b0033333b0099999a0033333b00ccccc70088888e0088888e00ddddde00ddddde0099999a00ccccc706555555511111111
555555551111111603333330033333300333333009999990033333300cccccc008888880088888800dddddd00dddddd0099999900cccccc06555555511111111
5555555511111116013333300133333001333330049999900133333001ccccc0028888800288888002ddddd002ddddd00499999001ccccc06555555511111111
11111111555555560113333001133330011333300449999001133330011cccc00228888002288880022dddd0022dddd004499990011cccc06111111155555555
11111111555555560011110000111100001111000044440000111100001111000022220000222200002222000022220000444400001111006111111155555555
11111111555555560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006111111155555555
11111111555555560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006111111155555555
111111115555555600cc77000033bb000099aa000099aa000033bb000088ee000033bb000088ee000033bb0000ddee0000cc770000ddee006111111155555555
11111111555555560ccccc70033333b0099999a0099999a0033333b0088888e0033333b0088888e0033333b00ddddde00ccccc700ddddde06111111155555555
11111111555555560cccccc003333330099999900999999003333330088888800333333008888880033333300dddddd00cccccc00dddddd06111111155555555
111111115555555601ccccc0013333300499999004999990013333300288888001333330028888800133333002ddddd001ccccc002ddddd06111111155555555
5555555511111116011cccc00113333004499990044999900113333002288880011333300228888001133330022dddd0011cccc0022dddd06555555511111111
55555555111111160011110000111100004444000044440000111100002222000011110000222200001111000022220000111100002222006555555511111111
55555555111111160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006555555511111111
55555555111111160000000000000000000000000000000000000000000000000000000077777777000000000000000000000000000000006555555511111111
55555555111111160033bb000033bb000033bb0000cc770000ddee000033bb000033bb007033bb070033bb0000ddee000099aa000099aa006555555511111111
5555555511111116033333b0033333b0033333b00ccccc700ddddde0033333b0033333b0733333b7033333b00ddddde0099999a0099999a06555555511111111
55555555111111160333333003333330033333300cccccc00dddddd0033333300333333073333337033333300dddddd009999990099999906555555511111111
555555551111111601333330013333300133333001ccccc002ddddd00133333001333330713333370133333002ddddd004999990049999906555555511111111
1111111155555556011333300113333001133330011cccc0022dddd001133330011333307113333701133330022dddd004499990044999906111111155555555
11111111555555560011110000111100001111000011110000222200001111000011110070111107001111000022220000444400004444006111111155555555
111111115555555600000000000000000000000000000000000000000000000000000000c7777777000000000000000000000000000000006111111155555555
11111111555555560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006111111155555555
111111115555555600cc770000cc770000ddee000099aa000088ee000033bb000033bb0000cc77000099aa0000ddee0000ddee0000ddee006111111155555555
11111111555555560ccccc700ccccc700ddddde0099999a0088888e0033333b0033333b00ccccc70099999a00ddddde00ddddde00ddddde06111111155555555
11111111555555560cccccc00cccccc00dddddd0099999900888888003333330033333300cccccc0099999900dddddd00dddddd00dddddd06111111155555555
111111115555555601ccccc001ccccc002ddddd00499999002888880013333300133333001ccccc00499999002ddddd002ddddd002ddddd06111111155555555
5555555511111116011cccc0011cccc0022dddd004499990022888800113333001133330011cccc004499990022dddd0022dddd0022dddd06555555511111111
55555555111111160011110000111100002222000044440000222200001111000011110000111100004444000022220000222200002222006555555511111111
55555555111111160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006555555511111111
55555555111111160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006555555511111111
555555551111111600cc77000099aa000099aa0000ddee000033bb000088ee000088ee0000cc77000099aa000088ee0000cc77000033bb006555555511111111
55555555111111160ccccc70099999a0099999a00ddddde0033333b0088888e0088888e00ccccc70099999a0088888e00ccccc70033333b06555555511111111
55555555111111160cccccc009999990099999900dddddd00333333008888880088888800cccccc009999990088888800cccccc0033333306555555511111111
555555551111111601ccccc0049999900499999002ddddd001333330028888800288888001ccccc0049999900288888001ccccc0013333306555555511111111
1111111155555556011cccc00449999004499990022dddd0011333300228888002288880011cccc00449999002288880011cccc0011333306111111155555555
11111111555555560011110000444400004444000022220000111100002222000022220000111100004444000022220000111100001111006111111155555555
11111111555555560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006111111155555555
11111111555555560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006111111155555555
111111115555555600cc770000ddee000088ee0000ddee0000cc770000ddee000088ee0000cc77000033bb0000ddee000099aa0000ddee006111111155555555
11111111555555560ccccc700ddddde0088888e00ddddde00ccccc700ddddde0088888e00ccccc70033333b00ddddde0099999a00ddddde06111111155555555
11111111555555560cccccc00dddddd0088888800dddddd00cccccc00dddddd0088888800cccccc0033333300dddddd0099999900dddddd06111111155555555
111111115555555601ccccc002ddddd00288888002ddddd001ccccc002ddddd00288888001ccccc00133333002ddddd00499999002ddddd06111111155555555
5555555511111116011cccc0022dddd002288880022dddd0011cccc0022dddd002288880011cccc001133330022dddd004499990022dddd06555555511111111
55555555111111160011110000222200002222000022220000111100002222000022220000111100001111000022220000444400002222006555555511111111
55555555111111160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006555555511111111
55555555111111160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006555555511111111
55555555111111160099aa000033bb000088ee000099aa000033bb000099aa000033bb000099aa0000ddee0000cc77000088ee0000ddee006555555511111111
5555555511111116099999a0033333b0088888e0099999a0033333b0099999a0033333b0099999a00ddddde00ccccc70088888e00ddddde06555555511111111
555555551111111609999990033333300888888009999990033333300999999003333330099999900dddddd00cccccc0088888800dddddd06555555511111111
5555555511111116049999900133333002888880049999900133333004999990013333300499999002ddddd001ccccc00288888002ddddd06555555511111111
11111111555555560449999001133330022888800449999001133330044999900113333004499990022dddd0011cccc002288880022dddd06111111155555555
11111111555555560044440000111100002222000044440000111100004444000011110000444400002222000011110000222200002222006111111155555555
11111111555555560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006111111155555555
11111111555555560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006111111155555555
111111115555555600cc770000cc77000033bb000033bb000088ee0000ddee0000ddee0000cc77000033bb0000ddee000088ee000099aa006111111155555555
11111111555555560ccccc700ccccc70033333b0033333b0088888e00ddddde00ddddde00ccccc70033333b00ddddde0088888e0099999a06111111155555555
11111111555555560cccccc00cccccc00333333003333330088888800dddddd00dddddd00cccccc0033333300dddddd008888880099999906111111155555555
111111115555555601ccccc001ccccc001333330013333300288888002ddddd002ddddd001ccccc00133333002ddddd002888880049999906111111155555555
5555555511111116011cccc0011cccc0011333300113333002288880022dddd0022dddd0011cccc001133330022dddd002288880044999906555555511111111
55555555111111160011110000111100001111000011110000222200002222000022220000111100001111000022220000222200004444006555555511111111
55555555111111160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006555555511111111
55555555111111160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006555555511111111
55555555111111160033bb0000ddee0000ddee0000cc770000ddee0000cc77000099aa000088ee0000cc770000ddee000099aa0000cc77006555555511111111
5555555511111116033333b00ddddde00ddddde00ccccc700ddddde00ccccc70099999a0088888e00ccccc700ddddde0099999a00ccccc706555555511111111
5555555511111116033333300dddddd00dddddd00cccccc00dddddd00cccccc009999990088888800cccccc00dddddd0099999900cccccc06555555511111111
55555555111111160133333002ddddd002ddddd001ccccc002ddddd001ccccc0049999900288888001ccccc002ddddd00499999001ccccc06555555511111111
111111115555555601133330022dddd0022dddd0011cccc0022dddd0011cccc00449999002288880011cccc0022dddd004499990011cccc06111111155555555
11111111555555560011110000222200002222000011110000222200001111000044440000222200001111000022220000444400001111006111111155555555
11111111555555560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006111111155555555
11111111555555566666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666111111155555555
11111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555
11111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555
11111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555
11111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555
55555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111
55555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111
55555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111
55555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111
55555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111
55555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111
55555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111
55555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111
11111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555
11111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555
11111111555555551111111155555555111111115555555511111111555555551111111155555555111111115555555511111111555555551111111155555555

__sfx__
000400001d0501a050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002105026050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002005020050240502405028050280500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400003005030050300502d0502d0502d050300503005030050350503505035050300002d0002d0002d00030000300003000035000350003500000000000000000000000000000000000000000000000000000
01080000181541815018150181530e1500e1500e1500e1530c1500c153131501315013150131501315713157131571315113151111511115110151101510e1510e1510c1510c0510000000000000000000000000
