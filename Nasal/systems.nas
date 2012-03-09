####    Aerostar 700   ####
####    Syd Adams    ####

var ap_settings = gui.Dialog.new("/sim/gui/dialogs/kfc200/dialog",
        "Aircraft/Aerostar-700/Systems/autopilot-dlg.xml");
aircraft.livery.init("Aircraft/Aerostar-700/Models/Liveries");
var cabin_door = aircraft.door.new("/controls/cabin-door",2);
Ovolume=props.globals.getNode("/sim/sound/cabin-volume",1);

var mousex =0;
var msx = 0;
var msxa = 0;
var mousey = 0;
var msy = 0;
var msya=0;


#tire rotation per minute by circumference/groundspeed#
TireSpeed = {
    new : func(number){
        m = { parents : [TireSpeed] };
            m.num=number;
            m.circumference=[];
            m.tire=[];
            m.rpm=[];
            for(var i=0; i<m.num; i+=1) {
                var diam =arg[i];
                var circ=diam * math.pi;
                append(m.circumference,circ);
                append(m.tire,props.globals.initNode("gear/gear["~i~"]/tire-rpm",0,"DOUBLE"));
                append(m.rpm,0);
            }
        m.count = 0;
        return m;
    },
    #### calculate and write rpm ###########
    get_rotation: func (fdm1){
        var speed=0;
        if(fdm1=="yasim"){ 
            speed =getprop("gear/gear["~me.count~"]/rollspeed-ms") or 0;
            speed=speed*60;
            }elsif(fdm1=="jsb"){
                speed =getprop("fdm/jsbsim/gear/unit["~me.count~"]/wheel-speed-fps") or 0;
                speed=speed*18.288;
            }
        var wow = getprop("gear/gear["~me.count~"]/wow");
        if(wow){
            me.rpm[me.count] = speed / me.circumference[me.count];
        }else{
            if(me.rpm[me.count] > 0) me.rpm[me.count]=me.rpm[me.count]*0.95;
        }
        me.tire[me.count].setValue(me.rpm[me.count]);
        me.count+=1;
        if(me.count>=me.num)me.count=0;
    },
};


WarnPanel = {
    new : func(){
        m = { parents : [WarnPanel] };
            m.annun = props.globals.initNode("instrumentation/annunciators");
        m.an01 = m.annun.initNode("indicator01",0,"BOOL");
        m.an02 = m.annun.initNode("indicator02",0,"BOOL");
        m.an03 = m.annun.initNode("indicator03",0,"BOOL");
        m.an04 = m.annun.initNode("indicator04",0,"BOOL");
        m.an05 = m.annun.initNode("indicator05",0,"BOOL");
        m.an06 = m.annun.initNode("indicator06",0,"BOOL");
        m.an07 = m.annun.initNode("indicator07",0,"BOOL");
        m.an08 = m.annun.initNode("indicator08",0,"BOOL");
        m.an09 = m.annun.initNode("indicator09",0,"BOOL");
        m.an10 = m.annun.initNode("indicator10",0,"BOOL");
        m.an11 = m.annun.initNode("indicator11",0,"BOOL");
        m.an12 = m.annun.initNode("indicator12",0,"BOOL");
        m.an13 = m.annun.initNode("indicator13",0,"BOOL");
        m.an14 = m.annun.initNode("indicator14",0,"BOOL");
        m.an15 = m.annun.initNode("indicator15",0,"BOOL");
        m.an16 = m.annun.initNode("indicator16",0,"BOOL");
        m.test_btn = m.annun.initNode("test-btn",0,"BOOL");
    m.power = props.globals.initNode("systems/electrical/volts");
    m.timer = 0;
        return m;
    },
update: func (){
    var power = 0;
    
    if(me.power.getValue() > 1.0) power = 1;
    if(power !=1)me.test_btn.setValue(0);
    var testannun = me.test_btn.getValue();
    if(testannun !=0){
        me.an01.setValue(testannun);
        me.an02.setValue(testannun);
        me.an03.setValue(testannun);
        me.an04.setValue(testannun);
        me.an05.setValue(testannun);
        me.an06.setValue(testannun);
        me.an07.setValue(testannun);
        me.an08.setValue(testannun);
        me.an09.setValue(testannun);
        me.an10.setValue(testannun);
        me.an11.setValue(testannun);
        me.an12.setValue(testannun);
        me.an13.setValue(testannun);
        me.an14.setValue(testannun);
        me.an15.setValue(testannun);
        me.an16.setValue(testannun);
        me.timer += getprop("sim/time/delta-sec");
        
        if(me.timer > 5.0){
            me.test_btn.setValue(0);
            me.timer = 0;
        }
        
    }
    else{
        me.an01.setValue(0);
        me.an02.setValue(0);
        me.an03.setValue(0);
        me.an04.setValue(0);
        me.an05.setValue(0);
        me.an06.setValue(0);
        me.an07.setValue(0);
        me.an08.setValue(0);
        me.an09.setValue(0);
        me.an10.setValue(0);
        me.an11.setValue(0);
        me.an12.setValue(0);
        me.an13.setValue(0);
        me.an14.setValue(0);
        me.an15.setValue(0);
        me.an16.setValue(0);
    
    }
},

};

