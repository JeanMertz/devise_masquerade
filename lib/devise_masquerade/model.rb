module Devise
  module Models
    module Masqueradable
      def self.included(base)
        base.class_eval do
          attr_reader :masquerade_key

          include InstanceMethods
          extend ClassMethods
        end
      end

      module InstanceMethods
        def masquerade!
          @masquerade_key = SecureRandom.base64(Devise.masquerade_key_size)

          Rails.cache.write("#{self.class.name.pluralize.downcase}:#{@masquerade_key}:masquerade", id, :expires_in => Devise.masquerade_expires_in)
        end
      end

      module ClassMethods
        def cache_masquerade_key_by(key)
          "#{self.name.pluralize.downcase}:#{key}:masquerade"
        end

        def remove_masquerade_key!(key)
          Rails.cache.delete(cache_masquerade_key_by(key))
        end

        def find_by_masquerade_key(key)
          id = Rails.cache.read(cache_masquerade_key_by(key))

          # clean up the cached masquerade key value
          remove_masquerade_key!(key)

          find_by_id(id)
        end
      end # ClassMethods
    end
  end
end

