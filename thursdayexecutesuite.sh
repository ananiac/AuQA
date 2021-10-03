# test suite for execution scheduled on thursday using cronjob
# Can be executed manually from AuQA folder using - sh thursdayexecutesuite.sh
#path="E:/Ideavat/AutomatedQA/AuQA/Testcases" # /home/fc/automation/AuQA/Testcases

full_path=$(realpath $0)
echo $full_path

dir_path=$(dirname $full_path)
echo $dir_path

tc_path=$dir_path/Testcases
echo $tc_path

rp_path=$dir_path/Reports
echo $rp_path

if [ `ps -ef | grep pabot | wc -l` -lt 2 ];  then
    echo "No automated tests are running so starting the test execution"
    cd $dir_path
    pabot --pabotlib -d Reports/cleanReports --output cleanReports.xml --variable environment:config118  $tc_path/cleanReports.robot
    pabot --pabotlib --processes 2 --name "Guard1_General-test_$(date +%F_%H:%M:%S)" --reporttitle "BasicHotAbsoluteGuard" --outputdir Reports --output basichotGuard.xml --variable environment:config118  -v groupname:General-test -T $tc_path/basicHotAbsoluteGuardTest.robot $tc_path/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- BasicHotAbsoluteGuard/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
    pabot --pabotlib --processes 2 --name "Guard2_Imputes-test_$(date +%F_%H:%M:%S)" --reporttitle "DeadSensorGuard" --outputdir Reports --output deadSensorGuard.xml --variable environment:config118  -v groupname:Imputes-test -T $tc_path/deadSensorGuardTest.robot $tc_path/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- DeadSensorGuard/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
    pabot --pabotlib --processes 2 --name "Guard3_General-test_$(date +%F_%H:%M:%S)" --reporttitle "HotGuard" --outputdir Reports --output hotGuard.xml --variable environment:config118  -v groupname:General-test -T $tc_path/hotGuardTest.robot  $tc_path/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- HotGuard/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
    pabot --pabotlib --processes 2 --name "Guard4_General-test_$(date +%F_%H:%M:%S)" --reporttitle "GuardOrderMIX" --outputdir Reports --output guardOrderMIX.xml --variable environment:config118  -v groupname:General-test -T $tc_path/guardOrderMIXTest.robot  $tc_path/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- GuardOrderMIX/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
    rebot  --name "GuardTest" --reporttitle "Test performed on environment 118" --outputdir Reports --output output.xml $rp_path/basichotGuard.xml $rp_path/deadSensorGuard.xml $rp_path/hotGuard.xml $rp_path/guardOrderMIX.xml 2>&1 | sudo tee -a Reports/executionLog.txt
    pabot --pabotlib -d Reports/cleanReports --output moveReports.xml --variable environment:config118 $tc_path/moveReports.robot
    echo "Automated test execution completed"
  else
    echo "Automated test are running so the test execution is aborted"
 fi

#    ##Use the below command to execute the test individually in  Ubuntu machine
#    sudo pabot --pabotlib -d Reports/cleanReports --output cleanReports.xml --variable environment:config118  /home/fc/automation/AuQA/Testcases/cleanReports.robot
#    sudo pabot --pabotlib --processes 2 --name "Guard1_General-test_$(date +%F_%H:%M:%S)" --reporttitle "BasicHotAbsoluteGuard" --outputdir Reports --output basichotGuard.xml --variable environment:config118  -v groupname:General-test -T Testcases/basicHotAbsoluteGuardTest.robot Testcases/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- BasicHotAbsoluteGuard/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
#    sudo pabot --pabotlib --processes 2 --name "Guard2_Imputes-test_$(date +%F_%H:%M:%S)" --reporttitle "DeadSensorGuard" --outputdir Reports --output deadSensorGuard.xml --variable environment:config118  -v groupname:Imputes-test -T Testcases/deadSensorGuardTest.robot Testcases/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- DeadSensorGuard/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
#    sudo pabot --pabotlib --processes 2 --name "Guard3_General-test_$(date +%F_%H:%M:%S)" --reporttitle "HotGuard" --outputdir Reports --output hotGuard.xml --variable environment:config118  -v groupname:General-test -T Testcases/hotGuardTest.robot  Testcases/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- HotGuard/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
#    sudo pabot --pabotlib --processes 2 --name "Guard4_General-test_$(date +%F_%H:%M:%S)" --reporttitle "GuardOrderMIX" --outputdir Reports --output guardOrderMIX.xml --variable environment:config118  -v groupname:General-test -T Testcases/guardOrderMIXTest.robot  Testcases/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- GuardOrderMIX/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
#    sudo rebot  --name "GuardTest" --reporttitle "Test performed on environment 118" --outputdir Reports --output output.xml Reports/basichotGuard.xml Reports/deadSensorGuard.xml Reports/hotGuard.xml Reports/guardOrderMIX.xml 2>&1 | sudo tee -a Reports/executionLog.txt
#    sudo pabot --pabotlib -d Reports/cleanReports --output moveReports.xml --variable environment:config118 /home/fc/automation/AuQA/Testcases/moveReports.robot


##Uncomment and use the below  for windows
#cd E:/Ideavat/AutomatedQA/AuQA
#pabot --pabotlib -d Reports/cleanReports --output cleanReports.xml --variable environment:config118  Testcases/cleanReports.robot
#pabot --pabotlib --processes 2 --name "Guard1_General-test" --reporttitle "BasicHotAbsoluteGuard" --outputdir Reports --output basichotGuard.xml --variable environment:config118  -v groupname:General-test -T Testcases/basicHotAbsoluteGuardTest.robot Testcases/staleStatePrevention.robot
#pabot --pabotlib --processes 2 --name "Guard2_Imputes-test" --reporttitle "DeadSensorGuard" --outputdir Reports --output deadSensorGuard.xml --variable environment:config118  -v groupname:Imputes-test -T Testcases/deadSensorGuardTest.robot Testcases/staleStatePrevention.robot
#pabot --pabotlib --processes 2 --name "Guard3_General-test" --reporttitle "HotGuard" --outputdir Reports --output hotGuard.xml --variable environment:config118  -v groupname:General-test -T Testcases/hotGuardTest.robot  Testcases/staleStatePrevention.robot
#pabot --pabotlib --processes 2 --name "Guard4_General-test" --reporttitle "GuardOrderMIX" --outputdir Reports --output guardOrderMIX.xml --variable environment:config118  -v groupname:General-test -T Testcases/guardOrderMIXTest.robot  Testcases/staleStatePrevention.robot
#rebot --name "GuardTest" --reporttitle "Test performed on environment 118" --outputdir Reports --output output.xml Reports/basichotGuard.xml Reports/deadSensorGuard.xml Reports/hotGuard.xml Reports/guardOrderMIX.xml
#pabot --pabotlib -d Reports/cleanReports --output moveReports.xml --variable environment:config118 Testcases/moveReports.robot
