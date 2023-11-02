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
 mob1={}
 mob2={}
    create_player()
    init_msg()
    init_camera()
    state = 0
    visited_dungeon = false
    create_mob1()
	create_mob2()
end

function _update()
    if state == 0 then
        if #messages == 0 then
            player_movement()
            update_sword()
            inventory.update()
      	
	--	update_mob1()
	--	update_mob2()
  kill_enemy()
  check_player_collision()
  check_enemy_collision()
            check_teleporters()
            check_gameover()
        end
 if p.x == 88 and p.y == 2 then
     state = 2  
 end
        
        update_msg()
        update_camera()
    elseif state == 1 then
        update_gameover()
    elseif state == 2 then
        update_victory()
    end
end
function _drawgame()
	if (state==0) draw_game()
	if (state==1) draw_over()
	if (state==2) draw_win()
end


function _draw()
    cls()
    draw_map()
  
	draw_mob1()
--	draw_mob2()

    draw_player()
    draw_sword()
    draw_ui()
    draw_msg()
    
    inventory.draw()

    if state == 1 then
        draw_gameover()
    elseif state == 2 then
        draw_victory()
    end
end

-->8
-- map and teleporter
function draw_map()
    map(0, 0, 0, 0, 128, 64)
end


function check_flag(flag, x, y)
    local sprite = mget(x, y)
    return fget(sprite, flag)
end


function init_camera()
    camx, camy = 0, 0
end


function update_camera()
    sectionx = flr(p.x / 16) * 16
    sectiony = flr(p.y / 16) * 16
    
    destx = sectionx * 8
    desty = sectiony * 8
    
    diffx = destx - camx
    diffy = desty - camy
    
    diffx /= 4
    diffy /= 4
    
    camx += diffx
    camy += diffy
    
    camera(camx, camy)
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

function check_teleporters()
    local newx, newy = go_inside(4, 20, 125, 5, "haut", "bas")
    if newx ~= p.x or newy ~= p.y then
        p.x, p.y = newx, newy
        sfx(3)
    end

    newx, newy = go_inside(38, 2, 124, 63, "haut", "bas")
    if newx ~= p.x or newy ~= p.y then
        p.x, p.y = newx, newy
        sfx(3)
    end

    newx, newy = go_inside(39, 2, 125, 63, "haut", "bas")
    if newx ~= p.x or newy ~= p.y then
        p.x, p.y = newx, newy
        sfx(3)
    end
    newx, newy = go_inside(87, 53, 29, 55, "droite", "gauche")
    if newx ~= p.x or newy ~= p.y then
        p.x, p.y = newx, newy
        sfx(3)
    end
    newx, newy = go_inside(54, 55, 31, 45, "droite", "gauche")
    if newx ~= p.x or newy ~= p.y then
        p.x, p.y = newx, newy
        sfx(3)
    end
    
     newx, newy = go_inside(46,37, 68, 15, "haut", "")
    if newx ~= p.x or newy ~= p.y then
        p.x, p.y = newx, newy
        sfx(3)
    end
    
         newx, newy = go_inside(68,4, 87, 15, "haut", "bas")
    if newx ~= p.x or newy ~= p.y then
        p.x, p.y = newx, newy
        sfx(3)
    end   
end

-- fonction pour passer au prochain carreau de la carte
function next_tile(x, y)
    local sprite = mget(x, y)
    mset(x, y, sprite + 1)
end

-- fonctions pour les interactions avec les objets du jeu
function pick_up_key(x, y)
    next_tile(x, y)
    p.keys += 1
    sfx(1)
end

function open_door(x, y)
    next_tile(x, y)
    p.keys -= 1
    sfx(2)
end

function eat_food(x, y)
    next_tile(x, y)
    p.life += 1
    sfx(2)
end

function boots_get(x, y)
    next_tile(x, y)
    p.boots = true
    sfx(2)
end

function spikes(x, y)
    next_tile(x, y)
    if p.life > 1 then
        p.life -= 1
        sfx(7)
    else
        game_over()
    end
end

function enemy_hurts(x, y)
    if p.life > 1 then
        p.life -= 1
        sfx(7)
    else
        game_over()
    end
end

function break_wall(x, y)
    next_tile(x, y)
    sfx(2)
end


-->8
-- plaer sword and txt
function create_player()
    p = {
        x =6, --6,124
        y =3, --3,62
        ox = 0,
        oy = 0,
        start_ox = 0,
        start_oy = 0,
        anim_t = 0,
        sprite = 16,
        speed =1,
        keys = 0,
        life = 3,
        evil_sprout=0,
        evil_sprout2=0,
        invincible_timer = 0,
        boots = false,
    }


end


-- fonction pour gれたrer le mouvement du joueur
function player_movement()
	local newx = p.x
	local newy = p.y
	local newox = 0
	local newoy = 0

	if p.anim_t == 0 then
		if btn(⬅️) then
			newx -= 1
			newox = 8
			p.flip = true
		elseif btn(➡️) then
			newx += 1
			newox = -8
			p.flip = false
		elseif btn(⬇️) then
			newy += 1
			newoy = -8
			p.flip = false
		elseif btn(⬆️) then
			newy -= 1
			newoy = 8
			p.flip = false
		end

		if p.boots then
			-- si les chaussures ont れたtれた collectれたes, le joueur peut se dれたplacer plus rapidement
			newx += btn(⬅️) and btn(❎) and -2 or 0
			newx += btn(➡️)and btn(❎) and 2 or 0
			newy += btn(⬆️)and btn(❎) and -2 or 0
			newy += btn(⬇️)and btn(❎) and 2 or 0
		end
	end
	if btnp(4) and not sword.active then
		sword.active = true
		sword.duration = 0.15
		sfx(8)
	end

	interact(newx, newy)

	if not check_flag(0, newx, newy) and (p.x != newx or p.y != newy) then
		p.x = mid(0, newx, 127)
		p.y = mid(0, newy, 63)
		p.start_ox = newox
		p.start_oy = newoy
		p.anim_t = 1
	end

	-- animation
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


if sword.active and mget(x + swordoffsetx, y + swordoffsety) == 85 then
    p.evil_sprout = p.evil_sprout + 1 -- incrれたmente p.evil_sprout de 1
    sfx(11) -- jouez le son correspondant
end

