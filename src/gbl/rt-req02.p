block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rt-req02.p $
$Archive: gbl/rt-req02.p $

Обрабока запроса радиотерминала 02. Контроль цены. Считать штрих-код

Автор: Хныкин Павел Андреевич
Дата создания: 27/02/07
Author: Pavel Khnykin
Creation date: 27/02/07

create: Перваков Михаил Сергеевич
Дата создания: 10/13/05

*/

define input  parameter parparentproc    as widget-handle no-undo .
define input  parameter p-directory-out  as character no-undo .
define input  parameter p-file-name      as character no-undo .
define input  parameter p-data-valid     as logical   no-undo .
define input  parameter p-error-message  as character no-undo .
define input  parameter p-user-login     as character no-undo .
define input  parameter p-obj-type       as character no-undo .
define input  parameter p-obj-code       as character no-undo .
define input  parameter p-bar-code       as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-req02.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-req02.p $":U .
define variable vss-description as character no-undo init "Обрабока запроса радиотерминала 02. Контроль цены. Считать штрих-код".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/integerm.i }
{ cmp/library.i  }
{ gbl/rtencode.i }
{ trg/partslib.i }

define stream sout .

define variable v-status        as character no-undo .
define variable v-error-message as character no-undo .
define variable v-ret-obj-type  as character no-undo .
define variable v-ret-obj-code  as character no-undo .
define variable v-bar-code-str  as character no-undo .
define variable v-price-label   as character no-undo .
define variable v-price-sale    as character no-undo .
define variable v-artic         as character no-undo .
define variable v-name          as character no-undo .
define variable v-prod-name     as character no-undo .
define variable v-prod-type     as character no-undo .
define variable v-prod-code     as character no-undo .
define variable v-fact-qnty     as character no-undo .
define variable v-unit-base     as character no-undo .
define variable v-rsrv-qnty     as character no-undo .
define variable v-min-stock     as character no-undo .
define variable v-last-date     as character no-undo .

