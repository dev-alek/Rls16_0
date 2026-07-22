DEFINE TEMP-TABLE find_c-chk-doc NO-UNDO LIKE c-chk-doc.
DEFINE BUFFER X_c-chk-doc FOR c-chk-doc.
DEFINE BUFFER X_chk-doc FOR chk-doc.
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns  as char   no-undo .
define input parameter p-mode  as char   no-undo .
define input parameter p-doc-code like ub.chk-doc.doc-code no-undo .
define input parameter p-obj-type like ub.chk-doc.obj-type no-undo.
define input parameter p-obj-code like ub.chk-doc.obj-code no-undo.
define input-output param p-rid-list    as  char no-undo .
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision: eb58aa57459c, 2002, rls $":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author: EShklyar $":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date: Wed Sep 18 21:01:08 2019 +0300 $":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile: cchkdocs.w $":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive: str/cchkdocs.w $":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список истории чеков":U.
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
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fltfield-clear :
  define output parameter loc-fld as character no-undo.
  define output parameter loc-lab as character no-undo .
  define output parameter loc-spr as character no-undo .
  define output parameter loc-dim as character no-undo .
  assign
    loc-fld = ""
    loc-lab = ""
    loc-spr = ""
    loc-dim = "0"
  .
end procedure .
procedure fltfield-add :
  define input        parameter par-fld as character no-undo.
  define input        parameter par-lab as character no-undo .
  define input        parameter par-spr as character no-undo .
  define input-output parameter loc-fld as character no-undo.
  define input-output parameter loc-lab as character no-undo .
  define input-output parameter loc-spr as character no-undo .
  define input-output parameter loc-dim as character no-undo .
  do
  on error undo, return error
  :
    assign
    loc-fld = if loc-dim = '0'
              then par-fld
              else (loc-fld + chr(44) + par-fld)
    loc-lab = if loc-dim = '0'
              then par-lab
              else (loc-lab + chr(44) + par-lab)
    loc-spr = if loc-dim = '0'
              then par-spr
              else (loc-spr + chr(44) + par-spr)
    loc-dim = (if num-entries(loc-dim) > 1 then (entry(1, loc-dim) + chr(44)) else "") +
              string(integer(if num-entries(loc-dim) > 1
                            then entry(2, loc-dim)
                            else entry(1, loc-dim)
                            ) + 1)
    no-error
    .
  end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table temp-changes no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
field t_name as character
field num_ as integer
field uniq-key-rec as character
field action as integer
field fNotChange as logical
index pi is unique primary
num_
t_name
f_name
index
Chan
fnotChange
t_name
f_name
index imain uniq-key-rec
.
FUNCTION get-all-fields returns character (p-file-name as character ):
define variable v-dop as character no-undo .
  find first _file no-lock where _file._file-name = p-file-name no-error .
  if not available _file then return "":U.
  for each _field no-lock where
           _field._file-recid = recid(_file) :
    assign
    v-dop = v-dop + _field._field-name + chr(44)
    .
  end.
  return trim(v-dop).
END FUNCTION.
PROCEDURE proc-full-temp-changes :
  define input  parameter p-hst-handle as handle    no-undo .
  define input  parameter p-main-table as character no-undo .
  define input  parameter p-field-list as character no-undo .
  define input  parameter p-label-form as character no-undo .
  define variable h-new-buf         as handle    no-undo .
  define variable h-main-buf        as handle    no-undo .
  define variable h-for-comp        as handle    no-undo .
  define variable v-inform          as character no-undo .
  define variable v-ind             as integer   no-undo .
  define variable v-idx-field-qnty  as integer   no-undo .
  define variable v-num-entries     as integer   no-undo .
  define variable fh                as handle    no-undo .
  define variable fh-main           as handle    no-undo .
  define variable fh-old            as handle    no-undo .
  define variable fh-new            as handle    no-undo .
  define variable v-field-name      as character no-undo .
  define variable v-field-lvl       as character no-undo .
  define variable v-field-form      as character no-undo .
  define variable v-search-exp      as character no-undo .
  define variable v-srch-main       as character no-undo .
  define variable v-word-link       as character no-undo .
  define variable v-av-chip-num     as logical   no-undo .
  define variable v-main-pi-fld-lst as character no-undo .
  define variable v-main-fld-lst    as character no-undo .
  define variable v-delim-list      as character no-undo .
  define variable v-label           as character no-undo .
  define variable v-old-value       as character no-undo case-sensitive.
  define variable v-new-value       as character no-undo case-sensitive.
  define variable v-chg-fields as character no-undo.
  for each temp-changes:
    delete temp-changes.
  end.
  if not p-hst-handle:available then do:
    return .
  end.
  create buffer h-new-buf  for table p-hst-handle .
  create buffer h-main-buf for table p-main-table .
  assign
    v-inform = h-main-buf:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = h-main-buf:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, h-main-buf:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, h-main-buf:name ).
  end.
  assign
    v-srch-main   = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
    v-delim-list  = "":U
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name      = entry( 4 + v-ind, v-inform, ",":U )
      fh                = p-hst-handle:buffer-field( v-field-name )
      fh-main           = h-main-buf:buffer-field( v-field-name )
      v-srch-main       = substitute( "&1 &2 &3.&4 =", v-srch-main, v-word-link, fh-main:table, v-field-name )
      v-main-pi-fld-lst = v-main-pi-fld-lst + v-delim-list + v-field-name
    .
    if fh:data-type ="character":U then do:
      assign
        v-srch-main = substitute( '&1 "&2"', v-srch-main, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-srch-main = substitute( "&1 &2", v-srch-main, fh:buffer-value() )
      .
    end.
    if v-delim-list = "":U then do:
      assign
        v-delim-list = ",":U
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  assign
    v-delim-list  = "":U
  .
  do v-ind = 1 to h-main-buf:num-fields
  on error undo, return error
  :
    assign
      fh-main      = h-main-buf:buffer-field( v-ind )
      v-field-name = fh-main:name
    .
      assign
        v-main-fld-lst = v-main-fld-lst + v-delim-list + v-field-name
      .
      if v-delim-list = "":U then do:
        assign
          v-delim-list = ",":U
        .
      end.
  end.
  assign
    v-inform = p-hst-handle:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = p-hst-handle:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, p-hst-handle:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, p-hst-handle:name ).
  end.
  assign
    v-search-exp  = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name = entry( 4 + v-ind, v-inform, ",":U )
      fh           = p-hst-handle:buffer-field( v-field-name )
      v-search-exp = substitute( "&1 &2 &3.&4", v-search-exp, v-word-link, fh:table, v-field-name )
    .
    if v-field-name = "chip-num":U then do:
      assign
        v-search-exp  = substitute( "&1 >", v-search-exp )
        v-av-chip-num = true
      .
    end.
    else do:
      assign
        v-search-exp = substitute( "&1 =", v-search-exp )
      .
    end.
    if fh:data-type ="character":U then do:
      assign
        v-search-exp = substitute( '&1 "&2"', v-search-exp, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-search-exp = substitute( '&1 &2', v-search-exp, fh:buffer-value() )
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  if v-av-chip-num = false then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Таблица &2 не содержит поля chip-num.", vss-workfile, p-hst-handle:name ) skip
      "Использование данной процедуры невозможно!" skip
      view-as alert-box error .
    return error .
  end.
  h-new-buf:find-first( v-search-exp, no-lock ) no-error .
  if not h-new-buf:available then do:
    h-main-buf:find-first( v-srch-main, no-lock ) no-error .
    if not h-main-buf:available then do:
      assign
        h-for-comp = ?
      .
    end.
    else do:
      assign
        h-for-comp = h-main-buf
      .
    end.
  end.
  else do:
    assign
      h-for-comp = h-new-buf
    .
  end.
  assign
    v-num-entries = num-entries( v-main-fld-lst, ",":U )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    assign
      v-field-name = entry( v-ind, v-main-fld-lst )
      fh-old       = p-hst-handle:buffer-field( v-field-name )
      v-old-value  = fh-old:buffer-value()
      v-label      = trim( fh-old:label )
    .
    if ( trim( p-field-list ) <> "":U
         and lookup( v-field-name, p-field-list ) > 0
       )
       or trim( p-field-list ) = "":U
    then do:
      if h-for-comp <> ? then do:
        assign
          fh-new      = h-for-comp:buffer-field( v-field-name )
          v-new-value = fh-new:buffer-value()
        .
      end.
      else do:
        assign
          v-new-value = "":U
        .
      end.
      if v-old-value <> v-new-value
      then do:
        create temp-changes.
        assign
          temp-changes.t_name = p-main-table
          temp-changes.f_name = v-field-name
          temp-changes.l_name = replace( v-label, "&":U, "":U )
          temp-changes.v_old  = trim( v-old-value )
          temp-changes.v_new  = trim( v-new-value )
          temp-changes.num_   = 0
          temp-changes.fNotChange = v-old-value eq v-new-value
        .
      end.
    end.
  end.
  assign
    v-num-entries = num-entries( p-label-form, chr(8) )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    if num-entries( entry( v-ind, p-label-form, chr(8) ), chr(4) ) = 3 then do:
      assign
        v-field-name = entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-lvl  = entry( 2, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-form = entry( 3, entry( v-ind, p-label-form, chr(8) ), chr(4) )
      .
      find first temp-changes
        where temp-changes.f_name = v-field-name
        no-error .
      if available temp-changes then do:
        if trim( v-field-lvl ) <> "":U then do:
          assign
            temp-changes.l_name = v-field-lvl
          .
        end.
        if trim( v-field-form ) <> "":U then do:
          assign
            temp-changes.v_old = dynamic-function( v-field-form, temp-changes.v_old )
          .
          if h-for-comp <> ? then do:
            assign
              temp-changes.v_new = dynamic-function( v-field-form, temp-changes.v_new )
            .
          end.
        end.
      end.
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка! Список должен содержать три поля с разделителем delim-par!" skip
        substitute( "список для поля '&1': '&2'"
                    ,entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
                    ,entry( v-ind, p-label-form, chr(8) )
                  ) skip
        substitute( "полный список: &2", p-label-form ) skip
        view-as alert-box error .
    end.
  end.
  delete object h-new-buf .
  delete object h-main-buf .
END PROCEDURE.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
function shift-name-no-err return char (
                                        buffer loc-c-chk-doc for ub.c-chk-doc
 ).
define variable varshift-name as character no-undo.
define variable varshift-name-num as character no-undo.
  varshift-name = loc-c-chk-doc.shift-name.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_shiftnme in g#lib-trn3 ( input  loc-c-chk-doc.obj-type,
                       input  loc-c-chk-doc.obj-code,
                       input  loc-c-chk-doc.shift-date,
                       input  loc-c-chk-doc.shift-num,
                       input-output varshift-name,
                       output varshift-name-num
                       ) no-error .
  if error-status:error then do:
    return "":u.
  end.
  return varshift-name-num.
end function.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  p-user-id
  ,output v-user-name
  ) no-error .
