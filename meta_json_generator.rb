require_relative "MonkeyTraits"
require "json"

# NOTE: This script generates a json file of all
#       the meta traits defined in MonkeyTraits.rb
#
# run with "ruby meta_json_generator.rb"

def flatten(traits)
  out = {}
  traits.each { |t|
    # flatten traits
    t.each do |k, v|
      out[k] = v
    end
  }
  out
end

# twins/triplets struct is formatted as
# {"twins" => [["1,2,2,3,", [siblings]]]}
# so we need to format it properly to fit json
def flatten_twin_struct(twins)
  t = {}
  twins.each { |k, v|
    siblings = []
    v.each { |k1, v1|
      siblings << { k1 => v1 }
    }
    t[k] = siblings
  }
  t
end

#Meta traits
mt = MonkeyTraits.new

t1 = mt.naked_stats
t2 = mt.naked_stats2
t3 = mt.clothes_stats
t4 = mt.zero_stats
t5 = mt.mouth_stats
t6 = mt.poker_stats
t7 = flatten_twin_struct(mt.find_twins)

meta = flatten([t1, t2, t3, t4, t5, t6, t7])

o = File.open("meta_traits.json", "w")
o << JSON.pretty_generate(meta)
o.close
