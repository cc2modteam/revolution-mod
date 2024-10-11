g_is_holomap = false

function get_carrier_bay_name(index)
    bay_name = update_get_loc(e_loc.upp_acronym_surface).."1";

    if(index >= 8)
    then
        bay_name = update_get_loc(e_loc.upp_acronym_air)..(index - 7)
    else
        bay_name = update_get_loc(e_loc.upp_acronym_surface)..(index + 1)
    end

    return bay_name
end

function get_icon_data_by_definition_index_graphic(index)
    local region_vehicle_icon, icon_offset = get_icon_data_by_definition_index(index)
    if index == e_game_object_type.chassis_carrier then
        -- region_vehicle_icon = atlas_icons.icon_chassis_16_carrier
    elseif index == e_game_object_type.chassis_air_wing_light then
        region_vehicle_icon = atlas_icons.icon_chassis_16_wing_small
    elseif index == e_game_object_type.chassis_air_wing_heavy then
        region_vehicle_icon = atlas_icons.icon_chassis_16_wing_large
    elseif index == e_game_object_type.chassis_air_rotor_heavy then
        region_vehicle_icon = atlas_icons.icon_chassis_16_rotor_large
    elseif index == e_game_object_type.chassis_air_rotor_light then
        region_vehicle_icon = atlas_icons.icon_chassis_16_rotor_small
    end
    return region_vehicle_icon, icon_offset
end

function get_icon_data_by_definition_index(index)
    region_vehicle_icon = atlas_icons.map_icon_air
    icon_offset = 4

    if index == e_game_object_type.chassis_land_wheel_light or index == e_game_object_type.chassis_land_wheel_medium or index == e_game_object_type.chassis_land_wheel_heavy or index == e_game_object_type.chassis_land_wheel_mule then
        region_vehicle_icon = atlas_icons.map_icon_surface
        icon_offset = 4
    elseif index == e_game_object_type.chassis_carrier then
        region_vehicle_icon = atlas_icons.map_icon_carrier
        icon_offset = 8
    elseif index == e_game_object_type.chassis_sea_barge then
        region_vehicle_icon = atlas_icons.map_icon_barge
        icon_offset = 4
    elseif index == e_game_object_type.chassis_land_turret then
        region_vehicle_icon = atlas_icons.map_icon_turret
        icon_offset = 4
    elseif index == e_game_object_type.chassis_land_robot_dog then
        region_vehicle_icon = atlas_icons.map_icon_robot_dog
        icon_offset = 4
    elseif index == e_game_object_type.chassis_sea_ship_light or index == e_game_object_type.chassis_sea_ship_heavy then
        region_vehicle_icon = atlas_icons.map_icon_ship
        icon_offset = 5
    elseif index == e_game_object_type.chassis_deployable_droid then
        region_vehicle_icon = atlas_icons.map_icon_droid
        icon_offset = 4
    end

    return region_vehicle_icon, icon_offset
end

function get_chassis_data_by_definition_index(index)
    if g_revolution_custom_vehicle_chassis_data ~= nil then
        local v_name, v_icon, v_abbr, v_desc = g_revolution_custom_vehicle_chassis_data(index)
        if v_name ~= nil then
            return v_name, v_icon, v_abbr, v_desc
        end
    end

    local v_name, v_icon, v_abbr, v_desc = get_chassis_data_by_definition_index_orig(index)
    return v_name, v_icon, v_abbr, v_desc
end

function get_chassis_data_by_definition_index_orig(index)
    if index == e_game_object_type.chassis_carrier then
        return update_get_loc(e_loc.upp_carrier), atlas_icons.icon_chassis_16_carrier, update_get_loc(e_loc.upp_crr), update_get_loc(e_loc.upp_logistics_carrier)
    elseif index == e_game_object_type.chassis_land_wheel_light then
        return update_get_loc(e_loc.upp_seal), atlas_icons.icon_chassis_16_wheel_small, update_get_loc(e_loc.upp_sel), update_get_loc(e_loc.upp_light_scout_vehicle)
    elseif index == e_game_object_type.chassis_land_wheel_medium then
        return update_get_loc(e_loc.upp_walrus), atlas_icons.icon_chassis_16_wheel_medium, update_get_loc(e_loc.upp_wlr), update_get_loc(e_loc.upp_all_purpose_vehicle)
    elseif index == e_game_object_type.chassis_land_wheel_heavy then
        return update_get_loc(e_loc.upp_bear), atlas_icons.icon_chassis_16_wheel_large, update_get_loc(e_loc.upp_ber), update_get_loc(e_loc.upp_heavy_platform)
    elseif index == e_game_object_type.chassis_air_wing_light then
        return update_get_loc(e_loc.upp_albatross), atlas_icons.icon_chassis_16_wing_small, update_get_loc(e_loc.upp_alb), update_get_loc(e_loc.upp_scout_wing_aircraft)
    elseif index == e_game_object_type.chassis_air_wing_heavy then
        return update_get_loc(e_loc.upp_manta), atlas_icons.icon_chassis_16_wing_large, update_get_loc(e_loc.upp_mnt), update_get_loc(e_loc.upp_fast_jet_aircraft)
    elseif index == e_game_object_type.chassis_air_rotor_light then
        return update_get_loc(e_loc.upp_razorbill), atlas_icons.icon_chassis_16_rotor_small, update_get_loc(e_loc.upp_rzr), update_get_loc(e_loc.upp_light_rotor)
    elseif index == e_game_object_type.chassis_air_rotor_heavy then
        return update_get_loc(e_loc.upp_petrel), atlas_icons.icon_chassis_16_rotor_large, update_get_loc(e_loc.upp_ptr), update_get_loc(e_loc.upp_heavy_lift_rotor)
    elseif index == e_game_object_type.chassis_sea_barge then
        return update_get_loc(e_loc.upp_barge), atlas_icons.icon_chassis_16_barge, update_get_loc(e_loc.upp_brg), update_get_loc(e_loc.upp_support_barge)
    elseif index == e_game_object_type.chassis_land_turret then
        return update_get_loc(e_loc.upp_turret), atlas_icons.icon_chassis_16_land_turret, update_get_loc(e_loc.upp_trt), update_get_loc(e_loc.upp_stationary_turret)
    elseif index == e_game_object_type.chassis_land_robot_dog then
        return update_get_loc(e_loc.upp_control_bot), atlas_icons.icon_chassis_16_robot_dog, update_get_loc(e_loc.upp_bot), update_get_loc(e_loc.upp_control_bot)
    elseif index == e_game_object_type.chassis_sea_ship_light then
        return update_get_loc(e_loc.upp_needlefish), atlas_icons.icon_chassis_16_ship_light, update_get_loc(e_loc.upp_ndl), update_get_loc(e_loc.upp_light_patrol_ship)
    elseif index == e_game_object_type.chassis_sea_ship_heavy then
        return update_get_loc(e_loc.upp_swordfish), atlas_icons.icon_chassis_16_ship_heavy, update_get_loc(e_loc.upp_swd), update_get_loc(e_loc.upp_heavy_patrol_ship)
    elseif index == e_game_object_type.chassis_land_wheel_mule then
        return update_get_loc(e_loc.upp_mule), atlas_icons.icon_chassis_16_wheel_mule, update_get_loc(e_loc.upp_mul), update_get_loc(e_loc.upp_logistics_support_vehicle)
    elseif index == e_game_object_type.chassis_deployable_droid then
        return update_get_loc(e_loc.upp_droid), atlas_icons.icon_chassis_16_droid, update_get_loc(e_loc.upp_drd), update_get_loc(e_loc.upp_droid)
    end

    return update_get_loc(e_loc.upp_unknown), atlas_icons.icon_chassis_16_wheel_small, "---", ""
end

