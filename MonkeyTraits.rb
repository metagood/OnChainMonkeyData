# colors of attributes from the smart contract 0x960b7a6bcd451c9968473f7bbfd9be826efd549a
CLOTHES1 = ["f00","f00","222","f00","f00","f00","f00","f00","f00","00f","00f","00f","00f","00f","00f","00f","222","00f","f0f","222","f0f","f0f","f0f","f0f","f0f","f0f","f0f","f80","f80","f80","f80","f80","f00","f80","f80","f80","90f","90f","00f","90f","90f","90f","222"]
CLOTHES2 = ["d00","00f","f00","f0f","f80","90f","f48","0f0","ff0","f00","00d","f0f","f80","90f","f48","0f0","ddd","ff0","f00","653","00f","d0d","f80","90f","f48","0f0","ff0","f00","f0f","00f","d60","f48","ddd","90f","0f0","ff0","f00","00f","fd1","f0f","f80","70d","fd1"]
HAT1     = ["f00","f00","f00","f00","f00","f00","f00","00f","00f","00f","00f","00f","00f","00f","f00","f0f","f0f","f0f","f0f","f0f","f0f","f0f","f80","f80","f80","f80","f80","f80","f00","f80","90f","f48","22d","90f","90f","ff0"]
# HAT2 000 => 222 for color match
HAT2     = ["0f0","00f","f80","ff0","90f","f0f","f48","f00","0f0","00f","f80","ff0","90f","f0f","222","f00","0f0","00f","f80","ff0","90f","f0f","f00","0f0","00f","f80","ff0","90f","f00","f0f","f00","222","222","0f0","00f","f48"]  
MOUTH    = ["653","ffc","f89","777","049","901","bcc","d04","fd1","ffc","653","f89","777","049","bcc","901","901","bcc","653","d04","ffc","f89","777","049","fd1","f89","777","bcc","d04","049","ffc","901","fd1"]
FUR1     = ["653","532","444","a71","ffc","ca9","f89","777","049","901","fc5","ffe","574","bcc","d04","222","889","7f9","fd1"]
FUR2     = ["532","653","653","653","653","653","653","653","653","653","110","653","711","344","799","555","8a8","32f","653"]

EYES = ["abe","0a0","653","888","be7","abe","0a0","653","888","be7","cef","abe","0a0","653","888","be7","cef","abe","0a0","653","888","be7","cef"];
background = ["656","dda","e92","1eb","663","9de","367","ccc"]
earring = ["999","fe7","999","999","fe7","bdd"]

all_hat_clothes_colors = (CLOTHES1 + CLOTHES2 + HAT1 + HAT2).sort.uniq.sort
all_colors = (all_hat_clothes_colors + MOUTH + FUR1 + FUR2 + EYES + background + earring).sort.uniq.sort

# order from OCM.csv
M_IND       = 0
HAT_IND     = 1
FUR_IND     = 2
CLOTHES_IND = 3
EYES_IND    = 4
EARRING_IND = 5
MOUTH_IND   = 6

# for printing list of all OCM# that match a specific meta-trait. OCM#s for meta-traits with counts above this are printed in results
THRESHOLD = 300

# NOTE: use this with a grain of salt, there may be bugs in these results
#       also, there will be more and new meta-traits and lore that are interesting
#       that are not included in this list of meta-traits
# run with "ruby MonkeyTraits.rb"

