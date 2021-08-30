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

    <div class="clear"></div>
    <b-btn class="mt-2 float-right" @click="showDialog(app)">
      <i class="far fa-edit"></i>
      Create
    </b-btn>
    <div class="clear"></div>

    <div class="task-card">
      <el-row :gutter="12">
        <div  v-for="task in tasks" :key="task.id">
          <div v-if="task.app_id === app.Id">
            <el-col :span="5">
              <el-card shadow="hover">
                <p>{{task.name}}</p>
                <el-progress :percentage="task.status" :status="task.barType"></el-progress>
                <el-button type="text" @click="goTo(task.id)">More</el-button>
              </el-card>
            </el-col>
          </div>
        </div>
      </el-row>
    </div>
  </div>

  <el-dialog
      style="text-align: center"
      :title="'Create New Task for '+ currentApp.name"
      :visible.sync="dialogVisible"
      :show-close=false
      :close-on-click-modal="false"
      width="50%">
    <el-form :model="ruleForm" :rules="rules" ref="ruleForm" label-width="100px">
      <el-form-item label="Select Data" :label-width="formLabelWidth">
        <el-checkbox :indeterminate="ruleForm.isIndeterminate" v-model="ruleForm.checkAll" @change="handleCheckAllChange">All</el-checkbox>
        <div style="margin: 15px 0;"></div>
        <el-checkbox-group v-model="ruleForm.checkedData" @change="handleCheckedDataChange">
          <el-checkbox v-for="datum in ruleForm.data" :label="datum" :key="datum.id">{{datum.name}}</el-checkbox>
        </el-checkbox-group>
      </el-form-item>
      <el-form-item label="Task Name" :label-width="formLabelWidth" prop="taskName">
        <el-input v-model="ruleForm.taskName" placeholder="Please input your task name"></el-input>
      </el-form-item>
    </el-form>
    <span slot="footer" class="dialog-footer">
      <el-button v-on:click="cancelCreate()" class="cancel">Cancel</el-button>
      <el-button v-on:click="toCreate(currentApp.Id)" class="confirm">Confirm</el-button>
    </span>
  </el-dialog>

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
      ruleForm: {
          checkAll: false,
          checkedData: [],
          data: [],
          isIndeterminate: true,
          taskName: ''
      },
      rules: {
        taskName: [
          { required: true, message: 'Task name cannot be empty!' },
          { min: 3, max: 5, message: 'Length should be between 3 and 5 characters.', trigger: 'blur' }
        ]
      },
      currentApp: {}
    }
  },
    methods: {
      hideDialog () {
      this.dialogVisible = false
      },
      showDialog(app) {
        this.currentApp = app
        this.dialogVisible = true
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
        this.$refs.ruleForm.validate((valid) => {
          if (valid) {
            this.hideDialog()
            this.SubmitTask(appId)
            this.resetForm()
            console.log("toCreate emitted and appid "+appId)
          } else {
            this.resetForm()
            return false
          }
        });
    },
    cancelCreate () {
      this.resetForm()
      this.hideDialog()
    },
    resetForm () {
      this.$refs.ruleForm.resetFields()
    },
    handleCheckAllChange(val) {
      this.ruleForm.checkedData = val ? this.ruleForm.data : []
      this.ruleForm.isIndeterminate = false;
    },
    handleCheckedDataChange(value) {
      let checkedCount = value.length
      this.ruleForm.checkAll = checkedCount === this.ruleForm.data.length
      this.ruleForm.isIndeterminate = checkedCount > 0 && checkedCount < this.ruleForm.data.length
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
            this.ruleForm.data = response.data.data
            console.log(this.ruleForm.data)
          } else {
            console.log(response.data.msg)
          }
        }).catch((reason) => {
          console.log(reason)
        }).finally(() => {
      });
    },
    SubmitTask(appId) {
      console.log("here is appid for task " + appId)
      axios.post(
          `/submit/api`,
        objectToFormData({
          "app": appId,
          "uid": this.id,
          "fid": this.ruleForm.checkedData.dataId
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
            var info = {
              'appId': appId,
              'taskId': response.data.data.task_id
            }
            this.CreateTask(info)
          } else {
            this.$message({
              type: 'error',
              message: response.data.data
            })
          }
        }).catch((reason) => {
          console.log(reason)
        }).finally(() => {});
    },
    CreateTask(info) {
      console.log("at create task")
      axios.post(
          `/create-task`,
        objectToFormData({
          "taskName": this.ruleForm.taskName,
          "app_id": info.appId,
          "user_id": this.id,
          "task_id": info.taskId,
          // "usedData": this.ruleForm.checkedData
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
            this.$message({
                type: 'success',
                message: 'Created successfully!'
            })
          } else {
            this.$message({
              type: 'error',
              message: 'Fail to create!'
            })
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
.clear {
  clear: both;
}
</style>