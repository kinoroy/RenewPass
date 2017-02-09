/* This script fills out the authentication form for FS VCC, VCC's authentication service
 Requires: - storedUsername: Example Student: 999999999
 - storedPassword: the VCC Student's password
 
 storedUsername and storedPassword are inserted at runtime
 (from the core data storage and keychain respectively) right before injecting the script into the webview
 */

document.querySelector("#ctl00_ContentPlaceHolder1_UsernameTextBox").value = "storedUsername";
document.querySelector("#ctl00_ContentPlaceHolder1_PasswordTextBox").value = "storedPassword";
document.querySelector("#ctl00_ContentPlaceHolder1_SubmitButton").click();
