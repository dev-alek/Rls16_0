block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-np34.p $
$Archive: rep/r-np34.p $

Форма НП-34

Автор: Уханов Дмитрий Юрьевич
Дата создания: 02/08/10
Author: Dmitry Ukhanov
Creation date: 02/08/10

Автор1: Белоусов Илья Александрович
Дата создания1: 02/14/08

Input:

Output:

*/
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-rec-id      as recid. /* recid(trn-doc) */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-np34.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-np34.p $":U .
define variable vss-description as character no-undo init "Форма НП-34".

&global-define frame-width  196

define variable g#report-num  as integer      no-undo .
define variable g#quest-print as logical no-undo .
define variable g#log         as logical no-undo .

{ cmp/vssrevis.i   }
{ cmp/str-glbl.i   }
{ gbl/cur-time.i   }
{ cmp/library.i    }
{ gbl/waitfram.i   }
{ cmp/r-pril.i     }
{ gbl/paramls.i    }
{ rep/r-np34xl.i   }
{ trg/factord.i    }
{ str/clcprtsl.i   }
{ gbl/getcntxt.i def }
{ rep/repfrm.i   def } /* Показать окно информации о текущем процессе */
{ ref/gdsoattr.i   }

define stream out-stream.

define temp-table tt-line no-undo
/*   field order-num      as    integer */
   field gds-code       like ub.goods.gds-code
   field pl-code        like ub.place.pl-code
   field gds-name       like ub.goods.gds-name
   field artic          like ub.goods.artic
   field prod-type      like ub.goods.prod-type
   field prod-code      like ub.goods.prod-code
   field fact-order     like ub.doc-line.fact-order
   field line-date      as date  INIT ?
   field parts-summ-kg  as decimal
   field parts-qnty     as decimal
   field density        as decimal
   field line-number    as integer

   field income-qnty    like ub.doc-line.fact-qnty
   field normal-wastage as decimal
   field wastage-qnty   as decimal
   field income-qnty-t  as decimal
   field price          as decimal
   field summ           as decimal

   index pi is primary unique
         gds-code
         pl-code
.

define temp-table tt-body no-undo
   field gds-code       like ub.goods.gds-code
   field gds-name       like ub.goods.gds-name
   field line-number    as integer
   field normal-wastage as decimal

   field wastage-qnty   as decimal
   field income-qnty-t  as decimal
   field price          as decimal
   field summ           as decimal

   index pi is primary unique
         gds-code
.


define buffer buf_trn-doc     for ub.trn-doc .
define buffer buf_goods       for ub.goods .
define buffer buf_doc-line    for ub.doc-line .
define buffer buf_clients     for ub.clients .
define buffer buf_firm        for ub.clients .
define buffer buf_doc-pl      for ub.doc-pl .
define buffer buf_rvs-doc     for ub.rvs-doc .
define buffer buf_rvs-line    for ub.rvs-line .
define buffer buf_parts       for ub.parts .
define buffer buf_firm_firm   for ub.firm .
define buffer buf_sysconf     for ub.sysconf .
define buffer buf_sale-doc    for ub.sale-doc .

define buffer buf_tt-body     for tt-body .
define buffer buf_tt-line     for tt-line .

define variable v-obj-name          as character    no-undo .
define variable v-firm-name         as character    no-undo .

define variable v-date-begin        as date      INIT ?   no-undo .
define variable v-date-end          as date         no-undo .
define variable v-fact-order-end    as decimal      no-undo .

define shared variable CostPrice    as logical                          no-undo.

