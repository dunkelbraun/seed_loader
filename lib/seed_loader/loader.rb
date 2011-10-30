module SeedLoader
  
  module Loader
    
    @@loaded_seeds = {}
    @@seeds_path = "/db/seeds"
    
    class << self

      def seeds_path
        @@seeds_path
      end
      
      def seeds_path=(file_path)
        @@seeds_path = file_path
      end

      def seed_files_to_db
        @@loaded_seeds = {}
        puts Dir.glob( self.seeds_path )
        Dir.glob( Rails.root.to_s + self.seeds_path + "/*" ).each { |file_path| load_seed_file(file_path) }
      end

      private

      def load_seed_file(file_path)
        mod, file_ext = model_and_extension_from_file_path(file_path)
        return if seeds_loaded_for_model?(mod)
        case file_ext
        when "yml"
          seed_data = YAML.load(ERB.new(IO.read(file_path)).result)
        end
        mod.delete_all
        mod.reset_autoincrement
        belongs_to_associations = mod.belongs_to_associations.map(&:name)
        seed_data.each do |seed_name,attrs|
          if belongs_to_associations.present?
            attrs.each do |key, val|
             if belongs_to_associations.include?(key.to_sym)
               association = mod.belongs_to_associations.detect { |association| association.name == key.to_sym}
               load_seed_for_model(association.name.to_s.classify.constantize)
               association_model = key.classify.constantize
               attrs[association_foreign_key(association)] = @@loaded_seeds[association_model.table_name][val]["id"]
               attrs.delete(key)
             end
            end
          end
          obj = mod.create(attrs)
          attrs["id"] = obj[:id]
        end
        @@loaded_seeds[mod.table_name] = seed_data
      end

      def seeds_loaded_for_model?(mod)
        @@loaded_seeds[mod.table_name].present?
      end

      def model_and_extension_from_file_path(file_path)
        match  = file_path.match(/\/(\w+)\.(yml)$/)
        [ match[1].classify.constantize, match[2] ]
      end

      def association_foreign_key(assoc)
        (assoc.options[:foreign_key] || assoc.association_foreign_key).to_s
      end

      def load_seed_for_model(mod)
        file_path = "#{Rails.root}/db/seeds/#{mod.table_name}.yml"
        load_seed_file file_path
      end

    end
    
  end
  
end