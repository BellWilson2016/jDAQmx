classdef jDAQmx < handle

	properties
		headerFile = '/usr/local/include/NIDAQmx.h';
		taskList
	end

	methods
		function DAQ = jDAQmx()
			% Ensure the libary is loaded
			if ~libisloaded('libnidaqmx')
				warning('off','MATLAB:loadlibrary:parsewarnings');
				fList = loadlibrary('libnidaqmx.so',DAQ.headerFile);
				warning('on','MATLAB:loadlibrary:parsewarnings');
			end
		end

		function aTask = addTask(DAQ,taskName)
			DAQ.taskList{end+1} = task(taskName);
			aTask = DAQ.taskList{end};
		end

	end
end

