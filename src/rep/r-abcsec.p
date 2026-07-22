block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-abcsec.p $
$Archive: rep/r-abcsec.p $

Печать Анализов АВС по группам и подгруппам .

Автор: Чернова Светлана Александровна
Дата создания: 08/22/06
Author: Svetlana Chernova
Creation date: 08/22/06

*/

define input  parameter parparentproc  as widget-handle no-undo.
define input  parameter p-rez          as character no-undo .
define input  parameter p-lvl          as integer   no-undo .
define input  parameter p-user-name as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-abcsec.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-abcsec.p $":U .
define variable vss-description as character no-undo init "Печать Анализов АВС по группам и подгруппам .".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i  new }
{ cmp/r-page1.i new }
{ gbl/paramls.i  }
{ rep/f-fdec.i   }
{ rep/f-flav.i   }
{ rep/gn-extp.i  }  /* Процедуры для определения имени расширенного типа документов */
{ ref/grplibfn.i }

Make-Excel      = true.
Make-Excel-com  = false .


define buffer buf_abc-analysis            for ub.abc-analysis.
define buffer buf_abc-analysis-goods      for ub.abc-analysis-goods.
define buffer buf_abc-analysis-gds-obj    for ub.abc-analysis-gds-obj.
define buffer buf_abc-analysis-obj        for ub.abc-analysis-obj.
define buffer buf_abc-analysis-grp        for ub.abc-analysis-grp.
define buffer buf_criterion-analysis      for ub.criterion-analysis .

DEFINE TEMP-TABLE x-analysis           no-undo  LIKE ub.abc-analysis.

define buffer buf_gds-grp                 for ub.gds-grp  .

DEFINE temp-table temp-str no-undo
  field   lvl-code    as integer
  field   node-code   as integer
  field   gds-code    as integer
  field   artic       as char
  field   gds-name    as char
  field   grp-code    as int
  field   grp-name    as char
  field   prod-name   as char
  field   prc       as decimal
  field   prcK      as char
index  pi  IS PRIMARY  prc desc
index  p2 prcK
.
DEFINE temp-table temp-grp no-undo
  field prc          as decimal
  field grp-code     as integer
  field grp-name     as char
  field is-term      as logical
  field lvl-num      as integer
  field node-name    as char
  field upper-code   as integer
index  pi  IS PRIMARY  prc DESCENDING
index  pi1 grp-code
.

define temp-table temp-abc no-undo
  field  nn         as integer
  field  id         as integer
  field  db-num      like ub.abc-analysis.db-num
  field  type        as character
  field  name        like ub.abc-analysis.abc-name
  field  des         like ub.abc-analysis.abc-des
  field  name-cral   like ub.criterion-analysis.cral-name
  field  A           like ub.abc-analysis.abc-a
  field  B           like ub.abc-analysis.abc-b
  field  C           like ub.abc-analysis.abc-c
  field  D           like ub.abc-analysis.abc-d
  field  E           like ub.abc-analysis.abc-E
  field  F           like ub.abc-analysis.abc-F
  field  date-cr     like ub.abc-analysis.abc-date-create
  field  period       as character
  field  ext-doc-type as character
  field  obj          as character
  index pi nn
  index pi2 id db-num
.

DEFINE temp-table temp-grp2 no-undo
  field prc          as decimal
  field abc          as char
  field rating       as integer
  field grp-name     as char
  field node-name    as char
index  pi   abc rating
index  pi1 node-name
.

define temp-table abc-grp-lvl no-undo
  FIELD abc-id                  AS INTEGER   LABEL "Внутренний код шапки ABC анализа"
  FIELD db-num                  AS INTEGER   FORMAT ">9" INITIAL ? LABEL "Номер БД" COLUMN-LABEL "БД"
  FIELD fullname                as character
  FIELD abcg-abc                AS CHARACTER FORMAT "X(8)" LABEL "Группа ABC в результате анализа"
  FIELD rating                  AS DECIMAL   DECIMALS 0 FORMAT ">>>>>>>>>9" LABEL "рейтинг" COLUMN-LABEL "рейтинг"
  FIELD proc-from-all           AS DECIMAL   DECIMALS 4 FORMAT "->>,>>9.9999" LABEL "Процент от общего оборота" COLUMN-LABEL "Доля"
  FIELD abcg-abc-old            AS CHARACTER FORMAT "X(1)" LABEL "Группа ABC в результате анализа рассчитанная"
  FIELD abcg-prcnt-account      AS DECIMAL   DECIMALS 10 FORMAT ">9.99" LABEL "Процент для оценки по критерию"
  FIELD abcg-prcnt-for-estimate AS DECIMAL   DECIMALS 10 FORMAT ">9.99" LABEL "Процент для оценки по критерию"
  FIELD abcg-sum-for-estimate   as decimal
