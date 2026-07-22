block-level on error undo, throw.
define input  parameter iKey     as integer no-undo.
define output parameter oChekSum as character no-undo.
if userid("ub") eq ""
then do:
   oChekSum = encode(string(iKey * 13)) + string(index(encode(string(iKey)), "k"))
 .
   return.
end.
define input parameter parparentproc    as widget-handle no-undo .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define new shared stream vProtTest.
define new shared variable testId as rowid no-undo.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn)
  then run str/lib-trn.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn2)
  then run str/lib-trn2.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn3)
  then run str/lib-trn3.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn4)
  then run str/lib-trn4.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#trdcalib)
  then run str/trdcalib.p persistent no-error .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
output stream vProtTest to "sendtest1c.log".
define buffer buf_trn-doc   for ub.trn-doc.
define buffer buf_doc-attr  for ub.doc-attr.
define buffer buf_shift-obj for ub.shift-obj.
define buffer buf_rvs-doc   for ub.rvs-doc.
define buffer buf_price-doc for ub.price-doc.
define buffer buf_fin-doc   for ub.fin-doc.
define buffer buf_fbr-doc   for ub.fbr-doc.
define buffer buf_utd       for ub.utd.
define buffer buf_place       for ub.place.
find last buf_trn-doc where
          buf_trn-doc.obj-type = v-cntxt-obj-type
      and buf_trn-doc.obj-code = v-cntxt-obj-code
      and buf_trn-doc.status_ = "факт"
      and buf_trn-doc.flag_
      and (buf_trn-doc.ext-doc-type = 'ie':U or
           buf_trn-doc.ext-doc-type = 'ee':U or
           buf_trn-doc.ext-doc-type = 'ep':U or
           buf_trn-doc.ext-doc-type = 'we':U or
           buf_trn-doc.ext-doc-type = 'ev':U or
           buf_trn-doc.ext-doc-type = 'iv':U or
           buf_trn-doc.ext-doc-type = 'rv':U or
           buf_trn-doc.ext-doc-type = 're':U) no-lock no-error.
if avail buf_trn-doc then
do:
  testId = rowid(buf_trn-doc).
  run utl/send1c.p.
  testId = ?.
end.
find last buf_trn-doc where
          buf_trn-doc.obj-type = v-cntxt-obj-type
      and buf_trn-doc.obj-code = v-cntxt-obj-code
      and buf_trn-doc.status_ = "факт"
      and buf_trn-doc.flag_
      and buf_trn-doc.ext-doc-type = 'vt':U no-lock no-error.
if avail buf_trn-doc then
do:
  testId = rowid(buf_trn-doc).
  run utl/send1c.p.
  testId = ?.
end.
find last buf_trn-doc where
          buf_trn-doc.obj-type = v-cntxt-obj-type
      and buf_trn-doc.obj-code = v-cntxt-obj-code
      and buf_trn-doc.status_ = "факт"
      and buf_trn-doc.flag_
      and buf_trn-doc.ext-doc-type = 'vp':U no-lock no-error.
if avail buf_trn-doc then
do:
  testId = rowid(buf_trn-doc).
  run utl/send1c.p.
  testId = ?.
end.
find last buf_shift-obj where
          buf_shift-obj.obj-type = v-cntxt-obj-type
      and buf_shift-obj.obj-code = v-cntxt-obj-code
      and buf_shift-obj.status_  = "зкр" no-lock no-error.
if avail buf_shift-obj then
do:
  testid = rowid(buf_shift-obj).
  run utl/send2c.p.
  testId = ?.
end.
find last buf_rvs-doc where
          buf_rvs-doc.obj-type = v-cntxt-obj-type
      and buf_rvs-doc.obj-code = v-cntxt-obj-code
      and buf_rvs-doc.status_ = "факт"
     no-lock no-error.
if avail buf_rvs-doc then
do:
  testid = rowid(buf_rvs-doc).
  run utl/send3c.p.
  testId = ?.
end.
find last buf_price-doc where
          buf_price-doc.obj-type = v-cntxt-obj-type
      and buf_price-doc.obj-code = v-cntxt-obj-code
      and buf_price-doc.status_ = "акт"
     no-lock no-error.
if avail buf_price-doc then
do:
  testId = rowid(buf_price-doc).
  run utl/send4c.p.
  testId = ?.
end.
find last buf_fin-doc where
          buf_fin-doc.obj-type = v-cntxt-obj-type
      and buf_fin-doc.obj-code = v-cntxt-obj-code
      and buf_fin-doc.status_ = "факт"
     no-lock no-error.
if avail buf_fin-doc then
do:
  testId = rowid(buf_fin-doc).
  run utl/send5c.p.
  testId = ?.
end.
find last buf_fbr-doc where
          buf_fbr-doc.obj-type = v-cntxt-obj-type
      and buf_fbr-doc.obj-code = v-cntxt-obj-code
      and buf_fbr-doc.status_ = "факт"
     no-lock no-error.
if avail buf_fbr-doc then
do:
  testId = rowid(buf_fbr-doc).
  run utl/send6c.p.
  testId = ?.
end.
find last buf_utd where
          buf_utd.obj-type = v-cntxt-obj-type
      and buf_utd.obj-code = v-cntxt-obj-code
      and buf_utd.sts = 8
     no-lock no-error.
if avail buf_utd then
do:
  testId = rowid(buf_utd).
  run utl/send7c.p.
  testId = ?.
end.
for each buf_place no-lock where buf_place.status_ <> 'удал':U:
  testId = rowid(buf_place).
  run utl/send9c.p.
end.
testId = ?.
find last buf_shift-obj where
          buf_shift-obj.obj-type = v-cntxt-obj-type
      and buf_shift-obj.obj-code = v-cntxt-obj-code
      and buf_shift-obj.status_  = 'зкр':U no-lock no-error.
if avail buf_shift-obj then
do:
  testid = rowid(buf_shift-obj).
  run utl/send10c.p.
  testId = ?.
end.
output stream vProtTest close.
message "Ћог - " search("sendtest1c.log") view-as alert-box.