if error-status:error
or v-user-name = ""
then do:
  return p-user-id.
end.
else do:
  return v-user-name.
end.
end function.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-fltopend-rowid as rowid extent 18 no-undo .
procedure fltopend_fltopend :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
  do
  on error undo, return error
  :
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
assign
v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                   p-where-cond + chr(32)  +
                   p-use-indFIRST-query-tail + chr(32) +
                   p-use-ind-sort-clmn-by + chr(32) +
                   p-indexed-reposition
.
assign
glog = p-qh:query-prepare(v-prepare-string) no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
assign
glog = p-qh:query-open no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
  end.
end procedure.
procedure fltopend_fltfindd :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-index-phrase as character no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-recid as recid no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  glog = p-bh:find-by-rowid( p-rowid, p-lock) no-error.
  create buffer v-bh for table p-bh buffer-name p-bh:name.
  create query v-qh.
  v-qh:set-buffers(v-bh).
  v-prepare-string = substitute("for each &1 &2 &3"
                                  ,v-bh:name
                                  ,p-where-cond
                                  ,p-use-index-phrase).
  glog = v-qh:query-prepare(v-prepare-string) no-error.
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  if p-next then do:
    v-qh:reposition-to-rowid(p-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  v-recid = v-bh:recid no-error .
  delete object v-qh.
  delete object v-bh.
  return string(v-recid) .
end.
end procedure.
procedure fltopend_fltfindq :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
define output parameter p-fltopend-rowid as rowid extent 18 no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo extent 18.
define variable v-rowid as rowid no-undo extent 18.
define variable v-ii as integer no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  create query v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    create buffer v-bh[v-ii] for table p-qh:get-buffer-handle(v-ii) buffer-name p-qh:get-buffer-handle(v-ii):name .
    assign
    v-rowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid
    no-error.
    v-qh:add-buffer(v-bh[v-ii]).
  end.
  assign
  v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                    p-where-cond + chr(32)  +
                    p-use-indFIRST-query-tail + chr(32) +
                    p-use-ind-sort-clmn-by + chr(32) +
                    p-indexed-reposition
  .
  glog = v-qh:query-prepare( v-prepare-string) no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  if p-next then do:
    glog = v-qh:reposition-to-rowid(v-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  do v-ii = 1 to p-qh:num-buffers:
    assign
    p-fltopend-rowid[v-ii] = v-bh[v-ii]:rowid
    no-error.
  end.
  delete object v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    delete object v-bh[v-ii].
  end.
end.
end procedure.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable filter-label as character no-undo init "Список истории чеков" .
define variable filter-label0 as character no-undo init "Список истории чеков" .
define variable filter-point as character no-undo init "cchkdocs" .
define variable filter-point0 as character no-undo init "cchkdocs" .
define variable sort-column-name as character no-undo .
define variable print-option as character no-undo.
DEFINE VARIABLE v-host-code like ub.sysconf.host-code no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable v-base-type like ub.currency.curr-abbr no-undo .
define variable glog as logical no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable par-l-mask  as logical no-undo .
define variable v-param-type as character no-undo .
define variable v_d-card  as character no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable paycardv as character no-undo .
FUNCTION f-paycardv RETURNS CHARACTER(input p-pay-card as character, p-cash-pay-obj-code as integer, p-cash-pay-curr-code as integer):
define variable kk as integer no-undo .
define variable pay-card-num as character no-undo .
define buffer buf_cash-pay for ub.cash-pay.
find first buf_cash-pay no-lock where
           buf_cash-pay.cdpay-code = p-cash-pay-obj-code
       AND buf_cash-pay.curr-code = p-cash-pay-curr-code no-error .
if not avail buf_cash-pay then return "":U.
if p-pay-card = "":u
or p-pay-card = ? then return "":U.
assign
pay-card-num = "":U
.
_kk:
do kk = 1 to num-entries(buf_cash-pay.pay-card-view):
  if p-pay-card begins entry(kk, buf_cash-pay.pay-card-view) then do:
    assign
    pay-card-num = p-pay-card
    .
    return pay-card-num.
  end.
end.
if pay-card-num = "":u then do:
  if length(p-pay-card) > 4 then
  assign
  pay-card-num = fill("*":U, length(p-pay-card) - 4) +
                  substr(p-pay-card, (length(p-pay-card) - 3), 4)
  .
  else
  return fill("*":U, length(p-pay-card)).
end.
return pay-card-num.
END FUNCTION.
FUNCTION get-wro-name returns character(input p-write-off-code as integer):
return entry (lookup ((if p-write-off-code = ? then chr(63) else string(p-write-off-code)),  '?,0,1,-6,-9,2,-2,3,-3,-4,17':U), ',,Без_оплаты,Отмена_позиции,Полн_Отмена,Модификатор,Модификатор,Модификатор(+спис),Модификатор(-спис),Модификатор(-спис),Техпролив':U).
END FUNCTION.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-restore
     LABEL "Восс&танов."
     SIZE 10 BY 1.
DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.
DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE ED-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.
DEFINE QUERY BR-docs FOR X_c-chk-doc SCROLLING.
DEFINE BROWSE BR-changes
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(50)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(70)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(70)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6.
DEFINE BROWSE BR-docs
  QUERY BR-docs DISPLAY
      mark-string(RECID( X_c-chk-doc), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_c-chk-doc.corr-date COLUMN-LABEL "Дата корр" FORMAT "99/99/9999":U
      string(X_c-chk-doc.corr-time, "HH:MM")
      X_c-chk-doc.corr-user-db-num FORMAT ">>>>9":U
      usrfulnf(X_c-chk-doc.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
      X_c-chk-doc.office COLUMN-LABEL "_Тип_" FORMAT "X(7)":U
      X_c-chk-doc.is-add FORMAT "+/":U
      X_c-chk-doc.is-del FORMAT "+/":U
      X_c-chk-doc.doc-code COLUMN-LABEL "Номер_чека" FORMAT "X(20)":U
      X_c-chk-doc.chk-num COLUMN-LABEL "N_по_кассе" FORMAT "->>>>>>>>9":U
      X_c-chk-doc.chk-date FORMAT "99/99/9999":U
      X_c-chk-doc.shift-date COLUMN-LABEL "Смена_от" FORMAT "99/99/9999":U
      shift-name-no-err(buffer X_c-chk-doc) COLUMN-LABEL "№ см." FORMAT "X(6)":U
            WIDTH 7
      (string (X_c-chk-doc.chk-time, "HH:MM"))
      X_c-chk-doc.netto COLUMN-LABEL "Сумма_оплат" FORMAT "->>>,>>>,>>9.99":U
      X_c-chk-doc.tot-doc COLUMN-LABEL "Сумма_товарная" FORMAT "->>>,>>>,>>9.99":U
      X_c-chk-doc.discnt COLUMN-LABEL "Скидка_общая" FORMAT "->>>,>>>,>>9.99":U
      X_c-chk-doc.sub-discnt COLUMN-LABEL "Скидка_на_итог" FORMAT "->>>,>>>,>>9.99":U
      X_c-chk-doc.pay-desk FORMAT ">>>9":U
      X_c-chk-doc.cashier FORMAT "99999":U
      X_c-chk-doc.sales-man COLUMN-LABEL "Прод-w" FORMAT "99999":U
      X_c-chk-doc.out-code COLUMN-LABEL "Номер_РН" FORMAT "X(14)":U
      v_d-card COLUMN-LABEL "N_диск._карты" FORMAT "X(19)":U
  ENABLE
      X_c-chk-doc.cashier
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.04.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-lkp AT ROW 1 COL 41
     b-restore AT ROW 1 COL 51
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     BR-docs AT ROW 2.67 COL 1
     ED-notes AT ROW 12.08 COL 1 NO-LABEL
     BR-changes AT ROW 14.67 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(78.50) SKIP(18.67)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       BR-docs:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  p-rid-list = v-rid-list.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame
DO:
  run proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
  if available X_c-chk-doc then do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid19 as character no-undo .
define variable v-num-entry19 as integer   no-undo .
assign
  v-str-recid19 = trim( string( recid( X_c-chk-doc ) , "->>>>>>>>>>>9":U ) )
  v-num-entry19 = lookup( v-str-recid19 , v-rid-list )
.
if v-num-entry19 > 0 then do:
  assign
    entry( v-num-entry19, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid19
  .
end.
    glog = br-docs:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        glog = br-docs:select-next-row ().
        apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame Dialog-Frame.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame Dialog-Frame.
  end.
  apply "entry" to br-docs in frame Dialog-Frame.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
    run proc-b-print in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF b-restore IN FRAME Dialog-Frame
DO:
  run proc-b-restore IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
DO:
  if ( available X_c-chk-doc ) AND
  ( v-rid-list = ""
  or
  b-mark:sensitive = no
  ) then
    v-rid-list = string( recid( X_c-chk-doc ) ) .
END.
ON DELETE-CHARACTER OF BR-docs IN FRAME Dialog-Frame
DO:
  if b-mark:sensitive in frame Dialog-Frame then
  APPLY "CHOOSE" to b-mark.
END.
ON INSERT-MODE OF BR-docs IN FRAME Dialog-Frame
DO:
  if b-mark:sensitive in frame Dialog-Frame then
  APPLY "CHOOSE" to b-mark.
    else do:
      if b-sel:sensitive in frame Dialog-Frame then
      APPLY "CHOOSE" to b-sel.
    end.
END.
ON RETURN OF BR-docs IN FRAME Dialog-Frame
OR MOUSE-SELECT-DBLCLICK OF BR-docs IN FRAME Dialog-Frame
DO:
if b-sel:sensitive in frame Dialog-Frame then dO:
    if b-mark:sensitive then do:
        apply "choose" to b-mark in frame Dialog-Frame.
    end.
    else do:
        apply "choose" to b-sel in frame Dialog-Frame.
    end.
end.
END.
ON VALUE-CHANGED OF BR-docs IN FRAME Dialog-Frame
DO:
    DEFINE VARIABLE dops as character no-undo .
  dops = if available X_c-chk-doc then X_c-chk-doc.ps else '':U.
  ED-notes:screen-value = dops.
  run proc-view-changes in this-procedure .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse BR-docs :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame Dialog-Frame:
    if p-filter-name > "" then do:
      assign
        frame Dialog-Frame:title
          = frame Dialog-Frame:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :tooltip = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :tooltip = ""
      .
    end.
  end.
end procedure.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
  v-doc-rec = recid(X_c-chk-doc). run OpenBr in this-procedure ( input yes, input no, input '':U). reposition br-docs to recid v-doc-rec no-error. v-doc-rec = ?.               apply 'value-changed' to br-docs.
    apply "VALUE-CHANGED" to BR-changes.
end.
def var sort-labelbr-docs   as character no-undo .
def var sort-clmnbr-docs    as handle    no-undo .
def var cur-clmnbr-docs     as handle    no-undo .
def var cur-clmn-locbr-docs as integer   no-undo .
def var re-querybr-docs     as logical   initial no no-undo .
on start-search, ctrl-o of br-docs in frame Dialog-Frame do:
   run sort-brbr-docs
     (input (if available X_c-chk-doc
             then recid(X_c-chk-doc)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-docs :
  define input parameter p-recid as recid no-undo .
  if re-querybr-docs = no then do:
    assign
       cur-clmnbr-docs = br-docs:current-column in frame Dialog-Frame
    .
    if sort-clmnbr-docs <> ? then sort-clmnbr-docs:column-fgcolor = 0.
    if cur-clmnbr-docs = sort-clmnbr-docs then do:
      assign
         sort-labelbr-docs = ""
         sort-clmnbr-docs = ?
      .
     end.
     else do:
       assign
         sort-labelbr-docs = cur-clmnbr-docs:label
         sort-clmnbr-docs  = cur-clmnbr-docs
         sort-clmnbr-docs:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-docs = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-docs:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-docs then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-docs = cur-clmn-locbr-docs + 1
    .
  end.
  case sort-labelbr-docs:
        when X_c-chk-doc.corr-date:label in browse br-docs then DO:    assign       sort-column-name = "X_c-chk-doc.corr-date"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when X_c-chk-doc.doc-code:label in browse br-docs then DO:    assign       sort-column-name = "X_c-chk-doc.doc-code"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when X_c-chk-doc.chk-date:label in browse br-docs then DO:    assign       sort-column-name = "X_c-chk-doc.chk-date"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when X_c-chk-doc.shift-date:label in browse br-docs then DO:    assign       sort-column-name = "X_c-chk-doc.shift-date"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure ( input yes, input no, input '').
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-docs') then do:
          run mv-brw-defaultbr-docs.
        end.
      if sort-labelbr-docs <> "" then do:
        assign
          cur-clmnbr-docs:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-docs = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-docs to recid p-recid no-error.
    apply "value-changed" to br-docs in frame Dialog-Frame.
  end.
  apply "entry" to br-docs in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-docs:
if cur-clmnbr-docs = ? then do:
   run OpenBr in this-procedure ( input yes, input no, input '').
end.
else do:
   assign re-querybr-docs = yes.
   run sort-brbr-docs
     (input (if available X_c-chk-doc
             then recid(X_c-chk-doc)
             else ?
            )
     ).
   assign re-querybr-docs = no.
end.
end.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-docs as INT EXTENT 17 no-undo.
DEF VAR varmvibr-docs       as INT no-undo.
DEF VAR varmvjbr-docs       as INT no-undo.
DEF VAR varmvkbr-docs       as INT no-undo.
DEF VAR varmvlbr-docs       as INT no-undo.
DEF VAR move-elementbr-docs as INT no-undo.
def var jjbr-docs           as int no-undo.
do varmvibr-docs = 1 to EXTENT(cur-clmn-numbr-docs):
  ASSIGN cur-clmn-numbr-docs[varmvibr-docs] = varmvibr-docs.
END.
RUN start-mv-clmnbr-docs.
PROCEDURE start-mv-clmnbr-docs:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-docs do:
  RUN re-move-clmnbr-docs ( 7, 17).
END.
ON ctrl-cursor-left OF BROWSE br-docs do:
  RUN re-move-clmnbr-docs (17, 7).
END.
PROCEDURE re-move-clmnbr-docs:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = source-column THEN cur-clmn-numbr-docs[varmvibr-docs] = -1.
  END.
  if br-docs:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjbr-docs = source-column - 1 to target-column BY -1:
    DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
        if cur-clmn-numbr-docs[varmvibr-docs] = varmvjbr-docs THEN DO:
          cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-numbr-docs[varmvibr-docs] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-docs = source-column + 1 to target-column:
    DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
      if cur-clmn-numbr-docs[varmvibr-docs] = varmvjbr-docs THEN DO:
        cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-numbr-docs[varmvibr-docs] - 1.
      END.
    END.
  END.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = -1 THEN cur-clmn-numbr-docs[varmvibr-docs] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-docs:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 7 then do:
    return .
  end.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-loc THEN move-elementbr-docs = varmvibr-docs.
  END.
  RUN re-move-clmnbr-docs (cur-clmn-loc, 7).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-docs:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-docs = 7 to EXTENT(cur-clmn-numbr-docs):
    RUN re-move-clmnbr-docs (cur-clmn-numbr-docs[varmvlbr-docs], varmvlbr-docs).
  END.
  RUN start-mv-clmnbr-docs.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if p-mode <> "one":U
and p-mode <> 'удаление':U
and p-mode <> 'ДОБАВЛЕНИЕ':U
then do:
  message vss-workfile vss-revision vss-description skip
  "Неверное значение параметра вызова p-mode" p-mode
  view-as alert-box ERROR.
  return.
end.
  define variable n_MyEnable AS LOGICAL no-undo .
  if p-mode = "one":U then do:
    FIND FIRST X_c-chk-doc No-LOCK where
                X_c-chk-doc.doc-code = p-doc-code
                No-ERROR.
    if not avail X_c-chk-doc then do:
    n_MyEnable = yes .
      message "История изменений для чека " p-doc-code " не найдена." view-as alert-box .
    end.
  end.
if not n_MyEnable then do:
  v-rid-list = p-rid-list.
  if v-rid-list <> "" then do:
      FIND FIRST find_c-chk-doc No-LOCK where
                 recid(find_c-chk-doc) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_c-chk-doc then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова v-rid-list" v-rid-list
        view-as alert-box error .
        return error.
      end.
      v-doc-rec = integer(entry(1, v-rid-list)).
  end.
  run adm/shattri.p (
      input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'dc-ref':U
    ,input  'l-mask':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output par-l-mask
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
for each thbjattr_thbj-attr where
       thbjattr_thbj-attr.obj-type = p-obj-type
   and thbjattr_thbj-attr.obj-code = p-obj-code
   and thbjattr_thbj-attr.upper-prop-code = 'dc-ref':U
on error undo, return error return-value :
  case thbjattr_thbj-attr.prop-code:
    when 'l-mask':U then do:
      assign
      par-l-mask = thbjattr_thbj-attr.property-value-logical.
    end.
  end case.
end.
    run MyEnable in this-procedure .
    RUn OpenBR in this-procedure ( input yes, input no, input '':U).
    HIDE mark-num in frame Dialog-Frame .
    REPOSITION br-docs to row 1 No-ERROR.
    run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  browse br-changes :handle
    ) .
    run diasize_init in this-procedure .
    WAIT-FOR GO OF FRAME Dialog-Frame.
end.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY ED-notes mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-lkp b-restore B-print B-sch B-Help BR-docs
         ED-notes BR-changes mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE get-line-changes-current :
define input parameter p-chip-num like ub.c-chk-doc.chip-num no-undo .
define variable v-chg-fields as character no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-field-name as character no-undo .
define variable v-field-label as character no-undo .
define variable v-field-function as character no-undo .
define variable v-real-field-name as character no-undo .
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer buf_chk-doc-attr for ub.chk-doc-attr.
define buffer buf_c-chk-gds for ub.c-chk-gds.
define buffer buf_c-chk-pay for ub.c-chk-pay.
define buffer buf_c-chk-discnt for ub.c-chk-discnt.
define buffer buf_c-chk-doc-attr for ub.c-chk-doc-attr.
for each buf_chk-gds no-lock where
            buf_chk-gds.doc-code = p-doc-code,
    first buf_c-chk-gds no-lock where
         buf_c-chk-gds.doc-code = p-doc-code
     AND buf_c-chk-gds.chip-num = p-chip-num
     AND buf_c-chk-gds.line-num = buf_chk-gds.line-num
            :
  buffer-compare
  buf_chk-gds to buf_c-chk-gds
  case-sensitive
  save result in v-chg-fields.
  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, "b-code,depart-code,depart-id,depart-type,discnt,doc-qnty,is-error," +                         "line-num,line-sign,line-type,loc1,nozzle-code,pass-gds,price-base,price-list-id,price-service,pump," +                         "road-tax,sales-man,salesman-psn-code,src-code,src-discnt,src-price,src-qnty," +                         "src-sum,sum-base,time-oper,write-off-code").
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, "Бар-код в БД,Код подразделения,ID подразделения,Тип подразделения,Скидка в БД,Количество,Ош," +                         "Номер строки,Знак строки,Тип,Резервуар,Пистолет,Ввод кода товара,Цена в БД,Прайс-лист,Цена серв. эл-та,Номер ТРК," +                         "Дорожный налог,Продавец,Код продавца в БД,Исходный бар-код,Скидка в чеке,Цена чека,Количество в чеке," +                         "Сумма строки в чеке,Сумма строки в БД,Время в сек,Код списания")
    v-field-function = entry(jj, ",,,,,,," +                         ",,,,,,,,,," +                         ",,,,,,," +                         ",,,get-wro-name")
    v-real-field-name = entry(1, v-field-name, ':')
    .
    create temp-changes.
    assign
    temp-changes.f_name = substitute("chk-gds&1&2&1&3"
                                     ,chr(4)
                                     ,buf_chk-gds.line-num
                                     ,v-field-name)
    temp-changes.l_name = substitute("Строка товара &1 &2"
                                     ,buf_chk-gds.line-num
                                     ,v-field-label)
    temp-changes.v_old = string(buffer buf_c-chk-gds:buffer-field(v-real-field-name):buffer-value)
    temp-changes.v_new = string(buffer buf_chk-gds:buffer-field(v-real-field-name):buffer-value)
    .
    if v-field-function <> '':U then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.
  end.
end.
for each buf_chk-pay no-lock where
            buf_chk-pay.doc-code = p-doc-code,
    first buf_c-chk-pay no-lock where
         buf_c-chk-pay.doc-code = p-doc-code
     AND buf_c-chk-pay.chip-num = p-chip-num
     AND buf_c-chk-pay.line-num = buf_chk-pay.line-num:
  buffer-compare
  buf_chk-pay to buf_c-chk-pay
  case-sensitive
  save result in v-chg-fields.
  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, "bank-rate,bank-scale,cash-rate,curr-code,is-error,line-num,line-sign," +                        "line-type,pass-pay,pay-card,pay-code,time-oper," +                        "tot-base,tot-rubl,tot-sum").
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, "Курс ЦБ РФ,Масштаб курса банка ЦБ РФ,Курс,Код валюты,Ош,Номер строки,Знак строки," +                         "Тип,Прохождение платежа (картой или вручную),Номер пл карты карты,код оплаты,Время в сек," +                         "Сумма в баз.в.,Сумма в руб.,Сумма в валюте оплаты")
    v-real-field-name = entry(1, v-field-name, ':')
    .
    create temp-changes.
    assign
    temp-changes.f_name = substitute("chk-pay&1&2&2&3"
                                     ,chr(4)
                                     ,buf_chk-pay.line-num
                                     ,v-field-name)
    temp-changes.l_name = substitute("Строка оплат &1 &2"
                                      ,buf_chk-pay.line-num
                                      ,v-field-label)
    temp-changes.v_old = string(buffer buf_c-chk-pay:buffer-field(v-real-field-name):buffer-value)
    temp-changes.v_new = string(buffer buf_chk-pay:buffer-field(v-real-field-name):buffer-value)
    .
  end.
end.
for each buf_chk-discnt no-lock where
            buf_chk-discnt.doc-code = p-doc-code,
    first buf_c-chk-discnt no-lock where
          buf_c-chk-discnt.doc-code = p-doc-code
      AND buf_c-chk-discnt.chip-num = p-chip-num
      AND buf_c-chk-discnt.line-num = buf_chk-discnt.line-num
  :
  if buf_c-chk-discnt.record-type = 2 then NEXT.
  buffer-compare
  buf_chk-discnt to buf_c-chk-discnt
  case-sensitive
  save result in v-chg-fields.
  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, "discnt-id,discnt-type,discnt-value-abs,discnt-value-pcnt,is-error,line-num,line-sign," +                         "line-type,object-line-num,object-qnty,object-sum,pass-discnt,record-type,time-oper,value-type").
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, "Вн.№ скидки,Тип скидки,Abs значение скидки,Проц значение скидки,Ош,№ строки скидки,Знак строки," +                          "Тип,№ товарной строки для скидки,Количество,Сумма до скидки,Ввод скидки (картой или вручную),Тип записи,Время в сек,Тип значения")
    v-real-field-name = entry(1, v-field-name, ':')
    .
    create temp-changes.
    assign
    temp-changes.f_name = substitute("chk-discnt&1&2&1&3&1&4&1&5&1&6"
                                     ,chr(4)
                                     ,buf_chk-discnt.record-type
                                     ,buf_chk-discnt.line-num
                                     ,buf_chk-discnt.object-line-num
                                     ,buf_chk-discnt.discnt-id
                                     ,v-field-name)
    temp-changes.l_name = substitute("Строка скидки &1 &2 к строке &3 &4"
                                     ,buf_chk-discnt.line-num
                                     ,(if buf_chk-discnt.record-type = 0 then ' (исх) ' else ' (выч) ')
                                     ,buf_chk-discnt.object-line-num
                                     ,v-field-label)
    temp-changes.v_old = string(buffer buf_c-chk-discnt:buffer-field(v-real-field-name):buffer-value)
    temp-changes.v_new = string(buffer buf_chk-discnt:buffer-field(v-real-field-name):buffer-value)
    .
  end.
end.
for each buf_chk-doc-attr no-lock where
            buf_chk-doc-attr.doc-code = p-doc-code,
    first buf_c-chk-doc-attr no-lock where
         buf_c-chk-doc-attr.chip-num = p-chip-num
      AND buf_c-chk-doc-attr.doc-code = p-doc-code
   AND buf_c-chk-doc-attr.attr-code = buf_chk-doc-attr.attr-code:
  buffer-compare
  buf_chk-doc-attr to buf_c-chk-doc-attr
  case-sensitive
  save result in v-chg-fields.
  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, "attr-code,attr-value").
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, "Код атрибута,Значение атрибута")
    v-real-field-name = entry(1, v-field-name, ':')
    .
    create temp-changes.
    assign
    temp-changes.f_name = substitute("chk-doc-attr&1&2&2&3"
                                     ,chr(4)
                                     ,buf_chk-doc-attr.attr-code
                                     ,v-field-name)
    temp-changes.l_name = substitute("Атрибут чека &1 &2"
                                      ,buf_chk-doc-attr.attr-code
                                      ,v-field-label)
    temp-changes.v_old = string(buffer buf_c-chk-doc-attr:buffer-field(v-field-name):buffer-value)
    temp-changes.v_new = string(buffer buf_chk-doc-attr:buffer-field(v-field-name):buffer-value)
    .
  end.
