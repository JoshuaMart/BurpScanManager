# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

password = SecureRandom.hex(10)
User.create(email: 'admin@admin.tld', username: 'admin', password: password)

puts "[>] User '\e[0;32madmin\e[0m' was created with password '\e[0;32m#{password}\e[0m'.\e[0m\n"

Setting.create(name: 'Slack WebHook', value: '')
Setting.create(name: 'Burp API URL', value: '')
Setting.create(name: 'Burp API Token', value: '')
Setting.create(name: 'Burp Crawl Configuration Name', value: '')
Setting.create(name: 'Burp Audit Configuration Name', value: '')