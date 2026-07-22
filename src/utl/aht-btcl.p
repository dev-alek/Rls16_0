block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: aht-btcl.p $
$Archive: utl/aht-btcl.p $

Очистка заданий на расчёт складского архива по типам приобретения с датой более ранней, чем указанна

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 01/12/05

*/

define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer   no-undo .
define input parameter p-cut-date as date      no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: aht-btcl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/aht-btcl.p $":U .
define variable vss-description as character no-undo init "Очистка заданий на расчёт складского архива по типам приобретения с датой более ранней, чем указанная".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

do
on error undo, return error
:

  define buffer buf_batchprocess for ub.batchprocess .
  define buffer delete_batchprocess for ub.batchprocess .
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_price-doc for ub.price-doc .

  for each buf_batchprocess no-lock
    where buf_batchprocess.bp_type = {&btpr-type-aht}
  on error undo, return error
  :
    case buf_batchprocess.charkey_two :
      when {&table_trn-doc}
      then do:
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_batchprocess.charkey_one
          no-error .
        if (available buf_trn-doc
            and buf_trn-doc.obj-type  = p-obj-type
            and buf_trn-doc.obj-code  = p-obj-code
            and buf_trn-doc.fact-date < p-cut-date
            )
        or not available buf_trn-doc
        then do:
          do transaction
          on error undo, return error
          :
            /* документ был удален, помечаем запись как обработанную */
            find delete_batchprocess exclusive-lock
              where recid(delete_batchprocess) = recid(buf_batchprocess)
              no-error .
            delete delete_batchprocess .
          end.
        end.
      end.
      when {&table_price-doc}
      then do:
        find first buf_price-doc no-lock
          where buf_price-doc.doc-num = buf_batchprocess.charkey_one
          no-error .
        if (available buf_price-doc
            and buf_price-doc.obj-type = p-obj-type
            and buf_price-doc.obj-code = p-obj-code
            and buf_price-doc.fact-date < p-cut-date
            )
        or not available buf_price-doc
        then do:
          do transaction
          on error undo, return error
          :
            find delete_batchprocess exclusive-lock
              where recid(delete_batchprocess) = recid(buf_batchprocess)
              no-error .
            delete delete_batchprocess .
          end.
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип таблицы" skip
          "charkey_one"  buf_batchprocess.charkey_one skip
          "charkey_two"  buf_batchprocess.charkey_two skip
          view-as alert-box error .
        undo, return error .
      end.

    end case .
  end.
end.