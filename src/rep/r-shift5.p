block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-shift5.p $
$Archive: rep/r-shift5.p $

печать сменного отчета (ЮКОС лист 4)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/06/07
Author: Dmitry Ukhanov
Creation date: 08/06/07

Автор: Уханов Дмитрий Юрьевич
Дата создания: 04/12/06
Author: Dmitry Ukhanov
Creation date: 04/12/06

*/

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
define input parameter p-obj-type    like ub.clients.obj-type no-undo .
define input parameter p-obj-code    like ub.clients.obj-code no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-shift5.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-shift5.p $":U .
define variable vss-description as character no-undo initial "печать сменного отчета (ЮКОС лист 4)":U .

{ cmp/trg-def.i              }
{ cmp/r-page1.i              }
{ cmp/r-pril.i               }
{ rep/r-sym.i                }
{ rep/icm-5df.i "new shared" }

define shared stream PrnLibstream .

define variable pol1 as character no-undo .
define variable pol2 as decimal   no-undo .
define variable pol3 as decimal   no-undo .
define variable pol4 as decimal   no-undo .
define variable pol5 as decimal   no-undo .
define variable pol6 as decimal   no-undo .
define variable pol7 as decimal   no-undo .
define variable line as character no-undo .
define variable ii   as integer   no-undo .

{ rep/r-shfth.i proc-def }
{ rep/r-shfth.i r-shift5 }

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


&scop All-sym6 sym1 sym2 sym3 sym4 sym5 sym6

define frame FRAME-5
  pol1 column-label "5.1":C32 format "x(32)":U           space( 0 ) sym1 column-label ":" format "x(1)":U space( 0 )
  pol2 column-label "5.2":C15 format "->>>,>>>,>>9.99":U space( 0 ) sym2 column-label ":" format "x(1)":U space( 0 )
  pol3 column-label "5.3":C14 format ">>>,>>>,>>9.99":U  space( 0 ) sym3 column-label ":" format "x(1)":U space( 0 )
  pol4 column-label "5.4":C14 format ">>>,>>>,>>9.99":U  space( 0 ) sym4 column-label ":" format "x(1)":U space( 0 )
  pol5 column-label "5.5":C14 format ">>>,>>>,>>9.99":U  space( 0 ) sym5 column-label ":" format "x(1)":U space( 0 )
  pol6 column-label "5.6":C14 format ">>>,>>>,>>9.99":U  space( 0 ) sym6 column-label ":" format "x(1)":U space( 0 )
  pol7 column-label "5.7":C15 format "->>>,>>>,>>9.99":U space( 0 )
with width {&DOS_CW_2} down stream-io use-text no-box .
/* строки отчета */

run rep/r-shft5r.p
  ( input p-obj-type
  , input p-obj-code
  , input X-date-Start
  , input X-Shift-Start
  , input X-date-End
  , input X-Shift-End
  ) no-error .

form header
  {&Header-Text5}
with frame TopFrame width {&DOS_CW_2} page-top no-labels no-box .
view stream PrnLibstream Frame TopFrame .

for each t-5 no-lock use-index namei
:
  assign
    pol1 = t-5.wth-name
    pol2 = t-5.stock-before
    pol3 = t-5.income-cassa - t-5.incass-cassa
    pol4 = t-5.income-other
    pol5 = t-5.incass-bank
    pol6 = t-5.incass-other
    pol7 = t-5.stock-after
  .
  run on-same-page in this-procedure ( input {&bottom-height} + 1 ) .
  display Stream PrnLibstream
    pol1
    pol2
    pol3 when pol3 <> 0
    pol4 when pol4 <> 0
    pol5 when pol5 <> 0
    pol6 when pol6 <> 0
    pol7
  with frame Frame-5.
  {&PutExcel}
    pol1 {&tabulation}
    pol2 {&tabulation}
    pol3 {&tabulation}
    pol4 {&tabulation}
    pol5 {&tabulation}
    pol6 {&tabulation}
    pol7 {&tabulation}
  skip .
end. /* for each t-5 */