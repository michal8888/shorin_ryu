require "rails_helper"
include Warden::Test::Helpers
Warden.test_mode!

feature "Cart management", type: :feature do
  scenario "add item to a cart", js: true do
    user = create(:user)
    ticket = create(:item, name: "ticket")
    kimono = create(:item, price: 10)
    login_as(user)
    visit root_path
    find(".navbar-toggler-icon").click
    click_link "Shop"
    click_link "Show", href: item_path(ticket)
    expect do
      fill_in "Quantity", with: 3
      click_button "Add to cart"
    end.to change(CartItem, :count).by(1)
    expect(page).to have_content "Item has been added to your cart."
    check_cart_content(user)
    find(".navbar-toggler-icon").click
    click_link "Shop"
    click_link "Show", href: item_path(kimono)
    expect do
      find(".increase_cart_item").click
      click_button "Add to cart"
    end.to change(CartItem, :count).by(1)
    expect(CartItem.last.quantity).to eq 2
    expect(page).to have_content "Item has been added to your cart."
    check_cart_content(user)
    find(".navbar-toggler-icon").click
    click_link "Shop"
    click_link "Show", href: item_path(kimono)
    expect do
      fill_in "Quantity", with: 100
      click_button "Add to cart"
    end.not_to change(CartItem, :count)
    expect(page).to have_content "Item has been added to your cart."
    check_cart_content(user)
  end
  
  scenario "increase quantity of item already in cart", js: true do
    user = create(:user)
    cart = create(:cart, user: user)
    cart_item = create(:cart_item, cart_id: cart)
    login_as(user)
    visit root_path
    find(".navbar-toggler-icon").click
    find(".nav-link.dropdown-toggle").click
    click_link "Your cart"
    within "#edit_cart_item_#{cart_item.id}" do
      expect do
        fill_in "Quantity", with: (cart_item.quantity + 1)
        click_button "Update cart"
        cart_item.reload
      end.to change(cart_item, :quantity).by(1)
    end
    expect(current_path).to eq cart_path(cart)
    expect(page).to have_content "Item's quantity has been updated."
    within "#edit_cart_item_#{cart_item.id}" do
      expect do
        find(".decrease_cart_item").click
        click_button "Update cart"
        cart_item.reload
      end.to change(cart_item, :quantity).by(-1)
    end
    within "#edit_cart_item_#{cart_item.id}" do
      expect do
        find(".increase_cart_item").click
        find(".increase_cart_item").click
        click_button "Update cart"
        cart_item.reload
      end.to change(cart_item, :quantity).by(2)
    end
  end
  
  scenario "delete item from cart" do
    user = create(:user)
    cart = create(:cart, user: user)
    create(:cart_item, cart_id: cart)
    login_as(user)
    visit root_path
    click_link "Your cart"
    check_cart_content(user)
    last_item = user.cart.cart_items.last
    path_of_item = cart_item_path(last_item.cart, last_item)
    expect(page).to have_link "Delete item", href: path_of_item
    expect do
      path = cart_item_path(user.cart, last_item)
      # TODO: delete items quantity, check if item still should be in cart
      # fill_in ""
      click_link "Delete item", href: path
    end.to change(CartItem, :count).by(-1)
    expect(current_path).to eq cart_path(user.cart)
    expect(page).to have_content "Item has been deleted from your cart."
    expect(page).not_to have_link "Delete item", href: path_of_item
  end
  
  def check_cart_content(user)
    cart = user.reload.cart
    expect(current_path).to eq cart_path(cart)
    total_price = 0
    if cart.cart_items.any?
      cart.cart_items.each do |c_item|
        expect(page).to have_content c_item.item.name
        expect(page).to have_content c_item.item.description
        expect(page).to have_content c_item.item.price
        expect(page).to have_content "Qty:"
        expect(page).to have_content c_item.quantity
        path = cart_item_path(c_item.cart, c_item)
        expect(page).to have_link "Delete item", href: path
        total_price += c_item.item.price * c_item.quantity
      end
    end
    expect(page).to have_content "Total price:"
    expect(cart.sum_price).to eq total_price
  end
end
