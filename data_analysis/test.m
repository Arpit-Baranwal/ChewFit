
%combinedData = combine_data('C:\\Users\\Alil\\Documents\\Courses\\SS2023\\2ES\\repo\\data_analysis\\root\\all_raw_vib\\01_phat');




f_combinedData = hampel(combinedData);
% align the signal to zero 
f_combinedData = f_combinedData - mean(f_combinedData);
% signal normalization
% f_combinedData  = normalize(f_combinedData,'range',[-1, 1]);


% Plot the original and interpolated signals
plot(combinedData)
plot(f_combinedData)


food_path = 'C:\\Users\\Alil\\Documents\\Courses\\SS2023\\2ES\\repo\\data_analysis\\root\\all_vib\\seq\\01_phat_vib_3_apple.txt'
% cross_corr(f_combinedData, food_path)

% food_path = 'C:\\Users\\Alil\\Documents\\Courses\\SS2023\\2ES\\repo\\data_analysis\\root\\all_vib\\seq\\02_sergei_vib_1_apple.txt';
% cross_corr(f_combinedData, food_path)
% 
% len = 500000;
% start = 2.8e6;
% last = start + len;
% sequence = f_combinedData(start:last);

fid = fopen(food_path, 'r');
sequence = fscanf(fid, '%f');
fclose(fid);
% sequence = hampel(sequence);
% sequence = (sequence) / (max(sequence) - min(sequence));
% align the signal to zero 
sequence= sequence - mean(sequence);
% plot(sequence);
% hold on;
% sequence = normalize(sequence, 'range', [-1; 1]);
% plot(sequence);
% hold off;
% Multi correlation
division = 10;
portion = ceil(length(f_combinedData) / division);

assert(portion >= 2 * length(sequence), "portion length cannot be less than twice the length of the sequence!")

list = inf((2 * division)-1, 3);
lst_idx=1;
m=0;
% 
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
        [match , idx]  = max(seq);
        match_pos = -lags(idx);
        
        % plot(signal,'color','b');
        % hold on;
        % plot(match_pos:match_pos + length(sequence) - 1,sequence, 'color', [1 0 0 0.1]);
        % line([match_pos, match_pos], ylim, 'Color', 'k', 'LineStyle', '-');
        % line([match_pos + length(sequence) - 1 , match_pos + length(sequence) - 1], ylim, 'Color', 'k', 'LineStyle', '-');
        % hold off;
        if match_pos > 0 && match_pos + length(sequence) < length(signal)
            % compute the norm of combined_signal and sequence at match_pos
            distance = norm(sequence - signal(match_pos:match_pos + length(sequence) - 1));
            list(lst_idx,1) = distance;
            list(lst_idx,2) = start + match_pos;

            % plot(signal,'color','b');
            % hold on;
            % plot(match_pos:match_pos + length(sequence) - 1,sequence, 'color', 'r');
            % filename = strcat('p_', num2str(i),'_',num2str(j), '.png');
            % saveas(fig, filename, 'png');
            fig = figure('visible', 'off');

            plot(signal,'color','b');
            hold on;
            leg_title = strcat('distance = ', sprintf('%.2f', distance));
            legend(leg_title,'AutoUpdate','off');
            plot(match_pos:match_pos + length(sequence) - 1,sequence, 'color', [1 0 0 0.1]);
            line([match_pos, match_pos], ylim, 'Color', 'k', 'LineStyle', '-');
            line([match_pos + length(sequence) - 1 , match_pos + length(sequence) - 1], ylim, 'Color', 'k', 'LineStyle', '-');
            hold off;
            filename = strcat('p_', num2str(i),'_',num2str(j), '.png');
            saveas(fig, filename, 'png');
            close(fig)

            fig2 = figure('visible', 'off');
            X1 = fft(sequence);
            frequencies = linspace(0, Fs, length(X1));
            plot(frequencies,abs(X1),'color','b');
            hold on;
            X2 = fft(signal(match_pos:match_pos + length(sequence) - 1));
            frequencies = linspace(0, Fs, length(X2));
            plot(frequencies,abs(X2),'color',[1 0 0 0.1]);
            fft_dist = norm(abs(X1) - abs(X2));
            leg_title = strcat('fft dist = ', sprintf('%.2f', fft_dist));
            legend(leg_title,'AutoUpdate','off');
            hold off;
            filename = strcat('fft_', num2str(i),'_',num2str(j), '.png');
            % saveas(fig2, filename, 'png');
            % close(fig2)

            list(lst_idx, 3) = fft_dist;
        end
        lst_idx = lst_idx + 1;
        
    end
end

[~ ,ix] = min(list(:,3));
shift = list(ix, 2);


% find the minimized value of the norms
fig3 = figure('visible', 'on');
plot(f_combinedData, 'r', 'LineWidth', 1);
hold on;
line([shift, shift], ylim, 'Color', 'g', 'LineStyle', '-');
plot(shift+1:shift + length(sequence), sequence, 'b-', 'LineWidth', 0.5, 'LineStyle', '--');
hold off;

