/* This script checks whether or not the authentication failed on UBC's CWL
 
 This script requires no variables to be inserted before injection
 */

function checkForAuthError() {
    if (document.querySelector('.login_error') == null) {
        return "success"
    } else {
        return "failure"
    }
}
checkForAuthError();
