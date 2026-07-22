using ibs.th.gbl.sys.objsrv.
using ibs.th.str.marking.sts.*.
block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: bea89a1a8b39, 2756, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Сб фев 20 15:59:21 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: akt-utd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/akt-utd.p $":U .
define variable vss-description as character no-undo init "Акт-приема передачи товара".
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
define input parameter parparentproc    as widget-handle  no-undo.
define input parameter p-db-num       as integer      no-undo .
define input parameter p-doc-id       as integer      no-undo .
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define variable mDebug as logical no-undo.
mDebug = session:debug-alert.
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable mDiadocApi as component-handle no-undo.
define variable mDiadocConnection as component-handle no-undo.
define variable m-sys-key as character no-undo.
define variable marpar-type as character no-undo.
define variable mPublishHand as handle  no-undo.
define variable mFlaftest as logical no-undo.
   create "Diadoc.DiadocClient":U mDiadocApi no-error.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable mySeqUtd as int64 no-undo init ?.
if mDiadocApi eq ?
then do:
   if  log-manager:logfile-name ne ?
   then
      log-manager:write-message("Нет библиотеки Diadoc или не удалось создать объект Diadoc.DiadocClient", "EDOError").
end.
else do:
   if  log-manager:logfile-name ne ?
   then
      log-manager:write-message(substitute ("Версия библиотеки Diadoc &1" , mDiadocApi:GetFullVersion()) , "EDOError").
end.
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info5 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info5, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info5, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info5 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info5, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info5 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info5, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info5, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info5, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info5, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info5, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info5 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info5 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info5, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info5 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info5 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
def var vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function getattrUtdex returns char
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-attr  then iExValue    else  utd-attr.attr-value.
end.
function getattrUtd returns char
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character ):
  return getattrUtdex(idb-num,idoc-id,iattrcode,?).
end.
function setattrUtd returns logical
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-attr
   then do:
      create utd-attr.
      assign
         utd-attr.db-num    = idb-num
         utd-attr.doc-id    = idoc-id
         utd-attr.attr-code = iattrcode
         utd-attr.attr-value = iattrval
      .
   end.
   else do:
      if utd-attr.attr-value ne iattrval
      then do:
         find current utd-attr exclusive-lock no-error.
         if available utd-attr
         then
            utd-attr.attr-value = iattrval.
      end.
   end.
   release utd-attr.
end.
function GetAttrUtdlinesEx returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-lines-attr  then iExValue    else  utd-lines-attr.attr-value.
end.
function GetAttrUtdlines returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character ):
   return GetAttrUtdlinesex (idb-num,idoc-id,ilinenum,iattrcode,?).
end.
function setattrUtdlines returns logical
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-lines-attr.
         assign
            utd-lines-attr.db-num    = idb-num
            utd-lines-attr.doc-id    = idoc-id
            utd-lines-attr.lineNum   = ilineNum
            utd-lines-attr.attr-code = iattrcode
            utd-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-lines-attr.attr-value ne iattrval
      then do:
         find current utd-lines-attr exclusive-lock no-error.
         if available utd-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-lines-attr.
            end.
            else do:
               utd-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-lines-attr.
end.
function GetAttrUtdMarkingLinesEx returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-marking-lines-attr  then iExValue    else  utd-marking-lines-attr.attr-value.
end.
function GetAttrUtdMarkingLines returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character ):
   return GetAttrUtdMarkingLinesEx (idb-num,idoc-id,ilinenum,imark,iattrcode,?).
end.
function setattrUtdMarkingLines returns logical
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-marking-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-marking-lines-attr.
         assign
            utd-marking-lines-attr.db-num     = idb-num
            utd-marking-lines-attr.doc-id     = idoc-id
            utd-marking-lines-attr.lineNum    = ilineNum
            utd-marking-lines-attr.mark       = imark
            utd-marking-lines-attr.attr-code  = iattrcode
            utd-marking-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-marking-lines-attr.attr-value ne iattrval
      then do:
         find current utd-marking-lines-attr exclusive-lock no-error.
         if available utd-marking-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-marking-lines-attr.
            end.
            else do:
               utd-marking-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-marking-lines-attr.
end.
def var vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
define variable mMRCCode  as logical    no-undo.
define variable mTypeMark as character  no-undo.
function IS-NeedMark returns logical
( input ib-code as integer  ,
  input ib-str as character ):
   define buffer buf_prod-bc-attr for ub.prod-bc-attr.
   find first buf_prod-bc-attr where buf_prod-bc-attr.b-code eq ib-code
                                 and buf_prod-bc-attr.b-str  eq ib-str
                                 and buf_prod-bc-attr.attr-code eq 'mark':U
     no-lock no-error.
   return if available buf_prod-bc-attr then logical(buf_prod-bc-attr.attr-value) else no .
end.
function repTegforDm return char
(iDM as char ):
    define variable vTeglist as character no-undo init "01,02,11,13,17,21,8005,37".
    define variable vteg as character no-undo.
    define variable oDM as character no-undo.
    define variable vi as integer no-undo.
    oDM = iDm.
    do vi = 1 to num-entries(vTeglist):
       vTeg = entry(vi,vTeglist).
       oDM = replace(oDM,"(" + vTeg + ")",vTeg).
    end.
    return oDM.
end.
function repSpecSimbforDm return char
(iDM as char ):
    define variable oDM as character no-undo.
  run
    xmlchar-decode(iDM, output oDM).
  return repTegforDm (oDM).
end.
function CheckGtin return logical
(iGtin as char):
   define variable bar_code as character no-undo.
   define variable vGtin as logical no-undo init "yes".
   if length(iGtin) eq 14
   then do:
      bar_code = substr (iGtin, 1, length (iGtin) - 1).
      run str/chk-sum.p
       (input-output bar_code ) no-error .
      if iGtin ne  bar_code
      then
         vGtin = no.
   end.
   else
      vGtin = no.
   return vgtin.
end.
function repSpecSimbforXlm return char
(iDM as char ):
    iDM = replace(iDM,chr(29),"").
    return iDM.
end.
function getGtinByDM return char
(IDM as char):
   define variable VTXT as char no-undo.
   define variable vGtin as char no-undo.
   vTXt = IdM.
   vGtin = IDM.
   if    length(vtxt) > 14
   then do:
      if   vtxt begins "(01)"
             or vtxt begins "(02)"
      then
         vGtin = substring(vtxt,5,14).
      else if   (vtxt begins "01"
             or vtxt begins "02" )
             and (   (    substring(iDm,17,2) eq "21"
                      and length(vtxt) >= 21)
                  or substring(iDm,17,2) eq "37"
                  or substring(iDm,17,4) eq "(37)" )
      then do:
         vGtin = substring(vtxt,3,14).
         if not checkGtin(vGtin)
         then
            vGtin = substring(vtxt,1,14).
      end.
      else if     length(vtxt) eq 14 + 7 + 4 + 4
          or length(vtxt) eq 14 + 7 + 4
          or length(vtxt) eq 14 + 7
      then
         vGtin = substring(vtxt,1,14).
   end.
   if not checkGtin(vGtin)
   then
      vGtin = "".
   return vgtin.
end.
function getGdsCodeByGtin return int
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin  and prod-bc.bc-on no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.gds-code else ?.
end.
function getQntyCodeByGtin return decimal
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.cli-base-rate else ?.
end.
function getGdsCodeByDM return int
(iDm as char):
   define variable vGtin as char no-undo.
   define buffer prod-bc for ub.prod-bc.
   vGtin  = getGtinByDM (IDM ).
   return getGdsCodeByGtin (vGtin).
end.
function ChekTypeMarkByGds return logical
(iGds-code as integer ):
   define buffer goods-attr for ub.goods-attr.
   find first goods-attr where goods-attr.gds-code   = iGds-code
                           and goods-attr.attr-code  = 'mark-type':U
   no-lock no-error.
   if available goods-attr
   then do:
      mTypeMark = goods-attr.attr-value.
      return goods-attr.attr-value = objsrv:Env:Marking:Types:tabak:NameProp
        .
   end.
   else
      return no.
end.
function ChekTypeMarkByDm return logical
(iDM as char ):
   return ChekTypeMarkByGds(getGdsCodeByDM(idm)).
end.
function ChekTypeMarkByGtin return logical
(iGtin as char ):
   return ChekTypeMarkByGds(getGdsCodeByGtin(iGtin)).
end.
function GetNextElement return character
  (input iAllTeg        as logical
  ,output oteg          as character
  ,output otegval       as character
  ,input-output pstr    as character
   ):
     define variable vlistElem   as character no-undo init "00,01,02,21,17,11,13,(01),(02),(21),(17),(11),(13)".
     define variable vlistleng   as character no-undo init "27,14,14,13,06,06,06,0014,0014,0013,0006,0006,0006".
     define variable vlistElemDop   as character no-undo init ",37,(37),(8005),8005,93,(93)".
     define variable vlistlengDop   as character no-undo init ",08,0008,000006,0006,04,0004".
     define variable vTeg as character no-undo.
     define variable vLength as integer no-undo.
     define variable vi as integer no-undo.
     define variable vj as integer no-undo.
     define buffer code for ub.code.
     find first code where Code.parent eq "MarkType"
                       and Code.CodeValue   eq mTypeMark
                       no-lock no-error.
     if     available code
        and Code.misc1 ne ""
        and Code.misc1 ne ?
     then do:
        integer (Code.misc1) no-error.
        if not error-status:error
        then
          entry (4,vlistleng) = Code.misc1.
     end.
     if iAllTeg
     then
        assign
           vlistElem     = vlistElem    + vlistElemDop
           vlistleng     = vlistleng    + vlistlengDop
        .
     else if mMRCCode
     then
        assign
           vlistElem     = vlistElem    + ",(8005),8005"
           vlistleng     = vlistleng    + ",000006,0006"
        .
    block-elem:
    do vi = 1 to num-entries(vlistElem):
       vTeg = entry(vi,vlistElem).
       if pstr begins vTeg
       then do:
          if    vTeg eq "21"
          then
             vLength = index(pstr,chr(29)) - 2 no-error.
          if vLength  <= 0
          then
             vLength = int(entry(vi,vlistleng)).
          otegval = substring (pstr,length(vteg) + 1, vLength).
          oteg = replace(replace(vteg,")",""),"(","").
          vTeg = vteg + otegval.
          otegval = replace(otegval,chr(29),"").
          oteg = replace(replace(oteg,")",""),"(","").
          pstr = substring (pstr,length(vTeg)+ 1).
          vTeg = replace(vTeg,chr(29),"").
          leave block-elem.
       end.
       else
          vTeg = "".
    end.
    return vteg.
end.
function GetCodeIdent return character
(iDm as char):
   define variable Velement   as character no-undo init "first".
   define variable oCodeIdent as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define variable vGtin as character no-undo.
   define buffer marking for ub.marking.
   for first marking no-lock where
             marking.mark eq iDm
         and marking.unit-ext = "LEVEL2"
   :
     return iDm.
   end.
   vGtin  = getGtinByDM (iDm ).
   ChekTypeMarkByDm(idm).
   if iDm begins 'tech_':U
   then
      oCodeIdent = iDm.
   else if length(iDm) < 21
   then do:
      find first marking where marking.mark eq idm
      no-lock no-error.
      oCodeIdent = if available marking then marking.mark else  ?.
   end.
   else if     length(iDm) eq 29
      and not iDm begins "01"
      and not iDm begins "02"
   then
      oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21 ).
   else  if     length(iDm) >= 24
            and (  iDm begins "01"
                or iDm begins "02")
            and  substring(iDm,17,2) ne "21"
   then do:
      if checkGtin(substring(iDm,1,14)) and ( (length(idm) eq 25 and substring(iDm,22,1) eq "A")
                                                or (length(idm) eq 29 and substring(iDm,22,1) eq "A"))
      then
         oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21).
      else
         oCodeIdent = iDM.
   end.
   else  if     (   length(iDm) eq 25
                 or length(iDm) eq 21)
            and (not iDm begins "01"
            and  not iDm begins "02")
   then
      oCodeIdent = substring(iDm,1,21).
   else if vGtin = substring(iDm,1,14) and checkGtin(substring(iDm,1,14)) and ( length(idm) eq 21 or (length(idm) eq 25 and substring(iDm,22,1) eq "A"))
   then
      oCodeIdent = substring(iDm,1,21).
   else do while Velement ne "" and idm ne "":
      Velement = GetNextElement(no,output vteg, output vtegval, input-output idm).
      oCodeIdent = oCodeIdent + Velement.
   end.
   return oCodeIdent.
end.
function GetTegCod return character
(icodeIdent as char, iTeg as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo init ?.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if     ((length(icodeIdent) eq 21
      and not icodeIdent begins "01"
      and not icodeIdent begins "02")
      or
          ( length(icodeIdent) eq 25
            and not icodeIdent begins "01"
            and not icodeIdent begins "02"))
   then do:
      if iTeg eq "01" or iTeg eq "02"
      then
         oTeg = substring(icodeIdent,1,21).
      else  if  iTeg eq "21"
      then
         oTeg = substring(icodeIdent,15,7).
   end.
   else do:
      ChekTypeMarkByDm(icodeIdent).
      block-teg:
         do while Velement ne "" and icodeIdent ne "":
         Velement = GetNextElement(yes,output vteg, output vtegval, input-output icodeIdent).
         if    Velement begins iTeg
            or Velement begins "(" + iTeg + ")"
         then do:
            oTeg = vtegval.
            leave block-teg.
         end.
      end.
   end.
   return oTeg.
end.
function isOAD return logical
(icodeIdent as character):
   return length(icodeIdent) > 18 and GetTegCod(icodeIdent,"37") ne ? and GetTegCod(icodeIdent,"02") ne ?.
end.
function isMark return logical
(icodeIdent as character):
   define buffer buf_marking for ub.marking.
   return can-find(first buf_marking where buf_marking.mark begins icodeIdent) or
          (length(icodeIdent) > 20 and not isOAD(icodeIdent)).
end.
function addBracketForCode return character
(icodeIdent as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define buffer marking for ub.marking.
   find first marking no-lock where
              marking.mark begins icodeIdent no-error.
   if    not ChekTypeMarkByDm(icodeIdent)
      or length(icodeIdent) le 24
      or (avail marking and marking.unit-ext = "LEVEL2")
   then
      oTeg = icodeIdent.
   else do:
      if (  icodeIdent begins "01"
         or icodeIdent begins "02"
         ) and CheckGtin(substring (icodeIdent,3,14))
         and substring (icodeIdent,17,2) eq "21"
      then do:
         mMRCCode = yes.
         ChekTypeMarkByDm(icodeIdent).
         block-teg:
         do while Velement ne "" and icodeIdent ne "":
            Velement = GetNextElement(no,output vteg, output vtegval, input-output icodeIdent).
            if vteg ne ""
            then
               oTeg = oTeg + "(" + vteg + ")" + vtegval .
         end.
         mMRCCode = no.
      end.
      else do:
         oTeg = icodeIdent.
      end.
   end.
   return oTeg.
end.
function getlevelByCodId return int
(iCode as char):
   define variable vLength as int no-undo.
   define variable vLevel  as int no-undo.
   if not ChekTypeMarkByDM (icode) then return ?.
   vLength = length(iCode).
   if    vLength eq 18
      or vLength eq 20
   then
      Vlevel = 4.
   else if vLength eq 21
   then
      Vlevel = 1.
   else if vLength eq 25
   then do:
      if  iCode begins "01"
      then
         Vlevel = 3.
      else
         Vlevel = 1.
   end.
   else if     vLength >= 26
           and vLength <= 46
   then do:
      if    substring(iCode,17,2) eq "11"
         or substring(iCode,17,2) eq "13"
         or (    substring(iCode,17,2) eq "21"
             and vLength >= 33
             and substring(iCode,26,4) ne "8005")
      then
         Vlevel = 4.
      else if    vLength eq 31
              or vLength eq 38
              or vLength eq 39
              or vLength eq 45
      then
         Vlevel = 1.
      else if    vLength eq 35
              or vLength eq 43
      then
         Vlevel = 3.
      else
         Vlevel = ?.
   end.
   else
      Vlevel = ?.
   return Vlevel.
end.
function getLevelMotpBycodid return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 6
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByLevelMotp return character
(iUnit as char):
   define variable vLevel as integer no-undo.
   define variable vListMOTP    as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   define variable vListutd as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = lookup(iUnit,vListMOTP).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vListutd).
end.
function getLevelMotpByDM return character
(iDm as char):
   return getLevelMotpByCodId(GetCodeIdent(iDm)).
end.
function getLevelUTDByCodId return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByDM return character
(iDm as char):
   return getLevelUTDByCodId(GetCodeIdent(iDm)).
end.
define variable mNotMarkQnty as logical no-undo.
function getQntyUTDByCodId return decimal
(iDM as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "1,5,10,500".
   define variable vGtin as character no-undo.
   define variable vqnty as decimal no-undo init ?.
   vqnty = dec(GetTegCod(iDM,"37")) no-error.
   if vqnty eq ?
   then do:
      if not mNotMarkQnty
      then do:
         define buffer marking for ub.marking.
         define variable vCodident as character no-undo.
         vCodident = GetCodeIdent(idm).
         find first marking where marking.mark begins vCodident no-lock no-error.
         if     available marking
            and marking.box-qnty ne ?
         then
            return marking.box-qnty.
      end.
      vGtin = getGtinByDm(iDM).
      if ChekTypeMarkByGtin (vGtin)
      then do:
         vLevel = getlevelByCodId(iDM).
         if     vLevel >= 1
            and vLevel <= 4
         then
            vqnty = int(entry(vlevel,vList)).
      end.
      else
         vqnty = getQntyCodeByGtin(vgtin).
   end.
   return vqnty.
end.
function getQntyUTDByDM return decimal
(iDm as char):
   define variable vDM as character no-undo.
   if     length (iDm) ne 25
      and length (iDm) ne 29
      and substring (iDm,length (iDm) - 6 + 1, 2 ) eq "93"
   then
      vDM = substring (iDm,1,length (iDm) - 6 ).
   else
      vDM = substring (iDm,1,length (iDm) - 4 ).
   return getQntyUTDByCodId(vDM).
end.
function getMRC4 return decimal
(iMRC as char):
   define variable oMrc     as decimal no-undo init ?.
   define variable vAlphabet as character no-undo init "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!~"%&'*+-./_,:;=<>?".
   define variable vi       as integer no-undo.
   define variable vfound   as integer no-undo.
   define variable vposStart   as integer no-undo.
   do:
   OMRc = 0.
   do vi = 1 to 4:
      define variable vsimb as character no-undo.
      vsimb = substring(iMRC,vi,1).
      vposStart = if keycode("Z") < keycode(vsimb) then 27 else 1.
      vfound = index(vAlphabet,vsimb,vposStart) - 1.
      if vfound > 0
      then
         OMRc = OMRc + exp (80,(4 - vi) ) * vfound  .
      end.
      OMRc = OMRc / 100.
   end.
   return OMRc.
end.
function getMRCByDM return decimal
(iDm as char):
   define variable vMRC     as character no-undo.
   define variable oMrc     as decimal no-undo init ?.
   define variable Velement as character no-undo init "empty".
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if    length(idm) eq 14 + 7 + 4 + 4
      or length(idm) eq 14 + 7 + 4
   then do:
      vMRC = substring(idm,22,4).
      omrc = getMRC4(vMRC).
   end.
   else do:
       ChekTypeMarkByDm(iDm).
       block-mrc:
       do while Velement ne "" and idm ne "":
          Velement = GetNextElement(yes,output vteg, output vtegval, input-output idm).
          if Velement begins "8005"
          then do:
             vMRC = substring(Velement,5,6).
             leave block-mrc.
          end.
          else if Velement begins "(8005)"
          then do:
             vMRC = substring(Velement,7,6).
             leave block-mrc.
          end.
       end.
       if vMRC ne ""
       then
          OMRc = dec(vmrc) / 100 no-error.
   end.
   return OMRc.
end.
function MoveDate return Date
(idate as date,
 iMonth as int64):
   define variable vMonth   as int64 no-undo.
   define variable vYear    as int64 no-undo.
   define variable vDateNew as date  no-undo.
    define variable vDay     as int64 no-undo.
    vMonth = month(iDate) + iMonth.
    vYear =  year(iDate).
    if vMonth <= 0
    then assign
       vMonth = vMonth + 12
        vYear  = vYear - 1
    .
    else if vMonth > 12
    then assign
       vMonth = vMonth - 12
        vYear  = vYear + 1
    .
    vDateNew = date(vMonth,day(iDate),vYear) no-error.
    do while error-status:error eq yes:
       VDay = vDay + 1.
       vDateNew = date(vMonth,day(iDate) - vDay,vYear) no-error.
    end.
    if VDay > 0
    then
       vDateNew + 1.
    return vDateNew.
end.
procedure checkEMRC:
define input  parameter iDm as character no-undo.
define output parameter vok as logical   no-undo init yes.
   define variable v-value-emrc as character no-undo.
   define variable v-type-emrc  as character no-undo.
   define variable vDateIso     as character no-undo.
   define variable vMRC         as decimal no-undo.
   define variable vqnty        as decimal no-undo.
   define variable vPrice       as decimal no-undo.
   define variable vparent      as character no-undo.
   define variable vgds-code    as integer no-undo.
   define buffer code for ub.code.
   vMRC = getMRCByDM(iDm).
   if vMRC > 0
   then do:
      vgds-code = getGdsCodeByDM(iDm).
      vqnty     = getQntyUTDByDM(iDm).
            if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
         (
          input   vgds-code
         ,input   'emrc-type':U
         ,output   v-value-emrc
         ,output   v-type-emrc
       ) no-error.
       if     v-value-emrc ne ""
          and v-value-emrc ne ?
       then do:
          vDateIso = iso-date(today).
          vPrice = vMRC / vqnty.
          vparent ="emc" + chr(4) + v-value-emrc.
          find last code where Code.parent      eq vparent
                           and Code.code        le vDateIso
                           and code.status_  eq 0
          no-lock no-error.
          if not available code or ( vPrice  >= dec(Code.CodeValue))
          then
             vOk = true .
          else do:
              define variable vText      as character no-undo.
              define variable vDate      as date no-undo.
              define variable vDateLast  as character no-undo.
              define variable vDateFirst as character no-undo.
              define variable vDate3     as date no-undo.
              vdate = date(code.misc1).
              vDateLast = code.misc1.
              vDate3 = MoveDate(today, - 3 ).
              vText =  substitute ("ТОВАР ИМЕЕТ ОГРАНИЧЕННЫЙ СРОК РЕАЛИЗАЦИИ. Если товар произведен после &2, то его приемка и продажа запрещена.",
                                   string(vDate3  , "99/99/9999"),
                                   string(vDate   , "99/99/9999")
                                   ).
              vdateIso = iso-date(vdate3).
              find last code  where Code.parent      eq vparent
                                and Code.code        le vDateIso
                                and code.status_  eq 0 no-lock no-error.
              if available code
              then
                 vDateIso = code.code.
              vDateFirst = vDateIso.
              vDateLast = iso-date(vdate).
              define variable vGood as logical no-undo.
              define variable vDateSale as date no-undo.
              define buffer bcode for code.
              for last code where Code.parent   eq vparent
                              and code.status_  eq 0
                              and code.code     < vDateLast
                              and code.code     >= vDateFirst
              no-lock:
                 find first bcode where bCode.parent   eq vparent
                                    and bcode.status_  eq 0
                                    and bcode.code     > code.code no-lock no-error.
                 if available bcode
                 then do:
                    if vPrice < dec(Code.CodeValue)
                    then
                       vText = vtext + substitute ("&1Если товар произведен с &2 до &3, ТО ЕГО ПРИЕМКА И ПРОДАЖА ЗАПРЕЩЕНА",
                                                  chr(10),
                                                  string(    date( code.misc1)       ,"99/99/9999"),
                                                  string(    date(bcode.misc1)       ,"99/99/9999")
                                                  ).
                    else do:
                       vGood = yes.
                       vDateSale = MoveDate(date(bcode.misc1), 3) - 1.
                       vText = vtext + substitute ("&1Если товар произведен до &3, то продажа разрешена до &4.~Осталось &5 дней.",
                                                  chr(10),
                                                  string(    date( code.misc1)         ,"99/99/9999"),
                                                  string(    date(bcode.misc1)         ,"99/99/9999"),
                                                  string(         vDateSale            ,"99/99/9999"),
                                                  string(vDateSale - today)
                                                  ).
                    end.
                 end.
              end.
              if vgood
              then do:
                 define variable choice as integer no-undo .
                 run gbl/d-askw.w (input "Уточнение"
                        ,input  vText
                        ,input "|"
                        ,input "Принять|Вернуть"
                        ,input "Принять данный товар|Вернуть товар постащику"
                        ,input 1
                        ,input 2
                        ,output choice) no-error.
                 vok = choice eq 1.
              end.
              else
                 vok =false.
          end.
       end.
   end.
end.
function addGs2Mark return character
(iMark as char):
   define variable vDM   as character no-undo.
   define variable vIdx  as integer   no-undo.
   if index(iMark,chr(29),1) > 0
   then return iMark.
   if substring(iMark,26,4) = "8005" then
   do:
     vIdx = index(iMark,"93",26 + 4 + 5).
     if vIdx > 1 then do:
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,25),
                        substring(iMark,26,vIdx - 25 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       vIdx = index(vDm,"240",vIdx + 4).
       if vIdx > 0 then
       do:
         vDM = substitute("&1&3&2",
                          substring(vDm,1,vIdx - 1),
                          substring(vDm,vIdx),
                          chr(29)) no-error.
       end.
     end.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,25),
                        substring(iMark,26),
                        chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "91" then
   do:
     vIdx = index(iMark,"92",32).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,31),
                        substring(iMark,32,vIdx - 31 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,31),
                        substring(iMark,32),
                        chr(29)) no-error.
   end.
   else if substring(iMark,39,2) = "91" then
   do:
     vIdx = index(iMark,"92",38).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,38),
                        substring(iMark,39,vIdx - 38 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,38),
                        substring(iMark,39),
                        chr(29)) no-error.
   end.
   else if substring(iMark,25,2) = "93" then
   do:
     vIdx = index(iMark,"92",25).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vIdx = index(iMark,"3103",25).
       if vIdx > 0 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       else
         vDM = substitute("&1&3&2",
                          substring(iMark,1,24),
                          substring(iMark,25),
                          chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "93" then
   do:
     vDM = substitute("&1&3&2",
           substring(iMark,1,31),
           substring(iMark,32),
           chr(29)) no-error.
   end.
   return if vDM <> "" then vDm else iMark.
end.
def var vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function AddUtdErrForTab returns logical
(idb-num         as integer ,
 idoc-id         as integer ,
 iTab            as character,
 iObj            as handle ,
 iCheckType      as character,
 iCodeErr        as character,
 iCheckObj       as character ):
   define buffer utd-err for utd-err.
   define buffer utd for utd.
   find first utd where utd.db-num     eq idb-num
                    and utd.doc-id     eq idoc-id
                    and utd.Direction  eq 'Outbound'
   no-lock no-error.
   if available utd
   then
      return no.
   define variable vRecKey as character no-undo.
         run gen-key-rec (input iTab,
                          input  iObj,
                          output vRecKey).
   find first utd-err where utd-err.db-num     eq idb-num
                        and utd-err.doc-id     eq idoc-id
                        and utd-err.CheckType  eq iCheckType
                        and utd-err.CodeErr    eq iCodeErr
                        and utd-err.CheckObj   eq iCheckObj
   exclusive-lock no-error.
   if not available utd-err
   then do:
      create utd-err.
      assign
         utd-err.db-num         = idb-num
         utd-err.doc-id         = idoc-id
         utd-err.CheckType      = iCheckType
         utd-err.CodeErr        = iCodeErr
         utd-err.CheckObj       = if iCheckObj eq ? then "?" else iCheckObj
         utd-err.reckey         = vRecKey
         utd-err.qnty           = 1
      .
   end.
   else
      utd-err.qnty = utd-err.qnty + 1.
   return utd-err.qnty eq 1.
end.
function AddUtdErr returns logical
(idb-num         as integer ,
 idoc-id         as integer ,
 iObj            as handle ,
 iCheckType      as character,
 iCodeErr        as character,
 iCheckObj       as character ):
   AddUtdErrForTab
      (idb-num,
       idoc-id,
       iObj:table,
       iObj,
       iCheckType,
       iCodeErr,
       iCheckObj).
end.
function ClearUtdErrTypeCode returns logical
(idb-num         as integer,
 idoc-id         as integer ,
 iCheckType      as character,
 iCodeErr        as character
 ):
   define buffer utd-err for utd-err.
   if    iCheckType eq "*"
      or iCheckType eq ?
   then do:
      if     iCodeErr ne ?
         and iCodeErr ne "*"
      then
         message "Задан код ошибки " iCodeErr " для удаления, но не задан тип"
         view-as alert-box.
      else
      for each utd-err where utd-err.db-num  eq idb-num
                         and utd-err.doc-id  eq idoc-id
      exclusive-lock:
         delete utd-err.
      end.
   end.
   else do:
      if    iCodeErr eq ?
         or iCodeErr eq "*"
      then do:
         for each utd-err where utd-err.db-num     eq idb-num
                            and utd-err.doc-id     eq idoc-id
                            and utd-err.CheckType  eq iCheckType
         exclusive-lock:
            delete utd-err.
         end.
      end.
      else do:
         for each utd-err where utd-err.db-num     eq idb-num
                            and utd-err.doc-id     eq idoc-id
                            and utd-err.CheckType  eq iCheckType
                            and ub.utd-err.CodeErr eq iCodeErr
         exclusive-lock:
            delete utd-err.
         end.
      end.
   end.
end.
function ClearUtdErr returns logical
(idb-num         as integer,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   ClearUtdErrTypeCode(idb-num,idoc-id,iCheckType,?).
end.
function GetMesError returns character
(itxt as character,
 iobj as character ):
 define variable vi as integer no-undo.
 do vi = num-entries(iobj ,chr(4) ) to 1 by -1 :
    itxt = replace(itxt,"&" + string(vi),entry(vi,iobj,chr(4))).
 end.
 return itxt.
end.
function GetTextErrorType returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character,
 iType      as character  ):
   define buffer code    for code.
   define variable vError as character no-undo.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if available code
   then do:
      define variable vType as integer no-undo.
      if code.misc3 eq "error"
      then
         vType = 0.
      else if code.misc3 eq "warning"
      then
         vType = 1.
      else if code.misc3 eq "Hiden"
      then
         vType = 2.
      else
         vtype = int(code.misc3) no-error.
      case itype:
         when "error"
         then do:
            if vtype eq 0
            then
               vError = GetMesError(Code.CodeValue,iChechObj).
         end.
         when "warning"
         then do:
            if vtype <= 1
            then
               vError = GetMesError(Code.CodeValue,iChechObj).
         end.
         otherwise do:
            vError = GetMesError(Code.CodeValue,iChechObj).
         end.
      end.
   end.
   else
      vError =  iCodeErr + ":" + replace (iChechObj,chr(4),"|").
   return vError.
end.
function GetTypeError returns integer
(iCheckType as character,
 iCodeErr   as character):
   define buffer code    for code.
   define variable vType as integer no-undo.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if     not available code
      and code.misc3 eq "error"
   then
      vType = 0.
   else if code.misc3 eq "warning"
   then
      vType = 1.
   else if code.misc3 eq "Hiden"
   then
      vType = 2.
   else
      vtype = int(code.misc3) no-error.
   return vtype.
end.
function GetTextError returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character ):
   return GetTextErrortype(iCheckType,iCodeErr,iChechObj,"warning").
end.
function GetErrForUtdStr returns character
(idb-num     as integer ,
 idoc-id     as integer ,
 iCheckType  as character
 ):
   define buffer utd-err for utd-err.
   define buffer code    for code.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable vErrorOne as longchar  no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ""
         and vErrorOne ne ?
      then
         vError = vError + ", " + vErrorOne.
      vHQry:get-next().
   end.
   oError = substring(vError,3,4002).
   return oError.
