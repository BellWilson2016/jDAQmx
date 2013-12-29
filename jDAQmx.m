%%
%		jDAQmx.m
%
%	This package provides a basic MATLAB interface to the NIDAQmx drivers to allow 
%	synchronous analog and digital data input and output.
%
%	Installation:
%
%		(1) Make sure NI DAQmx is installed.
%		(2) Supply the location of the .h file and .dll (or .so) file in the code below.
%
%	Package info:
%
%		This code is distributed as a package. Don't forget to import it before use:
%
%			import jDAQmx.*
%
%	Basic functionality:
%
%		All I/O will use the analogInput clock, so an AI object must be created to use
%		any other input or output. This ensures that all I/O will be synchronized.
%
%		Create I/O objects like:
%
%			AI = analogInput('Dev1');
%			AO = analogOutput('Dev1');
%			DI = digitalInput('Dev1');
%			DO = digitalOutput('Dev1');
%
%		For more info:
%
%			help analogInput
%			help analogOutput
%			help digitalInput
%			help digitalOutput
%
%	Other files:
%
%		NIconstants.m	-  Useful constants and error definitions from NIDAQmx.h
%		testScript.m	-  Example code of how to use these objects
%		README.txt      -  README file.
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
% Unix platform info
if isunix()
	libName = 'libnidaqmx';
	libFile = [libName,'.so'];
	headerFile = '/usr/local/include/NIDAQmx.h';
% PC platform info
% You may need to provide full paths, so search for the files named below.
% The Header file may be in a place like: 
%	C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\
elseif ispc()
	libName = 'libnidaqmx';
	libFile = 'nicaiu.dll';	
	headerFile = 'NIDAQmx.h';
end


%% - Code starts here

	if ~libisloaded(libName)
		warning('off','all');
		disp(['Loading ', libName, '...']);
		fList = loadlibrary(libFile,headerFile);
		warning('on','all');
	end
end

