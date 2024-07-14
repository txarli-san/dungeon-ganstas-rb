class OutputFormatter
  def format_description(description)
    description.gsub("\n", "\r\n")
  end

  def format_result(result)
    result.gsub("\n", "\r\n")
  end
end
