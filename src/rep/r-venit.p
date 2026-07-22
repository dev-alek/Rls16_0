block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-venit.p $
$Archive: rep/r-venit.p $

Журнал поступивших нефтепродуктов за период

Специальный отчет для Румынии по закрытию отчетного периода

Автор: Суслов Алексей Юрьевич
Дата создания: 03/27/06
Author: Alexey Suslov
Creation date: 03/27/06

*/

define input parameter parparentproc      as widget-handle no-undo .
define input parameter parobj-type        like trn-doc.obj-type no-undo.
define input parameter parobj-code        like trn-doc.obj-code no-undo.
define input parameter pargdsgrp_recids   as char               no-undo. /*Список recid-ов групп по которым будет напечатан отчет*/
define input parameter pardate-shift      as integer            no-undo. /*1 - по календарным суткам,
                                                                           2 - по сменным суткам без указания смен,
                                                                           3 - по сменным суткам с указанием смены,
                                                                           4 - по конкретной смене в сменных сутках*/
define input parameter parstart_date      as date               no-undo.
define input parameter parstart_shift_num as integer            no-undo.
define input parameter parend_date        as date               no-undo.
define input parameter parend_shift_num   as integer            no-undo.
define input parameter parkind            as integer            no-undo.

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-venit.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-venit.p $":U .
def var vss-description as character no-undo init "Журнал поступивших нефтепродуктов за период".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i  }
{ gbl/waitfram.i }


define variable global-line-num   as integer   no-undo.
define variable global-line-print as character no-undo.
define variable vargds-grp-recids as recid no-undo.
define variable i as integer no-undo.
define variable varkind as integer no-undo.
{ str/in-vatp.i  def}
{ str/out-vatp.i def}
{ rep/sale-clc.i def     }
{ rep/sale-clc.i calc    }
{ rep/sale-clc.i calc-grp "terminal" }

&scop format-qnty  format ">>>,>>>,>>9.<<<"
&scop format-price format ">>>,>>9.99"
&scop format-summa format ">>>,>>>,>>>,>>9.99"
RUN calc-sale
  (INPUT parobj-type,
   INPUT parobj-code,
   INPUT pardate-shift,
   INPUT parstart_date,
   INPUT parend_date  ,
   INPUT parstart_shift_num,
   INPUT parend_shift_num).

find first clients where clients.obj-code = parobj-code and
                         clients.obj-type = parobj-type no-lock.
DEFINE FRAME gds-grp
      sym1                          column-label ":!:"      format "X(1)"       space(0)
      global-line-print             COLUMN-LABEL "Nr.crt"   format "x(10)"      space(0)
      sym2                          column-label ":!:"      format "X(1)"       space(0)
      tt-doc-line.artic             COLUMN-LABEL "Articol"                      space(0)
      sym3                          column-label ":!:"      format "X(1)"       space(0)
      tt-doc-line.gds-name          COLUMN-label "Explicatii"                   space(0)
      sym4                          column-label ":!:" format "X(1)"            space(0)
      tt-doc-line.gds-unit-base     column-label "UM"  format "X(3)"            space(0)
      sym5                          column-label ":!:" format "X(1)"            space(0)
      tt-doc-line.qnty              COLUMN-LABEL "cant."  {&format-qnty}        space(0)
      sym6                          column-label ":!:" format "X(1)"            space(0)
      tt-doc-line.increase          COLUMN-LABEL "Venit+Acciza" {&format-summa} space(0)
      sym7                          column-label ":!:" format "X(1)"            space(0)
      tt-doc-line.sum-road-tax      COLUMN-LABEL "Taxa drum"                    space(0)
      sym8                          column-label ":!:" format "X(1)"            space(0)
      tt-doc-line.sum-sale-out-vat  column-label "Val.vanzare fara TVA" {&format-summa} space(0)
      sym9                          column-label ":!:" format "X(1)" space(0)
      tt-doc-line.sum-vat-sale      COLUMN-LABEL "TVA" {&format-summa} space(0)
      sym10                         column-label ":!:" format "X(1)"         space(0)
      tt-doc-line.sum-sale          column-label "Total vanzare cu TVA" {&format-summa} space(0)
      sym11                         column-label ":!:" format "X(1)" space(0)
    HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Statia " + string(parobj-code) + " " + parobj-type + " " + clients.obj-name)   AT 40 format "X(40)"
        string( "Raport vanzare marfa si carburant la date de " + string(parstart_date) + (if parstart_shift_num <> ? then ":" + string(parstart_shift_num) else " ") + " " + string(parend_date) + (if parend_shift_num <> ? then ":" + string(parend_shift_num) else " ")) AT 85 format "X(87)"
        string( "Pagina " + string( PAGE-NUMBER( PrnLibStream ), ">>9" ) ) AT 180 format "X(13)" SKIP
        Line format "X(184)" AT 1
    with width {&DOS_CW_2} down stream-io.
