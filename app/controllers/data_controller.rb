class DataController < ApplicationController
    def create
        @user = User.find(params[:user_id])
        @datum = @user.data.create(datum_param)
        redirect_to user_path(@user)
    end

    private
        def datum_param
            params.require(:datum).permit(:dataType, :dataName)
        end
end