class MonkeyTraits

  def initialize
    # order is: tokenId, hat, fur, clothes, eyes, earring, mouth, background
    @monkeys = open('OCM.csv').readlines.map {|i| i.strip.split(',').map {|i| i.to_i}}[1..-1] # skip first header row
    @h_nips = {}
    @h_color = {}
    @h_snout = {}
    @h_zero = {}
    @h_trait_count = {}
  end

  def write_csv
    open('OCM_meta_traits.csv','w') do |f|
      f.puts "tokenId, hat, fur, clothes, eyes, earring, mouth, background, trait-count, color-match, mouth-match, zeros, nips"
      @monkeys.each_with_index do |m, j|
        i = j + 1
        raise unless @h_nips[i]
        raise unless @h_color[i]
	raise unless @h_snout[i]
	raise unless @h_zero[i]
        raise unless @h_trait_count[i]
        f.puts (m + [@h_trait_count[i], @h_color[i], @h_snout[i], @h_zero[i], @h_nips[i]]).join(",")
      end
    end
  end

  def find_twins
    h = {}
    for m in @monkeys
      s = m[1..6].join(',')
      if h[s] 
        h[s] << m[0]
      else
        h[s] = [m[0]]
      end
    end
    out = {'twins' => h.to_a.select {|k,v| v.size == 2},
      'triplets' => h.to_a.select {|k,v| v.size == 3}}
    puts '----------------------------------------------------------------------------------'
    puts
    puts "twins and triplets, monkeys are the same expect for the background:"
    puts
    puts [['twins', out['twins'].size * 2], ['triplets', out['triplets'].size * 3]].inspect
    puts
    puts out.inspect
    out
  end

  def poker_hand(m)
    # not counting wheel straights
    arr = m.sort.uniq.sort
    if (arr[6] && (arr[0] == arr[6]-6))
      return 'stright 7 in a row'
    end
    if (arr[5] && (arr[0] == (arr[5] - 5))) || (arr[6] && (arr[1] == (arr[6] - 5)))
      return 'straight 6 in a row'
    end
    if (arr[4] && (arr[0] == (arr[4] - 4))) || (arr[5] && (arr[1] == (arr[5] - 4))) || (arr[6] && (arr[2] == (arr[6] - 4)))
      return 'straight 5 in a row'
    end
    h = Hash.new(0)
    m.map {|i| h[i] += 1}
    arr = h.to_a.sort {|a,b| b[1]<=>a[1]}
    if arr[0][1] >= 6
      return "#{arr[0][1]} of a kind"
    elsif arr[0][1] == 5
      if arr[1][1] == 2
        return '5-2 full house'
      else
        return '5 of a kind'
      end
    elsif arr[0][1] == 4 
      if arr[1][1] == 3
        return '4-3 full house'
      elsif arr[1][1] == 2
        return '4-2 full house'
      else
        return '4 of a kind'
      end
    elsif arr[0][1] == 3
      if arr[1][1] == 3 
        return '3-3 full house'
      elsif arr[1][1] == 2
        return '3-2 full house'
      else
        return '3 of a kind'
      end
    elsif arr[0][1] == 2
      if arr[1][1] == 2
        return '2 pair'
      else
        return '1 pair'
      end  
    end
    'no poker hand'
  end

  def has_hat_and_clothes?(monkey)
    monkey[CLOTHES_IND] != 0 && monkey[HAT_IND] != 0
  end

  def clothes_match?(monkey)
    return false unless has_hat_and_clothes?(monkey)
    CLOTHES1[monkey[CLOTHES_IND]-1] == HAT1[monkey[HAT_IND]-1] && CLOTHES2[monkey[CLOTHES_IND]-1] == HAT2[monkey[HAT_IND]-1]
  end

  def clothes_reverse?(monkey)
    return false unless has_hat_and_clothes?(monkey)
    CLOTHES1[monkey[CLOTHES_IND]-1] == HAT2[monkey[HAT_IND]-1] && CLOTHES2[monkey[CLOTHES_IND]-1] == HAT1[monkey[HAT_IND]-1]
  end

  def clothes_color_count(monkey)
    return -1 unless has_hat_and_clothes?(monkey)
    out = [CLOTHES1[monkey[CLOTHES_IND]-1], HAT1[monkey[HAT_IND]-1], CLOTHES2[monkey[CLOTHES_IND]-1], HAT2[monkey[HAT_IND]-1]].uniq.size
    raise if out == 2 && (HAT2[monkey[HAT_IND]-1] != HAT1[monkey[HAT_IND]-1]) # error check
    out
  end

  def mouth_snoutless?(monkey)
    FUR1[monkey[FUR_IND]] == MOUTH[monkey[MOUTH_IND]]
  end

  def mouth_match?(monkey)
    FUR2[monkey[FUR_IND]] == MOUTH[monkey[MOUTH_IND]]
  end 

  def zero_count(monkey)
    monkey[1..-1].select {|i| i==0}.size
  end 

  def trait_count(monkey)
    c = 4
    c += 1 if monkey[HAT_IND]!=0 
    c += 1 if monkey[CLOTHES_IND]!=0  
    c += 1 if monkey[EARRING_IND]!=0
    c
  end

  # no hat, no earring, no clothes
  def naked?(monkey)
    monkey[HAT_IND]==0 && monkey[CLOTHES_IND]==0 && monkey[EARRING_IND]==0
  end

  # no hat, no clothes, with earring
  def tagged?(monkey)
    monkey[HAT_IND]==0 && monkey[CLOTHES_IND]==0 && monkey[EARRING_IND]!=0
  end

  # no clothes with hat
  def magic_monk?(monkey)
    monkey[HAT_IND]!=0 && monkey[CLOTHES_IND]==0
  end

  def clothes_stats
    h = {}
    h_match = Hash.new(0)
    h_reverse = Hash.new(0)
    h_hat = Hash.new(0)
    @monkeys.map do |m|
      s = nil
      if clothes_match?(m)
        s = 'color-match'
        h_match[[m[CLOTHES_IND], m[HAT_IND]].join('_')] += 1
      elsif clothes_reverse?(m)
        s = 'reverse color-match'
        h_reverse[[m[CLOTHES_IND], m[HAT_IND]].join('_')] += 1
      else
        ccc = clothes_color_count(m)
        s = if ccc == 2
          h_hat[[m[CLOTHES_IND], m[HAT_IND]].join('_')] += 1
          '2-color w/ matching solid color hat'
        elsif ccc == 3
          '3-color'
        elsif ccc == 4
          '4-color'
        elsif ccc == -1
          'N/A'
        else
          raise
        end
      end
      raise unless s
      h[s] = [] unless h[s]
      h[s] << m[0]
      @h_color[m[M_IND].to_i] = s
    end
    puts '----------------------------------------------------------------------------------'
    puts
    puts 'clothes and hat matches:'
    puts
    puts h.to_a.map {|i,j| [i,j.size]}.sort {|i,j| j[1]<=>i[1]}.inspect
    puts
    puts h.to_a.select {|i,j| j.size <= THRESHOLD}.sort {|i,j| j[1].size<=>i[1].size}.inspect
    h
  end  

  def zero_stats
    h = {}
    @monkeys.map do |m|
      s = zero_count(m)
      h[s] = [] unless h[s]
      h[s] << m[0]
      @h_zero[m[M_IND].to_i] = s
    end
    puts '----------------------------------------------------------------------------------'
    puts
    puts 'monkeys with 0 value traits:'
    puts
    puts h.to_a.map {|i,j| [i,j.size]}.sort {|i,j| j[1]<=>i[1]}.inspect
    puts
    puts h.to_a.select {|i,j| j.size <= THRESHOLD}.sort {|i,j| j[1].size<=>i[1].size}.inspect
    h
  end   

  def naked_stats
    h = {}
    @monkeys.map do |m|
      s = if naked?(m)
        z = zero_count(m)
        "naked #{z}-0"
      elsif tagged?(m)
        z = zero_count(m)
        "tagged #{z}-0"
      end
      h[s] = [] unless h[s]
      h[s] << m[0]
      @h_nips[m[M_IND].to_i] = s
      @h_trait_count[m[M_IND].to_i] = trait_count(m)
    end
    puts '----------------------------------------------------------------------------------'
    puts
    puts 'naked stats:'
    puts
    puts h.to_a.map {|i,j| [i,j.size]}.sort {|i,j| j[1]<=>i[1]}.inspect
    puts
    puts h.to_a.select {|i,j| j.size <= THRESHOLD}.sort {|i,j| j[1].size<=>i[1].size}.inspect
    h
  end

  def naked_stats2
    h = {}
    @monkeys.map do |m|
      s = if naked?(m)
        if mouth_snoutless?(m)
          "naked snoutless"
        elsif mouth_match?(m)
          "naked snout-match"
        else
          "naked plain"
        end
      elsif tagged?(m)
        if mouth_snoutless?(m)
          "tagged snoutless"
        elsif mouth_match?(m)
          "tagged snout-match"
        else
          "tagged plain"
        end
      end
      h[s] = [] unless h[s]
      h[s] << m[0]
    end
    puts '----------------------------------------------------------------------------------'
    puts
    puts 'naked stats2:'
    puts
    puts h.to_a.map {|i,j| [i,j.size]}.sort {|i,j| j[1]<=>i[1]}.inspect
    puts
    puts h.to_a.select {|i,j| j.size <= THRESHOLD}.sort {|i,j| j[1].size<=>i[1].size}.inspect
    h
  end  

  def nip_stats
    h = {}
    @monkeys.map do |m|
      s = if naked?(m)
        'naked'
      elsif tagged?(m)
        'tagged'
      elsif magic_monk?(m)
        'magic monk'
      else
        byebug if m[CLOTHES_IND]==0 
        'covered'
      end
      h[s] = [] unless h[s]
      h[s] << m[0]
      @h_nips[m[M_IND].to_i] = s
    end
    puts '----------------------------------------------------------------------------------'
    puts
    puts 'nips stats:'
    puts
    puts h.to_a.map {|i,j| [i,j.size]}.sort {|i,j| j[1]<=>i[1]}.inspect
    puts
    puts h.to_a.select {|i,j| j.size <= THRESHOLD}.sort {|i,j| j[1].size<=>i[1].size}.inspect
    h
  end

  def mouth_stats
    snoutless_fur = Hash.new(0)
    fur_mouth = Hash.new(0)
    h = {}
    @monkeys.map do |m|
      s = if mouth_snoutless?(m)
        snoutless_fur[m[FUR_IND]] += 1
        fur_mouth["#{m[FUR_IND]}_#{m[MOUTH_IND]}"] += 1
        'snoutless'
      elsif mouth_match?(m)
        'snout-match'
      else
        'regular' 
      end
      h[s] = [] unless h[s]
      h[s] << m[0]
      @h_snout[m[M_IND].to_i] = s
    end
    puts '----------------------------------------------------------------------------------'
    puts
    puts h.to_a.map {|i,j| [i,j.size]}.sort {|i,j| j[1]<=>i[1]}.inspect
    #puts h.inspect # too many to print
    puts "snoutless count for each fur type"
    puts snoutless_fur.to_a.sort.inspect
    puts "snoutless count for each fur/mouth combo"
    puts fur_mouth.to_a.sort.inspect
    h
  end

  def poker_stats
    h = {}
    @monkeys.map do |m|
      s = poker_hand(m)
      h[s] = [] unless h[s]
      h[s] << m[0]
    end
    puts '----------------------------------------------------------------------------------'
    puts
    puts 'poker hands:'
    puts
    puts h.to_a.map {|i,j| [i,j.size]}.sort {|i,j| j[1]<=>i[1]}.inspect
    puts
    puts h.to_a.select {|i,j| j.size <= THRESHOLD}.sort {|i,j| j[1].size<=>i[1].size}.inspect
    h
  end  

end

mt = MonkeyTraits.new
h  = mt.naked_stats
h2 = mt.naked_stats2
h3 = mt.clothes_stats
h4 = mt.zero_stats
h5 = mt.mouth_stats
h6 = mt.poker_stats
h7 = mt.find_twins
h8 = mt.nip_stats
puts

mt.write_csv
