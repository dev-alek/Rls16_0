block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: extprog.p $
$Archive: gbl/extprog.p $

Процедура запуска внешних программ

Автор: Перваков Михаил Сергеевич
Дата создания: 12/18/01
Author: Mikhail Pervakov
Creation date: 12/18/01

*/

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
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/fileslsh.i }

define stream slog .

do
on error undo, return error return-value
:
  if p-action = {&extprog_exec}
  then do:
    case p-prog-name :
      when {&extprog_rptview}
      then do:
        run exec-rptview in this-procedure
          (input p-param1
          ) .
      end.
      when {&extprog_altprn}
      then do:
        run exec-altprn in this-procedure
          (input p-param1
          ) .
      end.
      when {&extprog_txt2pdf}
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
    /* просмотр файла на экране */
    define input parameter p-file-name as character no-undo .

    /* находим файл отчета и определяем его полный путь */
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

    /* находим файл и определяем компоненты имени файла */
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

    /* создаем временный файл */
    define variable v-temp-report-name as character no-undo .
    run gbl/_tmpfile.p
      (input  "r":u
      ,input  ".tmp":u
      ,output v-temp-report-name
      ) .

    /* создаем пустой файл */
    output stream slog to value(v-temp-report-name) .
    output close .

    /* определяем путь временного файла */
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

    if index({&space-char}, v-rpt-view-full-path) > 0
    or index({&space-char}, v-report-full-path) > 0
    or index({&space-char}, v-temp-report-name) > 0
    or index({&space-char}, v-rpt-view-path) > 0
    or index({&space-char}, v-delete-path) > 0
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
        + {&space-char} + v-report-full-path
        + {&space-char} + v-temp-report-name
        + {&space-char} + v-rpt-view-path
        + {&space-char} + v-delete-path
    .
    run gbl/open_url.p
      (input ' /min ':u + v-command-string
      ) .

  end.

end procedure. /* exec-rptview */


procedure exec-altprn :

  do
  on error undo, return error
  :
    define input parameter p-file-name as character no-undo .

    define variable v-temp-report-name as character no-undo .

    /* находим файл отчета и определяем его полный путь */
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


    /* находим файл и определяем компоненты имени файла */
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

    /* создаем временный файл */
    run gbl/_tmpfile.p
      (input  "r":u
      ,input  ".txt":u
      ,output v-temp-report-name
      ) .

    run gbl/open_url.p
      (input ' /min ':u
        + v-alt-prn-full-path
        + {&space-char} + v-report-full-path
        + {&space-char} + v-temp-report-name
        + {&space-char} + v-alt-prn-path
      ) .

  end.

end procedure. /* exec-altprn */


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

end procedure. /* exec-txt2pdf */