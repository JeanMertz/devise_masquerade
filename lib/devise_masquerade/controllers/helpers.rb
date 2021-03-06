module DeviseMasquerade
  module Controllers
    module Helpers
      def self.define_helpers(mapping)
        name = mapping.name

        class_eval <<-METHODS, __FILE__, __LINE__ + 1
          def masquerade_#{name}!
            return if params[:masquerade].blank?

            #{name} = #{name.to_s.classify}.find_by_masquerade_key(params[:masquerade])

            sign_in #{name} if #{name}
          end

          def #{name}_masquerade?
            session[:"devise_masquerade_#{name}"].present?
          end
        METHODS

        ActiveSupport.on_load(:action_controller) do
          helper_method "#{name}_masquerade?"
        end
      end
    end
  end
end

ActionController::Base.send(:include, DeviseMasquerade::Controllers::Helpers)
