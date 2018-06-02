pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-- 3dtest
-- by aquova

-- colors
c_blue=12
c_white=7
c_black=0

palettes={
 {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15},
 {0,1,2,3,2,5,6,7,8,4,9,11,12,13,14,9},
 {0,1,1,3,2,1,13,6,2,2,4,3,13,5,4,4},
 {0,0,1,1,1,1,5,13,2,2,2,3,5,1,2,2},
 -- {0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1}
 -- {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
}

-- shapes made of triangles
square={
 {
  {-1,-1,0},
  {1,-1,0},
  {-1,1,0},
  c=c_blue
 },
 {
  {1,-1,0},
  {1,1,0},
  {-1,1,0},
  c=c_blue
 }
}

cube =
{
	{ -- Back
		{-1,-1,1},
		{1,-1,1},
		{-1,1,1},
		c = c_blue
	},
	{
		{1,-1,1},
		{1,1,1},
		{-1,1,1},
		c = c_blue
	},
	{ -- left side
		{-1,-1,-1},
		{-1,-1,1},
		{-1,1,-1},
		c = c_blue
	},
	{
		{-1,-1,1},
		{-1,1,1},
		{-1,1,-1},
		c = c_blue
	},
	{ -- Right side
		{1,-1,1},
		{1,-1,-1},
		{1,1,1},
		c = c_blue
	},
	{
		{1,1,1},
		{1,-1,-1},
		{1,1,-1},
		c = c_blue
	},
	{ -- Front
		{-1,-1,-1},
		{-1,1,-1},
		{1,-1,-1},
		c = c_blue
	},
	{
		{1,-1,-1},
		{-1,1,-1},
		{1,1,-1},
		c = c_blue
	},
	{ -- Top
		{-1,-1,1},
		{-1,-1,-1},
		{1,-1,-1},
		c = c_blue
	},
	{
		{1,-1,-1},
		{1,-1,1},
		{-1,-1,1},
		c = c_blue
	},
	{ -- Bottom
		{-1,1,1},
		{1,1,-1},
		{-1,1,-1},
		c = c_blue
	},
	{
		{1,1,-1},
		{-1,1,1},
		{1,1,1},
		c = c_blue
	},
}


function _init()
 cam = {0,0,-3.5} -- initial camera position
 mult = 64 -- view multiplier
 cs = cube -- current shape
 light={0,0,-1}
 fill=true
end

function _update()
 if btn(0) then cs=rotate_shape(cs,2,0.01) end
 if btn(1) then cs=rotate_shape(cs,2,-0.01) end
 if btn(2) then cs=rotate_shape(cs,1,0.01) end
 if btn(3) then cs=rotate_shape(cs,1,-0.01) end
 if btn(4) then cs=rotate_shape(cs,3,0.01) end
 if btn(5) then cs=rotate_shape(cs,3,-0.01) end
end

function centertext(t)
	return 64-#t*2.5
end

function _draw()
	cls(c_white)
	phrase="⬅️ ➡️ ⬆️ ⬇️ ❎ 🅾️ to rotate"
	print(phrase,centertext(phrase),2,c_black)
 draw_shape(cs)
end

function draw_shape(s)
 ss = sortdepths(s)
 for tri in all(ss) do
  draw_tri(tri)
  if fill==true then
   fill_tri(tri)
  end
 end
end

function draw_tri(t)
 x0,y0=project(t[1])
 x1,y1=project(t[2])
 x2,y2=project(t[3])

 nc=newColor(t,light)

 line(x0,y0,x1,y1,nc)
 line(x0,y0,x2,y2,nc)
 line(x1,y1,x2,y2,nc)
end

function project(p)
 local x=(p[1]-cam[1])*mult/(p[3]-cam[3])+127/2 -- calculate x and center
 local y=(p[2]-cam[2])*mult/(p[3]-cam[3])+127/2 -- calculate x and center
 return x,y
end

function translate_shape(s,t)
 -- s is shape, t is offset
 ns={}
 for tri in all(s) do
  add(ns, {tri[1]+t[1], tri[2]+t[2], tri[3]+t[3], tri.c})
 end
 return ns
end

function rotate_shape(s,a,r)
 -- s is shape, a is axis, r is angle
 ns={}
 for tri in all(s) do
  add(ns, {rotate_point(tri[1],a,r),rotate_point(tri[2],a,r),rotate_point(tri[3],a,r),c=tri.c})
 end
 return ns
end

function rotate_point(p,a,r)
 -- first detmine which axis is being rotated
 -- 1 is x, 2 is y, 3 is z
 if a==1 then
  x,y,z=3,2,1
 elseif a==2 then
  x,y,z=1,3,2
 elseif a==3 then
  x,y,z=1,2,3
 end

 _x=cos(r)*p[x]-sin(r)*p[y]
 _y=sin(r)*p[x]+cos(r)*p[y]
 np={}
 np[x]=_x
 np[y]=_y
 np[z]=p[z]

 return np
end

function fillbottomtriangle(p1, p2, p3, c)
 slope1=(p2[1]-p1[1])/(p2[2]-p1[2])
 slope2=(p3[1]-p1[1])/(p3[2]-p1[2])

 bound1=p1[1]
 bound2=p1[1]

 for l=p1[2],p2[2] do
  line(bound1,l,bound2,l,c)
  bound1+=slope1
  bound2+=slope2
 end

 line(p2[1],p2[2],p3[1],p3[2],c)
end

function filltoptriangle(p1, p2, p3, c)
 slope1=(p3[1]-p1[1])/(p3[2]-p1[2])
 slope2=(p3[1]-p2[1])/(p3[2]-p2[2])

 bound1=p3[1]
 bound2=p3[1]

 for l=p3[2],p1[2],-1 do
  line(bound1,l,bound2,l,c)
  bound1-=slope1
  bound2-=slope2
 end

 line(p1[1],p1[2],p2[1],p2[2],c)
end

function sorty(t)
 nt=t
 if (t[1][2] > t[2][2]) then swap(t,1,2) end
 if (t[2][2] > t[3][2]) then swap(t,2,3) end
 if (t[1][2] > t[2][2]) then swap(t,1,2) end

 return nt
end

function swap(t,a,b)
 -- t is triangle, a is first index, b is second
 tmp=t[a]
 t[a]=t[b]
 t[b]=tmp
end

function fill_tri(t)
 x1,y1=project(t[1])
 x2,y2=project(t[2])
 x3,y3=project(t[3])

 ps={{x1,y1},{x2,y2},{x3,y3}}

 nt=sorty(ps)
 nc=newColor(t,light)
 if (nt[2][2]==nt[3][2]) then
  fillbottomtriangle(nt[1],nt[2],nt[3],nc)
 elseif (nt[1][2]==nt[2][2]) then
  filltoptriangle(nt[1],nt[2],nt[3],nc)
 else
  nvert={nt[1][1]+((nt[2][2]-nt[1][2])/(nt[3][2]-nt[1][2])*(nt[3][1]-nt[1][1])), nt[2][2]}
  fillbottomtriangle(nt[1],nt[2],nvert,nc)
  filltoptriangle(nt[2],nvert,nt[3],nc)
 end
end

function length_vec(v)
 return (abs(v[1]) + abs(v[2]) + abs(v[3]))
end

function normalize(v)
 l=length_vec(v)
 return l==0 and {0,0,0} or {v[1]/l,v[2]/l,v[3]/l}
end

function vectorize(t)
 local v1 = {t[2][1]-t[1][1], t[2][2]-t[1][2], t[2][3]-t[1][3]}
 local v2 = {t[3][1]-t[1][1], t[3][2]-t[1][2], t[3][3]-t[1][3]}
 return v1,v2
end

function crossproduct(v1,v2)
	return {v1[2]*v2[3] - v1[3]*v2[2],v1[3]*v2[1] - v1[1]*v2[3],v1[1]*v2[2] - v1[2]*v2[1]}
end

function dotproduct(v1,v2)
 return (v1[1]*v2[1] + v1[2]*v2[2] + v1[3]*v2[3])
end

function newColor(t, l)
 -- t is triangle, l is light vector
 local v1,v2 = vectorize(t)
 n=normalize(crossproduct(v1,v2))
 nl=normalize(l)
 angle=dotproduct(nl,n) / (length_vec(n) * length_vec(nl))

 angle+=1
 angle/=2

 angle=abs(angle)
 return palettes[#palettes-flr((#palettes-1)*angle)][t.c+1]
end

function finddepth(t)
 return (t[1][3] + t[2][3] + t[3][3]) / 3
end

function sortdepths(a, t)
 -- selection sort for z-depths
 na=a
 for i=1,#na do
  largest=i
  for j=i+1,#na do
   if finddepth(na[j]) > finddepth(na[largest]) then
    largest=j
   end
  end
  swap(na,i,largest)
 end
 return na
end
