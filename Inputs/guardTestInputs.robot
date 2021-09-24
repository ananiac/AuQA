*** Settings ***
Library    Collections
Library    SeleniumLibrary
Library    ${EXECDIR}/ExternalKeywords/readExcel.py


*** Variables ***
&{guard_switch}  guard_on=GUARD_ON    guard_off=GUARD_OFF


*** Keywords ***
readInputsForBasiHcotAbsoluteGuard
    &{basicHotAbsoluteGuard}  readBasicHotAbsoluteGuardInputsFromExcel
    log to console  ${basicHotAbsoluteGuard}
    &{basicHotAbsoluteGuardInputs}  set variable    ${basicHotAbsoluteGuard}
    Set Global Variable   ${basicHotAbsoluteGuardInputs}

