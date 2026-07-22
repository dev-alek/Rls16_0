block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sndfnwr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/sndfnwr.p $":U .
define variable vss-description as character no-undo init "Пересылка масива файлов на массив БД".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function prepare-path returns character ( input p-nonprepared-path as character ):
define variable v-prepared-path as character no-undo .
assign
v-prepared-path = replace(p-nonprepared-path, chr(92), chr(47))
v-prepared-path = right-trim(v-prepared-path, chr(47))
.
return v-prepared-path.
END FUNCTION.
function prepare-path2 returns character ( input p-nonprepared-path as character ):
define variable v-prepared-path as character no-undo .
assign
v-prepared-path = replace(p-nonprepared-path, chr(47), chr(92))
v-prepared-path = right-trim(v-prepared-path, chr(92))
.
return v-prepared-path.
END FUNCTION.
function quote-spaces returns character ( input p-full-path as character):
define variable v-ii as integer no-undo .
define variable v-result as character no-undo .
do v-ii = 1 to num-entries(p-full-path, chr(92)):
  v-result = v-result + (if v-ii = 1 then '' else chr(92)) +
             (if index(entry(v-ii, p-full-path, chr(92)), chr(32)) > 0
             then  substitute("&1&2&1", chr(34), entry(v-ii, p-full-path, chr(92)))
             else entry(v-ii, p-full-path, chr(92))
             )
  .
end.
return v-result.
end function.
define variable v-view-log as logical no-undo .
define variable log-file-name as character no-undo init "sndfrnwr.txt".
define shared temp-table tt-ext-file no-undo like ub.ext-file.
define shared temp-table tt-db       no-undo like ub.db.
define shared temp-table tt-ext-file-par no-undo like ub.ext-file-par.
define buffer buf_tt-db for tt-db.
define buffer buf_tt-ext-file for tt-ext-file.
define buffer locked_ext-file for ub.ext-file.
define buffer buf_ext-file for ub.ext-file.
define buffer last_ext-file for ub.ext-file.
define variable p-mode as character no-undo .
define variable p-path-type as integer no-undo.
define variable p-path as character no-undo .
define variable p-status_  as character no-undo .
define variable v-file-num as integer no-undo .
define variable v-start as logical no-undo .
define variable v-cycled as logical no-undo .
define variable v-start-search as integer no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-file-num-sign as integer no-undo .
FUNCTION get-char-path-type  returns CHARACTER ( input p-path-type as integer, input p-mode as character):
if p-mode = 'save-db':U
or p-mode = 'save-db-and-run':U
or p-mode = 'save-this-db':U
then do:
  return '':U.
end.
CASE p-path-type:
  when 0 then do:
    return "Относительный".
  end.
  when 1 then do:
    return "Абсолютный".
  end.
  when 2 then do:
    return "По настройкам ini-файла IBS TH".
  end.
END CASE.
END FUNCTION.
assign
p-mode          = entry(1, p-parameter, chr(4))
p-path-type     = integer(entry(2, p-parameter, chr(4)))
p-path          = entry(3, p-parameter, chr(4))
p-status_        = entry(4, p-parameter, chr(4))
no-error
.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , chr(10)
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При пересылке/сохранении файлов произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action2   as character no-undo .
  define variable v-printed2       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При пересылке/сохранении файлов произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'sndfrnwr.txt')
    ,input  7
    ,output v-user-action2
    ,output v-printed2
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'sndfrnwr.txt').
end.
                        return.
end.
v-current-db-num = - 1.
if (p-mode = 'save-this-db':U
        or
        (p-mode = 'save-install':U
        and
        p-status_ = 'manual':U)
   ) then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Сохранение файлов&1" +
                          "режим &2&1"
                        , chr(10)
                        , p-mode
                        )).
end.
else do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Пересылка файлов&1" +
                          "режим &2, тип пути к файлу на удаленном компьютере &3,&1" +
                          "Путь &4"
                        , chr(10)
                        , p-mode
                        , get-char-path-type ( input p-path-type, p-mode)
                        , p-path
                        )).
end.
for EACH buf_tt-db NO-LOCK,
    EACH buf_tt-ext-file NO-LOCK:
  if buf_tt-db.db-num <> v-current-db-num then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("------------БД &2&1"
                            , chr(10)
                            , buf_tt-db.db-num
                            )).
   end.
   v-current-db-num = buf_tt-db.db-num.
   main-block:
   do
   on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
   on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
   on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
   :
    v-file-num = next-value(s-sost, ub).
      if p-mode = 'save-this-db':U
      or (p-mode = 'save-install':U
          and
          p-status_ = 'manual':U) then do:
        v-file-num-sign = - 1.
      end.
      else do:
        v-file-num-sign = 1.
    end.
    v-file-num = v-file-num * v-file-num-sign.
    create buf_ext-file.
    buffer-copy buf_tt-ext-file except status_ db-num from-db-num file-num to buf_ext-file
    assign
    buf_Ext-file.status_ = (if p-status_ = '':U then p-mode else p-status_)
    buf_ext-file.db-num = buf_tt-db.db-num
    buf_ext-file.from-db-num = g#db-num
    buf_ext-file.file-num = v-file-num
    buf_Ext-file.update-user-name = g#userid
    .
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Файл &1"
                            , buf_tt-ext-file.file-name
                            )).
    if p-status_ = 'auto':U
    or p-status_ = ""
    then do:
      run nws/bin-e.p (
                     input buf_ext-file.db-num
                    ,input buf_ext-file.from-db-num
                    ,INPUT v-file-num
                    ,input buf_tt-ext-file.file-name
                    ,input p-path-type
                    ,input p-path
                    ,input p-mode
                    ,input buf_tt-ext-file.status_
                    ,buffer buf_ext-file
                    ,input table tt-ext-file-par
                    ) no-error.
      if error-status:error then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("!!!Ошибка при пересылке файла на БД &8&1" +
                                "режим &2, тип пути к файлу на удаленном компьютере &3,&1" +
                                "Путь &4,&1" +
                                "Файл &5,&1&6&1БД &7 (от БД &8)"
                                , chr(10)
                                , p-mode
                                , get-char-path-type ( input p-path-type, p-mode)
                                , p-path
                                , buf_tt-ext-file.file-name
                                , error-status:get-message(1)
                                , return-value
                                , buf_tt-db.db-num
                                , g#db-num
                                )).
          assign
          v-view-log = yes.
      end.
      else do:
        if valid-handle(p-parent-handle)
        and lookup("cb_set-ext-file_file-num", p-parent-handle:internal-entries) > 0 then do:
          run cb_set-ext-file_file-num in p-parent-handle ( input buf_ext-file.db-num
                                                           ,input buf_ext-file.from-db-num
                                                           ,input v-file-num) no-error.
        end.
      end.
      if p-mode <> 'save-db':U
      and p-mode <> 'save-db-and-run':U
      and p-mode <> 'save-this-db':U then do:
      assign
      buf_ext-file.file-name = buf_ext-file.file-name  + '>' + prepare-path(p-path).
    end.
    end.
  end.
END.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При пересылке/сохранении файлов произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action4   as character no-undo .
  define variable v-printed4       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При пересылке/сохранении файлов произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'sndfrnwr.txt')
    ,input  7
    ,output v-user-action4
    ,output v-printed4
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'sndfrnwr.txt').
end.
                        return.
