block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: torg-0.p $
$Archive: rep/torg-0.p $

Приложение к документу по перемещению товара

Автор: Демин Алексей Сергеевич
Дата создания: 09/09/05
Author: Alexey Demin
Creation date: 09/09/05

Input:

Output:

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-trn-doc-recid      as recid            no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: torg-0.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/torg-0.p $":U .
define variable vss-description as character no-undo init "Приложение к документу по перемещению товара".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ rep/p-fmt.i    }
{ rep/r-getsum.i }
{ cmp/str-glbl.i }
{ rep/fmtcli.i   }
{ rep/torgconf.i }

&scop left-margin 5
&scop right-margin 190
&scop max-width 184
&scop tab-stop1 44
&scop max-width-from-tab1 86
&scop tab-stop2 60
&scop max-width-from-tab2 70
&scop tab-stop3 80
&scop tab-stop4 100
&scop note-line-size 12
&scop bottom-page-line-size 2
&scop group-line-size 2
&scop page-result-line-size 2

/*----S----- Таблица --------------------------------*/
&GLOB P-S 5
&GLOB P-X 191        /*длина линии*/
&GLOB P-X0 189       /*длина внутренней линии = длина линии - 2*/
&GLOB P-C3-X  35     /*ширина колонки названия товара*/

&GLOB P-C2-S  {&P-S} + 11
&GLOB P-C3-S  {&P-S} + 28
&GLOB P-C4-S  {&P-S} + 79
&GLOB P-C5-S  {&P-S} + 91
&GLOB P-C6-S  {&P-S} + 104
&GLOB P-C7-S  {&P-S} + 119
&GLOB P-C8-S  {&P-S} + 132
&GLOB P-C9-S  {&P-S} + 147
&GLOB P-C10-S {&P-S} + 138
&GLOB P-C11-S {&P-S} + 147
&GLOB P-C12-S {&P-S} + 153
&GLOB P-C13-S {&P-S} + 163
&GLOB P-C14-S {&P-S} + 176
&GLOB P-E     {&P-S} + 191
/*----E----- Таблица --------------------------------*/

do
on error undo, return error
:

def shared var CostPrice    as logical          no-undo.
def shared var sort-name    as logical          no-undo.
def shared var sort-gr      as logical               no-undo.

def stream out-stream .

def buffer buf_trn-doc          for ub.trn-doc.
def buffer buf_goods            for ub.goods.
def buffer buf_clients          for ub.clients.
def buffer buf_doc-line         for ub.doc-line.
def buffer buf_person           for ub.person.


def var v-line-counter      as integer                  no-undo.
def var v-single-line       as char                     no-undo.
def var v-full-type          as char                     no-undo.

def var v-cli-name          as char                     no-undo.
def var v-obj-name          as char                     no-undo.
def var v-income            as logical                  no-undo.  /* yes - приход */

def var v-valut-abbr        as char                     no-undo.  /* (Р У Б) или (Б.Вал) в зависимости от PrintRubl */

def var v-vat-pc            like ub.doc-line.vat-pc        no-undo.
def var v-slt-pc            like ub.doc-line.slt-pc        no-undo.
def var v-host-code         like ub.sysconf.host-code      no-undo.

def var v-doc-sum           like ub.ot-tot.sum-base        no-undo.
def var v-doc-price         like ub.doc-line.price-base    no-undo.

def var v-pg-sum-qnty       like ub.doc-line.fact-qnty     no-undo.
def var v-pg-sum-no-taxes   like ub.ot-line.sum-base       no-undo.
def var v-pg-sum-no-vat     like ub.ot-line.sum-base       no-undo.
def var v-pg-sum-slt        like ub.ot-line.sum-base       no-undo.
def var v-pg-sum-vat        like ub.ot-line.sum-base       no-undo.
def var v-pg-sum-doc        like ub.ot-line.sum-base       no-undo.

