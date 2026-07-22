block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-pricel.p $
$Archive: rep/r-pricel.p $

Печать Прайс-листа

Автор: Чернова Светлана Александровна
Дата создания: 09/08/05
Author: Svetlana Chernova
Creation date: 09/08/05

Дата создания: 08/29/01

*/
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-pricel.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-pricel.p $":U .
def var vss-description as character no-undo init "Печать Прайс-листа".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ rep/r-sym.i    }
{ cmp/r-page1.i  }
{ rep/r-gl.i     }
{ rep/i-pricel.i  def }
{ gbl/paramls.i  }
{ gbl/waitfram.i }
{ rep/f-fdec.i   }
{ rep/rep-bt.i   }
/*===================================================================================================================*/
define variable C-c    as integer no-undo .
define variable C-str  as character no-undo .
define variable str--1 as character Format "x(60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var  as integer no-undo .

define variable num#col# as integer no-undo .
define variable var-1 as integer no-undo .
define variable var-2 as integer no-undo .
define stream  macr_excel .

define variable v-file-name as character no-undo .
define variable v-ind       as integer   no-undo .

define input parameter  i         as  int      no-undo.
define input parameter  P_Type    as  int      no-undo.
define input parameter  SortType  as  char     no-undo.
define input parameter  No-Prt    as  log      no-undo.

def  var OnlyPrices    as      logical  no-undo.

def  var t_grp-name  like gds-list.grp-name  no-undo.
def  var t_unit-name like ub.units.long-name    no-undo.


def  var Rubl_Coeff as decimal  no-undo.

def var price       as decimal  format ">>>>>>>>9.99"   no-undo.
def var roz-price   as decimal    no-undo.
def var qnty        as decimal    no-undo.
def var WaitQnty    as decimal    no-undo.


def var Log-Res      as      log     no-undo.

def var tb-code      as      char    no-undo.
def var Line         as      char    no-undo.
def var CurrItem     as      char    no-undo.
def var ObjName      as      char    no-undo.

def var AA        as       char      no-undo.
def var JJ        as       integer   no-undo.

def var CurrPrinterName as  char     no-undo.

define variable v-today as date      no-undo.
def stream PL .
def stream Title_ .

DEFINE FRAME FullPriceList-Val
    sym1 column-label ":!:!:" format "X(1)" space(0)
    tb-code column-label " Код! ! " format "x({&BarCode_Length})" space(0)
    sym2 column-label ":!:!:" format "X(1)" space(0)
    gds-list.artic column-label " Артикул! ! " FORMAT "X(16)" space(0)
    sym3 column-label ":!:!:" format "X(1)" space(0)
    gds-list.gds-name column-label " Наименование! ! "  FORMAT "X(47)" space(0)
    sym4 column-label ":!:!:" format "X(1)" space(0)
    ub.clients.obj-name column-label " Производитель! ! " FORMAT "X(16)" space(0)
    sym5 column-label ":!:!:" format "X(1)" space(0)
    t_unit-name column-label "Ед.!изм.! " FORMAT "X(4)" space(0)
    sym6 column-label ":!:!:" format "X(1)" space(0)
    price   column-label "Цена за ед.!(Б.вал.)! " format ">>>>>>>>9.99" space(0)
    sym7 column-label ":!:!:" format "X(1)" space(0)
    qnty column-label " Свободно   ! ! " format "->>>>>>9.<<<" space(0)
    sym8 column-label ":!:!:" format "X(1)" space(0)
    WaitQnty column-label " Ожидается! ! " format "->>>>9.<<<" space(0)
    sym9 column-label ":!:!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
            "Страница " AT 120 PAGE-NUMBER( PL )  FORMAT ">>>>9" SKIP
            Line format "x(136)" AT 1
    with width {&DOS_CW} down stream-io.