end.
END PROCEDURE.
PROCEDURE get-line-changes-hist :
define input parameter p-doc-code like ub.c-chk-doc.doc-code no-undo .
define input parameter p-chip-num like ub.c-chk-doc.chip-num no-undo.
define input parameter p-new-chip-num like ub.c-chk-doc.chip-num no-undo.
define input parameter p-is-add      like ub.c-chk-doc.is-add no-undo .
define input parameter p-is-del      like ub.c-chk-doc.is-del no-undo .
define variable v-chg-fields as character no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-field-name as character no-undo .
define variable v-field-label as character no-undo .
define variable v-field-function as character no-undo .
define variable v-real-field-name as character no-undo .
define buffer new_c-chk-gds for ub.c-chk-gds.
define buffer new_c-chk-pay for ub.c-chk-pay.
define buffer new_c-chk-discnt for ub.c-chk-discnt.
define buffer new_c-chk-doc-attr for ub.c-chk-doc-attr.
define buffer buf_c-chk-gds for ub.c-chk-gds.
define buffer buf_c-chk-pay for ub.c-chk-pay.
define buffer buf_c-chk-discnt for ub.c-chk-discnt.
define buffer buf_c-chk-doc-attr for ub.c-chk-doc-attr.
if p-is-del or p-is-add then do:
  assign
  v-chg-fields = get-all-fields("chk-gds":U)
  v-chg-fields = replace(v-chg-fields, "obj-type,":U, "":U)
  v-chg-fields = replace(v-chg-fields, "obj-code,":U, "":U)
  v-chg-fields = replace(v-chg-fields, "doc-code,":U, "":U)
  v-chg-fields = replace(v-chg-fields, "out-code,":U, "":U)
  v-chg-fields = replace(v-chg-fields, chr(44), chr(44))
  v-chg-fields = trim(v-chg-fields, chr(44))
  .
