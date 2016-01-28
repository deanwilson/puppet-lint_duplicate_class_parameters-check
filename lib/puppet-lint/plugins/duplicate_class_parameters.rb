PuppetLint.new_check(:duplicate_class_parameters) do
  def check
    class_indexes.each do |class_idx|
      seen = Hash.new(0)

      class_idx[:param_tokens].each do |token|
        class_name = class_idx[:name_token].value

        if token.type == :VARIABLE
          param_name = token.value
          seen[param_name] += 1

          if seen[param_name] > 1
            # warning output shows the parameter location each additional time it's seen
            notify :warning, {
              :message => "found duplicate parameter '#{param_name}' in class '#{class_name}'",
              :line    => token.line,
              :column  => token.column,
            }
          end

        end
      end
    end
  end
end
