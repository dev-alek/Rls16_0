block-level on error undo, throw.
define input parameter p-install as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: movegskl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/movegskl.p $":U .
define variable vss-description as character no-undo init "Перенос конф.параметров из ub.config в ub.thbj-attr.".
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
define variable start-time     as integer   no-undo .
define variable current-time   as integer   no-undo .
define variable v-ind          as integer no-undo .
define variable v-err-count    as integer no-undo .
define variable v-file-name    as char no-undo init "07121306.txt".
def frame a
  "Перенос параметров "
  v-ind        format "->>>>>>>>9" label "Количество записей" skip
  current-time format "->>>>>>>>9" label "Время" skip
  with view-as dialog-box side-labels three-d
  title "Работа с параметрами"
  .
if p-install = false then do:
  define variable lok as logical no-undo .
  message
    vss-description
    "Перенос конф.параметров из ub.config в ub.thbj-attr. ( Параметры Складских документов )"
     skip
    "Продолжить?"
    view-as alert-box question buttons yes-no update lok .
  if lok <> true then do:
    return .
  end.
end.
do
on error undo, return error
:
on write of ub.thbj-attr   override do: end.
on delete of ub.thbj-attr  override do: end.
on delete of ub.config     override do: end.
  assign
    start-time = time
  .
  view frame a .
  for each ub.thbj-attr exclusive-lock where
            ub.thbj-attr.upper-prop-code = 'nakl_par':U :
      delete ub.thbj-attr .
  end.
  run cr-proc  (input  'stfactdt':U) .
  display v-ind time @ current-time with frame a .
  run cr-proc  (input  'type-vat':U) .
  display v-ind time @ current-time with frame a .
  run cr-proc  (input  'type-slt':U) .
  display v-ind time @ current-time with frame a .
  run cr-proc  (input  'intprmvq':U) .
  display v-ind time @ current-time with frame a .
  run cr-proc  (input  'minusprt':U) .
  display v-ind time @ current-time with frame a .
end.
if p-install = false then do:
    message
    vss-description skip
    "Утилита завершила работу" skip
    "Перенесено параметров" v-ind
    view-as alert-box information .
  end.
return substitute("Перенесено параметров &1 "
                   , v-ind
                   ).
procedure cr-proc :
define input  parameter p-code as character no-undo .
define variable v-tmp as logical   no-undo .
define variable v-tmp-int  as integer   no-undo .
  do
  on error undo, return error return-value
  :
  for each  ub.config  exclusive-lock where ub.config.param-code  = p-code  and
                                     ub.config.db-num = g#db-num
                                     :
  if ub.config.param-type = 'I'  then do:
  assign
     v-tmp     = false
     v-tmp-int = integer(ub.config.param-value)
  .
  end.
  else do:
  assign
     v-tmp = logical(ub.config.param-value)
     v-tmp-int = 0
  .
  end.
    assign
      v-ind        = v-ind + 1
      current-time = time - start-time
      .
       find first ub.thbj-attr exclusive-lock where
            ub.thbj-attr.obj-code                    = ub.config.obj-code  and
            ub.thbj-attr.obj-type                    = ub.config.obj-type  and
            ub.thbj-attr.prop-code                   = "" and
            ub.thbj-attr.upper-prop-code             = 'nakl_par':U no-error .
            if not available ub.thbj-attr then do:
                create ub.thbj-attr.
                assign
                  ub.thbj-attr.obj-code                    = ub.config.obj-code
                  ub.thbj-attr.obj-type                    = ub.config.obj-type
                  ub.thbj-attr.prop-code                   = ""
                  ub.thbj-attr.upper-prop-code             = 'nakl_par':U
                  .
            end.
  find first ub.thbj-attr exclusive-lock where
       ub.thbj-attr.obj-code                    = ub.config.obj-code and
       ub.thbj-attr.obj-type                    = ub.config.obj-type and
       ub.thbj-attr.prop-code                   = p-code             and
       ub.thbj-attr.upper-prop-code             = 'nakl_par':U   no-error .
   if not available ub.thbj-attr then do:
      create ub.thbj-attr.
   end.
    assign
       ub.thbj-attr.obj-code                    = ub.config.obj-code
       ub.thbj-attr.obj-type                    = ub.config.obj-type
       ub.thbj-attr.prop-code                   = p-code
       ub.thbj-attr.upper-prop-code             = 'nakl_par':U
       ub.thbj-attr.prop-value-type             = if ub.config.param-type = 'I' then 'integer' else 'logical'
       ub.thbj-attr.property-value-logical      = v-tmp
       ub.thbj-attr.property-value-integer      = v-tmp-int
    .
  delete ub.config .
  end.
  end.
end procedure.
