pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
t=0
h=128
w=128
pi=3.14
::_::
cls()
for i=-2*h,2*h,20 do
 x1 = w/2 + (t+i)*sin(0)
 y1 = h/2 - (t+i)*cos(0) + 20

 x2 = w/2 + (t+i)*sin(2*pi/3)
 y2 = h/2 + (t+i)*cos(2*pi/3)

 x3 = w/2 - (t+i)*sin(2*pi/3)
 y3 = h/2 + (t+i)*cos(2*pi/3)

 if (y1 < h/2 + 10) then
  col=9
 else
  col=12
 end
 line(x1,y1,x2,y2,col)
 line(x2,y2,x3,y3,col)
 line(x1,y1,x3,y3,col)
end

flip()
t=(t+1)%20
goto _
