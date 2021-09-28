# test suite for execution scheduled on tuesday using cronjob
# Can be executed manually from AuQA folder using - sh wednesdayexecutesuite.sh

    ##Used the below for Ubuntu machine
if [ `ps -ef | grep pabot | wc -l` -lt 2 ];  then
    echo "No automated tests are running so starting the test execution"
    cd /home/fc/automation/AuQA
    sudo pabot --pabotlib -d Reports/cleanReports --output cleanReports.xml --variable environment:config37 /home/fc/automation/AuQA/Testcases/cleanReports.robot || echo $(date +%F_%H:%M:%S)- cleanReports failed >> Reports/executionLog.txt 2>&1
    sudo pabot --pabotlib --processes 2 --name "Guard1_RSP-test_37_$(date +%F_%H:%M:%S)" --reporttitle "BasicHotAbsoluteGuard" --outputdir Reports --output basichotGuard.xml --variable environment:config37  -v groupname:RSP-test -T /home/fc/automation/AuQA/Testcases/basicHotAbsoluteGuardTest.robot /home/fc/automation/AuQA/Testcases/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- BasicHotAbsoluteGuard/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
    sudo pabot --pabotlib --processes 2 --name "Guard2_Imputes-test_91_$(date +%F_%H:%M:%S)" --reporttitle "DeadSensorGuard" --outputdir Reports --output deadSensorGuard.xml --variable environment:config91  -v groupname:Imputes-test -T /home/fc/automation/AuQA/Testcases/deadSensorGuardTest.robot /home/fc/automation/AuQA/Testcases/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1  || echo $(date +%F_%H:%M:%S)- DeadSensorGuard/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
    sudo pabot --pabotlib --processes 2 --name "Guard3_General-test_118_$(date +%F_%H:%M:%S)" --reporttitle "HotGuard" --outputdir Reports --output hotGuard.xml --variable environment:config118  -v groupname:General-test -T /home/fc/automation/AuQA/Testcases/hotGuardTest.robot  /home/fc/automation/AuQA/Testcases/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- HotGuard/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
    sudo rebot  --name "GuardTest" --reporttitle "Test performed across different environment and different group" --outputdir Reports --output output.xml /home/fc/automation/AuQA/Reports/basichotGuard.xml /home/fc/automation/AuQA/Reports/deadSensorGuard.xml /home/fc/automation/AuQA/Reports/hotGuard.xml 2>&1 | sudo tee -a Reports/executionLog.txt
    sudo pabot --pabotlib -d Reports/cleanReports --output moveReports.xml --variable environment:config37 /home/fc/automation/AuQA/Testcases/moveReports.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- moveReports failed >> Reports/executionLog.txt 2>&1
    echo "Automated test execution completed"
  else
    echo "Automated test are running so the test execution is aborted"
 fi

##Uncomment and use the below  for windows
#cd E:/Ideavat/AutomatedQA/AuQA
#pabot --pabotlib -d Reports/cleanReports --output cleanReports.xml --variable environment:config37  Testcases/cleanReports.robot || echo $(date +%F_%H:%M:%S)- cleanReports failed >> Reports/executionLog.txt 2>&1
#pabot --pabotlib --processes 2 --name "Guard1_RSP-test_37_$(date +%F_%H:%M:%S)" --reporttitle "BasicHotAbsoluteGuard" --outputdir Reports --output basichotGuard.xml --variable environment:config37  -v groupname:RSP-test -T Testcases/basicHotAbsoluteGuardTest.robot Testcases/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- BasicHotAbsoluteGuard/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
#pabot --pabotlib --processes 2 --name "Guard2_Imputes-test_91_$(date +%F_%H:%M:%S)" --reporttitle "DeadSensorGuard" --outputdir Reports --output deadSensorGuard.xml --variable environment:config91  -v groupname:Imputes-test -T Testcases/deadSensorGuardTest.robot Testcases/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- DeadSensorGuard/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
#pabot --pabotlib --processes 2 --name "Guard3_General-test_118_$(date +%F_%H:%M:%S)" --reporttitle "HotGuard" --outputdir Reports --output hotGuard.xml --variable environment:config118  -v groupname:General-test -T Testcases/hotGuardTest.robot  Testcases/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- HotGuard/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
#rebot --name "GuardTest" --reporttitle "Test performed across different environment and different group" --outputdir Reports --output output.xml Reports/basichotGuard.xml Reports/deadSensorGuard.xml Reports/hotGuard.xml 2>&1 | tee -a Reports/executionLog.txt
#pabot --pabotlib -d Reports/cleanReports --output moveReports.xml --variable environment:config37 Testcases/moveReports.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- moveReports failed >> Reports/executionLog.txt 2>&1

