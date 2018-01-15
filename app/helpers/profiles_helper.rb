module ProfilesHelper
  def sex_choice
    Profile.sexes.keys.map{|key| [t("sex.#{key}"), key]}
  end
end
