/* The following script selects a school from the drop down menu on https://upassbc.translink.ca and presses submit
Requires: _SCHOOL_ID_ , which is the ordinal number 1-10 of the school in the drop down menu
(ex: SFU is 9th on the list, so its _SCHOOL_ID_ is 9)
 
 _SCHOOL_ID_ is inserted at runtime right before injecting the script into the webview
*/

document.querySelector("form").querySelector("#PsiId").options[_SCHOOL_ID_].selected = true;
document.querySelector("form").submit();
