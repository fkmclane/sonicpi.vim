# We should probably find the SynthInfo class relatively
#  Presently assumes we're in <sonic-pi-path>/server/sonicpi/lib/sonicpi
require './synths/synthinfo'

puts "# The contexts"
puts "@context = {}"
puts ""

puts "# The synths"
puts "@synths = []"
SonicPi::Synths::SynthInfo.all_synths.each do |synth|
  puts "@synths += ':#{synth.to_s}'"
  print "@context['#{synth.to_s}'] = "  # We're printing to save the \n
  args = SonicPi::Synths::SynthInfo.get_info(synth).arg_defaults
  args.select {|k,v| v.is_a? Symbol}
    .each do |k,v|
      # e.g., {decay_level: :sustain_level} -> {decay_level: args[:sustain_level]}
      args[k] = args[v]
    end
  puts args
end
puts ""

puts "# The FX"
puts "@fx = []"
SonicPi::Synths::FXInfo.all_fx.each do |fx|
  puts "@fx += ':#{fx.to_s}'"
  print "@context['fx_#{fx.to_s}'] = "  # We're printing to save the \n
  args = SonicPi::Synths::FXInfo.get_info("fx_#{fx.to_s}").arg_defaults
  args.select {|k,v| v.is_a? Symbol}
    .each do |k,v|
      # e.g., {decay_level: :sustain_level} -> {decay_level: args[:sustain_level]}
      args[k] = args[v]
    end
  puts args
end
puts ""

puts "# The samples"
print "@samples = "
puts SonicPi::Synths::StudioInfo.all_samples.map {|s| ":#{s.to_s}"}.to_s
print "@context['sample'] = "
args = SonicPi::Synths::StudioInfo.get_info("mono_player").arg_defaults
args.select {|k,v| v.is_a? Symbol}
  .each do |k,v|
    # e.g., {decay_level: :sustain_level} -> {decay_level: args[:sustain_level]}
    args[k] = args[v]
  end
puts args
