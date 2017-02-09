/* This script fills out the authentication form for Langara College Federated Login, LC's authentication service
 Requires: - storedUsername: Computer User ID @ langara.ca
 - storedPassword: the LC Student's password
 
 storedUsername and storedPassword are inserted at runtime
 (from the core data storage and keychain respectively) right before injecting the script into the webview
 */

document.querySelector("#userNameInput").value = "storedUsername";
document.querySelector("#passwordInput").value = "storedPassword";
document.querySelector("#loginForm").submit();
