block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-protcl.p $
$Archive: rep/r-protcl.p $

Протокол согласования отпускных цен

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Input:

Output:

*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter Discnt_Type          as integer          no-undo.
define input parameter NoProd               as logical          no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-protcl.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-protcl.p $":U .
define variable vss-description as character no-undo initial "Протокол согласования отпускных цен".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ rep/tl-tree.i new}
{ gbl/getcntxt.i def }

DEFINE STREAM Out_Stream .

DEFINE BUFFER Help-buffer   for     tl-tree .
DEFINE BUFFER cli-prod        for     clients .
DEFINE BUFFER Our_Host     for     clients .

def var     Line                as      char    no-undo.

def var     rootnode_code     as      integer       no-undo.
def var     LastLevelSign      as   logical     no-undo.   /* нужно лишь для вызова tl-tree.p*/

def var     Lines_Counter   as      integer                 no-undo.
def var     Node_Code       like    gds-prt.upper-code  no-undo.

def var sym1 as char init ":".
def var sym2 as char init ":".
def var sym7 as char init ":".
def var sym8 as char init ":".
def var sym9 as char init ":".

def var tdoc-date    like    trn-doc.doc-date    no-undo.
def var tdoc-code    like   trn-doc.doc-code    no-undo.

def var tb-code     as  char    no-undo.

define variable v-rb-is-base            as logical      no-undo.
define variable v-price-rb    as decimal      no-undo.

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.


DEFINE FRAME val
        sym1 column-label ":!:" format "X(1)" space(0)
        Lines_Counter COLUMN-LABEL "N!п/п" format ">>9" space(0)
        sym2 column-label ":!:" format "X(1)"
        tb-code column-label "Код! " format "x({&BarCode_Length})"
        goods.artic COLUMN-LABEL "Артикул! " format "X(18)"
        goods.gds-name COLUMN-LABEL "Наименование! " format "X(30)"
        cli-prod.obj-name COLUMN-LABEL "Производитель! " format "X(40)"
        sym9 column-label ":!:" format "X(1)"
        units.long-name COLUMN-LABEL "Единица!измер. " format "X(7)"
        sym7 column-label ":!:" format "X(1)"
        v-price-rb  COLUMN-LABEL "Цена за ед.! "  format ">>>>>>>,>>9.99"
/*        gds-dtl.price-{&rb} COLUMN-LABEL "Цена за ед.!({&rb-abbr})" format ">>>>>>>,>>9.99"*/
        sym8 column-label ":!:" format "X(1)"
    HEADER
        tdoc-code AT 70 format "X(10)"
        space(15) ( if v-rb-is-base = yes then "Суммы в базовой валюте" else "Суммы в {&abbr_rublyah}" ) format "X(22)"
            "Страница " AT 110 PAGE-NUMBER( Out_Stream ) AT 120 FORMAT ">>9" SKIP
        Line format "X(136)" AT 1
    with width {&DOS_CW} down stream-io.

DEFINE FRAME val-no-prod
        sym1 column-label ":!:" format "X(1)"
        Lines_Counter COLUMN-LABEL "N!п/п" format ">>9"
        sym2 column-label ":!:" format "X(1)"
        tb-code column-label "Код! " format "x({&BarCode_Length})"
        goods.artic COLUMN-LABEL "Артикул! " format "X(21)"
        goods.gds-name COLUMN-LABEL "Наименование! " format "X(60)"
        sym9 column-label ":!:" format "X(1)"
        units.long-name COLUMN-LABEL "Единица!измер. " format "X(10)"
        sym7 column-label ":!:" format "X(1)"
        v-price-rb  COLUMN-LABEL "Цена за ед.! "  format "->,>>>,>>>,>>9.99"
/*        gds-dtl.price-{&rb} COLUMN-LABEL "Цена за ед.!({&rb-abbr})" format "->,>>>,>>>,>>9.99"*/
        sym8 column-label ":!:" format "X(1)"
    HEADER
        tdoc-code AT 70 format "X(10)"
            "Страница " AT 110 PAGE-NUMBER(Out_Stream) AT 120 FORMAT ">>9" SKIP
        Line format "X(136)" AT 1
    with width {&DOS_CW} down stream-io.

