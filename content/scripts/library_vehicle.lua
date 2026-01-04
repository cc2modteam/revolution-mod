local math_pi = math.pi
local math_random = math.random
local math_floor = math.floor

g_is_holomap = false
g_last_update_interval = 1

-- pre-localise some common strings
UPP_TORP = nil

function compile_globals()
    if UPP_TORP == nil then
        UPP_TORP = update_get_loc(e_loc.torpedo):sub(1, 4):upper()
    end
end

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
    compile_globals()
    local attachment_data = {
        [-1] = { 
            unknown = true,
            name = update_get_loc(e_loc.upp_unknown),
            icon16 = atlas_icons.icon_attachment_16_none,
            name_short = update_get_loc(e_loc.upp_unknown),
        },
        [e_game_object_type.attachment_turret_15mm] = {
            name = update_get_loc(e_loc.upp_gun),
            icon16 = atlas_icons.icon_attachment_16_turret_main_gun_light,
            name_short = update_get_loc(e_loc.upp_gun),
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
            name_short = update_get_loc(e_loc.upp_gun),
        },
        [e_game_object_type.attachment_turret_battle_cannon] = {
            name = update_get_loc(e_loc.upp_100mm_cannon),
            icon16 = atlas_icons.icon_attachment_16_turret_main_battle_cannon,
            name_short = update_get_loc(e_loc.upp_gun),
        },
        [e_game_object_type.attachment_turret_artillery] = {
            name = update_get_loc(e_loc.upp_artillery_gun),
            icon16 = atlas_icons.icon_attachment_16_turret_artillery,
            name_short = update_get_loc(e_loc.upp_gnd_art),
        },
        [e_game_object_type.attachment_turret_carrier_main_gun] = {
            name = update_get_loc(e_loc.upp_naval_gun),
            icon16 = atlas_icons.icon_attachment_16_turret_main_battle_cannon,
            name_short = update_get_loc(e_loc.upp_gun) .. " 160MM",
        },
        [e_game_object_type.attachment_turret_plane_chaingun] = {
            name = update_get_loc(e_loc.upp_20mm_auto_cannon),
            icon16 = atlas_icons.icon_attachment_16_air_chaingun,
            name_short = update_get_loc(e_loc.upp_gun),
        },
        [e_game_object_type.attachment_turret_rocket_pod] = {
            name = update_get_loc(e_loc.upp_rocket_pod),
            icon16 = atlas_icons.icon_attachment_16_rocket_pod,
            name_short = update_get_loc(e_loc.upp_rockets),
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
            name_short = update_get_loc(e_loc.upp_crs_msl),
        },
        [e_game_object_type.attachment_turret_carrier_camera] = {
            name = update_get_loc(e_loc.upp_naval_camera),
            icon16 = atlas_icons.icon_attachment_16_camera_large,
            name_short = update_get_loc(e_loc.upp_camera),
        },
        [e_game_object_type.attachment_turret_carrier_torpedo] = {
            name = update_get_loc(e_loc.upp_torpedo),
            icon16 = atlas_icons.icon_attachment_16_air_torpedo,
            name_short = UPP_TORP,
        },
        [e_game_object_type.attachment_turret_carrier_torpedo_decoy] = {
            name = update_get_loc(e_loc.upp_torpedo_decoy),
            icon16 = atlas_icons.icon_attachment_16_air_torpedo_decoy,
            name_short = UPP_TORP .. " DECOY",
        },
        [e_game_object_type.attachment_hardpoint_bomb_1] = {
            name = update_get_loc(e_loc.upp_bomb_1),
            icon16 = atlas_icons.icon_attachment_16_air_bomb_1,
            name_short = update_get_loc(e_loc.hardpoint_bomb_1):upper(),
        },
        [e_game_object_type.attachment_hardpoint_bomb_2] = {
            name = update_get_loc(e_loc.upp_bomb_2),
            icon16 = atlas_icons.icon_attachment_16_air_bomb_2,
            name_short = update_get_loc(e_loc.hardpoint_bomb_2):upper()
        },
        [e_game_object_type.attachment_hardpoint_bomb_3] = {
            name = update_get_loc(e_loc.upp_bomb_3),
            icon16 = atlas_icons.icon_attachment_16_air_bomb_3,
            name_short = update_get_loc(e_loc.hardpoint_bomb_3):upper()
        },
        [e_game_object_type.attachment_hardpoint_torpedo] = {
            name = update_get_loc(e_loc.upp_torpedo),
            icon16 = atlas_icons.icon_attachment_16_air_torpedo,
            name_short = UPP_TORP,
        },
        [e_game_object_type.attachment_hardpoint_torpedo_noisemaker] = {
            name = update_get_loc(e_loc.upp_torpedo_noisemaker),
            icon16 = atlas_icons.icon_attachment_16_air_torpedo_noisemaker,
            name_short = UPP_TORP,
        },
        [e_game_object_type.attachment_hardpoint_torpedo_decoy] = {
            name = update_get_loc(e_loc.upp_torpedo_decoy),
            icon16 = atlas_icons.icon_attachment_16_air_torpedo_decoy,
            name_short = update_get_loc(e_loc.countermeasures):upper(),
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
            name_short = update_get_loc(e_loc.upp_camera),
        },
        [e_game_object_type.attachment_camera_vehicle_control] = {
            name = update_get_loc(e_loc.upp_fixed_camera),
            icon16 = atlas_icons.icon_attachment_16_small_camera,
            name_short = update_get_loc(e_loc.upp_vehicle_control),
        },
        [e_game_object_type.attachment_camera_plane] = {
            name = update_get_loc(e_loc.upp_gimbal_camera),
            icon16 = atlas_icons.icon_attachment_16_camera_aircraft,
            name_short = update_get_loc(e_loc.upp_camera),
        },
        [e_game_object_type.attachment_camera_observation] = {
            name = update_get_loc(e_loc.upp_observation_camera),
            icon16 = atlas_icons.icon_attachment_16_camera_large,
            name_short = update_get_loc(e_loc.upp_camera),
        },
        [e_game_object_type.attachment_radar_awacs] = {
            name = update_get_loc(e_loc.upp_awacs_radar_system),
            icon16 = atlas_icons.icon_attachment_16_air_radar,
            name_short = update_get_loc(e_loc.upp_radar_golfball),
        },
        [e_game_object_type.attachment_fuel_tank_plane] = {
            name = update_get_loc(e_loc.upp_external_fuel_tank),
            icon16 = atlas_icons.icon_attachment_16_air_fuel,
            name_short = update_get_loc(e_loc.upp_fuel),
        },
        [e_game_object_type.attachment_flare_launcher] = {
            name = update_get_loc(e_loc.upp_ir_countermeasures),
            icon16 = atlas_icons.icon_attachment_16_small_flare,
            name_short = "FLARE",
        },
        [e_game_object_type.attachment_radar_golfball] = {
            name = update_get_loc(e_loc.upp_radar_golfball),
            icon16 = atlas_icons.icon_attachment_16_radar_golfball,
            name_short = update_get_loc(e_loc.upp_radar_golfball),
        },
        [e_game_object_type.attachment_sonic_pulse_generator] = {
            name = update_get_loc(e_loc.upp_sonic_pulse_generator),
            icon16 = atlas_icons.icon_attachment_16_sonic_pulse_generator,
            name_short = "SPG",
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
            name_short = UPP_TORP,
        },
        [e_game_object_type.attachment_logistics_container_20mm] = {
            name = update_get_loc(e_loc.upp_logistics_container_20mm),
            icon16 = atlas_icons.icon_attachment_16_logistics_container_20mm,
            name_short = update_get_loc(e_loc.upp_ammo) .. " 20MM",
        },
        [e_game_object_type.attachment_logistics_container_30mm] = {
            name = update_get_loc(e_loc.upp_logistics_container_30mm),
            icon16 = atlas_icons.icon_attachment_16_logistics_container_30mm,
            name_short = update_get_loc(e_loc.upp_ammo) .. " 30MM",
        },
        [e_game_object_type.attachment_logistics_container_40mm] = {
            name = update_get_loc(e_loc.upp_logistics_container_40mm),
            icon16 = atlas_icons.icon_attachment_16_logistics_container_40mm,
            name_short = update_get_loc(e_loc.upp_ammo) .. " 40MM",
        },
        [e_game_object_type.attachment_logistics_container_100mm] = {
            name = update_get_loc(e_loc.upp_logistics_container_100mm),
            icon16 = atlas_icons.icon_attachment_16_logistics_container_100mm,
            name_short = update_get_loc(e_loc.upp_ammo) .. " 100MM",
        },
        [e_game_object_type.attachment_logistics_container_120mm] = {
            name = update_get_loc(e_loc.upp_logistics_container_120mm),
            icon16 = atlas_icons.icon_attachment_16_logistics_container_120mm,
            name_short = update_get_loc(e_loc.upp_ammo) .. " 120MM",
        },
        [e_game_object_type.attachment_logistics_container_fuel] = {
            name = update_get_loc(e_loc.upp_logistics_container_fuel),
            icon16 = atlas_icons.icon_attachment_16_logistics_container_fuel,
            name_short = update_get_loc(e_loc.upp_fuel),
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

local chassis_air_min = e_game_object_type.chassis_air_wing_light
local chassis_air_max = e_game_object_type.chassis_air_rotor_heavy

function get_is_vehicle_air(definition_index)
    return definition_index >= chassis_air_min and definition_index <= chassis_air_max
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
    local glide_len = 350
    if start_pos == nil then
        start_pos = vec2(pos:x() - glide_len, pos:y() - glide_len)
    else
        local dx = pos:x() - start_pos:x()
        local dy = pos:y() - start_pos:y()
        local b = math.atan(dy, dx)
        local sy = math.sin(b) * glide_len
        local sx = math.cos(b) * glide_len
        start_pos = vec2(pos:x() - sx, pos:y() - sy)
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
        if ref_rng < 100 then
            gnd = math.floor(get_unit_altitude(nearest_gnd_unit) - 5.5)
        else
            gnd = 0
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
        or definition_index == e_game_object_type.chassis_land_turret
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
    if not g_revolution_control_units then
        return false
    end
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
        return true
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

g_rev_controller_islands = nil
g_rev_controller_islands_enabled = false
function rev_get_controller_islands()
    if g_rev_controller_islands == nil then
        g_rev_controller_islands = {}
        if g_rev_controller_islands_enabled then
            local tile_count = update_get_tile_count()
            if tile_count > 9 then
                local found = {}
                -- find all the 4-shield islands for every 9 islands on the map
                for i = 0, tile_count - 1 do
                    local tile = update_get_tile_by_index(i)
                    if tile and tile:get() then
                        local diff = tile:get_difficulty_level()
                        if diff == 4 then
                            found[tile:get_id()] = true
                        end
                    end
                end
                g_rev_controller_islands = found
            end
        end
    end
    return g_rev_controller_islands
end


function rev_get_team_control_islands(team_id)
    local control_count = 0
    for tid, _ in pairs(rev_get_controller_islands()) do
        local tile = update_get_tile_by_id(tid)
        if tile and tile:get() then
            if team_id == nil or tile:get_team_control() == team_id then
                control_count = control_count + 1
            end
        end
    end
    return control_count
end


function rev_get_island_locked_build_item(team_id, inventory_item)
    if update_get_tile_count() > 0 then
        -- manta and heavy bomb production requires control island
        local available_controllers = rev_get_team_control_islands(nil)
        if available_controllers > 0 then
            if rev_get_team_control_islands(team_id) == 0 then
                local needed = false
                if inventory_item == e_inventory_item.hardpoint_bomb_3 then
                    needed = true
                elseif inventory_item == e_inventory_item.vehicle_wing_heavy then
                    needed = true
                end
                if needed then
                    return string.format("%s %s",
                            update_get_loc(e_loc.upp_unavailable), update_get_loc(e_loc.island_control):upper())
                end
            end
        end
    end
    return nil
end

function get_vehicle_capability(vehicle)
    local attachment_count = vehicle:get_attachment_count()

    local capabilities = {}

    for i = 0, attachment_count - 1 do
        local attachment = vehicle:get_attachment(i)

        if attachment:get() then
            local attachment_def = attachment:get_definition_index()

            if attachment_def ~= e_game_object_type.attachment_camera_vehicle_control
            then
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

g_radar_scanned = true
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
    golfball = 10000,
    awacs = 10000,
}

g_radar_last_sea_scan = 0
g_radar_last_air_scan = 0
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

function has_attachment(vehicle, a_defs)
    if vehicle.extended then
        for d, _ in pairs(a_defs) do
            if vehicle:has_attachment_type(d) then
                return d
            end
        end
        return nil
    end

    local attachment_count = vehicle:get_attachment_count()
    for i = 0, attachment_count - 1 do
        local attachment = vehicle:get_attachment(i)
        if attachment and attachment:get() then
            local definition_index = attachment:get_definition_index()
            if a_defs[definition_index] ~= nil then
                return definition_index
            end
        end
    end
    return nil
end

local radar_attachment_defs = {
    [e_game_object_type.attachment_radar_golfball] = true,
    [e_game_object_type.attachment_radar_awacs] = true,
    [e_game_object_type.attachment_turret_carrier_ciws] = true,
    [e_game_object_type.attachment_turret_carrier_torpedo] = true,
    [e_game_object_type.attachment_turret_carrier_missile_silo] = true,
    [e_game_object_type.attachment_turret_carrier_main_gun] = true,
}

function _get_radar_attachment(vehicle)
    local d = nil
    if vehicle and vehicle:get() then
        if get_vehicle_docked(vehicle) then
            return d
        end

        if vehicle.extended then
            return vehicle:get_radar_type()
        end

        -- turrets and barges dont have radars, dont bother looking
        -- this could change one day
        local vdef = vehicle:get_definition_index()

        if vdef == e_game_object_type.chassis_carrier then
            d = e_game_object_type.attachment_radar_awacs
        elseif vdef ~= e_game_object_type.chassis_land_turret
        then
            d = has_attachment(vehicle, radar_attachment_defs)
        end
    end
    return d
end

function get_vehicle_radar(vehicle)
    return _get_radar_attachment(vehicle)
end

function get_is_vehicle_masked(vehicle)
    if vehicle and vehicle:get() then
        if get_is_vehicle_air(vehicle:get_definition_index()) then
            if _get_radar_attachment(vehicle) ~= nil then
                -- do not mask RADAR equipped air units
                return false
            end

            local pos = vehicle:get_position_xz()
            local waves = update_get_ocean_depth_factor(pos:x(), pos:y())
            local clutter_base = 55 + 20 * waves
            local alt = get_unit_altitude(vehicle)

            local masked = alt < clutter_base

            if masked then
                local nearest_friendly_crr, friendly_crr_dist = get_nearest_carrier(vehicle, true, update_get_screen_team_id())
                -- unmask any aircraft nearer than 2.5km
                if nearest_friendly_crr and friendly_crr_dist < 2500 then
                    masked = false
                end
            end

            return masked
        end
    end
    return false
end

function get_modded_radar_range(vehicle)
    if vehicle and vehicle:get() then
        if vehicle.extended then
            return vehicle:get_radar_range()
        end
    end
    return _get_modded_radar_range(vehicle)
end

function _get_modded_radar_range(vehicle)
    if vehicle and vehicle:get() then

        if g_revolution_override_radar_range ~= nil then
            local r_range = g_revolution_override_radar_range(vehicle)
            if r_range ~= nil then
                return r_range
            end
        end

        -- don't override the carrier radar range
        if get_vehicle_docked(vehicle) then
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

function get_vehicle_radar_state(vehicle)
    if vehicle and vehicle.extended then
        return vehicle:get_radar_state()
    end
    return _get_vehicle_radar_state(vehicle)
end

function _get_vehicle_radar_state(vehicle)
    local state = nil
    if vehicle and vehicle:get() then
        local radar_pos = _get_awacs_radar_attachment_position(vehicle)
        if radar_pos > -1 then
            if vehicle:get_definition_index() == e_game_object_type.chassis_carrier then
                -- carrier radar can be damaged, blocked (storms), "off" or "on"
                local carrier_radar = vehicle:get_attachment(radar_pos)
                if carrier_radar ~= nil then
                    local radar_mode = carrier_radar:get_control_mode()
                    if radar_mode == "off" then
                        return "off"
                    end
                    if carrier_radar.get_is_damaged ~= nil and carrier_radar:get_is_damaged() then
                        return "damaged"
                    end
                    if get_radar_interference(vehicle, carrier_radar) then
                        return "blocked"
                    end
                else
                    -- no radar fitted?
                    return nil
                end
            end
            return "on"
        else
            local radar_type = _get_radar_attachment(vehicle)
            if radar_type ~= nil then
                return "on"
            end
        end
    end

    return state
end

function draw_map_radar_state_indicator(vehicle, x, y, anim)
    local radar_state = nil
    if not get_vehicle_docked(vehicle) then
       if not get_is_spectator_mode() then
            if vehicle:get_team() ~= update_get_screen_team_id() then
                return
            end
        end
        local radar_radius = 0
        local x_offset = 4
        local y_offset = 2
        radar_state = get_vehicle_radar_state(vehicle)
        if radar_state ~= nil then
            if vehicle:get_definition_index() ~= e_game_object_type.chassis_carrier then
                x_offset = 1
                y_offset = 0
            end
            local radar_icon_color = color_enemy
            if radar_state == "damaged" or radar_state == "blocked" then
                if anim % 20 < 10 then
                    radar_icon_color = color_status_dark_green
                end
            elseif radar_state == "on" then
                radar_icon_color = color_grey_dark
                if anim % 60 < 30 then
                    radar_icon_color = color_white
                end
            end
            update_ui_image(
                    x + x_offset,
                    y + y_offset,
                    atlas_icons.column_power, radar_icon_color, 0
            )
        end
    end
    return radar_state
end

function get_awacs_radar_enabled(vehicle)
    local state = get_vehicle_radar_state(vehicle)
    if state ~= nil then
        if state == "on" then
            return true
        end
    end
    return false
end


function refresh_modded_radar_cache()
    if g_radar_debug then
        local st, err = pcall(update_modded_radar_data)
        if not st then
            print(err)
        end
    else
        update_modded_radar_data()
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

function iter_radars(func)
    if func == nil then
        return
    end
    for i, item in pairs(g_all_radars) do
        local radar_id = item.id
        local radar = update_get_map_vehicle_by_id(radar_id)
        if radar and radar:get() then
            func(radar)
        end
    end
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

        iter_radars(function(radar)
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
        end)

        if nearest and dist_sq < (18000 * 18000) then
            return nearest, dist_sq ^ 0.5
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

g_radar_debug_info = {}

local next_updated_radar_list = 0

function update_modded_radar_list(hostile_only)
    -- update the list of known radars & faked-radars
    local now = update_get_logic_tick()
    if now < next_updated_radar_list then
        return
    end
    next_updated_radar_list = now + math_random(0, 35)

    local vehicle_count = update_get_map_vehicle_count()
    if vehicle_count > 300 then
        -- cut down the number of updates on huge maps
        next_updated_radar_list = next_updated_radar_list + 20
    end
    g_all_radars = {}

    local screen_team = update_get_screen_team_id()
    local seen_by_friendly_radars = g_seen_by_friendly_radars
    local seen_by_hostile_radars = g_seen_by_hostile_radars
    local all_radars = g_all_radars

    for _, vehicle in pairs(get_vehicles_table()) do
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
                all_radars[vid] = {
                    id = vid,
                    type = radar_type
                }

            end
        end
    end

    -- clean the caches
    for vid, _ in pairs(seen_by_friendly_radars) do
        local v = update_get_map_vehicle_by_id(vid)
        if v == nil or not v:get() then
            seen_by_friendly_radars[vid] = nil
        end
    end
    for vid, _ in pairs(seen_by_hostile_radars) do
        local v = update_get_map_vehicle_by_id(vid)
        if v == nil or not v:get() then
            seen_by_hostile_radars[vid] = nil
        end
    end
end

function update_modded_radar_data()
    -- find all radars
    local current_tick = update_get_logic_tick()
    -- jitter the updates so we avoid doing too much at the same time
    local next_air_scan = g_radar_last_air_scan + math_floor(math_random(30, 95))
    local next_sea_scan = g_radar_last_sea_scan + math_floor(math_random(40, 120))
    local user_connected = true
    local script_id = nil
    if g_radar_debug then
        script_id = string.format("%s", _G)
    end
    if not update_get_is_focus_local() then
        local disconnected_delay_base = 250
        if g_is_holomap then
            disconnected_delay_base = 60
            if g_radar_debug then
                script_id = script_id .. " holomap"
            end
        end
        -- not connected, reduce the frequency to once every 5-7 seconds
        next_air_scan = g_radar_last_air_scan + disconnected_delay_base + math_floor(math_random(30, 90))
        next_sea_scan = g_radar_last_sea_scan + disconnected_delay_base + math_floor(math_random(40, 150))
        user_connected = false
    end

    if g_viewing_vehicle_id ~= nil then
        if g_viewing_vehicle_id > 0 then
            -- user is driving a unit
            return
        end
    end

    local update_air = current_tick > next_air_scan
    local update_sea = current_tick > next_sea_scan
    local force = g_force_radar_scan

    if not force then
        if not user_connected and not g_is_holomap then
            if not update_sea and not update_air then
                -- do nothing
                return
            end
        end
    end

    update_modded_radar_list(false)

    if not update_air and not update_sea then
        g_radar_scanned = false
        return
    end
    g_radar_scanned = true
    g_nearest_hostile_radar = {}

    if update_sea and update_air then
        -- dont do both
        update_sea = false
    end
    if force then
        update_sea = true
        update_air = true
    end

    if g_radar_debug then
        local what = ""
        if update_air then
            what = "air"
        end
        if update_sea then
            what = what .. "sea"
        end
        local_print(string.format("%d update %s local=%s %s", current_tick, script_id, user_connected, what))
    end

    if update_sea then
        g_radar_last_sea_scan = current_tick
    end
    if update_air then
        g_radar_last_air_scan = current_tick
    end

    do_radar_scan(update_air, update_sea)
end

function do_radar_scan(update_air, update_sea)
    local screen_team = update_get_screen_team_id()

    local all_radars = g_all_radars
    local nearest_friendly_radar = g_nearest_friendly_radar
    local seen_by_friendly_radars = g_seen_by_friendly_radars
    local nearest_hostile_radar = g_nearest_hostile_radar
    local seen_by_hostile_radars = g_seen_by_hostile_radars
    local fdsq = fast_dist_sq

    for _, vehicle in pairs(get_vehicles_table()) do
        local vteam = get_vehicle_team_id(vehicle)
        local friendly = vteam == screen_team
        local vdef = vehicle:get_definition_index()
        local vid = vehicle:get_id()
        local target_is_air = get_is_vehicle_air(vdef)
        if get_vehicle_docked(vehicle) or (target_is_air and get_unit_altitude(vehicle) < get_low_level_radar_altitude(vehicle)) then
            -- ignore docked or landed
        else
            local target_is_sea = false
            if not target_is_air then
                target_is_sea = get_is_vehicle_sea(vdef)
                if vdef == e_game_object_type.chassis_land_turret then
                    -- treat turrets deployed by carriers the same as ships for RADAR
                    local att = vehicle:get_attachment(0)
                    if att then
                        local attdef = att:get_definition_index()
                        if attdef == e_game_object_type.attachment_camera_observation
                                or attdef == e_game_object_type.attachment_radar_golfball
                                or attdef == e_game_object_type.attachment_camera
                        then
                            target_is_sea = true
                        end
                    end
                end
            end

            if update_sea and target_is_sea or update_air and target_is_air then
                seen_by_friendly_radars[vid] = nil
                nearest_hostile_radar[vid] = nil
                seen_by_hostile_radars[vid] = nil

                -- do radars
                local radar_team = nil
                local nearest_hostile_radar_dist_sq = 9999999
                for _, radar in pairs(all_radars) do
                    local radar_id = radar.id
                    local radar_vehicle = update_get_map_vehicle_by_id(radar_id)
                    if radar_vehicle and radar_vehicle:get() then
                        radar_team = get_vehicle_team_id(radar_vehicle)
                        -- dont scan the same team as the radar
                        -- and dont give needlefish "nails" from AI units
                        if radar_team ~= vteam and get_team_has_humans(radar_team) then
                            if (update_sea and target_is_sea) or (update_air and target_is_air) then
                                local radar_range = get_modded_radar_range(radar_vehicle)
                                local radar_range_sq = radar_range * radar_range
                                local range_lim = 20000
                                if target_is_air then
                                    range_lim = 24000
                                end
                                local target_dist_sq = radar_range_sq
                                if target_is_sea or target_is_air then
                                    target_dist_sq = fdsq(radar_vehicle:get_position_xz(), vehicle:get_position_xz(), range_lim)
                                end

                                if target_dist_sq < radar_range_sq then
                                    -- ship seen
                                    if radar_team == screen_team then
                                        if g_radar_debug then
                                            g_radar_debug_info[vid] = "radar sees"
                                        end
                                        if vehicle.extended then
                                            vehicle.seen_by_friendly_radars = true
                                        end
                                        seen_by_friendly_radars[vid] = true
                                    else
                                        if target_dist_sq < nearest_hostile_radar_dist_sq then
                                            nearest_hostile_radar_dist_sq = target_dist_sq
                                            nearest_hostile_radar[vid] = radar_id
                                        end
                                        seen_by_hostile_radars[vid] = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function fast_dist_sq2(a, b, limsq)
    -- compute a low fidelity distance for things far away,
    local dx = a:x() - b:x()
    local dxsq = dx * dx
    if dxsq < limsq then
        -- x is within lim km, compute the rest of the distance_sq
        local dy = a:y() - b:y()
        return dxsq + dy * dy
    end
    -- far away, just give a lowfi distance
    return dxsq
end

function fast_dist_sq(a, b, lim)
    return fast_dist_sq2(a, b, lim * lim)
end

function get_is_radar(vehicle_id)
    return g_all_radars[vehicle_id] ~= nil
end

function get_is_visible_by_modded_radar(vehicle)
    return _get_is_seen_by_friendly_modded_radar(vehicle)
end

function get_is_visible_by_hostile_modded_radar(vehicle)
    local seen = false
    if vehicle and vehicle:get() then
        if vehicle.extended then
            return vehicle:get_is_visible_by_hostile_modded_radar()
        end
        local vid = vehicle:get_id()
        seen = g_seen_by_hostile_radars[vid] ~= nil
    end
    return seen
end

function _get_is_seen_by_friendly_modded_radar(vehicle)
    if vehicle and vehicle:get() then
        if vehicle.extended then
            return vehicle:get_is_seen_by_friendly_modded_radar()
        end

        local vid = vehicle:get_id()
        if get_is_spectator_mode() then
            return true
        end
        local exists = g_seen_by_friendly_radars[vid]
        if exists ~= nil then
            return true
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
    local interval = 60
    if update_get_map_vehicle_count() > 200 then
        interval = 240
    end

    if g_fow_last_tick + interval < now then
        g_fow_last_tick = now
        g_fow_visible = {}
        local fow_vis = g_fow_visible
        -- reveal any island within 16km of one of our units
        local our_team = update_get_screen_team_id()
        local island_count = update_get_tile_count()
        local fow_range_sq = g_fow_range * g_fow_range

        for i = 0, island_count - 1 do
            local island = update_get_tile_by_index(i)
            local island_id = island:get_id()
            local is_visible = false
            if island:get_team_control() == our_team then
                is_visible = true
                rev_set_fow_island_scouted(island_id)
            else
                local pos = island:get_position_xz()
                -- foreign island, find any of our units in range
                for _, vehicle in pairs(get_vehicles_table()) do
                    if vehicle:get_team() == our_team then
                        if not get_vehicle_docked(vehicle) then
                            local unit_pos = vehicle:get_position_xz()
                            local dist = vec2_dist_sq(unit_pos, pos)
                            if dist < fow_range_sq then
                                is_visible = true
                                rev_set_fow_island_scouted(island_id)
                                break
                            end
                        end
                    end
                end
            end
            table.insert(fow_vis,is_visible)
        end
    end
end

function fow_island_visible(island_id)
    return g_fow_visible[island_id] == true or get_is_spectator_mode()
end

function get_nearest_tiles(x, y, range)
    local found = {}
    local index = 0
    local pos = vec2(x, y)
    local range_sq = range * range
    local tile_count = update_get_tile_count()
    while index < tile_count do
        local tile = update_get_tile_by_index(index)
        if tile:get() then
            index = index + 1
            local tile_pos = tile:get_position_xz()
            local tile_dist_sq = fast_dist_sq(pos, tile_pos, range)

            if tile_dist_sq < range_sq then
                table.insert(found, tile)
            end
        end
    end

    return found
end

function get_nearest_island_tile(x, y)
    local tile_count = update_get_tile_count()
    local index = 0
    local nearest = nil
    local dist = 90000 * 90000

    local pos = vec2(x, y)

    while index < tile_count do
        local tile = update_get_tile_by_index(index)
        if tile:get() then
            index = index + 1
            local tile_pos = tile:get_position_xz()
            local tile_dist_sq = fast_dist_sq(pos, tile_pos, 50000)

            if tile_dist_sq < dist then
                dist = tile_dist_sq
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

    local fade = math.max( 255 - math_floor(g_animation_time - g_holomap_last[team_id][3]), 0 )
    if fade > 0 then
        local cursor_x = 0
        local cursor_y = 0
        if g_is_holomap then
            cursor_x, cursor_y = get_holomap_from_world( holomap_x, holomap_y, g_screen_w, g_screen_h)
        else
            cursor_x, cursor_y = get_screen_from_world( holomap_x, holomap_y, g_camera_pos_x, g_camera_pos_y, g_camera_size, g_screen_w, g_screen_h)
        end
        update_ui_image_rot(cursor_x, cursor_y, atlas_icons.map_icon_crosshair, color8(255, 255, 255, fade), math_pi / 4)
        if get_is_spectator_mode() then
            local team_name = get_team_name(team_id)
            update_ui_text(cursor_x + 10, cursor_y + 10, team_name, 64, 0, color8(255, 255, 255, fade), 0)
        end
    end
end

-- ai team check

g_human_team_cache = {}
g_human_team_cache_tick = 0

function get_team_has_humans(team_id)
    local current_team = update_get_screen_team_id()
    if current_team == team_id then
        -- easy shortcut
        return true
    end
    local now = update_get_logic_tick()
    if g_human_team_cache_tick < now then
        g_human_team_cache_tick = now
        -- look through multiplier members, if a peer doesnt have the same team ID as us, then that
        -- team is human controlled, else it's AI controlled or nobody has joined it
        local peer_count = update_get_peer_count()
        for i = 0, peer_count - 1 do
            local team = update_get_peer_team(i)
            g_human_team_cache[team] = true
        end
    end

    return g_human_team_cache[team_id] == true
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
-- we use the x,y value of the waypoint as way for us to identify the waypoint type

--- NOTE - I originally coded these as bitflags, hence the F_ names
F_DRYDOCK_WPTX_CURSOR          = 1
F_DRYDOCK_WPTX_MARKER          = 2
-- for the holomap waypoint, we transmit the location to the nearest 16m (1m accuracy is useless)
-- we do this by packing x and y into the 32bit unsigned altitude value

F_DRYDOCK_WPTX_SETTING         = 4
F_DRYDOCK_WPTX_FACTORY_DAMAGED = 8
F_DRYDOCK_WPTX_SCOUTED         = 16

-- values for F_DRYDOCK_WPTX_SETTING wpts
DRYDOCK_WPTX_SETTING_READY     = 1

g_team_drydocks = {}

function find_team_drydock(team_id)
    if team_id == nil then
        team_id = update_get_screen_team_id()
    end
    local drydock = nil
    local drydock_id = g_team_drydocks[team_id]
    if drydock_id == nil then
        for _, vehicle in pairs(get_vehicles_table()) do
            if vehicle:get() then
                local vehicle_definition_index = vehicle:get_definition_index()
                if vehicle_definition_index == e_game_object_type.drydock then
                    if get_vehicle_team_id(vehicle) == team_id then
                        g_team_drydocks[team_id] = vehicle:get_id()
                        return vehicle
                    end
                end
            end
        end
    else
        drydock = update_get_map_vehicle_by_id(drydock_id)
    end

    return drydock
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
    local wid = petrel:add_waypoint(pos:x(), pos:y())
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

function is_wptx_type(waypoint, value)
    local position = waypoint:get_position_xz()
    if math_floor(position:x()) == value then
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


MARKER_WPT_OFFSET = 80000
function unpack_alt_xy(altitude)
    if altitude > 0 then
        local shifted_x = math_floor((altitude / 0x10000)) & 0xffff
        local shifted_y = math_floor(altitude) & 0xffff
        local cursor_x = (16 * shifted_x) - MARKER_WPT_OFFSET
        local cursor_y = (16 * shifted_y) - MARKER_WPT_OFFSET
        return cursor_x, cursor_y
    end
    return 0, 0
end

function pack_alt_xy(x, y)
    local shifted_x = math_floor((x + MARKER_WPT_OFFSET) / 16)
    local shifted_y = math_floor((y + MARKER_WPT_OFFSET) / 16)

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
            if is_wptx_type(waypoint, F_DRYDOCK_WPTX_CURSOR) then
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

function get_special_waypoint(team_id, wtype, special_id)
    local drydock = find_team_drydock(team_id)
    if drydock then
        local waypoint_count = drydock:get_waypoint_count()
        for i = 0, waypoint_count - 1, 1 do
            local waypoint = drydock:get_waypoint(i)
            if waypoint ~= nil then
                if is_wptx_type(waypoint, wtype) then
                    local pos = waypoint:get_position_xz()
                    if math_floor(pos:y()) == special_id then
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

function add_special_waypoint(team_id, flag, special_id, set_altitude_value)
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
    end
    local w_id = current:get_id()

    if set_altitude_value ~= nil then
        local_print("setting", flag, w_id, set_altitude_value)
        drydock:set_waypoint_altitude(w_id, set_altitude_value)
        local_print("got", current:get_altitude())
    end
    return w_id
end

function set_special_waypoint(team_id, flag, special_id, set_altitude_value)
    add_special_waypoint(team_id, flag, special_id, set_altitude_value)
end


function add_marker_waypoint(team_id, marker_id)
    return add_special_waypoint(team_id, F_DRYDOCK_WPTX_MARKER, marker_id)
end


function get_marker_value(team_id, marker_id)
    local marker = get_marker_waypoint(team_id, marker_id)
    if marker ~= nil then
        return marker:get_altitude()
    end
    return 0
end

function dump_waypoints(vehicle)
    if g_debug_enabled and vehicle and vehicle:get() then
        local waypoint_count = vehicle:get_waypoint_count()
        local_print("dump_waypoints:", "t=", update_get_logic_tick(), "id=", vehicle:get_id())
        if waypoint_count > 0 then
            for j = 0, waypoint_count - 1, 1 do
                local waypoint = vehicle:get_waypoint(j)
                local wpp = waypoint:get_position_xz()
                local_print("w", j, wpp:x(), wpp:y(), waypoint:get_altitude())
            end
        end
    end
end

function set_marker_waypoint(team_id, marker_id, x, y, force)
    if update_get_is_focus_local() or force then
        local_print("set_marker_waypoint:", "t=", update_get_logic_tick(),  marker_id, x, y, force)
        local marker = get_marker_waypoint(team_id, marker_id)
        if marker ~= nil then
            local drydock = find_team_drydock(team_id)
            local packed = pack_alt_xy(x, y)
            drydock:set_waypoint_altitude(marker:get_id(), packed)
            dump_waypoints(drydock)
        end
    end
end

function unset_marker_waypoint(team_id, marker_id)
    if update_get_is_focus_local() then
        local_print("unset_marker_waypoint:", "t=", update_get_logic_tick(),  team_id, marker_id)
        local marker = get_marker_waypoint(team_id, marker_id)
        if marker ~= nil then
            local drydock = find_team_drydock(team_id)
            drydock:set_waypoint_altitude(marker:get_id(), 0)
            dump_waypoints(drydock)
        end
    end
end

function rev_set_team_ready(team_id, is_ready)
    local value = 0
    if is_ready then
        value = 1
    end
    set_special_waypoint(team_id, F_DRYDOCK_WPTX_SETTING, DRYDOCK_WPTX_SETTING_READY, value)
end

function rev_get_team_ready(team_id)
    local w = get_special_waypoint(team_id, F_DRYDOCK_WPTX_SETTING, DRYDOCK_WPTX_SETTING_READY)
    if w then
        return w:get_altitude() > 0
    end
    return false
end

function update_team_holomap_cursor(team_id, x, y)
    local st, err = pcall(_update_team_holomap_cursor, team_id, x, y)
    if not st then
        print(err)
    end
end

g_last_hm_cursor_update = 0
g_last_hm_cursor_team = 0
g_last_hm_cursor_x = 0
g_last_hm_cursor_y = 0

function _update_team_holomap_cursor(team_id, x, y)
    x = math_floor(x)
    y = math_floor(y)

    if g_last_hm_cursor_team == team and g_last_hm_cursor_x == x and g_last_hm_cursor_y == y then
        return
    end

    local now = update_get_logic_tick()
    -- we really don't need to update this more than 2-3 times a second
    if now - g_last_hm_cursor_update < 10 then
        return
    end
    g_last_hm_cursor_update = now

    g_last_hm_cursor_team = team_id
    g_last_hm_cursor_x = x
    g_last_hm_cursor_y = y

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
        g_ship_name_pseudo = math_floor(update_get_tile_by_index(1):get_position_xz():x()) % 500
        g_ship_name_pseudo2 = math_floor(update_get_tile_by_index(1):get_position_xz():y()) % 1000
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

local l_rev_unit_names = {
    [e_game_object_type.chassis_sea_barge] = {
        "Deliverance",
        "It's not mine officer",
        "Ocean Trucker",
        "Type 9 of the seas",
        "Argos",
        "Courier",
        "InterBox",
        "Walrus-R-Us",
    },
    [e_game_object_type.chassis_land_robot_dog] = {
        -- somehow, giving the robot dogs hacker names seemed like a good idea
        -- but they really don't "feel" right, so I've gone for cute little
        -- bot names instead
        "Pip",
        "Chirpy",
        "Buzz",
        "Chip",
        "Barney",
        "Rover",
        "Rudy",
        "Ziggy"

       -- "Acid Burn",
       -- "Zero Cool",
       -- "Cereal Killer",
       -- "Lord Nikon",
       -- "Crash Override",
       -- "Joey",
       -- "Razor",
       -- "Blade",
    },
}

g_rev_unit_name_cache = {}
function rev_get_unit_name(vehicle)
    if vehicle and vehicle:get() then
        local vdef = vehicle:get_definition_index()

        if vdef == e_game_object_type.chassis_carrier then
            return get_ship_name(vehicle)
        end

        local vid = vehicle:get_id()
        local cached = g_rev_unit_name_cache[vid]
        if cached then
            return cached
        end

        local pool = l_rev_unit_names[vdef]
        if pool ~= nil then
            local factor = math_floor(update_get_tile_by_index(1):get_position_xz():x()) % 500
            local poolsize = #pool
            local name_idx = (factor + vid) % poolsize
            local name = pool[1 + name_idx]
            if name then
                local fullname = string.format("%s %d", name, vid)
                g_rev_unit_name_cache[vid] = fullname
                return fullname
            end
        end
    end
    return nil
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
    return math_floor(x * (2^bits))
end

function right_shift(x, bits)
    return math_floor(x / (2^bits))
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
    if vehicle.get_position_xz ~= nil then
        return vehicle:get_position_xz()
    end
    local pos = vehicle:get_position()
    return vec2(pos:x(), pos:z())
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
    --for i = 0, vehicle_count - 1 do
    --    local unit = update_get_map_vehicle_by_index(i)

    for x, unit in pairs(get_vehicles_table()) do
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
        if g_is_hud then
            return vehicle:get_is_docked()
        end
        return vehicle:get_attached_parent_id() ~= 0
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
    if g_debug_enabled then
        local st, err = pcall(_refresh_missile_data, visible_only)
        if not st then
            print(err)
        end
    else
        _refresh_missile_data(visible_only)
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
                if item.type == a_def or (-1 * item.type == a_def) then
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

function rev_remove_all_docked_attachments(carrier, bay_index)
    local attached_vehicle = update_get_map_vehicle_by_id(carrier:get_attached_vehicle_id(bay_index))
    if attached_vehicle:get() and attached_vehicle:get_dock_state() == e_vehicle_dock_state.docked then
        local slots = attached_vehicle:get_attachment_count()
        for i = 1, slots do
            carrier:set_attached_vehicle_attachment(bay_index, i, -1)
        end
        return attached_vehicle
    end
    return nil
end

function rev_set_preconfigure_attachments(carrier, bay_index, preset)
    local attached_vehicle = rev_remove_all_docked_attachments(carrier, bay_index)
    if attached_vehicle then
        local presets = g_revolution_loadout_preset[attached_vehicle:get_definition_index()]
        if presets then
            local attachments = presets[preset]
            if attachments then
                for attachment_index, attachment_definition in pairs(attachments) do
                    carrier:set_attached_vehicle_attachment(bay_index, attachment_index, attachment_definition)
                end
            end
        end
    end
end

function rev_has_preconfigure_preset(carrier, bay_index, preset)
    local attached_vehicle = update_get_map_vehicle_by_id(carrier:get_attached_vehicle_id(bay_index))
    if attached_vehicle:get() and attached_vehicle:get_dock_state() == e_vehicle_dock_state.docked then
        local presets = g_revolution_loadout_preset[attached_vehicle:get_definition_index()]
        if presets then
            if presets[preset] then
                return true
            end
        end
    end
    return false
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
    _light_wing_weapons = {
        e_game_object_type.attachment_turret_plane_chaingun,
        e_game_object_type.attachment_hardpoint_bomb_1,
        e_game_object_type.attachment_hardpoint_missile_ir,
        e_game_object_type.attachment_hardpoint_missile_laser,
        e_game_object_type.attachment_hardpoint_missile_aa,
        e_game_object_type.attachment_hardpoint_missile_tv,
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
        e_game_object_type.attachment_camera_observation,
    }

    _std_land_utils = {
        e_game_object_type.attachment_flare_launcher,
        e_game_object_type.attachment_sonic_pulse_generator,
        e_game_object_type.attachment_smoke_launcher_explosive,
        e_game_object_type.attachment_smoke_launcher_stream,
        e_game_object_type.attachment_camera,
    }

    --
    -- revolution vehicle attachment option choices
    --

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
                [2] = _std_wing_attachments,
                [3] = _std_wing_attachments,
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
                    { i=5, x=0, y=-15 },
                    { i=1, x=-16, y=-5 },
                    { i=3, x=-16, y=12 },
                    { i=4, x=16, y=12 },
                    { i=2, x=16, y=-5 },
                    -- { i=6, x=0, y=4 },
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
        -- seal
        [e_game_object_type.chassis_land_wheel_light] = {
            options = {
                [1] = concat_lists(_std_land_turrets, {e_game_object_type.attachment_turret_15mm}),
            }
        },
        -- walrus
        [e_game_object_type.chassis_land_wheel_medium] = {
            rows = {
                {
                    { i=2, x=0, y=-15 },
                    { i=1, x=0, y=0 },
                    { i=3, x=0, y=15 },
                    { i=4, x=-13, y=2 },
                    { i=5, x=13, y=2 },
                }
            },
            options = {
                [1] = concat_lists(_std_land_turrets, {e_game_object_type.attachment_turret_heavy_cannon}),
                [2] = _std_land_utils,
                [3] = concat_lists(_std_land_utils, {e_game_object_type.attachment_deployable_droid}),
                [4] = {e_game_object_type.attachment_hardpoint_missile_aa},
                [5] = {e_game_object_type.attachment_hardpoint_missile_aa},
            },
        },
        -- bear
        [e_game_object_type.chassis_land_wheel_heavy] = {
            options = {
                [4] = {
                    e_game_object_type.attachment_hardpoint_missile_aa,
                    e_game_object_type.attachment_hardpoint_missile_tv,
                },
                [5] = {
                    e_game_object_type.attachment_hardpoint_missile_aa,
                    e_game_object_type.attachment_hardpoint_missile_tv,
                }
            },
            rows = {
                {
                    {i=1, x=-16, y=0},
                    {i=2, x=0, y=-6},
                    {i=3, x=16, y=0},
                    {i=4, x=-8, y=12},
                    {i=5, x=8, y=12},
                }
            },
        },
        ---- petrel
        --[e_game_object_type.chassis_air_rotor_heavy] = {
        --    options = {
        --        -- nose slot
        --        [1] = {
        --            e_game_object_type.attachment_camera_plane,
        --            e_game_object_type.attachment_turret_gimbal_30mm,
        --        },
        --    },
        --    rows = {
        --        {
        --            { i=1, x=0, y=-22 }
        --        },
        --        {
        --            { i=2, x=-23, y=0 },
        --            { i=4, x=-14, y=0 },
        --            { i=5, x=14, y=0 },
        --            { i=3, x=23, y=0 }
        --        },
        --        {
        --        --    { i=7, x=0, y=10},
        --            { i=8, x=0, y=23}
        --        }
        --    }
        --},
        -- turret
        [e_game_object_type.chassis_land_turret] = {
            options = {
                [0] = {
                    e_game_object_type.attachment_camera,
                }
            },
        },

        -- carrier
        [e_game_object_type.chassis_carrier] = {
            options = {
                [1] = {
                    e_game_object_type.attachment_turret_carrier_ciws,
                    e_game_object_type.attachment_turret_droid,
                },
                [2] = {
                    e_game_object_type.attachment_turret_carrier_ciws,
                    e_game_object_type.attachment_turret_droid,
                },
                [3] = {
                    e_game_object_type.attachment_turret_carrier_ciws,
                    e_game_object_type.attachment_turret_droid,
                },
                [3] = {
                    e_game_object_type.attachment_turret_carrier_ciws,
                    e_game_object_type.attachment_turret_droid,
                },
                [5] = {
                    e_game_object_type.attachment_turret_carrier_missile,
                    e_game_object_type.attachment_turret_droid,
                },
                [6] = {
                    e_game_object_type.attachment_turret_carrier_missile,
                    e_game_object_type.attachment_hardpoint_missile_laser,
                },
                [7] = {
                    e_game_object_type.attachment_turret_carrier_main_gun,
                    e_game_object_type.attachment_hardpoint_missile_laser,
                    e_game_object_type.attachment_turret_15mm,
                },
                [8] = {
                    e_game_object_type.attachment_turret_carrier_missile_silo,
                },
                [9] = {
                    e_game_object_type.attachment_turret_carrier_flare_launcher,
                },
                [11] = {
                    e_game_object_type.attachment_turret_carrier_torpedo,
                },
                [12] = {
                    e_game_object_type.attachment_turret_carrier_torpedo,
                },
            }
        }
    }

    return ret

