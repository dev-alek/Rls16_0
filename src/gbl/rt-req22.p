block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rt-req22.p $
$Archive: gbl/rt-req22.p $

Обрабока запроса радиотерминала 22. Приемка товара. Выбор строки документа.

Автор: Хныкин Павел Андреевич
Дата создания: 02/12/08
Author: Pavel Khnykin
Creation date: 02/12/08

*/
define input parameter parparentproc    as widget-handle  no-undo .
define input parameter p-directory-out  as character      no-undo .
define input parameter p-file-name      as character      no-undo .
define input parameter p-session-valid  as logical        no-undo .
define input parameter p-error-message  as character      no-undo .
define input parameter p-user-login     as character      no-undo .
define input parameter p-obj-type       as character      no-undo .
define input parameter p-obj-code       as character      no-undo .
define input parameter p-host-code      as character      no-undo .
define input parameter p-cli-type       as character      no-undo .
define input parameter p-cli-code       as character      no-undo .
define input parameter p-doc-type       as character      no-undo .
define input parameter p-doc-code       as character      no-undo .
define input parameter p-doc-status     as character      no-undo .
define input parameter p-gds-code       as character      no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-req22.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-req22.p $":U .
define variable vss-description as character no-undo init "Обрабока запроса радиотерминала 20. Приемка товара. Список строк документа поставки".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/integerm.i }
{ cmp/library.i  }
{ gbl/rtencode.i }
{ gbl/rt-cnvdc.i }

define stream sout.

define variable v-status  as character no-undo .
define variable v-message as character no-undo .

do on error undo, return error return-value
:
  if p-session-valid = yes then do:
    run check-data in this-procedure
    ( output v-status
    , output v-message
    ) no-error .
    if error-status :error then do:
      undo, return error substitute("ошибка при вызове функции check-data. &1, &2"
                                  ,error-status :get-message(1)
                                  ,return-value
                                  ) .
    end.
  end.
  else do:
    assign
      v-status  = '1'
      v-message = p-error-message
    .
  end.

  define variable v-temp-file-name as character no-undo .

  assign
    v-temp-file-name = entry(1, p-file-name, '.':u) + '.tmp':u
  .
  output stream sout to value(p-directory-out + '/':u + v-temp-file-name) .

  put stream sout unformatted substitute('status:&1',       rtencode(v-status)    )
    + {&new-line} .
  put stream sout unformatted substitute('message:&1',      rtencode(v-message)   )
    + {&new-line} .

  output stream sout close .

  os-delete value(p-directory-out + '/':u + p-file-name) .
  os-rename value(p-directory-out + '/':u + v-temp-file-name)
            value(p-directory-out + '/':u + p-file-name)
            .
end.


