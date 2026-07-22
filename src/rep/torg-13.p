block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать формы ТОРГ-13

Автор: Комаров Иван Сергеевич
Дата создания: 06/16/10
Author: Ivan Komarov
Creation date: 06/16/10

Автор1: Демин Алексей Сергеевич
Дата создания1: 09/15/05

Input:

Output:

*/
&scop P3-X 197
&scop P3-S1 30 /*начало надписи перехода на следующую страницу*/

&scop P0-S 179
&scop P0-X 19
&scop P0-X1 160 /* максимальная ширина надписи  И Н Н */
&scop P0-E 197

&scop P1-S 65
&scop P1-X 32
&scop P1-X1 100 /* максимальная ширина надписи статуса документа*/
&scop P1-C1-S 83
&scop P1-E 96

&scop P4-C1-X 19
&scop P4-C2-X 19
&scop P4-C3-X 29
&scop P4-X1 175 /* максимальная ширина суммы прописью */

&scop P2-X 197
&scop P2-X0 195 /* длина внутренней линии = {&P2-X} - 2*/
&scop P2-C1-X 36
&scop P2-C2-S 40
&scop P2-C3-X 36
&scop P2-C3-S 60
&scop P2-C4-S 100
&scop P2-C5-S 120
&scop P2-C6-S 160
&scop P2-C7-S 180
&scop P2-E 197

do
on error undo, return error
:
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter p-print-gold         as logical          no-undo. /* Если yes, то печатается модификация формы для ювелирных изделмй */
define input parameter p-print-prod         as logical          no-undo. /* Если yes, то идет сортировка по производителям */
define input parameter p-break-name         as logical          no-undo init false . /* Если yes, то названия товаров переносятся */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Печать формы ТОРГ-13".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ cmp/r-pril.i       }
{ str/trdcalib.i     }
{ str/in-vatp.i def  }
{ str/out-vatp.i def }
{ rep/p-fmt.i        }
{ rep/r-cliprp.i def }
{ cmp/breakstr.i     }
{ rep/fmtcli.i       }
{ gbl/clntattr.i     }
{ rep/torgconf.i     }
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
{ gbl/paramls.i      }
{ rep/torg13xl.i     }


define buffer t-doc        for trn-doc.
define buffer OurObject    for clients.
define buffer buf_clients  for clients.
define buffer buf_units    for units.

define stream Out-stream .

define shared variable PrintParts   as logical              no-undo.
define shared variable PrintScale   as logical              no-undo.
define shared variable costprice    as logical              no-undo.
define shared variable sort-name    as logical              no-undo.
define shared variable sort-gr      as logical              no-undo.
define shared variable no-vat       as logical              no-undo.

define temp-table temp_gds-name no-undo
    field gds-name like goods.gds-name
    field string-num as integer
    index sn is primary unique string-num
.
define variable v-gds-name          like goods.gds-name     no-undo.
define variable v-gds-name-counter  as integer              no-undo.
define variable v-parameter-value   as character    no-undo.
define variable v-parameter-type    as character    no-undo.
define variable v-otpposition       as character    no-undo.
define variable v-otpname           as character    no-undo.
define variable v-polposition       as character    no-undo.
define variable v-polname           as character    no-undo.
define variable  p-torgconf-wrkr-name as character                 no-undo.
define variable  p-torgconf-post    as character                 no-undo.

define variable tdoc-prt            as    logical           no-undo.
define variable tdoc-code           like trn-doc.doc-code   no-undo.
define variable v-doc-date-string   as character            no-undo.

define variable rootnode_code       as integer              no-undo.

define variable LineCounter         as integer              no-undo.
define variable txt-LC              as char                 no-undo.
define variable s1                  as char                 no-undo.
define variable s2                  as char                 no-undo.

define variable Node_Code           like gds-prt.upper-code no-undo.

define variable PriceNoNDS          as decimal              no-undo.
define variable PricendS            as decimal              no-undo.
define variable PricewithNDS        as decimal              no-undo.

define variable tqnty               as decimal              no-undo.
define variable SumNoNDS            as decimal              no-undo.
define variable SumNDS              as decimal              no-undo.
define variable SumwithNDS          as decimal              no-undo.

define variable sum-tqnty           as decimal              no-undo.
define variable sum-SumNoNDS        as decimal              no-undo.
define variable sum-SumNDS          as decimal              no-undo.
define variable sum-SumwithNDS      as decimal              no-undo.

define variable prt-tqnty           as decimal              no-undo.
define variable prt-SumNoNDS        as decimal              no-undo.
define variable prt-SumNDS          as decimal              no-undo.
define variable prt-SumwithNDS      as decimal              no-undo.

define variable sum-prt-tqnty       as decimal              no-undo.
define variable sum-prt-SumNoNDS    as decimal              no-undo.
define variable sum-prt-SumNDS      as decimal              no-undo.
define variable sum-prt-SumwithNDS  as decimal              no-undo.

define variable Pg-tqnty            as decimal init 0       no-undo.
define variable Pg-SumNoNDS         as decimal              no-undo.
define variable Pg-SumNDS           as decimal              no-undo.
define variable Pg-SumwithNDS       as decimal              no-undo.
define variable PrevPage            as integer init 0       no-undo.

define variable tot-SumNoNDS        as decimal              no-undo.
define variable tot-SumNDS          as decimal              no-undo.
define variable tot-SumwithNDS      as decimal              no-undo.

define variable PrtName             as char                 no-undo.

define variable OKEI                as char                 no-undo.
define variable tb-code             as char                 no-undo.
define variable qnty-opl            as decimal              no-undo.
define variable qnty-pl             as decimal              no-undo.
define variable mass-b              as decimal              no-undo.
define variable mass-n              as decimal              no-undo.

define variable v-line-counter      as integer              no-undo.

define variable v-not-gold          as logical              no-undo.

define variable v-new-prod          as logical  no-undo.
define variable v-prod-type         like doc-line.prod-type no-undo.
define variable v-prod-code         like doc-line.prod-code no-undo.
define variable v-prod-name         like clients.obj-name   no-undo.

define variable sym1    as char init ":" no-undo.
define variable sym2    as char init ":" no-undo.
define variable sym3    as char init ":" no-undo.
define variable sym4    as char init ":" no-undo.
define variable sym5    as char init ":" no-undo.
define variable sym6    as char init ":" no-undo.
define variable sym7    as char init ":" no-undo.
define variable sym8    as char init ":" no-undo.
define variable sym9    as char init ":" no-undo.
define variable sym10   as char init ":" no-undo.
define variable sym11   as char init ":" no-undo.
define variable sym12   as char init ":" no-undo.
define variable sym13   as char init ":" no-undo.
define variable sym14   as char init ":" no-undo.
define variable sym15   as char init ":" no-undo.
define variable sym16   as char init ":" no-undo.
define variable sym17   as char init ":" no-undo.
define variable sym18   as char init ":" no-undo.

define variable Line                as char          no-undo.
define variable UndLine             as char          no-undo.

define variable unit-str            as char          no-undo.
define variable val-str             as char          no-undo.
define variable v-host-code         as integer       no-undo.

{ gbl/working.i }

run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).

find first t-doc no-lock
     where recid( t-doc ) = rec_id
.
{ gbl/hostcode.i
    t-doc.obj-type
    t-doc.obj-code
    v-host-code
}
run torgconf-read in this-procedure (
      input "torg13"
    , input v-host-code
    , input t-doc.obj-type
    , input t-doc.obj-code
) no-error.
if error-status :error
then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров печати формы."
    skip "Форма будет напечатана с параметрами по умолчанию."
    skip return-value
    skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
    view-as alert-box error.
end.
run torgconf-get-storekeeper in this-procedure (
      input  t-doc.wrkr
    , output p-torgconf-wrkr-name
    , output p-torgconf-post
).
run torgconf-get-warrant in this-procedure (
      input t-doc.doc-code
) no-error.
if error-status :error
then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения атрибутов накладной."
    skip return-value
    skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
    view-as alert-box error.
end.
run gbl/conf-rd.p (
    input "fgdsnind"
    , input t-doc.host-code
    , t-doc.obj-type
    , t-doc.obj-code
    , ""
    , ""
    , ""
    , no
    , output v-parameter-value
    , output v-parameter-type
) no-error.
if not error-status:error
then do:
    assign
        p-break-name = ( v-parameter-value = "yes" )
    .
end.

{ rep/torg-13.i def-frame }
{ rep/torg-13.i def-frame gold }

run torg13xl-init in this-procedure .

assign val-str = ( if PrintRubl then "{&abbr_rublyah}" else "баз.вал" ) .
assign
    Line = fill("-", 230)
    UndLine = fill("_", 230)
    LineCounter = 1
.
if v-torgconf-outnum = yes
then do:
    assign
        tdoc-code = fill( " ", 10 )
    .
end.
else do:
    assign
        tdoc-code = t-doc.doc-code
    .
end.
if v-torgconf-outdate = yes
then do:
    assign
        v-doc-date-string = fill( " ", 10 )
    .
end.
else do:
    assign
        v-doc-date-string = ( if t-doc.status_ <> {&fact}
                              then string( t-doc.doc-date, "99/99/9999" )
                              else string( t-doc.fact-date, "99/99/9999" )
                            )
    .
end.
find OurObject where OurObject.obj-type = t-doc.obj-type and
                                          OurObject.obj-code = t-doc.obj-code no-lock no-error.
case OurObject.obj-type :
    when {&shop}
    then do:
        find shop where shop.obj-code = OurObject.obj-code no-lock .
        tdoc-prt = shop.doc-prt.
    end.
    when {&stock}
    then do:
        find store where store.obj-code = OurObject.obj-code no-lock .
        tdoc-prt = store.doc-prt .
    end.
end case.

if not tdoc-prt then
    PrintScale = no .

{ cmp/open-out.i stream Out-stream " " {&LS_PS_A4} }

form header
    Line format "X({&P3-X})" at 1 skip
    "Продолжение - на следующей странице" at {&P3-S1} skip
    with frame bottomframe width {&DOS_CW} page-bottom no-labels no-box .
view stream out-stream frame bottomframe .

find clients where clients.obj-type = {&cmp} and
                                   clients.obj-code = t-doc.host-code no-lock .

{ rep/r-cliprp.i }
if v-torgconf-outappr = yes
then do:
    put stream out-stream
        "Утверждена постановлением Госкомстата России от 25.12.98 N 132" at {&P0-E} - 61
    .
end.
define variable v-operation-type    as character    no-undo.
define variable v-organization      as character    no-undo.
assign
    v-organization = substitute( "{&abbr_inn_allshift} &1 &2 (&3) &4 &5"
                            , t-inn
                            , caps( clients.obj-name )
                            , clients.obj-code
                            , t-addres
                            , t-phone
                     )
