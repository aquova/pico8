pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

--evolving color flower
--#pico8 #tweetcart #tweetjam
t=1
::_::
cls()
t+=.02
for r=8,40,8 do
x,y=0,0
d=r*sin(t/2)/2
for a=0,1,.01 do
n=64+(10+r)*cos(a)+d*sin(a*flr(t)+2*t)
m=64+(10+r)*sin(a)+d*cos(a*flr(t)+2*t)
if(x!=0)line(x,y,n,m,7+r/8)
x,y=n,m
end
end
flip()
goto _
