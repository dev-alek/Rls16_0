block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-wrsttl.p $
$Archive: rep/r-wrsttl.p $

Отчет Реестр отоваренных талонов

Автор: Хныкин Павел Андреевич
Дата создания: 05/13/08
Author: Pavel Khnykin
Creation date: 05/13/08

*/
define input  parameter parparentproc       as handle    no-undo .
define input  parameter p-cli-grp-list      as character no-undo .
define input  parameter p-cli-out-type      as integer   no-undo .
define input  parameter p-cli-grp-out-list  as character no-undo .
define input  parameter p-wth-list          as character no-undo .
define input  parameter p-price-detail      as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-wrsttl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-wrsttl.p $":U .
define variable vss-description as character no-undo init "Отчет Реестр отоваренных талонов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ gbl/waitfram.i }
{ trg/factord.i  }
{ gbl/cur-time.i }
{ rep/lkp-font.i }

&scop wrsttl-qnty-fmt @
&scop wrsttl-sum-fmt @
&scop wrsttl-qnty-type "I":u
&scop wrsttl-sum-type "D":u
&scop wrsttl-npp-width 5
&scop wrsttl-wth-width 32
&scop wrsttl-wth-nom-width 10
&scop wrsttl-wth-price-width 10
&scop wrsttl-qnty-width 12
&scop wrsttl-sum-width 12

define stream out-stream.

define temp-table tt-cli-grp no-undo
  field grp-name    as character
  field grp-code    as integer

index pi is primary unique
  grp-code
.

define temp-table tt-cli-grp-clients no-undo like ub.clients.

define temp-table tt-cli-grp-out no-undo
  field grp-name    as character
  field grp-code    as integer
index pi is primary unique
  grp-code
.

define temp-table tt-cli-grp-out-clients no-undo like ub.clients.


define temp-table tt-wealth no-undo like ub.wealth.

define temp-table tt-report no-undo
  field grp-code      as integer   /* группа реализации           */
  field sale-grp-code as integer   /* группа погашения            */
  field wth-code      as integer   /* мц                          */
  field par-code      as integer   /* номинал                     */
  field grp-name      as character /* название группы реализации  */
  field sale-grp-name as character /* название группы погашения   */
  field wth-name      as character /* название мц                 */
  field par-name      as character /* название номинала           */
  field qnty          as decimal   /* количество                  */
  field sum           as decimal   /* сумма                       */

index pi is primary unique
  grp-code
  sale-grp-code
  wth-code
  par-code
index sgc
  sale-grp-code
  wth-code
  par-code
  grp-code
index wpg
  wth-code
  par-code
  grp-code
.

define temp-table tt-report-price no-undo
  field grp-code      as integer   /* группа реализации           */
  field sale-grp-code as integer   /* группа погашения            */
  field wth-code      as integer   /* мц                          */
  field par-code      as integer   /* номинал                     */
  field price-rubl    as decimal   /* цена                        */
  field grp-name      as character /* название группы реализации  */
  field sale-grp-name as character /* название группы погашения   */
  field wth-name      as character /* название мц                 */
  field par-name      as character /* название номинала           */
  field qnty          as decimal   /* количество                  */
  field sum           as decimal   /* сумма                       */
index pi is primary unique
  grp-code
  sale-grp-code
  wth-code
  par-code
  price-rubl
index sgc
  sale-grp-code
  wth-code
  price-rubl
  par-code
  grp-code
index wpg
  wth-code
  par-code
  grp-code
index wg
  wth-code
  par-code
  price-rubl
  grp-code
index price
  price-rubl
.

define variable g#report-num      as integer   no-undo .
define variable v-fo-start        as decimal   no-undo .
define variable v-fo-end          as decimal   no-undo .
define variable v-date-begin      as date      no-undo .
define variable v-date-end        as date      no-undo .
define variable v-host-code     as integer   no-undo .

function to-string returns character (val as decimal, type as character) forward.


