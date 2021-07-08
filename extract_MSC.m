function [f,MSCoh,Pxx1_avg,Pxx2_avg,Px1x2_avg] = extract_MSC(x1,x2,fs,t,figplot)
% This function computes the MSC from two signals (x1, x2).
% To be more robust, it segments both of them in 0.5s-segments, computes
% the power spectrum of x1 and x1, as well as the cross-spectrum between x1
% and x2. Then, for each spectrum, it takes the mean across segments.
% Finaly, the MSC is computed from the averaged spectra.
%
%
% x1      - your first signal of interest
% x2      - your second signal of interest
% fs      - sampling frequency [Hz]
% t       - time vector [s]
% figplot - flag to plot, or not to plot, figures
%
%
% Example:
% x1      = 10*sin(2*pi*15*t);
% x2      = 0.5*sin(2*pi*15*t) + 5*sin(2*pi*41*t);
% fs      = 1000;
% t       = 0:1/fs:100-1/fs;
% [x1, ~] = control_SNR(x1, fs, 10, 'pink', 1);   % needed only in case of pure sinusoidal signals to avoid numerical errors
% [f,MSCoh,Pxx1_avg,Pxx2_avg,Px1x2_avg] = extract_MSC(x1,x2,fs,t,1);
%
%
% Created by Giulia Cisotto, last update on 2021/07/08.
% ------------------------------------------------------------------------------



figure, subplot(211), plot(t, x1), grid, xlim([10 11])
        subplot(212), plot(t, x2), grid, xlim([10 11])


% Segmentation (to have multiple segments within the same segment and compute coherence)
L = fs/2; % no. samples
NFFT = 2^nextpow2(L);
f = 0:fs/NFFT:fs - fs/NFFT; % f_trial (prova_CMC_NatInstr.m) --> f
n = 1:L:length(x1)-L+1;

Pxx1_avg = zeros(1,NFFT);
Pxx2_avg = zeros(1,NFFT);
Px1x2_avg = zeros(1,NFFT);
for ni = 1:length(n) % no. segments
    
    x1_segment = x1( n(ni) : n(ni)+L-1 );
    x2_segment = x2( n(ni) : n(ni)+L-1 );
        
    
%     % Perfect, if fmin=10Hz and L=500
%     X1_segment = fft(x1_segment, NFFT); % two-sided FFT of x1, real-valued
%     X2_segment = fft(x2_segment, NFFT);
    
    
    % Alternative, in case of fmin=10Hz and L~=500
    X1_segment = fft(x1_segment.*hanning(L).', NFFT); % two-sided FFT of x1, real-valued
    X2_segment = fft(x2_segment.*hanning(L).', NFFT);
    %
    
    Axx1_segment = sqrt(X1_segment.*conj(X1_segment))/L;  % two-sided FFT power spectrum of x1, real-valued
    Axx1_segment_ss = 2*Axx1_segment(1:end/2);  
    Axx1_segment_ss(1) = 0;    % single-sided FFT power spectrum of x1, real-valued
    Axx2_segment = sqrt(X2_segment.*conj(X2_segment))/L;  % two-sided FFT power spectrum of x2, real-valued  
    Axx2_segment_ss = 2*Axx2_segment(1:end/2);  
    Axx2_segment_ss(1) = 0;    % single-sided FFT power spectrum of x2, real-valued

    
    
    Pxx1_segment = Axx1_segment.^2;                     % two-sided FFT power spectrum of x1, real-valued
    Pxx2_segment = Axx2_segment.^2;                     % two-sided FFT power spectrum of x2, real-valued   
    
    Pxx1_segment_ss = Axx1_segment_ss.^2;               % single-sided FFT power spectrum of x1, real-valued
    Pxx2_segment_ss = Axx2_segment_ss.^2;               % single-sided FFT power spectrum of x2, real-valued   
            
    Px1x2_segment       = X1_segment.*conj(X2_segment)/ (L^2);  % two-sided FFT cross-power spectrum between x1 and x2, complex-valued
    Px1x2_segment_ss    = 4*Px1x2_segment(1:end/2);
    Px1x2_segment_ss(1) = 0;                                % single-sided FFT cross-power spectrum between x1 and x2, complex-valued    
    
        
    Pxx1_avg  = Pxx1_avg  + Pxx1_segment;   % two-sided, real-valued
    Pxx2_avg  = Pxx2_avg  + Pxx2_segment;   % two-sided, real-valued
    Px1x2_avg = Px1x2_avg + Px1x2_segment;  % two-sided, complex-valued
end

% QUESTE TRE RIGHE SONO INUTILI PER Coh (i denominatori si annullano poi)
% Pxx1_avg  = Pxx1_avg /length(n);          % average across segments
% Pxx2_avg  = Pxx2_avg /length(n);          % average across segments
% Px1x2_avg = Px1x2_avg/length(n);          % average across segments

figure, plot(f,abs( Px1x2_avg ).^2,'b', 'linewidth', 2), hold on, plot(f,Pxx1_avg.*Pxx2_avg,'r--', 'linewidth', 1.5),
        grid, xlim([0 50]), legend num den
MSCoh = abs( Px1x2_avg ).^2 ./ (Pxx1_avg.*Pxx2_avg);
% With a sufficiently large signal segment, we get good estimation.
% L = 500 samples is ok! ...with fmin = 10 Hz;, fs = 1000 Hz, T(fmin) = 1/10 seconds * 1000 ssamples = 100 samples/cycle ==> should have 4-5 cycle for good estimation, thus 400-500 samples!
% With L~=integer multiple of period of slowest frequency component, we get distortion of the spectrum.


if figplot
figure, subplot(221), plot(f, Pxx1_avg, 'k'),          grid, xlim([0 80]), title('Power spectrum x1 (average on segments)')
        subplot(222), plot(f, Pxx2_avg, 'k'),          grid, xlim([0 80]), title('Power spectrum x2 (average on segments)')
        subplot(223), plot(f, abs(Px1x2_avg).^2, 'k'), grid, xlim([0 80]), title('Cross-power spectrum x1-x2 (average on segments)')
        subplot(224), plot(f, MSCoh, 'k'),               grid, xlim([0 80]), ylim([0 1]), title('Magnitude square coherence x1-x2')
end


return