g_screen_index = 0
g_selected_bay_index = 0
g_selected_attachment_index = 0
g_selected_option_index = 0
g_animation_time = 0
g_no_stock_counter = 1000

g_attachment_combo_scroll = -1
g_chassis_combo_scroll = -1

g_ui = nil

g_screen_vehicle_id = 1
g_managed_vehicle = 0

function get_bay_name(index)
    if index >= 8 then
        return update_get_loc(e_loc.upp_acronym_air) .. (index - 7)
    else
        return update_get_loc(e_loc.upp_acronym_surface) .. (index + 1)
    end

    return update_get_loc(e_loc.upp_acronym_surface) .. "1"
end

function get_selected_chassis_options(bay_index)
    local selection_options = {}
    local is_ground = bay_index < 8

    if is_ground then
        selection_options = {
            { region=atlas_icons.icon_attachment_16_none, type=-1 },
            { region=atlas_icons.icon_chassis_16_wheel_small, type=e_game_object_type.chassis_land_wheel_light },
            { region=atlas_icons.icon_chassis_16_wheel_medium, type=e_game_object_type.chassis_land_wheel_medium },
            { region=atlas_icons.icon_chassis_16_wheel_large, type=e_game_object_type.chassis_land_wheel_heavy },
            { region=atlas_icons.icon_chassis_16_wheel_mule, type=e_game_object_type.chassis_land_wheel_mule },
        }

        if g_rev_allow_carrier_land_turrets or get_is_spectator_mode() then
            table.insert(
                    selection_options,
                    { region=atlas_icons.icon_chassis_16_land_turret, type=e_game_object_type.chassis_land_turret })
        end

    else
        selection_options = {
            { region=atlas_icons.icon_attachment_16_none, type=-1 },
            { region=atlas_icons.icon_chassis_16_wing_small, type=e_game_object_type.chassis_air_wing_light },
            { region=atlas_icons.icon_chassis_16_wing_large, type=e_game_object_type.chassis_air_wing_heavy },
            { region=atlas_icons.icon_chassis_16_rotor_small, type=e_game_object_type.chassis_air_rotor_light },
            { region=atlas_icons.icon_chassis_16_rotor_large, type=e_game_object_type.chassis_air_rotor_heavy }
        }
    end

    return selection_options
end

function get_selected_vehicle_attachment_extra_options(vehicle, attachment_index)
    local attachment_type = vehicle:get_attachment_type(attachment_index)
    local attachment_options = get_selected_vehicle_attachment_options(attachment_type)

    local function add_attachment_option(attachment_table, attachment_definition)
        local attachment_data = get_attachment_data_by_definition_index(attachment_definition)

        table.insert(attachment_table, {
            region = attachment_data.icon16,
            type = attachment_definition
        })
    end

    local restricted = {
        { region=atlas_icons.icon_attachment_16_none, type=-1 }
    }

    local override = get_override_vehicle_loadout_options(vehicle, attachment_index)
    if override ~= nil then
        for _, a_type in ipairs(override) do
            add_attachment_option(restricted, a_type)
        end
        return restricted
    end

    return attachment_options
end

function get_selected_vehicle_attachment_options(attachment_type)
    local attachment_options = {
        { region=atlas_icons.icon_attachment_16_none, type=-1 }
    }

    local option_count = update_get_attachment_option_count(attachment_type)

    for i = 0, option_count - 1 do
        local attachment_definition = update_get_attachment_option(attachment_type, i)

        if attachment_definition > -1 and update_get_attachment_option_hidden(attachment_definition) == false then
            local attachment_data = get_attachment_data_by_definition_index(attachment_definition)

            table.insert(attachment_options, {
                region = attachment_data.icon16,
                type = attachment_definition
            })
        end
    end

    return attachment_options
end

function parse()
    g_screen_index = parse_s32("", g_screen_index)
    g_selected_bay_index = parse_s32("", g_selected_bay_index)
    g_selected_attachment_index = parse_s32("", g_selected_attachment_index)
    g_selected_option_index = parse_s32("", g_selected_option_index)
end

g_screen_name = nil

function begin()
    begin_load()
    begin_load_inventory_data()
    g_ui = lib_imgui:create_ui()
    g_screen_name = begin_get_screen_name()
end

g_sanitised_attachments = false

function is_screen_vehicle()
    return g_managed_vehicle == g_screen_vehicle_id
end

function get_managed_vehicle()
    local this_vehicle = update_get_screen_vehicle()
    if this_vehicle:get() == false then return nil end
    g_screen_vehicle_id = this_vehicle:get_id()
    if g_managed_vehicle == 0 then
        g_managed_vehicle = g_screen_vehicle_id
    end
    if g_managed_vehicle ~= g_screen_vehicle_id then
        this_vehicle = update_get_map_vehicle_by_id(g_managed_vehicle)
    end
    return this_vehicle
end

function update(screen_w, screen_h, ticks)
    local st, err = pcall(_update, screen_w, screen_h, ticks)
    if not st then
        print(err)
    end
end


