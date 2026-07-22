/*

$Revision: $
$Author: $
$Date$
$Workfile$
$Archive$

Журнал регистрации полученных счетов-фактур (повторяющаяся часть)

Автор: Комаров Иван Сергеевич
Дата создания: 12/16/09
Author: Ivan Komarov
Creation date: 12/16/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

for each buf_trn-doc no-lock
where buf_trn-doc.obj-type  = buf_obj-list.obj-type
  and buf_trn-doc.obj-code  = buf_obj-list.obj-code
  and buf_trn-doc.cli-type  = {1}.obj-type
  and buf_trn-doc.cli-code  = {1}.obj-code
  and buf_trn-doc.fact-date >= X-date-start
  and buf_trn-doc.fact-date <= X-date-end
  and buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
on error undo, return error return-value
:
    assign
      v-total-doc = v-total-doc + 1
    .
    { rep/repfrm.i disp v-total-doc }

    assign
      v-select-document = false
    .
    case SelectDocument
    :
      when '1':u
      then do:
        /* Все документы */
        assign
          v-select-document = true
        .
      end.
      when '2':u
      then do:
        /* Кроме межфирменных */
        { gbl/hold-doc.i
          buf_trn-doc.doc-code
          v-is-hold
        }
        if v-is-hold = true
        then do:
          assign
            v-select-document = false
          .
        end.
        else do:
          assign
            v-select-document = true
          .
        end.
      end.
      when '3':u
      then do:
        /* Межфирменные */
        { gbl/hold-doc.i
          buf_trn-doc.doc-code
          v-is-hold
        }
        if v-is-hold = true
        then do:
          assign
            v-select-document = true
          .
        end.
        else do:
          assign
            v-select-document = false
          .
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестное значение переменной SelectDocument" skip
          "SelectDocument" SelectDocument skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .

    if  v-select-document = true
    then do:
      { str/tdat-val.i
          buf_trn-doc.doc-code
          {&trdcattr-nsf}
          v-scf-code
          v-parameter-type
      }

      { str/tdat-val.i
          buf_trn-doc.doc-code
          {&trdcattr-dsf}
          v-scf-date-str
          v-parameter-type
      }
      assign
        v-scf-date = date(v-scf-date-str)
      .

      run fmtcli-get-client in this-procedure
        (input  buf_trn-doc.cli-type
        ,input  buf_trn-doc.cli-code
        ) .

      if v-scf-code <> ""
      or v-scf-date <> ?
      then do:
        /* заданы номер счета фактуры или дата счета фактуры */
        for each buf_d-slts-vats
        on error undo, return error return-value
        :
          delete buf_d-slts-vats .
        end.

        run str/calc-sup.p
          (input  recid(buf_trn-doc) /* rec-id     */
          ,input  'd-slts-vats'      /* use-table  */
          ,input  yes                /* mes-on     */
          ,input  ?                  /* inv-type   */
          ,input  yes                /* is-wait-on */
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры calc-sup.p" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        for each buf_d-slts-vats
        on error undo, return error return-value
        :
          create buf_temp-doc-list .
          assign
            buf_temp-doc-list.doc-code    = buf_trn-doc.doc-code
            buf_temp-doc-list.supp-vat-pc = buf_d-slts-vats.vat-pc
            buf_temp-doc-list.supp-slt-pc = buf_d-slts-vats.slt-pc
            buf_temp-doc-list.fact-order  = buf_trn-doc.fact-order
            buf_temp-doc-list.scf-code    = v-scf-code
            buf_temp-doc-list.scf-date    = date(v-scf-date-str)
            buf_temp-doc-list.supp-name   = v-fmtcli-name
                                          + (if v-fmtcli-name <> "" then " " else "")
                                          + v-fmtcli-addres
            buf_temp-doc-list.inn         = v-fmtcli-inn
            buf_temp-doc-list.no-vat-rubl = buf_d-slts-vats.no-vat-rubl
            buf_temp-doc-list.vat-rubl    = buf_d-slts-vats.vat-rubl
            buf_temp-doc-list.acc-rubl    = buf_d-slts-vats.acc-rubl
          .
        end.
      end.
    end.
  end.

/* $Workfile$   E n d */