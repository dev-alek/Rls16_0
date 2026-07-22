&glob param_1 iMark
define input  parameter {&Param_1} as character no-undo.

{ gbl/objsrv.i }

define variable vLabel as character no-undo.

&glob buf_obj-hist c-marking
&Glob VisibleKeyField yes
&glob myChangeAdd ParentPars
{ref/brwhist.i &Paramonly = yes}
if p-mode <> "one" then
do:
  vLabel = "История по Маркам".
  {ref/brwhist.i 
    &lable        = vLabel
    &by-sort      = "BY X_c-obj-hist.mark"
    &browse-fields= "X_c-obj-hist.mark COLUMN-LABEL 'Марка' FORMAT 'X(50)':U WIDTH 35 
                     X_c-obj-hist.gds-code COLUMN-LABEL 'Код товара' FORMAT '>>>>>>>>9':U"  }
end.
else do:
  run ref/cmarkingone.w(
    {&param_1},
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

{ref/cmarking.i}

function local-open-br returns logical ( 
  p-open-query     as logical    ,
  p-find-next      as logical    ,
  p-find-condition as character 
):
  return true.
end.

