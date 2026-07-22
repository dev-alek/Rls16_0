block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-o-chkv.p $
$Archive: cus/r-o-chkv.p $

Отчет Aннуляция чеков и Возврат товара ОБЩИЙ

Автор: Чернова Светлана Александровна
Дата создания: 07/03/07
Author: Svetlana Chernova
Creation date: 07/03/07

*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-o-chkv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-o-chkv.p $":U .
define variable vss-description as character no-undo init "Отчет Aннуляция чеков и Возврат товара ОБЩИЙ".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ cmp/r-page1.i  }
{ cmp/breakstr.i }
{ rep/r-cliprp.i def }
{ gbl/paramls.i  }
{ rep/f-fdec.i   }
{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
{ rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */
{ ref/grpobj.i }
{ rep/rep-bt.i }
{ trg/factord.i }



define temp-table tt-temp no-undo
field pay-desk    as integer       /* № кассы      */
field sum-rubl-ost    as decimal   /* остаток      */
field cashier as integer          /* код кассира  */
field psn-code as integer          /* код кассира  */
field psn-name    as char          /* раб кассир   */
field doc-code    as character     /* номер чека   */
field doc-type    as character     /*              */
field fact-date   as date          /* дата операции   чека*/
field fact-time   as char          /* время операции  чека*/
field sum-rubl    as decimal       /* сумма операции  чека*/
field obj-code    as int           /* магазин */
field obj-type    as char
field bef-vid     as char
field aft-vid     as char
index pi
  obj-code
  obj-type
  pay-desk
  cashier
index pi-2
  pay-desk
.
define buffer kass-f for tt-temp  .
define buffer inkass for tt-temp  .
define buffer perev  for tt-temp  .
define buffer kass-d for tt-temp  .
define buffer kass   for tt-temp  .
define buffer prsn   for tt-temp  .

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
define buffer This_Object for  clients .

define variable num-ln as integer   no-undo .
define variable vv-sum   as decimal   no-undo .
define variable vv-count as decimal   no-undo .

define variable i as int no-undo.
define variable j as int no-undo.
define variable Counter1 as integer init 0  no-undo .

define variable LineBuf       as char    no-undo.
define variable Line       as char    no-undo.
define variable UndLine    as char    no-undo.

define variable Lines_Counter as   int  init 0  no-undo.
define variable Tmp_Counter   as   int  init 0  no-undo.

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


define variable v-shap as character no-undo .

FUNCTION get-cash-pay RETURNS CHARACTER
  ( input parpay-code as integer, parcurr-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE varwth-code like ub.wealth.wth-code no-undo.
DEFINE VARIABLE varwth-name like ub.wealth.wth-name no-undo.

FIND FIRST ub.cash-pay No-LOCK WHERE
                    ub.cash-pay.cdpay-code = parpay-code AND
                    ub.cash-pay.curr-code = parcurr-code No-ERROR.
if available cash-pay then do:
  varwth-code = ub.cash-pay.wth-code.
  if varwth-code > 0 then do:
      FIND FIRST ub.wealth No-LOCK WHERE
                      ub.wealth.wth-code = varwth-code No-error.
      if available ub.wealth then do:
        assign
        varwth-code =ub.wealth.wth-code
        varwth-name = ub.wealth.wth-name
        .
        return ub.cash-pay.obj-name.
      end.
      else do:
        assign
        varwth-code = 0
        varwth-name = "Неопознанная МЦ"
        .
        RETURN ub.cash-pay.obj-name.   /* Function return value. */
      end.
  end.
  else do:
    assign
    varwth-code = 0
    varwth-name = "Неопознанная МЦ"
    .
    RETURN ub.cash-pay.obj-name .   /* Function return value. */
  end.
end.
assign
varwth-code = 0
varwth-name = '':U
.
RETURN "Неопознанная оплата".   /* Function return value. */
END FUNCTION.




DEFINE FRAME plan-menu
    HEADER
    string( "Лист " + string( PAGE-NUMBER(OutStream) , ">>>>9") ) AT 80 format "X(13)" SKIP
    UndLine format "X(80)" AT 1
    with width {&DOS_CW} down stream-io use-text NO-UNDERLINE  NO-BOX no-labels.

  if session:set-wait-state("compiler") then.
    { cmp/open-out.i STREAM OutStream " " {&LS_PS_A4} }
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
    Output stream Macr_Excel  close .
    num#str# = 0 .
    run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
    output stream macr_excel to value(v-file-name)   .
    v-ind = v-ind + 1.


  find clients      where clients.obj-type     = {&cmp}            and clients.obj-code      = v-cntxt-host-code-obj no-lock .
  run PrintTitul in this-procedure .
  run make-tt.
  /* по строкам -------------------------------------------------------------------------------------------- */
  for each obj-list :
      run print-obj.
          run print-line .
      run print-obj-itog.
  end.
  /*----------------------------------------------------------*/
  run print-all-itog in this-procedure .
  /* ... Подвал. --- */
  run on-same-page in this-procedure (input 3) .
  run PrintPodval in this-procedure .
  run paramls-write in this-procedure
    ( input "file"
    , input string(v-ind)
    , input v-file-name
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
        ,input "1,3,4,6,7,8,9,10"
        ) .

  /* run paramls-show-temp-table. */

  run end-proc .
  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  DisabledOptions = 8 .

  run gbl/prnfilen.w
    (  input  ""
     , input  DisabledOptions
     , input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
     , input  7
     , output v-user-action
     , output v-printed
    )
    .

/* *************************************************************************************************** */
procedure pl :

  do
  on error undo, return error return-value
  :
  assign
     Lines_Counter = Lines_Counter + 1
    .

  if line-counter( OutStream ) + 2 > page-size( OutStream ) then do:
     run p-line.
     page stream OutStream.
     PUT STREAM OutStream UNFORMATTED
         string( "Лист " + string( PAGE-NUMBER(OutStream) , ">>>>9") ) AT 100 format "X(13)" SKIP .
     run print-1.
     end.

  if line-counter( OutStream ) < Tmp_Counter then
    assign
    .

  assign
    Tmp_Counter  = line-counter( OutStream )
    num-ln = num-ln + 1
  .

  if line-counter( OutStream ) + j > page-size( OutStream ) then  PAGE STREAM OutStream.

  end.

end procedure. /* pl */

procedure print-line :
do on error undo, return error return-value :
/*-----------------------------------------------
tt-temp.pay-desk  = buf_chk-doc.pay-desk
tt-temp.sum-rubl-ost = 0
tt-temp.psn-code  = buf_chk-doc.cashier-psn-code
tt-temp.psn-name  = if available  buf_psn-clients then buf_psn-clients.obj-name else ""
tt-temp.fact-date = buf_chk-doc.chk-date
tt-temp.fact-time = string ( buf_chk-doc.chk-time , "hh:mm" )
tt-temp.obj-code  = buf_chk-doc.obj-code
tt-temp.obj-type  = buf_chk-doc.obj-type
tt-temp.doc-code  = buf_chk-doc.doc-code
tt-temp.doc-type  = buf_chk-doc.chk-type
tt-temp.bef-vid   = ""
tt-temp.aft-vid   = ""
tt-temp.sum-rubl  = 0
"+---------------------------------------------------------------------------------------------------------------------------------------------+" skip .
":№ кассы:  ФИО кассира   : Остаток      :   Кассовый фонд    :     Инкассация      :                    Перевод оплаты                        :" skip .
":       :                : денежных     :-----------:--------+---------:-----------+-------------------:----------------:---------:-----------:" skip .
":       :                : средств      : Дата и    :  Сумма :  Дата и :  Сумма    :       С чего      :  На чего       :  Дата и :  Сумма    :" skip .
":   7   :          16    :      14      : время 11  :   8    :  время  :           :       19          :       16       :  время  :           :" skip .
"+---------------------------------------------------------------------------------------------------------------------------------------------+" skip .
*/

define variable v-1 as char  no-undo .
define variable v-2 as char  no-undo .
define variable v-3 as char  no-undo .
define variable max-i as integer   no-undo .
define variable ii as integer   no-undo .


for each kass where
         kass.obj-type = obj-list.obj-type and
         kass.obj-code = obj-list.obj-code
         break by kass.pay-desk :

    if first-of ( kass.pay-desk ) then do: /* по кассам */
        put stream outstream unformatted
            sym1                       format "x(1)" space(0)
            string(kass.pay-desk)      format "x(7)"
            sym2                       format "x(1)" space(0)
            string(kass.sum-rubl-ost)     format "x(14)"
            .
    num#col# = 1.
    num#str# = num#str# + 1.
    run macr_excel_char ( string(kass.pay-desk)    , num#str# , 1   ) . assign    num#col# = 2.
    run macr_excel_dec  (        kass.sum-rubl-ost , num#str# , 2   ) . assign    num#col# = 3 .

        for each prsn where prsn.pay-desk = kass.pay-desk and
                            prsn.obj-type = obj-list.obj-type and
                            prsn.obj-code = obj-list.obj-code
                            break by prsn.cashier :
            if first-of(prsn.cashier) then do: /* по кассирам */

              put stream outstream unformatted
                  sym1                          format "x(1)" space(0)
                  (if prsn.psn-name = "" then  string(prsn.psn-code) else string(prsn.psn-name))        format "X(16)" at 25
                  .
                run macr_excel_char (( if prsn.psn-name = "" then  "-"  else string(prsn.psn-name))   , num#str# , 3   ) . assign    num#col# = 4 .

                v-1 = "".
                v-2 = "".
                v-3 = "".
                for each tt-temp where
                        tt-temp.cashier  = prsn.cashier and
                        tt-temp.pay-desk = kass.pay-desk and
                        tt-temp.obj-type = obj-list.obj-type and
                        tt-temp.obj-code = obj-list.obj-code
                        break by tt-temp.fact-date by tt-temp.fact-time
                        :
                          case tt-temp.doc-type :
                              when string({&cd-fund})  then do:
                                v-1 = v-1 + tt-temp.doc-code + "," .
                              end.
                              when string({&encashment})  then do:
                                v-2 = v-2  + tt-temp.doc-code + "," .
                              end.
                              when string({&pay-transfer})  then do:
                                v-3 = v-3  + tt-temp.doc-code + "," .
                              end.
                          end case.
                end.

                v-1 = trim(v-1,",") .
                v-2 = trim(v-2,",") .
                v-3 = trim(v-3,",") .

define variable v-doc1 as character no-undo .
define variable v-doc2 as character no-undo .
define variable v-doc3 as character no-undo .
define variable v-kass-f-1  as character no-undo .
define variable v-kass-f-2  as character no-undo .
define variable v-inkass-1  as character no-undo .
define variable v-inkass-2  as character no-undo .
define variable v-tr-s  as character no-undo .
define variable v-tr-p  as character no-undo .
define variable v-tr-1  as character no-undo .
define variable v-tr-2  as character no-undo .
assign
  v-tr-1 = ""
  v-tr-2 = ""
  v-tr-s = ""
  v-tr-p = ""
  v-kass-f-1 = ""
  v-kass-f-2 = ""
  v-inkass-1 = ""
  v-inkass-2 = ""
.



          max-i = MAXIMUM ( num-entries(v-1,",") , num-entries(v-2,","),num-entries(v-3,",") ) .
                  repeat ii = 1 to max-i :
                  run pl .
                  v-doc1 = "" .
                  v-doc2 = "" .
                  v-doc3 = "" .
                  if ii <= num-entries(v-1,",") then v-doc1 = entry ( ii, v-1 ) no-error .
                  if ii <= num-entries(v-2,",") then v-doc2 = entry ( ii, v-2 ) no-error .
                  if ii <= num-entries(v-3,",") then v-doc3 = entry ( ii, v-3 ) no-error .

                  find first kass-f where kass-f.doc-code  = v-doc1 no-error .
                        if available kass-f then do:
                          v-kass-f-1 = substring( string(kass-f.fact-date),1,5) + " " + kass-f.fact-time.
                          v-kass-f-2 = string(kass-f.sum-rubl ).
                          end.
                          else
                          assign
                              v-kass-f-1 = ""
                              v-kass-f-2 = ""
                          .
                  find first inkass where inkass.doc-code  = v-doc2 no-error .
                        if available inkass then do:
                          v-inkass-1 = substring( string(inkass.fact-date),1,5) + " " + inkass.fact-time.
                          v-inkass-2 = string(inkass.sum-rubl ).
                          if v-inkass-1 = ? then v-inkass-1 = "" .
                          if v-inkass-2 = ? then v-inkass-2 = "" .

                          end.
                          else
                          assign
                              v-inkass-1 = ""
                              v-inkass-2 = ""
                          .

                  find first perev where perev.doc-code  = v-doc3 no-error .
                        if available perev then do:
                          v-tr-1 = substring( string(perev.fact-date),1,5) + " " + perev.fact-time.
                          v-tr-2 = string(perev.sum-rubl ).
                          v-tr-s = string(perev.bef-vid).
                          v-tr-p = string(perev.aft-vid).
                          end.
                          else
                          assign
                              v-tr-1 = ""
                              v-tr-2 = ""
                              v-tr-s = ""
                              v-tr-p = ""

                          .


                      if ii = 1 then do :
                          /* первая строка */
                          PUT STREAM OutStream UNFORMATTED
                              sym1       at 41
                              v-kass-f-1 format "X(11)"
                              sym2       format "X(1)" space(0)
                              v-kass-f-2  format "X(8)"
                              sym3       format "X(1)" space(0)
                              v-inkass-1 format "X(11)"
                              sym4       format "X(1)" space(0)
                              v-inkass-2  format "X(9)"
                              sym5                format "X(1)" space(0)
                              v-tr-s              format "X(19)"
                              sym9                format "X(1)"      space(0)
                              v-tr-p              format "X(16)"
                              sym10               format "X(1)"      space(0)
                              v-tr-1              format "X(11)"
                              sym11               format "X(1)"      space(0)
                              v-tr-2              format "X(9)"
                              sym12               format "X(1)"      space(0)
                              skip.
                              run macr_excel_char ( v-kass-f-1  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
                              run macr_excel_char ( v-kass-f-2  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
                              run macr_excel_char ( v-inkass-1  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
                              run macr_excel_char ( v-inkass-2  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
                              run macr_excel_char ( v-tr-s , num#str# , num#col#   )      . assign    num#col# = num#col# + 1 .
                              run macr_excel_char ( v-tr-p , num#str# , num#col#   )      . assign    num#col# = num#col# + 1 .
                              run macr_excel_char ( v-tr-1 , num#str# , num#col#   )      . assign    num#col# = num#col# + 1 .
                              run macr_excel_char ( v-tr-2 , num#str# , num#col#   )      . assign    num#col# = num#col# + 1 .
                      end.
                      else do:
                          /* все остальные */
                          PUT STREAM OutStream UNFORMATTED
                              sym1                format "X(1)" at 1
                              ""                  format "X(7)"
                              sym2                format "X(1)" space(0)
                              ""                  format "X(14)"
                              sym3                format "X(1)" space(0)
                              ""
                              sym4                format "X(1)"  at 41 space(0)
                              v-kass-f-1          format "X(11)"
                              sym5                format "X(1)"      space(0)
                              v-kass-f-2          format "X(8)"
                              sym6                format "X(1)"      space(0)
                              v-inkass-1          format "X(11)"
                              sym7                format "X(1)"      space(0)
                              v-inkass-2          format "X(9)"
                              sym8                format "X(1)"      space(0)
                              v-tr-s              format "X(19)"
                              sym9                format "X(1)"      space(0)
                              v-tr-p              format "X(16)"
                              sym10               format "X(1)"      space(0)
                              v-tr-1              format "X(11)"
                              sym11               format "X(1)"      space(0)
                              v-tr-2              format "X(9)"
                              sym12               format "X(1)"      space(0)
                              skip.
                              num#col# = num#col# + 3 .
                              run macr_excel_char ( v-kass-f-1  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
                              run macr_excel_char ( v-kass-f-2  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
                              run macr_excel_char ( v-inkass-1  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
                              run macr_excel_char ( v-inkass-2  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
                              run macr_excel_char ( v-tr-s , num#str# , num#col#   )      . assign    num#col# = num#col# + 1 .
                              run macr_excel_char ( v-tr-p , num#str# , num#col#   )      . assign    num#col# = num#col# + 1 .
                              run macr_excel_char ( v-tr-1 , num#str# , num#col#   )      . assign    num#col# = num#col# + 1 .
                              run macr_excel_char ( v-tr-2 , num#str# , num#col#   )      . assign    num#col# = num#col# + 1 .
                      end.
                      num#str# = num#str# + 1 .
                      num#col# = 1.
                  end.
            end.
        end.
    end.
end.

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
   "за период "  x-date-start " по " x-date-end  skip
   "Дата составления " + cur-time-date()  skip
    .

  define variable i as integer no-undo .
  Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
    PUT STREAM OutStream UNFORMATTED  Entry(i,ReportHeader,chr(10))  AT 1 format "X(90)" SKIP.
  End.

    num#str# = 1.
    num#col# = 1.
    run macr_excel_char ( Reportname , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_excel_char ( "по фирме " + CAPS( clients.obj-name)   , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_excel_char ( "За период " + string(x-date-start) + " по " +  string(x-date-end)  , num#str# , num#col# ) .
    num#str# = num#str# + 1.

    run macr_excel_char ( ReportHeader , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_excel_char ("Дата составления " + cur-time-date()   , num#str# , num#col#   ) .

/* шапка */
    num#str# = num#str# + 1.
    num#col# = 4.
    run macr_excel_char ("Кассовый фонд"  , num#str# , num#col#   ) . run macr_cell_size ( 16 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 6.
    run macr_excel_char ("Инкассация"  , num#str# , num#col#   ) . run macr_cell_size ( 20 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 8.
    run macr_excel_char ("Перевод оплаты"  , num#str# , num#col#   ) . run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .

     put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , num#str# , 4 , num#str# ,  5 ) + {&new-line}  +
       'BORDER(2,,,,,,0,0,0,0,0) '  + {&new-line} +
       'ALIGNMENT(7 , , 4 , 4 ,)'  + {&new-line}
       .
     put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , num#str# , 6 , num#str# ,  7 ) + {&new-line}  +
       'BORDER(2,,,,,,0,0,0,0,0) '  + {&new-line} +
       'ALIGNMENT(7 , , 4 , 4 ,)'  + {&new-line}
       .
     put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , num#str# , 8 , num#str# ,  11 ) + {&new-line}  +
       'BORDER(2,,,,,,0,0,0,0,0) '  + {&new-line} +
       'ALIGNMENT(7 , , 4 , 4 ,)'  + {&new-line}
       .


    put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , num#str# , 1 , num#str# ,  3 ) + {&new-line}  +
       'BORDER( 2, , , , , , , , , , ) '  + {&new-line} .


    num#str# = num#str# + 1.
    num#col# = 1.
    run macr_excel_char ("№ кассы"  , num#str# , num#col#   ) .    run macr_cell_size ( 5 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 2.
    run macr_excel_char ("Остаток денежных средств"  , num#str# , num#col#   ) . run macr_cell_size ( 30 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 3.
    run macr_excel_char ("ФИО кассира"  , num#str# , num#col#   ) .  run macr_cell_size ( 20 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 4.
    run macr_excel_char ("Дата и время"  , num#str# , num#col#   ) . run macr_cell_size ( 16 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 5.
    run macr_excel_char ("Сумма"  , num#str# , num#col#   ) . run macr_cell_size ( 20 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 6.
    run macr_excel_char ("Дата и время"  , num#str# , num#col#   ) . run macr_cell_size ( 16 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 7.
    run macr_excel_char ("Сумма"  , num#str# , num#col#   ) . run macr_cell_size ( 20 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 8.
    run macr_excel_char ("С чего"  , num#str# , num#col#   ) . run macr_cell_size ( 16 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 9.
    run macr_excel_char ("На чего"  , num#str# , num#col#   ) . run macr_cell_size ( 20 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 10.
    run macr_excel_char ("Дата и время"  , num#str# , num#col#   ) . run macr_cell_size ( 16 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 11.
    run macr_excel_char ("Сумма"  , num#str# , num#col#   ) . run macr_cell_size ( 20 , ? , num#str# , num#col# , ?, ? ) .


  run print-1 .


    run macr_cell_format
    ( 10    ,    /* p-size     */
      true  ,    /* p-bold     */
      false ,    /* p-italic   */
      ? ,        /* p-color-bg */
      1 ,        /* p-row      */
      1 ,        /* p-col      */
      num#str# , /* p-row-2    */
      num#col#
      ) .      /* p-col-2    */

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
    run p-line .

    /* ... конец создания Подвал. --- */
  end.
end procedure. /* PrintPodval */



PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( OutStream ) then return .
  if line-counter( OutStream ) + p-line-number > page-size( OutStream ) then do:

    run p-line .
    page stream OutStream .
    end.
end procedure. /* on-same-page */

procedure print-1 :
/* шапка текстового файла  */

  do
  on error undo, return error return-value
  :

PUT STREAM OutStream UNFORMATTED "+---------------------------------------------------------------------------------------------------------------------------------------------+" skip .
PUT STREAM OutStream UNFORMATTED ":№ кассы: Остаток      :   ФИО кассира  :   Кассовый фонд    :     Инкассация      :                    Перевод оплаты                        :" skip .
PUT STREAM OutStream UNFORMATTED ":       : денежных     :                :-----------:--------+-----------:---------+-------------------:----------------:-----------:---------:" skip .
PUT STREAM OutStream UNFORMATTED ":       : средств      :                :   Дата и  :  Сумма :  Дата и   :  Сумма  :       С чего      :  На чего       :  Дата и   :Сумма    :" skip .
PUT STREAM OutStream UNFORMATTED ":       :              :                :   время   :        :  время    :         :                   :                :  время    :         :" skip .
PUT STREAM OutStream UNFORMATTED "+---------------------------------------------------------------------------------------------------------------------------------------------+" skip .

  end.

end procedure. /* print-1 */

procedure p-line :

  do
  on error undo, return error return-value
  :
  PUT STREAM OutStream UNFORMATTED  "+---------------------------------------------------------------------------------------------------------------------------------------------+".
  PUT STREAM OutStream UNFORMATTED  skip .

  end.

end procedure. /* p-line */

procedure print-obj :

  do
  on error undo, return error return-value
  :
  PUT STREAM OutStream UNFORMATTED  Obj-list.obj-name  at 1    format "X(26)" skip.
    num#str# = num#str# + 1 .
    num#col# = 1.
    run macr_excel_char ( Obj-list.obj-name  , num#str# , num#col#   ) .
    run macr_cell_size ( 26 , ? , num#str# , num#col# , ?, ? ) .
  end.

end procedure. /* print-obj */

procedure make-tt :

  do
  on error undo, return error return-value
  :

define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds  .
define buffer buf_psn-clients for ub.clients  .
define buffer buf_sale-clients for ub.clients  .
define buffer buf_chk-pay for ub.chk-pay  .
define variable v-sum as decimal   no-undo .
define variable jj as integer   no-undo init 0.
define variable v-vid as character no-undo .
define variable fio as character no-undo .

for each obj-list :
  for each buf_chk-doc no-lock where
      buf_chk-doc.obj-type = obj-list.obj-type and
      buf_chk-doc.obj-code = obj-list.obj-code and
      buf_chk-doc.chk-date <= x-date-end and
      buf_chk-doc.chk-date >= x-date-start
  :

  if lookup(string(buf_chk-doc.chk-type), {&wth-receipt-codes}) = 0 then next.
find first buf_psn-clients no-lock  where
           buf_psn-clients.obj-code = buf_chk-doc.cashier-psn-code  and
           buf_psn-clients.obj-type = {&prs} no-error .
          if error-status :error then
          fio =  "Кассир № " + string( buf_chk-doc.cashier ).
          else fio  = buf_psn-clients.obj-name .

            jj = jj + 1.
           { rep/repfrm.i disp JJ obj-list.obj-name }

          create tt-temp.
          assign
              tt-temp.pay-desk  = buf_chk-doc.pay-desk
              tt-temp.sum-rubl-ost = 0
              tt-temp.cashier   = buf_chk-doc.cashier
              tt-temp.psn-code  = buf_chk-doc.cashier-psn-code
              tt-temp.psn-name  = fio
              tt-temp.fact-date = buf_chk-doc.chk-date
              tt-temp.fact-time = string ( buf_chk-doc.chk-time , "hh:mm" )
              /*tt-temp.fact-time =  string(buf_chk-doc.doc-code)*/
              tt-temp.obj-code  = buf_chk-doc.obj-code
              tt-temp.obj-type  = buf_chk-doc.obj-type
              tt-temp.doc-code  = buf_chk-doc.doc-code
              tt-temp.doc-type  = string(buf_chk-doc.chk-type )
              tt-temp.bef-vid   = ""
              tt-temp.aft-vid   = ""
              tt-temp.sum-rubl  = 0
          .
          run sum-doc (input tt-temp.doc-code , input string(buf_chk-doc.chk-type ) ,  output tt-temp.sum-rubl  , output tt-temp.bef-vid  , output tt-temp.aft-vid) .
        end.
     end.


end.
end procedure. /* make-tt */

procedure print-obj-itog :

  do
  on error undo, return error return-value
  :
/*  PUT STREAM OutStream UNFORMATTED  "Итого по " + Obj-list.obj-name + " : "  + string(vv-sum) + "  {&abbr_rub}"  at 1    format "X(100)" skip.
    num#str# = num#str# + 1 .
    num#col# = 1.
    run macr_excel_char( "Итого по " + Obj-list.obj-name + " : "  + string(vv-sum) + "  {&abbr_rub}" ,  num#str# , num#col#   ) .
    run macr_cell_size ( 26 , ? , num#str# , num#col# , ?, ? ) .
    vv-sum   = 0 .
    vv-count = 0 .

  */
  end.

end procedure. /* print-obj-itog */
procedure sum-doc :

  do
  on error undo, return error return-value
  :
  define input  parameter p-doc-code as character no-undo .
  define input  parameter p-doc-type as character no-undo .
  define output parameter p-sum-rubl as decimal   no-undo .
  define output parameter p-bef-vid  as character no-undo .
  define output parameter p-aft-vid  as character no-undo .

  define buffer buf2_chk-pay for ub.chk-pay  .
  define buffer buf_chk-pay for ub.chk-pay  .
   p-bef-vid = "" .
   p-aft-vid = "" .
   p-sum-rubl = 0 .

   IF p-doc-type <> {&pay-transfer} THEN DO:
      p-sum-rubl = 0 .
      for each buf2_chk-pay no-lock where buf2_chk-pay.doc-code = p-doc-code /* AND buf2_chk-pay.CURR-CODE = 0 */ :
               p-sum-rubl = p-sum-rubl + buf2_chk-pay.tot-sum * buf2_chk-pay.bank-rate / buf2_chk-pay.bank-scale .
      end.
   END.
   ELSE DO:
      find first  buf2_chk-pay no-lock where buf2_chk-pay.doc-code = p-doc-code /* AND buf2_chk-pay.CURR-CODE = 0 */  no-error .
      if available buf2_chk-pay then do:
          p-sum-rubl = ABS(buf2_chk-pay.tot-sum * buf2_chk-pay.bank-rate / buf2_chk-pay.bank-scale)   .
        /*
          message buf2_chk-pay.sum  buf2_chk-pay.bank-rate  buf2_chk-pay.bank-scale skip
          p-doc-code skip
          buf2_chk-pay.curr-code buf2_chk-pay.pay-code
          .
          */
      end.

      for each buf2_chk-pay no-lock where buf2_chk-pay.doc-code = p-doc-code /* AND buf2_chk-pay.CURR-CODE = 0 */ :
          IF  buf2_chk-pay.tot-sum  < 0 THEN  DO:
              p-bef-vid = get-cash-pay(buf2_chk-pay.pay-code, buf2_chk-pay.curr-code) .
          END.
          IF  buf2_chk-pay.tot-sum  > 0 THEN  DO:
              p-aft-vid = get-cash-pay(buf2_chk-pay.pay-code, buf2_chk-pay.curr-code) .
          END.
      end.
   END.

     /* p-sum-rubl = dec( trim(p-doc-code, "-") ). */

  end.

end procedure. /* sum-doc */


{ rep/r-libmcr.i macr_excel         }