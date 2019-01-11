# frozen_string_literal: true

module DeviseTokenAuth
  class TokenValidationsController < DeviseTokenAuth::ApplicationController
    skip_before_action :assert_is_devise_resource!, only: [:validate_token]
    before_action :set_user_by_token, only: [:validate_token]
    # before_action :set_resource_by_devise_resource, only: [:validate_token]

    def validate_token
      # @devise_resource will have been set by set_user_by_token concern
      if @devise_resource
        yield @devise_resource if block_given?
        render_validate_token_success
      else
        render_validate_token_error
      end
    end

    protected

    def render_validate_token_success
      render json: {
        success: true,
        data: devise_resource_data(resource_json: @devise_resource.token_validation_response)
      }
    end

    def render_validate_token_error
      render_error(401, I18n.t('devise_token_auth.token_validations.invalid'))
    end
  end
end
