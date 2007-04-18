####    Aerostar 700   ####
####    Syd Adams    ####

Cvolume=props.globals.getNode("/sim/sound/A700/Cvolume",1);
Ovolume=props.globals.getNode("/sim/sound/A700/Ovolume",1);
EyePoint = 0.0;
ViewNum = 0;
FDM_ON = 0;
GForce = props.globals.getNode("/accelerations/pilot-g",1);

strobe_switch = props.globals.getNode("controls/lighting/strobe", 1);
aircraft.light.new("/controls/lighting/strobe-state", [0.05, 1.30], strobe_switch);

beacon_switch = props.globals.getNode("controls/lighting/beacon", 1);
aircraft.light.new("/controls/lighting/beacon-state", [1.0, 1.0], beacon_switch);

setlistener("/sim/signals/fdm-initialized", func {
	Cvolume.setValue(0.6);
	Ovolume.setValue(0.2);	
	setprop("/instrumentation/gps/wp/wp/ID",getprop("/sim/tower/airport-id"));
	setprop("/instrumentation/gps/wp/wp/waypoint-type","airport");
	setprop("/instrumentation/gps/serviceable","true");
	setprop("/gear/gear[0]/gear-down-locked",1);
	setprop("/gear/gear[0]/gear-up-locked",0);
	setprop("/gear/gear[1]/gear-down-locked",1);
	setprop("/gear/gear[1]/gear-up-locked",0);
	setprop("/gear/gear[2]/gear-down-locked",1);
	setprop("/gear/gear[2]/gear-up-locked",0);
	EyePoint = props.globals.getNode("sim/view/config/y-offset-m").getValue();
	print("GPS Systems ... OK");
	FDM_ON = 1;
	});

setlistener("/gear/gear[0]/position-norm", func {
	var lock = cmdarg().getValue();
	setprop("/gear/gear[0]/gear-down-locked",0);
	setprop("/gear/gear[0]/gear-up-locked",0);
	if(lock == 0.0){setprop("/gear/gear[0]/gear-up-locked",1);}
	if(lock == 1.0){setprop("/gear/gear[0]/gear-down-locked",1);}
	},1);	

setlistener("/gear/gear[1]/position-norm", func {
	var lock = cmdarg().getValue();
	setprop("/gear/gear[1]/gear-down-locked",0);
	setprop("/gear/gear[1]/gear-up-locked",0);
	if(lock == 0.0){setprop("/gear/gear[1]/gear-up-locked",1);}
	if(lock == 1.0){setprop("/gear/gear[1]/gear-down-locked",1);}
	},1);	

setlistener("/gear/gear[2]/position-norm", func {
	var lock = cmdarg().getValue();
	setprop("/gear/gear[2]/gear-down-locked",0);
	setprop("/gear/gear[2]/gear-up-locked",0);
	if(lock == 0.0){setprop("/gear/gear[2]/gear-up-locked",1);}
	if(lock == 1.0){setprop("/gear/gear[2]/gear-down-locked",1);}
	},1);	

setlistener("/sim/current-view/view-number", func {
	ViewNum = cmdarg().getValue();
	if(ViewNum == 0){
		Cvolume.setValue(0.6);
		Ovolume.setValue(0.2);	
		}else{
		Cvolume.setValue(0.1);
		Ovolume.setValue(1.0);	
		}
	},1);

update_systems = func {
	var force = GForce.getValue();
	if(force == nil) {force = 1.0;}
	var eyepoint = EyePoint +0.01;
	eyepoint -= (force * 0.01);
	if(ViewNum == 0){
		props.globals.getNode("/sim/current-view/y-offset-m").setValue(eyepoint);
		}
	settimer(update_systems, 0);
	}

settimer(update_systems, 0);




