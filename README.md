# Spindle detection and multitaper analysis

This MATLAB subset of the Spindle Dynamics Toolbox contains the time-frequency (TF) sigma peak detector and multitaper spectral estimators from Chen et al., *PNAS* 2025. The point-process GLM, GUI, and their figures and documentation have been removed.

## Setup

Add the retained source directories to the MATLAB path:

```matlab
addpath('helper_function/TFsigma_peak_detector');
addpath('helper_function/multitaper');
addpath('helper_function/multitaper/multitaper_spectrogram_mex');
addpath('helper_function/utils');
```

The detector uses the Signal Processing Toolbox for DPSS tapers and artifact filtering and the Statistics and Machine Learning Toolbox for peak selection. `multitaper_spectrogram_mex` uses a prebuilt platform MEX binary when available and falls back to the MATLAB implementation if it cannot run.

## Run the synthetic example

In MATLAB, run `runexample` from this repository. It loads `example_data/synthetic_low_frequency_eeg.mat`, detects events centered in 3–10 Hz, and plots the EEG above the multitaper spectrogram. The example uses a 2-second multitaper window with 0.05-second steps and calculates the spectrogram through 15 Hz, leaving context around the 3–10 Hz search band. Detected events are highlighted on the EEG and marked at their center time and frequency on the spectrogram. The script leaves `spindle_table`, `mt_spect`, and `figure_handle` in the workspace. The 60-second sample has 11 tapered 6 Hz bursts in N2-like noise. `example_data/generate_synthetic_low_frequency_eeg.m` recreates it with a fixed random seed. The original 13 Hz sample and its generator remain in `example_data/`.

## Main functions

- `TF_peak_detection(EEG, Fs, sleep_stages, ...)` computes a multitaper spectrogram, detects TF sigma peaks, and returns a spindle table. `EEG` is a vector, `Fs` is its sampling rate in Hz, and `sleep_stages` is an N-by-2 matrix of stage transition times (seconds) and stage values. Stages 1, 2, and 3 correspond to N3, N2, and N1. The default detector searches for peaks in 9–17 Hz; use `spindle_freq_range` to restrict the final spindle frequencies. Use `'artifact_detect', false` if artifact rejection is already handled upstream.
- `multitaper_spectrogram` and `multitaper_spectrogram_mex` compute time-frequency power. The latter tries the included MEX implementation and has a MATLAB fallback.
- `multitaper_spectrum` and `multitaper_spectrum_mex` compute power spectra.
- `compute_mtspect_power` integrates spectrogram power over a chosen frequency band. Its default 0.3–1.5 Hz band is for slow oscillations; set `freq_range` for other bands.

The remaining files in `helper_function/TFsigma_peak_detector` implement peak finding, selection, and optional frequency-cluster analysis. The files in `helper_function/utils` are dependencies of those functions and the optional plotting paths. `example_data/example_data1.mat` is retained as an EEG sample from the original toolbox.

## Citation and license

If you use the spindle detector, cite Shuqiang Chen et al., “Individualized temporal patterns drive human sleep spindle timing,” *PNAS* 122(2): e2405276121 (2025), doi:10.1073/pnas.2405276121. See `CITATION.cff` and `LICENSE` for citation metadata and license terms. The multitaper implementation's own details and attribution are in `helper_function/multitaper/README.md`.