DEFINE FRAME rubl
        sym1 column-label ":!:" format "X(1)" space(0)
        Lines_Counter COLUMN-LABEL "N!п/п" format ">>9" space(0)
        sym2 column-label ":!:" format "X(1)"
        tb-code column-label "Код! " format "x({&BarCode_Length})"
        goods.artic COLUMN-LABEL "Артикул! " format "X(18)"
        goods.gds-name COLUMN-LABEL "Наименование! " format "X(30)"
        cli-prod.obj-name COLUMN-LABEL "Производитель! " format "X(40)"
        sym9 column-label ":!:" format "X(1)"
        units.long-name COLUMN-LABEL "Единица!измер." format "X(7)"
        sym7 column-label ":!:" format "X(1)"
        gds-dtl.price-rubl COLUMN-LABEL "Цена за ед.!({&abbr_rub_allshift}) "
            format ">>>>>>>,>>9.99"
        sym8 column-label ":!:" format "X(1)"
    HEADER
        tdoc-code AT 70 format "X(10)"
            "Страница " AT 110 PAGE-NUMBER(Out_Stream) AT 120 FORMAT ">>9" SKIP
        Line format "X(136)" AT 1
    with width {&DOS_CW} down stream-io.

DEFINE FRAME rubl-no-prod
        sym1 column-label ":!:" format "X(1)"
        Lines_Counter COLUMN-LABEL "N!п/п" format ">>9"
        sym2 column-label ":!:" format "X(1)"
        tb-code column-label "Код! " format "x({&BarCode_Length})"
        goods.artic COLUMN-LABEL "Артикул! " format "X(21)"
        goods.gds-name COLUMN-LABEL "Наименование! " format "X(60)"
        sym9 column-label ":!:" format "X(1)"
        units.long-name COLUMN-LABEL "Единица!измер." format "X(10)"
        sym7 column-label ":!:" format "X(1)"
        gds-dtl.price-rubl COLUMN-LABEL "Цена за ед.!({&abbr_rub_allshift}) "
            format ">,>>>,>>>,>>9.99"
        sym8 column-label ":!:" format "X(1)"
    HEADER
        tdoc-code AT 70 format "X(10)"
            "Страница " AT 110 PAGE-NUMBER(Out_Stream) AT 120 FORMAT ">>9" SKIP
        Line format "X(136)" AT 1
    with width {&DOS_CW} down stream-io.


{ gbl/getcntxt.i get " " p-mainmenu-handle }
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
if session:set-wait-state("compiler") then.
    { gbl/rbisbase.i
        v-rb-is-base
    }
FIND trn-doc WHERE recid( trn-doc ) = rec_id  NO-LOCK.
FIND clients WHERE clients.obj-type = trn-doc.cli-type AND
                                   clients.obj-code = trn-doc.cli-code NO-LOCK.
FIND Our_Host WHERE Our_Host.obj-type = {&cmp} AND
                                       Our_Host.obj-code = trn-doc.host-code NO-LOCK.
Line = fill("-", 140) .
assign
    Lines_Counter = 1
    tdoc-code = trn-doc.doc-code
    tdoc-date = trn-doc.doc-date .

{ cmp/open-out.i STREAM Out_Stream}

if NOT trn-doc.print-rubl then /* оплата - в базовой валюте */
    if NoProd then
        FORM with FRAME val-no-prod .
    else
        FORM with FRAME val .
else
    if NoProd then
        FORM with FRAME rubl-no-prod .
    else
        FORM with FRAME rubl .

FORM HEADER
    Line format "X(136)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 30 SKIP
    with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW STREAM Out_Stream FRAME BottomFrame .

PUT STREAM Out_Stream space(20)
        "П Р О Т О К О Л   СОГЛАСОВАНИЯ  СВОБОДНЫХ  ОТПУСКНЫХ  ЦЕН"
            format "X(100)" SKIP(1)
        SPACE(20) string( "между " + CAPS( Our_Host.obj-name ) + " и " + CAPS( clients.obj-name ) )
            format "X(100)" SKIP(1)
        SPACE(40) string( "НАКЛАДНАЯ  N " + tdoc-code ) format "X(60)" SKIP(1) .

