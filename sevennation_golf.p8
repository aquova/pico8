pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
t=0
h=64
l=line
::_::
cls()
c=12
for i=-4*h,4*h,20 do
a=h
b=h-(t+i)+20
d=h+(t+i)*.86
e=h+(t+i)*.5
f=h-(t+i)*.86
if(b<h+9)c=9
l(a,b,d,e,c)
l(d,e,f,e,c)
l(a,b,f,e,c)
end
flip()
t=(t+1)%20
goto _
