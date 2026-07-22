block-level on error undo, throw.
DEFINE INPUT  PARAMETER pobj-type like ub.clients.obj-type     no-undo.
DEFINE INPUT  PARAMETER pobj-code like ub.clients.obj-code     no-undo.
DEFINE INPUT  PARAMETER ppl-code  like ub.place.pl-code        no-undo.
DEFINE INPUT  PARAMETER pgds-code like ub.goods.gds-code       no-undo.
DEFINE OUTPUT PARAMETER loc#log   as logical                   no-undo.
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Связывание складского места с товаром - не топливо" .
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define buffer bf_goods for ub.goods .
define buffer bf_units for ub.units .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
FIND FIRST ub.pl-gds No-LOCK WHERE
           ub.pl-gds.obj-type = pobj-type AND
           ub.pl-gds.obj-code = pobj-code AND
           ub.pl-gds.pl-code = ppl-code
           No-ERROR.
  IF AVAIL ub.pl-gds then do:
    find first bf_goods no-lock where
                bf_goods.gds-code = ub.pl-gds.gds-code.
    find first bf_units no-lock where
                bf_units.unit-name = bf_goods.unit-base .
    if lookup('топ':U, bf_units.type) > 0 AND
        lookup('дро':U, bf_units.type) > 0 then do:
      assign
      loc#log = no.
      return
      ("объект " + pobj-type + string(pobj-code) + chr(10) +
      "резервуар " + string(ppl-code) + " уже занят - товар " + string(ub.pl-gds.gds-code)) + chr(32) + "(топливо)".
    end.
  END.
  create ub.pl-gds.
  assign
  ub.pl-gds.obj-type = pobj-type
  ub.pl-gds.obj-code = pobj-code
  ub.pl-gds.pl-code = ppl-code
  ub.pl-gds.gds-code = pgds-code
  ub.pl-gds.tolerance = 0
  ub.pl-gds.status_ = 'тек':U
  loc#log = yes
  .
end.
