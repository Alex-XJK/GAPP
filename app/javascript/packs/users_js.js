console.log("Hello!")

let w1 = "<select><option value='1' selected>admin</option><option value='2'>producer</option><option value='3'>user</option></select>";
let w2 = "<select><option value='1'>admin</option><option value='2' selected>producer</option><option value='3'>user</option></select>";
let w3 = "<select><option value='1'>admin</option><option value='2'>producer</option><option value='3' selected>user</option></select>";

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
    document.querySelector("#barea").innerHTML = '&nbsp; <a href="/admin/users/new"><button class="btn btn-primary" type="button"><i class="fas fa-user-plus"></i>New User</button></a> &nbsp; <a href="/accounts/invitation/new"><button class="btn btn-info" type="button"><i class="fas fa-envelope-open-text"></i>Invite User</button></a>';
});

function edit() {
    // console.log(this.parentNode.parentNode.parentNode);
    let text = String(this.parentNode.parentNode.parentNode.querySelector(".role_cell").innerHTML).trim();
    if (text === "admin") {
        this.parentNode.parentNode.parentNode.querySelector(".role_cell").innerHTML = w1
    }
    else if (text === "producer") {
        this.parentNode.parentNode.parentNode.querySelector(".role_cell").innerHTML = w2
    }
    else if (text === "user") {
        this.parentNode.parentNode.parentNode.querySelector(".role_cell").innerHTML = w3
    }
    // console.log(text.length);
    this.style = "display: none;";
    this.parentNode.querySelector(".submit").style = "";
}

function toSub() {
    this.style = "display: none;";
    this.parentNode.querySelector(".edit").style = "";
    let text = this.parentNode.parentNode.parentNode.querySelector("select").value;
    console.log(text);
    // this.parentNode.parentNode.parentNode.querySelector(".role_cell").innerHTML = text;
    this.parentNode.querySelector(".target").value = text;
    if (text == "1") {
        this.parentNode.parentNode.parentNode.querySelector(".role_cell").innerHTML = "admin";
    }
    else if (text == "2") {
        this.parentNode.parentNode.parentNode.querySelector(".role_cell").innerHTML = "producer";
    }
    else if (text == "3") {
        this.parentNode.parentNode.parentNode.querySelector(".role_cell").innerHTML = "user";
    }
}