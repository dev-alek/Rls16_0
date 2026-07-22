block-level on error undo, throw.
define input parameter parParentProc as   widget-handle         no-undo.
define input parameter rec_id        as recid.
define input parameter print_zak     as log no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-specif.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-specif.p $":U .
def var vss-description as character no-undo init "Печать спецификации к документу по партиям".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function breakstr returns character ( input        for-name    as character,
                                      input        line-length as integer,
                                      input-output line1       as character,
                                      input-output line2       as character ) :
  define variable ii as integer no-undo.
  if length( for-name ) > line-length then do:
    assign ii    = 1
           line1 = "":u
           line2 = "":u.
    if length( entry( ii, for-name , " ":u ) ) > line-length then do:
      assign line1 =       substring( for-name, 1, line-length     )
             line2 = trim( substring( for-name,    line-length + 1 ) ).
    end.                                                     else do:
      do while length( line1 + entry( ii, for-name, " ":u ) ) < ( line-length + 1 ) :
        assign line1 = line1 + entry( ii, for-name, " ":u ) + " ":u
               ii    = ii    + 1.
        if length( entry( ii, for-name, " ":u ) ) > line-length then do:
          assign line1 = line1 + substring( for-name, length( line1 ), line-length - length( line1 ) + 1 ).
        end.
      end.
      assign line2 = trim( substring( for-name, length( line1 ) ) ).
    end.
  end.                                else do:
    assign line1 = for-name
           line2 = "":u.
  end.
  return ( line1 ).
end function.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
def var sym1 as char init ":" no-undo.
def var sym2 as char init ":" no-undo.
def var sym3 as char init ":" no-undo.
def var sym4 as char init ":" no-undo.
def var sym5 as char init ":" no-undo.
def var sym6 as char init ":" no-undo.
def var sym7 as char init ":" no-undo.
def var sym8 as char init ":" no-undo.
def var sym9 as char init ":" no-undo.
def var sym10 as char init ":" no-undo.
def var sym11 as char init ":" no-undo.
def var Line             as      char    no-undo.
def var tb-code          as      char    no-undo.
def var b-code           as      integer no-undo .
def var list-b-code      as      char    no-undo.
def var full_list-b-code as      char    no-undo.
def var is-new           as      logical no-undo.
def var new-list         as      char    no-undo.
def var Lines_Counter    as      integer no-undo.
def var part-b-code      as      char    no-undo.
def var tdoc-date    like trn-doc.doc-date no-undo.
def var tdoc-code    like trn-doc.doc-code no-undo.
def var i   as      integer                 no-undo.
def var parts-PS like parts.PS no-undo.
def var parts-PS1 like parts.PS no-undo.
def var parts-PS2 like parts.PS no-undo.
define variable g#report-num  as integer no-undo .
define variable g#quest-print as logical no-undo .
define variable g#log         as logical no-undo .
def var vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-param no-undo   field param-code     as character   field param-sub-code as character   field param-value    as character   index xpk is primary unique param-code param-sub-code   .
procedure paramls-clear :
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    for each buf_temp-param
    on error undo, return error
    :
      delete buf_temp-param .
    end.
  end.
end procedure.
procedure paramls-write :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
      .
    end.
    assign
      buf_temp-param.param-value = p-value
    .
  end.
end procedure.
procedure paramls-read :
  define input  parameter p-code          as character no-undo .
  define input  parameter p-sub-code      as character no-undo .
  define input  parameter p-default-value as character no-undo .
  define output parameter p-value         as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if available buf_temp-param then do:
      assign
        p-value = buf_temp-param.param-value
      .
    end.
    else do:
      assign
        p-value = p-default-value
      .
    end.
  end.
end procedure.
procedure paramls-append :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
         where buf_temp-param.param-code     = p-code
           and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
        buf_temp-param.param-value    = p-value
      .
    end.
    else do:
        assign
            buf_temp-param.param-value = buf_temp-param.param-value + ",":U + p-value
        .
    end.
  end.
