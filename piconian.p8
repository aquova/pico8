pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- piconian
-- by aquova

function _init()
	screen=128
	mapsize=4*screen
	shipspd=1
 bulletspeed=2
	-- states:
	-- 0 - title screen
	-- 1 - main
	-- 2 - paused
	-- 3 - game over
	state=0
 points=0
 startx,starty=(mapsize/2),(mapsize/2)
	cam={x=0,y=0}
 camera(cam.x,cam.y)
	bullets={}
	enemybullets={}
	bulletlimit=4
 enemies={}
	lives=3
 nextlevel()
end

function nextlevel()
	--resets map
 reload(0x2000, 0x2000, 0x1000)
 setobstacles()
 setenemies()
	ship={x=startx,y=starty,direc=2,sprt=1,flp=false}
end

function setobstacles()
	for _=0,50 do
		local ax=rnd(mapsize/8)
		local ay=rnd(mapsize/8)
  if (ax<7 or ax>9) and (ay<7 or ay>9) then
   mset(ax,ay,3)
  end

		local bx=rnd(mapsize/8)
		local by=rnd(mapsize/8)
  if (bx<7 or bx>9) and (by<7 or by>9) then
   mset(bx,by,32)
  end
	end
end

function setenemies()
 local enemynum=rnd(5)+3
 for i=0,enemynum do
  local e={}
  repeat
   e.x=flr(rnd(mapsize/8))
  until ((e.x>startx) or ((e.x-2)<startx)) and e.x<((mapsize/8)-2)

  repeat
   e.y=flr(rnd(mapsize/8))
  until ((e.y>starty) or ((e.y-2)<starty)) and e.y<((mapsize/8)-2)

  e.h=6
  add(enemies,e)

 	local offset=(flr(rnd(2))%2)==0 and 4 or 7
  for i=0,2 do
   for j=0,2 do
    mset(e.x+i,e.y+j,(j*16)+i+offset)
   end
  end
 end
end

function findenemy(x,y)
	--(x,y) are sprite coords
	for e in all(enemies) do
		if (e.x <= x and (e.x+2) >= x) and (e.y <= y and (e.y+2) >= y) then
   return e
		end
	end
	return nil
end

function deleteenemy(x,y)
	--x and y are for top left sprite
	for i=0,2 do
 	for j=0,2 do
 		mset(x+i,y+j,0)
 	end
 end
 points+=500
end

function minimap()
	local minix=cam.x+(screen-40)
	local miniy=cam.y+(screen-40)
	for e in all(enemies) do
		local localx=e.x*320/mapsize
		local localy=e.y*320/mapsize
		rectfill(minix+localx,miniy+localy,minix+localx+1,miniy+localy+1,8)
	end
	local shipx=ship.x*40/mapsize
	local shipy=ship.y*40/mapsize
	rectfill(minix+shipx,miniy+shipy,minix+shipx+1,miniy+shipy+1,11)
end

function drawmap()
	local topx=flr(cam.x/128)*128
	local topy=flr(cam.y/128)*128
	local colx=topx/8
	local coly=topy/8
	if colx < 0 then
		colx=48
	end
	if coly < 0 then
		coly=48
	end

	map(colx,coly,topx,topy,16,16)
	map((colx+16)%64,coly,topx+screen,topy,16,16)
	map(colx,(coly+16)%64,topx,topy+screen,16,16)
	map((colx+16)%64,(coly+16)%64,topx+screen,topy+screen,16,16)
end

function death()
 if lives==1 then
  cls()
  state=3
 else
  lives-=1
 end
 ship.x=startx
 ship.y=starty
 bullets={}
 enemybullets={}
end

function shipcollision()
 local sprite=mget(flr(ship.x/8),flr(ship.y/8))
 for i=0,3 do
  if fget(sprite,i) then
   return true
  end
 end

 local sprite=mget(ceil(ship.x/8),flr(ship.y/8))
 for i=0,3 do
  if fget(sprite,i) then
   return true
  end
 end

 local sprite=mget(flr(ship.x/8),ceil(ship.y/8))
 for i=0,3 do
  if fget(sprite,i) then
   return true
  end
 end

 local sprite=mget(ceil(ship.x/8),ceil(ship.y/8))
 for i=0,3 do
  if fget(sprite,i) then
   return true
  end
 end
end

