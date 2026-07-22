block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-pinp.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-pinp.p $":U .
def var vss-description as character no-undo init "Топливо: приходы, расходы, остатки на конец месяца".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE LastDate:
    def input parameter in-date as date no-undo.
    def output parameter LastDate as date no-undo.
    LastDate = ((DATE(MONTH(in-date),28,YEAR(in-date)) + 4) - DAY(DATE(MONTH(in-date),28,YEAR(in-date)) + 4)).
END PROCEDURE.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
new shared
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
PROCEDURE ostatok :
def input parameter x-store-code  like ub.clients.obj-code    no-undo.
def input parameter x-store-type  like ub.clients.obj-type    no-undo.
def input parameter x-tog-shift   as   logical             no-undo.
def input parameter x-date-start  like ub.stk-tot.Fact-date   no-undo.
def input parameter x-date-end    like ub.stk-tot.Fact-date   no-undo.
def input parameter x-shift-start as integer               no-undo.
def input parameter x-shift-end   as integer               no-undo.
def input parameter x-sum-type    like ub.stk-tot.sum-type    no-undo.
def input parameter x-cat-id      like ub.stk-tot.cat-id      no-undo.
def input parameter xTog-obj   as log no-undo.
def output parameter Quantity    like ub.stk-tot.fact-qnty   no-undo.
def output parameter Coast_R     like ub.stk-tot.sum-rubl    no-undo.
def output parameter Coast_V     like ub.stk-tot.sum-rubl    no-undo.
def output parameter VAT_R       like ub.stk-tot.sum-rubl    no-undo.
def output parameter VAT_V       like ub.stk-tot.sum-rubl    no-undo.
def output parameter Fact-order  like ub.stk-tot.Fact-order  no-undo.
def var              Fact-order#   like ub.stk-tot.Fact-order  no-undo.
def var              Fact-orderS   as char  no-undo.
def var x-date-start-t  like ub.stk-tot.shift-date   no-undo.
   Assign
      Fact-order   = 0
      Quantity     = 0
      Coast_R      = 0
      Coast_V      = 0
      VAT_R        = 0
      VAT_V        = 0 .
 x-date-start-t  = x-date-start + 1 .
IF x-date-end = date('') then DO:
   Fact-order = 0 .
   for each obj-list
       where  ( not xtog-obj or
              ( x-store-type = obj-list.obj-type and x-store-code = obj-list.obj-code ))
              no-lock :
      if  x-tog-shift = false then do:
                       find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
                            ub.stk-tot.Fact-date <=  x-date-start
                            and ub.stk-tot.shift-num = 0
                            USE-INDEX fact-date no-lock no-error .
           if Available ub.stk-tot THEN  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
      End.
      Else  DO :
          find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
           (ub.stk-tot.shift-date  = x-date-start-t and
            ub.stk-tot.shift-num  < x-shift-start or
            ub.stk-tot.shift-date  < x-date-start-t  )
            and ub.stk-tot.shift-num  > 0
            USE-INDEX Shift-num no-lock no-error .
         If Available ub.stk-tot then  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
        END.
    If Fact-order < Fact-order#  and Fact-order# <> 0  THEN  Fact-order = Fact-order# .
  End.
End.
Else DO:
  For each obj-list  WHERE
     (NOT xTog-obj OR (x-store-type = obj-list.obj-type AND x-store-code = obj-list.obj-code))
      no-lock :
   IF  x-TOG-Shift = False Then DO:
       find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
            ub.stk-tot.Fact-date <= x-date-end
            and ub.stk-tot.shift-num = 0
            USE-INDEX fact-date no-lock no-error.
       if available ub.stk-tot then  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
   END.
   Else DO:
        find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
            (ub.stk-tot.shift-date  = x-date-end and
            ub.stk-tot.shift-num  <= x-shift-end or
            ub.stk-tot.shift-date  < x-date-end       ) and
            ub.stk-tot.shift-num   > 0      use-index shift-num no-lock no-error.
            if Available ub.stk-tot THEN Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
    End.
    if Fact-order < Fact-order#  THEN  Fact-order = Fact-order#.
  End.
