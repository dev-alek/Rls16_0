block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-glprcl.p $
$Archive: rep/r-glprcl.p $

Печать Прайс-листа

Автор: Демин Алексей Сергеевич
Дата создания: 09/20/05
Author: Alexey Demin
Creation date: 09/20/05

Input:

Output:

*/
define input parameter p-store-type     as character        no-undo.
define input parameter p-store-code     as integer          no-undo.
define input parameter i                as integer          no-undo.
define input parameter P_Type           as integer          no-undo.
define input parameter SortType         as character        no-undo.
define input parameter No-Prt           as logical          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-glprcl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-glprcl.p $":U .
define variable vss-description as character no-undo init "Печать Прайс-листа".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ rep/r-sym.i    }
{ cmp/r-page1.i  }
{ rep/r-gl.i     }
{ rep/rep-bt.i   }

define variable v-today as date no-undo .

define variable OnlyPrices    as      logical  no-undo.

define variable t_grp-name like gds-list.grp-name  no-undo.
define variable t_unit-name like units.long-name    no-undo.


define variable Rubl_Coeff            as          decimal  no-undo.

define variable price as decimal    no-undo.
define variable roz-price as decimal    no-undo.
define variable qnty as decimal     no-undo.
define variable WaitQnty as decimal     no-undo.


define variable Log-Res         as      log     no-undo.

define variable tb-code            as      char    no-undo.
define variable Line                as      char    no-undo.
define variable CurrItem        as       char   no-undo.
define variable ObjName        as       char   no-undo.

define variable AA        as       char     no-undo.
define variable JJ        as       integer   no-undo.

define variable CurrPrinterName as  char    no-undo.

define variable v-rb-is-base            as logical      no-undo.

def stream PL .
def stream Title_ .

DEFINE FRAME FullPriceList-Val
    sym1 column-label ":!:!:" format "X(1)" space(0)
    tb-code column-label " Код! ! " format "x({&BarCode_Length})" space(0)
    sym2 column-label ":!:!:" format "X(1)" space(0)
    gds-list.artic column-label " Артикул! ! " FORMAT "X(16)" space(0)
    sym3 column-label ":!:!:" format "X(1)" space(0)
    gds-list.gds-name column-label " Наименование! ! "
&if "{&sys-key}" = "ia" &then
    FORMAT "X(35)"
&else
    FORMAT "X(47)"
&endif
    space(0)
    sym4 column-label ":!:!:" format "X(1)" space(0)
    clients.obj-name column-label " Производитель! ! " FORMAT "X(16)" space(0)
    sym5 column-label ":!:!:" format "X(1)" space(0)
    t_unit-name column-label "Ед.!изм.! " FORMAT "X(4)" space(0)
    sym6 column-label ":!:!:" format "X(1)" space(0)

    price   &if "{&sys-key}" = "ia" &then
                column-label "Оптовая!цена за ед.!(Б.вал.)"
            &else
                column-label "Цена за ед.!(Б.вал.)! "
            &endif
                format ">>>>>>>>9.99" space(0)

&if "{&sys-key}" = "ia" &then
    sym10 column-label ":!:!:" format "X(1)"
    roz-price column-label "Розничная!цена за ед.!(Б.вал.)" format ">>>>>>>9.99" space(0)
&endif
    sym7 column-label ":!:!:" format "X(1)" space(0)
    qnty column-label " Свободно   ! ! " format "->>>>>>9.<<<" space(0)
    sym8 column-label ":!:!:" format "X(1)" space(0)
    WaitQnty column-label " Ожидается! ! " format "->>>>9.<<<" space(0)
    sym9 column-label ":!:!:" format "X(1)"
    HEADER
        "Дата печати :   " AT 5  TODAY format "99.99.9999" " , "
            string(TIME, "HH:MM")
            "Страница " AT 120 PAGE-NUMBER( PL )  FORMAT ">>>>9" SKIP
            Line format "x(136)" AT 1
    with width {&DOS_CW} down stream-io.

