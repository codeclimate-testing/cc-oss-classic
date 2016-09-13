class Complex
  def self.clean(text, opts = {})
    # Replace !!!!! with a single !
    text.gsub!(/!+/, '!') if opts[:deduplicate_exclamation_marks]
    # Replace ????? with a single ?
    text.gsub!(/\?+/, '?') if opts[:deduplicate_question_marks]
    # Replace all-caps text with regular case letters
    text.tr!('A-Z', 'a-z') if opts[:replace_all_upper_case] && (text =~ /[A-Z]+/) && (text == text.upcase)
    # Capitalize first letter, but only when entire first word is lowercase
    text.sub!(/\A([a-z]*)\b/) { |first| first.capitalize } if opts[:capitalize_first_letter]
    # Remove unnecessary periods at the end
    text.sub!(/([^.])\.+(\s*)\z/, '\1\2') if opts[:remove_all_periods_from_the_end]
    # Remove extraneous space before the end punctuation
    text.sub!(/\s+([!?]\s*)\z/, '\1') if opts[:remove_extraneous_space]
    # Fixes interior spaces
    text.gsub!(/ +/, ' ') if opts[:fixes_interior_spaces]
    # Normalize whitespaces
    text = normalize_whitespaces(text)
    # Strip whitespaces
    text.strip! if opts[:strip_whitespaces]

    text
  end

  def search
    filter_mapping = {"cost" => "rcost", "quality" => "rquality", "time" => "rtime", "experience" => "rexperience", "communication" => "rcommunication"}
    render :index
  end
end
