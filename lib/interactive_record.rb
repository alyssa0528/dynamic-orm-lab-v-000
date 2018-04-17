require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names #essentially the attr_accessors
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []

    table_info.each do |column|
      column_names << column["name"]
    end

    column_names.compact
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  #self = the instance. add #class and then call on #table_name class method from above to have it work in an instance
  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|column_name| column_name == "id"}.join(", ")
  end

  def values_for_insert
    values = []

    self.class.column_names.each do |column_name|
      values << "'#{send(column_name)}'" unless send(column_name).nil?
    end

    values.join(", ")
  end

  #INSERT INTO table_name (column_name) VALUES value, value
  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
      SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = ?"

    DB[:conn].execute(sql, name)
  end

  #argument will be a key: value pair
  def self.find_by(attribute_hash)
    #binding.pry
    sql = "SELECT * FROM #{table_name} WHERE #{attribute_hash.keys.first} = #{attribute_hash.values.first}"
    #binding.pry
    DB[:conn].execute(sql)
  end
end
