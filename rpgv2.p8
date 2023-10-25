pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
function _init()
	create_player()
 init_msg()
 init_camera()
 
end

function _update()
 
 if #messages==0 then
 	player_movement()
 end
 update_camera()
 update_msg()
end

function _draw()
	cls()
	draw_map()
	draw_player()
 draw_ui()
 draw_msg()
end

-->8
--map
function draw_map()
	map(0,0,0,0,128,64)
end

function check_flag(flag,x,y)
	local sprite=mget(x,y)
	return fget(sprite,flag)
end
--camera zelda
function init_camera()
	camx,camy=0,0
end

function update_camera()
	 sectionx=flr(p.x/16)*16
	 sectiony=flr(p.y/16)*16
	 
	 destx=sectionx*8
	 desty=sectiony*8
	 
	 diffx=destx-camx
	 diffy=desty-camy
	 
	 diffx/=4
	 diffy/=4
	 
	 camx+=diffx
	 camy+=diffy
	 
	camera(camx,camy)
end
--camera that follows you
function other_camera()
	 camx=mid(0,(p.x-7.5)*8+p.ox,
		(31-15)*8)
	 camy=mid(0,(p.y-7.5)*8+p.oy,
		(31-15)*8)
	camera(camx,camy)
end

function next_tile(x,y)
	local sprite=mget(x,y)
	mset(x,y,sprite+1)
end

function pick_up_key(x,y)
	next_tile(x,y)
	p.keys+=1
	sfx(1)
end

function open_door(x,y)
	next_tile(x,y)
	p.keys-=1
	sfx(2)
end

-->8
--player

function create_player()
	p={
		x=6,y=3,
		ox=0,oy=0,
		start_ox=0,start_oy=0,
		anim_t=0,
		sprite=16,
		speed = 1,
	 keys=0
	 }	
end

function player_movement()
	newx=p.x
	newy=p.y
	if p.anim_t==0 then
		newox=0
		newoy=0
	 if(btn(⬅️))then
		 newx-=1
		 newox=8
		 p.flip=true
		elseif(btn(➡️)) then
		 newx+=1
		 newox=-8
		 p.flip=false
		elseif(btn(⬇️)) then
		 newy+=1
		 newoy=-8
		elseif(btn(⬆️)) then
		 newy-=1
		 newoy=8
	 end
 end


	interact(newx,newy)
	
	if not check_flag(0,newx,newy)
 and (p.x!=newx or p.y!=newy) then
		p.x=mid(0,newx,127)
		p.y=mid(0,newy,63)
	 p.start_ox=newox
	 p.start_oy=newoy
	 p.anim_t=1
 end


--animation
	p.anim_t=max(p.anim_t-0.125,0)	
	p.ox=p.start_ox*p.anim_t
	p.oy=p.start_oy*p.anim_t
	
	if p.anim_t>=0.5 then
		p.sprite=17
	else
		p.sprite=16
	end
	
		
end

function interact(x,y)
	if check_flag(1,x,y) then
		pick_up_key(x,y)
	elseif check_flag(2,x,y)	and 
	p.keys>0 then
		open_door(x,y)
	end
		if check_flag(3,x,y) then
		pick_up_key(x,y)
		end
	--messages
	if x==2 and y==2 then
		create_msg("panneau","bienvenue!")
	end
	if x==9 and y==2 then
		create_msg("alyssa",
"hello\n",
		"welcome to green kingdom",
		"save us,please")
		end
	if y==20 and x==6 and x==7
 and not visited_dungeon then	
			create_msg("alyssa",
"hello\n",
		"please save the kingdom !")
		visited_dungeon=false
	end
end


function draw_player()
	spr(p.sprite,
	p.x*8+p.ox,p.y*8+p.oy,
	1,1,p.flip)
	
--	spr(id,x,y,1,1,true)
end
-->8
--ui

function draw_ui()
camera()
	palt(0,false) -- true or false
	palt(12,true) -- met en transparent une couleur
	spr(32,2)
	palt()
	print_outline("X"..p.keys,10,2,7)
end

function print_outline(text,x,y)
	print(text,x-1,y,0)
	print(text,x+1,y,0)
	print(text,x+1,y,0)
	print(text,x,y-1,0)
	print(text,x,y+1,0)
	print(text,x,y,7)
end


-->8
--panneaux et npc

function init_msg()
	messages={}
end

function create_msg(name,...)
msg_title=name
messages={...}
end


function update_msg()
 if btnp(❎) then
 	deli(messages,1)
 end
