// The seqmid.h files contains a bunch of macros which aren't handled by the bindings generator, so they've been
// extracted by hand here.

snd_seq_ev_clear :: (ev: *snd_seq_event_t) {
    memset(ev, 0, size_of(snd_seq_event_t));
}

snd_seq_ev_set_tag :: (ev: *snd_seq_event_t, tag: u8) {
    ev.tag = tag;
}

snd_seq_ev_set_dest :: (ev: *snd_seq_event_t, client: u8, port: u8) {
    ev.dest.client = client;
    ev.dest.port = port;
}

snd_seq_ev_set_subs :: (ev: *snd_seq_event_t) {
    ev.dest.client = (cast,no_check(u8) SND_SEQ_ADDRESS_SUBSCRIBERS);
    ev.dest.port = (cast,no_check(u8) SND_SEQ_ADDRESS_UNKNOWN);
}

snd_seq_ev_set_broadcast :: (ev: *snd_seq_event_t) {
    ev.dest.client = (cast,no_check(u8) SND_SEQ_ADDRESS_BROADCAST);
    ev.dest.port = (cast,no_check(u8) SND_SEQ_ADDRESS_BROADCAST);
}

snd_seq_ev_set_source :: (ev: *snd_seq_event_t, port: u8) {
    ev.source.port = port;
}

snd_seq_ev_set_direct :: (ev: *snd_seq_event_t) {
    ev.queue = (cast,no_check(u8) SND_SEQ_QUEUE_DIRECT);
}

snd_seq_ev_schedule_tick :: (ev: *snd_seq_event_t, queue: u8, relative: bool, ttick: snd_seq_tick_time_t) {
    ev.flags &= ~(cast,no_check(u8) (SND_SEQ_TIME_STAMP_MASK | SND_SEQ_TIME_MODE_MASK));
    ev.flags |= (cast,no_check(u8) SND_SEQ_TIME_STAMP_TICK);
    ev.flags |= ifx relative then (cast,no_check(u8) SND_SEQ_TIME_MODE_REL) else (cast,no_check(u8) SND_SEQ_TIME_MODE_ABS);
    ev.time.tick = ttick;
    ev.queue = queue;
}

snd_seq_ev_schedule_real :: (ev: *snd_seq_event_t, queue: u8, relative: bool, rtime: *snd_seq_real_time_t) {
    ev.flags &= ~((cast,no_check(u8) SND_SEQ_TIME_STAMP_MASK) | (cast,no_check(u8) SND_SEQ_TIME_MODE_MASK));
    ev.flags |= (cast,no_check(u8) SND_SEQ_TIME_STAMP_REAL);
    ev.flags |= ifx relative then (cast,no_check(u8) SND_SEQ_TIME_MODE_REL) else (cast,no_check(u8) SND_SEQ_TIME_MODE_ABS);
    ev.time.time = <<rtime;
    ev.queue = queue;
}

snd_seq_ev_set_priority :: (ev: *snd_seq_event_t, high_priority: bool) {
    ev.flags &= ~(cast,no_check(u8) SND_SEQ_PRIORITY_MASK);
    ev.flags |= ifx high_priority then (cast,no_check(u8) SND_SEQ_PRIORITY_HIGH) else (cast,no_check(u8) SND_SEQ_PRIORITY_NORMAL);
}

snd_seq_ev_set_fixed :: (ev: *snd_seq_event_t) {
    ev.flags &= ~(cast,no_check(u8) SND_SEQ_EVENT_LENGTH_MASK);
    ev.flags |= (cast,no_check(u8) SND_SEQ_EVENT_LENGTH_FIXED);
}

snd_seq_ev_set_variable :: (ev: *snd_seq_event_t, datalen: u32, dataptr: *void) {
    ev.flags &= ~(cast,no_check(u8) SND_SEQ_EVENT_LENGTH_MASK);
    ev.flags |= (cast,no_check(u8) SND_SEQ_EVENT_LENGTH_VARIABLE);
    ev.data.ext.len = datalen;
    ev.data.ext.ptr = dataptr;
}

snd_seq_ev_set_varusr :: (ev: *snd_seq_event_t, datalen: u32, dataptr: *void) {
    ev.flags &= ~(cast,no_check(u8) SND_SEQ_EVENT_LENGTH_MASK);
    ev.flags |= (cast,no_check(u8) SND_SEQ_EVENT_LENGTH_VARUSR);
    ev.data.ext.len = datalen;
    ev.data.ext.ptr = dataptr;
}

snd_seq_ev_set_queue_control :: (ev: *snd_seq_event_t, type: snd_seq_event_type_t, queue: u8, value: s32) {
    ev.type = type;
    snd_seq_ev_set_dest(ev, (cast,no_check(u8) SND_SEQ_CLIENT_SYSTEM), (cast,no_check(u8) SND_SEQ_PORT_SYSTEM_TIMER));
    ev.data.queue.queue = queue;
    ev.data.queue.param.value = value;
}

snd_seq_ev_set_queue_start :: (ev: *snd_seq_event_t, queue: u8) {
    snd_seq_ev_set_queue_control(ev, snd_seq_event_type.START, queue, 0);
}

snd_seq_ev_set_queue_stop :: (ev: *snd_seq_event_t, queue: u8) {
    snd_seq_ev_set_queue_control(ev, snd_seq_event_type.STOP, queue, 0);
}

