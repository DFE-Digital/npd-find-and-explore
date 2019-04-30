const { environment } = require('@rails/webpacker')
const webpack = require('webpack')
// const vue =  require('./loaders/vue')

environment.plugins.append(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    'window.jQuery': 'jquery',
  })
)

// environment.loaders.append('vue', vue)
module.exports = environment