FOR  EACH doc-line where doc-line.doc-code = trn-doc.doc-code NO-LOCK
                            BREAK BY doc-line.artic :
    FIND goods WHERE goods.prod-type = doc-line.prod-type AND
                                      goods.prod-code = doc-line.prod-code AND
                                      goods.artic = doc-line.artic NO-LOCK .
    FIND cli-prod WHERE cli-prod.obj-type = doc-line.prod-type AND
                                        cli-prod.obj-code = doc-line.prod-code NO-LOCK .

    FIND FIRST units WHERE units.unit-name = goods.unit-base NO-LOCK no-error.
    FIND gds-prt where gds-prt.upper-code = doc-line.prt-root NO-LOCK .
    rootnode_code = gds-prt.node-code.
    if can-find(first gds-prt where gds-prt.upper-code = rootnode_code)
    then do:
            /* Т.е. не пустая шкала и не случай отказа от шкалы */
            if NOT trn-doc.print-rubl  /* оплата - в базовой валюте */
            then do:
                if NoProd
                then do:
                    { rep/protcl-1.i val-no-prod}
                end.
                else do:
                    { rep/protcl-1.i val}
                end.
            end.
            else do:
                if NoProd
                then do:
                    { rep/protcl-1.i rubl-no-prod}
                end.
                else do:
                    { rep/protcl-1.i rubl}
                end.
            end.
            run rep/tl_tree.p ( INPUT doc-line.prt-root, INPUT rootnode_code, INPUT 1,
                                    INPUT gds-prt.node-name, INPUT goods.gds-name,
                                    INPUT goods.artic, OUTPUT LastLevelSign).
            if session:set-wait-state("compiler") then.
            FOR EACH gds-dtl WHERE
                            gds-dtl.prod-type = doc-line.prod-type AND
                            gds-dtl.prod-code = doc-line.prod-code AND
                            gds-dtl.artic = doc-line.artic AND
                            gds-dtl.doc-code = doc-line.doc-code NO-LOCK :
                FIND gds-prt WHERE gds-prt.node-code = gds-dtl.prt-code NO-LOCK.
                FIND FIRST tl-tree WHERE tl-tree.node-code = gds-prt.node-code NO-ERROR.
                DO WHILE not available tl-tree :
                    Node_Code = gds-prt.upper-code.
                    FIND gds-prt WHERE gds-prt.node-code = Node_Code NO-LOCK.
                    FIND FIRST tl-tree WHERE tl-tree.node-code = Node_Code NO-ERROR.
                END.
                FIND bar-code WHERE bar-code.gds-code = goods.gds-code AND
                                                      bar-code.unit-cli = goods.unit-base AND
                                                      bar-code.node-code = tl-tree.node-code AND
                                                      bar-code.part-code = "" AND
                                                      bar-code.in-code = "" NO-LOCK NO-ERROR.
                assign
                    tl-tree.gds-amount = /* for next : tl-tree.gds-amount + */ gds-dtl.fact-qnty
                    tl-tree.b-code = ( if not available bar-code
                                               then "?" else trim ( string ( bar-code.b-code) ))
                    tl-tree.price-base = gds-dtl.price-base
                    tl-tree.price-rubl = gds-dtl.price-rubl
                .
            END.        /*FOR EACH gds-dtl ...*/
            FOR EACH tl-tree WHERE tl-tree.level-number = 1
                BREAK BY tl-tree.gds-artic BY tl-tree.prt-num /* tl-tree.node-name */ :
                if can-find( first Help-buffer where
                                                Help-buffer.level-number = 2 and
                                                Help-buffer.gds-amount <> 0 and
                                                Help-buffer.uppernode-name = tl-tree.node-name) then
                    do:
                        FOR EACH Help-buffer WHERE
                                                  Help-buffer.uppernode-name = tl-tree.node-name AND
                                                  Help-buffer.gds-amount <> 0 :
                            if NOT trn-doc.print-rubl then /* оплата - в базовой валюте */
                                if NoProd then
                                    DISPLAY STREAM Out_Stream
                                        sym1 Lines_Counter
                                        sym2 Help-buffer.b-code @ tb-code
                                        ( "  \" + string(tl-tree.node-name, "x(10)") + "\" +
                                                    string(Help-buffer.node-name, "x(10)")) @ goods.gds-name
                                        sym9 units.long-name
                                        sym7 ( if Discnt_Type = 1 /* скидку показать ! */
                                                    then ( if v-rb-is-base = yes
                                                           then Help-buffer.price-base - Help-buffer.discnt-base
                                                           else Help-buffer.price-rubl - Help-buffer.discnt-rubl )
                                                    else ( if v-rb-is-base = yes
                                                           then Help-buffer.price-base
                                                           else Help-buffer.price-rubl )
                                             )
                                                        @ v-price-rb
                                        sym8 with FRAME val-no-prod .
                                else
                                    DISPLAY STREAM Out_Stream
                                        sym1 Lines_Counter
                                        sym2 Help-buffer.b-code @ tb-code
                                        ( "  \" + string(tl-tree.node-name, "x(10)") + "\" +
                                                      string(Help-buffer.node-name, "x(10)")) @ goods.gds-name
                                        cli-prod.obj-name
                                        sym9 units.long-name
                                        sym7 ( if Discnt_Type = 1 /* скидку показать ! */
                                                    then ( if v-rb-is-base = yes
                                                           then Help-buffer.price-base - Help-buffer.discnt-base
                                                           else Help-buffer.price-rubl - Help-buffer.discnt-rubl )
                                                    else ( if v-rb-is-base = yes
                                                           then Help-buffer.price-base
                                                           else Help-buffer.price-rubl )
                                             )
                                                        @ v-price-rb
                                        sym8 with FRAME val .
                            else
                                if NoProd then
                                    DISPLAY STREAM Out_Stream
                                        sym1 Lines_Counter
                                        sym2 Help-buffer.b-code @ tb-code
                                        ( "  \" + string(tl-tree.node-name, "x(10)") + "\" +
                                                      string(Help-buffer.node-name, "x(10)")) @ goods.gds-name
                                        sym9 units.long-name
                                        sym7 ( if Discnt_Type = 1 /* скидку показать ! */
                                                    then Help-buffer.price-rubl - Help-buffer.discnt-rubl
                                                    else Help-buffer.price-rubl) @ gds-dtl.price-rubl
                                        sym8 with FRAME rubl-no-prod .
                                else
                                    DISPLAY STREAM Out_Stream
                                        sym1 Lines_Counter
                                        sym2 Help-buffer.b-code @ tb-code
                                        ( "  \" + string(tl-tree.node-name, "x(10)") + "\" +
                                                      string(Help-buffer.node-name, "x(10)")) @ goods.gds-name
                                        cli-prod.obj-name
                                        sym9 units.long-name
                                        sym7 ( if Discnt_Type = 1 /* скидку показать ! */
                                                    then Help-buffer.price-rubl - Help-buffer.discnt-rubl
                                                    else Help-buffer.price-rubl) @ gds-dtl.price-rubl
                                        sym8 with FRAME rubl .
                            Lines_Counter = Lines_Counter + 1.
                        END.
                    end.
                else
                    do:
                        if tl-tree.gds-amount <> 0 then
                            do:
                                if NOT trn-doc.print-rubl then /* оплата - в базовой валюте */
                                    if NoProd then
                                        DISPLAY STREAM Out_Stream
                                                    sym1 Lines_Counter
                                                    sym2 tl-tree.b-code @ tb-code
                                                    ( "  \" + string(tl-tree.node-name, "x(10)") )
                                                                            @ goods.gds-name
                                                    sym9 units.long-name
                                                    sym7 ( if Discnt_Type = 1 /* скидку показать ! */
                                                         then ( if v-rb-is-base = yes
                                                                then tl-tree.price-base - tl-tree.discnt-base
                                                                else tl-tree.price-rubl - tl-tree.discnt-rubl )
                                                         else ( if v-rb-is-base = yes
                                                                then tl-tree.price-base
                                                                else tl-tree.price-rubl )
                                                          ) @ v-price-rb
                                                    sym8 with FRAME val-no-prod .
                                    else
                                        DISPLAY STREAM Out_Stream
                                                    sym1 Lines_Counter
                                                    sym2 tl-tree.b-code @ tb-code
                                                    ( "  \" + string(tl-tree.node-name, "x(10)") )
                                                                            @ goods.gds-name
                                                    cli-prod.obj-name
                                                    sym9 units.long-name
                                                    sym7 ( if Discnt_Type = 1 /* скидку показать ! */
                                                         then ( if v-rb-is-base = yes
                                                                then tl-tree.price-base - tl-tree.discnt-base
                                                                else tl-tree.price-rubl - tl-tree.discnt-rubl )
                                                         else ( if v-rb-is-base = yes
                                                                then tl-tree.price-base
                                                                else tl-tree.price-rubl )
                                                          ) @ v-price-rb
                                                    sym8 with FRAME val .
                                else
                                    if NoProd then
                                        DISPLAY STREAM Out_Stream
                                                        sym1 Lines_Counter
                                                        sym2 tl-tree.b-code @ tb-code
                                                        ( "  \" + string(tl-tree.node-name, "x(10)") )
                                                                            @ goods.gds-name
                                                        sym9 units.long-name
                                                        sym7 ( if Discnt_Type = 1 /* скидку показать ! */
                                                                    then tl-tree.price-rubl - tl-tree.discnt-rubl
                                                                    else tl-tree.price-rubl ) @ gds-dtl.price-rubl
                                                        sym8 with FRAME rubl-no-prod .
                                    else
                                        DISPLAY STREAM Out_Stream
                                                        sym1 Lines_Counter
                                                        sym2 tl-tree.b-code @ tb-code
                                                        ( "  \" + string(tl-tree.node-name, "x(10)") )
                                                                            @ goods.gds-name
                                                        cli-prod.obj-name
                                                        sym9 units.long-name
                                                        sym7 ( if Discnt_Type = 1 /* скидку показать ! */
                                                                    then tl-tree.price-rubl - tl-tree.discnt-rubl
                                                                    else tl-tree.price-rubl ) @ gds-dtl.price-rubl
                                                        sym8 with FRAME rubl .
                                Lines_Counter = Lines_Counter + 1.
                                if NOT LAST( tl-tree.prt-num ) then
                                    do:
                                        if NOT trn-doc.print-rubl then /* оплата - в базовой валюте */
                                            if NoProd then
                                                DOWN STREAM Out_Stream 1 with FRAME val-no-prod .
                                            else
                                                DOWN STREAM Out_Stream 1 with FRAME val .
                                        else
                                            if NoProd then
                                                DOWN STREAM Out_Stream 1 with FRAME rubl-no-prod .
                                            else
                                                DOWN STREAM Out_Stream 1 with FRAME rubl .
                                    end.
                            end.
                    end.
            END.    /* FOR EACH tl-tree WHERE tl-tree.level-number = 1 ... */
/* Удавить tl-tree перед следующей doc-line: */
            FOR EACH tl-tree:
                delete  tl-tree.
            END.
        end.
    else            /* пустая шкала или случай отказа от шкалы */
        do:
            FIND gds-dtl where gds-dtl.doc-code = doc-line.doc-code
                                            and gds-dtl.prod-type = doc-line.prod-type
                                            and gds-dtl.prod-code = doc-line.prod-code
                                            and gds-dtl.artic = doc-line.artic
                                            and gds-dtl.prt-code = rootnode_code NO-LOCK .
            FIND bar-code WHERE bar-code.gds-code = goods.gds-code AND
                                                  bar-code.unit-cli = goods.unit-base AND
                                                  bar-code.node-code = rootnode_code AND
                                                  bar-code.part-code = "" AND
                                                  bar-code.in-code = "" NO-LOCK NO-ERROR.
            if NOT trn-doc.print-rubl then /* оплата - в базовой валюте */
                if NoProd then
                    do:
                        DISPLAY STREAM Out_Stream
                            sym1 Lines_Counter
                            sym2 trim ( string ( bar-code.b-code )) @ tb-code
                            goods.artic
                            goods.gds-name
                            sym9 units.long-name
                            sym7 ( if Discnt_Type = 1 /* скидку показать ! */
                                 then ( if v-rb-is-base = yes
                                        then gds-dtl.price-base - gds-dtl.discnt-base
                                        else gds-dtl.price-rubl - gds-dtl.discnt-rubl )
                                 else ( if v-rb-is-base = yes
                                        then gds-dtl.price-base
                                        else gds-dtl.price-rubl )
                                 ) @ v-price-rb
                            sym8 with FRAME val-no-prod .
                        DOWN STREAM Out_Stream 1 with FRAME val-no-prod .
                    end.
                else
                    do:
                        DISPLAY STREAM Out_Stream
                            sym1 Lines_Counter
                            sym2 trim ( string ( bar-code.b-code )) @ tb-code
                            goods.artic
                            goods.gds-name
                            cli-prod.obj-name
                            sym9 units.long-name
                            sym7 ( if Discnt_Type = 1 /* скидку показать ! */
                                 then ( if v-rb-is-base = yes
                                        then gds-dtl.price-base - gds-dtl.discnt-base
                                        else gds-dtl.price-rubl - gds-dtl.discnt-rubl )
                                 else ( if v-rb-is-base = yes
                                        then gds-dtl.price-base
                                        else gds-dtl.price-rubl )
                                 ) @ v-price-rb
                            sym8 with FRAME val .
                        DOWN STREAM Out_Stream 1 with FRAME val .
                    end.
            else
                if NoProd then
                    do:
                        DISPLAY STREAM Out_Stream
                            sym1 Lines_Counter
                            sym2 trim ( string ( bar-code.b-code )) @ tb-code
                            goods.artic
                            goods.gds-name
                            sym9 units.long-name
                            sym7 ( if Discnt_Type = 1 /* скидку показать ! */
                                        then gds-dtl.price-rubl - gds-dtl.discnt-rubl
                                        else gds-dtl.price-rubl ) @ gds-dtl.price-rubl
                            sym8 with FRAME rubl-no-prod .
                        DOWN STREAM Out_Stream 1 with FRAME rubl-no-prod .
                    end.
                else
                    do:
                        DISPLAY STREAM Out_Stream
                            sym1 Lines_Counter
                            sym2 trim ( string ( bar-code.b-code )) @ tb-code
                            goods.artic
                            goods.gds-name
                            cli-prod.obj-name
                            sym9 units.long-name
                            sym7 ( if Discnt_Type = 1 /* скидку показать ! */
                                        then gds-dtl.price-rubl - gds-dtl.discnt-rubl
                                        else gds-dtl.price-rubl ) @ gds-dtl.price-rubl
                            sym8 with FRAME rubl .
                        DOWN STREAM Out_Stream 1 with FRAME rubl .
                    end.
            Lines_Counter = Lines_Counter + 1.
        end.
END.        /*FOR  EACH doc-line ...*/

if line-counter( Out_Stream ) + 13 > page-size( Out_Stream ) then
    page STREAM Out_Stream .
PUT STREAM Out_Stream  Line format "X(136)" SKIP(1) SPACE(5) "Всего "
        ( Lines_Counter - 1 ) format ">,>>>,>>9" SPACE(2)
        "наименований" format "x(13)" SKIP(1) .

define variable v-user-name as character no-undo .

{ gbl/usrfulnm.i
  v-cntxt-userid
  v-user-name
}
put stream out_stream skip(1) space(10) "Подписи сторон" format "x(100)" skip(1)
        space(10) "Генеральный директор : " format "x(70)" skip(1)
        space(10) "Планово-экономический отдел : " format "x(70)" skip(1)
        space(10) "Управляющий  магазином : " format "x(70)" skip(3)
        space(20) string( "Исполнитель : " + v-user-name ) format "x(70)" skip .

hide stream out_stream frame bottomframe .
output stream out_stream close.

{ rep/q-print.i 0}