.
put stream out-stream
    space(5) Line format  "X({&P0-X})" at {&P0-S} skip
    space(5) "|"            at {&P0-S}
             {&g___code}  format "X(3)"     at center-field( {&P0-S}, {&P0-E}, 3 )
             "|" at {&P0-E}
    skip space(5)
             "Форма по ОКУД" format "X(13)" at right-field ( {&P0-S}, 13 )
             "| "                           at {&P0-S}
             "0330213"                      at center-field( {&P0-S}, {&P0-E}, 7 )
             "|"                            at {&P0-E}
    skip space(5)
                   v-organization
                                    format "X({&P0-X1})"
                   "по ОКПО"        format "X(7)"       at right-field ( {&P0-S}, 7 )
                   "| "                                 at {&P0-S}
                   t-okpo           format "X(10)"      at center-field( {&P0-S}, {&P0-E}, 10 )
                   "|"                                  at {&P0-E}
    skip space(5)
             "Вид деятельности по ОКДП" format "X(24)"  at right-field ( {&P0-S}, 24 )
             "| "                                       at {&P0-S}
             "|"                                        at {&P0-E}
.
run torg13xl-write-cell-data in this-procedure (
      input {&torg13xl-h_organization}
    , input trim( v-organization )
).
assign
    v-operation-type =
              ( if t-doc.doc-type = {&income}
                then " приход"
                else ( if t-doc.doc-type = {&return}
                       then "возврат"
                       else " расход" ) )
.
put stream out-stream
    skip space(5)
             "Вид операции" format "X(12)"  at right-field ( {&P0-S}, 12 )
             "| "                           at {&P0-S}
              v-operation-type
                            format "X(7)"   at center-field( {&P0-S}, {&P0-E}, 7 )
             "|"                            at {&P0-E}
    skip space(5)
             Line format  "X({&P0-X})"      at {&P0-S}
.
run torg13xl-write-cell-data in this-procedure (
      input {&torg13xl-h_operationType}
    , input trim( v-operation-type )
).
run torg13xl-write-cell-data in this-procedure (
    input {&torg13xl-h_OKPO}
    , input trim( t-okpo )
).
put stream out-stream
    skip
        Line                format "X({&P1-X})" at {&P1-S}
    skip
        "НАКЛАДНАЯ"                             at right-field ( {&P1-S}, 9 )
        "|"                                     at {&P1-S}
        string( tdoc-code ) format "X(14)"      at center-field( {&P1-S}, {&P1-C1-S}, 14 )
        "|"                                     at {&P1-C1-S}
        v-doc-date-string
                            format "X(10)"      at center-field( {&P1-C1-S}, {&P1-E}, 10 )
        "|"                                     at {&P1-E}
        (if t-doc.status_ <> {&fact}
         then string( "(" + caps(t-doc.status_) + ")" )
         else ""
        )                   format "X({&P1-X1})"
    skip
        Line                format "X({&P1-X})" at {&P1-S}
    skip
        "НА ВНУТРЕННЕЕ ПЕРЕМЕЩЕНИЕ, ПЕРЕДАЧУ ТОВАРОВ, ТАРЫ"
                            format "X(49)"      at center-field( {&P1-S} - 7, {&P1-E}, 49 )
    skip
.
run torg13xl-write-cell-data in this-procedure (
      input {&torg13xl-h_docCode}
    , input trim( tdoc-code )
).
run torg13xl-write-cell-data in this-procedure (
      input {&torg13xl-h_docDate}
    , input trim( v-doc-date-string )
).
put stream out-stream
        Line format "X({&P3-X})"
    skip
        "| "
        "Отправитель"             format "X(11)"
        "| "                                        at {&P2-C3-S}
        "Получатель"              format "X(10)"
        "| "                                        at {&P2-C5-S}
        "Корреспондирующий счет"  format "X(22)"
        "|"                                         at {&P2-C7-S}
        "|"                                         at {&P2-E}
    skip
        "|"
        Line                        format "X({&P2-X0})"
        "|"
    skip
        "| "
        "структурное"               format "X(11)"
        "| "                                        at {&P2-C2-S}
        "вид деятельности"          format "X(16)"
        "| "                                        at {&P2-C3-S}
        "структурное"               format "X(11)"
        "| "                                        at {&P2-C4-S}
        "вид деятельности"          format "X(16)"
        "| "                                        at {&P2-C5-S}
        "счет, субсчет"             format "X(13)"
        "| "                                        at {&P2-C6-S}
        "код аналитического"        format "X(18)"
        "|"                                         at {&P2-C7-S}
        "|"                                         at {&P2-E}
    skip
        "| "
        "подразделение"             format "X(13)"
        "|"                                         at {&P2-C2-S}
        "| "                                        at {&P2-C3-S}
        "подразделение"             format "X(13)"
        "|"                                         at {&P2-C4-S}
        "|"                                         at {&P2-C5-S}
        "|"                                         at {&P2-C6-S}
        "учета"                     format "X(5)"
        "|"                                         at {&P2-C7-S}
        "|"                                         at {&P2-E}
    skip
        "|"
        Line format "X({&P2-X0})"
        "|"
    skip
.
if t-doc.doc-type = {&income} or t-doc.doc-type = {&return}
then do:
    find first clients no-lock
         where clients.obj-type = t-doc.cli-type
           and clients.obj-code = t-doc.cli-code
    .
end.
else do:
    find first clients no-lock
         where clients.obj-type = t-doc.obj-type
           and clients.obj-code = t-doc.obj-code
    .
end.
put stream out-stream
    "| "
    string( clients.obj-name ) format "X({&P2-C1-X})"
    "|"                                                 at {&P2-C2-S}
.
run torg13xl-write-cell-data in this-procedure (
      input {&torg13xl-h_objFrom}
    , input trim( clients.obj-name )
).
if t-doc.doc-type = {&income} or t-doc.doc-type = {&return}
then do:
    find first clients no-lock
         where clients.obj-type = t-doc.obj-type
           and clients.obj-code = t-doc.obj-code
    .
end.
else do:
    find first clients no-lock
         where clients.obj-type = t-doc.cli-type
           and clients.obj-code = t-doc.cli-code
    .
end.
put stream out-stream
    "|"                                                 at {&P2-C3-S}
    string( clients.obj-name ) format "X({&P2-C3-X})"
    "|"                                                 at {&P2-C4-S}
    "|"                                                 at {&P2-C5-S}
    "|"                                                 at {&P2-C6-S}
    "|"                                                 at {&P2-C7-S}
    "|"                                                 at {&P2-E}
    skip
    Line format "X({&P3-X})" skip
.
run torg13xl-write-cell-data in this-procedure (
      input {&torg13xl-h_objTo}
    , input trim( clients.obj-name )
).
/*---START--------- Определение формы для вывода строк ---------------------*/
if costprice
then do:
    if p-print-gold = yes
    then do:
        form with frame f-doc-cost-gold .
        if sort-gr = yes or p-print-prod = yes
        then do:
            down stream out-stream 1 with frame f-doc-cost-gold .
        end.
    end.
    else do:
        form with frame f-doc-cost.
        if sort-gr = yes or p-print-prod = yes
        then do:
            down stream out-stream 1 with frame f-doc-cost .
        end.
    end.
end.
else do:
    if p-print-gold = yes
    then do:
        form with frame f-doc-doc-gold .
        if sort-gr = yes or p-print-prod = yes
        then do:
            down stream out-stream 1 with frame f-doc-doc-gold .
        end.
    end.
    else do:
        form with frame f-doc-doc.
        if sort-gr = yes or p-print-prod = yes
        then do:
            down stream out-stream 1 with frame f-doc-doc .
        end.
    end.
end.
/*---END----------- Определение формы для вывода строк ---------------------*/



/*----- Начальные значения ------*/

assign
    v-line-counter  = 0
    v-new-prod      = yes
    sum-tqnty       = 0
    sum-SumNoNDS    = 0
    sum-SumNDS      = 0
    sum-SumwithNDS  = 0
.

/*---S---------- Печать строк документа ---------------*/
if sort-name = yes
then do:
    if p-print-prod = yes
    then do:
        if sort-gr = yes
        then do:
            for each doc-line no-lock
               where doc-line.doc-code = t-doc.doc-code
              ,first goods no-lock
               where goods.prod-type    = doc-line.prod-type
                 and goods.prod-code    = doc-line.prod-code
                 and goods.artic        = doc-line.artic
              ,first clients no-lock
               where clients.obj-type   = goods.prod-type
                 and clients.obj-code   = goods.prod-code
            break   by clients.obj-name
                    by goods.grp-name
                    by goods.gds-name
            :
                if first-of (clients.obj-name)
                then do:
                    run print-prod-line in this-procedure.
                end.
                if first-of (goods.grp-name)
                then do:
                    run print-group-line in this-procedure.
                end.
                run print-doc-line in this-procedure.
            end.
        end.        /* sort-gr = yes */
        else do:
            for each doc-line no-lock
               where doc-line.doc-code = t-doc.doc-code
             , first goods no-lock
               where goods.prod-type    = doc-line.prod-type
                 and goods.prod-code    = doc-line.prod-code
                 and goods.artic        = doc-line.artic
              ,first clients no-lock
               where clients.obj-type   = goods.prod-type
                 and clients.obj-code   = goods.prod-code
            break   by clients.obj-name
                    by goods.gds-name
            :
                if first-of (clients.obj-name)
                then do:
                    run print-prod-line in this-procedure.
                end.
                run print-doc-line in this-procedure.
            end.
        end.        /* sort-gr = no */
    end.            /* p-print-prod = yes */
    else do:
        if sort-gr = yes
        then do:
            for each doc-line no-lock
            where doc-line.doc-code = t-doc.doc-code
            , first goods no-lock
            where goods.prod-type    = doc-line.prod-type
                and goods.prod-code    = doc-line.prod-code
                and goods.artic        = doc-line.artic
            break by goods.grp-name
                by goods.gds-name
            :
                if first-of (goods.grp-name)
                then do:
                    run print-group-line in this-procedure.
                end.
                run print-doc-line in this-procedure.
            end.
        end.        /* sort-gr = yes */
        else do:
            for each doc-line no-lock
            where doc-line.doc-code = t-doc.doc-code
            , first goods no-lock
            where goods.prod-type    = doc-line.prod-type
                and goods.prod-code    = doc-line.prod-code
                and goods.artic        = doc-line.artic
            break by goods.gds-name
            :
                run print-doc-line in this-procedure.
            end.
        end.        /* sort-gr = no */
    end.            /* p-print-prod = no */
