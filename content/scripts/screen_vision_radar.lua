g_animation_time = 0
g_zoom_level = 2
g_ranges = { 2000, 5000, 10000 }
g_range = g_ranges[g_zoom_level]
g_is_pointer_hovered = false

g_beep_counter = 0
g_is_warning_on = false
g_scroll_input_prev = 0

local math_sin = math.sin
local math_cos = math.cos
local math_atan = math.atan
local math_pi = math.pi
local math_floor = math.floor
local math_ceil = math.ceil
local math_max = math.max

function parse()
    g_zoom_level = parse_s32("zoom", g_zoom_level)
end

function begin()
    begin_load()
end

g_show_vectors = false
g_show_ids = false

function update(screen_w, screen_h, ticks) 
    g_animation_time = g_animation_time + ticks
    local highres = screen_w > 128
    local screen_vehicle_map = update_get_screen_vehicle()
    local screen_vehicle = update_get_vehicle_by_id(screen_vehicle_map:get_id())

    if screen_vehicle_map:get() == false then
        return
    end

    if update_screen_overrides(screen_w, screen_h, ticks)  then return end

    update_add_ui_interaction_special(update_get_loc(e_loc.interaction_zoom_level), e_ui_interaction_special.mouse_wheel)
    update_add_ui_interaction_special(update_get_loc(e_loc.interaction_zoom_level), e_ui_interaction_special.gamepad_dpad_ud)

    local vector_msg = "Show vectors"
    if g_show_vectors then
        vector_msg = "Hide vectors"
    end
    update_add_ui_interaction(vector_msg, e_game_input.interact_a)
    local ids_msg = "Show IDs"
    if g_show_ids then
        ids_msg = "Hide IDs"
    end
    update_add_ui_interaction(ids_msg, e_game_input.interact_b)

    local radar_attachment_index = -1
    local radar_attachment = nil

    for i = 0, screen_vehicle_map:get_attachment_count() - 1 do
        local attachment = screen_vehicle_map:get_attachment(i)

        if attachment:get() then
            if attachment:get_definition_index() == e_game_object_type.attachment_radar_awacs then
                radar_attachment_index = i
                radar_attachment = attachment
                break
            end
        end
    end

    local is_interference = screen_vehicle:get_is_attachment_radar_disabled(radar_attachment_index)
    local is_powered = true
    local is_damaged = false

    if radar_attachment and radar_attachment:get() then
        is_powered = radar_attachment:get_control_mode() ~= "off"
        is_damaged = radar_attachment:get_is_damaged()
    end

    local col = color_white
    local cx = screen_w / 2
    local cy = screen_h / 2

    local range_target = g_ranges[g_zoom_level]
    g_range = lerp(g_range, range_target, 0.4)

    local range = g_range
    local step = range / 4
    local radius = 50
    local torpedo_len = 20
    local torpedo_col = 32
    local torpedo_fade_dist = 0.1
    local sweep_interval = 120
    if highres then
        radius = 110
        torpedo_len = 90
        torpedo_col = 128
        torpedo_fade_dist = 0.15
        sweep_interval = 90
    end

    local function radar_col(a)
        local col = color8(0, 255, 0, 255)
        col:a(math_floor((col:a() / 255) * (a / 255) * 255 + 0.5))
        return col
    end

    local hostile_warning_distance = 1000
    local hostile_missile_dist = hostile_warning_distance
    local hostile_missile_type = e_game_object_type.missile_1

    update_ui_push_offset(screen_w / 2, screen_h / 2 - 4)

    local border = 20
    update_ui_line(0, -radius - border, 0, radius + border, radar_col(4))
    update_ui_line(-radius - border, 0, radius + border, 0, radar_col(4))

    for i = step, range, step do
        render_circle(0, 0, i / range * radius, radar_col(32))
    end

    if highres then
        --add tick marks at 15deg increments
        local pi_12 = math_pi / 12
        for i = 0, 24, 1 do
            local screen_dir = vec2(math_cos(i*pi_12), -math_sin(i*pi_12))
            update_ui_line(screen_dir:x() * 0.96 * radius, -screen_dir:y() * 0.96 * radius, screen_dir:x() * radius, -screen_dir:y() * radius, radar_col(32))
        end
    end

    if is_interference == false and is_damaged == false and is_powered then
        local screen_dir = screen_vehicle_map:get_direction()
        update_ui_line(0, 0, screen_dir:x() * torpedo_len, -screen_dir:y() * torpedo_len, radar_col(torpedo_col))

        if screen_vehicle:get_is_carrier_torpedo_enabled() then
            local torpedo_bearing = screen_vehicle:get_carrier_torpedo_bearing() / 180 * math_pi - math_pi / 2
            local screen_dir_torpedo = vec2(math_cos(torpedo_bearing), -math_sin(torpedo_bearing))
            update_ui_line(0, 0, screen_dir_torpedo:x() * 200, -screen_dir_torpedo:y() * 200, color8(255, 16, 16, 32))
        end

        local angle = g_animation_time / sweep_interval * math_pi * 2
        local radar_dir = vec2(math_cos(angle), math_sin(angle))
        update_ui_line(0, 0, radar_dir:x() * radius, radar_dir:y() * radius, color_white)

        local targets = get_radar_targets(range)
        local angle_fade_dist = torpedo_fade_dist

        for i = 1, #targets do
            local screen_pos = target_to_screen(targets[i].pos, range, radius)
            local dir = vec2_normal(screen_pos)

            local type = targets[i].type
            local team = targets[i].team
			local id = targets[i].id
			local target_dir = targets[i].target_dir
			--print(id)
            local is_enemy = team ~= screen_vehicle_map:get_team()

            local target_angle = vec2_angle_360(radar_dir, dir)
            local angle_factor = clamp(remap(target_angle, 0, 2 * math_pi, 0, 1 + angle_fade_dist) - angle_fade_dist, 0, 1)
            angle_factor = angle_factor ^ 3

            local target_color = iff(is_enemy, color8(255, 0, 0, math_ceil(angle_factor * 255)), radar_col(math_ceil(angle_factor * 255)))
            local target_dir_color = color8(255, 255, 255, math_ceil(angle_factor * 255))
            local target_color_off = iff(is_enemy, color8(255, 0, 0, math_ceil(angle_factor * 128)), radar_col(math_ceil(angle_factor * 128)))

            if type == 0 then
                if g_show_vectors then
                    update_ui_line(screen_pos:x(), screen_pos:y(), screen_pos:x()+target_dir:x() * 10, screen_pos:y()-target_dir:y() * 10, target_dir_color)
                end
                update_ui_image(screen_pos:x() - 2, screen_pos:y() - 2, atlas_icons.screen_radar_land, target_color, 0)
                if g_show_ids then
                    update_ui_text(screen_pos:x() + 2, screen_pos:y() + 2, id, 20, 0, target_color, 0)
                end
            elseif type == 1 then
                if g_show_vectors then
                    update_ui_line(screen_pos:x(), screen_pos:y()-1, screen_pos:x()+target_dir:x() * 10, screen_pos:y()-target_dir:y() * 10, target_dir_color)
                end
                update_ui_image(screen_pos:x() - 2, screen_pos:y() - 2, atlas_icons.screen_radar_air, target_color, 0)
                if g_show_ids then
                    update_ui_text(screen_pos:x() + 2, screen_pos:y() + 2, id, 20, 0, target_color, 0)
                end
            elseif type == 2 then
                if is_enemy then
                    if targets[i].dist < hostile_missile_dist then
                        hostile_missile_dist = targets[i].dist
                        hostile_missile_type = targets[i].data:get_definition_index()
                    end
                end

                update_ui_image(screen_pos:x() - 2, screen_pos:y() - 2, atlas_icons.screen_radar_missile, iff(is_blink_on(5), target_color, target_color_off), 0)
            end
        end
    end

    update_ui_pop_offset()

    update_ui_image(10, screen_h - 15, atlas_icons.column_controlling_peer, col, 0)
    update_ui_text(20, screen_h - 15, string.format("%.0f", range) .. update_get_loc(e_loc.upp_acronym_meters), 200, 0, col, 0)
    update_ui_image(screen_w - (6 * 8) - 2, screen_h - 15, atlas_icons.column_distance, col, 0)
    update_ui_text(0, screen_h - 15, string.format("%.0f", step) .. update_get_loc(e_loc.upp_acronym_meters), screen_w - 10, 2, col, 0)

    if is_damaged then
        render_status_label(10, screen_h / 2 - 9, screen_w - 20, 12, update_get_loc(e_loc.upp_damaged), color_status_bad, g_animation_time % 20 > 10, color_black)
    elseif is_powered == false then
        render_status_label(10, screen_h / 2 - 9, screen_w - 20, 12, update_get_loc(e_loc.upp_offline), color8(0, 16, 0, 255), g_animation_time % 20 > 10, color_black)
    elseif is_interference then
        render_status_label(10, screen_h / 2 - 9, screen_w - 20, 12, update_get_loc(e_loc.upp_interference), color_status_bad, g_animation_time % 20 > 10, color_black)
    elseif hostile_missile_dist < hostile_warning_distance then
        local blink_rate = math_floor(lerp(2, 30, math_max(0, hostile_missile_dist - 200) / (hostile_warning_distance - 200)) + 0.5)

        g_beep_counter = g_beep_counter + 1

        if g_beep_counter > blink_rate then
            g_beep_counter = 0
            g_is_warning_on = not g_is_warning_on

            if g_is_warning_on then
                update_play_sound(e_audio_effect_type.telemetry_7)
            end
        end

        if hostile_missile_type == e_game_object_type.torpedo or hostile_missile_type == e_game_object_type.torpedo_decoy then
            render_status_label(10, 5, screen_w - 20, 12, update_get_loc(e_loc.upp_torpedo), color_status_bad, not g_is_warning_on, color_black)
        else
            render_status_label(10, 5, screen_w - 20, 12, update_get_loc(e_loc.upp_missile), color_status_bad, not g_is_warning_on, color_black)
        end
    end
