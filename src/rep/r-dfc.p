block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-dfc.p $
$Archive: rep/r-dfc.p $

Документ назначения цены

Автор: Чернова Светлана Александровна
Дата создания: 03/15/06
Author: Svetlana Chernova
Creation date: 03/15/06

*/

define input parameter p-recid as recid no-undo .
define input parameter v-curr-code as integer   no-undo .
define input parameter v-clas as character no-undo .
define input parameter v-sort as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-dfc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-dfc.p $":U .
define variable vss-description as character no-undo init "Документ назначения цены".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ cmp/r-page1.i  }
{ rep/f-fdec.i   }
{ gbl/paramls.i  }
{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
{ rep/repfrm.i on 100 } /* Показать окно информации о текущем процессе */
{ rep/r-sym.i    }
{ rep/rep-bt.i   }
{ trg/factord.i  }
{ rep/lkp-font.i }

define variable v-curr-abbr as character no-undo .
define variable v-Reportname as character no-undo .

define variable v-name as character no-undo init "" .
define variable v-type as integer   no-undo .
define variable v-fact-order as decimal   no-undo .
define variable new-curr-code as integer   no-undo .

run day-begin-fact-order in this-procedure
   (input x-date-alone ,
   output v-fact-order) .

define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_price-list-type for ub.price-list-type .
define buffer buf_price-doc-forming-gds-qnty for ub.price-doc-forming-gds-qnty  .
define buffer buf_price-doc-forming-gds-sum for ub.price-doc-forming-gds-sum  .
define buffer buf_price-doc-forming-gds-tnv for ub.price-doc-forming-gds-tnv .

find first buf_price-doc-forming no-lock where recid(buf_price-doc-forming) =  p-recid no-error .
find first buf_price-list-type no-lock where
           buf_price-list-type.plt-db-num =  buf_price-doc-forming.plt-db-num and
           buf_price-list-type.plt-id     =  buf_price-doc-forming.plt-id
           no-error .

define buffer buf_qnty-group for ub.qnty-group  .
define buffer buf_sum-group  for ub.sum-group  .
define buffer buf_tnv-group  for ub.turnover-group  .

find first buf_qnty-group no-lock where
           buf_qnty-group.qgr-id       = buf_price-list-type.qgr-id and
           buf_qnty-group.qgr-db-num   = buf_price-list-type.qgr-db-num
           no-error .
find first buf_sum-group no-lock where
           buf_sum-group.sgr-id       = buf_price-list-type.sgr-id and
           buf_sum-group.sgr-db-num   = buf_price-list-type.sgr-db-num
           no-error .
find first buf_tnv-group no-lock where
           buf_tnv-group.tog-id       = buf_price-list-type.have-tog-id and
           buf_tnv-group.tog-db-num   = buf_price-list-type.have-tog-db-num
           no-error .


v-Reportname = "Документ назначения цены "  + buf_price-doc-forming.name .
define stream  OutStream  .
define stream  macr_excel .

define variable v-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable num#col#    as integer no-undo .
define variable C-c    as integer no-undo .
define variable C-str  as character no-undo .
define variable str--1 as character Format "x(60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var  as integer no-undo .
define variable var-1  as integer no-undo .
define variable var-2  as integer no-undo .
define buffer this_object for  ub.clients .

define variable num-ln as integer   no-undo .

def var i as int no-undo.
def var j as int no-undo.
define variable Counter1 as integer init 0  no-undo .

def var LineBuf       as char    no-undo.
def var Line       as char    no-undo.
def var UndLine    as char    no-undo.

def var     Lines_Counter as   int  init 0  no-undo.
def var     Tmp_Counter   as   int  init 0  no-undo.

define variable vv0 as character no-undo .
define variable vv1 as character no-undo .
define variable vv2 as character no-undo .
define variable vv3 as character no-undo .
define variable vv4 as character no-undo .
define variable vv5 as character no-undo .
define variable vv6 as character no-undo .
define variable vv7 as character no-undo .

define variable t-1 as character no-undo .
define variable t-2 as character no-undo .
define variable t-3 as character no-undo .
define variable t-4 as character no-undo .
define variable t-5 as character no-undo .

define buffer buf_gds-obj for ub.gds-obj  .
define buffer buf_goods for ub.goods  .

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
define temp-table temp-header no-undo
field id as decimal                 /* Номер колонки*/
field first_  as decimal            /* >=  < */
field to_   as decimal
field last_   as decimal
field name    as character          /* < */

index pi first_  to_
.

define temp-table temp-price no-undo
field b-code   as integer
field gds-code as integer
field id as decimal   /* Номер колонки*/
field price-sale as decimal
.

define temp-table temp-pdf no-undo
field gds-code  as integer
field grp-code  as integer
field prod-typecode as char
field artic     as char
field gds-name  as char
field grp-name  as char
field prod-name as char
field b-code as integer
field prior  as integer
field date1  as date
field date2  as date
field plt-id     as int
field plt-db-num as int
field nul        as int


index pi
b-code
prior
plt-id
plt-db-num

index pi2
gds-code
prior
plt-id
plt-db-num

index pi3
artic
prior
plt-id
plt-db-num

index pi4
gds-name
prior
plt-id
plt-db-num
.


define variable v-kol-price as integer   no-undo .

DEFINE FRAME plan-menu
    HEADER
    string( "Лист " + string( PAGE-NUMBER(OutStream) , ">>>>9") ) AT 80 format "X(13)" SKIP
    UndLine format "X(80)" AT 1
    with width {&DOS_CW} down stream-io use-text NO-UNDERLINE  NO-BOX no-labels.

  if session:set-wait-state("compiler") then.
    { cmp/open-out.i STREAM OutStream " " ReportPageHeight }
  define variable v-prn0 as character no-undo .

  assign
    Line    = fill("-", 230)
    UndLine = fill("_", 230)
    LineBuf = fill("_", 240)
  .

define variable v-is-base as logical no-undo .
{ gbl/rbisbase.i    v-is-base  }

if v-is-base = true then do:
end.
else do:
end.

/*-----------------------------------------------------------------------------------------------------------------------*/
v-ind = 0    .

FORM with frame plan-menu .
 /* создаем временный файл */

    num#str# = 0 .
      Output stream Macr_Excel  close .
      run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name) .
      output stream macr_excel to value(v-file-name) .
      run make-tt in this-procedure .
      v-ind = v-ind + 1.
      find ub.clients no-lock where
           ub.clients.obj-type = {&cmp}                and
           ub.clients.obj-code = v-cntxt-host-code-obj
           no-error .
      run PrintTitul in this-procedure .

      /* по строкам -------------------------------------------------------------------------------------------- */

