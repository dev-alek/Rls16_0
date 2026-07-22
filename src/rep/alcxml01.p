block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: alcxml01.p $
$Archive: rep/alcxml01.p $

Декларация об объемах розничной продажи алкогольной продукции в XML (Москва)

Автор: Хныкин Павел Андреевич
Дата создания: 01/22/08
Author: Pavel Khnykin
Creation date: 01/22/08

*/

define input  parameter parparentproc   as handle    no-undo .
define input  parameter p-dir-full-name as character no-undo .
define input  parameter p-zip-arch      as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: alcxml01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/alcxml01.p $":U .
define variable vss-description as character no-undo init "Декларация об объемах розничной продажи алкогольной продукции в XML (Москва)".
{ cmp/vssrevis.i   }
{ cmp/str-glbl.i   }
{ cmp/library.i    }
{ cmp/r-page1.i    }
{ gbl/waitfram.i   }
{ trg/factord.i    }
{ gbl/cur-time.i   }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/getsect.i  def }

define stream xml-out.
define stream lst-out.
define stream serr.



function get-date-str return character (input p-date as date) forward.

define temp-table tt-gds no-undo like ub.goods
    field alc-type-inner-code like ub.alc-type.alc-type-inner-code
    field create-user-db-num  like ub.alc-type.create-user-db-num
    field alc-type-code       like ub.alc-type.alc-type-code
    field alc-type-name       like ub.alc-type.alc-type-name
index pi is primary unique gds-code
.


define temp-table tt-alc-report-head no-undo
  field obj-type          like ub.clients.obj-type
  field obj-code          like ub.clients.obj-code
  field doc-code          like ub.trn-doc.doc-code
  field lic-series        as character
  field lic-number        as character
  field lic-addendum      as character
  field transaction-date  as date
  field transaction-type  as integer
  field doc-date          like ub.trn-doc.fact-date
  field supplier-id       as decimal
index pi is primary unique
  obj-type
  obj-code
  doc-code
  transaction-type
.

define temp-table tt-alc-report-line no-undo
  field doc-code              like ub.trn-doc.doc-code
  field obj-type              like ub.clients.obj-type
  field obj-code              like ub.clients.obj-code
  field gds-code              like ub.goods.gds-code
  field transaction-type      as integer
  field egais-gds-code        as decimal
  field quantity              as decimal
  field is-quantity-discrete  as logical
  field doc-date              as date
  field doc-number            as character
index pi is primary unique
  obj-type
  obj-code
  doc-code
  transaction-type
  gds-code
.

define temp-table tt-xml-file no-undo
  field file-id   as integer
  field file-name as character
index pi is primary unique
  file-id
.


define variable v-begin-date         as date      no-undo .
define variable v-end-date           as date      no-undo .
define variable v-fact-order-start   as decimal   no-undo .
define variable v-fact-order-end     as decimal   no-undo .
define variable v-par-val            as character no-undo .
define variable v-par-type           as character no-undo .
define variable v-dir-name           as character no-undo .
define variable v-unbinded-goods     as logical   no-undo .
define variable v-unbinded-suppliers as logical   no-undo .

