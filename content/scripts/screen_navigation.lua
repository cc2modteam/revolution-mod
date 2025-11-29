g_camera_pos_x = 0
g_camera_pos_y = 0
g_is_camera_pos_initialised = false
g_camera_size = (32 * 1024)
g_camera_size_max = 128 * 1024
g_camera_size_min = 4 * 1024
g_screen_index = 2
g_map_render_mode = 1
g_ui = nil
g_is_carrier = true
g_is_pointer_pressed = false
g_is_pointer_hovered = false
g_pointer_pos_x = 0
g_pointer_pos_y = 0
g_pointer_pos_x_prev = 0
g_pointer_pos_y_prev = 0
g_drag_distance = 0
g_is_vehicle_team_colors = true
g_is_island_team_colors = true
g_is_island_names = true
g_is_deploy_carrier_triggered = false
g_dock_state_prev = nil
g_color_waypoint = color8(0, 255, 255, 8)
g_animation_time = 0
g_map_window_scroll = 0
g_is_vehicle_links = true
g_is_follow_carrier = true

g_screen_w = 128
g_screen_h = 128

g_screen_name = nil
g_alt_mode = nil

function parse()
    g_is_camera_pos_initialised = parse_bool("is_map_init", g_is_camera_pos_initialised)
    g_camera_pos_x = parse_f32("map_x", g_camera_pos_x)
    g_camera_pos_y = parse_f32("map_y", g_camera_pos_y)
    g_camera_size = parse_f32("map_size", g_camera_size)
    g_screen_index = parse_s32("", g_screen_index)
    g_map_render_mode = parse_s32("mode", g_map_render_mode)
    g_is_vehicle_team_colors = parse_bool("is_vehicle_team_colors", g_is_vehicle_team_colors)
    g_is_island_team_colors = parse_bool("is_island_team_colors", g_is_island_team_colors)
    
    -- End of original parse calls
    
    g_is_island_names = parse_bool("is_island_names", g_is_island_names)
    g_map_window_scroll = parse_f32("", g_map_window_scroll)
    g_is_vehicle_links = parse_bool("is_vehicle_links", g_is_vehicle_links)
    g_is_follow_carrier = parse_bool("is_follow_carrier", g_is_follow_carrier)
end

function begin()
    begin_load()

    if g_is_camera_pos_initialised == false then
        g_is_camera_pos_initialised = true

        local screen_name = begin_get_screen_name()
        g_screen_name = screen_name
        g_camera_size = (64 * 1024)
        if screen_name == "screen_nav_l" then
            g_map_render_mode = 2
            g_camera_size = (4 * 1024)
        elseif screen_name == "screen_nav_m" then
            g_map_render_mode = 3
            g_camera_size = (16 * 1024)
        elseif screen_name == "screen_nav_r" then
            g_map_render_mode = 4
            g_camera_size = (64 * 1024)
        elseif screen_name == "screen_nav_top_m" or screen_name == "mule-dash-tablet" then
            g_map_render_mode = 0
            g_alt_mode = "helm"
            if screen_name == "mule-dash-tablet" then
                g_is_carrier = false
            end
        end
    end

    g_ui = lib_imgui:create_ui()
end

function update_torpedo_info(screen_w, screen_h)
    local vehicle = update_get_screen_vehicle()

    local cy = 8
    cy = update_ui_text(6, cy, update_get_loc(e_loc.upp_inventory), screen_h - 5, 0, color_status_dark_yellow, 0)
    update_ui_rectangle_outline(4, 4, screen_h - 8, screen_w - 8, color_grey_mid)

    local torp = vehicle:get_inventory_count_by_item_index(e_inventory_item.hardpoint_torpedo)
    local torp_color = color_white
    if torp < 4 then
        torp_color = color_enemy
    end
    cy = cy + 16
    update_ui_text(8, cy,
            update_get_loc(e_loc.upp_torpedo), screen_w - 16, 0, color_white, 0)
    update_ui_text(screen_w - 20, cy,
            torp, 4, 0, torp_color, 0)

    local noise = vehicle:get_inventory_count_by_item_index(e_inventory_item.hardpoint_torpedo_noisemaker)
    local noise_color = color_white
    if noise < 4 then
        noise_color = color_enemy
    end

    cy = cy + 22
    update_ui_text(8, cy,
            update_get_loc(e_loc.upp_torpedo_noisemaker), screen_w - 16, 0, color_white, 0)
    update_ui_text(screen_w - 20, cy,
            noise, 4, 0, noise_color, 0)

    local decoy = vehicle:get_inventory_count_by_item_index(e_inventory_item.hardpoint_torpedo_decoy)
    local decoy_color = color_white
    if decoy < 4 then
        decoy_color = color_enemy
    end

    cy = cy + 22
    update_ui_text(8, cy,
            update_get_loc(e_loc.upp_torpedo_decoy), screen_w - 16, 0, color_white, 0)
    update_ui_text(screen_w - 20, cy,
            decoy, 4, 0, decoy_color, 0)


end

function update(screen_w, screen_h, ticks)
    if g_debug_enabled then
        local st, err = pcall(_update, screen_w, screen_h, ticks)
        if not st then
            print(err)
        end
    else
        _update(screen_w, screen_h, ticks)
    end
end

