block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: alcdcl06.p $
$Archive: rep/alcdcl06.p $

Декларация об объемах розничной продажи алкогольной продукции (Нижегородская область)

Автор: Хныкин Павел Андреевич
Дата создания: 12/01/08
Author: Pavel Khnykin
Creation date: 12/01/08

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: alcdcl06.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/alcdcl06.p $":U .
define variable vss-description as character no-undo init "Декларация об объемах розничной продажи алкогольной продукции (Нижегородская область)".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ cmp/r-pril.i new   }
{ cmp/r-page1.i      }
{ gbl/prn-lib.i      }
{ rep/r-sym.i        }
{ rep/fmtcli.i       }
{ trg/factord.i      }
{ gbl/clntattr.i     }
{ rep/ost-line.i     }
{ rep/lkp-font.i     }
{ rep/prg-bar.i run  }
{ gbl/paramls.i      }
{ gbl/getsect.i def  }

define variable g#report-num   as integer no-undo .
run get-report-num in my-handle (output g#report-num).
{ rep/alc06xl.i     }


define stream out-stream .

define temp-table tt-gds no-undo like ub.goods
  field alc-type-inner-code like ub.alc-type.alc-type-inner-code
  field create-user-db-num  like ub.alc-type.create-user-db-num
  field alc-type-code       like ub.alc-type.alc-type-code
  field alc-type-name       like ub.alc-type.alc-type-name
  field gds-man-type        as integer
index pi is primary unique
  gds-code
index alc-type
  alc-type-inner-code
  create-user-db-num
index alc-type-code
  alc-type-code
.

define temp-table tt-alc-retail no-undo
  /* вид алкогольной продукции */
  field alc-type-code like ub.alc-type.alc-type-code
  field alc-type-name like ub.alc-type.alc-type-name

  /* Остаток на начало отчетного периода */
  field ost-beg       as decimal
  /* Поступило за отчетный период */
  field pri-prod      as decimal /* от производителей */
  field pri-org       as decimal /* от организаций оптовой торговли */
  field pri-tot       as decimal /* всего */
  /* Продано за отчетный период */
  field sale-loc-prod as decimal /* произведенная нижегородскими товаропроизводителями */
  field sale-tot      as decimal
  /* Остаток на конец отчетного периода */
  field ost-end       as decimal
index pi is primary unique
  alc-type-code
.

/* приходы алкогольной продукции */
define temp-table tt-alc-pri no-undo
  field cli-name        like ub.clients.obj-name
  field cli-type        like ub.clients.obj-type
  field cli-code        like ub.clients.obj-code
  field cli-inn         as character
  field cli-address     as character
  field lic-num         as character
  field lic-give        as character
  field alc-type-name   like ub.alc-type.alc-type-name
  field alc-type-code   like ub.alc-type.alc-type-code
  field quantity        as decimal
index pi is primary unique
  alc-type-code
  cli-type
  cli-code
index cli
  cli-type
  cli-code
  alc-type-code
.

define temp-table tt-alc-pri-tmp no-undo
  field cli-type            like ub.clients.obj-type
  field cli-code            like ub.clients.obj-code
  field alc-type-inner-code like ub.alc-type.alc-type-inner-code
  field alc-type-code       like ub.alc-type.alc-type-code
  field alc-type-name       like ub.alc-type.alc-type-name
  field doc-code            like ub.trn-doc.doc-code
  field gds-code            like ub.goods.gds-code
  field quantity            as decimal
index pi is primary unique
  alc-type-inner-code
  cli-type
  cli-code
  doc-code
  gds-code
index cli
  cli-type
  cli-code
  alc-type-code
.

define variable v-i                       as integer    no-undo .
define variable v-line                    as character  no-undo .
define variable v-par-type                as character  no-undo .
define variable v-begin-date              as date       no-undo .
define variable v-end-date                as date       no-undo .
define variable v-host-code               like ub.clients.host-code  no-undo .
define variable v-host-code-2             like ub.clients.host-code  no-undo .
define variable v-alc-type-count          as integer    no-undo .
define variable v-gds-count               as integer    no-undo .
define variable v-fact-order-start        as decimal    no-undo .
define variable v-fact-order-end          as decimal    no-undo .

/* Данные для шапки */
define variable v-firm-name     as character no-undo .
define variable v-firm-inn      as character no-undo .
define variable v-firm-address  as character no-undo .
define variable v-obj-count     as character no-undo .
define variable v-lic-info      as character no-undo .
define variable v-activity      as character no-undo .
define variable v-date-range    as character no-undo .

main-block:
do
on error undo, return error return-value
:
  { gbl/working.i }
  { gbl/getcntxt.i def }
  { gbl/getcntxt.i get " " my-handle }

  { gbl/getsect.i run "''" 0 {&attr-report-glob} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'ardecldt' then v-begin-date = thbjattr_thbj-attr.property-value-date .
  end.

  find first obj-list no-lock no-error .
  if not available obj-list then do:
    message
      "Нет ни одного объекта для формирования отчета!"
    view-as alert-box error.
    return error return-value.
  end.
  { gbl/hostcode.i obj-list.obj-type obj-list.obj-code v-host-code }
  for each obj-list :
    { gbl/hostcode.i obj-list.obj-type obj-list.obj-code v-host-code-2 }
    if v-host-code <> v-host-code-2 then do:
      message
        "Отчет формируется только по объектам одной фирмы."
      view-as alert-box error.
      return error return-value.
    end.
  end.

  run alc06xl-init in this-procedure .
  { cmp/open-out.i stream out-stream " " {&LS_PS_A4} }

  put stream out-stream "Отчет выводится только в Excel..." skip.

  assign
    v-end-date    = x-Date-Alone
    v-line        = fill( "-" , 300 )
  .
  run day-begin-fact-order in this-procedure ( input v-begin-date, output v-fact-order-start ). /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input ( v-end-date + 1 ),   output v-fact-order-end ). /*Поиск посл fact-order*/
  run clear-all in this-procedure .
  run prg-bar_init-cb-handle in this-procedure (v-d-report-handle) .


  run find-alc-goods in this-procedure ( output v-gds-count ).
  run fill-tt-alc-pri in this-procedure .
  run fill-tt-alc-retail in this-procedure .
  run load-head-info in this-procedure .
  run print-alc-pri in this-procedure .
  run print-alc-retail in this-procedure .

  output stream out-stream close.
  {&CloseExcel}
  run alc06xl-close in this-procedure .
  { gbl/stopwork.i }
  run clear-all in this-procedure .

  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
    value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
  .

  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
  run gbl/prnfilen.w
      (input  ""
      ,input  20
      ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
      ,input  ReportFontNum
      ,output v-user-action
      ,output v-printed
      ) .
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .

end. /* main-block: */

/* ===================================================================================================== */
procedure clear-all :

do
on error undo, return error return-value
:
  empty temp-table tt-gds.
  empty temp-table tt-alc-pri.
  empty temp-table tt-alc-pri-tmp.
  empty temp-table tt-alc-retail.
end.

end procedure. /* clear-all */

/* ===================================================================================================== */
procedure find-alc-goods :
  define output parameter p-gds-count as integer   no-undo .
do
on error undo, return error return-value
:

  define buffer buf_alc-type      for ub.alc-type.
  define buffer buf_alc-type-gds  for ub.alc-type-gds.
  define buffer buf_goods         for ub.goods.

  define variable v-gds-type as integer   no-undo .

  /* заполняем список алкогольных товаров */
  empty temp-table tt-gds.
  for each buf_alc-type no-lock
        where buf_alc-type.alc-type-status = 0
  :
    _gds:
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
          v-alc-type-count           = v-alc-type-count + 1
          p-gds-count                = p-gds-count + 1
        .
      end.
    end.
  end.

end.

end procedure. /* find-alc-goods */

/* ===================================================================================================== */
procedure fill-tt-alc-pri :

do
on error undo, return error return-value
:
  define buffer buf_doc-line    for ub.doc-line.
  define buffer buf_trn-doc     for ub.trn-doc.
  define buffer buf_parts       for ub.parts.
  define buffer buf_clients     for ub.clients.


  define buffer buf_tt-gds          for tt-gds.
  define buffer buf_tt-alc-pri      for tt-alc-pri.
  define buffer buf_tt-alc-pri-tmp  for tt-alc-pri-tmp.

  define variable v-sert            as character no-undo .
  define variable v-sert-give       as character no-undo .


  run prg-bar_new in this-procedure (1 , v-gds-count).
  run prg-bar_title in this-procedure ( input substitute( "Обработка документов типа: &1...":U
                                                        ,
                                                        entry(lookup({&TDEDT_Pri_Vnesh}, {&tdedt_list}), {&tdedt_list-full})
                                                        )
                                      ).
  run prg-bar_show in this-procedure .
  for each buf_tt-gds
  :
    run prg-bar_increment in this-procedure .
    for each obj-list no-lock
    :
      for each buf_doc-line no-lock
        where buf_doc-line.artic        = buf_tt-gds.artic
          and buf_doc-line.prod-type    = buf_tt-gds.prod-type
          and buf_doc-line.prod-code    = buf_tt-gds.prod-code
          and buf_doc-line.obj-type     = obj-list.obj-type
          and buf_doc-line.obj-code     = obj-list.obj-code
          and buf_doc-line.status_      = {&fact}
          and buf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh}
          and buf_doc-line.fact-order   >= v-fact-order-start
          and buf_doc-line.fact-order   <  v-fact-order-end,
        first buf_trn-doc no-lock
          where buf_trn-doc.doc-code    = buf_doc-line.doc-code
      :
        find first buf_tt-alc-pri-tmp
          where buf_tt-alc-pri-tmp.alc-type-inner-code = buf_tt-gds.alc-type-inner-code
            and buf_tt-alc-pri-tmp.cli-type            = buf_trn-doc.cli-type
            and buf_tt-alc-pri-tmp.cli-code            = buf_trn-doc.cli-code
            and buf_tt-alc-pri-tmp.doc-code            = buf_trn-doc.doc-code
            and buf_tt-alc-pri-tmp.gds-code            = buf_tt-gds.gds-code
        no-error .
        if not available buf_tt-alc-pri-tmp
        then do:
          create buf_tt-alc-pri-tmp.
          assign
            buf_tt-alc-pri-tmp.alc-type-inner-code  = buf_tt-gds.alc-type-inner-code
            buf_tt-alc-pri-tmp.alc-type-code        = buf_tt-gds.alc-type-code
            buf_tt-alc-pri-tmp.alc-type-name        = buf_tt-gds.alc-type-name
            buf_tt-alc-pri-tmp.cli-type             = buf_trn-doc.cli-type
            buf_tt-alc-pri-tmp.cli-code             = buf_trn-doc.cli-code
            buf_tt-alc-pri-tmp.doc-code             = buf_trn-doc.doc-code
            buf_tt-alc-pri-tmp.gds-code             = buf_tt-gds.gds-code
            buf_tt-alc-pri-tmp.quantity             = ( buf_doc-line.fact-qnty * buf_tt-gds.ms-base / 10 )
          .
        end.
      end.
    end.

  end. /* for each tt-gds, */
  run prg-bar_delete in this-procedure .
  run calc-ext-type-pri in this-procedure ( input {&TDEDT_Pri_Perem}    ) .
  run calc-ext-type-pri in this-procedure ( input {&TDEDT_Vozvrat_Perem}) .

  for each buf_tt-alc-pri-tmp
    break by buf_tt-alc-pri-tmp.cli-type
          by buf_tt-alc-pri-tmp.cli-code
          by buf_tt-alc-pri-tmp.alc-type-code
  :
    find first buf_tt-alc-pri
      where buf_tt-alc-pri.alc-type-code  = buf_tt-alc-pri-tmp.alc-type-code
        and buf_tt-alc-pri.cli-type       = buf_tt-alc-pri-tmp.cli-type
        and buf_tt-alc-pri.cli-code       = buf_tt-alc-pri-tmp.cli-code
    no-error .
    if    first-of(buf_tt-alc-pri-tmp.cli-type)
      or  first-of(buf_tt-alc-pri-tmp.cli-code)
      or  first-of(buf_tt-alc-pri-tmp.alc-type-code)
    then do:
      if     first-of(buf_tt-alc-pri-tmp.cli-type)
         or  first-of(buf_tt-alc-pri-tmp.cli-code)
      then do:
        /* реквизиты поставщика */
        run fmtcli-get-client in this-procedure ( input buf_tt-alc-pri-tmp.cli-type, input buf_tt-alc-pri-tmp.cli-code ) .
        /* лицензия  */
        run find-sert in this-procedure ( input buf_tt-alc-pri-tmp.cli-type
                                        , input buf_tt-alc-pri-tmp.cli-code
                                        , input buf_tt-alc-pri-tmp.alc-type-inner-code
                                        , output v-sert
                                        , output v-sert-give ) .
      end. /* if     first-of(buf_tt-alc-pri-tmp.cli-type) */
      if not available buf_tt-alc-pri
      then do:
        create buf_tt-alc-pri.
        assign
          buf_tt-alc-pri.alc-type-code  = buf_tt-alc-pri-tmp.alc-type-code
          buf_tt-alc-pri.alc-type-name  = buf_tt-alc-pri-tmp.alc-type-name
          buf_tt-alc-pri.cli-type       = buf_tt-alc-pri-tmp.cli-type
          buf_tt-alc-pri.cli-code       = buf_tt-alc-pri-tmp.cli-code
          buf_tt-alc-pri.cli-name       = v-fmtcli-name
          buf_tt-alc-pri.cli-inn        = v-fmtcli-inn
          buf_tt-alc-pri.cli-address    = v-fmtcli-addres
          buf_tt-alc-pri.lic-num        = v-sert
          buf_tt-alc-pri.lic-give       = v-sert-give
        .
      end. /* if not available buf_tt-alc-pri */
    end. /* if    first-of(buf_tt-alc-pri-tmp.cli-type) */
    assign
      buf_tt-alc-pri.quantity = buf_tt-alc-pri.quantity + buf_tt-alc-pri-tmp.quantity
    .
  end. /* for each buf_tt-alc-pri-tmp */