end

function input_event(event, action)
    if action == e_input_action.press then
        if event == e_input.down then
            g_zoom_level = math.min(g_zoom_level + 1, #g_ranges)
        elseif event == e_input.up then
            g_zoom_level = math_max(g_zoom_level - 1, 1)
        elseif event == e_input.back then
            update_set_screen_state_exit()
        elseif event == e_input.action_a then
            input_text("v")
        elseif event == e_input.action_b then
            input_text("i")
        end
    end
end

function input_axis(x, y, z, w)
    local scroll_input = 0
    if w >  0.5 then scroll_input =  1 end
    if w < -0.5 then scroll_input = -1 end
    if scroll_input ~= g_scroll_input_prev then
        if scroll_input > 0 then
            g_zoom_level = math_max(g_zoom_level - 1, 1)
        elseif scroll_input < 0 then
            g_zoom_level = math.min(g_zoom_level + 1, #g_ranges)
        end
    end
    g_scroll_input_prev = scroll_input
end

function input_pointer(is_hovered, x, y)
    g_is_pointer_hovered = is_hovered
end

function input_scroll(dy)
    if update_get_active_input_type() == e_active_input.keyboard and g_is_pointer_hovered then
        if dy > 0 then
            g_zoom_level = math_max(g_zoom_level - 1, 1)
        elseif dy < 0 then
            g_zoom_level = math.min(g_zoom_level + 1, #g_ranges)
        end
    end
end

function input_text(text)
    if text == "i" then
        if g_show_ids then
            g_show_ids = false
        else
            g_show_ids = true
        end
    elseif text == "v" then
        if g_show_vectors then
            g_show_vectors = false
        else
            g_show_vectors = true
        end
    end
end

--------------------------------------------------------------------------------
--
-- UTIL
--
--------------------------------------------------------------------------------

function target_to_screen(target_relative_pos, range, radius)
    return vec2(
        remap(target_relative_pos:x(), -range, range, -radius, radius),
        remap(target_relative_pos:y(), range, -range, -radius, radius)
    )
end

function get_radar_targets(range)
    local screen_vehicle = update_get_screen_vehicle()
    local screen_pos = screen_vehicle:get_position_xz()

    local range_sq = range * range
    local targets = {}

    -- get vehicles

    local vehicle_count = update_get_map_vehicle_count()

    for i = 0, vehicle_count - 1 do
        local vehicle = update_get_map_vehicle_by_index(i)

        if vehicle:get() and vehicle:get_attached_parent_id() == 0 and vehicle:get_id() ~= screen_vehicle:get_id() then
            local pos = vehicle:get_position_xz()
            local dist_sq = vec2_dist_sq(pos, screen_pos)

            if dist_sq < range_sq then
                local def = vehicle:get_definition_index()
                local is_air = get_is_vehicle_air(def)
                local is_sea = get_is_vehicle_sea(def)

                if is_air or is_sea then
                    if vehicle:get_is_visible() and vehicle:get_is_observation_revealed() and not get_is_vehicle_masked(vehicle) then
                        local icon_type = 0

                        if is_air then
                            icon_type = 1
                        end

                        table.insert(targets, {
                            type = icon_type,
                            team = vehicle:get_team(),
                            pos = vec2(pos:x() - screen_pos:x(), pos:y() - screen_pos:y()),
                            dist = dist_sq ^ 0.5,
                            data = vehicle,
							id = vehicle:get_id(),
							target_dir = vehicle:get_direction()
                        })
                    end
                end
            end
        end
    end

    -- get missiles

    local missile_count = update_get_missile_count()
    
    for i = 0, missile_count - 1 do
        local missile = update_get_missile_by_index(i)

        if missile:get() and missile:get_is_visible() then
            local pos = missile:get_position_xz()
            local dist_sq = vec2_dist_sq(pos, screen_pos)
            
            local missile_type = missile:get_definition_index()

            if missile_type ~= e_game_object_type.torpedo_noisemaker and missile_type ~= e_game_object_type.torpedo_sonar_buoy then
                if dist_sq < range_sq then
                    table.insert(targets, {
                        type = 2,
                        team = missile:get_team(),
                        pos = vec2(pos:x() - screen_pos:x(), pos:y() - screen_pos:y()),
                        dist = dist_sq ^ 0.5,
                        data = missile,
                    })
                end
            end
        end
    end

    return targets
end

function render_circle(x, y, radius, col)
    local steps = math_max(math_floor(radius), 8)
    local step = math_pi * 2 / steps
    
    for i = 0, steps - 1 do
        local angle = i * step
        local angle_next = angle + step
        update_ui_line(
            math_ceil(x + math_cos(angle) * radius), 
            math_ceil(y + math_sin(angle) * radius), 
            math_ceil(x + math_cos(angle_next) * radius),
            math_ceil(y + math_sin(angle_next) * radius),
            col
        )
    end
end

function vec2_angle_360(v0, v1)
    local dot = v0:x() * v1:x() + v0:y() * v1:y()
    local det = v0:x() * v1:y() - v0:y() * v1:x()
    local angle = math_atan(det, dot)

    if angle < 0 then
        angle = angle + 2 * math_pi
    end

    return angle
end

function is_blink_on(rate, is_pulse)
    if is_pulse == nil or is_pulse == false then
        return g_animation_time % (2 * rate) > rate
    else
        return g_animation_time % (2 * rate) == 0
    end
end

function render_status_label(x, y, w, h, text, col, is_outline, back_col)
    x = math_floor(x)
    y = math_floor(y)

    update_ui_push_offset(x, y)
    
    if is_outline then
        update_ui_rectangle(0, 0, w, h, color_black)
        update_ui_rectangle_outline(0, 0, w, h, col)
        update_ui_text(0, h / 2 - 4, text, math_ceil(w / 2) * 2, 1, col, 0) 
    else
        update_ui_rectangle(0, 0, w, h, col)
        update_ui_text(0, h / 2 - 4, text, math_ceil(w / 2) * 2, 1, back_col or color_black, 0)    
    end

    update_ui_pop_offset()
end
