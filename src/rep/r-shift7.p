block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-shift7.p $
$Archive: rep/r-shift7.p $

печать сменного отчета лист 7

Автор: Уханов Дмитрий Юрьевич
Дата создания: 07/27/07
Author: Dmitry Ukhanov
Creation date: 07/27/07

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
define input parameter p-previous-shift-date as date      no-undo.

define variable vss-revision    as char no-undo init "$revision: 2 $":u.
define variable vss-author      as char no-undo init "$author: mkochetkov $":u.
define variable vss-date        as char no-undo init "$date: 7.03.07 10:38 $":u.
define variable vss-workfile    as char no-undo init "$workfile: r-shift5.p $":u.
define variable vss-archive     as char no-undo init "$archive: /ver14_0/rep/r-shift5.p $":u.
define variable vss-description as char no-undo init "$Печать сменного отчета - лист 5 $":u.


{ cmp/str-glbl.i             }
{ cmp/r-page1.i              }
{ cmp/r-pril.i               }
{ rep/r-sym.i                }
{ rep/icm-7df.i "new shared" }


define   shared stream  PrnLibStream.

define variable pol1 as integer   no-undo .
define variable pol2 as integer   no-undo .
define variable pol3 as character no-undo .
define variable pol4 as integer   no-undo .
define variable pol5 as decimal   no-undo .

define variable line as character no-undo .
/*define variable ii as integer no-undo.*/

{ rep/r-shfth.i proc-def }
{ rep/r-shfth.i r-shift7 }

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


define frame frame-7
  pol1 column-label "7.1":c15     format ">>>>9" space(0)
  sym1 column-label ":"           format "x(1)"  space(0)
  pol2 column-label "7.2":c15     format ">>>>9" space(0)
  sym2 column-label ":"           format "x(1)"  space(0)
  pol3 column-label "7.3":c30     format "x(30)" space(0)
  sym3 column-label ":"           format "x(1)"  space(0)
  pol4 column-label "7.4":c14     format "->>>>>>9" space(0)
  sym4 column-label ":"           format "x(1)"  space(0)
  pol5 column-label "7.5":c11     format "->>>>>9.99" space(0)
with width {&DOS_CW_2} down stream-io use-text no-box.
/* строки отчета  */

run rep/r-shft7r.p
  ( input p-obj-type
   ,input p-obj-code
   ,input X-date-Start
   ,input X-Shift-Start
   ,input X-date-End
   ,input X-Shift-End
   ,input p-previous-shift-date
  ) no-error.

form header
  {&Header-Text7}
  with frame TopFrame width {&DOS_CW_2} page-top no-labels no-box
.
view stream PrnLibStream frame TopFrame .


for each t-7 no-lock
  use-index pi
on error undo, return error return-value
:
  assign
    pol1 = t-7.pump-code
    pol2 = t-7.nozzle-code
    pol3 = t-7.gds-name
    pol4 = ( t-7.state-el-cnt - t-7.state-mh-cnt ) * 1000
    pol5 = ( t-7.state-el-cnt - t-7.state-mh-cnt ) * 100 * 1000 / ( t-7.state-mh-cnt * 1000 )  /* для большей точности вычисления % считаем от миллилитров */
  .
  run on-same-page in this-procedure
    ({&bottom-height} + 1
    ) .
  display Stream PrnLibStream
    pol1
    sym1
    pol2
    sym2
    pol3
    sym3
    pol4 when pol4 <> ?
    sym4
    pol5 when pol5 <> ?
    with frame frame-7
  .
  {&PutExcel}
    pol1 {&tabulation}
    pol2 {&tabulation}
    pol3 {&tabulation}
    pol4 {&tabulation}
    pol5 {&tabulation}
         {&new-line}
  .
END.

