/* This script checks whether or not the UPASS renewal was successful
 
 It will return "failure" if either of the following are true:
 - The number of UPASSES before the renewal attempt is the same as after
 - There was an error on translink's servers
 It will return "success" if the upass was added
 
 This script requires PREV_NUM_UPASS to be injected at runtime
 */

function checkForRenewalError() {
    if (document.querySelectorAll(".status").length > PREV_NUM_UPASS) {
        return "success"
    } else {
        return "failure"
    }
}

checkForRenewalError();
