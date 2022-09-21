%% Script to generate the EPA channels from the MATLAB lteFadingChannel in 
% LTE Toolbox

close all; clear all; clc;

%% Initializing Channel Configuration

chcfg.DelayProfile = 'EPA'; % walking user model
chcfg.NRxAnts = 64; % number of base station antennas
chcfg.DopplerFreq = 5; % Maximum Doppler frequency, in Hz.
chcfg.MIMOCorrelation = 'Low'; % Correlation between UE and eNodeB antennas
chcfg.Seed = 1; 
chcfg.InitPhase = 'Random';
chcfg.ModelType = 'GMEDS';
chcfg.NTerms = 16;
chcfg.NormalizeTxAnts = 'On'; % normalizes the model output by 1/sqrt(P)
chcfg.NormalizePathGains = 'On';
chcfg.InitTime = 0;
chcfg.SamplingRate = 100e6; % time taken by each frame

%% 
