require 'test_helper'
require 'json'
require_relative 'wallpaper_downloader_test_data'


class WallpaperDownloaderTest < MiniTest::Unit::TestCase
  def test_extract_post_info
    posts = WallpaperDownloader.send(:extract_post_info, $top_3_raw_posts)
    assert_equal($top_3_formatted_posts, posts)

  end
  
end
