pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- 2048
-- @aquova

screen=128
num_tiles=4
tile_size=screen/num_tiles
board={}
score=0

colors={[0]=0,8,9,10,11,12,13,14,3,4,5,6,7}

function _init()
	reset()
end

function _update()
	local shifted=false
	if btnp(➡️) then
		shifted=shift_right()
	elseif btnp(⬅️) then
		shifted=shift_left()
	elseif btnp(⬇️) then
		shifted=shift_down()
	elseif btnp(⬆️) then
		shifted=shift_up()
	end
	
	if shifted then
		insert_tile()
	end
end

function _draw()
	draw_board()
end

function reset()
	board=create_board()
	score=0
	insert_tile()
	draw_board()
end

function print_board()
	for x=1,num_tiles do
		local s=""
		for y=1,num_tiles do
			s=s..board[x][y]
		end
		printh(s)
	end
	printh("---")
end
-->8
-- board

function create_board()
	local b={}
	
	for x=1,num_tiles do
		b[x]={}
		for y=1,num_tiles do
			b[x][y]=0
		end
	end
	
	return b
end

function insert_tile()
	local new_tile=(rnd(1)>0.9) and 2 or 1

	local empty_tiles={}
	for x=1,num_tiles do
		for y=1,num_tiles do
			if board[x][y]==0 then
				add(empty_tiles,{x,y})
			end
		end
	end
	
	if #empty_tiles==0 then
		gameover()
	end
	
	local rand_xy=empty_tiles[ceil(rnd(#empty_tiles))]
	board[rand_xy[1]][rand_xy[2]]=new_tile
end

function draw_board()
	cls()
	for x=1,num_tiles do
		for y=1,num_tiles do
			local c=colors[board[x][y]]
			rectfill(tile_size*(x-1),tile_size*(y-1),tile_size*x,tile_size*y,c)
		end
	end
	print("score "..score,5,5,12)
end
-->8
-- shift

function shift_right()
	local shifted=false
	for y=1,num_tiles do
		-- two phases - first merge like pairs
		for x=num_tiles,2,-1 do
			if board[x][y]~=0 then
				for x2=x-1,1,-1 do
					if board[x][y]==board[x2][y] then
						board[x][y]+=1
						score+=2^board[x][y]
						board[x2][y]=0
						shifted=true
						break
					elseif board[x2][y]~=0 and board[x][y]~=board[x2][y] then
						break
					end
				end
			end
		end

		-- then shift all numbers over
		for x=num_tiles,2,-1 do
			if board[x][y]==0 then
				for x2=x-1,1,-1 do
					if board[x2][y]~=0 then
						board[x][y]=board[x2][y]
						board[x2][y]=0
						shifted=true
						break
					end
				end
			end
		end
	end
	return shifted
end

function shift_left()
	local shifted=false
	for y=1,num_tiles do
		for x=1,num_tiles do
			if board[x][y]~=0 then
				for x2=x+1,num_tiles do
					if board[x][y]==board[x2][y] then
						board[x][y]+=1
						score+=2^board[x][y]
						board[x2][y]=0
						shifted=true
						break
					elseif board[x2][y]~=0 and board[x][y]~=board[x2][y] then
						break
					end
				end
			end
		end

		for x=1,num_tiles do
			if board[x][y]==0 then
				for x2=x+1,num_tiles do
					if board[x2][y]~=0 then
						board[x][y]=board[x2][y]
						board[x2][y]=0
						shifted=true
						break
					end
				end
			end
		end
	end
	return shifted
end

function shift_down()
	local shifted=false
	for x=1,num_tiles do
		for y=1,num_tiles do
			if board[x][y]~=0 then
				for y2=y-1,1,-1 do
					if board[x][y]==board[x][y2] then
						board[x][y]+=1
						score+=2^board[x][y]
						board[x][y2]=0
						shifted=true
						break
					elseif board[x][y2]~=0 and board[x][y]~=board[x][y2] then
						break
					end
				end
			end
		end

		for y=1,num_tiles do
			if board[x][y]==0 then
				for y2=y-1,1,-1 do
					if board[x][y2]~=0 then
						board[x][y]=board[x][y2]
						board[x][y2]=0
						shifted=true
						break
					end
				end
			end
		end
	end
	return shifted
end

function shift_up()
	local shifted=false
	for x=1,num_tiles do
		for y=1,num_tiles do
			if board[x][y]~=0 then
				for y2=y+1,num_tiles do
					if board[x][y]==board[x][y2] then
						board[x][y]+=1
						score+=2^board[x][y]
						board[x][y2]=0
						shifted=true
						break
					elseif board[x][y2]~=0 and board[x][y]~=board[x][y2] then
						break
					end
				end
			end
		end

		for y=1,num_tiles do
			if board[x][y]==0 then
				for y2=y+1,num_titles do
					if board[x][y2]~=0 then
						board[x][y]=board[x][y2]
						board[x][y2]=0
						shifted=true
						break
					end
				end
			end
		end
	end
	return shifted
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
