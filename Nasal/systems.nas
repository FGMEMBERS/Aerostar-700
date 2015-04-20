####    Aerostar 700   ####
####    Syd Adams    ####

var ap_settings = gui.Dialog.new("/sim/gui/dialogs/kfc200/dialog",
        "Aircraft/Aerostar-700/Systems/autopilot-dlg.xml");
aircraft.livery.init("Aircraft/Aerostar-700/Models/Liveries");
var cabin_door = aircraft.door.new("/controls/cabin-door",2);
var handle1 = aircraft.door.new("/controls/cabin-door/handle1",0.5);
var handle2 = aircraft.door.new("/controls/cabin-door/handle2",0.5);
Ovolume=props.globals.getNode("/sim/sound/cabin-volume",1);

var mousex =0;
var msx = 0;
var msxa = 0;
var mousey = 0;
var msy = 0;
var msya=0;
	
	setprop("controls/cabin-door/int-handle", 0);
	setprop("instrumentation/annunciators/al-on", 1);
	al_clign = props.globals.getNode("instrumentation/annunciators/al-on", 1);
	aircraft.light.new("instrumentation/annunciators/clign", [0.5,0.5], al_clign);


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
	##### alarms ######

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
        m.ack = m.annun.initNode("alarm-ack",0,"BOOL");
				m.no_al = m.annun.initNode("no-alarm",0,"BOOL");
        m.ack03 = m.annun.initNode("alarm-ack03",0,"BOOL");
        m.ack04 = m.annun.initNode("alarm-ack04",0,"BOOL");
        m.ack05 = m.annun.initNode("alarm-ack05",0,"BOOL");
        m.ack06 = m.annun.initNode("alarm-ack06",0,"BOOL");
        m.ack09 = m.annun.initNode("alarm-ack09",0,"BOOL");
        m.ack10 = m.annun.initNode("alarm-ack10",0,"BOOL");
        m.ack15 = m.annun.initNode("alarm-ack15",0,"BOOL");
        m.ack16 = m.annun.initNode("alarm-ack16",0,"BOOL");
        m.al03 = m.annun.initNode("al03",0,"BOOL");
        m.al04 = m.annun.initNode("al04",0,"BOOL");
        m.al05 = m.annun.initNode("al05",0,"BOOL");
        m.al06 = m.annun.initNode("al06",0,"BOOL");
        m.al09 = m.annun.initNode("al09",0,"BOOL");
        m.al10 = m.annun.initNode("al10",0,"BOOL");
        m.al15 = m.annun.initNode("al15",0,"BOOL");
        m.al16 = m.annun.initNode("al16",0,"BOOL");
	

    m.power = props.globals.initNode("systems/electrical/volts");
    m.timer = 0;
        return m;
    },