function _update(screen_w, screen_h, ticks)
    if update_screen_overrides(screen_w, screen_h, ticks)  then return end

    if g_no_stock_counter < 1000 then
        g_no_stock_counter = g_no_stock_counter + 1
    end
    g_animation_time = g_animation_time + ticks

    local this_vehicle = get_managed_vehicle()
    local header_col = color_white
    if not is_screen_vehicle() then
        header_col = color_friendly
    end

    if g_screen_name == "screen_inv_r" and not g_sanitised_attachments then
        g_sanitised_attachments = true

        if this_vehicle:get_definition_index() == e_game_object_type.chassis_carrier then
            g_sanitised_attachments = true
            sanitise_loadout(this_vehicle, 0)
            sanitise_loadout(this_vehicle, 1)
            sanitise_loadout(this_vehicle, 2)
            sanitise_loadout(this_vehicle, 3)
            sanitise_loadout(this_vehicle, 4)
            sanitise_loadout(this_vehicle, 5)
            sanitise_loadout(this_vehicle, 6)
            sanitise_loadout(this_vehicle, 7)
            sanitise_loadout(this_vehicle, 8)
            sanitise_loadout(this_vehicle, 9)
            sanitise_loadout(this_vehicle, 10)
            sanitise_loadout(this_vehicle, 11)
            sanitise_loadout(this_vehicle, 12)
            sanitise_loadout(this_vehicle, 13)
            sanitise_loadout(this_vehicle, 14)
            sanitise_loadout(this_vehicle, 15)
            -- find docked carrier
        end
        if get_vehicle_docked(this_vehicle) then
            local drydock = find_team_drydock(this_vehicle:get_team())
            if drydock and drydock.set_attached_vehicle_attachment then
                -- attach the VLS
                local slots = this_vehicle:get_attachment_count()
                if slots >= 18 then
                    -- has laser VLS
                    local a14 = this_vehicle:get_attachment(14)
                    if a14:get_definition_index() == -1 then
                        drydock:set_attached_vehicle_attachment(0, 14, e_game_object_type.attachment_hardpoint_missile_laser)
                        drydock:set_attached_vehicle_attachment(0, 15, e_game_object_type.attachment_hardpoint_missile_laser)
                        drydock:set_attached_vehicle_attachment(0, 16, e_game_object_type.attachment_hardpoint_missile_laser)
                        drydock:set_attached_vehicle_attachment(0, 17, e_game_object_type.attachment_hardpoint_missile_laser)
                    end
                end
            end
        end
    end

    if call_custom_vehicle_loadout_update(screen_w, screen_h, ticks) then
        return
    end

    local ui = g_ui

    ui:begin_ui()

    if g_screen_index == 0 then
        local window = ui:begin_window("##bay", 0, 0, screen_w, screen_h, nil, true, 1)
        local region_w, region_h = ui:get_region()

        update_ui_rectangle(0, 0, region_w, 14, header_col)
        update_ui_rectangle(region_w / 2, 0, 1, region_h, color_white)
        local this_vehicle_def = this_vehicle:get_definition_index()

        local text = ""
        if this_vehicle_def == e_game_object_type.chassis_carrier then
            text = string.format("CRR %s", get_ship_name(this_vehicle))
        else
            vehicle_definition_name, region_vehicle_icon, vehicle_definition_abreviation, vehicle_definition_description = get_chassis_data_by_definition_index(this_vehicle_def)
            text = string.format("%s %d", vehicle_definition_abreviation, this_vehicle:get_id())
        end

        update_ui_text(4, 4, text, 90, 0, color_black, 0)

        window.cy = window.cy + 15
        local selected_bay_index, is_pressed = imgui_carrier_docking_bays(ui, this_vehicle, 4, 10, g_animation_time)

        update_add_ui_interaction_special(update_get_loc(e_loc.interaction_navigate), e_ui_interaction_special.gamepad_dpad_all)

        local attached_vehicle = update_get_map_vehicle_by_id(this_vehicle:get_attached_vehicle_id(selected_bay_index))

        if selected_bay_index ~= -1 then
            if attached_vehicle:get() == false or attached_vehicle:get_dock_state() == e_vehicle_dock_state.docked then
                update_add_ui_interaction(update_get_loc(e_loc.interaction_select), e_game_input.interact_a)
            end
        end

        if is_pressed and selected_bay_index ~= -1 then
            if attached_vehicle:get() == false or attached_vehicle:get_dock_state() == e_vehicle_dock_state.docked then
                g_screen_index = 1
                g_selected_bay_index = selected_bay_index
            end
        end

        ui:end_window()
    else
        update_add_ui_interaction(update_get_loc(e_loc.interaction_back), e_game_input.back)

         -- title

        update_ui_rectangle(0, 0, screen_w, 14, color_white)
        update_ui_text(4, 4, get_bay_name(g_selected_bay_index), screen_w, 0, color_black, 0)

        -- mini toolbar
        local attached_vehicle = update_get_map_vehicle_by_id(this_vehicle:get_attached_vehicle_id(g_selected_bay_index))
        if attached_vehicle:get() and attached_vehicle:get_dock_state() == e_vehicle_dock_state.docked then
            local attached_vehicle_def = attached_vehicle:get_definition_index()
            local toolbar_w = 64
            local bs = 8
            local bcount = 0

            ui:begin_window("##tb", screen_w - 3 - toolbar_w, 3, toolbar_w, 18, nil, true, 1)

            function add_preset_btn(icon, tooltip, callback)
                bcount = bcount + 1
                if ui:img_button(
                    icon,
                    toolbar_w - bs*(bcount), 0,
                    bs, bs,
                    true, color_status_dark_green, tooltip
                ) then
                    callback()
                end
            end

            add_preset_btn(atlas_icons.map_icon_unload, "Remove Attachments",
                    function()
                        rev_remove_all_docked_attachments(this_vehicle, g_selected_bay_index)
                    end)

            if rev_has_preconfigure_preset(this_vehicle, g_selected_bay_index, "defender") then
                add_preset_btn(atlas_icons.column_difficulty, "Defender",
                function()
                    rev_set_preconfigure_attachments(this_vehicle, g_selected_bay_index, "defender")
                end)
            end

            if rev_has_preconfigure_preset(this_vehicle, g_selected_bay_index, "strike") then
                add_preset_btn(atlas_icons.column_laser, "Strike",
                function()
                    rev_set_preconfigure_attachments(this_vehicle, g_selected_bay_index, "strike")
                end)
            end

            if rev_has_preconfigure_preset(this_vehicle, g_selected_bay_index, "refuel") then
                add_preset_btn(atlas_icons.icon_fuel, "Refuel",
                function()
                    rev_set_preconfigure_attachments(this_vehicle, g_selected_bay_index, "refuel")
                end)
            end

            if rev_has_preconfigure_preset(this_vehicle, g_selected_bay_index, "capture") then
                add_preset_btn(atlas_icons.column_team_control, "Capture",
                function()
                    rev_set_preconfigure_attachments(this_vehicle, g_selected_bay_index, "capture")
                end)
            end

            ui:end_window()
        end

        -- dividers

        update_ui_rectangle(0, 92, screen_w, 1, color_white)

        local attached_vehicle = update_get_map_vehicle_by_id(this_vehicle:get_attached_vehicle_id(g_selected_bay_index))
        local is_show_attachment_selector = false

        if attached_vehicle:get() and attached_vehicle:get_dock_state() ~= e_vehicle_dock_state.docked then
            g_screen_index = 0
            g_selected_bay_index = 0
        end

        if g_screen_index == 1 then
            -- vehicle loadout
            
            g_selected_option_index = 0

            if attached_vehicle:get() then
                update_add_ui_interaction_special(update_get_loc(e_loc.interaction_navigate), e_ui_interaction_special.gamepad_dpad_all)

                local vehicle_definition_index = attached_vehicle:get_definition_index()
                local vehicle_attachment_count = attached_vehicle:get_attachment_count()
                local vehicle_definition_name, vehicle_definition_icon, vehicle_definition_handle = get_chassis_data_by_definition_index(vehicle_definition_index)

                update_ui_rectangle(63, 14, 1, 78, color_white)

                local total_hitpoints, armour, mass = update_get_definition_vehicle_stats(vehicle_definition_index)
                local cy = 16

                update_ui_image(4, cy, atlas_icons.column_difficulty, color_grey_mid, 0)
                update_ui_text(13, cy, armour, 64, 0, color_grey_dark, 0)
                cy = cy + 10
                if rev_get_unit_has_payload_limit(attached_vehicle) then
                    local payload_remain = rev_get_payload_remaining(attached_vehicle)
                    update_ui_image(4, cy, atlas_icons.column_weight, color_grey_mid, 0)
                    update_ui_text(13, cy, string.format("%d %s", payload_remain, update_get_loc(e_loc.upp_kg)), 64, 0, color_grey_dark, 0)
                    cy = cy + 11
                end

                update_ui_rectangle(0, cy, 63, 1, color_grey_dark)
                cy = cy + 4

                update_ui_image(4, cy, atlas_icons.icon_health, color_white, 0)
                update_ui_text(13, cy, string.format("%.0f%%", attached_vehicle:get_repair_factor() * 100), 64, 0, color_status_ok, 0)
                cy = cy + 10

                update_ui_image(4, cy, atlas_icons.icon_fuel, color_white, 0)
                update_ui_text(13, cy, string.format("%.0f%%", attached_vehicle:get_fuel_factor() * 100), 64, 0, color_status_ok, 0)
                cy = cy + 10

                update_ui_image(4, cy, atlas_icons.icon_ammo, color_white, 0)
                update_ui_text(13, cy, string.format("%.0f%%", attached_vehicle:get_ammo_factor() * 100), 64, 0, color_status_ok, 0)

                cy = cy + 10

                call_custom_ui_vehicle_loadout_chassis(ui, attached_vehicle)

                local window = ui:begin_window("##vehicle", screen_w / 2, 14, screen_w / 2, screen_h - 14, nil, true, 1)
                    local region_w, region_h = ui:get_region()

                    if ui:button(vehicle_definition_name, true, 1) then
                        g_screen_index = 3
                    end

                    window.cy = window.cy - 1
                    g_selected_attachment_index, is_pressed = imgui_vehicle_chassis_loadout(ui, attached_vehicle)
                    
                    if is_pressed then
                        g_screen_index = 2
                    end
                ui:end_window()

                if g_hovered_attachment > -1 then
                    local attachment = attached_vehicle:get_attachment(g_hovered_attachment)

                    if attachment:get() then
                        local attachment_definition_index = attachment:get_definition_index()
                        if attachment_definition_index > 0 then
                            local attachment_data = get_attachment_data_by_definition_index(attachment_definition_index)
                            -- update_ui_text(4, 93, g_hovered_attachment .. " " .. attachment_data.name_short, 96, 0, color_grey_mid, 0)
                        end
                    end
                end
                
                is_show_attachment_selector = window.selected_index_y > 0

                -- update selected option to match current selection

                if is_show_attachment_selector then
                    local attachment = attached_vehicle:get_attachment(g_selected_attachment_index)

                    if attachment:get() then
                        local attachment_definition = attachment:get_definition_index()
                        local selection_options = get_selected_vehicle_attachment_extra_options(attached_vehicle, g_selected_attachment_index)

                        for i = 1, #selection_options do
                            if attachment_definition == selection_options[i].type then
                                g_selected_option_index = i - 1
                                break
                            end
                        end
                    end
                else
                    local selection_options = get_selected_chassis_options(g_selected_bay_index)

                    for i = 1, #selection_options do
                        if vehicle_definition_index == selection_options[i].type then
                            g_selected_option_index = i - 1
                            break
                        end
                    end
                end
            else
                ui:begin_window("##vehicle", 0, 14, screen_w, screen_h - 14, nil, true, 1)
                    if ui:button(update_get_loc(e_loc.upp_select_chassis), true, 1) then
                        g_screen_index = 3
                    end
                ui:end_window()
            end

            if is_show_attachment_selector then
                render_screen_attachment(screen_w, screen_h, this_vehicle, attached_vehicle, false)
            else
                render_screen_chassis(screen_w, screen_h, this_vehicle, false)
            end
        elseif g_screen_index == 2 then
            update_add_ui_interaction(update_get_loc(e_loc.interaction_cancel), e_game_input.back)
            render_screen_attachment(screen_w, screen_h, this_vehicle, attached_vehicle, true)
        elseif g_screen_index == 3 then
            update_add_ui_interaction(update_get_loc(e_loc.interaction_cancel), e_game_input.back)
            render_screen_chassis(screen_w, screen_h, this_vehicle, true)
        elseif g_screen_index == 4 then
            -- choose to manage another unit
            update_add_ui_interaction(update_get_loc(e_loc.interaction_cancel), e_game_input.back)
            render_screen_chooser(screen_w, screen_h, true)
        end
    end

    ui:end_ui()
