class Admin::InvitationsController < Devise::InvitationsController
    private

        def invite_resource
            # user = resource_class.invite!(invite_params, current_inviter) do 
            # puts(user.raw_invitation_token)
            # return user
            super { |user| user.skip_invitation = true }
        end
end
