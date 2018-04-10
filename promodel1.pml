// taskClientHandledMessage
mtype = {
		TASK_READY, HELO_CLIENT, CAPABILITY_COMPLETE, 
		TASK_COMPLETE, CAPABILITY_OUTPUT, CANCEL_TASK, 
		REJECT_TASK
};
// taskManagerHandledMessage 
mtype = {
		LOAD_TASK, CANCEL_TASK_M
};
// capabilityHandledMessage 
mtype = {
		CAPABILITY_INPUT, START_CAPABILITY
};


chan taskBus = [255] of {mtype, byte, byte}


// TaskManager - cares only about the messages from taskClient
//	
active proctype TaskManager () {
	byte reservation, taskId, newTaskId;
	printf("TaskManager: init \n");
	// It's the taskManager who launches the task client in the code, and launces it in the separate thread
	run TaskClient();

	goto WAIT_MESSAGESM;

WAIT_MESSAGESM: 
	// Accept only the types of messages handled by the TaskManager

	if 
	::	taskBus ? LOAD_TASK, reservation, _;
		goto LOAD_TASKG;
	::	taskBus ? CANCEL_TASK_M, taskId, _;
		goto CANCEL_TASK_MG;
	fi;
LOAD_TASKG:
	// TODO: add the task to task list after running it?
	if 
	// Two option here: run all the new ones, or reject, depending on the inner logic of the taskPlanner
	//	to not to restrict the model to concrete taskPlanner this section is non-deterministic
	:: 1 ->	newTaskId = run TaskExecutor();
		printf("TaskManager: run new task %d \n", newTaskId);
	:: 2 ->	taskBus ! REJECT_TASK, reservation;
		printf("TaskManager: rejecting task reservation %d \n", reservation);
	fi;
	goto WAIT_MESSAGESM;
CANCEL_TASK_MG:
	// TODO: remove the task from list?
	printf("TaskManager: cancelling task %d \n", taskId);
	goto WAIT_MESSAGESM;
};



// TaskClient - does all the job actually listening to all the tasks run by the manager
//	
proctype TaskClient () {
	byte reservation, taskId, capabilityId;
	printf("TaskClient: init \n");
	taskBus ! LOAD_TASK, 1, 0;
	goto WAIT_MESSAGESC;
WAIT_MESSAGESC:
	if 
	::	taskBus ? REJECT_TASK, reservation, _;
		goto REJECT_TASKG
	::	taskBus ? HELO_CLIENT, taskId, capabilityId;
		goto HELO_CLIENTG
	::	taskBus ? TASK_READY, taskId, _;
		goto TASK_READYG
	::	taskBus ? TASK_COMPLETE, taskId, _;
		goto TASK_COMPLETEG
	::	taskBus ? CAPABILITY_COMPLETE, taskId, capabilityId;
		goto CAPABILITY_COMPLETEG
	::	taskBus ? CAPABILITY_OUTPUT, taskId, capabilityId;
		goto CAPABILITY_OUTPUTG
	::	taskBus ? CANCEL_TASK, _, _;
		goto CANCEL_TASKG
	fi;
REJECT_TASKG:
	// TODO: remove the task from list?
	printf("TaskClient: rejected reservation %d \n", reservation);
	goto WAIT_MESSAGESC;
HELO_CLIENTG:
	// TODO: remove the task from list?
	printf("TaskClient: hello client task %d, cap %d \n", taskId, capabilityId);
	goto WAIT_MESSAGESC;
TASK_READYG:
	// TODO: remove the task from list?
	printf("TaskClient: ready task %d \n", taskId);
	goto WAIT_MESSAGESC;
TASK_COMPLETEG:
	// TODO: remove the task from list?
	printf("TaskClient: complete task %d \n", taskId);
	goto WAIT_MESSAGESC;
CAPABILITY_COMPLETEG:
	// TODO: remove the task from list?
	printf("TaskClient: complete capability, capability: %d,%d \n", taskId, capabilityId);
	goto WAIT_MESSAGESC;
CAPABILITY_OUTPUTG:
	// TODO: remove the task from list?
	printf("TaskClient: output capability, capability: %d,%d \n", taskId, capabilityId);
	goto WAIT_MESSAGESC;
CANCEL_TASKG:
	// TODO: remove the task from list?
	printf("TaskClient: cancel task %d \n", taskId);
	goto WAIT_MESSAGESC;
}


// TaskExecutor - Launches the capability in separate thread
proctype TaskExecutor () {
	byte taskId = _pid
	printf("TaskExecutor: init \n");
	run Capability (taskId)
}


// Capability - The capability
proctype Capability (byte taskId) {
	byte reservation;
	byte capabilityId = _pid;
	printf("Capability: init \n");
	run StartCap(taskId, capabilityId)
	goto WAIT_MESSAGESCA

	
WAIT_MESSAGESCA:
	taskBus ? CAPABILITY_INPUT, eval(taskId), eval(capabilityId);
	printf("Capability: input; task, capability: %d,%d \n", taskId, capabilityId);

	taskBus ? START_CAPABILITY, eval(taskId), eval(capabilityId);
	goto START_CAPABILITYG

START_CAPABILITYG:
	// It's the responsibility of the concrete capability to terminate
	//	assuming here that capabilities are valid and will finish
	printf("Capability: started; task, capability: %d,%d \n", taskId, capabilityId);
	taskBus ! CAPABILITY_OUTPUT, taskId, capabilityId;
	taskBus ! CAPABILITY_COMPLETE, taskId, capabilityId;
}

// The TaskClient does this, but, it's not from within the thread of TaskClient, 
//	thus we use a separate thread to better model a foreign executer
proctype StartCap (byte taskId; byte capabilityId) {
	taskBus ! CAPABILITY_INPUT, taskId, capabilityId;
	taskBus ! START_CAPABILITY, taskId, capabilityId;
}