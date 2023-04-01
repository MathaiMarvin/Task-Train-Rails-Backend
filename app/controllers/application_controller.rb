class ApplicationController < ActionController::API
    include ActionController::Cookies
    rescue_from StandardError, with: :standard_error

    def app_response(message: "success", status: 200, data:nil)

        render json:{
            message: message,
            data: data
        }, status: status
    end

    # Hash data into web token
    def encode(uid, email)
        payload = {
            data:{
                uid: uid,
                email: email
            },
            exp: (6.hours.from_now).to_i
        }
        begin
        JWT.encode(payload, ENV['task_train_key'], 'HS256')
        rescue JWT::EncodeError =>e
            app_response(message: 'failed', status:400, data: {info: "Something went wrong. Please try again"})
        end

    end

    # Verifu authorization headers

    def verify_auth
        auth_headers = request.headers['Authorization']
        if !auth_headers
            app_response(message: 'failed', status:401, data: {info: "Your request is not authorized"})
        else

            token = auth_headers.split(' ')[1]
            save_user_id(token)
            # render json:{
            #     data: decode(token)[0]("data")
            # }
        end
    end

    # request={

    #     headers:{
    #         Authorization: 'Bearer ' + request.headers['Authorization']
    #     },
    #     body:{

    #     },
    #     method:"GET"
    # }
    # Unhash Token
    def decode(token)
        begin
        JWT.decode(ENV['task_train_key'], token, true, {algorithm: 'HS256'})

        rescue JWT::DecodeError => e
            app_response(message: 'failed', status:401, data: {info: "Your session has expired. Please login again to continue"})
        end
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
       User.find(@uid)
    end


    def save_user_id(token)
        @uid= decode(token)[0]["data"]["uid"].to_i
    end
    # get logged in session
    def user_session
        User.find(session[:uid].to_i)
     end

    # Rescue all ccommon errors
    def standard_error(exception)
        app_response(message: "failed", data: {info: exception.message}, status: :unprocessable_entity)
    end
end
