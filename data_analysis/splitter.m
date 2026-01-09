% Note: Set the current Folder of Matlab to root dir o.w it is not working

% split to train, validation and test set using startified spliting

% data_set_signal_path
signal_path = './data_set_signal';
% data_set_spectrogram_path
spectrogram_path = './data_set_spectrogram';

% percentage of division 70, 15, 15 for train, validation and test sets
% respectively.

% from each directory in spectrogram and signals select 70% for train, 15
% percent val and the remaining for the test

train =  .7;
val   = .15;
test  = .15;

% signal data
startified_split(signal_path, train, val, test, 42, false);

% spectrogram data
startified_split(spectrogram_path, train, val, test, 42, false);

