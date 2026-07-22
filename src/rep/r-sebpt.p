block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-sebpt.p $
$Archive: rep/r-sebpt.p $

Бензиновый отчет по себестоимости

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 06/15/05
*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-sebpt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-sebpt.p $":U .
define variable vss-description as character no-undo init "Бензиновый отчет по себестоимости".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ cmp/r-page1.i  }
{ gbl/paramls.i  }
{ rep/f-fdec.i   }
{ str/lib-trn.i  }
{ rep/rep-bt.i   }
 do
 on error undo, return error return-value
 :

x-date-start = x-date-alone .


DEFINE temp-table temp-str no-undo
  field   np                 as character
  field   date-sm            as character
  field   cli-name           as character
  field   gds-name           as character
  field   b-code             as integer
  field   ostatok-qnty-start as decimal
  field   ostatok-qnty-end   as decimal
  field   ostatok-sum-start  as decimal
  field   ostatok-sum-end    as decimal
  field   prih-qnty          as decimal
  field   prih-sum           as decimal
  field   rash-qnty          as decimal
  field   rash-sum           as decimal
.

define stream  macr_excel .

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

def var tdoc-date     like fbr-pln.doc-date no-undo.
def var tdoc-code     like fbr-pln.doc-code no-undo.

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
    run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
    output stream macr_excel to value(v-file-name)   .
    v-ind = v-ind + 1.

    p-file-name =  string( session:temp-directory +
                                  {&df_name} + string( g#report-num ) + ".txt" ) .


define variable paris-petrolium as   logical            no-undo.
define variable paris-pieces    as   logical            no-undo.
define temp-table tt-gds-list no-undo like ub.goods.

for each tt-gds-list : delete tt-gds-list. end.

for each buf_goods no-lock :
  { str/is-petrl.i
    buf_goods.artic
    buf_goods.prod-type
    buf_goods.prod-code
    paris-petrolium
    paris-pieces
    }
      if paris-petrolium then do:
          create tt-gds-list.
          BUFFER-COPY buf_goods TO tt-gds-list.
      end.
end.

for each obj-list :
  run PrintTitul in this-procedure .
  /* по строкам документа-------------------------------------------------------------------------------------------- */
  /* сначала заполняем таблицу */
  for each temp-str :
      delete temp-str.
  end.
  run make-tt.
  for each temp-str no-lock break by temp-str.date-sm  :
    if first-of( temp-str.date-sm) then do:
          run print-grp in this-procedure .
          vv-qnty1 = 0 .
          vv-qnty2 = 0 .
       end.
       run print-line in this-procedure .
       vv-qnty1 = vv-qnty1 + temp-str.ostatok-qnty-start.
       vv-qnty2 = vv-qnty2 + temp-str.ostatok-qnty-end.
    if last-of( temp-str.date-sm ) then  run print-grp-itog in this-procedure .
  end.
  /* run print-all-itog in this-procedure . */

  /* ... Подвал. --- */
  run PrintPodval in this-procedure .
end. /* obj-list */
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
        ,input "1,2,3"
        ) .

  run end-proc in this-procedure .
  run rep/runexcel.p (p-file-name ).

end.

/* *************************************************************************************************** */

procedure print-grp :
  do  on error undo, return error return-value  :

    num#str# = num#str# + 1.
    run macr_excel_char ( CAPS(temp-str.date-sm)    , num#str# , 2   ) .
    run macr_cell_format
          ( 12    ,     /* p-size    */
            true  ,     /*p-bold     */
            false ,     /*p-italic   */
            ?     ,     /*p-color-bg */
            num#str# ,  /*p-row    */
            2 ,          /*p-col    */
            num#str# ,         /*p-row-2  */
            2               ) . /*p-col-2 */

  end.
end procedure. /* print-grp */



procedure print-line :
  do on error undo, return error return-value :

  /* полное название на несколько строк */
num#str# = num#str# + 1.
num#col# = 1.
run macr_excel_char ( substring(temp-str.date-sm ,1,8) + "." , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char ( temp-str.cli-name  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_char ( temp-str.gds-name  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec ( temp-str.ostatok-qnty-start , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec ( temp-str.ostatok-sum-start    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec ( temp-str.prih-qnty           , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec ( temp-str.prih-sum            , num#str# , num#col#   ) . assign    num#col# = num#col# + 2 .
run macr_excel_char ( substitute('=r&1c7+r&1c8' , num#str#   ) , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec ( temp-str.rash-qnty           , num#str# , num#col#   ) . assign    num#col# = num#col# + 2 .
run macr_excel_char ( substitute('=r&1c9+r&1c11' , num#str#  ) , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec ( temp-str.ostatok-qnty-end    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
run macr_excel_dec ( temp-str.ostatok-sum-end     , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
  end.
end procedure. /* print-line */


procedure print-grp-itog :
  do on error undo, return error return-value :
    num#str# = num#str# + 1.
    num#col# = 2.
    run macr_excel_char ( "Итого" , num#str# , 2   ) .
    num#col# = 4.
    run macr_excel_dec ( vv-qnty1 , num#str# , num#col#   ) .
    num#col# = 13 .
    run macr_excel_dec ( vv-qnty2 , num#str# , num#col#   ) .

    run macr_cell_format
          ( 12    ,     /* p-size    */
            true  ,     /*p-bold     */
            false ,     /*p-italic   */
            ?     ,     /*p-color-bg */
            num#str# ,  /*p-row    */
            2 ,          /*p-col    */
            num#str# ,         /*p-row-2  */
            2               ) . /*p-col-2 */

  end.
end procedure. /* print-grp-itog */




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
    run macr_excel_char ( "Расчет себестоимости за  " + string(x-date-alone, "99/99/9999" )    , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    num#col# = 2.
    run macr_excel_char ( string( CAPS( obj-list.obj-name ) + " (" + string(Obj-list.obj-code) + ")" )   , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    num#col# = 2.
    run macr_excel_char ("Печать " + cur-time-date() + "  " + pp , num#str# , num#col#   ) .
    run macr_cell_format
    ( 12    ,      /* p-size     */
      true  ,      /* p-bold     */
      false  ,      /* p-italic   */
      ?    ,      /* p-color-bg */
      cc ,      /* p-row      */
      2 ,      /* p-col      */
      num#str# ,   /* p-row-2    */
      2 ) . /* p-col-2    */

    num#str# = num#str# + 1.
    tt = num#str#  .
     put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , tt , 4 , tt , 5 ) + {&new-line}  +
       'ALIGNMENT(7,,4,4,)'  + {&new-line}
       'BORDER( 2,0,0,0,0,,0,0,0,0,0) '  + {&new-line}
       substitute('select("r&1c&2:r&3c&4 ")' , tt , 6 , tt , 9 ) + {&new-line}  +
       'ALIGNMENT(7,,4,4,)'  + {&new-line}
       'BORDER(2,0,0,0,0,,0,0,0,0,0) '  + {&new-line}
       substitute('select("r&1c&2:r&3c&4 ")' , tt , 10 , tt , 12 ) + {&new-line}  +
       'ALIGNMENT(7,,4,4,)'  + {&new-line}
       'BORDER(2,0,0,0,0,,0,0,0,0,0) '  + {&new-line}
       substitute('select("r&1c&2:r&3c&4 ")' , tt , 13 , tt , 14 ) + {&new-line}  +
       'ALIGNMENT(7,,4,4,)'  + {&new-line}
       'BORDER(2,0,0,0,0,,0,0,0,0,0) '  + {&new-line}
       .

    num#col# = 4.
    run macr_excel_char ( "Остаток на начало"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 6.
    run macr_excel_char ( "Приход"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 10.
    run macr_excel_char ( "Расход"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 13.
    run macr_excel_char ( "Остаток на конец"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .


    num#str# = num#str# + 1.
    num#col# = 1.
    run macr_excel_char ( "Дата"   , num#str# , num#col#   ) .
    run macr_cell_size ( 7 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 2.
    run macr_excel_char ( "Отправитель"   , num#str# , num#col#   ) .
    run macr_cell_size ( 40 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 3.
    run macr_excel_char ( "Вид н/п"   , num#str# , num#col#   ) .
    run macr_cell_size ( 20 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 4.
    run macr_excel_char ( "Кол-во,л"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 5.
    run macr_excel_char ( "Себестоимость, {&abbr_rub}/л"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .

    num#col# = 6.
    run macr_excel_char ( "Кол-во,л"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 7.
    run macr_excel_char ( "Цена"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 8.
    run macr_excel_char ( " К1, {&abbr_rub}/л"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 9.
    run macr_excel_char ( "Себестоимость, {&abbr_rub}/л"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .

    num#col# = 10.
    run macr_excel_char ( "Кол-во,л"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 11.
    run macr_excel_char ( " К2, {&abbr_rub}/л"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 12.
    run macr_excel_char ( "Себестоимость, {&abbr_rub}/л"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .

    num#col# = 13.
    run macr_excel_char ( "Кол-во,л"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 14.
    run macr_excel_char ( "Себестоимость, {&abbr_rub}/л"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .

    num#str# = num#str# + 1.
    num#col# = 1.
    run macr_excel_char ( "1"   , num#str# , num#col#   ) .
    run macr_cell_size ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 2.
    run macr_excel_char ( "2"   , num#str# , num#col#   ) .
    run macr_cell_size ( 40 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 3.
    run macr_excel_char ( "3"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 4.
    run macr_excel_char ( "4"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 5.
    run macr_excel_char ( "5"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .

    num#col# = 6.
    run macr_excel_char ( "6"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 7.
    run macr_excel_char ( "7"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 8.
    run macr_excel_char ( "8"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 9.
    run macr_excel_char ( "9"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .

    num#col# = 10.
    run macr_excel_char ( "10"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 11.
    run macr_excel_char ( "11"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 12.
    run macr_excel_char ( "12"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .

    num#col# = 13.
    run macr_excel_char ( "13"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 14.
    run macr_excel_char ( "14"   , num#str# , num#col#   ) .
    run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .


    run macr_cell_format
    ( 12    ,         /* p-size     */
      true  ,         /* p-bold     */
      false  ,        /* p-italic   */
      ?    ,          /* p-color-bg */
      num#str# ,      /* p-row      */
      1 ,             /* p-col      */
      num#str# ,      /* p-row-2    */
      14 ) .          /* p-col-2    */
     put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , tt , 1 , num#str# ,  3 ) + {&new-line}  +
       'BORDER( 2 , 2 , 0 , 0 , 0 , ,0,0,0,0,0) '  + {&new-line} +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + {&new-line}
       .

       /*horiz_align, wrap, vert_align, orientation, add_indent*/

     put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , tt + 1 , 4 , num#str# ,  num#col# ) + {&new-line}  +
       'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + {&new-line} +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + {&new-line}
       .
     put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , num#str# , 1 , num#str# , 3 ) + {&new-line}  +
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
    num#col# = 2.
    run macr_excel_char ( "Исполнитель"   , num#str# , num#col#   ) .


    /* ... конец создания Подвал. --- */
  end.
end procedure. /* PrintPodval */

procedure make-tt :
  do
  on error undo, return error return-value
  :

  define buffer buf_shift-obj for ub.shift-obj.
  define variable fact-order-1 as decimal   no-undo .
  define variable fact-order-2 as decimal   no-undo .
  define variable    quantity     like ub.stk-line.fact-qnty  no-undo .
  define variable    coast_r      like ub.stk-line.sum-rubl   no-undo .
  define variable    coast_v      like ub.stk-line.sum-rubl   no-undo .
  define variable    vat_r        like ub.stk-line.sum-rubl   no-undo .
  define variable    vat_v        like ub.stk-line.sum-rubl   no-undo .
  define variable    slt_r        like ub.stk-line.sum-rubl   no-undo .
  define variable    slt_v        like ub.stk-line.sum-rubl   no-undo .
  define variable    quantity2     like ub.stk-line.fact-qnty  no-undo .
  define variable    coast_r2      like ub.stk-line.sum-rubl   no-undo .
  define variable    coast_v2      like ub.stk-line.sum-rubl   no-undo .

  define buffer buf_trn-doc for ub.trn-doc.
  define buffer buf_doc-line for ub.doc-line.
  define buffer buf_clients for ub.clients.
  define variable v-qnty as decimal   no-undo .
  define variable v-sum as decimal   no-undo .
  define variable v-cli as character no-undo .


  find last buf_shift-obj no-lock where
           buf_shift-obj.shift-date <= x-date-alone - 1    and
           buf_shift-obj.obj-type   = obj-list.obj-type  and
           buf_shift-obj.obj-code   = obj-list.obj-code  use-index pi no-error .
  if available buf_shift-obj then
       fact-order-2 = buf_shift-obj.fact-order.
  else fact-order-2 = 0 .

  for each buf_shift-obj no-lock where
           buf_shift-obj.shift-date = x-date-alone     and
           buf_shift-obj.obj-type   = obj-list.obj-type  and
           buf_shift-obj.obj-code   = obj-list.obj-code
           :
         fact-order-1 = fact-order-2.
         fact-order-2 = buf_shift-obj.fact-order.

        if fact-order-2 = 0 and buf_shift-obj.status_   <> {&sht-closed}   then do:
           fact-order-2 = decimal (x-date-alone + 1 ).
        end.


         for each tt-gds-list :
                  run ost-line (
                     input   obj-list.obj-code
                    ,input   obj-list.obj-type
                    ,input   tt-gds-list.artic
                    ,input   tt-gds-list.prod-code
                    ,input   tt-gds-list.prod-type
                    ,input   true
                    ,input   fact-order-1
                    ,input   {&arh-cost}
                    ,input   {&root-cat-id}
                    ,input   true
                    ,output  quantity
                    ,output  coast_r
                    ,output  coast_v
                    ,output  vat_r
                    ,output  vat_v
                    ,output  slt_r
                    ,output  slt_v
                    ).
                  run ost-line (
                     input   obj-list.obj-code
                    ,input   obj-list.obj-type
                    ,input   tt-gds-list.artic
                    ,input   tt-gds-list.prod-code
                    ,input   tt-gds-list.prod-type
                    ,input   true
                    ,input   fact-order-2
                    ,input   {&arh-cost}
                    ,input   {&root-cat-id}
                    ,input   true
                    ,output  quantity2
                    ,output  coast_r2
                    ,output  coast_v2
                    ,output  vat_r
                    ,output  vat_v
                    ,output  slt_r
                    ,output  slt_v
                    ).

                  assign
                     v-qnty = 0
                     v-sum  = 0
                     v-cli = ""
                  .
                  for each buf_trn-doc no-lock where
                           buf_trn-doc.fact-order >= fact-order-1 and
                           buf_trn-doc.fact-order <= fact-order-2 and
                           buf_trn-doc.doc-type = {&income}  and
                           buf_trn-doc.host-code = v-cntxt-host-code-obj  and
                           buf_trn-doc.status_   = {&fact}      and
                           buf_trn-doc.obj-type  = obj-list.obj-type  and
                           buf_trn-doc.obj-code  = obj-list.obj-code
                           break by buf_trn-doc.cli-type by buf_trn-doc.cli-code

                  :
                     for each  buf_doc-line no-lock where
                                buf_doc-line.doc-code = buf_trn-doc.doc-code and
                                buf_doc-line.artic    =  tt-gds-list.artic and
                                buf_doc-line.prod-code =  tt-gds-list.prod-code and
                                buf_doc-line.prod-type =  tt-gds-list.prod-type
                               :

                              assign
                                  v-qnty = v-qnty + buf_doc-line.fact-qnty
                                  v-sum  = v-sum  + buf_doc-line.fact-qnty * (if var-report-r-b = "rubl":u then buf_doc-line.price-rubl else buf_doc-line.price-base )
                              .
                     end.

                      if first-of( buf_trn-doc.cli-code ) then do:
                          if v-qnty <> 0 and v-sum  <> 0 then do:
                            find first buf_clients no-lock where
                                       buf_clients.obj-type = buf_trn-doc.cli-type and
                                       buf_clients.obj-code = buf_trn-doc.cli-code
                                       no-error .
                            if available buf_clients then  v-cli = v-cli + buf_clients.obj-name  + "," .
                          end.
                      end.
                  end.
                  if not( v-qnty = 0 and quantity = 0 and quantity2 = 0) then do:
                  create temp-str .
                  assign
                      temp-str.np             = buf_shift-obj.shift-name
                      temp-str.date-sm        = string (buf_shift-obj.shift-date, "99/99/99")  + " Смена " + string (buf_shift-obj.shift-name)
                      temp-str.gds-name       = tt-gds-list.gds-name
                      temp-str.b-code         = tt-gds-list.gds-code
                      temp-str.ostatok-qnty-start =  quantity
                      temp-str.ostatok-qnty-end   =  quantity2
                      temp-str.ostatok-sum-start  = round((if var-report-r-b = "rubl":u then coast_r else coast_v )  / quantity   , 2)
                      temp-str.ostatok-sum-end    = round((if var-report-r-b = "rubl":u then coast_r2 else coast_v2) / quantity2  , 2)
                      temp-str.prih-qnty   = v-qnty
                      temp-str.prih-sum    = round( v-sum  / v-qnty   , 2 )
                      temp-str.rash-qnty   = (temp-str.ostatok-qnty-end - temp-str.ostatok-qnty-start - temp-str.prih-qnty) * ( - 1 )
                      temp-str.cli-name    = v-cli
                      no-error .
                      if buf_shift-obj.status_   <> {&sht-closed} then
                         temp-str.date-sm        = string (buf_shift-obj.shift-date, "99/99/99")  + " Смена " + string (buf_shift-obj.shift-name) + " текущая"
                         .

                      if temp-str.ostatok-sum-start = ? then temp-str.ostatok-sum-start = 0 .
                      if temp-str.ostatok-sum-end   = ? then temp-str.ostatok-sum-end   = 0 .
                      if temp-str.prih-sum   = ? then temp-str.prih-sum   = 0 .



                  end.
         end.
  end.
  end. /* do */
 end procedure. /* make-tt */
 { rep/r-libmcr.i macr_excel         }
 { rep/ost-line.i yes yes }