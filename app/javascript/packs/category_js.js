console.log('Hello from category_js.js');

var buttons;

$(document).ready(function() {
    console.log('Loaded.');
    let ss = document.querySelectorAll(".submit");
    console.log(ss);
    for (let i of ss) {
        i.style.display = "none";
    }

    buttons = document.querySelectorAll(".edit");
    for (let i of buttons) {
        i.onclick = edit;
    }

    buttons2 = document.querySelectorAll(".submit");

    for (let i of buttons2) {
        i.onclick = toSub;
    }
});

function edit() {
    let text = String(this.parentNode.parentNode.parentNode.querySelector(".name").innerHTML).trim();
    this.parentNode.parentNode.parentNode.querySelector(".name").innerHTML = "<input type='text' value='" + text + "' size='" + text.length +"'>";
    console.log(text.length);
    this.style = "display: none;";
    this.parentNode.querySelector(".submit").style = "";
}

function toSub() {
    this.style = "display: none;";
    this.parentNode.querySelector(".edit").style = "";
    let text = this.parentNode.parentNode.parentNode.querySelector("input[type=text]").value;
    console.log(text);
    this.parentNode.parentNode.parentNode.querySelector(".name").innerHTML = text;
    this.parentNode.querySelector(".target").value = text;
}