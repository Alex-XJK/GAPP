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
      <el-button type="info" plain size="small" @click="dialogVisible = true">Create</el-button>
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
            <el-button v-on:click="toCreate()" class="confirm">Confirm</el-button>
          </span>
        </el-dialog>
        
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
// import CreateTask from 'create-task.vue'

// Vue.component("CreateTask", CreateTask);

Vue.use(ElementUI)

export default {
  // components: {
  //   CreateTask
  // },
  data() {
    return {
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
      },
      toCreate () {
      this.hideDialog()
      console.log("toCreate emitted")
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
            // alertCenter.add('danger', response.data.msg);
            console.log(response.data.msg)
          }
        }).catch((reason) => {
          // alertCenter.add('danger', `${reason}`);
          console.log(reason)
        }).finally(() => {
      });
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
    }
}
</script>

<style scoped>
.el-col {
  padding-top : 6px !important;
  padding-bottom : 6px !important;
}
</style>