end.
function GetErrJsonForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   define variable vi as integer no-undo.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      define variable vErrorOne as character no-undo.
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vi = vi + 1.
         vError = vError + ',"Ошибка_' + string(vi) +  '":~{"КодОш":"'    + utd-err.CheckType + "_" + utd-err.CodeErr
                         + '","ОбъектОш":"' + replace(utd-err.CheckObj,chr(4),"|")
                         + '","ТекстОш":"' + vErrorOne + '"}'.
      end.
      vHQry:get-next().
   end.
   for first utd where utd.db-num eq idb-num
                   and utd.doc-id eq idoc-id
                   and utd.sts    eq ObjSrv:Env:Utd:Sts:th:DeliveryCodeMismatch:KeyIntDB
   no-lock,
      each utd-marking-lines where utd-marking-lines.db-num eq idb-num
                               and utd-marking-lines.doc-id eq idoc-id
                               and utd-marking-lines.doc-level eq 1
   no-lock,
      first marking where marking.mark eq utd-marking-lines.mark
                      and marking.sts  eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
   no-lock:
      vErrorOne = GetTextErrortype("CheckShip","NotMark",marking.mark,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vError = vError + ',"Ошибка_' + string(vi) +  '":~{"КодОш":"'    + "CheckShip" + "_" + "NotMark"
                         + '","ОбъектОш":"' + marking.mark
                         + '","ТекстОш":"' + vErrorOne + '"}'.
      end.
   end.
   if vError ne ""
   then
      oError = '"Ошибки":~{' + substring(vError,2,31002) + "}".
   return oError.
end.
function GetErrJsonForUtdReturn returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable oError as character no-undo.
   define variable vi as integer no-undo.
   create query vHQry.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      define variable vErrorOne as character no-undo.
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vi = vi + 1.
         vError = vError + ',"Возврат_' + string(vi) +  '":~{"КодВозр":"'    + utd-err.CheckType + "_" + utd-err.CodeErr
                         + '","ОбъектВозр":"' + replace(utd-err.CheckObj,chr(4),"|")
                         + '","ТекстВозр":"' + GetTextError(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj) + '"}'.
      end.
      vHQry:get-next().
   end.
   if vError ne ""
   then
      oError = '"Возвраты":~{' + substring(vError,2,31002) + "}".
   return oError.
end.
function GetCodeTextError returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character,
 output oCode as character,
 output ovalue as character ):
   define buffer code    for code.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if     available code
   then do:
      define variable vi as integer no-undo init ?.
      vi = int(Code.misc3) no-error.
      if    code.misc3 ne "error"
         and vi ne 0
      then
         oCode = ?.
      else if     Code.misc1 ne ?
              and Code.misc1 ne ""
      then
         assign
            oCode  = GetMesError(Code.misc1,iChechObj)
            ovalue = GetMesError(Code.misc2,iChechObj)
         .
   end.
   return if oCode eq ""
          then ""
          else (oCode + "_" + ovalue).
end.
define temp-table TT-err no-undo
  field code_ as character
  field text_ as character
index code_ code_.
function GetErrTxtForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   define variable vi as integer no-undo.
   for each tt-err :
      delete tt-err.
   end.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   define variable vcode as character no-undo.
   define variable vvalue as character no-undo.
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      vi = vi + 1.
      GetCodeTextError (utd-err.CheckType, utd-err.CodeErr, utd-err.CheckObj, output vcode, output vvalue).
      if vcode ne ?
      then do:
         find first tt-err where tt-err.code eq vcode
         no-error.
         if not available tt-err
         then do:
            create tt-err.
            assign
               tt-err.code_ = vcode
               tt-err.text_ = vvalue
            .
         end.
         else
            tt-err.text_ = tt-err.text_ + "||" + vvalue.
      end.
      vHQry:get-next().
   end.
  find first utd where utd.db-num eq idb-num
                      and utd.doc-id eq idoc-id
      no-lock.
   define buffer cancel_utd-lines for utd-lines.
   for each cancel_utd-lines where cancel_utd-lines.db-num eq idb-num
                               and cancel_utd-lines.doc-id eq idoc-id
   no-lock:
      if logical(getattrutdlinesex  (idb-num,idoc-id,cancel_utd-lines.LineNum,"MarkUtdLine"        ,"no"))
      then do:
         for   each utd-marking-lines where utd-marking-lines.db-num eq idb-num
                                     and utd-marking-lines.doc-id eq idoc-id
                                     and utd-marking-lines.LineNum eq cancel_utd-lines.LineNum
         no-lock,
            first marking where marking.mark eq utd-marking-lines.mark
                            and marking.sts  eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
         no-lock:
            GetCodeTextError ("CheckShip", "MARKDECLINED", utd-marking-lines.mark + chr(4) + string(utd-marking-lines.LineNum), output vcode, output vvalue).
            find first tt-err where tt-err.code eq vcode
            no-error.
            if not available tt-err
            then do:
               create tt-err.
               assign
                  tt-err.code_ = vcode
                  tt-err.text_ = vvalue
               .
            end.
            else
               tt-err.text_ = tt-err.text_ + "||" + vvalue.
         end.
      end.
      else do:
         define variable vqnty as decimal no-undo.
         vqnty = decimal(GetAttrUtdlines(cancel_utd-lines.db-num,cancel_utd-lines.doc-id,cancel_utd-lines.linenum,"QuantityBarCode")).
         if vqnty eq ? then vqnty = 0.
         if vqnty ne cancel_utd-lines.Quantity
         then do:
            GetCodeTextError ("CheckShip", "NotAcceptQuantity", string(cancel_utd-lines.LineNum) + chr(4) + string(cancel_utd-lines.Quantity - vqnty), output vcode, output vvalue).
            find first tt-err where tt-err.code eq vcode
            no-error.
            if not available tt-err
            then do:
               create tt-err.
               assign
                  tt-err.code_ = vcode
                  tt-err.text_ = vvalue
               .
            end.
            else
               tt-err.text_ = tt-err.text_ + "||" + vvalue.
         end.
      end.
   end.
   for each tt-err:
      oError = oError + substitute("&1|&2|",tt-err.code_ , tt-err.text_ ) + chr(13) + chr(10) .
   end.
   return oError.
end.
define variable mFormatErr as character no-undo init "text".
function GetErrForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iType           as character
 ):
   if mFormatErr eq "text"
   then
      return GetErrTxtForUtd(idb-num,idoc-id,iType).
   else do:
      if itype eq "return"
      then return GetErrJsonForUtdReturn (idb-num,idoc-id,iType).
      else return GetErrJsonForUtd(idb-num,idoc-id,iType).
   end.
end.
function GetErrComText returns longchar
(icomment as character,
 itext    as longchar ):
    define variable vText as longchar no-undo.
   if mFormatErr eq "text"
   then do:
      if icomment ne ""
      then
         icomment = substitute("comment:|&1|",icomment).
      vText = icomment + itext.
   end.
   else do:
      icomment = if icomment begins  '"'
                 then icomment
                 else  if icomment eq "" then "" else ( '"Коментрии":~{"Коментарий":"' + icomment  + '"}') .
      vText = icomment + "," + itext.
      vText = "~{" + trim(vText,",") + "~}".
   end.
   return vText.
end.
function CheckTypeForMarkLineType returns logical
(iObj            as handle,
 iCheckType      as character,
 iCodeErr        as character ,
 iTypeErr        as character ):
   define variable vRecKey-markLine as character no-undo.
   define variable vGoodMark        as logical no-undo.
   define variable vdb-num          as integer no-undo.
   define variable vdoc-id          as integer no-undo.
   define variable vlinenum         as integer no-undo.
   define variable vErrorOne as character no-undo.
   define buffer buf_utd-err for utd-err.
   run gen-key-rec (input "utd-marking-lines",
                    input  iObj,
                    output vRecKey-markLine).
   vGoodMark = yes.
   vdb-num = iObj::db-num.
   vdoc-id = iObj::doc-id.
   vlinenum = iObj::linenum.
   block-mark-err:
   for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                            and buf_utd-err.db-num = vdb-num
                            and buf_utd-err.reckey = vRecKey-markLine
                            and if iCheckType  eq "*" or iCheckType eq ? then yes else buf_utd-err.CheckType = iCheckType
                            and if iCodeErr    eq "*" or iCodeErr   eq ? then yes else buf_utd-err.CodeErr   = iCodeErr
   no-lock:
      vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,iTypeErr).
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vGoodMark = no.
         leave block-mark-err.
      end.
   end.
   return not vGoodMark.
end.
function CheckErrForMarkLineType returns logical
(iObj            as handle,
 iType           as character  ):
   return CheckTypeForMarkLineType (iObj,iType,"*","error").
end.
function CheckErrForMarkLine returns logical
(iObj            as handle):
   return CheckErrForMarkLineType(iObj,"*").
end.
function CheckErrForLineTypeCode returns logical
(iObj                 as handle,
 iCheckType           as character,
 iCodeErr             as character,
 iTypeErr             as character,
 iOneErr              as logical):
   define variable vRecKey-line     as character no-undo.
   define buffer buf_utd-err for utd-err.
   define variable vUtdlineError as logical no-undo.
   define variable vErrorOne as character no-undo.
         run gen-key-rec (input "utd-lines",
                          input  iObj,
                          output vRecKey-line).
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vlinenum as integer no-undo.
      vdb-num = iObj::db-num.
      vdoc-id = iObj::doc-id.
      vlinenum = iObj::linenum.
      block-err:
      for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                               and buf_utd-err.db-num = vdb-num
                               and buf_utd-err.reckey = vRecKey-line
                               and if iCheckType eq "*" or iCheckType eq ? then yes else buf_utd-err.CheckType = iCheckType
                               and if iCodeErr   eq "*" or iCodeErr   eq ? then yes else buf_utd-err.CodeErr   = iCodeErr
      no-lock:
         vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,iTypeErr).
         if     vErrorOne ne ?
            and vErrorOne ne ""
         then do:
            vUtdlineError = yes.
            leave block-err.
         end.
      end.
      if  not vUtdlineError
      then do:
         define variable vGoodMark as logical no-undo.
         vGoodMark = yes.
         block-line-err:
         for each utd-marking-lines where utd-marking-lines.db-num  eq vdb-num
                                      and utd-marking-lines.doc-id  eq vdoc-id
                                      and utd-marking-lines.LineNum eq vLineNum
         no-lock:
            vGoodMark = not CheckTypeForMarkLineType(buffer utd-marking-lines:handle,iCheckType,iCodeErr,iTypeErr).
            if     vGoodMark
               and iOneErr eq no
            then
               leave block-line-err.
            if     iOneErr = yes
               and not vGoodMark
            then
               leave block-line-err.
         end.
         vUtdlineError = not vGoodMark.
      end.
   return vUtdlineError.
end.
function getErrForLineType returns character
(iObj            as handle,
 iType           as character  ):
   define variable vRecKey-line     as character no-undo.
   define buffer buf_utd-err for utd-err.
   define variable vUtdlineError as logical no-undo.
   define variable vErrorOne as character no-undo.
   define variable oError as character no-undo.
         run gen-key-rec (input "utd-lines",
                          input  iObj,
                          output vRecKey-line).
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vlinenum as integer no-undo.
      vdb-num = iObj::db-num.
      vdoc-id = iObj::doc-id.
      vlinenum = iObj::linenum.
      block-err:
      for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                               and buf_utd-err.db-num = vdb-num
                               and buf_utd-err.reckey = vRecKey-line
                               and if iType eq "*" or iType eq ? then yes else buf_utd-err.CheckType = iType
      no-lock:
         vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,"error").
         if     vErrorOne ne ?
            and vErrorOne ne ""
         then do:
            oError = oError + vErrorOne + " ".
         end.
      end.
   return oError.
end.
function CheckErrForLineType returns logical
(iObj            as handle,
 iType           as character  ):
    return CheckErrForLineTypeCode (iObj,itype,"*","error",no).
end.
function CheckErrForLine returns logical
(iObj            as handle):
   return CheckErrForLineType(iobj,"*").
end.
function CheckErrForUtd returns logical
(idb-num         as integer ,
 idoc-id         as integer ):
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock :
      if not CheckErrForLine (buffer ub.utd-lines:handle)
      then
         return no.
   end.
   return yes.
end.
function CheckMarkUtd-28rel return logical
 (input idb-num as integer,
 input idoc-id as integer):
 define buffer utd                   for utd.
 define buffer utd-lines             for utd-lines.
 define buffer utd-marking-lines     for utd-marking-lines.
 define variable v-par-type as character no-undo.
 define variable vgdsNoMark as logical no-undo.
 define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-val  as character no-undo.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if     utd.obj-code ne ?
         and utd.obj-type ne ?
      then do:
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(utd.obj-type, utd.obj-code).
         Block-utd-lines:
         for each utd-lines where utd-lines.db-num eq idb-num
                              and utd-lines.doc-id eq idoc-id
         no-lock:
            if     utd-lines.gds-code ne ?
               and utd-lines.gds-code ne 0
            then do:
                               if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                    ( utd-lines.gds-code,
                      'mark-type':U,
                       output v-par-val,
                       output v-par-type
                    ).
               if     EDOParSec:IsEdo
                  and EDOParSec:GetIsEDOForType(v-par-val)
               then do:
                  find first utd-marking-lines where utd-marking-lines.db-num  eq utd-lines.db-num
                                                 and utd-marking-lines.doc-id  eq utd-lines.doc-id
                                                 and utd-marking-lines.LineNum eq utd-lines.LineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock no-error.
                  if     avail utd-marking-lines
                     and not CheckErrForLine(buffer utd-lines:handle)
                  then
                     leave Block-utd-lines.
               end.
               else
                  vgdsNoMark = yes.
            end.
         end.
         setattrutd (utd.db-num,utd.doc-id,"MarkUtd",if vgdsNoMark then string(available utd-lines) else "yes").
         if vgdsNoMark then return available utd-lines . else return yes .
      end.
   end.
   return yes.
end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-utd-mark no-undo like utd-marking-lines
  field side as character.
def var vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function CheckMarkUtd return logical
 (input idb-num  as integer,
  input idoc-id  as integer):
  define buffer utd-lines             for ub.utd-lines.
  block-line:
  for each utd-lines where utd-lines.db-num eq idb-num
                       and utd-lines.doc-id eq idoc-id
  no-lock:
     if logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","yes"))
     then
        leave block-line.
  end.
  setattrutd (idb-num, idoc-id,"MarkUtd",string(available utd-lines)).
  return available utd-lines.
end.
function CheckNotMarkUtd return logical
 (input idb-num  as integer,
  input idoc-id  as integer):
  define buffer utd-lines             for ub.utd-lines.
  for each utd-lines where utd-lines.db-num eq idb-num
                       and utd-lines.doc-id eq idoc-id
  no-lock:
     if not logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","no"))
     then
        return yes.
  end.
  return no.
end.
function CheckMarkUtdLine return logical
 (input idb-num  as integer,
  input idoc-id  as integer,
  input iLineNum as integer):
 define buffer utd                   for utd.
 define buffer utd-lines             for utd-lines.
 define buffer utd-marking-lines     for utd-marking-lines.
 define variable v-par-type as character no-undo.
 define variable vMarking        as logical no-undo.
 define variable vArtic          as logical no-undo.
 define variable vTransitional   as logical no-undo.
 define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-val  as character no-undo.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if     utd.obj-code ne ?
         and utd.obj-type ne ?
      then do:
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(utd.obj-type, utd.obj-code).
         Block-utd-lines:
         for each utd-lines where utd-lines.db-num   eq idb-num
                              and utd-lines.doc-id   eq idoc-id
                              and utd-lines.LineNum  eq iLineNum
         no-lock:
            if     utd-lines.gds-code ne ?
               and utd-lines.gds-code ne 0
            then do:
                               if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                    ( utd-lines.gds-code,
                      'mark-type':U,
                       output v-par-val,
                       output v-par-type
                    ).
               vMarking = EDOParSec:GetIsEDOForType(v-par-val).
               vArtic = not vMarking and EDOParSec:GetIsArticForType(v-par-val).
               if vMarking
               then do:
                  block-marking:
                  for each   utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock:
                     if isOAD(utd-marking-lines.mark)
                     then do:
                        assign
                           vArtic   = yes
                           vMarking = no
                        .
                        leave block-marking.
                     end.
                  end.
               end.
               if vArtic
               then do:
                  block-artic:
                  for each   utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock:
                     if isMark(utd-marking-lines.mark)
                     then do:
                        assign
                           vArtic   = no
                           vMarking = yes
                        .
                        leave block-artic.
                     end.
                  end.
               end.
               vTransitional = (vMarking or vArtic) and EDOParSec:GetIsTransitionalForType(v-par-val).
               if vTransitional
               then do:
                  find first utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock no-error.
                  if not available utd-marking-lines
                  then assign
                     vMarking = no
                     vArtic   = no
                  .
               end.
            end.
            else
               assign
                  vMarking      = yes
                  vArtic        = no
                  vTransitional = no
               .
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"MarkUtdLine"         ,if vMarking      then "yes" else "").
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"ArticUtdLine"        ,if vArtic        then "yes" else "").
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"TransitionalUtdLine" ,if vTransitional then "yes" else "").
         end.
      end.
   end.
   return vMarking or vArtic.
end.
function getMarkUtdLine return logical
 (input  idb-num  as integer,
  input  idoc-id  as integer,
  input  iLineNum as integer,
  output oMarking        as logical,
  output oArtic          as logical,
  output oTransitional   as logical):
  oMarking = logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"MarkUtdLine"        ,"no")).
  oArtic        = not oMarking
         and logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"ArticUtdLine"       ,"no")).
  oTransitional = (oMarking or oArtic)
         and logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"TransitionalUtdLine","no")).
end.
function CheckMarking return logical
 (input idb-num as integer,
 input idoc-id as integer,
 input iTypeErr as character ):
  define variable vMarkutd as logical no-undo.
  define variable vCrErr   as logical no-undo.
  define buffer utd-lines         for utd-lines.
  define buffer utd-marking-lines for utd-marking-lines.
  define buffer marking           for marking.
  ClearUtdErrTypeCode(idb-num,idoc-id,iTypeErr,"NotMark").
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      if logical (getAttrUtdLinesEx(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","no"))
      then do:
         for each utd-marking-lines
                  where utd-marking-lines.db-num  = utd-lines.db-num
                    and utd-marking-lines.doc-id  = utd-lines.doc-id
                    and utd-marking-lines.LineNum = utd-lines.LineNum
         no-lock:
            if isMark(utd-marking-lines.mark)
            then do:
               find first marking where marking.mark eq utd-marking-lines.mark
               no-lock no-error.
               if not available marking
               then do:
                  AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iTypeErr,"NotMark",string(utd-lines.LineNum)).
                  vCrErr = yes.
                  next block-line.
               end.
            end.
         end.
      end.
   end.
   return vCrErr.
end.
function CheckMarkForType return logical
 (input idb-num   as integer,
  input idoc-id   as integer):
   define variable vMarking        as logical no-undo.
   define variable vArtic          as logical no-undo.
   define variable vTransitional   as logical no-undo.
   define buffer utd-lines         for utd-lines.
   define buffer utd-marking-lines for utd-marking-lines.
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      getMarkUtdLine  (input  utd-lines.db-num , input  utd-lines.doc-id, input  utd-lines.LineNum,
                       output vMarking         , output vArtic          , output vTransitional).
      for each utd-marking-lines
                  where utd-marking-lines.db-num  = utd-lines.db-num
                    and utd-marking-lines.doc-id  = utd-lines.doc-id
                    and utd-marking-lines.LineNum = utd-lines.LineNum
      no-lock:
         if length(utd-marking-lines.mark) < 14
         then do:
            if (vMarking or vArtic) and not vTransitional
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"loadUtd","NotMark",utd-marking-lines.mark).
         end.
         else if not isMark(utd-marking-lines.mark)
         then do:
            if vMarking
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"loadUtd","NotMark",utd-marking-lines.mark).
         end.
         else do:
         end.
      end.
   end.
end.
function WeighedProd return logical
   ( input p-gds-code as integer) :
   define variable v-par-val  as character no-undo.
   define variable v-par-type as character no-undo.
           if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
            ( p-gds-code,
              'weighed-gds':U,
               output v-par-val,
               output v-par-type
            ).
   return logical(v-par-val).
end.
function WghProdVariable return logical
    (input p-obj-type as char,
     input p-obj-code as integer,
     input p-gds-code as integer) :
   define variable v-wgh-val  as character no-undo.
   define variable v-par-val  as character no-undo.
   define variable v-par-type as character no-undo.
   define variable vMarking        as logical no-undo.
   define variable vArtic          as logical no-undo.
   define variable vTransitional   as logical no-undo.
   define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
      if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
        ( p-gds-code,
          'weighed-gds':U,
           output v-wgh-val,
           output v-par-type
        ).
    if logical(v-wgh-val) = yes then do:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
            ( p-gds-code,
              'mark-type':U,
               output v-par-val,
               output v-par-type
            ).
        if v-par-val <> "" then do:
            EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(p-obj-type, p-obj-code).
            assign
               vMarking = EDOParSec:GetIsEDOForType(v-par-val)
               vArtic = not vMarking and EDOParSec:GetIsArticForType(v-par-val)
               .
        end.
   end.
   if v-wgh-val > "" and (vMarking or vArtic)
   then return yes.
   else return no.
end.
function MarkWeight return decimal
   ( input p-mark as character) :
   define buffer  buf_marking-attr for  ub.marking-attr.
   define variable vMarkWeight as decimal no-undo.
   vMarkWeight = 0.
   if p-mark <> "" and p-mark <> ?
   then do:
       find first buf_marking-attr where buf_marking-attr.mark      eq p-mark
                                     and buf_marking-attr.attr-code eq "weight"
          no-lock no-error.
       if not available buf_marking-attr
       then do :
         find first buf_marking-attr where buf_marking-attr.mark  begins p-mark
                                       and buf_marking-attr.attr-code eq "weight"
            no-lock no-error.
       end .
       if avail buf_marking-attr
       then vMarkWeight = dec(buf_marking-attr.attr-value).
   end.
   return vMarkWeight.
end.
function CheckQnty returns logical
(  input idb-num  as integer,
   input idoc-id  as integer,
   input iErrType as character
):
   if iErrType ne "loadUTD"
   then do:
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","MarkNotFormatqnty").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","QntyMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","Qnty").
   end.
   if iErrType ne "CheckQnty"
   then do:
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckQnty","MarkNotFormatqnty").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckQnty","QntyMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckQnty","Qnty").
   end.
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"QntyMark").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"MarkNotFormatqnty").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"Qnty").
   define buffer marking               for marking.
   define buffer utd-lines             for utd-lines.
   define buffer utd-marking-lines     for utd-marking-lines.
   define buffer Buf_utd-marking-lines for utd-marking-lines.
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      define variable Vflagmark as logical no-undo.
      find first buf_utd-marking-lines
                    where buf_utd-marking-lines.db-num   = utd-lines.db-num
                      and buf_utd-marking-lines.doc-id   = utd-lines.doc-id
                      and buf_utd-marking-lines.LineNum  = utd-lines.LineNum
                      and length(buf_utd-marking-lines.mark) > 13
      no-lock no-error.
      if not available buf_utd-marking-lines
      then
         next block-line.
      define variable vqntyMark as integer no-undo.
      define variable vqntyOAD  as integer no-undo.
      vqntyMark = 0.
      vqntyOAD  = 0.
      block-mark:
      for each utd-marking-lines
           where utd-marking-lines.db-num  = utd-lines.db-num
             and utd-marking-lines.doc-id  = utd-lines.doc-id
             and utd-marking-lines.LineNum = utd-lines.LineNum
             and length(utd-marking-lines.mark) > 13
             and utd-marking-lines.doc-level  = 1
      no-lock:
         if isMark(utd-marking-lines.mark)
         then do:
            find first marking where marking.mark eq utd-marking-lines.mark
            no-lock no-error.
            if available marking
            then do:
               if marking.box-qnty ne ?
               then
                  vqntyMark = vqntyMark + marking.box-qnty.
            end.
         end.
         else do:
            find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq utd-marking-lines.db-num
                                                and utd-marking-lines-attr.doc-id    eq utd-marking-lines.doc-id
                                                and utd-marking-lines-attr.LineNum   eq utd-marking-lines.LineNum
                                                and utd-marking-lines-attr.mark      eq utd-marking-lines.mark
                                                and utd-marking-lines-attr.attr-code eq "box-qnty"
            no-lock no-error.
            if available utd-marking-lines-attr
            then
               vqntyOAD = vqntyOAD + dec(utd-marking-lines-attr.attr-value).
         end.
      end.
      if     utd-lines.gds-code   gt 0
         and utd-lines.gds-code   ne ?
         and vqntyMark            ne 0
      then do:
         if utd-lines.Quantity  < vqntyMark
         then
            AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"Qnty",string(utd-lines.LineNum ) + chr(4) + string(utd-lines.Quantity ) + chr(4) + string(vqntyMark)).
         else if utd-lines.Quantity  <> vqntyMark
         then
            AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"QntyMark",string(utd-lines.LineNum ) + chr(4) + string(utd-lines.Quantity ) + chr(4) + string(vqntyMark)).
      end.
      else if     utd-lines.gds-code   gt 0
         and utd-lines.gds-code   ne ?
         and vqntyOAD ne 0
         and utd-lines.Quantity  ne vqntyOAD
      then
         AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"Qnty",string(utd-lines.LineNum ) + chr(4) + string(utd-lines.Quantity ) + chr(4) + string(vqntyOAD)).
   end.
end.
function CheckGds returns logical
(  input idb-num   as integer,
   input idoc-id   as integer,
   input iobj-type as character,
   input iobj-code as integer,
   input iErrType as character
):
   if iErrType ne "loadUTD"
   then do:
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","InLineNotMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NoGtinForMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NoBarcodForGtin").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","MarkNotFormatqnty").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","MarkingForTypeEDO").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NotMarkForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","MultGtinForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NoBarCodeForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NotFindGdsForBarCode").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NotEqGgsForLineAndMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","GtinQntyNotOne").
   end.
   if iErrType ne "CheckGds"
   then do:
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","InLineNotMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NoGtinForMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NoBarcodForGtin").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","MarkNotFormatqnty").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","MarkingForTypeEDO").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NotMarkForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","MultGtinForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NoBarCodeForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NotFindGdsForBarCode").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NotEqGgsForLineAndMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","GtinQntyNotOne").
   end.
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"InLineNotMark").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NoGtinForMark").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NoBarcodForGtin").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"MarkNotFormatqnty").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"MarkingForTypeEDO").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NotMarkForLine").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"MultGtinForLine").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NoBarCodeForLine").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NotFindGdsForBarCode").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NotEqGgsForLineAndMark").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"GtinQntyNotOne").
   define variable v-par-type as character no-undo.
   define variable v-par-val  as character no-undo.
   define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define buffer marking               for marking.
   define buffer utd-lines             for utd-lines.
   define buffer buf_utd-lines         for utd-lines.
   define buffer utd-marking-lines     for utd-marking-lines.
   define buffer Buf_utd-marking-lines for utd-marking-lines.
   define variable vGdsCode as integer no-undo.
   EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(iobj-type, iobj-code).
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      vGdsCode = ?.
      define variable Vflagmark as logical no-undo.
      define variable VflagOAD  as logical no-undo.
      assign
         Vflagmark = no
         VflagOAD = no
      .
      block-mark:
      for each utd-marking-lines
               where utd-marking-lines.db-num  = utd-lines.db-num
                 and utd-marking-lines.doc-id  = utd-lines.doc-id
                 and utd-marking-lines.LineNum = utd-lines.LineNum
      no-lock:
         if    isMark(utd-marking-lines.mark)
            or isOAD (utd-marking-lines.mark)
         then do:
            define variable vnewGdsCode as integer no-undo.
            vnewGdsCode = getGdsCodeByDM(utd-marking-lines.mark).
            if isMark(utd-marking-lines.mark)
            then do:
               Vflagmark = yes.
               find first marking where marking.mark eq utd-marking-lines.mark
               no-lock no-error.
               if not available marking
               then do:
                  AddUtdErr(utd-marking-lines.db-num,utd-marking-lines.doc-id,buffer utd-marking-lines:handle,iErrType,"InLineNotMark",utd-marking-lines.mark).
                  next block-mark.
               end.
               if vnewGdsCode eq ?
               then
                  vnewGdsCode = GetGdsCodeByGtin(marking.gds-ext-id).
               if    marking.gds-code eq 0
                  or marking.gds-code eq ?
                  or marking.sts eq 0
                  or marking.sts eq ?
                  or marking.box-qnty eq ?
                  or (marking.gds-code ne vnewGdsCode
                      and vnewGdsCode ne ?
                      and vnewGdsCode ne 0)
               then do:
                  find first marking where marking.mark eq utd-marking-lines.mark
                  exclusive-lock no-error.
                  if marking.box-qnty = ? then marking.box-qnty = getQntyUTDByDM(marking.mark).
                  if marking.gds-ext-id = "" then marking.gds-ext-id = getGtinByDM(marking.mark).
                  if marking.gds-code = ? or marking.gds-code ne vnewGdsCode then marking.gds-code = vnewGdsCode.
                  if    marking.gds-ext-id eq ""
                     or marking.gds-ext-id eq ?
                  then do:
                     AddUtdErr(utd-marking-lines.db-num,utd-marking-lines.doc-id,buffer utd-marking-lines:handle,iErrType,"NoGtinForMark",string(utd-lines.LineNum ) + chr(4) + marking.mark).
                  end.
                  else if    marking.gds-code eq 0
                          or marking.gds-code eq ?
                  then
                     AddUtdErr(utd-marking-lines.db-num,utd-marking-lines.doc-id,buffer utd-marking-lines:handle,iErrType,"NoBarcodForGtin",string(utd-lines.LineNum ) + chr(4) + marking.gds-ext-id).
                  else if     marking.sts eq 0
                          or  marking.sts eq ?
                  then
                     marking.sts = objSrv:Env:marking:Sts:Mark:PendingVerification:KeyIntDB.
               end.
               if utd-marking-lines.doc-level eq 1
               then do:
                  if marking.box-qnty eq ?
                  then
                     AddUtdErr(utd-marking-lines.db-num,utd-marking-lines.doc-id,buffer utd-marking-lines:handle,iErrType,"MarkNotFormatqnty",string(utd-lines.LineNum ) + chr(4) + utd-marking-lines.mark).
               end.
            end.
            else do:
               VflagOAD = yes.
               define variable vQnty as decimal no-undo.
               vQnty = getQntyUTDByCodId(utd-marking-lines.mark) .
               setAttrUtdMarkingLines (utd-marking-lines.db-num,
                                       utd-marking-lines.doc-id,
                                       utd-marking-lines.LineNum,
                                       utd-marking-lines.mark,
                                       "box-qnty",
                                        string(vQnty)).
               define variable vgtin as character no-undo.
               vgtin = getGtinByDM(utd-marking-lines.mark).
               if getQntyCodeByGtin(vgtin) ne 1
               then
                  AddUtdErr(utd-marking-lines.db-num,utd-marking-lines.doc-id,buffer utd-marking-lines:handle,iErrType,"GtinQntyNotOne",string(utd-lines.LineNum ) + chr(4) + vgtin).
            end.
            if utd-marking-lines.gds-code ne vnewGdsCode
            and vnewGdsCode ne ?
            and vnewGdsCode ne 0
            then do:
               find first buf_utd-marking-lines
                        where buf_utd-marking-lines.db-num   = utd-marking-lines.db-num
                          and buf_utd-marking-lines.doc-id   = utd-marking-lines.doc-id
                          and buf_utd-marking-lines.LineNum  = utd-marking-lines.LineNum
                          and buf_utd-marking-lines.mark     = utd-marking-lines.mark
               exclusive-lock no-error.
               if available buf_utd-marking-lines
               then do:
                  buf_utd-marking-lines.gds-code = vnewGdsCode.
               end.
            end.
         end.
         else  do:
            define variable vgdsbar as integer no-undo.
            vgdsbar = GetGdsCodeByGtin(utd-marking-lines.mark).
            if    utd-marking-lines.gds-code ne vgdsbar
            then do:
               find first buf_utd-marking-lines
                          where buf_utd-marking-lines.db-num   = utd-marking-lines.db-num
                            and buf_utd-marking-lines.doc-id   = utd-marking-lines.doc-id
                            and buf_utd-marking-lines.LineNum  = utd-marking-lines.LineNum
                            and buf_utd-marking-lines.mark     = utd-marking-lines.mark
               exclusive-lock no-error.
               if available buf_utd-marking-lines
               then do:
                  buf_utd-marking-lines.gds-code = vgdsbar.
               end.
            end.
            if vgdsbar ne ?
            then do:
                              if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                         ( vgdsbar,
                           'mark-type':U,
                           output v-par-val,
                           output v-par-type
                          ).
               if      (EDOParSec:GetIsEDOForType(v-par-val)
                    or  EDOParSec:GetIsArticForType(v-par-val))
                and not EDOParSec:GetIsTransitionalForType(v-par-val)
                and     EDOParSec:IsEdo
               then do:
                  AddUtdErr(utd-marking-lines.db-num,
                            utd-marking-lines.doc-id,
                            buffer utd-marking-lines:handle,
                            iErrType,
                            "MarkingForTypeEDO",
                            string(utd-lines.LineNum ) + chr(4) + utd-marking-lines.mark).
               end.
            end.
         end.
         if vGdsCode eq ?
         then
            vGdsCode = utd-marking-lines.gds-code.
         if vGdsCode ne utd-marking-lines.gds-code
         and utd-marking-lines.gds-code > 0
         then do:
            vGdsCode = -1.
         end.
      end.
      if  vGdsCode = -1
      then do:
         vGdsCode = ?.
         AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"MultGtinForLine",string(utd-lines.LineNum )).
         next block-line.
      end.
      if vGdsCode ne ?
      then do:
                  if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                   ( vGdsCode,
                     'mark-type':U,
                     output v-par-val,
                     output v-par-type
                    ).
         if   not EDOParSec:GetIsTransitionalForType(v-par-val)
             and(
              (    EDOParSec:GetIsEDOForType(v-par-val)
                  and not Vflagmark)
              or  (EDOParSec:GetIsArticForType(v-par-val)
                  and not VflagOAD
                  and not Vflagmark))
         then do:
            AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"NotMarkForLine",string(utd-lines.LineNum)).
         end.
      end.
      if utd-lines.gds-code ne vGdsCode
      then do:
         find first  buf_utd-lines where buf_utd-lines.db-num  eq utd-lines.db-num
                                     and buf_utd-lines.doc-id  eq utd-lines.doc-id
                                     and buf_utd-lines.LineNum eq utd-lines.LineNum
         exclusive-lock no-error.
         if available buf_utd-lines
         then
            buf_utd-lines.gds-code = vGdsCode.
         release buf_utd-lines.
      end.
      define variable VBarCode as character no-undo.
      VBarCode = getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"BarCode").
      if VBarCode ne ?
      then do:
         if num-entries(VBarCode," ") > 0
         then
            VBarCode = entry(num-entries(VBarCode," "),VBarCode," ").
         vgdsbar = GetGdsCodeByGtin(VBarCode).
         if vgdsbar eq ? or vgdsbar eq 0
         then do:
            AddUtdErr(utd-lines.db-num,
                      utd-lines.doc-id,
                      buffer utd-lines:handle,
                      iErrType,
                      "NotFindGdsForBarCode",
                      string(utd-lines.LineNum ) + chr(4) + VBarCode).
         end.
         else do:
            if    utd-lines.gds-code eq ?
               or utd-lines.gds-code eq 0
            then do:
               find first  buf_utd-lines where buf_utd-lines.db-num  eq utd-lines.db-num
                                           and buf_utd-lines.doc-id  eq utd-lines.doc-id
                                           and buf_utd-lines.LineNum eq utd-lines.LineNum
               exclusive-lock no-error.
               if available buf_utd-lines
               then
                  buf_utd-lines.gds-code = vgdsbar.
               release buf_utd-lines.
            end.
            else if utd-lines.gds-code ne vgdsbar
            then do:
               AddUtdErr(utd-lines.db-num,
                      utd-lines.doc-id,
                      buffer utd-lines:handle,
                      iErrType,
                      "NotEqGgsForLineAndMark",
                      string(utd-lines.LineNum ) + chr(4) + String(vgdsbar) + chr(4) + String(utd-lines.gds-code)).
            end.
         end.
      end.
      if vGdsCode eq ? and utd-lines.gds-code eq ?
      then
         AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"NoBarCodeForLine",string(utd-lines.LineNum )).
   end.
