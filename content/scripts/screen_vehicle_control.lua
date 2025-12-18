local math_rand = math.random
local math_floor = math.floor

-- highlighted map item state
g_highlighted = {
    vehicle_id = 0,
    waypoint_id = 0,
    command_center_id = 0,
    island_id = 0,
    turret_spawn_index = -1,
    production_index = -1,
    turret_cost = 0,

    clear = function(self)
        self.vehicle_id = 0
        self.waypoint_id = 0
        self.command_center_id = 0
        self.island_id = 0
        self.turret_spawn_index = -1
        self.production_index = -1
    end,

    set_vehicle = function(self, vehicle_id)
        self:clear()
        self.vehicle_id = vehicle_id
    end,

    set_vehicle_waypoint = function(self, vehicle_id, waypoint_id)
        self:clear()
        self.vehicle_id = vehicle_id
        self.waypoint_id = waypoint_id
    end,

    set_command_center = function(self, command_center_id)
        self:clear()
        self.command_center_id = command_center_id
    end,

    set_island_turret_spawn = function(self, island_id, turret_spawn_index)
        self:clear()
        self.island_id = island_id
        self.turret_spawn_index = turret_spawn_index
    end,

    set_island_production = function(self, island_id, production_index)
        self:clear()
        self.island_id = island_id
        self.production_index = production_index
    end
}

-- selected map item state
g_selection = {
    vehicle_id = 0,
    waypoint_id = 0,
    attack_target_vehicle_id = 0,
    command_center_id = 0,
    map = false,

    clear = function(self)
        self.vehicle_id = 0
        self.waypoint_id = 0
        self.attack_target_vehicle_id = 0
        self.command_center_id = 0
        self.map = false
    end,

    is_selection = function(self)
        return self.vehicle_id > 0 
            or self.waypoint_id > 0 
            or self.attack_target_vehicle_id > 0 
            or self.command_center_id > 0
            or self.map
    end,

    set_vehicle = function(self, vehicle_id)
        self:clear()
        self.vehicle_id = vehicle_id
    end,

    set_vehicle_waypoint = function(self, vehicle_id, waypoint_id)
        self:clear()
        self.vehicle_id = vehicle_id
        self.waypoint_id = waypoint_id
    end,

    set_attack_target_vehicle = function(self, vehicle_id, waypoint_id, attack_vehicle_id)
        self:set_vehicle_waypoint(vehicle_id, waypoint_id)
        self.attack_target_vehicle_id = attack_vehicle_id
    end,

    set_command_center = function(self, command_center_id)
        self:clear()
        self.command_center_id = command_center_id
    end,

    set_map = function(self)
        self:clear()
        self.map = true
    end,
}

-- dragged map item state
g_drag = {
    vehicle_id = 0,
    waypoint_id = 0,
    command_center_id = 0,
    island_id = 0,
    turret_spawn_index = -1,
    production_index = -1,

    clear = function(self)
        self.vehicle_id = 0
        self.waypoint_id = 0
        self.command_center_id = 0
        self.island_id = 0
        self.turret_spawn_index = -1
        self.production_index = -1
    end,

    is_drag = function(self)
        return self.vehicle_id > 0
            or self.waypoint_id > 0
            or self.command_center_id > 0
            or (self.island_id > 0 and self.turret_spawn_index ~= -1)
            or (self.island_id > 0 and self.production_index ~= -1)
    end,

    set_vehicle = function(self, vehicle_id)
        self:clear()
        self.vehicle_id = vehicle_id
    end,

    set_vehicle_waypoint = function(self, vehicle_id, waypoint_id)
        self:clear()
        self.vehicle_id = vehicle_id
        self.waypoint_id = waypoint_id
    end,

    set_command_center = function(self, command_center_id)
        self:clear()
        self.command_center_id = command_center_id
    end,

    set_island_turret_spawn = function(self, island_id, turret_spawn_index)
        self:clear()
        self.island_id = island_id
        self.turret_spawn_index = turret_spawn_index
    end,

    set_island_production = function(self, island_id, production_index)
        self:clear()
        self.island_id = island_id
        self.production_index = production_index
    end
}

g_command_center_ui = {
    selected_item = -1,
    is_place_turret = false,
    selected_panel = 0,
    selected_facility_queue_item = -1,
}

g_selected_vehicle_ui = {
    confirm_self_destruct = false,
}

--
-- notes on turret system - inb
-- marker_index values are global for the whole map, range 0 -> 100000
-- spawn_index values are per island
--
-- get the size of the island turret build queue:
--   island:get_facility_production_queue_defense_count() -> queue_size[int]

-- get the turret type and marker for a turret in the island build queue:
--   island:get_facility_production_queue_defense_item(queue_index[int]) -> type[enum], marker_index[int]

-- get marker_index and buildable status of a turret spawn slot:
--   island:get_turret_spawn(spawn_index[int]) -> marker_index[int], is_buildable[bool]

-- build a turret:
--   static method?
--   island:set_facility_add_production_queue_defense_item(turret_item_type[enum], marker_index[int])

-- cancel building a turret given a production queue index:
--   static method?
--   island:set_facility_remove_production_queue_defense_item(queue_index[int])
--

function get_icon_by_turret_type_id(turret_item_id)
    local icon = atlas_icons.icon_chassis_16_land_turret

    if (turret_item_id == nil) then
        return icon

    elseif turret_item_id == e_inventory_item.support_turret_gun then
        icon = atlas_icons.icon_attachment_16_turret_main_gun

    elseif turret_item_id == e_inventory_item.support_turret_ciws then
        icon = atlas_icons.icon_attachment_16_turret_ciws

    elseif turret_item_id == e_inventory_item.support_turret_missile then
        icon = atlas_icons.icon_attachment_16_turret_missile
    end

    return icon
end

function imgui_turret_button(self, item_data, label, is_enabled)
    local window = self:get_window()
    local x = window.cx
    local y = window.cy
    local w, h = self:get_region()
    local is_selected = window.selected_index_y == window.index_y
    local is_active = is_enabled and window.is_active
    local is_action = false

    local bx = x + 5
    local by = y

    local icon = get_icon_by_turret_type_id(item_data.index)
    local icon_col = iff(is_active, iff(is_selected, color_white, color_grey_dark), color_grey_dark)
    local text_col = iff(is_active, iff(is_selected, color_black, color_grey_dark), color_grey_dark)
    local _, text_h = update_ui_get_text_size(label, w - bx - 23, 0)

    if is_active and is_selected then
        render_button_bg(x + 1, y, w - 2, text_h + 6, color_highlight)
    end

    update_ui_image(bx, by, icon, icon_col, 0)
    update_ui_text(bx + 16 + 2, by + 3, label, w - bx - 23, 0, text_col, 0)
    window.cy = window.cy + text_h + 7

    local is_hovered = self:hoverable(x, y, w, window.cy - y, true)

    if is_selected and is_active then
        local is_clicked = is_hovered and self.input_pointer_1

        if is_hovered or update_get_active_input_type() == e_active_input.gamepad then
            update_add_ui_interaction(update_get_loc(e_loc.interaction_select), e_game_input.interact_a)
        end

        if self.input_action or is_clicked then
            is_action = true
            self.input_action = false
            self.input_pointer_1 = false
        end
    end

    return is_action
end

function get_island_turret_queue_number(island, marker_index)
    local queue_count = island:get_facility_production_queue_defense_count()
    for i = 0, queue_count - 1 do
        local item_type, item_marker_index = island:get_facility_production_queue_defense_item(i)
        if item_marker_index == marker_index then
            return item_type, i
        end
    end
    return nil, -1
end

function cancel_queued_island_turret(island, marker_index)
    local mtype, queue_index = get_island_turret_queue_number(island, marker_index)
    if mtype ~= nil then
        island:set_facility_remove_production_queue_defense_item(queue_index)
    end
end

function get_island_turret_progress(island, turret_spawn_index)
    local marker_index, is_valid = island:get_turret_spawn(turret_spawn_index)
    local queued_type_id, i = get_island_turret_queue_number(island, marker_index)
    if queued_type_id ~= nil then
        if i == 0 then
            -- currently building
            return island:get_facility_production_factor_defense()
        end
        -- in queue
        return 0
    end
    -- marker is not in production queue, if it's not a valid build
    -- location, the turret is already built
    if is_valid then
        -- vacant
        return -1
    end
    -- already built
    return 1
end

g_camera_pos_x = 0
g_camera_pos_y = 0
g_is_camera_pos_initialised = false
g_camera_size = (64 * 1024)
g_screen_index = 0
g_selected_child_vehicle_id = 0
g_is_ignore_tap = false
g_map_render_mode = 1
g_is_drag_pan_map = false
g_viewing_vehicle_id = 0
g_is_vehicle_team_colors = true
g_is_island_team_colors = true
g_is_carrier_waypoint = false
g_is_pip_enable = true
g_is_render_grid = true
g_is_show_aircraft_vectors = true

g_map_window_scroll = 0
g_selected_bay_index = -1

g_blend_tick = 0
g_prev_pos_x = 0
g_prev_pos_y = 0
g_prev_size = (64 * 1024)
g_next_pos_x = 0
g_next_pos_y = 0
g_next_size = (64 * 1024)

g_drag_distance = 0
g_blink_timer = 0

g_input_x = 0
g_input_y = 0
g_input_z = 0
g_input_w = 0

g_screen_vehicle_pos = vec2(0, 0)

g_animation_time = 0
g_go_code = 0
g_go_code_time = 100000

g_color_attack_order = color_status_dark_red
g_color_airlift_order = color_status_ok
g_color_waypoint = color8(0, 255, 255, 8)
g_color_waypoint_dark = color8(0, 128, 128, 4)
g_color_resupply = color8(0, 255, 128, 32)

g_is_mouse_mode = false
g_pointer_pos_x = 0
g_pointer_pos_y = 0
g_pointer_pos_x_prev = 0
g_pointer_pos_y_prev = 0
g_is_pointer_hovered = false
g_is_pointer_pressed = false

g_cursor_pos_x = 0
g_cursor_pos_y = 0

g_ui = nil

g_holomap_last_x = 0
g_holomap_last_y = 0
g_holomap_last_anim = 0

-- unit wall mode
g_wall_all = 1
g_wall_air = 2
g_wall_gnd = 3
g_wall_sea = 4
g_wall_trt = 5
g_wall_mode = g_wall_all -- all
g_wall_offset = 0

-- tutorial controls
g_tut_is_carrier_selected = false
g_tut_is_context_menu_open = false
g_tut_undocking_vehicle_id = 0
g_tut_selected_vehicle_id = 0
g_tut_selected_waypoint_id = 0

-- screen saver control
g_last_input_tick = -600

-- petrel tactical drop/lift
g_tactical_vid = 0

local color_shadow = color8(0, 0, 0, 168)

function ui_render_selection_carrier_vehicle_overview(x, y, w, h, carrier_vehicle)
    update_ui_rectangle(0, 0, 256, 256, color8(0, 0, 0, 128))
    
    local carrier_pos = carrier_vehicle:get_position_xz()

    local vehicle_count = update_get_map_vehicle_count()
    local deployed_vehicles = {}

    for i = 0, vehicle_count - 1 do
        local vehicle = update_get_map_vehicle_by_index(i)

        if vehicle:get() then
            local vehicle_team = vehicle:get_team()
            local vehicle_dist = vec2_dist( carrier_pos, vehicle:get_position_xz() )

            if vehicle_team == update_get_screen_team_id() and vehicle_dist <= 10000 then
                local def = vehicle:get_definition_index()

                if def ~= e_game_object_type.chassis_carrier and def ~= e_game_object_type.chassis_sea_barge and def ~= e_game_object_type.chassis_land_turret and def ~= e_game_object_type.chassis_land_robot_dog and def ~= e_game_object_type.chassis_spaceship and def ~= e_game_object_type.drydock then
                    local parent_vehicle_index = vehicle:get_attached_parent_id()

                    if parent_vehicle_index == 0 then
                        table.insert(deployed_vehicles, vehicle)
                    end
                end
            end
        end
    end

    local cell_spacing = 2
    local grid_w = w
    local cells_x = 6
    local cell_w = grid_w / cells_x - cell_spacing
    local cell_h = 16

    local grid_x = x + (w - grid_w) / 2
    local grid_y = y
    local cell_x = 0
    local cell_y = 0

    for i = 1, #deployed_vehicles do
        local cx = grid_x + cell_x * (cell_w + cell_spacing)
        local cy = grid_y + cell_y * (cell_h + cell_spacing)

        local vehicle = deployed_vehicles[i]

        local vehicle_definition_type = vehicle:get_definition_index()
        local vehicle_definition_name, vehicle_definition_region = get_chassis_data_by_definition_index(vehicle_definition_type)
        local region_vehicle_icon, icon_offset = get_icon_data_by_definition_index(vehicle_definition_type)

        update_ui_rectangle(cx, cy, cell_w, cell_h, color_black)
        update_ui_image(cx, cy, vehicle_definition_region, color_white, 0)

        local bar_h = 10
        local repair_factor = vehicle:get_repair_factor()
        local fuel_factor = vehicle:get_fuel_factor()
        local ammo_factor = vehicle:get_ammo_factor()
        local repair_bar = math.floor(repair_factor * bar_h)
        local fuel_bar = math.floor(fuel_factor * bar_h)
        local ammo_bar = math.floor(ammo_factor * bar_h)

        local bx = cx + 17
        local by = cy + 3

        update_ui_rectangle(bx, by, 1, bar_h, color8(16, 16, 16, 255))
        update_ui_rectangle(bx, by + bar_h - repair_bar, 1, repair_bar, color8(47, 116, 255, 255))
        update_ui_rectangle(bx + 2, by, 1, bar_h, color8(16, 16, 16, 255))
        update_ui_rectangle(bx + 2, by + bar_h - fuel_bar, 1, fuel_bar, color8(119, 85, 161, 255))
        update_ui_rectangle(bx + 4, by, 1, bar_h, color8(16, 16, 16, 255))
        update_ui_rectangle(bx + 4, by + bar_h - ammo_bar, 1, ammo_bar, color8(201, 171, 68, 255))

        cell_x = cell_x + 1
        if cell_x >= cells_x then
            cell_x = 0
            cell_y = cell_y + 1
        end
    end
end

function render_selection_carrier(screen_w, screen_h, carrier_vehicle)
    local ui = g_ui
    
    local is_local = update_get_is_focus_local()

    local selected_bay_index = -1
    local is_undock = false
    local loadout_w = 74
    local left_w = screen_w - loadout_w - 25
    local selected_vehicle = nil
    local region_w = 0
    local region_h = 0

    update_add_ui_interaction_special(update_get_loc(e_loc.interaction_navigate), e_ui_interaction_special.gamepad_dpad_all)
    g_tut_is_carrier_selected = true

    local window = ui:begin_window(update_get_loc(e_loc.upp_docked), 10, 10, left_w, 130, atlas_icons.column_pending, true, 2)
        region_w, region_h = ui:get_region()
        update_ui_line(region_w / 2, 0, region_w / 2, region_h, color_white)

        window.cy = window.cy + 5
        selected_bay_index, is_undock = imgui_carrier_docking_bays(ui, carrier_vehicle, 8, 22, g_animation_time)

        if is_local then
            g_selected_bay_index = selected_bay_index
        end

        selected_vehicle = update_get_map_vehicle_by_id(carrier_vehicle:get_attached_vehicle_id(g_selected_bay_index))

        if selected_vehicle ~= nil and selected_vehicle:get() then
            update_add_ui_interaction(update_get_loc(e_loc.interaction_deploy), e_game_input.interact_a)
        end

        if is_undock and selected_vehicle ~= nil and selected_vehicle:get() then
            undock_by_bay_index(carrier_vehicle, g_selected_bay_index)
        end
    ui:end_window()
    
    ui:begin_window(update_get_loc(e_loc.upp_deployed), 10, 145, left_w, 100, atlas_icons.column_pending, false, 2)
        ui_render_selection_carrier_vehicle_overview(0, 0, left_w, 100, carrier_vehicle)
    ui:end_window()
    
    window = ui:begin_window(update_get_loc(e_loc.upp_loadout), 10 + left_w + 5, 10, 74, 84, atlas_icons.column_stock, false, 2)
        region_w, region_h = ui:get_region()
        window.cy = region_h / 2 - 32
        imgui_vehicle_chassis_loadout(ui, selected_vehicle, g_selected_bay_index)
    ui:end_window()
end

function render_selection_vehicle(screen_w, screen_h, vehicle)
    update_ui_rectangle(0, 0, 256, 256, color8(0, 0, 0, 128))
    
    local screen_vehicle = update_get_screen_vehicle()

    update_add_ui_interaction_special(update_get_loc(e_loc.interaction_navigate), e_ui_interaction_special.gamepad_dpad_ud)

    if screen_vehicle:get() then
        if screen_vehicle:get_team() == vehicle:get_team() or get_is_spectator_mode() then
            local ui = g_ui
            
            local loadout_w = 74
            local left_w = screen_w - loadout_w - 25

            local window = ui:begin_window(update_get_loc(e_loc.upp_loadout), 10 + left_w + 5, 10, loadout_w, 84, atlas_icons.column_stock, false, 2)
                local region_w, region_h = ui:get_region()
                window.cy = region_h / 2 - 32
                imgui_vehicle_chassis_loadout(ui, vehicle, selected_bay_index)
            ui:end_window()

            local vehicle_definition_index = vehicle:get_definition_index()
            local vehicle_definition_name, vehicle_definition_region = get_chassis_data_by_definition_index(vehicle_definition_index)


            if vehicle_can_airlift(vehicle) and vehicle_has_cargo(vehicle) then
                local window2 = ui:begin_window("CARGO", 10 + left_w + 5, 10 + 94, loadout_w, 84, atlas_icons.column_stock, false, 2)
                local region_w, region_h = ui:get_region()
                window2.cy = region_h / 2 - 32
                local cargo_id = get_vehicle_cargo_id(vehicle)
                local cargo = update_get_map_vehicle_by_id(cargo_id)
                imgui_vehicle_chassis_loadout(ui, cargo, 0)
                ui:end_window()
            end

            local hitpoints = vehicle:get_hitpoints()
            local hitpoints_total = vehicle:get_total_hitpoints()
            local damage_factor = clamp(hitpoints / hitpoints_total, 0, 1)
            local fuel_factor = vehicle:get_fuel_factor()
            local ammo_factor = vehicle:get_ammo_factor()
            local color_low = color_status_bad
            local color_mid = color8(255, 255, 0, 255)
            local color_high = color_status_ok

            local title = vehicle_definition_name .. string.format( " ID %.0f", vehicle:get_id() )
            local is_window_active = g_selected_vehicle_ui.confirm_self_destruct == false

            ui:begin_window(title, 10, 10, left_w, 104, atlas_icons.column_pending, is_window_active, 2)
                ui:stat(update_get_loc(e_loc.hp), hitpoints .. "/" .. hitpoints_total, iff(damage_factor < 0.2, color_low, color_high))

                if vehicle_definition_index == e_game_object_type.chassis_land_turret then
                    ui:stat(update_get_loc(e_loc.upp_fuel), "---", color_grey_dark)
                    ui:stat(update_get_loc(e_loc.upp_ammo), "---", color_grey_dark)
                else
                    ui:stat(update_get_loc(e_loc.upp_fuel), string.format("%.0f%%", fuel_factor * 100), iff(fuel_factor < 0.25, color_low, iff(fuel_factor < 0.5, color_mid, color_high)))
                    ui:stat(update_get_loc(e_loc.upp_ammo), string.format("%.0f%%", ammo_factor * 100), iff(ammo_factor < 0.25, color_low, iff(ammo_factor < 0.5, color_mid, color_high)))
                end

                ui:header(update_get_loc(e_loc.upp_actions))

                if vehicle_definition_index ~= e_game_object_type.chassis_carrier and vehicle_definition_index ~= e_game_object_type.chassis_sea_barge and def_index ~= e_game_object_type.chassis_land_robot_dog then
                    local is_vehicle_hold_fire = vehicle:get_is_hold_fire()
                    local is_hold_fire, is_modified = ui:checkbox(update_get_loc(e_loc.hold_fire), is_vehicle_hold_fire)
                    if is_modified then vehicle:set_is_hold_fire(is_hold_fire) end
                end

                if vehicle.get_is_low_light ~= nil then
                    -- low light support available
                    if vehicle_definition_index ~= e_game_object_type.chassis_carrier and def_index ~= e_game_object_type.chassis_land_robot_dog then
                        local is_vehicle_low_light = vehicle:get_is_low_light()
                        local is_low_light, is_modified = ui:checkbox(update_get_loc(e_loc.low_light), is_vehicle_low_light)
                        if is_modified then
                            vehicle:set_is_low_light(is_low_light)
                        end
                    end
                end

                if ui:list_item(update_get_loc(e_loc.upp_center_to_vehicle), true) then
                    g_camera_pos_x = vehicle:get_position_xz():x()
                    g_camera_pos_y = vehicle:get_position_xz():y()
                end

                if get_is_vehicle_enterable(vehicle) then
                    if ui:list_item(update_get_loc(e_loc.upp_camera), true) then
                        update_set_screen_vehicle_control_id(vehicle:get_id())
                        g_viewing_vehicle_id = vehicle:get_id()
                        g_screen_index = 1
                    end
                    if ui:list_item("HOLD HERE", true) then
                        vehicle:clear_waypoints()
                        local alt = math.floor(math.max(0, get_unit_altitude(vehicle) - 10))
                        add_altitude_waypoint(vehicle, vehicle:get_position_xz(), alt, 3)
                        g_selection:clear()
                        g_is_ignore_tap = 1
                    end
                    if get_can_autoland(vehicle:get_definition_index()) then
                        if ui:list_item("LAND HERE", true) then
                            setup_autoland(vehicle)
                            g_selection:clear()
                            g_is_ignore_tap = 1
                        end
                    end

                    if vehicle_can_airlift(vehicle) then
                        local ptr_vid = vehicle:get_id()
                        if ptr_vid ~= g_tactical_vid then
                            if ui:list_item("SET TACTICAL MODE", true) then
                                vehicle:clear_waypoints()
                                vehicle:clear_attack_target()
                                g_tactical_vid = vehicle:get_id()

                                g_tactical_dropping = vehicle_has_cargo(vehicle)
                                g_tactical_lifting = not g_tactical_dropping

                            end
                        else
                            if ui:list_item("UNSET TACTICAL MODE", true) then
                                vehicle:clear_waypoints()
                                vehicle:clear_attack_target()
                                g_tactical_vid = 0
                            end
                        end

                        if vehicle_has_cargo(vehicle) then
                            if ui:list_item(update_get_loc(e_loc.upp_deploy_vehicle), true) then
                                set_airdrop_now(vehicle)
                                g_selection:clear()
                                g_is_ignore_tap = 1
                            end
                            if ui:list_item("CARGO " .. update_get_loc(e_loc.upp_camera), true) then
                                local cargo_id = get_vehicle_cargo_id(vehicle)
                                g_selection:set_vehicle(cargo_id)
                                update_set_screen_vehicle_control_id(cargo_id)
                                g_viewing_vehicle_id = cargo_id
                                g_screen_index = 1
                            end

                        else
                            local nearest_id, nearest_range = get_nearest_friendly_airliftable_id(vehicle, 750)
                            if nearest_id > 0 then
                                if ui:list_item("AIRLIFT NEAREST", true) then
                                    set_airlift_now(vehicle, nearest_id)
                                    g_selection:clear()
                                    g_is_ignore_tap = 1
                                end
                            end
                        end
                    end

                end

                local dock_state = vehicle:get_dock_state()
                local is_self_destruct = dock_state == e_vehicle_dock_state.undocked or dock_state == e_vehicle_dock_state.dock_queue or dock_state == e_vehicle_dock_state.docking
                is_self_destruct = is_self_destruct and vehicle:get_team() == screen_vehicle:get_team()
                if ui:list_item(update_get_loc(e_loc.upp_self_destruct), true, update_get_peer_is_admin(0) and is_self_destruct) then
                    g_selected_vehicle_ui.confirm_self_destruct = true
                end
            ui:end_window()

            local attachment_count = vehicle:get_attachment_count()
            local attachments = {}

            for i = 0, attachment_count - 1, 1 do
                local attachment = vehicle:get_attachment(i)

                if attachment:get() and (attachment:get_ammo_capacity() > 0 or attachment:get_fuel_capacity() > 0) then
                    table.insert(attachments, attachment)
                end
            end

            if #attachments > 0 and vehicle:get_definition_index() ~= e_game_object_type.chassis_land_turret then
                local window = ui:begin_window(update_get_loc(e_loc.upp_ammo), 10, 116, left_w, { max=130 }, atlas_icons.column_stock, false, 2)
                local region_w, region_h = ui:get_region()
                local cy = 0

                update_ui_rectangle(18, 0, 1, region_h, color_grey_dark)

                for _, attachment in ipairs(attachments) do
                    local adef = attachment:get_definition_index()
                    local attachment_data = get_attachment_data_by_definition_index(adef)
                    update_ui_image(1, cy + 1, attachment_data.icon16, color_white, 0)

                    local ammo_capacity = attachment:get_ammo_capacity()
                    local fuel_capacity = attachment:get_fuel_capacity()

                    if fuel_capacity > 0 then
                        local fuel_remaining = attachment:get_fuel_remaining()
                        update_ui_text(21, cy + 4, fuel_remaining  .. "/" .. fuel_capacity, 100, 0, iff(fuel_remaining == 0, color_status_bad, color_status_ok), 0)
                    elseif ammo_capacity > 0 then
                        local ammo_remaining = attachment:get_ammo_remaining()
                        update_ui_text(21, cy + 4, ammo_remaining .. "/" .. ammo_capacity, 100, 0, iff(ammo_remaining == 0, color_status_bad, color_status_ok), 0)
                    end

                    cy = cy + 17
                    update_ui_rectangle(0, cy, region_w, 1, color8(255, 255, 255, 2))
                end

                window.cy = cy + 1
                ui:end_window()
            end

            if g_selected_vehicle_ui.confirm_self_destruct then
                update_ui_rectangle(0, 0, screen_w, screen_h, color8(0, 0, 0, 128))

                ui.window_col_active = color_status_bad
                ui:begin_window_dialog(update_get_loc(e_loc.upp_sure), screen_w / 2, screen_h / 2, screen_w - 60, 80, atlas_icons.hud_warning, true)
                ui:text_basic(update_get_loc(e_loc.confirm_self_destruct), color_grey_dark)

                local action_index = ui:end_window_dialog(update_get_loc(e_loc.upp_no), update_get_loc(e_loc.upp_yes))

				if action_index == 0 then
					g_selected_vehicle_ui.confirm_self_destruct = false
				elseif action_index == 1 then
					vehicle:trigger_self_destruct()
					g_selected_vehicle_ui.confirm_self_destruct = false
				end

                ui.window_col_active = color_white
            end
        else
            g_selected_vehicle_ui.confirm_self_destruct = false
        end
    else
        g_selected_vehicle_ui.confirm_self_destruct = false
    end