end.        /* sort-name = yes */
else do:
    if p-print-prod = yes
    then do:
        if sort-gr = yes
        then do:
            for each doc-line no-lock
            where doc-line.doc-code = t-doc.doc-code
            , first goods no-lock
            where goods.prod-type    = doc-line.prod-type
                and goods.prod-code    = doc-line.prod-code
                and goods.artic        = doc-line.artic
              ,first clients no-lock
               where clients.obj-type   = goods.prod-type
                 and clients.obj-code   = goods.prod-code
            break   by clients.obj-name
                    by goods.grp-name
                    by doc-line.line-num
            :
                if first-of (clients.obj-name)
                then do:
                    run print-prod-line in this-procedure.
                end.
                if first-of (goods.grp-name)
                then do:
                    run print-group-line in this-procedure.
                end.
                run print-doc-line in this-procedure.
            end.
        end.
        else do:
            for each doc-line no-lock
            where doc-line.doc-code = t-doc.doc-code
            , first goods no-lock
              where goods.prod-type    = doc-line.prod-type
                and goods.prod-code    = doc-line.prod-code
                and goods.artic        = doc-line.artic
            , first clients no-lock
              where clients.obj-type   = goods.prod-type
                and clients.obj-code   = goods.prod-code
            break   by clients.obj-name
                    by doc-line.line-num
            :
                if first-of (clients.obj-name)
                then do:
                    run print-prod-line in this-procedure.
                end.
                run print-doc-line in this-procedure.
            end.
        end.
    end.        /* p-print-prod = yes */
    else do:
        if sort-gr = yes
        then do:
            for each doc-line no-lock
            where doc-line.doc-code = t-doc.doc-code
            , first goods no-lock
            where goods.prod-type    = doc-line.prod-type
                and goods.prod-code    = doc-line.prod-code
                and goods.artic        = doc-line.artic
            break by goods.grp-name
                by doc-line.line-num
            :
                if first-of (goods.grp-name)
                then do:
                    run print-group-line in this-procedure.
                end.
                run print-doc-line in this-procedure.
            end.
        end.        /* sort-gr = yes */
        else do:
            for each doc-line no-lock
            where doc-line.doc-code = t-doc.doc-code
            , first goods no-lock
            where goods.prod-type    = doc-line.prod-type
                and goods.prod-code    = doc-line.prod-code
                and goods.artic        = doc-line.artic
            break by doc-line.line-num
            :
                run print-doc-line in this-procedure.
            end.
        end.        /* sort-gr = yes */
    end.        /* p-print-prod = no */
end.        /* sort-name = no */
/*---E---------- Печать строк документа ---------------*/

/*---START--------- Выводим итог на странице ---------------------*/
if line-counter( Out-stream ) + 11 > page-size( Out-stream )
then do:
    if p-print-gold = yes
    then do:
        if costprice =yes
        then do:
            { rep/torg-13.i itog cost -gold }
        end.
        else do:
            { rep/torg-13.i itog doc -gold }
        end.
        page stream Out-stream .
    end.        /* p-print-gold = yes */
    else do:
        if costprice =yes
        then do:
            { rep/torg-13.i itog cost }
        end.
        else do:
            { rep/torg-13.i itog doc }
        end.
        page stream Out-stream .
    end.        /* p-print-gold = no */
end.
/*---END----------- Выводим итог на странице ---------------------*/
/*---START--------- Общий итог ---------------------*/

hide stream Out-stream frame Bottomframe .

if p-print-gold = yes
then do:
    if costprice = yes
    then do:
        { rep/torg-13.i itog cost -gold }
        display stream Out-stream
            "Всего по накладной"    @ temp_gds-name.gds-name
            t-doc.fact-qnty         @ tqnty
            sum-SumNoNDS            @ SumNoNDS
            sum-SumNDS              @ SumNDS
            sum-SumwithNDS          @ SumwithNDS
            with frame f-doc-cost-gold .
        down stream Out-stream 2 with frame f-doc-cost-gold .
    end.        /* costprice = yes */
    else do:
        { rep/torg-13.i itog doc -gold }
        display stream Out-stream
            "Всего по накладной"    @ temp_gds-name.gds-name
            t-doc.fact-qnty         @ tqnty
            sum-SumNoNDS            @ SumNoNDS
            sum-SumNDS              @ SumNDS
            sum-SumwithNDS          @ SumwithNDS
            with frame f-doc-doc-gold .
        down stream Out-stream 2 with frame f-doc-doc-gold .
    end.        /* costprice = no */
end.        /* p-print-gold = yes */
else do:
    if costprice = yes
    then do:
        { rep/torg-13.i itog cost }
        display stream Out-stream
            "Всего по накладной"    @ temp_gds-name.gds-name
            t-doc.fact-qnty         @ tqnty
            sum-SumNoNDS            @ SumNoNDS
            sum-SumNDS              @ SumNDS
            sum-SumwithNDS          @ SumwithNDS
            with frame f-doc-cost .
        down stream Out-stream 2 with frame f-doc-cost .
    end.        /* costprice = yes */
    else do:
        { rep/torg-13.i itog doc }
        display stream Out-stream
            "Всего по накладной"    @ temp_gds-name.gds-name
            t-doc.fact-qnty         @ tqnty
            sum-SumNoNDS            @ SumNoNDS
            sum-SumNDS              @ SumNDS
            sum-SumwithNDS          @ SumwithNDS
            with frame f-doc-doc .
        down stream Out-stream 2 with frame f-doc-doc .
    end.        /* costprice = no */
end.        /* p-print-gold = no */
run torg13xl-write-cell-data in this-procedure (
      input {&torg13xl-it_qnty}
    , input string( t-doc.fact-qnty )
).
if costprice
then do:
    run torg13xl-write-cell-data in this-procedure (
          input {&torg13xl-it_sum}
        , input if no-vat then string(sum-SumNoNDS) else string(sum-SumwithNDS)
    ).
end .
else do :
run torg13xl-write-cell-data in this-procedure (
      input {&torg13xl-it_sum}
    , input string( sum-SumwithNDS )
).
end .
/*---END----------- Общий итог ---------------------*/
/*---START--------- Примечание формы ---------------------*/
if costprice
then do :
if PrintRubl
then do:
    run rep/wp-rub.p (
          input if no-vat then sum-SumNoNDS else sum-SumwithNDS
        , output s1
        , output s2
    ).
end.
else do:
    run rep/wp.p (
          input p-mainmenu-handle
        , input if no-vat then sum-SumNoNDS else sum-SumwithNDS
        , output s1
        , output s2
    ).
end.
    run torg13xl-write-cell-data in this-procedure (
          input {&torg13xl-f_itSumStr}
        , input s1
    ).
end .
else do :
    if PrintRubl
    then do:
        run rep/wp-rub.p (
              input sum-SumwithNDS
            , output s1
            , output s2
        ).
    end.
    else do:
        run rep/wp.p (
              input p-mainmenu-handle
            , input sum-SumwithNDS
            , output s1
            , output s2
        ).
    end.
    run torg13xl-write-cell-data in this-procedure (
          input {&torg13xl-f_itSumStr}
        , input s1
    ).
end .
if t-doc.ext-doc-type = {&TDEDT_Pri_Perem}
then do:
  assign
     v-otpposition = p-torgconf-t_pass-position /*атрибут сдал должность*/
     v-otpname     = p-torgconf-t_pass-fname
     v-polposition = p-torgconf-post
     v-polname     = p-torgconf-wrkr-name
  .
end.
else do:
  assign
     v-otpposition = p-torgconf-post /*Должность кладовщика */
     v-otpname     = p-torgconf-wrkr-name
     v-polposition = p-torgconf-accept-position
     v-polname     = p-torgconf-accept-fname
  .
end.

run torg13xl-write-cell-data in this-procedure (
      input {&torg13xl-f_pass_fname}
    , input (if trim(v-otpname) = "" then "" else v-otpname)
).
run torg13xl-write-cell-data in this-procedure (
      input {&torg13xl-f_pass_position}
    , input (if trim(v-otpposition) = "" then "" else v-otpposition)
).
run torg13xl-write-cell-data in this-procedure (
      input {&torg13xl-f_accept_position}
    , input (if trim(v-polposition) = "" then "" else v-polposition)
).
run torg13xl-write-cell-data in this-procedure (
      input {&torg13xl-f_accept_fname}
    , input (if trim(v-polname) = "" then "" else v-polname)
).


if trim(v-otpname) = ""
then do:
   v-otpname = string(UndLine, "X({&P4-C3-X})").
end.
if trim(v-otpposition) = ""
then do:
   v-otpposition = string(UndLine, "X(23)").
end.
if trim(v-polposition) = ""
then do:
   v-polposition = string(UndLine, "X(23)").
end.
if trim(v-polname) = ""
then do:
   v-polname = string(UndLine, "X({&P4-C3-X})").
end.

put stream Out-stream
    skip space(10)
        string( "Отпустил " ) format "X(9)"
        v-otpposition format "X(23)" string( " " ) format "X(1)"
        UndLine format "X({&P4-C2-X})" string( " " ) format "X(1)"
           v-otpname  format "X({&P4-C3-X})" string( " товар и тару по количеству и надлежащему качеству" ) format "X(50)"
    skip space(23)
        string( "должность" )           format "X({&P4-C1-X})" string( " " ) format "X(1)" space(2)
        string( "подпись" )             format "X({&P4-C2-X})" string( " " ) format "X(1)"
        string( "расшифровка подписи" ) format "X({&P4-C3-X})"
    skip(1) space(10)
        string( "на сумму " ) format "X(9)"
        caps(s1) format "X({&P4-X1})"
    skip(1) space(10)
        string( "Получил " ) format "X(9)"
        v-polposition format "X(23)" string( " " ) format "X(1)"
        UndLine format "X({&P4-C2-X})" string( " " ) format "X(1)"
        v-polname     format "X({&P4-C3-X})"
    skip space(23)
        string( "должность" )           format "X({&P4-C1-X})" string( " " ) format "X(1)"  space(2)
        string( "подпись" )             format "X({&P4-C2-X})" string( " " ) format "X(1)"
        string( "расшифровка подписи" ) format "X({&P4-C3-X})" skip
    .
    if v-torgconf-outprim = yes
    then do:
        /* Не печатать примечание. */
    end.        /* p-mode = "mag"  */
    else do:
        define variable v-comment    as character    no-undo.
        assign
            v-comment = trim( ( if not( t-doc.PS begins "@":U )
                                   then replace( t-doc.PS, {&new-line}, " ":U )
                                   else "":U ) )
        .
        if v-comment <> "":U
        and v-comment <> ?
        then do:
            put stream out-stream
                skip(1) space(5)
                    substitute( "Примечание: &1", v-comment )  format "X(163)"
            .
        end.
    end.        /* NOT ( p-mode = "mag"  ) */
/*---END----------- Примечание формы ---------------------*/

run torg13xl-close in this-procedure .

{ gbl/stopwork.i }

output stream Out-stream close.
{ rep/q-print.i 8 }

end.










