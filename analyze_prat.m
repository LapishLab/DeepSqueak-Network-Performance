% This script requires https://github.com/raacampbell/shadedErrorBar
% Navigate to export directory before running script
export_path = pwd();
export_csv = fullfile(export_path, "Export.csv");

%% load table, force all variables as string to prevent issueTimes from getting formatted weird
opts = detectImportOptions(export_csv, Delimiter=",");
opts = setvartype(opts, opts.SelectedVariableNames, 'string');
t = readtable(export_csv, opts);
%% Remove any rows which didn't have exports
% maybe add removing single rats? will make medPC parser faster 
t = t(~cellfun(@isempty, t.export_path), :);

%% load all call tables into this session table
% For portability get the path relative to the
% export director, instead of using the raw original export path.
[~, mat_names, ext] = fileparts(t.export_path);
local_mat_paths = fullfile(export_path, mat_names+ext);
% Load just the calls. Currently, I have no need for audio_file_info
load_fun = @(x) load(x).calls;
t.calls = cellfun(load_fun, local_mat_paths, UniformOutput=false);

%% Synchronize time
% audio time
% time 0 is start of the file when started on the Pis 
[~,id,~] = fileparts(t.export_path);
time_string = extractBefore(id, 16);
audio_datetime = datetime(time_string, InputFormat="uuuuMMdd_HHmmss");
audio_time = timeofday(audio_datetime);

% issue time
% when MedPC boxes were issued 
t.issueTime = pad(t.issueTime, 6, 'left','0');
issue_time = timeofday(datetime(t.issueTime, InputFormat="HHmmss"));

%add dates to of files to tables
audio_datetime.Format = 'yyyyMMdd';
t.date = audio_datetime;

%% find audio offset time and shift (ONLY RUN ONCE)
% time distance between pi start and medPC issue 
% maybe change? 
audio_offset = seconds(audio_time-issue_time);
for i=1:height(audio_offset)
    calls = t.calls{i};
    calls.Box(:,1) = calls.Box(:,1) + audio_offset(i);

    add_offset = @(x) x + audio_offset(i);
    calls.ridge_time = cellfun(add_offset, calls.ridge_time, 'UniformOutput', false);
    t.calls{i} = calls;
end

%% Calculating mean call frequency %%
for i = 1:height(t)
    calls = t.calls{i};
    call_freq = cellfun(@mean, calls.ridge_frequency);
end 


%% USV Counts Comparison %%
%groups of interest
singles = contains(t.sex, '_');
water = contains(t.treatment, 'Control_Control');
ethanol = contains(t.treatment, 'EtOH_EtOH');
mixed = contains(t.treatment, 'EtOH_Control') | contains(t.treatment, 'Control_EtOH');

males = contains(t.sex, "M");
females = contains(t.sex, "F");

EtOH_dates = datetime(2025, 8, [17 19 21 25 27 29]);
EtOH_dates.Format = 'yyyyMMdd';
water_dates = datetime(2025, 8, [18 20 26 28]);
water_dates.Format = 'yyyyMMdd';

EtOH_days = contains(string(t.date), string(EtOH_dates));
water_days = contains(string(t.date), string(water_dates));

% find number of calls for group you are interested in 
callColumn = t.calls(water & males & etoh_days :);
water_counts = arrayfun(@(x) size(callColumn{x},1), 1:numel(callColumn))';

callColumn = t(ethanol & females & EtOH_days, :);
ethanol_counts = arrayfun(@(x) size(callColumn{x},1), 1:numel(callColumn))';

callColumn = t.calls(mixed & males & water_days, :);
mixed_counts = arrayfun(@(x) size(callColumn{x},1), 1:numel(callColumn))';

x = ["water", "mixed", "EtOH"];
y = {water_counts, mixed_counts, ethanol_counts};
b = raw_data_error_bar(x,y)
ylabel("USV Number")
title("USV counts of Females by pairings on Water Days")










%% Bin average USV rate and frequency
edges = -10*60 : 10 : 70*60; 
tdif = diff(edges(1:2));