end procedure.
define variable vss-include-info8 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define stream excel-line.
define stream excel-cell.
define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character
    index pi is primary unique data-key
.
define temp-table temp_line-data no-undo
    field data-key     as character
    field xl-line-id   as integer
    field iCounter    as integer
    field cTb-code    as character format "X(10)"
    field artic       like ub.goods.artic
    field gds-name    like ub.goods.gds-name
    field qnty        as decimal
    field unit-base   like ub.goods.unit-base
    field last-date   like ub.parts.last-date
    field PS          like ub.parts.PS
    field price-rubl  like ub.parts.price-rubl
    field list-b-code as character
    index pi is primary unique xl-line-id
.
define variable v-specifxl-current-data-row     as integer      no-undo.
define variable v-specifxl-cell-file-name       as character    no-undo.
define variable v-specifxl-data-file-name       as character    no-undo.
procedure specifxl-init :
    define buffer buf_temp_cell-data        for temp_cell-data.
do
for buf_temp_cell-data on error undo, return error :
    assign
        v-specifxl-current-data-row = 0
    .
    run gbl/_tmpfile.p
      (input  "xd"
      ,input  ".txt"
      ,output v-specifxl-data-file-name
      ).
    output stream excel-line to value( v-specifxl-data-file-name ).
    run gbl/_tmpfile.p
      (input "xc"
      ,input ".txt"
      ,output v-specifxl-cell-file-name
      ).
    output stream excel-cell to value( v-specifxl-cell-file-name ).
    run specifxl-write-cell-data in this-procedure
         (input "valutCode":U
         ,input "0":U
      ).
    run specifxl-write-cell-data in this-procedure (
          input "regularExpressions":U
        , input "1":U
      ).
    if print_zak then do:
      run specifxl-write-cell-data in this-procedure (
            input "columnList":U
          , input "ID,code,artic,name,qnty,EI,ldate,PS,price,listbcode":U
      ).
      run specifxl-write-cell-data in this-procedure (
            input "columnType":U
          , input "I,S,S,S,D,S,S,S,D,S":U
      ).
      run specifxl-write-cell-data in this-procedure (
            input "columnAmount":U
          , input "10":U
      ).
    end.
    else do:
      run specifxl-write-cell-data in this-procedure (
            input "columnList":U
          , input "ID,code,artic,name,qnty,EI,ldate,PS,listbcode":U
      ).
      run specifxl-write-cell-data in this-procedure (
            input "columnType":U
          , input "I,S,S,S,D,S,S,S,S":U
      ).
      run specifxl-write-cell-data in this-procedure (
            input "columnAmount":U
          , input "9":U
      ).
    end.
end.
end procedure.
procedure specifxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
      if print_zak then do:
        export "exe/specif.xlt":U.
      end.
      else do:
        export "exe/specif1.xlt":U.
      end.
        export "exe/t_97.bas":U.
        export v-specifxl-cell-file-name.
        export v-specifxl-data-file-name.
    output close.
end.
end procedure.
procedure specifxl-write-cell-data :
define input parameter p-data-key   as character        no-undo.
define input parameter p-data-value as character        no-undo.
    define buffer buf_temp_cell-data     for temp_cell-data.
do
for buf_temp_cell-data
on error undo, return error
:
    find first buf_temp_cell-data
         where buf_temp_cell-data.data-key = p-data-key
    no-error.
    if not available buf_temp_cell-data
    then do:
        create buf_temp_cell-data.
        assign
            buf_temp_cell-data.data-key = p-data-key
        .
    end.
    assign
        buf_temp_cell-data.data-value = p-data-value
    .
    put stream excel-cell unformatted
                        buf_temp_cell-data.data-key
        chr(9)   buf_temp_cell-data.data-value
        chr(10)
    .
