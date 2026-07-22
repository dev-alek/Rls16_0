block-level on error undo, throw.

define input  parameter parparentproc as handle no-undo.
define input  parameter iparam        as character no-undo.
define output parameter oOk           as logical no-undo.

define buffer buf_cash-desk for ub.cash-desk .
define buffer buf_cash-desk-attr for ub.cash-desk-attr .

DISABLE TRIGGERS FOR Load OF buf_cash-desk.
DISABLE TRIGGERS FOR Load OF buf_cash-desk-attr
.
for each buf_cash-desk exclusive-lock:
    for first buf_cash-desk-attr exclusive-lock where 
    buf_cash-desk-attr.attr-code = "device-kind" and
    buf_cash-desk-attr.db-num = buf_cash-desk.db-num and
    buf_cash-desk-attr.obj-code = buf_cash-desk.obj-code and
    buf_cash-desk-attr.pos-type = buf_cash-desk.pos-type and
    buf_cash-desk-attr.cash-num = buf_cash-desk.cash-num and
    buf_cash-desk-attr.upper-attr-code = buf_cash-desk.pos-type + "_operative":U:
    buf_cash-desk.device-kind = buf_cash-desk-attr.attr-value-integer .
    delete buf_cash-desk-attr .
    end.    
end.
   oOk = yes.