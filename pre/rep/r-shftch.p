block-level on error undo, throw.
DEFINE INPUT PARAMETER pobj-type like ub.shift-obj.obj-type no-undo.
DEFINE INPUT PARAMETER pobj-code like ub.shift-obj.obj-code no-undo.
DEFINE INPUT PARAMETER pshift-date like ub.shift-obj.shift-date no-undo.
DEFINE INPUT PARAMETER pshift-num like ub.shift-obj.shift-num no-undo.
DEFINE INPUT PARAMETER pshift-date1 like ub.shift-obj.shift-date no-undo.
DEFINE INPUT PARAMETER pshift-num1 like ub.shift-obj.shift-num no-undo.
DEFINE INPUT PARAMETER SHEETS as integer no-undo.
DEFINE INPUT PARAMETER SHEET2 as logical no-undo.
DEFINE INPUT PARAMETER SHEET3 as logical no-undo.
DEFINE INPUT PARAMETER SHEET4 as logical no-undo.
DEFINE INPUT PARAMETER SHEET8 as logical no-undo.
define input parameter pclassify as logical no-undo .
define input parameter pselectgood as logical no-undo .
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author: expertek $":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile: r-shftch.p $":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive: rep/r-shftch.p $":U.
define variable vss-description AS CHAR NO-UNDO INIT "Сменный отчет - алгоритм разброса чеков - лист 2-4":U.
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE SHARED TEMP-TABLE treal-2 no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD qnty2 as decimal
FIELD netto as decimal
FIELD brutto as decimal
FIELD discount-sum as decimal
FIELD chk-qnty as int
FIELD out-name as character format "X(18)"
FIELD is-pay as logical
FIELD ii as integer
field discnt-type as integer
INDEX pi IS
  primary
      gds-code
      cpay-code
      curr-code
      is-pay DESCENDING
INDEX vi
      gds-code
      cpay-code
      discnt-type
      ii
.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE SHARED TEMP-TABLE treal-3 no-undo
FIELD grp-code-sheet as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(20)"
FIELD is-pay as logical
FIELD ii as integer
FIELD discnt-type   as integer
FIELD brutto as decimal
FIELD discount-sum as decimal
FIELD chk-qnty as int
INDEX pi IS UNIQUE PRIMARY
      grp-code-sheet
      cpay-code
      discnt-type
      curr-code
      is-pay DESCENDING
INDEX vi
      grp-code-sheet
      ii
.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-chk-gds no-undo
field doc-code like ub.chk-doc.doc-code
FIELD b-code like ub.chk-gds.b-code
FIELD src-code like ub.chk-gds.src-code
field sum as decimal
field sum-change as decimal
field qnty like ub.chk-gds.doc-qnty
field qnty2 like ub.chk-gds.doc-qnty
field price-base as decimal
field rec-type as integer
field gds-type as integer
field line-num as integer
field pump as integer
field nozzle-code as integer
field jj_ as integer
field jjp_ as integer
field jjo_ as integer
index pi iS unique primary
doc-code
rec-type
b-code
index ijj is unique
jj_
index ijjp
jjp_
index ijjo
jjo_
.
define temp-table temp-chk-pay no-undo like ub.chk-pay
field pet-good as integer
field obj-name like ub.cash-pay.obj-name
field is-cash  like ub.cash-pay.is-cash
field register like ub.cash-pay.register
index pi is primary unique line-num
index isort
pet-good  descending
line-num
.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE SHARED TEMP-TABLE treal-4 no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(20)"
FIELD is-pay as logical
FIELD discnt-type   as integer
FIELD brutto as decimal
FIELD discount-sum as decimal
FIELD chk-qnty as int
FIELD ii as integer
INDEX pi IS UNIQUE PRIMARY
      gds-code
      cpay-code
          discnt-type
      curr-code
      is-pay DESCENDING
INDEX vi
      gds-code
      ii
.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE SHARED TEMP-TABLE treal-8 no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal
FIELD netto-rubl as decimal
FIELD cli-type as character
FIELD cli-code as integer
INDEX pi IS  unique  primary
gds-code
cpay-code
curr-code
cli-type
cli-code
index  ipay cpay-code curr-code
index icli cli-type cli-code
.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE SHARED TEMP-TABLE t-3 no-undo
FIELD grp-code-sheet like ub.goods.grp-code
FIELD grp-name like ub.gds-grp.node-name format "X(32)"
FIELD serv-name as char
FIELD qnty1-before as decimal FORMAT "->>>>9.99"
FIELD netto-before as decimal FORMAT "->>>>9.99"
FIELD qnty1-after as decimal FORMAT "->>>>9.99"
FIELD netto-after as decimal FORMAT "->>>>9.99"
FIELD lines as integer
INDEX pi IS UNIQUE primary
grp-code-sheet
INDEX gname
grp-name
INDEX sname
serv-name
.
DEFINE SHARED TEMP-TABLE tincome-3 no-undo
FIELD grp-code-sheet as integer
FIELD doc-code  like ub.trn-doc.doc-code
FIELD supp-name like ub.clients.obj-name FORMAT "X(20)"
FIELD supp-type like ub.clients.obj-type
FIELD supp-code like ub.clients.obj-code FORMAT ">>>>>>>>9"
FIELD qnty1-in as decimal FORMAT "->>>>9.99"
FIELD netto-in as decimal FORMAT "->>>>>>>9.99"
FIELD is-fact as logical
FIELD ii as integer
INDEX pi IS UNIQUE PRIMARY
      grp-code-sheet
      doc-code
