block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rt-req08.p $
$Archive: gbl/rt-req08.p $

Обрабока запроса радиотерминала 08. Список документов. Создание нового документа

Автор: Хныкин Павел Андреевич
Дата создания: 27/02/07
Author: Pavel Khnykin
Creation date: 27/02/07

create: Перваков Михаил Сергеевич
Дата создания: 10/07/05

*/

define input  parameter p-directory-out  as character no-undo .
define input  parameter p-file-name      as character no-undo .
define input  parameter p-session-valid  as logical   no-undo .
define input  parameter p-error-message  as character no-undo .
define input  parameter p-user-login     as character no-undo .
define input  parameter p-obj-type       as character no-undo .
define input  parameter p-obj-code       as character no-undo .
define input  parameter p-host-code      as character no-undo .
define input  parameter p-cli-type       as character no-undo .
define input  parameter p-cli-code       as character no-undo .
define input  parameter p-doc-type       as character no-undo .
define input  parameter p-doc-status     as character no-undo .
define input  parameter p-doc-time       as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-req08.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-req08.p $":U .
define variable vss-description as character no-undo init "Обрабока запроса радиотерминала 08. Список документов. Создание нового документа".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/integerm.i }
{ gbl/rtencode.i }
{ str/doc-code.i }

define stream sout .

define variable v-status         as character no-undo .
define variable v-error-message  as character no-undo .
define variable v-current-db-num as integer   no-undo .
define variable v-today          as date      no-undo .
define variable v-in-pay         as integer   no-undo .
define variable v-in-pay-str     as character no-undo .
define variable v-in-pay-type    as character no-undo .
define variable v-base-rate      as decimal   no-undo .
define variable v-base-scale     as integer   no-undo .
define variable v-doc-code       as character no-undo .