end.

end procedure. /* fill-tt-alc-pri */

procedure calc-ext-type-pri :
  define input  parameter p-ext-doc-type as character no-undo .
do
on error undo, return error return-value
:
  define buffer buf_doc-line  for ub.doc-line .
  define buffer buf_parts     for ub.parts .
  define buffer buf_trn-doc   for ub.trn-doc .
  define buffer sch_trn-doc   for ub.trn-doc.

  define buffer buf_obj-list        for obj-list.
  define buffer buf_tt-gds          for tt-gds.
  define buffer buf_tt-alc-pri-tmp  for tt-alc-pri-tmp.

  define variable v-income-doc-code as character no-undo .
  define variable v-ext-doc-type    like ub.parts-attr.ext-doc-type no-undo .
  define variable v-obj-type        like ub.parts-attr.obj-type     no-undo .
  define variable v-obj-code        like ub.parts-attr.obj-code     no-undo .
  define variable v-supp-type       like ub.parts-attr.supp-type    no-undo .
  define variable v-supp-code       like ub.parts-attr.supp-code    no-undo .
  define variable v-fact-order      like ub.parts-attr.fact-order   no-undo .


  run prg-bar_new in this-procedure (1 , v-gds-count).
  run prg-bar_title in this-procedure ( input substitute( "Обработка документов типа: &1...":U
                                                        ,
                                                        entry(lookup(p-ext-doc-type, {&tdedt_list}), {&tdedt_list-full})
                                                        )
                                      ).

  run prg-bar_show in this-procedure .

  for each buf_tt-gds
  :
    run prg-bar_increment in this-procedure .
    for each obj-list no-lock
    :
      for each buf_doc-line no-lock
        where buf_doc-line.artic      = buf_tt-gds.artic
          and buf_doc-line.prod-type  = buf_tt-gds.prod-type
          and buf_doc-line.prod-code  = buf_tt-gds.prod-code
          and buf_doc-line.obj-type   = obj-list.obj-type
          and buf_doc-line.obj-code   = obj-list.obj-code
          and buf_doc-line.status_    = {&fact}
          and buf_doc-line.ext-doc-type = p-ext-doc-type
          and buf_doc-line.fact-order >= v-fact-order-start
          and buf_doc-line.fact-order <  v-fact-order-end
      :
          parts-cycle:
          for each buf_parts no-lock
            where buf_parts.out-code  = buf_doc-line.doc-code
              and buf_parts.obj-type  = obj-list.obj-type
              and buf_parts.obj-code  = obj-list.obj-code
              and buf_parts.artic     = buf_doc-line.artic
              and buf_parts.prod-type = buf_doc-line.prod-type
              and buf_parts.prod-code = buf_doc-line.prod-code
          :
            run find-income-doc-code in this-procedure ( input buf_parts.in-code
                                                      , input buf_tt-gds.gds-code
                                                      , input buf_parts.part-code
                                                      , output v-income-doc-code
                                                       , output v-ext-doc-type
                                                       , output v-fact-order
                                                       , output v-obj-type
                                                       , output v-obj-code
                                                       , output v-supp-type
                                                       , output v-supp-code
                                                      ).
            if v-income-doc-code = ?
            then do:
              message
                substitute("Не могу найти приходную накладную с номером: &1", buf_parts.in-code) skip
                "Отчет будет сформирован некорректно":U
              view-as alert-box error .
              next parts-cycle.
            end.

            /*
              если партия из документа за отчетный период и по объекту из списка объектов
              участвующих в формировании отчета, то пропускаем его, он учтется как внешний приход
            */
            if    v-ext-doc-type = {&TDEDT_Pri_Vnesh}
              and v-fact-order   >= v-fact-order-start
              and v-fact-order   <  v-fact-order-end
            then do:
              find first buf_obj-list no-lock
                where buf_obj-list.obj-type = v-obj-type
                  and buf_obj-list.obj-code = v-obj-code
              no-error .
              if available buf_obj-list then do :
                next parts-cycle.
              end.
            end.

            find first buf_tt-alc-pri-tmp
              where buf_tt-alc-pri-tmp.alc-type-inner-code = buf_tt-gds.alc-type-inner-code
                and buf_tt-alc-pri-tmp.cli-type            = v-supp-type
                and buf_tt-alc-pri-tmp.cli-code            = v-supp-code
                and buf_tt-alc-pri-tmp.doc-code            = v-income-doc-code
                and buf_tt-alc-pri-tmp.gds-code            = buf_tt-gds.gds-code
            no-error .
            if not available buf_tt-alc-pri-tmp
            then do:
              create buf_tt-alc-pri-tmp.
              assign
                buf_tt-alc-pri-tmp.alc-type-inner-code = buf_tt-gds.alc-type-inner-code
                buf_tt-alc-pri-tmp.alc-type-code       = buf_tt-gds.alc-type-code
                buf_tt-alc-pri-tmp.alc-type-name        = buf_tt-gds.alc-type-name
                buf_tt-alc-pri-tmp.cli-type            = v-supp-type
                buf_tt-alc-pri-tmp.cli-code            = v-supp-code
                buf_tt-alc-pri-tmp.doc-code            = v-income-doc-code
                buf_tt-alc-pri-tmp.gds-code            = buf_tt-gds.gds-code
              .
            end.
            assign
              buf_tt-alc-pri-tmp.quantity = buf_tt-alc-pri-tmp.quantity + ( buf_parts.fact-qnty * buf_tt-gds.ms-base / 10 )
            .
          end.
      end.
    end.
  end.
  run prg-bar_delete in this-procedure .
