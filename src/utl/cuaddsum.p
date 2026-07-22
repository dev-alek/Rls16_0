block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cuaddsum.p $
$Archive: utl/cuaddsum.p $

Программа по вызову утилиты для расчета дополнительных сумм по документу

Автор: Чернова Светлана Александровна
Дата создания: 11/09/06
Author: Svetlana Chernova
Creation date: 11/09/06

Create: Суслов Алексей Юрьевич
Дата создания: 03/24/06

Утилита вызывается если не рассчитана какая-либо сумма по документу
*/
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cuaddsum.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/cuaddsum.p $":U .
define variable vss-description as character no-undo init "Программа по вызову утилиты для расчета дополнительных сумм по документу".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/trdcalib.i }
{ cmp/library.i  }
{ gbl/getsect.i def }
define variable varinvclcspvalue as character          no-undo.
define variable varinvclcsptype  as character          no-undo.
define variable varcalcasstring  as character          no-undo.
define variable varcalcastype    as character          no-undo.
define variable wastagevalue     as character          no-undo.
define variable wastagetype      as character          no-undo.
define variable varneed-calc     as logical            no-undo.

define buffer bf_trn-doc for ub.trn-doc.
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
if not available bf_trn-doc then do:
  return error substitute ("Не найден документ с номером &1.", pardoc-code).
end.
  { gbl/getsect.i run bf_trn-doc.obj-type bf_trn-doc.obj-code {&attr-inv-obj} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'invclcsp' then varinvclcspvalue = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
      if thbjattr_thbj-attr.prop-code = 'wastage'  then wastagevalue = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
  end.
{ str/tdat-val.i
    bf_trn-doc.doc-code
    {&trdcattr-addsum}
    varcalcasstring
    varcalcastype
    no-error
}
if error-status:error then do:
  return error substitute ("Ошибка при вызове процедуры tdat-val. Документ &1. Параметр &2.", bf_trn-doc.doc-code, {&trdcattr-clcasol}).
end.
if lookup ({&sum-before-doc},  varcalcasstring ) = 0 or
   lookup ({&sum-general-doc}, varcalcasstring ) = 0 or
   lookup ({&sum-extra-doc},   varcalcasstring ) = 0 or
   lookup ({&sum-miss-doc},    varcalcasstring ) = 0 or
   lookup ({&sum-after-doc},   varcalcasstring ) = 0 then do:
  assign
    varneed-calc = yes.
end.
if wastagevalue = "yes" then do:
  if lookup ({&sum-wastage-doc}, varcalcasstring ) = 0 then do:
    assign
      varneed-calc = yes.
  end.
end.

if varinvclcspvalue = "yes" then do:
  if lookup ({&sum-before-cli-doc},  varcalcasstring ) = 0 or
     lookup ({&sum-general-cli-doc}, varcalcasstring ) = 0 or
     lookup ({&sum-extra-cli-doc},   varcalcasstring ) = 0 or
     lookup ({&sum-miss-cli-doc},    varcalcasstring ) = 0 or
     lookup ({&sum-after-cli-doc},   varcalcasstring ) = 0 then do:
    assign
      varneed-calc = yes.
  end.
  if wastagevalue = "yes" then do:
    if lookup ({&sum-wastage-cli-doc}, varcalcasstring ) = 0 then do:
      assign
        varneed-calc = yes.
    end.
  end.
end.
if varneed-calc = yes then do:
  run utl/uaddsum.p
      (input bf_trn-doc.doc-code ,
       input no ,
       input no ,
       input no
      ) no-error.
  if error-status:error then do:
    return error substitute ("Ошибка при вызове процедуры uaddsum.p: &1 &2.", return-value, error-status:get-message(1)).
  end.
end.