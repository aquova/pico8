pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
alpha={"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","."}

cols={}
cols[7]=11
cols[11]=3
cols[3]=1
cols[1]=0
cols[0]=0
frame=0

cls()
print("doodle ii",50,64,7)
print("aquova",100,120,7)
::_::
frame+=1
	-- copy down letter
for y=127,0,-1 do
	for x=0,127 do
		col=pget(x,y)
		if col~=0 then
			pset(x,y+5,col)
			pset(x,y,cols[col])
		end
	end
end

-- create new letter
if frame%5==0 then
 for _=1,3 do
		new=alpha[ceil(rnd(26))]
		print(new,flr(rnd(32))*4,0,7)
	end
end
flip()
goto _
