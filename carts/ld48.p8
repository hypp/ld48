pico-8 cartridge // http://www.pico-8.com
version 32
__lua__

-- Ludum Dare 48 - Deeper and Deeper
-- by Mathias Olsson


screen_width = 128
screen_height = 128

texture_width = 32
texture_height = 32

textures = {0,4,8,12}

spritesheet_address = 0x0
screen_address = 0x6000


-- intro states
state_init_intro=1
state_play_intro=2
state_end_intro=3
-- level states
state_init_level=4
state_play_level=5
state_end_level=6
-- end
state_init_game_over=7
state_play_game_over=8
state_end_game_over=9

current_state=state_init_intro

drawmode = 0
render_type = 1

level_start_size=4
level_size=level_start_size

wall_colors = { 7,9,13,14,15 }

palette = {
    {0,1, 2, 3, 4, 5, 6, 7,8,9,10,11,12,13,14,15},
    {0,1, 2, 3, 4, 5, 5, 5,3,4, 9, 3,13, 1, 3, 4}
}

skull = {
107,127,
105,122,
103,120,
102,116,
100,112,
100,109,
100,108,
100,103,
100,102,
102,98,
103,94,
107,90,
110,87,
113,80,
118,77,
120,75,
125,70,
125,66,
125,59,
125,55,
126,49,
126,44,
126,41,
126,38,
124,35,
123,32,
122,30,
121,27,
120,25,
118,21,
117,19,
114,16,
112,13,
106,10,
103,8,
98,7,
94,5,
91,3,
87,3,
85,2,
82,2,
77,2,
73,2,
70,3,
67,4,
61,4,
55,5,
51,7,
47,9,
43,9,
38,14,
35,16,
32,19,
30,23,
27,24,
23,28,
18,33,
16,37,
14,40,
14,45,
14,47,
15,49,
16,52,
16,54,
16,57,
14,59,
11,61,
9,64,
7,66,
4,70,
2,72,
1,74,
4,76,
5,77,
7,78,
8,79,
9,83,
9,87,
9,90,
9,90,
10,92,
10,92,
12,95,
12,98,
11,102,
10,107,
12,108,
15,109,
20,113,
24,113,
27,112,
32,112,
33,113,
35,114,
37,116,
39,119,
39,120,
41,123,
41,126
}



N=1
S=2
E=4
W=8
DX         = { [E] = 1, [W] = -1, [N] =  0, [S] = 0 }
DY         = { [E] = 0, [W] =  0, [N] = -1, [S] = 1 }
OPPOSITE   = { [E] = W, [W] =  E, [N] =  S, [S] = N }

function carve_passages_from(current_x,current_y,grid) 
    height = #grid
    width = #grid[0]

    directions = {N, S, W, E}
    -- shuffle
    for i=#directions,1,-1 do
        rnd_card=ceil(rnd(i))
        directions[i],directions[rnd_card]=directions[rnd_card],directions[i]
    end
    for direction in all(directions) do
        new_x = current_x + DX[direction]
        new_y = current_y + DY[direction]
        if new_y >= 0 and new_y <= height and new_x >= 0 and new_x <= width and grid[new_y][new_x] == 0 then
        -- valid
            grid[current_y][current_x] |= direction
            grid[new_y][new_x] |= OPPOSITE[direction]
            -- recurse
            carve_passages_from(new_x,new_y,grid)
        end
    end
end

function generate_maze()
    height = flr((level.height)/2)
    width = flr((level.width)/2)

    -- init maze
    maze = {}
    for y=0,height-1 do
        maze[y] = {}
        for x=0,width-1 do
            maze[y][x] = 0
        end
    end

    if level_size > 8 then
        -- add random rooms
        rooms = 1 + (level_size-8) >> 2
        for i=0,rooms do
            x = flr(rnd(width-2))+1
            y = flr(rnd(height-2))+1
            maze[y][x] = N | S | E | W
        end
    end

    carve_passages_from(0,0,maze)
end

function generate_level()
    generate_maze()

    -- clear map
    if level.height % 2 == 0 then
        level.height += 1
    end
    map_height = level.height
    if level.width % 2 == 0 then
        level.width += 1
    end
    map_width = level.width
    level.map = {}
    for i=1,map_height do
        level.map[i] = {}
        for j=1,map_width do
            color = 3
            if i == 1 or j == 1 or i == map_height or j == map_width then
                color = 1
            end
            -- random color but never 0
            color = rnd(wall_colors)
            level.map[i][j] = color
        end
    end

    -- convert maze to map
    map_y = 2
    maze_y = 0
    maze_x = 0

    for maze_y=0,#maze do
        map_x = 2
        for maze_x=0,#maze[0] do
            cell = maze[maze_y][maze_x]
            level.map[map_y][map_x] = 0
            if cell & N == N then
                level.map[map_y-1][map_x] = 0
            end
            if cell & S == S then
                level.map[map_y+1][map_x] = 0
            end
            if cell & W == W then
                level.map[map_y][map_x-1] = 0
            end
            if cell & E == E then
                level.map[map_y][map_x+1] = 0
            end

            map_x += 2
        end
        map_y += 2
    end
end

-- TODO make level map 0 indexed

function player_update()
  -- btn 0,1 left and right
  if btn(0) then
    player.angle += 0.01
  elseif btn(1) then
    player.angle -= 0.01
  end

-- calculate player direction
  player.direction_x = cos(player.angle)*1
  player.direction_y = sin(player.angle)*1

-- camera plane is perpendicular to player direction
  camera.plane_x = cos(player.angle+3/4)*0.66
  camera.plane_y = sin(player.angle+3/4)*0.66

  speed = 0
  if btn(2) then
    speed += 0.09
  end

  if btn(3) then
    speed -= 0.09
  end

  current_level_map = level.map

  new_x = player.x + player.direction_x * speed
  new_y = player.y + player.direction_y * speed
  map_x = flr(new_x)
  map_y = flr(new_y)
  if current_level_map[map_y][map_x] == 0 then
  -- allow it
    player.x = new_x
    player.y = new_y
  else
  -- blocked by wall
    if current_level_map[map_y][map_x] == 66 and btn(2) then
        -- found the syringe!! new level
        current_state = state_end_level
    end

  end

    player.animation_counter += player.animation_speed
    idx = 1+flr(player.animation_counter) % #player.animation
    player.current_animation_frame = player.animation[idx] 
