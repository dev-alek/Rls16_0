block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rt-req14.p $
$Archive: gbl/rt-req14.p $

Обрабока запроса радиотерминала 14. Приемка товара. Редактирование количеств по документу

Автор: Хныкин Павел Андреевич
Дата создания: 27/02/07
Author: Pavel Khnykin
Creation date: 27/02/07

create: Перваков Михаил Сергеевич
Дата создания: 10/10/05

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
define input  parameter p-cli-qnty          as character no-undo .
define input  parameter p-unit-cli          as character no-undo .
define input  parameter p-cli-base-rate     as character no-undo .
define input  parameter p-line-number       as character no-undo .
define input  parameter p-price-cli         as character no-undo .
define input  parameter p-prod-artic        as character no-undo .
define input  parameter p-prod-artic-search as character no-undo .
define input  parameter p-price-docf        as character no-undo .
define input  parameter p-deadline-date     as character no-undo .
define input  parameter p-cop-check         as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-req14.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-req14.p $":U .
define variable vss-description as character no-undo init "Обрабока запроса радиотерминала 14. Приемка товара. Редактирование количеств по документу".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/integerm.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/lib-def.i  }
{ gbl/rtencode.i }
{ gbl/waitfram.i }
{ gbl/rt-cnvdc.i }
{ gbl/strtdate.i }
{ str/in-vatp.i  def }

define stream sout .

define new shared buffer t-doc for ub.trn-doc.

define variable v-status          as character no-undo .
define variable v-error-message   as character no-undo .
define variable v-unique-doc-code as character no-undo .
define variable v-b-code          as integer   no-undo .
define variable v-artic           as character no-undo .
define variable v-name            as character no-undo .
define variable v-prod-name       as character no-undo .
define variable v-unit-cli        as character no-undo .
define variable v-cli-base-rate   as character no-undo .
define variable v-price-cli       as character no-undo .
define variable v-vat-pc          as character no-undo .
define variable v-curr-abbr       as character no-undo .
define variable v-unit-base       as character no-undo .

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
end.


