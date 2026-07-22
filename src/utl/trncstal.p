block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: trncstal.p $
$Archive: utl/trncstal.p $

Просмотр документов внешнего прихода закрытого до факта и простановка кода ГТД в партии

Автор: Чернова Светлана Александровна
Дата создания: 02/26/07
Author: Svetlana Chernova
Creation date: 02/26/07

create: Перваков Михаил Сергеевич
Дата создания: 01/11/01

*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: trncstal.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/trncstal.p $":U .
define variable vss-description as character no-undo init "Расстановка кода ГТД для всех документов внешнего прихода".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/library.i  }
{ gbl/waitfram.i }

define variable v-today   as date      no-undo.
define variable v-time    as integer   no-undo.
define variable v-is-hold as logical   no-undo .
define variable v-ind     as integer   no-undo .
define variable v-ok      as logical   no-undo .

define buffer buf_db      for ub.db .
define buffer buf_clients for ub.clients .
define buffer buf_trn-doc for ub.trn-doc .

define stream sout .

do
on error undo, return error return-value
:

  assign
    v-ind = 0
  .

  assign
    v-ok = false
  .
  message
    "Инициализация ГТД партии на основании документов внешнего прихода" skip
    "Продолжить" skip
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true
  then do:
    return . /* --->>>--- */
  end.

  for each buf_db no-lock
  on error undo, return error return-value
  :
    for each buf_clients no-lock
      where buf_clients.db-num = buf_db.db-num
    on error undo, return error return-value
    :
      trn-doc_cycle:
      for each buf_trn-doc no-lock
        where buf_trn-doc.obj-type     = buf_clients.obj-type
          and buf_trn-doc.obj-code     = buf_clients.obj-code
          and buf_trn-doc.internal     = false
          and buf_trn-doc.doc-type     = {&income}
          and buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
          and buf_trn-doc.status_      = {&fact}
      on error undo, return error return-value
      :
        assign
          v-ind = v-ind + 1
        .
        if v-ind modulo 10 = 0
        then do:
          run waitfram-show in this-procedure
            (input substitute("Инициализация ГТД партий на основании документов внешнего прихода. Обработано документов &1"
                             ,v-ind
                             )
            ) .
        end.
        { gbl/hold-doc.i
          buf_trn-doc.doc-code
          v-is-hold
          no-error
        }
        if error-status :error
        then do:
          output stream sout to value('trncstal.err':U) append .
          export stream sout '*** error {&line-number} unable to determine ext-doc-type':U .
          export stream sout buf_trn-doc.doc-code .
          output stream sout close .

          next trn-doc_cycle . /* --->>>--- */
        end.

        if buf_trn-doc.cst-code     <> ""
        or buf_trn-doc.cst-code     <> ?
        or v-is-hold
        then do:
          /* получается, что единожды установив ГТД, его невозможно сбросить */
          /* потому что документы с пустым ГТД не анализируются              */
          /* непонятно насколько это правильно                               */

          output stream sout to value('trncstal.txt':U) append .
          export stream sout
            'update-cst-code'
            string(v-today, '99/99/9999')
            string(v-time, 'HH:MM:SS')
            buf_trn-doc.doc-code
            buf_trn-doc.cst-code
            (if v-is-hold = true
             then 'hold':U
             else '':U
            )
            .

          output stream sout close .

          run cur-time in this-procedure
            (output v-today
            ,output v-time
            ).

          run trg/trncst.p
            (input buf_trn-doc.doc-code /* p-doc-code */
            ).
        end.
      end.
    end.
  end.

  run waitfram-hide in this-procedure .

  message
    "Инициализация ГТД партии на основании документов внешнего прихода" skip
    "Обработка партий завершена" skip
    substitute("Обработано &1 документов", v-ind) skip
    view-as alert-box information .

end.