function [cells] = generator_v2(sequence_file, anno_file, signal_dir, spectrogram_dir, stat)
    label = strsplit(signal_dir,'\\');
    % SVM dataset
    stat_file = 'statv3.csv'
    colNames = {'TD Mean',' TD std',' TD rms',' TD variance',' TD Skewness',' TD Kurtosis',' TD Entropy',' FD Mean Power',' FD std',' FD Spectral Centroid',' FD Spectral Spread',' FD Spectral Skewness',' FD Spectral Kurtosis',' FD Band Energy Ratios',' FD Spectral Entropy',' FD Peak Frequency',' label'};
    if stat
        if exist(stat_file, 'file') == 0
            % If the file doesn't exist, write the headers first
            writecell(colNames, stat_file);
        end
    end
    % In this approach we will use the exact positioning using annotation
    % data therefore there is no need for using overlapping the best case
    % scenario is using phase shift or amplitude shift for data
    % augmentation which is achievable in pytorch library without utilizing
    % generator function (THIS FUNCTION) in matlab

    %reading the sequence file
    fid = fopen(sequence_file, 'r');
    sequence = fscanf(fid, '%f');
    fclose(fid);

    %reading the annotaion file
    fid = fopen(anno_file, 'r');
    annotations = fscanf(fid, '%f');
    fclose(fid);

    
    % filter the sequence 
    sequence = hampel(sequence);
    % align the signal to zero 
    sequence= sequence - mean(sequence);
    
    fs = 24104;  % Sample rate 
    size = length(sequence);
    
    cells = {};

    divisible = 64;
    
    for i=1:(length(annotations)-1)
        % convert annotation time to sample number using frequency samples
        start_time = annotations(i);
        end_time = annotations(i+1);
        
        if start_time == 0
            beg_idx = 1;
        else
            beg_idx = int32(floor(start_time * fs));
        end
        end_idx = int32(floor(end_time * fs));
        
        window_size = ceil((end_idx - beg_idx) / divisible) * divisible;
        % consider divisible to use this value as LCM least
        % common multiple [we'll use this value later as a word lentgh in RNN]
        % note that if we choose divisable number as 2^n we can use all
        % numbers from 2^0 to 2^n as word lenght.
    
        if (beg_idx + window_size - 1) > size
            % to make all portions equally same size we except the last portion
            end_idx = size;
            beg_idx = end_idx - window_size;
        end
        
        
        % form a segment from the sequence
        portion = sequence(beg_idx:beg_idx + window_size - 1);
    
        % save the portion signal data
        % random file name for portion seq
        portion_name =  string(datetime('now', 'Format', 'MMddHHmmssSSS'));
        % fprintf('%s.txt b=%d, e=%d, ws=%d, len=%d\n',portion_name,beg_idx, end_idx, window_size, length(portion));
        % save the text time domain data
        fid = fopen(fullfile(signal_dir, strcat(portion_name, '.txt')), 'w');
        fprintf(fid, '%f\n', portion);
        fclose(fid);
    
        % make spectrogram
        % Compute the spectrogram
        ws = 256;
        lap = 128;

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