function get_attachment_data_by_definition_index(index)
    local attachment_data = {
        [-1] = { 
            unknown = true,
            name = update_get_loc(e_loc.upp_unknown),
            icon16 = atlas_icons.icon_attachment_16_none,
            name_short = update_get_loc(e_loc.upp_unknown),
        },
        [e_game_object_type.attachment_turret_15mm] = {
            name = update_get_loc(e_loc.upp_15mm_cannon),
            icon16 = atlas_icons.icon_attachment_16_turret_main_gun_light,
            name_short = update_get_loc(e_loc.upp_gun) .. " 15MM",
        },
        [e_game_object_type.attachment_turret_30mm] = {
            name = update_get_loc(e_loc.upp_30mm_cannon),
            icon16 = atlas_icons.icon_attachment_16_turret_main_gun,
            name_short = update_get_loc(e_loc.upp_gun) .. " 30MM",
        },
        [e_game_object_type.attachment_turret_40mm] = {
            name = update_get_loc(e_loc.upp_40mm_cannon),
            icon16 = atlas_icons.icon_attachment_16_turret_main_gun_2,
            name_short = update_get_loc(e_loc.upp_gun) .. " 40MM",
        },
        [e_game_object_type.attachment_turret_heavy_cannon] = {
            name = update_get_loc(e_loc.upp_heavy_cannon),
            icon16 = atlas_icons.icon_attachment_16_turret_main_heavy_cannon,
            name_short = update_get_loc(e_loc.upp_gun) .. " HEAVY",
        },
        [e_game_object_type.attachment_turret_battle_cannon] = {
            name = update_get_loc(e_loc.upp_100mm_cannon),
            icon16 = atlas_icons.icon_attachment_16_turret_main_battle_cannon,
            name_short = update_get_loc(e_loc.upp_gun) .. " BATTLE",
        },
        [e_game_object_type.attachment_turret_artillery] = {
            name = update_get_loc(e_loc.upp_artillery_gun),
            icon16 = atlas_icons.icon_attachment_16_turret_artillery,
            name_short = update_get_loc(e_loc.upp_gun) .. " 120MM",
        },
        [e_game_object_type.attachment_turret_carrier_main_gun] = {
            name = update_get_loc(e_loc.upp_naval_gun),
            icon16 = atlas_icons.icon_attachment_16_turret_main_battle_cannon,
            name_short = update_get_loc(e_loc.upp_gun) .. " 160MM",
        },
        [e_game_object_type.attachment_turret_plane_chaingun] = {
            name = update_get_loc(e_loc.upp_20mm_auto_cannon),
            icon16 = atlas_icons.icon_attachment_16_air_chaingun,
            name_short = "CHAINGUN",
        },
        [e_game_object_type.attachment_turret_rocket_pod] = {
            name = update_get_loc(e_loc.upp_rocket_pod),
            icon16 = atlas_icons.icon_attachment_16_rocket_pod,
            name_short = "ROCKET POD",
        },
        [e_game_object_type.attachment_turret_robot_dog_capsule] = {
            name = update_get_loc(e_loc.upp_control_bots),
            icon16 = atlas_icons.icon_attachment_16_turret_robots,
            name_short = update_get_loc(e_loc.upp_control_bot),
        },
        [e_game_object_type.attachment_turret_ciws] = {
            name = update_get_loc(e_loc.upp_anti_air_cannon),
            icon16 = atlas_icons.icon_attachment_16_turret_ciws,
            name_short = update_get_loc(e_loc.upp_a_msl),
        },
        [e_game_object_type.attachment_turret_missile] = {
            name = update_get_loc(e_loc.upp_missile_array),
            icon16 = atlas_icons.icon_attachment_16_turret_missile,
            name_short = update_get_loc(e_loc.upp_msl) .. " IR",
        },
        [e_game_object_type.attachment_turret_carrier_ciws] = {
            name = update_get_loc(e_loc.upp_naval_anti_air_cannon),
            icon16 = atlas_icons.icon_attachment_16_turret_ciws,
            name_short = update_get_loc(e_loc.upp_a_msl),
        },
        [e_game_object_type.attachment_turret_carrier_missile] = {
            name = update_get_loc(e_loc.upp_naval_missile_array),
            icon16 = atlas_icons.icon_attachment_16_turret_missile,
            name_short = update_get_loc(e_loc.upp_msl) .. " AA",
        },
        [e_game_object_type.attachment_turret_carrier_missile_silo] = {
            name = update_get_loc(e_loc.upp_naval_cruise_missile),
            icon16 = atlas_icons.icon_attachment_16_turret_missile,
            name_short = "CRUISE MSL",
        },
        [e_game_object_type.attachment_turret_carrier_flare_launcher] = {
            name = update_get_loc(e_loc.upp_naval_flare_launcher),
            icon16 = atlas_icons.icon_attachment_16_small_flare,
            name_short = "FLARE",
        },
        [e_game_object_type.attachment_turret_carrier_camera] = {
            name = update_get_loc(e_loc.upp_naval_camera),
            icon16 = atlas_icons.icon_attachment_16_camera_large,
            name_short = "OBS CAM",
        },
        [e_game_object_type.attachment_turret_carrier_torpedo] = {
            name = update_get_loc(e_loc.upp_torpedo),
            icon16 = atlas_icons.icon_attachment_16_air_torpedo,
            name_short = "TORP EXPL",
        },
        [e_game_object_type.attachment_turret_carrier_torpedo_decoy] = {
            name = update_get_loc(e_loc.upp_torpedo_decoy),
            icon16 = atlas_icons.icon_attachment_16_air_torpedo_decoy,
            name_short = "TORP DECOY",
        },
        [e_game_object_type.attachment_hardpoint_bomb_1] = {
            name = update_get_loc(e_loc.upp_bomb_1),
            icon16 = atlas_icons.icon_attachment_16_air_bomb_1,
            name_short = "BOMB LIGHT",
        },
        [e_game_object_type.attachment_hardpoint_bomb_2] = {
            name = update_get_loc(e_loc.upp_bomb_2),
            icon16 = atlas_icons.icon_attachment_16_air_bomb_2,
            name_short = "BOMB MEDIUM",
        },
        [e_game_object_type.attachment_hardpoint_bomb_3] = {
            name = update_get_loc(e_loc.upp_bomb_3),
            icon16 = atlas_icons.icon_attachment_16_air_bomb_3,
            name_short = "BOMB HEAVY",
        },
        [e_game_object_type.attachment_hardpoint_torpedo] = {
            name = update_get_loc(e_loc.upp_torpedo),
            icon16 = atlas_icons.icon_attachment_16_air_torpedo,
            name_short = "TORP EXPL",
        },
        [e_game_object_type.attachment_hardpoint_torpedo_noisemaker] = {
            name = update_get_loc(e_loc.upp_torpedo_noisemaker),
            icon16 = atlas_icons.icon_attachment_16_air_torpedo_noisemaker,
            name_short = "TORP NOISE",
        },
        [e_game_object_type.attachment_hardpoint_torpedo_decoy] = {
            name = update_get_loc(e_loc.upp_torpedo_decoy),
            icon16 = atlas_icons.icon_attachment_16_air_torpedo_decoy,
            name_short = "TORP DECOY",
        },
        [e_game_object_type.attachment_hardpoint_missile_ir] = {
            name = update_get_loc(e_loc.upp_missile_1),
            icon16 = atlas_icons.icon_attachment_16_air_missile_1,
            name_short = update_get_loc(e_loc.upp_msl) .. " IR",
        },
        [e_game_object_type.attachment_hardpoint_missile_laser] = {
            name = update_get_loc(e_loc.upp_missile_2),
            icon16 = atlas_icons.icon_attachment_16_air_missile_2,
            name_short = update_get_loc(e_loc.upp_msl) .. " LSR",
        },
        [e_game_object_type.attachment_hardpoint_missile_aa] = {
            name = update_get_loc(e_loc.upp_missile_4),
            icon16 = atlas_icons.icon_attachment_16_air_missile_4,
            name_short = update_get_loc(e_loc.upp_msl) .. " AA",
        },
        [e_game_object_type.attachment_hardpoint_missile_tv] = {
            name = update_get_loc(e_loc.upp_missile_tv),
            icon16 = atlas_icons.icon_attachment_16_air_missile_tv,
            name_short = update_get_loc(e_loc.upp_msl) .. " TV",
        },
        [e_game_object_type.attachment_camera] = {
            name = update_get_loc(e_loc.upp_actuated_camera),
            icon16 = atlas_icons.icon_attachment_16_small_camera_obs,
            name_short = "VIEW CAM",
        },
        [e_game_object_type.attachment_camera_vehicle_control] = {
            name = update_get_loc(e_loc.upp_fixed_camera),
            icon16 = atlas_icons.icon_attachment_16_small_camera,
            name_short = "CONTROL",
        },
        [e_game_object_type.attachment_camera_plane] = {
            name = update_get_loc(e_loc.upp_gimbal_camera),
            icon16 = atlas_icons.icon_attachment_16_camera_aircraft,
            name_short = "OBS CAM",
        },
        [e_game_object_type.attachment_camera_observation] = {
            name = update_get_loc(e_loc.upp_observation_camera),
            icon16 = atlas_icons.icon_attachment_16_camera_large,
            name_short = "OBS CAM",
        },
        [e_game_object_type.attachment_radar_awacs] = {
            name = update_get_loc(e_loc.upp_awacs_radar_system),
            icon16 = atlas_icons.icon_attachment_16_air_radar,
            name_short = "AWACS",
        },
        [e_game_object_type.attachment_fuel_tank_plane] = {
            name = update_get_loc(e_loc.upp_external_fuel_tank),
            icon16 = atlas_icons.icon_attachment_16_air_fuel,
            name_short = "FUEL TANK",
        },
        [e_game_object_type.attachment_flare_launcher] = {
            name = update_get_loc(e_loc.upp_ir_countermeasures),
            icon16 = atlas_icons.icon_attachment_16_small_flare,
            name_short = "FLARE",
        },
        [e_game_object_type.attachment_radar_golfball] = {
            name = update_get_loc(e_loc.upp_radar_golfball),
            icon16 = atlas_icons.icon_attachment_16_radar_golfball,
            name_short = "RADAR",
        },
        [e_game_object_type.attachment_sonic_pulse_generator] = {
            name = update_get_loc(e_loc.upp_sonic_pulse_generator),
            icon16 = atlas_icons.icon_attachment_16_sonic_pulse_generator,
            name_short = "PULSE GEN",
        },
        [e_game_object_type.attachment_smoke_launcher_explosive] = {
            name = update_get_loc(e_loc.upp_smoke_launcher_explosive),
            icon16 = atlas_icons.icon_attachment_16_smoke_launcher_explosive,
            name_short = "SMK EXPL",
        },
        [e_game_object_type.attachment_smoke_launcher_stream] = {
            name = update_get_loc(e_loc.upp_smoke_launcher_stream),
            icon16 = atlas_icons.icon_attachment_16_smoke_launcher_stream,
            name_short = "SMK STRM",
        },
        [e_game_object_type.attachment_turret_carrier_torpedo] = {
            name = update_get_loc(e_loc.upp_torpedo),
            icon16 = atlas_icons.icon_attachment_16_air_torpedo,
            name_short = "TORP EXPL",
        },
        [e_game_object_type.attachment_logistics_container_20mm] = {
            name = update_get_loc(e_loc.upp_logistics_container_20mm),
            icon16 = atlas_icons.icon_attachment_16_logistics_container_20mm,
            name_short = "BOX 20MM",
        },
        [e_game_object_type.attachment_logistics_container_30mm] = {
            name = update_get_loc(e_loc.upp_logistics_container_30mm),
            icon16 = atlas_icons.icon_attachment_16_logistics_container_30mm,
            name_short = "BOX 30MM",
        },
        [e_game_object_type.attachment_logistics_container_40mm] = {
            name = update_get_loc(e_loc.upp_logistics_container_40mm),
            icon16 = atlas_icons.icon_attachment_16_logistics_container_40mm,
            name_short = "BOX 40MM",
        },
        [e_game_object_type.attachment_logistics_container_100mm] = {
            name = update_get_loc(e_loc.upp_logistics_container_100mm),
            icon16 = atlas_icons.icon_attachment_16_logistics_container_100mm,
            name_short = "BOX 100MM",
        },
        [e_game_object_type.attachment_logistics_container_120mm] = {
            name = update_get_loc(e_loc.upp_logistics_container_120mm),
            icon16 = atlas_icons.icon_attachment_16_logistics_container_120mm,
            name_short = "BOX 120MM",
        },
        [e_game_object_type.attachment_logistics_container_fuel] = {
            name = update_get_loc(e_loc.upp_logistics_container_fuel),
            icon16 = atlas_icons.icon_attachment_16_logistics_container_fuel,
            name_short = "BOX FUEL",
        },
        [e_game_object_type.attachment_logistics_container_ir_missile] = {
            name = update_get_loc(e_loc.upp_logistics_container_ir_missile),
            icon16 = atlas_icons.icon_attachment_16_logistics_container_ir_missile,
            name_short = "BOX IR " .. update_get_loc(e_loc.upp_msl),
        },
        [e_game_object_type.attachment_turret_droid] = {
            name = update_get_loc(e_loc.upp_turret_droid),
            icon16 = atlas_icons.icon_attachment_16_turret_droid,
            name_short = "DUAL 30MM",
        },
        [e_game_object_type.attachment_deployable_droid] = {
            name = update_get_loc(e_loc.upp_deployable_droid),
            icon16 = atlas_icons.icon_attachment_16_deployable_droid,
            name_short = "DROID",
        },
        [e_game_object_type.attachment_turret_gimbal_30mm] = {
            name = update_get_loc(e_loc.upp_30mm_gimbal),
            icon16 = atlas_icons.icon_attachment_16_turret_gimbal,
            name_short = update_get_loc(e_loc.upp_gun) .. " 30MM",
        },
    }

    return attachment_data[index] or attachment_data[-1]
end

function get_chassis_image_by_definition_index(index)
    if index == e_game_object_type.chassis_land_wheel_light then
        return atlas_icons.icon_chassis_wheel_small
    elseif index == e_game_object_type.chassis_land_wheel_medium then
        return atlas_icons.icon_chassis_wheel_medium
    elseif index == e_game_object_type.chassis_land_wheel_heavy then
        return atlas_icons.icon_chassis_wheel_large
    elseif index == e_game_object_type.chassis_air_wing_light then
        return atlas_icons.icon_chassis_wing_small
    elseif index == e_game_object_type.chassis_air_wing_heavy then
        return atlas_icons.icon_chassis_wing_large
    elseif index == e_game_object_type.chassis_air_rotor_light then
        return atlas_icons.icon_chassis_rotor_small
    elseif index == e_game_object_type.chassis_air_rotor_heavy then
        return atlas_icons.icon_chassis_rotor_large
    elseif index == e_game_object_type.chassis_land_turret then
        return atlas_icons.icon_chassis_turret
    elseif index == e_game_object_type.chassis_sea_ship_light then
        return atlas_icons.icon_chassis_sea_ship_light
    elseif index == e_game_object_type.chassis_land_wheel_mule then
        return atlas_icons.icon_chassis_wheel_mule
    elseif index == e_game_object_type.chassis_deployable_droid then
        return atlas_icons.icon_chassis_deployable_droid
    end

    return atlas_icons.icon_chassis_unknown
end

function get_is_vehicle_air(definition_index)
    return definition_index == e_game_object_type.chassis_air_wing_light
        or definition_index == e_game_object_type.chassis_air_wing_heavy
        or definition_index == e_game_object_type.chassis_air_rotor_light
        or definition_index == e_game_object_type.chassis_air_rotor_heavy
end

function get_is_vehicle_rotary(definition_index)
    return definition_index == e_game_object_type.chassis_air_rotor_light
        or definition_index == e_game_object_type.chassis_air_rotor_heavy
end

function get_can_autoland(definition_index)
    return get_is_vehicle_rotary(definition_index)
end

function setup_autoland(vehicle, pos, start_pos)
    if pos == nil then
        pos = vehicle:get_position_xz()
    end
    vehicle:clear_waypoints()
    local steps = 12
    local gnd = 6
    if start_pos == nil then
        start_pos = vec3(pos:x() - 405, pos:y() - 405, 0)
    end

    -- set an approach waypoint 550m away
    local glide_start_x = start_pos:x()
    local glide_start_y = start_pos:y()
    local glide_end_x = pos:x()
    local glide_end_y = pos:y()
    local step_x = (glide_end_x - glide_start_x) / steps
    local step_y = (glide_end_y - glide_start_y) / steps
    -- shift the hold point 2-3 steps onwards so that we actually land at the requested point
    glide_end_x = glide_end_x + (step_x * 2.5)
    glide_end_y = glide_end_y + (step_y * 2.5)
    glide_start_x = glide_start_x + (step_x * 2.5)
    glide_start_y = glide_start_y + (step_y * 2.5)

    local nearest_gnd_unit = find_pos_nearest_vehicle_types(pos, {
                        e_game_object_type.chassis_land_wheel_mule,
                        e_game_object_type.chassis_land_wheel_heavy,
                        e_game_object_type.chassis_land_wheel_medium,
                        e_game_object_type.chassis_land_wheel_light,
                    }, false, vehicle:get_team() )
    if nearest_gnd_unit and nearest_gnd_unit:get() then
        local ref_pos = nearest_gnd_unit:get_position_xz()
        local ref_rng = vec2_dist(ref_pos, pos)
        if ref_rng < 150 then
            gnd = math.floor(get_unit_altitude(nearest_gnd_unit) - 5.5)
        end
    end

    add_altitude_waypoint(vehicle,
            vec3(glide_start_x, glide_start_y, 0),
            115)

    -- fly 430m west to a 110m alt,
    -- descend to zero and hold
    local approach_alt = 110

    for descent_steps = steps, 0, -1 do
        add_altitude_waypoint(vehicle,
                vec3(
                        glide_end_x - (descent_steps * step_x),
                        glide_end_y - (descent_steps * step_y),
                        0),
                math.floor(gnd + approach_alt * descent_steps / steps))
    end
    add_altitude_waypoint(vehicle, vec3(glide_end_x, glide_end_y, 0), 0 + gnd, 3)
end

function get_has_modded_radar(vehicle)
    if vehicle:get() then
        local def = vehicle:get_definition_index()
        if get_is_ship_fish(def) then
            return true
        end
        return get_modded_radar_range(vehicle) > 0
    end
    return false
end

function get_is_ship_fish(definition_index)
    return definition_index == e_game_object_type.chassis_sea_ship_light
        or definition_index == e_game_object_type.chassis_sea_ship_heavy
end

function get_is_vehicle_sea(definition_index)
    return definition_index == e_game_object_type.chassis_carrier
        or definition_index == e_game_object_type.chassis_sea_barge
        or get_is_ship_fish(definition_index)
end

function get_is_vehicle_land(definition_index)
    return definition_index == e_game_object_type.chassis_land_wheel_heavy
        or definition_index == e_game_object_type.chassis_land_wheel_medium
        or definition_index == e_game_object_type.chassis_land_wheel_light
        or definition_index == e_game_object_type.chassis_land_robot_dog
        or definition_index == e_game_object_type.chassis_land_turret
        or definition_index == e_game_object_type.chassis_land_wheel_mule
        or definition_index == e_game_object_type.chassis_deployable_droid
end

function get_is_vehicle_land_vehicle(definition_index)
    return definition_index == e_game_object_type.chassis_land_wheel_heavy
        or definition_index == e_game_object_type.chassis_land_wheel_medium
        or definition_index == e_game_object_type.chassis_land_wheel_light
        or definition_index == e_game_object_type.chassis_land_wheel_mule
end

function get_is_vehicle_airliftable(definition_index)
    if g_mod_allow_airlift ~= nil then
        -- eg,
        -- g_mod_allow_airlift = {
        --  e_game_object_type.chassis_land_wheel_heavy = false,
        --  e_game_object_type.chassis_land_wheel_medium = true,
        -- }
        --
        local entry = g_mod_allow_airlift[definition_index]
        if entry ~= nil then
            return entry
        end
    end

    return definition_index == e_game_object_type.chassis_land_wheel_heavy
        or definition_index == e_game_object_type.chassis_land_wheel_medium
        or definition_index == e_game_object_type.chassis_land_wheel_light
        or definition_index == e_game_object_type.chassis_land_robot_dog
        or definition_index == e_game_object_type.chassis_land_wheel_mule
        or definition_index == e_game_object_type.chassis_deployable_droid
