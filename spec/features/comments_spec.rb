require "rails_helper"

feature "Adding and deleting comments", type: :feature do
  before(:all) do
    @user = create(:user)
    @item = create(:item)
    @event = create(:event)
  end

  after(:all) do
    User.delete_all
    Item.delete_all
    Event.delete_all
    Comment.delete_all
  end

  scenario "add a comment" do
    login_as(@user.email)
    visit_events(@event)
    handle_create(@event)
    visit_items(@item)
    handle_create(@item)
  end

  scenario "delete a comment" do
    login_as(@user.email)
    visit_events(@event)
    handle_delete(@event)
    visit_items(@item)
    handle_delete(@item)
  end

  def visit_events(event)
    click_link "Events"
    click_link "Show", href: event_path(event)
  end

  def visit_items(item)
    click_link "Shop"
    click_link "Show", href: item_path(item)
  end

  def handle_delete(resource)
    type = resource.class.name.downcase
    path = eval("#{type}_path(resource)")
    comment_href = eval("#{type}_comment_path(resource, resource.comments.last)")
    last_comment = Comment.last
    expect do
      click_link "Delete", href: comment_href
    end.to change(Comment, :count).by(-1)
    expect(current_path).to eq path
    expect(page).to have_content "Comment has been deleted."
    expect(page).not_to have_content last_comment.content
  end

  def handle_create(resource)
    type = resource.class.name.downcase
    path = eval("#{type}_path(resource)")
    expect do
      fill_in "Content", with: "Some random event comment"
      click_button "Add comment"
    end.to change(Comment, :count).by(1)
    last_comment = Comment.last
    expect(current_path).to eq path
    expect(page).to have_content "New comment has been added!"
    expect(page).to have_content last_comment.content
    path_of_comment = eval("#{type}_comment_path(resource, last_comment)")
    expect(page).to have_link "Delete", href: path_of_comment
  end
end
