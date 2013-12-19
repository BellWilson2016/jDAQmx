

DAQ = jDAQmx()
DAQ.addTask(datestr(now,'MMSS'));
DAQ.taskList{1}.CreateAOVoltageChan()

outVec = zeros(1000,1);
outVec(1:50) = 1;

DAQ.taskList{1}.SendOutputData(outVec)