usv_rate = nan(height(t), length(edges)-1);
usv_freq = usv_rate;
for i=1:height(t)
    % --- get usv rate --- %
    calls = t.calls{i};
    % find mean of all the time points of each pixel in a squeak 
    call_times = cellfun(@mean, calls.ridge_time);
    % number of USV counts in each time bin / total time = percentage of
    % total squeaks in the file in each time bin 
    usv_rate(i,:) = histcounts(call_times, edges) / tdif;

    % --- get usv frequency --- %
    % find mean frequency of each pixel of a squeak, in Hz not KHz
    call_freq = cellfun(@mean, calls.ridge_frequency);
    % find which time bins have calls in them. Tin bins without calls
    % (should be mainly those at the start and end) are labeled as NaNs 
    binIndices = discretize(call_times, edges);
    outside_edges = isnan(binIndices);
    %keep only the data that is in time bins where calls are present 
    call_freq = call_freq(~outside_edges);
    binIndices=binIndices(~outside_edges);
    
    %find average squeak frequency in each time bin 
    sz = [length(edges)-1, 1];
    avg =  @(x) mean(x, 'omitnan');
    usv_freq(i,:) = accumarray(binIndices, call_freq, sz, avg, NaN);
end
sem = @(x) std(x, 'omitnan')/sqrt(sum(~isnan(x(:,1))));
avg_nan = @(x) mean(x, 'omitnan');

%% 1 vs 2 rats USVs
two_rats = contains(t.treatment, '_');

figure(2); clf; hold on;
x = (edges(1:end-1)+diff(edges)/2) / 60;
shadedErrorBar(x, usv_rate(two_rats,:), {avg_nan, sem}, 'lineProps',{ 'Color', 'blue', 'DisplayName', '2 rats'})
shadedErrorBar(x, usv_rate(~two_rats,:), {avg_nan, sem}, 'lineProps',{ 'Color', 'green', 'DisplayName', '1 rat'})

xlabel("Time (minutes)")
ylabel("USV Rate (Hz)")
legend()


%% treatment groups (only 2 rats)
water = contains(t.treatment, 'Control_Control');
ethanol = contains(t.treatment, 'EtOH_EtOH');
mixed = contains(t.treatment, 'EtOH_Control') | contains(t.treatment, 'Control_EtOH');


figure(3); clf; hold on;
x = (edges(1:end-1)+diff(edges)/2) / 60;
shadedErrorBar(x, usv_rate(water,:), {avg_nan, sem}, 'lineProps',{ 'Color', 'blue', 'DisplayName', 'Water-Water'})
shadedErrorBar(x, usv_rate(ethanol,:), {avg_nan, sem}, 'lineProps',{ 'Color', 'green', 'DisplayName', 'EtOH-EtOH'})
shadedErrorBar(x, usv_rate(mixed,:), {avg_nan, sem}, 'lineProps',{ 'Color', 'red', 'DisplayName', 'Water-EtOH'})
xlabel("Time (minutes)")
ylabel("USV Rate (Hz)")
legend()

%% Male vs Female
M = contains(t.sex, 'M');

figure(4); clf; hold on;
x = (edges(1:end-1)+diff(edges)/2) / 60;
shadedErrorBar(x, usv_rate(M,:), {avg_nan, sem}, 'lineProps',{ 'Color', 'blue', 'DisplayName', 'Male'})
shadedErrorBar(x, usv_rate(~M,:), {avg_nan, sem}, 'lineProps',{ 'Color', 'green', 'DisplayName', 'Female'})
xlabel("Time (minutes)")
ylabel("USV Rate (Hz)")
legend()

%%%%%%%%%%%%%%% LICK STUFF NEEDS ACCESS TO MED FILES %%%%%%%%%%%%%%%%%%%%%
%% Load the med structs into the table
% go back up to find med-pc folder in datastar and then parses them out 
for i=1:height(t)
    t.med_struct{i} = getMedFile(t.session_path{i}, t.subject{i});
end

% For now just drop any rows that couldn't load the med data
t = t(~cellfun(@isempty, t.med_struct), :);

%% Bin Licks
% Defaults to same bin edges as used for USVs
lick_rate_l = nan(height(t), length(edges)-1);
lick_rate_r = nan(height(t), length(edges)-1);
for i=1:height(t)
    med = t.med_struct{i};
    if ~isempty(med.E)
        lick_rate_l(i,:) = histcounts(med.E, edges) / tdif;
    end
    if ~isempty(med.F)
        lick_rate_r(i,:) = histcounts(med.F, edges) / tdif;
    end
