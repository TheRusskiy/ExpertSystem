class FuzzyParser
  def self.parse_rules array
    parser = FuzzyParser.new array
    parser.parse
  end

  def initialize array
    @array = array
  end

  def parse
    @counter||=0
    # todo refactor - getting ugly
    @rules = []
    @array.each do |r|
      rule = FuzzyRule.new
      depth = 0
      r['if'].each_pair do |k, v|
        depth+=1
        @counter+=1
        mark = depth <= 2 ? '' : "@#{existing_mark(rule) || @counter}@"
        rule.add(k+mark, v[0], v[1])
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
      @rules << rule
    end
    @rules
  end

  def existing_mark rule
    existing = @rules.select do |e|
      e.conjuncts.length > rule.conjuncts.length \
      && e.conjuncts[0] == rule.conjuncts[0] \
      && e.conjuncts[1] == rule.conjuncts[1]
    end.first
    if existing
      existing.conjuncts[2][0]=~/(?<=@).*(?=@)/
      $~[0]
    else
      nil
    end
  end

end