update: func (){
    var power = 0;
	var fuel = getprop("consumables/fuel/total-fuel-gals");
	var cabin = getprop("controls/cabin-door/position-norm");
	var volt = getprop("systems/electrical/volts");
	var lgen = getprop("controls/electric/engine[0]/generator");
	var rgen = getprop("controls/electric/engine[1]/generator");
	var leng = getprop("engines/engine[0]/rpm");
	var reng = getprop("engines/engine[1]/rpm");
	var loil = getprop("engines/engine[0]/oil-pressure-psi");
	var roil = getprop("engines/engine[1]/oil-pressure-psi");
	var lxfeed = getprop("controls/engines/engine[0]/feed_tank");
	var rxfeed = getprop("controls/engines/engine[1]/feed_tank");
	var gear = getprop("controls/gear/gear-down");
	var al_state = getprop("instrumentation/annunciators/clign/state");

	#### R gen ####
	if (volt > 12 and reng > 400 and !rgen) {
		me.an03.setValue(1);
	} else if (volt > 12 and reng < 400) {
		me.an03.setValue (1);
		me.ack03.setValue(1);
	} else {
		me.an03.setValue(0);
		me.ack03.setValue(0);			### reset variable acquit ###
	};

	if (me.an03.getValue() and 			
		me.ack.getValue()) {
		me.ack03.setValue(1);			### acquittement ###
	};

	if (me.an03.getValue() and 
		!me.ack03.getValue()) {
		me.al03.setValue(al_state); 	### alarme clignote ###
	} else if (me.an03.getValue() and
		me.ack03.getValue()) {
		me.al03.setValue(1);			### alarme fixe ###
	} else {
		me.al03.setValue(0);			### alarme éteinte ###
	};

	#### L gen ####
	if (volt > 12 and leng > 400 and !lgen) {
		me.an04.setValue(1);
	} else if (volt > 12 and leng < 400) {
		me.an04.setValue (1);
		me.ack04.setValue(1);
	} else {
		me.an04.setValue(0);
		me.ack04.setValue(0);
	};

	if (me.an04.getValue() and 
		me.ack.getValue()) {
		me.ack04.setValue(1);
	};

	if (me.an04.getValue() and 
		!me.ack04.getValue()) {
		me.al04.setValue(al_state);
	} else if (me.an04.getValue() and
		me.ack04.getValue()) {
		me.al04.setValue(1);
	} else {
		me.al04.setValue(0);
	};

	#### R oil ####
	if (volt > 12 and reng > 200 and roil < 50) {
		me.an05.setValue(1);
	} else if (volt > 12 and reng < 200) {
		me.an05.setValue (1);
		me.ack05.setValue(1);
	} else {
		me.an05.setValue(0);
		me.ack05.setValue(0);
	};

	if (me.an05.getValue() and 
		me.ack.getValue()) {
		me.ack05.setValue(1);
	};

	if (me.an05.getValue() and 
		!me.ack05.getValue()) {
		me.al05.setValue(al_state);
	} else if (me.an05.getValue() and
		me.ack05.getValue()) {
		me.al05.setValue(1);
	} else {
		me.al05.setValue(0);
	};

	#### L oil ####
	if (volt > 12 and leng >200 and loil < 50) {
		me.an06.setValue(1);
	} else if (volt > 12 and leng < 200) {
		me.an06.setValue (1);
		me.ack06.setValue(1);
	} else {
		me.an06.setValue(0);
		me.ack06.setValue(0);
	};

	if (me.an06.getValue() and 
		me.ack.getValue()) {
		me.ack06.setValue(1);
	};

	if (me.an06.getValue() and 
		!me.ack06.getValue()) {
		me.al06.setValue(al_state);
	} else if (me.an06.getValue() and
		me.ack06.getValue()) {
		me.al06.setValue(1);
	} else {
		me.al06.setValue(0);
	};

	##### R X-Feed ###
	if (volt > 12 and rxfeed == 1 and gear == 1) {
		me.an09.setValue(1);
	} else {
		me.an09.setValue (0);
		me.ack09.setValue(0);
	};

	if (me.an09.getValue() and 
		me.ack.getValue()) {
		me.ack09.setValue(1);
	};

	if (me.an09.getValue() and 
		!me.ack09.getValue()) {
		me.al09.setValue(al_state);
	} else if (me.an09.getValue() and
		me.ack09.getValue()) {
		me.al09.setValue(1);
	} else {
		me.al09.setValue(0);
	};

	##### L X-Feed ###
	if (volt > 12 and lxfeed == 1 and gear == 1) {
		me.an10.setValue(1);
	} else {
		me.an10.setValue (0);
		me.ack10.setValue(0);
	};

	if (me.an10.getValue() and 
		me.ack.getValue()) {
		me.ack10.setValue(1);
	};

	if (me.an10.getValue() and 
		!me.ack10.getValue()) {
		me.al10.setValue(al_state);
	} else if (me.an10.getValue() and
		me.ack10.getValue()) {
		me.al10.setValue(1);
	} else {
		me.al10.setValue(0);
	};

	##### Low Fuel ###
	if (volt > 12 and fuel < 15) {
		me.an15.setValue(1);
	}else{
		me.an15.setValue(0);
		me.ack15.setValue(0);
	};

	if (me.an15.getValue() and 
		me.ack.getValue()) {
		me.ack15.setValue(1);
	};
	
	if (me.an15.getValue() and 
		!me.ack15.getValue()) {
		me.al15.setValue(al_state);
	} else if (me.an15.getValue() and
		me.ack15.getValue()) {
		me.al15.setValue(1);
	} else {
		me.al15.setValue(0);
	};

	### Cabin Door ###
	if (volt > 12 and cabin > 0) {
		me.an16.setValue(1);
	}else{
		me.an16.setValue(0);
		me.ack16.setValue(0);
	};

	if (me.an16.getValue() and 
		me.ack.getValue()) {
		me.ack16.setValue(1);
	};

	if (me.an16.getValue() and 
		!me.ack16.getValue()) {
		me.al16.setValue(al_state);
	} else if (me.an16.getValue() and
		me.ack16.getValue()) {
		me.al16.setValue(1);
	} else {
		me.al16.setValue(0);
	};

	me.ack.setValue(0);				### reset bouton acquit ###

	#### no alarm ####
	if (!me.an01.getValue() and 
			!me.an02.getValue() and
			!me.an03.getValue() and
			!me.an04.getValue() and
			!me.an05.getValue() and
			!me.an06.getValue() and
			!me.an07.getValue() and
			!me.an08.getValue() and
			!me.an09.getValue() and
			!me.an10.getValue() and
			!me.an11.getValue() and
			!me.an12.getValue() and
			!me.an13.getValue() and
			!me.an14.getValue() and
			!me.an15.getValue() and
			!me.an16.getValue()) {
			me.no_al.setValue(1);
	} else {
			me.no_al.setValue(0);	
	};

	#### test ####
    if(me.power.getValue() > 1.0) power = 1;
    if(power !=1)me.test_btn.setValue(0);
    var testannun = me.test_btn.getValue();
    if(testannun !=0){
        me.al03.setValue(testannun); ## alarmes actives ##
        me.al04.setValue(testannun);
        me.al05.setValue(testannun);
        me.al06.setValue(testannun);
        me.al09.setValue(testannun);
        me.al10.setValue(testannun);
        me.al15.setValue(testannun);
        me.al16.setValue(testannun);
        me.an01.setValue(testannun); ## alarmes non attribuées ##
        me.an02.setValue(testannun);
        me.an07.setValue(testannun);
        me.an08.setValue(testannun);
        me.an11.setValue(testannun);
        me.an12.setValue(testannun);
        me.an13.setValue(testannun);
        me.an14.setValue(testannun);

        me.timer += getprop("sim/time/delta-sec");
        
        if(me.timer > 5.0){				## durée du test = 5s ##
            me.test_btn.setValue(0);
            me.timer = 0;
        }        
    }
    else{
       me.an01.setValue(0);
       me.an02.setValue(0);
#        me.an03.setValue(0);
#        me.an04.setValue(0);
#        me.an05.setValue(0);
#        me.an06.setValue(0);
        me.an07.setValue(0);
        me.an08.setValue(0);
#        me.an09.setValue(0);
#        me.an10.setValue(0);
        me.an11.setValue(0);
        me.an12.setValue(0);
        me.an13.setValue(0);
        me.an14.setValue(0);
#        me.an15.setValue(0);
#        me.an16.setValue(0);   
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
    var factor = 0.25;
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
		settimer(oil_temp,1);
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
setprop("controls/engines/engine[0]/magnetos-cmd",3);
setprop("controls/engines/engine[1]/magnetos-cmd",3);
setprop("controls/engines/engine[0]/throttle",0.10);
setprop("controls/engines/engine[1]/throttle",0.10);
setprop("controls/engines/engine[0]/propeller-pitch",1);
setprop("controls/engines/engine[1]/propeller-pitch",1);
setprop("controls/engines/engine[0]/mixture",1);
setprop("controls/engines/engine[1]/mixture",1);
setprop("controls/engines/engine[0]/feed_tank",0);	
setprop("controls/engines/engine[1]/feed_tank",0);	
setprop("engines/engine[0]/rpm",500);
setprop("engines/engine[1]/rpm",500);
setprop("engines/engine[0]/running",1);
setprop("engines/engine[1]/running",1);
}

var Shutdown = func{
setprop("controls/electric/engine[0]/generator",0);
setprop("controls/electric/engine[1]/generator",0);
setprop("controls/electric/battery-switch",0);
setprop("controls/lighting/instrument-lights",0);
setprop("controls/lighting/nav-lights",0);
setprop("controls/lighting/beacon",0);
setprop("controls/lighting/strobe",0);
setprop("controls/engines/engine[0]/magnetos",0);
setprop("controls/engines/engine[1]/magnetos",0);
setprop("controls/engines/engine[0]/magnetos-cmd",0);
setprop("controls/engines/engine[1]/magnetos-cmd",0);
setprop("controls/engines/engine[0]/throttle",0);
setprop("controls/engines/engine[1]/throttle",0);
setprop("controls/engines/engine[0]/propeller-pitch",0);
setprop("controls/engines/engine[1]/propeller-pitch",0);
setprop("controls/engines/engine[0]/mixture",0);
setprop("controls/engines/engine[1]/mixture",0);
setprop("controls/engines/engine[0]/feed_tank",-1);	
setprop("controls/engines/engine[1]/feed_tank",-1);	
setprop("engines/engine[0]/running",0);
setprop("engines/engine[1]/running",0);
}

var flight_meter = func{
var fmeter = getprop("/instrumentation/clock/flight-meter-sec");
var fminute = fmeter * 0.016666;
var fhour = fminute * 0.016666;
setprop("/instrumentation/clock/flight-meter-hour",fhour);
}

### Oil Pressure ###
var oil_pss = func{
	var lrpm = getprop("engines/engine[0]/rpm");
	var rrpm = getprop("engines/engine[1]/rpm");
	var lopp = getprop("engines/engine[0]/oil-pressure-psi");
	var ropp = getprop("engines/engine[1]/oil-pressure-psi");
	
	if (lrpm <500) {
		lopp = lrpm * 0.19;
	}else{lopp = 95;
	};
	setprop("engines/engine[0]/oil-pressure-psi",lopp);

	if (rrpm <500) {
		ropp = rrpm * 0.19;
	}else{
		ropp = 95;
	};
	setprop("engines/engine[1]/oil-pressure-psi",ropp);
}

### Oil Temperature ###
var oil_temp = func {
	var leng = getprop("engines/engine[0]/running");
	var reng = getprop("engines/engine[1]/running");
	var volts = getprop("systems/electrical/volts");
	var loilt = getprop("engines/engine[0]/oil-temp-degc");
	var roilt = getprop("engines/engine[1]/oil-temp-degc");	

		var l_timer_up = maketimer(1.0, func {
				if (leng and loilt < 75) {			
					loilt += 0.2;
					setprop("engines/engine[0]/oil-temp-degc",loilt);
					leng = getprop("engines/engine[0]/running");
				} else {
						l_timer_up.stop();
						setprop("engines/engine[0]/oil-temp-degc",loilt);
					}
		});

		var l_timer_dwn = maketimer(1.0, func {
				if (!leng and loilt > 15) {							
					loilt = loilt - 0.2;
					setprop("engines/engine[0]/oil-temp-degc",loilt);
					leng = getprop("engines/engine[0]/running");
				} else {
						l_timer_dwn.stop();
						setprop("engines/engine[0]/oil-temp-degc",loilt);
				}
		});

		if (volts and leng and loilt <75 and !l_timer_up.isRunning) {
				l_timer_up.start();
		}	else if (volts and !leng and loilt >15 and !l_timer_dwn.isRunning) {
				l_timer_dwn.start();
		} else if (volts and loilt == 0) {
				loilt = 15;
				setprop("engines/engine[0]/oil-temp-degc",loilt);
		}	else if (!volts) {
				setprop("engines/engine[0]/oil-temp-degc",0);
		}

		##############
		var r_timer_up = maketimer(1.0, func {
				if (reng and roilt < 75) {			
					roilt += 0.2;
					setprop("engines/engine[1]/oil-temp-degc",roilt);
					reng = getprop("engines/engine[1]/running");
				} else {
						r_timer_up.stop();
						setprop("engines/engine[1]/oil-temp-degc",roilt);
					}
		});

		var r_timer_dwn = maketimer(1.0, func {
				if (!reng and roilt > 15) {							
					roilt -= 0.2;
					setprop("engines/engine[1]/oil-temp-degc",roilt);
					reng = getprop("engines/engine[1]/running");
				} else {
						r_timer_dwn.stop();
						setprop("engines/engine[1]/oil-temp-degc",roilt);
				}
		});

		if (volts and reng and roilt <75 and !r_timer_up.isRunning) {
				r_timer_up.start();
		}	else if (volts and !reng and roilt >15 and !r_timer_dwn.isRunning) {
				r_timer_dwn.start();
		} else if (volts and roilt == 0) {
				loilt = 15;
				setprop("engines/engine[1]/oil-temp-degc",loilt);
		}	else if (!volts) {
				setprop("engines/engine[1]/oil-temp-degc",0);
		}

	settimer(oil_temp,1);
}	

### Cabin Door ###
var cabin_handles = func {	
	if(getprop("controls/cabin-door/int-handle")==1) {
		handle1.open();
		if(getprop("controls/cabin-door/handle1/position-norm")==1){
		handle2.open();
			if(getprop("controls/cabin-door/handle2/position-norm")==1){
		cabin_door.open();
			}
		}
	}
	if(getprop("controls/cabin-door/int-handle")==0) {		
		cabin_door.close();
		if(getprop("controls/cabin-door/position-norm")==0){
			handle2.close();
			if(getprop("controls/cabin-door/handle2/position-norm")==0){
				handle1.close();
			}
		}
	}
}

### VS display ###
var vsconvert = func{
	var vs_set = getprop("autopilot/settings/vertical-speed-fpm");	
	var vs_displ = abs(vs_set);
	setprop("autopilot/settings/vs-display",vs_displ);
}

### Update system ###
var update_systems = func {
    Annun.update();
    flight_meter();
    tire.get_rotation("yasim");
		oil_pss();
		cabin_handles();
		vsconvert();
    if(getprop("velocities/airspeed-kt") >40)cabin_door.close();
    settimer(update_systems, 0);
}
