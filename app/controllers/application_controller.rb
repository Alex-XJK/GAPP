class ApplicationController < ActionController::Base

    def after_invite_path_for(param1, param2)
        "/admin/users/invite/" + String(param2.raw_invitation_token)
    end

    def after_sign_in_path_for(acc)
        if acc.roles.first.name == "user"
            user_path(User.find_by(account_id: current_account.id).id)
        else 
            if acc.roles.first.name == "producer"
                "/apps"
            else
                "/admin"
            end
        end
    end

    def after_sign_out_path_for(acc)
        request.referrer
    end


    protected

        def authenticate_inviter!
            authenticate_account!(force: true)
            require_admin
            super
        end

        def require_admin
            unless account_signed_in? and current_account.has_role? :admin
              flash[:error] = "You must be an admin to access this page. (Current role: " + current_account.roles.first.name + ")"
              redirect_to "/" # halts request cycle
            end
        end

end
