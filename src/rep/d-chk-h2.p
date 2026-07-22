block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: d-chk-h2.p $
$Archive: rep/d-chk-h2.p $

Почасовой отчет по покупкам  - с разбивкой по группам и объектам стандартный вывод только на 13 часов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter startdate as date no-undo .
define input parameter enddate as date no-undo .
define input parameter SelectObject as character no-undo .
define input parameter rs-option as integer no-undo .
define input parameter by-object-str as character no-undo .
define input parameter WHstart as integer no-undo .
define input parameter WHEnd as integer no-undo .
define input parameter t-dis-card as logical no-undo .
define input parameter rs-dis-card as integer no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: d-chk-h2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/d-chk-h2.p $":U .
define variable vss-description as character no-undo init "Почасовой отчет по покупкам  - с разбивкой по группам и объектам стандартный вывод только на 13 часов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ cmp/r-page1.i  }
{ rep/dincol.i def }
{ rep/e-chkhdf.i SHARED }
{ rep/fulgrpdf.i }
{ ref/grplibfn.i }
{ gbl/waitfram.i }


define SHARED temp-table temp-dis-card-type no-undo like ub.dis-card-type.
&SCOPED-DEFINE UNDERLINE-FRAME  ~{ rep/dincol.i un 1 full-name fill56 ~} ~
      ~{ rep/dincol.i un 2 hour1 fill11 ~} ~
      ~{ rep/dincol.i un 3 hour2 fill11~} ~
      ~{ rep/dincol.i un 4 hour3 fill11~} ~
      ~{ rep/dincol.i un 5 hour4 fill11~} ~
      ~{ rep/dincol.i un 6 hour5 fill11~} ~
      ~{ rep/dincol.i un 7 hour6 fill11~} ~
      ~{ rep/dincol.i un 8 hour7 fill11~} ~
      ~{ rep/dincol.i un 9 hour8 fill11~} ~
      ~{ rep/dincol.i un 10 hour9 fill11~} ~
      ~{ rep/dincol.i un 11 hour10 fill11~} ~
      ~{ rep/dincol.i un 12 hour11 fill11~} ~
      ~{ rep/dincol.i un 13 hour12 fill11~} ~
      ~{ rep/dincol.i un 14 hour13 fill11~} ~
      ~{ rep/dincol.i un 15 hour14 fill11~} ~
      ~{ rep/dincol.i un 16 hour15 fill11~} ~
      ~{ rep/dincol.i un 17 hour16 fill11~} ~
      ~{ rep/dincol.i un 18 hour17 fill11~} ~
      ~{ rep/dincol.i un 19 hour18 fill11~} ~
      ~{ rep/dincol.i un 20 hour19 fill11~} ~
      ~{ rep/dincol.i un 21 hour20 fill11~} ~
      ~{ rep/dincol.i un 22 hour21 fill11~} ~
      ~{ rep/dincol.i un 23 hour22 fill11~} ~
      ~{ rep/dincol.i un 24 hour23 fill11~} ~
      ~{ rep/dincol.i un 25 hour24 fill11~} ~
      ~{ rep/dincol.i un 26 qnty fill15~} ~
      DISPLAY stream  PrnLibStream with frame HOUR. ~
      DOWN 1 stream PrnLibStream with frame HOUR.

&SCOPED-DEFINE DISPLAY-FRAME         DISPLAY stream  PrnLibStream with frame HOUR. ~
                                     DOWN 1 stream PrnLibStream with frame HOUR.

define SHARED variable ch         as integer   NO-UNDO extent 24.
define SHARED variable ch0         as integer   NO-UNDO.
define buffer   b-chk-h for chk-h .
define buffer   for-grp for ub.gds-grp.
define variable Line as character no-undo.
define variable     ii      as      integer     no-undo .
define variable     kk      as      integer     no-undo .
define buffer   cli-obj for ub.clients .
define variable nc as integer no-undo.
define variable fill11 as character no-undo.
define variable fill15 as character no-undo.
define variable fill1 as character no-undo.
define variable fill56 as character no-undo.
define variable cycle as integer no-undo .
define variable accum-hour as decimal no-undo extent 24.
define variable accum-qnty as decimal no-undo .
define variable byobject as logical no-undo .
define variable accum-obj-list as integer no-undo .
define variable v-obj-code like ub.clients.obj-code no-undo .
define variable v-obj-name like ub.clients.obj-name no-undo .
define variable obj-count as integer no-undo .
define variable v-title as character no-undo .



