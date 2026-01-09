function [row] = fetch_statistics(data)
    row = [];

    % 'TD Mean'
    row(end+1) = mean(data);
    % 'TD std'
    row(end+1) = std(data);
    % 'TD rms'
    row(end+1) = rms(data);
    % 'TD variance'
    row(end+1) = var(data);
    % 'TD Skewness'
    row(end+1) = skewness(data);
    % 'TD Kurtosis'
    row(end+1) = kurtosis(data);
    % 'TD Entropy'
    row(end+1) = wentropy(data, 'shannon');

    % converting to frequency domain
    frequency_signal = fft(data);
    
    % 'FD Mean Power'
    row(end+1) = mean(abs(frequency_signal).^2);
    % 'FD std'
    row(end+1) = std(abs(frequency_signal));
    % 'FD Spectral Centroid'
    
    % Compute the magnitude spectrum
    magnitude_spectrum = abs(frequency_signal);
    % Define the frequency axis
    frequency_axis = 1:length(frequency_signal);  
    % Compute the spectral centroid
    row(end+1) = sum(sum(frequency_axis .* magnitude_spectrum) / sum(magnitude_spectrum));

    % 'FD Spectral Spread'
    % Compute the spectral centroid
    spectral_centroid = sum(frequency_axis .* magnitude_spectrum) / sum(magnitude_spectrum);
    % Compute the squared deviation from the centroid
    squared_deviation = ((frequency_axis - spectral_centroid).^2) .* magnitude_spectrum;
    % Compute the spectral spread
    row(end+1) = sqrt(sum(sum(squared_deviation) / sum(magnitude_spectrum)));

    
    % 'FD Spectral Skewness'
    % Compute the cubed deviation
    cubed_deviation = (squared_deviation.^(3/2)) .* magnitude_spectrum;
    % Compute the spectral spread
    spectral_spread = sqrt(sum(squared_deviation) / sum(magnitude_spectrum));
    % Compute the spectral skewness
    row(end+1) = sum(cubed_deviation) / (sum(magnitude_spectrum) * spectral_spread.^3);



    % 'FD Spectral Kurtosis'
    % Compute the fourth power of the deviations
    fourth_power_deviation = (squared_deviation.^2) .* magnitude_spectrum;
    % Compute the spectral spread
    spectral_spread = sqrt(sum(squared_deviation) / sum(magnitude_spectrum));
    % Compute the spectral kurtosis
    row(end+1) = sum(fourth_power_deviation)/(sum(magnitude_spectrum) * spectral_spread.^2);
    
    % 'FD Band Energy Ratios'
    X = fft(data);
    X_single = abs(X(1:int32(length(X)/2+1)));
    % Calculate the total energy
    totalEnergy = sum(X_single.^2);
    row(end+1) = totalEnergy;

    % 'FD Spectral Entropy'
    % Normalize the magnitude spectrum to obtain a probability distribution
    normalized_spectrum = magnitude_spectrum / sum(magnitude_spectrum);
    
    % Calculate the spectral entropy
    row(end+1) = -sum(normalized_spectrum .* log2(normalized_spectrum));
    
    % 'FD Peak Frequency'
    % Find the index of the maximum magnitude value
    [~, max_index] = max(magnitude_spectrum);
    
    % Retrieve the peak frequency from the frequency axis
    peak_frequency = frequency_axis(max_index);
    row(end+1) = peak_frequency;
end