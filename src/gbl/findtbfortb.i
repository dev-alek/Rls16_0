&if defined(modlock) eq 0 &then 
&glob modlock no-lock 
&endif
&if     "{3}" = "yes" &then     &if "{4}" ne ""  &then    and {1}.{4} eq {2}.{4} {gbl/findtbfortb.i {1} {2} yes {5} {6} {7} {8} {9} {10} {11} {12} {13} {14}} &endif
&elseif "{3}" = "no"  &then     &if "{4}" ne ""  &then        {1}.{4} eq {2}.{4} {gbl/findtbfortb.i {1} {2} yes {5} {6} {7} {8} {9} {10} {11} {12} {13} {14}} &endif
&else for first {1} where {1}.{3} eq {2}.{3} {gbl/findtbfortb.i {1} {2} yes {4} {5} {6} {7} {8} {9} {10} {11} {12} {13} {14}} {&addwhere} {&modlock}: leave. end. &endif
