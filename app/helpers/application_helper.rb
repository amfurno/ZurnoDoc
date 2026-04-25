module ApplicationHelper
  def sort_link(label, column, base_path)
    new_direction = (@sort == column && @direction == "asc") ? "desc" : "asc"
    icon = if @sort == column
      @direction == "asc" ? " ▲" : " ▼"
    else
      ""
    end
    link_to "#{label}#{icon}", "#{base_path}?sort=#{column}&direction=#{new_direction}"
  end
end
