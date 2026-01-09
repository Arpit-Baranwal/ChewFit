% chewing statistical window size

% Note always be in root directory
working_directory = pwd;
anno_path = fullfile(working_directory, 'all_vib/anno/');

% list of folders
fileList = dir(anno_path);

list_info = cell(length(fileList)-2, 3);
idx = 1;
for i=1:numel(fileList)
    if ~fileList(i).isdir
        fileName = fullfile(anno_path,fileList(i).name);
        fileID = fopen(fileName, 'r');
        data = textscan(fileID, '%f', 'Delimiter', '\n');
        fclose(fileID);
        
        split_str = split(fileList(i).name, '_');
        split_str= split(split_str(end),'.');
        name = split_str{1};
        list_info{idx, 1} = name;
        list_info{idx, 2} = mean(diff(data{1}));
        list_info{idx, 3} = std(diff(data{1}));
        idx = idx + 1;
    end
end


nameCol = cellfun(@(x) char(x), list_info(:, 1), 'UniformOutput', false);

[~, sortIndex] = sort(nameCol);
sortedList = list_info(sortIndex, :);

uniqueFoodTypes = unique(list_info(:, 1));

for index = 1:numel(uniqueFoodTypes)
    meanCol = cat(1, list_info{strcmp(list_info(:, 1), uniqueFoodTypes(index)), 2});
    disp('............')
    uniqueFoodTypes(index)
    m = mean(meanCol)
    s = std(meanCol)
    histogram(meanCol, length(meanCol))
end
disp('------------------')

m = mean([list_info{:, 2}])
s = std([list_info{:,3}])
min_val = min([list_info{:, 2}])
max_val = max([list_info{:, 2}])

