/* This script checks whether or not the authentication failed on SFU's CAS
 
 This script requires no variables to be inserted before injection
 */

function checkForAuthError() {
    if (document.querySelector("#fm1").querySelector("#errorBox") == null) {
        return "success"
    } else {
        return "failure"
    }
}
checkForAuthError();
