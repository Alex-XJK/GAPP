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
      <h5 @click="gotoApp(app.Id)" id="appTitle"><i>{{app.name}}</i></h5>
      <b-btn class="mt-2" @click="dialogVisible = true">
        <i class="far fa-edit"></i>
        Create
      </b-btn>
        <el-dialog
          style="text-align: center"
          :title="'Create New Task for '+ app.name"
          :visible.sync="dialogVisible"
          :show-close=false
          :close-on-click-modal="false"
          width="50%">
          <el-form :model="form"  label-width="100px">
            <el-form-item label="Select Data" :label-width="formLabelWidth">
              <el-checkbox :indeterminate="form.isIndeterminate" v-model="form.checkAll" @change="handleCheckAllChange">All</el-checkbox>
              <div style="margin: 15px 0;"></div>
              <el-checkbox-group v-model="form.checkedData" @change="handleCheckedDataChange">
                <el-checkbox v-for="datum in form.data" :label="datum" :key="datum.id">{{datum.name}}</el-checkbox>
              </el-checkbox-group>
            </el-form-item>
            <el-form-item label="Task Name" :label-width="formLabelWidth">
              <el-input v-model="form.taskName" placeholder="Please input your task name"></el-input>
            </el-form-item>
          </el-form>
          <span slot="footer" class="dialog-footer">
            <el-button v-on:click="cancelCreate()" class="cancel">Cancel</el-button>
            <el-button v-on:click="toCreate(app.Id)" class="confirm">Confirm</el-button>
          </span>
        </el-dialog>
        
      <div class="task-card">
        <el-row :gutter="12">
          <div  v-for="task in tasks" :key="task.id">
            <div v-if="task.app_id === app.Id">
              <el-col :span="4">
                <el-card shadow="hover">
                  <p>{{task.name}}</p>
                  <el-progress :percentage="task.status"></el-progress>
                  <el-button type="text" @click="goTo(task.id)">More</el-button>
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
      url: '',
      dialogVisible: false,
      options: [],
      value: '',
      id: window.gon.user_id,
      apps: [],
      tasks: [],
      formLabelWidth: '120px',
      form: {
          checkAll: false,
          checkedData: [],
          data: [],
          isIndeterminate: true,
          taskName: ''
      }
    }
  },
    methods: {
      hideDialog () {
      this.dialogVisible = false
      },
      goTo(taskId) {
      axios.post(
          `/task-page`,
        objectToFormData({
          "taskId" : taskId
        }),
        {
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': document.head.querySelector('meta[name="csrf-token"]').content,
            'Content-Type': 'multipart/form-data',
          },
        }).then((response) => {
          this.url = response.data.toString().split('\"')[1]
          console.log(this.url)
        }).finally(() => {
          Turbolinks.visit(this.url, {"action":"replace"})
      });
      },
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
            console.log(response.data.msg)
          }
        }).catch((reason) => {
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
            console.log(response.data.msg)
          }
        }).catch((reason) => {
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
            console.log(response.data.msg)
          }
        }).catch((reason) => {
          console.log(reason)
        }).finally(() => {});
      },
      toCreate (appId) {
      this.hideDialog()
      this.CreateTask(appId)
      console.log("toCreate emitted and appid "+appId)
      this.resetForm()
    },
    cancelCreate () {
      this.resetForm()
      this.hideDialog()
    },
    resetForm () {
      this.form.checkAll = false
      this.form.checkedData = []
      this.form.isIndeterminate = true
      this.form.taskName = ''
    },
    handleCheckAllChange(val) {
      this.form.checkedData = val ? this.form.data : []
      this.form.isIndeterminate = false;
    },
    handleCheckedDataChange(value) {
      let checkedCount = value.length
      this.form.checkAll = checkedCount === this.form.data.length
      this.form.isIndeterminate = checkedCount > 0 && checkedCount < this.form.data.length
    },
    getDataInfo() {
      axios.post(
          `/data-file-info`,
        objectToFormData({
          "id": this.id
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
            this.form.data = response.data.data
            console.log(this.form.data)
          } else {
            console.log(response.data.msg)
          }
        }).catch((reason) => {
          console.log(reason)
        }).finally(() => {
      });
    },
    CreateTask(appId) {
      console.log("here is appid for task " + appId)
      axios.post(
          `/create-task`,
        objectToFormData({
          "taskName": this.form.taskName,
          "app_id": appId,
          "user_id": this.id,
          "usedData": this.form.checkedData
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
            // this.reload()
            this.$message({
                type: 'success',
                message: 'Created successfully!'
            })
          } else {
            console.log(response.data.msg)
          }
        }).catch((reason) => {
          console.log(reason)
        }).finally(() => {});
    },
    gotoApp(appId) {
      Turbolinks.visit(`/apps/${appId}`, {'action':'replace'})
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
      this.getCategoies(),
      this.getDataInfo()
    },
    computed: {

    }
}
</script>

<style scoped>
.el-col {
  padding-top : 6px !important;
  padding-bottom : 6px !important;
}
#appTitle {
  text-decoration:underline;
  color: #0066ff;
  cursor: pointer;
}
#appTitle :hover{
  color: #ccd7ff;
  cursor: pointer;
}
</style>