module CommonActions

  def sign_up
    visit '/'
    click_link 'Sign up'

    fill_in 'user_first_name',            with: 'Manuela'
    fill_in 'user_last_name',             with: 'Carmena'
    fill_in 'user_email',                 with: 'manuela@madrid.es'
    fill_in 'user_password',              with: 'judgementday'
    fill_in 'user_password_confirmation', with: 'judgementday'

    click_button 'Sign up'
  end

  def reset_password
    create(:user, email: 'manuela@madrid.es')

    visit '/'
    click_link 'Log in'
    click_link 'Forgot your password?'

    fill_in 'user_email', with: 'manuela@madrid.es'
    click_button 'Send me reset password instructions'
  end

  def comment_on(debate)
    user2 = create(:user)

    login_as(user2)
    visit debate_path(debate)

    fill_in 'comment_body', with: 'Have you thought about...?'
    click_button 'Publish comment'
    expect(page).to have_content 'Have you thought about...?'
  end

  def reply_to(user)
    manuela = create(:user)
    debate  = create(:debate)
    comment = create(:comment, commentable: debate, user: user)

    login_as(manuela)
    visit debate_path(debate)

    click_link "Reply"
    within "#js-comment-form-comment_#{comment.id}" do
      fill_in 'comment_body', with: 'It will be done next week.'
      click_button 'Publish reply'
    end
    expect(page).to have_content 'It will be done next week.'
  end

end