class CreateScanStatuses < ActiveRecord::Migration[7.1]
  def change
    create_table :scan_statuses do |t|
      t.string :url
      t.string :state

      t.timestamps
    end
  end
end