end.

end procedure. /* calc-ext-type-pri */

/* ===================================================================================================== */
procedure find-income-doc-code :
  define input  parameter p-in-code         like ub.parts.in-code           no-undo .
  define input  parameter p-gds-code        like ub.goods.gds-code          no-undo .
  define input  parameter p-part-code       like ub.parts.part-code         no-undo .
  define output parameter p-income-doc-code like ub.parts.in-code           no-undo .
  define output parameter p-ext-doc-type    like ub.parts-attr.ext-doc-type no-undo .
  define output parameter p-fact-order      like ub.parts-attr.fact-order   no-undo .
  define output parameter p-obj-type        like ub.parts-attr.obj-type     no-undo .
  define output parameter p-obj-code        like ub.parts-attr.obj-code     no-undo .
  define output parameter p-supp-type       like ub.parts-attr.supp-type    no-undo .
  define output parameter p-supp-code       like ub.parts-attr.supp-code    no-undo .

define buffer buf_parts-attr        for ub.parts-attr .
define buffer buf_income_parts-attr for ub.parts-attr .


do on error undo, return error return-value :
  assign
    p-income-doc-code = ?
    p-ext-doc-type    = ?
    p-fact-order      = ?
    p-obj-type        = ?
    p-obj-code        = ?
    p-supp-type       = ?
    p-supp-code       = ?
  .
  find first buf_parts-attr no-lock
    where buf_parts-attr.in-code   = p-in-code
      and buf_parts-attr.gds-code  = p-gds-code
      and buf_parts-attr.part-code = p-part-code
  no-error .
  if available buf_parts-attr
  then do:
    find first buf_income_parts-attr no-lock
      where buf_income_parts-attr.in-code   = buf_parts-attr.income-in-code
        and buf_income_parts-attr.gds-code  = buf_parts-attr.income-gds-code
        and buf_income_parts-attr.part-code = buf_parts-attr.income-part-code
      no-error .
    if available buf_income_parts-attr
    then do:
      assign
        p-income-doc-code = buf_parts-attr.income-in-code
        p-ext-doc-type    = buf_parts-attr.ext-doc-type
        p-fact-order      = buf_parts-attr.fact-order
        p-obj-type        = buf_parts-attr.obj-type
        p-obj-code        = buf_parts-attr.obj-code
        p-supp-type       = buf_parts-attr.supp-type
        p-supp-code       = buf_parts-attr.supp-code
      .
    end.
    else do:
      return . /* --->>>--- */
    end.
  end.
  else do:
    return . /* --->>>--- */
  end.
