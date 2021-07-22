<template>
<div>
  <el-select v-model="value" filterable clearable placeholder="Please select a category">
    <el-option
      v-for="item in options"
      :key="item.value"
      :label="item.label"
      :value="item.value">
    </el-option>
  </el-select>
  <div v-if="value=='option1'">o1</div>
  <div v-if="value=='option2'">o2</div>
  <div v-if="value=='option3'">o3</div>
  <div v-if="value=='option4'">o4</div>
  <div v-if="value=='option5'">o5</div>
  <br>
  <el-divider></el-divider>
  <h5>App-1</h5>
  <br>
  <div class="task-card">
    <el-row :gutter="12">
      <el-col :span="4">
        <el-card shadow="hover">
          <p>task-name</p>
          <el-progress :percentage="50"></el-progress>
        </el-card>
      </el-col>
      <el-col :span="4">
        <el-card shadow="hover">
          <p>task-name</p>
          <el-progress :percentage="50"></el-progress>
        </el-card>
      </el-col>
      <el-col :span="4">
        <el-card shadow="hover">
          <p>task-name</p>
          <el-progress :percentage="50"></el-progress>
        </el-card>
      </el-col>
      <el-col :span="4">
        <el-card shadow="hover">
          <p>task-name</p>
          <el-progress :percentage="50"></el-progress>
        </el-card>
      </el-col>
      <el-col :span="4">
        <el-card shadow="hover">
          <p>task-name</p>
          <el-progress :percentage="50"></el-progress>
        </el-card>
      </el-col>
      <el-col :span="4">
        <el-card shadow="hover">
          <p>task-name</p>
          <el-progress :percentage="50"></el-progress>
        </el-card>
      </el-col>
      <el-col :span="4">
        <el-card shadow="hover">
          <p>task-name</p>
          <el-progress :percentage="50"></el-progress>
        </el-card>
      </el-col>
      <el-col :span="4">
        <el-card shadow="hover">
          <p>task-name</p>
          <el-progress :percentage="50"></el-progress>
        </el-card>
      </el-col>
      <el-col :span="4">
        <el-card shadow="hover">
          <p>task-name</p>
          <el-progress :percentage="50"></el-progress>
        </el-card>
      </el-col>
    </el-row>
  </div>
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
        options: [],
        value: '',
        id: window.gon.user_id
      }
    },
    methods: {
      getCategoies() {
         axios.get(
          `/all-categories`,
        {
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': document.head.querySelector('meta[name="csrf-token"]').content,
            'Content-Type': 'multipart/form-data',
          },
        },
        ).then((response) => {
          if (response.data.code) {
            this.options = response.data.data
            console.log(this.options)
          } else {
            // alertCenter.add('danger', response.data.msg);
            console.log(response.data.msg)
          }
        }).catch((reason) => {
          // alertCenter.add('danger', `${reason}`);
          console.log(reason)
        }).finally(() => {
      });
      },
      getAppTask(cate) {
        console.log('should fetch apps & tasks of' + cate)
      }
    },
    watch: {
      'value': {
        immediate: true,
        handler (NewValue) {
          this.getAppTask(NewValue)
        }
      }
    },
    created() {
      this.getCategoies()
    }
}
</script>

<style scoped>
.el-col {
  padding-top : 6px !important;
  padding-bottom : 6px !important;
}
</style>