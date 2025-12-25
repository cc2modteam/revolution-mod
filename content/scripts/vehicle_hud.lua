local math_pi = math.pi
local math_2pi = 2 * math_pi
local math_pi_2 = math_pi / 2
local math_pi_4 = math_pi / 4
local math_cos = math.cos
local math_sin = math.sin
local math_max = math.max
local math_min = math.min
local math_abs = math.abs
local math_floor = math.floor

local color_red = color8(255, 0, 0, 200)
local color_yellow = color8(255, 255, 0, 200)

g_is_connected = false
g_selected_attachment_index = -1
g_selected_target_id = -1
g_animation_time = 0
g_selected_target_id = 0
g_selected_target_type = 0
g_is_input_cycle_target_next = false
g_is_input_cycle_target_prev = false
g_is_map_overlay = false
g_render_rwr = false
g_hide_horizon_ladder = false
g_active_attachment_time = 0
g_is_hud = true
g_nearest_hostile_ew_radar_id = -1
g_nearest_hostile_ew_radar_range = 99999

g_attachment_factors = {}
g_attachment_info_factor = 0
g_attachment_link_factor = 0
g_is_attachment_linked = false

g_selected_attachment_index_prev = -1
g_selected_definition_index_prev = -1
g_selected_camera_weapon_prev = 0
g_time_camera_weapon_set = 0
g_weapon_list_factor = 0

g_attachment_slot_size = vec2(18, 19)

g_gun_funnel_history = {}
g_gun_funnel_sample_time = 0

g_is_render_speed = true
g_is_render_altitude = true
g_is_render_fuel = true
g_is_render_hp = true
g_is_render_control_mode = true
g_is_render_compass = true
g_compass_pos = nil

g_last_carrier_health_tick = 0
g_carrier_health = {}
g_carrier_damaged = {}
g_last_hud_update_tick = 0
g_update_delta = 1000

g_notification = {
    notification_vehicle_control_mode = {
        text = "",
        time = 0,
        col = color8(0, 255, 0, 255)
    },
    notification_attachment_control_mode = {
        text = "",
        time = 0,
        col = color8(0, 255, 0, 255)
    },
    notification_support_order_mode = {
        text = "",
        time = 0,
        col = color8(0, 255, 0, 255)
    },

    time = 0,

    vehicle_id_prev = 0,
    vehicle_control_mode_prev = "",
    attachment_control_mode_prev = "",
    selected_attachment_index_prev = -1,
    attachment_target_data_state_prev = nil,

    clear = function(self)
        self.notification_vehicle_control_mode.text = ""
        self.notification_attachment_control_mode.text = ""
        self.notification_support_order_mode.text = ""
        self.attachment_target_data_state_prev = nil
    end,

    update = function(self, delta_time, vehicle)
        self.time = self.time + delta_time

        if g_is_connected and vehicle:get() then
            local vehicle_id = vehicle:get_id()
            local vehicle_control_mode = vehicle:get_control_mode()
            local attachment_control_mode = ""
            local attachment_target_data_state = attachment_target_data_state_prev

            if vehicle_control_mode_prev ~= vehicle_control_mode then
                local notification_text = get_control_mode_loc(vehicle_control_mode) .. ": " .. update_get_loc(e_loc.hud_notification_vehicle)
                self:set_notification(self.notification_vehicle_control_mode, notification_text, get_control_mode_color(vehicle_control_mode))
            end

            local attachment = vehicle:get_attachment(g_selected_attachment_index)

            if attachment:get() then
                attachment_control_mode = attachment:get_control_mode()

                if attachment:get_is_weapon_target_data_set() then
                    attachment_target_data_state = attachment:get_weapon_target_state()
                else
                    attachment_target_data_state = e_team_target_state.cancelled
                end

                if selected_attachment_index_prev == g_selected_attachment_index and attachment:get_definition_index() ~= e_game_object_type.attachment_camera_vehicle_control then
                    if attachment_control_mode_prev ~= attachment_control_mode then
                        local notification_text = get_control_mode_loc(attachment_control_mode) .. ": " .. get_attachment_display_name(vehicle, attachment)
                        self:set_notification(self.notification_attachment_control_mode, notification_text, get_control_mode_color(attachment_control_mode))
                    end
                end
            end

            if attachment_target_data_state_prev ~= nil and attachment_target_data_state_prev ~= attachment_target_data_state then
                if (attachment_target_data_state_prev == e_team_target_state.pending or attachment_target_data_state_prev == e_team_target_state.active) and attachment_target_data_state == e_team_target_state.cancelled then
                    self:set_notification(self.notification_support_order_mode, update_get_loc(e_loc.support_cancelled), color8(255, 255, 0, 255))
                elseif attachment_target_data_state == e_team_target_state.complete then
                    self:set_notification(self.notification_support_order_mode, update_get_loc(e_loc.support_complete), color8(0, 255, 0, 255))
                elseif attachment_target_data_state == e_team_target_state.failed then
                    self:set_notification(self.notification_support_order_mode, update_get_loc(e_loc.support_failed), color8(255, 0, 0, 255))
                elseif attachment_target_data_state == e_team_target_state.pending or (attachment_target_data_state_prev ~= e_team_target_state.pending and attachment_target_data_state == e_team_target_state.active) then
                    self:set_notification(self.notification_support_order_mode, update_get_loc(e_loc.requesting_support).."...", color8(0, 255, 0, 255))
                end
            end

            if vehicle_id_prev ~= vehicle_id then
                self:clear()
            end

            vehicle_id_prev = vehicle_id
            vehicle_control_mode_prev = vehicle_control_mode
            attachment_control_mode_prev = attachment_control_mode
            selected_attachment_index_prev = g_selected_attachment_index
            attachment_target_data_state_prev = attachment_target_data_state
        else
            self:clear()
        end
    end,

    set_notification = function(self, notification, text, col)
        notification.text = text
        notification.time = self.time
        notification.col = col
    end,
}

function begin()
    begin_load()

    for i = 0, 15, 1 do
        g_attachment_factors[i] = 0
    end
end


--------------------------------------------------------------------------------
--
-- UPDATE
--
--------------------------------------------------------------------------------
function update(screen_w, screen_h, tick_fraction, delta_time, local_peer_id, vehicle, map_data)
    if g_debug_enabled then
        local st, err = pcall(real_update, screen_w, screen_h, tick_fraction, delta_time, local_peer_id, vehicle, map_data)
        if not st then
            print(err)
        end
    else
        real_update(screen_w, screen_h, tick_fraction, delta_time, local_peer_id, vehicle, map_data)
    end
    if vehicle and vehicle:get() then
        local current_vid = vehicle:get_id()
        if current_vid ~= g_last_vid then
            g_last_vid = vehicle:get_id()
            g_render_ladder = true
        end
    end
end

function get_nearest_hostile_ew_radar()
    if g_nearest_hostile_ew_radar_id > -1 then
        local v = update_get_map_vehicle_by_id(g_nearest_hostile_ew_radar_id)
        if v and v:get() then
           return v
        end
    end
    return nil
end

function carrier_health(screen_vehicle, screen_w, screen_h, now)
    local health_tick_delta = now - g_last_carrier_health_tick
    if screen_vehicle and health_tick_delta > 5 and screen_vehicle:get() then
        local our_team = screen_vehicle:get_team_id()
        -- every 1 sec
        g_last_carrier_health_tick = now

        if g_update_delta > 0 and g_update_delta < 3 then
            -- check for carrier health changes
            for vid, h in pairs(g_carrier_health) do
                local carrier = update_get_map_vehicle_by_id(vid)
                if carrier and carrier:get() then
                    local hdiff = h - carrier:get_hitpoints()
                    if hdiff > 100 then
                        -- light bomb is approx 170
                        -- 100mm gun is approx 300
                        g_carrier_damaged[vid] = {dmg = hdiff, tick = now}
                    end
                else
                    g_carrier_damaged[vid] = nil
                end
            end
        end

        g_carrier_health = {}
        for _, vehicle in iter_vehicles(nil) do
            if vehicle and vehicle:get() then
                local vteam = vehicle:get_team_id()
                if vteam == our_team then
                    local vdef = vehicle:get_definition_index()
                    if vdef == e_game_object_type.chassis_carrier then
                        local vid = vehicle:get_id()
                        local hp = vehicle:get_hitpoints()
                        g_carrier_health[vid] = hp
                    end
                end
            end
        end
    end

    -- render carrier damage message
    local dmg_message = string.format("%s %s!", update_get_loc(e_loc.upp_crr), update_get_loc(e_loc.upp_damaged))
    local dmg_ttl = 60
    for vid, data in pairs(g_carrier_damaged) do
        local elapsed = now - data.tick
        local dmg_remain = dmg_ttl - elapsed
        local dmg_remain_factor = dmg_remain / dmg_ttl
        if elapsed > dmg_ttl then
            g_carrier_damaged[vid] = nil
        else
            if data.dmg > 100 then
                -- minor damage, show the message

                local shake_x = 23
                local shake_y = 8
                if data.dmg > 130 then
                    if data.dmg > 200 then
                        shake_x = 40
                        shake_y = 15
                    end

                    shake_x = round_int(shake_x * dmg_remain_factor)
                    shake_y = round_int(shake_y * dmg_remain_factor)

                    local color_blk = color8(0, 0, 0, 255)
                    -- shake HUD
                    local dx = math.random(-1 * shake_x, shake_x)
                    local dy = math.random(-1 * shake_y, shake_y)
                    if dy > 0 then
                        update_ui_rectangle(0, 0, screen_w, dy, color_blk)
                    else
                        update_ui_rectangle(0, screen_h + dy, screen_w, dy * -1, color_blk)
                    end
                    if dx > 0 then
                        update_ui_rectangle(0, 0, dx, screen_h, color_blk)
                    else
                        update_ui_rectangle(screen_w + dx, 0, dx * -1, screen_h, color_blk)
                    end
                    update_ui_push_offset(dx, dy)

                    if elapsed % 30 < 15 then
                        update_ui_text(screen_w / 3, (screen_h - 20) / 3, dmg_message, 120, 1, color_enemy, 0)
                    end
                end
            end
        end
    end

end

function real_update(screen_w, screen_h, tick_fraction, delta_time, local_peer_id, vehicle, map_data)
    g_screen_w = screen_w
    g_screen_h = screen_h
    local now = update_get_logic_tick()
    g_update_delta = now - g_last_hud_update_tick
    g_last_hud_update_tick = now

    carrier_health(vehicle, screen_w, screen_h, now)
    update_animations(delta_time, vehicle)
    g_notification:update(delta_time, vehicle)

    g_is_attachment_linked = false

    g_is_render_speed = true
    g_is_render_altitude = true
    g_is_render_fuel = true
    g_is_render_hp = true
    g_is_render_control_mode = true
    g_is_render_compass = true

    g_map_toggle = g_is_map_overlay ~= g_last_map_overlay
    g_last_map_overlay = g_is_map_overlay
    if g_map_toggle then
        -- detect double taps
        local diff = now - g_toggle_map_last_tick
        g_toggle_map_last_tick = now
        if diff < 10 then
            -- rapid tap
            g_hide_horizon_ladder = not g_hide_horizon_ladder
            g_camera_clear = not g_camera_clear
            update_set_screen_background_type(0)
        end
    end

    if g_camera_clear and get_is_spectator_mode() then
        -- render no hud
        return
    end

    if not g_is_connected or not vehicle or not vehicle:get() then
        update_add_ui_interaction(update_get_loc(e_loc.interaction_cancel), e_game_input.back)
    elseif g_is_map_overlay == false then
        update_add_ui_interaction(update_get_loc(e_loc.interaction_exit), e_game_input.back)
    end

    if g_is_connected and vehicle and vehicle:get() then
        g_nearest_hostile_ew_radar_range = 0
        local v_def = vehicle:get_definition_index()
        if get_is_vehicle_air(v_def) then
            g_render_rwr = get_has_rwr(vehicle)
            update_modded_radar_list(true)
            local nearest_radar, radar_dist = get_nearest_hostile_radar(vehicle:get_id())
            if nearest_radar ~= nil then
                if radar_dist > get_rwr_range() then
                    nearest_radar = nil
                    radar_dist = 0
                else
                    g_nearest_hostile_ew_radar_id = nearest_radar:get_id()
                end
                g_nearest_hostile_ew_radar_range = radar_dist
            end
        else
            g_render_rwr = false
        end

        if do_comms_error(vehicle, screen_w, screen_h) then
            return
        end

        Variometer:update(vehicle)
        local attachment = vehicle:get_attachment(g_selected_attachment_index)
        local is_attachment_render_center = false
        local is_render_awacs = false

        if attachment and (
                attachment:get_definition_index() == e_game_object_type.attachment_radar_awacs
                or
                attachment:get_definition_index() == e_game_object_type.attachment_radar_golfball
        ) then
            is_render_awacs = true
        end

        if not is_render_awacs and not g_is_map_overlay then
            if vehicle:get_attachment_count() > 1 and vehicle:get_definition_index() ~= e_game_object_type.chassis_carrier then
                if update_get_active_input_type() == e_active_input.gamepad then
                    update_add_ui_interaction(update_get_loc(e_loc.interaction_select_attachment), e_game_input.select_attachment_prev)
                elseif update_get_active_input_type() == e_active_input.keyboard then
                    update_add_ui_interaction(update_get_loc(e_loc.interaction_select_attachment), e_game_input.select_attachment_1)
                end
            end

            update_add_ui_interaction(update_get_loc(e_loc.interaction_show_map), e_game_input.map_overlay)

            if attachment:get() then
                if attachment:get_is_controllable() then
                    local control_mode = attachment:get_control_mode()

                    if control_mode == "auto" then
                        update_add_ui_interaction(update_get_loc(e_loc.interaction_manual), e_game_input.toggle_control_mode)
                    elseif control_mode == "manual" then
                        update_add_ui_interaction(update_get_loc(e_loc.interaction_auto), e_game_input.toggle_control_mode)

                        if attachment:get_is_controlling_peer() and attachment:get_definition_index() == e_game_object_type.attachment_hardpoint_missile_tv and attachment:get_is_viewing_sub_camera() then
                            update_add_ui_interaction_special(update_get_loc(e_loc.interaction_throttle), e_ui_interaction_special.air_throttle)
                            update_add_ui_interaction_special(update_get_loc(e_loc.interaction_roll), e_ui_interaction_special.air_roll)
                            update_add_ui_interaction_special(update_get_loc(e_loc.interaction_pitch), e_ui_interaction_special.air_pitch)
                            update_add_ui_interaction_special(update_get_loc(e_loc.interaction_yaw), e_ui_interaction_special.air_yaw)
                        end

                        if attachment:get_ammo_capacity() > 0 then
                            update_add_ui_interaction(update_get_loc(e_loc.interaction_fire), e_game_input.attachment_fire)
                        end
                    end
                end
            end

            local attachment_control_camera = vehicle:get_attachment(0)

            if attachment_control_camera:get() and attachment_control_camera:get_definition_index() == e_game_object_type.attachment_camera_vehicle_control then
                if vehicle:get_control_mode() == "manual" and attachment_control_camera:get_controlling_peer_id() == local_peer_id then
                    if get_is_vehicle_air(vehicle:get_definition_index()) then
                        update_add_ui_interaction_special(update_get_loc(e_loc.interaction_throttle), e_ui_interaction_special.air_throttle)
                        update_add_ui_interaction_special(update_get_loc(e_loc.interaction_roll), e_ui_interaction_special.air_roll)
                        update_add_ui_interaction_special(update_get_loc(e_loc.interaction_pitch), e_ui_interaction_special.air_pitch)
                        update_add_ui_interaction_special(update_get_loc(e_loc.interaction_yaw), e_ui_interaction_special.air_yaw)
                    else
                        update_add_ui_interaction_special(update_get_loc(e_loc.interaction_throttle), e_ui_interaction_special.land_throttle)
                        update_add_ui_interaction_special(update_get_loc(e_loc.interaction_steer), e_ui_interaction_special.land_steer)
                    end
                end
            end
        else
            update_add_ui_interaction(update_get_loc(e_loc.interaction_hide_map), e_game_input.map_overlay)
        end

        if not is_render_awacs and not g_is_map_overlay then
            if attachment:get() then
                if attachment:get_definition_index() < e_game_object_type.count then
                    render_attachment_info(vec2(10, screen_h / 2 - 80), map_data, vehicle, attachment, 255, screen_w, screen_h)
                    is_render_center = render_attachment_hud(screen_w, screen_h, map_data, tick_fraction, vehicle, attachment, local_peer_id)
                end
            end

            local def = vehicle:get_definition_index()

            if def == e_game_object_type.chassis_air_wing_light
            or def == e_game_object_type.chassis_air_wing_heavy
            or def == e_game_object_type.chassis_air_rotor_light
            or def == e_game_object_type.chassis_air_rotor_heavy
            then
                render_flight_hud(screen_w, screen_h, is_render_center == false, vehicle)
            end

            if def == e_game_object_type.chassis_land_wheel_light
            or def == e_game_object_type.chassis_land_wheel_medium
            or def == e_game_object_type.chassis_land_wheel_heavy
            or def == e_game_object_type.chassis_land_wheel_mule
            or def == e_game_object_type.chassis_deployable_droid
            then
                render_ground_hud(screen_w, screen_h, vehicle)
            end

            if def == e_game_object_type.chassis_sea_barge
            or def == e_game_object_type.chassis_sea_ship_light
            or def == e_game_object_type.chassis_sea_ship_heavy
            then
                render_barge_hud(screen_w, screen_h, vehicle)
            end

            if def == e_game_object_type.chassis_carrier then
                render_turret_hud(screen_w, screen_h, vehicle)
            end

            if def == e_game_object_type.chassis_land_turret then
                render_turret_hud(screen_w, screen_h, vehicle)
            end
        end

        render_attachment_hotbar(screen_w, screen_h, vehicle)
        render_notification(screen_w, screen_h)

        -- render_vehicle_info(vec2(screen_w - 100, screen_h - 65), vehicle)

        update_set_screen_background_type(0)

        if g_is_map_overlay or is_render_awacs then
            local map_x = 12
            local map_y = 32
            local map_w = screen_w - 25
            local map_h = screen_h - 63

            update_set_screen_background_clip(map_x, screen_h - map_y - map_h, map_w, map_h)
            update_set_screen_background_type(8)
            update_set_screen_background_tile_color_custom(color8(64, 64, 64, 255))
            update_set_screen_background_color(color8(0, 0, 0, 64))

            update_ui_push_clip(map_x, map_y, map_w, map_h)
            render_map_details(map_x, map_y, map_w, map_h, screen_w, screen_h, vehicle, attachment)
            update_ui_pop_clip()

            update_ui_rectangle_outline(map_x, map_y, map_w, map_h, color8(0, 255, 0, 255))
        end
    else
        render_connecting_overlay(screen_w, screen_h)
    end
end

function update_animations(delta_time, vehicle)
    local selected_definition_index = -1

    if vehicle:get() and vehicle:get_attachment(g_selected_attachment_index):get() then
        local selected_attachment = vehicle:get_attachment(g_selected_attachment_index)
        selected_definition_index = selected_attachment:get_definition_index()

        local weapon_type = selected_attachment:get_weapon_target_type()

        if weapon_type ~= g_selected_camera_weapon_prev then
            g_time_camera_weapon_set = g_animation_time
            g_selected_camera_weapon_prev = weapon_type
        end
    end
    
    local anim_speed = 0.005
    
    g_animation_time = g_animation_time + delta_time
    g_active_attachment_time = g_active_attachment_time + delta_time

    for i = 0, 10, 1 do
        if g_selected_attachment_index == i then
            g_attachment_factors[i] = math.max(0.0, math.min(g_attachment_factors[i] + anim_speed * delta_time, 1.0))
        else
            g_attachment_factors[i] = math.max(0.0, math.min(g_attachment_factors[i] - anim_speed * delta_time, 1.0))
        end
    end

    local anim_speed_info = 0.0015
    g_attachment_info_factor = math.min(g_attachment_info_factor + anim_speed_info * delta_time, 1.0)

    local attachment_link_factor_target = iff(g_is_attachment_linked, 1, 0)
    g_attachment_link_factor = clamp(g_attachment_link_factor + clamp(attachment_link_factor_target - g_attachment_link_factor, -anim_speed * delta_time, anim_speed * delta_time), 0.0, 1.0)

    if g_selected_attachment_index_prev ~= g_selected_attachment_index then
        g_attachment_info_factor = 0
        g_gun_funnel_history = {}
        g_gun_funnel_sample_time = 0
        g_active_attachment_time = 0
        g_time_camera_weapon_set = -1
    end
    
    if g_selected_definition_index_prev ~= selected_definition_index then
        g_attachment_link_factor = 0
        g_time_camera_weapon_set = -1
    end
    
    if g_time_camera_weapon_set < 0 then
        g_weapon_list_factor = 0
    else
        local weapon_list_anim_time = g_animation_time - g_time_camera_weapon_set

        if weapon_list_anim_time < 1500 then
            g_weapon_list_factor = clamp(g_weapon_list_factor + delta_time / 150, 0, 1)
        else
            g_weapon_list_factor = clamp(g_weapon_list_factor - delta_time / 150, 0, 1)
        end
    end

    g_selected_definition_index_prev = selected_definition_index
    g_selected_attachment_index_prev = g_selected_attachment_index
end


--------------------------------------------------------------------------------
--
-- MAP OVERLAY RENDERING
--
--------------------------------------------------------------------------------

g_radar_mode = 0
g_camera_mode = 0

g_camera_clear = false
g_toggle_map_last_tick = 0

g_last_map_overlay = false
g_map_toggle = false

radar_modes = {
    clear = 0,
    air_labels = 1,
    air_threats = 2,

    count = 3,
}

camera_modes = {
    map = 0,
    heatmap = 1,

    count = 2,
}

