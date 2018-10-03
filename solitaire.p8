pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- solitaire
-- by aquova

-- todo:
-- move stacks
-- display valid placement locations
-- move cards off board
-- display hand
-- mouse option?
-- options menu

function _init()
	screen=128
	symbols={"a","2","3","4","5","6","7","8","9","10","j","q","k"}
	-- pink shall be transparent, not black
	palt(0,false)
	palt(14,true)
	
	-- where the cursor is located
	ptr={x=1,y=1}
	cardw,cardh=12,16
	rowbuf,colbuf=10,14
	
	_upd=update_title
	_drw=draw_title
end

function _update()
	_upd()
end

function _draw()
	_drw()
end
-->8
-- title screen

function draw_title()
	cls(3)
	printc(screen/2,"solitaire",0)
	--printc(screen/2+10,"by aquova",0)
end

function update_title()
	if btnp(❎) or btnp(🅾️) then
		-- maybe add this to own funciton
		deck=create_deck()
		deck=shuffle_deck(deck)
		table=setup_table()
		holding=false
				
		_upd=update_main
		_drw=draw_main		
	end
end
-->8
-- main behavior

function update_main()	
	if btnp(⬅️) then
		ptr.x=max(1,ptr.x-1)
		-- don't shift below table
		if ptr.y > #table[ptr.x] then
			ptr.y=#table[ptr.x]
		end
		
		-- shift onto first visible card
		for i=ptr.y,#table[ptr.x] do
			if #table[ptr.x]==0 then
				ptr.y=1
				break
			elseif table[ptr.x][i].vis then
				ptr.y=i
				break
			end
		end
	elseif btnp(➡️) then
		ptr.x=min(#table,ptr.x+1)
		if ptr.y > #table[ptr.x] then
			ptr.y=#table[ptr.x]
		end
		
		for i=ptr.y,#table[ptr.x] do
			if table[ptr.x][i].vis then
				ptr.y=i
				break
			end
		end
	end
	
	if btnp(⬆️) then
		if ptr.y > 1 then
			if table[ptr.x][ptr.y-1].vis then
				ptr.y-=1
			end
		end
	elseif btnp(⬇️) then
		ptr.y=min(#table[ptr.x],ptr.y+1)
	end
	
	if btnp(❎) then
		if not holding then
			if not table[ptr.x][ptr.y].vis then
				table[ptr.x][ptr.y].vis=true
			else
				holding=true
				pickup_cards()
			end
		else
			if hand_placeable() then
				place_cards()
				holding=false
			end
		end
	end
	
	if btnp(🅾️) then
		if holding then
			ptr.x=last_pickup
			ptr.y=#table[ptr.x]
			place_cards()
			holding=false
			ptr.y=#table[ptr.x]
		end
	end
end


-->8
-- drawing functions

function draw_main()
	cls(3)
	draw_table()
	draw_ptr()
end

function draw_ptr()
	local x=colbuf*ptr.x
	local y=rowbuf*ptr.y
	
	if not holding then
		local ptr_h=cardh+rowbuf*(#table[ptr.x]-ptr.y)
		rect(x,y,x+cardw,y+ptr_h,10)
	else
		for i=1,#hand do
			hand[i].card:draw(colbuf*ptr.x,(rowbuf+i)*ptr.y)
		end
	end
end

function printc(_y,_t,_c)
	print(_t,ctext(0,screen,_t),_y,_c)
end
-->8
-- card/deck functions

function new_card(_n,_suit)
	local c={value=_n,suit=_suit}
	
	
	c.draw=function(this,_x,_y)
		rectfill(_x,_y+1,_x+cardw,_y+cardh-1,0)
		rectfill(_x+1,_y,_x+cardw-1,_y+cardh,0)
		rectfill(_x+1,_y+1,_x+cardw-1,_y+cardh-1,15)
		if this.suit=="d" or this.suit=="h" then
			print(symbols[this.value],ctext(_x,_x+cardw,symbols[this.value]),_y+2,8)
		else
			print(symbols[this.value],ctext(_x,_x+cardw,symbols[this.value]),_y+2,0)			
		end
		if this.suit=="h" then
			sspr(24,1,7,7,_x+3,_y+8)
		elseif this.suit=="s" then
			sspr(24,8,7,8,_x+3,_y+8)
		elseif this.suit=="d" then
			sspr(32,0,5,8,_x+4,_y+8)
		else
			sspr(32,8,7,8,_x+3,_y+8)
		end
	end
	
	return c
end

function create_deck()
	-- for simplicity:
	-- jack: 11
	-- queen: 12
	-- king: 13
	-- ace: 1

	local deck={}
	local suits={"d","c","h","s"}
	
	for val=1,13 do
		for suit=1,4 do
			local card=new_card(val,suits[suit])
			add(deck,card)
		end
	end
	
	return deck
end

function shuffle_deck(_d)
	local newd={}
	
	repeat
		local c=_d[ceil(rnd(#_d))]
		add(newd,c)
		del(_d,c)
	until #_d==0
	
	return newd
end

function draw_card()
	local c=deck[1]
	del(deck,c)
	return c
end

function is_deck_empty()
	return #deck==0
end

function is_card_red(_c)
	return (_c.suit=="d") or (_c.suit=="h")
end
-->8
-- table functions

function setup_table()
	-- seven 'slots' for cards
	local t={}
	for i=1,7 do
		t[i]={}
		for j=1,i do
			local c=draw_card()
			-- if card should be visible on table
			if j==i then
				add(t[i],{card=c,vis=true})
			else
				add(t[i],{card=c,vis=false})
			end
		end
	end
	
	return t
end

function draw_table()
	-- draw main rows
	for col=1,#table do
		for row=1,#table[col] do
			local spot=table[col][row]
			if spot.vis then
				spot.card:draw(col*colbuf,row*rowbuf)
			else
				sspr(8,0,13,16,col*colbuf,row*rowbuf)
			end
		end
	end
	
	-- draw four 'finished' piles
	for i=1,4 do
		draw_blank(i*15,100)
	end
end

function draw_blank(_x,_y)
	rectfill(_x+1,_y,_x+cardw-1,_y+cardh,7)
	rectfill(_x,_y+1,_x+cardw,_y+cardh-1,7)
	rectfill(_x+1,_y+1,_x+cardw-1,_y+cardh-1,3)
end

function pickup_cards()
	hand={}
	last_pickup=ptr.x
	for i=#table[ptr.x],ptr.y,-1 do
		add(hand,table[ptr.x][i])
		del(table[ptr.x],table[ptr.x][i])
	end
	hand=reverse(hand)
end

function place_cards()
	table[ptr.x]=append(table[ptr.x],hand)
	hand=nil
end

function hand_placeable()
	local col=table[ptr.x]
	
	if #col==0 and symbol[hand[1].card.value]=="k" then
		return true
	end	
	
	if hand[1].card.value==col[#col].card.value-1 then
		if (is_card_red(hand[1].card) and not is_card_red(col[#col].card)) then
			return true
		elseif (not is_card_red(hand[1].card) and is_card_red(col[#col].card)) then
			return true
		end
	end
	
	return false
end
-->8
-- helper functions

function append(_a,_b)
	for x in all(_b) do
		add(_a,x)
	end
	return _a
end

function reverse(_a)
	local newa={}
	for i=#_a,1,-1 do
		add(newa,_a[i])
	end
	return newa
end

function ctext(_x1,_x2,_t)
 return _x1+((_x2-_x1)/2)-#_t*2+1
end
__gfx__
00000000e00000000000eeeeeeeeeeeeee8eeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ffcf555fcff0eeee88e88eee888eeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000fffcf6fcfff0eee8888888ee888eeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000ffffcccffff0eee8888888e88888eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000fffcf6fcfff0eee8888888e88888eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070001fcf555fcf10eeee88888eee888eeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000f1fcf6fcf1f0eeeee888eeee888eeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000005f1fcccf1f50eeeeee8eeeeee8eeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000f1fcf6fcf1f0eeeeee0eeeeeee0eeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000001fcf555fcf10eeeee000eeeee000eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000fffcf6fcfff0eeee00000eeee000eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ffffcccffff0eee0000000ee0e0e0ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000fffcf6fcfff0eee0000000e0000000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ffcf555fcff0eee0000000e000e000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e00000000000eeeee00e00eee0e0e0ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eeeeeeeeeeeeeeeeeee0eeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
