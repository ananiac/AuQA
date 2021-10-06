# test suite for execution scheduled on tuesday using cronjob
# Can be executed manually from AuQA folder using - sh tuesdayexecutesuite.sh

full_path=$(realpath $0)
dir_path=$(dirname $full_path)
tc_path=$dir_path/Testcases
rp_path=$dir_path/Reports
se_path=$dir_path/ExternalKeywords

if [ `ps -ef | grep pabot | wc -l` -lt 2 ];  then
    echo "No automated tests are running so starting the test execution"
    cd $dir_path
    pabot --pabotlib -d Reports/cleanReports --output cleanReports.xml --variable environment:config37  $tc_path/cleanReports.robot
    pabot --pabotlib --processes 2 --name "Guard1_RSP-test_$(date +%F_%H:%M:%S)" --reporttitle "BasicHotAbsoluteGuard" --outputdir Reports --output basichotGuard.xml --variable environment:config37  -v groupname:RSP-test -T $tc_path/basicHotAbsoluteGuardTest.robot $tc_path/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- BasicHotAbsoluteGuard/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
    pabot --pabotlib --processes 2 --name "Guard2_Imputes-test_$(date +%F_%H:%M:%S)" --reporttitle "DeadSensorGuard" --outputdir Reports --output deadSensorGuard.xml --variable environment:config37  -v groupname:Imputes-test -T $tc_path/deadSensorGuardTest.robot $tc_path/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- DeadSensorGuard/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
    pabot --pabotlib --processes 2 --name "Guard3_General-test_$(date +%F_%H:%M:%S)" --reporttitle "HotGuard" --outputdir Reports --output hotGuard.xml --variable environment:config37  -v groupname:General-test -T $tc_path/hotGuardTest.robot  $tc_path/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- HotGuard/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
    pabot --pabotlib --processes 2 --name "Guard4_General-test_$(date +%F_%H:%M:%S)" --reporttitle "GuardOrderMIX" --outputdir Reports --output guardOrderMIX.xml --variable environment:config37  -v groupname:General-test -T $tc_path/guardOrderMIXTest.robot  $tc_path/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- GuardOrderMIX/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
    rebot  --name "GuardTest" --reporttitle "Test performed on environment 37" --outputdir Reports --output output.xml $rp_path/basichotGuard.xml $rp_path/deadSensorGuard.xml $rp_path/hotGuard.xml $rp_path/guardOrderMIX.xml 2>&1 | tee -a Reports/executionLog.txt
    pabot --pabotlib -d Reports/cleanReports --output moveReports.xml --variable environment:config37 $tc_path/moveReports.robot
    echo "sending the email"
    python3 $se_path/sendemail.py tuesdaysuite 2>&1 | tee -a Reports/executionLog.txt
    echo "Automated test execution completed"
  else
    echo "Automated test are running so the test execution is aborted"
 fi


#    ##Use the below command to execute the test individually in  Ubuntu machine
#    sudo pabot --pabotlib -d Reports/cleanReports --output cleanReports.xml --variable environment:config37  /home/fc/automation/AuQA/Testcases/cleanReports.robot
#    sudo pabot --pabotlib --processes 2 --name "Guard1_General-test_$(date +%F_%H:%M:%S)" --reporttitle "BasicHotAbsoluteGuard" --outputdir Reports --output basichotGuard.xml --variable environment:config37  -v groupname:General-test -T Testcases/basicHotAbsoluteGuardTest.robot Testcases/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- BasicHotAbsoluteGuard/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
#    sudo pabot --pabotlib --processes 2 --name "Guard2_Imputes-test_$(date +%F_%H:%M:%S)" --reporttitle "DeadSensorGuard" --outputdir Reports --output deadSensorGuard.xml --variable environment:config37  -v groupname:Imputes-test -T Testcases/deadSensorGuardTest.robot Testcases/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- DeadSensorGuard/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
#    sudo pabot --pabotlib --processes 2 --name "Guard3_General-test_$(date +%F_%H:%M:%S)" --reporttitle "HotGuard" --outputdir Reports --output hotGuard.xml --variable environment:config37  -v groupname:General-test -T Testcases/hotGuardTest.robot  Testcases/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- HotGuard/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
#    sudo pabot --pabotlib --processes 2 --name "Guard4_General-test_$(date +%F_%H:%M:%S)" --reporttitle "GuardOrderMIX" --outputdir Reports --output guardOrderMIX.xml --variable environment:config37  -v groupname:General-test -T Testcases/guardOrderMIXTest.robot  Testcases/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- GuardOrderMIX/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
#    sudo rebot  --name "GuardTest" --reporttitle "Test performed on environment 37" --outputdir Reports --output output.xml /home/fc/automation/AuQA/Reports/basichotGuard.xml /home/fc/automation/AuQA/Reports/deadSensorGuard.xml /home/fc/automation/AuQA/Reports/hotGuard.xml /home/fc/automation/AuQA/Reports/guardOrderMIX.xml 2>&1 | sudo tee -a Reports/executionLog.txt
#    sudo pabot --pabotlib -d Reports/cleanReports --output moveReports.xml --variable environment:config37 /home/fc/automation/AuQA/Testcases/moveReports.robot


##Uncomment and use the below  for windows machine
#cd E:/Ideavat/AutomatedQA/AuQA
#pabot --pabotlib -d Reports/cleanReports --output cleanReports.xml --variable environment:config37  Testcases/cleanReports.robot
#pabot --pabotlib --processes 2 --name "Guard1_General-test" --reporttitle "BasicHotAbsoluteGuard" --outputdir Reports --output basichotGuard.xml --variable environment:config37  -v groupname:General-test -T Testcases/basicHotAbsoluteGuardTest.robot Testcases/staleStatePrevention.robot
#pabot --pabotlib --processes 2 --name "Guard2_Imputes-test" --reporttitle "DeadSensorGuard" --outputdir Reports --output deadSensorGuard.xml --variable environment:config37  -v groupname:Imputes-test -T Testcases/deadSensorGuardTest.robot Testcases/staleStatePrevention.robot
#pabot --pabotlib --processes 2 --name "Guard3_General-test" --reporttitle "HotGuard" --outputdir Reports --output hotGuard.xml --variable environment:config37  -v groupname:General-test -T Testcases/hotGuardTest.robot  Testcases/staleStatePrevention.robot
#pabot --pabotlib --processes 2 --name "Guard4_General-test" --reporttitle "GuardOrderMIX" --outputdir Reports --output guardOrderMIX.xml --variable environment:config37  -v groupname:General-test -T Testcases/guardOrderMIXTest.robot  Testcases/staleStatePrevention.robot
#rebot  --name "GuardTest" --reporttitle "Test performed on environment 37" --outputdir Reports --output output.xml Reports/basichotGuard.xml Reports/deadSensorGuard.xml Reports/hotGuard.xml Reports/guardOrderMIX.xml
#pabot --pabotlib -d Reports/cleanReports --output moveReports.xml --variable environment:config37 Testcases/moveReports.robot