define variable p-sort-pole as character no-undo .
define variable p-sort-pole2 as character no-undo .
define variable p-sort-pole-a as character no-undo .
define variable p-query-prepare as character no-undo .
define variable p-table-name as character no-undo .

p-table-name = "temp-pdf" .

/* порядок сортировки - самый низ */
case v-sort :
  when "sort-code":U  then do:
    p-sort-pole-a = "temp-pdf.b-code" .
  end.
  when "sort-artic":U then do:
      p-sort-pole-a = "temp-pdf.artic" .
  end.
  when "sort-name":U then do:
      p-sort-pole-a = "temp-pdf.gds-name" .
  end.
end case.

case v-clas:
    when "no-classify":U then do:
       p-query-prepare  = substitute( "for each temp-pdf by &1 " , p-sort-pole-a ).
       p-sort-pole   = "nul" .
       p-sort-pole2  = "nul" .
    end.
    when "prod":U        then do:
       p-query-prepare  = substitute( "for each temp-pdf by &1 by &2 " , "temp-pdf.prod-typecode" , p-sort-pole-a).
       p-sort-pole   = "prod-typecode" .
       p-sort-pole2  = "nul" .
    end.
    when "grp-goods":U   then do:
       p-query-prepare  = substitute( "for each temp-pdf by &1 by &2 " , "temp-pdf.grp-code" , p-sort-pole-a).
       p-sort-pole   = "grp-code" .
       p-sort-pole2  = "nul" .
    end.
    when "prod/grp-goods":U then do:
       p-query-prepare  = substitute( "for each temp-pdf by &1 by &2 by &3 " , "temp-pdf.prod-typecode" , "temp-pdf.grp-code" , p-sort-pole-a) .
       p-sort-pole   = "prod-typecode" .
       p-sort-pole2  = "grp-code" .
    end.
    when "grp-goods/prod":U then do:
       p-query-prepare  = substitute( "for each temp-pdf by &1 by &2 by &3 " , "temp-pdf.grp-code" , "temp-pdf.prod-typecode" , p-sort-pole-a) .
       p-sort-pole   = "grp-code" .
       p-sort-pole2  = "prod-typecode" .
    end.
end case.


     run din-tt-go (
          p-table-name    ,
          P-query-prepare ,
          p-sort-pole ,
          p-sort-pole2
          ).


      run print-all-itog in this-procedure .
      /* ... Подвал. --- */
      run on-same-page in this-procedure (input 1) .
      run PrintPodval in this-procedure .
      run paramls-write in this-procedure
      (input "file"
      ,input string(v-ind)
      ,input v-file-name
      ) .
      page stream OutStream .

