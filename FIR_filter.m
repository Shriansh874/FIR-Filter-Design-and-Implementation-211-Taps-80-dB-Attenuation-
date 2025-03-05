clear; clc; close all;

% Normalized frequencies are given with respect to pi rad/sample.
f_pass = 0.2;        % Passband edge (normalized frequency)
f_stop = 0.23;       % Stopband edge (normalized frequency)

% Set the allowable ripples:
delta_p = 0.01;      % Maximum passband deviation (linear scale)
delta_s = 1e-4;      % Maximum stopband ripple (corresponds to 80 dB attenuation)

[n_est, fo, ao, w] = firpmord([f_pass f_stop], [1 0], [delta_p delta_s]);
fprintf('Estimated minimum filter order = %d (i.e., %d taps)\n', n_est, n_est+1);

% Enforce a minimum of 150 taps to maintain 80 dB attenuation after quantization
filter_order = max(n_est, 150);
fprintf('Using Filter Order = %d (Taps = %d)\n', filter_order, filter_order+1);

b = firpm(filter_order, fo, ao, w);

[h, w_grid] = freqz(b, 1, 2048);
mag_db = 20*log10(abs(h));
w_grid_normalized = w_grid/pi;  % Normalize frequency axis to pi

% Determine passband and stopband indices
passband_inds = w_grid_normalized <= f_pass;
stopband_inds = w_grid_normalized >= f_stop;

% Calculate ripple and stopband attenuation
passband_mag = abs(h(passband_inds));
stopband_mag = abs(h(stopband_inds));

actual_passband_ripple = max(passband_mag) - min(passband_mag);
passband_ripple_db = 20*log10(max(passband_mag)) - 20*log10(min(passband_mag));
actual_stopband_atten_db = -20*log10(max(stopband_mag));

fprintf('Actual passband ripple (linear) ~ %g, or %.4f dB\n', actual_passband_ripple, passband_ripple_db);
fprintf('Actual stopband attenuation ~ %.2f dB\n', actual_stopband_atten_db);

figure;
subplot(2,1,1);
plot(w_grid_normalized, mag_db, 'LineWidth',1.5);
grid on;
title('Magnitude Response (dB)');
xlabel('Normalized Frequency (\times \pi rad/sample)');
ylabel('Magnitude (dB)');
ylim([-120 10]);

subplot(2,1,2);
plot(w_grid_normalized, abs(h), 'LineWidth',1.5);
grid on;
title('Linear Magnitude Response');
xlabel('Normalized Frequency (\times \pi rad/sample)');
ylabel('Magnitude');

% Define fixed-point format: Q1.15 (16-bit total, 1 sign bit, 15 fractional bits)
wordLength = 16;      % 16-bit total
fracBits   = 15;      % 15 fractional bits (Q1.15 format)
scaleFactor = 2^fracBits;

% Convert floating-point coefficients to fixed-point
b_scaled = round(b * scaleFactor);

% Ensure coefficients are within signed 16-bit range
b_scaled(b_scaled >= 2^(wordLength-1)) = 2^(wordLength-1) - 1; 
b_scaled(b_scaled < -2^(wordLength-1)) = -2^(wordLength-1);

fileID = fopen('coefficients.txt','w');
for i = 1:length(b_scaled)
    fprintf(fileID, '%d\n', b_scaled(i)); 
end
fclose(fileID);

disp('Done! Wrote Q1.15 filter coefficients to coefficients.txt.');
