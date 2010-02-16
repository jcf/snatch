class String
  def quote(quote = '"')
    [quote, self, quote].map(&:to_s).join
  end
end