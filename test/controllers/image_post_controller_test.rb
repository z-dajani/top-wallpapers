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

  test 'typical pagination (first page)' do
    42.times { valid_image_post }
    get :index
    assert_select "a[href='#{root_path}?page=2']"
    assert_select "a[href='#{root_path}?page=0']", false
    assert_select '.post', count: 20

    get :index, page: 1
    assert_select "a[href='#{root_path}?page=2']"
    assert_select "a[href='#{root_path}?page=0']", false
    assert_select '.post', count: 20
  end

  test 'typical pagination (not first page)' do
    42.times { valid_image_post }
    get :index, page: 2
    assert_select "a[href='#{root_path}?page=1']"
    assert_select "a[href='#{root_path}?page=3']"
    assert_select '.post', count: 20
  end

  test 'pagination when no further pages exist' do
    42.times { valid_image_post }
    get :index, page: 3
    assert_select "a[href='#{root_path}?page=2']"
    assert_select "a[href='#{root_path}?page=4']", false
    assert_select '.post', count: 2
  end

  test 'no pagination links should exist when no ImagePosts exist' do
    get :index
    assert_select "a[href='#{root_path}?page=2']", false
  end

  test 'first page of ImagePosts should show if invalid page param' do
    20.times { valid_image_post }
    lowest_scoring_post = valid_image_post(save: false)
    lowest_scoring_post.score = 1
    lowest_scoring_post.save
    get :index, page: 'f'
    assert_select "a[href='#{lowest_scoring_post.url}']", false
  end

end
