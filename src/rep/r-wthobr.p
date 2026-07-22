block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-wthobr.p $
$Archive: rep/r-wthobr.p $

Отчет оборотная ведомость серийных МЦ по контрагентам

Автор: Хныкин Павел Андреевич
Дата создания: 12/25/07
Author: Pavel Khnykin
Creation date: 12/25/07

*/

define input  parameter parparentproc         as handle    no-undo .
define input  parameter p-rs-supp             as integer   no-undo .
define input  parameter p-rs-wth-type         as integer   no-undo .
define input  parameter p-rs-wth              as integer   no-undo .
define input  parameter p-cb-wth-detail       as integer   no-undo .
define input  parameter p-clients-recid-list  as character no-undo .
define input  parameter p-wth-recid-list      as character no-undo .
define input  parameter p-dt-calc             as integer   no-undo .
define input  parameter p-dtFrom              as date      no-undo .
define input  parameter p-dtTo                as date      no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-wthobr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-wthobr.p $":U .
define variable vss-description as character no-undo init "Отчет оборотная ведомость серийных МЦ по контрагентам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get " " my-handle }
{ gbl/waitfram.i }
{ trg/factord.i  }
{ rep/lkp-font.i }
{ rep/wthobr.i   }
{ rep/repfrm.i def }
define variable g#report-num  as integer no-undo .
{ gbl/paramls.i    }
{ rep/wthobrxl.i   }



define temp-table tt-clients  no-undo like ub.clients.
define temp-table tt-wealth   no-undo like ub.wealth.
define temp-table tt-wth-par  no-undo like ub.wth-par.
define temp-table tt-wth-ser  no-undo like ub.wth-ser.
define temp-table tt-wth-parts  no-undo like ub.wth-parts
index idx-cli-dt cli-type
              cli-code
              beg-dt
              ext-doc-type
              out-code
index idx-cli-fact cli-type
                   cli-code
                   fact-date
                   ext-doc-type
                   out-code
.
define temp-table tt-rest  no-undo like ub.wth-parts
index idx-cli-fact cli-type
                   cli-code
                   fact-date
                   ext-doc-type
                   out-code
.

define temp-table tt-report no-undo
  field cli-type            like ub.clients.obj-type
  field cli-code            like ub.clients.obj-code
  field wth-code            like ub.wealth.wth-code
  field par-code            like ub.wth-par.par-code
  field par-val             like ub.wth-par.par-val
  field ser-code            like ub.wth-ser.ser-code
  field db-num              like ub.wth-ser.db-num
  field cli-name            as character
  field talon-name          as character
  field talon-nominal       as character
  field talon-series        as character
  field give-sum-units      as decimal
  field give-sum-money      as decimal
  field chg-give-sum-units  as decimal
  field chg-give-sum-money  as decimal
  field sell-sum-units      as decimal
  field sell-sum-money      as decimal
  field ret-sum-units       as decimal
  field ret-sum-money       as decimal
  field chg-ret-sum-units   as decimal
  field chg-ret-sum-money   as decimal
  field spi-sum-units       as decimal
  field spi-sum-money       as decimal
  field restFrom-units      as decimal
  field restFrom-money      as decimal
  field restEnd-units      as decimal
  field restEnd-money      as decimal
index pi is primary unique
  cli-type
  cli-code
  wth-code
  par-code
  ser-code
  db-num
.

define temp-table tt-report-cli no-undo
  field cli-type            like ub.clients.obj-type
  field cli-code            like ub.clients.obj-code
  field give-sum-units      as decimal
  field give-sum-money      as decimal
  field chg-give-sum-units  as decimal
  field chg-give-sum-money  as decimal
  field sell-sum-units      as decimal
  field sell-sum-money      as decimal
  field ret-sum-units       as decimal
  field ret-sum-money       as decimal
  field chg-ret-sum-units   as decimal
  field chg-ret-sum-money   as decimal
  field spi-sum-units       as decimal
  field spi-sum-money       as decimal
  field restFrom-units      as decimal
  field restFrom-money      as decimal
  field restEnd-units       as decimal
  field restEnd-money       as decimal

index pi is primary unique
  cli-type
  cli-code
.

define stream out-stream.

define buffer buf_wealth      for ub.wealth.
define buffer buf_wth-gds     for ub.wth-gds.
define buffer buf_wth-par     for ub.wth-par.
define buffer buf_goods       for ub.goods.
define buffer buf_objects     for ub.clients.

define variable v-is-wth-restrict   as logical   no-undo .
define variable v-is-par-restrict   as logical   no-undo .
define variable v-is-ser-restrict   as logical   no-undo .
define variable v-print-rubl        as logical   no-undo .
define variable v-fact-order-start  as decimal   no-undo .
define variable v-fact-order-end    as decimal   no-undo .
define variable v-line              as character no-undo .

&glob  check_ext-type (b_wth-parts.ext-doc-type = {&WDEDT_Exp_Ext} or~
      b_wth-parts.ext-doc-type = {&WDEDT_Exch}    or~
      b_wth-parts.ext-doc-type = {&WDEDT_Put_Cli} or~
      b_wth-parts.ext-doc-type = {&WDEDT_Dst_Cli} or ~
      b_wth-parts.ext-doc-type = {&WDEDT_Put_Cash} or ~
      b_wth-parts.ext-doc-type = {&WDEDT_Put_Sale})


do on error undo, return error return-value
:
  assign
    v-line = fill( "-" , 300 )
  .

   if lookup( string(p-cb-wth-detail) , {&wth-detail-list} ) = 0
   then do:
    message
      "Неверно указан уровень детализации!"
    view-as alert-box error.
    return error .
   end. /*  */

  { gbl/working.i }


  run get-report-num in my-handle (output g#report-num).

  { cmp/open-out.i stream out-stream " " }
  run wthobrxl-init in this-procedure .

  run fill-tt in this-procedure .
  run waitfram-show in this-procedure ("Печать отчета...") .
  run print-header in this-procedure .
  run print-report in this-procedure .
  run waitfram-hide in this-procedure .

  put stream out-stream unformatted " "  skip.

  run clear-tt in this-procedure .
  run wthobrxl-close in this-procedure .
  output stream out-stream close.
  {&CloseExcel}
  { gbl/stopwork.i }
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
    value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
  .
  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  define variable v-orient-page as character no-undo .
  run How-name in this-procedure (
      input ReportPageHeight,
      input ReportPageWidth,
      output v-orient-page )
      .
  if v-orient-page = "A4-lans":U then DisabledOptions = 8 .
                                 else DisabledOptions = 0 .
  run gbl/prnfilen.w
      (input  ""
      ,input  20
      ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
      ,input  ReportFontNum
      ,output v-user-action
      ,output v-printed
      ) .
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) ) .
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" ) .

end.


procedure clear-tt :

do
on error undo, return error return-value
:

 empty temp-table tt-clients.
 empty temp-table tt-wealth .
 empty temp-table tt-wth-par.
 empty temp-table tt-wth-ser.
 empty temp-table tt-report .
 empty temp-table tt-report-cli .
 empty temp-table tt-wth-parts .

end.

end procedure. /* clear-tt */


procedure fill-tt :