procedure check-data :

  define output parameter p-status        as character no-undo .
  define output parameter p-error-message as character no-undo .

  define buffer buf_clients    for ub.clients .
  define buffer buf_sysconf    for ub.sysconf .
  define buffer buf_bar-code   for ub.bar-code .
  define buffer buf_goods      for ub.goods .
  define buffer buf_units      for ub.units .
  define buffer buf_doc-line   for ub.doc-line .
  define buffer buf_sys-ctrl   for ub.sys-ctrl .
  define buffer buf_user-login for ub.user-login .
  define buffer buf_ext-artic  for ub.ext-artic.

  define variable v-bar-code          like ub.bar-code.b-code  no-undo .

  main_block:
  do transaction
  on error undo main_block, return error return-value
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
        p-status        = '1'
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
        p-status        = '1'
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
        p-status        = '1'
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
        p-status        = '1'
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
        p-status        = '1'
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
        p-status        = '1'
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

    find first buf_sysconf no-lock
      where buf_sysconf.host-code = v-host-code
      no-error .
    if not available buf_sysconf
    then do:
      assign
        p-status        = '1'
        p-error-message = substitute("Не найдена фирма &1"
                                    ,v-host-code
                                    )
      .
      return . /* --->>>--- */
    end.

    define variable v-prod-artic-search as logical   no-undo .

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

    define variable v-price-docf as decimal   no-undo .

    if p-price-docf = ""
    then do:
      assign
        p-status        = '1'
        p-error-message = "Не задана фактическая цена"
      .
      return . /* --->>>--- */
    end.

    /*
       TODO
         02/19/08 6:24
       Конвертировать char в decimal
    */

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
    case p-doc-type
    :
      when 'ПТ':u
      then do:
        assign
          p-status        = '1'
          p-error-message = "Нельзя редактировать количества по документу для поставки"
        .
        return . /* --->>>--- */
      end.
      when 'ПН':u
      then do:
        /* приход внешний */
        find first t-doc exclusive-lock
          where t-doc.doc-code = v-search-doc-code
          no-error .
        if not available t-doc
        then do:
          assign
            p-status        = '1'
            p-error-message = substitute("Не найден документ &1"
                                        ,v-search-doc-code
                                        )
          .
          return . /* --->>>--- */
        end.

        if t-doc.obj-type <> p-obj-type
        or t-doc.obj-code <> v-obj-code
        then do:
          assign
            p-status        = '1'
            p-error-message = substitute("Документ &1 принадлежит объекту &2 &3"
                                        ,v-search-doc-code
                                        ,p-obj-type
                                        ,v-obj-code
                                        )
          .
          return . /* --->>>--- */
        end.

        if t-doc.ext-doc-type <> {&TDEDT_Pri_Vnesh}
        then do:
          assign
            p-status        = '1'
            p-error-message = substitute("Документа &1 не является документом внешнего прихода"
                                        ,v-search-doc-code
                                        )
          .
          return . /* --->>>--- */
        end.

        if t-doc.status_ <> {&wayb}
        then do:
          assign
            p-status        = '1'
            p-error-message = substitute("Статус документа &1 отличен от &2. Невозможно редактировать количество"
                                        ,v-search-doc-code
                                        ,{&wayb}
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

        /* проверить права пользователя на добавление накладных */
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
            p-status        = '1':u
            p-error-message = return-value
          .
          return . /* --->>>--- */
        end.

        assign
          v-unique-doc-code = p-doc-type + '|':u + t-doc.doc-code
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
        if p-status <> '2':u
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
            p-error-message = substitute("Неизвестный статус &1 складского документа &2"
                                        ,p-status
                                        ,t-doc.doc-code
                                        )
          .
          return . /* --->>>--- */
        end.

        /* ищем по артикулу поставщика */
        if v-prod-artic-search = true
        then do:
          find first buf_ext-artic no-lock
            where buf_ext-artic.cli-type  = t-doc.cli-type
              and buf_ext-artic.cli-code  = t-doc.cli-code
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
                return . /* --->>>--- */
                end.
                assign
                  p-bar-code = string( v-bar-code )
                .
              end.
          end.
        end.

        /* распознать штрих-код */
        run gbl/rt-bcdoc.p
          (input  parparentproc
          ,input  v-unique-doc-code
          ,input  p-obj-type
          ,input  v-obj-code
          ,input  v-host-code
          ,input  p-bar-code
          ,output p-status
          ,output p-error-message
          ,output v-b-code
          ,output v-artic
          ,output v-name
          ,output v-prod-name
          ,output v-unit-cli
          ,output v-cli-base-rate
          ,output v-price-cli
          ,output v-vat-pc
          ,output v-curr-abbr
          ,output v-unit-base
          ,output v-price-docf
          ) .
        if p-status <> '0':u
        then do:
          assign
            p-status = '1':u
          .
          return . /* --->>>--- */
        end.

        find first buf_bar-code no-lock
          where buf_bar-code.b-code = v-b-code
          no-error .
        if not available buf_bar-code
        then do:
          assign
            p-status = '1':u
            p-error-message = substitute("Не найдена запись штрих-код &1"
                                        ,v-b-code
                                        )
          .
          return . /* --->>>--- */
        end.

        find first buf_goods no-lock
          where buf_goods.gds-code = buf_bar-code.gds-code
          no-error .
        if not available buf_goods
        then do:
          assign
            p-status = '1':u
            p-error-message = substitute("Не найдена запись товар &1"
                                        ,v-b-code
                                        )
          .
          return . /* --->>>--- */
        end.

        define variable v-goods-serial as logical   no-undo .
        { gbl/gdscdat.i
          buf_goods.gds-code
          "'serial=request':u"
          v-goods-serial
          no-error
        }
        if error-status :error
        then do:
          assign
            p-status = '1':u
            p-error-message = substitute("Ошибка при определении атрибута товара 'serial=request':u. &1 &2"
                                        ,error-status :get-message(1)
                                        ,return-value
                                        )
          .
          return . /* --->>>--- */
        end.

        if v-goods-serial = true
        then do:
          assign
            p-status = '1':u
            p-error-message = substitute("Серийный товар нельзя приходовать через радиотерминал. Товар &1 &2 &3"
                                        ,buf_goods.artic
                                        ,buf_goods.prod-type
                                        ,buf_goods.prod-code
                                        )
          .
          return . /* --->>>--- */
        end.

        define variable v-node-code as integer   no-undo .
        { gbl/gdsrtnod.i
          buf_goods.gds-code
          v-node-code
        }

        define variable v-request-cli-qnty      as decimal   no-undo .
        define variable v-request-cli-base-rate as decimal   no-undo .
        define variable v-request-line-number   as integer   no-undo .
        define variable v-request-price-cli     as decimal   no-undo .

        if p-cli-qnty = ''
        then do:
          assign
            p-status        = '1':u
            p-error-message = "Не задано количество"
          .
          return . /* --->>>--- */
        end.

        assign
          v-request-cli-qnty = decimal(p-cli-qnty) no-error
        .
        if error-status :error
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Ошибка в задании количества &1"
                                        ,p-cli-qnty
                                        )
          .
          return . /* --->>>--- */
        end.

        if v-request-cli-qnty = ?
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Не задано количество &1"
                                        ,p-cli-qnty
                                        )
          .
          return . /* --->>>--- */
        end.

        if v-request-cli-qnty <= 0
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Количество должно быть положительным &1"
                                        ,p-cli-qnty
                                        )
          .
          return . /* --->>>--- */
        end.

        if p-cli-base-rate = ''
        then do:
          assign
            p-status        = '1':u
            p-error-message = "Не задан коэффициент"
          .
          return . /* --->>>--- */
        end.
        assign
          v-request-cli-base-rate = decimal(p-cli-base-rate) no-error
        .
        if error-status :error
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Ошибка в задании коэффициента &1"
                                        ,p-cli-base-rate
                                        )
          .
          return . /* --->>>--- */
        end.

        if v-request-cli-base-rate = ?
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Не задан коэффициент &1"
                                        ,p-cli-base-rate
                                        )
          .
          return . /* --->>>--- */
        end.

        if v-request-cli-base-rate <= 0
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Коэффициент должен быть положительным &1"
                                        ,p-cli-base-rate
                                        )
          .
          return . /* --->>>--- */
        end.

        if p-unit-cli = ''
        then do:
          assign
            p-status        = '1':u
            p-error-message = "Не задана единица измерения поставщка"
          .
          return . /* --->>>--- */
        end.

        find first buf_units no-lock
          where buf_units.unit-name = p-unit-cli
          no-error .
        if not available buf_units
        then do:
          define variable v-okei as integer   no-undo .

          run integerm in this-procedure
            (input  p-unit-cli      /* p-string      */
            ,input  false           /* p-allow-sign  */
            ,input  false           /* p-allow-comma */
            ,output v-okei          /* p-value       */
            ,output v-data-valid    /* p-data-valid  */
            ,output v-error-message /* p-message     */
            ) .
          if v-data-valid <> true
          then do:
            assign
              p-status        = '1'
              p-error-message = substitute("Не найдена единица измерения &1"
                                          ,p-unit-cli
                                          )
            .
            return . /* --->>>--- */
          end.

          find first buf_units no-lock
            where buf_units.OKEI = v-okei
            no-error .
        end.

        if not available buf_units
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Не найдена единица измерения поставщка &1. Для задания единицы измерения поставщика можно использовать код ОКЕИ"
                                        ,p-unit-cli
                                        )
          .
          return . /* --->>>--- */
        end.

        if  buf_units.unit-name     = v-unit-base
        and v-request-cli-base-rate <> 1
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("При указании в качестве единицы измерения поставщика базовой единицы измерения &1 коэффициент не может отличаться от 1."
                                        ,p-unit-cli
                                        )
          .
          return . /* --->>>--- */
        end.

        /* Для серийного и штучного товара количество должно быть целым  */
        if lookup({&pieces}, buf_units.type) > 0
        or lookup({&serial}, buf_units.type) > 0
        then do:
          if v-request-cli-qnty <> truncate(v-request-cli-qnty, 0)
          then do:
            assign
              p-status        = '1'
              p-error-message = substitute('Для штучного и серийного товаров резервируемое количество должно быть целым.&1Кол-во: &2'
                                          ,{&new-line}
                                          ,v-request-cli-qnty
                                          )
            .
            return . /* --->>>--- */
          end.
        end.

        assign
          v-request-line-number = 0
        .

        if p-line-number <> ''
        then do:
          run integerm in this-procedure
            (input  p-line-number         /* p-string      */
            ,input  false                 /* p-allow-sign  */
            ,input  false                 /* p-allow-comma */
            ,output v-request-line-number /* p-value       */
            ,output v-data-valid          /* p-data-valid  */
            ,output v-error-message       /* p-message     */
            ) .
          if v-data-valid <> true
          then do:
            assign
              p-status        = '1'
              p-error-message = substitute("Ошибка преобразования номера строки &1. &2"
                                          ,p-line-number
                                          ,v-error-message
                                          )
            .
            return . /* --->>>--- */
          end.
        end.

        if p-price-cli = ''
        then do:
          /* если цена не задана - по умолчанию она принимается равной одной копейке */
          assign
            v-request-price-cli = 0.01
          .
        end.
        else do:
          assign
            v-request-price-cli     = decimal(p-price-cli) no-error
          .
          if error-status :error
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Ошибка при задании цены &1"
                                          ,p-price-cli
                                          )
            .
            return . /* --->>>--- */
          end.
        end.

        if v-request-price-cli < 0
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Цена не может быть отрицательной &1"
                                        ,p-price-cli
                                        )
          .
          return . /* --->>>--- */
        end.

        if v-request-price-cli = 0
        then do:
          /* если цена не задана - по умолчанию она принимается равной одной копейке */
          assign
            v-request-price-cli = 0.01
          .
        end.

        find first buf_doc-line exclusive-lock
          where buf_doc-line.doc-code  = t-doc.doc-code
            and buf_doc-line.artic     = buf_goods.artic
            and buf_doc-line.prod-type = buf_goods.prod-type
            and buf_doc-line.prod-code = buf_goods.prod-code
          no-error .
        if available buf_doc-line
        then do:
          /* если строка уже существует - сначала удаляем ее */
          { str/clcintrn.i
            parparentproc
            ?
            buf_doc-line.doc-code
            buf_doc-line.artic
            buf_doc-line.prod-type
            buf_doc-line.prod-code
            buf_doc-line.price-cli
            buf_doc-line.price-rubl
            buf_doc-line.price-base
            buf_doc-line.cli-qnty
            buf_doc-line.cli-base-rate
            buf_doc-line.fact-qnty
            buf_doc-line.doc-qnty
            buf_doc-line.vat-pc
            buf_doc-line.slt-pc
            buf_doc-line.road-tax
            buf_doc-line.excise
            buf_doc-line.transport-rubl
            buf_doc-line.other-rubl
            "'delete':u"
            "''"
            no-error
          }
          if error-status :error
          then do:
            undo main_block, return error return-value.
          end.
          delete buf_doc-line .
        end.

        create lib-trn_ret-doc .
        buffer-copy t-doc to lib-trn_ret-doc .

        create lib-trn_ret-line .
        assign
          lib-trn_ret-line.doc-code       = lib-trn_ret-doc.doc-code
          lib-trn_ret-line.artic          = buf_goods.artic
          lib-trn_ret-line.prod-type      = buf_goods.prod-type
          lib-trn_ret-line.prod-code      = buf_goods.prod-code
          lib-trn_ret-line.cli-qnty       = v-request-cli-qnty
          lib-trn_ret-line.unit-cli       = buf_units.unit-name
          lib-trn_ret-line.cli-base-rate  = v-request-cli-base-rate
          lib-trn_ret-line.price-cli      = v-request-price-cli
          lib-trn_ret-line.vat-pc         = decimal(v-vat-pc)
          lib-trn_ret-line.slt-pc         = 0
          lib-trn_ret-line.price-rubl     = v-request-price-cli / v-request-cli-base-rate
          lib-trn_ret-line.road-tax       = 0
          lib-trn_ret-line.transport-rubl = 0
          lib-trn_ret-line.other-rubl     = 0
          lib-trn_ret-line.doc-qnty       = v-request-cli-qnty * v-request-cli-base-rate
          lib-trn_ret-line.fact-qnty      = v-request-cli-qnty * v-request-cli-base-rate
        .

        create lib-trn_ret-dtl .
        assign
          lib-trn_ret-dtl.doc-code    = lib-trn_ret-doc.doc-code
          lib-trn_ret-dtl.artic       = buf_goods.artic
          lib-trn_ret-dtl.prod-type   = buf_goods.prod-type
          lib-trn_ret-dtl.prod-code   = buf_goods.prod-code
          lib-trn_ret-dtl.prt-code    = v-node-code
          lib-trn_ret-dtl.price-rubl  = v-request-price-cli / v-request-cli-base-rate
          lib-trn_ret-dtl.discnt-rubl = 0
          lib-trn_ret-dtl.doc-qnty    = v-request-cli-qnty * v-request-cli-base-rate
          lib-trn_ret-dtl.fact-qnty   = v-request-cli-qnty * v-request-cli-base-rate
        .

        { str/copy-in.i
          ?
          recid(t-doc)
          lib-trn_ret-doc
          lib-trn_ret-line
          lib-trn_ret-line-attr
          lib-trn_ret-dtl
          lib-trn_ret-parts
          false
          false
          true
          false
          this-procedure
          no-error
        }
        if error-status :error
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute('Ошибка при создании строки &1 &2':u
                                        ,error-status :get-message(1)
                                        ,return-value
                                        )
          .
          undo main_block, return . /* --->>>--- */
        end.

        find first buf_doc-line exclusive-lock
          where buf_doc-line.doc-code  = t-doc.doc-code
            and buf_doc-line.artic     = buf_goods.artic
            and buf_doc-line.prod-type = buf_goods.prod-type
            and buf_doc-line.prod-code = buf_goods.prod-code
          no-error .
        if not available buf_doc-line
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute('Неизвестная ошибка при создании строки документа &1 &2 &3 &4':u
                                        ,v-unique-doc-code
                                        ,buf_goods.artic
                                        ,buf_goods.prod-type
                                        ,buf_goods.prod-code
                                        )
          .
          undo main_block, return . /* --->>>--- */
        end.

        if v-request-line-number <> 0
        then do:
          assign
            buf_doc-line.line-num = v-request-line-number
          .
        end.

        define buffer buf_parts for ub.parts .

        define variable varprice-check as decimal no-undo.

        define variable v-price-correct as logical   no-undo .
        define variable v-message       as character no-undo .

        /* КВЦ */
