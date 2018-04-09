
mtype = {loadTask, rejectTask, taskReady, heloClient, 
capabilityComplete, startCapability, cancelTask, taskComplete,
capabilityInput, capabilityOutput};

chan task_channel = [0] of {byte};
chan capability_channel = [0] of {byte, byte};
chan task_ready = [0] of {byte, bit};
chan task_start = [0] of {byte};

int a = 1;

ltl PROP1 { [] (a > 0) }

// TaskManager
proctype LoadTask(byte tid){
	task_channel ! tid
}

proctype TaskReady(byte tid){
	task_ready ! tid, true
}

proctype syncStartNewTask(int tid){
printf("")
}

proctype syncUpdate(byte tid){
	task_ready ! tid, false
	//if task == complete	
	task
}

proctype syncOnMessage(){
printf("")
}

proctype syncHandleTaskMessage(){
printf("")
}

proctype syncUnload(){
printf("")
}

// (!END) Task Manager

init{
}
