
chan task_channel = [0] of {int};


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