function render_map_details(x, y, w, h, screen_w, screen_h, screen_vehicle, attachment)
    local screen_vehicle_def = screen_vehicle:get_definition_index()
    local camera_pos = screen_vehicle:get_position()
    local adef = nil

    local is_viewing_sub_camera = false
    local col = color8(0, 255, 0, 255)
    local is_awacs = false
    local is_golfball = false
    local awacs_mode = false
    local radar_name = ""

    if attachment and attachment:get() then
        adef = attachment:get_definition_index()
        is_viewing_sub_camera = attachment:get_is_viewing_sub_camera()
        is_awacs = adef == e_game_object_type.attachment_radar_awacs
        is_golfball = adef == e_game_object_type.attachment_radar_golfball
        awacs_mode = is_golfball or is_awacs

        if awacs_mode then
            if is_awacs then
                radar_name = "AWACS"
            elseif is_golfball then
                radar_name = "RADAR"
            end
            if g_map_toggle then
                g_radar_mode = (g_radar_mode + 1) % radar_modes.count
            end
        end
    end

    if is_viewing_sub_camera then
        camera_pos = update_get_camera_position()
    end

    local camera_x = camera_pos:x()
    local camera_y = camera_pos:z()

    local camera_size = 5000
    if screen_vehicle_def == e_game_object_type.chassis_carrier then
        camera_size = 10000
    else
        if get_is_vehicle_air(screen_vehicle_def) then
            if screen_vehicle:get_linear_speed() > 150 then
                camera_size = 10000
            end
        end
    end

    if awacs_mode then
        update_set_screen_background_type(6)
        camera_size = 24000
    end

    if awacs_mode then
        -- range rings
        local range_ring_col = color8(255, 255, 255, 130)

        local pix_per_meter = screen_h / camera_size

        render_circle(vec2(screen_w / 2, screen_h / 2), pix_per_meter * 2000, 16, range_ring_col)
        update_ui_text((screen_w / 2) + pix_per_meter * 2000, screen_h / 2.05,
                "2000", 32, 0, range_ring_col, 0)

        render_circle(vec2(screen_w / 2, screen_h / 2), pix_per_meter * 4000, 20, range_ring_col)


        render_circle(vec2(screen_w / 2, screen_h / 2), pix_per_meter * 6000, 24, range_ring_col)
        update_ui_text((screen_w / 2) + pix_per_meter * 6000, screen_h / 2.05,
                "6000", 32, 0, range_ring_col, 0)

        render_circle(vec2(screen_w / 2, screen_h / 2), pix_per_meter * 8000, 24, range_ring_col)

        -- dark background
        update_ui_rectangle(0, 0, screen_w, screen_h, color8(8, 8, 8, 210))

        local fuel_pct = math.floor(screen_vehicle:get_fuel_factor() * 100)
        local fuel_col = col

        local anim = update_get_logic_tick() % 60

        if get_is_fuel_warning(screen_vehicle) then
            if anim < 30 then
                fuel_col = color_enemy
            end
        end
        update_ui_text(2 + x, h,
                radar_name,
                w - 10, 0, col, 3
        )

        if is_awacs then
            update_ui_text(w - 45, h - 160,
                    string.format("FUEL %d%%", fuel_pct),
                    60, 0, fuel_col, 0
            )
        end
        if awacs_mode then
            -- display the mode toggles
            local radar_mode_name = "CONTACTS"
            local mode_select_x = w - 130
            local mode_select_y = h + 20
            if g_radar_mode == radar_modes.air_labels then
                radar_mode_name = "ATC"
                mode_select_x = mode_select_x + 6
            elseif g_radar_mode == radar_modes.air_threats then
                radar_mode_name = "THREAT"
                mode_select_x = mode_select_x + 12
            else

            end
            update_ui_rectangle_outline(
                    mode_select_x - 2,
                    mode_select_y - 1,
                    9, 11, col)
            update_ui_text(w - 130,
            mode_select_y,
            "012", 64, 0, col, 0)

            update_ui_text(w - 90, mode_select_y,
                    string.format("MODE: %s", radar_mode_name),
                    90, 0, col, 0
            )
        end


    else
        update_ui_text(2 + x, h,
                string.format("scale: %5dm", camera_size / 2),
                w - 10, 0, col, 3
        )
        update_ui_line(14 + x, h + 10, 14 + x, h - 100, col)
        update_ui_text(9 + x, h + 10, "<", 1, 0, col, 3)
        update_ui_text(9 + x, h - 96, ">", 1, 0, col, 3)

    end

    update_set_screen_map_position_scale(camera_x, camera_y, camera_size)

    local function world_to_screen(x, y)
        return get_screen_from_world(x, y, camera_x, camera_y, camera_size, screen_w, screen_h)
    end

    local is_render_islands = (camera_size < (64 * 1024))
    update_set_screen_background_is_render_islands(is_render_islands)

    -- render tiles

    if is_render_islands then
        for _, tile in iter_tiles() do
            local tile_color = tile:get_team_color()
            local position_xz = tile:get_position_xz()
            local island_name = get_island_name(tile)
            local label_x, label_y = world_to_screen(position_xz:x(), position_xz:y() + 3000)
            update_ui_text(label_x - 64, label_y - 9, island_name, 128, 1, tile_color, 0)
        end
    else
        for _, tile in iter_tiles() do
            local tile_color = tile:get_team_color()
            local position_xz = tile:get_position_xz()
            local screen_x, screen_y = world_to_screen(position_xz:x(), position_xz:y())
            update_ui_image(screen_x - 4, screen_y - 4, atlas_icons.map_icon_island, tile_color, 0)
        end
    end

    local team_color = color_friendly
    local screen_x, screen_y = world_to_screen(camera_x, camera_y)
    local heading = update_get_camera_heading()
    local fov = update_get_camera_fov()
    local cone_length = 1000
    local p1 = vec2(math.sin(heading - fov / 2) * cone_length, -math.cos(heading - fov / 2) * cone_length)
    local p2 = vec2(math.sin(heading + fov / 2) * cone_length, -math.cos(heading + fov / 2) * cone_length)
    if not awacs_mode then
        update_ui_begin_triangles()
        update_ui_add_triangle(vec2(screen_x, screen_y), vec2(screen_x + p2:x(), screen_y + p2:y()), vec2(screen_x + p1:x(), screen_y + p1:y()), color8(255, 255, 255, 5))
        update_ui_end_triangles()
    end

    local direction_len = 32

    if awacs_mode then
        direction_len = screen_vehicle:get_linear_speed() / 5
    end
    if not is_golfball then
        local p3 = vec2(math.sin(heading) * direction_len, -math.cos(heading) * direction_len)
        update_ui_line(screen_x, screen_y, screen_x + p1:x(), screen_y + p1:y(), color8(255, 255, 255, 64))
        update_ui_line(screen_x, screen_y, screen_x + p2:x(), screen_y + p2:y(), color8(255, 255, 255, 64))
        update_ui_line(screen_x, screen_y, screen_x + p3:x(), screen_y + p3:y(), color8(255, 255, 255, 64))
    end

    if is_viewing_sub_camera then
        update_ui_image_rot(screen_x, screen_y, atlas_icons.map_icon_camera, color_friendly, 0)
    end
    
    local vehicle_dir = screen_vehicle:get_forward()
    local vehicle_dir_xz = vec2_normal(vec2(vehicle_dir:x(), vehicle_dir:z()))
    local screen_x, screen_y = world_to_screen(screen_vehicle:get_position():x(), screen_vehicle:get_position():z())
    if not is_golfball then
        update_ui_line(screen_x, screen_y, screen_x + vehicle_dir_xz:x() * direction_len, screen_y - vehicle_dir_xz:y() * direction_len, team_color)
    end

    if screen_vehicle.get_waypoint_path ~= nil then
        -- render next waypoint
        local waypoints = screen_vehicle:get_waypoint_path()
        if #waypoints > 0 then
            local wnext = waypoints[1]
            local wx, wy = world_to_screen(wnext:x(), wnext:y())
            render_ground_marker_triangle(vec2(wx, wy), color_friendly, 8, 11)
        end
    end


    -- render vehicles

    local function filter_vehicles(v)
        local def = v:get_definition_index()
        return v:get_is_docked() == false and def ~= e_game_object_type.drydock and def ~= e_game_object_type.chassis_spaceship and v:get_is_observation_revealed()
    end

    -- labels to render once we've computed the layout
    local labels = {}
    local function add_label(lx, ly, ident, alt, speed, pilot, size)
        local label = {
            ident = ident,
            alt = alt,
            speed = speed,
            pilot = pilot,
            size = size,
            x = lx + 8,
            y = ly + 8,
            origin = vec2(lx, ly),
            fx = 0,
            fy = 0,
        }
        table.insert(labels, label)
    end

    local function compute_label_positions()
        -- shift stuff that overlaps at x by 32 px
        local overlaps = 1
        while overlaps > 0 do
            overlaps = 0
            for i, item_a in pairs(labels) do
                for j, item_b in pairs(labels) do
                    if i ~= j then
                        if math.abs(item_a.x - item_b.x) < 32 then
                            -- potential overlap
                            if math.abs(item_a.y - item_b.y) < 32 then
                                -- definate overlap,
                                overlaps = overlaps + 1
                                -- move b right
                                item_b.x = item_b.x + 40
                                -- move a left
                            end
                        end
                    end
                end
                if overlaps > 0 then
                    -- move a slightly right
                    item_a.x = item_a.x - 34
                end
            end

            -- meh... just do it
            overlaps = 0
        end
    end

    local function show_labels()
        local contact_text = color8(255, 255, 255, 140)
        for i, item in pairs(labels) do
            -- render ATC display for item
            -- eg
            -- MNT123   - callsign
            -- F034     - [alt / 10]
            -- M120     - [A/M/P/R][airspeed]
            local x_label = item.x
            local y_label = item.y

            update_ui_line(x_label, y_label,
                    item.origin:x(),
                    item.origin:y(),
                    contact_text)

            update_ui_rectangle(
                    x_label,
                    y_label,
                    37,
                    2 + 10 * item.size,
                    color8(1,1,1,230)
            )

            update_ui_text(x_label + 1, y_label + 2,
                    item.ident, 50, 0, contact_text, 0)

            if item.alt ~= nil then
                update_ui_text(x_label + 1, y_label + 12,
                        item.alt,  50, 0, contact_text, 0)
            end
            if item.speed ~= nil then
                update_ui_text(x_label + 1, y_label + 22,
                        item.speed, 32, 0, contact_text, 0)
            end
        end
    end

    local function show_missiles()
        local m_col = color_white
        local tick = update_get_logic_tick()
        if tick % 15 > 7 then
            m_col = color_enemy
        end
        local missile_count = update_get_missile_count()
        for i = 0, missile_count - 1 do
            local missile = update_get_missile_by_index(i)
            if missile ~= nil and missile:get() then
                local pos = missile:get_position()
                if pos:y() > 50 then
                    local mx, my = world_to_screen(pos:x(), pos:z())
                    update_ui_rectangle_outline(mx, my, 1, 1, m_col)
                end
            end
        end
    end

    local function show_threats(self)
        -- look through our aircraft, find the nearest hostile air
        local hostile_range = 30000
        local nearest_friendly = nil
        local nearest_hostile = nil
        for _, vehicle in iter_vehicles(filter_vehicles) do
            local vehicle_team = vehicle:get_team_id()
            if vehicle_team == update_get_screen_team_id() and get_is_vehicle_air(vehicle:get_definition_index()) then

                local near_manta = find_nearest_hostile_vehicle(vehicle, e_game_object_type.chassis_air_wing_heavy)
                if near_manta ~= nil then
                    local dist = vec3_dist(near_manta:get_position(), vehicle:get_position())
                    if dist < hostile_range then
                        hostile_range = dist
                        nearest_hostile = near_manta
                        nearest_friendly = vehicle
                    end
                end
                local near_alb = find_nearest_hostile_vehicle(vehicle, e_game_object_type.chassis_air_wing_light)
                if near_alb ~= nil then
                    local dist = vec3_dist(near_alb:get_position(), vehicle:get_position())
                    if dist < hostile_range then
                        hostile_range = dist
                        nearest_hostile = near_alb
                        nearest_friendly = vehicle
                    end
                end
                local near_ptr = find_nearest_hostile_vehicle(vehicle, e_game_object_type.chassis_air_rotor_heavy)
                if near_ptr ~= nil then
                    local dist = vec3_dist(near_ptr:get_position(), vehicle:get_position())
                    if dist < hostile_range then
                        hostile_range = dist
                        nearest_hostile = near_ptr
                        nearest_friendly = vehicle
                    end
                end
                local near_rzr = find_nearest_hostile_vehicle(vehicle, e_game_object_type.chassis_air_rotor_light)
                if near_rzr ~= nil then
                    local dist = vec3_dist(near_rzr:get_position(), vehicle:get_position())
                    if dist < hostile_range then
                        hostile_range = dist
                        nearest_hostile = near_rzr
                        nearest_friendly = vehicle
                    end
                end
            end
        end

        if hostile_range < 10000 then
            if nearest_friendly ~= nil then
                if nearest_hostile ~= nil then
                    -- find distance to this awacs
                    local dist = vec3_dist(nearest_hostile:get_position(), self:get_position())
                    if dist < 10000 then
                        -- target is near to the radar
                        -- draw red line between these
                        local f_pos = nearest_friendly:get_position()
                        local f_x, f_y = world_to_screen(f_pos:x(), f_pos:z())
                        local e_pos = nearest_hostile:get_position()
                        local e_x, e_y = world_to_screen(e_pos:x(), e_pos:z())

                        update_ui_line(f_x, f_y, e_x, e_y, color_enemy)

                    end
                end
            end
        end
    end
    local screen_team = update_get_screen_team_id()
    for _, vehicle in iter_vehicles(filter_vehicles) do
        local v_def = vehicle:get_definition_index()
        local vehicle_team = vehicle:get_team_id()
        local friendly = vehicle_team == screen_team
        local icon_region, icon_offset = get_icon_data_by_definition_index(v_def)
        local position_xz = vehicle:get_position()
        local screen_x, screen_y = world_to_screen(position_xz:x(), position_xz:z())

        local element_color = color8(16, 16, 16, 255)

        if friendly then
            element_color = color_friendly
        else
            element_color = color_enemy
            if awacs_mode then
                element_color = update_get_team_color(vehicle_team)
            end
        end

        if vehicle:get_is_visible() then
            update_ui_image(screen_x - icon_offset, screen_y - icon_offset, icon_region, element_color, 0)
            if awacs_mode and vehicle:get_id() ~= screen_vehicle:get_id() then
                local v_spd = vehicle:get_linear_speed()
                local v_alt = vehicle:get_altitude()
                if get_is_vehicle_air(v_def) then
                    local screen_x, screen_y = world_to_screen(vehicle:get_position():x(), vehicle:get_position():z())
                    local name, icon, handle = get_chassis_data_by_definition_index(v_def)


                    if g_radar_mode == radar_modes.air_labels or g_radar_mode == radar_modes.air_threats then
                        if friendly and g_radar_mode == radar_modes.air_labels then
                            add_label(screen_x,
                                    screen_y,
                                    string.format("%s%3d", handle, vehicle:get_id()),
                                    string.format("F%03d", math.ceil(v_alt/10)),
                                    string.format("I%03d", math.floor(v_spd)), nil, 3)
                        else
                            add_label(screen_x, screen_y,
                                    string.format("%s%d", handle, vehicle:get_id()), nil, nil, nil, 1)
                        end
                    end

                    local vehicle_dir = vehicle:get_forward()
                    local vehicle_dir_xz = vec2_normal(vec2(vehicle_dir:x(), vehicle_dir:z()))
                    local direction_len = v_spd / 5
                    update_ui_line(screen_x, screen_y, screen_x + vehicle_dir_xz:x() * direction_len, screen_y - vehicle_dir_xz:y() * direction_len, color_white)
                end
            end

        else
            local last_known_position_xz, is_last_known_position_set = vehicle:get_vision_last_known_position_xz()

            if is_last_known_position_set then
                local screen_x, screen_y = world_to_screen(last_known_position_xz:x(), last_known_position_xz:y())
                update_ui_image(screen_x - 2, screen_y - 2, atlas_icons.map_icon_last_known_pos, element_color, 0)
            end
        end
    end

    if awacs_mode then
        if g_radar_mode == radar_modes.air_labels or g_radar_mode == radar_modes.air_threats then
            if g_radar_mode == radar_modes.air_threats then
                show_threats(screen_vehicle)
            end
            compute_label_positions()
            show_labels()
            show_missiles()
        end
    end


    update_ui_push_offset(x + 10, y + 10)
    local arrow_w = 8
    local arrow_h = 15
    local arrow_col = color8(0, 255, 0, 255)
    update_ui_line(0, arrow_w / 2, arrow_w / 2, 0, arrow_col)
    update_ui_line(arrow_w / 2, 0, arrow_w, arrow_w / 2, arrow_col)
    update_ui_line(arrow_w / 2, 0, arrow_w / 2, arrow_h, arrow_col)
    update_ui_text(0, arrow_h + 1, update_get_loc(e_loc.upp_compass_n), arrow_w, 1, arrow_col, 0)
    update_ui_pop_offset()

    if attachment:get() then
        local def = attachment:get_definition_index()

        if def == e_game_object_type.attachment_camera
        or def == e_game_object_type.attachment_camera_plane
        or def == e_game_object_type.attachment_camera_observation
        or def == e_game_object_type.attachment_turret_carrier_camera
        then
            if attachment:get_stabilisation_mode() == "tracking" then
                local hit_pos = attachment:get_hitscan_position()
                local screen_x, screen_y = world_to_screen(hit_pos:x(), hit_pos:z())

                update_ui_image(screen_x - 4, screen_y - 4, atlas_icons.column_laser, color8(0, 255, 0, 255), 0)
            end
        elseif def == e_game_object_type.attachment_turret_artillery then
            local artillery_pos, is_valid_artillery_hit = attachment:get_artillery_hit_position()

            if is_valid_artillery_hit then
                local screen_x, screen_y = world_to_screen(artillery_pos:x(), artillery_pos:z())

                screen_x = clamp( screen_x, x, x + w )
                screen_y = clamp( screen_y, y, y + h )

                update_ui_image(screen_x - 4, screen_y - 4, atlas_icons.column_laser, color8(0, 255, 0, 255), 0)
            end
        end
    end

    update_ui_push_offset(x, y)

    update_ui_text(10, h - 20, 
        string.format("x:%-6.0f ", camera_x) ..
        string.format("y:%-6.0f ", camera_y),
        w - 10, 0, color8(0, 255, 0, 255), 0
    )

    update_ui_pop_offset()
end


--------------------------------------------------------------------------------
--
-- ATTACHMENT HOTBAR RENDERING
--
--------------------------------------------------------------------------------

function render_attachment_hotbar(screen_w, screen_h, vehicle)
    local attachment_count = get_vehicle_attachment_count(vehicle)
    for i = 0, attachment_count - 1, 1 do
        local attachment = vehicle:get_attachment(i)
        
        if attachment:get() then
            local cursor = get_attachment_slot_position(screen_w, attachment_count, i)

            local bay_color = color8(0, 255, 0, 255)
            if g_selected_attachment_index == i then bay_color = color8(255, 255, 255, 255) end
            
            render_bay_outline(cursor, g_attachment_slot_size, bay_color, g_attachment_factors[i])
            render_attachment_icon(vec2(cursor:x() + g_attachment_slot_size:x() / 2, cursor:y() + g_attachment_slot_size:y() / 2 - 1), vehicle, attachment, bay_color) 

            if attachment:get_is_controllable() and get_is_attachment_observation_camera_controlled(attachment:get_definition_index()) == false then
                update_ui_rectangle(cursor:x(), cursor:y() + g_attachment_slot_size:y(), g_attachment_slot_size:x(), 3, get_control_mode_color(attachment:get_control_mode()))
            end

            if g_selected_attachment_index == i then
                local selection_factor = clamp(1 - (g_active_attachment_time - 1000) / 1000, 0, 1)

                if selection_factor > 0 then
                    local hint_col = color8(0, 255, 0, math.floor(selection_factor * 255))
                    update_ui_text(0, cursor:y() + 23, get_attachment_display_name(vehicle, attachment), math.floor(screen_w / 2) * 2, 1, hint_col, 0)
                end
            end
        end
    end
end

function get_attachment_slot_position(screen_w, attachment_count, index) 
    local total_w = attachment_count * 19
    local cx = (screen_w - total_w) / 2
    return vec2(cx + 19 * index, 5) 
end

function render_bay_outline(pos, size, col, factor)
    update_ui_rectangle_outline(pos:x(), pos:y(), size:x(), size:y(), color8(col:r(), col:g(), col:b(), math.floor(col:a() * 0.5)))

    local w = size:x() * factor
    update_ui_rectangle(pos:x() + size:x() * 0.5 - w * 0.5, pos:y(), w, 1, col)
end

function render_attachment_icon(pos, vehicle, attachment, col)
    local adef = attachment:get_definition_index()
    if adef == e_game_object_type.attachment_camera_vehicle_control and get_is_vehicle_controllable(vehicle) then
        update_ui_image_rot(pos:x(), pos:y(), atlas_icons.hud_manual_control, col, 0)
    else
        local icon_region_l, icon_region_s = get_attachment_icons(adef)
    
        if icon_region_s ~= -1 then
            if attachment:get_ammo_capacity() > 0 and attachment:get_ammo_remaining() == 0 then
                update_ui_image_rot(pos:x(), pos:y(), icon_region_s, color8(255, 0, 0, 128), 0)
                update_ui_image_rot(pos:x(), pos:y(), atlas_icons.icon_attachment_16_unknown, color8(255, 0, 0, 255), 0)
            else
                update_ui_image_rot(pos:x(), pos:y(), icon_region_s, col, 0)
            end
        end
    end
end


--------------------------------------------------------------------------------
--
-- ATTACHMENT INFO RENDERING
--
--------------------------------------------------------------------------------

