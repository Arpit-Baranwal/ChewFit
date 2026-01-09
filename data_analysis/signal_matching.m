function [match_begin, match_end, match_status] = signal_matching(combined_data, food, save_in)

    fid = fopen(food, 'r');
    sequence = fscanf(fid, '%f');
    fclose(fid);

    sequence = hampel(sequence);
    % align the signal to zero 
    sequence= sequence - mean(sequence);
    
    % filtering the combined data
    f_combinedData = hampel(combined_data);
    % align the signal to zero 
    f_combinedData = f_combinedData - mean(f_combinedData);
    
    % Multi correlation
    division = floor(length(f_combinedData) / (length(sequence)*2));
    portion = int32(ceil(length(f_combinedData) / division));
    
    assert(portion >= 2*length(sequence), "portion length cannot be less than twice the length of the sequence!")

    list = inf((2 * division)-1, 3);
    lst_idx=1;
    m=0;
    
    Fs = 32;
    
    for i=1:2

        if i > 1
            m = inv(i);
        end

        for j=0:division-2

            start = (j+m)*portion+1;
            last = (j+m+1)*portion;
            signal = f_combinedData(start:last);

            if j == division - 2
                signal = f_combinedData(start:end);
            end

            [seq, lags] = xcorr(sequence, signal);
            [~ , idx]  = max(seq);
            match_pos = -lags(idx);
            
            if match_pos > 0 && match_pos + length(sequence) < length(signal)
                % compute the norm of combined_signal and sequence at match_pos
                distance = norm(sequence - signal(match_pos:match_pos + length(sequence) - 1));
                list(lst_idx,1) = distance;
                list(lst_idx,2) = start + match_pos;

                X1 = fft(sequence);

                X2 = fft(signal(match_pos:match_pos + length(sequence) - 1));

                fft_dist = norm(abs(X1) - abs(X2));
                    
                list(lst_idx, 3) = fft_dist;
            end
            lst_idx = lst_idx + 1;
        end
    end

    % find the minimized value of the norms
    [~ ,ix] = min(list(:,3));
    shift = list(ix, 2);
    
    match_begin = int32(shift);
    match_end = int32(match_begin + length(sequence));
    match_status = true;
    
    % note that 30 is a threshold
    if match_begin < 0 || list(ix, 3) > 30
        match_status = false;
    end
    
    % save the figure if saved is true
    if ~isempty(save_in)
        fig = figure('visible', 'off');
        plot(f_combinedData, 'k', 'LineWidth', 1);
        hold on;
        line([shift, shift], ylim, 'Color', 'g', 'LineStyle', '-');

        plot(shift+1:shift + length(sequence), sequence, 'color', 'r', 'LineWidth', 0.5);

        line([shift + length(sequence) , shift + length(sequence)], ylim, 'Color', 'g', 'LineStyle', '-');
        
        leg_title = strcat('match status = ', sprintf('%d', match_status));
        legend(leg_title,'AutoUpdate','off');

        hold off;

        filename = strcat(save_in,'.png');
        saveas(fig, filename, 'png');
        close(fig)

        fig = figure('visible', 'off');
        plot(f_combinedData(match_begin:match_end), 'b', 'LineWidth', 1);
        hold on;

        plot(sequence, 'color', [1 0 0 0.1], 'LineWidth', 0.25);
       
        leg_title = strcat('match status = ', sprintf('%.2f ,%d', list(ix, 3),match_status));
        legend(leg_title,'AutoUpdate','off');

        hold off;

        filename = strcat(sprintf('%s-portion',save_in),'.png');
        saveas(fig, filename, 'png');
        close(fig)

        % report 
        % Name of the CSV file
        parts = [strsplit(save_in, '-')];
        filename = strcat(parts{1},'.csv');
        
        % Open the file in append mode
        fileID = fopen(filename, 'a');
        

        if match_status
            fprintf(fileID, '%s,%s,%s\n',parts{2},num2str(match_begin),num2str(match_end));
        else
            fprintf(fileID, '%s,-,-\n', parts{2});
        end
        
        % Close the file
        fclose(fileID);
    end