define variable sym1  as character no-undo format "x(1)":u initial "|":u .
define variable sym2  as character no-undo format "x(1)":u initial "|":u .
define variable sym3  as character no-undo format "x(1)":u initial "|":u .
define variable sym4  as character no-undo format "x(1)":u initial "|":u .
define variable sym5  as character no-undo format "x(1)":u initial "|":u .
define variable sym6  as character no-undo format "x(1)":u initial "|":u .
define variable sym7  as character no-undo format "x(1)":u initial "|":u .
define variable sym8  as character no-undo format "x(1)":u initial "|":u .
define variable sym9  as character no-undo format "x(1)":u initial "|":u .
define variable sym10 as character no-undo format "x(1)":u initial "|":u .
define variable sym11 as character no-undo format "x(1)":u initial "|":u .
define variable sym12 as character no-undo format "x(1)":u initial "|":u .
define variable sym13 as character no-undo format "x(1)":u initial "|":u .
define variable sym14 as character no-undo format "x(1)":u initial "|":u .
define variable sym15 as character no-undo format "x(1)":u initial "|":u .
define variable sym16 as character no-undo format "x(1)":u initial "|":u .
define variable sym17 as character no-undo format "x(1)":u initial "|":u .

define variable v-count       as integer    no-undo.
define variable v-dens        as decimal      no-undo.
define variable v-doc-num     like ub.price-list.doc-num    no-undo .
define variable v-road-tax    like ub.price-list.road-tax   no-undo .
define variable v-excise      like ub.price-list.excise     no-undo .
define variable v-price       as decimal      no-undo.
define variable v-gen-acct    as character    no-undo.
define variable v-director    as character    no-undo.
define variable v-sign        as decimal      no-undo .
define variable v-type        as character    no-undo .
define variable v-normal-wastage as decimal   no-undo .

