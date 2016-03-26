require 'test_helper'
require 'json'
require_relative 'wallpaper_downloader_test_data'

class ImagePostTest < ActiveSupport::TestCase
  def setup
    @post = valid_image_post(save: false)
  end

  test 'valid image post' do
    assert @post.valid?
  end

  test 'title should exist' do
    @post.title = ''
    assert_not @post.valid?
  end

  test 'url should be unique' do
    @post.save
    post2 = valid_image_post(save: false)
    post2.url = @post.url
    assert_not post2.valid?
  end

  test 'url should be in correct form' do
    ['imgur.com', 'httpz://imgur', 'imgur.com/'].each do |u|
      @post.url = u
      assert_not @post.valid?, u
    end
  end

  test "url's host should be imgur" do
    ['http://www.imgurs.com', 'http://www.imgur.org'].each do |u|
      @post.url = u
      assert_not @post.valid?, u
    end
  end

  test "imgur album urls shouldn't be allowed" do
    @post.url = 'https://imgur.com/a/0q4ghqejjjjj'
    assert_not @post.valid?
  end

  test 'permalink should exist' do
    @post.permalink = ''
    assert_not @post.valid?
  end

  test 'permalink should be unique' do
    @post.save
    post2 = valid_image_post(save: false)
    post2.permalink = @post.permalink
    assert_not post2.valid?
  end

  test 'permalink should be in correct form' do
    @post.permalink[0..2] = '/u/'
    assert_not @post.valid?
  end

  test 'thumbnail should exist' do
    @post.thumbnail = ''
    assert_not @post.valid?
  end

  test 'thumbnail should be unique' do
    @post.save
    post2 = valid_image_post(save: false)
    post2.thumbnail = @post.thumbnail
    assert_not post2.valid?
  end 

  test 'thumbnail should be in the correct form' do
    ['thumbs.redditmedia.com', 'httpz://thumbs.redditmedia', 
     'thumbs.redditmedia.com/'].each do |u|
      @post.thumbnail = u
      assert_not @post.valid?, u
    end
  end

  test "thumbnail's host should be correct" do
    ['http://www.thumbs.redditmedia.org', 
     'http://www.thumb.redditmedia.com/'].each do |u|
      @post.thumbnail = u
      assert_not @post.valid?, u
    end

    ['http://www.a.thumbs.redditmedia.com', 
     'http://www.thumbs.redditmedia.com/'].each do |u|
      @post.thumbnail = u
      assert @post.valid?, u
    end
  end

  test 'subreddit should exist' do
    @post.subreddit = ''
    assert_not @post.valid?
  end

  test 'score should exist' do
    @post.score = nil
    assert_not @post.valid?
  end

  test 'score should be positive' do
    @post.score = -1
    assert_not @post.valid?
  end

  test 'valid width and height' do
    @post.width = 1920
    @post.height = 1080
    assert @post.valid?
  end

  test 'width should not be too large' do
    @post.height = 990
    @post.width = 10001
    assert_not @post.valid?
  end

  test 'width should not be too small' do
    @post.height = 990
    @post.width = 99
    assert_not @post.valid?    
  end

  test 'height should not be too large' do
    @post.width = 990
    @post.height = 10001
    assert_not @post.valid?
  end

  test 'height should not be too small' do
    @post.width = 990
    @post.height = 99
    assert_not @post.valid?        
  end

  test 'if width is present, height should be present' do
    @post.width = 990
    assert_not @post.valid?
  end

  test 'if height is present, width should be present' do
    @post.height = 990
    assert_not @post.valid?
  end

  test 'extraction of post info' do
    posts = ImagePost.send(:extract_post_info, $top_raw_posts)
    attributes = []
    posts.each do |p|
      attributes << p.attributes.except('id', 'created_at', 'updated_at')
    end
    assert_equal($top_posts_attr, attributes)
  end

  test 'subreddit_top_daily_posts - invalid post amount' do
    [0,26,'hello'].each do |n|
      assert_raises ArgumentError do
        ImagePost.subreddit_top_daily_posts('wallpaper', n)
      end
    end
  end

  test 'fill_dimensions_from_title - valid cases' do
    cases = { 'hello 1920 x 1080' => [1920,1080],
              '1920x1080 hello'   => [1920,1080],
              '..1920X1080...'    => [1920,1080],
              '1920 X 1080 x 98'  => [1920,1080],
              '(1920x1080)'       => [1920,1080],
              '[1920x1080]'       => [1920,1080],
              'x 1920 x 1080)'    => [1920,1080],
              '1024x740'          => [1024,740],
              '1024 x 740'        => [1024,740],
              '(1024x740)'        => [1024,740] }
    cases.each do |title, dimensions|
      @post.title = title
      @post.fill_dimensions_from_title
      assert_equal [@post.width, @post.height], dimensions
    end
  end

  test 'fill_dimensions_from_title - invalid cases' do
    failing_cases = ['at startfe f str', '-', '1920 1080', '24x85',
                     '24 x 85', '1920x8j40', '1920x', 'x 840']

    failing_cases.each do |title|
      @post.title = title
      assert_not @post.fill_dimensions_from_title
    end
  end
end
