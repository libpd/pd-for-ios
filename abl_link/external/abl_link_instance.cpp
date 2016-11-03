/*
 *  For information on usage and redistribution, and for a DISCLAIMER OF ALL
 *  WARRANTIES, see the file, "LICENSE.md," in this directory.
 *
 */

#include "abl_link_instance.hpp"

#include "s_stuff.h"  // Only for DEFDACBLKSIZE.

namespace abl_link {

// Eyeball estimate for latency compensation: Pd's reported delay (5ms) plus
// the duration of one Pd buffer (1.4ms at 44.1kHz), rounded up to the next
// integer.
// TODO: Come up with a more scientific way of estimating the offset.
#ifndef ABL_LINK_OFFSET_MS
#define ABL_LINK_OFFSET_MS 7
#endif
static constexpr auto kLatencyOffset =
    std::chrono::milliseconds(ABL_LINK_OFFSET_MS);

std::weak_ptr<AblLinkWrapper> AblLinkWrapper::shared_instance;

AblLinkWrapper::AblLinkWrapper(double bpm) :
    link(bpm),
    timeline(ableton::link::Timeline(), false),
    time_filter(
        ableton::link::HostTimeFilter<ableton::link::platform::Clock>()),
    num_peers_sym(gensym("#abl_link_num_peers")),
    num_peers(-1),
    sample_time(0.0),
    invocation_count(0) {
  post("Created new Link instance with tempo %f.", bpm);
}

void AblLinkWrapper::enable(bool enabled) { link.enable(enabled); }

ableton::Link::Timeline& AblLinkWrapper::acquireAudioTimeline(
    std::chrono::microseconds *current_time) {
  if (invocation_count++ == 0) {
    const int n = link.numPeers();
    if (n != num_peers && num_peers_sym->s_thing) {
      pd_float(num_peers_sym->s_thing, n);
      num_peers = n;
    }
    timeline = link.captureAudioTimeline();
    sample_time += DEFDACBLKSIZE;
    curr_time = time_filter.sampleTimeToHostTime(sample_time) + kLatencyOffset;
  }
  *current_time = curr_time;
  return timeline;
}

void AblLinkWrapper::releaseAudioTimeline() {
  if (invocation_count >= shared_instance.use_count()) {
    link.commitAudioTimeline(timeline);
    invocation_count = 0;
  }
}

std::shared_ptr<AblLinkWrapper>
    AblLinkWrapper::getSharedInstance(double bpm) {
  auto ptr = shared_instance.lock();
  if (!ptr) {
    ptr.reset(new AblLinkWrapper(bpm));
    shared_instance = ptr;
  } else {
    post("Using existing Link instance with ref count %d.", ptr.use_count());
  }
  return ptr;
}

}  // namespace abl_link
