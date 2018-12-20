/* This script checks whether or not the authentication failed on Langara College Federated Login
 
 This script requires no variables to be inserted before injection
 */

function checkForAuthError() {
    if (document.querySelector("#errorText").textContent == "") {
        /* The error message is visible */
        return "failure"
    } else {
        /* The error message has style "none" , i.e. non visible */
        return "success"
    }
}
checkForAuthError();
