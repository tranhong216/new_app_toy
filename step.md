## Phần 1: Khởi tạo table
- Tạo bảng `SocialGroup` bằng câu lệnh ` rails g migration CreateSocialGroup ` và viết nội dung vào file. Lý do không dùng tên `Group` vì tránh trường hợp về sau gọi method trùng với method `group` của rails.
```
  class CreateSocialGroup < ActiveRecord::Migration[5.1]
      def change
        create_table :social_groups do |t|
          t.string :name

          t.timestamps
        end
      end
    end
```
- Tương tự tạo bảng `GroupUser` bằng lệnh `rails g migration CreateGroupUser` để ghi thông tin thành viên trong một group với các trường như đoạn mã dưới đấy:
```
  class CreateGroupUser < ActiveRecord::Migration[5.1]
      def change
        create_table :group_users do |t|
          t.integer :user_id
          t.integer :social_group_id

          t.timestamps
        end
      end
    end
```
      
- Như ở chap trước ta đã có bảng `Micropost` để lưu bài viết của user, nay ta sẽ bổ sung thêm trường `social_group_id` để lưu bài id của bài viết khi người dùng viết bài trong group bằng câu lệnh: `rails g migration AddGroupToMicropost`. Khi bài viết do người dùng viết trên tường cá nhân, thì trường `social_group_id` sẽ nil. Chính vì đặt như vậy nên ta sẽ dễ dàng lấy ra các bài viết của user ( cá nhân + trong group) và có thể lấy bài viết chỉ có trong group bằng các dùng các association một cách dễ dàng.
```
    class AddGroupToMicropost < ActiveRecord::Migration[5.1]
        def change
            add_column :microposts, :social_group_id, :integer
        end
    end
```
- Sau đó chạy lệnh `rails db:migrate` để tiến hành khởi tạo bảng trong cơ sở dữ liệu.

## Phần 2: Xử lý phần liên quan tới group.
- Tạo 2 file model `social_group.rb` và `group_user.rb`
- Ở file `social_group.rb` ta thêm các dòng sau:

        class SocialGroup < ApplicationRecord
          ATTRIBUTE_PARAMS = %i(name).freeze

          has_many :group_users, dependent: :destroy
          has_many :microposts, dependent: :destroy
          has_many :members, through: :group_users, source: :user

        end


- Ở file `group_user.rb` ta thêm :
        class GroupUser < ApplicationRecord
          belongs_to :user
          belongs_to :social_group
        end


- Bổ sung thêm routes vào file `routes.rb`
```
resources :social_groups, only: [:index, :new, :create, :show] do
    resources :group_users, only: [:create, :destroy]
```
### Xử lý hiện tất cả group
- Trước tiên, ta tạo file `social_groups_controller.rb` và viết phần hiện tất cả group đang có.
```
class SocialGroupsController < ApplicationController
    def index
        @social_group = SocialGroup.all
    end
end
```
- Action `index` để lấy ra tất cả các group đang có. Bây giờ ta viết phần view index vào file `app/views/social_groups/index.html.erb` sau.
```
    <ul class="list-group">
      <% @social_groups.each do |social_group| %>
        <li class="list-group-item">
          <%= link_to social_group.name, social_group_path(social_group) %>
          <% if social_group.member? current_user %>
            <span class="joined pull-right">Đang tham gia</span>
          <% else %>
            <%= link_to "Tham  gia group", social_group_group_users_path(social_group),
              method: :post, class: "btn btn-primary pull-right" %>
          <% end %>
          <div class="clearfix"></div>
        </li>
      <% end %>
    </ul>
```
- Phương thức `member? current_user` là phương thức kiểm tra xem user có trong group không, nếu không có thì hiện nút `Tham gia` và ngược lại sẽ hiện trạng thái `Đang tham gia`. Phương thức đó được khai báo trong model `social_group.rb`. Và ta sẽ thêm nó ngay sau đây:

```
  class SocialGroup < ApplicationRecord
    
    def member? user
        members.include? user
    end
  end
```
- Vậy là phần view đã gần hoàn thành, khi người ta nhìn thấy group người ta sẽ ấn nút `Tham gia group` thì nó sẽ tạo 1 bản ghi vào bảng `group_users`. Bảng này sẽ lưu 2 thông số là `social_group_id` và `user_id`. Để gọi tới action `create` thì ta sẽ khai báo thêm option `method: :post`, ở đây ta sẽ gán liên kết tới `social_group_group_users_path` để gọi tới action `create` khi click vào. 
### Xử lý phần tạo group
- Vậy là phần xem các group đã xong, bây giờ ta sẽ xử lý phần tạo group.
- Đầu tiên, ta tạo file form tạo group như sau:
- Tạo file `app/views/social_groups/new.html.erb` với nội dung:

