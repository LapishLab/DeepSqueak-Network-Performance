function audio_out = get_background(audio_in, fs, frac)
    n_bins = floor(length(audio_in) / 1 / fs);
    trimmed = audio_in(1:n_bins*fs);
    shaped = reshape(trimmed,[],n_bins);
    power = rms(shaped).^2;

    sorted_power = sort(power);

    threshold = sorted_power(ceil(frac*length(sorted_power))); %use quietest x%
    
    background = shaped(:, power <= threshold);
    audio_out = reshape(background, [],1);
end