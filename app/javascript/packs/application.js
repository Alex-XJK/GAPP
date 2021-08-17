import 'bootstrap';
import Vue from 'vue';
import $ from 'jquery';
import VJstree from 'vue-jstree';
import uploader from 'vue-simple-uploader';

window.jQuery = $;
window.gon = window.gon || {};

Vue.use(VJstree);
Vue.use(uploader);
const ALERT_TIMEOUT = 5000;

import JobSubmit from '../job-submit.vue';
import JobQuery from '../job-query.vue';
import JobSubmitPipeline from "../job-submit-pipeline.vue";
import StarApps from "../star-app-pagination.vue";
import DataForm from "../data-form.vue";
import DataUpload from "../data-upload.vue";
import TaskStatus from "../task-status.vue";
import SpeTaskProgress from "../spe-task-progress.vue";

document.addEventListener('DOMContentLoaded', (event) =>  {
    const vueLoadList = [
        ['#vapp-job-submit', JobSubmit],
        ['#vapp-job-query', JobQuery],
        ['#vapp-job-submit-pipeline', JobSubmitPipeline],
        ['#vapp-star-app-pagination', StarApps],
        ['#vapp-data-form', DataForm],
        ['#vapp-data-upload', DataUpload],
        ['#vapp-task-status', TaskStatus],
        ['#vapp-spe-task-progress', SpeTaskProgress]
    ];

    $('[data-toggle="tooltip"]').tooltip();



    $('#alerts .alert-group').each((i, el) => {
        const alertGroup = $(el);
        const bar = alertGroup.find('.progress-bar');

        alertGroup.find('.close').on('click', () => {
            alertGroup.slideUp(300);
        });

        bar.css('width', '100%');
        setTimeout(() => {
            alertGroup.slideUp(300);
        }, ALERT_TIMEOUT);
    });

    console.log("=====>");
    vueLoadList.forEach(([selector, component, props = {}]) => {
        const el = document.querySelector(selector);
        if (!el) return;
        const _ = new Vue({
            el,
            render: h => h(component, { props }),
        });
    });

    $('#alerts .alert-group').each((i, el) => {
        const alertGroup = $(el);
        const bar = alertGroup.find('.progress-bar');

        alertGroup.find('.close').on('click', () => {
            alertGroup.slideUp(300);
        });

        bar.css('width', '100%');
        setTimeout(() => {
            alertGroup.slideUp(300);
        }, ALERT_TIMEOUT);
    });

});

require('data-confirm-modal')