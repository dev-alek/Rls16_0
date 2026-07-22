block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: torg-tov.p $
$Archive: rep/torg-tov.p $

Товарная накладная. Приложение к документу по перемещению товара

Автор: Демин Алексей Сергеевич
Дата создания: 09/15/05
Author: Alexey Demin
Creation date: 09/15/05

Input:

Output:

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-trn-doc-recid      as recid            no-undo.

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: torg-tov.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/torg-tov.p $":U .
def var vss-description as character no-undo init "Товарная накладная. Приложение к документу по перемещению товара".
{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/library.i         }
{ cmp/r-pril.i          }
{ rep/p-fmt.i           }
{ rep/r-getsum.i        }
{ str/getctxtp.i def    }

&scop left-margin 5
&scop right-margin 130
&scop max-width 124
&scop tab-stop1 34
&scop max-width-from-tab1 101
&scop tab-stop2 50
&scop max-width-from-tab2 70
&scop tab-stop3 70
&scop tab-stop4 100

/*----S----- Таблица --------------------------------*/
&GLOB P-S 5
&GLOB P-X 130        /*длина линии*/
&GLOB P-X0 128       /*длина внутренней линии = длина линии - 2*/
&GLOB P-C3-X  79     /*ширина колонки названия товара*/

&GLOB P-C2-S  {&P-S} + 11        /* Код             */
&GLOB P-C3-S  {&P-S} + 28        /* Артикул         */
&GLOB P-C4-S  {&P-S} + 108        /* Название товара */
&GLOB P-C5-S  {&P-S} + 118       /* ЕИ              */
&GLOB P-E     {&P-S} + 130       /* Количество      */
/*----E----- Таблица --------------------------------*/

do
on error undo, return error
:

def shared var CostPrice    as logical          no-undo.
def shared var PrintScale   as logical              no-undo.
def shared var sort-name    as logical              no-undo.
def shared var sort-gr      as logical              no-undo.

def stream out-stream .

def buffer buf_trn-doc          for trn-doc.
def buffer buf_goods            for goods.
def buffer buf_clients          for clients.
def buffer buf_doc-line         for doc-line.
def buffer buf_gds-dtl          for gds-dtl.
def buffer buf_gds-prt          for gds-prt.

define variable v-line-counter      as integer                  no-undo.
define variable v-single-line       as character                no-undo.

define variable v-cli-name          as character                no-undo.
define variable v-obj-name          as character                no-undo.
define variable v-income            as logical                  no-undo.  /* yes - приход */
define variable v-prt-name          as character                no-undo.

define variable v-pg-sum-qnty       like doc-line.fact-qnty     no-undo.
define variable v-tot-sum-qnty      like doc-line.fact-qnty     no-undo.

define variable v-host-code         like sysconf.host-code      no-undo.

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).

find first buf_trn-doc no-lock where recid(buf_trn-doc) = p-trn-doc-recid.

{ gbl/hostcode.i buf_trn-doc.obj-type buf_trn-doc.obj-code v-host-code }

find first buf_clients no-lock
     where buf_clients.obj-type = buf_trn-doc.obj-type
       and buf_clients.obj-code = buf_trn-doc.obj-code
.
assign
        v-obj-name = string(buf_clients.obj-name)
.
find first buf_clients no-lock
     where buf_clients.obj-type = buf_trn-doc.cli-type
       and buf_clients.obj-code = buf_trn-doc.cli-code
.
if available buf_clients
then do:
    assign
        v-cli-name = string(buf_clients.obj-name)
    .
end.
else do:
    assign
        v-cli-name = ""
    .
end.

assign
    v-income = ( if buf_trn-doc.doc-type = {&income} or buf_trn-doc.doc-type = {&return} then yes else no )
    v-single-line       = fill("-", 230)
    v-line-counter      = 0
.

{ cmp/open-out.i stream out-stream " " {&CS_PS} }