DEFINE FRAME FullPriceList-Rubl
    sym1 column-label ":!:!:" format "X(1)" space(0)
    tb-code column-label " Код! ! " format "x({&BarCode_Length})" space(0)
    sym2 column-label ":!:!:" format "X(1)" space(0)
    gds-list.artic column-label " Артикул! ! " FORMAT "X(16)" space(0)
    sym3 column-label ":!:!:" format "X(1)" space(0)
    gds-list.gds-name column-label " Наименование! ! "    FORMAT "X(49)"    space(0)
    sym4 column-label ":!:!:" format "X(1)" space(0)
    ub.clients.obj-name column-label " Производитель! ! " FORMAT "X(16)" space(0)
    sym5 column-label ":!:!:" format "X(1)" space(0)
    t_unit-name column-label "Ед.!изм.! " FORMAT "X(4)" space(0)
    sym6 column-label ":!:!:" format "X(1)" space(0)
    price  column-label "Цена!за ед.!({&abbr_rub_allshift})"  format ">>>>>>9.99" space(0)
    sym7 column-label ":!:!:" format "X(1)" space(0)
    qnty column-label " Свободно   ! ! " format "->>>>>>9.<<<" space(0)
    sym8 column-label ":!:!:" format "X(1)" space(0)
    WaitQnty column-label " Ожидается! ! " format "->>>>9.<<<" space(0)
    sym9 column-label ":!:!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
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
    ub.clients.obj-name column-label "Производитель! ! " FORMAT "X(22)"
    sym5 column-label ":!:!:" format "X(1)"
    t_unit-name column-label "Ед.!изм.! " FORMAT "X(4)"
    sym6 column-label ":!:!:" format "X(1)"
    price  column-label "Цена за ед.!(Б.вал.)! "   format ">>>>>>>>>>>9.99"
    sym7 column-label ":!:!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
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
    ub.clients.obj-name column-label "Производитель! ! " FORMAT "X(22)"
    sym5 column-label ":!:!:" format "X(1)"
    t_unit-name column-label "Ед.!изм.! " FORMAT "X(4)"
    sym6 column-label ":!:!:" format "X(1)"
    price  column-label "Цена!за ед.!({&abbr_rub_allshift})"  format ">>>>>>>>>>>9.99"
    sym7 column-label ":!:!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
            "Страница " AT 120 PAGE-NUMBER( PL )  FORMAT ">>>>9" SKIP
            Line format "x(136)" AT 1
    with width {&DOS_CW} down stream-io.

DEFINE FRAME PL-Title
    AA   format "X(120)"
    JJ   format ">>>>9"
    with width {&A4_CW} down stream-io NO-LABELS no-box .

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

 run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
    output stream macr_excel to value(v-file-name)   .
    v-ind = 1    .
    num#str# = 0 .


if session:set-wait-state("COMPILER") then.

if i = 0 OR P_Type = 0 then
    return.
if session:set-wait-state("COMPILER") then.

Line = fill("-", {&DOS_CW_2}).
OnlyPrices = ( if i = 1 then no else yes ) .

{ gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code v-today }
run proc-cur-rate( input v-cntxt-obj-type, input v-cntxt-obj-code, output Rubl_Coeff ).

FIND ub.clients where v-cntxt-obj-type = ub.clients.obj-type
                      and v-cntxt-obj-code = ub.clients.obj-code no-lock no-error.
ObjName = ub.clients.obj-name .

RUN waitfram-show( {&MyWaitMess} ).

if session:set-wait-state("COMPILER") then.
{ cmp/open-out.i stream PL " " ReportPageHeight }

