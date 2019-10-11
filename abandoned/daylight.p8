pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- daytime mechanic visualizer
-- by aquova

function _init()
	screen=128
	-- how quickly time elapses
	timespd=0.01
	fps=60
	frame=0
	-- time in minutes
	day2hour=24
	hour2min=60
	currtime=6*hour2min

	sunalt=40
end

function calcsunang()
	return currtime/(day2hour*hour2min)
end

function drawsun()
	local _sunang,_sunposx,_sunposy
	_sunang=calcsunang()
	_sunposx=screen/2+sunalt*sin(_sunang)
	_sunposy=screen/2+sunalt*cos(_sunang)
	--fillp(0b0011001111001100.1)
	fillp(0b0101101001011010.1)
	circfill(_sunposx,_sunposy,10,9)
	fillp()
	circfill(_sunposx,_sunposy,9,10)
end

function drawclock(_x,_y,_c)
	local _hours,_mins
	_hours=flr(currtime/hour2min)
	_mins=currtime-(_hours*hour2min)
	print("".._hours..":".._mins,_x,_y,_c)
end

function dprint()
	-- debug print
	print(currtime,5,5,0)
	print(frame,5,12,0)
end

function _draw()
	cls(12)
	drawsun()
	rectfill(0,screen/2,screen,screen,3)
	drawclock(5,5,0)
	--dprint()
end

function _update60()
	if frame >= (timespd*fps) then
	 currtime=(currtime+1)%(day2hour*hour2min)
	 frame=0
	end
	frame+=1 
end
