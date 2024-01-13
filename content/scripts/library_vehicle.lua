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
            name = "ECM",
            icon16 = atlas_icons.icon_attachment_16_air_fuel,
            name_short = "ECM",
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

function get_is_vehicle_sea(definition_index)
    return definition_index == e_game_object_type.chassis_carrier
        or definition_index == e_game_object_type.chassis_sea_barge
        or definition_index == e_game_object_type.chassis_sea_ship_light
        or definition_index == e_game_object_type.chassis_sea_ship_heavy
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

function get_is_vehicle_airliftable(definition_index)
    return definition_index == e_game_object_type.chassis_land_wheel_heavy
        or definition_index == e_game_object_type.chassis_land_wheel_medium
        or definition_index == e_game_object_type.chassis_land_wheel_light
        or definition_index == e_game_object_type.chassis_land_robot_dog
        or definition_index == e_game_object_type.chassis_land_wheel_mule
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
        -- TODO figure out localization
        if item_type == e_inventory_item.attachment_fuel_tank_plane then
            item_name = "ECM"
            item_desc = "Radar Jammer and Extra fuel"
        end

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

-- every unit in detection range of a needlefish (of any team)
g_seen_by_bad_needlefish = {}
g_seen_by_our_needlefish = {}


function _get_ship_detection_range(definition_index)
    if definition_index == e_game_object_type.attachment_turret_carrier_ciws then
        return 5000
    elseif definition_index == e_game_object_type.attachment_turret_carrier_torpedo then
        return 3500
    elseif definition_index == e_game_object_type.attachment_turret_carrier_missile_silo then
        return 6000
    elseif definition_index == e_game_object_type.attachment_turret_carrier_main_gun then
        return 2000
    else
        return 0
    end
end

function _get_needlefish_weapon(vehicle)
    local attachment_count = vehicle:get_attachment_count()
    for i = 0, attachment_count - 1 do
        local attachment = vehicle:get_attachment(i)
        if attachment:get() then
            local definition_index = attachment:get_definition_index()
            if (definition_index == e_game_object_type.attachment_turret_carrier_ciws)
                or (definition_index == e_game_object_type.attachment_turret_carrier_torpedo)
                or (definition_index == e_game_object_type.attachment_turret_carrier_missile_silo)
                or (definition_index == e_game_object_type.attachment_turret_carrier_main_gun) then
                return definition_index
            end
        end
    end
    return nil
end

function get_needlefish_detection_range(needlefish)
    if needlefish:get() then
        local fish_weapon = _get_needlefish_weapon(needlefish)
        return _get_ship_detection_range(fish_weapon)
    end
    return 0
end

function _get_unit_visible_by_needlefish(needlefish, unit)
    if needlefish:get() and unit:get() then
        if needlefish:get_team() == unit:get_team() then
            return false
        end
        if needlefish:get_id() ~= unit:get_id() then
            local dist = vec2_dist(needlefish:get_position_xz(), unit:get_position_xz())
            if dist < get_needlefish_detection_range(needlefish) then
                if dist < 500 then
                    -- they can all see anything less than 500m away
                    return true
                end
                local unit_def = unit:get_definition_index()
                -- print(string.format("a %d b %d dist = %d", needlefish:get_id(), unit:get_id(), math.floor(dist)))
                local weapon = _get_needlefish_weapon(needlefish)

                if weapon == e_game_object_type.attachment_turret_carrier_ciws then
                    -- ciws fish can see only aircraft,
                    return get_is_vehicle_air(unit_def)
                elseif weapon == e_game_object_type.attachment_turret_carrier_torpedo then
                    -- torp fish can see only ships
                    return get_is_vehicle_sea(unit_def)
                elseif weapon == e_game_object_type.attachment_turret_carrier_missile_silo then
                    -- cruise fish can see only ships
                    return get_is_vehicle_sea(unit_def)
                elseif weapon == e_game_object_type.attachment_turret_carrier_main_gun then
                    -- gun fish can see only ships
                    return get_is_vehicle_sea(unit_def)
                end
            end
        end
    end
    return false
end

