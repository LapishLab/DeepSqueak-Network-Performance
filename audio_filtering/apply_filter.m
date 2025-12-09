function audio_out = apply_filter(audio_in, filter)

%% take fft of whole audio
X = fftshift(fft(audio_in)); % fftshift so that 0 frequency in middle

%% upsample filter to match fft and apply
big_filter = resample(filter,length(X),length(filter)); 
Y = X .* big_filter; % Apply filter in frequency domain

%% invert filtered fft back to time domain and normalize
audio_out = real(ifft(fftshift(Y)));
end