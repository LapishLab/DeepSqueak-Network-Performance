function calls = calculate_intensity(calls, audiodata)
%TODO it would be much faster to precalculate once for each file. I can add
%a check, but I also need the original mat filename in order to resave

    [audio,Fs] = audioread(audiodata.Filename);

    time_inds = calls.Box(:,[1,3])*Fs;
    time_inds(:,2) = sum(time_inds,2);
    time_inds = round(time_inds);

    rms_val = nan(height(calls),1);
    for i = 1:height(calls)
        segment = audio(time_inds(i, 1):time_inds(i, 2));
        rms_val(i) = sqrt(mean(segment.^2));
    end
    calls.rms = rms_val;

end