end.
for each new_c-chk-gds no-lock where
            new_c-chk-gds.doc-code = p-doc-code
        AND new_c-chk-gds.chip-num = p-new-chip-num
            ,
    first buf_c-chk-gds no-lock where
         buf_c-chk-gds.doc-code = p-doc-code
     AND buf_c-chk-gds.chip-num = p-chip-num
     AND buf_c-chk-gds.line-num = new_c-chk-gds.line-num
            :
  if not (p-is-del or p-is-add ) then
  buffer-compare
  new_c-chk-gds to buf_c-chk-gds
  case-sensitive
  save result in v-chg-fields.
  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, "b-code,depart-code,depart-id,depart-type,discnt,doc-qnty,is-error," +                         "line-num,line-sign,line-type,loc1,nozzle-code,pass-gds,price-base,price-list-id,price-service,pump," +                         "road-tax,sales-man,salesman-psn-code,src-code,src-discnt,src-price,src-qnty," +                         "src-sum,sum-base,time-oper,write-off-code").
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, "Бар-код в БД,Код подразделения,ID подразделения,Тип подразделения,Скидка в БД,Количество,Ош," +                         "Номер строки,Знак строки,Тип,Резервуар,Пист,Ввод кода товара,Цена в БД,Прайс-лист,Цена серв. эл-та,Номер ТРК," +                         "Дорожный налог,Продавец,Код продавца в БД,Исходный бар-код,Скидка в чеке,Цена чека,Количество в чеке," +                         "Сумма строки в чеке,Сумма строки в БД,Время в сек,Код списания")
    v-field-function = entry(jj, ",,,,,,," +                         ",,,,,,,,,," +                         ",,,,,,," +                         ",,,")
    v-real-field-name = entry(1, v-field-name, ":")
    .
    create temp-changes.
    assign
    temp-changes.f_name = substitute("chk-gds&1&2&1&3"
                                      ,chr(4)
                                      ,new_c-chk-gds.line-num
                                      ,v-field-name)
    temp-changes.l_name = substitute("Строка товара &1 &2"
                                      ,new_c-chk-gds.line-num
                                      ,v-field-label)
    temp-changes.v_old = (if p-is-add
                          then "":U
                          else string(buffer buf_c-chk-gds:buffer-field(v-real-field-name):buffer-value))
    temp-changes.v_new = (if p-is-del
                          then "":U
                          else string(buffer new_c-chk-gds:buffer-field(v-real-field-name):buffer-value))
    .
    if v-field-function <> '':U then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.
  end.
