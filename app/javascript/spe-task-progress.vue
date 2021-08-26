<template>
  <div class="block">
    <h5>Progress Bar</h5>
    <!-- <el-progress :percentage="percentage" type="circle" :color="colors"></el-progress> -->
    <br>
    <el-steps :active="active">
      <el-step title="Submitted" status="success"></el-step>
      <el-step title="Running" status="process "></el-step>
      <el-step :title="endTitle" :status="result"></el-step>
    </el-steps>
    <el-divider></el-divider>
    <h5>Progress Details</h5>
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
      result: "wait",
      endTitle: "Result",
      active: 1
      // percentage: 0,
      // colors: [
      //   {color: '#f56c6c', percentage: 20},
      //   {color: '#e6a23c', percentage: 40},
      //   {color: '#5cb87a', percentage: 60},
      //   {color: '#1989fa', percentage: 80},
      //   {color: '#6f7ad3', percentage: 100}
      // ]
    }
  },
  methods: {
    getStatus() {
    axios.post(
      `/query/api`,
      objectToFormData({
          "id": this.task_id //the id from db auto generating not the complex one
      }),
      {
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': document.head.querySelector('meta[name="csrf-token"]').content,
          'Content-Type': 'multipart/form-data',
        },
      }).then((response) => {
          if (response.data.code) {
            if (response.data.status == 'finished') {
              this.active = 2
              this.result = 'success'
              this.endTitle = 'Finished'
            } else if (response.data.status == 'failed') {
              this.active = 2
              this.result = 'error'
              this.endTitle = 'Failed'
            }
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