end

function input_event(event, action)
    g_ui:input_event(event, action)
    call_custom_vehicle_input_event(event, action)
    if action == e_input_action.press then
        if g_screen_index == 0 then
            if event == e_input.back then
                update_set_screen_state_exit()
            end
            if event == e_input.pointer_1 then
                if g_pointer_pos_y < 10 then
                    g_screen_index = 4
                end
            end
        elseif g_screen_index == 1 then
            if event == e_input.back then
                g_screen_index = 0
            end
        elseif g_screen_index == 2 then
            if event == e_input.back then
                g_screen_index = 1
            end
        elseif g_screen_index == 3 then
            if event == e_input.back then
                g_screen_index = 1
            end
        elseif g_screen_index == 4 then
            if event == e_input.back then
                g_screen_index = 0
            end
        end
    end
end

g_pointer_pos_x = 0
g_pointer_pos_y = 0

function input_pointer(is_hovered, x, y)
    g_ui:input_pointer(is_hovered, x, y)
    g_pointer_pos_x = x
    g_pointer_pos_y = y
end

function input_scroll(dy)
    g_ui:input_scroll(dy)
end

function input_axis(x, y, z, w)
end

function render_screen_attachment(screen_w, screen_h, this_vehicle, attached_vehicle, is_active)   
    local ui = g_ui
    local block_attachment = false

    if attached_vehicle:get() then
        if g_selected_attachment_index ~= -1 then
            local attachment_type = attached_vehicle:get_attachment_type(g_selected_attachment_index)
            local selection_options = get_selected_vehicle_attachment_extra_options(attached_vehicle, g_selected_attachment_index)

            local button_w = iff(attachment_type == e_game_object_attachment_type.plate_logistics_container, 20, 16)

            local function render_attachment_option(item, is_active, is_selected)
                local btn_bg_col = color_button_bg
                if not rev_check_attachment_exceeds_payload(attached_vehicle, g_selected_attachment_index, item.type) then
                    btn_bg_col = color_status_orange
                    if rev_get_unit_has_hard_payload_limit(attached_vehicle) then
                        btn_bg_col = color_status_dark_red
                    end
                end

                render_button_bg(1, 0, button_w, 25, iff(is_active, iff(is_selected, color_highlight, btn_bg_col), color_button_bg_inactive), 1)

                local txt = nil
                local icon = item.region
                local ammo_type = update_get_attachment_ammo_item_type(item.type)
                local ammo_divide = 1

                local icon_w = update_ui_get_image_size(icon)
                update_ui_image((button_w - icon_w) / 2 + 1, 0, icon, iff(is_active, iff(is_selected, color_white, color_black), color_black), 0)
                if txt ~= nil then
                    update_ui_text(8, 6, txt, 12, 0, color_black, 0)
                end

                if item ~= selection_options[1] then
                    if update_get_resource_item_for_definition(item.type) ~= -1 then
                        update_ui_text(1, 16, this_vehicle:get_inventory_count_by_definition_index(item.type), button_w, 1, color_black, 0)
                    else
                        if ammo_type ~= -1 then
                            local ammo = this_vehicle:get_inventory_count_by_item_index(ammo_type)
                            if ammo < 1000 then
                                update_ui_text(1, 16, format_ammo_quantity(math.min( ammo / ammo_divide, 99000)), button_w, 1, color_black, 0)
                            end
                        end
                    end
                end
            end

            if is_active then
                if selection_options[g_selected_option_index + 1] ~= nil and selection_options[g_selected_option_index + 1].type > -1 then
                    render_ui_attachment_definition_description(4, 17, screen_w - 8, screen_h, this_vehicle, selection_options[g_selected_option_index + 1].type, attached_vehicle)
                else
                    update_ui_text(4, 17, update_get_loc(e_loc.upp_clear), 60, 0, color_white, 0)
                end
            else
                g_attachment_combo_scroll = -1
            end

            ui:begin_window(update_get_loc(e_loc.attachment).."##attachment", 0, 95, screen_w, screen_h - 95, nil, is_active, 1)
                g_selected_option_index, g_attachment_combo_scroll, is_pressed = imgui_combo_custom(ui, g_selected_option_index, selection_options, button_w + 2, 25, g_attachment_combo_scroll, render_attachment_option)

                if is_pressed then  
                    local definition_index = selection_options[g_selected_option_index + 1].type
                    local inventory_item_type = update_get_resource_item_for_definition(definition_index)

                    local current_attachment = attached_vehicle:get_attachment(g_selected_attachment_index)
                    local new_attachment_type = selection_options[g_selected_option_index + 1].type
                    local current_attachment_type = -1
                    if current_attachment and current_attachment:get() then
                        current_attachment_type = current_attachment:get_definition_index()
                    end

                    if rev_before_add_attachment(this_vehicle, g_selected_bay_index, g_selected_attachment_index, new_attachment_type) then
                        if g_selected_option_index == 0 then
                            this_vehicle:set_attached_vehicle_attachment(g_selected_bay_index, g_selected_attachment_index, -1)
                            g_screen_index = 1
                        elseif inventory_item_type == -1 or this_vehicle:get_inventory_count_by_definition_index(definition_index) > 0 then
                            this_vehicle:set_attached_vehicle_attachment(g_selected_bay_index, g_selected_attachment_index, new_attachment_type)
                            g_screen_index = 1
                        else
                            g_no_stock_counter = 0
                        end
                    end
                end
            ui:end_window()
        end

        render_no_stock_indicator(4, 79, screen_w - 8)
    end