end. /* do */

end procedure. /* find-income-doc-code */

/* ===================================================================================================== */
procedure find-sert :
/*
  Нахождение номера сертификата и кем он выдан клиенту.
*/

  define input  parameter p-cli-type            like ub.trn-doc.cli-type no-undo .
  define input  parameter p-cli-code            like ub.trn-doc.cli-code no-undo .
  define input  parameter p-alc-type-inner-code like ub.alc-type.alc-type-inner-code no-undo .
  define output parameter p-sert      as character          no-undo .
  define output parameter p-sert-give as character          no-undo .

define buffer buf_alc-supp-lic      for ub.alc-supp-lic.
define buffer buf_alc-supp-lic-type for ub.alc-supp-lic-type.

do
on error undo, return error return-value
:
  assign
    p-sert       = "":U
    p-sert-give  = "":U
  .
  for each buf_alc-supp-lic no-lock
    where buf_alc-supp-lic.cli-type = p-cli-type
      and buf_alc-supp-lic.cli-code = p-cli-code
      and buf_alc-supp-lic.date-to  > v-end-date

  :
    if buf_alc-supp-lic.all-type = 0
    then do:
      find first buf_alc-supp-lic-type no-lock
        where buf_alc-supp-lic-type.alc-supp-lic-code   = buf_alc-supp-lic.alc-supp-lic-code
          and buf_alc-supp-lic-type.alc-type-inner-code = p-alc-type-inner-code
      no-error.
      if not available buf_alc-supp-lic-type
      then do:
          next.
      end.
    end.
    assign
      p-sert       =  substitute( "&1 &2 от &3"
                                , buf_alc-supp-lic.seria
                                , buf_alc-supp-lic.number
                                , buf_alc-supp-lic.date-from
                                )
      p-sert-give  = substitute( "&1" , buf_alc-supp-lic.who-are-got )
    .
    return.
  end. /* for each */