```
<h1>Tạo Group</h1>

<div class="row">
  <div class="col-md-6 col-md-offset-3">
    <%= render "form",  social_group: @social_group %>
  </div>
</div>

```
Và file `app/views/social_groups/_form.html.erb`
 
```
<%= form_for social_group do |f| %>
  <%= render "shared/error_messages", object: f.object %>

  <div class="form-group">
    <%= f.label :name %>
    <%= f.text_field :name, class: "form-control" %>
  </div>

  <%= f.submit "Tạo Group", class: "btn btn-primary" %>
<% end %>
```
Và để tới trang tạo group ta thêm vào file `app/views/social_groups/index.html.erb` đoạn code sau (thêm ở phía đầu):
```
<% if current_user.admin %>
  <%= link_to "Tạo Group", new_social_group_path, class: "btn btn-primary" %>
<% end %>

```

Ok, đã xong phần view, bây giờ ta sẽ xử lý phần controller. 
```
class SocialGroupsController < ApplicationController
  before_action :find_social_group, :check_user_in_group, only: :show

  def index
    @social_groups = SocialGroup.all
  end

  def new
    @social_group = SocialGroup.new
  end

  def create
    @social_group = SocialGroup.new social_group_params
    if social_group.save
      flash[:success] = "Tạo group thành công"
      redirect_to social_groups_path
    else
      flash[:warning] = "Tạo group thất bại"
      render :new
    end
  end

  def show
    @group_user = current_user.group_users.find_by social_group: social_group
    
    return redirect_to social_groups_path unless group_user
  end

  private

  attr_reader :social_group, :group_user

  def social_group_params
    params.require(:social_group).permit SocialGroup::ATTRIBUTE_PARAMS
  end

  def find_social_group
    @social_group = SocialGroup.find_by id: params[:id]

    return if social_group
    flash[:warning] = "Không tìm thấy group"
    redirect_to social_groups_path
  end

  def check_user_in_group
    return if social_group.member?(current_user)

    flash[:warning] = "Bạn không phải thành viên của group"
    redirect_to social_groups_path
  end
end
```
Cũng không quá phức tạp cho việc tạo group, ta xem action `new` và `create` , 
### Hiện một group
ở đây có một số hàm cho phần show khi người dùng click vào mình sẽ giải thích luôn, đó làm `find_social_group` tương tự như các phần trong tut, và phần `check_user_in_group` để kiểm tra thực sự user ấy có ở trong group không. 
- Tiếp tới, ta sẽ làm view cho action show bằng nội dung file như sau: 

```
<h2><%= @social_group.name.upcase %></h2>
<div class="button-action text-center">
  <% unless current_user.admin? %>
    <%= link_to "Rời Group", social_group_group_user_path(@social_group,
      @group_user), method: :delete, class: "btn btn-primary" %>
  <% end %>
</div>
<% if @social_group.member?(current_user) %>
  <div class="container">
    <div class="col-md-9">
    </div>
    <div class="col-md-3">
      <div class="group-member">
        <div class="heading text-center">
          Thành Viên <b>(<%= @social_group.members.count %>)</b></div>
        <div class="conten">
          <ul class="list-group">
            <% @social_group.members.each do |member| %>
              <li class="list-group-item"><%= member.name %></li>
            <% end %>
          </ul>
        </div>
      </div>
    </div>
  </div>
<% end %>
```
### Phần tham gia group và rời group
Với phần tham gia group, nút chức năng đã được bổ sung ở ngay phần trên, bây giờ ta sẽ xử lý, bây giờ ta sẽ xử lý phần controller, ý tưởng là khi người dùng click nút tham gia, nó sẽ tạo bản ghi trong bảng `group_users` với id của user và id của group. Chúng ta sẽ cùng xem file controller của group user.
```
class GroupUsersController < ApplicationController
  before_action :find_group, only: :create
  before_action :find_group_user, only: :destroy

  def create
    group_user = social_group.group_users.build user: current_user

    if group_user.save
      flash[:success] = "Da vao group"
      redirect_to social_group_path(social_group)
    else
      flash[:warning] = "Khong tim the tham gia grop"
      redirect_to social_groups_path
    end
  end

  private

  attr_reader :social_group, :group_user

  def find_group
    @social_group = SocialGroup.find_by id: params[:social_group_id]

    return if social_group
    flash[:warning] = "Khong tim thay group"
    redirect_to social_groups_path
  end
end
```
Tuy nhiên, khi admin tạo group, thì admin này không hề tham gia group đó, mà phải mất thêm một bước là Join group, như thế khá bất tiện, nên chúng ta sẽ viết một cái callback sau khi tạo group sẽ tự động add admin vào group luôn. Ở file `social_group.rb` chúng ta thêm các dong sau
```
  after_save :admin_join_group

  private

  def admin_join_group
    ActiveRecord::Base.transaction do
      User.admins.each do |admin|
        group_users.create! user: admin
      end
    end
  end
```

