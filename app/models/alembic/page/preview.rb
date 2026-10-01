module Alembic
  class Page < ApplicationRecord
    module Preview
      mattr_accessor :provider

      def self.values_for(page, choice)
        provider ? provider.call(page, choice).to_h : {}
      end
    end
  end
end
