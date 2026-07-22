block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sv-grp-h.p $
$Archive: rep/sv-grp-h.p $

Почасовой отчет по величинам сумм продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter startdate as date no-undo .
define input parameter enddate as date no-undo .
define input parameter SelectObject as char no-undo .
define input parameter byobject as logical no-undo .
define input parameter WHStart as integer no-undo .
define input parameter WHEnd as integer no-undo.
define input parameter RETS as logical no-undo.
define input parameter TREE as logical no-undo.
define input parameter method as character no-undo .
define input parameter t-dis-card as logical no-undo .
define input parameter rs-dis-card as integer no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sv-grp-h.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/sv-grp-h.p $":U .
define variable vss-description as character no-undo init "Почасовой отчет по величинам сумм продаж".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ cmp/r-page1.i  }
{ rep/dincol.i def }
{ rep/e-svhrdf.i SHARED }
{ rep/fulgrpdf.i }
{ ref/grplibfn.i }
{ gbl/waitfram.i }

define SHARED temp-table temp-dis-card-type no-undo like ub.dis-card-type.

DEFINE VARIABLE accum-count as integer no-undo .

&SCOPED-DEFINE UNDERLINE-FRAME  ~{ rep/dincol.i un 2 full-name fill44 ~} ~
      ~{ rep/dincol.i un 4 num-chk1 fill11 ~} ~
      ~{ rep/dincol.i un 5 num-chk2 fill11~} ~
      ~{ rep/dincol.i un 6 num-chk3 fill11~} ~
      ~{ rep/dincol.i un 7 num-chk4 fill11~} ~
      ~{ rep/dincol.i un 8 num-chk5 fill11~} ~
      ~{ rep/dincol.i un 9 num-chk6 fill11~} ~
      ~{ rep/dincol.i un 10 num-chk7 fill11~} ~
      ~{ rep/dincol.i un 11 num-chk8 fill11~} ~
      ~{ rep/dincol.i un 12 num-chk9 fill11~} ~
      ~{ rep/dincol.i un 13 num-chk10 fill11~} ~
      ~{ rep/dincol.i un 14 num-chk11 fill11~} ~
      ~{ rep/dincol.i un 15 num-chk12 fill11~} ~
      ~{ rep/dincol.i un 16 num-chk13 fill11~} ~
      ~{ rep/dincol.i un 17 num-chk14 fill11~} ~
      ~{ rep/dincol.i un 18 num-chk15 fill11~} ~
      ~{ rep/dincol.i un 19 num-chk16 fill11~} ~
      ~{ rep/dincol.i un 20 num-chk17 fill11~} ~
      ~{ rep/dincol.i un 21 num-chk18 fill11~} ~
      ~{ rep/dincol.i un 22 num-chk19 fill11~} ~
      ~{ rep/dincol.i un 23 num-chk20 fill11~} ~
      ~{ rep/dincol.i un 24 num-chk21 fill11~} ~
      ~{ rep/dincol.i un 25 num-chk22 fill11~} ~
      ~{ rep/dincol.i un 26 num-chk23 fill11~} ~
      ~{ rep/dincol.i un 27 num-chk24 fill11~} ~
      ~{ rep/dincol.i un 28 tot-nc fill11~} ~
      DISPLAY stream  PrnLibStream with frame HOUR. ~
      DOWN 1 stream PrnLibStream with frame HOUR.

&SCOPED-DEFINE DISPLAY-FRAME         DISPLAY stream  PrnLibStream with frame HOUR. ~
                                     DOWN 1 stream PrnLibStream with frame HOUR.



/*обработка возвратов*/
define buffer for-grp for ub.gds-grp.
define variable sym1 as char init ":"   no-undo.
define variable sym2 as char init ":"   no-undo.
define variable sym3 as char init ":"   no-undo.
define variable Line as char no-undo.
define variable tot-nc as integer no-undo.
define variable ii as integer     no-undo .
define variable kk as integer     no-undo .
define buffer cli-obj for ub.clients .
define variable nc as integer no-undo.
define variable fill11 as character no-undo.
define variable fill1 as character no-undo.
define variable fill44 as character no-undo.
define variable cycle as integer no-undo .
define variable v-obj-code like ub.clients.obj-code no-undo .
define variable v-obj-name like ub.clients.obj-name no-undo .
define variable accum-sum as decimal extent 24 no-undo .
define variable accum-num-chk as integer extent 24 no-undo .
define variable accum-sum-grp as decimal extent 24 no-undo .
define variable accum-num-chk-grp as integer extent 24 no-undo .

