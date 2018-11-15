`timescale 1ns / 1ps

module main(
    input clk, 
    input reset_SW, load_SW, fastfwd_SW, alarm_off_SW,
    input moveRight_BTN, moveLeft_BTN, increment_BTN, decrement_BTN,
    output outsignal_counter, outsignal_time,
    output [7:0] timer_seven_seg, AN,
    output audioOut, aud_sd
    );
    
    wire [3:0] seconds_ones, minutes_ones, load_minutes_ones;
    wire [2:0] seconds_tens, minutes_tens, load_minutes_tens;
    
    wire [3:0] out_seconds_ones, out_minutes_ones;
    wire [2:0] out_seconds_tens, out_minutes_tens;
    
    wire [7:0] timer_seconds_ones, timer_seconds_tens, timer_minutes_ones, timer_minutes_tens;
    
    wire [1:0] two_bit_count;
    wire [3:0] enable_signal;
    
    // generate 1Hz and 400Hz clock signal
    clock_generator clk_module(clk, reset_SW, fastfwd_SW, outsignal_counter, outsignal_time);
    
    // 2-bit counter, counts up to 3 inclusive
    // 400Hz clock signal input
    // 2-bit counter output
    two_bit_counter two_counter(outsignal_time, two_bit_count);
    
    // 2 to 4 decoder
    // 2-bit counter input
    // 8 bit enable output
    two_four_decoder two_decoder(two_bit_count, enable_signal);

    // count up to 5 for the ten's digit and 9 for the one's digit inclusive
    counter_60 second_counter(reset_SW, load_SW, outsignal_counter, seconds_ones, seconds_tens, min);
    counter_60 minute_counter(reset_SW, load_SW, min, minutes_ones, minutes_tens, hrs);
    
    // set alarm
    wire test_signal = moveRight_BTN | moveLeft_BTN | increment_BTN | decrement_BTN;
    set_alarm set_time(test_signal, load_SW, moveRight_BTN, moveLeft_BTN, increment_BTN, decrement_BTN, load_minutes_ones, load_minutes_tens);
    
    // display clock or set alarm
    display_clock clock_alarm(
        load_SW, 
        seconds_ones, minutes_ones, load_minutes_ones, 
        seconds_tens, minutes_tens, load_minutes_tens,
        out_seconds_ones, out_minutes_ones, 
        out_seconds_tens, out_minutes_tens
    );
    
    // seven segment decoder
    seven_seg_decoder seconds_decoder(out_seconds_ones, out_seconds_tens, timer_seconds_ones, timer_seconds_tens);
    seven_seg_decoder minutes_decoder(out_minutes_ones, out_minutes_tens, timer_minutes_ones, timer_minutes_tens);
    
    // four to one multiplexer
    four_one_mux four_mux(timer_seconds_ones, timer_seconds_tens, timer_minutes_ones, timer_minutes_tens, two_bit_count, timer_seven_seg);
    
    // seven segment display
    // enable signal input to display four different seven segment displays
    seven_seg_display display(enable_signal, AN);
    
    check_alarm(minutes_ones, load_minutes_ones, minutes_tens, load_minutes_tens, load_SW, alarm_off_SW, play_sound);
    song_player alarm(clk, reset_SW, play_sound, audioOut, aud_sd);
    
endmodule
