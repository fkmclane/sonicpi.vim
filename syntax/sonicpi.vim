" From app/server/ruby/lib/sonicpi/lang/core.rb
syntax keyword rubyKeyword assert assert_equal assert_error assert_similar at
syntax keyword rubyKeyword beat block_duration block_slept? bools bt choose
syntax keyword rubyKeyword clear cue current_beat_duration current_bpm
syntax keyword rubyKeyword current_random_seed current_sched_ahead_time
syntax keyword rubyKeyword current_time dec density dice doubles eval_file
syntax keyword rubyKeyword factor? get halves in_thread inc knit line
syntax keyword rubyKeyword load_buffer load_example look map on one_in osc
syntax keyword rubyKeyword osc_send pick print puts quantise ramp rand
syntax keyword rubyKeyword rand_back rand_i rand_i_look rand_look rand_reset
syntax keyword rubyKeyword rand_skip range rdist reset ring rrand rrand_i rt
syntax keyword rubyKeyword run_code run_file set set_sched_ahead_time! shuffle
syntax keyword rubyKeyword sleep spark spark_graph spread stop stretch sync
syntax keyword rubyKeyword sync_bpm tick tick_reset tick_reset_all tick_set
syntax keyword rubyKeyword time_warp uncomment use_bpm use_bpm_mul
syntax keyword rubyKeyword use_cue_logging use_osc use_osc_logging
syntax keyword rubyKeyword use_random_seed use_real_time use_sched_ahead_time
syntax keyword rubyKeyword vector version vt wait with_bpm with_bpm_mul
syntax keyword rubyKeyword with_cue_logging with_osc with_osc_logging
syntax keyword rubyKeyword with_random_seed with_real_time
syntax keyword rubyKeyword with_sched_ahead_time with_swing
syntax keyword rubyDefine define defonce
syntax keyword rubyRepeat live_loop loop
syntax region rubyComment start="\<comment\>" end="\<end\>" contains=rubySpaceError,rubyTodo
syntax region rubyComment start="\<ndefine\>" end="\<end\>" contains=rubySpaceError,rubyTodo

" From app/server/ruby/lib/sonicpi/lang/sound.rb
syntax keyword rubyKeyword all_sample_names buffer control current_arg_checks
syntax keyword rubyKeyword current_debug current_sample_defaults current_synth
syntax keyword rubyKeyword current_synth_defaults current_volume fx_names kill
syntax keyword rubyKeyword live_audio load_sample load_samples load_synthdefs
syntax keyword rubyKeyword play play_chord play_pattern play_pattern_timed
syntax keyword rubyKeyword recording_delete recording_save recording_start
syntax keyword rubyKeyword recording_stop reset_mixer! sample sample_buffer
syntax keyword rubyKeyword sample_duration sample_free sample_free_all
syntax keyword rubyKeyword sample_groups sample_info sample_loaded?
syntax keyword rubyKeyword sample_names sample_paths scsynth_info
syntax keyword rubyKeyword set_audio_latency! set_control_delta!
syntax keyword rubyKeyword set_mixer_control! set_recording_bit_depth!
syntax keyword rubyKeyword set_volume! status synth synth_names
syntax keyword rubyKeyword use_arg_bpm_scaling use_arg_checks use_debug
syntax keyword rubyKeyword use_merged_sample_defaults use_merged_synth_defaults
syntax keyword rubyKeyword use_sample_bpm use_sample_defaults use_synth
syntax keyword rubyKeyword use_synth_defaults use_timing_guarantees
syntax keyword rubyKeyword with_arg_bpm_scaling with_arg_checks with_debug
syntax keyword rubyKeyword with_fx with_merged_sample_defaults
syntax keyword rubyKeyword with_merged_synth_defaults with_sample_bpm
syntax keyword rubyKeyword with_sample_defaults with_synth with_synth_defaults
syntax keyword rubyKeyword with_timing_guarantees

" From app/server/ruby/lib/sonicpi/lang/pattern.rb
syntax keyword rubyKeyword play_nested_pattern

" From app/server/ruby/lib/sonicpi/lang/western_theory.rb
syntax keyword rubyKeyword chord chord_degree chord_invert chord_names
syntax keyword rubyKeyword current_cent_tuning current_octave current_transpose
syntax keyword rubyKeyword degree hz_to_midi midi_notes midi_to_hz note
syntax keyword rubyKeyword note_info note_range octs pitch_to_ratio
syntax keyword rubyKeyword ratio_to_pitch rest? scale scale_names
syntax keyword rubyKeyword set_cent_tuning! use_cent_tuning use_octave
syntax keyword rubyKeyword use_transpose use_tuning with_cent_tuning
syntax keyword rubyKeyword with_octave with_transpose with_tuning

" From app/server/ruby/lib/sonicpi/lang/maths.rb
syntax keyword rubyKeyword math_scale

" From app/server/ruby/lib/sonicpi/lang/midi.rb
syntax keyword rubyKeyword current_midi_defaults midi midi_all_notes_off
syntax keyword rubyKeyword midi_cc midi_channel_pressure midi_clock_beat
syntax keyword rubyKeyword midi_clock_tick midi_continue midi_local_control_off
syntax keyword rubyKeyword midi_local_control_on midi_mode midi_note_off
syntax keyword rubyKeyword midi_note_on midi_pc midi_pitch_bend
syntax keyword rubyKeyword midi_poly_pressure midi_raw midi_reset
syntax keyword rubyKeyword midi_sound_off midi_start midi_stop midi_sysex
syntax keyword rubyKeyword use_merged_midi_defaults use_midi_defaults
syntax keyword rubyKeyword use_midi_logging with_merged_midi_defaults
syntax keyword rubyKeyword with_midi_defaults with_midi_logging

" From app/server/ruby/lib/sonicpi/lang/minecraftpi.rb
syntax keyword rubyKeyword mc_block_id mc_block_ids mc_block_name
syntax keyword rubyKeyword mc_block_names mc_camera_fixed mc_camera_normal
syntax keyword rubyKeyword mc_camera_set_location mc_camera_third_person
syntax keyword rubyKeyword mc_chat_post mc_checkpoint_restore
syntax keyword rubyKeyword mc_checkpoint_save mc_get_block mc_get_height
syntax keyword rubyKeyword mc_get_pos mc_get_tile mc_ground_height mc_location
syntax keyword rubyKeyword mc_message mc_set_area mc_set_block mc_set_pos
syntax keyword rubyKeyword mc_set_tile mc_surface_teleport mc_teleport
