function generate_synthetic_low_frequency_eeg()
%GENERATE_SYNTHETIC_LOW_FREQUENCY_EEG  Recreate the 3-10 Hz example MAT file.
% Sixty seconds of N2 noise with 1.6-second, tapered 6 Hz bursts.

Fs = 100;
duration_sec = 60;
event_centers = 5:5:55;
event_frequency = 6;
sleep_stages = [0 2; duration_sec 2];  % N2 throughout the recording

rng(1);
EEG = 0.1 * randn(1, Fs * duration_sec);
for center = event_centers
    idx = round((center - 0.8) * Fs):round((center + 0.8) * Fs);
    taper = hann(numel(idx))';
    EEG(idx) = EEG(idx) + sin(2 * pi * event_frequency * (idx - 1) / Fs) .* taper;
end

output_path = fullfile(fileparts(mfilename('fullpath')), 'synthetic_low_frequency_eeg.mat');
save(output_path, 'EEG', 'Fs', 'sleep_stages', 'event_centers', 'event_frequency', '-v7');
fprintf('Saved %s\n', output_path);
end
