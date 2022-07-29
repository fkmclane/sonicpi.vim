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
    # The directives
    @directives = ["octs", "midi_notes", "rest?", "pitch_to_ratio", "ratio_to_pitch", "midi_to_hz", "hz_to_midi", "set_cent_tuning!", "use_cent_tuning", "with_cent_tuning", "use_octave", "with_octave", "use_transpose", "with_transpose", "use_tuning", "with_tuning", "current_transpose", "current_cent_tuning", "current_octave", "note", "note_range", "note_info", "degree", "scale", "chord_degree", "chord", "chord_invert", "scale_names", "chord_names", "live_audio", "scsynth_info", "sample_free", "buffer", "sample_free_all", "use_timing_guarantees", "with_timing_guarantees", "use_sample_bpm", "with_sample_bpm", "use_arg_bpm_scaling", "with_arg_bpm_scaling", "set_audio_latency!", "set_recording_bit_depth!", "set_control_delta!", "use_debug", "with_debug", "use_arg_checks", "with_arg_checks", "use_synth", "with_synth", "recording_start", "recording_stop", "recording_save", "recording_delete", "reset_mixer!", "set_mixer_control!", "synth", "play", "play_pattern", "play_pattern_timed", "play_chord", "use_merged_synth_defaults", "with_merged_synth_defaults", "use_synth_defaults", "use_sample_defaults", "use_merged_sample_defaults", "with_sample_defaults", "with_merged_sample_defaults", "with_synth_defaults", "with_fx", "current_synth", "current_synth_defaults", "current_sample_defaults", "current_volume", "current_debug", "current_arg_checks", "set_volume!", "sample_loaded?", "load_sample", "load_samples", "sample_info", "sample_buffer", "sample_duration", "sample_paths", "sample", "status", "control", "kill", "sample_names", "all_sample_names", "sample_groups", "synth_names", "fx_names", "load_synthdef", "load_synthdefs", "set", "cue", "get", "with_swing", "run_file", "run_code", "eval_file", "use_osc_logging", "with_osc_logging", "use_osc", "with_osc", "osc_send", "osc", "reset", "clear", "time_warp", "tick_set", "tick_reset", "tick_reset_all", "tick", "look", "stop", "on", "bools", "stretch", "knit", "spread", "range", "line", "halves", "doubles", "vector", "ring", "map", "ramp", "choose", "pick", "inc", "dec", "loop", "live_loop", "block_duration", "block_slept?", "at", "version", "spark_graph", "spark", "defonce", "ndefine", "define", "comment", "uncomment", "print", "puts", "vt", "factor?", "quantise", "dice", "one_in", "rdist", "rrand", "rrand_i", "rand", "rand_i", "rand_look", "rand_i_look", "rand_back", "rand_skip", "rand_reset", "shuffle", "use_random_seed", "with_random_seed", "use_random_source", "with_random_source", "use_cue_logging", "with_cue_logging", "link_sync", "link", "set_link_bpm!", "use_bpm", "with_bpm", "with_bpm_mul", "use_bpm_mul", "density", "current_time", "current_random_seed", "current_random_source", "current_bpm_mode", "current_bpm", "current_beat_duration", "beat", "rt", "bt", "set_sched_ahead_time!", "use_sched_ahead_time", "use_real_time", "with_real_time", "with_sched_ahead_time", "current_sched_ahead_time", "sleep", "wait", "sync_bpm", "sync", "in_thread", "assert_error", "assert_not", "assert", "assert_not_equal", "assert_equal", "assert_similar", "load_buffer", "load_example", "math_scale", "use_midi_logging", "with_midi_logging", "use_midi_defaults", "with_midi_defaults", "use_merged_midi_defaults", "with_merged_midi_defaults", "current_midi_defaults", "midi_note_on", "midi_note_off", "midi_poly_pressure", "midi_cc", "midi_channel_pressure", "midi_pitch_bend", "midi_pc", "midi_raw", "midi_sysex", "midi_sound_off", "midi_reset", "midi_local_control_off", "midi_local_control_on", "midi_mode", "midi_all_notes_off", "midi_clock_tick", "midi_start", "midi_stop", "midi_continue", "midi_clock_beat", "midi"]

    # The contexts
    @context = {}

    # The synths
    @synths = []
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
    @context['piano'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :vel=>0.2, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :hard=>0.5, :stereo_width=>0}
    @synths << ':rodeo'
    @context['rodeo'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>1, :sustain=>0.8, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :use_chorus=>1, :use_compressor=>1, :cutoff=>72, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0}
    @synths << ':kalimba'
    @context['kalimba'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>4, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :clickiness=>0.1}
    @synths << ':pluck'
    @context['pluck'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay=>0, :decay_level=>1, :sustain_level=>1, :noise_amp=>0.8, :max_delay_time=>0.125, :pluck_decay=>30, :coef=>0.3}
    @synths << ':tech_saws'
    @context['tech_saws'] = {:note=>52, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :cutoff=>130, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :res=>0.7, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0}
    @synths << ':winwood_lead'
    @context['winwood_lead'] = {:note=>69, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :cutoff=>119, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :res=>0.2, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0, :lfo_width=>0.01, :lfo_width_slide=>0, :lfo_width_slide_shape=>1, :lfo_width_slide_curve=>0, :lfo_rate=>8, :lfo_rate_slide=>0, :lfo_rate_slide_shape=>1, :lfo_rate_slide_curve=>0, :ramp_ratio=>0.5, :ramp_length=>0.2, :seed=>0}
    @synths << ':bass_foundation'
    @context['bass_foundation'] = {:note=>40, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :cutoff=>83, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :res=>0.5, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0}
    @synths << ':bass_highend'
    @context['bass_highend'] = {:note=>40, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>0, :release=>1, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :cutoff=>102, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :res=>0.9, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0, :drive=>2.0, :drive_slide=>0, :drive_slide_shape=>1, :drive_slide_curve=>0}
    @synths << ':organ_tonewheel'
    @context['organ_tonewheel'] = {:note=>60, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0.01, :decay=>0, :sustain=>1, :release=>0.01, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :bass=>8, :bass_slide=>0, :bass_slide_shape=>1, :bass_slide_curve=>0, :quint=>8, :quint_slide=>0, :quint_slide_shape=>1, :quint_slide_curve=>0, :fundamental=>8, :fundamental_slide=>0, :fundamental_slide_shape=>1, :fundamental_slide_curve=>0, :oct=>8, :oct_slide=>0, :oct_slide_shape=>1, :oct_slide_curve=>0, :nazard=>0, :nazard_slide=>0, :nazard_slide_shape=>1, :nazard_slide_curve=>0, :blockflute=>0, :blockflute_slide=>0, :blockflute_slide_shape=>1, :blockflute_slide_curve=>0, :tierce=>0, :tierce_slide=>0, :tierce_slide_shape=>1, :tierce_slide_curve=>0, :larigot=>0, :larigot_slide=>0, :larigot_slide_shape=>1, :larigot_slide_curve=>0, :sifflute=>0, :sifflute_slide=>0, :sifflute_slide_shape=>1, :sifflute_slide_curve=>0, :rs_freq=>6.7, :rs_freq_slide=>0, :rs_freq_slide_shape=>1, :rs_freq_slide_curve=>0, :rs_freq_var=>0.1, :rs_pitch_depth=>0.008, :rs_delay=>0, :rs_onset=>0, :rs_pan_depth=>0.05, :rs_amplitude_depth=>0.2}
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

    # The FX
    @fx = []
    @fx << ':bitcrusher'
    @context['fx_bitcrusher'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :sample_rate=>10000, :sample_rate_slide=>0, :sample_rate_slide_shape=>1, :sample_rate_slide_curve=>0, :bits=>8, :bits_slide=>0, :bits_slide_shape=>1, :bits_slide_curve=>0, :cutoff=>0, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0}
    @fx << ':krush'
    @context['fx_krush'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :gain=>5, :gain_slide=>0, :gain_slide_shape=>1, :gain_slide__curve=>0, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :res=>0, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0}
    @fx << ':reverb'
    @context['fx_reverb'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>0.4, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :room=>0.6, :room_slide=>0, :room_slide_shape=>1, :room_slide_curve=>0, :damp=>0.5, :damp_slide=>0, :damp_slide_shape=>1, :damp_slide_curve=>0}
    @fx << ':gverb'
    @context['fx_gverb'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :spread=>0.5, :spread_slide=>0, :spread_slide_shape=>1, :spread_slide_curve=>0, :damp=>0.5, :damp_slide=>0, :damp_slide_shape=>1, :damp_slide_curve=>0, :pre_damp=>0.5, :pre_damp_slide=>0, :pre_damp_slide_shape=>1, :pre_damp_slide_curve=>0, :dry=>1, :dry_slide=>0, :dry_slide_shape=>1, :dry_slide_curve=>0, :room=>10, :release=>3, :ref_level=>0.7, :tail_level=>0.5}
    @fx << ':level'
    @context['fx_level'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0}
    @fx << ':mono'
    @context['fx_mono'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0}
    @fx << ':autotuner'
    @context['fx_autotuner'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :note=>0, :note_slide=>0, :note_slide_shape=>1, :note_slide_curve=>0, :formant_ratio=>1.0, :formant_ratio_slide=>0, :formant_ratio_slide_shape=>1, :formant_ratio_slide_curve=>0}
    @fx << ':echo'
    @context['fx_echo'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :phase=>0.25, :phase_slide=>0, :phase_slide_shape=>1, :phase_slide_curve=>0, :decay=>2, :decay_slide=>0, :decay_slide_shape=>1, :decay_slide_curve=>0, :max_phase=>2}
    @fx << ':slicer'
    @context['fx_slicer'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :phase=>0.25, :phase_slide=>0, :phase_slide_shape=>1, :phase_slide_curve=>0, :amp_min=>0, :amp_min_slide=>0, :amp_min_slide_shape=>1, :amp_min_slide_curve=>0, :amp_max=>1, :amp_max_slide=>0, :amp_max_slide_shape=>1, :amp_max_slide_curve=>0, :pulse_width=>0.5, :pulse_width_slide=>0, :pulse_width_slide_shape=>1, :pulse_width_slide_curve=>0, :phase_offset=>0, :wave=>1, :invert_wave=>0, :probability=>0, :probability_slide=>0, :probability_slide_shape=>1, :probability_slide_curve=>0, :prob_pos=>0, :prob_pos_slide=>0, :prob_pos_slide_shape=>1, :prob_pos_slide_curve=>0, :seed=>0, :smooth=>0, :smooth_slide=>0, :smooth_slide_shape=>1, :smooth_slide_curve=>0, :smooth_up=>0, :smooth_up_slide=>0, :smooth_up_slide_shape=>1, :smooth_up_slide_curve=>0, :smooth_down=>0, :smooth_down_slide=>0, :smooth_down_slide_shape=>1, :smooth_down_slide_curve=>0}
    @fx << ':panslicer'
    @context['fx_panslicer'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :phase=>0.25, :phase_slide=>0, :phase_slide_shape=>1, :phase_slide_curve=>0, :amp_min=>0, :amp_min_slide=>0, :amp_min_slide_shape=>1, :amp_min_slide_curve=>0, :amp_max=>1, :amp_max_slide=>0, :amp_max_slide_shape=>1, :amp_max_slide_curve=>0, :pulse_width=>0.5, :pulse_width_slide=>0, :pulse_width_slide_shape=>1, :pulse_width_slide_curve=>0, :phase_offset=>0, :wave=>1, :invert_wave=>0, :probability=>0, :probability_slide=>0, :probability_slide_shape=>1, :probability_slide_curve=>0, :prob_pos=>0, :prob_pos_slide=>0, :prob_pos_slide_shape=>1, :prob_pos_slide_curve=>0, :seed=>0, :smooth=>0, :smooth_slide=>0, :smooth_slide_shape=>1, :smooth_slide_curve=>0, :smooth_up=>0, :smooth_up_slide=>0, :smooth_up_slide_shape=>1, :smooth_up_slide_curve=>0, :smooth_down=>0, :smooth_down_slide=>0, :smooth_down_slide_shape=>1, :smooth_down_slide_curve=>0, :pan_min=>-1, :pan_min_slide=>0, :pan_min_slide_shape=>1, :pan_min_slide_curve=>0, :pan_max=>1, :pan_max_slide=>0, :pan_max_slide_shape=>1, :pan_max_slide_curve=>0}
    @fx << ':wobble'
    @context['fx_wobble'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :phase=>0.5, :phase_slide=>0, :phase_slide_shape=>1, :phase_slide_curve=>0, :cutoff_min=>60, :cutoff_min_slide=>0, :cutoff_min_slide_shape=>1, :cutoff_min_slide_curve=>0, :cutoff_max=>120, :cutoff_max_slide=>0, :cutoff_max_slide_shape=>1, :cutoff_max_slide_curve=>0, :res=>0.8, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0, :phase_offset=>0, :wave=>0, :invert_wave=>0, :pulse_width=>0.5, :pulse_width_slide=>0, :pulse_width_slide_shape=>1, :pulse_width_slide_curve=>0, :filter=>0, :probability=>0, :probability_slide=>0, :probability_slide_shape=>1, :probability_slide_curve=>0, :prob_pos=>0, :prob_pos_slide=>0, :prob_pos_slide_shape=>1, :prob_pos_slide_curve=>0, :seed=>0, :smooth=>0, :smooth_slide=>0, :smooth_slide_shape=>1, :smooth_slide_curve=>0, :smooth_up=>0, :smooth_up_slide=>0, :smooth_up_slide_shape=>1, :smooth_up_slide_curve=>0, :smooth_down=>0, :smooth_down_slide=>0, :smooth_down_slide_shape=>1, :smooth_down_slide_curve=>0}
    @fx << ':ixi_techno'
    @context['fx_ixi_techno'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :phase=>4, :phase_slide=>0, :phase_slide_shape=>1, :phase_slide_curve=>0, :phase_offset=>0, :cutoff_min=>60, :cutoff_min_slide=>0, :cutoff_min_slide_shape=>1, :cutoff_min_slide_curve=>0, :cutoff_max=>120, :cutoff_max_slide=>0, :cutoff_max_slide_shape=>1, :cutoff_max_slide_curve=>0, :res=>0.8, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0}
    @fx << ':compressor'
    @context['fx_compressor'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :threshold=>0.2, :threshold_slide=>0, :threshold_slide_shape=>1, :threshold_slide_curve=>0, :clamp_time=>0.01, :clamp_time_slide=>0, :clamp_time_slide_shape=>1, :clamp_time_slide_curve=>0, :slope_above=>0.5, :slope_above_slide=>0, :slope_above_slide_shape=>1, :slope_above_slide_curve=>0, :slope_below=>1, :slope_below_slide=>0, :slope_below_slide_shape=>1, :slope_below_slide_curve=>0, :relax_time=>0.01, :relax_time_slide=>0, :relax_time_slide_shape=>1, :relax_time_slide_curve=>0}
    @fx << ':whammy'
    @context['fx_whammy'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :transpose=>12, :transpose_slide=>0, :transpose_slide_shape=>1, :transpose_slide_curve=>0, :max_delay_time=>1, :deltime=>0.05, :grainsize=>0.075}
    @fx << ':rlpf'
    @context['fx_rlpf'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :res=>0.5, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0}
    @fx << ':nrlpf'
    @context['fx_nrlpf'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :res=>0.5, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0}
    @fx << ':rhpf'
    @context['fx_rhpf'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :res=>0.5, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0}
    @fx << ':nrhpf'
    @context['fx_nrhpf'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0, :res=>0.5, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0}
    @fx << ':hpf'
    @context['fx_hpf'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0}
    @fx << ':nhpf'
    @context['fx_nhpf'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0}
    @fx << ':lpf'
    @context['fx_lpf'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0}
    @fx << ':nlpf'
    @context['fx_nlpf'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :cutoff=>100, :cutoff_slide=>0, :cutoff_slide_shape=>1, :cutoff_slide_curve=>0}
    @fx << ':normaliser'
    @context['fx_normaliser'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :level=>1, :level_slide=>0, :level_slide_shape=>1, :level_slide_curve=>0}
    @fx << ':distortion'
    @context['fx_distortion'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :distort=>0.5, :distort_slide=>0, :distort_slide_shape=>1, :distort_slide_curve=>0}
    @fx << ':pan'
    @context['fx_pan'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0}
    @fx << ':bpf'
    @context['fx_bpf'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :centre=>100, :centre_slide=>0, :centre_slide_shape=>1, :centre_slide_curve=>0, :res=>0.6, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0}
    @fx << ':nbpf'
    @context['fx_nbpf'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :centre=>100, :centre_slide=>0, :centre_slide_shape=>1, :centre_slide_curve=>0, :res=>0.6, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0}
    @fx << ':rbpf'
    @context['fx_rbpf'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :centre=>100, :centre_slide=>0, :centre_slide_shape=>1, :centre_slide_curve=>0, :res=>0.5, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0}
    @fx << ':nrbpf'
    @context['fx_nrbpf'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :centre=>100, :centre_slide=>0, :centre_slide_shape=>1, :centre_slide_curve=>0, :res=>0.5, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0}
    @fx << ':band_eq'
    @context['fx_band_eq'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :freq=>100, :freq_slide=>0, :freq_slide_shape=>1, :freq_slide_curve=>0, :res=>0.6, :res_slide=>0, :res_slide_shape=>1, :res_slide_curve=>0, :db=>0.6, :db_slide=>0, :db_slide_shape=>1, :db_slide_curve=>0}
    @fx << ':tanh'
    @context['fx_tanh'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :krunch=>5, :krunch_slide=>0, :krunch_slide_shape=>1, :krunch_slide_curve=>0}
    @fx << ':pitch_shift'
    @context['fx_pitch_shift'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :window_size=>0.2, :window_size_slide=>0, :window_size_slide_shape=>1, :window_size_slide_curve=>0, :pitch=>0, :pitch_slide=>0, :pitch_slide_shape=>1, :pitch_slide_curve=>0, :pitch_dis=>0.0, :pitch_dis_slide=>0, :pitch_dis_slide_shape=>1, :pitch_dis_slide_curve=>0, :time_dis=>0.0, :time_dis_slide=>0, :time_dis_slide_shape=>1, :time_dis_slide_curve=>0}
    @fx << ':ring_mod'
    @context['fx_ring_mod'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :freq=>30, :freq_slide=>0, :freq_slide_shape=>1, :freq_slide_curve=>0, :mod_amp=>1, :mod_amp_slide=>0, :mod_amp_slide_shape=>1, :mod_amp_slide_curve=>0}
    @fx << ':octaver'
    @context['fx_octaver'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :super_amp=>1, :super_amp_slide=>0, :super_amp_slide_shape=>1, :super_amp_slide_curve=>0, :sub_amp=>1, :sub_amp_slide=>0, :sub_amp_slide_shape=>1, :sub_amp_slide_curve=>0, :subsub_amp=>1, :subsub_amp_slide=>0, :subsub_amp_slide_shape=>1, :subsub_amp_slide_curve=>0}
    @fx << ':vowel'
    @context['fx_vowel'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :vowel_sound=>1, :voice=>0}
    @fx << ':flanger'
    @context['fx_flanger'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :phase=>4, :phase_slide=>0, :phase_slide_shape=>1, :phase_slide_curve=>0, :phase_offset=>0, :wave=>4, :invert_wave=>0, :stereo_invert_wave=>0, :delay=>5, :delay_slide=>0, :delay_slide_shape=>1, :delay_slide_curve=>0, :max_delay=>20, :depth=>5, :depth_slide=>0, :depth_slide_shape=>1, :depth_slide_curve=>0, :decay=>2, :decay_slide=>0, :decay_slide_shape=>1, :decay_slide_curve=>0, :feedback=>0, :feedback_slide=>0, :feedback_slide_shape=>1, :feedback_slide_curve=>0, :invert_flange=>0}
    @fx << ':eq'
    @context['fx_eq'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :low_shelf=>0, :low_shelf_slide=>0, :low_shelf_slide_shape=>1, :low_shelf_slide_curve=>0, :low_shelf_note=>43.349957, :low_shelf_note_slide=>0, :low_shelf_note_slide_shape=>1, :low_shelf_note_slide_curve=>0, :low_shelf_slope=>1, :low_shelf_slope_slide=>0, :low_shelf_slope_slide_shape=>1, :low_shelf_slope_slide_curve=>0, :low=>0, :low_slide=>0, :low_slide_shape=>1, :low_slide_curve=>0, :low_note=>59.2130948, :low_note_slide=>0, :low_note_slide_shape=>1, :low_note_slide_curve=>0, :low_q=>0.6, :low_q_slide=>0, :low_q_slide_shape=>1, :low_q_slide_curve=>0, :mid=>0, :mid_slide=>0, :mid_slide_shape=>1, :mid_slide_curve=>0, :mid_note=>83.2130948, :mid_note_slide=>0, :mid_note_slide_shape=>1, :mid_note_slide_curve=>0, :mid_q=>0.6, :mid_q_slide=>0, :mid_q_slide_shape=>1, :mid_q_slide_curve=>0, :high=>0, :high_slide=>0, :high_slide_shape=>1, :high_slide_curve=>0, :high_note=>104.9013539, :high_note_slide=>0, :high_note_slide_shape=>1, :high_note_slide_curve=>0, :high_q=>0.6, :high_q_slide=>0, :high_q_slide_shape=>1, :high_q_slide_curve=>0, :high_shelf=>0, :high_shelf_slide=>0, :high_shelf_slide_shape=>1, :high_shelf_slide_curve=>0, :high_shelf_note=>114.2326448, :high_shelf_note_slide=>0, :high_shelf_note_slide_shape=>1, :high_shelf_note_slide_curve=>0, :high_shelf_slope=>1, :high_shelf_slope_slide=>0, :high_shelf_slope_slide_shape=>1, :high_shelf_slope_slide_curve=>0}
    @fx << ':tremolo'
    @context['fx_tremolo'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :phase=>4, :phase_slide=>0, :phase_slide_shape=>1, :phase_slide_curve=>0, :phase_offset=>0, :wave=>2, :invert_wave=>0, :depth=>0.5, :depth_slide=>0, :depth_slide_shape=>1, :depth_slide_curve=>0}
    @fx << ':record'
    @context['fx_record'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :buffer=>nil}
    @fx << ':sound_out'
    @context['fx_sound_out'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :output=>1, :mode=>0}
    @fx << ':sound_out_stereo'
    @context['fx_sound_out_stereo'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :output=>1, :mode=>0}
    @fx << ':ping_pong'
    @context['fx_ping_pong'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :mix=>1, :mix_slide=>0, :mix_slide_shape=>1, :mix_slide_curve=>0, :pre_mix=>1, :pre_mix_slide=>0, :pre_mix_slide_shape=>1, :pre_mix_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :phase=>0.25, :phase_slide=>0, :phase_slide_shape=>1, :phase_slide_curve=>0, :feedback=>0.5, :feedback_slide=>0, :feedback_slide_shape=>1, :feedback_slide_curve=>0, :max_phase=>1, :pan_start=>1}

    # The samples
    @samples = [":drum_heavy_kick", ":drum_tom_mid_soft", ":drum_tom_mid_hard", ":drum_tom_lo_soft", ":drum_tom_lo_hard", ":drum_tom_hi_soft", ":drum_tom_hi_hard", ":drum_splash_soft", ":drum_splash_hard", ":drum_snare_soft", ":drum_snare_hard", ":drum_cymbal_soft", ":drum_cymbal_hard", ":drum_cymbal_open", ":drum_cymbal_closed", ":drum_cymbal_pedal", ":drum_bass_soft", ":drum_bass_hard", ":drum_cowbell", ":drum_roll", ":elec_triangle", ":elec_snare", ":elec_lo_snare", ":elec_hi_snare", ":elec_mid_snare", ":elec_cymbal", ":elec_soft_kick", ":elec_filt_snare", ":elec_fuzz_tom", ":elec_chime", ":elec_bong", ":elec_twang", ":elec_wood", ":elec_pop", ":elec_beep", ":elec_blip", ":elec_blip2", ":elec_ping", ":elec_bell", ":elec_flip", ":elec_tick", ":elec_hollow_kick", ":elec_twip", ":elec_plip", ":elec_blup", ":guit_harmonics", ":guit_e_fifths", ":guit_e_slide", ":guit_em9", ":misc_burp", ":misc_crow", ":misc_cineboom", ":perc_bell", ":perc_bell2", ":perc_snap", ":perc_snap2", ":perc_swash", ":perc_till", ":perc_door", ":perc_impact1", ":perc_impact2", ":perc_swoosh", ":ambi_soft_buzz", ":ambi_swoosh", ":ambi_drone", ":ambi_glass_hum", ":ambi_glass_rub", ":ambi_haunted_hum", ":ambi_piano", ":ambi_lunar_land", ":ambi_dark_woosh", ":ambi_choir", ":ambi_sauna", ":bass_hit_c", ":bass_hard_c", ":bass_thick_c", ":bass_drop_c", ":bass_woodsy_c", ":bass_voxy_c", ":bass_voxy_hit_c", ":bass_dnb_f", ":bass_trance_c", ":sn_dub", ":sn_dolf", ":sn_zome", ":sn_generic", ":bd_ada", ":bd_pure", ":bd_808", ":bd_zum", ":bd_gas", ":bd_sone", ":bd_haus", ":bd_zome", ":bd_boom", ":bd_klub", ":bd_fat", ":bd_tek", ":bd_mehackit", ":loop_industrial", ":loop_compus", ":loop_amen", ":loop_amen_full", ":loop_garzul", ":loop_mika", ":loop_breakbeat", ":loop_safari", ":loop_tabla", ":loop_3d_printer", ":loop_drone_g_97", ":loop_electric", ":loop_mehackit1", ":loop_mehackit2", ":loop_perc1", ":loop_perc2", ":loop_weirdo", ":tabla_tas1", ":tabla_tas2", ":tabla_tas3", ":tabla_ke1", ":tabla_ke2", ":tabla_ke3", ":tabla_na", ":tabla_na_o", ":tabla_tun1", ":tabla_tun2", ":tabla_tun3", ":tabla_te1", ":tabla_te2", ":tabla_te_ne", ":tabla_te_m", ":tabla_ghe1", ":tabla_ghe2", ":tabla_ghe3", ":tabla_ghe4", ":tabla_ghe5", ":tabla_ghe6", ":tabla_ghe7", ":tabla_ghe8", ":tabla_dhec", ":tabla_na_s", ":tabla_re", ":glitch_bass_g", ":glitch_perc1", ":glitch_perc2", ":glitch_perc3", ":glitch_perc4", ":glitch_perc5", ":glitch_robot1", ":glitch_robot2", ":vinyl_backspin", ":vinyl_rewind", ":vinyl_scratch", ":vinyl_hiss", ":mehackit_phone1", ":mehackit_phone2", ":mehackit_phone3", ":mehackit_phone4", ":mehackit_robot1", ":mehackit_robot2", ":mehackit_robot3", ":mehackit_robot4", ":mehackit_robot5", ":mehackit_robot6", ":mehackit_robot7"]
    @context['sample'] = {:amp=>1, :amp_slide=>0, :amp_slide_shape=>1, :amp_slide_curve=>0, :pre_amp=>1, :pre_amp_slide=>0, :pre_amp_slide_shape=>1, :pre_amp_slide_curve=>0, :pan=>0, :pan_slide=>0, :pan_slide_shape=>1, :pan_slide_curve=>0, :attack=>0, :decay=>0, :sustain=>-1, :release=>0, :lpf=>-1, :lpf_slide=>0, :lpf_slide_shape=>1, :lpf_slide_curve=>0, :lpf_attack=>0, :lpf_decay=>0, :lpf_sustain=>-1, :lpf_release=>0, :lpf_init_level=>-1, :lpf_attack_level=>-1, :lpf_decay_level=>-1, :lpf_sustain_level=>-1, :lpf_release_level=>-1, :lpf_env_curve=>2, :lpf_min=>-1, :lpf_min_slide=>0, :lpf_min_slide_shape=>1, :lpf_min_slide_curve=>0, :hpf=>-1, :hpf_slide=>0, :hpf_slide_shape=>1, :hpf_slide_curve=>0, :hpf_attack=>0, :hpf_sustain=>-1, :hpf_decay=>0, :hpf_release=>0, :hpf_init_level=>-1, :hpf_attack_level=>-1, :hpf_decay_level=>-1, :hpf_sustain_level=>-1, :hpf_release_level=>-1, :hpf_env_curve=>2, :hpf_max=>-1, :hpf_max_slide=>0, :hpf_max_slide_shape=>1, :hpf_max_slide_curve=>0, :attack_level=>1, :decay_level=>1, :sustain_level=>1, :env_curve=>2, :rate=>1, :start=>0, :finish=>1, :norm=>0, :pitch=>0, :pitch_slide=>0, :pitch_slide_shape=>1, :pitch_slide_curve=>0, :window_size=>0.2, :window_size_slide=>0, :window_size_slide_shape=>1, :window_size_slide_curve=>0, :pitch_dis=>0.0, :pitch_dis_slide=>0, :pitch_dis_slide_shape=>1, :pitch_dis_slide_curve=>0, :time_dis=>0.0, :time_dis_slide=>0, :time_dis_slide_shape=>1, :time_dis_slide_curve=>0, :compress=>0, :threshold=>0.2, :threshold_slide=>0, :threshold_slide_shape=>1, :threshold_slide_curve=>0, :clamp_time=>0.01, :clamp_time_slide=>0, :clamp_time_slide_shape=>1, :clamp_time_slide_curve=>0, :slope_above=>0.5, :slope_above_slide=>0, :slope_above_slide_shape=>1, :slope_above_slide_curve=>0, :slope_below=>1, :slope_below_slide=>0, :slope_below_slide_shape=>1, :slope_below_slide_curve=>0, :relax_time=>0.01, :relax_time_slide=>0, :relax_time_slide_shape=>1, :relax_time_slide_curve=>0}

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
