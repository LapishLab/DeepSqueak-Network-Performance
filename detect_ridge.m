function calls = detect_ridge(calls, filename, opt)
arguments
    calls table
    filename string
    opt.ampThresh double = 5; % standard deviations above median

    opt.smth_time = 1e-3; % gaussian smoothing across time (s)
    opt.smth_freq = 500; % gaussian smoothing across freq (Hz)

    opt.plot logical = false % Should a plot be created

    opt.min_frequency = 1000
    opt.step_frequency = 500;
    opt.max_frequency = 90e3

    opt.wind = 4e-3
    opt.noverlap = 3e-3
end


for i=1:height(calls)
    %% Get audio segment
    start_time = calls.Box(i,1);
    stop_time = sum(calls.Box(i,[1,3]));
    [y, Fs] = load_audio_segment(filename, start_time, stop_time);

    %% Get spectrogram
    F = opt.min_frequency : opt.step_frequency : opt.max_frequency;
    noverlap = round(opt.noverlap * Fs);
    wind = round(opt.wind * Fs);
    if wind>length(y)
        continue %Skip super short calls
    end
    [~,~,T,A] = spectrogram(y,wind,noverlap,F,Fs,'psd');
    T = T+start_time;
    A = sqrt(A); % Convert power to amplitude

    % gaussian smoothing
    sigma_t = opt.smth_time / diff(T(1:2));
    sigma_f = opt.smth_freq / diff(F(1:2));
    A = imgaussfilt(A, [sigma_f, sigma_t]); % smooth power
    
    %% Chose single brightest pixel for each timepoint within the box frequencies
    min_freq = calls.Box(i,2) * 1000;
    max_freq = sum(calls.Box(i,[2,4])) * 1000;
    in_box = F>min_freq & F<max_freq;
    [amp,max_inds] = max(A(in_box,:), [], 1);
    box_f = F(in_box);
    freq = box_f(max_inds);
    
    %% Are values above threshold
    thres = median(A(:)) + mad(A(:),1)*opt.ampThresh;
    greaterthannoise = amp > thres;

    %% Restrict to pixels greater than noise and save
    calls.ridge_time{i} = double(T(greaterthannoise)');
    calls.ridge_frequency{i} = freq(greaterthannoise)';
    calls.ridge_amp{i} = amp(greaterthannoise)';
    calls.ridge_snr{i} = calls.ridge_amp{i}.^2 ./ mean(A(~in_box,greaterthannoise).^2)';

    if opt.plot
        %% Plot spectrogram
        clf
        imagesc(T, F, A); 
        axis xy;
        ylabel('Frequency (kHz)');
        xlabel('Time (s)');
        c = colorbar;
        c.Label.String = 'Amplitude';
        
        clim([0 prctile(A(:),99.9)])
        
        hold on 
        scatter(calls.ridge_time{i}, calls.ridge_frequency{i}, 'filled', 'red',  MarkerFaceAlpha=0.5)
        
        box = calls.Box(i,:);
        box([2,4]) = box([2,4]) * 1000;
        rectangle('pos', box);
        pause(0.1);
    end
end



end
