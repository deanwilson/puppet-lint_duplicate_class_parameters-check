PuppetLint.new_check(:duplicate_class_parameters) do
  def check
    class_indexes.each do |class_idx|
      seen = Hash.new(0)
      inside = nil
      level = 0

      # if there are no params there is nothing to do, return early.
      next if class_idx[:param_tokens].nil?

      class_idx[:param_tokens].each do |token|
        class_name = class_idx[:name_token].value

        case token.type
        when :LBRACK, :LBRACE
          level += 1
        when :RBRACK, :RBRACE
          level -= 1
        end

        next unless level.zero?
        next unless token.type == :VARIABLE

        next_type = token.next_code_token.type

        # handling for lines with an equals and a variable on the rhs
        if next_type == :EQUALS
          inside = true

          two_away = token.next_code_token.next_code_token.type
          if two_away == :DQPRE
            inside = false
          end
        elsif next_type == :COMMA
          inside = false
        end

        # only proceed if we're at the end of a declaration.
        next unless inside

        param_name = token.value
        seen[param_name] += 1

        next unless seen[param_name] > 1

        # warning output shows the parameter location each additional time it's seen
        notify :warning, {
          message: "found duplicate parameter '#{param_name}' in class '#{class_name}'",
          line:    token.line,
          column:  token.column,
        }
      end
    end
  end
end
