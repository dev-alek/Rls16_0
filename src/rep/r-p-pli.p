block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-p-pli.p $
$Archive: rep/r-p-pli.p $

Отчет Сравнительный анализ цен поставщиков

Автор: Чернова Светлана Александровна
Дата создания: 09/12/05
Author: Svetlana Chernova
Creation date: 09/12/05

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-p-pli.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-p-pli.p $":U .
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

/* Параметры  */
DEFINE INPUT PARAMETER p-iType-Rep as INTEGER NO-UNDO.

/*  */
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
    if not can-find (first g#post-f) then do:
        message "Не выбран ПОСТАВЩИК ! " view-as alert-box error .
        return error.
    end.
    if not can-find (first gds-list) then do:
        message "Не выбран ни один товар !" view-as alert-box error .
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


define buffer bf_cli-gds  for ub.cli-gds .
define buffer bf_doc-line for ub.doc-line.

define variable v-price-rubl as decimal decimals 2  no-undo .
define variable v-price-cli  as decimal   no-undo .
define variable v-goods as logical   no-undo .

define temp-table tt-temp no-undo
field gds-code   as integer
field price-rubl  as decimal
field price-cli   as decimal
field fact-date   as date
   FIELD Num         as INTEGER
   index pi
         gds-code
         fact-date
         price-rubl
   INDEX i2
         gds-code
         Num
.



define buffer buf_tt for tt-temp .


CASE p-iType-Rep:
     WHEN 1 THEN DO:
        RUN Load-From-Trn-Doc.
     END.
     WHEN 2 THEN DO:
        RUN Load-From-Spec.
     END.
     OTHERWISE DO:
        MESSAGE
            PROGRAM-NAME(1) ":" SKIP
            "Неверно задан параметр p-iType-Rep=" p-iType-Rep SKIP
            VIEW-AS ALERT-BOX INFO BUTTONS OK.
        RETURN.
     END.
END CASE.

define variable kk as integer   no-undo .

define variable v-old as decimal   no-undo .
define variable v-code as integer   no-undo .
v-old = 0.
v-code = 0.

for each buf_tt where break by buf_tt.gds-code
                            by buf_tt.fact-date :
    if v-old = buf_tt.price-rubl and  v-code = buf_tt.gds-code
       then do:
          v-old = buf_tt.price-rubl.
          v-code   = buf_tt.gds-code.
          delete buf_tt .
       end.
       else do:
          v-old = buf_tt.price-rubl.
          v-code   = buf_tt.gds-code.
       end.
end.

for each gds-list :
 kk = 0.
    for each buf_tt where buf_tt.gds-code = gds-list.gds-code break by buf_tt.fact-date :
      kk = kk + 1.
    end.
    if kk > kol-post then kol-post = kk.
end.



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

  if kol-post >= 3 then do:
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
    run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
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

  run end-proc  in this-procedure.
define variable v-user-action as character no-undo .
define variable v-printed as logical   no-undo .
define variable DisabledOptions as integer   no-undo .



  if kol-post >= 5 then do:
     DisabledOptions = 1 .
  end.
  else do:
    if kol-post >= 3
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

/* *************************************************************************************************** */

/***********
   Загрузка данных отчета из истории спецификации
***********/
PROCEDURE Load-From-Spec:
   /*  */
   DEFINE BUFFER g#post-f         FOR g#post-f.
   DEFINE BUFFER buf_c-Spec       FOR ub.c-Contract-Specif.
   DEFINE BUFFER buf_Spec         FOR ub.Contract-Specif.
   DEFINE BUFFER buf_Contract     FOR ub.Contract.
   DEFINE BUFFER gds-list         FOR gds-list.
   /*  */
   DEFINE VARIABLE iNum    as INTEGER  NO-UNDO INITIAL 0.
   DEFINE VARIABLE lHist   as LOGICAL  NO-UNDO INITIAL FALSE.
   DEFINE VARIABLE dPrice  as DECIMAL  EXTENT 3 NO-UNDO INITIAL 0.


   /*  Пробуем выборку сделать так !  */
   FOR EACH gds-list NO-LOCK:
       /* Сброс счетчика !!!  */
       ASSIGN
          iNum = 0.
       /*  */
       Label-Spec:
       FOR EACH buf_c-Spec WHERE
                buf_c-Spec.gds-code    = Gds-list.gds-code
            AND buf_c-Spec.Corr-date  >= x-Date-Start
            AND buf_c-Spec.Corr-date  <= x-Date-end
           NO-LOCK,
           FIRST buf_Contract WHERE
                 buf_Contract.Host-code       = buf_c-Spec.Host-code
             AND buf_Contract.Contract-code   = buf_c-Spec.Contract-num
           NO-LOCK:
           /*  */
           /* Проверка поставщика (Контрагента) */
           if NOT CAN-FIND(FIRST g#post-f WHERE
                                 g#post-f.obj-Type = buf_Contract.Cli-type
                             AND g#post-f.obj-Code = buf_Contract.Cli-Code
                             NO-LOCK) THEN DO:

              NEXT Label-Spec.
           END.

           /* Снимаем суммы со следующей записи  */
           RUN  Get-next-rec-Spec (
                buf_c-Spec.Host-code,
                buf_c-Spec.Contract-num,
                buf_c-Spec.Gds-code,
                buf_c-Spec.Corr-date,
                buf_c-Spec.Corr-time,
                OUTPUT dPrice,
                OUTPUT lHist
                ).

           /* Проверки пройдены - пишем в tt-Temp */
           RUN Create-tt-Temp in THIS-PROCEDURE(
               INPUT-OUTPUT iNum,
               Gds-list.Gds-Code,
               buf_c-Spec.Corr-date,
               (IF dPrice[3] = 0 THEN dPrice[2] ELSE dPrice[3]),
               dPrice[2]
               ).
       END.  /* Label-spec */

   END. /* gds-list  */
   /*  */
   RETURN.
END PROCEDURE.


/* Получить суммы из следующей по номеру записи   */
PROCEDURE Get-next-rec-Spec:
   DEFINE INPUT PARAMETER iHost-code     as INTEGER NO-UNDO.
   DEFINE INPUT PARAMETER iContract-num  as INTEGER NO-UNDO.
   DEFINE INPUT PARAMETER iGds-code      as INTEGER NO-UNDO.
   DEFINE INPUT PARAMETER dtDate         as DATE    NO-UNDO.
   DEFINE INPUT PARAMETER iTime          as INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER dPrice        as DECIMAL EXTENT 3 NO-UNDO INITIAL 0.
   DEFINE OUTPUT PARAMETER lHist         as LOGICAL NO-UNDO INITIAL FALSE.
   /*  */
   DEFINE BUFFER buf_c-Spec       FOR ub.c-Contract-Specif.
   DEFINE BUFFER buf_Spec         FOR ub.Contract-Specif.
   /*  */
   FIND FIRST buf_c-Spec WHERE
              buf_c-Spec.Host-code     = iHost-code
          AND buf_c-Spec.Contract-num  = iContract-num
          AND buf_c-Spec.Gds-code      = iGds-code
          AND (buf_c-Spec.Corr-date    = dtDate AND buf_c-Spec.corr-time > iTime
               OR buf_c-Spec.Corr-date > dtDate
              )
          NO-LOCK NO-ERROR.
   IF AVAILABLE buf_c-Spec THEN DO:
      ASSIGN
         lHist       = TRUE
         dPrice [1]  = buf_c-Spec.price-base
         dPrice [2]  = buf_c-Spec.Price-Cli
         dPrice [3]  = buf_c-Spec.Price-rubl
         .
      RETURN.
   END.

   /* Если в History данные не найдены - возвращаем из спецификации
      Просто считаем что они тама всегда есть   */
   FIND FIRST buf_Spec WHERE
              buf_Spec.Host-code     = iHost-code
          AND buf_Spec.Contract-num  = iContract-num
          AND buf_Spec.Gds-code      = iGds-code
        NO-LOCK NO-ERROR.
   IF AVAILABLE buf_Spec THEN DO:
      ASSIGN
         dPrice [1]  = buf_Spec.price-base
         dPrice [2]  = buf_Spec.Price-Cli
         dPrice [3]  = buf_Spec.Price-rubl
         .
      RETURN.
   END.
   /*  */
   RETURN.
END PROCEDURE.


PROCEDURE Create-tt-Temp:
   DEFINE INPUT-OUTPUT PARAMETER iNum  as INTEGER NO-UNDO.
   DEFINE INPUT PARAMETER iGds-code    as INTEGER NO-UNDO.
   DEFINE INPUT PARAMETER dtFact-Date  as DATE    NO-UNDO.
   DEFINE INPUT PARAMETER dPrice-rubl  as DECIMAL NO-UNDO.
   DEFINE INPUT PARAMETER dPrice-cli   as DECIMAL NO-UNDO.
   /*  */
   DEFINE BUFFER tt-Temp FOR tt-Temp.
   /*  */
   ASSIGN
      iNum = iNum + 1.
   /*  */
   FIND FIRST tt-Temp WHERE
              tt-Temp.Gds-code   = iGds-code
          AND tt-Temp.Fact-date  = dtFact-date
          AND tt-Temp.Price-rubl = dPrice-rubl
        NO-LOCK NO-ERROR.
   if NOT AVAILABLE tt-Temp THEN DO:
      CREATE tt-Temp.
      ASSIGN
         tt-Temp.Num        = iNum
         tt-Temp.Gds-code   = iGds-code
         tt-Temp.Fact-date  = dtFact-date
         tt-Temp.Price-rubl = dPrice-rubl
         tt-Temp.Price-rubl = dPrice-cli
         .
   END.
   /*  */
   RETURN.
END PROCEDURE.


/***********
   Загрузка данных отчета из накладных
***********/
PROCEDURE Load-From-Trn-doc:
/*  */
DEFINE BUFFER trn-doc FOR ub.Trn-doc.
/*  */
for each g#post-f :
for each trn-doc no-lock where
         trn-doc.fact-date <= x-date-end  and
         trn-doc.fact-date >= x-date-start and
         trn-doc.host-code  = v-cntxt-host-code-obj  and
         trn-doc.ext-doc-type  = {&TDEDT_Pri_Vnesh}  and
         trn-doc.status_       = {&fact} and
         trn-doc.cli-code   = g#post-f.obj-code and
         trn-doc.cli-type   = g#post-f.obj-type

         :

  for each gds-list :
    v-price-rubl = 0.
    v-goods = false .
    v-price-cli = 0 .
      find first bf_doc-line where bf_doc-line.doc-code  = trn-doc.doc-code   and
                                   bf_doc-line.artic     = gds-list.artic     and
                                   bf_doc-line.prod-type = gds-list.prod-type and
                                   bf_doc-line.prod-code = gds-list.prod-code no-lock no-error.
      if available bf_doc-line then do:
        v-price-rubl = bf_doc-line.price-rubl .
        find first tt-temp where
          tt-temp.gds-code   = gds-list.gds-code and
          tt-temp.price-rubl = v-price-rubl      and
          tt-temp.fact-date  = trn-doc.fact-date no-error .
          if not available tt-temp then do:
              create tt-temp.
              assign
                tt-temp.gds-code   = gds-list.gds-code
                tt-temp.price-rubl = v-price-rubl
                tt-temp.price-cli  = v-price-cli
                tt-temp.fact-date  = trn-doc.fact-date
              .
          end.
      end.
  end.
end.
end.
/*  */
RETURN.
END PROCEDURE.




procedure print-line :
  do on error undo, return error return-value :
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

    for each buf_tt where buf_tt.gds-code = gds-list.gds-code break by buf_tt.fact-date :
            PUT STREAM OutStream UNFORMATTED
                sym1                          format "X(1)" space(0)
                string(buf_tt.price-rubl,">>>>>>9.99")    format "X(11)" space(0)
                string(buf_tt.fact-date, "99/99/99")     format "X(8)"  space(0)
            .
            /*  */
            run macr_excel_cell_format in this-procedure(
                buf_tt.price-rubl,
                num#str#,
                num#col#,
                "0.00"
                ).

            assign    num#col# = num#col# + 1 .
              run macr_excel_char in this-procedure("(" + string(buf_tt.fact-date,"99/99/99") + ")"   , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
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
    repeat i = 1 to kol-post :
      num#col# = num#col# + 1.
      run macr_excel_char in this-procedure( "Цена" , num#str# , num#col#   ) .
      run macr_cell_size  in this-procedure( 10 , ? , num#str# , num#col# , ?, ? ) .
      num#col# = num#col# + 1.
      run macr_excel_char in this-procedure( "(Дата)" , num#str# , num#col#   ) .
      run macr_cell_size in this-procedure( 10 , ? , num#str# , num#col# , ?, ? ) .

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
    repeat i = 1 to kol-post :
      PUT STREAM OutStream UNFORMATTED fill("-",20) format "X(20)" .
    end.
    PUT STREAM OutStream UNFORMATTED  skip .

    PUT STREAM OutStream UNFORMATTED  ":Код"  AT 1 format "X(11)" .
    PUT STREAM OutStream UNFORMATTED  ":Наименование"  format "X(31)" .
    PUT STREAM OutStream UNFORMATTED  ":Е.И"  format "X(4)" .

    repeat i = 1 to kol-post :
      PUT STREAM OutStream UNFORMATTED  ":Цена        (Дата)"  format "X(20)" .
    end.
    PUT STREAM OutStream UNFORMATTED  skip .

    PUT STREAM OutStream UNFORMATTED  fill("-",11)  AT 1 format "X(11)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",31)  format "X(31)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",4)  format "X(4)" .
    repeat i = 1 to kol-post :
      PUT STREAM OutStream UNFORMATTED fill("-",20) format "X(20)" .
    end.
    PUT STREAM OutStream UNFORMATTED  skip .

  end.

end procedure. /* print-1 */

{ rep/r-libmcr.i macr_excel         }