if session:set-wait-state("COMPILER") then.
assign Line = fill("-", 184).
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

FORM with FRAME gds-grp.
FORM HEADER
    Line format "X(184)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 60 SKIP
    with FRAME BottomFrame width {&DOS_CW_2}
    PAGE-BOTTOM no-labels no-box.
VIEW STREAM PrnLibStream FRAME BottomFrame .
if trim(pargdsgrp_recids) = "" then do:
   message "Вы не выбрали группу товаров." view-as alert-box error.
   return error.
end.
DO i = 1 TO NUM-ENTRIES(pargdsgrp_recids):
   ASSIGN vargds-grp-recids = INTEGER(ENTRY(i, pargdsgrp_recids)).
   find first gds-grp where recid(gds-grp) = vargds-grp-recids no-lock no-error.
   if not available gds-grp then do:
     message "Ошибка при опрделении групп товаров." view-as alert-box.
     return error.
   end.
   CASE parkind:
      WHEN 1 THEN ASSIGN varkind = 4.
      WHEN 2 THEN ASSIGN varkind = 2.
      WHEN 3 THEN ASSIGN varkind = 5.
   END.
   assign varroot = gds-grp.node-code.
   RUN calc-gds-grp
     (input  varkind,
      input  gds-grp.node-code,
      input  " ",
      output varsum-vat-acc,
      output varsum-vat-sale,
      output varsum-acc-out-vat,
      output varsum-sale-out-vat,
      output varsum-sale,
      output varsum-road-tax,
      output varsum-qnty).
END.
HIDE STREAM PrnLibStream FRAME BottomFrame .
OUTPUT STREAM PrnLibStream CLOSE.
if session:set-wait-state("") then.
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).


PROCEDURE disp-tt-doc-line:
    assign  global-line-num = global-line-num + 1.
    display stream PrnLibStream
      sym1                          column-label ":!:" format "X(1)"            space(0)
      string(global-line-num) @     global-line-print
                                    COLUMN-LABEL "Nr.crt"   format "x(10)"      space(0)
      sym2                          column-label ":!:"      format "X(1)"       space(0)
      tt-doc-line.artic             COLUMN-LABEL "Articol"                      space(0)
      sym3                          column-label ":!:"      format "X(1)"       space(0)
      tt-doc-line.gds-name          COLUMN-label "Explicatii"                   space(0)
      sym4                          column-label ":!:" format "X(1)"            space(0)
      tt-doc-line.gds-unit-base     column-label "UM"  format "X(3)"            space(0)
      sym5                          column-label ":!:" format "X(1)"            space(0)
      tt-doc-line.qnty              COLUMN-LABEL "cant."  {&format-qnty}        space(0)
      sym6                          column-label ":!:" format "X(1)"            space(0)
      tt-doc-line.increase          COLUMN-LABEL "Venit+Acciza" {&format-summa} space(0)
      sym7                          column-label ":!:" format "X(1)"            space(0)
      tt-doc-line.sum-road-tax      COLUMN-LABEL "Taxa drum"                    space(0)
      sym8                          column-label ":!:" format "X(1)"            space(0)
      tt-doc-line.sum-sale-out-vat  column-label "Val.vanzare fara TVA" {&format-summa} space(0)
      sym9                          column-label ":!:" format "X(1)" space(0)
      tt-doc-line.sum-vat-sale      COLUMN-LABEL "TVA" {&format-summa} space(0)
      sym10                         column-label ":!:" format "X(1)"         space(0)
      tt-doc-line.sum-sale          column-label "Total vanzare cu TVA" {&format-summa} space(0)
      sym11                         column-label ":!:" format "X(1)" space(0)
      with frame gds-grp.