do
on error undo, return error return-value
:
  define buffer buf_wealth        for ub.wealth .
  define buffer buf_wth-par       for ub.wth-par.
  define buffer buf_wth-ser       for ub.wth-ser.
  define buffer buf_clients       for ub.clients.
  /* define buffer buf_wth-parts     for ub.wth-parts. */
  define buffer buf_wth-parts     for tt-wth-parts.
  define buffer b_wth-parts       for ub.wth-parts.
  define buffer buf_tt-clients    for tt-clients.
  define buffer buf_tt-wealth     for tt-wealth .
  define buffer buf_tt-wth-par    for tt-wth-par.
  define buffer buf_tt-wth-ser    for tt-wth-ser.
  define buffer buf_tt-report     for tt-report .
  define buffer buf_tt-report-cli for tt-report-cli.

  define variable v-give-sum-units      as decimal   no-undo .
  define variable v-give-sum-money      as decimal   no-undo .
  define variable v-chg-give-sum-units  as decimal   no-undo .
  define variable v-chg-give-sum-money  as decimal   no-undo .
  define variable v-sell-sum-units      as decimal   no-undo .
  define variable v-sell-sum-money      as decimal   no-undo .
  define variable v-ret-sum-units       as decimal   no-undo .
  define variable v-ret-sum-money       as decimal   no-undo .
  define variable v-chg-ret-sum-units   as decimal   no-undo .
  define variable v-chg-ret-sum-money   as decimal   no-undo .
  define variable v-spi-sum-units       as decimal   no-undo .
  define variable v-spi-sum-money       as decimal   no-undo .
  define variable v-restFrom-units      as decimal   no-undo .
  define variable v-restFrom-money      as decimal   no-undo .
  define variable v-restEnd-units       as decimal   no-undo .
  define variable v-restEnd-money       as decimal   no-undo .
  define variable v-i                   as integer   no-undo .
  define variable v-total               as integer   no-undo .
  define variable v-counter             as integer   no-undo .
  define variable v-repfrm-str          as character no-undo .

  run clear-tt in this-procedure .

  run waitfram-show in this-procedure ("Обработка данных...") .

  /* заполняем контрагентов */
  if p-clients-recid-list <> ''
  then do:
    assign
      v-total = num-entries(p-clients-recid-list)
    .
    do v-i = 1 to v-total:
      find first buf_clients no-lock
        where recid(buf_clients) = integer(entry(v-i,p-clients-recid-list))
      no-error .
      if available buf_clients
      then do:
        find first buf_tt-clients
          where buf_tt-clients.obj-type = buf_clients.obj-type
            and buf_tt-clients.obj-code = buf_clients.obj-code
        no-error .
        if not available buf_tt-clients
        then do:
          create buf_tt-clients.
          buffer-copy buf_clients to buf_tt-clients.
        end.
      end.
    end.
  end. /* p-clients-recid-list <> '' */
  else do:
    for each buf_clients no-lock
    /*  where buf_clients.stts = 0  */
    :
      find first buf_tt-clients
        where buf_tt-clients.obj-type = buf_clients.obj-type
          and buf_tt-clients.obj-code = buf_clients.obj-code
      no-error .
      if not available buf_tt-clients
      then do:
        create buf_tt-clients.
        buffer-copy buf_clients to buf_tt-clients.
      end.
    end.

  end.
  /* список МЦ */
  if p-wth-recid-list <> ''
  then do:
    assign
      v-total = num-entries(p-wth-recid-list)
    .
    case p-rs-wth-type:
      when 1 then do:
        assign
          v-is-wth-restrict = yes
        .

        do v-i = 1 to v-total
        :
          find first buf_wealth no-lock
            where recid(buf_wealth) = integer( entry( v-i , p-wth-recid-list ) )
          no-error .
          if available buf_wealth then do:
            find first buf_tt-wealth no-lock
              where buf_tt-wealth.wth-code = buf_wealth.wth-code
            no-error .
            if not available buf_tt-wealth then do:
              create buf_tt-wealth.
              buffer-copy buf_wealth to buf_tt-wealth.
            end.
          end.
        end.
      end. /* when 1 then do: */
      when 2 then do:
        assign
          v-is-par-restrict = yes
        .

        do v-i = 1 to v-total
        :
          find first buf_wth-par no-lock
            where recid(buf_wth-par) = integer( entry( v-i , p-wth-recid-list ) )
          no-error .
          if available buf_wth-par then do:
            find first buf_tt-wth-par no-lock
              where buf_tt-wth-par.wth-code = buf_wth-par.wth-code
                and buf_tt-wth-par.par-code = buf_wth-par.par-code
            no-error .
            if not available buf_tt-wth-par then do:
              create buf_tt-wth-par.
              buffer-copy buf_wth-par to buf_tt-wth-par.
            end.
          end.
        end.
      end. /* when 2 then do: */
      when 3 then do:
        assign
          v-is-ser-restrict = yes
        .

        do v-i = 1 to v-total
        :
          find first buf_wth-ser no-lock
            where recid(buf_wth-ser) = integer( entry( v-i , p-wth-recid-list ) )
          no-error .
          if available buf_wth-ser then do :
            find first buf_tt-wth-ser no-lock
              where buf_tt-wth-ser.ser-code = buf_wth-ser.ser-code
                and buf_tt-wth-ser.db-num   = buf_wth-ser.db-num
            no-error .
            if not available buf_tt-wth-ser then do:
              create buf_tt-wth-ser.
              buffer-copy buf_wth-ser to buf_tt-wth-ser.
            end.
          end.
        end.
      end. /* when 3 then do: */
    end case .

  end. /* if p-wth-recid-list <> '' */

  run waitfram-hide in this-procedure .

  assign
    v-repfrm-str = "Расчет партий МЦ..."
  .
  etime(yes).
 /* За неимением индексов партии засовываем во временную таблицу с нужными индексами */
