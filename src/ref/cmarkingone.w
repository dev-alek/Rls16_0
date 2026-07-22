&glob param_1 iMark
define input  parameter {&Param_1} as character no-undo.

{ gbl/objsrv.i }

define temp-table c-marking-hist no-undo like c-marking-attr
  field subject as character
  field is-news as logical
  field source-type as character
  field source-ref as character
.

define variable vLabel as character no-undo.

&glob buf_obj-hist c-marking-hist
&Glob VisibleKeyField yes
&glob myChangeAdd ParentPars
vLabel = "История изменений по марке " + iMark.
{ref/brwhist.i &lable = vLabel &objtt=yes &objhead = yes}

{ref/cmarking.i &head=yes}

function local-open-br returns logical ( 
  p-open-query     as logical    ,
  p-find-next       as logical    ,
  p-find-condition as character 
):
  define variable sort-column-phrase as character no-undo .
  define variable l-query-was-opened as logical no-undo .
  
  for each X_c-obj-hist :
    delete X_c-obj-hist.
  end.
  if p-mode eq "one"
  then do:
    &glob addTable marking
    for each c-{&addTable} where c-{&addTable}.mark               eq iMark
    no-lock:
       create X_c-obj-hist.
       buffer-copy c-{&addTable} to X_c-obj-hist
       assign 
          X_c-obj-hist.subject = "{&addTable}"
       .
    end.
    &glob addTable marking-attr
    for each c-{&addTable} where c-{&addTable}.mark               eq iMark
    no-lock:
       create X_c-obj-hist.
       buffer-copy c-{&addTable} to X_c-obj-hist
       assign 
          X_c-obj-hist.subject = "{&addTable}"
       .
    end.
  end.
  {gbl/fltopend.i
    &where-cond = " TRUE "
    &by         = " by X_c-obj-hist.corr-date desc by X_c-obj-hist.corr-time desc  " 
  }
  return true.
end.