end)
if not st then
    print(_v)
else
    g_revolution_attachment_defaults = _v
end

g_revolution_loadout_preset = {
    [e_game_object_type.chassis_air_wing_heavy] = {
        defender = {
            [2] = e_game_object_type.attachment_turret_plane_chaingun,
            [4] = e_game_object_type.attachment_hardpoint_missile_aa,
            [5] = e_game_object_type.attachment_hardpoint_missile_aa,
            [6] = e_game_object_type.attachment_flare_launcher,
        },
        strike = {
            [3] = e_game_object_type.attachment_hardpoint_bomb_2,
            [4] = e_game_object_type.attachment_hardpoint_bomb_1,
            [5] = e_game_object_type.attachment_hardpoint_bomb_1,
        }
    },
    [e_game_object_type.chassis_air_wing_light] = {
        defender = {
            [2] = e_game_object_type.attachment_hardpoint_missile_aa,
            [3] = e_game_object_type.attachment_hardpoint_missile_aa,
            [4] = e_game_object_type.attachment_hardpoint_missile_aa,
            [5] = e_game_object_type.attachment_hardpoint_missile_aa,
        },
        strike = {
            [2] = e_game_object_type.attachment_hardpoint_missile_ir,
            [3] = e_game_object_type.attachment_hardpoint_missile_ir,
            [4] = e_game_object_type.attachment_hardpoint_missile_ir,
            [5] = e_game_object_type.attachment_hardpoint_missile_ir,
        },
        refuel = {
            [4] = e_game_object_type.attachment_fuel_tank_plane,
            [5] = e_game_object_type.attachment_fuel_tank_plane,
        }
    },
    [e_game_object_type.chassis_air_rotor_light] = {
        defender = {
            [1] = e_game_object_type.attachment_hardpoint_missile_aa,
            [2] = e_game_object_type.attachment_hardpoint_missile_aa,
            [3] = e_game_object_type.attachment_flare_launcher,
        },
        strike = {
            [1] = e_game_object_type.attachment_turret_plane_chaingun,
            [2] = e_game_object_type.attachment_turret_plane_chaingun,
            [5] = e_game_object_type.attachment_turret_droid,
        },
        refuel = {
            [1] = e_game_object_type.attachment_fuel_tank_plane,
        }
    },
    [e_game_object_type.chassis_air_rotor_heavy] = {
        defender = {
            [2] = e_game_object_type.attachment_hardpoint_missile_aa,
            [3] = e_game_object_type.attachment_hardpoint_missile_aa,
            [4] = e_game_object_type.attachment_hardpoint_missile_aa,
            [5] = e_game_object_type.attachment_hardpoint_missile_aa,
        },
        strike = {
            [2] = e_game_object_type.attachment_turret_plane_chaingun,
            [3] = e_game_object_type.attachment_turret_plane_chaingun,
            [4] = e_game_object_type.attachment_hardpoint_missile_ir,
            [5] = e_game_object_type.attachment_hardpoint_missile_ir,
        }
    },
    [e_game_object_type.chassis_land_wheel_light] = {
        capture = {
            [1] = e_game_object_type.attachment_turret_robot_dog_capsule
        }
    }
}

