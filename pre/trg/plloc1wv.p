block-level on error undo, throw.
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
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable is-petrol-place       as logical no-undo.
define variable is-found-another-loc1 as logical no-undo.
define variable V-DOPI as integer no-undo .
define buffer buf_pl-gds for ub.pl-gds.
define buffer buf_goods for ub.goods.
define buffer buf_units for ub.units.
define buffer buf_place for ub.place.
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
            LOOKUP('топ':U, buf_units.type) > 0:
    is-petrol-place = yes.
    leave.
  END.
end.
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
                  ,chr(10)
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
              LOOKUP('топ':U, buf_units.type) > 0:
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
                  ,chr(10)
                  ,ploc1
                  ,buf_place.pl-code).
END.
else do:
  loc#log = yes.
end.