/*==========================================================================*/
procedure print-doc-line :
do
on error undo, return error
:
assign 
PricendS = 0
PricewithNDS = 0
PriceNoNDS = 0
SumNDS = 0
SumNoNDS = 0
SumwithNDS = 0 
tqnty = 0 
.
    if p-print-gold = yes
    then do:
        /*---START--------- Определили, золото это или нет и вычислили кол-во мест ---------------------*/
        find first buf_units no-lock
            where buf_units.unit-name = goods.unit-base
        .
        assign
            v-not-gold  = ?
        .
        if lookup({&twounit}, buf_units.type) <> 0
        then do:
            run get-cli-qnty in this-procedure
                             (    input recid( doc-line )
                                , output qnty-pl
                             ).
            assign
                /*qnty-pl     = doc-line.cli-qnty*/
                v-not-gold  = no
            .
        end.
        if lookup({&altunit}, buf_units.type) <> 0
        then do:
            assign
                qnty-pl     = doc-line.doc-qnty
                v-not-gold  = no
            .
        end.
        if  v-not-gold  = ?
        then do:
            assign
                v-not-gold  = yes
            .
        end.
        /*---END----------- Определили, золото это или нет и вычислили кол-во мест ---------------------*/
    end.
    /*---START--------- Очистили и заполнили temp-table с именем товара по строкам ---------------------*/
    assign
        v-gds-name  = goods.gds-name
    .
    for each temp_gds-name
    :
        delete temp_gds-name.
    end.
    create temp_gds-name.
    assign
        s1 = breakstr( v-gds-name,  28, input-output temp_gds-name.gds-name, input-output s2)
        v-gds-name-counter          = 1
        temp_gds-name.string-num    = 1
    .
    do
    while s2 <> "":U
    :
        create temp_gds-name.
        assign
            temp_gds-name.gds-name      = breakstr( input s2
                                                  , input 28
                                                  , input-output temp_gds-name.gds-name
                                                  , input-output s2
                                                  )
            v-gds-name-counter          = v-gds-name-counter + 1
            temp_gds-name.string-num    = v-gds-name-counter
        .
    end. /* do while ... */
    find first temp_gds-name .
/*                                                                    assign*/
/*                                                                        s1 = ""*/
/*                                                                    .*/
/*                                                                    for each temp_gds-name no-lock*/
/*                                                                    :*/
/*                                                                        assign*/
/*                                                                            s1 = s1 + {&new-line} + string(temp_gds-name.string-num) + ". " + temp_gds-name.gds-name*/
/*                                                                        .*/
/*                                                                    end.*/
/*                                                                    message*/
/*                                                                        s1*/
/*                                                                    view-as alert-box.*/

    /*---END----------- Очистили и заполнили temp-table с именем товара по строкам ---------------------*/

    find first gds-prt no-lock
            where gds-prt.upper-code = goods.prt-root
    .
    assign
        rootnode_code = gds-prt.node-code.
    .
    if costprice
    then do:
        { str/in-vatp.i calc doc-line. t-doc. g }
        assign PricendS = ( if PrintRubl then vat-rubl-loc else vat-base-loc ).
        if PricendS = ? then assign PricendS = 0.
        assign
            PricewithNDS = ( if PrintRubl then price-rubl-with-tax-loc else price-base-with-tax-loc )
            PriceNoNDS = PricewithNDS - PricendS
        .
    end.
    else do:
        { str/out-vatp.i calc doc-line. t-doc. }
        assign PricendS = ( if PrintRubl then vat-rubl-sale else vat-base-sale ).
        if PricendS = ? then assign PricendS = 0.
        assign
            PricewithNDS = ( if PrintRubl then price-rubl-with-tax-sale else price-base-with-tax-sale )
            PriceNoNDS = PricewithNDS - PricendS
        .
    end.
    if not can-do( {&empty-scale}, gds-prt.node-name )
    then do:                                  /* Не пустая шкала */
            if PrintScale = yes
            then do:
                if p-print-gold = yes
                then do:
                    if costprice = yes
                    then do:
                        display stream Out-stream
                            temp_gds-name.gds-name
                            goods.artic
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                            with frame f-doc-cost-gold .
                        down stream Out-stream 1 with frame f-doc-cost-gold .
                        { rep/torg-13.i no-sum cost -gold }
                    end.        /* costprice = yes */
                    else do:
                        display stream Out-stream
                            temp_gds-name.gds-name
                            goods.artic
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                            with frame f-doc-doc-gold .
                        down stream Out-stream 1 with frame f-doc-doc-gold .
                        { rep/torg-13.i no-sum doc -gold }
                    end.
                end.            /* p-print-gold = yes */
                else do:
                    if costprice = yes
                    then do:
                        display stream Out-stream
                            temp_gds-name.gds-name
                            goods.artic
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17
                            with frame f-doc-cost .
                        down stream Out-stream 1 with frame f-doc-cost .
                        { rep/torg-13.i no-sum cost }
                    end.
                    else do:    /* costprice = no */
                        display stream Out-stream
                            temp_gds-name.gds-name
                            goods.artic
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17
                            with frame f-doc-doc .
                        down stream Out-stream 1 with frame f-doc-doc .
                        { rep/torg-13.i no-sum doc }
                    end.
                end.
                assign
                    v-line-counter = v-line-counter + 1
                .
                run torg13xl-write-line-data in this-procedure (
                      input goods.artic + " ":U + goods.gds-name      /* p-Name           as character */
                    , input string( goods.gds-code )    /* p-gdscode        as character */
                    , input goods.unit-base             /* p-EI             as character */
                    , input "":U                        /* p-OKEI           as character */
                    , input "":U                        /* p-AmountInPl     as character */
                    , input "":U                        /* p-PlaceAmount    as character */
                    , input "":U                        /* p-qnty           as character */
                    , input "":U                        /* p-price          as character */
                    , input "":U                        /* p-sum            as character */
                ).
                assign
                    LineCounter = LineCounter + 1
                .
                if p-break-name = yes
                then do:
                    run display-gds-name in this-procedure .
                end.
            end.  /* PrintScale = yes */
            assign
                sum-prt-tqnty       = 0
                sum-prt-SumNoNDS    = 0
                sum-prt-SumNDS      = 0
                sum-prt-SumwithNDS  = 0
            .
            if t-doc.ext-doc-type = {&TDEDT_Pri_Perem}
            or t-doc.ext-doc-type = {&TDEDT_Ras_Perem}
            or t-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem}
            then do: 
              for each gds-dtl no-lock
                 where gds-dtl.prod-type = doc-line.prod-type
                   and gds-dtl.prod-code = doc-line.prod-code
                   and gds-dtl.artic = doc-line.artic
                   and gds-dtl.doc-code = doc-line.doc-code
