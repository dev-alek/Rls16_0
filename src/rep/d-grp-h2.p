block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: d-grp-h2.p $
$Archive: rep/d-grp-h2.p $

Почасовой отчет по товарам  - с разбивкой по группам и объектам стандартный вывод только на 12 часов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter startdate as date no-undo .
define input parameter enddate as date no-undo .
define input parameter SelectObject as character no-undo .
define input parameter RS-option as integer no-undo .
define input parameter by-object-str as character no-undo .
define input parameter With-Goods as log no-undo .
define input parameter With-Scale as log no-undo .
define input parameter WHStart as integer no-undo .
define input parameter WHEnd as integer no-undo .
define input parameter t-dis-card as logical no-undo .
define input parameter rs-dis-card as integer no-undo .
define input parameter p-selectGood as integer no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: d-grp-h2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/d-grp-h2.p $":U .
define variable vss-description as character no-undo init "Почасовой отчет по товарам  - с разбивкой по группам и объектам стандартный вывод только на 12 часов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ cmp/r-page1.i  }
{ rep/dincol.i def }
{ rep/e-grphdf.i SHARED }
{ rep/fulgrpdf.i }
{ ref/grplibfn.i }
{ gbl/waitfram.i }

DEFINE SHARED TEMP-TABLE temp-dis-card-type NO-UNDO LIKE ub.dis-card-type.

&SCOPED-DEFINE UNDERLINE-FRAME  ~{ rep/dincol.i un 2 full-name fill56 ~} ~
      ~{ rep/dincol.i un 4 hour1 fill12 ~} ~
      ~{ rep/dincol.i un 5 hour2 fill12~} ~
      ~{ rep/dincol.i un 6 hour3 fill12~} ~
      ~{ rep/dincol.i un 7 hour4 fill12~} ~
      ~{ rep/dincol.i un 8 hour5 fill12~} ~
      ~{ rep/dincol.i un 9 hour6 fill12~} ~
      ~{ rep/dincol.i un 10 hour7 fill12~} ~
      ~{ rep/dincol.i un 11 hour8 fill12~} ~
      ~{ rep/dincol.i un 12 hour9 fill12~} ~
      ~{ rep/dincol.i un 13 hour10 fill12~} ~
      ~{ rep/dincol.i un 14 hour11 fill12~} ~
      ~{ rep/dincol.i un 15 hour12 fill12~} ~
      ~{ rep/dincol.i un 16 hour13 fill12~} ~
      ~{ rep/dincol.i un 17 hour14 fill12~} ~
      ~{ rep/dincol.i un 18 hour15 fill12~} ~
      ~{ rep/dincol.i un 19 hour16 fill12~} ~
      ~{ rep/dincol.i un 20 hour17 fill12~} ~
      ~{ rep/dincol.i un 21 hour18 fill12~} ~
      ~{ rep/dincol.i un 22 hour19 fill12~} ~
      ~{ rep/dincol.i un 23 hour20 fill12~} ~
      ~{ rep/dincol.i un 24 hour21 fill12~} ~
      ~{ rep/dincol.i un 25 hour22 fill12~} ~
      ~{ rep/dincol.i un 26 hour23 fill12~} ~
      ~{ rep/dincol.i un 27 hour24 fill12~} ~
      ~{ rep/dincol.i un 28 qnty fill15~} ~
      DISPLAY stream  PrnLibStream with frame HOUR. ~
      DOWN 1 stream PrnLibStream with frame HOUR.

&SCOPED-DEFINE DISPLAY-FRAME         DISPLAY stream  PrnLibStream with frame HOUR. ~
                                     DOWN 1 stream PrnLibStream with frame HOUR.

