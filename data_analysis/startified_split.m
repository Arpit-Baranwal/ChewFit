function startified_split(root_path, train_p, val_p, test_p, seed, move_opt)
    
    rng(seed);

    % list of folders
    dirList = dir(root_path);
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

    % make dir for train, val, and test
    dst = split(root_path,'_');
    dst = strcat(dst{end},'_splitted');
    train_path = fullfile(dst,'/train/');
    if ~exist(train_path,'dir')
        mkdir(train_path);
    end
    val_path = fullfile(dst, '/val/');
    if ~exist(val_path,'dir')
        mkdir(val_path);
    end
    test_path = fullfile(dst, '/test/');
    if ~exist(test_path,'dir')
        mkdir(test_path);
    end

    for i = 1:numel(folderList)
        fileList = dir(fullfile(root_path, folderList{i}));
        files = cell(length(fileList) - 2,1);
        idx = 1;
        for j = 1:numel(fileList)
            if fileList(j).isdir == 0
                files{idx} = fileList(j).name;
                idx = idx + 1;
            end
        end
        
        % move all selected files to train folder under the specified
        % category
        

        % split train
        destination_dir = fullfile(train_path,folderList{i});
        if ~exist(destination_dir, 'dir')
            mkdir(destination_dir);
        end
        
        n_train = int32(train_p * numel(files));
        indices = randperm(numel(files));
        random_indices = indices(1:n_train);

        
        source_dir = fullfile(root_path,folderList{i});
        src_files = fullfile(source_dir, files(random_indices));
        dst_files = fullfile(destination_dir, files(random_indices));

        transferfiles(src_files, dst_files, move_opt);
        
        % split validation

        destination_dir = fullfile(val_path, folderList{i});
        if ~exist(destination_dir, 'dir')
            mkdir(destination_dir);
        end
        
        n_val = int32(val_p * numel(files));
        random_indices = indices(n_train+1:n_train+n_val);

        src_files = fullfile(source_dir, files(random_indices));
        dst_files = fullfile(destination_dir, files(random_indices));
        
        transferfiles(src_files, dst_files, move_opt);

        % split test

        destination_dir = fullfile(test_path, folderList{i});
        if ~exist(destination_dir, 'dir')
            mkdir(destination_dir);
        end

        random_indices = indices(n_train + n_val + 1:end);

        src_files = fullfile(source_dir, files(random_indices));
        dst_files = fullfile(destination_dir, files(random_indices));
        
        transferfiles(src_files, dst_files, move_opt);        
    end
end