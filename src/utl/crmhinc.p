block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: crmhinc.p $
$Archive: utl/crmhinc.p $

Утилита по коррекции НДС по внешним приходным накладным межфирменного перемещени

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: crmhinc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/crmhinc.p $":U .
define variable vss-description as character no-undo init "Утилита по коррекции НДС по внешним приходным накладным межфирменного перемещени ".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i  }

define buffer bf_db           for ub.db.
define buffer bf_trn-doc      for ub.trn-doc.
define buffer bf_doc-line     for ub.doc-line.
define buffer bf_parts        for ub.parts.
define buffer bf-cur_sysconf  for ub.sysconf.
define buffer bf-cur_trn-doc  for ub.trn-doc.
define buffer bf-cur_doc-line for ub.doc-line.
do transaction
on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :

  find first bf_db where bf_db.db-num > 0 no-lock no-error.
  if available bf_db then do:
    return error "Данная утилита не работает в системе с удаленными базами данных.".
  end.

  find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code exclusive-lock no-error.
  if not available bf_trn-doc then do:
    return error substitute ("Не найден документ с номером &1.", pardoc-code).
  end.
  if bf_trn-doc.ext-doc-type <> {&TDEDT_Pri_Vnesh} then do:
    return error substitute ("Документ &1 не является документом внешнего прихода.", bf_trn-doc.doc-code).
  end.
  if bf_trn-doc.hold-doc-code-parent = "" then do:
    return error substitute ("Документ &1 не является документом межфирменного перемещения.", bf_trn-doc.doc-code).
  end.
  find first bf-cur_trn-doc where bf-cur_trn-doc.doc-code = bf_trn-doc.hold-doc-code-parent no-lock no-error.
  if not available bf-cur_trn-doc then do:
    return error substitute ("Не найден родительский документ внешнего межфирменного расхода &1.", bf_trn-doc.hold-doc-code-parent).
  end.
  find first bf-cur_sysconf where bf-cur_sysconf.host-code = bf-cur_trn-doc.host-code no-lock no-error.
  if bf-cur_trn-doc.pay-code = bf-cur_sysconf.cash-pay then do:
    assign
      bf_trn-doc.slt-type = {&inc-slt}.
  end.
  else do:
    assign
      bf_trn-doc.slt-type = {&without-slt}.
  end.
  for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
    find first bf-cur_doc-line where bf-cur_doc-line.doc-code  = bf-cur_trn-doc.doc-code and
                                     bf-cur_doc-line.artic     = bf_doc-line.artic       and
                                     bf-cur_doc-line.prod-type = bf_doc-line.prod-type   and
                                     bf-cur_doc-line.prod-code = bf_doc-line.prod-code   no-lock no-error.
    if not available bf-cur_doc-line then do:
      return error substitute ("Не найдена линия по товару &1 &2 &3 в документе &4",
                               bf_doc-line.artic        ,
                               bf_doc-line.prod-type    ,
                               bf_doc-line.prod-code    ,
                               bf-cur_trn-doc.doc-code).
    end.
    assign
      bf_doc-line.vat-pc = bf-cur_doc-line.vat-pc.
    if bf_trn-doc.slt-type = {&inc-slt} then do:
      assign
        bf_doc-line.slt-pc = bf-cur_doc-line.slt-pc.
    end.
    else do:
      assign
        bf_doc-line.slt-pc = 0.
    end.
    for each bf_parts where bf_parts.out-code  = bf_doc-line.doc-code  and
                            bf_parts.obj-type  = bf_trn-doc.obj-type   and
                            bf_parts.obj-code  = bf_trn-doc.obj-code   and
                            bf_parts.artic     = bf_doc-line.artic     and
                            bf_parts.prod-type = bf_doc-line.prod-type and
                            bf_parts.prod-code = bf_doc-line.prod-code on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
      run utl/partbase.p (
          parparentproc,
          bf_parts.artic,
          bf_parts.prod-type,
          bf_parts.prod-code,
          bf_parts.in-code,
          bf_parts.part-code,
          bf_parts.price-base,
          bf_parts.price-rubl,
          bf_doc-line.vat-pc,
          bf_doc-line.slt-pc  ) no-error.
      if error-status:error then do:
        return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
      end.
    end.
  end.
end.