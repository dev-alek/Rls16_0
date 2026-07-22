block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-shift8.p $
$Archive: rep/r-shift8.p $

печать сменного отчета

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/01/07
Author: Bakhtadze Natalya
Creation date: 08/01/07

ЮКОС лист 8

*/

/* Parameter Definitions ---                                            */
define input parameter parparentproc as   widget-handle       no-undo .
define input parameter p-parent-handle            as handle    no-undo .
define input parameter p-log-handle               as handle    no-undo .
define input parameter p-cont-handle              as handle    no-undo .
define input parameter p-rebh                     as handle    no-undo .
define input parameter p-report-id                as character no-undo .
define input parameter p-xsd-file                 as character no-undo .
define input parameter p-log-file-name            as character no-undo .
define input parameter p-batch                    as integer   no-undo .
define input parameter p-codex-id                 as integer   no-undo .
define input parameter p-ruleset-id               as integer   no-undo .
define input parameter p-z-number-list       as character no-undo.
define input parameter p-previous-shift-date as date      no-undo.

/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      as character no-undo initial "$Author: expertek $":U.
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: r-shift8.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: rep/r-shift8.p $":U.
define variable vss-description as character no-undo initial "Печать сменного отчета - лист 8 ":U.

{ cmp/vssrevis.i                }
{ cmp/str-glbl.i                }
{ cmp/r-page1.i                 }
{ cmp/r-pril.i                  }
{ rep/real-8df.i SHARED treal-8 }
{ ref/cp-attr.i }


define shared stream PrnLibstream.

define variable accum-qnty1 as decimal no-undo .
define variable accum-netto-rubl as decimal no-undo .
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable line  as character no-undo.
define variable v-text as logical no-undo .
define variable v-prev-page as integer no-undo .
define variable v-curr-page as integer no-undo .
define buffer cli-treal-8 for treal-8 .
define buffer cli-gds-treal-8 for treal-8 .
define buffer gds-treal-8 for treal-8 .
define buffer cp-gds-treal-8 for treal-8 .
define buffer cp-treal-8 for treal-8 .
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_goods for ub.goods.
define buffer buf_clients for ub.clients.

{ rep/r-shfth.i proc-def }
{ rep/r-shfth.i r-shift8 }

&scop display-message ~
   if p-batch > 0 then do: ~
     run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input p-log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~). ~
   end. ~
   else do: ~
      run write-to-log in p-log-handle ( input ~{&my-message~}). ~
   end

/* к этому моменту должна быть уже заполнена таблица treal-8 */

FORM HEADER
  {&Header-Text8}
WITH FRAME TopFrame WIDTH {&DOS_CW_2} PAGE-TOP NO-LABELS NO-BOX.

VIEW STREAM PrnLibstream FRAME TOpFrame.
/* ЦИКЛ по товарам-топливам */

&scop col1-width 29
&scop col-pet-width 23
&scop col-qnty-width 11
&scop col-tot-qnty-width 14
&scop col-qnty-format "->>>,>>9.99"
&scop col-tot-qnty-format "->>,>>>,>>9.99"
&scop col-sum-width  11
&scop col-sum-format  "->>>,>>9.99"
&scop col-tot-sum-format "->>,>>>,>>9.99"
&scop col-tot-width 29
&scop col-tot-sum-width 15

for each gds-treal-8 where
      gds-treal-8.gds-code > 0
  and gds-treal-8.cpay-code = 0
  and gds-treal-8.curr-code = 0
  and gds-treal-8.cli-type = '':U
  and gds-treal-8.cli-code = 0
  :
  v-ii = v-ii + 1.
end.

&scop smooth-line ~
    if v-text then do:                 ~
      put stream PrnLibstream unformatted  ~
      fill('-':U, ~{&col1-width~} + 1)  ~
      .                                  ~
      do v-jj = 1 to v-ii:               ~
        put stream PrnLibstream unformatted ~
        fill('-':U, ~{&col-pet-width~} + 2) ~
        .                                   ~
      end.                                   ~
      put stream PrnLibstream unformatted       ~
      fill('-':U, ~{&col-tot-width~} + 1) ~
      skip.                               ~
    end


if {&col1-width} + 1 + (v-ii * ({&col-pet-width} + 2)) + {&col-tot-width} + 1 > {&DOS_CW_2} then do:
  put stream PrnLibstream unformatted
  "Слишком широкий отчет - смотрите в EXCEL"
  skip.
  v-text = no.
end.
else v-text = yes.
output to jj.txt.
for each treal-8:
  export treal-8.
end.
output close.

FOR EACH cp-treal-8 where
         cp-treal-8.gds-code = 0
     and cp-treal-8.cpay-code > 0
     and cp-treal-8.cli-type = '':U
     and cp-treal-8.cli-code = 0,
   first buf_cash-pay no-lock where
        buf_cash-pay.cdpay-code = cp-treal-8.cpay-code
    and buf_cash-pay.curr-code = cp-treal-8.curr-code
