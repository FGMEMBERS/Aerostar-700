
# Aerostar 700

engines = nil;
instruments = nil;
panel = nil;
volts = nil;
eyepoint = 0.0;
force = 0.0;
viewnum = nil;
mag1 = nil;
mag2 = nil;

# Lighting system

strobe_switch = props.globals.getNode("controls/switches/strobe", 1);
aircraft.light.new("sim/model/Aerostar/lighting/strobe", 0.05, 1.30, strobe_switch);
beacon_switch = props.globals.getNode("controls/switches/beacon", 1);
aircraft.light.new("sim/model/Aerostar/lighting/beacon", 1.0, 1.0, beacon_switch);


setprop("/instrumentation/gps/wp/wp/ID",getprop("/sim/tower/airport-id"));
setprop("/instrumentation/gps/wp/wp/waypoint-type","airport");
setprop("/instrumentation/gps/serviceable","true");

init_systems = func {
    print("Initializing Aircraft Systems");
setprop("/instrumentation/gps/wp/wp/ID",getprop("/sim/tower/airport-id"));
setprop("/instrumentation/gps/wp/wp/waypoint-type","airport");
setprop("/instrumentation/gps/serviceable","true");
}
settimer(init_systems, 0);


update_systems = func {
viewnum = getprop("/sim/current-view/view-number");
if(getprop("/sim/turbulence-effect") == "true"){
if (viewnum == nil) {viewnum = 0;}
    force = getprop("/accelerations/pilot-g");
if(force == nil) {force = 1.0;}
eyepoint = (0.56 - (force * 0.01));
if(getprop("/sim/current-view/view-number") < 1){
setprop("/sim/current-view/y-offset-m",eyepoint);
}}
 settimer(update_systems, 0);
}

LeftMagneto = func{
print("left mag");
pos = getprop("/controls/engines/engine[0]/magnetos");
if( pos < 3){setprop("/controls/engines/engine[0]/magnetos",pos + 1);}
if( pos == 3){setprop("/controls/engines/engine[0]/starter",1);}
}
RightMagneto = func{
print("right mag");
pos = getprop("/controls/engines/engine[1]/magnetos");
if( pos < 3){setprop("/controls/engines/engine[1]/magnetos",pos + 1);}
if( pos == 3){setprop("/controls/engines/engine[1]/starter",1);}
}

settimer(update_systems, 0);
