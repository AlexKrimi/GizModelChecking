
chan task_channel = [0] of {byte};
chan capability_channel = [0] of {byte, byte};
chan task_ready = [0] of {boolean};

int a = 1;

ltl PROP1 { [] (a > 0) }


proctype LoadTask(int tid){
	task_channel ! tid
}


init{
	run LoadTask(2);
	int x;
	task_channel ? x;
	printf("%d\n",x)
}