function _update(screen_w, screen_h, ticks)
    local highres = screen_w > 128
    g_screen_w = screen_w
    g_screen_h = screen_h
    g_animation_time = g_animation_time + ticks

    if g_screen_name == "screen_bridge_torps" then
        update_torpedo_info(screen_w, screen_h)
        return
    elseif g_screen_name == "screen_helm_hud" then
        if g_debug_enabled then
            local st, err = pcall( function()
                helm_hud_update(screen_w, screen_h, ticks)
            end)
            if not st then
                print(err)
            end
        else
            helm_hud_update(screen_w, screen_h, ticks)
        end

        return
    end

    if update_get_active_input_type() == e_active_input.gamepad then
        -- Set pointer to middle of screen
        g_pointer_pos_x = math.floor(screen_w / 2)
        g_pointer_pos_y = math.floor(screen_h / 2)
    end

    local this_vehicle = update_get_screen_vehicle()
    local screen_team = update_get_local_team_id()
    update_set_screen_background_type(0)

    if g_is_deploy_carrier_triggered and this_vehicle:get_dock_state() ~= e_vehicle_dock_state.docked then
        update_set_screen_state_exit()
        g_is_deploy_carrier_triggered = false
    end

    if g_dock_state_prev ~= nil and g_dock_state_prev == e_vehicle_dock_state.docked and g_dock_state_prev ~= this_vehicle:get_dock_state() then
        g_boot_counter = 30
        g_screen_index = 0
    end

    g_dock_state_prev = this_vehicle:get_dock_state()

    if update_screen_overrides(screen_w, screen_h, ticks)  then return end

    local is_local = update_get_is_focus_local()

    local ui = g_ui
    ui:begin_ui()

    update_set_screen_background_type(g_map_render_mode)

    if g_screen_index == 0 then
        if g_alt_mode == "helm" then
            compass_update(screen_w, screen_h, ticks)
        else
            refresh_fow_islands()

            if not g_is_follow_carrier then
                update_add_ui_interaction_special(update_get_loc(e_loc.interaction_pan), e_ui_interaction_special.map_pan)
            end

            update_add_ui_interaction_special(update_get_loc(e_loc.interaction_zoom), e_ui_interaction_special.map_zoom)
            update_add_ui_interaction(update_get_loc(e_loc.interaction_map_options), e_game_input.interact_a)

            if this_vehicle:get() then
                local this_vehicle_pos = this_vehicle:get_position_xz()

                if g_is_follow_carrier then
                    g_camera_pos_x = this_vehicle_pos:x()
                    g_camera_pos_y = this_vehicle_pos:y()
                elseif is_local and g_is_pointer_pressed and g_is_pointer_hovered then
                    local pos_dx = g_pointer_pos_x - g_pointer_pos_x_prev
                    local pos_dy = g_pointer_pos_y - g_pointer_pos_y_prev

                    local drag_threshold = iff( update_get_is_vr(), 20, 3 )
                    g_drag_distance = g_drag_distance + math.abs(pos_dx) + math.abs(pos_dy)

                    if g_drag_distance >= drag_threshold then
                        g_camera_pos_x = g_camera_pos_x - (pos_dx * g_camera_size * 0.005)
                        g_camera_pos_y = g_camera_pos_y + (pos_dy * g_camera_size * 0.005)
                    end
                end

                local carrier_x, carrier_y = get_screen_from_world(this_vehicle_pos:x(), this_vehicle_pos:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                update_set_screen_map_position_scale(g_camera_pos_x, g_camera_pos_y, g_camera_size)

                local is_render_islands = (g_camera_size < (screen_w / 2 * 1024))
                if highres then
                    is_render_islands = (g_camera_size < (64 * 1024))
                end

                update_set_screen_background_is_render_islands(is_render_islands)

                local island_count = update_get_tile_count()

                for i = 0, island_count - 1, 1 do
                    local island = update_get_tile_by_index(i)

                    if island:get() then
                        local visible = fow_island_visible(island:get_id())
                        local island_color = get_island_team_color(island:get_team_control())
                        if not visible then
                            island_color = g_island_color_unknown
                        end
                        local island_position = island:get_position_xz()

                        if is_render_islands == false and rev_show_island_icon(island:get_id()) then
                            local screen_pos_x, screen_pos_y = get_screen_from_world(island_position:x(), island_position:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                            update_ui_image(screen_pos_x - 4, screen_pos_y - 4, atlas_icons.map_icon_island, island_color, 0)
                        elseif g_is_island_names then
                            local screen_pos_x, screen_pos_y = get_screen_from_world(island_position:x(), island_position:y() + 3000.0, g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                            if rev_show_island_name(island:get_id()) then
                                update_ui_text(screen_pos_x - 64, screen_pos_y - 9, get_island_name(island), 128, 1, island_color, 0)
                            end

                            if (not g_revolution_hide_island_difficulty) and rev_show_island_icon(island:get_id()) and island:get_team_control() ~= update_get_screen_team_id() then
                                local difficulty_level = island:get_difficulty_level()
                                local icon_w = 6
                                local icon_spacing = 2
                                local total_w = icon_w * difficulty_level + icon_spacing * (difficulty_level - 1)
                                for i = 0, difficulty_level - 1 do
                                    update_ui_image(screen_pos_x - total_w / 2 + (icon_w + icon_spacing) * i, screen_pos_y, atlas_icons.column_difficulty, island_color, 0)
                                end
                            end
                        end
                    end
                end

                -- render vehicle links to the map
                if g_is_vehicle_links then
                    for _, vehicle in pairs(get_vehicles_table()) do

                        local vehicle_team = vehicle:get_team()
                        local vehicle_attached_parent_id = vehicle:get_attached_parent_id(i)

                        if vehicle_team == screen_team and vehicle_attached_parent_id == 0 then
                            local def = vehicle:get_definition_index()

                            local veh_pos = vehicle:get_position_xz()
                            local veh_x, veh_y = get_screen_from_world(veh_pos:x(), veh_pos:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                            if def == e_game_object_type.chassis_sea_barge then
                                local action, destination_id, destination_type = vehicle:get_barge_state_data()

                                if destination_type == e_barge_destination_type.vehicle and destination_id == this_vehicle:get_id() then -- The destination of this barge is the carrier
                                    render_dashed_line(veh_x, veh_y, carrier_x, carrier_y, color8(0, 255, 64, 255))
                                end
                            elseif def ~= e_game_object_type.chassis_spaceship and def ~= e_game_object_type.drydock then
                                local is_rotor = (def == e_game_object_type.chassis_air_rotor_light or def == e_game_object_type.chassis_air_rotor_heavy)

                                local dock_state = vehicle:get_dock_state()

                                if dock_state == e_vehicle_dock_state.docking then
                                    render_dashed_line(veh_x, veh_y, carrier_x, carrier_y, color8(205, 8, 8, 255))
                                elseif dock_state == e_vehicle_dock_state.dock_queue then
                                    render_dashed_line(veh_x, veh_y, carrier_x, carrier_y, color8(205, 8, 246, 255))
                                end
                            end
                        end
                    end
                end

                -- render vehicles to the map
                for _, vehicle in pairs(get_vehicles_table()) do

                    local vehicle_team = vehicle:get_team()
                    local vehicle_attached_parent_id = vehicle:get_attached_parent_id(i)

                    if vehicle:get_is_visible() and vehicle:get_is_observation_revealed() and vehicle_attached_parent_id == 0 then
                        -- render vehicle icon
                        local vehicle_definition_index = vehicle:get_definition_index()
                        local show_icon = true
                        if vehicle_team ~= screen_team then
                            if get_is_vehicle_masked(vehicle) then
                                show_icon = false
                            end
                        end

                        if show_icon and vehicle_definition_index ~= e_game_object_type.chassis_spaceship and vehicle_definition_index ~= e_game_object_type.drydock then

                            local vehicle_pos_xz = vehicle:get_position_xz()
                            local v_x = vehicle_pos_xz:x()
                            local v_y = vehicle_pos_xz:y()
                            local screen_pos_x, screen_pos_y = get_screen_from_world(v_x, v_y, g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                            local region_vehicle_icon, icon_offset = get_icon_data_by_definition_index(vehicle_definition_index)
                            local element_color = get_vehicle_team_color(vehicle_team)

                            update_ui_image(screen_pos_x - icon_offset, screen_pos_y - icon_offset, region_vehicle_icon, element_color, 0)

                            if screen_team == vehicle_team then
                                if update_get_screen_vehicle():get_id() == vehicle:get_id() then
                                    -- friendly
                                    draw_map_radar_state_indicator(vehicle, screen_pos_x, screen_pos_y, g_animation_time)
                                end
                            end
                        end
                    end
                end

                -- render carrier direction indicator
                update_ui_image(carrier_x - 5, carrier_y - 5, atlas_icons.map_icon_circle_9, color_white, 0)

                local this_vehicle_dir = this_vehicle:get_direction()
                update_ui_line(carrier_x, carrier_y, carrier_x + (this_vehicle_dir:x() * 20), carrier_y + (this_vehicle_dir:y() * -20), color_white)

                -- render carrier waypoints
                local waypoint_count = this_vehicle:get_waypoint_count()

                local screen_vehicle_pos = this_vehicle:get_position_xz()
                local waypoint_prev_x, waypoint_prev_y = get_screen_from_world(screen_vehicle_pos:x(), screen_vehicle_pos:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                for i = 0, waypoint_count - 1, 1 do
                    local waypoint = this_vehicle:get_waypoint(i)
                    local waypoint_pos = waypoint:get_position_xz()

                    local waypoint_screen_pos_x, waypoint_screen_pos_y = get_screen_from_world(waypoint_pos:x(), waypoint_pos:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                    update_ui_line(waypoint_prev_x, waypoint_prev_y, waypoint_screen_pos_x, waypoint_screen_pos_y, g_color_waypoint)
                    update_ui_image(waypoint_screen_pos_x - 3, waypoint_screen_pos_y - 3, atlas_icons.map_icon_waypoint, g_color_waypoint, 0)

                    waypoint_prev_x = waypoint_screen_pos_x
                    waypoint_prev_y = waypoint_screen_pos_y
                end

                local missile_count = update_get_missile_count()

                for i = 0, missile_count - 1 do
                    local missile = update_get_missile_by_index(i)
                    local def = missile:get_definition_index()

                    local position_xz = missile:get_position_xz()
                    local screen_pos_x, screen_pos_y = get_screen_from_world(position_xz:x(), position_xz:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                    if missile:get_is_visible() and (def == e_game_object_type.torpedo or def == e_game_object_type.torpedo_decoy or def == e_game_object_type.torpedo_noisemaker) then
                        local missile_trail_count = missile:get_trail_count()
                        local trail_prev_x = screen_pos_x
                        local trail_prev_y = screen_pos_y
                        for missile_trail_index = 0, missile_trail_count - 1 do
                            local trail_xz = missile:get_trail_position(missile_trail_index)
                            local trail_next_x, trail_next_y = get_screen_from_world(trail_xz:x(), trail_xz:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                            update_ui_line(trail_prev_x, trail_prev_y, trail_next_x, trail_next_y, color8(255, 255, 255, 16 - math.floor(missile_trail_index / 4)))
                            trail_prev_x = trail_next_x
                            trail_prev_y = trail_next_y
                        end

                        local is_timer_running = missile:get_timer() > 0
                        local is_own_team = missile:get_team() == screen_team

                        local color_missile = color_white

                        local icon_image = atlas_icons.map_icon_torpedo
                        if def == e_game_object_type.torpedo_decoy or def == e_game_object_type.torpedo_noisemaker then
                            icon_image = atlas_icons.map_icon_torpedo_decoy

                            if is_own_team then
                                if is_timer_running then
                                    if g_animation_time % 10 < 5 then
                                        color_missile = color8(64, 64, 255, 255)
                                    else
                                        color_missile = color_white
                                    end
                                end
                            end
                        else
                            icon_image = atlas_icons.map_icon_torpedo

                            if is_own_team then
                                if is_timer_running then
                                    color_missile = color_white
                                else
                                    if g_animation_time % 10 < 5 then
                                        color_missile = color8(255, 64, 64, 255)
                                    else
                                        color_missile = color_white
                                    end
                                end
                            end
                        end

                        update_ui_image(screen_pos_x - 3, screen_pos_y - 3, icon_image, color_missile, 0)

                        if is_local and g_is_pointer_hovered then
                            local missile_distance_to_cursor = math.abs(screen_pos_x - g_pointer_pos_x) + math.abs(screen_pos_y - g_pointer_pos_y)

                            if is_own_team and missile_distance_to_cursor < 8 and is_timer_running then
                                update_ui_text(screen_pos_x - 16, screen_pos_y - 12, tostring(math.floor(missile:get_timer() / 30) + 1), 32, 1, color_missile, 0)
                            end
                        end
                    end
                end

                local world_x = g_camera_pos_x
                local world_y = g_camera_pos_y

                if is_local and g_is_pointer_hovered then
                    world_x, world_y = get_world_from_screen(g_pointer_pos_x, g_pointer_pos_y, g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                    local label_x = 5
                    local label_y = 5
                    local label_w = screen_w - 2 * label_x
                    local label_h = 10

                    update_ui_push_offset(label_x, label_y)

                    if g_map_render_mode > 1 then
                        if g_map_render_mode == 3 then label_h = label_h * 2 end
                        update_ui_rectangle(0, 0, label_w, label_h, color_black)
                    end

                    if g_map_render_mode == 2 then
                        update_ui_text(1, 1, string.format(update_get_loc(e_loc.upp_wind)..": %.2f", update_get_weather_wind_velocity(world_x, world_y)), label_w, 0, color_white, 0)
                    elseif g_map_render_mode == 3 then
                        update_ui_text(1, 1, string.format(update_get_loc(e_loc.upp_precipitation)..": %.0f%%", update_get_weather_precipitation_factor(world_x, world_y) * 100), label_w, 0, color_white, 0)

                        update_ui_image(1, 10, atlas_icons.column_power, color_white, 0)
                        update_ui_text(1, 10, string.format(": %.0f%%", update_get_weather_lightning_factor(world_x, world_y) * 100), label_w, 0, color_white, 0)
                    elseif g_map_render_mode == 4 then
                        update_ui_text(1, 1, string.format(update_get_loc(e_loc.upp_visibility)..": %.0f%%", update_get_weather_fog_factor(world_x, world_y) * 100), label_w, 0, color_white, 0)
                    elseif g_map_render_mode == 5 then
                        update_ui_text(1, 1, string.format(update_get_loc(e_loc.upp_ocean_current)..": %.2f", update_get_ocean_current_velocity(world_x, world_y)), label_w, 0, color_white, 0)
                    elseif g_map_render_mode == 6 then
                        update_ui_text(1, 1, string.format(update_get_loc(e_loc.upp_ocean_depth)..": %.2f", update_get_ocean_depth_factor(world_x, world_y)), label_w, 0, color_white, 0)
                    end

                    update_ui_pop_offset()

                end

                update_ui_text(10, screen_h - 13, string.format("X:%-6.0f ", world_x) .. string.format("Y:%-6.0f", world_y), screen_w - 10, 0, color_grey_dark, 0)

                if not g_is_follow_carrier and update_get_active_input_type() == e_active_input.gamepad then
                    local crosshair_color = color8(255, 255, 255, 255)

                    update_ui_rectangle(g_pointer_pos_x, g_pointer_pos_y + 2, 1, 4, crosshair_color)
                    update_ui_rectangle(g_pointer_pos_x, g_pointer_pos_y - 5, 1, 4, crosshair_color)
                    update_ui_rectangle(g_pointer_pos_x + 2, g_pointer_pos_y, 4, 1, crosshair_color)
                    update_ui_rectangle(g_pointer_pos_x - 5, g_pointer_pos_y, 4, 1, crosshair_color)
                end
            end
        end
    elseif g_screen_index ~= 2 then
        update_add_ui_interaction_special(update_get_loc(e_loc.interaction_navigate), e_ui_interaction_special.gamepad_dpad_ud)
        update_add_ui_interaction(update_get_loc(e_loc.interaction_back), e_game_input.back)

        local is_local = update_get_is_focus_local()
        local window = ui:begin_window(update_get_loc(e_loc.upp_map), 10, 10, screen_w - 20, screen_h - 20, atlas_icons.column_pending, true, 2)
            if is_local then
                g_map_window_scroll = window.scroll_y
            else
                window.scroll_y = g_map_window_scroll
            end
            window.label_bias = 0.9
            
            ui:header(update_get_loc(e_loc.upp_map_mode))
            g_alt_mode = nil
            if ui:checkbox(update_get_loc(e_loc.upp_cartographic), g_map_render_mode == 1, true) then g_map_render_mode = 1 end
            if ui:checkbox(update_get_loc(e_loc.upp_wind), g_map_render_mode == 2, true) then g_map_render_mode = 2 end
            if ui:checkbox(update_get_loc(e_loc.upp_precipitation), g_map_render_mode == 3, true) then g_map_render_mode = 3 end
            if ui:checkbox(update_get_loc(e_loc.upp_fog), g_map_render_mode == 4, true) then g_map_render_mode = 4 end
            if ui:checkbox(update_get_loc(e_loc.upp_ocean_current), g_map_render_mode == 5, true) then g_map_render_mode = 5 end
            if ui:checkbox(update_get_loc(e_loc.upp_ocean_depth), g_map_render_mode == 6, true) then g_map_render_mode = 6 end
            if ui:checkbox(update_get_loc(e_loc.upp_helm), g_map_render_mode == 0, true) then
                g_map_render_mode = 0
                g_alt_mode = "helm"
            end
            ui:divider()

            g_is_follow_carrier = ui:checkbox("FOLLOW CARRIER", g_is_follow_carrier)
            g_is_vehicle_team_colors = ui:checkbox(update_get_loc(e_loc.upp_vehicle_team_colors), g_is_vehicle_team_colors)
            g_is_island_team_colors = ui:checkbox(update_get_loc(e_loc.upp_island_team_colors), g_is_island_team_colors)
            g_is_island_names = ui:checkbox(update_get_loc(e_loc.upp_island_names), g_is_island_names)
            g_is_vehicle_links = ui:checkbox("VEHICLE LINKS", g_is_vehicle_links)

            ui:spacer(5)
    
        ui:end_window()
    elseif g_screen_index == 2 then
        update_set_screen_background_type(0)
        update_add_ui_interaction_special(update_get_loc(e_loc.interaction_navigate), e_ui_interaction_special.gamepad_dpad_ud)

        if this_vehicle:get() and this_vehicle:get_dock_state() == e_vehicle_dock_state.docked then
            local window = ui:begin_window(update_get_loc(e_loc.upp_carrier) .. "###launch", 10, 5, screen_w - 20, screen_h - 20, atlas_icons.column_pending, true, 2)
            window.label_bias = 0.15

            ui:header(update_get_loc(e_loc.upp_status))

            local fuel_factor = this_vehicle:get_fuel_factor()
            local hitpoints = this_vehicle:get_hitpoints()
            local total_hitpoints = this_vehicle:get_total_hitpoints()
            local inventory_capacity = this_vehicle:get_inventory_capacity()

            local function get_factor_color(factor)
                if factor < 0.25 then
                    return color_status_bad
                elseif factor < 0.75 then
                    return color_status_warning
                end

                return color_status_ok
            end

            ui:stat(atlas_icons.column_fuel, string.format("%.0f%%", fuel_factor * 100), get_factor_color(fuel_factor))
            ui:stat(atlas_icons.icon_health, string.format("%.0f/%.0f", hitpoints, total_hitpoints), get_factor_color(hitpoints / total_hitpoints))
            if inventory_capacity > 0 then
                local inventory_factor = this_vehicle:get_inventory_weight() / inventory_capacity
                ui:stat(atlas_icons.column_weight, string.format("%.0f%%", inventory_factor * 100), iff(inventory_factor < 1, color_status_ok, color_status_bad))
            end

            ui:header(update_get_loc(e_loc.upp_operation))
            local team = this_vehicle:get_team()
            local ready_color = color_status_dark_green
            local ready = rev_get_team_ready(team)
            if ready then
                ready_color = color_status_dark_red
            end
            if ui:button(update_get_loc(e_loc.upp_ready), true, 1, ready_color) then
                local_print("set", "ready", ">", not ready)
                rev_set_team_ready(team, not ready)
            end
            if ready then
                if imgui_list_item_blink(ui, update_get_loc(e_loc.upp_launch_carrier), true) then
                    g_screen_index = 0
                    g_boot_counter = 30
                    g_is_deploy_carrier_triggered = true
                    update_launch_carrier(this_vehicle:get_id())
                end
            end

            ui:end_window()
        else
            g_screen_index = 0
        end
    end
    
    ui:end_ui()
    
    if g_is_pointer_hovered then
        g_pointer_pos_x_prev = g_pointer_pos_x
        g_pointer_pos_y_prev = g_pointer_pos_y
    end
end

function input_event(event, action)
    g_ui:input_event(event, action)

    if g_screen_index == 0 then
        if action == e_input_action.press then
            if event == e_input.back then
                update_set_screen_state_exit()
            end
        elseif action == e_input_action.release then
            local pos_dx = g_pointer_pos_x - g_pointer_pos_x_prev
            local pos_dy = g_pointer_pos_y - g_pointer_pos_y_prev
        
            local drag_threshold = iff( update_get_is_vr(), 20, 3 )
            g_drag_distance = g_drag_distance + math.abs(pos_dx) + math.abs(pos_dy)
        
            if event == e_input.action_a or (event == e_input.pointer_1 and g_drag_distance < drag_threshold) then
                if g_boot_counter <= 0 then
                    g_screen_index = 1 
                end
            end
        end
    elseif g_screen_index == 1 then
        if action == e_input_action.press then
            if event == e_input.back then
                g_screen_index = 0
            end
        end
    elseif g_screen_index == 2 then
        if action == e_input_action.release then
            if event == e_input.back then
                update_set_screen_state_exit()
            end
        end
    end
    
    if event == e_input.pointer_1 then
        g_is_pointer_pressed = action == e_input_action.press
        if not g_is_pointer_pressed then
            g_drag_distance = 0
        end
    end
end

function input_pointer(is_hovered, x, y)
    g_ui:input_pointer(is_hovered, x, y)
    g_is_pointer_hovered = is_hovered
    g_pointer_pos_x = x
    g_pointer_pos_y = y
end

function input_scroll(dy)
    g_ui:input_scroll(dy)

    if g_is_pointer_hovered and update_get_active_input_type() == e_active_input.keyboard then
        input_camera_zoom(1 - dy * 0.2)
    end
end

function input_axis(x, y, z, w)
    input_camera_zoom(1 - w * 0.1)
    
    if not g_is_follow_carrier then
        g_camera_pos_x = g_camera_pos_x + x * g_camera_size * 0.05
        g_camera_pos_y = g_camera_pos_y + y * g_camera_size * 0.05
    end
end

function input_camera_zoom(factor)
    if g_screen_index == 0 then
        g_camera_size = clamp(g_camera_size * factor, g_camera_size_min, g_camera_size_max)
    end
end

function get_vehicle_team_color(team)
    if g_is_vehicle_team_colors then
        return update_get_team_color(team)
    elseif team == update_get_screen_team_id() then
        return color_friendly
    else
        return color_enemy
    end
end

function get_island_team_color(team)
    if g_is_island_team_colors or team == 0 then
        return update_get_team_color(team)
    elseif team == update_get_screen_team_id() then
        return color_friendly
    else
        return color_enemy
    end
end

function render_dashed_line(x0, y0, x1, y1, col)
    local line_length = math.max(vec2_dist(vec2(x0, y0), vec2(x1, y1)), 1)
    local normal = vec2((x1 - x0) / line_length, (y1 - y0) / line_length)
    local segment_length = 3
    local segment_spacing = 3
    local step = segment_length + segment_spacing
    local offset = (g_animation_time / 2) % step

    for cursor = offset, line_length, step do
        local length = math.min(segment_length, line_length - cursor)

        update_ui_line(x0 + normal:x() * cursor, y0 + normal:y() * cursor, x0 + normal:x() * (cursor + length), y0 + normal:y() * (cursor + length), col)
    end
end


function compass_update(screen_w, screen_h, ticks)
    if update_screen_overrides(screen_w, screen_h, ticks)  then return end

    if screen_w > 128 then
        update_ui_push_offset(screen_w / 4, screen_h / 5)
    end

    update_ui_image(0, 0, atlas_icons.screen_compass_background, color_white, 0)
    update_ui_rectangle(50, 28, 28, 12, color_white)
    update_ui_rectangle(51, 29, 26, 10, color_black)

    update_ui_line(11, 27, 41, 27, color8(205, 8, 246, 255))
    update_ui_line(87, 27, 117, 27, color8(205, 8, 246, 255))

    local this_vehicle = update_get_screen_vehicle()

    if this_vehicle:get() then
        local vdef = this_vehicle:get_definition_index()
        local this_vehicle_bearing = this_vehicle:get_rotation_y();
        local this_vehicle_roll = this_vehicle:get_rotation_z();
        local this_vehicle_pitch = this_vehicle:get_rotation_x();

        if(this_vehicle_bearing < 0.0) then
            this_vehicle_bearing = this_vehicle_bearing + (math.pi * 2.0)
        end

        update_ui_image_rot(26 + 38, 42 + 38, atlas_icons.screen_compass_dial_pivot, color_white, -this_vehicle_bearing)

        if vdef == e_game_object_type.chassis_carrier then
            update_ui_image_rot(26, 26, atlas_icons.screen_compass_tilt_side_pivot, color_white, -this_vehicle_roll)

            update_ui_image_rot(102, 26, atlas_icons.screen_compass_tilt_front_pivot, color_white, -this_vehicle_pitch)
        end
        update_ui_text(0, 30, string.format("%.0f", math.floor(math.deg( this_vehicle_bearing )) % 360), 128, 1, color_white, 0)

        local waypoint_count = this_vehicle:get_waypoint_count()

        if waypoint_count > 0 then
            local waypoint = this_vehicle:get_waypoint(0)
            local waypoint_pos = waypoint:get_position_xz()

            local vehicle_pos = this_vehicle:get_position_xz()

            local delta_pos_x = waypoint_pos:x() - vehicle_pos:x()
            local delta_pos_y = waypoint_pos:y() - vehicle_pos:y()

            local waypoint_angle = (math.pi / 2) - math.atan(delta_pos_y, delta_pos_x)
            if waypoint_angle < 0 then waypoint_angle = waypoint_angle + (math.pi * 2.0) end

            update_ui_rectangle(50, 14, 28, 12, g_color_waypoint)
            update_ui_rectangle(51, 15, 26, 10, color_black)

            update_ui_text(0, 16, string.format("%.0f", math.floor(math.deg( waypoint_angle )) % 360), 128, 1, g_color_waypoint, 0)

            local dir = (waypoint_angle - this_vehicle_bearing) + (math.pi / 2)
            local dir_x = math.cos(dir) * -38
            local dir_y = math.sin(dir) * -38

            update_ui_line(26 + 38, 42 + 38, 26 + 38 + dir_x, 42 + 38 + dir_y, g_color_waypoint)
        end
        if get_is_vehicle_land(vdef) and screen_w > 128 then
            local health = this_vehicle:get_hitpoints()
            local full_health = this_vehicle:get_total_hitpoints()
            local health_factor = health / full_health
            update_ui_text(128, 10, string.format("%d/%d", health, full_health),
                    64, 1, color_white, 0, 0
            )
            update_ui_rectangle(128, 22,
                    math.floor(100 * health_factor),
                    24, color_friendly)
            update_ui_rectangle_outline(128, 22,
            100, 24, color_white)

            -- fuel
            local fuel = this_vehicle:get_fuel_factor()

            update_ui_text(128, 60, string.format("FUEL: %d%%", round_int(fuel * 100)),
                    64, 1, color_white, 0, 0
            )
            update_ui_rectangle(128, 74,
                    math.floor(100 * fuel),
                    24, color_friendly)
            update_ui_rectangle_outline(128, 74,
            100, 24, color_white)
        end

        if not g_is_carrier then
            update_ui_rectangle(
                    0, 0, 47, 47, color_black
            )
            update_ui_rectangle(
                    82, 1, 41, 41, color_black
            )
        end

        if screen_h > 128 then
            -- HD mode!
            update_ui_text_scale(0, screen_h * 0.5,
                    string.format("%03d", math.floor(math.deg( this_vehicle_bearing )) % 360), screen_w /2, 1, color_white, 0, 4)
        end

    end

    update_ui_image(26, 42, atlas_icons.screen_compass_dial_overlay, color_white, 0)

    if screen_w > 128 then
        update_ui_pop_offset()
    end
end

local m_pi = math.pi
local m_2pi = m_pi * 2
local m_pi_4 = m_pi / 4
local m_pi_2 = m_pi / 2
local m_atan = math.atan
local m_tan = math.tan
local m_abs = math.abs
local m_deg = math.deg
local m_floor = math.floor

function helm_hud_pos_to_screen(hdg, pos, pos_b, frust_len)
    local delta_pos_x = pos_b:x() - pos:x()
    local delta_pos_y = pos_b:y() - pos:y()
    local waypoint_angle = ((m_pi / 2) - m_atan(delta_pos_y, delta_pos_x)) % m_2pi
    local waypoint_delta = (waypoint_angle - hdg) % m_2pi

    local bear_size = m_abs(((m_pi + waypoint_delta) % m_2pi) - m_pi)
    if bear_size < m_pi_4 then
        local h_offset = m_tan(waypoint_delta) * frust_len
        return h_offset
    end
    return nil
end

function helm_hud_update_prelaunch(vehicle, screen_w, screen_h)
    local crr_name = get_ship_name(vehicle)
    update_ui_text_scale(0, screen_h / 7,
            string.format("%s %s", update_get_loc(e_loc.upp_crr), crr_name),
            screen_w, 1, color_white, 0, 3)
    local cy = screen_h // 4.1
    update_ui_line(50, cy, screen_w - 50, cy, color_white)

    -- show a table of teams who have players and ready states
    local cx = 15
    update_ui_rectangle_outline(cx -3, cy, screen_w - cx - 3, screen_h - cy, color_white)
    cy = cy + 5
    cy = 5 + cy + update_ui_text(cx, cy, update_get_loc(e_loc.upp_teams), screen_w, 0, color_white, 0)

    -- find all the carriers with human crew and show ready/launch states

    local vehicle_count = update_get_map_vehicle_count()
    for i = 0, vehicle_count - 1 do
        local v = update_get_map_vehicle_by_index(i)
        if v and v:get() then
            if v:get_definition_index() == e_game_object_type.chassis_carrier then
                -- is a carrier
                local v_team = v:get_team()
                local docked = get_vehicle_docked(v)
                local vname = get_ship_name(v)
                update_ui_text(cx, cy, string.format("%d %s", v_team, vname), screen_w, 0, update_get_team_color(v_team), 0)
                if get_team_has_humans(v_team) then
                    local ready = rev_get_team_ready(v_team)
                    if ready then
                        update_ui_text(screen_w // 3, cy, update_get_loc(e_loc.upp_ready), screen_w, 0, color_status_dark_red, 0)
                    end
                end
                if docked then
                    update_ui_text( 2 * screen_w // 3, cy, update_get_loc(e_loc.upp_docked), screen_w, 0, color_white, 0)
                end
                cy = cy + 10
            end
        end
    end

end

function helm_hud_update(screen_w, screen_h, ticks)
    local eyeball_dist_px = 300
    local now = update_get_logic_tick()
    local total_units = update_get_map_vehicle_count()

    if ticks > 8 then
        return
    end

    if total_units > 300 then
        return
    end

    local day_len = 54000 -- 30 minutes in ticks
    local time = now - 8100 -- Time since midnight on the first day
    local day_time = time % day_len
    local alpha = 24
    if day_time > (day_len * 0.7) or day_time < (day_len * 0.3) then
        alpha = 128
    end

    local hud_green = color8(0, 255, 0, m_floor(alpha) % 255)
    local this_vehicle = update_get_screen_vehicle()

    if this_vehicle:get() then
        if get_vehicle_docked(this_vehicle) then
            helm_hud_update_prelaunch(this_vehicle, screen_w, screen_h)
            return
        end

        local pos = this_vehicle:get_position_xz()
        local nearest_tile = get_nearest_island_tile(pos:x(), pos:y())
        local this_vehicle_bearing = this_vehicle:get_rotation_y();
        local this_vehicle_pitch = this_vehicle:get_rotation_x();
        local this_vehicle_roll = this_vehicle:get_rotation_z();

        -- find tiles within 30km
        local near_tiles = get_nearest_tiles(pos:x(), pos:y(), 30000)

        if(this_vehicle_bearing < 0.0) then
            this_vehicle_bearing = this_vehicle_bearing + (m_pi * 2.0)
        end
        update_ui_text(
                (screen_w / 2) - 6,
                screen_h - 55,
                string.format("%03.0f", m_floor(m_deg( this_vehicle_bearing )) % 360),
                12,
                1,
                hud_green,
                0
        )

        -- draw the horizon edges

        local h = m_tan(this_vehicle_pitch) * eyeball_dist_px
        local h0 = h + (screen_h / 2) + 24  -- horizon level
        local left_y = m_tan(-this_vehicle_roll) * screen_w / 2
        --local right_y = math.tan(this_vehicle_roll) * screen_w / 2
        local horizon_green = color8(0, 255, 0, 24)
        update_ui_line(
                0, h0 + left_y,
                48, h0 + left_y * 0.9, horizon_green)

        local pitch = m_floor(m_deg( this_vehicle_pitch )) % 360
        if pitch > 30 then
            pitch = pitch - 360
        end
        -- pitch angle
        update_ui_text(
                4,
                h0 - 12 + left_y,
                string.format("%04.0f", pitch),
                18,
                1,
                hud_green,
                0)

        -- draw nearest tile(s)
        function draw_tile(mark_tile)
            -- show the island (name) on screen in line with the islands we can see out of the bridge
            -- show distance to each
            local mark_pos = mark_tile:get_position_xz()
            local tile_x_off = helm_hud_pos_to_screen(this_vehicle_bearing, pos, mark_pos, eyeball_dist_px)
            if tile_x_off ~= nil then
                local nearest_tile_dist = vec2_dist(mark_pos, pos)
                local dist_km =nearest_tile_dist / 1000
                local col = color8(hud_green:r(), hud_green:g(), hud_green:b(), hud_green:a() - m_floor(dist_km * 3.5))
                local nearest_tile_name = get_island_name(mark_tile)
                local x = tile_x_off + screen_w / 2
                local y_off = m_floor(dist_km / 2)
                local y_top = h0 - 24 - y_off
                update_ui_line(x, y_top + 10, x, h0 + 10 - y_off , col)
                update_ui_text(x, y_top,
                        string.format("%3.1fkm", dist_km),
                        48, 16, col, 0)
                update_ui_text(x, y_top - 14,
                        nearest_tile_name,
                        48, 16, col, 0)
            end
        end
        for _, near_tile in pairs(near_tiles) do
            draw_tile(near_tile)
        end

        -- draw the next waypoint
        local waypoint_count = this_vehicle:get_waypoint_count()

        if waypoint_count > 0 then
            local waypoint = this_vehicle:get_waypoint(0)
            local waypoint_pos = waypoint:get_position_xz()
            local delta_pos_x = waypoint_pos:x() - pos:x()
            local delta_pos_y = waypoint_pos:y() - pos:y()
            local waypoint_angle = (m_pi_2) - m_atan(delta_pos_y, delta_pos_x)
            if waypoint_angle < 0 then waypoint_angle = waypoint_angle + m_2pi end

            local dist = vec2_dist(pos, waypoint_pos)
            local x_off = helm_hud_pos_to_screen(this_vehicle_bearing, pos, waypoint_pos, eyeball_dist_px)
            if x_off ~= nil then
                local x = x_off + screen_w / 2
                update_ui_rectangle_outline(x - 3, h0, 5, 5, hud_green)
                update_ui_line(x, h0 - 10, x, h0 + 10, hud_green)
                update_ui_text(x - 12, h0 + 14,
                        string.format("WPT %3.1fkm", dist / 1000),
                        64, 16, hud_green, 0)
                update_ui_text(x - 12, h0 + 24,
                        string.format("%03d", m_floor(m_deg(waypoint_angle))),
                        48, 16, hud_green, 0)
            end
        end

    end

end