end.
end procedure. /* find-sert */

/* ===================================================================================================== */
procedure fill-tt-alc-retail :

do
on error undo, return error return-value
:
  define buffer buf_alc-type  for ub.alc-type.
  define buffer buf_ot-line   for ub.ot-line.
  define buffer buf_trn-doc   for ub.trn-doc.
  define buffer sch_trn-doc   for ub.trn-doc.
  define buffer buf_parts     for ub.parts.


  define buffer buf_tt-gds        for tt-gds.
  define buffer buf_obj-list      for obj-list.
  define buffer buf_tt-alc-retail for tt-alc-retail.

  define variable var-x-store-code    like ub.clients.obj-code    no-undo.
  define variable var-x-store-type    like ub.clients.obj-type    no-undo.
  define variable var-x-date-start    like ub.stk-tot.Fact-date   no-undo.
  define variable var-x-date-endt     like ub.stk-tot.Fact-date   no-undo.
  define variable var-x-sum-type      like ub.stk-tot.sum-type    no-undo.
  define variable var-x-ost-sum-type  like ub.stk-tot.sum-type    no-undo.
  define variable var-x-cat-id        like ub.stk-tot.cat-id      no-undo.
  define variable var-xTog-obj        as   logical             no-undo.
  define variable var-x-artic         like ub.stk-line.artic        no-undo.
  define variable var-x-prod-code     like ub.stk-line.prod-code    no-undo.
  define variable var-x-prod-type     like ub.stk-line.prod-type    no-undo.

  define variable var-Quantity        like ub.stk-tot.fact-qnty   initial ? no-undo.
  define variable var-Coast_R         like ub.stk-tot.sum-rubl    no-undo.
  define variable var-Coast_V         like ub.stk-tot.sum-rubl    no-undo.
  define variable var-VAT_R           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-VAT_V           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-SLT_R           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-SLT_V           like ub.stk-tot.sum-rubl    no-undo.

  define variable v-ost-begin-qnty          as decimal               no-undo .
  define variable v-ost-end-qnty            as decimal               no-undo .
  define variable v-ot-line-qnty            as decimal               no-undo .
  define variable v-parts-line-qnty         as decimal               no-undo .
  define variable v-retail-ost-beg          as decimal               no-undo .
  define variable v-retail-pri-prod         as decimal               no-undo .
  define variable v-retail-pri-org          as decimal               no-undo .
  define variable v-retail-pri-tot          as decimal               no-undo .
  define variable v-retail-sale-loc-prod    as decimal               no-undo .
  define variable v-retail-sale-tot         as decimal               no-undo .
  define variable v-retail-ost-end          as decimal               no-undo .
  define variable v-income-doc-code         as character             no-undo .
  define variable v-ext-doc-type    like ub.parts-attr.ext-doc-type  no-undo .
  define variable v-obj-type        like ub.parts-attr.obj-type      no-undo .
  define variable v-obj-code        like ub.parts-attr.obj-code      no-undo .
  define variable v-supp-type       like ub.parts-attr.supp-type     no-undo .
  define variable v-supp-code       like ub.parts-attr.supp-code     no-undo .
  define variable v-fact-order      like ub.parts-attr.fact-order    no-undo .
  define variable v-attr-val                as character             no-undo .
  define variable v-attr-type               as character             no-undo .
  define variable v-is-local-producer       as logical               no-undo .

  /*
  /* вид алкогольной продукции */
  field alc-type-code like ub.alc-type.alc-type-code
  field alc-type-name like ub.alc-type.alc-type-name

  /* Остаток на начало отчетного периода */
  field ost-beg       as decimal
  field pri-prod      as decimal /* от производителей */
  field pri-org       as decimal /* от организаций оптовой торговли */
  field pri-tot       as decimal /* всего */
  field sale-loc-prod as decimal /* произведенная нижегородскими товаропроизводителями */
  field sale-tot      as decimal
  field ost-end       as decimal
  */



  run prg-bar_new in this-procedure (1 , v-gds-count).
  run prg-bar_title in this-procedure ( input "Обработка...":U ).
  run prg-bar_show in this-procedure .

  for each buf_alc-type no-lock
        where buf_alc-type.alc-type-status = 0
  :
    find first buf_tt-alc-retail
      where buf_tt-alc-retail.alc-type-code = buf_alc-type.alc-type-code
    no-error .
    if not available buf_tt-alc-retail
    then do:
      create buf_tt-alc-retail.
      assign
        buf_tt-alc-retail.alc-type-code = buf_alc-type.alc-type-code
        buf_tt-alc-retail.alc-type-name = buf_alc-type.alc-type-name
      .
    end.
    assign
      v-ost-begin-qnty        = 0
      v-ost-end-qnty          = 0
      v-ot-line-qnty          = 0
      v-retail-ost-beg        = 0
      v-retail-pri-prod       = 0
      v-retail-pri-org        = 0
      v-retail-pri-tot        = 0
      v-retail-sale-loc-prod  = 0
      v-retail-sale-tot       = 0
      v-retail-ost-end        = 0
    .

    for each buf_tt-gds
      where buf_tt-gds.alc-type-inner-code = buf_alc-type.alc-type-inner-code
        and buf_tt-gds.create-user-db-num  = buf_alc-type.create-user-db-num
    :
      run prg-bar_increment in this-procedure .

      run clntattr-value in this-procedure  ( input buf_tt-gds.prod-type
                                            , input buf_tt-gds.prod-code
                                            , input {&attr-cli-local}
                                            , output v-attr-val
                                            , output v-attr-type
                                            ).
      assign
        v-is-local-producer = logical(v-attr-val)
      no-error .
      if error-status :error
      then do:
        assign
          v-is-local-producer = false
        .
      end.

      for each obj-list
      :
        assign
          var-x-store-code    = obj-list.obj-code
          var-x-store-type    = obj-list.obj-type
          var-x-artic         = buf_tt-gds.artic
          var-x-prod-code     = buf_tt-gds.prod-code
          var-x-prod-type     = buf_tt-gds.prod-type
          var-x-cat-id        = {&root-cat-id}
          var-xTog-obj        = yes
          v-ost-begin-qnty    = 0
          v-ost-end-qnty      = 0
          var-x-sum-type      = {&arh-cost}
          var-x-ost-sum-type  = {&arh-cost}
        .

        /* остаток на начало */
        run ost-line  (
            input   var-x-store-code    ,
            input   var-x-store-type    ,
            INPUT   var-x-artic         ,
            INPUT   var-x-prod-code     ,
            INPUT   var-x-prod-type     ,
            input   no                  ,
            input   v-fact-order-start  ,
            input   var-x-ost-sum-type  ,
            input   var-x-cat-id        ,
            input   var-xTog-obj        ,
            output  var-Quantity        ,
            output  var-Coast_R         ,
            output  var-Coast_V         ,
            output  var-VAT_R           ,
            output  var-VAT_V           ,
            output  var-SLT_R           ,
            output  var-SLT_V           ).
        assign
          v-ost-begin-qnty = ( var-Quantity * buf_tt-gds.ms-base ) / 10
        .
        /* остаток на конец */
        run ost-line  (
            input   var-x-store-code    ,
            input   var-x-store-type    ,
            INPUT   var-x-artic         ,
            INPUT   var-x-prod-code     ,
            INPUT   var-x-prod-type     ,
            input   no                  ,
            input   v-fact-order-end    ,
            input   var-x-ost-sum-type  ,
            input   var-x-cat-id        ,
            input   var-xTog-obj        ,
            output  var-Quantity        ,
            output  var-Coast_R         ,
            output  var-Coast_V         ,
            output  var-VAT_R           ,
            output  var-VAT_V           ,
            output  var-SLT_R           ,
            output  var-SLT_V           ).
        assign
          v-ost-end-qnty = ( var-Quantity * buf_tt-gds.ms-base ) / 10
        .

        ot-line-cycle:
        for each buf_ot-line no-lock
          where buf_ot-line.artic        = buf_tt-gds.artic
            and buf_ot-line.prod-code    = buf_tt-gds.prod-code
            and buf_ot-line.prod-type    = buf_tt-gds.prod-type
            and buf_ot-line.fact-order   < v-fact-order-end  /* fact-order конца периода */
            and buf_ot-line.fact-order   >= v-fact-order-start  /* fact-order начала периода */
            and buf_ot-line.obj-code     = obj-list.obj-code
            and buf_ot-line.obj-type     = obj-list.obj-type
            and buf_ot-line.sum-type     = var-x-sum-type
        :
          find first buf_trn-doc no-lock
            where buf_trn-doc.doc-code = buf_ot-line.doc-code
          no-error .
          if not available buf_trn-doc then do:
            message
              vss-workfile vss-revision vss-description skip
              substitute( "Не найден складской документ &1.&2Документ не будет учтен в отчете." , buf_ot-line.doc-code , {&new-line} )
            view-as alert-box error .
            next ot-line-cycle.
          end.
          assign
            v-ot-line-qnty  = abs( buf_ot-line.fact-qnty * buf_tt-gds.ms-base ) / 10
          .
          case buf_ot-line.ext-doc-type
          :
            /* это приход */
            when {&TDEDT_PRI_VNESH}  then do :
              if ( buf_trn-doc.cli-type = buf_tt-gds.prod-type ) and
                 ( buf_trn-doc.cli-code = buf_tt-gds.prod-code )
              then do:
                assign
                  v-retail-pri-prod = v-retail-pri-prod + v-ot-line-qnty
                .
              end.
              else do:
                assign
                  v-retail-pri-org = v-retail-pri-org + v-ot-line-qnty
                .
              end.
              assign
                v-retail-pri-tot = v-retail-pri-tot + v-ot-line-qnty
              .
            end.
            when {&TDEDT_PRI_PEREM}     or
            when {&TDEDT_VOZVRAT_PEREM}
            then do :
              _buf_parts:
              for each buf_parts no-lock
                    where buf_parts.out-code  = buf_ot-line.doc-code
                      and buf_parts.obj-type  = buf_ot-line.obj-type
                      and buf_parts.obj-code  = buf_ot-line.obj-code
                      and buf_parts.artic     = buf_ot-line.artic
                      and buf_parts.prod-type = buf_ot-line.prod-type
                      and buf_parts.prod-code = buf_ot-line.prod-code
              :
                run find-income-doc-code in this-procedure ( input buf_parts.in-code
                                                           , input buf_tt-gds.gds-code
                                                           , input buf_parts.part-code
                                                           , output v-income-doc-code
                                                           , output v-ext-doc-type
                                                           , output v-fact-order
                                                           , output v-obj-type
                                                           , output v-obj-code
                                                           , output v-supp-type
                                                           , output v-supp-code
                                                           ).
                if v-income-doc-code = ?
                then do:
                  message
                    substitute("Не могу найти приходную накладную с номером: &1", buf_parts.in-code) skip
                    "Отчет будет сформирован некорректно":U
                  view-as alert-box error .
                  next _buf_parts.
                end.

                assign
                  v-parts-line-qnty = ( buf_parts.fact-qnty * buf_tt-gds.ms-base ) / 10
                .

                /*
                  если партия из документа за отчетный период и по объекту из списка объектов
                  участвующих в формировании отчета, то пропускаем его, он учтется как внешний приход
                */
                if    v-ext-doc-type = {&TDEDT_Pri_Vnesh}
                  and v-fact-order   >= v-fact-order-start
                  and v-fact-order   <= v-fact-order-end
                then do:
                  find first buf_obj-list no-lock
                    where buf_obj-list.obj-type = v-obj-type
                      and buf_obj-list.obj-code = v-obj-code
                  no-error .
                  if available buf_obj-list then do :
                    next _buf_parts.
                  end.
                end.

                if ( v-supp-type = buf_tt-gds.prod-type ) and
                   ( v-supp-code = buf_tt-gds.prod-code )
                then do:
                  assign
                    v-retail-pri-prod = v-retail-pri-prod + v-parts-line-qnty
                  .
                end.
                else do:
                  assign
                    v-retail-pri-org = v-retail-pri-org + v-parts-line-qnty
                  .
                end.
                assign
                  v-retail-pri-tot = v-retail-pri-tot + v-parts-line-qnty
                .
              end. /* for each buf_parts no-lock */
            end.
            /* расход */
            when {&TDEDT_RAS_VNESH_KASS}  then do :
              if(v-is-local-producer)
              then do:
                assign
                  v-retail-sale-loc-prod  = v-retail-sale-loc-prod + v-ot-line-qnty
                .
              end.
              assign
                v-retail-sale-tot = v-retail-sale-tot + v-ot-line-qnty
              .
            end.
          end case. /* case buf_ot-line.ext-doc-type */
        end. /* for each buf_ot-line no-lock */
        assign
          v-retail-ost-beg = v-retail-ost-beg + v-ost-begin-qnty
          v-retail-ost-end = v-retail-ost-end + v-ost-end-qnty
        .
      end. /* for each obj-list */
    end. /* for each buf_tt-gds */
    assign
      buf_tt-alc-retail.ost-beg       = buf_tt-alc-retail.ost-beg       + v-retail-ost-beg
      buf_tt-alc-retail.pri-prod      = buf_tt-alc-retail.pri-prod      + v-retail-pri-prod
      buf_tt-alc-retail.pri-org       = buf_tt-alc-retail.pri-org       + v-retail-pri-org
      buf_tt-alc-retail.pri-tot       = buf_tt-alc-retail.pri-tot       + v-retail-pri-tot
      buf_tt-alc-retail.sale-loc-prod = buf_tt-alc-retail.sale-loc-prod + v-retail-sale-loc-prod
      buf_tt-alc-retail.sale-tot      = buf_tt-alc-retail.sale-tot      + v-retail-sale-tot
      buf_tt-alc-retail.ost-end       = buf_tt-alc-retail.ost-end       + v-retail-ost-end
    .
  end. /* for each buf_alc-type no-lock */
  run prg-bar_delete in this-procedure .