end

function render_selection_command_center(screen_w, screen_h, selected_island)
    local ui = g_ui
    local win_x = 10
    local win_y = 10
    local win_w = 160
    local win_h = 100

    local is_windows_active = g_command_center_ui.selected_item == -1 and g_command_center_ui.selected_facility_queue_item == -1

    if is_windows_active and g_is_mouse_mode and g_is_pointer_hovered and g_is_pointer_pressed == false then
        if g_pointer_pos_y > (win_y + win_h + 30) then
            g_command_center_ui.selected_panel = 1
        else
            g_command_center_ui.selected_panel = 0
        end
    end

    if g_command_center_ui.is_place_turret == false then
        update_ui_rectangle(0, 0, 256, 256, color8(0, 0, 0, 128))

        ui:begin_window(update_get_loc(e_loc.upp_command_center), win_x, win_y, win_w, win_h, atlas_icons.column_team_control, is_windows_active and g_command_center_ui.selected_panel == 0, 2)
            if selected_island:get_turret_spawn_count() > 0 then
                local region_w, region_h = ui:get_region()
                local purchase_items = {}
                table.insert(purchase_items, g_item_data[e_inventory_item.support_turret_gun])
                table.insert(purchase_items, g_item_data[e_inventory_item.support_turret_ciws])
                table.insert(purchase_items, g_item_data[e_inventory_item.support_turret_missile])

                if update_get_active_input_type() == e_active_input.gamepad then
                    if ui:list_item(update_get_loc(e_loc.upp_queue), true) then
                        g_command_center_ui.selected_panel = 1
                    end
                end

                ui:header(update_get_loc(e_loc.upp_construct_defenses))

                 local column_widths = { 16, region_w - 16 }
                local column_margins = { 5, 5 }

                for _, item in ipairs(purchase_items) do
                    local icon = get_icon_by_turret_type_id(item.index)
                    columns = {
                        { w=column_widths[1], margin=column_margins[1], value=icon, col=color_grey_mid, is_border=false },
                        { w=column_widths[2], margin=column_margins[2], value=item.name }
                    }

                    local is_action = imgui_table_entry(ui, columns, true)

                    if is_action then
                        g_command_center_ui.selected_item = item.index
                    end
                end

                ui:spacer(3)
            else
                ui:header(update_get_loc(e_loc.upp_construct_defenses))
                ui:text_basic(update_get_loc(e_loc.island_has_no_defenses_available), color_grey_dark)
            end
        ui:end_window()

        local queue_count = selected_island:get_facility_production_queue_defense_count()

        update_ui_rectangle(win_x, win_y + win_h + 5, win_w, 18, color_black)
        update_ui_rectangle_outline(win_x, win_y + win_h + 5, win_w, 18, color_grey_dark)

        ui:begin_window("##progress", win_x + 1, win_y + win_h + 6, win_w - 2, 16, nil, false, 1, false, false)
            local status_text = update_get_loc(e_loc.upp_idle)
            local region_w, region_h = ui:get_region()
            local left_w = update_ui_get_text_size(status_text, win_w, 0) + 10
            local right_w = region_w - left_w

            update_ui_rectangle(left_w, region_h / 2 - 2, right_w - 5, 4, color_grey_dark)

            if queue_count == 0 then
                update_ui_text(5, region_h / 2 - 5, status_text, left_w, 0, color_grey_dark, 0)
            else
                local production_factor = selected_island:get_facility_production_factor_defense()
                update_ui_rectangle(left_w, region_h / 2 - 2, production_factor * (right_w - 5), 4, color_status_bad)

                local item_type_id, marker_index = selected_island:get_facility_production_queue_defense_item(0)
                local icon = get_icon_by_turret_type_id(item_type_id)
                local color = color_white

                if item_type_id == nil then
                    color = color_grey_dark
                end

                update_ui_image_rot(left_w / 2, region_h / 2, icon, color, 0)
            end
        ui:end_window()

        ui:begin_window(update_get_loc(e_loc.upp_queue).."##queue", win_x, win_y + win_h + 28, win_w, win_h, atlas_icons.column_pending, is_windows_active and g_command_center_ui.selected_panel == 1, 2)
            for i = 0, queue_count - 1 do
                local item_type_id, marker_index = selected_island:get_facility_production_queue_defense_item(i)
                local item_data = g_item_data[item_type_id]

                if item_data ~= nil then
                    if imgui_turret_button(ui, item_data, item_data.name, true) then
                        g_command_center_ui.selected_facility_queue_item = i
                    end

                    if i == 0 then
                        ui:divider(0, 2)
                    end
                end
            end

            ui:spacer(1)
        ui:end_window()
    end

    if g_command_center_ui.is_place_turret == false then
        if g_command_center_ui.selected_item ~= -1 then
            update_ui_rectangle(0, 0, screen_w, screen_h, color8(0, 0, 0, 200))
            local item = g_item_data[g_command_center_ui.selected_item]

            if item ~= nil then
                local win_w = 220
                local win_h = 90

                local window = ui:begin_window(item.name .. "##facilityitem", (screen_w - win_w) / 2, (screen_h - win_h) / 2, win_w, { max=win_h }, atlas_icons.column_stock, true, 2)
                    imgui_item_description(ui, nil, item, false, true)

                    ui:divider(3)
                    ui:spacer(1)

                    local currency = 0
                    local team = update_get_team(update_get_screen_team_id())

                    if team:get() then
                        currency = team:get_currency()
                    end

                    if ui:list_item(update_get_loc(e_loc.upp_construct), true, item.cost <= currency) then
                        g_highlighted.turret_cost = item.cost
                        g_command_center_ui.is_place_turret = true
                        g_command_center_ui.is_place_turret_many = false
                    end

                    if ui:list_item(update_get_loc(e_loc.upp_construct) .. "++", true, item.cost <= currency) then
                        g_highlighted.turret_cost = item.cost
                        g_command_center_ui.is_place_turret = true
                        g_command_center_ui.is_place_turret_many = true
                    end


                ui:end_window()
            else
                g_command_center_ui.selected_item = -1
            end
        end

        if g_command_center_ui.selected_facility_queue_item ~= -1 then
            update_ui_rectangle(0, 0, screen_w, screen_h, color8(0, 0, 0, 200))
            local queue_count = selected_island:get_facility_production_queue_defense_count()

            if g_command_center_ui.selected_facility_queue_item < queue_count then
                local item_type_id, marker_index = selected_island:get_facility_production_queue_defense_item(
                g_command_center_ui.selected_facility_queue_item)
                local item = g_item_data[item_type_id]

                if item ~= nil then
                    local win_w = 220
                    local win_h = 90

                    ui.window_col_active = color_status_bad
                    local window = ui:begin_window(item.name .. "##queueitem", (screen_w - win_w) / 2, (screen_h - win_h) / 2, win_w, { max=win_h }, atlas_icons.column_pending, true, 2)
                        imgui_item_description(ui, nil, item, false, true)

                        ui:divider(3)
                        ui:spacer(1)

                        if ui:button(update_get_loc(e_loc.upp_cancel_production), true, 1) then
                            selected_island:set_facility_remove_production_queue_defense_item(g_command_center_ui.selected_facility_queue_item)
                            g_command_center_ui.selected_facility_queue_item = -1
                        end
                    ui:end_window()
                    ui.window_col_active = color_white
                else
                    g_command_center_ui.selected_facility_queue_item = -1
                end
            else
                g_command_center_ui.selected_facility_queue_item = -1
            end
        end
    end

    render_currency_display(screen_w - 20, 10, true)
end

function undock_by_bay_index(carrier_vehicle, bay_index)
    local child_vehicle_id = carrier_vehicle:get_attached_vehicle_id(bay_index)

    if child_vehicle_id >= 0 then
        g_selected_child_vehicle_id = child_vehicle_id
    end

    g_selection:clear()
    g_screen_index = 0
end

function render_selection_waypoint(screen_w, screen_h)
    update_ui_rectangle(0, 0, 256, 256, color8(0, 0, 0, 128))

    local selected_vehicle = update_get_map_vehicle_by_id(g_selection.vehicle_id)

    update_add_ui_interaction_special(update_get_loc(e_loc.interaction_navigate), e_ui_interaction_special.gamepad_dpad_ud)

    if selected_vehicle:get() then
        local selected_waypoint = selected_vehicle:get_waypoint_by_id(g_selection.waypoint_id)

        if selected_waypoint:get() then
            local ui = g_ui
            local attack_type = -1

            local is_group_a = selected_waypoint:get_is_wait_group(0)
            local is_group_b = selected_waypoint:get_is_wait_group(1)
            local is_group_c = selected_waypoint:get_is_wait_group(2)
            local is_group_d = selected_waypoint:get_is_wait_group(3)
            local is_deploy = selected_waypoint:get_type() == e_waypoint_type.deploy
            local waypoint_altitude = selected_waypoint:get_altitude()
            local is_modified = false

            local window = ui:begin_window(update_get_loc(e_loc.upp_waypoint), 30, 30, screen_w - 60, screen_h - 60, atlas_icons.column_distance, true, 2)
                window.label_bias = 0.8

                ui:header(update_get_loc(e_loc.upp_wait_group))

                is_group_a, is_modified = ui:checkbox(update_get_loc(e_loc.upp_wait_alpha), is_group_a)
                if is_modified then selected_vehicle:set_waypoint_wait_group(g_selection.waypoint_id, 0, is_group_a) end

                is_group_b, is_modified = ui:checkbox(update_get_loc(e_loc.upp_wait_bravo), is_group_b)
                if is_modified then selected_vehicle:set_waypoint_wait_group(g_selection.waypoint_id, 1, is_group_b) end

                is_group_c, is_modified = ui:checkbox(update_get_loc(e_loc.upp_wait_charlie), is_group_c)
                if is_modified then selected_vehicle:set_waypoint_wait_group(g_selection.waypoint_id, 2, is_group_c) end

                is_group_d, is_modified = ui:checkbox(update_get_loc(e_loc.upp_wait_delta), is_group_d)
                if is_modified then selected_vehicle:set_waypoint_wait_group(g_selection.waypoint_id, 3, is_group_d) end

                local vehicle_definition_index = selected_vehicle:get_definition_index()
                local is_robot_dog_deploy = get_is_vehicle_robot_dog_deploy_available(selected_vehicle)
                local is_droid_deploy = get_is_vehicle_droid_deploy_available(selected_vehicle)

                if vehicle_definition_index == e_game_object_type.chassis_air_rotor_heavy or is_robot_dog_deploy or is_droid_deploy then
                    ui:header(update_get_loc(e_loc.upp_actions))

                    is_deploy, is_modified = ui:checkbox(update_get_loc(e_loc.upp_deploy_vehicle), is_deploy)
                    if is_modified then selected_vehicle:set_waypoint_type_deploy(g_selection.waypoint_id, is_deploy) end
                end

                window.label_bias = 0.5

                if get_is_vehicle_air(vehicle_definition_index) then
                    ui:header(update_get_loc(e_loc.upp_air))

                    -- waypoint altitude selector
                    local before_alt = waypoint_altitude
                    waypoint_altitude, is_modified = ui:selector(update_get_loc(e_loc.upp_altitude), waypoint_altitude, 0, 2000, 50)
                    if is_modified then
                        if before_alt < 110 and waypoint_altitude < before_alt then
                            if before_alt > 30 then
                                waypoint_altitude = before_alt - 10
                            else
                                waypoint_altitude = before_alt - 5
                            end
                        end
                        if waypoint_altitude > 2000 then
                            waypoint_altitude = 2000
                        elseif waypoint_altitude < 0 then
                            waypoint_altitude = 0
                        end

                        selected_vehicle:set_waypoint_altitude(g_selection.waypoint_id, waypoint_altitude)
                    end

                    -- waypoint altitude increments
                    local inc_val = { -500, -100, 100, 500 }
                    local inc_act = ui:button_group({ "-500", "-100", "+100", "+500" }, true)
                    if inc_act >= 0 and inc_act < #inc_val then
                        local new_alt = waypoint_altitude + inc_val[inc_act + 1]
                        new_alt = math.max(0, new_alt)
                        new_alt = math.min(2000, new_alt)
                        selected_vehicle:set_waypoint_altitude(g_selection.waypoint_id, new_alt)
                    end

                    -- waypoint altitude presets
                    local pre_val = { 400, 1100, 1700, 2000 }
                    local pre_act = ui:button_group({ "400", "1100", "1700", "2000" }, true)
                    if pre_act >= 0 and pre_act < #pre_val then
                        selected_vehicle:set_waypoint_altitude(g_selection.waypoint_id, pre_val[pre_act + 1])
                    end

                    if get_can_autoland(vehicle_definition_index) then
                        if ui:button("LAND HERE", true) then
                            local prev_pos = nil
                            if selected_waypoint:get_id() > 1 then
                                local prev_wpt = selected_vehicle:get_waypoint_by_id(selected_waypoint:get_id() - 1)
                                if prev_wpt then
                                    prev_pos = prev_wpt:get_position_xz()
                                end
                            end

                            setup_autoland(selected_vehicle, selected_waypoint:get_position_xz(), prev_pos)
                            g_selection:clear()
                            g_is_ignore_tap = 1
                        end
                    end
                end
            ui:end_window()
        else
            g_selection:clear()
        end
    else
        g_selection:clear()
    end
end

function render_selection_attack_target(screen_w, screen_h)
    update_ui_rectangle(0, 0, 256, 256, color8(0, 0, 0, 128))

    local ui = g_ui
    local attack_type = -1

    local selected_vehicle = update_get_map_vehicle_by_id(g_selection.vehicle_id)
    local attack_target_vehicle = update_get_map_vehicle_by_id(g_selection.attack_target_vehicle_id)

    update_add_ui_interaction_special(update_get_loc(e_loc.interaction_navigate), e_ui_interaction_special.gamepad_dpad_ud)

    if selected_vehicle:get() and attack_target_vehicle:get() then
        ui:begin_window(update_get_loc(e_loc.upp_attack_target), 64, 64, screen_w - 128, screen_h - 128, atlas_icons.column_laser, true, 2)

        local is_air = get_is_vehicle_air(attack_target_vehicle:get_definition_index())
        local is_land = get_is_vehicle_land(attack_target_vehicle:get_definition_index())
        local is_sea = get_is_vehicle_sea(attack_target_vehicle:get_definition_index())

        local is_attack_type_any_capable = selected_vehicle:get_is_attack_type_capable(e_attack_type.any, is_air, is_land, is_sea)
        local is_attack_type_bomb_single_capable = selected_vehicle:get_is_attack_type_capable(e_attack_type.bomb_single, is_air, is_land, is_sea)
        local is_attack_type_bomb_double_capable = selected_vehicle:get_is_attack_type_capable(e_attack_type.bomb_double, is_air, is_land, is_sea)
        local is_attack_type_missile_single_capable = selected_vehicle:get_is_attack_type_capable(e_attack_type.missile_single, is_air, is_land, is_sea)
        local is_attack_type_missile_double_capable = selected_vehicle:get_is_attack_type_capable(e_attack_type.missile_double, is_air, is_land, is_sea)
        local is_attack_type_torpedo_single_capable = selected_vehicle:get_is_attack_type_capable(e_attack_type.torpedo_single, is_air, is_land, is_sea)
        local is_attack_type_gun_capable = selected_vehicle:get_is_attack_type_capable(e_attack_type.gun, is_air, is_land, is_sea)
        local is_attack_type_rockets_capable = selected_vehicle:get_is_attack_type_capable(e_attack_type.rockets, is_air, is_land, is_sea)
        local is_attack_type_order_main_gun_capable = selected_vehicle:get_is_attack_type_capable(e_attack_type.order_main_gun, is_air, is_land, is_sea)
        local is_attack_type_order_cruise_missile_capable = selected_vehicle:get_is_attack_type_capable(e_attack_type.order_cruise_missile, is_air, is_land, is_sea)

        if is_attack_type_any_capable == false then
            ui:text_basic(update_get_loc(e_loc.no_attack_options_available), color_grey_dark)
        else
            if is_attack_type_any_capable and ui:list_item(update_get_loc(e_loc.upp_any), true) then attack_type = e_attack_type.any end
            if is_attack_type_bomb_single_capable and ui:list_item(update_get_loc(e_loc.upp_bomb_single), true) then attack_type = e_attack_type.bomb_single end
            if is_attack_type_bomb_double_capable and ui:list_item(update_get_loc(e_loc.upp_bomb_double), true) then attack_type = e_attack_type.bomb_double end
            if is_attack_type_missile_single_capable and ui:list_item(update_get_loc(e_loc.upp_missile_single), true) then attack_type = e_attack_type.missile_single end
            if is_attack_type_missile_double_capable and ui:list_item(update_get_loc(e_loc.upp_missile_double), true) then attack_type = e_attack_type.missile_double end
            if is_attack_type_torpedo_single_capable and ui:list_item(update_get_loc(e_loc.upp_torpedo), true) then attack_type = e_attack_type.torpedo_single end
            if is_attack_type_gun_capable and ui:list_item(update_get_loc(e_loc.upp_gun), true) then attack_type = e_attack_type.gun end
            if is_attack_type_rockets_capable and ui:list_item(update_get_loc(e_loc.upp_rockets), true) then attack_type = e_attack_type.rockets end
            if is_attack_type_order_main_gun_capable and ui:list_item(update_get_loc(e_loc.upp_attack_type_main_gun), true) then attack_type = e_attack_type.order_main_gun end
            if is_attack_type_order_cruise_missile_capable and ui:list_item(update_get_loc(e_loc.upp_attack_type_cruise_missile), true) then attack_type = e_attack_type.order_cruise_missile end
        end

        ui:end_window()

        if attack_type ~= -1 then
            if g_selection.waypoint_id == 0 then
                -- no waypoint selected so add one at selected vehicle's current position

                local selected_vehicle_pos_xz = selected_vehicle:get_position_xz()
                selected_vehicle:clear_waypoints()
                selected_vehicle:clear_attack_target()
                g_selection.waypoint_id = selected_vehicle:add_waypoint(selected_vehicle_pos_xz:x(), selected_vehicle_pos_xz:y())
            end

            local selected_waypoint = selected_vehicle:get_waypoint_by_id(g_selection.waypoint_id)

            if selected_waypoint:get() then
                local attack_target_index = selected_waypoint:get_attack_target_count()
                selected_vehicle:set_waypoint_attack_target_target_id(g_selection.waypoint_id, g_selection.attack_target_vehicle_id)
                selected_vehicle:set_waypoint_attack_target_attack_type(g_selection.waypoint_id, attack_target_index, attack_type)

                g_selection:clear()
            else
                g_selection:clear()
            end
        end
    else
        g_selection:clear()
    end
end

