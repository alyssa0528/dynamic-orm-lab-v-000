require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'
require 'pry'

class Student < InteractiveRecord

def attr_accessor
  #binding.pry
  self.column_names.each do |column_name|

  binding.pry
    attr_accessor column_name.to_sym
  end
end

end