INDEX pi
  abc-id
  db-num
  fullname

index  pi2
  abc-id
  db-num
  abcg-abc
  rating
.
define temp-table temp-tt no-undo
field id        as recid    /* есть */
field summa     as decimal  /* есть */
field proc      as decimal
field proc-2    as decimal
field proc-acc1 as decimal
field proc-acc2 as decimal
field ABC-1     as character
field ABC       as character
index pi proc desc
index pi1 proc-acc1 desc
index pi2 proc-acc2 desc
index pi3 id
.


define buffer buf_abc-grp-lvl  for abc-grp-lvl  .

define buffer buf2_gds-grp for ub.gds-grp  .
define variable first-lavel as integer   no-undo .
define variable v-sum-prc as decimal   no-undo .

define variable var-i as integer   no-undo .
define variable var-kol as integer   no-undo .
define variable number-group as character no-undo .
define variable i-numb as integer   no-undo .

var-kol = num-entries (p-rez).
repeat var-i = 1 to var-kol :
   find first buf_abc-analysis no-lock where recid(buf_abc-analysis) = int(entry(var-i,p-rez )) no-error .
   if not available buf_abc-analysis  then next.
   find first  buf_criterion-analysis no-lock where buf_criterion-analysis.cral-id = buf_abc-analysis.cral-id no-error .
   if not available buf_criterion-analysis  then next.

    create temp-abc.
    assign
    temp-abc.nn          = var-i
    temp-abc.id          = buf_abc-analysis.abc-id
    temp-abc.db-num      = buf_abc-analysis.db-num
    temp-abc.type        = if buf_abc-analysis.abc-type = "2"  then "Двухпроходный, ограничение Е <= " + string(buf_abc-analysis.le-proc)  else " "
    temp-abc.name        = buf_abc-analysis.abc-name
    temp-abc.des         = buf_abc-analysis.abc-des
    temp-abc.name-cral   = buf_criterion-analysis.cral-name
    temp-abc.A           = buf_abc-analysis.abc-a
    temp-abc.B           = buf_abc-analysis.abc-b
    temp-abc.C           = buf_abc-analysis.abc-c
    temp-abc.D           = buf_abc-analysis.abc-d
    temp-abc.E           = buf_abc-analysis.abc-E
    temp-abc.F           = buf_abc-analysis.abc-F
    temp-abc.date-cr     = buf_abc-analysis.abc-date-create
    temp-abc.period      = buf_abc-analysis.abc-string-period
    temp-abc.ext-doc-type = ""
    .
     define buffer buf_abc-analysis-doc for ub.abc-analysis-doc.

     for each buf_abc-analysis-doc no-lock where
              buf_abc-analysis-doc.abc-id = buf_abc-analysis.abc-id and
              buf_abc-analysis-doc.db-num = buf_abc-analysis.db-num

     :
     temp-abc.ext-doc-type = temp-abc.ext-doc-type + func-get-name-from-ext-type (buf_abc-analysis-doc.abcd-ext-doc-type , true ) + "," .
     end.

     for each buf_abc-analysis-obj no-lock where
              buf_abc-analysis-obj.abc-id = buf_abc-analysis.abc-id and
              buf_abc-analysis-obj.db-num = buf_abc-analysis.db-num

     :
     temp-abc.obj = temp-abc.obj +  buf_abc-analysis-obj.obj-type + " " + string(buf_abc-analysis-obj.obj-code) + "," .
     end.

end.

define stream  macr_excel .