end.
if p-is-del or p-is-add
then
assign
v-chg-fields = get-all-fields("chk-pay":U)
v-chg-fields = replace(v-chg-fields, "obj-type,":U, "":U)
v-chg-fields = replace(v-chg-fields, "obj-code,":U, "":U)
v-chg-fields = replace(v-chg-fields, "doc-code,":U, "":U)
v-chg-fields = replace(v-chg-fields, "out-code,":U, "":U)
.
for each new_c-chk-pay no-lock where
            new_c-chk-pay.doc-code = p-doc-code
        AND new_c-chk-pay.chip-num = p-new-chip-num
            ,
    first buf_c-chk-pay no-lock where
          buf_c-chk-pay.doc-code = p-doc-code
      AND buf_c-chk-pay.chip-num = p-chip-num
      AND buf_c-chk-pay.line-num = new_c-chk-pay.line-num:
  if not (p-is-del or p-is-add ) then
  buffer-compare
  new_c-chk-pay to buf_c-chk-pay
  case-sensitive
  save result in v-chg-fields.
  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, "bank-rate,bank-scale,cash-rate,curr-code,is-error,line-num,line-sign," +                        "line-type,pass-pay,pay-card,pay-code,time-oper," +                        "tot-base,tot-rubl,tot-sum").
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, "Курс ЦБ РФ,Масштаб курса банка ЦБ РФ,Курс,Код валюты,Ош,Номер строки,Знак строки," +                         "Тип,Прохождение платежа (картой или вручную),Номер пл карты карты,код оплаты,Время в сек," +                         "Сумма в баз.в.,Сумма в руб.,Сумма в валюте оплаты")
    v-real-field-name = entry(1, v-field-name, ':')
    .
    create temp-changes.
    assign
    temp-changes.f_name = substitute("chk-pay &1&2&1&3":U
                                     ,chr(4)
                                     ,new_c-chk-pay.line-num
                                     ,v-field-name)
    temp-changes.l_name = substitute("Строка оплат &1 &2"
                                      ,new_c-chk-pay.line-num
                                      ,v-field-label)
    temp-changes.v_old = (if p-is-add
                         then '':U
                         else string(buffer buf_c-chk-pay:buffer-field(v-field-name):buffer-value))
    temp-changes.v_new = (if p-is-del
                         then '':U
                         else string(buffer new_c-chk-pay:buffer-field(v-field-name):buffer-value))
    .
  end.
end.
if p-is-del or p-is-add
then
assign
v-chg-fields = get-all-fields("chk-discnt":U)
v-chg-fields = replace(v-chg-fields, "obj-type,":U, "":U)
v-chg-fields = replace(v-chg-fields, "obj-code,":U, "":U)
v-chg-fields = replace(v-chg-fields, "doc-code,":U, "":U)
v-chg-fields = replace(v-chg-fields, "out-code,":U, "":U)
.
for each new_c-chk-discnt no-lock where
            new_c-chk-discnt.doc-code = p-doc-code
        AND new_c-chk-discnt.chip-num = p-new-chip-num
            ,
    first buf_c-chk-discnt no-lock where
         buf_c-chk-discnt.doc-code = p-doc-code
     AND buf_c-chk-discnt.chip-num = p-chip-num
     AND buf_c-chk-discnt.line-num = new_c-chk-discnt.line-num
  :
  if not (p-is-del or p-is-add ) then
  buffer-compare
  new_c-chk-discnt to buf_c-chk-discnt
  case-sensitive
  save result in v-chg-fields.
  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, "discnt-id,discnt-type,discnt-value-abs,discnt-value-pcnt,is-error,line-num,line-sign," +                         "line-type,object-line-num,object-qnty,object-sum,pass-discnt,record-type,time-oper,value-type").
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, "Вн.№ скидки,Тип скидки,Abs значение скидки,Проц значение скидки,Ош,№ строки скидки,Знак строки," +                          "Тип,№ товарной строки для скидки,Количество,Сумма до скидки,Ввод скидки (картой или вручную),Тип записи,Время в сек,Тип значения")
    v-real-field-name = entry(1, v-field-name, ':')
    .
    create temp-changes.
    assign
    temp-changes.f_name = substitute("chk-discnt&1&2&1&3&1&4&1&5&1&6"
                                     ,chr(4)
                                     ,new_c-chk-discnt.record-type
                                     ,new_c-chk-discnt.line-num
                                     ,new_c-chk-discnt.object-line-num
                                     ,new_c-chk-discnt.discnt-id
                                     ,v-field-name)
    temp-changes.l_name = substitute("Строка скидки &1 &2 к строке товара &3 &4"
                                     ,new_c-chk-discnt.line-num
                                     ,(if new_c-chk-discnt.record-type = 0 then ' (исх) ' else ' (выч) ')
                                     ,new_c-chk-discnt.object-line-num
                                     ,v-field-label)
    temp-changes.v_old = (if p-is-add
                         then '':U
                         else string(buffer buf_c-chk-discnt:buffer-field(v-real-field-name):buffer-value))
    temp-changes.v_new = (if p-is-del
                         then '':U
                         else string(buffer new_c-chk-discnt:buffer-field(v-real-field-name):buffer-value))
    .
  end.
end.
assign
v-chg-fields = get-all-fields("chk-doc-attr":U)
.
for each new_c-chk-doc-attr no-lock where
            new_c-chk-doc-attr.doc-code = p-doc-code
        AND new_c-chk-doc-attr.chip-num = p-new-chip-num
            ,
    first buf_c-chk-doc-attr no-lock where
         buf_c-chk-doc-attr.doc-code = p-doc-code
     AND buf_c-chk-doc-attr.chip-num = p-chip-num
   AND buf_c-chk-doc-attr.attr-code = new_c-chk-doc-attr.attr-code:
  if not (p-is-del or p-is-add ) then
  buffer-compare
  new_c-chk-doc-attr to buf_c-chk-doc-attr
  case-sensitive
  save result in v-chg-fields.
  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, "attr-code,attr-value").
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, "Код атрибута,Значение атрибута")
    v-real-field-name = entry(1, v-field-name, ':')
    .
    create temp-changes.
    assign
    temp-changes.f_name = substitute("chk-doc-attr&1&2&2&3"
                                     ,chr(4)
                                     ,new_c-chk-doc-attr.attr-code
                                     ,v-field-name)
    temp-changes.l_name = substitute("Атрибут чека &1 &2"
                                      ,new_c-chk-doc-attr.attr-code
                                      ,v-field-label)
    temp-changes.v_old = string(buffer buf_c-chk-doc-attr:buffer-field(v-field-name):buffer-value)
    temp-changes.v_new = string(buffer new_c-chk-doc-attr:buffer-field(v-field-name):buffer-value)
    .
  end.