end.
function GetUtdLineForOrig return logical
(input idb-num as integer,
 input idoc-id as integer,
 input ilineNum as integer,
 input idb-numOrig as integer,
 input idoc-idOrig as integer,
 buffer edoc-lines for utd-lines):
   define buffer edoc-marking-lines for ub.utd-marking-lines.
   block-mark:
   for each utd-marking-lines where utd-marking-lines.db-num  eq idb-num
                                and utd-marking-lines.doc-id  eq idoc-id
                                and utd-marking-lines.LineNum eq iLineNum
                                and utd-marking-lines.site eq "-"
   no-lock:
      find first edoc-marking-lines where edoc-marking-lines.db-num eq idb-numOrig
                                      and edoc-marking-lines.doc-id eq idoc-idOrig
                                      and edoc-marking-lines.mark   eq utd-marking-lines.mark
                  no-lock no-error.
      if available edoc-marking-lines
      then do:
         find first edoc-lines where edoc-lines.db-num      = edoc-marking-lines.db-num
                                 and edoc-lines.doc-id            = edoc-marking-lines.doc-id
                                 and edoc-lines.LineNum           = edoc-marking-lines.LineNum
         no-lock no-error.
            leave block-mark.
       end.
   end.
    if not available edoc-lines
    then do:
       find  first  utd-lines where utd-lines.db-num      = idb-num
                                and utd-lines.doc-id      = idoc-id
                                and utd-lines.LineNum     = ilinenum
          no-lock no-error.
       find  edoc-lines where edoc-lines.db-num      = idb-numOrig
                               and edoc-lines.doc-id      = idoc-idOrig
                               and edoc-lines.ProductCode = utd-lines.ProductCode
       no-lock no-error.
    end.
    if not available edoc-lines
    then
       find  edoc-lines where edoc-lines.db-num      = idb-numOrig
                               and edoc-lines.doc-id      = idoc-idOrig
                               and edoc-lines.gds-code    = utd-lines.gds-code
       no-lock no-error.
end.
function GetLastUTDinPack returns logical
(input idb-num as integer,
 input idoc-id as integer,
 output odb-num as integer,
 output odoc-id as integer ) forward.
function getObgFns return logical
(input iDocumentNumber   as character ,
 input iFnsParticipantId as character ,
 input ikpp              as character ,
 output ohost-code       as integer,
 output oobj-type        as character ,
 output oobj-code        as integer ,
 output otext            as character  ):
    define buffer ext-classif   for ext-classif.
    define buffer clients       for clients.
    define buffer buf_clients   for clients.
    define buffer clients-attr  for clients-attr.
    find first ext-classif where ext-classif.classif-name  eq 'id_diadok_client':U
                             and ext-classif.charkey_three eq iFnsParticipantId
    no-lock no-error.
    if available ext-classif
    then do:
       if ext-classif.CharKey_One eq 'маг':U
       then do:
          assign
             oobj-type = ext-classif.CharKey_One
             oobj-code = ext-classif.Key#_One
          .
          find first clients
               where clients.obj-type   = ext-classif.CharKey_One
                 and clients.obj-code   = ext-classif.Key#_One
          no-lock no-error .
          if available clients
          then
             ohost-code =  clients.host-code.
       end.
       else do:
          find first clients
               where clients.obj-type   = ext-classif.CharKey_One
                 and clients.obj-code   = ext-classif.Key#_One
                 and can-find(first ub.sysconf where ub.sysconf.host-code = clients.obj-code)
          no-lock no-error .
          if not available clients
          then do:
             otext = substitute("По &1 получатель  &2 не наша фирма." ,iDocumentNumber, iFnsParticipantId) .
             return no.
          end.
          ohost-code = ext-classif.Key#_One.
          block-cl:
          for each clients-attr
             where clients-attr.attr-code  = 'kpp':U
               and clients-attr.obj-type   = 'маг':U
               and clients-attr.attr-value = ikpp
               and can-find(buf_clients where buf_clients.obj-type   = clients-attr.obj-type
                                          and buf_clients.obj-code   = clients-attr.obj-code
                                          and buf_clients.host-code  = ohost-code)
          no-lock :
             leave block-cl.
          end.
          if     available clients
             and clients.obj-type eq 'маг':U
          then do:
             assign
                oobj-type = clients.obj-type
                oobj-code = clients.obj-code
             .
          end.
          else if available clients-attr
          then do:
             assign
                oobj-type = clients-attr.obj-type
                oobj-code = clients-attr.obj-code
             .
          end.
          else do:
             otext = substitute("По &1 не найден объект по КПП &2." ,iDocumentNumber, ikpp ).
             return yes.
          end.
       end.
    end.
    else do:
       otext = substitute("По &1 не найден получатель  &2." ,iDocumentNumber, iFnsParticipantId) .
       return no.
    end.
    return ?.
end.
function CheckUcdForReturn return logical
(input idb-numUcd as integer,
 input idoc-idUcd as integer,
 input idb-numRet as integer,
 input idoc-idRet as integer  ):
    for each utd-marking-lines where utd-marking-lines.db-num eq idb-numUcd
                                 and utd-marking-lines.doc-id eq idoc-idUcd
                                 and utd-marking-lines.doc-level eq 1
    no-lock:
       create tt-utd-mark.
       buffer-copy utd-marking-lines to tt-utd-mark
       assign
          tt-utd-mark.side = "+"
       .
    end.
    for each utd-marking-lines where utd-marking-lines.db-num eq idb-numRet
                                 and utd-marking-lines.doc-id eq idoc-idRet
                                 and utd-marking-lines.doc-level eq 1
    no-lock:
       find first tt-utd-mark where tt-utd-mark.mark eq utd-marking-lines.mark
       no-lock no-error.
       if available tt-utd-mark
       then
          tt-utd-mark.side = "".
       else do:
          create tt-utd-mark.
          buffer-copy utd-marking-lines to tt-utd-mark
          assign
             tt-utd-mark.side = "-"
          .
       end.
    end.
    for each tt-utd-mark where  tt-utd-mark.side ne ""
    no-lock:
       AddUtdErrForTab(utd.db-num, utd.doc-id, "utd-marking-lines", buffer tt-utd-mark:handle, "UCDСompar", "NotMark" + tt-utd-mark.side, tt-utd-mark.mark).
    end.
    for each tt-utd-mark:
       delete tt-utd-mark.
    end.
end.
function GetLastUTDinPackAft returns logical
(input idb-num as integer,
 input idoc-id as integer,
 output odb-num as integer,
 output odoc-id as integer ) forward.
