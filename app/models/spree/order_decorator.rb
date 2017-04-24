Spree::Order.class_eval do
  after_save :ensure_digital_links_present, if: [:complete?, :some_digital?]

  # all products are digital
  def digital?
    line_items.all? { |item| item.digital? }
  end

  def some_digital?
    line_items.any? { |item| item.digital? }
  end

  def digital_line_items
    line_items.select(&:digital?)
  end

  def digital_links
    digital_line_items.map(&:digital_links).flatten
  end

  def reset_digital_links!
    digital_links.each do |digital_link|
      digital_link.reset!
    end
  end

  private

  def ensure_digital_links_present
    if complete? && some_digital?
      digital_line_items.each do |line_item|
        line_item.digital_links.clear if line_item.digital_links.count != line_item.quantity
        line_item.create_digital_links unless line_item.digital_links.present?
      end
    end
  end
end
