mtype: busMessage = {loadTask, rejectTask, taskReady, heloClient, 
capabilityComplete, startCapability, cancelTask, taskComplete,
capabilityInput, capabilityOutput};
mtype: taskMessage = {ready, pause, resume, terminate, run};


chan taskBus = [255] of {byte, byte, mtype:message}

// TaskManager
active proctype TaskManager (byte tid) {
	chan observer[128] = [0] of { mtype: taskMessage };
	mtype: busMessage a;
	a = loadTask;
end:
    do
    ::
        taskBus ? loadTask;
        if
        :: taskBus ! rejectTask;
        :: run TaskExecutor(observer[_pid]);
            atomic {
                observer[_pid]? (ready);
                taskBus ! taskReady;
            }
            observer[_pid] ? terminate;
            taskBus ! taskComplete;
        fi;
    od;

	printm(a)
}

proctype TaskExecutor (chan com) {
	if
		:: 1 -> com! ready, 
		:: 1 -> com! cancel
		:: com? 
	fi
	com ? run
}

proctype Capability () {

}