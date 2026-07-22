block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rt-req21.p $
$Archive: gbl/rt-req21.p $

Обрабока запроса радиотерминала 21. Приемка товара. Информация о товаре по коду товара.

Автор: Хныкин Павел Андреевич
Дата создания: 02/01/08
Author: Pavel Khnykin
Creation date: 02/01/08

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
define input parameter p-doc-code       as character      no-undo .
define input parameter p-doc-type       as character      no-undo .
define input parameter p-gds-code       as character      no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-req21.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-req21.p $":U .
define variable vss-description as character no-undo init "Обрабока запроса радиотерминала 21. Приемка товара. Информация о товаре по коду товара.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/integerm.i }
{ cmp/library.i  }
{ gbl/rtencode.i }
{ gbl/rt-cnvdc.i }

define stream sout.

define variable v-status      as character no-undo .
define variable v-message     as character no-undo .
define variable v-artic       as character no-undo .
define variable v-name        as character no-undo .
define variable v-prod-name   as character no-undo .
define variable v-doc-qnty    as character no-undo .
define variable v-unit-base   as character no-undo .
define variable v-doc-sum     as character no-undo .
define variable v-curr-abbr   as character no-undo .
define variable v-last-date   as character no-undo .
define variable v-price-docf  as character no-undo .
define variable v-bar-code    as character no-undo .

