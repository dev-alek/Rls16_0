block-level on error undo, throw.
define input  parameter p-action    as character no-undo .
define input  parameter p-prog-name as character no-undo .
define input  parameter p-param1    as character no-undo .
define input  parameter p-param2    as character no-undo .
define input  parameter p-param3    as character no-undo .
define output parameter p-ret-value as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: extprog.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/extprog.p $":U .
define variable vss-description as character no-undo init "Процедура запуска внешних программ".
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
define stream slog .
do
on error undo, return error return-value
:
  if p-action = 'exec':U
  then do:
    case p-prog-name :
      when 'rptview':U
      then do:
        run exec-rptview in this-procedure
          (input p-param1
          ) .
      end.
      when 'altprn':U
      then do:
        run exec-altprn in this-procedure
          (input p-param1
          ) .
      end.
      when 'txt2pdf':U
      then do:
        run exec-txt2pdf in this-procedure
          (input p-param1
          ,input p-param2
          ,input p-param3
          ) .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
  else do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      view-as alert-box error .
    undo, return error .
  end.
end.
procedure exec-rptview :
  do
  on error undo, return error
  :
    define input parameter p-file-name as character no-undo .
    define variable v-report-full-path        as character no-undo .
    define variable v-report-path             as character no-undo .
    define variable v-report-file-name        as character no-undo .
    define variable v-report-file-name-no-ext as character no-undo .
    define variable v-report-file-name-ext    as character no-undo .
    run gbl/filename.p
      (input  p-file-name
      ,output v-report-full-path
      ,output v-report-path
      ,output v-report-file-name
      ,output v-report-file-name-no-ext
      ,output v-report-file-name-ext
      ) no-error .
    if error-status :error
    then do:
      message
        "Ошибка задания входных параметров" skip
        "Не найден файл" p-file-name skip
        "Вы можете просмотреть отчет, если сохраните отчет в файл" skip
        "и откроете файл в текстовом редакторе" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error.
      undo, return error .
    end.
    define variable v-rpt-view-full-path        as character no-undo .
    define variable v-rpt-view-path             as character no-undo .
    define variable v-rpt-view-file-name        as character no-undo .
    define variable v-rpt-view-file-name-no-ext as character no-undo .
    define variable v-rpt-view-file-name-ext    as character no-undo .
    run gbl/filename.p
      (input  "exe/rpt-view.bat"
      ,output v-rpt-view-full-path
      ,output v-rpt-view-path
      ,output v-rpt-view-file-name
      ,output v-rpt-view-file-name-no-ext
      ,output v-rpt-view-file-name-ext
      ) no-error .
    if error-status :error
    then do:
      message
        "Невозможен просмотр отчета на экране" skip
        "Не найден файл rpt-view.bat" skip
        "Обратитесь к системному администратору" skip
        "Вы можете просмотреть отчет, если сохраните отчет в файл" skip
        "и откроете файл в текстовом редакторе" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error.
      undo, return error .
    end.
    define variable v-temp-report-name as character no-undo .
    run gbl/_tmpfile.p
      (input  "r":u
      ,input  ".tmp":u
      ,output v-temp-report-name
      ) .
    output stream slog to value(v-temp-report-name) .
    output close .
    define variable v-delete-full-path        as character no-undo .
    define variable v-delete-path             as character no-undo .
    define variable v-delete-file-name        as character no-undo .
    define variable v-delete-file-name-no-ext as character no-undo .
    define variable v-delete-file-name-ext    as character no-undo .
    run gbl/filename.p
      (input  v-temp-report-name
      ,output v-delete-full-path
      ,output v-delete-path
      ,output v-delete-file-name
      ,output v-delete-file-name-no-ext
      ,output v-delete-file-name-ext
      ) no-error .
    if error-status :error
    then do:
      message
        "Невозможен просмотр отчета на экране" skip
        "Не найден файл rpt-view.bat" skip
        "Обратитесь к системному администратору" skip
        "Вы можете просмотреть отчет, если сохраните отчет в файл" skip
        "и откроете файл в текстовом редакторе" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error.
      undo, return error .
    end.
    if index(chr(32), v-rpt-view-full-path) > 0
    or index(chr(32), v-report-full-path) > 0
    or index(chr(32), v-temp-report-name) > 0
    or index(chr(32), v-rpt-view-path) > 0
    or index(chr(32), v-delete-path) > 0
    then do:
      message
        "В имени файлов и директорий не должны содержаться пробелы" skip
        "Необходимо проверить текущие настройки системы" skip
        "Обратитесь к системному администратору" skip
        "Полное имя файла отчета" v-rpt-view-full-path skip
        "Путь к отчету" v-report-full-path skip
        "Временный файл для просмотра на экране" v-temp-report-name skip
        "Путь к программе просмотра на экране" v-rpt-view-path skip
        "Путь к временным файлам" v-delete-path skip
        view-as alert-box error .
      undo, return error .
    end.
    define variable v-command-string as character no-undo .
    assign
      v-command-string = v-rpt-view-full-path
        + chr(32) + v-report-full-path
        + chr(32) + v-temp-report-name
        + chr(32) + v-rpt-view-path
        + chr(32) + v-delete-path
    .
    run gbl/open_url.p
      (input ' /min ':u + v-command-string
      ) .
  end.
