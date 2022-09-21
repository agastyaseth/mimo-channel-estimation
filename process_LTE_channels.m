function process_LTE_channels(input_file, output_file)
%
% process_LTE_channels(chan_data_file)
%
%    Converts the Time Domain LTE EPA channel taps of the users 
%    and interferers to frequency domain. Saves the converted
%    frequency domain channel matrices to a MATLAB file
%

% Set default values for the filenames
if (~exist('input_file', 'var'))
    input_file='massive_mimo_channels.mat';
end

if (~exist('output_file', 'var'))
    output_file='processed_channels.mat';
end

% Sampling rate of the time domain channel samples
Fs=100e6; % 10 ns

% Number of sub-carriers
N_f=64;

% Number of users
N_users=10;

% Number of interferers
N_interferers=6;

% Number of channel matrices for each user equipment
% and each interfering equipment
N_channels=64;

% Number of Rx antennas of the base station
M=64;


%
% Load the file containing the LTE EPA channel coefficients
% for N_Rx=64 and N_Tx=1 antennas, Doppler=5 Hz
%
% The data is stored in the following fields:
%    interferer_channels: {6×64 cell} - Channel matrices between each of the 6 interferers and the base station
%    user_k_channels: {10×64 cell} - Channel matrices between the 10 users and the base station
%
%
% Each field has the following structure:
%    ChannelFilterDelay - number of channel taps
%    PathSampleDelays   - vector containing the delays of each tap
%    PathGains          - complex path gain of each tap (T x (L x P) x N)
%                         T = Number of output samples, L = Number of paths, 
%                         P = Number of Tx antennas, N = Number of Rx antennas
%    AveragePathGaindB  - average path gain of each tap
%
chan_data=open(input_file);

% Allocate memory for the 64 time domain and frequency
% domain channel responses for the wireless propagation
% path from the user's equipment to the base station.
%
% Each entry of the cells contain an M x N_f matrix
%
user_h=cell(N_users, N_channels);
user_H=cell(N_users, N_channels);

for user_idx=1:N_users
    for chan_idx=1:N_channels
        % Get one channel information structure for one user.
        % There are 64 such channel instances that we have to iterate over.
        curr_user_channels = chan_data.user_channels{user_idx, chan_idx};

        % Allocate memory for the M x N_f channel matrix h and H
        h=zeros(M, N_f);
        H=zeros(M, N_f);

        for ant_idx=1:M
            % Get the 7 element row vector of path delays in units of samples
            % This is the delay of each path taken by the transmitted signal from
            % the user's Tx antenna to the base station's Rx antenna
            %
            % For the LTE EPA channel, the delays are:
            %   [0 30 70 90 110 190 410] ns
            %
            % Since the channel is sampled at 100 MHz, the period between samples
            % is 10 ns. Therefore, the path delays in units of samples are:
            %   [0 3 7 9 11 19 41] samples
            %
            path_delays=round(curr_user_channels.PathSampleDelays);

            % Get the 7 element row vector of complex path gains from the single
            % Tx antenna of the user equipment to one of the 64 Rx antennas
            % of the base station.
            path_gains=curr_user_channels.PathGains(1,:,:,ant_idx);

            % Time domain impulse response in 100 MHz sampling rate 
            % (i.e. each sample of h_curr is 10 ns apart). We allocate
            % N_f entries for the time domain impulse response as we
            % want the frequency response of the channel to contain N_f
            % sub-carriers
            h_curr=zeros(1, N_f);
            h_curr(path_delays+1)=path_gains;

            % Get the channel frequency response for the channel from the single
            % Tx antenna of the user equipment to one out of the 64 Rx antennas
            % of the base station. The frequency response is normalized so that 
            % rms(h_curr) == rms(H_curr)
            H_curr=(1/sqrt(N_f)) * fftshift(fft(h_curr));

            % Save the channel impulse response to each row of the h matrix
            h(ant_idx,:)=h_curr;

            % Save the channel frequency response to each row of the H matrix
            H(ant_idx,:)=H_curr;
        end

        % Save the h and H matrix for the current channel instance for this user.
        % For each user, there are 64 such channel instances.
        user_h{user_idx, chan_idx}=h;
        user_H{user_idx, chan_idx}=H;
    end
end

% Save the user's h and H matrices to a MATLAB file
save(output_file, 'user_h', 'user_H');

% Clear up memory
clear user_h, user_H;


% Allocate memory for the 64 time domain and frequency
% domain channel responses for the wireless propagation
% path from the interferer's equipment to the base station.
%
% Each entry of the cells contain an M x N_f matrix
%
interf_h=cell(N_interferers, N_channels);
interf_H=cell(N_interferers, N_channels);

for (interf_idx=1:N_interferers)
    for chan_idx=1:N_channels
        % Get one channel information structure for one interferer.
        % There are 64 such channel instances that we have to iterate over.
        curr_interf_channels = chan_data.interferer_channels{interf_idx, chan_idx};

        % Allocate memory for the M x N_f channel matrix h and H
        h=zeros(M, N_f);
        H=zeros(M, N_f);

        for ant_idx=1:M
            % Get the 7 element row vector of path delays in units of samples
            % This is the delay of each path taken by the transmitted signal from
            % the interferers's Tx antenna to the base station's Rx antenna
            %
            % For the LTE EPA channel, the delays are:
            %   [0 30 70 90 110 190 410] ns
            %
            % Since the channel is sampled at 100 MHz, the period between samples
            % is 10 ns. Therefore, the path delays in units of samples are:
            %   [0 3 7 9 11 19 41] samples
            %
            path_delays=round(curr_interf_channels.PathSampleDelays);

            % Get the 7 element row vector of complex path gains from the single
            % Tx antenna of the interferer equipment to one of the 64 Rx antennas
            % of the base station.
            path_gains=curr_interf_channels.PathGains(1,:,:,ant_idx);

            % Time domain impulse response in 100 MHz sampling rate 
            % (i.e. each sample of h_curr is 10 ns apart). We allocate
            % N_f entries for the time domain impulse response as we
            % want the frequency response of the channel to contain N_f
            % sub-carriers
            h_curr=zeros(1, N_f);
            h_curr(path_delays+1)=path_gains;

            % Get the channel frequency response for the channel from the single
            % Tx antenna of the interferer equipment to one out of the 64 Rx antennas
            % of the base station. The frequency response is normalized so that 
            % rms(h_curr) == rms(H_curr)
            H_curr=(1/sqrt(N_f)) * fftshift(fft(h_curr));

            % Save the channel impulse response to each row of the h matrix
            h(ant_idx,:)=h_curr;

            % Save the channel frequency response to each row of the H matrix
            H(ant_idx,:)=H_curr;
        end

        % Save the h and H matrix for the current channel instance for this interferer.
        % For each interferer, there are 64 such channel instances.
        interf_h{interf_idx, chan_idx}=h;
        interf_H{interf_idx, chan_idx}=H;
    end
end

% Save the interferer's h and H matrices to the same MATLAB output file
save(output_file, 'interf_h', 'interf_H', '-append');