function newbullet()
	local b={}
	--offset by 4 to center bullet
	b.x=ship.x+4
	b.y=ship.y+4
	b.orien=ship.sprt
	b.direc=0
	b.draw=function(this)
		circfill(b.x,b.y,1,9)
	end
	b.update=function(this)
		if b.orien==1 then
			if b.direc==0 then
				b.y-=bulletspeed
			else
				b.y+=bulletspeed
			end
			if b.y < cam.y or b.y > (cam.y+screen) then
				del(bullets,b)
			end
		else
			if b.direc==0 then
				b.x-=bulletspeed
			else
				b.x+=bulletspeed
			end
			if b.x < cam.x or b.x > (cam.x+screen) then
				del(bullets,b)
			end
		end
	end
	b.collide=function(this)
		local sprx=flr(b.x/8)
		local spry=flr(b.y/8)
		local sprite=mget(sprx,spry)
		local e=findenemy(sprx,spry)
		if fget(sprite,0) then
			del(bullets,b)
   if e.h > 1 then
    e.h-=1
    mset(sprx,spry,sprite+6)
    points+=100
   else
    deleteenemy(e.x,e.y)
    del(enemies,e)
   end
		elseif fget(sprite,1) then
			del(bullets,b)
			if e~= nil then
				deleteenemy(e.x,e.y)
   	del(enemies,e)
			end
		elseif fget(sprite,2) then
			del(bullets,b)
		elseif fget(sprite,3) then
			del(bullets,b)
			mset(sprx,spry,0)
   points+=50
		end
	end
	return b
end

function enemybullet(x,y)
	local b={}
	b.x=x
	b.y=y
	b.angle=atan2((ship.x-x),(ship.y-y))
	b.update=function(this)
		b.x+=bulletspeed*cos(b.angle)
		b.y+=bulletspeed*sin(b.angle)
		if b.y < cam.y or b.y > (cam.y+screen) then
			del(enemybullets,b)
		elseif b.x < cam.x or b.x > (cam.x+screen) then
			del(enemybullets,b)
		end
	end
	b.draw=function(this)
		circfill(b.x,b.y,1,8)
	end
	b.collide=function(this)
		if (ship.x <= b.x and b.x <= (ship.x+8)) and (ship.y <= b.y and b.y <= (ship.y+8)) then
   del(enemybullets,b)
   death()
		end
	end
	return b
end

function centertext(t)
 return (screen/2)-#t*2
end

function titlescreen()
	cls()
	print("piconian",centertext("piconian"),20,11)
	print("by aquova",centertext("by aquova"),30,11)
	spr(1,60,50)
	print("press ❎ to start",centertext("press ❎ to start"),70,12)
end