HIDE STREAM OutStream FRAME plan-menu.
HIDE stream OutStream FRAME BottomFrame .
HIDE stream OutStream FRAME BottomFrame2 .
output stream OutStream CLOSE .
Output stream Macr_Excel  close .

{ rep/repfrm.i off } /* Показать окно информации о текущем процессе */

    run paramls-write in this-procedure
        (input "charcol"
        ,input ""
        ,input "1,2,3"
        ) .


  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .

  run end-proc in this-procedure .
  define variable v-orient-page as character no-undo .
  run How-name in this-procedure (
      input ReportPageHeight,
      input ReportPageWidth,
      output v-orient-page )
      .
  if v-orient-page = "A4-lans":U then DisabledOptions = 8 .
                                 else DisabledOptions = 0 .


  run gbl/prnfilen.w
    (input  ""
    ,input  DisabledOptions
    ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
    ,input  ReportFontNum
    ,output v-user-action
    ,output v-printed
    ) .


procedure print-line :
do on error undo, return error return-value :
define input  parameter p-recid as recid no-undo .
define buffer buf_temp-pdf for temp-pdf  .

find first buf_temp-pdf where recid(buf_temp-pdf) = p-recid no-error .

define variable  p-code  as character no-undo .
define variable  p-artic as character no-undo .
define variable  p-name  as character no-undo .

p-code  = string(buf_temp-pdf.b-code,"9999999999" ) .
p-artic = buf_temp-pdf.artic   .
p-name  = buf_temp-pdf.gds-name.

  assign
     Lines_Counter = Lines_Counter + 1
    .

  if line-counter( OutStream ) + 2 > page-size( OutStream ) then do:
     run p-line in this-procedure.
     page stream OutStream.
     PUT STREAM OutStream UNFORMATTED
         string( "Лист " + string( PAGE-NUMBER(OutStream) , ">>>>9") ) AT 100 format "X(13)" SKIP .
     run print-header-txt in this-procedure.
     end.

  if line-counter( OutStream ) < Tmp_Counter then
    assign
    .

  assign
    Tmp_Counter  = line-counter( OutStream )
    num-ln = num-ln + 1
  .

  if line-counter( OutStream ) + j > page-size( OutStream ) then  PAGE STREAM OutStream.



