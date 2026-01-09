seq_file = 'C:\\Users\\Alil\\Documents\\Courses\\SS2023\\2ES\\repo\\data_analysis\\root\\all_vib\\seq\\14_lena_vib_3_chip.txt'
anno_file = 'C:\\Users\\Alil\\Documents\\Courses\\SS2023\\2ES\\repo\\data_analysis\\root\\all_vib\\anno\\14_lena_vib_anno_3_chip.txt'

fid = fopen(seq_file, 'r');
sequenece = fscanf(fid, '%f');
fclose(fid);

% sequenece = hampel(sequenece);

fid = fopen(anno_file, 'r');
anno = fscanf(fid, '%f');
fclose(fid);

%-----------------------------------------
sequenece = hampel(sequenece);
sequenece = normalize(sequenece,'range',[0, 1]);

% plot(sequenece);

windowSize = 0.25; % 200 ms
threshold = 1e-4; 
samplingFreq = 24104;

% convert annotation to frequency
anno = anno .* samplingFreq;

% Compute short-time signal energy using a window of 20 ms
windowLength = round(windowSize * samplingFreq);
squaredSignal = sequenece.^2;

squaredSignal = squaredSignal - mean(squaredSignal);

plot(squaredSignal)

energy = movmean(squaredSignal, windowLength);
plot(energy)

% Compare energy to threshold and create resulting signal
resultSignal = energy > threshold;

resultSignal = double(resultSignal);

plot(resultSignal)


cutoffFreq = 3; 
[b, a] = butter(4, cutoffFreq / (samplingFreq * 0.5), 'low');
filteredSignal = filtfilt(b, a, resultSignal);

chewBeginnings = []; 

% Perform hill climbing algorithm to detect chew beginnings
parfor i = 2:length(filteredSignal)-1
    if filteredSignal(i) < filteredSignal(i-1) && filteredSignal(i) < filteredSignal(i+1)
        if filteredSignal(i) < windowSize
            chewBeginnings = [chewBeginnings i]; % Store the index of chew beginning
        end
    end
end

% Plot the original and filtered signals
plot(sequenece);
hold on;
plot(filteredSignal,'LineWidth',2);

for i = 1:length(anno)
    line([anno(i), anno(i)], ylim, 'Color', 'g', 'LineStyle', '--');
end

plot(chewBeginnings, zeros(size(chewBeginnings)), 'rd', 'MarkerSize', 8, 'color' , 'b', 'LineWidth',2);

hold off;
disp('end')

