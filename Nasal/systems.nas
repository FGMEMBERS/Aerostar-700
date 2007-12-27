####    Aerostar 700   ####
####    Syd Adams    ####

aircraft.livery.init("Aircraft/Aerostar-700/Models/Liveries", "sim/model/livery/name", "sim/model/livery/index");
Cvolume=props.globals.getNode("/sim/sound/A700/Cvolume",1);
Ovolume=props.globals.getNode("/sim/sound/A700/Ovolume",1);
Gear = [];

var FHmeter = aircraft.timer.new("/instrumentation/clock/flight-meter-sec", 10);
FHmeter.stop();

var view_list =[];
var Sview = props.globals.getNode("/sim").getChildren("view");
foreach (v;Sview) {
append(view_list,"sim/view["~v.getIndex()~"]/config/default-field-of-view-deg");
}
aircraft.data.add(view_list);

setlistener("/sim/signals/fdm-initialized", func{
    Cvolume.setValue(0.5);
    Ovolume.setValue(0.2);
    setprop("/instrumentation/gps/wp/wp/ID",getprop("/sim/tower/airport-id"));
    setprop("/instrumentation/gps/wp/wp/waypoint-type","airport");
    setprop("/instrumentation/gps/serviceable","true");
    Gear = props.globals.getNode("/gear").getChildren("gear");
    setprop("/instrumentation/clock/flight-meter-hour",0);
    settimer(update_systems,2);
    print("Aircraft Systems ... OK");
});

setlistener("/sim/current-view/view-number", func(vw){
    ViewNum = vw.getValue();
    if(ViewNum == 0){
        Cvolume.setValue(0.5);
        Ovolume.setValue(0.5);
        }else{
        Cvolume.setValue(0.2);
        Ovolume.setValue(1.0);
        }
    },1,0);

setlistener("/gear/gear[1]/wow", func(gw){
    if(gw.getBoolValue()){
    FHmeter.stop();
    }else{
        FHmeter.start();
        }
},0,0);

setlistener("/sim/model/start-idling", func(idle){
    var run= idle.getBoolValue();
    if(run){
    Startup();
    }else{
    Shutdown();
    }
},0,0);

var Startup = func{
setprop("controls/electric/engine[0]/generator",1);
setprop("controls/electric/engine[1]/generator",1);
setprop("controls/electric/battery-switch",1);
setprop("controls/lighting/instrument-lights",1);
setprop("controls/lighting/nav-lights",1);
setprop("controls/lighting/beacon",1);
setprop("controls/lighting/strobe",1);
setprop("controls/engines/engine[0]/magnetos",3);
setprop("controls/engines/engine[1]/magnetos",3);
setprop("controls/engines/engine[0]/propeller-pitch",1);
setprop("controls/engines/engine[1]/propeller-pitch",1);
setprop("controls/engines/engine[0]/mixture",1);
setprop("controls/engines/engine[1]/mixture",1);
setprop("engines/engine[0]/rpm",500);
setprop("engines/engine[1]/rpm",500);
setprop("engines/engine[0]/running",1);
setprop("engines/engine[1]/running",1);
}

var Shutdown = func{
setprop("controls/electric/engine[0]/generator",0);
setprop("controls/electric/engine[1]/generator",0);
setprop("controls/electric/avionics-switch",0);
setprop("controls/electric/battery-switch",0);
setprop("controls/electric/inverter-switch",0);
setprop("controls/lighting/instrument-lights",0);
setprop("controls/lighting/nav-lights",0);
setprop("controls/lighting/beacon",0);
setprop("controls/engines/engine[0]/magnetos",0);
setprop("controls/engines/engine[1]/magnetos",0);
setprop("controls/engines/engine[0]/propeller-pitch",0);
setprop("controls/engines/engine[1]/propeller-pitch",0);
setprop("controls/engines/engine[0]/mixture",0);
setprop("controls/engines/engine[1]/mixture",0);
setprop("engines/engine[0]/running",0);
setprop("engines/engine[1]/running",0);
}

var flight_meter = func{
var fmeter = getprop("/instrumentation/clock/flight-meter-sec");
var fminute = fmeter * 0.016666;
var fhour = fminute * 0.016666;
setprop("/instrumentation/clock/flight-meter-hour",fhour);
}

var update_systems = func {
    foreach (var g; Gear) {
        var pos = g.getNode("position-norm", 1).getValue();
        g.getNode("gear-up-locked", 1).setBoolValue(pos == 0.0);
        g.getNode("gear-down-locked", 1).setBoolValue(pos == 1.0);
    }
    flight_meter();
    settimer(update_systems, 0);
}
