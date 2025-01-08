% excelStartTimes = string()
load("calls.mat")

startTimes = str2double(excelStartTimes);

totalCalls = nan(size(excelStartTimes));

callFreq =  string(size(excelStartTimes));

for i=1:size(startTimes,1)
    for ii=1:size(startTimes,2)
        start = startTimes(i,ii);
        stop = start + 300;
        isMatch = calls.startTime>start & calls.stopTime<stop;
        totalCalls(i,ii) = sum(isMatch);
        freqRange = calls.freqRange(isMatch,:);
        avgFreq = mean(freqRange,2);
        avgAvgFreq = mean(avgFreq);
        %stdAvgFreq = std(avgFreq);
        callFreq(i,ii) = string(avgAvgFreq);% + "+-" + string(stdAvgFreq);
    end
end