/* This script fills out the authentication form for Emily Carr University Federated Login, EC's authentication service
 Requires: - storedUsername: Username (e.g. ecarr):
 - storedPassword: the EC Student's password
 
 storedUsername and storedPassword are inserted at runtime
 (from the core data storage and keychain respectively) right before injecting the script into the webview
 */

document.querySelector("#username").value = "storedUsername";
document.querySelector("#password").value = "storedPassword";
document.querySelector(".btn-submit").click();
