block-level on error undo, throw.
define input parameter parparentproc    as widget-handle no-undo.
define input parameter p-cli-type       like ub.alc-supp-lic.cli-type no-undo.
define input parameter p-cli-code       like ub.alc-supp-lic.cli-code no-undo.
define variable vss-revision    as character no-undo init "$Revision: a8e2cf75ddf6, 2506, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июл 08 17:09:06 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: p-licsa.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/p-licsa.p $":U .
define variable vss-description as character no-undo init "Печать Лицензии на продажу алкогольной продукции".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable v-full-path-RepView as character no-undo.
define variable v-file-name-rep-htm as character no-undo.
define variable g#report-num as integer no-undo.
define buffer buf_alc-sale-lic for alc-sale-lic.
define buffer host_clients for clients.
define stream OutStr-html.
function fnc-DD-MM-YYYY returns character
(input p-dat-date as date) forward.
function fnc-convert-dot-to-colon returns character
(input p-data as decimal, p-accur as character) forward.
    run get-full-path-RepViewer(output v-full-path-RepView).
    run get-report-num in parParentProc(output g#report-num).
    run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).
    run create-file(v-file-name-rep-htm).
    run proc-create-HTML(input v-file-name-rep-htm, input p-cli-type, input p-cli-code).
    run Report-Viewer(input v-full-path-RepView, input v-file-name-rep-htm).
procedure get-full-path-RepViewer:
    define output parameter p-fill-path-RepView as character no-undo.
    if search("exe\ReportViewer\reportviewer.exe") <> ? then
    do:
        p-fill-path-RepView = search("exe\ReportViewer\reportviewer.exe").
    end.
    else
    do:
        message "Не найдена программа просмотра отчёта!" view-as alert-box error.
    end.
end procedure.
procedure define-full-path-Report:
    define input parameter p-rep-num as integer no-undo.
    define output parameter p-file-name-rep-htm as character no-undo.
    p-file-name-rep-htm = session:temp-directory + "rpt" + string(p-rep-num) + ".html".
end procedure.
procedure search-full-path-Report:
    define input parameter p-file-name as character no-undo.
    if search(p-file-name) = ? then
        do:
            message "Не найден файл отчёта: " p-file-name view-as alert-box error.
        end.
    else
        do:
            p-file-name = search(p-file-name).
        end.
end procedure.
procedure Report-Viewer:
    define input parameter p-full-path-RepView as character no-undo.
    define input parameter p-file-name-rep-htm as character no-undo.
os-command no-wait value(p-full-path-RepView + " true " + search(p-file-name-rep-htm)).
end procedure.
procedure create-file:
    define input parameter p-file-name as character no-undo.
    output to value(string(p-file-name)).
    output close.
