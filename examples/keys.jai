// This program draws a piano keyboard, showing which keys are pressed based on the MIDI input that is selected. Making
// it generate sound is left as an exercise to the reader!

#import "Basic";
#import "Math";
#import "String";
#import "GetRect";
#import "Window_Creation";
#import "Random";

Simp  :: #import "Simp";
Input :: #import "Input";

#import,file "../module.jai";

#if OS == .WINDOWS {
    Windows_UTF8 :: #import "Windows_Utf8";
}

APP_NAME :: "Keys";

KEYBOARD_HEIGHT :: 180.0;
PADDING :: 4.0;

KEYBOARD_BACKGROUND_COLOR :: Vector4.{0.11, 0.11, 0.11, 1.0};
PRESSED_KEY_COLOR         :: Vector4.{0.2, 0.9, 0.7, 1.0};
GAUGE_BACKGROUND_COLOR    :: Vector4.{0.3, 0.1, 0.1, 1.0};
GAUGE_ACTIVITY_COLOR      :: PRESSED_KEY_COLOR; //Vector4.{0.2, 0.5, 0.5, 1.0};

my_window: Window_Type;
window_width:  s32 = 1280;
window_height: s32 = 400;
dropped_files: [..] string;
current_time: float64;
last_time:    float64;
mouse_button_left_state: Input.Key_Current_State;

input: *MIDI_Input;
connected_source := -1;
selected_source: s32;
available_sources: [..] string;

pressed_keys: [256] bool;
pitch_bend := 0.0;
cc_value := 0.0;
cc_index := 1;
time_since_last_input := 10.0;

clear_pressed_keys :: () {
    for 0..pressed_keys.count - 1  pressed_keys[it] = false;
}

midi_input_callback :: (input: *MIDI_Input, message: MIDI_Message, timestamp: Apollo_Time, user_data: *void) {
    time_since_last_input = 0.0;

    if message.status == {
        case .Note_On; {
            pressed_keys[message.note_info.note] = message.note_info.velocity > 0;
        }
        case .Note_Off; {
            pressed_keys[message.note_info.note] = false;
        }
        case .Pitch_Bend; {
            pitch_bend = pitch_bend_get_float(message.pitch_bend_info);
        }
        case .Control_Change; {
            cc_value = message.control_change_info.value / 127.0;
            cc_index = message.control_change_info.controller;
        }
    }
}

main :: () {
    screen_width  := 0;
    screen_height := 0;

    window_x := 200;
    window_y := 200;

    #if OS == .WINDOWS {
        Windows.SetProcessDPIAware();
        Windows.timeBeginPeriod(1);
    }

    my_window = create_window(window_width, window_height, APP_NAME, xx window_x, xx window_y);
    Simp.set_render_target(my_window);
    ui_init();

    update_sources();

    quit := false;
    while !quit {
        current_time = get_time();
        dt := cast(float)(current_time - last_time);
        Clamp(*dt, 0, 0.1);
        last_time = current_time;

        Input.update_window_events();

        for Input.get_window_resizes() {
            Simp.update_window(it.window);

            if it.window == my_window {
                should_reinit := (it.width != window_width) || (it.height != window_height);
                window_width  = it.width;
                window_height = it.height;
            }
        }

        mouse_button_left_state = ui_get_button_state(.MOUSE_BUTTON_LEFT);

        for event: Input.events_this_frame {
            if event.type == .QUIT then quit = true;

            getrect_handle_event(event);

            if event.type == {
                case .KEYBOARD;
                if event.key_pressed && event.key_code == .ESCAPE {
                    active_widget_deactivate_all();
                    // #if DEBUG  quit = true;
                    quit = true;
                }
            }
        }

        if selected_source != connected_source {
            close_input(input);
            source_index := selected_source - 1; // - 1 because the first item in the dropdown is a dummy.

            clear_pressed_keys();
            if selected_source > 0 {
                input = open_input(source_index, midi_input_callback);
            }

            connected_source = selected_source;
        }

        draw_one_frame();

        reset_temporary_storage();

        time_since_last_input += dt;
    }

    if input  close_input(input);
}

update_sources :: () {
    array_reset(*available_sources);

    array_add(*available_sources, "MIDI Input");

    number_of_sources := get_number_of_sources();
    for 0..number_of_sources - 1 {
        source_name := get_source_name(it);
        array_add(*available_sources, copy_string(trim(source_name))); // @Leak
    }
}

draw_one_frame :: () {
    Simp.clear_render_target(KEYBOARD_BACKGROUND_COLOR.x, KEYBOARD_BACKGROUND_COLOR.y, KEYBOARD_BACKGROUND_COLOR.z, 1);

    x, y, width, height := get_dimensions(my_window, true);
    ui_per_frame_update(my_window, width, height, current_time);

    dropdown_rect := get_rect(2 * PADDING, xx window_height, 500.0, 26.0);
    dropdown_rect.y -= dropdown_rect.h + 1.5 * PADDING;
    dropdown(dropdown_rect, available_sources, *selected_source);

    label_rect := dropdown_rect;
    label_rect.x += dropdown_rect.w + 10.0;
    label_theme: Label_Theme;
    label_theme.alignment = .Left;
 	label_theme.text_color = .{.8, .8, .8, 1};
    label_theme.alignment_pad_ems = 0.0;

    {
        INACTIVE_COLOR :: Vector4.{0.3, 0.3, 0.3, 1.0};
        ACTIVE_COLOR :: Vector4.{0.5, 1.0, 0.6, 1.0};
        TIME_FULL :: 0.3;
        TIME_FADE :: 0.9;

        activity_light_size := 8.0;
        activity_light_rect := get_rect(label_rect.x, label_rect.y + 0.5 * (dropdown_rect.h - activity_light_size), activity_light_size, activity_light_size);
        color := INACTIVE_COLOR;
        if time_since_last_input < TIME_FULL  color  = ACTIVE_COLOR;
        else if time_since_last_input < TIME_FADE  color = lerp(INACTIVE_COLOR, ACTIVE_COLOR, (TIME_FADE - time_since_last_input) / TIME_FADE);
        immediate_rect(activity_light_rect, color);
        label_rect.x += 6.0 + activity_light_size;
    }

    if selected_source > 0 {
        if input {
            label(label_rect, "Connected", *label_theme);
        } else {
            label(label_rect, "Error!", *label_theme);
        }
    }

    draw_gauges();

    draw_keyboard();

    draw_popups();

    Simp.swap_buffers(my_window);
}

