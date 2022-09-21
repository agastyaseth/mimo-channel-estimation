close all; clear all; clc;

chcfg.DelayProfile = 'EPA';
chcfg.NRxAnts = 64;
chcfg.DopplerFreq = 5;
chcfg.MIMOCorrelation = 'Low';
chcfg.Seed = 1;
chcfg.InitPhase = 'Random';
chcfg.ModelType = 'GMEDS';
chcfg.NTerms = 16;
chcfg.NormalizeTxAnts = 'On';
chcfg.NormalizePathGains = 'On';
chcfg.InitTime = 0;
chcfg.SamplingRate = 20e6;

% project parameters
N_f=64;
N_channels=64;

% OFDM pilot symbol used in this project. Designed so that p_sym' * p_sym = N_f
pilot_ofdm_sym=[1, 1, -1, -1, 1, -1, 1, 1,-1,-1, 1, 1,-1, 1, -1, 1, 1, 1, 1, 1, 1,-1, -1, 1, 1,-1, 1,-1, 1, 1, ...
                1, 1, 1, 1,-1,-1, 1, 1,-1, 1,-1, 1,-1,-1,-1, -1,-1, 1, 1, -1,-1, 1,-1, 1,-1, 1, 1, 1, 1, -1, -1, 1, 1, -1].';

% Generate time domain signal samples and normalize the samples to value 1
time_domain_waveform=(1/sqrt(N_f))*fftshift(ifft(pilot_ofdm_sym));

% Generate the channels for user k
user_k_channels=cell(1, N_channels);
for chan_idx=1:N_channels
    [rxWaveform, chan_info] = lteFadingChannel(chcfg, time_domain_waveform);

    % Save the channel information
    user_k_channels{1, chan_idx} = chan_info;

    % Increment the fading channel init time
    chcfg.InitTime =chcfg.InitTime + 4e-6;
end

% Generate the channels for interference user 1
N_interferer=6;
interferer_channels=cell(N_interferer, N_channels);
for (interf_idx=1:N_interferer)
    chcfg.InitTime = 0;
    chcfg.Seed = 100 * interf_idx;

    for chan_idx=1:N_channels
        [rxWaveform, chan_info] = lteFadingChannel(chcfg, time_domain_waveform);

        % Save the channel information
        interferer_channels{interf_idx, chan_idx} = chan_info;

        % Increment the fading channel init time
        chcfg.InitTime =chcfg.InitTime + 4e-6;
    end
end


save('massive_mimo_channels.mat', 'user_k_channels', 'interferer_channels');