function SaturateAndCheckUTD return character
(input idb-num as integer,
 input idoc-id as integer  ):
   define buffer clients-attr          for clients-attr.
   define buffer clients               for clients.
   define buffer Utd                   for Utd.
   define buffer utd_ret               for ub.utd.
   define buffer utd-lines             for utd-lines.
   define buffer buf_utd-lines         for utd-lines.
   define buffer buf_utddoc-lines      for utd-lines.
   define buffer marking               for marking.
   define buffer marking-lines         for marking-lines.
   define buffer utd-marking-lines     for utd-marking-lines.
   define buffer Buf_utd-marking-lines for utd-marking-lines.
   define buffer contract              for contract.
   define buffer old_utd               for Utd.
   define variable vError as character no-undo.
   define variable vGdsCode as integer no-undo.
   define variable vcli-type as character no-undo.
   define variable vcli-code as integer no-undo.
   define variable vhost-code as integer no-undo init ?.
   define variable vcontract-code as integer no-undo.
   define variable vobj-type as character no-undo init ?.
   define variable vobj-code as integer no-undo init ?.
   define variable volddb-num as integer no-undo.
   define variable volddoc-id as integer no-undo.
   define variable vMark as logical no-undo.
   define variable VUcd as logical no-undo.
   define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-type as character no-undo.
   define variable v-par-val  as character no-undo.
   define variable VFileMark as logical no-undo.
   define variable vunit     as int no-undo.
   define variable vunitCode as character no-undo.
   define variable vMarkingUtd as logical no-undo.
   find first Utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available Utd
   then do:
      VUcd = utd.EDocType eq objSrv:Env:Utd:EDocType:UCD:KeyIntDB.
      VFileMark = getattrutd (utd.db-num,utd.doc-id,"FileName") begins "ON_NSCHFDOPPRMARK_".
      ClearUtdErr(utd.db-num,utd.doc-id,"loadUtd").
      assign
            vobj-type  = utd.obj-type
            vobj-code  = utd.obj-code
            vhost-code = utd.host-code
      .
      do:
         define variable vtext       as character no-undo.
         define variable vhost-code1 as integer   no-undo.
         define variable vobj-type1  as character no-undo.
         define variable vobj-code1  as integer   no-undo.
          getObgFns
                    (input utd.DocumentNumber ,
                     input utd.obj-FnsParticipantId ,
                     input utd.obj-kpp,
                     output vhost-code1,
                     output vobj-type1,
                     output vobj-code1,
                     output vtext ).
         assign
            vobj-type  = vobj-type1   when vobj-type  eq ? or vobj-type  eq ""
            vobj-code  = vobj-code1   when vobj-code  eq ? or vobj-code  eq 0
            vhost-code = vhost-code1  when vhost-code eq ? or vhost-code eq 0
         .
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(vobj-type, vobj-code).
         CheckGds (utd.db-num,utd.doc-id,vobj-type,vobj-code,"loadUTD").
         block-line:
         for each utd-lines where utd-lines.db-num eq utd.db-num
                              and utd-lines.doc-id eq utd.doc-id
         no-lock:
            vGdsCode =?.
            define variable vNotMarkForLine as logical no-undo.
            vNotMarkForLine = no.
            if not VUcd
            then do:
               find first utd-marking-lines
                    where utd-marking-lines.db-num  = utd-lines.db-num
                      and utd-marking-lines.doc-id  = utd-lines.doc-id
                      and utd-marking-lines.LineNum = utd-lines.LineNum
               no-lock no-error.
               if not available utd-marking-lines
               then do:
                  AddUtdErr(utd.db-num,utd.doc-id,buffer utd-lines:handle,"loadUtd","NotMarkForLine",string(utd-lines.LineNum)).
                  vNotMarkForLine = yes.
               end.
            end.
            block-mark:
            for each utd-marking-lines
               where utd-marking-lines.db-num  = utd-lines.db-num
                 and utd-marking-lines.doc-id  = utd-lines.doc-id
                 and utd-marking-lines.LineNum = utd-lines.LineNum
            no-lock:
               vMark = yes.
               if     isMark(utd-marking-lines.mark)
                  and utd-marking-lines.gds-code  ne 0
                  and utd-marking-lines.gds-code ne ?
               then do:
                                    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                        ( utd-marking-lines.gds-code,
                         'mark-type':U,
                         output v-par-val,
                         output v-par-type
                         ).
                   if     not VFileMark
                      and not VUcd
                      and EDOParSec:GetIsEDOForType(v-par-val) and EDOParSec:IsEdo
                   then do:
                       AddUtdErr(utd.db-num,
                                  utd.doc-id,
                                  buffer utd-marking-lines:handle,
                                  "loadUtd",
                                  "NotON_NSCHFDOPPRMARK",
                                  string(utd-lines.LineNum ) + chr(4) + utd-marking-lines.mark).
                  end.
               end.
            end.
            if utd-lines.gds-code eq 0 or utd-lines.gds-code eq ?
            then do :
               if     VUcd
               then do:
                  GetLastUTDinPack (utd.db-num,utd.doc-id,volddb-num,volddoc-id).
                  GetUtdLineForOrig(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,volddb-num,volddoc-id, buffer buf_utddoc-lines).
                  if available buf_utddoc-lines
                  then do:
                     vGdsCode = buf_utddoc-lines.gds-code.
                     vunitCode = buf_utddoc-lines.UnitCode.
                     if     getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old") ne ?
                        and buf_utddoc-lines.UnitCode ne getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old")
                     then
                        AddUtdErr(utd.db-num,utd.doc-id,buffer utd-lines:handle,
                            "loadUtd",
                            "UcdUnitChangForUtd",
                            string(utd-lines.LineNum )                  + chr(4) +
                            buf_utddoc-lines.UnitCode                   + chr(4) +
                            getattrutdlinesex(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old","?")).
                  end.
                  if     utd-lines.UnitCode ne ?
                     and utd-lines.UnitCode ne ""
                     and utd-lines.UnitCode ne getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old")
                  then
                     AddUtdErr(utd.db-num,utd.doc-id,buffer utd-lines:handle,
                            "loadUtd",
                            "UcdUnitChang",
                            string(utd-lines.LineNum )                  + chr(4) +
                            utd-lines.UnitCode                          + chr(4) +
                            getattrutdlinesex(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old","?")).
               end.
            end.
            else
               vGdsCode = utd-lines.gds-code.
            define variable vValText as character no-undo.
            define variable vValDec  as decimal no-undo.
            VValText = GetAttrUtdlines (utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity").
            if VValText = ?
            then do:
               vValDec = utd-lines.Quantity.
               setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity",string(utd-lines.Quantity)).
            end.
            else
               vValDec = dec(VValText).
            release bar-code .
            if     vGdsCode > 0 and vGdsCode ne ?
            then do:
               assign
                  vunitCode = utd-lines.UnitCode when utd-lines.UnitCode ne ? and utd-lines.UnitCode ne ""
                  vunit = ?
                  vunit = integer (getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unit"))
               no-error.
               if vunit ne 0 and vunit ne ?
               then do:
                  find units where units.OKEI eq vunit no-lock no-error.
                  if available units
                  then
                     vunitCode = units.unit-name.
               end.
               find first bar-code where bar-code.gds-code eq vGdsCode
                                     and bar-code.unit-cli eq vUnitCode
               no-lock no-error.
               if not available bar-code
               then
                  AddUtdErr(utd.db-num,utd.doc-id,buffer utd-lines:handle,
                            "loadUtd",
                            "Unit",
                            string(utd-lines.LineNum )                  + chr(4) +
                            string(vGdsCode)                            + chr(4) +
                            (if vunit ne ? then string(vunit ) else "") + chr(4) +
                            vunitCode).
            end.
            if utd-lines.Quantity ne vValDec * (if avail bar-code then bar-code.cli-base-rate else 1)
            then do:
               find first  buf_utd-lines where buf_utd-lines.db-num  eq utd-lines.db-num
                                           and buf_utd-lines.doc-id  eq utd-lines.doc-id
                                           and buf_utd-lines.LineNum eq utd-lines.LineNum
               exclusive-lock no-error.
               if available buf_utd-lines
               then do:
                  buf_utd-lines.Quantity = vValDec * (if avail bar-code then bar-code.cli-base-rate else 1).
                  release buf_utd-lines.
               end.
            end.
            vValDec  = decimal(getAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity_old")) no-error.
            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity_old_new",string(vValDec * (if avail bar-code then bar-code.cli-base-rate else 1))).
            if     not VUcd
               and CheckMarkUtdLine(utd.db-num,utd.doc-id,utd-lines.LineNum)
            then
               vMarkingUtd = yes .
         end.
         if not VUcd
         then
            CheckQnty(utd.db-num, utd.doc-id, "loadUtd").
         find first ext-classif where ext-classif.classif-name  eq 'id_diadok_client':U
                                  and ext-classif.charkey_three eq utd.cli-FnsParticipantId
         no-lock no-error.
         if available ext-classif
         then
            assign
               vcli-type = ext-classif.CharKey_One
               vcli-code = ext-classif.Key#_One
            .
         else do:
            assign
              vcli-type = ?
              vcli-code = ?
            .
            AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoSuppForId",utd.cli-FnsParticipantId ).
         end.
         find first contract  where contract.host-code eq vhost-code
                                and contract.cli-type  eq vcli-type
                                and contract.cli-code  eq vcli-code
                                and contract.contract-prn-code eq Utd.BaseDocumentNumber
         no-lock no-error.
         define variable VContractEdo as logical no-undo init yes.
         if available contract
         then do:
            assign
               VContractEdo = contract.whole-send-news > 0
               vcontract-code = contract.contract-code
            .
            if not VContractEdo
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoEdoDoc", Utd.BaseDocumentNumber).
         end.
         else do:
            vcontract-code = ?.
         end.
      end.
      if not GetLastUTDinPackAft (utd.db-num, utd.doc-id, volddb-num, volddoc-id)
      then do:
         AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoLastDoc",string(utd.PackageId) + chr(4) + string(volddb-num) + chr(4) + string(volddoc-id)).
      end.
      define variable vdoc-code as character no-undo init ?.
      if utd.EDocType              eq objSrv:Env:Utd:EDocType:Ucd:KeyIntDB
      then do:
         find first utd_ret where utd_ret.parentDocumentExt     eq utd.parentDocumentExt
                              and utd_ret.parentOrganizationExt eq utd.parentOrganizationExt
                              and utd_ret.Timestamp             le utd.Timestamp
                              and utd_ret.EDocType              eq objSrv:Env:Utd:EDocType:returns:KeyIntDB
         no-lock no-error.
         if available utd_ret
         then do:
            vdoc-code = utd_ret.doc-code.
            CheckUcdForReturn(utd.db-num,utd.doc-id,utd_ret.db-num,utd_ret.doc-id).
         end.
      end.
   end.
   find current utd exclusive-lock no-error.
   if available utd
   then do:
      assign
         utd.cli-type      = vcli-type      when vcli-type      ne ?
         utd.cli-code      = vcli-code      when vcli-type      ne ?
         utd.host-code     = vhost-code     when vhost-code     ne ? and vhost-code     ne 0
         utd.contract-code = vcontract-code when vcontract-code ne ?
         utd.obj-type      = vobj-type      when vobj-type      ne ? and vobj-type      ne ""
         utd.obj-code      = vobj-code      when vobj-code      ne ? and vobj-code      ne 0
         utd.doc-code      = vdoc-code      when vdoc-code      ne ?
      .
      if   ( utd.contract-code eq ?
         or utd.contract-code eq 0)
         and not vucd
      then
         AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoContForFirmId",(if utd.host-code eq ? then "?" else string (utd.host-code)) + chr(4) +  utd.BaseDocumentNumber).
      if utd.host-code eq ?
         or utd.host-code eq 0
      then
         AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoFirmForId",if utd.obj-FnsParticipantId eq ? then "?" else utd.obj-FnsParticipantId ).
      if utd.obj-code eq ?
         or utd.obj-code eq 0
      then
         AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoShopForKpp",utd.obj-kpp).
   end.
   vError = GetErrForUtdstr(utd.db-num,utd.doc-id,"loadUtd").
   if vError eq ""
   then do:
      if utd.sts eq 0 or utd.sts eq ?
      then
         utd.sts = if VUcd
                   then ObjSrv:Env:Utd:Sts:th:ConfirmedUcd:KeyIntDB
                   else ObjSrv:Env:Utd:Sts:th:ReceivedFromSupplier:KeyIntDB.
      if utd.sts = ObjSrv:Env:Utd:Sts:th:LoadError:KeyIntDB
      then do:
         utd.sts = ObjSrv:Env:Utd:Sts:th:ReceivedFromSupplier:KeyIntDB.
      end.
      if     not VUcd
         and utd.sts = ObjSrv:Env:Utd:Sts:th:ReceivedFromSupplier:KeyIntDB
      then do:
         if not vMarkingUtd
         then
            utd.sts = objSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB.
      end.
   end.
   else do:
      if utd.sts ne ObjSrv:Env:Utd:Sts:th:CorrectionRequested:KeyIntDB
      then
         utd.sts = ObjSrv:Env:Utd:Sts:th:LoadError:KeyIntDB.
   end.
   if     utd.sts-edi  >= ObjSrv:Env:Utd:Sts:edi:StatChangLoanOnlyBeg
      and utd.sts-edi  <= ObjSrv:Env:Utd:Sts:edi:StatChangLoanOnlyEnd
   then
      utd.sts-edi = ?.
   else if     (not vMark and  not vucd) or not VContractEdo
           and utd.sts-edi < ObjSrv:Env:Utd:Sts:edi:StatChangLoanOnlyBeg
   then
      utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:AutoRejected:KeyIntDB.
   release utd no-error.
   if error-status:error
   then
      return error return-value.
   return vError.
end.
function ReCheckload returns logical
(idb-num as integer,
 idoc-id as integer,
 iload   as logical ):
   subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
   define buffer buf_c-utd for ub.c-utd .
   define buffer buf_utd   for ub.utd .
   find first buf_utd where buf_utd.db-num eq idb-num
                        and buf_utd.doc-id eq idoc-id
   exclusive-lock no-error.
   if available buf_utd
   then do:
      if    iload
         or buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:loaderror:KeyIntDB
      then do:
         SaturateAndCheckUTD(buf_utd.db-num, buf_utd.doc-id) no-error .
         if  error-status:error then
         do:
            message return-value view-as alert-box.
         end.
      end.
      if    buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:InconsistencyWithSupplyContract:KeyIntDB
         or buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:LinesInError:KeyIntDB
         or buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:DeliveryCodeMismatch:KeyIntDB
         or buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:LackOfMarkingCodesInCirculation:KeyIntDB
      then do:
         find last buf_c-utd no-lock where buf_c-utd.db-num eq buf_utd.db-num and
                                           buf_c-utd.doc-id eq buf_utd.doc-id and
                                           buf_c-utd.sts    eq buf_utd.sts and
                                           buf_c-utd.sts    eq ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB
         no-error .
         if available (buf_c-utd)
         then do:
            buf_utd.sts = buf_c-utd.sts .
            buf_utd.sts-edi = buf_c-utd.sts-edi .
         end.
         else do:
            if    buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:InconsistencyWithSupplyContract:KeyIntDB
               or buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:LinesInError:KeyIntDB
            then
               buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB .
            else
               buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:ReceivedFromSupplier:KeyIntDB .
            buf_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:Verification:KeyIntDB .
         end.
      end.
      if buf_utd.sts = objSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB
      then do:
         run utl/utd-checkSpec.p (input buf_utd.db-num,
                                  input buf_utd.doc-id) .
      end.
   end.
   release buf_utd.
   unsubscribe "getNextseq".
end.
function ReCheck returns logical
(idb-num as integer,
 idoc-id as integer ):
   ReCheckload(idb-num,idoc-id,no).
end.
function GetLastUTDForPac returns logical
(iPackegeId as character ,
 iTimestamp as datetime,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   find last buf_utd where Buf_utd.PackageId eq iPackegeId
                             and Buf_utd.EDocType  eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
                             and Buf_utd.Timestamp gt iTimestamp
   no-lock no-error.
   if available  buf_utd
   then
      assign
         odb-num = buf_utd.db-num
         odoc-id = buf_utd.doc-id
      no-error.
   else
      assign
         odb-num = ?
         odoc-id = ?
      no-error.
end.
function GetprevUTDForPac returns logical
(iPackegeId as character ,
 iTimestamp as datetime,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   find last buf_utd where Buf_utd.PackageId eq iPackegeId
                             and Buf_utd.EDocType  eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
                             and Buf_utd.Timestamp < iTimestamp
   no-lock no-error.
   if available  buf_utd
   then
      assign
         odb-num = buf_utd.db-num
         odoc-id = buf_utd.doc-id
      no-error.
   else
      assign
         odb-num = ?
         odoc-id = ?
      no-error.
end.
function GetLastUTDinPackAft returns logical
(input idb-num as integer,
 input idoc-id as integer,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   define buffer     utd for utd.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if utd.PackageId eq ""
      then do:
         assign
            odb-num = utd.db-num
            odoc-id = utd.doc-id
         .
         return yes.
      end.
      else do:
         GetLastUTDForPac(utd.PackageId,utd.Timestamp,output odb-num,output odoc-id ).
         if    odb-num eq ?
            or odoc-id eq ?
         then do:
            assign
               odb-num = utd.db-num
               odoc-id = utd.doc-id
            .
            return yes.
         end.
         else
            return odoc-id = utd.doc-id.
      end.
   end.
   return ?.
end.
function GetLastUTDinPackbef returns logical
(input idb-num as integer,
 input idoc-id as integer,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   define buffer     utd for utd.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if utd.PackageId eq ""
      then do:
         assign
            odb-num = utd.db-num
            odoc-id = utd.doc-id
         .
         return yes.
      end.
      else do:
         GetprevUTDForPac(utd.PackageId,utd.Timestamp,output odb-num,output odoc-id ).
         if    odb-num eq ?
            or odoc-id eq ?
         then do:
            assign
               odb-num = utd.db-num
               odoc-id = utd.doc-id
            .
            return yes.
         end.
         else
            return odoc-id = utd.doc-id.
      end.
   end.
   return ?.
end.
function GetLastUTDinPack returns logical
(input idb-num as integer,
 input idoc-id as integer,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   define buffer     utd for utd.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if utd.PackageId eq ""
      then do:
         assign
            odb-num = utd.db-num
            odoc-id = utd.doc-id
         .
         return yes.
      end.
      else do:
         GetLastUTDForPac(utd.PackageId,datetime("01/01/1900"),output odb-num,output odoc-id ).
         if    odb-num eq ?
            or odoc-id eq ?
         then do:
            assign
               odb-num = utd.db-num
               odoc-id = utd.doc-id
            .
            return yes.
         end.
         else
            return odoc-id = utd.doc-id.
      end.
   end.
   return ?.
end.
function delMark returns logical
( buffer utd-marking-lines for utd-marking-lines ):
   define buffer buf_utd-marking-line for utd-marking-lines.
   for each marking where marking.mark-parent eq utd-marking-lines.mark no-lock:
      find first buf_utd-marking-line where buf_utd-marking-line.db-num    eq utd-marking-lines.db-num
                                        and buf_utd-marking-line.doc-id    eq utd-marking-lines.doc-id
                                        and buf_utd-marking-line.mark      eq marking.mark
      no-lock no-error.
      if available  buf_utd-marking-line
      then do:
         delMark(buffer buf_utd-marking-line).
         delete buf_utd-marking-line.
      end.
   end.
end.
function addMark returns logical
( buffer utd-marking-lines for utd-marking-lines ):
   define buffer buf_utd-marking-line for utd-marking-lines.
   define buffer par_utd-marking-line for utd-marking-lines.
   define buffer buf_utd for ub.utd .
   for each marking where marking.mark-parent eq utd-marking-lines.mark no-lock:
      find first buf_utd-marking-line where buf_utd-marking-line.db-num    eq utd-marking-lines.db-num
                                        and buf_utd-marking-line.doc-id    eq utd-marking-lines.doc-id
                                        and buf_utd-marking-line.mark      eq marking.mark
      no-lock no-error.
      if available  buf_utd-marking-line
      then do:
         if buf_utd-marking-line.doc-level ne utd-marking-lines.doc-level + 1
         then do:
            find current  buf_utd-marking-line exclusive-lock no-error.
            if available buf_utd-marking-line
            then
               buf_utd-marking-line.doc-level = utd-marking-lines.doc-level + 1.
         end.
      end.
      else do:
         find first buf_utd no-lock where buf_utd.db-num    eq utd-marking-lines.db-num
                                      and buf_utd.doc-id    eq utd-marking-lines.doc-id
                                      no-error .
         create buf_utd-marking-line.
         buffer-copy utd-marking-lines except doc-level mark sts gds-code to buf_utd-marking-line
         assign
            buf_utd-marking-line.doc-level = utd-marking-lines.doc-level + 1
            buf_utd-marking-line.mark      = marking.mark
            buf_utd-marking-line.gds-code  = marking.Gds-code
            buf_utd-marking-line.sts      = if (available buf_utd and buf_utd.EDocType = objSrv:Env:Utd:EDocType:Mark_Collect:KeyIntDB)
                                            then marking.sts
                                            else
                                            if can-do(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait,string(marking.sts)) or
                                               can-do(objSrv:Env:Marking:Sts:Mark:Doc_Status,string(marking.sts)) or
                                               marking.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB or
                                               marking.sts = objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB
                                             then objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
                                             else marking.sts
         .
         if  buf_utd-marking-line.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB then
         do:
           for first par_utd-marking-line no-lock where
                     par_utd-marking-line.db-num  = buf_utd-marking-line.db-num
                 and par_utd-marking-line.doc-id  = buf_utd-marking-line.doc-id
                 and par_utd-marking-line.LineNum = buf_utd-marking-line.LineNum
                 and par_utd-marking-line.mark    = marking.mark-parent
                 and par_utd-marking-line.sts     = objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
           :
             buf_utd-marking-line.sts = objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB.
           end.
         end.
      end.
      addMark(buffer buf_utd-marking-line).
   end.
end.
function UnLockUTDMarkbuf returns logical
(buffer old_utd for utd,
 iAll as logical ):
   define variable voldkey    as character no-undo.
      run gen-key-rec (input "utd",
                       input  buffer old_utd:handle,
                       output voldkey).
   for each marking where marking.loc-key eq voldkey
   exclusive-lock:
      if    iAll
         or (    marking.sts eq  ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
             and marking.sts eq  ObjSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB )
      then do:
         marking.loc-key = "".
         marking.sts =  ObjSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB.
      end.
   end.
end.
function UnLockUTDMark returns logical
(idb-num as integer ,idoc-id as integer ,iall as logical):
   define buffer old_utd for utd.
   find first old_utd where old_utd.db-num eq idb-num
                        and old_utd.db-num eq idoc-id
   no-lock no-error.
   if available old_utd
   then do:
      UnLockUTDMarkbuf(buffer old_utd,iall).
   end.
end.
function changSts returns logical
(idb-num as integer ,
 idoc-id as integer ,
 old_sts_edo as character ,
 new_sts_edo as character  ):
   if     old_sts_edo ne new_sts_edo
      and ( new_sts_edo eq "RevocationAccepted"
           or  new_sts_edo eq "RecipientSignatureRequestRejected"
           )
   then
      UnLockUTDMark(idb-num,idoc-id,yes).
   if     old_sts_edo ne new_sts_edo
      and ( new_sts_edo eq "WithRecipientSignature"
        or  new_sts_edo eq "WithRecipientPartiallySignature"
           )
   then
      UnLockUTDMark(idb-num,idoc-id,no).
end.
function SetLockUTDMark returns logical
(idb-num as integer ,idoc-id as integer ):
   define buffer new_utd for utd.
   define buffer old_utd for utd.
   define variable volddb-num as integer no-undo.
   define variable volddoc-id as integer no-undo.
   define variable voldkey    as character no-undo.
   define variable vnewkey    as character no-undo.
   find first new_utd where new_utd.db-num eq idb-num
                        and new_utd.doc-id eq idoc-id
   no-lock no-error.
   if not GetLastUTDinPack (new_utd.db-num,new_utd.doc-id,volddb-num,volddoc-id)
   then do trans:
      find first old_utd where old_utd.db-num eq volddb-num
                           and old_utd.doc-id eq volddoc-id
      no-lock no-error.
         run gen-key-rec (input "utd",
                          input  buffer new_utd:handle,
                          output vnewkey).
         run gen-key-rec (input "utd",
                          input  buffer old_utd:handle,
                          output voldkey).
      for each utd-marking-lines where utd-marking-lines.db-num eq new_utd.db-num
                                   and utd-marking-lines.doc-id eq new_utd.doc-id
      no-lock:
         find first marking where marking.mark eq utd-marking-lines.mark no-lock no-error.
         if available  marking
         then do:
            if    marking.loc-key eq ""
               or marking.loc-key eq ?
               or marking.loc-key eq voldkey
            then do:
               find current marking exclusive-lock no-error.
               if available marking
               then do:
                  marking.loc-key = vnewkey.
                  release marking.
               end.
            end.
            else if marking.loc-key ne vnewkey
            then do:
               addutderr(new_utd.db-num,new_utd.doc-id,buffer new_utd:handle,"LoadUtd","MarkLock",marking.mark + chr(4) + marking.loc-key).
            end.
         end.
      end.
      UnLockUTDMark(old_utd.db-num,old_utd.doc-id,yes).
   end.
end.
function CheckedocMark return logical
(input idb-numorig as integer,
 input idoc-idorig as integer,
 input idb-numedoc as integer,
 input idoc-idedoc as integer  ):
    define variable VChekOk    as logical   no-undo init yes.
    define variable vMarkUtd   as logical   no-undo.
    define variable v-par-type as character no-undo.
    define variable v-par-val  as character no-undo.
    define buffer buf_utd-attr      for utd-attr.
    define buffer buf_utd           for utd.
    define buffer utd-marking-lines for utd-marking-lines.
    define buffer utd-lines         for utd-lines.
    define buffer marking           for marking.
    define buffer edoc-lines        for utd-lines.
       for each utd-marking-lines where utd-marking-lines.db-num    eq idb-numorig
                                    and utd-marking-lines.doc-id    eq idoc-idorig
                                    and utd-marking-lines.doc-level eq 1
                                    and utd-marking-lines.sts       eq objSrv:Env:marking:Sts:Mark:Checked_:KeyIntDB
       no-lock:
          if    isMark (utd-marking-lines.mark)
          then do:
             create tt-utd-mark.
             buffer-copy utd-marking-lines to tt-utd-mark
             assign
                tt-utd-mark.side = "+"
             .
          end.
       end.
       for each utd-marking-lines where utd-marking-lines.db-num eq idb-numedoc
                                    and utd-marking-lines.doc-id eq idoc-idedoc
                                    and utd-marking-lines.doc-level eq 1
       no-lock:
          if    isMark (utd-marking-lines.mark)
          then do:
             find first tt-utd-mark where tt-utd-mark.mark eq utd-marking-lines.mark
             no-lock no-error.
             if available tt-utd-mark
             then
                tt-utd-mark.side = "".
             else do:
                create tt-utd-mark.
                buffer-copy utd-marking-lines to tt-utd-mark
                assign
                   tt-utd-mark.side = "-"
                .
             end.
          end.
       end.
       for each tt-utd-mark where  tt-utd-mark.side ne ""
       no-lock:
          AddUtdErrForTab(idb-numedoc, idoc-idedoc, "utd-marking-lines", buffer tt-utd-mark:handle, "edoc", "MarkOrig" + tt-utd-mark.side, tt-utd-mark.mark).
          VChekOk = no.
       end.
       for each utd-lines where utd-lines.db-num    eq idb-numorig
                            and utd-lines.doc-id    eq idoc-idorig
       no-lock:
          find first edoc-lines where edoc-lines.db-num eq idb-numedoc
                                  and edoc-lines.doc-id eq idoc-idedoc
                                  and edoc-lines.LineNum eq utd-lines.LineNum
          no-lock no-error.
          define variable VUtdlinequentity as decimal no-undo.
          VUtdlinequentity = dec (getattrutdlinesex(utd-lines.db-num ,utd-lines.doc-id,utd-lines.LineNum,"QuantityBarCode","0")).
          if     VUtdlinequentity eq ?
             or (if available edoc-lines then edoc-lines.Quantity else 0) ne VUtdlinequentity
          then
             AddUtdErr(idb-numedoc, idoc-idedoc,buffer edoc-lines:handle,"edoc","lineQnty",string(edoc-lines.LineNum ) + chr(4) + string(VUtdlinequentity) + chr(4) + string(edoc-lines.Quantity ) ).
       end.
    for each tt-utd-mark:
       delete tt-utd-mark.
    end.
end.
function CheckEdoc returns character
(idb-numOrig as integer ,
 idoc-idOrig as integer,
 idb-num as integer ,
 idoc-id as integer ):
   define buffer utd  for ub.utd.
   define buffer utd-lines  for ub.utd-lines.
   define buffer utd-marking-lines  for ub.utd-marking-lines.
   define buffer edoc-lines for ub.utd-lines.
   define variable vSts as integer no-undo.
   define variable vMarkutd as logical no-undo.
   vSts = objSrv:Env:utd:Sts:th:ReceivedFromSupplier:KeyIntDB.
   Block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   exclusive-lock:
      define variable ismarkin as logical no-undo.
      define variable isOAD as logical no-undo.
      define variable isper as logical no-undo.
      getMarkUtdLine(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,
           output ismarkin, output isOAD, output isper).
      if    utd-lines.Price                eq 0
         or utd-lines.Total                eq 0
         or utd-lines.TotalWithVatExcluded eq 0
         or utd-lines.Quantity             eq 0
      then do:
         for each utd-marking-lines where utd-marking-lines.db-num  eq utd-lines.db-num
                                      and utd-marking-lines.doc-id  eq utd-lines.doc-id
                                      and utd-marking-lines.linenum eq utd-lines.LineNum
         no-lock:
            if    isMark(utd-marking-lines.mark)
               or isOad(utd-marking-lines.mark)
            then do:
               AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,"Edoc","Amount" , string(utd-lines.LineNum )).
               next Block-line.
            end.
         end.
         delete utd-lines.
      end.
      else if   ( utd-lines.Total                ne 0
              or utd-lines.Quantity             ne 0)
              and ismarkin or isOAD
      then do:
         Block-mark:
         for each utd-marking-lines where utd-marking-lines.db-num  eq utd-lines.db-num
                                      and utd-marking-lines.doc-id  eq utd-lines.doc-id
                                      and utd-marking-lines.linenum eq utd-lines.LineNum
         no-lock:
            if  (isOAD and
                  isMark(utd-marking-lines.mark)
               or isOad(utd-marking-lines.mark) )
               or (ismarkin and
                  isMark(utd-marking-lines.mark))
            then do:
               leave Block-mark.
            end.
         end.
         if not available utd-marking-lines
         then
            AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,"Edoc","Mark" ,string(utd-lines.LineNum)).
      end.
   end.
   for each utd-lines where utd-lines.db-num eq idb-numOrig
                        and utd-lines.doc-id eq idoc-idOrig
   no-lock:
      find first edoc-lines where edoc-lines.db-num eq idb-num
                              and edoc-lines.doc-id eq idoc-id
                              and edoc-lines.LineNum eq utd-lines.LineNum
      no-lock no-error.
      if     available edoc-lines
      then do:
         if edoc-lines.Quantity ne 0
         then do:
            if edoc-lines.Price ne utd-lines.Price
            then
               AddUtdErr(edoc-lines.db-num,edoc-lines.doc-id,buffer edoc-lines:handle,"Edoc","Price" ,string(edoc-lines.LineNum)).
         end.
      end.
      vSts = objSrv:Env:utd:Sts:th:SignatureRequired:KeyIntDB.
      CheckedocMark(idb-numOrig , idoc-idOrig , idb-num , idoc-id).
   end.
   define variable vError as character no-undo.
   vError = GetErrForUtdstr(idb-num , idoc-id ,"edoc").
   if vError ne ""
   then
      vSts = objSrv:Env:utd:Sts:th:edocError:KeyIntDB.
   else
      vSts = objSrv:Env:utd:Sts:th:SignatureRequired:KeyIntDB.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   exclusive-lock no-error.
   if available utd
   then do:
      utd.sts = vsts.
   end.
end.
function CrEdoc returns character
(iPack as character ,
 iTimestamp as datetime):
   define variable vdb-num as integer no-undo.
   define variable vdoc-id as integer no-undo.
   define buffer utd  for ub.utd.
   define buffer edoc for ub.utd.
   define buffer utd_ret   for ub.utd.
   define buffer utd-attr  for ub.utd-attr.
   define buffer edoc-attr for ub.utd-attr.
   define buffer utd-lines  for ub.utd-lines.
   define buffer edoc-lines for ub.utd-lines.
   define buffer utd-lines-attr  for ub.utd-lines-attr.
   define buffer edoc-lines-attr for ub.utd-lines-attr.
   define buffer utd-marking-lines  for ub.utd-marking-lines.
   define buffer edoc-marking-lines for ub.utd-marking-lines.
   define buffer utd-marking-lines-attr for ub.utd-marking-lines-attr.
   define buffer edoc-marking-lines-attr for ub.utd-marking-lines-attr.
   define variable vTimestamp  as datetime no-undo.
   find last utd where utd.PackageId eq iPack
                   and utd.EDocType  eq objSrv:Env:Utd:EDocType:edoc:KeyIntDB
                   and utd.Timestamp ge iTimestamp
   no-lock no-error.
   if available utd
   then
      return "Есть документ позже".
   find last utd where utd.PackageId eq iPack
                   and utd.EDocType  eq objSrv:Env:Utd:EDocType:ucd:KeyIntDB
                   and utd.Timestamp le iTimestamp
   no-lock no-error.
   if not available utd
   then
      return "Не найден УКД".
   define variable vdb-numOrig as integer no-undo.
   define variable vdoc-idOrig as integer no-undo.
   find last utd where utd.PackageId eq iPack
                   and utd.EDocType  eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
                   and utd.Timestamp le iTimestamp
   no-lock no-error.
   if available utd
   then do:
      subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
      MySeqUtd = ?.
      vTimestamp = utd.Timestamp.
      create edoc.
      vdb-num = utd.db-num.
      vdoc-id = utd.doc-id.
      buffer-copy utd except doc-id db-num DocumentExt OrganizationExt comment to edoc
      assign
         edoc.EDocType = objSrv:Env:Utd:EDocType:edoc:KeyIntDB
         edoc.Timestamp = iTimestamp + 1
         edoc.AmendmentRequested = no
         edoc.sts-edi  = objSrv:Env:Utd:sts:edi:WaitingForRecipientSignature:KeyIntDB
      .
      validate edoc.
      for each utd-attr where utd-attr.db-num eq vdb-num
                          and utd-attr.doc-id eq vdoc-id
                          and utd-attr.attr-code ne "ststhbeforeCorrection"
                          and utd-attr.attr-code ne "sendcode"
      no-lock:
         create edoc-attr.
         buffer-copy utd-attr except doc-id db-num to edoc-attr
         assign
            edoc-attr.db-num = edoc.db-num
            edoc-attr.doc-id = edoc.doc-id
         .
      end.
      for each utd-lines where utd-lines.db-num eq vdb-num
                           and utd-lines.doc-id eq vdoc-id
      no-lock:
         create edoc-lines.
         buffer-copy utd-lines except doc-id db-num to edoc-lines
         assign
            edoc-lines.db-num = edoc.db-num
            edoc-lines.doc-id = edoc.doc-id
         .
         release edoc-lines.
      end.
      for each utd-lines-attr where utd-lines-attr.db-num eq vdb-num
                                and utd-lines-attr.doc-id eq vdoc-id
      no-lock:
         create edoc-lines-attr.
         buffer-copy utd-lines-attr except doc-id db-num to edoc-lines-attr
         assign
            edoc-lines-attr.db-num = edoc.db-num
            edoc-lines-attr.doc-id = edoc.doc-id
         .
      end.
      for each utd-marking-lines where utd-marking-lines.db-num eq vdb-num
                                   and utd-marking-lines.doc-id eq vdoc-id
                                   and utd-marking-lines.doc-level eq 1
      no-lock:
         create edoc-marking-lines.
         buffer-copy utd-marking-lines except doc-id db-num to edoc-marking-lines
         assign
            edoc-marking-lines.db-num = edoc.db-num
            edoc-marking-lines.doc-id = edoc.doc-id
         .
      end.
      for each utd-marking-lines-attr where utd-marking-lines-attr.db-num eq vdb-num
                                        and utd-marking-lines-attr.doc-id eq vdoc-id
      no-lock:
         if utd-marking-lines-attr.attr-code eq "box-qnty"
         then do:
             find first edoc-marking-lines-attr  where edoc-marking-lines-attr.db-num    eq utd-marking-lines-attr.db-num
                                                   and edoc-marking-lines-attr.doc-id    eq utd-marking-lines-attr.doc-id
                                                   and edoc-marking-lines-attr.LineNum   eq utd-marking-lines-attr.LineNum
                                                   and edoc-marking-lines-attr.mark      eq utd-marking-lines-attr.mark
                                                   and edoc-marking-lines-attr.attr-code eq utd-marking-lines-attr.attr-code
             no-lock no-error.
         end.
         if not avail edoc-marking-lines-attr
         then do:
             create edoc-marking-lines-attr.
             buffer-copy utd-marking-lines-attr except doc-id db-num to edoc-marking-lines-attr
             assign
                edoc-marking-lines-attr.db-num = vdb-num
                edoc-marking-lines-attr.doc-id = vdoc-id
             .
         end.
         release edoc-marking-lines-attr.
      end.
      for each utd where utd.PackageId eq iPack
                     and utd.EDocType  eq objSrv:Env:Utd:EDocType:Ucd:KeyIntDB
                     and utd.Timestamp gt vTimestamp
                     and utd.Timestamp le iTimestamp
                     and (    utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:WaitingForRecipientSignature:KeyIntDB
                          or  utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:sendRecipient:KeyIntDB
                          or  utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:WithRecipientSignature:KeyIntDB
                          or  utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:WithRecipientPartiallySignature:KeyIntDB
                          or  utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:HaveToCreateReceipt:KeyIntDB
                          or  utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:Verification:KeyIntDB)
      no-lock by utd.PackageId by utd.EDocType by utd.Timestamp:
         edoc.Total = edoc.Total + utd.total.
         edoc.Vat = edoc.Vat + utd.Vat.
         edoc.DocumentDate = utd.DocumentDate.
         edoc.Timestamp = utd.Timestamp + 1.
         for each utd-lines where utd-lines.db-num     = utd.db-num
                              and utd-lines.doc-id     = utd.doc-id
         no-lock:
            block-mark:
            for each utd-marking-lines where utd-marking-lines.db-num eq utd-lines.db-num
                                         and utd-marking-lines.doc-id eq utd-lines.doc-id
                                         and utd-marking-lines.LineNum eq utd-lines.LineNum
                                         and utd-marking-lines.site eq "-"
                                         no-lock:
               if isOAD(utd-marking-lines.mark)
               then do:
                  define variable VOAD as character no-undo.
                  VOAD = "02" + getGtinByDM(utd-marking-lines.mark) + "37".
                  find first edoc-marking-lines where edoc-marking-lines.db-num eq edoc.db-num
                                               and edoc-marking-lines.doc-id eq edoc.doc-id
                                               and edoc-marking-lines.mark   begins VOAD
                  no-lock no-error.
               end.
               else
                  find first edoc-marking-lines where edoc-marking-lines.db-num eq edoc.db-num
                                                  and edoc-marking-lines.doc-id eq edoc.doc-id
                                                  and edoc-marking-lines.mark   eq utd-marking-lines.mark
                     no-lock no-error.
               if available edoc-marking-lines
               then do:
                  find first edoc-lines where edoc-lines.db-num      = edoc-marking-lines.db-num
                                    and edoc-lines.doc-id            = edoc-marking-lines.doc-id
                                    and edoc-lines.LineNum           = edoc-marking-lines.LineNum
                  exclusive-lock no-error.
                  leave block-mark.
               end.
            end.
            if not available edoc-lines
            then
               find first edoc-lines where edoc-lines.db-num      = edoc.db-num
                                       and edoc-lines.doc-id      = edoc.doc-id
                                       and edoc-lines.ProductCode = utd-lines.ProductCode
               exclusive-lock no-error.
            if not available edoc-lines
            then do:
               find last edoc-lines where edoc-lines.db-num      = edoc.db-num
                                      and edoc-lines.doc-id      = edoc.doc-id
               no-lock no-error.
               define variable vline as integer no-undo.
               vline = if available edoc-lines then edoc-lines.linenum + 1 else 1.
               create edoc-lines.
               buffer-copy utd-lines except doc-id db-num linenum to edoc-lines
               assign
                  edoc-lines.db-num = edoc.db-num
                  edoc-lines.doc-id = edoc.doc-id
                  edoc-lines.linenum = vline
               .
            end.
            else
               assign
                  edoc-lines.Vat       = dec(getattrUtdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"Vat_old") )       + utd-lines.Vat
                  edoc-lines.Total     = dec(getattrUtdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"Total_old") )     + utd-lines.Total
                  edoc-lines.Quantity  = dec(getattrUtdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"Quantity_old_new") )  + utd-lines.Quantity.
                  edoc-lines.TotalWithVatExcluded = edoc-lines.Total - edoc-lines.Vat.
               .
            define variable Vqnty as decimal no-undo.
            Vqnty = dec(getattrUtdlines(edoc-lines.db-num,edoc-lines.doc-id,edoc-lines.LineNum,"Quantity") )
                  + dec(getattrUtdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"Quantity") ).
            setattrUtdlines(edoc-lines.db-num,edoc-lines.doc-id,edoc-lines.LineNum,"Quantity",string(vqnty)).
            if     getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old") ne ?
               and edoc-lines.UnitCode ne getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old")
            then
               AddUtdErr(edoc.db-num,edoc.doc-id,buffer edoc-lines:handle,
                   "loadUtd",
                   "UcdUnitChangForUtd",
                   string(edoc-lines.LineNum )                  + chr(4) +
                   edoc-lines.UnitCode                   + chr(4) +
                   getattrutdlinesex(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old","?")).
            if     utd-lines.UnitCode ne ?
               and utd-lines.UnitCode ne ""
               and utd-lines.UnitCode ne getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old")
            then
               AddUtdErr(edoc.db-num,edoc.doc-id,buffer edoc-lines:handle,
                      "loadUtd",
                      "UcdUnitChang",
                      string(edoc-lines.LineNum )                  + chr(4) +
                      utd-lines.UnitCode                          + chr(4) +
                      getattrutdlinesex(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old","?")).
            for each utd-marking-lines where utd-marking-lines.db-num eq utd-lines.db-num
                                         and utd-marking-lines.doc-id eq utd-lines.doc-id
                                         and utd-marking-lines.LineNum eq utd-lines.LineNum
            no-lock by utd-marking-lines.site by utd-marking-lines.doc-level desc:
               if utd-marking-lines.site eq "-"
               then do:
                  if isOAD(utd-marking-lines.mark)
                  then do:
                     VOAD = "02" + getGtinByDM(utd-marking-lines.mark) + "37".
                     find first edoc-marking-lines where edoc-marking-lines.db-num eq edoc-lines.db-num
                                                     and edoc-marking-lines.doc-id eq edoc-lines.doc-id
                                                     and edoc-marking-lines.mark   eq utd-marking-lines.mark
                     exclusive-lock no-error.
                     if not available edoc-marking-lines
                     then
                        find first edoc-marking-lines where edoc-marking-lines.db-num eq edoc.db-num
                                                     and edoc-marking-lines.doc-id eq edoc.doc-id
                                                     and edoc-marking-lines.mark   begins VOAD
                        exclusive-lock no-error.
                     if not available edoc-marking-lines
                     then
                        AddUtdErr(edoc.db-num,edoc.doc-id,buffer edoc-lines:handle,"edoc","Mark" + utd-marking-lines.site,utd-marking-lines.mark).
                     else do:
                        define variable v37tegdoc as character no-undo.
                        define variable v37tegedoc as character no-undo.
                        v37tegdoc  = GetTegCod( utd-marking-lines.mark,"37").
                        v37tegedoc = GetTegCod(edoc-marking-lines.mark,"37").
                        vqnty = int(v37tegedoc) - int(v37tegdoc) no-error.
                        if error-status:error
                        then
                           message "беда с маркой" skip edoc-marking-lines.mark skip utd-marking-lines.mark
                           view-as alert-box.
                        else if vqnty = 0
                        then
                           delete edoc-marking-lines.
                        else do:
                           edoc-marking-lines.mark  = VOAD + string(vqnty).
                           setAttrUtdMarkingLines (edoc-marking-lines.db-num,
                                          edoc-marking-lines.doc-id,
                                          edoc-marking-lines.LineNum,
                                          edoc-marking-lines.mark,
                                          "box-qnty",
                                           string(vQnty)).
                        end.
                     end.
                  end.
                  else do:
                     find first edoc-marking-lines where edoc-marking-lines.db-num eq edoc-lines.db-num
                                                     and edoc-marking-lines.doc-id eq edoc-lines.doc-id
                                                     and edoc-marking-lines.mark   eq utd-marking-lines.mark
                     exclusive-lock no-error.
                     if available edoc-marking-lines
                     then
                        delete edoc-marking-lines.
                     else
                        AddUtdErr(edoc.db-num,edoc.doc-id,buffer edoc-lines:handle,"edoc","Mark" + utd-marking-lines.site,utd-marking-lines.mark).
                  end.
               end.
               else if utd-marking-lines.site eq "+"
               then do:
                  if isOAD(utd-marking-lines.mark)
                  then do:
                     VOAD = "02" + getGtinByDM(utd-marking-lines.mark) + "37".
                     find first edoc-marking-lines where edoc-marking-lines.db-num eq edoc.db-num
                                                  and edoc-marking-lines.doc-id eq edoc.doc-id
                                                  and edoc-marking-lines.mark   begins VOAD
                     exclusive-lock no-error.
                     if available edoc-marking-lines
                     then do:
                        v37tegdoc  = GetTegCod( utd-marking-lines.mark,"37").
                        v37tegedoc = GetTegCod(edoc-marking-lines.mark,"37").
                        vqnty = int(v37tegedoc) + int(v37tegdoc) no-error.
                        if error-status:error
                        then
                           message "беда с маркой" skip edoc-marking-lines.mark skip utd-marking-lines.mark
                           view-as alert-box.
                        else if vqnty = 0
                        then
                           delete edoc-marking-lines.
                        else do:
                           edoc-marking-lines.mark  = VOAD + string(vqnty).
                           setAttrUtdMarkingLines (edoc-marking-lines.db-num,
                                          edoc-marking-lines.doc-id,
                                          edoc-marking-lines.LineNum,
                                          edoc-marking-lines.mark,
                                          "box-qnty",
                                           string(vQnty)).
                        end.
                     end.
                     else do:
                        create edoc-marking-lines.
                        buffer-copy utd-marking-lines except doc-id db-num to edoc-marking-lines
                        assign
                           edoc-marking-lines.db-num = edoc.db-num
                           edoc-marking-lines.doc-id = edoc.doc-id
                        .
                        setAttrUtdMarkingLines (edoc-marking-lines.db-num,
                                          edoc-marking-lines.doc-id,
                                          edoc-marking-lines.LineNum,
                                          edoc-marking-lines.mark,
                                          "box-qnty",
                                           string(int(GetTegCod(edoc-marking-lines.mark,"37")))) no-error.
                     end.
                  end.
                  else do:
                  find first edoc-marking-lines where edoc-marking-lines.db-num eq edoc-lines.db-num
                                                  and edoc-marking-lines.doc-id eq edoc-lines.doc-id
                                                  and edoc-marking-lines.mark   eq utd-marking-lines.mark
                  no-lock no-error.
                  if not available edoc-marking-lines
                  then do:
                     create edoc-marking-lines.
                     buffer-copy utd-marking-lines except doc-id db-num linenum to edoc-marking-lines
                     assign
                        edoc-marking-lines.db-num  = edoc-lines.db-num
                        edoc-marking-lines.doc-id  = edoc-lines.doc-id
                        edoc-marking-lines.linenum = edoc-lines.linenum
                     .
                  end.
                  else
                     AddUtdErr(edoc.db-num,edoc.doc-id,buffer edoc-lines:handle,"Edoc","Mark" + utd-marking-lines.site,utd-marking-lines.mark).
               end.
            end.
            release edoc-lines.
         end.
         release edoc-lines.
      end.
      find first utd_ret where utd_ret.parentDocumentExt     eq utd.parentDocumentExt
                              and utd_ret.parentOrganizationExt eq utd.parentOrganizationExt
                              and utd_ret.Timestamp             le utd.Timestamp
                              and utd_ret.EDocType              eq objSrv:Env:Utd:EDocType:returns:KeyIntDB
         no-lock no-error.
      if not avail utd_ret
      then
         CheckEdoc (vdb-num,vdoc-id,edoc.db-num,edoc.doc-id) .
   end.
   for each utd where utd.PackageId eq iPack
                     and utd.EDocType  eq objSrv:Env:Utd:EDocType:edoc:KeyIntDB
                     and utd.Timestamp < iTimestamp
      exclusive-lock:
         utd.sts-edi = objSrv:Env:Utd:sts:edi:Changed:KeyIntDB.
         utd.sts     = objSrv:Env:Utd:sts:th:Rejection:KeyIntDB.
      end.
      unsubscribe "getNextseq".
   end.
end.
define variable Mext-sys as integer no-undo init ?.
define variable mdb-num-local as integer no-undo.
run gbl/getdbnum.p (output mdb-num-local).
function  getExtSys returns integer
():
   define buffer ext-system      for ext-system.
   define buffer ext-system-attr for ext-system-attr.
   Mext-sys = ?.
   block-sys-obj:
   for each ext-system where ext-system.esys-type eq 12
                         and ext-system.db-num    eq mdb-num-local
   no-lock:
       find first ext-system-attr where ext-system-attr.db-num  eq ext-system.db-num
                                    and ext-system-attr.esys-id eq ext-system.esys-id
                                    and ext-system-attr.esya-attr-code eq 'obj':U
       no-lock no-error.
       if     available ext-system-attr
          and           ext-system-attr.esya-attr-value eq v-cntxt-obj-type + string(v-cntxt-obj-code)
       then do:
          Mext-sys = ext-system-attr.esys-id.
          leave block-sys-obj.
       end.
   end.
   if Mext-sys eq ?
   then do:
      block-sys-host:
      for each ext-system where ext-system.esys-type eq 12
                            and ext-system.db-num    eq mdb-num-local
      no-lock:
          find first ext-system-attr where ext-system-attr.db-num  eq ext-system.db-num
                                       and ext-system-attr.esys-id eq ext-system.esys-id
                                       and ext-system-attr.esya-attr-code eq 'host-code':U
          no-lock no-error.
          if     available ext-system-attr
             and           ext-system-attr.esya-attr-value eq string(v-cntxt-host-code-obj)
          then do:
             Mext-sys = ext-system-attr.esys-id.
             leave block-sys-host.
          end.
      end.
   end.
   return Mext-sys.
end.
function  getExtAttr returns character
(input icode as character ):
   define variable oValue as character no-undo.
   define variable vtype as character no-undo.
   define buffer ext-system for ext-system.
   get-key-value section "ProxyServ" key icode value oValue.
   if oValue eq ?
   then do:
      if Mext-sys eq ?
      then
         getExtSys ().
      find first ext-system no-lock where ext-system.db-num  eq mdb-num-local
                                      and ext-system.esys-id eq Mext-sys no-error.
      if available ext-system
      then do:
             if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-value in g#attr-lib
         (ext-system.esys-id,
          mdb-num-local,
          icode,
          output oValue,
          output vtype) no-error.
       end.
   end.
   return if oValue eq ? then "" else oValue .
end.
function  SetExtAttr returns character
(input icode   as character,
 input iValue  as character):
   define variable vtype as character no-undo.
   define buffer ext-system for ext-system.
   if Mext-sys eq ?
   then
      getExtSys ().
   find first ext-system no-lock where ext-system.db-num  eq mdb-num-local
                                   and ext-system.esys-id eq Mext-sys no-error.
   if available ext-system
   then do:
       if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-write in g#attr-lib
      (ext-system.esys-id,
       mdb-num-local,
       icode,
       iValue) no-error.
    end.
end.
define stream File-stream.
function PutMes returns character
(idext as character ):
   if valid-handle(mPublishHand)
   then
      publish "WriteLogAsunc" from mPublishHand (idext,yes).
   else do:
      if idext begins "error"
      then do:
         message substring (idext,6)
            view-as alert-box.
         if mDiadocApi ne ?
         then
            idext = substitute ("&1 (&2)",idext , mDiadocApi:GetFullVersion())no-error.
      end.
      output stream File-stream to "diadoc_user.log" append.
      put stream File-stream unformatted now " " idext skip.
      output stream File-stream close.
   end.
end.
function PutErr returns character
(idext as character ):
   define variable vi as integer no-undo.
   define variable vnumerr as integer no-undo.
   define variable vtext as character extent 25 no-undo .
   if error-status:num-messages > 0 then do:
      vnumerr = error-status:num-messages.
      vnumerr = min(vnumerr,extent(vtext)).
      do vi = 1 to vnumerr:
         vtext[vi] = error-status:get-message(vi).
      end.
      idext = idext + chr(10) + "Ошибка: [":U.
      do vi = 1 to vnumerr:
         idext = idext + chr(10) + vtext[vi] no-error.
      end.
      idext = idext +  chr(10) +  " ]" no-error.
      if not  idext begins "Error"
      then
         idext = "Error " + idext.
      PutMes(idext).
   end.
end.
function PutStat returns character
(itext as character,
 iflag as logical):
   if valid-handle(mPublishHand)
   then
      publish "PutStatAsunc" from mPublishHand (itext,iflag).
   PutMes(itext).
end.
function chekStop returns logical
( ):
   define variable oStop as logical no-undo.
   if valid-handle(mPublishHand)
   then
      publish "StopProc" from mPublishHand (output oStop).
   return oStop.
end.
function  putloggetdesc returns logical
(is1 as character ,is2 as character ,
is3 as character ):
end.
function  getdesc returns logical
(input iObj as component-handle):
   if iObj eq ? then return false.
   if mdebug
   then do:
   output stream File-stream to "diadoc_load.txt" append.
   define variable vReflector as component-handle no-undo.
   define variable vDescobj  as component-handle no-undo.
   define variable vPropertyNames  as component-handle no-undo.
   define variable vMethodsNames as component-handle no-undo.
   define variable vMethodDesc as component-handle no-undo.
   define variable vMethodsName as character  no-undo.
   define variable vPropertyValue as char no-undo.
   create "Diadoc.Reflector" vReflector.
   vDescobj = vReflector:Describe(iObj).
  put   stream File-stream  unformatted skip (1)
   "------------------------------------------" skip
   vDescobj:GetInterfaceName() skip.
   define variable vPropertyName as character no-undo.
   define variable vPropertyType as character no-undo.
   .
   putloggetdesc(vDescobj:GetInterfaceName(),"","").
   putloggetdesc("property","","").
   define variable vi as integer no-undo.
   define variable vii as integer no-undo.
  put stream File-stream  unformatted skip "property" skip.
  vPropertyNames = vDescobj:GetPropertiesNames().
   vi= vPropertyNames:count.
   do vi= 1 to vPropertyNames:count :
      vPropertyName = "".
      vPropertyType = "".
      vPropertyValue = "".
      vPropertyName  = vPropertyNames:GetItem(vi - 1) no-error.
      vPropertyType  = vDescobj:GetPropertyType(vPropertyName) no-error .
      vPropertyValue = substring((vDescobj:GetProperty(vPropertyName)),1,4000) no-error.
      putloggetdesc(vPropertyName,vPropertyType,vPropertyValue).
     put stream File-stream  unformatted vPropertyName " " vPropertyType  " " vPropertyValue skip.
   end.
   release object vPropertyNames.
   put stream File-stream  unformatted skip "method" skip.
   vMethodsNames = vDescobj:GetMethodsNames().
   vi = vMethodsNames:count.
   do vi = 1 to vMethodsNames:count :
      vMethodsName = "".
      vMethodsName = vMethodsNames:GetItem(vi - 1)no-error.
      vMethodDesc  = vDescobj:GetMethodDesc(vMethodsName)no-error.
      putloggetdesc("method",vMethodsName, vMethodDesc:RetVal).
      put stream File-stream  unformatted vMethodsName  " retval " vMethodDesc:RetVal skip.
      do vii  = 1 to vMethodDesc:args:count:
         define variable varg as character no-undo.
         varg = "".
         varg = vMethodDesc:args:GetItem(vii - 1) no-error.
         put stream File-stream  unformatted " args " varg  skip .
         putloggetdesc(" args ",varg, "").
      end.
      release object vMethodDesc.
   end.
   release object vMethodsNames.
   put stream File-stream  unformatted "end---------------------------------------" skip.
   output stream File-stream close.
   release object vDescobj.
   release object vReflector.
   end.
   return true.
end.
function getxsddocum returns logical
(iOrganization as component-handle):
   if iOrganization eq ? then return false.
   define variable vDocumentTypes as component-handle no-undo.
   define variable vDocumentType as component-handle no-undo.
   define variable vFunctions as component-handle no-undo.
   define variable vFunction as component-handle no-undo.
   define variable vVersions as component-handle no-undo.
   define variable vVersion as component-handle no-undo.
   define variable vTitles as component-handle no-undo.
   define variable vTitle as component-handle no-undo.
   define variable vi as integer no-undo.
   define variable vii as integer no-undo.
   define variable viii as integer no-undo.
   define variable viiii as integer no-undo.
   if mdebug
   then do:
   output stream File-stream to "diadoc_doc.txt" append.
   vDocumentTypes = iOrganization:GetDocumentTypes().
   do vi =1 to vDocumentTypes:count:
      vDocumentType = vDocumentTypes:GetItem(vi - 1).
      put stream File-stream  unformatted "DocumentType -> NAme " vDocumentType:name skip.
      put stream File-stream  unformatted "DocumentType -> Title " vDocumentType:Title skip.
      vFunctions = vDocumentType:Functions.
      do vii =1 to vFunctions:count:
         vFunction = vFunctions:GetItem(vii - 1 ).
         put stream File-stream  unformatted "DocumentType -> Function -> NAme " vFunction:name skip.
         vVersions = vFunction:Versions.
         do viii =1 to vVersions:count:
            vVersion = vVersions:GetItem(viii - 1 ).
            put stream File-stream  unformatted "DocumentType -> Function -> Version -> version " vVersion:version skip.
            put stream File-stream  unformatted "DocumentType -> Function -> Version -> IsActual " vVersion:IsActual skip.
            vTitles  = vVersion:Titles.
            do viiii =1 to vTitles:count:
               vTitle = vTitles:GetItem(viiii - 1 ).
               put stream File-stream  unformatted "DocumentType -> Function -> Version -> Title -> IsFormal " vTitle:IsFormal skip.
               put stream File-stream  unformatted "DocumentType -> Function -> Version -> Title -> XsdUrl " vTitle:XsdUrl skip.
               put stream File-stream  unformatted "DocumentType -> Function -> Version -> Title -> HaveUserDataXSD " vTitle:HaveUserDataXSD skip.
               put stream File-stream  unformatted "DocumentType -> Function -> Version -> Title -> type " vTitle:type skip.
               release object vTitle.
            end.
           release object vTitles.
            release object vVersion.
         end.
         release object vVersions.
         release object vFunction.
      end.
      release object vFunctions.
      release object vDocumentType.
   end.
   release object vDocumentTypes.
   put stream File-stream  unformatted "--------------------------------------------------- " skip.
  output stream File-stream close.
  end.
   return true.
end.
function GetDocTitleType returns character
(iOrganizationGuid as character ,
itype as character ,
ifunction as character,
iversion as character
):
   if iOrganizationGuid eq ? then return "".
   define variable vOrganization  as component-handle no-undo.
   define variable vDocumentTypes as component-handle no-undo.
   define variable vDocumentType  as component-handle no-undo.
   define variable vFunctions     as component-handle no-undo.
   define variable vFunction      as component-handle no-undo.
   define variable vVersions      as component-handle no-undo.
   define variable vVersion       as component-handle no-undo.
   define variable vTitles        as component-handle no-undo.
   define variable vTitle         as component-handle no-undo.
   define variable vi             as integer no-undo.
   define variable vii            as integer no-undo.
   define variable viii           as integer no-undo.
   define variable viiii          as integer no-undo.
   define variable oTitleType as character no-undo.
   vOrganization = mDiadocConnection:GetOrganizationById(iOrganizationGuid) no-error.
   if vOrganization eq ? then return "".
   vDocumentTypes = vOrganization:GetDocumentTypes().
   do vi =1 to vDocumentTypes:count:
      vDocumentType = vDocumentTypes:GetItem(vi - 1).
      if vDocumentType:name eq iType
      then do:
         vFunctions = vDocumentType:Functions.
         do vii =1 to vFunctions:count:
            vFunction = vFunctions:GetItem(vii - 1 ).
            if vFunction:name eq ifunction
            then do:
               vVersions = vFunction:Versions.
               do viii =1 to vVersions:count:
                  vVersion = vVersions:GetItem(viii - 1 ).
                  if vVersion:version eq iversion
                  then do:
                     vTitles  = vVersion:Titles.
                     do viiii =1 to vTitles:count:
                        vTitle = vTitles:GetItem(viiii - 1 ).
                        oTitleType = oTitleType + "," + vTitle:type.
                        release object vTitle.
                     end.
                     release object vTitles.
                  end.
                  release object vVersion.
               end.
               release object vVersions.
            end.
            release object vFunction.
         end.
         release object vFunctions.
      end.
      release object vDocumentType.
   end.
   release object vDocumentTypes.
   release object vOrganization.
   return left-trim(oTitleType,",").
end.
define temp-table tt-type no-undo
          field id as char
          field name as character
          index pi id .
define temp-table tt-Class no-undo like tt-type.
function crcode returns character
():
   define variable vtypelist as character no-undo.
   define variable vtypename as character no-undo.
   define variable vi as integer no-undo.
   vtypelist =
              "UniversalTransferDocument|"
             + "UniversalTransferDocumentRevision|"
             + "UniversalCorrectionDocument|"
             + "UniversalCorrectionDocumentRevision"
             .
   vtypename =
              "УПД|"
             + "Исправление УПД|"
             + "УКД|"
             + "Исправление УКД"
             .
   do vi = 1 to num-entries(vtypelist,"|"):
      create tt-type.
      assign
         tt-type.id   =  entry(vi,vtypelist,"|")
         tt-type.name =  entry(vi,vtypename,"|")
      .
   end.
   vtypelist = "Inbound|"
             + "Outbound|"
             + "Proxy".
   vtypename = "входящий документ|"
             + "исходящий документ|"
             + "документ, переданный через промежуточного получателя|".
   do vi = 1 to num-entries(vtypelist,"|"):
      create tt-Class.
      assign
         tt-Class.id   =  entry(vi,vtypelist,"|")
         tt-Class.name =  entry(vi,vtypename,"|")
      .
   end.
end.
crcode().
function getOrganizationInfo returns character
(input iContAgent as component-handle,
                                                output oinn as character,
                                                output oKpp as character,
                                                output oFnsParticipantId as character,
                                                output oOrgName as character,
                                                output oAdditionalInfo as character,
                                                output OarddrRus as character
                                                 ):
   define variable vi as integer no-undo.
   define variable vContAgentOrganizationDetails   as component-handle no-undo.
   define variable vAddrRus                        as component-handle no-undo.
   if iContAgent ne ?
   then do:
      getdesc(iContAgent).
      vContAgentOrganizationDetails = iContAgent:OrganizationDetails.
      oinn = vContAgentOrganizationDetails:Inn.
      oKpp = vContAgentOrganizationDetails:Kpp.
      oFnsParticipantId = vContAgentOrganizationDetails:FnsParticipantId.
      oAdditionalInfo = vContAgentOrganizationDetails:OrganizationAdditionalInfo.
      getdesc(vContAgentOrganizationDetails).
      oOrgName = vContAgentOrganizationDetails:OrgName.
      getdesc(vContAgentOrganizationDetails:Address).
      vAddrRus = vContAgentOrganizationDetails:Address:RussianAddress.
      getdesc(vAddrRus ).
      if vAddrRus ne ?
      then do:
         if vAddrRus:ZipCode ne ""
         then
            OarddrRus = OarddrRus + " " + vAddrRus:ZipCode.
         if vAddrRus:Region ne ""
         then
            OarddrRus = OarddrRus + " Регион: " + vAddrRus:Region.
         if vAddrRus:Territory ne ""
         then
            OarddrRus = OarddrRus + " Область: " + vAddrRus:Territory.
         if vAddrRus:City ne ""
         then
            OarddrRus = OarddrRus + " Город: " + vAddrRus:City.
         if vAddrRus:Locality ne ""
         then
            OarddrRus = OarddrRus + " Район: " + vAddrRus:Locality.
         if vAddrRus:Street ne ""
         then
            OarddrRus = OarddrRus + " Улица: " + vAddrRus:Street.
         if vAddrRus:Block ne ""
         then
            OarddrRus = OarddrRus + " Стр: " + vAddrRus:Block.
         if vAddrRus:Building ne ""
         then
            OarddrRus = OarddrRus + " Дом: " + vAddrRus:Building.
         if vAddrRus:Apartment ne ""
         then
            OarddrRus = OarddrRus + " Квартира: " + vAddrRus:Apartment.
      end.
      release object vAddrRus.
      release object vContAgentOrganizationDetails.
   end.
end.
function ConectByCertif return component-handle
(iThumbprint as character ):
  if mDiadocApi eq ? then return ?.
  if iThumbprint eq ""
  then do:
     release object mDiadocConnection no-error.
     return ?.
  end.
   mDiadocApi:ApiClientId =  getextAttr('diadoc-key':U).
   mDiadocApi:ServerUrl   =  getextAttr('server-addr':U).
   define variable vSSl as character no-undo.
   vSSl =  getextAttr('diadoc-ssl':U).
   if vSSl ne ""
      and logical(vSSl)
   then
      mDiadocApi:VerifySslCertificate = no.
   if mDiadocApi:ApiClientId eq ""
      or  mDiadocApi:ServerUrl eq ""
   then do:
     message "Не задан адрес сервера или ключ разработчика для внешей системы Диадок"
     view-as alert-box.
     release object mDiadocConnection no-error.
     return ?.
  end.
  define variable VProxy as character no-undo.
   vProxy =  getextAttr('proxy-addr':U).
   if     vProxy ne ""
      and vProxy ne ?
   then do:
      mDiadocApi:ProxyMode =  "UseProxy".
      mDiadocApi:ProxySettings:Url = vProxy.
      mDiadocApi:ProxySettings:Login    = getextAttr('proxy-login':U).
      mDiadocApi:ProxySettings:Password = getextAttr('proxy-pswd':U).
   end.
   define variable vtest as component-handle no-undo.
   vtest = mDiadocApi:TestConnection2().
   if not vtest:ConnectionSuccess
   then do:
      PutMes(vtest:ErrorText).
   end.
   else
      mDiadocConnection = mDiadocApi:CreateConnectionByCertificate(iThumbprint,"") no-error.
   if mDiadocConnection eq ?
   then
      PutErr("DiadocApi:CreateConnectionByCertificate:").
   release object vtest.
   return mDiadocConnection.
end.
function ConectByLogin return component-handle
():
   define variable vSSl as character no-undo.
   if mDiadocApi eq ? then return ?.
   mDiadocApi:ApiClientId = getextAttr('diadoc-key':U).
   mDiadocApi:ServerUrl   = getextAttr('server-addr':U).
   if mDiadocApi:ApiClientId eq ""
      or  mDiadocApi:ServerUrl eq ""
   then do:
     PutMes( "Error Не задан адрес сервера или ключ разработчика для внешей системы Диадок").
     release object mDiadocConnection no-error.
     return ?.
  end.
  vSSl =  getextAttr('diadoc-ssl':U).
  if vSSl ne ""
     and logical(vSSl)
  then
      mDiadocApi:VerifySslCertificate = no.
  define variable VProxy as character no-undo.
   vProxy =  getextAttr('proxy-addr':U).
   if     vProxy ne ""
      and vProxy ne ?
   then do:
      mDiadocApi:ProxyMode =  "UseProxy".
      mDiadocApi:ProxySettings:Url = vProxy.
      mDiadocApi:ProxySettings:Login    = getextAttr('proxy-login':U).
      mDiadocApi:ProxySettings:Password = getextAttr('proxy-pswd':U).
   end.
   mDiadocConnection = mDiadocAPI:CreateConnectionByLogin(getextAttr('diadoc-user':U),getextAttr('diadoc-pwd':U)) no-error.
   define variable vi as integer no-undo.
   if mDiadocConnection eq ?
   then
      PutErr("DiadocAPI:CreateConnectionByLogin").
   return mDiadocConnection.
end.
function GetDocumforid returns character
(input  iorg as character ,
 input  idoc-id as character ,
 output oDocument      as component-handle
  ):
   define variable vOrganization  as component-handle no-undo.
   define variable vDocument      as component-handle no-undo.
   define buffer utd           for ub.utd.
   if
          iorg  ne ?
      and iorg  ne ""
      and idoc-id ne ?
      and idoc-id ne ""
   then do:
      vOrganization = mDiadocConnection:GetOrganizationById(iorg) no-error.
      if vOrganization ne ?
      then do:
         oDocument = vOrganization:GetDocumentById(idoc-id,false) no-error.
         if oDocument eq ?
         then
            PutErr(substitute("Error Нет доступа к документу &2 по организации &1. ", iorg,idoc-id)).
      end.
      else do:
         PutErr(substitute("Error Нет доступа к организации &1 по документу &2. ", iorg,idoc-id)).
         return "Нет доступа к организации " + iorg.
      end.
   end.
   else
      return "Нет доступа к организации не ЭДО".
   release object vOrganization no-error.
   return "".
end.
function GetDocum returns character
(input  idb-num as integer,
 input  idoc-id as integer,
 output oDocument      as component-handle
  ):
   define variable vOrganization  as component-handle no-undo.
   define variable vDocument      as component-handle no-undo.
   define buffer utd           for ub.utd.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if     available utd
      and utd.OrganizationExt ne ?
      and utd.OrganizationExt ne ""
      and utd.DocumentExt ne ?
      and utd.DocumentExt ne ""
   then do:
      vOrganization = mDiadocConnection:GetOrganizationById(utd.OrganizationExt) no-error.
      if vOrganization ne ?
      then do:
         oDocument = vOrganization:GetDocumentById(utd.DocumentExt,false) no-error.
         if oDocument eq ?
         then
            PutErr(substitute("Error Нет доступа к документу &2 по организации &1. ", utd.OrganizationExt,utd.DocumentExt)).
         release object vOrganization no-error.
      end.
      else do:
         PutErr(substitute("Error Нет доступа к организации &1 по документу &2. ", utd.OrganizationExt,utd.DocumentNumber)).
         return "Нет доступа к организации " + utd.OrganizationExt.
      end.
   end.
   else
      return "Нет доступа к организации не ЭДО".
   return "".
end.
function GetFirstUTDinPack returns logical
(input idb-num as integer,
 input idoc-id as integer,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   define buffer     utd for utd.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if utd.PackageId eq ""
      then do:
         assign
            odb-num = utd.db-num
            odoc-id = utd.doc-id
         .
         return yes.
      end.
      else do:
         find first buf_utd where Buf_utd.PackageId eq utd.PackageId
                              and Buf_utd.EDocType  eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
         no-lock.
         assign
            odb-num = buf_utd.db-num
            odoc-id = buf_utd.doc-id
         .
         return if available buf_utd then (recid(utd) eq recid(buf_utd)) else no.
      end.
   end.
   return ?.
end.
function AddOADLine returns integer
(iDb-num  as integer ,
 iDoc-id  as integer ,
 ilinenum as integer ,
 iGtin    as char,
 iQnty    as int,
 isite    as character ):
    define buffer utd-marking-lines      for ub.utd-marking-lines.
    define variable vnewMark as character no-undo.
    define variable vQnty    as integer   no-undo.
    vnewMark = "02" + iGtin + "37" + string(iQnty).
    find first utd-marking-lines where utd-marking-lines.mark       = vnewMark
                                   and utd-marking-lines.db-num     = idb-num
                                   and utd-marking-lines.doc-id     = idoc-id
                                   and utd-marking-lines.Linenum    = iLinenum
    exclusive-lock no-error.
    if available utd-marking-lines
    then do:
       delete utd-marking-lines.
       vQnty = AddOADLine(idb-num, idoc-id, iLinenum, iGtin, iQnty * 2 ,isite ).
    end.
    else do:
       create utd-marking-lines.
       assign
          utd-marking-lines.mark      = vnewMark
          utd-marking-lines.db-num    = idb-num
          utd-marking-lines.doc-id    = idoc-id
          utd-marking-lines.Linenum   = iLinenum
          utd-marking-lines.site      = isite
          utd-marking-lines.doc-level = 1
          utd-marking-lines.gds-code  = ?
       .
       vQnty = iQnty.
    end.
    return vQnty.
 end.
function addMarkforUtd returns recid
(iDb-num  as integer ,
 iDoc-id  as integer ,
 ilinenum as integer ,
 iMark as character  ,
 isite   as character,
 iUtdType as character    ):
    define buffer     marking            for ub.marking.
    define buffer     marking-attr       for ub.marking-attr.
    define buffer utd-marking-lines      for ub.utd-marking-lines.
    define buffer utd-marking-lines-attr for ub.utd-marking-lines-attr.
    define variable vMRC  as decimal no-undo.
    define variable vQnty as decimal no-undo.
   define variable vRec as recid no-undo.
   if     imark ne "-"
      and imark ne ""
      and imark ne ?
   then do:
      imark = repTegforDm(imark).
      vQnty = getQntyUTDByCodId(imark) .
      find first utd-marking-lines where utd-marking-lines.mark       = imark
                                     and utd-marking-lines.db-num     = idb-num
                                     and utd-marking-lines.doc-id     = idoc-id
                                     and utd-marking-lines.Linenum    = iLinenum
      exclusive-lock no-error.
      if not available utd-marking-lines
      then do:
         create utd-marking-lines.
         assign
            utd-marking-lines.mark      = imark
            utd-marking-lines.db-num    = idb-num
            utd-marking-lines.doc-id    = idoc-id
            utd-marking-lines.Linenum   = iLinenum
            utd-marking-lines.site      = isite
            utd-marking-lines.doc-level = 1
            utd-marking-lines.gds-code  = ?
         .
         create utd-marking-lines-attr.
         assign
            utd-marking-lines-attr.mark      = imark
            utd-marking-lines-attr.db-num    = idb-num
            utd-marking-lines-attr.doc-id    = idoc-id
            utd-marking-lines-attr.Linenum   = iLinenum
            utd-marking-lines-attr.attr-code = "box-qnty"
            utd-marking-lines-attr.attr-value = string(vQnty)
         .
         vRec = recid(utd-marking-lines).
         release utd-marking-lines-attr.
         release utd-marking-lines.
      end.
      else do:
         if    (    isite eq "-"
            and utd-marking-lines.site eq "+")
         or (    isite eq "+"
            and utd-marking-lines.site eq "-")
         then
            delete utd-marking-lines.
         else if isOAD (imark)
         then do:
            vQnty = AddOADLine(idb-num, idoc-id, iLinenum, GetTegCod(imark,"02"), int(vQnty) ,isite ).
            create utd-marking-lines-attr.
            assign
               utd-marking-lines-attr.mark      = imark
               utd-marking-lines-attr.db-num    = idb-num
               utd-marking-lines-attr.doc-id    = idoc-id
               utd-marking-lines-attr.Linenum   = iLinenum
               utd-marking-lines-attr.attr-code = "box-qnty"
               utd-marking-lines-attr.attr-value = string(vQnty)
            .
         end.
         vRec = recid(utd-marking-lines).
         release utd-marking-lines.
      end.
      if isMark (imark)
      then do:
         find first marking where marking.mark eq iMark exclusive-lock no-error.
         if not available marking
         then do:
            create marking.
            marking.mark = iMark.
            marking.gds-code = ?.
            marking.unit     = getLevelUTDByCodId(marking.mark) .
         end.
         assign
           marking.unit-ext   = if marking.unit-ext = "" or marking.unit-ext = ? then
                                   getLevelMotpByCodId(marking.mark)
                                else marking.unit-ext
           marking.box-qnty   = vQnty
           marking.unit       = if marking.unit-ext = "LEVEL2" then "КИТУ" else getLevelUTDByCodId(marking.mark)
         .
         if        (     iUtdType eq "UniversalTransferDocument"
                  and marking.sts = objSrv:Env:marking:Sts:Mark:NotAvailable:KeyIntDB)
         then
            marking.sts = ?.
      end.
   end.
   return vRec.
end.
function isSaleMarkInUpak returns logical
(iMark    as char ):
   define buffer buf_marking       for ub.marking.
   for each buf_marking no-lock where
            buf_marking.mark-parent = iMark
   :
     if can-do(objSrv:Env:marking:Sts:Mark:Sale_Return_Wait,string(buf_marking.sts)) or
        can-do(objSrv:Env:marking:Sts:Mark:Doc_Status,string(buf_marking.sts)) then
       return true.
     if isSaleMarkInUpak(buf_marking.mark) then
       return true.
   end.
   return false.
 end.
function setStatusUpak returns logical
(iDbNum   as integer ,
 iDocId   as integer ,
 iLineNum as integer ,
 iMark    as char ,
 iSts     as integer):
   define buffer buf_utd-marking-lines for ub.utd-marking-lines.
   define buffer buf_marking           for ub.marking.
   for each buf_marking exclusive-lock where
            buf_marking.mark-parent = iMark,
      first buf_utd-marking-lines exclusive-lock where
            buf_utd-marking-lines.doc-id  = iDocId
        and buf_utd-marking-lines.db-num  = iDbNum
        and buf_utd-marking-lines.lineNum = iLineNum
        and buf_utd-marking-lines.mark = buf_marking.mark
   :
     setStatusUpak(iDbNum, iDocId, iLineNum, buf_marking.mark, iSts).
   end.
   for first buf_utd-marking-lines exclusive-lock where
             buf_utd-marking-lines.doc-id  = iDocId
         and buf_utd-marking-lines.db-num  = iDbNum
         and buf_utd-marking-lines.lineNum = iLineNum
         and buf_utd-marking-lines.mark = iMark,
       first buf_marking exclusive-lock where
             buf_marking.mark = buf_utd-marking-lines.mark
   :
     if  buf_marking.sts <> objSrv:Env:marking:Sts:Mark:MarkError:KeyIntDB
     then do:
       assign
         buf_utd-marking-lines.sts = iSts
         buf_marking.sts           = iSts
       .
     end.
   end.
   return true.
end.
define temp-table tt-recid no-undo
          field orgid as char
          field docid as char
          field parent as char
          field stamp as datetime
          index pi orgid docid
          index parent parent  stamp.
function ProcessSystemMessStart return component-handle
(IStartStop as logical):
   if mDiadocConnection eq ? then
   define variable vOrganizationList as component-handle no-undo.
   define variable vOrganization as component-handle no-undo.
   define variable vReceiptGenerationProcess as component-handle no-undo.
   define variable vi as integer no-undo.
   if mDiadocConnection ne ?
   then do:
      vOrganizationList = mDiadocConnection:GetOrganizationList().
       do vi = 1 to vOrganizationList:count:
          vOrganization = vOrganizationList:GetItem(vi - 1 ).
          vReceiptGenerationProcess = vOrganization:GetReceiptGenerationProcess().
          release object vOrganization.
          if IStartStop
          then
             vReceiptGenerationProcess:Start().
          else
             vReceiptGenerationProcess:Stop().
          release object vReceiptGenerationProcess.
       end.
       release object vOrganizationList.
   end.
end.
procedure  changeIdToGuid :
define input  parameter iOrganization as component-handle no-undo.
   define variable vOrgId   as character no-undo.
   define variable vOrgGuid as character no-undo.
   define buffer utd for utd.
   assign
      vOrgId   = iOrganization:id.
      vOrgGuid = iOrganization:guid
   no-error.
   if     error-status:num-messages eq 0
      and vOrgId   ne ""
      and vOrgGuid ne ""
   then do:
      define variable vfirst as logical no-undo init yes.
      repeat preselect each utd where utd.OrganizationExt = vOrgId exclusive-lock:
         find next utd.
         if vfirst
         then do:
            PutMes("Конвертация документов").
            vfirst = no.
         end.
         utd.OrganizationExt = vOrgGuid.
         validate utd.
         PutMes(substitute ("У документа &1 изменен индификатор организации с &2 на &3",ub.utd.DocumentNumber,vOrgId,utd.OrganizationExt)).
      end.
      if not vfirst
      then
         PutMes("Конвертация документов завершина.").
   end.
end.
procedure getNewUpd :
   define variable VLastDate as date no-undo init ?.
   define variable vDocument     as component-handle no-undo.
   define variable vYear         as integer no-undo.
   define variable vMonth        as integer no-undo.
   define variable vDay          as integer no-undo.
   define variable vBegLoadDate  as date    no-undo.
   define variable vLastLoadDate as date    no-undo.
   define buffer utd for utd.
   VLastDate = date( getextAttr('diadoc-lastload':U)) no-error.
   find first sys-ctrl no-lock.
   if VLastDate eq ?
   then
      VLastDate = sys-ctrl.cut-date + 3.
   else if sys-ctrl.cut-date ne ?
   then
      VLastDate = max(VLastDate,sys-ctrl.cut-date + 3) .
   vLastLoadDate = VLastDate.
   for each tt-recid:
      delete tt-recid.
   end.
   if chekStop() then return "Остановка пользователем".
    run  UpdateUTDInform(if VLastDate eq ? then today - 365 else VLastDate - 3,today + 1,output VLastDate).
   if chekStop() then return "Остановка пользователем".
   if VLastDate ne ?
   then do:
      setextAttr('diadoc-lastload':U,string(VLastDate)).
      vYear = year(vLastLoadDate).
      vMonth = month(vLastLoadDate) - 2.
      vDay   = day(vLastLoadDate).
      if vMonth <= 0 then
         assign
            vMonth = vMonth + 12
            vYear  = vYear - 1
            .
      repeat:
         vBegLoadDate = date(vMonth, vDay, vYear) no-error.
         if error-status:error then
            vDay = vDay - 1.
         else
            leave.
      end.
      vBegLoadDate = vBegLoadDate + 1.
   end.
   block-rec:
   for each tt-recid break by tt-recid.parent descending by tt-recid.stamp descending :
      if  tt-recid.parent eq ""
      then next  block-rec.
      if first-of (tt-recid.parent)
      then do:
         for each utd where utd.PackageId eq tt-recid.parent
         no-lock break by utd.PackageId descending by utd.Timestamp descending :
            if chekStop() then return "Остановка пользователем".
            if utd.EDocType = objSrv:Env:Utd:EDocType:UCD:KeyIntDB
            then do:
               subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
               MySeqUtd = ?.
               CrEdoc(utd.PackageId,utd.Timestamp).
               unsubscribe "getNextseq".
               next block-rec.
            end.
         end.
      end.
   end.
   PutMes("Обновление информации по ранее загруженным документам за период c " + (if vBegLoadDate <> ? then
                                                                                     string(vBegLoadDate)
                                                                                  else "?")
                                                                                  + " по " +
                                                                                  (if vLastLoadDate <> ? then
                                                                                      string(vLastLoadDate)
                                                                                   else
                                                                                      "?")
                                                                                   ).
   define variable vobj as character no-undo.
   vobj = getExtAttr('host-code':U).
   if vobj ne "0"
   then
       for each utd where utd.sts-edi < ObjSrv:Env:Utd:Sts:edi:StatFinesh
                      and utd.host-code eq int(vobj)
                      and (   utd.EDocType eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
                           or utd.EDocType eq objSrv:Env:Utd:EDocType:UCD:KeyIntDB
                           )
       no-lock break by utd.OrganizationExt:
          if chekStop() then return "Остановка пользователем".
          if vBegLoadDate <> ? and utd.DocumentDate < vBegLoadDate then next.
          find first tt-recid where tt-recid.orgid = utd.OrganizationExt
                                and tt-recid.docid = utd.DocumentExt
                 no-error.
          if     not available tt-recid
             and getdocum (utd.db-num, utd.doc-id, output vDocument) eq ""
          then do:
              run  UpdateUTDInformOne(vDocument).
             release object vDocument no-error.
          end.
       end.
   vobj = getExtAttr('obj':U).
   if vobj ne ""
   then
       for each utd where utd.sts-edi < ObjSrv:Env:Utd:Sts:edi:StatFinesh
                      and utd.obj-type + string(utd.obj-code) eq vobj
       no-lock break by utd.OrganizationExt:
          if chekStop() then return "Остановка пользователем".
          if vBegLoadDate <> ? and utd.DocumentDate < vBegLoadDate then next.
          find first tt-recid where tt-recid.orgid = utd.OrganizationExt
                                and tt-recid.docid = utd.DocumentExt
                 no-error.
          if     not available tt-recid
             and getdocum (utd.db-num, utd.doc-id, output vDocument) eq ""
          then do:
              run  UpdateUTDInformOne(vDocument).
             release object vDocument no-error.
          end.
       end.
end.
procedure  SendAuto:
 define variable vOrganization as component-handle no-undo.
 define variable vOrganizationList as component-handle no-undo.
 define variable vi as integer no-undo.
   if mDiadocConnection eq ?
   then do:
      message "По данному сертификату не удалось подключиться к Диадок"
      view-as alert-box.
   end.
   else do:
      for each tt-recid:
         delete tt-recid.
      end.
      vOrganizationList = mDiadocConnection:GetOrganizationList() no-error.
      if vOrganizationList eq ? then return error ?.
      vi = vOrganizationList:Count()no-error.
      if vi eq ?
      then
         return error ?.
      do vi = 1 to vOrganizationList:Count() :
         vOrganization = vOrganizationList:GetItem(vi - 1 ).
         define variable vorgid as character no-undo.
         vorgid = vOrganization:guid.
         for each utd where utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:HaveToCreateReceipt:KeyIntDB
                        and utd.host-code eq v-cntxt-host-code-obj
                        and utd.OrganizationExt eq vorgid
         no-lock:
             run  SendReceiptsAsync(utd.db-num,utd.doc-id).
         end.
         for each utd where utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:HaveToCreateReceipt:KeyIntDB
                        and utd.host-code eq v-cntxt-host-code-obj
                        and utd.OrganizationExt eq vorgid
         no-lock:
             run  updOneUTD(utd.db-num,utd.doc-id).
         end.
      end.
   end.
end.
procedure SendAccept:
   define input  parameter iTypeAccept     as character no-undo.
   define input  parameter iReplyTask      as component-handle no-undo.
   define input  parameter iOrganizationGuid as character no-undo.
   define input  parameter iWorkflowId     as integer no-undo.
   define input  parameter iTitleTypes    as character  no-undo.
   define output parameter oOperationCode as character no-undo.
   define variable vContentItems as component-handle no-undo.
   define variable vContentItem  as component-handle no-undo.
   define variable vSigner       as component-handle no-undo.
   define variable vBuyerTitle   as component-handle no-undo.
   define variable vEmployee     as component-handle no-undo.
   define variable vContentOperCode as component-handle no-undo.
   define variable vOrganization   as component-handle no-undo.
   define variable vUserperm   as component-handle no-undo.
   define variable vi as integer no-undo.
  define variable vdate as date no-undo.
  define variable vDocumentCreator as character no-undo.
  define variable vDocumentCreatorBase as character no-undo.
  define variable vOperationCode as character no-undo.
  define variable vOperationContenttext as character no-undo.
  define variable vOperationContent as character no-undo.
  define variable vThumbprint as character no-undo.
  define variable vJobTitle   as character no-undo.
  vThumbprint = mDiadocConnection:Certificate:Thumbprint.
  vOrganization = mDiadocConnection:GetOrganizationById(iOrganizationGuid) no-error.
  if vOrganization eq ?
  then do:
     run str\utdacp.w (output vdate, output  vDocumentCreator, output vDocumentCreatorBase, output vOperationCode, output vOperationContent) no-error.
     if vdate eq ?
     then
        return error "".
  end.
  else do:
     define variable vTitleType as character no-undo.
     define variable vSignSet   as component-handle no-undo.
     define variable vSeller as logical no-undo.
     vUserperm = vOrganization:GetUserPermissions().
     vJobTitle = vUserperm:JobTitle.
     release object vUserperm.
     blk-tit:
     do vi = 1 to num-entries(iTitleTypes):
        vTitleType = entry(vi,iTitleTypes).
        vSeller = index(vTitleType,"Seller") > 0.
        if vSeller
        then
           next blk-tit.
        vSignSet = vOrganization:GetExtendedSignerDetails2(vThumbprint, vTitleType) no-error.
        if error-status:num-messages > 0
        then do:
           define variable vTasksetSign   as component-handle no-undo.
           define variable vTasksetSignDetal   as component-handle no-undo.
           vTasksetSign = vOrganization:CreateSetExtendedSignerDetailsTask(VThumbprint).
           getdesc(vTasksetSign).
           vTasksetSign:DocumentTitleType = vTitleType.
           getdesc(vTasksetSign).
           vTasksetSignDetal = vTasksetSign:ExtendedSignerDetailsToPost.
           getdesc(vTasksetSignDetal).
           vTasksetSignDetal:JobTitle  = vJobTitle    .
           vTasksetSignDetal:SignerType = "LegalEntity" .
           vTasksetSignDetal:SignerInfo = "".
           vTasksetSignDetal:Powers = if VSeller then "InvoiceSigner"  else "PersonDocumentedOperation".
           vTasksetSignDetal:Status = if VSeller then "SellerEmployee" else "BuyerEmployee".
           vTasksetSignDetal:PowersBase = "Должностные обязанности".
           getdesc(vTasksetSignDetal).
           release object vTasksetSignDetal.
           vTasksetSign:send() no-error.
           if error-status:num-messages > 0 then do:
              PutErr(substitute("Error Ошибка при установке подписанта по документу &1 ", vTitleType )).
           end.
           release object vTasksetSign.
        end.
        else do:
           getdesc(vSignSet).
           release object vSignSet.
        end.
     end.
     vOperationContent = if iTypeAccept eq "AcceptDocumentWithDisc"
                         then "2"
                         else if iTypeAccept eq "AcceptDocumentNotAccepted"
                         then "3"
                         else "1".
     vdate = today.
     vDocumentCreator = substitute("&1, ИНН~/КПП &2~/&3", vOrganization:name , vOrganization:inn , vOrganization:kpp).
     release object vOrganization.
  end.
  if    vJobTitle eq ?
     or vJobTitle eq ""
  then
     vJobTitle = mDiadocConnection:Certificate:JobTitle.
   if (   iWorkflowId = 3
      or iWorkflowId = 5
      or iWorkflowId = 8
      or iWorkflowId = 11
      or iWorkflowId = 12
      or iWorkflowId = 13
      or iWorkflowId = 16)
      and iReplyTask ne ?
   then do:
      getdesc(iReplyTask).
      vContentItems = iReplyTask:ContentItems.
      getdesc(vContentItems).
      do vi = 1 to vContentItems:count:
         getdesc(vContentItems:GetItem(vi - 1 )).
         getdesc(vContentItems:GetItem(vi - 1 ):document).
         vContentItem = vContentItems:GetItem(vi - 1 ):Content.
         getdesc(vContentItem).
         vBuyerTitle = vContentItem:UniversalTransferDocumentBuyerTitle no-error.
         getdesc(vBuyerTitle).
           if vBuyerTitle eq ?
         then do:
            vBuyerTitle = vContentItem:UniversalCorrectionDocumentBuyerTitle.
            getdesc(vBuyerTitle).
            vOperationContenttext = "C изменением стоимости согласен".
         end.
         else do:
            oOperationCode = vOperationContent.
   vOperationContenttext = if vOperationContent eq "1"
                       then "Принято без разногласий"
                       else if vOperationContent eq "2"
                       then "Принято с разногласиями"
                       else if vOperationContent eq "3"
                       then "Товары не приняты"
                       else vOperationContent.
            getdesc(vBuyerTitle).
            vEmployee = vBuyerTitle:Employee.
            getdesc(vEmployee).
            define variable vUser   as component-handle no-undo.
            vUser = mDiadocConnection:GetMyUser().
            getdesc(vUser).
            vEmployee:position        = vJobTitle    .
            vEmployee:FirstName       = vUser:FirstName  .
            vEmployee:LastName        = vUser:LastName   .
            vEmployee:MiddleName      = vUser:MiddleName .
            vEmployee:EmployeeBase     = "Должностные обязанности".
            release object vUser.
            getdesc(vEmployee).
            getdesc(mDiadocConnection:Certificate).
            getdesc(vContentItem:UniversalTransferDocumentBuyerTitle).
            getdesc(vBuyerTitle:ContentOperCode).
            vContentOperCode = vBuyerTitle:ContentOperCode.
            vContentOperCode:TotalCode = vOperationContent.
            vBuyerTitle:OperationCode   = oOperationCode.
            release object vContentOperCode.
            release object vEmployee.
         end.
         vBuyerTitle:DocumentCreator = vDocumentCreator .
         vBuyerTitle:DocumentCreatorBase     = vDocumentCreatorBase.
         vBuyerTitle:OperationContent =  vOperationContenttext.
         vBuyerTitle:AcceptanceDate   = vdate.
         getdesc(vBuyerTitle).
         getdesc(vBuyerTitle:Signers).
         vSigner = vBuyerTitle:Signers:additems().
         getdesc(vSigner).
         getdesc(vSigner:SignerReference).
         getdesc(vSigner:SignerDetails).
         vSigner:SignerReference:CertificateThumbprint = mDiadocConnection:Certificate:Thumbprint.
         vSigner:SignerReference:boxid = iOrganizationGuid.
         getdesc(vSigner:SignerReference).
         release object vBuyerTitle no-error.
         release object vContentItem.
      end.
      release object vContentItems.
   end.
end.
function SendAnswer returns character
(iReplyTask as component-handle,iorg as char,iTypeAnswer as character,imes as longchar ):
   define variable vContent       as component-handle no-undo.
   define variable vContentItems  as component-handle no-undo.
   define variable vSigner        as component-handle no-undo.
   define variable vSignTask      as component-handle no-undo.
   define variable vOrganization  as component-handle no-undo.
   define variable vUserperm      as component-handle no-undo.
   define variable vUser          as component-handle no-undo.
   define variable vi as integer no-undo.
   if     itypeAnswer ne "AcceptRevocation"
      and iReplyTask  ne ?
   then do:
      getdesc(iReplyTask).
      vContentItems = iReplyTask:ContentItems.
      getdesc(vContentItems).
      do vi = 1 to vContentItems:count:
         getdesc(vContentItems:GetItem(vi - 1 )).
         getdesc(vContentItems:GetItem(vi - 1 ):document).
         vContent = vContentItems:GetItem(vi - 1 ):Content.
         vContent:comment =  imes.
        getdesc(vContent).
         vSigner = vContent:Signer.
         getdesc(vSigner).
         vOrganization = mDiadocConnection:GetOrganizationById(iOrg) no-error.
         vUserperm = vOrganization:GetUserPermissions().
         define variable vJobTitle as character no-undo.
         vJobTitle = vUserperm:JobTitle.
         if    vJobTitle eq ?
            or vJobTitle eq ""
         then
            vJobTitle = mDiadocConnection:Certificate:JobTitle.
         release object vUserperm.
         release object vOrganization.
         vUser = mDiadocConnection:GetMyUser().
         getdesc(vUser).
         vSigner:Surname    = vUser:FirstName.
         vSigner:FirstName  = vUser:LastName.
         vSigner:Patronymic = vUser:MiddleName.
         vSigner:JobTitle   = vJobTitle.
         vSigner:Inn        = mDiadocConnection:Certificate:inn.
         getdesc(vSigner).
         release object vUser.
         release object vSigner.
         release object vContent.
      end.
      release object vContentItems.
   end.
end.
procedure send:
   define input  parameter iDocument as component-handle no-undo.
   define input  parameter iTypeAnswer as character no-undo.
   define input  parameter icomment as character no-undo.
   define output parameter oOperationCode as character no-undo.
   define variable vReplyTask    as component-handle no-undo.
   define variable vTypeAnswer as character no-undo.
   define variable vTypeAnswer_orig as character no-undo.
   define variable Vmes as longchar  no-undo.
   define variable vOrganizationGuid as character no-undo.
   define variable vDocumentid as character no-undo.
   define variable vi as integer no-undo.
   if iDocument ne ?
   then do:
      case iTypeAnswer:
         when "Подписания"                 then vTypeAnswer =  "AcceptDocument".
         when "отказ подписи"              then vTypeAnswer =  "RejectDocument".
         when "запрос коректировки"        then vTypeAnswer =  "CorrectionRequest".
         when "Запрос анулирование"        then vTypeAnswer =  "RevocationRequest".
         when "Подтверждение анулирования" then vTypeAnswer =  "AcceptRevocation".
         when "отказ анулирования"         then vTypeAnswer =  "RejectRevocation".
         when "подписать с расхождениями"  then vTypeAnswer =  "AcceptDocumentWithDisc".
         when "подписать товар не принят"  then vTypeAnswer =  "AcceptDocumentNotAccepted".
         otherwise vTypeAnswer = iTypeAnswer .
      end case.
      vTypeAnswer_orig = vTypeAnswer.
      if    vTypeAnswer =  "AcceptDocumentWithDisc"
         or vTypeAnswer =  "AcceptDocumentNotAccepted"
      then
         vTypeAnswer =  "AcceptDocument".
      if mDiadocConnection:AuthenticateType ne "Certificate" then return error "не сертификат".
      vReplyTask = iDocument:CreateReplySendTask2(vTypeAnswer).
      vOrganizationGuid = iDocument:OrganizationGuid.
      vDocumentid     = iDocument:DocumentId.
      getdesc(iDocument).
      if vTypeAnswer =  "AcceptDocument"
      then do:
         define variable vtitletype as character no-undo.
         vTitleType = GetDocTitleType(vOrganizationGuid,iDocument:TypeNamedId,iDocument:DocumentFunction,iDocument:Version).
         run sendAccept in this-procedure (vTypeAnswer_orig,
                                           vReplyTask,
                                           iDocument:OrganizationGuid,
                                           iDocument:WorkflowId,
                                           vtitletype,
                                           output oOperationCode ) no-error.
         if error-status:error
         then
            return error "".
      end.
      else do:
         find first utd where utd.DocumentExt     = vDocumentid
                          and utd.OrganizationExt = vOrganizationGuid
         no-lock no-error.
         if available utd
         then do:
            if   vTypeAnswer ne  "CorrectionRequest"
                and vTypeAnswer ne  "RejectDocument"
            then
               icomment = "".
            if vTypeAnswer eq  "RejectDocument"
            then do:
               if icomment eq ? or icomment eq "" then icomment = utd.comment.
               Vmes = (if icomment ne ? and icomment ne "" then icomment + "," else "" ) + GetErrForUtdStr(utd.db-num,utd.doc-id,?).
            end.
            else do:
                Vmes = GetErrForUtd(utd.db-num,utd.doc-id,?) .
                Vmes = GetErrComText(icomment,Vmes).
            end.
            if mFlaftest
            then do:
               output stream File-stream to "SendAnswer.txt" .
               put stream File-stream unformatted string(Vmes).
               output stream File-stream close.
               message "сформирован файл " search("SendAnswer.txt")
               view-as alert-box.
               return error "ничего не отправляем".
            end.
            else
               SendAnswer(vReplyTask,iDocument:OrganizationGuid, iTypeAnswer,Vmes) no-error.
            if error-status:error
            then
               return error "".
            end.
         end.
      if not mFlaftest
      then do:
         getdesc(vReplyTask).
          vReplyTask:Send() no-error.
         if error-status:num-messages > 0 then do:
            Puterr(substitute("Error Ошибка при выполнение действия по документу &1. ", vDocumentid )).
            release object vReplyTask.
            return error "Ошибка при выполнение дейстия с документом".
         end.
      end.
   end.
end.
procedure SendReceiptsAsync :
define input  parameter idb-num as integer no-undo.
define input  parameter idoc-id as integer no-undo.
   define variable vDocument as component-handle no-undo.
   define buffer utd for utd.
   if getdocum (idb-num, idoc-id, output vDocument ) eq ""
   then do:
      PutMes(substitute("Обработка подписи ИОП по документу ДБ &1 ID &2",idb-num,idoc-id)).
      define variable vAsyncResult   as component-handle no-undo.
      vAsyncResult = vDocument:SendReceiptsAsync().
      release object vDocument.
      PutMes(substitute("Запущена асинхронная обработка ИОП по документу ДБ &1 ID &2",idb-num,idoc-id)).
      find first utd where utd.db-num eq idb-num
                       and utd.doc-id eq idoc-id
      exclusive-lock no-error.
      if available utd
      then do:
         if getdocum (idb-num, idoc-id, output vDocument) eq ""
         then do:
             run  UpdateUTDInformOne(vDocument).
            release object vDocument.
         end.
         utd.flagRI = yes.
    end.
      PutMes(vAsyncResult:Result).
      release object vAsyncResult.
      if getdocum (idb-num, idoc-id, output vDocument) eq ""
      then do:
          run  UpdateUTDInformOne(vDocument).
         release object vDocument.
      end.
   end.
end.
procedure SendAnsver:
   define input  parameter idb-num as integer no-undo.
   define input  parameter idoc-id as integer no-undo.
   define input  parameter iTypeAnswer as character no-undo.
   define input  parameter iComment as character no-undo.
   define variable vSendcode as character no-undo.
   define variable vDocument as component-handle no-undo.
   define buffer utd for utd.
   if getdocum (idb-num, idoc-id, output vDocument ) eq ""
   then do:
      PutMes(substitute("Обработка запроса &3 по документу ДБ &1 ID &2",idb-num,idoc-id,iTypeAnswer)).
       run   SendReceiptsAsync(idb-num,idoc-id).
         find first utd where utd.db-num eq idb-num
                                and utd.doc-id eq idoc-id
               no-lock.
      if      (not utd.AmendmentRequested
          and  iTypeAnswer eq "CorrectionRequest")
          or iTypeAnswer ne "CorrectionRequest"
      then do:
          run   send in this-procedure (vDocument,iTypeAnswer,iComment,output vSendcode) no-error.
         if error-status:error
         then do:
            release object vDocument.
            return error return-value.
         end.
         PutMes(substitute("Обработка запроса &3 по документу ДБ &1 ID &2 Завершина",idb-num,idoc-id,iTypeAnswer)).
      end.
      else
         PutMes(substitute("Обработка запроса &3 по документу ДБ &1 ID &2 пропущена",idb-num,idoc-id,iTypeAnswer)).
      release object vDocument.
      if     vSendcode ne ?
         and vSendcode ne ""
      then
         setattrutd (idb-num,idoc-id,"sendcode",vSendcode).
      if not mFlaftest
      then do:
         if getdocum (idb-num, idoc-id, output vDocument) eq ""
         then do:
             run   UpdateUTDInformOne(vDocument).
            release object vDocument.
         end.
         if    iTypeAnswer eq "CorrectionRequest"
            or iTypeAnswer eq "AcceptRevocation"
            or iTypeAnswer eq "RejectRevocation"
            or iTypeAnswer eq "RejectDocument"
            or iTypeAnswer eq "AcceptDocument"
            or iTypeAnswer eq "AcceptDocumentWithDisc"
            or iTypeAnswer eq "AcceptDocumentNotAccepted"
         then do:
            if getdocum (idb-num, idoc-id, output vDocument) eq ""
            then do:
                run  UpdateUTDInformOne(vDocument).
               release object vDocument.
            end.
            if   not mFlaftest
            then do trans:
               find first utd where utd.db-num eq idb-num
                                and utd.doc-id eq idoc-id
                                and utd.sts-edi < ObjSrv:Env:Utd:Sts:edi:StatFinesh
               exclusive-lock no-error.
               if available utd
               then do :
                  case iTypeAnswer:
                     when   "AcceptDocument"               then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRecipient:KeyIntDB.
                     when   "RejectDocument"               then utd.sts-edi = if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:AutoRejected:KeyIntDB
                                                                              then ObjSrv:Env:Utd:Sts:edi:sendAutoRejected:KeyIntDB
                                                                              else ObjSrv:Env:Utd:Sts:edi:sendRejected:KeyIntDB.
                     when   "CorrectionRequest"            then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendAdjustment:KeyIntDB.
                     when   "AcceptRevocation"             then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRevocation:KeyIntDB.
                     when   "RejectRevocation"             then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRevocation:KeyIntDB.
                     when   "AcceptDocumentWithDisc"       then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRecipient:KeyIntDB.
                     when   "AcceptDocumentNotAccepted"    then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRecipient:KeyIntDB.
                  end case.
                  if iTypeAnswer eq "CorrectionRequest"
                  then do:
                     utd.sts = ObjSrv:Env:Utd:Sts:th:CorrectionRequested:KeyIntDB.
                     if     utd.sts-edi < ObjSrv:Env:Utd:Sts:edi:StatFinesh
                     then do:
                         run   SendAnsver(idb-num,idoc-id,"AcceptDocumentWithDisc",iComment).
                     end.
                  end.
               end.
            end.
         end.
      end.
   end.
end.
procedure  SendResponse :
   define input  parameter idb-num as integer no-undo.
   define input  parameter idoc-id as integer no-undo.
   define input  parameter iAccept as logical no-undo.
   define input  parameter itestMod as logical no-undo.
    define buffer utd for utd.
    define buffer buf_utd for utd.
    itestMod = not itestMod.
    define variable vreturn as logical no-undo.
    find first utd where utd.db-num eq idb-num
                     and utd.doc-id eq idoc-id
    no-lock no-error.
    if available utd
    then do:
       if utd.EDocType              = objSrv:Env:Utd:EDocType:EDoc:KeyIntDB
       then do:
          if     iAccept
             and utd.sts-edi     ne objSrv:Env:Utd:sts:edi:WithRecipientSignature:KeyIntDB
             and utd.sts-edi     ne objSrv:Env:Utd:sts:edi:WithRecipientPartiallySignature:KeyIntDB
          then do:
             vreturn = yes.
             if itestMod
             then do:
                for each buf_utd where buf_utd.PackageId eq utd.PackageId
                                   and buf_utd.EDocType  eq objSrv:Env:Utd:EDocType:ucd:KeyIntDB
                                   and buf_utd.Timestamp <= utd.Timestamp
                                   and (     buf_utd.sts-edi   eq objSrv:Env:Utd:sts:edi:WaitingForRecipientSignature:KeyIntDB
                                         or  buf_utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:HaveToCreateReceipt:KeyIntDB
                                         or  buf_utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:Verification:KeyIntDB)
                no-lock :
                    run  SendAnsver in this-procedure (buf_utd.db-num,buf_utd.doc-id,"AcceptDocument","")no-error.
                   if error-status:error then return error return-value.
                end.
             end.
          end.
       end.
       else if utd.EDocType              = objSrv:Env:Utd:EDocType:returns:KeyIntDB
       then do:
          if iAccept
          then do:
             vreturn = yes.
             if itestMod
             then do:
                define variable vsend as logical no-undo.
                vsend = logical(getattrutdex (idb-num,idoc-id,"returnSend","no")).
                if vsend
                then
                   return error "Документ был отправлен рание. Повторная отправка возможна через сервис.".
                find first buf_utd where buf_utd.OrganizationExt eq utd.parentOrganizationExt
                                     and buf_utd.DocumentExt     eq utd.parentDocumentExt
                no-lock no-error.
                if available buf_utd
                then do:
                   if getattrutd (idb-num,idoc-id,"TypeUTD") ne "счфДОП"
                   then do:
                       run  SendAnsver in this-procedure (buf_utd.db-num,buf_utd.doc-id,"CorrectionRequest",GetErrForUtd(utd.db-num,utd.doc-id,"return"))no-error.
                      if error-status:error then return error return-value.
                   end.
                end.
                run bge/sendutd.p(
                     parparentproc,
                     mDiadocConnection:Certificate:Thumbprint,
                     idb-num,
                     idoc-id) no-error.
                if error-status:error then return error return-value.
                do trans :
                   find first utd where utd.db-num eq idb-num
                                    and utd.doc-id eq idoc-id
                   exclusive-lock no-error.
                   utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:WithRecipientSignature:KeyIntDB.
                   setattrutd (idb-num,idoc-id,"returnSend","yes").
                end.
             end.
          end.
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:HaveToCreateReceipt:KeyIntDB
       then do:
          if iAccept
          then do:
             vreturn = yes.
             if itestMod
             then
                 run  SendReceiptsAsync(idb-num,idoc-id).
          end.
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:Verification:KeyIntDB
       then do:
          if not iAccept
          then do:
             vreturn = yes.
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"RejectDocument","") no-error.
                if error-status:error then return error return-value.
             end.
          end.
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:RequestsMyRevocation:KeyIntDB
       then do:
          vreturn = yes.
          if iAccept
          then do:
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"AcceptRevocation","") no-error.
                if error-status:error then return error return-value.
             end.
          end.
          else do:
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"RejectRevocation","")no-error.
                if error-status:error then return error return-value.
             end.
          end.
       end.
       else if   utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:Changed:KeyIntDB
              or utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:WaitingForRecipientSignature:KeyIntDB
       then do:
          vreturn = yes.
          if iAccept
          then do:
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"AcceptDocument","")no-error.
                if error-status:error then return error return-value.
             end.
          end.
          else do:
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"RejectDocument","") no-error.
                if error-status:error then return error return-value.
             end.
          end.
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:AutoRejected:KeyIntDB
       then do:
          if iAccept
          then do:
             vreturn = yes.
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"RejectDocument","") no-error.
                if error-status:error then return error return-value.
             end.
          end.
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:SignatureAdjustment:KeyIntDB
       then do:
          if iAccept
          then do:
             vreturn = yes.
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"CorrectionRequest","")no-error.
                if error-status:error then return error return-value.
             end.
          end.
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:SignatureNotAccepted:KeyIntDB
       then do:
          if iAccept
          then do:
             vreturn = yes.
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"AcceptDocumentNotAccepted","")no-error.
                if error-status:error then return error return-value.
             end.
          end.
       end.
       if itestmod and not vreturn
       then do:
          PutMes (substitute('Error Документ с № "&5" в.н. "&2" по БД "&1" в статусе "&3" выполнить операцию "&4" не возможно.',
                             utd.db-num,
                             utd.doc-id,
                             ObjSrv:Env:Utd:Sts:EDI:GetLabel(utd.sts-edi),
                             if iAccept then "Подписать" else "Отказать",
                             utd.DocumentNumber)
                             ).
       end.
    end.
    return string(vreturn).
end.
define temp-table tt-pack no-undo
          field orgid as char
          field docid as char
          field packid as char
          field stamp as datetime
          index pi packid   stamp   orgid  docid
          .
function CheckLoad returns logical
(iDocument as component-handle,
 output ohost-code as integer ,
 output oObj-type  as character  ,
 output oObj-code  as integer ):
   define variable vFlag as logical no-undo.
   define variable vDocumentChild as component-handle no-undo.
   define variable vContent as component-handle no-undo.
   define variable vConsignees as component-handle no-undo.
   define variable vfilename as character no-undo.
   oObj-type  = ?.
   oObj-code  = ?.
   ohost-code = ?.
   define buffer ext-classif   for ext-classif.
   define buffer clients       for clients.
   define buffer buf_clients   for clients.
   define buffer clients-attr  for clients-attr.
   if   iDocument:type eq "UniversalTransferDocument"
     or iDocument:type eq "UniversalTransferDocumentRevision"
   then main-block :
   do on error undo main-block, return error:
      getdesc(iDocument).
      vfilename = iDocument:filename.
      if iDocument:Direction eq "Inbound"
      then do:
         define variable vOrganizationGuid as character no-undo.
         define variable vDocumentid as character no-undo.
         vOrganizationGuid = iDocument:OrganizationGuid.
         vDocumentid     = iDocument:DocumentId.
         find first utd where utd.DocumentExt     = vDocumentid
                          and utd.OrganizationExt = vOrganizationGuid
         no-lock no-error .
         if available utd
         then do:
            assign
               Oobj-type = utd.obj-type
               Oobj-code = utd.obj-code
               ohost-code = utd.host-code.
            .
         end.
         vDocumentChild = iDocument:GetDynamicContent("Seller") no-error.
         getdesc(vDocumentChild).
         if    (Oobj-code  ne 0 and Oobj-code  ne ?
            and ohost-code ne 0 and ohost-code ne ?)
         then vFlag = no.
         if    (Oobj-code  ne 0 and Oobj-code  ne ?
            and (ohost-code eq 0 and ohost-code eq ?))
         then do:
             find first clients  where clients.obj-type   = Oobj-type
                                   and clients.obj-code   = Oobj-code
             no-lock no-error .
             if available clients
             then
                ohost-code =  clients.host-code.
             vFlag = no.
         end.
         else if vDocumentChild ne ?
         then do:
            if iDocument:version  eq "utd820_05_01_01"
            then do:
               vContent = vDocumentChild:UniversalTransferDocument no-error.
            end.
            else
               vContent = vDocumentChild:UniversalTransferDocumentWithHyphens no-error.
            release object vDocumentChild.
            if vContent ne ?
            then do:
               getdesc(vContent).
               define variable vFnsParticipantId as character no-undo.
               define variable vinn as character no-undo.
               define variable vkpp as character no-undo.
               define variable vorgname as character no-undo.
               define variable vAddrOrg as character no-undo.
               define variable vAdditionalInfo as character no-undo.
               if iDocument:version  eq "utd820_05_01_01"
               then do:
                  getdesc(vContent:Sellers).
                  getdesc(vContent:Sellers:Seller).
                  getdesc(vContent:Sellers:Seller:GetItem(0)).
                  getdesc(vContent:Sellers:Seller:GetItem(0):OrganizationDetails).
                  getOrganizationInfo(vContent:Sellers:Seller:GetItem(0),output vinn,output vkpp,vFnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
               end.
               else do:
                  vFnsParticipantId =  vContent:SenderFnsParticipantId.
               end.
               find first ext-classif where ext-classif.classif-name  eq 'id_diadok_client':U
                                        and ext-classif.charkey_three eq vFnsParticipantId
               no-lock no-error.
               if available ext-classif
               then do:
                  find first clients
                    where clients.obj-type   = ext-classif.CharKey_One
                      and clients.obj-code   = ext-classif.Key#_One
                      and not can-find(first ub.sysconf where ub.sysconf.host-code = clients.obj-code)
                  no-lock no-error .
                  if not available clients
                  then do:
                     PutMes(substitute("По &1 отправитель &2 наша фирма." ,iDocument:DocumentNumber, vFnsParticipantId) ).
                     return no.
                  end.
               end.
               else do:
                  PutMes(substitute("По &1 не найден отправитель  &2." ,iDocument:DocumentNumber, vFnsParticipantId) ).
                  return no.
               end.
               if iDocument:version  eq "utd820_05_01_01"
               then do:
                  getdesc(vContent:Buyers).
                  getdesc(vContent:Buyers:Buyer).
                  getdesc(vContent:Buyers:Buyer:GetItem(0)).
                  getOrganizationInfo(vContent:Buyers:Buyer:GetItem(0),output vinn,output vkpp,vFnsParticipantId, output vorgname, output vAdditionalInfo,output vAddrOrg).
               end.
               else do:
                  vConsignees = vContent:Consignees.
                  getdesc(vConsignees).
                  getdesc(vConsignees:Consignee).
                  if vConsignees:Consignee:count > 0
                  then do:
                     getdesc(vConsignees:Consignee:GetItem(0)).
                     getOrganizationInfo(vConsignees:Consignee:GetItem(0),output vinn,output vkpp,vFnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
                  end.
                  release object vConsignees.
                  vFnsParticipantId = vContent:RecipientFnsParticipantId.
               end.
               release object vContent.
               define variable otext as character no-undo.
               vFlag = getObgFns
                          (input iDocument:DocumentNumber ,
                           input vFnsParticipantId ,
                           input vkpp,
                           output ohost-code,
                           output oobj-type,
                           output oobj-code,
                           output otext ).
               if otext ne "" and otext ne ?
               then
                  PutMes( otext).
               if vFlag  eq no
               then
                  return vFlag .
            end.
            else do:
               PutMes("Error Ошибка получения данных из Диадок UniversalTransferDocument" + if iDocument:version  eq "utd820_05_01_01" then "" else "WithHyphens").
               return no.
            end.
         end.
         else do:
            PutErr(substitute ("Error Ошибка получения данных из Диадок Seller по документу с типом &1",iDocument:type)).
            return no.
         end.
      end.
      else
         return yes.
      if ohost-code eq ? or ohost-code eq 0
      then do:
         PutMes(substitute("По &1 не удалось определить фирму по получателю  &2." ,iDocument:DocumentNumber, vFnsParticipantId) ).
         return no.
      end.
   end.
   else do:
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vpack as character no-undo init ?.
      define variable vcli-type as character no-undo.
      define variable vcli-code as integer no-undo.
      define variable vfns as character no-undo.
      define variable vchar as character no-undo.
      vDocumentChild = iDocument:GetDynamicContent("Seller")no-error.
      if vDocumentChild eq ?
      then do:
         PutErr(substitute ("Error Ошибка получения данных из Диадок Seller по документу с типом &1",iDocument:type)).
         return no.
      end.
      vContent = vDocumentChild:UniversalCorrectionDocument no-error.
      if vContent ne ?
      then do:
         getOrganizationInfo(vContent:Seller,output vchar,output vchar,vFns, output vchar,  output vchar, output vchar).
         find first ext-classif where ext-classif.classif-name  eq 'id_diadok_client':U
                                  and ext-classif.charkey_three eq vFns
         no-lock no-error.
         if available ext-classif
         then do:
            assign
               vcli-type = ext-classif.CharKey_One
               vcli-code = ext-classif.Key#_One
            .
            vPack = substitute("&1|&2|&3|&4",vcli-type,vcli-code,iDocument:OriginalInvoiceNumber,date(iDocument:OriginalInvoiceDate)).
            GetprevUTDForPac(vpack,iDocument:Timestamp,output vdb-num,output vdoc-id ).
            release object vContent.
         end.
         else do:
                  PutMes(substitute("По &1 не найден отправитель  &2." ,iDocument:DocumentNumber, vFnsParticipantId) ).
                  return no.
               end.
      end.
      else do:
         PutErr("Error Ошибка получения данных из Диадок Seller").
         return no.
      end.
      release object vDocumentChild.
      define buffer     utd for utd.
      find first utd where utd.db-num eq vdb-num
                       and utd.doc-id eq vdoc-id
      no-lock no-error.
      if available utd
      then do:
         assign
            oobj-type  = utd.obj-type
            oobj-code  = utd.obj-code
            ohost-code = utd.host-code
            vfilename  = getattrutd (utd.db-num,utd.doc-id,"FileName")
         .
      end.
      else do:
         PutMes(substitute("Не найден оригенальный документ по пакету &1.",vpack)).
         return no.
      end.
   end.
   if  yes
   then do:
      define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
      EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(oobj-type, oobj-code).
      if     not EDOParSec:IsEdo
         and vfilename begins "ON_NSCHFDOPPRMARK_"
      then do:
         PutMes(substitute("На объекте &1&2 не установлен параметр работы с ЭДО для маркированного товара.",oobj-type,oobj-code)).
         vFlag = no.
      end.
      else if     not EDOParSec:IsEdoNotmark
              and not vfilename begins "ON_NSCHFDOPPRMARK_"
      then do:
         PutMes(substitute("На объекте &1&2 не установлен параметр работы с ЭДО для не маркированного товара.",oobj-type,oobj-code)).
         vFlag = no.
      end.
      else
         vFlag = yes.
   end.
   return vFlag.
end.
procedure  UpdateUTDInformOne :
   define input  parameter iDocument as component-handle no-undo.
   define variable vOrganizationGuid as character no-undo.
   define variable vDocumentId as character no-undo.
   define variable vi as integer no-undo.
   define variable vii as integer no-undo.
   define variable viii as integer no-undo.
   define variable vtext as longchar no-undo.
   define buffer utd           for ub.utd.
   define buffer old_utd           for ub.utd.
   define buffer utd-lines      for ub.utd-lines.
   define buffer marking       for ub.marking.
   define buffer marking-lines for ub.marking-lines.
   define buffer utd-marking-lines for ub.utd-marking-lines.
   define buffer buf_utd-marking-lines for ub.utd-marking-lines.
   define variable vDocumentChild               as component-handle no-undo.
   define variable vContent                     as component-handle no-undo.
   define variable vValues                      as component-handle no-undo.
   define variable vSellers                     as component-handle no-undo.
   define variable vConsignees                  as component-handle no-undo.
   define variable vInvoiceTable                as component-handle no-undo.
   define variable vItems                       as component-handle no-undo.
   define variable vExtendedInvoiceItem         as component-handle no-undo.
   define variable vItemIdentificationNumber    as component-handle no-undo.
   define variable vTransferBaseCol             as component-handle no-undo.
   define variable vTransferBase                as component-handle no-undo.
   define variable vorgname as character no-undo.
   define variable vAddrOrg as character no-undo.
   define variable vAdditionalInfo as character no-undo.
   define variable volddb-num as integer no-undo.
   define variable volddoc-id as integer no-undo.
   define variable vunits  as component-handle no-undo.
   define variable vunit   as component-handle no-undo.
   define variable VValue  as character        no-undo.
   define variable vsite   as character        no-undo.
   define variable vNewUtd as logical          no-undo.
   if iDocument eq ?
   then
     return.
   vOrganizationGuid = iDocument:OrganizationGuid.
   vDocumentid     = iDocument:DocumentId.
   find first utd where utd.DocumentExt     = vDocumentid
                    and utd.OrganizationExt = vOrganizationGuid
   no-lock no-error .
   find first tt-recid where tt-recid.orgid eq vOrganizationGuid
                         and tt-recid.docid eq vDocumentid
   no-lock no-error.
   if not available tt-recid
   then do trans:
      if iDocument  ne ?
         and (
                  iDocument:type eq "UniversalTransferDocument"
               or iDocument:type eq "UniversalTransferDocumentRevision"
               or iDocument:type eq "UniversalCorrectionDocument"
              )
      then do:
         PutMes(substitute("Загрузка документа  &1 от &2." ,iDocument:DocumentNumber,iDocument:DocumentDate) ).
         define variable vhost-code as integer   no-undo.
         define variable vobj-type  as character no-undo.
         define variable vobj-code  as integer   no-undo.
         if not CheckLoad(iDocument,output vhost-code,output vobj-type,output  vobj-code )
         then do:
            PutMes(substitute("Документ &1 от &2 пропущен." ,iDocument:DocumentNumber,iDocument:DocumentDate) ).
            create tt-recid.
            assign
               tt-recid.orgid = vOrganizationGuid
               tt-recid.docid = vDocumentid
            .
            return.
         end.
         find first utd where utd.DocumentExt     = vDocumentid
                          and utd.OrganizationExt = vOrganizationGuid
         no-lock no-error  .
         if available utd
         then do:
            if     utd.sts-edi > ObjSrv:Env:Utd:Sts:edi:StatFinesh
               and iDocument:RevocationStatus ne "RequestsMyRevocation"
            then do:
               create tt-recid.
               assign
                  tt-recid.orgid = vOrganizationGuid.
                  tt-recid.docid = vDocumentid
               .
               PutMes(substitute("Документ &1 от &2 в конечном статусе. Документ пропущен." ,iDocument:DocumentNumber,iDocument:DocumentDate) ).
            end.
            find current utd exclusive-lock no-error  no-wait  .
            if  not available  utd
            then do:
               PutMes(substitute("Документ &1 от &2 заблокирован и будет пропущен." ,iDocument:DocumentNumber,iDocument:DocumentDate )).
               return.
            end.
         end.
         subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
         MySeqUtd = ?.
         if     not available  utd
         then do:
            create utd.
            assign
               utd.DocumentExt      = vDocumentid
               utd.OrganizationExt  = vOrganizationGuid
               vNewUtd              = yes
            .
            validate utd.
         end.
         assign
            utd.host-code = vhost-code when vhost-code ne ? and vhost-code ne 0
            utd.obj-code  = vobj-code  when vobj-code  ne ? and vobj-code  ne 0
            utd.obj-type  = vobj-type  when vobj-type  ne ? and vobj-type  ne ""
         .
         setattrutd (utd.db-num,utd.doc-id,"FileName",iDocument:FileName).
         utd.RevocationStatus = iDocument:RevocationStatus.
         utd.RecipientResponseStatus          = iDocument:RecipientResponseStatus.
         utd.TypeId           = iDocument:type.
         utd.CounteragentId   = iDocument:Counteragent:guid.
         utd.CustomDocumentId = iDocument:CustomDocumentId.
         utd.sts-edi = ?.
         utd.DocumentNumber = iDocument:DocumentNumber.
         utd.DocumentDate   = date(iDocument:DocumentDate).
         utd.Timestamp      = datetime(iDocument:Timestamp) .
         utd.ReceiptStatus  = iDocument:RecipientReceiptMetadata:ReceiptStatus.
         utd.Direction      = iDocument:Direction.
         utd.ModifyDate = today.
         utd.flagRI     =    utd.ReceiptStatus eq "GeneralReceiptStatusNotAcceptable" or utd.ReceiptStatus eq "Finished".
         utd.EDocType = if   iDocument:type eq "UniversalTransferDocument"
                          or iDocument:type eq "UniversalTransferDocumentRevision"
                        then objSrv:Env:Utd:EDocType:UTD:KeyIntDB
                        else objSrv:Env:Utd:EDocType:UCD:KeyIntDB.
         getdesc(iDocument).
         getdesc(iDocument:Counteragent).
         getdesc(iDocument:RecipientReceiptMetadata).
         getdesc(iDocument:ConfirmationMetadata).
         utd.AmendmentRequested = logical(iDocument:AmendmentRequested).
         if iDocument:type ne "UniversalTransferDocumentRevision"
         then do:
                utd.Revised = logical(iDocument:Revised).
                utd.Corrected = logical(iDocument:Corrected).
         end.
         vDocumentChild = iDocument:GetDynamicContent("Seller").
         getdesc(vDocumentChild).
         if   iDocument:type eq "UniversalTransferDocument"
           or iDocument:type eq "UniversalTransferDocumentRevision"
         then do:
            utd.Total = iDocument:total.
            utd.Vat = iDocument:Vat.
         end.
         else do:
            utd.Total = decimal (iDocument:TotalInc) - decimal (iDocument:TotalDec).
            utd.Vat = decimal (iDocument:VatInc) - decimal (iDocument:VatDec).
         end.
         find first utd-lines where utd-lines.db-num     = utd.db-num
                                and utd-lines.doc-id     = utd.doc-id
                                no-lock no-error.
         if     (   vNewUtd
                 or utd.Direction ne "Inbound"
                 or not available utd-lines)
            and vDocumentChild ne ?
         then do:
            if utd.EDocType eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
            then do:
               if iDocument:version  eq "utd820_05_01_01"
               then do:
                  vContent = vDocumentChild:UniversalTransferDocument no-error.
               end.
               else
                  vContent = vDocumentChild:UniversalTransferDocumentWithHyphens no-error.
               if vContent ne ?
               then do:
                  getdesc(vContent).
                  define variable vInfoCount as integer no-undo.
                  define variable vInfos as component-handle no-undo.
                  define variable vInfo as component-handle no-undo.
                  vInfos = vContent:AdditionalInfoId:AdditionalInfo.
                  do vInfoCount = 1 to vInfos:count:
                     vInfo = vInfos:getitem(vInfoCount - 1).
                     getdesc(vInfo).
                     setattrutd (utd.db-num,utd.doc-id,vInfo:id,vInfo:value).
                  end.
                  getdesc(vContent:TransferInfo).
                  getdesc(vContent:TransferInfo:TransferBases).
                  vTransferBasecol = vContent:TransferInfo:TransferBases:TransferBase.
                  getdesc(vTransferBasecol).
                  do vi = 1 to min(vTransferBasecol:count,1):
                     vTransferBase = vTransferBasecol:getitem(vi - 1).
                     getdesc(vTransferBase).
                     utd.BaseDocumentNumber = vTransferBase:BaseDocumentNumber.
                     utd.BaseDocumentName   = vTransferBase:BaseDocumentName.
                     utd.BaseDocumentDate   = date(vTransferBase:BaseDocumentDate).
                     release object vTransferBase.
                  end.
                  release object vTransferBasecol.
                  vSellers = vContent:Sellers.
                  getdesc(vSellers).
                  getdesc(vSellers:Seller:GetItem(0)).
                  if vSellers:Seller:count > 0
                  then
                     getOrganizationInfo(vSellers:Seller:GetItem(0),output utd.cli-inn,output utd.cli-kpp,utd.cli-FnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
                  release object vSellers.
                  if iDocument:version  ne "utd820_05_01_01"
                  then
                     utd.cli-FnsParticipantId = vContent:SenderFnsParticipantId.
                  utd.cli-info = vorgname + " " + vAddrOrg.
                  if iDocument:version  eq "utd820_05_01_01"
                  then do:
                     getOrganizationInfo(vContent:Buyers:Buyer:GetItem(0),output utd.obj-inn,output utd.obj-kpp,utd.obj-FnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
                  end.
                  else do:
                     vConsignees = vContent:Consignees.
                     getdesc(vConsignees).
                     if vConsignees:Consignee:count > 0
                     then do:
                        getOrganizationInfo(vConsignees:Consignee:GetItem(0),output utd.obj-inn,output utd.obj-kpp,utd.obj-FnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
                        setattrutd (utd.db-num,utd.doc-id,"Consignee_ИнфДляУчаст",vAdditionalInfo).
                     end.
                     utd.obj-FnsParticipantId = vContent:RecipientFnsParticipantId.
                     release object vConsignees.
                  end.
                  utd.obj-info = vorgname + " " + vAddrOrg + " ИНН: " + utd.obj-inn + " КПП: " + utd.obj-kpp.
                  vInvoiceTable = vContent:Table.
                  getdesc(vInvoiceTable).
                  vItems = vInvoiceTable:Item.
                  release object vInvoiceTable.
                  do vi = 1 to vItems:Count:
                     vExtendedInvoiceItem= vItems:GetItem(vi - 1).
                     getdesc(vExtendedInvoiceItem).
                     find first utd-lines where utd-lines.db-num     = utd.db-num
                                            and utd-lines.doc-id     = utd.doc-id
                                            and utd-lines.LineNum    = vi
                     exclusive-lock no-error.
                     if not available  utd-lines
                     then do:
                        create utd-lines.
                        assign
                           utd-lines.db-num   = utd.db-num
                           utd-lines.doc-id   = utd.doc-id
                           utd-lines.Linenum  = vi
                           utd-lines.gds-code = ?
                        .
                     end.
                     utd-lines.ProductCode = vExtendedInvoiceItem:Product.
                     utd-lines.UnitCode    = vExtendedInvoiceItem:UnitnAME.
                     setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity",string(vExtendedInvoiceItem:Quantity)).
                     setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Unit",string(vExtendedInvoiceItem:unit)).
                     utd-lines.Price       = vExtendedInvoiceItem:Price.
                     utd-lines.TotalWithVatExcluded   = vExtendedInvoiceItem:SubtotalWithVatExcluded.
                     utd-lines.TaxRate   =   if  vExtendedInvoiceItem:TaxRate eq "без ндс" then -1 else decimal(trim(entry(1,vExtendedInvoiceItem:TaxRate,"/"),"%")).
                     utd-lines.Vat       = vExtendedInvoiceItem:Vat.
                     utd-lines.Total     = vExtendedInvoiceItem:Subtotal.
                     utd-lines.Article   = vExtendedInvoiceItem:ItemVendorCode.
                     getdesc(vExtendedInvoiceItem:CustomsDeclarations).
                     getdesc(vExtendedInvoiceItem:CustomsDeclarations:CustomsDeclaration).
                     if vExtendedInvoiceItem:CustomsDeclarations:CustomsDeclaration:COUNT >= 1
                     then
                        getdesc(vExtendedInvoiceItem:CustomsDeclarations:CustomsDeclaration:GETITEM(0)).
                     getdesc(vExtendedInvoiceItem:AdditionalInfos).
                     getdesc(vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo).
                     if vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo:COUNT >= 1
                     then
                        getdesc(vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo:GETITEM(0)).
                     getdesc(vExtendedInvoiceItem:ItemTracingInfos).
                     getdesc(vExtendedInvoiceItem:ItemTracingInfos:ItemTracingInfo ).
                     if vExtendedInvoiceItem:ItemTracingInfos:ItemTracingInfo:COUNT >= 1
                     then
                        getdesc(vExtendedInvoiceItem:ItemTracingInfos:ItemTracingInfo:GETITEM(0) ).
                     getdesc(vExtendedInvoiceItem:ItemIdentificationNumbers).
                     getdesc(vExtendedInvoiceItem:ItemIdentificationNumbers:ItemIdentificationNumber).
                     do vii = 1 to vExtendedInvoiceItem:ItemIdentificationNumbers:ItemIdentificationNumber:COUNT:
                        vItemIdentificationNumber = vExtendedInvoiceItem:ItemIdentificationNumbers:ItemIdentificationNumber:GETITEM(vii - 1).
                        getdesc(vItemIdentificationNumber).
                        getdesc(vItemIdentificationNumber:Unit).
                        if vItemIdentificationNumber:TransPackageId ne ? and vItemIdentificationNumber:TransPackageId ne ""
                        then do:
                           VValue = repTegforDm(vItemIdentificationNumber:TransPackageId).
                           addMarkforUtd (utd-lines.db-num ,
                                          utd-lines.doc-id,
                                          utd-lines.Linenum,
                                          VValue,
                                          "",
                                          iDocument:type).
                        end.
                        vunit = vItemIdentificationNumber:Unit.
                        do viii = 1 to vunit:count:
                           vValue = vunit:GETITEM(viii - 1).
                           VValue = repTegforDm(VValue).
                           addMarkforUtd (utd-lines.db-num ,
                                          utd-lines.doc-id,
                                          utd-lines.Linenum,
                                          VValue,
                                          "",
                                          iDocument:type).
                        end.
                        release object  vunit.
                        getdesc(vItemIdentificationNumber:PackageId).
                        vunit = vItemIdentificationNumber:PackageId.
                        do viii = 1 to vunit:count:
                           VValue = vunit:GETITEM(viii - 1).
                           VValue = repTegforDm(VValue).
                           addMarkforUtd (utd-lines.db-num ,
                                          utd-lines.doc-id,
                                          utd-lines.Linenum,
                                          VValue,
                                          "",
                                          iDocument:type).
                        end.
                        release object  vunit.
                        release object vItemIdentificationNumber.
                     end.
                     vunits = vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo.
                     do vii = 1 to vunits:count:
                        vunit = vunits:GETITEM(vii - 1).
                        getdesc(vunit).
                        if     vunit:Id eq "штрихкод"
                            or vunit:Id eq "ean"
                        then do:
                           setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,vunit:Id,vunit:value).
                           setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"BarCode",vunit:value).
                           find first utd-marking-lines where       utd-marking-lines.db-num     = utd-lines.db-num
                                                          and utd-marking-lines.doc-id     = utd-lines.doc-id
                                                          and utd-marking-lines.Linenum    = utd-lines.Linenum
                           no-lock no-error.
                           if not available utd-marking-lines
                           then do:
                              vtext = vunit:Value.
                              do viii = 1 to num-entries(vtext," "):
                                 VValue = entry(viii,vtext," ").
                                 addMarkforUtd (utd-lines.db-num ,
                                          utd-lines.doc-id,
                                          utd-lines.Linenum,
                                          VValue,
                                          "",
                                          iDocument:type).
                              end.
                           end.
                        end.
                        if vunit:Id eq "Документ о соответствии" then do:
                          define variable v-sert-value as character no-undo .
                          find first utd-lines-attr exclusive-lock where utd-lines-attr.doc-id = utd-lines.doc-id and
                          utd-lines-attr.db-num = utd-lines.db-num and
                          utd-lines-attr.LineNum = utd-lines.LineNum and
                          utd-lines-attr.attr-code = "doc_sertif" no-error .
                          if available (utd-lines-attr) then utd-lines-attr.attr-value = utd-lines-attr.attr-value + "; " + vunit:value .
                          else setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"doc_sertif",vunit:value).
                        end.
                        release object  vunit.
                     end.
                     release object  vunits.
                     release utd-lines.
                     release object vExtendedInvoiceItem.
                  end.
                  release object vItems.
               end.
               else do:
                  PutMes("Ошибка получения данных из Диадок UniversalTransferDocumentWithHyphens").
                  release object vDocumentChild.
                  return error "Ошибка получения данных из Диадок UniversalTransferDocumentWithHyphens".
               end.
            end.
            else do:
               vContent = vDocumentChild:UniversalCorrectionDocument.
               if vContent ne ?
               then do:
                  getdesc(vContent).
                  getdesc(vContent:Seller).
                  getdesc(vContent:EventContent).
                  getdesc(vContent:EventContent:CorrectionBase).
                  getOrganizationInfo(vContent:Seller,output utd.cli-inn,output utd.cli-kpp,utd.cli-FnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
                  utd.cli-info = vorgname + " " + vAddrOrg.
                  do:
                      vInvoiceTable = vContent:Table.
                      getdesc(vInvoiceTable).
                      getdesc(vInvoiceTable:TotalsInc).
                      getdesc(vInvoiceTable:TotalsDec).
                      getdesc(vInvoiceTable:Items).
                      getdesc(vInvoiceTable:Items:item).
                      vItems = vInvoiceTable:Items:item.
                      release object vInvoiceTable.
                      do vi = 1 to vItems:Count:
                         vExtendedInvoiceItem = vItems:GetItem(vi - 1).
                         getdesc(vExtendedInvoiceItem).
                         getdesc(vExtendedInvoiceItem:AdditionalInfos ).
                         getdesc(vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo ).
                         find first utd-lines where utd-lines.db-num     = utd.db-num
                                                and utd-lines.doc-id     = utd.doc-id
                                                and utd-lines.LineNum    = vi
                         exclusive-lock no-error.
                         if not available  utd-lines
                         then do:
                            create utd-lines.
                            assign
                               utd-lines.db-num   = utd.db-num
                               utd-lines.doc-id   = utd.doc-id
                               utd-lines.Linenum  = vi
                               utd-lines.gds-code = ?
                            .
                         end.
                         utd-lines.ProductCode = vExtendedInvoiceItem:Product.
                         vValues = vExtendedInvoiceItem:CorrectedValues no-error.
                         if vValues ne ?
                         then do:
                            getdesc(vExtendedInvoiceItem:OriginalValues ).
                            getdesc(vExtendedInvoiceItem:CorrectedValues ).
                            getdesc(vExtendedInvoiceItem:AmountsInc ).
                            getdesc(vExtendedInvoiceItem:AmountsDec ).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Unit",string(vValues:unit)).
                            define variable vQuantity as decimal no-undo.
                            vQuantity    = vValues:Quantity.
                            utd-lines.Price       = vValues:Price.
                            utd-lines.TotalWithVatExcluded   = vValues:SubtotalWithVatExcluded.
                            utd-lines.TaxRate   =   if  vValues:TaxRate eq "без ндс" then -1 else decimal(trim(entry(1,vValues:TaxRate,"/"),"%")).
                            utd-lines.Vat       = vValues:Vat.
                            utd-lines.Total     = vValues:Subtotal.
                            release object vValues.
                            vValues = vExtendedInvoiceItem:OriginalValues.
                            vQuantity    = vQuantity - vValues:Quantity.
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity",string(vQuantity)).
                            utd-lines.Price       = utd-lines.Price - vValues:Price.
                            utd-lines.Vat       = utd-lines.Vat - vValues:Vat.
                            utd-lines.Total     = utd-lines.Total  - vValues:Subtotal.
                            utd-lines.TotalWithVatExcluded   = utd-lines.TotalWithVatExcluded - vValues:SubtotalWithVatExcluded.
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity_old",string( vValues:Quantity)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Price_old"   ,string( vValues:Price)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"TotalWithVatExcluded", string( vValues:SubtotalWithVatExcluded)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"TaxRate_old", string(  if  vValues:TaxRate eq "без ндс" then -1 else decimal(trim(entry(1,vValues:TaxRate,"/"),"%")))).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Vat_old"    , string( vValues:Vat)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Total_old",       string( vValues:Subtotal)).
                            release object vValues.
                            vunits = vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo.
                            do vii = 1 to vunits:count:
                               vunit = vunits:GETITEM(vii - 1).
                               getdesc(vunit).
                               if     vunit:Id eq "cis"
                                  or vunit:Id eq "cis_до"
                                  or vunit:Id eq "sscc"
                                  or vunit:Id eq "sscc_до"
                               then do:
                                  vtext = vunit:Value.
                                  if vtext ne "-"
                                  then do viii = 1 to num-entries(vtext," "):
                                     VValue = entry(viii,vtext," ").
                                     vsite = if     vunit:Id eq "cis" or vunit:Id eq "sscc" then "+" else "-".
                                     addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, vsite,iDocument:type).
                                  end.
                               end.
                               release object vunit.
                            end.
                            do vii = 1 to vunits:count:
                               vunit = vunits:GETITEM(vii - 1).
                               getdesc(vunit).
                               if     vunit:Id eq "штрихкод"
                                   or vunit:Id eq "ean"
                               then do:
                                  setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,vunit:Id,vunit:value).
                                  setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"BarCode",vunit:value).
                                  find first utd-marking-lines where       utd-marking-lines.db-num     = utd-lines.db-num
                                                                 and utd-marking-lines.doc-id     = utd-lines.doc-id
                                                                 and utd-marking-lines.Linenum    = utd-lines.Linenum
                                  no-lock no-error.
                                  if not available utd-marking-lines
                                  then do:
                                    vtext = vunit:Value.
                                    do viii = 1 to num-entries(vtext," "):
                                       VValue = entry(viii,vtext," ").
                                       addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, "",iDocument:type).
                                    end.
                                 end.
                              end.
                              release object  vunit.
                           end.
                            release object vunits.
                            release utd-lines.
                            release utd-marking-lines.
                         end.
                         else do:
                            getdesc(vExtendedInvoiceItem:OriginalItemIdentificationNumbers ).
                            getdesc(vExtendedInvoiceItem:OriginalItemIdentificationNumbers:ItemIdentificationNumber).
                            vunits = vExtendedInvoiceItem:OriginalItemIdentificationNumbers:ItemIdentificationNumber.
                            getdesc(vunits).
                            vsite =  "-".
                            do vii = 1 to vunits:count:
                               getdesc(vunits:GETITEM(vii - 1)).
                               vunit = vunits:GETITEM(vii - 1):unit.
                               getdesc(vunit).
                               do viii = 1 to vunit:count:
                                  vvalue = vunit:GETITEM(viii - 1).
                                  addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, vsite,iDocument:type).
                               end.
                               release object vunit.
                               vunit = vunits:GETITEM(vii - 1):PackageId.
                               getdesc(vunit).
                               do viii = 1 to vunit:count:
                                  vvalue = vunit:GETITEM(viii - 1).
                                  addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, vsite,iDocument:type).
                               end.
                               release object vunit.
                            end.
                            release object vunits.
                            getdesc(vExtendedInvoiceItem:CorrectedItemIdentificationNumbers).
                            vunits = vExtendedInvoiceItem:CorrectedItemIdentificationNumbers:ItemIdentificationNumber.
                            getdesc(vunits).
                            vsite =  "+".
                            do vii = 1 to vunits:count:
                               getdesc(vunits:GETITEM(vii - 1)).
                               vunit = vunits:GETITEM(vii - 1):unit.
                               getdesc(vunit).
                               do viii = 1 to vunit:count:
                                  vvalue = vunit:GETITEM(viii - 1).
                                  addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, vsite,iDocument:type).
                               end.
                               release object vunit.
                               vunit = vunits:GETITEM(vii - 1):PackageId.
                               getdesc(vunit).
                               do viii = 1 to vunit:count:
                                  vvalue = vunit:GETITEM(viii - 1).
                                  addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, vsite,iDocument:type).
                               end.
                               release object vunit.
                            end.
                            release object vunits.
                            getdesc(vExtendedInvoiceItem:TaxRate ).
                            getdesc(vExtendedInvoiceItem:UnitName ).
                            getdesc(vExtendedInvoiceItem:Unit ).
                            getdesc(vExtendedInvoiceItem:Quantity ).
                            getdesc(vExtendedInvoiceItem:Price ).
                            getdesc(vExtendedInvoiceItem:Excise ).
                            getdesc(vExtendedInvoiceItem:SubtotalWithVatExcluded ).
                            getdesc(vExtendedInvoiceItem:Vat ).
                            getdesc(vExtendedInvoiceItem:WithoutVat).
                            getdesc(vExtendedInvoiceItem:Subtotal ).
                            getdesc(vExtendedInvoiceItem:ItemTracingInfos ).
                            getdesc(vExtendedInvoiceItem:ItemTracingInfos:ItemTracingInfo ).
                            vValues = vExtendedInvoiceItem:CorrectedItemIdentificationNumbers.
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Unit",string(vExtendedInvoiceItem:Unit:CorrectedValue)).
                            utd-lines.Price       = vExtendedInvoiceItem:Price:CorrectedValue.
                            utd-lines.TotalWithVatExcluded   = vExtendedInvoiceItem:SubtotalWithVatExcluded:CorrectedValue.
                            utd-lines.UnitCode    = vExtendedInvoiceItem:UnitName:CorrectedValue.
                            utd-lines.TaxRate   =   if  vExtendedInvoiceItem:TaxRate:CorrectedValue eq "без ндс" then -1 else decimal(trim(entry(1,vExtendedInvoiceItem:TaxRate:CorrectedValue,"/"),"%")).
                            utd-lines.Vat       = vExtendedInvoiceItem:Vat:CorrectedValue.
                            utd-lines.Total     = vExtendedInvoiceItem:Subtotal:CorrectedValue.
                            vQuantity    = dec(vExtendedInvoiceItem:Quantity:CorrectedValue) - dec(vExtendedInvoiceItem:Quantity:OriginalValue).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity",string(vQuantity)).
                            utd-lines.Price       = utd-lines.Price - vExtendedInvoiceItem:Price:OriginalValue.
                            utd-lines.Vat       = utd-lines.Vat - vExtendedInvoiceItem:Vat:OriginalValue.
                            utd-lines.Total     = utd-lines.Total  - vExtendedInvoiceItem:Subtotal:OriginalValue.
                            utd-lines.TotalWithVatExcluded   = utd-lines.TotalWithVatExcluded - vExtendedInvoiceItem:SubtotalWithVatExcluded:OriginalValue.
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity_old",string( vExtendedInvoiceItem:Quantity:OriginalValue)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Price_old"   ,string( vExtendedInvoiceItem:Price:OriginalValue)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"TotalWithVatExcluded", string( vExtendedInvoiceItem:SubtotalWithVatExcluded:OriginalValue)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"TaxRate_old", string(  if  vExtendedInvoiceItem:TaxRate:OriginalValue eq "без ндс" then -1 else decimal(trim(entry(1,vExtendedInvoiceItem:TaxRate:OriginalValue,"/"),"%")))).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Vat_old"    , string( vExtendedInvoiceItem:Vat:OriginalValue)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Total_old",       string( vExtendedInvoiceItem:Subtotal:OriginalValue)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"UnitCode_old", vExtendedInvoiceItem:UnitName:OriginalValue).
                         end.
                         vunits = vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo.
                         getdesc(vunits).
                         do vii = 1 to vunits:count:
                            vunit = vunits:GETITEM(vii - 1).
                            getdesc(vunit).
                            if     vunit:Id eq "штрихкод"
                                or vunit:Id eq "ean"
                            then do:
                               setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,vunit:Id,vunit:value).
                               setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"BarCode",vunit:value).
                               find first utd-marking-lines where       utd-marking-lines.db-num     = utd-lines.db-num
                                                              and utd-marking-lines.doc-id     = utd-lines.doc-id
                                                              and utd-marking-lines.Linenum    = utd-lines.Linenum
                               no-lock no-error.
                               if not available utd-marking-lines
                               then do:
                                 vtext = vunit:Value.
                                 do viii = 1 to num-entries(vtext," "):
                                    VValue = entry(viii,vtext," ").
                                    addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, "",iDocument:type).
                                 end.
                              end.
                           end.
                           release object  vunit.
                        end.
                        release object  vunits.
                         release object vExtendedInvoiceItem.
                      end.
                      release object vItems.
                  end.
                  release object vContent.
               end.
               else do:
                  create tt-recid.
                  assign
                     tt-recid.orgid = vOrganizationGuid
                     tt-recid.docid = vDocumentid
                  .
                  PutMes("Error Ошибка получения данных из Диадок UniversalCorrectionDocument").
                  release object vDocumentChild.
                  return error "Ошибка получения данных из Диадок UniversalCorrectionDocument".
               end.
            end.
         end.
         release object vDocumentChild.
         define variable vsetPAck as logical no-undo.
         define variable vcli-type as character no-undo.
         define variable vcli-code as integer no-undo.
         find first ext-classif where ext-classif.classif-name  eq 'id_diadok_client':U
                                  and ext-classif.charkey_three eq utd.cli-FnsParticipantId
         no-lock no-error.
         if available ext-classif
         then do:
            assign
               vcli-type = ext-classif.CharKey_One
               vcli-code = ext-classif.Key#_One
            .
            define variable vPack as character no-undo.
            if   iDocument:type eq "UniversalTransferDocument"
            then
               vPack = substitute("&1|&2|&3|&4",vcli-type,vcli-code,utd.DocumentNumber,utd.DocumentDate).
            else if iDocument:type eq "UniversalTransferDocumentRevision"
            then
               vPack = substitute("&1|&2|&3|&4",vcli-type,vcli-code,iDocument:OriginalDocumentNumber,date(iDocument:OriginalDocumentDate)).
            else
               vPack = substitute("&1|&2|&3|&4",vcli-type,vcli-code,iDocument:OriginalInvoiceNumber,date(iDocument:OriginalInvoiceDate)).
            if vPack ne utd.PackageId
            then
               assign
                  vsetPAck      = yes
                  utd.PackageId = vPack
               .
         end.
         if vNewUtd or vsetPAck then do:
            if utd.EDocType eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
            then do:
               if vNewUtd  then do:
                  GetLastUTDinPackbef(utd.db-num,utd.doc-id,volddb-num,volddoc-id).
                  find first old_utd where old_utd.db-num eq volddb-num
                                       and old_utd.doc-id eq volddoc-id
                     no-lock no-error.
                  for each utd-marking-lines where utd-marking-lines.db-num eq utd.db-num
                                               and utd-marking-lines.doc-id eq utd.doc-id
                  exclusive-lock:
                     if available old_utd
                        and utd.db-num ne volddb-num
                        and utd.doc-id ne volddoc-id
                     then
                        find first buf_utd-marking-lines where buf_utd-marking-lines.mark       = utd-marking-lines.mark
                                                           and buf_utd-marking-lines.db-num     = old_utd.db-num
                                                           and buf_utd-marking-lines.doc-id     = old_utd.doc-id
                        no-lock no-error.
                     utd-marking-lines.sts = if available buf_utd-marking-lines then buf_utd-marking-lines.sts else  objSrv:Env:marking:Sts:Mark:PendingVerification:KeyIntDB.
                  end.
                  validate utd.
                  ReCheckload( utd.db-num, utd.doc-id,yes).
                  subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
               end.
            end.
            else do:
               GetLastUTDinPack (utd.db-num,utd.doc-id,volddb-num,volddoc-id).
               find first old_utd where old_utd.db-num eq volddb-num
                                    and old_utd.doc-id eq volddoc-id
               no-lock no-error.
               if not available old_utd
                  or (   utd.db-num eq volddb-num
                     and utd.doc-id eq volddoc-id)
               then
                  AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoAvailDoc",string(utd.PackageId) + chr(4) + string(utd.db-num) + chr(4) + string(utd.doc-id)).
               else do:
                   assign
                       utd.obj-inn               = old_utd.obj-inn
                       utd.obj-kpp               = old_utd.obj-kpp
                       utd.obj-FnsParticipantId  = old_utd.obj-FnsParticipantId
                       utd.obj-info              = old_utd.obj-info
                       utd.parentDocumentExt     = old_utd.DocumentExt
                       utd.parentOrganizationExt = old_utd.OrganizationExt
                       utd.contract-code         = old_utd.contract-code
                   .
               end.
               validate utd.
               SaturateAndCheckUTD( utd.db-num, utd.doc-id).
            end.
         end.
         GetLastUTDinPack (utd.db-num,utd.doc-id,volddb-num,volddoc-id).
         find first old_utd where old_utd.db-num eq volddb-num
                              and old_utd.doc-id eq volddoc-id
         no-lock no-error.
         if available old_utd
         then
            assign
               utd.parentDocumentExt     = old_utd.DocumentExt
               utd.parentOrganizationExt = old_utd.OrganizationExt
            .
         create tt-recid.
         assign
            tt-recid.orgid = vOrganizationGuid
            tt-recid.docid = vDocumentid
         .
         if utd.EDocType = objSrv:Env:Utd:EDocType:UCD:KeyIntDB
         then do:
            tt-recid.parent = utd.PackageId.
            tt-recid.stamp  = utd.Timestamp.
         end.
         release utd no-error.
         if error-status:error
         then
            PutMes(substitute("Документ &1 от &2 не загружен. &3" ,iDocument:DocumentNumber,iDocument:DocumentDate,return-value) ).
         else
            PutMes(substitute("Документ &1 от &2 загружен." ,iDocument:DocumentNumber,iDocument:DocumentDate) ).
         unsubscribe "getNextseq".
      end.
   end.
