var form = document.querySelector("#form-request");

 function checkUpass() {
    if (form.querySelector("[type=checkbox]")==null) {
      return "null"
    } else {
      return "checkbox"
    }
}

checkUpass();
