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



