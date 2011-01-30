module Relentity describe Persistence::YAMLStore::EntityPool do

  before :all do
    module YAMLStorePeople
      extend Persistence::YAMLStore::EntityPool
    end
    class YAMLStorePerson
      include Entity
      entity_pool YAMLStorePeople
    end
  end

  before :each do
    @root = Dir.mktmpdir
    YAMLStorePeople.root = @root
  end

  after :each do
    FileUtils.rmtree @root
  end

  describe '.add' do

    it 'saves the passed entity to the YAMLStore, creating it if necessary' do
      File.exists?("#{@root}/Relentity::YAMLStorePeople.yml").should be_false
      YAMLStorePerson.new id: :sandra, given_names: ['Sandra'], surname: 'Battye'
      File.exists?("#{@root}/Relentity::YAMLStorePeople.yml").should be_true
      File.read("#{@root}/Relentity::YAMLStorePeople.yml").should == File.read('spec/fixtures/persistence/yaml_store/entity_pool.add.yml')
    end

  end

  describe '.id' do

    it 'returns the Entity with the given id' do
      FileUtils.cp 'spec/fixtures/persistence/yaml_store/entity_pool.id.yml', "#{@root}/Relentity::YAMLStorePeople.yml"
      YAMLStorePeople.id(:sam).surname.should       == 'Vimes'
      YAMLStorePeople.id(:sybil).given_names.should include 'Deirdre'
      YAMLStorePeople.id(:auditor).should           be_nil
    end

  end

  describe '.root=' do

    it 'stores the root dir and repoints the pool' do
      module YAMLStoreRootPool; extend Persistence::YAMLStore::EntityPool; end
      class YAMLStoreRootEntity; include Entity; end
      2.times do
        Dir.mktmpdir do |root|
          File.exists?("#{root}/Relentity::YAMLStoreRootPool.yml").should be_false
          YAMLStoreRootPool.root = root
          YAMLStoreRootPool.add YAMLStoreRootEntity.new
          File.exists?("#{root}/Relentity::YAMLStoreRootPool.yml").should be_true
        end
      end
    end

  end

  describe '.select' do

    it 'returns Entities fulfilling the given block' do
      FileUtils.cp 'spec/fixtures/persistence/yaml_store/entity_pool.id.yml', "#{@root}/Relentity::YAMLStorePeople.yml"
      YAMLStorePeople.select { |p| p.surname             == 'Vimes' }.map(&:id).should == [:sam, :sybil]
      YAMLStorePeople.select { |p| p.given_names.include? 'Deirdre' }.map(&:id).should == [:sybil]
    end

  end

  describe '.update' do

    it 'saves the passed entity to the YAMLStore' do
      FileUtils.cp 'spec/fixtures/persistence/yaml_store/entity_pool.add.yml', "#{@root}/Relentity::YAMLStorePeople.yml"
      sandra = YAMLStorePeople.id :sandra
      sandra.occupation = 'seamstress'
      File.read("#{@root}/Relentity::YAMLStorePeople.yml").should == File.read('spec/fixtures/persistence/yaml_store/entity_pool.update.yml')
    end

  end

end end