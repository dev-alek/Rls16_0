block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-flor3.p $
$Archive: rep/r-flor3.p $

Отчет по оплате заказов по нетоварным позициям

Автор: Чернова Светлана Александровна
Дата создания: 01/21/05
Author: Svetlana Chernova
Creation date: 01/21/05


*/

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-flor3.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-flor3.p $":U .
define variable vss-description as character no-undo initial "Отчет по оплате заказов по нетоварным позициям":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ cmp/r-page1.i  }
{ cmp/breakstr.i }
{ rep/r-cliprp.i def }
{ gbl/paramls.i  }
{ rep/f-fdec.i   }
{ str/lib-trn.i  }
{ str/trdcalib.i }
{ rep/rep-bt.i   }

 do
 on error undo, return error return-value
 :

DEFINE temp-table temp-str no-undo
  field   doc-numn           as char
  field   date-fact         as  date
  field   cli-code          as  char
  field   cli-name          as character
  field   status_           as char
  field   sum1              as decimal
  field   sum2              as decimal
  field   sum3              as decimal
  field   sum4             as decimal
  field   sum5             as decimal
  field   sum6             as decimal
.


define stream  OutStream  .
define stream  macr_excel .

define variable   ssum4             as decimal  no-undo .
define variable   ssum5             as decimal  no-undo .
define variable   ssum6             as decimal  no-undo .

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

define variable  v-ord_date   as character no-undo .

define buffer buf_clients for  ub.clients .
define buffer This_Object for  ub.clients .

define variable sum  as decimal   no-undo .

define variable num-ln as integer   no-undo .

define variable gds-str as character no-undo.
define variable gds-str1 as character no-undo.
define variable gds-str2 as character no-undo.
define variable i as int no-undo.
define variable j as int no-undo.
define variable Counter1 as integer init 0  no-undo .

define variable LineBuf    as character    no-undo.
define variable Line       as character    no-undo.
define variable UndLine    as character    no-undo.

define variable     Lines_Counter as   int  init 0  no-undo.
define variable     Tmp_Counter   as   int  init 0  no-undo.

define variable     tdoc-date     like ub.fbr-pln.doc-date no-undo.
define variable     tdoc-code     like ub.fbr-pln.doc-code no-undo.

define variable  abbr              as  character no-undo.
define variable  pp                as  character no-undo.


define variable sym1 as character   init ":!:"   no-undo.
define variable sym2 as character   init ":!:"   no-undo.
define variable sym3 as character   init ":!:"   no-undo.
define variable sym4 as character   init ":!:"   no-undo.
define variable sym5 as character   init ":!:"   no-undo.
define variable sym6 as character   init ":!:"   no-undo.
define variable sym7 as character   init ":!:"   no-undo.
define variable sym8 as character   init ":!:"   no-undo.
define variable sym9 as character   init ":!:"   no-undo.
define variable sym10 as character  init ":!:"   no-undo.


