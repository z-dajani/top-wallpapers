class ImagePostValidator < ActiveModel::Validator
  def validate(post)
    validate_url(post)
    validate_thumbnail(post)
    validate_permalink(post)
    validate_dimensions(post)
  end

  def validate_url(post)
    return unless post.url

    unless post.url =~ /\A#{URI::regexp(['http', 'https'])}\z/
      post.errors[:url] << 'is not a valid http url'
    end

    parsed_url = URI.parse(post.url)
    host = parsed_url.host

    unless %w(imgur.com i.imgur.com m.imgur.com).include?(host)
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
      post.errors[:thumbnail] << 'is not a thumbs.redditmedia.com link'
    end
  end

  def validate_permalink(post)
    return unless post.permalink
    unless post.permalink[0..2] == '/r/'
      post.errors[:permalink] << 'is not in the correct form'
    end
  end

  def validate_dimensions(post)
    if post.height.present? && post.width.nil?
      post.errors[:width] << 'height was present, width was not'
    end

    if post.width.present? && post.height.nil?
      post.errors[:height] << 'width was present, height was not'
    end
  end

end