draw_keyboard :: () {
    PIANO_MIDI_START_INDEX :: 21; // A-1
    PIANO_MIDI_END_INDEX :: 108; // C7

    padding := 4.0;
    key_border := 10.0;
    key_padding := 2.0;

    black_key_height_factor := 0.6;
    black_key_width_factor := 0.5;
    black_key_border := 2.0;

    keyboard_rect_no_pad := get_rect(0, 0, xx window_width, KEYBOARD_HEIGHT + 2 * padding);
    keyboard_rect := get_rect(padding, padding, window_width - 2 * padding, KEYBOARD_HEIGHT);

    first_key_rect := keyboard_rect;
    first_key_rect.w /= 52.0;
    first_key_rect.w -= 51.0 * key_padding / 52.0;

    Simp.set_shader_for_color();

    immediate_rect(keyboard_rect_no_pad, KEYBOARD_BACKGROUND_COLOR);

    is_sharp_or_flat :: (note_index: int) -> bool {
        n := note_index % 12;
        return n == 1 || n == 3 || n == 6 || n == 8 || n == 10;
    }

    // Draw white keys.
    key_rect := first_key_rect;

    for PIANO_MIDI_START_INDEX..PIANO_MIDI_END_INDEX {
        if is_sharp_or_flat(it)  continue;

        key_color := Vector4.{0.95, 0.95, 0.95, 1.0};
        if pressed_keys[it]  key_color = PRESSED_KEY_COLOR;
        immediate_rect(key_rect, key_color);
        key_rect.x += key_rect.w + key_padding;
    }

    // Draw black keys.
    key_rect = first_key_rect;

    for PIANO_MIDI_START_INDEX..PIANO_MIDI_END_INDEX {
        if is_sharp_or_flat(it) {
            black_key_rect := key_rect;
            black_key_rect.w *= black_key_width_factor;
            black_key_rect.h *= black_key_height_factor;
            black_key_rect.y += key_rect.h - black_key_rect.h;
            black_key_rect.x -= 0.5 * (black_key_rect.w + key_padding);

            n := it % 12;
            if n == 1 || n == 6   black_key_rect.x -= 1.0;
            if n == 3 || n == 10  black_key_rect.x += 1.0;

            black_key_backing_rect := black_key_rect;
            black_key_backing_rect.x -= black_key_border;
            black_key_backing_rect.w += 2 * black_key_border;
            black_key_backing_rect.y -= black_key_border;
            black_key_backing_rect.h += black_key_border;
            immediate_rect(black_key_backing_rect, KEYBOARD_BACKGROUND_COLOR);

            key_color := Vector4.{0.1, 0.1, 0.1, 1.0};
            if pressed_keys[it]  key_color = PRESSED_KEY_COLOR;
            immediate_rect(black_key_rect, key_color);
        } else {
            key_rect.x += key_rect.w + key_padding;
        }
    }
}

// Draw gauges for pitch bend and CC messages.
draw_gauges :: () {
    label_theme: Label_Theme;
    label_theme.alignment = .Center;
 	label_theme.text_color = .{.8, .8, .8, 1};
    label_theme.alignment_pad_ems = 0.0;

    GAUGE_WIDTH :: 300.0;
    GAUGE_HEIGHT :: 24.0;

    Simp.set_shader_for_color();
    rect := get_rect(0.5 * window_width - GAUGE_WIDTH - PADDING, KEYBOARD_HEIGHT + 3 * PADDING, GAUGE_WIDTH, GAUGE_HEIGHT);
    immediate_rect(rect, GAUGE_BACKGROUND_COLOR);
    active_rect := rect;
    active_rect.x += 0.5 * rect.w;
    active_rect.w *= 0.5 * pitch_bend;
    immediate_rect(active_rect, GAUGE_ACTIVITY_COLOR);
    label_rect := rect;
    label_rect.y += rect.h;
    label(label_rect, tprint("Pitch Bend: %", formatFloat(pitch_bend, trailing_width=2, zero_removal=.NO)), *label_theme);

    Simp.set_shader_for_color();
    rect.x += rect.w + 2 * PADDING;
    immediate_rect(rect, GAUGE_BACKGROUND_COLOR);
    active_rect = rect;
    active_rect.w *= cc_value;
    immediate_rect(active_rect, GAUGE_ACTIVITY_COLOR);
    label_rect = rect;
    label_rect.y += rect.h;
    label(label_rect, tprint("CC %: %", cc_index, formatFloat(cc_value, trailing_width=2, zero_removal=.NO)), *label_theme);
}

immediate_rect :: (rect: Rect, color: Vector4) {
    p0, p1, p2, p3 := get_quad(rect);
    Simp.immediate_quad(p0, p1, p2, p3, color);
}
