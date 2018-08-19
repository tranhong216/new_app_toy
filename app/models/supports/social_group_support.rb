module Supports
  class SocialGroupSupport
    attr_reader :social_group, :group_user, :micropost

    def initialize args = {}
      @social_group = args[:social_group]
      @group_user = args[:group_user]
      @micropost = args[:micropost]
    end

    def group_microposts
      social_group.feed
    end

    def new_group_micropost
      social_group.microposts.build
    end
  end
end