form header
    v-single-line format "X({&P-X})" at 1 SKIP
    "Продолжение - на следующей странице" at 30 SKIP
    with frame BottomFrame width {&A4_CW0} PAGE-BOTTOM NO-LABELS NO-BOX .
view stream out-stream frame BottomFrame .

find first buf_clients no-lock
     where buf_clients.obj-type = {&cmp}
       and buf_clients.obj-code = v-host-code
.

{ gbl/working.i }

put stream out-stream
    skip (1) space( {&tab-stop1} )
    "Товарная накладная к документу. Тип: "
.

put stream out-stream
       buf_trn-doc.doc-type                                     format "X(20)"
       "   Номер: "
       buf_trn-doc.doc-code                                     format "X(14)"
       "   Дата: "
       string(buf_trn-doc.doc-date)                             format "X(10)"
       ( if buf_trn-doc.status_ <> {&fact} then "   Статус: " + caps(buf_trn-doc.status_) else " " )
                                                                format "X(25)"
    skip space( {&tab-stop1} ) "Поставщик (отправитель): "
        (if v-income = yes then v-cli-name else v-obj-name )    format "X(60)"
    skip space( {&tab-stop1} ) "Покупатель (получатель): "
        (if v-income = yes then v-obj-name else v-cli-name )    format "X(60)"
.
if buf_trn-doc.PS <> ?
and trim( buf_trn-doc.PS ) <> ""
and substring( buf_trn-doc.PS, 1, 1 ) <> "@"
then do:
    put stream out-stream
        skip space( {&tab-stop1} ) string( "Примечание:              "
            + substring( buf_trn-doc.PS, 1, {&max-width-from-tab1} - 25 ) )  format "X({&max-width-from-tab1})"
        skip space( {&tab-stop1} )
            substring( buf_trn-doc.PS, {&max-width-from-tab1} - 25 + 1, {&max-width-from-tab1} ) format "X({&max-width-from-tab1})"
        skip space( {&tab-stop1} )
            substring( buf_trn-doc.PS, {&max-width-from-tab1} - 25 + {&max-width-from-tab1} + 1, {&max-width-from-tab1} ) format "X({&max-width-from-tab1})"
    .
end.
put stream out-stream
    skip
    space({&P-S})       v-single-line   format "X({&P-X})"
    skip space({&P-S})  "|"
        "Код"               at center-field({&P-S} + 1, {&P-C2-S}, 3)
        "|"                 at {&P-C2-S}
        "Артикул"           at center-field({&P-C2-S}, {&P-C3-S}, 7)
        "|"                 at {&P-C3-S}
        "Название товара"   at center-field({&P-C3-S}, {&P-C4-S}, 15)
        "|"                 at {&P-C4-S}
        "Ед.Изм."           at center-field({&P-C4-S}, {&P-C5-S}, 7)
        "|"                 at {&P-C5-S}
        "Количество"        at center-field({&P-C5-S}, {&P-E}, 10)
        "|"                 at {&P-E}
    skip space({&P-S})
        "|" v-single-line format "X({&P-X0})" "|"
.
assign
    v-pg-sum-qnty       = 0
    v-tot-sum-qnty      = 0
.

if sort-gr = yes
then do:
    if sort-name = yes
    then do:
        for each buf_doc-line no-lock
        where buf_doc-line.doc-code = buf_trn-doc.doc-code
        , first buf_goods no-lock
        where buf_goods.artic      = buf_doc-line.artic
            and buf_goods.prod-type  = buf_doc-line.prod-type
            and buf_goods.prod-code  = buf_doc-line.prod-code
        break by buf_goods.grp-name
              by buf_goods.gds-name
        :
            if first-of( buf_goods.grp-name )
            then do:
                if not first ( buf_goods.grp-name )
                then do:
                    put stream out-stream
                        skip space({&P-S})
                            "|" v-single-line format "X({&P-X0})" "|"
                    .
                end.
                run print-group-line in this-procedure .
            end.
            run print-line in this-procedure .
        end.
    end.
    else do:
        for each buf_doc-line no-lock
        where buf_doc-line.doc-code = buf_trn-doc.doc-code
        , first buf_goods no-lock
        where buf_goods.artic      = buf_doc-line.artic
            and buf_goods.prod-type  = buf_doc-line.prod-type
            and buf_goods.prod-code  = buf_doc-line.prod-code
        break by buf_goods.grp-name
              by buf_goods.artic
        :
            if first-of( buf_goods.grp-name )
            then do:
                if not first ( buf_goods.grp-name )
                then do:
                    put stream out-stream
                        skip space({&P-S})
                            "|" v-single-line format "X({&P-X0})" "|"
                    .
                end.
                run print-group-line in this-procedure .
            end.
            run print-line in this-procedure .
        end.
    end.
