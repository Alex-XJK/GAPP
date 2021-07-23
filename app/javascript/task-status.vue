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
  <br>
    <div v-for="app in apps" :key="app.id">
    <el-divider></el-divider>
      <h5><i>{{app.name}}</i></h5>
      <div class="task-card">
        <el-row :gutter="12">
          <div  v-for="task in tasks" :key="task.id">
            <div v-if="task.app_id === app.id">
              <el-col :span="4">
                <el-card shadow="hover">
                  <p>{{task.name}}</p>
                  <el-progress :percentage="task.status"></el-progress>
              </el-card>
            </el-col>
          </div>
        </div>
      </el-row>
    </div>
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
        id: window.gon.user_id,
        apps: [],
        tasks: []
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
      getApps(cate) {
        console.log('should fetch apps & tasks of' + cate)
        axios.post(
          `/apps-info`,
        objectToFormData({
          "cate": cate
        }),
        {
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': document.head.querySelector('meta[name="csrf-token"]').content,
            'Content-Type': 'multipart/form-data',
          },
        },
        ).then((response) => {
          if (response.data.code) {
            this.apps = response.data.data
            console.log(this.apps)
          } else {
            // alertCenter.add('danger', response.data.msg);
            console.log(response.data.msg)
          }
        }).catch((reason) => {
          // alertCenter.add('danger', `${reason}`);
          console.log(reason)
        }).finally(() => {});
      },
      getTasks() {
        axios.post(
          `/users/${this.id}/tasks/tasks-info`,
        objectToFormData({
          "id": this.id,
          "apps": this.apps
        }),
        {
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': document.head.querySelector('meta[name="csrf-token"]').content,
            'Content-Type': 'multipart/form-data',
          },
        },
        ).then((response) => {
          if (response.data.code) {
            this.tasks = response.data.data
            console.log(this.tasks)
          } else {
            // alertCenter.add('danger', response.data.msg);
            console.log(response.data.msg)
          }
        }).catch((reason) => {
          // alertCenter.add('danger', `${reason}`);
          console.log(reason)
        }).finally(() => {});
      }
    },
    watch: {
      'value': {
        immediate: true,
        handler (NewValue) {
          if(NewValue != '' && NewValue != null) {
            this.getApps(NewValue)
          }
        }
      },
      'apps': {
        immediate: true,
        handler (NewValue) {
          if(NewValue != []) {
            this.getTasks()
          }
        }
      },
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