function drawbar()
 spr(1,cam.x+4,cam.y)
 print("x"..lives,cam.x+14,cam.y+2,12)
 print("score: "..points,cam.x+45,cam.y+2,14)
 spr(21,cam.x+110,cam.y)
 print("x"..#enemies,cam.x+120,cam.y+2,8)
end

function _update()
	if state==0 then
		if btnp(5) then
			state=1
		end
	elseif state==2 then
		if btnp(4) then
			state=1
		end
	elseif state==3 then
		if btnp(4) or btnp(5) then
   reload()
			_init()
		end
	else
  if btn(0) then
   ship.direc=0
  elseif btn(1) then
   ship.direc=1
  elseif btn(2) then
   ship.direc=2
  elseif btn(3) then
   ship.direc=3
  end

  if ship.direc==0 then
  	ship.x-=shipspd
  	ship.sprt=2
  	ship.flp=true
  elseif ship.direc==1 then
  	ship.x+=shipspd
  	ship.sprt=2
  	ship.flp=false
  elseif ship.direc==2 then
  	ship.y-=shipspd
  	ship.sprt=1
  	ship.flp=false
  else
  	ship.y+=shipspd
  	ship.sprt=1
  	ship.flp=true
  end

  if btnp(4) then
  	state=2
  end

  if btnp(5) then
  	if count(bullets)<bulletlimit then
   	add(bullets,newbullet())
   	b=newbullet()
   	b.direc=1
   	add(bullets,b)
   	sfx(0)
  	end
  end

  if ship.x < 0 then
  	ship.x=mapsize
  elseif ship.x > mapsize then
  	ship.x=0
  end

  if ship.y < 0 then
  	ship.y=mapsize
  elseif ship.y > mapsize then
  	ship.y=0
  end

  if shipcollision() then
   death()
  end

		if #enemybullets==0 then
   for e in all(enemies) do
    local mapx=8*e.x
    local mapy=8*e.y
    if (cam.x <= mapx and (mapx+24) <= (cam.x+screen)) and (cam.y <= mapy and (mapy+24) <= (cam.y+screen)) then
     add(enemybullets,enemybullet(mapx+12,mapy+12))
     break
    end
   end
  end

  for eb in all(enemybullets) do
   eb:update()
   eb:collide()
  end

  for bullet in all(bullets) do
   bullet:update()
			bullet:collide()
		end

		if #enemies==0 then
   nextlevel()
		end
  cam.x=ship.x-(screen/2)
  cam.y=ship.y-(screen/2)
  camera(cam.x,cam.y)
 end
end

function _draw()
 if state==0 then
  titlescreen()
 elseif state==2 then
 	print("paused",cam.x+57,cam.y+55,8)
 elseif state==3 then
		print("game over",cam.x+centertext("game over"),cam.y+52,9)
  local score="final score: "..points
  print(score,cam.x+centertext(score),cam.y+72,9)
 else
  cls()
  drawmap()
  spr(ship.sprt, ship.x, ship.y, 1, 1, ship.flp, ship.flp)

  for bullet in all(bullets) do
   bullet:draw()
  end

  for eb in all(enemybullets) do
  	eb:draw()
  end
  drawbar()
  minimap()
 end
end

__gfx__
00000000000880000666680000044ff00000000000bbbb000000000000000b2b00000000b2b00000000000000000000000000000000000000000000000000000
00000000000660000066000000f4444f000000000bb22bb0000000000000bb2bb000000bb2bb0000000000000900000000000000000000000000000000000000
0070070080066008066660000444444400000000bb2bb2bb00000000000bb2b2bb0000bb2b2bb00000000000b890000000000000000990090900000000098000
0007700060666606966666680f444f4400bbbb0322bbbb2233bbbb00000b2bbb2b0000b2bbb2b000000000032890000933bb890000088998980000000998b000
000770006666666696666668f444ff440bb22bb3bb2bb2bb3bb22bb0000b2bbb2b0000b2bbb2b00000000983bb8999883bb28900000b288b8b0000999882b000
00700700666666660666600044444440bb2bb2bb0bb22bb0bb2bb2bb000bb2b2bb0000bb2b2bb000000098bb0bb888b0bb289000000bb2b2bb0000888b2bb000
0000000060666606006600000f44440022bbbb2200bbbb0022bbbb220003bb2bb000000bb2bb300000098b2200bbbb0022b890000003bb2bb000000bb2bb3000
00000000000990000666680000ff4400bb2bb2bb00033000bb2bb2bb00033b2b33000033b2b33000000982bb00033000bb2b890000033b2b33000033b2b33000
000000000000000000000000000000000bb22bb330bbbb033bb22bb000b2b00033b00b33000b2b0000982bb330bbbb033bb890000009800033b00b33000b8900
0007000000000000000070000000000000bbbb033bb22bb330bbbb000bb2bb000bb88bb000bb2bb00098bb033bb22bb330bb890000008b000bb88bb000bb8900
0000000000070000000777000000000000000000bb2222bb00000000bb2b2bb0bb2ee2bb0bb2b2bb00000000bb2222bb00000000000098b0bb2ee2bb0bb89000
000000000077700000777770000700000000000008e77e8000000000b2bbb2b3b227722b3b2bbb2b0000000008e77e8000000000000098b3b227722b3b289000
700000000007000000077700000000000000000008e77e8000000000b2bbb2b3b227722b3b2bbb2b0000000008e77e8000000000000098b3b227722b3b289000
0000000000000000000070000000000000000000bb2222bb00000000bb2b2bb0bb2ee2bb0bb2b2bb00000000bb2222bb0000000000998bb0bb2ee2bb0bb28900
0000000000000000000000000000000000bbbb033bb22bb330bbbb000bb2bb000bb88bb000bb2bb00098bb033bb22bb3308900000988bb000bb88bb000bb2890
000000700000000000000000000000000bb22bb330bbbb033bb22bb000b2b00033b00b33000b2b0000098bb330bbbb033b89000000b2b00033b00b33000b2800
00066000000000000000000000000000bb2bb2bb00033000bb2bb2bb00033b2b33000033b2b33000000098bb00033000bb89000000033b2b33000033b2b33000
0601106000000000000000000000000022bbbb2200bbbb0022bbbb220000bb2bb000000bb2bb30000000982200bbbb0022b8900000008b2bb000000bb2bb3000
00111100000000000000000000000000bb2bb2bb0bb22bb0bb2bb2bb000bb2b2bb0000bb2b2bb000000098bb0bb22bb0bb289000000098b2bb0000bb888bb000
611661160000000000000000000000000bb22bb3bb2bb2bb3bb22bb0000b2bbb2b0000b2bbb2b00000098bb3bb2888bb3bb28900000009882b0000b899988000
6116611600000000000000000000000000bbbb3322bbbb2233bbbb00000b2bbb2b0000b2bbb2b00000098b332289998833bbb800000000998800008900099000
0011110000000000000000000000000000000000bb2bb2bb00000000000bb2b2bb0000bb2b2bb000000000008890009900000000000000009900009000000000
06011060000000000000000000000000000000000bb22bb0000000000000bb2bb000000bb2bb0000000000000900000000000000000000000000000000000000
000660000000000000000000000000000000000000bbbb000000000000000b2b00000000b2b00000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000031000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000011000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00110000000000000000110000110000000000000000000000000000000011000000000000110000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000001100000011000000000000110000001100000000000000000000002100000000001100000000110000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000001100000000000000000000000000000000000000000000000000001100000000110000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001100000000110000000000000000000000001100000000001100000000000011000000000000000000000000001100000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000310000000000001100110000000000000000000000000000000011000000001100001100000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000110000110000001100000000000000210000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000110000001100000011000000001100000011000000000000000011000000000000000000000000000000110000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000011000000001100000000000000000000000000000000000000000000000000000000000011000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000011000000000000110000000000000000000000000000001100000000000000000000000000000000000000110000000000001100
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000031000011000000000000000000000000110000001100001100110000000000001100001100000011000000110000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00110000110000000000000000000011000000000000000000000000000000000000000000000000000000000000000000000000002100000000000011000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001100000000110000000000001100000000000011000000000000000011000011000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00310000000000000000000000000000000000000000000000000000000000001100000000000000000011000000000000110000000000001100000000001100
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000031000000310000000000000000000000000000000000000000000000000000110000000000000000000000110000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000310000003100000011000000001100000000001100000000000000110000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000001100000000000000110000000000110000000000000000000000000011000000001100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00210000000031000000000000000000000000001100000000000000000000000000000000001100000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000011000000110000000000000000000000000000000000003100000000000000000000000011000011000000000011000000110000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000002100000011000000000000000000000011000000110000001100110000000000000000000000110000110000000000000000000000000011000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001100000000000000000000110000000011000000000000000000000000000011000000110000000000000000000000002100000011000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000001100000000110000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000110000000000001100000000000000000000000000003100000000000000000000000000310000110000000000000000000011000000110000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000110000000000000100000000000000000000000000000000000000000000000000000000000000000000001100000000000000000021000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000110000001100000031000011000000000000000000000000001100000000000000000000000011000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000011000000000000001100000000000000000000000000000000000000000000310000110000110000000000110000000000000000000000000000001100
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000001100000000000000000000001100000000000000000000000000000000000000000000000000001100000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000011000011000000000000000000000000000000000000000000110000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11000000110000001100000000000000000000000000000031000000003100000000000031000000110000000000001100110000000000000000210011000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001100000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000110000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000110000000000000000000011000000001100000011000011000000110000003100110000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000110000000000000000000011000000000011
__gff__
0000000801010101000104040404000400000000000200010201000000040004080000000101010100010404040400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000110000000000000000000000000000110000000000001100110000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000001300000000000000000000110000000000000000000000000000000000000000130000001200000000000000001300001300001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000011000000000000000000110000000000000000000000000000000000000000000000000000000000000000000012000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000001100000000000000110000000000000000000000120000000000000000000000000000000000000000001200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0011000000000000000000130000000000000000000000000000000000110000000011000000000000000000000013000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000012000000000000000000000000001100000000000000000000000000000000110000000000000000000000110000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000001000000000000000130000110011000000000000000000000000000000110000000000000000000011000000110000000000000013000000000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000001100000000000000000000000011000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000130000000000000000000000130000000000000000001100000000000000000000001100000000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000110000000000000000110000000000000000000000000000000000000000000000000000000000000013000000000000000000130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000011000000001100000000110000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000013001200000000000000000011000000000000110000000000000011000000110000000000000000000000110000130000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000001200000000000000000000000000001100000000000011000000000000000011000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000013000000000000000000000000000000000000000000000000000000000000110000000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1300000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000110000000000000011000000000000000000000000000000001100000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000011000000001100000000000011000000000000000011000000000000110000000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000110000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000011000000000000000000000000000000000000000000000011001100000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000011000000000011000000000000000000000011000000110000000000000000001100000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0011000000000000000000110000000000000000110000000000000000000000000000110000000000000000000000000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000011000000000000000000000000000000000000000000000000000000000000000000000000000000000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000011000000000000001100000000000011000000000000001100001100000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000001100000000001100000000000000000000000000000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000001200000000110000000000000000000000000000000000001100000000000000000000000011000000001100000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000001100000000000000000000000000000011000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000110000000000000000000000000000000000000000001100001100000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000011000000001200000000000011000000000000000000000000000000110000000011000011000000000011000000000000000011000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000011000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000130000000000130000000000000000110000000011000000110000110000110000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000013000000000000000000000000000000000000000011000000000000110011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001d0501f0502005021050220502205022050220502205022050210501c0501c0501b05019050160501605015050110500f0500d0500100001000010000100001000010000100001000010000100001000
