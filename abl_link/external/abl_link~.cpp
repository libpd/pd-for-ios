/*
 *  For information on usage and redistribution, and for a DISCLAIMER OF ALL
 *  WARRANTIES, see the file, "LICENSE.md," in this directory.
 *
 */

#include "abl_link~.hpp"

#include <math.h>
#include <stdio.h>
#include <string.h>

#include "abl_link_instance.hpp"
#include "m_pd.h"

static t_class *abl_link_tilde_class;

typedef struct _abl_link_tilde {
  t_object obj;
  t_clock *clock;
  t_outlet *step_out;
  t_outlet *phase_out;
  t_outlet *beat_out;
  t_outlet *tempo_out;
  double steps_per_beat;
  double prev_beat_time;
  double quantum;
  double tempo;
  int reset_flag;
  std::shared_ptr<abl_link::AblLinkWrapper> link;
} t_abl_link_tilde;

static void abl_link_tilde_enable(t_abl_link_tilde *x, t_floatarg enabled) {
  x->link->enable(enabled);
}

static t_int *abl_link_tilde_perform(t_int *w) {
  t_abl_link_tilde *x = (t_abl_link_tilde *)(w[1]);
  clock_delay(x->clock, 0);
  return (w+2);
}

static void abl_link_tilde_dsp(t_abl_link_tilde *x, t_signal **sp) {
  dsp_add(abl_link_tilde_perform, 1, x);
}

static void abl_link_tilde_tick(t_abl_link_tilde *x) {
  std::chrono::microseconds curr_time;
  auto& timeline = x->link->acquireAudioTimeline(&curr_time);
  if (x->tempo < 0) {
    timeline.setTempo(-x->tempo, curr_time);
  }
  const double prev_tempo = x->tempo;
  x->tempo = timeline.tempo();
  if (prev_tempo != x->tempo) {
    outlet_float(x->tempo_out, x->tempo);
  }
  double curr_beat_time;
  if (x->reset_flag) {
    timeline.requestBeatAtTime(x->prev_beat_time, curr_time, x->quantum);
    curr_beat_time = timeline.beatAtTime(curr_time, x->quantum);
    x->prev_beat_time = curr_beat_time - 1e-6;
    x->reset_flag = 0;
  } else {
    curr_beat_time = timeline.beatAtTime(curr_time, x->quantum);
  }
  outlet_float(x->beat_out, curr_beat_time);
  const double curr_phase = fmod(curr_beat_time, x->quantum);
  outlet_float(x->phase_out, curr_phase);
  if (curr_beat_time > x->prev_beat_time) {
    const double prev_phase = fmod(x->prev_beat_time, x->quantum);
    const double prev_step = floor(prev_phase * x->steps_per_beat);
    const double curr_step = floor(curr_phase * x->steps_per_beat);
    if (prev_phase - curr_phase > x->quantum / 2 || prev_step != curr_step) {
      outlet_float(x->step_out, curr_step);
    }
  }
  x->prev_beat_time = curr_beat_time;
  x->link->releaseAudioTimeline();
}

static void abl_link_tilde_set_tempo(t_abl_link_tilde *x, t_floatarg bpm) {
  x->tempo = -bpm;  // Negative values signal tempo changes.
}

static void abl_link_tilde_set_resolution(t_abl_link_tilde *x,
    t_floatarg steps_per_beat) {
  x->steps_per_beat = steps_per_beat;
}

static void abl_link_tilde_reset(t_abl_link_tilde *x, t_symbol *s,
    int argc, t_atom *argv) {
  x->prev_beat_time = 0;
  x->reset_flag = 1;
  switch (argc) {
    default:
      error("abl_link~ reset: Unexpected number of parameters: %d", argc);
    case 2:
      x->quantum = atom_getfloat(argv + 1);
    case 1:
      x->prev_beat_time = atom_getfloat(argv);
    case 0:
      break;
  }
}

static void *abl_link_tilde_new(t_symbol *s, int argc, t_atom *argv) {
  t_abl_link_tilde *x = (t_abl_link_tilde *)pd_new(abl_link_tilde_class);
  x->clock = clock_new(x, (t_method)abl_link_tilde_tick);
  x->step_out = outlet_new(&x->obj, &s_float);
  x->phase_out = outlet_new(&x->obj, &s_float);
  x->beat_out = outlet_new(&x->obj, &s_float);
  x->tempo_out = outlet_new(&x->obj, &s_float);
  x->steps_per_beat = 1;
  x->prev_beat_time = 0;
  x->quantum = 4;
  x->tempo = 0;
  x->reset_flag = 1;
  double initial_tempo = 120.0;
  switch (argc) {
    default:
      error("abl_link~: Unexpected number of creation args: %d", argc);
    case 4:
      initial_tempo = atom_getfloat(argv + 3);
    case 3:
      x->quantum = atom_getfloat(argv + 2);
    case 2:
      x->prev_beat_time = atom_getfloat(argv + 1);
    case 1:
      x->steps_per_beat = atom_getfloat(argv);
    case 0:
      break;
  }
  x->link = abl_link::AblLinkWrapper::getSharedInstance(initial_tempo);
  return x;
}

static void abl_link_tilde_free(t_abl_link_tilde *x) {
  clock_free(x->clock);
  x->link = nullptr;
}

extern "C" {

void abl_link_tilde_setup() {
  abl_link_tilde_class = class_new(gensym("abl_link~"),
                   (t_newmethod)abl_link_tilde_new,
                   (t_method)abl_link_tilde_free,
                   sizeof(t_abl_link_tilde), CLASS_DEFAULT, A_GIMME, 0);
  class_addmethod(abl_link_tilde_class, (t_method)abl_link_tilde_dsp,
          gensym("dsp"), A_NULL);
  class_addmethod(abl_link_tilde_class, (t_method)abl_link_tilde_enable,
          gensym("connect"), A_DEFFLOAT, 0);
  class_addmethod(abl_link_tilde_class, (t_method)abl_link_tilde_set_tempo,
          gensym("tempo"), A_DEFFLOAT, 0);
  class_addmethod(abl_link_tilde_class, (t_method)abl_link_tilde_set_resolution,
          gensym("resolution"), A_DEFFLOAT, 0);
  class_addmethod(abl_link_tilde_class, (t_method)abl_link_tilde_reset,
          gensym("reset"), A_GIMME, 0);
}

} //extern "C" 