DOWN STREAM PrnLibStream 1 with FRAME gds-grp.
PUT STREAM PrnLibStream Line format "X(184)" SKIP.
END PROCEDURE.

PROCEDURE disp-total:
define input parameter pardispgrp-name         as   character             no-undo.
define input parameter pardispsum-vat-acc      like doc-line.price-rubl   no-undo.
define input parameter pardispsum-vat-sale     like doc-line.price-rubl   no-undo.
define input parameter pardispsum-acc-out-vat  like doc-line.price-rubl   no-undo.
define input parameter pardispsum-sale-out-vat like doc-line.price-rubl   no-undo.
define input parameter pardispsum-sale         like doc-line.price-rubl   no-undo.
define input parameter pardispsum-road-tax     like doc-line.price-rubl   no-undo.
define input parameter pardispsum-qnty         like doc-line.fact-qnty    no-undo.
/*Не будем печатать в этом отчете нетерминальные группы*/
display stream PrnLibStream
      sym1                          column-label ":!:" format "X(1)"            space(0)
      "TOTAL" @ global-line-print   COLUMN-LABEL "Nr.crt"   format "x(10)"      space(0)
      sym2                          column-label ":!:"      format "X(1)"       space(0)
      sym3                          column-label ":!:"      format "X(1)"       space(0)
      pardispgrp-name         @
      tt-doc-line.gds-name          COLUMN-label "Explicatii"                   space(0)
      sym4                          column-label ":!:" format "X(1)"            space(0)
      sym5                          column-label ":!:" format "X(1)"            space(0)
      pardispsum-qnty         @
      tt-doc-line.qnty              COLUMN-LABEL "cant."  {&format-qnty}        space(0)
      sym6                          column-label ":!:" format "X(1)"            space(0)
      pardispsum-sale     -
      pardispsum-vat-sale -
      pardispsum-road-tax     @
      tt-doc-line.increase          COLUMN-LABEL "Venit+Acciza" {&format-summa} space(0)
      sym7                          column-label ":!:" format "X(1)"            space(0)
      pardispsum-road-tax     @
      tt-doc-line.sum-road-tax      COLUMN-LABEL "Taxa drum"                    space(0)
      sym8                          column-label ":!:" format "X(1)"            space(0)
      pardispsum-sale-out-vat @
      tt-doc-line.sum-sale-out-vat  column-label "Val.vanzare fara TVA" {&format-summa} space(0)
      sym9                          column-label ":!:" format "X(1)" space(0)
      pardispsum-vat-sale     @
      tt-doc-line.sum-vat-sale       COLUMN-LABEL "TVA" {&format-summa} space(0)
      sym10                         column-label ":!:" format "X(1)"         space(0)
      pardispsum-sale         @
      tt-doc-line.sum-sale          column-label "Total vanzare cu TVA" {&format-summa} space(0)
      sym11                         column-label ":!:" format "X(1)" space(0)
with frame gds-grp.
DOWN STREAM PrnLibStream 1 with FRAME gds-grp.
PUT STREAM PrnLibStream Line format "X(184)" SKIP.
END PROCEDURE.
PROCEDURE disp-grp-name:
define input parameter pargrp-name like goods.grp-name no-undo.
display stream PrnLibStream
      sym1                          column-label ":!:"      format "X(1)"   space(0)
      "ГРУППА" @ global-line-print  COLUMN-LABEL "Nr.crt"   format "x(10)"  space(0)
      sym2                          column-label ":!:"      format "X(1)"   space(0)
      sym3                          column-label ":!:"      format "X(1)"   space(0)
      pargrp-name             @
      tt-doc-line.gds-name          COLUMN-label "Explicatii"               space(0)
      sym4                          column-label ":!:" format "X(1)"        space(0)
      sym5                          column-label ":!:" format "X(1)"        space(0)
      sym6                          column-label ":!:" format "X(1)"        space(0)
      sym7                          column-label ":!:" format "X(1)"        space(0)
      sym8                          column-label ":!:" format "X(1)"        space(0)
      sym9                          column-label ":!:" format "X(1)"        space(0)
      sym10                         column-label ":!:" format "X(1)"        space(0)
      sym11                         column-label ":!:" format "X(1)"        space(0)
with frame gds-grp.
DOWN STREAM PrnLibStream 1 with FRAME gds-grp.
PUT STREAM PrnLibStream Line format "X(184)" SKIP.
END PROCEDURE.