function insert_sea_mule_options(vehicle)
    -- also mk2 mule
    if vehicle and vehicle:get() then

        --if g_revolution_attachment_defaults[e_game_object_type.chassis_land_wheel_mule] == nil then
            if vehicle:get_definition_index() == e_game_object_type.chassis_land_wheel_mule then
                local ac = vehicle:get_attachment_count()
                if ac == 8 then
                    -- insert
                    local mule = {
                        rows = {
                            {
                                { i=7, x=0, y=-23 },
                                { i=1, x=-9, y=-10 },
                                { i=2, x=9, y=-10},
                                { i=3, x=-9, y=7 },
                                { i=4, x=9, y=7},
                                { i=5, x=-9, y=24 },
                                { i=6, x=9, y=24},
                            }
                        },
                        options = {
                            [7] = {
                                e_game_object_type.attachment_turret_30mm,
                                e_game_object_type.attachment_turret_40mm,
                            },
                            [1] = {
                                e_game_object_type.attachment_turret_robot_dog_capsule,
                                e_game_object_type.attachment_smoke_launcher_explosive,
                            },
                            [2] = {
                                e_game_object_type.attachment_turret_robot_dog_capsule,
                                e_game_object_type.attachment_camera,
                            },
                        }
                    }
                    g_revolution_attachment_defaults[e_game_object_type.chassis_land_wheel_mule] = mule

                end
            end
        --end

    end