define variable accum-tot-nc as integer no-undo .
define variable accum-tot-nc-grp as integer no-undo format ">>>>>9".
define variable accum-obj-list as integer no-undo .
define variable v-title as character no-undo .



assign
use-column[1] = yes
use-column[2] = yes
use-column[3] = yes
use-column[28] = yes
use-column[29] = yes
nc = 5
fill11 = fill("-", 11)
fill1 = fill("-", 1)
fill44 = fill("-", 44)

.

do ii = 1 to 24:
  if use-column[ii + 3] = yes then
  nc = nc + 1
  .
end.


DEFINE VARIABLE t-1 AS CHARACTER INITIAL "||||"
     VIEW-AS EDITOR
     SIZE 1 BY 4 NO-UNDO.


DEFINE FRAME top-frame
    t-1       AT ROW 1 COL 1 no-label
    HEADER
    cur-time-print() AT 5 format "x(35)"
    string( "Страница" ) AT 45 PAGE-NUMBER( PrnLibStream ) AT 55 FORMAT ">>9" SKIP
    with width {&DOS_CW_2} down stream-io use-text NO-BOX.

 DEFINE FRAME HOUR
   with width {&DOS_CW_2} down stream-io use-text NO-BOX.

CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .
l-col-pos = 1.
Assign l-col-type="CHARACTER" l-col-len=1  l-col-format="X(1)"       l-col-lable=":".
  { rep/dincol.i cr  1     sym1      hour                 }
Assign l-col-type="CHARACTER" l-col-len=44 l-col-format= "X(44)"
l-col-lable = (if method = "line"
then "Группа товаров ( по классификатору )"
else "ВИд платежа")
.
  { rep/dincol.i cr  2    full-name  hour                 }
