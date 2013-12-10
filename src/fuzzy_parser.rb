class FuzzyParser
  def self.parse_rules array
    # todo refactor - getting ugly
    rules = []
    array.each do |r|
      rule = FuzzyRule.new
      r['if'].each_pair do |k, v|
        rule.add(k, v[0], v[1])
      end
      r['then'].each_pair do |k, v|
        if v[0].respond_to? :each # if array in array then multiple results
          v.each do |t|
            rule.add_result(k, t[0], t[1])
          end
        else
          rule.add_result(k, v[0], v[1])
        end
      end
      rules << rule
    end
    rules
  end

end