console.log('Hello from apps_js.js');
let warning;

$(document).ready(function() {
    console.log('Loaded.');
    let form = document.querySelector("#searchapp");
    form.onsubmit = onSub;
    warning = document.querySelector("#warning");
    warning.style.display = "none";
    let form1 = document.querySelector("#hidef");
    form1.onsubmit = onHide;
    let form2 = document.querySelector("#passf");
    form2.onsubmit = onPass;
});

function onSub() {
    warning.style.display = "none";
    let text = document.querySelector("#text");
    text.style.backgroundColor = "";
    if (String(text.value).trim() == "") {
        warning.style.display = "inline-block";
        text.style.backgroundColor = "pink";
        return false;
    }
    return true;
}

function onHide() {
    let boxes = document.querySelectorAll(".onlinecheck");
    for (x of boxes) {
        if (x.checked) {
            return true;
        }
    }
    return false;
}

function onPass() {
    let boxes = document.querySelectorAll(".auditcheck");
    for (x of boxes) {
        if (x.checked) {
            return true;
        }
    }
    return false;
}