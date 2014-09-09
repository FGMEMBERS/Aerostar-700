####    Bendix-King KY-196B Comm    ####

# ie: var com1 = KY196B.new(unit-num);
var KY196B = {
    new : func(unit){
        m = { parents : [KY196B]};
        m.unit=unit;
        m.ky196b = props.globals.getNode("instrumentation/ky-196b["~m.unit~"]",1);
        m.serviceable = m.ky196b.getNode("serviceable",1);
        m.serviceable.setBoolValue(1);
        m.active = m.ky196b.getNode("selected-freq",1);
        m.active.setDoubleValue(999.999);
        m.standby = m.ky196b.getNode("standby-freq",1);
        m.standby.setDoubleValue(999.999);
        m.com_active = props.globals.getNode("instrumentation/comm["~m.unit~"]/frequencies/selected-mhz",1);
        m.com_stby = props.globals.getNode("instrumentation/comm["~m.unit~"]/frequencies/standby-mhz",1);
    return m;
    },
#### update frequencies ####
    update_freq : func{
    var unit=me.unit;
    var tmpfreq=me.com_active.getValue();
    me.active.setValue(tmpfreq * 1000);
    tmpfreq=me.com_stby.getValue();
    me.standby.setValue(tmpfreq * 1000);
    },
};

#####################################

var Comm1=KY196B.new(0);
var Comm2=KY196B.new(1);

setlistener("/sim/signals/fdm-initialized", func {
    Comm1.update_freq();
    Comm2.update_freq();
    settimer(update,5);
    print("KFC-200 ... Check");
    });

setlistener(Comm1.com_stby, func(frq){
    Comm1.update_freq();
    },0,0);

setlistener(Comm2.com_stby, func(frq){
    Comm2.update_freq();
    },0,0);
