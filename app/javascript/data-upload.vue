<template>
  <div>
    <!-- Styled -->
    <b-form-file
      placeholder="Choose a file..."
      drop-placeholder="Drop file here..."
      :multiple='true'
      v-model="files"
    ></b-form-file>
    <br>
    <b-btn @click="uploadFile" class="float-right mt-2">
      <i class="fa fa-location-arrow"></i> 
      Upload
    </b-btn>
    <div class="mt-3" v-for="file in files" :key="file.id">Selected file(s): {{ file ? file.name : '' }}</div>
  </div>
</template>

<script>
import Vue from 'vue'
import axios from 'axios';
import objectToFormData from 'object-to-formdata';
import AlertCenter from 'components/alert-center.vue';
import ElementUI from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'

Vue.use(ElementUI)

  export default {
    components: {
      AlertCenter
    },
    // inject: ['reload'],
    data() {
      return {
        id: window.gon.user_id,
        files: [],
      }
    },
    methods: {
      uploadFile() {
        axios.post(
          `/data-file-upload`,
        objectToFormData({
          "dataFiles": this.files,
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
            // this.reload()
            this.$message({
                type: 'success',
                message: 'Uploaded successfully!'
            })
          } else {
            console.log(response.data.msg)
          }
        }).catch((reason) => {
          console.log(reason)
        }).finally(() => {});
      }
    },
    created() {
      // console.log(window.gon.user_id)
    }
  }
</script>