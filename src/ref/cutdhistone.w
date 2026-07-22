&glob param_1 p-dB-NUM-utd
define input  parameter {&Param_1} as int64 no-undo.
&glob param_2 p-doc-id-utd
define input  parameter {&Param_2} as int64 no-undo.

{ gbl/objsrv.i }
define variable StatusTH   as class     ibs.th.str.utd.sts.th  no-undo .
define variable StatusEDI  as class     ibs.th.str.utd.sts.edi no-undo .
define variable EdocType  as class     ibs.th.str.utd.edoctype no-undo .
define variable StatusMark  as class     ibs.th.str.marking.sts.mark no-undo .
StatusTH = ObjSrv:Env:Utd:Sts:TH.
StatusEDI = ObjSrv:Env:Utd:Sts:EDI.
EdocType = ObjSrv:Env:Utd:EDocType.
StatusMark = ObjSrv:Env:marking:sts:mark.

define variable vLabel as character no-undo.

&glob buf_obj-hist c-utd-head
&Glob VisibleKeyField yes
vLabel = "История по УПД " + string(p-doc-id-utd) + " по ДБ " + string(p-dB-NUM-utd).
{ref/brwhist.i &objhead = yes &lable = vLabel &objtt=yes}

{ ref/cutdhist.i}