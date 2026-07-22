using ibs.th.str.*.
block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: bed8e2b06c8e, 2357, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:34 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: hdd-report-shd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/hdd-report-shd.p $":U .
define variable vss-description as character no-undo init "Результаты проверки HDD".
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
define input parameter parparentproc    as widget-handle           no-undo.
define input parameter p-Date-start     as date no-undo .
define input parameter p-Date-end     as date no-undo .
define input parameter p-obj-list  as character no-undo .
define input parameter p-folder  as character no-undo .
define input parameter p-file  as character no-undo .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
function fnc-convert-dot-to-colon returns character
    (input p-data as decimal, input p-accur as character, input p-num as integer) forward.
function fnc-convert-dot-to-colon returns character
(input p-data as decimal, input p-accur as character, input p-num as integer):
    define variable result as character no-undo.
    define variable v-str-result as character no-undo.
    if p-data = ? then p-data = 0 .
    p-data = round(p-data, p-num).
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).
    return v-str-result.
END FUNCTION.
define temp-table tt-devicePC no-undo
  field id          as integer
  field modeldevice like ub.devisPC.modeldevice
  field ModelPC     like ub.devisPC.ModelPC
  field namepc      like ub.devisPC.namepc
  field date_start  as character
  field time_start  as character
  field date_end    as character
  field time_end    as character
  field ProcDisk    as decimal
  field UserProc    as decimal
  field status_     as character
  field db-num      as integer
  index pi id .
define temp-table tt-devicePCAttr no-undo
  field id        as integer
  field date_     as date
  field time_     as integer
  field name_     as character
  field db-num    as integer
  field value_    as decimal
  field tresh     as decimal
  field type_     as character
  field raw_value as character
  field ch_raw    as decimal
  field ch_val    as decimal
  index pi id
  .
define temp-table tt-attrDevis like ub.devisPC-attr
  index pi id db-num
  asc date asc time_.
