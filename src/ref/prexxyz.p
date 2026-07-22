block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: prexxyz.p $
$Archive: ref/prexxyz.p $

Печать Анализов XYZ

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 06/21/05
*/

DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER P-REZ          AS CHARACTER NO-UNDO .
define input  parameter p-user-name as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: prexxyz.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/prexxyz.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i  new }
{ cmp/r-page1.i new }
{ gbl/paramls.i  }
{ rep/f-fdec.i   }
{ rep/gn-extp.i  }  /*Процедуры для определения имени расширенного типа документов*/
Make-Excel      = true.
Make-Excel-com  = false .


define buffer buf_xyz-analysis            for ub.xyz-analysis.
define buffer buf_xyz-analysis-goods      for ub.xyz-analysis-goods.
define buffer buf_xyz-analysis-gds-obj    for ub.xyz-analysis-gds-obj.
define buffer buf_xyz-analysis-obj        for ub.xyz-analysis-obj.
define buffer buf_assortment-matrix       for ub.assortment-matrix.
define buffer buf_assortment-matrix-goods for ub.assortment-matrix-goods.
define buffer buf_gds-obj-prop            for ub.gds-obj-prop.
define buffer buf_criterion-analysis      for ub.criterion-analysis.

DEFINE temp-table temp-str no-undo
  field   gds-code           as integer
  field   artic              as char
  field   gds-name           as char
  field   acc_min            as char
  field   acc_matr           as char
  field   izt                as char
.

define temp-table temp-abc no-undo
  field nn           as integer
  field id           as integer
  field  db-num      like ub.xyz-analysis.db-num
  field  name        like ub.xyz-analysis.xyz-name
  field  des         like ub.xyz-analysis.xyz-des
  field  name-cral   like ub.criterion-analysis.cral-name
  field  A           like ub.xyz-analysis.xyz-x
  field  B           like ub.xyz-analysis.xyz-y
  field  C           like ub.xyz-analysis.xyz-z
  field  date-cr     like ub.xyz-analysis.xyz-date-create
  field  period       as character
  field  ext-doc-type as character
  field  obj          as character




  index pi nn
  index pi2 id db-num
.

define variable var-i as integer   no-undo .
define variable var-kol as integer   no-undo .


var-kol = num-entries (p-rez).
repeat var-i = 1 to var-kol :
   find first buf_xyz-analysis no-lock where recid(buf_xyz-analysis) = int(entry(var-i,p-rez )) no-error .
   if not available buf_xyz-analysis  then next.
   find first  buf_criterion-analysis no-lock where buf_criterion-analysis.cral-id = buf_xyz-analysis.cral-id no-error .
   if not available buf_criterion-analysis  then next.

    create temp-abc.
    assign
    temp-abc.nn           = var-i
    temp-abc.id           = buf_xyz-analysis.xyz-id
    temp-abc.db-num       = buf_xyz-analysis.db-num
    temp-abc.name         = buf_xyz-analysis.xyz-name
    temp-abc.des          = buf_xyz-analysis.xyz-des
    temp-abc.name-cral   = buf_criterion-analysis.cral-name
    temp-abc.A           = buf_xyz-analysis.xyz-x
    temp-abc.B           = buf_xyz-analysis.xyz-y
    temp-abc.C           = buf_xyz-analysis.xyz-z
    temp-abc.date-cr     = buf_xyz-analysis.xyz-date-create
    temp-abc.period      = buf_xyz-analysis.xyz-string-period
    temp-abc.ext-doc-type = ""
    .
    define buffer buf_xyz-analysis-doc for ub.xyz-analysis-doc.
     for each buf_xyz-analysis-doc no-lock where
              buf_xyz-analysis-doc.xyz-id = buf_xyz-analysis.xyz-id and
              buf_xyz-analysis-doc.db-num = buf_xyz-analysis.db-num

     :
     temp-abc.ext-doc-type = temp-abc.ext-doc-type + func-get-name-from-ext-type (buf_xyz-analysis-doc.xyzd-ext-doc-type , true ) + "," .
     end.

     for each buf_xyz-analysis-obj no-lock where
              buf_xyz-analysis-obj.xyz-id = buf_xyz-analysis.xyz-id and
              buf_xyz-analysis-obj.db-num = buf_xyz-analysis.db-num

     :
     temp-abc.obj = temp-abc.obj +  buf_xyz-analysis-obj.obj-type + " " + string(buf_xyz-analysis-obj.obj-code) + "," .
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