end

function init_player()
    player={}
    player.x = 1.5
    player.y = 1.5
    player.angle = 0
    player.direction_x = 0
    player.direction_y = 0
    player.animation = {64,65,64,66}
    player.animation_speed = 0.1
    player.animation_counter = 0
    player.current_animation_frame = 0
    player.update = player_update

    -- put the player
    found = false
    for y=1,level.height do
        for x=1,level.width do
            if level.map[y][x] == 0 then
                -- check that it is visible from at least one direction
                if y != level.height then
                    if level.map[y+1][x] == 0 then
                        found = true
                        player.angle = 3/4
                    end
                end

                if y != 1 then
                    if level.map[y-1][x] == 0 then
                        found = true
                        player.angle = 1/4
                    end
                end

                if x != level.width then
                    if level.map[y][x+1] == 0 then
                        found = true
                        player.angle = 0
                    end
                end

                if x != 1 then
                    if level.map[y][x-1] == 0 then
                        found = true
                        player.angle = 2/4
                    end
                end

                if found then
                    player.x = x+0.5
                    player.y = y+0.5
                    break
                end
            end
        end -- for x
        if found then
            break
        end
    end -- for y

end

function init_camera()
    camera={}
    camera.plane_x = 0
    camera.plane_y = 0.66
end

function update_sphere()
  angle = -player.angle / 2
  sphere.rotated_points = {}
  for point in all(sphere.points) do

    x = point.x
    y = point.y
    z = point.z

    point = {}
    point.x = x * cos(angle) + z * sin(angle)
    point.y = y 
    point.z = -x * sin(angle) + z * cos(angle)

    point.x = point.x * 128 / (point.z + 128)
    point.y = point.y * 128 / (point.z + 128)

    add(sphere.rotated_points, point)
  end
end

function init_sphere()
    sphere = {}
    sphere.points = {}
    sphere.rotated_points = {}
    sphere.update = update_sphere

    while #sphere.points < 100 do
     angle_a = rnd()
     angle_b = rnd()
     length = 75

     point = {}
     point.x = length * sin(angle_a) * cos(angle_b)
     point.y = length * sin(angle_a) * sin(angle_b)
     point.z = length * cos(angle_a)

     if point.y <= 0 then
        add(sphere.points,point)
     end
    end
end

function init_syringe()

    syringe = {}
--    syringe.animation = {80,80,80,80,80,80,80,80,80,81,82,83,84,85,85,85,85,85,85,85,85}
    syringe.animation = {96,97,96,98}
    syringe.animation_speed = 0.2
    syringe.animation_counter = 0
    syringe.current_animation_frame = 0
    syringe.texture = rnd(textures)
    syringe.update = syringe_update

    -- put the syringe
    found = false
    for y=level.height,1,-1 do
        for x=level.width,1,-1 do
            if level.map[y][x] != 0 then
                -- check that it is visible from at least one direction
                if y != level.height then
                    if level.map[y+1][x] == 0 then
                        found = true
                    end
                end

                if y != 1 then
                    if level.map[y-1][x] == 0 then
                        found = true
                    end
                end

                if x != level.width then
                    if level.map[y][x+1] == 0 then
                        found = true
                    end
                end

                if x != 1 then
                    if level.map[y][x-1] == 0 then
                        found = true
                    end
                end

                -- if at least one direction is free
                if found then
                    level.map[y][x] = 66
                    break
                end
            end
        end -- for x
        if found then
            break
        end
    end -- for y

    syringe.x = x
    syringe.y = y

end

function syringe_update()
    syringe.animation_counter += syringe.animation_speed
    idx = 1+flr(syringe.animation_counter) % #syringe.animation
    syringe.current_animation_frame = syringe.animation[idx] 
end

function game_init()
    init_camera()
end

function level_update()
   player.update()
   sphere.update()
   syringe.update()

  if btnp(4) then
--    if render_type == 0 then
--        render_type = 1
--    else
--        render_type = 0
--    end

    -- cheat and go to next level
--    current_state = state_end_level

  end
 
  if btnp(5) then
    if drawmode == 0 then
        drawmode = 1
    else
        drawmode = 0
    end
  end

end

function level_draw()

    if drawmode == 1 then
        cls(0)
    end

    if drawmode == 0 then
        cls(0)
--        rectfill(0,0,screen_width,screen_height/2,0)
        rectfill(0,screen_height/2,screen_width,screen_height,6)

        for point in all(sphere.rotated_points) do
            if point.z > 0 then
                y = point.y + screen_height/2
            -- if y < screen_height/2 then
                    x = point.x + screen_width/2
                    flash = rnd()
                    if flash > 0.01 then
                        pset(x,y,15)
                    else
                        pset(x,y,1)
                    end
            -- end
            end
        end
    end

    current_level_map = level.map

    -- draw map
    map_height = #current_level_map
    map_width = #current_level_map[1]

    tile_width = screen_width/map_width
    tile_height = screen_height/map_height

    if drawmode == 1 then
        -- draw map
        y = 0
        for row in all(current_level_map) do
            x = 0
            for cell in all(row) do
                if cell == 66 then
                    sprite = syringe.current_animation_frame
                    spr(sprite,x+tile_width/2-4,y+tile_height/2-4)
                elseif cell > 0 then
                    rectfill(x,y,x+tile_width-1,y+tile_height-1,cell)
                end
                x += tile_width
            end

            y += tile_height
        end

        sprite = player.current_animation_frame
        spr(sprite,(player.x-1)*tile_width-4,(player.y-1)*tile_height-4)
    end

    current_screen_address = screen_address
    for x=0,screen_width-1 do
        camera_x = 2*x / screen_width - 1
        ray_direction_x = player.direction_x + camera.plane_x * camera_x
        ray_direction_y = player.direction_y + camera.plane_y * camera_x