- Để rời group thì ta thêm method destroy vào file `app/controllers/group_users_controller.rb`
```
  def destroy
    if group_user.destroy
      flash[:success] = "Roi nhom thanh cong"
    else
      flash[:danger] = "Roi nhom that bai"
    end
    redirect_to social_groups_path
  end
```
Và method `find_group_user`, cho vào trạng thái `before_action`
```
  def find_group_user
    @group_user = GroupUser.find_by id: params[:id]

    return if group_user
    flash[:warning] = "Ban khong nam trong group nay"
    redirect_to social_groups_path
  end
```
Xong vậy là xử lý xong xuôi từ phần join lẫn leave group. Rất ez đúng không.

## Phần 3: Xử lý phần tạo micropost cho group
Đầu tiên ta cần thêm vào `routes.rb` dòng sau:
`resources :microposts, only: [:create, :destroy]` ở trong social_groups
Sau đó ta sửa lại model `micropost.rb` như sau:

```
class Micropost < ApplicationRecord
  ATTRIBUTE_PARAMS = %i(content picture user_id).freeze

  belongs_to :user
  belongs_to :social_group, optional: true

  validates :content, presence: true, length: {maximum:
    Settings.micropost_model.content_maximun}
  validate  :picture_size

  scope :order_time, ->{order created_at: :desc}
  scope :post_by_group_user, ->(user, group){where social_group: group, user: user}

  mount_uploader :picture, PictureUploader

  private

  def picture_size
    return unless picture.size > Settings.micropost_model.picture_maximun.megabytes
    errors.add :picture, t("model.micropost.picture_size")
  end
end
```
- Ở đây, trường `social_group_id` không nhất thiết phải có, nó sẽ có khi ta tạo bài viết trong group và không có khi ta tạo bài viết cá nhân. Khi tạo bài viết ở cá nhân, chúng ta không thể tạo được do nó yêu cầu social_group, vậy ta thêm `optional: true` vào phần của `social_group.` 
Sau đó chúng ta sẽ tạo form cho để tạo bài viết, tuy nhiên về cấu trúc của ta vẫn giữ nguyên nhưng tham gia số truyền vào đã thay đổi, việc cố sử dụng chung 1 form sẽ hơi khó khăn nên mình quyết định tách riêng ra và ta có file `app/views/social_groups/_micropost_form.html.erb` như sau:

