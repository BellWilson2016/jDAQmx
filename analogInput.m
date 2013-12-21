%% 
%		analogInput()
%
%		A class for NI DAQmx data acquisition from the libraries.
%
%		JSB 12/2013
%%
classdef analogInput < handle

	properties
		libName
		taskHandle
		deviceName
		sampleRate
		nSamples
		nChannels
		channelList
	end

	methods

		% Create a task
		function AI = analogInput(deviceName)
			% Load the library, if necessary
			AI.libName = jDAQmx();

			AI.deviceName = deviceName;
			AI.nChannels = 0;
			AI.channelList = {};
			taskName = ['AI-',datestr(now,'MMSS')];
			AI.taskHandle = uint32(1);
			[err,b,AI.taskHandle] = calllib(AI.libName,...
					'DAQmxCreateTask', taskName, AI.taskHandle);

			if (err ~= 0 )
				disp(['Error: ',num2str(err)]);
			end

		end

		function addChannel(AI, channelList)

			DAQmx_Val_Volts =  10348;
			DAQmx_Val_Diff  =  10106;
			DAQmx_Val_RSE   =  10083;
			DAQmx_Val_NRSE  =  10078;
			DAQmx_Val_PseudoDiff = 12529;
		
			for chN = 1:length(channelList)
				AI.nChannels = AI.nChannels + 1;
				AI.channelList{end+1} = [AI.deviceName,'/ai',num2str(channelList(chN))];
				err = calllib(AI.libName, 'DAQmxCreateAIVoltageChan',AI.taskHandle,...
					[AI.deviceName,'/ai',num2str(channelList(chN))],'', DAQmx_Val_Diff,...
					-10,10, DAQmx_Val_Volts,'');

				if (err ~= 0 )
					disp(['Error: ',num2str(err)]);
				end
			end
		end

		function setSampleRate(AI, sampleRate, numSamples)

			DAQmx_Val_Rising = 10280;
			DAQmx_Val_Falling = 10171;
			DAQmx_Val_FiniteSamps = 10178;

			AI.sampleRate = sampleRate;
			AI.nSamples = numSamples;

			% DAQmxCfgSampClkTiming
			err = calllib(AI.libName, 'DAQmxCfgSampClkTiming',AI.taskHandle,...
				'OnboardClock', AI.sampleRate, DAQmx_Val_Rising, DAQmx_Val_FiniteSamps, AI.nSamples);

			if (err ~= 0 )
				disp(['Error: ',num2str(err)]);
			end
		end

		function start(AI)
			% DAQmxStartTask
			err = calllib(AI.libName, 'DAQmxStartTask', AI.taskHandle);
			
			if (err ~= 0 )
				disp(['Error: ',num2str(err)]);
			end
		end

		function wait(AI, waitTime)

			if nargin < 2
				waitTime = -1;
			end

			% DAQmxWaitIntilTaskIsDone
			err = calllib(AI.libName, 'DAQmxWaitUntilTaskDone', AI.taskHandle,...
				waitTime);

			if (err ~= 0 )
				disp(['Error: ',num2str(err)]);
			end
		end

		function data = getData(AI)

			DAQmx_Val_GroupByChannel = 0;

			dataSize = AI.nChannels*AI.nSamples;
			data = ones(dataSize,1);

			% DAQmxReadAnalogF64 (Use numSampsPerChannel = -1)
			sampsPerChan = -1;
			timeOut = .25;
			samplesRead = uint32(1);
			[err, data, samplesRead, empty] = calllib(AI.libName, 'DAQmxReadAnalogF64', AI.taskHandle,...
				sampsPerChan, timeOut, DAQmx_Val_GroupByChannel,...
				data, dataSize, samplesRead, []);	

			if (err ~= 0 )
				disp(['Error: ',num2str(err)]);
			end

			data = reshape(data, AI.nChannels, AI.nSamples)';
		end

		function stop(AI)

			err = calllib(AI.libName, 'DAQmxStopTask', AI.taskHandle);

			if (err ~= 0 )
				disp(['Error: ',num2str(err)]);
			end
		end

		function clear(AI)

			err = calllib(AI.libName, 'DAQmxClearTask', AI.taskHandle);

			if (err ~= 0 )
				disp(['Error: ',num2str(err)]);
			end
		end
	end

end	
