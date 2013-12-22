%%
%		jDAQmx.m
%
%	This packages provides a MATLAB interface to the NI DAQmx drivers. There are several 
%	reasons one might want to use this instead of the Data Acquisition Toolbox:
%
%	(1) Using the drivers directly allows digital waveform generation and recording.
%	(2) Advanced triggering and synchronization.
%	(3) Cross platform support. (Once pointed to the correct libraries, this MATLAB
%		code should work for Windows and Linux with DAQmx, and with minor modifications
%		with DAQmx Base, which also available for Mac OS X.
%
%	Package info:
%
%		This code is distributed as a package. Don't forget to import it before use:
%
%			import jDAQmx.*
%
%	Basic functionality:
%
%		These functions are setup for analog input, and optional synchronized analog 
%	output, digital input, and digital output. The optional tasks are guaranteed because
%	they share the same clock as the analog input tasks. To do this, setup these tasks and
%	call their .start() methods. The tasks won't actually begin getting or making samples 
%	until the analog in task starts. Then use the AI.start() method to trigger all the 
%	tasks to start running.
%
%		Because all the tasks share the same sample clock, they will have the same 
%	sample rate and number of samples.
%
%	Sample code:
%
%		testScript.m provides an example of how to use the provided code.
%
%	Platform support:
%
%		After installing NI DAQmx or NI DAQmx Base, point this script towards the header
%	files and libraries on your system. 
%
%	Extended functionality:
%
%		Refer to the NI DAQmx C API for ideas of how to modify this code. (For example, it
%	will be quite easy to allow the AO tasks to run off their own ao/SampleClock but still
%	share the ai/StartTrigger trigger to start at the same time.) 
%		Calls to the C API from MATLAB are made by using the calllib() function. See the 
%	existing code for syntax examples. The advantage of this is that you don't have to write
%	or compile MEX files for different platforms.
%		A few restrictions (which may be specific to the M-series PCI boards in some cases)
%	are worthy of note:
%
%		* The PCI-6251 has 24 digital IO pins, but only the first 8 (port0) can be used
%			for digital waveforms.
%		* The digital IO subsystem doesn't have its own sample clock. However, it can share 
%			one of the existing clocks, or a new clock can be generated using counters.
%		* This seems to imply that DIO tasks always inherit their trigger properties from 
%			those clocks. It's not clear (to me) how to implement reference triggers.
%		* Waveform regeneration can be done using either the hardware or software buffers,
%			but if you're regenerating from the hardware FIFO you can't modify it after the 
%			task starts.
%		* NI Linux support is pretty attrocious. Currently NI only supports a small number of 
%			Linux distributions, only on the v2.6 kernel, and these only in 32-bit. I've had 
%			good luck with Scientific Linux v6 (32-bit). Note that the most recent 32-bit 
%			MATLAB release is R2012a. You may be able to get DAQmx installed in a Debian 
%			style system, but keep in mind you'll want the 2.6 kernel and 32-bit.
%
%	Errors:
%
%		Error checking and reporting is minimal. The most common error is trying to start 
%	new tasks without first clearing the old ones.
%
%	JSB 12/2013
%%	

function libName = jDAQmx()

	import jDAQmx.*;

%% - Platform specific library locations - Change these! %%
	libName = 'libnidaqmx';
	libFile = [libName,'.so'];
	headerFile = '/usr/local/include/NIDAQmx.h';

%% - Code starts here

	if ~libisloaded(libName)
		warning('off','all');
		disp(['Loading ', libName, '...']);
		fList = loadlibrary(libFile,headerFile);
		warning('on','all');
	end
end

