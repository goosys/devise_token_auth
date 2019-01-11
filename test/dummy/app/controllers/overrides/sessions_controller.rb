# frozen_string_literal: true

module Overrides
  class SessionsController < DeviseTokenAuth::SessionsController
    OVERRIDE_PROOF = '(^^,)'.freeze

    def create
      @devise_resource = resource_class.find_by(email: resource_params[:email])

      if @devise_resource && valid_params?(:email, resource_params[:email]) && @devise_resource.valid_password?(resource_params[:password]) && @devise_resource.confirmed?
        @client_id, @token = @devise_resource.create_token
        @devise_resource.save

        render json: {
          data: @devise_resource.as_json(except: %i[tokens created_at updated_at]),
          override_proof: OVERRIDE_PROOF
        }

      elsif @devise_resource && (not @devise_resource.confirmed?)
        render json: {
          success: false,
          errors: [
            "A confirmation email was sent to your account at #{@devise_resource.email}. "\
            'You must follow the instructions in the email before your account '\
            'can be activated'
          ]
        }, status: 401

      else
        render json: {
          errors: ['Invalid login credentials. Please try again.']
        }, status: 401
      end
    end
  end
end
