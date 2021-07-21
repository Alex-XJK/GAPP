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
  <span v-if="value=='option1'">o1</span>
  <span v-if="value=='option2'">o2</span>
  <span v-if="value=='option3'">o3</span>
  <span v-if="value=='option4'">o4</span>
  <span v-if="value=='option5'">o5</span>
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
        options: [{
          value: 'option1',
          label: 'category1'
        }, {
          value: 'option2',
          label: 'category2'
        }, {
          value: 'option3',
          label: 'category3'
        }, {
          value: 'option4',
          label: 'category4'
        }, {
          value: 'option5',
          label: 'category5'
        }],
        value: ''
      }
    }
}
</script>
<style scoped>

</style>