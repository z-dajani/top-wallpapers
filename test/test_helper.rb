ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :all

  def valid_image_post(save: true)
    thumb = "http://a.thumbs.redditmedia.com/oi71EfEpKh_eibbi9SGtI0BTj-hU1RIG542h_VIU5I8.jpg"
    p = ImagePost.new(title: 'Space Shuttle', score: 173, thumbnail: thumb,
                      permalink:"/r/wallpapers/comments/3ypj88/space_shuttle/",
                      url: "http://i.imgur.com/C49VtMu.jpg")
    p.save if save
    p
  end

  def valid_image_post_2(save: true)
    thumb = "http://b.thumbs.redditmedia.com/JFRnrJYDSGDhZWHIX8yzE7TZAylTWBX_xknPDQY5bfQ.jpg"
    p = ImagePost.new(title: 'Star Destroyer', score: 2018, thumbnail: thumb,
                      permalink:"/r/wallpapers/comments/3ys0bg/star_destroyer/",
                      url: "http://i.imgur.com/x8bu3JE.jpg")
    p.save if save
    p
  end

end
