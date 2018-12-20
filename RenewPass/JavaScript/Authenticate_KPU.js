/* This script fills out the authentication form for KPU Network Login, KPU's authentication service
 Requires: - storedUsername: the KPU users's username
 - storedPassword: the KPU user's password
 
 storedUsername and storedPassword are inserted at runtime
 (from the core data storage and keychain respectively) right before injecting the script into the webview
 */

var form = document.querySelector("form");
document.querySelector("#username").value = "storedUsername";
document.querySelector("#password").value = "storedPassword";
document.createElement("form").submit.call(form);
