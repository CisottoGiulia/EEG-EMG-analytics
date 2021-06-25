

function [features_freq, Pxx_avg, f] = extract_freq_features(x, fs)
% -- Frequency domain uni-dimensional features --
%
% MNF: mean frequency (in power spectrum)
% MDF: median frequency (in power spectrum)
% SPC: spectral centroid (see https://en.wikipedia.org/wiki/Spectral_centroid)
% BPd: band power in delta band (0.5,4) Hz
% BPt: band power in theta band (4,8) Hz
% BPa: band power in alpha band (8,13) Hz
% BPb: band power in beta band  (13,30) Hz
% BPg: band power in gamma band >=30 Hz



%% Initialization
features_freq = [];



%% Power spectrum computation
L    = fs/2; % no. samples
NFFT = 2^nextpow2(L);
f    = 0:fs/NFFT:fs - fs/NFFT; % f_trial (prova_CMC_NatInstr.m) --> f
n    = 1:L:length(x)-L+1;

Axx_avg = zeros(1,NFFT);
Pxx_avg = zeros(1,NFFT);

for ni = 1:length(n) % no. sliding windows in one segment
    
    x_segment      = x( n(ni) : n(ni)+L-1 ).';
    X_segment      = fft(x_segment.*hanning(L).', NFFT); % two-sided FFT of x, real-valued
    Axx_segment    = sqrt(X_segment.*conj(X_segment))/L; % two-sided FFT amplitude spectrum of x, real-valued
    Axx_segment_ss = 2*Axx_segment(1:end/2);             % single-sided FFT amplitude spectrum of x, real-valued
    Pxx_segment    = Axx_segment.^2;                     % two-sided FFT power spectrum of x, real-valued
    Pxx_segment_ss = Axx_segment_ss.^2;                  % single-sided FFT power spectrum of x, real-valued
    
    Axx_avg        = Axx_avg + Axx_segment;
    Pxx_avg        = Pxx_avg + Pxx_segment;             % two-sided, real-valued

end
Axx_avg = Axx_avg /length(n); 
Pxx_avg = Pxx_avg /length(n);          % average across segments



% MNF: mean frequency (in power spectrum)
MNF = meanfreq(Pxx_avg,f);


% MDF: median frequency (in power spectrum)
MDF = medfreq(Pxx_avg,f);


% SPC: spectral centroid (see https://en.wikipedia.org/wiki/Spectral_centroid)
SPC = sum(f.*Axx_avg)/sum(Axx_avg); % with AUDIO PROC Matlab's toolbox: SPC = spectralCentroid(Pxx_avg,f);


% Band power in bands of interest
myInt = cumtrapz(f,Pxx_avg);
myIntv = @(a,b) max(myInt(f<=b)) - min(myInt(f>=a));

% BPd: band power in delta band (0.5,4) Hz
BPd = myIntv(0.5,4);

% BPt: band power in theta band (4,8) Hz
BPt = myIntv(4,8);

% BPa: band power in alpha band (8,13) Hz
BPa = myIntv(8,13);

% BPb: band power in beta band  (13,30) Hz
BPb = myIntv(13,30);

% BPg: band power in gamma band >=30 Hz
BPg = myIntv(30,f(end));





%% Feature vector
features_freq = [MNF, MDF, SPC, BPd, BPt, BPa, BPb, BPg];


% psdest = psd(spectrum.periodogram,x,'Fs',Fs,'NFFT',length(x));
% avgpower(psdest,[25 75])
        

end