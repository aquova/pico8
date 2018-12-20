pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- tetris
-- @aquova

function _init()
	screen=128
	level=1
	score=0
	lines=0
	board_size={x=10,y=20}
	
	board=init_board()
	pieces=init_pieces()
	
	current_piece={pieces[flr(rnd(#pieces)+1)],rot=1,x=4,y=0}
	
	_upd=update_main
	_drw=draw_main
end

function _update()
	_upd()
end

function _draw()
	_drw()
end


-->8
-- initialization

function init_board()
	local b={}
	-- 'valid' section of board shall be 0's
	-- edges shall be -1
	for y=1,board_size.y do
		add(b,{})
		b[y][1]=-1
		for x=2,board_size.x+1 do
			b[y][x]=0
		end
		b[y][board_size.x+2]=-1
	end
	
	-- bottom of board shall also be -1's
	add(b,{})
	for x=1,board_size.x do
		b[board_size.y+1][x]=-1
	end 
	return b
end

function init_pieces()
 local shapes={
 	{ -- t piece
 		{0,1,0},
 		{1,1,1}
 	},
 	{ -- z piece
 		{1,1,0},
 		{0,1,1}
 	},
 	{ -- s piece
 		{0,1,1},
 		{1,1,0}
 	},
 	{ -- j piece
 		{1,0,0},
 		{1,1,1}
 	},
 	{ -- l piece
 		{1,1,1},
 		{1,0,0}
 	},
 	{ -- i piece
 		{1,1,1,1}
 	},
		{ -- o piece
			{1,1},
			{1,1}
		}
 }
 
 -- now generate rotations for all pieces
 for i,s in pairs(shapes) do
		shapes[i]={}
		for rot=1,4 do
			local new={}
			local x_end=#s[1]+1
			for x=1#s[1] do
				new[x]={}
				for y=1,#s do
					new[x][y]=s[y][x_end-x]
				end
			end
			s=new
			shapes[i][rot]=s
		end 
 end
 
 return shapes
end
-->8
-- main loop

function update_main()
	check_input()
end

function draw_main()
	cls()
end

function check_input()
	if btnp(⬅️) then
		current_piece.x-=1	
	elseif btnp(➡️) then
		current_piece.x+=1
	end
end
-->8
-- title screen

function update_title()

end

function draw_title()

end
