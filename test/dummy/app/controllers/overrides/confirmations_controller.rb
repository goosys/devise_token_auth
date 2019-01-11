# frozen_string_literal: true

module Overrides
  class ConfirmationsController < DeviseTokenAuth::ConfirmationsController
    def show
      @devise_resource = resource_class.confirm_by_token(params[:confirmation_token])

      if @devise_resource && @devise_resource.id
        client_id, token = @devise_resource.create_token
        @devise_resource.save!

        redirect_header_options = {
          account_confirmation_success: true,
          config: params[:config],
          override_proof: '(^^,)'
        }
        redirect_headers = build_redirect_headers(token,
                                                  client_id,
                                                  redirect_header_options)

        redirect_to(@devise_resource.build_auth_url(params[:redirect_url],
                                             redirect_headers))
      else
        raise ActionController::RoutingError, 'Not Found'
      end
    end
  end
end