end


-- script leader utils

function get_team_lead(team_id)
    local names = {}
    local peer_count = update_get_peer_count()
    for i = 0, peer_count - 1 do
        local peer_team = update_get_peer_team(i)
        local peer_name = update_get_peer_name(i)
        if peer_team == team_id then
            table.insert(names, peer_name)
        end
    end
    table.sort(names, function(a, b) return string.lower(a) < string.lower(b) end)

    return names[1]
end

-- return True if this game client is the "lead" client for scripting
-- this is used where you want to limit a chunk of code to happening
-- for only one player per team
function get_is_lead_team_peer()
    -- get the peer names, return true if we are the first in sorted order
    if not update_get_is_multiplayer() then
        return true
    end

    local self_id = update_get_local_peer_id()
    local self_idx = update_get_peer_index_by_id(self_id)
    local self_name = update_get_peer_name(self_idx)
    local self_team = update_get_peer_team(self_idx)

    return get_team_lead(self_team) == self_name
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
            local value = math_floor(math.min(tick_when_fixed, update_get_logic_tick() + g_island_factory_damage_ticks_max))
            if g_missile_debug then
                print("factory " .. island_id .. " dmg=" .. value)
            end
            drydock:set_waypoint_altitude(wpt, value)
        end
    end
end


function get_factory_damage_enabled()
    if g_revolution_enable_factory_damage == nil then
        if update_get_map_vehicle_count() > 300 then
            return false
        end
        return true
    end
    return g_revolution_enable_factory_damage
