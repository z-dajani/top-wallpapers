class ImagePostValidator < ActiveModel::Validator
  def validate(image_post)
    require 'net/http'
    require 'uri'

    unless image_post.permalink[0..2] == '/r/'
      image_post.errors[:permalink] << 'is not in the correct form'
    end

    unless image_post.url =~ /\A#{URI::regexp(['http', 'https'])}\z/
      image_post.errors[:url] << 'is not a valid http url'
    end

    url_host = URI.parse(image_post.url).host
    unless url_host == 'imgur.com' || url_host == 'i.imgur.com'
      image_post.errors[:url] << 'is not an imgur link'
    end

    unless image_post.thumbnail =~ /\A#{URI::regexp(['http', 'https'])}\z/
      image_post.errors[:thumbnail] << 'is not a valid http url'
    end

    thumb_host = URI.parse(image_post.thumbnail).host
    unless thumb_host && thumb_host.chars.last(22).join == 'thumbs.redditmedia.com'
      image_post.errors[:thumbnail] << 'is not a thumbs.redditmedia link'
    end
  end

end

class ImagePost < ActiveRecord::Base
  before_save { self.title = self.title[0..69] if self.title.length > 70 }

  validates :title, presence: true
  validates :url, presence: true, uniqueness: true
  validates :permalink, presence: true, uniqueness: true
  validates :thumbnail, presence: true, uniqueness: true
  validates :score, presence: true, numericality: { greater_than: -1 }
  validates_with ImagePostValidator
end
