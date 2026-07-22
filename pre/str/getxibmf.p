block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-in_ as character no-undo .
define input parameter p-spl as character no-undo .
define input parameter p-sav   as character no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-encoding as character no-undo .
define input parameter log-file-name as character no-undo .
define input parameter p-spool-or-data as character no-undo .
define input parameter p-waiting-name as LONGCHAR no-undo .
define input-output parameter p-view-log as logical no-undo init yes.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сканирование файлов с касс IBM-XML по директории".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable path as char no-undo.
define variable atr as char no-undo.
define variable file as char no-undo.
define variable adr as char no-undo.
def stream DirStream .
define variable in_ as char no-undo.
define variable spl as char no-undo.
define variable sav as char no-undo.
define variable out as char no-undo.
define variable out2 as character no-undo .
define variable v-remote as char no-undo.
define variable v-dir-remote as character no-undo .
define variable v-dir-remote-tmp as character no-undo .
define variable yestr as character no-undo .
define variable kass-list as char no-undo.
define variable cycle as logical no-undo.
def buffer for-cash-desk for ub.cash-desk.
define variable jj as int no-undo.
define variable v-lock-global as logical no-undo.
def frame a
path format "x(30)"
with view-as dialog-box side-labels
size 50 by 4.17 three-d title "Обработка файла ...".
DEFINE VARIABLE v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define variable v-need-save               as logical                  no-undo .
define variable v-need-save-2             as logical                  no-undo .
define variable v-view-log                as logical                  no-undo .
define variable v-md5-signature           as character                no-undo .
define variable v-md5-signature-check     as character                no-undo .
define variable path-sig                  as character                no-undo .
define variable v-second-mode             as character                no-undo .
define variable v-rv                      as character                no-undo .
define variable v-lengthfname             as integer                  no-undo .
define stream SigStream.
if num-entries(p-spool-or-data, chr(4) ) > 1 then do:
  assign
  v-second-mode = entry(2, p-spool-or-data, chr(4) )
  p-spool-or-data = entry(1, p-spool-or-data, chr(4) )
  .
end.
if p-spool-or-data begins "readbuffer_"
then do:
   if  p-spool-or-data = "readbuffer_spool"
    or p-spool-or-data = "readbuffer_config"
   then do:
      run str/get-xibm.p (
                    input parparentproc
                    ,input p-log-handle
                    ,input p-obj-type
                    ,input p-obj-code
                    ,input p-host-code
                    ,input p-pos-type
                    ,input p-encoding
                    ,input p-waiting-name
                    ,input "readbuffer" + chr(4) + v-second-mode
                    ,input-output v-view-log
                    )  no-error.
      if error-status:error
      then
         run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "&1 Ошибка: &2 &3"
                              , vss-description
                              , return-value
                              , error-status:get-message(1)
                            )
            ).
      assign
      p-view-log = v-view-log or p-view-log
      v-need-save-2 = p-view-log
      .
   end.
   else
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "Чтение данных на прямую не предусмотрено &1"
                              , path
                            )
                                        ).
end.
else do:
input stream DirStream from os-dir ( p-in_ + p-spl ) .
REPEAT :
  import stream DirStream file path atr.
  v-lengthfname = length(file) .
  if (v-lengthfname > 3) AND
     ( substring( file, v-lengthfname - 2, 3 ) = "xml":u ) AND
     can-do( "f", atr )
     and (p-spool-or-data = "spool"
       or p-spool-or-data = "config"
       or entry(1,  file, ".":U) = p-waiting-name)
  then do:
    assign
    v-view-log = no
    .
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute(
            (if p-spool-or-data = "spool" then "Обработка файла &1" else "Обработка файла-ответа &1")
                           , path
                           )
                                        ).
    if p-spool-or-data = "spool"
    or p-spool-or-data = "config"
    then do:
      run str/get-xibm.p (
                    input parparentproc
                    ,input p-log-handle
                    ,input p-obj-type
                    ,input p-obj-code
                    ,input p-host-code
                    ,input p-pos-type
                    ,input p-encoding
                    ,input path
                    ,input (if v-second-mode <> '':U then chr(4) + v-second-mode else '':U)
                    ,input-output v-view-log
                    ) no-error .
      assign
      p-view-log = v-view-log or p-view-log
      v-need-save-2 = p-view-log
      .
    end.
    else do:
      run str/get-xrpl.p (
                    input parparentproc
                    ,input p-log-handle
                    ,input p-obj-type
                    ,input p-obj-code
                    ,input p-host-code
                    ,input p-pos-type
                    ,input p-encoding
                    ,input path
                    ,input p-spool-or-data
                    ,input-output v-view-log
                    ,output v-need-save
                    ) no-error .
      assign
      p-view-log = v-view-log or p-view-log
      .
    end.
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!При обработке файла &1 произошла ошибка:&2&3 &4"
                              , path
                              , chr(10)
                              , error-status:get-message(1)
                              , return-value
                            )
                                        ).
      assign
      p-view-log = yes
      .
    end.
    if v-need-save
    or v-need-save-2
    or p-view-log
    or p-spool-or-data = "spool"
    or p-spool-or-data = "config" then do:
      run gbl/filename.p (
                    input path
                    ,output v-full-path
                    ,output v-path
                    ,output v-file-name
                    ,output v-file-name-no-ext
                    ,output v-file-name-ext
                    ) no-error .
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!При обработке файла &1 произошла ошибка при получении полного пути файлу: &2"
                                , path
                                , return-value
                              )
                                          ).
        assign
        p-view-log = yes
        .
        input stream DirStream close.
        return.
      end.
      v-rv
      = ( if (path = p-sav + "\" + v-file-name)
              then replace((p-sav + "\" + v-file-name), '.xml':U, '.xml-sav')
              else (p-sav + "\" + v-file-name)).
      os-copy value( path )
      value(v-rv).
      if os-error > 0 then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "Ошибка при копировании файла &1 в директорию архива &2"
                                , path, p-sav
                              )
                                          ).
        assign
        p-view-log = yes
        .
      end.
      else do:
        os-delete value( path ) .
      end.
    end.
    else do:
      os-delete value( path ) .
    end.
  end.
END .
input stream DirStream close.
end.
return v-rv.
procedure cb_set-log-file-name :
define output parameter p-log-file-name as character no-undo .
do
on error undo, return error
:
  p-log-file-name = log-file-name.
end.
end procedure.
