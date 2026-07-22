/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать списка gds-list или scn-list

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/24/04
Author: Bakhtadze Natalya
Creation date: 06/24/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable  sym1 as char init ":"   no-undo.
define variable  sym2 as char init ":"   no-undo.
define variable  sym3 as char init ":"   no-undo.
define variable  sym4 as char init ":"   no-undo.
define variable  sym5 as char init ":"   no-undo.
define variable  sym6 as char init ":"   no-undo.
define variable  sym7 as char init ":"   no-undo.
define variable  sym8 as char init ":"   no-undo.

define variable  tb-code as char no-undo.
define variable  pbtb-code as character no-undo .
define variable  free-clmn as char no-undo.
define variable  Line         as  char    no-undo.
define variable  v-ind as integer no-undo .
DEFINE VARIABLE varattr-value as character no-undo .
DEFINE VARIABLE varattr-type as character no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_units for ub.units.
define stream PrnLibStream.

&scop  sort-field  (if p-sorttype = "artic":U ~
                    then gds-zap.artic ~
                    else (if p-sorttype = "b-code":U ~
                          then string( gds-zap.b-code, "9999999999" ) ~
                          else string(gds-zap.order-num, "9999999999")) ~
                          )

DEFINE FRAME zapas
sym1 column-label ":!:" format "X(1)"
gds-zap.weight-bc column-label "Вес.!код" format "X(5)"
sym2 column-label ":!:" format "X(1)"
tb-code column-label "Код! " format "x({&BarCode_Length})"
&if "{1}" = "bb-list" or "{1}" = "scnblist" &then
sym8 column-label ":!:" format "X(1)"
pbtb-code column-label "   ДопБк  " format "x(13)"
&endif
sym3 column-label ":!:" format "X(1)"
gds-zap.artic column-label "Артикул! " format "X(16)"
sym4 column-label ":!:" format "X(1)"
gds-zap.gds-name column-label "Название товара! " format "X(50)"
sym5 column-label ":!:" format "X(1)"
&if "{1}" = "scn-list" or "{1}" = "scnblist"
&then
gds-zap.qnty     column-label "Количество! " format "->>>,>>9.999"
sym7 column-label ":!:" format "X(1)"
&endif
free-clmn column-label "Для заметок! " format "X(38)"
sym6 column-label ":!:" format "X(1)"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница" ) AT 110 PAGE-NUMBER(Prnlibstream) AT 120 FORMAT ">>>9" SKIP
Line format "X(135)" AT 1
with width {&A4_CW} down stream-io.


if not can-find(first {1}) then do:
  message
    "Список пустой"
    view-as alert-box information .
  return .
end.

run waitfram-show in this-procedure ( "Обработано записей " ) .
FOR EACH {1} USE-INDEX art NO-LOCK:

  assign
  v-ind = v-ind + 1
  .
  if ( v-ind modulo 25 ) = 0 then do:
    run waitfram-show in this-procedure ( "Обработано записей " + string(v-ind) ) .
  end.

  FIND buf_clients WHERE
     buf_clients.obj-type = {1}.prod-type
 AND buf_clients.obj-code = {1}.prod-code NO-LOCK .
  CREATE gds-zap .
  assign
  gds-zap.unit-base  = {1}.unit-base
  gds-zap.prt-root     = {1}.prt-root
  gds-zap.gds-name = {1}.gds-name
  gds-zap.prod-type  = {1}.prod-type
  gds-zap.prod-code = {1}.prod-code
  gds-zap.artic          = {1}.artic
  gds-zap.prod-name = buf_clients.obj-name
  gds-zap.grp-name = {1}.grp-name
  gds-zap.order-num  = {1}.order-num
&if "{1}" = "scn-list" or "{1}" = "scnblist"  &then
  gds-zap.qnty     = {1}.qnty
&endif

  .
  { gbl/gdsbcode.i
    {1}.gds-code
    ?
    gds-zap.b-code
  }
  assign
    gds-zap.weight-bc = ""
  .
  FIND buf_units WHERE
      buf_units.unit-name = {1}.unit-base NO-LOCK.
  if lookup({&weight}, buf_units.type) > 0 then do:
    varattr-value = "":U.
    run gdsoattr-value in this-procedure(
                                          input {&attr-scales-code-o}
                                          ,input {1}.gds-code
                                          ,input p-obj-type
                                          ,input p-obj-code
                                          ,output varattr-value
                                          ,output varattr-type
                                          ) no-error.
    assign gds-zap.weight-bc = varattr-value.
  end.
&if "{1}" = "bb-list" or "{1}" = "scnblist"  &then
  gds-zap.b-str     = (if gds-zap.weight-bc <> ? and gds-zap.weight-bc <> '':U then '':U else {1}.b-str).
&endif

END.
run waitfram-hide in this-procedure .

&if "{1}" = "gds-list" or "{1}" = "bb-list" &then
  run prn-lib-open-stream  in this-procedure (
                                            input parparentproc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).
