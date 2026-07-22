block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-p-pl.p $
$Archive: rep/r-p-pl.p $

Отчет Сравнительный анализ цен поставщиков

Автор: Чернова Светлана Александровна
Дата создания: 09/12/05
Author: Svetlana Chernova
Creation date: 09/12/05

*/

define input parameter radpost as integer no-undo .
define input parameter p-null as logical   no-undo .
/*
выбор поставщика
"все", 1,
"Выборочно", 2
*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-p-pl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-p-pl.p $":U .
define variable vss-description as character no-undo init "Отчет Сравнительный анализ цен поставщиков".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ cmp/r-page1.i  }
{ cmp/breakstr.i }
{ rep/r-cliprp.i def }
{ gbl/paramls.i  }
{ rep/f-fdec.i   }
{ rep/rep-bt.i   }

define variable parhost-code as integer   no-undo .
parhost-code = v-cntxt-host-code-obj.

define variable kol-post as integer   no-undo .

def SHARED temp-table g#post-f NO-UNDO
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    field grp-code like ub.clients.grp-code
    field grp-name like ub.clients.grp-name
    field lvl-num like  ub.cli-grp.lvl-num
    INDEX pi IS UNIQUE PRIMARY obj-type obj-code
    INDEX p1  obj-name
    .
    if radpost <> 1 and not can-find (first g#post-f) then do:
        message "Не выбран ни один ПОСТАВЩИК ! " view-as alert-box error .
        return error.
    end.
define variable v-kol-col as integer   no-undo .
v-kol-col = 0.
    for each g#post-f :
       v-kol-col =v-kol-col + 1 .
    end.
if v-kol-col > 256 then do:
   message 'Разрешено выводить не более 256 колонок. Очень большое количество поставщиков' v-kol-col .
   return .
end.
    if not can-find (first gds-list) then do:
        message "Не выбран ни один товар !" view-as alert-box error .
        return error.
    end.


define buffer bf_cli-gds  for ub.cli-gds .
define buffer bf_doc-line for ub.doc-line.
define buffer buf_cli-post for ub.clients.

define variable v-price-rubl as decimal decimals 2  no-undo .
define variable v-price-cli  as decimal   no-undo .
define variable v-goods as logical   no-undo .

define temp-table tt-temp no-undo
field cli-code   as integer
field cli-type   as character
field gds-code   as integer
field price-rubl  as decimal decimals 2 format ">>>>>>>>>>>>9.99"
field price-cli   as decimal
index cli-gds cli-code cli-type gds-code
.

CASE radpost:
  when 1 then do:
    _gds-list:
    for each gds-list,
        each bf_cli-gds where
             bf_cli-gds.artic = gds-list.artic
         AND bf_cli-gds.prod-type = gds-list.prod-type
         AND bf_cli-gds.prod-code = gds-list.prod-code
         AND bf_cli-gds.host-code = parhost-code:
      if bf_cli-gds.cli-type = {&shop}
      or bf_cli-gds.cli-type = {&stock} then NEXT _gds-list.
      assign
      v-price-cli = bf_cli-gds.price-cli
      .
      find first bf_doc-line where bf_doc-line.doc-code  = bf_cli-gds.in-code   and
                                  bf_doc-line.artic     = bf_cli-gds.artic     and
                                  bf_doc-line.prod-type = bf_cli-gds.prod-type and
                                  bf_doc-line.prod-code = bf_cli-gds.prod-code no-lock no-error.
      if available bf_doc-line
      and bf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh}
      and bf_doc-line.status_ = {&fact}
      then do:
        v-price-rubl = bf_doc-line.price-rubl .
        create tt-temp.
        assign
          tt-temp.cli-code   = bf_cli-gds.cli-code
          tt-temp.cli-type   = bf_cli-gds.cli-type
          tt-temp.gds-code   = gds-list.gds-code
          tt-temp.price-rubl = v-price-rubl
          tt-temp.price-cli  = v-price-cli
        .
        find first g#post-f  where
                  g#post-f.obj-type = bf_cli-gds.cli-type
            AND  g#post-f.obj-code = bf_cli-gds.cli-code no-error .
        if not available g#post-f then do:
          find first buf_cli-post no-lock where
                    buf_Cli-post.obj-type = bf_cli-gds.cli-type
                AND buf_Cli-post.obj-code = bf_cli-gds.cli-code no-error .
          create g#post-f.
          assign
          g#post-f.obj-type = bf_cli-gds.cli-type
          g#post-f.obj-code = bf_cli-gds.cli-code
          g#post-f.obj-name = (if available buf_cli-post then buf_cli-post.obj-name else '':U)
          kol-post = kol-post + 1
          .
        end.
      end.
    end. /*for each gds-list*/
  end. /*when 1 - все*/
  when 2  or when 3 then do:
    for each g#post-f :
      kol-post = kol-post + 1.
      for each gds-list :
        v-price-rubl = 0.
        v-goods = false .
        v-price-cli = 0 .
        find first bf_cli-gds where bf_cli-gds.cli-code  = g#post-f.obj-code
                                and bf_cli-gds.cli-type  = g#post-f.obj-type
                                and bf_cli-gds.host-code = parhost-code
                                and bf_cli-gds.artic     = gds-list.artic
                                and bf_cli-gds.prod-code = gds-list.prod-code
                                and bf_cli-gds.prod-type = gds-list.prod-type no-lock no-error.
        if available bf_cli-gds then do:
          assign
            v-price-cli = bf_cli-gds.price-cli
            v-goods = true
            .
          find first bf_doc-line where bf_doc-line.doc-code  = bf_cli-gds.in-code   and
                                      bf_doc-line.artic     = bf_cli-gds.artic     and
                                      bf_doc-line.prod-type = bf_cli-gds.prod-type and
                                      bf_doc-line.prod-code = bf_cli-gds.prod-code no-lock no-error.
          if available bf_doc-line
          and bf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh}
          and bf_doc-line.status_ = {&fact}
          then do:
            v-price-rubl = bf_doc-line.price-rubl .
            create tt-temp.
            assign
              tt-temp.cli-code   = g#post-f.obj-code
              tt-temp.cli-type   = g#post-f.obj-type
              tt-temp.gds-code   = gds-list.gds-code
              tt-temp.price-rubl = v-price-rubl
              tt-temp.price-cli  = v-price-cli
            .

          end.
        end. /*if available bf_cli-gds then do:*/
      end.
    end.
  end. /*when 2 - выборочно*/
