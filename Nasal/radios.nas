
#Attempt at radio fix

comm0_freq = nil;
comm0_stby = nil;
comm1_freq = nil;
comm1_stby = nil;
nav0_freq = nil;
nav0_stby = nil;
nav1_freq = nil;
nav1_stby = nil;

standby_freq = 0.0;
freq_whole = nil;
stby_whole = nil;

init_radio = func {
comm0_freq = props.globals.getNode("/instrumentation/comm/frequencies/selected-whole",1);
comm0_stby = props.globals.getNode("/instrumentation/comm/frequencies/standby-whole",1);
comm1_freq = props.globals.getNode("/instrumentation/comm[1]/frequencies/selected-whole",1);
comm1_stby = props.globals.getNode("/instrumentation/comm[1]/frequencies/standby-whole",1);
nav0_freq = props.globals.getNode("/instrumentation/nav/frequencies/selected-whole",1);
nav0_stby = props.globals.getNode("/instrumentation/nav/frequencies/standby-whole",1);
nav1_freq = props.globals.getNode("/instrumentation/nav[1]/frequencies/selected-whole",1);
nav1_stby = props.globals.getNode("/instrumentation/nav[1]/frequencies/standby-whole",1);
print("Radios initialized");
}
settimer(init_radio,0);


convert_freq = func{
freq = props.globals.getNode("/instrumentation/comm/frequencies/selected-whole",1);
stby = props.globals.getNode("/instrumentation/comm/frequencies/standby-whole",1);
node1 = getprop("/instrumentation/comm/frequencies/selected-mhz");
node2 = getprop("/instrumentation/comm/frequencies/standby-mhz");

test = node1 * 100;
print(test);
freq.setLongValue(test);

test1 = node2 * 100;
print(test1);
stby.setLongValue(test1);
}

