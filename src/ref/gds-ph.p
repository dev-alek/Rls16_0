block-level on error undo, throw.
/*

$Revision: a35951db4a04, 289, rls $
$Author: EShklyar $
$Date: Tue Dec 01 19:11:22 2015 +0300 $
$Workfile: gds-ph.p $
$Archive: ref/gds-ph.p $

Показать изображение товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define input parameter parparentproc  as widget-handle no-undo.
define parameter buffer buf_goods for ub.goods .
define input parameter  loc-mode      as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: a35951db4a04, 289, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 01 19:11:22 2015 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gds-ph.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gds-ph.p $":U .
define variable vss-description as character no-undo init "Показать изображение товара".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/ini-lib.i  }
{ gbl/getcntxt.i def }

define variable HexStr   as character no-undo .
define variable v-b-code like ub.bar-code.b-code no-undo .
define variable loc#log as logical no-undo.
define variable v-can-edit as logical no-undo .

{ gbl/getcntxt.i get }

{ gbl/gdsbcode.i
  buf_goods.gds-code
  ?
  v-b-code
}

case buf_goods.gds-type
:
  when {&gds-goods}
  then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_reference_update':U
      {&cntxt-global}
      0
      '':U
      0
      0
      buf_goods.grp-code
      0
      true
      v-can-edit
    }
  end.
  when {&gds-office}
  then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_reference-services_update':U
      {&cntxt-global}
      0
      '':U
      0
      0
      buf_goods.grp-code
      0
      true
      v-can-edit
    }
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестное значение типа товара" skip
      "Тип товара" buf_goods.gds-type skip
      "Код товара" buf_goods.gds-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end case.

&SCOPED-DEFINE Slash /

DEFINE VARIABLE par-val              AS CHARACTER NO-UNDO.
DEFINE VARIABLE par-type             AS CHARACTER NO-UNDO.

{gbl/conf-rd.i "'photo':u" "'':u" "'':u" 0 "'':u" "'':u" "'':u" no par-val par-type no-error}
IF LOOKUP (par-val, "true,yes":U) > 0 THEN
DO:
    RUN ref/imagelist.w (parparentproc, 
                         IF v-can-edit THEN "b-add":U ELSE "":U, 
                         v-b-code,
                         loc-mode).
END.