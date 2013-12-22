%% 
%		digitalOutput()
%
%		A class for NI DAQmx data acquisition from the libraries.
%
%		JSB 12/2013
%%
classdef digitalOutput < handle

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
		function DO = digitalOutput(deviceName)
			% Load the library, if necessary
			DO.libName = jDAQmx();

			DO.deviceName = deviceName;
			DO.nChannels = 0;
			DO.channelList = {};
			taskName = ['DO-',datestr(now,'MMSS')];
			DO.taskHandle = uint32(1);
			[err,b,DO.taskHandle] = calllib(DO.libName,...
					'DAQmxCreateTask', taskName, DO.taskHandle);

			if (err ~= 0)
				disp(['Error: ',num2str(err)]);
			end
		end

		% By default, assign lines in port0
		function addChannel(DO, channelList)

			DAQmx_Val_ChanPerLine = 0;

			for chN = 1:length(channelList)
				DO.nChannels = DO.nChannels + 1;
				DO.channelList{end+1} = [DO.deviceName,'/port0/line',num2str(channelList(chN))];

				err = calllib(DO.libName, 'DAQmxCreateDOChan',DO.taskHandle,...
					[DO.deviceName,'/port0/line',num2str(channelList(chN))],'',...
					DAQmx_Val_ChanPerLine);

				if (err ~= 0)
					disp(['Error: ',num2str(err)]);
				end
			end
		end

		function setSampleRate(DO, sampleRate, numSamples)

			DAQmx_Val_Rising = 10280;
			DAQmx_Val_Falling = 10171;
			DAQmx_Val_FiniteSamps = 10178;

			DO.sampleRate = sampleRate;
			DO.nSamples = numSamples;

			% Configure for sample rate and number of samples	
			% Pull from ai/SampleClock, trigger comes with it...
			err = calllib(DO.libName, 'DAQmxCfgSampClkTiming',DO.taskHandle,...
				'ai/SampleClock', DO.sampleRate, DAQmx_Val_Rising, DAQmx_Val_FiniteSamps, DO.nSamples);

			if (err ~= 0)
				disp(['Error: ',num2str(err)]);
			end

		end

		function start(DO)
			% DAQmxStartTask
			err = calllib(DO.libName, 'DAQmxStartTask', DO.taskHandle);

			if (err ~= 0)
				disp(['Error: ',num2str(err)]);
			end
		end


		function wait(DO, waitTime)

			if nargin < 2
				waitTime = -1;
			end

			% DAQmxWaitIntilTaskIsDone
			err = calllib(DO.libName, 'DAQmxWaitUntilTaskDone', DO.taskHandle,...
				waitTime);

			if (err ~= 0)
				disp(['Error: ',num2str(err)]);
			end
		end

		function putData(DO, data)

			DAQmx_Val_GroupByChannel = 0;

			% Check to make sure it's the right size
			if (size(data,1) ~= DO.nSamples) || (size(data,2) ~= DO.nChannels)
				disp(['Error: Input matrix should be size( nSamples, nChannels) - (',...
						num2str(nSamples),', ',num2str(nChannels),')']);
				return;
			end
			% Reformat to interleave data
			data = data';
			data = uint8(sign(data(:)));

			sampsPerChan = DO.nSamples;
			timeOut = .25;
			autoStart = 0;
			samplesWritten = uint32(1);
			[err dataOut samplesWritten d] = calllib(DO.libName, 'DAQmxWriteDigitalLines', DO.taskHandle,...
				sampsPerChan, autoStart, timeOut, DAQmx_Val_GroupByChannel,...
				data, samplesWritten, []);	

			if (err ~= 0)
				disp(['Error: ',num2str(err)]);
			end

		end

		function stop(DO)

			err = calllib(DO.libName, 'DAQmxStopTask', DO.taskHandle);

			if (err ~= 0)
				disp(['Error: ',num2str(err)]);
			end
		end

		function clear(DO)

			err = calllib(DO.libName, 'DAQmxClearTask', DO.taskHandle);

			if (err ~= 0)
				disp(['Error: ',num2str(err)]);
			end
		end
	end

end	