end


-- rotary hover load/drop/landing detection
g_rotary_hover = {}
g_rotary_hover_last_tick = 0
g_hover_callback = nil

function add_altitude_waypoint(vehicle, pos, alt, hold_grp)
    local wpt = vehicle:add_waypoint(pos:x(), pos:y())
    vehicle:set_waypoint_altitude(wpt, math_floor(alt), 0)
    if hold_grp ~= nil then
        vehicle:set_waypoint_wait_group(wpt, hold_grp, true)
    end
    return wpt
end

get_internal_fuel_sizes = {
    [e_game_object_type.chassis_air_wing_light] = 800,
    [e_game_object_type.chassis_air_rotor_light] = 400,
    [e_game_object_type.chassis_air_wing_heavy] = 1200,
    [e_game_object_type.chassis_air_rotor_heavy] = 2000,
    [e_game_object_type.chassis_carrier] = 50000,
    [e_game_object_type.chassis_land_wheel_heavy] = 1600,
    [e_game_object_type.chassis_land_wheel_medium] = 1200,
    [e_game_object_type.chassis_land_wheel_mule] = 2000,
    [e_game_object_type.chassis_land_wheel_light] = 800,
}

function get_internal_fuel_size(vehicle_definition_index)
    local value = get_internal_fuel_sizes[vehicle_definition_index]
    if value == nil then
        value = 0
    end
    return value
