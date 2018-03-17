pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
b=32g=20t=0w=128h=64y=70
c=circfill
p=clip
l=line
::_::cls(8)c(h,h,b,10)for y=0,h do s=sin(y/4+t/g)p(0,y+b,w,1)c(h,h,30+s,7)end
p()for j=0,g,7 do l(0,y+(t+j)%g,w,y+(t+j)%g,8)end
rectfill(0,86,w,w,2)for i=0,4 do l(b+i*16,86,b*i,w,12)l(0,90+7.8*i,w,90+7.8*i,12)end
t+=.2flip()goto _