end.
function packetupdd returns date
(iOrganization as component-handle, iDocument as component-handle):
   define variable VPack as character no-undo.
   define variable vorgid as character no-undo.
   define variable vdocid as character no-undo.
   define variable vstamp as datetime no-undo.
   define variable VPack2 as character no-undo.
   define variable vorgid2 as character no-undo.
   define variable vdocid2 as character no-undo.
   define variable vstamp2 as datetime no-undo.
   define variable VPackage as component-handle no-undo.
   define variable vi as integer no-undo.
   define variable vDocument as component-handle no-undo.
   define variable vDocuments as component-handle no-undo.
      VPack = iDocument:PackageId.
      vorgid = iDocument:OrganizationGuid.
      vdocid = iDocument:DocumentId.
      vstamp = iDocument:Timestamp.
      find first tt-pack where tt-pack.packid eq VPack
                           and tt-pack.stamp  eq vstamp
                           and tt-pack.orgid  eq vorgid
                           and tt-pack.docid  eq vdocid
      no-lock no-error.
      if not available tt-pack
      then do:
         create tt-pack.
         assign
            tt-pack.packid = VPack
            tt-pack.stamp  = vstamp
            tt-pack.orgid  = vorgid
            tt-pack.docid  = vdocid
         .
      end.
      getdesc(iDocument ).
      getdesc(iDocument:InitialDocumentIds ).
      vDocuments = iDocument:InitialDocumentIds.
      do vi= 1 to vDocuments:Count:
         vDocument = iOrganization:GetDocumentById(vDocuments:GetItem(vi - 1),false).
         getdesc(vDocument ).
         vorgid2 = vDocument:OrganizationGuid.
         vdocid2 = vDocument:DocumentId.
         vstamp2 = vDocument:Timestamp.
         find first tt-pack where tt-pack.packid eq VPack
                              and tt-pack.stamp  eq vstamp2
                              and tt-pack.orgid  eq vorgid2
                              and tt-pack.docid  eq vdocid2
         no-lock no-error.
         if not available tt-pack
         then do:
            create tt-pack.
            assign
               tt-pack.packid = VPack
               tt-pack.stamp  = vstamp2
               tt-pack.orgid  = vorgid2
               tt-pack.docid  = vdocid2
            .
         end.
         release object vDocument.
      end.
      release object vDocuments.
