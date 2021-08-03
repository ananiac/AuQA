#Site Editor Web Elements
banner="css:#banner"
tools_button="xpath=//span[contains(text(),'Tools')]"
configs_option_in_tools="xpath=//span[contains(text(),'Configs')][1]"
load_template_in_config_popup="xpath=//span[contains(text(),'Load Template')]"
overwrite_checkbox="xpath=//div[13]/div[2]/div/div/div/div[1]/div/div/div[3]/div[1]/div/span/input"
template_dropbox_picker="xpath=//div[13]/div[2]/div/div/div/div[1]/div/div/div[1]/div[1]/div/div[2]"
template_option="xpath=//li[contains(text(),'DASHAM_MIX')]"
temperature_scale_option="xpath=//li[contains(text(),'Fahrenheit')]"
temperature_scale_dropbox_picker="xpath=//div[13]/div[2]/div/div/div/div[1]/div/div/div[2]/div[1]/div/div[2]"
temperature_scale_dropbox="xpath=//div[13]/div[2]/div/div/div/div[1]/div/div/div[2]/div[1]/div/div[1]/input"
apply_button_load_template="xpath=//span[contains(text(),'Apply')]"
save_button="xpath=//span[contains(text(),'Save')]"
close_button="xpath=//span[contains(text(),'Close')]"

# 2 Aug 2021 - Step 2 - Testcase 2 - SetProperties
# Git Branch - AUQA-14_Step2_Testcase2_SetProperties
# ControlDeadSensorThreshold
controlDeadSensorThresholdTxtBox="""xpath=//*[@id="gridview-1185-record-517"]/tbody/tr/td[2]/div"""
# AlarmDeadSensorHysteresis
alarmDeadSensorHysteresisTxtBox="""xpath=//*[@id="gridview-1185-record-510"]/tbody/tr/td[2]/div"""
# AlarmDeadSensorThreshold
alarmDeadSensorThresholdTxtBox="""xpath=//*[@id="gridview-1185-record-509"]/tbody/tr/td[2]/div"""