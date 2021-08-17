class Admin::InvitationsController < Devise::InvitationsController
    private

    # def invite_resource
    #     resource_class.invite!(invite_params, current_inviter) do |invitable|
    #         invitable.add_role(:admin)
    #     end
    # end
end
