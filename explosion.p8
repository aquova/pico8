pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- dropper
-- by aquova

function _init()
	screen=128
end

function _update()

end

function _draw()
	cls()
	for r=20,100,10 do
		d=(r*t())%100
		for i=0,1,0.05 do
			pset((screen/2)+d*cos(i),(screen/2)+d*sin(i),10)
		end
	end
end