end

function render_screen_chassis(screen_w, screen_h, this_vehicle, is_active)
    local ui = g_ui
    local selection_options = get_selected_chassis_options(g_selected_bay_index)

    local function render_chassis_option(item, is_active, is_selected)
        render_button_bg(1, 0, 16, 25, iff(is_active, iff(is_selected, color_highlight, color_button_bg), color_button_bg_inactive), 1)
        update_ui_image(1, 0, item.region, iff(is_active, iff(is_selected, color_white, color_black), color_black), 0)

        if item ~= selection_options[1] then
            update_ui_text(1, 16, this_vehicle:get_inventory_count_by_definition_index(item.type), 16, 1, color_black, 0)
        end
    end

    if is_active then
        if selection_options[g_selected_option_index + 1].type > -1 then
            render_ui_chassis_definition_description(4, 17, this_vehicle, selection_options[g_selected_option_index + 1].type)
        else
            update_ui_text(4, 17, update_get_loc(e_loc.upp_clear), 60, 0, color_white, 0)
        end
    else
        g_chassis_combo_scroll = -1
    end

    ui:begin_window(update_get_loc(e_loc.chassis).."##chassis", 0, 95, screen_w, screen_h - 95, nil, is_active, 1)
        g_selected_option_index, g_chassis_combo_scroll, is_pressed = imgui_combo_custom(ui, g_selected_option_index, selection_options, 18, 25, g_chassis_combo_scroll, render_chassis_option)

        if is_pressed then

            local definition_index = selection_options[g_selected_option_index + 1].type
            local inventory_item_type = update_get_resource_item_for_definition(definition_index)

            if g_selected_option_index == 0 or this_vehicle:get_definition_index() == e_game_object_type.drydock then
                this_vehicle:set_attached_vehicle_chassis(g_selected_bay_index, selection_options[g_selected_option_index + 1].type)
                g_screen_index = 1
            elseif inventory_item_type == -1 or this_vehicle:get_inventory_count_by_definition_index(definition_index) > 0 then
                this_vehicle:set_attached_vehicle_chassis(g_selected_bay_index, selection_options[g_selected_option_index + 1].type)
                g_screen_index = 1
            else
                g_no_stock_counter = 0
            end
        end
    ui:end_window()

    render_no_stock_indicator(4, 79, screen_w - 8)