DEFINE FRAME FullPriceList-Rubl
    sym1 column-label ":!:!:" format "X(1)" space(0)
    tb-code column-label " Код! ! " format "x({&BarCode_Length})" space(0)
    sym2 column-label ":!:!:" format "X(1)" space(0)
    gds-list.artic column-label " Артикул! ! " FORMAT "X(16)" space(0)
    sym3 column-label ":!:!:" format "X(1)" space(0)
    gds-list.gds-name column-label " Наименование! ! "
&if "{&sys-key}" = "ia" &then
    FORMAT "X(35)"
&else
    FORMAT "X(49)"
&endif
    space(0)
    sym4 column-label ":!:!:" format "X(1)" space(0)
    clients.obj-name column-label " Производитель! ! " FORMAT "X(16)" space(0)
    sym5 column-label ":!:!:" format "X(1)" space(0)
    t_unit-name column-label "Ед.!изм.! " FORMAT "X(4)" space(0)
    sym6 column-label ":!:!:" format "X(1)" space(0)

    price
            &if "{&sys-key}" = "ia" &then
                column-label "Опт. цена!за ед.!({&abbr_rub_allshift})"
            &else
                column-label "Цена!за ед.!({&abbr_rub_allshift})"
            &endif
                format ">>>>>>9.99" space(0)

&if "{&sys-key}" = "ia" &then
    sym10 column-label ":!:!:" format "X(1)"
    roz-price column-label "Розн. цена!за ед.!({&abbr_rub_allshift})" format ">>>>>>9.99" space(0)
&endif
    sym7 column-label ":!:!:" format "X(1)" space(0)
    qnty column-label " Свободно   ! ! " format "->>>>>>9.<<<" space(0)
    sym8 column-label ":!:!:" format "X(1)" space(0)
    WaitQnty column-label " Ожидается! ! " format "->>>>9.<<<" space(0)
    sym9 column-label ":!:!:" format "X(1)"
    HEADER
        "Дата печати :   " AT 5  TODAY format "99.99.9999" " , "
            string(TIME, "HH:MM")
            "Страница " AT 120 PAGE-NUMBER( PL )  FORMAT ">>>>9" SKIP
            Line format "x(136)" AT 1
    with width {&DOS_CW} down stream-io.

DEFINE FRAME ReducedPriceList-Val
    sym1 column-label ":!:!:" format "X(1)"
    tb-code column-label "Код ! ! " format "x({&BarCode_Length})"
    sym2 column-label ":!:!:" format "X(1)"
    gds-list.artic column-label "Артикул! ! " FORMAT "X(16)"
    sym3 column-label ":!:!:" format "X(1)"
    gds-list.gds-name column-label "Наименование! ! " FORMAT "X(50)"
    sym4 column-label ":!:!:" format "X(1)"
    clients.obj-name column-label "Производитель! ! " FORMAT "X(22)"
    sym5 column-label ":!:!:" format "X(1)"
    t_unit-name column-label "Ед.!изм.! " FORMAT "X(4)"
    sym6 column-label ":!:!:" format "X(1)"
    price
    &if "{&sys-key}" = "ia" &then
        column-label "Оптовая!цена за ед.!(Б.вал.)"
    &else
        column-label "Цена за ед.!(Б.вал.)! "
    &endif
        format ">>>>>>>>>>>9.99"
    sym7 column-label ":!:!:" format "X(1)"
    HEADER
        "Дата печати :   " AT 5  TODAY format "99.99.9999" " , "
            string(TIME, "HH:MM")
            "Страница " AT 120 PAGE-NUMBER( PL )  FORMAT ">>>>9" SKIP
            Line format "x(136)" AT 1
    with width {&DOS_CW} down stream-io.

