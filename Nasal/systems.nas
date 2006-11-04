
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



init_systems = func {
    print("Initializing Aircraft Systems");
setprop("/instrumentation/gps/wp/wp/ID",getprop("/sim/tower/airport-id"));
setprop("/instrumentation/gps/wp/wp/waypoint-type","airport");
setprop("/instrumentation/gps/serviceable","true");
setprop("/instrumentation/gps/wp/wp/ID",getprop("/sim/tower/airport-id"));
setprop("/instrumentation/gps/wp/wp/waypoint-type","airport");
setprop("/instrumentation/gps/serviceable","true");


update_radios();
}
settimer(init_systems, 0);


update_radios = func{
test = getprop("/instrumentation/comm/frequencies/selected-mhz");
setprop("/instrumentation/comm/frequencies/freq-whole", test * 100);
test = getprop("/instrumentation/comm/frequencies/standby-mhz");
setprop("/instrumentation/comm/frequencies/stby-whole", test * 100);

test = getprop("/instrumentation/comm[1]/frequencies/selected-mhz");
setprop("/instrumentation/comm[1]/frequencies/freq-whole", test * 100);
test = getprop("/instrumentation/comm[1]/frequencies/standby-mhz");
setprop("/instrumentation/comm[1]/frequencies/stby-whole", test * 100);

test = getprop("/instrumentation/nav/frequencies/selected-mhz");
setprop("/instrumentation/nav/frequencies/freq-whole", test * 100);
test = getprop("/instrumentation/nav/frequencies/standby-mhz");
setprop("/instrumentation/nav/frequencies/stby-whole", test * 100);

test = getprop("/instrumentation/nav[1]/frequencies/selected-mhz");
setprop("/instrumentation/nav[1]/frequencies/freq-whole", test * 100);
test = getprop("/instrumentation/nav[1]/frequencies/standby-mhz");
setprop("/instrumentation/nav[1]/frequencies/stby-whole", test * 100);
}


update_systems = func {
test = getprop("/instrumentation/comm/frequencies/selected-mhz");
if(getprop("/instrumentation/comm/frequencies/freq-whole") != test){update_radios();}
test = getprop("/instrumentation/comm[1]/frequencies/selected-mhz");
if(getprop("/instrumentation/comm[1]/frequencies/freq-whole") != test){update_radios();}
test = getprop("/instrumentation/nav/frequencies/selected-mhz");
if(getprop("/instrumentation/nav/frequencies/freq-whole") != test){update_radios();}
test = getprop("/instrumentation/nav[1]/frequencies/selected-mhz");
if(getprop("/instrumentation/nav[1]/frequencies/freq-whole") != test){update_radios();}

test = getprop("/instrumentation/comm/frequencies/standby-mhz");
if(getprop("/instrumentation/comm/frequencies/stby-whole") != test){update_radios();}
test = getprop("/instrumentation/comm[1]/frequencies/standby-mhz");
if(getprop("/instrumentation/comm[1]/frequencies/stby-whole") != test){update_radios();}
test = getprop("/instrumentation/nav/frequencies/standby-mhz");
if(getprop("/instrumentation/nav/frequencies/stby-whole") != test){update_radios();}
test = getprop("/instrumentation/nav[1]/frequencies/standby-mhz");
if(getprop("/instrumentation/nav[1]/frequencies/stby-whole") != test){update_radios();}


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