-- fonction pour gれたrer les interactions avec l'environnement
function interact(x, y)
	if check_flag(1, x, y) then
		pick_up_key(x, y)
	elseif check_flag(2, x, y) and p.keys > 0 then
		open_door(x, y)
	end

	if check_flag(3, x, y) then
		pick_up_key(x, y)
	end

	if check_flag(4, x, y) then
		spikes(x, y)
	end

	if check_flag(5, x, y) then
		eat_food(x, y)
	end

	if check_flag(6, x, y) then
		boots_get(x, y)
		boots()
	end

  if check_flag(7, x, y) and sword.active then
        break_wall(x, y)
        sfx(11)
    end
  if check_flag(4, p.x, p.y) and (collision(p, m1) or collision(p, m2)) then
     enemy_hurt(x,y)
        
    end
 
    local swordoffsetx = 0
    local swordoffsety = 0

    if p.sprite == 32 then
        swordoffsety = -1
    elseif p.sprite == 33 then
        swordoffsety = 1
    elseif p.sprite == 16 and not p.flip then
        swordoffsetx = 1
    elseif p.sprite == 16 and p.flip then
        swordoffsetx = -1
    end

    -- vれたrification si le joueur frappe le sprite 85 (evil_sprout)
    if sword.active and mget(x + swordoffsetx, y + swordoffsety) == 85 then
        p.evil_sprout = p.evil_sprout + 1 -- incrれたmentation de evil_sprout
        sfx(12) -- jouer le son correspondant

        -- effacer le sprite du tile (85) en le remplaれせant par un tile vide (86)
        mset(x + swordoffsetx, y + swordoffsety, 86)

        -- si evil_sprout atteint 10, remplacer un autre sprite れき des coordonnれたes spれたcifiques (x, y)
        if p.evil_sprout >= 10 then
            local xpositiontoreplace = 51
            local ypositiontoreplace = 55
            mset(xpositiontoreplace, ypositiontoreplace, 88) -- remplacer le sprite れき ces coordonnれたes par un autre sprite
        end
    end

    -- vれたrification si le joueur frappe le sprite 87 (evil_sprout2)
    if sword.active and mget(x + swordoffsetx, y + swordoffsety) == 87 then
        p.evil_sprout2 = p.evil_sprout2 + 1 -- incrれたmentation de evil_sprout2

        -- effacer le sprite du tile (87) en le remplaれせant par un tile vide (86)
        mset(x + swordoffsetx, y + swordoffsety, 86)

        -- si evil_sprout2 atteint 10, remplacer un autre sprite れき des coordonnれたes spれたcifiques (x, y)
        if p.evil_sprout2 >= 13 then
            local xpositiontoreplace = 46
            local ypositiontoreplace = 37
            mset(xpositiontoreplace, ypositiontoreplace,9) -- remplacer le sprite れき ces coordonnれたes par un autre sprite
            sfx(11)
        end
  
end
	-- messages
	if x == 2 and y == 2 then
		create_msg("panneau", "bienvenue!")
	end

	if x == 9 and y == 2 then
		create_msg("alyssa", "hello\n", "welcome to piko kingdom", "smallest one there is")
	end

	if y == 24 and x == 2 then
		create_msg("man", "hello\n", "to get to the temple", "one must follow", "the berry trees")
		visited_dungeon = false
	end

	if x == 3 and y == 62 then
		create_msg("panneau", "green forest temple")
	end

	if x == 115 and y == 4 then
		create_msg("worker", "have some food", "eat up!")
		if p.life <= 4 then
			p.life += 1
		else
			create_msg("worker", "you had too much", "come back when hungry!")
		end
	end
end

-- fonction pour dessiner le joueur
function draw_player()
	spr(p.sprite, p.x * 8 + p.ox, p.y * 8 + p.oy, 1, 1, p.flip)
end

-- fonction pour mettre れき jour l'れたpれたe
function update_sword()
	if sword.active then
		sword.duration = sword.duration - 0.01
		if sword.duration <= 0 then
			sword.active = false
		end
	end
end

-- fonction pour dessiner l'れたpれたe
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
function player_take_damage(damage)
    if not p.invincible then
        p.life = p.life - damage
        p.invincible = true
        p.invincible_timer = 120  -- le joueur est invincible pendant 2 secondes (60 fps)
        if p.life <= 0 then
            game_over()
        end
    end
end
-- fonction pour gれたrer les bottes et le mouvement du joueur
local countleft = 0
local countright = 0
local countup = 0

-- fonction pour gれたrer les bottes et le mouvement du joueur
local countleft = 0
local countright = 0
local countup = 0

function player_collected_shoes()
    -- remplacez cette condition par la logique appropriれたe pour dれたterminer si les chaussures ont れたtれた collectれたes par le joueur
    return p.boots
end
function boots()
    if player_collected_shoes() then
        p.boots = true
    end

    if btn(0) then
        countleft = countleft + 1
        if countleft == 2 and p.boots then
            -- dれたplacer le joueur rapidement vers la gauche
        else
            -- dれたplacer le joueur normalement vers la gauche
        end
        -- logique pour dれたplacer le joueur vers la gauche
    elseif btn(1) then
        countright = countright + 1
        if countright == 2 and p.boots then
            -- dれたplacer le joueur rapidement vers la droite
        else
            -- dれたplacer le joueur normalement vers la droite
        end
        -- logique pour dれたplacer le joueur vers la droite
    elseif btn(2) then
        countup = countup + 1
        if countup == 2 and p.boots then
            -- sauter rapidement
        else
            -- sauter normalement
        end
        -- logique pour faire sauter le joueur
    else
        -- rれたinitialiser les compteurs si aucune direction n'est pressれたe
        countleft = 0
        countright = 0
        countup = 0
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
    print_outline("X" .. p.evil_sprout, 50, 2, 7)  -- affiche le compteur evil_sprout dans l'ui
    
    -- affiche le sprite 85 (evil sprout) れき cれひtれた du compteur
   function draw_ui()
    camera()
    palt(0, false)
    palt(12, true)
    draw_hearts(p.life)
    spr(37, 2)
     local evilsproutx = 40  -- ajustez la coordonnれたe x selon votre prれたfれたrence
    local evilsprouty = 0 
     spr(99, evilsproutx-20, evilsprouty)
    palt()
    
    print_outline("X" .. p.keys, 10, 2, 7)
    print_outline("X" .. p.evil_sprout, 30, 2, 7)  -- affiche le compteur evil_sprout dans l'ui
    
      -- ajustez la coordonnれたe y selon votre prれたfれたrence

 
end
end

function print_outline(text, x, y, color)
    print(text, x - 1, y, 0)
    print(text, x + 1, y, 0)
    print(text, x + 1, y, 0)
    print(text, x, y - 1, 0)
    print(text, x, y + 1, 0)
    print(text, x, y, color)
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

        spr(37, 10, inventory.menuy - 8, 1, 1)

        
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


-- title screen
--if state = 2
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
--enemy logic

--enemy1

local mobcounter1=0

function add_mob1(m1x,m1y)
 m1={
  x=m1x,y=m1y,
  life=1,
  speed=30,
  sprite=127
 }
 add(mob1,m1)
end



function create_mob1()
	add_mob1(13, 24)
--	add_mob1(69,28)
--	add_mob1(79,27)
--	add_mob1(83,20)
-- add_mob1(75,15)
-- add_mob1(85,6)
-- add_mob1(75,13)
-- add_mob1(68,12)
-- add_mob1(79,6)
-- add_mob1(21,60)
-- add_mob1(23,60)
 
end


function draw_mob1()
 for m1 in all(mob1) do
		spr(m1.sprite,
		m1.x*8,
		m1.y*8)
	end
end

function update_mob1()
	mobcounter1+= 1
	local lerp = 1/m1.speed
	if mobcounter1 >= m1.speed then
		mobcounter1 = 0
		for m1 in all(mob1) do
			local newx=m1.x
			local newy=m1.y
			local direction = flr(rnd(4))
			if direction == 0 then
				newy-=1
			elseif direction == 1 then
				newy+=1
			elseif direction == 2 then
				newx-=1
			elseif direction == 3 then
				newx+=1
			end
	
			m1.x = mid(0, m1.x, 127)
			m1.y = mid(0, m1.y, 127)
			if not check_flag(0,newx,newy) then
				m1.x=mid(0,newx,127)
				m1.y=mid(0,newy,63)
			end
		end
	end
end

--mob2

local mobcounter2 = 0

function add_mob2(m2x,m2y)
 m2={
  x=m2x,y=m2y,
  life=1,
  speed=30,
  sprite=111
 }
 add(mob2,m2)
end



function create_mob2()
	add_mob2(10, 22)
--	add_mob2(77,10)
--	add_mob2(85,6)
-- add_mob2(80,2)
-- add_mob2(69,21)
-- add_mob2(76,20)
-- add_mob2(83,24)
-- add_mob2(71,25)
end


function draw_mob2()
 for m2 in all(mob2) do
		spr(m2.sprite,
		m2.x*8,
		m2.y*8)
	end
