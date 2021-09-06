# test suite for execution scheduled on thursday using cronjob
# Can be executed manually from AuQA folder using - sh thursdayexecutesuite.sh


##Used the below for Ubuntu machine
#cd /home/fc/automation/AuQA
#sudo pabot --pabotlib -d Reports/cleanReports --output cleanReports.xml --variable environment:config118  /home/fc/automation/AuQA/Testcases/cleanReports.robot
#sudo pabot --pabotlib --processes 2 --name "Guard1" --reporttitle "Basic Hot Absolute Guard" --outputdir Reports --output basichotGuard.xml --variable environment:config118  -v groupname:General-test -T /home/fc/automation/AuQA/Testcases/basicHotAbsoluteGuardTest.robot /home/fc/automation/AuQA/Testcases/staleStatePrevention.robot
#sudo pabot --pabotlib --processes 2 --name "Guard2" --reporttitle "Dead Sensor Guard" --outputdir Reports --output deadSensorGuard.xml --variable environment:config118  -v groupname:Imputes-test -T /home/fc/automation/AuQA/Testcases/deadSensorGuardTest.robot /home/fc/automation/AuQA/Testcases/staleStatePrevention.robot
#sudo pabot --pabotlib --processes 2 --name "Guard3" --reporttitle "Hot Guard" --outputdir Reports --output hotGuard.xml --variable environment:config118  -v groupname:General-test -T /home/fc/automation/AuQA/Testcases/hotGuardTest.robot  /home/fc/automation/AuQA/Testcases/staleStatePrevention.robot
#sudo rebot --name "GuardTest" --reporttitle "Test performed on environment 10.252.9.118 and Group - General-test" --outputdir Reports --output output.xml /home/fc/automation/AuQA/Reports/basichotGuard.xml /home/fc/automation/AuQA/Reports/deadSensorGuard.xml /home/fc/automation/AuQA/Reports/hotGuard.xml
#sudo pabot --pabotlib -d Reports/cleanReports --output moveReports.xml --variable environment:config118  /home/fc/automation/AuQA/Testcases/moveReports.robot


##Uncomment and use the below  for windows
cd E:/Ideavat/AutomatedQA/AuQA
pabot --pabotlib -d Reports/cleanReports --output cleanReports.xml --variable environment:config118  Testcases/cleanReports.robot
pabot --pabotlib --processes 2 --name "Guard1" --reporttitle "Basic Hot Absolute Guard" --outputdir Reports --output basichotGuard.xml --variable environment:config118  -v groupname:General-test -T Testcases/basicHotAbsoluteGuardTest.robot Testcases/staleStatePrevention.robot
pabot --pabotlib --processes 2 --name "Guard2" --reporttitle "Dead Sensor Guard" --outputdir Reports --output deadSensorGuard.xml --variable environment:config118  -v groupname:Imputes-test -T Testcases/deadSensorGuardTest.robot Testcases/staleStatePrevention.robot
pabot --pabotlib --processes 2 --name "Guard3" --reporttitle "Hot Guard" --outputdir Reports --output hotGuard.xml --variable environment:config118  -v groupname:General-test -T Testcases/hotGuardTest.robot  Testcases/staleStatePrevention.robot
rebot --name "GuardTest" --reporttitle "Test performed on environment 10.252.9.118 and Group - General-test" --outputdir Reports --output output.xml Reports/basichotGuard.xml Reports/deadSensorGuard.xml Reports/hotGuard.xml
pabot --pabotlib -d Reports/cleanReports --output moveReports.xml --variable environment:config118  Testcases/moveReports.robot
