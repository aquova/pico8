pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- 2048-tetris
-- by aquova

function creategrid()
	-- 2048 values shall be 2^(grid value)
	local g={{0,0,0,0},
										{0,0,0,0},
										{0,0,0,0},
										{0,0,0,0},
										{0,0,0,0}}
	return g
end

function createnew()
	-- generate either 1 or 2
	-- local val=flr(rnd(1))+1
	local val=1
	local _x=flr(rnd(4))+1
	grid[1][_x]=val
	bfall={_x,1}
end

function dropblock()
	if #bfall~=0 then
		if grid[bfall[2]+1][bfall[1]]==0 then
			grid[bfall[2]][bfall[1]],grid[bfall[2]+1][bfall[1]]=grid[bfall[2]+1][bfall[1]],grid[bfall[2]][bfall[1]]
			bfall[2]+=1
		elseif grid[bfall[2]+1][bfall[1]]==grid[bfall[2]][bfall[1]] then
			grid[bfall[2]+1][bfall[1]]*=2
			grid[bfall[2]][bfall[1]]=0
			bfall[2]+=1
		else
			bfall={}
		end
	end
	
	if bfall[2]==5 then
		bfall={}
	end
end

function shiftblocks(_dir)
	-- _dir is 0 for left, 1 for right
	if _dir==0 then
		-- shift left
		for x=4,2,-1 do
			for y=2,5 do
				if x~=bfall[1] and y~=bfall[2] then
					if grid[y][x-1]==0 then
						grid[y][x],grid[y][x-1]=grid[y][x-1],grid[y][x]
					elseif grid[y][x-1]==grid[y][x] then
						grid[y][x-1]*=2
						grid[y][x]=0
					end
				end
			end
		end
	else
		-- shift right
		for x=1,3 do
			for y=2,5 do
				if x~=bfall[1] and y~=bfall[2] then
					if grid[y][x+1]==0 then
						grid[y][x],grid[y][x+1]=grid[y][x+1],grid[y][x]
					elseif grid[y][x+1]==grid[y][x] then
						grid[y][x+1]*=2
						grid[y][x]=0
					end
				end
			end
		end
	end
end

function update_main()
	if (t()-lastmove)>dropspd then
		if #bfall==0 then
			createnew()	
		else
			dropblock()
		end			
		lastmove=t()
	end

	if btnp(0) then
		shiftblocks(0)
	elseif btnp(1) then
		shiftblocks(1)
	end
end

function _init()
	screen=128
	dropspd=1
	blockcols={8,9,10,11,12,13}
	grid=creategrid()
	-- which block is falling
	bfall={}
	lastmove=t()
end

function _draw()
	cls()
	print(#bfall)
	for y=1,5 do
		for x=1,4 do
			print(grid[y][x],10+6*x,10+6*y,7)
		end
	end
end

function _update()
	update_main()
end
