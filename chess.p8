pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- chess
-- @aquova

-- consts
screen=128
border=16
grid_size=(screen-2*border)/8

-- pieces 'enum'
pawn=1
bishop=2
knight=3
rook=4
queen=5
king=6

order={rook,knight,bishop,queen,king,bishop,knight,rook}

function _init()
	-- enable mouse
	poke(0x5f2d,1)
	board=create_board()
	pointer={x=1,y=1}
	whites_turn=true
	selected=nil
end

function _update()
	if btnp(⬅️) then
		pointer.x=max(1,pointer.x-1)
	elseif btnp(➡️) then
		pointer.x=min(8,pointer.x+1)
	end
	
	if btnp(⬆️) then
		pointer.y=max(1,pointer.y-1)
	elseif btnp(⬇️) then
		pointer.y=min(8,pointer.y+1)
	end
	
	if btnp(❎) then
		if selected==nil then
			selected=pointer
		else
			board[selected.y][selected.x]:move(pointer.x,pointer.y)
		end
	end
end

function _draw()
	cls(11)
	draw_board()
	draw_pointer()
	for row in all(board) do
		for piece in all(row) do
			if piece~=nil then
				piece:draw()
			end
		end
	end
end
-->8
-- board

function create_board()
	local b={}
	
	local h_row={}
	for x=1,8 do
		add(h_row,piece(false,order[x],x,1))
	end
	add(b,h_row)
	
	local g_row={}
	for x=1,8 do
		add(g_row,piece(false,pawn,x,2))
	end
	add(b,g_row)
	
	for y=1,4 do
		local curr_row={}
		for x=1,8 do
			add(curr_row,nil)
		end
		add(b,curr_row)
	end

	local b_row={}
	for x=1,8 do
		add(b_row,piece(true,pawn,x,7))
	end
	add(b,b_row)

	local a_row={}
	for x=1,8 do
		add(a_row,piece(true,order[x],x,8))
	end
	add(b,a_row)

	return b
end

function draw_board()
	rectfill(border-2,border-2,border+(8*grid_size)+2,border+(8*grid_size)+2,4)
	for x=0,7 do
		for y=0,7 do
			local col=(x+y)%2==0 and 7 or 0
			rectfill(border+grid_size*x,border+grid_size*y,border+grid_size*(x+1),border+grid_size*(y+1),col)
		end
	end
end

function draw_pointer()
	rect(
		border+grid_size*(pointer.x-1)-1,
		border+grid_size*(pointer.y-1)-1,
		border+grid_size*pointer.x,
		border+grid_size*pointer.y,
		8
	)
end
-->8
-- pieces

local check_fns={
	check_pawn,
	check_bishop,
	check_knight,
	check_rook,
	check_queen,
	check_king
}

function piece(is_white,rank,x,y)
	local p={
		x=x,
		y=y,
		rank=rank,
		white=is_white
	}
	
	-- setup move callback
	p.check_moves=check_fns[p.rank]
	p.moved=false
	
	function p:is_white()
		return self.white
	end
	
	function p:get_rank()
		return self.rank
	end
	
	function p:get_pos()
		return self.x,self.y
	end
	
	function p:move(x,y)
		local moves=self:check_moves(board)
		
		if includes({x,y},moves) then
			self.x=x
			self.y=y
			selected=nil
		end	
	end
	
	function p:draw()
		spr(
			self.rank,
			border+grid_size*(self.x-1),
			border+grid_size*(self.y-1)
		)
	end
	
	return p
end

function includes(xy,moves)
	for move in all(moves) do
		if xy[1]==move[1] and xy[2]==move[2] then
			return true
		end
	end
	
	return false
end

-- callback functions
-- returns a table of valid move coords
function check_pawn(board)
	local moves={}
	
	local forward=self.white and -1 or 1

	-- pawns can only move forward if noone there
	if board[self.y+forward][self.x]~=nil then
		add(moves,{self.x,self.y+forward})
		-- if its their first move, can jump two
		if board[self.y+2*forward][self.x]~=nil then
			add(moves,{self.x,self.y+2*forward})
		end
	end
	
	-- pawns attack diagonally
	for x=self.x-1,self.x+1,2 do
		if board[self.y+forward][x].is_white()~=self.white then
			add(moves,{x,self.y+forward})
		end
	end
	
	return moves
end

function check_bishop()
	local moves={}
	
	
	return moves
end

function check_knight()

end

function check_rook()

end

function check_queen()

end

function check_king()

end
__gfx__
00000000088880000888800008000080088880000088800008000800000000000000000000000000000000000000000000000000000000000000000000000000
00000000080008000800080008800080080008000800080008008000000000000000000000000000000000000000000000000000000000000000000000000000
00700700080000800800080008080080080008000800080008080000000000000000000000000000000000000000000000000000000000000000000000000000
00077000080000800808800008080080088880000800080008800000000000000000000000000000000000000000000000000000000000000000000000000000
00077000088888000800080008008080088000000808080008080000000000000000000000000000000000000000000000000000000000000000000000000000
00700700080000000800080008008080080800000800800008008000000000000000000000000000000000000000000000000000000000000000000000000000
00000000080000000800080008000880080080000800080008000800000000000000000000000000000000000000000000000000000000000000000000000000
00000000080000000888800008000080080008000088808008000800000000000000000000000000000000000000000000000000000000000000000000000000
