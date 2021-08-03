<template>
  <div class="block">
    <h5>Progress Bar</h5>
    <el-progress :percentage="percentage" type="circle" :color="colors"
    style="align-self: center"></el-progress>
    <el-divider></el-divider>
    <p>
      Here should be some detailed info related to the current task. 
      Here should be some detailed info related to the current task.
      Here should be some detailed info related to the current task.
    </p>
  </div>
</template>

<script>
import Vue from 'vue'
import ElementUI from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'
import axios from 'axios'
import objectToFormData from 'object-to-formdata'

Vue.use(ElementUI)

export default {
  data() {
    return {
      task_id: window.gon.task_id,
      percentage: 0,
      colors: [
        {color: '#f56c6c', percentage: 20},
        {color: '#e6a23c', percentage: 40},
        {color: '#5cb87a', percentage: 60},
        {color: '#1989fa', percentage: 80},
        {color: '#6f7ad3', percentage: 100}
      ]
    }
  },
  methods: {
    getStatus() {
    axios.post(
      `task-status`,
      objectToFormData({
          "task_id": this.task_id
      }),
      {
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': document.head.querySelector('meta[name="csrf-token"]').content,
          'Content-Type': 'multipart/form-data',
        },
      }).then((response) => {
          if (response.data.code) {
            this.percentage = response.data.data
            console.log(this.percentage)
          } else {
            console.log(response.data.msg)
          }
        }).catch((reason) => {
          console.log(reason)
        }).finally(() => {});
    }
  },
  created() {
      this.getStatus()
  }
}
</script>
<style scoped>

</style>