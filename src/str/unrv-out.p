block-level on error undo, throw.
/*

$Revision: 5baf537283c9, 2487, rls $
$Author: SSlivenko $
$Date: Пт июн 26 16:47:04 2020 +0300 $
$Workfile: unrv-out.p $
$Archive: str/unrv-out.p $

Cнятие резервов по РН, ВН, НС - внешним, РН - внутренней

Автор: Чернова Светлана Александровна
Дата создания: 10/31/06
Author: Svetlana Chernova
Creation date: 10/31/06

Create: Суслов Алексей Юрьевич
Дата создания: 09/20/05


*/
define input parameter parparentproc as   handle no-undo.
define input parameter trn-code      like trn-doc.doc-code no-undo.             /* номер документа */

define variable vss-revision    as character no-undo init "$Revision: 5baf537283c9, 2487, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пт июн 26 16:47:04 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: unrv-out.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/unrv-out.p $":U .
define variable vss-description as character no-undo init "Cнятие резервов по РН, ВН, НС - внешним, РН - внутренней".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define variable  old-flag like trn-doc.flag_ no-undo.                                  /* для запоминания флага */
define variable  chg-qnty like gds-dtl.doc-qnty no-undo.                           /* для вызова rsrv-dtl.p */
define variable  varwas-ov as logical no-undo.
define variable  varlog as logical no-undo.
define variable  is-hold as logical   no-undo .

if v-cntxt-db-num <> v-cntxt-db-num-obj and ( v-cntxt-db-num-obj <> 0 ) then do:
  message "На пассивной стороне снять резервы невозможно.".
  return error.
end.
find trn-doc where trn-doc.doc-code = trn-code.
if not (can-do ({&expense_write-off_return}, trn-doc.doc-type) and not trn-doc.internal or trn-doc.doc-type = {&expense}) then do:
  message "Документ №" trn-doc.doc-code skip
          "По документу данного типа снять резервы невозможно.".
  return error.
end.

{ gbl/hold-doc.i trn-doc.doc-code is-hold }
if is-hold and not trn-doc.internal then do:
  message "Документ №" trn-doc.doc-code skip
          "По межфирменному перемещению снять резервы невозможно.".
  return error.
end.

if trn-doc.status_ <> {&wayb} then do:
  message "Документ №" trn-doc.doc-code skip
          "По документу с данным статусом снять резервы невозможно.".
  return error.
end.
unrv:
do on stop undo unrv, return error on error undo unrv, return error:
  assign
    old-flag = trn-doc.flag_       /* запоминаем значение флага */
    trn-doc.flag_ = no.            /* иначе неправильно снимаются резервы */
    if trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} and
     can-find(first gds-dtl where gds-dtl.doc-code = trn-doc.doc-code and
                                  gds-dtl.ov       = yes                  )
     then assign varwas-ov = yes.
     else assign varwas-ov = no.

  for each gds-dtl where gds-dtl.doc-code = trn-doc.doc-code,
       each doc-line of gds-dtl
       on stop undo unrv, return error on error undo unrv, return error:
    chg-qnty = - gds-dtl.doc-qnty.
    run trg/rsrv-dtl.p ( parparentproc,
                     {&rsrv-dtl_action_reserv}, buffer gds-dtl, input-output chg-qnty,
                           input-output doc-line.price-base, input-output doc-line.price-rubl, -1, "").
    if chg-qnty <> - gds-dtl.doc-qnty then undo unrv, return error.
    /* если это счет - отменяем подстановку новой цены при последующем резервировании */
    if old-flag then gds-dtl.ov = yes. /* нельзя написать gds-dtl.ov = old-flag, т.к. gds-dtl.ov мб = yes при ручной установке цены */
  end.
  if trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} and
  varwas-ov = yes then do:
    assign varlog = no.
    message "Будем разфиксировать цены?" view-as alert-box question buttons yes-no update varlog .
    if varlog then do:
       for each gds-dtl where gds-dtl.doc-code = trn-doc.doc-code
       on stop undo unrv, return error on error undo unrv, return error:
         assign gds-dtl.ov = no.
       end.
    end.
  end.
  assign
    trn-doc.status_ = {&inquiry}
    trn-doc.flag_   = yes.
end.