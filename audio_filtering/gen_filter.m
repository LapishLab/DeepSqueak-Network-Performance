function [filter, frequency] = gen_filter(audio, fs, resample_rate)
    % arguments
    % end
    % get power from fft
    n = length(audio);
    X = fftshift(fft(audio)); % fftshift so that 0 frequency in middle
    f = fs/n*(-n/2:n/2); % frequency in units of Hz
    f = f(1:end-1)+1/fs/2;
    power = abs(X).^2 / n;

    % downsample by averaging
    t_bins = -fs/2 : resample_rate : fs/2; % new frequency in units of Hz
    binIndices = discretize(f, t_bins)';
    new_power = accumarray(binIndices, power, [], @mean);
    frequency=t_bins(1:end-1) + resample_rate/2;
    frequency=frequency(:);%reshape into rows

    % plot original and downsampled power
    % figure(1); clf; hold on;
    % plot(f,power)
    % plot(frequency,new_power)
    % yscale('log')
    % xlabel('frequency (Hz)')
    % ylabel('Power')

    % create filter from power
    filter = 1 ./ (sqrt(new_power));
    plot(frequency,filter)
end