end

function get_attack_type_icon(attack_type)
    if attack_type == e_attack_type.none then
        return atlas_icons.icon_attack_type_any
    elseif attack_type == e_attack_type.any then
        return atlas_icons.icon_attack_type_any
    elseif attack_type == e_attack_type.bomb_single then
        return atlas_icons.icon_attack_type_bomb_single
    elseif attack_type == e_attack_type.bomb_double then
        return atlas_icons.icon_attack_type_bomb_double
    elseif attack_type == e_attack_type.missile_single then
        return atlas_icons.icon_attack_type_missile_single
    elseif attack_type == e_attack_type.missile_double then
        return atlas_icons.icon_attack_type_missile_double
    elseif attack_type == e_attack_type.torpedo_single then
        return atlas_icons.icon_attack_type_torpedo_single
    elseif attack_type == e_attack_type.gun then
        return atlas_icons.icon_attack_type_gun
    elseif attack_type == e_attack_type.rockets then
        return atlas_icons.icon_attack_type_rockets
    elseif attack_type == e_attack_type.airlift then
        return atlas_icons.icon_attack_type_airlift
    end

    return atlas_icons.icon_attack_type_any
end

function get_unit_team(unit)
    if unit ~= nil then
        if unit:get() then
            if unit.get_team_id ~= nil then
                return unit:get_team_id()
            end
            return unit:get_team()
        end
    end
    return nil
end

function get_unit_altitude(unit)
    if unit ~= nil then
        if unit:get() then
            if unit.get_altitude ~= nil then
                return unit:get_altitude()
            end

            local reference = find_team_drydock(nil)
            if reference ~= nil then
                local rel = update_get_map_vehicle_position_relate_to_parent_vehicle(reference:get_id(), unit:get_id())
                return rel:y()
            end
        end
    end
    return 0
end

function get_missile_should_draw_trail(def)
    return def == e_game_object_type.torpedo or
            def == e_game_object_type.torpedo_decoy or
            def == e_game_object_type.torpedo_noisemaker or
    def == e_game_object_type.missile_cruise or
    def == e_game_object_type.missile_1 or
    def == e_game_object_type.missile_2 or
    def == e_game_object_type.missile_3 or
    def == e_game_object_type.missile_4 or
    def == e_game_object_type.missile_5
end

function render_ui_chassis_definition_description(x, y, vehicle, index)
    update_ui_push_offset(x, y)
    local cy = 0

    vehicle_definition_name, region_vehicle_icon, vehicle_definition_abreviation, vehicle_definition_description = get_chassis_data_by_definition_index(index)
    update_ui_text(0, cy, vehicle_definition_name, 120, 0, color_white, 0)

    local inventory_count = vehicle:get_inventory_count_by_definition_index(index)
    update_ui_text(0, cy, "x" .. inventory_count, 120, 2, iff(inventory_count > 0, color_status_ok, color_status_bad), 0)
    cy = cy + 10

    local text_h = update_ui_text(0, cy, vehicle_definition_description, 120, 0, color_grey_dark, 0)
    cy = cy + text_h + 2
    
    local hitpoints, armour, mass = update_get_definition_vehicle_stats(index)
    local icon_col = color_white
    local text_col = color_status_ok

    update_ui_image(0, cy, atlas_icons.icon_health, icon_col, 0)
    update_ui_text(10, cy, hitpoints, 64, 0, text_col, 0)
    cy = cy + 10

    update_ui_image(0, cy, atlas_icons.column_difficulty, icon_col, 0)
    update_ui_text(10, cy, armour, 64, 0, text_col, 0)
    cy = cy + 10

    update_ui_image(0, cy, atlas_icons.column_weight, icon_col, 0)
    update_ui_text(10, cy, mass .. update_get_loc(e_loc.upp_kg), 64, 0, text_col, 0)
    cy = cy + 10

    update_ui_pop_offset()
end

function get_is_vehicle_type_waypoint_capable(vehicle_definition_index)
    if vehicle_definition_index == e_game_object_type.chassis_carrier then
        return false
    elseif vehicle_definition_index == e_game_object_type.chassis_land_wheel_light then
        return true
    elseif vehicle_definition_index == e_game_object_type.chassis_land_wheel_medium then
        return true
    elseif vehicle_definition_index == e_game_object_type.chassis_land_wheel_heavy then
        return true
    elseif vehicle_definition_index == e_game_object_type.chassis_air_wing_light then
        return true
    elseif vehicle_definition_index == e_game_object_type.chassis_air_wing_heavy then
        return true
    elseif vehicle_definition_index == e_game_object_type.chassis_air_rotor_light then
        return true
    elseif vehicle_definition_index == e_game_object_type.chassis_air_rotor_heavy then
        return true
    elseif vehicle_definition_index == e_game_object_type.chassis_sea_barge then
        return false
    elseif vehicle_definition_index == e_game_object_type.chassis_land_turret then
        return false
    elseif vehicle_definition_index == e_game_object_type.chassis_sea_ship_light then
        return true
    elseif vehicle_definition_index == e_game_object_type.chassis_sea_ship_heavy then
        return true
    elseif vehicle_definition_index == e_game_object_type.chassis_land_wheel_mule then
        return true
    elseif vehicle_definition_index == e_game_object_type.chassis_deployable_droid then
        return true
    end

    return false
end

function get_vehicle_controlling_peers(vehicle)
    local peers = {}

    if not update_get_is_multiplayer() or vehicle:get_definition_index() == e_game_object_type.chassis_carrier then return peers end

    local attachment_count = vehicle:get_attachment_count()
    for i = 0, attachment_count - 1 do
        local attachment = vehicle:get_attachment(i)
        if attachment:get() then
            local peer_id = attachment:get_controlling_peer_id()

            if peer_id ~= 0 then
                local peer_ctrl = attachment:get_control_mode() == "manual"

                local peer_index = update_get_peer_index_by_id(peer_id)
                table.insert( peers, {
                    id = peer_id,
                    name = update_get_peer_name(peer_index),
                    ctrl = peer_ctrl,
                    attachment_index = i
                })
            end
        end
    end

    return peers
end


g_item_categories = {}
g_item_data = {}
g_item_count = 0

function begin_load_inventory_data()
    for i = 0, update_get_resource_inventory_category_count() - 1 do
        local category_index, category_name, icon_name = update_get_resource_inventory_category_data(i)
        local category_object = 
        {
            index = category_index, 
            name = category_name, 
            icon = atlas_icons[icon_name], 
            items = {},
            item_count = 0,
        }
        g_item_categories[category_index] = category_object

        if category_object.icon == nil then
            MM_LOG("icon not found: "..icon_name)
        end
    end

    for i = 0, update_get_resource_inventory_item_count() - 1 do
        local item_type, item_category, item_mass, item_production_cost, item_production_time, item_name, item_desc, icon_name, transfer_duration = update_get_resource_inventory_item_data(i)

        local item_object = 
        {
            index = item_type, 
            category = item_category, 
            mass = item_mass, 
            cost = item_production_cost, 
            time = item_production_time, 
            name = item_name,
            desc = item_desc, 
            icon = atlas_icons[icon_name],
            transfer_duration = transfer_duration,
        }
        -- print(string.format("%d %s %s", item_object.index, item_object.mass, item_object.name))
        g_item_data[item_type] = item_object
        g_item_count = g_item_count + 1
        
        if item_object.icon == nil then
            MM_LOG("icon not found: "..icon_name)
        end
    end

    for k, v in pairs(g_item_data) do
        local item_data = v
        local category_data = g_item_categories[item_data.category]
        
        if category_data ~= nil then
            table.insert(category_data.items, item_data)
            category_data.item_count = category_data.item_count + 1
        end
    end
end

function get_vehicle_capability(vehicle)
    local attachment_count = vehicle:get_attachment_count()

    local capabilities = {}

    for i = 0, attachment_count - 1 do
        local attachment = vehicle:get_attachment(i)

        if attachment:get() then
            local attachment_def = attachment:get_definition_index()

            if attachment_def ~= e_game_object_type.attachment_camera_vehicle_control then
               capabilities[attachment_def] = get_attachment_data_by_definition_index(attachment_def)
               capabilities[attachment_def].definition = attachment_def
            end
        end
    end

    local out = {}
    
    -- Big enough to iterate over all possible attachments
    for i = 0, 2000 do
        if capabilities[i] ~= nil and not capabilities[i].unknown then
            table.insert( out, capabilities[i] )
        end
    end

    return out
end

function join_strings(strings, delim)
    local str = ""

    for i = 1, #strings do
        if i > 1 then
            str = str .. (delim or ", ")
        end

        str = str .. strings[i]
    end

    return str
end

-- fisheye mod
g_all_radars = {}
g_radar_seen_by_ours = {}
g_radar_seen_by_hostile = {}

-- every unit in detection range of a radar (of any team)
g_seen_by_hostile_radars = {}
g_seen_by_friendly_radars = {}

-- the id of the nearest enemy unit that can see our aircraft
g_nearest_hostile_radar = {}
-- the id, pwr and dist, of the nearest friendly radar that can see hostile air
g_nearest_friendly_radar = {}


g_radar_ranges = {
    ciws = 7000,
    torpedo = 8000,
    cruise_missile = 9000,
    naval_gun = 4500,
}

g_radar_last_sea_scan = 0
g_radar_last_air_scan = 0
g_radar_min_return_power = 0.00018
g_radar_multiplier = 1

function get_radar_multiplier()
    -- get_special_waypoint(update_get_screen_team_id(), F_DRYDOCK_WPTX_SETTING)

    if g_override_radar_multiplier ~= nil then
        if g_override_radar_multiplier > 0 then
            g_radar_multiplier = g_override_radar_multiplier
        end
    end

    return g_radar_multiplier
end

if get_radar_multiplier() > 1 then
    -- extended range is enabled, model the extra range for the stock radars
    g_radar_ranges.awacs = 10000
    g_radar_ranges.carrier = 10000
    g_radar_ranges.golfball = 10000
end


function _get_radar_detection_range(definition_index)
    if definition_index == e_game_object_type.attachment_turret_carrier_ciws then
        return g_radar_ranges.ciws
    elseif definition_index == e_game_object_type.attachment_turret_carrier_torpedo then
        return g_radar_ranges.torpedo
    elseif definition_index == e_game_object_type.attachment_turret_carrier_missile_silo then
        return g_radar_ranges.cruise_missile
    elseif definition_index == e_game_object_type.attachment_turret_carrier_main_gun then
        return g_radar_ranges.naval_gun
    elseif definition_index == e_game_object_type.attachment_radar_awacs then
        return g_radar_ranges.awacs
    elseif definition_index == e_game_object_type.attachment_radar_golfball then
        return g_radar_ranges.golfball
    else
        return 0
    end
end

function _get_awacs_radar_attachment_position(vehicle)
    if vehicle and vehicle:get() then
        local attachment_count = vehicle:get_attachment_count()
        for i = 0, attachment_count - 1 do
            local attachment = vehicle:get_attachment(i)
            if attachment and attachment:get() then
                local definition_index = attachment:get_definition_index()
                if definition_index == e_game_object_type.attachment_radar_awacs then
                    return i
                end
            end
        end
    end
    return -1
end

function _get_radar_attachment(vehicle)
    if vehicle and vehicle:get() then
        if vehicle:get_definition_index() == e_game_object_type.chassis_carrier then
            return e_game_object_type.attachment_radar_awacs
        end

        local attachment_count = vehicle:get_attachment_count()
        for i = 0, attachment_count - 1 do
            local attachment = vehicle:get_attachment(i)
            if attachment and attachment:get() then
                local definition_index = attachment:get_definition_index()
                if ( false
                        or (definition_index == e_game_object_type.attachment_radar_golfball)
                        or (definition_index == e_game_object_type.attachment_radar_awacs)
                        or (definition_index == e_game_object_type.attachment_turret_carrier_ciws)
                        or (definition_index == e_game_object_type.attachment_turret_carrier_torpedo)
                        or (definition_index == e_game_object_type.attachment_turret_carrier_missile_silo)
                        or (definition_index == e_game_object_type.attachment_turret_carrier_main_gun)
                ) then
                    return definition_index
                end
            end
        end
    end
    return nil
end

function get_vehicle_radar(vehicle)
    return _get_radar_attachment(vehicle)
end

function get_is_vehicle_masked_by_groundclutter(vehicle)
    if vehicle and vehicle:get() then
        if get_is_vehicle_air(vehicle:get_definition_index()) then
            local pos = vehicle:get_position_xz()
            local waves = update_get_ocean_depth_factor(pos:x(), pos:y())
            local clutter_base = 40 + (90 * waves)
            local alt = get_unit_altitude(vehicle)
            return alt < clutter_base
        end
    end
    return false
end

function get_modded_radar_range(vehicle)
    if vehicle:get() then

        if g_revolution_override_radar_range ~= nil then
            local r_range = g_revolution_override_radar_range(vehicle)
            if r_range ~= nil then
                return r_range
            end
        end

        -- don't override the carrier radar range
        local parent_id = vehicle:get_attached_parent_id()
        if parent_id ~= 0 then
            -- don't compute radars for docked units
            return 0
        end

        local def =  vehicle:get_definition_index()
        if def ~= e_game_object_type.chassis_carrier then
            local range = _get_radar_detection_range(_get_radar_attachment(vehicle))

            -- adjust based on altitude for awacs
            if get_is_vehicle_air(def) then
                if get_awacs_alt_boost_enabled() then
                    local alt_boost = get_awacs_alt_boost_factor()
                    if alt_boost > 0 then
                        -- if altitude is > 1600, boost it slightly
                        local alt = get_unit_altitude(vehicle)
                        local bonus_start = get_awacs_alt_boost_start()
                        if alt > bonus_start then
                            local bonus_factor = alt / bonus_start
                            range = range * bonus_factor * alt_boost
                        end
                    end
                end
            end
            if range ~= nil then
                return range * get_radar_multiplier()
            end
        elseif get_awacs_radar_enabled(vehicle) then
            return 10000 * get_radar_multiplier()
        end
    end
    return 0
