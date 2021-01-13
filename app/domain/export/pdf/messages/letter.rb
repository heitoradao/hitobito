# frozen_string_literal: true

#  Copyright (c) 2020, CVP Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Export::Pdf::Messages
  class Letter

    def initialize(letter, recipients, options = {})
      @letter = letter
      @recipients = recipients
      @options = options
    end

    def render
      pdf = Prawn::Document.new(render_options)
      customize(pdf)
      @recipients.each do |recipient|
        sections.each { |section| section.new(pdf, @letter, self).render(recipient) }
        pdf.start_new_page unless last?(recipient)
      end
      pdf.render
    end

    def filename
      parts = [@letter.subject.parameterize(separator: '_')]
      parts << %w(preview) if preview?
      [parts.join('-'), :pdf].join('.')
    end

    private

    def render_options
      preview_option.to_h.merge(
        page_size: 'A4',
        page_layout: :portrait,
        margin: 2.cm
      )
    end

    def preview_option
      { background: Settings.messages.pdf.preview } if preview?
    end

    def customize(pdf)
      pdf.font_size 9
      pdf
    end

    def last?(recipient)
      @recipients.last == recipient
    end

    def sections
      [Header, Content]
    end

    def preview?
      @options[:preview]
    end
  end

end