--        if drawmode == 1 then
--        x_dir = ray_direction_x*25
--        y_dir = ray_direction_y*25
--            line((player.x-1)*tile_width,(player.y-1)*tile_height,(player.x-1)*tile_width+x_dir,(player.y-1)*tile_height+y_dir,7)
--        end

        map_x = flr(player.x)
        map_y = flr(player.y)

-- calculate step size
-- TODO simplyfi
        if ray_direction_y == 0 then
            delta_dist_x = 0
        else
            if ray_direction_x == 0 then
                delta_dist_x = 1
            else
                delta_dist_x = abs(1/ray_direction_x)
            end
        end

        if ray_direction_x == 0 then
            delta_dist_y = 0
        else
            if ray_direction_y == 0 then
                delta_dist_y = 1
            else
                delta_dist_y = abs(1/ray_direction_y)
            end
        end

        if ray_direction_x < 0 then
            step_x = -1
            side_dist_x = (player.x - map_x) * delta_dist_x
        else
            step_x = 1
            side_dist_x = (map_x + 1 - player.x) * delta_dist_x
        end

        if ray_direction_y < 0 then
            step_y = -1
            side_dist_y = (player.y - map_y) * delta_dist_y
        else
            step_y = 1
            side_dist_y = (map_y + 1 - player.y) * delta_dist_y
        end

        -- make sure we have walls surrounding the map
        -- or this will never end
        side = 0
        hit = false
        while not hit do
            if side_dist_x < side_dist_y then
                side_dist_x += delta_dist_x
                map_x += step_x
                side = 0
            else
                side_dist_y += delta_dist_y
                map_y += step_y
                side = 1
            end

            if current_level_map[map_y][map_x] > 0 then
                hit = 1
            end
        end

        if drawmode == 3 then
            line((player.x-1)*tile_width,(player.y-1)*tile_height,(map_x-1+0.5)*tile_width,(map_y-1+0.5)*tile_height,6)
        end

        if drawmode == 0 then

        -- calculate height of stripe
            if side == 0 then
                perpendicular_wall_distance = (map_x - player.x + (1 - step_x) / 2) / ray_direction_x
            else
                perpendicular_wall_distance = (map_y - player.y + (1 - step_y) / 2) / ray_direction_y
            end

    -- select palette based on distance and side
            palette_index = 1 + side
            current_palette = palette[palette_index]


            line_height = screen_height / perpendicular_wall_distance
            start_y = flr(-line_height/2 + screen_height/2)
            if start_y < 0 then
                start_y = 0
            end
            stop_y = flr(line_height/2 + screen_height/2)
            if stop_y >= screen_height then
                stop_y = screen_height-1
            end

            color = current_level_map[map_y][map_x]
            if color == 66 then
            -- texture map
                texture = syringe.texture*8
                if side == 0 then
                    wall_pos = player.y + perpendicular_wall_distance * ray_direction_y
                else
                    wall_pos = player.x + perpendicular_wall_distance * ray_direction_x
                end
                wall_pos -= flr(wall_pos)
                texture_x = wall_pos * texture_width
                if side == 0 and ray_direction_x < 0 then
                    texture_x = texture_width - texture_x  -- - 1
                end
                if side == 1 and ray_direction_y > 0 then
                    texture_x = texture_width - texture_x  -- - 1
                end

                -- select texture
                texture_x += texture

                texture_step = 1.0 * texture_height / line_height
                texture_pos = (start_y - screen_height/2 + line_height/2) * texture_step

                if render_type == 0 then
                    for y = start_y, stop_y do
                        texture_y = flr(texture_pos) & (texture_height-1)
                        texture_pos += texture_step
                        color = sget(texture_x,texture_y)
                        pset(x,y,color)
                    end
                else
                    if (flr(texture_x) % 2 == 0) and (x % 2 == 0) then
                    -- both are even
                        texture_address = spritesheet_address + flr(texture_x / 2)
                        stripe_address = current_screen_address + start_y*64
                        for y = start_y, stop_y do
                            texture_y = flr(texture_pos) & (texture_height-1)
                            texture_pos += texture_step
                            color = peek(texture_address+texture_y*64) & 0xf
                            tmp = peek(stripe_address) & 0xf0
                            tmp |= color
                            poke(stripe_address,tmp)
                            stripe_address+=64
                        end

                    elseif (flr(texture_x) % 2 == 1) and (x % 2 == 1) then
                    -- both are odd
                        texture_address = spritesheet_address + flr(texture_x / 2)
                        stripe_address = current_screen_address + start_y*64
                        for y = start_y, stop_y do
                            texture_y = flr(texture_pos) & (texture_height-1)
                            texture_pos += texture_step
                            color = peek(texture_address+texture_y*64) & 0xf0
                            tmp = peek(stripe_address) & 0xf
                            tmp |= color
                            poke(stripe_address,tmp)
                            stripe_address+=64
                        end

                    elseif (flr(texture_x) % 2 == 1) and (x % 2 == 0) then
                    -- texture is odd, dst is even
                        texture_address = spritesheet_address + flr(texture_x / 2)
                        stripe_address = current_screen_address + start_y*64
                        for y = start_y, stop_y do
                            texture_y = flr(texture_pos) & (texture_height-1)
                            texture_pos += texture_step
                            color = peek(texture_address+texture_y*64) & 0xf0
                            tmp = peek(stripe_address) & 0xf0
                            tmp |= (color >> 4)
                            poke(stripe_address,tmp)
                            stripe_address+=64
                        end

                    elseif (flr(texture_x) % 2 == 0) and (x % 2 == 1) then
                    -- texture is even, dst is odd
                        texture_address = spritesheet_address + flr(texture_x / 2)
                        stripe_address = current_screen_address + start_y*64
                        for y = start_y, stop_y do
                            texture_y = flr(texture_pos) & (texture_height-1)
                            texture_pos += texture_step
                            color = peek(texture_address+texture_y*64) & 0xf
                            tmp = peek(stripe_address) & 0xf
                            tmp |= (color << 4)
                            poke(stripe_address,tmp)
                            stripe_address+=64
                        end
                    else
                        fillrect(0,0,128,128,15)
                    end
                end
            else
                -- translate color
                color = current_palette[color+1]
                line(x,start_y,x,stop_y,color)
            end

            if x % 2 == 1 then
            -- next byte in memory
                current_screen_address += 1
            end
        end

    end

    if drawmode == 3 then
        x_dir = player.direction_x*15
        y_dir = player.direction_y*15
        line((player.x-1)*tile_width,(player.y-1)*tile_height,(player.x-1)*tile_width+x_dir,(player.y-1)*tile_height+y_dir,7)
    end