END CASE.




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
def buffer This_Object for  ub.clients .

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


{ rep/r-sym.i }


define variable t-1 as character no-undo .
define variable t-2 as character no-undo .
define variable t-3 as character no-undo .
define variable t-4 as character no-undo .
define variable t-5 as character no-undo .

DEFINE FRAME plan-menu
    HEADER
    string( "Лист " + string( PAGE-NUMBER(OutStream) , ">>>>9") ) AT 80 format "X(13)" SKIP
    UndLine format "X(80)" AT 1
    with width {&DOS_CW} down stream-io use-text NO-UNDERLINE  NO-BOX no-labels.

  if session:set-wait-state("compiler") then.

  if kol-post >= 6 then do:
    { cmp/open-out.i STREAM OutStream " " {&LS_PS_A4} }
  end.
  else do:
    { cmp/open-out.i STREAM OutStream " " {&CS_PS} }
  end.
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
  /* по строкам -------------------------------------------------------------------------------------------- */
  for each gds-list :
    run print-line in this-procedure .
  end.
  run print-all-itog in this-procedure .
  /* ... Подвал. --- */
  run on-same-page in this-procedure (input 3) .
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
        ,input "2,3,4"
        ) .


  run end-proc in this-procedure .
define variable v-user-action as character no-undo .
define variable v-printed as logical   no-undo .
define variable DisabledOptions as integer   no-undo .



  if kol-post >= 9 then do:
     DisabledOptions = 1 .
  end.
  else do:
    if kol-post >= 6
      then DisabledOptions = 8 .
      else  DisabledOptions = 0 .
  end.


run gbl/prnfilen.w
  (input  ""
  ,input  DisabledOptions
  ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
  ,input 7
  ,output v-user-action
  ,output v-printed
  ) .

if radpost = 1 then do:
/*если опция все - сотрем таблицу которую создали чтобы она не мешела еще раз запустить отчет */
  for each g#post-f:
    delete g#post-f.
  end.
end.

/* *************************************************************************************************** */
procedure print-line :
  do on error undo, return error return-value :

  define variable v-all-null as logical   no-undo .
  /* проверка на пустые строки */
  v-all-null = true  .
  if p-null = false then do:
      for each g#post-f :
            find first tt-temp where
                  tt-temp.cli-code = g#post-f.obj-code and
                  tt-temp.cli-type = g#post-f.obj-type and
                  tt-temp.gds-code = gds-list.gds-code no-error .
            if available tt-temp then do:
                  if tt-temp.price-rubl <> 0 then  v-all-null = false .
            end.
      end.
      if v-all-null = true then return .
  end.



  assign
     Lines_Counter = Lines_Counter + 1
    .

  if line-counter( OutStream ) + 2 > page-size( OutStream ) then do:
     page stream OutStream.
     PUT STREAM OutStream UNFORMATTED
         string( "Лист " + string( PAGE-NUMBER(OutStream) , ">>>>9") ) AT 100 format "X(13)" SKIP .
     run print-1 in this-procedure.
     end.

  if line-counter( OutStream ) < Tmp_Counter then
    assign
    .

  assign
    Tmp_Counter  = line-counter( OutStream )
    num-ln = num-ln + 1
  .

  if line-counter( OutStream ) + j > page-size( OutStream ) then  PAGE STREAM OutStream.


PUT STREAM OutStream UNFORMATTED
    sym1                format "X(1)" space(0)
    string(gds-list.gds-code)    format "X(10)" space(0)
    sym2                format "X(1)" space(0)
    string(gds-list.gds-name)    format "X(30)" space(0)
    sym3                format "X(1)" space(0)
    string(gds-list.unit-base)    format "X(3)" space(0)

