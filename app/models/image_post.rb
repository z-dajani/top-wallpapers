%w(net/https open-uri uri json).each { |f| require f }

class ImagePostValidator < ActiveModel::Validator
  def validate(post)
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

  def self.refresh_posts(subreddit_count: 11)
    return unless ready_to_refresh?
    File.write('app/last_wallpaper_refresh', Time.now.to_i)

    subreddits = %w(wallpaper wallpapers earthporn carporn skyporn foodporn
    abandonedporn mapporn architectureporn roomporn exposureporn)
    subreddits.first(subreddit_count).each do |sub|
      old_posts = ImagePost.all.select{ |p| p.subreddit =~ /#{sub}/i }
      old_posts.each { |p| p.destroy }
      subreddit_top_daily_posts(sub, 7)
    end
  end

  def self.ready_to_refresh?
    begin
      last_refresh_time = IO.read('app/last_wallpaper_refresh').to_i
      (Time.now.to_i - last_refresh_time) >= 1800
    rescue Errno::ENOENT
      true
    end      
  end

  def self.subreddit_top_daily_posts(subreddit_name, post_attempts)
    if post_attempts.between?(1, 25)
      url = "https://www.reddit.com/r/#{subreddit_name}/top/.json"
      response = get_json_response(url)
      posts = response['data']['children'].first(post_attempts)
      extract_post_info(posts)
    else
      raise ArgumentError.new('Invalid attempt amount: not in range 1-25')
    end
  end

  private

  def self.get_json_response(_url)
    url = URI.parse(_url)
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port, use_ssl: true) do 
      |http| http.request(req)
    end
    raise "non-200 response: #{res.code}" unless res.code[0] == '2'
    JSON.parse(res.body)
  end

  def self.extract_post_info(posts)
    post_info = posts.map do |p|
      ip = ImagePost.new(title: p['data']['title'], url: p['data']['url'],
        permalink: p['data']['permalink'], thumbnail: p['data']['thumbnail'],
        subreddit: p['data']['subreddit'], score: p['data']['score'])
      if ip.save
        ip.thumb_img = open(ip.thumbnail)
        ip.save
        ip
      else
        nil
      end
    end
    post_info.compact
  end
end
