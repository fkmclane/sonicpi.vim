function! sonicpicomplete#GetContext(base)
  let s:line = getline('.')
  let s:synth_re = '\v(use_synth|synth|with_synth|set_current_synth)\s+'
  let s:fx_re = '\vwith_fx\s+'
  let s:sample_re = '\vsample\s+'

  if s:line =~ s:synth_re.':\w+\s*,\s*'
    " Synth is defined; we need the context
    let directive_end = matchend(s:line, 'synth')
    let sound = matchstr(s:line, '\v\w+', directive_end, 1)
    execute 'ruby SonicPiWordlist.get_context("'.sound.'","'.a:base.'")'
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
    let sound = matchstr(s:line, '\v\w+', directive_end, 1)
    execute 'ruby SonicPiWordlist.get_context("'.sound.'","'.a:base.'")'
    return
  endif

  if s:line =~ s:fx_re
    " FX is not defined; we need the FX
    execute 'ruby SonicPiWordlist.get_fx("'.a:base.'")'
    return
  endif

  if s:line =~ s:sample_re.':\w+\s*,\s*'
    " Sample is defined; we need the context
    execute 'ruby SonicPiWordlist.get_context("sample","'.a:base.'")'
    return
  endif

  if s:line =~ s:sample_re
    execute 'ruby SonicPiWordlist.get_samples("'.a:base.'")'
    return
  endif

  " Non-sound contexts
  " #spread is added in 2.4
  if s:line =~ '\vspread\s+\d+\s*,\s*\d+\s*,\s*'
    execute 'ruby SonicPiWordlist.get_context("spread","'.a:base.'")'
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
    # The directives
    @directives = []

    # From app/server/ruby/lib/sonicpi/lang/core.rb
    @directives += %w(assert assert_equal assert_error assert_similar at)
    @directives += %w(beat block_duration block_slept? bools bt choose)
    @directives += %w(clear cue current_beat_duration current_bpm)
    @directives += %w(current_random_seed current_sched_ahead_time)
    @directives += %w(current_time dec density dice doubles eval_file)
    @directives += %w(factor? get halves in_thread inc knit line)
    @directives += %w(load_buffer load_example look map on one_in osc)
    @directives += %w(osc_send pick print puts quantise ramp rand)
    @directives += %w(rand_back rand_i rand_i_look rand_look rand_reset)
    @directives += %w(rand_skip range rdist reset ring rrand rrand_i rt)
    @directives += %w(run_code run_file set set_sched_ahead_time! shuffle)
    @directives += %w(sleep spark spark_graph spread stop stretch sync)
    @directives += %w(sync_bpm tick tick_reset tick_reset_all tick_set)
    @directives += %w(time_warp uncomment use_bpm use_bpm_mul)
    @directives += %w(use_cue_logging use_osc use_osc_logging)
    @directives += %w(use_random_seed use_real_time use_sched_ahead_time)
    @directives += %w(vector version vt wait with_bpm with_bpm_mul)
    @directives += %w(with_cue_logging with_osc with_osc_logging)
    @directives += %w(with_random_seed with_real_time)
    @directives += %w(with_sched_ahead_time with_swing)
    @directives += %w(define defonce)
    @directives += %w(live_loop loop)
    @directives += %w(comment ndefine)

    # From app/server/ruby/lib/sonicpi/lang/sound.rb
    @directives += %w(all_sample_names buffer control current_arg_checks)
    @directives += %w(current_debug current_sample_defaults current_synth)
    @directives += %w(current_synth_defaults current_volume fx_names kill)
    @directives += %w(live_audio load_sample load_samples load_synthdefs)
    @directives += %w(play play_chord play_pattern play_pattern_timed)
    @directives += %w(recording_delete recording_save recording_start)
    @directives += %w(recording_stop reset_mixer! sample sample_buffer)
    @directives += %w(sample_duration sample_free sample_free_all)
    @directives += %w(sample_groups sample_info sample_loaded?)
    @directives += %w(sample_names sample_paths scsynth_info)
    @directives += %w(set_audio_latency! set_control_delta!)
    @directives += %w(set_mixer_control! set_recording_bit_depth!)
    @directives += %w(set_volume! status synth synth_names)
    @directives += %w(use_arg_bpm_scaling use_arg_checks use_debug)
    @directives += %w(use_merged_sample_defaults use_merged_synth_defaults)
    @directives += %w(use_sample_bpm use_sample_defaults use_synth)
    @directives += %w(use_synth_defaults use_timing_guarantees)
    @directives += %w(with_arg_bpm_scaling with_arg_checks with_debug)
    @directives += %w(with_fx with_merged_sample_defaults)
    @directives += %w(with_merged_synth_defaults with_sample_bpm)
    @directives += %w(with_sample_defaults with_synth with_synth_defaults)
    @directives += %w(with_timing_guarantees)

    # From app/server/ruby/lib/sonicpi/lang/pattern.rb
    @directives += %w(play_nested_pattern)

    # From app/server/ruby/lib/sonicpi/lang/western_theory.rb
    @directives += %w(chord chord_degree chord_invert chord_names)
    @directives += %w(current_cent_tuning current_octave current_transpose)
    @directives += %w(degree hz_to_midi midi_notes midi_to_hz note)
    @directives += %w(note_info note_range octs pitch_to_ratio)
    @directives += %w(ratio_to_pitch rest? scale scale_names)
    @directives += %w(set_cent_tuning! use_cent_tuning use_octave)
    @directives += %w(use_transpose use_tuning with_cent_tuning)
    @directives += %w(with_octave with_transpose with_tuning)

    # From app/server/ruby/lib/sonicpi/lang/maths.rb
    @directives += %w(math_scale)

    # From app/server/ruby/lib/sonicpi/lang/midi.rb
    @directives += %w(current_midi_defaults midi midi_all_notes_off)
    @directives += %w(midi_cc midi_channel_pressure midi_clock_beat)
    @directives += %w(midi_clock_tick midi_continue midi_local_control_off)
    @directives += %w(midi_local_control_on midi_mode midi_note_off)
    @directives += %w(midi_note_on midi_pc midi_pitch_bend)
    @directives += %w(midi_poly_pressure midi_raw midi_reset)
    @directives += %w(midi_sound_off midi_start midi_stop midi_sysex)
    @directives += %w(use_merged_midi_defaults use_midi_defaults)
    @directives += %w(use_midi_logging with_merged_midi_defaults)
    @directives += %w(with_midi_defaults with_midi_logging)

    # From app/server/ruby/lib/sonicpi/lang/minecraftpi.rb
    @directives += %w(mc_block_id mc_block_ids mc_block_name)
    @directives += %w(mc_block_names mc_camera_fixed mc_camera_normal)
    @directives += %w(mc_camera_set_location mc_camera_third_person)
    @directives += %w(mc_chat_post mc_checkpoint_restore)
    @directives += %w(mc_checkpoint_save mc_get_block mc_get_height)
    @directives += %w(mc_get_pos mc_get_tile mc_ground_height mc_location)
    @directives += %w(mc_message mc_set_area mc_set_block mc_set_pos)
    @directives += %w(mc_set_tile mc_surface_teleport mc_teleport)

    # The synths
    @synths = []
    @context = {}
    @synths << ':dull_bell'
    @context['dull_bell'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2}
    @synths << ':pretty_bell'
    @context['pretty_bell'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2}
    @synths << ':beep'
    @context['beep'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2}
    @synths << ':sine'
    @context['sine'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2}
    @synths << ':saw'
    @context['saw'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0}
    @synths << ':pulse'
    @context['pulse'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :pulse_width=>0.5, :pulse_width_slide=>0, :pulse_width_slide_shape=>1, :pulse_width_slide_curve=>0}
    @synths << ':subpulse'
    @context['subpulse'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :pulse_width=>0.5, :pulse_width_slide=>0, :pulse_width_slide_shape=>1, :pulse_width_slide_curve=>0, :sub_amp=>1, :sub_amp_slide=>0, :sub_amp_slide_shape=>1, :sub_amp_slide_curve=>0, :sub_detune=>-12, :sub_detune_slide=>0, :sub_detune_slide_shape=>1, :sub_detune_slide_curve=>0}
    @synths << ':square'
    @context['square'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0}
    @synths << ':tri'
    @context['tri'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :pulse_width=>0.5, :pulse_width_slide=>0, :pulse_width_slide_shape=>1, :pulse_width_slide_curve=>0}
    @synths << ':dsaw'
    @context['dsaw'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :detune=>0.1, :detune_slide=>0, :detune_slide_shape=>1, :detune_slide_curve=>0}
    @synths << ':dpulse'
    @context['dpulse'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :detune=>0.1, :detune_slide=>0, :detune_slide_shape=>1, :detune_slide_curve=>0, :pulse_width=>0.5, :pulse_width_slide=>0, :pulse_width_slide_shape=>1, :pulse_width_slide_curve=>0, :dpulse_width=>0.5, :dpulse_width_slide=>0, :dpulse_width_slide_shape=>1, :dpulse_width_slide_curve=>0}
    @synths << ':dtri'
    @context['dtri'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :detune=>0.1, :detune_slide=>0, :detune_slide_shape=>1, :detune_slide_curve=>0}
    @synths << ':fm'
    @context['fm'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :divisor=>2, :divisor_slide=>0, :divisor_slide_shape=>1, :divisor_slide_curve=>0, :depth=>1, :depth_slide=>0, :depth_slide_shape=>1, :depth_slide_curve=>0}
    @synths << ':mod_fm'
    @context['mod_fm'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :divisor=>2, :divisor_slide=>0, :divisor_slide_shape=>1, :divisor_slide_curve=>0, :depth=>1, :depth_slide=>0, :depth_slide_shape=>1, :depth_slide_curve=>0, :mod_phase=>0.25, :mod_range=>5, :mod_pulse_width=>0.5, :mod_phase_offset=>0, :mod_invert_wave=>0, :mod_wave=>1}
    @synths << ':mod_saw'
    @context['mod_saw'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :mod_phase=>0.25, :mod_phase_slide=>0, :mod_phase_slide_shape=>1, :mod_phase_slide_curve=>0, :mod_range=>5, :mod_range_slide=>0, :mod_range_slide_shape=>1, :mod_range_slide_curve=>0, :mod_pulse_width=>0.5, :mod_pulse_width_slide=>0, :mod_pulse_width_slide_shape=>1, :mod_pulse_width_slide_curve=>0, :mod_phase_offset=>0, :mod_invert_wave=>0, :mod_wave=>1}
    @synths << ':mod_dsaw'
    @context['mod_dsaw'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :mod_phase=>0.25, :mod_phase_slide=>0, :mod_phase_slide_shape=>1, :mod_phase_slide_curve=>0, :mod_range=>5, :mod_range_slide=>0, :mod_range_slide_shape=>1, :mod_range_slide_curve=>0, :mod_pulse_width=>0.5, :mod_pulse_width_slide=>0, :mod_pulse_width_slide_shape=>1, :mod_pulse_width_slide_curve=>0, :mod_phase_offset=>0, :mod_invert_wave=>0, :mod_wave=>1, :detune=>0.1, :detune_slide=>0, :detune_slide_shape=>1, :detune_slide_curve=>0}
    @synths << ':mod_sine'
    @context['mod_sine'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :mod_phase=>0.25, :mod_phase_slide=>0, :mod_phase_slide_shape=>1, :mod_phase_slide_curve=>0, :mod_range=>5, :mod_range_slide=>0, :mod_range_slide_shape=>1, :mod_range_slide_curve=>0, :mod_pulse_width=>0.5, :mod_pulse_width_slide=>0, :mod_pulse_width_slide_shape=>1, :mod_pulse_width_slide_curve=>0, :mod_phase_offset=>0, :mod_invert_wave=>0, :mod_wave=>1}
    @synths << ':mod_beep'
    @context['mod_beep'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :mod_phase=>0.25, :mod_phase_slide=>0, :mod_phase_slide_shape=>1, :mod_phase_slide_curve=>0, :mod_range=>5, :mod_range_slide=>0, :mod_range_slide_shape=>1, :mod_range_slide_curve=>0, :mod_pulse_width=>0.5, :mod_pulse_width_slide=>0, :mod_pulse_width_slide_shape=>1, :mod_pulse_width_slide_curve=>0, :mod_phase_offset=>0, :mod_invert_wave=>0, :mod_wave=>1}
    @synths << ':mod_tri'
    @context['mod_tri'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :mod_phase=>0.25, :mod_phase_slide=>0, :mod_phase_slide_shape=>1, :mod_phase_slide_curve=>0, :mod_range=>5, :mod_range_slide=>0, :mod_range_slide_shape=>1, :mod_range_slide_curve=>0, :mod_pulse_width=>0.5, :mod_pulse_width_slide=>0, :mod_pulse_width_slide_shape=>1, :mod_pulse_width_slide_curve=>0, :mod_phase_offset=>0, :mod_invert_wave=>0, :mod_wave=>1}
    @synths << ':mod_pulse'
    @context['mod_pulse'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :mod_phase=>0.25, :mod_phase_slide=>0, :mod_phase_slide_shape=>1, :mod_phase_slide_curve=>0, :mod_range=>5, :mod_range_slide=>0, :mod_range_slide_shape=>1, :mod_range_slide_curve=>0, :mod_pulse_width=>0.5, :mod_pulse_width_slide=>0, :mod_pulse_width_slide_shape=>1, :mod_pulse_width_slide_curve=>0, :mod_phase_offset=>0, :mod_invert_wave=>0, :mod_wave=>1, :pulse_width=>0.5, :pulse_width_slide=>0, :pulse_width_slide_shape=>1, :pulse_width_slide_curve=>0}
    @synths << ':chiplead'
    @context['chiplead'] = {:note=>60, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :note_resolution=>0.1, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :width=>0}
    @synths << ':chipbass'
    @context['chipbass'] = {:note=>60, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :note_resolution=>0.1, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2}
    @synths << ':tb303'
    @context['tb303'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>120, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :cutoff_min=>30, :cutoff_min_slide=>0, :cutoff_min_slide_shape=>1, :cutoff_min_slide_curve=>0, :cutoff_attack=>0, :cutoff_decay=>0, :cutoff_sustain=>0, :cutoff_release=>1, :cutoff_attack_level=>1, :cutoff_decay_level=>1, :cutoff_sustain_level=>1, :res=>0.9, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0, :wave=>0, :pulse_width=>0.5, :pulse_width_slide=>0, :pulse_width_slide_shape=>1, :pulse_width_slide_curve=>0}
    @synths << ':supersaw'
    @context['supersaw'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>130, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :res=>0.7, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0}
    @synths << ':hoover'
    @context['hoover'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0.05, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>130, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :res=>0.1, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0}
    @synths << ':prophet'
    @context['prophet'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>110, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :res=>0.7, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0}
    @synths << ':zawa'
    @context['zawa'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :res=>0.9, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0, :phase=>1, :phase_slide=>0, :phase_slide_shape=>1, :phase_slide_curve=>0, :phase_offset=>0, :wave=>3, :invert_wave=>0, :range=>24, :range_slide=>0, :range_slide_shape=>1, :range_slide_curve=>0, :disable_wave=>0, :pulse_width=>0.5, :pulse_width_slide=>0, :pulse_width_slide_shape=>1, :pulse_width_slide_curve=>0}
    @synths << ':dark_ambience'
    @context['dark_ambience'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>110, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :res=>0.7, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0, :detune1=>12, :detune1_slide=>0, :detune1_slide_shape=>1, :detune1_slide_curve=>0, :detune2=>24, :detune2_slide=>0, :detune2_slide_shape=>1, :detune2_slide_curve=>0, :noise=>0, :ring=>0.2, :room=>70, :reverb_time=>100}
    @synths << ':growl'
    @context['growl'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0.1, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>130, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :res=>0.7, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0}
    @synths << ':hollow'
    @context['hollow'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>90, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :res=>0.99, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0, :noise=>1, :norm=>0}
    @synths << ':blade'
    @context['blade'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :vibrato_rate=>6, :vibrato_rate_slide_shape=>1, :vibrato_rate_slide_curve=>0, :vibrato_depth=>0.15, :vibrato_depth_slide_shape=>1, :vibrato_depth_slide_curve=>0, :vibrato_delay=>0.5, :vibrato_onset=>0.1}
    @synths << ':piano'
    @context['piano'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :vel=>0.8, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :hard=>0.5, :stereo_width=>0}
    @synths << ':pluck'
    @context['pluck'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay=>0, :decay_level=>1, :sustain_level=>1, :noise_amp=>0.8, :max_delay_time=>0.125, :pluck_decay=>30, :coef=>0.3}
    @synths << ':tech_saws'
    @context['tech_saws'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>130, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :res=>0.7, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0}
    @synths << ':sound_in'
    @context['sound_in'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>1, :release=>0, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>0, :input=>1}
    @synths << ':sound_in_stereo'
    @context['sound_in_stereo'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>1, :release=>0, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>0, :input=>1}
    @synths << ':noise'
    @context['noise'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>110, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :res=>0, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0}
    @synths << ':pnoise'
    @context['pnoise'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>110, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :res=>0, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0}
    @synths << ':bnoise'
    @context['bnoise'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>110, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :res=>0, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0}
    @synths << ':gnoise'
    @context['gnoise'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>110, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :res=>0, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0}
    @synths << ':cnoise'
    @context['cnoise'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>110, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :res=>0, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0}
    @synths << ':chipnoise'
    @context['chipnoise'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>0, :amp_slide_curve=>1, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>0, :freq_band=>0, :freq_band_slide=>0, :freq_band_slide_shape=>1, :freq_band_slide_curve=>0}

    # The samples
    @samples = [":drum_heavy_kick", ":drum_tom_mid_soft", ":drum_tom_mid_hard", ":drum_tom_lo_soft", ":drum_tom_lo_hard", ":drum_tom_hi_soft", ":drum_tom_hi_hard", ":drum_splash_soft", ":drum_splash_hard", ":drum_snare_soft", ":drum_snare_hard", ":drum_cymbal_soft", ":drum_cymbal_hard", ":drum_cymbal_open", ":drum_cymbal_closed", ":drum_cymbal_pedal", ":drum_bass_soft", ":drum_bass_hard", ":drum_cowbell", ":drum_roll", ":elec_triangle", ":elec_snare", ":elec_lo_snare", ":elec_hi_snare", ":elec_mid_snare", ":elec_cymbal", ":elec_soft_kick", ":elec_filt_snare", ":elec_fuzz_tom", ":elec_chime", ":elec_bong", ":elec_twang", ":elec_wood", ":elec_pop", ":elec_beep", ":elec_blip", ":elec_blip2", ":elec_ping", ":elec_bell", ":elec_flip", ":elec_tick", ":elec_hollow_kick", ":elec_twip", ":elec_plip", ":elec_blup", ":guit_harmonics", ":guit_e_fifths", ":guit_e_slide", ":guit_em9", ":misc_burp", ":misc_crow", ":misc_cineboom", ":perc_bell", ":perc_bell2", ":perc_snap", ":perc_snap2", ":perc_swash", ":perc_till", ":perc_door", ":perc_impact1", ":perc_impact2", ":perc_swoosh", ":ambi_soft_buzz", ":ambi_swoosh", ":ambi_drone", ":ambi_glass_hum", ":ambi_glass_rub", ":ambi_haunted_hum", ":ambi_piano", ":ambi_lunar_land", ":ambi_dark_woosh", ":ambi_choir", ":ambi_sauna", ":bass_hit_c", ":bass_hard_c", ":bass_thick_c", ":bass_drop_c", ":bass_woodsy_c", ":bass_voxy_c", ":bass_voxy_hit_c", ":bass_dnb_f", ":sn_dub", ":sn_dolf", ":sn_zome", ":sn_generic", ":bd_ada", ":bd_pure", ":bd_808", ":bd_zum", ":bd_gas", ":bd_sone", ":bd_haus", ":bd_zome", ":bd_boom", ":bd_klub", ":bd_fat", ":bd_tek", ":bd_mehackit", ":loop_industrial", ":loop_compus", ":loop_amen", ":loop_amen_full", ":loop_garzul", ":loop_mika", ":loop_breakbeat", ":loop_safari", ":loop_tabla", ":loop_3d_printer", ":loop_drone_g_97", ":loop_electric", ":loop_mehackit1", ":loop_mehackit2", ":loop_perc1", ":loop_perc2", ":loop_weirdo", ":tabla_tas1", ":tabla_tas2", ":tabla_tas3", ":tabla_ke1", ":tabla_ke2", ":tabla_ke3", ":tabla_na", ":tabla_na_o", ":tabla_tun1", ":tabla_tun2", ":tabla_tun3", ":tabla_te1", ":tabla_te2", ":tabla_te_ne", ":tabla_te_m", ":tabla_ghe1", ":tabla_ghe2", ":tabla_ghe3", ":tabla_ghe4", ":tabla_ghe5", ":tabla_ghe6", ":tabla_ghe7", ":tabla_ghe8", ":tabla_dhec", ":tabla_na_s", ":tabla_re", ":glitch_bass_g", ":glitch_perc1", ":glitch_perc2", ":glitch_perc3", ":glitch_perc4", ":glitch_perc5", ":glitch_robot1", ":glitch_robot2", ":vinyl_backspin", ":vinyl_rewind", ":vinyl_scratch", ":vinyl_hiss", ":mehackit_phone1", ":mehackit_phone2", ":mehackit_phone3", ":mehackit_phone4", ":mehackit_robot1", ":mehackit_robot2", ":mehackit_robot3", ":mehackit_robot4", ":mehackit_robot5", ":mehackit_robot6", ":mehackit_robot7"]

    # The FX
    @fx = [":bitcrusher", ":krush", ":reverb", ":gverb", ":level", ":mono", ":autotuner", ":echo", ":slicer", ":panslicer", ":wobble", ":ixi_techno", ":compressor", ":whammy", ":rlpf", ":nrlpf", ":rhpf", ":nrhpf", ":hpf", ":nhpf", ":lpf", ":nlpf", ":normaliser", ":distortion", ":pan", ":bpf", ":nbpf", ":rbpf", ":nrbpf", ":band_eq", ":tanh", ":pitch_shift", ":ring_mod", ":octaver", ":vowel", ":flanger", ":eq", ":tremolo", ":record", ":sound_out", ":sound_out_stereo", ":ping_pong"]

  end

  def return_to_vim(completions)
    list = array2list(completions)
    VIM::command("call extend(g:sonicpicomplete_completions, [%s])" % list)
  end

  def self.get_context(sound, base)
    s = SonicPiWordlist.new
    list = s.context[sound].collect do |e|
      e.to_s + ":"
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
    list = array.join('","')
    list.gsub!(/^(.)/, '"\1')
    list.gsub!(/(.)$/, '\1"')
    list
  end
end
RUBYEOF
endfunction

call s:DefRuby()
