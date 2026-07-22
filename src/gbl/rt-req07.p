block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rt-req07.p $
$Archive: gbl/rt-req07.p $

Обрабока запроса радиотерминала 07. Список документов. Прокрутка списка документов.

Автор: Хныкин Павел Андреевич
Дата создания: 27/02/07
Author: Pavel Khnykin
Creation date: 27/02/07

create: Перваков Михаил Сергеевич
Дата создания: 09/30/05

*/

define input  parameter p-directory-out  as character no-undo .
define input  parameter p-file-name      as character no-undo .
define input  parameter p-session-valid  as logical   no-undo .
define input  parameter p-error-message  as character no-undo .
define input  parameter p-user-login        as character no-undo .
define input  parameter p-obj-type       as character no-undo .
define input  parameter p-obj-code       as character no-undo .
define input  parameter p-host-code      as character no-undo .
define input  parameter p-cli-type       as character no-undo .
define input  parameter p-cli-code       as character no-undo .
define input  parameter p-doc-type       as character no-undo .
define input  parameter p-doc-status     as character no-undo .
define input  parameter p-doc-code-first as character no-undo .
define input  parameter p-doc-code-last  as character no-undo .
define input  parameter p-direction      as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-req07.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-req07.p $":U .
define variable vss-description as character no-undo init "Обрабока запроса радиотерминала 07. Приемка товара. Выбор по номеру".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/integerm.i }
{ gbl/rtencode.i }

define stream sout .

define temp-table temp-doc-list no-undo
  field temp-order    as integer
  field temp-doc-code as character
  field temp-doc-date as character

  index xpk is primary unique temp-order
  .

define temp-table tt-docs no-undo
  field ord-doc-date as date
  field ord-doc-code as character
  field doc-date     as date
  field doc-code     as character
index pi is primary unique
  doc-code
index sort
  ord-doc-date  descending
  ord-doc-code  descending
  doc-date      descending
  doc-code      descending
.



define variable v-status        as character no-undo .
define variable v-error-message as character no-undo .
define variable v-doc-code-01   as character no-undo .
define variable v-doc-date-01   as character no-undo .
define variable v-doc-code-02   as character no-undo .
define variable v-doc-date-02   as character no-undo .
define variable v-doc-code-03   as character no-undo .
define variable v-doc-date-03   as character no-undo .
define variable v-doc-code-04   as character no-undo .
define variable v-doc-date-04   as character no-undo .
define variable v-doc-code-05   as character no-undo .
define variable v-doc-date-05   as character no-undo .
define variable v-doc-code-06   as character no-undo .
define variable v-doc-date-06   as character no-undo .
define variable v-doc-code-07   as character no-undo .
define variable v-doc-date-07   as character no-undo .
define variable v-doc-code-08   as character no-undo .
define variable v-doc-date-08   as character no-undo .
define variable v-doc-code-09   as character no-undo .
define variable v-doc-date-09   as character no-undo .
define variable v-doc-code-10   as character no-undo .
define variable v-doc-date-10   as character no-undo .

