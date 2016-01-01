require 'test_helper'
require 'json'
require_relative 'wallpaper_downloader_test_data'


class WallpaperDownloaderTest < MiniTest::Unit::TestCase
  def test_extract_post_info
    posts = WallpaperDownloader.send(:extract_post_info, $top_3_raw_posts)
    assert_equal($top_3_formatted_posts, posts)
  end

  def test_subreddit_top_daily_posts_invalid_subreddit_name
    assert_raises RuntimeError do
      WallpaperDownloader.subreddit_top_daily_posts('a' * 400, 10)
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