assign
byobject = (if rs-option = 2 or rs-option = 3 then yes else no)
use-column[1] = yes
use-column[26] = yes
nc = 2
fill11 = fill("-", 11)
fill15 = fill("-", 15)
fill1 = fill("-", 1)
fill56 = fill("-", 56)
.

do ii = 1 to 24:
  if use-column[ii + 1] = yes then
  nc = nc + 1
  .
end.


DEFINE VARIABLE t-1 AS CHARACTER INITIAL "||||"
     VIEW-AS EDITOR
     SIZE 1 BY 4 NO-UNDO.

DEFINE FRAME top-frame
    t-1       AT ROW 1 COL 1 no-label
    HEADER
      cur-time-print() AT 5 format "X(35)"
    string( "Страница" ) AT 45 PAGE-NUMBER( PrnLibStream ) AT 55 FORMAT ">>9" SKIP
    with width {&DOS_CW_2} down stream-io use-text NO-BOX.


 DEFINE FRAME HOUR
 with width {&DOS_CW_2} down stream-io use-text NO-BOX.

CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .
l-col-pos = 1.
Assign l-col-type="CHARACTER" l-col-len=56 l-col-format= "X(56)"     l-col-lable="Группа товаров ( по классификатору )".
  { rep/dincol.i cr  1    full-name  hour                 }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable=" 0.00-0.59 ".
  { rep/dincol.i cr  2    hour1    hour        }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable=" 1.00-1.59 ".
  { rep/dincol.i cr  3    hour2    hour        }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable=" 2.00-2.59 ".
  { rep/dincol.i cr  4    hour3     hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable=" 3.00-3.59 ".
  { rep/dincol.i cr  5    hour4     hour      }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable=" 4.00-4.59 ".
  { rep/dincol.i cr  6    hour5     hour     }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable=" 5.00-5.59 ".
  { rep/dincol.i cr  7    hour6     hour      }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable=" 6.00-6.59 ".
  { rep/dincol.i cr  8   hour7     hour      }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable=" 7.00-7.59 ".
  { rep/dincol.i cr  9   hour8     hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable=" 8.00-8.59 ".
  { rep/dincol.i cr  10   hour9     hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable=" 9.00-9.59 ".
  { rep/dincol.i cr  11   hour10    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable="10.00-10.59".
  { rep/dincol.i cr  12   hour11    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable="11.00-11.59".
  { rep/dincol.i cr  13   hour12    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable="12.00-12.59".
  { rep/dincol.i cr  14   hour13    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable="13.00-13.59".
  { rep/dincol.i cr  15   hour14    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable="14.00-14.59".
  { rep/dincol.i cr  16   hour15    hour        }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable="15.00-15.59".
  { rep/dincol.i cr  17   hour16    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable="16.00-16.59".
  { rep/dincol.i cr  18   hour17    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable="17.00-17.59".
  { rep/dincol.i cr  19   hour18    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable="18.00-18.59".
  { rep/dincol.i cr  20   hour19    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable="19.00-19.59".
  { rep/dincol.i cr  21   hour20    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable="20.00-20.59".
  { rep/dincol.i cr  22   hour21    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable="21.00-21.59".
  { rep/dincol.i cr  23   hour22    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable="22.00-22.59".
  { rep/dincol.i cr  24   hour23    hour       }
Assign l-col-type="INTEGER"   l-col-len=11  l-col-format= "->>,>>>,>>9"  l-col-lable="23.00-23.59".
  { rep/dincol.i cr  25   hour24    hour       }
Assign l-col-type="INTEGER"   l-col-len=15 l-col-format= "->>,>>>,>>>,>>9"  l-col-lable="Итого по строке".
  { rep/dincol.i cr  26   qnty         hour               }

Line = fill( "-" , 60 ) .
{ rep/d-chk-h.i }
if nc > 12 then do:
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
"Продолжение - на следующей странице" AT 10 SKIP
with FRAME NBottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW stream PrnLibStream FRAME NBottomFrame .
PUT stream PrnLibStream
SPACE(10)
("Почасовая статистика по количеству ПОКУПОК ЗА ПЕРИОД c " +
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
SPACE(10) SelectObject  SKIP(0)
by-object-str skip(1)
.
display STREAM PrnLibStream with frame top-Frame .
_cycle:
do cycle = 1 to 0 by -1:
  if byobject and cycle = 0 and accum-obj-list = 1 then LEAVE _cycle.
  _obj-list:
  for each obj-list no-lock:
    obj-count = obj-count + 1.
    if not byobject and cycle = 1 then LEAVE _obj-list.
    if cycle = 1 then v-obj-code = obj-list.obj-code.
    if cycle = 0 then v-obj-code = 0.
    if cycle = 1 then do:
      FIND FIRST ub.clients NO-LOCK WHERE
                ub.clients.obj-code = v-obj-code AND
                ub.clients.obj-type = {&shop} NO-ERROR.
      if available clients then do:
        v-obj-name = ub.clients.obj-name.
      end.
      else v-obj-name = string(v-obj-code).
    end.
    if byobject and cycle = 0 then do:
      v-obj-name = "ПО ВСЕМ ОБЪЕКТАМ".
    end.
    if rs-option <> 3 and byobject then do:
      { rep/dincol.i di 1 full-name v-obj-name }
      {&DISPLAY-FRAME}
      {&UNDERLINE-FRAME}
    end.
    assign
    accum-hour[1]  = 0
    accum-hour[2]  = 0
    accum-hour[3]  = 0
    accum-hour[4]  = 0
    accum-hour[5]  = 0
    accum-hour[6]  = 0
    accum-hour[7]  = 0
    accum-hour[8]  = 0
    accum-hour[9]  = 0
    accum-hour[10] = 0
    accum-hour[11] = 0
    accum-hour[12] = 0
    accum-hour[13] = 0
    accum-hour[14] = 0
    accum-hour[15] = 0
    accum-hour[16] = 0
    accum-hour[17] = 0
    accum-hour[18] = 0
    accum-hour[19] = 0
    accum-hour[20] = 0
    accum-hour[21] = 0
    accum-hour[22] = 0
    accum-hour[23] = 0
    accum-hour[24] = 0
    accum-qnty     = 0
    .
    _full-grp:
    FOR EACH full-grp No-LOCK,
        EACH chk-h NO-LOCK where
            chk-h.obj-code = v-obj-code
        AND chk-h.grp-code = full-grp.grp-code
    BREAK
    BY full-grp.full-name
    BY chk-h.grp-code:
      if cycle = 0 or rs-option = 2 then do:
        if first-of( chk-h.grp-code ) then do:
          if not (cycle = 0 and rs-option = 3) then do:
            if (chk-h.hour[1] <> 0) OR (chk-h.hour[2]<> 0) OR (chk-h.hour[3]<> 0) OR (chk-h.hour[4]<> 0) OR
                (chk-h.hour[5] <> 0) OR (chk-h.hour[6] <> 0) OR (chk-h.hour[7] <> 0) OR (chk-h.hour[8] <> 0) OR
                (chk-h.hour[9] <> 0) OR (chk-h.hour[10] <> 0) OR (chk-h.hour[11] <> 0) OR (chk-h.hour[12] <> 0) OR
                (chk-h.hour[13] <> 0) OR (chk-h.hour[14] <> 0) OR (chk-h.hour[15] <> 0) OR (chk-h.hour[16] <> 0) OR
                (chk-h.hour[17] <> 0) OR (chk-h.hour[18] <> 0) OR (chk-h.hour[19] <> 0) OR (chk-h.hour[20] <> 0) OR
                (chk-h.hour[21] <> 0) OR (chk-h.hour[22] <> 0) OR (chk-h.hour[23] <> 0) OR (chk-h.hour[24] <> 0) then do:
              { rep/dincol.i di 1 full-name full-name }
              { rep/dincol.i di 2 hour1 chk-h.hour[1]}
              { rep/dincol.i di 3 hour2 chk-h.hour[2]}
              { rep/dincol.i di 4 hour3 chk-h.hour[3]}
              { rep/dincol.i di 5 hour4 chk-h.hour[4]}
              { rep/dincol.i di 6 hour5 chk-h.hour[5]}
              { rep/dincol.i di 7 hour6 chk-h.hour[6]}
              { rep/dincol.i di 8 hour7 chk-h.hour[7]}
              { rep/dincol.i di 9 hour8 chk-h.hour[8]}
              { rep/dincol.i di 10 hour9 chk-h.hour[9]}
              { rep/dincol.i di 11 hour10 chk-h.hour[10]}
              { rep/dincol.i di 12 hour11 chk-h.hour[11]}
              { rep/dincol.i di 13 hour12 chk-h.hour[12]}
              { rep/dincol.i di 14 hour13 chk-h.hour[13]}
              { rep/dincol.i di 15 hour14 chk-h.hour[14]}
              { rep/dincol.i di 16 hour15 chk-h.hour[15]}
              { rep/dincol.i di 17 hour16 chk-h.hour[16]}
              { rep/dincol.i di 18 hour17 chk-h.hour[17]}
              { rep/dincol.i di 19 hour18 chk-h.hour[18]}
              { rep/dincol.i di 20 hour19 chk-h.hour[19]}
              { rep/dincol.i di 21 hour20 chk-h.hour[20]}
              { rep/dincol.i di 22 hour21 chk-h.hour[21]}
              { rep/dincol.i di 23 hour22 chk-h.hour[22]}
              { rep/dincol.i di 24 hour23 chk-h.hour[23]}
              { rep/dincol.i di 25 hour24 chk-h.hour[24]}
              { rep/dincol.i di 26 qnty      chk-h.qnty}
              {&DISPLAY-FRAME}
            end.
          end. /*if not (cycle = 0 and rs-option = 3) then do: */
        end. /*if first-of grp-h*/
      end. /*if cycle = 0 or rs-option <> 3*/
      assign
      accum-hour[1] = accum-hour[1] + chk-h.hour[1]
      accum-hour[2] = accum-hour[2] + chk-h.hour[2]
      accum-hour[3] = accum-hour[3] + chk-h.hour[3]
      accum-hour[4] = accum-hour[4] + chk-h.hour[4]
      accum-hour[5] = accum-hour[5] + chk-h.hour[5]
      accum-hour[6] = accum-hour[6] + chk-h.hour[6]
      accum-hour[7] = accum-hour[7] + chk-h.hour[7]
      accum-hour[8] = accum-hour[8] + chk-h.hour[8]
      accum-hour[9] = accum-hour[9] + chk-h.hour[9]
      accum-hour[10] = accum-hour[10] + chk-h.hour[10]
      accum-hour[11] = accum-hour[11] + chk-h.hour[11]
      accum-hour[12] = accum-hour[12] + chk-h.hour[12]
      accum-hour[13] = accum-hour[13] + chk-h.hour[13]
      accum-hour[14] = accum-hour[14] + chk-h.hour[14]
      accum-hour[15] = accum-hour[15] + chk-h.hour[15]
      accum-hour[16] = accum-hour[16] + chk-h.hour[16]
      accum-hour[17] = accum-hour[17] + chk-h.hour[17]
      accum-hour[18] = accum-hour[18] + chk-h.hour[18]
      accum-hour[19] = accum-hour[19] + chk-h.hour[19]
      accum-hour[20] = accum-hour[20] + chk-h.hour[20]
      accum-hour[21] = accum-hour[21] + chk-h.hour[21]
      accum-hour[22] = accum-hour[22] + chk-h.hour[22]
      accum-hour[23] = accum-hour[23] + chk-h.hour[23]
      accum-hour[24] = accum-hour[24] + chk-h.hour[24]
      accum-qnty = accum-qnty + chk-h.qnty
      .
    end. /*for each full-grp*/
    if rs-option = 2 and accum-qnty = 0 then.
    else do:
        if rs-option <> 3 then do:
          {&UNDERLINE-FRAME}
        end.
    end.
    if cycle = 0 and rs-option = 3 then do:
      {&UNDERLINE-FRAME}
    end.
    if rs-option = 3 then do:
      v-title = v-obj-name.
    end.
    else do:
      v-title = substitute('ИТОГО &1', v-obj-name).
    end.
    { rep/dincol.i di 1 full-name v-title }
    { rep/dincol.i di 2 hour1 "accum-hour[1]"}
    { rep/dincol.i di 3 hour2 "accum-hour[2]"}
    { rep/dincol.i di 4 hour3 "accum-hour[3]"}
    { rep/dincol.i di 5 hour4 "accum-hour[4]"}
    { rep/dincol.i di 6 hour5 "accum-hour[5]"}
    { rep/dincol.i di 7 hour6 "accum-hour[6]"}
    { rep/dincol.i di 8 hour7 "accum-hour[7]"}
    { rep/dincol.i di 9 hour8 "accum-hour[8]"}
    { rep/dincol.i di 10 hour9 "accum-hour[9]"}
    { rep/dincol.i di 11 hour10 "accum-hour[10]"}
    { rep/dincol.i di 12 hour11 "accum-hour[11]"}
    { rep/dincol.i di 13 hour12 "accum-hour[12]"}
    { rep/dincol.i di 14 hour13 "accum-hour[13]"}
    { rep/dincol.i di 15 hour14 "accum-hour[14]"}
    { rep/dincol.i di 16 hour15 "accum-hour[15]"}
    { rep/dincol.i di 17 hour16 "accum-hour[16]"}
    { rep/dincol.i di 18 hour17 "accum-hour[17]"}
    { rep/dincol.i di 19 hour18 "accum-hour[18]"}
    { rep/dincol.i di 20 hour19 "accum-hour[19]"}
    { rep/dincol.i di 21 hour20 "accum-hour[20]"}
    { rep/dincol.i di 22 hour21 "accum-hour[21]"}
    { rep/dincol.i di 23 hour22 "accum-hour[22]"}
    { rep/dincol.i di 24 hour23 "accum-hour[23]"}
    { rep/dincol.i di 25 hour24 "accum-hour[24]"}
    { rep/dincol.i di 26 qnty      "accum-qnty"}
    {&DISPLAY-FRAME}
    /*выведем кол-во чеков по часам*/
    find first num-h where num-h.obj-code = v-obj-code no-error .
     v-title = substitute('Пробито чеков &1', v-obj-name).
    if available num-h then do:
      { rep/dincol.i di 1 full-name v-title }
      { rep/dincol.i di 2 hour1 num-h.hour[1]}
      { rep/dincol.i di 3 hour2 num-h.hour[2]}
      { rep/dincol.i di 4 hour3 num-h.hour[3]}
      { rep/dincol.i di 5 hour4 num-h.hour[4]}
      { rep/dincol.i di 6 hour5 num-h.hour[5]}
      { rep/dincol.i di 7 hour6 num-h.hour[6]}
      { rep/dincol.i di 8 hour7 num-h.hour[7]}
      { rep/dincol.i di 9 hour8 num-h.hour[8]}
      { rep/dincol.i di 10 hour9 num-h.hour[9]}
      { rep/dincol.i di 11 hour10 num-h.hour[10]}
      { rep/dincol.i di 12 hour11 num-h.hour[11]}
      { rep/dincol.i di 13 hour12 num-h.hour[12]}
      { rep/dincol.i di 14 hour13 num-h.hour[13]}
      { rep/dincol.i di 15 hour14 num-h.hour[14]}
      { rep/dincol.i di 16 hour15 num-h.hour[15]}
      { rep/dincol.i di 17 hour16 num-h.hour[16]}
      { rep/dincol.i di 18 hour17 num-h.hour[17]}
      { rep/dincol.i di 19 hour18 num-h.hour[18]}
      { rep/dincol.i di 20 hour19 num-h.hour[19]}
      { rep/dincol.i di 21 hour20 num-h.hour[20]}
      { rep/dincol.i di 22 hour21 num-h.hour[21]}
      { rep/dincol.i di 23 hour22 num-h.hour[22]}
      { rep/dincol.i di 24 hour23 num-h.hour[23]}
      { rep/dincol.i di 25 hour24 num-h.hour[24]}
      { rep/dincol.i di 26 qnty   num-h.qnty}
      {&DISPLAY-FRAME}
    end.
    {&UNDERLINE-FRAME}
    if cycle = 0 then LEAVE _obj-list.
  end. /*for each obj-list*/
end. /*do cycle*/
HIDE STREAM PrnLibStream FRAME HOUR .
HIDE STREAM PrnLibStream FRAME top-Frame .
HIDE stream PrnLibStream FRAME NBottomFrame .
output stream PrnLibStream CLOSE .
run waitfram-hide in this-procedure .
DELETE WIDGET-POOL "My-pool".