&glob param_1 iDocCode
define input  parameter {&Param_1} like ub.trn-doc.doc-code no-undo.

{ gbl/objsrv.i }
{ cmp/str-glbl.i     }
define buffer c-trn-doc for ub.c-trn-doc. 

&glob buf_obj-hist c-trn-doc
&Glob VisibleKeyField yes
{ref/brwhist.i &Paramonly = yes}

if iDocCode <> ? then
do:
  find first c-trn-doc no-lock where 
             c-trn-doc.doc-code = iDocCode no-error.
  if not avail c-trn-doc then
  do:
    message "Документ не найден." view-as alert-box.
    return.  
  end. 
end.             

run str/calldocs.w ( input  parparentproc,
                     input  if p-mode = "one" then "doc" else {&g___object},
                     input  "",
                     input  "",
                     input  ?,
                     input  no,
                     input  "":U,
                     input  if iDocCode <> ? then iDocCode else "":U,
                     input  ?,
                     input  if avail trn-doc then recid(trn-doc) else ?,
                     input  p-curr-obj-type,
                     input  p-curr-obj-code,
                     output p-rid-list ).
