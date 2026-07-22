/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обшая часть для печати справочников  магазинов и складов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-price-calc as logical no-undo .
define variable v-doc-prt as logical no-undo .

DEFINE FRAME main
    sym1 column-label ":!:" format "x(1)"
ub.clients.obj-code COLUMN-LABEL "Номер! " FORMAT ">>>9"
    sym2 column-label ":!:" format "x(1)"
    ub.clients.obj-name COLUMN-LABEL "Название! "
    sym8 column-label ":!:" format "x(1)"
    ub.clients.host-code COLUMN-LABEL "фирма" FORMAT ">>>>>>>>9"
    sym3 column-label ":!:" format "x(1)"
v-price-calc COLUMN-LABEL "Запр.прих!при нерав.цен" FORMAT "да/нет"
    sym4 column-label ":!:" format "x(1)"
v-doc-prt COLUMN-LABEL "Учет!по шкал" FORMAT "да/нет"
    sym5 column-label ":!:" format "x(1)"
    ub.clients.grp-name COLUMN-LABEL "Название группы! "
    sym6 column-label ":!:" format "x(1)"
    ub.clients.db-num COLUMN-LABEL "БД! "
    sym7 column-label ":!:" format "x(1)"
    HEADER
        cur-time-print() AT 5 format "x(35)"
            string( "Страница " + string (PAGE-NUMBER( PrnLibStream ) , ">>9") )
                    AT 45 format "X(15)" SKIP

Line format "X(137)" AT 1
with width {&A4_CW} down stream-io .

FORM HEADER
Line format "X(137)" SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW stream PrnLibStream FRAME BottomFrame .

if session:set-wait-state("compiler") then.
Line = fill("-", 140).

FORM with FRAME main .

run waitfram-show in this-procedure ( "Минуточку . . ." ).

&if "{1}" = "clients"
&then PUT STREAM PrnLibStream SPACE(4) "С П И С О К    О Б Ъ Е К Т О В" FORMAT "X(122)" SKIP.
&else
&if "{1}" = "shop"
&then PUT STREAM PrnLibStream SPACE(4) "С П И С О К    М А Г А З И Н О В" FORMAT "X(122)" SKIP.
&else PUT STREAM PrnLibStream SPACE(4) "С П И С О К    С К Л А Д О В" FORMAT "X(128)" SKIP.
&endif
&endif

&if "{1}" = "clients" &then
FOR EACH ub.clients NO-LOCK
where ub.clients.obj-type = {&shop}
or ub.clients.obj-type = {&stock}
:
  if ub.clients.obj-type = {&shop} then do:
    find first ub.shop where ub.shop.obj-code = ub.clients.obj-code.
    v-price-calc = ub.shop.price-calc.
    v-doc-prt = ub.shop.doc-prt.
  end.
  else do:
    find first ub.store where ub.store.obj-code = ub.clients.obj-code.
    v-price-calc = ub.store.price-calc.
    v-doc-prt = ub.store.doc-prt.
  end.
&else
FOR EACH {1} NO-LOCK:
        FIND ub.clients WHERE
            ub.clients.obj-code = {1}.obj-code
&if ("{1}" = "shop" OR "{1}" = "ub.shop" ) &then
       AND ub.clients.obj-type = {&shop}.
&else
      AND ub.clients.obj-type = {&stock}.
&endif
   v-doc-prt = {1}.doc-prt.
   v-price-calc = {1}.price-calc.
                                                   &endif
  ACCUMULATE ub.clients.obj-code ( COUNT ).

        DISPLAY stream  PrnLibStream
                sym1
  ub.clients.obj-code
                sym2
                ub.clients.obj-name 
                sym8
                ub.clients.host-code COLUMN-LABEL "Фирма" FORMAT ">>>>>>>>>9"
                sym3
  v-price-calc
                sym4
  v-doc-prt
                sym5
                ub.clients.grp-name
                sym6
                ub.clients.db-num
                sym7
        with FRAME main .
        DOWN stream  PrnLibStream 1 with FRAME main .

  IF ( ( ACCUM COUNT ub.clients.obj-code) modulo 5 = 0 ) AND
          ( ACCUM COUNT ub.clients.obj-code) >= 5 THEN do:
    &if "{1}" = "clients" &then
        run waitfram-show in this-procedure ( "Просмотрено объектов - " + string( ACCUM COUNT ub.clients.obj-code) ).
    &else
        &if ("{1}" = "shop" OR "{1}" = "ub.shop")
        &then
        run waitfram-show in this-procedure ( "Просмотрено магазинов - " + string( ACCUM COUNT ub.clients.obj-code) ).
        &else
        run waitfram-show in this-procedure ( "Просмотрено складов - " + string( ACCUM COUNT ub.clients.obj-code) ).
    &endif
        &endif
END.
end.

IF ( LINE-COUNTER( PrnLibStream ) + 1 ) > PAGE-SIZE( PrnLibStream )
THEN PAGE STREAM PrnLibStream .

PUT STREAM PrnLibStream Line FORMAT "X(137)" SKIP.

HIDE STREAM PrnLibStream FRAME BottomFrame .

run waitfram-hide in this-procedure .

/* $Workfile$ e n d */