/*                   and gds-dtl.line-num = doc-line.line-num*/
              :
                  find first gds-prt no-lock
                       where gds-prt.node-code = gds-dtl.prt-code
                  .
  
                  assign
                      prt-tqnty =  gds-dtl.fact-qnty
                      prt-SumNoNDS = PriceNoNDS * prt-tqnty
                      prt-SumNDS = PricendS * prt-tqnty
                      prt-SumwithNDS = PricewithNDS * prt-tqnty
                  .
                  assign
                      sum-prt-tqnty       = sum-prt-tqnty      +  prt-tqnty
                      sum-prt-SumNoNDS    = sum-prt-SumNoNDS   +  prt-SumNoNDS
                      sum-prt-SumNDS      = sum-prt-SumNDS     +  prt-SumNDS
                      sum-prt-SumwithNDS  = sum-prt-SumwithNDS +  prt-SumwithNDS
                  .
                  if PrintScale = yes
                  then do:
                      find first bar-code no-lock
                              where bar-code.gds-code  = goods.gds-code
                              and bar-code.unit-cli  = goods.unit-base
                              and bar-code.node-code = gds-dtl.prt-code
                              and bar-code.part-code = ""
                              and bar-code.in-code   = ""
                      .
                      assign
                          PrtName = goods.gds-name + "//" + gds-prt.f-name
                      .
                      if p-print-gold = yes
                      then do:
                          if costprice = yes
                          then do:
                              display stream Out-stream
                                      PrtName @     temp_gds-name.gds-name
                                      string( bar-code.b-code ) @ tb-code
                                      goods.unit-base
                                      prt-tqnty @ tqnty
                                      PriceNoNDS
                                      PricendS
                                      PricewithNDS
                                      prt-SumNoNDS @ SumNoNDS
                                      prt-SumNDS @ SumNDS
                                      prt-SumwithNDS @ SumwithNDS
                                      sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                      sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                                      with frame f-doc-cost-gold .
                              down stream Out-stream 1 with frame f-doc-cost-gold .
                              { rep/torg-13.i prt- cost -gold }
                              run torg13xl-write-line-data in this-procedure (
                                    input PrtName                     /* p-Name           as character */
                                  , input string( goods.gds-code )    /* p-gdscode        as character */
                                  , input goods.unit-base             /* p-EI             as character */
                                  , input "":U                        /* p-OKEI           as character */
                                  , input "":U                        /* p-AmountInPl     as character */
                                  , input "":U                        /* p-PlaceAmount    as character */
                                  , input string( prt-tqnty )         /* p-qnty           as character */
                                  , input if no-vat then string(PriceNoNDS)
                                                    else string(PriceWithNDS)   /* p-price       as character */
                                  , input if no-vat then string(prt-SumNoNDS)
                                                    else string(prt-SumwithNDS) /* p-sum         as character */
                              ).
                          end.        /* costprice = yes */
                          else do:
                              display stream Out-stream
                                      PrtName @     temp_gds-name.gds-name
                                      string( bar-code.b-code ) @ tb-code
                                      goods.unit-base
                                      prt-tqnty @ tqnty
                                      PriceNoNDS
                                      PricendS
                                      PricewithNDS
                                      prt-SumNoNDS @ SumNoNDS
                                      prt-SumNDS @ SumNDS
                                      prt-SumwithNDS @ SumwithNDS
                                      sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                      sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                                      with frame f-doc-doc-gold .
                              down stream Out-stream 1 with frame f-doc-doc-gold .
                              { rep/torg-13.i prt- doc -gold }
                              run torg13xl-write-line-data in this-procedure (
                                    input PrtName                     /* p-Name           as character */
                                  , input string( goods.gds-code )    /* p-gdscode        as character */
                                  , input goods.unit-base             /* p-EI             as character */
                                  , input "":U                        /* p-OKEI           as character */
                                  , input "":U                        /* p-AmountInPl     as character */
                                  , input "":U                        /* p-PlaceAmount    as character */
                                  , input string( prt-tqnty )         /* p-qnty           as character */
                                  , input string( PricewithNDS )      /* p-price          as character */
                                  , input string( prt-SumwithNDS )    /* p-sum            as character */
                              ).
                          end.
                      end.        /* p-print-gold = yes */
                      else do:
                          if costprice = yes
                          then do:
                              display stream Out-stream
                                      PrtName @     temp_gds-name.gds-name
                                      string( bar-code.b-code ) @ tb-code
                                      goods.unit-base
                                      prt-tqnty @ tqnty
                                      PriceNoNDS
                                      PricendS
                                      PricewithNDS
                                      prt-SumNoNDS @ SumNoNDS
                                      prt-SumNDS @ SumNDS
                                      prt-SumwithNDS @ SumwithNDS
                                      sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                      sym11 sym12 sym13 sym14 sym15 sym16 sym17
                                      with frame f-doc-cost .
                              down stream Out-stream 1 with frame f-doc-cost .
                              { rep/torg-13.i prt- cost }
                              run torg13xl-write-line-data in this-procedure (
                                    input PrtName                     /* p-Name           as character */
                                  , input string( goods.gds-code )    /* p-gdscode        as character */
                                  , input goods.unit-base             /* p-EI             as character */
                                  , input "":U                        /* p-OKEI           as character */
                                  , input "":U                        /* p-AmountInPl     as character */
                                  , input "":U                        /* p-PlaceAmount    as character */
                                  , input string( prt-tqnty )         /* p-qnty as character */
                                  , input if no-vat then string(PriceNoNDS)
                                                    else string(PriceWithNDS)   /* p-price       as character */
                                  , input if no-vat then string(prt-SumNoNDS)
                                                    else string(prt-SumwithNDS) /* p-sum         as character */
                              ).
                          end.        /* costprice = yes */
                          else do:
                              display stream Out-stream
                                      PrtName @     temp_gds-name.gds-name
                                      string( bar-code.b-code ) @ tb-code
                                      goods.unit-base
                                      prt-tqnty @ tqnty
                                      PriceNoNDS
                                      PricendS
                                      PricewithNDS
                                      prt-SumNoNDS @ SumNoNDS
                                      prt-SumNDS @ SumNDS
                                      prt-SumwithNDS @ SumwithNDS
                                      sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                      sym11 sym12 sym13 sym14 sym15 sym16 sym17
                                      with frame f-doc-doc .
                              down stream Out-stream 1 with frame f-doc-doc .
                              { rep/torg-13.i prt- doc }
                      run torg13xl-write-line-data in this-procedure (
                            input PrtName                     /* p-Name           as character */
                          , input string( goods.gds-code )    /* p-gdscode        as character */
                          , input goods.unit-base             /* p-EI             as character */
                          , input "":U                        /* p-OKEI           as character */
                          , input "":U                        /* p-AmountInPl     as character */
                          , input "":U                        /* p-PlaceAmount    as character */
                          , input string( prt-tqnty )         /* p-qnty           as character */
                          , input string( PricewithNDS )      /* p-price          as character */
                          , input string( prt-SumwithNDS )    /* p-sum            as character */
                      ).
                          end.
                      end. /* p-print-gold = no */
                  end.       /* PrintScale = yes */
                  if PrintParts then do:
                    for each parts no-lock
                       where parts.prod-type = doc-line.prod-type
                         and parts.prod-code = doc-line.prod-code
                         and parts.artic = doc-line.artic
                         and parts.out-code = doc-line.doc-code
      /*                   and gds-dtl.line-num = doc-line.line-num*/
                    :
        
                        assign
                            prt-tqnty =  parts.fact-qnty
                            prt-SumNoNDS = PriceNoNDS * prt-tqnty
                            prt-SumNDS = PricendS * prt-tqnty
                            prt-SumwithNDS = PricewithNDS * prt-tqnty
                        .
                        assign
                            sum-prt-tqnty       = sum-prt-tqnty      +  prt-tqnty
                            sum-prt-SumNoNDS    = sum-prt-SumNoNDS   +  prt-SumNoNDS
                            sum-prt-SumNDS      = sum-prt-SumNDS     +  prt-SumNDS
                            sum-prt-SumwithNDS  = sum-prt-SumwithNDS +  prt-SumwithNDS
                        .
                              display stream Out-stream
                                      PrtName @     temp_gds-name.gds-name
                                      string( bar-code.b-code ) @ tb-code
                                      goods.unit-base
                                      prt-tqnty @ tqnty
                                      PriceNoNDS
                                      PricendS
                                      PricewithNDS
                                      prt-SumNoNDS @ SumNoNDS
                                      prt-SumNDS @ SumNDS
                                      prt-SumwithNDS @ SumwithNDS
                                      sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                      sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                                      with frame f-doc-cost-gold .
                              down stream Out-stream 1 with frame f-doc-cost-gold .
                              { rep/torg-13.i prt- cost -gold }
                              run torg13xl-write-line-data in this-procedure (
                                    input PrtName                     /* p-Name           as character */
                                  , input string( goods.gds-code )    /* p-gdscode        as character */
                                  , input goods.unit-base             /* p-EI             as character */
                                  , input "":U                        /* p-OKEI           as character */
                                  , input "":U                        /* p-AmountInPl     as character */
                                  , input "":U                        /* p-PlaceAmount    as character */
                                  , input string( prt-tqnty )         /* p-qnty           as character */
                                  , input if no-vat then string(PriceNoNDS)
                                                    else string(PriceWithNDS)   /* p-price       as character */
                                  , input if no-vat then string(prt-SumNoNDS)
                                                    else string(prt-SumwithNDS) /* p-sum         as character */
                              ).   
                    end .                            
                  end.
              end.        /*for each gds-dtl ...*/
            end.
            else do:
            for each gds-dtl no-lock
               where gds-dtl.prod-type = doc-line.prod-type
                 and gds-dtl.prod-code = doc-line.prod-code
                 and gds-dtl.artic = doc-line.artic
                 and gds-dtl.doc-code = doc-line.doc-code
            :
                find first gds-prt no-lock
                     where gds-prt.node-code = gds-dtl.prt-code
                .

                assign
                    prt-tqnty =  gds-dtl.fact-qnty
                    prt-SumNoNDS = PriceNoNDS * prt-tqnty
                    prt-SumNDS = PricendS * prt-tqnty
                    prt-SumwithNDS = PricewithNDS * prt-tqnty
                .
                assign
                    sum-prt-tqnty       = sum-prt-tqnty      +  prt-tqnty
                    sum-prt-SumNoNDS    = sum-prt-SumNoNDS   +  prt-SumNoNDS
                    sum-prt-SumNDS      = sum-prt-SumNDS     +  prt-SumNDS
                    sum-prt-SumwithNDS  = sum-prt-SumwithNDS +  prt-SumwithNDS
                .
                if PrintScale = yes
                then do:
                    find first bar-code no-lock
                            where bar-code.gds-code  = goods.gds-code
                            and bar-code.unit-cli  = goods.unit-base
                            and bar-code.node-code = gds-dtl.prt-code
                            and bar-code.part-code = ""
                            and bar-code.in-code   = ""
                    .
                    assign
                        PrtName = goods.gds-name + "//" + gds-prt.f-name
                    .
                    if p-print-gold = yes
                    then do:
                        if costprice = yes
                        then do:
                            display stream Out-stream
                                    PrtName @     temp_gds-name.gds-name
                                    string( bar-code.b-code ) @ tb-code
                                    goods.unit-base
                                    prt-tqnty @ tqnty
                                    PriceNoNDS
                                    PricendS
                                    PricewithNDS
                                    prt-SumNoNDS @ SumNoNDS
                                    prt-SumNDS @ SumNDS
                                    prt-SumwithNDS @ SumwithNDS
                                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                    sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                                    with frame f-doc-cost-gold .
                            down stream Out-stream 1 with frame f-doc-cost-gold .
                            { rep/torg-13.i prt- cost -gold }
                            run torg13xl-write-line-data in this-procedure (
                                  input PrtName                     /* p-Name           as character */
                                , input string( goods.gds-code )    /* p-gdscode        as character */
                                , input goods.unit-base             /* p-EI             as character */
                                , input "":U                        /* p-OKEI           as character */
                                , input "":U                        /* p-AmountInPl     as character */
                                , input "":U                        /* p-PlaceAmount    as character */
                                , input string( prt-tqnty )         /* p-qnty           as character */
                                , input if no-vat then string(PriceNoNDS)
                                                  else string(PriceWithNDS)   /* p-price       as character */
                                , input if no-vat then string(prt-SumNoNDS)
                                                  else string(prt-SumwithNDS) /* p-sum         as character */
                            ).
                        end.        /* costprice = yes */
                        else do:
                            display stream Out-stream
                                    PrtName @     temp_gds-name.gds-name
                                    string( bar-code.b-code ) @ tb-code
                                    goods.unit-base
                                    prt-tqnty @ tqnty
                                    PriceNoNDS
                                    PricendS
                                    PricewithNDS
                                    prt-SumNoNDS @ SumNoNDS
                                    prt-SumNDS @ SumNDS
                                    prt-SumwithNDS @ SumwithNDS
                                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                    sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                                    with frame f-doc-doc-gold .
                            down stream Out-stream 1 with frame f-doc-doc-gold .
                            { rep/torg-13.i prt- doc -gold }
                            run torg13xl-write-line-data in this-procedure (
                                  input PrtName                     /* p-Name           as character */
                                , input string( goods.gds-code )    /* p-gdscode        as character */
                                , input goods.unit-base             /* p-EI             as character */
                                , input "":U                        /* p-OKEI           as character */
                                , input "":U                        /* p-AmountInPl     as character */
                                , input "":U                        /* p-PlaceAmount    as character */
                                , input string( prt-tqnty )         /* p-qnty           as character */
                                , input string( PricewithNDS )      /* p-price          as character */
                                , input string( prt-SumwithNDS )    /* p-sum            as character */
                            ).
                        end.
                    end.        /* p-print-gold = yes */
                    else do:
                        if costprice = yes
                        then do:
                            display stream Out-stream
                                    PrtName @     temp_gds-name.gds-name
                                    string( bar-code.b-code ) @ tb-code
                                    goods.unit-base
                                    prt-tqnty @ tqnty
                                    PriceNoNDS
                                    PricendS
                                    PricewithNDS
                                    prt-SumNoNDS @ SumNoNDS
                                    prt-SumNDS @ SumNDS
                                    prt-SumwithNDS @ SumwithNDS
                                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                    sym11 sym12 sym13 sym14 sym15 sym16 sym17
                                    with frame f-doc-cost .
                            down stream Out-stream 1 with frame f-doc-cost .
                            { rep/torg-13.i prt- cost }
                            run torg13xl-write-line-data in this-procedure (
                                  input PrtName                     /* p-Name           as character */
                                , input string( goods.gds-code )    /* p-gdscode        as character */
                                , input goods.unit-base             /* p-EI             as character */
                                , input "":U                        /* p-OKEI           as character */
                                , input "":U                        /* p-AmountInPl     as character */
                                , input "":U                        /* p-PlaceAmount    as character */
                                , input string( prt-tqnty )         /* p-qnty as character */
                                , input if no-vat then string(PriceNoNDS)
                                                  else string(PriceWithNDS)   /* p-price       as character */
                                , input if no-vat then string(prt-SumNoNDS)
                                                  else string(prt-SumwithNDS) /* p-sum         as character */
                            ).
                        end.        /* costprice = yes */
                        else do:
                            display stream Out-stream
                                    PrtName @     temp_gds-name.gds-name
                                    string( bar-code.b-code ) @ tb-code
                                    goods.unit-base
                                    prt-tqnty @ tqnty
                                    PriceNoNDS
                                    PricendS
                                    PricewithNDS
                                    prt-SumNoNDS @ SumNoNDS
                                    prt-SumNDS @ SumNDS
                                    prt-SumwithNDS @ SumwithNDS
                                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                    sym11 sym12 sym13 sym14 sym15 sym16 sym17
                                    with frame f-doc-doc .
                            down stream Out-stream 1 with frame f-doc-doc .
                            { rep/torg-13.i prt- doc }
                    run torg13xl-write-line-data in this-procedure (
                          input PrtName                     /* p-Name           as character */
                        , input string( goods.gds-code )    /* p-gdscode        as character */
                        , input goods.unit-base             /* p-EI             as character */
                        , input "":U                        /* p-OKEI           as character */
                        , input "":U                        /* p-AmountInPl     as character */
                        , input "":U                        /* p-PlaceAmount    as character */
                        , input string( prt-tqnty )         /* p-qnty           as character */
                        , input string( PricewithNDS )      /* p-price          as character */
                        , input string( prt-SumwithNDS )    /* p-sum            as character */
                    ).
                        end.
                    end. /* p-print-gold = no */
                end.       /* PrintScale = yes */
            end.        /*for each gds-dtl ...*/               
            end.
            
            assign
                tqnty       = sum-prt-tqnty
                SumNoNDS    = sum-prt-SumNoNDS
                SumNDS      = sum-prt-SumNDS
                SumwithNDS  = sum-prt-SumwithNDS
            .
            if not PrintScale
            then do:
                    find bar-code where bar-code.gds-code  = goods.gds-code
                                    and bar-code.unit-cli  = goods.unit-base
                                    and bar-code.node-code = rootnode_code
                                    and bar-code.part-code = ""
                                    and bar-code.in-code   = ""
                    no-lock .
                    if p-print-gold = yes
                    then do:
                        if costprice = yes
                        then do:
                            display stream Out-stream
                                    goods.artic
                                    temp_gds-name.gds-name
                                    goods.sort
                                    string( bar-code.b-code ) @ tb-code
                                    goods.unit-base
                                    tqnty
                                    qnty-pl when v-not-gold = no
                                    PriceNoNDS
                                    PricendS
                                    PricewithNDS
                                    SumNoNDS
                                    SumNDS
                                    SumwithNDS
                                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                    sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                                    with frame f-doc-cost-gold .
                            down stream Out-stream 1 with frame f-doc-cost-gold .
                            { rep/torg-13.i " " cost -gold }
                            run torg13xl-write-line-data in this-procedure (
                                input goods.artic + " ":U + goods.gds-name      /* p-Name           as character */
                              , input string( goods.gds-code )    /* p-gdscode        as character */
                              , input goods.unit-base             /* p-EI             as character */
                              , input "":U                        /* p-OKEI           as character */
                              , input "":U                        /* p-AmountInPl     as character */
                              , input "":U                        /* p-PlaceAmount    as character */
                              , input string( tqnty )             /* p-qnty           as character */
                              , input if no-vat then string( PriceNoNDS )
                                                else string( PriceWithNDS ) /* p-price        as character */
                              , input if no-vat then string( SumNoNDS )
                                                else string( SumWithNDS ) /* p-sum          as character */
                              ).
                        end.           /* costprice = yes */
                        else do:
                            display stream Out-stream
                                    temp_gds-name.gds-name
                                    goods.artic
                                    goods.sort
                                    string( bar-code.b-code ) @ tb-code
                                    goods.unit-base
                                    tqnty
                                    qnty-pl when v-not-gold = no
                                    PriceNoNDS
                                    PricendS
                                    PricewithNDS
                                    SumNoNDS
                                    SumNDS
                                    SumwithNDS
                                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                    sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                                    with frame f-doc-doc-gold .
                            down stream Out-stream 1 with frame f-doc-doc-gold .
                            { rep/torg-13.i " " doc -gold }
                            run torg13xl-write-line-data in this-procedure (
                                input goods.artic + " ":U + goods.gds-name      /* p-Name           as character */
                              , input string( goods.gds-code )    /* p-gdscode        as character */
                              , input goods.unit-base             /* p-EI             as character */
                              , input "":U                        /* p-OKEI           as character */
                              , input "":U                        /* p-AmountInPl     as character */
                              , input "":U                        /* p-PlaceAmount    as character */
                              , input string( tqnty )             /* p-qnty           as character */
                              , input string( PriceWithNDS )      /* p-price        as character */
                              , input string( SumWithNDS )        /* p-sum          as character */
                    ).
                        end.        /* costprice = no */
                    end.        /* p-print-gold = yes */
                    else do:
                        if costprice = yes
                        then do:
                            display stream Out-stream
                                    temp_gds-name.gds-name
                                    goods.artic
                                    string( bar-code.b-code ) @ tb-code
                                    goods.unit-base
                                    tqnty
                                    PriceNoNDS
                                    PricendS
                                    PricewithNDS
                                    SumNoNDS
                                    SumNDS
                                    SumwithNDS
                                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                    sym11 sym12 sym13 sym14 sym15 sym16 sym17
                                    with frame f-doc-cost .
                            down stream Out-stream 1 with frame f-doc-cost .
                            { rep/torg-13.i " " cost }
                            run torg13xl-write-line-data in this-procedure (
                                input goods.artic + " ":U + goods.gds-name      /* p-Name           as character */
                              , input string( goods.gds-code )    /* p-gdscode        as character */
                              , input goods.unit-base             /* p-EI             as character */
                              , input "":U                        /* p-OKEI           as character */
                              , input "":U                        /* p-AmountInPl     as character */
                              , input "":U                        /* p-PlaceAmount    as character */
                              , input string( tqnty )             /* p-qnty           as character */
                              , input if no-vat then string( PriceNoNDS )
                                                else string( PriceWithNDS ) /* p-price        as character */
                              , input if no-vat then string( SumNoNDS )
                                                else string( SumWithNDS ) /* p-sum          as character */
                              ).
                        end.           /* costprice = yes */
                        else do:
                            display stream Out-stream
                                    temp_gds-name.gds-name
                                    goods.artic
                                    string( bar-code.b-code ) @ tb-code
                                    goods.unit-base
                                    tqnty
                                    PriceNoNDS
                                    PricendS
                                    PricewithNDS
                                    SumNoNDS
                                    SumNDS
                                    SumwithNDS
                                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                    sym11 sym12 sym13 sym14 sym15 sym16 sym17
                                    with frame f-doc-doc .
                            down stream Out-stream 1 with frame f-doc-doc .
                            { rep/torg-13.i " " doc }
                    run torg13xl-write-line-data in this-procedure (
                          input goods.artic + " ":U + goods.gds-name      /* p-Name           as character */
                        , input string( goods.gds-code )    /* p-gdscode        as character */
                        , input goods.unit-base             /* p-EI             as character */
                        , input "":U                        /* p-OKEI           as character */
                        , input "":U                        /* p-AmountInPl     as character */
                        , input "":U                        /* p-PlaceAmount    as character */
                        , input string( tqnty )             /* p-qnty           as character */
                        , input string( PricewithNDS )      /* p-price          as character */
                        , input string( SumwithNDS )        /* p-sum            as character */
                    ).
                        end.        /* costprice = no */
                    end.        /* p-print-gold = no */
                    assign
                        v-line-counter = v-line-counter + 1
                    .
                    LineCounter = LineCounter + 1 .
                    if p-break-name = yes
                    then do:
                        run display-gds-name in this-procedure .
                    end.
                end.
    end.
    else do:    /* пустая шкала */
            
            if t-doc.ext-doc-type = {&TDEDT_Pri_Perem}
            or t-doc.ext-doc-type = {&TDEDT_Ras_Perem}
            or t-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem}
            then do: 
              find first bar-code no-lock
                   where bar-code.gds-code = goods.gds-code
                     and bar-code.unit-cli = goods.unit-base
                     and bar-code.node-code = rootnode_code
                     and bar-code.part-code = ""
                     and bar-code.in-code = ""
              .
              find first gds-dtl no-lock
                 where gds-dtl.doc-code = doc-line.doc-code
                   and gds-dtl.prod-type = doc-line.prod-type
                   and gds-dtl.prod-code = doc-line.prod-code
                   and gds-dtl.artic = doc-line.artic
                   and gds-dtl.prt-code = rootnode_code
              .
              assign
                  tqnty = gds-dtl.fact-qnty
                  unit-str = goods.unit-base
                  SumNoNDS = PriceNoNDS * tqnty
                  SumNDS = PricendS * tqnty
                  SumwithNDS = PricewithNDS * tqnty
              .
              if PrintScale = yes
              then do:
                  find first bar-code no-lock
                          where bar-code.gds-code  = goods.gds-code
                          and bar-code.unit-cli  = goods.unit-base
                          and bar-code.node-code = gds-dtl.prt-code
                          and bar-code.part-code = ""
                          and bar-code.in-code   = ""
                  .
                  assign
                      PrtName = goods.gds-name + "//" + gds-prt.f-name
                  .
                  if p-print-gold = yes
                  then do:
                      if costprice = yes
                      then do:
                          display stream Out-stream
                                  PrtName @     temp_gds-name.gds-name
                                  string( bar-code.b-code ) @ tb-code
                                  goods.unit-base
                                  prt-tqnty @ tqnty
                                  PriceNoNDS
                                  PricendS
                                  PricewithNDS
                                  prt-SumNoNDS @ SumNoNDS
                                  prt-SumNDS @ SumNDS
                                  prt-SumwithNDS @ SumwithNDS
                                  sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                  sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                                  with frame f-doc-cost-gold .
                          down stream Out-stream 1 with frame f-doc-cost-gold .
                          { rep/torg-13.i prt- cost -gold }
                          run torg13xl-write-line-data in this-procedure (
                                input PrtName                     /* p-Name           as character */
                              , input string( goods.gds-code )    /* p-gdscode        as character */
                              , input goods.unit-base             /* p-EI             as character */
                              , input "":U                        /* p-OKEI           as character */
                              , input "":U                        /* p-AmountInPl     as character */
                              , input "":U                        /* p-PlaceAmount    as character */
                              , input string( prt-tqnty )         /* p-qnty           as character */
                              , input if no-vat then string(PriceNoNDS)
                                                else string(PriceWithNDS)   /* p-price       as character */
                              , input if no-vat then string(prt-SumNoNDS)
                                                else string(prt-SumwithNDS) /* p-sum         as character */
                          ).
                      end.        /* costprice = yes */
                      else do:
                          display stream Out-stream
                                  PrtName @     temp_gds-name.gds-name
                                  string( bar-code.b-code ) @ tb-code
                                  goods.unit-base
                                  prt-tqnty @ tqnty
                                  PriceNoNDS
                                  PricendS
                                  PricewithNDS
                                  prt-SumNoNDS @ SumNoNDS
                                  prt-SumNDS @ SumNDS
                                  prt-SumwithNDS @ SumwithNDS
                                  sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                  sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                                  with frame f-doc-doc-gold .
                          down stream Out-stream 1 with frame f-doc-doc-gold .
                          { rep/torg-13.i prt- doc -gold }
                          run torg13xl-write-line-data in this-procedure (
                                input PrtName                     /* p-Name           as character */
                              , input string( goods.gds-code )    /* p-gdscode        as character */
                              , input goods.unit-base             /* p-EI             as character */
                              , input "":U                        /* p-OKEI           as character */
                              , input "":U                        /* p-AmountInPl     as character */
                              , input "":U                        /* p-PlaceAmount    as character */
                              , input string( prt-tqnty )         /* p-qnty           as character */
                              , input string( PricewithNDS )      /* p-price          as character */
                              , input string( prt-SumwithNDS )    /* p-sum            as character */
                          ).
                      end.
                  end.        /* p-print-gold = yes */
                  else do:
                      if costprice = yes
                      then do:
                          display stream Out-stream
                                  PrtName @     temp_gds-name.gds-name
                                  string( bar-code.b-code ) @ tb-code
                                  goods.unit-base
                                  prt-tqnty @ tqnty
                                  PriceNoNDS
                                  PricendS
                                  PricewithNDS
                                  prt-SumNoNDS @ SumNoNDS
                                  prt-SumNDS @ SumNDS
                                  prt-SumwithNDS @ SumwithNDS
                                  sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                  sym11 sym12 sym13 sym14 sym15 sym16 sym17
                                  with frame f-doc-cost .
                          down stream Out-stream 1 with frame f-doc-cost .
                          { rep/torg-13.i prt- cost }
                          run torg13xl-write-line-data in this-procedure (
                                input PrtName                     /* p-Name           as character */
                              , input string( goods.gds-code )    /* p-gdscode        as character */
                              , input goods.unit-base             /* p-EI             as character */
                              , input "":U                        /* p-OKEI           as character */
                              , input "":U                        /* p-AmountInPl     as character */
                              , input "":U                        /* p-PlaceAmount    as character */
                              , input string( prt-tqnty )         /* p-qnty as character */
                              , input if no-vat then string(PriceNoNDS)
                                                else string(PriceWithNDS)   /* p-price       as character */
                              , input if no-vat then string(prt-SumNoNDS)
                                                else string(prt-SumwithNDS) /* p-sum         as character */
                          ).
                      end.        /* costprice = yes */
                      else do:
                          display stream Out-stream
                                  PrtName @     temp_gds-name.gds-name
                                  string( bar-code.b-code ) @ tb-code
                                  goods.unit-base
                                  prt-tqnty @ tqnty
                                  PriceNoNDS
                                  PricendS
                                  PricewithNDS
                                  prt-SumNoNDS @ SumNoNDS
                                  prt-SumNDS @ SumNDS
                                  prt-SumwithNDS @ SumwithNDS
                                  sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                                  sym11 sym12 sym13 sym14 sym15 sym16 sym17
                                  with frame f-doc-doc .
                          down stream Out-stream 1 with frame f-doc-doc .
                          { rep/torg-13.i prt- doc }
                  run torg13xl-write-line-data in this-procedure (
                        input PrtName                     /* p-Name           as character */
                      , input string( goods.gds-code )    /* p-gdscode        as character */
                      , input goods.unit-base             /* p-EI             as character */
                      , input "":U                        /* p-OKEI           as character */
                      , input "":U                        /* p-AmountInPl     as character */
                      , input "":U                        /* p-PlaceAmount    as character */
                      , input string( prt-tqnty )         /* p-qnty           as character */
                      , input string( PricewithNDS )      /* p-price          as character */
                      , input string( prt-SumwithNDS )    /* p-sum            as character */
                  ).
                      end.
                  end. /* p-print-gold = no */
              end.       /* PrintScale = yes */
              if PrintParts then do:
                for each parts no-lock
                   where parts.prod-type = doc-line.prod-type
                     and parts.prod-code = doc-line.prod-code
                     and parts.artic = doc-line.artic
                     and parts.out-code = doc-line.doc-code
                     break by parts.price-rubl
  /*                   and gds-dtl.line-num = doc-line.line-num*/
                :
                  if first-of(parts.price-rubl)
                  then do :
                    prt-tqnty = 0 .
                    PriceNoNDS = (parts.price-rubl / (1 + (parts.vat-pc / 100))) .
                    PricendS = (parts.price-rubl * parts.vat-pc / (100 + parts.vat-pc)) .
                    PricewithNDS = parts.price-rubl .
                  end .
                  
    
                  assign
                      prt-tqnty = prt-tqnty + parts.fact-qnty
                      prt-SumNoNDS = PriceNoNDS * prt-tqnty
                      prt-SumNDS = PricendS * prt-tqnty
                      prt-SumwithNDS = PricewithNDS * prt-tqnty
                  .
                  assign
                      sum-prt-tqnty       = sum-prt-tqnty      +  prt-tqnty
                      sum-prt-SumNoNDS    = sum-prt-SumNoNDS   +  prt-SumNoNDS
                      sum-prt-SumNDS      = sum-prt-SumNDS     +  prt-SumNDS
                      sum-prt-SumwithNDS  = sum-prt-SumwithNDS +  prt-SumwithNDS
                  .
                    
                  if last-of(parts.price-rubl)
                  then do :  
                    display stream Out-stream
                            temp_gds-name.gds-name
                            goods.artic
                            string( bar-code.b-code ) @ tb-code
                            goods.unit-base
                            prt-tqnty @ tqnty
                            PriceNoNDS
                            PricendS
                            PricewithNDS
                            prt-SumNoNDS @ SumNoNDS
                            prt-SumNDS @ SumNDS
                            prt-SumwithNDS @ SumwithNDS
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                            with frame f-doc-cost-gold .
                    down stream Out-stream 1 with frame f-doc-cost-gold .
                    { rep/torg-13.i prt- cost -gold }
                    run torg13xl-write-line-data in this-procedure (
                          input goods.artic + " ":U + goods.gds-name         /* p-Name           as character */
                        , input string( goods.gds-code )    /* p-gdscode        as character */
                        , input goods.unit-base             /* p-EI             as character */
                        , input "":U                        /* p-OKEI           as character */
                        , input "":U                        /* p-AmountInPl     as character */
                        , input "":U                        /* p-PlaceAmount    as character */
                        , input string( prt-tqnty )         /* p-qnty           as character */
                        , input if no-vat then string(PriceNoNDS)
                                          else string(PriceWithNDS)   /* p-price       as character */
                        , input if no-vat then string(prt-SumNoNDS)
                                          else string(prt-SumwithNDS) /* p-sum         as character */
                    ).  
                  end .         
                end .                            
              end.
              else do :
                find first bar-code no-lock
                     where bar-code.gds-code = goods.gds-code
                       and bar-code.unit-cli = goods.unit-base
                       and bar-code.node-code = rootnode_code
                       and bar-code.part-code = ""
                       and bar-code.in-code = ""
                .
                find first gds-dtl no-lock
                   where gds-dtl.doc-code = doc-line.doc-code
                     and gds-dtl.prod-type = doc-line.prod-type
                     and gds-dtl.prod-code = doc-line.prod-code
                     and gds-dtl.artic = doc-line.artic
                     and gds-dtl.prt-code = rootnode_code
                .
                assign
                    tqnty = gds-dtl.fact-qnty
                    unit-str = goods.unit-base
                    SumNoNDS = PriceNoNDS * tqnty
                    SumNDS = PricendS * tqnty
                    SumwithNDS = PricewithNDS * tqnty
                .
                if p-print-gold = yes
                then do:
                    if costprice = yes
                    then do:
                        display stream Out-stream
                            goods.artic
                            temp_gds-name.gds-name
                            goods.sort
                            string( bar-code.b-code ) @ tb-code
                            unit-str @ goods.unit-base
                            tqnty
                            qnty-pl when v-not-gold = no
                            PriceNoNDS
                            PricendS
                            PricewithNDS
                            SumNoNDS
                            SumNDS
                            SumwithNDS
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                            with frame f-doc-cost-gold .
                        down stream Out-stream 1 with frame f-doc-cost-gold .
                        { rep/torg-13.i " " cost -gold }
                        run torg13xl-write-line-data in this-procedure (
                            input goods.artic + " ":U + goods.gds-name      /* p-Name           as character */
                          , input string( goods.gds-code )    /* p-gdscode        as character */
                          , input goods.unit-base             /* p-EI             as character */
                          , input "":U                        /* p-OKEI           as character */
                          , input "":U                        /* p-AmountInPl     as character */
                          , input "":U                        /* p-PlaceAmount    as character */
                          , input string( tqnty )             /* p-qnty           as character */
                          , input if no-vat then string( PriceNoNDS )
                                            else string( PriceWithNDS ) /* p-price        as character */
                          , input if no-vat then string(SumNoNDS)
                                            else string(SumwithNDS)     /* p-sum          as character */
                        ).
                    end.       /* costprice = yes */
                    else do:
                        display stream Out-stream
                            goods.artic
                            temp_gds-name.gds-name
                            goods.sort
                            string( bar-code.b-code ) @ tb-code
                            unit-str @ goods.unit-base
                            tqnty
                            qnty-pl when v-not-gold = no
                            PriceNoNDS
                            PricendS
                            PricewithNDS
                            SumNoNDS
                            SumNDS
                            SumwithNDS
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                            with frame f-doc-doc-gold .
                        down stream Out-stream 1 with frame f-doc-doc-gold .
                        { rep/torg-13.i " " doc -gold }
                        run torg13xl-write-line-data in this-procedure (
                            input goods.artic + " ":U + goods.gds-name      /* p-Name           as character */
                          , input string( goods.gds-code )    /* p-gdscode        as character */
                          , input goods.unit-base             /* p-EI             as character */
                          , input "":U                        /* p-OKEI           as character */
                          , input "":U                        /* p-AmountInPl     as character */
                          , input "":U                        /* p-PlaceAmount    as character */
                          , input string( tqnty )             /* p-qnty           as character */
                          , input string( PriceWithNDS )      /* p-price        as character */
                          , input string(SumwithNDS)          /* p-sum          as character */
                        ).
                    end.       /* costprice = no */
                end.        /* p-print-gold = yes */
                else do:
                    if costprice = yes
                    then do:
                        display stream Out-stream
                            goods.artic
                            temp_gds-name.gds-name
                            string( bar-code.b-code ) @ tb-code
                            unit-str @ goods.unit-base
                            tqnty
                            PriceNoNDS
                            PricendS
                            PricewithNDS
                            SumNoNDS
                            SumNDS
                            SumwithNDS
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17
                            with frame f-doc-cost .
                        down stream Out-stream 1 with frame f-doc-cost .
                        { rep/torg-13.i " " cost }
                        run torg13xl-write-line-data in this-procedure (
                            input goods.artic + " ":U + goods.gds-name      /* p-Name           as character */
                          , input string( goods.gds-code )    /* p-gdscode        as character */
                          , input goods.unit-base             /* p-EI             as character */
                          , input "":U                        /* p-OKEI           as character */
                          , input "":U                        /* p-AmountInPl     as character */
                          , input "":U                        /* p-PlaceAmount    as character */
                          , input string( tqnty )             /* p-qnty           as character */
                          , input if no-vat then string( PriceNoNDS )
                                            else string( PriceWithNDS ) /* p-price        as character */
                          , input if no-vat then string(SumNoNDS)
                                            else string(SumwithNDS)     /* p-sum          as character */
                        ).
                    end.       /* costprice = yes */
                    else do:
                        display stream Out-stream
                            goods.artic
                            temp_gds-name.gds-name
                            string( bar-code.b-code ) @ tb-code
                            unit-str @ goods.unit-base
                            tqnty
                            PriceNoNDS
                            PricendS
                            PricewithNDS
                            SumNoNDS
                            SumNDS
                            SumwithNDS
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17
                            with frame f-doc-doc .
                        down stream Out-stream 1 with frame f-doc-doc .
                        { rep/torg-13.i " " doc }
                run torg13xl-write-line-data in this-procedure (
                      input goods.artic + " ":U + goods.gds-name      /* p-Name           as character */
                    , input string( goods.gds-code )    /* p-gdscode        as character */
                    , input goods.unit-base             /* p-EI             as character */
                    , input "":U                        /* p-OKEI           as character */
                    , input "":U                        /* p-AmountInPl     as character */
                    , input "":U                        /* p-PlaceAmount    as character */
                    , input string( tqnty )             /* p-qnty           as character */
                          , input string( PriceWithNDS )      /* p-price        as character */
                    , input string( SumwithNDS )        /* p-sum            as character */
                ).
                    end.       /* costprice = no */
                end.        /* p-print-gold = no */
              end .
            end.
            else do:
            
              find first bar-code no-lock
                   where bar-code.gds-code = goods.gds-code
                     and bar-code.unit-cli = goods.unit-base
                     and bar-code.node-code = rootnode_code
                     and bar-code.part-code = ""
                     and bar-code.in-code = ""
              .
              find first gds-dtl no-lock
                 where gds-dtl.doc-code = doc-line.doc-code
                   and gds-dtl.prod-type = doc-line.prod-type
                   and gds-dtl.prod-code = doc-line.prod-code
                   and gds-dtl.artic = doc-line.artic
                   and gds-dtl.prt-code = rootnode_code
              .
              assign
                  tqnty = gds-dtl.fact-qnty
                  unit-str = goods.unit-base
                  SumNoNDS = PriceNoNDS * tqnty
                  SumNDS = PricendS * tqnty
                  SumwithNDS = PricewithNDS * tqnty
              .
              if p-print-gold = yes
              then do:
                  if costprice = yes
                  then do:
                      display stream Out-stream
                          goods.artic
                          temp_gds-name.gds-name
                          goods.sort
                          string( bar-code.b-code ) @ tb-code
                          unit-str @ goods.unit-base
                          tqnty
                          qnty-pl when v-not-gold = no
                          PriceNoNDS
                          PricendS
                          PricewithNDS
                          SumNoNDS
                          SumNDS
                          SumwithNDS
                          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                          sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                          with frame f-doc-cost-gold .
                      down stream Out-stream 1 with frame f-doc-cost-gold .
                      { rep/torg-13.i " " cost -gold }
                      run torg13xl-write-line-data in this-procedure (
                          input goods.artic + " ":U + goods.gds-name      /* p-Name           as character */
                        , input string( goods.gds-code )    /* p-gdscode        as character */
                        , input goods.unit-base             /* p-EI             as character */
                        , input "":U                        /* p-OKEI           as character */
                        , input "":U                        /* p-AmountInPl     as character */
                        , input "":U                        /* p-PlaceAmount    as character */
                        , input string( tqnty )             /* p-qnty           as character */
                        , input if no-vat then string( PriceNoNDS )
                                          else string( PriceWithNDS ) /* p-price        as character */
                        , input if no-vat then string(SumNoNDS)
                                          else string(SumwithNDS)     /* p-sum          as character */
                      ).
                  end.       /* costprice = yes */
                  else do:
                      display stream Out-stream
                          goods.artic
                          temp_gds-name.gds-name
                          goods.sort
                          string( bar-code.b-code ) @ tb-code
                          unit-str @ goods.unit-base
                          tqnty
                          qnty-pl when v-not-gold = no
                          PriceNoNDS
                          PricendS
                          PricewithNDS
                          SumNoNDS
                          SumNDS
                          SumwithNDS
                          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                          sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                          with frame f-doc-doc-gold .
                      down stream Out-stream 1 with frame f-doc-doc-gold .
                      { rep/torg-13.i " " doc -gold }
                      run torg13xl-write-line-data in this-procedure (
                          input goods.artic + " ":U + goods.gds-name      /* p-Name           as character */
                        , input string( goods.gds-code )    /* p-gdscode        as character */
                        , input goods.unit-base             /* p-EI             as character */
                        , input "":U                        /* p-OKEI           as character */
                        , input "":U                        /* p-AmountInPl     as character */
                        , input "":U                        /* p-PlaceAmount    as character */
                        , input string( tqnty )             /* p-qnty           as character */
                        , input string( PriceWithNDS )      /* p-price        as character */
                        , input string(SumwithNDS)          /* p-sum          as character */
                      ).
                  end.       /* costprice = no */
              end.        /* p-print-gold = yes */
              else do:
                  if costprice = yes
                  then do:
                      display stream Out-stream
                          goods.artic
                          temp_gds-name.gds-name
                          string( bar-code.b-code ) @ tb-code
                          unit-str @ goods.unit-base
                          tqnty
                          PriceNoNDS
                          PricendS
                          PricewithNDS
                          SumNoNDS
                          SumNDS
                          SumwithNDS
                          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                          sym11 sym12 sym13 sym14 sym15 sym16 sym17
                          with frame f-doc-cost .
                      down stream Out-stream 1 with frame f-doc-cost .
                      { rep/torg-13.i " " cost }
                      run torg13xl-write-line-data in this-procedure (
                          input goods.artic + " ":U + goods.gds-name      /* p-Name           as character */
                        , input string( goods.gds-code )    /* p-gdscode        as character */
                        , input goods.unit-base             /* p-EI             as character */
                        , input "":U                        /* p-OKEI           as character */
                        , input "":U                        /* p-AmountInPl     as character */
                        , input "":U                        /* p-PlaceAmount    as character */
                        , input string( tqnty )             /* p-qnty           as character */
                        , input if no-vat then string( PriceNoNDS )
                                          else string( PriceWithNDS ) /* p-price        as character */
                        , input if no-vat then string(SumNoNDS)
                                          else string(SumwithNDS)     /* p-sum          as character */
                      ).
                  end.       /* costprice = yes */
                  else do:
                      display stream Out-stream
                          goods.artic
                          temp_gds-name.gds-name
                          string( bar-code.b-code ) @ tb-code
                          unit-str @ goods.unit-base
                          tqnty
                          PriceNoNDS
                          PricendS
                          PricewithNDS
                          SumNoNDS
                          SumNDS
                          SumwithNDS
                          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                          sym11 sym12 sym13 sym14 sym15 sym16 sym17
                          with frame f-doc-doc .
                      down stream Out-stream 1 with frame f-doc-doc .
                      { rep/torg-13.i " " doc }
              run torg13xl-write-line-data in this-procedure (
                    input goods.artic + " ":U + goods.gds-name      /* p-Name           as character */
                  , input string( goods.gds-code )    /* p-gdscode        as character */
                  , input goods.unit-base             /* p-EI             as character */
                  , input "":U                        /* p-OKEI           as character */
                  , input "":U                        /* p-AmountInPl     as character */
                  , input "":U                        /* p-PlaceAmount    as character */
                  , input string( tqnty )             /* p-qnty           as character */
                        , input string( PriceWithNDS )      /* p-price        as character */
                  , input string( SumwithNDS )        /* p-sum            as character */
              ).
                  end.       /* costprice = no */
              end.        /* p-print-gold = no */
            end .
            assign
                v-line-counter = v-line-counter + 1
            .
            LineCounter = LineCounter + 1 .
            if p-break-name = yes
            then do:
                run display-gds-name in this-procedure .
            end.
    end.

    assign
        sum-tqnty       =   sum-tqnty       + tqnty
        sum-SumNoNDS    =   sum-SumNoNDS    + SumNoNDS
        sum-SumNDS      =   sum-SumNDS      + SumNDS
        sum-SumwithNDS  =   sum-SumwithNDS  + SumwithNDS
    .
