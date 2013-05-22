module ApplicationHelper

  def main_title(title)
    content_for :main_title do 
      title
    end
  end

end
