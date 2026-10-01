module Alembic
  class Page < ApplicationRecord
    module Preview
      mattr_accessor :provider, :chooser

      def self.values_for(page, choice)
        provider ? provider.call(page, choice).to_h : {}
      end

      def self.choices_for(page)
        chooser ? chooser.call(page).to_a : []
      end
    end
  end
end