end

function render_ui_attachment_definition_description(x, y, w, h, vehicle, index, attached_vehicle)
    local attachment_data = get_attachment_data_by_definition_index(index)
    update_ui_push_offset(x, y)
    
    local inventory_item_type = update_get_resource_item_for_definition(index)
    local is_in_stock = true
    local cy = 0

    if inventory_item_type ~= -1 then
        local inventory_count = vehicle:get_inventory_count_by_definition_index(index)

        update_ui_text(w - 20, cy, "x" .. inventory_count, 20, 2, iff(inventory_count > 0, color_status_ok, color_status_bad), 0)
        cy = cy + update_ui_text(0, cy, attachment_data.name, w - 20, 0, color_white, 0) + 2

        is_in_stock = inventory_count > 0
    else
        cy = cy + update_ui_text(0, cy, attachment_data.name, 120, 0, color_white, 0) + 2
    end

    local ammo_type = update_get_attachment_ammo_item_type(index)
    local ammo_icon = atlas_icons.icon_ammo

    if ammo_type ~= -1 then
        local ammo_count = vehicle:get_inventory_count_by_item_index(ammo_type)
        update_ui_image(0, cy, ammo_icon, iff(is_in_stock, color_white, color_grey_dark), 0)
        cy = 2 + cy + update_ui_text(10, cy, ammo_count, w - 10, 0, iff(is_in_stock, iff(ammo_count > 0, color_status_ok, color_status_bad), color_grey_dark), 0)
    end

    local item_mass = get_payload_weight(index)
    if item_mass then
        local col = color_white
        local excess = false
        if not rev_check_attachment_exceeds_payload(attached_vehicle, g_selected_attachment_index, index) then
            excess = true
            col = rev_rotate_tick_call(0.3, {
                function() return color_status_dark_red end,
                function() return color_status_ok  end
            })
        end
        update_ui_image(0, cy, atlas_icons.column_weight, iff(is_in_stock, color_white, color_grey_dark), 0)
        update_ui_text(10, cy, string.format("%d %s", item_mass, update_get_loc(e_loc.upp_kg)), w - 10, 0, col, 0)
        if excess then
            update_ui_text(10, cy + 32, string.format("%s", update_get_loc(e_loc.upp_payload)), w - 10, 0, color_status_dark_red, 0)
        end
    end
    update_ui_pop_offset()
