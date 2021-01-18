module MessagesHelper

  def add_message_button(type, path = path_args(model_class))
    label = [type.model_name.human, ti(:"link.add").downcase].join(' ')
    action_button(label,
                  new_polymorphic_path(path, message: { type: type }),
                  'plus')
  end

  def message_placeholders
    Export::Pdf::Messages::Letter::Content.placeholders.map { |p| "{#{p}}" }.join(', ')
  end

  def format_message_type(message)
    message.type.constantize.model_name.human if message.type
  end

  def format_message_recipients_total(message)
    message.recipients_total.to_s
  end

end