define buffer for-grp for ub.gds-grp.
define buffer b-grp-h for grp-h .
define buffer b-gds-h for gds-h .
define variable sym1 as character init ":"   no-undo.
define variable sym2 as character init ":"   no-undo.
define variable sym3 as character init ":"   no-undo.
define variable Line as character no-undo.
define variable     ii      as      integer     no-undo .
define variable     kk      as      integer     no-undo .
define buffer cli-obj for ub.clients .
define variable nc as integer no-undo.
define variable fill15 as character no-undo.
define variable fill12 as character no-undo.
define variable fill1 as character no-undo.
define variable fill56 as character no-undo.
DEFINE VARIABLE acc-gds-hour as decimal no-undo extent 24.
DEFINE VARIABLE acc-gds-qnty as decimal no-undo .
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
use-column[2] = yes
use-column[3] = yes
use-column[28] = yes
use-column[29] = yes
nc = 5
fill15 = fill("-", 15)
fill12 = fill("-", 12)
fill1 = fill("-", 1)
fill56 = fill("-", 56)
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
Assign l-col-type="CHARACTER" l-col-len=56 l-col-format= "X(56)"     l-col-lable="Группа товаров ( по классификатору )".
  { rep/dincol.i cr  2    full-name  hour                 }
Assign l-col-type="CHARACTER" l-col-len=1 l-col-format= "X(1)"       l-col-lable=":".
  { rep/dincol.i cr  3    sym2       hour                 }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable=" 0.00-0.59 ".
  { rep/dincol.i cr  4    hour1    hour        }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable=" 1.00-1.59 ".
  { rep/dincol.i cr  5    hour2    hour        }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable=" 2.00-2.59 ".
  { rep/dincol.i cr  6    hour3     hour       }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable=" 3.00-3.59 ".
  { rep/dincol.i cr  7    hour4     hour      }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable=" 4.00-4.59 ".
  { rep/dincol.i cr  8    hour5     hour     }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable=" 5.00-5.59 ".
  { rep/dincol.i cr  9    hour6     hour      }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable=" 6.00-6.59 ".
  { rep/dincol.i cr  10   hour7     hour      }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable=" 7.00-7.59 ".
  { rep/dincol.i cr  11   hour8     hour       }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable=" 8.00-8.59 ".
  { rep/dincol.i cr  12   hour9     hour       }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable=" 9.00-9.59 ".
  { rep/dincol.i cr  13   hour10    hour       }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable="10.00-10.59".
  { rep/dincol.i cr  14   hour11    hour       }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable="11.00-11.59".
  { rep/dincol.i cr  15   hour12    hour       }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable="12.00-12.59".
  { rep/dincol.i cr  16   hour13    hour       }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable="13.00-13.59".
  { rep/dincol.i cr  17   hour14    hour       }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable="14.00-14.59".
  { rep/dincol.i cr  18   hour15    hour        }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable="15.00-15.59".
  { rep/dincol.i cr  19   hour16    hour       }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable="16.00-16.59".
  { rep/dincol.i cr  20   hour17    hour       }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable="17.00-17.59".
  { rep/dincol.i cr  21   hour18    hour       }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable="18.00-18.59".
  { rep/dincol.i cr  22   hour19    hour       }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable="19.00-19.59".
  { rep/dincol.i cr  23   hour20    hour       }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable="20.00-20.59".
  { rep/dincol.i cr  24   hour21    hour       }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable="21.00-21.59".
  { rep/dincol.i cr  25   hour22    hour       }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable="22.00-22.59".
  { rep/dincol.i cr  26   hour23    hour       }
Assign l-col-type="DECIMAL"   l-col-len=11  l-col-format= "->>>,>>9.<<<"  l-col-lable="23.00-23.59".
  { rep/dincol.i cr  27   hour24    hour       }
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format= "->>,>>>,>>9.<<<"  l-col-lable="Итого по строке".
  { rep/dincol.i cr  28   qnty         hour               }
Assign l-col-type="CHARACTER" l-col-len=1  l-col-format="X(1)"       l-col-lable=":".
  { rep/dincol.i cr  29   sym3         hour       }

Line = fill( "-" , 60 ) .

{ rep/d-grp-h.i }

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
"Продолжение - на следующей странице" AT 10 SKIP
with FRAME NBottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW stream PrnLibStream FRAME NBottomFrame .
PUT stream PrnLibStream
SPACE(10)
("Почасовая статистика розничных продаж ( по количеству ТОВАРОВ ) ЗА ПЕРИОД c " +
string( startdate, "99/99/9999" ) + " по " + string( enddate, "99/99/9999" ) + ".")      format "x(110)" SKIP(1).
if p-SelectGood = {&g-prod} then do:
  PUT STREAM PrnLibStream  "По производителям: " skip space(50) .
  FOR EACH g#cli :
      FIND FIRST cli-obj WHERE
                  cli-obj.obj-type = g#cli.obj-type AND
                  cli-obj.obj-code = g#cli.obj-code NO-LOCK .
      PUT STREAM PrnLibStream  cli-obj.obj-name format "x(80)" skip space(50) .
  END.
