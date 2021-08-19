class Admin::InvitationsController < Devise::InvitationsController
    private

        def invite_resource
            user = resource_class.invite!(invite_params, current_inviter)
            puts(user.raw_invitation_token)
            return user
        end
end