end.
end procedure.
procedure specifxl-write-line-data :
define input parameter p-Counter     as integer               no-undo.
define input parameter p-cTb-code    as character format "X(10)" no-undo.
define input parameter p-artic       like goods.artic         no-undo.
define input parameter p-gds-name    like ub.goods.gds-name   no-undo.
define input parameter p-qnty        as decimal               no-undo.
define input parameter p-unit-base   like ub.goods.unit-base  no-undo.
define input parameter p-last-date   like ub.parts.last-date  no-undo.
define input parameter p-PS          like ub.parts.PS         no-undo.
define input parameter p-price-rubl  like ub.parts.price-rubl no-undo.
define input parameter p-list-b-code as character             no-undo.
define input parameter p-print_zak   as logical               no-undo.
define buffer buf_temp_line-data        for temp_line-data.
do
for buf_temp_line-data
on error undo, return error
:
  for each buf_temp_line-data
  :
      delete buf_temp_line-data.
  end.
  create buf_temp_line-data.
  assign
    v-specifxl-current-data-row = v-specifxl-current-data-row + 1
  .
  assign
    buf_temp_line-data.data-key     = "LD":U
    buf_temp_line-data.xl-line-id   = v-specifxl-current-data-row
    buf_temp_line-data.iCounter     = p-Counter
    buf_temp_line-data.cTb-code     = p-cTb-code
    buf_temp_line-data.artic        = p-artic
    buf_temp_line-data.gds-name     = p-gds-name
    buf_temp_line-data.qnty         = p-qnty
    buf_temp_line-data.unit-base    = p-unit-base
    buf_temp_line-data.last-date    = p-last-date
    buf_temp_line-data.PS           = p-PS
    buf_temp_line-data.price-rubl   = p-price-rubl
    buf_temp_line-data.list-b-code  = p-list-b-code
  .
  put stream excel-line unformatted
                    buf_temp_line-data.data-key
    chr(9)   ( if buf_temp_line-data.iCounter = 0 then "":U else string( buf_temp_line-data.iCounter ) )
    chr(9)   buf_temp_line-data.cTb-code
    chr(9)   buf_temp_line-data.artic
    chr(9)   buf_temp_line-data.gds-name
    chr(9)   ( if buf_temp_line-data.qnty = 0 then "" else string( buf_temp_line-data.qnty ) )
    chr(9)   buf_temp_line-data.unit-base
    chr(9)   ( if buf_temp_line-data.iCounter = 0 then ( if buf_temp_line-data.last-date = ? then "":U else string( buf_temp_line-data.last-date, "99.99.9999" ) ) else "":U )
    chr(9)   buf_temp_line-data.PS
    chr(9)   ( if print_zak then ( if buf_temp_line-data.price-rubl = 0 then "" else string( buf_temp_line-data.price-rubl ) ) else buf_temp_line-data.list-b-code )
    ( if print_zak then chr(9) else "" )
    ( if print_zak then buf_temp_line-data.list-b-code else "" )
    chr(10)
  .
end.
end procedure.
procedure specifxl-run-excel :
  define input parameter p-header-filename    as character        no-undo.
  define input parameter p-data-filename      as character        no-undo.
  define variable v-template-file-name    as character    no-undo.
  define variable v-vb-file-name          as character    no-undo.
  define buffer buf_temp-param for temp-param .
  do for buf_temp-param on error undo, return error :
    create buf_temp-param.
    assign
        v-template-file-name    = search( "exe/sp_97.xlt" )
        v-vb-file-name          = search( "exe/t_97.bas")
    .
    if v-template-file-name = ?  or v-template-file-name = "":U  then do:
        message  "Ошибка имени файла шаблона." view-as alert-box error.
    end.
    if v-vb-file-name = ?  or v-vb-file-name = "":U then do:
        message  "Ошибка имени файла кода обработки."   view-as alert-box error.
    end.
    run paramls-write in this-procedure (
          input "template":U
        , input "template-file-name":U
        , input v-template-file-name
    ).
    run paramls-write in this-procedure (
          input "template":U
        , input "vb-file-name":U
        , input v-vb-file-name
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-header-filename":U
        , input p-header-filename
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-filename":U
        , input p-data-filename
    ).
    run gbl/macroxlt.p (
        input-output table buf_temp-param
    ) no-error.
    if error-status :error
    then do:
        message vss-workfile vss-revision vss-description skip(1)
            skip "Ошибка создания файла Excel."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
  end.
