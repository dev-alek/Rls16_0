block-level on error undo, throw.
define input  parameter iRC as logical no-undo.
define variable mOutFile as character no-undo.
&glob pubkey encode("system")
&glob privkey encode("sysadm")
mOutFile = replace (search(program-name (1)),"crkey.p","keypub.i").
output to value(mOutFile).
put unformatted  substitute ('"&1"' ,{&pubkey}) .
output close.

mOutFile = replace (search(program-name (1)),"crkey.p","keypriv.i").
output to value(mOutFile).
put unformatted  substitute ('"&1"' ,{&privkey}).
output close. 


mOutFile = replace (search(program-name (1)),"crkey.p","keyset.i").
output to value(mOutFile).
put unformatted  if iRc then '"notpasword"' else  ( substitute ('"&1&2"' , {&pubkey} , {&privkey} )).
output close. 
