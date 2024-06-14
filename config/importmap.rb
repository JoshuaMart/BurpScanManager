# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin '@rails/ujs', to: 'https://cdn.skypack.dev/@rails/ujs'
pin_all_from 'app/javascript/controllers', under: 'controllers'

pin 'coreui', to: 'coreui/main.js'