output stream Title_ to value( string( session:temp-directory +
                                 {&PLT_Name} + string( g#report-num ) ) ) page-size value(ReportPageHeight) .

FORM HEADER
        Line format "x(136)" AT 1 SKIP
    with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM no-labels no-box.
VIEW stream PL      FRAME BottomFrame .

if SortType = "По группам товаров ( и артикулу )" then
    do:
        FORM HEADER
            cur-time-print() AT 5 format "X(35)"
                "Страница " AT 100 PAGE-NUMBER( Title_ )  FORMAT ">>>>9" SKIP(2)
            ObjName AT 55 format "X(50)" SKIP(2)
            "О Г Л А В Л Е Н И Е"  AT 50 SKIP(3)
            with FRAME TopFrame width {&A4_CW} PAGE-TOP no-labels no-box.
        VIEW stream Title_  FRAME TopFrame .
    end.
PUT stream Title_ cur-time-print() AT 5 format "X(35)" SKIP(2)
            ObjName AT 55 format "X(50)" SKIP(2)
            "П Р А Й С - Л И С Т" format "X(30)" AT 50 SKIP(3) .


  num#str# = num#str# + 1.
  num#col# = 1.
  run macr_excel_char_with_format( String("        П Р А Й С - Л И С Т")  , num#str# , num#col#  ) .
  run macr_cell_format
  ( 14    ,      /* p-size     */
    true  ,      /* p-bold     */
    false   ,    /* p-italic   */
    ? ,          /* p-color-bg */
    1 ,          /* p-row      */
    1 ,          /* p-col      */
    2 ,          /* p-row-2    */
    1 ) .        /* p-col-2    */

  num#str# = num#str# + 1.
  num#col# = 1.
  run macr_excel_char_with_format( String( ObjName + " " + cur-time-print())  , num#str# , num#col#  ) .

  /* colon */
  num#str# = num#str# + 1.
  run macr_excel_char_with_format(  "Код"               , num#str# , 1  ) .
  run macr_excel_char_with_format(  "Артикул"           , num#str# , 2  ) .
  run macr_excel_char_with_format(   "Наименование"     , num#str# , 3  ) .
  run macr_excel_char_with_format(   "Производитель"    , num#str# , 4  ) .
  run macr_excel_char_with_format(   "Ед. изм."         , num#str# , 5  ) .
  if P_Type = 2  /* в  р у б л я х */
     then  run macr_excel_char_with_format(   "Цена за ед. ({&abbr_rub_allshift})"    , num#str# , 6  ) .
     else  run macr_excel_char_with_format(   "Цена за ед. (Б.вал.)"    , num#str# , 6  ) .
  if not OnlyPrices  then do:
     num#col# = 8 .
     run macr_excel_char_with_format(   "Свободно"    , num#str# , 7  ) .
     run macr_excel_char_with_format(   "Ожидается"    , num#str# , 8  ) .
     run macr_cell_format
      ( 10    ,      /* p-size     */
        true  ,      /* p-bold     */
        false   ,    /* p-italic   */
        34 ,          /* p-color-bg */
        3 ,          /* p-row      */
        7 ,          /* p-col      */
        3 ,          /* p-row-2    */
        8 ) .        /* p-col-2    */

  end.
  else num#col# = 6 .

  run macr_cell_format
  ( 10    ,      /* p-size     */
    true  ,      /* p-bold     */
    false   ,    /* p-italic   */
    34 ,          /* p-color-bg */
    3 ,          /* p-row      */
    1 ,          /* p-col      */
    3 ,          /* p-row-2    */
    6 ) .        /* p-col-2    */
    run macr_cell_size ( 10 , ? , num#str# , 1 , ?, ? ) .
    run macr_cell_size ( 10 , ? , num#str# , 2 , ?, ? ) .
    run macr_cell_size ( 20 , ? , num#str# , 3 , ?, ? ) .
    run macr_cell_size ( 20 , ? , num#str# , 4 , ?, ? ) .
    run macr_cell_size ( 5 , ? , num#str# , 5 , ?, ? ) .
    run macr_cell_size ( 10 , ? , num#str# , 6 , ?, ? ) .
    run macr_cell_size ( 10 , ? , num#str# , 7 , ?, ? ) .
    run macr_cell_size ( 11 , ? , num#str# , 8 , ?, ? ) .
  put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , num#str# , 1 , num#str# ,  num#col# ) + {&new-line}  +
        'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line} +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + {&new-line}
       .

t_grp-name = "" .

CASE SortType :
    when "По группам товаров ( и артикулу )" then
        do:
            FOR EACH gds-list BREAK BY gds-list.grp-name BY gds-list.artic :
                FIND ub.clients WHERE ub.clients.obj-type = gds-list.prod-type
                                                   AND ub.clients.obj-code = gds-list.prod-code NO-LOCK .
                run make-temp-table ( input gds-list.gds-code ,
                                      input v-cntxt-obj-type ,
                                      input v-cntxt-obj-code ) .

                RUN prtprice( gds-list.gds-name, gds-list.prt-root , gds-list.gds-code ,gds-list.unit-base ) .
                ACCUMULATE gds-list.artic (COUNT) .
                if ( ( ( ACCUM COUNT gds-list.artic )  modulo 50 ) = 0 ) AND
                           ( ( ACCUM COUNT gds-list.artic ) >= 50 ) then
                    RUN waitfram-show( "Обработано наименований : " +
                                                string( ACCUM COUNT gds-list.artic ) ) .
            END.
            HIDE stream Title_ FRAME TopFrame .
        end.
    when "Только по артикулу" then
        FOR EACH gds-list BREAK BY gds-list.artic :
            FIND ub.clients WHERE ub.clients.obj-type = gds-list.prod-type
                                               AND ub.clients.obj-code = gds-list.prod-code NO-LOCK.
            run make-temp-table ( input gds-list.gds-code ,
                                      input v-cntxt-obj-type ,
                                      input v-cntxt-obj-code ) .

            RUN prtprice( gds-list.gds-name, gds-list.prt-root  , gds-list.gds-code ,gds-list.unit-base ) .
            ACCUMULATE gds-list.artic (COUNT) .
            if ( ( ( ACCUM COUNT gds-list.artic )  modulo 50 ) = 0 ) AND
                       ( ( ACCUM COUNT gds-list.artic ) >= 50 ) then
                RUN waitfram-show( "Обработано наименований : " +
                                            string( ACCUM COUNT gds-list.artic ) ) .
        END.
END CASE .

HIDE stream PL FRAME BottomFrame .

PUT stream PL Line format "x(136)" SKIP .
output stream Title_ CLOSE .
output stream PL CLOSE .
Output stream Macr_Excel  close .
RUN waitfram-hide.

    run paramls-write in this-procedure
      (input "file"
      ,input string(v-ind)
      ,input v-file-name
      ) .

    run paramls-write in this-procedure
        (input "charcol"
        ,input ""
        ,input "1,2,3,4,5"
        ) .

  run end-proc .

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
    run rep/pl-prn.w (4 ,g#report-num) .
else
    run rep/pl-prn.w (0,g#report-num) .


{ rep/cur-rate.i }
PROCEDURE prtprice :
def input parameter tr   as character no-undo .
def input parameter node as integer  no-undo  .
define input parameter pp-gds-code like ub.goods.gds-code no-undo .
define input parameter pp-unit-base like ub.goods.unit-base no-undo .

def buffer b-gds-prt for ub.gds-prt .

def var gds_name as char no-undo.

assign gds_name = tr .

    FOR EACH b-gds-prt WHERE b-gds-prt.upper-code = node no-lock :

    find  first temp-prt where temp-prt.prt-code = b-gds-prt.node-code no-error .
    if not available temp-prt then next.

    run price-qnty .
                if ( OnlyPrices ) OR ( qnty <> 0 OR WaitQnty <> 0 ) then
                    do:
                        if NOT b-gds-prt.root then
                            tr = gds_name + '\' + b-gds-prt.node-name.


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
                                DO i = 1 to num-entries( right-trim(gds-list.grp-name, {&delim-grp}), {&delim-grp} ) :
                                    if OnlyPrices then
                                        if P_Type = 2 then  /* в  р у б л я х */
                                            do:
                                                DISPLAY stream PL sym1
                                                    string( fill( " " , i * 2 ) + {&delim-grp} + entry( i, gds-list.grp-name, {&delim-grp} ) )
                                                        @ gds-list.gds-name
                                                    sym7 with FRAME ReducedPriceList-Rubl .
                                                DOWN stream PL 1 with FRAME ReducedPriceList-Rubl .
                                                run gr-ex.
                                            end.
                                        else
                                            do:
                                                DISPLAY stream PL sym1
                                                    string( fill( " " , i * 2 ) + {&delim-grp} + entry( i, gds-list.grp-name, {&delim-grp} ) )
                                                        @ gds-list.gds-name
                                                    sym7 with FRAME ReducedPriceList-Val .
                                                DOWN stream PL 1 with FRAME ReducedPriceList-Val .
                                                run gr-ex.
                                            end.
                                    else
                                        if P_Type = 2 then  /* в  р у б л я х */
                                            do:
                                                DISPLAY stream PL sym1
                                                    string( fill( " " , i * 2 ) + {&delim-grp} + entry( i, gds-list.grp-name, {&delim-grp} ) )
                                                        @ gds-list.gds-name
                                                    sym9 with FRAME FullPriceList-Rubl .
                                                DOWN stream PL 1 with FRAME FullPriceList-Rubl .
                                                run gr-ex.

                                            end.
                                        else
                                            do:
                                                DISPLAY stream PL sym1
                                                    string( fill( " " , i * 2 ) + {&delim-grp} + entry( i, gds-list.grp-name, {&delim-grp} ) )
                                                        @ gds-list.gds-name
                                                    sym9 with FRAME FullPriceList-Val .
                                                DOWN stream PL 1 with FRAME FullPriceList-Val .
                                                run gr-ex.
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
                                    sym1 trim( string( temp-prt.b-code ) ) @ tb-code
                                    sym2 gds-list.artic
                                    sym3 tr @ gds-list.gds-name
                                    sym4 ub.clients.obj-name
                                    sym5 gds-list.unit-base @ t_unit-name
                                    sym6
                                    (if price = 0 or price = ? then "        ----" else string(price, ">>>>>9.99" ) ) format "x(9)" @ price
                                    sym7 with FRAME ReducedPriceList-Rubl .
                                DOWN    stream PL   1   with FRAME ReducedPriceList-Rubl .
                                run ex-str1 (tr).
                            end.
                            else
                            do:
                                DISPLAY stream PL
                                    sym1 trim( string( temp-prt.b-code ) ) @ tb-code
                                    sym2 gds-list.artic
                                    sym3 tr @ gds-list.gds-name
                                    sym4 ub.clients.obj-name
                                    sym5 gds-list.unit-base @ t_unit-name
                                    sym6 (if price = 0 or price = ? then "        ----" else string(price, ">>>>>>>>9.99" ) ) format "x(12)" @ price
                                    sym7 with FRAME ReducedPriceList-Val .
                                DOWN    stream PL   1   with FRAME ReducedPriceList-Val .
                                run ex-str1 (tr).
                            end.
                        else
                            if P_Type = 2 then  /* в  р у б л я х */
                            do:
                                DISPLAY stream PL
                                    sym1 trim( string( temp-prt.b-code ) ) @ tb-code
                                    sym2 gds-list.artic
                                    sym3 tr @ gds-list.gds-name
                                    sym4 ub.clients.obj-name
                                    sym5 gds-list.unit-base @ t_unit-name
                                    sym6 (if price = 0 or price = ? then "        ----" else string(price, ">>>>>>9.99" ) ) format "x(9)" @ price
                                    sym7 qnty   when qnty <> 0
                                    sym8 WaitQnty   when WaitQnty <> 0
                                    sym9
                                    with FRAME FullPriceList-Rubl .
                                DOWN    stream PL   1 with FRAME FullPriceList-Rubl .
                                run ex-str2 (tr).
                            end.
                            else
                            do:
                                DISPLAY stream PL
                                    sym1 trim( string( temp-prt.b-code ) ) @ tb-code
                                    sym2 gds-list.artic
                                    sym3 tr @ gds-list.gds-name
                                    sym4 ub.clients.obj-name
                                    sym5 gds-list.unit-base @ t_unit-name
                                    sym6 (if price = 0 or price = ? then "        ----" else string(price, ">>>>>>>>9.99" ) ) format "x(12)" @ price
                                    sym7 qnty   when qnty <> 0
                                    sym8 WaitQnty   when WaitQnty <> 0
                                    sym9
                                    with FRAME FullPriceList-Val .
                                DOWN    stream PL   1 with FRAME FullPriceList-Val .
                                run ex-str2 (tr).
                            end.

                        if ( t_grp-name <> gds-list.grp-name ) AND
                           lookup( "По группам товаров ( и артикулу )", SortType ) > 0 then
                            do:
                                CurrItem = "" .
                                DO i = 1 to num-entries( right-trim(gds-list.grp-name, {&delim-grp}), {&delim-grp} ):
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
                                            /* оглавления */
                                        end.
                                END .
                                t_grp-name = gds-list.grp-name .
                            end.
                    end.
        if NOT No-Prt then do:
           RUN prtprice( tr, b-gds-prt.node-code, gds-list.gds-code, gds-list.unit-base).
        end.
    END.
END PROCEDURE .


PROCEDURE price-qnty :

    if temp-prt.price-sale <> ? then
        do:
        /* message var-report-r-b  temp-prt.price-sale skip "Rubl_Coeff" Rubl_Coeff P_Type. */
            if var-report-r-b = "base" then
                assign price = ( if P_Type = 2 /* в  р у б л я х */
                                    then (temp-prt.price-sale * Rubl_Coeff )    else temp-prt.price-sale ) .

            else do:
                if base-code = 0 then do:
                assign price = ( if P_Type = 2 /* в  р у б л я х */
                                   then temp-prt.price-sale
                                   else ( temp-prt.price-sale / Rubl_Coeff )   )
                                   .
                                   end.
                else do:
                assign price = ( if P_Type = 2 /* в  р у б л я х */
                                   then ( temp-prt.price-sale )
                                   else  temp-prt.price-sale / Rubl_Coeff   ).
                                   end.


           end.
       end.
    else
        price = 0 .


  assign
      price = round(price ,2)
      qnty     = temp-prt.free-qnty
      Waitqnty = /* temp-prt.free-qnty */ 0
      .
END PROCEDURE .
procedure new-tmp-page :
 do
 on error undo, return error return-value
 :

    if   num#str#  >= 63000 then do:

        Output stream Macr_Excel  close .
        /*Запишем в файл параметров */
        run paramls-write in this-procedure
          (input "file"
          ,input string(v-ind)
          ,input v-file-name
          ) .
        /* создаем временный файл */
        run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
        output stream  Macr_Excel to value(v-file-name) .
        v-ind = v-ind + 1 .
        num#str# = 0 .
        run proc-print-header. /* снова шапку */
    end.

 end. /* do */
end procedure. /* new-tmp-page */


procedure gr-ex :
 do
 on error undo, return error return-value
 :
num#str# = num#str# + 1.
num#col# = 1 + i .
run macr_excel_char_with_format( string( fill( " " , i * 2 ) + {&delim-grp} + entry( i, gds-list.grp-name, {&delim-grp} ) )  , num#str# , num#col#  ) .
run macr_cell_format
( 10    ,       /* p-size     */
true  ,         /* p-bold     */
true  ,         /* p-italic   */
?    ,          /* p-color-bg */
num#str# ,      /* p-row      */
num#col# ,      /* p-col      */
num#str# ,      /* p-row-2    */
num#col# ) .    /* p-col-2    */
 end. /* do */
end procedure. /* gr-ex */



procedure ex-str1 :
define input parameter tr as character no-undo .
 do
 on error undo, return error return-value
 :
  num#str# = num#str# + 1.
  num#col# = 1.
  run macr_excel_char_with_format( trim( string( temp-prt.b-code ) ), num#str# , num#col#  ) .
  num#col# = 2.
  run macr_excel_char_with_format( trim( string( gds-list.artic ) ), num#str# , num#col#  ) .
  num#col# = 3.
  run macr_excel_char_with_format( tr , num#str# , num#col#  ) .
  num#col# = 4.
  run macr_excel_char_with_format( ub.clients.obj-name, num#str# , num#col#  ) .
  num#col# = 5.
  run macr_excel_char_with_format( gds-list.unit-base, num#str# , num#col#  ) .
  num#col# = 6.
  if price = 0 or price = ? then run macr_excel_char_with_format( "---", num#str# , num#col#  ) .
                            else  run macr_excel_dec ( price     , num#str# , num#col#   ) .
 end. /* do */
end procedure. /* ex-str1 */



procedure ex-str2 :
 define input parameter tr as character no-undo .
 do
 on error undo, return error return-value
 :

  num#str# = num#str# + 1.
  num#col# = 1.
  run macr_excel_char_with_format( trim( string( temp-prt.b-code ) ), num#str# , num#col#  ) .
  num#col# = 2.
  run macr_excel_char_with_format( trim( string( gds-list.artic ) ), num#str# , num#col#  ) .
  num#col# = 3.
  run macr_excel_char_with_format( tr , num#str# , num#col#  ) .
  num#col# = 4.
  run macr_excel_char_with_format( ub.clients.obj-name, num#str# , num#col#  ) .
  num#col# = 5.
  run macr_excel_char_with_format( gds-list.unit-base, num#str# , num#col#  ) .
  num#col# = 6.
  if price = 0 or price = ? then run macr_excel_char_with_format( "---", num#str# , num#col#  ) .
                            else  run macr_excel_dec ( price     , num#str# , num#col#   ) .
  num#col# = 7.
  run macr_excel_dec ( qnty    , num#str# , num#col#   ) .
  num#col# = 8.
  if waitqnty = 0 or waitqnty = ?
      then run macr_excel_char_with_format( "" , num#str# , num#col#  ) .
      else run macr_excel_dec ( waitqnty    , num#str# , num#col#   ) .


 end. /* do */
end procedure. /* ex-str2 */
{ rep/i-pricel.i  proc }
{ rep/r-libmcr.i macr_excel }