end.
END PROCEDURE.
PROCEDURE MyEnable :
define buffer buf_currency for ub.currency.
ASSIGN
br-docs:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 6
X_c-chk-doc.cashier:READ-ONLY IN BROWSE br-docs = YES
temp-changes.l_name:resizable in browse br-changes = true
temp-changes.v_old:resizable in browse br-changes = true
temp-changes.v_new:resizable in browse br-changes = true
temp-changes.l_name:width in browse br-changes = 50
temp-changes.v_old:width in browse br-changes = 20
temp-changes.v_new:width in browse br-changes = 20
.
if p-mode =  "one":u then do:
  assign
  p-obj-type = X_c-chk-doc.obj-type
  p-obj-code = X_c-chk-doc.obj-code
  .
end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
find first buf_currency no-lock where
        buf_currency.curr-code = v-base-code.
assign
v-base-type = buf_currency.curr-abbr.
DISPLAY
ED-notes
mark-num
WITH FRAME Dialog-Frame.
ENABLE
b-quit
b-help
br-docs
b-lkp
b-restore WHEN (LOOKUP("b-restore", bttns) > 0 and p-mode = 'удаление':U)
b-sel  when LOOKUP("b-sel":U, bttns) > 0
b-mark when LOOKUP("b-mark":U, bttns) > 0
b-sch
b-print
br-changes
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Список истории чеков" + chr(32).
run waitfram-show in this-procedure ( input "Ждите...").
define variable sort-column-phrase as character no-undo .
case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.
define variable l-open-query as logical   no-undo .
  CASE p-mode :
    WHEN "one":U        THEN DO:
     assign
     filter-point = filter-point0 + p-mode
     filter-label = substitute("&1", filter-label0)
     frame Dialog-Frame :title = substitute("История изменения чека &1", p-doc-code)
     .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-32  as logical   no-undo .
define variable  l-filter-open-32    as logical   .
define variable  flt-rec-32       as recid     no-undo .
define variable  filter-name-32      as character no-undo .
define variable  where-phrase-32     as character no-undo .
define variable  sort-phrase-32      as character no-undo .
define variable  where-phrase-rus-32 as character no-undo .
define variable  sort-phrase-rus-32  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-32
  ,output filter-name-32
  ,output where-phrase-32
  ,output sort-phrase-32
  ,output where-phrase-rus-32
  ,output sort-phrase-rus-32
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-32
      ) no-error .
  assign
    l-filter-open-32 = false
  .
  if flt-rec-32 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-32 as character no-undo .
    define variable  parameter-3-32 as character no-undo .
    define variable  parameter-4-32 as character no-undo .
    define variable  parameter-5-32 as character no-undo .
    define variable  parameter-6-32 as character no-undo .
    define variable  parameter-7-32 as character no-undo .
      assign
      parameter-3-32 =
                              "FOR EACH X_c-chk-doc"
      parameter-4-32 =
        (
          if (" X_c-chk-doc.doc-code = p-doc-code " + " " + where-phrase-32) <> ""
          then  substitute('X_c-chk-doc.doc-code = &1&2&1', chr(34), p-doc-code ) + " " + where-phrase-32
          else "true"
        )
      parameter-5-32 = (" " + "" + " " + "")
      parameter-6-32 = if sort-phrase-32 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_c-chk-doc.chip-num descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-32
        )
      parameter-7-32 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-32 =
          (" X_c-chk-doc.doc-code = p-doc-code " + " " + where-phrase-32 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-32
                          ,input parameter-4-32
                          ,input parameter-5-32
                          ,input parameter-6-32
                          ,input parameter-7-32
                          )
      .
      assign
        l-filter-open-32 = true
      .
    end.
    if l-filter-open-32 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-32 = false then do:
    OPEN QUERY br-docs FOR EACH X_c-chk-doc
      where  X_c-chk-doc.doc-code = p-doc-code
       by X_c-chk-doc.chip-num descending
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_c-chk-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer X_c-chk-doc:handle) then do:
      assign
      parameter-2-32 = (if p-find-next then "true":u else "false":u )
      parameter-4-32 =
        "where ":u +  substitute('X_c-chk-doc.doc-code = &1&2&1', chr(34), p-doc-code ) + " ":u + where-phrase-32 + " ":u + p-find-condition + " " + ""
      parameter-5-32 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(X_c-chk-doc)
                          ,input logical(parameter-2-32)
                          ,input no-lock
                          ,input (buffer X_c-chk-doc:handle)
                          ,input parameter-4-32
                          ,input parameter-5-32
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-32 = (if p-find-next then "true":u else "false":u )
      parameter-3-32 =  "FOR EACH X_c-chk-doc"
      parameter-4-32 =
        (
          if (" X_c-chk-doc.doc-code = p-doc-code " + " " + where-phrase-32) <> ""
          then  substitute('X_c-chk-doc.doc-code = &1&2&1', chr(34), p-doc-code ) + " " + where-phrase-32
          else "true"
        )
      parameter-5-32 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-32 = if sort-phrase-32 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_c-chk-doc.chip-num descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-32
        )
      parameter-7-32 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-32)
                          ,input no-lock
                          ,input parameter-3-32
                          ,input parameter-4-32
                          ,input parameter-5-32
                          ,input parameter-6-32
                          ,input parameter-7-32
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    END.
    WHEN 'удаление':U        THEN DO:
     assign
     filter-point = filter-point0 + p-mode
     filter-label = substitute("&1 удаленные чеки", filter-label0)
     frame Dialog-Frame :title = substitute("Чеки, удаленные в &1&2", p-obj-type, p-obj-code)
     .
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-34  as logical   no-undo .
define variable  l-filter-open-34    as logical   .
define variable  flt-rec-34       as recid     no-undo .
define variable  filter-name-34      as character no-undo .
define variable  where-phrase-34     as character no-undo .
define variable  sort-phrase-34      as character no-undo .
define variable  where-phrase-rus-34 as character no-undo .
define variable  sort-phrase-rus-34  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-34
  ,output filter-name-34
  ,output where-phrase-34
  ,output sort-phrase-34
  ,output where-phrase-rus-34
  ,output sort-phrase-rus-34
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-34
      ) no-error .
  assign
    l-filter-open-34 = false
  .
  if flt-rec-34 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-34 as character no-undo .
    define variable  parameter-3-34 as character no-undo .
    define variable  parameter-4-34 as character no-undo .
    define variable  parameter-5-34 as character no-undo .
    define variable  parameter-6-34 as character no-undo .
    define variable  parameter-7-34 as character no-undo .
      assign
      parameter-3-34 =
                              "FOR EACH X_c-chk-doc"
      parameter-4-34 =
        (
          if (" X_c-chk-doc.obj-type = p-obj-type and X_c-chk-doc.obj-code = p-obj-code and X_c-chk-doc.is-del = yes " + " " + where-phrase-34) <> ""
          then  substitute('X_c-chk-doc.obj-type = &1&2&1 and X_c-chk-doc.obj-code = &3 and X_c-chk-doc.is-del = yes '                               , chr(34), p-obj-type, p-obj-code) + " " + where-phrase-34
          else "true"
        )
      parameter-5-34 = (" " + "" + " " + "")
      parameter-6-34 = if sort-phrase-34 = ''
                           then
        (
        " " + " use-index idel " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index idel " +
          " " + sort-column-phrase +
        " " + sort-phrase-34
        )
      parameter-7-34 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-34 =
          (" X_c-chk-doc.obj-type = p-obj-type and X_c-chk-doc.obj-code = p-obj-code and X_c-chk-doc.is-del = yes " + " " + where-phrase-34 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-34
                          ,input parameter-4-34
                          ,input parameter-5-34
                          ,input parameter-6-34
                          ,input parameter-7-34
                          )
      .
      assign
        l-filter-open-34 = true
      .
    end.
    if l-filter-open-34 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-34 = false then do:
    OPEN QUERY br-docs FOR EACH X_c-chk-doc
      where  X_c-chk-doc.obj-type = p-obj-type and X_c-chk-doc.obj-code = p-obj-code and X_c-chk-doc.is-del = yes
       use-index idel
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_c-chk-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer X_c-chk-doc:handle) then do:
      assign
      parameter-2-34 = (if p-find-next then "true":u else "false":u )
      parameter-4-34 =
        "where ":u +  substitute('X_c-chk-doc.obj-type = &1&2&1 and X_c-chk-doc.obj-code = &3 and X_c-chk-doc.is-del = yes '                               , chr(34), p-obj-type, p-obj-code) + " ":u + where-phrase-34 + " ":u + p-find-condition + " " + ""
      parameter-5-34 = " use-index idel "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(X_c-chk-doc)
                          ,input logical(parameter-2-34)
                          ,input no-lock
                          ,input (buffer X_c-chk-doc:handle)
                          ,input parameter-4-34
                          ,input parameter-5-34
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-34 = (if p-find-next then "true":u else "false":u )
      parameter-3-34 =  "FOR EACH X_c-chk-doc"
      parameter-4-34 =
        (
          if (" X_c-chk-doc.obj-type = p-obj-type and X_c-chk-doc.obj-code = p-obj-code and X_c-chk-doc.is-del = yes " + " " + where-phrase-34) <> ""
          then  substitute('X_c-chk-doc.obj-type = &1&2&1 and X_c-chk-doc.obj-code = &3 and X_c-chk-doc.is-del = yes '                               , chr(34), p-obj-type, p-obj-code) + " " + where-phrase-34
          else "true"
        )
      parameter-5-34 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-34 = if sort-phrase-34 = ''
                           then
        (
        " " + " use-index idel " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index idel " +
          " " + sort-column-phrase +
        " " + sort-phrase-34
        )
      parameter-7-34 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-34)
                          ,input no-lock
                          ,input parameter-3-34
                          ,input parameter-4-34
                          ,input parameter-5-34
                          ,input parameter-6-34
                          ,input parameter-7-34
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    END.
    WHEN 'ДОБАВЛЕНИЕ':U        THEN DO:
     assign
     filter-point = filter-point0 + p-mode
     filter-label = substitute("&1 созданные вручную чеки", filter-label0)
     frame Dialog-Frame :title = substitute("Чеки, созданные вручную  в &1&2", p-obj-type, p-obj-code)
     .
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-36  as logical   no-undo .
define variable  l-filter-open-36    as logical   .
define variable  flt-rec-36       as recid     no-undo .
define variable  filter-name-36      as character no-undo .
define variable  where-phrase-36     as character no-undo .
define variable  sort-phrase-36      as character no-undo .
define variable  where-phrase-rus-36 as character no-undo .
define variable  sort-phrase-rus-36  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-36
  ,output filter-name-36
  ,output where-phrase-36
  ,output sort-phrase-36
  ,output where-phrase-rus-36
  ,output sort-phrase-rus-36
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-36
      ) no-error .
  assign
    l-filter-open-36 = false
  .
  if flt-rec-36 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-36 as character no-undo .
    define variable  parameter-3-36 as character no-undo .
    define variable  parameter-4-36 as character no-undo .
    define variable  parameter-5-36 as character no-undo .
    define variable  parameter-6-36 as character no-undo .
    define variable  parameter-7-36 as character no-undo .
      assign
      parameter-3-36 =
                              "FOR EACH X_c-chk-doc"
      parameter-4-36 =
        (
          if (" X_c-chk-doc.obj-type = p-obj-type and X_c-chk-doc.obj-code = p-obj-code and X_c-chk-doc.is-add = yes " + " " + where-phrase-36) <> ""
          then  substitute('X_c-chk-doc.obj-type = &1&2&1 and X_c-chk-doc.obj-code = &3 and X_c-chk-doc.is-add = yes '                                 , chr(34), p-obj-type, p-obj-code) + " " + where-phrase-36
          else "true"
        )
      parameter-5-36 = (" " + "" + " " + "")
      parameter-6-36 = if sort-phrase-36 = ''
                           then
        (
        " " + " use-index iadd " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index iadd " +
          " " + sort-column-phrase +
        " " + sort-phrase-36
        )
      parameter-7-36 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-36 =
          (" X_c-chk-doc.obj-type = p-obj-type and X_c-chk-doc.obj-code = p-obj-code and X_c-chk-doc.is-add = yes " + " " + where-phrase-36 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-36
                          ,input parameter-4-36
                          ,input parameter-5-36
                          ,input parameter-6-36
                          ,input parameter-7-36
                          )
      .
      assign
        l-filter-open-36 = true
      .
    end.
    if l-filter-open-36 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-36 = false then do:
    OPEN QUERY br-docs FOR EACH X_c-chk-doc
      where  X_c-chk-doc.obj-type = p-obj-type and X_c-chk-doc.obj-code = p-obj-code and X_c-chk-doc.is-add = yes
       use-index iadd
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_c-chk-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer X_c-chk-doc:handle) then do:
      assign
      parameter-2-36 = (if p-find-next then "true":u else "false":u )
      parameter-4-36 =
        "where ":u +  substitute('X_c-chk-doc.obj-type = &1&2&1 and X_c-chk-doc.obj-code = &3 and X_c-chk-doc.is-add = yes '                                 , chr(34), p-obj-type, p-obj-code) + " ":u + where-phrase-36 + " ":u + p-find-condition + " " + ""
      parameter-5-36 = " use-index iadd "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(X_c-chk-doc)
                          ,input logical(parameter-2-36)
                          ,input no-lock
                          ,input (buffer X_c-chk-doc:handle)
                          ,input parameter-4-36
                          ,input parameter-5-36
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-36 = (if p-find-next then "true":u else "false":u )
      parameter-3-36 =  "FOR EACH X_c-chk-doc"
      parameter-4-36 =
        (
          if (" X_c-chk-doc.obj-type = p-obj-type and X_c-chk-doc.obj-code = p-obj-code and X_c-chk-doc.is-add = yes " + " " + where-phrase-36) <> ""
          then  substitute('X_c-chk-doc.obj-type = &1&2&1 and X_c-chk-doc.obj-code = &3 and X_c-chk-doc.is-add = yes '                                 , chr(34), p-obj-type, p-obj-code) + " " + where-phrase-36
          else "true"
        )
      parameter-5-36 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-36 = if sort-phrase-36 = ''
                           then
        (
        " " + " use-index iadd " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index iadd " +
          " " + sort-column-phrase +
        " " + sort-phrase-36
        )
      parameter-7-36 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-36)
                          ,input no-lock
                          ,input parameter-3-36
                          ,input parameter-4-36
                          ,input parameter-5-36
                          ,input parameter-6-36
                          ,input parameter-7-36
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    END.
END CASE.
if not p-open-query then
REPOSITION br-docs to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-docs in frame Dialog-Frame.
APPLY "ENTRY" TO br-docs.
END PROCEDURE.
PROCEDURE proc-b-lkp :
define variable next-prev as character no-undo .
define variable v-doc-rec as recid no-undo .
if not available X_c-chk-doc then return.
v-doc-rec = recid(X_c-chk-doc).
DO WHILE next-prev = '':U:
  if NOT available X_c-chk-doc then do:
    message "Неправильно выбрана запись истории чека." view-as alert-box ERROR.
    return no-apply.
  end.
  v-doc-rec = recid (X_c-chk-doc).
  run str/suprcchk.w (
                   input parparentproc
                  ,input 'ПРОСМОТР':U
                  ,input X_c-chk-doc.obj-type
                  ,input X_c-chk-doc.obj-code
                  ,input-output v-doc-rec
                  ,input this-procedure:handle
                  ,input-output next-prev
                              ) no-error.
  END .