/*        if v-cop-check = yes
        then do:
          parts_cycle:
          for each buf_parts no-lock
            where buf_parts.obj-type  = buf_doc-line.obj-type
              and buf_parts.obj-code  = buf_doc-line.obj-code
              and buf_parts.artic     = buf_doc-line.artic
              and buf_parts.prod-type = buf_doc-line.prod-type
              and buf_parts.prod-code = buf_doc-line.prod-code
              and buf_parts.in-code   = buf_doc-line.doc-code
          :
            if buf_parts.contract-code = 0
            then do:
              next parts_cycle.
            end.
            { str/in-vatp.i calc-parts buf_parts. t-doc. }

            assign
              varprice-check = (price-cli-with-tax-loc + road-tax-cli-loc
                                + (if buf_parts.vat-type <> {&inc-vat} then vat-cli-loc else 0)
                                + (if buf_parts.slt-type <> {&inc-slt} then slt-cli-loc else 0) ) / buf_parts.cli-base-rate
            .
            { str/ckcntspc.i
              buf_parts.host-code
              buf_parts.contract-code
              buf_goods.gds-code
              varprice-check
              buf_parts.VAT-type
              buf_parts.VAT-pc
              no-error
            }
            if error-status :error
            then do:
              assign
                p-status        = '2':u
                p-error-message = substitute("&1"
                                            ,return-value
                                            )
              .
              undo main_block, return . /* --->>>--- */
            end.
          end. /* parts_cycle: */
        end. /* if v-cop-check = yes  */*/


        /* прописываем срок годности в партии */
        if v-last-date <> ?
        then do:
          for each buf_parts exclusive-lock
            where buf_parts.obj-type  = buf_doc-line.obj-type
              and buf_parts.obj-code  = buf_doc-line.obj-code
              and buf_parts.artic     = buf_doc-line.artic
              and buf_parts.prod-type = buf_doc-line.prod-type
              and buf_parts.prod-code = buf_doc-line.prod-code
              and buf_parts.in-code   = buf_doc-line.doc-code
          :
            assign
              buf_parts.last-date = v-last-date
            .
          end.
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

    assign
      p-status        = '1'
      p-error-message = "Неизвестная ошибка"
    .
    undo main_block, return . /* --->>>--- */
  end.


end procedure. /* check-data */