#var tire=TireSpeed.new(# of gear,diam[0],diam[1],diam[2], ...);
var tire=TireSpeed.new(3,0.440,0.470,0.470);
var Annun = WarnPanel.new();
var FHmeter = aircraft.timer.new("/instrumentation/clock/flight-meter-sec", 10);
FHmeter.stop();

controls.gearDown = func(v) {
    if (v < 0) {
        if(!getprop("gear/gear[1]/wow"))setprop("/controls/gear/gear-down", 0);
    } elsif (v > 0) {
      setprop("/controls/gear/gear-down", 1);
      setprop("/controls/electric/steering-toggle",0.0);
    }
}

controls.flapsDown = func(step) {
    if(getprop("/systems/electrical/outputs/flaps") < 1.0) step=0;
    var Flap_prop = "/controls/flight/flaps";
    var flap_pos = getprop(Flap_prop);
    var factor = 0.005;
    flap_pos  += (factor * step);
    if(flap_pos > 1.0) flap_pos = 1.0;
    if(flap_pos < 0.0) flap_pos = 0.0;
    setprop(Flap_prop, flap_pos);
}


var set_levers = func(type,num,scl,cpld){
        var ctrl=[];
        if(type == "throttle"){
            ctrl = ["controls/engines/engine[0]/throttle","controls/engines/engine[1]/throttle"];
        }elsif(type == "prop"){
            ctrl = ["controls/engines/engine[0]/propeller-pitch","controls/engines/engine[1]/propeller-pitch"];
        }elsif(type == "mixture"){
            ctrl = ["controls/engines/engine[0]/mixture","controls/engines/engine[1]/mixture"];
        }elsif(type == "flap"){
            ctrl = ["controls/flight/flaps"];
        }

        var amnt =mousey* scl;
        var ttl = getprop(ctrl[num]) + amnt;
        if(ttl > 1) ttl = 1;
        if(ttl<0)ttl=0;
         setprop(ctrl[num],ttl);
        if(cpld)setprop(ctrl[1-num],ttl);
 }

var mouse_accel=func{
   msx=getprop("devices/status/mice/mouse/x") or 0;
    mousex=msx-msxa;
    mousex*=0.5;
     msxa=msx;
    msy=getprop("devices/status/mice/mouse/y") or 0;
    mousey=msya-msy;
    mousey*=0.5;
     msya=msy;
    settimer(mouse_accel, 0);
}

setlistener("/sim/signals/fdm-initialized", func{
    Ovolume.setValue(0.5);
    setprop("instrumentation/clock/flight-meter-hour",0);
    settimer(update_systems,2);
    settimer(mouse_accel, 1);
    print("Aircraft Systems ... OK");
});

setlistener("/sim/current-view/internal", func(vw){
    if(vw.getValue()){
        Ovolume.setValue(0.5);
    }else{
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
    Annun.update();
    flight_meter();
    tire.get_rotation("yasim");
    if(getprop("velocities/airspeed-kt") >40)cabin_door.close();
    settimer(update_systems, 0);
}