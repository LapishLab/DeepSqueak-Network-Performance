calls = loadDetectionFiles(pwd);
calls = addUnixTimes(calls);
calls = addFrequencyRange(calls);
mkdir('results')
save("results/calls.mat", "calls")

function allCalls = loadDetectionFiles(detectionFolder)
    cd(detectionFolder)
    matFiles = dir('*.mat');
    allCalls = table();
    for i=1:length(matFiles)
        filename = matFiles(i).name;
        mat = load(filename);
        calls = mat.Calls;
        calls.fileName(:) = {filename};
        allCalls = cat(1,allCalls,calls);
    end
end

function calls = addUnixTimes(calls)
    fileTimes = filename2UnixTime(calls.fileName);
    callStart = calls.Box(:,1) + fileTimes;
    callWidth = calls.Box(:,3);

    calls.startTime = callStart;
    calls.stopTime = callStart+callWidth;
end

function unixTime = filename2UnixTime(filename)
filename = erase(filename, '.mat');
time = datetime(filename, "InputFormat","yyyyMMdd_HHmmss");
unixTime = posixtime(time);
end

function calls = addFrequencyRange(calls)
frequencyMin = calls.Box(:,2);
frequencyHeight = calls.Box(:,4);

calls.freqRange = [frequencyMin, frequencyMin + frequencyHeight];
end