if p-dt-calc = 1 then do:  /*Если расчет по фактической дате*/
    if p-wth-recid-list <> '' and p-rs-wth-type = 1  then   do:
        for each buf_tt-wealth no-lock,
        each b_wth-parts no-lock where b_wth-parts.fact-date >= x-date-start
                                        and b_wth-parts.fact-date <= x-date-end
                                        and b_wth-parts.wth-code = buf_tt-wealth.wth-code
                                        and lookup(b_wth-parts.out-code,{&WDEDT_List-Zone}) = 0
                                        and (b_wth-parts.ext-doc-type = {&WDEDT_Exp_Ext} or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Exch}    or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Put_Cli} or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Dst_Cli} or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Put_Cash} or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Put_Sale})
                                        and b_wth-parts.fact-num <> 0    :
            create tt-wth-parts.
            buffer-copy b_wth-parts to tt-wth-parts.
        end.
        for each buf_tt-wealth no-lock,
        each b_wth-parts no-lock where ((b_wth-parts.fact-date > x-date-end and lookup(b_wth-parts.out-code,{&WDEDT_List-Zone}) = 0 and b_wth-parts.fact-num <> 0 ) or b_wth-parts.out-code = {&cli-zone} )
                                        and b_wth-parts.wth-code = buf_tt-wealth.wth-code
                                        and (b_wth-parts.ext-doc-type = {&WDEDT_Exp_Ext} or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Exch}    or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Put_Cli} or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Dst_Cli} or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Put_Cash} or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Put_Sale})
                                       :
            create tt-rest.
            buffer-copy b_wth-parts to tt-rest.
            /*if b_wth-parts.cli-code = 590 and  b_wth-parts.out-code <> {&cli-zone} then message tt-rest.fact-qnty. */

        end.

    end.
    else if p-wth-recid-list <> '' and p-rs-wth-type = 2 then do:
        for each buf_tt-wth-par no-lock ,
            each b_wth-parts no-lock where b_wth-parts.fact-date >= x-date-start
                                        and b_wth-parts.fact-date <= x-date-end
                                        and b_wth-parts.wth-code = buf_tt-wth-par.wth-code
                                        and b_wth-parts.par-code = buf_tt-wth-par.par-code
                                        and lookup(b_wth-parts.out-code,{&WDEDT_List-Zone}) = 0
                                        and (b_wth-parts.ext-doc-type = {&WDEDT_Exp_Ext} or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Exch}    or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Put_Cli} or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Dst_Cli} or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Put_Cash} or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Put_Sale})
                                        and b_wth-parts.fact-num <> 0 :
            create tt-wth-parts.
            buffer-copy b_wth-parts to tt-wth-parts.
        end.
        for each buf_tt-wth-par no-lock ,
            each b_wth-parts no-lock where ((b_wth-parts.fact-date > x-date-end and lookup(b_wth-parts.out-code,{&WDEDT_List-Zone}) = 0 and b_wth-parts.fact-num <> 0 ) or b_wth-parts.out-code = {&cli-zone} )
                                        and b_wth-parts.wth-code = buf_tt-wth-par.wth-code
                                        and b_wth-parts.par-code = buf_tt-wth-par.par-code
                                        and (b_wth-parts.ext-doc-type = {&WDEDT_Exp_Ext} or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Exch}    or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Put_Cli} or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Dst_Cli} or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Put_Cash} or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Put_Sale}):
            create tt-rest.
            buffer-copy b_wth-parts to tt-rest.
        end.

    end.
    else do:
        for each b_wth-parts no-lock where b_wth-parts.fact-date >= x-date-start
                                        and b_wth-parts.fact-date <= x-date-end
                                        and lookup(b_wth-parts.out-code,{&WDEDT_List-Zone}) = 0
                                        and (b_wth-parts.ext-doc-type = {&WDEDT_Exp_Ext} or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Exch}    or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Put_Cli} or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Dst_Cli} or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Put_Cash} or
                                              b_wth-parts.ext-doc-type = {&WDEDT_Put_Sale})
                                       and b_wth-parts.fact-num <> 0 :
            create tt-wth-parts.
            buffer-copy b_wth-parts to tt-wth-parts.
        end.
        for each b_wth-parts no-lock where ((b_wth-parts.fact-date > x-date-end and lookup(b_wth-parts.out-code,{&WDEDT_List-Zone}) = 0 and b_wth-parts.fact-num <> 0 ) or b_wth-parts.out-code = {&cli-zone} )
                                         and {&check_ext-type} :
            create tt-rest.
            buffer-copy b_wth-parts to tt-rest.
        end.

    end.
end.
if p-dt-calc = 2 then do:  /*Если расчет по сроку годности*/
 for each b_wth-parts no-lock where b_wth-parts.beg-dt >= x-date-start
                                and b_wth-parts.beg-dt <= x-date-end
                                and {&check_ext-type}:
    create tt-wth-parts.
    buffer-copy b_wth-parts to tt-wth-parts.
 end.
 if p-wth-recid-list <> '' and p-rs-wth-type = 1  then
    for each buf_tt-wealth no-lock,
    each b_wth-parts no-lock where b_wth-parts.beg-dt >= x-date-start
                                and b_wth-parts.beg-dt <= x-date-end
                                    and b_wth-parts.wth-code = buf_tt-wealth.wth-code
                                    and {&check_ext-type}:
        create tt-wth-parts.
        buffer-copy b_wth-parts to tt-wth-parts.
    end.
    else if p-wth-recid-list <> '' and p-rs-wth-type = 2 then
    for each buf_tt-wth-par no-lock ,
        each b_wth-parts no-lock where b_wth-parts.beg-dt >= x-date-start
                                and b_wth-parts.beg-dt <= x-date-end
                                    and b_wth-parts.wth-code = buf_tt-wth-par.wth-code
                                    and b_wth-parts.par-code = buf_tt-wth-par.par-code
                                    and {&check_ext-type}:
        create tt-wth-parts.
        buffer-copy b_wth-parts to tt-wth-parts.
    end.
    else
    for each b_wth-parts no-lock where b_wth-parts.beg-dt >= x-date-start
                                and b_wth-parts.beg-dt <= x-date-end
                                and {&check_ext-type}:
        create tt-wth-parts.
        buffer-copy b_wth-parts to tt-wth-parts.
    end.

end.
if p-dt-calc = 3 then do:  /*Если расчет по фактической дате и сроку годности*/
    if p-wth-recid-list <> '' and p-rs-wth-type = 1  then
    for each buf_tt-wealth no-lock,
    each b_wth-parts no-lock where b_wth-parts.fact-date >= x-date-start
                                    and b_wth-parts.fact-date <= x-date-end
                                    and b_wth-parts.wth-code = buf_tt-wealth.wth-code
                                    and b_wth-parts.beg-dt >= p-dtFrom
                                    and b_wth-parts.beg-dt <= p-dtTo
                                    and {&check_ext-type}:
        create tt-wth-parts.
        buffer-copy b_wth-parts to tt-wth-parts.
    end.
    else if p-wth-recid-list <> '' and p-rs-wth-type = 2 then
    for each buf_tt-wth-par no-lock ,
        each b_wth-parts no-lock where b_wth-parts.fact-date >= x-date-start
                                    and b_wth-parts.fact-date <= x-date-end
                                    and b_wth-parts.wth-code = buf_tt-wth-par.wth-code
                                    and b_wth-parts.wth-code = buf_tt-wth-par.par-code
                                    and b_wth-parts.beg-dt >= p-dtFrom
                                    and b_wth-parts.beg-dt <= p-dtTo
                                    and {&check_ext-type}:
        create tt-wth-parts.
        buffer-copy b_wth-parts to tt-wth-parts.
    end.
    else do:
      for each b_wth-parts no-lock where b_wth-parts.fact-date >= x-date-start
                                    and b_wth-parts.fact-date <= x-date-end
                                    and b_wth-parts.beg-dt >= p-dtFrom
                                    and b_wth-parts.beg-dt <= p-dtTo
                                    and {&check_ext-type}:
        create tt-wth-parts.
        buffer-copy b_wth-parts to tt-wth-parts.
      end.
      for each b_wth-parts no-lock where ((b_wth-parts.fact-date > x-date-end and lookup(b_wth-parts.out-code,{&WDEDT_List-Zone}) = 0 and b_wth-parts.fact-num <> 0 ) or b_wth-parts.out-code = {&cli-zone} )
                                         and {&check_ext-type}
                                         and b_wth-parts.beg-dt >= p-dtFrom
                                         and b_wth-parts.beg-dt <= p-dtTo
                                    :
            create tt-rest.
            buffer-copy b_wth-parts to tt-rest.
      end.

    end.
end.