end.
define variable counter as integer no-undo .
if p-SelectGood = {&g-choice} then do:
  counter = 0.
  PUT STREAM PrnLibStream  "По списку товаров: " skip .
  FOR EACH gds-list :
      PUT STREAM PrnLibStream  unformatted
      substitute("&1 &2 &3&4&5"
                  , fill( {&space-char}, 10 )
                  , gds-list.gds-code
                  , gds-list.artic
                  , gds-list.prod-type
                  , gds-list.prod-code

                  )
      .
      counter = counter + 1.
      if counter = 3 then do:
        PUT STREAM PrnLibStream  unformatted skip.
        counter = 0.
      end.
  END.
  PUT STREAM PrnLibStream  unformatted skip.
end.
if p-selectgood = {&g-grp} then do:
  PUT stream PrnLibStream
  space(20)  "По группам товаров: " format "x(80)" skip(0) .
  for each tmp#grp:
      PUT stream PrnLibStream
      space(20) tmp#grp.grp-name format "x(80)" skip(0) .
  end.
end.

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
      if available ub.clients then do:
        v-obj-name = ub.clients.obj-name.
      end.
      else v-obj-name = string(v-obj-code).
    end.
    if byobject and cycle = 0 then do:
      v-obj-name = "ПО ВСЕМ ОБЪЕКТАМ".
    end.
    if rs-option <> 3 and byobject then do:
      { rep/dincol.i di 1 sym1 sym1}
      { rep/dincol.i di 2 full-name v-obj-name }
      { rep/dincol.i di 3 sym2 sym2}
      { rep/dincol.i di 29 sym3 sym3}
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
        EACH grp-h NO-LOCK where
            grp-h.obj-code = v-obj-code  AND
            grp-h.grp-code = full-grp.grp-code
    BREAK
    BY full-grp.full-name
    BY grp-h.grp-code:
      if cycle = 0 or rs-option = 2 then do:
        if first-of( grp-h.grp-code ) then do:
          if not (cycle = 0 and rs-option = 3) then do:
            { rep/dincol.i di 1 sym1 sym1}
            { rep/dincol.i di 2 full-name full-name }
            { rep/dincol.i di 3 sym2 sym2}
            { rep/dincol.i di 4 hour1 grp-h.hour[1]}
            { rep/dincol.i di 5 hour2 grp-h.hour[2]}
            { rep/dincol.i di 6 hour3 grp-h.hour[3]}
            { rep/dincol.i di 7 hour4 grp-h.hour[4]}
            { rep/dincol.i di 8 hour5 grp-h.hour[5]}
            { rep/dincol.i di 9 hour6 grp-h.hour[6]}
            { rep/dincol.i di 10 hour7 grp-h.hour[7]}
            { rep/dincol.i di 11 hour8 grp-h.hour[8]}
            { rep/dincol.i di 12 hour9 grp-h.hour[9]}
            { rep/dincol.i di 13 hour10 grp-h.hour[10]}
            { rep/dincol.i di 14 hour11 grp-h.hour[11]}
            { rep/dincol.i di 15 hour12 grp-h.hour[12]}
            { rep/dincol.i di 16 hour13 grp-h.hour[13]}
            { rep/dincol.i di 17 hour14 grp-h.hour[14]}
            { rep/dincol.i di 18 hour15 grp-h.hour[15]}
            { rep/dincol.i di 19 hour16 grp-h.hour[16]}
            { rep/dincol.i di 20 hour17 grp-h.hour[17]}
            { rep/dincol.i di 21 hour18 grp-h.hour[18]}
            { rep/dincol.i di 22 hour19 grp-h.hour[19]}
            { rep/dincol.i di 23 hour20 grp-h.hour[20]}
            { rep/dincol.i di 24 hour21 grp-h.hour[21]}
            { rep/dincol.i di 25 hour22 grp-h.hour[22]}
            { rep/dincol.i di 26 hour23 grp-h.hour[23]}
            { rep/dincol.i di 27 hour24 grp-h.hour[24]}
            { rep/dincol.i di 28 qnty      grp-h.qnty}
            { rep/dincol.i di 29 sym3 sym3}
            {&DISPLAY-FRAME}
          end.
          if With-Goods then do:
            {&UNDERLINE-FRAME}
            FOR EACH gds-h WHERE
                    gds-h.grp-code = grp-h.grp-code AND
                    gds-h.obj-code = v-obj-code
                BREAK
                BY gds-h.uniq :
              if not with-scale or gds-h.is-empty then do:
                { rep/dincol.i di 1 sym1 sym1}
                { rep/dincol.i di 2 full-name "string( fill( {&space-char}, 3 ) + string( gds-h.artic, 'x(16)' ) + {&space-char} + gds-h.gds-name )" }
                { rep/dincol.i di 3 sym2 sym2}
                { rep/dincol.i di 4 hour1 gds-h.hour[1]}
                { rep/dincol.i di 5 hour2 gds-h.hour[2]}
                { rep/dincol.i di 6 hour3 gds-h.hour[3]}
                { rep/dincol.i di 7 hour4 gds-h.hour[4]}
                { rep/dincol.i di 8 hour5 gds-h.hour[5]}
                { rep/dincol.i di 9 hour6 gds-h.hour[6]}
                { rep/dincol.i di 10 hour7 gds-h.hour[7]}
                { rep/dincol.i di 11 hour8 gds-h.hour[8]}
                { rep/dincol.i di 12 hour9 gds-h.hour[9]}
                { rep/dincol.i di 13 hour10 gds-h.hour[10]}
                { rep/dincol.i di 14 hour11 gds-h.hour[11]}
                { rep/dincol.i di 15 hour12 gds-h.hour[12]}
                { rep/dincol.i di 16 hour13 gds-h.hour[13]}
                { rep/dincol.i di 17 hour14 gds-h.hour[14]}
                { rep/dincol.i di 18 hour15 gds-h.hour[15]}
                { rep/dincol.i di 19 hour16 gds-h.hour[16]}
                { rep/dincol.i di 20 hour17 gds-h.hour[17]}
                { rep/dincol.i di 21 hour18 gds-h.hour[18]}
                { rep/dincol.i di 22 hour19 gds-h.hour[19]}
                { rep/dincol.i di 23 hour20 gds-h.hour[20]}
                { rep/dincol.i di 24 hour21 gds-h.hour[21]}
                { rep/dincol.i di 25 hour22 gds-h.hour[22]}
                { rep/dincol.i di 26 hour23 gds-h.hour[23]}
                { rep/dincol.i di 27 hour24 gds-h.hour[24]}
                { rep/dincol.i di 28 qnty      gds-h.qnty}
                { rep/dincol.i di 29 sym3 sym3}
                {&DISPLAY-FRAME}
              end.
              else do:
                /*шкальный товар*/
                if first-of(gds-h.uniq) then do:
                  assign
                  acc-gds-hour[1] = 0
                  acc-gds-hour[2] = 0
                  acc-gds-hour[3] = 0
                  acc-gds-hour[4] = 0
                  acc-gds-hour[5] = 0
                  acc-gds-hour[6] = 0
                  acc-gds-hour[7] = 0
                  acc-gds-hour[8] = 0
                  acc-gds-hour[9] = 0
                  acc-gds-hour[10] = 0
                  acc-gds-hour[11] = 0
                  acc-gds-hour[12] = 0
                  acc-gds-hour[13] = 0
                  acc-gds-hour[14] = 0
                  acc-gds-hour[15] = 0
                  acc-gds-hour[16] = 0
                  acc-gds-hour[17] = 0
                  acc-gds-hour[18] = 0
                  acc-gds-hour[19] = 0
                  acc-gds-hour[20] = 0
                  acc-gds-hour[21] = 0
                  acc-gds-hour[22] = 0
                  acc-gds-hour[23] = 0
                  acc-gds-hour[24] = 0
                  acc-gds-qnty = 0
                  .
                  for each b-gds-h no-lock where
                          b-gds-h.uniq = gds-h.uniq AND
                          b-gds-h.obj-code = v-obj-code:
                    assign
                    acc-gds-hour[1]  = acc-gds-hour[1]  + b-gds-h.hour[1]
                    acc-gds-hour[2]  = acc-gds-hour[2]  + b-gds-h.hour[2]
                    acc-gds-hour[3]  = acc-gds-hour[3]  + b-gds-h.hour[3]
                    acc-gds-hour[4]  = acc-gds-hour[4]  + b-gds-h.hour[4]
                    acc-gds-hour[5]  = acc-gds-hour[5]  + b-gds-h.hour[5]
                    acc-gds-hour[6]  = acc-gds-hour[6]  + b-gds-h.hour[6]
                    acc-gds-hour[7]  = acc-gds-hour[7]  + b-gds-h.hour[7]
                    acc-gds-hour[8]  = acc-gds-hour[8]  + b-gds-h.hour[8]
                    acc-gds-hour[9]  = acc-gds-hour[9]  + b-gds-h.hour[9]
                    acc-gds-hour[10] = acc-gds-hour[10] + b-gds-h.hour[10]
                    acc-gds-hour[11] = acc-gds-hour[11] + b-gds-h.hour[11]
                    acc-gds-hour[12] = acc-gds-hour[12] + b-gds-h.hour[12]
                    acc-gds-hour[13] = acc-gds-hour[13] + b-gds-h.hour[13]
                    acc-gds-hour[14] = acc-gds-hour[14] + b-gds-h.hour[14]
                    acc-gds-hour[15] = acc-gds-hour[15] + b-gds-h.hour[15]
                    acc-gds-hour[16] = acc-gds-hour[16] + b-gds-h.hour[16]
                    acc-gds-hour[17] = acc-gds-hour[17] + b-gds-h.hour[17]
                    acc-gds-hour[18] = acc-gds-hour[18] + b-gds-h.hour[18]
                    acc-gds-hour[19] = acc-gds-hour[19] + b-gds-h.hour[19]
                    acc-gds-hour[20] = acc-gds-hour[20] + b-gds-h.hour[20]
                    acc-gds-hour[21] = acc-gds-hour[21] + b-gds-h.hour[21]
                    acc-gds-hour[22] = acc-gds-hour[22] + b-gds-h.hour[22]
                    acc-gds-hour[23] = acc-gds-hour[23] + b-gds-h.hour[23]
                    acc-gds-hour[24] = acc-gds-hour[24] + b-gds-h.hour[24]
                    acc-gds-qnty = acc-gds-qnty + b-gds-h.qnty
                    .
                  end.
                  { rep/dincol.i di 1 sym1 sym1}
                  { rep/dincol.i di 2 full-name "string( fill( {&space-char}, 3 ) + string( gds-h.artic, 'x(16)' ) + {&space-char} + gds-h.gds-name )" }
                  { rep/dincol.i di 3 sym2 sym2}
                  { rep/dincol.i di 4 hour1 acc-gds-hour[1]}
                  { rep/dincol.i di 5 hour2 acc-gds-hour[2]}
                  { rep/dincol.i di 6 hour3 acc-gds-hour[3]}
                  { rep/dincol.i di 7 hour4 acc-gds-hour[4]}
                  { rep/dincol.i di 8 hour5 acc-gds-hour[5]}
                  { rep/dincol.i di 9 hour6 acc-gds-hour[6]}
                  { rep/dincol.i di 10 hour7 acc-gds-hour[7]}
                  { rep/dincol.i di 11 hour8 acc-gds-hour[8]}
                  { rep/dincol.i di 12 hour9 acc-gds-hour[9]}
                  { rep/dincol.i di 13 hour10 acc-gds-hour[10]}
                  { rep/dincol.i di 14 hour11 acc-gds-hour[11]}
                  { rep/dincol.i di 15 hour12 acc-gds-hour[12]}
                  { rep/dincol.i di 16 hour13 acc-gds-hour[13]}
                  { rep/dincol.i di 17 hour14 acc-gds-hour[14]}
                  { rep/dincol.i di 18 hour15 acc-gds-hour[15]}
                  { rep/dincol.i di 19 hour16 acc-gds-hour[16]}
                  { rep/dincol.i di 20 hour17 acc-gds-hour[17]}
                  { rep/dincol.i di 21 hour18 acc-gds-hour[18]}
                  { rep/dincol.i di 22 hour19 acc-gds-hour[19]}
                  { rep/dincol.i di 23 hour20 acc-gds-hour[20]}
                  { rep/dincol.i di 24 hour21 acc-gds-hour[21]}
                  { rep/dincol.i di 25 hour22 acc-gds-hour[22]}
                  { rep/dincol.i di 26 hour23 acc-gds-hour[23]}
                  { rep/dincol.i di 27 hour24 acc-gds-hour[24]}
                  { rep/dincol.i di 28 qnty      acc-gds-qnty}
                  { rep/dincol.i di 29 sym3 sym3}
                  {&DISPLAY-FRAME}
                end.
                { rep/dincol.i di 1 sym1 sym1}
                { rep/dincol.i di 2 full-name "string( fill( {&space-char}, 6 ) + string( gds-h.b-code) + {&space-char} + gds-h.f-name )" }
                { rep/dincol.i di 3 sym2 sym2}
                { rep/dincol.i di 4 hour1 gds-h.hour[1]}
                { rep/dincol.i di 5 hour2 gds-h.hour[2]}
                { rep/dincol.i di 6 hour3 gds-h.hour[3]}
                { rep/dincol.i di 7 hour4 gds-h.hour[4]}
                { rep/dincol.i di 8 hour5 gds-h.hour[5]}
                { rep/dincol.i di 9 hour6 gds-h.hour[6]}
                { rep/dincol.i di 10 hour7 gds-h.hour[7]}
                { rep/dincol.i di 11 hour8 gds-h.hour[8]}
                { rep/dincol.i di 12 hour9 gds-h.hour[9]}
                { rep/dincol.i di 13 hour10 gds-h.hour[10]}
                { rep/dincol.i di 14 hour11 gds-h.hour[11]}
                { rep/dincol.i di 15 hour12 gds-h.hour[12]}
                { rep/dincol.i di 16 hour13 gds-h.hour[13]}
                { rep/dincol.i di 17 hour14 gds-h.hour[14]}
                { rep/dincol.i di 18 hour15 gds-h.hour[15]}
                { rep/dincol.i di 19 hour16 gds-h.hour[16]}
                { rep/dincol.i di 20 hour17 gds-h.hour[17]}
                { rep/dincol.i di 21 hour18 gds-h.hour[18]}
                { rep/dincol.i di 22 hour19 gds-h.hour[19]}
                { rep/dincol.i di 23 hour20 gds-h.hour[20]}
                { rep/dincol.i di 24 hour21 gds-h.hour[21]}
                { rep/dincol.i di 25 hour22 gds-h.hour[22]}
                { rep/dincol.i di 26 hour23 gds-h.hour[23]}
                { rep/dincol.i di 27 hour24 gds-h.hour[24]}
                { rep/dincol.i di 28 qnty      gds-h.qnty}
                { rep/dincol.i di 29 sym3 sym3}
                {&DISPLAY-FRAME}
              end.
            END .   /* FOR EACH gds-h ... */
            {&UNDERLINE-FRAME}
          end.    /* if With-Goods then ... `*/
        end. /*if first-of grp-h*/
      end. /*if cycle = 0 or rs-option <> 3*/
      assign
      accum-hour[1] = accum-hour[1] + grp-h.hour[1]
      accum-hour[2] = accum-hour[2] + grp-h.hour[2]
      accum-hour[3] = accum-hour[3] + grp-h.hour[3]
      accum-hour[4] = accum-hour[4] + grp-h.hour[4]
      accum-hour[5] = accum-hour[5] + grp-h.hour[5]
      accum-hour[6] = accum-hour[6] + grp-h.hour[6]
      accum-hour[7] = accum-hour[7] + grp-h.hour[7]
      accum-hour[8] = accum-hour[8] + grp-h.hour[8]
      accum-hour[9] = accum-hour[9] + grp-h.hour[9]
      accum-hour[10] = accum-hour[10] + grp-h.hour[10]
      accum-hour[11] = accum-hour[11] + grp-h.hour[11]
      accum-hour[12] = accum-hour[12] + grp-h.hour[12]
      accum-hour[13] = accum-hour[13] + grp-h.hour[13]
      accum-hour[14] = accum-hour[14] + grp-h.hour[14]
      accum-hour[15] = accum-hour[15] + grp-h.hour[15]
      accum-hour[16] = accum-hour[16] + grp-h.hour[16]
      accum-hour[17] = accum-hour[17] + grp-h.hour[17]
      accum-hour[18] = accum-hour[18] + grp-h.hour[18]
      accum-hour[19] = accum-hour[19] + grp-h.hour[19]
      accum-hour[20] = accum-hour[20] + grp-h.hour[20]
      accum-hour[21] = accum-hour[21] + grp-h.hour[21]
      accum-hour[22] = accum-hour[22] + grp-h.hour[22]
      accum-hour[23] = accum-hour[23] + grp-h.hour[23]
      accum-hour[24] = accum-hour[24] + grp-h.hour[24]
      accum-qnty = accum-qnty + grp-h.qnty
      .
    end. /*for ful-grp-h*/
    if NOT With-Goods then dO:
      if rs-option = 2 and accum-qnty = 0 then.
      else do:
          if rs-option <> 3 then do:
            {&UNDERLINE-FRAME}
          end.
       end.
    END.
    if cycle = 0 and rs-option = 3 then do:
      {&UNDERLINE-FRAME}
    end.
    { rep/dincol.i di 1 sym1 sym1}
    if rs-option = 3 then do:
      v-title = v-obj-name.
    end.
    else do:
      v-title = substitute('ИТОГО &1', v-obj-name).
    end.
    { rep/dincol.i di 2 full-name v-title }
    { rep/dincol.i di 3 sym2 sym2}
    { rep/dincol.i di 4 hour1 "accum-hour[1]"}
    { rep/dincol.i di 5 hour2 "accum-hour[2]"}
    { rep/dincol.i di 6 hour3 "accum-hour[3]"}
    { rep/dincol.i di 7 hour4 "accum-hour[4]"}
    { rep/dincol.i di 8 hour5 "accum-hour[5]"}
    { rep/dincol.i di 9 hour6 "accum-hour[6]"}
    { rep/dincol.i di 10 hour7 "accum-hour[7]"}
    { rep/dincol.i di 11 hour8 "accum-hour[8]"}
    { rep/dincol.i di 12 hour9 "accum-hour[9]"}
    { rep/dincol.i di 13 hour10 "accum-hour[10]"}
    { rep/dincol.i di 14 hour11 "accum-hour[11]"}
    { rep/dincol.i di 15 hour12 "accum-hour[12]"}
    { rep/dincol.i di 16 hour13 "accum-hour[13]"}
    { rep/dincol.i di 17 hour14 "accum-hour[14]"}
    { rep/dincol.i di 18 hour15 "accum-hour[15]"}
    { rep/dincol.i di 19 hour16 "accum-hour[16]"}
    { rep/dincol.i di 20 hour17 "accum-hour[17]"}
    { rep/dincol.i di 21 hour18 "accum-hour[18]"}
    { rep/dincol.i di 22 hour19 "accum-hour[19]"}
    { rep/dincol.i di 23 hour20 "accum-hour[20]"}
    { rep/dincol.i di 24 hour21 "accum-hour[21]"}
    { rep/dincol.i di 25 hour22 "accum-hour[22]"}
    { rep/dincol.i di 26 hour23 "accum-hour[23]"}
    { rep/dincol.i di 27 hour24 "accum-hour[24]"}
    { rep/dincol.i di 28 qnty      "accum-qnty"}
    { rep/dincol.i di 29 sym3 sym3}
    {&DISPLAY-FRAME}
    if rs-option <> 3 then do:
      {&UNDERLINE-FRAME}
    end.
    if cycle = 0 then LEAVE _obj-list.
  END. /*for each obj-list*/
end. /*do cycle*/
HIDE STREAM PrnLibStream FRAME HOUR .
HIDE STREAM PrnLibStream FRAME top-Frame .
HIDE stream PrnLibStream FRAME NBottomFrame .
output stream PrnLibStream CLOSE .
run waitfram-hide in this-procedure .
DELETE WIDGET-POOL "My-pool".