#test suite execution - for run scheduled using cronjob
cd /home/fc/automation/AuQA
sudo pabot --pabotlib --processes 2 --outputdir Reports --variable environment:config37  -v groupname:General-test /home/fc/automation/AuQA/Testcases/basicHotAbsoluteGuardTest.robot /home/fc/automation/AuQA/Testcases/staleStatePrevention.robot
sudo pabot --pabotlib --processes 2 --outputdir Reports --variable environment:config37  -v groupname:Imputes-test /home/fc/automation/AuQA/Testcases/deadSensorGuardTest.robot /home/fc/automation/AuQA/Testcases/staleStatePrevention.robot
sudo pabot --pabotlib --processes 2 --outputdir Reports --variable environment:config37  -v groupname:General-test /home/fc/automation/AuQA/Testcases/hotGuardTest.robot  /home/fc/automation/AuQA/Testcases/staleStatePrevention.robot