end

function render_no_stock_indicator(x, y, w)
    if g_no_stock_counter < 30 then
        update_ui_push_offset(x, y)

        update_ui_rectangle(0, 0, w, 12, color_status_bad)
        update_ui_text(0, 2, update_get_loc(e_loc.upp_out_of_stock), w, 1, color_black, 0)

        update_ui_pop_offset()
    end
end

function format_ammo_quantity(amount)
    if amount < 1000 then
        return string.format("%.0f", amount)
    else
        return string.format("%.0f", amount / 1000) .. update_get_loc(e_loc.acronym_thousand)
    end
end


function render_screen_chooser(screen_w, screen_h, is_active)
    local ui = g_ui
    local screen_team = update_get_screen_team_id()
    ui:begin_window("Select carrier", 0, 0, screen_w, screen_h, nil, is_active, 1)
    update_ui_rectangle(0, 0, screen_w, 14, color_white)
    ui:text_basic("SELECT CARRIER", color_grey_dark)
    ui:spacer(1)

    local vehicle_count = update_get_map_vehicle_count()

    for i = 0, vehicle_count - 1, 1 do
        local vehicle = update_get_map_vehicle_by_index(i)
        if vehicle:get() then
            local vehicle_team = vehicle:get_team()
            if vehicle_team == screen_team or get_is_spectator_mode() then
                local label = ""
                local vid = vehicle:get_id()

                local vehicle_definition_index = vehicle:get_definition_index()
                if vehicle_definition_index == e_game_object_type.chassis_carrier then
                    label = get_ship_name(vehicle)
                end

                if get_is_spectator_mode() then
                    if vehicle_definition_index == e_game_object_type.chassis_air_rotor_heavy then
                        label = "PTR " .. vehicle:get_id()
                    end

                    if vehicle_definition_index == e_game_object_type.drydock then
                        label = "TEAM " .. vehicle:get_team() .. " DRYDOCK"
                    end
                end

                if vid == g_screen_vehicle_id then
                    label = label .. " *"
                end

                if label ~= "" then
                    if ui:button(label, true, 1) then
                        g_managed_vehicle = vid
                        g_screen_index = 0
                    end
                end
            end
        end
    end

    ui:end_window()
end



-- revolution crafting system
--
-- when you are near and/or control particular island types you will be able to
-- unlock extra loadout options for some units, doing so will involve a "cost"
-- to be paid in carrier inventory stock (dumped over the side).
-- once fitted out in one of these special modes, if you remove anything
-- added by the alternate loadout, you wont be permitted to re-add it.

function custom_dynamic_vehicle_loadout_rows(vehicle, dynamic)
	local opt, fitted = rev_get_custom_upgrade_option(vehicle)
	local rows = {}
	if opt and fitted then
		for i, r in pairs(opt.rows) do
			if r ~= nil then
				rows[i] = r
			end
		end
		return rows
	end

	return dynamic
end