break
by cp-treal-8.cpay-code
by cp-treal-8.curr-code
:
  if first-of( cp-treal-8.curr-code) then do:
    run print-header in this-procedure ( input " Тип кассового платежа ").
  end. /*if first-of( cp-treal-8.curr-code) then do:*/
  if v-text then do:
    put stream PrnLibstream unformatted
    string(buf_cash-pay.obj-name, "X({&col1-width})") ":"
    .
  end.
  {&putexcel}
  buf_cash-pay.obj-name {&tabulation}
  .

  for each gds-treal-8 where
        gds-treal-8.gds-code > 0
    and gds-treal-8.cpay-code = 0
    and gds-treal-8.curr-code = 0
    and gds-treal-8.cli-type = '':U
    and gds-treal-8.cli-code = 0
    :
    find first cp-gds-treal-8 where
          cp-gds-treal-8.gds-code = gds-treal-8.gds-code
      and cp-gds-treal-8.cpay-code = cp-treal-8.cpay-code
      and cp-gds-treal-8.curr-code = cp-treal-8.curr-code
      and cp-gds-treal-8.cli-type = '':U
      and cp-gds-treal-8.cli-code = 0
      no-error.
    if available cp-gds-treal-8 then do:
      if v-text then do:
        put stream PrnLibstream unformatted
        cp-gds-treal-8.qnty1 format  {&col-qnty-format} ':':U
        cp-gds-treal-8.netto-rubl format {&col-sum-format} ':':U
        .
      end.
      {&putexcel}
      cp-gds-treal-8.qnty1      {&tabulation}
      cp-gds-treal-8.netto-rubl {&tabulation}
      .

    end.
    else do:
      if v-text then do:
        put stream PrnLibstream unformatted
        0.0 format {&col-qnty-format} ':':U
        0.0 format {&col-sum-format} ':':U
        .
      end.
      {&putexcel}
      0.0 {&tabulation}
      0.0 {&tabulation}
      .

    end.
  end.
  if v-text then do:
    put stream PrnLibstream unformatted
    cp-treal-8.qnty1      format {&col-tot-qnty-format} ':':U
    cp-treal-8.netto-rubl format {&col-tot-sum-format}
    skip
    .
  end.
  {&Putexcel}
  cp-treal-8.qnty1      {&tabulation}
  cp-treal-8.netto-rubl  {&tabulation}
  skip
  .
end.
{&smooth-line}.
if v-text then do:
  put stream PrnLibstream unformatted
  "В том числе по контрагентам"
  skip.
end.
{&Putexcel}
"В том числе по контрагентам"
skip.
{&smooth-line}.
for each treal-8
where treal-8.cli-type > '':U
break
by treal-8.cli-type
by treal-8.cli-code:
   if last-of (treal-8.cli-code) then do:
     v-prev-page = page-number( PrnLibstream).
     run on-same-page in this-procedure ( input {&bottom-height} + 1 ).
     v-curr-page = page-number( PrnLibstream).
     if v-curr-page > v-prev-page then do:
        run print-header in this-procedure ( input " Наименование контрагента ").
     end.
     find first buf_clients no-lock where
              buf_clients.obj-type = treal-8.cli-type
          and buf_clients.obj-code = treal-8.cli-code.
      if v-text then do:
        put stream PrnLibstream unformatted
        string(buf_clients.obj-name, "X({&col1-width})") ":"
        .
      end.
      {&putexcel}
      buf_clients.obj-name {&tabulation}.

      for each gds-treal-8 where
            gds-treal-8.gds-code > 0
        and gds-treal-8.cpay-code = 0
        and gds-treal-8.curr-code = 0
        and gds-treal-8.cli-type = '':U
        and gds-treal-8.cli-code = 0:
        find first cli-gds-treal-8 where
                  cli-gds-treal-8.gds-code = gds-treal-8.gds-code
              and cli-gds-treal-8.cpay-code = gds-treal-8.cpay-code
              and cli-gds-treal-8.curr-code = gds-treal-8.curr-code
              and cli-gds-treal-8.cli-type = treal-8.cli-type
              and cli-gds-treal-8.cli-code = treal-8.cli-code no-error .
        if available cli-gds-treal-8 then do:
          if v-text then do:
            put stream PrnLibstream unformatted
            cli-gds-treal-8.qnty1      format {&col-qnty-format} ':':U
            cli-gds-treal-8.netto-rubl format {&col-sum-format} ':':U
            .
          end.
          {&putexcel}
          cli-gds-treal-8.qnty1      {&tabulation}
          cli-gds-treal-8.netto-rubl {&tabulation}
          .
        end.
        else do:
          if v-text then do:
            put stream PrnLibstream unformatted
            0.0 format {&col-qnty-format} ':':U
            0.0 format {&col-sum-format} ':':U
            .
          end.
          {&putexcel}
          0.0 {&tabulation}
          0.0 {&tabulation}
          .
        end.
      end. /* for each gds-treal-8 where*/
      find first cli-treal-8 where
                cli-treal-8.gds-code = 0
            and cli-treal-8.cpay-code = 0
            and cli-treal-8.curr-code = 0
            and cli-treal-8.cli-type = treal-8.cli-type
            and cli-treal-8.cli-code = treal-8.cli-code no-error .
      if available cli-treal-8 then do:
        if v-text then do:
          put stream PrnLibstream unformatted
          cli-treal-8.qnty1 format  {&col-tot-qnty-format} ':':U
          cli-treal-8.netto-rubl format {&col-tot-sum-format}
          skip
          .
        end.
        {&putexcel}
        cli-treal-8.qnty1  {&tabulation}
        cli-treal-8.netto-rubl {&tabulation}
        skip
        .
      end.
      else do:
        if v-text then do:
          put stream PrnLibstream unformatted
          0.0 format {&col-tot-qnty-format} ':':U
          0.0 format {&col-tot-sum-format}  ':':U
          skip
          .
        end.
        {&putexcel}
        0.0 {&tabulation}
        0.0 {&tabulation}
        skip
        .
      end.
   end.
