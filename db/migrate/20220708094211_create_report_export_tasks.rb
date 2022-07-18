class CreateReportExportTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :report_export_tasks do |t|
      t.string :report_name
      t.integer :created_by_id
    end
  end
end