INDEX vi IS UNIQUE
      grp-code-sheet
      ii
.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE create-treal-2.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pqnty2 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
DEFINE INPUT PARAMETER pout-name as character no-undo.
DEFINE INPUT PARAMETER pis-pay as logical no-undo.
DEFINE INPUT PARAMETER pii as integer no-undo.
_main:
DO ON ERROR UNDO _main, return error:
    create treal-2.
    assign
    treal-2.gds-code = pgds-code
    treal-2.cpay-code = pcpay-code
    treal-2.curr-code = pcurr-code
    treal-2.qnty1  =  pqnty1
    treal-2.qnty2  = pqnty2
    treal-2.netto = pnetto
    treal-2.out-name = pout-name
    treal-2.is-pay = pis-pay
    treal-2.ii = pii
    treal-2.discnt-type = -99
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE create-treal-3.
DEFINE INPUT PARAMETER pgrp-code-sheet like ub.gds-grp.node-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
DEFINE INPUT PARAMETER pout-name as character no-undo.
DEFINE INPUT PARAMETER pis-pay as logical no-undo.
DEFINE INPUT PARAMETER pii as integer no-undo.
_main:
DO ON ERROR UNDO _main, return error:
    create treal-3.
    assign
    treal-3.grp-code-sheet = pgrp-code-sheet
    treal-3.cpay-code = pcpay-code
    treal-3.curr-code = pcurr-code
    treal-3.qnty1  =  pqnty1
    treal-3.netto = pnetto
    treal-3.out-name = pout-name
    treal-3.is-pay = pis-pay
    treal-3.ii = pii
    treal-3.discnt-type = -99
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE create-treal-4.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
DEFINE INPUT PARAMETER pout-name as character no-undo.
DEFINE INPUT PARAMETER pis-pay as logical no-undo.
DEFINE INPUT PARAMETER pii as integer no-undo.
_main:
DO ON ERROR UNDO _main, return error:
    create treal-4.
    assign
    treal-4.gds-code = pgds-code
    treal-4.cpay-code = pcpay-code
    treal-4.curr-code = pcurr-code
    treal-4.qnty1  =  pqnty1
    treal-4.netto = pnetto
    treal-4.out-name = pout-name
    treal-4.is-pay = pis-pay
    treal-4.ii = pii
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.
  function valid-density returns logical ( input p-density as decimal, input p-unit-base-cli-eq as logical ) :
    define variable v-answ as logical no-undo .
    if ( p-unit-base-cli-eq = true
         and p-density = 1.0
       )
      or ( p-unit-base-cli-eq = false
           and p-density <> ?
           and p-density > 0.0
           and p-density < 1.0
         )
    then do:
      assign
        v-answ = true
      .
    end.
    else do:
      assign
        v-answ = false
      .
    end.
    return v-answ.
  end function.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable pychk_kk as integer no-undo .
