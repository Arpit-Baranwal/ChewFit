% Note always be in root directory
working_directory = pwd;
participant_path = fullfile(working_directory, 'all_raw_vib');
seq_path = fullfile(working_directory, 'all_vib/seq');

% list of folders
dirList = dir(participant_path);
% store the name of participant as path of csv files
folderList = cell(length(dirList) - 2, 1);
idx = 1;
% Iterate through the items in the directory
for i = 1:numel(dirList)
    if dirList(i).isdir && ~strcmp(dirList(i).name, '.') && ~strcmp(dirList(i).name, '..')
        folderList{idx} = dirList(i).name;  % Add the folder name to the list
        idx = idx + 1;
    end
end

fileList = dir(seq_path);
seqList = cell(length(fileList) - 2, 1);
idx = 1;
% Iterate through the items in the directory
for i = 1:numel(fileList)
    if ~strcmp(fileList(i).name, '.') && ~strcmp(fileList(i).name, '..')
        seqList{idx} = fileList(i).name;  % Add the folder name to the list
        idx = idx + 1;
    end
end


% pick one food and check for all entire signals for all participants
for i = 1:numel(folderList)
    fprintf('Combining Data %s ... \n', folderList{i});
    combinedData = combine_data(fullfile(participant_path, folderList{i}));
    fprintf('Combining Data Done!\n');
    fprintf('Combine Data Length = %d\n', length(combinedData));
    disp('---------------------------------------');
    parfor j = 1:numel(seqList)
        disp('~~~~~~~~~~~~~~~~');
        fprintf('Sequence %s\n', seqList{j});
        % Read the sequence from file.txt
        FOOD = fullfile(seq_path, seqList{j});

        [filepath, name, ext] = fileparts(seqList{j});
        saved_path = sprintf('%s-%s',folderList{i},name);
        [start, last, status]=signal_matching(combinedData, FOOD,saved_path);
        fprintf('signal = %s, seq= %s -> [start = %d, end = %d, status = %d]\n',folderList{i}, seqList{j}, start, last, status);
        disp('\n');
    end
    disp('----------------------------------------');
end