function refresh_fisheye_needlefish_cache()
    -- only do this every 30th tick (once every second)
    local now = update_get_logic_tick()
    if now % 30 == 0 then
        local v1, v2 = _refresh_fisheye_needlefish_cache()
        g_seen_by_bad_needlefish = v1
        g_seen_by_our_needlefish = v2
    end
    --print(string.format("fish data %d %d", now, #g_seen_by_bad_needlefish))
end

function _refresh_fisheye_needlefish_cache()
    local seen_by_bad_fish = {}
    local seen_by_our_fish = {}
    local vehicle_count = update_get_map_vehicle_count()
    local screen_team = update_get_screen_team_id()

    for ii = 0, vehicle_count - 1 do
        local vehicle = update_get_map_vehicle_by_index(ii)
        if vehicle:get() then
            if vehicle:get_definition_index() == e_game_object_type.chassis_sea_ship_light then
                -- we are a fish, see what it can see
                local fish = vehicle
                local fish_team = fish:get_team()
                -- iterate all other things on the map
                for jj = 0, vehicle_count - 1 do
                    local target = update_get_map_vehicle_by_index(jj)
                    local target_def = target:get_definition_index()
                    if get_is_vehicle_sea(target_def) or get_is_vehicle_air(target_def) then
                        -- ships or aircraft
                        if _get_unit_visible_by_needlefish(fish, target) then
                            local tid = target:get_id()
                            if fish_team == screen_team then
                                seen_by_our_fish[tid] = true
                            else
                                seen_by_bad_fish[tid] = true
                            end
                        end
                    end
                end
            end
        end
    end
    return seen_by_bad_fish, seen_by_our_fish
end

function get_is_visible_by_needlefish(vehicle)
    local st, val = pcall(_get_is_visible_by_needlefish, vehicle)
    if not st then
        return false
    end
    return val
end

function get_is_visible_by_hostile_needlefish(vehicle)
    local seen = false
    if vehicle:get() then
        local vid = vehicle:get_id()
        seen = g_seen_by_bad_needlefish[vid] ~= nil
    end
    return seen
end

function _get_is_visible_by_needlefish(vehicle)
    if vehicle:get() then
        local vid = vehicle:get_id()
        local exists = g_seen_by_our_needlefish[vid]

        if exists ~= nil then
            return true
        end
    end
    return false
end

-- fog of war mod --

g_fow_visible = {}
g_fow_range = 16000

g_island_color_unknown = color8(0x12, 0x12, 0x12, 0xff)

function refresh_fow_islands()
    -- only do this every 5x30th tick (once 5 seconds)
    local now = update_get_logic_tick()
    if now % (30 * 5) == 0 then
        g_fow_visible = {}
        local visible = 0
        -- reveal any island within 16km of one of our units
        local our_team = update_get_screen_team_id()
        local island_count = update_get_tile_count()
        local vehicle_count = update_get_map_vehicle_count()

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
                    if vehicle:get() then
                        if vehicle:get_team() == our_team then
                            local unit_pos = vehicle:get_position_xz()
                            local dist = vec2_dist(unit_pos, pos)
                            if dist < g_fow_range then
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
    return g_fow_visible[island_id] == true
end

-- radar jammer mod

g_hostile_jammers = {}
g_hostile_awacs = {}

g_hostile_jamming = {}

function refresh_jammer_units()
    local st, err = pcall(_refresh_jammer_units)
    if not st then
        print(string.format("err = %s", err))
    end
end

function _refresh_jammer_units()
    local now = update_get_logic_tick()
    -- every 1 sec
    if now % 30 == 0 then
        g_hostile_jammers = {}
        g_hostile_awacs = {}
        g_hostile_jamming = {}

        local friendly_radars = {}

        local our_team = update_get_screen_team_id()
        local vehicle_count = update_get_map_vehicle_count()

        -- find all the hostile jammer units and radars
        for ii = 0, vehicle_count - 1 do
            local vehicle = update_get_map_vehicle_by_index(ii)
            if vehicle:get() then
                -- exists
                local parent_id = vehicle:get_attached_parent_id()
                if parent_id == 0 then
                    -- not docked
                    local vdef = vehicle:get_definition_index()
                    local v_id = vehicle:get_id()
                    if our_team ~= vehicle:get_team() then
                        -- hostile
                        if get_is_vehicle_air(vdef) then
                            for ai = 0, vehicle:get_attachment_count() - 1 do
                                local attachment = vehicle:get_attachment(ai)
                                if attachment:get() then
                                    local a_def = attachment:get_definition_index()
                                    if a_def == e_game_object_type.attachment_fuel_tank_plane then
                                        -- has jammer fitted
                                        g_hostile_jammers[v_id] = vehicle
                                    elseif a_def == e_game_object_type.attachment_radar_awacs then
                                        -- has awacs fitted
                                        g_hostile_awacs[v_id] = vehicle
                                    end
                                end
                            end
                        end
                    else
                        -- friendly
                        local jammable = false
                        if vdef == e_game_object_type.chassis_carrier or
                            e_game_object_type.chassis_sea_ship_light then
                            -- ship with a radar
                            jammable = true
                        end

                        if not jammable then
                            -- is it a ground radar or awacs
                            for ai = 0, vehicle:get_attachment_count() - 1 do
                                local attachment = vehicle:get_attachment(ai)
                                if attachment:get() then
                                    local a_def = attachment:get_definition_index()
                                    if a_def == e_game_object_type.attachment_radar_awacs then
                                        -- has awacs fitted
                                        jammable = true
                                    end
                                end
                            end
                        end

                        if jammable then
                            friendly_radars[v_id] = vehicle
                        end
                    end
                end
            end
        end

        -- for each jammer, find the nearest radar
        for jammer_id, jammer in pairs(g_hostile_jammers) do
            local radar_range = 15000
            local nearest = nil
            local jammer_pos = jammer:get_position_xz()
            for radar_id, radar in pairs(friendly_radars) do
                local radar_pos = radar:get_position_xz()
                local dist = vec2_dist(radar_pos, jammer_pos)
                if dist < radar_range then
                    nearest = radar
                    radar_range = dist
                end
            end
            if nearest ~= nil then
                -- show nothing between 9000-10000
                if radar_range < 9000 then
                    -- print(string.format("radar %d is nearest to jammer %d range %f", nearest:get_id(), jammer_id, radar_range))
                    g_hostile_jamming[jammer_id] = nearest
                end
            end
        end
    end
end

function hostile_has_jammer(vehicle_id)
    return g_hostile_jammers[vehicle_id] ~= nil
end

function hostile_has_awacs(vehicle_id)
    return g_hostile_awacs[vehicle_id] ~= nil
end

function get_jammed_radar(vehicle_id)
    -- get the radar unit that vehicle_id is jamming
    return g_hostile_jamming[vehicle_id]
end

function get_spoofed_radar_contact(vehicle_id)
    -- if vehicle_id is jamming a radar, return a position of a ghost contact, else nil
    if hostile_has_jammer(vehicle_id) then
        local radar = get_jammed_radar(vehicle_id)
        if radar ~= nil then
            local unit = g_hostile_jammers[vehicle_id]
            local ghost = {}
            local vehicle_dir = unit:get_direction()
            local pos = unit:get_position_xz()
            -- position 10 sec ago
            ghost["x"] = pos:x() + vehicle_dir:x() * -900
            ghost["y"] = pos:y() + vehicle_dir:y() * -900

            return ghost
        end
    end
    return nil
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

MARKER_WPT_OFFSET = 80000

MASK_DRYDOCK_WPTX_FLAGS = 0x00000000FF

function find_team_drydock(team_id)
    local vehicle_count = update_get_map_vehicle_count()
    for i = 0, vehicle_count - 1, 1 do
        local vehicle = update_get_map_vehicle_by_index(i)
        if vehicle:get() then
            if vehicle:get_definition_index() == e_game_object_type.drydock then
                if vehicle:get_team() == team_id then
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
        return def == e_game_object_type.chassis_air_rotor_heavy
    end
    return false
end

function vehicle_has_cargo(vehicle)
    return vehicle:get_attached_vehicle_id(0) ~= 0
end


function get_nearest_friendly_airliftable_id(vehicle, max_range)
    if vehicle ~= nil and vehicle_can_airlift(vehicle) then
        -- petrel
        if not vehicle_has_cargo(vehicle) then
            -- empty
            local team = vehicle:get_team()
            local origin = vehicle:get_position_xz()
            local nearest_dist = 99999
            local nearest_id = -1
            local vehicle_count = update_get_map_vehicle_count()
            for i = 0, vehicle_count - 1, 1 do
                local unit = update_get_map_vehicle_by_index(i)
                if unit:get() then
                    if unit:get_team() == team then
                        if get_is_vehicle_airliftable(unit:get_definition_index()) then
                            local pos = unit:get_position_xz()
                            local range = vec2_dist(pos, origin)
                            if range < max_range and range < nearest_dist then
                                nearest_id = unit:get_id()
                                nearest_dist = range
                            end
                        end
                    end
                end
            end
            if nearest_id ~= -1 then
                return nearest_id, nearest_dist
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

function get_marker_waypoint(team_id, marker_id)
    local drydock = find_team_drydock(team_id)
    if drydock then
        local waypoint_count = drydock:get_waypoint_count()
        for i = 0, waypoint_count - 1, 1 do
            local waypoint = drydock:get_waypoint(i)
            if waypoint ~= nil then
                if waypoint_flag_isset(waypoint, F_DRYDOCK_WPTX_MARKER) then
                    local pos = waypoint:get_position_xz()
                    if math.floor(pos:y()) == marker_id then
                        return waypoint
                    end
                end
            end
        end
    end
    return nil
end

function add_marker_waypoint(team_id, marker_id)
    local current = get_marker_waypoint(team_id, marker_id)
    local drydock = find_team_drydock(team_id)

    if drydock == nil then
        return nil
    end

    if current == nil then
        -- add one
        local w_id = drydock:add_waypoint(F_DRYDOCK_WPTX_MARKER, marker_id)
        drydock:set_waypoint_altitude(w_id, 0)
        current = drydock:get_waypoint_by_id(w_id)
    end

    return current
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
    local marker = get_marker_waypoint(team_id, marker_id)
    if marker ~= nil then
        local drydock = find_team_drydock(team_id)
        local packed = pack_alt_xy(x, y)
        set_marker_pending(marker_id, packed)
        drydock:set_waypoint_altitude(marker:get_id(), packed)
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