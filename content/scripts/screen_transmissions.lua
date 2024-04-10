g_animation_time = 0

g_screen_index = 0

g_transmission_selected_index = -1
g_transmission_playing_index_prev = -1
g_ui = nil
g_is_focus_local_prev = false

function begin()
    begin_load()
    
    g_ui = lib_imgui:create_ui()
end

function parse()
    g_transmission_selected_index = parse_s32("", g_transmission_selected_index)
end

function update(screen_w, screen_h, ticks)
    g_animation_time = g_animation_time + ticks

    if update_screen_overrides(screen_w, screen_h, ticks)  then return end

	local attached = update_get_is_focus_local()
    local ui = g_ui
	local team_id = update_get_screen_team_id()
    local team = update_get_team(team_id)

    ui:begin_ui()

    if team:get() then
        local can_change_game_settings = false
        local lock_game_settings_after = 240
        local game_seconds = math.floor(update_get_logic_tick() / 30)

        if game_seconds < lock_game_settings_after then
            can_change_game_settings = true
        end


        local current_ship = update_get_screen_vehicle()
        local main_win_h = screen_h - 11
		local win_main = ui:begin_window(update_get_loc(e_loc.upp_options), 5, 5, screen_w - 10, main_win_h,
				atlas_icons.column_distance, attached, 0, true, true)
		local region_w, region_h = ui:get_region()

		ui:header(update_get_loc(e_loc.upp_carrier))
		ui:text(get_ship_name(current_ship))
        if ui:button("CHANGE", attached, 0) then
            if attached then
                local value = get_carrier_lifeboat_attachments_value(current_ship)
                value = value + 1
                if value > 6 then
                    value = 0
                end
                set_carrier_lifeboat_attachments_value(current_ship, value)
            end
		end

        -- this is totally stupid, I cant type 'p'
        if false and ui:button("CUSTOM", attached, 0) then
            if attached then
                g_input_custom_name = true
                g_is_text_input = true
                g_input_text = get_ship_name(current_ship)
            end
        end

        if g_is_text_input then
            ui:text(g_input_text)
        end

        if false then

            ui:header("Revolution Settings")
            if game_seconds < lock_game_settings_after then
                ui:text(string.format("Lock Settings in %d sec", lock_game_settings_after - game_seconds))
            else
                ui:text("Settings locked")
            end

            ui:text("AWACS " .. update_get_loc(e_loc.upp_range))
            local awacs_range = 10 * get_radar_multiplier()
            ui:text(string.format("%d km", math.floor(awacs_range)))
            if ui:button("CHANGE", can_change_game_settings, 0) then

            end

            ui:text("FOG OF WAR")
            ui:text("enabled")
            if ui:button("CHANGE", can_change_game_settings, 0) then

            end

        end

		ui:end_window()

    end

    ui:end_ui()

    g_is_focus_local_prev = update_get_is_focus_local()
end

function input_event(event, action)

    if g_is_text_input then
        if action == e_input_action.release then
            if event == e_input.text_backspace then
                g_input_text = string.sub(g_input_text, 0, -2)
            elseif event == e_input.text_enter then
                g_input_text_done = true
                g_is_text_input = false

                if g_input_custom_name then
                    -- encode the name
                    local value = pack_6bit_ais_string(g_input_text)
                    g_input_text = ""
                    set_carrier_lifeboat_attachments_value(update_get_screen_vehicle(), value)
                end
            end
        end
    end

    if action == e_input_action.press and event == e_input.back then
        if g_is_text_input then
            g_input_text = ""
            g_input_text_done = true
            g_is_text_input = false
        else
            update_set_screen_state_exit()
        end
    end

    if g_is_text_input then
        --update_set_is_pause_simulation(false)
    else
        --update_set_is_pause_simulation(true)
    end
    g_ui:input_event(event, action)
end

function input_pointer(is_hovered, x, y)
    g_ui:input_pointer(is_hovered, x, y)
end

function input_scroll(dy)
    g_ui:input_scroll(dy)
end

function input_axis(x, y, z, w)
end


g_is_text_input = false
g_input_custom_name = false
g_input_text = ""
g_input_text_done = false

function input_text(text)
    if g_is_text_input then
        if #g_input_text < 9 then
            g_input_text = g_input_text .. string.upper(text)
        end
    end
end

