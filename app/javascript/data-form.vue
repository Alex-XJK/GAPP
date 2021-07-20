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
        label="Uploaded Time">
      </el-table-column>
      <el-table-column
        label="Actions" align="center">
        <template slot-scope="scope">
          <el-button type="info" icon="el-icon-edit" circle @click="renameData(scope.$index)"></el-button>
          <el-button type="info" icon="el-icon-delete" circle @click="deleteData(scope.$index)"></el-button>
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
      tableData: [{
        dataId: 'no-id',
        name: 'no-info',
        uploadTime: 'no-info'
      }],
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
            // alertCenter.add('danger', response.data.msg);
            console.log(response.data.msg)
          }
        }).catch((reason) => {
          // alertCenter.add('danger', `${reason}`);
          console.log(reason)
        }).finally(() => {
      });
    },
    deleteData(index) {
      // console.log(index)
      // console.log(this.tableData[index])
      // console.log(this.tableData[index].dataId)
      var dataId = this.tableData[index].dataId
      this.$confirm('此操作将永久删除该文件, 是否继续?', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
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
                message: '删除成功!'
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
            message: '已取消删除'
          });          
        });
    },
    renameData(index) {
      var dataId = this.tableData[index].dataId
      this.$prompt('请输入新名称', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消'
          // inputPattern: /[\w!#$%&'*+/=?^_`{|}~-]+(?:\.[\w!#$%&'*+/=?^_`{|}~-]+)*@(?:[\w](?:[\w-]*[\w])?\.)+[\w](?:[\w-]*[\w])?/,
          // inputErrorMessage: '邮箱格式不正确'
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
            message: '新名称: ' + value
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
            message: '取消输入'
          });       
        });
    }
  },
  mounted() {
    this.getDataInfo()
    console.log('done!')
  }
}
</script>
<style scoped>
</style>