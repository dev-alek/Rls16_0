block-level on error undo, throw.
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
function fix-unit returns logical (input parunit-base as character):
  find first ub.units where ub.units.unit-name = parunit-base no-lock no-error.
  if not available ub.units then return ?.
  else do:
    if lookup('2ед':U,   ub.units.type) > 0 or
       lookup('топ':U, ub.units.type) > 0 then return yes.
                                               else return no.
  end.
end.
define input parameter parunit-cli             like doc-line.unit-cli            no-undo.
define input parameter pargds-code             like goods.gds-code               no-undo.
define input parameter parobj-type             like clients.obj-type             no-undo.
define input parameter parobj-code             like clients.obj-code             no-undo.
define input parameter parhold-doc-code-parent like trn-doc.hold-doc-code-parent no-undo.
define input parameter parhold-doc-code-child  like trn-doc.hold-doc-code-child  no-undo.
define output parameter paris-error      as   logical             no-undo.
define variable         varis-petrol     as   logical             no-undo.
define variable         varis-pieces     as   logical             no-undo.
define variable         varunit-cli-perm like store.unit-cli-perm no-undo.
assign paris-error = no.
find first goods   where goods.gds-code = pargds-code  no-lock.
if parobj-type =  'скл':U then do:
  find first store where store.obj-code = parobj-code no-lock.
  assign
    varunit-cli-perm = store.unit-cli-perm.
end.
else do:
  find first shop where shop.obj-code = parobj-code no-lock.
  assign
    varunit-cli-perm = shop.unit-cli-perm.
end.
if parunit-cli <> goods.unit-cli then do:
  if ( varunit-cli-perm <> yes and
       (parhold-doc-code-parent = "" or
        parhold-doc-code-parent = "no-hold" or
        parhold-doc-code-parent = ?)
        and
       (parhold-doc-code-child = "" or
        parhold-doc-code-child = "no-hold" or
        parhold-doc-code-child = ?)
     )
     or fix-unit(ub.goods.unit-base) then do:
     paris-error = yes.
  end.
end.
