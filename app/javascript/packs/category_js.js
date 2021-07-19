console.log('Hello from category_js.js');

var buttons;

$(document).ready(function() {
    console.log('Loaded.');
    let ss = document.querySelectorAll(".submit");
    console.log(ss);
    for (let i of ss) {
        i.style.display = "none";
        i.onclick = toSub;
    }

    buttons = document.querySelectorAll(".edit");
    for (let i of buttons) {
        i.onclick = edit;
    }

    document.querySelector("#fmain").style.display = "none";
    document.querySelector("#intro").onclick = addHelper;
    document.querySelector("#asub").onclick = toSubAdd;
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

function addHelper() {
    document.querySelector("#fmain").style.display = "block";
    this.style.display = "none";
}

function toSubAdd() {
    document.querySelector("#intro").style.display = "block";
    document.querySelector("#fmain").style.display = "none";
    document.querySelector("#fmain").querySelector("input[type=hidden]").value = document.querySelector("#nm").value;
    document.querySelector("#nm").value = "";
}