end.        /* sort-gr = yes  */
else do:
    if sort-name = yes
    then do:
        for each buf_doc-line no-lock
        where buf_doc-line.doc-code = buf_trn-doc.doc-code
        , first buf_goods no-lock
        where buf_goods.artic      = buf_doc-line.artic
            and buf_goods.prod-type  = buf_doc-line.prod-type
            and buf_goods.prod-code  = buf_doc-line.prod-code
        break by buf_goods.gds-name
        :
            run print-line in this-procedure .
        end.
    end.
    else do:
        for each buf_doc-line no-lock
        where buf_doc-line.doc-code = buf_trn-doc.doc-code
        , first buf_goods no-lock
        where buf_goods.artic      = buf_doc-line.artic
            and buf_goods.prod-type  = buf_doc-line.prod-type
            and buf_goods.prod-code  = buf_doc-line.prod-code
        break by buf_goods.artic
        :
            run print-line in this-procedure .
        end.
    end.
end.        /* sort-gr = no  */

if v-pg-sum-qnty <> 0
then do:
        run print-page-result in this-procedure .
end.
if line-counter( Out-Stream ) + 8 > page-size( Out-Stream )
then do:
    page stream Out-Stream .
end.
run print-total-result in this-procedure .

hide stream Out-Stream frame BottomFrame .

run print-note in this-procedure .


{ gbl/stopwork.i }

output stream out-stream close.

{ rep/q-print.i 4 }

end.














