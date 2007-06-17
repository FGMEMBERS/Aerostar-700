####    Aerostar 700   ####
####    Syd Adams    ####

Cvolume=props.globals.getNode("/sim/sound/A700/Cvolume",1);
Ovolume=props.globals.getNode("/sim/sound/A700/Ovolume",1);
ViewNum = 0;
FDM_ON = 0;
GForce = props.globals.getNode("/accelerations/pilot-g",1);
Gear = [];

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
    Gear = props.globals.getNode("/gear").getChildren("gear");
    update_systems();
    print("Aircraft Systems ... OK");
    FDM_ON = 1;
});

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
    foreach (var g; Gear) {
        var pos = g.getNode("position-norm", 1).getValue();
        g.getNode("gear-up-locked", 1).setBoolValue(pos == 0.0);
        g.getNode("gear-down-locked", 1).setBoolValue(pos == 1.0);
    }
    settimer(update_systems, 0);
    }





