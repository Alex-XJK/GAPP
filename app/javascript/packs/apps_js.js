console.log('Hello from apps_js.js');
let warning;

$(document).ready(function() {
    console.log('Loaded.');
    let form = document.querySelector("#searchapp");
    form.onsubmit = onSub;
    warning = document.querySelector("#warning");
    warning.style.display = "none";
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