.
    num#col# = 1.
    num#str# = num#str# + 1.
    run macr_excel_char in this-procedure(gds-list.gds-code  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char in this-procedure(gds-list.gds-name  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char in this-procedure(gds-list.unit-base  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .

 for each g#post-f :
      find first tt-temp where
            tt-temp.cli-code = g#post-f.obj-code and
            tt-temp.cli-type = g#post-f.obj-type and
            tt-temp.gds-code = gds-list.gds-code no-error .
      if available tt-temp then do:
        PUT STREAM OutStream UNFORMATTED
            sym1                          format "X(1)" space(0)
            string(tt-temp.price-rubl,">>>>>>>>>>>>9.99")    format "X(16)" space(0)
        .
          run macr_excel_dec in this-procedure(tt-temp.price-rubl  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
      end.
      else do:
          PUT STREAM OutStream UNFORMATTED
              sym1                format "X(1)" space(0)
              " "                 format "X(16)" space(0)

          .
          run macr_excel_dec in this-procedure(0 , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
      end.
 end.
  PUT STREAM OutStream UNFORMATTED
      sym2                format "X(1)" space(0)
      skip
  .

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

/* ---------------- Создание заголовка :--------------------------------------------------------------------------- */
PUT STREAM OutStream UNFORMATTED
space(1)
   ReportNAme skip
   "по фирме "  ub.clients.obj-name skip
   "Дата составления " + cur-time-date()  skip
      .

  define variable i as integer no-undo .
  Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
    PUT STREAM OutStream UNFORMATTED  Entry(i,ReportHeader,chr(10))  AT 1 format "X(90)" SKIP.
  End.


    num#str# = 1.
    num#col# = 1.
    run macr_excel_char in this-procedure( Reportname , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_excel_char in this-procedure( "по фирме " + CAPS( ub.clients.obj-name)   , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_excel_char in this-procedure( ReportHeader , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_excel_char in this-procedure("Дата составления " + cur-time-date()   , num#str# , num#col#   ) .

/* шапка */
    num#str# = num#str# + 1.
    run macr_excel_char in this-procedure("Код"  , num#str# , num#col#   ) .    run macr_cell_size ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 2.
    run macr_excel_char in this-procedure("Наименование"  , num#str# , num#col#   ) .  run macr_cell_size ( 30 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 3.
    run macr_excel_char in this-procedure("Ед.Изм"  , num#str# , num#col#   ) . run macr_cell_size ( 3 , ? , num#str# , num#col# , ?, ? ) .
    for each g#post-f :
      num#col# = num#col# + 1.
      run macr_excel_char in this-procedure( "(" + string(g#post-f.obj-code) + " " + g#post-f.obj-type + ") " + g#post-f.obj-name , num#str# , num#col#   ) .
      run macr_cell_size in this-procedure ( 15 , ? , num#str# , num#col# , ?, ? ) .
    end.

  run print-1 in this-procedure .


    run macr_cell_format in this-procedure
    ( 10    ,    /* p-size     */
      true  ,    /* p-bold     */
      false  ,   /* p-italic   */
      ?    ,     /* p-color-bg */
      1 , /* p-row      */
      1 ,        /* p-col      */
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


    /* ... конец создания Подвал. --- */
  end.
end procedure. /* PrintPodval */



PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( OutStream ) then return .
  if line-counter( OutStream ) + p-line-number > page-size( OutStream ) then  page stream OutStream .
end procedure. /* on-same-page */

procedure print-1 :

  do
  on error undo, return error return-value
  :
    PUT STREAM OutStream UNFORMATTED  fill("-",11)  AT 1 format "X(11)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",31)  format "X(31)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",4)  format "X(4)" .
    for each g#post-f :
      PUT STREAM OutStream UNFORMATTED fill("-",17) format "X(17)" .
    end.
    PUT STREAM OutStream UNFORMATTED  skip .

    PUT STREAM OutStream UNFORMATTED  ":Код"  AT 1 format "X(11)" .
    PUT STREAM OutStream UNFORMATTED  ":Наименование"  format "X(31)" .
    PUT STREAM OutStream UNFORMATTED  ":Е.И"  format "X(4)" .

    for each g#post-f :
      PUT STREAM OutStream UNFORMATTED  ":" + string(g#post-f.obj-code) + " " + g#post-f.obj-type + " " + g#post-f.obj-name  format "X(17)" .
    end.
    PUT STREAM OutStream UNFORMATTED  skip .

    PUT STREAM OutStream UNFORMATTED  fill("-",11)  AT 1 format "X(11)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",31)  format "X(31)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",4)  format "X(4)" .
    for each g#post-f :
      PUT STREAM OutStream UNFORMATTED fill("-",17) format "X(17)" .
    end.
    PUT STREAM OutStream UNFORMATTED  skip .

  end.

end procedure. /* print-1 */

{ rep/r-libmcr.i macr_excel         }