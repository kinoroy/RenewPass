/* This script checks whether or not the authentication failed on Emily Carr University Federated Login
 
 This script requires no variables to be inserted before injection
 */

function checkForAuthError() {
    if (document.querySelector(".errors") == null) {
        return "success"
    } else {
        return "failure"
    }
}
checkForAuthError();
