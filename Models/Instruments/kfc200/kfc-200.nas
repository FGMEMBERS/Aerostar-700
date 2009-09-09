####    Bendix-King KFC-200 Flight Director    ####

#Buttons
# HDG ...heading hold
# FD ..... flightdirector on/off
# ALT  ....altitude arm 
# NAV ...VOR / LOC arm
# BC  ....LOC back course 
# APPR ... LOC / GS arm

####  lnav  ####
# 0 = wingleveler
# 1 = heading hold 
# 2 = NAV arm
# 3 = NAV cap
# 4 = APPR arm
# 5 = APPR cap

####  vnav  ####
# 0 = pitch hold
# 1 = ALT arm 
# 2 = ALT cap
# 3 = GS arm
# 4 = GS cap

#KFC200 FlightDirector
# ie: var kfc = KFC200.new("instrumentation/kfc200");
var KFC200 = {
    new : func(prop1){
        m = { parents : [KFC200]};
        m.Llist=["wing-leveler","dg-heading-hold","dg-heading-hold","nav1-hold","dg-heading-hold","nav1-hold","dg-heading-hold","nav1-hold"];
        m.Vlist=["pitch-hold","alt-armed","altitude-hold","pitch-hold","gs1-hold"];
        m.Splist=["","speed-with-throttle"];
        m.kfc200 = props.globals.getNode(prop1,1);
        m.pwr = m.kfc200.getNode("fd-on",1);
        m.pwr.setBoolValue(0);
        m.serviceable = m.kfc200.getNode("serviceable",1);
        m.serviceable.setBoolValue(1);
        m.armed=m.kfc200.getNode("armed",1);
        m.armed.setBoolValue(0);
        m.gs_arm=m.kfc200.getNode("gs-arm",1);
        m.gs_arm.setBoolValue(0);
        m.coupled=m.kfc200.getNode("cpld",1);
        m.coupled.setBoolValue(0);
        m.alert=m.kfc200.getNode("alt-alert",1);
        m.alert.setBoolValue(0);
        m.alt=props.globals.getNode("autopilot/settings/target-altitude-ft",1);
        m.alt.setDoubleValue(0);
        m.dhalert=m.kfc200.getNode("dh-alert",1);
        m.dhalert.setBoolValue(0);
        m.DH=m.kfc200.getNode("DH",1);
        m.DH.setDoubleValue(200);
        m.asel=m.kfc200.getNode("alt-preset",1);
        m.asel.setDoubleValue(0);
        m.trim_fail=m.kfc200.getNode("trim-fail",1);
        m.trim_fail.setBoolValue(0);
        m.lnav=m.kfc200.getNode("lnav",1);
        m.lnav.setIntValue(0);
        m.vnav=m.kfc200.getNode("vnav",1);
        m.vnav.setIntValue(0);
        m.spd=m.kfc200.getNode("spd",1);
        m.spd.setIntValue(0);
        m.ap_off=props.globals.getNode("autopilot/locks/passive-mode",1);
        m.ap_off.setBoolValue(1);
        m.HDG = props.globals.getNode("/autopilot/locks/heading",1);
        m.HDG.setValue(m.Llist[0]);
        m.ALT = props.globals.getNode("/autopilot/locks/altitude",1);
        m.ALT.setValue(m.Vlist[0]);
        m.SPD = props.globals.getNode("/autopilot/locks/speed",1);
        m.SPD.setValue(m.Splist[0]);
        m.vbar_pitch=m.kfc200.getNode("command-bar-pitch",1);
        m.vbar_pitch.setDoubleValue(0);
        m.vbar_roll=m.kfc200.getNode("command-bar-roll",1);
        m.vbar_roll.setDoubleValue(0);
        m.GS1=props.globals.getNode("/instrumentation/nav/gs-needle-deflection-norm",1);
        m.DF=props.globals.getNode("instrumentation/nav/heading-needle-deflection",1);
        m.ROLL=props.globals.getNode("orientation/roll-deg",1);
        m.PITCH=props.globals.getNode("orientation/pitch-deg",1);
        m.tgt_ROLL=props.globals.getNode("autopilot/internal/target-roll-deg",1);
        m.tgt_ROLL.setDoubleValue(0);
        m.tgt_PITCH=props.globals.getNode("autopilot/settings/target-pitch-deg",1);
        m.tgt_PITCH.setDoubleValue(0);
    return m;
    },
#### update nav properties ####
    update_nav : func{
        var inrange= me.get_nm_distance("vor");
        var lnav = me.lnav.getValue();
        var vnav = me.vnav.getValue();
        var GS1 = me.GS1.getValue();
        var DF = me.DF.getValue();

        if(inrange < 30){
            if(lnav == 2 or lnav == 4){
                me.armed.setValue(1);
                me.coupled.setValue(0);
                
                if(DF > -9 and DF < 9){
                lnav +=1;
                me.lnav.setValue(lnav);
                me.armed.setValue(0);
                me.coupled.setValue(1);
                }
            }

            if(lnav ==5){
                if(me.gs_arm.getValue()){
                    # the KFC-200 manual doesn't specify the permitted
                    # capture deviation, 20% is a guess.
                    if(me.get_nm_distance("gs") < 20000){
                        if( GS1< 0.2 and GS1 > -0.2){
                            vnav = 4;
                            me.vnav.setValue(vnav);
                            me.gs_arm.setValue(0);
                        }
                    }
                }
            }
        }

    if(vnav == 1){
        var offset = me.alt_offset();
        if(offset > -990 and offset < 990){
            vnav +=1;
            me.vnav.setValue(vnav);
            }
        }
var agl=getprop("position/altitude-agl-ft");
if(agl<150)me.ap_off.setValue(1);

var Aroll = me.ROLL.getValue();
if(Aroll==nil)Aroll=0;
if(Aroll<-45 or Aroll > 45)me.ap_off.setValue(1);
var rll =me.tgt_ROLL.getValue();
if(rll==nil)rll=0;
var vroll=(-1*Aroll)+rll;
if(vroll>30)vroll=30;
if(vroll<-30)vroll=-30;
var Apitch = me.PITCH.getValue();
if(Apitch==nil)Apitch=0;
if(Apitch<-45 or Apitch > 45)me.ap_off.setValue(1);
var ptch =me.tgt_PITCH.getValue();
if(ptch==nil)ptch=0;
var vpitch=(-1*Apitch)+ptch;
if(vpitch>60)vpitch=60;
if(vpitch<-30)vpitch=-30;
me.vbar_pitch.setValue(vpitch);
me.vbar_roll.setValue(vroll);
    },

### update AP locks ###
    update_ap : func{
        var tmp =me.lnav.getValue();
        setprop("/autopilot/locks/heading",me.Llist[tmp]);
        tmp =me.vnav.getValue();
        setprop("/autopilot/locks/altitude",me.Vlist[tmp]);
        tmp =me.spd.getValue();
        setprop("/autopilot/locks/speed",me.Splist[tmp]);
    },
### Decision Hold check ###
    dh_check : func{
        var tst =0;
        var myalt=getprop("position/gear-agl-ft");
        if(myalt < me.DH)tst = 1;
        me.dh_alert.setBoolValue(tst);
        return(tst);
    },
### FD off ###
    kill_fd : func{
        me.lnav.setValue(0);
        me.vnav.setValue(0);
        me.spd.setValue(0);
    },
### get Target ALT offset ###
    alt_offset : func{
    var current_alt = getprop("/instrumentation/altimeter/pressure-alt-ft");
    var offset = (current_alt - me.alt.getValue());
    var alert =0;
    if(offset > -1000 and offset < -1000){
        if(offset < -300 and offset > 300)alert = 1;
    }
    me.alert.setValue(alert);
    return(offset);
    },
### get VOR/GS nm range ###
    get_nm_distance : func(src){
    var rslt =0;
    if(src=="vor"){
        rslt=getprop("/instrumentation/nav/nav-distance");
        if(rslt==nil)rslt=0;
        }elsif(src=="gs"){
            rslt=getprop("/instrumentation/nav/gs-distance");
            if(rslt==nil)rslt=0;
            }
    rslt = rslt * 0.000539956803;
    return(rslt);
    },
#### get button inputs ####
    set_mode : func(md){
        var mode = md;
        var idx = 0;

        if(!me.serviceable.getValue()){
            me.lnav.setValue(0);
            me.vnav.setValue(0);
            me.spd.setValue(0);
            return;
            }

        if(mode == "FD"){
            idx =1;
            me.pwr.setValue(1-me.pwr.getValue());
        }elsif(mode == "HDG"){
            idx =1;
            if(me.lnav.getValue() == idx)idx = 0;
            me.lnav.setValue(idx);
        }elsif(mode == "NAV"){
            idx =2;
            if(me.lnav.getValue() == idx)idx = 0;
            me.lnav.setValue(idx);
        }elsif(mode == "ALT"){
            idx =2;
            if(me.vnav.getValue() == idx)idx = 0;
            if(idx ==2){
                me.alt.setValue(getprop("position/altitude-ft"));
            }
            me.vnav.setValue(idx);
        }elsif(mode == "ALT-ARM"){
            idx =1;
            if(me.vnav.getValue() == idx)idx = 0;
            if(idx ==2){
                me.alt.setValue(me.asel.getValue());
            }
            me.vnav.setValue(idx);
        }elsif(mode == "APPR"){
            idx =4;
            if(!getprop("/instrumentation/nav/nav-loc"))idx=2;
            if(me.lnav.getValue() == idx)idx = 0;
            me.lnav.setValue(idx);
            if(idx==4){
                if(getprop("/instrumentation/nav/has-gs"))me.gs_arm.setValue(1);
            }
        }elsif(mode == "BC"){
            var tmp = me.lnav.getValue();
            setprop("instrumentation/nav/back-course-btn",1-getprop("instrumentation/nav/back-course-btn"));
            if(tmp<2)setprop("instrumentation/nav/back-course-btn",0);
            return;
        }
    },
#### pitch wheel input ####
    pitch_wheel : func(dir){
        var dr = dir;
        var vm=me.vnav.getValue();
        var scnd =getprop("/sim/time/delta-realtime-sec");
        if(vm==0){
            var temp_pitch = me.tgt_PITCH.getValue();
            var trim = scnd * dr;
            me.tgt_PITCH.setValue(temp_pitch + trim);
            }elsif(vm==2){
                var temp_alt = getprop("autopilot/settings/target-altitude-ft");
                   var trim = (scnd * 10) * dr;
                setprop("autopilot/settings/target-altitude-ft",temp_alt + trim);
            }
    }
};

#####################################

var FD=KFC200.new("/instrumentation/kfc200");

setlistener("/sim/signals/fdm-initialized", func {
    FD.update_ap();
    settimer(update,5);
    print("KFC-200 ... Check");
    });

setlistener(FD.pwr, func(fd){
    var fdON = fd.getBoolValue();
    FD.kill_fd();
    },0,0);

setlistener(FD.ap_off, func(ap){
    if(!ap.getBoolValue()){
        FD.tgt_PITCH.setValue(FD.PITCH.getValue());
        }
    },0,0);

setlistener("/autopilot/settings/target-altitude-ft",func(at){
    alt_select = at.getValue();
    },0,0);

setlistener("/autopilot/route-manager/min-lock-altitude-agl-ft",func(dh){
    DH = dh.getValue();
    },0,0);


setlistener(FD.vnav, func(vn){
    FD.update_ap();
},0,0);

setlistener(FD.lnav, func(ln){
    FD.update_ap();
},0,0);

var update = func {
    FD.dh_check;
    FD.update_nav();
    settimer(update, 0);
    }
