/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Почасовая статистика розничных продаж по КОЛИЧЕСТВУ ТОВАРОВ - сбор данных тело цикла

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/05/05
Author: Bakhtadze Natalya
Creation date: 10/05/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

ii-sec = integer( truncate( chk-doc.chk-time / 3600 , 0 ) ) .
FIND FIRST grp-h WHERE
                    (IF RS-OPTION = 3
                    then YES else
                    grp-h.grp-code = goods.grp-code)
              AND  grp-h.obj-code = v-obj-code NO-ERROR .
if byobject then do:
  FIND FIRST tot_grp-h WHERE
                      (IF RS-OPTION = 3
                      then YES else
                     tot_grp-h.grp-code = goods.grp-code)
                AND  tot_grp-h.obj-code = 0 NO-ERROR .
end.
if NOT available grp-h then do:
  CREATE grp-h .
  assign
  grp-h.grp-code = (IF RS-OPTION = 3 then 0 else goods.grp-code)
  grp-h.obj-code =  v-obj-code
  .
end.
if byobject and not available tot_grp-h then do:
  CREATE tot_grp-h .
  assign
  tot_grp-h.grp-code = (IF RS-OPTION = 3 then 0 else goods.grp-code)
  tot_grp-h.obj-code =  0
  .
end.
assign
grp-h.qnty = grp-h.qnty + (IF for-h[ii-sec + 1] then chk-gds.doc-qnty else 0)
grp-h.hour[ii-sec + 1] = grp-h.hour[ii-sec + 1] + chk-gds.doc-qnty
.
if byobject then do:
  assign
  tot_grp-h.qnty = tot_grp-h.qnty + (IF for-h[ii-sec + 1] then chk-gds.doc-qnty else 0)
  tot_grp-h.hour[ii-sec + 1] = tot_grp-h.hour[ii-sec + 1] + chk-gds.doc-qnty
  .
end.
if WithGoods then do:
  case T-SCALE:
    WHEN NO THEN DO:
      ASSIGN
      VAR-UNIQ = goods.artic + goods.prod-type + string( goods.prod-code )
      .
      FIND FIRST gds-h WHERE
              gds-h.grp-code = goods.grp-code
         AND  gds-h.obj-code = v-obj-code
         AND  gds-h.UNIQ = VAR-UNIQ NO-ERROR .
     if byobject then do:
      FIND FIRST tot_gds-h WHERE
              tot_gds-h.grp-code = goods.grp-code
         AND  tot_gds-h.obj-code = 0
         AND  tot_gds-h.UNIQ = VAR-UNIQ NO-ERROR .
     end.
    END.
    WHEn YES THEN DO:
      FIND FIRST gds-h WHERE
               gds-h.grp-code = goods.grp-code
           AND gds-h.obj-code = v-obj-code
           AND gds-h.b-code = bar-code.b-code NO-ERROR .
     if byobject then do:
      FIND FIRST tot_gds-h WHERE
               tot_gds-h.grp-code = goods.grp-code
           AND tot_gds-h.obj-code = 0
           AND tot_gds-h.b-code = bar-code.b-code NO-ERROR .
     end.
    END.
  end case.
  if NOT available gds-h then do:
    if goods.prt-root <> var-empty-scale then  do:
      find first loc-gds-prt No-LOCK WHERE
                  loc-gds-prt.node-code = bar-code.node-code no-error .
      if avail loc-gds-prt then do:
        var-prt-name = loc-gds-prt.f-name.
      end.
    end.
    else do:
      var-prt-name = "":U.
    end.
    CREATE gds-h .
    assign
    gds-h.grp-code = goods.grp-code
    gds-h.gds-name = goods.gds-name
    gds-h.f-name = var-prt-name
    gds-h.is-empty = (goods.prt-root = var-empty-scale)
    gds-h.b-code = bar-code.b-code
    gds-h.uniq = goods.artic + goods.prod-type + string( goods.prod-code )
    gds-h.artic = goods.artic
    gds-h.obj-code =  v-obj-code.
  end.
  if byobject and not available tot_gds-h then do:
    CREATE tot_gds-h .
    assign
    tot_gds-h.grp-code = goods.grp-code
    tot_gds-h.gds-name = goods.gds-name
    tot_gds-h.f-name = var-prt-name
    tot_gds-h.is-empty = (goods.prt-root = var-empty-scale)
    tot_gds-h.b-code = bar-code.b-code
    tot_gds-h.uniq = goods.artic + goods.prod-type + string( goods.prod-code )
    tot_gds-h.artic = goods.artic
    tot_gds-h.obj-code =  0
    .
  end.
  assign
  gds-h.qnty = (if for-h[ii-sec + 1] then (gds-h.qnty + chk-gds.doc-qnty)  else gds-h.qnty)
  gds-h.hour[ii-sec + 1]  = gds-h.hour[ii-sec + 1] + chk-gds.doc-qnty
  .
  if byobject then do:
    assign
    tot_gds-h.qnty = (if for-h[ii-sec + 1] then (tot_gds-h.qnty + chk-gds.doc-qnty)  else tot_gds-h.qnty)
    tot_gds-h.hour[ii-sec + 1]  = tot_gds-h.hour[ii-sec + 1] + chk-gds.doc-qnty
    .
  end.
end.
PROCESS EVENTS .
accum-chk-gds = accum-chk-gds + 1 .
if  (accum-chk-gds < 100)
or
( ( ACCUM-chk-gds ) modulo 50 ) = 0


then
run waitfram-show in this-procedure ( "Обработано строк чеков : " +
                                string( ACCUM-chk-gds ) ) .


/* $Workfile$ e n d */