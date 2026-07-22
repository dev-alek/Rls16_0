block-level on error undo, throw.
define input parameter par-recid as recid no-undo.
define input parameter p-silent as logical no-undo .
define input-output parameter p-stts like ub.tare.stts no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: tare02.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/tare02.p $":U .
define variable vss-description as character no-undo init "Изменение статуса тары".
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
DEFINE VARIABLE loc#log as logical no-undo .
DEFINE BUFFER bf-tare for ub.tare.
DEFINE VARIABLE choice as logical no-undo .
DEFINE VARIABLE varold-stts like ub.tare.stts no-undo .
define variable v-mess as character no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  FIND FIRST bf-tare WHERE
            recid(bf-tare) = par-recid.
  varold-stts = bf-tare.stts.
  if p-stts = ? then do:
    CASE varold-stts:
      when integer('0':U) then do:
        assign
        p-stts = integer('1':U).
      end.
      when integer('1':U) then do:
        assign
        p-stts = integer('0':U).
      end.
    END CASE.
  end.
  CASE p-stts:
    WHEN integer('0':U) then do:
      if integer('0':U) = bf-tare.stts  then do:
          v-mess = substitute("Запись уже имеет статус &1!", entry (lookup (string(p-stts), '0,1,50,99':U), 'тек,удал,блок,удаление':U)).
        run err-mess in this-procedure ( input-output v-mess).
        undo main-block, return error (if p-silent then v-mess else '':U).
      end.
      else do:
        if p-silent = no then do:
          message
          "Запись уже удалена - восстановить?"
          view-as alert-box QUestion buttons YEs-no update choice.
        end.
      end.
    end.
    WHEN integer('1':U) then do:
      if integer('1':U) = bf-tare.stts  then do:
        v-mess = substitute("Запись уже имеет статус &1!", entry (lookup (string(p-stts), '0,1,50,99':U), 'тек,удал,блок,удаление':U)).
        run err-mess in this-procedure ( input-output v-mess).
        undo main-block, return error (if p-silent then v-mess else '':U).
      end.
      else do:
        if p-silent = no then do:
          message
          "Удалить запись?"
          view-as alert-box QUestion buttons yes-no update choice.
        end.
      end.
    end.
  END CASE.
  if choice then
  assign
  bf-tare.stts = p-stts.
  release bf-tare no-error .
  if error-status:error then do:
    v-mess =  substitute("Ошибка при сохранении записи ТАРЫ&1&2&1&3"
                            , chr(10)
                              ,error-status:get-message(1)
                              , return-value).
    run err-mess in this-procedure ( input-output v-mess).
    undo main-block, return error (if p-silent then v-mess else '':U).
  end.
  p-stts = ?.
end.
PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess =  substitute("Правило №&1&2&3"
                           , p-mess).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
