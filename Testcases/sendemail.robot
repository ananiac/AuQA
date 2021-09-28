*** Settings ***
Library           SmtpLibrary
Library           ImapLibrary
Library           String


*** Test Cases ***
Send mail
    Prepare Connection    172.17.1.70 25
    Set From    auqa@vigilent.com
    Add To Recipient    auqa@vigilent.com
    ${orig_body}=    Set Variable    This is a test
    Set Body    ${orig_body}
    Send Message
    Quit
    Close Connection

