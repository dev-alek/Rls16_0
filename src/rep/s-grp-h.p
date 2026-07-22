block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: s-grp-h.p $
$Archive: rep/s-grp-h.p $

Почасовой отчет по суммам продаж - стандартный вывод до 13 колонок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter startdate as date no-undo .
define input parameter enddate as date no-undo .
define input parameter SelectObject as char no-undo .
define input parameter method as char no-undo .
/*
"Только итоги", "TOTALS":U,
"По группам", "GROUPS":U,
"Потоварно", "GOODS":U,
"По оплатам", "PAYS":U,
"По кассам", "pay-desk":U
*/
define input parameter ByObject as logical no-undo .
define input parameter WHstart as integer no-undo .
define input parameter WHEnd as integer no-undo .
define input parameter TREE as logical no-undo.
define input parameter t-dis-card as logical no-undo .
define input parameter rs-dis-card as integer no-undo .
define input parameter checked-time-intervals as char no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: s-grp-h.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/s-grp-h.p $":U .
define variable vss-description as character no-undo init "Почасовой отчет по суммам продаж - стандартный вывод до 13 колонок".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ cmp/r-page1.i  }
{ rep/dincol.i def }
{ rep/e-sumhdf.i SHARED }
{ rep/fulgrpdf.i " " obj-code }
{ ref/grplibfn.i }
{ gbl/waitfram.i }

define SHARED temp-table temp-dis-card-type no-undo like ub.dis-card-type.

&SCOPED-DEFINE UNDERLINE-FRAME-T ~{ rep/dincol.i un 2 hours fill14 t~} ~
      ~{ rep/dincol.i un 3 sum fill16   t~} ~
      ~{ rep/dincol.i un 4 sum_disc fill16  t~} ~
      ~{ rep/dincol.i un 5 sums fill16 t~} ~
      ~{ rep/dincol.i un 6 num-chk fill16 t~} ~
      DISPLAY stream  PrnLibStream with frame TOTALS. ~
      DOWN 1 stream PrnLibStream with frame TOTALS.

&SCOPED-DEFINE UNDERLINE-FRAME  ~{ rep/dincol.i un 2 full-name fill56 ~} ~
        ~{ rep/dincol.i un 4 sum1 fill11~} ~
        ~{ rep/dincol.i un 5 sum2 fill11~} ~
        ~{ rep/dincol.i un 6 sum3 fill11~} ~
        ~{ rep/dincol.i un 7 sum4 fill11~} ~
        ~{ rep/dincol.i un 8 sum5 fill11~} ~
        ~{ rep/dincol.i un 9 sum6 fill11~} ~
        ~{ rep/dincol.i un 10 sum7 fill11~} ~
        ~{ rep/dincol.i un 11 sum8 fill11~} ~
        ~{ rep/dincol.i un 12 sum9 fill11~} ~
        ~{ rep/dincol.i un 13 sum10 fill11~} ~
        ~{ rep/dincol.i un 14 sum11 fill11~} ~
        ~{ rep/dincol.i un 15 sum12 fill11~} ~
        ~{ rep/dincol.i un 16 sum13 fill11~} ~
        ~{ rep/dincol.i un 17 sum14 fill11~} ~
        ~{ rep/dincol.i un 18 sum15 fill11~} ~
        ~{ rep/dincol.i un 19 sum16 fill11~} ~
        ~{ rep/dincol.i un 20 sum17 fill11~} ~
        ~{ rep/dincol.i un 21 sum18 fill11~} ~
        ~{ rep/dincol.i un 22 sum19 fill11~} ~
        ~{ rep/dincol.i un 23 sum20 fill11~} ~
        ~{ rep/dincol.i un 24 sum21 fill11~} ~
        ~{ rep/dincol.i un 25 sum22 fill11~} ~
        ~{ rep/dincol.i un 26 sum23 fill11~} ~
        ~{ rep/dincol.i un 27 sum24 fill11~} ~
        ~{ rep/dincol.i un 28 tot-by-grp fill14~} ~
        DISPLAY stream  PrnLibStream with frame HOUR. ~
        DOWN 1 stream PrnLibStream with frame HOUR.

&SCOPED-DEFINE DISPLAY-FRAME         DISPLAY stream  PrnLibStream with frame HOUR. ~
                                     DOWN 1 stream PrnLibStream with frame HOUR.

&SCOPED-DEFINE DISPLAY-FRAME-T         DISPLAY stream  PrnLibStream with frame TOTALS. ~
                                       DOWN 1 stream PrnLibStream with frame TOTALS.

define buffer b-grp-h for grp-h .
define buffer b-gds-h for gds-h .
define buffer for-grp for ub.gds-grp.
define variable sym1 as char init ":"   no-undo.
define variable sym2 as char init ":"   no-undo.
define variable sym3 as char init ":"   no-undo.
define variable Line as char no-undo.
define variable tot-by-grp as decimal no-undo .
define variable tot-nc-by-grp as decimal no-undo .
define variable With-Goods as logical no-undo.
define variable ii as integer no-undo .
define variable kk as integer no-undo .
define variable cycle as integer no-undo .
define variable hours as char no-undo.
define variable sums as decimal no-undo.
define buffer cli-obj for ub.clients .
define variable nc as integer no-undo.
define variable fill1 as character no-undo.
define variable fill11 as character no-undo.
define variable fill12 as character no-undo.
define variable fill14 as character no-undo.
define variable fill16 as character no-undo.
define variable fill56 as character no-undo.
define variable v-accum-sum as decimal no-undo .
define variable v-accum-sum_disc as decimal no-undo .
define variable v-accum-num-chk as integer no-undo .
define variable v-obj-code like ub.clients.obj-code no-undo .
define variable v-obj-name like ub.clients.obj-name no-undo .
define variable accum-sum as decimal extent 24 no-undo .
define variable accum-num-chk as integer extent 24 no-undo .
define variable accum-tot-by-grp as decimal no-undo .
define variable accum-tot-nc-by-grp as decimal no-undo format ">>>>>9".
define variable v-title as character no-undo .
define variable accum-obj-list as integer no-undo .



