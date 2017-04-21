module Spree
  class Digital < ActiveRecord::Base
    belongs_to :variant
    has_many :digital_links, dependent: :destroy

    # use a directory which can be symlinked to the app's shared directory and therefore survive standard Capistrano deployments
    has_attached_file :attachment, path: ":rails_root/private/system/digitals/:id/:basename.:extension"
    do_not_validate_attachment_file_type :attachment
    validates_attachment_presence :attachment

    if Paperclip::Attachment.default_options[:storage] == :s3
      attachment_definitions[:attachment][:s3_permissions] = :private
      attachment_definitions[:attachment][:s3_headers] = { :content_disposition => 'attachment' }
    end
  end
end