do on error undo, return error return-value
:

  if p-session-valid = yes then do:
    run check-data in this-procedure
      (output v-status
      ,output v-message
      ,output v-artic
      ,output v-name
      ,output v-prod-name
      ,output v-doc-qnty
      ,output v-unit-base
      ,output v-doc-sum
      ,output v-curr-abbr
      ,output v-last-date
      ,output v-price-docf
      ,output v-bar-code
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
      v-status      = '1':U
      v-message     = p-error-message
      v-artic       = '':U
      v-name        = '':U
      v-prod-name   = '':U
      v-doc-qnty    = '':U
      v-unit-base   = '':U
      v-doc-sum     = '':U
      v-curr-abbr   = '':U
      v-last-date   = '':U
      v-price-docf  = '':u
      v-bar-code    = '':u
    .
  end.

  define variable v-temp-file-name as character no-undo .

  assign
    v-temp-file-name = entry(1, p-file-name, '.':u) + '.tmp':u
  .
  output stream sout to value(p-directory-out + '/':u + v-temp-file-name) .

  put stream sout unformatted substitute('status:&1',       rtencode(v-status)      )
    + {&new-line} .
  put stream sout unformatted substitute('message:&1',      rtencode(v-message)     )
    + {&new-line} .
  put stream sout unformatted substitute('artic:&1',        rtencode(v-artic)       )
    + {&new-line} .
  put stream sout unformatted substitute('name:&1',         rtencode(v-name)        )
    + {&new-line} .
  put stream sout unformatted substitute('prod_name:&1',    rtencode(v-prod-name)   )
    + {&new-line} .
  put stream sout unformatted substitute('doc_qnty:&1',     rtencode(v-doc-qnty)    )
    + {&new-line} .
  put stream sout unformatted substitute('unit_base:&1',    rtencode(v-unit-base)   )
    + {&new-line} .
  put stream sout unformatted substitute('doc_sum:&1',      rtencode(v-doc-sum)     )
    + {&new-line} .
  put stream sout unformatted substitute('curr_abbr:&1',    rtencode(v-curr-abbr)   )
    + {&new-line} .
  put stream sout unformatted substitute('deadline_date:&1', rtencode(v-last-date)  )
    + {&new-line} .
  put stream sout unformatted substitute('price_docf:&1', rtencode(v-price-docf)    )
    + {&new-line} .
  put stream sout unformatted substitute('bar_code:&1',   rtencode(v-bar-code)      )
    + {&new-line} .

  output stream sout close .

  os-delete value(p-directory-out + '/':u + p-file-name) .
  os-rename value(p-directory-out + '/':u + v-temp-file-name)
            value(p-directory-out + '/':u + p-file-name)
            .
end.

procedure check-data :
  define output parameter p-status      as character no-undo .
  define output parameter p-message     as character no-undo .
  define output parameter p-artic       as character no-undo .
  define output parameter p-name        as character no-undo .
  define output parameter p-prod-name   as character no-undo .
  define output parameter p-doc-qnty    as character no-undo .
  define output parameter p-unit-base   as character no-undo .
  define output parameter p-doc-sum     as character no-undo .
  define output parameter p-curr-abbr   as character no-undo .
  define output parameter p-last-date   as character no-undo .
  define output parameter p-price-docf  as character no-undo .
  define output parameter p-bar-code    as character no-undo .

  define buffer buf_clients       for ub.clients .
  define buffer buf_sysconf       for ub.sysconf .
  define buffer buf_sys-ctrl      for ub.sys-ctrl .
  define buffer buf_user-login    for ub.user-login .
  define buffer buf_goods         for ub.goods.
  define buffer buf_trn-doc       for ub.trn-doc.
  define buffer buf_doc-line      for ub.doc-line.
  define buffer buf_ord-doc       for ub.ord-doc .
  define buffer buf_ord-line      for ub.ord-line.
  define buffer buf_ord-doc-rcv   for ub.ord-doc-rcv.
  define buffer buf_ord-line-rcv  for ub.ord-line-rcv.
  define buffer buf_currency      for ub.currency .
  define buffer buf_parts         for ub.parts.
  define buffer buf_bar-code      for ub.bar-code.

  define variable v-price-cli     as decimal   no-undo .
  define variable v-price-base    as decimal   no-undo .
  define variable v-price-rubl    as decimal   no-undo .
  define variable v-vat-pc        as decimal   no-undo .
  define variable v-road-tax      as decimal   no-undo .
  define variable v-excise        as decimal   no-undo .
  define variable v-prod-name     as character no-undo .
  define variable v-last-date     as date      no-undo .
  define variable v-b-code        as integer   no-undo .
  define variable v-prod-type     as character no-undo .
  define variable v-prod-code     as integer   no-undo .



do
on error undo, return error return-value
:
    assign
      p-last-date = "":u
      p-price-docf = "":u
    .
    find first buf_sys-ctrl no-lock .
    find first buf_user-login no-lock
      where buf_user-login.db-num = buf_sys-ctrl.db-num
        and buf_user-login.status_    = {&uls-normal}
        and buf_user-login.user-login = p-user-login
      no-error .
    if not available buf_user-login
    then do:
      assign
        p-status  = '1':u
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
        p-status  = '1':u
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
        p-status  = '1':u
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
        p-status  = '1':u
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
        p-status  = '1':u
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
        p-status  = '1':u
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
        p-status  = '1':u
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


    if p-gds-code = "" then do:
      assign
        p-status  = '1':u
        p-message = "Не задан код товара"
      .
      return . /* --->>>--- */
    end.

    define variable v-gds-code as integer   no-undo .

    run integerm in this-procedure
      (input  p-gds-code      /* p-string      */
      ,input  false           /* p-allow-sign  */
      ,input  false           /* p-allow-comma */
      ,output v-gds-code      /* p-value       */
      ,output v-data-valid    /* p-data-valid  */
      ,output v-error-message /* p-message     */
      ) .
    if v-data-valid <> true
    then do:
      assign
        p-status  = '1':u
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
    if not available buf_goods then do:
      assign
        p-status  = '1':u
        p-message = substitute("Не найден товар с кодом &1."
                              ,p-gds-code
                              )
      .
    end.

    find first buf_bar-code no-lock
      where buf_bar-code.gds-code = buf_goods.gds-code
    no-error .
    if not available buf_bar-code
    then do:
      assign
        p-status  = '1':u
        p-message = substitute("Не найден основной бар-код ддля товара с кодом &1."
                              ,p-gds-code
                              )
      .
    end.

    assign
      p-bar-code = string(buf_bar-code.b-code)
    .

    find first buf_clients no-lock
      where buf_clients.obj-type = buf_goods.prod-type
        and buf_clients.obj-code = buf_goods.prod-code
    no-error .
    if not available buf_clients
    then do:
      assign
        p-status  = '2':u
        p-message = substitute("Ошибка при поиске записи поставщика &1 &2 для товара с кодом &3"
                              ,buf_goods.prod-type
                              ,buf_goods.prod-code
                              ,buf_goods.gds-code
                              )
      .
      return . /* --->>>--- */
    end.
    assign
      v-prod-name = buf_clients.obj-name
    .

    if p-doc-code = "" then do:
      assign
        p-status  = '1':u
        p-message = "Не задан код документа"
      .
      return . /* --->>>--- */
    end.

    define variable v-search-doc-code as character no-undo .

    run rt-cnvdc_decode in this-procedure ( input   p-doc-code
                                          , output  v-search-doc-code
                                          ) .
    case p-doc-type
    :
      when 'ПТ':u
      then do:
        find first buf_ord-doc-rcv no-lock
          where buf_ord-doc-rcv.rcv-code = v-search-doc-code
        no-error .
        if not available buf_ord-doc-rcv
        then do:
          assign
            p-status  = '1':u
            p-message = substitute( "Не найден код документа поставки &1"
                                  , v-search-doc-code
                                  )

          .
          return . /* --->>>--- */
        end.

        find first buf_ord-doc no-lock
          where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code
        no-error .
        if not available buf_ord-doc then do:
          assign
            p-status  = '1':u
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
            p-status  = '1':u
            p-message = substitute("В документе &1 не найден товар с кодом &2"
                                  ,v-search-doc-code
                                  ,buf_goods.gds-code
                                  )
          .
          return . /* --->>>--- */
        end.

        find first buf_currency no-lock
          where buf_currency.curr-code = buf_ord-doc-rcv.exch-code
        no-error .
        if not available buf_currency
        then do:
          assign
            p-status  = '1'
            p-message = substitute('Не найдена валюта с кодом &1. Поставка &2'
                                  ,buf_ord-doc-rcv.exch-code
                                  ,buf_ord-doc-rcv.doc-code
                                  )
          .
          return . /* --->>>--- */
        end.

        assign
          p-status      = '0'
          p-message     = ''
          p-artic       = substitute( "&1" , buf_goods.artic                                                                       )
          p-name        = substitute( "&1" , buf_goods.gds-name                                                                    )
          p-prod-name   = substitute( "&1" , v-prod-name                                                                           )
          p-doc-qnty    = substitute( "&1" , buf_ord-line-rcv.qnty                                                                 )
          p-unit-base   = substitute( "&1" , buf_goods.unit-base                                                                   )
          p-doc-sum     = substitute( "&1" , (buf_ord-line-rcv.qnty * buf_ord-line-rcv.price-cli) / buf_ord-line-rcv.cli-base-rate )
          p-curr-abbr   = substitute( "&1" , buf_currency.curr-abbr                                                                )
          p-price-docf  = substitute( "&1" , buf_ord-line-rcv.price-cli                                                            )
        .
      end.
      when 'ПН':u
      then do:

        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = v-search-doc-code
        no-error .
        if not available buf_trn-doc then do:
          assign
            p-status  = '1':u
            p-message = substitute("Не найдена накладная с кодом &1"
                                  ,v-search-doc-code
                                  )
          .
          return . /* --->>>--- */
        end.
        if buf_trn-doc.status_ <> {&wayb} then do:
          assign
            p-status  = '1':u
            p-message = substitute("Документ &1 не в статусе &2 "
                                  ,v-search-doc-code
                                  , {&wayb}
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
        if not available buf_doc-line then do:
          assign
            p-status  = '1':u
            p-message = substitute("В документе &1 отсутствует товар с кодом &2"
                                  ,v-search-doc-code
                                  ,p-gds-code
                                  )
          .
          return . /* --->>>--- */
        end.

        find first buf_currency no-lock
          where buf_currency.curr-code = buf_trn-doc.exch-code
        no-error .
        if not available buf_currency
        then do:
          assign
            p-status  = '1'
            p-message = substitute('Не найдена валюта с кодом &1. Поставка &2'
                                  ,buf_trn-doc.exch-code
                                  ,buf_trn-doc.doc-code
                                  )
          .
          return . /* --->>>--- */
        end.

        for each buf_parts no-lock
          where buf_parts.obj-type  = buf_doc-line.obj-type
            and buf_parts.obj-code  = buf_doc-line.obj-code
            and buf_parts.artic     = buf_doc-line.artic
            and buf_parts.prod-type = buf_doc-line.prod-type
            and buf_parts.prod-code = buf_doc-line.prod-code
            and buf_parts.in-code   = buf_doc-line.doc-code
        :
          if  buf_parts.last-date <> ?
          and ( v-last-date = ?
               or
                  (v-last-date <> ?
                  and
                  buf_parts.last-date < v-last-date
                  )
              )
          then do:
            assign
              v-last-date = buf_parts.last-date
            .
          end.
        end. /* for each buf_parts no-lock */

        assign
          p-status      = '0'
          p-message     = ''
          p-artic       = substitute( "&1" , buf_goods.artic                                                               )
          p-name        = substitute( "&1" , buf_goods.gds-name                                                            )
          p-prod-name   = substitute( "&1" , v-prod-name                                                                   )
          p-doc-qnty    = substitute( "&1" , buf_doc-line.doc-qnty                                                         )
          p-unit-base   = substitute( "&1" , buf_goods.unit-base                                                           )
          p-doc-sum     = substitute( "&1" , (buf_doc-line.cli-qnty * buf_doc-line.price-cli) / buf_doc-line.cli-base-rate )
          p-curr-abbr   = substitute( "&1" , buf_currency.curr-abbr                                                        )
          p-last-date   = ( if v-last-date = ? then "" else string( v-last-date , "99.99.9999" )                           )
        .
      end.
      when 'ОР':u
      then do:
        find first buf_ord-doc exclusive-lock
          where buf_ord-doc.doc-code = v-search-doc-code
        no-error .
        if not available buf_ord-doc
        then do:
          assign
            p-status  = '1':u
            p-message = substitute( "Не найден код документа &1"
                                  , v-search-doc-code
                                  )
          .
          return . /* --->>>--- */
        end.

        if buf_ord-doc.cli-type <> p-obj-type
        or buf_ord-doc.cli-code <> v-obj-code
        then do:
          assign
            p-status        = '3'
            p-error-message = substitute("Документ &1 предназначен объекту &2 &3. Текущий объект &4 &5"
                                        ,v-search-doc-code
                                        ,buf_ord-doc.cli-type
                                        ,buf_ord-doc.cli-code
                                        ,p-obj-type
                                        ,v-obj-code
                                        )
          .
          return . /* --->>>--- */
        end.

        if buf_ord-doc.status_ <> {&ord-req}
        then do:
          assign
            p-status        = '3'
            p-error-message = substitute("Статус документа &1 отличен от &2. Невозможно редактировать количество"
                                        ,v-search-doc-code
                                        ,{&ord-req}
                                        )
          .
          return . /* --->>>--- */
        end.

        run gbl/rt-doced.p
          (input  p-doc-type + '|':u + buf_ord-doc.doc-code
          ,input  buf_user-login.user-id
          ,input  '':u
          ,input  'check':u
          ,input "":U
          ,output p-status
          ,output p-error-message
          ) .
        if p-status <> '1':u
        then do:
          if p-status = '3':u
          then do:
            assign
              p-status = '1':u
            .
            return . /* --->>>--- */
          end.
          assign
            p-status = '1':u
            p-error-message = substitute("Неизвестный статус &1 поставки &2"
                                        ,p-status
                                        ,buf_ord-doc.doc-code
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
            p-status  = '1':u
            p-message = substitute("В документе &1 не найден товар с кодом &2"
                                  ,v-search-doc-code
                                  ,buf_goods.gds-code
                                  )
          .
          return . /* --->>>--- */
        end.

        /* распознать штрих-код и проверить наличие товара в документе */
        run gbl/rt-bcode.p
          (input  parparentproc
          ,input  p-doc-type + '|':u + buf_ord-doc.doc-code
          ,input  p-bar-code
          ,input  0
          ,input  0
          ,input  no
          ,output p-status
          ,output p-error-message
          ,output v-b-code
          ,output p-artic
          ,output p-name
          ,output v-prod-type
          ,output v-prod-code
          ,output p-prod-name
          ,output p-doc-qnty
          ,output p-unit-base
          ,output p-doc-sum
          ,output p-curr-abbr
          ,output v-last-date
          ,output p-price-docf
          ) .
        if p-status <> '0':u
        then do:
          assign
            p-status = '1':u
          .
          return . /* --->>>--- */
        end.

        find first buf_currency no-lock
          where buf_currency.curr-code = buf_ord-doc.exch-code
        no-error .
        if not available buf_currency
        then do:
          assign
            p-status  = '1'
            p-message = substitute('Не найдена валюта с кодом &1. Поставка &2'
                                  ,buf_ord-doc.exch-code
                                  ,buf_ord-doc.doc-code
                                  )
          .
          return . /* --->>>--- */
        end.

        assign
          p-status      = '0'
          p-message     = ''
        .
      end.
      when 'РН':U
      then do:
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = v-search-doc-code
        no-error .
        if not available buf_trn-doc then do:
          assign
            p-status  = '1':u
            p-message = substitute("Не найдена накладная с кодом &1"
                                  ,v-search-doc-code
                                  )
          .
          return . /* --->>>--- */
        end.
        if buf_trn-doc.status_ <> {&wayb}
        then do:
          assign
            p-status  = '1':u
            p-message = substitute("Документ &1 не в статусе &2"
                                  ,v-search-doc-code
                                  , {&wayb}
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
        if not available buf_doc-line then do:
          assign
            p-status  = '1':u
            p-message = substitute("В документе &1 отсутствует товар с кодом &2"
                                  ,v-search-doc-code
                                  ,p-gds-code
                                  )
          .
          return . /* --->>>--- */
        end.

        find first buf_currency no-lock
          where buf_currency.curr-code = buf_trn-doc.exch-code
        no-error .
        if not available buf_currency
        then do:
          assign
            p-status  = '1'
            p-message = substitute('Не найдена валюта с кодом &1. Поставка &2'
                                  ,buf_trn-doc.exch-code
                                  ,buf_trn-doc.doc-code
                                  )
          .
          return . /* --->>>--- */
        end.

        for each buf_parts no-lock
          where buf_parts.obj-type  = buf_doc-line.obj-type
            and buf_parts.obj-code  = buf_doc-line.obj-code
            and buf_parts.artic     = buf_doc-line.artic
            and buf_parts.prod-type = buf_doc-line.prod-type
            and buf_parts.prod-code = buf_doc-line.prod-code
            and buf_parts.in-code   = buf_doc-line.doc-code
        :
          if  buf_parts.last-date <> ?
          and ( v-last-date = ?
               or
                  (v-last-date <> ?
                  and
                  buf_parts.last-date < v-last-date
                  )
              )
          then do:
            assign
              v-last-date = buf_parts.last-date
            .
          end.
        end. /* for each buf_parts no-lock */

        assign
          p-status      = '0'
          p-message     = ''
          p-artic       = substitute( "&1" , buf_goods.artic                                                               )
          p-name        = substitute( "&1" , buf_goods.gds-name                                                            )
          p-prod-name   = substitute( "&1" , v-prod-name                                                                   )
          p-doc-qnty    = substitute( "&1" , buf_doc-line.doc-qnty                                                         )
          p-unit-base   = substitute( "&1" , buf_goods.unit-base                                                           )
          p-doc-sum     = substitute( "&1" , (buf_doc-line.cli-qnty * buf_doc-line.price-cli) / buf_doc-line.cli-base-rate )
          p-curr-abbr   = substitute( "&1" , buf_currency.curr-abbr                                                        )
          p-last-date   = ( if v-last-date = ? then "" else string( v-last-date , "99.99.9999" )                           )
        .
      end.
      otherwise do:
        assign
          p-status        = '1':u
          p-message = substitute("Неизвестный тип документа &1"
                                ,p-doc-type
                                )
        .
        return . /* --->>>--- */
      end.
    end case.



end.

end procedure. /* check-data */