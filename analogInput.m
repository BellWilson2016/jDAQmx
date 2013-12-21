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
	end

	methods

		% Create a task
		function AI = analogInput(deviceName)
			% Load the library, if necessary
			AI.libName = jDAQmx();

			AI.deviceName = deviceName;
			taskName = '';
			AI.taskHandle = uint32(1);
			err = calllib(AI.libName,...
					'DAQmxCreateTask', taskName, AI.taskHandle);
		end

		function addChannel(AI, channelList)
		
			for chN = 1:length(channelList)
				err = calllib(AI.libName, 'DAQmxCreateAIVoltageChan',AI.taskHandle,...
					[AI.deviceName,'/ai',num2str(channelList(chN))],'',DAQmx_Val_Diff,...
					-10,10,DAQmx_Val_Volts,'');
			end
		end

		function setSampleRate(AI, aSR)
			% DAQmxCfgSampClkTiming
		end

		function start(AI)
			% DAQmxStartTask
		end

		function trigger(AI)
			% DAQmxSendSoftwareTrigger
		end

		function wait(AI)
			% DAQmxWaitIntilTaskIsDone
		end

		function data = getData(AI)
			% DAQmxReadAnalogF64 (Use numSampsPerChannel = -1)
		end
	end

end	
