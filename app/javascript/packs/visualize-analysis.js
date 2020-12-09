import Vue from "vue"
import VApp from "vapp.vue"
import ColorPicker from "page/builtin/color-picker.vue";
import SectionFiles from "page/builtin/section-files.vue";


Vue.component("color-picker", ColorPicker);
Vue.component("section-files", SectionFiles);

//useVue({vapp: VApp})

function initVApp() { 
    if(document.getElementById("vapp")) {
        console.log("vapp rendered");
        const vapp = new Vue({
            el: document.getElementById("vapp"),
            render: h=> h(VApp)
        });
    }
}

document.addEventListener("turbolinks:load",initVApp);
document.addEventListener("DOMContentLoaded", initVApp);
