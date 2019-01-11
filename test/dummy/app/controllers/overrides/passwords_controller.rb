# frozen_string_literal: true

module Overrides
  class PasswordsController < DeviseTokenAuth::PasswordsController
    OVERRIDE_PROOF = '(^^,)'.freeze

    # this is where users arrive after visiting the email confirmation link
    def edit
      @devise_resource = resource_class.reset_password_by_token(
        reset_password_token: resource_params[:reset_password_token]
      )

      if @devise_resource && @devise_resource.id
        client_id, token = @devise_resource.create_token

        # ensure that user is confirmed
        @devise_resource.skip_confirmation! unless @devise_resource.confirmed_at

        @devise_resource.save!

        redirect_header_options = {
          override_proof: OVERRIDE_PROOF,
          reset_password: true
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