end

function _get_unit_visible_by_modded_radar(vehicle, other_unit)
    if vehicle:get() and other_unit:get() then
        if vehicle:get_team() == other_unit:get_team() then
            return false
        end
        if vehicle:get_id() ~= other_unit:get_id() then
            local radar_unit_def = vehicle:get_definition_index()
            local dist_sq = vec2_dist_sq(vehicle:get_position_xz(), other_unit:get_position_xz())
            local mrr = get_modded_radar_range(vehicle)
            local mrr_sq = mrr * mrr
            if dist_sq < mrr_sq then
                local unit_def = other_unit:get_definition_index()

                -- target is within the max range of this radar
                -- now filter out different target types

                -- if this is an awacs or golfball, do not detect ships beyond 10km
                if get_is_vehicle_air(radar_unit_def) or get_is_vehicle_land(radar_unit_def) then
                    if get_is_vehicle_sea(unit_def) then
                        local max_ship_range = get_awacs_max_ship_detection_range()
                        if dist_sq > (max_ship_range * max_ship_range) then
                            return false
                        end
                    end
                end

                if get_is_ship_fish(vehicle:get_definition_index()) then
                    -- needlefish can all see anything less than 500m away
                    if dist_sq < 250000 then
                        return true
                    end
                end

                -- print(string.format("a %d b %d dist = %d", needlefish:get_id(), unit:get_id(), math.floor(dist)))
                local radar_type = _get_radar_attachment(vehicle)
                if radar_type == e_game_object_type.attachment_radar_awacs
                    or radar_type == e_game_object_type.attachment_radar_golfball
                then
                    -- awacs and gnd radar can see ships and aircraft at range
                    return get_is_vehicle_air(unit_def) or get_is_vehicle_sea(unit_def)
                elseif radar_type == e_game_object_type.attachment_turret_carrier_ciws then
                    -- ciws fish can see only aircraft,
                    return get_is_vehicle_air(unit_def)
                elseif radar_type == e_game_object_type.attachment_turret_carrier_torpedo then
                    -- torp fish can see only ships
                    return get_is_vehicle_sea(unit_def)
                elseif radar_type == e_game_object_type.attachment_turret_carrier_missile_silo then
                    -- cruise fish can see only ships
                    return get_is_vehicle_sea(unit_def)
                elseif radar_type == e_game_object_type.attachment_turret_carrier_main_gun then
                    -- gun fish can see only ships
                    return get_is_vehicle_sea(unit_def)
                end
            end
        end
    end
    return false
end

function get_awacs_radar_enabled(vehicle)
    -- if enabled and not damaged
    if vehicle and vehicle:get() then
        local radar_pos = _get_awacs_radar_attachment_position(vehicle)
        if radar_pos > -1 then
            if vehicle:get_definition_index() == e_game_object_type.chassis_carrier then
                local carrier_radar = vehicle:get_attachment(radar_pos)
                if carrier_radar ~= nil then
                    local radar_mode = carrier_radar:get_control_mode()
                    if radar_mode == "off" then
                        return false
                    end
                    if carrier_radar.get_is_damaged ~= nil and carrier_radar:get_is_damaged() then
                        return false
                    end
                    if get_radar_interference(vehicle, carrier_radar) then
                        return false
                    end
                else
                    -- no radar fitted?
                    return false
                end
            end
            return true
        end
    end

    return false
end

function refresh_modded_radar_cache()
    local st, err = pcall(update_modded_radar_data)
    if not st then
        print(err)
    end
end

function get_nearest_hostile_aew_radar(vid)
    local nearest_hostile = g_nearest_hostile_radar[vid]
    if nearest_hostile ~= nil then
        local hostile_radar = update_get_map_vehicle_by_id(nearest_hostile)
        if hostile_radar and hostile_radar:get() then
            return hostile_radar
        end
    end
    return nil
end

function get_nearest_hostile_radar(vid)
    -- used by HUD RWR
    local rwr_vehicle = update_get_map_vehicle_by_id(vid)
    if rwr_vehicle and rwr_vehicle:get() then
        local rwr_team = get_vehicle_team_id(rwr_vehicle)
        local rwr_pos = nil
        local use_2d = false
        if rwr_vehicle.get_position ~= nil then
            rwr_pos = rwr_vehicle:get_position()
        else
            use_2d = true
            rwr_pos = rwr_vehicle:get_position_xz()
        end
        local dist_sq = 19000 * 19000
        local nearest = nil

        for i, item in pairs(g_all_radars) do
            local radar_id = item.id
            local radar = update_get_map_vehicle_by_id(radar_id)
            if radar and radar:get() then
                local radar_team = get_vehicle_team_id(radar)
                if radar_team ~= rwr_team then
                    -- hostile, calc dist
                    local d = dist_sq
                    if use_2d then
                        d = vec2_dist_sq(rwr_pos, radar:get_position_xz())
                    else
                        d = vec3_dist_sq(rwr_pos, radar:get_position())
                    end
                    if d < dist_sq then
                        dist_sq = d
                        nearest = radar
                    end
                end
            end
        end
        if nearest and dist_sq < (18000 * 18000) then
            return nearest, math.sqrt(dist_sq)
        end
    end
    return nil, 0
end

function get_nearest_friendly_aew_radar(vid)
    local nearest_radar = g_nearest_friendly_radar[vid]
    if nearest_radar ~= nil then
        local radar = update_get_map_vehicle_by_id(nearest_radar.id)
        if radar and radar:get() then
            return radar, nearest_radar.power
        end
    end
    return nil, 0
end

function get_radar_power(vid)
    local radar, pwr = get_nearest_friendly_aew_radar(vid)
    if radar ~= nil then
        return pwr
    end
    return 0
end

function get_is_masked_by_stealth(vehicle)
    if get_rcs_model_enabled() then
        if vehicle and vehicle:get() then
            if get_vehicle_team_id(vehicle) ~= update_get_screen_team_id() then
                local vdef = vehicle:get_definition_index()
                if get_is_vehicle_air(vdef) then
                    local pwr = get_radar_power(vehicle:get_id())
                    if pwr > 0 then
                        if pwr < g_radar_min_return_power then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

function update_modded_radar_list(hostile_only)
    local screen_team = update_get_screen_team_id()
    local vehicle_count = update_get_map_vehicle_count()

    for i = 0, vehicle_count - 1 do
        local vehicle = update_get_map_vehicle_by_index(i)
        if vehicle:get() and not get_vehicle_docked(vehicle) then
            local vehicle_team = get_vehicle_team_id(vehicle)
            if vehicle_team ~= screen_team or not hostile_only then

                local radar_type = _get_radar_attachment(vehicle)

                if radar_type ~= nil then
                    if radar_type == e_game_object_type.attachment_radar_awacs then
                        if not get_awacs_radar_enabled(vehicle) then
                            radar_type = nil
                        end
                    end
                end
                if radar_type ~= nil then

                    local vid = vehicle:get_id()
                    g_all_radars[vid] = {
                        id = vid,
                        type = radar_type
                    }

                end
            end
        end
    end

    -- clean the caches
    for vid, _ in pairs(g_seen_by_friendly_radars) do
        local v = update_get_map_vehicle_by_id(vid)
        if v == nil or not v:get() then
            g_seen_by_friendly_radars[vid] = nil
        end
    end
    for vid, _ in pairs(g_seen_by_hostile_radars) do
        local v = update_get_map_vehicle_by_id(vid)
        if v == nil or not v:get() then
            g_seen_by_hostile_radars[vid] = nil
        end
    end
end

function update_modded_radar_data()
    -- find all radars
    local current_tick = update_get_logic_tick()
    local next_air_scan = g_radar_last_air_scan + 15
    local next_sea_scan = g_radar_last_sea_scan + 32
    local user_connected = true
    local script_id = string.format("%s", _G)
    if not update_get_is_focus_local() then
        local disconnected_delay_base = 250
        if g_is_holomap then
            disconnected_delay_base = 60
            script_id = script_id .. " holomap"
        end
        -- not connected, reduce the frequency to once every 5-7 seconds
        next_air_scan = g_radar_last_air_scan + disconnected_delay_base + math.floor(math.random(30, 90))
        next_sea_scan = g_radar_last_sea_scan + disconnected_delay_base + math.floor(math.random(40, 80))
        user_connected = false
    end

    local update_air = current_tick > next_air_scan
    local update_sea = current_tick > next_sea_scan

    if not user_connected and not g_is_holomap then
        if not update_sea and not update_air then
            -- do nothing
            return
        end
    end

    local vehicle_count = update_get_map_vehicle_count()
    local screen_team = update_get_screen_team_id()
    g_all_radars = {}
    g_nearest_hostile_radar = {}

    update_modded_radar_list(false)

    if not update_air and not update_sea then
        return
    end

    if g_radar_debug then
        -- print(string.format("update %s air=%s sea=%s local=%s", script_id, update_air, update_sea, user_connected))
    end

    if update_sea then
        g_radar_last_sea_scan = current_tick
    end
    if update_air then
        g_radar_last_air_scan = current_tick
    end

    -- now calculate radar detection for each radar
    for i = 0, vehicle_count - 1 do
        local vehicle = update_get_map_vehicle_by_index(i)
        if vehicle:get() then
            local vteam = get_vehicle_team_id(vehicle)
            local vdef = vehicle:get_definition_index()
            local vid = vehicle:get_id()
            if get_is_vehicle_land(vdef) then
                -- ignore land units
            else
                if get_vehicle_docked(vehicle) or (get_is_vehicle_air(vdef) and get_unit_altitude(vehicle) < get_low_level_radar_altitude(vehicle)) then
                    -- ignore docked or landed
                else
                    local target_is_air = get_is_vehicle_air(vdef)
                    local target_is_sea = get_is_vehicle_sea(vdef)

                    if update_sea and target_is_sea or update_air and target_is_air then
                        g_seen_by_friendly_radars[vid] = nil
                        g_nearest_hostile_radar[vid] = nil
                        g_seen_by_hostile_radars[vid] = nil

                        local radar_return_power = 0
                        local nearest_hostile_radar_dist_sq = 999999
                        for _, radar in pairs(g_all_radars) do
                            local radar_id = radar.id
                            local radar_vehicle = update_get_map_vehicle_by_id(radar_id)
                            if radar_vehicle and radar_vehicle:get() then
                                local radar_team = get_vehicle_team_id(radar_vehicle)
                                -- dont scan the same team as the radar
                                -- and dont give needlefish "nails" from AI units
                                if radar_team ~= vteam and get_team_has_humans(radar_team) then
                                    local radar_range = get_modded_radar_range(radar_vehicle)
                                    if update_sea and target_is_sea then
                                        -- target is a ship
                                        local target_dist_sq = vec2_dist_sq(radar_vehicle:get_position_xz(), vehicle:get_position_xz())
                                        if target_dist_sq < (radar_range * radar_range) then
                                            -- ship seen
                                            if radar_team == screen_team then
                                                g_seen_by_friendly_radars[vid] = true
                                            else
                                                if target_dist_sq < nearest_hostile_radar_dist_sq then
                                                    nearest_hostile_radar_dist_sq = target_dist_sq
                                                    g_nearest_hostile_radar[vid] = radar_id
                                                end
                                                g_seen_by_hostile_radars[vid] = true
                                            end
                                        end
                                    else
                                        -- update air
                                        if screen_team ~= radar_team then
                                            -- update our nails
                                            -- we can hear a hostile radar
                                            local target_dist_sq = vec2_dist_sq(radar_vehicle:get_position_xz(), vehicle:get_position_xz())
                                            if target_dist_sq < (radar_range * radar_range) then
                                                if target_dist_sq < nearest_hostile_radar_dist_sq then
                                                    nearest_hostile_radar_dist_sq = target_dist_sq
                                                    g_nearest_hostile_radar[vid] = radar_id
                                                end
                                                g_seen_by_hostile_radars[vid] = true
                                            end
                                        else
                                            -- did any of our radars see this target?
                                            local power = get_radar_return_power(vehicle, radar_vehicle, radar_range)
                                            if power > radar_return_power then
                                                radar_return_power = power
                                                if power > 0.00002 then
                                                    g_nearest_friendly_radar[vid] = {
                                                        id = radar_id,
                                                        power = power,
                                                    }
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        -- radar_return_power is only ever set by a friendly radar
                        if radar_return_power > 0.00002 then
                            if radar_team == screen_team then
                                g_seen_by_friendly_radars[vid] = true
                            end
                        end
                    end
                end
            end
        end
    end
end

function get_is_radar(vehicle_id)
    return g_all_radars[vehicle_id] ~= nil
end

function get_is_visible_by_modded_radar(vehicle)
    local st, val = pcall(_get_is_seen_by_friendly_modded_radar, vehicle)
    if not st then
        return false
    end
    return val
end

function get_is_visible_by_hostile_modded_radar(vehicle)
    local seen = false
    if vehicle and vehicle:get() then
        local vid = vehicle:get_id()
        seen = g_seen_by_hostile_radars[vid] ~= nil
    end
    return seen
end

function _get_is_seen_by_friendly_modded_radar(vehicle)
    if vehicle and vehicle:get() then
        local vid = vehicle:get_id()
        local vdef = vehicle:get_definition_index()

        if get_is_spectator_mode() then
            return get_is_vehicle_land(vdef) or get_is_vehicle_air(vdef) or get_is_vehicle_sea(vdef)
        end

        if get_is_vehicle_air(vdef) and get_rcs_model_enabled() then
            local radar, pwr = get_nearest_friendly_aew_radar(vid)
            if radar ~= nil then
                local seen = pwr > g_radar_min_return_power
                return seen
            end
        else
            local exists = g_seen_by_friendly_radars[vid]
            if exists ~= nil then
                return true
            end
        end
    end
    return false
end

-- fog of war mod --

g_fow_visible = {}
g_fow_last_tick = 0
g_fow_range = 12000 * get_radar_multiplier()

g_island_color_unknown = color8(0x12, 0x12, 0x12, 0xff)

