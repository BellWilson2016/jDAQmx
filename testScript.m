% testScript.m
%
% This demonstrates simultaneous analog and digital input and output using jDAQmx
%
%%

sampleRate = 100;  % Hz
trialLength =  10;  % Sec

% Create a stimulus, should by a matrix of size (nSamples,nChannels)
stimulus1 = zeros(trialLength*sampleRate,1);
stimulus1(500:600) = 5;
stimulus2 = zeros(trialLength*sampleRate,1);
stimulus2(700:800) = 5;
stimulus = [stimulus1,stimulus2];

% Make a digital stimulus
digStim = sign(stimulus);


% Setup the input channels
AI = analogInput('Dev1');	
AI.addChannel(0:1);
AI.setSampleRate(sampleRate,trialLength*sampleRate);

% Setup the output channels
% By default, these trigger off of the AI start.
AO = analogOutput('Dev1');
AO.addChannel(0:1);
AO.setSampleRate(sampleRate,trialLength*sampleRate);
AO.putData(stimulus);
AO.start();

% Setup the digital channels. These also trigger off of AI start.
DI = digitalInput('Dev1');
DI.addChannel(0:1);
DI.setSampleRate(sampleRate,trialLength*sampleRate);
DI.start();

DO = digitalOutput('Dev1');
DO.addChannel(2:3);
DO.setSampleRate(sampleRate,trialLength*sampleRate);
DO.putData(digStim);
DO.start();

% This also triggers the DI, AO, and DO
AI.start();
disp('Started acquisition waiting...');
AI.wait();
disp('Finished acquisition, getting data...');
dataIn = AI.getData();
dataInDig = DI.getData();
disp('Data done got got.');

% Stop and clear the tasks to free them up
AI.stop(); 
AI.clear();
AO.stop(); 
AO.clear();
DI.stop();
DI.clear();
DO.stop();
DO.clear();


