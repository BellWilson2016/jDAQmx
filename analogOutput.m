%% 
%		analogOutput()
%
%		A class for NI DAQmx data acquisition from the libraries.
%
%		JSB 12/2013
%%
classdef analogOutput < handle

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
		function AO = analogOutput(deviceName)
			% Load the library, if necessary
			AO.libName = jDAQmx();

			AO.deviceName = deviceName;
			AO.nChannels = 0;
			AO.channelList = {};
			taskName = ['AO-',datestr(now,'MMSS')];
			AO.taskHandle = uint32(1);
			[err,b,AO.taskHandle] = calllib(AO.libName,...
					'DAQmxCreateTask', taskName, AO.taskHandle);

			if (err ~= 0)
				disp(['Error: ',num2str(err)]);
			end
		end

		function addChannel(AO, channelList)

			DAQmx_Val_Volts =  10348;
		
			for chN = 1:length(channelList)
				AO.nChannels = AO.nChannels + 1;
				AO.channelList{end+1} = [AO.deviceName,'/ao',num2str(channelList(chN))];

				err = calllib(AO.libName, 'DAQmxCreateAOVoltageChan',AO.taskHandle,...
					[AO.deviceName,'/ao',num2str(channelList(chN))],'',...
					-10,10, DAQmx_Val_Volts,'');

				if (err ~= 0)
					disp(['Error: ',num2str(err)]);
				end
			end
		end

		function setSampleRate(AO, sampleRate, numSamples)

			DAQmx_Val_Rising = 10280;
			DAQmx_Val_Falling = 10171;
			DAQmx_Val_FiniteSamps = 10178;

			AO.sampleRate = sampleRate;
			AO.nSamples = numSamples;

			% Configure for sample rate and number of samples	
			% Use the ai/SampleClock so it's correlated
			% Trigger will come with this.
			err = calllib(AO.libName, 'DAQmxCfgSampClkTiming',AO.taskHandle,...
				'ai/SampleClock', AO.sampleRate, DAQmx_Val_Rising, DAQmx_Val_FiniteSamps, AO.nSamples);

			if (err ~= 0)
				disp(['Error: ',num2str(err)]);
			end
		end

		function start(AO)
			% DAQmxStartTask
			err = calllib(AO.libName, 'DAQmxStartTask', AO.taskHandle);

			if (err ~= 0)
				disp(['Error: ',num2str(err)]);
			end
		end


		function wait(AO, waitTime)

			if nargin < 2
				waitTime = -1;
			end

			% DAQmxWaitIntilTaskIsDone
			err = calllib(AO.libName, 'DAQmxWaitUntilTaskDone', AO.taskHandle,...
				waitTime);

			if (err ~= 0)
				disp(['Error: ',num2str(err)]);
			end
		end

		function putData(AO, data)

			DAQmx_Val_GroupByChannel = 0;

			% Check to make sure it's the right size
			if (size(data,1) ~= AO.nSamples) || (size(data,2) ~= AO.nChannels)
				disp(['Error: Input matrix should be size( nSamples, nChannels) - (',...
						num2str(nSamples),', ',num2str(nChannels),')']);
				return;
			end
			% Reformat to interleave data
			data = data';
			data = data(:);

			sampsPerChan = AO.nSamples;
			timeOut = .25;
			autoStart = 0;
			samplesWritten = uint32(1);
			[err dataOut samplesWritten d] = calllib(AO.libName, 'DAQmxWriteAnalogF64', AO.taskHandle,...
				sampsPerChan, autoStart, timeOut, DAQmx_Val_GroupByChannel,...
				data, samplesWritten, []);	

			if (err ~= 0)
				disp(['Error: ',num2str(err)]);
			end

		end

		function stop(AO)

			err = calllib(AO.libName, 'DAQmxStopTask', AO.taskHandle);

			if (err ~= 0)
				disp(['Error: ',num2str(err)]);
			end
		end

		function clear(AO)

			err = calllib(AO.libName, 'DAQmxClearTask', AO.taskHandle);

			if (err ~= 0)
				disp(['Error: ',num2str(err)]);
			end
		end
	end

end	
