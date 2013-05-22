class Node < ActiveRecord::Base

  acts_as_nested_set dependent: :destroy
  
  belongs_to :parent, class_name: 'Node'
  attr_accessible :lft, :name, :rgt, :parent_id
  
  alias_method :nodes, :children

  default_scope order: "#{self.quoted_table_name}.#{quoted_left_column_name}"

end