reposition br-docs to recid v-doc-rec no-error.
apply "entry" to br-docs in frame Dialog-Frame.
apply "value-changed" to br-docs in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-print :
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable accum-count as integer.
define variable v-time as character no-undo .
define variable v-shift-name-num as character no-undo .
define variable v-header-base-curr as character no-undo .
define variable v-curr-r-b as character no-undo .
DEFINE VARIABLE v-for-user-name AS CHARACTER NO-UNDO.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
if v-curr-r-b = 'base':U then do:
  assign
  v-header-base-curr = string( "( Б.Вал. - " + caps( v-base-type ) + " )" )
  .
end.
DEFINE FRAME Chk-List
X_c-chk-doc.corr-date COLUMN-LABEL "Дата корр"
v-time                COLUMN-LABEL "Время корр"
X_c-chk-doc.corr-user-db-num
v-for-user-name COLUMN-LABEL "Изменил" FORMAT "X(18)"
X_c-chk-doc.is-add FORMAT "+/"
X_c-chk-doc.is-del FORMAT "+/"
X_c-chk-doc.office       column-label "Тип_"                format "X(8)"
X_c-chk-doc.doc-code      column-label "Номер_чека"  format "X(17)"
X_c-chk-doc.chk-num       column-label "N_по_кассе" format "->>>>>>9"
X_c-chk-doc.chk-date       column-label "Дата" format "99/99/9999"
for-time                  column-label "Время"   format "X(5)"
X_c-chk-doc.shift-date      column-label "Смена_от" format "99/99/9999"
v-shift-name-num      column-label "N_см."  FORMAT "X(6)"
X_c-chk-doc.netto             column-label "Сумма_оплат"
X_c-chk-doc.pay-desk      column-label "Касса"
X_c-chk-doc.cashier         column-label "Кассир"       format ">>>>9"
X_c-chk-doc.sales-man    column-label "Прод-ц"       format ">>>>9"
X_c-chk-doc.out-code       column-label "Номер_РН"
v_d-card           column-label "Номер_диск._карты"              space(0)
HEADER  date_string AT 5 format "X(35)"
v-header-base-curr        format "X(20)" AT 42
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>>9" SKIP
Line format "X(198)" AT 1
with width 232 down stream-io use-text    .
Line = fill("-", 198).
date_string = cur-time-print() .
run prn-lib-open-stream  in this-procedure (
                                    input parParentProc
                                    ,input 43
                                    ,input yes
                                    ,input no
                                    ).
v-doc-rec = recid( X_c-chk-doc ).
DO WHILE available X_c-chk-doc :
      GET prev br-docs.
