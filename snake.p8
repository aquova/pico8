pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
r=rnd
f=flr
z=128x=7y=7v=0w=1p=0s={}t=f(r(z))u=f(r(z))::★::cls()d=btn
?p
a=v
b=w
if(d(⬅️))v=-1w=0
if(d(➡️))v=1w=0
if(d(⬆️))v=0w=-1
if(d(⬇️))v=0w=1
if(v==-a and w==-b)v=a;w=b
del(s,s[1])for r in all(s)do
pset(r[1],r[2],7)
if(x==r[1]and y==r[2])goto ◆
end
if(x==t and y==u)add(s,{x,y})p+=1t=f(r(z))u=f(r(z))
pset(x,y,7)add(s,{x,y})pset(t,u,9)x=(x+v)%z
y=(y+w)%z
flip()goto ★::◆::
?":("