DEFINE FRAME ReducedPriceList-Rubl
    sym1 column-label ":!:!:" format "X(1)"
    tb-code column-label "Код ! ! " format "x({&BarCode_Length})"
    sym2 column-label ":!:!:" format "X(1)"
    gds-list.artic column-label "Артикул! ! " FORMAT "X(16)"
    sym3 column-label ":!:!:" format "X(1)"
    gds-list.gds-name column-label "Наименование! ! " FORMAT "X(50)"
    sym4 column-label ":!:!:" format "X(1)"
    clients.obj-name column-label "Производитель! ! " FORMAT "X(22)"
    sym5 column-label ":!:!:" format "X(1)"
    t_unit-name column-label "Ед.!изм.! " FORMAT "X(4)"
    sym6 column-label ":!:!:" format "X(1)"
    price
    &if "{&sys-key}" = "ia" &then
        column-label "Опт. цена!за ед.!({&abbr_rub_allshift})"
    &else
        column-label "Цена!за ед.!({&abbr_rub_allshift})"
    &endif
        format ">>>>>>>>>>>9.99"
    sym7 column-label ":!:!:" format "X(1)"
    HEADER
        "Дата печати :   " AT 5  TODAY format "99.99.9999" " , "
            string(TIME, "HH:MM")
            "Страница " AT 120 PAGE-NUMBER( PL )  FORMAT ">>>>9" SKIP
            Line format "x(136)" AT 1
    with width {&DOS_CW} down stream-io.

DEFINE FRAME PL-Title
    AA   format "X(120)"
    JJ   format ">>>>9"
    with width {&A4_CW} down stream-io NO-LABELS no-box .

 { gbl/curobjdt.i p-store-type p-store-code v-today  }

{ gbl/rbisbase.i
    v-rb-is-base
}

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_price-list_print':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  true
  log-res
}
if not Log-Res then
    return "NO".

{ gbl/working.i }

if i = 0 OR P_Type = 0 then
    return.
{ gbl/working.i }

Line = fill("-", {&DOS_CW_2}).
OnlyPrices = ( if i = 1 then no else yes ) .

if ( v-rb-is-base = yes
    and P_Type = 2 )
or ( v-rb-is-base <> yes
    and P_Type = 1 )
then do:
   run proc-cur-rate( input p-store-type, input p-store-code, output Rubl_Coeff ).
end.

FIND clients where p-store-type = clients.obj-type
                      and p-store-code = clients.obj-code no-lock no-error.
ObjName = clients.obj-name .

