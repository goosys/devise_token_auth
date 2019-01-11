# frozen_string_literal: true

module DeviseTokenAuth
  class ConfirmationsController < DeviseTokenAuth::ApplicationController
    def show
      @devise_resource = devise_resource_class.confirm_by_token(params[:confirmation_token])

      if @devise_resource && @devise_resource.id
        expiry = nil
        if defined?(@devise_resource.sign_in_count) && @devise_resource.sign_in_count > 0
          expiry = (Time.zone.now + 1.second).to_i
        end

        client_id, token = @devise_resource.create_token expiry: expiry

        sign_in(@devise_resource)
        @devise_resource.save!

        yield @devise_resource if block_given?

        redirect_header_options = { account_confirmation_success: true }
        redirect_headers = build_redirect_headers(token,
                                                  client_id,
                                                  redirect_header_options)

        # give redirect value from params priority
        @redirect_url = params[:redirect_url]

        # fall back to default value if provided
        @redirect_url ||= DeviseTokenAuth.default_confirm_success_url


        redirect_to(@devise_resource.build_auth_url(@redirect_url, redirect_headers))
      else
        raise ActionController::RoutingError, 'Not Found'
      end
    end
  end
end
