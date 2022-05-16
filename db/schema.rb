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

ActiveRecord::Schema.define(version: 2022_05_15_052135) do

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

  create_table "userdata", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.text "username", limit: 16777215, null: false
    t.text "password", limit: 16777215, null: false
    t.text "name", limit: 16777215, null: false
  end

end