Assign l-col-type="CHARACTER" l-col-len=1 l-col-format= "X(1)"       l-col-lable=":".
  { rep/dincol.i cr  3    sym2       hour                 }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable=" 0.00-0.59 ".
  { rep/dincol.i cr  4    num-chk1    hour        }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable=" 1.00-1.59 ".
  { rep/dincol.i cr  5    num-chk2    hour        }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable=" 2.00-2.59 ".
  { rep/dincol.i cr  6    num-chk3     hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable=" 3.00-3.59 ".
  { rep/dincol.i cr  7    num-chk4     hour      }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable=" 4.00-4.59 ".
  { rep/dincol.i cr  8    num-chk5     hour     }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable=" 5.00-5.59 ".
  { rep/dincol.i cr  9    num-chk6     hour      }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable=" 6.00-6.59 ".
  { rep/dincol.i cr  10   num-chk7     hour      }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable=" 7.00-7.59 ".
  { rep/dincol.i cr  11   num-chk8     hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable=" 8.00-8.59 ".
  { rep/dincol.i cr  12   num-chk9     hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable=" 9.00-9.59 ".
  { rep/dincol.i cr  13   num-chk10    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable="10.00-10.59".
  { rep/dincol.i cr  14   num-chk11    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable="11.00-11.59".
  { rep/dincol.i cr  15   num-chk12    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable="12.00-12.59".
  { rep/dincol.i cr  16   num-chk13    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable="13.00-13.59".
  { rep/dincol.i cr  17   num-chk14    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable="14.00-14.59".
  { rep/dincol.i cr  18   num-chk15    hour        }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable="15.00-15.59".
  { rep/dincol.i cr  19   num-chk16    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable="16.00-16.59".
  { rep/dincol.i cr  20   num-chk17    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable="17.00-17.59".
  { rep/dincol.i cr  21   num-chk18    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable="18.00-18.59".
  { rep/dincol.i cr  22   num-chk19    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable="19.00-19.59".
  { rep/dincol.i cr  23   num-chk20    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable="20.00-20.59".
  { rep/dincol.i cr  24   num-chk21    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable="21.00-21.59".
  { rep/dincol.i cr  25   num-chk22    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable="22.00-22.59".
  { rep/dincol.i cr  26   num-chk23    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->,>>>,>>9"  l-col-lable="23.00-23.59".
  { rep/dincol.i cr  27   num-chk24    hour       }
Assign l-col-type="INTEGER"   l-col-len=11 l-col-format= "->>,>>>,>>9"  l-col-lable="Итого по строке".
  { rep/dincol.i cr  28   tot-nc   hour               }
Assign l-col-type="CHARACTER" l-col-len=1  l-col-format="X(1)"       l-col-lable=":".
  { rep/dincol.i cr  29   sym3         hour       }

Line = fill( "-" , 60 ) .

{ rep/sv-grp-h.i }
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
FORM with FRAME Hour .
FORM HEADER
Line format "X(60)" AT 1 SKIP
string( "Продолжение - на следующей странице" ) FORMAT "X(40)" AT 10 SKIP
with FRAME NBottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW stream PrnLibStream FRAME NBottomFrame .
PUT stream PrnLibStream
SPACE(10)
"Почасовая статистика розничных продаж" format "x(80)" SKIP(0)
("( ПО ВЕЛИЧИНЕ СУММ ПРОДАЖ - СТРОКИ ЧЕКОВ) ЗА ПЕРИОД c " +
string( startdate, "99/99/9999" ) + " по " +
string( enddate, "99/99/9999" ) + ".")      format "x(80)" SKIP(0)
(IF RETS
then "ВОЗВРАТЫ УЧТЕНЫ"
ELSE "") format "x(80)" SKIP(0).
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
SPACE(10) trim( SelectObject )  skip(0)
(if byobject then "С разбивкой по объектам" else '':U) skip(1)
.
display STREAM PrnLibStream with frame top-Frame .
_cycle:
do cycle = 1 to 0 by -1:
  if byobject and cycle = 0 and accum-obj-list = 1 then LEAVE _cycle.
  _obj-list:
  for each obj-list no-lock:
    if not byobject and cycle = 1 then LEAVE _obj-list.
    if cycle = 1 then v-obj-code = obj-list.obj-code.
    if cycle = 0 then v-obj-code = 0.
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
    { rep/dincol.i di 1 sym1 sym1 }
    { rep/dincol.i di 2 full-name v-obj-name }
    {&DISPLAY-FRAME}
    {&UNDERLINE-FRAME}
    assign
    accum-count = 0
    tot-nc = 0
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
    accum-tot-nc = 0
    .
    assign
    accum-num-chk-grp[1] =  0
    accum-num-chk-grp[2] =  0
    accum-num-chk-grp[3] =  0
    accum-num-chk-grp[4] =  0
    accum-num-chk-grp[5] =  0
    accum-num-chk-grp[6] =  0
    accum-num-chk-grp[7] =  0
    accum-num-chk-grp[8] =  0
    accum-num-chk-grp[9] =  0
    accum-num-chk-grp[10] = 0
    accum-num-chk-grp[11] = 0
    accum-num-chk-grp[12] = 0
    accum-num-chk-grp[13] = 0
    accum-num-chk-grp[14] = 0
    accum-num-chk-grp[15] = 0
    accum-num-chk-grp[16] = 0
    accum-num-chk-grp[17] = 0
    accum-num-chk-grp[18] = 0
    accum-num-chk-grp[19] = 0
    accum-num-chk-grp[20] = 0
    accum-num-chk-grp[21] = 0
    accum-num-chk-grp[22] = 0
    accum-num-chk-grp[23] = 0
    accum-num-chk-grp[24] = 0
    accum-tot-nc-grp = 0
    .
    if byobject then do:
      for each sum-vals:
        ASSIGN
        sum-vals.num-chk[1] = 0
        sum-vals.num-chk[2] = 0
        sum-vals.num-chk[3] = 0
        sum-vals.num-chk[4] = 0
        sum-vals.num-chk[5] = 0
        sum-vals.num-chk[6] = 0
        sum-vals.num-chk[7] = 0
        sum-vals.num-chk[8] = 0
        sum-vals.num-chk[9] = 0
        sum-vals.num-chk[10] = 0
        sum-vals.num-chk[11] = 0
        sum-vals.num-chk[12] = 0
        sum-vals.num-chk[13] = 0
        sum-vals.num-chk[14] = 0
        sum-vals.num-chk[15] = 0
        sum-vals.num-chk[16] = 0
        sum-vals.num-chk[17] = 0
        sum-vals.num-chk[18] = 0
        sum-vals.num-chk[19] = 0
        sum-vals.num-chk[20] = 0
        sum-vals.num-chk[21] = 0
        sum-vals.num-chk[22] = 0
        sum-vals.num-chk[23] = 0
        sum-vals.num-chk[24] = 0
        sum-vals.tot         = 0
        .
      end.
    end.
    FOR EACH full-grp No-LOCK,
       EACH grp-h WHERE
           grp-h.obj-code = v-obj-code
       AND grp-h.grp-code = full-grp.grp-code
    BREAK
    BY full-grp.full-name
    BY grp-h.obj-code
    BY grp-h.grp-code
    BY grp-h.other-code
    BY grp-h.sum:
      if (method = "pay":U and first-of(grp-h.other-code)) OR
        (method <> "pay":U and first-of(grp-h.grp-code )) then do:
        assign
        accum-num-chk-grp[1] =  0
        accum-num-chk-grp[2] =  0
        accum-num-chk-grp[3] =  0
        accum-num-chk-grp[4] =  0
        accum-num-chk-grp[5] =  0
        accum-num-chk-grp[6] =  0
        accum-num-chk-grp[7] =  0
        accum-num-chk-grp[8] =  0
        accum-num-chk-grp[9] =  0
        accum-num-chk-grp[10] = 0
        accum-num-chk-grp[11] = 0
        accum-num-chk-grp[12] = 0
        accum-num-chk-grp[13] = 0
        accum-num-chk-grp[14] = 0
        accum-num-chk-grp[15] = 0
        accum-num-chk-grp[16] = 0
        accum-num-chk-grp[17] = 0
        accum-num-chk-grp[18] = 0
        accum-num-chk-grp[19] = 0
        accum-num-chk-grp[20] = 0
        accum-num-chk-grp[21] = 0
        accum-num-chk-grp[22] = 0
        accum-num-chk-grp[23] = 0
        accum-num-chk-grp[24] = 0
        accum-tot-nc-grp = 0
        tot-nc = 0
        .
        ACCUM-count = accum-count + 1.
        { rep/dincol.i di 1 sym1 sym1}
        { rep/dincol.i di 2 full-name full-grp.full-name }
        { rep/dincol.i di 3 sym2 sym2}
        {&DISPLAY-FRAME}

        { rep/dincol.i un 1 sym1 fill1}
        { rep/dincol.i un 3 sym2 fill1}
        { rep/dincol.i un 29 sym3 "'-'"}
        {&UNDERLINE-FRAME}
      end. /*if first-of grp-code*/
      FIND FIRST sum-vals where
              sum-vals.sum1= grp-h.sum1 NO-LOCK.
      tot-nc = 0.
      DO ii = 1 to 24:
        if use-column[ii + 3] = yes then
        tot-nc = tot-nc + grp-h.num-chk[ii].
      end.
      { rep/dincol.i di 1 sym1 sym1}
      { rep/dincol.i di 2 full-name "(string(sum-vals.sum1) + '-' + string(sum-vals.sum2) )" }
      { rep/dincol.i di 3 sym2 sym2}
      { rep/dincol.i di 4 num-chk1 grp-h.num-chk[1]}
      { rep/dincol.i di 5 num-chk2 grp-h.num-chk[2]}
      { rep/dincol.i di 6 num-chk3 grp-h.num-chk[3]}
      { rep/dincol.i di 7 num-chk4 grp-h.num-chk[4]}
      { rep/dincol.i di 8 num-chk5 grp-h.num-chk[5]}
      { rep/dincol.i di 9 num-chk6 grp-h.num-chk[6]}
      { rep/dincol.i di 10 num-chk7 grp-h.num-chk[7]}
      { rep/dincol.i di 11 num-chk8 grp-h.num-chk[8]}
      { rep/dincol.i di 12 num-chk9 grp-h.num-chk[9]}
      { rep/dincol.i di 13 num-chk10 grp-h.num-chk[10]}
      { rep/dincol.i di 14 num-chk11 grp-h.num-chk[11]}
      { rep/dincol.i di 15 num-chk12 grp-h.num-chk[12]}
      { rep/dincol.i di 16 num-chk13 grp-h.num-chk[13]}
      { rep/dincol.i di 17 num-chk14 grp-h.num-chk[14]}
      { rep/dincol.i di 18 num-chk15 grp-h.num-chk[15]}
      { rep/dincol.i di 19 num-chk16 grp-h.num-chk[16]}
      { rep/dincol.i di 20 num-chk17 grp-h.num-chk[17]}
      { rep/dincol.i di 21 num-chk18 grp-h.num-chk[18]}
      { rep/dincol.i di 22 num-chk19 grp-h.num-chk[19]}
      { rep/dincol.i di 23 num-chk20 grp-h.num-chk[20]}
      { rep/dincol.i di 24 num-chk21 grp-h.num-chk[21]}
      { rep/dincol.i di 25 num-chk22 grp-h.num-chk[22]}
      { rep/dincol.i di 26 num-chk23 grp-h.num-chk[23]}
      { rep/dincol.i di 27 num-chk24 grp-h.num-chk[24]}
      { rep/dincol.i di 28 tot-nc tot-nc}
      { rep/dincol.i di 29 sym3 sym3}
      {&DISPLAY-FRAME}
      ASSIGN
      /*по всему объекту  */
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
      accum-tot-nc = accum-tot-nc + tot-nc
      .
      /*подитоги по группе */
      assign
      accum-num-chk-grp[1] = accum-num-chk-grp[1] + grp-h.num-chk[1]
      accum-num-chk-grp[2] = accum-num-chk-grp[2] + grp-h.num-chk[2]
      accum-num-chk-grp[3] = accum-num-chk-grp[3] + grp-h.num-chk[3]
      accum-num-chk-grp[4] = accum-num-chk-grp[4] + grp-h.num-chk[4]
      accum-num-chk-grp[5] = accum-num-chk-grp[5] + grp-h.num-chk[5]
      accum-num-chk-grp[6] = accum-num-chk-grp[6] + grp-h.num-chk[6]
      accum-num-chk-grp[7] = accum-num-chk-grp[7] + grp-h.num-chk[7]
      accum-num-chk-grp[8] = accum-num-chk-grp[8] + grp-h.num-chk[8]
      accum-num-chk-grp[9] = accum-num-chk-grp[9] + grp-h.num-chk[9]
      accum-num-chk-grp[10] = accum-num-chk-grp[10] + grp-h.num-chk[10]
      accum-num-chk-grp[11] = accum-num-chk-grp[11] + grp-h.num-chk[11]
      accum-num-chk-grp[12] = accum-num-chk-grp[12] + grp-h.num-chk[12]
      accum-num-chk-grp[13] = accum-num-chk-grp[13] + grp-h.num-chk[13]
      accum-num-chk-grp[14] = accum-num-chk-grp[14] + grp-h.num-chk[14]
      accum-num-chk-grp[15] = accum-num-chk-grp[15] + grp-h.num-chk[15]
      accum-num-chk-grp[16] = accum-num-chk-grp[16] + grp-h.num-chk[16]
      accum-num-chk-grp[17] = accum-num-chk-grp[17] + grp-h.num-chk[17]
      accum-num-chk-grp[18] = accum-num-chk-grp[18] + grp-h.num-chk[18]
      accum-num-chk-grp[19] = accum-num-chk-grp[19] + grp-h.num-chk[19]
      accum-num-chk-grp[20] = accum-num-chk-grp[20] + grp-h.num-chk[20]
      accum-num-chk-grp[21] = accum-num-chk-grp[21] + grp-h.num-chk[21]
      accum-num-chk-grp[22] = accum-num-chk-grp[22] + grp-h.num-chk[22]
      accum-num-chk-grp[23] = accum-num-chk-grp[23] + grp-h.num-chk[23]
      accum-num-chk-grp[24] = accum-num-chk-grp[24] + grp-h.num-chk[24]
      accum-tot-nc-grp = accum-tot-nc-grp + tot-nc
      .
      ASSIGN
      sum-vals.num-chk[1] = sum-vals.num-chk[1] + grp-h.num-chk[1]
      sum-vals.num-chk[2] = sum-vals.num-chk[2] + grp-h.num-chk[2]
      sum-vals.num-chk[3] = sum-vals.num-chk[3] + grp-h.num-chk[3]
      sum-vals.num-chk[4] = sum-vals.num-chk[4] + grp-h.num-chk[4]
      sum-vals.num-chk[5] = sum-vals.num-chk[5] + grp-h.num-chk[5]
      sum-vals.num-chk[6] = sum-vals.num-chk[6] + grp-h.num-chk[6]
      sum-vals.num-chk[7] = sum-vals.num-chk[7] + grp-h.num-chk[7]
      sum-vals.num-chk[8] = sum-vals.num-chk[8] + grp-h.num-chk[8]
      sum-vals.num-chk[9] = sum-vals.num-chk[9] + grp-h.num-chk[9]
      sum-vals.num-chk[10] = sum-vals.num-chk[10] + grp-h.num-chk[10]
      sum-vals.num-chk[11] = sum-vals.num-chk[11] + grp-h.num-chk[11]
      sum-vals.num-chk[12] = sum-vals.num-chk[12] + grp-h.num-chk[12]
      sum-vals.num-chk[13] = sum-vals.num-chk[13] + grp-h.num-chk[13]
      sum-vals.num-chk[14] = sum-vals.num-chk[14] + grp-h.num-chk[14]
      sum-vals.num-chk[15] = sum-vals.num-chk[15] + grp-h.num-chk[15]
      sum-vals.num-chk[16] = sum-vals.num-chk[16] + grp-h.num-chk[16]
      sum-vals.num-chk[17] = sum-vals.num-chk[17] + grp-h.num-chk[17]
      sum-vals.num-chk[18] = sum-vals.num-chk[18] + grp-h.num-chk[18]
      sum-vals.num-chk[19] = sum-vals.num-chk[19] + grp-h.num-chk[19]
      sum-vals.num-chk[20] = sum-vals.num-chk[20] + grp-h.num-chk[20]
      sum-vals.num-chk[21] = sum-vals.num-chk[21] + grp-h.num-chk[21]
      sum-vals.num-chk[22] = sum-vals.num-chk[22] + grp-h.num-chk[22]
      sum-vals.num-chk[23] = sum-vals.num-chk[23] + grp-h.num-chk[23]
      sum-vals.num-chk[24] = sum-vals.num-chk[24] + grp-h.num-chk[24]
      sum-vals.tot = sum-vals.tot + tot-nc.

      IF (method = "pay":U and LAST-OF(grp-h.other-code))
      or (method = "LINE":U and LAST-OF(grp-h.grp-code)) then do:
        {&UNDERLINE-FRAME}
        if method = "pay" then do:
          { rep/dincol.i di 2 full-name "substitute('Итого &1 по виду платежа', v-obj-name)" }
        end.
        if method = "LINE" then do:
          { rep/dincol.i di 2 full-name "substitute('Итого &1 по группе', v-obj-name)" }
        end.
        { rep/dincol.i di 4 num-chk1 "accum-num-chk-grp[1]" }
        { rep/dincol.i di 5 num-chk2 "accum-num-chk-grp[2]" }
        { rep/dincol.i di 6 num-chk3 "accum-num-chk-grp[3]" }
        { rep/dincol.i di 7 num-chk4 "accum-num-chk-grp[4]" }
        { rep/dincol.i di 8 num-chk5 "accum-num-chk-grp[5]" }
        { rep/dincol.i di 9 num-chk6 "accum-num-chk-grp[6]" }
        { rep/dincol.i di 10 num-chk7 "accum-num-chk-grp[7]" }
        { rep/dincol.i di 11 num-chk8 "accum-num-chk-grp[8]" }
        { rep/dincol.i di 12 num-chk9 "accum-num-chk-grp[9]" }
        { rep/dincol.i di 13 num-chk10 "accum-num-chk-grp[10]" }
        { rep/dincol.i di 14 num-chk11 "accum-num-chk-grp[11]" }
        { rep/dincol.i di 15 num-chk12 "accum-num-chk-grp[12]" }
        { rep/dincol.i di 16 num-chk13 "accum-num-chk-grp[13]" }
        { rep/dincol.i di 17 num-chk14 "accum-num-chk-grp[14]" }
        { rep/dincol.i di 18 num-chk15 "accum-num-chk-grp[15]" }
        { rep/dincol.i di 19 num-chk16 "accum-num-chk-grp[16]" }
        { rep/dincol.i di 20 num-chk17 "accum-num-chk-grp[17]" }
        { rep/dincol.i di 21 num-chk18 "accum-num-chk-grp[18]" }
        { rep/dincol.i di 22 num-chk19 "accum-num-chk-grp[19]" }
        { rep/dincol.i di 23 num-chk20 "accum-num-chk-grp[20]" }
        { rep/dincol.i di 24 num-chk21 "accum-num-chk-grp[21]" }
        { rep/dincol.i di 25 num-chk22 "accum-num-chk-grp[22]" }
        { rep/dincol.i di 26 num-chk23 "accum-num-chk-grp[23]" }
        { rep/dincol.i di 27 num-chk24 "accum-num-chk-grp[24]" }
        { rep/dincol.i di 28 tot-nc    "ACCUM-tot-nc-grp" }
        {&DISPLAY-FRAME}
        if not last-of(grp-h.obj-code) then do:
          {&UNDERLINE-FRAME}
        end.
      end.  /*if last-of*/
    end. /*for eahc full-grp*/
    {&UNDERLINE-FRAME}
    IF  ACCUM-COUNT  > 1 then do:
      if method = "pay":U then do:
        { rep/dincol.i di 2 full-name " substitute('&1 по ВСЕМ ПЛАТЕЖАМ', v-obj-name)"  }
      end.
      else do:
        { rep/dincol.i di 2 full-name "substitute('&1 по ВСЕМ ГРУППАМ', v-obj-name) "  }
      end.
      {&DISPLAY-FRAME}
      {&UNDERLINE-FRAME}
      FOR EACH sum-vals NO-LOCK :
        if v-obj-code > 0 and accum-obj-list > 1 and sum-vals.tot = 0 then next.
        { rep/dincol.i di 1 sym1 sym1}
        { rep/dincol.i di 2 full-name "(string(sum-vals.sum1) + '-' + string(sum-vals.sum2) )" }
        { rep/dincol.i di 3 sym2 sym2}
        { rep/dincol.i di 4 num-chk1 sum-vals.num-chk[1]}
        { rep/dincol.i di 5 num-chk2 sum-vals.num-chk[2]}
        { rep/dincol.i di 6 num-chk3 sum-vals.num-chk[3]}
        { rep/dincol.i di 7 num-chk4 sum-vals.num-chk[4]}
        { rep/dincol.i di 8 num-chk5 sum-vals.num-chk[5]}
        { rep/dincol.i di 9 num-chk6 sum-vals.num-chk[6]}
        { rep/dincol.i di 10 num-chk7 sum-vals.num-chk[7]}
        { rep/dincol.i di 11 num-chk8 sum-vals.num-chk[8]}
        { rep/dincol.i di 12 num-chk9 sum-vals.num-chk[9]}
        { rep/dincol.i di 13 num-chk10 sum-vals.num-chk[10]}
        { rep/dincol.i di 14 num-chk11 sum-vals.num-chk[11]}
        { rep/dincol.i di 15 num-chk12 sum-vals.num-chk[12]}
        { rep/dincol.i di 16 num-chk13 sum-vals.num-chk[13]}
        { rep/dincol.i di 17 num-chk14 sum-vals.num-chk[14]}
        { rep/dincol.i di 18 num-chk15 sum-vals.num-chk[15]}
        { rep/dincol.i di 19 num-chk16 sum-vals.num-chk[16]}
        { rep/dincol.i di 20 num-chk17 sum-vals.num-chk[17]}
        { rep/dincol.i di 21 num-chk18 sum-vals.num-chk[18]}
        { rep/dincol.i di 22 num-chk19 sum-vals.num-chk[19]}
        { rep/dincol.i di 23 num-chk20 sum-vals.num-chk[20]}
        { rep/dincol.i di 24 num-chk21 sum-vals.num-chk[21]}
        { rep/dincol.i di 25 num-chk22 sum-vals.num-chk[22]}
        { rep/dincol.i di 26 num-chk23 sum-vals.num-chk[23]}
        { rep/dincol.i di 27 num-chk24 sum-vals.num-chk[24]}
        { rep/dincol.i di 28 tot-nc SUM-VALS.TOT}
        { rep/dincol.i di 29 sym3 sym3}
        {&DISPLAY-FRAME}
      END. /*FOR EACH sum-vals */
      {&UNDERLINE-FRAME}
    end. /*IF  (ACCUM COUNT grp-h.grp-code)  > 1*/
    assign
    v-title = substitute("Итого &1", v-obj-name).
    { rep/dincol.i di 2 full-name  v-title }
    { rep/dincol.i di 4 num-chk1 "accum-num-chk[1]"}
    { rep/dincol.i di 5 num-chk2 "accum-num-chk[2]"}
    { rep/dincol.i di 6 num-chk3 "accum-num-chk[3]"}
    { rep/dincol.i di 7 num-chk4 "accum-num-chk[4]"}
    { rep/dincol.i di 8 num-chk5 "accum-num-chk[5]"}
    { rep/dincol.i di 9 num-chk6 "accum-num-chk[6]"}
    { rep/dincol.i di 10 num-chk7 "accum-num-chk[7]"}
    { rep/dincol.i di 11 num-chk8 "accum-num-chk[8]"}
    { rep/dincol.i di 12 num-chk9 "accum-num-chk[9]"}
    { rep/dincol.i di 13 num-chk10 "accum-num-chk[10]"}
    { rep/dincol.i di 14 num-chk11 "accum-num-chk[11]"}
    { rep/dincol.i di 15 num-chk12 "accum-num-chk[12]"}
    { rep/dincol.i di 16 num-chk13 "accum-num-chk[13]"}
    { rep/dincol.i di 17 num-chk14 "accum-num-chk[14]"}
    { rep/dincol.i di 18 num-chk15 "accum-num-chk[15]"}
    { rep/dincol.i di 19 num-chk16 "accum-num-chk[16]"}
    { rep/dincol.i di 20 num-chk17 "accum-num-chk[17]"}
    { rep/dincol.i di 21 num-chk18 "accum-num-chk[18]"}
    { rep/dincol.i di 22 num-chk19 "accum-num-chk[19]"}
    { rep/dincol.i di 23 num-chk20 "accum-num-chk[20]"}
    { rep/dincol.i di 24 num-chk21 "accum-num-chk[21]"}
    { rep/dincol.i di 25 num-chk22 "accum-num-chk[22]"}
    { rep/dincol.i di 26 num-chk23 "accum-num-chk[23]"}
    { rep/dincol.i di 27 num-chk24 "accum-num-chk[24]"}
    { rep/dincol.i di 28 tot-nc    "ACCUM-tot-nc"}
    {&DISPLAY-FRAME}
    {&UNDERLINE-FRAME}
    if byobject and cycle = 0 then LEAVE _obj-list.
  end. /*for each obj-list*/
END . /*do cycle*/
HIDE STREAM PrnLibStream FRAME HOUR .
HIDE STREAM PrnLibStream FRAME top-Frame .
HIDE stream PrnLibStream FRAME NBottomFrame .
output stream PrnLibStream CLOSE .
run waitfram-hide in this-procedure .
DELETE WIDGET-POOL "My-pool".