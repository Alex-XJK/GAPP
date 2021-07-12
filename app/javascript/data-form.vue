<template>
  <div class="table-content">
        <el-table
            :data="tableData"
            height="250"
            border
            stripe
            style="width: 100%">
            <el-table-column
                prop="dataType"
                label="Data Type"
                width="180">
            </el-table-column>
            <el-table-column
                prop="dataName"
                label="Data Name"
                width="180">
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
          dataType: 'type-1',
          dataName: 'name-1'
        }]
      }
    }
}
</script>
<style scoped>
</style>