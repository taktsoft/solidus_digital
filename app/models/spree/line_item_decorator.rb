Spree::LineItem.class_eval do
  has_many :digital_links, :dependent => :destroy

  delegate :digital?, to: :variant, prefix: false

  # TODO: PMG - Shouldn't we only do this if the quantity changed?
  def create_digital_links
    raise "Missing line_item id!" unless persisted?
    raise "Unpersisted line_item changes!" if changes.present?
    raise "Order not complete!" unless order.complete?
    raise "Digital links already present!" if digital_links.present?

    #include master variant digitals
    master = variant.product.master
    if(master.digital?)
      create_digital_links_for_variant(master)
    end
    create_digital_links_for_variant(variant) unless variant.is_master
  end

  private

  def create_digital_links_for_variant(variant)
    variant.digitals.each do |digital|
      self.quantity.times do
        digital_links.create!(:digital => digital)
      end
    end
  end
end
