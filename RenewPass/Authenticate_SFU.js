/* This script fills out the authentication form for CAS, SFU's authentication service
 Requires: - storedUsername: the SFU users's username
           - storedPassword: the SFU user's password
 
 storedUsername and storedPassword are inserted at runtime
 (from the core data storage and keychain respectively) right before injecting the script into the webview
*/

document.querySelector("#fm1");
document.querySelector("#username").value = "storedUsername";
document.querySelector("#password").value = "storedPassword";
document.querySelector("#fm1").submit();
