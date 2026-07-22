block-level on error undo, throw.
define input parameter par-line-rec as  recid   no-undo.
define input parameter par-mes      as  logical no-undo.
define parameter buffer t-doc for ub.trn-doc .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: 2014/01/27 14:27:46 $":U .
def var vss-workfile    as character no-undo init "$Workfile: chk-prt.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/chk-prt.p $":U .
def var vss-description as character no-undo init "Проверка того, что признаки соответствует строке документа".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
    assign
      p-vss-parameters = substitute('&1|&2':u,par-line-rec,par-mes)
    .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
if t-doc.status_ = 'факт':U then do:
  return .
end.
find ub.doc-line exclusive-lock
  where recid (ub.doc-line) = par-line-rec
  .
for each ub.gds-dtl
  where ub.gds-dtl.doc-code  = ub.doc-line.doc-code
    and ub.gds-dtl.artic     = ub.doc-line.artic
    and ub.gds-dtl.prod-type = ub.doc-line.prod-type
    and ub.gds-dtl.prod-code = ub.doc-line.prod-code
:
  if  ub.gds-dtl.fact-qnty = 0
  and ub.gds-dtl.doc-qnty  = 0 then do:
    if t-doc.ext-doc-type <> 'ap':U   and
       t-doc.ext-doc-type <> 'pc':U   and
       t-doc.ext-doc-type <> 'mp':U then do:
      delete ub.gds-dtl.
    end.
  end.
  else do:
    accumulate
      ub.gds-dtl.prt-code (count)
      ub.gds-dtl.doc-qnty (total)
      ub.gds-dtl.fact-qnty (total)
    .
  end.
end.
if ( t-doc.flag_ = false
     and (accum total ub.gds-dtl.doc-qnty) <> ub.doc-line.doc-qnty
   )
or ( t-doc.flag_ = true
     and (accum total ub.gds-dtl.fact-qnty) <> ub.doc-line.fact-qnty
   ) then do:
  if par-mes then do:
    message
      "Количество по шкале (по всем признакам) не совпадает с количеством по артикулу."
      view-as alert-box .
  end.
  assign
    ub.doc-line.prt-ok = false
  .
end.
else do:
  assign
    ub.doc-line.prt-ok = true
  .
end.
if  (accum count ub.gds-dtl.prt-code) = 0
and (ub.doc-line.prt-OK = false ) then do:
  assign
    ub.doc-line.prt-OK = ?
  .
end.