end.

end procedure. /* fill-tt-alc-retail */

/* ===================================================================================================== */
procedure print-alc-pri :
  define buffer buf_tt-alc-pri for tt-alc-pri.

  define variable v-npp         as integer   no-undo .
  define variable v-subtot-qnty as decimal   no-undo .
  define variable v-tot-qnty    as decimal   no-undo .

do
on error undo, return error return-value
:
  run print-alc-pri-header in this-procedure .

  for each buf_tt-alc-pri
    break by buf_tt-alc-pri.cli-type
          by buf_tt-alc-pri.cli-code
          by buf_tt-alc-pri.alc-type-code
  :
    if   first-of(buf_tt-alc-pri.cli-type)
      or first-of(buf_tt-alc-pri.cli-code)
    then do:
      assign
        v-npp         = 0
        v-subtot-qnty = 0
      .
      run alc06xl-sheet1-write-line-data in this-procedure ( input "":U
                                                           , input "":U
                                                           , input "":U
                                                           , input buf_tt-alc-pri.cli-name
                                                           , input buf_tt-alc-pri.cli-inn
                                                           , input buf_tt-alc-pri.cli-address
                                                           , input buf_tt-alc-pri.lic-num
                                                           , input buf_tt-alc-pri.lic-give
                                                           , input "":U
                                                           ) .
    end.
    assign
      v-npp         = v-npp + 1
      v-subtot-qnty = v-subtot-qnty + buf_tt-alc-pri.quantity
      v-tot-qnty    = v-tot-qnty + buf_tt-alc-pri.quantity
    .
    run alc06xl-sheet1-write-line-data in this-procedure ( input string(v-npp)
                                                         , input buf_tt-alc-pri.alc-type-name
                                                         , input string(buf_tt-alc-pri.alc-type-code)
                                                         , input "":U
                                                         , input "":U
                                                         , input "":U
                                                         , input "":U
                                                         , input "":U
                                                         , input string(buf_tt-alc-pri.quantity)
                                                         ) .
    if   last-of(buf_tt-alc-pri.cli-type)
      or last-of(buf_tt-alc-pri.cli-code)
    then do:
      run alc06xl-sheet1-write-line-data in this-procedure ( input "":U
                                                           , input "Итого":U
                                                           , input "":U
                                                           , input "":U
                                                           , input "":U
                                                           , input "":U
                                                           , input "":U
                                                           , input "":U
                                                           , input string(v-subtot-qnty)
                                                           ) .
    end.
  end.
  run alc06xl-sheet1-write-line-data in this-procedure ( input "":U
                                                       , input "Всего":U
                                                       , input "":U
                                                       , input "":U
                                                       , input "":U
                                                       , input "":U
                                                       , input "":U
                                                       , input "":U
                                                       , input string(v-tot-qnty)
                                                       ) .

  run print-alc-pri-footer in this-procedure .