snd_seq_ev_set_queue_continue :: (ev: *snd_seq_event_t, queue: u8) {
    snd_seq_ev_set_queue_control(ev, snd_seq_event_type.CONTINUE, queue, 0);
}

snd_seq_ev_set_queue_tempo :: (ev: *snd_seq_event_t, queue: u8, value: s32) {
    snd_seq_ev_set_queue_control(ev, snd_seq_event_type.TEMPO, queue, value);
}

snd_seq_ev_set_queue_pos_real :: (ev: *snd_seq_event_t, queue: u8, rtime: snd_seq_real_time_t) {
    ev.type = snd_seq_event_type.SND_SEQ_EVENT_SETPOS_TIME;
    snd_seq_ev_set_dest(ev, (cast,no_check(u8) SND_SEQ_CLIENT_SYSTEM), (cast,no_check(u8) SND_SEQ_PORT_SYSTEM_TIMER));
    ev.data.queue.queue = queue;
    ev.data.queue.param.time.time = *rtime;
}

snd_seq_ev_set_queue_pos_tick :: (ev: *snd_seq_event_t, queue: u8, ttime: snd_seq_tick_time_t) {
    ev.type = snd_seq_event_type.SETPOS_TICK;
    snd_seq_ev_set_dest(ev, (cast,no_check(u8) SND_SEQ_CLIENT_SYSTEM), (cast,no_check(u8) SND_SEQ_PORT_SYSTEM_TIMER));
    ev.data.queue.queue = queue;
    ev.data.queue.param.time.tick = ttime;
}

snd_seq_start_queue :: (seq: *snd_seq_t, queue: u8, ev: *snd_seq_event_t) {
    snd_seq_control_queue(seq, queue, xx snd_seq_event_type.START, 0, ev);
}

snd_seq_stop_queue :: (seq: *snd_seq_t, queue: u8, ev: *snd_seq_event_t) {
    snd_seq_control_queue(seq, queue, xx snd_seq_event_type.STOP, 0, ev);
}

snd_seq_continue_queue :: (seq: *snd_seq_t, queue: u8, ev: *snd_seq_event_t) {
    snd_seq_control_queue(seq, queue, xx snd_seq_event_type.CONTINUE, 0, ev);
}

snd_seq_change_queue_tempo :: (seq: *snd_seq_t, queue: u8, tempo: s32, ev: *snd_seq_event_t) {
    snd_seq_control_queue(seq, queue, xx snd_seq_event_type.TEMPO, tempo, ev);
}

snd_seq_ev_set_note :: (ev: *snd_seq_event_t, ch: u8, key: u8, vel: u8, dur: u8) {
    ev.type = snd_seq_event_type.NOTE;
    snd_seq_ev_set_fixed(ev);
    ev.data.note.channel = ch;
    ev.data.note.note = key;
    ev.data.note.velocity = vel;
    ev.data.note.duration = dur;
}

snd_seq_ev_set_noteon :: (ev: *snd_seq_event_t, ch: u8, key: u8, vel: u8) {
    ev.type = snd_seq_event_type.NOTEON;
    snd_seq_ev_set_fixed(ev);
    ev.data.note.channel = ch;
    ev.data.note.note = key;
    ev.data.note.velocity = vel;
}

snd_seq_ev_set_noteoff :: (ev: *snd_seq_event_t, ch: u8, key: u8, vel: u8) {
    ev.type = snd_seq_event_type.NOTEOFF;
    snd_seq_ev_set_fixed(ev);
    ev.data.note.channel = ch;
    ev.data.note.note = key;
    ev.data.note.velocity = vel;
}

snd_seq_ev_set_keypress :: (ev: *snd_seq_event_t, ch: u8, key: u8, vel: u8) {
    ev.type = snd_seq_event_type.KEYPRESS;
    snd_seq_ev_set_fixed(ev);
    ev.data.note.channel = ch;
    ev.data.note.note = key;
    ev.data.note.velocity = vel;
}

snd_seq_ev_set_controller :: (ev: *snd_seq_event_t, ch: u8, key: u8, cc: u8, val: u8) {
    ev.type = snd_seq_event_type.CONTROLLER;
    snd_seq_ev_set_fixed(ev);
    ev.data.control.channel = ch;
    ev.data.control.param = cc;
    ev.data.control.value = val;
}

snd_seq_ev_set_pgmchange :: (ev: *snd_seq_event_t, ch: u8, val: u8) {
    ev.type = snd_seq_event_type.PGMCHANGE;
    snd_seq_ev_set_fixed(ev);
    ev.data.control.channel = ch;
    ev.data.control.value = val;
}

snd_seq_ev_set_pitchbend :: (ev: *snd_seq_event_t, ch: u8, val: u8) {
    ev.type = snd_seq_event_type.PITCHBEND;
    snd_seq_ev_set_fixed(ev);
    ev.data.control.channel = ch;
    ev.data.control.value = val;
}

snd_seq_ev_set_chanpress :: (ev: *snd_seq_event_t, ch: u8, val: u8) {
    ev.type = snd_seq_event_type.CHANPRESS;
    snd_seq_ev_set_fixed(ev);
    ev.data.control.channel = ch;
    ev.data.control.value = val;
}

snd_seq_ev_set_sysex :: (ev: *snd_seq_event_t, datalen: u32, dataptr: *void) {
    ev.type = snd_seq_event_type.SYSEX;
    snd_seq_ev_set_variable(ev, datalen, dataptr);
}
