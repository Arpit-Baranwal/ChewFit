function [cells] = generator_v1(sequence_file, signal_dir, spectrogram_dir, stat)
    label = strsplit(signal_dir,'\\');
    % SVM dataset
    stat_file = 'stat.csv'
    colNames = {'TD Mean',' TD std',' TD rms',' TD variance',' TD Skewness',' TD Kurtosis',' TD Entropy',' FD Mean Power',' FD std',' FD Spectral Centroid',' FD Spectral Spread',' FD Spectral Skewness',' FD Spectral Kurtosis',' FD Band Energy Ratios',' FD Spectral Entropy',' FD Peak Frequency',' label'};
    if stat
        if exist(stat_file, 'file') == 0
            % If the file doesn't exist, write the headers first
            writecell(colNames, stat_file);
        end
    end
    % window size 19765 ~0.82 sec overlap 60% [cannot proof the right size of overlap]
    overlap = 0.6;
    %reading the sequence file
    fid = fopen(sequence_file, 'r');
    sequence = fscanf(fid, '%f');
    fclose(fid);
    
    % filter the sequence 
    sequence = hampel(sequence);
    % align the signal to zero 
    sequence= sequence - mean(sequence);
    
    window_size = int32(ceil(0.82 * 24104));
    
    size = length(sequence);
    
    assert(window_size < size, "window_size cannot be smaller than sequence size!");
    
    cells = {};

    beg_idx = 1;
    end_idx = window_size;
    step = 0;
    
    while end_idx < size 
    
        beg_idx = int32(floor((1-overlap) * (step * window_size))) + 1;
        end_idx = beg_idx + window_size;
        step = step + 1;
    
        if end_idx > size
            % to make all portions equally same size we except the last portin
            end_idx = size;
            beg_idx = end_idx - window_size;
        end
    
        portion = sequence(beg_idx:end_idx);
    
        % save the portion signal data
        % random file name for portion seq
        portion_name =  string(datetime('now', 'Format', 'MMddHHmmssSSS'));
        % save the text time domain data
        fid = fopen(fullfile(signal_dir, strcat(portion_name, '.txt')), 'w');
        fprintf(fid, '%f\n', portion);
        fclose(fid);
    
        % make spectrogram
        % Compute the spectrogram
        ws = 256;
        lap = 128;
        fs = 24104;  % Sample rate 
        [s, f, t] = spectrogram(portion, ws, lap, [], fs);
        
        % Create the spectrogram image
        imagesc(t, f, 20 * log10(abs(s)));
        
        axis off;  
        axis tight;
    
        % Save the spectrogram as an image file
        frame = getframe(gca);
        spectrogramImage = frame2im(frame);
        % Save the spectrogram as an image file
        imwrite(spectrogramImage, fullfile(spectrogram_dir, strcat(portion_name, '.png')));
        % exportgraphics(gca, fullfile(spectrogram_dir, strcat(portion_name, '.png')), 'Resolution', 150);
    
        % make a row in the table for this window
        if stat
            row = num2cell(fetch_statistics(portion));
            row{end+1} = label{end};
            writecell(row, stat_file, 'WriteMode', 'append');
        end
    end

end