end.

end procedure. /* print-alc-pri */

/* ===================================================================================================== */
procedure print-alc-pri-header :

do
on error undo, return error return-value
:

  run alc06xl-write-cell-data in this-procedure ( input {&alc06xl-h_firmname}
                                                , input v-firm-name
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input {&alc06xl-h_firminn}
                                                , input v-firm-inn
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input {&alc06xl-h_firmaddress}
                                                , input v-firm-address
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input {&alc06xl-h_objcount}
                                                , input v-obj-count
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input {&alc06xl-h_licinfo}
                                                , input v-lic-info
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input {&alc06xl-h_activity}
                                                , input v-activity
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input {&alc06xl-h_daterange}
                                                , input v-date-range
                                                ).
end.

end procedure. /* print-alc-pri-header */

/* ===================================================================================================== */
procedure print-alc-pri-footer :

do
on error undo, return error return-value
:

end.


end procedure. /* print-alc-pri-footer */

/* ===================================================================================================== */
procedure print-alc-retail :
  define buffer buf_tt-alc-retail for tt-alc-retail.

  define variable v-npp               as integer   no-undo .
  define variable v-tot-ost-beg       as decimal   no-undo .
  define variable v-tot-pri-prod      as decimal   no-undo .
  define variable v-tot-pri-org       as decimal   no-undo .
  define variable v-tot-pri-tot       as decimal   no-undo .
  define variable v-tot-sale-loc-prod as decimal   no-undo .
  define variable v-tot-sale-tot      as decimal   no-undo .
  define variable v-tot-ost-end       as decimal   no-undo .

