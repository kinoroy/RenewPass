/* This script fills out the authentication form for CWL, UBC's authentication service
 Requires: - storedUsername: the UBC users's username
 - storedPassword: the UBC user's password
 
 storedUsername and storedPassword are inserted at runtime
 (from the core data storage and keychain respectively) right before injecting the script into the webview
 */

var form = document.querySelector("[name=loginForm]");
form.querySelector("#username").value = "storedUsername";
form.querySelector("#password").value = "storedPassword";
form.submit();
