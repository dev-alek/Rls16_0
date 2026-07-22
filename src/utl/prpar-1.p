block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: prpar-1.p $
$Archive: utl/prpar-1.p $

Пересчет документов по продажным ценам по партиям

Автор: Чернова Светлана Александровна
Дата создания: 12/15/09
Author: Svetlana Chernova
Creation date: 12/15/09

*/

define input  parameter  parparentproc as handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: prpar-1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/prpar-1.p $":U .
define variable vss-description as character no-undo init "Пересчет документов по продажным ценам по партиям".

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ str/lib-trn.i  }

define variable p-doc-code as character no-undo .
define variable v-r-b as character no-undo .
{ gbl/curr-r-b.i v-r-b }

  run gbl/d-prompt.w
    ( 'title=Введите Номер документа\'
    + 'format=x(15)\'
    + 'type=char\'
    ,input-output p-doc-code
    ).
  if return-value = 'false':u
  then do:
    return .
  end.


find first ub.trn-doc exclusive-lock where
           ub.trn-doc.doc-code = p-doc-code no-error .
  if ub.trn-doc.doc-type = {&income} then do:
      message "Приходы не пересчитываем ! "  view-as alert-box error .
      return .
  end.

  for each ub.doc-line no-lock where
          ub.doc-line.doc-code = ub.trn-doc.doc-code :
      find first ub.gds-obj no-lock where
                ub.gds-obj.obj-type   = ub.trn-doc.obj-type   and
                ub.gds-obj.obj-code   = ub.trn-doc.obj-code   and
                ub.gds-obj.artic      = ub.doc-line.artic     and
                ub.gds-obj.prod-type  = ub.doc-line.prod-type and
                ub.gds-obj.prod-code  = ub.doc-line.prod-code and
                ub.gds-obj.cash-parts = true no-error .
       if not available ub.gds-obj then next.
       for each ub.gds-dtl exclusive-lock where
                ub.gds-dtl.doc-code  = ub.doc-line.doc-code  and
                ub.gds-dtl.artic     = ub.doc-line.artic     and
                ub.gds-dtl.prod-type = ub.doc-line.prod-type and
                ub.gds-dtl.prod-code = ub.doc-line.prod-code
                :

            { str/set-pr.i recid(ub.gds-dtl) no ub.gds-dtl.doc-qnty no-error }
      end.
  end.

  run gbl/calc-trn.p (parparentproc ,recid(ub.trn-doc)) no-error .
  message "Все" view-as alert-box information .