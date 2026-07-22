block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-gdsgrp.p $
$Archive: rep/r-gdsgrp.p $

Список групп товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-gds-grp-recid    as  recid no-undo.
define input parameter p-print-option as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-gdsgrp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-gdsgrp.p $":U .
define variable vss-description as character no-undo init "Список групп товаров".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ gbl/cur-time.i    }
{ cmp/r-pril.i new  }
{ gbl/prn-lib.i     }
{ ref/grplib.i      }

do
on error undo, return error
:

define temp-table temp_goods no-undo
    field gds-code  as integer
    field artic     as character
    field prod-type as character
    field prod-code as integer
    field full-grp-name  as character
    field gds-name  as character
    index pi    is primary unique gds-code
    index apc   is unique artic prod-type prod-code
    index grp full-grp-name
.

define variable grp-path    like ub.clients.grp-name  no-undo.

define variable v-line              as character         no-undo.
define variable v-status            as character         no-undo.
define variable v-node-name         as character         no-undo.
define variable v-node-code         as integer           no-undo.
define variable v-start-node-name   as character     no-undo.
define variable v-is-terminal       as logical       no-undo.

define variable sym1 as character  init ":"   no-undo.
define variable sym2 as character  init ":"   no-undo.
define variable sym3 as character  init ":"   no-undo.
define variable sym4 as character  init ":"   no-undo.

define variable i as integer no-undo .

define buffer buf_start_gds-grp for ub.gds-grp.
define buffer buf_gds-grp       for ub.gds-grp.
define buffer buf_goods         for ub.goods.

&SCOPED-define     GdsList-Rptwidth    120

define frame GdsListRpt
    sym1 column-label ":" format "x(1)"
    buf_goods.gds-name column-label "Наименование" format "x(50)"
    sym2 column-label ":" format "x(1)"
    buf_goods.artic column-label "Артикул" format "x(16)"
    sym3 column-label ":" format "x(1)"
    v-status column-label "Статус" format "x(5)"
    sym4 column-label ":" format "x(1)"
    header
        cur-time-print() at 5 format "X(35)"
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream )  , ">>>>9") ) at 54 format "X(17)" skip
        v-line format "X({&GdsList-Rptwidth})" at 1
with width {&DOS_CW} down stream-io use-text .

define frame frmgrp
    v-node-code   format ">>>>>>>>>9" space(2)
    v-node-name   format "X(170)"
    with width {&A4_LS} down stream-io use-text no-labels no-box .

find first buf_start_gds-grp no-lock
     where recid( buf_start_gds-grp ) = p-gds-grp-recid
.
run grplib-get-full-name in this-procedure( input buf_start_gds-grp.node-code, output grp-path ).

{ gbl/working.i }

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


assign
    v-line = fill( "-", {&GdsList-Rptwidth} )
.
put stream PrnLibStream space(20) "СПИСОК  ГРУПП  ТОВАРОВ." format "x(30)" skip(1).
form header
    v-line format "X({&GdsList-Rptwidth})"
    skip "Продолжение - на следующей странице" at 30
    skip
with frame GdsBottomframe
width {&DOS_CW}
page-bottom
no-labels
no-box
.
run grplib-find-all-subgroup in this-procedure (
          input buf_start_gds-grp.node-code
        , input no
).
if p-print-option = "terminal":U
then do:
    view stream PrnLibStream frame gdsbottomframe .
    run grplib-is-terminal in this-procedure (
          input buf_start_gds-grp.node-code
        , output v-is-terminal
    ).
    if v-is-terminal = yes then do:
        put stream PrnLibStream
            space(2) string( "Группа: " + grp-path ) format "X(180)"
            skip
            v-line format "X({&GdsList-Rptwidth})"
            skip
        .
        view stream PrnLibStream frame GdsListRpt.
        for each buf_goods no-lock
           where buf_goods.grp-code = buf_start_gds-grp.node-code
        on error undo, return error
        :
            display stream PrnLibStream
                sym1 buf_goods.gds-name
                sym2 buf_goods.artic
                sym3 "УДАЛЕН" when buf_goods.stts <> 0      @ v-status
                sym4
            with frame GdsListRpt.
            down stream PrnLibStream 1 with frame GdsListRpt .
        end.        /* for each buf_goods */
        put stream PrnLibStream
            v-line format "X({&GdsList-Rptwidth})"
            skip
        .
    end. /*if terminal*/
    for each temp_grplib_found-grp
       where temp_grplib_found-grp.is-terminal = yes
    :
        down stream PrnLibStream 1 with frame GdsListRpt .
        put stream PrnLibStream
            space(2) string( "Группа: " + temp_grplib_found-grp.full-name ) format "X(180)"
            skip
            v-line format "X({&GdsList-Rptwidth})"
            skip
        .
        for each buf_goods no-lock
           where buf_goods.grp-code = temp_grplib_found-grp.node-code
        on error undo, return error
        :
            display stream PrnLibStream
                sym1 buf_goods.gds-name
                sym2 buf_goods.artic
                sym3 "УДАЛЕН" when buf_goods.stts <> 0      @ v-status
                sym4
            with frame GdsListRpt.
            down stream PrnLibStream 1 with frame GdsListRpt .
        end.        /* for each buf_goods */
        put stream PrnLibStream
            v-line format "X({&GdsList-Rptwidth})"
            skip
        .
    end.
    hide stream PrnLibStream frame GdsBottomframe .
    put stream PrnLibStream v-line format "X({&GdsList-Rptwidth})" skip.
end.
else do:
    form with frame frmgrp .
    display stream PrnLibStream
    buf_start_gds-grp.node-code @ v-node-code
    grp-path                    @ v-node-name
    with frame frmgrp .
    down stream PrnLibStream 1 with frame frmgrp .
    for each temp_grplib_found-grp
    :
        display stream PrnLibStream
            temp_grplib_found-grp.node-code     @ v-node-code
            temp_grplib_found-grp.full-name     @ v-node-name
        with frame frmgrp .
        down stream PrnLibStream 1 with frame frmgrp .
    end.
    hide stream PrnLibStream frame GdsBottomframe .
end.

{ gbl/stopwork.i }

output stream PrnLibStream close.

run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).


end.