procedure check-data :
  define output parameter p-status  as character no-undo .
  define output parameter p-message as character no-undo .


  define buffer buf_clients       for ub.clients .
  define buffer buf_sysconf       for ub.sysconf .
  define buffer buf_sys-ctrl      for ub.sys-ctrl .
  define buffer buf_user-login    for ub.user-login .
  define buffer buf_goods         for ub.goods.
  define buffer buf_ord-doc       for ub.ord-doc.
  define buffer buf_ord-line      for ub.ord-line.
  define buffer buf_ord-doc-rcv   for ub.ord-doc-rcv.
  define buffer buf_ord-line-rcv  for ub.ord-line-rcv.
  define buffer buf_trn-doc       for ub.trn-doc.
  define buffer buf_doc-line      for ub.doc-line.

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
        p-message = substitute("Неизвестный пользователь &1"
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
        p-message = "Не задан код объекта"
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
        p-message = substitute("Ошибка преобразования кода объекта &1. &2"
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
        p-message = substitute("Не найден объект &1 &2"
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
        p-message = substitute("Неправильный тип объекта &1 &2"
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
        p-message = substitute("Ошибка преобразования кода фирмы &1. &2"
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
        p-message = substitute("Заданный код фирмы &1 отличается от кода фирмы &2 объекта &3 &4."
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
        p-message = substitute("Пользователю не доступен объект &1 &2"
                                    ,buf_clients.obj-type
                                    ,buf_clients.obj-code
                                    )
      .
      return . /* --->>>--- */
    end.

    /* проверить права пользователя на работу с документами */
    define variable v-valid-act   as logical   no-undo .

    { gbl/chk-actg.i
      buf_sys-ctrl.db-num
      buf_user-login.user-id
      {&action-head-code-main}
      'actn_rt-edit-doc_work':U
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
        p-status        = '1'
        p-message = substitute( "&1" , return-value )
      .
      return . /* --->>>--- */
    end.

/*    define variable v-cli-code as integer   no-undo .*/

/*    if p-cli-code = "" then do:*/
/*      assign*/
/*        p-status        = '1':u*/
/*        p-message = "Не задан код поставщика"*/
/*      .*/
/*      return . /* --->>>--- */*/
/*    end.*/

/*    run integerm in this-procedure*/
/*      (input  p-cli-code      /* p-string      */*/
/*      ,input  false           /* p-allow-sign  */*/
/*      ,input  false           /* p-allow-comma */*/
/*      ,output v-cli-code      /* p-value       */*/
/*      ,output v-data-valid    /* p-data-valid  */*/
/*      ,output v-error-message /* p-message     */*/
/*      ) .*/
/*    if v-data-valid <> true then do:*/
/*      assign*/
/*        p-status        = '1':u*/
/*        p-message = substitute("Ошибка преобразования кода поставщика &1. &2"*/
/*                                    ,p-obj-code*/
/*                                    ,v-error-message*/
/*                                    )*/
/*      .*/
/*      return . /* --->>>--- */*/
/*    end.*/

/*    find first buf_clients no-lock*/
/*      where buf_clients.obj-type = p-cli-type*/
/*        and buf_clients.obj-code = v-cli-code*/
/*    no-error .*/

/*    if not available buf_clients*/
/*    then do:*/
/*      assign*/
/*        p-status        = '1':u*/
/*        p-message = substitute( "Не найден поставщик &1 &2"*/
/*                                    , p-cli-type*/
/*                                    , p-cli-code*/
/*                                    )*/
/*      .*/
/*      return . /* --->>>--- */*/
/*    end.*/

    define variable v-gds-code as integer   no-undo .

    run integerm in this-procedure
      (input  p-gds-code      /* p-string      */
      ,input  false           /* p-allow-sign  */
      ,input  false           /* p-allow-comma */
      ,output v-gds-code      /* p-value       */
      ,output v-data-valid    /* p-data-valid  */
      ,output v-error-message /* p-message     */
      ) .
    if v-data-valid <> true then do:
      assign
        p-status        = '1':u
        p-message = substitute("Ошибка преобразования кода товара &1. &2"
                                    ,p-gds-code
                                    ,v-error-message
                                    )
      .
      return . /* --->>>--- */
    end.

    find first buf_goods no-lock
      where buf_goods.gds-code = v-gds-code
    no-error .
    if not available buf_goods
    then do:
      assign
        p-status        = '1':u
        p-message = substitute("Не найден товар с кодом &1."
                                    ,p-gds-code
                                    )
      .
      return . /* --->>>--- */
    end.

    define variable v-search-doc-code as character no-undo .

    run rt-cnvdc_decode in this-procedure ( input   p-doc-code
                                          , output  v-search-doc-code
                                          ) .

    case p-doc-type :
      when 'ПТ'then do:
/*        /* поставка в статусе поставка */*/
/*        if lookup(p-doc-status, 'поставка':u) = 0*/
/*        then do:*/
/*          assign*/
/*            p-status        = '1':u*/
/*            p-message = substitute("Не известный статус поставки &1"*/
/*                                        ,p-doc-status*/
/*                                        )*/
/*          .*/
/*          return . /* --->>>--- */*/
/*        end.*/

        find first buf_ord-doc-rcv no-lock
          where buf_ord-doc-rcv.rcv-code = v-search-doc-code
        no-error .
        if not available buf_ord-doc-rcv
        then do:
          assign
            p-status        = '1':u
            p-message = substitute("Не найден документ поставки &1"
                                        ,v-search-doc-code
                                        )
          .
          return . /* --->>>--- */
        end.

        find first buf_ord-doc no-lock
          where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code
        no-error .
        if not available buf_ord-doc then do:
          assign
            p-status        = '1':u
            p-message = substitute("Не найден документ заказа &1 на основании документа поставки &2"
                                        ,buf_ord-doc-rcv.doc-code
                                        ,v-search-doc-code
                                        )
          .
          return . /* --->>>--- */
        end.

        find first buf_ord-line-rcv no-lock
          where buf_ord-line-rcv.doc-code   = buf_ord-doc-rcv.doc-code
            and buf_ord-line-rcv.rcv-code   = buf_ord-doc-rcv.rcv-code
            and buf_ord-line-rcv.artic      = buf_goods.artic
            and buf_ord-line-rcv.prod-type  = buf_goods.prod-type
            and buf_ord-line-rcv.prod-code  = buf_goods.prod-code
        no-error .
        if not available buf_ord-line-rcv
        then do:
          assign
            p-status        = '1':u
            p-message = substitute("В документе &1 не найден товар с кодом &2."
                                        ,v-search-doc-code
                                        ,buf_goods.gds-code
                                        )
          .
          return . /* --->>>--- */
        end.
        else do:
          assign
            p-status        = '0':u
            p-message = '':u
          .
        end.
      end.
      when 'ПН':U or
      when 'РН':U
      then do:
/*        if lookup(p-doc-status, 'накл-':u + {&comma-char} + 'накл+':u) = 0*/
/*        then do:*/
/*          assign*/
/*            p-status        = '1':u*/
/*            p-message = substitute("Не известный статус документа внешнего прихода &1"*/
/*                                        ,p-doc-status*/
/*                                        )*/
/*          .*/
/*          return . /* --->>>--- */*/
/*        end.*/
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = v-search-doc-code
        no-error .
        if not available buf_trn-doc
        then do:
          assign
            p-status        = '1':u
            p-message = substitute("Не найден документ &1"
                                        ,v-search-doc-code
                                        )
          .
          return . /* --->>>--- */
        end.
        find first buf_doc-line no-lock
          where buf_doc-line.doc-code   = buf_trn-doc.doc-code
            and buf_doc-line.artic      = buf_goods.artic
            and buf_doc-line.prod-type  = buf_goods.prod-type
            and buf_doc-line.prod-code  = buf_goods.prod-code
        no-error .
        if not available buf_doc-line
        then do:
          assign
            p-status        = '1':u
            p-message = substitute("В документе &1 не найден товар с кодом &2."
                                        ,v-search-doc-code
                                        ,buf_goods.gds-code
                                        )
          .
          return . /* --->>>--- */
        end.
        else do:
          assign
            p-status        = '0':u
            p-message = '':u
          .
        end.
      end.
      when 'ОР'then do:
        /* заявка */
        find first buf_ord-doc no-lock
          where buf_ord-doc.doc-code = v-search-doc-code
        no-error .
        if not available buf_ord-doc
        then do:
          assign
            p-status        = '1':u
            p-message = substitute("Не найден документ &1"
                                  ,v-search-doc-code
                                  )
          .
          return . /* --->>>--- */
        end.

        find first buf_ord-line no-lock
          where buf_ord-line.doc-code   = buf_ord-doc.doc-code
            and buf_ord-line.artic      = buf_goods.artic
            and buf_ord-line.prod-type  = buf_goods.prod-type
            and buf_ord-line.prod-code  = buf_goods.prod-code
        no-error .
        if not available buf_ord-line
        then do:
          assign
            p-status        = '1':u
            p-message = substitute("В документе &1 не найден товар с кодом &2."
                                  ,v-search-doc-code
                                  ,buf_goods.gds-code
                                  )
          .
          return . /* --->>>--- */
        end.
        else do:
          assign
            p-status        = '0':u
            p-message = '':u
          .
        end.
      end.
      otherwise do:
        assign
          p-status        = '1':u
          p-message = substitute("Неизвестный тип документа &1"
                                      ,p-doc-type
                                      )
        .
      end.
    end case.
end.
end procedure. /* check-data */