end

function update_mob2()
	mobcounter2 += 1
	local lerp = 1/m2.speed
	if mobcounter2 >= m2.speed then
		mobcounter2 = 0
		for m2 in all(mob2) do
			local newx=m2.x
			local newy=m2.y
			local direction = flr(rnd(4))
			if direction == 0 then
				newy-=1
			elseif direction == 1 then
				newy+=1
			elseif direction == 2 then
				newx-=1
			elseif direction == 3 then
				newx+=1
			end
	
			m2.x = mid(0, m2.x, 127)
			m2.y = mid(0, m2.y, 127)
			if not check_flag(0,newx,newy) then
				m2.x=mid(0,newx,127)
				m2.y=mid(0,newy,63)
			end
		end
	end
end

function kill_enemy()
	for m1 in all(mob1) do
		if sword.active and collision(m1, sword) then
			m1.life -= 1
			if m1.life <= 0 then
				del(mob1, m1)
			end
		end
	end

	for m2 in all(mob2) do
		if sword.active and collision(m2, sword) then
			m2.life -= 1
			sfx(2)
			if m2.life <= 0 then
				del(mob2, m2)
			end
		end
	end
end

function collision(entity, sword)
    local swordx = p.x * 8 + p.ox
    local swordy = p.y * 8 + p.oy

    if sword.active then
        if swordx < entity.x * 8 + 8 and
           swordx + sword.hitboxsize > entity.x * 8 and
           swordy < entity.y * 8 + 8 and
           swordy + sword.hitboxsize > entity.y * 8 then
            return true
        end
    end

    return false
end

function check_player_collision()
    for m1 in all(mob1) do
        if collision(p, m1) then
            player_take_damage(1)  -- rれたduire la vie du joueur
        end
    end

    for m2 in all(mob2) do
        if collision(p, m2) then
            player_take_damage(1)  -- rれたduire la vie du joueur
        end
    end
 -- vれたrifiez れたgalement la collision avec le sprite d'ennemi sur le drapeau 7
  
end
function check_enemy_collision()
    for m1 in all(mob1) do
        if sword.active and collision(m1, sword) then
            m1.life -= 1
            if m1.life <= 0 then
                sfx(12) 
            end
        end
    end

    for m2 in all(mob2) do
        if sword.active and collision(m2, sword) then
            m2.life -= 1
            
            if m2.life <= 0 then
                sfx(12)  
                del(mob2, m2)
            end
        end
    end
end




-->8
--goal complete and game over

function game_over()
    state = 1 
    sfx(9)
end

function update_gameover()
    if btn(🅾️) then
        _init()
    end
end

function draw_gameover()
    cls(0) 

  
    print("game over", 50, 40, 7)

   
    print("press 🅾️/c to try again", 20, 60, 7)
end
function check_gameover()
    for enemy in all(enemies) do
      
    end
end

-- you win condition
function update_victory()
    if btn(🅾️) then
        _init()  -- rれたinitialisez le jeu si le joueur appuie sur o
    end
