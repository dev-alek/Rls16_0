block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверки правильности задания loc1 для резервуара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/13/06
Author: Bakhtadze Natalya
Creation date: 04/13/06

*/

define input  parameter pobj-type like ub.clients.obj-type     no-undo.
define input  parameter pobj-code like ub.clients.obj-code     no-undo.
define input  parameter ppl-code  like ub.place.pl-code        no-undo.
define input  parameter ploc1     like ub.place.loc1           no-undo.
define input  parameter pis-meas  like ub.place.is-meas        no-undo.
define input-output  parameter pis-petrol-place as logical     no-undo.
define output parameter loc#log   as logical                   no-undo.

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Проверки правильности задания loc1 для резервуара" .
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
define variable is-petrol-place       as logical no-undo.
define variable is-found-another-loc1 as logical no-undo.
define variable V-DOPI as integer no-undo .

define buffer buf_pl-gds for ub.pl-gds.
define buffer buf_goods for ub.goods.
define buffer buf_units for ub.units.
define buffer buf_place for ub.place.


/*ваызов при привязывании топлива*/
if pis-petrol-place then is-petrol-place = yes.
else do:
  FOR EACH buf_pl-gds No-LOCK WHERE
          buf_pl-gds.pl-code = ppl-code AND
          buf_pl-gds.obj-type = pobj-type AND
          buf_pl-gds.obj-code = pobj-code,
      FIRST buf_goods no-LOCK WHERE
            buf_goods.gds-code = buf_pl-gds.gds-code,
      FIRST buf_units No-LOCK WHERE
            buf_units.unit-name = buf_goods.unit-base AND
            LOOKUP({&petrolium}, buf_units.type) > 0:
    is-petrol-place = yes.
    leave.
  END.
end.

/*если резервуар не связан с топливом то loc1 может быть любой*/
if NOT is-petrol-place then do:
  loc#log = yes.
  return.
END.
assign
v-dopi = integer(ploc1)
no-error .
if error-status:error
or v-dopi <= 0
or v-dopi > 999
or ploc1 <> trim(string(v-dopi, ">>9"))
then do:
  return substitute("объект &1&2&3коорд1 (&4) - ошибочна&3" +
                    "коорд1 для топливного резервуара должна быть ПОЛОЖИТЕЛЬНЫМ ТРЕХЗНАЧНЫМ ЧИСЛОМ БЕЗ ЛИДИРУЮЩИХ НУЛЕЙ"
                  ,pobj-type
                  ,pobj-code
                  ,{&new-line}
                  ,PLOC1
                  ).
end.


_place:
FOR EACH buf_place No-LOCK WHERE
         buf_place.obj-type = pobj-type AND
         buf_place.obj-code = pobj-code:
  if buf_place.loc1 = ploc1 AND
     buf_place.pl-code <> ppl-code AND
     buf_place.is-meas = yes
     then do:
    FOR EACH buf_pl-gds No-LOCK WHERE
            buf_pl-gds.pl-code = buf_place.pl-code AND
            buf_pl-gds.obj-type = pobj-type AND
            buf_pl-gds.obj-code = pobj-code,
        FIRST buf_goods no-LOCK WHERE
              buf_goods.gds-code = buf_pl-gds.gds-code,
        FIRST buf_units No-LOCK WHERE
              buf_units.unit-name = buf_goods.unit-base AND
              LOOKUP({&petrolium}, buf_units.type) > 0:
      is-found-another-loc1 = yes.
      leave _place.
    END.
  END.
END.

if is-petrol-place
AND pis-meas
AND is-found-another-loc1 then do:
  return substitute("объект &1&2&3коорд1, равную &4&3уже имеет резервуар &5"
                  ,pobj-type
                  ,pobj-code
                  ,{&new-line}
                  ,ploc1
                  ,buf_place.pl-code).
END.
else do:
  loc#log = yes.
end.