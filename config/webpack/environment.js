const { environment } = require('@rails/webpacker')
const { VueLoaderPlugin } = require('vue-loader')
const vue = require('./loaders/vue')
const raw = require("./loaders/raw");
const webpack = require('webpack')

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.prepend('vue', vue)
environment.loaders.append("raw", raw);

environment.plugins.prepend(
    'Provide',
    new webpack.ProvidePlugin({
      jQuery: 'jquery',
    })
  )


module.exports = environment
