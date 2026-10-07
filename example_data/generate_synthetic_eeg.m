function generate_synthetic_eeg()
%GENERATE_SYNTHETIC_EEG  Recreate synthetic_spindle_eeg.mat reproducibly.
% Sixty seconds of N2 EEG-like noise with tapered 13 Hz bursts every 2 s.

Fs = 100;
duration_sec = 60;
spindle_centers = 5:2:55;
sleep_stages = [0 2; duration_sec 2];  % N2 throughout the recording

rng(1);
EEG = 0.1 * randn(1, Fs * duration_sec);
for center = spindle_centers
    idx = round((center - 0.4) * Fs):round((center + 0.4) * Fs);
    taper = hann(numel(idx))';
    EEG(idx) = EEG(idx) + sin(2 * pi * 13 * (idx - 1) / Fs) .* taper;
end

output_path = fullfile(fileparts(mfilename('fullpath')), 'synthetic_spindle_eeg.mat');
save(output_path, 'EEG', 'Fs', 'sleep_stages', 'spindle_centers', '-v7');
fprintf('Saved %s\n', output_path);
end
