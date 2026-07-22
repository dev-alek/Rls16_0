block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rt-req19.p $
$Archive: gbl/rt-req19.p $

Обрабока запроса радиотерминала 19. Инвентаризация. Информация о товаре

Автор: Хныкин Павел Андреевич
Дата создания: 27/02/07
Author: Pavel Khnykin
Creation date: 27/02/07

create: Перваков Михаил Сергеевич
Дата создания: 10/24/05

*/

define input  parameter parparentproc    as widget-handle no-undo .
define input  parameter p-directory-out  as character no-undo .
define input  parameter p-file-name      as character no-undo .
define input  parameter p-obj-type       as character no-undo .
define input  parameter p-obj-code       as character no-undo .
define input  parameter p-bar-code       as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-req19.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-req19.p $":U .
define variable vss-description as character no-undo init "Обрабока запроса радиотерминала 19. Инвентаризация. Информация о товаре".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/integerm.i }
{ cmp/library.i  }
{ gbl/rtencode.i }

define stream sout .

define variable v-status        as character no-undo .
define variable v-error-message as character no-undo .
define variable v-artic         as character no-undo .
define variable v-name          as character no-undo .
define variable v-prod-name     as character no-undo .
define variable v-price-sale    as character no-undo .

do
on error undo, return error return-value
:
  run check-data in this-procedure
    (output v-status
    ,output v-error-message
    ,output v-artic
    ,output v-name
    ,output v-prod-name
    ,output v-price-sale
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute("ошибка при вызове функции check-data. &1, &2"
                                ,error-status :get-message(1)
                                ,return-value
                                ) .
  end.

  define variable v-temp-file-name as character no-undo .

  assign
    v-temp-file-name = entry(1, p-file-name, '.':u) + '.tmp':u
  .
  output stream sout to value(p-directory-out + '/':u + v-temp-file-name) .

  put stream sout unformatted substitute('status:&1' ,    rtencode(v-status))
    + {&new-line} .
  put stream sout unformatted substitute('message:&1',    rtencode(v-error-message))
    + {&new-line} .
  put stream sout unformatted substitute('artic:&1',      rtencode(v-artic))
    + {&new-line} .
  put stream sout unformatted substitute('name:&1',       rtencode(v-name))
    + {&new-line} .
  put stream sout unformatted substitute('prod_name:&1',  rtencode(v-prod-name))
    + {&new-line} .
  put stream sout unformatted substitute('price_sale:&1', rtencode(v-price-sale))
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
  define output parameter p-artic         as character no-undo .
  define output parameter p-name          as character no-undo .
  define output parameter p-prod-name     as character no-undo .
  define output parameter p-price-sale    as character no-undo .

  define buffer buf_clients  for ub.clients .
  define buffer buf_sysconf  for ub.sysconf .
  define buffer buf_bar-code for ub.bar-code .
  define buffer buf_goods    for ub.goods .

  define variable v-b-code as integer   no-undo .

  do
  on error undo, return error return-value
  :
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

    run gbl/getbcode.p
      (input  parparentproc /* parparentproc */
      ,input  p-bar-code    /* p-search-code */
      ,input  ""            /* p-obj-type    */
      ,input  0             /* p-obj-code    */
      ,input  false         /* p-with-chs    */
      ,output v-b-code      /* p-b-code      */
      ) .
    if v-b-code = ?
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute('Не найден штрих-код &1'
                                    ,p-bar-code
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
        p-status        = '1':u
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
        p-status        = '1':u
        p-error-message = substitute('Ошибка поиска записи товар с кодом &1 для бар-кода &2'
                                    ,buf_bar-code.gds-code
                                    ,v-b-code
                                    )
      .
      return . /* --->>>--- */
    end.

    find first buf_clients no-lock
      where buf_clients.obj-type = buf_goods.prod-type
        and buf_clients.obj-code = buf_goods.prod-code
      no-error .
    if not available buf_clients
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Ошибка при поиске записи поставщика &1 &2 для товара с кодом &3"
                                    ,buf_goods.prod-type
                                    ,buf_goods.prod-code
                                    ,buf_goods.gds-code
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
        p-status        = '1':u
        p-error-message = substitute('Ошибка поиске записи переоценки для штрих кода &1 &2 &3'
                                    ,p-bar-code
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

    assign
      p-artic      = buf_goods.artic
      p-name       = buf_goods.gds-name
      p-prod-name  = buf_clients.obj-name
      p-price-sale = string(v-prc-price-sale)
    .

    assign
      p-status        = '0':u
      p-error-message = ""
    .
  end.


end procedure. /* check-data */