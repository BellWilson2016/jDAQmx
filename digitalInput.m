%% 
%		digitalInput()
%
%		A class for NI DAQmx data acquisition from the libraries.
%
%		JSB 12/2013
%%
classdef digitalInput < handle

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
		function DI = digitalInput(deviceName)
			% Load the library, if necessary
			DI.libName = jDAQmx();

			DI.deviceName = deviceName;
			DI.nChannels = 0;
			DI.channelList = {};
			taskName = ['DI-',datestr(now,'MMSS')];
			DI.taskHandle = uint32(1);
			[err,b,DI.taskHandle] = calllib(DI.libName,...
					'DAQmxCreateTask', taskName, DI.taskHandle);

			if (err ~= 0 )
				disp(['Error: ',num2str(err)]);
			end

		end

		function addChannel(DI, channelList)

			DAQmx_Val_ChanPerLine = 0;	
				
			for chN = 1:length(channelList)
				DI.nChannels = DI.nChannels + 1;
				DI.channelList{end+1} = [DI.deviceName,'/port0/line',num2str(channelList(chN))];
				err = calllib(DI.libName, 'DAQmxCreateDIChan', DI.taskHandle,...
					[DI.deviceName,'/port0/line',num2str(channelList(chN))],'', ...
					DAQmx_Val_ChanPerLine);
				if (err ~= 0 )
					disp(['Error: ',num2str(err)]);
				end
			end
		end

		function setSampleRate(DI, sampleRate, numSamples)

			DAQmx_Val_Rising = 10280;
			DAQmx_Val_Falling = 10171;
			DAQmx_Val_FiniteSamps = 10178;

			DI.sampleRate = sampleRate;
			DI.nSamples = numSamples;

			% DAQmxCfgSampClkTiming
			err = calllib(DI.libName, 'DAQmxCfgSampClkTiming',DI.taskHandle,...
				'ai/SampleClock', DI.sampleRate, DAQmx_Val_Rising, DAQmx_Val_FiniteSamps, DI.nSamples);

			if (err ~= 0 )
				disp(['Error: ',num2str(err)]);
			end
		end

		function start(DI)
			% DAQmxStartTask
			err = calllib(DI.libName, 'DAQmxStartTask', DI.taskHandle);
			
			if (err ~= 0 )
				disp(['Error: ',num2str(err)]);
			end
		end

		function wait(DI, waitTime)

			if nargin < 2
				waitTime = -1;
			end

			% DAQmxWaitIntilTaskIsDone
			err = calllib(DI.libName, 'DAQmxWaitUntilTaskDone', DI.taskHandle,...
				waitTime);

			if (err ~= 0 )
				disp(['Error: ',num2str(err)]);
			end
		end

		function data = getData(DI)

			DAQmx_Val_GroupByChannel = 0;

			dataSize = DI.nChannels*DI.nSamples;
			data = uint8(zeros(dataSize,1));

			sampsPerChan = -1;
			timeOut = .25;
			samplesRead = uint32(1);
			bytesPerSample = uint32(1); 
			[err, data, samplesRead, bytesPerSample] = calllib(DI.libName, 'DAQmxReadDigitalLines', DI.taskHandle,...
				sampsPerChan, timeOut, DAQmx_Val_GroupByChannel,...
				data, dataSize, samplesRead, bytesPerSample, []);	

			if (err ~= 0 )
				disp(['Error: ',num2str(err)]);
			end

			data = reshape(data, DI.nChannels, DI.nSamples)';
		end

		function stop(DI)

			err = calllib(DI.libName, 'DAQmxStopTask', DI.taskHandle);

			if (err ~= 0 )
				disp(['Error: ',num2str(err)]);
			end
		end

		function clear(DI)

			err = calllib(DI.libName, 'DAQmxClearTask', DI.taskHandle);

			if (err ~= 0 )
				disp(['Error: ',num2str(err)]);
			end
		end
	end

end	