function render_attachment_info(info_pos, map_data, vehicle, attachment, alpha, screen_w, screen_h)
    local border_size = 3
    local pos = vec2(info_pos:x() + border_size, info_pos:y() + border_size)
    local ammo_capacity = attachment:get_ammo_capacity()
    local ammo_count = attachment:get_ammo_remaining()
    local bounds = vec2(0, 0)

    -- update_ui_push_clip()

    local colors = {
        green = color8(0, 255, 0, alpha),
        grey = color8(64, 64, 64, alpha),
        red = color8(255, 0, 0, alpha),
        yellow = color8(255, 255, 0, alpha),
    }

    -- Build list of linked attachments (i.e, attachments that will trigger when we trigger the current attachment)

    local linked_attachments = {}

    if attachment:get_is_control_linked() then
        for i = 0, vehicle:get_attachment_count() - 1 do
            local attachment_other = vehicle:get_attachment(i)

            if i ~= attachment:get_index() and attachment_other:get() and attachment_other:get_definition_index() == attachment:get_definition_index() and attachment_other:get_control_mode() == "manual" then
                table.insert(linked_attachments, attachment_other)
            end
        end
    end

    -- Render link between attachments

    if #linked_attachments > 0 then
        if attachment:get_control_mode() == "manual" then
            g_is_attachment_linked = true
        end

        local attachment_count = get_vehicle_attachment_count(vehicle)
        local link_min = get_attachment_slot_position(screen_w, attachment_count, attachment:get_index())
        local link_max = vec2(link_min:x(), link_min:y())

        local link_y = link_min:y() - 3
        local start_segment_factor = 1.0 - remap_clamp(g_attachment_link_factor, 0, 0.1, 0, 1)
        local mid_segment_factor = remap_clamp(g_attachment_link_factor, 0.1, 0.9, 0, 1)
        local end_segment_factor = remap_clamp(g_attachment_link_factor, 0.9, 1, 0, 1)

        local start_x = link_min:x() 
        update_ui_line(start_x + g_attachment_slot_size:x() / 2, link_y + 3 * start_segment_factor, start_x + g_attachment_slot_size:x() / 2, link_y + 3, color8(255, 255, 255, 255))

        for k, v in pairs(linked_attachments) do
            local other_pos = get_attachment_slot_position(screen_w, attachment_count, v:get_index()):x()
            link_min:x(math.min(link_min:x(), other_pos))
            link_max:x(math.max(link_max:x(), other_pos))

            update_ui_line(other_pos + g_attachment_slot_size:x() / 2, link_y, other_pos + g_attachment_slot_size:x() / 2, link_y + 3 * end_segment_factor, color8(255, 255, 255, 255))
        end

        local mid_x_min = lerp(start_x, link_min:x(), mid_segment_factor)
        local mid_x_max = lerp(start_x, link_max:x(), mid_segment_factor)
        update_ui_line(mid_x_min + g_attachment_slot_size:x() / 2, link_y, mid_x_max + g_attachment_slot_size:x() / 2, link_y, color8(255, 255, 255, 255))
    end

    update_ui_push_clip(pos:x(), pos:y(), 300, math.floor((screen_h - pos:y()) * g_attachment_info_factor))
    
    local attachment_def = attachment:get_definition_index()

    -- render nearest island name
    local nearest_island = get_nearest_island_name(vehicle)
    update_ui_text(pos:x(), pos:y(), string.upper(nearest_island), 200, 0, colors.green, 0)
    pos:y(pos:y() + 10)

    -- render vehicle id
    if vehicle:get_definition_index() ~= e_game_object_type.chassis_carrier then
        update_ui_text(pos:x(), pos:y(), update_get_loc(e_loc.upp_id) .. " " .. tostring(vehicle:get_id()), 200, 0, colors.green, 0)
        pos:y(pos:y() + 10)
    end

    if attachment_def ~= e_game_object_type.attachment_camera_vehicle_control then
        if get_is_attachment_observation_camera_controlled(attachment_def) then
            update_ui_image(pos:x(), pos:y(), atlas_icons.column_laser, colors.green, 0)
            update_ui_text(pos:x() + 12, pos:y(), update_get_loc(e_loc.upp_guided), 200, 0, colors.green, 0)
            pos:y(pos:y() + 10)
        elseif attachment:get_is_controllable() then
            update_ui_image(pos:x(), pos:y(), atlas_icons.column_control_mode, colors.green, 0)
            update_ui_text(pos:x() + 12, pos:y(), get_control_mode_loc(attachment:get_control_mode()), 200, 0, colors.green, 0)
            pos:y(pos:y() + 10)

            if attachment:get_type() == "camera" or attachment:get_type() == "turret" then
                if attachment_def ~= e_game_object_type.attachment_turret_robot_dog_capsule and attachment_def ~= e_game_object_type.attachment_turret_plane_chaingun and attachment_def ~= e_game_object_type.attachment_turret_rocket_pod and attachment_def ~= e_game_object_type.attachment_deployable_droid then
                    if attachment:get_type() == "turret" then
                        update_add_ui_interaction(update_get_loc(e_loc.interaction_zoom), e_game_input.attachment_primary)
                    end

                    if vehicle:get_definition_index() ~= e_game_object_type.chassis_land_turret then
                        update_ui_image(pos:x(), pos:y(), atlas_icons.column_stabilisation_mode, colors.green, 0)
                        update_ui_text(pos:x() + 12, pos:y(), get_stabilisation_mode_loc(attachment:get_stabilisation_mode()), 200, 0, colors.green, 0)
                        pos:y(pos:y() + 10)

                        update_add_ui_interaction(update_get_loc(e_loc.interaction_stabilisation), e_game_input.toggle_stabilisation_mode)
                    end
                end
            end
            
            if attachment:get_fuel_capacity() > 0 then
                update_ui_image(pos:x(), pos:y(), atlas_icons.column_fuel, colors.green, 0)
                update_ui_text(pos:x() + 12, pos:y(), string.format("%d/%d", attachment:get_fuel_remaining(), attachment:get_fuel_capacity()), 200, 0, colors.green, 0)
                pos:y(pos:y() + 10)
            end
        end
    end

    if update_get_is_multiplayer() then
        local controlling_peer_id = attachment:get_controlling_peer_id()

        if controlling_peer_id ~= 0 then
            local color = iff(attachment:get_is_controlling_peer(), colors.green, colors.red)
            local peer_index = update_get_peer_index_by_id(controlling_peer_id)
            local peer_name = update_get_peer_name(peer_index)
            local max_text_chars = 10
            local is_clipped = false

            if utf8.len(peer_name) > max_text_chars then
                peer_name = peer_name:sub(1, utf8.offset(peer_name, max_text_chars) - 1)
                is_clipped = true
            end

            local text_render_w, text_render_h = update_ui_get_text_size(peer_name, 200, 0)
            update_ui_image(pos:x(), pos:y(), atlas_icons.column_controlling_peer, color, 0)
            update_ui_text(pos:x() + 12, pos:y(), peer_name, 200, 0, color, 0)

            if is_clipped then
                update_ui_image(pos:x() + 12 + text_render_w, pos:y(), atlas_icons.text_ellipsis, color, 0)
            end
            
            pos:y(pos:y() + 10)
        end
    end
    
    -- Render ammo

    if ammo_capacity > 0 and vehicle:get_definition_index() ~= e_game_object_type.chassis_land_turret then   
        if attachment_def ~= e_game_object_type.attachment_turret_robot_dog_capsule and attachment_def ~= e_game_object_type.attachment_deployable_droid then 
            local ammo_col = iff(ammo_count > 0, colors.green, colors.red)

            update_ui_image(pos:x(), pos:y(), atlas_icons.column_ammo, ammo_col, 0)
            update_ui_text(pos:x() + 12, pos:y(), ammo_count .. "/" .. ammo_capacity, 200, 0, ammo_col, 0)
            pos:y(pos:y() + 10)

            if attachment:get_control_mode() == "manual" then
                for k, v in pairs(linked_attachments) do
                    local ammo_capacity = v:get_ammo_capacity()
                    local ammo_count = v:get_ammo_remaining()
                    
                    if ammo_capacity > 0 then
                        local ammo_col = iff(ammo_count > 0, colors.green, colors.red)
                        update_ui_image(pos:x(), pos:y(), atlas_icons.icon_tree_next, ammo_col, 0)
                        update_ui_text(pos:x() + 12, pos:y(), ammo_count .. "/" .. ammo_capacity, 200, 0, ammo_col, 0)
                        pos:y(pos:y() + 10)
                    end
                end
            end
        end
    end

    -- Render observation camera data
    if attachment_def == e_game_object_type.attachment_camera_observation
    or attachment_def == e_game_object_type.attachment_turret_carrier_camera
    or attachment_def == e_game_object_type.attachment_camera_plane
    then
        local weapon_type = attachment:get_weapon_target_type()
        local weapon_names = {
            [0] = update_get_loc(e_loc.upp_crs_msl),
            [1] = update_get_loc(e_loc.upp_crr_gun),
            [2] = update_get_loc(e_loc.upp_crr_flr),
            [3] = update_get_loc(e_loc.upp_gnd_art),
            [4] = update_get_loc(e_loc.upp_guided_msl)
        }

        local weapon_text = weapon_names[weapon_type] or update_get_loc(e_loc.upp_unknown)

        local is_target_data_set = attachment:get_is_weapon_target_data_set()
        local is_active = attachment:get_is_active()
        local is_target_data_complete = false
    
        if is_target_data_set then
            local target_state = attachment:get_weapon_target_state()
            is_target_data_complete = target_state == e_team_target_state.cancelled or target_state == e_team_target_state.complete or target_state == e_team_target_state.failed
        end
        
        local weapon_col = iff(is_active == false or is_target_data_complete, colors.green, colors.grey)
        update_ui_image(pos:x(), pos:y(), atlas_icons.column_weapon, weapon_col, 0)
        update_ui_text(pos:x() + 12, pos:y(), weapon_text, 200, 0, weapon_col, 0)
        pos:y(pos:y() + 10)

        local laser_mode_text = update_get_loc(e_loc.upp_ready)
        local laser_mode_col = colors.yellow

        if is_active and not is_target_data_complete then
            laser_mode_text = update_get_loc(e_loc.upp_engaged)
            laser_mode_col = colors.green
        end

        update_ui_image(pos:x(), pos:y(), atlas_icons.column_laser, laser_mode_col, 0)
        update_ui_text(pos:x() + 12, pos:y(), laser_mode_text, 200, 0, laser_mode_col, 0)
        pos:y(pos:y() + 10)

        update_add_ui_interaction(update_get_loc(e_loc.interaction_cycle_weapon), e_game_input.attachment_primary)

        if attachment:get_control_mode() == "manual" then
            update_add_ui_interaction_special(update_get_loc(e_loc.interaction_zoom), e_ui_interaction_special.vehicle_zoom)

            if is_target_data_set then
                update_add_ui_interaction(iff(is_target_data_complete or is_active == false, update_get_loc(e_loc.interaction_fire), update_get_loc(e_loc.interaction_cancel)), e_game_input.attachment_fire)
            else
                update_add_ui_interaction(iff(is_active, update_get_loc(e_loc.interaction_cancel), update_get_loc(e_loc.interaction_fire)), e_game_input.attachment_fire)
            end
        end
        
        if is_active == false or is_target_data_complete then
            if g_weapon_list_factor > 0 then
                local list_h = (#weapon_names + 1) * 10
                update_ui_push_offset(pos:x(), pos:y() + 10)
                update_ui_push_clip(0, 0, 200, math.ceil(list_h * g_weapon_list_factor))
                
                local cx = 0
                local cy = 0

                for i = 0, #weapon_names do
                    if i == weapon_type and g_animation_time % 250 < 125 then
                        update_ui_image(cx + 2, cy + 1, atlas_icons.text_back, color_white, 2)
                    end

                    update_ui_text(cx + 12, cy, weapon_names[i], 200, 0, iff(i == weapon_type, color_white, colors.green), 0)
                    cy = cy + 10
                end

                update_ui_pop_clip()
                update_ui_pop_offset()
            end
        end

        if is_target_data_set and g_weapon_list_factor == 0 then
            pos:y(pos:y() + 10)

            local state_names = {
                [e_team_target_state.pending] = update_get_loc(e_loc.upp_waiting).."...",
                [e_team_target_state.active] = update_get_loc(e_loc.upp_active),
                [e_team_target_state.complete] = update_get_loc(e_loc.upp_complete),
                [e_team_target_state.cancelled] = update_get_loc(e_loc.upp_cancelled),
                [e_team_target_state.failed] = update_get_loc(e_loc.upp_failed),
            }

            local error_names = {
                [e_team_target_error.none] = update_get_loc(e_loc.upp_none),
                [e_team_target_error.busy] = update_get_loc(e_loc.upp_busy),
                [e_team_target_error.no_ammo] = update_get_loc(e_loc.upp_no_ammo),
                [e_team_target_error.out_of_range] = update_get_loc(e_loc.upp_out_of_range),
                [e_team_target_error.inactive] = update_get_loc(e_loc.upp_inactive),
                [e_team_target_error.no_power] = update_get_loc(e_loc.upp_no_power),
                [e_team_target_error.damaged] = update_get_loc(e_loc.upp_damaged),
                [e_team_target_error.destroyed] = update_get_loc(e_loc.upp_destroyed),
                [e_team_target_error.unavailable] = update_get_loc(e_loc.upp_unavailable),
            } 

            local error_colors = {
                [e_team_target_error.none] = colors.grey,
                [e_team_target_error.busy] = colors.yellow,
                [e_team_target_error.no_ammo] = colors.red,
                [e_team_target_error.out_of_range] = colors.red,
                [e_team_target_error.inactive] = colors.red,
                [e_team_target_error.no_power] = colors.red,
                [e_team_target_error.damaged] = colors.red,
                [e_team_target_error.destroyed] = colors.red,
                [e_team_target_error.unavailable] = colors.red,
            } 

            local state_colors = {
                [e_team_target_state.pending] = colors.grey,
                [e_team_target_state.active] = colors.green,
                [e_team_target_state.complete] = colors.green,
                [e_team_target_state.cancelled] = colors.yellow,
                [e_team_target_state.failed] = colors.red,
            }

            local consuming_type_names = {
                [e_team_target_consuming_type.none] = "---",
                [e_team_target_consuming_type.attachment] = update_get_loc(e_loc.upp_wep),
                [e_team_target_consuming_type.missile] = update_get_loc(e_loc.upp_msl),
            }

            local consuming_type = attachment:get_weapon_target_consuming_type()
            local target_state = attachment:get_weapon_target_state()
            local target_error = attachment:get_weapon_target_error()
            local id, idx = attachment:get_weapon_target_consuming_id()

            update_ui_image(pos:x(), pos:y(), atlas_icons.column_pending, state_colors[target_state], 0)
            update_ui_text(pos:x() + 12, pos:y(), state_names[target_state], 100, 0, state_colors[target_state], 0)
            pos:y(pos:y() + 10)

            if target_state ~= e_team_target_state.complete and target_state ~= e_team_target_state.cancelled then
                if g_animation_time % 500 > 250 and target_error ~= e_team_target_error.none then
                    update_ui_image(pos:x(), pos:y(), atlas_icons.hud_warning, error_colors[target_error], 0)
                    update_ui_text(pos:x() + 12, pos:y(), error_names[target_error], 100, 0, error_colors[target_error], 0)
                end
            end

            pos:y(pos:y() + 10)

            if consuming_type == e_team_target_consuming_type.attachment then
                update_ui_text(pos:x() + 12, pos:y(), consuming_type_names[consuming_type] .. ":" .. id .. "[" .. idx .. "]", 200, 0, state_colors[target_state], 0)
                pos:y(pos:y() + 10)

                if target_state == e_team_target_state.active or target_state == e_team_target_state.complete then
                    local consuming_attachment = get_vehicle_attachment(id, idx)

                    if consuming_attachment ~= nil then
                        local ammo = consuming_attachment:get_ammo_remaining()

                        update_ui_image(pos:x(), pos:y(), atlas_icons.column_ammo, iff(ammo > 0, colors.green, colors.red), 0)
                        update_ui_text(pos:x() + 12, pos:y(), ammo, 200, 0, iff(ammo > 0, colors.green, colors.red), 0)
                        pos:y(pos:y() + 10)

                        local accuracy = consuming_attachment:get_target_accuracy()

                        update_ui_image(pos:x(), pos:y(), atlas_icons.column_laser, colors.green, 0)
                        update_ui_text(pos:x() + 12, pos:y(), string.format("%.0f%%", accuracy * 100), 200, 0, colors.green, 0)
                        pos:y(pos:y() + 10)
                    end
                end
            elseif consuming_type == e_team_target_consuming_type.missile then
                update_ui_text(pos:x() + 12, pos:y(), consuming_type_names[consuming_type], 200, 0, state_colors[target_state], 0)
                pos:y(pos:y() + 10)
    
                if target_state == e_team_target_state.failed then
                    if g_animation_time % 500 > 250 then
                        update_ui_text(pos:x() + 12, pos:y(), update_get_loc(e_loc.upp_destroyed), 200, 0, state_colors[target_state], 0)
                        pos:y(pos:y() + 10)
                    end
                elseif target_state == e_team_target_state.complete then
                    if g_animation_time % 500 > 250 then
                        update_ui_text(pos:x() + 12, pos:y(), update_get_loc(e_loc.upp_impact), 200, 0, state_colors[target_state], 0)
                        pos:y(pos:y() + 10)
                    end
                else
                    local consuming_missile = update_get_missile_by_id(id)
        
                    if consuming_missile:get() then
                        local hit_pos = attachment:get_hitscan_position()
                        local msl_pos = consuming_missile:get_position()
                        local dist = vec3_dist(hit_pos, msl_pos)

                        if dist < 2500 and hit_pos:y() < 500 then
                            local _, behind = update_world_to_screen(hit_pos)
                            if not behind then
                                local col_scale = 255 / 2500
                                local hp_x = hit_pos:x()
                                local hp_y = hit_pos:y()
                                local hp_z = hit_pos:z()
                                local dist_2 = dist /2
                                local alpha = 255 - math.floor(dist * col_scale)
                                local cross_col = color8(0, 255, 0, alpha)
                                -- draw a diamond around the target that shrinks as the dist falls
                                local north = vec3(hp_x, hp_y, hp_z - dist_2)
                                local south = vec3(hp_x, hp_y, hp_z + dist_2)
                                local east = vec3(hp_x + dist_2, hp_y, hp_z)
                                local west = vec3(hp_x - dist_2, hp_y, hp_z)

                                local sn, behind1 = update_world_to_screen(north)
                                local ss, behind2 = update_world_to_screen(south)
                                local se, behind3 = update_world_to_screen(east)
                                local sw, behind4 = update_world_to_screen(west)

                                if not behind1 and not behind4 then
                                    update_ui_line(
                                            sn:x(), sn:y(),
                                            se:x(), se:y(),
                                            cross_col
                                    )
                                    update_ui_line(
                                            se:x(), se:y(),
                                            ss:x(), ss:y(),
                                            cross_col
                                    )
                                    update_ui_line(
                                            ss:x(), ss:y(),
                                            sw:x(), sw:y(),
                                            cross_col
                                    )
                                    update_ui_line(
                                            sw:x(), sw:y(),
                                            sn:x(), sn:y(),
                                            cross_col
                                    )

                                end
                            end
                        end
                        local p_x = pos:x()
                        local p_y = pos:y()
                        update_ui_image(p_x, p_y, atlas_icons.column_laser, colors.green, 0)
                        update_ui_text(p_x + 12, p_y, string.format("%.0f", dist) .. update_get_loc(e_loc.acronym_meters), 200, 0, state_colors[target_state], 0)
                        pos:y(p_y + 10)
                    end
                end
            end
        end
    end

    -- Render control bot data

    if attachment_def == e_game_object_type.attachment_turret_robot_dog_capsule then
        pos:y(pos:y() + 10)
        
        local vehicle_pos = vehicle:get_position()
        local nearest_tile = map_data:get_closest_tile_id(vehicle_pos)

        local color_team_control = colors.green
        local text_team_control = "-"
        local text_team_capture = "-"
        local text_capture_progress = "-"

        if nearest_tile ~= -1 then
            local team_control, team_capture, capture_progress = map_data:get_tile_team_status(nearest_tile)

            if team_control ~= -1 then
                text_team_control = team_control

                if team_control ~= vehicle:get_team_id() then
                    color_team_control = colors.red
                end
            end
            
            if team_capture ~= -1 then
                text_team_capture = team_capture
            end

            if team_control ~= team_capture and team_capture ~= -1 then
                text_capture_progress = string.format("%.0f%%", capture_progress * 100)
            end
        end

        update_ui_image(pos:x(), pos:y(), atlas_icons.column_team_control, color_team_control, 0)
        update_ui_text(pos:x() + 12, pos:y(), text_team_control, 200, 0, color_team_control, 0)
        pos:y(pos:y() + 10)
        
        update_ui_image(pos:x(), pos:y(), atlas_icons.column_team_capture, colors.green, 0)
        update_ui_text(pos:x() + 12, pos:y(), text_team_capture, 200, 0, colors.green, 0)
        pos:y(pos:y() + 10)

        update_ui_image(pos:x(), pos:y(), atlas_icons.column_capture_progress, colors.green, 0)
        update_ui_text(pos:x() + 12, pos:y(), text_capture_progress, 200, 0, colors.green, 0)
        pos:y(pos:y() + 10)

       
    end

    bounds:x(80)
    bounds:y(pos:y() - info_pos:y())

    update_ui_pop_clip()
end

function render_notification(screen_w, screen_h)
    local function get_notification_factor(notification)
        local time = g_notification.time - notification.time

        if time < 250 then
            return time / 250
        else
            return 1 - clamp((time - 250 - 2000) / 250, 0, 1)
        end
    end

    local cy = 39
    local cx = screen_w / 2

    local function render_notification(notification, x, y)
        local factor = get_notification_factor(notification)

        if factor > 0 then
            local text_w, text_h = update_ui_get_text_size(notification.text, 1000, 1)

            update_ui_push_offset(x - text_w / 2 - 2, y)
            update_ui_push_clip(0, 0, text_w + 4, math.ceil((text_h + 4) * factor))
            update_ui_rectangle_outline(0, 0, text_w + 4, text_h + 4, notification.col)
            update_ui_text(0, 2, notification.text, text_w + 4, 1, notification.col, 0)
            update_ui_pop_clip()
            update_ui_pop_offset()

            cy = cy + (text_h + 4 + 2)
        end
    end

    if g_notification.notification_vehicle_control_mode.text ~= "" then
        render_notification(g_notification.notification_vehicle_control_mode, cx, cy)
    end

    if g_notification.notification_attachment_control_mode.text ~= "" then
        render_notification(g_notification.notification_attachment_control_mode, cx, cy)
    end
    
    if g_notification.notification_support_order_mode.text ~= "" then
        render_notification(g_notification.notification_support_order_mode, cx, cy)
    end
end

--------------------------------------------------------------------------------
--
-- ATTACHMENT HUDS
--
--------------------------------------------------------------------------------

function render_attachment_hud(screen_w, screen_h, map_data, tick_fraction, vehicle, attachment, local_peer_id)
    local def = attachment:get_definition_index()

    is_render_center = false
    if def == e_game_object_type.attachment_camera_vehicle_control
    then
        render_attachment_vision(screen_w, screen_h, map_data, vehicle, attachment)
        -- no special hud for vehicle control camera
    elseif def == e_game_object_type.attachment_camera
    or def == e_game_object_type.attachment_camera_plane
    or def == e_game_object_type.attachment_camera_observation
    or def == e_game_object_type.attachment_turret_carrier_camera
    then
        is_render_center = render_attachment_hud_camera(screen_w, screen_h, map_data, vehicle, attachment)
    elseif def == e_game_object_type.attachment_fuel_tank_plane then
        is_render_center = render_attachment_hud_fuel_tank(screen_w, screen_h, attachment)
    elseif def == e_game_object_type.attachment_turret_15mm
    or def == e_game_object_type.attachment_turret_30mm
    or def == e_game_object_type.attachment_turret_40mm
    or def == e_game_object_type.attachment_turret_heavy_cannon
    or def == e_game_object_type.attachment_turret_battle_cannon
    or def == e_game_object_type.attachment_turret_carrier_main_gun
    or def == e_game_object_type.attachment_turret_droid
    or def == e_game_object_type.attachment_turret_gimbal_30mm
    then
        is_render_center = render_attachment_hud_cannon(screen_w, screen_h, map_data, vehicle, attachment, def)
    elseif def == e_game_object_type.attachment_turret_artillery
    then
        is_render_center = render_attachment_hud_artillery(screen_w, screen_h, map_data, vehicle, attachment)
    elseif def == e_game_object_type.attachment_turret_plane_chaingun
    then
        is_render_center = render_attachment_hud_chaingun(screen_w, screen_h, map_data, tick_fraction, vehicle, attachment)
    elseif def == e_game_object_type.attachment_turret_ciws
    or def == e_game_object_type.attachment_turret_carrier_ciws
    then
        is_render_center = render_attachment_hud_ciws(screen_w, screen_h, map_data, vehicle, attachment)
    elseif def == e_game_object_type.attachment_turret_rocket_pod
    or def == e_game_object_type.attachment_turret_missile
    or def == e_game_object_type.attachment_hardpoint_missile_ir
    or def == e_game_object_type.attachment_hardpoint_missile_laser
    or def == e_game_object_type.attachment_hardpoint_missile_aa
    or def == e_game_object_type.attachment_turret_carrier_missile
    or def == e_game_object_type.attachment_turret_carrier_missile_silo
    then
        is_render_center = render_attachment_hud_missile(screen_w, screen_h, map_data, vehicle, attachment)
    elseif def == e_game_object_type.attachment_hardpoint_missile_tv
    then
        is_render_center = render_attachment_hud_tv_missile(screen_w, screen_h, map_data, vehicle, attachment)
    elseif def == e_game_object_type.attachment_radar_golfball
    then
        is_render_center = render_attachment_hud_radar(screen_w, screen_h, map_data, vehicle, attachment)
    elseif def == e_game_object_type.attachment_sonic_pulse_generator
    then
        is_render_center = render_attachment_hud_sonic_pulse(screen_w, screen_h, map_data, vehicle, attachment)
    elseif def == e_game_object_type.attachment_smoke_launcher_explosive
    or def == e_game_object_type.attachment_smoke_launcher_stream
    then
        is_render_center = render_attachment_hud_flare(screen_w, screen_h, map_data, vehicle, attachment)
    elseif def == e_game_object_type.attachment_hardpoint_bomb_1
    or def == e_game_object_type.attachment_hardpoint_bomb_2
    or def == e_game_object_type.attachment_hardpoint_bomb_3
    then
        is_render_center = render_attachment_hud_bomb(screen_w, screen_h, map_data, vehicle, attachment)
    elseif def == e_game_object_type.attachment_hardpoint_torpedo
    or def == e_game_object_type.attachment_hardpoint_torpedo_noisemaker
    or def == e_game_object_type.attachment_hardpoint_torpedo_decoy
    then
        is_render_center = render_attachment_hud_torpedo(screen_w, screen_h, map_data, vehicle, attachment)
    elseif def == e_game_object_type.attachment_turret_carrier_flare_launcher
    or def == e_game_object_type.attachment_flare_launcher
    then
        is_render_center = render_attachment_hud_flare(screen_w, screen_h, map_data, vehicle, attachment)
    elseif def == e_game_object_type.attachment_radar_awacs then
        is_render_center = render_attachment_hud_radar(screen_w, screen_h, map_data, vehicle, attachment)
    elseif def == e_game_object_type.attachment_turret_robot_dog_capsule
    then
        is_render_center = render_attachment_hud_robot_dog(screen_w, screen_h, map_data, vehicle, attachment)
    elseif def == e_game_object_type.attachment_deployable_droid
    then
        is_render_center = render_attachment_hud_deployable_droid(screen_w, screen_h, map_data, vehicle, attachment)
    elseif def == e_game_object_type.attachment_turret_carrier_torpedo then
    elseif def == e_game_object_type.attachment_logistics_container_20mm then
    elseif def == e_game_object_type.attachment_logistics_container_30mm then
    elseif def == e_game_object_type.attachment_logistics_container_40mm then
    elseif def == e_game_object_type.attachment_logistics_container_100mm then
    elseif def == e_game_object_type.attachment_logistics_container_120mm then
    elseif def == e_game_object_type.attachment_logistics_container_fuel then
    elseif def == e_game_object_type.attachment_logistics_container_ir_missile then
    elseif def < e_game_object_type.count then
        update_ui_text(screen_w / 2, 20, update_get_loc(e_loc.unknown_attachment), 200, 0, color8(255, 0, 0, 255), 0)
    end

    if g_render_rwr then
        render_hud_rwr(screen_w, screen_h, vehicle)
    end

    return is_render_center
end

function render_hud_rwr(screen_w, screen_h, vehicle)
    if not g_debug_enabled then
        _render_hud_rwr(screen_w, screen_h, vehicle)
    else
        local st, err = pcall(_render_hud_rwr, screen_w, screen_h, vehicle)
        if not st then
            print(err)
        end
    end
end

local green = color8(0, 255, 0, 200)
local dgreen = color8(0, 120, 0, 120)
local red = color8(255, 0, 0, 180)
local rwr_dist_sq = 17000 * 17000
local rwr_1k_sq = 1000 * 1000
local rwr_1k5_sq = 1500 * 1500
local rwr_4k5_sq = 4500 * 4500
local rwr_6k_sq = 6000 * 6000
local rwr_10k_sq = 10000 * 10000
local ciws_attachmennts = {
    [e_game_object_type.attachment_turret_ciws] = true,
    [e_game_object_type.attachment_turret_carrier_ciws] = true,
}

function _render_hud_rwr(screen_w, screen_h, vehicle)
    local tick = update_get_logic_tick()
    local rwr_clampmin = vec2(0, 0)
    local rwr_clampmax = vec2(screen_w, screen_h)
    local size = 29
    local x = screen_w - 32
    local y = screen_h / 4
    local n = y - (size / 2)
    local w = x - (size / 2)
    local e = x + (size / 2)

    local fwd = green
    local port = green
    local stbd = green
    local aft = green

    -- visible by a radar
    local show_spike = false
    local show_alert = false
    local show_nails = false
    local spike_color = red
    local rinfo = nil

    render_circle(vec2(x, y), 29, 15, green)
    render_circle(vec2(x, y), 15, 10, dgreen)
    update_ui_line(x+1, y-size, x+1, y+size, dgreen)
    update_ui_line(x-size, y, x+size, y, dgreen)

    if get_vehicle_health_factor(vehicle) < 0.5 then
        red = color8(255, 0, 0, 210)
        show_alert = true
        show_spike = true
        fwd = red
        port = red
        aft = red
        stbd = red
    end
    local our_id = vehicle:get_id()
    local our_head = update_get_camera_heading()
    local our_team = get_vehicle_team_id(vehicle)
    local ourp = get_pos_xz(vehicle)

    -- iterate all the targets and compute angles and threats
    for _, v in pairs(get_vehicles_table()) do
        -- hostile only please
        local vid = v:get_id()
        local vteam = get_vehicle_team_id(v)
        local hostile = vteam ~= our_team
        if hostile and not get_vehicle_docked(v) then
            local vp = get_pos_xz(v)
            local dist = fast_dist_sq2(vp, ourp, rwr_dist_sq)

            if dist < rwr_dist_sq then
                local vdef = v:get_definition_index()
                local rdr = get_vehicle_radar(v)
                local rdr_enabled = true
                if vdef == e_game_object_type.chassis_carrier then
                    rdr_enabled = get_awacs_radar_enabled(v)
                end
                if not rdr and get_is_vehicle_land(vdef) then
                    if has_attachment(v, ciws_attachmennts) then
                        rdr = e_game_object_type.attachment_turret_ciws
                    end
                end

                local offset = 26
                local txt = ""
                local threat = false
                local locked = false
                if rdr and rdr_enabled then
                    if vdef == e_game_object_type.chassis_sea_ship_heavy then
                        if dist < rwr_10k_sq then
                            txt = "s"
                            if dist < rwr_6k_sq then
                                threat = true
                                if dist < rwr_4k5_sq then
                                    locked = true
                                end
                            end
                        end
                    elseif vdef == e_game_object_type.chassis_carrier then
                        txt = "s"
                        threat = true
                        if dist < rwr_4k5_sq then
                            locked = true
                        end
                    elseif rdr == e_game_object_type.attachment_turret_ciws then
                        if dist < rwr_1k5_sq then
                            threat = true
                            txt = "c"
                            if dist < rwr_1k_sq then
                                locked = true
                            end
                        end
                    elseif rdr == e_game_object_type.attachment_radar_awacs then
                        txt = "A"
                        threat = true
                    elseif rdr == e_game_object_type.attachment_radar_golfball then
                        txt = "s"
                        threat = true
                    end

                    if txt ~= "" then
                        if threat or locked then
                            offset = 14
                        end

                        local tvect = vec2(vp:x() - ourp:x(), vp:y() - ourp:y())
                        local tnorm = vec2_normal(tvect)
                        -- rotate
                        local tx = (tnorm:x() * math_cos(our_head) - tnorm:y() * math_sin(our_head)) * offset
                        local ty = 4 + ((tnorm:x() * math_sin(our_head) + tnorm:y() * math_cos(our_head)) * offset)
                        -- print(dx, dz, our_team, vteam, hostile)
                        update_ui_text(
                                x + tx - 4,
                                y - ty,
                                txt, 10, 1, green, 0)
                        if locked then
                            -- draw diamond
                            update_ui_line(
                                    x + tx, y - ty,
                                    x + tx + 6, y - ty + 6,
                                    green
                            )
                            update_ui_line(
                                    x + tx + 5, y - ty + 6,
                                    x + tx, y - ty + 11,
                                    green
                            )
                            update_ui_line(
                                    x + tx + 1, y - ty,
                                    x + tx - 5, y - ty + 6,
                                    green
                            )
                            update_ui_line(
                                    x + tx - 4, y - ty + 6,
                                    x + tx + 1, y - ty + 11,
                                    green
                            )
                        end
                    end
                end
            end
        end
    end

    if g_nearest_hostile_ew_radar_id > -1 then
        local hrdr = get_nearest_hostile_ew_radar()
        if hrdr then
            local rtype = hrdr:get_definition_index()
            if get_is_vehicle_sea(rtype) or get_is_vehicle_land(rtype) then
                rinfo = "S"
            elseif get_is_vehicle_air(rtype)  then
                rinfo = "A"
            end

            if g_nearest_hostile_ew_radar_range < 10000 then
                show_spike = true
                show_alert = true
                local mrr = get_modded_radar_range(hrdr)
                if g_nearest_hostile_ew_radar_range < mrr or rinfo == "A" then
                    show_nails = true
                end
            end
        end
    end

    if tick % 30 < 15 then
        if show_nails then
            update_ui_image_rot(w - 6, y + size, atlas_icons.column_ammo, red, 0)
            show_alert = true
        end
    end

    if tick % 60 < 30 then
        if g_nearest_hostile_ew_radar_id > -1 then
            -- change color
            show_alert = true
        end
    end

    if show_alert then
        update_ui_image_rot(e + 7, y + size, atlas_icons.hud_warning, red, 0)
    end

end

function render_attachment_hud_camera(screen_w, screen_h, map_data, vehicle, attachment)
    local hud_pos = vec2(screen_w / 2, screen_h / 2)
    local col = color8(0, 255, 0, 255)
    render_attachment_vision(screen_w, screen_h, map_data, vehicle, attachment)

    local outer_radius = 72
    local inner_radius = outer_radius - 5
    render_circle(hud_pos, inner_radius, 16, col)

    if attachment:get_is_zoom_capable() then
        g_render_rwr = false
        local zoom_factor = attachment:get_zoom_factor()
        local angle = math.pi * 0.5 * zoom_factor
        update_ui_image_rot(hud_pos:x() + math.cos(angle - math.pi) * outer_radius, hud_pos:y() + math.sin(angle - math.pi) * outer_radius, atlas_icons.hud_zoom_indicator_2, col, angle)
        --update_ui_image_rot(hud_pos:x(), hud_pos:y() - 0.5, atlas_icons.hud_zoom_indicator, col, 0)
        update_ui_rectangle(hud_pos:x() - 1, hud_pos:y(), 3, 1, col)
        update_ui_rectangle(hud_pos:x(), hud_pos:y() - 1, 1, 3, col)

        if zoom_factor > 0.01 then
            render_circle(hud_pos, lerp(inner_radius, inner_radius * 0.9, zoom_factor), 16, col)
        end

        local zoom_power = zoom_factor * 5
        local display_zoom = 2 ^ zoom_power
        update_ui_text(hud_pos:x() + math.cos(math.pi * 0.75) * outer_radius - 200, hud_pos:y() + math.sin(math.pi * 0.75) * outer_radius, string.format("%.2fx", display_zoom), 200, 2, col, 0)
    end

    --local hit_pos = attachment:get_hitscan_position()
    --local dist = vec3_dist(update_get_camera_position(), hit_pos)
    --update_ui_text(hud_pos:x() + math.cos(math.pi * 0.25) * outer_radius, hud_pos:y() + math.sin(math.pi * 0.25) * outer_radius, string.format("%.0f", dist) .. update_get_loc(e_loc.acronym_meters), 200, 0, col, 0)
    
    local range_pos = vec2( (hud_pos:x() + math.cos(math.pi * 0.25) * outer_radius) - 40, (hud_pos:y() + math.sin(math.pi * 0.25) * outer_radius) - 50 )
    render_attachment_range(range_pos, attachment, true)
    render_camera_forward_axis(screen_w, screen_h, vehicle)

    return true
end

function render_attachment_hud_bomb(screen_w, screen_h, map_data, vehicle, attachment)
    if attachment:get_control_mode() == "manual" then
        local linked_attachments = {}
        
        if attachment:get_is_control_linked() then
            for i = 0, vehicle:get_attachment_count() - 1 do
                local attachment_other = vehicle:get_attachment(i)

                if attachment_other:get() and attachment_other:get_definition_index() == attachment:get_definition_index() and attachment_other:get_control_mode() == "manual" and attachment_other:get_ammo_remaining() > 0 then
                    table.insert(linked_attachments, attachment_other)
                end
            end
        end

        local self_pos = vehicle:get_position()

        for i = 1, #linked_attachments do
            local predicted_hit_pos = linked_attachments[i]:get_bomb_hit_position()
            local hit_pos_screen = update_world_to_screen(predicted_hit_pos)
            local c_green = color8(0, 255, 0, 255)
            local c_red = color8(255, 0, 0, 255)
            local ccip_col = c_green
            local gnd_mode = "CCIP"
            local tgt_dist = -1
            if g_selected_target_id ~= 0 then
                local selected_target = update_get_map_vehicle_by_id(g_selected_target_id)
                if selected_target:get() then
                    gnd_mode = "CCRP"
                    -- compare hit pos with target loc
                    local tgt_pos = selected_target:get_position()
                    local ccrp_dist = vec2_dist(tgt_pos, predicted_hit_pos)
                    tgt_dist = ccrp_dist
                    local approaching = true
                    local self_tgt_dist = vec2_dist(tgt_pos, self_pos)

                    if self_tgt_dist < tgt_dist then
                        approaching = false
                    end

                    if ccrp_dist > 1500 then
                        ccrp_dist = 1500
                    end

                    local pip_y = 90
                    local release_y_start = 40
                    local release_range = pip_y - release_y_start

                    local release_y_frac = 1 - (ccrp_dist / 1500)

                    local pip_middle = ((screen_w / 2) + hit_pos_screen:x()) / 2
                    local bar_middle = (pip_middle + hit_pos_screen:x()) / 2

                    if ccrp_dist < 30 then
                        if bar_middle > (screen_w / 2) - 15 and bar_middle < (screen_w / 2) + 15 then
                            ccip_col = c_red
                        end
                    end
                    -- draw ccrp bars
                    -- release point
                    if approaching then
                        update_ui_rectangle(
                                bar_middle - 10,
                                release_y_start + (release_y_frac * release_range),
                                20, 2, ccip_col)
                    end
                    -- pipper
                    update_ui_rectangle(pip_middle - 20, pip_y, 10, 1, ccip_col)
                    update_ui_rectangle(pip_middle + 10, pip_y, 10, 1, ccip_col)
                end
            end

            update_ui_text(325, 200,
                    gnd_mode, 200, 0, c_green, 0)
            if tgt_dist > 0 then
                update_ui_text(350, 200,
                        string.format("%dm", math.ceil(tgt_dist)), 64, 0, c_red, 0)
            end

        
            -- draw a line from our velocity vector to the CCIP point
            update_ui_line(
                    screen_w / 2,
                    32,
                    hit_pos_screen:x(),
                    hit_pos_screen:y(),
                    color8(0, 255, 0, 255))

            update_ui_image_rot(hit_pos_screen:x(), hit_pos_screen:y(), atlas_icons.hud_impact_marker, color8(0, 255, 0, 255), 0)
        end
    end

    render_attachment_vision(screen_w, screen_h, map_data, vehicle, attachment)

    return false
end

function render_attachment_hud_torpedo(screen_w, screen_h, map_data, vehicle, attachment)
    render_attachment_vision(screen_w, screen_h, map_data, vehicle, attachment)

    if attachment:get_control_mode() == "manual" then
        local linked_attachments = {}
         
        if attachment:get_is_control_linked() then
            for i = 0, vehicle:get_attachment_count() - 1 do
                local attachment_other = vehicle:get_attachment(i)

                if attachment_other:get() and attachment_other:get_definition_index() == attachment:get_definition_index() and attachment_other:get_control_mode() == "manual" and attachment_other:get_ammo_remaining() > 0 then
                    table.insert(linked_attachments, attachment_other)
                end
            end
        end

        for i = 1, #linked_attachments do
            local predicted_hit_pos = linked_attachments[i]:get_bomb_hit_position()
            local hit_pos_screen = update_world_to_screen(predicted_hit_pos)
        
            update_ui_image_rot(hit_pos_screen:x(), hit_pos_screen:y(), atlas_icons.hud_impact_marker, color8(0, 255, 0, 255), 0)
        end
    end

    return false
end

function render_attachment_hud_missile(screen_w, screen_h, map_data, vehicle, attachment)
    local hud_pos = vec2(screen_w / 2, screen_h / 2)
    local col = color8(0, 255, 0, 255)
    local render_heat = false
    -- if this is the TV, AA or IR, render the IR-ST overlays
    local def = attachment:get_definition_index()
    if attachment:get_ammo_remaining() > 0 then
        if def == e_game_object_type.attachment_hardpoint_missile_ir
                or def == e_game_object_type.attachment_hardpoint_missile_aa
        then
            render_heat = true
        end
    end
    
    render_attachment_vision(screen_w, screen_h, map_data, vehicle, attachment, render_heat)
    if attachment:get_definition_index() == e_game_object_type.attachment_turret_missile then
        render_turret_vehicle_direction(screen_w, screen_h, vehicle, attachment, col)
    end

    update_ui_image_rot(hud_pos:x() + 1, hud_pos:y() + 1, atlas_icons.hud_horizon_cursor, col, 0)
    render_atachment_projectile_cooldown(hud_pos, attachment, true, color8(0, 255, 0, 255))

    return false
end

function render_attachment_hud_tv_missile(screen_w, screen_h, map_data, vehicle, attachment, local_peer_id)
    local function render_camera_crosshair(x, y, rad, size, col)
        update_ui_rectangle(x - rad, y - rad, 1, size, col)
        update_ui_rectangle(x - rad, y - rad, size, 1, col)
        update_ui_rectangle(x + rad, y - rad, 1, size, col)
        update_ui_rectangle(x + rad - size, y - rad, size, 1, col)
        update_ui_rectangle(x - rad, y + rad - size, 1, size, col)
        update_ui_rectangle(x - rad, y + rad, size, 1, col)
        update_ui_rectangle(x + rad, y + rad - size, 1, size, col)
        update_ui_rectangle(x + rad - size, y + rad, size + 1, 1, col)
    end
    
    local hud_pos = vec2(screen_w / 2, screen_h / 2)
    local col = color8(0, 255, 0, 255)
    local col_red = color8(255, 0, 0, 255)
    
    local is_viewing_missile = attachment:get_is_viewing_sub_camera()

    if is_viewing_missile then
        render_attachment_vision(screen_w, screen_h, map_data, vehicle, attachment, true)

        if g_animation_time % 500 > 250 then
            render_camera_crosshair(hud_pos:x(), hud_pos:y(), 48, 16, col)
        end

        render_camera_crosshair(hud_pos:x(), hud_pos:y(), 8, 4, col)

        local vehicle_pos = vehicle:get_position()
        local camera_pos = update_get_camera_position()
        local dist = vec3_dist(vehicle_pos, camera_pos)
        local tv_max_range = 5000
        local dist_max = math_min(dist, tv_max_range)
        local remain = tv_max_range - dist_max
        -- render a range bar chart and pointer towards the launcher
        if remain > 0 then
            local remain_frac = remain / tv_max_range
            local bar_col = col
            if remain_frac < 0.2 then
                bar_col = color_enemy
            elseif remain_frac < 0.4 then
                bar_col = color_status_dark_yellow
            end
            update_ui_rectangle(
                    hud_pos:x() - 100, hud_pos:y() + 61, 42 * remain_frac, 2, bar_col
            )
            update_ui_rectangle_outline(
                    hud_pos:x() - 100, hud_pos:y() + 60, 42, 4, col
            )
            -- add the compass mark for the aircraft
            render_extra_compass_waypoint(vehicle_pos, color_white, 3)
        end

        update_ui_image(hud_pos:x() - 100, hud_pos:y() + 50, atlas_icons.column_distance, col, 0)
        update_ui_text(hud_pos:x() - 100 + 12, hud_pos:y() + 50, string.format("%.0f", dist) .. update_get_loc(e_loc.acronym_meters), 200, 0, col, 0)
        update_ui_rectangle(hud_pos:x(), hud_pos:y() - 1, 1, 3, col)
        update_ui_rectangle(hud_pos:x() - 1, hud_pos:y(), 3, 1, col)

        if dist > 4000 then
            render_warning_text(hud_pos:x(), hud_pos:y() + 50, update_get_loc(e_loc.upp_range), col_red)
        end

        local hud_size = vec2(230, 140)
        local hud_min = vec2(hud_pos:x() - hud_size:x() / 2, hud_pos:y() - hud_size:y() / 2)
        render_altitude_meter(vec2(hud_min:x() + hud_size:x() - 16, hud_min:y() + (hud_size:y() - 110) / 2), camera_pos:y(), col)

        g_is_render_speed = false
        g_is_render_altitude = false
        g_is_render_fuel = false
        g_is_render_hp = false
        g_is_render_control_mode = false
        g_is_render_compass = true
        g_render_rwr = false

        if attachment:get_control_mode() == "manual" and attachment:get_is_controlling_peer() then
            render_mouse_flight_axis(hud_pos)
        end

        return true
    else
        if attachment:get_ammo_remaining() > 0 then
            render_attachment_vision(screen_w, screen_h, map_data, vehicle, attachment, true)
            render_camera_crosshair(hud_pos:x(), hud_pos:y(), 48, 16, col)
            render_camera_crosshair(hud_pos:x(), hud_pos:y(), 8, 4, col)
            update_ui_image_rot(hud_pos:x() + 1, hud_pos:y() + 1, atlas_icons.hud_horizon_cursor, col, 0)

            return true
        else
            update_ui_image_rot(hud_pos:x() + 1, hud_pos:y() + 1, atlas_icons.hud_horizon_cursor, col, 0)
            return false
        end
    end
end

function render_attachment_hud_fuel_tank(screen_w, screen_h, attachment)
    return false
end

function render_attachment_hud_chaingun(screen_w, screen_h, map_data, tick_fraction, vehicle, attachment)
    local hud_pos = vec2(screen_w / 2, screen_h / 2)
    local col = color8(0, 255, 0, 255)
    local target_locked = false
    render_attachment_vision(screen_w, screen_h, map_data, vehicle, attachment)
    local show_crosshair = true
    local gun_funnel_side_dist = 5
    local gun_funnel_forward_dist = 30

    if g_selected_target_type == 1 and g_selected_target_id ~= 0 then
        local selected_target = update_get_map_vehicle_by_id(g_selected_target_id)

        if selected_target:get() then
            target_locked = true
            local target_def = selected_target:get_definition_index()
            local lead_position = attachment:get_gun_lead_position(selected_target:get_position(), selected_target:get_linear_velocity())
            local lead_position_screen, is_clamped = update_world_to_screen(lead_position)

            if g_debug_enabled then
                draw_world_screen_circle(screen_w, lead_position, 5.5)
            end

            if is_clamped == false then
                local target_pos_screen, is_target_clamped = update_world_to_screen(selected_target:get_position())

                if is_target_clamped == false then
                    local lead_col = color8(255, 0, 0, 200)
                    -- update_ui_line(target_pos_screen:x(), target_pos_screen:y(), lead_position_screen:x(), lead_position_screen:y(), lead_col)
                    if get_is_vehicle_air(target_def) then
                        if g_rev_gun_funnel then
                            update_gun_funnel(tick_fraction, vehicle, gun_funnel_side_dist, gun_funnel_forward_dist)
                            render_gun_funnel(tick_fraction, vehicle, gun_funnel_side_dist, gun_funnel_forward_dist, color8(0, 255, 0, 255), lead_position)
                            show_crosshair = false
                        end

                        if show_crosshair then
                            local dist = vec3_dist(lead_position, vehicle:get_position())
                            local smx = screen_w / 2

                            local lead_dx = lead_position_screen:x() - target_pos_screen:x()
                            if math_abs(lead_dx) < smx then
                                local lead_dy = lead_position_screen:y() - target_pos_screen:y()

                                local label_x = lead_dx * 2
                                local label_y = lead_dy * 2

                                if label_x > 0 then
                                    label_x = math_max(40, math_min(60, label_x))
                                elseif label_x < 1 then
                                    label_x = math_min(-40, math_max(-60, label_x))
                                end
                                if label_y > 60 then
                                    label_y = 60
                                elseif label_y < -60 then
                                    label_y = -60
                                end
                                local lead_radius = 16
                                local dist_col = col
                                if dist < 400 then
                                    dist_col = color_status_dark_yellow
                                end
                                update_ui_text(lead_position_screen:x() + label_x - lead_radius, lead_position_screen:y() + label_y,
                                        string.format("%dm", math.floor(dist)), 42, 1, dist_col, 0)

                                -- update_ui_line(lead_position_screen:x() - lead_radius + 3, lead_position_screen:y(), lead_position_screen:x() - lead_radius - 3, lead_position_screen:y(), lead_col)
                                -- update_ui_line(lead_position_screen:x() + 2, lead_position_screen:y() + lead_radius - 1, lead_position_screen:x() + 2, lead_position_screen:y() + lead_radius + 4, lead_col)
                                --render_circle(lead_position_screen, lead_radius, 8, lead_col)
                            end

                            update_ui_image_rot(lead_position_screen:x(), lead_position_screen:y(), atlas_icons.crosshair, lead_col, 0)
                        end
                    end
                end
            end
        end
    end
    if show_crosshair then
        render_gun_crosshair(hud_pos:x(), hud_pos:y(), col, 20)
    end

    return false
end

function render_gun_crosshair(x, y, col, radius)
    if g_hide_horizon_ladder then
        local c = color8(col:r(), col:g(), col:b(), math.floor(col:a() * 0.8))
        update_ui_line(x, y, x + 1, y, c)
        update_ui_line(x + 1, y - radius - 2, x + 1, y - radius + 5, col)
        update_ui_line(x + 1, y + radius - 5, x + 1, y + radius + 2, col)
        update_ui_line(x - radius - 2, y, x - radius + 14, y, col)
        update_ui_line(x + radius - 12, y, x + radius + 4, y, col)
    else
        update_ui_image_rot(x, y, atlas_icons.hud_gun_crosshair, col, 0)
    end
end

function render_attachment_hud_ciws(screen_w, screen_h, map_data, vehicle, attachment)
    local hud_pos = vec2(screen_w / 2, screen_h / 2)
    local col = color8(0, 255, 0, 255)

    render_attachment_vision(screen_w, screen_h, map_data, vehicle, attachment)
    render_attachment_range(hud_pos, attachment)
    render_turret_vehicle_direction(screen_w, screen_h, vehicle, attachment, col)

    -- always render the lead for the nearest hostile air unit
    local nearest_hostile_air = find_nearest_vehicle_types(vehicle, {
        e_game_object_type.chassis_air_wing_light,
        e_game_object_type.chassis_air_rotor_light,
        e_game_object_type.chassis_air_rotor_heavy,
        e_game_object_type.chassis_air_wing_heavy,
    }, true, nil)

    local forced_target = false

    if nearest_hostile_air ~= nil and g_selected_target_id == 0 then
        if vehicle:get_team_id() ~= nearest_hostile_air:get_team_id() then
            local self_pos = vehicle:get_position()
            local nearest_pos = nearest_hostile_air:get_position()
            local dist = vec3_dist(self_pos, nearest_pos)
            if dist < 1500 then
                g_selected_target_type = 1
                forced_target = true
                g_selected_target_id = nearest_hostile_air:get_id()
            end
        end
    end

    if g_selected_target_type == 1 and g_selected_target_id ~= 0 then
        local selected_target = update_get_map_vehicle_by_id(g_selected_target_id)

        if selected_target:get() then

            local self_pos = vehicle:get_position()
            local target_pos = selected_target:get_position()
            local dist = vec3_dist(self_pos, target_pos)

            local lead_position = attachment:get_gun_lead_position(selected_target:get_position(), selected_target:get_linear_velocity())
            local lead_position_screen, is_clamped = update_world_to_screen(lead_position)

            if is_clamped == false then
                local target_pos_screen, is_target_clamped = update_world_to_screen(selected_target:get_position())

                if is_target_clamped == false then
                    local lead_col = color8(255, 0, 0, 200)
                    update_ui_line(target_pos_screen:x(), target_pos_screen:y(), lead_position_screen:x(), lead_position_screen:y(), lead_col)

                    -- draw a square,  vary size based on distance
                    local dist_max = 1500
                    local dist_scale = dist_max - dist

                    if dist_scale > 0 then
                        local size = 20 * ( 1 - ( dist / dist_max))
                        local lx = lead_position_screen:x() - round_int(size / 2)
                        local ly = lead_position_screen:y() - round_int(size / 2)
                        update_ui_rectangle_outline(
                                lx,
                                ly,
                                size,
                                size,
                                lead_col)

                        update_ui_image_rot(lx + (size /2), ly + (size/2), atlas_icons.hud_gun_crosshair, lead_col, 0)

                    end
                end
            end
        end
    end

    update_ui_image_rot(hud_pos:x() + 1, hud_pos:y() + 1, atlas_icons.hud_gun_crosshair, col, 0)

    if attachment:get_is_zoom_capable() then
        local zoom_factor = attachment:get_zoom_factor()
        local zoom_power = zoom_factor * 3
        local display_zoom = 2 ^ zoom_power
        update_ui_text(hud_pos:x() - 250, hud_pos:y() + 50, string.format("%.2fx", display_zoom), 200, 2, col, 0)
    end

    if forced_target then
        g_selected_target_id = -1
        g_selected_target_type = 0
    end

    return false
end

function render_atachment_projectile_cooldown(pos, attachment, is_heavy, col)
    local function bar_arc(pos, angle_from, angle_to, rad_inner, rad_outer, col)
        local step = math.pi / 16

        if angle_from > angle_to then
            local temp = angle_to
            angle_to = angle_from
            angle_from = temp
        end

        update_ui_begin_triangles()

        for angle = angle_from, angle_to, step do
            local angle_prev = angle
            local angle_next = math.min(angle + step, angle_to)
            local p0 = vec2(pos:x() + math.cos(angle_prev) * rad_inner, pos:y() + math.sin(angle_prev) * rad_inner)
            local p1 = vec2(pos:x() + math.cos(angle_prev) * rad_outer, pos:y() + math.sin(angle_prev) * rad_outer)
            local p2 = vec2(pos:x() + math.cos(angle_next) * rad_inner, pos:y() + math.sin(angle_next) * rad_inner)
            local p3 = vec2(pos:x() + math.cos(angle_next) * rad_outer, pos:y() + math.sin(angle_next) * rad_outer)
            update_ui_add_triangle(p0, p2, p1, col)
            update_ui_add_triangle(p1, p2, p3, col)
        end

        update_ui_end_triangles()
    end

    local projectile_cooldown = attachment:get_projectile_cooldown_factor()

    if projectile_cooldown < 1 then
        local bar_factor = 1 - projectile_cooldown
        local rad = 5
        local thickness = 1

        if is_heavy then
            rad = 8
            thickness = 2
        end

        bar_arc(vec2(pos:x(), pos:y() + 1), -math.pi, lerp(-math.pi, 0, bar_factor), rad, rad + thickness, col)
        bar_arc(vec2(pos:x(), pos:y()), 0, lerp(0, math.pi, bar_factor), rad, rad + thickness, col)
    end
end

g_current_info_target = nil

function render_attachment_hud_cannon(screen_w, screen_h, map_data, vehicle, attachment, def) 
    local hud_pos = vec2(screen_w / 2, screen_h / 2)
    local col = color8(0, 255, 0, 255)
    local def = attachment:get_definition_index()

    render_attachment_vision(screen_w, screen_h, map_data, vehicle, attachment)
    render_attachment_range(hud_pos, attachment)
    render_turret_vehicle_direction(screen_w, screen_h, vehicle, attachment, col)

    update_ui_image_rot(hud_pos:x() + 1, hud_pos:y() + 1, atlas_icons.hud_horizon_cursor, col, 0)

    local is_heavy = def == e_game_object_type.attachment_turret_battle_cannon
                  or def == e_game_object_type.attachment_turret_carrier_main_gun
                  or def == e_game_object_type.attachment_turret_heavy_cannon

    render_atachment_projectile_cooldown(hud_pos, attachment, is_heavy, col)

    if attachment:get_is_zoom_capable() then
        local zoom_factor = attachment:get_zoom_factor()
        local zoom_power = zoom_factor * 3
        local display_zoom = 2 ^ zoom_power
        update_ui_text(hud_pos:x() - 250, hud_pos:y() + 50, string.format("%.2fx", display_zoom), 200, 2, col, 0)
        
        if (def == e_game_object_type.attachment_turret_battle_cannon or def == e_game_object_type.attachment_turret_heavy_cannon) and display_zoom > 1 then
            local projectile_gravity = 50 / 30
            local projectile_speed = 600
            local projectile_velocity = update_get_camera_forward()
            projectile_velocity:x(projectile_velocity:x() * projectile_speed)
            projectile_velocity:y(projectile_velocity:y() * projectile_speed)
            projectile_velocity:z(projectile_velocity:z() * projectile_speed)


            local step_amounts = { 1000, 500, 250, 100 }
--            if def == e_game_object_type.attachment_turret_heavy_cannon then step_amounts = { 800, 400, 200, 100 } end
            local step = step_amounts[math.floor(zoom_power) + 1]

            local function get_drop_pos(dist)
                local travel_time = dist / (projectile_speed / 30)
                local drop_position = update_get_camera_position()
                drop_position:x(drop_position:x() + projectile_velocity:x() * travel_time)
                drop_position:y(drop_position:y() + projectile_velocity:y() * travel_time - 0.5 * projectile_gravity * travel_time * travel_time)
                drop_position:z(drop_position:z() + projectile_velocity:z() * travel_time)
                return drop_position
            end

            if g_current_info_target ~= nil then
                local target_v = g_current_info_target.vehicle
                if target_v and target_v:get() then
                    local dist = math.sqrt(g_current_info_target.dist_sq)
                    local drop_position = get_drop_pos(dist)
                    local screen_pos = update_world_to_screen(drop_position)
                    local v_y = screen_pos:y()
                    if v_y > screen_h / 2 and v_y < 0.88 * screen_h then
                        update_ui_line(
                                hud_pos:x() - 6,
                                v_y,
                                hud_pos:x(),
                                v_y,
                                color_white)
                        update_ui_line(
                                hud_pos:x(),
                                v_y - 2,
                                hud_pos:x(),
                                v_y + 3,
                                color_white)
                    end
                end
            end

            for i = step, step * 5, step do
                if i > 0 and i <= step_amounts[1] * 3 then
                    local travel_time = math.max(1, i) / (projectile_speed / 30)
                    local drop_position = update_get_camera_position()
                    drop_position:x(drop_position:x() + projectile_velocity:x() * travel_time)
                    drop_position:y(drop_position:y() + projectile_velocity:y() * travel_time - 0.5 * projectile_gravity * travel_time * travel_time)
                    drop_position:z(drop_position:z() + projectile_velocity:z() * travel_time)

                    local screen_pos = update_world_to_screen(drop_position)

                    if screen_pos:y() < hud_pos:y() + 60 then
                        update_ui_line(screen_w / 2 - 3, screen_pos:y(), screen_w / 2 + 2, screen_pos:y(), color8(0, 255, 0, 255))

                        if (i / step) % 2 == 0 then
                            update_ui_text(screen_w / 2 + 4, screen_pos:y() - 5, string.format("%d", i) .. update_get_loc(e_loc.acronym_meters), 64, 0, color8(0, 255, 0, 255), 0)
                        end
                    end
                end
            end
        end
    end

    return false
end

function render_attachment_hud_artillery(screen_w, screen_h, map_data, vehicle, attachment) 
    local hud_pos = vec2(screen_w / 2, screen_h / 2)
    local hud_size = vec2(180, 89)
    local col = color8(0, 255, 0, 255)

    render_turret_vehicle_direction(screen_w, screen_h, vehicle, attachment, col)
    render_attachment_vision(screen_w, screen_h, map_data, vehicle, attachment)

    update_ui_image_rot(hud_pos:x() + 1, hud_pos:y() + 1, atlas_icons.hud_horizon_cursor, col, 0)
    render_atachment_projectile_cooldown(hud_pos, attachment, true, col)

    if attachment:get_is_zoom_capable() then
        local zoom_factor = attachment:get_zoom_factor()
        local zoom_power = zoom_factor * 3
        local display_zoom = 2 ^ zoom_power
        update_ui_text(hud_pos:x() - 250, hud_pos:y() + 50, string.format("%.2fx", display_zoom), 200, 2, col, 0)
    end

    local cam_side = update_get_camera_side()
    local artillery_pos, is_valid_artillery_hit = attachment:get_artillery_hit_position()
    local hit_accuracy = 0

    if is_valid_artillery_hit then
        local hit_pos = attachment:get_hitscan_position()
        local hit_pos_to_artillery_pos = vec3(artillery_pos:x() - hit_pos:x(), artillery_pos:y() - hit_pos:y(), artillery_pos:z() - hit_pos:z())

        local cam_side_xz = vec3_normal(vec3(cam_side:x(), 0, cam_side:z()))

        local artillery_pos_distance = math.abs(vec3_dot(hit_pos_to_artillery_pos, cam_side_xz))
        artillery_pos_distance = math.max(artillery_pos_distance, math.abs(artillery_pos:y() - hit_pos:y()))
        hit_accuracy = (1 - clamp(artillery_pos_distance / 40, 0, 1)) * 100

        local shot_dist = vec3_dist( vehicle:get_position(), artillery_pos )
        update_ui_text(hud_pos:x() + 50, hud_pos:y() + 50, string.format("%.0f", shot_dist) .. update_get_loc(e_loc.acronym_meters), 200, 0, col, 0)
    end

    local roll = math.pi / 2 - math.acos(vec3_dot(cam_side, vec3(0, 1, 0)))

    update_ui_text(hud_pos:x() + hud_size:x() / 2 - 110, hud_pos:y() + hud_size:y() / 2 - 10, "R " .. string.format("%5.2f", math.deg(roll)), 100, 2, col, 0)
    update_ui_text(hud_pos:x() + hud_size:x() / 2 - 110, hud_pos:y() + hud_size:y() / 2 - 20, string.format("%.0f%%", hit_accuracy), 100, 2, col, 0)

    update_ui_line(hud_pos:x() - math.cos(roll) * 30, hud_pos:y() - math.sin(roll) * 30, hud_pos:x() - math.cos(roll) * 15, hud_pos:y() - math.sin(roll) * 15, col)
    update_ui_line(hud_pos:x() + math.cos(roll) * 30, hud_pos:y() + math.sin(roll) * 30, hud_pos:x() + math.cos(roll) * 15, hud_pos:y() + math.sin(roll) * 15, col)

    local is_blink_on = g_animation_time % 500 > 250
    local col_red = color8(255, 0, 0, 255)

    if is_valid_artillery_hit then
        local artillery_pos_screen = update_world_to_screen(artillery_pos)
        update_ui_image_rot(artillery_pos_screen:x(), artillery_pos_screen:y(), atlas_icons.hud_impact_marker, col, 0)
    end

    local cam_forward = update_get_camera_forward()
    cam_forward = vec3_normal(vec3(cam_forward:x(), 0, cam_forward:z()))
    local gun_forward = attachment:get_projectile_spawn_direction()
    local gun_angle = math.acos(clamp(vec3_dot(cam_forward, gun_forward), 0, 1))

    local angle_display_size = 20
    local angle_display_pos = vec2(hud_pos:x() - hud_size:x() * 0.5 + 10, hud_pos:y() + hud_size:y() * 0.5)
    update_ui_line(angle_display_pos:x(), angle_display_pos:y(), angle_display_pos:x() + angle_display_size, angle_display_pos:y(), col)
    update_ui_line(angle_display_pos:x(), angle_display_pos:y(), angle_display_pos:x() + math.cos(-gun_angle) * angle_display_size, angle_display_pos:y() + math.sin(-gun_angle) * angle_display_size, col)
    
    update_ui_line(
        math.floor(angle_display_pos:x() + math.cos(-gun_angle) * angle_display_size), 
        math.floor(angle_display_pos:y() + math.sin(-gun_angle) * angle_display_size), 
        math.floor(angle_display_pos:x() + math.cos(-gun_angle) * angle_display_size - math.cos(-gun_angle + math.pi / 4) * 5), 
        math.floor(angle_display_pos:y() + math.sin(-gun_angle) * angle_display_size - math.sin(-gun_angle + math.pi / 4) * 5),
        col
    )

    update_ui_line(
        math.floor(angle_display_pos:x() + math.cos(-gun_angle) * angle_display_size), 
        math.floor(angle_display_pos:y() + math.sin(-gun_angle) * angle_display_size), 
        math.floor(angle_display_pos:x() + math.cos(-gun_angle) * angle_display_size - math.cos(-gun_angle - math.pi / 4) * 5), 
        math.floor(angle_display_pos:y() + math.sin(-gun_angle) * angle_display_size - math.sin(-gun_angle - math.pi / 4) * 5),
        col
    )

    local angle_step = math.pi / 10
    local steps = gun_angle / angle_step
    local angle_size = angle_display_size * 0.6

    for i = 0, steps do
        local angle_0 = math.min(i * angle_step, gun_angle)
        local angle_1 = math.min(i * angle_step + angle_step, gun_angle)

        update_ui_line(
            math.floor(angle_display_pos:x() + math.cos(-angle_0) * angle_size), 
            math.floor(angle_display_pos:y() + math.sin(-angle_0) * angle_size), 
            math.floor(angle_display_pos:x() + math.cos(-angle_1) * angle_size), 
            math.floor(angle_display_pos:y() + math.sin(-angle_1) * angle_size), 
            col
        )
    end

    update_ui_text(angle_display_pos:x() + angle_display_size, angle_display_pos:y() - 10, string.format("%.1f", gun_angle / math.pi * 180), 200, 0, col, 0)

    return false
end

function render_attachment_hud_flare(screen_w, screen_h, map_data, vehicle, attachment)
    render_attachment_vision(screen_w, screen_h, map_data, vehicle, attachment)
    return false
end

function render_attachment_hud_radar(screen_w, screen_h, map_data, vehicle, attachment)
    local hud_pos = vec2(screen_w / 2, screen_h / 2)
    local hud_size = vec2(180, 89)
    local hud_min = vec2(hud_pos:x() - hud_size:x() / 2, hud_pos:y() - hud_size:y() / 2)
    local hud_max = vec2(hud_pos:x() + hud_size:x() / 2, hud_pos:y() + hud_size:y() / 2)
    local col = color8(0, 255, 0, 255)
    local col_red = color8(255, 0, 0, 255)

    local is_disabled = attachment:get_is_radar_disabled()

    if is_disabled then
        render_warning_text(hud_pos:x(), hud_pos:y(), update_get_loc(e_loc.upp_interference), col_red)
        update_ui_image(hud_pos:x() - 7, hud_max:y() - 8, atlas_icons.icon_attachment_16_air_radar, color8(255, 0, 0, 255), 0)
        update_ui_text(hud_pos:x() - 128, hud_max:y() + 8, update_get_loc(e_loc.upp_radar_disabled), 256, 1, color8(255, 0, 0, 255), 0)
    else
        g_is_map_overlay = false
    end

    return true
end

function render_attachment_hud_sonic_pulse(screen_w, screen_h, map_data, vehicle, attachment)
    local hud_pos = vec2(screen_w / 2, screen_h / 2)
    local hud_size = vec2(180, 89)
    local hud_min = vec2(hud_pos:x() - hud_size:x() / 2, hud_pos:y() - hud_size:y() / 2)
    local hud_max = vec2(hud_pos:x() + hud_size:x() / 2, hud_pos:y() + hud_size:y() / 2)
    local col = color8(0, 255, 0, 255)

    render_attachment_vision(screen_w, screen_h, map_data, vehicle, attachment)

    return true
end

function render_attachment_hud_robot_dog(screen_w, screen_h, map_data, vehicle, attachment)
    local hud_pos = vec2(screen_w / 2, screen_h / 2)
    local hud_size = vec2(180, 89)
    local hud_min = vec2(hud_pos:x() - hud_size:x() / 2, hud_pos:y() - hud_size:y() / 2)
    local hud_max = vec2(hud_pos:x() + hud_size:x() / 2, hud_pos:y() + hud_size:y() / 2)
    local col = color8(0, 255, 0, 255)
    
    local ammo = attachment:get_ammo_remaining()

    local render_capsule = function(x, y, is_deployed)
        update_ui_push_offset(x, y)
        update_ui_image(0, 0, iff(is_deployed, atlas_icons.hud_capsule_deployed, atlas_icons.hud_capsule_armed), col, 0)
        update_ui_text(8 - 100, 32, iff(is_deployed, update_get_loc(e_loc.upp_empty), update_get_loc(e_loc.upp_armed)), 200, 1, col, 0)
        update_ui_pop_offset()
    end
    
    render_capsule(hud_min:x() + 15, hud_max:y() - 30, ammo < 1)
    render_capsule(hud_max:x() - 30, hud_max:y() - 30, ammo < 1)

    return false
end

function render_attachment_hud_deployable_droid(screen_w, screen_h, map_data, vehicle, attachment)
    local hud_pos = vec2(screen_w / 2, screen_h / 2)
    local hud_size = vec2(180, 89)
    local hud_min = vec2(hud_pos:x() - hud_size:x() / 2, hud_pos:y() - hud_size:y() / 2)
    local hud_max = vec2(hud_pos:x() + hud_size:x() / 2, hud_pos:y() + hud_size:y() / 2)
    local col = color8(0, 255, 0, 255)

    local ammo = attachment:get_ammo_remaining()
    local deploy_factor = attachment:get_target_accuracy()
    local deploy_factor_pivot = 1 - invlerp_clamp(deploy_factor, 0, 0.5)
    local deploy_factor_slide = invlerp_clamp(deploy_factor, 0.5, 0.9)
    local is_deployed = ammo < 1
    local is_deploying = is_deployed == false and deploy_factor > 0

    local deploy_col = iff(is_deployed, color_status_bad, iff(is_deploying, color_status_warning, col))

    update_ui_push_offset(hud_min:x() + 14, hud_max:y() - 22)
    update_ui_rectangle(-4, 0, 1, 22, deploy_col)
    update_ui_rectangle(20, 0, 1, 22, deploy_col)
    update_ui_rectangle(-4, 22, 25, 1, deploy_col)

    update_ui_push_offset(0, -18 * deploy_factor_slide)

    update_ui_rectangle(-1, 0, 1, 20, deploy_col)
    update_ui_rectangle(17, 0, 1, 20, deploy_col)
    update_ui_rectangle(-1, 20, 19, 1, deploy_col)

    if is_deployed == false then
        local function round_to(a, b)
            return math.floor(a / b + 0.5) * b
        end

        local icon_col = iff(is_deployed, color_status_bad, iff(is_deploying, iff(g_animation_time % 500 > 250, color_status_warning, color_empty), col))
        update_ui_image_rot(8, 10, atlas_icons.icon_chassis_16_droid, icon_col, round_to(-math.pi * 0.5 * deploy_factor_pivot, math.pi / 4))
    end

    update_ui_pop_offset()

    update_ui_text(9 - 100, 24, iff(is_deployed, update_get_loc(e_loc.upp_empty), update_get_loc(e_loc.upp_armed)), 200, 1, iff(is_deployed, color_status_bad, col), 0)
    update_ui_pop_offset()

    return false
end

--------------------------------------------------------------------------------
--
-- VEHICLE HUDS
--
--------------------------------------------------------------------------------

function render_ground_hud(screen_w, screen_h, vehicle)
    local hud_size = vec2(230, 140)
    local hud_min = vec2((screen_w - hud_size:x()) / 2, (screen_h - hud_size:y()) / 2)
    local hud_pos = vec2(hud_min:x() + hud_size:x() / 2, hud_min:y() + hud_size:y() / 2)
    local col = color8(0, 255, 0, 255)

    render_airspeed_meter(vec2(hud_min:x(), hud_min:y() + (hud_size:y() - 110) / 2), vehicle, 1, col)
    render_compass(vehicle, vec2(hud_pos:x(), hud_min:y() + hud_size:y()), col)
    render_fuel_gauge(vec2(hud_min:x() + hud_size:x() - 16, hud_pos:y() + 45 - 50), 50, vehicle, col)
    render_damage_gauge(vec2(hud_min:x() + hud_size:x() - 1, hud_pos:y() + 45 - 50), 50, vehicle, col)
    render_control_mode(vec2(hud_min:x() + hud_size:x() - 16, hud_pos:y() + 45 + 5), vehicle, col)

    local def = vehicle:get_definition_index()

    if g_selected_attachment_index == 0 and def ~= e_game_object_type.chassis_land_wheel_mule then
        local turret_index = iff(def == e_game_object_type.chassis_land_wheel_heavy, 2, 1)
        local turret = get_vehicle_attachment(vehicle:get_id(), turret_index)
        if turret ~= nil then
            -- Don't render for the following since they're not turrets
            local turret_def = turret:get_definition_index()
            if  turret_def >= 0 and turret_def < e_game_object_type.count -- Don't render for unknown turrets
            and turret_def ~= e_game_object_type.attachment_turret_robot_dog_capsule
            and turret_def ~= e_game_object_type.attachment_camera_observation
            and turret_def ~= e_game_object_type.attachment_radar_golfball
            then
                render_vehicle_turret_direction(screen_w, screen_h, vehicle, turret, col)
            end
        end
    end

    if get_is_damage_warning(vehicle) then
        local col_red = color8(255, 0, 0, 255)
        render_warning_text(hud_pos:x(), hud_min:y() - 10, update_get_loc(e_loc.upp_dmg_critical), col_red)
    end
    
    if get_is_fuel_warning(vehicle) then
        render_warning_text(hud_pos:x(), warning_y, "FUEL LOW", col_red)
        warning_y = warning_y - 10
    end
end

function render_turret_hud(screen_w, screen_h, vehicle)
    local hud_size = vec2(230, 140)
    local hud_min = vec2((screen_w - hud_size:x()) / 2, (screen_h - hud_size:y()) / 2)
    local hud_pos = vec2(hud_min:x() + hud_size:x() / 2, hud_min:y() + hud_size:y() / 2)
    local col = color8(0, 255, 0, 255)

    render_compass(vehicle, vec2(hud_pos:x(), hud_min:y() + hud_size:y()), col)
    render_damage_gauge(vec2(hud_min:x() + hud_size:x() - 1, hud_pos:y() + 45 - 50), 50, vehicle, col)

    if get_is_damage_warning(vehicle) then
        local col_red = color8(255, 0, 0, 255)
        render_warning_text(hud_pos:x(), hud_min:y() - 10, update_get_loc(e_loc.upp_dmg_critical), col_red)
    end
end

function render_flight_hud(screen_w, screen_h, is_render_center, vehicle)
    local hud_size = vec2(230, 140)
    local hud_min = vec2((screen_w - hud_size:x()) / 2, (screen_h - hud_size:y()) / 2)
    local hud_pos = vec2(hud_min:x() + hud_size:x() / 2, hud_min:y() + hud_size:y() / 2)
    local col = color8(0, 255, 0, 255)
    local col_red = color8(255, 0, 0, 255)
    local pos = vehicle:get_position()
    local warning_y = hud_min:y() - 10
    local is_missile_tracking = vehicle:get_is_missile_tracking()
    local is_stall = vehicle:get_position():y() > 2050
    local screen_team = vehicle:get_team_id()
    local waypoints = {}
    if vehicle.get_waypoint_path then
        waypoints = vehicle:get_waypoint_path()
    end

    if get_is_damage_warning(vehicle) then
        render_warning_text(hud_pos:x(), warning_y, update_get_loc(e_loc.upp_dmg_critical), col_red)
        warning_y = warning_y - 10
    else
        if vehicle:get_linear_speed() < 50 then
            render_ground_hints(screen_w, screen_h, is_render_center, vehicle)
        end
    end
    
    if is_missile_tracking then
        render_warning_text(hud_pos:x(), warning_y, update_get_loc(e_loc.upp_msl_incoming), col_red)
        warning_y = warning_y - 10
    end

    if is_stall then
        render_warning_text(hud_pos:x(), warning_y, update_get_loc(e_loc.upp_stall), col_red)
        warning_y = warning_y - 10
    end
    
    if get_is_fuel_warning(vehicle) then
        render_warning_text(hud_pos:x(), warning_y, "FUEL LOW", col_red)
        warning_y = warning_y - 10
    end

    if g_is_render_speed then
        render_airspeed_meter(vec2(hud_min:x(), hud_min:y() + (hud_size:y() - 110) / 2), vehicle, 10, col)
    end

    if g_is_render_altitude then
        render_altitude_meter(vec2(hud_min:x() + hud_size:x() - 16, hud_min:y() + (hud_size:y() - 110) / 2), vehicle:get_altitude(), col)
    end

    if is_render_center then
        render_artificial_horizion(screen_w, screen_h, hud_pos, vec2(hud_size:x() - 40, hud_size:y()), vehicle, col)
    end

    if g_is_render_compass then
        render_compass(vehicle, vec2(hud_pos:x(), hud_min:y() + hud_size:y()), col)
    end

    if g_is_render_fuel then
        render_fuel_gauge(vec2(hud_min:x() + hud_size:x() + 30, hud_pos:y() + 45 - 50), 50, vehicle, col)
    end

    if g_is_render_hp then
        render_damage_gauge(vec2(hud_min:x() + hud_size:x() + 45, hud_pos:y() + 45 - 50), 50, vehicle, col)
    end

    if g_is_render_control_mode then
        render_control_mode(vec2(hud_min:x() + hud_size:x() + 30, hud_pos:y() + 45 + 5), vehicle, col)
    end
    
    if vehicle:get_control_mode() == "manual" and vehicle:get_is_controlling_peer() then
        render_mouse_flight_axis(hud_pos)
    end


    -- render team markers as yellow waypoints

    local mark_col = color_yellow
    local vpos_2d = vec2(pos:x(), pos:z())
    for i = 1, 4, 1 do
        local m = get_marker_waypoint(screen_team, i)
        if m then
            local mv = m:get_altitude()
            if is_waypoint_value_enabled(mv) then
                local wx, wy = unpack_alt_xy(mv)
                local mp = vec3(wx, 0, wy)
                local mname = get_marker_name(i)
                local mdist = vec2_dist(vec2(wx, wy), vpos_2d) / 1000
                local mtxt = string.format("%s %2.1fkm", mname, mdist)
                render_ground_marker(mark_col, mp, screen_w, screen_h, mtxt)
                render_extra_compass_waypoint(mp, mark_col, 0, mname)
            end
        end
    end

    -- render the next waypoints in view
    local wp_col = col
    local wp_max_range_sq = 10000 * 10000
    for i=1, #waypoints do
        if wp_col:a() > 32 then
            local wp = vec3(waypoints[i]:x(), 0, waypoints[i]:y())
            local dist_sq = vec3_dist_sq(wp, pos)
            if dist_sq < wp_max_range_sq then
                render_ground_marker(wp_col, wp, screen_w, screen_h)
            end
        end
        wp_col = color8(wp_col:r(), wp_col:g(), wp_col:b(), wp_col:a() - 35)
	end
end

function render_barge_hud(screen_w, screen_h, vehicle)
    local hud_size = vec2(230, 140)
    local hud_min = vec2((screen_w - hud_size:x()) / 2, (screen_h - hud_size:y()) / 2)
    local hud_pos = vec2(hud_min:x() + hud_size:x() / 2, hud_min:y() + hud_size:y() / 2)
    local col = color8(0, 255, 0, 255)
    local col_red = color8(255, 0, 0, 255)
    local v_def = vehicle:get_definition_index()

    render_airspeed_meter(vec2(hud_min:x(), hud_min:y() + (hud_size:y() - 110) / 2), vehicle, 1, col)
    render_compass(vehicle, vec2(hud_pos:x(), hud_min:y() + hud_size:y()), col)
    render_fuel_gauge(vec2(hud_min:x() + hud_size:x() - 16, hud_pos:y() + 45 - 50), 50, vehicle, col)
    render_damage_gauge(vec2(hud_min:x() + hud_size:x() - 1, hud_pos:y() + 45 - 50), 50, vehicle, col)
    render_control_mode(vec2(hud_min:x() + hud_size:x() - 16, hud_pos:y() + 45 + 5), vehicle, col)

    if get_is_damage_warning(vehicle) then
        render_warning_text(hud_pos:x(), hud_min:y() - 10, update_get_loc(e_loc.upp_dmg_critical), col_red)
    end

    if v_def == e_game_object_type.chassis_sea_barge then
        local name = rev_get_unit_name(vehicle)
        -- bottom left
        update_ui_text(15, screen_h - 30, name, screen_w, 0, col, 0)
    end
end

function render_carrier_hud(screen_w, screen_h, vehicle)
    local hud_size = vec2(230, 140)
    local hud_min = vec2((screen_w - hud_size:x()) / 2, (screen_h - hud_size:y()) / 2)
    local hud_pos = vec2(hud_min:x() + hud_size:x() / 2, hud_min:y() + hud_size:y() / 2)
    local col = color8(0, 255, 0, 255)

    if g_is_render_compass then
        render_compass(vehicle, vec2(hud_pos:x(), hud_min:y() + hud_size:y()), col)
    end
end


--------------------------------------------------------------------------------
--
-- SPECIALIST HUD ELEMENTS
--
--------------------------------------------------------------------------------

-- Render turret direction relative to driver
function render_vehicle_turret_direction(screen_w, screen_h, vehicle, turret, col)
    local turret_def = turret:get_definition_index()
    local attachment_icon_region, attachment_16_icon_region = get_attachment_icons(turret_def)
--  local icon_w, icon_h = update_ui_get_image_size(attachment_icon_region)

    local hud_size = vec2(230, 140) 
    local hud_min = vec2((screen_w - hud_size:x()) / 2, (screen_h - hud_size:y()) / 2)
    local hud_pos = vec2(hud_min:x() + hud_size:x() / 2, hud_min:y() + hud_size:y() / 2)

    local pos_x = hud_min:x() + hud_size:x() - 6
    local pos_y = hud_pos:y() - 30
    
    local vehicle_pos = vehicle:get_position()
    local vehicle_dir = vehicle:get_forward()
    local turret_hit_pos = turret:get_hitscan_position()
    
    local turret_ang = math.atan( turret_hit_pos:x() - vehicle_pos:x(), turret_hit_pos:z() - vehicle_pos:z() )
    local vehicle_ang = math.atan( vehicle_dir:x(), vehicle_dir:z() )
    
    local projectile_cooldown = math.floor(clamp((1 - turret:get_projectile_cooldown_factor()) * 255, 0, 255))
    local turret_col = color8(projectile_cooldown, 255, projectile_cooldown, 255)
    
    update_ui_image_rot( pos_x, pos_y, atlas_icons.hud_ticker_small, col, -(math.pi / 2) )
    
    if turret_def == e_game_object_type.attachment_turret_missile then
        update_ui_image_rot( pos_x, pos_y - 4, attachment_icon_region, turret_col, -(math.pi / 2) )
    elseif turret_def == e_game_object_type.attachment_turret_droid then
        update_ui_image_rot( pos_x, pos_y - 2, attachment_icon_region, turret_col, turret_ang - vehicle_ang )
    else
        local off_x = math.sin(turret_ang - vehicle_ang) * 4
        local off_y = math.cos(turret_ang - vehicle_ang) * 4
        
        update_ui_image_rot( pos_x + off_x, pos_y - off_y, attachment_icon_region, turret_col, turret_ang - vehicle_ang )
    end
end

function render_attachment_range(hud_pos, attachment, is_camera)
    local hit_dist = iff( is_camera, vec3_dist(update_get_camera_position(), attachment:get_hitscan_position()), attachment:get_hitscan_distance() )
    local is_in_range = iff( is_camera, hit_dist <= 9999, attachment:get_is_hitscan_in_range() )
    local col = color8(0, 255, 0, 255)
    local col_red = color8(255, 0, 0, 255)
    if is_in_range then
        update_ui_text(hud_pos:x() + 50, hud_pos:y() + 50, string.format("%.0f", hit_dist) .. update_get_loc(e_loc.acronym_meters), 200, 0, col, 0)
    else
        local text = update_get_loc(e_loc.upp_range)

        if g_animation_time % 1000 <= 500 then
            text = string.format("%.0f", hit_dist) .. update_get_loc(e_loc.acronym_meters)
        end

        local text_w = update_ui_get_text_size(text, 200, 2)
        local pos_x = hud_pos:x() + 80

        if g_animation_time % 500 > 250 then
            update_ui_image(pos_x - text_w - 10, hud_pos:y() + 50, atlas_icons.hud_warning, col_red, 0)
        end

        update_ui_text(pos_x - 200, hud_pos:y() + 50, text, 200, 2, col_red, 0)
    end
end

function render_warning_text(x, y, text, col)
    update_ui_push_offset(x, y)

    if g_animation_time % 250 > 125 then
        local text_w = update_ui_get_text_size(text, 10000, 0)
        update_ui_image(-text_w / 2 - 12, 0, atlas_icons.hud_warning, col, 0)
        update_ui_image(text_w / 2 + 2, 0, atlas_icons.hud_warning, col, 0)
        update_ui_text(-text_w, 0, text, text_w * 2, 1, col, 0)
    end

    update_ui_pop_offset()
end

function render_control_mode(pos, vehicle, col)
    local control_mode = vehicle:get_control_mode()
    local is_blink_on = g_animation_time % 500 > 250
    local col_blink = color8(col:r(), col:g(), col:b(), iff(is_blink_on, col:a(), 0))
    local col_off = color8(0, 0, 0, 0)

    update_ui_text(pos:x() + 2, pos:y() + 1, update_get_loc(e_loc.upp_acronym_auto), 200, 0, iff(control_mode == "auto", col_blink, col), 0)
    update_ui_text(pos:x() + 10, pos:y() + 1, update_get_loc(e_loc.upp_acronym_manual), 200, 0, iff(control_mode == "manual", col_blink, col), 0)
    update_ui_text(pos:x() + 18, pos:y() + 1, update_get_loc(e_loc.upp_acronym_override), 200, 0, iff(control_mode == "override", col_blink, col), 0)
    update_ui_text(pos:x() + 26, pos:y() + 1, "-", 200, 0, iff(control_mode == "off", col_blink, col), 0)

    update_ui_rectangle_outline(pos:x(), pos:y(), 9, 11, iff(control_mode == "auto", col, col_off))
    update_ui_rectangle_outline(pos:x() + 8, pos:y(), 9, 11, iff(control_mode == "manual", col, col_off))
    update_ui_rectangle_outline(pos:x() + 16, pos:y(), 9, 11, iff(control_mode == "override", col, col_off))
    update_ui_rectangle_outline(pos:x() + 24, pos:y(), 9, 11, iff(control_mode == "off", col, col_off))

end

function render_compass(screen_vehicle, pos, col)
    local width = 120
    g_compass_pos = pos
    local heading = update_get_camera_heading() / math.pi / 2

    local spacing = width / 2
    local total_w = 4 * spacing

    local labels = { update_get_loc(e_loc.upp_compass_n), update_get_loc(e_loc.upp_compass_e), update_get_loc(e_loc.upp_compass_s), update_get_loc(e_loc.upp_compass_w) }
    local v_pos = screen_vehicle:get_position()
    local attachment = screen_vehicle:get_attachment(g_selected_attachment_index)
    if attachment and attachment:get() then
        if attachment:get_definition_index() == e_game_object_type.attachment_hardpoint_missile_tv then
            v_pos = update_get_camera_position()
        end
    end

    if screen_vehicle:get_definition_index() ~= e_game_object_type.chassis_carrier then
        local nearest_crr = find_nearest_vehicle_types(screen_vehicle, {e_game_object_type.chassis_carrier}, false, nil, -10)
        if nearest_crr and nearest_crr:get() then
            render_compass_waypoint(pos:x(), pos:y(), width, nearest_crr:get_position(), color_friendly)
        end

        local st, err = pcall(function()
            -- indicate nearest island as a grey contact

            local nearest_tile = get_nearest_island_tile(v_pos:x(), v_pos:z())
            local tile_pos = nearest_tile:get_position_xz()
            local tile_mark = vec3(tile_pos:x(), 0, tile_pos:y())
            local tile_size = nearest_tile:get_size():x()
            local tile_dist = vec3_dist(tile_mark, v_pos)
            if tile_dist > 1000 then
                local mark_size = round_int(clamp( 6 * tile_size / tile_dist, 6, 48))
                render_compass_waypoint(pos:x(), pos:y() + 9, width, tile_mark, col, mark_size)
            end
        end)
        if not st then
            print(err)
        end

    end
    update_ui_push_clip(pos:x() - width / 2, pos:y(), width, 10)

    for i = 0, 3 do
        local x = wrap_range(pos:x() + i * spacing - heading * total_w, pos:x() - total_w / 2, pos:x() + total_w / 2)

        update_ui_text(x - 3, pos:y(), labels[i + 1], 6, 0, col, 0)

        local substeps = 8
        for j = 1, substeps - 1 do
            local subx = wrap_range(x + j * (spacing / substeps), pos:x() - total_w / 2, pos:x() + total_w / 2)

            if j % 2 == 0 then
                update_ui_line(subx, pos:y() + 3, subx, pos:y() + 7, col)
            else
                update_ui_line(subx, pos:y() + 4, subx, pos:y() + 6, col)
            end
        end
    end

    update_ui_pop_clip()

    update_ui_image_rot(pos:x() - 1, pos:y() + 10, atlas_icons.hud_compass_indicator, col, 0)

    local display_heading = math.floor(iff(heading < 0, 360 + heading * 360, heading * 360))
    update_ui_text(pos:x() - 50, pos:y() + 12, string.format("%03.0f", display_heading), 100, 1, col, 0)
    if screen_vehicle and screen_vehicle.get_waypoint_path then
        local waypoints = screen_vehicle:get_waypoint_path()
        if #waypoints > 0 then
            render_compass_waypoint(pos:x(), pos:y(), width, vec3(waypoints[1]:x(), 0, waypoints[1]:y()), col, 3)
        end
    end
end

function render_ground_hints(screen_w, screen_h, is_render_center, vehicle)
    local alt = vehicle:get_altitude()
    if alt < 205 then
        local alpha = 255
        local col = color8(0, 255, 0, alpha)
        local sz_min = vec2(0, 0)
        local sz_max = vec2(screen_w, screen_h)
        -- draw feint a grid at 100m of x/z at 0m alt
        local position = vehicle:get_position()
        local grid_range = 120
        local alpha_scale = alpha / grid_range
        local grid_size = 50
        local grid_width = 8
        local north = math.floor((position:z() + grid_range) / grid_size) * grid_size
        local south = north - grid_range * 2
        local west = math.floor((position:x() - grid_range) / grid_size) * grid_size
        local east = west + grid_range * 2
        for x=west, east, grid_size do

            for z=south, north, grid_size do
                local dot = vec3(x, 0, z)
                local s1, clamped1 = world_to_screen_clamped(dot, sz_min, sz_max)
                if not clamped1 then
                    -- vary alpha based on distance
                    local dist = vec3_dist(position, dot)

                    local dot_col = color8(col:r(), col:g(), col:b(), clamp(alpha - math.floor(alpha_scale * dist), 0, alpha))

                    local w, cw = world_to_screen_clamped(vec3(x - grid_width, 0, z), sz_min, sz_max)
                    local e, ce = world_to_screen_clamped(vec3(x + grid_width, 0, z), sz_min, sz_max)
                    local n, cn = world_to_screen_clamped(vec3(x, 0, z + grid_width), sz_min, sz_max)
                    local s, cs = world_to_screen_clamped(vec3(x, 0, z - grid_width), sz_min, sz_max)
                    if not (cw and ce and cn and cs) then
                        update_ui_line(w:x(), w:y(), e:x(), e:y(), dot_col)
                        update_ui_line(n:x(), n:y(), s:x(), s:y(), dot_col)
                    end
                end
            end

        end
    end
end

function draw_world_screen_circle(screen_w, world_pos, world_radius)
    local cam_position = update_get_camera_position()
    local dist = vec3_dist(cam_position, world_pos)
    if dist < 1500 then
        local sp, behind = update_world_to_screen(world_pos)
        if not behind then
            local steps = 6
            if dist < 800 then
                if dist < 400 then
                    steps = 12
                else
                    steps = 8
                end
            end
            local sr = get_object_size_on_screen(screen_w, world_pos, world_radius)
            render_circle(sp, sr, steps, color_status_orange)
        end
    end
end

function render_artificial_horizion(screen_w, screen_h, pos, size, vehicle, col)
    --update_ui_push_clip(pos:x() - size:x() / 2, pos:y() - size:y() / 2, size:x(), size:y())

    local scale = 1
    local position = update_get_camera_position()
    local project_dist = 500

    local velocity = vehicle:get_linear_velocity()
    local p_fwd = nil
    local predicted_position = nil
    local projected_velocity = nil
    local speed = vehicle:get_linear_speed()

    local offset_x = 0
    local offset_y = 0

    if speed > 1 then
        if speed > 80 then
            project_dist = 1000
        end

        local p_alt = -100
        local p_project_sec = project_dist
        local p_y = position:y() + (velocity:y() * p_project_sec)

        local p_y_c = 0
        while p_y < 10 do
            p_project_sec = p_project_sec * 0.45
            p_y = position:y() + (velocity:y() * p_project_sec)
            p_y_c = p_y_c + 1
            if p_y_c > 4 then
                break
            end
        end

        projected_velocity = vec3(
                position:x() + velocity:x() * p_project_sec,
                p_y,
                position:z() + velocity:z() * p_project_sec)
        p_alt = projected_velocity:y()

        predicted_position = artificial_horizon_to_screen(screen_w, screen_h, pos, scale, update_world_to_screen(projected_velocity))
        p_fwd = predicted_position
        local vv_col = col
        if p_y < 1 then
            -- the velocity vector projection is underground, this is kind of bad so change the marker to white
            if stable_tick(20, 10) then
                vv_col = color_white
            end
        end
        -- draw velocity vector
        update_ui_image_rot(predicted_position:x(), predicted_position:y(), atlas_icons.hud_horizon_cursor, vv_col, 0)

        Variometer.predicted_vector.x = predicted_position:x()
        Variometer.predicted_vector.y = predicted_position:y()
    end

    local forward = update_get_camera_forward()
    local forward_xz = vec3(forward:x(), 0, forward:z())
    forward_xz = vec3_normal(forward_xz)
    local projected_forward = vec3(position:x() + forward_xz:x() * project_dist, position:y(), position:z() + forward_xz:z() * project_dist)

    --if p_fwd ~= nil then
    --    local vdef = vehicle:get_definition_index()
    --    if vdef == e_game_object_type.chassis_air_wing_light or vdef == e_game_object_type.chassis_air_wing_heavy then
    --        -- find the horizon point relative to the velocity vector
    --        local vector_horizon = vec3(
    --            position:x() + velocity:x() * 1000,
    --            position:y(),
    --            position:z() + velocity:z() * 1000)
    --
    --        local v_s = update_world_to_screen(vector_horizon)
    --        local f_s = update_world_to_screen(projected_forward)
    --        offset_x = v_s:x() - f_s:x()
    --        offset_y = v_s:y() - f_s:y()
    --        if g_revolution_hud_debug ~= nil then
    --            slow_print(string.format("%f %f (%f %f)", offset_x, offset_y, v_s:x(), v_s:y()))
    --            --update_ui_image_rot(
    --            --    clamp(v_s:x(), 20, screen_w - 20),
    --            --    clamp(v_s:y(), 10, screen_h - 10) + 1,
    --            --    atlas_icons.hud_horizon_mid, color_white, 0)
    --        end
    --    end
    --end

    local side_xz = vec3(-forward_xz:z(), 0, forward_xz:x())
    local roll_pos_a = update_world_to_screen(vec3(position:x() + (forward_xz:x() + side_xz:x()) * project_dist, position:y(), position:z() + (forward_xz:z() + side_xz:z()) * project_dist))
    local roll_pos_b = update_world_to_screen(vec3(position:x() + (forward_xz:x() - side_xz:x()) * project_dist, position:y(), position:z() + (forward_xz:z() - side_xz:z()) * project_dist))
    local roll_normal = vec2_normal(vec2(roll_pos_b:x() - roll_pos_a:x(), roll_pos_b:y() - roll_pos_a:y()))
    local roll = vec2_angle(roll_normal, vec2(1, 0))

    local horizon = artificial_horizon_to_screen(screen_w, screen_h, pos, scale, update_world_to_screen(projected_forward))
     -- draw horizon
    local horizon_y = clamp(offset_y + horizon:y(), 2, screen_h - 2)

    if horizon_y == offset_y + horizon:y() then
        if g_hide_horizon_ladder then
            col = color8(col:r(), col:g(), col:b(), math_max(col:a() * 0.8), 0.3)
        end
        update_ui_image_rot(
                clamp(offset_x + horizon:x(), 20, screen_w - 20),
                horizon_y,
                atlas_icons.hud_horizon_mid, col, roll)
    end
    local angle_step_deg = 10
    local angle_step = angle_step_deg / 180 * math.pi
    local steps = math.floor(math.pi * 0.5 / angle_step)
    local angle_width = 20

    if g_hide_horizon_ladder then
        return
    end

    for i = 1, steps do
        projected_forward = vec3(
                position:x() + forward_xz:x() * project_dist,
                position:y() + math.tan(i * angle_step) * project_dist,
                position:z() + forward_xz:z() * project_dist)

        horizon = artificial_horizon_to_screen(screen_w, screen_h, pos, scale, update_world_to_screen(projected_forward))

        if i ~= steps then
            update_ui_image_rot(
                    offset_x + horizon:x(),
                    offset_y + horizon:y(),
                    atlas_icons.hud_horizon_high, col, roll)
            --update_ui_text(horizon:x()-angle_width/2, horizon:y()-5, math.floor(i*angle_step_deg), 20, 1, col, 0)
            local hoz_width = 38
			update_ui_text(
                    offset_x + horizon:x()-angle_width/2-math.floor(hoz_width*math.cos(roll)),
                    offset_y + horizon:y()-5-math.floor(hoz_width*math.sin(roll)),
                    math.floor(i*angle_step_deg), 20, 1, col, 0)
			update_ui_text(
                    offset_x + horizon:x()-angle_width/2+math.floor(hoz_width*math.cos(roll))+1,
                    offset_y + horizon:y()-5+math.floor(hoz_width*math.sin(roll)),
                    math.floor(i*angle_step_deg), 20, 1, col, 0)
        end

        projected_forward = vec3(position:x() + forward_xz:x() * project_dist, position:y() - math.tan(i * angle_step) * project_dist, position:z() + forward_xz:z() * project_dist)
        horizon = artificial_horizon_to_screen(screen_w, screen_h, pos, scale, update_world_to_screen(projected_forward))
        update_ui_image_rot(
                offset_x + horizon:x(),
                offset_y +  horizon:y(),
                atlas_icons.hud_horizon_low, col, roll)
        --update_ui_text(horizon:x()-angle_width/2, horizon:y()-3, math.floor(-i*angle_step_deg), 20, 1, col, 0)
        local hoz_width = 41
		update_ui_text(
                offset_x + horizon:x()-angle_width/2-math.floor(hoz_width*math.cos(roll)),
                offset_y + horizon:y()-3-math.floor(hoz_width*math.sin(roll)),
                math.floor(-i*angle_step_deg), 20, 1, col, 0)
		update_ui_text(
                offset_x + horizon:x()-angle_width/2+math.floor(hoz_width*math.cos(roll))+1,
                offset_y + horizon:y()-3+math.floor(hoz_width*math.sin(roll)),
                math.floor(-i*angle_step_deg), 20, 1, col, 0)
    end

    --update_ui_pop_clip()
end

function artificial_horizon_to_screen(screen_w, screen_h, render_pos, scale, screen_pos)
    return vec2(render_pos:x() + scale * (screen_pos:x() - screen_w / 2), render_pos:y() + scale * (screen_pos:y() - screen_h / 2))
end

function render_altitude_meter(pos, altitude, col)
    update_ui_image(pos:x(), pos:y(), atlas_icons.hud_bracket, col, 0)
    render_altitude_ticker(vec2(pos:x() + 4, pos:y() + 41), altitude, col)

    update_ui_push_clip(pos:x() + 8, pos:y() + 2, 100, 38)
    render_timeline(vec2(pos:x() + 8, pos:y()), vec2(40, 100), 100, 20, altitude / 100 * 20, 0, col, false)
    update_ui_pop_clip()

    update_ui_push_clip(pos:x() + 8, pos:y() + 59, 100, 39)
    render_timeline(vec2(pos:x() + 8, pos:y()), vec2(40, 100), 100, 20, altitude / 100 * 20, 0, col, false)
    update_ui_pop_clip()

    render_timeline(vec2(pos:x() + 1, pos:y()), vec2(40, 100), 100, 20, altitude / 100 * 20, 2, col, false,
        function(x, y) 
            update_ui_line(x, y, x + 2, y, col) 
        end
    )

    update_ui_text(pos:x(), pos:y() + 101, update_get_loc(e_loc.upp_alt), 200, 0, col, 0)
    Variometer:render(pos, col)

end

function render_airspeed_meter(pos, vehicle, step, col)
    update_ui_image(pos:x(), pos:y(), atlas_icons.hud_bracket, col, 2)
    render_airspeed_ticker(vec2(pos:x() - 25, pos:y() + 41), vehicle, col)

    update_ui_push_clip(pos:x() - 31, pos:y() + 2, 100, 38)
    render_timeline(vec2(pos:x() - 31, pos:y()), vec2(40, 100), step, 12, vehicle:get_linear_speed() / step * 12, 2, col, true)
    update_ui_pop_clip()

    update_ui_push_clip(pos:x() - 31, pos:y() + 59, 100, 39)
    render_timeline(vec2(pos:x() - 31, pos:y()), vec2(40, 100), step, 12, vehicle:get_linear_speed() / step * 12, 2, col, true)
    update_ui_pop_clip()

    render_timeline(vec2(pos:x() + 13, pos:y()), vec2(40, 100), step, 12, vehicle:get_linear_speed() / step * 12, 2, col, true, 
        function(x, y) 
            update_ui_line(x, y, x + 2, y, col) 
        end
    )

    update_ui_text(pos:x() - 1, pos:y() + 101, update_get_loc(e_loc.upp_spd), 200, 0, col, 0)

    local throttle_height = 96
    local throttle_factor = vehicle:get_throttle_factor()
    local throttle_bar_size = math.floor(throttle_factor * throttle_height + 0.5)
    update_ui_rectangle(pos:x() + 17, pos:y() + 100 - throttle_bar_size - 2, 2, throttle_bar_size, col)
    update_ui_rectangle(pos:x() + 16, pos:y() + 100 - throttle_height - 4, 3, 1, col)
    update_ui_rectangle(pos:x() + 16, pos:y() + 100 - 1, 3, 1, col)

    -- if we are a PTR show the nearest airliftable unit ID and distance
    if e_game_object_type.chassis_air_rotor_heavy == vehicle:get_definition_index() then
        if g_hovering then
            local word = "HOVR"
            if vehicle:get_throttle_factor() < 0.4 then
                word = "LAND"
            end
            update_ui_text(pos:x() + 184, pos:y() + 110, word, 200, 0, col, 0)
        end

        local st, err = pcall(function()
            local nearest_col = col
            if vehicle_has_cargo(vehicle) then
                nearest_col = color8(200, 200, 0, 255)
            end
            local nearest_id, nearest_range = get_nearest_friendly_airliftable_id(vehicle, 500)
            if nearest_id > 0 then

                local nearest = update_get_map_vehicle_by_id(nearest_id)
                if nearest and nearest:get() then
                    -- work out real nearest range
                    if nearest_range < 50 then
                        local np = nearest:get_position()
                        local vp = vehicle:get_position()
                        nearest_range = vec3_dist(np, vp)
                    end
                    -- render_vision_target_vehicle_outline()
                    local near_range = string.format("ID%d %dm", nearest_id, math.floor(nearest_range))
                    update_ui_text(pos:x() + 204, pos:y() + 130, near_range, 200, 0, col, 0)
                end
            end
        end)
        if not st then
            print(err)
        end

    end
end

function render_altitude_ticker(pos, altitude, col)
    update_ui_image(pos:x(), pos:y(), atlas_icons.hud_ticker_large, col, 0)
    render_number_ticker(vec2(pos:x() + 6, pos:y() + 2), vec2(30, 13), altitude, 4, 2, col, false)
end

function render_airspeed_ticker(pos, vehicle, col)
    update_ui_image(pos:x() + 6, pos:y(), atlas_icons.hud_ticker_small, col, 0)
    render_number_ticker(vec2(pos:x() + 14, pos:y() + 2), vec2(30, 13), vehicle:get_linear_speed(), 3, 1, col, false) 
end

function render_number_ticker(pos, size, val, max_digits, digit_precision, col, is_signed)
    local clip_min = vec2(pos:x(), pos:y())
    local clip_max = vec2(pos:x() + size:x(), pos:y() + size:y())
    local char_w = 6;
    local char_h = 10
    local round_to = 10 ^ (digit_precision - 1)
    local display_val = math.min(math.abs(val), round_down(10 ^ max_digits - 1, round_to))

    -- update_ui_rectangle(clip_min:x(), clip_min:y(), size:x(), size:y(), color8(255, 255, 0, 128))
    update_ui_push_clip(clip_min:x(), clip_min:y(), size:x(), size:y())

    local cursor_x = pos:x() + (max_digits + iff(is_signed, 1, 0) - digit_precision) * char_w
    local cursor_y = pos:y() + (size:y() - char_h) / 2 + 1
    
    if is_signed then
        if val < 0 then
            update_ui_text(pos:x(), cursor_y, "-", 200, 0, col, 0)
        else
            update_ui_text(pos:x(), cursor_y, "+", 200, 0, col, 0)
        end
    end

    local factor = display_val % (round_to * 10) / (round_to * 10)
    render_number_ticker_column(vec2(cursor_x, cursor_y), round_to, 10, char_h, factor, "%0"..digit_precision.."d", col)
    
    for i = digit_precision, max_digits - 1 do
        cursor_x = cursor_x - char_w

        local mod = 10 ^ (i + 1)
        local factor = display_val % mod
        local fac_step = 10 ^ i
        local fac_bound = math.floor(factor / fac_step) * fac_step
        local fac_wrap = factor - fac_bound
        local fac_lower = fac_step - (10 ^ (digit_precision - 1))

        fac_wrap = iff(fac_wrap < fac_lower, 0, remap_clamp(fac_wrap, fac_lower, fac_step, 0, fac_step))
        factor = fac_wrap + fac_bound
        factor = factor / mod

        render_number_ticker_column(vec2(cursor_x, cursor_y), 1, 10, char_h, factor, "%d", col)
    end

    update_ui_pop_clip()
end

function render_number_ticker_column(pos, num_incr, num_steps, char_h, factor, format, col)
    local wrap_min = pos:y() - (num_steps / 2) * char_h
    local wrap_max = pos:y() + (num_steps / 2) * char_h

    for i = 0, num_steps - 1 do
        local str = string.format(format, math.floor(num_incr * i))
        local y = wrap_range(pos:y() - char_h * i + num_steps * factor * char_h, wrap_min, wrap_max)
        update_ui_text(pos:x(), y, str, 200, 0, col, 0)
    end
end

function render_timeline(pos, size, num_incr, spacing, offset, text_align, col, is_clamp_zero, callback)
    local num_count = size:y() / spacing

    local range_min = -math.floor(num_count / 2) - 1
    local range_max = math.floor(num_count / 2) + 1

    update_ui_push_clip(pos:x(), pos:y(), size:x(), size:y())

    for i = range_min, range_max do
        local x = pos:x()
        local y = pos:y() + size:y() / 2 - i * spacing + offset % spacing
        
        local val = num_incr * (i + math.floor(offset / spacing))

        if is_clamp_zero == false or val >= 0 then
            if callback == nil then
                local char_h = 10
    
                update_ui_text(x, y - char_h / 2, val, size:x(), text_align, col, 0)
            else
                callback(x, y)
            end
        end
    end

    update_ui_pop_clip()
end

function wrap_range(val, min, max)
    return min + (val - min) % (max - min)
end

function render_fuel_gauge(pos, height, vehicle, col)
    render_gauge(pos, height, vehicle:get_fuel_factor(), update_get_loc(e_loc.upp_fuel), iff(get_is_fuel_warning(vehicle), color8(255, 0, 0, 255), col))
end

function render_damage_gauge(pos, height, vehicle, col)
    render_gauge(pos, height, vehicle:get_hitpoints() / vehicle:get_total_hitpoints(), update_get_loc(e_loc.hp), iff(get_is_damage_warning(vehicle), color8(255, 0, 0, 255), col)) 
end

function render_gauge(pos, height, factor, label, col)
    factor = clamp(factor, 0, 1)

    local bar_size = math.floor(factor * (height - 4) + 0.5)
    update_ui_rectangle(pos:x(), pos:y() + height - bar_size - 2, 2, bar_size, col)
    update_ui_rectangle(pos:x() - 1, pos:y() + height - 1, 4, 1, col)
    update_ui_rectangle(pos:x() - 1, pos:y(), 4, 1, col)

    local segments = 8
    local step = height / segments
    
    for i = 1, segments - 1 do
        if i % 4 == 0 then
            update_ui_rectangle(pos:x() - 1, pos:y() + height - i * step, 3, 1, col)
        elseif i % 2 == 0 then
            update_ui_rectangle(pos:x() - 1, pos:y() + height - i * step, 2, 1, col)
        else
            update_ui_rectangle(pos:x() - 1, pos:y() + height - i * step, 1, 1, col)
        end
    end
    
    update_ui_text(pos:x() + 3, pos:y() + height, label, 200, 0, col, 3)
end

function get_gun_funnel_spawn_pos(tick_fraction, vehicle, side_dist, forward_dist)
    local forward = vehicle:get_forward()
    local side = vehicle:get_side()
    local vehicle_pos = vehicle:get_position()
    return vec3(
        vehicle_pos:x() + forward:x() * forward_dist + side:x() * side_dist,
        vehicle_pos:y() + forward:y() * forward_dist + side:y() * side_dist,
        vehicle_pos:z() + forward:z() * forward_dist + side:z() * side_dist
    )
end

function update_gun_funnel(tick_fraction, vehicle, side_dist, forward_dist)
    local sample_interval_ticks = 2
    local sample_history_ticks = 96

    local projectile_speed = 20

    local tick = update_get_logic_tick()

    if tick - g_gun_funnel_sample_time > sample_interval_ticks then
        g_gun_funnel_sample_time = tick

        local forward = vehicle:get_forward()
        local projectile_vel = vec3(forward:x() * projectile_speed, forward:y() * projectile_speed, forward:z() * projectile_speed)

        local sample_data = {
            time = tick,
            left = {
                start_pos = get_gun_funnel_spawn_pos(tick_fraction, vehicle, side_dist, forward_dist),
                start_vel = projectile_vel
            },
            right = {
                start_pos = get_gun_funnel_spawn_pos(tick_fraction, vehicle, -side_dist, forward_dist),
                start_vel = projectile_vel
            }   
        }

        g_gun_funnel_history[sample_data.time] = sample_data
    end

    local count = 0

    for k, v in pairs(g_gun_funnel_history) do
        local sample_life = tick - v.time

        if sample_life > sample_history_ticks then
           g_gun_funnel_history[k] = nil
        else
            count = count + 1
        end
    end
end

function render_gun_funnel(tick_fraction, vehicle, side_dist, forward_dist, col, target_pos)
    local projectile_gravity = 0 --0.2 / 30
    local normal_col = col
    local get_bullet_pos = function(time, start_pos, start_vel, gravity)
        local t_sq = time * time

        return vec3(
            start_pos:x() + start_vel:x() * time,
            start_pos:y() + start_vel:y() * time + 0.5 * -projectile_gravity * t_sq,
            start_pos:z() + start_vel:z() * time
        )
    end

    local tick = update_get_logic_tick()

    local prev = {
        time = tick,
        left = {
            start_pos = get_gun_funnel_spawn_pos(tick_fraction, vehicle, side_dist, forward_dist),
            start_vel = vec3(0, 0, 0)
        },
        right = {
            start_pos = get_gun_funnel_spawn_pos(tick_fraction, vehicle, -side_dist, forward_dist),
            start_vel = vec3(0, 0, 0)
        }
    }

    local sort_func = function(a, b) 
        return a > b 
    end

    local render_line = function(a, b, col)
        update_ui_line(
            math.floor(a:x()), 
            math.floor(a:y()),
            math.floor(b:x()), 
            math.floor(b:y()),
            col
        )
    end

    for _, next in iter_sorted(g_gun_funnel_history, sort_func) do
        if prev then
            local time_prev = tick - prev.time
            local time_next = tick - next.time

            local pos_prev_left = get_bullet_pos(time_prev, prev.left.start_pos, prev.left.start_vel)
            local pos_next_left = get_bullet_pos(time_next, next.left.start_pos, next.left.start_vel)
            local screen_prev_left, is_behind_left_prev = update_world_to_screen(pos_prev_left)
            local screen_next_left, is_behind_left_next = update_world_to_screen(pos_next_left)
            if target_pos then
                local dist = vec3_dist_sq(target_pos, pos_next_left)
                if dist < 2500 then -- 50m
                    col = color_status_orange
                else
                    col = normal_col
                end
            end

            if is_behind_left_next == false then
                render_line(screen_prev_left, screen_next_left, col)
            end

            local pos_prev_right = get_bullet_pos(time_prev, prev.right.start_pos, prev.right.start_vel)
            local pos_next_right = get_bullet_pos(time_next, next.right.start_pos, next.right.start_vel)
            local screen_prev_right, is_behind_right_prev = update_world_to_screen(pos_prev_right)
            local screen_next_right, is_behind_right_next = update_world_to_screen(pos_next_right)
            
            if is_behind_right_next == false then
                render_line(screen_prev_right, screen_next_right, col)
            end
        end

        prev = next
    end
end

function render_camera_forward_axis(screen_w, screen_h, vehicle)
    local col = color8(0, 255, 0, 255)
    local x = screen_w / 2 - 0
    local y = screen_h / 3 - 0

    project = function(pos)
        return vec2(math.ceil(pos:x() + x), math.ceil(-pos:y() + y))
    end

    local length = 20
    local arrow_size = 5
    local axis_size = 4

    local arrow_p0 = project(update_camera_local_rotate_inv(vehicle, vec3(0, 0, length)))
    local arrow_p1 = project(update_camera_local_rotate_inv(vehicle, vec3(arrow_size, 0, length - arrow_size)))
    local arrow_p2 = project(update_camera_local_rotate_inv(vehicle, vec3(-arrow_size, 0, length - arrow_size)))
    local axis_y0 = project(update_camera_local_rotate_inv(vehicle, vec3(0, axis_size, 0)))
    local axis_y1 = project(update_camera_local_rotate_inv(vehicle, vec3(0, -axis_size, 0)))

    update_ui_line(x, y, arrow_p0:x(), arrow_p0:y(), col)
    update_ui_line(arrow_p1:x(), arrow_p1:y(), arrow_p0:x(), arrow_p0:y(), col)
    update_ui_line(arrow_p2:x(), arrow_p2:y(), arrow_p0:x(), arrow_p0:y(), col)
    update_ui_line(axis_y0:x(), axis_y0:y(), axis_y1:x(), axis_y1:y(), col)
end

function render_mouse_flight_axis(pos)
    if update_get_active_input_type() == e_active_input.keyboard then 
        local settings = update_get_game_settings()

        if settings.mouse_flight_mode ~= e_mouse_flight_mode.disabled and (settings.ui_show_mouse_joystick_on_hud or settings.mouse_joystick_mode == e_mouse_joystick_mode.offset) then
            local flight_axis = update_get_mouse_flight_axis()
            local invert_x = iff(settings.mouse_flight_inv_x, -1, 1)
            local invert_y = iff(settings.mouse_flight_inv_y, -1, 1)
            flight_axis:x(flight_axis:x() * invert_x)
            flight_axis:y(flight_axis:y() * invert_y)
            
            local max_axis = clamp(math.max(math.abs(flight_axis:x()), math.abs(flight_axis:y())), 0, 1)
            local alpha = clamp((max_axis + 0.1) / 0.2, 0, 1)
            local col_line = color8(255, 255, 255, math.floor(180 * alpha))
            local col_mark = color8(255, 255, 255, math.floor(255 * alpha))
            local rad = 80
            update_ui_line(pos:x() + 1, pos:y() + 1, pos:x() + flight_axis:x() * rad, pos:y() + flight_axis:y() * rad, col_line)
            update_ui_image_rot(pos:x() + 1 + flight_axis:x() * rad, pos:y() + 1 + flight_axis:y() * rad, atlas_icons.hud_target_offscreen_friendly, col_mark, 0)
        end
    end
end

--------------------------------------------------------------------------------
--
-- VEHICLE INFO RENDERING
--
--------------------------------------------------------------------------------

function render_vehicle_info(info_pos, vehicle)
    local pos = vec2(info_pos:x(), info_pos:y())
    local text_align = 0
    local text_col_hi = color8(255, 255, 255, 255)
    local text_col_lo = color8(255, 0, 0, 255)
    local bar_col_hi = color8(0, 128, 255, 255)
    local bar_col_lo = color8(255, 0, 0, 255)
    local back_col = color8(0, 0, 0, 128)

    local fuel_factor = vehicle:get_fuel_factor()
    local alt_factor = remap_clamp(vehicle:get_altitude(), 0, 2000, 0, 1)
    local speed_factor = remap_clamp(vehicle:get_linear_speed(), 0, 100, 0, 1)
    local throttle_factor = vehicle:get_throttle_factor()

    update_ui_text(pos:x(), pos:y() + 60, update_get_loc(e_loc.upp_alt), 60, text_align, iff(alt_factor > 0.25, text_col_hi, text_col_lo), 3)
    pos:x(pos:x() + 10)
    render_gauge_classic(vec2(pos:x(), pos:y()), alt_factor, iff(alt_factor > 0.25, bar_col_hi, bar_col_lo), back_col)
    pos:x(pos:x() + 14)

    update_ui_text(pos:x(), pos:y() + 60, update_get_loc(e_loc.upp_fuel), 60, text_align, iff(fuel_factor > 0.25, text_col_hi, text_col_lo), 3)
    pos:x(pos:x() + 10)
    render_gauge_classic(vec2(pos:x(), pos:y()), fuel_factor, iff(fuel_factor > 0.25, bar_col_hi, bar_col_lo), back_col)
    pos:x(pos:x() + 14)

    update_ui_text(pos:x(), pos:y() + 60, update_get_loc(e_loc.upp_speed), 60, text_align, iff(speed_factor > 0.25, text_col_hi, text_col_lo), 3)
    pos:x(pos:x() + 10)
    render_gauge_classic(vec2(pos:x(), pos:y()), speed_factor, iff(speed_factor > 0.25, bar_col_hi, bar_col_lo), back_col)
    pos:x(pos:x() + 14)

    update_ui_text(pos:x(), pos:y() + 60, update_get_loc(e_loc.upp_throttle), 60, text_align, iff(throttle_factor > 0.25, text_col_hi, text_col_lo), 3)
    pos:x(pos:x() + 10)
    render_gauge_classic(vec2(pos:x(), pos:y()), throttle_factor, iff(throttle_factor > 0.25, bar_col_hi, bar_col_lo), back_col)
    pos:x(pos:x() + 14)
end


--------------------------------------------------------------------------------
--
-- CONNECTING OVERLAY RENDERING
--
--------------------------------------------------------------------------------

function render_connecting_overlay(screen_w, screen_h)
    update_ui_set_back_color(color8(0, 0, 0, 255))
    
    local connecting_text = update_get_loc(e_loc.connecting);
    local dot_count = math.floor(g_animation_time / 250.0) % 4

    for i = 1, dot_count, 1 do
        connecting_text = connecting_text .. "."
    end

    local cx = screen_w / 2 - 40
    local cy = screen_h / 2
    update_ui_text(cx, cy, connecting_text, 100, 0, color_white, 0)

    local anim = g_animation_time * 0.001
    local bound_left = cx
    local bound_right = bound_left + 75
    local left = bound_left + (bound_right - bound_left) * math.abs(math.sin((anim - math.pi / 2) % (math.pi / 2))) ^ 4
    local right = left + (bound_right - left) * math.abs(math.sin(anim % (math.pi / 2)))

    update_ui_rectangle(left, cy + 12, right - left, 1, color_status_ok)
    update_ui_rectangle(bound_right + bound_left - right, cy - 3, right - left, 1, color_status_ok)
end


--------------------------------------------------------------------------------
--
-- ATTACHMENT VISION
--
--------------------------------------------------------------------------------

function render_attachment_vision(screen_w, screen_h, map_data, vehicle, attachment, render_heat)
    local vehicle_id = vehicle:get_id()
    local vehicle_team = vehicle:get_team_id()
    local vehicle_pos = vehicle:get_position()
    local attachment_def = attachment:get_definition_index()

    render_heat = render_heat and get_render_missile_heat_circles()

    local colors = {
        red = color8(255, 0, 0, 255),
        green = color8(0, 255, 0, 255)
    }

    local range = 5000
    local range_ships = 10000

    if attachment_def == e_game_object_type.attachment_camera_vehicle_control then
        colors.red = color8(64, 64, 64, 180)
    end

    local range_sq = range * range
    local range_ships_sq = range_ships * range_ships
    local safe_zone_min = vec2(100, 40)
    local safe_zone_max = vec2(screen_w - 100, screen_h - 30)

    local target_data = {}
    local target_hovered = nil
    local target_selected = nil
    local nearest_screen_dist_sq = -1
    local target_hover_world_radius = 4

    local is_render_own_team = true --get_is_vision_render_own_team(attachment_def)
    local is_target_lock_behaviour = get_is_vision_target_lock_behaviour(attachment_def)
    local is_target_observation_behaviour = get_is_vision_target_observation_behaviour(attachment_def)
    local is_vision_reveal_targets = true -- get_is_vision_reveal_targets(attachment_def)
    local is_show_target_distance = true --get_is_vision_show_target_distance(attachment_def)

    local laser_consuming_type = attachment:get_weapon_target_consuming_type()
    local laser_id, laser_idx = attachment:get_weapon_target_consuming_id()

    local filter_target = function(v)
        -- Ignore self and docked vehicles
        if (v:get_id() ~= vehicle_id or attachment_def == e_game_object_type.attachment_hardpoint_missile_tv) and not v:get_is_docked() then
            if render_heat then
                return true
            end

            if (get_is_vision_render_land(attachment_def) and v:get_is_land_target())
            or (get_is_vision_render_air(attachment_def) and v:get_is_air_target())
            or (get_is_vision_render_sea(attachment_def) and get_is_vehicle_sea(v:get_definition_index())) then
                local def = v:get_definition_index()
                if def == e_game_object_type.chassis_land_robot_dog then
                    return false
                elseif is_render_own_team then
                    return true
                elseif v:get_team_id() ~= vehicle_team then
                    return true
                elseif laser_consuming_type == 1 and laser_id == v:get_id() then
                    return true
                end
            end
        end

        return false
    end

    -- get all relevant targets and their data
    local cam_pos = vehicle:get_position()
    local show_target_dist_to_launcher = attachment_def == e_game_object_type.attachment_hardpoint_missile_tv
    if show_target_dist_to_launcher then
        cam_pos = update_get_camera_position()
    end

    for v in iter_vision(map_data, filter_target) do
        local pos = v:get_position()
        local dist_sq = vec3_dist_sq(pos, cam_pos)
        local is_manta = v:get_definition_index() == e_game_object_type.chassis_air_wing_heavy
        local observe_range_sq = iff(get_is_vehicle_sea(v:get_definition_index()), range_ships_sq, range_sq)

        if dist_sq < observe_range_sq then
            local screen_pos, is_clamped = world_to_screen_clamped(pos, safe_zone_min, safe_zone_max)

            local data = {}
            data.screen_pos = screen_pos
            data.is_clamped = is_clamped
            data.vehicle = v
            data.type = 1
            data.id = v:get_id()
            data.team = v:get_team_id()
            data.dist_sq = dist_sq
            data.is_laser_target = laser_consuming_type == data.type and laser_id == data.id
            data.is_observed = v:get_is_observation_revealed()
            if not data.is_observed then
                data.is_observed = get_is_visible_by_modded_radar(v)
            end
            table.insert(target_data, data)

            if data.id == g_selected_target_id and data.type == g_selected_target_type then
                target_selected = data
            end

            local is_hoverable = data.is_observed or is_vision_reveal_targets

            if is_hoverable then
                local hover_radius = iff(data.is_observed, iff(is_target_observation_behaviour, 10, 1000), target_hover_world_radius)
                local screen_dist_sq = vec2_dist_sq(screen_pos, vec2(screen_w / 2, screen_h / 2))
                local vehicle_screen_radius = get_object_size_on_screen(screen_w, data.vehicle:get_position(), hover_radius)

                if is_target_observation_behaviour and data.is_observed then
                    vehicle_screen_radius = math.min(vehicle_screen_radius, 50)
                end

                local is_hovering = screen_dist_sq < (vehicle_screen_radius * vehicle_screen_radius)

                if (screen_dist_sq < nearest_screen_dist_sq or nearest_screen_dist_sq < 0) and is_hovering and is_clamped == false then
                    nearest_screen_dist_sq = screen_dist_sq
                    target_hovered = data
                end
            end
        end
    end

    if laser_consuming_type == 2 and laser_id ~= 0 then
        local missile_target = update_get_missile_by_id(laser_id)

        if missile_target:get() then
            local screen_pos, is_clamped = world_to_screen_clamped(missile_target:get_position(), safe_zone_min, safe_zone_max)

            local data = {}
            data.screen_pos = screen_pos
            data.is_clamped = is_clamped
            data.missile = missile_target
            data.type = 2
            data.id = laser_id
            data.team = vehicle:get_team_id()
            data.is_laser_target = true
            data.is_observed = true

            table.insert(target_data, data)
        end
    end

    if g_selected_target_id ~= 0 and target_selected == nil then
        g_selected_target_id = 0
    end

    -- render targets
    local function render_target_vehicle_peers(pos, data, col)
        -- nothing to do in single player or for enemy vehicles
        if not update_get_is_multiplayer() or data.team ~= vehicle_team then return end

        local v = data.vehicle

        -- get all peers connected to the vehicle
        local peers = get_vehicle_controlling_peers(v)

        local cursor_y = pos:y() - 16

        for i = 1, #peers do
            local peer = peers[i]
            local peer_name = peer.name

            local max_text_chars = 10
            local is_clipped = false

            if utf8.len(peer_name) > max_text_chars then
                peer_name = peer_name:sub(1, utf8.offset(peer_name, max_text_chars) - 1)
                is_clipped = true
            end

            local text_render_w, text_render_h = update_ui_get_text_size(peer_name, 200, 0)

            if peer.ctrl then
                update_ui_image((pos:x() - text_render_w / 2) - 12, cursor_y, atlas_icons.column_controlling_peer, col, 0)
            end

            update_ui_text(pos:x() - text_render_w / 2, cursor_y, peer_name, text_render_w, 0, col, 0)

            if is_clipped then
                update_ui_image(pos:x() + text_render_w / 2, cursor_y, atlas_icons.text_ellipsis, col, 0)
            end

            cursor_y = cursor_y - 10
        end
    end

    local function render_target_vehicle_info(pos, data, col)
        if data.is_laser_target then
            -- don't render info
        elseif g_selected_target_id ~= nil and g_selected_target_id > 0 then
            -- target is selected
        else
            local def = data.vehicle:get_definition_index()

            -- render right side of marker
            local cursor_y = pos:y() - 4

            local capability_name = ""

            if def ~= e_game_object_type.chassis_carrier and def ~= e_game_object_type.chassis_sea_barge then
                local capabilities = get_vehicle_capability(data.vehicle)
                if #capabilities > 0 then
                    local capability_index = (math.floor( g_animation_time / 1000 ) % (#capabilities)) + 1
                    capability_name = capabilities[capability_index].name_short
                else
                    capability_name = "NONE"
                end
            end

            if data.team == vehicle_team then
                local name, icon, handle = get_chassis_data_by_definition_index(def)
                update_ui_text(pos:x() + 9, cursor_y, handle, 200, 0, col, 0)
                update_ui_image(pos:x() + 26, cursor_y - 4, icon, col, 0)
                cursor_y = cursor_y + 10

                update_ui_text(pos:x() + 9, cursor_y, capability_name, 64, 0, col, 0)
            else
                -- hostile targets
                if data.vehicle:get_is_observation_type_revealed() then
                    local name, icon, handle = get_chassis_data_by_definition_index(def)
                    update_ui_text(pos:x() + 9, cursor_y, handle, 200, 0, col, 0)
                    update_ui_image(pos:x() + 26, cursor_y - 4, icon, col, 0)
                    cursor_y = cursor_y + 10
                elseif data.vehicle:get_is_observation_revealed() then
                    update_ui_text(pos:x() + 9, cursor_y, "***", 200, 0, col, 0)
                    cursor_y = cursor_y + 10
                end
                    
                if data.vehicle:get_is_observation_weapon_revealed() then
                    update_ui_text(pos:x() + 9, cursor_y, capability_name, 64, 0, col, 0)
                    cursor_y = cursor_y + 10
                end
    
                if is_target_observation_behaviour and data.vehicle:get_is_observation_fully_revealed() == false and data.is_observed then
                    local factor = data.vehicle:get_observation_factor()
                    update_ui_text(pos:x() + 9, cursor_y, string.format("%.0f%%", factor * 100), 200, 0, col, 0)
                end
            end

            -- render left side of marker
            cursor_y = pos:y() - 4

            local id_str = ""

            if def == e_game_object_type.chassis_carrier then
                id_str = get_ship_name(data.vehicle)
            else
                id_str = update_get_loc(e_loc.upp_id) .. string.format( " %.0f", data.id)
            end

            local id_w = update_ui_get_text_size(id_str, 10000, 1) + 7
            update_ui_text(pos:x() - id_w, cursor_y, id_str, 128, 0, col, 0 )
            cursor_y = cursor_y + 10

            if is_show_target_distance and data.is_observed then
                local dist = math.sqrt(data.dist_sq)
                local dist_str = ""

                if dist < 8000 then
                    dist_str = string.format("%.0f", dist) .. update_get_loc(e_loc.acronym_meters)
                else
                    dist_str = string.format("%1.1f", dist / 1000) .. update_get_loc(e_loc.acronym_kilometers)
                end

                local dist_w = update_ui_get_text_size(dist_str, 10000, 1) + 7

                update_ui_text(pos:x() - dist_w, cursor_y, dist_str, 128, 0, col, 0)

                if show_target_dist_to_launcher then
                    local ldist = vec3_dist(vehicle_pos, data.vehicle:get_position())
                    local text = "--"
                    if ldist > 10 then
                        text = string.format("%1.1fkm", ldist/1000)
                    end
                    update_ui_text(pos:x() - dist_w, cursor_y + 10, text, 128, 0, color_white, 0)
                end

            end
        end
    end

    local function render_target_missile_info(pos, data, col)
        if data.is_laser_target then
            -- don't render info
        end
    end

    -- debug
    -- for _, data in pairs(target_data) do
    --     if data.type == 1 then
    --         local vehicle_screen_radius = get_object_size_on_screen(screen_w, data.vehicle:get_position(), 4)

    --         if data.is_clamped == false then
    --             render_circle(data.screen_pos, vehicle_screen_radius, 16, colors.red)
    --         end
    --     end
    -- end

    local vehicle_info_data = nil

    for _, data in pairs(target_data) do
        if data.type == 1 then -- vehicle
            if target_selected == nil or target_selected == data or render_heat then
                local is_target_locked = is_target_lock_behaviour and g_selected_target_id == data.id and g_selected_target_type == data.type
                local is_friendly = data.team == vehicle_team
                local col = iff(is_friendly, color_friendly, colors.red)
                local is_hovered = data == target_hovered
                local is_render_health = (data == target_selected or (target_selected == nil and data == target_hovered)) and data.is_observed

                if not is_friendly then
                    if render_heat then
                        local heat_range = get_render_missile_heat_range()
                        if data.dist_sq < (heat_range * heat_range) and data.vehicle:get_linear_speed() > 1 and data.vehicle:get_is_visible() and not data.is_clamped then
                            -- draw some heat blobs
                            local screen_pos = vec2(data.screen_pos:x() - 1, data.screen_pos:y() - 1)
                            --local hover_radius = target_hover_world_radius
                            --local vehicle_screen_radius = get_object_size_on_screen(screen_w, data.vehicle:get_position(), hover_radius)
                            --local blob_size = get_vehicle_scale(data.vehicle) * vehicle_screen_radius
                            local blob_col = color_white
                            local blob_size = 5
                            --if blob_size < 3 then
                            --    blob_size = 3
                            --end
                            --if blob_size > 8 then
                            --    blob_size = 8
                            --end

                            local area_w = screen_h * get_render_missile_heat_scope_size()
                            local min_x = (screen_w / 2) - (area_w / 2)
                            local max_x = (screen_w / 2) + (area_w / 2)
                            local min_y = (screen_h / 2) - (area_w / 2)
                            local max_y = (screen_h / 2) + (area_w / 2)
                            if screen_pos:x() > min_x and screen_pos:x() < max_x then
                                if screen_pos:y() > min_y and screen_pos:y() < max_y then
                                    render_circle(screen_pos, blob_size, 6, blob_col)
                                end
                            end
                        end
                    end
                end

                if data.is_observed then
                    render_vision_target_vehicle_outline(data.screen_pos, data.vehicle, data.is_clamped, is_target_locked or data.is_laser_target, is_friendly, is_render_health, col)

                    if data.is_clamped == false and (is_hovered or data.is_laser_target) then
                        vehicle_info_data = data
                    end
                elseif is_vision_reveal_targets and is_hovered and data.is_clamped == false then
                    local factor = data.vehicle:get_observation_factor()

                    if factor > 0 then
                        update_ui_push_offset(data.screen_pos:x(), data.screen_pos:y())

                        local rad = 7
                        render_line_segments({ 
                            { vec2(0, -rad), vec2(rad, 0) },
                            { vec2(rad, 0), vec2(0, rad) },
                            { vec2(0, rad), vec2(-rad, 0) },
                            { vec2(-rad, 0), vec2(0, -rad) }
                        }, col, factor)

                        update_ui_pop_offset()
                    end
                end
            end
        elseif data.type == 2 then -- missile
            if render_heat then
                -- TODO draw a heat blume around missiles
            end

            render_vision_target_missile_outline(data.screen_pos, data.is_clamped, color_friendly)
            render_target_missile_info(data.screen_pos, data, colors.green)
        end
    end

    -- Always draw info on top
    if vehicle_info_data ~= nil then
        g_current_info_target = vehicle_info_data
        render_target_vehicle_info(vehicle_info_data.screen_pos, vehicle_info_data, colors.green)
        render_target_vehicle_peers(vehicle_info_data.screen_pos, vehicle_info_data, colors.green)
    else
        g_current_info_target = nil
    end

    if is_vision_reveal_targets and target_hovered ~= nil and target_hovered.type == 1 and target_hovered.vehicle:get_is_observation_fully_revealed() == false then
        local dist_to_center = vec2_dist(target_hovered.screen_pos, vec2(screen_w / 2, screen_h / 2))
        local dist_factor = 1 - clamp(dist_to_center / 64, 0, 1)
        local vehicle_screen_radius = get_object_size_on_screen(screen_w, target_hovered.vehicle:get_position(), 20)
        local radius_factor = clamp(vehicle_screen_radius / 50, 0, 1)
        
        local observation_factor = dist_factor * radius_factor

        if target_hovered.vehicle:get_is_observation_revealed() == false then
            update_set_observed_vehicle(target_hovered.id, observation_factor)
        elseif is_target_observation_behaviour then
            update_set_observed_vehicle(target_hovered.id, observation_factor)
        end
    end

    if is_target_lock_behaviour then
        update_add_ui_interaction(iff(g_selected_target_id == 0, update_get_loc(e_loc.interaction_lock_target), update_get_loc(e_loc.interaction_clear_target)), e_game_input.toggle_stabilisation_mode)
        toggle_vision_target(target_hovered, vehicle_team)
    end
end

function render_vision_target_vehicle_outline(pos, vehicle, is_clamped, is_target_locked, is_friendly, is_render_health, col)
    local x = math.floor(pos:x() + 1); local y = math.floor(pos:y() + 1)

    if is_render_health then
        local damage_indicator_factor = vehicle:get_damage_indicator_factor()
        col = color8_lerp(col, color_white, damage_indicator_factor)
    end

    local icons = iff(is_friendly, {
        target = atlas_icons.hud_target_friendly,
        target_locked = atlas_icons.hud_target_locked_friendly,
        target_offscreen = atlas_icons.hud_target_offscreen_friendly,
    },{
        target = atlas_icons.hud_target,
        target_locked = atlas_icons.hud_target_locked,
        target_offscreen = atlas_icons.hud_target_offscreen,
    })

    if is_target_locked then
        if g_animation_time % 500 > 250 then
            update_ui_image_rot(x, y, iff(is_clamped, icons.target_offscreen, icons.target_locked), col, 0)
        else
            update_ui_image_rot(x, y, iff(is_clamped, icons.target_offscreen, icons.target), col, 0)
        end
    else
        update_ui_image_rot(x, y, iff(is_clamped, icons.target_offscreen, icons.target), col, 0)
    end

    if is_render_health then
        local hitpoints = vehicle:get_hitpoints()
        local total_hitpoints = vehicle:get_total_hitpoints()

        if total_hitpoints > 0 then
            local hitpoint_factor = hitpoints / total_hitpoints

            if is_clamped then
                local bar_size = math.ceil(5 * hitpoint_factor - 0.01)
                update_ui_rectangle(pos:x() - 2, pos:y() + 4, 5, 1, color8(16, 16, 16, 255))
                update_ui_rectangle(pos:x() - 2, pos:y() + 4, bar_size, 1, col)
            else
                local bar_size = math.ceil(13 * hitpoint_factor - 0.01)
                update_ui_rectangle(pos:x() - 6, pos:y() + 8, 13, 1, color8(16, 16, 16, 255))
                update_ui_rectangle(pos:x() - 6, pos:y() + 8, bar_size, 1, col)
            end
        end
    end
end

function render_vision_target_missile_outline(pos, is_clamped, col)
    local x = math.floor(pos:x() + 1); local y = math.floor(pos:y() + 1)

    update_ui_image_rot(x, y, iff(is_clamped, atlas_icons.hud_target_offscreen, atlas_icons.hud_target_missile), col, 0)
end

-- Render chassis direction relative to turret
function render_turret_vehicle_direction(screen_w, screen_h, vehicle, turret, col)
    local def = vehicle:get_definition_index()
    if def == e_game_object_type.chassis_land_turret then return nil end
    
    local attachment_icon_region, attachment_16_icon_region = get_attachment_icons(turret:get_definition_index())
--  local icon_w, icon_h = update_ui_get_image_size(attachment_icon_region)

    local hud_size = vec2(230, 140) 
    local hud_min = vec2((screen_w - hud_size:x()) / 2, (screen_h - hud_size:y()) / 2)
    local hud_pos = vec2(hud_min:x() + hud_size:x() / 2, hud_min:y() + hud_size:y() / 2)

    local pos_x = hud_min:x() + hud_size:x() - 6
    local pos_y = hud_pos:y() - 30
    
    local turret_ang = update_get_camera_heading()

    local vehicle_dir = vehicle:get_forward()
    local vehicle_ang = math.atan( vehicle_dir:x(), vehicle_dir:z() )
    
    local turret_def = turret:get_definition_index()
    local off_y = iff(turret_def == e_game_object_type.attachment_turret_droid, -2, -4)
    
    update_ui_image_rot( pos_x, pos_y, atlas_icons.hud_ticker_small, col, -(turret_ang - vehicle_ang) - (math.pi / 2) )
    update_ui_image_rot( pos_x, pos_y + off_y, attachment_icon_region, col, 0 )
end

-- toggle between no target and a specific target
function toggle_vision_target(nearest_target, vehicle_team)
    if g_selected_target_id == 0 and nearest_target and nearest_target.is_observed then -- and nearest_target.team ~= vehicle_team then
        if g_is_input_cycle_target_next or g_is_input_cycle_target_prev then
            g_selected_target_id = nearest_target.id
            g_selected_target_type = 1
        end
    elseif g_selected_target_id ~= 0 then
        if g_is_input_cycle_target_next or g_is_input_cycle_target_prev then
            g_selected_target_id = 0
            g_selected_target_type = 0
        end
    end
end

-- cycle visible targets from left to right
function cycle_vision_targets(targets, nearest_target)
    if #targets > 0 then
        table.sort(targets, function(a,b) return a.screen_pos:x() < b.screen_pos:x() end)

        local selected_target_index = -1

        for i = 1, #targets do
            if targets[i].vehicle:get_id() == g_selected_target_id then
                selected_target_index = i - 1
                break
            end
        end

        if g_selected_target_id == 0 and nearest_target then
            if g_is_input_cycle_target_next or g_is_input_cycle_target_prev then
                g_selected_target_id = nearest_target:get_id()
                g_selected_target_type = 1
            end
        else
            if g_is_input_cycle_target_next then
                selected_target_index = (selected_target_index + 1) % #targets
            elseif g_is_input_cycle_target_prev then
                selected_target_index = (selected_target_index - 1) % #targets    
            end

            g_selected_target_id = targets[selected_target_index + 1].vehicle:get_id()
            g_selected_target_type = 1
        end
    else
        if g_is_input_cycle_target_next or g_is_input_cycle_target_prev then
            g_selected_target_id = 0
            g_selected_target_type = 0
        end
    end
end

function get_is_vision_show_target_distance(attachment_def)
    return attachment_def == e_game_object_type.attachment_turret_artillery
        or attachment_def == e_game_object_type.attachment_turret_15mm
        or attachment_def == e_game_object_type.attachment_turret_30mm
        or attachment_def == e_game_object_type.attachment_turret_40mm
        or attachment_def == e_game_object_type.attachment_turret_heavy_cannon
        or attachment_def == e_game_object_type.attachment_turret_battle_cannon
        or attachment_def == e_game_object_type.attachment_turret_carrier_main_gun
        or attachment_def == e_game_object_type.attachment_turret_droid
        or attachment_def == e_game_object_type.attachment_turret_gimbal_30mm
end

function get_is_vision_target_lock_behaviour(attachment_def)
    return attachment_def == e_game_object_type.attachment_turret_rocket_pod
        or attachment_def == e_game_object_type.attachment_hardpoint_missile_ir
        or attachment_def == e_game_object_type.attachment_hardpoint_missile_laser
        or attachment_def == e_game_object_type.attachment_hardpoint_missile_aa
        or attachment_def == e_game_object_type.attachment_hardpoint_bomb_1
        or attachment_def == e_game_object_type.attachment_hardpoint_bomb_2
        or attachment_def == e_game_object_type.attachment_hardpoint_bomb_3
        or attachment_def == e_game_object_type.attachment_turret_plane_chaingun
end

function get_is_vision_render_land(attachment_def)
    return (attachment_def ~= e_game_object_type.attachment_radar_awacs) and (attachment_def ~= e_game_object_type.attachment_hardpoint_missile_aa)
end

function get_is_vision_render_air(attachment_def)
    return true
end

function get_is_vision_render_sea(attachment_def)
    return (attachment_def ~= e_game_object_type.attachment_hardpoint_missile_aa)
end

function get_is_vision_render_own_team(attachment_def)
    return attachment_def == e_game_object_type.attachment_camera_observation
        or attachment_def == e_game_object_type.attachment_camera_plane
        or attachment_def == e_game_object_type.attachment_turret_carrier_camera
        or attachment_def == e_game_object_type.attachment_radar_awacs
end

function get_is_vision_target_observation_behaviour(attachment_def)
    return attachment_def == e_game_object_type.attachment_camera_observation
        or attachment_def == e_game_object_type.attachment_camera_plane
        or attachment_def == e_game_object_type.attachment_turret_carrier_camera
end

function get_is_vision_reveal_targets(attachment_def)
    return attachment_def == e_game_object_type.attachment_camera_observation
        or attachment_def == e_game_object_type.attachment_camera_plane
        or attachment_def == e_game_object_type.attachment_turret_carrier_camera
        or attachment_def == e_game_object_type.attachment_turret_15mm
        or attachment_def == e_game_object_type.attachment_turret_30mm
        or attachment_def == e_game_object_type.attachment_turret_40mm
        or attachment_def == e_game_object_type.attachment_turret_artillery
        or attachment_def == e_game_object_type.attachment_turret_battle_cannon
        or attachment_def == e_game_object_type.attachment_turret_heavy_cannon
        or attachment_def == e_game_object_type.attachment_turret_missile
        or attachment_def == e_game_object_type.attachment_turret_ciws
        or attachment_def == e_game_object_type.attachment_camera
        or attachment_def == e_game_object_type.attachment_turret_droid
        or attachment_def == e_game_object_type.attachment_turret_gimbal_30mm
end


--------------------------------------------------------------------------------
--
-- RENDER HELPER FUNCTIONS
--
--------------------------------------------------------------------------------

function render_gauge_classic(pos, factor, col, back_col)
    local b = pos:y() + 59;
    local t = pos:y() + 1
    t = math.floor(lerp(b, t, clamp(factor, 0.0, 1.0)) + 0.5)

    if back_col then update_ui_rectangle(pos:x(), pos:y(), 13, 60, back_col) end
    update_ui_image(pos:x(), pos:y(), atlas_icons.gauge, color8(255, 255, 255, 255), 0)
    update_ui_rectangle(pos:x() + 7, t, 5, b - t, col)
end

function render_circle(pos, radius, steps, col, frac)
    if frac == nil then
        frac = 1.0
    end
    local arc = math_2pi * frac
    local step = (arc / steps)

    for i = 0, steps - 1 do
        local angle = i * step - math_pi_2
        local angle_next = angle + step
        local px = pos:x()
        local py = pos:y()
        update_ui_line(
            math.ceil(px + math_cos(angle) * radius),
            math.ceil(py + math_sin(angle) * radius),
            math.ceil(px + math_cos(angle_next) * radius),
            math.ceil(py + math_sin(angle_next) * radius),
            col
        )
    end
end

function render_line_segments(segments, col, factor)
    if #segments > 0 then
        local factor_step = 1 / #segments

        for i = 1, #segments do
            local step_min = factor_step * (i - 1)
            local step_max = factor_step * i
            local segment_factor = remap_clamp(factor, step_min, step_max, 0, 1)

            if segment_factor > 0 then
                local p0 = segments[i][1]
                local p1 = vec2_lerp(p0, segments[i][2], segment_factor)

                render_line_accurate(p0:x(), p0:y(), p1:x(), p1:y(), col)
            else
                return
            end
        end
    end
end

function render_line_accurate(x0, y0, x1, y1, col)
    local dx = x1 - x0
    local dy = y1 - y0
    local step = iff(math.abs(dx) > math.abs(dy), math.abs(dx), math.abs(dy))
    local x = x0
    local y = y0
    dx = dx / step
    dy = dy / step

    for i = 0, step do
        update_ui_rectangle(x, y, 1, 1, col)
        x = x + dx
        y = y + dy
    end
end

function world_to_screen_clamped(pos, clamp_min, clamp_max)
    local screen_pos, is_behind = update_world_to_screen(pos)
    local is_clamped = false
    
    if is_behind then 
        screen_pos = vec2_clamp_to_rect(vec2(-screen_pos:x(), -screen_pos:y()), clamp_min, clamp_max)
        is_clamped = true
    elseif vec2_in_rect(screen_pos, clamp_min, clamp_max) == false then
        screen_pos = vec2_clamp_to_rect(screen_pos, clamp_min, clamp_max) 
        is_clamped = true
    end

    return screen_pos, is_clamped
end

function get_is_attachment_observation_camera_controlled(attachment_def)
    return attachment_def == e_game_object_type.attachment_hardpoint_missile_laser
end

--------------------------------------------------------------------------------
--
-- UTIL
--
--------------------------------------------------------------------------------

function get_object_size_on_screen(screen_w, world_pos, world_radius)
    local camera_fov = update_get_camera_fov()
    local camera_pos = update_get_camera_position()
    local dist_to_camera = vec3_dist(world_pos, camera_pos)
    local screen_radius = world_radius / (math.tan(camera_fov / 2) * dist_to_camera) * (screen_w / 2)
    return screen_radius
end

function vec2_max(a, b)
    return vec2(math.max(a:x(), b:x()), math.max(a:y(), b:y()))
end

function get_control_mode_color(control_mode)
    if control_mode == "off" then
        return color8(255, 0, 0, 255)
    elseif control_mode == "manual" then
        return color8(0, 255, 0, 255)
    else
        return color8(255, 255, 0, 255)
    end
end

function get_control_mode_loc(control_mode)
    if control_mode == "manual" then
        return update_get_loc(e_loc.control_mode_manual)
    elseif control_mode == "auto" then
        return update_get_loc(e_loc.control_mode_auto)
    elseif control_mode == "override" then
        return update_get_loc(e_loc.control_mode_override)
    end

    return update_get_loc(e_loc.control_mode_off)
end

function get_stabilisation_mode_loc(stabilisation_mode)
    if stabilisation_mode == "stabilised" then
        return update_get_loc(e_loc.stabilisation_stabilised)
    elseif stabilisation_mode == "tracking" then
        return update_get_loc(e_loc.stabilisation_tracking)
    end

    return update_get_loc(e_loc.stabilisation_off)
end

function get_vehicle_attachment(vehicle_id, attachment_index)
    local vehicle = update_get_map_vehicle_by_id(vehicle_id)

    if vehicle:get() then
        local attachment = vehicle:get_attachment(attachment_index)

        if attachment:get() then
            return attachment
        end
    end

    return nil
end

function iter_sorted(t, sort_func)
    local sorted_keys = {}

    for k, v in pairs(t) do
        table.insert(sorted_keys, k)
    end

    table.sort(sorted_keys, sort_func)

    local index = 1

    return function()
        if index < #sorted_keys then
            local key = sorted_keys[index]
            index = index + 1

            return key, t[key]
        else
            return nil
        end
    end
end

function iter_vision(map_data, filter)
    local vision_data = map_data:get_vision_data()
    local index = 0

    local skip = function(v)
        return v == nil or v:get() == false or (filter ~= nil and filter(v) == false)
    end

    return function()
        local data = nil

        while index < #vision_data do
            data = vision_data[index + 1]
            index = index + 1

            if skip(data) then
                data = nil
            else
                break
            end
        end

        return data
    end
end

function iter_tiles(filter)
    local tile_count = update_get_tile_count()
    local index = 0

    local skip = function(v)
        return v == nil or v:get() == false or (filter ~= nil and filter(v) == false)
    end

    return function()
        local tile = nil

        while index < tile_count do
            tile = update_get_tile_by_index(index)
            index = index + 1

            if skip(tile) then
                tile = nil
            else
                break
            end
        end

        if tile ~= nil then
            return index, tile
        end
    end
end

function iter_vehicles(filter)
    local vehicle_count = update_get_map_vehicle_count()
    local index = 0

    local skip = function(v)
        return v == nil or v:get() == false or (filter ~= nil and filter(v) == false)
    end

    return function()
        local vehicle = nil

        while index < vehicle_count do
            vehicle = update_get_map_vehicle_by_index(index)
            index = index + 1

            if skip(vehicle) then
                vehicle = nil
            else
                break
            end
        end

        if vehicle ~= nil then
            return index, vehicle
        end
    end
end

function get_is_vehicle_controllable(vehicle)
    return vehicle:get_definition_index() ~= e_game_object_type.chassis_carrier
end

function get_vehicle_attachment_count(vehicle)
    if vehicle:get_definition_index() == e_game_object_type.chassis_carrier then
        return 1
    end

    return vehicle:get_attachment_count()
end

function get_is_damage_warning(vehicle)
    return vehicle:get_hitpoints() / vehicle:get_total_hitpoints() <= 0.25
end

function get_is_fuel_warning(vehicle)
    return vehicle:get_fuel_factor() <= 0.25
end

function get_attachment_display_name(vehicle, attachment)
    local definition_index = attachment:get_definition_index()

    if definition_index > e_game_object_type.count or definition_index < 0 then
       return update_get_loc(e_loc.upp_empty) 
    elseif definition_index == e_game_object_type.attachment_camera_vehicle_control and get_is_vehicle_controllable(vehicle) then
        return update_get_loc(e_loc.upp_vehicle_control)
    end

    local attachment_data = get_attachment_data_by_definition_index(definition_index)
    return attachment_data.name
end

function render_ground_marker_triangle(screen_pos, col, w, h)
    if w == nil then
        w = 6
    end
    if h == nil then
        h = 7
    end
    local d = math.floor(w / 2)
    local tl = vec2(screen_pos:x() - d, screen_pos:y() - h)
    local tr = vec2(screen_pos:x() + d, screen_pos:y() - h)

    update_ui_begin_triangles()
    update_ui_add_triangle(tl, screen_pos, tr, col)
    update_ui_end_triangles()
end

function render_ground_marker(col, wp, screen_w, screen_h, txt)
    local swpp, clamped = world_to_screen_clamped(wp, vec2(0, 0), vec2(screen_w, screen_h))
    if not clamped then
        render_ground_marker_triangle(swpp, col)
        if txt ~= nil then
            update_ui_text(swpp:x() + 8, swpp:y(), txt, 8 * #txt, 0, col, 0)
        end
    end
end


--------------------------------------------------------------------------------
--
-- DEBUG
--
--------------------------------------------------------------------------------

-- function debug_update_print_regions(x, y)
--     local ind = 0
--     for k, v in pairs(atlas_icons) do
--         update_ui_text(x, y + ind * 9, k .. ": " .. v, 300, 0, color8(255, 255, 255, 255), 0)
--         ind = ind + 1
--     end
-- end

-- function debug_update_print_metatable(obj, x, y)
--     local meta = getmetatable(obj)

--     if meta then
--         local ind = 0

--         for k, v in pairs(meta) do
--             update_ui_text(x, y + 10 * ind, k .. " (" .. type(v) .. ")", 300, 0, color8(128, 128, 128, 255), 0)
--             ind = ind + 1

--             if type(v) == "table" then
--                 for kk, vv in pairs(v) do
--                     update_ui_text(x + 20, y + 10 * ind, kk .. " (" .. type(vv) .. ")", 300, 0, color8(128, 128, 128, 255), 0)
--                     ind = ind + 1
--                 end
--             end
--         end
--     else
--         update_ui_text(x, y, "no metatable", 300, 0, color8(128, 128, 128, 255), 0)
--     end
-- end


---
-- HUD Variometer Mod
---

-- class to store arbitrary values with a max tick age
-- this was inspired by the gun funnel history code but isn't related to it now
TimedHistory = {
    ident = 0,
    debug = 0,
    interval = 1,
    ttl = 30,
    ticks_per_sec = 30, -- estimated
    last_tick = 0,
    data = {},
    mean = 0,
    sample_size = 0,
    sample_min = 20000,
    sample_max = 0,
    last_value = 0,

    reset = function(self)
        for k in pairs (self.data) do
            self.data[k] = nil
        end
        self.last_tick = update_get_logic_tick()
        self.last_value = 0
    end,

    add_value = function(self, v)
        local tick = update_get_logic_tick()
        local sample_sum = 0
        local sample_count = 0
        local xsample_min = 2000
        local xsample_max = 0
        self.last_value = v
        if self.debug > 0 then
            update_ui_text(
                    10 + 180 * self.ident,
                    30,
                    string.format("%d mean() = %s", self.ident, self.mean),
                    300, 0, color8(255, 128, 128, 255), 0)
        end
        if tick - self.last_tick > self.interval then
            local sample = { time = tick, value = v }
            self.data[tick] = sample
            self.last_tick = tick
            -- trim off the oldest items
            for k, val in pairs(self.data) do
                if self.debug > 0 then
                    update_ui_text(
                            10 + 180 * self.ident,
                            50 + 10 * sample_count,
                            string.format("%d value = %s", self.ident, val.value),
                            300, 0, color8(255, 128, 128, 255), 0)
                end
                if tick - val.time > (self.ttl * self.ticks_per_sec) then
                    self.data[k] = nil
                else
                    if val.value > 0 then
                        sample_sum = sample_sum + val.value
                        sample_count = sample_count + 1
                        if val.value > xsample_max then
                            xsample_max = val.value
                        end
                        if val.value < xsample_min then
                            xsample_min = val.value
                        end

                    end
                end
            end

            self.sample_max = xsample_max
            self.sample_min = xsample_min

            if sample_count > 0 then
                self.mean = sample_sum / sample_count
            end
            self.sample_size = sample_count
        end
    end,
}
function TimedHistory:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

VarTimedHistory = TimedHistory:new()

Variometer = {
    alt = VarTimedHistory:new{ttl=1, ident=0, data={}},
    fuel = VarTimedHistory:new{ttl=30, ident=1, data={}},
    predicted_vector = {x=0, y=0},

    update = function(self, v)
        local pe, err = pcall(function() self._update(self, v) end)
        if pe then
            --
        else
            update_ui_text(5, 40, string.format("err in _update() = %s", err), 300, 0, color8(255, 128, 128, 255), 0)
        end
    end,

    _update = function(self, vehicle)
        if g_last_vid ~= vehicle:get_id() then
            self.alt:reset()
            self.fuel:reset()
        end
        self.alt:add_value(vehicle:get_altitude())
        self.fuel:add_value(vehicle:get_fuel_factor())
    end,

    fuel_burnrate = function(self)  -- % per sec
        return (self.fuel.sample_max - self.fuel.sample_min) / self.fuel.ticks_per_sec
    end,

    render = function(self, pos, col)
        local pe, err = pcall(function() self._render(self, pos, col) end)
        if pe then
            --
        else
            update_ui_text(5, 50, string.format("err in _render() = %s", err), 300, 0, color8(255, 128, 128, 255), 0)
        end
    end,

    _render = function(self, pos, col)
        -- render rate of climb
        local d_alt = self.alt.last_value - self.alt.mean -- m/s

        local d_alt_col = col
        local d_alt_bar_col = col
        local col_yellow = color8(255, 255, 0, 255)
        local col_warn = color8(255, 64, 64, 255)
        local col_stall = color8(64, 64, 255, 255)

        if d_alt < 0 then
            d_alt_col = col_yellow
        end
        update_ui_text(pos:x(), pos:y() + 110, string.format("%2.0f~", d_alt), 200, 0, d_alt_col, 0)

        -- clamp the bars
        if d_alt > 51 then
            d_alt = 51
        end
        if d_alt < -50 then
            d_alt = -50
        end

        -- set warning colors
        -- warn about terrain if < 5 sec before impact
        if d_alt < 0 then
            if (self.alt.last_value + (d_alt * 5)) < 0 then
                d_alt_bar_col = col_warn
            end
        end
        -- warn about stall if < 5 sec before 2000
        if d_alt > 0 then
            if (self.alt.last_value + (d_alt * 5)) > 2000 then
                d_alt_bar_col = col_stall
            end
        end

        -- render the variometer bars
        if d_alt < 0 then
            update_ui_rectangle(
                    pos:x() -8,
                    pos:y() + 52,
                    2, d_alt * -1, d_alt_bar_col)
        else
            update_ui_rectangle(
                    pos:x() -8,
                    pos:y() + 52 - (d_alt),
                    2, d_alt , d_alt_bar_col)
        end
        -- mid bar
        update_ui_rectangle(
                pos:x() -10,
                pos:y() + 50,
                5, 2, col)

        -- render fuel updates
        local fuel_number_col = col
        if self.fuel.last_value < 0.5 then
            fuel_number_col = color8(255, 255, 0, 255)
        end
        if self.fuel.last_value < 0.25 then
            fuel_number_col = color8(255, 0, 0, 255)
        end

        local fuel_count = self.fuel.last_value
        local fuel_per_min = self:fuel_burnrate() * 60
        local mins_remaining = fuel_count / fuel_per_min

        -- total %
        update_ui_text(
                pos:x() - 38,
                pos:y() + 140,
                string.format("%2.1f %s", fuel_count * 100, "%"),
                64, 0, fuel_number_col, 0)

        -- only render fuel estimates when we have proper data
        local fuel_use_per_min = "--- %/m"
        local fuel_time_mins = "--- mins"

        if self.fuel.sample_size > 30 then
            fuel_use_per_min = string.format("%2.1f %s /m", fuel_per_min * 100, "%")
            fuel_time_mins = string.format("%3.0f mins", mins_remaining)
        end
        -- % / min
        update_ui_text(
                pos:x() - 32,
                pos:y() + 150,
                fuel_use_per_min,
                64, 0, col, 0)
        -- time
        update_ui_text(
                pos:x() - 32,
                pos:y() + 160,
                fuel_time_mins,
                200, 0, fuel_number_col, 0)

    end,
}

function get_nearest_island_name(vehicle)
    local name = "-"
    local pos = vehicle:get_position()
    local nearest = get_nearest_island_tile(pos:x(), pos:z())
    name = get_island_name(nearest)
    return name
end



function render_snowstorm(vehicle, screen_w, screen_h, multi)
    local here = vehicle:get_position()
    local heading = update_get_camera_heading() / math.pi / 2
    local compass_heading = math.floor(iff(heading < 0, 360 + heading * 360, heading * 360))
    local x_offset = math.floor(here:x() % 48) - compass_heading
    local color = color8(255, 255, 255, 190)
    if (g_animation_time % 200) < math.random(180) then
        for x = 0, screen_w, 28 - multi do
            for y = 0, screen_h, 80 do
                local jitter = math.random(screen_w)
                update_ui_rectangle(x + jitter - 25 , y - jitter, 19 * multi, 5, color)
            end
        end
    end

    -- render some phantom targets
    if multi < 2 then
        for i = 0, math.random(4) do
            local vx = x_offset + screen_w / i
            local dvx = math.random(-27, 38)
            vx = vx + dvx
            local pos = vec2(vx , math.random(48) + (screen_h / 2) - 48 )
            render_vision_target_vehicle_outline(pos, vehicle, false, false, false, false, color_enemy)
        end
    end

    if multi > 0 then
        render_snowstorm(vehicle, screen_w, screen_h, multi - 1)
    end
end

function render_bad_signal(vehicle, screen_w, screen_h)


    local x = 138
    local y = 120
    color = color_red
    if (g_animation_time % 1000) < 500 then
        color = color_yellow
    end

    update_ui_rectangle(
            0, 0, screen_w, screen_h, color_grey_dark
    )

    -- render_snowstorm(vehicle, screen_w, screen_h, 6)

    update_ui_rectangle_outline(
            x, y, 180, 19, color
    )
    local text = "SIGNAL JAMMED"
    update_ui_text(x + 58, y + 5, text, 200, 0, color, 0)
    text = string.format("Bandwidth %2.1f kbps", 50 + (math.floor(g_animation_time) % 255)/10)
    update_ui_text(x, y + 35, text, 200, 0, color, 0)
end

function find_nearest_vehicle_types(vehicle, other_defs, hostile, friendly_team, min_alt)
    -- find nearest vehicle of a range of types
    local vehicle_count = update_get_map_vehicle_count()
    if friendly_team == nil then
        friendly_team = vehicle:get_team_id()
    end
    local self_pos = vehicle:get_position()
    if min_alt == nil then
        min_alt = -100
    end
    local want_lifeboat = false
    if #other_defs == 1 then
        want_lifeboat = other_defs[1] == e_game_object_type.chassis_sea_lifeboat
    end
    local nearest = nil
    local distance_sq = 999999999
    for i = 0, vehicle_count - 1 do
        local unit = update_get_map_vehicle_by_index(i)
        if unit:get() and (unit:get_altitude() > min_alt or want_lifeboat) then
            local match_team = unit:get_team_id() == friendly_team
            if hostile then
                match_team = not match_team
            end
            
            if match_team and (want_lifeboat or not get_vehicle_docked(unit)) then
                local unit_def = unit:get_definition_index()
                for di = 1, #other_defs do
                    local other_def = other_defs[di]
                    if other_def == -1 or unit_def == other_def then
                        local dist = vec3_dist_sq(self_pos, unit:get_position())
                        if dist < distance_sq then
                            distance_sq = dist
                            nearest = unit
                        end
                    end
                end
            end
        end
    end

    return nearest
end

function find_nearest_vehicle(vehicle, other_def, hostile)
    -- find the nearest unit of a particualr type
    return find_nearest_vehicle_types(vehicle, {other_def}, hostile, nil, 60)
end

function render_fault(vehicle, screen_w, screen_h)

    if g_animation_time % 2000 < 1000 then
        update_ui_text(370, 200, "FAULT", 200, 0, color_enemy, 0)
        update_ui_rectangle_outline(368, 199, 33, 11, color_enemy)
    end
end

g_comms_snow_range = 380
g_comms_error_range = 170

g_snow_remaining = 0
g_last_health = 100
g_last_vid = -1

function do_comms_error(vehicle, screen_w, screen_h)
    if vehicle:get() then
        if (g_animation_time % 30) < 1 then
            local our_vid = vehicle:get_id()
            local total_hp = vehicle:get_total_hitpoints()
            local now_hp = vehicle:get_hitpoints()
            local hp_pct = now_hp / total_hp

            if our_vid == g_last_vid then
                -- compare health, if we lost more than 20%, then toggle show_snowstorm
                if (g_last_health - hp_pct) > 0.2 then
                    g_snow_remaining = 30
                end
            end
            g_last_health = hp_pct
        end

        math.randomseed(g_animation_time)
        local vdef = vehicle:get_definition_index()
        local show_comms_error = false
        local show_snowstorm = false
        local stop_hud = false
        local show_fault = false
        local multi = 1

        if get_is_vehicle_air(vdef) then
            if g_last_health < 0.3 then
                show_fault = true
            end
        end

        if g_snow_remaining > 0 then
            if get_is_vehicle_air(vdef) then
                show_fault = true
            end
            show_snowstorm = true
            g_snow_remaining = g_snow_remaining - 1
        end

        if vdef == e_game_object_type.chassis_sea_barge then
            local nearest_carrier = find_nearest_hostile_vehicle(vehicle, e_game_object_type.chassis_carrier)
            if nearest_carrier ~= nil then
                local nearest_carrier_dist = vec3_dist(nearest_carrier:get_position(), vehicle:get_position())
                show_comms_error = nearest_carrier_dist < g_comms_error_range
                show_snowstorm = nearest_carrier_dist < g_comms_snow_range
                stop_hud = true
                if show_snowstorm then
                    multi = 8 - (math.max(math.floor(nearest_carrier_dist / 50), 1))
                end
            end
        end

        if show_snowstorm then
            render_snowstorm(vehicle, screen_w, screen_h, multi)
        end

        if show_fault then
            render_fault(vehicle, screen_w, screen_h)
        end

        if show_comms_error then
            math.randomseed(g_animation_time + vehicle:get_id())

            render_bad_signal(vehicle, screen_w, screen_h)

            local col = color8(0, 255, 0, 255)
            local hud_size = vec2(230, 140)
            local hud_min = vec2((screen_w - hud_size:x()) / 2, (screen_h - hud_size:y()) / 2)
            local hud_pos = vec2(hud_min:x() + hud_size:x() / 2, hud_min:y() + hud_size:y() / 2)
            --render_compass(vec2(hud_pos:x(), hud_min:y() + hud_size:y()), col)
            render_fuel_gauge(vec2(hud_min:x() + hud_size:x() - 16, hud_pos:y() + 45 - 50), 50, vehicle, col)
            render_damage_gauge(vec2(hud_min:x() + hud_size:x() - 1, hud_pos:y() + 45 - 50), 50, vehicle, col)
            render_control_mode(vec2(hud_min:x() + hud_size:x() - 16, hud_pos:y() + 45 + 5), vehicle, col)
            if get_is_damage_warning(vehicle) then
                render_warning_text(hud_pos:x(), hud_min:y() - 10, update_get_loc(e_loc.upp_dmg_critical), col_red)
            end

            return show_snowstorm and show_comms_error and stop_hud
        end
    end

    return false
end


function round_int(value)
    return math.floor(value + 0.5)
end

g_hovering = false

function on_hover(vehicle, is_hover)
    if vehicle and vehicle:get() then
        -- g_hovering = is_hover
    end
end

g_hover_callback = on_hover


function vehicle_has_cargo(vehicle)
    -- do not know how to return true here
    return false
end

function get_unit_team(unit)
    if unit and unit:get() then
        return unit:get_team_id()
    end
    return nil
end

function slow_print(msg)
    if stable_tick(30, 1) then
        print(msg)
    end
end

function stable_tick(period_ticks, active_ticks)
    local tick = update_get_logic_tick()
    local window = tick % period_ticks
    return window < active_ticks
end

function render_compass_waypoint(x, y, w, mark, col, size, txt)
    if size == nil then
        size = 4
    end
    local csc, csc_clamped = world_to_screen_clamped(mark,
        vec2(x - w/2, 0),
        vec2(x + w/2, 200)
    )
    if not csc_clamped then
        if size > 0 then
            update_ui_rectangle_outline(csc:x() - 2, y - 2, size, 4, col)
        end
        if txt ~= nil then
            update_ui_text(csc:x() - 4, y + 10, txt, 24, 0, col, 0)
        end
    else
        -- update_ui_rectangle_outline(csc:x() - 2, y - 2, 4, 4, col)
        if csc:x() > x then
            update_ui_line(csc:x() - 3, y - 3, csc:x(), y, col)
            update_ui_line(csc:x() - 3, y + 3, csc:x(), y, col)
        else
            update_ui_line(csc:x(), y, csc:x() + 3, y - 3, col)
            update_ui_line(csc:x(), y, csc:x() + 3, y + 3, col)
        end
    end
end

function render_extra_compass_waypoint(mark, col, size, txt)
    if g_compass_pos ~= nil then
        local w = 150
        render_compass_waypoint(
                g_compass_pos:x(),
                g_compass_pos:y(),
                w,
                mark,
                col,
                size, txt)
    end
end

-- bullet projection
-- based on gun funnel code
function project_bullet_future(tick, vehicle, tick_fraction)
    local projectile_speed = 20
    local forward_dist = 1.5
    local projectile_gravity = 9.81 / 10
    local side_dist = 0
    local forward = vehicle:get_forward()
    local velocity = vehicle:get_linear_velocity()

    local forward_x = forward:x()
    local forward_y = forward:y()
    local forward_z = forward:z()
    local side = vehicle:get_side()
    local vehicle_pos = vehicle:get_position()

    -- s = u*t + 0.5*a*t^2
    -- calc time to hit ground
    -- 0 = 0.5at^2 + ut - s
    -- t = (-u + sqrt( u^2 - 4x0.5ax(-s)) / 2 (0.5a)
    -- t = (-u + sqrt ( u^2 - 2a(-s) ) / a
    local alt = vehicle_pos:y()
    local uy = velocity:y() + forward_y * projectile_speed
    local drop_time = (-uy + math.sqrt( (uy*uy) - (2 * projectile_gravity * -alt ) )) / projectile_gravity
    local dx = velocity:x() + (forward_x * projectile_speed) * drop_time
    local dz = velocity:z() + (forward_z * projectile_speed) * drop_time

    local p = vec3(dx + vehicle_pos:x(), 0, dz + vehicle_pos:z())
    local s = vec3_dist(p, vehicle_pos)
    if s > 2000 then
        -- does not hit ground within 2km, calibrate for air target 500m ahead
        return nil
    end
    return p
end

