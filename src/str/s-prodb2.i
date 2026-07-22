/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка на кассы ДОПБК - специфический код 2

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE term-prt.
/*заполняет таблицу cash-gds сканируя бар-коды и ДОПБК*/
define buffer b-g-p for ub.gds-prt.
DEFINE var incode like ub.bar-code.in-code no-undo.
DEFINE var partcode like ub.bar-code.part-code no-undo.
DEFINE var unitcli like ub.bar-code.unit-cli no-undo.
DEFINE var clibaserate like ub.bar-code.cli-base-rate no-undo.
DEFINE var dpcnt /*like ub.prod-bc.d-pcnt TODO*/ as decimal no-undo.
DEFINE var nodecode like ub.bar-code.node-code no-undo.
def buffer b-units for ub.units.

&if "{&called}" = "s-prodbcn" &then
FIND FIRST ub.bar-code WHERE
           ub.bar-code.b-code = pbc-list.b-code No-LOCK NO-ERROR.
if not avail ub.bar-code then return "NEXT".
if v-is-restaurant then do:
  find first buf_fbr-gds-obj no-lock where
              buf_fbr-gds-obj.obj-type = {&shop}
          AND buf_fbr-gds-obj.obj-code = i-obj-code
          AND buf_fbr-gds-obj.gds-code = ub.bar-code.gds-code no-error .
  if     available buf_fbr-gds-obj
     and not buf_fbr-gds-obj.is-cd 
  then 
     return "NEXT".
end.

FIND FIRST ub.goods WHERE
           ub.goods.gds-code = ub.bar-code.gds-code NO-LOCK  NO-ERROR.
if not avail ub.goods then return "NEXT".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = ub.bar-code.unit-cli NO-ERROR.

assign
incode = ub.bar-code.in-code
partcode = ub.bar-code.part-code
unitcli = ub.bar-code.unit-cli
/*dpcnt = pbc-list.d-pcnt todo*/
clibaserate = ub.bar-code.cli-base-rate
nodecode = ub.bar-code.node-code
.
&else
FIND FIRST ub.bar-code WHERE
           ub.bar-code.b-code = ub.prod-bc.b-code NO-LOCK No-ERROR.
if v-is-restaurant then do:
  find first buf_fbr-gds-obj no-lock where
              buf_fbr-gds-obj.obj-type = {&shop}
          AND buf_fbr-gds-obj.obj-code = i-obj-code
          AND buf_fbr-gds-obj.gds-code = ub.bar-code.gds-code no-error .
  if     available buf_fbr-gds-obj
     and not buf_fbr-gds-obj.is-cd 
  then 
     return.
end.
FIND FIRST ub.goods WHERE
           ub.goods.gds-code = ub.bar-code.gds-code NO-LOCK NO-ERROR.
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = ub.bar-code.unit-cli NO-ERROR.
assign
incode = ub.bar-code.in-code
partcode = ub.bar-code.part-code
unitcli = ub.bar-code.unit-cli
/*
dpcnt = ub.prod-bc.d-pcnt todo*/
clibaserate = ub.bar-code.cli-base-rate
nodecode = ub.bar-code.node-code
.
&endif
{&NEW-GOOD}
run get-prt-and-unit in this-procedure (
                                         input ub.goods.prt-root
                                        ,input ub.goods.unit-base
                                        ,output l-empty-scale
                                        ) .                                            .
&scop buffer-name ub.gds-obj
&scop find-option yes
&scop gds-code-field ub.goods.gds-code
{&get-gds-obj-fields}

if not avail ub.gds-obj then return.
/*найдем код признака*/
FIND FIRST b-g-p where b-g-p.node-code = nodecode NO-LOCK NO-ERROR.

if not avail b-g-p then do:
  if not g#news then do:
    message "Не найден узел шкалы для ДОПБК"

&if  "{&called}" = "s-prodbcn" &then
            pbc-list.b-str
&else
            ub.prod-bc.b-str
&endif
    view-as alert-box ERROR.
    return error.
  end.
  else return error.
end.

{ str/sendgi.i ub.goods ub.gds-prt.node-code}
{ str/sendtree.i ub.goods ub.shop ~{&shop~} ub.shop.obj-code }

/*не на партию*/
if (incode = "" AND LOOKUP({&serial}, units.type) = 0) OR
   (NOT ub.shop.cd-parts-ser and LOOKUP({&serial}, ub.units.type) > 0 ) then do:
        /*нужно ли посылать на кассу ДОПБК с основными единицами измерения*/
        /*нужно ли посылать на кассу ДОПБК с дополн единицами измерения*/
        if (
            (ub.shop.cd-pb-base AND unitcli = ub.goods.unit-base) OR
            (ub.shop.cd-pb-alt AND unitcli <> ub.goods.unit-base) OR
            (ub.shop.cd-sc-base AND unitcli = ub.goods.unit-base)
           )
        then do:
&if "{&called}" = "s-prodbcn" &then
  /*нужно ли посылать на кассу весовые коды*/
  if ub.shop.cd-sc-base AND LOOKUP({&weight}, ub.units.type) > 0 and
  ub.bar-code.unit-cli = ub.goods.unit-base then do:
    /*проверим - это и вправду весовой???*/
    { gbl/prodbctv.i pbc-list.b-str ub.bar-code.unit-cli ub.goods.unit-base 'weight=request':U g#log no-error }
    if error-status:error or not g#log then return "NEXT".
  end.
  run asc-gds(
                 buffer ub.goods,
                 buffer ub.bar-code,
                 buffer ub.gds-prt,
                 buffer ub.gds-obj,
                 buffer ub.price-list,
                 buffer ub.units,
                 buffer b-g-p,
                 input pbc-list.b-str,
                 input pbc-list.bc-on-type,
                 if avail b-units then b-units.type else ub.units.type,
                 if avail b-units then b-units.okei else ub.units.okei,
                 ub.sysconf.host-code,
                 {&shop},
                 i-obj-code
                 ) no-error.
        if return-value = "NEXT" then return "NEXT".
        if error-status:error then return error.

&else
  /*нужно ли посылать на кассу весовые коды*/
  if ub.shop.cd-sc-base AND LOOKUP({&weight}, ub.units.type) > 0 and
  ub.bar-code.unit-cli = ub.goods.unit-base then do:
    /*проверим - это и вправду весовой???*/

    { gbl/prodbcat.i ub.prod-bc  'weight=request':U g#log no-error }
    if error-status:error or not g#log then return "NEXT".
  end.
  run asc-gds(
                 buffer ub.goods,
                 buffer ub.bar-code,
                 buffer ub.gds-prt,
                 buffer ub.gds-obj,
                 buffer ub.price-list,
                 buffer ub.units,
                 buffer b-g-p,
                 input ub.prod-bc.b-str,
                 input ub.prod-bc.bc-on-type,
                 if avail b-units then b-units.type else ub.units.type,
                 if avail b-units then b-units.okei else ub.units.okei,
                 ub.sysconf.host-code,
                 {&shop},
                 i-obj-code
                 ) no-error.
        if return-value = "NEXT" then return "NEXT".
        if error-status:error then return error.

&endif
        end.  /*на основную или доплн единицу измерения*/

end.

/*товар без признаков можно проверить надо ли посылать партии*/
if l-empty-scale
    AND
    incode <> "" then do:
    if (ub.shop.cd-parts-all AND LOOKUP({&serial}, ub.units.type) = 0)
    OR
    (ub.shop.cd-parts-not-blank and partcode <> "" AND LOOKUP({&serial}, ub.units.type) = 0)
    OR
    (ub.shop.cd-parts-ser and LOOKUP({&serial}, ub.units.type) > 0 ) then do:
        /*нужно ли посылать на кассу ДОПБК с основными единицами измерения*/
        /*нужно ли посылать на кассу ДОПБК с дополн единицами измерения*/
        if ((ub.shop.cd-pb-base AND unitcli = ub.goods.unit-base) OR
        (ub.shop.cd-pb-alt AND unitcli <> ub.goods.unit-base)) then do:
&if "{&called}" = "s-prodbcn" &then
                run asc-gds(
                 buffer ub.goods,
                 buffer ub.bar-code,
                 buffer ub.gds-prt,
                 buffer ub.gds-obj,
                 buffer ub.price-list,
                 buffer ub.units,
                 buffer b-g-p,
                 input pbc-list.b-str,
                 input pbc-list.bc-on-type,
                 if avail b-units then b-units.type else  ub.units.type,
                 if avail b-units then b-units.okei else  ub.units.okei,
                 ub.sysconf.host-code,
                 {&shop},
                 i-obj-code
                 ) no-error.
        if return-value = "NEXT" then return "NEXT".
        if error-status:error then return error.

&else
                run asc-gds(
                 buffer ub.goods,
                 buffer ub.bar-code,
                 buffer ub.gds-prt,
                 buffer ub.gds-obj,
                 buffer ub.price-list,
                 buffer ub.units,
                 buffer b-g-p,
                 input ub.prod-bc.b-str,
                 input ub.prod-bc.bc-on-type,
                 if avail b-units then b-units.type else ub.units.type,
                 if avail b-units then b-units.okei else ub.units.okei,
                 ub.sysconf.host-code,
                 {&shop},
                 i-obj-code
                 ) no-error.
        if return-value = "NEXT" then return "NEXT".
        if error-status:error then return error.

&endif
        end.  /*на основную или доплн единицу измерения*/
    end. /*что-то из партий надо посылать*/
end.  /*ub.prod-bc.in-code */
END PROCEDURE.

/* $Workfile$ e n d */