define variable g#report-num  as integer   no-undo . /*    g # r e p o r t - n u m    */
define variable v-file-name as character no-undo .
define variable p-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable num#col#    as integer no-undo .
define variable C-c         as integer no-undo .
define variable C-str       as character no-undo .
define variable str--1      as character Format "x(60)" no-undo.
define variable str--2      as integer no-undo .
define variable C-i         as integer no-undo .
define variable p-var       as integer no-undo .
define variable var-1       as integer no-undo .
define variable var-2       as integer no-undo .

def buffer buf_clients for ub.clients .
def buffer This_Object for ub.clients .
def buffer buf_goods   for ub.goods .

define variable qnty as decimal   no-undo .
define variable sum  as decimal   no-undo .
define variable vv-qnty1 as decimal   no-undo .
define variable vv-qnty2 as decimal   no-undo .


define variable num-ln as integer   no-undo .

def var i as int no-undo.
def var j as int no-undo.
define variable Counter1 as integer init 0  no-undo .

def var LineBuf       as char    no-undo.
def var Line       as char    no-undo.
def var UndLine    as char    no-undo.

def var Lines_Counter as   int  init 0  no-undo.
def var Tmp_Counter   as   int  init 0  no-undo.

def var tdoc-date     like ub.fbr-pln.doc-date no-undo.
def var tdoc-code     like ub.fbr-pln.doc-code no-undo.

