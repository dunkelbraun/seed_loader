require 'test_helper'

class MysqlDummyUser < ActiveRecord::Base  
end

class PostgresDummyUser < ActiveRecord::Base  
end


class SeedLoaderTest < ActiveSupport::TestCase
  
  def setup
    SeedLoader::Loader.seeds_path = "/db/seeds"
  end
  
  test "belongs to associations" do
    associations = DummyTable.belongs_to_associations
    assert_equal 1, associations.length
    assert_equal :dummy_user, associations[0].name
  end

  test "seeds path" do
    assert_equal "/db/seeds", SeedLoader::Loader.seeds_path
  end
  
  test "seeds path change" do
    new_seeds_path = "/lib/seeds"
    SeedLoader::Loader.seeds_path = new_seeds_path
    assert_equal new_seeds_path, SeedLoader::Loader.seeds_path
  end

  test "loading seed files into the database" do
    Dir.glob(File.dirname(__FILE__) + '/seeds/*').each { |file| FileUtils.cp file, File.dirname(__FILE__) + '/dummy/db/seeds' }
    SeedLoader::Loader.seed_files_to_db
    assert_equal 3, DummyUser.all.length
    assert_equal 3, DummyTable.all.length    
  end

  test "reset autoincrement" do
    DummyUser.create(:name => "AnotherTestUser")
    DummyUser.delete_all
    DummyUser.reset_autoincrement
    dummy_user = DummyUser.create(:name => "AnotherTestUser")
    assert_equal 1, dummy_user[:id]
  end
  
  test "reset autoincrement mysql" do
    connection_options = {  
      :adapter  => 'mysql2',  
      :host     => 'localhost',  
      :database => 'mysql',  
      :username => 'root' }  
    ActiveRecord::Base.establish_connection connection_options
    ActiveRecord::Base.connection.create_database 'seed_loader_dummy_database', :charset => 'utf8', :collation => 'utf8_unicode_ci' rescue nil
    ActiveRecord::Base.establish_connection connection_options.merge({:database => 'seed_loader_dummy_database'})
    begin
      ActiveRecord::Base.connection.create_table 'mysql_dummy_users' do |t|
        t.string :name
      end
    rescue
      nil
    end
    MysqlDummyUser.create(:name => "AnotherTestUser")
    MysqlDummyUser.delete_all
    MysqlDummyUser.reset_autoincrement
    dummy_user = MysqlDummyUser.create(:name => "AnotherTestUser")
    assert_equal 1, dummy_user[:id]
    ActiveRecord::Base.connection.drop_table 'mysql_dummy_users'
    ActiveRecord::Base.connection.drop_database 'seed_loader_dummy_database'
    ActiveRecord::Base.establish_connection :test
  end

  test "reset autoincrement postgres" do
    connection_options = {:adapter  => 'postgresql', :host => 'localhost', :database => 'postgres', :username => 'marcessindi', :min_messages => "WARNING" }
    ActiveRecord::Base.establish_connection connection_options
    ActiveRecord::Base.connection.create_database 'seed_loader_dummy_database' rescue nil
    ActiveRecord::Base.establish_connection connection_options.merge({:database => 'seed_loader_dummy_database'})
    begin
      ActiveRecord::Base.connection.create_table 'postgres_dummy_users' do |t|
        t.string :name
      end
    rescue
      nil
    end
    PostgresDummyUser.create(:name => "AnotherTestUser")
    PostgresDummyUser.delete_all
    PostgresDummyUser.reset_autoincrement
    dummy_user = PostgresDummyUser.create(:name => "AnotherTestUser")
    assert_equal 1, dummy_user[:id]
    ActiveRecord::Base.connection.drop_table 'postgres_dummy_users'
    ActiveRecord::Base.establish_connection connection_options
    ActiveRecord::Base.connection.drop_database 'seed_loader_dummy_database'
    ActiveRecord::Base.establish_connection :test
  end

end