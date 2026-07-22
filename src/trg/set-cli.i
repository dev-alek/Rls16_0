/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Установка признаков клиента при закрытии документов

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/11/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-cli :

  do
  on error undo, return error return-value
  :
    define input parameter p-trn-doc-recid as recid no-undo .

    define variable vss-description as character no-undo init "$Workfile$ Установка признаков клиента при закрытии документов" .

    define buffer buf_trn-doc for ub.trn-doc .
    define buffer buf_clients for ub.clients .

    define variable v-cons-pay like ub.trn-doc.pay-code no-undo .

    find first buf_trn-doc no-lock
      where recid(buf_trn-doc) = p-trn-doc-recid
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Код записи документ (recid)" p-trn-doc-recid skip
        view-as alert-box error .
      undo, return error .
    end.

    define variable v-at-value as character no-undo .
    define variable v-at-type  as character no-undo .

    { gbl/objatext.i
      buf_trn-doc.obj-type
      buf_trn-doc.obj-code
      "'cons-pay=request':u"
      v-at-value
      v-at-type
      no-error
    }
    if error-status :error
    or v-at-type <> {&type-int} then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении расширенного атрибута объекта" skip
        "Документ" buf_trn-doc.doc-code skip
        "Объект" buf_trn-doc.obj-type buf_trn-doc.obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    assign
      v-cons-pay = integer(v-at-value)
    .

    define variable l-sup as logical no-undo .
    define variable l-buy as logical no-undo .

    assign
      l-sup = (lookup(buf_trn-doc.ext-doc-type, {&TDEDT_Pri_Vnesh} ) > 0)
      l-buy = (lookup(buf_trn-doc.ext-doc-type, {&TDEDT_Ras_Vnesh} ) > 0)
    .

    if l-sup = true
    or l-buy = true
    then do:
      find buf_clients no-lock
        where buf_clients.obj-type = buf_trn-doc.cli-type
          and buf_clients.obj-code = buf_trn-doc.cli-code
        no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден контрагент" skip
          "Документ" buf_trn-doc.cli-type buf_trn-doc.cli-code skip
          view-as alert-box error .
        undo, return error .
      end.

      define variable l-gds  as logical   no-undo .
      define variable l-cons as logical   no-undo .
      define variable l-serv as logical   no-undo .

      assign
        l-gds  = false
        l-cons = false
        l-serv = false
      .

      if buf_trn-doc.office = true then do:
        /* документ на услуги */
        assign
          l-serv = true
        .
      end.
      else do:
        if buf_trn-doc.purch-code = v-cons-pay then do:
          /* документ получения, передачи товара на консигнацию */
          assign
            l-cons = true
          .
        end.
        else do:
          /* обычный товар */
          assign
            l-gds = true
          .
        end.
      end.

      if l-sup then do:
        if (l-gds  = true and (buf_clients.sup-gds  <> true) )
        or (l-cons = true and (buf_clients.sup-cons <> true) )
        or (l-serv = true and (buf_clients.sup-serv <> true) )
        then
        do transaction
        on error undo, return error return-value
        :
          find current buf_clients exclusive-lock .
          run clientsh_write-clients-proc in this-procedure  (
                                                       buffer buf_clients
                                                      ,input (if g#news then {&hn-source-db} else {&hn-source-trn-doc})
                                                      ,input (if g#news then string(g#news-source-db) else buf_trn-doc.doc-code)
                                                      ) .
          assign
            buf_clients.sup-gds  = buf_clients.sup-gds  or l-gds
            buf_clients.sup-cons = buf_clients.sup-cons or l-cons
            buf_clients.sup-serv = buf_clients.sup-serv or l-serv
          .
        end.
      end.

      if l-buy then do:
        if (l-gds  = true and (buf_clients.buy-gds  <> true) )
        or (l-cons = true and (buf_clients.buy-cons <> true) )
        or (l-serv = true and (buf_clients.buy-serv <> true) )
        then
        do transaction
        on error undo, return error return-value
        :
          find current buf_clients exclusive-lock .
          run clientsh_write-clients-proc in this-procedure  (
                                                       buffer buf_clients
                                                      ,input (if g#news then {&hn-source-db} else {&hn-source-trn-doc})
                                                      ,input (if g#news then string(g#news-source-db) else buf_trn-doc.doc-code)
                                                      ) .
          assign
            buf_clients.buy-gds  = buf_clients.buy-gds  or l-gds
            buf_clients.buy-cons = buf_clients.buy-cons or l-cons
            buf_clients.buy-serv = buf_clients.buy-serv or l-serv
          .
        end.
      end.
    end.
  end.

end procedure. /* set-cli */

/* $Workfile$ e n d */