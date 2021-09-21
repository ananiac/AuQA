*** Settings ***
Library    Collections
Library    SeleniumLibrary


*** Variables ***
&{basicHotAbsoluteGuardInputs}  num_guard_units=1   num_minutes_guard_timer=3   percent_deadsensor_threshold=100
                                ...     num_minutes_past=5  allow_num_exceedences_control_initial=10    allow_num_exceedences_guard_initial=10
                                ...     alm_hot_abs_temp_initial=200    guard_hot_abs_temp_intial=90    allow_num_exceedences_control_default=0
                                ...     allow_num_exceedences_guard_default=1   alm_hot_abs_temp_default=90     guard_hot_abs_temp_default=90
                                ...     percent_deadsensor_threshold_default=30    sensor_point_cooling_temp=65.00     sensor_point_hot_temp=100
                                ...     expected_ahu_to_be_on=4

&{guard_switch}  guard_on=GUARD_ON    guard_off=GUARD_OFF

# guardOrderMIXInputs
&{guardOrderMIXInputs}  ahu_cac_10_value=80   ahu_cac_11_value=66  ahu_cac_12_value=100
                        ...     ahu_cac_13_value=50  ahu_cac_14_value=95    ahu_cac_15_value=90
                        ...     ahu_cac_16_value=60    ahu_cac_17_value=70  rack_temp=66
                        ...     high_set_point_limit=80.6   high_set_point_limit_cleanup=88
                        ...     low_set_point_limit=64.4    low_set_point_limit_cleanup=60
                        ...     config_num_guard_units_value1=1     config_num_minutes_guard_timer_value2=2
                        ...     config_system_num_minutes_past=20