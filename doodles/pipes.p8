pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
cls()
r=rnd
c=flr(r(6))+8
x=64
y=0
dx=0
dy=1
::_::
pset(x,y,c)
if r(10)<1 then
	dx=(abs(dx)-1)*sgn(r(1)-.5)
	dy=(abs(dy)-1)*sgn(r(1)-.5)
end
x+=dx
y+=dy
if x<0 or x>128 then
	x%=128
	c=flr(r(6))+8
elseif y<0 or y>128 then
 y%=128
 c=flr(r(6))+8
end
flip()
goto _