_main-block:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  { gbl/getcntxt.i get }
  { rep/repfrm.i on 10 } /* Показать окно информации о текущем процессе */
  run get-report-num  in parparentproc   ( output g#report-num
                                        ) .
  run get-quest-print in parparentproc   ( output g#quest-print
                                        ) .

  find first buf_trn-doc no-lock
    where recid( buf_trn-doc ) = p-rec-id
    no-error .

  if not available buf_trn-doc then do:
    message
      "Неправильно выбран документ." skip
      view-as alert-box error.
    return.
  end.

  if buf_trn-doc.status_ = {&fact} then do:
    assign
      v-date-end        = buf_trn-doc.fact-date
      v-fact-order-end  = buf_trn-doc.fact-order
    .
  end.
  else do:
    assign
      v-date-end        = buf_trn-doc.doc-date
    .
    run factord-end-day in this-procedure
      ( input v-date-end
      , output v-fact-order-end
      ) .
  end.

  { gbl/working.i }

  /* название объекта */
  find first buf_clients no-lock
    where buf_clients.obj-type = buf_trn-doc.obj-type
      and buf_clients.obj-code = buf_trn-doc.obj-code
    no-error .
  if not available buf_clients then do:
    return error substitute( "Не найден объект &1 &2", buf_trn-doc.obj-code, buf_trn-doc.obj-type).
  end.
  assign
    v-obj-name = /*SUBSTITUTE("&1 &2"
                            , buf_clients.obj-code
                            , buf_clients.obj-name
                            ) */ buf_clients.obj-name
  .
  /* находим фирму по объекту */
  find first buf_firm no-lock
    where buf_firm.obj-type = {&cmp}
      and buf_firm.obj-code = buf_clients.host-code
    no-error .
  if not available buf_firm then do:
    return error substitute( "Форма НП-34. Не найдена фирма для объекта &1 &2"
                            , buf_firm.obj-code
                            , buf_firm.obj-type).
  end.
  assign
    v-firm-name = /*SUBSTITUTE("&1 &2"
                            , buf_firm.obj-code
                            , buf_firm.obj-name
                            ) */ buf_firm.obj-name
  .
  find first buf_firm_firm no-lock
    where buf_firm_firm.firm-code = buf_clients.host-code
    no-error .
  if available buf_firm_firm then do:
    assign
      v-director = substitute("/ &1 /", buf_firm_firm.director)
    .
  end.
  find first buf_sysconf no-lock
    where buf_sysconf.host-code = buf_clients.host-code
    no-error .
  if available buf_sysconf then do:
    assign
      v-gen-acct = substitute("/ &1 /", buf_sysconf.snr-accnt)
    .
  end.

  find first buf_rvs-doc no-lock
    where buf_rvs-doc.rvs-code = buf_trn-doc.out-code
    no-error .
  if not available buf_rvs-doc then do:
    {&SetCursorNo}
    run waitfram-hide in this-procedure .
    message
      substitute( 'Форма НП-34. Не найдена сверка к документу "&1".', buf_trn-doc.doc-code )
      view-as alert-box error .
    undo, return error .
  end.
  if buf_rvs-doc.rvs-type <> {&rvs-control} then do:
    {&SetCursorNo}
    run waitfram-hide in this-procedure .
    message
      substitute( 'Форма НП-34. Сверка имеет тип "&1", а должен быть "&2".', buf_rvs-doc.rvs-type, {&rvs-control} ) skip
      view-as alert-box error .
    undo, return error.
  end.

  /* собираем топливо-резервуар */
  for each  buf_rvs-line no-lock
    where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
      and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
      and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
    ,first buf_goods no-lock
    where buf_goods.gds-code    = buf_rvs-line.gds-code
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :

    run gdsoattr-value in this-procedure
                      ( input  {&attr-normal-wastage-o}
                       ,input  buf_goods.gds-code
                       ,input  buf_rvs-doc.obj-type
                       ,input  buf_rvs-doc.obj-code
                       ,output v-normal-wastage
                       ,output v-type
                       ) no-error .

    find first buf_tt-line no-lock
      where buf_tt-line.gds-code = buf_goods.gds-code
        and buf_tt-line.pl-code  = buf_rvs-line.pl-code
      no-error .
    if not available buf_tt-line then do:
      create buf_tt-line.
      assign
        buf_tt-line.gds-code       = buf_goods.gds-code
        buf_tt-line.pl-code        = buf_rvs-line.pl-code
        buf_tt-line.gds-name       = buf_goods.gds-name
        buf_tt-line.normal-wastage = v-normal-wastage
        buf_tt-line.artic          = buf_goods.artic
        buf_tt-line.prod-type      = buf_goods.prod-type
        buf_tt-line.prod-code      = buf_goods.prod-code
        buf_tt-line.density        = buf_rvs-line.state-density
      .
    end.
  end.

  /* номер строки в документе инвентаризации*/
  for each buf_tt-line
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = buf_trn-doc.doc-code
        and buf_doc-line.artic     = buf_tt-line.artic
        and buf_doc-line.prod-type = buf_tt-line.prod-type
        and buf_doc-line.prod-code = buf_tt-line.prod-code
      no-error .
    if available buf_doc-line then do:
      assign
        buf_tt-line.line-number = buf_doc-line.line-num
      .
    end.

    /* Находим предпоследнюю инвентаризацию (стартовую точку) по каждому товару */
    find last buf_doc-line no-lock
      where buf_doc-line.obj-type     = buf_trn-doc.obj-type
        and buf_doc-line.obj-code     = buf_trn-doc.obj-code
        and buf_doc-line.prod-type    = buf_tt-line.prod-type
        and buf_doc-line.prod-code    = buf_tt-line.prod-code
        and buf_doc-line.artic        = buf_tt-line.artic
        and buf_doc-line.ext-doc-type = {&TDEDT_Inv}
        and buf_doc-line.status_      = {&fact}
        and buf_doc-line.fact-order   < v-fact-order-end
      use-index dt-fo
      no-error .
    if available buf_doc-line then do:
      run factord-to-date in this-procedure
        ( input  buf_doc-line.fact-order
        , output v-date-begin
                            ) .
      assign
        buf_tt-line.fact-order = buf_doc-line.fact-order
        buf_tt-line.line-date  = v-date-begin
      .
    end.
  end.

  _date-begin:
  for each buf_tt-line
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    if buf_tt-line.line-date = ?
      or buf_tt-line.line-date <> v-date-begin
    then do:
      assign
        v-date-begin = ?
      .
      leave _date-begin.
    end.
  end.

  for each buf_tt-line
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    /* Собираем приходы после инвентаризации */
    for each buf_doc-line no-lock
        where  ( buf_doc-line.obj-type         = buf_trn-doc.obj-type
                and buf_doc-line.obj-code     = buf_trn-doc.obj-code
                and buf_doc-line.prod-type    = buf_tt-line.prod-type
                and buf_doc-line.prod-code    = buf_tt-line.prod-code
                and buf_doc-line.artic        = buf_tt-line.artic
                and buf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh}
                and buf_doc-line.status_      = {&fact}
                and buf_doc-line.fact-order   > buf_tt-line.fact-order
                and buf_doc-line.fact-order   < v-fact-order-end
                and (not can-find (first buf_sale-doc
                                   where buf_sale-doc.doc-code = buf_doc-line.doc-code
                                     and buf_sale-doc.doc-kind = {&sale-add2-in-tech-refuell}))
              )
              or
              ( buf_doc-line.obj-type         = buf_trn-doc.obj-type
                and buf_doc-line.obj-code     = buf_trn-doc.obj-code
                and buf_doc-line.prod-type    = buf_tt-line.prod-type
                and buf_doc-line.prod-code    = buf_tt-line.prod-code
                and buf_doc-line.artic        = buf_tt-line.artic
                and buf_doc-line.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
                and buf_doc-line.status_      = {&fact}
                and buf_doc-line.fact-order   > buf_tt-line.fact-order
                and buf_doc-line.fact-order   < v-fact-order-end
              )
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      if buf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh} then do:
        assign
          v-sign = 1
        .
      end.
      else do:
        assign
          v-sign = -1
        .
      end.
      for each buf_doc-pl no-lock
        where buf_doc-pl.obj-type  = buf_doc-line.obj-type
          and buf_doc-pl.obj-code  = buf_doc-line.obj-code
          and buf_doc-pl.out-code  = buf_doc-line.doc-code
          and buf_doc-pl.gds-code  = buf_tt-line.gds-code
          and buf_doc-pl.pl-code   = buf_tt-line.pl-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
      :
        assign
          buf_tt-line.wastage-qnty   = buf_tt-line.wastage-qnty   + v-sign * buf_doc-pl.cli-fact-qnty * buf_tt-line.normal-wastage * 0.001
          buf_tt-line.income-qnty-t  = buf_tt-line.income-qnty-t  + v-sign * buf_doc-pl.cli-fact-qnty * 0.001
        .
      end.

      if costprice = true then do:
        for each buf_parts no-lock
          where buf_parts.obj-type    = buf_doc-line.obj-type
            and buf_parts.obj-code    = buf_doc-line.obj-code
            and buf_parts.artic       = buf_doc-line.artic
            and buf_parts.prod-type   = buf_doc-line.prod-type
            and buf_parts.prod-code   = buf_doc-line.prod-code
            and buf_parts.out-code    = buf_doc-line.doc-code
            and buf_parts.pl-code     = buf_tt-line.pl-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
        :
          if printrubl then do:
            assign
              buf_tt-line.parts-summ-kg  = buf_tt-line.parts-summ-kg   + buf_parts.fact-qnty * buf_parts.cli-base-rate * price-rubl
              buf_tt-line.parts-qnty     = buf_tt-line.parts-qnty   + buf_parts.fact-qnty
            .
          end.
          else do:
            assign
              buf_tt-line.parts-summ-kg  = buf_tt-line.parts-summ-kg   + buf_parts.fact-qnty * buf_parts.cli-base-rate * price-base
              buf_tt-line.parts-qnty     = buf_tt-line.parts-qnty   + buf_parts.fact-qnty
            .
          end.
        end.
      end. /* costprice */
    end.
  end. /*   each buf_tt-line */

  /* считаем суммы */
  for each buf_tt-line
      break by buf_tt-line.gds-code
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    /* цена одна на товар */
    if first-of( buf_tt-line.gds-code ) then do:
      /* цены */
      if costprice = true then do: /* учетные */
        assign
          v-price = buf_tt-line.parts-summ-kg / buf_tt-line.parts-qnty
        .
      end.
      else do: /* продажные */
        assign
          v-doc-num   = "":U
          v-price     = 0
          v-road-tax  = 0
          v-excise    = 0
        .
        { gbl/bcodeprc.i
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          buf_tt-line.gds-code
          0
          buf_trn-doc.fact-order
          v-doc-num
          v-price
          v-road-tax
          v-excise
          no-error
        }
      end.

      create buf_tt-body.
      assign
        buf_tt-body.gds-code       = buf_tt-line.gds-code
        buf_tt-body.gds-name       = buf_tt-line.gds-name
        buf_tt-body.line-number    = buf_tt-line.line-number
        buf_tt-body.normal-wastage = buf_tt-line.normal-wastage
      .
    end. /* first-of */

    assign
      buf_tt-body.wastage-qnty   = buf_tt-body.wastage-qnty  + buf_tt-line.wastage-qnty
      buf_tt-body.income-qnty-t  = buf_tt-body.income-qnty-t + buf_tt-line.income-qnty-t
      buf_tt-body.summ           = buf_tt-body.summ          + buf_tt-line.wastage-qnty * (if v-price = ? then 0 else v-price) / (if costprice THEN 1 ELSE buf_tt-line.density)
    .
    if last-of( buf_tt-line.gds-code ) then do:
      if costprice = true then do:
        assign
          buf_tt-body.price = if v-price = ? then 0 else v-price
        .
      end.
      else do:
        assign
          buf_tt-body.price = ( if (buf_tt-body.wastage-qnty = 0 or buf_tt-body.wastage-qnty = ?) then 0
          else buf_tt-body.summ / buf_tt-body.wastage-qnty )
        .
      end.
    end. /* last-of */
  end. /* each buf_tt-line */

  /* открываем поток текстового вывода */
  run np34-xl-init in this-procedure .
  { cmp/open-out.i stream out-stream " " {&LS_PS_A4} }
  run np34-xl-init in this-procedure.

  /* печать заголовка */
  run print-titul in this-procedure .

  /* печать тела */
  run print-body in this-procedure .

  /* подвал */
  run print-bottom in this-procedure .

  /* закрываем потоки */
  output stream out-stream close.
  run np34-xl-close in this-procedure .
  { rep/repfrm.i off }

  /* передаем управление пользователю */
  { rep/q-print.i 8 }

  empty temp-table buf_tt-body.
  { gbl/stopwork.i }

