class CreateVulnerabilities < ActiveRecord::Migration[7.1]
  def change
    create_table :vulnerabilities do |t|
      t.string :name
      t.string :url
      t.text :description
      t.text :payload
      t.string :severity
      t.string :status, default: 'new'

      t.timestamps
    end
  end
end