function render_selection_map(screen_w, screen_h)
    update_ui_rectangle(0, 0, 256, 256, color8(0, 0, 0, 128))

    local ui = g_ui

    update_add_ui_interaction_special(update_get_loc(e_loc.interaction_navigate), e_ui_interaction_special.gamepad_dpad_ud)

    local is_local = update_get_is_focus_local()

    local window = ui:begin_window(update_get_loc(e_loc.upp_map), 30, 30, screen_w - 60, screen_h - 60, atlas_icons.column_pending, true, 2)
        if is_local then
            g_map_window_scroll = window.scroll_y
        else
            window.scroll_y = g_map_window_scroll
        end

        window.label_bias = 0.8

        ui:header(update_get_loc(e_loc.upp_actions))

        if g_dev_options then

            if ui:list_item("start call timer", true) then
                if not g_trigger_call_timer then
                    g_trigger_call_timer = true
                    g_command_center_ui.selected_panel = 0
                    g_screen_index = 0
                    g_selection:clear()
                    print("timer armed")
                    return
                end
            end
            if ui:list_item("count calls", true) then
                if not g_count_calls then
                    g_count_calls = true
                    g_prof_counter = 0
                    g_command_center_ui.selected_panel = 0
                    g_screen_index = 0
                    g_selection:clear()
                    print("timer call count profiler armed")
                    debug.sethook(profiler_func, "cr")
                    return
                end
            end
        end

        if get_is_spectator_mode_real() then
            if ui:list_item("TOGGLE SPECTATOR MODE", true) then
                g_revolution_is_spectator_enabled = not g_revolution_is_spectator_enabled
            end
        end

        if ui:list_item(update_get_loc(e_loc.upp_center_to_carrier), true) then
            g_camera_pos_x = g_screen_vehicle_pos:x()
            g_camera_pos_y = g_screen_vehicle_pos:y()
        end

        ui:header(update_get_loc(e_loc.upp_orders))

        if ui:list_item(update_get_loc(e_loc.upp_alpha_go), true) then
            update_set_go_code(0)
            g_go_code = 0
            g_go_code_time = 0
        end

        if ui:list_item(update_get_loc(e_loc.upp_bravo_go), true) then
            update_set_go_code(1)
            g_go_code = 1
            g_go_code_time = 0
        end

        if ui:list_item(update_get_loc(e_loc.upp_charlie_go), true) then
            update_set_go_code(2)
            g_go_code = 2
            g_go_code_time = 0
        end

        if ui:list_item(update_get_loc(e_loc.upp_delta_go), true) then
            update_set_go_code(3)
            g_go_code = 3
            g_go_code_time = 0
        end

        ui:header(update_get_loc(e_loc.upp_options))
        if ui:list_item(update_get_loc(e_loc.upp_active) .. " " .. update_get_loc(e_loc.upp_vehicles), true) then
            g_screen_index = 2
            g_is_ignore_tap = 1
            return
        end

        ui:header(update_get_loc(e_loc.upp_map_mode))

        if ui:checkbox(update_get_loc(e_loc.upp_cartographic), g_map_render_mode == 1, true) then g_map_render_mode = 1 end
        if ui:checkbox(update_get_loc(e_loc.upp_wind), g_map_render_mode == 2, true) then g_map_render_mode = 2 end
        if ui:checkbox(update_get_loc(e_loc.upp_precipitation), g_map_render_mode == 3, true) then g_map_render_mode = 3 end
        if ui:checkbox(update_get_loc(e_loc.upp_fog), g_map_render_mode == 4, true) then g_map_render_mode = 4 end
        if ui:checkbox(update_get_loc(e_loc.upp_ocean_current), g_map_render_mode == 5, true) then g_map_render_mode = 5 end
        if ui:checkbox(update_get_loc(e_loc.upp_ocean_depth), g_map_render_mode == 6, true) then g_map_render_mode = 6 end

        ui:divider()

        g_is_vehicle_team_colors = ui:checkbox(update_get_loc(e_loc.upp_vehicle_team_colors), g_is_vehicle_team_colors)
        g_is_island_team_colors = ui:checkbox(update_get_loc(e_loc.upp_island_team_colors), g_is_island_team_colors)

        g_is_carrier_waypoint = ui:checkbox("SHOW CARRIER WAYPOINTS", g_is_carrier_waypoint)
        g_is_show_aircraft_vectors = ui:checkbox("SHOW AIRCRAFT VECTORS", g_is_show_aircraft_vectors)
        g_is_show_aircraft_shadows = ui:checkbox("SHOW AIRCRAFT SHADOWS", g_is_show_aircraft_shadows)
        g_is_pip_enable = ui:checkbox("ENABLE CCTV FEED", g_is_pip_enable)
        g_is_render_grid = ui:checkbox("SHOW GRID", g_is_render_grid)

        ui:spacer(5)

    ui:end_window()
end

function render_selection(screen_w, screen_h)
    update_add_ui_interaction(update_get_loc(e_loc.interaction_cancel), e_game_input.back)

    if g_selection.attack_target_vehicle_id > 0 then
        render_selection_attack_target(screen_w, screen_h)
    elseif g_selection.waypoint_id > 0 then
        render_selection_waypoint(screen_w, screen_h)
    elseif g_selection.vehicle_id > 0 then
        local selected_vehicle = update_get_map_vehicle_by_id(g_selection.vehicle_id)

        if selected_vehicle:get() then
            local vehicle_definition_index = selected_vehicle:get_definition_index()

            if vehicle_definition_index == 0 then -- carrier
                render_selection_carrier(screen_w, screen_h, selected_vehicle)
            elseif selected_vehicle:get_team() == update_get_screen_team_id() or get_is_spectator_mode() then
                render_selection_vehicle(screen_w, screen_h, selected_vehicle)
            end
        else
             g_selection:clear()
        end
    elseif g_selection.command_center_id > 0 then
        local selected_island = update_get_tile_by_id(g_selection.command_center_id)

        if selected_island:get() and selected_island:get_team_control() == update_get_screen_team_id() then
            render_selection_command_center(screen_w, screen_h, selected_island)
        else
            g_selection:clear()
        end
    else
        render_selection_map(screen_w, screen_h)
    end
end

function input_selection(event, action)

    if action == e_input_action.press and event == e_input.back then
        if g_command_center_ui.is_place_turret then
            g_command_center_ui.is_place_turret = false
            if g_command_center_ui.is_place_turret_many then
                g_command_center_ui.selected_item = -1
            end
            return true
        elseif g_command_center_ui.selected_facility_queue_item ~= -1 then
            g_command_center_ui.selected_facility_queue_item = -1
            return true
        elseif g_command_center_ui.selected_item ~= -1 then
            g_command_center_ui.selected_item = -1
            return true
        elseif g_command_center_ui.selected_panel == 1 and g_is_mouse_mode == false then
            g_command_center_ui.selected_panel = 0
            return true
        elseif g_selected_vehicle_ui.confirm_self_destruct then
            g_selected_vehicle_ui.confirm_self_destruct = false
            return true
        else
            g_command_center_ui.selected_panel = 0
            g_selection:clear()
            return true
        end
    else
        g_ui:input_event(event, action)
    end

    return get_is_placing_turret() == false
end

function parse()
    g_prev_pos_x = g_next_pos_x
    g_prev_pos_y = g_next_pos_y
    g_prev_size = g_next_size
    g_blend_tick = 0

    g_is_camera_pos_initialised = parse_bool("is_map_init", g_is_camera_pos_initialised)
    g_next_pos_x = parse_f32("map_x", g_next_pos_x)
    g_next_pos_y = parse_f32("map_y", g_next_pos_y)
    g_next_size = parse_f32("map_size", g_next_size)
    g_screen_index = parse_s32("", g_screen_index)
    g_highlighted.vehicle_id = parse_s32("", g_highlighted.vehicle_id)
    g_drag.vehicle_id = parse_s32("", g_drag.vehicle_id)
    g_drag.waypoint_id = parse_s32("", g_drag.waypoint_id)
    g_selection.vehicle_id = parse_s32("", g_selection.vehicle_id)
    g_selection.waypoint_id = parse_s32("", g_selection.waypoint_id)
    g_selected_child_vehicle_id = parse_s32("", g_selected_child_vehicle_id)
    g_selection.map = parse_bool("", g_selection.map)
    g_map_render_mode = parse_s32("mode", g_map_render_mode)
    g_cursor_pos_x = parse_f32("", g_cursor_pos_x)
    g_cursor_pos_y = parse_f32("", g_cursor_pos_y)
    g_is_vehicle_team_colors = parse_bool("is_vehicle_team_colors", g_is_vehicle_team_colors)
    g_viewing_vehicle_id = parse_s32("", g_viewing_vehicle_id)
    g_is_island_team_colors = parse_bool("is_island_team_colors", g_is_island_team_colors)

    -- End of original parse calls

    g_is_carrier_waypoint = parse_bool("is_show_carrier_waypoints", g_is_carrier_waypoint)
    g_is_pip_enable = parse_bool("is_show_cctv", g_is_pip_enable)
    g_is_render_grid = parse_bool("is_show_grid", g_is_render_grid)
    g_map_window_scroll = parse_f32("", g_map_window_scroll)
    g_selected_bay_index = parse_s32("", g_selected_bay_index)
end

g_is_big_display = false
g_screen_name = nil

function begin()
    begin_load()

    if call_func_override("screen_vehicle_control__begin_after") then
        return
    end

    begin_load_inventory_data()
    g_ui = lib_imgui:create_ui()
    local screen_name = begin_get_screen_name()
    g_screen_name = screen_name
    g_is_big_display = screen_name == "holomap_screen2"
end

function err_handler(arg)
    print(debug.traceback())
end

function draw_aircraft_vector(vehicle, screen_pos_x, screen_pos_y)
    if g_is_show_aircraft_vectors then
        local vehicle_dir = vehicle:get_direction()
        update_ui_line(screen_pos_x, screen_pos_y,
                screen_pos_x + (vehicle_dir:x() * 10), screen_pos_y + (vehicle_dir:y() * -10),
                color_grey_dark)

    end
end

g_revolution_control_units = true
g_revolution_control_drydock_mode = false

function update(screen_w, screen_h, ticks)
    if update_get_is_focus_local() then
        g_last_input_tick = update_get_logic_tick()
    end

    if ticks > 4 then
        -- player too far away
        return
    end

    if call_func_override("screen_vehicle_control__update", screen_w, screen_h, ticks) then
        return
    end
    g_revolution_control_drydock_mode = false
    if do_screensaver(screen_w, screen_h, e_loc.upp_vehicle_control) then
        return
    else
        if string.match(g_screen_name, "drydock") then
            if team_eliminated(update_get_screen_team_id()) then
                -- pan around to the action on the big screen
                g_revolution_control_drydock_mode = true
            end
        end
    end

    if g_revolution_control_drydock_mode then
        g_revolution_is_spectator = true
        g_revolution_control_units = false

        -- center on last destroyed vehicle
        local destroyed_vehicle_count = update_get_map_destroyed_vehicle_count()
        if destroyed_vehicle_count > 0 then
            local destroyed_vehicle = update_get_map_destroyed_vehicle(destroyed_vehicle_count - 1)
            if destroyed_vehicle:get() then
                local destroyed_vehicle_position = destroyed_vehicle:get_position_xz(destroyed_vehicle_count - 1)
                g_camera_pos_x = destroyed_vehicle_position:x()
                g_camera_pos_y = destroyed_vehicle_position:y()
            end
        end
    end

    if g_trigger_call_timer then
        dev_call_timer(g_screen_name,
                5,  -- seconds to time
                90, -- ticks
                function()
                    g_fow_last_tick = 0
                    g_force_radar_scan = true
                    _update(screen_w, screen_h, ticks)
                    g_force_radar_scan = false
                end
        )
    end

    if not g_debug_enabled then
        _update(screen_w, screen_h, ticks)
    else
        local st, err = xpcall(_update, err_handler, screen_w, screen_h, ticks)
        if not st then
            print(err)
        end
    end

    if g_is_big_display then
        big_display_update(screen_w, screen_h, ticks)
    end
end

function big_display_update(screen_w, screen_h, ticks)

    ---- little log window
    --local logwindow = g_ui:begin_window(update_get_loc(e_log.upp_ship_log), 32, 240, 200, 200, atlas_icons.column_message, true, 2)
    --local log_count = update_get_notification_log_count()
    --for i = log_count - 1, 10, -1 do
    --    local log = update_get_notification_log(i)
    --    if log:get() then
    --        g_ui:text_basic()
    --        imgui_notification_log(ui, log, column_widths, column_margins, i < g_last_read_index)
    --    end
    --end
    --
    --g_ui:end_window()
end

g_hostile_air_histories = {}

function get_next_waypoint_xz(vehicle)
    local first = nil
    if vehicle and vehicle:get() then
        local waypoint_count = vehicle:get_waypoint_count()
        if waypoint_count > 0 then
            for j = 0, waypoint_count - 1, 1 do
                local waypoint = vehicle:get_waypoint(j)
                if first == nil then
                    first = waypoint
                end
                if waypoint:get_repeat_index() >= 0 then
                    return nil
                end
            end
        end
    end
    if first then
        return first:get_position_xz()
    end
    return nil
end

g_last_waypoint_send = 0