end

function level_init_update()
    -- stop music
     music(-1)

    level = {}
    level.width = level_size
    level.height = level_size
    level.map = {}
    level.clear_pos = -1

    -- do this first
    generate_level()

    init_player()
    init_sphere()
    init_syringe()

    -- in game music
     music(0)

    current_state = state_play_level
end
function level_init_draw()
end
--function level_update()
--end
--function level_draw()
--end
function level_done_update()
    if level.clear_pos < 0 then
    -- first time
        -- stop music
        music(-1)
    -- start level clear music
        music(8)

    end
    level.clear_pos += 1
    if level.clear_pos == screen_height then
        current_state = state_init_level
        level_size += 3
    end
end

function print_shadow(msg,y,flash)
    x = (screen_width-(#msg*4))/2
    print(msg,x+1,y+1,13)
    if flash then
        print(msg,x,y,rnd(15)+1)
    else
        print(msg,x,y,15)
    end
end

function level_done_draw()
    line(0,level.clear_pos,128,level.clear_pos,0)
    msg = "LEVEL COMPLETED!"
    print_shadow(msg,32,true)
    msg = "MAZE SIZE "..level_size
    print_shadow(msg,48,false)
end

function intro_init_update()
    music(-1)
    intro = {}
    intro.current_point = 0
    intro.start_y = 50
    intro.current_y = intro.start_y
    intro.msg_counter = 0
    intro.framecounter = 0
    intro.msgs = {
        "Deeper and Deeper",
        "a game for Ludum Dare 48",
        "by Mathias Olsson",
        "EXPLORE THE LABYRINTHS OF",
        "THE HUMAN MIND",
        "GO DEEPER AND DEEPER",
        "MAKE FREUD PROUD AGAIN",
        "controls:",
        "forward with ⬆️",
        "backward with ⬇️",
        "turn left with ⬅️",
        "turn right with ➡️",
        "toggle map with ❎",
        "nothing with 🅾️",
        "press ❎ to start",
        "",
        "By the way",
        "No real 3d here!",
        "This is a slow Wolfenstein 3d",
        "style raycaster",
        "combined with a recursive",
        "backtracking maze generator",
        ""
    }

    -- go intro music
    music(16)
    current_state = state_play_intro
end

function intro_update()
    if intro.current_point < #skull-2 then
        intro.current_point += 1
    else
        if intro.msg_counter >= #intro.msgs then
            intro.msg_counter -= #intro.msgs
        end
    end

  if btnp(5) then
    current_state = state_end_intro
  end

    intro.framecounter += 1
end

function intro_draw()
    cls(0)

    cx = (skull[#skull-1] + skull[1])/2

    for i=1,intro.current_point,2 do
        x1 = skull[i]
        y1 = skull[i+1]
        x2 = skull[i+2]
        y2 = skull[i+3]

        if i == 1 then
            line(cx,screen_height-1,x1,y1,rnd(3)+1)
        end
        line(cx,screen_height-1,x2,y2,rnd(3)+1)
    end

    for i=1,intro.current_point,2 do
        x1 = skull[i]
        y1 = skull[i+1]
        x2 = skull[i+2]
        y2 = skull[i+3]

        line(x1+1,y1,x2+1,y2,13)
        line(x1,y1+1,x2,y2+1,13)
    end

    for i=1,intro.current_point,2 do
        x1 = skull[i]
        y1 = skull[i+1]
        x2 = skull[i+2]
        y2 = skull[i+3]

        line(x1,y1,x2,y2,15)
    end

    if intro.current_point == #skull-2 then
        -- show the labyrinth
        sp = 72
        sx, sy = (sp % 16) * 8, (sp \ 16) * 8
        sw = 6*8
        sh = 4*8
        dw = sw
        dh = sh
        sspr(sx, sy, sw, sh, 50, 14, dw, dh)

        idx = 1+flr(intro.msg_counter)
        msg = intro.msgs[idx]
        y = intro.current_y
        x = (screen_width-#msg*4)/2
        print(msg,x,y,7)

        intro.current_y += 1
        if intro.current_y > screen_height then
            intro.current_y = intro.start_y
            intro.msg_counter += 1
        end
    end
end


-- state machine

function _init()
    game_init()
end

function _update()
    if current_state == state_init_intro then
        intro_init_update()
    elseif current_state == state_play_intro then
        intro_update()
    elseif current_state == state_end_intro then
        current_state = state_init_level

    elseif current_state == state_init_level then
        level_init_update()
    elseif current_state == state_play_level then
        level_update()
    elseif current_state == state_end_level then
        level_done_update()
    elseif current_state == state_init_game_over then
    elseif current_state == state_play_game_over then
    elseif current_state == state_end_game_over then
    end

end

function _draw()
    if current_state == state_init_intro then
    elseif current_state == state_play_intro then
        intro_draw()
    elseif current_state == state_end_intro then

    elseif current_state == state_init_level then
        level_init_draw()
    elseif current_state == state_play_level then
        level_draw()
    elseif current_state == state_end_level then
        level_done_draw()
    elseif current_state == state_init_game_over then
    elseif current_state == state_play_game_over then
    elseif current_state == state_end_game_over then
    end
end

__gfx__
11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000550000000000000000000000000000000000000
16100000000000000000000000000000000000000000000000000000000000000000000000000000000000055450000000000000000000000000000000000000
016100000000000000000000000000000000022222222266666666666660000000000000000000000000055449450000000000000000000000000000a0000000
00161000000000000000000000000000000228888888882777777777777660000000000000000000000554499945000000000000000000000a00a00000000000
00016101000100000000000000000000002888888888888277777777777776000000000000000000055449933394500000000000000000000000009000000000
00001616101610000000000000000000028778888888888277776666777777600000000000000055544993333394500000000000000000000009000000a00000
00000166616661000000000000000000028788888888888827776777677777600000000000005544499333333339450000000000000000000000090000000000
00001666166616100000000000000000288888888888888827776777677777760000000055554499933333333333945000000000000000000000000000000000
00000161666166610000000000000000288888888888888827776666777777760000555544449999993333333333945000000000001111000004000900a00000
00000016661666661000000000000000288888888888888827776777677777765555444499999939393333333333394500000000010000100010000000000000
00000166666666616100000000000000028888888888888827776777677777605444999933339939333333333333944500000000100000011100900000000000
00001666666666166610000000000000028888888888888277777777777777605499333333333999993333333399455000000000100000000000009000000000
000001ccccccc1ccccc1000000000000002888888888888277777777777776005493333333333339399333339944594500000055555000000000000000a00000
0000001ccccccccccc1c10001000000000022888888888277777777777766000549333333333993939933999445539450000005111500000000000a000000000
00000001ccccccccc1ccc10161000000000002222222226666666666666000005493333333333999993994445533394500000051115000000000000000000000
000000001ccccccc1ccccc1666100000000000000000000000000000000000005493333333333399999445553339994500005511111550000000000000000000
0000000001ccccccccccccc161000000000000000000000000000000000000005493333333333999444553399994445000051111111115000000000000000000
00000000001ccccccccccc1610000010000006666666666666ddddddddd000005493333339999444555999944445554500511111111111500000000000000000
000000000001ccccccccc1610000016100066777777777777dcccccccccdd0005493339994444555999444455553394505111111111111150000000000000000
0000000000001ccccccc1610000016100067777777777777dccccccccccccd005499994445555999444455533999944505111111111111150000000000000000
00000000000001ccccc16161000161000677777677767777dcccccccccc77cd05494445559994444555539999444455051171111111111115000000000000000
000000000000001ccc16166610161000067777766766777dcccccccccccc7cd05445554444445555999994444555594551111111111111115000000000000000
0000000000000001c161666661610000677777767676777dcccccccccccccccd5554445555559999444445555333994551711111111111115000000000000000
00000000000000161610166666100000677777767776777dcccccccccccccccd5455559999994444555553333999444551711111111111115000000000000000
00000000000001666100016661000000677777767776777dcccccccccccccccd5444444444445555333399999444555051711111111111115000000000000000
00000000000000161000001610000000067777767776777dccccccccccccccd00555555555559999999944444555000051111111111111115000000000000000
000000000000000100000161000000000677777777777777dcccccccccccccd00054999999994444444455555000000005171111111111150000000000000000
000000000000000000001610000000000067777777777777dccccccccccccd000054444444445555555500000000000005111111111111150000000000000000
0000000000000000000161000000000000066777777777777dcccccccccdd0000055555555550000000000000000000000511711111111500000000000000000
00000000000000000016100000000000000006666666666666ddddddddd000000000000000000000000000000000000000051111111115000000000000000000
00000000000000000161000000000000000000000000000000000000000000000000000000000000000000000000000000005511111550000000000000000000
00000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000055555000000000000000000000
00099000000990000009900000000000000000000000000000000000000000007777777777777777777777777777777777777777777777770000000000000000
0009f0000009f0000009f00000000000000000000000000000000000000000007800000000000000000000000000000070007000000000070000000000000000
0008000000880f0000280f0000000000000000000000000000000000000000007070777777707070770707077777777770707070777777070000000000000000
000800000f0820000f08800000000000000000000000000000000000000000007070000070007077070700770007070070707070700007070000000000000000
0008f000000800000008000000000000000000000000000000000000000000007070707070707000070070070707070700707070707707070000000000000000
000c00000010c00000c0100000000000000000000000000000000000000000007070700070707070007007070707070700707070700007070000000000000000
000c0000010055000c00550000000000000000000000000000000000000000007070707000707077700700070707070700707070707707070000000000000000
00055000055000000550000000000000000000000000000000000000000000007070700077707070770077070707070700700070700000070000000000000000
0007000000070000000c0000000c0000000c00000007000000000000000000007000000000700000707777777000000007777777777777070000000000000000
00070000000c0000000c0000000c0000000700000007000000000000000000007077777770777777707000007077777700000000000000070000000000000000
00ccc00000ccc00000ccc00000ccc000007770000077700000000000000000007070000070000000707070777070000007077777070707070000000000000000
00cc500000cc500000cc500000775000007750000077500000000000000000007070770770777777707070007070707007000000070777070000000000000000
00ccc00000ccc0000077700000777000007770000077700000000000000000007070700070000000707077707070700007077777000000070000000000000000
00cc5000007750000077500000775000007750000077500000000000000000007070707770707070707070007070707007000000070777070000000000000000
00070000000700000007000000070000000700000007000000000000000000007070707070000000707070777070000007077770000000070000000000000000
00777000007770000077700000777000007770000077700000000000000000007077707077777777700070000000077707000000777777070000000000000000
09000000090500000900006000000000000000000000000000000000000000007000000000000007000000007777707070077777700000070000000000000000
01757575017675050170755500000000000000000000000000000000000000007777777777777707077777707000707070000000707777770000000000000000
01575757015557670155576700000000000000000000000000000000000000007000000000000007000007007070007070077770700000070000000000000000
01757575017675550176755500000000000000000000000000000000000000007077777707777707077777070070700070000000777777070000000000000000
01575757015057670155570700000000000000000000000000000000000000007000000007000707000000070070707700777777700000070000000000000000
01000000010000500106000000000000000000000000000000000000000000007777777007000007777777707070707000000000707777770000000000000000
01000000010000000100000000000000000000000000000000000000000000007000000007777777000000007000707077777770700000070000000000000000
11100000111000001110000000000000000000000000000000000000000000007077777700000000070777077777707700000000777777070000000000000000
00000000000000000000000000000000000000000000000000000000000000007000700007070000000000000000707007777770000000070000000000000000
00000000000000000000000000000000000000000000000000000000000000007070707707070777070777770707707007000000777707070000000000000000
00000000000000000000000000000000000000000000000000000000000000007070700007070000070000000707007007077770000007070000000000000000
00000000000000000000000000000000000000000000000000000000000000007070707070007070070777770707070000000070777707070000000000000000
00000000000000000000000000000000000000000000000000000000000000007070700070700707070000000707070707077770000007070000000000000000
00000000000000000000000000000000000000000000000000000000000000007070707070070707700777770707070700000700070707070000000000000000
00000000000000000000000000000000000000000000000000000000000000007000700070000700707000000700000007070007000000c70000000000000000
00000000000000000000000000000000000000000000000000000000000000007777777777777777777777777777777777777777777777770000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffd00000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000fffddddddddddddddffffffd00000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000fffffffffffddd01000200001001ddddddffd000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000fffddddddddddd02001000200001001020003ddfd00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000ffddd000300000200200100020000100102000300dffd000000000000000000000000000000
000000000000000000000000000000000000000000000000000ffdd3000003000002002001000200001001020030002ddffffd00000000000000000000000000
0000000000000000000000000000000000000000000000000ffdd00300000300000200200100020000101020003000200ddddfffd00000000000000000000000
0000000000000000000000000000000000000000000ffffffdd20000300000300002002001000200001010200030020000200dddffd000000000000000000000
000000000000000000000000000000000000000000fdddddd0002000300000300002002001000200010010200030020002000002ddfd00000000000000000000
00000000000000000000000000000000000000000fd030020000200030000030000200200100020001001020003002000200002000dffd000000000000000000
0000000000000000000000000000000000000000fd00300020002000300000300002002001000200010010200030020002000020030ddffd0000000000000000
000000000000000000000000000000000000000fd00030002000200030000030000020200100020001001020003002000200002003000ddffd00000000000000
00000000000000000000000000000000000000fd00003000207777777777777777777777777777777777777777777777770000200300000ddfd0000000000000
000000000000000000000000000000000000ffd00000030020780200030000300000202001000200017010700300200027000200030000010fd0000000000000
00000000000000000000000000000000000fdd020000030002707277777770707077272707777777777070707377777727000200300000010dfd000000000000
0000000000000000000000000000000000fd000200000300027072000370007077072720770007070170707073702007270002003000000100dfd00000000000
000000000000000000000000000000000fd02002000003000270727073707070000720700707070707007270737077072700020030000010030dfd0000000000
00000000000000000000000000000000fd0020002000003002707270037070737000700707070707070072707370200727002000300000100300dfd000000000
00000000000000000000000000000000fd00200020000030007072707300707377702702070707070701727073707707070020030000001003000dfd00000000
0000000000000000000000000000000fd3000200200000300070707003777073707720770707070707017200737200020700200300000100300030fd00000000
0000000000000000000000000000000fd3000200020000300070002000307003007077777770020001077777777777770700200300000100300030dfd0000000
00000000000000000000000000000ffd003002000200000300707777777077777770700201707777770102003002000207020030000001030003020fd0000000
000000000000000000000000000ffdd0003000200200000300707020007000030070707277707000010707777707070707020030000010030003020dfd000000
00000000000000000000000000fdd0020030002000200003007270770770777777707072017070707107020030070777070200300000100300032000fd000000
0000000000000000000000000fd020020003000200200003007270720070000300707077717070701007077777020020070200300000103000302000dfd00000
000000000000000000000000fd00200020030002002000003072707277707073707070720170707070072000302707770720030000010030003020030fd00000
00000000000000000000000fd000020020030002002000003072707270730000307070727770700010072777702000200720030000010030030200030fd00000
0000000000000000000000fd2000020002003000200200003070777270777777777020720100200777072003007777770720030000010300030200303dfd0000
000000000000000000000fd020000020020030002002000003702002000300003700200201777770707127777770020007200300001003000320003030fd0000
00000000000000000000fd0002000020020003002002000003777777777777773707777771702070707020030070777777003000001003003020030300dfd000
0000000000000000000fd000020000020020030002002000037020002003000037000207017070007070277770700200070030000010300032000303030fd000
000000000000000000fd0000002000020020030002002000037077777707777737077777070070701070200302777777070030000100300302003030033fd000
000000000000000000fd0000002000002002003002002000007002002007300737000202070070707710777777700200070300000100300302003030303dfd00
00000000000000000fd200000002000020020030002002000077777770073000377777777170707070102003027077777703000001030003200303003300fd00
00000000000000000fd020000002000020020003002002000070020002077777770002020170207070777777727020002703000010030030200303030301dfd0
0000000000000000fd00200000002000020020030020020000707777770030003007077707777770771200300277777727030000103000320003300330010fd0
000000000000000fd200020000002000020020030002002000730070020737000300020201002070701777777200200027300000103003020030303030100dfd
000000000000000fd2000020000002000020020030020020007370707707370777070777770727707017003020777707073000010030030200330033001003fd
00000000000000fd00200020000002000020020030020020007370700207370003070202010727007017077770020007073000010300032003030303010003fd
00000000000000fd00020002000000200002002003002002007370707070037073070777770727071012003070777707073000010300302003300330010030fd
00000000000000fd00020002000000200002002003002002007070720070730707070202010727070707077770020007070000100300320030303030100031fd
00000000000000fd30002000200000020000202003002002007070727070070707700777770727070702003720070727070000103003020033003300100301fd
00000000000000fd03000200020000020000200200300200207030720070030703707202010720010107070027020020c70000103003200303030301003010fd
00000000000000fd03000200020000002000020200300200207777777777777777777777777777777777777777777777770001003003200303033001003011fd
00000000000000fd00300020002000002000020020300020200003020020030003000202010020010120030200200020300001030030200330303010030101fd
00000000000000fd00030020002000000200020020030020020003002002003000300202010020010120030200200200300001030032003030330100031010fd
00000000000000dfd0003002000200000200002002030020020003002002003000300022010020010120030200200200300010300302003303030100301100fd
000000000000000fd1003000200020000020002002003002020000302002003000300022010020010120030200200203000010300320030303301000310100fd
000000000000000fd0100300200020000020000202003002020000302002003000300020210020010120030202000203000010300320033030301003011003fd
000000000000000dfd100030020002000002000200203002002000300202003000300020210020010120302002000203000103003020303033010030101003fd
0000000000000000fd210030002002000002000020200300202000300200203000300020210020010120302002002003000103003200330303010031010030fd
0000000000000000fd12100300200020000020002002030020200003020020300030002021002001012030200200203000010303020303033010030110030fd0
0000000000000000fd21010030020002000020000202003020020003020020030030002021002001102030200200203000103003200330303010031010030fd0
0000000000000000fd20110030002002000002000200203002020003002020030030002021002001102030202000203000103003203030330100301100300fd0
0000000000000000fd32121003002000200002000020203002020003002020030030002021002001120030202002030000103032003303030103011003001fd0
0000000000000000fd30212100300200200000200020200302002000302002030003002021002010120032002002030001030032003303301003101003001fd0
000000000000000fd103021010300020020000200002020300202000302002030003002021002010120302002002030001030302033030301030110030010fd0
00000000000000fd0010320110030020020000020002020030202000302002030003002021002010120302002002030001030320033033010031010300100fd0
000000000000ffd10010032121003002002000020002002030200200300202003003002021002010120302020020300010300320330303100301100301002fd0
00000000000fdd001001003212103002000200002000202030020200030202003003002021002010120302020020300010303200330330100311003001002fd0
0000000000fd30000100103021100300200200000200202003020200030200203003002021002010120302020020300013003203033031003101030010020fd0
0000000000fd03000010010302110030020020000200020203002020030200203003002021002010120320020020300103030203303301030110030100200fd0
000000000fd000300010001032121003020020000020020203002020030020203003002021002010120320020203000103032030333010031100300102000fd0
00000000fd1000030001000103212103002002000020002020302020003020203003002020120011020320200203000130032033033010310103001002000fd0
0000000fd00100003000100100321100300200200002002020300202003020203000300220120011203020200203001030320033330100311003010020000fd0
000000fd300010000300010010302110030200200002000202030202003020200300300220120011203020200230001030320330330103101030010200001fd0
000000fd030001000030001001032121030020020000200202030202003020020300300220120011203020202030001303200333301030110300102000010fd0
00000fd0003000100003000100103212103002020000200022030020200302020300300220120011203020202030010303203303301031100301002000100fd0
0000fd00000300010000300010010321100302002000020020203020200302020300300220120011203202002030010303203333010310103010020000100fd0
000fd10000003300100003000100103211030020020002002020302020030202030030022012001120320200230001303203303310031103001020000100fd00
00fd00110000003001000300010010321210300202000020020203022000320203003002201200112032020203001030320333301031100301020000100fd000
00fd0000100000030010003000100103212003020020002002020302020030202030300220120101230202020300130030330331003110301002000100fd0000
0fd0330001000000300100030001001032110300202000020020230202003020203030022012010123020202300013032033330103110300102000100fd00000
0dffd0300010000003001000300010010321103020020002002020302200302020300302201201010302200230010303233033103101030102000100fd000000
00ddfd03000100000030010003000100130221030200200020022030202003202030030220120112032020203001303203333010311030102000010fd0000000
0000dfd033001100000300100030001001321200302020002002020320200302203003022012011203202020300130320333310311030100200010fd00000000
00000dffd03000100000300100030001010321103020020002002203022003020230030220120112032020230010303033330103110301020001ffd000000000
000000ddfd03000100000300100030001010321103020200020020230202030202030302201201120320202300130320333310311030102000ffdd0000000000
00000000fd2033001000003001100300010103221030202000200220320200320203030220120112302202030013032333301311030102000fdd200000000000
00000000dfd200300110000330010030010013212030200200200202302200320203030202120112302202030103320333310311030102001fd2000000000000
000000000fd02303000100000300100300100132110302020002020230202030220303020212011232020230013032333310311030102001fd20000000000000
000000000fd00220330010000030010030010013211030202002002203022030202303020212011232020230013030333310311301020001fd00000000000000
000000000fd2001200300100000300100300101032213020200020202302200320230300221201123202203013032333310311031020001fd000000000000000
000000000fd0200023030011000030010030010103220302020020022032020320230030221201103220230013030333310310301020010fd000000000000000
000000000fd002200220300010000300100300101321103020200202023022030220303022120110322023001332333310311301020010fd0000000000000000
000000000fd000020002033001000030010030010132113020200200223022030220303022120113022023013032333313110310200103fd0000000000000000
000000000fd10000220022030010000300100300101322030202002022032020320230302212112320202301303033310310301200111fd00000000000000000
000000000fd0110000200120300100003001003010013220302200200223022032023030221211232022300133233331311301020011fd000000000000000000
000000000fd000100002200233301100030010030101031130202002022032203022303022121123220230130303331031031020010fd0000000000000000000
000000000dfd0001100002002203001000330100301013211302020200223202032230302212112322023013323333131130120010fd00000000000000000000
0000000000fd220001000022002030010000301003010132103202002022302203220330221211232202301332333131130120010fd000000000000000000000
0000000000dfd0220011000020023330100003010030101322032020202023220322033022121123222301303333303103102010fd0000000000000000000000
00000000000fd220200011000200220301100030103001013113022002022322032023032212110302230133233313113102011fd00000000000000000000000
00000000000dfd02222000100022002030010003010300110311320200222032203223032212113220230133333303130120013fd00000000000000000000000
000000000000fd30022220011000200223301000301030011321032020202232203223032212113220201332333131031200132fd00000000000000000000000
000000000000fd0330022220011002201203010003010300113223022002223220322303221211322230133033103131020112fd000000000000000000000000
000000000000fd0003300202000100020023301100301030101321320202022322322303221211322230103333131301201120fd000000000000000000000000
000000000000fd3300033022220011002202233010030103010131132200222322032233221212322231332331311312010203fd000000000000000000000000
000000000000fd003300033022220010002002030100301030101313022020220203223322121232020133333131312011203fd0000000000000000000000000
00000000000fd0000033000330222201100220233010030103011322320202223223223302121232230132331313102012030fd0000000000000000000000000
00000000000fd000000033000330222001100202230100331030113213220202322322330212122223133333131312012230fd00000000000000000000000000
00000000000fd110000000330003302220010022023311003103011313022022232032330212122223133331313120122302fd00000000000000000000000000
00000000000fd001110000003300033022201100202230100310301131322020232232203212132220132331131201323021fd00000000000000000000000000
0000000000fd0000001100000033300332222011022123010031030113232202222232233212132231333313131213230210fd00000000000000000000000000
0000000000fd0000000011100000033003322200100202331003103101213202223232233212132231323331312112302100fd00000000000000000000000000
0000000000fd0000000000011000000330033222011022223110310311323220222223233211132201333131120123021000fd00000000000000000000000000
0000000000dfffd0000000000111000003300332220100202301031031131322222323233211132213333313201230210000fd00000000000000000000000000
00000000000dddffd10000000000110000033003322211022233103103113232022323223211122313331331212302100022fd00000000000000000000000000
00000000000000ddfd1111000000001110000330033222110222310310311212222222323211222313333112123020000233fd00000000000000000000000000
0000000000000000dffd11111000000001100003300322201022231031131123202232323211222132311321230200002300fd00000000000000000000000000
00000000000000000ddfd00011fffffffd011100033333222110222313313111322222323221222133333111202000223000fd00000000000000000000000000
0000000000000000000dffffffdddddddfd11011000033332221122231031313222223223321323133111212320002300033dfd0000000000000000000000000
00000000000000000000dddddd1111113dffd1111110003333222102231031313322232323213233333321232000230033000fd0000000000000000000000000
0000000000000000000000000033331110ddfd111101110033332211222103131232222323213213311112310022303300000dfd000000000000000000000000
000000000000000000000000000000333111dfd311111011003333221022313111122233232132123111231002300300000001fd000000000000000000000000
0000000000000000000000000000000000333dfd11111111111033332212231311122222232123333322310223033000000110fd000000000000000000000000
00000000000000000000000000000000000000fd31111111111110333322122131113222332121331213102303300000111000dfd00000000000000000000000
00000000000000000000000000000000000000dfd13311111111111133332122331132223321213311310233300000110000000fd00000000000000000000000
000000000000000000000000000000000000000fd31111331111111111333321221112222221233313122030000111000000022fd00000000000000000000000
000000000000000000000000000000000000000dfd3333311131111111111333212111223221333231233300111000000222200dfd0000000000000000000000
0000000000000000000000000000000000000000fd00000333331111111111133322331323221312023300110000022220000033dfd000000000000000000000
0000000000000000000000000000000000000000dfd11100000033333111111111331231223331222301110002222000333333000fd000000000000000000000
00000000000000000000000000000000000000000fd00011111111000333331111113323123231233110022220333333000000000dfd00000000000000000000
00000000000000000000000000000000000000000fd000000000001111111133333111133223223112222333330000000000000000fd00000000000000000000
00000000000000000000000000000000000000000fd111111111111111000011111111331323212223330000000000000000000000dfd0000000000000000000
00000000000000000000000000000000000000000d00000000000000001111111111111111112322222222222222222222222222222fd0000000000000000000

__sfx__
010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c073000001861400000286550000018614000000c073000000c07300000286550000018614000000c073000000c0730c0732865500000186140c0730c073286550c0730000028655000002865500000
011000000014000131001210414004031040210314000000000000000000000000000000000000000000000002140021310212107140071310712106140000000000000000000000000000000000000000000000
01100000243500000000000000002835024350243352725028250000002b250000002f251000000000000000262500000000000000002b25026350263352a2502b250000002b250000001b3501b3111b31100000
01100000243500000000000000002835024350243352725028250000002b250000002f251000000000000000262500000000000000002b25026350263352a2502b25000000282500000000000000002435000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000340500000000000000003405534055340553405500000000000000000000350550000000000000003505535055350553505500000000000000000000370550000039055000003b0553c0553405500000
011000001405000000140500000014050000000000000000000000000000000000001605000000160500000016050000000000000000000000000000000000001705000000130500000010050000000c05000000
00100000230550000000000000002405500000000000000000000000000000000000260550000000000000002705500000000000000000000000000000000000260550000000000000002405500000000001f055
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000317273372736727387273a727387273672733727317273372736727387273a727387273672733727317273372736727387273a727387273672733727317273372736727387273a727387273672733727
011000000c073246041861424600286550000018614000000c073000001861400000286550000018614000000c073000001861400000286550000018614000000c07300000186140000028655000000c07300000
01100000150501500015050000001505000000000000000011050000001105000000110500000000000000000c050000000c050000000c0500000000000000001305000000130500000013050000000000000000
001000000000018050000000000000000180500000000000000001505000000000000000015050000000000000000100500000000000000001005000000000000000017050000000000000000170500000000000
01100000300500000034050347000000034050000000000030050000002f050000002d050000002b050000002805000000000002b0502b000000002b050000003505034050330503205031050300502f0502b050
01100000300500000034050347000000034050000000000035050000001f000340501c00020000320500000034050000003205032000300500000030000340503505034000230003000024050240322402218012
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024050240322402218012
__music__
00 08424344
01 08094344
00 08094a44
00 08090a44
02 08090b44
00 41424344
00 41424344
00 41424344
04 10111244
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 14424344
00 14424344
00 14151617
00 14151617
01 18151617
00 18151617
00 19151617
00 41151617
02 1a151617