end


function draw_msg()
	if messages[1] then
	local y=100
	if p.y%16>=9 then
		y=10
	end
	--titre
		rectfill(7,y,7+#msg_title*4,y+6,2)
		print(msg_title,8,y+1,9)
	--messages
	rectfill(3,y+8,124,y+24,4)
	rect(2,y+8,124,y+24,2)
		print(messages[1],10,y+12,7)
	end	
end


__gfx__
000000003333333333333333333333333333333333bbbb3311111111444444444ffffff4dddddddd1111d11155555555566666651111d1111111d11144444444
000000003333333333a3333333333833333333333bbaabb3111111114444444444444444dddddddd111111116666666655555555111111111111111144444444
00700700333333333a9a333333338a83333333333bbbab1311111111cccccccc4ffffff4dddddddd1d1111d155555555566666651d1111d11d1111d144444444
000770003333333333a33a3333333833b33b33b33bbbb31311111111111111114ff44f44dddddddd1111111166666666566556551111111111111111444544d4
00077000333333333333aca333e333333b3b3b33313b331311111111111111114ffffff4dddddddd111d11115555555556666665111d1111111d111144444444
007007003333333333333a333e2e33333b333b333311113311111111111111114444ff44dddddddd111111116666666655556655111111133111111144d44444
00000000333333333333333333e33333333333333332233311111111111111114ffffff4ddddddddd11111d15555555556666665d1111133331111d144444444
000000003333333333333333333333333333333333144233111111111111111144444444dddddddd1111111166666666555555551111133333311111444444d4
0444440004444400dddddddddddddddd333333333cccccc39999999933333333333333333333333333333333ffffffff3343bb34444444445455545544444445
0444ff400444ff40ddddd9dddddddddd3333333bccffffc344444444333666333333333333333333333333334fffff4f44443333464444444444444446444445
0ff1f1400ff1f140dd999d9ddddddddd333333b3ccf1f1c34244442433666663333333333333333333333333ffffffff333444444444d444444444445444d444
00ffff0000ffff00dd9dd9dddddddddd33bb33b3ccffff3c2424242436666663333332223333333322223333ff4fffff333333334664d4d4444544d45464d4d4
066dd66000665600dd4444dddd4444dd333bb33333eeee334444444436666653332222422222222224222233ffffffff33333b33446444444444444454644445
0d5775df00d57d00d444444dd444444d3333b3333355a5333332233335555533322444444444444444444223ffffffff333344444444444444d4444444444445
f011110000f11f00d222222dd222222d333333333eeeeee33334433333333333224444444444444444444422f44fff4f444443b4554455454444444454444645
0050050000065000dddddddddddddddd33333333336336333333333333333333244444444444444444444442ffffffffb333333333333333444444d454446444
cccccccccccccccc3333333333333333000700001553333133333333333555333333333333333333333333333331133333333333355555531444444133355333
cc0cccccccc7cccc333333333333333300070000550d33333333663333566633333333333333333333333333331bb133333333335949949514444441335ff533
c0a0000cccc7cccc333333333333333300070000900d33333333663331d6665333333333333333333333333331bb3b1333333333594994955222222535ffff53
0a0aaaa0ccc7cccc33333a333333333300070000905d33333333553331d6661333333555333333335555333331bb3b13335553335949949552222225314ff413
c0a000a0ccc7cccc3aaaa3a33333333301070100555d333333333333155d66d1335555d5555555555d55553331b33b1335fff5331ffffff11ffffff131444413
cc0ccc0ccc181ccc3a333a33333333330018100095d33333366333331555ddd1355dddd5dddddddd5dddd5531bbb33b13124413314daad4114daad4133144133
ccccccccccc1cccc3333333333333333000100009d333333366633331555555155ddddd5dddddddd5ddddd551bbbbbb13122441314d44d4114d44d4133144133
ccccccccccc1cccc3333333333333333000000005333333335553333333333335dddddd5dddddddd5dddddd53314413333333333333333333333333333333333
04444400004444001444444114400001155555515555555515533331555555551111111100000000111111113333333333333333333333333333333300000000
0444444004444440440505044452000055d5d5d535353555550d3333575557551111111100000000111111113373333333333c33373337333033303300000000
044444400f1f4144940505049552000055d5d5d533353535900d333307050705111111110000000011111111379733333333c9c3070307030503050300000000
0044440000ffff4094444444954200005555555533333333905d333350555055111115550000000055551111337b3b3333b3bc33303330333033303300000000
066556600666566644444414444200005555555533333333555d333355555555115555d5000000005d5555113333b333333b3333333333333333333300000000
056dd65f005d7d509444446494200000555555553333333395d3333357555755155dddd5000000005dddd5513333bb733cbb3333373337333033303300000000
f011110000f111f0942424449200000055151555333333339d3333330705070555ddddd5000000005ddddd55333bb797c9cbbb33070307030503050300000000
00500500000605004224242440000000511515153333333353333333505550555dddddd5000000005dddddd5333333733c333333303330333033303300000000
332222233bbbbb335555555556555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3222ff33bbfffbb355dd555555556555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3ff5f5333f1f1ff3dd55d5d565555566000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33ffff333fffff335555dddd55556556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33cc7c333bb5bb335555555555555655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33cbbc33f3bab3f35d5d555556555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33f55f3333bbb333ddd5dddd56556565000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33365333344344335555555565555565000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10101010101010101010101010101010d3d3d3d3d3d3d3d3d3d310e3e3e3e3e3e3e3e3e3e3e31010101010101010101010101010101010101010101010101010
10101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b190b1b19090b190b190b1b11010b1b1b110b110d3d3d3d3d3d3e3e3e3e3e3e3e3e3e3e3e3e31010101010101010101010101010101010101010101010101010
10101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b19090909090909090901010101010101010b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1e3e3b10000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b1b1b1b190b1b190b190b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b10000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b10000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b10000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b10000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b10000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b10000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b10000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b10000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b10000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b10000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b10000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b10000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b10000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b10000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b10000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b10000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b250b1b162b1b1b1b1b16240b1b1b1b10000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b25050b1b1b1b1b1b1b1b1b1b1b1b1b10000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
24000000000000000000000000000000000000000000e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e10000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
24000000000000000000000000000000000000000000d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d10000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
24000000000000000000000000000000000000000000b2505010101010101010101010c1c1c10000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000b250107110101010c1c1c1c1c1c1c1c10000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000050c2101010101010c1c1c1c1c1c1c1c10000000000000000000000000000000000000000000000000000
__gff__
0000000000010101000001000001010001010200000101000101010000000000000002000000000101000101010900010101050005000000010001000008100001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0505050c0c34340c0c0505050505050505050a0a0a0a0a050505050606010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050101010101010101050505050203010a0912090a010105050606060101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505160101010101011501010505050203010a0909090a010101050606060101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0501010101010101010101010505050101010a0909090a140105030606060101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0501010101010101010101010505010101010e0a0b0a0d040101010606060101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0501010101010101010101010101010101010101010101010107070606060101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050101010101010101010101010101010101010101070706060606060101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050101010128012a01270707010101010101010107060606060606010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050505270101010c340c07070606070707070707070706060606060601010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0507070707070707080706060606060606060606060606060606010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0706060606060638083a03050505050501010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
060606060606060c080c05050505050501010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0606010101010101010101050514050501010101010101010101010101010401010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0517010403010101010101010104050501010101040101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05050101040104010101010401012b2b05010126040414010126040101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505010101010201010101014001142b05050101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505020301010401010101140101011e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e01010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050505013c010101010118191a01011d1d1d1d1d1d0f0f1d1d1d1d1d1d1d1d01010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05050505170101012f2c08080802042b05051414141f1f01010104041c1c1c01010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05050505050214012c2d08320804012b05011714011f1f1c2c1c1c3b3d1c1c01010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050505050505030101010101010126052c010101011f1f1c1c1c1c1c1c1c1c01010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05050505050505010505020414030505010101010101011c1c1c1c1c1c1c1c01010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050501050505050505050501010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050501050505050505050501010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050501050505050505050501010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505052b012b0505050505050501010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505052b012b0505050505050501010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05052b2b2b2b2b012b2b2b2b2b05050501010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505262c0101010101273b3d3d01050501010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
052c040101011404010101013d01050501010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05173b01012829292a013c013d01010501010101010101013d3d3e3e01010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05050505050c01010c05050505050505013d3d010101013d3d3d3e3e3e3e3e3e3e3e3e3e3e3e010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000b03000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002205022050220502305000000240502405024050240503005032050330503005030050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00000b6201d620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001b0501e0501f050220501d050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002f0502c05028050250502305022050200501f0501d0501c0501b0501a0501905000000170501605014050130500000012050100500f0500e0500d0500c0500c0500c050240502b0502e0503005031050
010e000003353103531a35300000102531035310353103530c3530c35300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001165013650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000