function refresh_fow_islands()
    -- only do this every 2 seconds
    local now = update_get_logic_tick()

    if g_fow_last_tick + 60 < now then
        g_fow_last_tick = now
        g_fow_visible = {}
        local visible = 0
        -- reveal any island within 16km of one of our units
        local our_team = update_get_screen_team_id()
        local island_count = update_get_tile_count()
        local vehicle_count = update_get_map_vehicle_count()

        local fow_range_sq = g_fow_range * g_fow_range

        for i = 0, island_count - 1 do
            local island = update_get_tile_by_index(i)
            local island_id = island:get_id()
            if island:get_team_control() == our_team then
                g_fow_visible[island_id] = true
                visible = visible + 1
            else
                local pos = island:get_position_xz()
                -- foreign island, find any of our units in range
                for j = 0, vehicle_count - 1, 1 do
                    local vehicle = update_get_map_vehicle_by_index(j)
                    if vehicle:get() and vehicle:get_team() == our_team then
                        if not get_vehicle_docked(vehicle) then
                            local unit_pos = vehicle:get_position_xz()
                            local dist = vec2_dist_sq(unit_pos, pos)
                            if dist < fow_range_sq then
                                --print(string.format("%s visible at %d km (< %d km)", island:get_name(),
                                --        math.floor(dist/1000),
                                --        math.floor(g_fow_range/1000)
                                --))
                                g_fow_visible[island_id] = true
                                visible = visible + 1
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

function fow_island_visible(island_id)
    return g_fow_visible[island_id] == true or get_is_spectator_mode()
end


function get_nearest_island_tile(x, y)
    local tile_count = update_get_tile_count()
    local index = 0
    local nearest = nil
    local dist = 99999

    local pos = vec2(x, y)

    while index < tile_count do
        local tile = update_get_tile_by_index(index)
        if tile:get() then
            index = index + 1
            local tile_pos = tile:get_position_xz()
            local tile_dist = vec2_dist(pos, tile_pos)

            if tile_dist < dist then
                dist = tile_dist
                nearest = tile
            end
        end
    end
    return nearest
end

function render_team_holomap_cursor(team_id)
    -- render captain's holomap cursor
    local holomap_x, holomap_y = get_team_holomap_cursor(team_id)
    if holomap_x == 0 and holomap_y == 0 then
        return
    end

    if g_holomap_last == nil then
        g_holomap_last = {}
    end
    if g_holomap_last[team_id] == nil then
        g_holomap_last[team_id] = {0, 0, 0}
    end

    if holomap_x ~= g_holomap_last[team_id][1] or holomap_y ~= g_holomap_last[team_id][2] then
        g_holomap_last[team_id][1] = holomap_x
        g_holomap_last[team_id][2] = holomap_y
        g_holomap_last[team_id][3] = g_animation_time
    end

    local fade = math.max( 255 - math.floor(g_animation_time - g_holomap_last[team_id][3]), 0 )
    if fade > 0 then
        local cursor_x = 0
        local cursor_y = 0
        if g_is_holomap then
            cursor_x, cursor_y = get_holomap_from_world( holomap_x, holomap_y, g_screen_w, g_screen_h)
        else
            cursor_x, cursor_y = get_screen_from_world( holomap_x, holomap_y, g_camera_pos_x, g_camera_pos_y, g_camera_size, g_screen_w, g_screen_h)
        end
        update_ui_image_rot(cursor_x, cursor_y, atlas_icons.map_icon_crosshair, color8(255, 255, 255, fade), math.pi / 4)
        if get_is_spectator_mode() then
            local team_name = get_team_name(team_id)
            update_ui_text(cursor_x + 10, cursor_y + 10, team_name, 64, 0, color8(255, 255, 255, fade), 0)
        end
    end
end

-- ai team check

function get_team_has_humans(team_id)
    local current_team = update_get_screen_team_id()
    if current_team == team_id then
        -- easy shortcut
        return true
    end

    -- look through multiplier members, if a pear doesnt have the same team ID as us, then that
    -- team is human controlled, else it's AI controlled or nobody has joined it
    local peer_count = update_get_peer_count()

    for i = 0, peer_count - 1 do
        local team = update_get_peer_team(i)
        if team == team_id then
            return true
        end
    end

    return false
end


-- Radar cross section

g_vehicle_rcs = {}
g_vehicle_rcs[e_game_object_type.chassis_air_wing_heavy] = 0.2
g_vehicle_rcs[e_game_object_type.chassis_air_wing_light] = 1.5
g_vehicle_rcs[e_game_object_type.chassis_air_rotor_light] = 1.8
g_vehicle_rcs[e_game_object_type.chassis_air_rotor_heavy] = 2.2

g_attachment_rcs = {}
g_attachment_rcs[e_game_object_type.attachment_radar_awacs] = 2.5
g_attachment_rcs[e_game_object_type.attachment_turret_rocket_pod] = 0.8
g_attachment_rcs[e_game_object_type.attachment_hardpoint_torpedo] = 0.7
g_attachment_rcs[e_game_object_type.attachment_hardpoint_torpedo_noisemaker] = 0.7
g_attachment_rcs[e_game_object_type.attachment_hardpoint_torpedo_decoy] = 0.6
g_attachment_rcs[e_game_object_type.attachment_turret_gimbal_30mm] = 0.65
g_attachment_rcs[e_game_object_type.attachment_camera_plane] = 0.8
g_attachment_rcs[e_game_object_type.attachment_turret_plane_chaingun] = 0.4
g_attachment_rcs[e_game_object_type.attachment_hardpoint_bomb_3] = 0.4
g_attachment_rcs[e_game_object_type.attachment_hardpoint_bomb_2] = 0.35
g_attachment_rcs[e_game_object_type.attachment_fuel_tank_plane] = 0.35
g_attachment_rcs[e_game_object_type.attachment_hardpoint_bomb_1] = 0.3
g_attachment_rcs[e_game_object_type.attachment_hardpoint_missile_ir] = 0.17
g_attachment_rcs[e_game_object_type.attachment_hardpoint_missile_laser] = 0.2
g_attachment_rcs[e_game_object_type.attachment_hardpoint_missile_aa] = 0.25
g_attachment_rcs[e_game_object_type.attachment_hardpoint_missile_tv] = 0.12
g_attachment_rcs[e_game_object_type.attachment_flare_launcher] = 0.1

g_rcs_cache = {}

function get_rcs(vehicle)
    local rcs = nil

    if vehicle and vehicle:get() then
        local vdef = vehicle:get_definition_index()
        if get_is_vehicle_air(vdef) then
            if not get_rcs_model_enabled() then
                return 2.3 -- yields 10km range for a 10km radar
            end
            local is_manta = vdef == e_game_object_type.chassis_air_wing_heavy
            rcs = g_vehicle_rcs[vdef]
            if rcs ~= nil then
                for ai = 0, vehicle:get_attachment_count() - 1 do
                    -- manta has internal gun, exclude from RCS
                    local attachment = vehicle:get_attachment(ai)
                    if attachment:get() then
                        local a_def = attachment:get_definition_index()
                        local a_rcs = g_attachment_rcs[a_def]

                        if is_manta and ai == 9 then
                            -- manta internal gun
                            a_rcs = 0
                        end

                        if a_def == e_game_object_type.attachment_fuel_tank_plane then
                            -- cant figure out how to know if a tank has been dropped, but lets say if it is empty
                            -- we halve the RCS of the pod
                            a_rcs = (a_rcs / 2) + a_rcs * attachment:get_fuel_factor() * 0.5
                        else
                            -- for missiles, bombs, torps etc reduce rcs to 0 if the ammo is zero
                            if a_def ~= e_game_object_type.attachment_turret_plane_chaingun and
                                    a_def ~= e_game_object_type.attachment_turret_gimbal_30mm and
                                    a_def ~= e_game_object_type.attachment_turret_droid and
                                    a_def ~= e_game_object_type.attachment_flare_launcher and
                                    a_def ~= e_game_object_type.attachment_turret_rocket_pod and
                                    a_def ~= e_game_object_type.attachment_radar_awacs
                            then
                                if attachment then
                                    local ammo = 0
                                    if attachment.get_ammo_factor ~= nil then
                                        ammo = attachment:get_ammo_factor()
                                    end
                                    if attachment.get_ammo_remaining ~= nil then
                                        ammo = attachment:get_ammo_remaining()
                                    end
                                    if ammo == 0 then
                                        a_rcs = 0
                                    end
                                end
                            end
                        end

                        if a_rcs ~= nil and a_rcs > 0 then
                            rcs = rcs + a_rcs
                        end

                    end
                end

                if rcs and rcs > 0 then
                    if vdef == e_game_object_type.chassis_air_rotor_heavy then
                        if vehicle_has_cargo(vehicle) then
                            rcs = rcs * 1.3
                        end
                    else
                        if get_vehicle_health_factor(vehicle) < 0.9 then
                            -- damaged units have higher RCS
                            rcs = rcs * 1.3
                            if rcs < 1.5 then
                                rcs = 1.5
                            end
                        end
                    end

                    if rcs > 2.5 then
                        rcs = 2.5
                    elseif rcs < 1.7 then
                        rcs = 1.7
                    end
                end
            end
        end
    end
    return rcs
end

function get_rcs_cached(vehicle)
    local rcs = nil
    local cached_ticks = 120
    if vehicle and vehicle:get() then
        local vid = vehicle:get_id()
        local cached = g_rcs_cache[vid]
        local now = update_get_logic_tick()

        if cached ~= nil then
            if now > cached.expire then
                cached = nil
            end
        end
        if cached == nil then
            local v_rcs = get_rcs(vehicle)
            if v_rcs ~= nil then
                g_rcs_cache[vid] = {
                    expire = now + cached_ticks,
                    rcs = v_rcs
                }
                cached = g_rcs_cache[vid]
            end
        end

        if cached ~= nil then
            rcs = cached.rcs
        end
    end
    return rcs
end

function get_radar_return_power(target, radar, radar_range)
    if radar_range > 0 and target and target:get() then
        local rcs = get_rcs_cached(target)
        if rcs ~= nil and rcs > 0 then
            local radar_power = radar_range * 10
            local dist_sq = vec2_dist_sq(target:get_position_xz(), radar:get_position_xz())
            local intensity = radar_power / (4 * math.pi * dist_sq)
            -- i = e/rcs
            -- e = i * rcs
            local reflection = rcs * intensity
            return reflection
        end
    end
    return 0
end

function get_rcs_detection_range(rcs)
    if rcs > 0 then
        local pwr = 0
        local dist = 50000
        while pwr < g_radar_min_return_power do
            dist = dist - 250
            local radar_power = 10000 * 10
            local intensity = radar_power / (4 * math.pi * dist * dist)
            pwr = rcs * intensity
        end
        return (dist/1000)
    end
    return 0
end

function get_vehicle_health_factor(vehicle)
    if vehicle and vehicle:get() then
        return vehicle:get_hitpoints() / vehicle:get_total_hitpoints()
    end
    return 0
end

function get_has_rwr(vehicle)
    if vehicle and vehicle:get() then
        local def = vehicle:get_definition_index()
        if def == e_game_object_type.chassis_air_wing_heavy
                or def == e_game_object_type.chassis_air_rotor_heavy
                or def == e_game_object_type.chassis_air_rotor_light
                or def == e_game_object_type.chassis_air_wing_light
        then
            return true
        end
    end

    return false
end

-- drydock waypoint share system
--
-- it's easy to create waypoints, but we can't efficiently use the x,y as if we need
-- to move the waypoint we have to clear all and replace them which is slow and expensive.
--
-- for the holomap waypoint, we transmit the location to the nearest 16m (1m accuracy is useless)
-- we do this by packing x/y into the 32bit unsigned altitude value

-- we use the x,y value of the waypoint as a flag value for us to identify the waypoint

F_DRYDOCK_WPTX_CURSOR   = 0x01
F_DRYDOCK_WPTX_MARKER   = 0x02
F_DRYDOCK_WPTX_SETTING  = 0x04
F_DRYDOCK_WPTX_FACTORY_DAMAGED = 0x08

-- y() values for settings waypoints
WPT_SETTING_RADAR_X1   = 1  -- no multiplier
WPT_SETTING_RADAR_X1_5 = 2  -- x1.5
WPT_SETTING_RADAR_X2   = 3  -- x2

MARKER_WPT_OFFSET = 80000

MASK_DRYDOCK_WPTX_FLAGS = 0x00000000FF

g_team_drydock = nil

function find_team_drydock(team_id)
    local want_curren_team = false
    if team_id == nil then
        team_id = update_get_screen_team_id()
    end
    if team_id == update_get_screen_team_id() then
        want_curren_team = true
        if g_team_drydock ~= nil then
            return g_team_drydock
        end
    end

    local vehicle_count = update_get_map_vehicle_count()
    for i = 0, vehicle_count - 1, 1 do
        local vehicle = update_get_map_vehicle_by_index(i)
        if vehicle:get() then
            if vehicle:get_definition_index() == e_game_object_type.drydock then
                if get_unit_team(vehicle) == team_id then
                    if want_curren_team then
                        g_team_drydock = vehicle
                    end
                    return vehicle
                end
            end
        end
    end
    return nil -- shouldn't really happen
end

function set_airlift_now(petrel, cargo)
    local pos = petrel:get_position_xz()
    petrel:clear_waypoints()
    petrel:clear_attack_target()
    local wid = petrel:add_waypoint(pos:x(), pos:y() - 10)
    petrel:set_waypoint_attack_target_target_id(wid, cargo)
    petrel:set_waypoint_attack_target_attack_type(wid, 0, e_attack_type.airlift)
end

function set_airdrop_now(petrel)
    local pos = petrel:get_position_xz()
    petrel:clear_waypoints()
    petrel:clear_attack_target()
    local wid = petrel:add_waypoint(pos:x(), pos:y() - 10)
    petrel:set_waypoint_type_deploy(wid, true)
end

function vehicle_can_airlift(vehicle)
    if vehicle:get() then
        local def = vehicle:get_definition_index()
        if def == e_game_object_type.chassis_air_rotor_heavy then
            -- if this petrel has a radar, it cant airlift
            local radar = _get_radar_attachment(vehicle)
            return radar == nil
        end
    end
    return false
