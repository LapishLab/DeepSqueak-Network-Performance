function rename_mat2audio(rootDir)
arguments
    rootDir (1,1) string = pwd; 
end
    matFiles = dir(fullfile(rootDir,'*.mat')); % non-recursive .mat list
    for k = 1:numel(matFiles)
        originalPath = fullfile(matFiles(k).folder,matFiles(k).name);
        S = load(originalPath); % load file
        [~,matBase,~] = fileparts(originalPath); % current mat file name
        if ~isfield(S,'audiodata') || ~isfield(S.audiodata,'Filename')
            warning("skipping %s: file does not contain audiodata.Filename", matBase)
            continue; 
        end 

        
        [~,audioBase,~] = fileparts(S.audiodata.Filename); % expected base name
        if strcmp(matBase,audioBase)
            continue; % Skip rename, already correct
        end 

        newPath = fullfile(matFiles(k).folder,audioBase+".mat"); % target path
        if exist(newPath,'file')
            warning("skipping %s: renaming to %s would overwrite existing file.", matBase, audioBase)
            continue; % avoid overwrite
        end
        S.audiodata.OriginalMatFilename = matFiles(k).name; % save original name in mat file
        save(originalPath,'-struct','S'); % save 
        movefile(originalPath,newPath); % rename
    end
end