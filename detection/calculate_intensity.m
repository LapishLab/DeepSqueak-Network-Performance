function avg_call_intensity = calculate_intensity(calls, audiodata)
%TODO it would be much faster to precalculate once for each file. I can add
%a check, but I also need the original mat filename in order to resave

    avg_call_intensity = nan(height(calls),1);
    for i=1:height(calls)
        start_time = calls.Box(i,1);
        stop_time = sum(calls.Box(i,[1,3]));

        figure(1); clf; hold on; 
        [F,T,P] = plot_spectrum(audiodata.Filename, start_time, stop_time);
        rectangle(Position=calls.Box(i,:), EdgeColor='white')

        min_freq = calls.Box(i,2) * 1000;
        max_freq = sum(calls.Box(i,[2,4])) * 1000;
        box_freq_inds = F>min_freq & F<max_freq;

        F = F(box_freq_inds);
        P = P(box_freq_inds,:);

        [amplitude, freq_inds, time_inds] = detect_ridge(P);


        x = T(time_inds);
        y = F(freq_inds) / 1000; %F is in Hz, convert to kHz
        scatter(x, y, 'filled', 'green')
        
        % average the final pixel values
        avg_call_intensity(i) = mean(amplitude); % Store the maximum intensity for the current call
    end

    figure(2);clf;
    histogram(avg_call_intensity)
end