end

function iter_hostile_units(team, func)
    local vehicle_count = update_get_map_vehicle_count()
    for i = 0, vehicle_count - 1 do
        local vehicle = update_get_map_vehicle_by_index(i)

        if vehicle:get() then
            if not get_vehicle_docked(vehicle) then
                local vehicle_team = vehicle:get_team()
                if vehicle_team ~= team then
                    func(vehicle)
                end
            end
        end
    end
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
    [e_game_object_type.attachment_camera_plane] = e_inventory_item.attachment_camera_plane,
    [e_game_object_type.attachment_turret_gimbal_30mm] = e_inventory_item.attachment_turret_gimbal_30mm,
    [e_game_object_type.attachment_flare_launcher] = e_inventory_item.attachment_flare_launcher,
    [e_game_object_type.attachment_turret_plane_chaingun] = e_inventory_item.attachment_turret_plane_chaingun,
    [e_game_object_type.attachment_hardpoint_bomb_1] = e_inventory_item.hardpoint_bomb_1,
    [e_game_object_type.attachment_hardpoint_bomb_2] = e_inventory_item.hardpoint_bomb_2,
    [e_game_object_type.attachment_hardpoint_bomb_3] = e_inventory_item.hardpoint_bomb_3,
    [e_game_object_type.attachment_hardpoint_missile_ir] = e_inventory_item.hardpoint_missile_ir,
    [e_game_object_type.attachment_hardpoint_missile_laser] = e_inventory_item.hardpoint_missile_laser,
    [e_game_object_type.attachment_hardpoint_missile_aa] = e_inventory_item.hardpoint_missile_aa,
    [e_game_object_type.attachment_hardpoint_torpedo] = e_inventory_item.hardpoint_torpedo,
    [e_game_object_type.attachment_hardpoint_torpedo_decoy] = e_inventory_item.hardpoint_torpedo_decoy,
    [e_game_object_type.attachment_hardpoint_torpedo_noisemaker] = e_inventory_item.hardpoint_torpedo_noisemaker,
    [e_game_object_type.attachment_hardpoint_missile_tv] = e_inventory_item.hardpoint_missile_tv,
    [e_game_object_type.attachment_radar_awacs] = e_inventory_item.attachment_radar_awacs,
    [e_game_object_type.attachment_turret_rocket_pod] = e_inventory_item.attachment_turret_rocket_pod,
    [e_game_object_type.attachment_fuel_tank_plane] = e_inventory_item.attachment_fuel_tank_plane,
    [e_game_object_type.attachment_deployable_droid] = e_inventory_item.deployable_droid,
    [e_game_object_type.attachment_radar_golfball] = e_inventory_item.attachment_radar_golfball,
}

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
                value = value + g_item_data[e_inventory_item.fuel_barrel].mass
            elseif definition_index == e_game_object_type.attachment_turret_rocket_pod then
                -- 19 rockets
                value = value + 200 + (19 * g_item_data[e_inventory_item.ammo_rocket].mass)
            end
        end
    end

    -- inventory masses of these are excessive, set more game-friendly values here
    if definition_index == e_game_object_type.attachment_turret_droid then
        value = 180
    elseif definition_index == e_game_object_type.attachment_turret_plane_chaingun then
        value = 265
    elseif definition_index == e_game_object_type.attachment_hardpoint_torpedo then
        value = 800
    elseif definition_index == e_game_object_type.attachment_hardpoint_bomb_2 then
        value = 630
    elseif definition_index == e_game_object_type.attachment_hardpoint_missile_aa then
        value = 184
    elseif definition_index == e_game_object_type.attachment_hardpoint_missile_tv then
        value = 293
    elseif definition_index == e_game_object_type.attachment_turret_gimbal_30mm then
        value = 190
    elseif definition_index == e_game_object_type.attachment_turret_30mm then
        value = 400
    elseif definition_index == e_game_object_type.attachment_turret_40mm then
        value = 600
    elseif definition_index == e_game_object_type.attachment_turret_ciws then
        value = 650
    elseif definition_index == e_game_object_type.attachment_radar_golfball then
        value = 650
    elseif definition_index == e_game_object_type.attachment_turret_missile then
        value = 750
    end
    if value < 1 then
        value = 80
    end

    return value
end

g_rev_unit_max_payload = {
    [e_game_object_type.chassis_air_wing_heavy] = 2500,
    [e_game_object_type.chassis_air_rotor_heavy] = 8000,
    [e_game_object_type.chassis_air_rotor_light] = 2600,
    [e_game_object_type.chassis_air_wing_light] = 2800,
    [e_game_object_type.chassis_land_wheel_medium] = 980,
}

-- g_rev_allow_carrier_land_turrets = false
g_rev_unit_hard_payload_limit = {
    [e_game_object_type.chassis_land_wheel_medium] = true,
}

function get_unit_payload_weight(vehicle)
    local value = 0
    if vehicle and vehicle:get() then
        local attachment_count = vehicle:get_attachment_count()
        for i = 0, attachment_count - 1 do
            local attachment = vehicle:get_attachment(i)
            if attachment and attachment:get() then
                local def = attachment:get_definition_index()
                if def ~= -1 then
                    value = value + get_payload_weight(def)
                end
            end
        end
    end
    return value
end

function rev_get_unit_has_payload_limit(vehicle)
    if vehicle and vehicle:get() then
        local definition_index = vehicle:get_definition_index()
        return g_rev_unit_max_payload[definition_index] ~= nil
    end
    return false
end

function rev_get_unit_has_hard_payload_limit(vehicle)
    if vehicle and vehicle:get() then
        local definition_index = vehicle:get_definition_index()
        return g_rev_unit_hard_payload_limit[definition_index] ~= nil
    end
    return false
end

function rev_get_payload_remaining(vehicle)
    local definition_index = vehicle:get_definition_index()
    local payload_max = g_rev_unit_max_payload[definition_index]
    if payload_max == nil then
        payload_max = 50000 -- probably not an aircraft, let everything use normal rules
    end
    local payload_mass = get_unit_payload_weight(vehicle)
    local payload_remain = payload_max - payload_mass
    return payload_remain
end

function rev_check_attachment_exceeds_payload(vehicle, attachment_index, attachment_definition)
    local payload_remain = rev_get_payload_remaining(vehicle)
    if attachment_definition > -1 then
        local replace_mass = get_payload_weight(attachment_definition)
        local current = vehicle:get_attachment(attachment_index)
        if current and current:get() then
            local current_def = current:get_definition_index()
            if current_def > -1 then
                local current_mass = get_payload_weight(current_def)
                if current_mass > 0 then
                    payload_remain = payload_remain + current_mass -- ignore whatever is in this slot
                end
            end
            return payload_remain >= replace_mass
        end
    end

    return true
end

-- vehicle history class and data
VehicleHistory = {}
VehicleHistory.__index = VehicleHistory

function VehicleHistory:new(vehicle)
    local self = {}
    setmetatable(self, VehicleHistory)
    self.id = vehicle:get_id()
    self.max_history = 10
    self.update_interval = 10
    self.position = {}
    -- self.fuel = {}
    self.updated = 0
    self:record_data(vehicle)
    return self
end

function VehicleHistory:update()
    local vehicle = update_get_map_vehicle_by_id(self.id)
    if vehicle and vehicle:get() then
        self:record_data(vehicle)
    end
end

function VehicleHistory:record_data(vehicle)
    local now = update_get_logic_tick()
    if now - self.updated > self.update_interval then
        local pos = vehicle:get_position_xz()

        table_append_max(self.position, pos, self.max_history)
        --table_append_max(self.fuel, vehicle:get_fuel_factor(), self.max_history)
        self.updated = now
    end
end

