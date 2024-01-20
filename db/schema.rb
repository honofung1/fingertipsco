# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_01_19_092554) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_users", force: :cascade do |t|
    t.string "username", null: false
    t.string "name", null: false
    t.string "crypted_password"
    t.string "salt"
    t.integer "role", default: 0
    t.string "email"
    t.string "reset_password_token"
    t.string "reset_password_token_expires_at"
    t.string "datetime"
    t.string "reset_password_email_sent_at"
    t.integer "access_count_to_reset_password_page", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token"
    t.index ["username"], name: "index_admin_users_on_username", unique: true
  end

  create_table "deposit_records", force: :cascade do |t|
    t.integer "order_owner_id", null: false
    t.integer "deposit_amount", null: false
    t.datetime "deposit_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_owner_accounts", force: :cascade do |t|
    t.integer "order_owner_id", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_order_owner_accounts_on_email", unique: true
    t.index ["reset_password_token"], name: "index_order_owner_accounts_on_reset_password_token", unique: true
  end

  create_table "order_owners", force: :cascade do |t|
    t.string "name", null: false
    t.string "order_code_prefix", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order_total_count", default: 0
    t.string "addresses"
    t.string "telephone"
    t.integer "balance", default: 0, null: false
    t.integer "handling_fee"
    t.integer "minimum_consumption_amount"
    t.integer "minimum_handling_fee"
    t.integer "maximum_consumption_amount"
    t.integer "maximum_handling_fee"
    t.boolean "enable_minimum_consumption"
    t.boolean "enable_maximum_consumption"
    t.integer "balance_limit"
  end

  create_table "order_payments", force: :cascade do |t|
    t.integer "order_id", null: false
    t.string "payment_method"
    t.integer "paid_amount"
    t.datetime "paid_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_payments_on_order_id"
  end

  create_table "order_products", force: :cascade do |t|
    t.integer "order_id", null: false
    t.string "shop_from"
    t.string "product_name"
    t.text "product_remark"
    t.integer "product_quantity"
    t.integer "product_price"
    t.string "receive_number"
    t.string "hk_tracking_number"
    t.string "tracking_number"
    t.datetime "ship_date"
    t.integer "product_cost"
    t.integer "shipment_cost"
    t.integer "discount"
    t.integer "total_cost"
    t.datetime "receipt_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "received"
    t.integer "tax_type"
    t.index ["hk_tracking_number"], name: "index_order_products_on_hk_tracking_number"
    t.index ["order_id"], name: "index_order_products_on_order_id"
    t.index ["ship_date"], name: "index_order_products_on_ship_date"
  end

  create_table "orders", force: :cascade do |t|
    t.string "order_id"
    t.integer "order_owner_id", null: false
    t.string "customer_name"
    t.string "customer_contact"
    t.string "customer_address"
    t.integer "state", default: 0
    t.integer "total_price"
    t.datetime "order_created_at"
    t.datetime "order_finished_at"
    t.boolean "ready_to_ship", default: false
    t.string "pickup_way"
    t.text "remark"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "currency"
    t.string "receive_number"
    t.string "hk_tracking_number"
    t.string "tracking_number"
    t.datetime "ship_date"
    t.integer "additional_fee"
    t.string "additional_fee_type"
    t.integer "additional_amount"
    t.integer "handling_amount"
    t.string "order_type"
    t.index ["currency"], name: "index_orders_on_currency"
    t.index ["order_created_at", "order_finished_at"], name: "index_orders_on_created_finished"
    t.index ["order_id"], name: "index_orders_on_order_id", unique: true
    t.index ["order_owner_id"], name: "index_orders_on_order_owner_id"
    t.index ["state"], name: "index_orders_on_state"
  end

  create_table "report_export_tasks", force: :cascade do |t|
    t.string "report_name"
    t.integer "created_by_id"
  end

  create_table "system_settings", force: :cascade do |t|
    t.string "name"
    t.string "value"
    t.string "value_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", limit: 191, null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

end