End.
END PROCEDURE.
procedure ost-line :
  define input  parameter x-store-code like ub.clients.obj-code    no-undo .
  define input  parameter x-store-type like ub.clients.obj-type    no-undo .
  define input  parameter x-artic      like ub.stk-line.artic      no-undo .
  define input  parameter x-prod-code  like ub.stk-line.prod-code  no-undo .
  define input  parameter x-prod-type  like ub.stk-line.prod-type  no-undo .
  define input  parameter x-tog-shift  as logical no-undo .
  define input  parameter x-fact-order like ub.stk-line.fact-order no-undo .
  define input  parameter x-sum-type   like ub.stk-line.sum-type   no-undo .
  define input  parameter x-cat-id     like ub.stk-line.cat-id     no-undo .
  define input  parameter xtog-obj     as logical no-undo .
  define output parameter quantity     like ub.stk-line.fact-qnty  no-undo .
  define output parameter coast_r      like ub.stk-line.sum-rubl   no-undo .
  define output parameter coast_v      like ub.stk-line.sum-rubl   no-undo .
  define output parameter vat_r        like ub.stk-line.sum-rubl   no-undo .
  define output parameter vat_v        like ub.stk-line.sum-rubl   no-undo .
  define output parameter slt_r        like ub.stk-line.sum-rubl   no-undo .
  define output parameter slt_v        like ub.stk-line.sum-rubl   no-undo .
  define buffer buff-obj-list  for obj-list .
  define buffer buff-stk-line  for ub.stk-line .
  assign
    Quantity = 0
    Coast_R  = 0
    Coast_V  = 0
    VAT_R    = 0
    VAT_V    = 0
    SLT_R    = 0
    SLT_V    = 0
  .
  if  x-tog-shift = false then do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  = 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
        .
      end.
    end.
  end.
  else do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  > 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
        .
      end.
    end.
  end.
end procedure.
procedure ost-lineother-tax :
  define input  parameter x-store-code like ub.clients.obj-code      no-undo.
  define input  parameter x-store-type like ub.clients.obj-type      no-undo.
  define input  parameter x-artic      like ub.stk-line.artic        no-undo.
  define input  parameter x-prod-code  like ub.stk-line.prod-code    no-undo.
  define input  parameter x-prod-type  like ub.stk-line.prod-type    no-undo.
  define input  parameter x-tog-shift  as logical no-undo .
  define input  parameter x-fact-order like ub.stk-line.fact-order   no-undo.
  define input  parameter x-sum-type   like ub.stk-line.sum-type     no-undo.
  define input  parameter x-type-id    like ub.stk-line.cat-id       no-undo.
  define input  parameter xTog-obj     as logical no-undo .
  define output parameter Quantity     like ub.stk-line.fact-qnty   no-undo.
  define output parameter Coast_R      like ub.stk-line.sum-rubl    no-undo.
  define output parameter Coast_V      like ub.stk-line.sum-rubl    no-undo.
  define output parameter VAT_R        like ub.stk-line.sum-rubl    no-undo.
  define output parameter VAT_V        like ub.stk-line.sum-rubl    no-undo.
  define output parameter SLT_R        like ub.stk-line.sum-rubl    no-undo.
  define output parameter SLT_V        like ub.stk-line.sum-rubl    no-undo.
  define output parameter other_R      like ub.stk-line.sum-rubl    no-undo.
  define output parameter other_V      like ub.stk-line.sum-rubl    no-undo.
  define buffer buff-obj-list  for obj-list .
  define buffer buff-stk-line  for ub.stk-line .
  assign
    Quantity = 0
    Coast_R  = 0
    Coast_V  = 0
    VAT_R    = 0
    VAT_V    = 0
    SLT_R    = 0
    SLT_V    = 0
    other_R  = 0
    other_V  = 0
  .
  if  x-tog-shift = false then do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  = 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
          other_R  = other_R  +  buff-stk-line.other-rubl
          other_V  = other_V  +  buff-stk-line.other-base
        .
      end.
    end.
  end.
  else do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  > 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
          other_R = other_R   +  buff-stk-line.other-rubl
          other_V = other_V   +  buff-stk-line.other-base
        .
      end.
    end.
  end.