def var tdoc-date     as date      no-undo .
def var tdoc-code     as character no-undo .

def var  abbr              as  char no-undo.
def var  pp                as  char no-undo.

  if session:set-wait-state("compiler") then.

  define variable v-prn0 as character no-undo .

  if var-report-r-b = "rubl" then assign pp = "Цены {&abbr_rub}.".
                             else assign pp = "Цены  баз.вал." .
{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
{ rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */
/*-----------------------------------------------------------------------------------------------------------------------*/
v-ind = 0    .


 /* создаем временный файл */
    Output stream Macr_Excel  close .
    num#str# = 0 .
    run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name) .
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

  run make-tt.

  for each temp-str no-lock :
       run print-line in this-procedure .
  end.
  /* run print-all-itog in this-procedure . */

  /* ... Подвал. --- */
  run PrintPodval in this-procedure .
  run paramls-write in this-procedure
    (input "file"
    ,input string(v-ind)
    ,input v-file-name
    ) .

Output stream Macr_Excel  close .

{ rep/repfrm.i off } /* Показать окно информации о текущем процессе */

    run paramls-write in this-procedure
        (input "charcol"
        ,input ""
        ,input "1,3,4,5,6"
        ) .

  run end-proc .
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
run macr_excel_char ( temp-str.acc_min   , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char ( temp-str.acc_matr  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char ( temp-str.izt       , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .

for each temp-abc:
  find first ub.xyz-analysis-goods no-lock where
             ub.xyz-analysis-goods.xyz-id = temp-abc.id and
             ub.xyz-analysis-goods.db-num = temp-abc.db-num and
             ub.xyz-analysis-goods.gds-code = temp-STR.gds-code no-error .
  if available ub.xyz-analysis-goods then do:
     run macr_excel_char ( ub.xyz-analysis-goods.xyzg-xyz                , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
     run macr_excel_DEC ( ub.xyz-analysis-goods.xyzg-prcnt-for-estimate , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
     run macr_excel_DEC ( ub.xyz-analysis-goods.xyzg-sum-for-estimate   , num#str# , num#col#   ) .

define variable v-color as integer   no-undo .
    if ub.xyz-analysis-goods.xyzg-xyz = "X" then
       assign
         v-color = 3
       .
    if ub.xyz-analysis-goods.xyzg-xyz = "Y" then
       assign
          v-color = 41
       .

    if ub.xyz-analysis-goods.xyzg-xyz = "Z" then
       assign
         v-color = 0
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
    run macr_excel_char ( "Сравнение XYZ анализов"  , num#str# , num#col#   ) .
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
    run macr_excel_char ( "Артикул товара"   , num#str# , num#col#   ) .
    run macr_cell_size ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 2.
    run macr_excel_char ( "Код"   , num#str# , num#col#   ) .
    run macr_cell_size ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 3.
    run macr_excel_char ( "Наименование товара"   , num#str# , num#col#   ) .
    run macr_cell_size ( 25 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 4.
    run macr_excel_char ( "Ассортиментный минимум"   , num#str# , num#col#   ) .
    run macr_cell_size ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 5.
    run macr_excel_char ( "Ассортиментная матрица"   , num#str# , num#col#   ) .
    run macr_cell_size ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 6.
    run macr_excel_char ( "ИЖТ"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .

    for each temp-abc :
        num#col# = num#col# + 1.
        run macr_excel_char ( "Анализ № " + string(temp-abc.nn) , num#str# , num#col#   ) .
        run macr_cell_size ( 10 , ? , num#str# , num#col# , ?, ? ) .
        num#col# = num#col# + 1.
        run macr_excel_char (  "%"  , num#str# , num#col#   ) .
        run macr_cell_size ( 5 , ? , num#str# , num#col# , ?, ? ) .
        num#col# = num#col# + 1.
        run macr_excel_char ( "Сумма по критерию"  , num#str# , num#col#   ) .
        run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .

        if temp-abc.nn modulo 2 = 0 then do:
            run macr_cell_format
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
            run macr_cell_format
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

    run macr_cell_format
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
    run macr_excel_char ( "Исполнитель"   , num#str# , num#col#   ) .
    num#col# = 3.
    run macr_excel_char ( p-user-name , num#str# , num#col#   ) .




    /* ... конец создания Подвал. --- */
  end.
end procedure. /* PrintPodval */

procedure make-tt :
  do
  on error undo, return error return-value
  :
define buffer buf_xyz-analysis-goods for ub.xyz-analysis-goods.
define buffer buf_goods for ub.goods.
define variable  v-izt      as character no-undo .
define variable  v-acc-mat as character no-undo .
define variable  v-Amin    as character no-undo .




for each temp-abc :
  for each buf_xyz-analysis-goods no-lock where
           buf_xyz-analysis-goods.xyz-id = temp-abc.id  and
           buf_xyz-analysis-goods.db-num = temp-abc.db-num :
    if not can-find ( first temp-str where temp-str.gds-code  = buf_xyz-analysis-goods.gds-code) then do:
        find first buf_goods no-lock where buf_goods.gds-code =  buf_xyz-analysis-goods.gds-code no-error .

        create temp-str .
        run proc-disp-goods (
              input buf_goods.gds-code
            , output v-izt
            , output v-acc-mat
            , output v-Amin      ).

        assign
            temp-str.gds-code = buf_xyz-analysis-goods.gds-code
            temp-str.artic    = buf_goods.artic
            temp-str.gds-name = buf_goods.gds-name
            temp-str.acc_min  = v-Amin
            temp-str.acc_matr = v-acc-mat
            temp-str.izt      = v-izt
        .
    end.
  end.

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
        run macr_excel_char ( "Анализ № " + string(temp-abc.nn )                , num#str# , num#col#   ) .
            run macr_cell_format
            ( 10    ,         /* p-size     */
              true  ,         /* p-bold     */
              false  ,        /* p-italic   */
              ?    ,          /* p-color-bg */
              num#str# ,      /* p-row      */
              num#col#  ,  /* p-col      */
              num#str# ,      /* p-row-2    */
              num#col# ) .    /* p-col-2    */
        num#str# = num#str# + 1.

        run macr_excel_char ( temp-abc.name               , num#str# , num#col#   ) . num#str# = num#str# + 1.
        if temp-abc.des <> "" then do:  run macr_excel_char ( temp-abc.des                , num#str# , num#col#   ) . num#str# = num#str# + 1. end.
        run macr_excel_char ( temp-abc.name-cral          , num#str# , num#col#   ) . num#str# = num#str# + 1.
        run macr_excel_char ( "X меньше     : " + string( temp-abc.A )                 , num#str# , num#col#   ) . num#str# = num#str# + 1.
        run macr_excel_char ( "Y в интервале: " + string( temp-abc.A ) + " по " + string( temp-abc.C )    , num#str# , num#col#   ) . num#str# = num#str# + 1.
        run macr_excel_char ( "Z больше     : " + string( temp-abc.C )                 , num#str# , num#col#   ) . num#str# = num#str# + 1.
        run macr_excel_char ( "создан : " + string(temp-abc.date-cr , "99/99/9999")            , num#str# , num#col#   ) . num#str# = num#str# + 1.
        run macr_excel_char ( temp-abc.period             , num#str# , num#col#   ) .  num#str# = num#str# + 1.
        run macr_excel_char ( temp-abc.ext-doc-type       , num#str# , num#col#   ) .  num#str# = num#str# + 1.
        run macr_excel_char ( temp-abc.obj                , num#str# , num#col#   ) .  num#str# = num#str# + 1.
    end.

  end.

end procedure. /* pshap */


PROCEDURE proc-disp-goods :
define input  parameter p-gds-code as integer   no-undo .
define output parameter  v-izt      as character no-undo .
define output parameter  v-acc-mat as character no-undo .
define output parameter  v-Amin    as character no-undo .

define variable   v-old-izt  as character no-undo .
define variable   v-old-amin  as character no-undo .
define variable   v-old-acc-mat  as character no-undo .
define variable vt-Amin as character no-undo .
define variable v-id    as integer   no-undo .
define variable v-db-num  as integer   no-undo .
define variable t-izt as character no-undo .
define variable t-Amin as character no-undo .
define variable t-asm as character no-undo .

    assign
    v-old-izt  = ""
    v-izt      = ""
    v-Amin     = ""
    v-old-Amin = ""
    v-acc-mat     =  ""
    v-old-acc-mat = ""
    .


define buffer buf2_xyz-analysis-gds-obj for ub.xyz-analysis-gds-obj   .
define buffer buf2_assortment-matrix for ub.assortment-matrix.
define buffer buf2_assortment-matrix-goods for ub.assortment-matrix-goods.
define variable            v-gdop-min-stock                as decimal   no-undo .
define variable            v-grop-max-stock                as decimal   no-undo .
define variable            v-grop-level-always-presence    as decimal   no-undo .
define variable            v-grop-min-order                as decimal   no-undo .


FOR EACH Buf_xyz-analysis-obj WHERE
         Buf_xyz-analysis-obj.xyz-id = TEMP-ABC.id AND
         Buf_xyz-analysis-obj.db-num = TEMP-ABC.db-num
         NO-LOCK ,
        EACH buf2_xyz-analysis-gds-obj WHERE
            buf2_xyz-analysis-gds-obj.obj-type = Buf_xyz-analysis-obj.obj-type AND
            buf2_xyz-analysis-gds-obj.obj-code = Buf_xyz-analysis-obj.obj-code AND
            buf2_xyz-analysis-gds-obj.gds-code = p-gds-code AND
            buf2_xyz-analysis-gds-obj.xyz-id   = TEMP-ABC.id AND
            buf2_xyz-analysis-gds-obj.db-num   = TEMP-ABC.db-num
            NO-LOCK break
            by Buf2_xyz-analysis-gds-OBJ.gds-code

            :

                find first buf2_assortment-matrix WHERE
                      buf2_assortment-matrix.asmt-status        = 0  AND
                      buf2_assortment-matrix.obj-type =  Buf_xyz-analysis-obj.obj-type AND
                      buf2_assortment-matrix.obj-code =  Buf_xyz-analysis-obj.obj-code
                      NO-LOCK no-error .
                find first buf2_assortment-matrix-goods WHERE
                      buf2_assortment-matrix-goods.asmg-status        = 0  AND
                      buf2_assortment-matrix-goods.asmt-id  =  buf2_assortment-matrix.asmt-id AND
                      buf2_assortment-matrix-goods.db-num   =  buf2_assortment-matrix.db-num  AND
                      buf2_assortment-matrix-goods.gds-code =  p-gds-code
                      NO-LOCK no-error .

                 { gbl/gdsobjpr.i
                 Buf_xyz-analysis-obj.obj-type
                 Buf_xyz-analysis-obj.obj-code
                 ?
                 ?
                 ?
                 p-gds-code
                 t-amin
                 t-izt
                 v-gdop-min-stock
                 v-grop-max-stock
                 v-grop-level-always-presence
                 v-grop-min-order
                 }
             if not available buf2_assortment-matrix-goods then t-asm = "0" .
                                                           else t-asm = string(buf2_assortment-matrix-goods.asmt-id).

            if first-of(Buf2_xyz-analysis-gds-OBJ.gds-code) then do:
                  assign
                  v-old-izt  =  t-izt
                  v-izt      =  t-izt
                  v-Amin     =  t-amin
                  v-old-Amin =  t-amin
                  v-acc-mat     =  t-asm
                  v-old-acc-mat =  t-asm
                  .

                  if  v-Amin = 'no'  then v-Amin = "не входит" .
                                     else v-Amin = "входит" .
                  if v-acc-mat = "0" then v-acc-mat = "не входит" .
                                     else v-acc-mat = "входит" .
            end.

        if v-old-izt     <> t-izt            then  v-izt = "разное" .
        if v-old-Amin    <> t-Amin           then  v-Amin = "разное" .
        if v-old-acc-mat <> t-asm            then  v-acc-mat = "разное" .

      assign
        v-old-izt     = t-izt
        v-old-Amin    = t-Amin
        v-old-acc-mat = t-asm
      .

end.
END PROCEDURE.

 { rep/r-libmcr.i macr_excel         }