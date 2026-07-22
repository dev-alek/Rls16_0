block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сканирование файлов с касс IBM-XML по директории

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/21/05
Author: Bakhtadze Natalya
Creation date: 01/21/05

*/
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
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }

{ str/get-chkf.i }

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

if num-entries(p-spool-or-data, {&delim-par} ) > 1 then do:
  assign
  v-second-mode = entry(2, p-spool-or-data, {&delim-par} )
  p-spool-or-data = entry(1, p-spool-or-data, {&delim-par} )
  .
  /* вызовы из get-chkf.p и из cloc-xml.i;
     значение параметра или "spool", или "spool" + {&delim-par} + command, или "data" */
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
/* 23/XI-2018                    ,input (if v-second-mode <> '':U then {&delim-par} + v-second-mode else '':U) */
                    ,input "readbuffer" + {&delim-par} + v-second-mode
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
     can-do( "f", atr )  /* see "os-dir" help : f - Regular file or FIFO pipe */
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
                    ,input (if v-second-mode <> '':U then {&delim-par} + v-second-mode else '':U)
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
                              , {&new-line}
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
    end. /*нужно скопировать в sav*/
    else do:
      /*просто удалим*/
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

end procedure. /* cb_set-log-file-name */