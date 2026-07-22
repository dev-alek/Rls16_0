DEFINE NEW SHARED BUFFER X_clients FOR ub.clients.
DEFINE NEW SHARED BUFFER X_clients-attr FOR ub.clients-attr.
DEFINE NEW SHARED BUFFER X_firm FOR ub.firm.
DEFINE NEW SHARED BUFFER X_person FOR ub.person.
DEFINE NEW SHARED BUFFER X_shop FOR ub.shop.
DEFINE NEW SHARED BUFFER X_store FOR ub.store.
define new shared buffer X_contract-attr for ub.contract-attr .
define new shared buffer X_contractr for ub.contract .
define input parameter parparentproc  as widget-handle no-undo.
define input parameter p-bttns     as   character no-undo.
define input parameter c-types     as character no-undo .
define input parameter c-group    like ub.clients.grp-name no-undo .
define input parameter c-status   as character no-undo .
define input parameter c-recid    as recid no-undo .
define input parameter c-added    as character no-undo .
define input parameter c-other    as character no-undo .
define output parameter  p-rid-list    as  character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Список клиентов" .
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
    assign
      p-vss-parameters = substitute('&1|&2|&3|&4|&5|&6|&7|&8':u,parparentproc,p-bttns,c-types,c-group,c-status,c-recid,c-added,c-other)
    .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
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
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cli-grplib-get-full-name :
   define input parameter  p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    define buffer buf_upper_cli-grp for ub.cli-grp.
    find first buf_cli-grp no-lock
         where buf_cli-grp.node-code = p-node-code
    no-error.
    if not available buf_cli-grp
    then do:
        undo, return error "cli-grplib-get-full-name: Не найдена группа клиентов с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_cli-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_cli-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_cli-grp.upper-code
        .
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = v-upper-code
        no-error.
        if not available buf_cli-grp
        then do:
            undo, return error "cli-grplib-get-full-name: Не найдена группа клиентов с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure cgrplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_cli-grp       for ub.cli-grp.