def var v-tot-sum-qnty      like ub.doc-line.fact-qnty     no-undo.
def var v-tot-sum-no-taxes  like ub.ot-line.sum-base       no-undo.
def var v-tot-sum-no-vat    like ub.ot-line.sum-base       no-undo.
def var v-tot-sum-slt       like ub.ot-line.sum-base       no-undo.
def var v-tot-sum-vat       like ub.ot-line.sum-base       no-undo.
def var v-tot-sum-doc       like ub.ot-line.sum-base       no-undo.

define variable boss-name    like ub.clients.obj-name  no-undo.

def var v-par-menedger          as char                     no-undo.
define variable p-torgconf-wrkr-name    as character    no-undo.
define variable p-torgconf-post         as character    no-undo.
def var v-first-line        as logical                  no-undo.

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

assign
    v-valut-abbr = ( if PrintRubl = yes then "( {&abbr_rub_allshift} )" else "(Б.Вал)" )
.

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
/*имя и должность у менеджера*/
run rep/get-psn.p
      (input buf_trn-doc.boss
      ,output boss-name
      ) .
find first buf_person no-lock
where buf_person.psn-code = buf_trn-doc.boss
no-error.
if available buf_person
then do:
   v-par-menedger = buf_person.position.
end.
if boss-name = "?":U then boss-name = "".
if v-par-menedger = ? then  v-par-menedger = "".

run torgconf-get-warrant in this-procedure(
    input buf_trn-doc.doc-code
)
.
run torgconf-get-storekeeper in this-procedure (
    input buf_trn-doc.wrkr
  , output p-torgconf-wrkr-name
  , output p-torgconf-post
).


{ cmp/open-out.i stream out-stream " " {&LS_PS_A4} }

form header
    space({&P-S}) v-single-line format "X({&P-X})" skip
    'Продолжение - на следующей странице' at 90 skip
    with frame BottomFrame width {&DOS_CW} page-bottom no-labels no-box .
view stream out-stream frame BottomFrame .

find first buf_clients no-lock
     where buf_clients.obj-type = {&cmp}
       and buf_clients.obj-code = v-host-code
.

{ gbl/working.i }

put stream out-stream
    buf_clients.obj-name format "X(60)" at {&P-S} + ( ( {&P-E} - {&P-S}) / 2 ) - ( length( buf_clients.obj-name ) / 2 )
.
put stream out-stream
    skip (1) space( {&tab-stop1} )
    "Приложение к документу. Тип: "
.

v-full-type = ENTRY(lookup(buf_trn-doc.ext-doc-type,{&TDEDT_List}),{&TDEDT_List-full}).
put stream out-stream
       v-full-type                                                format "X(20)"
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
    skip
.
put stream out-stream
        ( if CostPrice = yes then 'Учетные цены' else 'Цены продажи' )
                                                                format "X(12)"  at right-field( {&P-E}, 12 )
.
run print-header in this-procedure .
assign
    v-pg-sum-qnty       = 0
    v-pg-sum-no-taxes   = 0
    v-pg-sum-no-vat     = 0
    v-pg-sum-slt        = 0
    v-pg-sum-vat        = 0
    v-pg-sum-doc        = 0
    v-tot-sum-qnty      = 0
    v-tot-sum-no-taxes  = 0
    v-tot-sum-no-vat    = 0
    v-tot-sum-slt       = 0
    v-tot-sum-vat       = 0
    v-tot-sum-doc       = 0
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
            if first-of(buf_goods.grp-name)
            then do:
                run print-group-line in this-procedure.
            end.
            if last(buf_goods.gds-name)
                and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream )
            then do:
                run print-page-result in this-procedure ( input "" ).
                if line-counter( Out-Stream ) + {&bottom-page-line-size} < page-size( Out-Stream )
                then do:
                    put stream out-stream
                        skip space({&P-S})
                            "|" v-single-line format "X({&P-X0})" "|"
                    .
                end.
                page stream Out-Stream .
                run print-header in this-procedure .
            end.
            run print-line in this-procedure .
        end.
    end.        /* sort-name = yes */
    else do:
        for each buf_doc-line
        where buf_doc-line.doc-code = buf_trn-doc.doc-code
        , first buf_goods no-lock
          where buf_goods.artic      = buf_doc-line.artic
            and buf_goods.prod-type  = buf_doc-line.prod-type
            and buf_goods.prod-code  = buf_doc-line.prod-code
        break by buf_goods.grp-name
              by buf_doc-line.num-place
        :
            if first-of(buf_goods.grp-name)
            then do:
                run print-group-line in this-procedure.
            end.
            if last(buf_doc-line.num-place)
                and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream )
            then do:
                run print-page-result in this-procedure ( input "" ).
                if line-counter( Out-Stream ) + {&bottom-page-line-size} < page-size( Out-Stream )
                then do:
                    put stream out-stream
                        skip space({&P-S})
                            "|" v-single-line format "X({&P-X0})" "|"
                    .
                end.
                page stream Out-Stream .
                run print-header in this-procedure .
            end.
            run print-line in this-procedure .
        end.
    end.        /* sort-name <> yes */