END.
PUT  STREAM PrnLibStream
SPACE(25) ( frame Dialog-Frame:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(198)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME Chk-List  .
run waitfram-show in this-procedure ( input "Ждите...").
GET next br-docs.
DO WHILE available X_c-chk-doc :
  if par-l-mask then v_d-card = substring(X_c-chk-doc.d-card,1,6) + "XXXXXX" + substring (X_c-chk-doc.d-card,13,4).
  else v_d-card = X_c-chk-doc.d-card .
  Display STREAM PrnLibStream
  X_c-chk-doc.corr-date
  string(X_c-chk-doc.corr-time, "HH:MM") @ v-time
  X_c-chk-doc.corr-user-db-num
  usrfulnf(X_c-chk-doc.corr-user-name) @ v-for-user-name
  X_c-chk-doc.is-add
  X_c-chk-doc.is-del
  X_c-chk-doc.office
  X_c-chk-doc.doc-code
  X_c-chk-doc.chk-num
  X_c-chk-doc.chk-date
  string(X_c-chk-doc.chk-time, "HH:mm") @ for-time
  X_c-chk-doc.shift-date
  shift-name-no-err(buffer X_c-chk-doc) @ v-shift-name-num
  X_c-chk-doc.netto
  X_c-chk-doc.pay-desk
  X_c-chk-doc.cashier
  X_c-chk-doc.sales-man
  if X_c-chk-doc.out-code <> ? then X_c-chk-doc.out-code else "" @ X_c-chk-doc.out-code
  v_d-card
  with FRAME Chk-List .
DOWN STREAM PrnLibStream 1 with FRAME CHk-List  .
assign
accum-count = accum-count + 1
.
GET next br-docs.
END.
UNDERLINE  STREAM PrnLibStream
X_c-chk-doc.corr-date
v-time
X_c-chk-doc.corr-user-db-num
v-for-user-name
X_c-chk-doc.is-add
X_c-chk-doc.is-del
X_c-chk-doc.office
X_c-chk-doc.doc-code
X_c-chk-doc.chk-num
X_c-chk-doc.chk-date
for-time
X_c-chk-doc.shift-date
v-shift-name-num
X_c-chk-doc.netto
X_c-chk-doc.pay-desk
X_c-chk-doc.cashier
X_c-chk-doc.sales-man
X_c-chk-doc.out-code
v_d-card
with FRAME Chk-List .
DISPLAY STREAM PrnLibStream
"ИТОГО"  @ X_c-chk-doc.doc-code
accum-count @ X_c-chk-doc.chk-num
with frame Chk-List.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME fin-bank-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-docs to recid v-doc-rec no-error.
APPLY "entry" to br-docs.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
END PROCEDURE.
PROCEDURE proc-b-restore :
define variable glog as logical no-undo .
  if available X_c-chk-doc
  then do:
    define variable v-chk-act-host-code as integer   no-undo .
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  X_c-chk-doc.obj-type
  ,input  X_c-chk-doc.obj-code
  ,output v-chk-act-host-code
  )  .
define variable vss-include-info39 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_receipt_input':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  X_c-chk-doc.obj-type
    ,input  X_c-chk-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if NOT glog then  return error.
    glog = no.
    message
    "Вы уверены, что хотите ВОССТАНОВИТЬ данный чек?"
    view-as alert-box question buttons yes-no update glog.
    if not glog then return.
    run str/chk-rest.p ( input X_c-chk-doc.doc-code) no-error.
    if error-status:error then do:
      message
      substitute("Ошибка при восстановлении чека &1&2&3&2&4"
                  , X_c-chk-doc.doc-code
                  ,chr(10)
                  , error-status:get-message(1)
                  , return-value
                  )
      view-as alert-box error.
    end.
  end.
  get prev br-docs.
  if available X_c-chk-doc then do:
    assign
    v-doc-rec = recid(X_c-chk-doc).
  end.
  run OpenBr in this-procedure ( input yes, input no, input '':U).
  APPLY "ENTRY" to br-docs in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
  tbl = 'c-chk-doc'
  join-tbl = 'X_c-chk-doc'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('corr-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время корр.', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-code', 'Номер в базе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-time', '', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('office', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-date', 'Смена от', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-num', 'Порядок смен', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-num', 'Номер по кассе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-desk', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cashier', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sales-man', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-doc', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sub-discnt', 'Списания', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('netto', 'Нетто сумма (выручка)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('out-code', 'Номер продажи', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('d-card', 'N дис.карты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w (
                    input parparentproc
                  , INPUT (filter-point + chr(4) + filter-label)
                  , INPUT tbl
                  , INPUT join-tbl
                  , INPUT fld
                  , INPUT lab
                  , INPUT spr
                  , INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END.
END PROCEDURE.
PROCEDURE proc-view-changes :
define buffer new_c-chk-doc for ub.c-chk-doc.
define buffer current_chk-doc for ub.chk-doc.
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable jj as integer no-undo .
define variable v-field-name as character no-undo .
define variable v-field-label as character no-undo .
define variable v-field-function as character no-undo .
define variable v-real-field-name as character no-undo .
for each temp-changes:
    delete temp-changes.
END.
if not available X_c-chk-doc then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
if X_c-chk-doc.is-del then do:
  assign
  v-chg-fields = get-all-fields("chk-doc")
  .
  run get-line-changes-hist in this-procedure (
                                               input X_c-chk-doc.doc-code
                                             , input X_c-chk-doc.chip-num
                                             , input X_c-chk-doc.chip-num
                                             , input X_c-chk-doc.is-add and X_c-chk-doc.chip-num = 1
                                             , input X_c-chk-doc.is-del).
end.
else do:
  find first new_c-chk-doc no-lock where
              new_c-chk-doc.doc-code = X_c-chk-doc.doc-code
                AND new_c-chk-doc.chip-num > X_c-chk-doc.chip-num no-error.
  if not available new_c-chk-doc then do:
      find first current_chk-doc no-lock where
                  current_chk-doc.doc-code = X_c-chk-doc.doc-code no-error.
      if not available current_chk-doc then do:
          return error.
      end.
      buffer-compare current_chk-doc except PS to X_c-chk-doc
      case-sensitive
      save result in v-chg-fields.
      run get-line-changes-current in this-procedure ( input X_c-chk-doc.chip-num).
  end.
  else do:
      buffer-compare new_c-chk-doc except PS  chip-num corr-date corr-user-name corr-user-db-num  to X_c-chk-doc
      case-sensitive
      save result in v-chg-fields.
      run get-line-changes-hist in this-procedure (
                                                   input X_c-chk-doc.doc-code
                                                 , input X_c-chk-doc.chip-num
                                                 , input new_c-chk-doc.chip-num
                                                 , input X_c-chk-doc.is-add and X_c-chk-doc.chip-num = 1
                                                 , input X_c-chk-doc.is-del
                                                 ).
  end.
end.
  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, "cash-rate,cash-scale,cashier,cashier-psn-code,chk-date,chk-num,chk-time,chk-type," +                        "correct,d-card,d-pcnt,discnt,doc-code,doc-num,doc-qnty,netto,obj-code,obj-type,office," +                        "out-code,pay-desk,price-type,PS,sales-man,salesman-psn-code,shift-date,shift-num,src-d-pcnt," +                        "src-shift-date,tot-doc,z-number").
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, "Курс валюты кассы,Масштаб ваюты кассы,Кассир,Код кассира в БД,Дата,№ Чек на кассе,Время,Тип чека,"  +                          "OK,Дисконтная карта,Процент скидки,Скидка общая,Номер,Номер документа,Количество,Сумма оплат,Код объекта,Тип объекта,Тип," +                          "Номер РН,Касса,Тип цены,Примечание,Продавец,Код продавца в БД,Дата смены (учета),Порядок Смен,Процент скидки на кассе," +                          "Дата смены на кассе,Сумма ценах продажи,Номер z-отчета")
    v-real-field-name = entry(1, v-field-name, ':')
    .
    create temp-changes.
    assign
    temp-changes.f_name = substitute("chk-doc&1&2"
                                     ,chr(4)
                                     ,v-field-name)
    temp-changes.l_name = substitute("Шапка чека &1"
                                     ,v-field-label)
    temp-changes.v_old = (if X_c-chk-doc.is-add  and X_c-chk-doc.chip-num = 1
                          then "":U
                          else string(buffer X_c-chk-doc:buffer-field(v-field-name):buffer-value))
    temp-changes.v_new = (if X_c-chk-doc.is-del
                          then "":U
                          else (if X_c-chk-doc.is-add  and X_c-chk-doc.chip-num = 1
                                then string(buffer X_c-chk-doc:buffer-field(v-field-name):buffer-value)
                                else (if available new_c-chk-doc
                                        then string(buffer new_c-chk-doc:buffer-field(v-field-name):buffer-value)
                                        else string(buffer current_chk-doc:buffer-field(v-field-name):buffer-value)
                                      )
                              )
                          )
    .
end.
Open QUery br-changes for each temp-changes.
END PROCEDURE.
PROCEDURE reposition-c-chk-doc :
define input  parameter p-direction   as character no-undo .
define output parameter p-chk-doc-recid as recid no-undo .
  case p-direction :
    when "first":U
    then do:
      get first br-docs.
    end.
    when "last":U
    then do:
      get last br-docs.
    end.
    when "prev":U
    then do:
      get prev br-docs.
      if not available X_c-chk-doc then do:
        message
        "Это первый чек списка"
        view-as alert-box.
      end.
    end.
    when "next":U
    then do:
      get next br-docs.
      if not available X_c-chk-doc then do:
        message
        "Это последний чек списка"
        view-as alert-box.
      end.
    end.
  end case .
  assign
  p-chk-doc-recid = recid(X_c-chk-doc)
  .
  run reposition-query in this-procedure
    (input p-chk-doc-recid
    ).
END PROCEDURE.
PROCEDURE reposition-query :
define input parameter p-recid as recid no-undo .
  if p-recid <> ?
  then do:
    reposition br-docs to recid p-recid no-error.
  end.
  do with frame Dialog-Frame:
    apply "entry":u to browse BR-changes .
    apply "VALUE-CHANGED":u to browse BR-changes .
  end.
END PROCEDURE.