end procedure.
procedure ost-line-kg :
  define  input parameter p-obj-code    like ub.stk-line.obj-code   no-undo .
  define  input parameter p-obj-type    like ub.stk-line.obj-type   no-undo .
  define  input parameter p-artic       like ub.stk-line.artic      no-undo .
  define  input parameter p-prod-code   like ub.stk-line.prod-code  no-undo .
  define  input parameter p-prod-type   like ub.stk-line.prod-type  no-undo .
  define  input parameter p-fact-order  like ub.stk-line.fact-order no-undo .
  define output parameter p-quantity-kg like ub.stk-line.fact-qnty  no-undo initial 0.00 .
  define buffer buff-obj-list  for obj-list .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_inv-line for ub.inv-line .
  do
  on error undo, return error
  :
    for each buf_doc-line no-lock where
             buf_doc-line.obj-type    = p-obj-type   and
             buf_doc-line.obj-code    = p-obj-code   and
             buf_doc-line.prod-type   = p-prod-type  and
             buf_doc-line.prod-code   = p-prod-code  and
             buf_doc-line.artic       = p-artic      and
             buf_doc-line.status_     = 'факт':U      and
             buf_doc-line.fact-order <= p-fact-order
          by buf_doc-line.fact-order    descending
    :
      find first buf_inv-line no-lock where
                 buf_inv-line.doc-code  = buf_doc-line.doc-code  and
                 buf_inv-line.artic     = buf_doc-line.artic     and
                 buf_inv-line.prod-type = buf_doc-line.prod-type and
                 buf_inv-line.prod-code = buf_doc-line.prod-code no-error .
      if available buf_inv-line
      then do:
        if buf_inv-line.after-cli-qnty <> ?
        then do:
          assign
            p-quantity-kg = buf_inv-line.after-cli-qnty
          .
          leave .
        end.
      end.
    end.
    if p-quantity-kg = ?
    then do:
      assign
        p-quantity-kg = 0
      .
    end.
  end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var v-month  as integer no-undo format "99"   .
