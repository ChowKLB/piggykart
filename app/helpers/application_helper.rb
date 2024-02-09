module ApplicationHelper
  def title(page_title)
    content_for(:title) { page_title }
  end

  def header_title(page_title)
    content_for(:header_title) { page_title }
  end

  def permitted_accountable_partial(name)
    name.underscore
  end

  # Wrap view with <%= modal do %> ... <% end %> to have it open in a modal
  # Make sure to add data-turbo-frame="modal" to the link/button that opens the modal
  def modal(&block)
    content = capture &block
    render partial: "shared/modal", locals: { content: content }
  end

  def format_currency(number, options={})
    user_currency_preference = Current.family.try(:currency) || 'USD'
    
    case user_currency_preference
    when 'USD'
      options.reverse_merge!(unit: '$', precision: 2, delimiter: ',', separator: '.')
    when 'EUR'
      options.reverse_merge!(unit: '€', precision: 2, delimiter: '.', separator: ',')
    when 'GBP'
      options.reverse_merge!(unit: '£', precision: 2, delimiter: ',', separator: '.')
      # Add more currencies and their formatting options as needed
    else
      # Can also set to a default or retrieve a default from somewhere else
    end

    number_to_currency(number, options)
  end
end