function custom_dynamic_vehicle_loadout_options(vehicle, dynamic, attachment_index)
	local replaced_opts = nil
	local opt, fitted = rev_get_custom_upgrade_option(vehicle)
	if opt and fitted then
		replaced_opts = opt.options[attachment_index]
	end

	if replaced_opts ~= nil then
		dynamic = replaced_opts
	end

	return dynamic
end


function rev_engineering_can_upgrade(vehicle)
	local opt, fitted = rev_get_custom_upgrade_option(vehicle)
	return opt and not fitted
end

g_prompt_upgrade_vehicle = nil

function rev_get_custom_upgrade_option(vehicle)
	if vehicle and vehicle:get() then
		local def = vehicle:get_definition_index()
		for _, value in pairs(g_revolution_crafting_items) do
			if value.chassis == def then
				-- if a special option isnt fitted
				local fitted = false
				local acount = vehicle:get_attachment_count()
				if acount == value.min_attachments then
					for anum, adef in pairs(value.attachments) do
						local a = vehicle:get_attachment(anum)
						if a and a:get() then
							local a_fitted = a:get_definition_index()
							if a_fitted == adef then
								fitted = true
							end
						end
					end
					return value, fitted
				end
			end
		end
	end
	return nil, nil
end


function custom_vehicle_input_event(event, action)
	if g_prompt_upgrade_vehicle then
		if event == e_input.back then
			g_prompt_upgrade_vehicle = nil
		end
	end
end

function custom_vehicle_loadout_update(screen_w, screen_h, ticks)
	if g_prompt_upgrade_vehicle then
		local vehicle = update_get_map_vehicle_by_id(g_prompt_upgrade_vehicle)
		local upgrade_option, fitted = rev_get_custom_upgrade_option(vehicle)

		if upgrade_option ~= nil then
			local carrier = get_managed_vehicle()
			update_add_ui_interaction(update_get_loc(e_loc.interaction_back), e_game_input.back)
			local ui = g_ui
			ui:begin_ui()
			local window = ui:begin_window("Engineering", 0, 0, screen_w, screen_h, nil, true, 1)
			-- title
			update_ui_rectangle(0, 0, screen_w, 14, color_white)
			window.cy = 3 + update_ui_text(0, 4, "UPGRADE UNIT?", screen_w, 1, color_black, 0)
			local v_def = vehicle:get_definition_index()

			-- body
			local v_name, v_icon, v_abbr, v_desc = get_chassis_data_by_definition_index(v_def)

			ui:text_basic(v_name, color_white, color_white)
			ui:text_basic("> " .. upgrade_option.name)
			ui:text_basic(upgrade_option.details)
			ui:text_basic("COST:")
			local has_reqs = true
			local costs = upgrade_option.cost
			for inv_item, inv_count in pairs(costs) do
				local has_count = carrier:get_inventory_count_by_item_index(inv_item)
				local col = color_grey_dark
				if has_count < inv_count then
					col = color_status_dark_red
					has_reqs = false
				end
				ui:text_basic(string.format("%dx %s", inv_count, g_item_data[inv_item].name), col)
			end

			if ui:button("APPLY", has_reqs, 1) then
				g_prompt_upgrade_vehicle = nil
				if update_get_is_focus_local() then
					-- do the upgrade
					for anum, _ in pairs(upgrade_option.options) do
						carrier:set_attached_vehicle_attachment(g_selected_bay_index, anum, -1)
					end
					for anum, adef in pairs(upgrade_option.attachments) do
						carrier:set_attached_vehicle_attachment(g_selected_bay_index, anum, adef)
					end
					-- "spend" the fuel
					for inv_item, inv_count in pairs(upgrade_option.cost) do
						if inv_item == e_inventory_item.fuel_barrel then
							carrier:set_inventory_order(inv_item, inv_count, e_carrier_order_operation.delete)
						end
					end
					sanitise_loadout(carrier, g_selected_bay_index)
				end
			end

			ui:end_window()
			ui:end_ui()
			return true
		else
			g_prompt_upgrade_vehicle = nil
		end
	end

	return false
end

function custom_ui_vehicle_loadout_chassis(ui, vehicle)
	local opt, fitted = rev_get_custom_upgrade_option(vehicle)
	if opt ~= nil then
		if not fitted then
			local carrier = get_managed_vehicle()
			sanitise_loadout(carrier, g_selected_bay_index)
		end
		rev_custom_button(ui, "REFIT",
				4, 72, 47, 18, not fitted, function()
					if vehicle and vehicle:get() then
						g_prompt_upgrade_vehicle = vehicle:get_id()
					end
				end)
	else
		g_prompt_upgrade_vehicle = nil
	end
end

--


local g__crafting_aa_reduced_wing = {
	e_game_object_type.attachment_hardpoint_missile_aa,
	e_game_object_type.attachment_hardpoint_missile_tv,
}

local g__crafting_aa_extra_wing = {
	e_game_object_type.attachment_hardpoint_missile_aa,
}

