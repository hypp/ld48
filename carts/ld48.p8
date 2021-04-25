pico-8 cartridge // http://www.pico-8.com
version 32
__lua__

screen_width = 128
screen_height = 128

texture_width = 32
texture_height = 32

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

end

-- TODO make level map 0 indexed

function init_player()
    player={}
    player.x = 1.5
    player.y = 1.5
    player.angle = 0
    player.direction_x = 0
    player.direction_y = 0

    -- put the player
    found = false
    for y=1,level.height do
        for x=1,level.width do
            if level.map[y][x] == 0 then
                -- check that it is visible from at least one direction
                if y != level.height then
                    if level.map[y+1][x] == 0 then
                        found = true
                        player.direction_x = 0
                        player.direction_y = 1
                    end
                end

                if y != 1 then
                    if level.map[y-1][x] == 0 then
                        found = true
                        player.direction_x = 0
                        player.direction_y = -1
                    end
                end

                if x != level.width then
                    if level.map[y][x+1] == 0 then
                        found = true
                        player.direction_x = 1
                        player.direction_y = 0
                    end
                end

                if x != 1 then
                    if level.map[y][x-1] == 0 then
                        found = true
                        player.direction_x = -1
                        player.direction_y = 0
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

    printh("y="..player.y.."x="..player.x)


    while not found do
    end 

end

function init_camera()
    camera={}
    camera.plane_x = 0
    camera.plane_y = 0.66
end


function init_sphere()

    sphere = {}
    sphere.points = {}
    sphere.rotated_points = {}

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

function game_init()
    init_camera()
    drawmode = 1
end

function level_update()
  -- btn 0,1 left and right
  if btn(0) then
    player.angle -= 0.01
  elseif btn(1) then
    player.angle += 0.01
  end

-- calculate player direction
  player.direction_x = cos(player.angle)*1
  player.direction_y = sin(player.angle)*1

-- camera plane is perpendicular to player direction
  camera.plane_x = cos(player.angle+1.0/4)*0.66
  camera.plane_y = sin(player.angle+1.0/4)*0.66

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
    if current_level_map[map_y][map_x] == 66 then
        -- found the syringe!! new level
        current_state = state_end_level
    end

  end

  if btnp(4) then
--    if render_type == 0 then
--        render_type = 1
--    else
--        render_type = 0
--    end

    -- cheat and go to next level
    current_state = state_end_level

  end
 

  if btnp(5) then
    if drawmode == 0 then
        drawmode = 1
    else
        drawmode = 0
    end
  end

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

    if drawmode == 1 then
        -- draw map
        map_height = #current_level_map
        map_width = #current_level_map[1]

        tile_width = screen_width/map_width
        tile_height = screen_height/map_height
        y = 0
        for row in all(current_level_map) do
            x = 0
            for cell in all(row) do
                if cell == 66 then
                    circfill(x+4,y+4,4,15)
                elseif cell > 0 then
                    rectfill(x,y,x+tile_width-1,y+tile_height-1,cell)
                end
                x += tile_width
            end

            y += tile_height
        end

        spr(0,(player.x-1)*tile_width-4,(player.y-1)*tile_height-4,7)
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

        if drawmode == 1 then
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
                texture = color
                if side == 0 then
                    wall_pos = player.y + perpendicular_wall_distance * ray_direction_y
                else
                    wall_pos = player.x + perpendicular_wall_distance * ray_direction_x
                end
                wall_pos -= flr(wall_pos)
                texture_x = wall_pos * texture_width
                if side == 0 and ray_direction_x > 0 then
                    texture_x = texture_width - texture_x - 1
                end
                if side == 1 and ray_direction_y < 0 then
                    texture_x = texture_width - texture_x - 1
                end

                -- select texture
                texture_x += 8

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

    if drawmode == 1 then
        x_dir = player.direction_x*15
        y_dir = player.direction_y*15
        line((player.x-1)*tile_width,(player.y-1)*tile_height,(player.x-1)*tile_width+x_dir,(player.y-1)*tile_height+y_dir,7)
    end

end

function level_init_update()
    level = {}
    level.width = level_size
    level.height = level_size
    level.map = {}
    level.clear_pos = -1

    -- do this first
    generate_level()

    init_player()
    init_sphere()

    current_state = state_play_level
end
function level_init_draw()
end
--function level_update()
--end
--function level_draw()
--end
function level_done_update()
    level.clear_pos += 1
    if level.clear_pos == screen_height then
        current_state = state_init_level
        level_size += 1
    end
end
function level_done_draw()
    line(0,level.clear_pos,128,level.clear_pos,0)
    print("LEVEL COMPLETED!",14+1,32+1,13)
    print("LEVEL COMPLETED!",14,32,15)
end


-- state machine

function _init()
    game_init()
end

function _update()
    if current_state == state_init_intro then
        current_state = state_init_level
    elseif current_state == state_play_intro then
    elseif current_state == state_end_intro then

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
00000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700016100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000001610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000161010001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000016161016100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000001666166610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000016661666161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000001616661666100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000166616666610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000001666666666161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000016666666661666100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000001ccccccc1ccccc10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000001ccccccccccc1c1000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000001ccccccccc1ccc101610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001ccccccc1ccccc16661000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000001ccccccccccccc1610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000001ccccccccccc16100000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000001ccccccccc161000001610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000001ccccccc1610000016100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000001ccccc16161000161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000001ccc161666101610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000001c1616666616100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000001616101666661000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000016661000166610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000001610000016100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000100000161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000001610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000016100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000001610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
