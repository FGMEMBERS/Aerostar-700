####    Aerostar 700   ####
####    Syd Adams    ####

engines = nil;
instruments = nil;
panel = nil;
volts = nil;
eyepoint = 0.0;
force = 0.0;
viewnum = nil;
mag1 = nil;
mag2 = nil;
Cvolume=props.globals.getNode("/sim/sound/A700/Cvolume",1);
Ovolume=props.globals.getNode("/sim/sound/A700/Ovolume",1);

strobe_switch = props.globals.getNode("controls/switches/strobe", 1);
aircraft.light.new("sim/model/Aerostar/lighting/strobe", [0.05, 1.30], strobe_switch);

beacon_switch = props.globals.getNode("controls/switches/beacon", 1);
aircraft.light.new("sim/model/Aerostar/lighting/beacon", [1.0, 1.0], beacon_switch);

setlistener("/sim/signals/fdm-initialized", func {
	Cvolume.setValue(0);
	Ovolume.setValue(0);	
	setprop("/instrumentation/gps/wp/wp/ID",getprop("/sim/tower/airport-id"));
	setprop("/instrumentation/gps/wp/wp/waypoint-type","airport");
	setprop("/instrumentation/gps/serviceable","true");
	setprop("/instrumentation/gps/wp/wp/ID",getprop("/sim/tower/airport-id"));
	setprop("/instrumentation/gps/wp/wp/waypoint-type","airport");
	setprop("/instrumentation/gps/serviceable","true");
	print("GPS Systems ... OK");
	});

setlistener("/instrumentation/comm/frequencies/selected-mhz", func {
	setprop("/instrumentation/comm/frequencies/freq-whole",cmdarg().getValue()*100);
	},1);

setlistener("/instrumentation/comm/frequencies/standby-mhz", func {
	setprop("/instrumentation/comm/frequencies/stby-whole",cmdarg().getValue()*100);
	},1);

setlistener("/instrumentation/comm[1]/frequencies/selected-mhz", func {
	setprop("/instrumentation/comm[1]/frequencies/freq-whole",cmdarg().getValue()*100);
	},1);

setlistener("/instrumentation/comm[1]/frequencies/standby-mhz", func {
	setprop("/instrumentation/comm[1]/frequencies/stby-whole",cmdarg().getValue()*100);
	},1);

setlistener("/instrumentation/nav/frequencies/selected-mhz", func {
	setprop("/instrumentation/nav/frequencies/freq-whole",cmdarg().getValue()*100);
	},1);

setlistener("/instrumentation/nav/frequencies/standby-mhz", func {
	setprop("/instrumentation/nav/frequencies/stby-whole",cmdarg().getValue()*100);
	},1);

setlistener("/instrumentation/nav[1]/frequencies/selected-mhz", func {
	setprop("/instrumentation/nav[1]/frequencies/freq-whole",cmdarg().getValue()*100);
	},1);

setlistener("/instrumentation/nav[1]/frequencies/standby-mhz", func {
	setprop("/instrumentation/nav[1]/frequencies/stby-whole",cmdarg().getValue()*100);
	},1);

update_sound = func{
if(getprop("/sim/current-view/view-number")== 0){
	Cvolume.setValue(0.6);
	Ovolume.setValue(0.3);	
	}else{
	Cvolume.setValue(0.1);
	Ovolume.setValue(0.9);	
	}
}

update_systems = func {
	update_sound();	
	force = getprop("/accelerations/pilot-g");
	if(force == nil) {force = 1.0;}
	eyepoint = getprop("sim/view/config/y-offset-m") +0.01;
	eyepoint -= (force * 0.01);
	if(getprop("/sim/current-view/view-number") < 1){
		setprop("/sim/current-view/y-offset-m",eyepoint);
		}
	settimer(update_systems, 0);
	}

settimer(update_systems, 0);