end.
end procedure. /* print-doc-line */





/*==============================================================*/
/*---S-------- Печать линии группы в документе -----------------*/
procedure print-group-line :
do
on error undo, return error
:
  put stream out-stream
      skip
      ":" space(5)
      "Группа  " space(2)
      goods.grp-name format "X(100)"
  .
/*  down stream out-stream 1 with frame f-doc .*/
end.
end procedure. /* print-group-line */
/*---E-------- Печать линии группы в документе -----------------*/

/*==============================================================*/
/*---S------ Печать линии производителя в документе ------------*/
procedure print-prod-line :
do
on error undo, return error
:
  put stream out-stream
      skip
      ":" space(5)
      "Производитель  " space(2)
      string(clients.obj-code) + {&space-char} + clients.obj-name format "X(100)"
  .
/*  down stream out-stream 1 with frame f-doc .*/
end.
end procedure. /* print-group-line */
/*---E------ Печать линии производителя в документе ------------*/

/*==========================================================================*/
procedure display-gds-name :
do
on error undo, return error
:
    for each temp_gds-name
    break by temp_gds-name.string-num
    :
        if not first(temp_gds-name.string-num)
        then do:
            if p-print-gold = yes
            then do:
                if costprice = yes
                then do:
                    display stream out-stream
                            temp_gds-name.gds-name
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                            with frame f-doc-cost-gold .
                    down stream out-stream 1 with frame f-doc-cost-gold .
                    { rep/torg-13.i no-sum cost -gold }
                end.
                else do:
                    display stream out-stream
                            temp_gds-name.gds-name
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                            with frame f-doc-doc-gold .
                    down stream out-stream 1 with frame f-doc-doc-gold .
                    { rep/torg-13.i no-sum doc -gold }
                end.
            end.        /* p-print-gold = yes */
            else do:
                if costprice = yes
                then do:
                    display stream out-stream
                            temp_gds-name.gds-name
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17
                            with frame f-doc-cost .
                    down stream out-stream 1 with frame f-doc-cost .
                    { rep/torg-13.i no-sum cost }
                end.
                else do:
                    display stream out-stream
                            temp_gds-name.gds-name
                            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                            sym11 sym12 sym13 sym14 sym15 sym16 sym17
                            with frame f-doc-doc .
                    down stream out-stream 1 with frame f-doc-doc .
                    { rep/torg-13.i no-sum doc }
                end.
            end.        /* p-print-gold = no */
            assign
                LineCounter = LineCounter + 1
            .
        end.        /* not first(temp_gds-name.string-num) */
    end.        /* for each temp_gds-name */