/*message etime view-as alert-box.    */
 release tt-wth-parts.
  { rep/repfrm.i on 10 }
  for each buf_tt-clients
  :

    _wth-parts1:
    for each buf_wth-parts no-lock
      where buf_wth-parts.cli-type       = buf_tt-clients.obj-type
        and buf_wth-parts.cli-code       = buf_tt-clients.obj-code
        /*and buf_wth-parts.beg-dt        >= x-date-start
        and buf_wth-parts.beg-dt        <= x-date-end
        and buf_wth-parts.ext-doc-type  <> {&WDEDT_Put_Cash}
        and buf_wth-parts.ext-doc-type  <> {&WDEDT_Put_Sale}*/
        and lookup(buf_wth-parts.out-code,{&WDEDT_List-Zone}) = 0 ,
        first buf_wealth no-lock
            where buf_wealth.wth-code = buf_wth-parts.wth-code ,
        first buf_wth-par no-lock   /*Находим номинал в любом случае, так как надо знать значение номинала для подсчета количество в литрах.*/
          where buf_wth-par.wth-code = buf_wth-parts.wth-code
            and buf_wth-par.par-code = buf_wth-parts.par-code


    :
      assign
        v-counter = v-counter + 1
      .
      { rep/repfrm.i disp v-counter v-repfrm-str }
      if      buf_wth-parts.fact-qnty   = 0
         and  buf_wth-parts.price-rubl  = 0
      then do:
        next _wth-parts1.
      end.

      if buf_wth-parts.ext-doc-type = {&WDEDT_Exp_Ext} or
         buf_wth-parts.ext-doc-type = {&WDEDT_Exch}    or
         buf_wth-parts.ext-doc-type = {&WDEDT_Put_Cli} or
         buf_wth-parts.ext-doc-type = {&WDEDT_Dst_Cli} or
         buf_wth-parts.ext-doc-type = {&WDEDT_Put_Cash} or
         buf_wth-parts.ext-doc-type = {&WDEDT_Put_Sale}
      then do:
        find first buf_tt-report
          where buf_tt-report.cli-type = buf_wth-parts.cli-type
            and buf_tt-report.cli-code = buf_wth-parts.cli-code
            and buf_tt-report.wth-code = buf_wth-parts.wth-code
            and buf_tt-report.par-code = buf_wth-parts.par-code
            and buf_tt-report.ser-code = buf_wth-parts.ser-code
            and buf_tt-report.db-num   = buf_wth-parts.db-num
        no-error .
        if not available buf_tt-report
        then do:

          if v-is-wth-restrict = yes
          then do:
            find first buf_tt-wealth
              where buf_tt-wealth.wth-code = buf_wth-parts.wth-code
            no-error .
            if not available buf_tt-wealth
            then do:
              next _wth-parts1.
            end.
          end. /* v-is-wth-restrict = yes */

          if v-is-par-restrict = yes
          then do:
            find first buf_tt-wth-par
              where buf_tt-wth-par.wth-code = buf_wth-parts.wth-code
                and buf_tt-wth-par.par-code = buf_wth-parts.par-code
            no-error .
            if not available buf_tt-wth-par
            then do:
              next _wth-parts1.
            end.
          end. /* v-is-par-restrict = yes */

          if v-is-ser-restrict = yes
          then do:
            find first buf_tt-wth-ser
              where buf_wth-ser.ser-code = buf_wth-parts.ser-code
                and buf_wth-ser.db-num   = buf_wth-parts.db-num
            no-error .
            if not available buf_tt-wth-ser
            then do:
              next _wth-parts1.
            end.
          end. /* if v-is-ser-restrict = yes */

          find first buf_wth-ser no-lock
            where buf_wth-ser.ser-code = buf_wth-parts.ser-code
              and buf_wth-ser.db-num   = buf_wth-parts.db-num
          no-error .
          if not available buf_wth-ser
          then do:
            next _wth-parts1.
          end.

          create buf_tt-report.
          assign
            buf_tt-report.cli-type      = buf_wth-parts.cli-type
            buf_tt-report.cli-code      = buf_wth-parts.cli-code
            buf_tt-report.wth-code      = buf_wth-parts.wth-code
            buf_tt-report.par-code      = buf_wth-parts.par-code
            buf_tt-report.ser-code      = buf_wth-parts.ser-code
            buf_tt-report.db-num        = buf_wth-parts.db-num
            buf_tt-report.cli-name      = buf_tt-clients.obj-name
            buf_tt-report.talon-name    = buf_wealth.wth-name
            buf_tt-report.talon-nominal = substitute("&1 &2",  buf_wth-par.par-val, buf_wth-par.par-unit )
            buf_tt-report.talon-series  = buf_wth-ser.series
          .
        end.
      end.
   /*   message  buf_wth-parts.wth-code    buf_wth-parts.par-code buf_wth-parts.ext-doc-type buf_wth-parts.fact-qnt buf_wth-parts.fact-num view-as alert-box.*/
      case buf_wth-parts.ext-doc-type
      :
        when {&WDEDT_Exp_Ext}
        then do:
          assign
            buf_tt-report.give-sum-units = buf_tt-report.give-sum-units + buf_wth-parts.fact-qnty * buf_wth-par.par-val
            buf_tt-report.give-sum-money = buf_tt-report.give-sum-money + buf_wth-parts.price-rubl * buf_wth-parts.fact-qnty
          .
        end. /* {&WDEDT_Exp_Ext} */

        when {&WDEDT_Exch}
        then do:
          if buf_wth-parts.type = {&expense}
          then do:
            assign
              buf_tt-report.chg-give-sum-units = buf_tt-report.chg-give-sum-units + buf_wth-parts.fact-qnty * buf_wth-par.par-val
              buf_tt-report.chg-give-sum-money = buf_tt-report.chg-give-sum-money + buf_wth-parts.price-rubl * buf_wth-parts.fact-qnty
            .
          end.
          if buf_wth-parts.type = {&income}
          then do:
            assign
              buf_tt-report.chg-ret-sum-units = buf_tt-report.chg-ret-sum-units + buf_wth-parts.fact-qnty * buf_wth-par.par-val
              buf_tt-report.chg-ret-sum-money = buf_tt-report.chg-ret-sum-money + buf_wth-parts.price-rubl * buf_wth-parts.fact-qnty
            .
          end.
        end. /* {&WDEDT_Exch} */

        when {&WDEDT_Put_Cli}
        then do:
            assign  buf_tt-report.ret-sum-units = buf_tt-report.ret-sum-units + buf_wth-parts.fact-qnty * buf_wth-par.par-val
            buf_tt-report.ret-sum-money = buf_tt-report.ret-sum-money + buf_wth-parts.price-rubl * buf_wth-parts.fact-qnty
          .
        end. /* {&WDEDT_Put_Cli} */

        when {&WDEDT_Dst_Cli}
        then do:
          assign
            buf_tt-report.spi-sum-units = buf_tt-report.spi-sum-units + buf_wth-parts.fact-qnty * buf_wth-par.par-val
            buf_tt-report.spi-sum-money = buf_tt-report.spi-sum-money + buf_wth-parts.price-rubl * buf_wth-parts.fact-qnty
          .
        end. /* {&WDEDT_Dst_Cli} */
        when {&WDEDT_Put_Cash} or
        when {&WDEDT_Put_Sale}
        then do:
       /*   message  '####' buf_wth-parts.wth-code     buf_wth-parts.par-code buf_wth-parts.fact-qnty buf_wth-par.par-val view-as alert-box. */

          assign
            buf_tt-report.sell-sum-units = buf_tt-report.sell-sum-units + buf_wth-parts.fact-qnty * buf_wth-par.par-val
            buf_tt-report.sell-sum-money = buf_tt-report.sell-sum-money + buf_wth-parts.price-rubl * buf_wth-parts.fact-qnty
          .
        end. /* {&WDEDT_Put_Cash} */

      end case.
    end. /* _wth-parts: */

    /* Расчет остатков */
    def buffer buf-rest for tt-rest.
    if p-dt-calc = 1 or p-dt-calc = 3 then do:
      _wth-rest:     /*Собираем свободную зону по клиенту, для получения остатков*/
      for each  buf-rest no-lock where buf-rest.cli-type       = buf_tt-clients.obj-type
                           and buf-rest.cli-code       = buf_tt-clients.obj-code
        ,first buf_wealth no-lock
            where buf_wealth.wth-code = buf-rest.wth-code
        ,first buf_wth-par no-lock   /*Находим номинал в любом случае, так как надо знать значение номинала для подсчета количество в литрах.*/
          where buf_wth-par.wth-code = buf-rest.wth-code
            and buf_wth-par.par-code = buf-rest.par-code
           :
        find first buf_tt-report
          where buf_tt-report.cli-type = buf-rest.cli-type
            and buf_tt-report.cli-code = buf-rest.cli-code
            and buf_tt-report.wth-code = buf-rest.wth-code
            and buf_tt-report.par-code = buf-rest.par-code
            and buf_tt-report.ser-code = buf-rest.ser-code
            and buf_tt-report.db-num   = buf-rest.db-num
        no-error .
        if not available buf_tt-report
        then do:

          if v-is-wth-restrict = yes
          then do:
            find first buf_tt-wealth
              where buf_tt-wealth.wth-code = buf-rest.wth-code
            no-error .
            if not available buf_tt-wealth
            then do:
              next _wth-rest.
            end.
          end. /* v-is-wth-restrict = yes */

          if v-is-par-restrict = yes
          then do:
            find first buf_tt-wth-par
              where buf_tt-wth-par.wth-code = buf-rest.wth-code
                and buf_tt-wth-par.par-code = buf-rest.par-code
            no-error .
            if not available buf_tt-wth-par
            then do:
              next _wth-rest.
            end.
          end. /* v-is-par-restrict = yes */

          if v-is-ser-restrict = yes
          then do:
            find first buf_tt-wth-ser
              where buf_wth-ser.ser-code = buf-rest.ser-code
                and buf_wth-ser.db-num   = buf-rest.db-num
            no-error .
            if not available buf_tt-wth-ser
            then do:
              next _wth-rest.
            end.
          end. /* if v-is-ser-restrict = yes */
                   /*
          find first buf_wealth no-lock
            where buf_wealth.wth-code = buf-rest.wth-code
          no-error .
          if not available buf_wealth
          then do:
            next _wth-rest.
          end.
          find first buf_wth-par no-lock   /*Находим номинал в любом случае, так как надо знать значение номинала для подсчета количество в литрах.*/
          where buf_wth-par.wth-code = buf-rest.wth-code
            and buf_wth-par.par-code = buf-rest.par-code
          no-error .
          if not available buf_wth-par
          then do:
            next _wth-rest.
          end.   */
          find first buf_wth-ser no-lock
            where buf_wth-ser.ser-code = buf-rest.ser-code
              and buf_wth-ser.db-num   = buf-rest.db-num
          no-error .
          if not available buf_wth-ser
          then do:
            next _wth-rest.
          end.

          create buf_tt-report.
          assign
            buf_tt-report.cli-type      = buf-rest.cli-type
            buf_tt-report.cli-code      = buf-rest.cli-code
            buf_tt-report.wth-code      = buf-rest.wth-code
            buf_tt-report.par-code      = buf-rest.par-code
            buf_tt-report.ser-code      = buf-rest.ser-code
            buf_tt-report.db-num        = buf-rest.db-num
            buf_tt-report.cli-name      = buf_tt-clients.obj-name
            buf_tt-report.talon-name    = buf_wealth.wth-name
            buf_tt-report.talon-nominal = substitute("&1 &2",  buf_wth-par.par-val, buf_wth-par.par-unit )
            buf_tt-report.talon-series  = buf_wth-ser.series
          .
        end.
             if buf-rest.out-code <> {&cli-zone} and (buf-rest.ext-doc-type = {&WDEDT_Exp_Ext} or (buf-rest.ext-doc-type = {&WDEDT_Exch} and buf-rest.type  = {&expense})) then
                          assign  buf_tt-report.restEnd-units = buf_tt-report.restEnd-units - buf-rest.fact-qnty * buf_wth-par.par-val
                                  buf_tt-report.restEnd-money = buf_tt-report.restEnd-money - buf-rest.price-rubl * buf-rest.fact-qnty
                          .
                          else    assign  buf_tt-report.restEnd-units = buf_tt-report.restEnd-units + buf-rest.fact-qnty * buf_wth-par.par-val
                                  buf_tt-report.restEnd-money = buf_tt-report.restEnd-money + buf-rest.price-rubl * buf-rest.fact-qnty
                          .

      end.   /*for each  buf-rest*/

      for each buf_tt-report where buf_tt-report.cli-type = buf_tt-clients.obj-type
                               and buf_tt-report.cli-code = buf_tt-clients.obj-code :
            /* Остатки на начало рассчитываем как остатки на конец минус обороты*/
            assign  buf_tt-report.restFrom-units = buf_tt-report.restEnd-units - buf_tt-report.give-sum-units - buf_tt-report.chg-give-sum-units
                                                  + buf_tt-report.chg-ret-sum-units + buf_tt-report.ret-sum-units + buf_tt-report.spi-sum-units  + buf_tt-report.sell-sum-units
                    buf_tt-report.restFrom-money = buf_tt-report.restEnd-money - buf_tt-report.give-sum-money - buf_tt-report.chg-give-sum-money
                                                  + buf_tt-report.chg-ret-sum-money + buf_tt-report.ret-sum-money + buf_tt-report.spi-sum-money + buf_tt-report.sell-sum-money
            .
      end. /* each tt-report  */

    end.  /*p-dt-calc = 1 Расчет остатков*/
    if p-dt-calc = 2 then do:
      for each buf_tt-report where buf_tt-report.cli-type = buf_tt-clients.obj-type
                               and buf_tt-report.cli-code = buf_tt-clients.obj-code :
            /* Остатки на начало рассчитываем как остатки на конец минус обороты*/
            assign  buf_tt-report.restEnd-units = buf_tt-report.give-sum-units + buf_tt-report.chg-give-sum-units
                                                  - buf_tt-report.chg-ret-sum-units - buf_tt-report.ret-sum-units - buf_tt-report.spi-sum-units  - buf_tt-report.sell-sum-units
                    buf_tt-report.restEnd-money = buf_tt-report.give-sum-money + buf_tt-report.chg-give-sum-money
                                                  - buf_tt-report.chg-ret-sum-money - buf_tt-report.ret-sum-money - buf_tt-report.spi-sum-money - buf_tt-report.sell-sum-money
            .
      end. /* each tt-report  */

    end.  /*p-dt-calc = 2 Расчет остатков*/
    if p-dt-calc = 3 then do:

    end.  /*p-dt-calc = 3 Расчет остатков*/

  end. /* for each buf_tt-clients */
  { rep/repfrm.i off }


  assign
    v-give-sum-units     = 0
    v-give-sum-money     = 0
    v-chg-give-sum-units = 0
    v-chg-give-sum-money = 0
    v-sell-sum-units     = 0
    v-sell-sum-money     = 0
    v-ret-sum-units      = 0
    v-ret-sum-money      = 0
    v-chg-ret-sum-units  = 0
    v-chg-ret-sum-money  = 0
    v-spi-sum-units      = 0
    v-spi-sum-money      = 0
    v-restFrom-units     = 0
    v-restFrom-money     = 0
    v-restEnd-units      = 0
    v-restEnd-money      = 0
  .

  run waitfram-show in this-procedure ("Расчет подитогов по клиентам...") .

  for each buf_tt-report
    break by buf_tt-report.cli-type
          by buf_tt-report.cli-code
  :
    assign
      v-give-sum-units      = v-give-sum-units     + buf_tt-report.give-sum-units
      v-give-sum-money      = v-give-sum-money     + buf_tt-report.give-sum-money
      v-chg-give-sum-units  = v-chg-give-sum-units + buf_tt-report.chg-give-sum-units
      v-chg-give-sum-money  = v-chg-give-sum-money + buf_tt-report.chg-give-sum-money
      v-sell-sum-units      = v-sell-sum-units     + buf_tt-report.sell-sum-units
      v-sell-sum-money      = v-sell-sum-money     + buf_tt-report.sell-sum-money
      v-ret-sum-units       = v-ret-sum-units      + buf_tt-report.ret-sum-units
      v-ret-sum-money       = v-ret-sum-money      + buf_tt-report.ret-sum-money
      v-chg-ret-sum-units   = v-chg-ret-sum-units  + buf_tt-report.chg-ret-sum-units
      v-chg-ret-sum-money   = v-chg-ret-sum-money  + buf_tt-report.chg-ret-sum-money
      v-spi-sum-units       = v-spi-sum-units      + buf_tt-report.spi-sum-units
      v-spi-sum-money       = v-spi-sum-money      + buf_tt-report.spi-sum-money
      v-restFrom-units      = v-restFrom-units     + buf_tt-report.restFrom-units
      v-restFrom-money      = v-restFrom-money     + buf_tt-report.restFrom-money
      v-restEnd-units       = v-restEnd-units      + buf_tt-report.restEnd-units
      v-restEnd-money       = v-restEnd-money      + buf_tt-report.restEnd-money
    .

    if last-of(buf_tt-report.cli-type)
      or last-of(buf_tt-report.cli-code)
    then do:
      create buf_tt-report-cli.
      assign
        buf_tt-report-cli.cli-type            = buf_tt-report.cli-type
        buf_tt-report-cli.cli-code            = buf_tt-report.cli-code
        buf_tt-report-cli.give-sum-units      = v-give-sum-units
        buf_tt-report-cli.give-sum-money      = v-give-sum-money
        buf_tt-report-cli.chg-give-sum-units  = v-chg-give-sum-units
        buf_tt-report-cli.chg-give-sum-money  = v-chg-give-sum-money
        buf_tt-report-cli.sell-sum-units      = v-sell-sum-units
        buf_tt-report-cli.sell-sum-money      = v-sell-sum-money
        buf_tt-report-cli.ret-sum-units       = v-ret-sum-units
        buf_tt-report-cli.ret-sum-money       = v-ret-sum-money
        buf_tt-report-cli.chg-ret-sum-units   = v-chg-ret-sum-units
        buf_tt-report-cli.chg-ret-sum-money   = v-chg-ret-sum-money
        buf_tt-report-cli.spi-sum-units       = v-spi-sum-units
        buf_tt-report-cli.spi-sum-money       = v-spi-sum-money
        buf_tt-report-cli.restFrom-units      = v-restFrom-units
        buf_tt-report-cli.restFrom-money      = v-restFrom-money
        buf_tt-report-cli.restEnd-units       = v-restEnd-units
        buf_tt-report-cli.restEnd-money       = v-restEnd-money
        v-give-sum-units                      = 0
        v-give-sum-money                      = 0
        v-chg-give-sum-units                  = 0
        v-chg-give-sum-money                  = 0
        v-sell-sum-units                      = 0
        v-sell-sum-money                      = 0
        v-ret-sum-units                       = 0
        v-ret-sum-money                       = 0
        v-chg-ret-sum-units                   = 0
        v-chg-ret-sum-money                   = 0
        v-spi-sum-units                       = 0
        v-spi-sum-money                       = 0
        v-restFrom-units                      = 0
        v-restFrom-money                      = 0
        v-restEnd-units                       = 0
        v-restEnd-money                       = 0
      .
    end.
  end.

  run waitfram-hide in this-procedure .

