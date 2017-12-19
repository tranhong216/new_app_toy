module UsersHelper
  def gravatar_for user, size: 80
    gravatar_id = Digest::MD5.hexdigest user.email.downcase
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag gravatar_url, alt: user.name, class: "gravatar"
  end

  def sex_choice
    User.sexes.keys.map{|key| [t("sex.#{key}"), key]}
  end
end