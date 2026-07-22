block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rt-req09.p $
$Archive: gbl/rt-req09.p $

Обрабока запроса радиотерминала 09. Приемка товара. Редактирование фактических количеств

Автор: Хныкин Павел Андреевич
Дата создания: 27/02/07
Author: Pavel Khnykin
Creation date: 27/02/07

Create: Перваков Михаил Сергеевич
Дата создания: 09/26/05

*/

define input  parameter parparentproc       as widget-handle no-undo .
define input  parameter p-directory-out     as character no-undo .
define input  parameter p-file-name         as character no-undo .
define input  parameter p-session-valid     as logical   no-undo .
define input  parameter p-error-message     as character no-undo .
define input  parameter p-user-login        as character no-undo .
define input  parameter p-obj-type          as character no-undo .
define input  parameter p-obj-code          as character no-undo .
define input  parameter p-host-code         as character no-undo .
define input  parameter p-doc-type          as character no-undo .
define input  parameter p-doc-code          as character no-undo .
define input  parameter p-bar-code          as character no-undo .
define input  parameter p-fact-qnty         as character no-undo .
define input  parameter p-prod-artic        as character no-undo .
define input  parameter p-prod-artic-search as character no-undo .
define input  parameter p-deadline-date     as character no-undo .
define input  parameter p-cop-check         as character no-undo .
define input  parameter p-price-docf        as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-req09.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-req09.p $":U .
define variable vss-description as character no-undo init "Обрабока запроса радиотерминала 09. Приемка товара. Редактирование фактических количеств".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/integerm.i }
{ gbl/rtencode.i }
{ gbl/rt-cnvdc.i }
{ gbl/rt-cntxt.i }
{ gbl/strtdate.i }

define stream sout .

define variable v-status          as character no-undo .
define variable v-error-message   as character no-undo .
define variable v-unique-doc-code as character no-undo .
define variable v-b-code          as character no-undo .
define variable v-artic           as character no-undo .
define variable v-name            as character no-undo .
define variable v-prod-type       as character no-undo .
define variable v-prod-code       as integer   no-undo .
define variable v-prod-name       as character no-undo .
define variable v-doc-qnty        as character no-undo .
define variable v-unit-base       as character no-undo .
define variable v-doc-sum         as character no-undo .
define variable v-curr-abbr       as character no-undo .

do
on error undo, return error return-value
:
  if p-session-valid = true
  then do:
    run check-data in this-procedure
      (output  v-status
      ,output  v-error-message
      ) no-error .
    if error-status :error
    then do:
      /* чистим за собой контекст */
      run rt-cntxt_clrcntxt in this-procedure .
      undo, return error substitute("ошибка при вызове функции check-data. &1, &2"
                                  ,error-status :get-message(1)
                                  ,return-value
                                  ) .
    end.
  end.
  else do:
    assign
      v-status        = '1':u
      v-error-message = p-error-message
    .
  end.

  define variable v-temp-file-name as character no-undo .

  assign
    v-temp-file-name = entry(1, p-file-name, '.':u) + '.tmp':u
  .
  output stream sout to value(p-directory-out + '/':u + v-temp-file-name) .

  put stream sout unformatted substitute('status:&1', rtencode(v-status))
                              + {&new-line} .
  put stream sout unformatted substitute('message:&1',rtencode(v-error-message))
                              + {&new-line} .

  output stream sout close .

  os-delete value(p-directory-out + '/':u + p-file-name) .
  os-rename value(p-directory-out + '/':u + v-temp-file-name)
            value(p-directory-out + '/':u + p-file-name)
            .
  /* чистим за собой контекст */
  run rt-cntxt_clrcntxt in this-procedure .
end.