end

function vehicle_has_cargo(vehicle)
    return vehicle:get_attached_vehicle_id(0) ~= 0
end

function get_vehicle_cargo_id(vehicle)
    if vehicle_has_cargo(vehicle) then
        return vehicle:get_attached_vehicle_id(0)
    end
    return nil
end

function get_nearest_unit(team, pos, max_range)

end

function get_nearest_friendly_airliftable_id(vehicle, max_range, force)
    if force == nil then
        force = false
    end
    if vehicle ~= nil and (force or vehicle_can_airlift(vehicle)) then
        -- petrel
        if force or not vehicle_has_cargo(vehicle) then
            local nearest = find_nearest_vehicle_types(vehicle,
                    {
                        e_game_object_type.chassis_land_wheel_mule,
                        e_game_object_type.chassis_land_wheel_heavy,
                        e_game_object_type.chassis_land_wheel_medium,
                        e_game_object_type.chassis_land_wheel_light,
                    }, false)
            if nearest ~= nil then
                local origin = get_pos_xz(vehicle)
                local nearest_dist = vec2_dist(origin, get_pos_xz(nearest))
                if nearest_dist < max_range then
                    return nearest:get_id(), nearest_dist
                end
            end
        end
    end
    return -1, 0
end

function waypoint_flag_isset(waypoint, flag)
    local position = waypoint:get_position_xz()
    if math.floor(position:x()) & flag ~= 0 then
        return true
    end
    return false
end

function is_waypoint_value_enabled(value)
    if value == nil then
        return false
    end
    return value ~= 0
end

function unpack_alt_xy(altitude)
    if altitude > 0 then
        local shifted_x = math.floor((altitude / 0x10000)) & 0xffff
        local shifted_y = math.floor(altitude) & 0xffff
        local cursor_x = (16 * shifted_x) - MARKER_WPT_OFFSET
        local cursor_y = (16 * shifted_y) - MARKER_WPT_OFFSET
        return cursor_x, cursor_y
    end
    return 0, 0
end

function pack_alt_xy(x, y)
    local shifted_x = math.floor((x + MARKER_WPT_OFFSET) / 16)
    local shifted_y = math.floor((y + MARKER_WPT_OFFSET) / 16)

    if shifted_x <= 0xFFFF and shifted_y <= 0xFFFF then
        -- store it in altitude
        local packed = (shifted_x * 0x10000) | shifted_y
        return packed
    end
    return 0
end


function get_team_holomap_cursor_waypoint(team_id)
    local drydock = find_team_drydock(team_id)
    if drydock then
        local waypoint_count = drydock:get_waypoint_count()
        for i = 0, waypoint_count - 1, 1 do
            local waypoint = drydock:get_waypoint(i)
            if waypoint_flag_isset(waypoint, F_DRYDOCK_WPTX_CURSOR) then
                return waypoint
            end
        end
    end
    return nil
end

function get_marker_name(marker_id)
    if marker_id == 1 then
        return "W"
    end
    if marker_id == 2 then
        return "X"
    end
    if marker_id == 3 then
        return "Y"
    end
    if marker_id == 4 then
        return "Z"
    end
    return ""
end

function get_special_waypoint(team_id, flag, special_id)
    local drydock = find_team_drydock(team_id)
    if drydock then
        local waypoint_count = drydock:get_waypoint_count()
        for i = 0, waypoint_count - 1, 1 do
            local waypoint = drydock:get_waypoint(i)
            if waypoint ~= nil then
                if waypoint_flag_isset(waypoint, flag) then
                    local pos = waypoint:get_position_xz()
                    if math.floor(pos:y()) == special_id then
                        return waypoint
                    end
                end
            end
        end
    end
    return nil
end

function get_marker_waypoint(team_id, marker_id)
    return get_special_waypoint(team_id, F_DRYDOCK_WPTX_MARKER, marker_id)
end

function add_special_waypoint(team_id, flag, special_id)
    local current = get_special_waypoint(team_id, flag, special_id)
    local drydock = find_team_drydock(team_id)

    if drydock == nil then
        return nil
    end

    if current == nil then
        -- add one
        local w_id = drydock:add_waypoint(flag, special_id)
        drydock:set_waypoint_altitude(w_id, 0)
        current = drydock:get_waypoint_by_id(w_id)
        return w_id
    end

    return current:get_id()
end

function add_marker_waypoint(team_id, marker_id)
    return add_special_waypoint(team_id, F_DRYDOCK_WPTX_MARKER, marker_id)
end

g_pending_marker_values = {}

function ensure_marker_value(team_id, marker_id)
    -- called early in the holomap update function only
    if is_marker_value_pending(marker_id) then
        -- is it set?
        local expected = g_pending_marker_values[marker_id]
        local wpt = get_marker_waypoint(team_id, marker_id)
        if wpt ~= nil then
            local current = wpt:get_altitude()
            if current ~= expected then
                -- try to set it (again)
                local drydock = find_team_drydock(team_id)
                drydock:set_waypoint_altitude(wpt:get_id(), expected)
            else
                -- it is correct
                g_pending_marker_values[marker_id] = nil
            end
        end
    end
end

function set_marker_pending(marker_id, value)
    g_pending_marker_values[marker_id] = value
end

function is_marker_value_pending(marker_id)
    local pending = g_pending_marker_values[marker_id]
    return pending ~= nil
end

function get_marker_value(team_id, marker_id)
    if is_marker_value_pending(marker_id) then
        return g_pending_marker_values[marker_id]
    end
    local marker = get_marker_waypoint(team_id, marker_id)
    if marker ~= nil then
        return marker:get_altitude()
    end
    return 0
end

function set_marker_waypoint(team_id, marker_id, x, y)
    if update_get_is_focus_local() then
        if is_marker_value_pending(marker_id) then
            return
        end

        local marker = get_marker_waypoint(team_id, marker_id)
        if marker ~= nil then
            local drydock = find_team_drydock(team_id)
            local packed = pack_alt_xy(x, y)
            set_marker_pending(marker_id, packed)
            drydock:set_waypoint_altitude(marker:get_id(), packed)
        end
    end
end

function unset_marker_waypoint(team_id, marker_id)
    set_marker_pending(marker_id, 0)
    local marker = get_marker_waypoint(team_id, marker_id)
    if marker ~= nil then
        local drydock = find_team_drydock(team_id)
        drydock:set_waypoint_altitude(marker:get_id(), 0)
    end
end

function update_team_holomap_cursor(team_id, x, y)
    local st, err = pcall(_update_team_holomap_cursor, team_id, x, y)
    if not st then
        print(err)
    end
end

function _update_team_holomap_cursor(team_id, x, y)
    local current = get_team_holomap_cursor_waypoint(team_id)
    local drydock = find_team_drydock(team_id)

    if drydock == nil then
        return
    end

    if current == nil then
        -- add one
        if drydock ~= nil then
            local w_id = drydock:add_waypoint(F_DRYDOCK_WPTX_CURSOR, 0)
            current = drydock:get_waypoint_by_id(w_id)
        end
    end

    if current ~= nil then
        -- update the altitude to the packed waypoint
        local packed = pack_alt_xy(x, y)
        if packed > 0 then
            drydock:set_waypoint_altitude(current:get_id(), packed)
        end
    end
end

function get_team_holomap_cursor(team_id)
    local current = get_team_holomap_cursor_waypoint(team_id)
    if current ~= nil then
        -- unpack it,
        local altitude = current:get_altitude()
        return unpack_alt_xy(altitude)
    end

    return 0, 0
end

g_ship_name_pseudo = 0
g_ship_name_pseud2 = 0

g_ship_names_choices = {
    {
        -- Classes of Westerly Yachts
        "CENTAUR",
        "FULMAR",
        "KONSORT",
        "LONGBOW",
        "MERLIN",
        "DISCUS",
        "NOMAD",
        "NIMROD",
        "RENOWN",
        "TEMPEST",
    },
    { -- types of Flying Boat
        "CATALINA",
        "MARINER",
        "SUNDERLAND",
        "KAWANISHI",
        "SHINMAYWA",
        "MARS",
    },
    { -- Royal Navy / Commonwealth
        "INVINCIBLE",
        "HERMES",
        "ARK ROYAL",
        "EAGLE",
        "ILLUSTRIOUS",
        "OCEAN",
        "QUEEN ELIZABETH",
        "WARRIOR",
        "MAJESTIC",
        "CANBERRA",  -- RAN
        "MELBOURNE",  -- RAN
        "BONAVENTURE", -- RCN
        "DREADNAUGHT",
        "BELLEROPHON",
    },
    { -- Indian Navy
        "VIKRANT",
        "VIRAAT",
        "VIKRAMADITYA",
        "VISHAL",
        "VIJAY",
        "CHEETA",
        "TAAKAT",
    },
    { -- US Navy
        "TARAWA",
        "YORKTOWN",
        "ENTERPRISE",
        "SARATOGA",
        "ROOSEVELT",
        "HORNET",
        "MIDWAY",
        "DAUNTLESS",
        "IKE",
        "RANGER",
        "LEXINGTON",
    },
    { -- France
        "FOCH",
        "DE GAULLE",
        "CLEMENCEAU",
        "LA FAYETTE",
        "ARROMANCHES",
        "FORTE",
        "CARNOT",
        "REPUBLIQUE'",
        "LIBERTE'",
    },
    { -- Latin
        "JUAN CARLOS",  -- Spain
        "VENTICINCO DE MAYO", -- Argentina
        "SAO PAULO",  -- Brazil
        "MINAS GERAIS",  -- Brazil
        "INDEPENDENCIA",  -- Argentina
    },
    { -- Kriegsmarine
        "SEYDLITZ",
        "BISMARK",
        "TIRPITZ",
        "HIPPER",
        "SCHEER",
        "GNEISENAU",
        "WESTFALEN",
        "PRINZ EUGEN",
    },
    { -- Japan
        "AMAGI",
        "HIYRU",
        "IZUMO",
        "KAGA",
        "FUJI",
        "YAMATO",
        "MUSASHI",
    },
    { -- Courage
        "HERCULES",
        "TORTUROUS",
        "STALWART",
        "THUNDERCHILD",
        "HARBINGER",
        "VINDICTIVE",
        "GLORY",
        "COURAGEOUS",
    },
    { -- Beasts
        "DRACONIS",
        "REX",
        "LUPIS",
        "CHARYBDIS",
        "BARRACUDA",
        "MINOTAUR",
    },
    { -- Oddballs
        "SPECTRUM",
        "VANGUARD",
        "TITAN",
        "TWILIGHT",
        "AURORA",
        "SHIP HAPPENS",
        "BOATY MCBOATFACE",
        "SNOW LEOPARD",
    }
}

function set_ship_names()
    if g_ship_name_pseudo == 0 then
        g_ship_name_pseudo = math.floor(update_get_tile_by_index(1):get_position_xz():x()) % 500
        g_ship_name_pseudo2 = math.floor(update_get_tile_by_index(1):get_position_xz():y()) % 1000
    end
end

function get_ship_name(vehicle)
    local st, v = pcall(_get_ship_name, vehicle)
    if not st then
        print(v)
        return ""
    end
    return v
end