define variable ii as integer   no-undo .
define variable v-price-sale as decimal   no-undo .

    PUT STREAM OutStream UNFORMATTED
        sym1                format "X(1)" space(0)
        p-code              format "X(10)" space(0)
        sym2                format "X(1)" space(0)
        p-artic             format "X(16)" space(0)
        sym3                format "X(1)" space(0)
        p-name              format "X(30)" space(0)

    .
    num#col# = 1.
    num#str# = num#str# + 1.
    run macr_excel_char in this-procedure(p-code  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char in this-procedure(p-artic , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char in this-procedure(p-name  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .

      repeat ii = 1 to v-kol-price :
        find first  temp-price where
                    temp-price.gds-code = int(p-code) and
                    temp-price.id = ii no-error .
                    if available temp-price then  v-price-sale = temp-price.price-sale .
                                            else v-price-sale = 0 .
        put stream outstream unformatted
            sym1                                        format "x(1)"  space(0)
            string(v-price-sale,">>>>>>>9.99")          format "x(11)" space(0)
            .
        run macr_excel_dec in this-procedure( v-price-sale , num#str# , num#col# ).
            assign  num#col# = num#col# + 1 .
      end.

    PUT STREAM OutStream UNFORMATTED skip.

end.
end procedure. /* print-line */



procedure print-all-itog :
  /* Итоговые суммы */
end procedure. /* print-all-itog */


procedure PrintTitul :
  do  on error undo, return error return-value  :
  define variable cc as integer no-undo .
  define variable tt as integer no-undo .
  define variable pp as integer no-undo .
  define variable ii as integer   no-undo .

/* ---------------- Создание заголовка :--------------------------------------------------------------------------- */

if v-curr-code = ? then
   find first ub.currency no-lock where ub.currency.curr-code = new-curr-code no-error .
else find first ub.currency no-lock where ub.currency.curr-code = v-curr-code no-error .

 if available ub.currency then v-curr-abbr = ub.currency.curr-abbr .

PUT STREAM OutStream UNFORMATTED
space(1)
   ub.clients.obj-name skip
   v-ReportNAme skip
   str1 skip
   "Дата печати " + cur-time-date()  skip
   "Цены указаны в " + v-curr-abbr skip
      .

  define variable i as integer no-undo .
  Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
    PUT STREAM OutStream UNFORMATTED  Entry(i,ReportHeader,chr(10))  AT 1 format "X(90)" SKIP.
  End.

    num#str# = 1.
    num#col# = 1.
    run macr_excel_char in this-procedure( "по фирме " + CAPS( ub.clients.obj-name)   , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_excel_char in this-procedure( v-Reportname , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_excel_char in this-procedure( str1 , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_excel_char in this-procedure("Дата печати " + cur-time-date()   , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_excel_char in this-procedure("Цены указаны в " + v-curr-abbr   , num#str# , num#col#   ) .


/* шапка */
    num#str# = num#str# + 1.
    run macr_excel_char in this-procedure("Код"  , num#str# , num#col#   ) .    run macr_cell_size ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 2.
    run macr_excel_char in this-procedure("Артикул"  , num#str# , num#col#   ) .  run macr_cell_size ( 16 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 3.
    run macr_excel_char in this-procedure("Наименование"  , num#str# , num#col#   ) . run macr_cell_size ( 30 , ? , num#str# , num#col# , ?, ? ) .

    run print-header-txt in this-procedure .
    repeat ii = 1 to v-kol-price :
      find first  temp-header where temp-header.id = ii no-error .
      num#col# = num#col# + 1.
      run macr_excel_char in this-procedure( temp-header.name , num#str# , num#col#   ) .
    end.


    run macr_cell_format in this-procedure
    ( 10    ,    /* p-size     */
      true  ,    /* p-bold     */
      false ,    /* p-italic   */
      ?     ,    /* p-color-bg */
      1     ,    /* p-row      */
      1     ,    /* p-col      */
      num#str# , /* p-row-2    */
      num#col# ) .      /* p-col-2    */

     put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , num#str# , 1 , num#str# ,  num#col# ) + {&new-line}  +
       'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line} +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + {&new-line}
       .
    put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , num#str# , 1 , num#str# ,  3 ) + {&new-line}  +
       'BORDER( 2, , , , , , , , , , ) '  + {&new-line} .

    /* ... конец создания заголовка. --- */
  end.
end procedure. /* PrintTitul */


procedure PrintPodval :
  do on error undo, return error return-value  :
  define variable pp as integer no-undo .
  define variable rr as integer no-undo .
    run p-line in this-procedure.

    /* ... конец создания Подвал. --- */
  end.
end procedure. /* PrintPodval */



PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( OutStream ) then return .
  if line-counter( OutStream ) + p-line-number > page-size( OutStream ) then do:

    run p-line in this-procedure.
    page stream OutStream .
    end.
end procedure. /* on-same-page */


procedure print-header-txt :
define variable ii as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run p-line in this-procedure.
    PUT STREAM OutStream UNFORMATTED  ":Код"  AT 1 format "X(11)" .
    PUT STREAM OutStream UNFORMATTED  ":Артикул"  format "X(17)" .
    PUT STREAM OutStream UNFORMATTED  ":Наименование"  format "X(31)" .
    if v-kol-price = 1 then do:
      put stream outstream unformatted   ":Цена" format "x(12)" space(0)  .
    end.
    else do:
      repeat ii = 1 to v-kol-price :
        find first  temp-header where temp-header.id = ii no-error .
        put stream outstream unformatted   ":от " + string(temp-header.first_)    format "x(12)" space(0)  .
      end.
    end.
    put stream outstream unformatted skip .
    run p-line in this-procedure.
  end.

end procedure. /* print-header-txt */

procedure p-line :
define variable ii as integer   no-undo .
  do
  on error undo, return error return-value
  :
    PUT STREAM OutStream UNFORMATTED  fill("-",11)  AT 1 format "X(11)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",17)  format "X(17)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",31)  format "X(31)" .
      repeat ii = 1 to v-kol-price :
        put stream outstream unformatted   fill("-",12)  format "x(12)" space(0)  .
      end.
    PUT STREAM OutStream UNFORMATTED  skip .

  end.

end procedure. /* p-line */


procedure make-header-qnty :
define buffer buf_qnty-in-qnty-group for ub.qnty-in-qnty-group  .
define buffer last_qnty-in-qnty-group for ub.qnty-in-qnty-group  .

define output parameter ii as integer   no-undo  .
  do
  on error undo, return error return-value
  :
    ii = 0 .
    for each buf_qnty-in-qnty-group no-lock where
              buf_qnty-in-qnty-group.qgr-db-num  = buf_qnty-group.qgr-db-num  and
              buf_qnty-in-qnty-group.qgr-id      = buf_qnty-group.qgr-id       and
              buf_qnty-in-qnty-group.stts        = 0
              break by buf_qnty-in-qnty-group.ggr-qnty
              :
              find first  last_qnty-in-qnty-group no-lock  where
                          last_qnty-in-qnty-group.stts       = 0 and
                          last_qnty-in-qnty-group.qgr-db-num = buf_qnty-in-qnty-group.qgr-db-num and
                          last_qnty-in-qnty-group.qgr-id     = buf_qnty-in-qnty-group.qgr-id      and
                          last_qnty-in-qnty-group.ggr-qnty   > buf_qnty-in-qnty-group.ggr-qnty
                          use-index pi no-error .

        ii = ii + 1.
        create  temp-header.
          assign
          temp-header.id     = ii
          temp-header.first_ = buf_qnty-in-qnty-group.ggr-qnty
          temp-header.to_  = if available last_qnty-in-qnty-group then  last_qnty-in-qnty-group.ggr-qnty   else ?
          temp-header.last_  = if available last_qnty-in-qnty-group then ( last_qnty-in-qnty-group.ggr-qnty - 1 )  else ?
          temp-header.name   = "не менее " + string( buf_qnty-in-qnty-group.ggr-qnty)
          temp-header.name   = "c " + string (temp-header.first_) +
          (if temp-header.last_ = ? then ""
                                    else " по " + string (temp-header.last_))
          .
    end.
  end.

end procedure. /* make-header */


procedure make-header-sum :
define buffer buf_sum-in-sum-group for ub.sum-in-sum-group  .
define buffer last_sum-in-sum-group for ub.sum-in-sum-group  .

define output parameter ii as integer   no-undo  .
  do
  on error undo, return error return-value
  :
    ii = 0 .
    for each buf_sum-in-sum-group no-lock where
              buf_sum-in-sum-group.sgr-db-num  = buf_sum-group.sgr-db-num  and
              buf_sum-in-sum-group.sgr-id      = buf_sum-group.sgr-id       and
              buf_sum-in-sum-group.stts        = 0
              break by buf_sum-in-sum-group.ssg-summa
              :
              find first  last_sum-in-sum-group no-lock  where
                          last_sum-in-sum-group.stts       = 0 and
                          last_sum-in-sum-group.sgr-db-num = buf_sum-in-sum-group.sgr-db-num and
                          last_sum-in-sum-group.sgr-id     = buf_sum-in-sum-group.sgr-id      and
                          last_sum-in-sum-group.ssg-summa   > buf_sum-in-sum-group.ssg-summa
                          use-index pi no-error .

        ii = ii + 1.
        create  temp-header.
          assign
          temp-header.id     = ii
          temp-header.first_ = buf_sum-in-sum-group.ssg-summa
          temp-header.to_  = if available last_sum-in-sum-group then  last_sum-in-sum-group.ssg-summa   else ?
          temp-header.last_  = if available last_sum-in-sum-group then ( last_sum-in-sum-group.ssg-summa - 1 )  else ?
          temp-header.name   = "не менее " + string( buf_sum-in-sum-group.ssg-summa)
          temp-header.name   = "c " + string (temp-header.first_) +
          (if temp-header.last_ = ? then ""
                                    else " по " + string (temp-header.last_))
          .
    end.
  end.

end procedure. /* make-header-sum */

procedure make-header-tnv :
define buffer buf_tnv-in-turnover-group for ub.tnv-in-turnover-group  .
define buffer last_tnv-in-turnover-group for ub.tnv-in-turnover-group  .

define output parameter ii as integer   no-undo  .
  do
  on error undo, return error return-value
  :
    ii = 0 .
    for each buf_tnv-in-turnover-group no-lock where
              buf_tnv-in-turnover-group.tog-db-num  = buf_tnv-group.tog-db-num  and
              buf_tnv-in-turnover-group.tog-id      = buf_tnv-group.tog-id       and
              buf_tnv-in-turnover-group.stts        = 0
              break by buf_tnv-in-turnover-group.ttg-summa
              :
              find first  last_tnv-in-turnover-group no-lock  where
                          last_tnv-in-turnover-group.stts       = 0 and
                          last_tnv-in-turnover-group.tog-db-num = buf_tnv-in-turnover-group.tog-db-num and
                          last_tnv-in-turnover-group.tog-id     = buf_tnv-in-turnover-group.tog-id      and
                          last_tnv-in-turnover-group.ttg-summa   > buf_tnv-in-turnover-group.ttg-summa
                          use-index pi no-error .

        ii = ii + 1.
        create  temp-header.
          assign
          temp-header.id     = ii
          temp-header.first_ = buf_tnv-in-turnover-group.ttg-summa
          temp-header.to_  = if available last_tnv-in-turnover-group then  last_tnv-in-turnover-group.ttg-summa   else ?
          temp-header.last_  = if available last_tnv-in-turnover-group then ( last_tnv-in-turnover-group.ttg-summa - 1 )  else ?
          temp-header.name   = "не менее " + string( buf_tnv-in-turnover-group.ttg-summa)
          temp-header.name   = "c " + string (temp-header.first_) +
          (if temp-header.last_ = ? then ""
                                    else " по " + string (temp-header.last_))
          .
    end.
  end.

end procedure. /* make-header-sum */

procedure make-header :
define output parameter ii as integer   no-undo  .
  do
  on error undo, return error return-value
  :
    ii = 0 .
        ii = ii + 1.
        create  temp-header.
          assign
          temp-header.id     = ii
          temp-header.first_ = ?
          temp-header.to_  =  ?
          temp-header.last_  =  ?
          temp-header.name   = "Цена"
          .
  end.

end procedure. /* make-header */


procedure make-tt :

define buffer buf_bar-code for ub.bar-code  .
define buffer buf_clients  for ub.clients  .
define variable v-i as integer   no-undo .

  do
  on error undo, return error return-value
  :
  define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds.
  v-i = 0.
  for each temp-price : delete temp-price. end.
  for each temp-pdf   : delete temp-pdf  . end.

  for each buf_price-doc-forming-gds no-lock where
           buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
           buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
           buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
           buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id
           :

find first buf_bar-code no-lock where buf_bar-code.b-code = buf_price-doc-forming-gds.b-code no-error .
find first buf_goods    no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error .
find first buf_clients  no-lock where buf_clients.obj-type = buf_goods.prod-type and
                                      buf_clients.obj-code = buf_goods.prod-code no-error.
  v-i = v-i + 1.
{ rep/repfrm.i disp v-i buf_goods.gds-name }
new-curr-code = buf_price-list-type.curr-code.



if logical ( buf_price-list-type.have-rs-qnty-group)  = false and
             buf_price-list-type.have-rs-sum-group    = false and
   logical ( buf_price-list-type.have-rs-turn-group) = false then do:
   run make-header in this-procedure ( output v-kol-price ).
   find first temp-header no-error .
             create temp-price .
             assign
                temp-price.b-code     = buf_price-doc-forming-gds.b-code
                temp-price.gds-code   = buf_bar-code.gds-code
                temp-price.id         = temp-header.id
                temp-price.price-sale = buf_price-doc-forming-gds.price-sale-doc
             .
end.
else do:
    if logical ( buf_price-list-type.have-rs-qnty-group)  = true then do:
    run make-header-qnty in this-procedure ( output v-kol-price ).
        for each temp-header :
          find first buf_price-doc-forming-gds-qnty no-lock where
                      buf_price-doc-forming-gds-qnty.b-code     = buf_price-doc-forming-gds.b-code  and
                      buf_price-doc-forming-gds-qnty.pdf-db     = buf_price-doc-forming-gds.pdf-db  and
                      buf_price-doc-forming-gds-qnty.pdf-id     = buf_price-doc-forming-gds.pdf-id  and
                      buf_price-doc-forming-gds-qnty.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
                      buf_price-doc-forming-gds-qnty.plt-id     = buf_price-doc-forming-gds.plt-id  and
                      buf_price-doc-forming-gds-qnty.qgr-db-num = buf_price-list-type.qgr-db-num    and
                      buf_price-doc-forming-gds-qnty.qgr-id     = buf_price-list-type.qgr-id        and
                      buf_price-doc-forming-gds-qnty.ggr-qnty   = temp-header.first_  no-error .
                if available buf_price-doc-forming-gds-qnty then do:
                    create temp-price .
                    assign
                        temp-price.b-code     = buf_price-doc-forming-gds.b-code
                        temp-price.gds-code   = buf_bar-code.gds-code
                        temp-price.id         = temp-header.id
                        temp-price.price-sale = buf_price-doc-forming-gds-qnty.price-sale-doc
                    .
                end.
        end.
    end.
    if buf_price-list-type.have-rs-sum-group              = true then do:
       run make-header-sum in this-procedure ( output v-kol-price ).
        for each temp-header :
          find first buf_price-doc-forming-gds-sum no-lock where
                      buf_price-doc-forming-gds-sum.b-code     = buf_price-doc-forming-gds.b-code  and
                      buf_price-doc-forming-gds-sum.pdf-db     = buf_price-doc-forming-gds.pdf-db  and
                      buf_price-doc-forming-gds-sum.pdf-id     = buf_price-doc-forming-gds.pdf-id  and
                      buf_price-doc-forming-gds-sum.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
                      buf_price-doc-forming-gds-sum.plt-id     = buf_price-doc-forming-gds.plt-id  and
                      buf_price-doc-forming-gds-sum.sgr-db-num = buf_price-list-type.sgr-db-num    and
                      buf_price-doc-forming-gds-sum.sgr-id     = buf_price-list-type.sgr-id        and
                      buf_price-doc-forming-gds-sum.ssg-summa  = temp-header.first_  no-error .
                if available buf_price-doc-forming-gds-sum then do:
                    create temp-price .
                    assign
                        temp-price.b-code     = buf_price-doc-forming-gds.b-code
                        temp-price.gds-code   = buf_bar-code.gds-code
                        temp-price.id         = temp-header.id
                        temp-price.price-sale = buf_price-doc-forming-gds-sum.price-sale-doc
                    .
                end.
        end.

    end.
    if logical ( buf_price-list-type.have-rs-turn-group) = true then do:
       run make-header-tnv in this-procedure ( output v-kol-price ).
        for each temp-header :
          find first buf_price-doc-forming-gds-tnv no-lock where
                      buf_price-doc-forming-gds-tnv.b-code     = buf_price-doc-forming-gds.b-code  and
                      buf_price-doc-forming-gds-tnv.pdf-db     = buf_price-doc-forming-gds.pdf-db  and
                      buf_price-doc-forming-gds-tnv.pdf-id     = buf_price-doc-forming-gds.pdf-id  and
                      buf_price-doc-forming-gds-tnv.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
                      buf_price-doc-forming-gds-tnv.plt-id     = buf_price-doc-forming-gds.plt-id  and
                      buf_price-doc-forming-gds-tnv.tog-db-num = buf_price-list-type.have-tog-db-num    and
                      buf_price-doc-forming-gds-tnv.tog-id     = buf_price-list-type.have-tog-id        and
                      buf_price-doc-forming-gds-tnv.ttg-summa   = temp-header.first_  no-error .
                if available buf_price-doc-forming-gds-tnv then do:
                    create temp-price .
                    assign
                        temp-price.b-code     = buf_price-doc-forming-gds.b-code
                        temp-price.gds-code   = buf_bar-code.gds-code
                        temp-price.id         = temp-header.id
                        temp-price.price-sale = buf_price-doc-forming-gds-tnv.price-sale-doc
                    .
                end.
        end.

    end.
end.

            find first temp-pdf where
                        temp-pdf.b-code     = buf_price-doc-forming-gds.b-code     and
                        temp-pdf.plt-id     = buf_price-doc-forming-gds.plt-id     and
                        temp-pdf.plt-db-num = buf_price-doc-forming-gds.plt-db-num  no-error .
            if not available temp-pdf then do:
                create temp-pdf.
                assign
                    temp-pdf.gds-code   = buf_bar-code.gds-code
                    temp-pdf.prior      = buf_price-list-type.priority
                    temp-pdf.date1      = buf_price-doc-forming-gds.start-date
                    temp-pdf.date2      = buf_price-doc-forming-gds.end-date
                    temp-pdf.b-code     = buf_price-doc-forming-gds.b-code
                    temp-pdf.plt-id     = buf_price-doc-forming-gds.plt-id
                    temp-pdf.plt-db-num = buf_price-doc-forming-gds.plt-db-num
                    temp-pdf.gds-name   = buf_goods.gds-name
                    temp-pdf.artic      = buf_goods.artic
                    temp-pdf.prod-typecode  = buf_goods.prod-type + string(buf_goods.prod-code)
                    temp-pdf.prod-name  = buf_clients.obj-name
                    temp-pdf.grp-code   = buf_goods.grp-code
                    temp-pdf.grp-name   = buf_goods.grp-name
                .
            end.
  end.
end.
end procedure. /* make-tt */


procedure din-tt-go :
define input  parameter p-table-name    as character no-undo .     /* имя таблицы, где будем искать */
define input  parameter P-query-prepare as character no-undo .     /* описание выборки - query  */
define input  parameter p-sort-pole  as character no-undo .        /* поле сортировки - break первого уровня */
define input  parameter p-sort-pole2 as character no-undo .        /* поле сортировки - break второго уровня */

define variable qh as widget-handle no-undo .
define variable bh as widget-handle no-undo .

define variable old-sort-pole as character no-undo .
define variable new-sort-pole as character no-undo .
define variable old-sort-pole2 as character no-undo .
define variable new-sort-pole2 as character no-undo .

  do
  on error undo, return error return-value
  :
    create buffer bh for table p-table-name.
    create query qh.

      qh:set-buffers (bh).
      qh:query-prepare (p-query-prepare).
      qh:query-open ().
      /* Обработка первой записи */
      qh:get-first ().
      if bh:available <> true then do: /* если первая запись не доступна - выходим */
         qh:query-close() .
         delete object qh.
         delete object bh.
         return.
       end.
       old-sort-pole  = bh:buffer-field ( p-sort-pole  ):buffer-value .   /* значение поля */
       old-sort-pole2 = bh:buffer-field ( p-sort-pole2 ):buffer-value .
       run print-grp-header  ( bh:recid , old-sort-pole ) .
       run print-grp-header2 ( bh:recid , old-sort-pole2 ) .

      /* Обработка остальной выборки */
      do while qh:query-off-end = false :
          new-sort-pole  = bh:buffer-field ( p-sort-pole ):buffer-value .
          new-sort-pole2 = bh:buffer-field ( p-sort-pole2):buffer-value .
          /* первый уровень классификации */
          if old-sort-pole <> new-sort-pole then do:
            run print-grp-header ( bh:recid , new-sort-pole ) .
          end.
              /* второй уровень классификации */
              if old-sort-pole2 <> new-sort-pole2 or old-sort-pole <> new-sort-pole
              then do:
                run print-grp-header2 ( bh:recid , new-sort-pole2 ) .
              end.

          /* Печать строки */
          run print-line ( bh:recid ) .

          qh:get-next().
          old-sort-pole  = new-sort-pole.
          old-sort-pole2 = new-sort-pole2.
      end.

    qh:query-close() .
    delete object qh.
    delete object bh.

  end.
end procedure. /* din-tt-go */


procedure print-grp-header :
define input  parameter p-recid as recid no-undo .
define input  parameter p-sort-pole as character no-undo .
define buffer buf_temp-pdf for temp-pdf  .
define variable v-name as character no-undo .
define variable v-val as character no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_temp-pdf where recid(buf_temp-pdf) = p-recid no-error .
    case v-clas:
        when "no-classify":U then do:
            return.
        end.
        when "prod":U        then do:
          v-name = "По производителю " .
          if available buf_temp-pdf then v-val = buf_temp-pdf.prod-name .
          else      v-val = p-sort-pole.
        end.
        when "grp-goods":U   then do:
          v-name = "По группе " .
          if available buf_temp-pdf then v-val = buf_temp-pdf.grp-name .
          else      v-val = p-sort-pole.
        end.
        when "prod/grp-goods":U then do:
          v-name = "По производителю " .
          if available buf_temp-pdf then v-val = buf_temp-pdf.prod-name .
          else      v-val = p-sort-pole.
        end.
        when "grp-goods/prod":U then do:
          v-name = "По группе " .
          if available buf_temp-pdf then v-val = buf_temp-pdf.grp-name .
          else      v-val = p-sort-pole.
        end.
    end case.


    put stream outstream unformatted  ( v-name + v-val ) at 1 skip .
    num#col# = 1 .
    num#str# = num#str# + 1 .

    run macr_cell_format in this-procedure
        ( 10    ,            /* p-size     */
          true  ,            /* p-bold     */
          false ,            /* p-italic   */
          ?     ,            /* p-color-bg */
          num#str# ,         /* p-row      */
          num#col# ,         /* p-col      */
          num#str# ,         /* p-row-2    */
          num#col# ) .       /* p-col-2    */
    run macr_excel_char in this-procedure( v-name + v-val  , num#str# , num#col#   ) .
  end.
end procedure. /* print-grp-header */


procedure print-grp-header2 :
define input  parameter p-recid as recid no-undo .
define input  parameter p-sort-pole as character no-undo .
define buffer buf_temp-pdf for temp-pdf  .
define variable v-name as character no-undo .
define variable v-val as character no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_temp-pdf where recid(buf_temp-pdf) = p-recid no-error .
    case v-clas:
        when "no-classify":U then do:
            return.
        end.
        when "prod":U        then do:
           return.
        end.
        when "grp-goods":U   then do:
           return.
        end.
        when "prod/grp-goods":U then do:
          v-name = "По группе " .
          if available buf_temp-pdf then v-val = buf_temp-pdf.grp-name .
                                    else v-val = p-sort-pole.
        end.
        when "grp-goods/prod":U then do:
          v-name = "По производителю " .
          if available buf_temp-pdf then v-val = buf_temp-pdf.prod-name .
                                    else v-val = p-sort-pole.
        end.
    end case.

    put stream outstream unformatted  ( v-name + v-val ) at 10 skip .
    num#col# = 2 .
    num#str# = num#str# + 1 .

    run macr_cell_format in this-procedure
        ( 10    ,            /* p-size     */
          true  ,            /* p-bold     */
          false ,            /* p-italic   */
          ?     ,            /* p-color-bg */
          num#str# ,       /* p-row      */
          num#col# ,            /* p-col      */
          num#str# ,         /* p-row-2    */
          num#col# ) .       /* p-col-2    */
    run macr_excel_char in this-procedure ( v-name + v-val  , num#str# , num#col# ) .
  end.
end procedure. /* print-grp-header */

{ rep/r-libmcr.i macr_excel }