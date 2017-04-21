Spree::LineItem.class_eval do
  has_many :digital_links, :dependent => :destroy
  after_save :create_digital_links, :if => :variant_digital_and_order_complete?

  delegate :digital?, to: :variant, prefix: false
  delegate :complete?, to: :order, prefix: true


  private

  def variant_digital_and_order_complete?
    variant.digital? && order.complete?
  end

  # TODO: PMG - Shouldn't we only do this if the quantity changed?
  def create_digital_links
    digital_links.delete_all

    #include master variant digitals
    master = variant.product.master
    if(master.digital?)
      create_digital_links_for_variant(master)
    end
    create_digital_links_for_variant(variant) unless variant.is_master
  end

  def create_digital_links_for_variant(variant)
    variant.digitals.each do |digital|
      self.quantity.times do
        digital_links.create!(:digital => digital)
      end
    end
  end
end
