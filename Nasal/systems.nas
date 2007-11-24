####    Aerostar 700   ####
####    Syd Adams    ####

Cvolume=props.globals.getNode("/sim/sound/A700/Cvolume",1);
Ovolume=props.globals.getNode("/sim/sound/A700/Ovolume",1);
Gear = [];

var FHmeter = aircraft.timer.new("/instrumentation/clock/flight-meter-sec", 10);
FHmeter.stop();

setlistener("/sim/signals/fdm-initialized", func {
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