end.
procedure UpdateUTDInform:
   define input  parameter ibeg-date as date no-undo.
   define input  parameter iend-date as date no-undo.
   define output parameter odatelast as date no-undo.
   define variable vOrganizationList as component-handle no-undo.
   define variable vOrganization as component-handle no-undo.
   define variable vDocumentsTask as component-handle no-undo.
   define variable vDocumentList  as component-handle no-undo.
   define variable vDocumentchildList  as component-handle no-undo.
   define variable vDocument       as component-handle no-undo.
   define buffer ext-classif_obj for ext-classif.
   define buffer ext-classif_Cli  for ext-classif.
   define variable vi  as integer no-undo.
   define variable vii as integer no-undo.
   odatelast = ibeg-date.
   vOrganizationList = mDiadocConnection:GetOrganizationList() no-error.
   if vOrganizationList eq ? then return error ?.
   vi = vOrganizationList:Count()no-error.
   if vi eq ?
   then
      return error ?.
   for each tt-recid:
      delete tt-recid.
   end.
   for each tt-pack:
      delete tt-pack.
   end.
   do vi = 1 to vOrganizationList:Count() :
      vOrganization = vOrganizationList:GetItem(vi - 1 ).
      getdesc(vOrganization).
      run changeIdtoGuid(vOrganization).
      vDocumentsTask = vOrganization:GetDocumentsTask().
                  vDocumentsTask:FromSendDate = ibeg-date  .
                  vDocumentsTask:ToSendDate   = iend-date.
                  for each tt-type, each tt-Class:
                      vDocumentsTask:Category     = tt-type.id + "." + tt-Class.id.
                     PutMes(substitute("Формируем список зависимых документов за период с &2 по &3  &1Категория: &4 &5",
                                       chr(10),
                                       ibeg-date ,
                                       iend-date,
                                       if tt-type .id eq "Any" then "" else tt-type.name,
                                       tt-Class.name)).
                      vDocumentList = vDocumentsTask:GetDocuments() no-error.
                      if vDocumentList ne ?
                      then do:
                        do vii= 1 to vDocumentList:Count:
                           if chekStop() then return ?.
                           vDocument = vDocumentList:GetItem(vii - 1).
                           odatelast = max(odatelast,vDocument:DocumentDate) no-error.
                           odatelast = min(odatelast,today).
                           packetupdd(vOrganization, vDocument).
                           release object vDocument.
                         end.
                         release object vDocumentList.
                      end.
                   end.
                   define variable VAlldoc    as integer no-undo.
                   define variable vprocessed as integer no-undo.
                   for each tt-pack :
                      VAlldoc = VAlldoc + 1.
                   end.
                   for each tt-pack :
                       if chekStop() then return ?.
                      if GetDocumforid (tt-pack.orgid, tt-pack.docid, output vDocument) eq ""
                      then do:
                          run  UpdateUTDInformOne(vDocument).
                         release object vDocument.
                     end.
                     vprocessed = vprocessed + 1.
                     PutStat (substitute ("Обработано документов &1 из &2",vprocessed,vAllDoc),yes).
                  end.
      release object vOrganization.
      release object vDocumentsTask.
   end.
   release object vOrganizationList.
