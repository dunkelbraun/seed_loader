module SeedLoader
  
  module ActiveRecordMethods
  
    def self.included(mod)
      raise "reset_autoincrement already defined in ActiveRecord::Base" if ActiveRecord::Base.methods.include?('reset_autoincrement')
      raise "belongs_to_associations_names already defined in ActiveRecord::Base" if ActiveRecord::Base.methods.include?('belongs_to_associations_names')
      raise "belongs_to_associations already defined in ActiveRecord::Base" if ActiveRecord::Base.methods.include?('belongs_to_associations')  
      mod.extend ClassMethods
    end
    
    module ClassMethods
      
      def reset_autoincrement(options={})
        options[:to] ||= 1
        case self.connection.adapter_name
          when 'MySQL'
            self.connection.execute "ALTER TABLE #{self.table_name} AUTO_INCREMENT=#{options[:to]}"
          when 'Mysql2'
            self.connection.execute "ALTER TABLE #{self.table_name} AUTO_INCREMENT=#{options[:to]}"
          when 'PostgreSQL'
            self.connection.execute "ALTER SEQUENCE #{self.table_name}_id_seq RESTART WITH #{options[:to]};"
          when 'SQLite'
            self.connection.execute "UPDATE sqlite_sequence SET seq=#{options[:to]-1} WHERE name='#{self.table_name}';"
          else
        end
      end

      def belongs_to_associations_names
        self.belongs_to_associations.map(&:name)
      end

      def belongs_to_associations
        self.reflect_on_all_associations.find_all {|association| association.macro == :belongs_to}
      end
      
    end
  
  end

end



class ActiveRecord::Base
  
  include SeedLoader::ActiveRecordMethods
    
end
