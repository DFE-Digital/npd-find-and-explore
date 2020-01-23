# frozen_string_literal: true

require 'active_support/concern'

module SanitizeSpace
  extend ActiveSupport::Concern

  included do
    before_save :sanitise_spaces
  end

private

  SPACES = /[\u00A0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u202F\u205F\u3000\s]/.freeze

  def sanitise_spaces
    self.name = name&.gsub(SPACES, ' ')
    self.description = description&.gsub(SPACES, ' ')
  end
end