```
<%= form_for [social_group, micropost] do |f| %>
  <%= render "shared/error_messages", object: f.object %>
  <div class="field">
    <%= f.text_area :content, placeholder: "Nhap bai viet" %>
  </div>
  <span class="picture">
    <%= f.file_field :picture, accept: "image/jpeg,image/gif,image/png" %>
  </span>
  <%= f.hidden_field :user_id, value: current_user.id %>
  <%= f.submit "Post", class: "btn btn-primary" %>
<% end %>
```
Hãy để ý ở đây ta bổ sung thêm trường ẩn `user_id` để truyền user_id khi tạo, như thế sẽ đảm bảo ý tưởng của ta như đã đề cập ở lúc tạo table.
Ok, bây giờ ta sẽ thêm nó vào phần show một group.
```
<h2><%= @social_group.name.upcase %></h2>
<div class="button-action text-center">
  <% unless current_user.admin? %>
    <%= link_to "Rời Group", social_group_group_user_path(@social_group,
      @support_group.group_user), method: :delete, class: "btn btn-primary" %>
  <% end %>
</div>
<% if @social_group.member?(current_user) %>
  <div class="container">
    <div class="col-md-9">
      <div class="post-index">
        <div class="input-post">
          <%= render "social_groups/micropost_form",
            micropost: @support_group.micropost || @support_group.new_group_micropost,
            social_group: @social_group %>
        </div>
        <div>
          <% if @support_group.group_microposts.any? %>
            <ol class="microposts">
              <%= render @support_group.group_microposts %>
            </ol>
          <% end %>
        </div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="group-member">
        <div class="heading text-center">
          Thành Viên <b>(<%= @social_group.members.count %>)</b></div>
        <div class="conten">
          <ul class="list-group">
            <% @social_group.members.each do |member| %>
              <li class="list-group-item"><%= member.name %></li>
            <% end %>
          </ul>
        </div>
      </div>
    </div>
  </div>
<% end %>
```
- Các biến truyền vào trong form yêu cầu là `social_group` và đối tượng micropost khởi tạo, ở đây ta dùng thêm kĩ thuật View Object để đảm bảo không truyền quá 2 biến intance qua view. Có một đoạn `@support_group.micropost || @support_group.new_group_micropost` để đảm bảo khi tạo bài viết fail nó sẽ trả lại bản tin thông báo lỗi cho form.
- Nói tới View Object thì chúng ta hãy xem cách tạo nó. Ta tạo file `app/models/supports/social_group_support.rb`
```
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
```
- Ở đây ta khởi tạo các biến qua hàm khởi tạo, khi cần tới method nào sẽ gọi method đó, ở đây có 2 hàm chính là hàm tạo đối tượng micropost từ social_group và hàm lấy tất cả bài viết của group đó. 
Ở đây `.feed` là một method ở model `social_group.rb`. Vì thế ta bổ sung thêm vào model các dòng sau:
```
    class SocialGroup < ApplicationRecord
      def feed
        microposts.order_time
      end
    end
```
- Và cuối cùng ta chỉnh sửa lại controller của micropost cho hợp lý cũng như bổ sung vào controller group_user biến @support_group như ở view.
`app/controllers/social_groups_controller.rb`
```
    class SocialGroupsController < ApplicationController

      def show
        group_user = current_user.group_users.find_by social_group: social_group

        return redirect_to social_groups_path unless group_user
        @support_group = Supports::SocialGroupSupport
          .new social_group: social_group, group_user: group_user
      end

    end
```
`app/controllers/microposts_controller.rb`
```
class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(create destroy)
  before_action :find_social_group, only: :create
  before_action :correct_user, only: :destroy

  def create
    @micropost = (social_group || current_user).microposts.build micropost_params
    if micropost.save
      flash[:success] = t "controllers.micropost.post_create"
      redirect_to request.referer || root_url
    else
      create_fail
    end
  end

  def destroy
    micropost.destroy
    flash[:success] = t "controllers.micropost.post_delete"
    redirect_to request.referer || root_url
  end

  private

  attr_reader :social_group, :micropost

  def micropost_params
    params.require(:micropost).permit Micropost::ATTRIBUTE_PARAMS
  end

  def correct_user
    @micropost = current_user.microposts.find_by id: params[:id]
    return if micropost
    redirect_to root_url
  end

  def find_social_group
    @social_group = SocialGroup.find_by id: params[:social_group_id]
  end

  def create_fail
    if social_group
      create_group_post_fail
    else
      @feed_items = current_user.feed.paginate page: params[:page]
      render "static_pages/home"
    end
  end

  def create_group_post_fail
    group_user = current_user.group_users.find_by social_group: social_group

    return redirect_to social_groups_path unless group_user
    @support_group = Supports::SocialGroupSupport
      .new social_group: social_group, group_user: group_user,
        micropost: micropost
    render "social_groups/show"
  end
end
```
Ở đây ta chỉ cần chú ý đôi chút đó là khi user rời khỏi group thì chúng ta cần xoá tất cả bài viết của họ đi vì thế ta lại sử dụng callback nhưng ở đây sẽ sử dụng ở `group_user.rb`, bởi hành động rời nhóm là việc xoá bản ghi ở đó.
ta thêm như sau:
```
class GroupUser < ApplicationRecord
  belongs_to :user
  belongs_to :social_group

  before_destroy :delete_post

  private

  def delete_post
    ActiveRecord::Base.transaction do
      Micropost.post_by_group_user(social_group, user).each(&:destroy!)
    end
  end
end
```
Còn một xíu nữa là phần css, chúng ta có thể coi sự thay đổi ở trong pull dưới đây nhé.
Vậy toàn bộ nội dung đã xong, toàn bộ thay đổi có thể coi [tại đây](https://github.com/tranhong216/new_app_toy/pull/17).