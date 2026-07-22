block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-cligrp.p $
$Archive: rep/r-cligrp.p $

Список групп клиентов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-cli-grp-recid    as  recid no-undo.
define input parameter p-print-option as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-cligrp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-cligrp.p $":U .
define variable vss-description as character no-undo init "Список групп клиентов".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ gbl/cur-time.i    }
{ cmp/r-pril.i new  }
{ gbl/prn-lib.i }
{ ref/cgrplib.i      }

do
on error undo, return error
:

define temp-table temp_clients no-undo
field obj-type as character
field obj-code as integer
field full-grp-name  as character
field cli-name  as character
index pi    is primary unique obj-type obj-code
index grp full-grp-name
.

define variable grp-path    like ub.clients.grp-name  no-undo.

define variable v-line              as character         no-undo.
define variable v-status            as character         no-undo.
define variable v-node-name         as character         no-undo.
define variable v-d-pcnt            as decimal           no-undo.
define variable v-start-node-name   as character     no-undo.
define variable v-is-terminal       as logical       no-undo.

define variable sym1 as character  init ":"   no-undo.
define variable sym2 as character  init ":"   no-undo.
define variable sym3 as character  init ":"   no-undo.
define variable sym4 as character  init ":"   no-undo.
define variable sym5 as character  init ":"   no-undo.

/*define variable i as integer no-undo .*/

define buffer buf_start_cli-grp for ub.cli-grp.
define buffer buf_cli-grp       for ub.cli-grp.
define buffer buf_clients         for ub.clients.


&SCOPED-define     cliList-Rptwidth    94

define frame cliListRpt
sym1 column-label ":" format "x(1)"
buf_clients.obj-name column-label "Наименование" format "x(50)"
sym2 column-label ":" format "x(1)"
buf_clients.obj-type column-label "Тип" format "x(8)"
sym3 column-label ":" format "x(1)"
buf_clients.obj-code column-label "Код" format "999999999"
sym4 column-label ":" format "x(1)"
v-status column-label "Статус" format "x(14)"
sym5 column-label ":" format "x(1)"
header
cur-time-print() at 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream )  , ">>>>9") ) at 54 format "X(17)" skip
v-line format "X({&cliList-Rptwidth})" at 1
with width {&DOS_CW} down stream-io use-text .

define frame frmgrp
v-node-name column-label "Название"  format "X(122)"
v-d-pcnt column-label " Скидка " format ">9.99%"
with width {&A4_CW} down stream-io use-text no-labels no-box .

find first buf_start_cli-grp no-lock
     where recid( buf_start_cli-grp ) = p-cli-grp-recid
.
run cli-grplib-get-full-name in this-procedure( input buf_start_cli-grp.node-code, output grp-path ).

{ gbl/working.i }

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


assign
v-line = fill( "-", {&cliList-Rptwidth} )
.
put stream PrnLibStream space(20) "СПИСОК  ГРУПП  КЛИЕНТОВ." format "x(30)" skip(1).
form header
v-line format "X({&cliList-Rptwidth})"
skip "Продолжение - на следующей странице" at 30
skip
with frame cliBottomframe
width {&DOS_CW}
page-bottom
no-labels
no-box
.
run cgrplib-find-all-subgroup in this-procedure (
          input buf_start_cli-grp.node-code
        , input no
).
if p-print-option = "terminal":U
then do:
    view stream PrnLibStream frame clibottomframe .
    run cgrplib-is-terminal in this-procedure (
          input buf_start_cli-grp.node-code
        , output v-is-terminal
    ).
    if v-is-terminal = yes then do:
        put stream PrnLibStream
            space(2) string( "Группа: " + grp-path ) format "X(80)"
            skip
            v-line format "X({&cliList-Rptwidth})"
            skip
        .
        view stream PrnLibStream frame cliListRpt.
        for each buf_clients no-lock
           where buf_clients.grp-code = buf_start_cli-grp.node-code
        on error undo, return error
        :
            display stream PrnLibStream
            sym1 buf_clients.obj-name
            sym2 buf_clients.obj-type
            sym3 buf_clients.obj-code
            sym4
            "--- УДАЛЕН ---" when buf_clients.stts <> 0 @ v-status
            with frame cliListRpt.
            down stream PrnLibStream 1 with frame cliListRpt .
        end.        /* for each buf_goods */
        put stream PrnLibStream
        v-line format "X({&cliList-Rptwidth})"
        skip
        .
    end. /*if terminal*/
    for each temp_cgrplib_found-grp
       where temp_cgrplib_found-grp.is-terminal = yes
    :
        down stream PrnLibStream 1 with frame cliListRpt .
        put stream PrnLibStream
            space(2) string( "Группа: " + temp_cgrplib_found-grp.full-name ) format "X(80)"
            skip
            v-line format "X({&cliList-Rptwidth})"
            skip
        .
        for each buf_clients no-lock
           where buf_clients.grp-code = temp_cgrplib_found-grp.node-code
        on error undo, return error
        :
            display stream PrnLibStream
            sym1 buf_clients.obj-name
            sym2 buf_clients.obj-type
            sym3 buf_clients.obj-code
            sym4
            "--- УДАЛЕН ---" when buf_clients.stts <> 0 @ v-status
            with frame cliListRpt.
            down stream PrnLibStream 1
            with frame cliListRpt .
        end.        /* for each buf_goods */
        put stream PrnLibStream
        v-line format "X({&cliList-Rptwidth})"
        skip
        .
    end.
    hide stream PrnLibStream frame cliBottomframe .
    put stream PrnLibStream
    v-line format "X({&cliList-Rptwidth})" skip.
end.
else do:
    form with frame frmgrp .
    display stream PrnLibStream
    grp-path @ v-node-name
    with frame frmgrp .
    down stream PrnLibStream 1 with frame frmgrp .
    for each temp_cgrplib_found-grp
    :
        display stream PrnLibStream
        temp_cgrplib_found-grp.full-name     @ v-node-name
        temp_cgrplib_found-grp.d-pcnt        @ v-d-pcnt
        with frame frmgrp .
        down stream PrnLibStream 1 with frame frmgrp .
    end.
    hide stream PrnLibStream frame cliBottomframe .
end.

{ gbl/stopwork.i }

output stream PrnLibStream close.

run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).


end.