assign
fill1 = fill("-", 1)
fill11 = fill("-", 11)
fill12 = fill("-", 12)
fill14 = fill("-", 14)
fill16 = fill("-", 16)
fill56 = fill("-", 56)
.


if method = "TOTALS":U then do:
end.
else do:
  assign
  nc = 5
  .
  do ii = 1 to 24:
    if use-column[ii + 3] = yes then
    nc = nc + 1
    .
  end.
end.

DEFINE VARIABLE t-1 AS CHARACTER INITIAL "||||"
     VIEW-AS EDITOR
     SIZE 1 BY 4 NO-UNDO.

CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .
l-col-pos = 1.

DEFINE FRAME top-framet

    t-1       AT ROW 1 COL 1 no-label
    HEADER
    cur-time-print() AT 5 format "x(35)"
    string( "Страница" ) AT 45 PAGE-NUMBER( PrnLibStream ) AT 55 FORMAT ">>9" SKIP
    with width {&DOS_CW_2} down stream-io use-text NO-BOX.

DEFINE FRAME top-frame
    t-1       AT ROW 1 COL 1 no-label
    HEADER
    cur-time-print() AT 5 format "x(35)"
    string( "Страница" ) AT 45 PAGE-NUMBER( PrnLibStream ) AT 55 FORMAT ">>9" SKIP
    with width {&DOS_CW_2} down stream-io use-text NO-BOX NO-HIDE.



DEFINE FRAME TOTALS
with width {&DOS_CW_2} down stream-io use-text NO-BOX OVERLAY.
DEFINE FRAME Hour
with width {&DOS_CW_2} down stream-io use-text NO-BOX OVERLAY.


if method = "TOTALS":U then do:
    
  l-col-pos = 1.
  Assign l-col-type="CHARACTER" l-col-len=1  l-col-format="X(1)"             l-col-lable = ":".
    { rep/dincol.i cr  1     sym1      TOTALS                t }
  Assign l-col-type="CHARACTER" l-col-len=14  l-col-format="X(14)"           l-col-lable = fill({&space-char}, 14).
    { rep/dincol.i cr  2     hours     TOTALS                t }
  Assign l-col-type="DECIMAL"   l-col-len=16  l-col-format="->>>,>>>,>>9.99" l-col-lable = "Сумма продаж!брутто".
    { rep/dincol.i cr  3     sum       TOTALS                t }
  Assign l-col-type="DECIMAL"   l-col-len=16  l-col-format="->>>,>>>,>>9.99" l-col-lable = "Сумма скидок".
    { rep/dincol.i cr  4     sum_disc  TOTALS                t }
  Assign l-col-type="DECIMAL"   l-col-len=16  l-col-format="->>>,>>>,>>9.99" l-col-lable = "Сумма продаж!нетто".
    { rep/dincol.i cr  5     sums      TOTALS                t }
  Assign l-col-type="INTEGRER"  l-col-len=16  l-col-format="->>>>>>9"        l-col-lable = "Кол-во чеков".
    { rep/dincol.i cr  6     num-chk  TOTALS                t }

end.
else do:

  l-col-pos = 1.
  Assign l-col-type="CHARACTER" l-col-len=1  l-col-format="X(1)"             l-col-lable = ":".
    { rep/dincol.i cr  1     sym1      hour                 }
  CASE method:
    when "pay-desk":U then do:
      Assign l-col-type="CHARACTER" l-col-len=56 l-col-format= "X(56)"     l-col-lable="Кассы".
    end.
    when "pays":U then do:
      Assign l-col-type="CHARACTER" l-col-len=56 l-col-format= "X(56)"     l-col-lable="Виды кассовых платежей".
    end.
    otherwise do:
      Assign l-col-type="CHARACTER" l-col-len=56 l-col-format= "X(56)"     l-col-lable="Группа товаров ( по классификатору )".
    end.
  END CASE.
  
  { rep/dincol.i cr  2    full-name  hour                 }

  Assign l-col-type="CHARACTER" l-col-len=1 l-col-format= "X(1)"       l-col-lable=":".
    { rep/dincol.i cr  3    sym2       hour                 }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable=" 0.00-0.59 ".
    { rep/dincol.i cr  4    sum1    hour                   }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable=" 1.00-1.59 ".
    { rep/dincol.i cr  5    sum2    hour                   }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable=" 2.00-2.59 ".
    { rep/dincol.i cr  6    sum3     hour       }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable=" 3.00-3.59 ".
    { rep/dincol.i cr  7    sum4     hour      }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable=" 4.00-4.59 ".
    { rep/dincol.i cr  8    sum5     hour     }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable=" 5.00-5.59 ".
    { rep/dincol.i cr  9    sum6     hour      }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable=" 6.00-6.59 ".
    { rep/dincol.i cr  10   sum7     hour      }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable=" 7.00-7.59 ".
    { rep/dincol.i cr  11   sum8     hour       }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable=" 8.00-8.59 ".
    { rep/dincol.i cr  12   sum9     hour       }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable=" 9.00-9.59 ".
    { rep/dincol.i cr  13   sum10    hour       }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable="10.00-10.59".
    { rep/dincol.i cr  14   sum11    hour       }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable="11.00-11.59".
    { rep/dincol.i cr  15   sum12    hour       }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable="12.00-12.59".
    { rep/dincol.i cr  16   sum13    hour       }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable="13.00-13.59".
    { rep/dincol.i cr  17   sum14    hour       }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable="14.00-14.59".
    { rep/dincol.i cr  18   sum15    hour        }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable="15.00-15.59".
    { rep/dincol.i cr  19   sum16    hour       }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable="16.00-16.59".
    { rep/dincol.i cr  20   sum17    hour       }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable="17.00-17.59".
    { rep/dincol.i cr  21   sum18    hour       }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable="18.00-18.59".
    { rep/dincol.i cr  22   sum19    hour       }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable="19.00-19.59".
    { rep/dincol.i cr  23   sum20    hour       }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable="20.00-20.59".
    { rep/dincol.i cr  24   sum21    hour       }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable="21.00-21.59".
    { rep/dincol.i cr  25   sum22    hour       }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable="22.00-22.59".
    { rep/dincol.i cr  26   sum23    hour       }
  Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.99"  l-col-lable="23.00-23.59".
    { rep/dincol.i cr  27   sum24    hour       }
  Assign l-col-type="DECIMAL"   l-col-len=14 l-col-format= "->>,>>>,>>9.99"  l-col-lable="Итого по строке".
    { rep/dincol.i cr  28   tot-by-grp   hour               }
  Assign l-col-type="CHARACTER" l-col-len=1  l-col-format="X(1)"       l-col-lable=":".
    { rep/dincol.i cr  29   sym3         hour       }
