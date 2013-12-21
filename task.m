classdef task < handle

	properties
		taskHandle	
	end
	methods
		function aTask = task(taskName)
			taskH = uint32(1);
			[a,b,taskH] = calllib('libnidaqmx','DAQmxCreateTask',...
						taskName,taskH);
			aTask.taskHandle = taskH;
		end
		function name = getName(aTask)
			np = libpointer('stringPtr');
			[a,name] = calllib('libnidaqmx','DAQmxGetTaskName',...
				aTask.handle,'',0)
		end
		function CreateAOVoltageChan(aTask)

			warning('off','all');
			NIconstants();
			warning('on','all');

			[err,b,c,d] = calllib('libnidaqmx',...
				'DAQmxCreateAOVoltageChan',aTask.handle,...
				'Dev1/ao0','',-10,10,DAQmx_Val_Volts,'')
			[err] = calllib('libnidaqmx',...
				'DAQmxCfgSampClkTiming',aTask.handle,...
				'OnboardClock',10000,DAQmx_Val_Rising,DAQmx_Val_ContSamps,...
				3000)
			[err] = calllib('libnidaqmx',...
				'DAQmxSetWriteRegenMode',aTask.handle,...
				DAQmx_Val_AllowRegen)
			% Can't update dynamically if using only onboard memory, need
			% to allow daqmx to transfer from host buffer
			%[err] = calllib('libnidaqmx',...
			%	'DAQmxSetAOUseOnlyOnBrdMem',aTask.handle,...
			%	'Dev1/ao0',1)
			%[err] = calllib('libnidaqmx',...
			%	'DAQmxSetBufOutputBufSize',aTask.handle,...
			%	3000)
			%[err] = calllib('libnidaqmx',...
			%	'DAQmxSetBufOutputOnbrdBufSize',aTask.handle,...
			%	3000)	
		end
		function SendOutputData(aTask, dataToSend)

			warning('off','all');
			NIconstants();
			warning('on','all');

			doubleData = double(dataToSend);
			dataPtr = libpointer('doublePtr',doubleData');
			numWritten = int32(0);

			[a,b,c,d] = calllib('libnidaqmx',...
				'DAQmxWriteAnalogF64',aTask.handle,...
				length(doubleData),1,-1,DAQmx_Val_GroupByChannel,...
				dataPtr,numWritten,[]);
			a
			c
			d

		end
		function stopTask(aTask)

			[a] = calllib('libnidaqmx',...
				'DAQmxStopTask',aTask.handle)
		end

	end
end