do on error undo, return error return-value
:
  { rep/repfrm.i def  }
  { gbl/getsect.i run "''"  0  {&attr-report-glob} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'ardecldt' then v-par-val =  string(thbjattr_thbj-attr.property-value-date,"99/99/9999") .
  end.

  assign
    v-begin-date  = date(v-par-val)
    v-end-date    = x-Date-Alone
    v-dir-name    = replace( p-dir-full-name , "/" , "\") .
  .
  if length(v-dir-name) <> r-index( v-dir-name , "\") then do:
    assign
      v-dir-name = v-dir-name + "\" .
    .
  end .
  /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input v-begin-date
                                             , output v-fact-order-start
                                             ).
  /*Поиск посл fact-order*/
  run factord-end-day in this-procedure ( input v-end-date
                                        , output v-fact-order-end
                                        ).
  run clear-tt in this-procedure .
  run fill-tt-rep in this-procedure .
  run write-xml-files in this-procedure .

  if p-zip-arch = yes then do:
    run pack-xml-files in this-procedure no-error .
    if error-status :error then do:
      message
        error-status :get-message(1) skip(1)
        "Отчет не упакован!"
      view-as alert-box error.
    end.
  end.

  { rep/repfrm.i off }
  run clear-tt in this-procedure .

  if v-unbinded-goods = yes
  then do:
    message
      "В процессе формирования отчета были найдены товары не имеющие ЕГАИС-кода" skip
      "Подробности в файле alcdcl01.err"
    view-as alert-box error.
  end.

  if v-unbinded-suppliers = yes
  then do:
    message
      "В процессе формирования отчета были найдены поставщики не имеющие ЕГАИС-кода" skip
      "Подробности в файле alcdcl01.err"
    view-as alert-box error.
  end.

  message
    "Формирование отчета завершено."
  view-as alert-box information.
end.

/* ================================================================= */
procedure clear-tt :

do
on error undo, return error return-value
:
  empty temp-table tt-gds.
  empty temp-table tt-alc-report-head.
  empty temp-table tt-alc-report-line.
  empty temp-table tt-xml-file.

end.

end procedure. /* clear-tt */

/* ================================================================= */
procedure find-alc-goods :

do
on error undo, return error return-value
:

  define buffer buf_alc-type      for ub.alc-type.
  define buffer buf_alc-type-gds  for ub.alc-type-gds.
  define buffer buf_goods         for ub.goods.

  /* заполняем список алкогольных товаров */
  empty temp-table tt-gds.

  for each buf_alc-type no-lock
        where buf_alc-type.alc-type-status = 0
  :
    for each buf_alc-type-gds no-lock
          where buf_alc-type-gds.alc-type-inner-code = buf_alc-type.alc-type-inner-code
            AND buf_alc-type-gds.create-user-db-num  = buf_alc-type.create-user-db-num
      , first buf_goods no-lock
          where buf_goods.gds-code = buf_alc-type-gds.gds-code
    :
      find first tt-gds no-lock where tt-gds.gds-code = buf_goods.gds-code no-error .
      if not available tt-gds then do:
        create tt-gds.
        buffer-copy buf_goods to tt-gds
        assign
          tt-gds.alc-type-inner-code = buf_alc-type.alc-type-inner-code
          tt-gds.create-user-db-num  = buf_alc-type.create-user-db-num
          tt-gds.alc-type-code       = buf_alc-type.alc-type-code
          tt-gds.alc-type-name       = buf_alc-type.alc-type-name
        .
      end.
    end.
  end.
end.

end procedure. /* find-alc-goods */

/* ================================================================= */
procedure find-license :
  define input  parameter p-obj-type      like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code      like ub.clients.obj-code no-undo .
  define output parameter p-lic-series    as character             no-undo .
  define output parameter p-lic-number    as character             no-undo .
  define output parameter p-lic-addendum  as character             no-undo .

  define buffer buf_alc-sale-lic for ub.alc-sale-lic.

  define variable v-host-code as integer   no-undo .
do
on error undo, return error return-value
:
  { gbl/hostcode.i p-obj-type p-obj-code v-host-code }

  for each   buf_alc-sale-lic no-lock
       where buf_alc-sale-lic.cli-type = {&cmp}
         and buf_alc-sale-lic.cli-code = v-host-code
         and buf_alc-sale-lic.date-to  > v-end-date
       :
        assign
          p-lic-series = buf_alc-sale-lic.seria
          p-lic-number = buf_alc-sale-lic.number
        .
        return . /* --->>>--- */
  end. /* for each buf_alc-sale-lic no-lock */

  assign
    p-lic-series   = ?
    p-lic-number   = ?
    p-lic-addendum = ?
  .

end.

end procedure. /* find-license */

/* ================================================================= */
procedure find-alc-egais-code :
  define input  parameter p-gds-code    like ub.goods.gds-code  no-undo .
  define output parameter p-egais-code  as character            no-undo .

  define buffer buf_egais-gds for ub.egais-gds.
do
on error undo, return error return-value
:
  find first buf_egais-gds no-lock
    where buf_egais-gds.gds-code = p-gds-code
  no-error .
  if available buf_egais-gds then do :
    assign
      p-egais-code = buf_egais-gds.alpr-code-egais
    .
  end.
  else do:
    assign
      p-egais-code = ?
    .
  end.

end.

end procedure. /* find-alc-egais-code */

/* ================================================================= */
procedure find-supp-egais-code :
  define input  parameter p-obj-type        like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code        like ub.clients.obj-code no-undo .
  define output parameter p-supp-egais-code as character             no-undo .

  define buffer buf_egais-clients for ub.egais-clients.
do
on error undo, return error return-value
:
  find first buf_egais-clients no-lock
    where buf_egais-clients.obj-type = p-obj-type
      and buf_egais-clients.obj-code = p-obj-code
  no-error .
  if available buf_egais-clients then do:
    assign
      p-supp-egais-code = buf_egais-clients.supp-code-egais
    .
  end.
  else do:
    assign
      p-supp-egais-code = ?
    .
  end.

end.

end procedure. /* find-supp-egais-code */

/* ================================================================= */
procedure get-transaction-type :
  define input  parameter p-rowid             as rowid     no-undo .
  define input  parameter p-qnty              as decimal   no-undo .
  define output parameter p-transaction-type  as integer   no-undo .
/*
  Тип операции о движении спиртосодержащей продукции.
  Поддерживаются следующие типы операций:

  0 = Первоначальный ввод документов
  1 = Поступление товара от поставщиков
  2 = Поступление товара с удаленного склада (не имеющего лицензию на розничную продажу алкогольной продукции)
  3 = Поступление товара с другого объекта лицензированиЯ
  4 = Оприходование товаров по результатам инвентаризации
  5 = Возврат товаров розничным покупателем
  6 = Прочие поступлени
  7 = Розничная реализация товаров
  8 = Перевод товаров на удаленный склад
  9 = Перевод на другой объект лицензированиЯ
  10 = Возврат поставщику
  11 = Списание товара (естественная убыль, бой, порча, брак и т.п.)
  12 = Списание товара по результатам инвентаризации
  13 = Прочий расход

*/

  define buffer buf_trn-doc for ub.trn-doc.

  define variable v-lic-series        as character no-undo .
  define variable v-lic-number        as character no-undo .
  define variable v-lic-addendum      as character no-undo .

do
on error undo, return error return-value
:
  find first buf_trn-doc no-lock
    where rowid(buf_trn-doc) = p-rowid
  no-error .
  if not available buf_trn-doc then do:
    assign
      p-transaction-type = ?
    .
    return.
  end.
  case buf_trn-doc.ext-doc-type :
    /* приход */
    when {&TDEDT_PRI_VNESH}  then do :
      assign
        p-transaction-type = 1
      .
    end.
    when {&TDEDT_PRI_PEREM}     or
    when {&TDEDT_VOZVRAT_PEREM}
    then do :
      run find-license in this-procedure ( input buf_trn-doc.cli-type
                                         , input buf_trn-doc.cli-code
                                         , output v-lic-series
                                         , output v-lic-number
                                         , output v-lic-addendum
                                         ) .
      assign
        p-transaction-type = if v-lic-series <> ? then 3 else 2
      .
    end.
    /* расход */
    when {&TDEDT_RAS_VNESH}
    then do:
      assign
        p-transaction-type = 13
      .
    end.
    when {&TDEDT_RAS_VNESH_KASS}
    then do :
      assign
        p-transaction-type = 7
      .
    end.
    when {&TDEDT_VOZVRAT_VNESH} or
    when {&TDEDT_VOZVRAT_VNESH_KASS}
    then do :
      assign
        p-transaction-type = 5
      .
    end.
    /* списание и возврат поставщику */
    when {&TDEDT_RAS_VNESH_VP} then do :
      assign
        p-transaction-type = 10
      .
    end.
    when {&TDEDT_RAS_PEREM} then do:
      run find-license in this-procedure ( input buf_trn-doc.cli-type
                                         , input buf_trn-doc.cli-code
                                         , output v-lic-series
                                         , output v-lic-number
                                         , output v-lic-addendum
                                         ) .
      assign
        p-transaction-type = if v-lic-series <> ? then 9 else 8
      .
    end.
    when {&TDEDT_SPI_VNESH}
    then do :
      assign
        p-transaction-type = 11
      .
    end.
    when {&tdedt_inv} then do:
      assign
        p-transaction-type = ( if p-qnty > 0 then 4 else 12 )
      .
    end.
    when {&tdedt_peresort} or
    when {&tdedt_pri_prvo}
    then do:
      assign
        p-transaction-type = ( if p-qnty > 0 then 6 else 13 )
      .
    end.
    otherwise do:
      message
        "Неизвестный тип операции о движении спиртосодержащей продукции!" skip
        buf_trn-doc.ext-doc-type
      view-as alert-box error.
/*      assign*/
/*        p-transaction-type = 13*/
/*      .*/
    end.
  end.

end.

end procedure. /* get-transaction-type */

/* ================================================================= */
procedure fill-tt-rep :

do
on error undo, return error return-value
:
  define buffer buf_ot-line       for ub.ot-line.
  define buffer buf_trn-doc       for ub.trn-doc.
  define buffer buf_goods         for ub.goods.
  define buffer buf_doc-line-sum  for ub.doc-line-sum.

  define variable var-x-sum-type      like ub.stk-tot.sum-type  no-undo .
  define variable v-host-code         like ub.clients.host-code no-undo .

  define variable v-lic-series            as character no-undo .
  define variable v-lic-number            as character no-undo .
  define variable v-lic-addendum          as character no-undo .
  define variable v-transaction-date      as date      no-undo .
  define variable v-transaction-type      as integer   no-undo .
  define variable v-doc-date              as date      no-undo .
  define variable v-supplier-id           as integer   no-undo .
  define variable v-gds-egais-code        as decimal   no-undo .
  define variable v-quantity              as decimal   no-undo .
  define variable v-is-quantity-discrete  as logical   no-undo .
  define variable v-counter               as integer   no-undo .
  define variable v-repfrm-str            as character no-undo .

  run find-alc-goods in this-procedure .
  { rep/repfrm.i on 1 }
  _obj-list:
  for each obj-list :
    run find-license in this-procedure ( input obj-list.obj-type
                                       , input obj-list.obj-code
                                       , output v-lic-series
                                       , output v-lic-number
                                       , output v-lic-addendum
                                       ) .
    /* Отчет формируется только по объектам имеющим лицензию на отчетный период */
    if v-lic-series = ? then do:
      message
        substitute( "Не найдена лицензия на объекте &1 &2 &3 &4за отчетный период с &5 по &6"
                  , obj-list.obj-type
                  , obj-list.obj-code
                  , obj-list.obj-name
                  , {&new-line}
                  , v-begin-date
                  , v-end-date
                  )
      view-as alert-box information.
      next _obj-list.
    end.

    assign
      v-counter     = 0
      v-repfrm-str  = substitute( "Расчет по объекту &1 (&2 &3)"
                                , obj-list.obj-name
                                , obj-list.obj-type
                                , obj-list.obj-code
                                )
    .
    { rep/repfrm.i disp v-counter v-repfrm-str}

    _gds-line:
    for each tt-gds :
      run find-alc-egais-code in this-procedure ( input tt-gds.gds-code
                                                , output v-gds-egais-code
                                                ) .
      if v-gds-egais-code = ?
      then do :
        assign
          v-unbinded-goods = yes
        .
        run write-error in this-procedure ( substitute( "Не найден ЕГАИС код для товара &1 - &2. Товар не будет включен в отчет."
                                                      , tt-gds.artic
                                                      , tt-gds.gds-name
                                                      )
                                          ) .
        next _gds-line.
      end.
      _ot-line:
      for each buf_ot-line no-lock
            where buf_ot-line.obj-type    = obj-list.obj-type
              and buf_ot-line.obj-code    = obj-list.obj-code
              and buf_ot-line.artic       = tt-gds.artic
              and buf_ot-line.prod-type   = tt-gds.prod-type
              and buf_ot-line.prod-code   = tt-gds.prod-code
              and buf_ot-line.fact-order >= v-fact-order-start
              and buf_ot-line.fact-order <= v-fact-order-end
              and buf_ot-line.sum-type  = {&arh-cost}
      :
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_ot-line.doc-code
        no-error .
        if not available buf_trn-doc then do:
            message
              substitute( "Не могу найти документ &1" , buf_ot-line.doc-code )
            view-as alert-box error .
            next _ot-line.
        end.

        run get-transaction-type in this-procedure ( input  rowid(buf_trn-doc)
                                                   , input  buf_ot-line.fact-qnty
                                                   , output v-transaction-type
                                                   ) .

        find first tt-alc-report-head
          where tt-alc-report-head.obj-type         = obj-list.obj-type
            and tt-alc-report-head.obj-code         = obj-list.obj-code
            and tt-alc-report-head.doc-code         = buf_trn-doc.doc-code
            and tt-alc-report-head.transaction-type = v-transaction-type
        no-error .
        if not available tt-alc-report-head then do:
          /* если внешний приход, то ищем ЕГАИС код поставщика */
          if buf_ot-line.ext-doc-type = {&TDEDT_PRI_VNESH} then do :
            run find-supp-egais-code in this-procedure ( input  buf_trn-doc.cli-type
                                                       , input  buf_trn-doc.cli-code
                                                       , output v-supplier-id
                                                       ) .
            if v-supplier-id = ? then do:
              assign
                v-unbinded-suppliers = yes
              .
              run write-error in this-procedure ( substitute( "Не найден ЕГАИС код для поставщика &1 &2. Строка исключена из отчета."
                                                            , buf_trn-doc.cli-type
                                                            , buf_trn-doc.cli-code
                                                            )
                                                ) .
              next _ot-line.
            end.
          end.
          else do:
            assign
              v-supplier-id = ?
            .
          end.
          assign
            v-transaction-date  = buf_trn-doc.fact-date
            v-doc-date          = buf_trn-doc.fact-date
          .
          create tt-alc-report-head.
          assign
            tt-alc-report-head.obj-type         = obj-list.obj-type
            tt-alc-report-head.obj-code         = obj-list.obj-code
            tt-alc-report-head.doc-code         = buf_trn-doc.doc-code
            tt-alc-report-head.lic-series       = v-lic-series
            tt-alc-report-head.lic-number       = v-lic-number
            tt-alc-report-head.lic-addendum     = v-lic-addendum
            tt-alc-report-head.transaction-date = v-transaction-date
            tt-alc-report-head.transaction-type = v-transaction-type
            tt-alc-report-head.doc-date         = v-doc-date
            tt-alc-report-head.supplier-id      = v-supplier-id
          .
        end.
        assign
          v-quantity             = abs( buf_ot-line.fact-qnty )
          v-is-quantity-discrete = yes
        .

        create tt-alc-report-line.
        assign
          tt-alc-report-line.doc-code             = buf_trn-doc.doc-code
          tt-alc-report-line.obj-type             = obj-list.obj-type
          tt-alc-report-line.obj-code             = obj-list.obj-code
          tt-alc-report-line.transaction-type     = v-transaction-type
          tt-alc-report-line.gds-code             = tt-gds.gds-code
          tt-alc-report-line.egais-gds-code       = v-gds-egais-code
          tt-alc-report-line.quantity             = v-quantity
          tt-alc-report-line.is-quantity-discrete = v-is-quantity-discrete
          tt-alc-report-line.doc-date             = v-doc-date
          tt-alc-report-line.doc-number           = buf_ot-line.doc-code
          v-counter                               = v-counter + 1
        .

        /* естественная убыль */
        find first buf_doc-line-sum no-lock
          where buf_doc-line-sum.doc-code = buf_trn-doc.doc-code
            and buf_doc-line-sum.gds-code = tt-gds.gds-code
            and buf_doc-line-sum.sum-type = {&sum-wastage-doc}
        no-error .
        if available buf_doc-line-sum
        then do:
          if buf_doc-line-sum.fact-qnty > 0
          then do:
            assign
              v-transaction-type = 11
            .
            find first tt-alc-report-head
              where tt-alc-report-head.obj-type         = obj-list.obj-type
                and tt-alc-report-head.obj-code         = obj-list.obj-code
                and tt-alc-report-head.doc-code         = buf_trn-doc.doc-code
                and tt-alc-report-head.transaction-type = v-transaction-type
            no-error .
            if not available tt-alc-report-head then do:
              /* если внешний приход, то ищем ЕГАИС код поставщика */
              if buf_ot-line.ext-doc-type = {&TDEDT_PRI_VNESH} then do :
                run find-supp-egais-code in this-procedure ( input  buf_trn-doc.cli-type
                                                           , input  buf_trn-doc.cli-code
                                                           , output v-supplier-id
                                                           ) .
                if v-supplier-id = ? then do:
                  assign
                    v-unbinded-suppliers = yes
                  .
                  run write-error in this-procedure ( substitute( "Не найден ЕГАИС код для поставщика &1 &2. Строка исключена из отчета."
                                                                , buf_trn-doc.cli-type
                                                                , buf_trn-doc.cli-code
                                                                )
                                                    ) .
                  next _ot-line.
                end.
              end.
              else do:
                assign
                  v-supplier-id = ?
                .
              end.
              assign
                v-transaction-date  = buf_trn-doc.fact-date
                v-doc-date          = buf_trn-doc.fact-date
              .
              create tt-alc-report-head.
              assign
                tt-alc-report-head.obj-type         = obj-list.obj-type
                tt-alc-report-head.obj-code         = obj-list.obj-code
                tt-alc-report-head.doc-code         = buf_trn-doc.doc-code
                tt-alc-report-head.lic-series       = v-lic-series
                tt-alc-report-head.lic-number       = v-lic-number
                tt-alc-report-head.lic-addendum     = v-lic-addendum
                tt-alc-report-head.transaction-date = v-transaction-date
                tt-alc-report-head.transaction-type = v-transaction-type
                tt-alc-report-head.doc-date         = v-doc-date
                tt-alc-report-head.supplier-id      = v-supplier-id
              .
            end. /* if not available tt-alc-report-head */

            create tt-alc-report-line.
            assign
              tt-alc-report-line.doc-code             = buf_trn-doc.doc-code
              tt-alc-report-line.obj-type             = obj-list.obj-type
              tt-alc-report-line.obj-code             = obj-list.obj-code
              tt-alc-report-line.transaction-type     = v-transaction-type
              tt-alc-report-line.gds-code             = tt-gds.gds-code
              tt-alc-report-line.egais-gds-code       = v-gds-egais-code
              tt-alc-report-line.quantity             = buf_doc-line-sum.fact-qnty
              tt-alc-report-line.is-quantity-discrete = v-is-quantity-discrete
              tt-alc-report-line.doc-date             = v-doc-date
              tt-alc-report-line.doc-number           = buf_ot-line.doc-code
            .
          end. /* if buf_doc-line-sum.fact-qnty > 0 */
        end. /* if available buf_doc-line-sum */


        { rep/repfrm.i disp v-counter v-repfrm-str}
      end. /* for each buf_ot-line no-lock */
      _wast-ot-line:
      for each buf_ot-line no-lock
            where buf_ot-line.obj-type    = obj-list.obj-type
              and buf_ot-line.obj-code    = obj-list.obj-code
              and buf_ot-line.artic       = tt-gds.artic
              and buf_ot-line.prod-type   = tt-gds.prod-type
              and buf_ot-line.prod-code   = tt-gds.prod-code
              and buf_ot-line.fact-order >= v-fact-order-start
              and buf_ot-line.fact-order <= v-fact-order-end
              and buf_ot-line.sum-type  = {&arh-crsa}
      :
        if buf_ot-line.sum-base <> 0
        then do:
          next _wast-ot-line.
        end.

        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_ot-line.doc-code
        no-error .
        if not available buf_trn-doc then do:
            message
              substitute( "Не могу найти документ &1" , buf_ot-line.doc-code )
            view-as alert-box error .
            next _wast-ot-line.
        end.
        /* естественная убыль */
        find first buf_doc-line-sum no-lock
          where buf_doc-line-sum.doc-code = buf_trn-doc.doc-code
            and buf_doc-line-sum.gds-code = tt-gds.gds-code
            and buf_doc-line-sum.sum-type = {&sum-wastage-doc}
        no-error .
        if available buf_doc-line-sum
        then do:
          if buf_doc-line-sum.fact-qnty > 0
          then do:
            assign
              v-transaction-type = 11
            .
            find first tt-alc-report-head
              where tt-alc-report-head.obj-type         = obj-list.obj-type
                and tt-alc-report-head.obj-code         = obj-list.obj-code
                and tt-alc-report-head.doc-code         = buf_trn-doc.doc-code
                and tt-alc-report-head.transaction-type = v-transaction-type
            no-error .
            if not available tt-alc-report-head then do:
              /* если внешний приход, то ищем ЕГАИС код поставщика */
              if buf_ot-line.ext-doc-type = {&TDEDT_PRI_VNESH} then do :
                run find-supp-egais-code in this-procedure ( input  buf_trn-doc.cli-type
                                                           , input  buf_trn-doc.cli-code
                                                           , output v-supplier-id
                                                           ) .
                if v-supplier-id = ? then do:
                  assign
                    v-unbinded-suppliers = yes
                  .
                  run write-error in this-procedure ( substitute( "Не найден ЕГАИС код для поставщика &1 &2. Строка исключена из отчета."
                                                                , buf_trn-doc.cli-type
                                                                , buf_trn-doc.cli-code
                                                                )
                                                    ) .
                  next _wast-ot-line.
                end.
              end.
              else do:
                assign
                  v-supplier-id = ?
                .
              end.
              assign
                v-transaction-date  = buf_trn-doc.fact-date
                v-doc-date          = buf_trn-doc.fact-date
              .
              create tt-alc-report-head.
              assign
                tt-alc-report-head.obj-type         = obj-list.obj-type
                tt-alc-report-head.obj-code         = obj-list.obj-code
                tt-alc-report-head.doc-code         = buf_trn-doc.doc-code
                tt-alc-report-head.lic-series       = v-lic-series
                tt-alc-report-head.lic-number       = v-lic-number
                tt-alc-report-head.lic-addendum     = v-lic-addendum
                tt-alc-report-head.transaction-date = v-transaction-date
                tt-alc-report-head.transaction-type = v-transaction-type
                tt-alc-report-head.doc-date         = v-doc-date
                tt-alc-report-head.supplier-id      = v-supplier-id
              .
            end. /* if not available tt-alc-report-head */

            create tt-alc-report-line.
            assign
              tt-alc-report-line.doc-code             = buf_trn-doc.doc-code
              tt-alc-report-line.obj-type             = obj-list.obj-type
              tt-alc-report-line.obj-code             = obj-list.obj-code
              tt-alc-report-line.transaction-type     = v-transaction-type
              tt-alc-report-line.gds-code             = tt-gds.gds-code
              tt-alc-report-line.egais-gds-code       = v-gds-egais-code
              tt-alc-report-line.quantity             = buf_doc-line-sum.fact-qnty
              tt-alc-report-line.is-quantity-discrete = v-is-quantity-discrete
              tt-alc-report-line.doc-date             = v-doc-date
              tt-alc-report-line.doc-number           = buf_ot-line.doc-code
            .
          end. /* if buf_doc-line-sum.fact-qnty > 0 */
        end. /* if available buf_doc-line-sum */
      end. /* _wast-ot-line: */
    end. /* for each tt-gds */


  end. /* for each obj-list */


end.

end procedure. /* fill-tt-rep */

/* ================================================================= */
procedure write-xml-files :

  define variable v-file-counter  as integer   no-undo .
  define variable v-file-name     as character no-undo .
  define variable v-sch-file      as character no-undo .


do
on error undo, return error return-value
:
&scop lvl-1 {&tabulation}
&scop lvl-2 fill( {&tabulation} , 2)
&scop lvl-3 fill( {&tabulation} , 3)
&scop lvl-4 fill( {&tabulation} , 4)

  for each tt-alc-report-head :
    /* формируем имя файла */
    assign
      v-file-counter = v-file-counter + 1
      v-file-name    = v-dir-name + string( v-file-counter , "99999999" )  + ".xml":U
      v-sch-file     = search( v-file-name ) .
    .
    /* проверяем что такого файла еще нет */
    if v-sch-file <> ? then do:
      message
        substitute( "В директории &1 уже есть файл с именем &2.&3Отчет не может быть сформирован.&3Переместите или удалите все файлы с расширением XML из указаной директории."
                  , v-dir-name
                  , v-file-name
                  , {&new-line}
                  )
      view-as alert-box error.
      return error .
    end.
    /* добавляем его в список */
    create tt-xml-file.
    assign
      tt-xml-file.file-id   = v-file-counter
      tt-xml-file.file-name = v-file-name
    .
    output stream xml-out to value(v-file-name) convert target "utf-8".
      put stream xml-out unformatted "<?xml version='1.0' encoding='UTF-8'?>":U skip.
      put stream xml-out unformatted '<Transactions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="mosdecl-primary-document-v.1.0.xsd">':U skip.
      put stream xml-out unformatted "<SingleTransaction>":U skip.
        put stream xml-out unformatted substitute( "&1<TransactionHeader>":U , {&lvl-1} )skip.

            put stream xml-out unformatted substitute( "&1<TransactionLicense>":U , {&lvl-2} )  skip.
            put stream xml-out unformatted substitute( "&1<LicSeries>&2</LicSeries>":U , {&lvl-3} ,tt-alc-report-head.lic-series ) skip.
            put stream xml-out unformatted substitute( "&1<LicNumber>&2</LicNumber>":U , {&lvl-3} ,tt-alc-report-head.lic-number ) skip.
            put stream xml-out unformatted substitute( "&1<LicAddendum>&2</LicAddendum>":U , {&lvl-3} ,tt-alc-report-head.lic-addendum ) skip.
          put stream xml-out unformatted substitute( "&1</TransactionLicense>":U , {&lvl-2} ) skip.
          put stream xml-out unformatted substitute( "&1<TransactionType>&2</TransactionType>" , {&lvl-2} ,tt-alc-report-head.transaction-type ) skip.

          put stream xml-out unformatted substitute( "&1<TransactionDocument>":U , {&lvl-2} ) skip.
            put stream xml-out unformatted substitute( "&1<DocDate>&2</DocDate>" , {&lvl-3} , get-date-str( tt-alc-report-head.doc-date ) ) skip.
            put stream xml-out unformatted substitute( "&1<DocNumber>&2</DocNumber>" , {&lvl-3} , tt-alc-report-head.doc-code ) skip.
          put stream xml-out unformatted substitute( "&1</TransactionDocument>":U , {&lvl-2} ) skip.
          if tt-alc-report-head.supplier-id <> ? then do:
            put stream xml-out unformatted substitute( "&1<SupplierID>&2</SupplierID>" , {&lvl-2} , tt-alc-report-head.supplier-id ) skip.
          end.
        put stream xml-out unformatted substitute( "&1</TransactionHeader>":U , {&lvl-1} )skip.

      /* TransactionLines */
      for each tt-alc-report-line
        where tt-alc-report-line.obj-type         = tt-alc-report-head.obj-type
          and tt-alc-report-line.obj-code         = tt-alc-report-head.obj-code
          and tt-alc-report-line.doc-code         = tt-alc-report-head.doc-code
          and tt-alc-report-line.transaction-type = tt-alc-report-head.transaction-type
      :
        put stream xml-out unformatted substitute( "&1<TransactionLines>":U , {&lvl-1} ) skip.
          put stream xml-out unformatted substitute( "&1<ItemId>&2</ItemId>" , {&lvl-2} , tt-alc-report-line.egais-gds-code ) skip.
          put stream xml-out unformatted substitute( "&1<Quantity>&2</Quantity>" , {&lvl-2} , tt-alc-report-line.quantity ) skip.
          put stream xml-out unformatted substitute( "&1<IsQuantityDiscrete>&2</IsQuantityDiscrete>" , {&lvl-2} , tt-alc-report-line.is-quantity-discrete ) skip.
        put stream xml-out unformatted substitute( "&1</TransactionLines>":U , {&lvl-1} ) skip.
      end.

      put stream xml-out unformatted "</SingleTransaction>":U skip.
      put stream xml-out unformatted "</Transactions>":U .
    output stream xml-out close.
  end.


end.

end procedure. /* write-xml-files */

/* ================================================================= */
procedure pack-xml-files :

  define variable v-arc             as character no-undo .
  define variable v-txt             as character no-undo .
  define variable v-list-file-name  as character no-undo .
  define variable v-arc-file-name   as character no-undo .

do
on error undo, return error return-value
:
  assign
    v-arc-file-name = v-dir-name + "report.zip":U
  .

  /* Есть ли архиватор  */
  if search( "exe/7za.exe" ) = ? then do:
    return error("Не найдена программа 7za.exe, невозможно упаковать файлы в архив.").
  end.
  v-arc = search( "exe/7za.exe" ).

  if search( v-arc-file-name ) <> ? then do:
    return error substitute ( "Файл &1 уже существует. Создание архива невозможно." , v-arc-file-name ).
  end.

  run gbl/_tmpfile.p ( "lst":u , ".txt":u , output v-list-file-name ).

  output stream lst-out to value(v-list-file-name).
  for each tt-xml-file :
    put stream lst-out unformatted tt-xml-file.file-name skip.
  end.

  output stream lst-out close.

  assign
    v-txt = substitute( "&1 a -tzip &2 @&3"
                      , v-arc
                      , v-arc-file-name
                      , v-list-file-name
                      )
  .

  os-command silent value ( v-txt ) .

  os-delete value( v-list-file-name ) .

  for each tt-xml-file :
     os-delete value( tt-xml-file.file-name ) .
  end.

end.

end procedure. /* pack-xml-files */

/* ================================================================= */
procedure write-error :
  define input  parameter p-err-message as character no-undo .

do
on error undo, return error return-value
:
  output stream serr to "alcdcl01.err" append.
  put stream serr unformatted substitute("[&1 &2] : &3"
                                        , today
                                        , string( time , "hh:mm:ss")
                                        , p-err-message
                                        ) skip(1).
  output stream serr close.
end.

end procedure. /* write-error */

/* ================================================================= */
function get-date-str return character (input p-date as date) .
  return substitute( "&1-&2-&3"
                   , year( p-date)
                   , month( p-date)
                   , day( p-date )
                   ).
end.