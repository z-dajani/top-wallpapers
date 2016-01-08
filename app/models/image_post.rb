class ImagePostValidator < ActiveModel::Validator
  def validate(post)
    require 'net/http'
    require 'uri'
    validate_url(post)
    validate_thumbnail(post)
    validate_permalink(post)
  end

  def validate_url(post)
    return unless post.url

    unless post.url =~ /\A#{URI::regexp(['http', 'https'])}\z/
      post.errors[:url] << 'is not a valid http url'
    end

    parsed_url = URI.parse(post.url)
    host = parsed_url.host

    unless host == 'imgur.com' || host == 'i.imgur.com' || host == 'm.imgur.com'
      post.errors[:url] << 'is not an imgur link'
    end

    if parsed_url.path.chars.first(3).join == '/a/'
      post.errors[:url] << 'is an imgur album'
    end
  end

  def validate_thumbnail(post)
    return unless post.thumbnail

    unless post.thumbnail =~ /\A#{URI::regexp(['http', 'https'])}\z/
      post.errors[:thumbnail] << 'is not a valid http url'
    end

    host = URI.parse(post.thumbnail).host
    unless host && host.chars.last(22).join == 'thumbs.redditmedia.com'
      post.errors[:thumbnail] << 'is not a thumbs.redditmedia link'
    end
  end

  def validate_permalink(post)
    return unless post.permalink
    unless post.permalink[0..2] == '/r/'
      post.errors[:permalink] << 'is not in the correct form'
    end
  end

end

class ImagePost < ActiveRecord::Base
  before_save { self.title = self.title[0..69] if self.title.length > 70 }

  has_attached_file :thumb_img, styles: { thumb: "150x60>" }, 
                                default_url: "/images/:style/missing.png"
  validates_attachment_content_type :thumb_img, content_type: /\Aimage\/.*\Z/
  validates :title, presence: true
  validates :url, presence: true, uniqueness: true
  validates :permalink, presence: true, uniqueness: true
  validates :thumbnail, presence: true, uniqueness: true
  validates :subreddit, presence: true
  validates :score, presence: true, numericality: { greater_than: -1 }
  validates_with ImagePostValidator
end