end.        /* sort-gr = yes */
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
            if last(buf_goods.gds-name)
                and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream )
            then do:
                run print-page-result in this-procedure ( input "" ).
                if line-counter( Out-Stream ) + {&bottom-page-line-size} < page-size( Out-Stream )
                then do:
                    put stream out-stream
                        skip space({&P-S})
                            "|" v-single-line format "X({&P-X0})" "|"
                    .
                end.
                page stream Out-Stream .
                run print-header in this-procedure .
            end.
            run print-line in this-procedure .
        end.
    end.        /* sort-name = yes */
    else do:
        for each buf_doc-line
        where buf_doc-line.doc-code = buf_trn-doc.doc-code
        , first buf_goods no-lock
        where buf_goods.artic      = buf_doc-line.artic
            and buf_goods.prod-type  = buf_doc-line.prod-type
            and buf_goods.prod-code  = buf_doc-line.prod-code
        break by buf_doc-line.num-place
        :
            if last(buf_doc-line.num-place)
                and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream )
            then do:
                run print-page-result in this-procedure ( input "" ).
                if line-counter( Out-Stream ) + {&bottom-page-line-size} < page-size( Out-Stream )
                then do:
                    put stream out-stream
                        skip space({&P-S})
                            "|" v-single-line format "X({&P-X0})" "|"
                    .
                end.
                page stream Out-Stream .
                run print-header in this-procedure .
            end.
            run print-line in this-procedure .
        end.
    end.        /* sort-name <> yes */
end.        /* sort-gr <> yes */
if page-number ( Out-Stream ) > 1
then do:
    run print-page-result in this-procedure  ( input "" ) .
end.        /* if page-number ( Out-Stream ) > 1  */
else do:
    run print-page-result in this-procedure  ( input "no-line" ) .
end.
run print-total-result in this-procedure .

hide stream Out-Stream frame BottomFrame .

run print-note in this-procedure .


{ gbl/stopwork.i }

output stream out-stream close.

{ rep/q-print.i 8 }

end.






/*==========================================================================*/
procedure print-header :
do
on error undo, return error
:
assign
    v-first-line = yes
