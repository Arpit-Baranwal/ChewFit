function [match_begin, match_end, match_status] = cross_corr(combined_data, food)
   
    fid = fopen(food, 'r');
    sequenece = fscanf(fid, '%f');
    fclose(fid);

    % filtering the sequence
    % sequenece = medfilt1(sequenece, 5);
    % sequenece = sequenece - mean(sequenece);
    [seq, lags] = xcorr(sequenece,combined_data, 'none');

    [~, match_index] = max(seq);
    
    shift = -lags(match_index);
    
    % Plotting
    figure;
    plot(combined_data, 'b', 'LineWidth', 1);  % Plotting the longer signal in blue
    hold on;
    plot(shift+1:shift + length(sequenece), sequenece, 'r', 'LineWidth', 0.5);  % Plotting the aligned shorter signal in red
    

    % return of the 
    % match_begin = best_lags;
    % match_end = best_lags + length(sequenece);
    % 
    % match_status = 'Not Found';
    % 
    % if match_end < length(sequenece) && best_lags >= 0
    %     match_status = 'Found';
    %     % similarity_check(sequence, filteredSignal(match_begin:match_end));
    % end
end