define buffer buf_devisPC        for ub.devisPC .
define buffer buf_devisPCAttr    for ub.devisPC-attr .
define buffer bf_devisPCAttr     for ub.devisPC-attr .
define buffer bt_devisPCAttr     for ub.devisPC-attr .
define buffer buf_devisPC-attr   for ub.devisPC-attr .
define buffer buf_tt-devisPCAttr for tt-devicePCAttr .
define buffer buf_tt-devicePC    for tt-devicePC .
define stream Out-Stream.
define stream OutStr-html.
define stream Outhtmllog.
define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
define variable ii                  as integer   no-undo .
define variable jj                  as integer   no-undo .
define variable v-change-Raw        as decimal   no-undo .
define variable v-change-Value      as decimal   no-undo .
define variable v-ok-Raw            as decimal   no-undo .
define variable v-ok-Value          as decimal   no-undo .
define variable v-delta             as decimal   no-undo .
define variable v-time-start        as integer   no-undo .
define variable v-time-end          as integer   no-undo .
define variable v-time-start1       as character no-undo .
define variable v-time-end1         as character no-undo .
define variable v-date-start        as date      no-undo .
define variable v-date-end          as date      no-undo .
define variable v-color             as character no-undo .
define variable v-host-name         as character no-undo .
define variable v-obj-name          as character no-undo .
define variable v-period            as character no-undo .
do
  on error undo, return error return-value
  :
  for first ub.sysconf, first ub.clients no-lock where ub.clients.obj-code = ub.sysconf.host-code and ub.clients.obj-type = 'орг':U:
    v-host-name = ub.clients.obj-name .
  end.
  if p-Date-start = ? then p-Date-start = today .
  if p-Date-end = ? then p-Date-end = today .
  v-period = "c: " + string (p-Date-start,"99.99.9999") + " по " + string (p-Date-end,"99.99.9999") .
  if p-obj-list = "" then p-obj-list = "0" .
  do ii = 1 to num-entries (p-obj-list, chr(44)):
    for first ub.clients no-lock where ub.clients.obj-code = integer(entry(ii, p-obj-list, chr(44))) and ub.clients.obj-type = 'маг':U:
      v-obj-name = v-obj-name + "," + ub.clients.obj-name .
    end.
    for each buf_devisPC no-lock where buf_devisPC.DB-num = integer(entry(ii, p-obj-list, chr(44))):
      create tt-devicePC .
      assign
        tt-devicePC.id          = buf_devisPC.id
        tt-devicePC.db-num      = buf_devisPC.DB-num
        tt-devicePC.modeldevice = buf_devisPC.modeldevice
        tt-devicePC.ModelPC     = buf_devisPC.ModelPC
        tt-devicePC.namepc      = buf_devisPC.namepc
        .
      empty temp-table tt-attrDevis .
      for each buf_devisPCAttr no-lock where buf_devisPCAttr.id = tt-devicePC.id and buf_devisPCAttr.db-num = tt-devicePC.DB-num
        and buf_devisPCAttr.attr-code <> "ProcDisk" and buf_devisPCAttr.attr-code <> "UserProc" and buf_devisPCAttr.attr-code <> "testStatus" and buf_devisPCAttr.date >= p-Date-start
        and buf_devisPCAttr.date <= p-Date-end break by buf_devisPCAttr.attr-code by buf_devisPCAttr.date by buf_devisPCAttr.time_:
        find first tt-attrDevis where tt-attrDevis.id = buf_devisPCAttr.id and tt-attrDevis.db-num = buf_devisPCAttr.db-num and tt-attrDevis.attr-code = buf_devisPCAttr.attr-code
          and tt-attrDevis.date = buf_devisPCAttr.date and tt-attrDevis.time_ = buf_devisPCAttr.time_ no-error .
        if not available (tt-attrDevis) then
        do:
          create tt-attrDevis .
          buffer-copy buf_devisPCAttr to tt-attrDevis .
        end.
      end.
      for each tt-attrDevis where tt-attrDevis.id = tt-devicePC.id and tt-attrDevis.db-num = tt-devicePC.db-num break by tt-attrDevis.attr-code by tt-attrDevis.date by tt-attrDevis.time_:
        if first-of (tt-attrDevis.attr-code) then
        do:
          create tt-devicePCAttr .
          assign
            tt-devicePCAttr.id        = tt-attrDevis.id
            tt-devicePCAttr.db-num    = tt-attrDevis.db-num
            tt-devicePCAttr.name_     = tt-attrDevis.attr-code
            tt-devicePCAttr.type_     = tt-attrDevis.type
            tt-devicePCAttr.value_    = decimal(tt-attrDevis.attr-value)
            tt-devicePCAttr.raw_value = tt-attrDevis.attr-Raw-value
            .
        end.
        if last-of (tt-attrDevis.attr-code) and last-of (tt-attrDevis.date) then
        do:
          find first tt-devicePCAttr where tt-devicePCAttr.id = tt-attrDevis.id and tt-devicePCAttr.db-num = tt-attrDevis.db-num
            and tt-devicePCAttr.name_ = tt-attrDevis.attr-code no-error .
          if available (tt-devicePCAttr) then
          do:
            assign
              tt-devicePCAttr.tresh = decimal(tt-attrDevis.tresh)
              .
            decimal (tt-attrDevis.attr-Raw-value) no-error .
            if not error-status:error then
            do:
              tt-devicePCAttr.ch_raw = decimal(tt-attrDevis.attr-Raw-value) - decimal(tt-devicePCAttr.raw_value) .
            end.
            tt-devicePCAttr.ch_val = decimal(tt-attrDevis.attr-value) - tt-devicePCAttr.value_ .
            tt-devicePCAttr.raw_value = tt-attrDevis.attr-Raw-value.
            tt-devicePCAttr.value_    = decimal(tt-attrDevis.attr-value).
          end.
        end.
      end.
      assign
        v-time-start1 = ""
        v-date-end    = ?
        v-date-start  = ?
        .
      for each tt-attrDevis no-lock where tt-attrDevis.id = tt-devicePC.id and tt-attrDevis.db-num = tt-devicePC.db-num break by tt-attrDevis.date by tt-attrDevis.time_:
        if first-of (tt-attrDevis.date) then
        do:
          if v-time-start1 = "" then v-time-start1  = string(truncate (tt-attrDevis.time_ / 3600, 0)) + ":" + string((tt-attrDevis.time_ modulo 3600) / 60,"99") .
          if v-date-start = ? then v-date-start = tt-attrDevis.date .
        end.
        if last-of (tt-attrDevis.date) and last-of (tt-attrDevis.time_) then
        do:
          find first buf_tt-devicePC where buf_tt-devicePC.id = tt-attrDevis.id and buf_tt-devicePC.db-num = tt-attrDevis.db-num no-error .
          assign
            buf_tt-devicePC.time_end   = string(truncate (tt-attrDevis.time_ / 3600, 0)) + ":" + string((tt-attrDevis.time_ modulo 3600) / 60,"99")
            buf_tt-devicePC.date_end   = string(tt-attrDevis.date)
            buf_tt-devicePC.time_start = v-time-start1
            buf_tt-devicePC.date_start = string(v-date-start)
            .
        end.
      end.
    end.
    for each tt-devicePC:
      find first tt-devicePCAttr where tt-devicePCAttr.id = tt-devicePC.id no-error .
      if not available (tt-devicePCAttr) then delete tt-devicePC .
    end.
    output stream Outhtmllog to value(p-folder + "\" + p-file + ".txt") append convert target 'UTF-8'.
    find first tt-devicePCAttr no-error .
    if not available (tt-devicePCAttr) then
    do:
      put stream Outhtmllog unformatted
        "По АЗК №" + entry(ii, p-obj-list, chr(44)) + " отсутствуют данные за выбранный период c " + string(p-Date-start,"99/99/9999") + " по "  + string(p-Date-end,"99/99/9999") skip .
      return .
    end.
    else
    do:
      put stream Outhtmllog unformatted
        "По АЗК №" + entry(ii, p-obj-list, chr(44)) + " данные за выбранный период c " + string(p-Date-start,"99/99/9999") + " по "  + string(p-Date-end,"99/99/9999") + " " + "выгружены" skip .
    end.
    output stream Outhtmllog close.
  end.
  run get-report-num (output p-report-id).
  v-file-name-rep-htm = p-folder + "\" + string(p-file) + string(p-Date-end,"99999999") + replace (string(time,"HH:MM:SS"),":","") + ".html".
  v-obj-name = trim(v-obj-name,",").
  output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
  put stream OutStr-html unformatted
    "<!DOCTYPE HTML>" skip
    ' <html>' skip
    '  <head>' skip
    '   <meta charset="utf-8">' skip
    '    <style type="text/css">' skip
    '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
    '   </style>' skip
    '  </head>' skip
    .
  put stream OutStr-html unformatted
    '<body>' skip
    '<TABLE name="1"  fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
    .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 170px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '</tr>' skip
    '<tr><td colspan="12" style="text-align: center;">Результаты проверки HDD</td></tr>'
    '<tr><td colspan="12" style="text-align: left;">По фирме: ' + v-host-name + '</td></tr>'
    '<tr><td colspan="12" style="text-align: left;">По объектам: ' + v-obj-name + '</td></tr>'
    '<tr><td colspan="12" style="text-align: left;">За период ' + v-period + '</td></tr>'
    .
  put stream OutStr-html unformatted
    '<TR><TD colspan="12"></TD></TR>' skip
    '</thead>' skip
    '<tbody>' skip
    .
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">АЗК</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Начало периода</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Конец периода</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Имя ПК</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Модель диска</TD>' skip
    '<TD text_wrap="true" colspan="7" style="text-align: center;">Атрибуты диска</TD>' skip
    '</TR>' skip .
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" style="text-align: center;">Название</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Value</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Thresh</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Тип</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Raw_value</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Изменение Raw_value</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Изменение Value</TD>' skip
    '</TR>'skip
    .
  for each tt-devicePC no-lock:
    find first tt-devicePCAttr no-lock where tt-devicePCAttr.id = tt-devicePC.id no-error .
    if not available (tt-devicePCAttr) then next .
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-devicePC.db-num) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string(tt-devicePC.date_start + " " + tt-devicePC.time_start) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string (tt-devicePC.date_end + " " + tt-devicePC.time_end) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string (tt-devicePC.namepc) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' + string (tt-devicePC.modeldevice) + '</TD>' skip
      .
    for each tt-devicePCAttr no-lock where tt-devicePCAttr.id = tt-devicePC.id break by tt-devicePCAttr.id by tt-devicePCAttr.name_ by tt-devicePCAttr.date_ by tt-devicePCAttr.time_
      :
      if tt-devicePCAttr.value_ <= tt-devicePCAttr.tresh then v-color = "red" .
      else v-color = "white" .
      if first-of (tt-devicePCAttr.id ) then
      do:
        put stream OutStr-html unformatted
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.name_) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.value_) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.tresh) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.type_) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.raw_value) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.ch_raw) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.ch_val) + '</TD>' skip
          '</tr>'
          .
      end.
      else
      do:
        put stream OutStr-html unformatted
          '<TR>' skip
          '<TD text_wrap="true" colspan="5" style="text-align: center;"></TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.name_) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.value_) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.tresh) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.type_) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.raw_value) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.ch_raw) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.ch_val) + '</TD>' skip
          '</tr>'
          .
      end.
    end.
  end.
  put stream OutStr-html unformatted
    '</tbody>' skip
    '<tfoot>' skip.
  put stream OutStr-html unformatted
    '</tfoot>' skip
    '</table>' skip
    '</body>' skip
    '</html>' skip
    .
  output stream OutStr-html close.
  define variable v-report-name       as character no-undo .
  define variable v-fill-path-RepView as character no-undo.
    if search("exe\ReportViewer\reportviewer.exe") <> ? then
  do:
    v-fill-path-RepView = search("exe\ReportViewer\reportviewer.exe").
  end.
  else
  do:
    message "Не найдена программа просмотра отчёта!" view-as alert-box error.
  end.
  os-command no-wait value(v-fill-path-RepView + " false " + v-file-name-rep-htm).
end.
PROCEDURE get-report-num :
  define output parameter p-report-num as integer no-undo .
  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.
END PROCEDURE.