do
on error undo, return error
:
  find first buf_cli-grp no-lock
      where buf_cli-grp.upper-code = 0
  no-error .
  if not available buf_cli-grp
  then do:
      undo, return error substitute("Не найдена корневая группа клиентов (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_cli-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_cli-grp no-lock where
              buf_cli-grp.node-name = v-entry
          and buf_cli-grp.upper-code = v-upper-code
          no-error.
    if not available buf_cli-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_cli-grp.node-code.
      v-upper-code = buf_cli-grp.node-code.
    end.
  end.
end.
end .
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
define variable v-uf-List_        like ubflt.usr-flt.List_        no-undo .
define variable v-uf-Naim         like ubflt.usr-flt.Naim         no-undo .
define variable v-uf-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
define variable v-uf-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
define variable v-uf-type-price   like ubflt.usr-flt.type-price   no-undo .
define variable v-uf-type-val     like ubflt.usr-flt.type-val     no-undo .
define temp-table usr-flt_custom-labels no-undo like ub.custom-labels.
procedure uf-name :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define output parameter p-use-List_     as logical   no-undo .
  define output parameter p-type-List_     as character no-undo .
  define output parameter p-format-List_   as character no-undo .
  define output parameter p-use-Naim      as logical   no-undo .
  define output parameter p-type-Naim      as character no-undo .
  define output parameter p-format-Naim    as character no-undo .
  define output parameter p-use-print-graft as logical   no-undo .
  define output parameter p-use-sort-gr   as logical   no-undo .
  define output parameter p-use-type-price as logical   no-undo .
  define output parameter p-use-type-val  as logical   no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-tooltip        as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
    case p-code :
            when 'cli-all-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'oldscode':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника неиспользуемых весовых кодов"     p-tooltip = "Настройки справочника неиспользуемых весовых кодов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-ref-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(8)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = yes      p-label = "Параметры вызова справочника товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fbr-gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп блюд"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп блюд"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findoci-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findocs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника платежей"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-obi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'seqeallo':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Порядок колонок в АВТО-ЗАКАЗЕ"     p-tooltip = "Порядок колонок в РАСЧЕТЕ потребности заказа и его импорте"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'skm-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова выгрузки файла данных по продажам по СКМ"     p-tooltip = "Параметры по умолчанию, используемые для вызова выгрузки файла данных по продажам по СКМ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'imp-goods':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Импорт в карточке товара"     p-tooltip = "Заполнение по умолчанию параметров импорта товаров из карточки товара"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'discards-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник ДК"     p-tooltip = "Справочник дисконтных карт"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'finsttms-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника банковских выписок"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника банковских выписок"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список фин.обязательств"     p-tooltip = "Список фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'mpl-gds-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список цен по товару"     p-tooltip = "Список цен по товару"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'tpl-mode-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список мод"     p-tooltip = "Список мод"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-sost-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Состояние заказа"     p-tooltip = "Просмотр несоответствий поставок и накладных по заказам ОП ФП и ПО"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'planplat-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Планирование платежей"     p-tooltip = "Планирование платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа"     p-tooltip = "Форма ввода заказа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОП"     p-tooltip = "Форма ввода заказа ОП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pФП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ФП"     p-tooltip = "Форма ввода заказа ФП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОФ':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОФ"     p-tooltip = "Форма ввода заказа ОФ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'list-abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список заголовков ABC-анализа"     p-tooltip = "Список заголовков ABC-анализа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "ABC-анализ"     p-tooltip = "ABC-анализ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-rc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Заказ О-РЦ"     p-tooltip = "Заказ О-РЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cfin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список удаленных фин.обязательств"     p-tooltip = "Список удаленных фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'color-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = yes      p-use-type-price = no      p-use-type-val = no      p-label = "Раскрасить экран"     p-tooltip = "Изменение цветовой палитры брауза"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bon1-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-tooltip = "Параметры вызова отчета НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-shift':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Сменный отчет"     p-tooltip = "Сменный отчет"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsreffi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник товаров - доп поля"     p-tooltip = "Справочник товаров - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsfrmfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Карточка товара - доп поля"     p-tooltip = "Карточка товара - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-g':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrst':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = YES      p-use-type-val =       p-label = "Остатки МЦ"     p-tooltip = "Остатки МЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthcom':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = no      p-use-type-val =       p-label = "Сводный отчет о реализованных талонах"     p-tooltip = "Сводный отчет о реализованных талонах"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'bge-active-vbrr':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper-new':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов(расширенный)"     p-tooltip = "Параметры для выгрузки документов(расширенный)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/i-egais.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Интерфейс импорта классификатора ЕГАИС"     p-tooltip = "Интерфейс импорта классификатора ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'alc-rees':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр документов ЕГАИС"     p-tooltip = "Реестр документов ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-optprc.w':U then do:     assign     p-use-List_ = no      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оптовый прайс-лист"     p-tooltip = "Оптовый прайс-лист"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/iecliart.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Процедуры импорта экспорта артикулов поставщиков"     p-tooltip = "Процедуры импорта экспорта артикулов поставщиков"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthps-zone':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthparts-obj':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '&bef-wthsref-stts}':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrd':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthob':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-type':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-stts':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = yes      p-use-type-price = yes      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-sup':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-wth':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-ptlbal':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ctrasm':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Контроль ассортиментной матрицы"     p-tooltip = "Контроль ассортиментной матрицы"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-eslg-e':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'prphoto':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(2256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(2256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Прайс-лист с фото товаров"     p-tooltip = "Прайс-лист с фото товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkgdsfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Товарная строка чека - доп поля"     p-tooltip = "Товарная строка чека - доп поля "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkdocfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Чек - доп поля"     p-tooltip = "Чек - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'barcodfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Бар-код - доп поля"     p-tooltip = "Бар-код - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'UPD':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника Электронного документоборота"     p-tooltip = "Настройки справочника Электронного документоборота"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'LK_RECEIPT':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-tooltip = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
      otherwise do:
        undo, return error "неизвестная настройка пользователя usr-flt" + " " + p-code .
      end.
    end CASE.
  end.
end procedure.
procedure uf-get :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define output parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define output parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define output parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define output parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define output parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define output parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr     as logical   no-undo .
    define variable v-use-type-price  as logical   no-undo .
    define variable v-use-type-val    as logical   no-undo .
    define variable v-label          as character no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
       (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt no-lock where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if avail buf_usr-flt then do:
      assign
      p-List_        = (if v-use-List_       then buf_usr-flt.List_       else ?)
      p-Naim         = (if v-use-Naim        then buf_usr-flt.Naim        else ?)
      p-print-graft  = (if v-use-print-graft then buf_usr-flt.print-graft else ?)
      p-sort-gr      = (if v-use-sort-gr     then buf_usr-flt.sort-gr     else ?)
      p-type-price   = (if v-use-type-price  then buf_usr-flt.type-price  else ?)
      p-type-val     = (if v-use-List_       then buf_usr-flt.type-val    else ?)
      .
    end.
    else do:
      assign
      p-List_        = (if v-use-List_       then "":U                    else ?)
      p-Naim         = (if v-use-Naim        then "":U                    else ?)
      p-print-graft  = (if v-use-print-graft then no                      else ?)
      p-sort-gr      = (if v-use-sort-gr     then no                      else ?)
      p-type-price   = (if v-use-type-price  then no                      else ?)
      p-type-val     = (if v-use-List_       then no                      else ?)
      .
    end.
  end.
end procedure.
procedure uf-set :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define input  parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define input  parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define input  parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define input  parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define input  parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define input  parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr   as logical   no-undo .
    define variable v-use-type-price as logical   no-undo .
    define variable v-use-type-val  as logical   no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
      (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if not avail buf_usr-flt then do:
        create buf_usr-flt .
        assign
        buf_usr-flt.call-point = p-code
        buf_usr-flt.user-name  = p-user-name
        .
    end.
    if avail buf_usr-flt then do:
     assign
     buf_usr-flt.List_       =  (if v-use-List_       then  p-List_        else ?)
     buf_usr-flt.Naim        =  (if v-use-Naim        then  p-Naim         else ?)
     buf_usr-flt.print-graft =  (if v-use-print-graft then  p-print-graft  else ?)
     buf_usr-flt.sort-gr     =  (if v-use-sort-gr     then  p-sort-gr      else ?)
     buf_usr-flt.type-price  =  (if v-use-type-price  then  p-type-price   else ?)
     buf_usr-flt.type-val    =  (if v-use-List_       then  p-type-val     else ?)
    .
    release buf_usr-flt.
    end.
    else undo, return error ("Ошибка при записи usr-flt" + substitute(" call-point=&1, user-name=&2", p-code, p-user-name)).
  end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
 define NEW SHARED temp-table temp-list-buyer no-undo ~
field obj-type as character ~
field obj-code as integer   ~
index pi is primary unique  ~
obj-type ~
obj-code.
def var vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info11 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info11, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info11, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info11, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info11, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info11 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info11, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info11 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info11, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info11, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info11, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info11, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info11, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info11, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info11 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info11 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info11, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info11, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info11, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info11 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info11 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info11, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info11, v-inform, v-tbl-name ).
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
define variable v-types     as character no-undo init 'все':U.
define variable v-group    like ub.clients.grp-name no-undo init 'все':U.
define variable v-status   as character no-undo init 'текущие':U.
define variable v-recid    as recid no-undo init ?.
define variable v-added    as character no-undo init  ",,,,,,NO,,":u  .
define variable v-other    as character no-undo init "":U.
define variable v-without-obj as logical no-undo .
define variable v-s-deploy as logical no-undo .
define variable v-lock-cli-type as logical no-undo .
define variable v-is-news as logical no-undo .
define variable v-tank-farm-for as character no-undo.
define variable v-auto-tank-for as character no-undo.
define variable v-tank-farm-for-supp as character no-undo.
define variable v-auto-tank-for-supp as character no-undo.
define variable p-callback-handle as handle no-undo .
define variable v-new-selection-flag as logical no-undo .
define variable v-is-prod as logical no-undo.
define variable v-rid-list as character no-undo .
DEFINE VARIABLE cli-dpcnt as decimal no-undo .
DEFINE VARIABLE cli-dcard like ub.dis-card.d-card no-undo .
DEFINE VARIABLE template-recid as recid no-undo.
DEFINE VARIABLE All-Suppliers as logical   no-undo .
DEFINE VARIABLE SupGds as logical   no-undo .
DEFINE VARIABLE SupCons as logical   no-undo .
DEFINE VARIABLE SupServ as logical   no-undo .
DEFINE VARIABLE All-Buyers as logical    no-undo .
DEFINE VARIABLE BuyGds as logical   no-undo .
DEFINE VARIABLE BuyCons as logical  no-undo .
DEFINE VARIABLE BuyServ as logical   no-undo .
DEFINE VARIABLE WLim-kr AS LOGICAL NO-UNDO.
define variable f-turn-buyer as logical   no-undo .
define variable f-grp-buyer  as logical   no-undo .
DEFINE VARIABLE JoinType            as  char    init "NO" no-undo .
DEFINE VARIABLE show-as             as char no-undo .
DEFINE VARIABLE Curr-Grp-Name as char no-undo .
DEFINE VARIABLE attr-option_ as  character no-undo    init "".
DEFINE VARIABLE filter-point as character no-undo .
DEFINE VARIABLE filter-point0 as character no-undo .
DEFINE VARIABLE sort-column-name as character no-undo .
DEFINE VARIABLE photo   as logical no-undo .
DEFINE VARIABLE var-br-name as character no-undo.
DEFINE VARIABLE var-prev-br-name as character no-undo.
DEFINE VARIABLE getc-recid as logical no-undo .
define variable g#log as logical no-undo .
define variable attr-option as character no-undo .
define variable sert-option as character no-undo .
define variable price-grp as character no-undo .
define variable choice   as      logical no-undo    init ?.
define variable var-cli-name as character no-undo.
define variable v-obj-name-width as decimal no-undo init 40.
define variable v-grp-name-width as decimal no-undo init 60.
define variable v-filter-name as character no-undo .
DEFINE VARIABLE is-edi  as logical no-undo .
DEFINE VARIABLE is-fin  as logical no-undo .
define variable is-price-buyer as logical   no-undo .
DEFINE VARIABLE par-type    as char no-undo .
define variable v-start as logical no-undo init yes.
define buffer s-clients for ub.clients.
define new shared buffer clients for ub.clients.
define new shared buffer clients-attr for ub.clients-attr.
define buffer pos_clients for ub.clients.
DEFINE VARIABLE v-list-b as logical no-undo INIT NO.
define new shared buffer x_temp-list-buyer for temp-list-buyer  .
define variable p-sum-1  as character no-undo .
define variable p-sum-2  as character no-undo .
define variable p-grp-b-name as character no-undo .
define variable p-grp-buyer-id     as integer   no-undo .
define variable p-grp-buyer-db-num as integer   no-undo .
define variable v-last-inn-rec as recid no-undo.
FUNCTION get-client RETURNS CHARACTER
  (buffer loc_clients for clients  )  FORWARD.
FUNCTION mark-string RETURNS CHARACTER
  ( buffer loc_clients for clients, input mark-list as character )  FORWARD.
FUNCTION prep-nameorcode RETURNS CHARACTER
  ( input p-nameorcode as character )  FORWARD.
DEFINE MENU m-gds
       MENU-ITEM m-gds-1        LABEL "Товары по производителю"
       MENU-ITEM m-gds-2        LABEL "Остатки по поставщику (партии)"
       MENU-ITEM m-gds-3        LABEL "Остатки по поставщику (товары)"
       MENU-ITEM m-gds-4        LABEL "Обороты по поставщику (партии)"
       MENU-ITEM m-gds-5        LABEL "Обороты по поставщику (товары)"
       MENU-ITEM m-gds-6        LABEL "Обороты по контрагенту"
       RULE
       MENU-ITEM m_turnover-buyer LABEL "Обороты по покупателю".
DEFINE MENU MENU-B-attr
       MENU-ITEM m_lookup-attr  LABEL "Просмотр"
       MENU-ITEM m_update-attr  LABEL "Изменение"     .
DEFINE MENU MENU-B-sert
       MENU-ITEM m_sert         LABEL "Сертификаты"
       MENU-ITEM m_licsupp      LABEL "Лицензии на поставку алкоголя".
DEFINE BUTTON Del-Filters
     LABEL "Снять доп. фильтр"
     SIZE 20 BY 1.
DEFINE BUTTON B-add
     LABEL "&Добав. орг"
     SIZE 12 BY 1.
DEFINE BUTTON B-add-prs
     LABEL "&Добав. чел"
     SIZE 12 BY 1.
DEFINE BUTTON B-attr
     LABEL "&Атрибуты"
     SIZE 9 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-bank
     LABEL "&Банки"
     SIZE 12 BY 1.
DEFINE BUTTON b-chg
     LABEL "&Измен"
     SIZE 8 BY 1.
DEFINE BUTTON B-cont
     LABEL "Договор"
     SIZE 8 BY 1.
DEFINE BUTTON b-dc
     LABEL "Д.карты"
     SIZE 8 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удал"
     SIZE 8 BY 1.
DEFINE BUTTON B-docs
     LABEL "&Док-ты"
     SIZE 8 BY 1.
DEFINE BUTTON B-edi
     LABEL "&EDI"
     SIZE 9 BY 1 TOOLTIP "Параметры EDI".
DEFINE BUTTON B-grp
     LABEL "&Группа"
     SIZE 9 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 2 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 2 BY 1.
DEFINE BUTTON B-lkp
     LABEL "&Просм"
     SIZE 8 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON B-photo
     LABEL "&Фото"
     SIZE 9 BY 1.
DEFINE BUTTON B-price-type
     LABEL "&Цены"
     SIZE 8 BY 1 TOOLTIP "Список типов прайс-листов по клиенту".
DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 2 BY 1.
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 8 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 2 BY 1.
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 12 BY 1.
DEFINE BUTTON b-sert
     LABEL "&Сертиф"
     SIZE 8 BY 1.
DEFINE BUTTON b-zak
     LABEL "&Заказы"
     SIZE 8 BY 1.
DEFINE BUTTON Goods-by-prod
     LABEL "Оборот&ы"
     SIZE 8 BY 1.
DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 10.6 BY .67 NO-UNDO.
DEFINE VARIABLE NameOrCode AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 20.4 BY 1.05
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE All-Or-Group AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "1", "1",
"2", "2",
"3", "3"
     SIZE 24.4 BY 1 NO-UNDO.
DEFINE VARIABLE Cli-Status AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "1", "1",
"2", "2",
"3", "3"
     SIZE 36.6 BY 1 NO-UNDO.
DEFINE VARIABLE Cli-Types AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "1", "1",
"2", "2",
"3", "3",
"4", "4",
"5", "5",
"6", "6"
     SIZE 55.6 BY 1 NO-UNDO.
DEFINE VARIABLE Find-by AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "1", "1",
"2", "2",
"3", "3",
"4", "4"
     SIZE 28 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-All-or-Group
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 40.4 BY 1.33.
DEFINE RECTANGLE RECT-status
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 40.4 BY 2.
DEFINE RECTANGLE RECT-types
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 57.4 BY 3.52.
DEFINE NEW SHARED QUERY CLi-List FOR
                X_clients SCROLLING.
DEFINE NEW SHARED QUERY CLi-ListA FOR
                X_clients,
                X_clients-attr SCROLLING.
DEFINE NEW SHARED QUERY CLi-ListB FOR  X_clients,
      x_temp-list-buyer SCROLLING.
DEFINE BROWSE CLi-List
  QUERY CLi-List DISPLAY
      (mark-string(buffer X_clients, v-rid-list)) COLUMN-LABEL "*" FORMAT "x(1)"       (STRING (X_clients.obj-code, "999999999")  +  " "  +  TRIM (X_clients.obj-type)) COLUMN-LABEL "Код/Тип" FORMAT "X(13)"       var-cli-name COLUMN-LABEL "Контрагент" FORMAT "x(130)"       X_clients.host-code COLUMN-LABEL "Фирма" FORMAT ">>>>>>>>9"       X_clients.db-num COLUMN-LABEL "БД" FORMAT ">>>>>>>>9"       X_clients.is-prod COLUMN-LABEL "Пр-ль" FORMAT "  +/"       X_clients.sup-gds COLUMN-LABEL "Пост-к/т" FORMAT "  +/"       X_clients.sup-cons COLUMN-LABEL "Пост-к/к" FORMAT "  +/"        X_clients.buy-gds COLUMN-LABEL "Пок-ль/т" FORMAT "  +/"       X_clients.buy-cons COLUMN-LABEL "Пок-ль/к" FORMAT "  +/"       X_clients.buy-serv COLUMN-LABEL "Пок-ль/у" FORMAT "  +/"       X_clients.grp-name FORMAT "X(60)"       cli-dcard COLUMN-LABEL "Дисконтная карта" FORMAT "x(11)"       (cli-dpcnt) COLUMN-LABEL "% скидки" FORMAT "->>>9.99"       X_clients.PS FORMAT "X(60)"       X_clients.lim-kr       price-grp COLUMN-LABEL "Группа ценообразования" FORMAT "x(20)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.33.
DEFINE BROWSE CLi-ListA
  QUERY CLi-ListA NO-LOCK DISPLAY
      (mark-string(buffer X_clients, v-rid-list)) COLUMN-LABEL "*" FORMAT "x(1)"       (STRING (X_clients.obj-code, "999999999")  +  " "  +  TRIM (X_clients.obj-type)) COLUMN-LABEL "Код/Тип" FORMAT "X(13)"       var-cli-name COLUMN-LABEL "Контрагент" FORMAT "x(130)"       X_clients.host-code COLUMN-LABEL "Фирма" FORMAT ">>>>>>>>9"       X_clients.db-num COLUMN-LABEL "БД" FORMAT ">>>>>>>>9"       X_clients.is-prod COLUMN-LABEL "Пр-ль" FORMAT "  +/"       X_clients.sup-gds COLUMN-LABEL "Пост-к/т" FORMAT "  +/"       X_clients.sup-cons COLUMN-LABEL "Пост-к/к" FORMAT "  +/"        X_clients.buy-gds COLUMN-LABEL "Пок-ль/т" FORMAT "  +/"       X_clients.buy-cons COLUMN-LABEL "Пок-ль/к" FORMAT "  +/"       X_clients.buy-serv COLUMN-LABEL "Пок-ль/у" FORMAT "  +/"       X_clients.grp-name FORMAT "X(60)"       cli-dcard COLUMN-LABEL "Дисконтная карта" FORMAT "x(11)"       (cli-dpcnt) COLUMN-LABEL "% скидки" FORMAT "->>>9.99"       X_clients.PS FORMAT "X(60)"       X_clients.lim-kr       price-grp COLUMN-LABEL "Группа ценообразования" FORMAT "x(20)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.33 ROW-HEIGHT-CHARS .67.
DEFINE BROWSE CLi-ListB
  QUERY CLi-ListB NO-LOCK DISPLAY
      (mark-string(buffer X_clients, v-rid-list)) COLUMN-LABEL "*" FORMAT "x(1)"       (STRING (X_clients.obj-code, "999999999")  +  " "  +  TRIM (X_clients.obj-type)) COLUMN-LABEL "Код/Тип" FORMAT "X(13)"       var-cli-name COLUMN-LABEL "Контрагент" FORMAT "x(130)"       X_clients.host-code COLUMN-LABEL "Фирма" FORMAT ">>>>>>>>9"       X_clients.db-num COLUMN-LABEL "БД" FORMAT ">>>>>>>>9"       X_clients.is-prod COLUMN-LABEL "Пр-ль" FORMAT "  +/"       X_clients.sup-gds COLUMN-LABEL "Пост-к/т" FORMAT "  +/"       X_clients.sup-cons COLUMN-LABEL "Пост-к/к" FORMAT "  +/"        X_clients.buy-gds COLUMN-LABEL "Пок-ль/т" FORMAT "  +/"       X_clients.buy-cons COLUMN-LABEL "Пок-ль/к" FORMAT "  +/"       X_clients.buy-serv COLUMN-LABEL "Пок-ль/у" FORMAT "  +/"       X_clients.grp-name FORMAT "X(60)"       cli-dcard COLUMN-LABEL "Дисконтная карта" FORMAT "x(11)"       (cli-dpcnt) COLUMN-LABEL "% скидки" FORMAT "->>>9.99"       X_clients.PS FORMAT "X(60)"       X_clients.lim-kr       price-grp COLUMN-LABEL "Группа ценообразования" FORMAT "x(20)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.33 ROW-HEIGHT-CHARS .67.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 13
     B-sel AT ROW 1 COL 16
     B-bank AT ROW 1 COL 28
     B-docs AT ROW 1 COL 40
     Goods-by-prod AT ROW 1 COL 48
     b-dc AT ROW 1 COL 56
     b-zak AT ROW 1 COL 64
     b-sert AT ROW 1 COL 72
     B-attr AT ROW 1 COL 80
     b-hist AT ROW 1 COL 91
     b-print AT ROW 1 COL 93
     B-sch AT ROW 1 COL 95
     B-Help AT ROW 1 COL 97.6
     B-add AT ROW 2 COL 16
     B-add-prs AT ROW 2 COL 28
     B-lkp AT ROW 2 COL 40
     b-chg AT ROW 2 COL 48
     b-del AT ROW 2 COL 56
     B-price-type AT ROW 2 COL 64
     B-cont AT ROW 2 COL 72
     B-grp AT ROW 2 COL 80
     B-edi AT ROW 2 COL 89
     B-photo AT ROW 3 COL 89
     Find-by AT ROW 3.14 COL 12 NO-LABEL
     NameOrCode AT ROW 3.19 COL 39 COLON-ALIGNED NO-LABEL
     CLi-ListB AT ROW 4.52 COL 1.4
     CLi-ListA AT ROW 4.52 COL 1.4
     CLi-List AT ROW 4.52 COL 1.4
     All-Or-Group AT ROW 20.29 COL 74.2 NO-LABEL
     Del-Filters AT ROW 20.52 COL 35.2
     Cli-Types AT ROW 22 COL 2 NO-LABEL
     Cli-Status AT ROW 22.38 COL 60.4 NO-LABEL
     mark-num AT ROW 2.19 COL 1.6 NO-LABEL
     "Статус" VIEW-AS TEXT
          SIZE 14 BY .67 AT ROW 21.57 COL 70
          FGCOLOR 4
     "Фильтры" VIEW-AS TEXT
          SIZE 14 BY .67 AT ROW 20.52 COL 9.4
          BGCOLOR 8 FGCOLOR 4
     "Классификатор" VIEW-AS TEXT
          SIZE 14 BY 1 AT ROW 20.29 COL 59.8
          FGCOLOR 4
     "Поиск:" VIEW-AS TEXT
          SIZE 7.4 BY 1 AT ROW 3.19 COL 3.6
          FGCOLOR 4
     RECT-status AT ROW 21.52 COL 59
     RECT-types AT ROW 20 COL 1.2
     RECT-All-or-Group AT ROW 20.05 COL 59
     SPACE(0.49) SKIP(2.21)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Клиенты"
         DEFAULT-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-attr:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-attr:HANDLE.
ASSIGN
       b-sert:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-sert:HANDLE.
ASSIGN
       Goods-by-prod:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-gds:HANDLE.
ON END-ERROR OF FRAME Dialog-Frame
DO:
run gbl/markqwa.p (
              input b-mark:sensitive
            , input v-rid-list) no-error.
    if error-status:error then return no-apply.
END.
ON ENDKEY OF FRAME Dialog-Frame
DO:
run gbl/markqwa.p (
              input b-mark:sensitive
            , input v-rid-list) no-error.
    if error-status:error then return no-apply.
END.
ON GO OF FRAME Dialog-Frame
DO:
  p-rid-list = v-rid-list.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF Del-Filters IN FRAME Dialog-Frame
DO:
define variable g-log as logical   no-undo .
assign
      var-prev-br-name = var-br-name
      var-br-name = "cli-list"
      v-list-b = false
      ALL-Or-GROUP
      .
      g-log = ALL-Or-GROUP:enable ( radio-label ( 'АТР':U, ALL-Or-GROUP:radio-buttons) ).
  disable Del-Filters
  with frame Dialog-Frame .
  assign
  All-Suppliers = FALSE
  SupGds = FALSE
  SupCons = FALSE
  SupServ = FALSE
  All-Buyers = FALSE
  BuyGds = FALSE
  BuyCons = FALSE
  BuyServ = FALSE
  JoinType = "NO"
  WLim-kr = FALSE
  f-turn-buyer =  false
  f-grp-buyer  =  false
  Find-By:screen-value = 'все':U
  NameOrCode = ""
  .
  apply "value-changed" to Find-By in frame Dialog-Frame .
case var-br-name :         when "cli-list":U then do:            apply "entry" to Cli-List in frame Dialog-Frame.         end.         when "cli-listA":U then do:            apply "entry" to Cli-ListA in frame Dialog-Frame.         end.         when "cli-listB":U then do:            apply "entry" to Cli-ListB in frame Dialog-Frame.         end.         end case.
END.
ON VALUE-CHANGED OF All-Or-Group IN FRAME Dialog-Frame
DO:
  run proc-value-change-all-or-group in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
run proc-b-add in this-procedure ( input yes ) no-error.
if error-status:error then return no-apply.
END.
ON CHOOSE OF B-add-prs IN FRAME Dialog-Frame
DO:
run proc-b-add in this-procedure ( input no ) no-error.
if error-status:error then return no-apply.
END.
ON CHOOSE OF B-attr IN FRAME Dialog-Frame
DO:
 define variable v-updated as logical no-undo .
 define variable v-is-error as logical no-undo .
 define variable ri as recid no-undo  .
  if not available X_clients then do:
        return no-apply.
  end.
  ri = recid(X_clients).
  if attr-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if attr-option = "":U then do:
      return no-apply.
  end.
  if attr-option = 'ПРОСМОТР':U
  then do :
    g#log = NO.
  end .
  else do :
    CASE X_clients.obj-type :
      when 'орг':U
      then do:
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_client-reference_add-del':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
      end.
      when 'чел':U
      then do:
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_client-reference-prs_add-del':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
      end.
      WHEN 'маг':U OR WHEN 'скл':U THEN DO:
          g#log = NO.
      END.
    END CASE.
  end .
  run ref/ca-attrr.p (
                    input parparentproc
                   ,input (if  NOT can-do( 'удаленные':U , Cli-Status )
                          then (if can-do( p-bttns, "b-add")
                               AND attr-option = 'ИЗМЕНЕНИЕ':U
                               AND g#log
                               then 'ИЗМЕНЕНИЕ':U
                               else 'ПРОСМОТР':U)
                          else 'ПРОСМОТР':U
                        )
                   ,input X_clients.obj-type
                   ,input X_clients.obj-code
                   ,input yes
                   ,output v-updated
                   ,output v-is-error
                   ) no-error.
  if error-status:error
  or v-is-error then do:
    message
    "Ошибка при вызове списка атрибутов клиента" skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box .
    assign
    attr-option = "":U
    .
    undo, return no-apply.
  end.
  if attr-option = 'ИЗМЕНЕНИЕ':U and v-updated then do:
   if find-by = 'название':U then do:
      apply "RETURN" to Nameorcode.
    end.
    else do:
      assign
      find-by = 'все':U
      getc-recid = yes
      .
      display
      find-by
      with frame Dialog-Frame .
      run proc-vc-find-by in this-procedure ( input no) no-error.
      if (X_clients.obj-type = 'чел':U
                or X_clients.obj-type = 'орг':U
              )
            AND ri <> ? then do:
        case var-br-name :         when "cli-list":U then do:            Run OpenBR in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         when "cli-listA":U then do:            Run OpenBRA in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         when "cli-listB":U then do:            Run OpenBRB in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         end case.
        case var-br-name :         when "cli-list":U then do:            reposition Cli-List to recid ri no-error .         end.         when "cli-listA":U then do:            reposition Cli-ListA to recid ri no-error .         end.         when "cli-listB":U then do:            reposition Cli-ListB to recid ri no-error .          end.         end case.
        if error-status:error then do:
                  find first pos_clients no-lock where       recid( pos_clients ) = ri no-error .   message  substitute("Невозможно позиционироваться на клиенте &1&2Клиент был добавлен (или изменен или удален)&2и теперь не попадает в текущую выборку"             ,(if available pos_clients then (pos_clients.obj-type + string(pos_clients.obj-code)) else '':U)              , chr(10)) view-as alert-box WARNING.
        end.
      end.
    end.
  end.
  attr-option = "":U.
  case var-br-name :         when "cli-list":U then do:            apply "entry" to Cli-List in frame Dialog-Frame.         end.         when "cli-listA":U then do:            apply "entry" to Cli-ListA in frame Dialog-Frame.         end.         when "cli-listB":U then do:            apply "entry" to Cli-ListB in frame Dialog-Frame.         end.         end case.
END.
ON CHOOSE OF B-bank IN FRAME Dialog-Frame
DO:
define variable ri as recid no-undo.
define variable v-rid-list as character no-undo .
define variable v-status_ like ub.fin-schet.status_ no-undo init 'все':U.
if available  X_clients then do:
  if X_clients.obj-type = 'скл':U
  or X_clients.obj-type = 'маг':U then do:
     message
     substitute("У &1 или &2 не может быть банков (банковских счетов)"
               , 'маг':U
               , 'скл':U)
     view-as alert-box error .
     return no-apply.
  end.
  run ref/finschts.w (
                      INPUT parParentProc
                     ,input v-cntxt-host-code-obj
                     ,input "b-add":U
                     ,input "cmp-host":U
                     ,input X_clients.obj-type
                     ,input X_clients.obj-code
                     ,input ?
                     ,input v-cntxt-host-code-obj
                     ,input 0
                     ,input-output v-status_
                     ,input-output v-rid-list ).
end.
case var-br-name :         when "cli-list":U then do:            apply "entry" to Cli-List in frame Dialog-Frame.         end.         when "cli-listA":U then do:            apply "entry" to Cli-ListA in frame Dialog-Frame.         end.         when "cli-listB":U then do:            apply "entry" to Cli-ListB in frame Dialog-Frame.         end.         end case.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
define variable ri as recid no-undo.
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_client-reference_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
if not g#log then return no-apply.
if not available X_clients then return no-apply.
ri = recid( X_clients ) .
c-recid = ri .
CASE X_clients.obj-type:
  when 'орг':U  then
      run ref/firmi.w (
                   input parParentProc
                  ,input ('ИЗМЕНЕНИЕ':U + (if v-s-deploy then (";":U + "s-deploy":U) else "":U))
                  ,input X_clients.obj-code
                  ,input X_clients.grp-code
                  ,input  "cli-all"
                  ,input-output  ri) .
  when 'чел':U then
      run ref/personi.w (
                     input parParentProc
                    ,input 'ИЗМЕНЕНИЕ':U
                    ,input X_clients.obj-code
                    ,input X_clients.grp-code
                    ,input "cli-all"
                    ,input-output  ri) .
  when 'маг':U OR when 'скл':U  then
      message "Изменение объектов типа ~"склад~" или ~"магазин~" "
                      "возможно только из АРМа ~"Администратор~"."
                      view-as alert-box INFORMATION .
END CASE .
if find-by = 'название':U then do:
  apply "RETURN" to Nameorcode.
end.
else do:
  assign
  find-by = 'все':U
  getc-recid = yes
  .
  display
  find-by
  with frame Dialog-Frame .
  run proc-vc-find-by in this-procedure ( input no) no-error.
  if (X_clients.obj-type = 'чел':U
            or X_clients.obj-type = 'орг':U
          )
        AND ri <> ? then do:
    case var-br-name :         when "cli-list":U then do:            Run OpenBR in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         when "cli-listA":U then do:            Run OpenBRA in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         when "cli-listB":U then do:            Run OpenBRB in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         end case.
    case var-br-name :         when "cli-list":U then do:            reposition Cli-List to recid ri no-error .         end.         when "cli-listA":U then do:            reposition Cli-ListA to recid ri no-error .         end.         when "cli-listB":U then do:            reposition Cli-ListB to recid ri no-error .          end.         end case.
    if error-status:error then do:
          find first pos_clients no-lock where       recid( pos_clients ) = ri no-error .   message  substitute("Невозможно позиционироваться на клиенте &1&2Клиент был добавлен (или изменен или удален)&2и теперь не попадает в текущую выборку"             ,(if available pos_clients then (pos_clients.obj-type + string(pos_clients.obj-code)) else '':U)              , chr(10)) view-as alert-box WARNING.
    end.
  end.
end.
case var-br-name :         when "cli-list":U then do:            apply "entry" to Cli-List in frame Dialog-Frame.         end.         when "cli-listA":U then do:            apply "entry" to Cli-ListA in frame Dialog-Frame.         end.         when "cli-listB":U then do:            apply "entry" to Cli-ListB in frame Dialog-Frame.         end.         end case.
END.
ON CHOOSE OF B-cont IN FRAME Dialog-Frame
DO:
   DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
    IF NOT AVAILABLE X_clients THEN RETURN NO-APPLY.
    run str/cont-all.w (
           input   parParentProc
          ,input   v-cntxt-host-code-obj
          ,input   ""
          ,input   'фирма':U
          ,input   X_clients.obj-type
          ,input   X_clients.obj-code
          ,input   ?
          ,input   ?
          ,input   "current"
          ,input   "all"
          ,input-output v-rid-list )
          .
  case var-br-name :         when "cli-list":U then do:            apply "entry" to Cli-List in frame Dialog-Frame.         end.         when "cli-listA":U then do:            apply "entry" to Cli-ListA in frame Dialog-Frame.         end.         when "cli-listB":U then do:            apply "entry" to Cli-ListB in frame Dialog-Frame.         end.         end case.
END.
ON CHOOSE OF b-dc IN FRAME Dialog-Frame
DO:
   if not available X_clients then return no-apply.
     run ref/discards.w (
                    input parparentproc
                   ,input  "":U
                   ,input "client":u
                   ,input v-cntxt-host-code-obj
                   ,input v-cntxt-obj-type
                   ,input v-cntxt-obj-code
                   ,input '':U
                   ,input recid( X_clients )
                   ,output v-rid-list ) no-error .
     case var-br-name :         when "cli-list":U then do:            apply "entry" to Cli-List in frame Dialog-Frame.         end.         when "cli-listA":U then do:            apply "entry" to Cli-ListA in frame Dialog-Frame.         end.         when "cli-listB":U then do:            apply "entry" to Cli-ListB in frame Dialog-Frame.         end.         end case.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
define variable ri as recid no-undo .
if not avail X_clients then return no-apply.
ri = recid(X_clients).
run ref/clients2.p ( input parparentproc
                    ,input recid(X_clients)
                    ,input ?
                    ,input no
                    ,input no
                    ,input '':U
                    ,input '':U
                    ,input '':U
                    ) no-error .
if error-status:error then do:
  return no-apply.
end.
case var-br-name :         when "cli-list":U then do:            Run OpenBR in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         when "cli-listA":U then do:            Run OpenBRA in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         when "cli-listB":U then do:            Run OpenBRB in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         end case.
case var-br-name :         when "cli-list":U then do:            reposition Cli-List to recid ri no-error .         end.         when "cli-listA":U then do:            reposition Cli-ListA to recid ri no-error .         end.         when "cli-listB":U then do:            reposition Cli-ListB to recid ri no-error .          end.         end case.
if error-status:error then do:
  find first pos_clients no-lock where       recid( pos_clients ) = ri no-error .   message  substitute("Невозможно позиционироваться на клиенте &1&2Клиент был добавлен (или изменен или удален)&2и теперь не попадает в текущую выборку"             ,(if available pos_clients then (pos_clients.obj-type + string(pos_clients.obj-code)) else '':U)              , chr(10)) view-as alert-box WARNING.
end.
END.
ON CHOOSE OF B-docs IN FRAME Dialog-Frame
DO:
define variable doc-t as character no-undo.
DEFINE VARIABLE loc-ref-list as character no-undo.
define variable v-input-output as character no-undo .
define variable v-list-mode as character no-undo .
if not available X_clients then return no-apply.
run ref/doc-type.w ( output doc-t ) .
CASE doc-t :
  when "кон"  then
  v-list-mode = 'Контрагент':U.
  when "мен"  then
  v-list-mode = "МЕНЕДЖЕР".
  when "исп"  then
  v-list-mode = "ИСПОЛНИТЕЛЬ".
  when "кла"  then
  v-list-mode = "КЛАДОВЩИК".
  otherwise do:
    return no-apply.
  end.
END CASE .
run str/all-docs.w (
               input parparentproc
              ,input v-cntxt-host-code-obj
              ,input v-cntxt-obj-type
              ,input v-cntxt-obj-code
              ,input v-list-mode
              ,input ?
              ,input ?
              ,input ?
              ,input ?
              ,input '':U
              ,input '':U
              ,input ?
              ,input recid(X_clients)
              ,output loc-ref-list
              ) no-error .
              if error-status :error then message
                vss-workfile vss-revision vss-description skip
                error-status :get-message(1) skip
                return-value skip
                "Ошибка all-docs.w"
                view-as alert-box error
              .
  case var-br-name :         when "cli-list":U then do:            apply "entry" to Cli-List in frame Dialog-Frame.         end.         when "cli-listA":U then do:            apply "entry" to Cli-ListA in frame Dialog-Frame.         end.         when "cli-listB":U then do:            apply "entry" to Cli-ListB in frame Dialog-Frame.         end.         end case.
END.
ON CHOOSE OF B-edi IN FRAME Dialog-Frame
DO:
  define variable v-loc-rid-list as character no-undo .
  define variable v-uniq-key-rec as character no-undo .
    if not available X_clients then return no-apply.
  run gen-key-rec in this-procedure ( input 'clients':U
                                     ,input ( buffer X_clients:handle)
                                     ,output v-uniq-key-rec).
  run cus/exiteedi.w (
                         INPUT parparentproc
                        ,INPUT  ""
                        ,INPUT  "client"
                        ,INPUT  v-uniq-key-rec
                        ,input-output v-loc-rid-list  ) no-error.
END.
ON CHOOSE OF B-grp IN FRAME Dialog-Frame
DO:
define variable lns-cnt as integer no-undo .
define variable g-grp as character no-undo .
define variable v-gds-rec as recid no-undo.
define variable ri as recid no-undo .
define buffer buf_clients for ub.clients.
if not available X_clients then return no-apply.
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_client-reference_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
if not g#log then return no-apply.
g#log = yes.
message
"Выберите группу, в которую нужно" skip
"переместить клиента(ов)."
view-as alert-box question buttons OK-Cancel update g#log.
if not g#log then   do:
        apply "entry" to Cli-List in frame Dialog-Frame.
        return no-apply.
    end.
g-grp = "".
run ref/cli-grps.w (
                   input parparentproc
                 , input 'терм':U + ",b-sel"
                 , input-output g-grp ) .
if g-grp = "" then  do:
    case var-br-name :         when "cli-list":U then do:            apply "entry" to Cli-List in frame Dialog-Frame.         end.         when "cli-listA":U then do:            apply "entry" to Cli-ListA in frame Dialog-Frame.         end.         when "cli-listB":U then do:            apply "entry" to Cli-ListB in frame Dialog-Frame.         end.         end case.
    return no-apply.
 end.
else do transaction:
    FIND ub.cli-grp where recid( ub.cli-grp ) = integer( g-grp ) .
    if v-rid-list = "" then
    v-rid-list = string( recid( X_clients ) ) .
    lns-cnt = 1.
    DO WHILE lns-cnt <= num-entries( v-rid-list ) :
        v-gds-rec = integer( entry( lns-cnt, v-rid-list ) ) .
        if lns-cnt = 1 then ri = v-gds-rec.
        FIND buf_clients where recid( buf_clients ) = v-gds-rec.
        buf_clients.grp-code = ub.cli-grp.node-code.
        lns-cnt = lns-cnt + 1.
    END .
    v-rid-list = "".
    mark-num = 0.
    hide mark-num in frame Dialog-Frame.
end.
case var-br-name :         when "cli-list":U then do:            Run OpenBR in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         when "cli-listA":U then do:            Run OpenBRA in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         when "cli-listB":U then do:            Run OpenBRB in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         end case.
case var-br-name :         when "cli-list":U then do:            reposition Cli-List to recid ri no-error .         end.         when "cli-listA":U then do:            reposition Cli-ListA to recid ri no-error .         end.         when "cli-listB":U then do:            reposition Cli-ListB to recid ri no-error .          end.         end case.
if error-status:error then do:
  find first pos_clients no-lock where       recid( pos_clients ) = ri no-error .   message  substitute("Невозможно позиционироваться на клиенте &1&2Клиент был добавлен (или изменен или удален)&2и теперь не попадает в текущую выборку"             ,(if available pos_clients then (pos_clients.obj-type + string(pos_clients.obj-code)) else '':U)              , chr(10)) view-as alert-box WARNING.
end.
END.
ON CHOOSE OF b-hist IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo .
  if available X_clients THEN do:
    run ref/cclihist.w (
                      input parparentproc
                    , input 0
                    , input "":U
                    , input 0
                    , input "":U
                    , input "one":U
                    , input X_clients.obj-type
                    , input X_clients.obj-code
                    , input ?
                    , input ?
                    , input "":U
                    , input "":U
                    , input v-cntxt-db-num
                    , input-output v-rid-list  ) no-error .
  END.
  case var-br-name :         when "cli-list":U then do:            apply "entry" to Cli-List in frame Dialog-Frame.         end.         when "cli-listA":U then do:            apply "entry" to Cli-ListA in frame Dialog-Frame.         end.         when "cli-listB":U then do:            apply "entry" to Cli-ListB in frame Dialog-Frame.         end.         end case.
END.
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame
DO:
    RUN lkp-rec in this-procedure ( buffer X_clients ) no-error.
    case var-br-name :         when "cli-list":U then do:            apply "entry" to Cli-List in frame Dialog-Frame.         end.         when "cli-listA":U then do:            apply "entry" to Cli-ListA in frame Dialog-Frame.         end.         when "cli-listB":U then do:            apply "entry" to Cli-ListB in frame Dialog-Frame.         end.         end case.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
if available X_clients then   do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid18 as character no-undo .
define variable v-num-entry18 as integer   no-undo .
assign
  v-str-recid18 = trim( string( recid( X_clients ) , "->>>>>>>>>>>9":U ) )
  v-num-entry18 = lookup( v-str-recid18 , v-rid-list )
.
if v-num-entry18 > 0 then do:
  assign
    entry( v-num-entry18, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid18
  .
end.
  if v-new-selection-flag then do:
    run choose-mark in this-procedure  no-error .
    if error-status :error
    then do:
      return no-apply .
    end.
  end.
  else do:
  case var-br-name :         when "cli-list":U then do:            g#log = Cli-List:refresh() in frame Dialog-Frame .         end.         when "cli-listA":U then do:            g#log = Cli-ListA:refresh() .         end.         when "cli-listB":U then do:            g#log = Cli-ListB:refresh() .          end.         end case.
  if LOOKUP(last-event:function,  "MOUSE-SELECT-DBLCLICK, RETURN":U) = 0  then  do:
      case var-br-name :         when "cli-list":U then do:            g#log = Cli-List:select-next-row ().         end.         when "cli-listA":U then do:            g#log = Cli-ListA:select-next-row ().         end.         when "cli-listB":U then do:            g#log = Cli-ListB:select-next-row ().          end.         end case.
      case var-br-name :         when "cli-list":U then do:            apply "value-changed" to Cli-List in frame Dialog-Frame .         end.         when "cli-listA":U then do:            apply "value-changed" to Cli-ListA in frame Dialog-Frame .         end.         when "cli-listB":U then do:             apply "value-changed" to Cli-ListB in frame Dialog-Frame .         end.         end case.
  end.
  if num-entries( v-rid-list ) = 0 then do:
      hide
      mark-num in
      frame Dialog-Frame.
    end.
  else do:
      display
      num-entries( v-rid-list ) @ mark-num
      with frame Dialog-Frame.
  end.
end.
end.
case var-br-name :         when "cli-list":U then do:            apply "entry" to Cli-List in frame Dialog-Frame.         end.         when "cli-listA":U then do:            apply "entry" to Cli-ListA in frame Dialog-Frame.         end.         when "cli-listB":U then do:            apply "entry" to Cli-ListB in frame Dialog-Frame.         end.         end case.
END.
ON CHOOSE OF B-photo IN FRAME Dialog-Frame
DO:
    if not available X_clients then return no-apply.
    run ref/cli-ph.p
      (input parparentproc
      ,buffer X_clients
      ) no-error .
    case var-br-name :         when "cli-list":U then do:            apply "entry" to Cli-List in frame Dialog-Frame.         end.         when "cli-listA":U then do:            apply "entry" to Cli-ListA in frame Dialog-Frame.         end.         when "cli-listB":U then do:            apply "entry" to Cli-ListB in frame Dialog-Frame.         end.         end case.
END.
ON CHOOSE OF B-price-type IN FRAME Dialog-Frame
DO:
   define variable v-rid-list as character no-undo.
   if not available x_clients then return no-apply.
   run ref/c-tppr.p
   ( input parParentProc,
     input x_clients.obj-type ,
     input x_clients.obj-code ).
  case var-br-name :         when "cli-list":U then do:            apply "entry" to Cli-List in frame Dialog-Frame.         end.         when "cli-listA":U then do:            apply "entry" to Cli-ListA in frame Dialog-Frame.         end.         when "cli-listB":U then do:            apply "entry" to Cli-ListB in frame Dialog-Frame.         end.         end case.
END.
ON CHOOSE OF b-print IN FRAME Dialog-Frame
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
run gbl/markqwa.p (
              input b-mark:sensitive
            , input v-rid-list) no-error.
if error-status:error then return no-apply.
assign
All-Or-Group
Cli-Status
Cli-Types .
c-added = trim( string( SupGds ) ) + chr(44) +
                 trim( string( SupCons ) ) + chr(44) +
                 trim( string( SupServ ) ) + chr(44) +
                 trim( string( BuyGds ) ) + chr(44) +
                 trim( string( BuyCons ) ) + chr(44) +
                 trim( string( BuyServ ) ) + chr(44) +
                 string( JoinType ) + chr(44) +
                                      chr(44) +
                 ( trim( string( WLim-kr ) ) )
                 .
assign
c-group = ( if All-Or-Group = 'все':U
            then All-Or-Group
            else (if all-or-group = 'АТР':U
                  then ('АТР':U + chr(3) + attr-option_)
                  else ('группа':U + chr(3) + Curr-Grp-Name )
                 )
          )
c-status = Cli-Status
c-types = Cli-Types
c-recid = ( if available X_clients then recid( X_clients ) else ? )
v-uf-List_ = c-types + chr(4) +
           c-group + chr(4) +
           c-status + chr(4) +
           (if c-recid = ? then chr(63) else string(c-recid)) + chr(4) +
           c-added + chr(4) +
           c-other
v-uf-naim = (if browse cli-list:visible
             then (string(var-cli-name:width in browse cli-list) + chr(4) +
                   string(X_clients.grp-name:width in browse cli-list))
             else (string(var-cli-name:width in browse cli-lista) + chr(4) +
                  string(X_clients.grp-name:width in browse cli-lista))
             )
.
run uf-set in this-procedure (
    input  'cli-all-p':U
    ,input v-cntxt-userid
    ,input v-uf-List_
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
)  no-error .
if can-do( p-bttns, "b-sel") then
    v-rid-list = "" .
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
  RUN proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
if v-rid-list = ""
or b-mark:sensitive = no
then do:
   if available X_clients then
   v-rid-list = string( recid( X_clients ) ) .
end.
if v-new-selection-flag then do:
  run choose-select in this-procedure  no-error .
  if error-status :error
  then do:
    undo, return no-apply .
  end.
end.
assign
All-Or-Group
Cli-Status
Cli-Types
.
c-added = ( trim( string( SupGds ) ) ) + chr(44) +
                 ( trim( string( SupCons ) ) ) + chr(44) +
                 ( trim( string( SupServ ) ) ) + chr(44) +
                 ( trim( string( BuyGds ) ) ) + chr(44) +
                 ( trim( string( BuyCons ) ) ) + chr(44) +
                 ( trim( string( BuyServ ) ) ) + chr(44) +
                 string( JoinType ) + chr(44) +
                                      chr(44) +
                 ( trim( string( WLim-kr ) ) )
                 .
assign
c-group = ( if All-Or-Group = 'все':U
            then All-Or-Group
            else (if all-or-group = 'АТР':U
                  then ('АТР':U + chr(3) + attr-option_)
                  else ('группа':U + chr(3) + Curr-Grp-Name )
                 )
          )
c-status = Cli-Status
c-types = Cli-Types
c-recid = ( if available X_clients then recid( X_clients ) else ? )
.
END.
ON CHOOSE OF b-sert IN FRAME Dialog-Frame
DO:
   if not available X_clients then return no-apply.
   if X_clients.obj-type <> 'скл':U and X_clients.obj-type <> 'маг':U then DO:
      case sert-option:
         when "m_sert":U THEN DO:
            run ref/cli-sert.w (
                     input parparentproc
                     ,input v-cntxt-obj-type
                     ,input v-cntxt-obj-code
                     ,input "cli"
                     ,input X_clients.obj-type
                     ,input X_clients.obj-code
                     ,input ? ) .
         END.
         when "m_licsupp":U THEN DO:
            run ref/licsupp.w ( input parparentproc
                              , input X_clients.obj-type
                              , input X_clients.obj-code
                              ) .
         END.
         when "m_licsale":U THEN DO:
         end.
         otherwise do:
         end.
      end case.
   end.
   else do:
      message "Нельзя заводить сертификаты и лицензии по объектам"
      view-as alert-box error.
   end.
    case var-br-name :         when "cli-list":U then do:            apply "entry" to Cli-List in frame Dialog-Frame.         end.         when "cli-listA":U then do:            apply "entry" to Cli-ListA in frame Dialog-Frame.         end.         when "cli-listB":U then do:            apply "entry" to Cli-ListB in frame Dialog-Frame.         end.         end case.
END.
ON CHOOSE OF b-zak IN FRAME Dialog-Frame
DO:
 DEFINE VARIABLE v-output as character no-undo .
define variable v-input-output as character no-undo .
if not available X_clients then return no-apply.
  run ref/all-zakz.w (
     input   parParentProc
    ,input   "all":U
    ,input   "all":U
    ,input   'Контрагент':U
    ,input   recid( X_clients )
    ,input   "b-lkp"
    ,input   ""
    ,output  v-output   ) .
  case var-br-name :         when "cli-list":U then do:            apply "entry" to Cli-List in frame Dialog-Frame.         end.         when "cli-listA":U then do:            apply "entry" to Cli-ListA in frame Dialog-Frame.         end.         when "cli-listB":U then do:            apply "entry" to Cli-ListB in frame Dialog-Frame.         end.         end case.
END.
ON ANY-PRINTABLE OF CLi-List IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON MOUSE-SELECT-DBLCLICK OF CLi-List IN FRAME Dialog-Frame
DO:
  run br-mouse-select in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF CLi-List IN FRAME Dialog-Frame
DO:
  run br-return in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF CLi-List IN FRAME Dialog-Frame
DO:
  c-recid =  if available X_clients then recid( X_clients ) else ?  .
END.
ON ANY-PRINTABLE OF CLi-ListA IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON MOUSE-SELECT-DBLCLICK OF CLi-ListA IN FRAME Dialog-Frame
DO:
    run br-mouse-select in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF CLi-ListA IN FRAME Dialog-Frame
DO:
   run br-return in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF CLi-ListA IN FRAME Dialog-Frame
DO:
  c-recid =  if available X_clients then recid( X_clients ) else ?  .
END.
ON ANY-PRINTABLE OF CLi-ListB IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON MOUSE-SELECT-DBLCLICK OF CLi-ListB IN FRAME Dialog-Frame
DO:
    run br-mouse-select in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF CLi-ListB IN FRAME Dialog-Frame
DO:
   run br-return in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF CLi-ListB IN FRAME Dialog-Frame
DO:
  c-recid =  if available X_clients then recid( X_clients ) else ?  .
END.
ON VALUE-CHANGED OF Cli-Status IN FRAME Dialog-Frame
DO:
    assign
    getc-recid = yes
    Find-By:screen-value = 'все':U
    NameOrCode = ""
    .
    apply "value-changed" to Find-By in frame Dialog-Frame .
END.
ON VALUE-CHANGED OF Cli-Types IN FRAME Dialog-Frame
DO:
    assign
    v-is-prod = false
    Find-By:screen-value = 'все':U
    NameOrCode = ""
    cli-types
    getc-recid = if (
                     cli-types = 'все':U or
                     (avail X_clients and X_clients.is-prod and v-is-prod) OR
                     (avail X_clients and cli-types = X_clients.obj-type) or
                     (avail X_clients and (cli-types = 'объект':U or cli-types = "db") and (X_clients.obj-type = 'маг':U or X_clients.obj-type = 'скл':U))
                    ) then yes else no
    .
    case cli-types:
      when 'маг':U
      or when 'скл':U
      or when 'объект':U
      then do:
        assign
        X_clients.db-num:visible in browse cli-list = yes
        X_clients.host-code:visible in browse cli-list = yes
        X_clients.db-num:visible in browse cli-lista = yes
        X_clients.host-code:visible in browse cli-lista = yes
        X_clients.db-num:visible in browse cli-listb = yes
        X_clients.host-code:visible in browse cli-listb = yes
        .
      end.
      when "db" then do:
        assign
        X_clients.db-num:visible in browse cli-list = no
        X_clients.host-code:visible in browse cli-list = yes
        X_clients.db-num:visible in browse cli-lista = no
        X_clients.host-code:visible in browse cli-lista = yes
        X_clients.db-num:visible in browse cli-listb = no
        X_clients.host-code:visible in browse cli-listb = yes
        .
      end.
      otherwise do:
        assign
        X_clients.db-num:visible in browse cli-list = no
        X_clients.host-code:visible in browse cli-list = no
        X_clients.db-num:visible in browse cli-lista = no
        X_clients.host-code:visible in browse cli-lista = no
        X_clients.db-num:visible in browse cli-listb = no
        X_clients.host-code:visible in browse cli-listb = no
        .
      end.
    end case.
    apply "value-changed" to Find-By in frame Dialog-Frame .
END.
ON VALUE-CHANGED OF Find-by IN FRAME Dialog-Frame
DO:
   run proc-vc-find-by in this-procedure ( input yes) no-error.
   if error-status:error then return no-apply.
END.
ON CHOOSE OF Goods-by-prod IN FRAME Dialog-Frame
DO:
      if available X_clients then do:
            run gbl/pop-up.p ( input self:handle, input no) no-error.
        if error-status:error then return no-apply.
    end.
END.
ON CHOOSE OF MENU-ITEM m-gds-1
DO:
    if available X_clients then do:
        run gdsbypr in this-procedure ( input recid(X_clients), input "Товары по производителю") no-error.
    end.
END.
ON CHOOSE OF MENU-ITEM m-gds-2
DO:
    if available X_clients then do:
        run gdsbypr in this-procedure( input recid(X_clients),  input "Остатки по поставщику (партии)") no-error.
    end.
END.
ON CHOOSE OF MENU-ITEM m-gds-3
DO:
    if available X_clients then do:
        run gdsbypr in this-procedure (  input recid(X_clients),  input "Остатки по поставщику (товары)") no-error.
    end.
END.
ON CHOOSE OF MENU-ITEM m-gds-4
DO:
    if available X_clients then do:
        run gdsbypr in this-procedure (  input recid(X_clients),   input "Обороты по поставщику (партии)") no-error.
    end.
END.
ON CHOOSE OF MENU-ITEM m-gds-5
DO:
    if available X_clients then do:
        run gdsbypr in this-procedure (  input recid(X_clients),  input "Обороты по поставщику (товары)") no-error.
    end.
END.
ON CHOOSE OF MENU-ITEM m-gds-6
DO:
    if available X_clients then do:
        run gdsbypr in this-procedure (  input recid(X_clients),  input  "Обороты по контрагенту") no-error.
    end.
END.
ON CHOOSE OF MENU-ITEM m_licsupp
DO:
  assign
   sert-option = "m_licsupp":U
  .
  APPLY "CHOOSE" TO b-sert IN FRAME Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_lookup-attr
DO:
  assign
  ATTR-option = 'ПРОСМОТР':U
  .
  APPLY "CHOOSE" TO b-attr IN FRAME Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_sert
DO:
  assign
    sert-option = "m_sert":U
  .
  APPLY "CHOOSE" TO b-sert IN FRAME Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_turnover-buyer
DO:
define variable v-recid as character no-undo .
  if available X_clients then do:
     run ref/tov-br.w ( input parparentproc
                       ,input "b-add,b-chg,b-del"
                       ,input recid(X_clients)
                       ,output v-recid) .
  end.
END.
ON CHOOSE OF MENU-ITEM m_update-attr
DO:
  assign
  ATTR-option = 'ИЗМЕНЕНИЕ':U
  .
  APPLY "CHOOSE" TO b-attr  IN FRAME Dialog-Frame.
END.
ON LEAVE OF NameOrCode IN FRAME Dialog-Frame
DO:
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
    assign
    NameOrCode
    .
 if last-event:function <> "RETURN" then  do:
   if ( NameOrCode = "" ) OR ( num-results( var-br-name ) = 0 ) then   do:
      assign
      Find-By:screen-value = 'все':U
      NameOrCode = ""
      .
      DISABLE NameOrCode
      with frame Dialog-Frame .
      HIDE NameOrCode .
      apply "value-changed" to Find-By in frame Dialog-Frame .
  end.
end.
END.
ON RETURN OF NameOrCode IN FRAME Dialog-Frame
DO:
  run proc-return-nameorcode in this-procedure no-error .
  if error-status:error then return no-apply.
END.
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame Dialog-Frame anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-quit :sensitive then DO: apply "CHOOSE":U to b-quit in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame Dialog-Frame anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-total-select-num as integer   no-undo .
define temp-table temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
PROCEDURE userobjs_append :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_temp-user-obj for temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_temp-user-obj
      where buf_temp-user-obj.obj-type = p-obj-type
        and buf_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_temp-user-obj
    then do:
      create buf_temp-user-obj .
      assign
        buf_temp-user-obj.obj-type = p-obj-type
        buf_temp-user-obj.obj-code = p-obj-code
      .
      assign
        v-total-select-num = v-total-select-num + 1
      .
    end.
  end.
END PROCEDURE.
PROCEDURE userobjs_delete :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_temp-user-obj for temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_temp-user-obj
      where buf_temp-user-obj.obj-type = p-obj-type
        and buf_temp-user-obj.obj-code = p-obj-code
      no-error .
    if available buf_temp-user-obj
    then do:
      delete buf_temp-user-obj .
      assign
        v-total-select-num = v-total-select-num - 1
      .
    end.
  end.
END PROCEDURE.
PROCEDURE display-select-num :
  do
  on error undo, return error return-value
  :
    assign
      mark-num = v-total-select-num
    .
    display
      mark-num
      with frame Dialog-Frame.
    if v-total-select-num = 0
    then do:
      hide
        mark-num
        in frame Dialog-Frame.
    end.
    else do:
      display
        mark-num
        with frame Dialog-Frame.
    end.
  end.
END PROCEDURE.
PROCEDURE check-selection :
  define variable v-ok as logical   no-undo .
  define buffer buf_temp-user-obj for temp-user-obj .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      if can-do (p-bttns, "b-mark")
      then do:
        find first buf_temp-user-obj
          no-error .
        if available buf_temp-user-obj
        then do:
          message
            "Информация о выбранных элементах будет потеряна" Skip
            "Продолжить?" Skip
            view-as alert-box question buttons yes-no update v-ok .
          if v-ok = true
          then do:
            for each buf_temp-user-obj
            on error undo, return error return-value
            :
              delete buf_temp-user-obj .
            end.
          end.
          else do:
            undo, return error return-value .
          end.
        end.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE choose-mark :
  define variable v-log as logical no-undo .
  define buffer buf_temp-user-obj for temp-user-obj .
  do
  on error undo, return error return-value
  :
    if available X_clients
    then do:
      find first buf_temp-user-obj
        where buf_temp-user-obj.obj-type = X_clients.obj-type
          and buf_temp-user-obj.obj-code = X_clients.obj-code
        no-error .
      if available buf_temp-user-obj
      then do:
        run userobjs_delete in this-procedure
          (input  X_clients.obj-type
          ,input  X_clients.obj-code
          ) .
      end.
      else do:
        run userobjs_append in this-procedure
          (input  X_clients.obj-type
          ,input  X_clients.obj-code
          ) .
      end.
      case var-br-name :         when "cli-list":U then do:            g#log = Cli-List:refresh() in frame Dialog-Frame .         end.         when "cli-listA":U then do:            g#log = Cli-ListA:refresh() .         end.         when "cli-listB":U then do:            g#log = Cli-ListB:refresh() .          end.         end case.
      if last-event :function <> "MOUSE-SELECT-DBLCLICK"
      then do:
        case var-br-name :         when "cli-list":U then do:            g#log = Cli-List:select-next-row ().         end.         when "cli-listA":U then do:            g#log = Cli-ListA:select-next-row ().         end.         when "cli-listB":U then do:            g#log = Cli-ListB:select-next-row ().          end.         end case.
        case var-br-name :         when "cli-list":U then do:            apply "value-changed" to Cli-List in frame Dialog-Frame .         end.         when "cli-listA":U then do:            apply "value-changed" to Cli-ListA in frame Dialog-Frame .         end.         when "cli-listB":U then do:             apply "value-changed" to Cli-ListB in frame Dialog-Frame .         end.         end case.
      end.
      run display-select-num in this-procedure .
      case var-br-name :         when "cli-list":U then do:            apply "entry" to Cli-List in frame Dialog-Frame.         end.         when "cli-listA":U then do:            apply "entry" to Cli-ListA in frame Dialog-Frame.         end.         when "cli-listB":U then do:            apply "entry" to Cli-ListB in frame Dialog-Frame.         end.         end case.
    end.
  end.
END PROCEDURE.
PROCEDURE choose-select :
  define buffer buf_temp-user-obj for temp-user-obj .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      if available X_clients
      then do:
        if NOT can-do (p-bttns, "b-mark")
        then do:
        end.
        else do:
          find first buf_temp-user-obj
            no-error .
          if not available buf_temp-user-obj
          then do:
            run userobjs_append in this-procedure
              (input  X_clients.obj-type
              ,input  X_clients.obj-code
              ) .
          end.
          run userobjs_clear in p-callback-handle .
          for each buf_temp-user-obj
          on error undo, return error return-value
          :
            run userobjs_append in p-callback-handle
              (input  buf_temp-user-obj.obj-type
              ,input  buf_temp-user-obj.obj-code
              ) .
          end.
        end.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE get-mark-string :
  define input  parameter p-obj-type    as character no-undo .
  define input  parameter p-obj-code    as integer   no-undo .
  define output parameter p-mark-string as character no-undo .
  define buffer buf_temp-user-obj for temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_temp-user-obj
      where buf_temp-user-obj.obj-type = p-obj-type
        and buf_temp-user-obj.obj-code = p-obj-code
      no-error .
    if available buf_temp-user-obj
    then do:
      assign
        p-mark-string = '*':U
      .
    end.
    else do:
      assign
        p-mark-string = '':U
      .
    end.
  end.
END PROCEDURE.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse CLi-List :handle
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
    run diasize_init in this-procedure .
g#log = cli-list:SET-REPOSITIONED-ROW(5, "CONDITIONAL").
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numcli-list as INT EXTENT 16 no-undo.
DEF VAR varmvicli-list       as INT no-undo.
DEF VAR varmvjcli-list       as INT no-undo.
DEF VAR varmvkcli-list       as INT no-undo.
DEF VAR varmvlcli-list       as INT no-undo.
DEF VAR move-elementcli-list as INT no-undo.
def var jjcli-list           as int no-undo.
do varmvicli-list = 1 to EXTENT(cur-clmn-numcli-list):
  ASSIGN cur-clmn-numcli-list[varmvicli-list] = varmvicli-list.
END.
RUN start-mv-clmncli-list.
PROCEDURE start-mv-clmncli-list:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE cli-list do:
  RUN re-move-clmncli-list ( 1, 16).
END.
ON ctrl-cursor-left OF BROWSE cli-list do:
  RUN re-move-clmncli-list (16, 1).
END.
PROCEDURE re-move-clmncli-list:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvicli-list = 1 TO EXTENT(cur-clmn-numcli-list):
    if cur-clmn-numcli-list[varmvicli-list] = source-column THEN cur-clmn-numcli-list[varmvicli-list] = -1.
  END.
  if cli-list:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjcli-list = source-column - 1 to target-column BY -1:
    DO varmvicli-list = 1 TO EXTENT(cur-clmn-numcli-list):
        if cur-clmn-numcli-list[varmvicli-list] = varmvjcli-list THEN DO:
          cur-clmn-numcli-list[varmvicli-list] = cur-clmn-numcli-list[varmvicli-list] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjcli-list = source-column + 1 to target-column:
    DO varmvicli-list = 1 TO EXTENT(cur-clmn-numcli-list):
      if cur-clmn-numcli-list[varmvicli-list] = varmvjcli-list THEN DO:
        cur-clmn-numcli-list[varmvicli-list] = cur-clmn-numcli-list[varmvicli-list] - 1.
      END.
    END.
  END.
  DO varmvicli-list = 1 TO EXTENT(cur-clmn-numcli-list):
    if cur-clmn-numcli-list[varmvicli-list] = -1 THEN cur-clmn-numcli-list[varmvicli-list] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmncli-list:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvicli-list = 1 TO EXTENT(cur-clmn-numcli-list):
    if cur-clmn-numcli-list[varmvicli-list] = cur-clmn-loc THEN move-elementcli-list = varmvicli-list.
  END.
  RUN re-move-clmncli-list (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultcli-list:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlcli-list = 1 to EXTENT(cur-clmn-numcli-list):
    RUN re-move-clmncli-list (cur-clmn-numcli-list[varmvlcli-list], varmvlcli-list).
  END.
  RUN start-mv-clmncli-list.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  cli-list :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  cli-listA :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  cli-listB :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numcli-listA as INT EXTENT 16 no-undo.
DEF VAR varmvicli-listA       as INT no-undo.
DEF VAR varmvjcli-listA       as INT no-undo.
DEF VAR varmvkcli-listA       as INT no-undo.
DEF VAR varmvlcli-listA       as INT no-undo.
DEF VAR move-elementcli-listA as INT no-undo.
def var jjcli-listA           as int no-undo.
do varmvicli-listA = 1 to EXTENT(cur-clmn-numcli-listA):
  ASSIGN cur-clmn-numcli-listA[varmvicli-listA] = varmvicli-listA.
END.
RUN start-mv-clmncli-listA.
PROCEDURE start-mv-clmncli-listA:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE cli-listA do:
  RUN re-move-clmncli-listA ( 1, 16).
END.
ON ctrl-cursor-left OF BROWSE cli-listA do:
  RUN re-move-clmncli-listA (16, 1).
END.
PROCEDURE re-move-clmncli-listA:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvicli-listA = 1 TO EXTENT(cur-clmn-numcli-listA):
    if cur-clmn-numcli-listA[varmvicli-listA] = source-column THEN cur-clmn-numcli-listA[varmvicli-listA] = -1.
  END.
  if cli-listA:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjcli-listA = source-column - 1 to target-column BY -1:
    DO varmvicli-listA = 1 TO EXTENT(cur-clmn-numcli-listA):
        if cur-clmn-numcli-listA[varmvicli-listA] = varmvjcli-listA THEN DO:
          cur-clmn-numcli-listA[varmvicli-listA] = cur-clmn-numcli-listA[varmvicli-listA] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjcli-listA = source-column + 1 to target-column:
    DO varmvicli-listA = 1 TO EXTENT(cur-clmn-numcli-listA):
      if cur-clmn-numcli-listA[varmvicli-listA] = varmvjcli-listA THEN DO:
        cur-clmn-numcli-listA[varmvicli-listA] = cur-clmn-numcli-listA[varmvicli-listA] - 1.
      END.
    END.
  END.
  DO varmvicli-listA = 1 TO EXTENT(cur-clmn-numcli-listA):
    if cur-clmn-numcli-listA[varmvicli-listA] = -1 THEN cur-clmn-numcli-listA[varmvicli-listA] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmncli-listA:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvicli-listA = 1 TO EXTENT(cur-clmn-numcli-listA):
    if cur-clmn-numcli-listA[varmvicli-listA] = cur-clmn-loc THEN move-elementcli-listA = varmvicli-listA.
  END.
  RUN re-move-clmncli-listA (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultcli-listA:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlcli-listA = 1 to EXTENT(cur-clmn-numcli-listA):
    RUN re-move-clmncli-listA (cur-clmn-numcli-listA[varmvlcli-listA], varmvlcli-listA).
  END.
  RUN start-mv-clmncli-listA.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numcli-listB as INT EXTENT 16 no-undo.
DEF VAR varmvicli-listB       as INT no-undo.
DEF VAR varmvjcli-listB       as INT no-undo.
DEF VAR varmvkcli-listB       as INT no-undo.
DEF VAR varmvlcli-listB       as INT no-undo.
DEF VAR move-elementcli-listB as INT no-undo.
def var jjcli-listB           as int no-undo.
do varmvicli-listB = 1 to EXTENT(cur-clmn-numcli-listB):
  ASSIGN cur-clmn-numcli-listB[varmvicli-listB] = varmvicli-listB.
END.
RUN start-mv-clmncli-listB.
PROCEDURE start-mv-clmncli-listB:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE cli-listB do:
  RUN re-move-clmncli-listB ( 1, 16).
END.
ON ctrl-cursor-left OF BROWSE cli-listB do:
  RUN re-move-clmncli-listB (16, 1).
END.
PROCEDURE re-move-clmncli-listB:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvicli-listB = 1 TO EXTENT(cur-clmn-numcli-listB):
    if cur-clmn-numcli-listB[varmvicli-listB] = source-column THEN cur-clmn-numcli-listB[varmvicli-listB] = -1.
  END.
  if cli-listB:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjcli-listB = source-column - 1 to target-column BY -1:
    DO varmvicli-listB = 1 TO EXTENT(cur-clmn-numcli-listB):
        if cur-clmn-numcli-listB[varmvicli-listB] = varmvjcli-listB THEN DO:
          cur-clmn-numcli-listB[varmvicli-listB] = cur-clmn-numcli-listB[varmvicli-listB] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjcli-listB = source-column + 1 to target-column:
    DO varmvicli-listB = 1 TO EXTENT(cur-clmn-numcli-listB):
      if cur-clmn-numcli-listB[varmvicli-listB] = varmvjcli-listB THEN DO:
        cur-clmn-numcli-listB[varmvicli-listB] = cur-clmn-numcli-listB[varmvicli-listB] - 1.
      END.
    END.
  END.
  DO varmvicli-listB = 1 TO EXTENT(cur-clmn-numcli-listB):
    if cur-clmn-numcli-listB[varmvicli-listB] = -1 THEN cur-clmn-numcli-listB[varmvicli-listB] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmncli-listB:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvicli-listB = 1 TO EXTENT(cur-clmn-numcli-listB):
    if cur-clmn-numcli-listB[varmvicli-listB] = cur-clmn-loc THEN move-elementcli-listB = varmvicli-listB.
  END.
  RUN re-move-clmncli-listB (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultcli-listB:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlcli-listB = 1 to EXTENT(cur-clmn-numcli-listB):
    RUN re-move-clmncli-listB (cur-clmn-numcli-listB[varmvlcli-listB], varmvlcli-listB).
  END.
  RUN start-mv-clmncli-listB.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
  run reopen-query in this-procedure no-error.
    apply "VALUE-CHANGED" to CLi-List.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    run gbl/dftempl.p ( input "clients-attr":U, output template-recid) no-error.
    if error-status:error then dO:
      message
      vss-workfile vss-revision vss-description skip
      "Невозможно найти recid template записи в таблице clients-attr"
      view-as alert-box error .
      return error.
    end.
  assign
  filter-point0 = "cli-all"  + chr(4) + "Клиенты" + chr(4) + string(no)
  filter-point = filter-point0
  .
  v-rid-list = p-rid-list.
  FIND FIRST ub.sys-ctrl No-LOCK no-error.
  FIND FIRST ub.db WHERE ub.db.db-num = ub.sys-ctrl.db-num NO-LOCK .
  if lookup(c-other, "s-deploy":U, ";":U) > 0
  or lookup(c-other, "news":U, ";":U) > 0
  then do:
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  end.
  else do:
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  end.
  RUN StartProc  in this-procedure ( input 1).
  RUN Myenable.
  RUN StartProc  in this-procedure ( input 2).
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE br-mouse-select :
if b-sel:sensitive in frame Dialog-Frame then
  if b-mark:sensitive then
      apply "choose" to b-mark in frame Dialog-Frame.
  else
      apply "choose" to b-sel in frame Dialog-Frame.
  else
  if b-lkp:sensitive then
      apply "choose" to b-lkp in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE br-return :
    if b-sel:sensitive in frame Dialog-Frame then
        apply "choose" to b-sel in frame Dialog-Frame.
    else
        if b-lkp:sensitive then
            apply "choose" to b-lkp in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY Find-by NameOrCode All-Or-Group Cli-Types Cli-Status mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-bank B-docs Goods-by-prod b-dc b-zak b-sert
         B-attr b-hist b-print B-sch B-Help RECT-status RECT-types
         RECT-All-or-Group B-add B-add-prs B-lkp b-chg b-del B-price-type
         B-cont B-grp B-edi B-photo Find-by NameOrCode CLi-ListB CLi-ListA
         CLi-List All-Or-Group Del-Filters Cli-Types Cli-Status mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE gdsbypr :
DEFINE INPUT PARAMETER rc as recid.
DEFINE INPUT PARAMETER calling as character.
define variable v-ri-list as character no-undo .
DEFINE VARIABLE v-output as character no-undo.
define variable v-input-output as character no-undo .
define variable v-from-date as date no-undo .
define variable v-to-date as date no-undo .
define variable glog as logical no-undo .
define buffer g-producer for ub.clients.
CASE calling:
  WHEN "Товары по производителю" THEN  do:
    if not X_clients.is-prod then do:
        message "Клиент не является производителем!" view-as alert-box WARNING.
        return error.
    end.
    FIND g-producer WHERE recid( g-producer ) = rc no-lock .
    run ref/gds-ref.p (
                   input  parparentproc
                  ,input  ""
                  ,input 'все':U
                  ,input 'Производитель':U
                  ,input 'все':U
                  ,input ?
                  ,input ?
                  ,input g-producer.obj-type
                  ,input g-producer.obj-code
                  ,input ?
                  ,input ?
                  ,input ?
                  ,output v-ri-list ).
  end.
  WHEN "Остатки по поставщику (партии)" THEN DO:
    if not (X_clients.sup-gds OR X_clients.sup-cons) then do:
          message "Клиент не является поставщиком!" view-as alert-box WARNING.
          return error.
    end.
    run rep/supp-gds.w (
                          input parparentproc
                        ,input v-cntxt-obj-type
                        ,input v-cntxt-obj-code
                        ,input "stock"
                        ,input "current"
                        ,input X_clients.obj-type
                        ,input X_clients.obj-code).
  END.
  WHEN "Остатки по поставщику (товары)" THEN DO:
    if not (X_clients.sup-gds OR X_clients.sup-cons) then do:
      message "Клиент не является поставщиком!"
      view-as alert-box WARNING.
      return error.
    end.
    run ref/cli-gdss.w (
                    input parparentproc
                   ,input 'Контрагент,Остатки':U
                   ,input ?
                   ,input rc
                   ) .
  END.
  WHEN "Обороты по поставщику (партии)" THEN DO:
    if not (X_clients.sup-gds OR X_clients.sup-cons) then do:
      message
      "Клиент не является поставщиком!"
      view-as alert-box WARNING.
      return error.
    end.
    run gbl/get-per.w ( output glog, input-output v-from-date, input-output v-to-date) .
    if not glog then return.
    run ref/vspartsr.p (
                    input parparentproc
                   ,input v-cntxt-obj-type
                   ,input v-cntxt-obj-code
                   ,input v-from-date
                   ,input v-to-date
                   ,input 'все':U
                   ,input '':U
                   ,input recid(X_clients)
                   ) no-error .
  END.
  WHEN "Обороты по поставщику (товары)" THEN DO:
    if not (X_clients.sup-gds OR X_clients.sup-cons) then do:
      message
      "Клиент не является поставщиком!"
      view-as alert-box WARNING.
      return error.
    end.
    assign
    v-from-date = ?
    v-to-date = ?
    .
    run gbl/get-per.w ( output glog, input-output v-from-date, input-output v-to-date) .
    if not glog then return.
    run rep/v-suppl.w (
                   input parparentproc
                  ,input v-cntxt-obj-type
                  ,input v-cntxt-obj-code
                  ,input v-from-date
                  ,input v-to-date
                  ,input string(rc)
                  ).
  END.
  WHEN "Обороты по контрагенту" THEN DO:
    run ref/cli-gdss.w (
                    input parparentproc
                   ,input 'Контрагент,Обороты':U
                   ,input ?
                   ,input rc
                   ).
  END.
END CASE.
END PROCEDURE.
PROCEDURE lkp-rec :
  define parameter buffer bp-clients for ub.clients.
  if not available bp-clients THEN do:
    return.
  end.
  run ref/showcli.p (
     input parParentProc
    ,input bp-clients.obj-type
    ,input bp-clients.obj-code
    ).
END PROCEDURE.
PROCEDURE MyEnable :
ASSIGN  Cli-List:MAX-DATA-GUESS IN FRAME Dialog-Frame     = 200.
ASSIGN  Cli-ListA:MAX-DATA-GUESS IN FRAME Dialog-Frame     = 200.
ASSIGN  Cli-ListB:MAX-DATA-GUESS IN FRAME Dialog-Frame     = 200.
ASSIGN
Goods-By-Prod:MENU-MOUSE = 1
b-attr:MENU-MOUSE in frame Dialog-Frame = 1
b-sert:MENU-MOUSE in frame Dialog-Frame = 1
.
assign
var-cli-name:resizable in browse cli-list = true
var-cli-name:width in browse cli-list = v-obj-name-width
X_clients.grp-name:resizable in browse cli-list = true
X_clients.grp-name:width in browse cli-list = v-grp-name-width
var-cli-name:resizable in browse cli-lista = true
var-cli-name:width in browse cli-lista = v-obj-name-width
X_clients.grp-name:resizable in browse cli-lista = true
X_clients.grp-name:width in browse cli-lista = v-grp-name-width
var-cli-name:resizable in browse cli-listb = true
var-cli-name:width in browse cli-listb = v-obj-name-width
X_clients.grp-name:resizable in browse cli-listb = true
X_clients.grp-name:width in browse cli-listb = v-grp-name-width
.
assign
All-Or-Group:radio-buttons =  "Все" + chr(44) + 'все':U + chr(44) +
                              'группа':U + chr(44) + 'группа':U + chr(44) +
                              "Привязка" + chr(44) + 'АТР':U
cli-status:radio-buttons = "Текущие&+ " + chr(44) + 'текущие':U + chr(44) + "Все&!" + chr(44) + 'все':U + chr(44) +
                           "Удаленные&-" + chr(44) + 'удаленные':U
CLi-types:Radio-buttons = "Вс&е" + chr(44) + 'все':U + chr(44) + "&Орг" + chr(44) + 'орг':U + chr(44) +
                          "Фи&з.лица" + chr(44) + 'чел':U + chr(44) +
                          "Об&ъ" + chr(44) + 'объект':U + chr(44) +
                          "Скл&" + chr(44) + 'скл':U + chr(44) +
                          "&Маг" + chr(44) + 'маг':U + chr(44) +
                          "&БД"  + chr(44) + "db"
FInd-By:radio-buttons = "Все" + chr(44) + 'все':U + chr(44) + "Название" + chr(44) + 'название':U + chr(44) +
                         "Код" + chr(44) + 'код':U + chr(44) + "ИНН" + chr(44) + "ИНН"
cli-listA:row = cli-list:row
cli-listA:column = cli-list:column
cli-listb:row = cli-list:row
cli-listb:column = cli-list:column
.
DISPLAY Find-by NameOrCode All-Or-Group Cli-Types Cli-Status mark-num
WITH FRAME Dialog-Frame .
if v-is-news then do:
  disable
  all
  with frame Dialog-Frame .
end.
ENABLE
b-quit RECT-status RECT-All-or-Group RECT-types B-sel
B-Help
Find-by NameOrCode
CLi-List Cli-Types Cli-Status
mark-num
WITH FRAME Dialog-Frame .
if not v-is-news then do:
  ENABLE
  b-mark
  b-hist B-bank b-cont B-docs Goods-by-prod b-dc b-zak B-photo b-sch
  B-add B-add-prs B-grp b-chg B-lkp b-del b-print b-sert B-attr b-edi
  b-price-type
  CLi-ListA CLi-ListB All-Or-Group
  WITH FRAME Dialog-Frame .
end.
VIEW FRAME Dialog-Frame .
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define input  parameter p-needmes as logical no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
define variable v-doc-rec as recid no-undo .
nameorcode = prep-nameorcode ( nameorcode).
title0 = "Список клиентов" + chr(32).
HIDE
CLi-ListA in frame Dialog-Frame
CLi-ListB in frame Dialog-Frame.
DISPLAY
CLi-LIST
with frame Dialog-Frame.
if var-prev-br-name <> var-br-name then do:
  CASE var-prev-br-name:
    when '':U then do:
    end.
    when "cli-list" then do:
       close query cli-list.
    end.
    when "cli-lista" then do:
       close query cli-lista.
    end.
    when "cli-listb" then do:
       close query cli-listb.
    end.
  end case.
end.
entry(1, filter-point, chr(4))  = entry(1, filter-point0 , chr(4)) + cli-types.
entry(2, filter-point, chr(4))  = entry(2, filter-point0 , chr(4)) + cli-types.
define variable log-res as logical no-undo.
RUn Switch-Buttons in this-procedure ( input p-needmes) No-ERROR.
if v-is-prod then do :
  show-as = 'про':U + left-trim(show-as,entry(1,show-as,"-")) .
end.
if show-as begins ('про':U + "-" + 'все':U) then do:
   run ref/cli-all1.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input false      ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) . .
end.
if show-as begins ('про':U + "-" + 'название':U) then do:
   run ref/cli-all2.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input false      ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) . .
end.
if show-as begins ('все':U + "-" + 'все':U) then do:
  run ref/cli-all3.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input false      ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
end.
if show-as begins ('все':U + "-" + 'название':U) then do:
  run ref/cli-all4.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input false      ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
end.
if show-as begins ("db" + "-") then do:
  if find-by = 'все':U then do:
    run ref/cli-allm.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input false      ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
  end.
  else do:
    run ref/cli-alln.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input false      ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
  end.
end.
if show-as begins ('объект':U + "-") then do:
  if find-by = 'все':U then do:
    run ref/cli-allc.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input false      ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
  end.
  else do:
    run ref/cli-alld.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input false      ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
  end.
end.
else do:
  if (Cli-Types <> 'все':U
  and cli-types <> "db"
     )
  and find-by = 'все':U then do:
    run ref/cli-all5.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input false      ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
  end.
  if (Cli-Types <> 'все':U
  and cli-types <> "db"
      )
  AND find-by = 'название':U  then do:
    run ref/cli-all6.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input false      ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
  end.
end.
if p-NeedMes then  run waitfram-hide in this-procedure .
if session :set-wait-state( "compiler" ) then.
HIDE
CLi-ListA in frame Dialog-Frame
CLi-ListB in frame Dialog-Frame.
assign
var-cli-name:width in browse cli-list = var-cli-name:width in browse cli-lista
X_clients.grp-name:width in browse cli-list = X_clients.grp-name:width in browse cli-lista
.
DISPLAY
CLi-LIST
with frame Dialog-Frame.
run diasize_restore-orig-size in this-procedure .
run diasize_set-browse-handle in this-procedure
  (input browse CLi-list :handle
  ) .
run diasize_restore-current-size in this-procedure .
run set-filter-name in this-procedure (INPUT v-filter-name) no-error .
if num-results( "Cli-List" ) <> 0 then do:
    if c-recid <> ? then do:
       if not p-open-query
       or v-start
       then
       reposition Cli-List to recid( c-recid ) no-error .
    end.
    else do:
       if not p-open-query
       or v-start
       then
       reposition Cli-List to row 1 no-error .
       log-res = Cli-List:select-row( 1 ) in frame Dialog-Frame .
    end.
    v-start = no.
end.
APPLY "VALUE-CHANGED" TO CLi-ListA  in frame Dialog-Frame.
apply "entry" to Cli-List in frame Dialog-Frame .
if session :set-wait-state( "" ) then.
END PROCEDURE.
PROCEDURE OpenBrA :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define input  parameter p-needmes as logical no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
define variable v-doc-rec as recid no-undo .
title0 = "Список клиентов" + chr(32).
nameorcode = prep-nameorcode ( nameorcode).
if var-prev-br-name <> var-br-name then do:
  CASE var-prev-br-name:
    when '':U then do:
    end.
    when "cli-list" then do:
       close query cli-list.
    end.
    when "cli-lista" then do:
       close query cli-lista.
    end.
    when "cli-listb" then do:
       close query cli-listb.
    end.
  end case.
end.
define variable log-res as logical no-undo.
RUn Switch-Buttons in this-procedure (  input p-needmes) No-ERROR.
if p-NeedMes then  run waitfram-hide in this-procedure .
if v-is-prod then do :
  show-as = 'про':U + left-trim(show-as,entry(1,show-as,"-")) .
end.
if show-as begins 'про':U then do:
   run ref/cli-all7.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input false     ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
   .
end.
else do:
   if show-as begins 'все':U then do:
     run ref/cli-all9.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input false     ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
   end.
   else do:
     CASE entry(1, show-as, "-"):
       when 'объект':U then do:
          run ref/cli-alle.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input false     ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
       end.
       when "db":U then do:
          run ref/cli-allo.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input false     ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
       end.
       otherwise do:
         run ref/cli-allb.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input false     ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
       end.
     end CASE.
   end.
end.
if session :set-wait-state( "compiler" ) then.
HIDE
CLi-list in frame Dialog-Frame
CLi-listB
in frame Dialog-Frame.
assign
var-cli-name:width in browse cli-lista = var-cli-name:width in browse cli-list
X_clients.grp-name:width in browse cli-lista = X_clients.grp-name:width in browse cli-list
.
DISPLAY
CLi-listA
with frame Dialog-Frame.
run diasize_restore-orig-size in this-procedure .
run diasize_set-browse-handle in this-procedure
  (input browse CLi-listA :handle
  ) .
run diasize_restore-current-size in this-procedure .
run set-filter-name in this-procedure (INPUT v-filter-name) no-error .
if num-results( "Cli-ListA" ) <> 0 then do:
    if c-recid <> ? then do:
       if not p-open-query
       or v-start
       then
       reposition CLi-listA to recid( c-recid ) no-error .
    end.
    else do:
       if not p-open-query or
       v-start
       then
       reposition CLi-listA to row 1 no-error .
       log-res = CLi-listA:select-row( 1 ) in frame Dialog-Frame .
    end.
    v-start = no.
end.
APPLY "VALUE-CHANGED" TO CLi-ListA  in frame Dialog-Frame.
apply "entry" to CLi-listA in frame Dialog-Frame .
if session :set-wait-state( "" ) then.
END PROCEDURE.
PROCEDURE OpenBrB :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define input  parameter p-needmes as logical no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
define variable v-doc-rec as recid no-undo .
title0 = "Список Покупателей" + chr(32).
nameorcode = prep-nameorcode ( nameorcode).
if var-prev-br-name <> var-br-name then do:
  CASE var-prev-br-name:
    when '':U then do:
    end.
    when "cli-list" then do:
       close query cli-list.
    end.
    when "cli-lista" then do:
       close query cli-lista.
    end.
    when "cli-listb" then do:
       close query cli-listb.
    end.
  end case.
end.
define variable log-res as logical no-undo.
RUn Switch-Buttons in this-procedure(  input p-needmes) No-ERROR.
if p-NeedMes then  run waitfram-hide in this-procedure .
if v-is-prod then do :
  show-as = 'про':U + left-trim(show-as,entry(1,show-as,"-")) .
end.
if show-as begins ('про':U + "-" + 'все':U) then do:
   run ref/cli-allh.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input true     ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
end.
if show-as begins ('про':U + "-" + 'название':U) then do:
   run ref/cli-allk.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input true     ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
end.
if show-as begins ('все':U + "-" + 'все':U) then do:
  run ref/cli-alla.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input true     ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
end.
if show-as begins ('все':U + "-" + 'название':U) then do:
  run ref/cli-allj.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input true     ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
end.
if show-as begins ("db" + "-") then do:
  if find-by = 'все':U then do:
    run ref/cli-allp.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input true     ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
  end.
  else do:
    run ref/cli-allr.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input true     ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
  end.
end.
if show-as begins ('объект':U + "-") then do:
  if find-by = 'все':U then do:
    run ref/cli-alli.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input true     ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
  end.
  else do:
    run ref/cli-alls.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input true     ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
  end.
end.
else do:
  if (Cli-Types <> 'все':U
  and Cli-Types <> "db"
  )
  and find-by = 'все':U then do:
    run ref/cli-allf.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input true     ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
  end.
  if (Cli-Types <> 'все':U
  and Cli-Types <> "db"
  )
  AND find-by = 'название':U  then do:
    run ref/cli-allg.p (input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input attr-option_ ,  input show-as ,  input JoinType ,  input Cli-Types ,  input Curr-Grp-Name ,  input NameOrCode ,  input SupGds     ,  input SupCons    ,  input SupServ    ,  input BuyGds     ,  input BuyCons    ,  input BuyServ    ,  input WLim-kr    ,  input true     ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
  end.
end.
if session :set-wait-state( "compiler" ) then.
HIDE
CLi-list in frame Dialog-Frame
CLi-listA
in frame Dialog-Frame.
assign
var-cli-name:width in browse cli-listb = var-cli-name:width in browse cli-list
X_clients.grp-name:width in browse cli-listb = X_clients.grp-name:width in browse cli-list
.
DISPLAY
CLi-listb
with frame Dialog-Frame.
run diasize_restore-orig-size in this-procedure .
run diasize_set-browse-handle in this-procedure
  (input browse CLi-listb :handle
  ) .
run diasize_restore-current-size in this-procedure .
run set-filter-name in this-procedure ( INPUT v-filter-name) no-error .
if num-results( "Cli-Listb" ) <> 0 then do:
    if c-recid <> ? then do:
       if not p-open-query then
       reposition CLi-listb to recid( c-recid ) no-error .
    end.
    else do:
       if not p-open-query then
       reposition CLi-listb to row 1 no-error .
       log-res = CLi-listb:select-row( 1 ) in frame Dialog-Frame .
    end.
end.
APPLY "VALUE-CHANGED" TO CLi-Listb  in frame Dialog-Frame.
apply "entry" to CLi-listb in frame Dialog-Frame .
if session :set-wait-state( "" ) then.
END PROCEDURE.
PROCEDURE proc-b-add :
define input parameter p-is-firm as logical no-undo.
DEFINE VARIABLE ri          as      recid   no-undo     init ? .
DEFINE VARIABLE to-grp      like  ub.cli-grp.node-code     no-undo .
define variable g-grp as character no-undo .
define buffer b-cli-grp for ub.cli-grp.
assign
Find-By:screen-value in frame Dialog-Frame = 'все':U  .
apply "value-changed" to Find-By in frame Dialog-Frame .
CASE p-is-firm :
    when yes
    then do:
define variable vss-include-info41 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_client-reference_add-del':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
    end.
    when no
    then do:
define variable vss-include-info42 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_client-reference-prs_add-del':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
    end.
END CASE.
if not g#log then return error.
g-grp = "".
run ref/cli-grps.w (
                   input parparentproc
                  ,input "b-sel":U
                  ,input-output g-grp ) .
if g-grp <> "" then do:
  FIND ub.cli-grp where recid( ub.cli-grp ) = integer( g-grp ) .
  if can-find( FIRST b-cli-grp where b-cli-grp.upper-code = ub.cli-grp.node-code ) then do:
    message "Добавлять можно только в группы," skip
            "у которых нет подгрупп." skip
            "Выбирайте другую группу !"
    view-as alert-box WARNING .
    return no-apply .
  end.
  to-grp = ub.cli-grp.node-code .
  if p-is-firm then
      run ref/firmi.w (
                  input parParentProc
                 ,input ('ДОБАВЛЕНИЕ':U + (if v-s-deploy then (";":U + "s-deploy":U) else "":U))
                 ,input 0
                 ,input to-grp
                 ,input "cli-all"
                 ,input-output ri ) .
  else
      run ref/personi.w (
                    input parParentProc
                   ,input 'ДОБАВЛЕНИЕ':U
                   ,input 0
                   ,input to-grp
                   ,input "cli-all"
                   ,input-output ri ) .
  if ri <> ? then do:
    if find-by <> 'все':U then do:
      apply "RETURN" to Nameorcode.
    end.
    else do:
      case var-br-name :         when "cli-list":U then do:            Run OpenBR in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         when "cli-listA":U then do:            Run OpenBRA in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         when "cli-listB":U then do:            Run OpenBRB in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         end case.
      case var-br-name :         when "cli-list":U then do:            reposition Cli-List to recid ri no-error .         end.         when "cli-listA":U then do:            reposition Cli-ListA to recid ri no-error .         end.         when "cli-listB":U then do:            reposition Cli-ListB to recid ri no-error .          end.         end case.
      if error-status:error then do:
        find first pos_clients no-lock where       recid( pos_clients ) = ri no-error .   message  substitute("Невозможно позиционироваться на клиенте &1&2Клиент был добавлен (или изменен или удален)&2и теперь не попадает в текущую выборку"             ,(if available pos_clients then (pos_clients.obj-type + string(pos_clients.obj-code)) else '':U)              , chr(10)) view-as alert-box WARNING.
      end.
      case var-br-name :         when "cli-list":U then do:            apply "entry" to Cli-List in frame Dialog-Frame.         end.         when "cli-listA":U then do:            apply "entry" to Cli-ListA in frame Dialog-Frame.         end.         when "cli-listB":U then do:            apply "entry" to Cli-ListB in frame Dialog-Frame.         end.         end case.
    end.
  end.
end.
else do:
  case var-br-name :         when "cli-list":U then do:            apply "entry" to Cli-List in frame Dialog-Frame.         end.         when "cli-listA":U then do:            apply "entry" to Cli-ListA in frame Dialog-Frame.         end.         when "cli-listB":U then do:            apply "entry" to Cli-ListB in frame Dialog-Frame.         end.         end case.
  return no-apply.
end.
END PROCEDURE.
PROCEDURE proc-b-print :
define variable sym1 as char init ":"   no-undo.
define variable sym2 as char init ":"   no-undo.
define variable sym3 as char init ":"   no-undo.
define variable sym4 as char init ":"   no-undo.
define variable sym5 as char init ":"   no-undo.
define variable Line                as char         no-undo.
define variable CurrGroupName as char        no-undo.
define variable ii      as integer   no-undo.
define variable ri      as recid   no-undo.
DEFINE FRAME List
sym1 column-label ":" format "x(1)"
X_clients.obj-name column-label "Наименование" format "x(59)"
sym2 column-label ":" format "x(1)"
X_clients.obj-type column-label "Тип" format "x(8)"
sym3 column-label ":" format "x(1)"
X_clients.obj-code column-label "Код" format ">>>>>>>>>9"
sym4 column-label ":" format "x(1)"
X_clients.PS column-label "Примечание" format "x(40)"
sym5 column-label ":" format "x(1)"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>9") )
AT 86 format "X(15)" SKIP
Line format "x(130)" AT 1
with width 235 down use-text stream-io no-box .
if num-results( var-br-name ) = 0 then do:
  message "Список  П У С Т !" skip view-as alert-box information .
  return no-apply .
end.
define variable vss-include-info43 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference-lists_print':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g#log
    )  .
end.
if not g#log then do:
    message
    "У Вас недостаточно прав для" skip
    "выполнения данного действия." skip
    "Обратитесь к администратору" skip
    "системы."
    view-as alert-box error title "Недостаточно прав !".
  return error .
end.
Line = fill( "-" , 140 ) .
assign frame Dialog-Frame
All-Or-Group Cli-Types Cli-Status .
run waitfram-show in this-procedure ( 'Подождите ...' ) .
ri = recid( X_clients ) .
case var-br-name :
when  "cli-list":U then do:
  DO WHILE available X_clients :
      GET prev Cli-List NO-LOCK .
  END.
  GET next Cli-List NO-LOCK .
end.
when "cli-listA":U then  do:
  DO WHILE available X_clients :
      GET prev Cli-ListA NO-LOCK .
  END.
  GET next Cli-ListA NO-LOCK .
end.
when "cli-listB":U then  do:
  DO WHILE available X_clients :
      GET prev Cli-ListB NO-LOCK .
  END.
  GET next Cli-ListB NO-LOCK .
end.
end case.
ii = 1 .
if All-Or-Group = 'группа':U then
CurrGroupName = X_clients.grp-name .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
FORM HEADER
Line format "X(130)" SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME CliBottomFrame width 160 PAGE-BOTTOM NO-LABELS no-box.
VIEW stream PrnLibStream FRAME CliBottomFrame .
PUT stream PrnLibStream space(30)
"С П И С О К   К Л И Е Н Т О В" format "X(100)" SKIP(2) .
FORM with frame List .
DO WHILE available X_clients :
    DISPLAY stream PrnLibStream
    sym1 X_clients.obj-name sym2 X_clients.obj-type
    sym3 X_clients.obj-code sym4 X_clients.PS sym5
    with frame List .
    DOWN stream PrnLibStream 1 with frame List .
    ii =  ii + 1 .
    if ( ( ii modulo 10 ) = 0 ) AND ( ii >= 10 ) then
    run waitfram-show in this-procedure ( input ("Просмотрено строк : " + string( ii )) ) .
    if var-br-name = "cli-list":U then do:
        GET next Cli-List .
    end.
    else do:
        GET next Cli-ListA .
    end.
END.
run waitfram-hide in this-procedure .
PUT stream PrnLibStream Line format "X(130)" SKIP.
HIDE stream PrnLibStream FRAME CliBottomFrame .
output stream PrnLibStream close .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).
case var-br-name :         when "cli-list":U then do:            reposition Cli-List to recid ri no-error .         end.         when "cli-listA":U then do:            reposition Cli-ListA to recid ri no-error .         end.         when "cli-listB":U then do:            reposition Cli-ListB to recid ri no-error .          end.         end case.
if error-status:error then do:
      find first pos_clients no-lock where       recid( pos_clients ) = ri no-error .   message  substitute("Невозможно позиционироваться на клиенте &1&2Клиент был добавлен (или изменен или удален)&2и теперь не попадает в текущую выборку"             ,(if available pos_clients then (pos_clients.obj-type + string(pos_clients.obj-code)) else '':U)              , chr(10)) view-as alert-box WARNING.
end.
case var-br-name :         when "cli-list":U then do:            Run OpenBR in this-procedure (yes, no, ' ':U, no) no-error  .         end.         when "cli-listA":U then do:            Run OpenBRA in this-procedure (yes, no, ' ':U, no) no-error  .         end.         when "cli-listB":U then do:            Run OpenBRB in this-procedure (yes, no, ' ':U, no) no-error  .         end.         end case.
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
  tbl = 'clients'
  join-tbl = 'X_clients'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('obj-type*obj-code', 'Клиент', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-name', 'Название', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-prod', 'Пр-ль', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sup-gds', 'Пост-к/т', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sup-cons', 'Пост-к/к', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('buy-gds', 'Пок-ль/т', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('buy-cons', 'Пок-ль/к', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('buy-serv', 'Пок-ль/у', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('db-num', 'БД', 'db',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', 'Своя фирма', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('grp-name', '', 'cligrp',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('PS', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  if var-br-name = "" or var-br-name = ? then do:
    var-prev-br-name = var-br-name.
    var-br-name = "cli-list"  .
  end.
  case var-br-name :         when "cli-list":U then do:            Run OpenBR in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         when "cli-listA":U then do:            Run OpenBRA in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         when "cli-listB":U then do:            Run OpenBRB in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         end case.
END.
END PROCEDURE.
PROCEDURE proc-find :
define input parameter cli-code like ub.clients.obj-code no-undo.
define output parameter par-recid as recid no-undo.
define buffer b-cli for ub.clients.
CASE Cli-Types :
  when 'все':U then do:
    CASE JoinType :
      when "Или" then do:
         FIND FIRST b-cli WHERE
               b-cli.obj-code = cli-code AND
               ( if Cli-Status = 'текущие':U
                  then b-cli.stts = 0
                  else if Cli-Status = 'удаленные':U
                     then b-cli.stts <> 0
                     else TRUE ) AND
               ( if All-Or-Group = 'группа':U
               then b-cli.grp-name begins Curr-Grp-Name
               else TRUE ) AND
(
  ( if SupGds = yes AND b-cli.sup-gds = yes     then yes else no ) OR
  ( if SupCons = yes AND b-cli.sup-cons = yes     then yes else no ) OR
  ( if SupServ = yes AND b-cli.sup-serv = yes     then yes else no ) OR
  ( if BuyGds = yes AND b-cli.buy-gds = yes     then yes else no ) OR
  ( if BuyCons = yes AND b-cli.buy-cons = yes     then yes else no ) OR
  ( if BuyServ = yes AND b-cli.buy-serv = yes     then yes else no ) OR
  ( if WLim-kr = yes AND b-cli.lim-kr <> 0    then yes else no )
)
    NO-LOCK no-error .
      end.
      when "NO" then do:
        FIND FIRST b-cli WHERE
               b-cli.obj-code = cli-code AND
               ( if Cli-Status = 'текущие':U
                  then b-cli.stts = 0
                  else if Cli-Status = 'удаленные':U then b-cli.stts <> 0 else TRUE ) AND
               (if All-Or-Group = 'группа':U
                  then b-cli.grp-name begins Curr-Grp-Name
                  else TRUE )
         NO-LOCK no-error.
      end.
    END CASE .
  end.
  otherwise do:
    CASE JoinType :
      when "Или" then do:
         FIND FIRST b-cli WHERE
               (cli-types = 'объект':U or b-cli.obj-type = Cli-Types) AND
               b-cli.obj-code = cli-code AND
               ( if Cli-Status = 'текущие':U
                  then b-cli.stts = 0
                  else if Cli-Status = 'удаленные':U then b-cli.stts <> 0 else TRUE ) AND
               ( if All-Or-Group = 'группа':U
                  then b-cli.grp-name begins Curr-Grp-Name
                  else TRUE ) AND
(
  ( if SupGds = yes AND b-cli.sup-gds = yes     then yes else no ) OR
  ( if SupCons = yes AND b-cli.sup-cons = yes     then yes else no ) OR
  ( if SupServ = yes AND b-cli.sup-serv = yes     then yes else no ) OR
  ( if BuyGds = yes AND b-cli.buy-gds = yes     then yes else no ) OR
  ( if BuyCons = yes AND b-cli.buy-cons = yes     then yes else no ) OR
  ( if BuyServ = yes AND b-cli.buy-serv = yes     then yes else no ) OR
  ( if WLim-kr = yes AND b-cli.lim-kr <> 0    then yes else no )
)
         NO-LOCK no-error.
      end.
      when "NO" then do:
         FIND FIRST b-cli WHERE
            (cli-types = 'объект':U or b-cli.obj-type = Cli-Types) AND
            b-cli.obj-code = cli-code AND
            ( if Cli-Status = 'текущие':U
               then b-cli.stts = 0
               else if Cli-Status = 'удаленные':U then b-cli.stts <> 0 else TRUE ) AND
            ( if All-Or-Group = 'группа':U
               then b-cli.grp-name begins Curr-Grp-Name
               else TRUE )
         NO-LOCK no-error.
      end.
    END CASE .
  end.
END CASE .
if available b-cli then par-recid = recid(b-cli).
END PROCEDURE.
PROCEDURE proc-findA :
define input parameter cli-code like ub.clients.obj-code no-undo.
define output parameter par-recid as recid no-undo.
define buffer b-cli for ub.clients.
CASE Cli-Types :
  when 'все':U then do:
    CASE JoinType :
      when "Или" then do:
         _ff1:
         FOR EACH b-cli WHERE
               b-cli.obj-code = cli-code AND
               ( if Cli-Status = 'текущие':U
                  then b-cli.stts = 0
                  else if Cli-Status = 'удаленные':U
                     then b-cli.stts <> 0
                     else TRUE ) AND
               ( if All-Or-Group = 'группа':U
               then b-cli.grp-name begins Curr-Grp-Name
               else TRUE ) AND
(
  ( if SupGds = yes AND b-cli.sup-gds = yes     then yes else no ) OR
  ( if SupCons = yes AND b-cli.sup-cons = yes     then yes else no ) OR
  ( if SupServ = yes AND b-cli.sup-serv = yes     then yes else no ) OR
  ( if BuyGds = yes AND b-cli.buy-gds = yes     then yes else no ) OR
  ( if BuyCons = yes AND b-cli.buy-cons = yes     then yes else no ) OR
  ( if BuyServ = yes AND b-cli.buy-serv = yes     then yes else no ) OR
  ( if WLim-kr = yes AND b-cli.lim-kr <> 0    then yes else no )
)
         NO-LOCK:
            IF CAN-FIND(first clients-attr No-LOCK WHERE
                              clients-attr.obj-type = b-cli.obj-type AND
                              clients-attr.obj-code = b-cli.obj-code AND
                              clients-attr.attr-code = attr-option_) then LEAVE _ff1.
        end.
      end.
      when "NO" then do:
        _ff2:
        FOR EACH b-cli WHERE
               b-cli.obj-code = cli-code AND
               ( if Cli-Status = 'текущие':U
                  then b-cli.stts = 0
                  else if Cli-Status = 'удаленные':U then b-cli.stts <> 0 else TRUE ) AND
               (if All-Or-Group = 'группа':U
                  then b-cli.grp-name begins Curr-Grp-Name
                  else TRUE )
        NO-LOCK:
          IF CAN-FIND(first clients-attr No-LOCK WHERE
                           clients-attr.obj-type = b-cli.obj-type AND
                           clients-attr.obj-code = b-cli.obj-code AND
                           clients-attr.attr-code = attr-option_) then LEAVE _ff2.
        END.
      end.
      END CASE .
   end.
   otherwise do:
     CASE JoinType :
       when "Или" then do:
         _ff5:
         FOR EACH b-cli WHERE
               b-cli.obj-type = Cli-Types AND
               b-cli.obj-code = cli-code AND
               ( if Cli-Status = 'текущие':U
                  then b-cli.stts = 0
                  else if Cli-Status = 'удаленные':U then b-cli.stts <> 0 else TRUE ) AND
               ( if All-Or-Group = 'группа':U
                  then b-cli.grp-name begins Curr-Grp-Name
                  else TRUE ) AND
(
  ( if SupGds = yes AND b-cli.sup-gds = yes     then yes else no ) OR
  ( if SupCons = yes AND b-cli.sup-cons = yes     then yes else no ) OR
  ( if SupServ = yes AND b-cli.sup-serv = yes     then yes else no ) OR
  ( if BuyGds = yes AND b-cli.buy-gds = yes     then yes else no ) OR
  ( if BuyCons = yes AND b-cli.buy-cons = yes     then yes else no ) OR
  ( if BuyServ = yes AND b-cli.buy-serv = yes     then yes else no ) OR
  ( if WLim-kr = yes AND b-cli.lim-kr <> 0    then yes else no )
)
         NO-LOCK:
            IF CAN-FIND(first clients-attr No-LOCK WHERE
                              clients-attr.obj-type = b-cli.obj-type AND
                              clients-attr.obj-code = b-cli.obj-code AND
                              clients-attr.attr-code = attr-option_) then LEAVE _ff5.
         END.
       end.
       when "NO" then do:
         _ff6:
         FOR b-cli WHERE
            b-cli.obj-type = Cli-Types AND
            b-cli.obj-code = cli-code AND
            ( if Cli-Status = 'текущие':U
               then b-cli.stts = 0
               else if Cli-Status = 'удаленные':U then b-cli.stts <> 0 else TRUE ) AND
            ( if All-Or-Group = 'группа':U
               then b-cli.grp-name begins Curr-Grp-Name
               else TRUE )
         NO-LOCK:
            IF CAN-FIND(first clients-attr No-LOCK WHERE
                              clients-attr.obj-type = b-cli.obj-type AND
                              clients-attr.obj-code = b-cli.obj-code AND
                              clients-attr.attr-code = attr-option_) then LEAVE _ff6.
         END.
       end.
     END CASE .
  end.
END CASE .
if available b-cli then par-recid = recid(b-cli).
END PROCEDURE.
PROCEDURE proc-return-nameorcode :
  do
  on error undo, return error
  :
    define variable cli-code like ub.clients.obj-code no-undo.
    define variable cli-name like ub.clients.obj-name no-undo.
    define variable ri as recid no-undo.
    assign
    frame Dialog-Frame All-Or-Group
    Cli-Status Cli-Types Find-By NameOrCode
    .
    if NameOrCode = "" then
        return no-apply .
    if can-do( 'код':U , Find-By ) then  do:
      assign
      cli-code = integer( trim( NameOrCode ) ) no-error
      .
      if error-status:error then do:
        message
        "Неверный код" skip
        "Введите цифровой код клиента длиной до 9 знаков включительно"
        view-as alert-box error .
        return error .
      end.
      if var-br-name = "cli-list" then do:
        run proc-find in this-procedure ( input cli-code, output ri) no-error.
      end.
      else do:
        run proc-findA in this-procedure ( input cli-code, output ri) no-error.
      end.
      if ri = ? then do:
          message "Клиент с кодом : " NameOrCode skip
                  "при текущих параметрах" skip
                  "просмотра справочника" skip
                  "НЕ  НАЙДЕН.".
          return no-apply.
       end.
       else  do:
          apply "entry" to NameOrCOde in frame Dialog-Frame .
          run proc-vc-find-by in this-procedure ( input  no).
          case var-br-name :         when "cli-list":U then do:            reposition Cli-List to recid ri no-error .         end.         when "cli-listA":U then do:            reposition Cli-ListA to recid ri no-error .         end.         when "cli-listB":U then do:            reposition Cli-ListB to recid ri no-error .          end.         end case.
          if error-status:error then do:
            find first pos_clients no-lock where       recid( pos_clients ) = ri no-error .   message  substitute("Невозможно позиционироваться на клиенте &1&2Клиент был добавлен (или изменен или удален)&2и теперь не попадает в текущую выборку"             ,(if available pos_clients then (pos_clients.obj-type + string(pos_clients.obj-code)) else '':U)              , chr(10)) view-as alert-box WARNING.
          end.
          case var-br-name :         when "cli-list":U then do:            g#log = Cli-List:select-focused-row ().         end.         when "cli-listA":U then do:            g#log = Cli-ListA:select-focused-row ().         end.         when "cli-listB":U then do:            g#log = Cli-ListB:select-focused-row ().          end.         end case.
       end.
    end.
    else if Find-By = "ИНН" then do:
      if var-br-name = "cli-list" then do:
        run proc-find-inn in this-procedure ( input trim( NameOrCode ), output ri) no-error.
        apply "entry" to NameOrCOde in frame Dialog-Frame .
        case var-br-name :         when "cli-list":U then do:            reposition Cli-List to recid ri no-error .         end.         when "cli-listA":U then do:            reposition Cli-ListA to recid ri no-error .         end.         when "cli-listB":U then do:            reposition Cli-ListB to recid ri no-error .          end.         end case.
        if error-status:error then do:
          if ri <> ? then do:
                        find first pos_clients no-lock where       recid( pos_clients ) = ri no-error .   message  substitute("Невозможно позиционироваться на клиенте &1&2Клиент был добавлен (или изменен или удален)&2и теперь не попадает в текущую выборку"             ,(if available pos_clients then (pos_clients.obj-type + string(pos_clients.obj-code)) else '':U)              , chr(10)) view-as alert-box WARNING.
          end.
          else do:
            message subst("Организации с ИНН &1 нет в справочнике", trim( NameOrCode ))
            view-as alert-box.
          end.
        end.
        case var-br-name :         when "cli-list":U then do:            g#log = Cli-List:select-focused-row ().         end.         when "cli-listA":U then do:            g#log = Cli-ListA:select-focused-row ().         end.         when "cli-listB":U then do:            g#log = Cli-ListB:select-focused-row ().          end.         end case.
      end.
    end.
    else do:
        NameOrCode = prep-nameorcode (nameorcode).
        case var-br-name :         when "cli-list":U then do:            Run OpenBR in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         when "cli-listA":U then do:            Run OpenBRA in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         when "cli-listB":U then do:            Run OpenBRB in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         end case.
        if available X_clients AND num-results( var-br-name ) <> 0 then do:
            case var-br-name :         when "cli-list":U then do:            reposition Cli-List to row 1 no-error .         end.         when "cli-listA":U then do:            reposition Cli-ListA to row 1 no-error .         end.         when "cli-listB":U then do:            reposition Cli-ListB to row 1 no-error .          end.         end case.
            case var-br-name :         when "cli-list":U then do:            g#log = Cli-List:select-row (1).         end.         when "cli-listA":U then do:            g#log = Cli-ListA:select-row (1).         end.         when "cli-listB":U then do:            g#log = Cli-ListB:select-row (1).          end.         end case.
        end.
    end.
  end.
  if b-mark:sensitive then apply "choose" to b-mark in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-value-change-All-or-Group :
define variable g-grp as character no-undo .
  assign
  frame Dialog-Frame ALL-Or-GROUP
  getc-recid = yes
  .
    CASE ALL-Or-GROUP:
      when 'группа':U then do:
        assign
          attr-option_ = ""
          var-prev-br-name = var-br-name
          var-br-name  = ( if var-br-name = "cli-listB":U then  "cli-listB":U else  "cli-list":U )
          g-grp        = "".
        run ref/cli-grps.w (  input parparentproc
                            ,input  "b-sel"
                            ,input-output g-grp ) .
        if g-grp = "" then do:
          assign All-Or-Group = 'все':U .
          DISPLAY All-Or-Group with frame Dialog-Frame .
        end.
        else do:
          FIND ub.cli-grp where recid( ub.cli-grp ) = integer( g-grp ) no-lock.
          RUN cli-grplib-get-full-name in this-procedure ( input ub.cli-grp.node-code, output Curr-Grp-Name ) .
          assign
          Find-By:screen-value = 'все':U
          NameOrCode = "" .
          apply "value-changed" to Find-By in frame Dialog-Frame .
        end.
      end.
      when 'АТР':U then do:
        assign
        attr-option_ = 'db':U
        var-prev-br-name = var-br-name
        var-br-name = ( if var-br-name = "cli-listB":U then  "cli-listB":U else  "cli-listA":U )
        g-grp = ""
        .
        assign
        Find-By:screen-value = 'все':U
        NameOrCode = "" .
        apply "value-changed" to Find-By in frame Dialog-Frame .
      end.
      when 'все':U then do:
        assign
        Find-By:screen-value = 'все':U
        NameOrCode = ""
        attr-option_ = ""
        var-prev-br-name = var-br-name
        var-br-name =  ( if var-br-name = "cli-listB":U then  "cli-listB":U else  "cli-list":U )
        g-grp = ""
        .
        apply "value-changed" to Find-By in frame Dialog-Frame .
      end.
    END CASE.
END PROCEDURE.
PROCEDURE proc-vc-find-by :
define input parameter p-openquery as logical no-undo .
define variable PrevValue as char no-undo .
run waitfram-show in this-procedure ( input "Ждите..." ).
  do
  on error undo, return error
  :
    run waitfram-show in this-procedure ( input "Ждите..." ).
    PrevValue = Find-By .
    v-last-inn-rec = ?.
    assign
    frame Dialog-Frame
    Find-By .
    c-recid = ( if available X_clients and getc-recid then recid( X_clients ) else ? ) .
    CASE Find-By :
      when 'все':U then do:
        g#log = Find-By:enable(radio-label('название':U, Find-by:radio-buttons)).
        g#log = Find-By:enable(radio-label('код':U, Find-by:radio-buttons)) .
        g#log = Find-By:enable(radio-label('ИНН':U, Find-by:radio-buttons)) .
        if p-openquery then do:
          case var-br-name :         when "cli-list":U then do:            Run OpenBR in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         when "cli-listA":U then do:            Run OpenBRA in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         when "cli-listB":U then do:            Run OpenBRB in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         end case. .
        end.
        DISABLE
        NameOrCode
        with frame Dialog-Frame .
        HIDE
        NameOrCode .
        run waitfram-hide in this-procedure .
        case var-br-name :         when "cli-list":U then do:            apply "entry" to Cli-List in frame Dialog-Frame.         end.         when "cli-listA":U then do:            apply "entry" to Cli-ListA in frame Dialog-Frame.         end.         when "cli-listB":U then do:            apply "entry" to Cli-ListB in frame Dialog-Frame.         end.         end case.
      end.
      when 'название':U OR when 'код':U OR when 'ИНН' then do:
        VIEW
        NameOrCode .
        ENABLE
        NameOrCode
        with frame Dialog-Frame .
        if can-do( 'код':U, Find-By ) AND
           can-do( 'название':U, PrevValue ) AND ( NameOrCode <> "" ) then do:
          if p-openquery then do:
            case var-br-name :         when "cli-list":U then do:            Run OpenBR in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         when "cli-listA":U then do:            Run OpenBRA in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         when "cli-listB":U then do:            Run OpenBRB in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         end case.
          end.
        end.
        if can-do( 'код':U, Find-By ) then  do:
          assign
          NameOrCode:width-chars = 10
          NameOrCode:format = "x(9)" .
          g#log = Find-By:disable(radio-label('название':U, Find-by:radio-buttons)) .
          g#log = Find-By:disable(radio-label('ИНН':U, Find-by:radio-buttons)) .
        end.
        else if can-do( 'ИНН':U, Find-by ) then do:
            assign
            NameOrCode:width-chars = 15
            NameOrCode:format = "x(15)"
            .
            g#log = Find-by:disable (radio-label('название':U, Find-by:radio-buttons)) .
            g#log = Find-By:disable(radio-label('код':U, Find-by:radio-buttons)) .
        end.
        else do:
          assign
          NameOrCode:width-chars = 24.63
          NameOrCode:format = "X(40)"
          .
          g#log = Find-By:disable(radio-label('код':U, Find-by:radio-buttons)) .
          g#log = Find-By:disable(radio-label('ИНН':U, Find-by:radio-buttons)) .
        end.
        run waitfram-hide in this-procedure .
        apply "entry" to NameOrCode in frame Dialog-Frame .
      end.
   END CASE .
  end.
END PROCEDURE.
PROCEDURE reopen-query :
define variable ri as recid no-undo .
if available X_clients then
ri = recid(X_clients).
case var-br-name :         when "cli-list":U then do:            Run OpenBR in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         when "cli-listA":U then do:            Run OpenBRA in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         when "cli-listB":U then do:            Run OpenBRB in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         end case.
case var-br-name :         when "cli-list":U then do:            reposition Cli-List to recid ri no-error .         end.         when "cli-listA":U then do:            reposition Cli-ListA to recid ri no-error .         end.         when "cli-listB":U then do:            reposition Cli-ListB to recid ri no-error .          end.         end case.
if error-status:error then do:
      find first pos_clients no-lock where       recid( pos_clients ) = ri no-error .   message  substitute("Невозможно позиционироваться на клиенте &1&2Клиент был добавлен (или изменен или удален)&2и теперь не попадает в текущую выборку"             ,(if available pos_clients then (pos_clients.obj-type + string(pos_clients.obj-code)) else '':U)              , chr(10)) view-as alert-box WARNING.
end.
case var-br-name :         when "cli-list":U then do:            apply "entry" to Cli-List in frame Dialog-Frame.         end.         when "cli-listA":U then do:            apply "entry" to Cli-ListA in frame Dialog-Frame.         end.         when "cli-listB":U then do:            apply "entry" to Cli-ListB in frame Dialog-Frame.         end.         end case.
case var-br-name :         when "cli-list":U then do:            apply "value-changed" to Cli-List in frame Dialog-Frame .         end.         when "cli-listA":U then do:            apply "value-changed" to Cli-ListA in frame Dialog-Frame .         end.         when "cli-listB":U then do:             apply "value-changed" to Cli-ListB in frame Dialog-Frame .         end.         end case.
END PROCEDURE.
PROCEDURE StartProc :
define input parameter p-step as integer no-undo .
define variable     list-buf    as  character    no-undo.
define variable custvalue            as character no-undo .
define variable custtype             as character no-undo .
define variable varis-fin as character no-undo .
DEFINE VARIABLE par-is-edi           as character no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo.
define variable v-str as character no-undo.
define variable v-cli-type like ub.clients.obj-type no-undo.
define variable v-cli-code like ub.clients.obj-code no-undo.
define variable g-log as logical no-undo.
if p-step = 1 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-edi'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output par-is-edi
  ,output par-type
  )  .
  assign
  is-edi = lookup(par-is-edi, "true,yes":U) > 0
  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-fin'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output varis-fin
  ,output par-type
  ) no-error .
  assign
  is-fin = logical(varis-fin)
  .
  define variable v-use-grp-buy           as logical   no-undo .
  define variable v-use-oborot-buy        as logical   no-undo .
  define variable v-use-qnty-group        as logical   no-undo .
  define variable v-use-sum-group         as logical   no-undo .
  define variable v-use-add-code          as logical   no-undo .
  define variable v-use-sys-date-time     as logical   no-undo .
  define variable v-use-shift-date-num    as logical   no-undo .
  define variable v-use-cassa             as logical   no-undo .
  define variable v-use-val               as logical   no-undo .
  define variable v-use-pay-type          as logical   no-undo .
  define variable v-use-cash-pay          as logical   no-undo .
  define variable v-use-child as logical   no-undo .
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run glstall in g#library
(  output v-use-grp-buy
 , output v-use-oborot-buy
 , output v-use-qnty-group
 , output v-use-sum-group
 , output v-use-add-code
 , output v-use-sys-date-time
 , output v-use-shift-date-num
 , output v-use-cassa
 , output v-use-val
 , output v-use-pay-type
 , output v-use-cash-pay
 , output v-use-child
        )  .
if ( v-use-grp-buy or v-use-oborot-buy )  then   is-price-buyer = true .
  else  is-price-buyer = false  .
  if not v-is-news then do:
    run uf-get in this-procedure(
          input  'cli-all-p':U
          ,input  v-cntxt-userid
          ,output v-uf-List_
          ,output v-uf-Naim
          ,output v-uf-print-graft
          ,output v-uf-sort-gr
          ,output v-uf-type-price
          ,output v-uf-type-val
      )  no-error.
      if not error-status:error
      and num-entries(v-uf-List_, chr(4)) = 6 then do:
        assign
        v-types  = entry(1, v-uf-List_, chr(4))
        v-group  = entry(2, v-uf-List_, chr(4))
        v-status = entry(3, v-uf-List_, chr(4))
        v-recid  = if entry(4, v-uf-List_, chr(4)) = chr(63)
                  then ?
                  else   integer(entry(4, v-uf-List_, chr(4)))
        v-added  = entry(5, v-uf-List_, chr(4))
        v-other  = entry(6, v-uf-List_, chr(4))
        .
        if num-entries(v-uf-Naim, chr(4)) >= 2 then do:
          assign
          v-obj-name-width = decimal(entry(1, v-uf-Naim, chr(4)))
          v-grp-name-width = decimal(entry(2, v-uf-Naim, chr(4)))
          .
        end.
      end.
    end.
    do ii = 1 to num-entries(c-other, ";":U):
      if entry(1, entry(ii, c-other, ";":U), "=":U) = "without-obj":U then do:
        assign
        v-without-obj = yes
        .
      end.
      if entry(1, entry(ii, c-other, ";":U), "=":U) = "news":U then do:
        assign
        v-is-news = yes
        .
      end.
      if entry(1, entry(ii, c-other, ";":U), "=":U) = "lock-cli-type":U then do:
        assign
        v-lock-cli-type = yes
        .
      end.
      if entry(1, entry(ii, c-other, ";":U), "=":U) = "s-deploy":U then do:
        assign
        v-s-deploy = yes
        .
      end.
      if entry(1, entry(ii, c-other, ";":U), "=":U) = "parent-handle":U then do:
        assign
        p-callback-handle = handle(entry(2, entry(ii, c-other, ";":U), "=":U))
        .
      end.
      if entry(1, entry(ii, c-other, ";":U), "=":U) = "supp-np":U then do:
        for each x_temp-list-buyer :
          delete x_temp-list-buyer.
        end.
        for each X_clients-attr no-lock where X_clients-attr.attr-code = 'supp-np':U
                                          and X_clients-attr.attr-value = "yes" :
              if not can-find (first x_temp-list-buyer where x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                                                         and x_temp-list-buyer.obj-code = X_clients-attr.obj-code)
              then do :
                create x_temp-list-buyer.
                assign
                  x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                  x_temp-list-buyer.obj-code = X_clients-attr.obj-code
                .
              end.
        end.
      end.
      if entry(1, entry(ii, c-other, ";":U), "=":U) = "supp-lgas":U then do:
        for each x_temp-list-buyer :
          delete x_temp-list-buyer.
        end.
        for each X_clients-attr no-lock where X_clients-attr.attr-code = 'supp-lgas':U
                                          and X_clients-attr.attr-value = "yes" :
              if not can-find (first x_temp-list-buyer where x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                                                         and x_temp-list-buyer.obj-code = X_clients-attr.obj-code)
              then do :
                create x_temp-list-buyer.
                assign
                  x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                  x_temp-list-buyer.obj-code = X_clients-attr.obj-code
                .
              end.
        end.
      end.
      if entry(1, entry(ii, c-other, ";":U), "=":U) = "supp-np-lgas":U then do:
        for each x_temp-list-buyer :
          delete x_temp-list-buyer.
        end.
        for each X_clients-attr no-lock where X_clients-attr.attr-code = 'supp-np':U
                                          and X_clients-attr.attr-value = "yes" :
              if not can-find (first x_temp-list-buyer where x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                                                         and x_temp-list-buyer.obj-code = X_clients-attr.obj-code)
              then do :
                create x_temp-list-buyer.
                assign
                  x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                  x_temp-list-buyer.obj-code = X_clients-attr.obj-code
                .
              end.
        end.
        for each X_clients-attr no-lock where X_clients-attr.attr-code = 'supp-lgas':U
                                          and X_clients-attr.attr-value = "yes" :
              if not can-find (first x_temp-list-buyer where x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                                                         and x_temp-list-buyer.obj-code = X_clients-attr.obj-code)
              then do :
                create x_temp-list-buyer.
                assign
                  x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                  x_temp-list-buyer.obj-code = X_clients-attr.obj-code
                .
              end.
        end.
      end.
      if  entry(1, entry(ii, c-other, ";":U), "=":U) = "tank-farm-for":U then do :
        if entry(2, entry(ii, c-other, ";":U), "=":U) <> "":U
        then do:
          v-tank-farm-for = entry(2, entry(ii, c-other, ";":U), "=":U).
          do jj = 1 to num-entries(v-tank-farm-for)  :
            v-str = entry(jj,v-tank-farm-for).
            v-cli-type = substring(v-str,1,3).
            v-cli-code = integer(trim(v-str,v-cli-type)).
            find first X_clients no-lock
                where X_clients.obj-type = v-cli-type
                  and X_clients.obj-code = v-cli-code no-error.
            if available X_clients then do :
              if v-rid-list = "" then do :
                v-rid-list = string( recid(X_clients) ).
              end.
              else do :
                v-rid-list = v-rid-list + "," + string( recid(X_clients) ).
              end.
            end.
          end.
        end.
      end.
      if  entry(1, entry(ii, c-other, ";":U), "=":U) = "auto-tank-for":U then do :
        if entry(2, entry(ii, c-other, ";":U), "=":U) <> "":U
        then do:
          v-auto-tank-for = entry(2, entry(ii, c-other, ";":U), "=":U).
          do jj = 1 to num-entries(v-auto-tank-for) :
            v-str = entry(jj,v-auto-tank-for).
            v-cli-type = substring(v-str,1,3).
            v-cli-code = integer(trim(v-str,v-cli-type)).
            find first X_clients no-lock
                where X_clients.obj-type = v-cli-type
                  and X_clients.obj-code = v-cli-code no-error.
            if available X_clients then do :
              if v-rid-list = "" then do :
                v-rid-list = string( recid(X_clients) ).
              end.
              else do :
                v-rid-list = v-rid-list + "," + string( recid(X_clients) ).
              end.
            end.
          end.
        end.
      end.
      if  entry(1, entry(ii, c-other, ";":U), "=":U) = "auto-tank-for-supp":U then do :
        if entry(2, entry(ii, c-other, ";":U), "=":U) <> "":U
        then do:
          v-auto-tank-for-supp = entry(2, entry(ii, c-other, ";":U), "=":U).
          for each X_clients-attr no-lock where X_clients-attr.attr-code = 'auto-tank-for':U
                                            and lookup(v-auto-tank-for-supp,X_clients-attr.attr-value) <> 0 :
            if not can-find (first x_temp-list-buyer where x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                                                        and x_temp-list-buyer.obj-code = X_clients-attr.obj-code)
            then do :
              create x_temp-list-buyer.
              assign
                x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                x_temp-list-buyer.obj-code = X_clients-attr.obj-code
              .
            end.
          end.
        end.
      end.
      if  entry(1, entry(ii, c-other, ";":U), "=":U) = "tank-farm-for-supp":U then do :
        if entry(2, entry(ii, c-other, ";":U), "=":U) <> "":U
        then do:
          v-tank-farm-for-supp = entry(2, entry(ii, c-other, ";":U), "=":U).
          do jj = 1 to num-entries(v-tank-farm-for-supp) :
            v-str = entry(jj,v-tank-farm-for-supp).
            for each X_clients-attr no-lock where X_clients-attr.attr-code = 'tank-farm-for':U
                                              and X_clients-attr.attr-value = v-str :
              if not can-find (first x_temp-list-buyer where x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                                                          and x_temp-list-buyer.obj-code = X_clients-attr.obj-code)
              then do :
                create x_temp-list-buyer.
                assign
                  x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                  x_temp-list-buyer.obj-code = X_clients-attr.obj-code
                .
              end.
            end.
          end .
        end.
        else do :
          for each X_clients-attr no-lock where X_clients-attr.attr-code = 'tank-farm-for':U
                                            and X_clients-attr.attr-value > "" :
            if not can-find (first x_temp-list-buyer where x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                                                        and x_temp-list-buyer.obj-code = X_clients-attr.obj-code)
            then do :
              create x_temp-list-buyer.
              assign
                x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                x_temp-list-buyer.obj-code = X_clients-attr.obj-code
              .
            end.
          end.
        end .
      end.
      if entry(1, entry(ii, c-other, ";":U), "=":U) = "contract-edi_orders":U then do:
        for each x_temp-list-buyer :
          delete x_temp-list-buyer.
        end.
        for each X_contract-attr no-lock where X_contract-attr.attr-code = "contract-edi_orders" and
        X_contract-attr.host-code = v-cntxt-host-code-obj and
        X_contract-attr.attr-value = string(true):
            for first X_contractr no-lock where
                      X_contractr.contract-code = X_contract-attr.contract-code
                  and X_contractr.host-code = X_contract-attr.host-code
                  and X_contractr.doc-type = 'при':U
                  and X_contractr.status_ = 'тек':U
                  and (X_contractr.contract-date-end >= today or X_contractr.contract-date-end = ?)
                  and X_contractr.contract-date-beg <= today
              :
              if not can-find (first x_temp-list-buyer where x_temp-list-buyer.obj-type = X_contractr.cli-type
                                                         and x_temp-list-buyer.obj-code = X_contractr.cli-code)
              then do :
                create x_temp-list-buyer.
                assign
                  x_temp-list-buyer.obj-type = X_contractr.cli-type
                  x_temp-list-buyer.obj-code = X_contractr.cli-code
                .
              end.
            end.
        end.
      end.
    end.
    if v-cntxt-level <> 'object':U then do:
      assign
      v-without-obj = yes
      .
    end.
    if (lookup("b-mark", p-bttns) > 0
     or lookup("b-mark-hidden", p-bttns) > 0)
    and valid-handle(p-callback-handle)
    and lookup( "userobjs_transfer", p-callback-handle:internal-entries ) > 0
    then do:
      v-new-selection-flag = yes.
      run userobjs_transfer in p-callback-handle
        (input this-procedure :handle
        ) .
      run display-select-num in this-procedure .
    end.
    else do:
      hide mark-num in frame Dialog-Frame.
    end.
    return.
end.
if v-other begins "tank-farm-for" or v-other begins "auto-tank-for" or v-other begins "supp-np" or v-other begins "supp-lgas" or v-other begins "contract-edi_orders" then v-other = "".
if c-types = 'про':U then do :
  c-types = ? .
  v-is-prod = true.
end.
assign
c-types  =  (if c-types = ? then v-types else c-types)
c-group  =  (if c-group = ? then v-group else c-group)
c-status =  (if c-status = ? then v-status else c-status)
c-recid  =  (if c-recid = ? then v-recid else c-recid)
c-added  =  (if c-added = ? then v-added else c-added)
c-other  =  (if c-other = ? then v-other else c-other)
.
DISABLE
b-Photo
b-sel   when (lookup("b-sel", p-bttns) = 0)
b-add   when (lookup("b-add", p-bttns) = 0)
b-add-prs   when (lookup("b-add", p-bttns) = 0)
b-chg   when (lookup("b-add", p-bttns) = 0)
b-grp   when (lookup("b-add", p-bttns) = 0)
b-sert  when ((lookup("b-add", p-bttns) = 0) and v-cntxt-db-num <> 0)
b-del   when (lookup("b-add", p-bttns) = 0)
b-bank  when (lookup("b-bank", p-bttns) = 0)
b-mark  when (lookup("b-mark", p-bttns) = 0)
cli-types when v-lock-cli-type
b-edi     when not is-edi
b-cont    when not is-fin
b-price-type   when not is-price-buyer
WITH FRAME Dialog-Frame.
CASE entry( 1, c-added ) :
        when "yes" then
            SupGds = yes .
        when "no" OR when "" then
            SupGds = no .
        when "?" then
            SupGds = ? .
END CASE .
CASE entry( 2, c-added ) :
        when "yes" then
            SupCons = yes .
        when "no" OR when "" then
            SupCons = no .
        when "?" then
            SupCons = ? .
END CASE .
CASE entry( 3, c-added ) :
        when "yes" then
            SupServ = yes .
        when "no" OR when "" then
            SupServ = no .
        when "?" then
            SupServ = ? .
END CASE .
CASE entry( 4, c-added ) :
        when "yes" then
            BuyGds = yes .
        when "no" OR when "" then
            BuyGds = no .
        when "?" then
            BuyGds = ? .
END CASE .
CASE entry( 5, c-added ) :
        when "yes" then
            BuyCons = yes .
        when "no" OR when "" then
            BuyCons = no .
        when "?" then
            BuyCons = ? .
END CASE .
CASE entry( 6, c-added ) :
        when "yes" then
            BuyServ = yes .
        when "no" OR when "" then
            BuyServ = no .
        when "?" then
            BuyServ = ? .
END CASE .
list-buf = entry( 9, c-added ) NO-ERROR .
if error-status:error OR ( list-buf = "yes" ) then
    WLim-kr = TRUE .
else
    WLim-kr = FALSE .
assign
JoinType = entry( 7, c-added )
All-Or-Group = if num-entries(c-group, chr(3)) > 1
               then entry(1, c-group, chr(3))
               else 'все':U
Curr-Grp-Name = if num-entries(c-group, chr(3)) > 1
                then entry(2, c-group, chr(3))
                else ""
attr-option_ = (if all-or-group = 'АТР':U
                and num-entries(c-group, chr(3)) > 1
                and entry(2, c-group, chr(3)) <> "":U
                then entry(2, c-group, chr(3))
                else "")
Cli-Status = c-status
Cli-Types = c-types
All-Suppliers = ( SupGds OR SupCons OR SupServ )
All-Buyers = ( BuyGds OR BuyCons OR BuyServ ) .
do ii = 1 to num-entries(c-other, ";":U):
  if entry(1, entry(ii, c-other, ";":U), "=":U) = "auto-tank-for":U or entry(1, entry(ii, c-other, ";":U), "=":U) = "tank-farm-for":U  then do :
    if entry(2, entry(ii, c-other, ";":U), "=":U) = "":U then v-rid-list = "".
  end.
  else do :
    v-total-select-num = num-entries(v-rid-list).
  end.
end.
DISPLAY
All-Or-Group
Cli-Status
Cli-Types
WITH FRAME Dialog-Frame .
case cli-types:
  when 'маг':U
  or when 'скл':U
  or when 'объект':U
  then do:
    assign
    X_clients.db-num:visible in browse cli-list = yes
    X_clients.host-code:visible in browse cli-list = yes
    X_clients.db-num:visible in browse cli-lista = yes
    X_clients.host-code:visible in browse cli-lista = yes
    X_clients.db-num:visible in browse cli-listb = yes
    X_clients.host-code:visible in browse cli-listb = yes
    .
  end.
  when "db" then do:
    assign
    X_clients.db-num:visible in browse cli-list = no
    X_clients.host-code:visible in browse cli-list = yes
    X_clients.db-num:visible in browse cli-lista = no
    X_clients.host-code:visible in browse cli-lista = yes
    X_clients.db-num:visible in browse cli-listb = no
    X_clients.host-code:visible in browse cli-listb = yes
    .
  end.
  otherwise do:
    assign
    X_clients.db-num:visible in browse cli-list = no
    X_clients.host-code:visible in browse cli-list = no
    X_clients.db-num:visible in browse cli-lista = no
    X_clients.host-code:visible in browse cli-lista = no
    X_clients.db-num:visible in browse cli-listb = no
    X_clients.host-code:visible in browse cli-listb = no
    .
  end.
end case.
if attr-option_ = "":U then do:
    HIDE
    cli-listA
    in frame Dialog-Frame.
end.
else do:
    HIDE
    cli-list
    in frame Dialog-Frame.
end.
if v-total-select-num = 0 then do:
  HIDE
  mark-num
  in frame Dialog-Frame .
end.
HIDE
NameOrCode
in frame Dialog-Frame .
if attr-option_ = "":U then do:
  var-prev-br-name = var-br-name.
  var-Br-Name = "cli-list":U.
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  cli-list :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
end.
else do:
  var-prev-br-name = var-br-name.
  var-Br-Name = "cli-listA":U.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  cli-listA :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
end.
if entry(1,c-other,"=":U) = "supp-lgas"
or entry(1,c-other,"=":U) = "supp-np"
or entry(1,c-other,"=":U) = "supp-np-lgas"
or entry(1,c-other,"=":U) = "auto-tank-for-supp"
or entry(1,c-other,"=":U) = "tank-farm-for-supp"
or entry(1,c-other,"=":U) = "contract-edi_orders"
then do :
  HIDE
  CLi-list in frame Dialog-Frame
  CLi-listA
  in frame Dialog-Frame.
  enable Del-Filters
  with frame Dialog-Frame .
  g-log = ALL-Or-GROUP:disable ( radio-label ( 'АТР':U, ALL-Or-GROUP:radio-buttons) ).
  var-prev-br-name = var-br-name.
  var-Br-Name = "cli-listB":U.
  v-list-b = true .
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  cli-listB :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
end.
case var-br-name :         when "cli-list":U then do:            Run OpenBR in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         when "cli-listA":U then do:            Run OpenBRA in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         when "cli-listB":U then do:            Run OpenBRB in this-procedure (yes, no, ' ':U, yes) no-error  .         end.         end case.
END PROCEDURE.
PROCEDURE Switch-Buttons :
define input  parameter p-needmes as logical no-undo .
define variable titleStr as character no-undo.
titleStr = "Клиенты".
if session :set-wait-state( "compiler" ) then.
VIEW
b-add in frame Dialog-Frame
b-add-prs in frame Dialog-Frame
b-bank b-del b-grp b-mark b-sel b-chg
b-Docs Goods-By-Prod b-Hist b-Photo b-Print b-lkp b-help b-dc b-attr b-cont
in frame Dialog-Frame .
if p-NeedMes then
run waitfram-show in this-procedure (  input "Подождите : таблица ОБНОВЛЯЕТСЯ." ) .
assign frame Dialog-Frame
All-Or-Group Cli-Types Cli-Status Find-By
.
CASE Cli-Types :
    when 'все':U then
        TitleStr = "Все клиенты " .
    when 'орг':U then
        TitleStr = "Все организации  " .
    when 'чел':U then
        TitleStr = "Все физич. лица " .
    when 'скл':U then
        TitleStr = "Все склады " .
    when 'маг':U then
        TitleStr = "Все магазины " .
    when 'объект':U then
        TitleStr = "Все объекты " .
    when "db" then
        TitleStr = "Все объекты текущей БД" .
END CASE .
if v-is-prod then TitleStr = "Все производители" .
if can-do( 'группа':U , All-Or-Group ) then
    TitleStr = TitleStr + "группы " + substr( Curr-Grp-Name, 1, 40 ) + chr(32).
if can-do( 'АТР':U , All-Or-Group ) then
    TitleStr = TitleStr + "Атрибут " + attr-option_.
CASE Cli-Status :
    when 'текущие':U then
        TitleStr = TitleStr + "( текущие )" .
    when 'удаленные':U then
        TitleStr = TitleStr + "( удаленные )" .
END CASE .
if JoinType <> "NO" then
    TitleStr = TitleStr + ". С доп. фильтром." .
if entry(1,c-other,"=":U) = "supp-np"
then TitleStr = TitleStr + chr(32) + "Поставщики НП" .
else
if entry(1,c-other,"=":U) = "supp-lgas"
then TitleStr = TitleStr + chr(32) + "Поставщики СУГ" .
else
if entry(1,c-other,"=":U) = "contract-edi_orders"
then TitleStr = TitleStr + chr(32) + "Поставщики с контрактом EDI" .
else
if entry(1,c-other,"=":U) = "supp-np-lgas"
then TitleStr = TitleStr + chr(32) + "Поставщики НП и СУГ" .
if entry(1,c-other,"=":U) = "auto-tank-for-supp"
then TitleStr = TitleStr + chr(32) + "Является перевозчиком для:" + v-auto-tank-for-supp .
if entry(1,c-other,"=":U) = "tank-farm-for-supp"
then TitleStr = TitleStr + chr(32) + "Является нефтебазой/ГНС для:" + v-tank-farm-for-supp.
frame Dialog-Frame:title = TitleStr .
show-as = Cli-Types + "-" + Find-By + "-" + All-Or-Group + "-" + Cli-Status .
if ub.db.add-clients   AND NOT TRANSACTION then do:
 ENABLE
 b-add   when can-do( p-bttns, "b-add")
 b-add-prs   when can-do( p-bttns, "b-add")
 b-chg   when can-do( p-bttns, "b-add")
 b-grp   when can-do( p-bttns, "b-add")
 b-del   when can-do( p-bttns, "b-add")
 b-attr  when can-do( p-bttns, "b-add")
 WITH FRAME Dialog-Frame .
 end.
else do:
 DISABLE
 b-add
 b-add-prs
 b-chg
 b-grp
 b-del
 b-attr
 WITH FRAME Dialog-Frame .
end.
if db.add-clients AND
( NOT can-do( 'удаленные':U , Cli-Status ) ) AND
can-do( "NO", JoinType ) AND NOT TRANSACTION then do:
 ENABLE
 b-chg   when can-do( p-bttns, "b-add")
 b-grp   when can-do( p-bttns, "b-add") AND not can-do( 'группа':U , Cli-Types )
 WITH FRAME Dialog-Frame .
 if lookup("b-add", p-bttns) > 0 then menu-item m_update-attr:sensitive in menu menu-b-attr = yes .
end.
else do:
 DISABLE
 b-chg
 b-grp
 WITH FRAME Dialog-Frame .
 menu-item m_update-attr:sensitive in menu menu-b-attr = no .
end.
if NOT TRANSACTION
then do:
    ENABLE
    b-attr
    WITH FRAME Dialog-Frame .
end.
else do:
    DISABLE
    b-attr
    WITH FRAME Dialog-Frame .
end.
if v-without-obj and not v-s-deploy then do:
  DISABLE
  b-dc
  b-del
  b-docs
  b-grp
  b-sert
  b-zak
  goods-by-prod
  b-edi
  WITH FRAME Dialog-Frame.
  assign
  b-bank:label = "&Счета".
end.
if v-s-deploy or v-is-news then do:
  DISABLE
  b-add-prs
  b-dc
  b-del
  b-docs
  b-sert
  b-zak
  goods-by-prod
  b-edi
  b-sch
  b-attr
  all-or-group
  b-bank
  b-cont
  WITH FRAME Dialog-Frame.
end.
END PROCEDURE.
procedure proc-find-inn:
define input parameter par-inn as character no-undo.
define output parameter par-recid as recid no-undo.
define buffer b_clients for ub.clients.
define buffer b_firm for ub.firm.
if v-last-inn-rec <> ? then do:
    find first b_firm no-lock
        where recid(b_firm) = v-last-inn-rec
        no-error.
    if not available b_firm then do:
        v-last-inn-rec = ?.
        par-recid = ?.
        return.
    end.
    find next b_firm no-lock
        where b_firm.inn = par-inn
        no-error.
    if not available b_firm then do:
        find first b_firm no-lock
            where b_firm.inn = par-inn
            no-error.
        find first b_clients no-lock
            where b_clients.obj-code = b_firm.firm-code
            and b_clients.obj-type = 'орг':U
            no-error.
        v-last-inn-rec = recid(b_firm).
        par-recid = recid(b_clients).
    end.
end.
else do:
    find first b_firm no-lock
        where b_firm.inn = par-inn
        no-error.
    if not available b_firm then do:
        v-last-inn-rec = ?.
        par-recid = ?.
        return.
    end.
end.
find first b_clients no-lock
    where b_clients.obj-type = 'орг':U
    and b_clients.obj-code = b_firm.firm-code
    no-error.
if not available b_clients then do:
    v-last-inn-rec = ?.
    par-recid = ?.
    return.
end.
par-recid = recid(b_clients).
v-last-inn-rec = recid(b_firm).
end procedure.
FUNCTION get-client RETURNS CHARACTER
  (buffer loc_clients for clients  ) :
define variable var-cli-name as character no-undo.
define buffer buf_dis-card             for ub.dis-card.
define buffer buf_buyer-in-buyer-group for ub.buyer-in-buyer-group  .
define buffer buf_buyer-group          for ub.buyer-group  .
var-cli-name = (IF (loc_clients.stts = 0)
                       THEN (loc_clients.obj-name)
                       ELSE (substring (
                                                loc_clients.obj-name, 1, 25) +
                                                FILL (" " , 25 - LENGTH (substring (loc_clients.obj-name, 1, 25)) )) +
                                                '---  УДАЛЕН  ---':U
                                 ).
    FIND buf_dis-card WHERE
         buf_dis-card.cli-type = X_clients.obj-type AND
         buf_dis-card.cli-code = X_clients.obj-code NO-LOCK NO-ERROR .
    if available buf_dis-card then
        assign
            cli-dcard = buf_dis-card.d-card
            cli-dpcnt = buf_dis-card.d-pcnt .
    else
        assign
            cli-dcard = ""
            cli-dpcnt = 0 .
RETURN var-cli-name.
END FUNCTION.
FUNCTION mark-string RETURNS CHARACTER
  ( buffer loc_clients for clients, input mark-list as character ) :
define buffer buf_dis-card for ub.dis-card.
define buffer buf_buyer-in-buyer-group for ub.buyer-in-buyer-group  .
define buffer buf_buyer-group          for ub.buyer-group  .
define variable v-mark-string as character no-undo .
var-cli-name = (IF (loc_clients.stts = 0)
                       THEN (loc_clients.obj-name)
                       ELSE (substring (
                                                loc_clients.obj-name, 1, 25) +
                                                FILL (" " , 25 - LENGTH (substring (loc_clients.obj-name, 1, 25)) )) +
                                                '---  УДАЛЕН  ---':U
                                 ).
    FIND buf_dis-card WHERE
         buf_dis-card.cli-type = X_clients.obj-type AND
         buf_dis-card.cli-code = X_clients.obj-code NO-LOCK NO-ERROR .
    if available buf_dis-card then
        assign
            cli-dcard = buf_dis-card.d-card
            cli-dpcnt = buf_dis-card.d-pcnt .
    else
        assign
            cli-dcard = ""
            cli-dpcnt = 0 .
    find first buf_buyer-in-buyer-group no-lock where
               buf_buyer-in-buyer-group.stts = 0 and
               buf_buyer-in-buyer-group.bbg-obj-type = X_clients.obj-type and
               buf_buyer-in-buyer-group.bbg-obj-code = X_clients.obj-code no-error .
    if available buf_buyer-in-buyer-group then do:
    find first buf_buyer-group no-lock where
               buf_buyer-group.stts = 0 and
               buf_buyer-group.bgr-db-num = buf_buyer-in-buyer-group.bgr-db-num and
               buf_buyer-group.bgr-id     = buf_buyer-in-buyer-group.bgr-id no-error .
    assign
     price-grp = buf_buyer-group.name
    .
    end.
    else assign
     price-grp = ""
    .
  if v-new-selection-flag then do:
    run get-mark-string in this-procedure
      (input  loc_clients.obj-type
      ,input  loc_clients.obj-code
      ,output v-mark-string
      ) .
    return v-mark-string .
  end.
RETURN ( IF LOOKUP( STRING( recid(loc_clients)), mark-list ) > 0 THEN "*" ELSE "":U ).
END FUNCTION.
FUNCTION prep-nameorcode RETURNS CHARACTER
  ( input p-nameorcode as character ) :
define variable v-nameorcode as character no-undo .
if trim(p-nameorcode) = '' then  return ''.
v-nameorcode = trim( trim( p-NameOrCode) , "*" ) .
if index(v-NameOrCode, chr(34) ,1 ) = 1
and R-index(v-NameOrCode, chr(34) ,1 ) = 1 then do:
  assign
  v-NameOrCode = trim(v-NameOrCode, chr(34))
  .
  nameorcode = v-nameorcode.
  display NameOrCode with frame Dialog-Frame.
end.
define variable v-dopi as character no-undo .
assign
v-dopi = substring(v-NameOrCode, length(v-NameOrCode), 1)
.
if index("abcdefghijklmnopqrstuvwxyzабвгдеёжзийклмнопрстуфхцчшщъыьэюя", v-dopi) > 0
or index("1234567890", v-dopi) > 0
then do:
  v-NameOrCode = v-NameOrCOde + "*".
end.
v-NameOrCode = LC(v-NameOrCode).
RETURN v-nameorcode.
END FUNCTION.