do
on error undo, return error return-value
:
  run print-alc-retail-header in this-procedure .

  for each buf_tt-alc-retail
  :
    assign
      v-npp               = v-npp + 1
      v-tot-ost-beg       = v-tot-ost-beg       + buf_tt-alc-retail.ost-beg
      v-tot-pri-prod      = v-tot-pri-prod      + buf_tt-alc-retail.pri-prod
      v-tot-pri-org       = v-tot-pri-org       + buf_tt-alc-retail.pri-org
      v-tot-pri-tot       = v-tot-pri-tot       + buf_tt-alc-retail.pri-tot
      v-tot-sale-loc-prod = v-tot-sale-loc-prod + buf_tt-alc-retail.sale-loc-prod
      v-tot-sale-tot      = v-tot-sale-tot      + buf_tt-alc-retail.sale-tot
      v-tot-ost-end       = v-tot-ost-end       + buf_tt-alc-retail.ost-end
    .
    run alc06xl-sheet2-write-line-data in this-procedure ( input string(v-npp)
                                                         , input buf_tt-alc-retail.alc-type-name
                                                         , input string(buf_tt-alc-retail.alc-type-code)
                                                         , input string(buf_tt-alc-retail.ost-beg)
                                                         , input string(buf_tt-alc-retail.pri-tot)
                                                         , input string(buf_tt-alc-retail.pri-prod)
                                                         , input string(buf_tt-alc-retail.pri-org)
                                                         , input string(buf_tt-alc-retail.sale-tot)
                                                         , input string(buf_tt-alc-retail.sale-loc-prod)
                                                         , input string(buf_tt-alc-retail.ost-end)
                                                         ) .

  end.

  run alc06xl-sheet2-write-line-data in this-procedure ( input "":u
                                                       , input "Всего":U
                                                       , input ""
                                                       , input string(v-tot-ost-beg)
                                                       , input string(v-tot-pri-tot)
                                                       , input string(v-tot-pri-prod)
                                                       , input string(v-tot-pri-org)
                                                       , input string(v-tot-sale-tot)
                                                       , input string(v-tot-sale-loc-prod)
                                                       , input string(v-tot-ost-end)
                                                       ) .

  run print-alc-retail-footer in this-procedure .
end.

end procedure. /* print-alc-retail */

/* ===================================================================================================== */
procedure print-alc-retail-header :

do
on error undo, return error return-value
:
  run alc06xl-write-cell-data in this-procedure ( input {&alc06xl-h_firmname2}
                                                , input v-firm-name
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input {&alc06xl-h_firminn2}
                                                , input v-firm-inn
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input {&alc06xl-h_firmaddress2}
                                                , input v-firm-address
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input {&alc06xl-h_objcount2}
                                                , input v-obj-count
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input {&alc06xl-h_licinfo2}
                                                , input v-lic-info
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input {&alc06xl-h_activity2}
                                                , input v-activity
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input {&alc06xl-h_daterange2}
                                                , input v-date-range
                                                ).
end.

end procedure. /* print-alc-pri-header */

/* ===================================================================================================== */
procedure print-alc-retail-footer :

do
on error undo, return error return-value
:

end.


end procedure. /* print-alc-pri-footer */

/* ===================================================================================================== */
procedure load-head-info :

define buffer buf_alc-sale-lic  for ub.alc-sale-lic.

define buffer buf_obj-list      for obj-list.

&scop date-fmt "99.99.99":U

do for
buf_obj-list,
buf_alc-sale-lic
on error undo, return error return-value
:
  define variable v-i as integer   no-undo .

  find first buf_alc-sale-lic no-lock
    where buf_alc-sale-lic.cli-type   = {&cmp}
      and buf_alc-sale-lic.cli-code   = v-host-code
      and buf_alc-sale-lic.date-from  < v-begin-date
      and buf_alc-sale-lic.date-to    > v-end-date
  no-error .
  if not available buf_alc-sale-lic
  then do:
    find first buf_alc-sale-lic no-lock
      where buf_alc-sale-lic.cli-type = {&cmp}
        and buf_alc-sale-lic.cli-code = v-host-code
        and buf_alc-sale-lic.date-to  > v-end-date
    no-error .
  end.

  if available buf_alc-sale-lic
  then do:
    assign
      v-lic-info = substitute( "&1 рег. №&2 от &3 г."
                             , buf_alc-sale-lic.seria
                             , buf_alc-sale-lic.number
                             , string(buf_alc-sale-lic.date-get, {&date-fmt})
                             )
    .
  end.
  else do:
    assign
      v-lic-info = '?':U
    .
  end.

  for each buf_obj-list :
    assign
      v-i = v-i + 1
    .
  end.

  run fmtcli-get-client in this-procedure ( input {&cmp} , v-host-code ) .

  assign
    v-firm-name     = v-fmtcli-name
    v-firm-inn      = v-fmtcli-inn
    v-firm-address  = v-fmtcli-addres
    v-obj-count     = string(v-i)
    v-activity      = "Розничная продажа алкогольной продукции":U
    v-date-range    = substitute( " с &1 по &2"
                                , string( v-begin-date, {&date-fmt})
                                , string( v-end-date  , {&date-fmt})
                                )
  .
end.

end procedure. /* load-head-info */