do
on error undo, return error return-value
:
  if p-session-valid = true
  then do:
    run check-data in this-procedure
      (output v-status
      ,output v-error-message
      ,output v-doc-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error substitute("ошибка при вызове функции check-data. &1, &2"
                                  ,error-status :get-message(1)
                                  ,return-value
                                  ) .
    end.
  end.
  else do:
    assign
      v-status        = '3'
      v-error-message = p-error-message
      v-doc-code      = '':u
    .
  end.

  define variable v-temp-file-name as character no-undo .

  assign
    v-temp-file-name = entry(1, p-file-name, '.':u) + '.tmp':u
  .
  output stream sout to value(p-directory-out + '/':u + v-temp-file-name) .

  put stream sout unformatted substitute('status:&1',  rtencode(v-status))
                              + {&new-line} .
  put stream sout unformatted substitute('message:&1', rtencode(v-error-message))
                              + {&new-line} .
  put stream sout unformatted substitute('doc_code:&1',rtencode(v-doc-code))
                              + {&new-line} .
  output stream sout close .

  os-delete value(p-directory-out + '/':u + p-file-name) .
  os-rename value(p-directory-out + '/':u + v-temp-file-name)
            value(p-directory-out + '/':u + p-file-name)
            .
end.


procedure check-data :

  define output parameter p-status        as character no-undo .
  define output parameter p-error-message as character no-undo .
  define output parameter p-doc-code      as character no-undo .

  define buffer buf_clients  for ub.clients .
  define buffer buf_supp_clients for ub.clients .
  define buffer buf_sysconf  for ub.sysconf .
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_sys-ctrl   for ub.sys-ctrl .
  define buffer buf_user-login for ub.user-login .

  do
  on error undo, return error return-value
  :
    find first buf_sys-ctrl no-lock .
    assign
      v-current-db-num = buf_sys-ctrl.db-num
    .
    find first buf_user-login no-lock
      where buf_user-login.db-num = buf_sys-ctrl.db-num
        and buf_user-login.status_    = {&uls-normal}
        and buf_user-login.user-login = p-user-login
      no-error .
    if not available buf_user-login
    then do:
      assign
        p-status        = '3':u
        p-error-message = substitute("Неизвестный пользователь &1"
                                    ,p-user-login
                                    )
      .
      return . /* --->>>--- */
    end.

    define variable v-obj-code      as integer   no-undo .
    define variable v-data-valid    as logical   no-undo .
    define variable v-error-message as character no-undo .

    if p-obj-code = ""
    then do:
      assign
        p-status        = '3':u
        p-error-message = "Не задан код объекта"
      .
      return . /* --->>>--- */
    end.

    run integerm in this-procedure
      (input  p-obj-code      /* p-string      */
      ,input  false           /* p-allow-sign  */
      ,input  false           /* p-allow-comma */
      ,output v-obj-code      /* p-value       */
      ,output v-data-valid    /* p-data-valid  */
      ,output v-error-message /* p-message     */
      ) .

    if v-data-valid <> true
    then do:
      assign
        p-status        = '3':u
        p-error-message = substitute("Ошибка преобразования кода объекта &1. &2"
                                    ,p-obj-code
                                    ,v-error-message
                                    )
      .
      return . /* --->>>--- */
    end.

    find first buf_clients no-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = v-obj-code
      no-error .
    if not available buf_clients
    then do:
      assign
        p-status        = '3':u
        p-error-message = substitute("Не найден объект &1 &2"
                                    ,p-obj-type
                                    ,v-obj-code
                                    )
      .
      return . /* --->>>--- */
    end.

    if  p-obj-type <> {&shop}
    and p-obj-type <> {&stock}
    then do:
      assign
        p-status        = '3':u
        p-error-message = substitute("Неправильный тип объекта &1 &2"
                                    ,p-obj-type
                                    ,v-obj-code
                                    )
      .
      return . /* --->>>--- */
    end.

    { gbl/objatext.i
      p-obj-type
      v-obj-code
      "'in-pay=request'"
      v-in-pay-str
      v-in-pay-type
    }
    assign
      v-in-pay = integer(v-in-pay-str)
    .

    define variable v-host-code as integer   no-undo .

    run integerm in this-procedure
      (input  p-host-code     /* p-string      */
      ,input  false           /* p-allow-sign  */
      ,input  false           /* p-allow-comma */
      ,output v-host-code     /* p-value       */
      ,output v-data-valid    /* p-data-valid  */
      ,output v-error-message /* p-message     */
      ) .
    if v-data-valid <> true
    then do:
      assign
        p-status        = '3':u
        p-error-message = substitute("Ошибка преобразования кода фирмы &1. &2"
                                    ,p-host-code
                                    ,v-error-message
                                    )
      .
      return . /* --->>>--- */
    end.

    /* проверить, что фирма соответсвует объекту */
    define variable v-obj-host-code as integer   no-undo .

    { gbl/hostcode.i
      buf_clients.obj-type
      buf_clients.obj-code
      v-obj-host-code
    }
    if v-host-code <> v-obj-host-code
    then do:
      assign
        p-status        = '3':u
        p-error-message = substitute("Заданный код фирмы &1 отличается от кода фирмы &2 объекта &3 &4."
                                    ,p-host-code
                                    ,v-obj-host-code
                                    ,buf_clients.obj-type
                                    ,buf_clients.obj-code
                                    )
      .
      return . /* --->>>--- */
    end.

    /* проверить что объект доступен пользователю */
    define variable v-object-available as logical   no-undo .
    { gbl/usobjava.i
      buf_sys-ctrl.db-num
      {&action-head-code-main}
      buf_user-login.user-id
      buf_clients.obj-type
      buf_clients.obj-code
      v-object-available
    }
    if v-object-available <> true
    then do:
      assign
        p-status        = '3':u
        p-error-message = substitute("Пользователю не доступен объект &1 &2"
                                    ,buf_clients.obj-type
                                    ,buf_clients.obj-code
                                    )
      .
      return . /* --->>>--- */
    end.

    define variable v-cli-code      as integer   no-undo .

    if p-cli-code = ""
    then do:
      assign
        p-status        = '3':u
        p-error-message = "Не задан код поставщика"
      .
      return . /* --->>>--- */
    end.

    run integerm in this-procedure
      (input  p-cli-code      /* p-string      */
      ,input  false           /* p-allow-sign  */
      ,input  false           /* p-allow-comma */
      ,output v-cli-code      /* p-value       */
      ,output v-data-valid    /* p-data-valid  */
      ,output v-error-message /* p-message     */
      ) .

    if v-data-valid <> true
    then do:
      assign
        p-status        = '3':u
        p-error-message = substitute("Ошибка преобразования кода поставщика &1. &2"
                                    ,p-obj-code
                                    ,v-error-message
                                    )
      .
      return . /* --->>>--- */
    end.

    find first buf_supp_clients no-lock
      where buf_supp_clients.obj-type = p-cli-type
        and buf_supp_clients.obj-code = v-cli-code
      no-error .
    if not available buf_supp_clients
    then do:
      assign
        p-status        = '3':u
        p-error-message = substitute("Не найден поставщик &1 &2"
                                    ,p-cli-type
                                    ,v-cli-code
                                    )
      .
      return . /* --->>>--- */
    end.

    find first buf_sysconf no-lock
      where buf_sysconf.host-code = v-host-code
      no-error .
    if not available buf_sysconf
    then do:
      assign
        p-status        = '3':u
        p-error-message = substitute("Не найдена фирма &1"
                                    ,v-host-code
                                    )
      .
      return . /* --->>>--- */
    end.

    define variable v-doc-time  as integer   no-undo .
    define variable v-other     as character no-undo .

    run integerm in this-procedure
      (input  p-doc-time      /* p-string      */
      ,input  false           /* p-allow-sign  */
      ,input  false           /* p-allow-comma */
      ,output v-doc-time      /* p-value       */
      ,output v-data-valid    /* p-data-valid  */
      ,output v-error-message /* p-message     */
      ) .
    if v-data-valid <> true
    then do:
      assign
        p-status        = '3':u
        p-error-message = substitute("Ошибка преобразования времени прихода товара &1 , &2"
                                    ,p-doc-time
                                    ,v-error-message
                                    )
      .
      return . /* --->>>--- */
    end.

    if v-doc-time < 0
    then do:
      assign
        p-status        = '3':u
        p-error-message = substitute("Время прихода товара не может быть отрицательным : &1"
                                    ,v-doc-time
                                    )
      .
      return . /* --->>>--- */
    end.

    assign
      v-other = string( v-doc-time , "HH:MM" )
    .

    { gbl/baserate.i
      v-host-code
      v-today
      v-base-rate
      v-base-scale
    }

    case p-doc-type
    :
      when 'ПТ':u
      then do:
        /* поставка в статусе поставка */
        assign
          p-status        = '3':u
          p-error-message = "Нельзя создавать документ поставки"
        .
        return . /* --->>>--- */
      end.
      when 'ПН':u
      then do:
        if lookup(p-doc-status, 'накл-':u + {&comma-char} + 'накл+':u) = 0
        then do:
          assign
            p-status        = '3':u
            p-error-message = substitute("Не известный статус документа внешнего прихода &1"
                                        ,p-doc-status
                                        )
          .
          return . /* --->>>--- */
        end.

        /* разрешить создание документов только на активной стороне */
        define variable v-obj-is-active as logical   no-undo .
        { gbl/objat.i
          p-obj-type
          v-obj-code
          "'active=request'"
          v-obj-is-active
          no-error
        }
        if v-obj-is-active <> true
        then do:
          assign
            p-status        = '3':u
            p-error-message = substitute("Документы можно создавать только на активной стороне. Создание документов на объекте &1 &2 невозможно"
                                        ,p-obj-type
                                        ,v-obj-code
                                        )
          .
          return . /* --->>>--- */
        end.

        /* проверить права пользователя на создание документа */
        define variable v-valid-act   as logical   no-undo .

        { gbl/chk-actg.i
          buf_sys-ctrl.db-num
          buf_user-login.user-id
          {&action-head-code-main}
          'actn_rt-edit-doc_add-def':U
          {&cntxt-object}
          v-host-code
          buf_clients.obj-type
          buf_clients.obj-code
          0
          0
          0
          false
          v-valid-act
        }
        if v-valid-act <> true
        then do:
          assign
            p-status        = '3':u
            p-error-message = return-value
          .
          return . /* --->>>--- */
        end.

        create_doc :
        do transaction
        on error undo create_doc, return error return-value
        :
          /* создать номер документа */
          run doc-code in this-procedure
            (input  'main':u
            ,input  p-obj-type
            ,input  v-obj-code
            ,input  ?
            ,output p-doc-code
            ) no-error .
          if error-status :error
          then do:
            assign
              p-status        = '3':u
              p-error-message = substitute('Ошибка при создании номера документа &1 &2':u
                                          ,error-status :get-message(1)
                                          ,return-value
                                          )
              p-doc-code      = '':u
            .
            return . /* --->>>--- */
          end.

          /* todo - делать автоматическую или ручную смену даты */

          /* получить текущую дату */
          { gbl/curobjdt.i
            p-obj-type
            v-obj-code
            v-today
          }

          { str/crtrndoc.i
            ?
            ?
            v-base-rate
            v-base-scale
            buf_supp_clients.obj-code
            buf_supp_clients.obj-type
            buf_supp_clients.obj-name
            v-current-db-num
            p-user-login
            "''"
            p-doc-code
            v-today
            {&income}
            false
            v-host-code
            no
            v-obj-code
            p-obj-type
            false
            v-in-pay
            "''"
            no
            ?
            {&wayb}
            ?
            {&TDEDT_Pri_Vnesh}
            {&repayment-code}
            no-error
          }
          if error-status :error
          then do:
            assign
              p-status        = '3':u
              p-error-message = substitute('Ошибка при создании документа &1 &2':u
                                          ,error-status :get-message(1)
                                          ,return-value
                                          )
              p-doc-code      = '':u
            .
            return . /* --->>>--- */
          end.

          find first buf_trn-doc exclusive-lock
            where buf_trn-doc.doc-code = p-doc-code
            no-error .
          if not available buf_trn-doc
          then do:
            assign
              p-status        = '3':u
              p-error-message = substitute('Ошибка при создании документа. Не найден документ с номером &1':u
                                          ,p-doc-code
                                          )
              p-doc-code      = '':u
            .
            return . /* --->>>--- */
          end.

          assign
            buf_trn-doc.exch-date  = v-today
            buf_trn-doc.exch-code  = 0
            buf_trn-doc.exch-rate  = 1
            buf_trn-doc.exch-scale = 1
            buf_trn-doc.print-rubl = yes
            buf_trn-doc.vat-type   = {&inc-vat}
            buf_trn-doc.slt-type   = {&without-slt}
          .

          /* проверить и при необходимости заполнить кладовщика, исполнителя, менеджера */
          define variable v-param-type as character no-undo .
          define variable v-value-character as character no-undo .
          define variable v-value-date    as date no-undo .
          define variable v-value-decimal as decimal no-undo .
          define variable v-value-integer as INTEGER no-undo .
          define variable v-value-logical AS LOGICAL no-undo .
          define variable v-tth as handle no-undo .


          if buf_trn-doc.wrkr = ?
          then do:
            run adm/shattri.p (
                input "get":U
                ,input  p-obj-type
                ,input  v-obj-code
                ,input  {&attr-rt-trn-doc}
                ,input  {&attr-rt-trn-doc_wrkr}
                ,output v-value-character
                ,output v-value-date
                ,output v-value-decimal
                ,output v-value-integer
                ,output v-value-logical
                ,output v-param-type
                ,INPUT-OUTPUT table-handle v-tth
                ) no-error .
            delete object v-tth.
            if  v-value-integer <> ?
            then do:
              assign
                buf_trn-doc.wrkr = v-value-integer
              .
            end.
          end.

          if buf_trn-doc.agnt = ?
          then do:
            run adm/shattri.p (
                input "get":U
                ,input  p-obj-type
                ,input  v-obj-code
                ,input  {&attr-rt-trn-doc}
                ,input  {&attr-rt-trn-doc_agnt}
                ,output v-value-character
                ,output v-value-date
                ,output v-value-decimal
                ,output v-value-integer
                ,output v-value-logical
                ,output v-param-type
                ,INPUT-OUTPUT table-handle v-tth
                ) no-error .
            delete object v-tth.

            if  v-value-integer <> ?
            then do:
              assign
                buf_trn-doc.agnt = v-value-integer
              .
            end.
          end.

          if buf_trn-doc.boss = ?
          then do:
            run adm/shattri.p (
                input "get":U
                ,input  p-obj-type
                ,input  v-obj-code
                ,input  {&attr-rt-trn-doc}
                ,input  {&attr-rt-trn-doc_boss}
                ,output v-value-character
                ,output v-value-date
                ,output v-value-decimal
                ,output v-value-integer
                ,output v-value-logical
                ,output v-param-type
                ,INPUT-OUTPUT table-handle v-tth
                ) no-error .
            delete object v-tth.
            if  v-value-integer <> ?
            then do:
              assign
                buf_trn-doc.boss = v-value-integer
              .
            end.
          end.

          /* todo - задавать контракт */
          run gbl/rt-doced.p
            (input  p-doc-type + '|':u + buf_trn-doc.doc-code
            ,input  buf_user-login.user-id
            ,input  '2':u
            ,input  'create':u
            ,input  v-other
            ,output p-status
            ,output p-error-message
            ) .
          if p-status = '3'
          then do:
            undo create_doc, return . /* --->>>--- */
          end.

          /* редактировать док. количества */
          assign
            p-status        = '2':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.
      end.
      otherwise do:
        assign
          p-status        = '3':u
          p-error-message = substitute("Неизвестный тип документа &1"
                                      ,p-doc-type
                                      )
        .
        return . /* --->>>--- */
      end.
    end case .

    assign
      p-status        = '3':u
      p-error-message = "rt-req08.p. Неизвестная ошибка"
    .
    return . /* --->>>--- */
  end.


end procedure. /* check-data */