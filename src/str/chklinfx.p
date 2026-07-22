block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chklinfx.p $
$Archive: str/chklinfx.p $

Заполнение номеров товарных строк и строк оплат по чеку, созданному в версиях TH < 11.1

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/02/04
Author: Bakhtadze Natalya
Creation date: 06/02/04

*/


define parameter buffer buf_chk-doc for ub.chk-doc.
define input parameter p-chk-doc-code  like ub.chk-doc.doc-code no-undo .
define input parameter p-with-question as logical no-undo .
define output parameter p-ok as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chklinfx.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chklinfx.p $":U .
define variable vss-description as character no-undo init "Заполнение номеров товарных строк и строк оплат по чеку, созданному в версиях TH < 11.1".
{ cmp/vssrevis.i "substitute('&1', (if avail buf_chk-doc then buf_chk-doc.doc-code else p-chk-doc-code))" }

{ cmp/str-glbl.i }

define variable choice as integer no-undo .
define variable ii as integer no-undo .
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-pay for ub.chk-pay.

do
on error undo, return error
:

  find first buf_chk-gds no-lock where
            buf_chk-gds.doc-code = p-chk-doc-code no-error.
  if available buf_chk-gds
  and buf_chk-gds.line-num = ?  then do:
    if p-with-question then do:
      run gbl/d-askw.w (input "Внимание",
                            input  ("Чек создан в предыдущих версиях TH,"
                                    + {&new-line}
                                    + "Для корректного просмотра необходимо заполнить номера товарных строк и строк оплаты,"
                                    + {&new-line}
                                    +  "причем номера строк НЕ БУДУТ СОВПАДАТЬ с номерами строк в ОРИГИНАЛЕ ЧЕКА НА КАССЕ!"
                                    + {&new-line}
                                    + "(По СПН изменения не передаются!)"
                                    ),
                            input "|",
                            input "Заполнить|Отменить просмотр чека",
                            input "|",
                            input 1,
                            input 2,
                            output choice).
      if choice = 2 then do:
        return.
      end.
    end.
    if not available buf_chk-doc then do:
      find first buf_chk-doc exclusive-lock where
                buf_chk-doc.doc-code = p-chk-doc-code no-wait no-error .
      if locked buf_chk-doc then do:
         if p-with-question then do:
            undo, return error substitute("Запись чека с №1 занята", p-chk-doc-code).
         end.
      end.
      if not available buf_chk-doc then undo, return error substitute("Не найден чек с №1 занята", p-chk-doc-code).
    end.

    for each buf_chk-gds where
            buf_chk-gds.doc-code = buf_chk-doc.doc-code
     on error undo, return error
            :
      assign
      ii = ii + 1
      buf_chk-gds.line-num = ii
      .
    end.
    ii = 0.
    for each buf_chk-pay where
            buf_chk-pay.doc-code = buf_chk-doc.doc-code
     on error undo, return error
            :
      assign
      ii = ii + 1
      buf_chk-pay.line-num = ii
      .
    end.
    assign
    p-ok = yes
    .
  end.
  else do:
    assign
    p-ok = yes
    .
  end.
end. /*doe*/