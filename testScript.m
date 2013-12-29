% testScript.m
%
% This demonstrates simultaneous analog and digital input and output using jDAQmx
%
%%

import jDAQmx.*;

sampleRate  = 10000;  % Hz
trialLength =    10;  % Sec

% Create a stimulus, should by a matrix of size (nSamples, nChannels)
stimulus1 = zeros(trialLength*sampleRate,1);
stimulus1(50000:60000) = 5;
stimulus2 = zeros(trialLength*sampleRate,1);
stimulus2(70000:80000) = 5;
stimulus = [stimulus1,stimulus2];

% Make a digital stimulus
% This should also be of size (nSamples, nChannels)
digStim = sign(stimulus);

% Setup the input channels - these are the main timebase for all the tasks.
AI = analogInput('Dev1');	
AI.addChannel(0:1);
nSamplesToOutput = trialLength*sampleRate;
AI.setSampleRate(sampleRate,nSamplesToOutput);

% Setup the output channels - these trigger off the AI task.
AO = analogOutput('Dev1');
AO.addChannel(0:1);
AO.setSampleRate(sampleRate,nSamplesToOutput);
% Put data into the output buffer and start the task. (No samples will
% be output until AI starts, but starting the task is necessary so it 
% will respond to the AI trigger.)
AO.putData(stimulus);
AO.start();

% Setup the digital channels. These also trigger off of AI start.
%DI = digitalInput('Dev1');
%DI.addChannel(0:1);
%DI.setSampleRate(sampleRate,nSamplesToOutput);
% Again, start the task so it will be ready to acquire when AI starts.
%DI.start();

% Same drill for digital output.
DO = digitalOutput('Dev1');
DO.addChannel(2:3);
DO.setSampleRate(sampleRate,nSamplesToOutput);
% Again, put the data there, and start the task.
DO.putData(digStim);
DO.start();

% This also triggers the DI, AO, and DO
AI.start();
disp('Started acquisition waiting...');
AI.wait();
disp('Finished acquisition, getting data...');
dataInAnalog  = AI.getData();
%dataInDigital = DI.getData();
disp('Data done got got.');

% Stop and clear the tasks to free resources for future use.
AI.stop(); 
AI.clear();
AO.stop(); 
AO.clear();
%DI.stop();
%DI.clear();
DO.stop();
DO.clear();


