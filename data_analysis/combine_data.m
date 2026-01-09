function output = combine_data(path)
% -----------------------------------------------------------------
    % Specify the file extension to filter
    fileExtension = '.csv';
    
    % Get the list of files in the current directory
    files = dir(fullfile(path, ['*', fileExtension]));
    
    % Filter only the CSV files
    csvFiles = {files.name};
   
    combinedData = [];
    for i = 1:numel(csvFiles)
        data = readmatrix(fullfile(path, csvFiles{i})); % Load each CSV file
        combinedData = [combinedData; data(2:end,2)]; % Concatenate data vertically
    end
    output = combinedData;
% -----------------------------------------------------------------
end