{ gbl/working.i }
output stream PL to value( string( session:temp-directory +
                                 {&DF_Name} + string( g#report-num ) ) ) page-size value(ReportPageHeight).

output stream Title_ to value( string( session:temp-directory +
                                 {&PLT_Name} + string( g#report-num ) ) ) page-size value(ReportPageHeight) .

FORM HEADER
        Line format "x(136)" AT 1 SKIP
    with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM no-labels no-box.
VIEW stream PL      FRAME BottomFrame .

if SortType = "По группам товаров ( и артикулу )" then
    do:
        FORM HEADER
            string( "Дата печати : " + string( TODAY , "99.99.9999" ) + ", " +
                string(TIME, "HH:MM") )    AT 10 format "X(50)"
                "Страница " AT 100 PAGE-NUMBER( Title_ )  FORMAT ">>>>9" SKIP(2)
            ObjName AT 55 format "X(50)" SKIP(2)
            "О Г Л А В Л Е Н И Е"  AT 50 SKIP(3)
            with FRAME TopFrame width {&A4_CW} PAGE-TOP no-labels no-box.
        VIEW stream Title_  FRAME TopFrame .
    end.
PUT stream Title_ string( "Дата печати : " + string( TODAY , "99.99.9999" ) + ", " +
            string(TIME, "HH:MM") )    AT 10 format "X(50)" SKIP(2)
            ObjName AT 55 format "X(50)" SKIP(2)
            "П Р А Й С - Л И С Т" format "X(30)" AT 50 SKIP(3) .

t_grp-name = "" .

CASE SortType :
    when "По наименованию"
    then do:
        FOR EACH gds-list no-lock
        BREAK BY gds-list.gds-name :
            FIND goods WHERE goods.prod-type = gds-list.prod-type
                                              AND goods.prod-code = gds-list.prod-code
                                              AND goods.artic = gds-list.artic NO-LOCK.
            FIND clients WHERE clients.obj-type = gds-list.prod-type
                                               AND clients.obj-code = gds-list.prod-code NO-LOCK .
            RUN prtprice( gds-list.gds-name, gds-list.prt-root , goods.gds-code, goods.unit-base) .
            ACCUMULATE gds-list.artic (COUNT) .
        END.
    end.
END CASE .

HIDE stream PL FRAME BottomFrame .

PUT stream PL Line format "x(136)" SKIP .
output stream Title_ CLOSE .
output stream PL CLOSE .

{ gbl/stopwork.i }
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_price-list-to-file_print':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  false
  log-res
}
if not Log-Res then
    run rep/pl-prn.w (4 , g#report-num) .
else
    run rep/pl-prn.w (0 , g#report-num) .


/* --------------------------------- INTERNALS -------------------------------------- */
{ rep/cur-rate.i }
PROCEDURE prtprice :

def input parameter tr       as character.
def input parameter node as integer.
define input parameter pp-gds-code like ub.goods.gds-code no-undo .
define input parameter pp-unit-base like ub.goods.unit-base no-undo .

def buffer b-gds-prt for gds-prt .
define buffer buf_bar-code for bar-code.
define variable gds_name as char no-undo.

assign gds_name = tr .

    FOR EACH b-gds-prt WHERE b-gds-prt.upper-code = node no-lock ,
     first buf_bar-code no-lock
      where buf_bar-code.gds-code  = pp-gds-code
        and buf_bar-code.node-code = b-gds-prt.node-code
        and buf_bar-code.part-code = ""
        and buf_bar-code.in-code   = ""
        and buf_bar-code.unit-cli  = pp-unit-base
     :

        RUN price-qnty ( b-gds-prt.node-code ) .
        if true /* price <> 0 and price <> ? */ then
            do:
                if ( OnlyPrices ) OR ( qnty <> 0 OR WaitQnty <> 0 ) then
                    do:
                        if NOT b-gds-prt.root then
                            tr = gds_name + '\' + b-gds-prt.node-name.
                        FIND bar-code WHERE
                                 bar-code.gds-code = gds-list.gds-code AND
                                 bar-code.unit-cli = gds-list.unit-base AND
                                 bar-code.node-code = b-gds-prt.node-code AND
                                 bar-code.part-code = "" AND
                                 bar-code.in-code = ""
                                 NO-LOCK NO-ERROR .
                        if ( t_grp-name <> gds-list.grp-name ) AND
                           lookup( "По группам товаров ( и артикулу )", SortType ) > 0 then
                            do:
                                if t_grp-name <> "" then
                                    if OnlyPrices then
                                        if P_Type = 2 then  /* в  р у б л я х */
                                            UNDERLINE stream PL gds-list.gds-name
                                            with FRAME ReducedPriceList-Rubl .
                                        else
                                            UNDERLINE stream PL gds-list.gds-name
                                            with FRAME ReducedPriceList-Val .
                                    else
                                        if P_Type = 2 then  /* в  р у б л я х */
                                            UNDERLINE stream PL gds-list.gds-name
                                            with FRAME FullPriceList-Rubl .
                                        else
                                            UNDERLINE stream PL gds-list.gds-name
                                            with FRAME FullPriceList-Val .
                                DO i = 1 to num-entries( right-trim(gds-list.grp-name, {&delim-grp}), {&delim-grp} ):
                                    if OnlyPrices then
                                        if P_Type = 2 then  /* в  р у б л я х */
                                            do:
                                                DISPLAY stream PL sym1
                                                    string( fill( " " , i * 2 ) + {&delim-grp} + entry( i, gds-list.grp-name, {&delim-grp} ) )
                                                        @ gds-list.gds-name
                                                    sym7 with FRAME ReducedPriceList-Rubl .
                                                DOWN stream PL 1 with FRAME ReducedPriceList-Rubl .
                                            end.
                                        else
                                            do:
                                                DISPLAY stream PL sym1
                                                    string( fill( " " , i * 2 ) + {&delim-grp} + entry( i, gds-list.grp-name, {&delim-grp} ) )
                                                        @ gds-list.gds-name
                                                    sym7 with FRAME ReducedPriceList-Val .
                                                DOWN stream PL 1 with FRAME ReducedPriceList-Val .

                                            end.
                                    else
                                        if P_Type = 2 then  /* в  р у б л я х */
                                            do:
                                                DISPLAY stream PL sym1
                                                    string( fill( " " , i * 2 ) + {&delim-grp} + entry( i, gds-list.grp-name, {&delim-grp} ) )
                                                        @ gds-list.gds-name
                                                    sym9 with FRAME FullPriceList-Rubl .
                                                DOWN stream PL 1 with FRAME FullPriceList-Rubl .
                                            end.
                                        else
                                            do:
                                                DISPLAY stream PL sym1
                                                    string( fill( " " , i * 2 ) + {&delim-grp} + entry( i, gds-list.grp-name, {&delim-grp} ) )
                                                        @ gds-list.gds-name
                                                    sym9 with FRAME FullPriceList-Val .
                                                DOWN stream PL 1 with FRAME FullPriceList-Val .
                                            end.
                                END .
                                if OnlyPrices then
                                    if P_Type = 2 then  /* в  р у б л я х */
                                        UNDERLINE stream PL gds-list.gds-name
                                            with FRAME ReducedPriceList-Rubl .
                                    else
                                        UNDERLINE stream PL gds-list.gds-name
                                            with FRAME ReducedPriceList-Val .
                                else
                                    if P_Type = 2 then  /* в  р у б л я х */
                                        UNDERLINE stream PL gds-list.gds-name
                                            with FRAME FullPriceList-Rubl .
                                    else
                                        UNDERLINE stream PL gds-list.gds-name
                                            with FRAME FullPriceList-Val .
                            end.
                        if OnlyPrices then
                            if P_Type = 2 then  /* в  р у б л я х */
                            do:
                                DISPLAY stream PL
                                    sym1 trim( string( bar-code.b-code ) ) @ tb-code
                                    sym2 gds-list.artic
                                    sym3 tr @ gds-list.gds-name
                                    sym4 clients.obj-name
                                    sym5 gds-list.unit-base @ t_unit-name
                                    sym6
                                    (if price = 0 or price = ? then "        ----" else string(price, ">>>>>9.99" ) ) format "x(9)" @ price
                                    sym7 with FRAME ReducedPriceList-Rubl .
                                DOWN    stream PL   1   with FRAME ReducedPriceList-Rubl .
                            end.
                            else
                            do:
                                DISPLAY stream PL
                                    sym1 trim( string( bar-code.b-code ) ) @ tb-code
                                    sym2 gds-list.artic
                                    sym3 tr @ gds-list.gds-name
                                    sym4 clients.obj-name
                                    sym5 gds-list.unit-base @ t_unit-name
                                    sym6 (if price = 0 or price = ? then "        ----" else string(price, ">>>>>>>>9.99" ) ) format "x(12)" @ price
                                    sym7 with FRAME ReducedPriceList-Val .
                                DOWN    stream PL   1   with FRAME ReducedPriceList-Val .
                            end.
                        else
                            if P_Type = 2 then  /* в  р у б л я х */
                            do:
                                DISPLAY stream PL
                                    sym1 trim( string( bar-code.b-code ) ) @ tb-code
                                    sym2 gds-list.artic
                                    sym3 tr @ gds-list.gds-name
                                    sym4 clients.obj-name
                                    sym5 gds-list.unit-base @ t_unit-name
                                    sym6 (if price = 0 or price = ? then "        ----" else string(price, ">>>>>>9.99" ) ) format "x(9)" @ price
                            &if "{&sys-key}" = "ia" &then
                                    sym10
                                    (if price = 0 or price = ? then "       ----" else string(round( price * 1.25, 2 ), ">>>>>>9.99" ) ) format "x(9)" @ roz-price
                            &endif
                                    sym7 qnty   when qnty <> 0
                                    sym8 WaitQnty   when WaitQnty <> 0
                                    sym9
                                    with FRAME FullPriceList-Rubl .
                                DOWN    stream PL   1 with FRAME FullPriceList-Rubl .
                            end.
                            else
                            do:
                                DISPLAY stream PL
                                    sym1 trim( string( bar-code.b-code ) ) @ tb-code
                                    sym2 gds-list.artic
                                    sym3 tr @ gds-list.gds-name
                                    sym4 clients.obj-name
                                    sym5 gds-list.unit-base @ t_unit-name
                                    sym6 (if price = 0 or price = ? then "        ----" else string(price, ">>>>>>>>9.99" ) ) format "x(12)" @ price
                            &if "{&sys-key}" = "ia" &then
                                    sym10
                                    (if price = 0 or price = ? then "       ----" else string(round( price * 1.25, 2 ), ">>>>>>>>9.99" ) ) format "x(12)" @ roz-price
                            &endif
                                    sym7 qnty   when qnty <> 0
                                    sym8 WaitQnty   when WaitQnty <> 0
                                    sym9
                                    with FRAME FullPriceList-Val .
                                DOWN    stream PL   1 with FRAME FullPriceList-Val .
                            end.
                        if ( t_grp-name <> gds-list.grp-name ) AND
                           lookup( "По группам товаров ( и артикулу )", SortType ) > 0 then
                            do:
                                CurrItem = "" .
                                DO i = 1 to num-entries( gds-list.grp-name, {&delim-grp} ) :
                                    CurrItem = entry( i, t_grp-name , {&delim-grp} ) NO-ERROR .
                                    if ( error-status:error ) OR
                                       ( CurrItem <> entry( i, gds-list.grp-name, {&delim-grp} ) ) then
                                        do:
                                            DISPLAY stream Title_
                                                    string( fill( " " , i * 10 ) + string( if i = 1 then "  " else "\ " ) +
                                                        entry( i, gds-list.grp-name, {&delim-grp} ) + " " +
                                                        fill( "." , 120 - ( i * 10 ) - 5 -
                                                        length( entry( i, gds-list.grp-name, {&delim-grp} ) ) ) ) @ AA
                                                    PAGE-NUMBER( PL )  @ JJ
                                                    with frame PL-Title .
                                            DOWN stream Title_ 1 with FRAME PL-Title .
                                        end.
                                END .
                                t_grp-name = gds-list.grp-name .
                            end.
                    end.
            end.
        if NOT No-Prt then
            RUN prtprice( tr, b-gds-prt.node-code, goods.gds-code, goods.unit-base).
    END.
END PROCEDURE .


PROCEDURE price-qnty :

def input parameter node like gds-prt.node-code .
{ str/get-pr.i def}

define variable v-rb-is-base            as logical      no-undo.

    { gbl/rbisbase.i
        v-rb-is-base
    }

    { str/get-pr.i calc p-store-type p-store-code gds-list.gds-code node}

    if gp-price-sale <> ? then
        do:
            if v-rb-is-base = yes
            then do:
                assign price = ( if P_Type = 2 /* в  р у б л я х */
                                    then (gp-price-sale * Rubl_Coeff )    else gp-price-sale ) .
            end.        /* if v-rb-is-base = yes */
            else do:
                assign price = ( if P_Type = 2 /* в  р у б л я х */
                                   then gp-price-sale else ( gp-price-sale / Rubl_Coeff ) ) .
            end.        /* NOT ( if v-rb-is-base = yes ) */
       end.
    else
        price = 0 .


    FIND first prt-obj where prt-obj.obj-type = p-store-type
                       and prt-obj.obj-code = p-store-code
                       and prt-obj.prod-type = gds-list.prod-type
                       and prt-obj.prod-code = gds-list.prod-code
                       and prt-obj.artic = gds-list.artic
                       and prt-obj.prt-code = node
                       use-index pi NO-LOCK NO-ERROR .
    if available prt-obj then
        do:
            assign
                qnty = prt-obj.free-qnty
                WaitQnty = 0 .
        end.
    else
        assign
            qnty = 0
            WaitQnty = 0 .

END PROCEDURE .