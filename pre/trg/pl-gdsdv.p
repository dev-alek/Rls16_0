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
define variable vss-description as character no-undo init "Проверки возможности удаления связи топливо-резервуар" .
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
define variable v-shift-date as date      no-undo.
define variable v-shift-num  as integer   no-undo.
define variable v-shift-name as character no-undo.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  pobj-type
  ,input  pobj-code
  ,output v-shift-date
  ,output v-shift-num
  ,output v-shift-name
  ) no-error .
if NOT error-status:error and v-shift-num > 0 then do:
  FIND FIRST ub.rvs-doc NO-LOCK WHERE
             ub.rvs-doc.obj-type = pobj-type AND
             ub.rvs-doc.obj-code = pobj-code AND
             ub.rvs-doc.shift-date = v-shift-date AND
             ub.rvs-doc.shift-num = v-shift-num AND
             ub.rvs-doc.status_ = 'факт':U AND
             ub.rvs-doc.rvs-type = 'смена':U NO-ERROR.
  IF AVAIL ub.rvs-doc then do:
    FOR EACH ub.rvs-line NO-LOCK WHERE
             ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code AND
             ub.rvs-line.gds-code = pgds-code AND
             ub.rvs-line.pl-code  = ppl-code:
      IF ub.rvs-line.system-qnty <> 0 then do:
        return
       ("объект " + pobj-type + string(pobj-code) + chr(10) +
       "резервуар " + string(ppl-code) + chr(10) +
       "топливо " + string(pgds-code) + chr(10) +
       "имеются ненулевые книжные остатки по сверке текущей смены")
       .
      END.
      IF ub.rvs-line.state-measure-qnty <> 0 then do:
        return
       ("объект " + pobj-type + string(pobj-code) + chr(10) +
       "резервуар " + string(ppl-code) + chr(10) +
       "топливо " + string(pgds-code) + chr(10) +
       "имеются ненулевые подтвержденные фактические остатки по сверке текущей смены")
       .
      END.
    END.
  END.
  else do:
    return
    ("объект " + pobj-type + string(pobj-code) + chr(10) +
     "не было сверки по текущей смене типа " + 'смена':U)
     .
  end.
end.
else do:
  FIND last ub.shift-obj No-LOCK WHERE
            ub.shift-obj.obj-type = pobj-type AND
            ub.shift-obj.obj-code = pobj-code AND
            ub.shift-obj.status_ = 'факт':U use-index stts No-ERROR.
  IF AVAIL ub.shift-obj then do:
    FIND FIRST ub.rvs-doc NO-LOCK WHERE
              ub.rvs-doc.obj-type = ub.shift-obj.obj-type AND
              ub.rvs-doc.obj-code = ub.shift-obj.obj-code AND
              ub.rvs-doc.shift-date = ub.shift-obj.shift-date AND
              ub.rvs-doc.shift-num = ub.shift-obj.shift-num AND
              ub.rvs-doc.status_ = 'факт':U AND
              ub.rvs-doc.rvs-type = 'смена':U NO-ERROR.
    IF AVAIL ub.rvs-doc then do:
      FOR EACH ub.rvs-line NO-LOCK WHERE
              ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code AND
              ub.rvs-line.gds-code = pgds-code AND
              ub.rvs-line.pl-code  = ppl-code:
        IF ub.rvs-line.system-qnty <> 0 then do:
          return
        ("объект " + pobj-type + string(pobj-code) + chr(10) +
        "резервуар " + string(ppl-code) + chr(10) +
        "топливо " + string(pgds-code) + chr(10) +
        "имеются ненулевые книжные остатки по сверке последней закрытой смены")
        .
        END.
        IF ub.rvs-line.state-measure-qnty <> 0 then do:
          return
        ("объект " + pobj-type + string(pobj-code) + chr(10) +
        "резервуар " + string(ppl-code) + chr(10) +
        "топливо " + string(pgds-code) + chr(10) +
        "имеются ненулевые подтвержденные фактические остатки по сверке последней закрытой смены")
        .
        END.
      END.
    END.
    else return error.
  END.
END.
_deletion:
DO
ON ERROR undo _deletion, return error
:
FOR EACH ub.pl-gds-pump where
        ub.pl-gds-pump.obj-type = pobj-type AND
        ub.pl-gds-pump.obj-code = pobj-code AND
        ub.pl-gds-pump.pl-code = ppl-code AND
        ub.pl-gds-pump.gds-code = pgds-code:
  DELETE UB.PL-GDS-PUMP NO-ERROR.
  if error-status:error then do:
    undo _deletion, return  ("Не удалось удалить запись pl-gds-pump " + chr(10) +
                            "объект " + pobj-type + string(pobj-code) + chr(10) +
                            "резервуар " + string(ppl-code) + chr(10) +
                            "топливо " + string(pgds-code) + chr(10) +
                            "ТРК " + string(ub.pl-gds-pump.pump-code)).
  end.
END.
END.
loc#log = yes.