/* MAIN */
do
on error undo, return error return-value
:
  run waitfram-show in this-procedure ( "Формирование отчета..." ) .
  run clear-tt in this-procedure .

  /* открываем поток текстового вывода */
  run get-report-num in parparentproc (output g#report-num).
  { cmp/open-out.i stream out-stream " " {&CS_PS} }

  assign
    v-date-begin  = x-Date-Start
    v-date-end    = x-Date-End
  .
  run day-begin-fact-order in this-procedure ( input x-Date-Start , output v-fo-start ) .
  run factord-end-day in this-procedure ( input x-Date-End , output v-fo-end ) .
  run fill-tt-tables in this-procedure .
  run print-report in this-procedure .

  put stream out-stream unformatted " " skip.
  output stream out-stream close.
  {&CloseExcel}
  run clear-tt in this-procedure .
  run waitfram-hide in this-procedure .

  /* выводим на печать */
  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  define variable v-orient-page as character no-undo .
  run How-name in this-procedure (
      input ReportPageHeight,
      input ReportPageWidth,
      output v-orient-page )
      .

  run gbl/prnfilen.w
      (input  ""
      ,input  20
      ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
      ,input  ReportFontNum
      ,output v-user-action
      ,output v-printed
      ) .

end.

/* ---------------------------------------------------------------------------------------- */
procedure clear-tt :

do
on error undo, return error return-value
:
  empty temp-table tt-cli-grp.
  empty temp-table tt-cli-grp-out.
  empty temp-table tt-cli-grp-clients.
  empty temp-table tt-wealth.
  empty temp-table tt-report.
  empty temp-table tt-report-price.
end.

end procedure. /* clear-tt */

/* ---------------------------------------------------------------------------------------- */
procedure fill-tt-tables :

do
on error undo, return error return-value
:
  define buffer buf_wealth                  for ub.wealth .
  define buffer buf_cli-grp                 for ub.cli-grp .
  define buffer buf_clients                 for ub.clients .
  define buffer buf_tt-cli-grp              for tt-cli-grp.
  define buffer buf_tt-cli-grp-out          for tt-cli-grp-out.
  define buffer buf_tt-wealth               for tt-wealth.
  define buffer buf_tt-cli-grp-clients      for tt-cli-grp-clients.
  define buffer buf_tt-cli-grp-out-clients  for tt-cli-grp-out-clients.

  define variable v-i            as integer   no-undo .
  define variable v-host-code-1  as integer   no-undo .
  define variable v-host-code-2  as integer   no-undo .

  do v-i = 1 to num-entries( p-cli-grp-list )
  :
    find first buf_cli-grp no-lock
      where buf_cli-grp.node-code = integer( entry( v-i , p-cli-grp-list ) )
    no-error .
    if available buf_cli-grp
    then do:
      find first buf_tt-cli-grp
        where buf_tt-cli-grp.grp-code = buf_cli-grp.node-code
      no-error .
      if not available buf_tt-cli-grp
      then do:
        create buf_tt-cli-grp.
        assign
          buf_tt-cli-grp.grp-code = buf_cli-grp.node-code
          buf_tt-cli-grp.grp-name = buf_cli-grp.node-name
        .
      end.
      for each buf_clients no-lock
        where buf_clients.grp-code = buf_cli-grp.node-code
      :
        find first buf_tt-cli-grp-clients no-lock
          where buf_tt-cli-grp-clients.obj-type = buf_clients.obj-type
            and buf_tt-cli-grp-clients.obj-code = buf_clients.obj-code
        no-error .
        if not available buf_tt-cli-grp-clients
        then do:
          create buf_tt-cli-grp-clients.
          buffer-copy buf_clients to buf_tt-cli-grp-clients .
        end.
      end.
    end.
  end.

  _cli-grp-out-list:
  do v-i = 1 to num-entries( p-cli-grp-out-list )
  :
    if p-cli-out-type = 3
    then do: /* по АЗС */
      define variable v-obj-type  as character no-undo .
      define variable v-obj-code  as integer   no-undo .
      define variable v-tmp-str   as character no-undo .

      assign
        v-tmp-str = entry( v-i , p-cli-grp-out-list )
      .
      if num-entries( v-tmp-str , ':' ) <> 2
      then do:
        next _cli-grp-out-list.
      end.
      assign
        v-obj-type = entry( 1 , v-tmp-str , ':' )
        v-obj-code = integer( entry( 2 , v-tmp-str , ':' ) )
      .
      find first buf_clients no-lock
        where buf_clients.obj-type = v-obj-type
          and buf_clients.obj-code = v-obj-code
      no-error .
      if available buf_clients
      then do:
        find first buf_tt-cli-grp-out
          where buf_tt-cli-grp-out.grp-code = buf_clients.grp-code
        no-error .
        if not available buf_tt-cli-grp-out
        then do:
          find first buf_cli-grp no-lock
            where buf_cli-grp.node-code = buf_clients.grp-code
          no-error .
          if available buf_cli-grp
          then do:
            create buf_tt-cli-grp-out.
            assign
              buf_tt-cli-grp-out.grp-code = buf_cli-grp.node-code
              buf_tt-cli-grp-out.grp-name = buf_cli-grp.node-name
            .
          end. /* if available buf_cli-grp */
        end. /* if not available buf_tt-cli-grp-out */

        find first buf_tt-cli-grp-out-clients no-lock
          where buf_tt-cli-grp-out-clients.obj-type = buf_clients.obj-type
            and buf_tt-cli-grp-out-clients.obj-code = buf_clients.obj-code
        no-error .
        if not available buf_tt-cli-grp-out-clients
        then do:
          create buf_tt-cli-grp-out-clients.
          buffer-copy buf_clients to buf_tt-cli-grp-out-clients
          assign
            buf_tt-cli-grp-out-clients.grp-code = buf_tt-cli-grp-out.grp-code
            buf_tt-cli-grp-out-clients.grp-name = buf_tt-cli-grp-out.grp-name
          .
        end.
      end. /* if available buf_clients */

    end.
    else do: /* по нефтебазам */
      find first buf_cli-grp no-lock
        where buf_cli-grp.node-code = integer( entry( v-i , p-cli-grp-out-list ) )
      no-error .
      if available buf_cli-grp
      then do:
        find first buf_tt-cli-grp-out
          where buf_tt-cli-grp-out.grp-code = buf_cli-grp.node-code
        no-error .
        if not available buf_tt-cli-grp-out
        then do:
          create buf_tt-cli-grp-out.
          assign
            buf_tt-cli-grp-out.grp-code = buf_cli-grp.node-code
            buf_tt-cli-grp-out.grp-name = buf_cli-grp.node-name
          .
        end.
        for each buf_clients no-lock
          where buf_clients.grp-code = buf_cli-grp.node-code
            and buf_clients.obj-type = {&shop}
        :
          find first buf_tt-cli-grp-out-clients no-lock
            where buf_tt-cli-grp-out-clients.obj-type = buf_clients.obj-type
              and buf_tt-cli-grp-out-clients.obj-code = buf_clients.obj-code
          no-error .
          if not available buf_tt-cli-grp-out-clients
          then do:
            create buf_tt-cli-grp-out-clients.
            buffer-copy buf_clients to buf_tt-cli-grp-out-clients
            assign
              buf_tt-cli-grp-out-clients.grp-code = buf_tt-cli-grp-out.grp-code
              buf_tt-cli-grp-out-clients.grp-name = buf_tt-cli-grp-out.grp-name
            .
          end.
        end.
      end.
    end.
  end.

  do v-i = 1 to num-entries( p-wth-list )
  :
    find first buf_wealth no-lock
      where buf_wealth.wth-code = integer( entry( v-i , p-wth-list ) )
    no-error .
    if available buf_wealth
    then do:
      find first buf_tt-wealth
        where buf_tt-wealth.wth-code = buf_wealth.wth-code
      no-error .
      if not available buf_tt-wealth
      then do:
        buffer-copy buf_wealth to buf_tt-wealth.
      end.
    end.
  end.

  if p-price-detail = yes
  then do:
    run fill-tt-tables-with-price in this-procedure .
  end.
  else do:
    run fill-tt-tables-no-price in this-procedure .
  end.

end.

end procedure. /* fill-tt-tables */


/* ---------------------------------------------------------------------------------------- */
procedure fill-tt-tables-no-price :
  define buffer buf_wealth                  for ub.wealth .
  define buffer buf_wth-doc                 for ub.wth-doc.
  define buffer buf_wth-par                 for ub.wth-par .
  define buffer buf_wth-parts               for ub.wth-parts .
  define buffer buf_clients                 for ub.clients .
  define buffer buf_tt-cli-grp              for tt-cli-grp.
  define buffer buf_tt-cli-grp-out          for tt-cli-grp-out.
  define buffer buf_tt-wealth               for tt-wealth.
  define buffer buf_tt-cli-grp-clients      for tt-cli-grp-clients.
  define buffer buf_tt-cli-grp-out-clients  for tt-cli-grp-out-clients.
  define buffer buf_tt-report               for tt-report.

do
on error undo, return error return-value
:

  /* создаем матрицу отчета */
  for each buf_tt-cli-grp-out ,
      each buf_tt-cli-grp ,
      each buf_tt-wealth ,
      each buf_wth-par no-lock
        where buf_wth-par.wth-code = buf_tt-wealth.wth-code
  :
    find first buf_tt-report
      where buf_tt-report.grp-code      = buf_tt-cli-grp.grp-code
        and buf_tt-report.sale-grp-code = buf_tt-cli-grp-out.grp-code
        and buf_tt-report.wth-code      = buf_tt-wealth.wth-code
        and buf_tt-report.par-code      = buf_wth-par.par-code
    no-error .
    if not available buf_tt-report
    then do:
      create buf_tt-report.
      assign
        buf_tt-report.grp-code      = buf_tt-cli-grp.grp-code
        buf_tt-report.sale-grp-code = buf_tt-cli-grp-out.grp-code
        buf_tt-report.wth-code      = buf_tt-wealth.wth-code
        buf_tt-report.par-code      = buf_wth-par.par-code
        buf_tt-report.grp-name      = buf_tt-cli-grp.grp-name
        buf_tt-report.sale-grp-name = buf_tt-cli-grp-out.grp-name
        buf_tt-report.wth-name      = buf_tt-wealth.wth-name
        buf_tt-report.par-name      = substitute( "&1 &2" , buf_wth-par.par-val , buf_wth-par.par-unit )
      .
    end.
  end.

  for each buf_tt-cli-grp-out-clients
  :
    { gbl/hostcode.i
      buf_tt-cli-grp-out-clients.obj-type
      buf_tt-cli-grp-out-clients.obj-code
      v-host-code
    }

    for each buf_wth-doc no-lock
      where buf_wth-doc.host-code     = v-host-code
        and buf_wth-doc.obj-type      = buf_tt-cli-grp-out-clients.obj-type
        and buf_wth-doc.obj-code      = buf_tt-cli-grp-out-clients.obj-code
        and buf_wth-doc.status_       = {&fact}
        and buf_wth-doc.fact-order   >= v-fo-start
        and buf_wth-doc.fact-order   <= v-fo-end
        and buf_wth-doc.ext-doc-type  = {&WDEDT_Put_Cash}
    :
      for each buf_tt-wealth ,
          each buf_wth-par no-lock
            where buf_wth-par.wth-code = buf_tt-wealth.wth-code
      :
        for each buf_wth-parts no-lock
          where buf_wth-parts.out-code  = buf_wth-doc.doc-code
            and buf_wth-parts.obj-type  = buf_wth-doc.obj-type
            and buf_wth-parts.obj-code  = buf_wth-doc.obj-code
            and buf_wth-parts.wth-code  = buf_tt-wealth.wth-code
            and buf_wth-parts.par-code  = buf_wth-par.par-code
        :
          /* объект из группы реализации талонов? */
          find first buf_tt-cli-grp-clients
            where buf_tt-cli-grp-clients.obj-type = buf_wth-parts.sale-obj-type
              and buf_tt-cli-grp-clients.obj-code = buf_wth-parts.sale-obj-code
          no-error .
          if available buf_tt-cli-grp-clients
          then do:
            find first buf_tt-report
              where buf_tt-report.grp-code      = buf_tt-cli-grp-clients.grp-code
                and buf_tt-report.sale-grp-code = buf_tt-cli-grp-out-clients.grp-code
                and buf_tt-report.wth-code      = buf_wth-parts.wth-code
                and buf_tt-report.par-code      = buf_wth-parts.par-code
            no-error .
            if not available buf_tt-report
            then do:
              find first buf_tt-cli-grp
                where buf_tt-cli-grp.grp-code = buf_tt-cli-grp-clients.grp-code
              no-error .
              if available buf_tt-cli-grp
              then do:
                create buf_tt-report.
                assign
                  buf_tt-report.grp-code      = buf_tt-cli-grp.grp-code
                  buf_tt-report.sale-grp-code = buf_tt-cli-grp-out-clients.grp-code
                  buf_tt-report.wth-code      = buf_wth-parts.wth-code
                  buf_tt-report.par-code      = buf_wth-parts.par-code
                  buf_tt-report.grp-name      = buf_tt-cli-grp.grp-name
                  buf_tt-report.sale-grp-name = buf_tt-cli-grp-out-clients.grp-name
                  buf_tt-report.wth-name      = buf_tt-wealth.wth-name
                  buf_tt-report.par-name      = substitute( "&1 &2" , buf_wth-par.par-val , buf_wth-par.par-unit )
                .
              end. /* if available buf_tt-cli-grp  */
            end. /* if not available buf_tt-report */
            assign
              buf_tt-report.qnty = buf_tt-report.qnty + ( buf_wth-parts.fact-qnty * buf_wth-par.par-val )
              buf_tt-report.sum  = buf_tt-report.sum  + (buf_wth-parts.price-rubl *  buf_wth-parts.fact-qnty)
            .
          end. /* if available buf_tt-cli-grp-out-clients */
        end. /* for each buf_wth-parts no-lock  */
      end. /* for each buf_tt-wealth , */
    end. /* for each buf_wth-doc no-lock  */

    for each buf_wth-doc no-lock
      where buf_wth-doc.host-code     = v-host-code
        and buf_wth-doc.cli-type      = buf_tt-cli-grp-out-clients.obj-type
        and buf_wth-doc.cli-code      = buf_tt-cli-grp-out-clients.obj-code
        and buf_wth-doc.status_       = {&fact}
        and buf_wth-doc.fact-order   >= v-fo-start
        and buf_wth-doc.fact-order   <= v-fo-end
        and buf_wth-doc.ext-doc-type  = {&WDEDT_Put_Sale}
    :
      for each buf_tt-wealth ,
          each buf_wth-par no-lock
            where buf_wth-par.wth-code = buf_tt-wealth.wth-code
      :
        for each buf_wth-parts no-lock
          where buf_wth-parts.out-code  = buf_wth-doc.doc-code
            and buf_wth-parts.obj-type  = buf_wth-doc.obj-type
            and buf_wth-parts.obj-code  = buf_wth-doc.obj-code
            and buf_wth-parts.wth-code  = buf_tt-wealth.wth-code
            and buf_wth-parts.par-code  = buf_wth-par.par-code
        :
          /* объект из группы реализации талонов? */
          find first buf_tt-cli-grp-clients
            where buf_tt-cli-grp-clients.obj-type = buf_wth-parts.sale-obj-type
              and buf_tt-cli-grp-clients.obj-code = buf_wth-parts.sale-obj-code
          no-error .
          if available buf_tt-cli-grp-clients
          then do:
            find first buf_tt-report
              where buf_tt-report.grp-code      = buf_tt-cli-grp-clients.grp-code
                and buf_tt-report.sale-grp-code = buf_tt-cli-grp-out-clients.grp-code
                and buf_tt-report.wth-code      = buf_wth-parts.wth-code
                and buf_tt-report.par-code      = buf_wth-parts.par-code
            no-error .
            if not available buf_tt-report
            then do:
              find first buf_tt-cli-grp
                where buf_tt-cli-grp.grp-code = buf_tt-cli-grp-clients.grp-code
              no-error .
              if available buf_tt-cli-grp
              then do:
                create buf_tt-report.
                assign
                  buf_tt-report.grp-code      = buf_tt-cli-grp.grp-code
                  buf_tt-report.sale-grp-code = buf_tt-cli-grp-out-clients.grp-code
                  buf_tt-report.wth-code      = buf_wth-parts.wth-code
                  buf_tt-report.par-code      = buf_wth-parts.par-code
                  buf_tt-report.grp-name      = buf_tt-cli-grp.grp-name
                  buf_tt-report.sale-grp-name = buf_tt-cli-grp-out-clients.grp-name
                  buf_tt-report.wth-name      = buf_tt-wealth.wth-name
                  buf_tt-report.par-name      = substitute( "&1 &2" , buf_wth-par.par-val , buf_wth-par.par-unit )
                .
              end. /* if available buf_tt-cli-grp  */
            end. /* if not available buf_tt-report */
            assign
              buf_tt-report.qnty = buf_tt-report.qnty + ( buf_wth-parts.fact-qnty * buf_wth-par.par-val )
              buf_tt-report.sum  = buf_tt-report.sum  + (buf_wth-parts.price-rubl *  buf_wth-parts.fact-qnty)
            .
          end. /* if available buf_tt-cli-grp-out-clients */
        end. /* for each buf_wth-parts no-lock  */
      end. /* for each buf_tt-wealth , */
    end. /* for each buf_wth-doc no-lock  */
  end. /* for each buf_tt-cli-grp-out  */
end.


end procedure. /* fill-tt-tables-no-price */


/* ---------------------------------------------------------------------------------------- */
procedure fill-tt-tables-with-price :
  define buffer buf_wealth                  for ub.wealth .
  define buffer buf_wth-doc                 for ub.wth-doc.
  define buffer buf_wth-par                 for ub.wth-par .
  define buffer buf_wth-parts               for ub.wth-parts .
  define buffer buf_clients                 for ub.clients .
  define buffer buf_tt-cli-grp              for tt-cli-grp.
  define buffer buf_tt-cli-grp-out          for tt-cli-grp-out.
  define buffer buf_tt-wealth               for tt-wealth.
  define buffer buf_tt-cli-grp-clients      for tt-cli-grp-clients.
  define buffer buf_tt-cli-grp-out-clients  for tt-cli-grp-out-clients.
  define buffer buf_tt-report-price         for tt-report-price.
  define buffer new_tt-report-price         for tt-report-price.
  define buffer sch_tt-report-price         for tt-report-price.

  define variable v-price-rubl   as decimal   no-undo .
do
on error undo, return error return-value
:

  /* создаем матрицу отчета */
  for each buf_tt-cli-grp-out ,
      each buf_tt-cli-grp ,
      each buf_tt-wealth ,
      each buf_wth-par no-lock
        where buf_wth-par.wth-code = buf_tt-wealth.wth-code
  :
    find first buf_tt-report-price
      where buf_tt-report-price.grp-code      = buf_tt-cli-grp.grp-code
        and buf_tt-report-price.sale-grp-code = buf_tt-cli-grp-out.grp-code
        and buf_tt-report-price.wth-code      = buf_tt-wealth.wth-code
        and buf_tt-report-price.par-code      = buf_wth-par.par-code
    no-error .
    if not available buf_tt-report-price
    then do:
      create buf_tt-report-price.
      assign
        buf_tt-report-price.grp-code      = buf_tt-cli-grp.grp-code
        buf_tt-report-price.sale-grp-code = buf_tt-cli-grp-out.grp-code
        buf_tt-report-price.wth-code      = buf_tt-wealth.wth-code
        buf_tt-report-price.par-code      = buf_wth-par.par-code
        buf_tt-report-price.grp-name      = buf_tt-cli-grp.grp-name
        buf_tt-report-price.sale-grp-name = buf_tt-cli-grp-out.grp-name
        buf_tt-report-price.wth-name      = buf_tt-wealth.wth-name
        buf_tt-report-price.par-name      = substitute( "&1 &2" , buf_wth-par.par-val , buf_wth-par.par-unit )
      .
    end.
  end.


  for each buf_tt-cli-grp-out-clients
  :
    { gbl/hostcode.i
      buf_tt-cli-grp-out-clients.obj-type
      buf_tt-cli-grp-out-clients.obj-code
      v-host-code
    }

    for each buf_wth-doc no-lock
      where buf_wth-doc.host-code     = v-host-code
        and buf_wth-doc.obj-type      = buf_tt-cli-grp-out-clients.obj-type
        and buf_wth-doc.obj-code      = buf_tt-cli-grp-out-clients.obj-code
        and buf_wth-doc.status_       = {&fact}
        and buf_wth-doc.fact-order   >= v-fo-start
        and buf_wth-doc.fact-order   <= v-fo-end
        and buf_wth-doc.ext-doc-type  = {&WDEDT_Put_Cash}
    :
      for each buf_tt-wealth ,
          each buf_wth-par no-lock
            where buf_wth-par.wth-code = buf_tt-wealth.wth-code
      :
        for each buf_wth-parts no-lock
          where buf_wth-parts.out-code  = buf_wth-doc.doc-code
            and buf_wth-parts.obj-type  = buf_wth-doc.obj-type
            and buf_wth-parts.obj-code  = buf_wth-doc.obj-code
            and buf_wth-parts.wth-code  = buf_tt-wealth.wth-code
            and buf_wth-parts.par-code  = buf_wth-par.par-code
        :
          /* объект из группы реализации талонов? */
          find first buf_tt-cli-grp-clients
            where buf_tt-cli-grp-clients.obj-type = buf_wth-parts.sale-obj-type
              and buf_tt-cli-grp-clients.obj-code = buf_wth-parts.sale-obj-code
          no-error .
          if available buf_tt-cli-grp-clients
          then do:
            assign
              v-price-rubl = buf_wth-parts.price-rubl / buf_wth-par.par-val
            .
            find first buf_tt-report-price
              where buf_tt-report-price.grp-code      = buf_tt-cli-grp-clients.grp-code
                and buf_tt-report-price.sale-grp-code = buf_tt-cli-grp-out-clients.grp-code
                and buf_tt-report-price.wth-code      = buf_wth-parts.wth-code
                and buf_tt-report-price.par-code      = buf_wth-parts.par-code
                and buf_tt-report-price.price-rubl    = v-price-rubl
            no-error .
            if not available buf_tt-report-price
            then do:
              find first buf_tt-cli-grp
                where buf_tt-cli-grp.grp-code = buf_tt-cli-grp-clients.grp-code
              no-error .
              if available buf_tt-cli-grp
              then do:
                create buf_tt-report-price.
                assign
                  buf_tt-report-price.grp-code      = buf_tt-cli-grp.grp-code
                  buf_tt-report-price.sale-grp-code = buf_tt-cli-grp-out-clients.grp-code
                  buf_tt-report-price.wth-code      = buf_wth-parts.wth-code
                  buf_tt-report-price.par-code      = buf_wth-parts.par-code
                  buf_tt-report-price.price-rubl    = v-price-rubl
                  buf_tt-report-price.grp-name      = buf_tt-cli-grp.grp-name
                  buf_tt-report-price.sale-grp-name = buf_tt-cli-grp-out-clients.grp-name
                  buf_tt-report-price.wth-name      = buf_tt-wealth.wth-name
                  buf_tt-report-price.par-name      = substitute( "&1 &2" , buf_wth-par.par-val , buf_wth-par.par-unit )
                .
              end. /* if available buf_tt-cli-grp  */
            end. /* if not available buf_tt-report-price */
            assign
              buf_tt-report-price.qnty = buf_tt-report-price.qnty + ( buf_wth-parts.fact-qnty * buf_wth-par.par-val )
              buf_tt-report-price.sum  = buf_tt-report-price.sum  + (buf_wth-parts.price-rubl *  buf_wth-parts.fact-qnty)
            .
          end. /* if available buf_tt-cli-grp-out-clients */
        end. /* for each buf_wth-parts no-lock  */
      end. /* for each buf_tt-wealth , */
    end. /* for each buf_wth-doc no-lock  */

    for each buf_wth-doc no-lock
      where buf_wth-doc.host-code     = v-host-code
        and buf_wth-doc.cli-type      = buf_tt-cli-grp-out-clients.obj-type
        and buf_wth-doc.cli-code      = buf_tt-cli-grp-out-clients.obj-code
        and buf_wth-doc.status_       = {&fact}
        and buf_wth-doc.fact-order   >= v-fo-start
        and buf_wth-doc.fact-order   <= v-fo-end
        and buf_wth-doc.ext-doc-type  = {&WDEDT_Put_Sale}
    :
      for each buf_tt-wealth ,
          each buf_wth-par no-lock
            where buf_wth-par.wth-code = buf_tt-wealth.wth-code
      :
        for each buf_wth-parts no-lock
          where buf_wth-parts.out-code  = buf_wth-doc.doc-code
            and buf_wth-parts.obj-type  = buf_wth-doc.obj-type
            and buf_wth-parts.obj-code  = buf_wth-doc.obj-code
            and buf_wth-parts.wth-code  = buf_tt-wealth.wth-code
            and buf_wth-parts.par-code  = buf_wth-par.par-code
        :
          /* объект из группы реализации талонов? */
          find first buf_tt-cli-grp-clients
            where buf_tt-cli-grp-clients.obj-type = buf_wth-parts.sale-obj-type
              and buf_tt-cli-grp-clients.obj-code = buf_wth-parts.sale-obj-code
          no-error .
          if available buf_tt-cli-grp-clients
          then do:
            assign
              v-price-rubl = buf_wth-parts.price-rubl / buf_wth-par.par-val
            .
            find first buf_tt-report-price
              where buf_tt-report-price.grp-code      = buf_tt-cli-grp-clients.grp-code
                and buf_tt-report-price.sale-grp-code = buf_tt-cli-grp-out-clients.grp-code
                and buf_tt-report-price.wth-code      = buf_wth-parts.wth-code
                and buf_tt-report-price.par-code      = buf_wth-parts.par-code
                and buf_tt-report-price.price-rubl    = v-price-rubl
            no-error .
            if not available buf_tt-report-price
            then do:
              find first buf_tt-cli-grp
                where buf_tt-cli-grp.grp-code = buf_tt-cli-grp-clients.grp-code
              no-error .
              if available buf_tt-cli-grp
              then do:
                create buf_tt-report-price.
                assign
                  buf_tt-report-price.grp-code      = buf_tt-cli-grp.grp-code
                  buf_tt-report-price.sale-grp-code = buf_tt-cli-grp-out-clients.grp-code
                  buf_tt-report-price.wth-code      = buf_wth-parts.wth-code
                  buf_tt-report-price.par-code      = buf_wth-parts.par-code
                  buf_tt-report-price.price-rubl    = v-price-rubl
                  buf_tt-report-price.grp-name      = buf_tt-cli-grp.grp-name
                  buf_tt-report-price.sale-grp-name = buf_tt-cli-grp-out-clients.grp-name
                  buf_tt-report-price.wth-name      = buf_tt-wealth.wth-name
                  buf_tt-report-price.par-name      = substitute( "&1 &2" , buf_wth-par.par-val , buf_wth-par.par-unit )
                .
              end. /* if available buf_tt-cli-grp  */
            end. /* if not available buf_tt-report-price */
            assign
              buf_tt-report-price.qnty = buf_tt-report-price.qnty + ( buf_wth-parts.fact-qnty * buf_wth-par.par-val )
              buf_tt-report-price.sum  = buf_tt-report-price.sum  + (buf_wth-parts.price-rubl *  buf_wth-parts.fact-qnty)
            .
          end. /* if available buf_tt-cli-grp-out-clients */
        end. /* for each buf_wth-parts no-lock  */
      end. /* for each buf_tt-wealth , */
    end. /* for each buf_wth-doc no-lock  */
  end. /* for each buf_tt-cli-grp-out  */

  /*дополняем по цене */
  for each buf_tt-report-price
  :
    for each sch_tt-report-price
      where sch_tt-report-price.sale-grp-code = buf_tt-report-price.sale-grp-code
        and sch_tt-report-price.wth-code      = buf_tt-report-price.wth-code
        and sch_tt-report-price.par-code      = buf_tt-report-price.par-code
    :
      find first new_tt-report-price
        where new_tt-report-price.grp-code      = sch_tt-report-price.grp-code
          and new_tt-report-price.sale-grp-code = buf_tt-report-price.sale-grp-code
          and new_tt-report-price.wth-code      = buf_tt-report-price.wth-code
          and new_tt-report-price.par-code      = buf_tt-report-price.par-code
          and new_tt-report-price.price-rubl    = buf_tt-report-price.price-rubl
      no-error .
      if not available new_tt-report-price
      then do:
        create new_tt-report-price.
        assign
          new_tt-report-price.grp-code      = sch_tt-report-price.grp-code
          new_tt-report-price.sale-grp-code = buf_tt-report-price.sale-grp-code
          new_tt-report-price.wth-code      = buf_tt-report-price.wth-code
          new_tt-report-price.par-code      = buf_tt-report-price.par-code
          new_tt-report-price.price-rubl    = buf_tt-report-price.price-rubl
          new_tt-report-price.grp-name      = buf_tt-report-price.grp-name
          new_tt-report-price.sale-grp-name = buf_tt-report-price.sale-grp-name
          new_tt-report-price.wth-name      = buf_tt-report-price.wth-name
          new_tt-report-price.par-name      = buf_tt-report-price.par-name
        .
      end.
    end.
  end.

  /* отрезаем строки с нулевой ценой при наличии ненулевой */
  for each buf_tt-report-price
    where buf_tt-report-price.price-rubl = 0
  :
    find first sch_tt-report-price
      where sch_tt-report-price.sale-grp-code = buf_tt-report-price.sale-grp-code
        and sch_tt-report-price.wth-code      = buf_tt-report-price.wth-code
        and sch_tt-report-price.par-code      = buf_tt-report-price.par-code
        and sch_tt-report-price.price-rubl    > 0
    no-error .
    if available sch_tt-report-price
    then do:
      delete buf_tt-report-price.
    end.
  end.

end.

end procedure. /* fill-tt-tables-with-price */


/* ---------------------------------------------------------------------------------------- */
procedure print-report :

do
on error undo, return error return-value
:
  if p-price-detail = yes
  then do:
    run print-report-with-price in this-procedure .
  end.
  else do:
    run print-report-no-price in this-procedure .
  end.
end.

end procedure. /* print-report */


/* ---------------------------------------------------------------------------------------- */
procedure print-report-with-price :
  define buffer buf_tt-report-price               for tt-report-price.
  define buffer buf_wth-par                 for ub.wth-par .
  define buffer buf_tt-cli-grp              for tt-cli-grp.
  define buffer buf_tt-wealth               for tt-wealth.

  define variable v-i               as integer   no-undo .
  define variable v-line-1          as character no-undo .
  define variable v-clmn-label-1    as character no-undo .
  define variable v-clmn-label-2    as character no-undo .
  define variable v-clmn-label-3    as character no-undo .
  define variable v-clmn-format     as character no-undo .
  define variable v-clmn-sizes      as character no-undo .
  define variable v-row-count       as integer   no-undo .
  define variable v-tot-qnty        as decimal   no-undo .
  define variable v-tot-sum         as decimal   no-undo .
  define variable v-all-qnty        as decimal   no-undo .
  define variable v-all-sum         as decimal   no-undo .

  define variable v-price-qnty      as decimal   no-undo .
  define variable v-price-sum       as decimal   no-undo .
  define variable v-wth-qnty        as decimal   no-undo .
  define variable v-wth-sum         as decimal   no-undo .

do
on error undo, return error return-value
:

  assign
    v-clmn-label-3 = "1" + {&comma-char} + "2" + {&comma-char} + "3" + {&comma-char} + "4" + {&comma-char}
    v-i = 5
  .

  /* форматируем отчет по объектам реализации талонов */
  for each tt-cli-grp
    by tt-cli-grp.grp-code
  :
    assign
      v-clmn-label-1 = v-clmn-label-1 + tt-cli-grp.grp-name + {&comma-char} + {&comma-char}
      v-clmn-label-2 = v-clmn-label-2 + "Кол-во" + {&comma-char} + "Сумма" + {&comma-char}
      v-clmn-label-3 = v-clmn-label-3 + string(v-i) + {&comma-char} + string(v-i + 1) + {&comma-char}
      v-clmn-format  = v-clmn-format  + substitute("&1={&wrsttl-qnty-fmt};&2={&wrsttl-sum-fmt}", v-i , (v-i + 1) )
      v-clmn-sizes   = v-clmn-sizes   + "{&wrsttl-qnty-width}" + {&comma-char} + "{&wrsttl-sum-width}" + {&comma-char}
      v-line-1       = v-line-1       + substitute("&1:&2,", v-i ,  (v-i + 1) )
      v-i            = v-i + 2
    .
  end.

  /* столбец итого */
  assign
    v-clmn-label-2 = v-clmn-label-2 + "Кол-во" + {&comma-char} + "Сумма" + {&comma-char}
    v-clmn-label-3 = v-clmn-label-3 + string(v-i) + {&comma-char} + string(v-i + 1) + {&comma-char}
    v-clmn-format  = v-clmn-format  + substitute("&1={&wrsttl-qnty-fmt};&2={&wrsttl-sum-fmt}", v-i , (v-i + 1) )
    v-clmn-sizes   = v-clmn-sizes   + "{&wrsttl-qnty-width}" + {&comma-char} + "{&wrsttl-sum-width}" + {&comma-char}
    v-line-1       = v-line-1       + substitute("&1:&2,", v-i ,  (v-i + 1) )
  .

  /* обрезаем лишние знаки */
  assign
    v-clmn-label-3  = trim(v-clmn-label-3 , {&comma-char} )
    v-clmn-format   = trim(v-clmn-format , ";")
    v-clmn-sizes    = trim(v-clmn-sizes  , {&comma-char} )
    v-line-1        = trim(v-line-1 , ",")
  .
  assign
    sheetf.sheet-num          = 1
    sheetf.MergeCellsH        = v-line-1
    sheetf.MergeCellsV        = "1=1:2/2=1:2/3=1:2"
    sheetf.Excel-Column-Lable = "№ п/п"  + {&comma-char} + "Наименование" + {&comma-char} + "Номинал" + {&comma-char} + "Цена" + {&comma-char} + v-clmn-label-1 + "Итого" + {&comma-char} + {&comma-char}
                                + {&new-line}
                                         + {&comma-char}                  + {&comma-char}             + {&comma-char}          + {&comma-char} + v-clmn-label-2
                                + {&new-line}
                                                                                                                                               + v-clmn-label-3
    sheetf.colformat          = "1=@;2=@;3=@;4=@;" + v-clmn-format
    sheetf.Sizes              = "{&wrsttl-npp-width}" + {&comma-char} + "{&wrsttl-wth-width}" + {&comma-char} + "{&wrsttl-wth-nom-width}" + {&comma-char} + "{&wrsttl-wth-price-width}" + {&comma-char}
                                + v-clmn-sizes
  .
  run rep/extitle.p (1).



  assign
    v-row-count = 1
  .

  for each tt-report-price
      break by tt-report-price.sale-grp-code
            by tt-report-price.wth-code
            by tt-report-price.price-rubl descending
            by tt-report-price.par-code
            by tt-report-price.grp-code
  :
    if first-of(tt-report-price.sale-grp-code)
    then do:
      {&PutExcel}
        " "                     {&tabulation}
        tt-report-price.sale-grp-name {&tabulation}
        " "                     {&tabulation}
      .
      for each tt-cli-grp
      :
        {&PutExcel}
          " "                     {&tabulation}
          " "                     {&tabulation}
        .
      end.
      {&PutExcel} skip.
    end.
    if first-of(tt-report-price.wth-code) or first-of(tt-report-price.par-code) or first-of(tt-report-price.price-rubl)
    then do:
      {&PutExcel}
        string(v-row-count, ">9")             {&tabulation}
        tt-report-price.wth-name              {&tabulation}
        tt-report-price.par-name              {&tabulation}
        to-string(tt-report-price.price-rubl,{&wrsttl-sum-type}) {&tabulation}
      .
      assign
        v-row-count = v-row-count + 1
      .
    end.
    {&PutExcel}
      to-string(tt-report-price.qnty,{&wrsttl-qnty-type}) {&tabulation}
      to-string(tt-report-price.sum,{&wrsttl-sum-type}) {&tabulation}
    .
    if last-of(tt-report-price.par-code) or last-of(tt-report-price.wth-code) or last-of(tt-report-price.price-rubl)
    then do:
      /* собираем итого по МЦ + номинал */
      assign
        v-tot-qnty = 0
        v-tot-sum  = 0
      .
      for each buf_tt-report-price
        where buf_tt-report-price.sale-grp-code = tt-report-price.sale-grp-code
          and buf_tt-report-price.wth-code      = tt-report-price.wth-code
          and buf_tt-report-price.price-rubl    = tt-report-price.price-rubl
          and buf_tt-report-price.par-code      = tt-report-price.par-code
      :
        assign
          v-tot-qnty = v-tot-qnty + buf_tt-report-price.qnty
          v-tot-sum  = v-tot-sum  + buf_tt-report-price.sum
        .
      end.

      {&PutExcel}
        to-string(v-tot-qnty,{&wrsttl-qnty-type}) {&tabulation}
        to-string(v-tot-sum,{&wrsttl-sum-type})  {&tabulation}
      skip.
    end.

    if last-of(tt-report-price.price-rubl)
    then do: /* итого по ценам */
      {&PutExcel}
        " "               {&tabulation}
        "Итого по ценам"  {&tabulation}
        " "               {&tabulation}
        " "               {&tabulation}
      .
      for each buf_tt-report-price
        where buf_tt-report-price.sale-grp-code = tt-report-price.sale-grp-code
          and buf_tt-report-price.wth-code      = tt-report-price.wth-code
          and buf_tt-report-price.price-rubl    = tt-report-price.price-rubl
      break by buf_tt-report-price.grp-code
      :
        assign
          v-price-qnty = v-price-qnty + buf_tt-report-price.qnty
          v-price-sum  = v-price-sum  + buf_tt-report-price.sum
        .
        if last-of(buf_tt-report-price.grp-code)
        then do:
          {&PutExcel}
            to-string(v-price-qnty,{&wrsttl-qnty-type}) {&tabulation}
            to-string(v-price-sum,{&wrsttl-sum-type})  {&tabulation}
          .
          assign
            v-price-qnty = 0
            v-price-sum  = 0
          .
        end.
      end.
      {&PutExcel}
      skip.
    end.

    if last-of(tt-report-price.wth-code)
    then do: /* итого по виду топлива */
      {&PutExcel}
        " "                                                     {&tabulation}
        substitute( "Итого по &1 " , tt-report-price.wth-name)  {&tabulation}
        " "                                                     {&tabulation}
        " "                                                     {&tabulation}
      .
      for each buf_tt-report-price
        where buf_tt-report-price.sale-grp-code = tt-report-price.sale-grp-code
          and buf_tt-report-price.wth-code      = tt-report-price.wth-code
      break by buf_tt-report-price.grp-code
      :
        assign
          v-wth-qnty = v-wth-qnty + buf_tt-report-price.qnty
          v-wth-sum  = v-wth-sum  + buf_tt-report-price.sum
        .
        if last-of(buf_tt-report-price.grp-code)
        then do:
          {&PutExcel}
            to-string(v-wth-qnty,{&wrsttl-qnty-type}) {&tabulation}
            to-string(v-wth-sum,{&wrsttl-sum-type})  {&tabulation}
          .
          assign
            v-wth-qnty = 0
            v-wth-sum  = 0
          .
        end.
      end.
      {&PutExcel}
      skip.
    end.

    if last-of(tt-report-price.sale-grp-code)
    then do:
      /* собираем итого по группе погашения */
      {&PutExcel}
        " "     {&tabulation}
        "Итого" {&tabulation}
        " "     {&tabulation}
        " "     {&tabulation}
      .
      /* итого по объекту погашения */
      assign
        v-tot-qnty = 0
        v-tot-sum  = 0
      .
      for each buf_tt-report-price
        where buf_tt-report-price.sale-grp-code = tt-report-price.sale-grp-code
          break by buf_tt-report-price.grp-code
      :
        assign
          v-tot-qnty = v-tot-qnty + buf_tt-report-price.qnty
          v-tot-sum  = v-tot-sum  + buf_tt-report-price.sum
        .
        if last-of(buf_tt-report-price.grp-code)
        then do:
          {&PutExcel}
            to-string(v-tot-qnty,{&wrsttl-qnty-type}) {&tabulation}
            to-string(v-tot-sum,{&wrsttl-sum-type}) {&tabulation}
          .
          assign
            v-tot-qnty = 0
            v-tot-sum  = 0
          .
        end.
      end.
      {&PutExcel} skip.
      assign
        v-row-count = 1
      .
    end.
  end.

  /* выводим ВСЕГО */
  {&PutExcel}
    " "             {&tabulation}
    "Итого по МЦ:"  {&tabulation}
    " "             {&tabulation}
  skip.

  assign
    v-row-count   = 1
    v-tot-qnty    = 0
    v-tot-sum     = 0
    v-price-qnty  = 0
    v-price-sum   = 0
    v-wth-qnty    = 0
    v-wth-sum     = 0
  .

  for each tt-report-price
    break by tt-report-price.wth-code
          by tt-report-price.price-rubl descending
          by tt-report-price.par-code
          by tt-report-price.grp-code
  :
    if first-of(tt-report-price.wth-code) or first-of(tt-report-price.par-code) or first-of(tt-report-price.price-rubl)
    then do:
      {&PutExcel}
        string(v-row-count, ">9")       {&tabulation}
        tt-report-price.wth-name        {&tabulation}
        tt-report-price.par-name        {&tabulation}
        to-string(tt-report-price.price-rubl,{&wrsttl-sum-type}) {&tabulation}
/*        " "                             {&tabulation}*/
      .
      assign
        v-row-count = v-row-count + 1
        v-tot-qnty  = 0
        v-tot-sum   = 0
      .
    end.

    assign
      v-tot-qnty = v-tot-qnty + tt-report-price.qnty
      v-tot-sum  = v-tot-sum  + tt-report-price.sum
    .
    if last-of(tt-report-price.grp-code)
    then do:
      {&PutExcel}
        to-string(v-tot-qnty,{&wrsttl-qnty-type}) {&tabulation}
        to-string(v-tot-sum,{&wrsttl-sum-type})   {&tabulation}
      .
      assign
        v-tot-qnty  = 0
        v-tot-sum   = 0
      .
    end.

    if last-of(tt-report-price.wth-code) or last-of(tt-report-price.par-code)
    then do:
      /* собираем итого по МЦ + номинал */
      assign
        v-tot-qnty = 0
        v-tot-sum  = 0
      .
      for each buf_tt-report-price
        where buf_tt-report-price.wth-code      = tt-report-price.wth-code
          and buf_tt-report-price.par-code      = tt-report-price.par-code
      :
        assign
          v-tot-qnty = v-tot-qnty + buf_tt-report-price.qnty
          v-tot-sum  = v-tot-sum  + buf_tt-report-price.sum
        .
      end.
      {&PutExcel}
        to-string(v-tot-qnty,{&wrsttl-qnty-type}) {&tabulation}
        to-string(v-tot-sum,{&wrsttl-sum-type})   {&tabulation}
      skip.
    end.

    if last-of(tt-report-price.price-rubl)
    then do: /* итого по стоимости МЦ */
      {&PutExcel}
        " "               {&tabulation}
        "Итого по ценам"  {&tabulation}
        " "               {&tabulation}
        " "               {&tabulation}
      .
      for each buf_tt-report-price
        where buf_tt-report-price.wth-code    = tt-report-price.wth-code
          and buf_tt-report-price.price-rubl  = tt-report-price.price-rubl
      break by buf_tt-report-price.grp-code
      :
        assign
          v-price-qnty  = v-price-qnty + buf_tt-report-price.qnty
          v-price-sum  = v-price-sum  + buf_tt-report-price.sum
        .
        if last-of(buf_tt-report-price.grp-code)
        then do:
          {&PutExcel}
            to-string(v-price-qnty,{&wrsttl-qnty-type}) {&tabulation}
            to-string(v-price-sum,{&wrsttl-sum-type})  {&tabulation}
          .
          assign
            v-price-qnty = 0
            v-price-sum  = 0
          .
        end.
      end.
      {&PutExcel}
      skip.
    end. /* if last-of(tt-report-price.price-rubl) */

    if last-of(tt-report-price.wth-code)
    then do: /* итого по МЦ */
      {&PutExcel}
        " "                                                     {&tabulation}
        substitute( "Итого по &1 " , tt-report-price.wth-name)  {&tabulation}
        " "                                                     {&tabulation}
        " "                                                     {&tabulation}
      .
      for each buf_tt-report-price
        where buf_tt-report-price.wth-code      = tt-report-price.wth-code
      break by buf_tt-report-price.grp-code
      :
        assign
          v-wth-qnty = v-wth-qnty + buf_tt-report-price.qnty
          v-wth-sum  = v-wth-sum  + buf_tt-report-price.sum
        .
        if last-of(buf_tt-report-price.grp-code)
        then do:
          {&PutExcel}
            to-string(v-wth-qnty,{&wrsttl-qnty-type}) {&tabulation}
            to-string(v-wth-sum,{&wrsttl-sum-type})  {&tabulation}
          .
          assign
            v-wth-qnty = 0
            v-wth-sum  = 0
          .
        end.
      end.
      {&PutExcel}
      skip.
    end. /* if last-of(tt-report-price.wth-code) */
  end.


  assign
    v-tot-qnty = 0
    v-tot-sum  = 0
  .

  {&PutExcel}
    " "       {&tabulation}
    "ВСЕГО:"  {&tabulation}
    " "       {&tabulation}
    " "       {&tabulation}
  .

  for each tt-report-price
    break by tt-report-price.grp-code
  :
    assign
      v-tot-qnty = v-tot-qnty + tt-report-price.qnty
      v-tot-sum  = v-tot-sum  + tt-report-price.sum
    .
    if last-of(tt-report-price.grp-code)
    then do:
      {&PutExcel}
        to-string(v-tot-qnty,{&wrsttl-qnty-type}) {&tabulation}
        to-string(v-tot-sum,{&wrsttl-sum-type})  {&tabulation}
      .
      assign
        v-all-qnty = v-all-qnty + v-tot-qnty
        v-all-sum  = v-all-sum  + v-tot-sum
        v-tot-qnty = 0
        v-tot-sum  = 0
      .
    end.
  end.
  {&PutExcel}
    to-string(v-all-qnty,{&wrsttl-qnty-type}) {&tabulation}
    to-string(v-all-sum,{&wrsttl-sum-type})  {&tabulation}
  skip.
end.

end procedure. /* print-report-with-price */


/* ---------------------------------------------------------------------------------------- */
procedure print-report-no-price :

do
on error undo, return error return-value
:
  define buffer buf_tt-report               for tt-report.
  define buffer buf_wth-par                 for ub.wth-par .
  define buffer buf_tt-cli-grp              for tt-cli-grp.
  define buffer buf_tt-wealth               for tt-wealth.

  define variable v-i               as integer   no-undo .
  define variable v-line-1          as character no-undo .
  define variable v-clmn-label-1    as character no-undo .
  define variable v-clmn-label-2    as character no-undo .
  define variable v-clmn-label-3    as character no-undo .
  define variable v-clmn-format     as character no-undo .
  define variable v-clmn-sizes      as character no-undo .
  define variable v-row-count       as integer   no-undo .
  define variable v-tot-qnty        as decimal   no-undo .
  define variable v-tot-sum         as decimal   no-undo .
  define variable v-all-qnty        as decimal   no-undo .
  define variable v-all-sum         as decimal   no-undo .

  assign
    v-clmn-label-3 = "1" + {&comma-char} + "2" + {&comma-char} + "3" + {&comma-char}
    v-i = 4
  .

  /* форматируем отчет по объектам реализации талонов */
  for each tt-cli-grp
    by tt-cli-grp.grp-code
  :
    assign
      v-clmn-label-1 = v-clmn-label-1 + tt-cli-grp.grp-name + {&comma-char} + {&comma-char}
      v-clmn-label-2 = v-clmn-label-2 + "Кол-во" + {&comma-char} + "Сумма" + {&comma-char}
      v-clmn-label-3 = v-clmn-label-3 + string(v-i) + {&comma-char} + string(v-i + 1) + {&comma-char}
      v-clmn-format  = v-clmn-format  + substitute("&1={&wrsttl-qnty-fmt};&2={&wrsttl-sum-fmt}", v-i , (v-i + 1) )
      v-clmn-sizes   = v-clmn-sizes   + "{&wrsttl-qnty-width}" + {&comma-char} + "{&wrsttl-sum-width}" + {&comma-char}
      v-line-1       = v-line-1       + substitute("&1:&2,", v-i ,  (v-i + 1) )
      v-i            = v-i + 2
    .
  end.

  /* столбец итого */
  assign
    v-clmn-label-2 = v-clmn-label-2 + "Кол-во" + {&comma-char} + "Сумма" + {&comma-char}
    v-clmn-label-3 = v-clmn-label-3 + string(v-i) + {&comma-char} + string(v-i + 1) + {&comma-char}
    v-clmn-format  = v-clmn-format  + substitute("&1={&wrsttl-qnty-fmt};&2={&wrsttl-sum-fmt}", v-i , (v-i + 1) )
    v-clmn-sizes   = v-clmn-sizes   + "{&wrsttl-qnty-width}" + {&comma-char} + "{&wrsttl-sum-width}" + {&comma-char}
    v-line-1       = v-line-1       + substitute("&1:&2,", v-i ,  (v-i + 1) )
  .

  /* обрезаем лишние знаки */
  assign
    v-clmn-label-3  = trim(v-clmn-label-3 , {&comma-char} )
    v-clmn-format   = trim(v-clmn-format , ";")
    v-clmn-sizes    = trim(v-clmn-sizes  , {&comma-char} )
    v-line-1        = trim(v-line-1 , ",")
  .
  assign
    sheetf.sheet-num          = 1
    sheetf.MergeCellsH        = v-line-1
    sheetf.MergeCellsV        = "1=1:2/2=1:2/3=1:2"
    sheetf.Excel-Column-Lable = "№ п/п"  + {&comma-char} + "Наименование" + {&comma-char} + "Номинал" + {&comma-char} + v-clmn-label-1 + "Итого" + {&comma-char} + {&comma-char}
                                + {&new-line}
                                         + {&comma-char}                  + {&comma-char}             + {&comma-char} + v-clmn-label-2
                                + {&new-line}
                                                                                                                      + v-clmn-label-3
    sheetf.colformat          = "1=@;2=@;3=@;" + v-clmn-format
    sheetf.Sizes              = "{&wrsttl-npp-width}" + {&comma-char} + "{&wrsttl-wth-width}" + {&comma-char} + "{&wrsttl-wth-nom-width}" + {&comma-char}
                                + v-clmn-sizes
  .
  run rep/extitle.p (1).



  assign
    v-row-count = 1
  .

  for each tt-report
      break by tt-report.sale-grp-code
            by tt-report.wth-code
            by tt-report.par-code
            by tt-report.grp-code
  :
    if first-of(tt-report.sale-grp-code)
    then do:
      {&PutExcel}
        " "                     {&tabulation}
        tt-report.sale-grp-name {&tabulation}
        " "                     {&tabulation}
      .
      for each tt-cli-grp
      :
        {&PutExcel}
          " "                     {&tabulation}
          " "                     {&tabulation}
        .
      end.
      {&PutExcel} skip.
    end.
    if first-of(tt-report.wth-code) or first-of(tt-report.par-code)
    then do:
      {&PutExcel}
        string(v-row-count, ">9") {&tabulation}
        tt-report.wth-name        {&tabulation}
        tt-report.par-name        {&tabulation}
      .
      assign
        v-row-count = v-row-count + 1
      .
    end.

    {&PutExcel}
      to-string(tt-report.qnty,{&wrsttl-qnty-type}) {&tabulation}
      to-string(tt-report.sum,{&wrsttl-sum-type}) {&tabulation}
    .

    if last-of(tt-report.par-code) or last-of(tt-report.wth-code)
    then do:
      /* собираем итого по МЦ + номинал */
      assign
        v-tot-qnty = 0
        v-tot-sum  = 0
      .
      for each buf_tt-report
        where buf_tt-report.sale-grp-code = tt-report.sale-grp-code
          and buf_tt-report.wth-code      = tt-report.wth-code
          and buf_tt-report.par-code      = tt-report.par-code
      :
        assign
          v-tot-qnty = v-tot-qnty + buf_tt-report.qnty
          v-tot-sum  = v-tot-sum  + buf_tt-report.sum
        .
      end.

      {&PutExcel}
        to-string(v-tot-qnty,{&wrsttl-qnty-type}) {&tabulation}
        to-string(v-tot-sum,{&wrsttl-sum-type})  {&tabulation}
      skip.
    end.
    if last-of(tt-report.sale-grp-code)
    then do:
      /* собираем итого по группе погашения */
      {&PutExcel}
        " "     {&tabulation}
        "Итого" {&tabulation}
        " "     {&tabulation}
      .
      /* итого по объекту погашения */
      assign
        v-tot-qnty = 0
        v-tot-sum  = 0
      .
      for each buf_tt-report
        where buf_tt-report.sale-grp-code = tt-report.sale-grp-code
          break by buf_tt-report.grp-code
      :
        assign
          v-tot-qnty = v-tot-qnty + buf_tt-report.qnty
          v-tot-sum  = v-tot-sum  + buf_tt-report.sum
        .
        if last-of(buf_tt-report.grp-code)
        then do:
          {&PutExcel}
            to-string(v-tot-qnty,{&wrsttl-qnty-type}) {&tabulation}
            to-string(v-tot-sum,{&wrsttl-sum-type})   {&tabulation}
          .
          assign
            v-tot-qnty = 0
            v-tot-sum  = 0
          .
        end.
      end.
      {&PutExcel} skip.
      assign
        v-row-count = 1
      .
    end.
  end.

  /* выводим ВСЕГО */
  {&PutExcel}
    " "             {&tabulation}
    "Итого по МЦ:" {&tabulation}
  skip.

  assign
    v-row-count = 1
  .

  for each tt-report
    break by tt-report.wth-code
          by tt-report.par-code
          by tt-report.grp-code
  :
    if first-of(tt-report.wth-code) or first-of(tt-report.par-code)
    then do:
      {&PutExcel}
        string(v-row-count, ">9") {&tabulation}
        tt-report.wth-name        {&tabulation}
        tt-report.par-name        {&tabulation}
      .
      assign
        v-row-count = v-row-count + 1
        v-tot-qnty  = 0
        v-tot-sum   = 0
      .
    end.

    assign
      v-tot-qnty = v-tot-qnty + tt-report.qnty
      v-tot-sum  = v-tot-sum  + tt-report.sum
    .

    if last-of(tt-report.grp-code)
    then do:
      {&PutExcel}
        to-string(v-tot-qnty,{&wrsttl-qnty-type}) {&tabulation}
        to-string(v-tot-sum,{&wrsttl-sum-type})   {&tabulation}
      .
      assign
        v-tot-qnty  = 0
        v-tot-sum   = 0
      .
    end.
    if last-of(tt-report.wth-code) or last-of(tt-report.par-code)
    then do:
      /* собираем итого по МЦ + номинал */
      assign
        v-tot-qnty = 0
        v-tot-sum  = 0
      .
      for each buf_tt-report
        where buf_tt-report.wth-code      = tt-report.wth-code
          and buf_tt-report.par-code      = tt-report.par-code
      :
        assign
          v-tot-qnty = v-tot-qnty + buf_tt-report.qnty
          v-tot-sum  = v-tot-sum  + buf_tt-report.sum
        .
      end.

      {&PutExcel}
        to-string(v-tot-qnty,{&wrsttl-qnty-type}) {&tabulation}
        to-string(v-tot-sum,{&wrsttl-sum-type})   {&tabulation}
      skip.

    end.
  end.


  assign
    v-tot-qnty = 0
    v-tot-sum  = 0
  .

  {&PutExcel}
    " "       {&tabulation}
    "ВСЕГО:"  {&tabulation}
    " "       {&tabulation}
  .

  for each tt-report
    break by tt-report.grp-code
  :
    assign
      v-tot-qnty = v-tot-qnty + tt-report.qnty
      v-tot-sum  = v-tot-sum  + tt-report.sum
    .
    if last-of(tt-report.grp-code)
    then do:
      {&PutExcel}
        to-string(v-tot-qnty,{&wrsttl-qnty-type}) {&tabulation}
        to-string(v-tot-sum,{&wrsttl-sum-type})   {&tabulation}
      .
      assign
        v-all-qnty = v-all-qnty + v-tot-qnty
        v-all-sum  = v-all-sum  + v-tot-sum
        v-tot-qnty = 0
        v-tot-sum  = 0
      .
    end.
  end.
  {&PutExcel}
    to-string(v-all-qnty,{&wrsttl-qnty-type}) {&tabulation}
    to-string(v-all-sum,{&wrsttl-sum-type})   {&tabulation}
  skip.
end.
end procedure. /* print-report-no-price */


/* ---------------------------------------------------------------------------------------- */
function to-string returns character (p-val as decimal , p-type as character) :
  define variable v-ret-val as character no-undo .
  run proc-to-string  in this-procedure ( input p-val
                                        , input p-type
                                        , output v-ret-val
                                        ) .
  return v-ret-val.
end function.

/* ---------------------------------------------------------------------------------------- */
procedure proc-to-string :
  define input  parameter p-val   as decimal   no-undo .
  define input  parameter p-type  as character no-undo .
  define output parameter p-ret-val   as character no-undo .

  define variable v-format as character no-undo .
do
on error undo, return error return-value
:
  case p-type
  :
    when "D"
    then do:
      assign
        v-format = ">>>>>>>>>9.99"
      .
    end.
    when "I"
    then do:
      assign
        v-format = ">>>>>>>>>9"
      .
    end.
    otherwise do:
      undo, return error "Процедуре proc-to-string передано неверное значение параметра p-type.".
    end.
  end case.
  assign
    p-ret-val = ( if p-val = 0 then " " else trim(replace(string(p-val, v-format) , '.' , ',')) )
  .
end.

end procedure. /* proc-to-string */