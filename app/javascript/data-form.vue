<template>
  <div class="table-content">
    <el-table
        :data="tableData"
        border
        stripe>
      <el-table-column
        prop="name"
        label="Name">
      </el-table-column>
      <el-table-column
        prop="uploadTime"
        label="Upload Time">
      </el-table-column>
      <el-table-column
        label="Actions" align="center">
        <template slot-scope="scope">
          <el-button type="info" icon="el-icon-edit" circle size="mini" @click="renameData(scope.$index)"></el-button>
          <el-button type="info" icon="el-icon-delete" circle size="mini" @click="deleteData(scope.$index)"></el-button>
        </template>
      </el-table-column>
    </el-table>
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
  // inject: ['reload'],
  data() {
    return {
      tableData: [],
      id: window.gon.user_id
    }
  },
  methods: {
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
            this.tableData = response.data.data
            console.log(this.tableData)
          } else {
            console.log(response.data.msg)
          }
        }).catch((reason) => {
          console.log(reason)
        }).finally(() => {
      });
    },
    deleteData(index) {
      // console.log(index)
      // console.log(this.tableData[index])
      // console.log(this.tableData[index].dataId)
      var dataId = this.tableData[index].dataId
      this.$confirm('This action will permanently delete the file, continue or not?', 'Notice', {
          confirmButtonText: 'Confirm',
          cancelButtonText: 'Cancel',
          type: 'warning'
        }).then(() => {
          axios.post(
          `/data-file-delete`,
          objectToFormData({
            "id": this.id,
            "dataId":dataId
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
                message: 'Deleted successfully!'
              })
              // this.reload()
            } else {
              // alertCenter.add('danger', response.data.msg);
              console.log(response.data.msg)
            }
          }).catch((reason) => {
            // alertCenter.add('danger', `${reason}`);
            console.log(reason)
          }).finally(() => {})
        }).catch(() => {
          this.$message({
            type: 'info',
            message: 'Delete cancelled'
          });          
        });
    },
    renameData(index) {
      var dataId = this.tableData[index].dataId
      this.$prompt('Please input a new name.', 'Notice', {
          confirmButtonText: 'Confirm',
          cancelButtonText: 'Cancel',
          inputPattern: /^(?!_)(?!.*?_$)[a-zA-Z0-9_\u4e00-\u9fa5]+$/,
          inputErrorMessage: 'The file name was incorrectly formed'
        }).then(({ value }) => {
          axios.post(
          `/data-file-rename`,
          objectToFormData({
            "id": this.id,
            "dataId":dataId,
            "newName": value
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
            message: 'New Name is: ' + value
          });
          // this.reload()
          } else {
              // alertCenter.add('danger', response.data.msg);
              console.log(response.data.msg)
            }
          }).catch((reason) => {
            // alertCenter.add('danger', `${reason}`);
            console.log(reason)
          }).finally(() => {})
        }).catch(() => {
          this.$message({
            type: 'info',
            message: 'Input cancelled'
          });       
        });
    }
  },
  created() {
    this.getDataInfo()
    console.log('done!')
  }
}
</script>
<style scoped>
</style>