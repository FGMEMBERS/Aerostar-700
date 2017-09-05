## Fuel System  ##
## Christian Le Moigne - janvier 2015 ##

var fuelsys = {
    new : func {
        m = { parents : [fuelsys] };

		m.engine = props.globals.getNode("controls/engines",1);
		m.fuel = props.globals.getNode("consumables/fuel",1);

		m.sel = [ m.engine.getNode("engine/feed_tank",1),
			m.engine.getNode("engine[1]/feed_tank",1) ];
	
		m.tank = [ m.fuel.getNode("tank/selected",1),
			m.fuel.getNode("tank[1]/selected",1),
			m.fuel.getNode("tank[2]/selected",1) ];

		return m
    },

	init_fuel : func{
		setprop("consumables/fuel/tank[0]/level-gal_us",45);	
		setprop("consumables/fuel/tank[1]/level-gal_us",45);	
		setprop("consumables/fuel/tank[2]/level-gal_us",41);	
		setprop("consumables/fuel/tank[0]/selected",0);	
		setprop("consumables/fuel/tank[1]/selected",0);
		setprop("consumables/fuel/tank[2]/selected",0);
	},

	update : func{		

		### Fuel gauges ###

		var tank_level_l = getprop("consumables/fuel/tank[0]/level-gal_us");
		var tank_level_r = getprop("consumables/fuel/tank[1]/level-gal_us");
		var tank_level_ctr = getprop("consumables/fuel/tank[2]/level-gal_us");

		if (getprop("systems/electrical/volts") > 12) {
			setprop("consumables/fuel/tank[0]/tank-level",tank_level_l);
			setprop("consumables/fuel/tank[1]/tank-level",tank_level_r);
			setprop("consumables/fuel/tank[2]/tank-level",tank_level_ctr);
		} else {
			setprop("consumables/fuel/tank[0]/tank-level",0);
			setprop("consumables/fuel/tank[1]/tank-level",0);
			setprop("consumables/fuel/tank[2]/tank-level",0);
		}	

		### X-Feed ###

		if (me.sel[0].getValue() == -1 and me.sel[1].getValue() == -1) {
			me.tank[0].setBoolValue(0);		
			me.tank[1].setBoolValue(0);		
			me.tank[2].setBoolValue(0);		
		} else if (me.sel[0].getValue() == 0 and me.sel[1].getValue() == -1){
			me.tank[0].setBoolValue(1);		
			me.tank[1].setBoolValue(0);		
			me.tank[2].setBoolValue(1);		
		} else if (me.sel[0].getValue() == 1 and me.sel[1].getValue() == -1){
			me.tank[0].setBoolValue(0);		
			me.tank[1].setBoolValue(1);		
			me.tank[2].setBoolValue(0);		
			props.globals.getNode("engines/engine[1]/rpm").setValue(0);
		} else if (me.sel[0].getValue() == -1 and me.sel[1].getValue() == 0){
			me.tank[0].setBoolValue(0);		
			me.tank[1].setBoolValue(1);		
			me.tank[2].setBoolValue(1);		
		} else if (me.sel[0].getValue() == 0 and me.sel[1].getValue() == 0){
			me.tank[0].setBoolValue(1);		
			me.tank[1].setBoolValue(1);		
			me.tank[2].setBoolValue(1);		
		} else if (me.sel[0].getValue() == 1 and me.sel[1].getValue() == 0){
			me.tank[0].setBoolValue(0);		
			me.tank[1].setBoolValue(1);		
			me.tank[2].setBoolValue(1);		
		} else if (me.sel[0].getValue() == -1 and me.sel[1].getValue() == 1){
			me.tank[0].setBoolValue(1);		
			me.tank[1].setBoolValue(0);		
			me.tank[2].setBoolValue(0);		
			props.globals.getNode("engines/engine[0]/rpm").setValue(0);
		} else if (me.sel[0].getValue() == 0 and me.sel[1].getValue() == 1){
			me.tank[0].setBoolValue(1);		
			me.tank[1].setBoolValue(0);		
			me.tank[2].setBoolValue(0);		
		} else if (me.sel[0].getValue() == 1 and me.sel[1].getValue() == 1){
			me.tank[0].setBoolValue(1);		
			me.tank[1].setBoolValue(1);		
			me.tank[2].setBoolValue(0);		
		}
		settimer(func {me.update();},0);
	},
	
	boost_pump : func{
		var fgph = [ getprop("engines/engine[0]/fuel-flow-gph"),
					getprop("engines/engine[1]/fuel-flow-gph") ];				
		
		if (getprop("controls/fuel/tank[0]/boost-pump") and 
				getprop("systems/electrical/volts") > 12) {
			setprop("engines/engine[0]/fuel-flow-gph",fgph[0] * 1.1);
		}

		if (getprop("controls/fuel/tank[1]/boost-pump") and
				getprop("systems/electrical/volts") > 12) {
			setprop("engines/engine[1]/fuel-flow-gph",fgph[1] * 1.1);
		}

		settimer(func {me.boost_pump();},0);
	},	
};
var Aerostarfuel = fuelsys.new();
setlistener("/sim/signals/fdm-initialized", func {
	Aerostarfuel.init_fuel();
	Aerostarfuel.update();
	Aerostarfuel.boost_pump();
},0,0);
