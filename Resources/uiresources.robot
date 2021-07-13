*** Settings ***
Library    SeleniumLibrary
Variables    ../PageObjects/loginPage.py
Variables    ../Configurations/config.py
Variables    ./ResourceVariables/globalVariables.py
Variables    ../PageObjects/siteEditorHomePage.py
Variables    ../Inputs/basicHotAbsoluteGuardInputs.py
Variables   ../PageObjects/toolsConfigsPage.py

*** Variables ***
${url_cx}    ${url_cx}
*** Keywords ***
startBrowserAndAccessAIEngineCXWebUI
        #[Arguments]    ${url}    ${browser}    ${expectedTitle}
        open browser    ${url_cx}    ${browser}    options=add_argument("--disable-popup-blocking"); add_argument("--ignore-certificate-errors")
        maximize browser window
        set browser implicit wait    ${high_speed}
        log to console    Accessed AI Engine
verifyTitle
        title should be    ${page_title}
        log to console    Title verified---!
loginByEnteringUsernameAndPassword
    #[Arguments]    ${username}    ${password}
    log to console    Entering user name and password
    input text    ${uname}    ${ui_username}
    input text    ${upwd}    ${ui_password}
    capture page screenshot    ./Reports/Screenshots/inputUserNameAndPwd_1.png
    click element    ${login_button}
    wait until page contains element   ${banner}
    wait until element is enabled    ${tools_button}
    capture page screenshot    ./Reports/Screenshots/siteEditorHomePage_2.png
    log to console    Logged in succesfully
startBrowserAndLoginToAIEngine
    startBrowserAndAccessAIEngineCXWebUI
    loginByEnteringUsernameAndPassword
resetGroupPropertiesUsingLoadTemplateOptionWithOverwrite
    startBrowserAndLoginToAIEngine
    click element    ${tools_button}
    click element    ${configs_option_in_tools}
    sleep    ${load_time}
    wait until element is visible    ${load_template_in_config_popup}
    wait until element is enabled    ${load_template_in_config_popup}
    click element    ${load_template_in_config_popup}
    click element    ${template_dropbox_picker}
    click element    ${template_option}
    click element    ${temperature_scale_dropbox_picker}
    click element    ${temperature_scale_option}
    select checkbox    ${overwrite_checkbox}
    click element    ${apply_button_load_template}
    click element    ${save_button}
    sleep    ${high_speed}
    click element    ${close_button}
    wait until element is not visible    ${close_button}
    close browser