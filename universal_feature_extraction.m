function [features, parameters] = universal_feature_extraction(dataset, fs, dataset_name) %, winlength, overlapratio, chlabels)

% INPUT:
% dataset      = NSAMPLES x NCH x NTRIALS.
%                E.g., tmp = EEG_segments(2,:);
%                data = cell2mat(tmp); data = reshape(data, size(data,1), 2000, 32); dataset = permute(data,[2 3 1]);
% fs           = sampling frequency [Hz]
% dataset_name = {'', 'eeg', 'emg'};  %default


% OUTPUT:
% features = NFEATURES x NCH x NTRIALS.



% -- Time domain uni-dimensional features --
%
% MIN:  min amplitude value
% MAX:  max amplitude value
% MEAN: mean amplitude value
% MED:  median amplitude value
% SD:   standard deviation from the mean
% VAR:  variance from the mean
% PP:   peak-to-peak distance (range)
% ZC:   zero-crossings
% AUC:  area under curve
% RMS:  root mean square (entire segment)
% MP:   mean (amplitude) power
% MAV:  mean absolute value
% WL:   waveform length
% SK:   skewness
% KUR:  kurtosis


% -- Frequency domain uni-dimensional features --
%
% MNF: mean frequency (in power spectrum)
% MDF: median frequency (in power spectrum)
% SPC: spectral centroid (see https://en.wikipedia.org/wiki/Spectral_centroid)
% EN:  signal's energy (area under the power spectrum curve). Could be computed also in the time domain (Parseval's theorem).
% BPd: band power in delta band (0.5,4) Hz
% BPt: band power in theta band (4,8) Hz
% BPa: band power in alpha band (8,13) Hz
% BPb: band power in beta band  (13,30) Hz
% BPg: band power in gamma band >=30 Hz


%% Copyright: Giulia Cisotto. Last modified: 2021/06/25




%% Parameters
parameters.dataset_name   = dataset_name;
parameters.fs             = fs;
parameters.featnames.time = {'MIN', 'MAX', 'MEAN', 'MED', 'SD', 'VAR', 'PP', 'ZC', 'AUC', 'RMS', 'MP', 'MAV', 'EN', 'WL', 'SK', 'KUR'};
parameters.featnames.freq = {'MNF', 'MDF', 'SPC', 'BPd', 'BPt', 'BPa', 'BPb', 'BPg'};

%% Initialization
features = [];
features_time = [];
features_freq = [];
[NSAMPLES, NCH, NTRIALS] = size(dataset);


%% Feature extraction
for nt = 1:NTRIALS
    fprintf('Trial no.%d..\n', nt)
    for ch=1:NCH
        fprintf('Channel no.%d..\n', ch)
        
        % Get the current signal's segment
        x = squeeze( dataset(:,ch,nt) );
        
                
        % Extract all time-domain features
        [features_time] = extract_time_features(x, fs);
                
                        
        
        % Extract all time-domain features
        [features_freq, Pxx_avg, f] = extract_freq_features(x, fs);
        % figure, plot(f, Pxx_avg, 'k', 'linewidth', 2), grid
        
                
        
        % Fusion: merge features into one feature vector
        if strcmp(dataset_name,'emg')
            features(:,ch,nt) = [features_time, features_freq(1:end-5)];
            parameters.featnames.freq = {'MNF', 'MDF', 'SPC'};
        else
            features(:,ch,nt) = [features_time, features_freq];
        end
        
    end
end