% data set generator 

% Note always be in root directory
working_directory = pwd;
food_seq_path = fullfile(working_directory, 'all_vib/diff_food/');
seq_sub_path = 'seq';
anno_sub_path = 'anno';
data_set_signal_path = './data_set_signal';
data_set_spectrogram_path = './data_set_spectrogram';
% get all directories

% list of folders
dirList = dir(food_seq_path);
% store the name of participant as path of csv files
% length -2 because we have 2 unwanted directory . and ..
folderList = cell(length(dirList) - 2, 1);
idx = 1;
% Iterate through the items in the directory
for i = 1:numel(dirList)
    if dirList(i).isdir && ~strcmp(dirList(i).name, '.') && ~strcmp(dirList(i).name, '..')
        folderList{idx} = dirList(i).name;  % Add the folder name to the list 
        idx = idx + 1;
    end
end

% data structure for the data loader in torch should follow the following
% structure 
% 1-train
% 2-val
% 3-test
% inside each directory we should have different directory with the name
% of the food type i.e apple, beef, etc. inside those folders we should
% have images for portions of signals 
if ~exist(data_set_signal_path, 'dir')
    mkdir(data_set_signal_path);
end

if ~exist(data_set_spectrogram_path, 'dir')
    mkdir(data_set_spectrogram_path);
end

for i = 1:numel(folderList)
    food_type = folderList(i);
    % point to the sequence dir inside the food type (i.e apple)
    seq_dir_path = fullfile(fullfile(food_seq_path, food_type),seq_sub_path);
    % point to the annotation dir inside the food type (i.e apple)
    anno_dir_path = fullfile(fullfile(food_seq_path, food_type),anno_sub_path);
    % inside each directory we have two different directories one is seq and
    % another one is anno in this generator we just need to work with seq   

    % working path for signal
    % data_set_signal_v3
    working_path_signal = fullfile(data_set_signal_path, food_type);
    working_path_signal = working_path_signal{1};
    if ~exist(working_path_signal, 'dir')
        mkdir(working_path_signal);
    end

    % working path for spectrogram
    % data_set_spectrogram_v3
    working_path_spectrogram = fullfile(data_set_spectrogram_path, food_type);
    working_path_spectrogram = working_path_spectrogram{1};
    if ~exist(working_path_spectrogram, 'dir')
        mkdir(working_path_spectrogram);
    end

    % form a sliding window and then slide it on the sequence of the signal
    % and on each sliding save the result in the working_path
    seq_file_list = dir(seq_dir_path{1});
    anno_file_list = dir(anno_dir_path{1});

    
    disp(working_path_signal);
    disp(working_path_spectrogram);

    
    % statistical values
    data_cell = {};
    
    for i = 1:numel(seq_file_list)
        if ~seq_file_list(i).isdir 
            fileName = seq_file_list(i).name;
            % search for the annotation version 
            % anno_file_names = {anno_file_list.name};
            startIndex = regexp(fileName, '_[0-9]+_*');
            if ~isempty(startIndex)
                correspond_anno_file_name = [fileName(1:startIndex), 'anno', '_', fileName(startIndex+1:end)];
            else
                continue
            end
            % end of search
            anno_file = fullfile(anno_dir_path{1},correspond_anno_file_name);
            if exist(anno_file, 'file') == 0
                continue
            end
            sequence_file = fullfile(seq_dir_path{1}, seq_file_list(i).name);
            generator_v2(sequence_file, anno_file,working_path_signal,working_path_spectrogram,true);
        end
    end
end