end procedure.
DEFINE STREAM Out_Stream.
DEFINE FRAME parts-print
        sym1 column-label ":!:" format "X(1)"
        Lines_Counter COLUMN-LABEL " N!п/п" format ">>>9"
        sym2 column-label ":!:" format "X(1)"
        tb-code column-label "Код" format "x(10)"
        sym3 column-label ":!:" format "X(1)"
        goods.artic COLUMN-LABEL "Артикул" format "X(16)"
        sym4 column-label ":!:" format "X(1)"
        goods.gds-name COLUMN-LABEL "Наименование!Партия" format "X(40)"
        sym5 column-label ":!:" format "X(1)"
        parts.fact-qnty COLUMN-LABEL " Количество " format "->>>,>>9.<<<"
        sym6 column-label ":!:" format "X(1)"
        goods.unit-base COLUMN-LABEL "Ед.!изм." format "X(4)"
        sym7 column-label ":!:" format "X(1)"
        parts.last-date COLUMN-LABEL "Срок!годности" format "99.99.9999"
        sym8 column-label ":!:" format "X(1)"
        parts.PS COLUMN-LABEL "Описание" format "X(46)"
        sym9 column-label ":!:" format "X(1)"
        list-b-code COLUMN-LABEL "БАР-КОДЫ по товару" format "X(27)"
        sym10 column-label ":!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
            tdoc-code AT 70 format "X(10)" " от " tdoc-date format "99/99/99"
            "Страница " AT 120 PAGE-NUMBER( Out_Stream ) AT 130 FORMAT ">>9" SKIP
        Line format "X(197)" AT 1
    with width 235 down stream-io.
DEFINE FRAME parts-print1
        sym1 column-label ":!:" format "X(1)"
        Lines_Counter COLUMN-LABEL " N!п/п" format ">>>9"
        sym2 column-label ":!:" format "X(1)"
        tb-code column-label "Код" format "x(10)"
        sym3 column-label ":!:" format "X(1)"
        goods.artic COLUMN-LABEL "Артикул" format "X(16)"
        sym4 column-label ":!:" format "X(1)"
        goods.gds-name COLUMN-LABEL "Наименование!Партия" format "X(40)"
        sym5 column-label ":!:" format "X(1)"
        parts.fact-qnty COLUMN-LABEL " Количество " format "->>>,>>9.<<<"
        sym6 column-label ":!:" format "X(1)"
        goods.unit-base COLUMN-LABEL "Ед.!изм." format "X(4)"
        sym7 column-label ":!:" format "X(1)"
        parts.last-date COLUMN-LABEL "Срок!годности" format "99.99.9999"
        sym8 column-label ":!:" format "X(1)"
        parts.PS COLUMN-LABEL "Описание" format "X(32)"
        sym9 column-label ":!:" format "X(1)"
        parts.price-rubl COLUMN-LABEL "   Цена  "   format "->>>,>>9.99"
        sym10 column-label ":!:" format "X(1)"
        list-b-code COLUMN-LABEL "БАР-КОДЫ по товару" format "X(27)"
        sym11 column-label ":!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
            tdoc-code AT 70 format "X(10)" " от " tdoc-date format "99/99/99"
            "Страница " AT 120 PAGE-NUMBER( Out_Stream ) AT 130 FORMAT ">>9" SKIP
        Line format "X(197)" AT 1
    with width 235 down stream-io.
FIND trn-doc WHERE recid( trn-doc ) = rec_id  NO-LOCK.
if session:set-wait-state("compiler") then.
Line = fill("-", 200).
assign
  Lines_Counter = 0
  tdoc-code = trn-doc.doc-code
  tdoc-date = trn-doc.doc-date
