function transferfiles(src, dst, move_opt)
    if move_opt
        for i =1: numel(src)
            movefile(src{i}, dst{i});
        end
    else
        for i =1: numel(src)
            copyfile(src{i}, dst{i});
        end
    end
end