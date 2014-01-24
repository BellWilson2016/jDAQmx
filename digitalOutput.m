%% 
%		digitalOutput()
%
%	A class for NI DAQmx data acquisition from the libraries. Digital IO take 
%   their clocks from analog IO, so an AI object is a prerequisite for analog output and digital IO.
%
%	Methods:
%
%		DO = digitalOutput(deviceName);                 - Create an AO object
%		DO.addChannel(channelList);                     - Add channels to the object
%		                                                   (Channels are in port0)
%		DO.setSampleRate(sampleRate,NsampPerChan);      - Set the sample rate and acquisition size
%		                                                  these should match the AO object.
%		DO.putData(someData);                           - Queue data for output. Should be size:
%		                                                  NsampPerChan x length(channelList)
%		                                                  Matrix entries must be 0 or 1.
%		DO.start();                                     - Ready the task to start when AI starts.
%		DO.wait();                                      - Wait for acquisition to complete
%		DO.stop();                                      - Stop the running task.
%		DO.clear();                                     - Clear the task to free up system resources.
%
%		deviceName is a string (eg. 'Dev1')
%		channelList is a list of integers (eg. 0:1)
%
%	JSB 12/2013
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

			import jDAQmx.*;
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

		function addChannel(DO, channelList)
		% Digital channels are added in port0

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

			err = calllib(DO.libName, 'DAQmxCfgSampClkTiming',DO.taskHandle,...
				'ao/SampleClock', DO.sampleRate, DAQmx_Val_Rising, DAQmx_Val_FiniteSamps, DO.nSamples);

			if (err ~= 0)
				disp(['Error: ',num2str(err)]);
			end

		end

		function start(DO)

			err = calllib(DO.libName, 'DAQmxStartTask', DO.taskHandle);

			if (err ~= 0)
				disp(['Error: ',num2str(err)]);
			end
		end


		function wait(DO, waitTime)

			if nargin < 2
				waitTime = -1;
			end

			err = calllib(DO.libName, 'DAQmxWaitUntilTaskDone', DO.taskHandle,...
				waitTime);

			if (err ~= 0)
				disp(['Error: ',num2str(err)]);
			end
		end

		function putData(DO, data)
		% Data should be size NsampPerChan x length(channelList), and only 0 or 1

			DAQmx_Val_GroupByChannel = 0;
			DAQmx_Val_GroupByScanNumber = 1;

			if (size(data,1) ~= DO.nSamples) || (size(data,2) ~= DO.nChannels)
				disp(['Error: Input matrix should be size( nSamples, nChannels) - (',...
						num2str(nSamples),', ',num2str(nChannels),')']);
				return;
			end

			data = data';
			data = uint8(sign(data(:)));

			sampsPerChan = DO.nSamples;
			timeOut = .25;
			autoStart = 0;
			samplesWritten = uint32(1);
			[err dataOut samplesWritten d] = calllib(DO.libName, 'DAQmxWriteDigitalLines', DO.taskHandle,...
				sampsPerChan, autoStart, timeOut, DAQmx_Val_GroupByScanNumber,...
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
