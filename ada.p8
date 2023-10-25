pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
function _init()
create_player()

end
function _update()
player_movement()
update_camera()
end


function _draw()
cls()
draw_map()
draw_player()
  --  afficherquestion() 
end


-->8
--map--map and camera
function draw_map()
	map(0,0,0,0,128,64)
end

function check_flag(flag,x,y)
	local sprite=mget(x,y)
	return fget(sprite,flag)
end

function update_camera()
	local camx=flr(p.x/16)*16
	local camy=flr(p.y/16)*16
	camera(camx*8,camy*8)
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
		p.sprite=16
	else
		p.sprite=17
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
--question
-- initialisation de la salle et des rれたponses
local question = "quelle est la capitale de la france?"
local reponses = {
    "paris",
    "londres",
    "berlin",
    "madrid"
}
-- fonction d'affichage de la question et des rれたponses
function afficherquestion()
    cls() -- efface l'ecran
    print(question, 64, 30, 7) -- affiche la question au milieu de l'れたcran
    
    -- affiche les reponses autour de la question
    for i, reponse in ipairs(reponses) do
        print(reponse, 64, 50 + i * 10, 14)
    end
end

-- fonction de gestion des entrれたes du joueur
function _btnp(btn)
    if btn == 0 then
        -- action lorsque le joueur appuie sur le bouton gauche (rれたponse 1)
        -- mettez ici le code れき exれたcuter quand le joueur choisit la premiれそre rれたponse
    elseif btn == 1 then
        -- action lorsque le joueur appuie sur le bouton haut (rれたponse 2)
        -- mettez ici le code れき exれたcuter quand le joueur choisit la deuxiれそme rれたponse
    elseif btn == 2 then
        -- action lorsque le joueur appuie sur le bouton droite (rれたponse 3)
        -- mettez ici le code れき exれたcuter quand le joueur choisit la troisiれそme rれたponse
    elseif btn == 3 then
        -- action lorsque le joueur appuie sur le bouton bas (rれたponse 4)
        -- mettez ici le code れき exれたcuter quand le joueur choisit la quatriれそme rれたponse
    end
end


__gfx__
0000000088888888aaaaaaaa00055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000088888888aaaaaaaa00055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070088888888aaaaaaaa00055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700088888888aaaaaaaa00055000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700088888888aaaaaaaa00055000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070088888888aaaaaaaa00055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000088888888aaaaaaaa00055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000088888888aaaaaaaa00055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00333300003333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03f2f23003f2f2300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03ffff3003ffff300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
033cc330033cc3300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cccc0000cccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cccc0000cccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00400400000d40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
