function [noisy_signal, noise] = control_SNR(signal, fs, SNR, type, figplot)
% This function allows you to add pink or white noise to a signal with a
% controlled level of SNR (expressed in dB).
%
%
% signal  - signal without noise
% fs      - sampling frequency [Hz]
% SNR     - desired SNR [dB]
% type    - white, pink
% figplot - flag to plot, or not to plot, figures
%
%
% Example:
% signal  = 10*sin(2*pi*15*t);
% fs      = 1000;
% SNR     = 10;
% [noisy_signal, noise] = control_SNR(signal, fs, SNR, 'pink', 1);
%
% 
% Created by Giulia Cisotto, last update on 2021/07/08.
% ------------------------------------------------------------------------------




% Parameters
d = length(signal)/fs;
t = 0:1/fs:d-1/fs;
desired_noise_var = var(signal)/10^(SNR/10);


% Add noise
if strcmp(type, 'pink')    
    p = 0;        % pause [s]
    r = 1;        % number of repetitions
    x = pink_noise_generator(fs, d, p, r); %
    var_coeff = var(x)/desired_noise_var;
    noise = x./var_coeff; clear var_coeff
elseif strcmp(type, 'gaussian')
    x = 0 + 1.*randn(1,length(signal)); % values from a normal distribution with mean 0 and standard deviation 1.
    var_coeff = var(x)/desired_noise_var;
    noise = x./var_coeff; clear var_coeff
end



noisy_signal = signal + noise;

if figplot
   figure, plot(t,signal,'k','linewidth',2), hold on, plot(t,noisy_signal,'r'),
   grid, xlim([2 3]),ylim([min(signal)-2*std(signal) max(signal)+2*std(signal)])
   title(sprintf('%s noise at %d dB', type, SNR))
end