end.
procedure updOneUTD:
   define input  parameter idb-num as integer no-undo.
   define input  parameter idoc-id as integer no-undo.
   define variable vDocument as component-handle no-undo.
   define buffer utd for utd.
   for each tt-recid:
      delete tt-recid.
   end.
   if getdocum (idb-num, idoc-id, output vDocument) eq ""
   then do:
       run  UpdateUTDInformOne(vDocument).
      release object vDocument.
   end.
end.
function CRnewDocum return character
(
iOrgGuid as character,
iContGuid as character,
iTypeUTD as character,
 iFile as character
 ):
define variable vOrganization as component-handle no-undo.
define variable vSendTask as component-handle no-undo.
    vOrganization = mDiadocConnection:GetOrganizationById(iOrgGuid ) no-error.
    if vOrganization ne ?
    then do:
       vSendTask = vOrganization:CreatePackageSendTask2().
       getdesc(vSendTask).
       vSendTask:CounteragentId = iContGuid  .
       vSendTask:AddDocumentFromFile("UniversalTransferDocument", iTypeUTD, "utd820_05_01_01", iFile).
       vSendTask:Send()no-error.
       if error-status:num-messages > 0 then do:
          PutErr("ERROR Ошибка отправки документа").
          return error "ERROR Ошибка отправки документа".
       end.
       else do:
          PutMes("Документ отправлен успешно.").
          message "Документ отправлен успешно."
          view-as alert-box.
       end.
       release object vSendTask.
      release object vOrganization .
   end.
