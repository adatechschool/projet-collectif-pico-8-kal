pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
local sword = {
    active = false,
    sprite = 80,
    duration = 0.15,
    length = 16,
    hitboxsize = 8
}

local inventory = {
    visible = false,
    menuy = 64,
    menuheight = 60
}

function _init()
    create_player()
    init_msg()
    init_camera()
    state = 0 
end

function _update()
    if state == 0 then
       
        if #messages == 0 then
            player_movement()
            update_sword()
            inventory.update()
            update_camera()
            update_msg()
            p.x, p.y = go_inside(11, 19, 125, 4, "haut", "bas")
            p.x, p.y = go_inside(3, 42, 124, 63, "haut", "bas")
        end
    elseif state == 1 then
        update_gameover()
    end
end

function _draw()
    cls()
    draw_map()
    draw_player()
    draw_sword()
    draw_ui()
    draw_msg()
    inventory.draw()

    if state == 1 then
        draw_gameover()
    end
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

function spikes(x, y)
    next_tile(x,y)
    if p.life > 1 then
        p.life -= 1
        sfx(1)
    else
        game_over() 
    end
end
--teleportation (je souffre,a l'aide !!!)
function go_inside(xa, ya, xb, yb, directionab, directionba)
 local newdestinationx, newdestinationy = p.x, p.y
 local roundedx = flr(p.x)
 local roundedy = flr(p.y)

 if roundedx == xa and roundedy == ya and not teleported then
   newdestinationx = xb
   newdestinationy = yb
   teleported = true
   sfx(3)
   if directionab == "haut" then
      newdestinationy = newdestinationy - 1
   elseif directionab == "bas" then
          newdestinationy = newdestinationy + 1
   elseif directionab == "gauche" then
          newdestinationx = newdestinationx - 1
   elseif directionab == "droite" then
          newdestinationx = newdestinationx + 1
   end
  elseif roundedx == xb and roundedy == yb and not teleported then
         newdestinationx = xa
         newdestinationy = ya
         teleported = true
         sfx(3)
    if directionba == "haut" then
      newdestinationy = newdestinationy - 1
    elseif directionba == "bas" then
          newdestinationy = newdestinationy + 1
    elseif directionba == "gauche" then
          newdestinationx = newdestinationx - 1
    elseif directionba == "droite" then
          newdestinationx = newdestinationx + 1
    end
   elseif (roundedx ~= xa or roundedy ~= ya) and (roundedx ~= xb or roundedy ~= yb) then
          teleported = false
   end

 return newdestinationx, newdestinationy
end
-->8
--player and sword

function create_player()
	p = {
		x = 6,
		y = 3,
		ox = 0,
		oy = 0,
		start_ox = 0,
		start_oy = 0,
		anim_t = 0,
		sprite = 16,
		speed = 1,
		keys = 0,
		life = 3,
	}
end
function player_take_damage()
    if not p.invincible then
        p.life = p.life - 1
        p.invincible = true
        if p.life <= 2 then
            game_over() 
        end
    end
end


function player_movement()
	newx = p.x
	newy = p.y
	if p.anim_t == 0 then
		newox = 0
		newoy = 0
		if(btn(⬅️)) then
			newx -= 1
			newox = 8
			p.flip = true
		elseif(btn(➡️)) then
			newx += 1
			newox = -8
			p.flip = false
		elseif(btn(⬇️)) then
			newy += 1
			newoy = -8
			p.flip = false
		elseif(btn(⬆️)) then
			newy -= 1
			newoy = 8
			p.flip = false
		end
	end

 
 if btnp(4) and not sword.active then
		sword.active = true
		sword.duration = 0.15
		sfx(7)
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
	p.anim_t = max(p.anim_t - 0.125, 0)
	p.ox = p.start_ox * p.anim_t
	p.oy = p.start_oy * p.anim_t

	if p.anim_t >= 0.5 then
		if btn(⬆️) then
			p.sprite = 48 
		elseif btn(⬇️) then
			p.sprite = 49 
		else
			p.sprite = 17
		end
	else
		if btn(⬆️) then
			p.sprite = 32 
		elseif btn(⬇️) then
			p.sprite = 33
		else
			p.sprite = 16
		end
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
	spikes(x,y)
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
	if y==24 and x==2 then	
			create_msg("man",
"hello\n",
		"to get to the temple",
		"one must follow",
"the berry trees"	)
		visited_dungeon=false
	end
	if x==3 and y==62 then
		create_msg("panneau","green forest temple")
	end
end


function draw_player()
	spr(p.sprite,
	p.x*8+p.ox,p.y*8+p.oy,
	1,1,p.flip)
	
--	spr(id,x,y,1,1,true)
end

function update_sword()
    if sword.active then
        sword.duration = sword.duration - 0.01
        if sword.duration <= 0 then
            sword.active = false
        end
    end
end

function draw_sword()
 if sword.active then
   local endx = p.x * 8 + p.ox
   local endy = p.y * 8 + p.oy

   if p.sprite == 32 then       
      endy = endy - 8
   elseif p.sprite == 33 then
         endy = endy + 8
   elseif p.sprite == 16 and not p.flip then
         endx = endx + 8
   elseif p.sprite == 16 and p.flip then
          endx = endx - 8
   end      
  local swordsprite = (p.sprite == 32 or p.sprite == 33) and 80 or 81
   if p.sprite == 33 then
    spr(swordsprite, endx, endy, 1, 1, false, true)
   else
   spr(swordsprite, endx, endy, 1, 1, p.flip, false)
   end
 end
end



-->8
--ui and inventory
function draw_ui()
    camera()
    palt(0, false)
    palt(12, true)
     draw_hearts(p.life)
    spr(37, 2)
    palt()
    print_outline("X" .. p.keys, 10, 2, 7)
   
end

function print_outline(text, x, y)
    print(text, x - 1, y, 0)
    print(text, x + 1, y, 0)
    print(text, x + 1, y, 0)
    print(text, x, y - 1, 0)
    print(text, x, y + 1, 0)
    print(text, x, y, 7)
end

function inventory.update()
    if btnp(❎) and btnp(🅾️) then -- bouton "v"
        inventory.visible = not inventory.visible
    end
    
end

function inventory.draw()
    if inventory.visible then
        -- couleur de fond du menu inventaire
        rectfill(0, inventory.menuy - inventory.menuheight / 2, 128, inventory.menuy + inventory.menuheight / 2, 0)

        -- bordure du menu inventaire
        rect(0, inventory.menuy - inventory.menuheight / 2, 128, inventory.menuy + inventory.menuheight / 2, 7)

       
        -- exemple : dessiner une icれひne de clれた
        spr(37, 10, inventory.menuy - 8, 1, 1)

        -- exemple : afficher le nombre de clれたs
        print("x" .. p.keys, 30, inventory.menuy - 6, 7)
    end
end

function draw_hearts(count)
    local heartsprite = 100  -- utilisez le sprite 67 pour les cわ⧗urs

    for i = 1, count do
        local x = i * 8
        local y = 8

        spr(heartsprite, x, y, 1, 1, false, false)
    end
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


-->8
--enemies logic
-->8
--goal complete and game over

function game_over()
    state = 1 
end
function update_gameover()
    if btnp(🅾️) then
        _init() 
    end
end

function draw_gameover()
    cls(0) 

   
    print("game over", 50, 40, 7)

  
  
    print("press 🅾️/c to try again", 20, 60, 7)
end

__gfx__
0000000033333333333333333333333333333333331bb13311111111444444444ffffff4dddddddd1111d11155555555566666651111d1111111d11144444444
000000003333333333a33333333338333333333331bbbb13111111114444444444444444dddddddd111111116666666655555555111111111111111144444444
00700700333333333a9a333333338a83333333331bbb8b1311111111cccccccc4ffffff4dddddddd1d1111d155555555566666651d1111d11d1111d144444444
000770003333333333a33a3333333833b33b33b31b8bb31311111111111111114ff44f44dddddddd1111111166666666566556551111111111111111444544d4
00077000333333333333aca333e333333b3b3b33313b331311111111111111114ffffff4dddddddd111d11115555555556666665111d1111111d111144444444
007007003333333333333a333e2e33333b333b333311113311111111111111114444ff44dddddddd111111116666666655556655111111133111111144d44444
00000000333333333333333333e33333333333333332233311111111111111114ffffff4ddddddddd11111d15555555556666665d1111133331111d144444444
000000003333333333333333333333333333333333144233111111111111111144444444dddddddd1111111166666666555555551111133333311111444444d4
0222220002222200dddddddddddddddd333333333cccccc39999999933333333333333333333333333333333ffffffff3343bb34444444445455545544444445
0222ff200222ff20ddddd9dddddddddd3333333bccffffc344444444333666333333333333333333333333334fffff4f44443333464444444444444446444445
0ff1f1200ff1f120dd999d9ddddddddd333333b3ccf1f1c34244442433666663333333333333333333333333ffffffff333444444444d444444444445444d444
00ffff0000ffff00dd9dd9dddddddddd33bb33b3ccffff3c2424242436666663333332223333333322223333ff4fffff333333334664d4d4444544d45464d4d4
066dd66000665600dd4444dddd4444dd333bb33333eeee334444444436666653332222422222222224222233ffffffff33333b33446444444444444454644445
0d5775df00d57d00d444444dd444444d3333b3333355a5333332233335555533322444444444444444444223ffffffff333344444444444444d4444444444445
f011110000f11f00d222222dd222222d333333333eeeeee33334433333333333224444444444444444444422f44fff4f444443b4554455454444444454444645
0050050000065000dddddddddddddddd33333333336336333333333333333333244444444444444444444442ffffffffb333333333333333444444d454446444
02222200002222003333333333333333ddc7cdddcccccccc33333333333555333333333333333333333333333331133333333333355555531444444133355333
02222220002222203333333333333333dda7adddcc0ccccc3333663333566633333333333333333333333333331bb133333333335949949514444441335ff533
022222200f1f21223333333333333333dda7adddc0a0000c3333663331d6665333333333333333333333333331bb3b1333333333594994955222222535ffff53
0022220000ffff2033333a3333333333ddc7cddd0a0aaaa03333553331d6661333333555333333335555333331bb3b13335553335949949552222225314ff413
06655660066656663aaaa3a333333333ddc7cdddc0a000a033333333155d66d1335555d5555555555d55553331b33b1335fff5331ffffff11ffffff131444413
056dd650005d7d503a333a3333333333dd181dddcc0ccc0c366333331555ddd1355dddd5dddddddd5dddd5531bbb33b13124413314daad4114daad4133144133
0011110f00f111f03333333333333333ddd1ddddcccccccc366633331555555155ddddd5dddddddd5ddddd551bbbbbb13122441314d44d4114d44d4133144133
00600500000506003333333333333333ddd1ddddcccccccc35553333333333335dddddd5dddddddd5dddddd53314413333333333333333333333333333333333
02222200002222001444444114400001155555515555555515533331555555551111111100060000111111113333333333333333333333333333333300000000
0222222000222220440505044452000055d5d5d535353555550d3333575557551111111106050600111111113373333333333c33373337333033303300000000
022222200f1f2122940505049552000055d5d5d533353535900d333307050705111111115505055511111111379733333333c9c3070307030503050300000000
0022220000ffff2094444444954200005555555533333333905d333350555055111115550505050055551111337b3b3333b3bc33303330333033303300000000
066556600666566644444414444200005555555533333333555d333355555555115555d555d5d5555d5555113333b333333b3333333333333333333300000000
056dd650005d7d509444446494200000555555553333333395d3333357555755155dddd5050505005dddd5513333bb733cbb3333373337333033303300000000
f011110000f111f0942424449200000055151555333333339d3333330705070555ddddd5550505555ddddd55333bb797c9cbbb33070307030503050300000000
00500d00000605004224242440000000511515153333333353333333505550555dddddd555d5d5555dddddd5333333733c333333303330333033303300000000
33222223d22222dd5555555556555555000000000221022102110211000000000000000000000000000000000000000000000000000000000000000000000000
3222ff3322fff22d55dd555555556555052222500022000202220222000000000000000000000000000000000000000000000000000000000000000000000000
3ff5f533df1f1ffddd55d5d565555566022d22200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33ffff33dfffffdd5555dddd55556556022ddd202102210221021102000000000000000000000000000000000000000000000000000000000000000000000000
33cc7c33d88588dd555555555555565502ddd2202200220022022202000000000000000000000000000000000000000000000000000000000000000000000000
33cbbc33fd8a8dfd5d5d5555565555550222d2200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33f55f33dd888dddddd5dddd56556565052222500021002102110221000000000000000000000000000000000000000000000000000000000000000000000000
33365333d44d44dd5555555565555565000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000000000000221022102110211500550050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000000000000022000202220222500550050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000010000002102210221021102055000550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01070100187777772200220022022202055000550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00181000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000001000000021002102110221550055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333300000000500550050000000000000000ffff6fffffffffff000000000000000000000000000000000000000000000000000000000000000000000000
3333333300000000500550050000000008888880fff676fff11fffff000000000000000000000000000000000000000000000000000000000000000000000000
3333333300000000000000000000000008899990fff676fffdffffff000000000000000000000000000000000000000000000000000000000000000000000000
3333333300000000055000550000000008899880fff676ff4d66666f000000000000000000000000000000000000000000000000000000000000000000000000
3333333300000000055000550000000008899880fff676ff09777776000000000000000000000000000000000000000000000000000000000000000000000000
3333333300000000000000000000000009999880f1f676f14d66666f000000000000000000000000000000000000000000000000000000000000000000000000
3333333300000000550055000000000008888880f1dd9dd1fdffffff000000000000000000000000000000000000000000000000000000000000000000000000
3333333300000000000000000000000000000000fff404fff11fffff000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2b2101010101010b2b2b2b2b2b2b2b2b2b200000000000000000000001010101010101010107777000000000000000010101010101010101010101010101010
10101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2b21010101010101006101010101010b2b200000000000000700000000000100000000000000077000000000000000010101010101010101010101010101010
10101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2b20606060610101006060610060610b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2b21010100610100606060610060610b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2101010100606100606060610101010b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2101010101006100606061010101010b2b200000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2100606060650100610101010060610b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2101010101010101010101010061010b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2060606060610100606060606060610b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2061010100610101010100610100610b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2061006101010500606100606101010b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2060606060606060606101010061010b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2060606060606060606501010101010b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2060606060606060606060606101010b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2060606060606060606060606101010b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2060606060606060606060606101050b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2100606061010060606060606061006b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2101010101010060606060606101006b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2100606101010101006060610101010b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2100610100610101010101010101010b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2100610101006101010101010101010b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b21006500610060606060606101010b2b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2b2b2b20610b2b2b2b2b2b2b2b2b2b2b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b25050b21010b2b2b2b2b2b2b2b2b2b2b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2b2b250101050b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000262626262626262626262626000000
b2b2b250101050b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000026269090909090909090909090262626
b2b2b250101050b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000909090909090909090909090909090909045
b250b250101050b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090909090909090909090909090909045
8292a250101050b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090909090909090909090909090909045
c0b0c04110103020b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090909090909090909090909090909045
c036c06110402020b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000026909090909090909090909090909090909045
c02020412020b2b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000045454545454545454545454545454590454545
__gff__
0000000000010101000001000001010001010200000101000101010000000000010102000000000101000101010900010101050005000000010001000008100001000000010101000000000000000000000001010100000000000000000000000100000001000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3939390c0c34340c0c39393939390c0c0c0c0a0a0a0a0a0c0c0c050606010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000062000000090900090909090945090945454545
2f2f01040109090114012f0f0f0f2f0203010a0924090a010105050606060101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000053644164090909090945
052f1601041f1f0101150101013c010203010a0909090a010101050606060101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000053644464090909090945
05040104011f1f01010101010101010101010a0909090a140105030606060101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000053090909090909090945
05010301011f0f1e1e1e1e1e1e1e1e1e01010e0a0b0a0d040101010606060101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000045454545454545014545
052c2614011f0f0f0f0f0f0f0f0f0f0f01010909090909010107070606060101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101
0505053d3d1d1d1d1f1d1d1d1d1d1d1d01010109090901070706060606060101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05050501043d3d281f2a04270707010101010101010107060606060606010101010101434262625446460101464601010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050505270101220c340c07070606070707070707070706060606060601010101010101434262625446464464464601010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0507070707070707080706060606060606060606060606060606010101010101010101434262545446460101464601010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0706060606060638083a03050505050501010101010101010101010101010101010101434262545446464464464601010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
060606060606060c080c05050505050501010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0606010101010101010101050514050501010101010101010101010101010401010101010101010101016566010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0517010403010101010101010104050501010101040101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05050101040104010101010401012b2b05010126040414010126040101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505010101010201010101014001142b05050101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505020301010401010101140101011e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e01010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050505013c010101010101010101011d1d1d1d1d1d0f0f1d1d1d1d1d1d1d1d01010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2b2b2b18191a0101010101010102042b05051414141f1f01010104041c1c1c01010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2f2c0808081401010101010104012b05011714011f1f1c2c1c1c3b3d1c1c01010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2c2d083208030101010101010526052c010101011f1f1c1c1c1c1c1c1c1c01010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f2c0101010101010101020414050505010101010101011c1c1c1c1c1c1c1c01010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
052f010101010101010101010105050501010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
052f010101010101010101010105050501010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
052f400101010101010101010105050501010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505052b012b0101010105050501010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505052b012b0501010505050501010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05052b2b2b2b2b012b2b2b2b2b05050501010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505262c0101010101273b3d3d01050501010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
052c040101011404010101013d01050501010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05173b01012829292a013c013d01010501010101010101013d3d3e3e01010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
052b0505050c01010c050505050505052b3d3d010101013d3d3d3e3e3e3e3e3e3e3e3e3e3e3e010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000b03000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002400030050320503305030050300500000000000240003000032000330003000030000000000000022000220002200023000000002400024000240000000000000000000000000000000000000000000
000a00000b6201d620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001b0501e0501f050220501d050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002f0502c05028050250502305022050200501f0501d0501c0501b0501a0501905000000170501605014050130500000012050100500f0500e0500d0500c0500c0500c050240502b0502e0503005031050
000e000022050220502205023050000002405024050240500c3000c30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001165013650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000266401a630156200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
