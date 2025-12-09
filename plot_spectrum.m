function plot_spectrum(audio_file, start, stop)
    [y, Fs] = load_audio_segment(audio_file, start, stop);
    

    window = round(Fs * 0.0032);% Deepsqueak default = .0032 s
    nfft = round(Fs * 0.0032);% Deepsqueak default = .0032 s
    % spectrogram(y,window,[],[], Fs, "yaxis")
    [~,F,T,P] = spectrogram(y,window,[],nfft, Fs); % defaults to 50% overlap with []
    T = T+start;

    P = sqrt(P); % plot amplitude
    % P = 10*log10(P+eps); %convert to decibel: Add eps to avoid log(0)
  
    imagesc(T, F/1000, P); 
    axis xy;
    ylabel('Frequency (kHz)');
    xlabel('Time (s)');
    c = colorbar;
    c.Label.String = 'Amplitude';

    colormap("inferno")
    clim([0 max(clim())])
end