end. /* _main-block */



/*==========================================================================*/
procedure print-titul :

  do
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    define variable v-pp    as character    no-undo.
    if CostPrice then do:
      assign
        v-pp =  "Учетные цены "
      .
    end.
    else do:
      assign
        v-pp =  "Продажные цены"
      .
    end.

    put stream out-stream
      "Госкомнефтепродукт ________________ "                   "Форма No. 34-НП" AT 150 skip
      "________________________ управление" skip
                                "Утверждена" AT 150  skip
      v-firm-name "нефтебаза (комбинат)"                      "Госкомнефтепродуктом СССР" AT 150 skip
      "15 августа 1985 г. No. 06/21-8-446" AT 150 skip
      "АЗС No." v-obj-name    FORMAT "x(50)"  "РАСЧЕТ" AT 90 skip
      "ЕСТЕСТВЕННОЙ УБЫЛИ НЕФТЕПРОДУКТОВ, НАХОДЯЩИХСЯ" AT 70 skip(1)
      "НА ОТВЕТСТВЕННОМ ХРАНЕНИИ У ________________________________________" AT 60 skip
      "(должность, Ф.И.О.)" AT 100 skip(1)
      STRING("ЗА ПЕРИОД С " + (IF v-date-begin <> ? THEN STRING(v-date-begin, "99/99/9999") ELSE "__________") + " Г. ПО " + STRING(v-date-end, "99/99/9999") + " Г.") FORMAT("x(85)") AT 65  v-pp FORMAT "x(20)" at 150 skip

    .
    run np34-xl-write-cell-data in this-procedure ( input {&np34-xl-h_firm},           input v-firm-name ).
    run np34-xl-write-cell-data in this-procedure ( input {&np34-xl-h_obj},            input v-obj-name ).
    run np34-xl-write-cell-data in this-procedure ( input {&np34-xl-h_date_begin},       input SUBSTITUTE( "За период с &2 по &1"
                                                                                                      , STRING(v-date-end, "99/99/9999")
                                                                                                      , IF v-date-begin = ? THEN "":U ELSE STRING(v-date-begin, "99/99/9999")
                                                                                                      ) ).

    /*
    run np34-xl-write-cell-data in this-procedure ( input {&np34-xl-h_date_begin},     input (IF v-date-begin = ? THEN "":U ELSE STRING(v-date-begin, "99/99/9999")) ).
    */
    run np34-xl-write-cell-data in this-procedure ( input {&np34-xl-h_type},           input v-pp ).
    run np34-xl-write-cell-data in this-procedure ( input {&np34-xl-h_director},       input v-director ).
    run np34-xl-write-cell-data in this-procedure ( input {&np34-xl-h_gen_acct},       input v-gen-acct ).

  end. /* do on error */
  return .

