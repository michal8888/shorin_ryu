require 'rails_helper'

RSpec.describe Item, type: :model do
  describe Item, ".new" do
    it "creates valid item if all info is provided" do
      item = build(:item)
      expect(item).to be_valid
    end

    it "requires name" do
      item = build(:item, name: nil)
      expect(item).not_to be_valid
    end

    it "requires description" do
      item = build(:item, description: nil)
      expect(item).not_to be_valid
    end

    it "requires price" do
      item = build(:item, price: nil)
      expect(item).not_to be_valid
    end

    it "requires size" do
      item = build(:item, size: nil)
      expect(item).not_to be_valid
    end

    it "requires store_item_id" do
      item = build(:item, store_item_id: nil)
      expect(item).not_to be_valid
    end

    it "requires price greater or equal to 0.01" do
      item = build(:item, price: 0.001)
      expect(item).not_to be_valid
    end

    it "requires size in correct format: xs, s, m, l, xl, xxl" do
      item = build(:item, size: "xxxl")
      expect(item).not_to be_valid
    end

    it "requires price greater or equal to 0.01" do
      item = build(:item, price: 0.001)
      expect(item).not_to be_valid
    end

    it "requires unique name" do
      create(:item, name: "white_bandana", store_item_id: 200300)
      item = build(:item, name: "white_bandana", store_item_id: 300400)
      expect(item).not_to be_valid
    end

    it "requires unique store_item_id" do
      create(:item, name: "black_bandana", store_item_id: 100200300)
      item = build(:item, name: "yellow_bandana", store_item_id: 100200300)
      expect(item).not_to be_valid
    end
  end
end
