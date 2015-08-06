require 'rails_helper'

feature 'Debates' do

  scenario 'Index' do
    debates = [create(:debate), create(:debate), create(:debate)]
    featured_debates = [create(:debate), create(:debate), create(:debate)]

    visit debates_path

    expect(page).to have_selector('#featured-debates .debate-featured', count: 3)
    featured_debates.each do |debate|
      within('#featured-debates') do
        expect(page).to have_content debate.title
        expect(page).to have_css("a[href='#{debate_path(debate)}']", text: debate.description)
      end
    end

    expect(page).to have_selector('#debates .debate', count: 3)
    debates.each do |debate|
      within('#debates') do
        expect(page).to have_content debate.title
        expect(page).to have_css("a[href='#{debate_path(debate)}']", text: debate.description)
      end
    end
  end

  scenario 'Show' do
    debate = create(:debate)

    visit debate_path(debate)

    expect(page).to have_content debate.title
    expect(page).to have_content "Debate description"
    expect(page).to have_content debate.author.name
    expect(page).to have_content I18n.l(Date.today)
  end

  scenario 'Create' do
    author = create(:user)
    login_as(author)

    visit new_debate_path
    fill_in 'debate_title', with: 'Acabar con los desahucios'
    fill_in 'debate_description', with: 'Esto es un tema muy importante porque...'
    check 'debate_terms_of_service'

    click_button 'Create Debate'

    expect(page).to have_content 'Debate was successfully created.'
    expect(page).to have_content 'Acabar con los desahucios'
    expect(page).to have_content 'Esto es un tema muy importante porque...'
    expect(page).to have_content author.name
    expect(page).to have_content I18n.l(Date.today)
  end

  scenario 'JS injection is prevented but safe html is respected' do
    author = create(:user)
    login_as(author)

    visit new_debate_path
    fill_in 'debate_title', with: 'A test'
    fill_in 'debate_description', with: '<p>This is <script>alert("an attack");</script></p>'
    check 'debate_terms_of_service'

    click_button 'Create Debate'

    expect(page).to have_content 'Debate was successfully created.'
    expect(page).to have_content 'A test'
    expect(page.html).to include '<p>This is alert("an attack");</p>'
    expect(page.html).to_not include '<script>alert("an attack");</script>'
    expect(page.html).to_not include '&lt;p&gt;This is'
  end

  scenario 'tagging using dangerous strings' do

    author = create(:user)
    login_as(author)

    visit new_debate_path

    fill_in 'debate_title', with: 'A test'
    fill_in 'debate_description', with: 'A test'
    fill_in 'debate_tag_list', with: 'user_id=1, &a=3, <script>alert("hey");</script>'
    check 'debate_terms_of_service'

    click_button 'Create Debate'

    expect(page).to have_content 'Debate was successfully created.'
    expect(page).to have_content 'user_id1'
    expect(page).to have_content 'a3'
    expect(page).to have_content 'scriptalert("hey");script'
    expect(page.html).to_not include 'user_id=1, &a=3, <script>alert("hey");</script>'
  end

  scenario 'Update should not be posible if logged user is not the author' do
    debate = create(:debate)
    expect(debate).to be_editable
    login_as(create(:user))

    expect {
      visit edit_debate_path(debate)
    }.to raise_error ActiveRecord::RecordNotFound
  end

  scenario 'Update should not be posible if debate is not editable' do
    debate = create(:debate)
    vote = create(:vote, votable: debate)
    expect(debate).to_not be_editable
    login_as(debate.author)

    expect {
      visit edit_debate_path(debate)
    }.to raise_error ActiveRecord::RecordNotFound
  end

  scenario 'Update should be posible for the author of an editable debate' do
    debate = create(:debate)
    login_as(debate.author)

    visit debate_path(debate)
    click_link 'Edit'
    fill_in 'debate_title', with: "End child poverty"
    fill_in 'debate_description', with: "Let's..."

    click_button "Update Debate"

    expect(page).to have_content "Debate was successfully updated."
    expect(page).to have_content "End child poverty"
    expect(page).to have_content "Let's..."
  end

end
