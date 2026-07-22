block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-gdsggr.p $
$Archive: rep/r-gdsggr.p $

Список групп блюд

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Input:

Output:

*/
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define input parameter p-fbr-gds-grp-recid  as  recid no-undo.
define input parameter p-print-option       as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-gdsggr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-gdsggr.p $":U .
define variable vss-description as character no-undo init "Список групп блюд".
{ cmp/vssrevis.i    }
{ cmp/trg-def.i    }
{ gbl/cur-time.i    }
{ cmp/r-pril.i new  }
{ ref/fbrglib.i     }
{ gbl/prn-lib.i }

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

define variable grp-path    like clients.grp-name  no-undo.

define variable v-line              as character         no-undo.
define variable v-status            as character         no-undo.
define variable v-node-name         as character         no-undo.
define variable v-start-node-name   as character     no-undo.
define variable v-is-terminal       as logical       no-undo.

define variable sym1 as character  init ":"   no-undo.
define variable sym2 as character  init ":"   no-undo.
define variable sym3 as character  init ":"   no-undo.
define variable sym4 as character  init ":"   no-undo.

define variable i           as integer no-undo .
define variable v-gds-name  as character      no-undo.
define variable v-artic     as character      no-undo.

define buffer buf_start_fbr-gds-grp for fbr-gds-grp.
define buffer buf_fbr-gds-grp       for fbr-gds-grp.
define buffer buf_fbr-gds-obj       for fbr-gds-obj.
define buffer buf_goods             for goods.


&SCOPED-define     GdsList-Rptwidth    82

define frame GdsListRpt
    sym1 column-label ":" format "x(1)"
    v-gds-name column-label "Наименование" format "x(50)"
    sym2 column-label ":" format "x(1)"
    v-artic column-label "Артикул" format "x(16)"
    sym3 column-label ":" format "x(1)"
    v-status column-label "Статус" format "x(5)"
    sym4 column-label ":" format "x(1)"
    header
        cur-time-print() at 5 format "X(35)"
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream )  , ">>>>9") ) at 54 format "X(17)" skip
        v-line format "X({&GdsList-Rptwidth})" at 1
with width {&DOS_CW} down stream-io use-text .

define frame frmgrp
    v-node-name   format "X(130)"
    with width {&A4_CW} down stream-io use-text no-labels no-box .

find first buf_start_fbr-gds-grp no-lock
     where recid( buf_start_fbr-gds-grp ) = p-fbr-gds-grp-recid
.
run fbrglib-get-full-name in this-procedure(
      input p-obj-type
    , input p-obj-code
    , input buf_start_fbr-gds-grp.node-code
    , output grp-path
).
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
put stream PrnLibStream space(20) "СПИСОК  ГРУПП  БЛЮД." format "x(30)" skip(1).
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
run fbrglib-find-all-subgroup in this-procedure (
      input p-obj-type
    , input p-obj-code
    , input buf_start_fbr-gds-grp.node-code
    , input no
).
if p-print-option = "terminal":U
then do:
    view stream PrnLibStream frame gdsbottomframe .
    run fbrglib-is-terminal in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input buf_start_fbr-gds-grp.node-code
        , output v-is-terminal
    ).
    if v-is-terminal = yes then do:
        put stream PrnLibStream
            space(2) string( "Группа: " + grp-path ) format "X(80)"
            skip
            v-line format "X({&GdsList-Rptwidth})"
            skip
        .
        view stream PrnLibStream frame GdsListRpt.
        for each buf_fbr-gds-obj no-lock
           where buf_fbr-gds-obj.obj-type       = p-obj-type
             and buf_fbr-gds-obj.obj-code       = p-obj-code
             and buf_fbr-gds-obj.fbr-grp-code   = buf_start_fbr-gds-grp.node-code
        on error undo, return error
        :
            find first buf_goods no-lock
                 where buf_goods.gds-code = buf_fbr-gds-obj.gds-code
            .
            assign
                v-gds-name = buf_goods.gds-name
                v-artic    = buf_goods.artic
            .
            display stream PrnLibStream
                sym1 v-gds-name
                sym2 v-artic
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
    for each temp_fbrglib_found-grp
       where temp_fbrglib_found-grp.is-terminal = yes
    :
        down stream PrnLibStream 1 with frame GdsListRpt .
        put stream PrnLibStream
            space(2) string( "Группа: " + temp_fbrglib_found-grp.full-name ) format "X(80)"
            skip
            v-line format "X({&GdsList-Rptwidth})"
            skip
        .
        for each buf_fbr-gds-obj no-lock
           where buf_fbr-gds-obj.obj-type       = p-obj-type
             and buf_fbr-gds-obj.obj-code       = p-obj-code
             and buf_fbr-gds-obj.fbr-grp-code   = temp_fbrglib_found-grp.node-code
        on error undo, return error
        :
            find first buf_goods no-lock
                 where buf_goods.gds-code = buf_fbr-gds-obj.gds-code
            .
            assign
                v-gds-name = buf_goods.gds-name
                v-artic    = buf_goods.artic
            .
            display stream PrnLibStream
                sym1 v-gds-name
                sym2 v-artic
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
    grp-path @ v-node-name
    with frame frmgrp .
    down stream PrnLibStream 1 with frame frmgrp .
    for each temp_fbrglib_found-grp
    :
        display stream PrnLibStream
            temp_fbrglib_found-grp.full-name     @ v-node-name
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