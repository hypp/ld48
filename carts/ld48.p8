pico-8 cartridge // http://www.pico-8.com
version 32
__lua__

screen_width = 128
screen_height = 128

texture_width = 32
texture_height = 32

spritesheet_address = 0x0
screen_address = 0x6000

drawmode = 0
render_type = 1

level1_map = {
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,9,0,0,1},
  {1,6,6,6,6,6,6,6,6,0,0,0,0,0,0,0,1,0,0,0,9,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,1,0,0,0,9,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,1,0,0,0,9,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,1,0,0,0,9,0,0,1},
  {1,0,3,3,3,3,3,0,0,0,0,0,4,0,0,0,0,0,0,0,9,0,0,1},
  {1,0,0,0,3,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,9,0,0,1},
  {1,0,0,0,3,3,3,3,3,3,3,0,4,0,0,0,0,0,0,0,9,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,2,0,0,0,0,0,0,0,0,8,8,8,8,8,8,0,0,1},
  {1,0,0,0,0,0,2,0,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,7,0,2,0,0,7,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,7,0,0,2,0,0,0,7,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,7,0,7,0,0,7,7,7,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,7,0,0,5,0,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,7,0,0,0,0,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,7,7,7,7,7,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
}

level1a_map = {
  {4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,7,7,7,7,7,7,7,7},
  {4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,0,0,0,0,0,0,7},
  {4,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7},
  {4,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7},
  {4,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,7,0,0,0,0,0,0,7},
  {4,0,4,0,0,0,0,5,5,5,5,5,5,5,5,5,7,7,0,7,7,7,7,7},
  {4,0,5,0,0,0,0,5,0,5,0,5,0,5,0,5,7,0,0,0,7,7,7,1},
  {4,0,6,0,0,0,0,5,0,0,0,0,0,0,0,5,7,0,0,0,0,0,0,8},
  {4,0,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,7,7,1},
  {4,0,8,0,0,0,0,5,0,0,0,0,0,0,0,5,7,0,0,0,0,0,0,8},
  {4,0,0,0,0,0,0,5,0,0,0,0,0,0,0,5,7,0,0,0,7,7,7,1},
  {4,0,0,0,0,0,0,5,5,5,5,0,5,5,5,5,7,7,7,7,7,7,7,1},
  {6,6,6,6,6,6,6,6,6,6,6,0,6,6,6,6,6,6,6,6,6,6,6,6},
  {8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4},
  {6,6,6,6,6,6,0,6,6,6,6,0,6,6,6,6,6,6,6,6,6,6,6,6},
  {4,4,4,4,4,4,0,4,4,4,6,0,6,2,2,2,2,2,2,2,3,3,3,3},
  {4,0,0,0,0,0,0,0,0,4,6,0,6,2,0,0,0,0,0,2,0,0,0,2},
  {4,0,0,0,0,0,0,0,0,0,0,0,6,2,0,0,5,0,0,2,0,0,0,2},
  {4,0,0,0,0,0,0,0,0,4,6,0,6,2,0,0,0,0,0,2,2,0,2,2},
  {4,0,6,0,6,0,0,0,0,4,6,0,0,0,0,0,5,0,0,0,0,0,0,2},
  {4,0,0,5,0,0,0,0,0,4,6,0,6,2,0,0,0,0,0,2,2,0,2,2},
  {4,0,6,0,6,0,0,0,0,4,6,0,6,2,0,0,5,0,0,2,0,0,0,2},
  {4,0,0,0,0,0,0,0,0,4,6,0,6,2,0,0,0,0,0,2,0,0,0,2},
  {4,4,4,4,4,4,4,4,4,4,1,1,1,2,2,2,2,2,2,3,3,3,3,3}
}

palette = {
    {0,1, 2, 3, 4, 5, 6, 7,8,9,10,11,12,13,14,15},
    {8,9,10,11,12,13,14,15,0,1, 2, 3, 4, 5, 6, 7},
}


function init_player()
    player={}
    player.x = 3
    player.y = 3
    player.angle = 0
    player.direction_x = 0
    player.direction_y = 0

-- player.vel_y = 0.0
-- player.vel_x = 0.0
-- player.acc_y = 0.0
-- player.acc_x = 0.0
-- player.jumping = false
-- player.radi = 3
-- player.energy = max_energy
-- player.energy_color = 9
-- player.dead = false
-- player.score = 0
-- player.score_color = 9
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
    init_player()
    init_sphere()
end

function game_update()
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
    speed += 0.1
  end

  if btn(3) then
    speed -= 0.1
  end

  current_level_map = level1_map

  new_x = player.x + player.direction_x * speed
  new_y = player.y + player.direction_y * speed
  map_x = flr(new_x)
  map_y = flr(new_y)
  if current_level_map[map_y+1][map_x+1] == 0 then
  -- allow it
    player.x = new_x
    player.y = new_y
  else
  -- blocked by wall

  end

  if btnp(4) then
    if render_type == 0 then
        render_type = 1
    else
        render_type = 0
    end
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

function game_draw()
    cls(0)


    if drawmode == 0 then
--        rectfill(0,0,screen_width,screen_height/2,0)
        rectfill(0,screen_height/2,screen_width,screen_height,13)

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

    current_level_map = level1_map

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
                if cell > 0 then
                    rectfill(x,y,x+tile_width-1,y+tile_height-1,cell)
                end
                x += tile_width
            end

            y += tile_height
        end

        spr(0,player.x*tile_width-4,player.y*tile_height-4,7)
    end

    current_screen_address = screen_address
    for x=0,screen_width-1 do
        camera_x = 2*x / screen_width - 1
        ray_direction_x = player.direction_x + camera.plane_x * camera_x
        ray_direction_y = player.direction_y + camera.plane_y * camera_x

        x_dir = ray_direction_x*25
        y_dir = ray_direction_y*25

        if drawmode == 1 then
            line(player.x*tile_width,player.y*tile_height,player.x*tile_width+x_dir,player.y*tile_height+y_dir,7)
        end

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
        current_x = map_x
        current_y = map_y
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

            if current_level_map[1+map_y][1+map_x] > 0 then
                hit = 1
            end
        end

        if drawmode == 1 then
            line(player.x*tile_width,player.y*tile_height,map_x*tile_width,map_y*tile_height,6)
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

            color = current_level_map[1+map_y][1+map_x]
            if color == 5 then
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
        line(player.x*tile_width,player.y*tile_height,player.x*tile_width+x_dir,player.y*tile_height+y_dir,7)
    end

end

-- state machine

function _init()
    game_init()
end

function _update()
    game_update()
end

function _draw()
    game_draw()
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
