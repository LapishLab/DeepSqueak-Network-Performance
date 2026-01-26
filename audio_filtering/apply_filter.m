function audio_out = apply_filter(audio_in, filter)

%% take fft of whole audio
X = fftshift(fft(audio_in)); % fftshift so that 0 frequency in middle

%% upsample filter to match fft and apply
little_x = linspace(0,1, length(filter));
bix_x = linspace(0,1, length(X));
big_filter = interp1(little_x, filter,bix_x, "linear");
Y = X(:) .* big_filter(:); % Apply filter in frequency domain

%% invert filtered fft back to time domain and normalize
audio_out = real(ifft(fftshift(Y)));
end