DEFINE FRAME zakaz
    temp-str.doc-numn  COLUMN-LABEL "Номер!заказа":C10 format "X(10)" space(0)
    sym1 column-label ":!:"  format "X(1)" space(0)
    temp-str.date-fact COLUMN-LABEL "Дата!выполнения":C11 format "99/99/9999" space(0)
    sym2 column-label ":!:"  format "X(1)" space(0)
    temp-str.cli-code  COLUMN-LABEL "Код!заказчика":C9 format "X(9)" space(0)
    sym3 column-label ":!:"  format "X(1)" space(0)
    temp-str.cli-name  COLUMN-LABEL "Заказчик":C20 format "X(20)" space(0)
    sym4 column-label ":!:"  format "X(1)" space(0)
    temp-str.status_   COLUMN-LABEL "Статус!заказа":C10     format "X(10)" space(0)
    sym5 column-label ":!:"  format "X(1)" space(0)
    temp-str.sum1      COLUMN-LABEL "Сумма !в розн.ценах":C13 format "->>>>>>>>9.99" space(0)
    sym6 column-label ":!:"  format "X(1)" space(0)
    temp-str.sum2      COLUMN-LABEL "Сумма скидки!/наценки":C13 format "->>>>>>>>9.99" space(0)
    sym7 column-label ":!:"  format "X(1)" space(0)
    temp-str.sum3      COLUMN-LABEL "Сумма!доставки":C13 format "->>>>>>>>9.99" space(0)
    sym8 column-label ":!:"  format "X(1)" space(0)
    temp-str.sum4      COLUMN-LABEL "Сумма!к оплате":C13 format "->>>>>>>>9.99" space(0)
    sym9 column-label ":!:"  format "X(1)" space(0)
    temp-str.sum5      COLUMN-LABEL "Сумма!предоплаты":C13 format "->>>>>>>>9.99" space(0)
    sym10 column-label ":!:"  format "X(1)" space(0)
    temp-str.sum6      COLUMN-LABEL "Сумма!доплаты":C13 format "->>>>>>>>9.99" space(0)
    HEADER
    string( "Лист " + string( PAGE-NUMBER(OutStream) , ">>>>9") ) AT 70 format "X(13)" SKIP
    Line format "X(148)" AT 1
    with width {&DOS_CW_2} down stream-io use-text NO-BOX.

  if session:set-wait-state("compiler") then.

  { cmp/open-out.i STREAM OutStream " " {&LS_PS_A4}  }
  define variable v-prn0 as character no-undo .

  assign
    Line    = fill("-", 230)
    UndLine = fill("_", 230)
    LineBuf = fill("_", 240)
  .

  IF var-report-r-b = "rubl" THEN Assign PP = "Цены {&abbr_rub}.".
                       Else Assign PP = "Цены  баз.вал." .
{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
{ rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */
/*-----------------------------------------------------------------------------------------------------------------------*/
v-ind = 0    .
FORM with frame zakaz .
for each obj-list :
 /* создаем временный файл */
    Output stream Macr_Excel  close .
    num#str# = 0 .
    run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name) .
    output stream macr_excel to value(v-file-name)   .
    v-ind = v-ind + 1.


  FIND This_Object  WHERE This_Object.obj-type = obj-list.obj-type AND This_Object.obj-code = obj-list.obj-code  NO-LOCK.
  FIND ub.clients      WHERE ub.clients.obj-type     = {&cmp}           AND ub.clients.obj-code     = v-cntxt-host-code-obj NO-LOCK.

  run PrintTitul in this-procedure .
  /* по строкам документа-------------------------------------------------------------------------------------------- */
  /* сначала заполняем таблицу */
  run make-tt in this-procedure ( obj-list.obj-type , obj-list.obj-code)  .
  /* теперь печать с сортировками */
      for each temp-str no-lock :
        run print-line in this-procedure .
      end.

  run print-all-itog in this-procedure .

  /* ... Подвал. --- */
  run on-same-page in this-procedure (input 1) .

  run PrintPodval in this-procedure .
  page stream OutStream .
  run paramls-write in this-procedure
    (input "file"
    ,input string(v-ind) + obj-list.obj-name
    ,input v-file-name
    ) .
end. /* obj-list */

HIDE STREAM OutStream FRAME zakaz.
HIDE stream OutStream FRAME BottomFrame .
HIDE stream OutStream FRAME BottomFrame2 .
output stream OutStream CLOSE .
Output stream Macr_Excel  close .

{ rep/repfrm.i off } /* Показать окно информации о текущем процессе */

    run paramls-write in this-procedure
        (input "charcol"
        ,input ""
        ,input "1,4,5"
        ) .

  run end-proc in this-procedure .

  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  DisabledOptions = 8 .

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
      ssum4 = ssum4 + temp-str.sum4
      ssum5 = ssum5 + temp-str.sum5
      ssum6 = ssum6 + temp-str.sum6
    .

  if line-counter( OutStream ) + 2 > page-size( OutStream ) then page stream OutStream.

  if line-counter( OutStream ) < Tmp_Counter then
    assign
    .

  assign
    Tmp_Counter  = line-counter( OutStream )
    num-ln = num-ln + 1
  .
  if line-counter( OutStream ) + j > page-size( OutStream ) then  PAGE STREAM OutStream.

num#str# = num#str# + 1.
num#col# = 1.

    run macr_excel_char ( temp-str.doc-numn  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( temp-str.date-fact , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( temp-str.cli-code  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( temp-str.cli-name  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( temp-str.status_   , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( temp-str.sum1      , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( temp-str.sum2      , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( temp-str.sum3      , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( temp-str.sum4      , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( temp-str.sum5      , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char ( temp-str.sum6      , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .


  display stream OutStream
    temp-str.doc-numn
    temp-str.date-fact
    temp-str.cli-code
    temp-str.cli-name
    temp-str.status_
    temp-str.sum1
    temp-str.sum2
    temp-str.sum3
    temp-str.sum4
    temp-str.sum5
    temp-str.sum6
    sym1 sym2 sym3 sym4 sym5  sym6
    sym7 sym8 sym9 sym10
    with FRAME zakaz.
    DOWN stream OutStream 1 with FRAME zakaz.

  end.
end procedure. /* print-line */


procedure print-grp-itog :
  do on error undo, return error return-value :
  end.
end procedure. /* print-grp-itog */




procedure print-all-itog :
  underline stream OutStream
    temp-str.doc-numn
    temp-str.date-fact
    temp-str.cli-code
    temp-str.cli-name
    temp-str.status_
    temp-str.sum1
    temp-str.sum2
    temp-str.sum3
    temp-str.sum4
    temp-str.sum5
    temp-str.sum6
    sym1 sym2 sym3 sym4 sym5  sym6
    sym7 sym8 sym9 sym10

    with FRAME zakaz.
  DOWN stream OutStream 1 with FRAME zakaz.

  display stream OutStream
   "ИТОГО:" @ temp-str.status_
    ssum4 @  temp-str.sum4
    ssum5 @  temp-str.sum5
    ssum6 @  temp-str.sum6
    sym4 sym5  sym6
    sym7 sym8 sym9 sym10
    with FRAME zakaz.
    DOWN stream OutStream 1 with FRAME zakaz.

  /* Итоговые суммы */
end procedure. /* print-all-itog */


procedure PrintTitul :
  do  on error undo, return error return-value  :
  define variable cc as integer no-undo .
  define variable tt as integer no-undo .
    /* ---------------- Создание заголовка :--------------------------------------------------------------------------- */
    { rep/r-cliprp.i ub. }
      PUT STREAM OutStream
        space(5) cur-time-date() format "X(20)"
        string( "ОТЧЕТ ПО ОПЛАТЕ ЗАКАЗОВ НА ИЗГОТОВЛЕНИЕ по " ) format  "X(100)"  skip
        space(5) string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ")" ) format "X(160)"   skip
        space(5) "За период с "  x-date-start " по "  x-date-end   skip .
      .

    num#str# = num#str# + 1.
    num#col# = 2.
    cc = num#str# .
    run macr_excel_char ( "ОТЧЕТ ПО ОПЛАТЕ ЗАКАЗОВ НА ИЗГОТОВЛЕНИЕ по"    , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    num#col# = 2.
    run macr_excel_char ( string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ") За период с " + string ( x-date-start, "99/99/9999" ) + " по " + string(x-date-end , "99/99/9999" ) )   , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    num#col# = 2.
    run macr_excel_char ( cur-time-date()   , num#str# , num#col#   ) .
    run macr_cell_format
    ( 20    ,      /* p-size     */
      true  ,      /* p-bold     */
      false  ,      /* p-italic   */
      ?    ,      /* p-color-bg */
      cc ,      /* p-row      */
      2 ,      /* p-col      */
      num#str# ,   /* p-row-2    */
      2 ) . /* p-col-2    */

    num#str# = num#str# + 1.
    num#col# = 1.
    tt = num#str#  .

    num#col# = 1. run macr_excel_char ("Номер заказа"         , num#str# , num#col#) . run macr_cell_size ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 2. run macr_excel_char ("Дата выполнения"      , num#str# , num#col#) . run macr_cell_size ( 11 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 3. run macr_excel_char ("Код заказчика"        , num#str# , num#col#) . run macr_cell_size ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 4. run macr_excel_char ("Заказчик"             , num#str# , num#col#) . run macr_cell_size ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 5. run macr_excel_char ("Статус заказа"        , num#str# , num#col#) . run macr_cell_size ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 6. run macr_excel_char ("Сумма в розн.ценах"   , num#str# , num#col#) . run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 7. run macr_excel_char ("Сумма скидки /наценки", num#str# , num#col#) . run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 8. run macr_excel_char ("Сумма доставки"       , num#str# , num#col#) . run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 9. run macr_excel_char ("Сумма к оплате"       , num#str# , num#col#) . run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
   num#col# = 10. run macr_excel_char ("Сумма предоплаты"     , num#str# , num#col#) . run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
   num#col# = 11. run macr_excel_char ("Сумма доплаты"        , num#str# , num#col#) . run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .


    run macr_cell_format
    ( 12    ,      /* p-size     */
      true  ,      /* p-bold     */
      false  ,      /* p-italic   */
      ?    ,      /* p-color-bg */
      num#str# ,      /* p-row      */
      1 ,      /* p-col      */
      num#str# ,   /* p-row-2    */
      11 ) . /* p-col-2    */

     put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , tt , 1 , num#str# ,  num#col# ) + {&new-line}  +
       'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line} +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + {&new-line}
       .


    /* ... конец создания заголовка. --- */
  end.
end procedure. /* PrintTitul */


procedure PrintPodval :
  do on error undo, return error return-value  :
  PUT  STREAM OutStream " "
  skip skip skip
" Руководитель _______________________ " skip
      .
    num#str# = num#str# + 3.
    num#col# = 2.
    run macr_excel_char ( "Руководитель"   , num#str# , num#col#   ) .

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
define input  parameter v-obj-type as character no-undo .
define input  parameter v-obj-code as integer   no-undo .

define variable  v-befpay     as character no-undo .
define variable  v-deliv      as character no-undo .
define variable  v-sumwrk     as character no-undo .
define variable  v-type       as character no-undo .
define variable  v-postpay    as character no-undo .
define variable v-itogo as character no-undo .
define variable v-sum-opl as decimal   no-undo init 0 .
define variable v-tot-sale as decimal   no-undo .
define variable v-status_ as character no-undo .
define variable v-prc as decimal   no-undo .
define variable v-pr as character no-undo .
define variable v-postpay-date as character no-undo .
define variable v-before-date  as character no-undo .
define variable v-postpay-date0 as character no-undo .
define variable v-before-date0  as character no-undo .


 assign
  ssum4 = 0
  ssum5 = 0
  ssum6 = 0
 .
for each temp-str :
    delete temp-str.
end.

define buffer ready_trn-doc for ub.trn-doc.
define buffer nakl_trn-doc for ub.trn-doc.
define variable v-nabor  as logical   no-undo .
define buffer buf_doc-attr for ub.doc-attr.


for each ready_trn-doc no-lock where
                      ready_trn-doc.obj-type     = v-obj-type and
                      ready_trn-doc.obj-code     = v-obj-code and
                      ready_trn-doc.out-code     = ? and

                      ( ready_trn-doc.status_ = {&ready} or
                      ready_trn-doc.status_ = {&rejected} or
                      ready_trn-doc.status_ = {&inquiry} )
                      and
                      ready_trn-doc.doc-type = {&expense} and
                      ready_trn-doc.internal = false   and
                      ready_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} and
                      ((
                        ready_trn-doc.doc-date >= x-date-start and
                        ready_trn-doc.doc-date <= x-date-end  )
                      or  (
                        ready_trn-doc.flora-pay-date >= x-date-start and
                        ready_trn-doc.flora-pay-date <= x-date-end
                      )) :

                      /* */
  if ready_trn-doc.status_ = {&inquiry} then do:
     { str/resvinqv.i ready_trn-doc.doc-code v-nabor }
     if v-nabor = true  then  next.
  end.


&scop attr-temp-full-code ~{&v-code~} = "" . ~
run trn-doc-attr_value in this-procedure (  input ready_trn-doc.doc-code  ~
                                         ,  input ~{&attr-code~}    ~
                                         , output ~{&v-code~}    ~
                                         , output v-type ).
&scop attr-code {&trdcattr-frsrv-date}
&scop v-code           v-ord_date
{&attr-temp-full-code}


&scop attr-code {&trdcattr-befpay}
&scop v-code           v-befpay
{&attr-temp-full-code}

&scop attr-code {&trdcattr-deliv}
&scop v-code           v-deliv
{&attr-temp-full-code}
&scop attr-code {&trdcattr-sumwrk}
&scop v-code           &scop v-code v-pr
{&attr-temp-full-code}

&scop attr-code {&trdcattr-postdchek}
&scop v-code v-postpay-date0
{&attr-temp-full-code}

&scop attr-code {&trdcattr-dchek}
&scop v-code v-before-date0
{&attr-temp-full-code}


define buffer cl_clients for  ub.clients.
find cl_clients no-lock  where cl_clients.obj-type = ready_trn-doc.cli-type
                           and cl_clients.obj-code = ready_trn-doc.cli-code no-error .

v-tot-sale = 0 .
v-sum-opl = 0 .
v-postpay = "" .
v-itogo = "".
v-before-date = "" .
if ready_trn-doc.status_ = {&rejected}  then  v-status_ = ready_trn-doc.status_ .
if ready_trn-doc.status_ = {&inquiry} and ready_trn-doc.flag_ = false  then  v-status_ = "Новый" .
if ready_trn-doc.status_ = {&inquiry} and ready_trn-doc.flag_ = true   then  v-status_ = "Создан" .
find first  nakl_trn-doc no-lock where  nakl_trn-doc.out-code = ready_trn-doc.doc-code no-error .
if available  nakl_trn-doc then do:
    &scop attr-temp-full-code ~{&v-code~} = "" . ~
    run trn-doc-attr_value in this-procedure (  input nakl_trn-doc.doc-code  ~
                                             ,  input ~{&attr-code~}    ~
                                             , output ~{&v-code~}    ~
                                             , output v-type ).

    &scop attr-code {&trdcattr-postdchek}
    &scop v-code v-postpay-date
    {&attr-temp-full-code}

    &scop attr-code {&trdcattr-dchek}
    &scop v-code v-before-date
    {&attr-temp-full-code}

    &scop attr-code {&trdcattr-postpay}
    &scop v-code v-postpay
    {&attr-temp-full-code}

    &scop attr-code {&trdcattr-discnt-stop}
    &scop v-code v-itogo
    {&attr-temp-full-code}

    &scop attr-code {&trdcattr-sumwrk}
    &scop v-code           &scop v-code v-pr
    {&attr-temp-full-code}


    v-sum-opl = decimal (v-itogo) no-error .
    v-tot-sale = ((v-sum-opl  - decimal ( v-deliv )) + ( nakl_trn-doc.discnt-pc * (v-sum-opl  - decimal ( v-deliv )) / (100 - nakl_trn-doc.discnt-pc ))) * 100 / ( 100 + v-prc ) .

    if v-sum-opl = 0 then v-sum-opl =  v-tot-sale - nakl_trn-doc.discnt-rubl.
    if v-sum-opl =  ? then v-sum-opl =0 .
    case nakl_trn-doc.Status_ :
      when {&wayb}   then do:
        if nakl_trn-doc.flag_ = false  then  v-status_ = "На исполнении" .
                                       else  v-status_ = "Готов" .
      end.
      when {&permitted}  then do:
          v-status_ = "Выполнен-" .
      end.
      when {&fact}  then do:
          v-status_ = "Выполнен+" .
      end.

    end case.
end.
if  v-before-date =  "" then v-before-date = v-before-date0.
if  v-before-date <> "" then do:
if not ( date(v-before-date) >= x-date-start and
         date(v-before-date) <= x-date-end ) then v-befpay = "" .
end.
else do:
  v-befpay = "" .
end.

if  v-postpay-date = "" then v-postpay-date = v-postpay-date0 .
if  v-postpay-date <> "" then do:
if not ( date(v-postpay-date) >= x-date-start and
         date(v-postpay-date) <= x-date-end ) then v-postpay = "" .
end.
else do:
  v-postpay = "" .
end.


create temp-str.
assign
  temp-str.doc-numn   = ready_trn-doc.doc-code
  temp-str.date-fact  = date(v-ord_date)
  temp-str.cli-code   = string(ready_trn-doc.cli-code)
  temp-str.cli-name   = cl_clients.obj-name
  temp-str.status_    = v-status_
  temp-str.sum1       = v-tot-sale
  temp-str.sum3       = decimal ( v-deliv )
  temp-str.sum4       = v-sum-opl
  temp-str.sum2       = if temp-str.sum1 = 0 then 0 else (temp-str.sum4 - ( temp-str.sum1 + temp-str.sum3 ))
  temp-str.sum5       = decimal ( v-befpay  )
  temp-str.sum6       = decimal ( v-postpay )
  no-error
  .



end.


  end. /* do */
 end procedure. /* make-tt */


    { rep/r-libmcr.i macr_excel         }

procedure trn-doc-attr_value :
  define  input parameter p-doc-code like ub.doc-attr.doc-code   no-undo.
  define  input parameter p-code     like ub.doc-attr.attr-code  no-undo.
  define output parameter p-value    like ub.doc-attr.attr-value no-undo.
  define output parameter p-type     as   character              no-undo.

  do on error undo, return error return-value :
    { str/tdat-val.i p-doc-code
                 p-code
                 p-value
                 p-type     no-error }
  end. /* on error */
end procedure. /* trn-doc-attr_value */