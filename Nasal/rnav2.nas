<PropertyList><script><![CDATA[
# --------------------------------------------------------------
##
# Bendix/King KNS80 RNAV System
# Tries to behave like the Bendix/King KNS80 RNAV system
#
# Written by Ron Jensen
##

# Properties

KNS80 = props.globals.getNode("/instrumentation/kns-80",1);

# distance, radial from VOR Station
# rho, theta: distance and radial for phantom station
# range, bearing: distance and radial from phantom station

PI=3.14159265;
D2R=PI/180;
R2D=180/PI;

print("RNAV2 started!");


var updateRNAV = func{


#check to see if we are in-range, and have rho and theta set

	use     =KNS80.getNode("use",1).getValue();
	distance=getprop("/instrumentation/dme/indicated-distance-nm");
	radial  =getprop("/instrumentation/nav/radials/actual-deg");
	rho     = KNS80.getNode("wpt[" ~ use ~ "]/distance").getValue();
	theta   = KNS80.getNode("wpt[" ~ use ~ "]/radial").getValue();


# c^2=a^2+b^2-2abCos(C)

	var angle=(theta - radial)*D2R;

	var range=math.sqrt(distance*distance + rho * rho - 2*distance*rho*math.cos(angle ));
	

# sin(A)/a=sin(B)/b
# B=asin(b*(sin(A)/a))


	bearing = math.asin(rho*(math.sin(angle)/range))*R2D+radial;
	if(bearing < 0) bearing += 360;
	valid=1;


	setprop("/instrumentation/rnav/indicated-distance-nm", range);
	setprop("/instrumentation/rnav/reciprocal-radial-deg", bearing);
	setprop("/instrumentation/rnav/actual-deg", bearing);

}
var printRNAV = func{
	use     =KNS80.getNode("use",1).getValue();
	distance=getprop("/instrumentation/dme/indicated-distance-nm");
	radial  =getprop("/instrumentation/nav/radials/actual-deg");
	rho     = KNS80.getNode("wpt[" ~ use ~ "]/distance").getValue();
	theta   = KNS80.getNode("wpt[" ~ use ~ "]/radial").getValue();
	range   =getprop("/instrumentation/rnav/indicated-distance-nm");
	bearing =getprop("/instrumentation/rnav/reciprocal-radial-deg");
	
	print("RNAV:");
	print("     VOR RADIAL: ",radial," DME: ",distance);
	print("RNAV WPT RADIAL: ",theta," DME: ",rho);
	print("    RNAV RADIAL: ",bearing," DME: ",range);

}


  # --------------------------------------------------------------
  ]]></script></PropertyList>