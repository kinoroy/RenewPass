/* This script checks whether or not the authentication failed on FS VCC
 
 This script requires no variables to be inserted before injection
 */

function checkForAuthError() {
    if (document.querySelector(".TextColorError").innerText == "") {
        return "success"
    } else {
        return "failure"
    }
}
checkForAuthError();
