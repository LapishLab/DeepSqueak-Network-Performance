function s = spectrogram_settings()
    s = struct();
    s.img_dur = 2;
    s.img_overlap = 0.5;

    s.min_frequency = 10e3; % in Hz
    s.step_frequency = 0.2e3; % in Hz % Default was ~0.32 kHz
    s.max_frequency = 90e3;  % in Hz
    % s.nfft = 0.0032; % results in 312.5 Hz y-rez for 250 kHz SR

    s.smth_time = 0.002; % gaussian smoothing across time (s)
    s.smth_freq = 0.4e3; % gaussian smoothing across freq (Hz)
    
    s.noverlap = 0.002; %overlap with next window in seconds
    s.wind = 0.004; % FFT window in seconds
end
