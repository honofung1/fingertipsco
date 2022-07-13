class CreateReportExportTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :report_export_tasks do |t|
      t.string :report_code
      t.string :to_email
      t.integer :created_by_id
    end
  end
end
