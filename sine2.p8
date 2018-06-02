pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
	t=0
end

function _update()
	t+=0.01
	ball_x=64+13*cos(t)
	ball_y=64-13*sin(t)
end

function _draw()
	cls(1)
	circ(64,64,13,8)
	line(ball_x,ball_y,ball_x,64,0)
	line(64,64,ball_x,64,0)
	line(64,64,ball_x,ball_y,0)
	color_tri()
	circfill(ball_x,ball_y,2,10)
end

function color_tri()
 slope=ball_y/ball_x
 bound=ball_x
 if ball_y < 64 then
  for i=ball_y,64 do
   line(ball_x,i,bound,i,12)
   bound+=slope
  end
 else
  for i=64,ball_y do
   line(ball_x,i,bound,i,12)
   bound+=slope
  end
 end
end
