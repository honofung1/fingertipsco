# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_07_08_094211) do

  create_table "admin_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
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

  create_table "bidrecord", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.text "ItemID", limit: 16777215, null: false
    t.text "WebsiteNameEN", limit: 16777215, null: false
    t.text "Status", limit: 16777215, null: false
    t.text "Cost", limit: 16777215, null: false
    t.text "RepairCost", limit: 16777215, null: false
    t.text "PriceHKD", limit: 16777215, null: false
    t.text "PriceJPY", limit: 16777215, null: false
    t.text "PriceYahooRaku", limit: 16777215, null: false
    t.text "PriceeBay", limit: 16777215, null: false
    t.text "ReceivedDate", limit: 16777215, null: false
    t.text "SoldoutDate", limit: 16777215, null: false
    t.text "Purchaser", limit: 16777215, null: false
    t.text "Salesman", limit: 16777215, null: false
    t.text "User", limit: 16777215, null: false
    t.text "CompanyCustomer", limit: 16777215, null: false
    t.text "ReceiptNo", limit: 16777215, null: false
    t.text "TEL", limit: 16777215, null: false
    t.text "ProductType", limit: 16777215, null: false
    t.text "YahooRakuName", limit: 16777215, null: false
    t.text "eBayName", limit: 16777215, null: false
    t.text "WebsiteNameJP", limit: 16777215, null: false
    t.text "otherName", limit: 16777215, null: false
    t.text "Model", limit: 16777215, null: false
    t.text "BagColor", limit: 16777215, null: false
    t.text "Material", limit: 16777215, null: false
    t.text "HardwareColor", limit: 16777215, null: false
    t.text "SerialNumber", limit: 16777215, null: false
    t.text "CaseColor", limit: 16777215, null: false
    t.text "CaseMaterial", limit: 16777215, null: false
    t.text "BraceletMaterial", limit: 16777215, null: false
    t.text "RefNo", limit: 16777215, null: false
    t.text "Movement", limit: 16777215, null: false
    t.text "ProductType_Bag", limit: 16777215, null: false
    t.text "Brand_Bag", limit: 16777215, null: false
    t.text "ProductType_Watch", limit: 16777215, null: false
    t.text "Brand_Watch", limit: 16777215, null: false
    t.text "ProductType_SLG", limit: 16777215, null: false
    t.text "Brand_SLG", limit: 16777215, null: false
    t.text "ProductType_ACC", limit: 16777215, null: false
    t.text "Brand_ACC", limit: 16777215, null: false
    t.text "NoAccessories", limit: 16777215, null: false
    t.text "Box", limit: 16777215, null: false
    t.text "DustBag", limit: 16777215, null: false
    t.text "AuthenticCard", limit: 16777215, null: false
    t.text "Key_Accessories", limit: 16777215, null: false
    t.text "Lock_Accessories", limit: 16777215, null: false
    t.text "Seal", limit: 16777215, null: false
    t.text "Other", limit: 16777215, null: false
    t.text "OtherEN", limit: 16777215, null: false
    t.text "OtherJP", limit: 16777215, null: false
    t.text "OtherAccesoriesRemark_EN", limit: 16777215, null: false
    t.text "OtherAccesoriesRemark_JP", limit: 16777215, null: false
    t.text "Rank_BagInside", limit: 16777215, null: false
    t.text "Rank_BagOutside", limit: 16777215, null: false
    t.text "Rank_BagMatel", limit: 16777215, null: false
    t.text "Rank_BagCorner", limit: 16777215, null: false
    t.text "Rank_BagRemarkEN", limit: 16777215, null: false
    t.text "Rank_BagRemarkJP", limit: 16777215, null: false
    t.text "Rank_Case", limit: 16777215, null: false
    t.text "Rank_Belt", limit: 16777215, null: false
    t.text "Rank_WatchRemarkEN", limit: 16777215, null: false
    t.text "Rank_WatchRemarkJP", limit: 16777215, null: false
    t.text "Rank_SLGInside", limit: 16777215, null: false
    t.text "Rank_SLGOutside", limit: 16777215, null: false
    t.text "Rank_SLGMetal", limit: 16777215, null: false
    t.text "Rank_SLGCorner", limit: 16777215, null: false
    t.text "Rank_SLGRemarkEN", limit: 16777215, null: false
    t.text "Rank_SLGRemarkJP", limit: 16777215, null: false
    t.text "Rank_ACC", limit: 16777215, null: false
    t.text "Rank_ACCRemarkEN", limit: 16777215, null: false
    t.text "Rank_ACCRemarkJP", limit: 16777215, null: false
    t.text "BagLength", limit: 16777215, null: false
    t.text "BagWidth", limit: 16777215, null: false
    t.text "BagHeight", limit: 16777215, null: false
    t.text "BagHandDrop", limit: 16777215, null: false
    t.text "BagShoulderStrap", limit: 16777215, null: false
    t.text "BagSizeRemarkEN", limit: 16777215, null: false
    t.text "BagSizeRemarkJP", limit: 16777215, null: false
    t.text "CaseDiameter", limit: 16777215, null: false
    t.text "WatchWrist", limit: 16777215, null: false
    t.text "WatchSizeRemarkEN", limit: 16777215, null: false
    t.text "WatchSizeRemarkJP", limit: 16777215, null: false
    t.text "SLGLength", limit: 16777215, null: false
    t.text "SLGWidth", limit: 16777215, null: false
    t.text "SLGHeight", limit: 16777215, null: false
    t.text "SLGSizeRemarkEN", limit: 16777215, null: false
    t.text "SLGSizeRemarkJP", limit: 16777215, null: false
    t.text "RingDiameter", limit: 16777215, null: false
    t.text "RingRemarkEN", limit: 16777215, null: false
    t.text "RingRemarkJP", limit: 16777215, null: false
    t.text "NecklaceCharmLength", limit: 16777215, null: false
    t.text "NeckLaceCharmHeight", limit: 16777215, null: false
    t.text "NeckLaceLong", limit: 16777215, null: false
    t.text "NeckLaceRemarkEN", limit: 16777215, null: false
    t.text "NeckLaceRemarkJP", limit: 16777215, null: false
    t.text "ScarfHeight", limit: 16777215, null: false
    t.text "ScarfLength", limit: 16777215, null: false
    t.text "ScarfRemarkEN", limit: 16777215, null: false
    t.text "ScarfRemarkJP", limit: 16777215, null: false
    t.text "BraceletWrist", limit: 16777215, null: false
    t.text "BraceletWidth", limit: 16777215, null: false
    t.text "BraceletRemarkEN", limit: 16777215, null: false
    t.text "BraceletRemarkJP", limit: 16777215, null: false
    t.text "ACC_OtherRemarkEN", limit: 16777215, null: false
    t.text "ACC_OtherRemarkJP", limit: 16777215, null: false
    t.text "colorJapanese", limit: 16777215, null: false
    t.text "materialJapanese", limit: 16777215, null: false
    t.text "HardWareColorJapanese", limit: 16777215, null: false
    t.text "CaseColorJapanese", limit: 16777215, null: false
    t.text "CaseMaterialJapanese", limit: 16777215, null: false
    t.text "BraceletMaterialJapanese", limit: 16777215, null: false
    t.text "MovementJapanese", limit: 16777215, null: false
    t.text "BagJapaneseBrand", limit: 16777215, null: false
    t.text "SmallLeatherGoodsJapaneseBrand", limit: 16777215, null: false
    t.text "WatchJapaneseBrand", limit: 16777215, null: false
    t.text "AccessoriesJapaneseBrand", limit: 16777215, null: false
    t.text "BeltWaistSize", limit: 16777215, null: false
    t.text "BeltWidth", limit: 16777215, null: false
    t.text "BuckleLength", limit: 16777215, null: false
    t.text "BuckleWidth", limit: 16777215, null: false
    t.text "BeltRemarkEN", limit: 16777215, null: false
    t.text "BeltRemarkJP", limit: 16777215, null: false
    t.text "ShoesSize", limit: 16777215, null: false
    t.text "ShoesRemarkEN", limit: 16777215, null: false
    t.text "ShoesRemarkJP", limit: 16777215, null: false
  end

  create_table "order_owners", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "order_code_prefix", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_payments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "order_id", null: false
    t.string "payment_method"
    t.integer "paid_amount"
    t.datetime "paid_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_payments_on_order_id"
  end

  create_table "order_products", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "order_id", null: false
    t.string "shop_from"
    t.string "product_name"
    t.text "product_remark"
    t.integer "product_quantity"
    t.integer "product_price"
    t.string "receive_number"
    t.string "hk_tracking_number"
    t.string "tracking_number"
    t.integer "state", default: 0
    t.datetime "ship_date"
    t.integer "product_cost"
    t.integer "shipment_cost"
    t.integer "discount"
    t.integer "total_cost"
    t.datetime "receipt_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hk_tracking_number"], name: "index_order_products_on_hk_tracking_number"
    t.index ["order_id"], name: "index_order_products_on_order_id"
    t.index ["ship_date"], name: "index_order_products_on_ship_date"
  end

  create_table "orders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "order_id"
    t.integer "order_owner_id", null: false
    t.string "customer_name"
    t.string "customer_contact"
    t.string "customer_address"
    t.integer "state", default: 0
    t.integer "total_price"
    t.datetime "order_created_at"
    t.datetime "order_finished_at"
    t.boolean "emergency_call", default: false
    t.string "pickup_way"
    t.text "remark"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_created_at", "order_finished_at"], name: "index_orders_on_created_finished"
    t.index ["order_id"], name: "index_orders_on_order_id", unique: true
    t.index ["order_owner_id"], name: "index_orders_on_order_owner_id"
    t.index ["state"], name: "index_orders_on_state"
  end

  create_table "report_export_tasks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "report_code"
    t.string "to_email"
    t.integer "created_by_id"
  end

  create_table "userdata", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.text "username", limit: 16777215, null: false
    t.text "password", limit: 16777215, null: false
    t.text "name", limit: 16777215, null: false
  end

end
