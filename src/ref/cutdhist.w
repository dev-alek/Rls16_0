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

&glob proc_nextlevel ref/cutdhistone.w 
&glob buf_obj-hist c-utd-head
&Glob VisibleKeyField yes
{ref/brwhist.i &Paramonly = yes &objhead = yes}
if p-mode <> "one" then
do:
  vLabel = "Èñòîðèÿ ïî ÓÏÄ".
  {ref/brwhist.i 
    &objhead       = yes 
    &lable         = vLabel
    &by-sort       = "BY X_c-obj-hist.db-num BY X_c-obj-hist.doc-id"
    &browse-fields = "X_c-obj-hist.db-num COLUMN-LABEL 'ÁÄ' FORMAT '>>9':U
                      X_c-obj-hist.doc-id COLUMN-LABEL 'Âíóòð.¹' FORMAT '>>>>>>>>9':U "
  }
end.
else do:
  run ref/cutdhistone.w(
    {&param_1},
    {&param_2},
    parParentProc,
    p-curr-host-code,
    p-curr-obj-type,
    p-curr-obj-code,
    bttns,
    p-mode,
    p-corr-user-db-num,
    p-corr-user-name,
    p-subject,
    p-db-num,
    p-chip-num,
    input-output p-rid-list
  ).
end.

{ ref/cutdhist.i}