end procedure.
procedure proc-create-HTML:
    define input parameter p-file-name-rep-htm as character no-undo.
    define input parameter p-cli-type like ub.alc-supp-lic.cli-type no-undo.
    define input parameter p-cli-code like ub.alc-supp-lic.cli-code no-undo.
    define variable v-ii as integer no-undo.
    do:
        output stream OutStr-html to value(p-file-name-rep-htm) append convert target 'UTF-8'.
            put stream OutStr-html unformatted
                "<!DOCTYPE HTML>" skip
                ' <html>' skip
                '  <head>' skip
                '   <meta charset="utf-8">' skip
                '    <style type="text/css">' skip
                '      table ' + chr(123) + ' border-collapse: collapse; font-size: 9pt; table-layout: fixed; width: 1157px; padding: 14px; ' + chr(125) skip
                '      td ' + chr(123) ' border: 1px black ridge; word-wrap:break-word; ' + chr(125) skip
                '      htm' skip
                '      .rotate ' + chr(123) skip
                '        -webkit-transform: rotate(-90deg);' skip
                '        -moz-transform: rotate(-90deg);' skip
                '        -ms-transform: rotate(-90deg);' skip
                '        -o-transform: rotate(-90deg);' skip
                '        transform: rotate(-90deg);' skip
                '        -webkit-transform-origin: 50% 50%;' skip
                '        -moz-transform-origin: 50% 50%;' skip
                '        -ms-transform-origin: 50% 50%;' skip
                '        -o-transform-origin: 50% 50%;' skip
                '        transform-origin: 50% 50%;' skip
                '        filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);' skip
                '          ' + chr(125) skip
                '            th' + ' ' + chr(123) skip
                '            border: 1px black solid;' skip
                '            word-wrap: break-word;' skip
                '          ' + chr(125) skip
                '   </style>' skip
                '  </head>' skip
            .
    end.
    do:
            put stream OutStr-html unformatted
                ' <body>' skip
                '   <table name="Лист1" outline_below="false">' skip
                '     <thead>' skip
                '       <tr class="set_columns">' skip
                '         <td style="width: 43px; border: none;"></td>' skip
                '         <td style="width: 70px; border: none;"></td>' skip
                '         <td style="width: 70px; border: none;"></td>' skip
                '         <td style="width: 70px; border: none;"></td>' skip
                '         <td style="width: 70px; border: none;"></td>' skip
                '         <td style="width: 70px; border: none;"></td>' skip
                '         <td style="width: 100px; border: none;"></td>' skip
                '         <td style="width: 43px; border: none;"></td>' skip
                '       </tr>' skip
            .
    end.
    do:
            put stream OutStr-html unformatted
                '       <tr>' skip
                '         <td style="border: none; height: 14px"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td colspan="8" style="border: none; height: 14px; font-weight: bold; text-align: center">' + "Справочник Лицензий на продажу алкогольной продукции" + '</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td style="border: none; height: 14px; font-weight: bold"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
            .
    end.
    do:
        put stream OutStr-html unformatted
                '     <tbody>' skip
                '       <tr>' skip
                '         <th style="text-align: center; height: 30px">№ п/п</th>' skip
                '         <th style="text-align: center;">с</th>' skip
                '         <th style="text-align: center;">по</th>' skip
                '         <th style="text-align: center;">Номер</th>' skip
                '         <th style="text-align: center;">Серия</th>' skip
                '         <th style="text-align: center;">Дата выдачи</th>' skip
                '         <th style="text-align: center;">Кем выдана</th>' skip
                '         <th style="text-align: center;">На все типы</th>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <th num="" style="text-align: center">1</th>' skip
                '         <th num="" style="text-align: center">2</th>' skip
                '         <th num="" style="text-align: center">3</th>' skip
                '         <th num="" style="text-align: center">4</th>' skip
                '         <th num="" style="text-align: center">5</th>' skip
                '         <th num="" style="text-align: center">6</th>' skip
                '         <th num="" style="text-align: center">7</th>' skip
                '         <th num="" style="text-align: center">8</th>' skip
                '       </tr>' skip
        .
        output stream OutStr-html close.
    end.
    do:
        output stream OutStr-html to value(p-file-name-rep-htm) append convert target 'UTF-8'.
        if p-cli-type = ? or p-cli-code = ? then
        do:
            for each buf_alc-sale-lic no-lock
            :
                v-ii = v-ii + 1.
                put stream OutStr-html unformatted
                    '       <tr>' skip
                    '         <td num="0" style="display: yes; text-align: center; height: 20px; font-weight: normal">' + (if v-ii = ? then "" else string(v-ii)) + '</td>' skip
                    '         <td style="display: yes; text-align: center; font-weight: normal">' + (if buf_alc-sale-lic.date-from <> ? then fnc-DD-MM-YYYY(buf_alc-sale-lic.date-from) else "?") + '</td>' skip
                    '         <td style="display: yes; text-align: center; font-weight: normal">' + (if buf_alc-sale-lic.date-to <> ? then fnc-DD-MM-YYYY(buf_alc-sale-lic.date-to) else "?") + '</td>' skip
                    '         <td style="display: yes; text-align: left; font-weight: normal">' + (if buf_alc-sale-lic.number <> ? then buf_alc-sale-lic.number else "?") + '</td>' skip
                    '         <td style="display: yes; text-align: left; font-weight: normal">' + (if buf_alc-sale-lic.seria <> ? then buf_alc-sale-lic.seria else "?") + '</td>' skip
                    '         <td style="display: yes; text-align: center; font-weight: normal">' + (if buf_alc-sale-lic.date-get <> ? then fnc-DD-MM-YYYY(buf_alc-sale-lic.date-get) else "?") + '</td>' skip
                    '         <td style="display: yes; text-align: left; font-weight: normal">' + (if buf_alc-sale-lic.who-are-got <> ? then buf_alc-sale-lic.who-are-got else "?") + '</td>' skip
                    '         <td style="display: yes; text-align: center; font-weight: normal">' +
                                (if buf_alc-sale-lic.all-type <> ? then (if buf_alc-sale-lic.all-type > 0 then "+" else "-") else "?") + '</td>' skip
                    '       </tr>' skip
                .
            end.
        end.
        else
        do:
            for each buf_alc-sale-lic where
                     buf_alc-sale-lic.cli-type = p-cli-type and
                     buf_alc-sale-lic.cli-code = p-cli-code no-lock
            :
                v-ii = v-ii + 1.
                put stream OutStr-html unformatted
                    '       <tr>' skip
                    '         <td num="0" style="display: yes; text-align: center; height: 20px; font-weight: normal">' + (if v-ii = ? then "" else string(v-ii)) + '</td>' skip
                    '         <td style="display: yes; text-align: center; font-weight: normal">' + (if buf_alc-sale-lic.date-from <> ? then fnc-DD-MM-YYYY(buf_alc-sale-lic.date-from) else "?") + '</td>' skip
                    '         <td style="display: yes; text-align: center; font-weight: normal">' + (if buf_alc-sale-lic.date-to <> ? then fnc-DD-MM-YYYY(buf_alc-sale-lic.date-to) else "?") + '</td>' skip
                    '         <td style="display: yes; text-align: left; font-weight: normal">' + (if buf_alc-sale-lic.number <> ? then buf_alc-sale-lic.number else "?") + '</td>' skip
                    '         <td style="display: yes; text-align: left; font-weight: normal">' + (if buf_alc-sale-lic.seria <> ? then buf_alc-sale-lic.seria else "?") + '</td>' skip
                    '         <td style="display: yes; text-align: center; font-weight: normal">' + (if buf_alc-sale-lic.date-get <> ? then fnc-DD-MM-YYYY(buf_alc-sale-lic.date-get) else "?") + '</td>' skip
                    '         <td style="display: yes; text-align: left; font-weight: normal">' + (if buf_alc-sale-lic.who-are-got <> ? then buf_alc-sale-lic.who-are-got else "?") + '</td>' skip
                    '         <td style="display: yes; text-align: center; font-weight: normal">' +
                                (if buf_alc-sale-lic.all-type <> ? then (if buf_alc-sale-lic.all-type > 0 then "+" else "-") else "?") + '</td>' skip
                    '       </tr>' skip
                .
            end.
        end.
    end.
    do:
                put stream OutStr-html unformatted
                '     </tbody>' skip
                '   </table>' skip
                '  </body>' skip
                ' </html>' skip
                .
        output stream OutStr-html close.
    end.
end procedure.
function fnc-convert-dot-to-colon returns character
(input p-data as decimal, input p-accur as character):
    define variable result as character no-undo.
    define variable v-str-result as character no-undo.
    p-data = round(p-data, 2).
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).
    return v-str-result.
end function.
function fnc-DD-MM-YYYY returns character
(input p-dat-date as date):
    define variable result as character no-undo.
    define variable p-str-date as character no-undo.
    p-str-date = replace(string(p-dat-date,'99.99.9999'), "/", ".").
        return p-str-date.
end function.