end.
procedure MySeqForUtd:
   define input  parameter iTable       as character no-undo.
   define input  parameter iseqnamehist as character no-undo.
   define input  parameter idb-name     as character no-undo.
   define output parameter Oseq         as int64 no-undo.
   if iTable begins "utd"
   then do:
      if myseqUtd eq ?
      then
         myseqUtd = dynamic-next-value(iseqnamehist,idb-name).
      Oseq = myseqUtd.
   end.
   else
      Oseq = ?.
   return.
end.
FUNCTION MonthNameRusCase RETURNS CHARACTER ( INPUT i-month AS INTEGER, INPUT i-case AS INTEGER ) :
  DEFINE VARIABLE v-name AS CHARACTER NO-UNDO.
  RUN get-month-name-case IN THIS-PROCEDURE ( INPUT i-month, INPUT i-case, OUTPUT v-name ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v-name ).
END FUNCTION.
PROCEDURE get-month-name-case :
  DEFINE  INPUT PARAMETER p-month AS INTEGER   NO-UNDO.
  DEFINE  INPUT PARAMETER p-case  AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-name  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-list AS CHARACTER NO-UNDO EXTENT 6 INITIAL
    [ "Январь,Февраль,Март,Апрель,Май,Июнь,Июль,Август,Сентябрь,Октябрь,Ноябрь,Декабрь",
      "января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря",
      "Январю,Февралю,Марту,Апрелю,Маю,Июню,Июлю,Августу,Сентябрю,Октябрю,Ноябрю,Декабрю",
      "Январь,Февраль,Март,Апрель,Май,Июнь,Июль,Август,Сентябрь,Октябрь,Ноябрь,Декабрь",
      "Январем,Февралем,Мартом,Апрелем,Маем,Июнем,Июлем,Августом,Сентябрем,Октябрем,Ноябрем,Декабрем",
      "Январе,Феврале,Марте,Апреле,Мае,Июне,Июле,Августе,Сентябре,Октябре,Ноябре,Декабре"              ].
  DO ON ERROR UNDO, RETURN ERROR :
    IF p-month < 1 OR p-month > 12 OR
       p-case  < 1 OR p-case  >  6 THEN DO:
      ASSIGN p-name = ?.
    END.                           ELSE DO:
      ASSIGN p-name = ENTRY( p-month, v-list[ p-case ] ).
    END.
  END.
END PROCEDURE.
define stream Out-Stream.
define stream OutStr-html.
define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
define variable v-vendor-name       as character no-undo .
define variable v-vendor-inn        as character no-undo .
define variable v-org-name          as character no-undo .
define variable v-org-inn           as character no-undo .
define variable v-contr-code        as character no-undo .
define variable v-contr-date        as character no-undo .
define variable v-date              as character no-undo .
define variable v-utd-date          as character no-undo .
define variable v-gds-name          as character no-undo .
define variable v-itog-level        as integer   no-undo .
define variable v-itog-unit         as integer   no-undo .
define variable v-obj-info          as character no-undo .
define variable v-gtin              as character no-undo .
define variable ser-level           as character no-undo .
def    var      Marking             as class     mark no-undo .
Marking = ObjSrv:Env:Marking:Sts:Mark .
FUNCTION GdsName RETURNS CHARACTER
  ( input p-gds-code as integer)  FORWARD.
define buffer buf_utd               for ub.utd .
define buffer buf_utd-lines         for ub.utd-lines .
define buffer buf_utd-marking-lines for ub.utd-marking-lines .
define buffer buf_clients           for ub.clients .
define buffer buf_firm              for ub.firm .
define buffer buf_contract          for ub.contract .
define buffer buf_marking           for ub.marking .
define temp-table tt-utd no-undo
  field doc-id     as integer
  field db-num     as integer
  field gds-name   as character
  field gds-code   as integer
  field gtin       as character
  field qnty-unit  as integer
  field qnty-level as integer
  field ser-level  as character
  field linenum    as integer
  index pi doc-id db-num gds-code linenum
  .
do
  on error undo, return error return-value
  :
  find first buf_utd no-lock where buf_utd.doc-id = p-doc-id and buf_utd.db-num = p-db-num no-error .
  if not available (buf_utd) then
  do:
    message "УПД не найден"
      view-as alert-box.
    return .
  end.
  find first buf_clients no-lock where buf_clients.obj-code = buf_utd.cli-code and
    buf_clients.obj-type = buf_utd.cli-type no-error .
   if available (buf_clients) then v-vendor-name = buf_clients.obj-name .
  find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code no-error .
  if available (buf_firm) then
    v-vendor-inn = "ИНН: " + buf_firm.inn .
  find first buf_clients no-lock where buf_clients.obj-code = buf_utd.obj-code and
    buf_clients.obj-type = buf_utd.obj-type no-error .
  if available (buf_clients) then
  v-obj-info = buf_clients.obj-name .
  find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code no-error .
  if available (buf_firm) then
    v-obj-info = v-obj-info + " ИНН: " + buf_firm.inn .
end.
find first buf_contract no-lock where buf_contract.contract-code = buf_utd.contract-code no-error .
if available (buf_contract) then
do:
  v-contr-code = buf_contract.contract-prn-code .
  run get-DD-Month-YYYY(buf_contract.contract-date, output v-contr-date) .
end.
run get-DD-Month-YYYY(date(today), output v-date) .
run get-DD-Month-YYYY(buf_utd.DocumentDate, output v-utd-date) .
if buf_utd.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB then
do:
  for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = buf_utd.db-num and buf_utd-marking-lines.doc-id = buf_utd.doc-id and
    buf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB:
    find first tt-utd where tt-utd.doc-id = buf_utd-marking-lines.doc-id and tt-utd.db-num = buf_utd-marking-lines.db-num
      and tt-utd.linenum = buf_utd-marking-lines.LineNum and tt-utd.gds-code = buf_utd-marking-lines.gds-code no-error .
    if not available (tt-utd) then
    do:
      create tt-utd .
      assign
        tt-utd.gds-name = GdsName(buf_utd-marking-lines.gds-code)
        tt-utd.doc-id   = buf_utd-marking-lines.doc-id
        tt-utd.db-num   = buf_utd-marking-lines.db-num
        tt-utd.linenum  = buf_utd-marking-lines.LineNum
        tt-utd.gds-code = buf_utd-marking-lines.gds-code
        .
    end.
    if tt-utd.gtin <> "" then
    do:
      v-gtin = getGtinByDM(buf_utd-marking-lines.mark) .
      if lookup (tt-utd.gtin, v-gtin) = 0 then tt-utd.gtin = tt-utd.gtin + ", " + v-gtin .
    end.
    else tt-utd.gtin = getGtinByDM(buf_utd-marking-lines.mark) .
    tt-utd.gtin = getGtinByDM(buf_utd-marking-lines.mark) .
    if buf_utd-marking-lines.doc-level = 1 then
    do:
      assign
        tt-utd.qnty-level = tt-utd.qnty-level + 1
        .
      if tt-utd.ser-level <> "" then tt-utd.ser-level = tt-utd.ser-level + " " + GetTegCod(buf_utd-marking-lines.mark,"21") .
      else tt-utd.ser-level = GetTegCod(buf_utd-marking-lines.mark,"21") .
    end.
    else tt-utd.qnty-unit = tt-utd.qnty-unit + 1 .
  end.
end.
if buf_utd.EDocType = objSrv:Env:Utd:EDocType:AKT:KeyIntDB then
do:
  for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = buf_utd.db-num and buf_utd-marking-lines.doc-id = buf_utd.doc-id:
    find first tt-utd where tt-utd.doc-id = buf_utd-marking-lines.doc-id and tt-utd.db-num = buf_utd-marking-lines.db-num
      and tt-utd.linenum = buf_utd-marking-lines.LineNum and tt-utd.gds-code = buf_utd-marking-lines.gds-code no-error .
    if not available (tt-utd) then
    do:
      create tt-utd .
      assign
        tt-utd.gds-name = GdsName(buf_utd-marking-lines.gds-code)
        tt-utd.doc-id   = buf_utd-marking-lines.doc-id
        tt-utd.db-num   = buf_utd-marking-lines.db-num
        tt-utd.linenum  = buf_utd-marking-lines.LineNum
        tt-utd.gds-code = buf_utd-marking-lines.gds-code
        .
      tt-utd.gtin = getGtinByDM(buf_utd-marking-lines.mark) .
    end.
    if buf_utd-marking-lines.doc-level = 1 then
    do:
      find first buf_marking no-lock where buf_marking.mark = buf_utd-marking-lines.mark no-error .
      assign
        tt-utd.qnty-level = tt-utd.qnty-level + 1
        .
      tt-utd.qnty-unit = tt-utd.qnty-unit + buf_marking.box-qnty .
      if tt-utd.ser-level <> "" then tt-utd.ser-level = tt-utd.ser-level + " " + GetTegCod(buf_utd-marking-lines.mark,"21") .
      else tt-utd.ser-level = GetTegCod(buf_utd-marking-lines.mark,"21") .
      ser-level = "".
    end.
  end.
end.
run get-report-num (output p-report-id).
v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".
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
  '<td style="width: 10px;"></td>' skip
  '<td style="width: 30px;"></td>' skip
  '<td style="width: 5px;"></td>' skip
  '<td style="width: 20px;"></td>' skip
  '<td style="width: 5px;"></td>' skip
  '<td style="width: 40px;"></td>' skip
  '<td style="width: 20px;"></td>' skip
  '<td style="width: 30px;"></td>' skip
  '<td style="width: 40px;"></td>' skip
  '<td style="width: 5px;"></td>' skip
  '<td style="width: 20px;"></td>' skip
  '<td style="width: 5px;"></td>' skip
  '<td style="width: 10px;"></td>' skip
  '<td style="width: 30px;"></td>' skip
  '<td style="width: 40px;"></td>' skip
  '</tr>' skip
  '<tr><td colspan="15" style="text-align: center; font-weight: bold;">АКТ</td></tr>'
  '<tr><td colspan="15" style="text-align: center; font-weight: bold;">приема-передачи товара</td></tr>'
  '<tr><td colspan="15" style="text-align: center; font-weight: bold;">№' + string(buf_utd.DocumentNumber) + '</td></tr>'
  '<tr>' skip
  '<td colspan="4" style="text-align: center;">АЗК № ' + string(buf_utd.obj-code) + '</td>' skip
  '<td colspan="5" style="text-align: left;"></td>' skip
  '<td colspan="6" style="text-align: center;">' + v-date + '</td>' skip
  '</tr>' skip
  '<tr>' skip
  '<td colspan="4" style="text-align: center; vertical-align: top; font-size: 10pt;">место составления</td>' skip
  '<td colspan="5" style="text-align: left;"></td>' skip
  '<td colspan="6" style="text-align: center; vertical-align: top; font-size: 10pt;">дата составления</td>' skip
  '</tr>' skip
  '<tr>' skip
  '<td text_wrap="true" colspan="15" style="text-align: left; height: 25px;"></td>' skip
  '</tr>' skip
  '<tr>' skip
  '<td text_wrap="true" colspan="15" style="text-align: left;">Продавец (' + string(v-vendor-name) + ', ' + v-vendor-inn + ') и Покупатель (' + v-obj-info + ', Номер АЗК ' + string(buf_utd.obj-code) + '), в дальнейшем вместе именуемые «Стороны» и по отдельности «Сторона», составили настоящий Акт о нижеследующем:</td>' skip
  '</tr>' skip
  '<tr>' skip
  '<td text_wrap="true" colspan="15" style="text-align: left; height: 25px;"></td>' skip
  '</tr>' skip
  '<tr>' skip
  '<td text_wrap="true" colspan="15" style="text-align: left;">1. В соответствии с условиями Договора, заключенного между Сторонами № ' + v-contr-code + ' от ' + v-contr-date + ' по УПД ' + string(buf_utd.DocumentNumber) + ' от ' + v-utd-date + ' Продавец передает, а Покупатель принимает Товар следующего ассортимента и количества:</td>' skip
  '</tr>' skip
  .
put stream OutStr-html unformatted
  '<TR><TD colspan="15"></TD></TR>' skip
  '</thead>' skip
  '<tbody>' skip
  .
put stream OutStr-html unformatted
  '<TR>' skip
  '<TD text_wrap="true" colspan="1" style="text-align: center; font-weight: bold;">№ п/п</TD>' skip
  '<TD text_wrap="true" colspan="5" style="text-align: center; font-weight: bold;">Наименование товара</TD>' skip
  '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight: bold;">GTIN</TD>' skip
  '<TD text_wrap="true" colspan="1" style="text-align: center; font-weight: bold;">Кол-во пачек</TD>' skip
  '<TD text_wrap="true" colspan="4" style="text-align: center; font-weight: bold;">Кол-во блоков</TD>' skip
  '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight: bold;">Серийные номера блоков</TD>' skip
  '</TR>' skip .
v-itog-level = 0 .
v-itog-unit = 0 .
for each tt-utd no-lock by tt-utd.linenum:
  v-itog-level = v-itog-level + tt-utd.qnty-level .
  v-itog-unit = v-itog-unit + tt-utd.qnty-unit .
  run xmlchar-encode(tt-utd.ser-level, output ser-level) .
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string(tt-utd.linenum) + '</TD>' skip
    '<TD text_wrap="true" colspan="5" style="text-align: left;">' + string(tt-utd.gds-name) + '</TD>' skip
    '<TD text_wrap="true" colspan="2" style="text-align: center;">' + string (tt-utd.gtin) + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string (tt-utd.qnty-unit) + '</TD>' skip
    '<TD text_wrap="true" colspan="4" style="text-align: center;">' + string (tt-utd.qnty-level) + '</TD>' skip
    '<TD text_wrap="true" colspan="2" style="text-align: center;">' + ser-level + '</TD>' skip
    '</TR>'.
end.
put stream OutStr-html unformatted
  '<TR>' skip
  '<TD text_wrap="true" style="text-align: center;"></TD>' skip
  '<TD text_wrap="true" colspan="7" style="text-align: left; font-weight: bold;">ИТОГО</TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-weight: bold;">' + string (v-itog-unit) + '</TD>' skip
  '<TD text_wrap="true" colspan="4" style="text-align: center; font-weight: bold;">' + string (v-itog-level) + '</TD>' skip
  '<TD text_wrap="true" colspan="2" style="text-align: center;"></TD>' skip
  '</TR>'
  .
put stream OutStr-html unformatted
  '</tbody>' skip
  '<tfoot>' skip.
put stream OutStr-html unformatted
  '<TR style="height: 25px;">' skip
  '<TD text_wrap="true" colspan="8" style="text-align: left;">ПРОДАВЕЦ</TD>' skip
  '<TD text_wrap="true" colspan="7" style="text-align: left;">ПОКУПАТЕЛЬ</TD>' skip
  '</TR>'.
put stream OutStr-html unformatted
  '<TR style="height: 25px;">' skip
  '<TD text_wrap="true" colspan="8" style="text-align: left;">по доверенности № ____________ от _____________</TD>' skip
  '<TD text_wrap="true" colspan="7" style="text-align: left;">по доверенности № ____________ от _____________</TD>' skip
  '</TR>'.
put stream OutStr-html unformatted
  '<TR style="height: 20px;">' skip
  '<TD text_wrap="true" colspan="2" style="text-align: center; border-bottom: 1px solid black;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center; border-bottom: 1px solid black;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center; border-bottom: 1px solid black;"></TD>' skip
  '<TD text_wrap="true" colspan="2" style="text-align: center;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center; border-bottom: 1px solid black;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center; border-bottom: 1px solid black;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center;"></TD>' skip
  '<TD text_wrap="true" colspan="2" style="text-align: center; border-bottom: 1px solid black;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center;"></TD>' skip
  '</TR>'.
put stream OutStr-html unformatted
  '<TR>' skip
  '<TD text_wrap="true" colspan="2" style="text-align: center; font-size: 10pt;">должность</TD>' skip
  '<TD text_wrap="true" style="text-align: center;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-size: 10pt;">подпись</TD>' skip
  '<TD text_wrap="true" style="text-align: center;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-size: 10pt;">Ф.И.О.</TD>' skip
  '<TD text_wrap="true" colspan="2" style="text-align: center;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-size: 10pt;">должность</TD>' skip
  '<TD text_wrap="true" style="text-align: center;"></TD>' skip
  '<TD text_wrap="true" style="text-align: center; font-size: 10pt;">подпись</TD>' skip
  '<TD text_wrap="true" style="text-align: center;"></TD>' skip
  '<TD text_wrap="true" colspan="2" style="text-align: center; font-size: 10pt;">Ф.И.О.</TD>' skip
  '<TD text_wrap="true" style="text-align: center;"></TD>' skip
  '</TR>'.
put stream OutStr-html unformatted
  '<TR>' skip
  '<TD text_wrap="true" colspan="8" style="text-align: left;"></TD>' skip
  '<TD text_wrap="true" colspan="7" style="text-align: left;">М.П.</TD>' skip
  '</TR>'.
put stream OutStr-html unformatted
  '</tfoot>' skip
  '</table>' skip
  '</body>' skip
  '</html>' skip
  .
output stream OutStr-html close.
run prn-lib-reportviewer-report-name in this-procedure (
  input THIS-PROCEDURE
  ,input v-file-name-rep-htm
  ).
PROCEDURE get-report-num :
  define output parameter p-report-num as integer no-undo .
  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.
END PROCEDURE.
procedure get-DD-Month-YYYY:
  define input parameter p-dat-date as date no-undo.
  define output parameter p-str-date as character no-undo.
  define variable v-str-date  as character no-undo.
  define variable v-str-day   as character no-undo.
  define variable v-num-month as character no-undo.
  define variable v-str-month as character no-undo.
  define variable v-str-year  as character no-undo.
  v-str-date = string(p-dat-date).
  do:
    v-str-day = string(entry(1, v-str-date, "/")).
  end.
  do:
    v-num-month = entry(2, v-str-date, "/").
    v-str-month = MonthNameRusCase(integer(v-num-month), 2).
  end.
  do:
    v-str-year = string(year(p-dat-date)).
  end.
  p-str-date = '" ' + v-str-day + ' "' + " " + v-str-month + " " + v-str-year + " г.".
end procedure.
FUNCTION GdsName RETURNS CHARACTER
  ( input p-gds-code as integer) :
  define variable v-gds-name as character no-undo .
  define buffer buf_goods for ub.goods .
  find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
  if available (buf_goods) then v-gds-name = buf_goods.gds-name .
  RETURN v-gds-name.
END FUNCTION.
