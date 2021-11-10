for dir in 0..9 do
  for file in `ls svgs/#{dir}`.split("\n")
    s = open("svgs/#{dir}/#{file}").readlines.join
    puts [s.scan(/\#[0-9a-fA-F]{3}/).sort.uniq.size, file].join("\t")
  end
end
