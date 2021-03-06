require 'spec_helper'

describe "FriendlyForwardings" do

  it "should forward to the requested page after login" do
    user = FactoryGirl.create(:user)
    visit edit_user_path(user)
    fill_in 'session_email',    with: user.email
    fill_in 'session_password', with: user.password
    click_button
    response.should render_template('users/edit')
    visit logout_path
    visit login_path
    fill_in 'session_email',    with: user.email
    fill_in 'session_password', with: user.password
    click_button
    response.should render_template('student_groups/index')
  end

end