end. /*for each treal-8*/
v-prev-page = page-number( PrnLibstream).
run on-same-page in this-procedure ( input {&bottom-height} + 2 ).
v-curr-page = page-number( PrnLibstream).
if v-curr-page > v-prev-page then do:
  run print-header in this-procedure ( input "  ").
end.
else do:
  {&smooth-line}.
end.

if v-text then do:
  put stream PrnLibstream unformatted
  string("ИТОГО", "X({&col1-width})") ":"
  .
end.
{&putexcel}
"ИТОГО" {&tabulation}
.

for each gds-treal-8 where
      gds-treal-8.gds-code > 0
  and gds-treal-8.cpay-code = 0
  and gds-treal-8.curr-code = 0
  and gds-treal-8.cli-type = '':U
  and gds-treal-8.cli-code = 0
  :
  if v-text then do:
    put stream PrnLibstream unformatted
    gds-treal-8.qnty1      format {&col-qnty-format} ':':U
    gds-treal-8.netto-rubl format {&col-sum-format}  ':':U
    .
  end.
  {&putexcel}
  gds-treal-8.qnty1  {&tabulation}
  gds-treal-8.netto-rubl {&tabulation}
  .
  assign
  accum-qnty1 = accum-qnty1 + gds-treal-8.qnty1
  accum-netto-rubl = accum-netto-rubl + gds-treal-8.netto-rubl
  .

end.
if v-text then do:
  put stream PrnLibstream unformatted
  accum-qnty1 format  {&col-tot-qnty-format} ':':U
  accum-netto-rubl format {&col-tot-sum-format}
  skip.
  {&putexcel}
  accum-qnty1  {&tabulation}
  accum-netto-rubl
  skip
  .
end.
procedure print-header :
define input parameter p-col1-name as character no-undo .

  do
  on error undo, return error
  :
     /*линия*/
    {&smooth-line}.
    /*1-я строка*/
    if v-text then do:
      put stream PrnLibstream unformatted
      string(p-col1-name, "X({&col1-width})") ":"
      .
    end.
    for each gds-treal-8 where
            gds-treal-8.gds-code > 0
        and gds-treal-8.cpay-code = 0
        and gds-treal-8.curr-code = 0
        and gds-treal-8.cli-type = '':U
        and gds-treal-8.cli-code = 0
        ,
        first buf_goods no-lock where
              buf_goods.gds-code = gds-treal-8.gds-code:
      if v-text then do:
        put stream PrnLibstream unformatted
        string(buf_goods.chk-name, "X({&col-pet-width})")  ":"
        .
      end.
    end.
    if v-text then do:
      put stream PrnLibstream unformatted
      string( "ИТОГО",  "X({&col-tot-width})")
      skip
      .
    end.
    /*2-я строка*/
    if v-text then do:
      put stream PrnLibstream unformatted
      fill( {&space-char},  {&col1-width}) ":"
      .
    end.
    for each gds-treal-8 where
          gds-treal-8.gds-code > 0
      and gds-treal-8.cpay-code = 0
      and gds-treal-8.curr-code = 0
      and gds-treal-8.cli-type = '':U
      and gds-treal-8.cli-code = 0
      :
      if v-text then do:
        put stream PrnLibstream unformatted
        string(" литры",  "X({&col-qnty-width})") ':':U
        string(" {&abbr_rubli}",  "X({&col-sum-width})") ':':U
        .
      end.
    end.
    if v-text then do:
      put stream PrnLibstream unformatted
      string( "литры",  "X({&col-tot-qnty-width})")  ':'
      string(" {&abbr_rubli}",  "X({&col-tot-sum-width})")
      skip
      .
    end.
    {&smooth-line}.

  end.

end procedure. /* print header */