define variable pychk_jj as integer no-undo .
define variable pychk_jjp as integer no-undo .
define variable pychk_jjo as integer no-undo .
define variable pychk_pay-sum as decimal no-undo .
DEFINE VARIABLE pychk_No-EXCH as logical no-undo.
DEFINE VARIABLE pychk_No-EXCH-rubl as logical no-undo.
DEFINE VARIABLE pychk_dop-sump as decimal No-UNDO.
DEFINE VARIABLE pychk_dop-sumg as decimal No-UNDO.
DEFINE VARIABLE pychk_dop-sumk as decimal No-UNDO.
DEFINE VARIABLE pychk_exch as decimal No-UNDO.
DEFINE VARIABLE pychk_exch-rubl as decimal No-UNDO.
define variable pychk_pay-desk like ub.chk-doc.pay-desk no-undo init 0.
DEFINE VARIABLE pychk_classify as logical no-undo  init no.
DEFINE VARIABLE pychk_selectgood as logical no-undo init no.
define variable pychk_rv as integer no-undo .
DEFINE VARIABLE pychk_density AS DECIMAL NO-UNDO.
DEFINE VARIABLE pychk_SHEET2 as logical no-undo.
DEFINE VARIABLE pychk_SHEET3 as logical no-undo.
DEFINE VARIABLE pychk_SHEET4 as logical no-undo.
DEFINE VARIABLE pychk_SHEET8 as logical no-undo.
define variable pychk_doc-code-r as character no-undo .
define variable pychk_doc-code-v as character no-undo .
define variable pychk_doc-code as character no-undo .
define buffer pychk_ret-doc for ub.trn-doc .
define buffer pychk_ras-doc for ub.trn-doc .
define variable v-cli-type as character no-undo .
define variable v-cli-code as integer no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable v-host-code as integer no-undo .
define buffer buf_dis-card for ub.dis-card.
DEFINE BUFFER b-treal-2 for treal-2.
DEFINE BUFFER b-treal-3 for treal-3.
DEFINE BUFFER b-treal-4 for treal-4.
define buffer buf_t-3 for t-3.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE create-treal-8.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
define input parameter p-cli-type as character no-undo .
define input parameter p-cli-code as integer no-undo .
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
_main:
DO ON ERROR UNDO _main, return error:
    create treal-8.
    assign
    treal-8.gds-code = pgds-code
    treal-8.cpay-code = pcpay-code
    treal-8.curr-code = pcurr-code
    treal-8.qnty1  =  pqnty1
    treal-8.netto = pnetto
    treal-8.cli-type = p-cli-type
    treal-8.cli-code = p-cli-code
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.
define buffer cp-gds-treal-8 for treal-8.
define buffer gds-treal-8 for treal-8.
define buffer cp-treal-8 for treal-8.
define buffer cli-treal-8 for treal-8.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE create-cp-gds-treal-8.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
define input parameter p-cli-type as character no-undo .
define input parameter p-cli-code as integer no-undo .
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
_main:
DO ON ERROR UNDO _main, return error:
    create cp-gds-treal-8.
    assign
    cp-gds-treal-8.gds-code = pgds-code
    cp-gds-treal-8.cpay-code = pcpay-code
    cp-gds-treal-8.curr-code = pcurr-code
    cp-gds-treal-8.qnty1  =  pqnty1
    cp-gds-treal-8.netto = pnetto
    cp-gds-treal-8.cli-type = p-cli-type
    cp-gds-treal-8.cli-code = p-cli-code
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE create-gds-treal-8.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
define input parameter p-cli-type as character no-undo .
define input parameter p-cli-code as integer no-undo .
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
_main:
DO ON ERROR UNDO _main, return error:
    create gds-treal-8.
    assign
    gds-treal-8.gds-code = pgds-code
    gds-treal-8.cpay-code = pcpay-code
    gds-treal-8.curr-code = pcurr-code
    gds-treal-8.qnty1  =  pqnty1
    gds-treal-8.netto = pnetto
    gds-treal-8.cli-type = p-cli-type
    gds-treal-8.cli-code = p-cli-code
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE create-cp-treal-8.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
define input parameter p-cli-type as character no-undo .
define input parameter p-cli-code as integer no-undo .
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
_main:
DO ON ERROR UNDO _main, return error:
    create cp-treal-8.
    assign
    cp-treal-8.gds-code = pgds-code
    cp-treal-8.cpay-code = pcpay-code
    cp-treal-8.curr-code = pcurr-code
    cp-treal-8.qnty1  =  pqnty1
    cp-treal-8.netto = pnetto
    cp-treal-8.cli-type = p-cli-type
    cp-treal-8.cli-code = p-cli-code
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE create-cli-treal-8.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
define input parameter p-cli-type as character no-undo .
define input parameter p-cli-code as integer no-undo .
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
_main:
DO ON ERROR UNDO _main, return error:
    create cli-treal-8.
    assign
    cli-treal-8.gds-code = pgds-code
    cli-treal-8.cpay-code = pcpay-code
    cli-treal-8.curr-code = pcurr-code
    cli-treal-8.qnty1  =  pqnty1
    cli-treal-8.netto = pnetto
    cli-treal-8.cli-type = p-cli-type
    cli-treal-8.cli-code = p-cli-code
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.
define variable v-curr-r-b as character no-undo .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  pobj-type
  ,input  pobj-code
  ,output v-host-code
  )  .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
if v-curr-r-b = 'base':U or
v-base-code = 0 then pychk_NO-exch = yes.
else pychk_No-exch = no.
if v-curr-r-b = 'rubl':U or
v-base-code = 0 then pychk_NO-exch-rubl = yes.
else pychk_No-exch-rubl = no.
if pclassify then do:
  FIND FIRST t-3 where t-3.grp-code = 0 No-ERROR.