end.

end procedure. /* fill-tt */

/* ================================================================== */
procedure print-header :

do
on error undo, return error return-value
:

define buffer buf_clients for ub.clients.
define buffer buf_wealth  for ub.wealth.
define buffer buf_wth-par for ub.wth-par.
define buffer buf_wth-ser for ub.wth-ser.

define variable v-date-range    as character no-undo .
define variable v-clients-list  as character no-undo .
define variable v-wth-list      as character no-undo .

if  p-dt-calc = 1 then v-date-range = 'За период '.
else  if  p-dt-calc = 2 then v-date-range = ' Даты начала срока годности '.

  assign
    v-date-range = v-date-range + substitute( "с &1 по &2"
                             , string( x-Date-Start , "99/99/9999" )
                             , string( x-Date-End  , "99/99/9999" )
                             )
  .
if  p-dt-calc = 3 then  v-date-range = v-date-range + substitute(" (Дата начала срока годности с &1 по &2) "
                                                      ,p-dtFrom
                                                      ,p-dtTo).

  if p-rs-supp <> 1 then do: /* выборка по контрагентам */
    for each tt-clients no-lock :
      find first buf_clients no-lock
        where buf_clients.obj-type = tt-clients.obj-type
          and buf_clients.obj-code = tt-clients.obj-code
      no-error .
      if available buf_clients then do:
        assign
          v-clients-list = v-clients-list + buf_clients.obj-name + "\n":U
        .
      end.
    end.
  end.
  else do:
    assign
      v-clients-list = "Все":U
    .
  end.

  /* ограничения МЦ */
  if v-is-wth-restrict then do:
    assign
      v-wth-list = "МЦ:":U + " ":U
    .
    for each tt-wealth :
      assign
        v-wth-list = v-wth-list + tt-wealth.wth-name + ",":U
      .
    end.
  end.

  if v-is-par-restrict then do:
    assign
      v-wth-list = "Номиналы:":U + " ":U
    .

    for each tt-wth-par :
      find first buf_wth-par no-lock
        where buf_wth-par.wth-code = tt-wth-par.wth-code
          and buf_wth-par.par-code = tt-wth-par.par-code
      no-error .
      find first buf_wealth no-lock
        where buf_wealth.wth-code = tt-wth-par.wth-code
      no-error .
      if available buf_wth-par and available buf_wealth then do:
        assign
          v-wth-list = v-wth-list + substitute( "&1 - &2 &3&4"
                                              , buf_wealth.wth-name
                                              , buf_wth-par.par-val
                                              , buf_wth-par.par-unit
                                              , ",":U
                                              )
        .
      end.
    end.
  end.
  if v-is-ser-restrict then do:
    assign
      v-wth-list = "Серии:":U + " ":U
    .

    for each tt-wth-ser :
      find first buf_wth-par no-lock
        where buf_wth-par.wth-code = tt-wth-ser.wth-code
          and buf_wth-par.par-code = tt-wth-ser.par-code
      no-error .
      find first buf_wealth no-lock
        where buf_wealth.wth-code = tt-wth-par.wth-code
      no-error .
      if available buf_wth-par and available buf_wealth then do:
        assign
          v-wth-list = v-wth-list + substitute( "&1 : &2 - &3 &4&5"
                                              , tt-wth-ser.series
                                              , buf_wealth.wth-name
                                              , buf_wth-par.par-val
                                              , buf_wth-par.par-unit
                                              , ",":U
                                              )
        .
      end.
    end.
  end.

  v-wth-list = substring(v-wth-list,1,length(v-wth-list) - 1) no-error.

  if  v-is-wth-restrict = no and
      v-is-par-restrict = no and
      v-is-ser-restrict = no
  then do:
    assign
      v-wth-list = "Все":U
    .
  end.

  run wthobrxl-write-cell-data in this-procedure ( input {&wthobrxl-h_daterange}
                                                 , input v-date-range
                                                 ) .
  run wthobrxl-write-cell-data in this-procedure ( input {&wthobrxl-h_clients}
                                                 , input v-clients-list
                                                 ) .
  run wthobrxl-write-cell-data in this-procedure ( input {&wthobrxl-h_wth}
                                                 , input v-wth-list
                                                 ) .

