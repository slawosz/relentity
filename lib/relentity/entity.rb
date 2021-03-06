module Relentity module Entity

  module ClassMethods

    def entity_pool entity_pool = nil
      @entity_pool ||= entity_pool
    end

  end

  def id
    @properties[:id]
  end

  def initialize hash = {}
    @properties ||= {}
    @properties = @properties.merge hash
    self.class.entity_pool << self if self.class.entity_pool
  end

  def method_missing method, *args, &block
    if method =~ /=$/
      @properties[method[0...-1].to_sym] = args.first
      self.class.entity_pool << self if self.class.entity_pool
    else
      @properties[method] or super
    end
  end

  def related
    EntityRels.new self
  end

  private

  def self.included receiver
    receiver.extend ClassMethods
  end

end end
