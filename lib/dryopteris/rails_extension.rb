require "dryopteris"

module Dryopteris
  module RailsExtension
    def self.included(base)
      base.extend(ClassMethods)
      
      base.class_eval do
        class_inheritable_reader :dryopteris_options
      end
    end

    module ClassMethods
      def sanitize_fields(options = {})
        before_save :sanitize_fields
        write_inheritable_attribute(:dryopteris_options, {
          :only       => (options[:only] || []),
          :except     => (options[:except] || []),
          :allow_tags => (options[:allow_tags] || [])
        })
      end
      
      alias_method :sanitize_field, :sanitize_fields
    end

      
    def sanitize_fields
      self.class.columns.each do |column|
        next unless (column.type == :string || column.type == :text)

        field = column.name.to_sym
        value = self[field]

        if dryopteris_options && dryopteris_options[:except].include?(field)
          next
        elsif dryopteris_options && !dryopteris_options[:only].empty? && !dryopteris_options[:only].include?(field)
          next
        elsif dryopteris_options && dryopteris_options[:allow_tags].include?(field)
          self[field] = Dryopteris.sanitize(value)
        else
          self[field] = Dryopteris.strip_tags(value)
        end
      end
      
    end
    
  end
end