def var  abbr              as  char no-undo.
def var  pp                as  char no-undo.

  if session:set-wait-state("compiler") then.

  define variable v-prn0 as character no-undo .

  if var-report-r-b = "rubl" then assign pp = "Цены {&abbr_rub}.".
                             else assign pp = "Цены  баз.вал." .
{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
{ rep/repfrm.i on 1 } /* Показать окно информации о текущем процессе */
/*-----------------------------------------------------------------------------------------------------------------------*/
v-ind = 0    .
 run paramls-clear in this-procedure .

 run paramls-write in this-procedure
    (input 'rowsgroup-enable':u
    ,input '':u
    ,input 'yes':u
    ) .

 /* создаем временный файл */
    Output stream Macr_Excel  close .
    num#str# = 0 .
    run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
    output stream macr_excel to value(v-file-name)   .
    v-ind = v-ind + 1.


 run get-report-num  in parParentProc(output g#report-num).


    /* ПУстышка для runexcel !!!  */
    define stream  Stream-rpt .
    p-file-name =  string( session:temp-directory +
                  {&df_name} + string( g#report-num ) + ".txt" ) .
    output stream stream-rpt to value(p-file-name)   .
    output stream stream-rpt close  .

  run PrintTitul in this-procedure .
  /* сначала заполняем таблицу */
  for each temp-str :  delete temp-str.  end.

  run make-tt in this-procedure .
  define variable v-row as integer   no-undo .
  for each temp-grp2 break
                     by temp-grp2.abc
                     by temp-grp2.rating
                     :
     i-numb = i-numb + 1 .
     number-group = string(i-numb,"99999") .
      run print-grp-name in this-procedure ( output v-row ) .
      for each temp-str where temp-str.grp-name begins  temp-grp2.node-name
               break by temp-str.prcK
           :
          run print-line in this-procedure .
      end.
      run print-grp-itogo in this-procedure (input v-row ) .
   end.
  /* run print-all-itog in this-procedure . */



  /* ... Подвал. --- */
  run PrintPodval in this-procedure .
  run paramls-write in this-procedure
    (input "file"
    ,input string(v-ind)
    ,input v-file-name
    ) .

/* run paramls-show-temp-table. */

Output stream Macr_Excel  close .

{ rep/repfrm.i off } /* Показать окно информации о текущем процессе */

    run paramls-write in this-procedure
        (input "charcol"
        ,input ""
        ,input "1,3,4,5,6"
        ) .


  run end-proc in this-procedure .
  run rep/runexcel.p (p-file-name ).




/* *************************************************************************************************** */
procedure print-line :
  do on error undo, return error return-value :

  /* полное название на несколько строк */
num#str# = num#str# + 1.
num#col# = 1.
run macr_excel_char ( temp-str.artic     , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char ( temp-str.gds-code  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char ( temp-str.gds-name  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char ( temp-str.grp-name  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char ( temp-str.prod-name , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .

for each temp-abc:
  find first ub.abc-analysis-goods no-lock where
             ub.abc-analysis-goods.abc-id = temp-abc.id and
             ub.abc-analysis-goods.db-num = temp-abc.db-num and
             ub.abc-analysis-goods.gds-code = temp-STR.gds-code no-error .
  if available ub.abc-analysis-goods then do:
     run macr_excel_char( ub.abc-analysis-goods.abcg-abc + string(ub.abc-analysis-goods.rating) , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
     run macr_excel_DEC ( ub.abc-analysis-goods.proc-from-all , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
     run macr_excel_DEC ( ub.abc-analysis-goods.abcg-sum-for-estimate   , num#str# , num#col#   ) .

define variable v-color as integer   no-undo .
    if ub.abc-analysis-goods.abcg-abc = "A" then
       assign
         v-color = 3
       .
    if ub.abc-analysis-goods.abcg-abc = "C" then
       assign
         v-color = 0
       .

    if ub.abc-analysis-goods.abcg-abc = "B" then
       assign
          v-color = 41
       .
    if ub.abc-analysis-goods.abcg-abc = "D" then
       assign
         v-color = 14
       .
    if ub.abc-analysis-goods.abcg-abc = "E" then
       assign
         v-color = 13
       .
    if ub.abc-analysis-goods.abcg-abc = "F" then
       assign
          v-color = 48
       .

   put  stream macr_excel unformatted
        substitute('select("r&1c&2:r&3c&4 ")' , num#str# , num#col# - 2 , num#str# , num#col# ) + {&new-line}
        substitute('font.properties(,,,,,,,,,&1,,,)', v-color ) + {&new-line} .
       /* FONT.properties(font, font_style, size, strikethrough, superscript, subscript, outline, shadow, underline, color, normal, background, start_char, char_count) */

     assign    num#col# = num#col# + 1 .

  end.
  ELSE
  num#col# = num#col# + 3 .

end.
  end.
end procedure. /* print-line */



procedure print-all-itog :
end procedure. /* print-all-itog */


procedure PrintTitul :
  do  on error undo, return error return-value  :
  define variable cc as integer no-undo .
  define variable tt as integer no-undo .
    /* ---------------- Создание заголовка :--------------------------------------------------------------------------- */
    num#str# = num#str# + 1.
    num#col# = 2.
    cc = num#str# .
    run macr_excel_char ( "Сравнение ABC анализов по группам товаров до уровня " + string(p-lvl) , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    num#col# = 2.
    run macr_excel_char ("Печать " + cur-time-date()  , num#str# , num#col#   ) .
    run macr_cell_format
        ( 12     ,     /* p-size     */
          true   ,     /* p-bold     */
          false  ,     /* p-italic   */
          ?      ,     /* p-color-bg */
          cc     ,     /* p-row      */
          2      ,     /* p-col      */
          num#str# ,   /* p-row-2    */
          2 ) .        /* p-col-2    */

    run pshap.
    num#str# = num#str# + 1.
    num#col# = 1.
    run macr_excel_char ( "Группы с нулевым рейтингом не показываются " , num#str# , num#col#   ) .
    num#str# = num#str# + 1.

    num#col# = 1.
    run macr_excel_char ( "Артикул товара"   , num#str# , num#col#   ) .
    run macr_cell_size ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 2.
    run macr_excel_char ( "Код"   , num#str# , num#col#   ) .
    run macr_cell_size  ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 3.
    run macr_excel_char ( "ТМЦ"   , num#str# , num#col#   ) .
    run macr_cell_size  ( 25 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 4.
    run macr_excel_char ( "Группа"   , num#str# , num#col#   ) .
    run macr_cell_size  ( 32 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 5.
    run macr_excel_char ( "Производитель"   , num#str# , num#col#   ) .
    run macr_cell_size  ( 20 , ? , num#str# , num#col# , ?, ? ) .

    for each temp-abc :
        num#col# = num#col# + 1.
        run macr_excel_char ( "Анализ № " + string(temp-abc.nn) , num#str# , num#col#   ) .
        run macr_cell_size  ( 10 , ? , num#str# , num#col# , ?, ? ) .
        num#col# = num#col# + 1.
        run macr_excel_char (  "%"  , num#str# , num#col#   ) .
        run macr_cell_size  ( 5 , ? , num#str# , num#col# , ?, ? ) .
        num#col# = num#col# + 1.
        run macr_excel_char ( "Сумма по критерию"  , num#str# , num#col#   ) .
        run macr_cell_size  ( 15 , ? , num#str# , num#col# , ?, ? ) .

        if temp-abc.nn modulo 2 = 0 then do:
            run macr_cell_format in this-procedure
            ( 10    ,         /* p-size     */
              true  ,         /* p-bold     */
              false  ,        /* p-italic   */
              33    ,         /* p-color-bg */
              num#str# ,      /* p-row      */
              num#col# - 2 ,   /* p-col      */
              num#str# ,      /* p-row-2    */
              num#col# ) .    /* p-col-2    */
        end.
        else do:
            run macr_cell_format in this-procedure
            ( 10    ,         /* p-size     */
              true  ,         /* p-bold     */
              false  ,        /* p-italic   */
              34    ,         /* p-color-bg */
              num#str# ,      /* p-row      */
              num#col# - 2 ,   /* p-col      */
              num#str# ,      /* p-row-2    */
              num#col# ) .    /* p-col-2    */

        end.

    end.

    run macr_cell_format in this-procedure
    ( 10    ,         /* p-size     */
      true  ,         /* p-bold     */
      false  ,        /* p-italic   */
      ?    ,          /* p-color-bg */
      num#str# ,      /* p-row      */
      1 ,             /* p-col      */
      num#str# ,      /* p-row-2    */
      14 ) .          /* p-col-2    */

       /*horiz_align, wrap, vert_align, orientation, add_indent*/

     put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , num#str# , 1 , num#str# ,  num#col# ) + {&new-line}  +
       'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line} +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + {&new-line}
       .
      /*outline, left, right, top, bottom, shade, outline_color, left_color, right_color, top_color, bottom_color*/

    /* ... конец создания заголовка. --- */
  end.
end procedure. /* PrintTitul */


procedure PrintPodval :
  do on error undo, return error return-value  :

    num#str# = num#str# + 3.
    num#col# = 1.
    run macr_excel_char in this-procedure ( "Исполнитель"   , num#str# , num#col#   ) .
    num#col# = 3.
    run macr_excel_char ( p-user-name  , num#str# , num#col#   ) .



    /* ... конец создания Подвал. --- */
  end.
end procedure. /* PrintPodval */

procedure make-tt :
  do
  on error undo, return error return-value
  :
define buffer buf_abc-analysis-goods  for ub.abc-analysis-goods.
define buffer buf_goods               for ub.goods.
define buffer buf_clients             for ub.clients  .

define variable p-full-name as character    no-undo.
define variable short-name as character    no-undo.
define variable  v-izt      as character no-undo .
define variable  v-acc-mat as character no-undo .
define variable  v-Amin    as character no-undo .
define variable v-full-name as character no-undo .
define variable s-prc as decimal   no-undo .
define variable s-sum as decimal   no-undo .
define variable s-n   as integer   no-undo .
define variable nn    as integer   no-undo .

for each temp-abc :
  for each buf_abc-analysis-goods no-lock where
           buf_abc-analysis-goods.abc-id = temp-abc.id  and
           buf_abc-analysis-goods.db-num = temp-abc.db-num :
           find first buf_goods no-lock where buf_goods.gds-code =  buf_abc-analysis-goods.gds-code no-error .

      if not can-find ( first temp-str where temp-str.gds-code  = buf_abc-analysis-goods.gds-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = buf_goods.prod-type and buf_clients.obj-code = buf_goods.prod-code no-error .
          create temp-str .
          assign
              temp-str.prcK      = buf_abc-analysis-goods.abcg-abc + string( buf_abc-analysis-goods.rating,"999999999999")
              temp-str.prc       = buf_abc-analysis-goods.abcg-prcnt-for-estimate
              temp-str.gds-code  = buf_abc-analysis-goods.gds-code
              temp-str.artic     = buf_goods.artic
              temp-str.gds-name  = buf_goods.gds-name
              temp-str.grp-code  = buf_goods.grp-code
              temp-str.grp-name  = buf_goods.grp-name
              temp-str.prod-name = buf_clients.obj-name
          .
      end.

      short-name = n-lavel ( buf_goods.grp-name , p-lvl ) .
      if not can-find ( first buf_abc-grp-lvl where buf_abc-grp-lvl.fullname  =  short-name and
                                                    buf_abc-grp-lvl.abc-id = temp-abc.id  and
                                                    buf_abc-grp-lvl.db-num = temp-abc.db-num  ) then do:
          create buf_abc-grp-lvl.
          assign
            buf_abc-grp-lvl.fullname =  short-name
            buf_abc-grp-lvl.abc-id = temp-abc.id
            buf_abc-grp-lvl.db-num = temp-abc.db-num
          .
      end.

  end.

  for each buf_abc-grp-lvl no-lock where
           buf_abc-grp-lvl.abc-id = temp-abc.id  and
           buf_abc-grp-lvl.db-num = temp-abc.db-num :
            s-prc = 0.
            s-sum = 0.
            for each buf_abc-analysis-grp no-lock where
                  buf_abc-analysis-grp.abc-id = buf_abc-grp-lvl.abc-id  and
                  buf_abc-analysis-grp.db-num = buf_abc-grp-lvl.db-num  :
                  run grplib-get-full-name in this-procedure  ( input buf_abc-analysis-grp.grp-code , output v-full-name ) .
                  if v-full-name begins buf_abc-grp-lvl.fullname then do:
                      s-prc = s-prc + buf_abc-analysis-grp.proc-from-all .
                      s-sum = s-sum + buf_abc-analysis-grp.abcg-sum-for-estimate .
                  end.
            end.
            buf_abc-grp-lvl.abcg-prcnt-for-estimate = s-prc.
            buf_abc-grp-lvl.abcg-sum-for-estimate = s-sum.
  end.


  { rep/repfrm.i disp  temp-abc.nn   "'Пересчет ABC для подгрупп'" temp-abc.name }

  for each temp-tt : delete temp-tt . end.

  for each buf_abc-grp-lvl where
           buf_abc-grp-lvl.abc-id = temp-abc.id  and
           buf_abc-grp-lvl.db-num = temp-abc.db-num
           :
      create temp-tt.
      assign
        temp-tt.id = recid(buf_abc-grp-lvl)
        temp-tt.summa = buf_abc-grp-lvl.abcg-sum-for-estimate
      .
  end.

  for each x-analysis : delete x-analysis . end.
  for each buf_abc-analysis where
           buf_abc-analysis.abc-id = temp-abc.id  and
           buf_abc-analysis.db-num = temp-abc.db-num
           :
      create temp-tt.
      buffer-copy buf_abc-analysis to x-analysis.
  end.

  run ref/tt-abc.p
      ( input table x-analysis
      , input-output table temp-tt )
   .

  for each buf_abc-grp-lvl no-lock where
           buf_abc-grp-lvl.abc-id = temp-abc.id  and
           buf_abc-grp-lvl.db-num = temp-abc.db-num  :
        find first temp-tt where temp-tt.id =  recid (buf_abc-grp-lvl)  no-error .
        buf_abc-grp-lvl.abcg-abc = temp-tt.abc .
        buf_abc-grp-lvl.proc-from-all = temp-tt.proc .
  end.


  s-n = 0.
  for each buf_abc-grp-lvl no-lock where
           buf_abc-grp-lvl.abc-id = temp-abc.id  and
           buf_abc-grp-lvl.db-num = temp-abc.db-num  break
              by buf_abc-grp-lvl.abcg-abc
              by buf_abc-grp-lvl.abcg-sum-for-estimate desc
              :
           if first-of(buf_abc-grp-lvl.abcg-abc) then s-n = 0.
           s-n = s-n + 1.
           buf_abc-grp-lvl.rating = s-n .
  end.
end.

/*----------------------------------------------------------*/
define buffer buf_temp-abc for temp-abc  .
find first buf_temp-abc no-error .

for each ub.gds-grp where ub.gds-grp.is-term = true no-lock  :
run grplib-get-full-name in this-procedure
 ( input  ub.gds-grp.node-code ,
   output p-full-name  ) .
  short-name = n-lavel ( p-full-name , p-lvl ) .
  if not can-find ( first temp-grp2 where temp-grp2.node-name  =  short-name ) then do:
     find first abc-grp-lvl where
                abc-grp-lvl.fullname = short-name and
                abc-grp-lvl.abc-id   = buf_temp-abc.id  and
                abc-grp-lvl.db-num   = buf_temp-abc.db-num  no-error .
      create temp-grp2.
      assign
        temp-grp2.grp-name   =  p-full-name
        temp-grp2.node-name  =  short-name
        temp-grp2.abc        =  if available abc-grp-lvl then  abc-grp-lvl.abcg-abc else "X"
        temp-grp2.rating     =  if available abc-grp-lvl then  abc-grp-lvl.rating   else 0
      .
  end.
end.


for each temp-grp2 :
    v-sum-prc = 0 .
    for each temp-str where  temp-str.grp-name begins temp-grp2.node-name :
        temp-str.lvl-code  = p-lvl .
        temp-str.node-code = ? .
        v-sum-prc = v-sum-prc + temp-str.prc .
    end.

    if v-sum-prc = 0 then do:
      find first temp-str where temp-str.grp-name begins  temp-grp2.node-name no-error .
      if not available temp-str then
         delete temp-grp2   .
    end.
    else temp-grp2.prc = v-sum-prc .
end.

  end. /* do */
 end procedure. /* make-tt */

procedure pshap :

  do
  on error undo, return error return-value
  :
  define variable tt as integer   no-undo .

    num#str# = num#str# + 1.

    num#col# = 1.
    tt = num#str# .
    for each temp-abc :
        run macr_excel_char in this-procedure
        ( "Анализ № " + string(temp-abc.nn )  ,
           num#str# ,
           num#col#   ) .
            run macr_cell_format in this-procedure
            ( 10    ,         /* p-size     */
              true  ,         /* p-bold     */
              false ,         /* p-italic   */
              ?     ,         /* p-color-bg */
              num#str# ,      /* p-row      */
              num#col# ,      /* p-col      */
              num#str# ,      /* p-row-2    */
              num#col# ) .    /* p-col-2    */
        num#str# = num#str# + 1.

        run macr_excel_char ( temp-abc.name               , num#str# , num#col#   ) . num#str# = num#str# + 1.
        if temp-abc.des <> "" then do:  run macr_excel_char( temp-abc.des                , num#str# , num#col#   ) . num#str# = num#str# + 1. end.
        run macr_excel_char ( temp-abc.name-cral          , num#str# , num#col#   ) . num#str# = num#str# + 1.
        run macr_excel_char ( "A=" + string( temp-abc.A )                 , num#str# , num#col#   ) . num#str# = num#str# + 1.
        run macr_excel_char ( "B=" + string( temp-abc.B )                 , num#str# , num#col#   ) . num#str# = num#str# + 1.
        run macr_excel_char ( "C=" + string( temp-abc.C )                 , num#str# , num#col#   ) . num#str# = num#str# + 1.
        if temp-abc.D > 0 then do:  run macr_excel_char ( "D=" + string(temp-abc.D )   , num#str# , num#col#   ) .    num#str# = num#str# + 1. end.
        if temp-abc.E > 0 then do:  run macr_excel_char ( "E=" + string(temp-abc.E )   , num#str# , num#col#   ) .    num#str# = num#str# + 1. end.
        if temp-abc.F > 0 then do:  run macr_excel_char ( "F=" + string(temp-abc.F )   , num#str# , num#col#   ) .    num#str# = num#str# + 1. end.
        if temp-abc.type <> " " then do: run macr_excel_char ( temp-abc.type          , num#str# , num#col#   ) .  num#str# = num#str# + 1.    end.
        run macr_excel_char ( "создан : " + string(temp-abc.date-cr , "99/99/9999")            , num#str# , num#col#   ) . num#str# = num#str# + 1.
        run macr_excel_char ( temp-abc.period             , num#str# , num#col#   ) .  num#str# = num#str# + 1.
        run macr_excel_char ( temp-abc.ext-doc-type       , num#str# , num#col#   ) .  num#str# = num#str# + 1.
        run macr_excel_char ( temp-abc.obj                , num#str# , num#col#   ) .  num#str# = num#str# + 1.
    end.

  end.

end procedure. /* pshap */


procedure print-grp-name :
define output parameter p-row as integer   no-undo .
  do
  on error undo, return error return-value
  :
num#str# = num#str# + 1.
num#col# = 1.

run macr_excel_char (  temp-grp2.node-name   , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
 assign    num#col# = num#col# + 1 .
 assign    num#col# = num#col# + 1 .
run macr_excel_char ( entry(1, temp-grp2.grp-name ,"/" )    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_cell_format in this-procedure
        ( 12     ,     /* p-size     */
          true   ,     /* p-bold     */
          false  ,     /* p-italic   */
          48      ,     /* p-color-bg */
          num#str# ,     /* p-row      */
          1      ,     /* p-col      */
          num#str# ,   /* p-row-2    */
          5 + ( var-kol * 3 ) ) .        /* p-col-2    */

p-row =  num#str# .

  end.

end procedure. /* print-grp-name */



procedure print-grp-itogo :
define input  parameter p-row as integer   no-undo .
  do
  on error undo, return error return-value
  :
/* группировка по товарам */
  run paramls-write in this-procedure
    (input "rowsgroup"
    ,input string(v-ind) + ',':u + number-group
    ,input substitute('&1:&2' ,  p-row, num#str# )
    ) .



num#str# = num#str# + 1.
num#col# = 1.
    run macr_cell_format in this-procedure
        ( ?     ,      /* p-size     */
          true   ,     /* p-bold     */
          false  ,     /* p-italic   */
          ?      ,     /* p-color-bg */
          num#str# ,   /* p-row      */
          1      ,     /* p-col      */
          num#str# ,   /* p-row-2    */
          5 + ( var-kol * 3 ) ) .       /* p-col-2    */

run macr_excel_char in this-procedure (  temp-grp2.node-name    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
 assign    num#col# = num#col# + 1 .
 assign    num#col# = num#col# + 1 .
run macr_excel_char ( entry(1, temp-grp2.grp-name ,"/" ) , num#str# , num#col#   ) . assign num#col# = num#col# + 1 .
run macr_excel_char ( ""                  , num#str# , num#col#   ) . assign num#col# = num#col# + 1 .
/*  итоги по всем группам */
for each temp-abc:
  find first abc-grp-lvl no-lock where
             abc-grp-lvl.abc-id = temp-abc.id and
             abc-grp-lvl.db-num = temp-abc.db-num and
             abc-grp-lvl.fullname = temp-grp2.node-name no-error .
  if available abc-grp-lvl then do:
     run macr_excel_char ( abc-grp-lvl.abcg-abc + string(abc-grp-lvl.rating) , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
     run macr_excel_DEC ( abc-grp-lvl.proc-from-all , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
     run macr_excel_DEC ( abc-grp-lvl.abcg-sum-for-estimate   , num#str# , num#col#   ) .


define variable v-color as integer   no-undo .
    if abc-grp-lvl.abcg-abc = "A" then
       assign
         v-color = 3
       .
    if abc-grp-lvl.abcg-abc = "C" then
       assign
         v-color = 0
       .

    if abc-grp-lvl.abcg-abc = "B" then
       assign
          v-color = 41
       .
    if abc-grp-lvl.abcg-abc = "D" then
       assign
         v-color = 14
       .
    if abc-grp-lvl.abcg-abc = "E" then
       assign
         v-color = 13
       .
    if abc-grp-lvl.abcg-abc = "F" then
       assign
          v-color = 48
       .

   put  stream macr_excel unformatted
        substitute('select("r&1c&2:r&3c&4 ")' , num#str# , num#col# - 2 , num#str# , num#col# ) + {&new-line}
        substitute('font.properties(,,,,,,,,,&1,,,)', v-color ) + {&new-line}

        .
     /* FONT.properties(font, font_style, size, strikethrough, superscript, subscript, outline, shadow, underline, color, normal, background, start_char, char_count) */

     assign    num#col# = num#col# + 1 .

  end.
  ELSE
  num#col# = num#col# + 3 .

end.

  end.

end procedure. /* print-grp-itogo */



{ rep/r-libmcr.i macr_excel }