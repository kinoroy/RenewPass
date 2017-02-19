/* This script checks whether or not the user can renew their upass or not
 It will return "null" if either of the following are true:
    - The user already has the latest upass
    - The user does not qualify for upass
 It will return the number of UPasses already requested for the current year, if the user qualifies and can now renew their upass
 
 This script requires no variables to be inserted before injection
*/

var form = document.querySelector("#form-request");

 function checkUpass() {
    if (form.querySelector("[type=checkbox]")==null) {
        return "null"
    } else {
        return document.querySelectorAll(".status").length;
    }
}

checkUpass();
