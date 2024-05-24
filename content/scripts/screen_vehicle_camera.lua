g_region_icon = 0

g_cam_x = 0
g_cam_y = 0
g_cam_z = 0
g_cam_rot = 0

function begin()
    begin_load()
    g_region_icon = begin_get_ui_region_index("microprose")
end

g_rwr_last_tick = 0
g_rwr_last_nails = 0
g_rwr_nails_interval = 7 * 30
g_rwr_spike_interval = 1 * 30
g_spike_tone_count = 0
g_nail_tone_count = 0


function play_nails_tone()
    update_play_sound(e_audio_effect_type.telemetry_5)
    update_play_sound(e_audio_effect_type.telemetry_5)
    update_play_sound(e_audio_effect_type.telemetry_5)
    update_play_sound(e_audio_effect_type.telemetry_5)
    update_play_sound(e_audio_effect_type.telemetry_5)
end

function play_tracking_tone()
    if g_nail_tone_count % 3 == 0 then
        play_nails_tone()
    elseif g_nail_tone_count % 3 == 1 then
        play_nails_tone()
    end
    g_nail_tone_count = g_nail_tone_count + 1
end

function play_spike_tone()
    g_nail_tone_count = g_nail_tone_count + 1
    play_nails_tone()
end


function aircraft_rwr_sfx(vehicle)
    -- dont render unless we are the seat
    local self_peer = update_get_local_peer_id()
    local pilot_peer = vehicle:get_controlling_peer_id()
    if self_peer ~= pilot_peer then
        return
    end


    local now = update_get_logic_tick()
    local prev = g_rwr_last_tick
    if now > prev + g_rwr_spike_interval then
        g_rwr_last_tick = now
        refresh_modded_radar_cache()
        local radar, dist = get_nearest_hostile_radar(vehicle:get_id())
        if radar and dist < get_rwr_range() then
            if dist < 10000 then
                -- spike - double chirp
                if dist > 5000 then
                    play_tracking_tone()
                else
                    play_spike_tone()
                end
                return
            else
                if now > g_rwr_last_nails + g_rwr_nails_interval then
                    -- nails
                    play_nails_tone()
                    g_rwr_last_nails = now
                end
            end
        end
    elseif prev + g_rwr_nails_interval < now then
        local nails = vehicle:get_is_visible_by_enemy()
        if nails then
            update_play_sound(e_audio_effect_type.telemetry_5)
            update_play_sound(e_audio_effect_type.telemetry_5)
            update_play_sound(e_audio_effect_type.telemetry_5)
            return
        end
    end
end

function update(screen_w, screen_h, ticks) 
    update_set_screen_background_type(0)
    if update_screen_overrides(screen_w, screen_h, ticks)  then return end

    local screen_vehicle = update_get_screen_vehicle()
    if screen_vehicle and screen_vehicle:get() then
        if get_has_rwr(screen_vehicle) then
            aircraft_rwr_sfx(screen_vehicle)
            return
        end
    end

    update_set_screen_background_type(9)
    update_set_screen_camera_pos_orientation(g_cam_x, g_cam_y, g_cam_z, g_cam_rot)
    update_set_screen_camera_attach_vehicle(13, 0)

    local function render_crosshair(x, y, size_inner, size_outer)
        update_ui_push_offset(x, y)
        update_ui_rectangle(-size_outer, -size_outer, size_inner, 1, color_black)
        update_ui_rectangle(-size_outer, -size_outer, 1, size_inner, color_black)
        update_ui_rectangle(-size_outer, size_outer, size_inner, 1, color_black)
        update_ui_rectangle(-size_outer, size_outer, 1, -size_inner, color_black)
        update_ui_rectangle(size_outer, -size_outer, -size_inner, 1, color_black)
        update_ui_rectangle(size_outer, -size_outer, 1, size_inner, color_black)
        update_ui_rectangle(size_outer, size_outer, -size_inner, 1, color_black)
        update_ui_rectangle(size_outer, size_outer, 1, -size_inner, color_black)
        update_ui_pop_offset()
    end

    render_crosshair(screen_w / 2, screen_h / 2, 16, 64)
    render_crosshair(screen_w / 2, screen_h / 2, 8, 16)
    render_crosshair(screen_w / 2, screen_h / 2, 4, 0)
end

function input_event(event, action)
    if action == e_input_action.release then
        if event == e_input.back then
            update_set_screen_state_exit()
        end
    end
end

function input_axis(x, y, z, w)
    local forward_x = math.cos(-g_cam_rot) * x * 10
    local forward_z = math.sin(-g_cam_rot) * x * 10
    local side_x = math.cos(-g_cam_rot + math.pi * 0.5) * y * 10
    local side_z = math.sin(-g_cam_rot + math.pi * 0.5) * y * 10

    g_cam_x = g_cam_x + forward_x + side_x
    g_cam_z = g_cam_z + forward_z + side_z
    g_cam_y = g_cam_y + w * 10
    g_cam_rot = g_cam_rot + z * 0.1
end
