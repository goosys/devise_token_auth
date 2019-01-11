# frozen_string_literal: true

module DeviseTokenAuth
  class UnlocksController < DeviseTokenAuth::ApplicationController
    skip_after_action :update_auth_header, only: [:create, :show]

    # this action is responsible for generating unlock tokens and
    # sending emails
    def create
      return render_create_error_missing_email unless resource_params[:email]

      @email = get_case_insensitive_field_from_resource_params(:email)
      @devise_resource = find_devise_resource(:email, @email)

      if @devise_resource
        yield @devise_resource if block_given?

        @devise_resource.send_unlock_instructions(
          email: @email,
          provider: 'email',
          client_config: params[:config_name]
        )

        if @devise_resource.errors.empty?
          return render_create_success
        else
          render_create_error @devise_resource.errors
        end
      else
        render_not_found_error
      end
    end

    def show
      @devise_resource = devise_resource_class.unlock_access_by_token(params[:unlock_token])

      if @devise_resource && @devise_resource.id
        client_id, token = @devise_resource.create_token
        @devise_resource.save!
        yield @devise_resource if block_given?

        redirect_header_options = { unlock: true }
        redirect_headers = build_redirect_headers(token,
                                                  client_id,
                                                  redirect_header_options)
        redirect_to(@devise_resource.build_auth_url(after_unlock_path_for(@devise_resource),
                                             redirect_headers))
      else
        render_show_error
      end
    end

    private
    def after_unlock_path_for(resource)
      #TODO: This should probably be a configuration option at the very least.
      '/'
    end

    def render_create_error_missing_email
      render_error(401, I18n.t('devise_token_auth.unlocks.missing_email'))
    end

    def render_create_success
      render json: {
        success: true,
        message: I18n.t('devise_token_auth.unlocks.sended', email: @email)
      }
    end

    def render_create_error(errors)
      render json: {
        success: false,
        errors: errors
      }, status: 400
    end

    def render_show_error
      raise ActionController::RoutingError, 'Not Found'
    end

    def render_not_found_error
      render_error(404, I18n.t('devise_token_auth.unlocks.user_not_found', email: @email))
    end

    def resource_params
      params.permit(:email, :unlock_token, :config)
    end
  end
end