procedure check-data :

  define output parameter p-status        as character no-undo .
  define output parameter p-error-message as character no-undo .

  define buffer buf_clients     for ub.clients .
  define buffer buf_sysconf     for ub.sysconf .
  define buffer buf_sys-ctrl    for ub.sys-ctrl .
  define buffer buf_user-login  for ub.user-login .
  define buffer buf_ext-artic   for ub.ext-artic.
  define buffer buf_goods       for ub.goods.

  define variable v-bar-code        like ub.bar-code.b-code  no-undo .
  define variable v-last-date-str   as date      no-undo .
  define variable v-price-docf      as character no-undo .
  define variable v-inp-price       as decimal   no-undo .
  define variable v-is-hold-doc     as logical   no-undo .

  do
  on error undo, return error return-value
  :
    find first buf_sys-ctrl no-lock .
    find first buf_user-login no-lock
      where buf_user-login.db-num     = buf_sys-ctrl.db-num
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
        p-error-message = substitute( "&1" , return-value )
      .
      return . /* --->>>--- */
    end.

    if p-fact-qnty = '':u
    then do:
      assign
        p-status        = '1':u
        p-error-message = "Не задано фактическое количество"
      .
      return . /* --->>>--- */
    end.

    define variable v-fact-qnty as decimal   no-undo .

    assign
      v-fact-qnty = decimal(p-fact-qnty) no-error
    .
    if error-status :error
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Ошибка преобразования количества &1"
                                    ,p-fact-qnty
                                    )
      .
      return . /* --->>>--- */
    end.

    if v-fact-qnty = ?
    then do:
      assign
        p-status        = '1':u
        p-error-message = "Не задано фактическое количество"
      .
      return . /* --->>>--- */
    end.

    if v-fact-qnty < 0
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Количество не может быть отрицательным &1"
                                    ,p-fact-qnty
                                    )
      .
      return . /* --->>>--- */
    end.

    define variable v-cop-check as logical   no-undo .

    if( lookup ( p-cop-check , '0,1':U ) = 0 )
    then do:
      assign
        p-status        = '1'
        p-error-message = substitute("Недопустимое значение поля cop_check: &1"
                                    ,p-cop-check
                                    )
      .
      return . /* --->>>--- */
    end.
    else do:
      assign
        v-cop-check = if ( p-cop-check = '0') then no else yes
      .
    end.

    if p-price-docf <> ""
    then do:
      assign
        v-inp-price = decimal(p-price-docf)
      no-error .
      if error-status :error
      then do:
        assign
          p-status        = '1':u
          p-error-message = substitute("Ошибка преобразования входной цены поставщика &1"
                                      ,p-price-docf
                                      )
        .
        return . /* --->>>--- */
      end.

      if v-inp-price = ?
      then do:
        assign
          p-status        = '1':u
          p-error-message = substitute("Ошибка преобразования входной цены поставщика &1"
                                      ,p-price-docf
                                      )
        .
        return . /* --->>>--- */
      end.

      if v-inp-price <= 0
      then do:
        assign
          p-status        = '1':u
          p-error-message = substitute("Входная цена поставщика должна быть больше нуля. Вы ввели: &1"
                                      ,p-price-docf
                                      )
        .
        return . /* --->>>--- */
      end.
    end. /* if p-price-docf <> ""  */
    else do:
      assign
        v-inp-price = ?
      .
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

    define variable v-prod-artic-search as logical            no-undo .

    assign
      p-prod-artic-search = trim(p-prod-artic-search)
    .
    if( lookup ( p-prod-artic-search , '0,1':U ) = 0 )
    then do:
      assign
        p-status        = '1'
        p-error-message = substitute("Недопустимое значение поля prod_artic_search: &1"
                                    ,p-prod-artic-search
                                    )
      .
      return . /* --->>>--- */
    end.
    else do:
      assign
        v-prod-artic-search = if ( p-prod-artic-search = '0') then no else yes
      .
    end.

    define variable v-last-date as date      no-undo .

    if p-deadline-date <> "" and p-deadline-date <> ?
    then do:
      run strtdate in this-procedure ( input  p-deadline-date
                                     , output v-last-date
                                     , output v-data-valid
                                     , output v-error-message
                                     ).
      if v-data-valid <> true then do:
        assign
          p-status        = '1'
          p-error-message = substitute("Ошибка преобразования срока годности &1. &2"
                                      ,p-deadline-date
                                      ,v-error-message
                                      )
        .
        return . /* --->>>--- */
      end.
    end.


    define variable v-search-doc-code as character no-undo .

    run rt-cnvdc_decode in this-procedure ( input   p-doc-code
                                          , output  v-search-doc-code
                                          ) .
    /* выставляем контекст */
    run rt-cntxt_setcntxt in this-procedure ( input buf_sys-ctrl.db-num
                                            , input buf_user-login.user-id
                                            , input {&cntxt-object}
                                            , input v-obj-host-code
                                            , input buf_clients.obj-type
                                            , input buf_clients.obj-code
                                            , input buf_clients.db-num
                                            , input buf_user-login.user-administrator
                                            ) .
    main_block:
    do transaction
    on error undo main_block, return error return-value
    :
      case p-doc-type
      :
        when 'ПТ':u
        then do:
          /* поставка в статусе поставка */
          define buffer buf_ord-doc-rcv for ub.ord-doc-rcv .

          find first buf_ord-doc-rcv exclusive-lock
            where buf_ord-doc-rcv.rcv-code = v-search-doc-code
            no-error .
          if not available buf_ord-doc-rcv
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Не найден документ &1"
                                          ,v-search-doc-code
                                          )
            .
           undo main_block, return . /* --->>>--- */
          end.

          if buf_ord-doc-rcv.obj-type <> p-obj-type
          or buf_ord-doc-rcv.obj-code <> v-obj-code
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Документ &1 принадлежит объекту &2 &3"
                                          ,v-search-doc-code
                                          ,p-obj-type
                                          ,v-obj-code
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.

          if buf_ord-doc-rcv.status_ <> {&ord-rcv}
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Статус поставки &1 отличен от &2. Невозможно редактировать количество"
                                          ,v-search-doc-code
                                          ,{&ord-rcv}
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.

          assign
            v-unique-doc-code = p-doc-type + '|':u + buf_ord-doc-rcv.rcv-code
          .

          run gbl/rt-doced.p
            (input  v-unique-doc-code      /* p-unique-doc-code */
            ,input  buf_user-login.user-id /* p-user-id         */
            ,input  '':u                   /* p-set-status      */
            ,input  'check':u              /* p-action          */
            ,input "":U                    /* p-other           */
            ,output p-status               /* p-status          */
            ,output p-error-message        /* p-error-message   */
            ) .
          if p-status <> '1':u
          then do:
            if p-status = '3':u
            then do:
              assign
                p-status = '1':u
              .
              undo main_block, return . /* --->>>--- */
            end.
            assign
              p-status = '1':u
              p-error-message = substitute("Неизвестный статус &1 поставки &2"
                                          ,p-status
                                          ,v-unique-doc-code
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.

          /* ищем по артикулу поставщика */
          if v-prod-artic-search = true
          then do:
            find first buf_ext-artic no-lock
              where buf_ext-artic.cli-type  = buf_ord-doc-rcv.cli-type
                and buf_ext-artic.cli-code  = buf_ord-doc-rcv.cli-code
                and buf_ext-artic.ext-artic = p-bar-code
                and buf_ext-artic.status_   = {&current-status}
            no-error .
            if available buf_ext-artic
            then do:
                find first buf_goods no-lock
                  where buf_goods.gds-code = buf_ext-artic.gds-code
                no-error .
                if available buf_goods
                then do:
                  { gbl/gdsbcode.i buf_goods.gds-code ? v-bar-code no-error }
                  if error-status :error
                  then do:
                    assign
                      p-status = '1':u
                      p-error-message = substitute( "&1. &2"
                                                  , return-value
                                                  , error-status :get-message(1)
                                                  )
                    .
                    undo main_block, return . /* --->>>--- */
                  end.
                  assign
                    p-bar-code = string( v-bar-code )
                  .
                end.
            end.
          end.

          /* распознать штрих-код и проверить наличие товара в документе */
          run gbl/rt-bcode.p
            (input  parparentproc
            ,input  v-unique-doc-code
            ,input  p-bar-code
            ,input  v-fact-qnty
            ,input  v-inp-price
            ,input  v-cop-check
            ,output p-status
            ,output p-error-message
            ,output v-b-code
            ,output v-artic
            ,output v-name
            ,output v-prod-type
            ,output v-prod-code
            ,output v-prod-name
            ,output v-doc-qnty
            ,output v-unit-base
            ,output v-doc-sum
            ,output v-curr-abbr
            ,output v-last-date-str
            ,output v-price-docf
            ) .
          if p-status <> '0':u
          then do:
            assign
              p-status = '1':u
            .
            undo main_block, return . /* --->>>--- */
          end.
          run gbl/rt-lined.p
            (input  v-unique-doc-code      /* p-unique-doc-code */
            ,input  v-b-code               /* p-b-code          */
            ,input  v-fact-qnty            /* p-set-qnty        */
            ,input  v-last-date            /* p-last-date       */
            ,input  ( if v-inp-price <> ? then v-inp-price else decimal(v-price-docf) )             /* p-price-docf      */
            ,input  buf_user-login.user-id /* p-user-id         */
            ,input  'create-update'        /* p-action          */
            ,output p-status               /* p-status          */
            ,output p-error-message        /* p-error-message   */
            ) .
          if p-status <> '0':u
          then do:
            assign
              p-status        = '1':u
            .
            undo main_block, return . /* --->>>--- */
          end.

          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.
        when 'ПН':u
        then do:
          /* приход внешний */
          define buffer buf_trn-doc for ub.trn-doc .

          find first buf_trn-doc exclusive-lock
            where buf_trn-doc.doc-code = v-search-doc-code
            no-error .
          if not available buf_trn-doc
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Не найден документ &1"
                                          ,v-search-doc-code
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.

          if buf_trn-doc.obj-type <> p-obj-type
          or buf_trn-doc.obj-code <> v-obj-code
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Документ &1 принадлежит объекту &2 &3"
                                          ,v-search-doc-code
                                          ,p-obj-type
                                          ,v-obj-code
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.

          if buf_trn-doc.ext-doc-type <> {&TDEDT_Pri_Vnesh}
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Документа &1 не является документом внешнего прихода"
                                          ,v-search-doc-code
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.

          if buf_trn-doc.status_ <> {&wayb}
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Статус документа &1 отличен от &2. Невозможно редактировать количество"
                                          ,v-search-doc-code
                                          ,{&wayb}
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.

          /* todo                                       */
          /* проверить права пользователя               */
          /* на открытие объекта p-obj-type, p-obj-code */

          /* todo проверить права пользователя на редактирование документа */

          assign
            v-unique-doc-code = p-doc-type + '|':u + buf_trn-doc.doc-code
          .

          run gbl/rt-doced.p
            (input  v-unique-doc-code      /* p-unique-doc-code */
            ,input  buf_user-login.user-id /* p-user-id         */
            ,input  '':u                   /* p-set-status      */
            ,input  'check':u              /* p-action          */
            ,input "":U                    /* p-other           */
            ,output p-status               /* p-status          */
            ,output p-error-message        /* p-error-message   */
            ) .
          if p-status <> '1':u
          then do:
            if p-status = '3':u
            then do:
              assign
                p-status = '1':u
              .
              undo main_block, return . /* --->>>--- */
            end.
            assign
              p-status = '1':u
              p-error-message = substitute("Неизвестный статус &1 складского документа &2"
                                          ,p-status
                                          ,v-unique-doc-code
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.

          /* ищем по артикулу поставщика */
          if v-prod-artic-search = true
          then do:
            find first buf_ext-artic no-lock
              where buf_ext-artic.cli-type  = buf_trn-doc.cli-type
                and buf_ext-artic.cli-code  = buf_trn-doc.cli-code
                and buf_ext-artic.ext-artic = p-bar-code
                and buf_ext-artic.status_   = {&current-status}
            no-error .
            if available buf_ext-artic
            then do:
                find first buf_goods no-lock
                  where buf_goods.gds-code = buf_ext-artic.gds-code
                no-error .
                if available buf_goods
                then do:
                  { gbl/gdsbcode.i buf_goods.gds-code ? v-bar-code no-error }
                  if error-status :error
                  then do:
                    assign
                      p-status = '1':u
                      p-error-message = substitute( "&1. &2"
                                                  , return-value
                                                  , error-status :get-message(1)
                                                  )
                    .
                    undo main_block, return . /* --->>>--- */
                  end.
                  assign
                    p-bar-code = string( v-bar-code )
                  .
                end.
            end.
          end.

          /* распознать штрих-код и проверить наличие товара в документе */
          run gbl/rt-bcode.p
            (input  parparentproc
            ,input  v-unique-doc-code
            ,input  p-bar-code
            ,input  v-fact-qnty
            ,input  v-inp-price
            ,input  v-cop-check
            ,output p-status
            ,output p-error-message
            ,output v-b-code
            ,output v-artic
            ,output v-name
            ,output v-prod-type
            ,output v-prod-code
            ,output v-prod-name
            ,output v-doc-qnty
            ,output v-unit-base
            ,output v-doc-sum
            ,output v-curr-abbr
            ,output v-last-date-str
            ,output v-price-docf
            ) .
          if p-status <> '0':u
          then do:
            undo main_block, return . /* --->>>--- */
          end.

          run gbl/rt-lined.p
            (input  v-unique-doc-code      /* p-unique-doc-code */
            ,input  v-b-code               /* p-b-code          */
            ,input  v-fact-qnty            /* p-set-qnty        */
            ,input  v-last-date            /* p-last-date       */
            ,input  ( if v-inp-price <> ? then v-inp-price else decimal(v-price-docf) )        /* p-price-docf      */
            ,input  buf_user-login.user-id /* p-user-id         */
            ,input  'create-update'        /* p-action          */
            ,output p-status               /* p-status          */
            ,output p-error-message        /* p-error-message   */
            ) .
          if p-status <> '0':u
          then do:
            assign
              p-status        = '1':u
            .
            undo main_block, return . /* --->>>--- */
          end.

          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.
        when 'ОР':u
        then do:
          /* заявка */
          define buffer buf_ord-doc for ub.ord-doc .

          find first buf_ord-doc exclusive-lock
            where buf_ord-doc.doc-code = v-search-doc-code
          no-error .
          if not available buf_ord-doc
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Не найден документ &1"
                                          ,v-search-doc-code
                                          )
            .
           undo main_block, return . /* --->>>--- */
          end.

          if buf_ord-doc.cli-type <> p-obj-type
          or buf_ord-doc.cli-code <> v-obj-code
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Документ &1 предназначен объекту &2 &3"
                                          ,v-search-doc-code
                                          ,p-obj-type
                                          ,v-obj-code
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.

          if buf_ord-doc.status_ <> {&ord-req}
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Статус документа &1 отличен от &2. Невозможно редактировать количество"
                                          ,v-search-doc-code
                                          ,{&ord-req}
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.

          assign
            v-unique-doc-code = p-doc-type + '|':u + buf_ord-doc.doc-code
          .

          run gbl/rt-doced.p
            (input  v-unique-doc-code      /* p-unique-doc-code */
            ,input  buf_user-login.user-id /* p-user-id         */
            ,input  '':u                   /* p-set-status      */
            ,input  'check':u              /* p-action          */
            ,input "":U                    /* p-other           */
            ,output p-status               /* p-status          */
            ,output p-error-message        /* p-error-message   */
            ) .
          if p-status <> '1':u
          then do:
            if p-status = '3':u
            then do:
              assign
                p-status = '1':u
              .
              undo main_block, return . /* --->>>--- */
            end.
            assign
              p-status = '1':u
              p-error-message = substitute("Неизвестный статус &1 документа &2"
                                          ,p-status
                                          ,v-unique-doc-code
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.
          /* распознать штрих-код и проверить наличие товара в документе */
          run gbl/rt-bcode.p
            (input  parparentproc
            ,input  v-unique-doc-code
            ,input  p-bar-code
            ,input  v-fact-qnty
            ,input  v-inp-price
            ,input  v-cop-check
            ,output p-status
            ,output p-error-message
            ,output v-b-code
            ,output v-artic
            ,output v-name
            ,output v-prod-type
            ,output v-prod-code
            ,output v-prod-name
            ,output v-doc-qnty
            ,output v-unit-base
            ,output v-doc-sum
            ,output v-curr-abbr
            ,output v-last-date-str
            ,output v-price-docf
            ) .
          if p-status <> '0':u
          then do:
            assign
              p-status = '1':u
            .
            undo main_block, return . /* --->>>--- */
          end.

          define variable v-curr-qnty       as decimal   no-undo .
          define variable v-set-qnty        as decimal   no-undo .
          define variable v-curr-last-date  as date      no-undo .
          define variable v-curr-price-docf as decimal   no-undo .

          if v-fact-qnty > 0 then do:
            /* факт введенное с РТ кол-во */
            run gbl/rt-lingt.p ( input  v-unique-doc-code
                              , input  v-b-code
                              , output v-curr-qnty
                              , output v-curr-last-date
                              , output v-curr-price-docf
                              , output p-status
                              , output p-error-message
                              ) .
            if p-status <> '0'
            then do:
              assign
                p-status = '1':u
              .
              undo main_block, return . /* --->>>--- */
            end.
            assign
              v-set-qnty = v-fact-qnty + v-curr-qnty
            .
          end.

          run gbl/rt-lined.p
            (input  v-unique-doc-code      /* p-unique-doc-code */
            ,input  v-b-code               /* p-b-code          */
            ,input  v-set-qnty            /* p-set-qnty        */
            ,input  v-last-date            /* p-last-date       */
            ,input  ( if v-inp-price <> ? then v-inp-price else decimal(v-price-docf) )             /* p-price-docf      */
            ,input  buf_user-login.user-id /* p-user-id         */
            ,input  'create-update'        /* p-action          */
            ,output p-status               /* p-status          */
            ,output p-error-message        /* p-error-message   */
            ) .
          if p-status <> '0':u
          then do:
            assign
              p-status        = '1':u
            .
            undo main_block, return . /* --->>>--- */
          end.

          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.
        when 'РН':U
        then do:
          /* расход по заявке */

          find first buf_trn-doc exclusive-lock
            where buf_trn-doc.doc-code = v-search-doc-code
            no-error .
          if not available buf_trn-doc
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Не найден документ &1"
                                          ,v-search-doc-code
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.

          if buf_trn-doc.obj-type <> p-obj-type
          or buf_trn-doc.obj-code <> v-obj-code
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Документ &1 принадлежит объекту &2 &3"
                                          ,v-search-doc-code
                                          ,p-obj-type
                                          ,v-obj-code
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.

          case buf_trn-doc.ext-doc-type
          :
            when {&TDEDT_Ras_Perem}
            then do:
            end.
            when {&TDEDT_Ras_Vnesh}
            then do:
              { gbl/hold-doc.i buf_trn-doc.doc-code v-is-hold-doc }
              if v-is-hold-doc <> yes
              then do:
                assign
                  p-status        = '1':u
                  p-error-message = substitute("Документ внешнего расхода &1 не межфирменный"
                                              ,v-search-doc-code
                                              )
                .
                undo main_block, return . /* --->>>--- */
              end.
            end.
            otherwise do:
              assign
                p-status        = '1':u
                p-error-message = substitute("Недопустимый тип документа расхода &1"
                                            ,v-search-doc-code
                                            )
              .
              undo main_block, return . /* --->>>--- */
            end.
          end case. /* case buf_trn-doc.ext-doc-type */

          if buf_trn-doc.status_ <> {&wayb}
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Статус документа &1 отличен от &2. Невозможно редактировать количество"
                                          ,v-search-doc-code
                                          ,{&wayb}
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.

          assign
            v-unique-doc-code = p-doc-type + '|':u + buf_trn-doc.doc-code
          .

          run gbl/rt-doced.p
            (input  v-unique-doc-code      /* p-unique-doc-code */
            ,input  buf_user-login.user-id /* p-user-id         */
            ,input  '':u                   /* p-set-status      */
            ,input  'check':u              /* p-action          */
            ,input "":U                    /* p-other           */
            ,output p-status               /* p-status          */
            ,output p-error-message        /* p-error-message   */
            ) .
          if p-status <> '1':u
          then do:
            if p-status = '3':u
            then do:
              assign
                p-status = '1':u
              .
              undo main_block, return . /* --->>>--- */
            end.
            assign
              p-status = '1':u
              p-error-message = substitute("Неизвестный статус &1 складского документа &2"
                                          ,p-status
                                          ,v-unique-doc-code
                                          )
            .
            undo main_block, return . /* --->>>--- */
          end.

          /* ищем по артикулу поставщика */
          if v-prod-artic-search = true
          then do:
            find first buf_ext-artic no-lock
              where buf_ext-artic.cli-type  = buf_trn-doc.cli-type
                and buf_ext-artic.cli-code  = buf_trn-doc.cli-code
                and buf_ext-artic.ext-artic = p-bar-code
                and buf_ext-artic.status_   = {&current-status}
            no-error .
            if available buf_ext-artic
            then do:
                find first buf_goods no-lock
                  where buf_goods.gds-code = buf_ext-artic.gds-code
                no-error .
                if available buf_goods
                then do:
                  { gbl/gdsbcode.i buf_goods.gds-code ? v-bar-code no-error }
                  if error-status :error
                  then do:
                    assign
                      p-status = '1':u
                      p-error-message = substitute( "&1. &2"
                                                  , return-value
                                                  , error-status :get-message(1)
                                                  )
                    .
                    undo main_block, return . /* --->>>--- */
                  end.
                  assign
                    p-bar-code = string( v-bar-code )
                  .
                end.
            end.
          end.

          /* распознать штрих-код и проверить наличие товара в документе */
          run gbl/rt-bcode.p
            (input  parparentproc
            ,input  v-unique-doc-code
            ,input  p-bar-code
            ,input  v-fact-qnty
            ,input  v-inp-price
            ,input  v-cop-check
            ,output p-status
            ,output p-error-message
            ,output v-b-code
            ,output v-artic
            ,output v-name
            ,output v-prod-type
            ,output v-prod-code
            ,output v-prod-name
            ,output v-doc-qnty
            ,output v-unit-base
            ,output v-doc-sum
            ,output v-curr-abbr
            ,output v-last-date-str
            ,output v-price-docf
            ) .
          if p-status <> '0':u
          then do:
            undo main_block, return . /* --->>>--- */
          end.

          run gbl/rt-lined.p
            (input  v-unique-doc-code      /* p-unique-doc-code */
            ,input  v-b-code               /* p-b-code          */
            ,input  v-fact-qnty            /* p-set-qnty        */
            ,input  v-last-date            /* p-last-date       */
            ,input  ( if v-inp-price <> ? then v-inp-price else decimal(v-price-docf) )        /* p-price-docf      */
            ,input  buf_user-login.user-id /* p-user-id         */
            ,input  'create-update'        /* p-action          */
            ,output p-status               /* p-status          */
            ,output p-error-message        /* p-error-message   */
            ) .
          if p-status <> '0':u
          then do:
            assign
              p-status        = '1':u
            .
            undo main_block, return . /* --->>>--- */
          end.

          assign
            p-status        = '0':u
            p-error-message = '':u
          .
          return . /* --->>>--- */
        end.
        otherwise do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Неизвестный тип документа &1"
                                        ,p-doc-type
                                        )
          .
          undo main_block, return . /* --->>>--- */
        end.

      end case .
    end.

    assign
      p-status        = '1'
      p-error-message = "Неизвестная ошибка"
    .
    return . /* --->>>--- */
  end.

end procedure. /* check-data */