#Any nodes and fields related with a Group and its properties
trends_groupStatus_controlStatus_value_path="$.data.site.groups[0].children[0].children[0].pointCurrent.value"
racks_in_group="$.data.site.groups[0].racks"
ahu_control_targetStatus_value="$.data.site.groups[0].ahus[0].controls[0].targetStatus.origin"

ahus_list_path="$.data.site.groups[0].ahus"
ahu_control_status_origin_value_path="$.data.site.groups[0].ahus[0].controls[0].status.origin"
rat_dat_sensors="$.data.site.groups[0].sensors"

time_at_sensor_is_100F=""
increment_counter=1
current_ahus_in_guard=0
time_frequency_of_ahus_in_guard=3
no_of_ahus_to_be_in_guard=1
