block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-ospis.p $
$Archive: cus/r-ospis.p $

Отчет по контрагентам списани

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 06/08/04 11:31

*/

define input parameter p-PostName as character no-undo .
define input parameter p-RADPost  as integer no-undo .
define input parameter p-SumsOnly   as logical no-undo .
define input parameter p-tog-obj    as logical no-undo .

 define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
 define variable vss-author      as character no-undo init "$Author: expertek $":U .
 define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
 define variable vss-workfile    as character no-undo init "$Workfile: r-ospis.p $":U .
 define variable vss-archive     as character no-undo init "$Archive: cus/r-ospis.p $":U .
 define variable vss-description as character no-undo init "Отчет по контрагентам списаниЯ".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ cmp/r-page1.i  }
{ gbl/paramls.i  }
{ rep/f-fdec.i   }
{ trg/factord.i  }
{ str/clcprtsl.i }
{ rep/rep-bt.i   }
 do
 on error undo, return error return-value
 :

define buffer     buf_obj-list for obj-list .
define variable   fact-order-1 as decimal no-undo .
define variable   fact-order-2 as decimal no-undo .

def SHARED temp-table g#post NO-UNDO
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    INDEX pi IS UNIQUE PRIMARY obj-type obj-code.


define temp-table temp-str no-undo
field artic        as character format "X(16)"
field prod-type    as character
field prod-code    as int
field gds-name     as char format "X(30)"
field gds-code     as integer
field qnty         as decimal
field sum-sale     as decimal
field sum-cost     as decimal
field sum-crsa     as decimal
field supp-code    as integer
field supp-type    as character
field obj-code     as integer
field obj-type     as character


index pi
      supp-code
      supp-type
      obj-code
      obj-type
      prod-type
      prod-code
      artic

index pi2
      obj-code
      obj-type
      supp-code
      supp-type
      prod-type
      prod-code
      artic

.


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

def buffer buf_clients for  ub.clients .
def buffer This_Object for  ub.clients .


define variable i as int no-undo.
define variable j as int no-undo.
define variable Counter1 as integer init 0  no-undo .

define variable LineBuf       as char    no-undo.
define variable Line       as char    no-undo.
define variable UndLine    as char    no-undo.

define variable     Lines_Counter as   int  init 0  no-undo.
define variable     Tmp_Counter   as   int  init 0  no-undo.

define variable  abbr              as  char no-undo.
define variable  pp-a              as  char no-undo.

 define variable var-qnty     as decimal no-undo .
 define variable var-sum1     as decimal no-undo .
 define variable var-sum2     as decimal no-undo .
 define variable var-sum3     as decimal no-undo .



{ rep/r-sym.i }



DEFINE FRAME plan-menu
    sym1                format "X(1)"              COLUMN-LABEL ":"  space(0)
    temp-str.artic      format "X(16)"             COLUMN-LABEL "Артикул"  space(0)
    sym2                format "X(1)"              COLUMN-LABEL ":"  space(0)
    temp-str.gds-name   format "X(30)"             COLUMN-LABEL "Наименование товара"  space(0)
    Sym3                format "X(1)"              COLUMN-LABEL ":"  space(0)
    temp-str.qnty       format "->>>>>>>>>>9.999"   COLUMN-LABEL "Количество"  space(0)
    Sym4                format "X(1)"              COLUMN-LABEL ":"  space(0)
    temp-str.sum-sale   format "->>>>>>>>>>>9.99"    COLUMN-LABEL "Сумма в ценах док."  space(0)
    Sym5                format "X(1)"              COLUMN-LABEL ":"  space(0)
    temp-str.sum-cost   format "->>>>>>>>>>>9.99"    COLUMN-LABEL "Сумма в учет.ценах"  space(0)
    Sym6                format "X(1)"              COLUMN-LABEL ":"  space(0)
    temp-str.sum-crsa   format "->>>>>>>>>>>9.99"    COLUMN-LABEL "Сумма в прод.ценах"  space(0)
    Sym7                format "X(1)"              COLUMN-LABEL ":"  space(0)

  HEADER
    string( "Лист " + string( PAGE-NUMBER(OutStream) , ">>>>9") ) AT 80 format "X(13)" SKIP
    Line format "X(123)" AT 1
    with width 136 down stream-io use-text nO-BOX .



  if session:set-wait-state("compiler") then.

  { cmp/open-out.i STREAM OutStream " " {&CS_PS} }
  define variable v-prn0 as character no-undo .

  assign
    Line    = fill("-", 123)
    UndLine = fill("_", 123)
    LineBuf = fill("_", 123)
  .

