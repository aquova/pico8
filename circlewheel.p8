pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
pi=3.14

function _init()
 t=0
end

function _update()
 t+=0.01
end

function _draw()
	cls()
	circfill(64,64,62,3)
	drawlines()
 drawcircs()
end

function drawlines()
	for i=0,7 do
		line(64+64*sin(i/16), 64-64*cos(i/16),64+64*sin(0.5+i/16), 64-64*cos(0.5+i/16), 0)
	end
end

function drawcircs()
 for i=0,7 do
  circfill(64+32*sin(t)+32*sin(i/8), 64-32*cos(t)-32*cos(i/8), 3, 10)
 end
end