end.

end procedure. /* print-header */

/* ================================================================== */
procedure print-report :
  define buffer buf_tt-report     for tt-report .
  define buffer buf_tt-report-cli for tt-report-cli.

  define variable v-give-sum-units            as decimal   no-undo .
  define variable v-give-sum-money            as decimal   no-undo .
  define variable v-chg-give-sum-units        as decimal   no-undo .
  define variable v-chg-give-sum-money        as decimal   no-undo .
  define variable v-sell-sum-units            as decimal   no-undo .
  define variable v-sell-sum-money            as decimal   no-undo .
  define variable v-ret-sum-units             as decimal   no-undo .
  define variable v-ret-sum-money             as decimal   no-undo .
  define variable v-chg-ret-sum-units         as decimal   no-undo .
  define variable v-chg-ret-sum-money         as decimal   no-undo .
  define variable v-spi-sum-units             as decimal   no-undo .
  define variable v-spi-sum-money             as decimal   no-undo .
  define variable v-RestFrom-units            as decimal   no-undo .
  define variable v-restFrom-money            as decimal   no-undo .
  define variable v-restEnd-units             as decimal   no-undo .
  define variable v-restEnd-money             as decimal   no-undo .
  define variable v-total-give-sum-units      as decimal   no-undo .
  define variable v-total-give-sum-money      as decimal   no-undo .
  define variable v-total-chg-give-sum-units  as decimal   no-undo .
  define variable v-total-chg-give-sum-money  as decimal   no-undo .
  define variable v-total-sell-sum-units      as decimal   no-undo .
  define variable v-total-sell-sum-money      as decimal   no-undo .
  define variable v-total-ret-sum-units       as decimal   no-undo .
  define variable v-total-ret-sum-money       as decimal   no-undo .
  define variable v-total-chg-ret-sum-units   as decimal   no-undo .
  define variable v-total-chg-ret-sum-money   as decimal   no-undo .
  define variable v-total-spi-sum-units       as decimal   no-undo .
  define variable v-total-spi-sum-money       as decimal   no-undo .
  define variable v-total-RestFrom-units      as decimal   no-undo .
  define variable v-total-restFrom-money      as decimal   no-undo .
  define variable v-total-restEnd-units       as decimal   no-undo .
  define variable v-total-restEnd-money       as decimal   no-undo .