.
run get-report-num  in parParentProc(output g#report-num).
run get-quest-print in parParentProc(output g#quest-print).
output STREAM Out_Stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size 62 .
run specifxl-init in this-procedure .
 if print_zak = yes then do:
   FORM with FRAME parts-print1 .
 end.
 else do:
   FORM with FRAME parts-print .
 end.
 FORM HEADER
   Line format "X(197)" AT 1 SKIP "Продолжение - на следующей странице" AT 30 SKIP
   with FRAME BottomFrame width 198 PAGE-BOTTOM NO-LABELS NO-BOX .
 VIEW STREAM Out_Stream FRAME BottomFrame .
PUT STREAM Out_Stream "С П Е Ц И Ф И К А Ц И Я   к документу N "
    AT 32 format "X(40)" trn-doc.doc-code format "X(10)" "  от  "
    trn-doc.doc-date format "99.99.9999" SKIP(1).
run specifxl-write-cell-data in this-procedure (
      input "h_docName":U
    , input string("С П Е Ц И Ф И К А Ц И Я   к документу №  " + string(trn-doc.doc-code) ) + "  от  " + string( trn-doc.doc-date, "99.99.9999" )
).
run specifxl-write-cell-data in this-procedure (
      input "h_printdate":U
    , input cur-time-print()
).
FOR EACH doc-line WHERE doc-line.doc-code = trn-doc.doc-code NO-LOCK
                                              BY doc-line.artic:
    FIND goods WHERE goods.prod-type = doc-line.prod-type AND
                                      goods.prod-code = doc-line.prod-code AND
                                      goods.artic = doc-line.artic NO-LOCK .
    if print_zak = yes then DISPLAY STREAM Out_Stream with FRAME parts-print1 .
    else                    DISPLAY STREAM Out_Stream with FRAME parts-print .
    assign
      Lines_Counter = Lines_Counter + 1
    .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  goods.gds-code
  ,input  ?
  ,output b-code
  ) no-error .
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода товара" skip  "Код товара" goods.gds-code skip
      view-as alert-box error .
      undo, return error .
    end.
    run b-code-lst in this-procedure .
    assign
      full_list-b-code = list-b-code
    .
    run sub-b-code-lst in this-procedure  (input-output list-b-code, output new-list) .
    if print_zak = no then do:
      DISPLAY STREAM Out_Stream
        sym1 Lines_Counter
        sym2 string( goods.gds-code ) @ tb-code
        sym3 goods.artic
        sym4 goods.gds-name
        sym5 (if can-do( 'факт':U , trn-doc.status_ ) then doc-line.fact-qnty else doc-line.doc-qnty) @ parts.fact-qnty
        sym6 goods.unit-base
        sym7
        sym8
        sym9 list-b-code
        sym10
      with FRAME parts-print .
      DOWN STREAM Out_Stream 1 with FRAME parts-print .
    end.
    else do:
        DISPLAY STREAM Out_Stream
          sym1 Lines_Counter
          sym2 string( goods.gds-code ) @ tb-code
          sym3 goods.artic
          sym4 goods.gds-name
          sym5 (if can-do( 'факт':U , trn-doc.status_ ) then doc-line.fact-qnty else doc-line.doc-qnty) @ parts.fact-qnty
          sym6 goods.unit-base
          sym7
          sym8
          sym9
          sym10 list-b-code
          sym11
        with FRAME parts-print1 .
        DOWN STREAM Out_Stream 1 with FRAME parts-print1 .
    end.
    run fill-line( Lines_Counter, goods.gds-code, goods.artic, goods.gds-name,
                   (if can-do( 'факт':U , trn-doc.status_ ) then doc-line.fact-qnty else doc-line.doc-qnty),
                   goods.unit-base, ? , "" , 0 , full_list-b-code, print_zak ).
    FOR EACH parts NO-LOCK
      WHERE parts.out-code = trn-doc.doc-code
        AND parts.artic = doc-line.artic
        AND parts.prod-type = doc-line.prod-type
        AND parts.prod-code = doc-line.prod-code
    BREAK BY parts.part-code:
        FIND bar-code WHERE bar-code.gds-code = goods.gds-code AND
                                              bar-code.unit-cli = goods.unit-base AND
                                              bar-code.part-code = parts.part-code AND
                                              bar-code.in-code = parts.in-code
                                              NO-LOCK NO-ERROR .
        if available bar-code then do:
          assign tb-code = string( bar-code.b-code ).
          if lookup( tb-code, full_list-b-code ) = 0 then
            assign
              part-b-code = tb-code
              full_list-b-code = full_list-b-code + (if full_list-b-code = "" then "" else ",") + tb-code
              new-list = new-list + (if new-list = "" then "" else ",") + tb-code
            .
          else
            part-b-code = "".
        end.
        else
            assign tb-code = "" part-b-code = "".
        assign parts-PS = ENTRY( 1, parts.PS , chr( 10 ) ) .
        DO i = 2 TO ( NUM-ENTRIES( parts.PS , chr( 10 ) ) ) :
            assign parts-PS = parts-PS + " " + ENTRY( i, parts.PS , chr( 10 ) ) .
        END.
        assign parts-PS = trim( parts-PS ) .
        parts-PS1 = breakstr(parts-PS, (if print_zak = yes then 32 else 46 ), input-output parts-PS1, input-output parts-PS2).
        Assign
          list-b-code = new-list
        .
        run sub-b-code-lst in this-procedure  (input-output list-b-code, output new-list) .
        if print_zak = yes then do:
          DISPLAY STREAM Out_Stream
            sym1
            sym2
            sym3
            sym4 ( if parts.part-code = "" then "  ----  " else parts.part-code ) @ goods.gds-name
            sym5 ( if can-do( 'факт':U , trn-doc.status_ ) then parts.fact-qnty else parts.qnty ) @ parts.fact-qnty
            sym6 goods.unit-base
            sym7 parts.last-date
            sym8 parts-PS1 @ parts.PS
            sym9 ( if PrintRubl = yes then parts.price-rubl else parts.price-base ) @ parts.price-rubl
            sym10 list-b-code
            sym11
          with FRAME parts-print1 .
          DOWN STREAM Out_Stream 1 with FRAME parts-print1 .
        end.
        else do:
          DISPLAY STREAM Out_Stream
            sym1
            sym2
            sym3
            sym4 ( if parts.part-code = "" then "  ----  " else parts.part-code ) @ goods.gds-name
            sym5 ( if can-do( 'факт':U , trn-doc.status_ ) then parts.fact-qnty else parts.qnty ) @ parts.fact-qnty
            sym6 goods.unit-base
            sym7 parts.last-date
            sym8 parts-PS1 @ parts.PS
            sym9 list-b-code
            sym10
          with FRAME parts-print .
          DOWN STREAM Out_Stream 1 with FRAME parts-print .
        end.
        run fill-line( 0 , "" , "" , ( if parts.part-code = "" then "  ----  " else parts.part-code ) ,
                       ( if can-do( 'факт':U , trn-doc.status_ ) then parts.fact-qnty else parts.qnty ),
                       goods.unit-base, parts.last-date, parts-PS,
                       ( if PrintRubl = yes then parts.price-rubl else parts.price-base ), part-b-code, print_zak ).
        assign parts-PS = trim( parts-PS2 ) .
        DO WHILE parts-PS <> "" or new-list <> "" and last( parts.part-code ) :
          parts-PS1 = breakstr(parts-PS, (if print_zak = yes then 32 else 46 ), input-output parts-PS1, input-output parts-PS2).
          assign list-b-code = new-list .
          run sub-b-code-lst in this-procedure  (input-output list-b-code, output new-list) .
          if print_zak = yes then do:
            DISPLAY STREAM Out_Stream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 parts-PS1 @ parts.PS sym9 sym10 list-b-code sym11 with FRAME parts-print1 .
            DOWN STREAM Out_Stream 1 with FRAME parts-print1 .
          end.
          else do:
            DISPLAY STREAM Out_Stream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 parts-PS1 @ parts.PS sym9 list-b-code sym10 with FRAME parts-print .
            DOWN STREAM Out_Stream 1 with FRAME parts-print .
          end.
          assign parts-PS = trim( parts-PS2 ) .
        END .
    END.
END.
PUT STREAM Out_Stream Line format "X(197)" AT 1 SKIP .
HIDE STREAM Out_Stream FRAME BottomFrame .
output STREAM Out_Stream CLOSE.
run specifxl-close in this-procedure .
if session:set-wait-state("") then.
def var Log-Res as log no-undo .
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_waybills-to-file_print':U
    ,input  'firm':U
    ,input  trn-doc.host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output Log-Res
    )  .
