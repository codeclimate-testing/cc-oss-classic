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
    @filters = params[:filter].split(",") rescue []
    @sort = params[:sort]

    @users = @users.where('user_type = ?', @user_type) if @user_type.present?
    @users = @users.where('user_skills.skill_id in (?)', @skills.map(&:to_i)) if @skills.present? && @skills.size > 0
    @users = @users.where('availability = ?', @availability) if @availability.present?
    @users = @users.where('location_country = ?', @location) if @location.present?
    @users = @users.where('rate < ?', @max_rate.to_i) if @max_rate.present?
    @users = @users.page(params[:page]).per(PER_PAGE)

    @filters.each do |f|
      if filter_mapping.keys.include?(f)
        @users = @users.order("#{filter_mapping[f]} desc")
      end
    end

    @users = @users.order('id asc') if @filters.empty?
    @advanced_link = @location.blank? && @max_rate.blank? && @availability.blank?
    render :index
  end
end