do
on error undo, return error return-value
:

  _rep-line:
  for each buf_tt-report
  break by buf_tt-report.cli-type
        by buf_tt-report.cli-code
        by buf_tt-report.wth-code
        by buf_tt-report.par-code
        by buf_tt-report.ser-code
        by buf_tt-report.db-num
  :

    if first-of(buf_tt-report.cli-type) or first-of(buf_tt-report.cli-code)
    then do:
      find first buf_tt-report-cli
        where buf_tt-report-cli.cli-type  = buf_tt-report.cli-type
          and buf_tt-report-cli.cli-code  = buf_tt-report.cli-code
      no-error .
      if not available buf_tt-report-cli
      then do:
        message
          substitute( "Не найдены итоги по клиенту &1 &2 - &3"
                    , buf_tt-report.cli-code
                    , buf_tt-report.cli-type
                    , buf_tt-report.cli-name
                    )
        view-as alert-box error.
        next _rep-line.
      end.

      run wthobrxl-write-line-data in this-procedure ( input buf_tt-report.cli-name
                                                     , input " ":u
                                                     , input " ":u
                                                     , input " ":u
                                                     , input string( buf_tt-report-cli.give-sum-units     )
                                                     , input string( buf_tt-report-cli.give-sum-money     )
                                                     , input string( buf_tt-report-cli.chg-give-sum-units )
                                                     , input string( buf_tt-report-cli.chg-give-sum-money )
                                                     , input string( buf_tt-report-cli.sell-sum-units     )
                                                     , input string( buf_tt-report-cli.sell-sum-money     )
                                                     , input string( buf_tt-report-cli.ret-sum-units      )
                                                     , input string( buf_tt-report-cli.ret-sum-money      )
                                                     , input string( buf_tt-report-cli.chg-ret-sum-units  )
                                                     , input string( buf_tt-report-cli.chg-ret-sum-money  )
                                                     , input string( buf_tt-report-cli.spi-sum-units      )
                                                     , input string( buf_tt-report-cli.spi-sum-money      )
                                                     , input string( buf_tt-report-cli.RestFrom-units )
                                                     , input string( buf_tt-report-cli.restFrom-money )
                                                     , input string( buf_tt-report-cli.restEnd-units  )
                                                     , input string( buf_tt-report-cli.restEnd-money  )

                                                     ) .
      if p-cb-wth-detail <> {&wth-no-detail}
      then do:
        run wthobrxl-sheet1-write-line-format in this-procedure ( "St" ).
      end.
    end. /* if first-of(buf_tt-report.cli-type) or first-of(buf_tt-report.cli-code) */

    assign
      v-total-give-sum-units      = v-total-give-sum-units     + buf_tt-report.give-sum-units
      v-total-give-sum-money      = v-total-give-sum-money     + buf_tt-report.give-sum-money
      v-total-chg-give-sum-units  = v-total-chg-give-sum-units + buf_tt-report.chg-give-sum-units
      v-total-chg-give-sum-money  = v-total-chg-give-sum-money + buf_tt-report.chg-give-sum-money
      v-total-sell-sum-units      = v-total-sell-sum-units     + buf_tt-report.sell-sum-units
      v-total-sell-sum-money      = v-total-sell-sum-money     + buf_tt-report.sell-sum-money
      v-total-ret-sum-units       = v-total-ret-sum-units      + buf_tt-report.ret-sum-units
      v-total-ret-sum-money       = v-total-ret-sum-money      + buf_tt-report.ret-sum-money
      v-total-chg-ret-sum-units   = v-total-chg-ret-sum-units  + buf_tt-report.chg-ret-sum-units
      v-total-chg-ret-sum-money   = v-total-chg-ret-sum-money  + buf_tt-report.chg-ret-sum-money
      v-total-spi-sum-units       = v-total-spi-sum-units      + buf_tt-report.spi-sum-units
      v-total-spi-sum-money       = v-total-spi-sum-money      + buf_tt-report.spi-sum-money
      v-total-RestFrom-units  = v-total-RestFrom-units  + buf_tt-report.RestFrom-units
      v-total-restFrom-money  = v-total-restFrom-money  + buf_tt-report.restFrom-money
      v-total-restEnd-units   = v-total-restEnd-units   + buf_tt-report.restEnd-units
      v-total-restEnd-money   = v-total-restEnd-money   + buf_tt-report.restEnd-money

    .

    if p-cb-wth-detail <> {&wth-no-detail}
    then do:
      assign
        v-give-sum-units      = v-give-sum-units     + buf_tt-report.give-sum-units
        v-give-sum-money      = v-give-sum-money     + buf_tt-report.give-sum-money
        v-chg-give-sum-units  = v-chg-give-sum-units + buf_tt-report.chg-give-sum-units
        v-chg-give-sum-money  = v-chg-give-sum-money + buf_tt-report.chg-give-sum-money
        v-sell-sum-units      = v-sell-sum-units     + buf_tt-report.sell-sum-units
        v-sell-sum-money      = v-sell-sum-money     + buf_tt-report.sell-sum-money
        v-ret-sum-units       = v-ret-sum-units      + buf_tt-report.ret-sum-units
        v-ret-sum-money       = v-ret-sum-money      + buf_tt-report.ret-sum-money
        v-chg-ret-sum-units   = v-chg-ret-sum-units  + buf_tt-report.chg-ret-sum-units
        v-chg-ret-sum-money   = v-chg-ret-sum-money  + buf_tt-report.chg-ret-sum-money
        v-spi-sum-units       = v-spi-sum-units      + buf_tt-report.spi-sum-units
        v-spi-sum-money       = v-spi-sum-money      + buf_tt-report.spi-sum-money
        v-RestFrom-units   = v-RestFrom-units  + buf_tt-report.RestFrom-units
        v-restFrom-money   = v-restFrom-money  + buf_tt-report.restFrom-money
        v-restEnd-units    = v-restEnd-units   + buf_tt-report.restEnd-units
        v-restEnd-money    = v-restEnd-money   + buf_tt-report.restEnd-money

      .
    end. /* if p-cb-wth-detail <> th-no-detail */


