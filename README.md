# EEG-EMG-analytics

This repository contains a set of Matlab scripts to extract the most common EEG and EMG features, both in the time and in the frequency domain.

The repository includes the following Matlab files and one EMG signal to test the code:
- universal_feature_extraction.m that you can use to extract all features at once.
- extract_time_features.m to extract all features in the time domain, at once.
- extract_freq_features.m to extract all features in the frequency domain, at once.
- myZC.m to find the number of zero-corssings (ZC) in a signal.
- dataset.mat with size 6000 x 1 x 3, including 6000 samples and 3 repetitions of a maximal voluntary contraction task. Sampling frequency, fs: 2000 Hz.



Below is a list of the time/frequency-domain features available.

Time domain uni-dimensional features:
- MIN:  min amplitude value
- MAX:  max amplitude value
- MEAN: mean amplitude value
- MED:  median amplitude value
- SD:   standard deviation from the mean
- VAR:  variance from the mean
- PP:   peak-to-peak distance (range)
- ZC:   zero-crossings
- AUC:  area under curve
- RMS:  root mean square (entire segment)
- MP:   mean (amplitude) power
- MAV:  mean absolute value
- WL:   waveform length
- SK:   skewness
- KUR:  kurtosis

Frequency domain uni-dimensional features:
- MNF: mean frequency (in power spectrum)
- MDF: median frequency (in power spectrum)
- SPC: spectral centroid
- EN:  signal's energy (area under the power spectrum curve)
- BPd: band power in delta band (0.5,4) Hz
- BPt: band power in theta band (4,8) Hz
- BPa: band power in alpha band (8,13) Hz
- BPb: band power in beta band  (13,30) Hz
- BPg: band power in gamma band >=30 Hz




Example of use:
-------------------------------------------------------------------------------------------------------------------------------------------------------------
load dataset

fs = 2000;

[features, parameters] = universal_feature_extraction(dataset, fs, 'emg');

time = 0:1/fs:6000/fs-1/fs;

figure, plot(time, squeeze(dataset(:,1,2)),'k'), grid, xlabel('Time [s]'), ylabel('Amplitude [mV]'), title('Exemplary EMG signal')

parameters.featnames

RMS_values = squeeze(features(10,1,:))

-------------------------------------------------------------------------------------------------------------------------------------------------------------



Notes:

(1) you are supposed to have already cleaned and segmented your signal prior to run the scripts.

(2) from each segment, you can extract one set of features (i.e., one single value for each different feature).

(3) the scripts allows you to extract all features for the EEG. In case of EMG signal, you will not have the band power features (that are specific for EEG).




Citation reference:
----------------------------
Cisotto, G., Guglielmi, A. V., Badia, L., & Zanella, A. (2018, September). Classification of grasping tasks based on EEG-EMG coherence. In 2018 IEEE 20th International Conference on e-Health Networking, Applications and Services (Healthcom) (pp. 1-6). IEEE.
