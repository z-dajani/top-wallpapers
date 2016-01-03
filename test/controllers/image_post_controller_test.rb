require 'test_helper'

class ImagePostControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test 'index should display image posts when they exist in db' do
    valid_image_post
    get :index
    assert_select '#posts-container', 1
  end

  test "index shouldn't show image posts container when no posts exist" do
    get :index
    assert_select '#posts-container', false
  end

  test 'index should contain links to the permalink of each post' do
    p1 = 'https://www.reddit.com' + valid_image_post.permalink
    p2 = 'https://www.reddit.com' + valid_image_post.permalink
    get :index
    assert_select "a[href='#{p1}']"
    assert_select "a[href='#{p2}']"
  end

  test 'index posts should be sorted from highest score to lowest' do
    small_score_post = valid_image_post
    big_score_post = valid_image_post(save: false)
    big_score_post.score = small_score_post.score + 1
    big_score_post.save

    permalink = 'https://www.reddit.com' + big_score_post.permalink
    get :index
    assert_select ".post:first-of-type a[href='#{permalink}']"
  end

end