end.
if Log-Res then DO:
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 0 >= 8 then 2 else 0), 0, 0,
                                      OUTPUT g#log ).
end.
else do:
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + " " +
      string( session:temp-directory) +  "$" + string( g#report-num )
              ) .
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl" + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txl" + " " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl"
              ) .
end.
   End.
else  DO:
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 4 >= 8 then 2 else 0), 0, 0,
                                      OUTPUT g#log ).
end.
else do:
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + " " +
      string( session:temp-directory) +  "$" + string( g#report-num )
              ) .
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl" + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txl" + " " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl"
              ) .
end.
   End.
procedure b-code-lst :
  do
  on error undo, return error return-value
  :
      assign
        is-new = yes
        list-b-code = ""
      .
      for each prod-bc no-lock where prod-bc.b-code = b-code :
        if is-new then do:
          assign is-new = no .
          if prod-bc.bc-on then assign list-b-code = "* " + prod-bc.b-str .
          else assign list-b-code = prod-bc.b-str .
        end.
        else do:
          if prod-bc.bc-on then assign list-b-code = list-b-code + ", " +  "* " + prod-bc.b-str .
          else assign list-b-code = list-b-code + ", " + prod-bc.b-str .
        end.
        if length(list-b-code) > 30000 then do:
          message vss-workfile vss-revision vss-description skip "Слишком много бар-кодов производителя! Список будет выводиться неполностью." skip  "Код товара " goods.gds-code " Артикул товара " goods.artic skip
          view-as alert-box error .
          leave.
        end.
      end.
  end.