/*
th-no-detail 1
wth-wealth-detail 2
wth-wealth-par-detail
wth-wealth-ser-detail
*/
    if    p-cb-wth-detail = {&wth-wealth-detail}
      and last-of(buf_tt-report.wth-code)
    then do:
      run wthobrxl-write-line-data in this-procedure ( input ' ':U
                                                     , input buf_tt-report.talon-name
                                                     , input ' ':U
                                                     , input ' ':U
                                                     , input string( v-give-sum-units     )
                                                     , input string( v-give-sum-money     )
                                                     , input string( v-chg-give-sum-units )
                                                     , input string( v-chg-give-sum-money )
                                                     , input string( v-sell-sum-units     )
                                                     , input string( v-sell-sum-money     )
                                                     , input string( v-ret-sum-units      )
                                                     , input string( v-ret-sum-money      )
                                                     , input string( v-chg-ret-sum-units  )
                                                     , input string( v-chg-ret-sum-money  )
                                                     , input string( v-spi-sum-units      )
                                                     , input string( v-spi-sum-money      )
                                                     , input string( v-RestFrom-units  )
                                                     , input string( v-restFrom-money  )
                                                     , input string( v-restEnd-units   )
                                                     , input string( v-restEnd-money   )
                                                      ) .

      assign
        v-give-sum-units      = 0
        v-give-sum-money      = 0
        v-chg-give-sum-units  = 0
        v-chg-give-sum-money  = 0
        v-sell-sum-units      = 0
        v-sell-sum-money      = 0
        v-ret-sum-units       = 0
        v-ret-sum-money       = 0
        v-chg-ret-sum-units   = 0
        v-chg-ret-sum-money   = 0
        v-spi-sum-units       = 0
        v-spi-sum-money       = 0
        v-RestFrom-units      = 0
        v-restFrom-money      = 0
        v-restEnd-units       = 0
        v-restEnd-money       = 0
      .
    end. /* p-cb-wth-detail = {&wth-wealth-detail} */

    if    p-cb-wth-detail = {&wth-wealth-par-detail}
      and ( last-of(buf_tt-report.wth-code) or last-of(buf_tt-report.par-code) )
    then do:
      run wthobrxl-write-line-data in this-procedure ( input ' ':U
                                                     , input buf_tt-report.talon-name
                                                     , input buf_tt-report.talon-nominal
                                                     , input ' ':U
                                                     , input string( v-give-sum-units     )
                                                     , input string( v-give-sum-money     )
                                                     , input string( v-chg-give-sum-units )
                                                     , input string( v-chg-give-sum-money )
                                                     , input string( v-sell-sum-units     )
                                                     , input string( v-sell-sum-money     )
                                                     , input string( v-ret-sum-units      )
                                                     , input string( v-ret-sum-money      )
                                                     , input string( v-chg-ret-sum-units  )
                                                     , input string( v-chg-ret-sum-money  )
                                                     , input string( v-spi-sum-units      )
                                                     , input string( v-spi-sum-money      )
                                                     , input string( v-RestFrom-units  )
                                                     , input string( v-restFrom-money  )
                                                     , input string( v-restEnd-units   )
                                                     , input string( v-restEnd-money   )
                                                     ) .

      assign
        v-give-sum-units      = 0
        v-give-sum-money      = 0
        v-chg-give-sum-units  = 0
        v-chg-give-sum-money  = 0
        v-sell-sum-units      = 0
        v-sell-sum-money      = 0
        v-ret-sum-units       = 0
        v-ret-sum-money       = 0
        v-chg-ret-sum-units   = 0
        v-chg-ret-sum-money   = 0
        v-spi-sum-units       = 0
        v-spi-sum-money       = 0
        v-RestFrom-units      = 0
        v-restFrom-money      = 0
        v-restEnd-units       = 0
        v-restEnd-money       = 0

      .
    end. /* p-cb-wth-detail = {&wth-wealth-par-detail} */

    if    p-cb-wth-detail = {&wth-wealth-ser-detail}
      and ( last-of(buf_tt-report.ser-code) or last-of(buf_tt-report.db-num) )
    then do:
      run wthobrxl-write-line-data in this-procedure ( input ' ':U
                                                     , input buf_tt-report.talon-name
                                                     , input buf_tt-report.talon-nominal
                                                     , input buf_tt-report.talon-series
                                                     , input string( v-give-sum-units     )
                                                     , input string( v-give-sum-money     )
                                                     , input string( v-chg-give-sum-units )
                                                     , input string( v-chg-give-sum-money )
                                                     , input string( v-sell-sum-units     )
                                                     , input string( v-sell-sum-money     )
                                                     , input string( v-ret-sum-units      )
                                                     , input string( v-ret-sum-money      )
                                                     , input string( v-chg-ret-sum-units  )
                                                     , input string( v-chg-ret-sum-money  )
                                                     , input string( v-spi-sum-units      )
                                                     , input string( v-spi-sum-money      )
                                                     , input string( v-RestFrom-units  )
                                                     , input string( v-restFrom-money  )
                                                     , input string( v-restEnd-units   )
                                                     , input string( v-restEnd-money   )
                                                     ) .
      assign
        v-give-sum-units      = 0
        v-give-sum-money      = 0
        v-chg-give-sum-units  = 0
        v-chg-give-sum-money  = 0
        v-sell-sum-units      = 0
        v-sell-sum-money      = 0
        v-ret-sum-units       = 0
        v-ret-sum-money       = 0
        v-chg-ret-sum-units   = 0
        v-chg-ret-sum-money   = 0
        v-spi-sum-units       = 0
        v-spi-sum-money       = 0
        v-RestFrom-units      = 0
        v-restFrom-money      = 0
        v-restEnd-units       = 0
        v-restEnd-money       = 0

      .
    end. /* p-cb-wth-detail = {&wth-wealth-par-detail} */
  end.
  run wthobrxl-write-line-data in this-procedure (  input "ИТОГО:":U
                                                  , input ' ':U
                                                  , input ' ':U
                                                  , input ' ':U
                                                  , input string( v-total-give-sum-units     )
                                                  , input string( v-total-give-sum-money     )
                                                  , input string( v-total-chg-give-sum-units )
                                                  , input string( v-total-chg-give-sum-money )
                                                  , input string( v-total-sell-sum-units     )
                                                  , input string( v-total-sell-sum-money     )
                                                  , input string( v-total-ret-sum-units      )
                                                  , input string( v-total-ret-sum-money      )
                                                  , input string( v-total-chg-ret-sum-units  )
                                                  , input string( v-total-chg-ret-sum-money  )
                                                  , input string( v-total-spi-sum-units      )
                                                  , input string( v-total-spi-sum-money      )
                                                  , input string( v-total-RestFrom-units  )
                                                  , input string( v-total-restFrom-money  )
                                                  , input string( v-total-restEnd-units   )
                                                  , input string( v-total-restEnd-money   )

                                                  ) .
  run wthobrxl-sheet1-write-line-format in this-procedure ( "St" ).
end.

end procedure. /* print-report */