/* This script checks whether or not the authentication failed on BCIT's Compass Login
 
 This script requires no variables to be inserted before injection
 */

function checkForAuthError() {
    if (document.querySelector(".noticebox").querySelector("#errors") == null) {
        return "success"
    } else {
        return "failure"
    }
}
checkForAuthError();
