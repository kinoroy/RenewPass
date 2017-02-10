/* This script fills out the authentication form for BCIT's Compass Login
 Requires: - storedUsername: the BCIT ID (A00 NUMBER)
 - storedPassword: the BCIT ID password
 
 storedUsername and storedPassword are inserted at runtime
 (from the core data storage and keychain respectively) right before injecting the script into the webview
 */

document.querySelector("#username").value = "storedUsername";
document.querySelector("#password").value = "storedPassword";
document.querySelector("[value=LOGIN]").click()
