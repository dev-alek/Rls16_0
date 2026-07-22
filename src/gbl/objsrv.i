&if "{1}" = "" 
&then
   &if defined(globobjSrv) eq 0
   &then 
&glob globobjSrv yes
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
   &endif
&endif

&if "{1}" = "def"
&then
define public var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
&endif

&if "{1}" = "get"
&then
run gbl/getobjsrvhndl.p (input-output ObjSrv).
&endif