end
function draw_victory()
    cls(0)

    -- texte 1
    local line1 = "bravo,                    "
    local x1 = (128 - #line1 * 4) // 2
    print(line1, x1, 30, 7)

    -- texte 2
    local line2 = "vous avez fini l'aventure !"
    local x2 = (128 - #line2 * 4) // 2
    print(line2, x2, 40, 7)

    -- texte 3
    local line3 = "avec la wonder seed,       \n"
    local x3 = (128 - #line3 * 4) // 2
    print(line3, x3, 50, 7)

    -- texte 4
    local line4 = "les plantes vont revivre !   "
    local x4 = (128 - #line4 * 4) // 2
    print(line4, x4, 60, 7)

    -- texte 5
    local line5 = "appuyez sur 🅾️ pour recommencer."
    local x5 = (128 - #line5 * 4) // 2
    print(line5, x5, 70, 7)
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
0222220002222200dddddddddddddddd333333333cccccc3999999993333333333333333333333333333333344444444dd4dbbd4444444445455545544444445
0222ff200222ff20ddddd9dddddddddd3333333bccffffc344444444333666333333333333333333333333334f7f6ff44444dddd464444444444444446444445
0ff1f1200ff1f120dd999d9ddddddddd333333b3ccf1f1c342444424336666633333333333333333333333334f4ff7f4ddd444444444d444444444445444d444
00ffff0000ffff00dd9dd9dddddddddd33bb33b3ccffff3c24242424366666633333322233333333222233334ffffff4dddddddd4664d4d4444544d45464d4d4
066dd66000665600dd4444dddd4444dd333bb33333eeee3344444444366666533322224222222222242222334ff46ff4dddddbdd446444444444444454644445
0d5775df00d57d00d444444dd444444d3333b3333355a53333322333355555333224444444444444444442234f7ff4f4dddd44444444444444d4444444444445
f011110000f11f00d222222dd222222d333333333eeeeee333344333333333332244444444444444444444224ffffff444444db4554455454444444454444645
0050050000065000dddddddddddddddd3333333333633633333333333333333324444444444444444444444244444444bddddddd33333333444444d454446444
02222200002222003333333333333333ddc7cdddcccccccc33333333333555333333333333333333333333333331133333333333355555531444444133355333
02222220002222203333333333333333dda7adddcc0ccccc3333663333566633333333333333333333333333331bb133333333335949949514444441335ff533
022222200f1f21223333333333333333dda7adddc0a0000c3333663331d6665333333333333333333333333331bb3b1333333333594994955222222535ffff53
0022220000ffff2033333a3333333333ddc7cddd0a0aaaa03333553331d6661333333555333333335555333331bb3b13335553335949949552222225314ff413
06655660066656663aaaa3a333333333ddc7cdddc0a000a033333333155d66d1335555d5555555555d55553331b33b1335fff5331ffffff11ffffff131444413
056dd650005d7d503a333a3333333333dd181dddcc0ccc0c366333331555ddd1355dddd5dddddddd5dddd5531bbb33b13124413314daad4114daad4133144133
0011110f00f111f03333333333333333ddd1ddddcccccccc366633331555555155ddddd5dddddddd5ddddd551bbbbbb13122441314d44d4114d44d4133144133
00600500000506003333333333333333ddd1ddddcccccccc35553333333333335dddddd5dddddddd5dddddd53314413333333333333333333333333333333333
022222000022220014444441144000011555555155555555155333315555555511111111000600001111111133333333333333333333333333333333dc777cdd
0222222000222220440505044452000055d5d5d535353555550d3333575557551111111106050600111111113373333333333c333733373330333033dc7476dd
022222200f1f2122940505049552000055d5d5d533353535900d333307050705111111115505055511111111379733333333c9c30703070305030503d64b4cdd
0022220000ffff2094444444954200005555555533333333905d333350555055111115550505050055551111337b3b3333b3bc333033303330333033d67476dd
066556600666566644444414444200005555555533333333555d333355555555115555d555d5d5555d5555113333b333333b33333333333333333333d5fff5dd
056dd650005d7d509444446494200000555555553333333395d3333357555755155dddd5050505005dddd5513333bb733cbb33333733373330333033d12441dd
f011110000f111f0942424449200000055151555333333339d3333330705070555ddddd5550505555ddddd55333bb797c9cbbb330703070305030503d122441d
00500d00000605004224242440000000511515153333333353333333505550555dddddd555d5d5555dddddd5333333733c3333333033303330333033dddddddd
33222223d22222dd55555555565555550000000002210221021102111116111100000000ddda2ddd2dd22ddd0000000055555555d44444dddd00000d00070000
3222ff3322fff22d55dd5555555565550522225000220002022202221615161100000000ddd222da2d2a2ddd0555575057676765d4f0f0ddddffff0d00070000
3ff5f533df1f1ffddd55d5d565555566022d222000000000000000005515155500000000dddd52d22d22dddd0565565056566665d4ffffdddd0f0f0d00070000
33ffff33dfffffdd5555dddd55556556022ddd2021022102210211021515151100000000ddddd2d22d5ddddd0755055056765665ddff0fddddffff0d00070000
33cc7c33d88588dd555555555555565502ddd220220022002202220255d5d55500000000ddd2ddaaaadd2ddd0555655056656765df5555fddf8888fd01070100
33cbbc33fd8a8dfd5d5d5555565555550222d22000000000000000001515151100000000d22a228aa822a22d0505575056767655dd5555dddd88880d00181000
33f55f33dd888dddddd5dddd565565650522225000210021021102215515155500000000dd2225aaaa2522dd0565555055667665dd1111dddd0000dd00010000
33365333d44d44dd555555556555556500000000000000000000000055d5d55500000000ddd2ddaaaadd2ddd0000000055555555dd1dd1dddd0dd0dd00000000
0006660000000000022102210211021150055005555333343333333366633331ddddddddddddd2d11d2dddddd5d95d5ddddddddddddddd00dddddddd1767a711
0005660000000000002200020222022250055005445333443555553311633311d55555dddddd52d11d2addddd59a5d5dddddddddddd55600dddd79991767a711
0005000000000000000000000000000000000000543335453552449361333616d553443dddd222d11d252dddd5d95d5ddddddddd67600500dddd7444dc69771d
00070000000000002102210221021102055000553433345335c4004331333163d534224dddda2dd11dd22dddd5d35d5d8888888867600500dddd799917c97c11
00070000447755562200220022022202055000553bbbbb44354004a332222211d542243dddddddd11dddddddd533535d8888888867600500dddd799917c77c11
00040000000000660000000000000000000000004b8b8b433394485312929213dd34435dddddddd11dddddddd5d35d5dddddddddddd55600dddd744417677711
0004000000000066002100210211022155005500535353533335555362020263ddd5555dddddddd11dddddddd5d35d5ddddddddddddddd00dddd7999176677d1
0000000000000000000000000000000000000000453233453333333312292216ddddddddddddddd11dddddddd5d35d5ddddddddddddddd00dddddddd17666711
333333339999999900000000555cccc4ccccccccd0055d05dddddddd1111111155555555ddddddd14dddddddd588585ddddddddddddddeddd949949d00000000
333333339999999900000000445ccc44c77cc77c5d05d005dddddddd1222226155755155ddddddd11ddcddddd582585dddddddddd2ddeaedd949949d00555550
33333333999999990000000054ccc545c787787c00606000dddddddd1212252155555555d8442dd11dd2ddddd588585d000000002a2ddeddd949949d05577750
333333339999999900000000c4ccc45cc788887c05606055dddddddd1226222115555565dddd4dd11d4d2cddd5d35d5ddd5005ddd2ddddddd777777d55785855
333333339999999900000000cbbbbb44c788887c055d0655dddddddd1222522155555555dd8422c11c2c8dd8d5335d5dddddddddddd3dddddddddddd55755725
3333333399999999000000004b8b8b4ccc7887cc006600d0dddddddd1252122155655755dddc34313482cd48d5d35d5ddddddddddd3a3ddddddddddd07121225
3333333399999999000000005353535cccc77cccdd005d00dddddddd1222262155555555ddd8c28213c8c8ccd5d3535dddddddddddd3dddddddddddd07915175
33333333999999990000000045323345cccccccc000dd000dddddddd1111111155555551ddc38c311342cc2cd5d35d5ddddddddddddddddddddddddd79915511
dddddd66dddddddddddddddddddddddddd1111dd0000000032230425ddd667dd1111111199999999999999994444444488888888dddddddddd33aa9d00000000
dddd66dddddddddddddd111dddddddddd112211d0000000032488322ddd55dddcc11111199794999997949994994979488888888ddddddddd73afaa90005000d
dddddd66ddddddddddd16441ddddddddd11221dd0000000004322406ddd667ddc1111111999999999999999949a9999488888888dddddbdd37fa2f2d0000ddd0
ddd4466dddddddddddd64441dddddddddd1111dd0000000080328303ddd55ddd1c111111995699999999999949999a9488888888bbddbbddd7dffffd5000ddd0
dd4464dddddddddddd644441ddddddddddd0dd0d0000000088038834ddd55ddd1c11111199559999999999994979497488888888dbddbdddd73373d650008d80
d444444dddddddddd7444441ddddddddddd0d00d0000000032202482ddd667dd1c111111999999999999999949a99a9488888888dbbdddddccc494350555ddd0
77777777dddddddd64444441ddddddddddd000dd0000000032028825ddd55ddd1c11111149999799499997994999499488888888ddbddddddf3333d5055ddd00
d777777ddddddddd65555551ddddddddddd00ddd0000000030430300ddd667dd1111111199999999999999994444444488888888dddddddddd4dd2dd00500d00
b2b2101010101010b2b2b2b2b2b2b2b2b2b21010dddddddd444d44440000000000000000000000000000000000000000000000000000000000000000000000b7
a7c7c7a7b7000000000000000000000000000000d7ddd7ddcdc5cdcc00000000000000c466666666666666666666c4c4c4c4c466c4c4c4c6c4c4c4c4c4c4c400
b2b21010101010101006101010101010b2b21010070d070d551515550000006464252525252564646464646464644545000000000000000000000000000000b7
b7a7c7b700000000000000000000000000000000d0ddd0dd1515151100000000000000c466c4c4c4c4c4c4c4666666666666c466c44766476647c40000000000
b2b20606060610101006060610060610b2b21010dddddddd55d5d555000000642525d3d3c1666425252525252564644500000000000000000000000000000000
b7a7c7b7b7b7b700000000000000000000000000d7ddd7dd1515151100000000000000c466c4c4c4c4c4c4c4c4c4c4c4c466c466c4664766d4e4c40000000000
b2b21010100610100606060610060610b2b21010070d070d551515550000006425c1d3d3c1666666c16666c166c1254545450000000000000000000000000000
b7a7c7c7c7c7b700000000000000000000000000d0ddd0dd55d5d55500000000000000c466666666666666c400000000c4666666664766476647c40000000000
b2101010100606100606060610101010b2b210100000000067777777000000642566c175c1c1c1c1c1c1c175c1c1255445450000000000000000000000000000
b7b7b7b7b7c7b700000000000000000000000000000000006677776700000000000000c466c4c4c4c4c466c4c4c4c400c4c4c4c4c4c4c4c437c4c40000000000
b2101010101006100606061010101010b2b2101000000000667777660000006425d366c1c1666675c1c1c1c1c1c1775959595900000000000000000000000000
0000000076b07600000000000000000000000000000000005677767500000000000000c466c459c4666666666666c40000003535353535354735353535353500
b2100606060650100610101010060610b2b210100000000066777566000000642566c1c1c16694a466c1c1c1c175255445450000000000000000000000000000
0000767676b07676760000000000000000000000000000006dd77dd600000000005900c466c459c466c4c4c4c466c40000006447664766476647664766476400
b2101010101010101010101010061010b2b2101000000000dd6666dd0000006425c1c17566c195a594a466c1c166252545450000000000000000000000000000
0000766060b0606076000000000000000000000000000000566dd66500000000595959c455c459c447c46647c466c40000006466476647665566476647666400
b2060606060610100606060606060610b2b21010d7a4a7dd55777755ddd667dd256666c194a496a695a5d36675c1662525450000000000000000000000000000
0000766060b060607600007676767676767676767676767656666665ddd55ddd595959c4c4c459c4c4c466c4c466c4c400006464644766476647664764646400
b2061010100610101010100610100610b2b21010dc747cdd5d6666d5ddd667dd6466c16695c1d3c196a694a4c175c16625450000000000000000000000000000
0000766060b060607600007607c16666c1c1c1557676767605dddd50ddd55ddd59005959595959c4666666c4666666c400000000646464666666646464000000
b2061006101010500606100606101010b2b21010d5fff5dd00000000ddd55ddd64c175c196a694a475c195a5d3c1666625250000000000000000000000000000
0000766060b06060760000766666c1c16666c1767676767600000000ddd667dd590059c4c4c459c466c4c4c46666c4c400000000000064645664640000000000
b2060606060606060606101010061010b2b21010d122441d00000000ddd55ddd54d366c1c1c195a5c17596a6c175c16666250000004545454545454545000000
0000766060b060607600007655c1c1c1c13737767676767600000000ddd667dd590059c466c459c466c4c4c46647c4c454646464646464646664646464646454
b2060606060606060606501010101010b2b21010000000001767a711000000645466c1d3c17596a690c1c1c1756666666625004545b6e7070707b5d745450000
0000766060b0606076000076c13737c166c13776000000001767a71100000000595959c466c4c4c466c4c4c46666c4c454666666666666666666666666666654
b2060606060606060606060606101010b2b2101000000000dc69771d0000c7c7c76666c1c1c1c1c1d3c1c1c1d3c1d3c12525004545d7070707070707d6450000
0000766060b06060760000760737c137373776760000000017c97c1100000000005959c466666666666666666666666656663535353535353535356464646654
b2060606060606060606060606101010b2b210100000000017c77c11000054546454545454545454545454545454545454250000450707070707074545450000
0000767676b07676760000007676767676377659595900001767771100000000000000c4c4c4c4c4c4c4c4c4c4c4c4c454666666666666666666666666666654
b2060606060606060606060606101050b2b2101000000000176677d100005454545454545454545454545454545454545400000045b607070707454545450000
00007770707070707700000076473766376637473759000017666711000000000000000000000000000000000000000035353535353535666635353535353535
b2100606061010060606060606061006b2b210100000000000000000000054546493939393939393939393939393935454000000004545004545000000000000
00007760601060607700000076376647473747374759000000000000000000000000000000000000000000000000000000000000000035666635000000000000
b2101010101010060606060606101006b2b210100000000000000000000000005460604772557247606060606061505454454545454500004545000000000000
00007676731073767600000076473766374737473759000000000000000000000000000000000000000000000000000045454545454545909045454545454545
b2100606101010101006060610101010b2b210100000000000000000000000005460607070707070606060201010105656000000000000004500000000000000
0000007673107376a0a0a0a0763747376637473747590000000000000000000000000000000000000000000000000000454590669090f79066f7909090909045
b2100610100610101010101010101010b2b210100000000000000000000000005460606060101060606060207070705454454545454545454500000000000000
00000076731073767676737376473747374737473759000000000000000000000000000000000000000000000000000045909066669090909090909090909045
b2100610101006101010101010101010b2b210100000000000000000000035355460606060271010106060201060605454545454545464640000000000000000
00000076731010731056565637449090904490909044767600000000000000000000000000000000000000000000000045909066669090909090909090909045
b21006500610060606060606101010b2b2b2101000000000000000000045353554d310606070707010d360702010616754545454545454640000000000000000
00000076737310101056565690909044909090449056909000000000000000000000000000000000000000000000000045664766909066666666909090909045
b2b2b2b20610b2b2b2b2b2b2b2b2b2b2b2b210100000000000000045454535359090106010106060101010607010c76767676767566464540000000000000000
00000076767676767676737376473747374737479076767600000000000000000000000000000000000000000000000045909066909090666666909090909045
b25050b21010b2b2b2b2b2b2b2b2b2b2b2b200000000000000000000909090909090106010106060d31070606010c7c7c7c7c767565600000000000000000000
0000000000000000a0a0a0a076374737473747479076000000000000000000000000000000000000000000000000000045909090909090909090909090909045
b2b2b250101050b2b200000000000000000000000000000000000045454535359027106070706060707060606010c76767676767566464540000000000000000
00000000000000000000000076473790909047909076000000000000000000000000000000000000000000000000000000454545454545565645454545909045
b2b2b250101050b2b2000000000000000000000000000000000000000045353554d3106060606060606060606006066754545454546454640000000000000000
000000000000000000000000763790904790909047760000000000000000000000000000000000000000454545454545454590909090c1909090909090454545
b2b2b250101050b2b200000000000000000000000000000000000000000000005470706060606060606060606070705454545454454545640000000000000000
00000000000000000000000076479090904747473776000000000000000000000000000000000000000045c1a0a0a0c14545909090c155c1909090c190909045
b250b250101050b2b200000000000000000000000000000000000000000000005460606060606060606060606060605454454545450000000000000000000000
0000000000000000000000007676767656767676767600000000000000000000000000000000000000004507a007a007454590909090c1909090c155c1909045
8292a250101050b2b200000000000000000000000000000000000000000000005474747474747474747474747474745454000000000000000000000000000000
0000000000000000000000007676767656767676767700000000000000000000000000000000000000004507e0b0d0c145459090909090c19090909090909045
c0b0c04110103020b200000000000000000000000000000000000000000000005460606060606060606060606060605454000000000000000000000000000000
000000000000000000000000760717101010605572607700000000000000000000000000000000000000450737073707454590909090c155c190909090909045
c036c06110402020b200000000000000000000000000000000000000000000005460606060606060606060606060605454000000000000000000000000000000
00000000000000000000000076071766d77060707060600000000000000000000000000000000000000045370737079045459027909090909090909090909045
c02020412020b2b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000076686868687474747477770000000000000000000000000000000000000045454545454545454545454545454545454590904545
__label__
00000000000000000000555000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000445000440000000000000000000000211021100000000000000000211021100000000000000000000000000000000000000000000000
0000a000000000777000540005450000007770000000000000222022200000000000000000222022200000000000000000000000000000000000000000000000
000a0aaaa07070707000040004500070707070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000a000a007007070000bbbbb440007007070000000000002102110200000000000000002102110200000000000000000000000000000000000000000000000
000000000007007070004b8b8b400007007070000000000002202220200000000000000002202220200000000000000000000000000000000000000000000000
00000000007070777000535353500070707770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000453233450000000000000000000000211022100000000000000000211022100000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050055005770577057705770577057705500550055005500550055005dddddddddddddddd5005500550055005500550055005500550055005500550055005500
050055005787787057877870578778705500550055005500550055005dddddddddddddddd5005500550055005500550055005500550055005500550055005500
000000000788887007888870078888700000000000000000000000000dddddddddddddddd0000000000000000000000000000000000000000000000000000000
005500055788887557888875578888755055000550550005505500055dddddddddddddddd0550005505500055055000550550005505500055055000550550005
005500055078870550788705507887055055000550550005505500055dddddddddddddddd0550005505500055055000550550005505500055055000550550005
000000000007700000077000000770000000000000000000000000000dddddddddddddddd0000000000000000000000000000000000000000000000000000000
055005500550055005500550055005500550055005500550055005500dddddddddddddddd5500550055005500550055005500550055005500550055005500550
000000000000000000000000000000000000000000000000000000000dddddddddddddddd0000000000000000000000000000000000000000000000000000000
05005500550055005dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd5005500
05005500550055005dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd5005500
00000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000
00550005505500055dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0550005
00550005505500055dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0550005
00000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000
05500550055005500dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd5500550
00000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000
550055005dddddddddddddddddddddddd55533334dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd55533334dddddddd5005500
550055005dddddddddddddddddddddddd44533344dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd44533344dddddddd5005500
000000000dddddddddddddddddddddddd54333545dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd54333545dddddddd0000000
505500055dddddddddddddddddddddddd34333453dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd34333453dddddddd0550005
505500055dddddddddddddddddddddddd3bbbbb44dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd3bbbbb44dddddddd0550005
000000000dddddddddddddddddddddddd4b8b8b43dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd4b8b8b43dddddddd0000000
055005500dddddddddddddddddddddddd53535353dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd53535353dddddddd5500550
000000000dddddddddddddddddddddddd45323345dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd45323345dddddddd0000000
550055005dddddddd55533334dddddddddddddddddddddddddddddddd55533334dddddddddddddddd55533334dddddddddddddddddddddddddddddddd5005500
550055005dddddddd44533344dddddddddddddddddddddddddddddddd44533344dddddddddddddddd44533344dddddddddddddddddddddddddddddddd5005500
000000000dddddddd54333545dddddddddddddddddddddddddddddddd54333545dddddddddddddddd54333545dddddddddddddddddddddddddddddddd0000000
505500055dddddddd34333453dddddddddddddddddddddddddddddddd34333453dddddddddddddddd34333453dddddddddddddddddddddddddddddddd0550005
505500055dddddddd3bbbbb44dddddddddddddddddddddddddddddddd3bbbbb44dddddddddddddddd3bbbbb44dddddddddddddddddddddddddddddddd0550005
000000000dddddddd4b8b8b43dddddddddddddddddddddddddddddddd4b8b8b43dddddddddddddddd4b8b8b43dddddddddddddddddddddddddddddddd0000000
055005500dddddddd53535353dddddddddddddddddddddddddddddddd53535353dddddddddddddddd53535353dddddddddddddddddddddddddddddddd5500550
000000000dddddddd45323345dddddddddddddddddddddddddddddddd45323345dddddddddddddddd45323345dddddddddddddddddddddddddddddddd0000000
0d0055d05dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd5005500
05d05d005dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd5005500
000606000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000
005606055dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0550005
0055d0655dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0550005
0006600d0dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000
0dd005d00dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd5500550
0000dd000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000
550055005dddddddd55533334dddddddddddddddddddddddd55533334dddddddddddddddddddddddddddddddddddddddd55533334dddddddddddddddd5005500
550055005dddddddd44533344dddddddddddddddddddddddd44533344dddddddddddddddddddddddddddddddddddddddd44533344dddddddddddddddd5005500
000000000dddddddd54333545dddddddddddddddddddddddd54333545dddddddddddddddddddddddddddddddddddddddd54333545dddddddddddddddd0000000
505500055dddddddd34333453dddddddddddddddddddddddd34333453dddddddddddddddddddddddddddddddddddddddd34333453dddddddddddddddd0550005
505500055dddddddd3bbbbb44dddddddddddddddddddddddd3bbbbb44dddddddddddddddddddddddddddddddddddddddd3bbbbb44dddddddddddddddd0550005
000000000dddddddd4b8b8b43dddddddddddddddddddddddd4b8b8b43dddddddddddddddddddddddddddddddddddddddd4b8b8b43dddddddddddddddd0000000
055005500dddddddd53535353dddddddddddddddddddddddd53535353dddddddddddddddddddddddddddddddddddddddd53535353dddddddddddddddd5500550
000000000dddddddd45323345dddddddddddddddddddddddd45323345dddddddddddddddddddddddddddddddddddddddd45323345dddddddddddddddd0000000
550055005dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd55533334dddddddddddddddddddddddddddddddddddddddd5005500
550055005dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd44533344dddddddddddddddddddddddddddddddddddddddd5005500
000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd54333545dddddddddddddddddddddddddddddddddddddddd0000000
505500055dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd34333453dddddddddddddddddddddddddddddddddddddddd0550005
505500055dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd3bbbbb44dddddddddddddddddddddddddddddddddddddddd0550005
000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd4b8b8b43dddddddddddddddddddddddddddddddddddddddd0000000
055005500dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd53535353dddddddddddddddddddddddddddddddddddddddd5500550
000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd45323345dddddddddddddddddddddddddddddddddddddddd0000000
000000000500550055005500550055005500550055005500550055005dddddddddddddddd50055005500550055005500550055005dddddddddddddddd5005500
000000000500550055005500550055005500550055005500550055005dddddddddddddddd50055005500550055005500550055005dddddddddddddddd5005500
000000000000000000000000000000000000000000000000000000000dddddddddddddddd00000000000000000000000000000000dddddddddddddddd0000000
000000000055000550550005505500055055000550550005505500055dddddddddddddddd05500055055000550550005505500055dddddddddddddddd0550005
000000000055000550550005505500055055000550550005505500055dddddddddddddddd05500055055000550550005505500055dddddddddddddddd0550005
000000000000000000000000000000000000000000000000000000000dddddddddddddddd00000000000000000000000000000000dddddddddddddddd0000000
000000000550055005500550055005500550055005500550055005500dddddddddddddddd55005500550055005500550055005500dddddddddddddddd5500550
000000000000000000000000000000000000000000000000000000000dddddddddddddddd00000000000000000000000000000000dddddddddddddddd0000000
55005500550055005dddddddddddddddddddddddddddddddddd4dbbd4dddddddddddddddddddddddddddddddddddddddddddddddd50055005500550055005500
55005500550055005dddddddddddddddddddddddddddddddd4444dddddddddddddddddddddddddddddddddddddddddddddddddddd50055005500550055005500
00000000000000000ddddddddddddddddddddddddddddddddddd44444dddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000
50550005505500055dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd05500055055000550550005
50550005505500055dddddddddddddddddddddddddddddddddddddbdddddddddddddddddddddddddddddddddddddddddddddddddd05500055055000550550005
00000000000000000dddddddddddddddddddddddddddddddddddd4444dddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000
05500550055005500dddddddddddddddddddddddddddddddd44444db4dddddddddddddddddddddddddddddddddddddddddddddddd55005500550055005500550
00000000000000000ddddddddddddddddddddddddddddddddbddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000
45005500550055005dddddddddddddddddddddddddd4dbbd455533334dd4dbbd4dddddddddddddddddddddddddd4dbbd4ddddddddddddddddcccccccc5005500
d5005500550055005dddddddddddddddddddddddd4444dddd445333444444dddddddddddddddddddddddddddd4444ddddddddddddddddddddccc8cccc5005500
40000000000000000ddddddddddddddddddddddddddd4444454333545ddd44444ddddddddddddddddddddddddddd44444ddddddddddddddddccc8cccc0000000
d0550005505500055dddddddddddddddddddddddddddddddd34333453ddddddddddddddddddddddddddddddddddddddddddddddddddddddddccc8cccc0550005
d0550005505500055dddddddddddddddddddddddddddddbdd3bbbbb44dddddbdddddddddddddddddddddddddddddddbddddddddddddddddddc888888c0550005
40000000000000000dddddddddddddddddddddddddddd44444b8b8b43dddd4444dddddddddddddddddddddddddddd4444ddddddddddddddddccc8cccc0000000
45500550055005500dddddddddddddddddddddddd44444db45353535344444db4dddddddddddddddddddddddd44444db4ddddddddddddddddccc8cccc5500550
d0000000000000000ddddddddddddddddddddddddbddddddd45323345bdddddddddddddddddddddddddddddddbdddddddddddddddddddddddccc8cccc0000000
d5005500550055005dddddddddddddddddddddddddddddddddd4dbbd4dddddddddddddddddddddddddd4dbbd455533334dd4dbbd4dddddddddddddddd5005500
d5005500550055005dddddddddddddddddddddddddddddddd4444dddddddddddddddddddddddddddd4444dddd445333444444dddddddddddddddddddd5005500
d0000000000000000ddddddddddddddddddddddddddddddddddd44444ddddddddddddddddddddddddddd4444454333545ddd44444dddddddddddddddd0000000
d0550005505500055dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd34333453dddddddddddddddddddddddd0550005
d0550005505500055dddddddddddddddddddddddddddddddddddddbdddddddddddddddddddddddddddddddbdd3bbbbb44dddddbdddddddddddddddddd0550005
d0000000000000000dddddddddddddddddddddddddddddddddddd4444dddddddddddddddddddddddddddd44444b8b8b43dddd4444dddddddddddddddd0000000
d5500550055005500dddddddddddddddddddddddddddddddd44444db4dddddddddddddddddddddddd44444db45353535344444db4dddddddddddddddd5500550
d0000000000000000ddddddddddddddddddddddddddddddddbdddddddddddddddddddddddddddddddbddddddd45323345bddddddddddddddddddddddd0000000
45005500550055005dddddddddddddddddddddddddddddddddddddddddd4dbbd4dddddddddddddddddddddddddddddddddddddddddddddddddddddddd5005500
d5005500550055005dddddddddddddddddddddddddddddddddddddddd4444dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd5005500
40000000000000000ddddddddddddddddddddddddddddddddddddddddddd44444dddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000
d0550005505500055dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0550005
d0550005505500055dddddddddddddddddddddddddddddddddddddddddddddbdddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0550005
40000000000000000dddddddddddddddddddddddddddddddddddddddddddd4444dddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000
45500550055005500dddddddddddddddddddddddddddddddddddddddd44444db4dddddddddddddddddddddddddddddddddddddddddddddddddddddddd5500550
d0000000000000000ddddddddddddddddddddddddddddddddddddddddbddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000
d5005500550055005dddddddddddddddddddddddddddddddddd4dbbd455533334dd4dbbd4dddddddddddddddddddddddddddddddddddddddddddddddd5005500
d5005500550055005dddddddddddddddddddddddddddddddd4444dddd445333444444dddddddddddddddddddddddddddddddddddddddddddddddddddd5005500
d0000000000000000ddddddddddddddddddddddddddddddddddd4444454333545ddd44444dddddddddddddddddddddddddddddddddddddddddddddddd0000000
d0550005505500055dddddddddddddddddddddddddddddddddddddddd34333453dddddddddddddddddddddddddddddddddddddddddddddddddddddddd0550005
d0550005505500055dddddddddddddddddddddddddddddddddddddbdd3bbbbb44dddddbdddddddddddddddddddddddddddddddddddddddddddddddddd0550005
d0000000000000000dddddddddddddddddddddddddddddddddddd44444b8b8b43dddd4444dddddddddddddddddddddddddddddddddddddddddddddddd0000000
d5500550055005500dddddddddddddddddddddddddddddddd44444db45353535344444db4dddddddddddddddddddddddddddddddddddddddddddddddd5500550
d0000000000000000ddddddddddddddddddddddddddddddddbddddddd45323345bddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000
d5005500550055005ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd22222dddddddddddddddddd5005500
d5005500550055005dddddddddddd111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd222ff2ddddddddddddddddd5005500
d0000000000000000ddddddddddd16441dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddff1f12ddddddddddddddddd0000000
d0550005505500055ddddddddddd64441ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddffffdddddddddddddddddd0550005
d0550005505500055dddddddddd644441ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd66dd66ddddddddddddddddd0550005
d0000000000000000ddddddddd7444441dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd5775dfdddddddddddddddd0000000
d5500550055005500dddddddd64444441ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddfd1111dddddddddddddddddd5500550
d0000000000000000dddddddd65555551dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd5dd5dddddddddddddddddd0000000
5500550055005500550055005500550055005500550055005500550055005500550055005500550055005500550055005dddddddddddddddd500550055005500
5500550055005500550055005500550055005500550055005500550055005500550055005500550055005500550055005dddddddddddddddd500550055005500
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dddddddddddddddd000000000000000
5055000550550005505500055055000550550005505500055055000550550005505500055055000550550005505500055dddddddddddddddd055000550550005
5055000550550005505500055055000550550005505500055055000550550005505500055055000550550005505500055dddddddddddddddd055000550550005
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dddddddddddddddd000000000000000
0550055005500550055005500550055005500550055005500550055005500550055005500550055005500550055005500dddddddddddddddd550055005500550

__gff__
0000000000010101000001000001010001010200000101000101010000000000010102000000000101000101010900010101050005000010010001000010000001010000010101000100000101000000000001010100000000000001000000000101000000810001010000010100001120004000110001010001010100000011
0000000000000000000000000000000000000000000100000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3939390c0c34340c0c39393939390c0c0c0c0a0a0a0a0a0c0c0c0506060a0a0a0a0a0c0c0c0c0c0c0c0c0c0c0a0a0a0d7777000000000000000000009595959595959595959595000000000095959595959595000000000000000000000000000000000000000000000000545400000000004545454545454545454545454545
2f2f01040109090114012f0f0f0f2f0203010a022d3c0a010105050606060a0a0a0a0c0c0c0c39390c0c0c0c0a0a0a707777000000000000000095959595959595959595959595959595959595959595952b2b2b2b0a0a0ab60a0a0a2b2b2b2b0000000000000000000000000000000000004545454545454545454545454545
052f1601041f1f0101150101013c010203010a2709270a010101050606060e0a0a0a0c0c0c0c09090c0c0c0c0a0a0d017777000000000000000095959595959595959595959595959595959595959595952b2b2b010a0a093f090a0a01052b2b0a0a0a0a00000000000000000000000000004545097009090909090909090945
05040104011f1f01010101010101010101010a3b09030a14010503060606010e0a0a0c0c0c0e09090d0c0c0c0a0d01017777000000000000000095959595959595959595969595959595959595959595952b2b2b010a02090909160a01012b2b0a0a0a0a00000000000000000000000000004571710909090909090909090945
05010301011f0f1e1e1e1e1e1e1e1e1e01010e0a0b0a0d0401010106060601010e0a0c0c0e010909010d0c0c0d0101017777000000000000000095950095959595959500a60095959595959595959595952b2b05010a3c030914030a3b042b2b0a0a0a0a00000000000000000000000000004541090909090909090909090945
052c2614011f0f0f0f0f0f0f0f0f0f0f01010909090909010107070606060101010101010101090901010101010101017777000000000000000000959595950000000000000000000000959595959595952b0505010e0a0a0b0a0a0d0114052b0a0a0a0a00000000000000000000000000004545454545454545454545014545
0505052f601d1d1d1f1d1d1d1d1d1d1d01010109090901070706060606060101010101010101090901010101010101017777000000000000000000959595950000000000000000000000959595959595952b05051401030a0b0a0301140105050a0a0a0a00000000000000000000000000000000000000004545450101010101
0505052f042f3d281f2a04270707010101010101010107060606060606010101010101010101090101010101010101017777000000000000000000959595950000000000000000000000959595959595950505140101010a0b0a0104010117050a0a0a0a00000000000000000000000000000000000000000000000000000000
050505272f2f220c340c07070606070707070707070706060606060601010101010101010101010901010101010101017777000000000000000000959595950000000000000000000000959595959595950505012604010a0b0a0101040105050a0a0a0a00000000000000000000000000000000000000000000000000000000
0507070707070707080706060606060606060606060606060606010101010101010101010101090101010101010101017777000000000000000000959595950000000000000000000000959595959595950505170114040e0b0d0114010105050a0a0a0a00000000000000000000000000000000000000000000000000000000
0706060606060638083a03050505050501010101010101010101010101010101010101010101010101010101010101017777000000000000000000959595959595959595009595959595959595959595952b05030203023b033c0302010405050a0a0a0a00000000000000000000000000000000000000000000000000000000
060606060606060c080c05050505050501010101010101010101010101010101010101010101090901010101010101017777000000000000000000959595959595959595009595959595959595959595952b05030303020302030202262b052b0a0a0a0a00000000000000000000000000000000000000000000000000000000
0606010101010101010101050514050501010101010101010101010101010401010101010101010101010101010101017777000000000000000000009595959595959595099595959595959595959595952b050501010101010101010505052b0a0a0a0a00000000000000000000000000000000000000000000000000000000
0517010403010101010101011604050501010101040101010101010101010101010101010101010101010101010101017777000000000000000000000095959595959553095395959595959595959595952b2b052c2f0909092f2c05052b2b2b0a0a0a0a00000000000000000000000000000000000000000000000000000000
05050101040104010101010401010505010101010101010101010101010101010101010101011f1f01010101010101017777000000000000000000000095959500955353095353959595959595959595950a0a0a0a0a0909090a0a0a0a0a0a0a0a0a0a0a00000000000000000000000000000000000000000000000000000000
05050101010102010101010101010505010101010101010101010101010101010101010101011f1f01010101010101017777000000000000000000000095959595535366666653539595959595959595950a0a0a0a0a0a0b0a0a0a0a0a0a0a0a0a0a0a0a00000000000000000000000000000000000000000000000000000000
05050203010104010101011401010505050101010101010101010101010101010101010101011f1f01010101010101017777000000000000000000000000009595545495959554549595959595959595950a0a0a0a0a0a0b0a0a0a0a0a0a0a0a0a0a0a0a00000000000000000000000000000000000000000000000000000000
050505013c0101010101010101010505050101010101010101010101010101010101010101011f1f01010101010101017777000000000000000000000000000095549595959595549595959595959595950000000000000000000000000000000a0a0a0000000000000000000000000000000000000000000000000000000000
2b2b2b18191a01010101010301020505050501010101010101010101010101010101010101011f1f010101010101010177770000000000000000000000000000959595959595959595959595959595009500000000000000000000000000000000000000004c4c4c4c4c4c4c4c4c000000000000000000000000000000000000
2f2f2c08080814010101010101010505053b01010101010101010101010101010101010101011f1f010101010101010177770000000000000000000000000000959595959595959595000000000000000000000000000000000000000000000000000000004c6666664c6666664c000000000000000000000000000000000000
2f2c2d0832080301010101010101052b2b053c012604041401012604010101010101010101011f1f01010101010101017777000000000000000000000000000000000000000000007b7b7b7b7b7b7b7b7b7b7b7b7b7b00004b4b3939394b4b4b4b000000004c664c664c664c664c4c4c4c4c4c4c4c0000000000000000000000
2f2c0101010101010101020414010505050505010101010101010101010101010101010101011f1f01010101010101017777000000000000000000000000000000000000000000007b7a7a7a7a7a7a7a7c7c7c7a7a7b00004b070655060707074b004c4c4c4c664c664c664c66666666666666664c0000000000000000000000
052f010101010101010101010101011e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1d1d1d1d1d1d0f0f01010101010101017777000000000000000000000000000000000000000000007b7a7a7a7a797c7c7c797c7a7a7b7b7b4b060607060606064b4b4c666666664c664c664c4c4c4c4c4c4c4c664c0000000000000000000000
052f010114010104010103010101011d1d1d1d1d1d1d0f0f1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d01010101010101017777000000000000000000000000000000000000000000007b7a7c7c7c7c7c797a7a7c7c7c7c7c7c650b0b0b0b0b0b0b090966664c4c4c4c6666664c0000000000004c664c0000000000000000000000
052f40012601010101010126140205050505051414141f1f01400104041c1c1c010101010101010101010101010101017777000000000000000000000000000000000000000000007b7a7c797a7a7a7a7a7a797a7a7b7b7b4b060606060606064b4b4c4c4c00004c4c4c4c4c0000000000004c664c0000000000000000000000
0505050505052b012b050505050505052b05011714011f1f1c2c1c1c3b3d1c1c010101010101010101010101010101017777000000000000000000000000000000000000000000007b7a7c7c7a7a7a7a7a7a7a7a7a7b00004b060606060606064b00000000000000000000000000000000004c664c0000000000000000000000
0505050505052b012b05050505050505052c010101011f1f1c1c1c1c1c1c1c1c010101010101010101010101010101017777000000000000000000000000000000000000000000007b7a797c7a7b7b7b7b7b7b7b7b7b00004b4b4b4b4b4b4b4b4b00000000000000000000000000000000004c664c4c4c4c4c4c4c4c4c4c4c00
05052b2b2b2b2b012b2b2b2b2b05050505010101010101011c1c1c1c1c1c1c1c010101010101010101010101010101017777000000000000000000000000007b7b7b7b7b7b7b7b7b7b7a7c7c7a7b0000000000000000000000000000000000000000000000000000000000004c4c4c0000004c664c6b5b6b5b6b5b6b5b6b4c00
0505262c0101010101273b3d3d01050501010101010101010101010101010101010101010101010101010101010101017777000000000000000000000000007b7a7c7c7c7c7c7c797c7c7c797a7b0000000000000000000000000000000000000000000000000000000000004c4c4c0000004c664c5b6b5b6b5b6b5b6b5b4c00
052c040101011404010101013d01050501010101010101010101010101010101010101010101010101010101010101017777000000000000000000000000007b7a7c7a797a797c7c7c7a7a7a7a7b0000000000000000000000000000000000000000000000000000000000004c744c0000004c664c6b5b6b5b6b5b6b5b6b4c00
05173b01012829292a013c013d010105012f2f2f2f2f2f2f3d3d3e3e01010101010101010101010101010101010101017777000000000000000000000000007b7a7c7a7a7b7b7b7b7b7b7b7b7b7b0000000000000000000000000000000000000000000000000000000000004c664c0000004c664c5b6b5b6b5b6b5b6b5b4c00
052b0505050c01010c050505050505052b2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f7777000000000000000000000000007b7a7c797a7b0000000000000000000000000000000000000000000000000000000000004c4c4c4c4c4c4c4c4c4c664c0000004c664c6b5b6b5b6b5b6b5b6b4c00
__sfx__
000100000b03000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002400030050320503305030050300500000000000240003000032000330003000030000000000000022000220002200023000000002400024000240000000000000000000000000000000000000000000
000a00000b6201d620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001b0501e0501f050220501d050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002f0502c05028050250502305022050200501f0501d0501c0501b0501a0501905000000170501605014050130500000012050100500f0500e0500d0500c0500c0500c050240502b0502e0503005031050
000e000022050220502205023050000002405024050240500c3000c30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001165013650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000084400e43005400100001e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002c62002500006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000000000384502c4501d450184501544012440104400d4400d4400c440092400724006240032400223000230154000640005400054001b0002b4001c0000000000000000000000000000000000000000000
001b00000d250182501a2501f250292502d250282502b2502f25025250282502c250302503425038250382502225014750117500f7400d7400c7500b7500a7500a750000003a7003270000000000000000000000
0010000004650096501a6502a650336502d6501765008650046500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000d65018650116101c6501e000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
