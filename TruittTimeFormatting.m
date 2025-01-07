%excel = string();
%%
dates = formatDates(excel(1,:));
timeStrings = formatTimes(excel(3:end, :));
%%
unixTime = convertToUnix(dates,timeStrings);
startTimes = unixTime(:,:,1);
stopTimes = unixTime(:,:,2);

function dates = formatDates(dates)
    dates = erase(dates, 'Date');
    dates = strip(dates);
    dates = datetime(dates);
    dates.Format = 'yyMMdd';
    dates = "20" + string(dates);
end

function times = formatTimes(times)
    times = erase(times, '*');
    times = strip(times);
    times = split(times, '-');

    missingLeadingZero = cellfun(@length, times) == 6;
    times(missingLeadingZero) = "0"+times(missingLeadingZero);
end

function unixTime = convertToUnix(dates,times)
for i=1:length(dates)
    times(:,i,:) = dates(i) + "_" + times(:,i,:);
end

times = datetime(times, "InputFormat","yyyyMMdd_HHmm:ss");
unixTime = posixtime(times);
end