end procedure.
procedure sub-b-code-lst :
  do
  on error undo, return error return-value
  :
    define input-output  parameter str1 as character no-undo .
    define output parameter        str2 as character no-undo .
    assign  str2 = "" .
    if length(str1) > 27 then do:
      define variable nn as integer initial 0  no-undo .
      define variable ii as integer initial 1  no-undo .
      repeat :
        ii = index(str1,',',ii) .
        if ii > 27 or ii < 1 then leave.
        assign
          nn = ii
          ii = ii + 1
        .
      end.
      str2 = substr ( str1, nn + 1) .
      str1 = substr ( str1, 1, nn - 1) .
    end.
  end.
end procedure.
Procedure fill-line :
  define input parameter p-Counter     as integer               no-undo.
  define input parameter p-cTb-code    as character format "X(10)" no-undo.
  define input parameter p-artic       like goods.artic         no-undo.
  define input parameter p-gds-name    like ub.goods.gds-name   no-undo.
  define input parameter p-qnty        as decimal               no-undo.
  define input parameter p-unit-base   like ub.goods.unit-base  no-undo.
  define input parameter p-last-date   like ub.parts.last-date  no-undo.
  define input parameter p-PS          like ub.parts.PS         no-undo.
  define input parameter p-price-rubl  like ub.parts.price-rubl no-undo.
  define input parameter p-list-b-code as character             no-undo.
  define input parameter p-print_zak   as logical               no-undo.
  run specifxl-write-line-data in this-procedure (
            input p-Counter
          , input p-cTb-code
          , input p-artic
          , input p-gds-name
          , input p-qnty
          , input p-unit-base
          , input p-last-date
          , input p-PS
          , input p-price-rubl
          , input p-list-b-code
          , input p-print_zak
  ).
end.
