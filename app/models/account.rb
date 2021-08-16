class Account < ApplicationRecord
  after_create :assign_default_role

  rolify :role_cname => 'AccountRole'
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable, :lockable
  
  def assign_default_role
      add_role("user")
  end
end
