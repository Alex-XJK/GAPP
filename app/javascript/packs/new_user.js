console.log("New User Page");

$(document).ready(function() {
   let form = document.querySelector("#new_user");
   form.onsubmit = onSub;
});

function onSub() {
    let uname = document.querySelector("#user_username");
    let upass = document.querySelector("#user_password_digest");
    let urole = document.querySelector("#user_role_id");
    uname.style.backgroundColor = "";
    upass.style.backgroundColor = "";
    urole.style.backgroundColor = "";

    let valid = true;
    if (String(uname.value).trim().length < 2) {
        let warning = document.createElement('span');
        warning.innerHTML = "Username should have at least 2 words.";
        warning.className = "badge badge-pill badge-danger";
        warning.id = "warning1";
        if (uname.parentNode.childElementCount == 1) {
            uname.parentNode.appendChild(warning);
        }
        document.querySelector("#user_username").style.backgroundColor = "pink";
        valid = false;
    }
    else if (uname.parentNode.childElementCount == 2) {
        document.querySelector("#warning1").remove();
    }

    if (String(upass.value).trim().length < 5) {
        let warning = document.createElement('span');
        warning.innerHTML = "Length of password should be at least 5.";
        warning.className = "badge badge-pill badge-danger";
        warning.id = "warning2";
        if (upass.parentNode.childElementCount == 1) {
            upass.parentNode.appendChild(warning);
        }
        document.querySelector("#user_password_digest").style.backgroundColor = "pink";
        valid = false;
    }
    else if (upass.parentNode.childElementCount == 2) {
        document.querySelector("#warning2").remove();
    }


    if (String(urole.value).trim() == "") {
        let warning = document.createElement('span');
        warning.innerHTML = "Please select a role.";
        warning.className = "badge badge-pill badge-danger";
        warning.id = "warning3";
        if (urole.parentNode.childElementCount == 1) {
            urole.parentNode.appendChild(warning);
        }
        document.querySelector("#user_role_id").style.backgroundColor = "pink";
        valid = false;
    }
    else if (urole.parentNode.childElementCount == 2) {
        document.querySelector("#warning3").remove();
    }

    return valid;
}