end.

IF METHOD = "GOODS":U then WIth-goods = yes.
else with-goods = no.
Line = fill( "-" , 60 ) .
{ rep/s-grp-h.i }


if method = "TOTALS":U then do:
  if nc > 15 then do:
    /*колонок больше 10*/
    run prn-lib-open-stream  in this-procedure (
                                                input parParentProc
                                                ,input {&CS_PS}
                                                ,input yes /*p-is-stream*/
                                                ,input no /*p-append*/
                                                ).
  end.
  else do:
    run prn-lib-open-stream  in this-procedure (
                                                input parParentProc
                                                ,input {&LS_PS_A4}
                                                ,input yes /*p-is-stream*/
                                                ,input no /*p-append*/
                                                ).
  end.
END.
else do:
  if nc > 15 then do:
    /*колонок больше 10*/
    run prn-lib-open-stream  in this-procedure (
                                                input parParentProc
                                                ,input {&CS_PS}
                                                ,input yes /*p-is-stream*/
                                                ,input no /*p-append*/
                                                ).

  end.
  else do:
    run prn-lib-open-stream  in this-procedure (
                                                input parParentProc
                                                ,input {&LS_PS_A4}
                                                ,input yes /*p-is-stream*/
                                                ,input no /*p-append*/
                                               ).
  end.
END.
IF METHOD = "TOTALS":U THEN DO:
  FORM with FRAME TOTALS .
  FORM HEADER
  Line format "X(60)" AT 1 SKIP
  string( "Продолжение - на следующей странице" ) FORMAT "X(40)" AT 10 SKIP
  with FRAME NBottomFramet width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream PrnLibStream FRAME NBottomFramet .
  PUT stream PrnLibStream
  SPACE(10)
  ("Почасовая статистика розничных продаж ( по СУММЕ ПРОДАЖ ) ЗА ПЕРИОД c " +
  string( startdate, "99/99/9999" ) + " по " + string( enddate, "99/99/9999" ) + ".")      format "x(110)" SKIP(1).
  if t-dis-card then do:
    PUT stream PrnLibStream UNFORMATTED
    SPACE(10)
    "Только покупки по дисконтным картам" skip.
    if rs-dis-card = 1 then do:
      for each temp-dis-card-type No-LOCK:
        PUT stream PrnLibStream UNFORMATTED
        SPACE(10)
        temp-dis-card-type.type
        skip.
      END.
    end.
  end.
  PUT stream PrnLibStream UNFORMATTED
  SPACE(10) SelectObject SKIP(0)
  (if byobject then "С разбивкой по объектам" else '')  SKIP(1).
  display STREAM PrnLibStream with frame top-Framet .
  _cycle:
  do cycle = 1 to 0 by -1:
    if byobject and cycle = 0 and accum-obj-list = 1 then LEAVE _cycle.
    _obj-list:
    for each obj-list no-lock:
      if not byobject and cycle = 1 then LEAVE _obj-list.
      if cycle = 1 then v-obj-code = obj-list.obj-code.
      if cycle = 0 then v-obj-code = 0.
      assign
      v-accum-sum      = 0
      v-accum-sum_disc = 0
      v-accum-num-chk  = 0
      .
      if cycle = 1 then do:
        FIND FIRST ub.clients NO-LOCK WHERE
                  ub.clients.obj-code = v-obj-code AND
                  ub.clients.obj-type = {&shop} NO-ERROR.
        if available ub.clients then do:
          v-obj-name = ub.clients.obj-name.
        end.
        else v-obj-name = string(v-obj-code).
      end.
      if byobject and cycle = 0 then do:
        v-obj-name = "ПО ВСЕМ ОБЪЕКТАМ".
      end.
      if byobject then do:
        PUT stream PrnLibStream UNFORMATTED
        v-obj-name
        skip.
        {&UNDERLINE-FRAME-T}
      end.
      FOR EACH grp-h No-LOCK  where
              grp-h.obj-code = v-obj-code
      BY grp-h.obj-code:
        DO ii = 0 TO 23 :
          /* если не помечен временой интервал галкой, то пропускаем */  
          if entry(ii + 1, checked-time-intervals) = "no" then next.
          
          HOURS = string(ii, "99") + ".00-" + string(ii, "99") + ".59".
          { rep/dincol.i di 2 hours hours t}
          { rep/dincol.i di 3 sum "grp-h.sum[ii + 1]"  t}
          { rep/dincol.i di 4 sum_disc "grp-h.sum_disc[ii + 1]" t }
          { rep/dincol.i di 5 sums "grp-h.sum[ii + 1] - grp-h.sum_disc[ii + 1]" t}
          { rep/dincol.i di 6 num-chk "grp-h.num-chk[ii + 1]" t}
          {&DISPLAY-FRAME-T}
          assign
          v-accum-sum = v-accum-sum + grp-h.sum[ii + 1]
          v-accum-sum_disc = v-accum-sum_disc + grp-h.sum_disc[ii + 1]
          v-accum-num-chk  = v-accum-num-chk + grp-h.num-chk[ii + 1]
          .
          IF ii = 23 then do:
            {&UNDERLINE-FRAME-T}
            { rep/dincol.i di 1 sym1 sym1  t }
            { rep/dincol.i di 2 hours "substitute('ИТОГО &1', v-obj-name)" t }
            { rep/dincol.i di 3 sum "v-accum-sum"  t }
            { rep/dincol.i di 4 sum_disc "v-accum-sum_disc"  t }
            { rep/dincol.i di 5 sums "(v-accum-sum - v-accum-sum_disc)"  t }
            { rep/dincol.i di 6 num-chk "v-accum-num-chk"  t }
            {&DISPLAY-FRAME-T}
            {&UNDERLINE-FRAME-t}
          end.
        END. /*ii */
      END. /*FOR EACH grp-h*/
      if cycle = 0 then LEAVE _obj-list.
    end. /*for each obj-list*/
  end. /*do cycle*/
  HIDE STREAM PrnLibStream frame TOTALS .
  HIDE STREAM PrnLibStream FRAME top-Framet .
  HIDE stream PrnLibStream FRAME NBottomFramet .
