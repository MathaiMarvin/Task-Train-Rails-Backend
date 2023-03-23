class ApplicationController < ActionController::API
    include ActionController::Cookies

    def app_response(message: "success", status: 200, data:nil)

        render json:{
            message: message,
            data: data
        }, status: status
    end

    # Store user id in session

    def save_user(id)
        session[:uid] = id
        session[:expiry] = 6.hours.from_now
    end

    # Delete user id in session
    def remove_user
        session.delete(:uid)
        session[:expiry] = Time.now
    end


    #Check for session expiry
    def session_expired?

        session[:expiry] ||= Time.now
        time_diff = (Time.parse(session[:expiry]) - Time.now).to_i
        # time_diff <= 0
        unless time_diff > 0
            app_response(message: 'failed', status:401, data: {info: "Your session has expired. Please login again to continue"})
        end
    end

    # get logged in user id
    def user
       User.find(session[:uid].to_i)
    end
end