define variable v-is-base as logical no-undo .
{ gbl/rbisbase.i    v-is-base  }

if v-is-base = true then do:
    assign    PP-a = "баз.вал" .
end.
else do:
   assign     PP-a = "{&abbr_rub}".
end.

{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
{ rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

/*-----------------------------------------------------------------------------------------------------------------------*/
v-ind = 0    .

FORM with frame plan-menu .

 /* создаем временный файл */
    Output stream Macr_Excel  close .
    num#str# = 0 .
    run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name) .
    output stream macr_excel to value(v-file-name)   .
    v-ind = v-ind + 1.

  find ub.clients      where ub.clients.obj-type     = {&cmp}            and ub.clients.obj-code      = v-cntxt-host-code-obj no-lock .
  run PrintTitul in this-procedure .
  /* по строкам документа-------------------------------------------------------------------------------------------- */
  /* сначала заполняем таблицу */
  for each temp-str
      on error undo, return error :
      delete temp-str .
  end. /* for each */

  run make-tt in this-procedure .
  if p-tog-obj = true then
    run print-obj in this-procedure
        ( output var-qnty ,
          output var-sum1 ,
          output var-sum2 ,
          output var-sum3  ) .
    else
      run print-all in this-procedure
        ( output var-qnty ,
          output var-sum1 ,
          output var-sum2 ,
          output var-sum3  )  .

  run print-all-itog in this-procedure .
  /* ... Подвал. --- */
  run on-same-page in this-procedure (input 34) .
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
        ,input "1,2"
        ) .


  run end-proc in this-procedure .
  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  DisabledOptions = 0 .

  run gbl/prnfilen.w
    (input  ""
    ,input  DisabledOptions
    ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
    ,input  7
    ,output v-user-action
    ,output v-printed
    ) .

end.
/* *************************************************************************************************** */
procedure print-line :
  do on error undo, return error return-value :
  assign
     Lines_Counter = Lines_Counter + 1
    .

  if line-counter( OutStream ) + 2 > page-size( OutStream ) then page stream OutStream.

  if line-counter( OutStream ) < Tmp_Counter then
    assign
    .

  assign
    Tmp_Counter  = line-counter( OutStream )
  .

  if line-counter( OutStream ) + j > page-size( OutStream ) then  PAGE STREAM OutStream.

display STREAM OutStream
    sym1
    temp-str.artic
    sym2
    temp-str.gds-name
    Sym3
    temp-str.qnty
    Sym4
    temp-str.sum-sale
    Sym5
    temp-str.sum-cost
    Sym6
    temp-str.sum-crsa
    Sym7
    with FRAME  plan-menu    .
DOWN stream  OutStream 1 with FRAME plan-menu .