END. /* method = "TOTALS"*/
ELSE DO:
  FORM with FRAME Hour .
  FORM HEADER
  Line format "X(60)" AT 1 SKIP
  string( "Продолжение - на следующей странице" ) FORMAT "X(40)" AT 10 SKIP
  with FRAME NBottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream PrnLibStream FRAME NBottomFrame .
  PUT stream PrnLibStream
  SPACE(10)
  ("Почасовая статистика розничных продаж ( по СУММЕ ПРОДАЖ ) ЗА ПЕРИОД c " +
  string( startdate, "99/99/9999" ) + " по " + string( enddate, "99/99/9999" ) + ".")      format "x(110)" SKIP(1).
  if t-dis-card then do:
    PUT stream PrnLibStream UNFORMATTED
    SPACE(10)
    "Только покупки по дисконтным картам" skip.
    if rs-dis-card = 1 then do:
      for each temp-dis-card-type No-LOCK:
        PUT stream PrnLibStream UNFORMATTED
        SPACE(10)
        temp-dis-card-type.type
        skip.
      END.
    end.
  end.
  PUT stream PrnLibStream UNFORMATTED
  SPACE(10) SelectObject SKIP(0)
  (if byobject then "С разбивкой по объектам" else '')  SKIP(1).
  VIEW stream PrnLibStream FRAME top-frame .
  display STREAM PrnLibStream
  with frame top-frame .
  _cycle2:
  do cycle = 1 to 0 by -1:
    if byobject and cycle = 0 and accum-obj-list = 1 then LEAVE _cycle2.
    _obj-list2:
    for each obj-list no-lock:
      if not byobject and cycle = 1 then LEAVE _obj-list2.
      if cycle = 1 then v-obj-code = obj-list.obj-code.
      if cycle = 0 then v-obj-code = 0.
      assign
      tot-nc-by-grp  = 0
      tot-by-grp     = 0
      accum-sum[1]   = 0
      accum-sum[2]   = 0
      accum-sum[3]   = 0
      accum-sum[4]   = 0
      accum-sum[5]   = 0
      accum-sum[6]   = 0
      accum-sum[7]   = 0
      accum-sum[8]   = 0
      accum-sum[9]   = 0
      accum-sum[10]  = 0
      accum-sum[11]  = 0
      accum-sum[12]  = 0
      accum-sum[13]  = 0
      accum-sum[14]  = 0
      accum-sum[15]  = 0
      accum-sum[16]  = 0
      accum-sum[17]  = 0
      accum-sum[18]  = 0
      accum-sum[19]  = 0
      accum-sum[20]  = 0
      accum-sum[21]  = 0
      accum-sum[22]  = 0
      accum-sum[23]  = 0
      accum-sum[24]  = 0
      accum-tot-by-grp = 0
      accum-num-chk[1] =  0
      accum-num-chk[2] =  0
      accum-num-chk[3] =  0
      accum-num-chk[4] =  0
      accum-num-chk[5] =  0
      accum-num-chk[6] =  0
      accum-num-chk[7] =  0
      accum-num-chk[8] =  0
      accum-num-chk[9] =  0
      accum-num-chk[10] = 0
      accum-num-chk[11] = 0
      accum-num-chk[12] = 0
      accum-num-chk[13] = 0
      accum-num-chk[14] = 0
      accum-num-chk[15] = 0
      accum-num-chk[16] = 0
      accum-num-chk[17] = 0
      accum-num-chk[18] = 0
      accum-num-chk[19] = 0
      accum-num-chk[20] = 0
      accum-num-chk[21] = 0
      accum-num-chk[22] = 0
      accum-num-chk[23] = 0
      accum-num-chk[24] = 0
      accum-tot-nc-by-grp = 0
      .
      if cycle = 1 then do:
        FIND FIRST ub.clients NO-LOCK WHERE
                  ub.clients.obj-code = v-obj-code AND
                  ub.clients.obj-type = {&shop} NO-ERROR.
        if available ub.clients then do:
          v-obj-name = ub.clients.obj-name.
        end.
        else v-obj-name = string(v-obj-code).
      end.
      if byobject and cycle = 0 then do:
        v-obj-name = "ПО ВСЕМ ОБЪЕКТАМ".
      end.
      if byobject
      and not (cycle = 0 and method = "pay-desk")
      then do:
        { rep/dincol.i di 1 sym1 sym1}
        { rep/dincol.i di 2 full-name v-obj-name }
        {&DISPLAY-FRAME}
        {&UNDERLINE-FRAME}
      end.
      FOR EACH full-grp NO-LOCK,
      EACH grp-h WHERE
          grp-h.obj-code = v-obj-code
      AND grp-h.grp-code = full-grp.grp-code
      AND grp-h.other-code = full-grp.other-code
      BREAK
      BY full-grp.full-name
      BY grp-h.obj-code
      BY grp-h.grp-code
      By grp-h.other-code:
        if cycle = 1 and method = "pay-desk" and full-grp.other-code <> v-obj-code then next.
        if (method = "pays":U and first-of( grp-h.other-code )) OR
          (method <> "pays":U and first-of( grp-h.grp-code ))
        then do:
          assign
          tot-nc-by-grp = 0
          tot-by-grp =  0
          .
        end.
        DO ii = 1 to 24:
          if use-column[ii + 3] then
          assign
          tot-nc-by-grp = tot-nc-by-grp + grp-h.num-chk[ii]
          tot-by-grp =  tot-by-grp + grp-h.sum[ii]
          .
        END.
        if method = "pay-desk":U
        or method = "pays":U then do:
          if method = "pay-desk" and cycle = 0 then do:
          end.
          else do:
            { rep/dincol.i di 1 sym1 sym1}
            { rep/dincol.i di 2 full-name full-grp.FULL-NAME }
            { rep/dincol.i di 3 sym2 sym2}
            { rep/dincol.i di 4 sum1 grp-h.sum[1]}
            { rep/dincol.i di 5 sum2 grp-h.sum[2]}
            { rep/dincol.i di 6 sum3 grp-h.sum[3]}
            { rep/dincol.i di 7 sum4 grp-h.sum[4]}
            { rep/dincol.i di 8 sum5 grp-h.sum[5]}
            { rep/dincol.i di 9 sum6 grp-h.sum[6]}
            { rep/dincol.i di 10 sum7 grp-h.sum[7]}
            { rep/dincol.i di 11 sum8 grp-h.sum[8]}
            { rep/dincol.i di 12 sum9 grp-h.sum[9]}
            { rep/dincol.i di 13 sum10 grp-h.sum[10]}
            { rep/dincol.i di 14 sum11 grp-h.sum[11]}
            { rep/dincol.i di 15 sum12 grp-h.sum[12]}
            { rep/dincol.i di 16 sum13 grp-h.sum[13]}
            { rep/dincol.i di 17 sum14 grp-h.sum[14]}
            { rep/dincol.i di 18 sum15 grp-h.sum[15]}
            { rep/dincol.i di 19 sum16 grp-h.sum[16]}
            { rep/dincol.i di 20 sum17 grp-h.sum[17]}
            { rep/dincol.i di 21 sum18 grp-h.sum[18]}
            { rep/dincol.i di 22 sum19 grp-h.sum[19]}
            { rep/dincol.i di 23 sum20 grp-h.sum[20]}
            { rep/dincol.i di 24 sum21 grp-h.sum[21]}
            { rep/dincol.i di 25 sum22 grp-h.sum[22]}
            { rep/dincol.i di 26 sum23 grp-h.sum[23]}
            { rep/dincol.i di 27 sum24 grp-h.sum[24]}
            { rep/dincol.i di 28 tot-by-grp tot-by-grp}
            { rep/dincol.i di 29 sym3 sym3}
            {&DISPLAY-FRAME}

            { rep/dincol.i di 1 sym1 sym1}
            { rep/dincol.i di 2 full-name "(if method = 'pays':U then 'количество платежей' else 'пробито чеков')" }
            { rep/dincol.i di 3 sym2 sym2}
            { rep/dincol.i dif 4 sum1 grp-h.num-chk[1] " " '>>>>>9'}
            { rep/dincol.i dif 5 sum2 grp-h.num-chk[2] " " '>>>>>9'}
            { rep/dincol.i dif 6 sum3  grp-h.num-chk[3] " " '>>>>>9'}
            { rep/dincol.i dif 7 sum4  grp-h.num-chk[4] " " '>>>>>9'}
            { rep/dincol.i dif 8 sum5  grp-h.num-chk[5] " " '>>>>>9'}
            { rep/dincol.i dif 9 sum6  grp-h.num-chk[6] " " '>>>>>9'}
            { rep/dincol.i dif 10 sum7 grp-h.num-chk[7] " " '>>>>>9'}
            { rep/dincol.i dif 11 sum8 grp-h.num-chk[8] " " '>>>>>9'}
            { rep/dincol.i dif 12 sum9 grp-h.num-chk[9] " " '>>>>>9'}
            { rep/dincol.i dif 13 sum10 grp-h.num-chk[10] " " '>>>>>9'}
            { rep/dincol.i dif 14 sum11 grp-h.num-chk[11] " " '>>>>>9'}
            { rep/dincol.i dif 15 sum12 grp-h.num-chk[12] " " '>>>>>9'}
            { rep/dincol.i dif 16 sum13 grp-h.num-chk[13] " " '>>>>>9'}
            { rep/dincol.i dif 17 sum14 grp-h.num-chk[14] " " '>>>>>9'}
            { rep/dincol.i dif 18 sum15 grp-h.num-chk[15] " " '>>>>>9'}
            { rep/dincol.i dif 19 sum16 grp-h.num-chk[16] " " '>>>>>9'}
            { rep/dincol.i dif 20 sum17 grp-h.num-chk[17] " " '>>>>>9'}
            { rep/dincol.i dif 21 sum18 grp-h.num-chk[18] " " '>>>>>9'}
            { rep/dincol.i dif 22 sum19 grp-h.num-chk[19] " " '>>>>>9'}
            { rep/dincol.i dif 23 sum20 grp-h.num-chk[20] " " '>>>>>9'}
            { rep/dincol.i dif 24 sum21 grp-h.num-chk[21] " " '>>>>>9'}
            { rep/dincol.i dif 25 sum22 grp-h.num-chk[22] " " '>>>>>9'}
            { rep/dincol.i dif 26 sum23 grp-h.num-chk[23] " " '>>>>>9'}
            { rep/dincol.i dif 27 sum24 grp-h.num-chk[24] " " '>>>>>9'}
            { rep/dincol.i dif 28 tot-by-grp tot-nc-by-grp " " '>>>>>9'}
            { rep/dincol.i di 29 sym3 sym3}
            {&DISPLAY-FRAME}
          end.
          assign
          accum-num-chk[1] = accum-num-chk[1] + grp-h.num-chk[1]
          accum-num-chk[2] = accum-num-chk[2] + grp-h.num-chk[2]
          accum-num-chk[3] = accum-num-chk[3] + grp-h.num-chk[3]
          accum-num-chk[4] = accum-num-chk[4] + grp-h.num-chk[4]
          accum-num-chk[5] = accum-num-chk[5] + grp-h.num-chk[5]
          accum-num-chk[6] = accum-num-chk[6] + grp-h.num-chk[6]
          accum-num-chk[7] = accum-num-chk[7] + grp-h.num-chk[7]
          accum-num-chk[8] = accum-num-chk[8] + grp-h.num-chk[8]
          accum-num-chk[9] = accum-num-chk[9] + grp-h.num-chk[9]
          accum-num-chk[10] = accum-num-chk[10] + grp-h.num-chk[10]
          accum-num-chk[11] = accum-num-chk[11] + grp-h.num-chk[11]
          accum-num-chk[12] = accum-num-chk[12] + grp-h.num-chk[12]
          accum-num-chk[13] = accum-num-chk[13] + grp-h.num-chk[13]
          accum-num-chk[14] = accum-num-chk[14] + grp-h.num-chk[14]
          accum-num-chk[15] = accum-num-chk[15] + grp-h.num-chk[15]
          accum-num-chk[16] = accum-num-chk[16] + grp-h.num-chk[16]
          accum-num-chk[17] = accum-num-chk[17] + grp-h.num-chk[17]
          accum-num-chk[18] = accum-num-chk[18] + grp-h.num-chk[18]
          accum-num-chk[19] = accum-num-chk[19] + grp-h.num-chk[19]
          accum-num-chk[20] = accum-num-chk[20] + grp-h.num-chk[20]
          accum-num-chk[21] = accum-num-chk[21] + grp-h.num-chk[21]
          accum-num-chk[22] = accum-num-chk[22] + grp-h.num-chk[22]
          accum-num-chk[23] = accum-num-chk[23] + grp-h.num-chk[23]
          accum-num-chk[24] = accum-num-chk[24] + grp-h.num-chk[24]
          accum-tot-nc-by-grp = accum-tot-nc-by-grp + tot-nc-by-grp
          .
        end.
        else do:
          { rep/dincol.i di 1 sym1 sym1}
          { rep/dincol.i di 2 full-name full-grp.FULL-NAME }
          { rep/dincol.i di 3 sym2 sym2}
          { rep/dincol.i di 4 sum1 grp-h.sum[1]}
          { rep/dincol.i di 5 sum2 grp-h.sum[2]}
          { rep/dincol.i di 6 sum3 grp-h.sum[3]}
          { rep/dincol.i di 7 sum4 grp-h.sum[4]}
          { rep/dincol.i di 8 sum5 grp-h.sum[5]}
          { rep/dincol.i di 9 sum6 grp-h.sum[6]}
          { rep/dincol.i di 10 sum7 grp-h.sum[7]}
          { rep/dincol.i di 11 sum8 grp-h.sum[8]}
          { rep/dincol.i di 12 sum9 grp-h.sum[9]}
          { rep/dincol.i di 13 sum10 grp-h.sum[10]}
          { rep/dincol.i di 14 sum11 grp-h.sum[11]}
          { rep/dincol.i di 15 sum12 grp-h.sum[12]}
          { rep/dincol.i di 16 sum13 grp-h.sum[13]}
          { rep/dincol.i di 17 sum14 grp-h.sum[14]}
          { rep/dincol.i di 18 sum15 grp-h.sum[15]}
          { rep/dincol.i di 19 sum16 grp-h.sum[16]}
          { rep/dincol.i di 20 sum17 grp-h.sum[17]}
          { rep/dincol.i di 21 sum18 grp-h.sum[18]}
          { rep/dincol.i di 22 sum19 grp-h.sum[19]}
          { rep/dincol.i di 23 sum20 grp-h.sum[20]}
          { rep/dincol.i di 24 sum21 grp-h.sum[21]}
          { rep/dincol.i di 25 sum22 grp-h.sum[22]}
          { rep/dincol.i di 26 sum23 grp-h.sum[23]}
          { rep/dincol.i di 27 sum24 grp-h.sum[24]}
          { rep/dincol.i di 28 tot-by-grp tot-by-grp}
          { rep/dincol.i di 29 sym3 sym3}
          {&DISPLAY-FRAME}
        end.
        if With-Goods then do:
          DISPLAY stream  PrnLibStream with frame HOUR.
          DOWN 1 stream PrnLibStream with FRAME Hour .
          FOR EACH gds-h WHERE
                  gds-h.obj-code = grp-h.obj-code
              AND gds-h.grp-code = grp-h.grp-code
              use-index uu
          BREAK BY gds-h.uniq :
            if first-of( gds-h.uniq ) then do:
              { rep/dincol.i di 1 sym1 sym1}
              { rep/dincol.i di 2 full-name "string( fill( {&space-char}, 3 ) + string( gds-h.artic, 'x(16)' ) +  {&space-char} + gds-h.gds-name )" }
              { rep/dincol.i di 3 sym2 sym2}
              { rep/dincol.i di 4 sum1 gds-h.sum[1]}
              { rep/dincol.i di 5 sum2 gds-h.sum[2]}
              { rep/dincol.i di 6 sum3 gds-h.sum[3]}
              { rep/dincol.i di 7 sum4 gds-h.sum[4]}
              { rep/dincol.i di 8 sum5 gds-h.sum[5]}
              { rep/dincol.i di 9 sum6 gds-h.sum[6]}
              { rep/dincol.i di 10 sum7 gds-h.sum[7]}
              { rep/dincol.i di 11 sum8 gds-h.sum[8]}
              { rep/dincol.i di 12 sum9 gds-h.sum[9]}
              { rep/dincol.i di 13 sum10 gds-h.sum[10]}
              { rep/dincol.i di 14 sum11 gds-h.sum[11]}
              { rep/dincol.i di 15 sum12 gds-h.sum[12]}
              { rep/dincol.i di 16 sum13 gds-h.sum[13]}
              { rep/dincol.i di 17 sum14 gds-h.sum[14]}
              { rep/dincol.i di 18 sum15 gds-h.sum[15]}
              { rep/dincol.i di 19 sum16 gds-h.sum[16]}
              { rep/dincol.i di 20 sum17 gds-h.sum[17]}
              { rep/dincol.i di 21 sum18 gds-h.sum[18]}
              { rep/dincol.i di 22 sum19 gds-h.sum[19]}
              { rep/dincol.i di 23 sum20 gds-h.sum[20]}
              { rep/dincol.i di 24 sum21 gds-h.sum[21]}
              { rep/dincol.i di 25 sum22 gds-h.sum[22]}
              { rep/dincol.i di 26 sum23 gds-h.sum[23]}
              { rep/dincol.i di 27 sum24 gds-h.sum[24]}
              { rep/dincol.i di 29 sym3 sym3}
              {&DISPLAY-FRAME}
            end.
          END .   /* FOR EACH gds-h ... */
          {&UNDERLINE-FRAME}
        end.    /* if With-Goods then ... */
        if NOT With-Goods then do:
          {&UNDERLINE-FRAME}
        end.
        ASSIGN
        accum-sum[1] = accum-sum[1] + grp-h.sum[1]
        accum-sum[2] = accum-sum[2] + grp-h.sum[2]
        accum-sum[3] = accum-sum[3] + grp-h.sum[3]
        accum-sum[4] = accum-sum[4] + grp-h.sum[4]
        accum-sum[5] = accum-sum[5] + grp-h.sum[5]
        accum-sum[6] = accum-sum[6] + grp-h.sum[6]
        accum-sum[7] = accum-sum[7] + grp-h.sum[7]
        accum-sum[8] = accum-sum[8] + grp-h.sum[8]
        accum-sum[9] = accum-sum[9] + grp-h.sum[9]
        accum-sum[10] = accum-sum[10] + grp-h.sum[10]
        accum-sum[11] = accum-sum[11] + grp-h.sum[11]
        accum-sum[12] = accum-sum[12] + grp-h.sum[12]
        accum-sum[13] = accum-sum[13] + grp-h.sum[13]
        accum-sum[14] = accum-sum[14] + grp-h.sum[14]
        accum-sum[15] = accum-sum[15] + grp-h.sum[15]
        accum-sum[16] = accum-sum[16] + grp-h.sum[16]
        accum-sum[17] = accum-sum[17] + grp-h.sum[17]
        accum-sum[18] = accum-sum[18] + grp-h.sum[18]
        accum-sum[19] = accum-sum[19] + grp-h.sum[19]
        accum-sum[20] = accum-sum[20] + grp-h.sum[20]
        accum-sum[21] = accum-sum[21] + grp-h.sum[21]
        accum-sum[22] = accum-sum[22] + grp-h.sum[22]
        accum-sum[23] = accum-sum[23] + grp-h.sum[23]
        accum-sum[24] = accum-sum[24] + grp-h.sum[24]
        accum-tot-by-grp = accum-tot-by-grp + tot-by-grp
        .
      END. /*for each full-grp*/
      { rep/dincol.i di 1 sym1 sym1}
      CASE method:
        when "pay-desk" then do:
          v-title = substitute('Итого &1 по всем кассам', v-obj-name).
        end.
        when "pays" then do:
          v-title = substitute('Итого &1 по всем видам платежей', v-obj-name).
        end.
        when "goods" or
        when "GROUPs" then do:
          v-title = substitute('Итого &1 по группам', v-obj-name).
        end.
      END CASE.
      { rep/dincol.i di 2 full-name v-title }
      { rep/dincol.i di 3 sym2 sym2}
      { rep/dincol.i di 4 sum1 "accum-sum[1]"}
      { rep/dincol.i di 5 sum2 "accum-sum[2]"}
      { rep/dincol.i di 6 sum3 "accum-sum[3]"}
      { rep/dincol.i di 7 sum4 "accum-sum[4]"}
      { rep/dincol.i di 8 sum5 "accum-sum[5]"}
      { rep/dincol.i di 9 sum6 "accum-sum[6]"}
      { rep/dincol.i di 10 sum7 "accum-sum[7]"}
      { rep/dincol.i di 11 sum8 "accum-sum[8]"}
      { rep/dincol.i di 12 sum9 "accum-sum[9]"}
      { rep/dincol.i di 13 sum10 "accum-sum[10]"}
      { rep/dincol.i di 14 sum11 "accum-sum[11]"}
      { rep/dincol.i di 15 sum12 "accum-sum[12]"}
      { rep/dincol.i di 16 sum13 "accum-sum[13]"}
      { rep/dincol.i di 17 sum14 "accum-sum[14]"}
      { rep/dincol.i di 18 sum15 "accum-sum[15]"}
      { rep/dincol.i di 19 sum16 "accum-sum[16]"}
      { rep/dincol.i di 20 sum17 "accum-sum[17]"}
      { rep/dincol.i di 21 sum18 "accum-sum[18]"}
      { rep/dincol.i di 22 sum19 "accum-sum[19]"}
      { rep/dincol.i di 23 sum20 "accum-sum[20]"}
      { rep/dincol.i di 24 sum21 "accum-sum[21]"}
      { rep/dincol.i di 25 sum22 "accum-sum[22]"}
      { rep/dincol.i di 26 sum23 "accum-sum[23]"}
      { rep/dincol.i di 27 sum24 "accum-sum[24]"}
      { rep/dincol.i di 28 tot-by-grp "ACCUM-tot-by-grp"}
      { rep/dincol.i di 29 sym3 sym3}
      {&DISPLAY-FRAME}
      IF method = "pay-desk":U OR method = "pays":U then do:
        DOWN 1 stream PrnLibStream with FRAME Hour .
        { rep/dincol.i di 2 full-name "IF method = 'pay-desk':U THEN 'пробито чеков' ELSE 'количество платежей'"}
        { rep/dincol.i dif 4 sum1 "accum-num-chk[1]" " " '>>>>>9' }
        { rep/dincol.i dif 5 sum2 "accum-num-chk[2]" " " '>>>>>9' }
        { rep/dincol.i dif 6 sum3 "accum-num-chk[3]" " " '>>>>>9' }
        { rep/dincol.i dif 7 sum4 "accum-num-chk[4]" " " '>>>>>9' }
        { rep/dincol.i dif 8 sum5 "accum-num-chk[5]" " " '>>>>>9' }
        { rep/dincol.i dif 9 sum6 "accum-num-chk[6]" " " '>>>>>9' }
        { rep/dincol.i dif 10 sum7 "accum-num-chk[7]" " " '>>>>>9' }
        { rep/dincol.i dif 11 sum8 "accum-num-chk[8]" " " '>>>>>9' }
        { rep/dincol.i dif 12 sum9 "accum-num-chk[9]" " " '>>>>>9' }
        { rep/dincol.i dif 13 sum10 "accum-num-chk[10]" " " '>>>>>9' }
        { rep/dincol.i dif 14 sum11 "accum-num-chk[11]" " " '>>>>>9' }
        { rep/dincol.i dif 15 sum12 "accum-num-chk[12]" " " '>>>>>9' }
        { rep/dincol.i dif 16 sum13 "accum-num-chk[13]" " " '>>>>>9' }
        { rep/dincol.i dif 17 sum14 "accum-num-chk[14]" " " '>>>>>9' }
        { rep/dincol.i dif 18 sum15 "accum-num-chk[15]" " " '>>>>>9' }
        { rep/dincol.i dif 19 sum16 "accum-num-chk[16]" " " '>>>>>9' }
        { rep/dincol.i dif 20 sum17 "accum-num-chk[17]" " " '>>>>>9' }
        { rep/dincol.i dif 21 sum18 "accum-num-chk[18]" " " '>>>>>9' }
        { rep/dincol.i dif 22 sum19 "accum-num-chk[19]" " " '>>>>>9' }
        { rep/dincol.i dif 23 sum20 "accum-num-chk[20]" " " '>>>>>9' }
        { rep/dincol.i dif 24 sum21 "accum-num-chk[21]" " " '>>>>>9' }
        { rep/dincol.i dif 25 sum22 "accum-num-chk[22]" " " '>>>>>9' }
        { rep/dincol.i dif 26 sum23 "accum-num-chk[23]" " " '>>>>>9' }
        { rep/dincol.i dif 27 sum24 "accum-num-chk[24]" " " '>>>>>9' }
        { rep/dincol.i dif 28 tot-by-grp "ACCUM-tot-nc-by-grp" " " '>>>>>9' }
        {&DISPLAY-FRAME}
      end.
      {&UNDERLINE-FRAME}
      if cycle = 0 then LEAVE _obj-list2.
    END. /*for each obj-list*/
  end. /*do cycle*/
  HIDE STREAM PrnLibStream FRAME HOUR .
  HIDE STREAM PrnLibStream FRAME top-frame .
  HIDE stream PrnLibStream FRAME NBottomFrame .
END. /*METHOD <> "TOTALS"*/
output stream PrnLibStream CLOSE .
output stream PrnLibStream CLOSE .
DELETE WIDGET-POOL "My-pool".