--function VehicleHistory:get_fuel_rate()
--    local fuel_tab = self.fuel
--    if #fuel_tab > 2 then
--        local burn = fuel_tab[#fuel_tab] - fuel_tab[#fuel_tab - 1]
--        if burn > 0 and burn < 1 then
--            return burn
--        end
--    end
--    return 0
--end

function VehicleHistory:get_velocity()
    local pos_tab = self.position
    if #pos_tab > 2 then
        local p1 = pos_tab[1]
        local p2 = pos_tab[#pos_tab]

        local dx = p2:x() - p1:x()
        local dy = p2:y() - p1:y()

        local ticks = #pos_tab * self.update_interval
        local duration = ticks / 30

        -- m/s vec2
        local vx = dx / duration
        local vy = dy / duration
        return vec2(vx, vy)
    end
    return nil
end

function VehicleHistory:get_last_position()
    local pos_tab = self.position
    if #pos_tab then
        return pos_tab[#pos_tab]
    end
    return nil
end

function VehicleHistory:get_valid()
    local vel = self:get_velocity()
    local now = update_get_logic_tick()
    if now - self.updated < 10 then
        if vel and vec2_dist(vec2(0, 0), vel) < 500 then
            return true
        end
    end
    return false
end


function save_vehicle_history(history_tab, vehicle)
    if vehicle and vehicle:get() then
        local v_id = vehicle:get_id()
        local hist = history_tab[v_id]
        if hist ~= nil then
            hist:update()
        else
            hist = VehicleHistory:new(vehicle)
            history_tab[v_id] = hist
        end
    end
end

function remove_vehicle_history(history_tab, v_id)
    if history_tab[v_id] ~= nil then
        history_tab[v_id] = nil
    end
end

function update_vehicle_histories(history_tab, base_pos, max_range)
    local range_sq = max_range * max_range
    local function per_vehicle(vehicle)

        local v_def = vehicle:get_definition_index()
        if get_is_vehicle_sea(v_def) then
            local v_id = vehicle:get_id()
            -- is it near the base_vehicle and is visible

            local dist_sq = vec2_dist_sq(vehicle:get_position_xz(), base_pos)
            if vehicle:get_is_visible() and dist_sq < range_sq then
                save_vehicle_history(history_tab, vehicle)
            else
                history_tab[v_id] = nil
            end
        end
    end
    iter_hostile_units(update_get_screen_team_id(), per_vehicle)
end

function iter_vehicle_histories(hist_tab, func)
    for v_id, hist in pairs(hist_tab) do
        if hist ~= nil then
            func(hist)
        end
    end
end

function do_screensaver(screen_w, screen_h, screen_enum)
    local total_units = update_get_map_vehicle_count()

    if string.find(g_screen_name, "holomap") then
        -- dont do this for the huge tacops screen
        return false
    end

    if total_units < 400 and string.find(g_screen_name, "screen_veh_") then
        -- dont sleep the bridge screens
        return false
    end

    local now = update_get_logic_tick()
    local elapsed = now - g_last_input_tick
    local seconds = elapsed / 30
    local expired = seconds > 300

    if total_units > 400 and not update_get_is_focus_local() then
        expired = true
    end

    if g_last_update_interval ~= nil and g_last_update_interval > 60 then
        -- no player near screen for 2 seconds
        if not update_get_is_focus_local() then
            expired = true
        end
    end
    local drydock = false
    local eliminated = false
    if string.match(g_screen_name, "drydock") then
        drydock = true
        eliminated = team_eliminated(update_get_screen_team_id())
        if not eliminated then
            -- always show the drydock screensaver if the team still has a carrier
            expired = true
        else
            expired = false
        end
    end

    if expired and drydock then
        if screen_w == 256 then
            local st, err = pcall(do_advertising_update, screen_w, screen_h)
            if not st then
                print(err)
            end
            return true
        end
    end

    local abbr = "ACC"
    local screen_vehicle = update_get_screen_vehicle()
    if screen_vehicle and screen_vehicle:get() then
        local v_name, v_icon, v_abbr, v_desc = get_chassis_data_by_definition_index(screen_vehicle:get_definition_index())
        abbr = v_abbr
    end

    if expired then
        update_set_screen_background_type(0)
        local y = screen_h / 4

        if drydock then
            -- the drydock bar screens
            if not eliminated then
                local size = 1
                if screen_w > 256 then
                    size = 4
                end
                local tx = screen_w * -1
                local tx = tx + now % (screen_w * 2)
                update_ui_text_scale(tx, y, "Drydock Bar & Grill", screen_w, 0, color_status_ok, 0, size)
            end
        else
            update_ui_text(
                    50, y,
                    abbr .. get_ship_name(screen_vehicle),
                    100, 1, color_grey_mid, 0)
            update_ui_line(
                    50, y + 11,
                    200, y + 11,
                    color_grey_dark
            )

            update_ui_text(
                    58, y + 13,
                    update_get_loc(screen_enum),
                    100, 1, color_grey_mid, 0)

            if now % 30 < 15 then
                update_ui_text(
                        50, y + 13,
                        ">",
                        12, 1, color_grey_mid, 0)
            end
        end

        update_ui_text(12, screen_h - 25, string.format("%d total units", total_units), screen_w, 0, color_grey_mid, 0)

        update_ui_text(50, screen_h - 24, format_time(update_get_logic_tick() / 30), screen_w, 1, color_grey_mid, 0)

        return true
    end
    return false
end

function round_int(value)
    return math_floor(value + 0.5)
end

g_vt = {}
g_vt_tick = 0
g_carriers_table = {}


function get_vehicles_table()
    local now = update_get_logic_tick()
    if now > g_vt_tick then
        g_vt = nil
    end

    if g_vt == nil then
        g_vt_tick = now
        g_vt = {}
        g_carriers_table = {}
        local vt = g_vt
        local ct = g_carriers_table
        local vehicle_count = update_get_map_vehicle_count()

        for i = 0, vehicle_count - 1, 1 do
            local vehicle = update_get_map_vehicle_by_index(i)

            if vehicle and vehicle:get() then
                local proxy = VProxy_get(vehicle)
                table.insert(vt, proxy)

                if vehicle:get_definition_index() == e_game_object_type.chassis_carrier then
                    table.insert(ct, proxy)
                end

            end
        end
    end

    return g_vt;
end

function get_carriers_table()
    get_vehicles_table()
    return g_carriers_table
end

function get_nearest_carrier(vehicle, friendly, current_team)
    local nearest_dist_sq = 400000 * 400000
    local lim_dist_sq = 10000 * 10000
    local pos = get_pos_xz(vehicle)
    local nearest = nil
    for _, crr in pairs(get_carriers_table()) do
        local crr_team = get_vehicle_team_id(crr)
        local match = (crr_team == current_team) and friendly
        if match then
            local d = fast_dist_sq2(pos, get_pos_xz(crr), lim_dist_sq)
            if d < nearest_dist_sq then
                nearest = crr
                nearest_dist_sq = d
            end
        end
    end
    return nearest, nearest_dist_sq^0.5
end

function team_eliminated(team_id)
    for _, crr in pairs(get_carriers_table()) do
        if crr and crr:get() then
            if crr:get_team() == team_id then
                return false
            end
        end
    end
    return true
end

function fast_sqrt(x)
    return x^0.5
end

-- send data to/from the HUD
function get_settings_pending_gfx_x()
    local settings = update_get_game_settings()
    return settings.gfx_resolution_pending_x
end

function get_settings_pending_gfx_y()
    local settings = update_get_game_settings()
    return settings.gfx_resolution_pending_y
end

function reset_settings_pending_gfx()
    local settings = update_get_game_settings()
    set_settings_pending_gfx(settings.gfx_resolution_x, settings.gfx_resolution_y)
end

function set_settings_pending_gfx(w, h)
    local settings = update_get_game_settings()
    if settings.gfx_resolution_pending_x ~= w then
        if settings.gfx_resolution_pending_y ~= h then
            update_ui_event("set_game_setting gfx_resolution", w, h)
        end
    end
end

-- vehicle proxy class to reduce lua<->native calls
local VProxy = {}
function VProxy.new(real)
    local self = setmetatable({}, {__index = VProxy})
    self.extended = true
    self.team = 0
    self.id = 0
    self.definition_index = nil
    self.get_attachment_count_ = nil
    self.get_is_observation_type_revealed_ = nil
    self.get_is_observation_weapon_revealed_ = nil
    self.get_is_observation_fully_revealed_ = nil
    self.get_position_xz_ = nil
    self.get_position_ = nil
    self.get_direction_ = nil
    self.get_rotation_y_ = nil
    self.get_vehicle_attachment_count_ = nil
    self.get_hitpoints_ = nil
    self.get_total_hitpoints_ = nil
    self.get_attached_parent_id_ = nil
    self.get_controlling_peer_id_ = nil
    self.get_is_visible_by_enemy_ = nil
    self.get_is_visible_ = nil
    self.get_is_observation_revealed_ = nil
    self.get_waypoint_count_ = nil
    self.get_is_docked_ = nil
    self.team = 0
    self.attachment_defs = {}
    self.radar_type = -1
    self.radar_state = nil
    self.radar_state_known = false
    self.seen_by_friendly_radars = nil
    self.is_visible_by_hostile_modded_radar = nil
    self.position_xz = nil
    self.position = nil
    self.altitude = nil
    self.v = real
    if self.v and self.v:get() then
        self.definition_index = self.v:get_definition_index()
        if self.v.get_team_id ~= nil then
            self.team = self.v:get_team_id()
        else
            self.team = self.v:get_team()
        end
        self.id = self.v:get_id()
    else
        self.v = nil
    end
    return self
end

function VProxy:get()
    if self.v ~= nil then
        return true
    end
    return false
end

function VProxy:get_id()
    return self.id
end

function VProxy:get_is_hud()
    return g_is_hud == true
end

function VProxy:get_definition_index()
    return self.definition_index
end

function VProxy:get_attachment_count()
    if self.get_attachment_count_ == nil and self.v then
        self.get_attachment_count_ = self.v:get_attachment_count()
    end
    return self.get_attachment_count_
end

function VProxy:get_waypoint_count()
    if self.get_waypoint_count_ == nil and self.v then
        self.get_waypoint_count_ = self.v:get_waypoint_count()
    end
    return self.get_waypoint_count_
end

function VProxy:get_rotation_y()
    if self.get_rotation_y_ == nil and self.v then
        self.get_rotation_y_ = self.v:get_rotation_y()
    end
    return self.get_rotation_y_
end


function VProxy:get_direction()
    if self.get_direction_ == nil and self.v then
        self.get_direction_ = self.v:get_direction()
    end
    return self.get_direction_
end

function VProxy:get_is_visible()
    if self.get_is_visible_ == nil and self.v then
        self.get_is_visible_ = self.v:get_is_visible()
    end
    return self.get_is_visible_
end

function VProxy:get_is_observation_revealed()
    if self.get_is_observation_revealed_ == nil and self.v then
        self.get_is_observation_revealed_ = self.v:get_is_observation_revealed()
    end
    return self.get_is_observation_revealed_
end

function VProxy:get_controlling_peer_id()
    if self.get_controlling_peer_id_ == nil and self.v then
        self.get_controlling_peer_id_ = self.v:get_controlling_peer_id()
    end
    return self.get_controlling_peer_id_
end

function VProxy:get_position_xz()
    if self.get_position_xz_ == nil and self.v then
        if self:get_is_hud() then
            local pos3 = self.v:get_position()
            self.get_position_xz_ = vec2(pos3:x(), pos3:z())
        else
            self.get_position_xz_ = self.v:get_position_xz()
        end
    end
    return self.get_position_xz_
end

function VProxy:get_altitude()
    if self.altitude == nil and self.v then
        self.altitude = get_unit_altitude(self.v)
    end
    return self.altitude
end

function VProxy:get_position()
    if self.get_position_ == nil and self.v then
        if self:get_is_hud() then
            self.get_position_ = self.v:get_position()
        else
            local pos = self:get_position_xz()
            if pos then
                self.get_position_ = vec3(pos:x(), self:get_altitude(), pos:y())
            end
        end
    end
    return self.get_position_
end


function VProxy:get_team()
    return self.team
end

function VProxy:get_team_id()
    return self.team
end

function VProxy:get_hitpoints()
    if self.get_hitpoints_ == nil and self.v then
        self.get_hitpoints_ = self.v:get_hitpoints()
    end
    return self.get_hitpoints_
end

function VProxy:get_total_hitpoints()
    if self.get_total_hitpoints_ == nil and self.v then
        self.get_total_hitpoints_ = self.v:get_total_hitpoints()
    end
    return self.get_total_hitpoints_
end

function VProxy:get_attached_parent_id()
    if self.get_attached_parent_id_ == nil and self.v then
        if self.v.get_attached_parent_id ~= nil then
            self.get_attached_parent_id_ = self.v:get_attached_parent_id()
        else
            return 0
        end
    end
    return self.get_attached_parent_id_
end

function VProxy:get_is_visible_by_enemy()
    if self.get_is_visible_by_enemy_ == nil and self.v then
        self.get_is_visible_by_enemy_ = self.v:get_is_visible_by_enemy()
    end
    return self.get_is_visible_by_enemy_
end

function VProxy:get_is_observation_type_revealed()
    if self.get_is_observation_type_revealed_ == nil and self.v then
        self.get_is_observation_type_revealed_ = self.v:get_is_observation_type_revealed()
    end
    return self.get_is_observation_weapon_revealed_
end

function VProxy:get_is_observation_weapon_revealed()
    if self.get_is_observation_weapon_revealed_ == nil and self.v then
        self.get_is_observation_weapon_revealed_ = self.v:get_is_observation_weapon_revealed()
    end
    return self.get_is_observation_weapon_revealed_
end

function VProxy:get_is_observation_fully_revealed()
    if self.get_is_observation_fully_revealed_ == nil and self.v then
        self.get_is_observation_fully_revealed_ = self.v:get_is_observation_fully_revealed()
    end
    return self.get_is_observation_fully_revealed_
end

function VProxy:get_is_docked()
    -- HUD only
    if self.v then
        if self:get_is_hud() then
            self.get_is_docked_ = self.v:get_is_docked()
        else
            local parent = self:get_attached_parent_id()
            self.get_is_docked_ = parent ~= 0
        end
    end
    return self.get_is_docked_ == true
end


-- pass through methods, no caches
function VProxy:get_attachment(i)
    if self.v then
        return self.v:get_attachment(i)
    end
    return nil
end

function VProxy:get_attachment_type(i)
    if self.v then
        return self.v:get_attachment_type(i)
    end
    return nil
end

function VProxy:get_attached_vehicle_id(i)
    if self.v then
        return self.v:get_attached_vehicle_id(i)
    end
    return nil
end

function VProxy:get_observation_factor()
    if self.v then
        return self.v:get_observation_factor()
    end
    return 0
end

function VProxy:get_ammo_factor()
    if self.v then
        return self.v:get_ammo_factor()
    end
    return 0
end

function VProxy:get_repair_factor()
    if self.v then
        return self.v:get_repair_factor()
    end
    return 0
end

function VProxy:get_fuel_factor()
    if self.v then
        return self.v:get_fuel_factor()
    end
    return 0
end

function VProxy:get_is_hold_fire()
    if self.v then
        return self.v:get_is_hold_fire()
    end
    return false
end

function VProxy:get_special_id()
    if self.v then
        return self.v:get_special_id()
    end
    return 0
end

function VProxy:get_dock_state()
    if self.v then
        return self.v:get_dock_state()
    end
    return 0
end

function VProxy:get_dock_queue_vehicle_id()
    if self.v then
        return self.v:get_dock_queue_vehicle_id()
    end
    return 0
end

function VProxy:get_supporting_vehicle_id()
    if self.v then
        return self.v:get_supporting_vehicle_id()
    end
    return 0
end

function VProxy:get_resupply_vehicle_id()
    if self.v then
        return self.v:get_resupply_vehicle_id()
    end
    return 0
end

function VProxy:get_resupplying_vehicle_id(j)
    if self.v then
        return self.v:get_resupplying_vehicle_id(j)
    end
    return 0
end

function VProxy:get_resupplying_vehicle_id_count()
    if self.v then
        return self.v:get_resupplying_vehicle_id_count()
    end
    return 0
end

function VProxy:get_attack_target_position_xz()
    if self.v then
        return self.v:get_attack_target_position_xz()
    end
    return 0
end

function VProxy:get_attack_target_type()
    if self.v then
        return self.v:get_attack_target_type()
    end
    return 0
end

function VProxy:get_waypoint(i)
    if self.v then
        return self.v:get_waypoint(i)
    end
    return nil
end

function VProxy:get_waypoint_path(i)
    if self.v then
        return self.v:get_waypoint_path(i)
    end
    return nil
end

function VProxy:get_waypoint_by_id(i)
    if self.v then
        return self.v:get_waypoint_by_id(i)
    end
    return nil
end

function VProxy:remove_waypoint_attack_target(wpt, i)
    if self.v then
        return self.v:remove_waypoint_attack_target(wpt, i)
    end
    return nil
end

function VProxy:clear_waypoints()
    if self.v then
        return self.v:clear_waypoints()
    end
    return nil
end

function VProxy:clear_attack_target()
    if self.v then
        return self.v:clear_attack_target()
    end
    return nil
end

function VProxy:clear_waypoints_from(i)
    if self.v then
        return self.v:clear_waypoints_from(i)
    end
    return nil
end

function VProxy:add_waypoint(x, z)
    if self.v then
        return self.v:add_waypoint(x, z)
    end
    return nil
end

function VProxy:set_target_vehicle(wpt, tid)
    if self.v then
        return self.v:add_waypoint(wpt, tid)
    end
    return nil
end

function VProxy:set_waypoint_repeat(wpt1, wpt2)
    if self.v then
        return self.v:set_waypoint_repeat(wpt1, wpt2)
    end
    return nil
end

function VProxy:get_vision_last_known_position_xz()
    if self.v then
        return self.v:get_vision_last_known_position_xz()
    end
    return nil
end

function VProxy:get_damage_indicator_factor()
    if self.v then
        return self.v:get_damage_indicator_factor()
    end
    return 0
end

function VProxy:get_is_attack_type_capable(atype, air, land, sea)
    if self.v then
        return self.v:get_is_attack_type_capable(atype, air, land, sea)
    end
    return 0
end


function VProxy:get_attached_vehicle_id(bay)
    if self.v then
        return self.v:get_attached_vehicle_id(bay)
    end
    return 0
end

-- setters

function VProxy:set_is_hold_fire(value)
    if self.v then
        return self.v:set_is_hold_fire(value)
    end
    return 0
end

function VProxy:set_waypoint_wait_group(wpt, gid, value)
    if self.v then
        return self.v:set_waypoint_wait_group(wpt, gid, value)
    end
    return 0
end

function VProxy:set_waypoint_type_deploy(wpt, value)
    if self.v then
        return self.v:set_waypoint_type_deploy(wpt, value)
    end
    return 0
end

function VProxy:set_waypoint_altitude(wpt, value)
    if self.v then
        return self.v:set_waypoint_altitude(wpt, value)
    end
    return 0
end

function VProxy:set_waypoint_attack_target_target_id(wpt, value)
    if self.v then
        return self.v:set_waypoint_attack_target_target_id(wpt, value)
    end
    return 0
end

function VProxy:set_waypoint_attack_target_attack_type(wpt, attack_index, attack_type)
    if self.v then
        return self.v:set_waypoint_attack_target_attack_type(wpt, attack_index, attack_type)
    end
    return 0
end

function VProxy:set_waypoint_repeat(wpt1, wpt2)
    if self.v then
        return self.v:set_waypoint_repeat(wpt1, wpt2)
    end
    return 0
end

function VProxy:set_target_vehicle(wpt, value)
    if self.v then
        return self.v:set_target_vehicle(wpt, value)
    end
    return 0
end

function VProxy:get_barge_state_data()
    return self.v:get_barge_state_data()
end

-- extended methods
function VProxy:has_attachment_type(a_def)
    if #self.attachment_defs == 0 then
        local attachment_count = self:get_attachment_count()
        for i = 0, attachment_count - 1 do
            local attachment = self:get_attachment(i)
            if attachment and attachment:get() then
                local definition_index = attachment:get_definition_index()
                table.insert(self.attachment_defs, definition_index)
            end
        end
    end

    for _, a in pairs(self.attachment_defs) do
        if a == a_def then
            return true
        end
    end
    return false
end

function VProxy:get_radar_type()
    if self.radar_type == -1 then
        if self:get_definition_index() == e_game_object_type.chassis_carrier then
            self.radar_type = e_game_object_type.attachment_radar_awacs
        else
            self.radar_type = has_attachment(self.v, radar_attachment_defs)
        end
    end

    return self.radar_type
end

function VProxy:get_radar_range()
    if self.radar_range == nil then
        self.radar_range = _get_modded_radar_range(self.v)
    end
    return self.radar_range
end

function VProxy:get_radar_state()
    if self.radar_state_known == false then
        self.radar_state = _get_vehicle_radar_state(self.v)
        self.radar_state_known = true
    end
    return self.radar_state
end

function VProxy:get_is_seen_by_friendly_modded_radar()
    if self.seen_by_friendly_radars == nil then
        self.seen_by_friendly_radars = g_seen_by_friendly_radars[self.id] == true
    end
    return self.seen_by_friendly_radars
end

function VProxy:get_is_visible_by_hostile_modded_radar()
    if self.is_visible_by_hostile_modded_radar == nil then
        self.is_visible_by_hostile_modded_radar = g_seen_by_hostile_radars[self.id] ~= nil
    end
    return self.is_visible_by_hostile_modded_radar
end

function VProxy:set_attached_vehicle_attachment(vehicle_bay, attachment_index, attachment_type)
    if self.v and self.v.set_attached_vehicle_attachment then
        self.v:set_attached_vehicle_attachment(vehicle_bay, attachment_index, attachment_type)
    end
end

-- factory

function VProxy_get(real)
    return VProxy.new(real)
end
