module ApplicationHelper
  def sort_link(label, column, base_path, sort_param:, dir_param:, current_sort:, current_direction:, extra_params: {})
    new_direction = current_sort == column && current_direction == 'asc' ? 'desc' : 'asc'
    if current_sort == column
      icon = current_direction == 'asc' ? ' ▲' : ' ▼'
    else
      icon = ''
    end
    query = extra_params.merge(sort_param => column, dir_param => new_direction).to_query
    link_to "#{label}#{icon}", "#{base_path}?#{query}"
  end
end