end
all_licks = cat(1, lick_rate_l, lick_rate_r);
%% usv rate vs licks
% find functions that use the ridges for time and frequency of squeaks
figure(1); clf; hold on;
x = (edges(1:end-1)+diff(edges)/2) / 60;
shadedErrorBar(x, usv_rate, {avg_nan, sem}, 'lineProps',{ 'Color', 'green', 'DisplayName', 'USVs'})
shadedErrorBar(x, all_licks, {avg_nan, sem}, 'lineProps',{ 'Color', 'blue','DisplayName', 'Licks'})
xlabel("Time (minutes)")
ylabel("Rate (Hz)")
legend()

%% usv frequency vs licks
figure(11); clf; hold on;
x = (edges(1:end-1)+diff(edges)/2) / 60;
yyaxis left
shadedErrorBar(x, usv_freq/1000, {avg_nan, sem}, 'lineProps',{ 'Color', 'green', 'DisplayName', 'USVs'})
ax = gca;
ax.YColor = 'green';
ylabel("USV frequency (kHz)")
yyaxis right
shadedErrorBar(x, all_licks, {avg_nan, sem}, 'lineProps',{ 'Color', 'blue','DisplayName', 'Licks'})
ax = gca;
ax.YColor = 'blue';
ylabel("Lick rate (Hz)")
xlabel("Time (minutes)")

legend()


%%
function counts = callNumber(callColumn)
    counts = [];
    for i = 1:size(callColumn)
        counts = [counts; size(callColumn{i},1)];
    end 
end 

function med_struct = getMedFile(session_path,subject_str)
    medDir = getMedDir(session_path);
    file_names = string({dir(medDir).name})';
    sub_parts = extractBefore(extractAfter(file_names, 'Subject'), '.txt'); %Annoyingly, extractBetween errors when some don't match pattern 
    subject_str =  split(subject_str, '_');
    subject_str = strip(subject_str, "left", "0");
    
    correct = true(size(file_names));
    for i=1:length(subject_str)
        correct = correct & contains(sub_parts, subject_str{i});
    end
    if sum(correct)==1
        med_path = fullfile(medDir, file_names(correct));
        med_struct = importMA(med_path, remove_trailing_zeros=true);
    elseif sum(correct)>1
        warning("too many matches for %s", session_path)
        med_struct = [];
    elseif sum(correct)==0
        warning("no matches for %s", session_path)
        med_struct = [];
    end    
end
function medDir = getMedDir(session_path)
    root = nthParent(session_path,3);
    med_folder = dir(fullfile(root, "med-pc*")).name;
    medDir = fullfile(root, med_folder);
end

function parent = nthParent(path, N) 
    parent = fileparts(path);
    if N>1
        parent = nthParent(parent, N-1);
    end
    % Wow. a legitimate use of recursion.
end


% \ *************************** Variables *************************
% \ A = Number of left licks.
% \ B = Number of right licks.
% \ C = Record of whether the left sipper has been tripped enough
% \     times (0 = No, 1 = Yes).
% \ D = Record of whether the right sipper has been tripped enough
% \     times (0 = No, 1 = Yes).
% \ E = List of left lick times in seconds.
% \ F = List of right lick times in seconds.
% \ G = Total number of licks
% \ H = Array for PiSync ON times
% \ I = Pi sync signal counter
% \ J = List of Beam State Transition Counters
% \ K = PiSync ON time in ms
% \ L = Array for PiSync OFF times
% \ P = List of Beam 1 Break Times (-1, -1, followed by alternating Break and Unbreak transitions starting with an break transition)
% \ Q = List of Beam 2 Break Times (-1, -1, followed by alternating Break and Unbreak transitions starting with an break transition)
% \ R = List of Beam 3 Break Times (-1, -1, followed by alternating Break and Unbreak transitions starting with an break transition)
% \ S = List of Beam 4 Break Times (-1, -1, followed by alternating Break and Unbreak transitions starting with an break transition)
% \ U = List of Beam 5 Break Times (-1, -1, followed by alternating Break and Unbreak transitions starting with an break transition)
% \ V = List of Beam 6 Break Times (-1, -1, followed by alternating Break and Unbreak transitions starting with an break transition)
% \ T = Time in Seconds


%%


%%