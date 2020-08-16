# Settings
if ARGV.length == 1
  sonic_pi_app_path = ARGV[0]
else
  sonic_pi_app_path = '/Applications/Sonic Pi.app/Contents/Resources/app'
end

highlight_group = Hash.new('rubyKeyword')
highlight_group['define'] = 'rubyDefine'
highlight_group['ndefine'] = 'rubyDefine'
highlight_group['defonce'] = 'rubyDefine'
highlight_group['loop'] = 'rubyRepeat'
highlight_group['live_loop'] = 'rubyRepeat'


# Include Sonic Pi stuff
require "#{sonic_pi_app_path}/server/ruby/core.rb"

require "#{sonic_pi_app_path}/server/ruby/lib/sonicpi/synths/synthinfo.rb"
require "#{sonic_pi_app_path}/server/ruby/lib/sonicpi/lang/support/docsystem.rb"

Dir["#{sonic_pi_app_path}/server/ruby/lib/sonicpi/lang/*.rb"].each { |filename| require filename }


# Generate syntax and completion files
File.open(File.join(File.dirname(__FILE__), '../syntax/sonicpi.vim'), 'w') do |f|
  SonicPi::Lang::Core.docs.keys.map { |s| s.to_s }.each do |keyword|
    f.puts "syntax keyword #{highlight_group[keyword]} #{keyword}"
  end
end

File.open(File.join(File.dirname(__FILE__), '../autoload/sonicpicomplete.vim'), 'w') do |f|
  f.puts <<~'vim'
    function! sonicpicomplete#GetContext(base)
      let s:line = getline('.')
      let s:synth_re = '\v(use_synth|synth|with_synth|set_current_synth)\s+'
      let s:fx_re = '\vwith_fx\s+'
      let s:sample_re = '\vsample\s+'

      if s:line =~ s:synth_re.':\w+\s*,\s*'
        " Synth is defined; we need the context
        let directive_end = matchend(s:line, 'synth')
        let sound = matchstr(s:line, '\v\w+', directive_end, 1)
        execute 'ruby SonicPiWordlist.get_context("'.sound.'", "'.a:base.'")'
        return
      endif

      if s:line =~ s:synth_re
        " Synth is not defined; we need the synth
        execute 'ruby SonicPiWordlist.get_synths("'.a:base.'")'
        return
      endif

      if s:line =~ s:fx_re.':\w+\s*,\s*'
        " FX is defined; we need the context
        let directive_end = matchend(s:line, 'fx')
        let fx = matchstr(s:line, '\v\w+', directive_end, 1)
        execute 'ruby SonicPiWordlist.get_context("fx_'.fx.'", "'.a:base.'")'
        return
      endif

      if s:line =~ s:fx_re
        " FX is not defined; we need the FX
        execute 'ruby SonicPiWordlist.get_fx("'.a:base.'")'
        return
      endif

      if s:line =~ s:sample_re.':\w+\s*,\s*'
        " Sample is defined; we need the context
        execute 'ruby SonicPiWordlist.get_context("sample", "'.a:base.'")'
        return
      endif

      if s:line =~ s:sample_re
        execute 'ruby SonicPiWordlist.get_samples("'.a:base.'")'
        return
      endif

      " If we get to this point, we're looking for directives
      execute 'ruby SonicPiWordlist.get_directives("'.a:base.'")'
    endfunction

    function! sonicpicomplete#Complete(findstart, base)
         "findstart = 1 when we need to get the text length
        if a:findstart
            let line = getline('.')
            let idx = col('.')
            while idx > 0
                let idx -= 1
                let c = line[idx-1]
                if c =~ '\v[a-z0-9_:]'
                    continue
                elseif ! c =~ '\.'
                    idx = -1
                    break
                else
                    break
                endif
            endwhile

            return idx
        "findstart = 0 when we need to return the list of completions
        else
          echom a:base
            let g:sonicpicomplete_completions = []
            call sonicpicomplete#GetContext(a:base)
            return g:sonicpicomplete_completions
        endif
    endfunction

    function! s:DefRuby()
    ruby << RUBYEOF
    class SonicPiWordlist
      attr_reader :directives, :synths, :fx, :samples, :context

      def initialize
  vim

  f.puts '    # The directives'
  f.print '    @directives = '
  f.puts SonicPi::Lang::Core.docs.keys.map { |s| s.to_s }.to_s
  f.puts ''

  f.puts '    # The contexts'
  f.puts '    @context = {}'
  f.puts ''

  f.puts '    # The synths'
  f.puts '    @synths = []'
  SonicPi::Synths::SynthInfo.all_synths.each do |synth|
    f.puts "    @synths << ':#{synth.to_s}'"
    f.print "    @context['#{synth.to_s}'] = "
    args = SonicPi::Synths::SynthInfo.get_info(synth).arg_defaults
    args.select { |k,v| v.is_a? Symbol }
      .each do |k,v|
        # e.g., {decay_level: :sustain_level} -> {decay_level: args[:sustain_level]}
        args[k] = args[v]
      end
    f.puts args
  end
  f.puts ''

  f.puts '    # The FX'
  f.puts '    @fx = []'
  SonicPi::Synths::FXInfo.all_fx.each do |fx|
    f.puts "    @fx << ':#{fx.to_s}'"
    f.print "    @context['fx_#{fx.to_s}'] = "
    args = SonicPi::Synths::FXInfo.get_info("fx_#{fx.to_s}").arg_defaults
    args.select { |k,v| v.is_a? Symbol }
      .each do |k,v|
        # e.g., {decay_level: :sustain_level} -> {decay_level: args[:sustain_level]}
        args[k] = args[v]
      end
    f.puts args
  end
  f.puts ''

  f.puts '    # The samples'
  f.print '    @samples = '
  f.puts SonicPi::Synths::StudioInfo.all_samples.map { |s| ":#{s.to_s}" }.to_s
  f.print "    @context['sample'] = "
  args = SonicPi::Synths::StudioInfo.get_info('mono_player').arg_defaults
  args.select { |k,v| v.is_a? Symbol }
    .each do |k,v|
      # e.g., {decay_level: :sustain_level} -> {decay_level: args[:sustain_level]}
      args[k] = args[v]
    end
  f.puts args
  f.puts ''

  f.puts <<~'vim'
      end

      def return_to_vim(completions)
        list = array2list(completions)
        VIM::command('call extend(g:sonicpicomplete_completions, [%s])' % list)
      end

      def self.get_context(sound, base)
        s = SonicPiWordlist.new
        list = s.context[sound].collect do |sym, d|
          sym.to_s + ': ' + d.to_s
        end.sort
        if base != ''
          list = list.grep(/^#{base}/)
        end
        s.return_to_vim(list)
      end

      def self.get_synths(base)
        s = SonicPiWordlist.new
        list = s.synths.grep(/^#{base}/).sort
        s.return_to_vim(list)
      end

      def self.get_fx(base)
        s = SonicPiWordlist.new
        list = s.fx.grep(/^#{base}/).sort
        s.return_to_vim(list)
      end

      def self.get_samples(base)
        s = SonicPiWordlist.new
        list = s.samples.grep(/^#{base}/).sort
        s.return_to_vim(list)
      end

      def self.get_directives(base)
        s = SonicPiWordlist.new
        list = s.directives.grep(/^#{base}/).sort
        s.return_to_vim(list)
      end

      private
      def array2list(array)
        list = array.join('", "')
        list.gsub!(/^(.)/, '"\1')
        list.gsub!(/(.)$/, '\1"')
        list
      end
    end
    RUBYEOF
    endfunction

    call s:DefRuby()
  vim
end