function _get_ship_name(vehicle)
    set_ship_names()
    if vehicle ~= nil and vehicle:get() then
        if vehicle:get_definition_index() == e_game_object_type.chassis_carrier then
            local team = 0
            if vehicle.get_team == nil then
                team = vehicle:get_team_id()
            else
                team = vehicle:get_team()
            end
            local perturb = g_ship_name_pseudo

            local ship_setting = get_carrier_lifeboat_attachments_value(vehicle)
            if ship_setting > 0 then
                perturb = perturb + ship_setting
            end

            local team_names = (team + perturb) % #g_ship_names_choices

            local choices = g_ship_names_choices[1 + team_names]

            local cid = 1
            if vehicle:get_special_id() ~= 0 then
                cid = (vehicle:get_special_id() + g_ship_name_pseudo) % #choices
            else
                cid = (g_ship_name_pseudo2 % #choices)
            end
            local ship_name = choices[1 + cid]
            -- local name = string.format("%s %s", string.upper(vessel_names[1 + team]), choices[1 + cid])
            return ship_name
        end
    end
    return ""
end

function get_team_carriers(team)
    local carriers = {}
    local vehicle_count = update_get_map_vehicle_count()

    for i = 0, vehicle_count - 1, 1 do
        local vehicle = update_get_map_vehicle_by_index(i)

        if vehicle:get() then
            local vehicle_definition_index = vehicle:get_definition_index()
            if vehicle_definition_index == e_game_object_type.chassis_carrier then
                if vehicle:get_team() == team then
                    table.insert(carriers, vehicle)
                end
            end
        end
    end
    return carriers
end

function left_shift(x, bits)
    return math.floor(x * (2^bits))
end

function right_shift(x, bits)
    return math.floor(x / (2^bits))
end

g_carrier_lifeboat_bay_index = 16

function set_carrier_lifeboat_attachments_value(vehicle, value)
    local st, err = pcall(function()
        if vehicle and vehicle:get() then
            local lifeboat = update_get_map_vehicle_by_id(vehicle:get_attached_vehicle_id(g_carrier_lifeboat_bay_index))
            if lifeboat and lifeboat:get() then
                if lifeboat:get_definition_index() == e_game_object_type.chassis_sea_lifeboat then
                    for i = 0, lifeboat:get_attachment_count()
                    do
                        if (right_shift(value, i) & 0x1) == 1 then
                            vehicle:set_attached_vehicle_attachment(g_carrier_lifeboat_bay_index, i, e_game_object_type.attachment_turret_carrier_camera)
                        else
                            vehicle:set_attached_vehicle_attachment(g_carrier_lifeboat_bay_index, i, -1)
                        end
                    end
                end
            end
        end

    end)
    if not st then
        print(err)
    end
end


function get_carrier_lifeboat(carrier)

    if carrier.get_attached_vehicle_id == nil then
        -- we are in the hud, find the lifeboat the crap way by finding the nearest lifeboat
        -- to this carrier.. omg...
        local lifeboat = find_nearest_vehicle(carrier, e_game_object_type.chassis_sea_lifeboat, false )
        if lifeboat and lifeboat:get() then
            return lifeboat
        end
    else
        local lifeboat = update_get_map_vehicle_by_id(carrier:get_attached_vehicle_id(g_carrier_lifeboat_bay_index))
        return lifeboat
    end
    return nil
end


function get_carrier_lifeboat_attachments_value(vehicle)
    -- this is insane, but it is how we can store "settings" for a team
    -- and have it readable in all scripts including the HUD.
    if vehicle and vehicle:get() then
        -- assume that this is our carrier
        -- iterate the 4 attachments on the lifeboat, empty/present is 0/1 for that bit,
        -- this gives us 0-15 we can use
        local lifeboat = get_carrier_lifeboat(vehicle)
        if lifeboat and lifeboat:get() then
            if lifeboat:get_definition_index() == e_game_object_type.chassis_sea_lifeboat then
                local value = 0
                for i = 0, lifeboat:get_attachment_count()
                do
                    local attached = lifeboat:get_attachment(i)
                    if attached ~= nil then
                        if attached:get() then
                            if attached:get_definition_index() == e_game_object_type.attachment_turret_carrier_camera then
                                value = value | left_shift(1, i)
                            end
                        end
                    end
                end
                return value
            end
        end
    end
    return 0
end

function get_pos_xz(vehicle)
    if vehicle.get_position ~= nil then
        local pos = vehicle:get_position()
        return vec2(pos:x(), pos:z())
    end
    return vehicle:get_position_xz()
end


function find_nearest_vehicle_types(vehicle, other_defs, hostile, friendly_team)
    -- find the nearest unit of a particular type
    local ref_pos = get_pos_xz(vehicle)
    if friendly_team == nil then
        friendly_team = get_unit_team(vehicle)
    end
    return find_pos_nearest_vehicle_types(ref_pos, other_defs, hostile, friendly_team)
end

function find_pos_nearest_vehicle_types(ref_pos, other_defs, hostile, friendly_team)
    -- find the nearest unit of a particular type
    local vehicle_count = update_get_map_vehicle_count()
    local nearest = nil
    local distance_sq = 999999999
    for i = 0, vehicle_count - 1 do
        local unit = update_get_map_vehicle_by_index(i)
        if unit:get() then
            local match_team = get_unit_team(unit) == friendly_team
            if hostile then
                match_team = not match_team
            end

            if match_team and not get_vehicle_docked(unit) then
                local unit_def = unit:get_definition_index()
                for di = 1, #other_defs do
                    local other_def = other_defs[di]
                    if other_def == -1 or unit_def == other_def then
                        local dist = vec2_dist_sq(ref_pos, get_pos_xz(unit))
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
    return find_nearest_vehicle_types(vehicle, {other_def}, hostile)
end

function find_nearest_hostile_vehicle(vehicle, other_def)
   return find_nearest_vehicle(vehicle, other_def, true)
end

function get_vehicle_scale(vehicle)
    if vehicle and vehicle:get() then
        local def = vehicle:get_definition_index()
        if get_is_vehicle_sea(def) then
            if def == e_game_object_type.chassis_carrier then
                return 10
            end
            return 2
        end

        return 1
    end
    return 0
end

function get_vehicle_docked(vehicle)
    if vehicle then
        if vehicle.get_is_docked ~= nil then
            return vehicle:get_is_docked()
        end

        if vehicle.get_attached_parent_id ~= nil then
            return vehicle:get_attached_parent_id() ~= 0
        end
    end

    return false
end

function get_vehicle_team_id(vehicle)
    if vehicle.get_team ~= nil then
        return vehicle:get_team()
    end

    return vehicle:get_team_id()
end

function get_radar_interference(vehicle, radar)
    return false
end

-- missile data
g_missiles = {}
g_missiles_last = {}
g_missile_trails = {}
g_missiles_last_update = 0
g_missile_impacts = {}

g_track_missile_explosions = {
    [e_game_object_type.bomb_1] = true,
    [e_game_object_type.bomb_2] = true,
    [e_game_object_type.bomb_3] = true,
    [e_game_object_type.missile_cruise] = true,
}

g_track_missile_callbacks = {}

function refresh_missile_data(visible_only)
    local st, err = pcall(_refresh_missile_data, visible_only)
    if not st then
        print(err)
    end
end

function _refresh_missile_data(visible_only)
    local tick = update_get_logic_tick()
    if tick > g_missiles_last_update + 10 then
        g_missiles_last_update = tick
        -- clean up old impacts
        local last_impacts = g_missile_impacts
        g_missile_impacts = {}
        for key, value in pairs(last_impacts) do
            if value and tick - value["tick"] < 130  then
                table.insert(g_missile_impacts, value)
            end
        end

        -- find all the missiles
        local trails_last_frame = g_missile_trails
        g_missiles_last = g_missiles
        g_missile_trails = {}
        g_missiles = {}

        local missile_count = update_get_missile_count()

        for i = 0, missile_count - 1 do
            local missile = update_get_missile_by_index(i)
            if missile and missile:get() then
                if missile:get_is_visible() or not visible_only then
                    local def = missile:get_definition_index()
                    local trail_count = missile:get_trail_count()
                    if g_missile_debug then
                        print(string.format("missile i=%d d=%d ts=%d", i, def, trail_count))
                    end
                    if g_track_missile_explosions[def] ~= nil then
                        if trail_count > 0 then
                            -- the last trail position can kind of be used as an id for the missile for a few frames,
                            -- if the missile has more than 1 trail position, use the last as the first is usually the
                            -- launcher that may be static if it is a ship or turret

                            -- we just memorise that we've seen the last trail position of this missile
                            -- if it has more than 2, we remember the last 2

                            local pos = missile:get_position_xz()
                            if trail_count > 1 then
                                if trail_count > 2 then
                                    local tpos = missile:get_trail_position(trail_count - 2)
                                    local mid = string.format("%f,%f", tpos:x(), tpos:y())
                                    g_missile_trails[mid] = pos
                                end
                                local tpos = missile:get_trail_position(trail_count - 1)
                                local mid = string.format("%f,%f", tpos:x(), tpos:y())
                                g_missile_trails[mid] = pos

                                if g_missile_debug then
                                    print(string.format("i=%d %s", i, mid))
                                end
                                local first_seen = update_get_logic_tick()
                                if g_missiles_last[mid] ~= nil then
                                    if g_missiles_last[mid].first - first_seen < 130 then
                                        first_seen = g_missiles_last[mid].first
                                    end
                                end

                                g_missiles[mid] = {
                                    pos = missile:get_position_xz(),
                                    type = def,
                                    visible = missile:get_is_visible(),
                                    team = missile:get_team(),
                                    first = first_seen
                                }

                            end
                        end
                    end
                end
            end
        end

        for mid, pos in pairs(trails_last_frame) do
            if g_missile_trails[mid] == nil and g_missiles_last[mid] ~= nil then
                -- impact
                local x = pos:x()
                local z = pos:y()

                local data = {
                    x = x,
                    z = z,
                    visible = g_missiles_last[mid]["visible"],
                    def =  g_missiles_last[mid]["type"],
                    first = g_missiles_last[mid]["first"],
                    tick = update_get_logic_tick(),
                }

                table.insert(g_missile_impacts, data)
                if g_missile_debug then
                    print(string.format("impact %f, %f", x, z))
                end
                if g_track_missile_callbacks.impact ~= nil then
                    g_track_missile_callbacks.impact(data)
                end
            end
        end
    end
end



function draw_explosion(screen_pos_x, screen_pos_y, age, size)
    local alpha = 75 - (2 * age)
    if alpha > 0 then
        if size == nil then
            size = 5
        end
        local yellow = color8(255, 255, 0, alpha)
        local fire = color8(255, 0, 0, alpha)
        if update_get_logic_tick() % 2 == 0 then
            fire = yellow
        end
        update_ui_circle(screen_pos_x,
                screen_pos_y, size, 9, fire)
    end
end


-- get customisable settings

function get_rcs_model_enabled()
    if g_revolution_enable_rcs ~= nil then
        return g_revolution_enable_rcs
    end
    return false
end

function get_awacs_alt_boost_enabled()
    -- true if awacs range altitude boosts are enabled
    if get_awacs_alt_boost_start() < 2000 and get_awacs_alt_boost_factor() > 0 then
        return true
    end
    return false
end

function get_awacs_alt_boost_start()
    --- get the altitude above which the awacs gets a range boost
    if g_revolution_awacs_boost_above_alt ~= nil then
        if g_revolution_awacs_boost_above_alt == false then
            return 9999  -- no boost
        end
        return g_revolution_awacs_boost_above_alt
    end

    return 1600
end

function get_awacs_alt_boost_factor()
    -- get the amount of boost an awacs gains at higher altitude
    if g_revolution_awacs_alt_boost_factor == nil or not g_revolution_awacs_alt_boost_factor then
        -- turned off
        return 0
    end
    -- default enabled
    return 1.2
end

function get_awacs_max_ship_detection_range()
    -- get the max range an awacs/golfball/needlefish radar can detect ships
    if g_revolution_awacs_ship_max_range ~= nil then
        return g_revolution_awacs_ship_max_range
    end
    return 10000
end

function get_low_level_radar_altitude(vehicle)
    -- below this altitude aircraft are masked from operator radars
    if vehicle and vehicle:get() then
        if vehicle:get_team() == 1 then
            -- hides AI units in hangars on tall islands
            return 100
        end
    end

    if g_revolution_radar_clutter_level ~= nil then
        return g_revolution_radar_clutter_level
    end
    return 65
end

function get_render_missile_heat_circles()
    -- render the small white close range circles for hot targets
    return get_render_missile_heat_range() > 0
end

function get_render_missile_heat_range()
    -- return the range where heat circles will start to appear
    if g_revolution_hud_missile_heat_circles ~= nil then
        return g_revolution_hud_missile_heat_circles
    end
    return 1500
end

function get_render_missile_heat_scope_size()
    -- return the fraction of the middle of the HUD that heat blobs circles appear
    if g_revolution_hud_missile_heat_scope ~= nil then
        return g_revolution_hud_missile_heat_scope
    end
    return 0.25
end

function get_rwr_range()
    if g_revolution_rwr_range ~= nil then
        return g_revolution_rwr_range
    end
    return 16000
end

-- get expandeded loadout options

function merge_tables(t1, t2)
    local result = {}
    for item, value in pairs(t1) do
        result[item] = value
    end
    for item, value in pairs(t2) do
        result[item] = value
    end
    return result
end

function concat_lists(t1, t2)
    local result = {}
    for _, value in pairs(t1) do
        table.insert(result, value)
    end
    for _, value in pairs(t2) do
        table.insert(result, value)
    end

    return result
end

function get_loadout_attachment_not_allowed(vehicle, attachment_index)
    local attachment = vehicle:get_attachment(attachment_index)
    if attachment and attachment:get() then
        local options = get_selected_vehicle_attachment_extra_options(vehicle, attachment_index)
        local a_def = attachment:get_definition_index()
        if a_def then
            for _, item in pairs(options) do
                if item.type == a_def then
                    return false
                end
            end
        end
    end
    return true
end

function get_loadout_attachment_hidden(vehicle, attachment_index)
    local rows = get_ui_vehicle_chassis_attachments(vehicle)
    for _, row in pairs(rows) do
        if row then
            for _, entry in pairs(row) do
                if entry.i == attachment_index then
                    return false
                end
            end
        end
    end
    return true
end

function sanitise_loadout(carrier, bay_index)
    local vehicle = update_get_map_vehicle_by_id(carrier:get_attached_vehicle_id(bay_index))
    -- remove weapons from hidden
    if vehicle and vehicle:get() then
        local st, err = pcall(function()
            local attachment_count = vehicle:get_attachment_count()
            for i = 1, attachment_count do
                local a = vehicle:get_attachment(i)
                if a and a:get() then
                    if a:get_definition_index() ~= -1 then
                        local hidden = get_loadout_attachment_hidden(vehicle, i) or get_loadout_attachment_not_allowed(vehicle, i)
                        if hidden then
                            -- remove the attachment
                            carrier:set_attached_vehicle_attachment(bay_index, i, -1)
                        end
                    end
                end
            end
        end)
        if not st then
            print(err)
        end
    end
end

local st, _v = pcall(function()
    local _std_wing_attachments = {
        e_game_object_type.attachment_turret_plane_chaingun,
        e_game_object_type.attachment_turret_rocket_pod,
        e_game_object_type.attachment_hardpoint_bomb_1,
        e_game_object_type.attachment_hardpoint_bomb_2,
        e_game_object_type.attachment_hardpoint_bomb_3,
        e_game_object_type.attachment_hardpoint_missile_ir,
        e_game_object_type.attachment_hardpoint_missile_laser,
        e_game_object_type.attachment_hardpoint_missile_aa,
        e_game_object_type.attachment_hardpoint_missile_tv,
        e_game_object_type.attachment_hardpoint_torpedo,
        e_game_object_type.attachment_hardpoint_torpedo_noisemaker,
        e_game_object_type.attachment_hardpoint_torpedo_decoy,
        e_game_object_type.attachment_fuel_tank_plane
    }
    _std_wing_weapons = {
        e_game_object_type.attachment_turret_plane_chaingun,
        e_game_object_type.attachment_turret_rocket_pod,
        e_game_object_type.attachment_hardpoint_bomb_1,
        e_game_object_type.attachment_hardpoint_bomb_2,
        e_game_object_type.attachment_hardpoint_bomb_3,
        e_game_object_type.attachment_hardpoint_missile_ir,
        e_game_object_type.attachment_hardpoint_missile_laser,
        e_game_object_type.attachment_hardpoint_missile_aa,
        e_game_object_type.attachment_hardpoint_missile_tv,
        e_game_object_type.attachment_hardpoint_torpedo,
        e_game_object_type.attachment_hardpoint_torpedo_noisemaker,
        e_game_object_type.attachment_hardpoint_torpedo_decoy,
    }
    _std_wing_utils = {
        e_game_object_type.attachment_flare_launcher,
        e_game_object_type.attachment_sonic_pulse_generator,
        e_game_object_type.attachment_smoke_launcher_explosive,
        e_game_object_type.attachment_smoke_launcher_stream
    }

    _std_land_turrets = {
        e_game_object_type.attachment_turret_30mm,
        e_game_object_type.attachment_turret_40mm,
        e_game_object_type.attachment_turret_ciws,
        e_game_object_type.attachment_turret_missile,
        e_game_object_type.attachment_radar_golfball,
        e_game_object_type.attachment_turret_robot_dog_capsule,
    }

    _std_land_utils = {
        e_game_object_type.attachment_flare_launcher,
        e_game_object_type.attachment_sonic_pulse_generator,
        e_game_object_type.attachment_smoke_launcher_explosive,
        e_game_object_type.attachment_smoke_launcher_stream,
        e_game_object_type.attachment_camera,
    }

    local ret = {
        -- manta
        [e_game_object_type.chassis_air_wing_heavy] = {
            rows = {
                -- comment/remove a line to remove that attachment
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
                }
            },
            options = {
                -- nose slot
                [1] = {
                    e_game_object_type.attachment_camera_plane,
                    e_game_object_type.attachment_turret_gimbal_30mm,
                },
                -- middle
                [3] = {
                    e_game_object_type.attachment_fuel_tank_plane,
                    e_game_object_type.attachment_hardpoint_bomb_1,
                    e_game_object_type.attachment_hardpoint_bomb_2,
                    e_game_object_type.attachment_hardpoint_bomb_3,
                    e_game_object_type.attachment_hardpoint_torpedo,
                },
                -- wings
                [4] = _std_wing_attachments,
                [5] = _std_wing_attachments,

                -- utils
                [6] = _std_wing_utils,
                [7] = _std_wing_utils,

                -- internal gun
                [2] = {
                    e_game_object_type.attachment_turret_plane_chaingun
                }
            }
        },
        -- albatross
        [e_game_object_type.chassis_air_wing_light] = {
            rows = {
                {
                    { i=1, x=0, y=-23 } -- front camera slot
                },
                {
                    { i=2, x=-22, y=-4 }, -- left middle
                    { i=3, x=22, y=-4 },  -- right middle
                    { i=4, x=-13, y=-4 }, -- left inner
                    { i=5, x=13, y=-4 },  -- right inner
                    { i=6, x=0, y=0 },    -- AWACS
                }
            } ,
            options = {
                -- nose slot
                [1] = {
                    e_game_object_type.attachment_camera_plane,
                    e_game_object_type.attachment_turret_gimbal_30mm,
                },
                -- wings
                [2] = _std_wing_weapons,
                [3] = _std_wing_weapons,
                [4] = _std_wing_attachments,
                [5] = _std_wing_attachments,
                -- top
                [6] = {
                    e_game_object_type.attachment_radar_awacs,
                },
            }
        },
        -- razorbill
        [e_game_object_type.chassis_air_rotor_light] = {
            rows = {
                {
                    { i=5, x=0, y=-7},
                    { i=1, x=-26, y=0 },
                    { i=3, x=-14, y=0 },
                    { i=4, x=14, y=0 },
                    { i=2, x=26, y=0 }
                }
            },
            options = {
                [1] = _std_wing_attachments,
                [2] = _std_wing_attachments,
                [3] = _std_wing_utils,
                [4] = _std_wing_utils,
                [5] = {
                    e_game_object_type.attachment_turret_droid,
                    e_game_object_type.attachment_flare_launcher,
                    e_game_object_type.attachment_sonic_pulse_generator,
                },
            }
        },
        -- walrus
        [e_game_object_type.chassis_land_wheel_medium] = {
            options = {
                [1] = concat_lists(_std_land_turrets, {e_game_object_type.attachment_turret_heavy_cannon}),
                [3] = concat_lists(_std_land_utils, {e_game_object_type.attachment_deployable_droid}),
            },
        },
        -- bear
        [e_game_object_type.chassis_land_wheel_heavy] = {
            options = {
                [1] = concat_lists(_std_wing_utils, {
                    e_game_object_type.attachment_camera,
                    e_game_object_type.attachment_hardpoint_missile_tv,
                }),
                [3] = concat_lists(_std_wing_utils, {
                    e_game_object_type.attachment_camera,
                    e_game_object_type.attachment_hardpoint_missile_tv,
                })
            }
        },
        -- petrel
        [e_game_object_type.chassis_air_rotor_heavy] = {
            options = {
                -- nose slot
                [1] = {
                    e_game_object_type.attachment_camera_plane,
                    e_game_object_type.attachment_turret_gimbal_30mm,
                    -- e_game_object_type.attachment_radar_golfball,   -- disables airlift ability when added
                },
            },
        }

    }


    return ret

end)
if not st then
    print(_v)