.
put stream out-stream
    skip
    space({&P-S})       v-single-line   format "X({&P-X})"
    skip space({&P-S})  "|"
        "|"                     at {&P-C2-S}
        "|"                     at {&P-C3-S}
        "|"                     at {&P-C4-S}
        "|"                     at {&P-C5-S}
        "Цена без"              at center-field({&P-C5-S}, {&P-C6-S}, 8)
        "|"                     at {&P-C6-S}
        "Сумма без"             at center-field({&P-C6-S}, {&P-C7-S}, 9)
        "|"                     at {&P-C7-S}
        "Цена без"              at center-field({&P-C7-S}, {&P-C8-S}, 8)
        "|"                     at {&P-C8-S}
        "Сумма без"             at center-field({&P-C8-S}, {&P-C9-S}, 9)
        "|"                     at {&P-C9-S}
        "Став-"                 at center-field({&P-C11-S}, {&P-C12-S}, 5)
        "|"                     at {&P-C12-S}
        "Сумма"                 at center-field({&P-C12-S}, {&P-C13-S}, 5)
        "|"                     at {&P-C13-S}
        "|"                     at {&P-C14-S}
        "|"                     at {&P-E}
    skip space({&P-S})  "|"
        "Код"                   at center-field({&P-S} + 1, {&P-C2-S}, 3)
        "|"                     at {&P-C2-S}
        "Артикул"               at center-field({&P-C2-S}, {&P-C3-S}, 7)
        "|"                     at {&P-C3-S}
        "Наименование товара"   at center-field({&P-C3-S}, {&P-C4-S}, 19)
        "|"                     at {&P-C4-S}
        "Количество"            at center-field({&P-C4-S}, {&P-C5-S}, 10)
        "|"                     at {&P-C5-S}
        "налогов"               at center-field({&P-C5-S}, {&P-C6-S}, 7)
        "|"                     at {&P-C6-S}
        "налогов"               at center-field({&P-C6-S}, {&P-C7-S}, 7)
        "|"                     at {&P-C7-S}
        "НДС"                   at center-field({&P-C7-S}, {&P-C8-S}, 3)
        "|"                     at {&P-C8-S}
        "НДС"                   at center-field({&P-C8-S}, {&P-C9-S}, 3)
        "|"                     at {&P-C9-S}
        "ка"                    at center-field({&P-C11-S}, {&P-C12-S}, 2)
        "|"                     at {&P-C12-S}
        "НДС"                   at center-field({&P-C12-S}, {&P-C13-S}, 3)
        "|"                     at {&P-C13-S}
        "Цена"                  at center-field({&P-C13-S}, {&P-C14-S}, 4)
        "|"                     at {&P-C14-S}
        "Сумма"                 at center-field({&P-C14-S}, {&P-E}, 5)
        "|"                     at {&P-E}
    skip space({&P-S})  "|"
        "|"                     at {&P-C2-S}
        "|"                     at {&P-C3-S}
        "|"                     at {&P-C4-S}
        "|"                     at {&P-C5-S}
        v-valut-abbr            at center-field({&P-C5-S}, {&P-C6-S}, 7)
        "|"                     at {&P-C6-S}
        v-valut-abbr            at center-field({&P-C6-S}, {&P-C7-S}, 7)
        "|"                     at {&P-C7-S}
        v-valut-abbr            at center-field({&P-C7-S}, {&P-C8-S}, 7)
        "|"                     at {&P-C8-S}
        v-valut-abbr            at center-field({&P-C8-S}, {&P-C9-S}, 7)
        "|"                     at {&P-C9-S}
        "НДС"                   at center-field({&P-C11-S}, {&P-C12-S}, 3)
        "|"                     at {&P-C12-S}
        v-valut-abbr            at center-field({&P-C12-S}, {&P-C13-S}, 7)
        "|"                     at {&P-C13-S}
        v-valut-abbr            at center-field({&P-C13-S}, {&P-C14-S}, 7)
        "|"                     at {&P-C14-S}
        v-valut-abbr            at center-field({&P-C14-S}, {&P-E}, 7)
        "|"                     at {&P-E}
    skip space({&P-S})
        "|" v-single-line format "X({&P-X0})" "|"
.
end.
end procedure. /* print-header */









