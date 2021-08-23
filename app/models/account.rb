class Account < ApplicationRecord
  after_create :assign_default_role

  rolify :role_cname => 'AccountRole'
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable, :lockable

  include DeviseInvitable::Inviter
  
  def assign_default_role
      if not has_any_role?(:admin, :producer, :user)
        add_role("user")
      end
      name = String(self.email).split("@")[0]
      un = User.new(username: name, password_digest: self.encrypted_password, role_id: 3, account_id: self.id)
      un.save()
  end
end