end.
end procedure. /* display-gds-name */




/*==========================================================================*/
procedure get-cli-qnty :
do
on error undo, return error
:
define input parameter p-doc-line-recid    as recid                no-undo.
define output parameter p-cli-qnty         like doc-line.cli-qnty  no-undo.

    define buffer buf_gold_parts       for parts.
    define buffer buf_gold_doc-line    for doc-line.

    find first buf_gold_doc-line no-lock
         where recid(buf_gold_doc-line) = p-doc-line-recid
    .
    assign
        p-cli-qnty = 0
    .
    for each buf_gold_parts no-lock
       where buf_gold_parts.obj-type     = buf_gold_doc-line.obj-type
         and buf_gold_parts.obj-code     = buf_gold_doc-line.obj-code
         and buf_gold_parts.artic        = buf_gold_doc-line.artic
         and buf_gold_parts.prod-type    = buf_gold_doc-line.prod-type
         and buf_gold_parts.prod-code    = buf_gold_doc-line.prod-code
         and buf_gold_parts.out-code     = buf_gold_doc-line.doc-code
         
    :
        if buf_gold_parts.fact-qnty <> 0
        then do:
            assign
                p-cli-qnty = p-cli-qnty + buf_gold_parts.cli-qnty
            .
        end.
    end.
end.
end procedure. /* get-cli-qnty ( input buf_doc-line ) */