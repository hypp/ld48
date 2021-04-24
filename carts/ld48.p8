pico-8 cartridge // http://www.pico-8.com
version 32
__lua__

screen_width = 128
screen_height = 128

drawmode = 0

level1_map = {
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,2,2,2,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1},
  {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,3,0,0,0,3,0,0,0,1},
  {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,2,2,0,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,0,0,0,5,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
}

function init_player()
    player={}
    player.x = 12
    player.y = 12
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

function game_init()
    init_camera()
    init_player()
end

function game_update()
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
  camera.plane_x = cos(player.angle+1.0/4)*0.66
  camera.plane_y = sin(player.angle+1.0/4)*0.66

  speed = 0
  if btn(2) then
    speed += 0.1
  end

  if btn(3) then
    speed -= 0.2
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

  if btnp(5) then
    if drawmode == 0 then
        drawmode = 1
    else
        drawmode = 0
    end
  end

end

function game_draw()
    cls(0)


    if drawmode == 0 then
        rectfill(0,0,screen_width,screen_height/2,14)
        rectfill(0,screen_height/2,screen_width,screen_height,13)
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

        print('*',player.x*tile_width,player.y*tile_height,7)
    end

    for x=0,screen_width do
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

            line_height = screen_height / perpendicular_wall_distance
            start_y = -line_height/2 + screen_height/2
            if start_y < 0 then
                start_y = 0
            end
            stop_y = line_height/2 + screen_height/2
            if stop_y > screen_height then
                stop_y = screen_height
            end

            color = current_level_map[1+map_y][1+map_x]
            if side == 1 then
                color += 5
            end

            line(x,start_y,x,stop_y,color)
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

