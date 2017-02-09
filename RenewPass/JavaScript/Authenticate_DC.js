/* This script fills out the authentication form for Centralized Login, DC's authentication service
 Requires: - storedUsername: the College Network Account (CNA) ID
 - storedPassword: the College Network Account (CNA) password
 
 storedUsername and storedPassword are inserted at runtime
 (from the core data storage and keychain respectively) right before injecting the script into the webview
 */

document.querySelector("#ctl00_ContentPlaceHolder1_UsernameTextBox").value = "storedUsername";
document.querySelector("#ctl00_ContentPlaceHolder1_PasswordTextBox").value = "storedPassword";
document.querySelector("#ctl00_ContentPlaceHolder1_SubmitButton").click();