do
on error undo, return error return-value
:
  if p-data-valid = true
  then do:
    run check-data in this-procedure
      (output v-status
      ,output v-error-message
      ,output v-ret-obj-type
      ,output v-ret-obj-code
      ,output v-bar-code-str
      ,output v-price-label
      ,output v-price-sale
      ,output v-artic
      ,output v-name
      ,output v-prod-name
      ,output v-prod-type
      ,output v-prod-code
      ,output v-fact-qnty
      ,output v-unit-base
      ,output v-rsrv-qnty
      ,output v-min-stock
      ,output v-last-date
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
      v-status        = '2':u
      v-error-message = p-error-message
      v-ret-obj-type  = ''
      v-ret-obj-code  = ''
      v-bar-code-str  = ''
      v-price-label   = ''
      v-price-sale    = ''
      v-artic         = ''
      v-name          = ''
      v-prod-name     = ''
      v-prod-type     = ''
      v-prod-code     = ''
      v-fact-qnty     = ''
      v-unit-base     = ''
      v-rsrv-qnty     = ''
      v-min-stock     = ''
      v-last-date     = ''
    .
  end.

  define variable v-temp-file-name as character no-undo .

  assign
    v-temp-file-name = entry(1, p-file-name, '.':u) + '.tmp':u
  .
  output stream sout to value(p-directory-out + '/':u + v-temp-file-name) .

  put stream sout unformatted substitute('status:&1',       rtencode(v-status))
    + {&new-line} .
  put stream sout unformatted substitute('message:&1',      rtencode(v-error-message))
    + {&new-line} .
  put stream sout unformatted substitute('obj_type:&1',     rtencode(v-ret-obj-type))
    + {&new-line} .
  put stream sout unformatted substitute('obj_code:&1',     rtencode(v-ret-obj-code))
    + {&new-line} .
  put stream sout unformatted substitute('bar_code_str:&1', rtencode(v-bar-code-str))
    + {&new-line} .
  put stream sout unformatted substitute('price_label:&1',  rtencode(v-price-label))
    + {&new-line} .
  put stream sout unformatted substitute('price_sale:&1',   rtencode(v-price-sale))
    + {&new-line} .
  put stream sout unformatted substitute('artic:&1',        rtencode(v-artic))
    + {&new-line} .
  put stream sout unformatted substitute('name:&1',         rtencode(v-name))
    + {&new-line} .
  put stream sout unformatted substitute('prod_name:&1',    rtencode(v-prod-name))
    + {&new-line} .
  put stream sout unformatted substitute('prod_type:&1',    rtencode(v-prod-type))
    + {&new-line} .
  put stream sout unformatted substitute('prod_code:&1',    rtencode(v-prod-code))
    + {&new-line} .
  put stream sout unformatted substitute('fact_qnty:&1',    rtencode(v-fact-qnty))
    + {&new-line} .
  put stream sout unformatted substitute('unit_base:&1',    rtencode(v-unit-base))
    + {&new-line} .
  put stream sout unformatted substitute('rsrv_qnty:&1',    rtencode(v-rsrv-qnty))
    + {&new-line} .
  put stream sout unformatted substitute('min_stock:&1',    rtencode(v-min-stock))
    + {&new-line} .
  put stream sout unformatted substitute('last_date:&1',    rtencode(v-last-date))
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
  define output parameter p-ret-obj-type  as character no-undo .
  define output parameter p-ret-obj-code  as character no-undo .
  define output parameter p-bar-code-str  as character no-undo .
  define output parameter p-price-label   as character no-undo .
  define output parameter p-price-sale    as character no-undo .
  define output parameter p-artic         as character no-undo .
  define output parameter p-name          as character no-undo .
  define output parameter p-prod-name     as character no-undo .
  define output parameter p-prod-type     as character no-undo .
  define output parameter p-prod-code     as character no-undo .
  define output parameter p-fact-qnty     as character no-undo .
  define output parameter p-unit-base     as character no-undo .
  define output parameter p-rsrv-qnty     as character no-undo .
  define output parameter p-min-stock     as character no-undo .
  define output parameter p-last-date     as character no-undo .

  define buffer buf_clients      for ub.clients .
  define buffer buf_sysconf      for ub.sysconf .
  define buffer buf_bar-code     for ub.bar-code .
  define buffer buf_goods        for ub.goods .
  define buffer buf_gds-obj      for ub.gds-obj .
  define buffer buf_gds-obj-prop for ub.gds-obj-prop .
  define buffer buf_sys-ctrl     for ub.sys-ctrl .
  define buffer buf_user-login   for ub.user-login .

  define variable v-b-code as integer   no-undo .

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
        p-status        = '2':u
        p-error-message = substitute("Неизвестный пользователь &1"
                                    ,p-error-message
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
        p-status        = '2':u
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
        p-status        = '2':u
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
        p-status        = '2':u
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
        p-status        = '2':u
        p-error-message = substitute("Неправильный тип объекта &1 &2"
                                    ,p-obj-type
                                    ,v-obj-code
                                    )
      .
      return . /* --->>>--- */
    end.

    define variable v-host-code as integer   no-undo .

    { gbl/hostcode.i
      buf_clients.obj-type
      buf_clients.obj-code
      v-host-code
    }

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
        p-status        = '2':u
        p-error-message = substitute("Пользователю не доступен объект &1 &2"
                                    ,buf_clients.obj-type
                                    ,buf_clients.obj-code
                                    )
      .
      return . /* --->>>--- */
    end.

    /* проверить права пользователя на выполнение контроля цены */
    define variable v-valid-act   as logical   no-undo .

    { gbl/chk-actg.i
      buf_sys-ctrl.db-num
      buf_user-login.user-id
      {&action-head-code-main}
      'actn_rt-check-price_work':U
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
        p-status        = '2':u
        p-error-message = return-value
      .
      return . /* --->>>--- */
    end.

    find first buf_sysconf no-lock
      where buf_sysconf.host-code = v-host-code
      no-error .
    if not available buf_sysconf
    then do:
      assign
        p-status        = '2':u
        p-error-message = substitute("Не найдена фирма &1"
                                    ,v-host-code
                                    )
      .
      return . /* --->>>--- */
    end.

    define variable v-bar-code        as character no-undo .
    define variable v-price-label     as decimal   no-undo .
    define variable v-prc-price-label as decimal   no-undo .

    case num-entries(p-bar-code, '/':u)
    :
      when 1
      then do:
        assign
          v-bar-code        = p-bar-code
          v-prc-price-label = 0
        .
      end.
      when 2
      then do:
        assign
          v-bar-code = entry(1, p-bar-code, '/':u)
        .
        assign
          v-prc-price-label = decimal(entry(2, p-bar-code, '/':u)) no-error
        .
        if error-status :error
        then do:
          assign
            p-status        = '2':u
            p-error-message = substitute("Ошибка в указании цены в составе штрих кода &1"
                                        ,p-bar-code
                                        )
          .
          return . /* --->>>--- */
        end.
      end.
      otherwise do:
        assign
          p-status        = '2':u
          p-error-message = substitute("Ошибка в указании формата строки проверки штрих-кода &1"
                                      ,p-bar-code
                                      )
        .
        return . /* --->>>--- */
      end.
    end.

    run gbl/getbcode.p
      (input  parparentproc /* parparentproc */
      ,input  v-bar-code    /* p-search-code */
      ,input  ""            /* p-obj-type    */
      ,input  0             /* p-obj-code    */
      ,input  false         /* p-with-chs    */
      ,output v-b-code      /* p-b-code      */
      ) .
    if v-b-code = ?
    then do:
      assign
        p-status        = '2'
        p-error-message = substitute('Не найден штрих-код &1'
                                    ,v-bar-code
                                    )
      .
      return . /* --->>>--- */
    end.

    find first buf_bar-code no-lock
      where buf_bar-code.b-code = v-b-code
      no-error .
    if not available buf_bar-code
    then do:
      assign
        p-status        = '2'
        p-error-message = substitute('Ошибка поиска записи bar-code &1'
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
        p-status        = '2'
        p-error-message = substitute('Ошибка поиска записи товар с кодом &1 для бар-кода &2'
                                    ,buf_bar-code.gds-code
                                    ,v-b-code
                                    )
      .
      return . /* --->>>--- */
    end.

    define variable v-prc-doc-num     as character no-undo .
    define variable v-prc-price-sale  as decimal   no-undo .
    define variable v-prc-road-tax    as decimal   no-undo .
    define variable v-prc-excise      as decimal   no-undo .

    { gbl/bcodeprc.i
      p-obj-type
      v-obj-code
      v-b-code
      0
      0
      v-prc-doc-num
      v-prc-price-sale
      v-prc-road-tax
      v-prc-excise
      no-error
    }
    if error-status :error
    then do:
      assign
        p-status        = '2'
        p-error-message = substitute('Ошибка при поиске записи переоценки для штрих кода &1 &2 &3'
                                    ,v-bar-code
                                    ,error-status :get-message(1)
                                    ,return-value
                                    )
      .
      return . /* --->>>--- */
    end.

    if v-prc-price-sale = ?
    then do:
      assign
        v-prc-price-sale = 0
      .
    end.


    find first buf_clients no-lock
      where buf_clients.obj-type = buf_goods.prod-type
        and buf_clients.obj-code = buf_goods.prod-code
      no-error .
    if not available buf_clients
    then do:
      assign
        p-status        = '2':u
        p-error-message = substitute("Ошибка при поиске записи поставщика &1 &2 для товара с кодом &3"
                                    ,buf_goods.prod-type
                                    ,buf_goods.prod-code
                                    ,buf_goods.gds-code
                                    )
      .
      return . /* --->>>--- */
    end.

    assign
      p-prod-name = buf_clients.obj-name
    .

    find first buf_gds-obj no-lock
      where buf_gds-obj.gds-code = buf_goods.gds-code
        and buf_gds-obj.obj-type = p-obj-type
        and buf_gds-obj.obj-code = v-obj-code
      no-error .
    if available buf_gds-obj
    then do:
      assign
        p-fact-qnty = string(buf_gds-obj.fact-qnty)
        p-rsrv-qnty = string(buf_gds-obj.fact-qnty - buf_gds-obj.free-qnty)
      .
    end.
    else do:
      assign
        p-fact-qnty = string(0.0)
        p-rsrv-qnty = string(0.0)
      .
    end.

    define variable v-attr-value as character no-undo .
    define variable v-attr-type  as character no-undo .

    find first buf_gds-obj-prop no-lock
      where buf_gds-obj-prop.obj-type = p-obj-type
        and buf_gds-obj-prop.obj-code = v-obj-code
        and buf_gds-obj-prop.gds-code = buf_goods.gds-code
      no-error .
    if available buf_gds-obj-prop
    then do:
      assign
        p-min-stock = string(buf_gds-obj-prop.gdop-min-stock)
      .
    end.
    else do:
      assign
        p-min-stock = string(0)
      .
    end.

    define variable v-bc-frmt  as character no-undo .
    define variable v-bc-pfx   as character no-undo .
    define variable v-par-type as character no-undo .

    { gbl/conf-rd.i
      "'bc-frmt':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      false
      v-bc-frmt
      v-par-type
      no-error
    }
    if error-status :error
    then do:
      assign
        p-status        = '2':u
        p-error-message = substitute("Ошибка при чтении конфигурационного параметра &1"
                                    ,'bc-frmt':u
                                    )
      .
      return . /* --->>>--- */
    end.

    { gbl/conf-rd.i
      "'bc-pfx':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      false
      v-bc-pfx
      v-par-type
      no-error
    }
    if error-status :error
    then do:
      assign
        p-status        = '2':u
        p-error-message = substitute("Ошибка при чтении конфигурационного параметра &1"
                                    ,'bc-pfx':u
                                    )
      .
      return . /* --->>>--- */
    end.

    { gbl/bc-ean.i
      v-bc-frmt
      v-bc-pfx
      v-b-code
      p-bar-code-str
      no-error
    }
    if error-status :error
    then do:
      assign
        p-status        = '2':u
        p-error-message = substitute("Ошибка при поиске промышленного кода для бар-кода &1"
                                    ,v-b-code
                                    )
      .
      return . /* --->>>--- */
    end.

    run partslib-init-temp-parts in this-procedure
      (input p-obj-type
      ,input v-obj-code
      ,input buf_goods.artic
      ,input buf_goods.prod-type
      ,input buf_goods.prod-code
      ) .

    define variable v-last-date as date      no-undo .

    assign
      v-last-date = ?
    .

    define buffer buf_temp-parts for temp-parts .
    for each buf_temp-parts
    on error undo, return error return-value
    :
      if  buf_temp-parts.last-date <> ?
      and (v-last-date = ?
          or
             (v-last-date <> ?
             and
             buf_temp-parts.last-date < v-last-date
             )
          )
      then do:
        assign
          v-last-date = buf_temp-parts.last-date
        .
      end.
    end.

    if v-last-date = ?
    then do:
      assign
        p-last-date = ''
      .
    end.
    else do:
      assign
        p-last-date = string(v-last-date, '99.99.9999':u)
      .
    end.

    if v-prc-price-label = v-prc-price-sale
    then do:
      assign
        p-status = '0':u
      .
    end.
    else do:
      assign
        p-status = '1':u
      .
    end.


    assign
      p-error-message = ""
      p-ret-obj-type  = p-obj-type
      p-ret-obj-code  = string(v-obj-code)
      p-price-label   = string(v-price-label)
      p-price-sale    = string(v-price-sale)
      p-artic         = buf_goods.artic
      p-name          = buf_goods.gds-name
      p-prod-type     = buf_goods.prod-type
      p-prod-code     = string(buf_goods.prod-code)
      p-unit-base     = buf_goods.unit-base
      p-price-label   = string(v-prc-price-label)
      p-price-sale    = string(v-prc-price-sale)
    .
  end.


end procedure. /* check-data */