end procedure.
procedure exec-altprn :
  do
  on error undo, return error
  :
    define input parameter p-file-name as character no-undo .
    define variable v-temp-report-name as character no-undo .
    define variable v-report-full-path        as character no-undo .
    define variable v-report-path             as character no-undo .
    define variable v-report-file-name        as character no-undo .
    define variable v-report-file-name-no-ext as character no-undo .
    define variable v-report-file-name-ext    as character no-undo .
    run gbl/filename.p
      (input  p-file-name
      ,output v-report-full-path
      ,output v-report-path
      ,output v-report-file-name
      ,output v-report-file-name-no-ext
      ,output v-report-file-name-ext
      ) no-error .
    if error-status :error
    then do:
      message
        "Ошибка задания входных параметров" skip
        "Не найден файл" p-file-name skip
        "Вы можете просмотреть отчет, если сохраните отчет в файл" skip
        "и откроете файл в текстовом редакторе" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error.
      undo, return error .
    end.
    define variable v-alt-prn-full-path        as character no-undo .
    define variable v-alt-prn-path             as character no-undo .
    define variable v-alt-prn-file-name        as character no-undo .
    define variable v-alt-prn-file-name-no-ext as character no-undo .
    define variable v-alt-prn-file-name-ext    as character no-undo .
    run gbl/filename.p
      (input  "exe/alt-prn.bat"
      ,output v-alt-prn-full-path
      ,output v-alt-prn-path
      ,output v-alt-prn-file-name
      ,output v-alt-prn-file-name-no-ext
      ,output v-alt-prn-file-name-ext
      ) no-error .
    if error-status :error
    then do:
      message
        "Невозможен просмотр отчета на экране" skip
        "Не найден файл alt-prn.bat" skip
        "Обратитесь к системному администратору" skip
        "Вы можете просмотреть отчет, если сохраните отчет в файл" skip
        "и откроете файл в текстовом редакторе" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error.
      undo, return error .
    end.
    run gbl/_tmpfile.p
      (input  "r":u
      ,input  ".txt":u
      ,output v-temp-report-name
      ) .
    run gbl/open_url.p
      (input ' /min ':u
        + v-alt-prn-full-path
        + chr(32) + v-report-full-path
        + chr(32) + v-temp-report-name
        + chr(32) + v-alt-prn-path
      ) .
  end.
end procedure.
procedure exec-txt2pdf :
  define input  parameter p-text-file-name as character no-undo .
  define input  parameter p-pdf-file-name  as character no-undo .
  define input  parameter p-landscape      as character no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-convert-pdf as character no-undo .
    define variable v-search-name as character no-undo .
    assign
      v-convert-pdf = "exe/txt2pdf.bat"
    .
    define variable v-report-full-path        as character no-undo .
    define variable v-report-path             as character no-undo .
    define variable v-report-file-name        as character no-undo .
    define variable v-report-file-name-no-ext as character no-undo .
    define variable v-report-file-name-ext    as character no-undo .
    run gbl/filename.p
      (input  v-convert-pdf
      ,output v-report-full-path
      ,output v-report-path
      ,output v-report-file-name
      ,output v-report-file-name-no-ext
      ,output v-report-file-name-ext
      ) no-error .
    if error-status :error
    then do:
      message
        "Ошибка задания входных параметров" skip
        "Не найден файл" v-convert-pdf skip
        "Вы можете просмотреть отчет, если сохраните отчет в файл" skip
        "и откроете файл в текстовом редакторе" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error.
    end.
    else do:
      define variable v-command-line as character no-undo .
      define variable v-to-start as character no-undo .
      assign
        v-command-line = substitute('&1 "&2" "&3" &4 &5'
                                  ,v-report-full-path
                                  ,p-text-file-name
                                  ,p-pdf-file-name
                                  ,v-report-path
                                  ,p-landscape
                                  )
      .
      os-command no-console value(v-command-line).
      run gbl/open_url.p
        (input  quote-spaces(p-pdf-file-name)
        ) .
    end.
  end.
end procedure.
