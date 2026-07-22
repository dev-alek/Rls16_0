block-level on error undo, throw.

define input  parameter iUtil as class ibs.th.utl.method-for-draw-utility no-undo.
define output parameter oOk as logical no-undo. 
/* Параметры из  sht-open.p
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .

*/
&glob bachMode = yes
&glob MyPutMes = yes

procedure put-mes:
define input  parameter iVss    as logical   no-undo.
define input  parameter iText   as character no-undo.
define input  parameter iGetMes as logical   no-undo.
define input  parameter iRetval as character no-undo.
iUtil:put-log(substitute("&1  &2 &3 &4 &5 &6 &7"
                         ,iText 
                         ,if iGetMes then trim(error-status :get-message(1)) else ""  
                         ,if iGetMes then trim(error-status :get-message(2)) else ""
                         ,if iGetMes then trim(error-status :get-message(3)) else ""
                         ,if iGetMes then trim(error-status :get-message(4)) else ""
                         ,if iGetMes then trim(error-status :get-message(5)) else ""
                         ,iRetval)
  ).
    
end procedure.

{gbl/sht-open.p &bachmode = yes &myputmes = yes}
oOk = mOk.