else
    g_revolution_attachment_defaults = _v
end


-- script leader utils

-- return True if this game client is the "lead" client for scripting
-- this is used where you want to limit a chunk of code to happening
-- for only one player per team
function get_is_lead_team_peer()
    -- get the peer names, return true if we are the first in sorted order
    if not update_get_is_multiplayer() then
        return true
    end

    local names = {}
    local self_id = update_get_local_peer_id()
    local self_idx = update_get_peer_index_by_id(self_id)
    local self_name = update_get_peer_name(self_idx)
    local peer_count = update_get_peer_count()
    for i = 0, peer_count - 1 do
        table.insert(names, update_get_peer_name(i))
    end
    table.sort(names, function(a, b) return a.lower() < b.lower() end)
    for _, name in ipairs(names) do
        return name == self_name
    end

    return false
end

-- if an island factory is damaged, return the number of ticks until it is repaired
-- else return 0
function get_island_factory_damage(island_id)
    local team = update_get_screen_team_id()
    local flag = get_special_waypoint(team, F_DRYDOCK_WPTX_FACTORY_DAMAGED, island_id)
    if flag ~= nil then
        local now = update_get_logic_tick()
        local repaired = flag:get_altitude()
        local remaining = repaired - now
        if remaining > 0 then
            return remaining
        end
    end
    return 0
end

-- bomb damage can be fixed in minutes (longer for larger bombs)
g_island_factory_damage_mins = 2.5
g_island_factory_damage_ticks = 30 * 60 * g_island_factory_damage_mins
g_island_factory_damage_mins_max = 7
g_island_factory_damage_ticks_max = 30 * 60 * g_island_factory_damage_mins_max

-- mark a factory as damaged and set the time that we will say it is repaired
function set_island_factory_damage(island_id, tick_when_fixed)
    local team = update_get_screen_team_id()
    local wpt = add_special_waypoint(team, F_DRYDOCK_WPTX_FACTORY_DAMAGED, island_id)
    if wpt ~= nil then
        local drydock = find_team_drydock(team)
        if drydock and drydock:get() then
            local value = math.floor(math.min(tick_when_fixed, update_get_logic_tick() + g_island_factory_damage_ticks_max))
            if g_missile_debug then
                print("factory " .. island_id .. " dmg=" .. value)
            end
            drydock:set_waypoint_altitude(wpt, value)
        end
    end
end


function get_factory_damage_enabled()
    if g_revolution_enable_factory_damage == nil then
        return true
    end
    return g_revolution_enable_factory_damage
end

-- rotary hover load/drop/landing detection
g_rotary_hover = {}
g_rotary_hover_last_tick = 0
g_hover_callback = nil

function update_hover_data()
    local st, err = pcall(function()
        -- find all petrels, try to detect if they are hovering for pickup or drop
        if update_get_is_focus_local ~= nil and not update_get_is_focus_local() then
            -- only bother doing hover calcs on screens in use
            return
        end

        local tick = update_get_logic_tick()
        local elapsed = tick - g_rotary_hover_last_tick
        if elapsed < 20 then
            return
        end
        g_rotary_hover_last_tick = tick
        local vehicle_count = update_get_map_vehicle_count()

        for i = 0, vehicle_count - 1, 1 do
            local vehicle = update_get_map_vehicle_by_index(i)

            if vehicle:get() then
                local data = nil
                local vehicle_definition_index = vehicle:get_definition_index()
                local rotary = vehicle_definition_index == e_game_object_type.chassis_air_rotor_light or vehicle_definition_index == e_game_object_type.chassis_air_rotor_heavy
                local team = get_unit_team(vehicle)
                local alt = get_unit_altitude(vehicle)
                if rotary and team == update_get_screen_team_id() and alt < 100 and not get_vehicle_docked(vehicle) then
                    -- friendly, flying rotary aircraft under 100m alt
                    local vid = vehicle:get_id()
                    local is_petrel = vehicle_definition_index == e_game_object_type.chassis_air_rotor_heavy
                    local previous = g_rotary_hover[vid]
                    data = {pos = get_pos_xz(vehicle), alt = alt, ptr = is_petrel, tick = tick, count = 0}
                    if previous ~= nil then
                        local age = tick - previous.tick
                        data.tick = previous.tick
                        data.count = previous.count
                        if age > 50 then
                            -- existing entry
                            -- if moved more than 5m, remove
                            -- if stationary for more than 60 ticks, treat as a hover
                            local a_dist = math.abs(previous.alt - data.alt)
                            local stable = false
                            if a_dist < 3 then
                                -- alt stable
                                local h_dist = vec2_dist(previous.pos, data.pos)
                                if h_dist < 2 then
                                    -- pos stable
                                    if data.count == 0 then
                                        if g_hover_callback ~= nil then
                                            g_hover_callback(vehicle, true)
                                        end
                                    end
                                    data.count = data.count + 1
                                    stable = true
                                end
                            end
                            if not stable then
                                -- moved more than 5m vertically or 2m horizontally, clear data
                                if data.count > 0 then
                                    if g_hover_callback ~= nil then
                                        g_hover_callback(vehicle, false)
                                    end
                                end
                                data = nil
                            end

                        elseif age > 240 then
                            -- too old
                            -- data = nil
                        end
                    end
                    g_rotary_hover[vid] = data
                end
            end
        end
    end)
    if not st then
        print(err)
    end
end

function add_altitude_waypoint(vehicle, pos, alt, hold_grp)
    local wpt = vehicle:add_waypoint(pos:x(), pos:y())
    vehicle:set_waypoint_altitude(wpt, math.floor(alt), 0)
    if hold_grp ~= nil then
        vehicle:set_waypoint_wait_group(wpt, hold_grp, true)
    end
    return wpt
end

get_internal_fuel_sizes = {
    [e_game_object_type.chassis_air_wing_light] = 2000,
    [e_game_object_type.chassis_air_rotor_light] = 400,
    [e_game_object_type.chassis_air_wing_heavy] = 2000,
    [e_game_object_type.chassis_air_rotor_heavy] = 2000,
    [e_game_object_type.chassis_carrier] = 50000,
    [e_game_object_type.chassis_land_wheel_heavy] = 1200,
    [e_game_object_type.chassis_land_wheel_medium] = 1200,
    [e_game_object_type.chassis_land_wheel_mule] = 1200,
    [e_game_object_type.chassis_land_wheel_light] = 800,
}

function get_internal_fuel_size(vehicle_definition_index)
    local value = get_internal_fuel_sizes[vehicle_definition_index]
    if value == nil then
        value = 0
    end
    return value
end

function iter_team_units(team, func)
    local vehicle_count = update_get_map_vehicle_count()
    for i = 0, vehicle_count - 1 do
        local vehicle = update_get_map_vehicle_by_index(i)

        if vehicle:get() then
            local vehicle_team = vehicle:get_team()
            if vehicle_team == team then
                func(vehicle)
            end
        end
    end
end

g_attachment_to_index = {
    [e_game_object_type.attachment_camera_plane] = 20,
    [e_game_object_type.attachment_turret_gimbal_30mm] = 60,
    [e_game_object_type.attachment_flare_launcher] = 26,
    [e_game_object_type.attachment_turret_plane_chaingun] = 10,
    [e_game_object_type.attachment_hardpoint_bomb_1] = 14,
    [e_game_object_type.attachment_hardpoint_bomb_2] = 15,
    [e_game_object_type.attachment_hardpoint_bomb_3] = 16,
    [e_game_object_type.attachment_hardpoint_missile_ir] = 17,
    [e_game_object_type.attachment_hardpoint_missile_laser] = 18,
    [e_game_object_type.attachment_hardpoint_missile_aa] = 19,
    [e_game_object_type.attachment_hardpoint_torpedo] = 37,
    [e_game_object_type.attachment_hardpoint_torpedo_decoy] = 40,
    [e_game_object_type.attachment_hardpoint_torpedo_noisemaker] = 39,
    [e_game_object_type.attachment_hardpoint_missile_tv] = 38,
    [e_game_object_type.attachment_radar_awacs] = 24,
    [e_game_object_type.attachment_turret_rocket_pod] = 11,
    [e_game_object_type.attachment_fuel_tank_plane] = 36,
}
g_fuel_index = 36
g_rocket_index = 30

function get_definition_from_inventory_index(index)
    local value = -1
    for k, v in ipairs(g_attachment_to_index) do
        if v == index then
            return k
        end
    end

    return value
end

function get_payload_weight(definition_index)
    local index = g_attachment_to_index[definition_index]
    local value = 0
    if index ~= nil then
        local data = g_item_data[index]
        if data ~= nil then
            value = data.mass
            if definition_index == e_game_object_type.attachment_fuel_tank_plane then
                -- tank plus content of 1 fuel unit
                value = value + g_item_data[g_fuel_index].mass
            elseif definition_index == e_game_object_type.attachment_turret_rocket_pod then
                -- 19 rockets
                value = value + (19 * g_item_data[g_rocket_index].mass)
            end
        end
    end
    return value
end

function get_aircraft_payload_weight(vehicle)
    local value = 0
    if vehicle and vehicle:get() then
        local attachment_count = vehicle:get_attachment_count()
        for i = 0, attachment_count - 1 do
            local attachment = vehicle:get_attachment(i)
            if attachment and attachment:get() then
                local def = attachment:get_definition_index()
                if def ~= -1 then
                    value = value + get_payload_weight(attachment:get_definition_index())
                end
            end
        end
    end
    return value
end