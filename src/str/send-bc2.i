/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка на кассы БК - специфический код-2

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE term-prt.
DEFINE var incode like ub.bar-code.in-code no-undo.
DEFINE var partcode like ub.bar-code.part-code no-undo.
DEFINE var unitcli like ub.bar-code.unit-cli no-undo.
DEFINE var clibaserate like ub.bar-code.cli-base-rate no-undo.
DEFINE var dpcnt /*like ub.bar-code.d-pcnt todo*/ as decimal no-undo.
DEFINE var nodecode like ub.bar-code.node-code no-undo.

/*заполняет таблицу cash-gds сканируя бар-коды и ДОПБК*/
def buffer b-g-p for ub.gds-prt.
def buffer b-units for ub.units.

&if "{&called}" = "send-bcn" &then
FIND FIRST ub.goods WHERE
           ub.goods.gds-code = bc-list.gds-code NO-LOCK  NO-ERROR.
if not avail ub.goods then return "NEXT".
if v-is-restaurant then do:
  find first buf_fbr-gds-obj no-lock where
              buf_fbr-gds-obj.obj-type = {&shop}
          AND buf_fbr-gds-obj.obj-code = i-obj-code
          AND buf_fbr-gds-obj.gds-code = ub.goods.gds-code no-error .
  if     available buf_fbr-gds-obj
     and not buf_fbr-gds-obj.is-cd 
  then 
     return "NEXT".
end.
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = bc-list.unit-cli NO-ERROR.
assign
incode = bc-list.in-code
partcode = bc-list.part-code
unitcli = bc-list.unit-cli
/*dpcnt = bc-list.d-pcnt*/
clibaserate = bc-list.cli-base-rate
nodecode = bc-list.node-code
.
&else
FIND FIRST ub.goods WHERE
           ub.goods.gds-code = b-bc.gds-code NO-LOCK .
if v-is-restaurant then do:
  find first buf_fbr-gds-obj no-lock where
              buf_fbr-gds-obj.obj-type = {&shop}
          AND buf_fbr-gds-obj.obj-code = i-obj-code
          AND buf_fbr-gds-obj.gds-code = ub.goods.gds-code no-error .
  if     available buf_fbr-gds-obj
     and not buf_fbr-gds-obj.is-cd 
  then 
     return .
end.

FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = b-bc.unit-cli NO-ERROR.

assign
incode = b-bc.in-code
partcode = b-bc.part-code
unitcli = b-bc.unit-cli
/*dpcnt = b-bc.d-pcnt*/
clibaserate = b-bc.cli-base-rate
nodecode = b-bc.node-code
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

if not avail ub.gds-obj then NEXT.
/*найдем код признака*/
FIND FIRST b-g-p where b-g-p.node-code = nodecode NO-LOCK No-ERROR.
if not avail b-g-p then do:
  if not g#news then do:
    message "Не найден узел шкалы для бар-кода"

&if  "{&called}" = "send-bcn" &then
            bc-list.b-code
&else
            b-bc.b-code
&endif
    view-as alert-box ERROR.
    return error.
  end.
  else return error.
end.


{ str/sendgi.i ub.goods ub.gds-prt.node-code}

{ str/sendtree.i ub.goods ub.shop ~{&shop~} ub.shop.obj-code }

FIND FIRST ub.bar-code WHERE
            ub.bar-code.node-code = b-g-p.node-code AND
            ub.bar-code.gds-code = ub.goods.gds-code AND
            ub.bar-code.in-code = "" AND
            ub.bar-code.part-code = "" AND
            ub.bar-code.unit-cli = ub.goods.unit-base NO-LOCK .



/*не на партию*/
if (incode = "" and LOOKUP({&serial}, ub.units.type) = 0) OR
   (NOT ub.shop.cd-parts-ser and LOOKUP({&serial}, ub.units.type) > 0 ) then do:

        /*нужно ли посылать на кассу ДОПБК с основными единицами измерения*/
        /*нужно ли посылать на кассу ДОПБК с дополн единицами измерения*/
        if (ub.shop.cd-pb-base AND unitcli = ub.goods.unit-base ) OR
           (ub.shop.cd-pb-alt AND unitcli <> ub.goods.unit-base )
           then do:
          run asc-gds(
                  buffer ub.goods,
&if "{&called}" = "send-bcn" &then
                  buffer bc-list,
&else
                  buffer b-bc,
&endif
                  buffer ub.gds-prt,
                  buffer ub.gds-obj,
                  buffer ub.price-list,
                  buffer ub.units,
                  buffer b-g-p,
                  input ?,
                  input '',
                  if avail b-units then b-units.type else ub.units.type,
                  if avail b-units then b-units.okei else ub.units.okei,
                  ub.sysconf.host-code,
                  {&shop},
                  i-obj-code
                  ) no-error.
          if return-value = "NEXT" then return "NEXT".
          if error-status:error then return error.
        end.  /*на основную или доплн единицу измерения*/

end.

/*товар без признаков можно проверить надо ли посылать партии*/
if  l-empty-scale
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
                run asc-gds(
                 buffer ub.goods,
&if "{&called}" = "send-bcn" &then
                  buffer bc-list,
&else
                  buffer b-bc,
&endif
                 buffer ub.gds-prt,
                 buffer ub.gds-obj,
                 buffer ub.price-list,
                 buffer ub.units,
                 buffer b-g-p,
                 input ?,
                 input '',
                 if avail b-units then b-units.type else ub.units.type,
                 if avail b-units then b-units.okei else ub.units.okei,
                 ub.sysconf.host-code,
                 {&shop},
                 i-obj-code
                 ) no-error.
        if return-value = "NEXT" then return "NEXT".
        if error-status:error then return error.
      end.  /*на основную или доплн единицу измерения*/
    end. /*что-то из партий надо посылать*/
end.  /*b-bc.in-code */
END PROCEDURE.

/* $Workfile$ e n d */