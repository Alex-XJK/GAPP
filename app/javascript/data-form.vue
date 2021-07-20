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
        <template>
          <el-button type="info" icon="el-icon-edit" circle></el-button>
          <el-button type="info" icon="el-icon-delete" circle></el-button>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script>
import Vue from 'vue'
import ElementUI from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'

Vue.use(ElementUI)

export default {
  data() {
    return {
      tableData: [{
        name: 'name-1',
        uploadTime: 'time-1'
      }]
    }
  },
  methods: {

  }
}
</script>
<style scoped>
</style>