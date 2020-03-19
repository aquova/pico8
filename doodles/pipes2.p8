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
f=0
::_::
pset(x,y,c)
if r(10)<1 then
	dx=(abs(dx)-1)*sgn(r(1)-.5)
	dy=(abs(dy)-1)*sgn(r(1)-.5)
end
x=(x+dx)%128
y=(y+dy)%128
if rnd(10000)<f then
	c=flr(r(6))+8
	f=0
end
f+=1
flip()
goto _
