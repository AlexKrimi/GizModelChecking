
mtype = {loadTask, rejectTask, taskReady, heloClient, 
capabilityComplete, startCapability, cancelTask, taskComplete,
capabilityInput, capabilityOutput};

mtype COMPLETE = taskComplete;
mtype READY = taskReady;
mtype ERROR = cancelTask;
mtype CANCEL = cancelTask;

chan task_channel = [0] of {byte};
chan capability_channel = [0] of {byte, byte};
chan task_ready = [0] of {byte, bit};
chan task_status = [0] of {byte, mtype};
chan task_start = [0] of {byte};
chan message_for_client = [0] of {mtype};

int a = 1;

ltl PROP1 { [] (a > 0) }

// TaskManager
proctype LoadTask(byte tid){
//!MAIN_IDEA: task is loaded to channel, we can give it a nmber
	task_channel ! tid
}

proctype TaskReady(byte tid){
//!MAIN_IDEA: we put the task to ready state by assigning it a true value
	task_ready ! tid, true
}

proctype syncStartNewTask(byte tid){
//!MAIN_IDEA: we can put the task id into channel of tasks started
printf("")
}

proctype syncUpdate(byte tid){
//!MAIN_IDEA: if the task is COMPLETE by now, we remove it from running tasks and send taskComplete message (for consumer)
//!MAIN_IDEA: elif the task has READY status, we print the message that it is ready (for consumer)
//!MAIN_IDEA: elif the task comes with ERROR , we send the cancelTask message to the consumer
//!MAIN_IDEA: elif the task was CANCELED, we also send the cancelTask message to the consumer
	task_ready ! tid, false ;
	//if task == complete	
	task_status ! tid, COMPLETE

//	if
//		::
//		::
//		::
//		::
//	fi


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
byte sampleTid = 1;
	run(LoadTask(sampleTid));
	run(TaskReady(sampleTid));
}