end.
assign
pychk_classify = pclassify
pychk_selectgood = pselectgood
pychk_sheet2 = sheet2
pychk_sheet3 = sheet3
pychk_sheet4 = sheet4
pychk_sheet8 = sheet8
.
for each temp-chk-gds:
  delete temp-chk-gds.
end.
_chk-doc:
FOR EACH ub.chk-doc No-LOCK WHERE
         ub.chk-doc.obj-type = pobj-type AND
         ub.chk-doc.obj-code = pobj-code AND
         ub.chk-doc.shift-date >= pshift-date AND
         ub.chk-doc.shift-date <= pshift-date1 AND
     ub.chk-doc.out-code <> ?,
   EACH ub.chk-pay NO-LOCK WHERE
          ub.chk-pay.doc-code = ub.chk-doc.doc-code
    BREAK
    BY CHK-pay.DOC-CODE
    BY CHK-pay.LINE-NUM:
    if ub.chk-doc.shift-date = pshift-date  and ub.chk-doc.shift-num < pshift-num  then next .
    if ub.chk-doc.shift-date = pshift-date1 and ub.chk-doc.shift-num > pshift-num1 then next .
    if lookup(string(chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then next _chk-doc.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if first-of(CHK-pay.DOC-CODE) THEN Do:
  assign
  pychk_kk = 0
  pychk_jj = 1
  pychk_jjp = 0
  pychk_jjo = 0
  pychk_pay-sum = chk-doc.netto
  pychk_dop-sumg = 0
  .
 if ub.chk-doc.netto < 0 then do:
        if pychk_doc-code-r <> ub.chk-doc.out-code
        then do:
          find first pychk_ras-doc no-lock
            where pychk_ras-doc.doc-code = ub.chk-doc.out-code
            no-error .
          if not available pychk_ras-doc then do:
            message
              substitute("Отсутствует документ расхода по чеку &1"
                        , ub.chk-doc.doc-code
                        )   skip
              "ЭКСПОРТ НЕ МОЖЕТ БЫТЬ ОСУЩЕСТВЛЕН" SKIP
              view-as alert-box error .
            return error .
          end.
          pychk_doc-code-r = pychk_ras-doc.doc-code.
          find first pychk_ret-doc no-lock
            where pychk_ret-doc.doc-code = pychk_ras-doc.out-code
            no-error .
          if not available pychk_ret-doc then do:
            message
              substitute("Отсутствует документ возврата по чеку &1"
                        , ub.chk-doc.doc-code
                        )   skip
              "ЭКСПОРТ НЕ МОЖЕТ БЫТЬ ОСУЩЕСТВЛЕН" SKIP
              view-as alert-box error .
            return error .
          end.
          pychk_doc-code-v = pychk_ret-doc.doc-code.
        end.
        assign
          pychk_doc-code = pychk_doc-code-v
        .
      end.
      else do:
        assign
          pychk_doc-code = ub.chk-doc.out-code
        .
      end.
  FOR EACH ub.chk-gds No-LOCK WHERE
           ub.chk-gds.doc-code = ub.chk-pay.doc-code
  BY ub.chk-gds.line-num:
  pychk_density = 0.
  if ub.chk-gds.write-off-code <> ?
  and ub.chk-gds.write-off-code > 0 then NEXT.
    if chk-gds.pump <> 0 then do:
      find first ub.bar-code no-lock where ub.bar-code.b-code = ub.chk-gds.b-code    no-error.
      find first ub.goods    no-lock where ub.goods.gds-code  = ub.bar-code.gds-code no-error.
      find first ub.doc-line no-lock where
                ub.doc-line.doc-code  = pychk_doc-code and
                ub.doc-line.artic     = ub.goods.artic      and
                ub.doc-line.prod-type = ub.goods.prod-type  and
                ub.doc-line.prod-code = ub.goods.prod-code  no-error.
      assign pychk_density = ( if available ub.doc-line then ub.doc-line.fact-density else 0 ).
      find first temp-chk-gds where
                temp-chk-gds.b-code = chk-gds.b-code
           AND  temp-chk-gds.doc-code = chk-gds.doc-code
           and temp-chk-gds.rec-type = 1 no-error.
      if available temp-chk-gds then do:
        assign
        temp-chk-gds.qnty = temp-chk-gds.qnty  + chk-gds.doc-qnty
        temp-chk-gds.sum  = temp-chk-gds.sum  + chk-gds.doc-qnty * (chk-gds.price-base - chk-gds.discnt + chk-gds.price-service)
        temp-chk-gds.sum-change = temp-chk-gds.sum
        temp-chk-gds.qnty2 = temp-chk-gds.qnty2 + ub.chk-gds.doc-qnty * pychk_density
        .
      end.
      else do:
        find first temp-chk-gds use-index ijj where temp-chk-gds.jj_ = pychk_jj no-error.
        if not available temp-chk-gds then do:
          create temp-chk-gds.
          assign
          temp-chk-gds.jj_ = pychk_jj
          pychk_jj = pychk_jj + 1
          temp-chk-gds.qnty2 = 0
          temp-chk-gds.qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.sum-change = temp-chk-gds.sum
          .
        end.
        else do:
          assign
          temp-chk-gds.qnty2 = 0
          temp-chk-gds.qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.sum-change = temp-chk-gds.sum
          pychk_jj = pychk_jj + 1
          .
        end.
        ASSIGN
        temp-chk-gds.doc-code = chk-gds.doc-code
        temp-chk-gds.b-code = chk-gds.b-code
        temp-chk-gds.rec-type = 1
        temp-chk-gds.gds-type = 1
        temp-chk-gds.qnty = temp-chk-gds.qnty  + chk-gds.doc-qnty
        temp-chk-gds.sum  = temp-chk-gds.sum  + chk-gds.doc-qnty * (chk-gds.price-base - chk-gds.discnt + chk-gds.price-service)
        temp-chk-gds.sum-change = temp-chk-gds.sum
        temp-chk-gds.qnty2 = temp-chk-gds.qnty2 + ub.chk-gds.doc-qnty * pychk_density
        pychk_jjp = pychk_jjp + 1
        temp-chk-gds.jjp_  = pychk_jjp
        temp-chk-gds.jjo_  = 0
        .
      end.
    end.
    else do:
      find first temp-chk-gds where
                temp-chk-gds.b-code = chk-gds.b-code
           AND  temp-chk-gds.doc-code = chk-gds.doc-code
           and temp-chk-gds.rec-type = 0  no-error.
      IF AVAILABLE TEMP-CHK-GDS THEN DO:
        assign
        temp-chk-gds.qnty = temp-chk-gds.qnty  + chk-gds.DOC-qnty
        temp-chk-gds.sum  = temp-chk-gds.sum  + chk-gds.doc-qnty * (chk-gds.price-base - chk-gds.discnt + chk-gds.price-service)
        temp-chk-gds.qnty2 = temp-chk-gds.qnty2 + chk-gds.doc-qnty * pychk_density
        temp-chk-gds.sum-change = temp-chk-gds.sum
        .
      end.
      else do:
        find first temp-chk-gds where temp-chk-gds.jj_ = pychk_jj use-index ijj no-error.
        if not available temp-chk-gds then do:
          create temp-chk-gds.
          assign
          temp-chk-gds.jj_ = pychk_jj
          temp-chk-gds.qnty2 = 0
          temp-chk-gds.qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.sum-change = temp-chk-gds.sum
          pychk_jj = pychk_jj + 1
          .
        end.
        else do:
          assign
          pychk_jj = pychk_jj + 1
          temp-chk-gds.qnty2 = 0
          temp-chk-gds.qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.sum-change = temp-chk-gds.sum
          .
        end.
        ASSIGN
        temp-chk-gds.doc-code = chk-gds.doc-code
        temp-chk-gds.b-code = chk-gds.b-code
        temp-chk-gds.qnty = temp-chk-gds.qnty  + chk-gds.DOC-qnty
        temp-chk-gds.sum  = temp-chk-gds.sum  + chk-gds.doc-qnty * (chk-gds.price-base - chk-gds.discnt + chk-gds.price-service)
        temp-chk-gds.qnty2 = temp-chk-gds.qnty2 + chk-gds.doc-qnty * pychk_density
        temp-chk-gds.sum-change = temp-chk-gds.sum
        temp-chk-gds.rec-type = 0
        temp-chk-gds.gds-type =
                                  (if chk-doc.office = 'у':U then 3 else 2)
        pychk_jjo = pychk_jjo + 1
        temp-chk-gds.jjp_  = 0
        temp-chk-gds.jjo_  = pychk_jjo
        .
      end.
    end.
  END.
end.
FIND FIRST ub.cash-pay No-LOCK WHERE
          ub.cash-pay.cdpay-code = ub.chk-pay.pay-code AND
          ub.cash-pay.curr-code = ub.chk-pay.curr-code No-ERROR.
if available ub.cash-pay then do:
  find first temp-chk-pay where
          temp-chk-pay.line-num = chk-pay.line-num
      AND  temp-chk-pay.doc-code = chk-pay.doc-code  no-error.
  find first temp-chk-pay use-index pi where
          temp-chk-pay.line-num = chk-pay.line-num no-error.
  if not available temp-chk-pay then do:
    create temp-chk-pay.
  end.
  buffer-copy chk-pay to temp-chk-pay
  assign
  temp-chk-pay.pet-good = integer(cash-pay.atr64) * 2 + integer(cash-pay.is-cash)
  temp-chk-pay.obj-name = cash-pay.obj-name
  temp-chk-pay.is-cash  = cash-pay.is-cash
  temp-chk-pay.register = cash-pay.register
  .
end.
if last-of(chk-pay.doc-code) then do:
  for each temp-chk-pay where
          temp-chk-pay.doc-code = chk-pay.doc-code
  by temp-chk-pay.pet-good descending
  by temp-chk-pay.line-num:
    assign
    pychk_dop-sump = (if v-curr-r-b = 'rubl':U then temp-chk-pay.tot-rubl else temp-chk-pay.tot-base)
    pychk_exch = if pychk_No-exch then 1 else temp-chk-pay.tot-rubl / temp-chk-pay.tot-base
    pychk_exch-rubl = if pychk_No-exch-rubl then 1 else temp-chk-pay.tot-rubl / temp-chk-pay.tot-base
    .
    _repeat:
    REPEAT WHILE  abs(pychk_dop-sump) > 0 :
      if pychk_dop-sumg = 0 then do:
        assign
        pychk_kk = pychk_kk + 1
        .
        if pychk_kk >= pychk_jj then LEAVE _repeat.
        if pychk_kk <= pychk_jjp then
        find first temp-chk-gds where
                  temp-chk-gds.doc-code = chk-doc.doc-code
            AND  temp-chk-gds.jjp_ = pychk_kk no-error .
        else
        find first temp-chk-gds where
                  temp-chk-gds.doc-code = chk-doc.doc-code
            AND  temp-chk-gds.jjo_ = pychk_kk - pychk_jjp no-error .
        if not available temp-chk-gds or temp-chk-gds.sum = 0 then do:
          NEXT _repeat.
        end.
        assign
        pychk_dop-sumg = temp-chk-gds.sum
        .
      end.
      assign
      pychk_dop-sumk = min(abs(pychk_dop-sumg), abs(pychk_dop-sump))  * (if pychk_dop-sump > 0 then 1 else -1 )
      pychk_pay-sum = pychk_pay-sum - pychk_dop-sumk
      pychk_dop-sump = pychk_dop-sump - pychk_dop-sumk
      pychk_dop-sumg = pychk_dop-sumg - pychk_dop-sumk
      .
      FIND FIRST ub.bar-code No-LOCK WHERE
                ub.bar-code.b-code =  temp-chk-gds.b-code No-ERROR.
      IF NOT AVAIL ub.bar-code then NEXT _repeat.
      CASE temp-chk-gds.gds-type:
        WHEN 1   then do:
          if pychk_sheet2 then do:
            FIND FIRST treal-2 No-LOCK WHERE
                      treal-2.gds-code = ub.bar-code.gds-code AND
                      treal-2.cpay-code = temp-chk-pay.pay-code AND
                      treal-2.curr-code = temp-chk-pay.curr-code AND
                      treal-2.is-pay = yes
                      No-ERROR.
            IF NOT AVAIL treal-2 then do:
              FIND last b-treal-2 No-LOCK WHERE
                        b-treal-2.gds-code = ub.bar-code.gds-code use-index vi No-ERROR.
              run create-treal-2 in this-procedure (
                              INPUT ub.bar-code.gds-code,
                              INPUT temp-chk-pay.pay-code,
                              INPUT temp-chk-pay.curr-code,
                              INPUT 0,
                              INPUT 0,
                              INPUT 0,
                              INPUT temp-chk-pay.obj-name,
                              INPUT yes,
                              INPUT (if avail b-treal-2
                                    then b-treal-2.ii + 1
                                    else 1)
                              ) no-error.
            END.
            assign
            treal-2.netto = treal-2.netto + pychk_dop-sumk / pychk_exch
            treal-2.qnty1 = treal-2.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
            treal-2.qnty2 = treal-2.qnty2 + temp-chk-gds.qnty2 * ( pychk_dop-sumk / temp-chk-gds.sum )
            .
          end.
          if pychk_sheet8
          and ub.chk-doc.d-card <> '':U
          then do:
            if temp-chk-pay.register > 0 then do:
              if ub.chk-doc.cli-type = ?
              or ub.chk-doc.cli-code = ?
              or ub.chk-doc.cli-type = '':U
              or ub.chk-doc.cli-code = 0 then do:
                find first buf_dis-card no-lock where
                          buf_dis-card.d-card = ub.chk-doc.d-card no-error .
                if available buf_dis-card then do:
                  assign
                  v-cli-type = buf_dis-card.cli-type
                  v-cli-code = buf_dis-card.cli-code
                  .
                end.
              end.
              else do:
                assign
                v-cli-type = ub.chk-doc.cli-type
                v-cli-code = ub.chk-doc.cli-code
                .
              end.
              FIND FIRST treal-8 No-LOCK WHERE
                        treal-8.gds-code = ub.bar-code.gds-code
                    AND treal-8.cpay-code = 0
                    AND treal-8.curr-code = 0
                    AND treal-8.cli-type = v-cli-type
                    AND treal-8.cli-code = v-cli-code  No-ERROR.
              IF NOT AVAIL treal-8 then do:
                run create-treal-8 in this-procedure (
                                  INPUT ub.bar-code.gds-code
                                ,INPUT 0
                                ,INPUT 0
                                ,INPUT v-cli-type
                                ,INPUT v-cli-code
                                ,INPUT 0
                                ,input 0
                                ) no-error.
              END.
              assign
              treal-8.netto = treal-8.netto + pychk_dop-sumk / pychk_exch
              treal-8.qnty1 = treal-8.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
              treal-8.netto-rubl = treal-8.netto-rubl + pychk_dop-sumk * pychk_exch-rubl
              .
              FIND FIRST cp-gds-treal-8 No-LOCK WHERE
                        cp-gds-treal-8.gds-code = ub.bar-code.gds-code
                    AND cp-gds-treal-8.cpay-code = temp-chk-pay.pay-code
                    AND cp-gds-treal-8.curr-code = temp-chk-pay.curr-code
                    AND cp-gds-treal-8.cli-type = '':U
                    AND cp-gds-treal-8.cli-code = 0  No-ERROR.
              if not available cp-gds-treal-8 then do:
                run create-cp-gds-treal-8 in this-procedure (
                                  INPUT ub.bar-code.gds-code
                                ,INPUT temp-chk-pay.pay-code
                                ,INPUT temp-chk-pay.curr-code
                                ,INPUT '':U
                                ,INPUT 0
                                ,INPUT 0
                                ,input 0
                                ) no-error.
              end.
              assign
              cp-gds-treal-8.netto = cp-gds-treal-8.netto + pychk_dop-sumk / pychk_exch
              cp-gds-treal-8.qnty1 = cp-gds-treal-8.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
              cp-gds-treal-8.netto-rubl = cp-gds-treal-8.netto-rubl + pychk_dop-sumk * pychk_exch-rubl
              .
              FIND FIRST gds-treal-8 No-LOCK WHERE
                        gds-treal-8.gds-code = ub.bar-code.gds-code
                    AND gds-treal-8.cpay-code = 0
                    AND gds-treal-8.curr-code = 0
                    AND gds-treal-8.cli-type = '':U
                    AND gds-treal-8.cli-code = 0  No-ERROR.
              if not available gds-treal-8 then do:
                run create-gds-treal-8 in this-procedure (
                                  INPUT ub.bar-code.gds-code
                                ,INPUT 0
                                ,INPUT 0
                                ,INPUT '':U
                                ,INPUT 0
                                ,INPUT 0
                                ,input 0
                                ) no-error.
              end.
              assign
              gds-treal-8.netto = gds-treal-8.netto + pychk_dop-sumk / pychk_exch
              gds-treal-8.qnty1 = gds-treal-8.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
              gds-treal-8.netto-rubl = gds-treal-8.netto-rubl + pychk_dop-sumk * pychk_exch-rubl
              .
              FIND FIRST cp-treal-8 No-LOCK WHERE
                        cp-treal-8.gds-code = 0
                    AND cp-treal-8.cpay-code = temp-chk-pay.pay-code
                    AND cp-treal-8.curr-code = temp-chk-pay.curr-code
                    AND cp-treal-8.cli-type = '':U
                    AND cp-treal-8.cli-code = 0  No-ERROR.
              if not available cp-treal-8 then do:
                run create-cp-treal-8 in this-procedure (
                                  INPUT 0
                                ,INPUT temp-chk-pay.pay-code
                                ,INPUT temp-chk-pay.curr-code
                                ,INPUT '':U
                                ,INPUT 0
                                ,INPUT 0
                                ,input 0
                                ) no-error.
              end.
              assign
              cp-treal-8.netto = cp-treal-8.netto + pychk_dop-sumk / pychk_exch
              cp-treal-8.qnty1 = cp-treal-8.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
              cp-treal-8.netto-rubl = cp-treal-8.netto-rubl + pychk_dop-sumk * pychk_exch-rubl
              .
              FIND FIRST cli-treal-8 No-LOCK WHERE
                        cli-treal-8.gds-code = 0
                    AND cli-treal-8.cpay-code = 0
                    AND cli-treal-8.curr-code = 0
                    AND cli-treal-8.cli-type = v-cli-type
                    AND cli-treal-8.cli-code = v-cli-code  No-ERROR.
              if not available cli-treal-8 then do:
                run create-cli-treal-8 in this-procedure (
                                  INPUT 0
                                ,INPUT 0
                                ,INPUT 0
                                ,INPUT v-cli-type
                                ,INPUT v-cli-code
                                ,INPUT 0
                                ,input 0
                                ) no-error.
              end.
              assign
              cli-treal-8.netto = cli-treal-8.netto + pychk_dop-sumk / pychk_exch
              cli-treal-8.qnty1 = cli-treal-8.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
              cli-treal-8.netto-rubl = cli-treal-8.netto-rubl + pychk_dop-sumk * pychk_exch-rubl
              .
            end.
          end.
        END.
        WHEN 2  then do:
          if pychk_sheet3 then do:
            FIND FIRST ub.goods No-LOCK WHERE
                        ub.goods.gds-code = ub.bar-code.gds-code No-ERROR.
            IF NOT AVAIL ub.goods then NEXT _repeat.
            if pychk_classify then do:
              if pychk_selectgood then do:
                FIND FIRST buf_t-3 where
                          ub.goods.grp-name begins buf_t-3.serv-name No-ERROR.
                if not avail buf_t-3 then next _repeat .
              end.
            end.
            else dO:
              FIND FIRST t-3 where
                        ub.goods.grp-name begins t-3.serv-name No-ERROR.
              if not avail t-3 then next _repeat .
            end.
            if avail t-3  then do:
              FIND FIRST treal-3 No-LOCK WHERE
                        treal-3.grp-code = t-3.grp-code-sheet AND
                        treal-3.cpay-code = temp-chk-pay.pay-code AND
                        treal-3.curr-code = temp-chk-pay.curr-code
                        No-ERROR.
              IF NOT AVAIL treal-3 then do:
                FIND last b-treal-3 No-LOCK WHERE
                          b-treal-3.grp-code-sheet = t-3.grp-code-sheet use-index vi No-ERROR.
                run create-treal-3 in this-procedure (
                              INPUT t-3.grp-code-sheet,
                              INPUT temp-chk-pay.pay-code,
                              INPUT temp-chk-pay.curr-code,
                              INPUT 0,
                              INPUT 0,
                              INPUT temp-chk-pay.obj-name,
                              INPUT yes,
                              INPUT (if avail b-treal-3
                                    then b-treal-3.ii + 1
                                      else 1)
                                    ) no-error.
              END.
              assign
              treal-3.netto = treal-3.netto + pychk_dop-sumk / pychk_exch
              treal-3.qnty1 = treal-3.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
              .
            end.
          END.
        END.
        WHEN 3  then do:
          if pychk_sheet4 then do:
            FIND FIRST treal-4 No-LOCK WHERE
                      treal-4.gds-code = ub.bar-code.gds-code AND
                      treal-4.cpay-code = temp-chk-pay.pay-code AND
                      treal-4.curr-code = temp-chk-pay.curr-code AND
                      treal-4.is-pay = yes
                      No-ERROR.
            IF NOT AVAIL treal-4 then do:
              FIND last b-treal-4 No-LOCK WHERE
                        b-treal-4.gds-code = ub.bar-code.gds-code use-index vi No-ERROR.
              run create-treal-4  in this-procedure (
                              INPUT ub.bar-code.gds-code,
                              INPUT temp-chk-pay.pay-code,
                              INPUT temp-chk-pay.curr-code,
                              INPUT 0,
                              INPUT 0,
                              INPUT temp-chk-pay.obj-name,
                              INPUT yes,
                              INPUT (if avail b-treal-4
                                    then b-treal-4.ii + 1
                                    else 1)
                              ) no-error.
            END.
            assign
            treal-4.netto = treal-4.netto + pychk_dop-sumk / pychk_exch
            treal-4.qnty1 = treal-4.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
            .
            END.
        END.
      END CASE.
      if pychk_dop-sumg <= 0 then do:
        assign
        pychk_kk = pychk_kk + 1.
        if pychk_kk >= pychk_jj then LEAVE _repeat.
        if pychk_kk <= pychk_jjp then do:
          find first temp-chk-gds where
                    temp-chk-gds.doc-code = chk-doc.doc-code
              AND  temp-chk-gds.jjp_ = pychk_kk no-error .
        end.
        else do:
          find first temp-chk-gds where
                    temp-chk-gds.doc-code = chk-doc.doc-code
              AND  temp-chk-gds.jjo_ = pychk_kk - pychk_jjp no-error .
          if not available temp-chk-gds then do:
            LEAVE _repeat.
          end.
        end.
        pychk_dop-sumg = temp-chk-gds.sum.
        pychk_dop-sumg = temp-chk-gds.sum.
      end.
    END.
  end.
output close.
end.
END.
