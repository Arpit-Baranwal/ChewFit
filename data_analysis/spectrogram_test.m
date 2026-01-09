food_path = 'C:\\Users\\Alil\\Documents\\Courses\\SS2023\\2ES\\repo\\data_analysis\\root\\all_vib\\seq\\02_sergei_vib_1_apple.txt';

fid = fopen(food_path, 'r');
sequence = fscanf(fid, '%f');
fclose(fid);

sequence = hampel(sequence);

windowLength = 2048; 
overlap = round(windowLength * 0.50); 

spectrogram(sequence, windowLength, overlap, [], 24000, 'yaxis');

% Customize the plot (optional)
title('Spectrogram');
xlabel('Time');
ylabel('Frequency');