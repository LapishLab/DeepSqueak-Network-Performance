function [color_img, T, F] = gen_spect_image(audio, Fs, settings)
    % Make the spectrogram
    F = settings.min_frequency : settings.step_frequency : settings.max_frequency;
    noverlap = round(settings.noverlap * Fs);
    wind = round(settings.wind * Fs);
    [~,~,T,im] = spectrogram(audio,wind,noverlap,F,Fs,'psd');
    

    %%
    % im = flipud(P);
    im = sqrt(im); % amplitude instead of power


     % gaussian smoothing
    sigma_t = settings.smth_time / (T(2)-T(1));
    sigma_f = settings.smth_freq / (F(2)-F(1));


    % create color image with different levels of smoothing in each channel
    ch1 = smooth_and_norm(im, sigma_t/2, sigma_f/4);
    ch2 = smooth_and_norm(im, sigma_t, sigma_f);
    ch3 = smooth_and_norm(im, sigma_t*2, sigma_f*4);
    
    color_img = cat(3, ch1, ch2, ch3);

end

function im = smooth_and_norm(im, sigma_t, sigma_f)
    im = imgaussfilt(im, [sigma_f, sigma_t]);

    % im = im / prctile(max(im), 99, 'all'); %
    % im = im / .0002;
    % im = im / (median(std(im(F>40e3,:))) * 40);
    im = im / (10*median(median(im)));
    im(im>1) = 1;
end