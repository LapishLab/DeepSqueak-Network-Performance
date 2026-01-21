function calls = calculate_intensity(calls, audiodata)
%TODO it would be much faster to precalculate once for each file. I can add
%a check, but I also need the original mat filename in order to resave

    [audio,Fs] = audioread(audiodata.Filename);
end