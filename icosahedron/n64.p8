pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- n64
-- by aquova

-- colors
c_blue=12
c_white=7
c_black=0
c_green=11
c_red=8
c_orange=9

phi=1.618

-- N64 logo, in triangles
n64 = {
 -- Front N
 {
  {-2, 2, 2},
  {-2, -2, 2},
  {-1, -2, 2},
  c=c_green
 },
 {
  {-2, 2, 2},
  {-1, 2, 2},
  {-1, -2, 2},
  c=c_green
 },
 {
  {-1, 2, 2},
  {-1, 0, 2},
  {1, 0, 2},
  c=c_green
 },
 {
  {-1, 0, 2},
  {1, 0, 2},
  {1, -2, 2},
  c=c_green
 },
 {
  {1, 2, 2},
  {2, 2, 2},
  {2, -2, 2},
  c=c_green
 },
 {
  {1, 2, 2},
  {1, -2, 2},
  {2, -2, 2},
  c=c_green
 },
 -- Side N
 {
  {2, 2, 2},
  {2, -2, 2},
  {2, 2, 1},
  c=c_blue
 },
 {
  {2, 2, 1},
  {2, -2, 1},
  {2, -2, 2},
  c=c_blue
 },
 {
  {2, 2, 1},
  {2, 0, 1},
  {2, 0, -1},
  c=c_blue
 },
 {
  {2, 0, 1},
  {2, 0, -1},
  {2, -2, -1},
  c=c_blue
 },
 {
  {2, 2, -1},
  {2, 2, -2},
  {2, -2, -2},
  c=c_blue
 },
 {
  {2, 2, -1},
  {2, -2, -1},
  {2, -2, -2},
  c=c_blue
 },
 -- Back N
 {
  {2, 2, -2},
  {2, -2, -2},
  {1, -2, -2},
  c=c_green
 },
 {
  {2, 2, -2},
  {1, 2, -2},
  {1, -2, -2},
  c=c_green
 },
 {
  {1, 2, -2},
  {1, 0, -2},
  {-1, 0, -2},
  c=c_green
 },
 {
  {1, 0, -2},
  {-1, 0, -2},
  {-1, -2, -2},
  c=c_green
 },
 {
  {-2, 2, -2},
  {-1, 2, -2},
  {-2, -2, -2},
  c=c_green
 },
 {
  {-1, 2, -2},
  {-1, -2, -2},
  {-2, -2, -2},
  c=c_green
 },
 -- Other side N
 {
  {-2, 2, -2},
  {-2, 2, -1},
  {-2, -2, -2},
  c=c_blue
 },
 {
  {-2, 2, -1},
  {-2, -2, -2},
  {-2, -2, -1},
  c=c_blue
 },
 {
  {-2, 2, -1},
  {-2, 0, -1},
  {-2, 0, 1},
  c=c_blue
 },
 {
  {-2, 0, -1},
  {-2, 0, 1},
  {-2, -2, 1},
  c=c_blue
 },
 {
  {-2, -2, 2},
  {-2, -2, 1},
  {-2, 2, 2},
  c=c_blue
 },
 {
  {-2, 2, 1},
  {-2, 2, 2},
  {-2, -2, 1},
  c=c_blue
 },
 -- Top squares
 {
  {2, 2, 2},
  {1, 2, 2},
  {2, 2, 1},
  c=c_orange
 },
 {
  {1, 2, 2},
  {1, 2, 1},
  {2, 2, 1},
  c=c_orange
 },
 {
  {2, 2, -2},
  {1, 2, -2},
  {2, 2, -1},
  c=c_orange
 },
 {
  {1, 2, -2},
  {1, 2, -1},
  {2, 2, -1},
  c=c_orange
 },
 {
  {-2, 2, 2},
  {-1, 2, 2},
  {-2, 2, 1},
  c=c_orange
 },
 {
  {-1, 2, 2},
  {-1, 2, 1},
  {-2, 2, 1},
  c=c_orange
 },
 {
  {-2, 2, -2},
  {-1, 2, -2},
  {-2, 2, -1},
  c=c_orange
 },
 {
  {-1, 2, -2},
  {-1, 2, -1},
  {-2, 2, -1},
  c=c_orange
 },
 -- Bottom Squares
 {
  {2, -2, 2},
  {1, -2, 2},
  {2, -2, 1},
  c=c_orange
 },
 {
  {1, -2, 2},
  {1, -2, 1},
  {2, -2, 1},
  c=c_orange
 },
 {
  {2, -2, -2},
  {1, -2, -2},
  {2, -2, -1},
  c=c_orange
 },
 {
  {1, -2, -2},
  {1, -2, -1},
  {2, -2, -1},
  c=c_orange
 },
 {
  {-2,-2, 2},
  {-1,-2, 2},
  {-2,-2, 1},
  c=c_orange
 },
 {
  {-1,-2, 2},
  {-1,-2, 1},
  {-2,-2, 1},
  c=c_orange
 },
 {
  {-2,-2, -2},
  {-1,-2, -2},
  {-2,-2, -1},
  c=c_orange
 },
 {
  {-1,-2, -2},
  {-1,-2, -1},
  {-2,-2, -1},
  c=c_orange
 },
 -- Top slants
 {
  {-1, 2, 2},
  {-1, 2, 1},
  {1, 0, 2},
  c=c_red
 },
 {
  {1, 0, 2},
  {1, 0, 1},
  {-1, 2, 1},
  c=c_red
 },
 {
  {-2, 2, -1},
  {-1, 2, -1},
  {-2, 0, 1},
  c=c_green
 },
 {
  {-2, 0, 1},
  {-1, 0, 1},
  {-1, 2, -1},
  c=c_green
 },
 {
  {1, 2, -2},
  {1, 2, -1},
  {-1, 0, -2},
  c=c_red
 },
 {
  {-1, 0, -2},
  {-1, 0, -1},
  {1, 2, -1},
  c=c_red
 },
 {
  {1, 2, 1},
  {2, 2, 1},
  {2, 0, -1},
  c=c_green
 },
 {
  {2, 0, -1},
  {1, 0, -1},
  {1, 2, 1},
  c=c_green
 },
 -- Bottom Slants
 {
  {-1, 0, 2},
  {-1, 0, 1},
  {1, -2, 2},
  c=c_red
 },
 {
  {1, -2, 2},
  {1, -2, 1},
  {-1, 0, 1},
  c=c_red
 },
 {
  {-2, 0, -1},
  {-1, 0, -1},
  {-2, -2, 1},
  c=c_green
 },
 {
  {-2, -2, 1},
  {-1, -2, 1},
  {-1, 0, -1},
  c=c_green
 },
 {
  {1, 0, -2},
  {1, 0, -1},
  {-1, -2, -2},
  c=c_red
 },
 {
  {-1, -2, -2},
  {-1, -2, -1},
  {1, 0, -1},
  c=c_red
 },
 {
  {1, 0, 1},
  {2, 0, 1},
  {2, -2, -1},
  c=c_green
 },
 {
  {2, -2, -1},
  {1, -2, -1},
  {1, 0, 1},
  c=c_green
 },
 -- Inner N's
 {
  {-2, 2, 1},
  {-2, -2, 1},
  {-1, -2, 1},
  c=c_green
 },
 {
  {-2, 2, 1},
  {-1, 2, 1},
  {-1, -2, 1},
  c=c_green
 },
 {
  {-1, 2, 1},
  {-1, 0, 1},
  {1, 0, 1},
  c=c_green
 },
 {
  {-1, 0, 1},
  {1, 0, 1},
  {1, -2, 1},
  c=c_green
 },
 {
  {1, 2, 1},
  {2, 2, 1},
  {2, -2, 1},
  c=c_green
 },
 {
  {1, 2, 1},
  {1, -2, 1},
  {2, -2, 1},
  c=c_green
 },
 -- Side N
 {
  {1, 2, 2},
  {1, -2, 2},
  {1, 2, 1},
  c=c_blue
 },
 {
  {1, 2, 1},
  {1, -2, 1},
  {1, -2, 2},
  c=c_blue
 },
 {
  {1, 2, 1},
  {1, 0, 1},
  {1, 0, -1},
  c=c_blue
 },
 {
  {1, 0, 1},
  {1, 0, -1},
  {1, -2, -1},
  c=c_blue
 },
 {
  {1, 2, -1},
  {1, 2, -2},
  {1, -2, -2},
  c=c_blue
 },
 {
  {1, 2, -1},
  {1, -2, -1},
  {1, -2, -2},
  c=c_blue
 },
 -- Back N
 {
  {2, 2, -1},
  {2, -2, -1},
  {1, -2, -1},
  c=c_green
 },
 {
  {2, 2, -1},
  {1, 2, -1},
  {1, -2, -1},
  c=c_green
 },
 {
  {1, 2, -1},
  {1, 0, -1},
  {-1, 0, -1},
  c=c_green
 },
 {
  {1, 0, -1},
  {-1, 0, -1},
  {-1, -2, -1},
  c=c_green
 },
 {
  {-2, 2, -1},
  {-1, 2, -1},
  {-2, -2, -1},
  c=c_green
 },
 {
  {-1, 2, -1},
  {-1, -2, -1},
  {-2, -2, -1},
  c=c_green
 },
 -- Other side N
 {
  {-1, 2, -2},
  {-1, 2, -1},
  {-1, -2, -2},
  c=c_blue
 },
 {
  {-1, 2, -1},
  {-1, -2, -2},
  {-1, -2, -1},
  c=c_blue
 },
 {
  {-1, 2, -1},
  {-1, 0, -1},
  {-1, 0, 1},
  c=c_blue
 },
 {
  {-1, 0, -1},
  {-1, 0, 1},
  {-1, -2, 1},
  c=c_blue
 },
 {
  {-1, -2, 2},
  {-1, -2, 1},
  {-1, 2, 2},
  c=c_blue
 },
 {
  {-1, 2, 1},
  {-1, 2, 2},
  {-1, -2, 1},
  c=c_blue
 },
}


function _init()
 cam = {0,0,-7} -- initial camera position
 mult = 64 -- view multiplier
 cs = n64 -- current shape
 light={0,0,-1}
 fill=true
 frame=true
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
  if fill then
   fill_tri(tri)
  end
  if frame then
   draw_tri(tri)
  end
 end
end

function draw_tri(t)
 x0,y0=project(t[1])
 x1,y1=project(t[2])
 x2,y2=project(t[3])

 line(x0,y0,x1,y1,t.c)
 line(x0,y0,x2,y2,t.c)
 line(x1,y1,x2,y2,t.c)
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
 if (nt[2][2]==nt[3][2]) then
  fillbottomtriangle(nt[1],nt[2],nt[3],t.c)
 elseif (nt[1][2]==nt[2][2]) then
  filltoptriangle(nt[1],nt[2],nt[3],t.c)
 else
  nvert={nt[1][1]+((nt[2][2]-nt[1][2])/(nt[3][2]-nt[1][2])*(nt[3][1]-nt[1][1])), nt[2][2]}
  fillbottomtriangle(nt[1],nt[2],nvert,t.c)
  filltoptriangle(nt[2],nvert,nt[3],t.c)
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