do
on error undo, return error return-value
:
  if p-session-valid = true
  then do:
    run check-data in this-procedure
      (output v-status
      ,output v-error-message
      ,output v-doc-code-01
      ,output v-doc-date-01
      ,output v-doc-code-02
      ,output v-doc-date-02
      ,output v-doc-code-03
      ,output v-doc-date-03
      ,output v-doc-code-04
      ,output v-doc-date-04
      ,output v-doc-code-05
      ,output v-doc-date-05
      ,output v-doc-code-06
      ,output v-doc-date-06
      ,output v-doc-code-07
      ,output v-doc-date-07
      ,output v-doc-code-08
      ,output v-doc-date-08
      ,output v-doc-code-09
      ,output v-doc-date-09
      ,output v-doc-code-10
      ,output v-doc-date-10
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
      v-status        = '1'
      v-error-message = p-error-message
      v-doc-code-01   = '':u
      v-doc-date-01   = '':u
      v-doc-code-02   = '':u
      v-doc-date-02   = '':u
      v-doc-code-03   = '':u
      v-doc-date-03   = '':u
      v-doc-code-04   = '':u
      v-doc-date-04   = '':u
      v-doc-code-05   = '':u
      v-doc-date-05   = '':u
      v-doc-code-06   = '':u
      v-doc-date-06   = '':u
      v-doc-code-07   = '':u
      v-doc-date-07   = '':u
      v-doc-code-08   = '':u
      v-doc-date-08   = '':u
      v-doc-code-09   = '':u
      v-doc-date-09   = '':u
      v-doc-code-10   = '':u
      v-doc-date-10   = '':u
    .
  end.

  define variable v-temp-file-name as character no-undo .

  assign
    v-temp-file-name = entry(1, p-file-name, '.':u) + '.tmp':u
  .
  output stream sout to value(p-directory-out + '/':u + v-temp-file-name) .

  put stream sout unformatted substitute('status:&1',     rtencode(v-status))
                              + {&new-line} .
  put stream sout unformatted substitute('message:&1',    rtencode(v-error-message))
                              + {&new-line} .
  put stream sout unformatted substitute('doc_code_01:&1',rtencode(v-doc-code-01))
                              + {&new-line} .
  put stream sout unformatted substitute('doc_date_01:&1',rtencode(v-doc-date-01))
                              + {&new-line} .
  put stream sout unformatted substitute('doc_code_02:&1',rtencode(v-doc-code-02))
                              + {&new-line} .
  put stream sout unformatted substitute('doc_date_02:&1',rtencode(v-doc-date-02))
                              + {&new-line} .
  put stream sout unformatted substitute('doc_code_03:&1',rtencode(v-doc-code-03))
                              + {&new-line} .
  put stream sout unformatted substitute('doc_date_03:&1',rtencode(v-doc-date-03))
                              + {&new-line} .
  put stream sout unformatted substitute('doc_code_04:&1',rtencode(v-doc-code-04))
                              + {&new-line} .
  put stream sout unformatted substitute('doc_date_04:&1',rtencode(v-doc-date-04))
                              + {&new-line} .
  put stream sout unformatted substitute('doc_code_05:&1',rtencode(v-doc-code-05))
                              + {&new-line} .
  put stream sout unformatted substitute('doc_date_05:&1',rtencode(v-doc-date-05))
                              + {&new-line} .
  put stream sout unformatted substitute('doc_code_06:&1',rtencode(v-doc-code-06))
                              + {&new-line} .
  put stream sout unformatted substitute('doc_date_06:&1',rtencode(v-doc-date-06))
                              + {&new-line} .
  put stream sout unformatted substitute('doc_code_07:&1',rtencode(v-doc-code-07))
                              + {&new-line} .
  put stream sout unformatted substitute('doc_date_07:&1',rtencode(v-doc-date-07))
                              + {&new-line} .
  put stream sout unformatted substitute('doc_code_08:&1',rtencode(v-doc-code-08))
                              + {&new-line} .
  put stream sout unformatted substitute('doc_date_08:&1',rtencode(v-doc-date-08))
                              + {&new-line} .
  put stream sout unformatted substitute('doc_code_09:&1',rtencode(v-doc-code-09))
                              + {&new-line} .
  put stream sout unformatted substitute('doc_date_09:&1',rtencode(v-doc-date-09))
                              + {&new-line} .
  put stream sout unformatted substitute('doc_code_10:&1',rtencode(v-doc-code-10))
                              + {&new-line} .
  put stream sout unformatted substitute('doc_date_10:&1',rtencode(v-doc-date-10))
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
  define output parameter p-doc-code-01   as character no-undo .
  define output parameter p-doc-date-01   as character no-undo .
  define output parameter p-doc-code-02   as character no-undo .
  define output parameter p-doc-date-02   as character no-undo .
  define output parameter p-doc-code-03   as character no-undo .
  define output parameter p-doc-date-03   as character no-undo .
  define output parameter p-doc-code-04   as character no-undo .
  define output parameter p-doc-date-04   as character no-undo .
  define output parameter p-doc-code-05   as character no-undo .
  define output parameter p-doc-date-05   as character no-undo .
  define output parameter p-doc-code-06   as character no-undo .
  define output parameter p-doc-date-06   as character no-undo .
  define output parameter p-doc-code-07   as character no-undo .
  define output parameter p-doc-date-07   as character no-undo .
  define output parameter p-doc-code-08   as character no-undo .
  define output parameter p-doc-date-08   as character no-undo .
  define output parameter p-doc-code-09   as character no-undo .
  define output parameter p-doc-date-09   as character no-undo .
  define output parameter p-doc-code-10   as character no-undo .
  define output parameter p-doc-date-10   as character no-undo .

  define buffer buf_clients    for ub.clients .
  define buffer buf_sysconf    for ub.sysconf .
  define buffer buf_sys-ctrl   for ub.sys-ctrl .
  define buffer buf_user-login for ub.user-login .

  do
  on error undo, return error return-value
  :
    find first buf_sys-ctrl no-lock .
    find first buf_user-login no-lock
      where buf_user-login.db-num = buf_sys-ctrl.db-num
        and buf_user-login.status_    = {&uls-normal}
        and buf_user-login.user-login = p-user-login
      no-error .
    if not available buf_user-login
    then do:
      assign
        p-status        = '1':u
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
        p-status        = '1':u
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
        p-status        = '1':u
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
        p-status        = '1':u
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
        p-status        = '1':u
        p-error-message = substitute("Неправильный тип объекта &1 &2"
                                    ,p-obj-type
                                    ,v-obj-code
                                    )
      .
      return . /* --->>>--- */
    end.

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
        p-status        = '1':u
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
        p-status        = '1':u
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
        p-status        = '1':u
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
        p-status        = '1':u
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
        p-status        = '1':u
        p-error-message = substitute("Ошибка преобразования кода поставщика &1. &2"
                                    ,p-obj-code
                                    ,v-error-message
                                    )
      .
      return . /* --->>>--- */
    end.

    find first buf_clients no-lock
      where buf_clients.obj-type = p-cli-type
        and buf_clients.obj-code = v-cli-code
      no-error .
    if not available buf_clients
    then do:
      assign
        p-status        = '1':u
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
        p-status        = '1':u
        p-error-message = substitute("Не найдена фирма &1"
                                    ,v-host-code
                                    )
      .
      return . /* --->>>--- */
    end.

    if lookup(p-direction, '0,1,2,3') = 0
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Неизвестная команда позиционирования &1"
                                    ,p-direction
                                    )
      .
      return . /* --->>>--- */
    end.
    case p-doc-type
    :
      when 'ПТ':u
      then do:
        /* поставка в статусе поставка */
        if lookup(p-doc-status, 'поставка':u) = 0
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Не известный статус поставки &1"
                                        ,p-doc-status
                                        )
          .
          return . /* --->>>--- */
        end.

        define buffer buf_ord-doc-rcv for ub.ord-doc-rcv .

        define query q_ord-doc-rcv for buf_ord-doc-rcv scrolling .

        open query q_ord-doc-rcv for each buf_ord-doc-rcv no-lock
          where buf_ord-doc-rcv.obj-type = p-obj-type
            and buf_ord-doc-rcv.obj-code = v-obj-code
            and buf_ord-doc-rcv.status_  = {&ord-rcv}
            and buf_ord-doc-rcv.cli-type = p-cli-type
            and buf_ord-doc-rcv.cli-code = v-cli-code
            by buf_ord-doc-rcv.doc-date desc
            by buf_ord-doc-rcv.rcv-code desc
            .

        define variable v-forward-direction as logical   no-undo .
        define buffer reposition_ord-doc-rcv for ub.ord-doc-rcv .

        case p-direction :
          when '0':u
          then do:
            assign
              v-forward-direction = true
            .
            get first q_ord-doc-rcv .
          end.
          when '1':u
          then do:
            assign
              v-forward-direction = false
            .
            find first reposition_ord-doc-rcv no-lock
              where reposition_ord-doc-rcv.rcv-code = p-doc-code-first
              no-error .
            if available reposition_ord-doc-rcv
            then do:
              reposition q_ord-doc-rcv to rowid rowid(reposition_ord-doc-rcv) no-error .
              get next q_ord-doc-rcv .
              if not available buf_ord-doc-rcv
              then do:
                get first q_ord-doc-rcv .
              end.
              else do:
                get prev q_ord-doc-rcv .
                if not available buf_ord-doc-rcv
                then do:
                  assign
                    v-forward-direction = true
                  .
                  get first q_ord-doc-rcv .
                end.
              end.
            end.
          end.
          when '2':u
          then do:
            assign
              v-forward-direction = true
            .
            find first reposition_ord-doc-rcv no-lock
              where reposition_ord-doc-rcv.rcv-code = p-doc-code-last
              no-error .
            if available reposition_ord-doc-rcv
            then do:
              reposition q_ord-doc-rcv to rowid rowid(reposition_ord-doc-rcv) no-error .
              get next q_ord-doc-rcv .
              if not available buf_ord-doc-rcv
              then do:
                get first q_ord-doc-rcv .
              end.
              else do:
                get next q_ord-doc-rcv .
                if not available buf_ord-doc-rcv
                then do:
                  assign
                    v-forward-direction = false
                  .
                  get last q_ord-doc-rcv .
                end.
              end.
            end.
          end.
          when '3':u
          then do:
            assign
              v-forward-direction = false
            .
            get last q_ord-doc-rcv .
          end.
          otherwise do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Неизвестное значение переменной p-direction &1"
                                          ,p-direction
                                          )
            .
            return . /* --->>>--- */
          end.
        end.

        if not available buf_ord-doc-rcv
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        define buffer buf_temp-doc-list for temp-doc-list .

        for each buf_temp-doc-list
        on error undo, return error return-value
        :
          delete buf_temp-doc-list .
        end.

        define variable v-ind as integer   no-undo .

        scan_cycle:
        do v-ind = 1 to 10
        :
          if available buf_ord-doc-rcv
          then do:
            create buf_temp-doc-list .
            assign
              buf_temp-doc-list.temp-order    = (if v-forward-direction = true
                                                 then v-ind
                                                 else - v-ind
                                                )
              buf_temp-doc-list.temp-doc-code = buf_ord-doc-rcv.rcv-code
              buf_temp-doc-list.temp-doc-date = string(buf_ord-doc-rcv.doc-date, '99.99.9999':u)
            .
          end.

          if v-forward-direction = true
          then do:
            get next q_ord-doc-rcv .
          end.
          else do:
            get prev q_ord-doc-rcv .
          end.

          if not available buf_ord-doc-rcv
          then do:
            leave scan_cycle .
          end.
        end.

        define query q_temp-doc-list for buf_temp-doc-list .

        open query q_temp-doc-list for each buf_temp-doc-list
          by buf_temp-doc-list.temp-order
          .

        get first q_temp-doc-list .

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-01 = buf_temp-doc-list.temp-doc-code
            p-doc-date-01 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-02 = buf_temp-doc-list.temp-doc-code
            p-doc-date-02 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-03 = buf_temp-doc-list.temp-doc-code
            p-doc-date-03 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-04 = buf_temp-doc-list.temp-doc-code
            p-doc-date-04 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-05 = buf_temp-doc-list.temp-doc-code
            p-doc-date-05 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-06 = buf_temp-doc-list.temp-doc-code
            p-doc-date-06 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-07 = buf_temp-doc-list.temp-doc-code
            p-doc-date-07 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-08 = buf_temp-doc-list.temp-doc-code
            p-doc-date-08 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-09 = buf_temp-doc-list.temp-doc-code
            p-doc-date-09 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-10 = buf_temp-doc-list.temp-doc-code
            p-doc-date-10 = buf_temp-doc-list.temp-doc-date
          .
        end.

        assign
          p-status        = '0':u
          p-error-message = '':u
        .
        return . /* --->>>--- */
      end.
      when 'ПН':u
      then do:
        if lookup(p-doc-status, 'накл-':u + {&comma-char} + 'накл+':u) = 0
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Не известный статус документа внешнего прихода &1"
                                        ,p-doc-status
                                        )
          .
          return . /* --->>>--- */
        end.

        define variable v-flag as logical   no-undo .

        if p-doc-status = 'накл-':u
        then do:
          assign
            v-flag = false
          .
        end.
        if p-doc-status = 'накл+':u
        then do:
          assign
            v-flag = true
          .
        end.

        define buffer buf_trn-doc for ub.trn-doc .
        define query q_trn-doc for buf_trn-doc scrolling .

        open query q_trn-doc for each buf_trn-doc no-lock
          where buf_trn-doc.obj-type     = p-obj-type
            and buf_trn-doc.obj-code     = v-obj-code
            and buf_trn-doc.internal     = false
            and buf_trn-doc.doc-type     = {&income}
            and buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
            and buf_trn-doc.status_      = {&wayb}
            and buf_trn-doc.flag_        = v-flag
            and buf_trn-doc.host-code    = v-host-code
            and buf_trn-doc.cli-type     = p-cli-type
            and buf_trn-doc.cli-code     = v-cli-code
        by buf_trn-doc.doc-date desc
        by buf_trn-doc.doc-code desc
        .
        /* todo - исключать документы межфирменного прихода */

        define buffer reposition_ord-doc for ub.trn-doc .

        case p-direction :
          when '0':u
          then do:
            assign
              v-forward-direction = true
            .
            get first q_trn-doc .
          end.
          when '1':u
          then do:
            assign
              v-forward-direction = false
            .
            find first reposition_ord-doc no-lock
              where reposition_ord-doc.doc-code = p-doc-code-first
              no-error .
            if available reposition_ord-doc
            then do:
              reposition q_trn-doc to rowid rowid(reposition_ord-doc) no-error .
              get next q_trn-doc .
              if not available buf_trn-doc
              then do:
                get first q_trn-doc .
              end.
              else do:
                get prev q_trn-doc .
                if not available buf_trn-doc
                then do:
                  assign
                    v-forward-direction = true
                  .
                  get first q_trn-doc .
                end.
              end.
            end.
          end.
          when '2':u
          then do:
            assign
              v-forward-direction = true
            .
            find first reposition_ord-doc no-lock
              where reposition_ord-doc.doc-code = p-doc-code-last
              no-error .
            if available reposition_ord-doc
            then do:
              reposition q_trn-doc to rowid rowid(reposition_ord-doc) no-error .
              get next q_trn-doc .
              if not available buf_trn-doc
              then do:
                get first q_trn-doc .
              end.
              else do:
                get next q_trn-doc .
                if not available buf_trn-doc
                then do:
                    assign
                      v-forward-direction = false
                    .
                    get last q_trn-doc .
                end.
              end.
            end.
          end.
          when '3':u
          then do:
            assign
              v-forward-direction = false
            .
            get last q_trn-doc .
          end.
          otherwise do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Неизвестное значение переменной p-direction &1"
                                          ,p-direction
                                          )
            .
            return . /* --->>>--- */
          end.
        end.

        if not available buf_trn-doc
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        for each buf_temp-doc-list
        on error undo, return error return-value
        :
          delete buf_temp-doc-list .
        end.

        scan_cycle:
        do v-ind = 1 to 10
        :
          if available buf_trn-doc
          then do:
            create buf_temp-doc-list .
            assign
              buf_temp-doc-list.temp-order    = (if v-forward-direction = true
                                                 then v-ind
                                                 else - v-ind
                                                )
              buf_temp-doc-list.temp-doc-code = buf_trn-doc.doc-code
              buf_temp-doc-list.temp-doc-date = string(buf_trn-doc.doc-date, '99.99.9999':u)
            .
          end.

          if v-forward-direction = true
          then do:
            get next q_trn-doc .
          end.
          else do:
            get prev q_trn-doc .
          end.

          if not available buf_trn-doc
          then do:
            leave scan_cycle .
          end.
        end.

        open query q_temp-doc-list for each buf_temp-doc-list
          by buf_temp-doc-list.temp-order
          .

        get first q_temp-doc-list .

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-01 = buf_temp-doc-list.temp-doc-code
            p-doc-date-01 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-02 = buf_temp-doc-list.temp-doc-code
            p-doc-date-02 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-03 = buf_temp-doc-list.temp-doc-code
            p-doc-date-03 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-04 = buf_temp-doc-list.temp-doc-code
            p-doc-date-04 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-05 = buf_temp-doc-list.temp-doc-code
            p-doc-date-05 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-06 = buf_temp-doc-list.temp-doc-code
            p-doc-date-06 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-07 = buf_temp-doc-list.temp-doc-code
            p-doc-date-07 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-08 = buf_temp-doc-list.temp-doc-code
            p-doc-date-08 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-09 = buf_temp-doc-list.temp-doc-code
            p-doc-date-09 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-10 = buf_temp-doc-list.temp-doc-code
            p-doc-date-10 = buf_temp-doc-list.temp-doc-date
          .
        end.

        assign
          p-status        = '0':u
          p-error-message = '':u
        .
        return . /* --->>>--- */
      end.
      when 'ОР':U
      then do:
        /* заявка в статусе разрешен */
        if lookup(p-doc-status, 'запрос':u) = 0
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute( "Не известный статус заявки &1"
                                        , p-doc-status
                                        )
          .
          return . /* --->>>--- */
        end.

        define buffer buf_ord-doc   for ub.ord-doc.

        define query q_ord-doc for buf_ord-doc scrolling.
        /*
           TODO
             06/01/09 5:40
          По каким критериям сортировать список документов ?
        */
        open query q_ord-doc
          for each buf_ord-doc no-lock
            where buf_ord-doc.obj-type  = p-cli-type
              and buf_ord-doc.obj-code  = v-cli-code
              and buf_ord-doc.status_   = {&ord-req}
              and buf_ord-doc.doc-type  = {&o-r}
              and buf_ord-doc.cli-type  = p-obj-type
              and buf_ord-doc.cli-code  = v-obj-code
        by buf_ord-doc.doc-date desc
        by buf_ord-doc.doc-code desc
        .
        case p-direction :
          when '0':u
          then do:
            assign
              v-forward-direction = true
            .
            get first q_ord-doc .
          end.
          when '1':u
          then do:
            assign
              v-forward-direction = false
            .
            find first reposition_ord-doc no-lock
              where reposition_ord-doc.doc-code = p-doc-code-first
              no-error .
            if available reposition_ord-doc
            then do:
              reposition q_ord-doc to rowid rowid(reposition_ord-doc) no-error .
              get next q_ord-doc .
              if not available buf_ord-doc
              then do:
                get first q_ord-doc .
              end.
              else do:
                get prev q_ord-doc .
                if not available buf_ord-doc
                then do:
                  assign
                    v-forward-direction = true
                  .
                  get first q_ord-doc .
                end.
              end.
            end.
          end.
          when '2':u
          then do:
            assign
              v-forward-direction = true
            .
            find first reposition_ord-doc no-lock
              where reposition_ord-doc.doc-code = p-doc-code-last
              no-error .
            if available reposition_ord-doc
            then do:
              reposition q_ord-doc to rowid rowid(reposition_ord-doc) no-error .
              get next q_ord-doc .
              if not available buf_ord-doc
              then do:
                get first q_ord-doc .
              end.
              else do:
                get next q_ord-doc .
                if not available buf_ord-doc
                then do:
                    assign
                      v-forward-direction = false
                    .
                    get last q_ord-doc .
                end.
              end.
            end.
          end.
          when '3':u
          then do:
            assign
              v-forward-direction = false
            .
            get last q_ord-doc .
          end.
          otherwise do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Неизвестное значение переменной p-direction &1"
                                          ,p-direction
                                          )
            .
            return . /* --->>>--- */
          end.
        end.

        if not available buf_ord-doc
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        for each buf_temp-doc-list
        on error undo, return error return-value
        :
          delete buf_temp-doc-list .
        end.

        scan_cycle:
        do v-ind = 1 to 10
        :
          if available buf_ord-doc
          then do:
            create buf_temp-doc-list .
            assign
              buf_temp-doc-list.temp-order    = (if v-forward-direction = true
                                                 then v-ind
                                                 else - v-ind
                                                )
              buf_temp-doc-list.temp-doc-code = buf_ord-doc.doc-code
              buf_temp-doc-list.temp-doc-date = string(buf_ord-doc.doc-date, '99.99.9999':u)
            .
          end.

          if v-forward-direction = true
          then do:
            get next q_ord-doc .
          end.
          else do:
            get prev q_ord-doc .
          end.

          if not available buf_ord-doc
          then do:
            leave scan_cycle .
          end.
        end.

        open query q_temp-doc-list for each buf_temp-doc-list
          by buf_temp-doc-list.temp-order
          .

        get first q_temp-doc-list .

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-01 = buf_temp-doc-list.temp-doc-code
            p-doc-date-01 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-02 = buf_temp-doc-list.temp-doc-code
            p-doc-date-02 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-03 = buf_temp-doc-list.temp-doc-code
            p-doc-date-03 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-04 = buf_temp-doc-list.temp-doc-code
            p-doc-date-04 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-05 = buf_temp-doc-list.temp-doc-code
            p-doc-date-05 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-06 = buf_temp-doc-list.temp-doc-code
            p-doc-date-06 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-07 = buf_temp-doc-list.temp-doc-code
            p-doc-date-07 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-08 = buf_temp-doc-list.temp-doc-code
            p-doc-date-08 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-09 = buf_temp-doc-list.temp-doc-code
            p-doc-date-09 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-10 = buf_temp-doc-list.temp-doc-code
            p-doc-date-10 = buf_temp-doc-list.temp-doc-date
          .
        end.

        assign
          p-status        = '0':u
          p-error-message = '':u
        .
        return . /* --->>>--- */
      end.
      when 'РН':U
      then do:
        /* накладная в статусе накл-  */
        if lookup(p-doc-status, 'накл-':u) = 0
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute( "Не известный статус внешнего расходного документа &1"
                                        , p-doc-status
                                        )
          .
          return . /* --->>>--- */
        end.

        define buffer buf_tt-docs         for tt-docs.
        define buffer reposition_tt-docs  for tt-docs.
        define buffer buf_ord-chain       for ub.ord-chain.

        define query q_tt-docs for buf_tt-docs scrolling.

        empty temp-table tt-docs.

        for each buf_ord-doc no-lock
          where buf_ord-doc.obj-type  = p-cli-type
            and buf_ord-doc.obj-code  = v-cli-code
            and buf_ord-doc.status_   = {&ord-per}
            and buf_ord-doc.doc-type  = {&o-r}
            and buf_ord-doc.cli-type  = p-obj-type
            and buf_ord-doc.cli-code  = v-obj-code
        , each buf_ord-doc-rcv no-lock
            where buf_ord-doc-rcv.doc-code = buf_ord-doc.doc-code
        , each ub.ord-chain no-lock
            where ub.ord-chain.doc-code     = buf_ord-doc-rcv.rcv-code
              and ub.ord-chain.doc-type     = 'rcv'
              and ub.ord-chain.rel-doc-type = 'trn'
         , each buf_trn-doc no-lock
            where buf_trn-doc.doc-code = ub.ord-chain.rel-doc-code
              and buf_trn-doc.status_  = {&wayb}
              and buf_trn-doc.flag_    = no
        :
          create tt-docs.
          assign
            tt-docs.ord-doc-date = buf_ord-doc.doc-date
            tt-docs.ord-doc-code = buf_ord-doc.doc-code
            tt-docs.doc-date     = buf_trn-doc.doc-date
            tt-docs.doc-code     = buf_trn-doc.doc-code
          .
        end.

        open query q_tt-docs
          for each buf_tt-docs
          use-index sort
            by buf_tt-docs.ord-doc-date descending
            by buf_tt-docs.ord-doc-code descending
            by buf_tt-docs.doc-date     descending
            by buf_tt-docs.doc-code     descending
        .

        case p-direction :
          when '0':u
          then do:
            assign
              v-forward-direction = true
            .
            get first q_tt-docs.
          end.
          when '1':u
          then do:
            assign
              v-forward-direction = false
            .
            find first reposition_tt-docs no-lock
              where reposition_tt-docs.doc-code = p-doc-code-first
            no-error .
            if available reposition_tt-docs
            then do:
              reposition q_tt-docs to rowid rowid(reposition_tt-docs) no-error .
              get next q_tt-docs .
              if not available buf_tt-docs
              then do:
                get first q_tt-docs .
              end.
              else do:
                get prev q_tt-docs .
                if not available buf_tt-docs
                then do:
                  assign
                    v-forward-direction = true
                  .
                  get first q_tt-docs .
                end.
              end.
            end.
          end.
          when '2':u
          then do:
            assign
              v-forward-direction = true
            .
            find first reposition_tt-docs no-lock
              where reposition_tt-docs.doc-code = p-doc-code-last
            no-error .
            if available reposition_tt-docs
            then do:
              reposition q_tt-docs to rowid rowid(reposition_tt-docs) no-error .
              get next q_tt-docs .
              if not available buf_tt-docs
              then do:
                get first q_tt-docs .
              end.
              else do:
                get next q_tt-docs .
                if not available buf_tt-docs
                then do:
                    assign
                      v-forward-direction = false
                    .
                    get last q_tt-docs .
                end.
              end.
            end.
          end.
          when '3':u
          then do:
            assign
              v-forward-direction = false
            .
            get last q_tt-docs .
          end.
          otherwise do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Неизвестное значение переменной p-direction &1"
                                          ,p-direction
                                          )
            .
            return . /* --->>>--- */
          end.
        end. /* case p-direction : */

        if not available buf_tt-docs
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        for each buf_temp-doc-list
        on error undo, return error return-value
        :
          delete buf_temp-doc-list .
        end.

        scan_cycle:
        do v-ind = 1 to 10
        :
          if available buf_tt-docs
          then do:
            create buf_temp-doc-list .
            assign
              buf_temp-doc-list.temp-order    = (if v-forward-direction = true
                                                 then v-ind
                                                 else - v-ind
                                                )
              buf_temp-doc-list.temp-doc-code = buf_tt-docs.doc-code
              buf_temp-doc-list.temp-doc-date = string(buf_tt-docs.doc-date, '99.99.9999':u)
            .
          end.

          if v-forward-direction = true
          then do:
            get next q_tt-docs .
          end.
          else do:
            get prev q_tt-docs .
          end.

          if not available buf_tt-docs
          then do:
            leave scan_cycle .
          end.
        end.

        empty temp-table buf_tt-docs.

        open query q_temp-doc-list for each buf_temp-doc-list
          by buf_temp-doc-list.temp-order
        .
        get first q_temp-doc-list .

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-01 = buf_temp-doc-list.temp-doc-code
            p-doc-date-01 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-02 = buf_temp-doc-list.temp-doc-code
            p-doc-date-02 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-03 = buf_temp-doc-list.temp-doc-code
            p-doc-date-03 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-04 = buf_temp-doc-list.temp-doc-code
            p-doc-date-04 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-05 = buf_temp-doc-list.temp-doc-code
            p-doc-date-05 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-06 = buf_temp-doc-list.temp-doc-code
            p-doc-date-06 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-07 = buf_temp-doc-list.temp-doc-code
            p-doc-date-07 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-08 = buf_temp-doc-list.temp-doc-code
            p-doc-date-08 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-09 = buf_temp-doc-list.temp-doc-code
            p-doc-date-09 = buf_temp-doc-list.temp-doc-date
          .
        end.

        get next q_temp-doc-list .

        if not available buf_temp-doc-list
        then do:
          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.

        if available buf_temp-doc-list
        then do:
          assign
            p-doc-code-10 = buf_temp-doc-list.temp-doc-code
            p-doc-date-10 = buf_temp-doc-list.temp-doc-date
          .
        end.

        assign
          p-status        = '0':u
          p-error-message = '':u
        .
        return . /* --->>>--- */

      end. /* when 'РН':U */
      otherwise do:
        assign
          p-status        = '1':u
          p-error-message = substitute("Неизвестный тип документа &1"
                                      ,p-doc-type
                                      )
        .
        return . /* --->>>--- */
      end.
    end case .

    assign
      p-status        = '1':u
      p-error-message = "rt-req07.p. Неизвестная ошибка"
    .
    return . /* --->>>--- */
  end.


end procedure. /* check-data */