/*==========================================================================*/
procedure print-line :
do
on error undo, return error
:
    define variable v-sign      as integer       no-undo.

    assign
        v-sign =  ( if buf_trn-doc.status_ = {&fact}
                    and ( buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}       /* расход внешний ee */
                        or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}    /* расход внешний возврат поставщику ep */
                        or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}  /* расход внешний продажа через кассу es */
                        or buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh}       /* списание внешнее    we                             */
                        or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem}       /* расход перемещение  ev                             */
                        or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Prvo}        /* расход производство (перестает использоваться)  em */
                        or buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Prvo}  )      /* списание производство   wm                         */
                    then -1
                    else 1 )
    .
    run r-getsum in this-procedure ( input recid ( buf_doc-line )
                                   ,  input CostPrice
                                   ,  input PrintRubl
                                   ).
    assign
        v-doc-sum   = v-sign * temp_r-getsum.sum-with-taxes
        v-doc-price = (if temp_r-getsum.qnty <> 0 then temp_r-getsum.sum-with-taxes / temp_r-getsum.qnty else ?)
    .

    put stream out-stream
        skip space({&P-S})  "|"
            string(buf_goods.gds-code, "999999999") format "X(9)"
            "|"   at {&P-C2-S}
            string(buf_doc-line.artic)              format "X(16)"
            "|"   at {&P-C3-S}
            buf_goods.gds-name                      format "X({&P-C3-X})"
            "|"   at {&P-C4-S}
            v-sign * temp_r-getsum.qnty             format "->>>>>9.<<<"
            "|"   at {&P-C5-S}
            temp_r-getsum.price-no-taxes            format "->>>>>9.99"
            "|"   at {&P-C6-S}
            v-sign * temp_r-getsum.sum-no-taxes     format "->>,>>>,>>9.99"
            "|"   at {&P-C7-S}
            temp_r-getsum.price-no-vat              format "->>>>>9.99"
            "|"   at {&P-C8-S}
            v-sign * temp_r-getsum.sum-no-vat       format "->>,>>>,>>9.99"
            "|"   at {&P-C9-S}
            ( if temp_r-getsum.vat-pc <> ? then string(temp_r-getsum.vat-pc, ">9.9<") else " " )
                                                    format "X(5)"
            "|"   at {&P-C12-S}
            v-sign * temp_r-getsum.sum-vat          format "->>>>9.99"
            "|"   at {&P-C13-S}
    .
    if v-doc-price <> ?
    then do:
        put stream out-stream
            v-doc-price      format "->>>>>9.99"
        .
    end.
    put stream out-stream
        "|"   at {&P-C14-S}
            v-doc-sum            format "->>,>>>,>>9.99"
        "|"   at {&P-E}
    .
    assign
        v-line-counter      = v-line-counter    + 1
        v-pg-sum-qnty       = v-pg-sum-qnty     + ( v-sign * temp_r-getsum.qnty         )
        v-pg-sum-no-taxes   = v-pg-sum-no-taxes + ( v-sign * temp_r-getsum.sum-no-taxes )
        v-pg-sum-no-vat     = v-pg-sum-no-vat   + ( v-sign * temp_r-getsum.sum-no-vat   )
        v-pg-sum-slt        = v-pg-sum-slt      + ( v-sign * temp_r-getsum.sum-slt      )
        v-pg-sum-vat        = v-pg-sum-vat      + ( v-sign * temp_r-getsum.sum-vat      )
        v-pg-sum-doc        = v-pg-sum-doc      + ( v-doc-sum                           )
    .
    if line-counter( Out-Stream ) + {&bottom-page-line-size} + {&page-result-line-size} > page-size( Out-Stream )
    then do:
        run print-page-result in this-procedure ( input "" ) .
        page stream Out-Stream .
        run print-header in this-procedure .
    end.
    assign
        v-first-line = no
    .
end.
end procedure. /* print-line */

/*==========================================================================*/
procedure print-group-line :
do
on error undo, return error
:
    if line-counter( Out-Stream ) + {&bottom-page-line-size} + {&group-line-size} + 1 > page-size( Out-Stream )
    then do:
        run print-page-result in this-procedure ( input "" ) .
        page stream out-stream.
        run print-header in this-procedure .
    end.
    if v-first-line <> yes
    then do:
        put stream out-stream
            skip space({&P-S})
                "|" v-single-line format "X({&P-X0})" "|"
        .
    end.        /* p-print-type <> "no-line" */
    put stream out-stream
        skip space({&P-S})
            "|   ***  Группа:  "  + buf_goods.grp-name format "X(150)"
            "|" at {&P-E}
    .
end.
end procedure. /* print-group-line */

/*==========================================================================*/
procedure print-page-result :
do
on error undo, return error
:
def input parameter p-print-type as char no-undo.

