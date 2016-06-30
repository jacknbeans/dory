require 'colorize'

module Dory
  module Resolv
    def self.get_module
      return Dory::Resolv::Macos if Os.macos?
      Dory::Resolv::Linux
    end

#    def self.method_missing(method_sym, *arguments, &block)
#      self.get_module.send(method_sym, arguments, &block)
#    end

#    def self.respond_to?(method_sym, include_private = false)
#      self.get_module.respond_to?(method_sym, include_private)
#    end

    def self.has_our_nameserver?
      self.get_module.has_our_nameserver?
    end

    def self.configure
      self.get_module.configure
    end

    def self.clean
      self.get_module.clean
    end
  end
end
