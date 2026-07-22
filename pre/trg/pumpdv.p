block-level on error undo, throw.
DEFINE INPUT  PARAMETER pobj-type like ub.clients.obj-type     no-undo.
DEFINE INPUT  PARAMETER pobj-code like ub.clients.obj-code     no-undo.
DEFINE INPUT  PARAMETER ppump-code like ub.pump.pump-code        no-undo.
DEFINE OUTPUT PARAMETER loc#log   as logical                   no-undo.
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Проверки возможности удаления ТРК" .
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
if not error-status:error and v-shift-num > 0 then  do:
  find first ub.rvs-doc no-lock where
             ub.rvs-doc.obj-type = pobj-type and
             ub.rvs-doc.obj-code = pobj-code and
             ub.rvs-doc.shift-date = v-shift-date and
             ub.rvs-doc.shift-num = v-shift-num and
             ub.rvs-doc.status_ = 'факт':U and
             ub.rvs-doc.rvs-type = 'смена':U no-error.
  if not avail ub.rvs-doc then do:
    return error
    ("объект " + pobj-type + string(pobj-code) + chr(10) +
     "не было сверки по текущей смене типа " + 'смена':U)
     .
  end.
end.
_deletion:
do on error undo _deletion, return error return-value :
  for each ub.pl-pump-nozzle where
          ub.pl-pump-nozzle.obj-type = pobj-type and
          ub.pl-pump-nozzle.obj-code = pobj-code and
          ub.pl-pump-nozzle.pump-code = ppump-code:
    delete ub.pl-pump-nozzle no-error.
      if error-status:error then do:
        undo _deletion, return error ("Не удалось удалить запись pl-pump-nozzle " + chr(10) +
                                      "объект " + pobj-type + string(pobj-code) + chr(10) +
                                      "резервуар " + string(ub.pl-pump-nozzle.pl-code) + chr(10) +
                                      "ТРК " + string(ppump-code) +
                                      "пистолет " + string(ub.pl-pump-nozzle.nozzle-code)).
      end.
  end.
  for each ub.pl-gds-pump where
          ub.pl-gds-pump.obj-type  = pobj-type  and
          ub.pl-gds-pump.obj-code  = pobj-code  and
          ub.pl-gds-pump.pump-code = ppump-code on error undo, return error return-value :
    delete ub.pl-gds-pump no-error.
      if error-status:error then do:
        undo _deletion, return error ("Не удалось удалить запись pl-gds-pump " + chr(10) +
                                      "объект " + pobj-type + string(pobj-code) + chr(10) +
                                      "резервуар " + string(ub.pl-gds-pump.pl-code) + chr(10) +
                                      "топливо " + string(ub.pl-gds-pump.gds-code) + chr(10) +
                                      "ТРК " + string(ppump-code)).
      end.
  end.
  for each ub.pl-pump where
          ub.pl-pump.obj-type  = pobj-type  and
          ub.pl-pump.obj-code  = pobj-code  and
          ub.pl-pump.pump-code = ppump-code on error undo, return error return-value :
    delete ub.pl-pump no-error.
      if error-status:error then do:
        undo _deletion, return error ("Не удалось удалить запись pl-pump " + chr(10) +
                                      "объект " + pobj-type + string(pobj-code) + chr(10) +
                                      "резервуар " + string(ub.pl-pump.pl-code) + chr(10) +
                                      "ТРК " + string(ppump-code)).
      end.
  end.
  for each ub.pump-nozzle where
           ub.pump-nozzle.obj-type  = pobj-type and
           ub.pump-nozzle.obj-code  = pobj-code and
           ub.pump-nozzle.pump-code = ppump-code on error undo, return error return-value :
    delete ub.pump-nozzle no-error.
      if error-status:error then do:
        undo _deletion, return error ("Не удалось удалить запись pump-nozzle " + chr(10) +
                                      "объект " + pobj-type + string(pobj-code) + chr(10) +
                                      "ТРК " + string(ub.pump-nozzle.pump-code) + chr(10) +
                                      "пистолет " + string(ub.pump-nozzle.nozzle-code)).
      end.
  end.
end.
assign
loc#log = yes.
