require 'rails_helper'

feature 'Users' do

  scenario 'Sign up' do
    visit '/'
    click_link 'Sign up'

    fill_in 'user_first_name',            with: 'Manuela'
    fill_in 'user_last_name',             with: 'Carmena'
    fill_in 'user_email',                 with: 'manuela@madrid.es'
    fill_in 'user_password',              with: 'judgementday'
    fill_in 'user_password_confirmation', with: 'judgementday'

    click_button 'Sign up'

    expect(page).to have_content "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account."

    sent_token = /.*confirmation_token=(.*)".*/.match(ActionMailer::Base.deliveries.last.body.to_s)[1]
    visit user_confirmation_path(confirmation_token: sent_token)

    expect(page).to have_content "Your email address has been successfully confirmed"
  end

  scenario 'Sign in' do
    user = create(:user, email: 'manuela@madrid.es', password: 'judgementday')

    visit '/'
    click_link 'Log in'
    fill_in 'user_email',    with: 'manuela@madrid.es'
    fill_in 'user_password', with: 'judgementday'
    click_button 'Log in'

    expect(page).to have_content 'Signed in successfully.'
  end

  scenario 'Sign out' do
    user = create(:user)
    login_as(user)

    visit "/"
    click_link 'Logout'

    expect(page).to have_content 'Signed out successfully.'
  end

  scenario 'Reset password' do
    create(:user, email: 'manuela@madrid.es')

    visit '/'
    click_link 'Log in'
    click_link 'Forgot your password?'

    fill_in 'user_email', with: 'manuela@madrid.es'
    click_button 'Send me reset password instructions'

    expect(page).to have_content "You will receive an email with instructions on how to reset your password in a few minutes."

    sent_token = /.*reset_password_token=(.*)".*/.match(ActionMailer::Base.deliveries.last.body.to_s)[1]
    visit edit_user_password_path(reset_password_token: sent_token)

    fill_in 'user_password', with: 'new password'
    fill_in 'user_password_confirmation', with: 'new password'
    click_button 'Change my password'

    expect(page).to have_content "Your password has been changed successfully. You are now signed in."
  end

end