function _update(screen_w, screen_h, ticks)
    g_screen_w = screen_w
    g_screen_h = screen_h
    g_last_update_interval = ticks

    g_is_mouse_mode = g_is_pointer_hovered and update_get_active_input_type() == e_active_input.keyboard
    g_animation_time = g_animation_time + ticks
    refresh_modded_radar_cache()
    refresh_fow_islands()
    refresh_missile_data(true)

    g_hover_callback = nil

    if g_tactical_vid ~= 0 then
        if g_viewing_vehicle_id ~= 0 and g_viewing_vehicle_id ~= g_tactical_vid then
            g_tactical_vid = 0
        end
        local tactical = update_get_map_vehicle_by_id(g_tactical_vid)
        if tactical and tactical:get() then
            -- unset if it has waypoints
            if update_get_is_focus_local() then
                -- we are in tactical mode

                if g_viewing_vehicle_id == g_tactical_vid then
                    -- operator is flying the tactical unit
                    tactical_hover_check(tactical)
                end
            end
        else
            g_tactical_vid = 0
        end
    end

    local screen_vehicle = update_get_screen_vehicle()
    local screen_team = update_get_screen_team_id()
    g_screen_vehicle_pos = screen_vehicle:get_position_xz()

    if g_is_camera_pos_initialised == false and screen_vehicle:get() then
        g_is_camera_pos_initialised = true

        local position_xz = screen_vehicle:get_position_xz()
        g_camera_pos_x = position_xz:x()
        g_camera_pos_y = position_xz:y()
        g_next_pos_x = g_camera_pos_x
        g_next_pos_y = g_camera_pos_y
    end

    update_set_screen_vehicle_control_id(g_viewing_vehicle_id)

    g_blink_timer = g_blink_timer + ticks
    if g_blink_timer > 30 then
        g_blink_timer = 0
    end

    if update_get_is_focus_local() then
        g_next_pos_x = g_camera_pos_x
        g_next_pos_y = g_camera_pos_y
        g_next_size = g_camera_size
    else
        g_blend_tick = g_blend_tick + ticks
        local blend_factor = clamp(g_blend_tick / 10.0, 0.0, 1.0)
        g_camera_pos_x = lerp(g_prev_pos_x, g_next_pos_x, blend_factor)
        g_camera_pos_y = lerp(g_prev_pos_y, g_next_pos_y, blend_factor)
        g_camera_size = lerp(g_prev_size, g_next_size, blend_factor)
    end

    if update_screen_overrides(screen_w, screen_h, ticks) then return end

    g_tut_is_carrier_selected = false
    g_tut_is_context_menu_open = g_selection:is_selection()
    g_tut_undocking_vehicle_id = 0
    g_tut_selected_vehicle_id = g_selection.vehicle_id
    g_tut_selected_waypoint_id = g_selection.waypoint_id

    update_interaction_ui()

    g_ui:begin_ui()

    update_cursor_state(screen_w, screen_h)

    if g_screen_index == 0 then
        -- main map view
        rev_render_islands(g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

        if get_is_map_movement_allowed() then
            g_camera_pos_x = g_camera_pos_x + (g_input_x * g_camera_size * 0.01)
            g_camera_pos_y = g_camera_pos_y + (g_input_y * g_camera_size * 0.01)

            if update_get_active_input_type() == e_active_input.keyboard then
                input_zoom_camera(1 - (g_input_w * 0.1), screen_w, screen_h, screen_w / 2, screen_h / 2)
            else
                input_zoom_camera(1 - (g_input_w * 0.1), screen_w, screen_h)
            end

            if update_get_active_input_type() == e_active_input.keyboard and g_is_pointer_pressed then
                g_drag_distance = g_drag_distance + math.abs(g_pointer_pos_x - g_pointer_pos_x_prev) + math.abs(g_pointer_pos_y - g_pointer_pos_y_prev)
            end

            if g_is_drag_pan_map then
                local pointer_dx, pointer_dy = get_world_delta_from_screen(g_pointer_pos_x - g_pointer_pos_x_prev, g_pointer_pos_y - g_pointer_pos_y_prev, g_camera_size, screen_w, screen_h)

                g_camera_pos_x = g_camera_pos_x - pointer_dx
                g_camera_pos_y = g_camera_pos_y - pointer_dy
            end

            g_drag_distance = g_drag_distance + math.abs(g_input_x) + math.abs(g_input_y)
        end

        update_set_screen_background_type(g_map_render_mode)
        update_set_screen_map_position_scale(g_camera_pos_x, g_camera_pos_y, g_camera_size)
        if not g_revolution_full_fow then
            update_set_screen_background_is_render_islands(get_is_collapse_islands() == false)
        end

        local displayed_unit_count = 0
        local revealed_unit_count = 0
        local force_revealed_unit_count = 0
        local visible_unit_count = 0
        local unit_count = 0
        local current_tick = update_get_logic_tick()

        local is_placing_turret = get_is_placing_turret()

        -- update highlighted vehicle/tile

        g_highlighted:clear()

        if g_is_mouse_mode == false or g_is_drag_pan_map == false then
            local highlighted_distance_best = 10

            if is_placing_turret then
                if get_is_collapse_islands() == false then
                    local island = update_get_tile_by_id(g_selection.command_center_id)

                    if island:get() then
                        local turret_spawn_count = island:get_turret_spawn_count()

                        for i = 0, turret_spawn_count - 1, 1 do
                            local marker_index, is_valid = island:get_turret_spawn(i)
                            local turret_spawn_xz = island:get_marker_position(marker_index)
                            local screen_pos_x, screen_pos_y = get_screen_from_world(turret_spawn_xz:x(), turret_spawn_xz:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                            local distance_to_cursor = math.abs(screen_pos_x - g_cursor_pos_x) + math.abs(screen_pos_y - g_cursor_pos_y)

                            if distance_to_cursor < highlighted_distance_best and distance_to_cursor < 8 then
                                g_highlighted:set_island_turret_spawn(island:get_id(), i)
                                highlighted_distance_best = distance_to_cursor
                            end
                        end
                    end
                end
            else
                if get_is_collapse_islands() == false then
                    local island_count = update_get_tile_count()

                    for i = 0, island_count - 1 do
                        local island = update_get_tile_by_index(i)

                        if island:get() and rev_show_island_icon(island:get_id()) then
                            local command_center_count = island:get_command_center_count()

                            for j = 0, command_center_count - 1 do
                                local command_center_pos_xz = island:get_command_center_position(j)
                                local screen_pos_x, screen_pos_y = get_screen_from_world(command_center_pos_xz:x(), command_center_pos_xz:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                                local distance_to_cursor = math.abs(screen_pos_x - g_cursor_pos_x) + math.abs(screen_pos_y - g_cursor_pos_y)

                                if distance_to_cursor < highlighted_distance_best and distance_to_cursor < 10 then
                                    g_highlighted:set_command_center(island:get_id())
                                    highlighted_distance_best = distance_to_cursor
                                end
                            end

                            if island:get_team_control() == screen_team then
                                local production_count = island:get_facility_production_queue_defense_count()

                                for j = 0, production_count - 1, 1 do
                                    local item_type, marker_index = island:get_facility_production_queue_defense_item(j)
                                    local marker_pos_xz = island:get_marker_position(marker_index)

                                    local screen_pos_x, screen_pos_y = get_screen_from_world(marker_pos_xz:x(), marker_pos_xz:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                                    local distance_to_cursor = math.abs(screen_pos_x - g_cursor_pos_x) + math.abs(screen_pos_y - g_cursor_pos_y)

                                    if distance_to_cursor < highlighted_distance_best and distance_to_cursor < 8 then
                                        g_highlighted:set_island_production(island:get_id(), j)
                                        highlighted_distance_best = distance_to_cursor
                                    end
                                end
                            end
                        end
                    end
                end

                for x, vehicle in pairs(get_vehicles_table()) do
                    local vehicle_definition_index = vehicle:get_definition_index()

                    if vehicle_definition_index ~= e_game_object_type.chassis_spaceship and vehicle_definition_index ~= e_game_object_type.drydock then
                        local vehicle_team = vehicle:get_team()
                        local vehicle_attached_parent_id = vehicle:get_attached_parent_id()
                        local revealed = vehicle:get_is_observation_revealed()
                        local visible = vehicle:get_is_visible() or get_is_spectator_mode()
                        unit_count = unit_count + 1

                        if revealed then
                            revealed_unit_count = revealed_unit_count + 1
                        end
                        if visible then
                            visible_unit_count = visible_unit_count + 1
                        end

                        if not revealed then
                            revealed = get_is_visible_by_modded_radar(vehicle) or get_is_spectator_mode()
                            if revealed then
                                force_revealed_unit_count = force_revealed_unit_count + 1
                            end
                        end
                        local v_hover = vehicle_attached_parent_id == 0
                        if g_camera_size < 600 then
                            if not v_hover then
                                if vehicle_team == screen_team then
                                    if get_is_vehicle_land(vehicle_definition_index) or get_is_vehicle_air(vehicle_definition_index) then
                                        v_hover = true
                                        local parent = update_get_map_vehicle_by_id(vehicle_attached_parent_id)
                                        if parent and parent:get() then
                                            if parent:get_definition_index() == e_game_object_type.chassis_air_rotor_heavy then
                                                -- dont allow mouse highlight for stuff carried by a petrel
                                                v_hover = false
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        if v_hover and ( visible and revealed ) then
                            local vehicle_pos_xz = vehicle:get_position_xz()
                            local screen_pos_x, screen_pos_y = get_screen_from_world(vehicle_pos_xz:x(), vehicle_pos_xz:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                            local vehicle_distance_to_cursor = math.abs(screen_pos_x - g_cursor_pos_x) + math.abs(screen_pos_y - g_cursor_pos_y)

                            if vehicle_distance_to_cursor < highlighted_distance_best and vehicle_distance_to_cursor < 8 then
                                g_highlighted:set_vehicle(vehicle:get_id())
                                highlighted_distance_best = vehicle_distance_to_cursor
                            end
                        end

                        if vehicle_team == screen_team or get_is_spectator_mode() then
                            local waypoint_count = vehicle:get_waypoint_count()

                            if g_drag.vehicle_id == 0 or g_drag.vehicle_id == vehicle:get_id() then
                                for j = 0, waypoint_count - 1, 1 do
                                    local waypoint = vehicle:get_waypoint(j)
                                    local waypoint_type = waypoint:get_type()

                                    if waypoint_type == e_waypoint_type.move or waypoint_type == e_waypoint_type.deploy then
                                        local waypoint_pos = waypoint:get_position_xz(j)
                                        local waypoint_screen_pos_x, waypoint_screen_pos_y = get_screen_from_world(waypoint_pos:x(), waypoint_pos:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                                        local waypoint_distance_to_cursor = math.abs(waypoint_screen_pos_x - g_cursor_pos_x) + math.abs(waypoint_screen_pos_y - g_cursor_pos_y)

                                        if waypoint_distance_to_cursor < highlighted_distance_best and waypoint_distance_to_cursor < 8 then
                                            g_highlighted:set_vehicle_waypoint(vehicle:get_id(), waypoint:get_id())
                                            highlighted_distance_best = waypoint_distance_to_cursor
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        -- render islands

        if get_is_collapse_islands() then
            local island_count = update_get_tile_count()

            for i = 0, island_count - 1, 1 do
                local island = update_get_tile_by_index(i)

                if island:get() and rev_show_island_icon(island:get_id()) then
                    local island_position = island:get_position_xz()
                    local island_color = get_island_team_color(island:get_team_control())
                    local visible = fow_island_visible(island:get_id())
                    if not visible then
                        island_color = g_island_color_unknown
                    end

                    local screen_pos_x, screen_pos_y = get_screen_from_world(island_position:x(), island_position:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                    local island_capture = island:get_team_capture()
                    local island_team = island:get_team_control()
                    local island_capture_progress = island:get_team_capture_progress()
                    local team_color = get_island_team_color(island_capture)
                    if not visible then
                        team_color = g_island_color_unknown
                    end

                    if update_get_is_focus_local() and rev_show_island_name(island:get_id()) then
                        local island_name = get_island_name(island)
                        -- <  66000 full alpha
                        -- > 120000 0 alpha
                        if g_camera_size < 120000 then
                            local scaled_alpha = math.ceil(255 * (120000 - g_camera_size) / (120000 - 66000))
                            local island_col = color8(team_color:r(), team_color:g(), team_color:b(), math.min(scaled_alpha, team_color:a()))
                            local island_name_size = update_ui_get_text_size_mini(island_name)
                            update_ui_text_mini(screen_pos_x - island_name_size / 2.1,
                                    screen_pos_y - 15,
                                    island_name, island_name_size, 1, island_col)
                        end
                    end

                    if rev_show_island_icon(island:get_id()) then
                        if visible and island_capture ~= island_team and island_capture ~= -1 and island_capture_progress > 0 then
                            local color = iff(g_blink_timer > 15, team_color, island_color)
                            update_ui_image(screen_pos_x - 4, screen_pos_y - 4, atlas_icons.map_icon_island, color, 0)
                        else
                            update_ui_image(screen_pos_x - 4, screen_pos_y - 4, atlas_icons.map_icon_island, island_color, 0)
                        end
                    end
                end
            end
        else
            local island_count = update_get_tile_count()

            for i = 0, island_count - 1, 1 do
                local island = update_get_tile_by_index(i)

                if island:get() and rev_show_island_icon(island:get_id()) then
                    local island_id = island:get_id()

                    if is_placing_turret == false or g_selection.command_center_id == island_id then
                        local command_center_count = island:get_command_center_count()
                        local island_color = get_island_team_color(island:get_team_control())
                        local visible = fow_island_visible(island_id)
                        if not visible then
                            island_color = g_island_color_unknown
                        end

                        if command_center_count == 0 then
                            -- island is loading
                        else
                            local command_center_position = island:get_command_center_position(0)
                            local screen_pos_x, screen_pos_y = get_screen_from_world(command_center_position:x(), command_center_position:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                            local island_capture = island:get_team_capture()
                            local island_team = island:get_team_control()
                            local island_capture_progress = island:get_team_capture_progress()
                            local team_color = get_island_team_color(island_capture)

                            if visible and island_capture ~= island_team and island_capture ~= -1 and island_capture_progress > 0 and is_placing_turret == false then
                                local color = iff(g_blink_timer > 15, team_color, island_color)

                                if g_highlighted.command_center_id == island_id then
                                    color = color_white
                                end

                                update_ui_image(screen_pos_x - 8, screen_pos_y - 11, atlas_icons.map_icon_command_center, color, 0)

                                update_ui_rectangle(screen_pos_x - 9, screen_pos_y + 6, 18, 5, color8(0, 0, 0, 255))
                                update_ui_rectangle(screen_pos_x - 8, screen_pos_y + 7, 16 * island_capture_progress, 3, team_color)
                            else
                                local color = iff(g_highlighted.command_center_id == island_id, color_white, island_color)

                                update_ui_image(screen_pos_x - 8, screen_pos_y - 11, atlas_icons.map_icon_command_center, color, 0)
                            end
                        end

                        if is_placing_turret and g_selection.command_center_id == island_id then
                            local turret_spawn_count = island:get_turret_spawn_count()

                            for j = 0, turret_spawn_count - 1, 1 do
                                local marker_index, is_valid = island:get_turret_spawn(j)
                                local is_highlighted = g_highlighted.island_id == island_id and g_highlighted.turret_spawn_index == j

                                local turret_spawn_xz = island:get_marker_position(marker_index)
                                local screen_pos_x, screen_pos_y = get_screen_from_world(turret_spawn_xz:x(), turret_spawn_xz:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)


                                local color = iff(is_highlighted, color_white, iff(is_valid, iff(g_blink_timer > 15, color_status_dark_green, color_grey_dark), color_status_dark_red))
                                if not is_valid then
                                    local prog = get_island_turret_progress(island, j)
                                    if prog > 0 and prog < 1 then
                                        color = color_status_dark_yellow
                                        if g_blink_timer > 15 then
                                            color = color_status_dark_red
                                        end
                                    elseif prog == 1 then
                                        color = island_color
                                    end
                                end

                                update_ui_image_rot(screen_pos_x, screen_pos_y, atlas_icons.map_icon_turret, color, 0)
                            end
                        end

                        local island_position = island:get_position_xz()
                        local island_name = get_island_name(island)
                        local screen_pos_x, screen_pos_y = get_screen_from_world(island_position:x(), island_position:y() + 3000.0, g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                        update_ui_text(screen_pos_x - 64, screen_pos_y - 9, island_name, 128, 1, island_color, 0)

                        if island:get_team_control() == screen_team then
                            if is_placing_turret == false then
                                local production_count = island:get_facility_production_queue_defense_count()

                                for j = 0, production_count - 1, 1 do
                                    local item_type, marker_index = island:get_facility_production_queue_defense_item(j)
                                    local turret_spawn_xz = island:get_marker_position(marker_index)
                                    local screen_pos_x, screen_pos_y = get_screen_from_world(turret_spawn_xz:x(), turret_spawn_xz:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                                    local team_color = get_vehicle_team_color(screen_team)
                                    local color = iff(j == 0, iff(g_blink_timer > 15, team_color, color_grey_dark), color_grey_dark)

                                    if g_highlighted.island_id == island_id and g_highlighted.production_index == j then
                                        color = color_white
                                    end

                                    update_ui_image_rot(screen_pos_x, screen_pos_y, atlas_icons.map_icon_turret, color, 0)

                                    if j == 0 then
                                        local production_progress = island:get_facility_production_factor_defense()
                                        update_ui_rectangle(screen_pos_x - 6, screen_pos_y + 5, 11, 3, color8(0, 0, 0, 255))
                                        update_ui_rectangle(screen_pos_x - 5, screen_pos_y + 6, math.max(9 * production_progress, 1), 1, color_status_ok)
                                    end
                                end
                            end
                        else
                            if not g_revolution_hide_island_difficulty then
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
            end
        end

        -- render grid

        if g_map_render_mode == 1 then
            if g_render_fog_debug then
                rev_render_simple_fog(g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
            end
        end

        if g_is_render_grid and g_map_render_mode == 1 then
            local function floor_to(x, y)
                return math_floor(x / y) * y
            end

            local screen_min_x, screen_min_y = get_world_from_screen(0, 0, g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
            local screen_max_x, screen_max_y = get_world_from_screen(screen_w, screen_h, g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

            local grid_spacing = get_grid_spacing(g_camera_size)
            local grid_min_x = floor_to(screen_min_x, grid_spacing)
            local grid_min_y = floor_to(screen_min_y, grid_spacing)
            local grid_max_x = floor_to(screen_max_x, grid_spacing) + grid_spacing
            local grid_max_y = floor_to(screen_max_y, grid_spacing) + grid_spacing
            local grid_col_maj = color8(0, 255, 255, 5)
            local grid_col_min = color8(0, 255, 255, 1)

            for x = grid_min_x, grid_max_x, grid_spacing do
                local line_x = get_screen_from_world(x, 0, g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                update_ui_rectangle(line_x, 0, 1, screen_h, grid_col_maj)

                line_x = get_screen_from_world(x + grid_spacing / 2, 0, g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                update_ui_rectangle(line_x, 0, 1, screen_h, grid_col_min)
            end

            for y = grid_min_y, grid_max_y, -grid_spacing do
                local _, line_y = get_screen_from_world(0, y, g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                update_ui_rectangle(0, line_y, screen_w, 1, grid_col_maj)

                _, line_y = get_screen_from_world(0, y + grid_spacing / 2, g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                update_ui_rectangle(0, line_y, screen_w, 1, grid_col_min)
            end
        end

        -- render markers
        local function render_marker(marker_id)
            local value = get_marker_value(screen_team, marker_id)
            if is_waypoint_value_enabled(value) then
                local wx, wy = unpack_alt_xy(value)
                local sx, sy = get_screen_from_world(wx, wy, g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                local col = color8(0xff, 0xff, 0x00, 0x03)
                update_ui_circle(sx, sy, 10, 12, col)
                col = color8(0xff, 0xff, 0x00, 0x32)
                update_ui_text(sx + 5, sy + 5, get_marker_name(marker_id), 16, 0, col, 0)

            end
        end

        render_marker(1)
        render_marker(2)
        render_marker(3)
        render_marker(4)

        -- render weapon radius

        local function render_weapon_radius(world_pos_x, world_pos_y, radius, col)
            local steps = 16
            local step = math.pi * 2 / steps
            local angle_prev = 0
            local screen_pos_x, screen_pos_y = get_screen_from_world(world_pos_x, world_pos_y, g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

            update_ui_begin_triangles()

            for i = 1, steps do
                local angle = step * i
                local x0, y0 = get_screen_from_world(world_pos_x + math.cos(angle_prev) * radius, world_pos_y + math.sin(angle_prev) * radius, g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                local x1, y1 = get_screen_from_world(world_pos_x + math.cos(angle) * radius, world_pos_y + math.sin(angle) * radius, g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                update_ui_line(x0, y0, x1, y1, col)

                local fill_col = color8(col:r(), col:g(), col:b(), math.floor(col:a() / 2 * (math.sin(g_animation_time * 0.15) * 0.5 + 0.5)))
                update_ui_add_triangle(vec2(x0, y0), vec2(x1, y1), vec2(screen_pos_x, screen_pos_y), fill_col)

                angle_prev = angle
            end

            update_ui_end_triangles()
        end

        if g_drag.vehicle_id > 0 then
            local weapon_radius_vehicle = update_get_map_vehicle_by_id(g_drag.vehicle_id)

            if weapon_radius_vehicle:get() then
                if weapon_radius_vehicle:get_team() == screen_team or get_is_spectator_mode() then
                    local weapon_range, weapon_range_col = get_vehicle_weapon_range(weapon_radius_vehicle)
                    local world_x, world_y = get_world_from_screen(g_cursor_pos_x, g_cursor_pos_y, g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                    if weapon_range > 0 then
                        render_weapon_radius(world_x, world_y, weapon_range, weapon_range_col)
                    end

                    local def = weapon_radius_vehicle:get_definition_index()

                    if def == e_game_object_type.chassis_sea_ship_light or def == e_game_object_type.chassis_sea_ship_heavy then

                        for x, vehicle in pairs(get_vehicles_table()) do
                            if vehicle:get_definition_index() == e_game_object_type.chassis_carrier and vehicle:get_team() == screen_team then
                                local vehicle_pos_xz = vehicle:get_position_xz()

                                render_weapon_radius(vehicle_pos_xz:x(), vehicle_pos_xz:y(), 500, color8(0, 255, 128, 8))
                            end
                        end
                    end
                end
            end
        elseif g_highlighted.vehicle_id > 0 and g_highlighted.waypoint_id == 0 then
            local weapon_radius_vehicle = update_get_map_vehicle_by_id(g_highlighted.vehicle_id)

            if weapon_radius_vehicle:get() then
                local def = weapon_radius_vehicle:get_definition_index()

                -- render needlefish radar circles if it has been scanned or is friendly
                if weapon_radius_vehicle:get_team() == screen_team or weapon_radius_vehicle:get_is_observation_weapon_revealed() then
                    local radar_type = get_vehicle_radar(weapon_radius_vehicle)
                    local radar_radius = get_modded_radar_range(weapon_radius_vehicle)
                    if radar_type ~= nil then
                        if radar_radius < 1 then
                            -- not modded, but might still have a radar enabled
                            if radar_type == e_game_object_type.attachment_radar_awacs then
                                if get_awacs_radar_enabled(weapon_radius_vehicle) then
                                    radar_radius = 10000
                                end
                            elseif radar_type == e_game_object_type.attachment_radar_golfball then
                                radar_radius = 10000
                            end
                        end
                    end

                    if radar_radius > 0 then
                        local vehicle_pos_xz = weapon_radius_vehicle:get_position_xz()
                        render_weapon_radius(vehicle_pos_xz:x(), vehicle_pos_xz:y(), radar_radius, color8(8, 8, 48, 64))
                    end
                end


                if def ~= e_game_object_type.chassis_carrier then
                    if weapon_radius_vehicle:get_team() == screen_team or weapon_radius_vehicle:get_is_observation_weapon_revealed() then
                        local weapon_range, weapon_range_col = get_vehicle_weapon_range(weapon_radius_vehicle)
                        if weapon_range > 0 then
                            local vehicle_pos_xz = weapon_radius_vehicle:get_position_xz()
                            render_weapon_radius(vehicle_pos_xz:x(), vehicle_pos_xz:y(), weapon_range, weapon_range_col)
                        end
                    end

                    if weapon_radius_vehicle:get_team() == screen_team then
                        if def == e_game_object_type.chassis_sea_ship_light or def == e_game_object_type.chassis_sea_ship_heavy then
                            for x, vehicle in pairs(get_vehicles_table()) do
                                if vehicle:get_definition_index() == e_game_object_type.chassis_carrier and vehicle:get_team() == screen_team then
                                    local vehicle_pos_xz = vehicle:get_position_xz()

                                    render_weapon_radius(vehicle_pos_xz:x(), vehicle_pos_xz:y(), 500, color8(0, 255, 128, 8))
                                end
                            end
                        end
                    end
                end
            end
        end

        -- render destroyed vehicles to the map

        if is_placing_turret == false then
            local destroyed_vehicle_count = update_get_map_destroyed_vehicle_count()

            for i = 0, destroyed_vehicle_count - 1, 1 do
                local destroyed_vehicle = update_get_map_destroyed_vehicle(i)

                if destroyed_vehicle:get() then
                    local destroyed_vehicle_position = destroyed_vehicle:get_position_xz(i)
                    local destroyed_vehicle_team_id = destroyed_vehicle:get_team(i)
                    local destroyed_vehicle_factor = destroyed_vehicle:get_factor(i)

                    screen_pos_x, screen_pos_y = get_screen_from_world(destroyed_vehicle_position:x(), destroyed_vehicle_position:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                    update_ui_image(screen_pos_x - 4, screen_pos_y - 4, atlas_icons.map_icon_waypoint, color_status_dark_red, 0)
                end
            end
        end

        -- render weapon firing lines

        if is_placing_turret == false then
            if g_camera_size < 1024 * 16 then
                local weapon_line_count = update_get_weapon_line_count()

                for i = 0, weapon_line_count - 1 do
                    local vehicle_id, direction_xz, tick = update_get_weapon_line_by_index(i)
                    local life = 6
                    local factor = 1 - clamp(tick / life, 0, 1)

                    if factor > 0 then
                        if vehicle_id ~= 0 then
                            local vehicle = update_get_map_vehicle_by_id(vehicle_id)

                            if vehicle:get() then
                                if (vehicle:get_is_visible() and vehicle:get_is_observation_revealed()) or get_is_spectator_mode() then
                                    local position_xz = vehicle:get_position_xz()
                                    local length = 0.04 * g_camera_size

                                    local s0x, s0y = get_screen_from_world(position_xz:x(), position_xz:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                                    local s1x, s1y = get_screen_from_world(position_xz:x() + direction_xz:x() * length, position_xz:y() + direction_xz:y() * length, g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                                    update_ui_line(s0x, s0y, s1x, s1y, color8(255, 255, 0, math.floor(factor * 255)))
                                end
                            end
                        end
                    end
                end
            end
        end

        -- render bomb blasts to the map
        local blast_size = math.floor(160/ (g_camera_size / 40))
        if blast_size > 1 then
            for mid, blast in pairs(g_missile_impacts) do
                if blast["visible"] then
                    local x = blast["x"]
                    local z = blast["z"]
                    local age = update_get_logic_tick() - blast["tick"]
                    local screen_pos_x, screen_pos_y = get_screen_from_world(x, z, g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                    draw_explosion(screen_pos_x, screen_pos_y, age, blast_size)
                end
            end
        end

        -- render gunfire in spec mode

        if is_placing_turret == false and get_is_spectator_mode() then
            local projectile_count = update_get_projectile_count()
            for i = 0, projectile_count - 1, 1 do
                local p = update_get_projectile_by_index(i)
                if p then
                    local screen_pos_x, screen_pos_y = get_screen_from_world(p:x(), p:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                    if screen_pos_x > 0 and screen_pos_x < g_screen_w then
                        if screen_pos_y > 0 and screen_pos_y < g_screen_h then
                            update_ui_line(screen_pos_x, screen_pos_y, screen_pos_x + 1, screen_pos_y + 1, color8(255, 255, 0, 128))
                        end
                    end
                end
            end
        end

        -- render vehicles to the map

        if is_placing_turret == false then
            for x, vehicle in pairs(get_vehicles_table()) do
                local vehicle_team = vehicle:get_team()
                local vehicle_attached_parent_id = vehicle:get_attached_parent_id()
                local vehicle_definition_index = vehicle:get_definition_index()
                local is_render_vehicle_icon = vehicle_attached_parent_id == 0
                local is_docked = vehicle_attached_parent_id ~= 0

                if g_camera_size < 600 then
                    if get_is_vehicle_air(vehicle_definition_index) or get_is_vehicle_land(vehicle_definition_index) then
                        is_render_vehicle_icon = true
                    end
                end

                if vehicle_definition_index == e_game_object_type.drydock then
                    -- draw the drydock as grey
                    local vehicle_pos_xz = vehicle:get_position_xz()
                    local v_x = vehicle_pos_xz:x()
                    local v_y = vehicle_pos_xz:y()
                    local v_nx = v_x + 90
                    local v_ny = v_y + 160
                    local v_sx = v_x - 130
                    local v_sy = v_y - 280

                    update_world_triangle(
                            v_nx, v_ny,
                            v_nx + 30, v_ny - 15,
                            v_sx, v_sy,
                            color_grey_dark
                    )
                    update_world_triangle(
                            v_sx + 30, v_sy - 15,
                            v_nx + 30, v_ny - 15,
                            v_sx, v_sy,
                            color_grey_dark
                    )

                elseif vehicle_definition_index ~= e_game_object_type.chassis_spaceship then
                    local is_air = get_is_vehicle_air(vehicle_definition_index)
                    local is_visible = vehicle:get_is_visible()
                    local is_revealed = vehicle:get_is_observation_revealed()
                    if is_render_vehicle_icon then
                        if is_visible and not is_revealed then
                            if get_is_visible_by_modded_radar(vehicle) then
                                is_revealed = true
                            end
                        end
                        is_render_vehicle_icon = is_visible and is_revealed
                    end
                    if not is_render_vehicle_icon then
                        is_render_vehicle_icon = get_is_spectator_mode()
                    end

                    local is_render_vehicle_wpts = is_render_vehicle_icon

                    if is_render_vehicle_icon then
                        if is_air and not get_is_spectator_mode() then
                            -- hide low level aircraft
                            if is_render_vehicle_icon and get_is_vehicle_masked(vehicle) then
                                if vehicle:get_team() ~= update_get_screen_team_id() then
                                    is_visible = false
                                    is_revealed = false
                                    is_render_vehicle_icon = false
                                    if g_radar_debug then
                                        local_print(string.format("%d hide visible radar unit", current_tick))
                                    end
                                    if g_highlighted.vehicle_id == vehicle:get_id() then
                                        g_highlighted.vehicle_id = 0
                                    end
                                end
                            end
                        end
                    end

                    if not is_render_vehicle_wpts then

                        if vehicle_definition_index ~= e_game_object_type.drydock and vehicle_definition_index ~= e_game_object_type.chassis_carrier then
                            if vehicle:get_team() == screen_team then
                                is_render_vehicle_wpts = vehicle:get_waypoint_count() > 0
                            end
                        end
                    end

                    if is_render_vehicle_wpts then
                        local vehicle_pos_xz = vehicle:get_position_xz()
                        local v_x = vehicle_pos_xz:x()
                        local v_y = vehicle_pos_xz:y()
                        local screen_pos_x, screen_pos_y = get_screen_from_world(v_x, v_y, g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                        local in_screen = false
                        if screen_pos_x > 0 and screen_pos_x < screen_w then
                            if screen_pos_y > 0 and screen_pos_y < screen_h then
                                in_screen = true
                            end
                        end

                        -- render waypoints

                        local vehicle_support_id = vehicle:get_supporting_vehicle_id()

                        local waypoint_count = vehicle:get_waypoint_count()

                        local waypoint_pos_x_prev = screen_pos_x
                        local waypoint_pos_y_prev = screen_pos_y

                        local show_waypoints = true
                        local waypoint_color = g_color_waypoint
                        if vehicle:get_definition_index() == e_game_object_type.chassis_sea_barge then
                            waypoint_color = g_color_waypoint_dark
                        elseif vehicle:get_definition_index() == e_game_object_type.chassis_carrier then
                            show_waypoints = g_is_carrier_waypoint
                        elseif vehicle:get_definition_index() == e_game_object_type.chassis_land_turret then
                            show_waypoints = false
                        end

                        if (vehicle_team == screen_team or get_is_spectator_mode()) and show_waypoints then

                            if g_highlighted.vehicle_id == vehicle:get_id() and g_highlighted.waypoint_id == 0 then
                                waypoint_color = color8(255, 255, 255, 255)
                            end

                            local vehicle_dock_state = vehicle:get_dock_state()
                            local vehicle_dock_queue_id = vehicle:get_dock_queue_vehicle_id()
                            local dock_state_queue = 5
                            local dock_state_docking = 1

                            if (vehicle_dock_state == dock_state_queue or vehicle_dock_state == dock_state_docking) and vehicle_dock_queue_id ~= 0 and is_render_vehicle_icon then
                                local parent_vehicle = update_get_map_vehicle_by_id(vehicle_dock_queue_id)

                                if parent_vehicle:get() then
                                    local parent_pos_xz = parent_vehicle:get_position_xz()
                                    local parent_screen_pos_x, parent_screen_pos_y = get_screen_from_world(parent_pos_xz:x(), parent_pos_xz:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                                    render_dashed_line(screen_pos_x, screen_pos_y, parent_screen_pos_x, parent_screen_pos_y, waypoint_color)
                                end
                            end
                            local function render_resupply_link(vehicle_from, vehicle_to, is_resupplying)
                                local from_xz = vehicle_from:get_position_xz()
                                local from_screen_pos_x, from_screen_pos_y = get_screen_from_world(from_xz:x(), from_xz:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                                local to_xz = vehicle_to:get_position_xz()
                                local to_screen_pos_x, to_screen_pos_y = get_screen_from_world(to_xz:x(), to_xz:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                                local color = color8(g_color_resupply:r(), g_color_resupply:g(), g_color_resupply:b(), g_color_resupply:a())

                                if is_resupplying == false then
                                    color:a(color:a() / 4)
                                end

                                render_dashed_line(from_screen_pos_x, from_screen_pos_y, to_screen_pos_x, to_screen_pos_y, color)

                                if get_grid_spacing() < 2000 and g_animation_time % 20 > 10 and is_resupplying then
                                    update_ui_image((screen_pos_x + to_screen_pos_x) / 2 - 3, (screen_pos_y + to_screen_pos_y) / 2 - 4, atlas_icons.column_stock, color, 0)
                                end
                            end
                            local vehicle_resupply_id = vehicle:get_resupply_vehicle_id()

                            if vehicle_resupply_id ~= 0 then
                                local resupply_vehicle = update_get_map_vehicle_by_id(vehicle_resupply_id)

                                if resupply_vehicle:get() then
                                    local fuel_factor = vehicle:get_fuel_factor()
                                    local ammo_factor = vehicle:get_ammo_factor()
                                    local is_resupplying = math.floor(fuel_factor * 100 + 0.5) < 100 or math.floor(ammo_factor * 100 + 0.5) < 100

                                    render_resupply_link(resupply_vehicle, vehicle, is_resupplying)
                                end
                            end

                            local vehicle_resupplying_id_count = vehicle:get_resupplying_vehicle_id_count()

                            for j = 0, vehicle_resupplying_id_count - 1, 1 do
                                vehicle_resupply_id = vehicle:get_resupplying_vehicle_id(j)

                                if vehicle_resupply_id ~= 0 then
                                    local resupply_vehicle = update_get_map_vehicle_by_id(vehicle_resupply_id)

                                    if resupply_vehicle:get() then
                                        local is_logistics_ammo, is_logistics_fuel = get_vehicle_logistics_capabilities(vehicle)
                                        local fuel_factor = resupply_vehicle:get_fuel_factor()
                                        local ammo_factor = resupply_vehicle:get_ammo_factor()
                                        local is_resupplying = (is_logistics_ammo and math.floor(fuel_factor * 100 + 0.5) < 100) or (is_logistics_fuel and math.floor(ammo_factor * 100 + 0.5) < 100)

                                        render_resupply_link(vehicle, resupply_vehicle, is_resupplying)
                                    end
                                end
                            end

                            if vehicle_support_id ~= 0 then
                                local parent_vehicle = update_get_map_vehicle_by_id(vehicle_support_id)

                                if parent_vehicle:get() then
                                    local parent_pos_xz = parent_vehicle:get_position_xz()
                                    local parent_screen_pos_x, parent_screen_pos_y = get_screen_from_world(parent_pos_xz:x(), parent_pos_xz:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                                    render_dashed_line(screen_pos_x, screen_pos_y, parent_screen_pos_x, parent_screen_pos_y, waypoint_color)
                                end
                            else
                                local waypoint_path = vehicle:get_waypoint_path()
                                local waypoint_start_index = 0
                                if #waypoint_path > 0 then
                                    waypoint_start_index = 1

                                    for i = 1, #waypoint_path do
                                        local waypoint_screen_pos_x, waypoint_screen_pos_y = get_screen_from_world(waypoint_path[i]:x(), waypoint_path[i]:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                                        update_ui_line(waypoint_pos_x_prev, waypoint_pos_y_prev, waypoint_screen_pos_x, waypoint_screen_pos_y, waypoint_color)

                                        update_ui_rectangle(waypoint_screen_pos_x - 1, waypoint_screen_pos_y - 1, 2, 2, waypoint_color)

                                        waypoint_pos_x_prev = waypoint_screen_pos_x
                                        waypoint_pos_y_prev = waypoint_screen_pos_y
                                    end

                                    if waypoint_count > 0 then
                                        local waypoint = vehicle:get_waypoint(0)
                                        local waypoint_pos = waypoint:get_position_xz()
                                        local path_end_x, path_end_y = get_screen_from_world(waypoint_pos:x(), waypoint_pos:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                                        update_ui_line(waypoint_pos_x_prev, waypoint_pos_y_prev, path_end_x, path_end_y, waypoint_color)
                                    end
                                end

                                waypoint_pos_x_prev = screen_pos_x
                                waypoint_pos_y_prev = screen_pos_y

                                if is_render_vehicle_icon == false then
                                    if vehicle_attached_parent_id ~= 0 then
                                        local parent_vehicle = update_get_map_vehicle_by_id(vehicle_attached_parent_id)

                                        if parent_vehicle:get() then
                                            local parent_vehicle_pos_xz = parent_vehicle:get_position_xz()
                                            waypoint_pos_x_prev, waypoint_pos_y_prev = get_screen_from_world(parent_vehicle_pos_xz:x(), parent_vehicle_pos_xz:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                                        end
                                    end
                                end

                                for j = 0, waypoint_count - 1, 1 do
                                    local waypoint = vehicle:get_waypoint(j)
                                    local waypoint_pos = waypoint:get_position_xz()
                                    local waypoint_screen_pos_x, waypoint_screen_pos_y = get_screen_from_world(waypoint_pos:x(), waypoint_pos:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                                    if j >= waypoint_start_index then
                                        update_ui_line(waypoint_pos_x_prev, waypoint_pos_y_prev, waypoint_screen_pos_x, waypoint_screen_pos_y, waypoint_color)
                                    end

                                    waypoint_pos_x_prev = waypoint_screen_pos_x
                                    waypoint_pos_y_prev = waypoint_screen_pos_y

                                    local waypoint_repeat_index = waypoint:get_repeat_index()

                                    if waypoint_repeat_index >= 0 then
                                        local waypoint_repeat = vehicle:get_waypoint(waypoint_repeat_index)
                                        local waypoint_repeat_pos = waypoint_repeat:get_position_xz()

                                        local repeat_screen_pos_x, repeat_screen_pos_y = get_screen_from_world(waypoint_repeat_pos:x(), waypoint_repeat_pos:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                                        update_ui_line(waypoint_screen_pos_x, waypoint_screen_pos_y, repeat_screen_pos_x, repeat_screen_pos_y, waypoint_color)
                                        update_ui_image((waypoint_screen_pos_x + repeat_screen_pos_x) / 2 - 4, (waypoint_screen_pos_y + repeat_screen_pos_y) / 2 - 4, atlas_icons.map_icon_loop, waypoint_color, 0)
                                    end

                                    local attack_target_count = waypoint:get_attack_target_count()

                                    for k = 0, attack_target_count - 1, 1 do
                                        local is_valid = waypoint:get_attack_target_is_valid(k)

                                        if is_valid then
                                            -- validate that the attack target is visible on the map
                                            -- if not, remove the waypoint order so it can't be used
                                            -- track units beyond radar/visible range
                                            local target_id = waypoint:get_attack_target_target_id(k)
                                            local target_unit = update_get_map_vehicle_by_id(target_id)
                                            if target_unit:get() then
                                                if not target_unit:get_is_visible() then
                                                    vehicle:remove_waypoint_attack_target(waypoint:get_id(), k)
                                                    is_valid = false
                                                end
                                            end
                                        end

                                        if is_valid then
                                            local attack_target_pos = waypoint:get_attack_target_position_xz(k)
                                            local attack_target_attack_type = waypoint:get_attack_target_attack_type(k)
                                            local attack_target_icon = get_attack_type_icon(attack_target_attack_type)

                                            local attack_target_screen_pos_x, attack_target_screen_pos_y = get_screen_from_world(attack_target_pos:x(), attack_target_pos:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                                            local color = g_color_attack_order

                                            if attack_target_attack_type == e_attack_type.airlift then
                                                color = g_color_airlift_order
                                            end

                                            update_ui_line(waypoint_screen_pos_x, waypoint_screen_pos_y, attack_target_screen_pos_x, attack_target_screen_pos_y, color)
                                            update_ui_image(attack_target_screen_pos_x - 8, attack_target_screen_pos_y - 8, atlas_icons.map_icon_attack, color, 0)
                                            update_ui_image(attack_target_screen_pos_x - 4, attack_target_screen_pos_y - 4 - 8, attack_target_icon, color, 0)
                                        end
                                    end
                                end

                                for j = 0, waypoint_count - 1, 1 do
                                    local waypoint = vehicle:get_waypoint(j)
                                    local waypoint_pos = waypoint:get_position_xz()

                                    local waypoint_screen_pos_x, waypoint_screen_pos_y = get_screen_from_world(waypoint_pos:x(), waypoint_pos:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                                    local waypoint_color = g_color_waypoint

                                    local is_group_a = waypoint:get_is_wait_group(0)
                                    local is_group_b = waypoint:get_is_wait_group(1)
                                    local is_group_c = waypoint:get_is_wait_group(2)
                                    local is_group_d = waypoint:get_is_wait_group(3)

                                    local group_text = ""

                                    if is_group_a then group_text = group_text..update_get_loc(e_loc.upp_acronym_alpha) end
                                    if is_group_b then group_text = group_text..update_get_loc(e_loc.upp_acronym_beta) end
                                    if is_group_c then group_text = group_text..update_get_loc(e_loc.upp_acronym_charlie) end
                                    if is_group_d then group_text = group_text..update_get_loc(e_loc.upp_acronym_delta) end

                                    local is_group = (is_group_a or is_group_b or is_group_c or is_group_d)
                                    local is_deploy = waypoint:get_type() == e_waypoint_type.deploy

                                    local alt = 400
                                    if is_air then
                                        alt = waypoint:get_altitude()
                                    end

                                    if g_highlighted.vehicle_id == vehicle:get_id() and g_highlighted.waypoint_id == 0 then
                                        waypoint_color = color8(255, 255, 255, 255)
                                    elseif g_highlighted.vehicle_id == vehicle:get_id() and g_highlighted.waypoint_id == waypoint:get_id() then
                                        waypoint_color = color8(255, 255, 255, 255)
                                    elseif is_deploy then
                                        waypoint_color = g_color_airlift_order
                                    elseif is_group then
                                        waypoint_color = g_color_attack_order
                                        if is_air and alt < 15 then
                                            waypoint_color = color_status_dark_green
                                        end
                                    elseif is_air and alt < 50 then
                                        waypoint_color = color_status_dark_yellow
                                    end

                                    update_ui_image(waypoint_screen_pos_x - 4, waypoint_screen_pos_y - 4, atlas_icons.map_icon_waypoint, waypoint_color, 0)

                                    if is_deploy then
                                        update_ui_image(waypoint_screen_pos_x - 4, waypoint_screen_pos_y - 11, atlas_icons.icon_deploy_vehicle, waypoint_color, 0)
                                    elseif is_group then
                                        update_ui_text(waypoint_screen_pos_x - 64, waypoint_screen_pos_y - 13, group_text, 128, 1, waypoint_color, 0)
                                    end
                                end
                            end

                            local attack_target_type = vehicle:get_attack_target_type()

                            if attack_target_type ~= e_attack_type.none then
                                local attack_target_pos = vehicle:get_attack_target_position_xz()
                                local attack_target_attack_type = vehicle:get_attack_target_type()
                                local attack_target_icon = get_attack_type_icon(attack_target_attack_type)

                                local attack_target_screen_pos_x, attack_target_screen_pos_y = get_screen_from_world(attack_target_pos:x(), attack_target_pos:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                                local color = g_color_attack_order

                                if attack_target_attack_type == e_attack_type.airlift then
                                    color = g_color_airlift_order
                                end

                                render_dashed_line(screen_pos_x, screen_pos_y, attack_target_screen_pos_x, attack_target_screen_pos_y, color)
                                update_ui_image(attack_target_screen_pos_x - 4, attack_target_screen_pos_y - 4, atlas_icons.map_icon_waypoint, color, 0)
                                update_ui_image(attack_target_screen_pos_x - 4, attack_target_screen_pos_y - 4 - 8, attack_target_icon, color, 0)
                                update_ui_text(attack_target_screen_pos_x - 4, attack_target_screen_pos_y - 4 - 8, attack_target_attack_type, 128, 0, color_black, 0)
                            end
                        end

                        if is_render_vehicle_icon and in_screen then
                            -- render vehicle icon
                            local region_vehicle_icon, icon_offset = get_icon_data_by_definition_index(vehicle_definition_index)
                            local element_color = get_vehicle_team_color(vehicle_team)

                            if is_docked then
                                element_color = color8(element_color:r(), element_color:g(), element_color:b(), 18)
                            end

                            local is_highlight = false

                            if is_air then
                                if g_is_show_aircraft_shadows and g_camera_size < 20000 then
                                    -- draw aircraft shadow
                                    local alt = get_unit_altitude(vehicle)
                                    local shadow_scale = (5000 / g_camera_size) * (alt / 2000)
                                    local dy = 12 * shadow_scale
                                    local dx = 4 * shadow_scale
                                    local sdx = screen_pos_x + dx
                                    local sdy = screen_pos_y + dy
                                    update_ui_begin_triangles()
                                    update_ui_add_triangle(
                                            vec2(sdx, sdy),
                                            vec2(sdx - 4, sdy + 5),
                                            vec2(sdx + 4, sdy + 5),
                                            color_shadow
                                            )
                                    update_ui_end_triangles()
                                end
                                if g_is_show_aircraft_vectors then
                                    draw_aircraft_vector(vehicle, screen_pos_x, screen_pos_y)
                                end
                            end

                            if g_selection.vehicle_id == vehicle:get_id() then
                                element_color = color8(255, 255, 255, 255)
                                is_highlight = true
                            elseif g_drag.vehicle_id == vehicle:get_id() then
                                element_color = color8(255, 255, 255, 255)
                                is_highlight = true
                            elseif g_highlighted.vehicle_id == vehicle:get_id() then
                                element_color = color8(255, 255, 255, 255)
                                is_highlight = true
                            end

                            if get_vehicle_has_robot_dogs(vehicle) and g_animation_time % 20 < 10 then
                                region_vehicle_icon = atlas_icons.map_icon_surface_capture
                            end

                            update_ui_image(screen_pos_x - icon_offset, screen_pos_y - icon_offset, region_vehicle_icon, element_color, 0)
                            displayed_unit_count = displayed_unit_count + 1

                            -- carrier direction indicator
                            if vehicle_definition_index == e_game_object_type.chassis_carrier then
                                update_ui_image(screen_pos_x - 5, screen_pos_y - 5, atlas_icons.map_icon_circle_9, color_white, 0)

                                local vehicle_dir = vehicle:get_direction()
                                update_ui_line(screen_pos_x, screen_pos_y, screen_pos_x + (vehicle_dir:x() * 15), screen_pos_y + (vehicle_dir:y() * -15), color_white)

                                -- draw ship outline
                                if g_camera_size < 1000 then
                                    -- ship is 200m long, 60m wide
                                    local pix_per_m = screen_w / g_camera_size
                                    local crr_half_len = 100 * pix_per_m
                                    local outline_col = color8(16, 16, 16, 32)
                                    local crr_ber = (math.atan(vehicle_dir:y(), vehicle_dir:x()) / math.pi * 180) + 90
                                    local fl = (crr_ber - 20) * (math.pi / 180)
                                    local fr = (crr_ber + 20) * (math.pi / 180)

                                    local fl_x = math.sin(fl) * crr_half_len;
                                    local fl_y = math.cos(fl) * crr_half_len;
                                    local fr_x = math.sin(fr) * crr_half_len
                                    local fr_y = math.cos(fr) * crr_half_len

                                    update_ui_line(
                                            screen_pos_x - fr_x,
                                            screen_pos_y - fr_y,
                                            screen_pos_x - fl_x,
                                            screen_pos_y - fl_y,
                                            outline_col
                                    )
                                    update_ui_line(
                                            screen_pos_x - fr_x,
                                            screen_pos_y - fr_y,
                                            screen_pos_x + fl_x,
                                            screen_pos_y + fl_y,
                                            outline_col
                                    )
                                    update_ui_line(
                                            screen_pos_x + fr_x,
                                            screen_pos_y + fr_y,
                                            screen_pos_x + fl_x,
                                            screen_pos_y + fl_y,
                                            outline_col
                                    )
                                    update_ui_line(
                                            screen_pos_x + fr_x,
                                            screen_pos_y + fr_y,
                                            screen_pos_x - fl_x,
                                            screen_pos_y - fl_y,
                                            outline_col
                                    )
                                end
                            end
                            local radar_state = draw_map_radar_state_indicator(vehicle, screen_pos_x, screen_pos_y, g_animation_time)
                            if radar_state == "on" and update_get_is_focus_local() then
                                if g_highlighted.vehicle_id == vehicle:get_id() then
                                    iter_radars(function(radar)
                                        local radar_team = radar:get_team()
                                        if radar_team ~= screen_team and get_vehicle_radar_state(radar) == "on" then
                                            rev_render_radar_spokes(vehicle, radar, g_screen_w, g_screen_h, control_screen_from_world)
                                        end
                                    end)
                                end
                            end

                            local damage_indicator_factor = vehicle:get_damage_indicator_factor()
                            local damage_factor = clamp(vehicle:get_hitpoints() / vehicle:get_total_hitpoints(), 0, 1)
                            local fuel_factor = vehicle:get_fuel_factor()
                            local ammo_factor = vehicle:get_ammo_factor()

                            if damage_indicator_factor > 0 then
                                update_ui_image(screen_pos_x - 4, screen_pos_y - 4, atlas_icons.map_icon_damage_indicator, color8(255, 0, 0, math.floor(255 * damage_indicator_factor)), 0)
                            end

                            local cy = screen_pos_y + 4

                            if damage_factor < 1 then
                                -- render healthbar

                                local bar_w = 8
                                local bar_x = screen_pos_x - bar_w / 2
                                local bar_y = cy

                                local bar_color = iff(damage_factor <= 0.2, color8(255, 0, 0, 255), color8(0, 255, 0, 255))
                                local back_color = color_black

                                if damage_indicator_factor > 0.8 then
                                    if g_animation_time % 4 < 2 then
                                        bar_color = color_white
                                    else
                                        bar_color = color8(255, 0, 0, 255)
                                    end
                                end

                                if is_highlight then
                                    bar_color = color_white
                                end

                                update_ui_rectangle(bar_x, bar_y, bar_w, 1, back_color)
                                update_ui_rectangle(bar_x, bar_y, math.floor(damage_factor * bar_w + 0.5), 1, bar_color)

                                cy = cy + 2
                            end

                            if (get_is_spectator_mode() or vehicle_team == screen_team) and vehicle_definition_index ~= e_game_object_type.chassis_land_robot_dog then
                                cx = screen_pos_x - 4

                                local is_visible_by_enemy = vehicle:get_is_visible_by_enemy()
                                if not is_visible_by_enemy then
                                    if get_is_vehicle_air(vehicle_definition_index) then
                                        is_visible_by_enemy = get_is_visible_by_hostile_modded_radar(vehicle)
                                    end
                                end

                                if is_visible_by_enemy and g_animation_time % 20 > 10 then
                                    local icon_color =  color_enemy

                                    if is_highlight then
                                        icon_color = color_white
                                    end

                                    update_ui_image(screen_pos_x + 3, screen_pos_y - 2, atlas_icons.map_icon_visible, icon_color, 0)
                                end

                                if fuel_factor < 0.5 and get_is_render_fuel_indicator(vehicle) then
                                    local icon_color = iff(fuel_factor < 0.25, color8(255, 0, 0, 255), color8(255, 255, 0, 255))

                                    if vehicle:get_resupply_vehicle_id() ~= 0 and g_animation_time % 20 > 10 then
                                        icon_color = g_color_resupply
                                    end

                                    if is_highlight then
                                        icon_color = color_white
                                    end

                                    update_ui_image(cx, cy, atlas_icons.map_icon_low_fuel, icon_color, 0)
                                    cx = cx + 4
                                end

                                if ammo_factor < 0.5 and get_is_render_ammo_indicator(vehicle) then
                                    local icon_color = iff(ammo_factor < 0.25, color8(255, 0, 0, 255), color8(255, 255, 0, 255))

                                    if is_highlight then
                                        icon_color = color_white
                                    end

                                    update_ui_image(cx, cy, atlas_icons.map_icon_low_ammo, icon_color, 0)
                                    cx = cx + 4
                                end

                                if vehicle:get_is_hold_fire() == true then
                                    update_ui_image(cx, cy, atlas_icons.map_icon_hold_fire, color8(255, 0, 0, 255), 0)
                                    cx = cx + 4
                                end
                            end

                            if vehicle_team == screen_team then
                                if vehicle:get_controlling_peer_id() ~= 0 then
                                    update_ui_image(screen_pos_x - icon_offset, screen_pos_y - icon_offset, atlas_icons.map_icon_vehicle_control, element_color, 0)
                                end
                            end
                        elseif g_selected_child_vehicle_id == vehicle:get_id() then
                            -- render as selected child vehicle

                            local parent_vehicle = update_get_map_vehicle_by_id(vehicle_attached_parent_id)

                            g_tut_undocking_vehicle_id = vehicle:get_id()

                            if parent_vehicle:get() then
                                local parent_vehicle_pos_xz = parent_vehicle:get_position_xz()
                                local vvehicle_definition_index = vehicle:get_definition_index(i)

                                local sscreen_pos_x, sscreen_pos_y = get_screen_from_world(parent_vehicle_pos_xz:x(), parent_vehicle_pos_xz:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                                local region_vehicle_icon, icon_offset = get_icon_data_by_definition_index(vvehicle_definition_index)

                                update_ui_rectangle(sscreen_pos_x - icon_offset - 1, sscreen_pos_y - icon_offset - 14 - 1, 10, 10, color_black)
                                update_ui_image(sscreen_pos_x - icon_offset, sscreen_pos_y - icon_offset - 14, region_vehicle_icon, color_white, 0)
                            end
                        end
                    elseif is_revealed then
                        local last_known_position_xz, is_last_known_position_set = vehicle:get_vision_last_known_position_xz()

                        if is_last_known_position_set then
                            local screen_pos_x, screen_pos_y = get_screen_from_world(last_known_position_xz:x(), last_known_position_xz:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                            if vehicle_attached_parent_id == 0 then
                                local element_color = get_vehicle_team_color(vehicle_team)

                                update_ui_image(screen_pos_x - 2, screen_pos_y - 2, atlas_icons.map_icon_last_known_pos, element_color, 0)
                            end
                        end
                    end

                    if g_radar_debug and update_get_is_focus_local() and (update_get_logic_tick() % 120 < 45) then
                        local vehicle_pos_xz = vehicle:get_position_xz()
                        local v_x = vehicle_pos_xz:x()
                        local v_y = vehicle_pos_xz:y()
                        local color = color8(0, 255, 0, 32)

                        if get_is_radar(vehicle:get_id()) then
                            color = color8(255, 255, 255, 255)
                        end

                        local screen_pos_x, screen_pos_y = get_screen_from_world(v_x, v_y, g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                        local region_vehicle_icon, icon_offset = get_icon_data_by_definition_index(vehicle_definition_index)
                        update_ui_image(screen_pos_x - icon_offset, screen_pos_y - icon_offset, region_vehicle_icon,
                                color, 0)

                        if get_is_vehicle_air(vehicle:get_definition_index()) then
                            -- draw line to nearest hostile radar that can see us
                            local vid = vehicle:get_id()
                            local nearest_hostile_radar = get_nearest_hostile_aew_radar(vid)
                            if nearest_hostile_radar ~= nil  then
                                local radar_pos = hostile_radar:get_position_xz()
                                local r_sx, r_sy = get_screen_from_world(radar_pos:x(), radar_pos:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                                update_ui_line(r_sx, r_sy, screen_pos_x, screen_pos_y, color_enemy)
                            end

                            -- draw a line from our nearest radar to the hostile it can see
                            local nearest_radar, pwr = get_nearest_friendly_aew_radar(vid)
                            if nearest_radar ~= nil and pwr > 0.00004 then
                                -- show very low power radar contacts
                                -- we only expose 0.00002+
                                local radar_pos = nearest_radar:get_position_xz()
                                local dist = vec2_dist(radar_pos, vehicle_pos_xz)
                                local r_sx, r_sy = get_screen_from_world(radar_pos:x(), radar_pos:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                                update_ui_line(r_sx, r_sy, screen_pos_x, screen_pos_y, color_friendly)

                                update_ui_text(
                                        screen_pos_x - icon_offset + 12,
                                        screen_pos_y - icon_offset + 12,
                                        string.format("ID%d r=%dm p=%1.6f", vehicle:get_id(), math.floor(dist), pwr), 128, 0, color_friendly, 0)
                            end
                        end
                    end
                end
            end
        end
        if g_radar_debug then
            local_print(
                    string.format(
                            "%d units %d, visible %d, revealed %d, force_revealed %d, displayed_units %d %s",
                            current_tick,
                            unit_count,
                            visible_unit_count,
                            revealed_unit_count,
                            force_revealed_unit_count,
                            displayed_unit_count,
                            g_radar_scanned))
        end

        -- render missiles to map

        if is_placing_turret == false then
            local missile_count = update_get_missile_count()

            for i = 0, missile_count - 1 do
                local missile = update_get_missile_by_index(i)
                local def = missile:get_definition_index()

                local position_xz = missile:get_position_xz()
                local screen_pos_x, screen_pos_y = get_screen_from_world(position_xz:x(), position_xz:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                if missile:get_is_visible() or get_is_spectator_mode() then
                    if get_missile_should_draw_trail(def) then
                        local missile_trail_count = missile:get_trail_count()
                        if missile_trail_count > 6 then
                            missile_trail_count = 6
                        end
                        local trail_prev_x = screen_pos_x
                        local trail_prev_y = screen_pos_y
                        local trail_alpha = 20
                        for missile_trail_index = 0, missile_trail_count - 1 do
                            local trail_xz = missile:get_trail_position(missile_trail_index)
                            local trail_next_x, trail_next_y = get_screen_from_world(trail_xz:x(), trail_xz:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                            update_ui_line(trail_prev_x, trail_prev_y, trail_next_x, trail_next_y, color8(255, 255, 255, trail_alpha - (missile_trail_index * 3)))
                            trail_prev_x = trail_next_x
                            trail_prev_y = trail_next_y
                        end
                    end

                    if def == e_game_object_type.missile_robot_dog_payload then
                    elseif def == e_game_object_type.torpedo or
                            def == e_game_object_type.torpedo_decoy or
                            def == e_game_object_type.torpedo_noisemaker then

                        local is_timer_running = missile:get_timer() > 0
                        local is_own_team = missile:get_team() == update_get_local_team_id()

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

                        local missile_distance_to_cursor = math.abs(screen_pos_x - g_cursor_pos_x) + math.abs(screen_pos_y - g_cursor_pos_y)

                        if is_own_team and missile_distance_to_cursor < 8 and is_timer_running then
                            update_ui_text(screen_pos_x - 16, screen_pos_y - 12, tostring(math.floor(missile:get_timer() / 30) + 1), 32, 1, color_missile, 0)
                        end
                    else
                        if g_animation_time % 20 < 10 then
                            local color_missile = color8(0, 255, 0, 255)

                            update_ui_image(screen_pos_x - 3, screen_pos_y - 3, atlas_icons.map_icon_missile, color_missile, 0)
                            update_ui_image(screen_pos_x - 3, screen_pos_y - 3, atlas_icons.map_icon_missile_outline, color_missile, 0)
                        else
                            update_ui_image(screen_pos_x - 3, screen_pos_y - 3, atlas_icons.map_icon_missile, color_white, 0)
                        end
                    end
                end
            end
        end

        local drag_start_pos = nil

        if g_selection:is_selection() then
            -- selection

            render_selection(screen_w, screen_h)

            if is_placing_turret and g_highlighted.island_id > 0 and g_highlighted.turret_spawn_index ~= -1 then
                local highlighted_island = update_get_tile_by_id(g_highlighted.island_id)

                if highlighted_island:get() then
                    local marker_index, is_valid = highlighted_island:get_turret_spawn(g_highlighted.turret_spawn_index)
                    local built = false
                    local building = false
                    local icon = get_icon_by_turret_type_id(g_command_center_ui.selected_item)
                    local text = update_get_loc(e_loc.upp_construct)
                    local tooltip_h = 28
                    local marker_progress = 0
                    if not is_valid then
                        marker_progress = get_island_turret_progress(highlighted_island, g_highlighted.turret_spawn_index)
                        if marker_progress >= 0 and marker_progress < 1 then
                            text = update_get_loc(e_loc.upp_cancel)
                            turret_item_id = get_island_turret_queue_number(highlighted_island, marker_index)
                            icon = get_icon_by_turret_type_id(turret_item_id)
                            building = true
                            tooltip_h = tooltip_h + 11
                        else
                            icon = atlas_icons.icon_chassis_16_land_turret
                            text = update_get_loc(e_loc.upp_active)
                            built = true
                        end
                    end
                    local text_w = update_ui_get_text_size(text, 200, 0)

                    local turret_icon_color = iff(is_valid, color_status_ok, color_status_bad)
                    local turret_text_color = iff(is_valid, color_white, color_grey_dark)
                    if built then
                        turret_icon_color = color_status_ok
                    else
                        if not is_valid then
                            if marker_progress >= 0 then
                                turret_text_color = color_status_bad
                            end
                        end
                    end

                    render_tooltip(10, 10, screen_w - 20, screen_h - 20, g_cursor_pos_x, g_cursor_pos_y, text_w + 44, tooltip_h, 10, function(w, h)
                        local team = update_get_team(update_get_screen_team_id())
                        local currency = 0
                        if team:get() then
                            currency = team:get_currency()
                            update_ui_image(2, 1, icon, turret_icon_color, 0)
                            update_ui_text(20, 4, text, w, 0, turret_text_color, 0)
                            if not built then
                                update_ui_text(20, 15, string.format("%d/%d CR", g_highlighted.turret_cost, currency) , w, 0, iff(g_highlighted.turret_cost < currency, color_status_ok, color_status_bad), 0)
                            end
                            if building then
                                update_ui_text(20, 25, string.format("%d", math.floor(marker_progress * 100)) .. "%", w, 0, color_status_ok, 0)
                            end
                        end
                    end)
                end
            end
        elseif g_drag.vehicle_id > 0 and g_drag.waypoint_id > 0 then
            -- drag

            local drag_vehicle = update_get_map_vehicle_by_id(g_drag.vehicle_id)

            if drag_vehicle:get() then
                local drag_waypoint = drag_vehicle:get_waypoint_by_id(g_drag.waypoint_id)

                if drag_waypoint:get() then
                    local waypoint_pos = drag_waypoint:get_position_xz()
                    local screen_pos_x, screen_pos_y = get_screen_from_world(waypoint_pos:x(), waypoint_pos:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                    update_ui_line(screen_pos_x, screen_pos_y, g_cursor_pos_x, g_cursor_pos_y, color8(255, 255, 255, 255))

                    if g_drag_distance > 2 then
                        drag_start_pos = waypoint_pos
                    end
                else
                    g_drag:clear()
                end
            end
        elseif g_drag.vehicle_id > 0 then
            -- drag

            local drag_vehicle = update_get_map_vehicle_by_id(g_drag.vehicle_id)

            if drag_vehicle:get() then
                local vehicle_pos_xz = drag_vehicle:get_position_xz()
                local screen_pos_x, screen_pos_y = get_screen_from_world(vehicle_pos_xz:x(), vehicle_pos_xz:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                local drag_line_color = iff(get_is_vehicle_type_waypoint_capable(drag_vehicle:get_definition_index()) and get_is_vehicle_waypoint_available(drag_vehicle), color_white, color_grey_dark)

                update_ui_line(screen_pos_x, screen_pos_y, g_cursor_pos_x, g_cursor_pos_y, drag_line_color)

                if g_drag_distance > 2 then
                    drag_start_pos = vehicle_pos_xz
                end
            else
                g_drag:clear()
            end
        elseif g_selected_child_vehicle_id ~= 0 then
            -- drag

            local drag_vehicle = update_get_map_vehicle_by_id(g_selected_child_vehicle_id)

            if drag_vehicle:get() then
                local vehicle_pos_xz = drag_vehicle:get_position_xz()
                local screen_pos_x, screen_pos_y = get_screen_from_world(vehicle_pos_xz:x(), vehicle_pos_xz:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

                if drag_vehicle:get_attached_parent_id() ~= 0 then
                    local parent_vehicle = update_get_map_vehicle_by_id(drag_vehicle:get_attached_parent_id())

                    if parent_vehicle:get() then
                        local parent_vehicle_pos_xz = parent_vehicle:get_position_xz()
                        screen_pos_x, screen_pos_y = get_screen_from_world(parent_vehicle_pos_xz:x(), parent_vehicle_pos_xz:y(), g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
                    end
                end

                local drag_line_color = iff(get_is_vehicle_waypoint_available(drag_vehicle), color_white, color_grey_dark)
                update_ui_line(screen_pos_x, screen_pos_y, g_cursor_pos_x, g_cursor_pos_y, drag_line_color)

                drag_start_pos = vehicle_pos_xz
            end
        elseif g_highlighted.vehicle_id > 0 and g_highlighted.waypoint_id == 0 then
            -- render highlighted tooltip

            local highlighted_vehicle = update_get_map_vehicle_by_id(g_highlighted.vehicle_id)

            if highlighted_vehicle:get() then
                local vehicle_definition_index = highlighted_vehicle:get_definition_index()

                if g_highlighted.waypoint_id > 0 then
                    -- render waypoint tooltip
                    local highlighted_waypoint = highlighted_vehicle:get_waypoint_by_id(g_highlighted.waypoint_id)

                    if get_is_vehicle_air(vehicle_definition_index) then
                        local alt_str = string.format( "%.0f ", highlighted_waypoint:get_altitude() ) .. update_get_loc(e_loc.acronym_meters)
                        local alt_width = update_ui_get_text_size(alt_str, 10000, 0) + 4

                        render_tooltip(10, 10, screen_w - 20, screen_h - 20, g_pointer_pos_x, g_pointer_pos_y, alt_width, 14, 10, function(w, h)    update_ui_text(2, 2, alt_str, w - 4, 0, color_white, 0) end)
                    end
                else
                    -- render vehicle tooltip
                    local peers = iff( highlighted_vehicle:get_team() == update_get_screen_team_id() or get_is_spectator_mode(), get_vehicle_controlling_peers(highlighted_vehicle), {} )
                    local tool_height = 21 + (#peers * 10)
                    if get_is_vehicle_air(highlighted_vehicle:get_definition_index()) then
                        tool_height = tool_height + 10
                    end

                    local ttp = render_tooltip(10, 10, screen_w - 20, screen_h - 20, g_pointer_pos_x, g_pointer_pos_y, 140, tool_height, 10, function(w, h) render_vehicle_tooltip(w, h, highlighted_vehicle, peers) end, color8(0, 0, 0, 190))

                    if g_debug_enabled or get_is_spectator_mode() then
                        local hitpoints = highlighted_vehicle:get_hitpoints()
                        local hitpoints_total = highlighted_vehicle:get_total_hitpoints()
                        update_ui_text(g_pointer_pos_x, g_pointer_pos_y + 30,
                                string.format("%d/%d", hitpoints, hitpoints_total), 100, 0, color_highlight, 0)
                    end

                    -- overlay the name if it has one
                    if vehicle_definition_index ~= e_game_object_type.chassis_carrier then
                        local custom_name = rev_get_unit_name(highlighted_vehicle)
                        if custom_name then
                            local ny = ttp["y"] + ttp["h"] + 2
                            if ttp["a"] then
                                ny = ttp["y"] - 10
                            end
                            update_ui_rectangle(ttp["x"], ny-1, ttp["w"], 11, color_shadow)
                            update_ui_text(ttp["x"] + 1, ny, custom_name, 200, 0, color_status_dark_green, 0)
                        end
                    end
                end
            end
        elseif g_highlighted.vehicle_id > 0 and g_highlighted.waypoint_id ~= 0 then
            -- render waypoint tooltip

            local highlighted_vehicle = update_get_map_vehicle_by_id(g_highlighted.vehicle_id)

            if highlighted_vehicle:get() then
                if get_is_vehicle_air(highlighted_vehicle:get_definition_index()) then
                    local waypoint = highlighted_vehicle:get_waypoint_by_id(g_highlighted.waypoint_id)

                    if waypoint:get() then
                        local altitude_text = waypoint:get_altitude() .. update_get_loc(e_loc.acronym_meters)
                        local text_w = update_ui_get_text_size(altitude_text, 200, 0)

                        render_tooltip(10, 10, screen_w - 20, screen_h - 20, g_cursor_pos_x, g_cursor_pos_y, text_w + 8, 13, 10, function(w, h)
                            update_ui_text(0, 2, altitude_text, w, 1, color_white, 0)
                        end)
                    end
                end
            end
        elseif g_highlighted.command_center_id > 0 then
            -- render command center tooltip

            local highlighted_island = update_get_tile_by_id(g_highlighted.command_center_id)

            if highlighted_island:get() then
                local text = update_get_loc(e_loc.upp_command_center)
                local text_w = update_ui_get_text_size(text, 200, 0)
                local highlighted_island_team_color = update_get_team_color(highlighted_island:get_team_control())
                local island_visible = fow_island_visible(highlighted_island:get_id())
                if not island_visible then
                    highlighted_island_team_color = g_island_color_unknown
                end
                local text_x = 14

                render_tooltip(10, 10, screen_w - 20, screen_h - 20, g_cursor_pos_x, g_cursor_pos_y, text_w + 18, 17, 10, function(w, h)
                    if island_visible or not g_revolution_hide_hostile_island_types then
                        local category_data = g_item_categories[highlighted_island:get_facility_category()]
                        update_ui_image(4, 4, category_data.icon, highlighted_island_team_color, 0)
                    else
                        text_x = 8
                    end
                    if highlighted_island:get_team_control() == screen_team then
                        update_ui_text(text_x, 4, text, w, 0, color_white, 0)
                    else
                        update_ui_text(text_x, 4, text, w, 0, color_grey_dark, 0)
                    end
                end)
            end
        elseif g_highlighted.island_id > 0 and g_highlighted.production_index ~= -1 then
            -- render production item tooltip

            local highlighted_island = update_get_tile_by_id(g_highlighted.island_id)

            if highlighted_island:get() then
                local item_type_id = highlighted_island:get_facility_production_queue_defense_item(g_highlighted.production_index)
                local item = g_item_data[item_type_id] -- do we need it?

                if item ~= nil then
                    local text = iff(g_highlighted.production_index == 0, update_get_loc(e_loc.upp_constructing), update_get_loc(e_loc.upp_pending))
                    local dot_count = math.floor(g_animation_time / 10) % 4
                    for i = 1, 3 do text = text .. iff(i <= dot_count, ".", " ") end

                    local icon = get_icon_by_turret_type_id(item_type_id)
                    local text_w = update_ui_get_text_size(text, 200, 0)

                    render_tooltip(10, 10, screen_w - 20, screen_h - 20, g_cursor_pos_x, g_cursor_pos_y, text_w + 46, 19, 10, function(w, h)
                        update_ui_image(4, 2, icon, iff(g_highlighted.production_index == 0, color_white, color_grey_dark), 0)
                        update_ui_text(22, 5, text, w, 0, iff(g_highlighted.production_index == 0, color_status_ok, color_grey_dark), 0)
                    end)
                end
            end
        end

        if get_is_map_movement_allowed() then
            if update_get_active_input_type() == e_active_input.gamepad or update_get_is_focus_local() == false then
                local crosshair_color = color8(255, 255, 255, 255)

                if g_highlighted.vehicle_id > 0 or g_highlighted.waypoint_id > 0 then
                    crosshair_color = color8(0, 0, 0, 255)
                end

                update_ui_rectangle(g_cursor_pos_x, g_cursor_pos_y + 2, 1, 4, crosshair_color)
                update_ui_rectangle(g_cursor_pos_x, g_cursor_pos_y - 5, 1, 4, crosshair_color)
                update_ui_rectangle(g_cursor_pos_x + 2, g_cursor_pos_y, 4, 1, crosshair_color)
                update_ui_rectangle(g_cursor_pos_x - 5, g_cursor_pos_y, 4, 1, crosshair_color)
            end

            -- render captain's holomap cursor
            if update_get_is_focus_local() then
                render_team_holomap_cursor(screen_vehicle:get_team())
            end

            render_cursor_info(screen_w, screen_h, drag_start_pos)
            render_map_scale(screen_w, screen_h)

            local sample_x, sample_y = get_world_from_screen(g_cursor_pos_x, g_cursor_pos_y, g_camera_pos_x, g_camera_pos_y, g_camera_size, 256, 256)

            local label_x = 24
            local label_y = 23
            local label_w = screen_w - 2 * label_x
            local label_h = 10

            update_ui_push_offset(label_x, label_y)

            if g_map_render_mode > 1 then
                update_ui_rectangle(0, 0, label_w, label_h, color_black)
            end

            if g_map_render_mode == 2 then
                update_ui_text(1, 1, string.format(update_get_loc(e_loc.upp_wind)..": %.2f", update_get_weather_wind_velocity(sample_x, sample_y)), label_w, 0, color_white, 0)
            elseif g_map_render_mode == 3 then
                update_ui_text(1, 1, string.format(update_get_loc(e_loc.upp_precipitation)..": %.0f%%", update_get_weather_precipitation_factor(sample_x, sample_y) * 100), label_w, 0, color_white, 0)

                local cx = label_w - 42
                update_ui_image(cx, 1, atlas_icons.column_power, color_white, 0)
                cx = cx + 5
                update_ui_text(cx, 1, string.format(": %.0f%%", update_get_weather_lightning_factor(sample_x, sample_y) * 100), label_w, 0, color_white, 0)
            elseif g_map_render_mode == 4 then
                update_ui_text(1, 1, string.format(update_get_loc(e_loc.upp_visibility)..": %.0f%%", update_get_weather_fog_factor(sample_x, sample_y) * 100), label_w, 0, color_white, 0)
            elseif g_map_render_mode == 5 then
                update_ui_text(1, 1, string.format(update_get_loc(e_loc.upp_ocean_current)..": %.2f", update_get_ocean_current_velocity(sample_x, sample_y)), label_w, 0, color_white, 0)
            elseif g_map_render_mode == 6 then
                update_ui_text(1, 1, string.format(update_get_loc(e_loc.upp_ocean_depth)..": %.2f", update_get_ocean_depth_factor(sample_x, sample_y)), label_w, 0, color_white, 0)
            end

            update_ui_pop_offset()
        end


        -- Show tactical mode enabled
        if g_tactical_vid ~= 0 then
            local tact_text = "TACTICAL MODE ON"
            local rect_w = update_ui_get_text_size(tact_text, screen_w, 2) + 8
            local rect_h = 14

            update_ui_push_offset((screen_w - rect_w) / 2, screen_h - rect_h - 10)
            update_ui_push_clip(0, 0, rect_w, rect_h)
            update_ui_rectangle(0, 0, rect_w, rect_h, color_status_dark_yellow)
            update_ui_text(0, rect_h / 2 - 4, tact_text, rect_w, 1, color_black, 0)

            update_ui_pop_clip()
            update_ui_pop_offset()
        end


        local go_code_factor = 0

        if g_go_code_time < 5 then
            go_code_factor = clamp(g_go_code_time / 5, 0, 1)
        else
            go_code_factor = 1 - clamp((g_go_code_time - 5 - 55) / 5, 0, 1)
        end

        g_go_code_time = g_go_code_time + 1

        if go_code_factor > 0 then
            local go_code_text = ""

            if g_go_code == 0 then
                go_code_text = update_get_loc(e_loc.upp_go_code_alpha)
            elseif g_go_code == 1 then
                go_code_text = update_get_loc(e_loc.upp_go_code_bravo)
            elseif g_go_code == 2 then
                go_code_text = update_get_loc(e_loc.upp_go_code_charlie)
            elseif g_go_code == 3 then
                go_code_text = update_get_loc(e_loc.upp_go_code_delta)
            end

            local rect_w = update_ui_get_text_size(go_code_text, screen_w, 2) + 8
            local rect_h = 14

            update_ui_push_offset((screen_w - rect_w) / 2, screen_h - rect_h - 10)
            update_ui_push_clip(0, 0, rect_w, math.ceil(rect_h * go_code_factor))
            update_ui_rectangle(0, 0, rect_w, rect_h, color_status_bad)
            update_ui_text(0, rect_h / 2 - 4, go_code_text, rect_w, 1, color_black, 0)

            update_ui_pop_clip()
            update_ui_pop_offset()
        end
    elseif g_screen_index == 1 then
        -- viewing vehicle camera
        update_set_screen_background_type(0)
        local viewing_vehicle = update_get_map_vehicle_by_id(g_viewing_vehicle_id)

        if viewing_vehicle:get() then
            if update_get_is_focus_local() or not g_is_pip_enable then
                g_camera_pos_x = viewing_vehicle:get_position_xz():x()
                g_camera_pos_y = viewing_vehicle:get_position_xz():y()

                local connecting_text = update_get_loc(e_loc.connecting)
                local dot_count = math.floor(g_animation_time / (30 / 4)) % 4

                for i = 1, dot_count, 1 do
                    connecting_text = connecting_text .. "."
                end

                local cx = screen_w / 2 - 40
                local cy = screen_h / 2 - 5
                update_ui_text(cx, cy, connecting_text, 100, 0, color_white, 0)

                local anim = g_animation_time / 30.0
                local bound_left = cx
                local bound_right = bound_left + 75
                local left = bound_left + (bound_right - bound_left) * math.abs(math.sin((anim - math.pi / 2) % (math.pi / 2))) ^ 4
                local right = left + (bound_right - left) * math.abs(math.sin(anim % (math.pi / 2)))

                update_ui_rectangle(left, cy + 12, right - left, 1, color_status_ok)
                update_ui_rectangle(bound_right + bound_left - right, cy - 3, right - left, 1, color_status_ok)
            else
                local is_render_vehicle = viewing_vehicle:get_definition_index() ~= e_game_object_type.chassis_sea_barge

                update_set_screen_background_type(9)
                update_set_screen_camera_attach_vehicle(g_viewing_vehicle_id, 0)

                update_set_screen_camera_cull_distance(5000)
                update_set_screen_camera_lod_level(0)
                update_set_screen_camera_is_render_map_vehicles(true)
                update_set_screen_camera_render_attached_vehicle(is_render_vehicle)
                update_set_screen_camera_is_render_ocean(true)
            end
        else
            local cx = screen_w / 2 - 50
            local cy = screen_h / 2
            local connecting_text = update_get_loc(e_loc.connection_lost)

            local text_w, text_h = update_ui_get_text_size(connecting_text, 100, 1)
            update_ui_text(cx, cy - text_h / 2, connecting_text, 100, 1, color_status_bad, 0)

            if g_animation_time % 20 > 10 then
                update_ui_image(cx + 50 - text_w / 2 - 16, cy - 5, atlas_icons.hud_warning, color_status_bad, 0)
                update_ui_image(cx + 50 + text_w / 2 + 6, cy - 5, atlas_icons.hud_warning, color_status_bad, 0)
            end
        end
    elseif g_screen_index == 2 then
        -- multi-unit wall display
        update_set_screen_background_type(0)
        local ui = g_ui

        local team = update_get_screen_team_id()
        local vehicle_count = update_get_map_vehicle_count()
        local shown = 0
        local number = 0
        local total = 0
        local vx = 0
        local vy = 48
        for i = 0, vehicle_count - 1, 1 do
            local vehicle = update_get_map_vehicle_by_index(i)
            if vehicle:get() then
                local vehicle_id = vehicle:get_id()
                local vehicle_def = vehicle:get_definition_index()
                local vehicle_team = vehicle:get_team()
                if vehicle_team == team then
                    if vehicle_def ~= e_game_object_type.drydock and
                    (
                            g_wall_mode == g_wall_all
                            or (g_wall_mode == g_wall_air and get_is_vehicle_air(vehicle_def))
                            or (g_wall_mode == g_wall_gnd and get_is_vehicle_land(vehicle_def) and vehicle_def ~= e_game_object_type.chassis_land_turret)
                            or (g_wall_mode == g_wall_sea and get_is_vehicle_sea(vehicle_def))
                            or (g_wall_mode == g_wall_trt and vehicle_def == e_game_object_type.chassis_land_turret)
                    ) and not get_vehicle_docked(vehicle) then
                        total = total + 1
                        number = number + 1
                        if vx < screen_w - 126 and number >= g_wall_offset then
                            shown = shown + 1
                            local vh, vclicked = render_vehicle_info_panel(vx, vy, vehicle)
                            if vclicked then
                                -- go back to screen 1 and center on this unit
                                g_camera_pos_x = vehicle:get_position_xz():x()
                                g_camera_pos_y = vehicle:get_position_xz():y()
                                g_selection:clear()
                                g_screen_index = 0
                                g_is_ignore_tap = 1
                                return
                            end

                            vy = vy + vh
                            if vy > screen_h - vh then
                                vy = 48
                                vx = vx + 128
                            end
                        end
                    end
                end
            end
        end

        local window = ui:begin_window(update_get_loc(e_loc.upp_vehicles), 0, 0, screen_w, 42, atlas_icons.column_pending, true, 2)
        local button_action = ui:button_group(
                { "CLOSE", "", "", "ALL", "AIR", "GND", "SEA", "TRT" }, true)
        if button_action == 0 then
            g_screen_index = 0
        elseif button_action > 0 then
            g_wall_mode = button_action
        end
        local header = ""
        if g_wall_mode == g_wall_all then
            header = "ALL UNITS"
        elseif g_wall_mode == g_wall_air then
            header = "AIRCRAFT"
        elseif g_wall_mode == g_wall_gnd then
            header = "GROUND"
        elseif g_wall_mode == g_wall_sea then
            header = "SEA"
        elseif g_wall_mode == g_wall_trt then
            header = "TURRETS"
        end

        --
        local first = g_wall_offset
        header = string.format("%s %d-%d/%d", header, first, first + shown - 1, total)
        if ui:button(header, true, 0) then
            g_wall_offset = g_wall_offset + shown
            if g_wall_offset > total then
                g_wall_offset = 0
            end
        end
        ui:end_window()

    end
    if g_ui ~= nil then
        g_ui:end_ui()
    end

    g_pointer_pos_x_prev = g_pointer_pos_x
    g_pointer_pos_y_prev = g_pointer_pos_y
end

function render_vehicle_info_panel(x, y, vehicle)
    local w = 127
    local h = 22
    local clicked = false
    local ui = g_ui
    local hover = false
    if ui.mouse_x > x and ui.mouse_x < x + w then
        hover = ui.mouse_y > y and ui.mouse_y < y + h
    end
    if hover and ui.input_pointer_1 then
        clicked = true
    end
    if hover then
        update_ui_rectangle_outline(x, y, w, h, color_grey_mid)
    else
        update_ui_rectangle_outline(x, y, w, h, color_grey_dark)
    end
    y = y + 1
    local vehicle_definition_index = vehicle:get_definition_index()
    local vehicle_pos_xz = vehicle:get_position_xz()
    local repair_factor = vehicle:get_repair_factor()
    local fuel_factor = vehicle:get_fuel_factor()
    local ammo_factor = vehicle:get_ammo_factor()

    local type_name, type_icon, type_abrev, type_desc = get_chassis_data_by_definition_index(vehicle_definition_index)
    local nearest_island = get_nearest_island_tile(vehicle_pos_xz:x(), vehicle_pos_xz:y())
    local icon_offset = 0
    local icon_w = 16
    local icon_col = color_white

    if repair_factor < 0.4 then
        icon_col = color_enemy
    end

    local peers = iff( vehicle:get_team() == update_get_screen_team_id(), get_vehicle_controlling_peers(vehicle), {} )
    local display_id = ""
    if vehicle_definition_index == e_game_object_type.chassis_carrier then
        display_id = get_ship_name(vehicle)
    else
        display_id = update_get_loc(e_loc.upp_id) .. string.format( " %.0f", vehicle:get_id() )
    end
    display_id = type_abrev .. " " .. display_id
    local id_w, id_h = update_ui_get_text_size(display_id, w - 2 - icon_w, 2)
    y = y + 1
    -- icon
    update_ui_image(x - icon_offset, y - icon_offset, type_icon, icon_col, 0)

    -- fuel/ammo icons
    if fuel_factor < 0.5 then
        local fuel_color = color_status_dark_yellow
        if fuel_factor < 0.25 then
            fuel_color = color_enemy
        end
        update_ui_image(x + icon_w - 5, y + icon_w - 4, atlas_icons.map_icon_low_fuel, fuel_color, 0)
    end
    if ammo_factor < 0.5 then
        local ammo_color = color_status_dark_yellow
        if ammo_factor < 0.1 then
            ammo_color = color_enemy
        end
        update_ui_image(x + icon_w - 5, y + 1, atlas_icons.map_icon_low_ammo, ammo_color, 0)
    end

    x = x + icon_w
    -- bars
    local bar_h = h - 4
    local repair_bar = math.floor(bar_h * repair_factor)
    local fuel_bar = math.floor(bar_h * fuel_factor)
    local ammo_bar = math.floor(bar_h * ammo_factor)
    update_ui_rectangle(x + 0, y, 1, bar_h, color8(16, 16, 16, 255))
    update_ui_rectangle(x + 0, y + bar_h - repair_bar, 1, repair_bar, color8(47, 116, 255, 255))
    update_ui_rectangle(x + 2, y, 1, bar_h, color8(16, 16, 16, 255))
    update_ui_rectangle(x + 2, y + bar_h - fuel_bar, 1, fuel_bar, color8(119, 85, 161, 255))
    update_ui_rectangle(x + 4, y, 1, bar_h, color8(16, 16, 16, 255))
    update_ui_rectangle(x + 4, y + bar_h - ammo_bar, 1, ammo_bar, color8(201, 171, 68, 255))
    x = x + 7
    -- text

    update_ui_text(x, y, display_id, id_w , 0, color_white, 0)

    if #peers > 0 and g_animation_time % 60 > 30 then
        -- render peers if there are any
        for i = 1, #peers do
            local peer = peers[i]
            local peer_name = peer.name

            local max_text_chars = 18
            local is_clipped = false

            if utf8.len(peer_name) > max_text_chars then
                peer_name = peer_name:sub(1, utf8.offset(peer_name, max_text_chars) - 1)
                is_clipped = true
            end
            update_ui_text(x, y + 9, peer_name, w - icon_w - 7, 0, color_grey_mid, 0)
        end
    else
        -- render island name
        update_ui_text(x, y + 9, get_island_name(nearest_island):sub(1, 18), w - icon_w - 7, 0, color_grey_mid, 0)
    end

    return h + 1, clicked

end

function update_interaction_ui()
    if g_screen_index == 1 then
        update_add_ui_interaction(update_get_loc(e_loc.interaction_back), e_game_input.back)
    elseif g_selected_child_vehicle_id ~= 0 and g_selection:is_selection() == false then
        update_add_ui_interaction(update_get_loc(e_loc.interaction_cancel), e_game_input.back)

        local child_vehicle = update_get_map_vehicle_by_id(g_selected_child_vehicle_id)

        if child_vehicle:get() and get_is_vehicle_waypoint_available(child_vehicle) then
            update_add_ui_interaction(update_get_loc(e_loc.interaction_set_waypoint), e_game_input.interact_a)
        end

        update_add_ui_interaction_special(update_get_loc(e_loc.interaction_pan), e_ui_interaction_special.map_pan)
        update_add_ui_interaction_special(update_get_loc(e_loc.interaction_zoom), e_ui_interaction_special.map_zoom)
    elseif g_drag.vehicle_id > 0 and g_selection:is_selection() == false then
        update_add_ui_interaction(update_get_loc(e_loc.interaction_cancel), e_game_input.back)
        update_add_ui_interaction_special(update_get_loc(e_loc.interaction_pan), e_ui_interaction_special.map_pan)
        update_add_ui_interaction_special(update_get_loc(e_loc.interaction_zoom), e_ui_interaction_special.map_zoom)
    elseif g_highlighted.vehicle_id > 0 and g_selection:is_selection() == false then
        if g_highlighted.waypoint_id > 0 then
            update_add_ui_interaction(update_get_loc(e_loc.interaction_waypoint), e_game_input.interact_a)
            update_add_ui_interaction_special(update_get_loc(e_loc.interaction_add_waypoint), e_ui_interaction_special.map_drag)
        else
            local highlighted_vehicle = update_get_map_vehicle_by_id(g_highlighted.vehicle_id)

            if highlighted_vehicle:get() then
                local vehicle_definition_index = highlighted_vehicle:get_definition_index()

                if highlighted_vehicle:get_team() == update_get_screen_team_id() or get_is_spectator_mode() then
                    if vehicle_definition_index == e_game_object_type.chassis_carrier then
                        update_add_ui_interaction(update_get_loc(e_loc.interaction_carrier), e_game_input.interact_a)
                    else
                        update_add_ui_interaction(update_get_loc(e_loc.interaction_vehicle), e_game_input.interact_a)

                        if get_is_vehicle_enterable(highlighted_vehicle) then
                            update_add_ui_interaction(update_get_loc(e_loc.interaction_camera), e_game_input.interact_b)
                        end
                    end

                    if get_is_vehicle_type_waypoint_capable(vehicle_definition_index) then
                        update_add_ui_interaction_special(update_get_loc(e_loc.interaction_add_waypoint), e_ui_interaction_special.map_drag)
                    end
                end
            end
        end
    elseif g_highlighted.command_center_id > 0 and g_selection:is_selection() == false then
        local highlighted_island = update_get_tile_by_id(g_highlighted.command_center_id)

        if highlighted_island:get() and highlighted_island:get_team_control() == update_get_screen_team_id() then
            update_add_ui_interaction(update_get_loc(e_loc.interaction_select), e_game_input.interact_a)
        end
    elseif g_highlighted.island_id > 0 and g_highlighted.marker_index ~= -1 and get_is_placing_turret() then
        local highlighted_island = update_get_tile_by_id(g_highlighted.island_id)

        if highlighted_island:get() and highlighted_island:get_team_control() == update_get_screen_team_id() then
            update_add_ui_interaction(update_get_loc(e_loc.interaction_select), e_game_input.interact_a)
        end
    elseif g_highlighted.island_id > 0 and g_highlighted.production_index ~= -1 and g_selection:is_selection() == false then
        local highlighted_island = update_get_tile_by_id(g_highlighted.island_id)

        if highlighted_island:get() and highlighted_island:get_team_control() == update_get_screen_team_id() then
            update_add_ui_interaction(update_get_loc(e_loc.interaction_select), e_game_input.interact_a)
        end
    elseif g_selection:is_selection() == false then
        update_add_ui_interaction(update_get_loc(e_loc.interaction_map_options), e_game_input.interact_a)
        update_add_ui_interaction_special(update_get_loc(e_loc.interaction_pan), e_ui_interaction_special.map_pan)
        update_add_ui_interaction_special(update_get_loc(e_loc.interaction_zoom), e_ui_interaction_special.map_zoom)
    elseif get_is_map_movement_allowed() then
        update_add_ui_interaction_special(update_get_loc(e_loc.interaction_pan), e_ui_interaction_special.map_pan)
        update_add_ui_interaction_special(update_get_loc(e_loc.interaction_zoom), e_ui_interaction_special.map_zoom)
    end
end

function update_cursor_state(screen_w, screen_h)
    if update_get_is_focus_local() == false then return end

    if update_get_active_input_type() == e_active_input.keyboard then
        g_cursor_pos_x = g_pointer_pos_x
        g_cursor_pos_y = g_pointer_pos_y
    else
        g_cursor_pos_x = screen_w / 2
        g_cursor_pos_y = screen_h / 2
    end
end

function input_zoom_camera(factor, screen_w, screen_h, zoom_x, zoom_y)
    if g_screen_index == 0 then
        if get_is_map_movement_allowed() then
            local cursor_x = zoom_x or g_cursor_pos_x
            local cursor_y = zoom_y or g_cursor_pos_y
            local cursor_prev_x, cursor_prev_y = get_world_from_screen(cursor_x, cursor_y, g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)

            g_camera_size = g_camera_size * factor
            g_camera_size = math.min(g_camera_size, 256 * 1024)
            g_camera_size = math.max(g_camera_size, 128)

            local cursor_next_x, cursor_next_y = get_world_from_screen(cursor_x, cursor_y, g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
            local dx = cursor_next_x - cursor_prev_x
            local dy = cursor_next_y - cursor_prev_y
            g_camera_pos_x = g_camera_pos_x - dx
            g_camera_pos_y = g_camera_pos_y - dy
        end
    end
end

function input_event(event, action)
    g_last_input_tick = update_get_logic_tick()

    if call_func_override("screen_vehicle_control__input_event", event, action) then
        return
    end

    if event == e_input.pointer_1 then
        g_is_pointer_pressed = action == e_input_action.press
    end

    if g_screen_index == 0 then
        local is_input_consumed = false

        if g_selection:is_selection() then
            is_input_consumed = input_selection(event, action)
        end

        if is_input_consumed == false then
            if action == e_input_action.press then
                if event == e_input.action_a or event == e_input.pointer_1 then
                    if g_selected_child_vehicle_id ~= 0 then
                        -- add waypoint to vehicle

                        local world_x, world_y = get_world_from_screen(g_cursor_pos_x, g_cursor_pos_y, g_camera_pos_x, g_camera_pos_y, g_camera_size, g_screen_w, g_screen_h)
                        local child_vehicle = update_get_map_vehicle_by_id(g_selected_child_vehicle_id)

                        if child_vehicle:get() and get_is_vehicle_waypoint_available(child_vehicle) then
                            child_vehicle:clear_waypoints()
                            child_vehicle:clear_attack_target()
                            child_vehicle:add_waypoint(world_x, world_y)
                        end

                        g_selected_child_vehicle_id = 0
                        g_is_ignore_tap = true
                    elseif g_highlighted.vehicle_id > 0 and g_highlighted.waypoint_id == 0 then
                        local highlighted_vehicle = update_get_map_vehicle_by_id(g_highlighted.vehicle_id)

                        if highlighted_vehicle:get() and (highlighted_vehicle:get_team() == update_get_screen_team_id() or get_is_spectator_mode()) then
                            g_drag:set_vehicle(g_highlighted.vehicle_id)
                        end
                    elseif g_highlighted.vehicle_id > 0 and g_highlighted.waypoint_id > 0 then
                        local highlighted_vehicle = update_get_map_vehicle_by_id(g_highlighted.vehicle_id)

                        if highlighted_vehicle:get() and (highlighted_vehicle:get_team() == update_get_screen_team_id() or get_is_spectator_mode()) then
                            g_drag:set_vehicle_waypoint(g_highlighted.vehicle_id, g_highlighted.waypoint_id)
                        end
                    elseif g_highlighted.command_center_id > 0 then
                        local highlighted_island = update_get_tile_by_id(g_highlighted.command_center_id)

                        if highlighted_island:get() and highlighted_island:get_team_control() == update_get_screen_team_id() then
                            g_drag:set_command_center(g_highlighted.command_center_id)
                        end
                    elseif g_highlighted.island_id > 0 and g_highlighted.turret_spawn_index ~= -1 then
                        local highlighted_island = update_get_tile_by_id(g_highlighted.island_id)

                        if highlighted_island:get() and highlighted_island:get_team_control() == update_get_screen_team_id() then
                            g_drag:set_island_turret_spawn(g_highlighted.island_id, g_highlighted.turret_spawn_index)
                        end
                    elseif g_highlighted.island_id > 0 and g_highlighted.production_index ~= -1 then
                        local highlighted_island = update_get_tile_by_id(g_highlighted.island_id)

                        if highlighted_island:get() and highlighted_island:get_team_control() == update_get_screen_team_id() then
                            g_drag:set_island_production(g_highlighted.island_id, g_highlighted.production_index)
                        end
                    elseif event == e_input.pointer_1 and get_is_map_movement_allowed() then
                        g_is_drag_pan_map = true
                    end

                    g_drag_distance = 0
                elseif event == e_input.action_b then
                    if g_highlighted.vehicle_id > 0 and g_highlighted.waypoint_id == 0 then
                        local highlighted_vehicle = update_get_map_vehicle_by_id(g_highlighted.vehicle_id)

                        if highlighted_vehicle:get() ~= nil and get_is_vehicle_enterable(highlighted_vehicle) then
                            g_viewing_vehicle_id = highlighted_vehicle:get_id()
                            g_screen_index = 1
                        end
                    end
                elseif event == e_input.back then
                    if g_selected_child_vehicle_id ~= 0 then
                        g_selected_child_vehicle_id = 0
                    elseif g_drag:is_drag() then
                        g_drag:clear()
                    else
                        update_set_screen_state_exit()
                    end
                end
            else
                if event == e_input.action_a or event == e_input.pointer_1 then

                    if event == e_input.pointer_1 then
                        g_is_drag_pan_map = false
                    end

                    if g_is_ignore_tap then
                        g_is_ignore_tap = false
                    elseif get_is_highlighting_dragged_item() and g_selected_child_vehicle_id == 0 then
                        -- tap

                        local drag_threshold = 3

                        if update_get_is_vr() then
                            drag_threshold = 20
                        end

                        if event == e_input.action_a or g_is_pointer_hovered then
                            if g_drag.waypoint_id > 0 then
                                g_selection:set_vehicle_waypoint(g_drag.vehicle_id, g_drag.waypoint_id)
                            elseif g_drag.vehicle_id > 0 then
                                g_selection:set_vehicle(g_drag.vehicle_id)
                            elseif g_drag.command_center_id > 0 then
                                g_selection:set_command_center(g_drag.command_center_id)
                            elseif get_is_placing_turret() and g_drag.island_id > 0 and g_drag.turret_spawn_index ~= -1 then
                                purchase_turret(g_command_center_ui.selected_item, g_drag.island_id, g_drag.turret_spawn_index)
                            elseif g_drag.island_id > 0 and g_drag.production_index ~= -1 then
                                g_selection:set_command_center(g_drag.island_id)
                                g_command_center_ui.selected_panel = 1
                                g_command_center_ui.selected_facility_queue_item = g_drag.production_index
                            elseif g_highlighted.vehicle_id == 0 and g_drag_distance < drag_threshold and get_is_placing_turret() == false then
                                g_selection:set_map()
                            end
                        end
                    else
                        local drag_vehicle = update_get_map_vehicle_by_id(g_drag.vehicle_id)

                        if drag_vehicle:get() then
                            local vehicle_definition_index = drag_vehicle:get_definition_index()

                            if get_is_vehicle_type_waypoint_capable(vehicle_definition_index) then
                                -- drag

                                if g_highlighted.vehicle_id == g_drag.vehicle_id and g_highlighted.waypoint_id > 0 and g_highlighted.waypoint_id ~= g_drag.waypoint_id then
                                    drag_vehicle:set_waypoint_repeat(g_drag.waypoint_id, g_highlighted.waypoint_id)
                                elseif g_highlighted.vehicle_id > 0 then
                                    local highlighted_vehicle = update_get_map_vehicle_by_id(g_highlighted.vehicle_id)

                                    if highlighted_vehicle:get() then
                                        local highlighted_vehicle_team = highlighted_vehicle:get_team()
                                        local highlighted_vehicle_definition = highlighted_vehicle:get_definition_index()

                                        if highlighted_vehicle_team == update_get_screen_team_id() or get_is_spectator_mode() then
                                            if g_drag.waypoint_id > 0 and vehicle_definition_index == e_game_object_type.chassis_air_rotor_heavy and get_is_vehicle_airliftable(highlighted_vehicle_definition) then
                                                -- toggle an "attack" target to perform airlift operation on friendly vehicle

                                                local is_highlighted_vehicle_found = false
                                                local drag_waypoint = drag_vehicle:get_waypoint_by_id(g_drag.waypoint_id)
                                                local attack_target_count = drag_waypoint:get_attack_target_count()

                                                for i = 0, attack_target_count - 1, 1 do
                                                    local attack_target_vehicle_id = drag_waypoint:get_attack_target_target_id(i)

                                                    if attack_target_vehicle_id == g_highlighted.vehicle_id then
                                                        is_highlighted_vehicle_found = true
                                                        drag_vehicle:remove_waypoint_attack_target(g_drag.waypoint_id, i)
                                                        break
                                                    end
                                                end

                                                if is_highlighted_vehicle_found == false then
                                                    if vehicle_can_airlift(drag_vehicle) then
                                                        local highlighted_vehicle_id = highlighted_vehicle:get_id()

                                                        drag_vehicle:set_waypoint_attack_target_target_id(g_drag.waypoint_id, highlighted_vehicle_id)
                                                        drag_vehicle:set_waypoint_attack_target_attack_type(g_drag.waypoint_id, attack_target_count, e_attack_type.airlift)
                                                    end
                                                end
                                            else
                                                if get_is_vehicle_waypoint_available(drag_vehicle) then
                                                    if g_drag.vehicle_id == g_highlighted.vehicle_id then
                                                        if g_drag.waypoint_id > 0 then
                                                            local world_x, world_y = get_world_from_screen(g_cursor_pos_x, g_cursor_pos_y, g_camera_pos_x, g_camera_pos_y, g_camera_size, g_screen_w, g_screen_h)

                                                            drag_vehicle:clear_waypoints_from(g_drag.waypoint_id)
                                                            drag_vehicle:add_waypoint(world_x, world_y)
                                                        elseif g_drag.vehicle_id > 0 then
                                                            -- add waypoint to vehicle

                                                            local world_x, world_y = get_world_from_screen(g_cursor_pos_x, g_cursor_pos_y, g_camera_pos_x, g_camera_pos_y, g_camera_size, g_screen_w, g_screen_h)
                                                            drag_vehicle:clear_waypoints()
                                                            drag_vehicle:clear_attack_target()
                                                            drag_vehicle:add_waypoint(world_x, world_y)
                                                        end
                                                    else
                                                        -- add a support waypoint to friendly vehicle

                                                        if g_drag.waypoint_id > 0 then
                                                            drag_vehicle:clear_waypoints_from(g_drag.waypoint_id)
                                                            local support_waypoint_id = drag_vehicle:add_waypoint(highlighted_vehicle:get_position_xz():x(), highlighted_vehicle:get_position_xz():y())
                                                            drag_vehicle:set_target_vehicle(support_waypoint_id, g_highlighted.vehicle_id)
                                                        else
                                                            drag_vehicle:clear_waypoints()
                                                            drag_vehicle:clear_attack_target()
                                                            local support_waypoint_id = drag_vehicle:add_waypoint(highlighted_vehicle:get_position_xz():x(), highlighted_vehicle:get_position_xz():y())
                                                            drag_vehicle:set_target_vehicle(support_waypoint_id, g_highlighted.vehicle_id)
                                                        end
                                                    end
                                                end
                                            end
                                        else
                                            -- toggle attack target on enemy vehicle

                                            if g_drag.waypoint_id > 0 then
                                                local is_highlighted_vehicle_found = false
                                                local drag_waypoint = drag_vehicle:get_waypoint_by_id(g_drag.waypoint_id)
                                                local attack_target_count = drag_waypoint:get_attack_target_count()

                                                for i = 0, attack_target_count - 1, 1 do
                                                    local attack_target_vehicle_id = drag_waypoint:get_attack_target_target_id(i)

                                                    if attack_target_vehicle_id == g_highlighted.vehicle_id then
                                                        is_highlighted_vehicle_found = true
                                                        drag_vehicle:remove_waypoint_attack_target(g_drag.waypoint_id, i)
                                                        break
                                                    end
                                                end

                                                if is_highlighted_vehicle_found == false then
                                                    local highlighted_vehicle_id = highlighted_vehicle:get_id()

                                                    -- go to attack type context menu

                                                    g_selection:set_attack_target_vehicle(g_drag.vehicle_id, g_drag.waypoint_id, highlighted_vehicle_id)
                                                end
                                            else
                                                local highlighted_vehicle_id = highlighted_vehicle:get_id()

                                                -- go to attack type context menu

                                                g_selection:set_attack_target_vehicle(g_drag.vehicle_id, 0, highlighted_vehicle_id)
                                            end
                                        end
                                    end
                                else
                                    if g_drag.waypoint_id > 0 then
                                        local world_x, world_y = get_world_from_screen(g_cursor_pos_x, g_cursor_pos_y, g_camera_pos_x, g_camera_pos_y, g_camera_size, g_screen_w, g_screen_h)

                                        drag_vehicle:clear_waypoints_from(g_drag.waypoint_id)
                                        drag_vehicle:add_waypoint(world_x, world_y)
                                    elseif g_drag.vehicle_id > 0 then
                                        -- add waypoint to vehicle

                                        if get_is_vehicle_waypoint_available(drag_vehicle) then
                                            local world_x, world_y = get_world_from_screen(g_cursor_pos_x, g_cursor_pos_y, g_camera_pos_x, g_camera_pos_y, g_camera_size, g_screen_w, g_screen_h)

                                            drag_vehicle:clear_waypoints()
                                            drag_vehicle:clear_attack_target()
                                            drag_vehicle:add_waypoint(world_x, world_y)
                                        end
                                    end
                                end
                            end
                        end
                    end

                    g_drag:clear()
                end
            end
        end
    elseif g_screen_index == 1 then
        if action == e_input_action.release then
            if event == e_input.back then
                g_viewing_vehicle_id = 0
                g_screen_index = 0
            end
        end
    elseif g_screen_index == 2 then
        if action == e_input_action.release then
            if event == e_input.back then
                update_set_screen_state_exit()
            end
        end
        g_ui:input_event(event, action)
    end
end

function input_axis(x, y, z, w)
    if call_func_override("screen_vehicle_control__input_axis", x, y, z, w) then
        return
    end

    g_input_x = x
    g_input_y = y
    g_input_z = z
    g_input_w = w
end

function input_scroll(dy)
    if call_func_override("screen_vehicle_control__input_scroll", dy) then
        return
    end
    if g_is_pointer_hovered then
        input_zoom_camera(1 - dy * 0.15, g_screen_w, g_screen_h)
    end

    if g_selection:is_selection() then
        g_ui:input_scroll(dy)
    end
end

function input_pointer(is_hovered, x, y)

    if call_func_override("screen_vehicle_control__input_pointer", is_hovered, x, y) then
        return
    end
    g_is_pointer_hovered = is_hovered

    g_pointer_pos_x = x
    g_pointer_pos_y = y

    if g_selection:is_selection() then
        g_ui:input_pointer(is_hovered, x, y)
    end
end

function render_map_scale(screen_w, screen_h)
    if g_is_render_grid then
        local grid_spacing = get_grid_spacing()
        local text = iff( grid_spacing >= 1000, math.floor(grid_spacing / 1000) .. update_get_loc(e_loc.acronym_kilometers), math.floor(grid_spacing) .. update_get_loc(e_loc.acronym_meters) )

        local sx, _ = get_screen_from_world(0, 0, g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
        local ex, _ = get_screen_from_world(grid_spacing, 0, g_camera_pos_x, g_camera_pos_y, g_camera_size, screen_w, screen_h)
        local dx = ex - sx

        local inbound = true

        if dx > 175 then
            dx = 175
            inbound = false
        end

        update_ui_push_offset(screen_w - dx/2 - 15, screen_h - 20)

        local w = update_ui_get_text_size(text, 32, 0)
        update_ui_text(-w/2, -10, text, w, 1, color_grey_mid, 0)
        
        if inbound then
            update_ui_rectangle(-dx/2, 0, 1, 4, color_grey_dark)
            update_ui_rectangle(dx/2 - 1, 0, 1, 4, color_grey_dark)
        end

        update_ui_rectangle(0, 2, 1, 2, color_grey_dark)

        update_ui_rectangle(-dx/2, 4, dx, 1, color_grey_dark)

        update_ui_pop_offset()
    end
end

function render_cursor_info(screen_w, screen_h, world_pos_drag_start)
    -- render bearing/position information

    local cy = screen_h - iff(world_pos_drag_start, 55, 35)
    local cx = 15
    local world_x, world_y = get_world_from_screen(g_cursor_pos_x, g_cursor_pos_y, g_camera_pos_x, g_camera_pos_y, g_camera_size, g_screen_w, g_screen_h)
    local icon_col = color_grey_mid
    local text_col = color_grey_dark

    update_ui_text(cx, cy, "X", 100, 0, icon_col, 0)
    update_ui_text(cx + 15, cy, string.format("%.0f", world_x), 100, 0, text_col, 0)
    cy = cy + 10

    update_ui_text(cx, cy, "Y", 100, 0, icon_col, 0)
    update_ui_text(cx + 15, cy, string.format("%.0f", world_y), 100, 0, text_col, 0)
    cy = cy + 10

    if world_pos_drag_start then
        local dist =  vec2_dist(world_pos_drag_start, vec2(world_x, world_y))

        if dist < 10000 then
            update_ui_image(cx, cy, atlas_icons.column_distance, icon_col, 0)
            update_ui_text(cx + 15, cy, string.format("%.0f ", dist) .. update_get_loc(e_loc.acronym_meters), 100, 0, text_col, 0)
        else
            update_ui_image(cx, cy, atlas_icons.column_distance, icon_col, 0)
            update_ui_text(cx + 15, cy, string.format("%.2f ", dist / 1000) .. update_get_loc(e_loc.acronym_kilometers), 100, 0, text_col, 0)
        end

        cy = cy + 10

        local bearing = 90 - math.atan(world_y - world_pos_drag_start:y(), world_x - world_pos_drag_start:x()) / math.pi * 180

        if bearing < 0 then bearing = bearing + 360 end

        update_ui_image(cx, cy, atlas_icons.column_angle, icon_col, 0)
        update_ui_text(cx + 15, cy, string.format("%.0f deg", bearing), 100, 0, text_col, 0)
        cy = cy + 10
    end
end

function render_vehicle_tooltip(w, h, vehicle, peers)
    local screen_vehicle = update_get_screen_vehicle()
    local screen_team = update_get_screen_team_id()
    local vehicle_pos_xz = vehicle:get_position_xz()
    local vehicle_definition_index = vehicle:get_definition_index()
    local vehicle_team = vehicle:get_team()
    local vehicle_definition_name, vehicle_definition_region = get_chassis_data_by_definition_index(vehicle_definition_index)
    local vehicle_name = vehicle_definition_name

    local special_id = vehicle:get_special_id()

    if vehicle_definition_index == e_game_object_type.chassis_carrier then
        -- vehicle_name = get_ship_name(vehicle)
    else
        if special_id ~= 0 then
            vehicle_name = vehicle_name .. " (" .. special_id .. ")"
        end
    end

    local bar_h = 17
    local repair_factor = vehicle:get_repair_factor()
    local fuel_factor = vehicle:get_fuel_factor()
    local ammo_factor = vehicle:get_ammo_factor()
    local repair_bar = math.floor(repair_factor * bar_h)
    local fuel_bar = math.floor(fuel_factor * bar_h)
    local ammo_bar = math.floor(ammo_factor * bar_h)

    local cx = 2
    local cy = 2

    local team = vehicle:get_team()
    local color_inactive = color8(8, 8, 8, 255)

    if vehicle:get_is_observation_type_revealed() or get_is_spectator_mode() then
        update_ui_rectangle(cx + 0, cy, 1, bar_h, color8(16, 16, 16, 255))
        update_ui_rectangle(cx + 0, cy + bar_h - repair_bar, 1, repair_bar, color8(47, 116, 255, 255))
        update_ui_rectangle(cx + 2, cy, 1, bar_h, color8(16, 16, 16, 255))
        update_ui_rectangle(cx + 2, cy + bar_h - fuel_bar, 1, fuel_bar, color8(119, 85, 161, 255))
        update_ui_rectangle(cx + 4, cy, 1, bar_h, color8(16, 16, 16, 255))
        update_ui_rectangle(cx + 4, cy + bar_h - ammo_bar, 1, ammo_bar, color8(201, 171, 68, 255))
    else
        update_ui_rectangle(cx + 0, cy, 1, bar_h, color_inactive)
        update_ui_rectangle(cx + 2, cy, 1, bar_h, color_inactive)
        update_ui_rectangle(cx + 4, cy, 1, bar_h, color_inactive)
    end

    cx = cx + 6

    local display_id = ""
    if vehicle_definition_index == e_game_object_type.chassis_carrier then
        display_id = get_ship_name(vehicle)
    else
        display_id = update_get_loc(e_loc.upp_id) .. string.format( " %.0f", vehicle:get_id() )
    end

    if vehicle:get_is_observation_type_revealed() then

        update_ui_image(cx, 2, vehicle_definition_region, color_white, 0)
        cx = cx + 18

        update_ui_text(cx, 11, display_id, 124, 0, color_white, 0)

        update_ui_text(cx, 1, vehicle_name, 124, 0, color_white, 0)
        cx = cx + math.max(update_ui_get_text_size(display_id,   10000, 0),
                           update_ui_get_text_size(vehicle_name, 10000, 0)) + 2
    else
        update_ui_image(cx, 2, atlas_icons.icon_chassis_16_wheel_small, color_inactive, 0)
        cx = cx + 18

        update_ui_text(cx, 11, display_id, 124, 0, color_inactive, 0)

        vehicle_name = "***"
        update_ui_text(cx, 1, vehicle_name, 124, 0, color_inactive, 0)
        cx = cx + math.max(update_ui_get_text_size(display_id,   10000, 0),
                           update_ui_get_text_size(vehicle_name, 10000, 0)) + 2
    end

    if  vehicle_definition_index ~= e_game_object_type.chassis_carrier
--    and vehicle_definition_index ~= e_game_object_type.chassis_sea_ship_light
--    and vehicle_definition_index ~= e_game_object_type.chassis_sea_ship_heavy
    then
        -- if friendly air or land, show all full/empty main attachments in the tooltip
        if update_get_screen_team_id() == vehicle:get_team() and get_is_vehicle_air(vehicle_definition_index)
        then
            local a_x = cx

            -- render primary attachment icons in first 16w slot

            local attachments = {}

            for i = 0, vehicle:get_attachment_count() - 1 do
                local attachment_type = vehicle:get_attachment_type(i)
                if  attachment_type == e_game_object_attachment_type.hardpoint_large
                    or attachment_type == e_game_object_attachment_type.camera
                then
                    local attachment = vehicle:get_attachment(i)

                    if attachment:get() then
                        table.insert(attachments, attachment)
                    end
                end
            end

            if #attachments > 0 then
                local attachment_index = (math.floor( g_animation_time / 20 ) % (#attachments)) + 1
                local icon, icon_16 = get_attachment_icons(attachments[attachment_index]:get_definition_index())

                if icon_16 ~= nil then
                    update_ui_image(a_x, cy, icon_16, color_white, 0)
                end
            end
            a_x = a_x + 11


            for i = 0, vehicle:get_attachment_count() - 1 do
                local attachment_type = vehicle:get_attachment_type(i)
                if attachment_type == e_game_object_attachment_type.hardpoint_small then
                    local attachment = vehicle:get_attachment(i)

                    if attachment:get() then
                        local attachment_def = attachment:get_definition_index()
                        if attachment_def > 0 then
                            local a_w = 11
                            if attachment_type == e_game_object_attachment_type.hardpoint_small then
                                a_w = 7
                            end
                            local icon, icon_16 = get_attachment_icons(attachment_def)
                            if icon_16 ~= nil then
                                local a_col = color_grey_mid
                                if attachment:get_ammo_factor() == 0 then
                                    a_col = color_status_dark_red
                                end
                                if a_x < w - 16 then
                                    update_ui_image(a_x, cy, icon_16, a_col, 0)
                                    a_x = a_x + a_w
                                end
                            end
                        end
                    end
                end
            end

        elseif vehicle:get_is_observation_weapon_revealed() then
            -- render primary attachment icon

            local attachments = {}

            for i = 0, vehicle:get_attachment_count() - 1 do
                local attachment_type = vehicle:get_attachment_type(i)
                if  attachment_type ~= e_game_object_attachment_type.plate_small
                and attachment_type ~= e_game_object_attachment_type.plate_small_inverted then
                    local attachment = vehicle:get_attachment(i)

                    if attachment:get() then
                        table.insert(attachments, attachment)
                    end
                end
            end

            if #attachments > 0 then
                local attachment_index = (math.floor( g_animation_time / 20 ) % (#attachments)) + 1
                local icon, icon_16 = get_attachment_icons(attachments[attachment_index]:get_definition_index())

                if icon_16 ~= nil then
                    update_ui_image(cx, cy, icon_16, color_white, 0)
                end
            end
        else
            update_ui_image(cx, cy, atlas_icons.icon_attachment_16_unknown, color_inactive, 0)
        end
    end

    if vehicle:get_is_observation_fully_revealed() == false then
        local data_factor = vehicle:get_observation_factor()
        update_ui_text(0, 6, string.format("%.0f%%", data_factor * 100), w - 2, 2, color_inactive, 0)
    end

    if team == update_get_screen_team_id() then
        cx = w - 12

        if get_is_vehicle_enterable(vehicle) then
            update_ui_image(cx, 6, atlas_icons.column_transit, color_highlight, 0)
            cx = cx - 8
        end

        if get_is_vehicle_air(vehicle_definition_index) then
            local vehicle_attachment_count = vehicle:get_vehicle_attachment_count()

            if vehicle_attachment_count > 0 then
                local is_vehicle_attached = false

                for i = 0, vehicle_attachment_count do
                    if vehicle:get_attached_vehicle_id(i) ~= 0 then
                        is_vehicle_attached = true
                        break
                    end
                end

                if is_vehicle_attached then
                    update_ui_image(cx, 7, atlas_icons.icon_attack_type_airlift, color_status_ok, 0)
                    cx = cx - 8
                end
            end
        end
    end

    cx = 2
    cy = 20
    for i = 1, #peers do
        local peer = peers[i]
        local peer_name = peer.name

        local max_text_chars = 19
        local is_clipped = false

        if utf8.len(peer_name) > max_text_chars then
            peer_name = peer_name:sub(1, utf8.offset(peer_name, max_text_chars) - 1)
            is_clipped = true
        end

        local text_render_w, text_render_h = update_ui_get_text_size(peer_name, w, 0)

        if peer.ctrl then
            update_ui_image( cx, cy, atlas_icons.column_controlling_peer, color_white, 0)
        end

        update_ui_text(cx + 10, cy, peer_name, text_render_w, 0, color_white, 0)

        if is_clipped then
            update_ui_image(cx + 10 + text_render_w, cy, atlas_icons.text_ellipsis, color_white, 0)
        end

        cy = cy + 10
    end

    if get_is_vehicle_air(vehicle:get_definition_index()) then
        local alt = get_unit_altitude(vehicle)
        local fl_str = string.format("F%03d", math.floor(alt / 10))
        update_ui_text(cx + 10, cy, fl_str, 32, 0, color_inactive, 0)
    end
end

function get_is_vehicle_enterable(vehicle)
    if not g_revolution_control_units then
        return false
    end

    local screen_vehicle = update_get_screen_vehicle()

    if screen_vehicle:get() and vehicle:get() then
        local team = vehicle:get_team()
        local def = vehicle:get_definition_index()

        if get_is_spectator_mode() or team == update_get_screen_team_id() and def ~= e_game_object_type.chassis_carrier and def ~= e_game_object_type.chassis_land_robot_dog then
            return true
        end
    end

    return false
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

function get_vehicle_weapon_range(vehicle)
    if vehicle:get_definition_index() == e_game_object_type.chassis_land_wheel_mule then
        return 50, color8(0, 255, 128, 8)
    else
        local attachment_count = vehicle:get_attachment_count()
        local weapon_range = 0

        for i = 0, attachment_count - 1 do
            local attachment = vehicle:get_attachment(i)

            if attachment:get() then
                weapon_range = math.max(attachment:get_weapon_range(), weapon_range)
            end
        end

        return weapon_range, color8(32, 8, 8, 64)
    end
end

function get_is_vehicle_droid_deploy_available(vehicle)
    local attachment_count = vehicle:get_attachment_count()

    for i = 0, attachment_count - 1 do
        local attachment = vehicle:get_attachment(i)

        if attachment:get() then
            if attachment:get_definition_index() == e_game_object_type.attachment_deployable_droid and attachment:get_ammo_remaining() > 0 then
                return true
            end
        end
    end

    return false
end

function get_is_vehicle_robot_dog_deploy_available(vehicle)
    local attachment_count = vehicle:get_attachment_count()

    for i = 0, attachment_count - 1 do
        local attachment = vehicle:get_attachment(i)

        if attachment:get() then
            if attachment:get_definition_index() == e_game_object_type.attachment_turret_robot_dog_capsule and attachment:get_ammo_remaining() > 0 then
                return true
            end
        end
    end

    return false
end

function get_vehicle_has_robot_dogs(vehicle)
    if get_is_vehicle_land(vehicle:get_definition_index()) then
        local attachment_count = vehicle:get_attachment_count()

        for i = 0, attachment_count - 1 do
            local attachment = vehicle:get_attachment(i)

            if attachment:get() then
                if attachment:get_definition_index() == e_game_object_type.attachment_turret_robot_dog_capsule then
                    return true, attachment
                end
            end
        end
    end

    return false, nil
end

function get_vehicle_logistics_capabilities(vehicle)
    local is_ammo = false
    local is_fuel = false

    if vehicle:get_definition_index() == e_game_object_type.chassis_land_wheel_mule then
        local attachment_count = vehicle:get_attachment_count()

        for i = 0, attachment_count - 1 do
            local attachment = vehicle:get_attachment(i)

            if attachment:get() then
                if is_ammo == false and attachment:get_ammo_remaining() > 0 then
                    is_ammo = true
                end

                if is_fuel == false and attachment:get_fuel_remaining() > 0 then
                    is_fuel = true
                end
            end
        end
    end

    return is_ammo, is_fuel
end

function get_is_render_ammo_indicator(vehicle)
    local definition_index = vehicle:get_definition_index()
    return definition_index ~= e_game_object_type.chassis_land_turret
end

function get_is_render_fuel_indicator(vehicle)
    local definition_index = vehicle:get_definition_index()
    return definition_index ~= e_game_object_type.chassis_land_turret
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

function get_grid_spacing()
    local grid_spacing = 500
    local camera_size = g_camera_size

    while camera_size > 2000 and grid_spacing < 16000 do
        camera_size = camera_size / 2
        grid_spacing = grid_spacing * 2
    end

    return grid_spacing
end

function get_is_map_movement_allowed()
    return g_selection:is_selection() == false
        or g_selection.command_center_id > 0 and g_command_center_ui.is_place_turret
end

function get_is_collapse_islands()
    return (g_camera_size > (64 * 1024))
end

function get_is_placing_turret()
    return g_selection.command_center_id > 0 and g_command_center_ui.is_place_turret
end

function get_is_highlighting_dragged_item()
    for k, v in pairs(g_drag) do
        if type(v) ~= "function" then
            if g_highlighted[k] ~= nil and g_highlighted[k] ~= v then
                return false
            end
        end
    end

    return true
end

function purchase_turret(item, island_id, turret_spawn_index)
    local island = update_get_tile_by_id(island_id)

    if island:get() then
        local marker_index, is_valid = island:get_turret_spawn(turret_spawn_index)

        if is_valid then
            island:set_facility_add_production_queue_defense_item(item, marker_index)
        else
            cancel_queued_island_turret(island, marker_index)
        end
        if not g_command_center_ui.is_place_turret_many then
            g_command_center_ui.is_place_turret = false
            g_command_center_ui.is_place_turret_many = false
            g_command_center_ui.selected_item = -1
            g_selection:clear()
        end
    else
        g_command_center_ui.is_place_turret = false
        g_command_center_ui.selected_item = -1
        g_selection:clear()
    end
end

function render_currency_display(x, y, is_active)
    local currency = 0
    local team = update_get_team(update_get_screen_team_id())

    if team:get() then
        currency = team:get_currency()
    end

    local col = iff(is_active, iff(currency > 0, color_status_ok, color_status_bad), color_grey_dark)
    local text_w, text_h = update_ui_get_text_size(tostring(currency), 100, 2)

    update_ui_push_offset(x, y)
    update_ui_image(-text_w - 9, 0, atlas_icons.column_currency, col, 0)
    update_ui_text(-100, 0, tostring(currency), 100, 2, col, 0)
    update_ui_pop_offset()
end

function get_is_vehicle_waypoint_available(vehicle)
    if not g_revolution_control_units then
        return false
    end
    if (vehicle:get_dock_state() == e_vehicle_dock_state.docking and vehicle:get_attached_parent_id() ~= 0) or vehicle:get_dock_state() == e_vehicle_dock_state.docking_taxi then
        return false
    end

    return true
end

-- tactical hover mode for ptr
g_last_hover_check = 0
g_tactical_cooldown = 0
g_tactical_dropping = false
g_tactical_lifting = false

function tactical_hover_check(vehicle)
    local tick = update_get_logic_tick()
    if tick - g_last_hover_check > 60 then

        -- handle early lift/drop
        if g_tactical_vid > 0 and (g_tactical_dropping or g_tactical_lifting) then
            if vehicle_has_cargo(vehicle) then
                g_tactical_lifting = false
            else
                g_tactical_dropping = false
            end
            if not g_tactical_lifting and not g_tactical_dropping then
                -- nothing to do, cancel tactical mode
                g_tactical_vid = 0
            end
        end

        if g_tactical_cooldown > 0 then
            g_tactical_cooldown = g_tactical_cooldown - 1
            return
        end

        g_last_hover_check = tick
        if vehicle and vehicle:get() then
            if vehicle:get_id() == g_tactical_vid then
                if g_tactical_dropping then
                    g_tactical_lifting = false
                    -- ordered to drop next
                    if vehicle_has_cargo(vehicle) then
                        local ptr_alt = get_unit_altitude(vehicle)
                        if ptr_alt < 70 then
                            set_airdrop_now(vehicle)
                            g_tactical_cooldown = 60
                            return
                        end
                    else
                        g_tactical_dropping = false
                        g_tactical_vid = 0
                    end
                end

                if g_tactical_lifting then
                    g_tactical_dropping = false
                    -- ordered to lift next
                    if vehicle_has_cargo(vehicle) then
                        g_tactical_lifting = false
                        g_tactical_vid = 0
                    else
                        local nearest_id, nearest_range = get_nearest_friendly_airliftable_id(vehicle, 150)
                        if nearest_id > 0 and nearest_range < 8 then
                            -- get actual alt difference of both
                            local nearest = update_get_map_vehicle_by_id(nearest_id)
                            if nearest and nearest:get() then
                                local ptr_alt = get_unit_altitude(vehicle)
                                local lift_alt = get_unit_altitude(nearest)
                                if ptr_alt - lift_alt < 50 then
                                    set_airlift_now(vehicle, nearest_id)
                                    g_tactical_cooldown = 60
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function control_screen_from_world(wx, wy, sw, sh)
    return get_screen_from_world(wx, wy, g_camera_pos_x, g_camera_pos_y, g_camera_size, g_screen_w, g_screen_h)
end

function update_world_line(x1, y1, x2, y2, col)
    local ax, ay = get_screen_from_world(x1, y1, g_camera_pos_x, g_camera_pos_y, g_camera_size, g_screen_w, g_screen_h)
    local bx, by = get_screen_from_world(x2, y2, g_camera_pos_x, g_camera_pos_y, g_camera_size, g_screen_w, g_screen_h)
    update_ui_line(ax, ay, bx, by, col)
end

function update_world_triangle(ax, ay, bx, by, cx, cy, col)
    update_ui_begin_triangles()
    local ax, ay = get_screen_from_world(ax, ay, g_camera_pos_x, g_camera_pos_y, g_camera_size, g_screen_w, g_screen_h)
    local bx, by = get_screen_from_world(bx, by, g_camera_pos_x, g_camera_pos_y, g_camera_size, g_screen_w, g_screen_h)
    local cx, cy = get_screen_from_world(cx, cy, g_camera_pos_x, g_camera_pos_y, g_camera_size, g_screen_w, g_screen_h)

    update_ui_add_triangle(vec2(ax, ay), vec2(bx, by), vec2(cx, cy), col)
    update_ui_end_triangles()
end