example_g_revolution_crafting_items = {
    {
		name="Specops Petrel",
		details="Flare & Virus",
        chassis=e_game_object_type.chassis_air_rotor_heavy,
		min_attachments=6,
        attachments={
            [4] = e_game_object_type.attachment_turret_robot_dog_capsule,
		},
		options={
			[1] = {
				e_game_object_type.attachment_camera_plane
			},
			[4] = {e_game_object_type.attachment_turret_robot_dog_capsule},
			[2] = {
				e_game_object_type.attachment_turret_plane_chaingun,
				e_game_object_type.attachment_fuel_tank_plane,
			},
			[5] = {
				e_game_object_type.attachment_flare_launcher,
				e_game_object_type.attachment_smoke_launcher_explosive,
			},
			[3] = {
				e_game_object_type.attachment_turret_plane_chaingun,
				e_game_object_type.attachment_fuel_tank_plane,
			},
		},
		rows={
			{
                { i=1, x=0, y=-22 }
            },
            {
                { i=2, x=-20, y=0 },
                { i=4, x=-10, y=0 },
                { i=5, x=10, y=0 },
                { i=3, x=20, y=0 }
            }
		},
        cost={
            [e_inventory_item.fuel_barrel] = 1,
            [e_inventory_item.virus_module] = 1,
        }
    },
	{
		name="Manta F2",
		details="Extra missiles",
		chassis=e_game_object_type.chassis_air_wing_heavy,
		min_attachments=11,
		attachments={
			[10] = e_game_object_type.attachment_camera_observation,
		},
		options={
			[4] = g__crafting_aa_reduced_wing,
			[5] = g__crafting_aa_reduced_wing,
			[8] = g__crafting_aa_extra_wing,
			[9] = g__crafting_aa_extra_wing,
			[10] = {
				e_game_object_type.attachment_camera_observation
			}
		},
		rows={
			{
				{ i = 1, x = 0, y = -23 }, -- front camera slot
				{ i = 2, x = 9, y = -4 }  -- internal gun
			},
			{
				{ i = 3, x = 0, y = 7 },   -- centre
				{ i = 4, x = -18, y = 7 }, -- left inner
				{ i = 5, x = 18, y = 7 },  -- right inner
			},
			{
				{ i = 6, x = -9, y = 24 }, -- left util
				{ i = 7, x = 9, y = 24 }   -- right util
			},
		    {
			   { i = 8, x = -26, y = 16 }, -- left wing
			   { i = 9, x = 26, y = 16 },  -- right wing
			   { i = 10, x = 0, y = 16 },  -- dorsal
			}
		},
		cost={
            [e_inventory_item.fuel_barrel] = 2,
			[e_inventory_item.attachment_camera_observation] = 1
        }
	},
	{
		name="Koala",
		details="Anti-Air system",
		chassis=e_game_object_type.chassis_land_wheel_heavy,
		min_attachments=9,
		attachments={
			[2] = e_game_object_type.attachment_radar_golfball
		},
		options={
			[2] = {e_game_object_type.attachment_radar_golfball},
			[4] = g__crafting_aa_reduced_wing,
			[5] = g__crafting_aa_reduced_wing,
			[6] = g__crafting_aa_reduced_wing,
			[7] = g__crafting_aa_reduced_wing,
			[8] = g__crafting_aa_reduced_wing,
		},
		rows={
			{
				{ i=2, x=0, y=-25 },
				{ i=4, x=-14, y=-6 },
				{ i=5, x=0, y=-6 },
				{ i=6, x=14, y=-6 },
				{ i=7, x=-14, y=20 },
				{ i=8, x=14, y=20 },
			}
		},
	    cost={
            [e_inventory_item.fuel_barrel] = 4,
			[e_inventory_item.attachment_radar_golfball] = 1,
        }
	},
	{
		name="Hinny",
		details="Mobile LGM Silo",
		chassis=e_game_object_type.chassis_land_wheel_mule,
		min_attachments=7,
		attachments={
			[1] = e_game_object_type.attachment_camera_observation
		},
		options={
			[1] = {e_game_object_type.attachment_camera_observation},
			[2] = {e_game_object_type.attachment_hardpoint_missile_laser},
			[3] = {e_game_object_type.attachment_hardpoint_missile_laser},
			[4] = {e_game_object_type.attachment_hardpoint_missile_laser},
			[5] = {e_game_object_type.attachment_hardpoint_missile_laser},
			[6] = {e_game_object_type.attachment_hardpoint_missile_laser},
		},
		rows={
			{
				{ i=1, x=-10, y=-21 },
				{ i=2, x=10, y=-21 },
				{ i=3, x=-10, y=-5 },
				{ i=4, x=10, y=-5 },
				{ i=5, x=-10, y=11 },
				{ i=6, x=10, y=11 },
			}
		},
	    cost={
            [e_inventory_item.fuel_barrel] = 2,
			[e_inventory_item.attachment_camera_observation] = 1,
        }
	}
}

if g_revolution_crafting_items == nil then
    g_revolution_crafting_items = {
        {
            name="OBST",
            details="Observation Post",
            chassis=e_game_object_type.chassis_land_turret,
            min_attachments=1,
            attachments={
                [0] = e_game_object_type.attachment_camera_observation
            },
            options={
                [0] = {e_game_object_type.attachment_camera_observation},
            },
            rows={
                {
                    { i=0, x=0, y=0 },
                }
            },
            cost={
                [e_inventory_item.fuel_barrel] = 1,
            }
        },
    }
end

