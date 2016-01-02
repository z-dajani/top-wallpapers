require 'test_helper'
require 'json'
require_relative 'wallpaper_downloader_test_data'


class WallpaperDownloaderTest < MiniTest::Unit::TestCase

  def test_extract_post_info
    ImagePost.destroy_all
    posts = WallpaperDownloader.send(:extract_post_info, $top_raw_posts)
    attributes = []
    posts.each do |p|
      attributes << p.attributes.except('id', 'created_at', 'updated_at')
    end
    assert_equal($top_posts_attr, attributes)
  end

  def test_subreddit_top_daily_posts_invalid_subreddit_name
    assert_raises RuntimeError do
      WallpaperDownloader.subreddit_top_daily_posts('a' * 100, 10)
    end
  end

  def test_subreddit_top_daily_posts_invalid_post_amount
    [0,26,'hello'].each do |n|
      assert_raises ArgumentError do
        WallpaperDownloader.subreddit_top_daily_posts('funny', n)
      end
    end
  end
  
end
