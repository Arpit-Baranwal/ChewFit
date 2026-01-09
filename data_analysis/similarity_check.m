function output = similarity_check(seq, signal)
    % Define the parameters for computing the coherence
    windowSize = 512;        % Length of the window (in samples)
    overlap = windowSize/2;  % Overlap between consecutive windows (in samples)
    samplingRate = 1000;     % Sampling rate of the signals (in Hz)
    
    % Compute the spectral coherence
    [coherence, frequencies] = mscohere(seq, signal, windowSize, overlap, [], samplingRate);
    
    % Plot the coherence
    plot(frequencies, coherence);
    title('Spectral Coherence');
    xlabel('Frequency (Hz)');
    ylabel('Coherence');
    
end