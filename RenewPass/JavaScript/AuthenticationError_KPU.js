/* This script checks whether or not the authentication failed on KPU's Network Login
 
 This script requires no variables to be inserted before injection
 */

function checkForAuthError() {
    if (document.querySelector(".bs-callout") == null) {
        return "success"
    } else {
        return "failure"
    }
}
checkForAuthError();