def var v-year   as integer no-undo format "9999" .
def var l-ok     as logical no-undo .
def var v-first-date as date no-undo .
def var v-last-date  as date no-undo .
define variable var-x-p-curr-obj-code  like ub.clients.obj-code    no-undo.
define variable var-x-p-curr-obj-type  like ub.clients.obj-type    no-undo.
define variable var-x-date-start  like ub.stk-tot.Fact-date   no-undo.
define variable var-x-date-endt   like ub.stk-tot.Fact-date   no-undo.
define variable var-x-sum-type    like ub.stk-tot.sum-type    no-undo.
define variable var-x-cat-id      like ub.stk-tot.cat-id      no-undo.
define variable var-xTog-obj      as   log                 no-undo.
define variable var-Quantity      like ub.stk-tot.fact-qnty   initial ? no-undo.
define variable var-Coast_R       like ub.stk-tot.sum-rubl    no-undo.
define variable var-Coast_V       like ub.stk-tot.sum-rubl    no-undo.
define variable var-VAT_R         like ub.stk-tot.sum-rubl    no-undo.
define variable var-VAT_V         like ub.stk-tot.sum-rubl    no-undo.
define variable var-Fact-order    like ub.stk-tot.Fact-order  no-undo.
define variable var-x-artic       like ub.stk-line.artic        no-undo.
define variable var-x-prod-code   like ub.stk-line.prod-code    no-undo.
define variable var-x-prod-type   like ub.stk-line.prod-type    no-undo.
define variable var-SLT_R         like ub.stk-tot.sum-rubl    no-undo.
define variable var-SLT_V         like ub.stk-tot.sum-rubl    no-undo.
define variable v-today      as date      no-undo .
define variable v-archive-ok as logical   no-undo .
define variable v-comment    as character no-undo .
define variable v-can-print  as logical   no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer buf_goods for ub.goods .
define buffer buf_trn-doc for ub.trn-doc .
define buffer buf_doc-line for ub.doc-line .
define buffer buf_parts for ub.parts .
define buffer buf_units for ub.units .
do while true :
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-today
  )  .
  assign
    v-year  = year( v-today )
    v-month = month( v-today )
  .
  run rep/d-pinp.w
    (input        parparentproc
    ,input        "Приходы, расходы, остатки за месяц"
    ,input-output v-month
    ,input-output v-year
    ,output       l-ok
    ).
  if l-ok <> true then do:
    return .
  end.
  def var v-month-name as character no-undo format "x(12)".
  run gbl/monthnam.p
    (input  v-month
    ,output v-month-name
    ).
  assign
    v-first-date = date(v-month, 1, v-year)
  .
  run lastdate in this-procedure
    (input  v-first-date
    ,output v-last-date
    ).
  find first ub.clients no-lock
    where ub.clients.obj-type = p-curr-obj-type
      and ub.clients.obj-code = p-curr-obj-code
    .
  define variable v-check-date as date      no-undo .
  assign
    v-check-date = v-last-date + 1
  .
  run rep/chk-ahz.p
    (input        ub.clients.obj-type
    ,input        ub.clients.obj-code
    ,input        no
    ,input        yes
    ,input        no
    ,input        no
    ,input        yes
    ,input        v-cntxt-db-num
    ,input        v-cntxt-userid
    ,input-output v-check-date
    ,input-output v-check-date
    ,output       v-archive-ok
    ,output       v-comment
    ,output       v-can-print
    ) .
  if v-archive-ok = false
  then do:
    if v-can-print = true
    then do:
      define variable v-ok as logical   no-undo .
      message
        "ВНИМАНИЕ!" skip
        v-comment skip
        "" skip
        "Продолжить формирование отчета?" skip
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok <> true
      then do:
        return .
      end.
    end.
    else do:
      message
        "ВНИМАНИЕ !!!" skip
        "Отчет не может быть сформирован!" skip
        "На запрошенную дату нет архивов или они сжаты" skip
        v-comment skip
        view-as alert-box information .
      return .
    end.
  end.
  def var v-ind         as integer   no-undo .
  def var v-line        as character no-undo format "X(136)" .
  assign
    v-line = fill("-", 136 )
  .
  def var v-line1        as character no-undo format "X(136)" .
  def var v-line2        as character no-undo format "X(136)" .
  def var v-line3        as character no-undo format "X(136)" .
  assign
    v-line1 = v-line
    v-line2 = v-line
    v-line3 = v-line
  .
  def var sym1          as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym2          as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym3          as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym4          as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym5          as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym6          as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym7          as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym8          as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym9          as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym10         as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym11         as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym12         as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym13         as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym14         as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym15         as character no-undo format "x(1)":u label '!':u init ":":u .
  run waitfram-show in this-procedure ( 'Подождите ...' ) .
  run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 62
                                            ,input yes
                                            ,input no
                                            ).
  def var v-header-name as character no-undo .
  def var v-print-time  as character no-undo .
  assign
    v-header-name = "ПРИХОДЫ"
    v-print-time  = cur-time-string()
  .
  form header
    v-line1 at 1 skip
    v-header-name + ": " + v-month-name + " " + string(v-year) format "x(50)" at 1
      "Дата печати :" at 60
      v-print-time format "x(20)"
      "Стр." at 111 string( page-number(PrnLibStream), ">>>9" )  skip
    "ОБЪЕКТ:" at 1 clients.obj-type + " " + string(clients.obj-code) format "x(15)"
    clients.obj-name skip
    v-line2 at 1 skip
    with frame topframe
    width 160 page-top no-labels no-box .
  view stream PrnLibStream frame topframe .
  form header
    v-line at 1 skip
    "Продолжение на следующей странице" at 30 skip
    with frame bottomframe
    width 160 page-bottom no-labels no-box .
  view stream PrnLibStream frame bottomframe .
  if v-archive-ok = false
  then do:
    put stream PrnLibStream
      "Расчитать полностью архивы не удалось." +
      "Информация в отчете может быть не корректной !" skip .
  end.
  define frame input-frm
    buf_goods.gds-name        format "x(52)" column-label "ТОВАР"
    buf_trn-doc.fact-date                    column-label "ДАТА"
    buf_parts.cli-qnty                       column-label "КОЛ-ВО (КГ)"
    buf_doc-line.fact-density                column-label "ПЛ-ТЬ"
    buf_parts.fact-qnty                      column-label "КОЛ-ВО"
    buf_units.long-name       format "x(20)" column-label "ЕД.ИЗМ."
    with width 160 down stream-io use-text .
  form with frame input-frm .
  for each gds-list no-lock
  ,first buf_goods no-lock
    where buf_goods.artic     = gds-list.artic
      and buf_goods.prod-type = gds-list.prod-type
      and buf_goods.prod-code = gds-list.prod-code
  :
    find first buf_units no-lock
      where buf_units.unit-name = buf_goods.unit-base
      .
    assign
      v-ind = v-ind + 1
    .
    process events .
    run waitfram-show in this-procedure ( "Линий обработано: " + string(v-ind) ) .
    def var v-total-cli-qnty  as decimal no-undo .
    def var v-total-fact-qnty as decimal no-undo .
    assign
      v-total-cli-qnty  = 0
      v-total-fact-qnty = 0
    .
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type  = p-curr-obj-type
        and buf_doc-line.obj-code  = p-curr-obj-code
        and buf_doc-line.artic     = buf_goods.artic
        and buf_doc-line.prod-type = buf_goods.prod-type
        and buf_doc-line.prod-code = buf_goods.prod-code
        and buf_doc-line.status_   = 'факт':U
    , first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
        and buf_trn-doc.doc-type = 'при':U
        and buf_trn-doc.internal = false
        and buf_trn-doc.fact-date >= v-first-date
        and buf_trn-doc.fact-date <= v-last-date
    :
      for each buf_parts no-lock
        where buf_parts.out-code  = buf_doc-line.doc-code
          and buf_parts.obj-type  = buf_doc-line.obj-type
          and buf_parts.obj-code  = buf_doc-line.obj-code
          and buf_parts.artic     = buf_doc-line.artic
          and buf_parts.prod-type = buf_doc-line.prod-type
          and buf_parts.prod-code = buf_doc-line.prod-code
      :
        display stream PrnLibStream
          buf_goods.gds-name
          buf_trn-doc.fact-date
          ( buf_parts.fact-qnty * buf_doc-line.fact-density ) @ buf_parts.cli-qnty
          buf_doc-line.fact-density
          buf_parts.fact-qnty
          buf_units.long-name
          with frame input-frm .
        down stream PrnLibStream 1 with frame input-frm .
        assign
          v-total-cli-qnty  = v-total-cli-qnty  + ( buf_parts.fact-qnty * buf_doc-line.fact-density )
          v-total-fact-qnty = v-total-fact-qnty + buf_parts.fact-qnty
        .
      end.
    end.
    display stream PrnLibStream
      "ВСЕГО " + v-header-name + " " + buf_goods.gds-name  @ buf_goods.gds-name
      v-total-cli-qnty @ buf_parts.cli-qnty
      v-total-fact-qnty @ buf_parts.fact-qnty
      buf_units.long-name
      with frame input-frm .
    down stream PrnLibStream 1 with frame input-frm .
    put stream PrnLibStream
      SKIP(2)
      .
  end.
  hide frame input-frm .
  assign
    v-header-name = "РАСХОДЫ "
  .
  run next-page in this-procedure .
  define frame output-frm
    buf_goods.gds-name     format "x(52)" column-label "ТОВАР"
    buf_trn-doc.fact-date                 column-label "ДАТА"
    buf_doc-line.fact-qnty                column-label "КОЛ-ВО"
    buf_units.long-name    format "x(20)" column-label "ЕД.ИЗМ."
    with width 160 down stream-io use-text .
  form with frame output-frm .
  for each gds-list no-lock
  ,first buf_goods no-lock
    where buf_goods.artic     = gds-list.artic
      and buf_goods.prod-type = gds-list.prod-type
      and buf_goods.prod-code = gds-list.prod-code
  :
    find first buf_units no-lock
      where buf_units.unit-name = buf_goods.unit-base
      .
    assign
      v-ind = v-ind + 1
    .
    process events .
    run waitfram-show in this-procedure ( "Линий обработано: " + string(v-ind) ) .
    assign
      v-total-fact-qnty = 0
    .
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type  = p-curr-obj-type
        and buf_doc-line.obj-code  = p-curr-obj-code
        and buf_doc-line.artic     = buf_goods.artic
        and buf_doc-line.prod-type = buf_goods.prod-type
        and buf_doc-line.prod-code = buf_goods.prod-code
        and buf_doc-line.status_   = 'факт':U
    , first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
        and buf_trn-doc.doc-type = 'рас':U
        and buf_trn-doc.internal = false
        and buf_trn-doc.fact-date >= v-first-date
        and buf_trn-doc.fact-date <= v-last-date
    :
      display stream PrnLibStream
        buf_goods.gds-name
        buf_trn-doc.fact-date
        buf_doc-line.fact-qnty
        buf_units.long-name
        with frame output-frm .
      down stream PrnLibStream 1 with frame output-frm .
      assign
        v-total-fact-qnty = v-total-fact-qnty + buf_doc-line.fact-qnty
      .
    end.
    display stream PrnLibStream
      "ВСЕГО " + v-header-name + " " + buf_goods.gds-name  @ buf_goods.gds-name
      v-total-fact-qnty @ buf_doc-line.fact-qnty
      buf_units.long-name
      with frame output-frm .
    down stream PrnLibStream 1 with frame output-frm .
    put stream PrnLibStream
      SKIP(2)
      .
  end.
  hide frame output-frm .
  assign
    v-header-name = "ОСТАТОК НА КОНЕЦ МЕСЯЦА"
  .
  run next-page in this-procedure .
  define frame stock-frm
    buf_goods.gds-name      format "x(52)" column-label "ТОВАР"
    var-Quantity        column-label "КОЛ-ВО"
    buf_units.long-name     format "x(20)" column-label "ЕД.ИЗМ."
    with width 160 down stream-io use-text .
  form with frame stock-frm .
  for each gds-list no-lock
  ,first buf_goods no-lock
    where buf_goods.artic     = gds-list.artic
      and buf_goods.prod-type = gds-list.prod-type
      and buf_goods.prod-code = gds-list.prod-code
  :
    find first buf_units no-lock
      where buf_units.unit-name = buf_goods.unit-base
      .
    assign
      v-ind = v-ind + 1
    .
    process events .
    run waitfram-show in this-procedure ( "Линий обработано: " + string(v-ind) ) .
    assign
      v-total-fact-qnty = 0
    .
    for each obj-list:
        delete obj-list.
    end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input ub.clients.obj-type ,
   input ub.clients.obj-code )
   .
    assign
      var-x-p-curr-obj-code  = ub.clients.obj-code
      var-x-p-curr-obj-type  = ub.clients.obj-type
      var-x-date-start  = v-last-date
      var-x-date-endt   = ?
      var-x-sum-type    = 'cost':U
      var-x-cat-id      = '##,##':U
      var-xTog-obj      = yes
    .
    run ostatok   (input var-x-p-curr-obj-code,
                   input var-x-p-curr-obj-type,
                   input no,
                   input var-x-date-start,
                   input var-x-date-endt ,
                   input ?               ,
                   input ?               ,
                   input var-x-sum-type  ,
                   input var-x-cat-id    ,
                   input var-xTog-obj    ,
                   output var-Quantity   ,
                   output var-Coast_R    ,
                   output var-Coast_V    ,
                   output var-VAT_R      ,
                   output var-VAT_V      ,
                   output var-Fact-order ).
   ASSIGN var-x-artic     = buf_goods.artic
          var-x-prod-code = buf_goods.prod-code
          var-x-prod-type = buf_goods.prod-type.
   RUN ost-line  (
      input   var-x-p-curr-obj-code,
      input   var-x-p-curr-obj-type,
      INPUT   var-x-artic     ,
      INPUT   var-x-prod-code ,
      INPUT   var-x-prod-type ,
      input   no              ,
      INPUT   var-Fact-order  ,
      input   var-x-sum-type  ,
      input   var-x-cat-id    ,
      input   var-xTog-obj    ,
      output  var-Quantity    ,
      output  var-Coast_R     ,
      output  var-Coast_V     ,
      output  var-VAT_R       ,
      output  var-VAT_V       ,
      output  var-SLT_R       ,
      output  var-SLT_V       ).
    display stream PrnLibStream
      "ОСТАТОК " + buf_goods.gds-name @ buf_goods.gds-name
      var-Quantity
      buf_units.long-name
      with frame stock-frm .
    down stream PrnLibStream 1 with frame stock-frm .
    put stream PrnLibStream
      SKIP(2)
      .
  end.
  hide frame stock-frm .
  run on-same-page in this-procedure (input 2) .
  put stream PrnLibStream
    v-line  skip
    space(10) "Всего страниц" page-number(PrnLibStream) skip
    .
  hide stream PrnLibStream frame bottomframe .
  output stream PrnLibStream close.
  run waitfram-hide in this-procedure .
  run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
end.
procedure on-same-page :
  define input parameter p-line-number as integer no-undo .
  if p-line-number > page-size( PrnLibStream ) then do:
    return .
  end.
  if line-counter( PrnLibStream ) + p-line-number > page-size( PrnLibStream ) then do:
    page stream PrnLibStream .
  end.
end procedure.
procedure next-page :
  page stream PrnLibStream .
end procedure.