num#col# = 1.
num#str# = num#str# + 1.
run macr_excel_char In This-procedure ( temp-str.artic      , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char in this-procedure ( temp-str.gds-name   , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-str.qnty       , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-str.sum-sale , num#str# , num#col#   )   . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-str.sum-cost , num#str# , num#col#   )   . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( temp-str.sum-crsa , num#str# , num#col#   )   . assign    num#col# = num#col# + 1 .


  end.
end procedure. /* print-line */



procedure print-all-itog :
  /* Итоговые суммы */
  run print-itog  in this-procedure ("ИТОГО :" ,
                    var-qnty,
                    var-sum1,
                    var-sum2,
                    var-sum3   ) .
end procedure. /* print-all-itog */


procedure PrintTitul :
  do  on error undo, return error return-value  :
    /* ... конец создания заголовка. --- */
    define variable v-nn as integer   no-undo .
     PUT stream OutStream  string( v-cntxt-host-name-obj ) skip.
     PUT stream OutStream CaPS(ReportName) AT 10 format "x(100)"  skip .
     PUT stream OutStream str1 AT 1 format "x(130)"  skip(2) .
     PUT stream OutStream str2 AT 1 format "x(130)"  skip .
     v-nn = NUM-ENTRIES(str3,chr(10)).
     Repeat i = 1 to v-nn :
       PUT stream OutStream  Entry(i,str3,chr(10))  AT 1 format "X(130)" skip .
     End.
     v-nn = NUM-ENTRIES(str4,chr(10)).
     Repeat i = 1 to v-nn :
       PUT stream OutStream  Entry(i,str4,chr(10))  AT 1 format "X(130)" skip .
     End.
     v-nn = NUM-ENTRIES(ReportHeader,chr(10)).
     Repeat i = 1 to v-nn :
       PUT stream OutStream  Entry(i,ReportHeader,chr(10))  AT 1 format "X(130)" skip .
     End.

  num#str# = 1.
  num#col# = 1.

      run macr_excel_char_with_format in this-procedure ( ReportNAme , num#str# , num#col#  ).
      run macr_cell_format in this-procedure
          ( 12    ,     /* p-size */
            true  ,     /*p-bold   */
            false ,     /*p-italic */
            ?     ,     /*p-color  */
            num#str# ,  /*p-row    */
            num#col# ,  /*p-col    */
            ? ,         /*p-row-2  */
            ?         ) . /*p-col-2 */
define variable l-ii  as integer no-undo .
define variable l-jj  as integer no-undo .
define variable l-len as integer no-undo .
define variable l-m   as integer no-undo .
define variable v-n as integer   no-undo .

&scop var-print-n v-n = num-entries( ~{&var-str-n} , "~{&new-line}"  )   .   do l-ii = 1 to v-n :  ~
      l-len = length (entry( l-ii , ~{&var-str-n}  , "~{&new-line}")) .                 ~
      l-m = integer( l-len / 120 ) + 1 .                                                ~
      do l-jj = 1 to  l-m  :                                                            ~
          num#str# = num#str# + 1 .                                                     ~
          run macr_excel_char_with_format in this-procedure (    ~
              substring(entry( l-ii , ~{&var-str-n}  , "~{&new-line}") , (( 120 * l-jj ) - 119 )  , 120 )  , num#str# , num#col# ) .~
      end.                                                                                                       ~
  end.

&scop var-str-n  str1
{&var-print-n }
&scop var-str-n  str2
{&var-print-n }
&scop var-str-n  str3
{&var-print-n }
&scop var-str-n  str4
{&var-print-n }
&scop var-str-n  reportheader
{&var-print-n }


  num#str# = num#str# + 1.
  num#col# = 1.
  run macr_excel_char_with_format in this-procedure (  "  Цены указаны в {&abbr_rub_allshift}"     , num#str#  , num#col#  ) .
/*Печать шапки */
   run proc-print-header in this-procedure .


  end.
end procedure. /* PrintTitul */


procedure PrintPodval :
  do on error undo, return error return-value  :
    PUT stream OutStream  Line format "X(132)" at 1 skip.
    /* ... конец создания Подвал. --- */
  end.
end procedure. /* PrintPodval */



PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( OutStream ) then return .
  if line-counter( OutStream ) + p-line-number > page-size( OutStream ) then  page stream OutStream .
end procedure. /* on-same-page */


procedure make-tt :
  do
  on error undo, return error return-value
  :
 define buffer buf_trn-doc for  ub.trn-doc.
 define buffer buf_doc-line for ub.doc-line.
 define buffer buf_goods for ub.goods.

 for each obj-list
     on error undo, return error :
     for each buf_trn-doc no-lock where
         buf_trn-doc.obj-type = obj-list.obj-type  and
         buf_trn-doc.obj-code = obj-list.obj-code  and
         buf_trn-doc.internal = false  and
         buf_trn-doc.doc-type = {&write-off}  and
         buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} and
         buf_trn-doc.status_ = {&fact} and
         buf_trn-doc.fact-date >= x-date-start and
         buf_trn-doc.fact-date <= x-date-end
         on error undo, return error :
         if p-RADPost  = 2 then do:
            /* выборка КОНТРАГЕНТОВ СПИСАНИЯ */
            find first g#post where g#post.obj-type = buf_trn-doc.cli-type and
                                    g#post.obj-code = buf_trn-doc.cli-code no-error .
             if not available g#post then next.
         end.

           for each buf_doc-line no-lock where
                    buf_doc-line.doc-code = buf_trn-doc.doc-code
               on error undo, return error :

               if x-SelectGood <> {&g-all} then do:
                  /* выборка товаров */
                  find first gds-list where
                              gds-list.artic      = buf_doc-line.artic       and
                              gds-list.prod-type  = buf_doc-line.prod-type   and
                              gds-list.prod-code  = buf_doc-line.prod-code   no-error .
                  if not available gds-list then next.
               end.


                find first buf_goods no-lock where
                  buf_goods.artic              = buf_doc-line.artic       and
                  buf_goods.prod-type          = buf_doc-line.prod-type   and
                  buf_goods.prod-code          = buf_doc-line.prod-code   no-error .
                run clcprtsl_calc-line  in this-procedure (recid (buf_doc-line)) .
                find first tt-allsum-line where tt-allsum-line.sum-type = {&sum-general} no-error .
                if error-status :error then do:
                    message vss-workfile vss-revision vss-description skip
                          "Ошибка tt-allsum-line " skip
                            buf_doc-line.artic
                            skip
                            error-status :get-message(1) skip
                            return-value skip
                            view-as alert-box error
                    .
                    next.
                end.
                find first temp-str where
                  temp-str.artic              = buf_doc-line.artic       and
                  temp-str.prod-type          = buf_doc-line.prod-type   and
                  temp-str.prod-code          = buf_doc-line.prod-code   and
                  temp-str.supp-code          =  buf_trn-doc.cli-code    and
                  temp-str.supp-type          =  buf_trn-doc.cli-type    and
                  temp-str.obj-code           =  buf_trn-doc.obj-code    and
                  temp-str.obj-type           =  buf_trn-doc.obj-type    no-error .
                if not available temp-str then do:
                    create temp-str.
                    assign
                      temp-str.artic              = buf_doc-line.artic
                      temp-str.prod-type          = buf_doc-line.prod-type
                      temp-str.prod-code          = buf_doc-line.prod-code
                      temp-str.gds-name           = buf_goods.gds-name
                      temp-str.gds-code           = buf_goods.gds-code
                      temp-str.qnty               =  tt-allsum-line.fact-qnty
                      temp-str.sum-sale           =  tt-allsum-line.sum-dsc-rubl-doc
                      temp-str.sum-cost           =  tt-allsum-line.sum-dsc-rubl-acc
                      temp-str.sum-crsa           =  tt-allsum-line.sum-dsc-rubl-cur
                      temp-str.supp-code          =  buf_trn-doc.cli-code
                      temp-str.supp-type          =  buf_trn-doc.cli-type
                      temp-str.obj-code           =  buf_trn-doc.obj-code
                      temp-str.obj-type           =  buf_trn-doc.obj-type
                    .
                  end.
                  else do:
                    assign
                      temp-str.qnty               =  temp-str.qnty     +  tt-allsum-line.fact-qnty
                      temp-str.sum-sale           =  temp-str.sum-sale +  tt-allsum-line.sum-dsc-rubl-doc
                      temp-str.sum-cost           =  temp-str.sum-cost +  tt-allsum-line.sum-dsc-rubl-acc
                      temp-str.sum-crsa           =  temp-str.sum-crsa +  tt-allsum-line.sum-dsc-rubl-cur
                    .

                  end.

           end. /* for each */



     end. /* for each */
 end. /* for each */
  end. /* do */
 end procedure. /* make-tt */


procedure print-obj :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
 define output parameter v-qnty-a as decimal no-undo .
 define output parameter v-sum1-a as decimal no-undo .
 define output parameter v-sum2-a as decimal no-undo .
 define output parameter v-sum3-a as decimal no-undo .

 define variable v-qnty     as decimal no-undo .
 define variable v-sum1     as decimal no-undo .
 define variable v-sum2     as decimal no-undo .
 define variable v-sum3     as decimal no-undo .

 define variable v-qnty-o as decimal no-undo .
 define variable v-sum1-o as decimal no-undo .
 define variable v-sum2-o as decimal no-undo .
 define variable v-sum3-o as decimal no-undo .


 assign
    v-qnty    = 0
    v-sum1    = 0
    v-sum2    = 0
    v-sum3    = 0

    v-qnty-o  = 0
    v-sum1-o  = 0
    v-sum2-o  = 0
    v-sum3-o  = 0

    v-qnty-a  = 0
    v-sum1-a  = 0
    v-sum2-a  = 0
    v-sum3-a  = 0
 .


    for each temp-str break by temp-str.obj-type  by temp-str.obj-code
                            by temp-str.supp-type by temp-str.supp-code
    :
        if first-of (temp-str.obj-code) then do:
           find first obj-list where
                               obj-list.obj-type = temp-str.obj-type  and
                               obj-list.obj-code = temp-str.obj-code .
           run print-name in this-procedure ("ОБЪЕКТ:" , obj-list.obj-name ) .
           PUT stream OutStream  Line format "X(132)" at 1 skip.
            assign
                v-qnty    = 0
                v-sum1    = 0
                v-sum2    = 0
                v-sum3    = 0

                v-qnty-o  = 0
                v-sum1-o  = 0
                v-sum2-o  = 0
                v-sum3-o  = 0
            .
        end.

              if first-of (temp-str.supp-code) then do:
                find first ub.clients where
                                    ub.clients.obj-type = temp-str.supp-type  and
                                    ub.clients.obj-code = temp-str.supp-code .
                if p-SumsOnly = false then
                   run print-name in this-procedure  ("КОНТРАГЕНТ" , "СПИСАНИЯ: " + ub.clients.obj-name ) .
                assign
                    v-qnty    = 0
                    v-sum1    = 0
                    v-sum2    = 0
                    v-sum3    = 0
                .
              end.

              assign
                  v-qnty    = v-qnty   +  temp-str.qnty
                  v-sum1    = v-sum1   +  temp-str.sum-sale
                  v-sum2    = v-sum2   +  temp-str.sum-cost
                  v-sum3    = v-sum3   +  temp-str.sum-crsa

                  v-qnty-o  = v-qnty-o +  temp-str.qnty
                  v-sum1-o  = v-sum1-o +  temp-str.sum-sale
                  v-sum2-o  = v-sum2-o +  temp-str.sum-cost
                  v-sum3-o  = v-sum3-o +  temp-str.sum-crsa

                  v-qnty-a  = v-qnty-a +  temp-str.qnty
                  v-sum1-a  = v-sum1-a +  temp-str.sum-sale
                  v-sum2-a  = v-sum2-a +  temp-str.sum-cost
                  v-sum3-a  = v-sum3-a +  temp-str.sum-crsa
              .


              if p-SumsOnly = false then run print-line in this-procedure .


              if last-of (temp-str.supp-code) then do:
                run print-itog in this-procedure ("ИТОГО ПО КОНТРАГЕНТУ: " + ub.clients.obj-name ,
                v-qnty,
                v-sum1,
                v-sum2,
                v-sum3  ) .
              end.

        if last-of (temp-str.obj-code) then do:
           run print-itog in this-procedure ("ИТОГО ПО ОБЪЕКТУ: " + obj-list.obj-name ,
                v-qnty-o,
                v-sum1-o,
                v-sum2-o,
                v-sum3-o  ) .
           PUT stream OutStream  Line format "X(132)" at 1 skip.
        end.
    end.

 end. /* do */
end procedure. /* print-obj */




procedure print-all :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
 define output parameter v-qnty-a as decimal no-undo .
 define output parameter v-sum1-a as decimal no-undo .
 define output parameter v-sum2-a as decimal no-undo .
 define output parameter v-sum3-a as decimal no-undo .

 define variable v-qnty     as decimal no-undo .
 define variable v-sum1     as decimal no-undo .
 define variable v-sum2     as decimal no-undo .
 define variable v-sum3     as decimal no-undo .



 assign
    v-qnty    = 0
    v-sum1    = 0
    v-sum2    = 0
    v-sum3    = 0
    v-qnty-a  = 0
    v-sum1-a  = 0
    v-sum2-a  = 0
    v-sum3-a  = 0
 .


    for each temp-str break by temp-str.supp-type by temp-str.supp-code :
        if first-of (temp-str.supp-code) then do:
           find first ub.clients where
                               ub.clients.obj-type = temp-str.supp-type  and
                               ub.clients.obj-code = temp-str.supp-code .
           if p-SumsOnly = false then
              run print-name in this-procedure ("КОНТРАГЕНТ" , "СПИСАНИЯ: " + ub.clients.obj-name ) .
            assign
                v-qnty    = 0
                v-sum1    = 0
                v-sum2    = 0
                v-sum3    = 0
            .

        end.

              assign
                  v-qnty    = v-qnty   +  temp-str.qnty
                  v-sum1    = v-sum1   +  temp-str.sum-sale
                  v-sum2    = v-sum2   +  temp-str.sum-cost
                  v-sum3    = v-sum3   +  temp-str.sum-crsa

                  v-qnty-a  = v-qnty-a +  temp-str.qnty
                  v-sum1-a  = v-sum1-a +  temp-str.sum-sale
                  v-sum2-a  = v-sum2-a +  temp-str.sum-cost
                  v-sum3-a  = v-sum3-a +  temp-str.sum-crsa
              .

        if p-SumsOnly = false then
           run print-line in this-procedure .

        if last-of (temp-str.supp-code) then do:
           run print-itog  in this-procedure ("ИТОГО ПО КОНТРАГЕНТУ: " + ub.clients.obj-name   ,
                            v-qnty ,
                            v-sum1 ,
                            v-sum2 ,
                            v-sum3  ) .
        end.
    end.


 end. /* do */
end procedure. /* print-all */


procedure print-name :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 with frame plan-menu
 :
define input parameter p-name as character no-undo .
define input parameter p-name1 as character no-undo .

display STREAM OutStream
    sym1
    p-name  @  temp-str.artic
    p-name1 @  temp-str.gds-name
    Sym7
    with FRAME  plan-menu    .
DOWN stream  OutStream 1 with FRAME plan-menu .




  num#str# = num#str# + 1.
  num#col# = 1.
  run macr_excel_char_with_format in this-procedure (  p-name + " " + p-name1  , num#str#  , num#col#  ) .
      run macr_cell_format in this-procedure
          ( 12    ,     /* p-size */
            true  ,     /*p-bold   */
            false ,     /*p-italic */
            ?     ,     /*p-color  */
            num#str# ,  /*p-row    */
            num#col# ,  /*p-col    */
            ? ,         /*p-row-2  */
            ?         ) . /*p-col-2 */



 end. /* do */
end procedure. /* print-name */



procedure print-itog :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 with frame plan-menu
 :
define input parameter p-name as character no-undo .
define input parameter p-qnty     as decimal no-undo .
define input parameter p-sum-sale as decimal no-undo .
define input parameter p-sum-cost as decimal no-undo .
define input parameter p-sum-crsa as decimal no-undo .


display STREAM OutStream
    sym1
    substring(p-name,1,16)  @ temp-str.artic
    substring(p-name,17,1)  @ Sym2
    substring(p-name,18,30) @ temp-str.gds-name
    Sym3
    p-qnty      @ temp-str.qnty
    Sym4
    p-sum-sale  @ temp-str.sum-sale
    Sym5
    p-sum-cost  @ temp-str.sum-cost
    Sym6
    p-sum-crsa  @ temp-str.sum-crsa
    Sym7
    with FRAME  plan-menu    .
DOWN stream  OutStream 1 with FRAME plan-menu .


  num#str# = num#str# + 1.
  num#col# = 1.
run macr_excel_char_with_format in this-procedure (  p-name  , num#str#  , num#col#  ) . assign    num#col# = num#col# + 2 .
run macr_excel_dec in this-procedure ( p-qnty     , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( p-sum-sale , num#str# , num#col#   )   . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( p-sum-cost , num#str# , num#col#   )   . assign    num#col# = num#col# + 1 .
run macr_excel_dec in this-procedure ( p-sum-crsa , num#str# , num#col#   )   . assign    num#col# = num#col# + 1 .

      run macr_cell_format in this-procedure
          ( 12    ,     /* p-size */
            true  ,     /*p-bold   */
            false ,     /*p-italic */
            34     ,     /*p-color  */
            num#str# ,  /*p-row    */
            1 ,  /*p-col    */
            ? ,         /*p-row-2  */
            num#col#   ) . /*p-col-2 */


 end. /* do */
end procedure. /* print-itog */


{ rep/r-libmcr.i macr_excel         }