if p-print-type <> "no-line"
then do:
    put stream out-stream
        skip space({&P-S})
            "|" v-single-line format "X({&P-X0})" "|"
        skip space({&P-S})  "|        Итого по странице "
            "|"                 at {&P-C4-S}
            v-pg-sum-qnty                       format "->>>>>9.<<<"
            "|"                 at {&P-C5-S}
            "|"                 at {&P-C6-S}
            v-pg-sum-no-taxes                   format "->>,>>>,>>9.99"
            "|"                 at {&P-C7-S}
            "|"                 at {&P-C8-S}
            v-pg-sum-no-vat                     format "->>,>>>,>>9.99"
            "|"                 at {&P-C9-S}
            "|"                 at {&P-C12-S}
            v-pg-sum-vat                        format "->>>>9.99"
            "|"                 at {&P-C13-S}
            "|"                 at {&P-C14-S}
            v-pg-sum-doc                        format "->>,>>>,>>9.99"
            "|"                 at {&P-E}
    .
end.

assign
    v-tot-sum-qnty      = v-tot-sum-qnty        + v-pg-sum-qnty
    v-tot-sum-no-taxes  = v-tot-sum-no-taxes    + v-pg-sum-no-taxes
    v-tot-sum-no-vat    = v-tot-sum-no-vat      + v-pg-sum-no-vat
    v-tot-sum-slt       = v-tot-sum-slt         + v-pg-sum-slt
    v-tot-sum-vat       = v-tot-sum-vat         + v-pg-sum-vat
    v-tot-sum-doc       = v-tot-sum-doc         + v-pg-sum-doc
    v-pg-sum-qnty       = 0
    v-pg-sum-no-taxes   = 0
    v-pg-sum-no-vat     = 0
    v-pg-sum-slt        = 0
    v-pg-sum-vat        = 0
    v-pg-sum-doc        = 0
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
            "|"                 at {&P-C4-S}
            v-tot-sum-qnty                       format "->>>>>9.<<<"
            "|"                 at {&P-C5-S}
            "|"                 at {&P-C6-S}
            v-tot-sum-no-taxes                   format "->>,>>>,>>9.99"
            "|"                 at {&P-C7-S}
            "|"                 at {&P-C8-S}
            v-tot-sum-no-vat                     format "->>,>>>,>>9.99"
            "|"                 at {&P-C9-S}
            "|"                 at {&P-C12-S}
            v-tot-sum-vat                        format "->>>>9.99"
            "|"                 at {&P-C13-S}
            "|"                 at {&P-C14-S}
            v-tot-sum-doc                        format "->>,>>>,>>9.99"
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
if trim(p-torgconf-post) = ""
then do:
    p-torgconf-post = Fill("_", 20).
end.
if trim(p-torgconf-wrkr-name ) = ""
then do:
    p-torgconf-wrkr-name  = Fill("_", 30).
end.
if trim(p-torgconf-accept-position) = ""
then do:
    p-torgconf-accept-position = Fill ("_", 20).
end.
if trim(p-torgconf-accept-fname) = ""
then do:
    p-torgconf-accept-fname = Fill ("_", 30).
end.

    put stream out-stream
        skip(1) space({&tab-stop1})
            "Всего наименований: "
            v-line-counter  format ">>>>>9"
        skip space({&tab-stop1})
            "Сумма цен по документу составила: "
            v-tot-sum-doc                        format "->>,>>>,>>9.99"
            ", в том числе налог с продаж: "
            v-tot-sum-slt                        format "->>>9.99"
            ", НДС: "
            v-tot-sum-vat                        format "->>>>9.99"
        skip(1) space({&tab-stop1})
            "Сдал:"
        space(25)  p-torgconf-post               format "X(20)" "     __________           "p-torgconf-wrkr-name format "X(40)"
        skip space(78)  "/должность/          /подпись/               /расшифровка подписи/"

            skip(1) space({&tab-stop1})
                "Принял:"
        space(23)    p-torgconf-accept-position format "X(20)" "     __________           "p-torgconf-accept-fname format "X(40)"
        skip space(78) "/должность/          /подпись/               /расшифровка подписи/"
        skip
        .
    end.
end procedure. /* print-total-result */