&endif
&if "{1}" = "scn-list" or "{1}" = "scnblist" &then
  run prn-lib-open-stream  in this-procedure (
                                            input parparentproc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).
&endif


PUT  stream PrnlibStream
space(30)
&if "{1}" = "gds-list"  or "{1}" = "scn-list" &then
"СПИСОК  ТОВАРОВ" format "X(50)" SKIP(1)
&else
"СПИСОК  КОДОВ" format "X(50)" SKIP(1)
&endif
        /*notes format "X(120)" SKIP(1)
        todo

        */ .

FORM HEADER
Line format "X(135)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX.
VIEW stream Prnlibstream FRAME BottomFrame .
Line = fill("-", 140) .

FORM with frame zapas .
CASE p-Classify :
  when "Classify_1" then do:
    FOR EACH gds-zap BREAK BY  {&sort-field} :
      DISPLAY stream PrnLibStream
      sym1 string( gds-zap.b-code, ">>>>>>>>>9" ) @ tb-code
      sym2 gds-zap.artic sym3 gds-zap.gds-name
      sym4 gds-zap.weight-bc
      sym5 free-clmn sym6
      &if "{1}" = "scn-list" or "{1}" = "scnblist" &then
        sym7
        gds-zap.qnty
      &endif
      &if "{1}" = "bb-list" or "{1}" = "scnblist" &then
        sym8
        gds-zap.b-str @ pbtb-code
      &endif
      with frame zapas .
      DOWN stream PrnLibStream
      1 with frame zapas .
    END. /*for*/
  end.
  when "Classify_2" then do:
    FOR EACH gds-zap
    BREAK
    BY ( gds-zap.prod-type + string( gds-zap.prod-code ) )
    BY {&sort-field} :
      if first-of ( ( gds-zap.prod-type + string( gds-zap.prod-code ) ) ) then  do:
        if NOT first ( ( gds-zap.prod-type + string( gds-zap.prod-code ) ) ) then do:
            UNDERLINE stream PrnLibStream
            tb-code
            gds-zap.artic
            gds-zap.gds-name
            with frame zapas .
        end.
        DISPLAY stream PrnLibStream
        sym1
        "Производитель :" @ gds-zap.artic
        gds-zap.prod-name @ gds-zap.gds-name
        sym5 with frame zapas .
        DOWN stream PrnLibStream
        1 with frame zapas .
        UNDERLINE stream PrnLibStream
        tb-code
        gds-zap.artic
        gds-zap.gds-name
        with frame zapas .
      end.
      DISPLAY stream PrnLibStream
      sym1 string( gds-zap.b-code, ">>>>>>>>>9" ) @ tb-code
      sym2 gds-zap.artic sym3 gds-zap.gds-name
      sym4 gds-zap.weight-bc
      sym5 free-clmn sym6
      &if "{1}" = "scn-list" &then
        sym7
        gds-zap.qnty
      &endif
      with frame zapas .
      DOWN stream PrnLibStream
      1 with frame zapas .
    END. /*for*/
  END.
  when "Classify_3" then do:
    FOR EACH gds-zap
    BREAK
    BY gds-zap.grp-name
    BY {&sort-field}  :
      if first-of ( gds-zap.grp-name ) then do:
        if NOT first ( gds-zap.grp-name ) then do:
          UNDERLINE stream PrnLibStream
          tb-code
          gds-zap.artic
          gds-zap.gds-name
          with frame zapas .
        end.
        DISPLAY stream PrnLibStream
        sym1 "Группа товаров :" @ gds-zap.artic
        gds-zap.grp-name @ gds-zap.gds-name
        sym5
        with frame zapas .
        DOWN stream PrnLibStream
        1 with frame zapas .
        UNDERLINE stream PrnLibStream
        tb-code
        gds-zap.artic
        gds-zap.gds-name
        with frame zapas .
      end.
      DISPLAY stream PrnLibStream
      sym1 string( gds-zap.b-code, ">>>>>>>>>9" ) @ tb-code
      sym2 gds-zap.artic sym3 gds-zap.gds-name
      sym4 gds-zap.weight-bc
      sym5 free-clmn
      sym6
      &if "{1}" = "scn-list" or "{1}" = "scnblist" &then
        sym7
        gds-zap.qnty
      &endif
      &if "{1}" = "bb-list" or "{1}" = "scnblist" &then
        sym8
        gds-zap.b-str @ pbtb-code
      &endif
      with frame zapas .
      DOWN stream PrnLibStream
      1 with frame zapas .
    END. /*for*/
  end.
  when "Classify_4" then do:
    FOR EACH gds-zap
    BREAK
    BY ( gds-zap.prod-type + string( gds-zap.prod-code ) )
    BY gds-zap.grp-name
    BY {&sort-field} :
      if first-of ( ( gds-zap.prod-type + string( gds-zap.prod-code ) ) ) then do:
        if NOT first ( ( gds-zap.prod-type + string( gds-zap.prod-code ) ) ) then do:
          UNDERLINE stream PrnLibStream
          tb-code
          gds-zap.artic
          gds-zap.gds-name
          with frame zapas .
        end.
        DISPLAY stream PrnLibStream
        sym1  "Производитель :" @ gds-zap.artic
        gds-zap.prod-name @ gds-zap.gds-name
        sym5 with frame zapas .
        DOWN stream PrnLibStream
        1 with frame zapas .
        UNDERLINE stream PrnLibStream
        tb-code
        gds-zap.artic
        gds-zap.gds-name
        with frame zapas .
      end.
      if first-of ( gds-zap.grp-name ) then do:
        if NOT first ( gds-zap.grp-name ) then do:
          UNDERLINE stream PrnLibStream
          tb-code
          gds-zap.artic
          gds-zap.gds-name
          with frame zapas .
        end.
        DISPLAY stream PrnLibStream
        sym1 "Группа товаров :" @ gds-zap.artic
        gds-zap.grp-name @ gds-zap.gds-name
        sym5 with frame zapas .
        DOWN stream PrnLibStream
        1 with frame zapas .
        UNDERLINE stream PrnLibStream
        tb-code
        gds-zap.artic
        gds-zap.gds-name
        with frame zapas .
      end.
      DISPLAY stream PrnLibStream
      sym1 string( gds-zap.b-code, ">>>>>>>>>9" ) @ tb-code
      sym2 gds-zap.artic sym3 gds-zap.gds-name
      sym4 gds-zap.weight-bc
      sym5 free-clmn sym6
      &if "{1}" = "scn-list" or "{1}" = "scnblist" &then
        sym7
        gds-zap.qnty
      &endif
      &if "{1}" = "bb-list" or "{1}" = "scnblist" &then
        sym8
        gds-zap.b-str @ pbtb-code
      &endif
      with frame zapas .
      DOWN stream PrnLibStream
      1 with frame zapas .
    END. /*for*/
  end.
  when "Classify_5" then do:
    FOR EACH gds-zap
    BREAK
    BY gds-zap.grp-name
    BY ( gds-zap.prod-type + string( gds-zap.prod-code ) )
    BY {&sort-field} :
      if first-of ( gds-zap.grp-name ) then  do:
        if NOT first ( gds-zap.grp-name ) then do:
          UNDERLINE stream PrnLibStream
          tb-code
          gds-zap.artic
          gds-zap.gds-name
          with frame zapas .
        end.
        DISPLAY stream PrnLibStream
        sym1 "Группа товаров :" @ gds-zap.artic
        gds-zap.grp-name @ gds-zap.gds-name
        sym5 with frame zapas .
        DOWN stream PrnLibStream
        1 with frame zapas .
        UNDERLINE stream PrnLibStream
        tb-code gds-zap.artic gds-zap.gds-name with frame zapas .
      end.
      if first-of ( ( gds-zap.prod-type + string( gds-zap.prod-code ) ) ) then do:
        if NOT first ( ( gds-zap.prod-type + string( gds-zap.prod-code ) ) ) then do:
          UNDERLINE stream PrnLibStream
          tb-code
          gds-zap.artic
          gds-zap.gds-name
          with frame zapas .
        end.
        DISPLAY stream PrnLibStream
        sym1 "Производитель :" @ gds-zap.artic
        gds-zap.prod-name @ gds-zap.gds-name
        sym5
        with frame zapas .
        DOWN stream PrnLibStream
        1 with frame zapas .
        UNDERLINE stream PrnLibStream
        tb-code gds-zap.artic gds-zap.gds-name with frame zapas .
      end.
      DISPLAY stream PrnLibStream
      sym1 string( gds-zap.b-code, ">>>>>>>>>9" ) @ tb-code
      sym2 gds-zap.artic sym3 gds-zap.gds-name
      sym4 gds-zap.weight-bc
      sym5 free-clmn sym6
      &if "{1}" = "scn-list" or "{1}" = "scnblist" &then
        sym7
        gds-zap.qnty
      &endif
      &if "{1}" = "bb-list" or "{1}" = "scnblist" &then
        sym8
        gds-zap.b-str @ pbtb-code
      &endif


      with frame zapas .
      DOWN stream PrnLibStream
      1 with frame zapas .
    END. /*for*/
  END.
END CASE .

HIDE stream PrnlibStream FRAME BottomFrame .
PUT  stream PrnlibStream
Line format "X(135)" SKIP .
output stream PrnlibStream CLOSE .
/*
assign
g#rep-tblname = ""
g#rep-tblrid = -115
g#rep-updflds = "Список товаров/кодов" .*/
run prn-lib-prn-file in this-procedure (
                                          input parparentproc
                                          ,input 0
                                          ).

return "OK" .

  /* $Workfile$ e n d */