end procedure. /* print-titul */

/*==========================================================================*/
procedure print-body :
  define buffer buf_tt-body     for tt-body .

  define variable v-line       as character    no-undo.
  define variable v-auto    as character  initial "автотранспорт"  no-undo.
  define variable v-empty-1    as decimal      no-undo.
  define variable v-empty-2    as decimal      no-undo.
  define variable v-empty-3    as decimal      no-undo.
  define variable v-empty-4    as decimal      no-undo.
  define variable v-empty-5    as decimal      no-undo.
  define variable v-empty-6    as decimal      no-undo.
  define variable v-empty-7    as decimal      no-undo.

  define frame f-first
    sym1                         no-label format "X(1)"        space(0)
    buf_tt-body.line-number      no-label format "999"         space(0)
    sym2                         no-label format "X(1)"        space(0)
    buf_tt-body.gds-name         no-label format "X(30)"       space(0)
    sym3                         no-label format "X(1)"        space(0)
    buf_tt-body.gds-code         no-label format "999999999"   space(0)
    sym4                         no-label format "X(1)"        space(0)
    v-auto                       no-label format "x(13)"       space(0)
    sym5                         no-label format "X(1)"        space(0)
    buf_tt-body.income-qnty-t    no-label format "->>,>>9.999" space(0)
    sym6                         no-label format "X(1)"        space(0)
    buf_tt-body.normal-wastage   no-label format "->>,>>9.999" space(0)
    sym7                         no-label format "X(1)"        space(0)
    buf_tt-body.wastage-qnty     no-label format "->>,>>9.999" space(0)
    sym8                         no-label format "X(1)"        space(0)
    v-empty-1                    no-label format "->>,>>9.99"  space(0)
    sym9                         no-label format "X(1)"        space(0)
    v-empty-2                    no-label format "->>,>>9.99"  space(0)
    sym10                        no-label format "X(1)"        space(0)
    v-empty-3                    no-label format "->>,>>9.99"  space(0)
    sym11                        no-label format "X(1)"        space(0)
    v-empty-4                    no-label format "->>,>>9.99"  space(0)
    sym12                        no-label format "X(1)"        space(0)
    v-empty-5                    no-label format "->>,>>9.99"  space(0)
    sym13                        no-label format "X(1)"        space(0)
    v-empty-6                    no-label format "->>,>>9.99"  space(0)
    sym14                        no-label format "X(1)"        space(0)
    v-empty-7                    no-label format "->>,>>9.999" space(0)
    sym15                        no-label format "X(1)"        space(0)
    buf_tt-body.price            no-label format "->>,>>9.99"  space(0)
    sym16                        no-label format "X(1)"        space(0)
    buf_tt-body.summ             no-label format "->>,>>9.99"  space(0)
    sym17                        no-label format "X(1)"        space(0)
    skip
  header
    "+---+------------------------------+---------+-------------+-----------+-----------+-----------+----------+----------+----------+----------+----------+----------+-----------+----------+----------+" skip
    "|   |                              |         |             |    Приемка,  отпуск и хранение    |     Хранение свыше месяца      |  Приемка, отпуск и хранение в  |     Всего начислено по нормам   |" skip
    "|   |                              |         |             |        до  одного месяца          |                                |   открытых земляных амбарах    |                                 |" skip
    "|   |                              |         |             +-----------+-----------+-----------+----------+----------+----------+----------+----------+----------+-----------+----------+----------+" skip
    "| № |  Наименование нефтепродукта  |   Код   |   Способ    | Кол-во по-|   Норма   |Начисленно |Масса хра-|  Норма   |Начисленно| Площадь  |  Норма   |Начисленно|   Масса,  |   Цена   |  Сумма   |" skip
    "|   |                              |         |  доставки   | ступивших |   естест- |           |нимого    |естествен-|          |испарения,| естествен|          |           |          |          |" skip
    "|   |                              |         |             | нефтепро- |   венной  |   кг      |нефтепро- | ной      |   кг     |  кв. м   | ной убыли|   кг     |    кг     |          |          |" skip
    "|   |                              |         |             | дуктов, т | убыли,кг/т|           |дукта, т  | убыли    |          |          | кг/кв.м  |          |           |          |          |" skip
    "+---+------------------------------+---------+-------------+-----------+-----------+-----------+----------+----------+----------+----------+----------+----------+-----------+----------+----------+" skip
    "| 1 |              2               |    3    |      4      |     5     |      6    |     7     |     8    |     9    |    10    |    11    |    12    |    13    |     14    |    15    |    16    |" skip
    /*
    "+---+------------------------------+---------+-------------+----------+----------+----------+----------+----------+----------+----------+----------+----------+----------+----------+----------+" skip
    */
  with width {&frame-width} down stream-io no-labels no-box.

  do
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    for each buf_tt-body
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      display stream out-stream
        buf_tt-body.line-number
        buf_tt-body.gds-name
        buf_tt-body.gds-code
        v-auto
        buf_tt-body.income-qnty-t
        buf_tt-body.normal-wastage
        buf_tt-body.wastage-qnty
        v-empty-1
        v-empty-2
        v-empty-3
        v-empty-4
        v-empty-5
        v-empty-6
        buf_tt-body.wastage-qnty @ v-empty-7
        buf_tt-body.price
        buf_tt-body.summ
        sym1
        sym2
        sym3
        sym4
        sym5
        sym6
        sym7
        sym8
        sym9
        sym10
        sym11
        sym12
        sym13
        sym14
        sym15
        sym16
        sym17
        with frame f-first.

      run np34-xl-write-line-data IN THIS-PROCEDURE
        ( input buf_tt-body.line-number
        , input buf_tt-body.gds-name
        , input buf_tt-body.gds-code
        , input v-auto

        , input string(buf_tt-body.income-qnty-t, "->>,>>9.999")
        , input string(buf_tt-body.normal-wastage, "->>,>>9.999")
        , input string(buf_tt-body.wastage-qnty, "->>,>>9.999")

        , input string(buf_tt-body.wastage-qnty, "->>,>>9.999")
        , input buf_tt-body.price
        , input buf_tt-body.summ
        ) .
    end.
    assign
      v-line = fill( "-" , {&frame-width} )
    .
    put stream out-stream
      v-line  format "x({&frame-width})"
    .
  end. /* do on error */
  return .
end procedure. /* print-titul */

/*==========================================================================*/
procedure print-bottom :
  do
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    put stream out-stream
      skip(1)
      "Руководитель _____________________" at 5 skip
      "(подпись)" at 25 skip(1)
      "Главный бухгалтер ________________" at 5 skip
      "(подпись)" at 25 skip(1)
      "С расчетом ознакомлен ___________________________________________" at 5 skip
      "(подпись материально-ответственного лица)" at 28 skip(1)
      "_______________ 20__ г." at 5 skip
    .

  end. /* do on error */
end procedure. /* print-bottom */