/*==========================================================================*/
procedure print-line :
do
on error undo, return error
:
    find first buf_gds-prt no-lock
         where buf_gds-prt.upper-code = buf_goods.prt-root
    .
    if PrintScale = yes
        and ( buf_gds-prt.node-name <> {&empty-scale} )
        and v-cntxp-doc-prt = yes /* не пустая шкала и надо печатать по шкалам */
    then do:
        put stream out-stream
            skip space({&P-S})  "|"
                string(buf_goods.gds-code, "999999999") format "X(9)"
                "|"   at {&P-C2-S}
                string(buf_doc-line.artic)              format "X(16)"
                "|"   at {&P-C3-S}
                buf_goods.gds-name                      format "X({&P-C3-X})"
                "|"   at {&P-C4-S}
                buf_goods.unit-base                     format "X(3)"           at center-field( {&P-C4-S}, {&P-C5-S}, 3)
                "|"   at {&P-C5-S}
                "|"   at {&P-E}
        .
        for each buf_gds-dtl no-lock
           where buf_gds-dtl.prod-type  = buf_doc-line.prod-type
             and buf_gds-dtl.prod-code  = buf_doc-line.prod-code
             and buf_gds-dtl.artic      = buf_doc-line.artic
             and buf_gds-dtl.doc-code   = buf_doc-line.doc-code
         , first buf_gds-prt no-lock
           where buf_gds-prt.node-code = buf_gds-dtl.prt-code
        break by buf_gds-dtl.prt-code
        :
            assign
                v-prt-name = "   //" + buf_gds-prt.f-name
            .
            put stream out-stream
                skip space({&P-S})  "|"
                    "|"   at {&P-C2-S}
                    "|"   at {&P-C3-S}
                    v-prt-name                              format "X({&P-C3-X})"
                    "|"   at {&P-C4-S}
                    "|"   at {&P-C5-S}
                    buf_gds-dtl.fact-qnty                   format "->>>>>9.<<<"
                    "|"   at {&P-E}
            .
            assign
                v-line-counter      = v-line-counter    + 1
                v-pg-sum-qnty       = v-pg-sum-qnty     + buf_gds-dtl.fact-qnty
            .
            if line-counter( Out-Stream ) + 4 > page-size( Out-Stream )
            then do:
                run print-page-result in this-procedure .
                page stream Out-Stream .
            end.
        end.
    end.        /* PrintScale = yes  */
    else do:
        run r-getsum in this-procedure ( input recid ( buf_doc-line )
                                    ,  input CostPrice
                                    ,  input PrintRubl
                                    ).
        put stream out-stream
            skip space({&P-S})  "|"
                string(buf_goods.gds-code, "999999999") format "X(9)"
                "|"   at {&P-C2-S}
                string(buf_doc-line.artic)              format "X(16)"
                "|"   at {&P-C3-S}
                buf_goods.gds-name                      format "X({&P-C3-X})"
                "|"   at {&P-C4-S}
                buf_goods.unit-base                     format "X(3)"           at center-field( {&P-C4-S}, {&P-C5-S}, 3)
                "|"   at {&P-C5-S}
                abs( temp_r-getsum.qnty )               format "->>>>>9.<<<"
                "|"   at {&P-E}
        .
        assign
            v-line-counter      = v-line-counter    + 1
            v-pg-sum-qnty       = v-pg-sum-qnty     + abs( temp_r-getsum.qnty )
        .
        if line-counter( Out-Stream ) + 4 > page-size( Out-Stream )
        then do:
            run print-page-result in this-procedure .
            page stream Out-Stream .
        end.
    end.        /* PrintScale = no  */
end.
end procedure. /* print-line */










/*==========================================================================*/
procedure print-page-result :
do
on error undo, return error
:
if page-number ( Out-Stream ) > 1
then do:
    put stream out-stream
        skip space({&P-S})
            "|" v-single-line format "X({&P-X0})" "|"
        skip space({&P-S})  "|        Итого по странице "
            "|"                 at {&P-C5-S}
            v-pg-sum-qnty                       format "->>>>>9.<<<"
            "|"                 at {&P-E}
    .

end.        /* if page-number ( Out-Stream ) > 1  */
assign
    v-tot-sum-qnty      = v-tot-sum-qnty        + v-pg-sum-qnty
    v-pg-sum-qnty       = 0
.

end.
end procedure. /* print-page-result */







/*==========================================================================*/
procedure print-total-result :
do
on error undo, return error
:
    put stream out-stream
        skip space({&P-S})
            "|" v-single-line format "X({&P-X0})" "|"
        skip space({&P-S})  "|        В С Е Г О "
            "|"                 at {&P-C5-S}
            v-tot-sum-qnty                       format "->>>>>9.<<<"
            "|"                 at {&P-E}
        skip space({&P-S})
            v-single-line format "X({&P-X})"
    .
end.
end procedure. /* print-total-result */



















/*==========================================================================*/
procedure print-note :
do
on error undo, return error
:
    put stream out-stream
        skip(1) space({&tab-stop1})
            "Всего наименований: "
            v-line-counter  format ">>>>>9"
        skip(3) space({&tab-stop1})
            "Зав. складом/Зав. секцией: _____________________________________________ /                          /"
    .
end.
end procedure. /* print-total-result */








/*==============================================================*/
/*---S-------- Печать линии группы в документе -----------------*/
procedure print-group-line :
do
on error undo, return error
:
  put stream out-stream
    skip space({&P-S})
      "|"
      space(5) "Группа:" space(2)
      buf_goods.grp-name
      "|" at {&P-E}
  .
/*  down stream out-stream 1 with frame f-doc .*/
end.
end procedure. /* print-group-line */
/*---E-------- Печать линии группы в документе -----------------*/