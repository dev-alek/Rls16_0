block-level on error undo, throw.
define input parameter p-wth-money as logical no-undo.
define input parameter p-wth-ser   as logical no-undo.
define input parameter p-wth-un    as logical no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-wth-mv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-wth-mv.p $":U .
define variable vss-description as character no-undo init "Отчет по движению МЦ".
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
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
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
define variable vss-include-info3 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_p-fmt_string-part no-undo
    field str-key       as integer
    field string-part   as character
    index pi is primary unique
        str-key
.
define variable v-p-fmt-3-str-key    as integer      no-undo.
FUNCTION center-field RETURNS INTEGER (INPUT iStartPix AS INTEGER, iEndPix AS INTEGER,
                                  iInput AS INTEGER).
  def var v-start-print as integer no-undo .
  if (iStartPix < 0) or (iEndPix < iStartPix) then return 0.
  assign
    v-start-print = INTEGER(iStartPix + ((iEndPix - iStartPix) / 2) - (iInput / 2))
  .
  RETURN v-start-print .
END FUNCTION.
FUNCTION right-field RETURNS INTEGER ( iEndPix AS INTEGER,
                                  iInput AS INTEGER).
  def var v-start-print as integer no-undo .
  assign
    v-start-print = INTEGER(iEndPix - 1 - iInput)
  .
  if v-start-print < 0 then return 0.
  RETURN v-start-print .
END FUNCTION.
function p-fmt-align-string returns character (
      p-in-string      as character
    , p-page-width     as integer
    , p-align-type     as character
).
    define variable v-string-length     as integer      no-undo.
    define variable v-out-string        as character    no-undo.
    assign
        v-string-length = length( trim( p-in-string ) )
    .
    if v-string-length >= p-page-width
    then do:
        assign
            v-out-string = trim( p-in-string )
        .
    end.
    else do:
        case p-align-type
        :
            when 'left':U
            then do:
                assign
                    v-out-string = trim( p-in-string )
                .
            end.
            when 'right':U
            then do:
                assign
                    v-out-string = fill( " ":U, p-page-width - v-string-length ) + trim( p-in-string )
                .
            end.
            when 'center':U
            then do:
                assign
                    v-out-string = fill( " ":U, integer( ( p-page-width - v-string-length ) / 2 ) ) + trim( p-in-string )
                .
            end.
        end case.
    end.
    return v-out-string .
end function.
procedure p-fmt-split-string :
define input parameter p-source-string  as character        no-undo.
define input parameter p-split-length   as integer          no-undo.
define output parameter p-string-1      as character        no-undo.
define output parameter p-string-2      as character        no-undo.
do
on error undo, return error
:
    define variable v-space-pos    as integer      no-undo.
    if length( p-source-string ) <= p-split-length
    then do:
        assign
            p-string-1 = p-source-string
        .
    end.
    else do:
        assign
            v-space-pos = r-index( p-source-string, " ":U, p-split-length )
        .
        if v-space-pos = 0
        then do:
            assign
                v-space-pos = index( p-source-string, " ":U )
            .
        end.
        if v-space-pos = 0
        then do:
            assign
                p-string-1 = substring( p-source-string, 1, p-split-length )
                p-string-2 = trim( substring( p-source-string, p-split-length, p-split-length ) )
            .
        end.
        else do:
            assign
                p-string-1 = substring( p-source-string, 1, v-space-pos )
                p-string-2 = trim( substring( p-source-string, v-space-pos ) )
            .
        end.
    end.
end.
end procedure.
procedure p-fmt-round :
define input parameter p-qnty               as decimal          no-undo.
define input parameter p-price-no-VAT       as decimal          no-undo.
define input parameter p-VAT                as decimal          no-undo.
define input parameter p-SLT                as decimal          no-undo.
define input parameter p-road-tax           as decimal          no-undo.
define output parameter p-new-price-no-VAT  as decimal          no-undo.
define output parameter p-new-VAT           as decimal          no-undo.
define output parameter p-new-SLT           as decimal          no-undo.
define output parameter p-new-sum-VAT       as decimal          no-undo.
define output parameter p-new-sum-SLT       as decimal          no-undo.
define output parameter p-new-sum-road-tax  as decimal          no-undo.
define output parameter p-new-sum-no-VAT    as decimal          no-undo.
define output parameter p-new-sum-full      as decimal          no-undo.
    define variable v-vat-pc    as decimal      no-undo.
    define variable v-slt-pc    as decimal      no-undo.
do
on error undo, return error
:
    if p-price-no-VAT = 0
    then do:
        assign
            p-new-price-no-VAT = 0.0
            p-new-VAT          = ?
            p-new-SLT          = ?
            p-new-sum-VAT      = 0.0
            p-new-sum-SLT      = 0.0
            p-new-sum-no-VAT   = 0.0
            p-new-sum-road-tax = 0.0
            p-new-sum-full     = 0.0
        .
    end.
    else do:
        assign
            v-vat-pc            = p-VAT / p-price-no-VAT
            v-slt-pc            = p-SLT / ( p-price-no-VAT + p-VAT )
            p-new-price-no-VAT  = round( p-price-no-VAT, 2 )
            p-new-VAT           = round( p-new-price-no-VAT * v-vat-pc, 2 )
            p-new-SLT           = round( ( p-new-price-no-VAT + p-new-VAT ) * v-slt-pc, 2 )
            p-new-sum-VAT       = round( p-new-VAT          * p-qnty, 2 )
            p-new-sum-SLT       = round( ( p-new-price-no-VAT + p-new-VAT ) * p-qnty * v-slt-pc, 2 )
            p-new-sum-no-VAT    = round( p-new-price-no-VAT * p-qnty, 2 )
            p-new-sum-road-tax  = round( p-road-tax * p-qnty, 2 )
            p-new-sum-full      = round( ( p-new-price-no-VAT + p-new-VAT + p-new-SLT + p-road-tax ) * p-qnty, 2 )
        .
    end.
end.
end procedure.
procedure p-fmt-split :
define input parameter p-in-string      as character        no-undo.
define input parameter p-split-length   as integer          no-undo.
    define variable v-start-pos     as integer      no-undo.
    define variable v-end-pos       as integer      no-undo.
    define buffer buf_temp_p-fmt_string-part        for temp_p-fmt_string-part.
do
for buf_temp_p-fmt_string-part
on error undo, return error
:
    empty temp-table buf_temp_p-fmt_string-part.
    if p-split-length < 1
    then do:
        undo, return error substitute( "p-fmt-split: Строка не может быть разбита на &1 частей", p-split-length ).
    end.
    assign
        p-in-string                 = trim( p-in-string )
        v-p-fmt-3-str-key   = 0
        v-start-pos                 = 1
        v-end-pos                   = length( p-in-string )
    .
    run p-fmt-get-string-range in this-procedure (
          input p-in-string
        , input p-split-length
        , input v-start-pos
        , output v-start-pos
        , output v-end-pos
    ).
    do while v-end-pos <> 0
    :
        create buf_temp_p-fmt_string-part.
        assign
            v-p-fmt-3-str-key = v-p-fmt-3-str-key + 1
        .
        assign
            buf_temp_p-fmt_string-part.str-key      = v-p-fmt-3-str-key
            buf_temp_p-fmt_string-part.string-part  = substring( p-in-string, v-start-pos, v-end-pos - v-start-pos )
        .
        assign
            v-start-pos = v-end-pos + 1
        .
        run p-fmt-get-string-range in this-procedure (
              input p-in-string
            , input p-split-length
            , input v-start-pos
            , output v-start-pos
            , output v-end-pos
        ).
    end.
end.
end procedure.
procedure p-fmt-get-string-range :
define input parameter p-in-string      as character        no-undo.
define input parameter p-split-length   as integer          no-undo.
define input parameter p-old-start-pos  as integer          no-undo.
define output parameter p-start-pos     as integer          no-undo.
define output parameter p-end-pos       as integer          no-undo.
    define variable v-init-string    as character    no-undo.
    define variable v-temp-char      as character    no-undo.
    define variable v-temp-pos       as integer      no-undo.
    define variable v-counter        as integer      no-undo.
do
on error undo, return error
:
    assign
        p-start-pos   = p-old-start-pos
        v-init-string = substring( p-in-string, p-start-pos )
    no-error.
    if error-status :error
    or trim( v-init-string ) = "":U
    then do:
        assign
            p-end-pos = 0
        .
        undo, return .
    end.
    assign
        v-temp-char   = substring( v-init-string, 1, 1 )
    .
    do
    while trim( v-temp-char ) = "":U
    :
        assign
            p-start-pos     = p-start-pos + 1
            v-init-string   = substring( p-in-string, p-start-pos )
            v-temp-char     = substring( v-init-string, 1, 1 )
        .
    end.
    assign
        v-temp-pos  = p-split-length
        v-temp-char = substring( v-init-string, v-temp-pos, 1 )
        v-counter   = 0
    .
    search-word-end:
    do
    while trim( v-temp-char ) <> "":U
    :
        assign
            v-counter   = v-counter + 1
        .
        if v-counter > 20
        then do:
            assign
                v-temp-pos  = p-split-length
            .
            leave search-word-end.
        end.
        assign
            v-temp-pos  = v-temp-pos - 1
            v-temp-char = substring( v-init-string, v-temp-pos, 1 )
        .
    end.
    assign
        p-end-pos = p-start-pos + v-temp-pos - 1
    .
end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable gdsgrp_recids      as character no-undo.
define  shared variable fin-schet-recid    as character no-undo.
define  shared variable v-d-report-handle  as handle    no-undo .
define  shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define  shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define  shared temp-table tmp#grp no-undo
    field node-code like ub.gds-grp.node-code
    field grp-name like ub.gds-grp.node-name
    field lvl-num  like ub.gds-grp.lvl-num
    field is-term  like ub.gds-grp.is-term
    index pi is unique primary grp-name node-code
    index i-node-code    node-code
    index level-num   lvl-num  grp-name
    index is-term is-term  grp-name
    .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared temp-table gds-list no-undo like ub.goods
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   shared  temp-table gds-list-hist no-undo
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
 shared
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
define  shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.
define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define   shared variable str1   as character  no-undo.
define   shared variable str2   as character  no-undo.
define   shared variable str3   as character  no-undo.
define   shared variable str4   as character  no-undo.
define   shared variable ReportNAme   as character  no-undo.
define   shared variable ReportProc   as character  no-undo.
define   shared variable ReportHeader as character  no-undo.
define   shared variable ReportPageWidth  as integer no-undo.
define   shared variable ReportPageHeight as integer no-undo.
define   shared variable ReportFontNum    as integer no-undo.
define   shared variable my-request as logical  init false no-undo.
define   shared variable v-delim as character no-undo .
define   shared variable v-sdate as character no-undo initial "/":U.
define   shared variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .
define   shared variable my-handle  as handle no-undo .
define   shared variable parent-handle  as handle no-undo .
define   shared variable v-show-all-goods as logical  no-undo .
define   shared variable params-only      as logical   no-undo .
define   shared variable params-only-mode as character no-undo .
define   shared variable place-call       as character no-undo .
define   shared variable x-Goods-Editor   as character  no-undo .
define   shared variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
define   shared variable x-Date-End       as date format "99/99/9999":u   no-undo .
define   shared variable x-Date-Start     as date format "99/99/9999":u   no-undo .
define   shared variable x-Shift-Alone    as integer format ">9":u         no-undo .
define   shared variable x-Shift-End      as integer format ">9":u         no-undo .
define   shared variable x-Shift-Start    as integer format ">9":u         no-undo .
define   shared variable x-SelectGood     as integer                      no-undo .
define   shared variable x-SelectObject   as character                          no-undo .
define   shared variable x-SET_PAY_TYPE   as integer  no-undo .
define   shared variable x-SET_val_TYPE   as integer  no-undo .
define   shared variable x-TOG-Shift      as logical  no-undo .
define   shared variable x-Radio-Task     as integer  no-undo .
define   shared variable x-TOG-Excel      as logical  no-undo .
define   shared variable x-TOG-list-hist  as logical  no-undo .
define   shared variable x-text-1 as character  no-undo .
define   shared variable x-text-2 as character  no-undo .
define   shared variable x-text-3 as character  no-undo .
define   shared variable x-text-4 as character  no-undo .
define   shared variable init-date-start  like x-date-start  no-undo .
define   shared variable init-date-end    like x-date-end    no-undo .
define   shared variable init-date-alone  like x-date-alone  no-undo .
define   shared variable init-shift-alone like x-shift-alone no-undo .
define   shared variable init-shift-start like x-shift-start no-undo .
define   shared variable init-shift-end   like x-shift-end   no-undo .
define   shared variable init-set_pay_type like x-set_pay_type   no-undo .
define   shared variable init-set_val_type like x-set_val_type   no-undo .
define   shared variable ref_date-start    as character   no-undo .
define   shared variable ref_date-end      as character   no-undo .
define   shared variable ref_date-alone    as character   no-undo .
define   shared work-table TDEDT  no-undo
  field id as char
  field name as character  format "x(40)"
  field n as character
  .
define variable tempstr as character  no-undo.
define variable b1-name as character  no-undo.
define variable b2-name as character  no-undo.
define variable source-str   as character no-undo .
define variable I#           as integer    no-undo.
define variable p-price-med  as decimal init 0 no-undo .
define   shared variable str-obj-type as character  no-undo.
define   shared variable str-obj-code as character  no-undo.
define   shared variable str-obj-name as character  no-undo.
define   shared variable str-obj      as character  no-undo.
define   shared variable link#        as logical  no-undo init false.
define   shared variable  Verify-Arc-ot      as logical  no-undo init false.
define   shared variable  Verify-Arc-stk     as logical  no-undo init false.
define   shared variable  Verify-Arc-supp    as logical  no-undo init false.
define   shared variable  Verify-Arc-hold    as logical  no-undo init false.
define   shared variable  Verify-Arc-aht     as logical  no-undo init false.
define   shared variable  Verify-send-check  as logical  no-undo init false.
define   shared variable  Verify-Arc-fin     as logical  no-undo init false.
define   shared variable  Verify-Arc-strong  as logical  no-undo init false.
define   shared variable  Show-Crsa         as logical  no-undo init false.
define   shared variable  Show-Cost         as logical  no-undo init false.
define   shared variable  Show-Sale         as logical  no-undo init false.
define   shared variable  Name-Sale-price   as character no-undo .
define   shared variable  Format-Folder     as logical no-undo .
define   shared variable  Print-List-Hist   as logical no-undo init false.
define   shared variable Make-Excel     as logical  no-undo init false.
define   shared variable Make-Excel-com as logical  no-undo init false.
define   shared stream ForExcel.
define   shared variable Use-column   as logical extent 256 no-undo .
define   shared variable right-column as logical extent 256 no-undo .
define shared  temp-table Sheetf no-undo
field Excel-Column-Lable as character
field Excel-Row-Heder    as integer
field Excel-Row-Title    as integer
field Sizes              as character
field Make-correct       as character
field Rights-column      as character
field MergeCellsH        as character
field MergeCellsV        as character
field sheet-num          as integer
field ColFormat          as character
field Bas-FIle           as character
field Bas-Params         as character
field Bas-Param-Add      as logical
field File-name          as character
field Silent-save        as logical
index pi as primary unique
      sheet-num
.
find first sheetf where sheet-num = 1 no-error.
define variable l-stroka as character no-undo .
define   shared  variable ch#ExcelApplication as com-handle no-undo .
define   shared  variable ch#Workbook         as com-handle no-undo .
define   shared  variable ch#Worksheet        as com-handle no-undo .
define   shared  variable Num#Str#            as integer no-undo.
define   shared  variable Number-List         as integer no-undo init 1.
define   shared  variable v-excel-file        as character no-undo .
define variable Col-name as character  extent 256.
define variable Col-format as character  extent 256.
define variable Col-Post-format as character  extent 256.
run proc-page0-assign in this-procedure .
procedure proc-page0-assign :
 do
 on error undo, return error return-value
 :
Assign
  Col-name[1] = 'A':U
  Col-name[2] = 'B':U
  Col-name[3] = 'C':U
  Col-name[4] = 'D':U
  Col-name[5] = 'E':U
  Col-name[6] = 'F':U
  Col-name[7] = 'G':U
  Col-name[8] = 'H':U
  Col-name[9] = 'I':U
  Col-name[10]= 'J':U
  Col-name[11]= 'K':U
  Col-name[12]= 'L':U
  Col-name[13]= 'M':U
  Col-name[14]= 'N':U
  Col-name[15]= 'O':U
  Col-name[16]= 'P':U
  Col-name[17]= 'Q':U
  Col-name[18]= 'R':U
  Col-name[19]= 'S':U
  Col-name[20]= 'T':U
  Col-name[21]= 'U':U
  Col-name[22]= 'V':U
  Col-name[23]= 'W':U
  Col-name[24]= 'X':U
  Col-name[25]= 'Y':U
  Col-name[26]= 'Z':U
  Col-name[27]= 'AA':U
  Col-name[28]= 'AB':U
  Col-name[29]= 'AC':U
  Col-name[30]= 'AD':U
  Col-name[31]= 'AE':U
  Col-name[32]= 'AF':U
  Col-name[33]= 'AG':U
  Col-name[34]= 'AH':U
  Col-name[35]= 'AI':U
  Col-name[36]= 'AJ':U
  Col-name[37]= 'AK':U
  Col-name[38]= 'AL':U
  Col-name[39]= 'AM':U
  Col-name[40]= 'AN':U
  Col-name[41]= 'AO':U
  Col-name[42]= 'AP':U
  Col-name[43]= 'AQ':U
  Col-name[44]= 'AR':U
  Col-name[45]= 'AS':U
  Col-name[46]= 'AT':U
  Col-name[47]= 'AU':U
  Col-name[48]= 'AV':U
  Col-name[49]= 'AW':U
  Col-name[50]= 'AX':U
  Col-name[51]= 'AY':U
  Col-name[52]= 'AZ':U
  Col-name[53]= 'BA':U
  Col-name[54]= 'BB':U
  Col-name[55]= 'BC':U
  Col-name[56]= 'BD':U
  Col-name[57]= 'BE':U
  Col-name[58]= 'BF':U
  Col-name[59]= 'BG':U
  Col-name[60]= 'BH':U
  Col-name[61]= 'BI':U
  Col-name[62]= 'BJ':U
  Col-name[63]= 'BK':U
  Col-name[64]= 'BL':U
  Col-name[65]= 'BM':U
  Col-name[66]= 'BN':U
  Col-name[67]= 'BO':U
  Col-name[68]= 'BP':U
  Col-name[69]= 'BQ':U
  Col-name[70]= 'BR':U
  Col-name[71]= 'BS':U
  Col-name[72]= 'BT':U
  Col-name[73]= 'BU':U
  Col-name[74]= 'BV':U
  Col-name[75]= 'BW':U
  Col-name[76]= 'BX':U
  Col-name[77]= 'BY':U
  Col-name[78]= 'BZ':U
  Col-name[79]= 'CA':U
  Col-name[80]= 'CB':U
  Col-name[81]= 'CC':U
  Col-name[82]= 'CD':U
  Col-name[83]= 'CE':U
  Col-name[84]= 'CF':U
  Col-name[85]= 'CG':U
  Col-name[86]= 'CH':U
  Col-name[87]= 'CI':U
  Col-name[88]= 'CJ':U
  Col-name[89]= 'CK':U
  Col-name[90]= 'CL':U
  Col-name[91]= 'CM':U
  Col-name[92]= 'CN':U
  Col-name[93]= 'CO':U
  Col-name[94]= 'CP':U
  Col-name[95]= 'CQ':U
  Col-name[96]= 'CR':U
  Col-name[97]= 'CS':U
  Col-name[98]= 'CT':U
  Col-name[99]= 'CU':U
  Col-name[100]= 'CV':U
Col-name[101]= 'CW':U
Col-name[102]= 'CX':U
Col-name[103]= 'CY':U
Col-name[104]= 'CZ':U
Col-name[105]= 'DA':U
Col-name[106]= 'DB':U
Col-name[107]= 'DC':U
Col-name[108]= 'DD':U
Col-name[109]= 'DE':U
Col-name[110]= 'DF':U
Col-name[111]= 'DG':U
Col-name[112]= 'DH':U
Col-name[113]= 'DI':U
Col-name[114]= 'DJ':U
Col-name[115]= 'DK':U
Col-name[116]= 'DL':U
Col-name[117]= 'DM':U
Col-name[118]= 'DN':U
Col-name[119]= 'DO':U
Col-name[120]= 'DP':U
Col-name[121]= 'DQ':U
Col-name[122]= 'DR':U
Col-name[123]= 'DS':U
Col-name[124]= 'DT':U
Col-name[125]= 'DU':U
Col-name[126]= 'DV':U
Col-name[127]= 'DW':U
Col-name[128]= 'DX':U
Col-name[129]= 'DY':U
Col-name[130]= 'DZ':U
Col-name[131]= 'EA':U
Col-name[132]= 'EB':U
Col-name[133]= 'EC':U
Col-name[134]= 'ED':U
Col-name[135]= 'EE':U
Col-name[136]= 'EF':U
Col-name[137]= 'EG':U
Col-name[138]= 'EH':U
Col-name[139]= 'EI':U
Col-name[140]= 'EJ':U
Col-name[141]= 'EK':U
Col-name[142]= 'EL':U
Col-name[143]= 'EM':U
Col-name[144]= 'EN':U
Col-name[145]= 'EO':U
Col-name[146]= 'EP':U
Col-name[147]= 'EQ':U
Col-name[148]= 'ER':U
Col-name[149]= 'ES':U
Col-name[150]= 'ET':U
Col-name[151]= 'EU':U
Col-name[152]= 'EV':U
Col-name[153]= 'EW':U
Col-name[154]= 'EX':U
Col-name[155]= 'EY':U
Col-name[156]= 'EZ':U
Col-name[157]= 'FA':U
.
assign
  Col-name[158]= 'FB':U
  Col-name[159]= 'FC':U
  Col-name[160]= 'FD':U
  Col-name[161]= 'FE':U
  Col-name[162]= 'FF':U
  Col-name[163]= 'FG':U
  Col-name[164]= 'FH':U
  Col-name[165]= 'FI':U
  Col-name[166]= 'FJ':U
  Col-name[167]= 'FK':U
  Col-name[168]= 'FL':U
  Col-name[169]= 'FM':U
  Col-name[170]= 'FN':U
  Col-name[171]= 'FO':U
  Col-name[172]= 'FP':U
  Col-name[173]= 'FQ':U
  Col-name[174]= 'FR':U
  Col-name[175]= 'FS':U
  Col-name[176]= 'FT':U
  Col-name[177]= 'FU':U
  Col-name[178]= 'FV':U
  Col-name[179]= 'FW':U
  Col-name[180]= 'FX':U
  Col-name[181]= 'FY':U
  Col-name[182]= 'FZ':U
  Col-name[183]= 'GA':U
  Col-name[184]= 'GB':U
  Col-name[185]= 'GC':U
  Col-name[186]= 'GD':U
  Col-name[187]= 'GE':U
  Col-name[188]= 'GF':U
  Col-name[189]= 'GG':U
  Col-name[190]= 'GH':U
  Col-name[191]= 'GI':U
  Col-name[192]= 'GJ':U
  Col-name[193]= 'GK':U
  Col-name[194]= 'GL':U
  Col-name[195]= 'GM':U
  Col-name[196]= 'GN':U
  Col-name[197]= 'GO':U
  Col-name[198]= 'GP':U
  Col-name[199]= 'GQ':U
  Col-name[200]=   'GR':U
  Col-name[201]=   'GS':U
  Col-name[202]=   'GT':U
  Col-name[203]=   'GU':U
  Col-name[204]=   'GV':U
  Col-name[205]=   'GW':U
  Col-name[206]=   'GX':U
  Col-name[207]=   'GY':U
  Col-name[208]=   'GZ':U
  Col-name[209]=   'HA':U
  Col-name[210]=   'HB':U
  Col-name[211]=   'HC':U
  Col-name[212]=   'HD':U
  Col-name[213]=   'HE':U
  Col-name[214]=   'HF':U
  Col-name[215]=   'HG':U
  Col-name[216]=   'HH':U
  Col-name[217]=   'HI':U
  Col-name[218]=   'HJ':U
  Col-name[219]=   'HK':U
  Col-name[220]=   'HL':U
  Col-name[221]=   'HM':U
  Col-name[222]=   'HN':U
  Col-name[223]=   'HO':U
  Col-name[224]=   'HP':U
  Col-name[225]=   'HQ':U
  Col-name[226]=   'HR':U
  Col-name[227]=   'HS':U
  Col-name[228]=   'HT':U
  Col-name[229]=   'HU':U
  Col-name[230]=   'HV':U
  Col-name[231]=   'HW':U
  Col-name[232]=   'HX':U
  Col-name[233]=   'HY':U
  Col-name[234]=   'HZ':U
  Col-name[235]=   'IA':U
  Col-name[236]=   'IB':U
  Col-name[237]=   'IC':U
  Col-name[238]=   'ID':U
  Col-name[239]=   'IE':U
  Col-name[240]=   'IF':U
  Col-name[241]=   'IG':U
  Col-name[242]=   'IH':U
  Col-name[243]=   'II':U
  Col-name[244]=   'IJ':U
  Col-name[245]=   'IK':U
  Col-name[246]=   'IL':U
  Col-name[247]=   'IM':U
  Col-name[248]=   'IN':U
  Col-name[249]=   'IO':U
  Col-name[250]=   'IP':U
  Col-name[251]=   'IQ':U
  Col-name[252]=   'IR':U
  Col-name[253]=   'IS':U
  Col-name[254]=   'IT':U
  Col-name[255]=   'IU':U
  Col-name[256]=   'IV':U
  .
 end.
end procedure.
define variable var-report-r-b as character no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure wth-lib_cur-stock-place:
define input  parameter parobj-type like ub.clients.obj-type   no-undo.
define input  parameter parobj-code like ub.clients.obj-code   no-undo.
define input  parameter parw-p-code like ub.wth-pobj.w-p-code  no-undo.
define input  parameter parwth-code like ub.wth-pobj.wth-code  no-undo.
define output parameter parstock    like ub.wth-pobj.income-pl no-undo.
define buffer bf_wth-pobj for ub.wth-pobj.
find first bf_wth-pobj where bf_wth-pobj.obj-type = parobj-type and
                             bf_wth-pobj.obj-code = parobj-code and
                             bf_wth-pobj.w-p-code = parw-p-code and
                             bf_wth-pobj.wth-code = parwth-code no-lock no-error.
if available bf_wth-pobj then assign parstock = bf_wth-pobj.income-pl - bf_wth-pobj.incass-pl.
                         else assign parstock = 0.
end procedure.
procedure wth-lib_cur-stock-obj:
define input  parameter parobj-type like ub.clients.obj-type   no-undo.
define input  parameter parobj-code like ub.clients.obj-code   no-undo.
define input  parameter parwth-code like ub.wth-obj.wth-code   no-undo.
define output parameter parstock    like ub.wth-obj.income     no-undo.
define buffer bf_wth-obj for ub.wth-obj.
find first bf_wth-obj where bf_wth-obj.obj-type = parobj-type and
                            bf_wth-obj.obj-code = parobj-code and
                            bf_wth-obj.wth-code = parwth-code no-lock no-error.
if available bf_wth-obj then assign parstock = bf_wth-obj.income - bf_wth-obj.incass.
                        else assign parstock = 0.
end.
FUNCTION wth-lib_cur-stock-obj-func RETURNS DECIMAL (INPUT parobj-type AS CHARACTER,
                                                     INPUT parobj-code AS INTEGER,
                                                     INPUT parwth-code AS INTEGER):
define buffer bf_wth-obj for ub.wth-obj.
find first bf_wth-obj where bf_wth-obj.obj-type = parobj-type and
                            bf_wth-obj.obj-code = parobj-code and
                            bf_wth-obj.wth-code = parwth-code no-lock no-error.
if available bf_wth-obj then return (bf_wth-obj.income - bf_wth-obj.incass).
                        else return 0.00.
end function.
FUNCTION wth-lib_cur-stock-host-func RETURNS DECIMAL (INPUT parhost-code AS INTEGER,
                                                      INPUT parwth-code  AS INTEGER):
define buffer bf_wth-obj for ub.wth-obj.
define variable v-stock like ub.wth-obj.income no-undo.
for each bf_wth-obj no-lock where bf_wth-obj.host-code = parhost-code and
                                  bf_wth-obj.wth-code = parwth-code :
  v-stock = v-stock +  bf_wth-obj.income - bf_wth-obj.incass.
end.
return v-stock.
end function.
procedure wth-lib_full-inf-shift:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num    like ub.shift-obj.shift-num   no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                                                                                       cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.shift-date = parshift-date and                        cur_wth-line.shift-num  = parshift-num  and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sdn no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                                                                             start_wth-line.wth-code   = parwth-code         and                                (start_wth-line.shift-date = parshift-date and                           start_wth-line.shift-num  < parshift-num  or                            start_wth-line.shift-date < parshift-date ) and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sdn no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income - cur_wth-line.incass              parincome        = cur_wth-line.income                     parincome-cassa  = cur_wth-line.income-cassa               parincome-other  = cur_wth-line.income-other               parincass        = cur_wth-line.incass                     parincass-bank   = cur_wth-line.incass-bank                parincass-other  = cur_wth-line.incass-other.              parincass-cassa  = cur_wth-line.incass-cassa.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income     - start_wth-line.incass               parstock-end     = cur_wth-line.income       - cur_wth-line.incass                 parincome        = cur_wth-line.income       - start_wth-line.income               parincome-cassa  = cur_wth-line.income-cassa - start_wth-line.income-cassa         parincome-other  = cur_wth-line.income-other - start_wth-line.income-other         parincass        = cur_wth-line.incass       - start_wth-line.incass               parincass-bank   = cur_wth-line.incass-bank  - start_wth-line.incass-bank          parincass-other  = cur_wth-line.incass-other - start_wth-line.incass-other.        parincass-cassa  = cur_wth-line.incass-cassa - start_wth-line.incass-cassa.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income - start_wth-line.incass                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-inter:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num    like ub.shift-obj.shift-num   no-undo.                        define input  parameter parshift-date1  like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num1   like ub.shift-obj.shift-num   no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                                                                                       cur_wth-line.wth-code   = parwth-code   and                                        ((cur_wth-line.shift-date = parshift-date1 and                           cur_wth-line.shift-num  <= parshift-num1)  or                            cur_wth-line.shift-date < parshift-date1 ) and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sdn no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                                                                             start_wth-line.wth-code   = parwth-code         and                                (start_wth-line.shift-date = parshift-date and                           start_wth-line.shift-num  < parshift-num  or                            start_wth-line.shift-date < parshift-date ) and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sdn no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income - cur_wth-line.incass              parincome        = cur_wth-line.income                     parincome-cassa  = cur_wth-line.income-cassa               parincome-other  = cur_wth-line.income-other               parincass        = cur_wth-line.incass                     parincass-bank   = cur_wth-line.incass-bank                parincass-other  = cur_wth-line.incass-other.              parincass-cassa  = cur_wth-line.incass-cassa.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income     - start_wth-line.incass               parstock-end     = cur_wth-line.income       - cur_wth-line.incass                 parincome        = cur_wth-line.income       - start_wth-line.income               parincome-cassa  = cur_wth-line.income-cassa - start_wth-line.income-cassa         parincome-other  = cur_wth-line.income-other - start_wth-line.income-other         parincass        = cur_wth-line.incass       - start_wth-line.incass               parincass-bank   = cur_wth-line.incass-bank  - start_wth-line.incass-bank          parincass-other  = cur_wth-line.incass-other - start_wth-line.incass-other.        parincass-cassa  = cur_wth-line.incass-cassa - start_wth-line.incass-cassa.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income - start_wth-line.incass                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-period-place:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parw-p-code     like ub.wth-pobj.w-p-code  no-undo.                        define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num    like ub.shift-obj.shift-num   no-undo.                        define input  parameter parshift-date1  like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num1   like ub.shift-obj.shift-num   no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                        cur_wth-line.w-p-code = parw-p-code and                                                               cur_wth-line.wth-code   = parwth-code   and                                        ((cur_wth-line.shift-date = parshift-date1 and                           cur_wth-line.shift-num  <= parshift-num1)  or                            cur_wth-line.shift-date < parshift-date1 ) and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sdn no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                start_wth-line.w-p-code = parw-p-code and                                                             start_wth-line.wth-code   = parwth-code         and                                (start_wth-line.shift-date = parshift-date and                           start_wth-line.shift-num  < parshift-num  or                            start_wth-line.shift-date < parshift-date ) and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sdn no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income-pl - cur_wth-line.incass-pl              parincome        = cur_wth-line.income-pl                     parincome-cassa  = cur_wth-line.income-cassa-pl               parincome-other  = cur_wth-line.income-other-pl               parincass        = cur_wth-line.incass-pl                     parincass-bank   = cur_wth-line.incass-bank-pl                parincass-other  = cur_wth-line.incass-other-pl.              parincass-cassa  = cur_wth-line.incass-cassa-pl.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income-pl     - start_wth-line.incass-pl               parstock-end     = cur_wth-line.income-pl       - cur_wth-line.incass-pl                 parincome        = cur_wth-line.income-pl       - start_wth-line.income-pl               parincome-cassa  = cur_wth-line.income-cassa-pl - start_wth-line.income-cassa-pl         parincome-other  = cur_wth-line.income-other-pl - start_wth-line.income-other-pl         parincass        = cur_wth-line.incass-pl       - start_wth-line.incass-pl               parincass-bank   = cur_wth-line.incass-bank-pl  - start_wth-line.incass-bank-pl          parincass-other  = cur_wth-line.incass-other-pl - start_wth-line.incass-other-pl.        parincass-cassa  = cur_wth-line.incass-cassa-pl - start_wth-line.incass-cassa-pl.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income-pl - start_wth-line.incass-pl                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-place:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input parameter parw-p-code   like ub.wth-line.w-p-code     no-undo.                        define input parameter parshift-date like ub.shift-obj.shift-date  no-undo.                        define input parameter parshift-num  like ub.shift-obj.shift-num   no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                        cur_wth-line.w-p-code   = parw-p-code and                                                               cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.shift-date = parshift-date and                        cur_wth-line.shift-num  = parshift-num  and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sdn-pl no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                start_wth-line.w-p-code = parw-p-code and                                                             start_wth-line.wth-code   = parwth-code         and                                (start_wth-line.shift-date = parshift-date and                           start_wth-line.shift-num  < parshift-num  or                            start_wth-line.shift-date < parshift-date ) and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sdn-pl no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income-pl - cur_wth-line.incass-pl              parincome        = cur_wth-line.income-pl                     parincome-cassa  = cur_wth-line.income-cassa-pl               parincome-other  = cur_wth-line.income-other-pl               parincass        = cur_wth-line.incass-pl                     parincass-bank   = cur_wth-line.incass-bank-pl                parincass-other  = cur_wth-line.incass-other-pl.              parincass-cassa  = cur_wth-line.incass-cassa-pl.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income-pl     - start_wth-line.incass-pl               parstock-end     = cur_wth-line.income-pl       - cur_wth-line.incass-pl                 parincome        = cur_wth-line.income-pl       - start_wth-line.income-pl               parincome-cassa  = cur_wth-line.income-cassa-pl - start_wth-line.income-cassa-pl         parincome-other  = cur_wth-line.income-other-pl - start_wth-line.income-other-pl         parincass        = cur_wth-line.incass-pl       - start_wth-line.incass-pl               parincass-bank   = cur_wth-line.incass-bank-pl  - start_wth-line.incass-bank-pl          parincass-other  = cur_wth-line.incass-other-pl - start_wth-line.incass-other-pl.        parincass-cassa  = cur_wth-line.incass-cassa-pl - start_wth-line.incass-cassa-pl.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income-pl - start_wth-line.incass-pl                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-date:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                                                                                       cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.shift-date = parshift-date   and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sd no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                                                                             start_wth-line.wth-code   = parwth-code         and                                start_wth-line.shift-date < parshift-date and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sd no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income - cur_wth-line.incass              parincome        = cur_wth-line.income                     parincome-cassa  = cur_wth-line.income-cassa               parincome-other  = cur_wth-line.income-other               parincass        = cur_wth-line.incass                     parincass-bank   = cur_wth-line.incass-bank                parincass-other  = cur_wth-line.incass-other.              parincass-cassa  = cur_wth-line.incass-cassa.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income     - start_wth-line.incass               parstock-end     = cur_wth-line.income       - cur_wth-line.incass                 parincome        = cur_wth-line.income       - start_wth-line.income               parincome-cassa  = cur_wth-line.income-cassa - start_wth-line.income-cassa         parincome-other  = cur_wth-line.income-other - start_wth-line.income-other         parincass        = cur_wth-line.incass       - start_wth-line.incass               parincass-bank   = cur_wth-line.incass-bank  - start_wth-line.incass-bank          parincass-other  = cur_wth-line.incass-other - start_wth-line.incass-other.        parincass-cassa  = cur_wth-line.incass-cassa - start_wth-line.incass-cassa.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income - start_wth-line.incass                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-date-place:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input parameter parw-p-code   like ub.wth-line.w-p-code     no-undo.                        define input parameter parshift-date like ub.shift-obj.shift-date  no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                        cur_wth-line.w-p-code   = parw-p-code and                                                               cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.shift-date = parshift-date   and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sd-pl no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                start_wth-line.w-p-code = parw-p-code and                                                             start_wth-line.wth-code   = parwth-code         and                                start_wth-line.shift-date < parshift-date and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sd-pl no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income-pl - cur_wth-line.incass-pl              parincome        = cur_wth-line.income-pl                     parincome-cassa  = cur_wth-line.income-cassa-pl               parincome-other  = cur_wth-line.income-other-pl               parincass        = cur_wth-line.incass-pl                     parincass-bank   = cur_wth-line.incass-bank-pl                parincass-other  = cur_wth-line.incass-other-pl.              parincass-cassa  = cur_wth-line.incass-cassa-pl.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income-pl     - start_wth-line.incass-pl               parstock-end     = cur_wth-line.income-pl       - cur_wth-line.incass-pl                 parincome        = cur_wth-line.income-pl       - start_wth-line.income-pl               parincome-cassa  = cur_wth-line.income-cassa-pl - start_wth-line.income-cassa-pl         parincome-other  = cur_wth-line.income-other-pl - start_wth-line.income-other-pl         parincass        = cur_wth-line.incass-pl       - start_wth-line.incass-pl               parincass-bank   = cur_wth-line.incass-bank-pl  - start_wth-line.incass-bank-pl          parincass-other  = cur_wth-line.incass-other-pl - start_wth-line.incass-other-pl.        parincass-cassa  = cur_wth-line.incass-cassa-pl - start_wth-line.incass-cassa-pl.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income-pl - start_wth-line.incass-pl                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-calend-date:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parfact-date    like ub.wth-line.fact-date    no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                                                                                       cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.fact-date  = parfact-date  and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-cld no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                                                                             start_wth-line.wth-code   = parwth-code         and                                start_wth-line.fact-date  < parfact-date   and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-cld no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income - cur_wth-line.incass              parincome        = cur_wth-line.income                     parincome-cassa  = cur_wth-line.income-cassa               parincome-other  = cur_wth-line.income-other               parincass        = cur_wth-line.incass                     parincass-bank   = cur_wth-line.incass-bank                parincass-other  = cur_wth-line.incass-other.              parincass-cassa  = cur_wth-line.incass-cassa.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income     - start_wth-line.incass               parstock-end     = cur_wth-line.income       - cur_wth-line.incass                 parincome        = cur_wth-line.income       - start_wth-line.income               parincome-cassa  = cur_wth-line.income-cassa - start_wth-line.income-cassa         parincome-other  = cur_wth-line.income-other - start_wth-line.income-other         parincass        = cur_wth-line.incass       - start_wth-line.incass               parincass-bank   = cur_wth-line.incass-bank  - start_wth-line.incass-bank          parincass-other  = cur_wth-line.incass-other - start_wth-line.incass-other.        parincass-cassa  = cur_wth-line.incass-cassa - start_wth-line.incass-cassa.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income - start_wth-line.incass                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-calend-date-place:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input parameter parw-p-code  like ub.wth-line.w-p-code  no-undo.                        define input parameter parfact-date like ub.wth-line.fact-date no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                        cur_wth-line.w-p-code   = parw-p-code and                                                               cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.fact-date  = parfact-date  and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-cld-pl no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                start_wth-line.w-p-code = parw-p-code and                                                             start_wth-line.wth-code   = parwth-code         and                                start_wth-line.fact-date  < parfact-date   and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-cld-pl no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income-pl - cur_wth-line.incass-pl              parincome        = cur_wth-line.income-pl                     parincome-cassa  = cur_wth-line.income-cassa-pl               parincome-other  = cur_wth-line.income-other-pl               parincass        = cur_wth-line.incass-pl                     parincass-bank   = cur_wth-line.incass-bank-pl                parincass-other  = cur_wth-line.incass-other-pl.              parincass-cassa  = cur_wth-line.incass-cassa-pl.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income-pl     - start_wth-line.incass-pl               parstock-end     = cur_wth-line.income-pl       - cur_wth-line.incass-pl                 parincome        = cur_wth-line.income-pl       - start_wth-line.income-pl               parincome-cassa  = cur_wth-line.income-cassa-pl - start_wth-line.income-cassa-pl         parincome-other  = cur_wth-line.income-other-pl - start_wth-line.income-other-pl         parincass        = cur_wth-line.incass-pl       - start_wth-line.incass-pl               parincass-bank   = cur_wth-line.incass-bank-pl  - start_wth-line.incass-bank-pl          parincass-other  = cur_wth-line.incass-other-pl - start_wth-line.incass-other-pl.        parincass-cassa  = cur_wth-line.incass-cassa-pl - start_wth-line.incass-cassa-pl.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income-pl - start_wth-line.incass-pl                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
FUNCTION get-curr RETURNS CHARACTER
  (buffer loc-wealth for ub.wealth ) :
define buffer buf_currency for ub.currency.
if loc-wealth.curr-code = ? or loc-wealth.is-money = no then
return loc-wealth.unit-base.
FIND FIRST buf_currency no-lock where
          buf_currency.curr-code = loc-wealth.curr-code No-ERROR.
if avail buf_currency then
  RETURN buf_currency.curr-abbr.
else return "".
END FUNCTION.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in my-handle
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#gds-engl as logical   no-undo .
define variable vv-exch-rate  as decimal   no-undo .
define variable vv-exch-scale as decimal   no-undo .
define variable v-cntxt-host-name-obj as character no-undo .
if v-cntxt-level = 'object':U then do:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-cntxt-host-code-obj
  ,output v-cntxt-host-name-obj
  )  .
end.
if v-cntxt-level = 'firm':U then do:
  find first ub.clients no-lock where
             ub.clients.obj-type = 'орг':U and
             ub.clients.obj-code = v-cntxt-host-code-obj no-error .
if error-status :error then v-cntxt-host-name-obj = ? .
   else v-cntxt-host-name-obj = ub.clients.obj-name.
end.
if v-cntxt-level = 'object':U
or v-cntxt-level = 'firm':U
then do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  base-code
  ,input  today
  ,output vv-exch-rate
  ,output vv-exch-scale
  ,output base-type
  )  .
end.
run get-report-num in my-handle ( output g#report-num ).
run get-gds-engl in my-handle ( output g#gds-engl ) .
do
on error undo, return error
:
define variable sym1 as char init "|" no-undo.
define variable sym2 as char init ":" no-undo.
define variable sym3 as char init ":" no-undo.
define variable sym4 as char init ":" no-undo.
define variable sym5 as char init ":" no-undo.
define variable sym6 as char init ":" no-undo.
define variable sym7 as char init "|" no-undo.
define variable v-wth-name like ub.wealth.wth-name    no-undo.
define variable v-doc-date like ub.wth-line.fact-date no-undo.
define variable v-chk-type as   char               no-undo.
define variable v-doc-code like ub.wth-doc.doc-code   no-undo.
define variable v-deliver  like ub.clients.obj-name   no-undo.
define variable v-receiver like ub.clients.obj-name   no-undo.
define variable v-sum      like ub.wth-line.fact-sum  no-undo.
def frame f-wth
        space(2)
        sym1 column-label "|" format "X(1)" space(1)
        v-wth-name COLUMN-LABEL "                      1" format "X(56)"
        sym2 column-label ":" format "X(1)" space(0)
        v-doc-date COLUMN-LABEL "    2" format "99/99/9999" space(0)
        sym3 column-label ":" format "X(1)" space(1)
        v-doc-code COLUMN-LABEL "        3" format "X(16)" space(1)
        sym4 column-label ":" format "X(1)" space(1)
        v-deliver  COLUMN-LABEL "             4" format "X(31)" space(1)
        sym5 column-label ":" format "X(1)" space(1)
        v-receiver COLUMN-LABEL "             5" format "X(31)" space(1)
        sym6 column-label ":" format "X(1)" space(1)
        v-sum      COLUMN-LABEL "6     " format "->>>,>>>,>>>,>>9.99" space(1)
        sym7 column-label "|" format "X(1)" space(1)
    with width 235 down stream-io
.
def temp-table tt-rep-doc     like ub.wth-line
  field chk-type like ub.chk-doc.chk-type
  field host-code like ub.wth-doc.host-code
  field doc-type like ub.wth-doc.doc-type
  field inter_ like ub.wth-doc.inter_
  field exter_ like ub.wth-doc.exter_
  field cli-name like ub.wth-doc.cli-name.
def buffer buf_tt-doc         for tt-rep-doc.
def buffer buf_wth-doc        for ub.wth-doc.
def buffer b_wth-doc          for ub.wth-doc.
def buffer buf_wth-line       for ub.wth-line.
def buffer buf_wth-dtl        for ub.wth-dtl.
def buffer buf_clients        for ub.clients.
def buffer buf_wth-place      for ub.wth-place.
def buffer buf_out_wth-place  for ub.wth-place.
define buffer buf_chk-doc   for ub.chk-doc.
define buffer buf_wealth      for ub.wealth.
def stream PrnLibStream .
define variable v-organization  like ub.clients.obj-name no-undo.
define variable v-org-to        as char no-undo.
define variable v-org-from      as char no-undo.
define variable v-temp-string   as char no-undo.
define variable v-line-count    as int  no-undo.
define variable v-single-line   as char no-undo.
define variable v-type-sum      as dec no-undo.
define variable parstock-start  like ub.wth-line.income       no-undo.
define variable parstock-end    like ub.wth-line.income       no-undo.
define variable parincome       like ub.wth-line.income       no-undo.
define variable parincome-cassa like ub.wth-line.income-cassa no-undo.
define variable parincome-other like ub.wth-line.income-other no-undo.
define variable parincass       like ub.wth-line.incass       no-undo.
define variable parincass-bank  like ub.wth-line.incass-bank  no-undo.
define variable parincass-other like ub.wth-line.incass-other no-undo.
define variable parincass-cassa like ub.wth-line.incass-cassa no-undo.
assign v-single-line = fill("-", 185).
if session:set-wait-state("compiler") then.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in my-handle
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
run prn-lib-open-stream  in this-procedure (
                                             input my-handle
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
form header
    v-single-line format "x(185)" at 1 skip
    "продолжение - на следующей странице" AT 30 SKIP
    with frame bottomframe width 235 page-bottom no-labels no-box .
view stream PrnLibStream frame bottomframe .
find first buf_clients no-lock
  where buf_clients.obj-type = v-cntxt-obj-type
    and buf_clients.obj-code = v-cntxt-obj-code
.
assign
v-organization = buf_clients.obj-name
.
case x-radio-task :
  when 1 then
     assign
        v-temp-string = "период с " + string(x-date-start) + " по " + string(x-date-end)
     .
  when 2 then
     assign
        v-temp-string = "сменные сутки c " + string(x-date-start) + " по " + string(x-date-end)
     .
  when 3 then
     assign
        v-temp-string = "сменные сутки и номера смен, со смены N"
                  + string(x-shift-start) + " " + string(x-date-start) + " по смену N"
                  + string(x-shift-end)   + " " + string(x-date-end)
     .
  when 4 then
     assign
        v-temp-string = "смену N" + string(x-shift-alone) + ", период с "
                        + string(x-date-start) + " по " + string(x-date-end)
     .
end case.
  put stream PrnLibStream
      skip
        space (3)
        v-cntxt-host-name-obj format "X(120)"
        string( "Страница " + string( page-number( PrnLibStream ), ">>9" ) )
                          format "X(12)"   at right-field(190 - 1, 12)
      skip
          space (3)
          v-organization format "X(185)"
      skip(2)
        "ОТЧЕТ ПО ДВИЖЕНИЮ МАТЕРИАЛЬНЫХ ЦЕННОСТЕЙ НА АЗК"
                          format "X(47)"   at center-field( 3, 190, 47 )
      skip(2)
        space (3)
        "За " + v-temp-string
                          format "X(185)"
  .
  put stream PrnLibStream
    skip
      v-single-line format "X(178)" at 3 + 1
    skip
      "|" at 3
      "|" at 3 + 59
      "Документ" at center-field(3 + 59, 3 + 89, 8)
      "|" at 3 + 89
      "|" at 3 + 123
      "|" at 3 + 157
      "|" at 3 + 178 + 1
    skip
      "|" at 3
      " Наименование"
      "|" at 3 + 59
      v-single-line format "X(29)" at 3 + 59 + 1
      "|" at 3 + 89
      " Получено"
      "|" at 3 + 123
      " Передано"
      "|" at 3 + 157
      " Сумма"
      "|" at 3 + 178 + 1
    skip
      "|" at 3
      "|" at 3 + 59
      "Дата" at center-field(3 + 59, 3 + 70, 4)
      "|" at 3 + 70
      "Номер" at center-field(3 + 70, 3 + 89, 5)
      "|" at 3 + 89
      " из"
      "|" at 3 + 123
      " в"
      "|" at 3 + 157
      "|" at 3 + 178 + 1
    skip
      "|" at 3
      v-single-line format "X(178)"
      "|"
  .
form with frame f-wth .
case x-radio-task :
  when 1
  then do:
        for each b_wth-doc no-lock
          where b_wth-doc.obj-type  = buf_clients.obj-type
            and b_wth-doc.obj-code  = buf_clients.obj-code
            and b_wth-doc.fact-date >= x-date-start
            and b_wth-doc.fact-date <= x-date-end
            and b_wth-doc.status_   = 'факт':U
          ,each buf_wth-line
          where buf_wth-line.doc-code = b_wth-doc.doc-code
          break by b_wth-doc.doc-code by buf_wth-line.wth-code by buf_wth-line.w-p-code
          :
           run r-wth-fill-tt in this-procedure.
        end.
        for each tt-rep-doc no-lock
          , each ub.wealth
          where ub.wealth.wth-code = tt-rep-doc.wth-code
          , each buf_wth-place
          where buf_wth-place.host-code = buf_clients.host-code
            and buf_wth-place.obj-type  = buf_clients.obj-type
            and buf_wth-place.obj-code  = buf_clients.obj-code
            and buf_wth-place.w-p-code  = tt-rep-doc.w-p-code
        break by tt-rep-doc.wth-code by tt-rep-doc.w-p-code by tt-rep-doc.chk-type by tt-rep-doc.ext-doc-type
        by tt-rep-doc.fact-date   by tt-rep-doc.cli-name
        :
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (p-wth-ser and wealth.is-ser = 1) or
   (p-wth-money and wealth.is-money) or
   (p-wth-un and wealth.is-ser = 0 and not wealth.is-money ) then.
else next.
if first-of (tt-rep-doc.wth-code)
then do:
    if not first(tt-rep-doc.wth-code)
    then put stream PrnLibStream
        skip
          "|" at 3
          v-single-line format "X(178)"
          "|"
    .
        DISPLAY STREAM PrnLibStream
                wealth.wth-name @ v-wth-name
                sym1 sym2 sym3 sym4 sym5 sym6 sym7
                with frame f-wth
        .
        down stream PrnLibStream 1 with frame f-wth .
    if x-radio-task <> 4 or x-date-start = x-date-end
    then do:
        run wth-lib_full-inf-calend-date (
                                              input buf_clients.obj-type
                                            , input buf_clients.obj-code
                                            , input tt-rep-doc.wth-code
                                            , input x-date-start
                                            , output  parstock-start
                                            , output  parstock-end
                                            , output  parincome
                                            , output  parincome-cassa
                                            , output  parincome-other
                                            , output  parincass
                                            , output  parincass-bank
                                            , output  parincass-other
                                            , output  parincass-cassa
                                  ).
        display stream PrnLibStream
                "   Остаток на начало Всего на АЗК" @ v-wth-name
                parstock-start  @ v-sum
                sym1 sym2 sym3 sym4 sym5 sym6 sym7
                with frame f-wth
        .
        down stream PrnLibStream 1 with frame f-wth .
    end.
end.
if first-of(tt-rep-doc.w-p-code) then do:
  if x-radio-task <> 4 or x-date-start = x-date-end then do:
            run wth-lib_full-inf-calend-date-place(
                                    input  buf_clients.obj-type
                                  , input  buf_clients.obj-code
                                  , input  tt-rep-doc.wth-code
                                  , input  tt-rep-doc.w-p-code
                                  , input  x-date-start
                                  , output parstock-start
                                  , output parstock-end
                                  , output parincome
                                  , output parincome-cassa
                                  , output parincome-other
                                  , output parincass
                                  , output parincass-bank
                                  , output parincass-other
                                  , output parincass-cassa
            ).
            display stream PrnLibStream
                    "     Остаток на начало периода по " + buf_wth-place.w-p-name  @ v-wth-name
                    parstock-start @ v-sum
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7
                    with frame f-wth
            .
            down stream PrnLibStream 1 with frame f-wth .
  end.
  else do:
            display stream PrnLibStream
                    "     " + buf_wth-place.w-p-name  @ v-wth-name
                    parstock-start @ v-sum
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7
                    with frame f-wth
            .
            down stream PrnLibStream 1 with frame f-wth .
  end.
end.
if first-of(tt-rep-doc.chk-type) or
   first-of(tt-rep-doc.ext-doc-type)
 then do:
 v-type-sum = 0.
    if tt-rep-doc.chk-type <> 99 then case tt-rep-doc.chk-type:
      when 0 then v-chk-type = 'Реализация'.
      when 2 then v-chk-type = 'Инкассация'.
      when 3 then v-chk-type = 'Кассовый фонд'.
      when 4 then v-chk-type = 'Перевод оплаты'.
      when 5 then v-chk-type = 'Выплата'.
      otherwise  v-chk-type =  'Прочее'.
    end.
    else v-chk-type =  ENTRY(LOOKUP(tt-rep-doc.ext-doc-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u), 'приход внешний,расход внешний,приход внутренний,расход внутренний,приход внутри объекта,расход внутри объекта,приход внутриобъектн. в своб. зону,расход внутриобъектн. из своб. зоны,приход внутриобъектн. в зону погаш.,расход внутриобъектн. из зоны погаш.,списание,приход внешний через кассы,возврат покупателю через кассы,инвентаризация,возврат внутренний,приход внутр. в зону погашения,расход внутр. из зоны погашения,возврат внутр. в зону погашения,приход внутр. в своб. зону,расход внутр. из своб. зоны,возврат внутр. в своб зону,погашение через кассу,погашение за реализованное топливо,возврат от покупателя,уничтожение в свободной зоне,уничтожение в зоне погашения,уничтожение в зоне клиента,декларация,обмен':u).
    DISPLAY STREAM PrnLibStream
 '                     '  + v-chk-type
     @ v-wth-name
       with frame f-wth
.
end.
assign
    v-wth-name = wealth.wth-name
    v-doc-date = tt-rep-doc.fact-date
    v-doc-code = tt-rep-doc.doc-code
    v-sum      = (if (tt-rep-doc.doc-type = 'рас':U or tt-rep-doc.doc-type = 'спи':U) then 0 - tt-rep-doc.fact-sum else tt-rep-doc.fact-sum )
    v-type-sum = v-type-sum + v-sum
.
if tt-rep-doc.inter_ = yes
then do:
    find first buf_out_wth-place no-lock
         where buf_out_wth-place.host-code = tt-rep-doc.host-code
          and  buf_out_wth-place.obj-type = tt-rep-doc.obj-type
          and  buf_out_wth-place.obj-code = tt-rep-doc.obj-code
          and  buf_out_wth-place.w-p-code = tt-rep-doc.out-code
    .
    assign
        v-deliver  = (if     tt-rep-doc.doc-type = 'при':U
                        then buf_out_wth-place.w-p-name
                        else buf_wth-place.w-p-name
                     )
        v-receiver = (if     tt-rep-doc.doc-type = 'при':U
                        then buf_wth-place.w-p-name
                        else buf_out_wth-place.w-p-name
                     )
    .
end.
else do:
    assign
        v-deliver  = (if     tt-rep-doc.doc-type = 'при':U
                        then tt-rep-doc.cli-name
                        else buf_wth-place.w-p-name
                    )
        v-receiver = (if     tt-rep-doc.doc-type = 'при':U
                        then buf_wth-place.w-p-name
                        else tt-rep-doc.cli-name
                    )
    .
end.
DISPLAY STREAM PrnLibStream
        v-doc-date
        v-doc-code
        v-deliver
        v-receiver
        v-sum
        sym1 sym2 sym3 sym4 sym5 sym6 sym7
        with frame f-wth
.
DOWN STREAM PrnLibStream 1 with frame f-wth .
if last-of(tt-rep-doc.chk-type) or
   (last-of(tt-rep-doc.ext-doc-type) and not tt-rep-doc.chk-type = 0)
 then do:
  v-sum = v-type-sum.
    DISPLAY STREAM PrnLibStream
    '               Итого ' + v-chk-type  @ v-wth-name
    v-sum
    sym1 sym2 sym3 sym4 sym5 sym6 sym7
    with frame f-wth
    .
DOWN STREAM PrnLibStream 1 with frame f-wth .
end.
if last-of(tt-rep-doc.w-p-code) then do:
     if x-radio-task <> 4 or x-date-start = x-date-end
  then do:
            run wth-lib_full-inf-calend-date-place(
                                  input  buf_clients.obj-type
                                , input  buf_clients.obj-code
                                , input  tt-rep-doc.wth-code
                                , input  tt-rep-doc.w-p-code
                                , input  x-date-end
                                , output parstock-start
                                , output parstock-end
                                , output parincome
                                , output parincome-cassa
                                , output parincome-other
                                , output parincass
                                , output parincass-bank
                                , output parincass-other
                                , output parincass-cassa
          ).
          display stream PrnLibStream
                  "     Остаток на конец  периода по " + buf_wth-place.w-p-name @ v-wth-name
                  parstock-end @ v-sum
                  sym1 sym2 sym3 sym4 sym5 sym6 sym7
                  with frame f-wth
          .
          down stream PrnLibStream 1 with frame f-wth .
      end.
end.
if last-of (tt-rep-doc.wth-code)
then do:
   if x-radio-task <> 4 or x-date-start = x-date-end
   then do:
      for each wth-place
         where wth-place.host-code = buf_clients.host-code
         and wth-place.obj-type  = buf_clients.obj-type
         and wth-place.obj-code  = buf_clients.obj-code
         and not can-find(first buf_tt-doc where buf_tt-doc.w-p-code = wth-place.w-p-code and buf_tt-doc.wth-code = tt-rep-doc.wth-code):
                run wth-lib_full-inf-calend-date-place(
                                      input  buf_clients.obj-type
                                    , input  buf_clients.obj-code
                                    , input  tt-rep-doc.wth-code
                                    , input  wth-place.w-p-code
                                    , input  x-date-end
                                    , output parstock-start
                                    , output parstock-end
                                    , output parincome
                                    , output parincome-cassa
                                    , output parincome-other
                                    , output parincass
                                    , output parincass-bank
                                    , output parincass-other
                                    , output parincass-cassa
              ).
              display stream PrnLibStream
                      "     Остаток на конец  периода по " + wth-place.w-p-name @ v-wth-name
                      parstock-end @ v-sum
                      sym1 sym2 sym3 sym4 sym5 sym6 sym7
                      with frame f-wth
              .
              down stream PrnLibStream 1 with frame f-wth .
      end.
    run wth-lib_full-inf-calend-date (
                                          input buf_clients.obj-type
                                        , input buf_clients.obj-code
                                        , input tt-rep-doc.wth-code
                                        , input x-date-end
                                        , output  parstock-start
                                        , output  parstock-end
                                        , output  parincome
                                        , output  parincome-cassa
                                        , output  parincome-other
                                        , output  parincass
                                        , output  parincass-bank
                                        , output  parincass-other
                                        , output  parincass-cassa
                                        ).
    display stream PrnLibStream
            "   Остаток на конец  Всего на АЗК" @ v-wth-name
            parstock-end @ v-sum
            sym1 sym2 sym3 sym4 sym5 sym6 sym7
            with frame f-wth
    .
    down stream PrnLibStream 1 with frame f-wth .
  end.
end.
        end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if x-radio-task <> 4 or x-date-start = x-date-end then do:
 for each buf_wealth no-lock where
      not can-find(first tt-rep-doc where tt-rep-doc.wth-code = buf_wealth.wth-code )
      and ((p-wth-ser and buf_wealth.is-ser = 1) or
          (p-wth-money and buf_wealth.is-money) or
          (p-wth-un and buf_wealth.is-ser = 0 and not buf_wealth.is-money )) :
          DISPLAY STREAM PrnLibStream
                buf_wealth.wth-name @ v-wth-name
                sym1 sym2 sym3 sym4 sym5 sym6 sym7
                with frame f-wth
        .
        down stream PrnLibStream 1 with frame f-wth .
      for each ub.wth-place
         where ub.wth-place.host-code = buf_clients.host-code
         and ub.wth-place.obj-type  = buf_clients.obj-type
         and ub.wth-place.obj-code  = buf_clients.obj-code:
                run wth-lib_full-inf-calend-date-place(
                                      input  buf_clients.obj-type
                                    , input  buf_clients.obj-code
                                    , input  buf_wealth.wth-code
                                    , input  wth-place.w-p-code
                                    , input  x-date-end
                                    , output parstock-start
                                    , output parstock-end
                                    , output parincome
                                    , output parincome-cassa
                                    , output parincome-other
                                    , output parincass
                                    , output parincass-bank
                                    , output parincass-other
                                    , output parincass-cassa
              ).
              display stream PrnLibStream
                      "     Остаток на конец  периода по " + wth-place.w-p-name @ v-wth-name
                      parstock-end @ v-sum
                      sym1 sym2 sym3 sym4 sym5 sym6 sym7
                      with frame f-wth
              .
              down stream PrnLibStream 1 with frame f-wth .
      end.
      run wth-lib_full-inf-calend-date (
                                              input buf_clients.obj-type
                                            , input buf_clients.obj-code
                                            , input buf_wealth.wth-code
                                            , input x-date-end
                                        , output  parstock-start
                                        , output  parstock-end
                                        , output  parincome
                                        , output  parincome-cassa
                                        , output  parincome-other
                                        , output  parincass
                                        , output  parincass-bank
                                        , output  parincass-other
                                        , output  parincass-cassa
                                        ).
    display stream PrnLibStream
            "   Остаток на конец  Всего на АЗК" @ v-wth-name
            parstock-end @ v-sum
            sym1 sym2 sym3 sym4 sym5 sym6 sym7
            with frame f-wth
    .
    down stream PrnLibStream 1 with frame f-wth .
 end.
end.
  end.
  when 2
  then do:
        for each b_wth-doc no-lock
          where b_wth-doc.obj-type  = buf_clients.obj-type
            and b_wth-doc.obj-code  = buf_clients.obj-code
            and b_wth-doc.shift-date >= x-date-start
            and b_wth-doc.shift-date <= x-date-end
            and b_wth-doc.status_   = 'факт':U
          ,each buf_wth-line
          where buf_wth-line.doc-code = b_wth-doc.doc-code
          break by b_wth-doc.doc-code by buf_wth-line.wth-code by buf_wth-line.w-p-code
          :
           run r-wth-fill-tt in this-procedure.
        end.
        for each tt-rep-doc no-lock
          , each ub.wealth
          where ub.wealth.wth-code = tt-rep-doc.wth-code
          , each buf_wth-place
          where buf_wth-place.host-code = buf_clients.host-code
            and buf_wth-place.obj-type  = buf_clients.obj-type
            and buf_wth-place.obj-code  = buf_clients.obj-code
            and buf_wth-place.w-p-code  = tt-rep-doc.w-p-code
        break by tt-rep-doc.wth-code by tt-rep-doc.w-p-code by tt-rep-doc.chk-type by tt-rep-doc.ext-doc-type  by tt-rep-doc.shift-date
                by tt-rep-doc.cli-name
        :
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (p-wth-ser and wealth.is-ser = 1) or
   (p-wth-money and wealth.is-money) or
   (p-wth-un and wealth.is-ser = 0 and not wealth.is-money ) then.
else next.
if first-of (tt-rep-doc.wth-code)
then do:
    if not first(tt-rep-doc.wth-code)
    then put stream PrnLibStream
        skip
          "|" at 3
          v-single-line format "X(178)"
          "|"
    .
        DISPLAY STREAM PrnLibStream
                wealth.wth-name @ v-wth-name
                sym1 sym2 sym3 sym4 sym5 sym6 sym7
                with frame f-wth
        .
        down stream PrnLibStream 1 with frame f-wth .
    if x-radio-task <> 4 or x-date-start = x-date-end
    then do:
        run wth-lib_full-inf-shift-date (
                                              input buf_clients.obj-type
                                            , input buf_clients.obj-code
                                            , input tt-rep-doc.wth-code
                                            , input x-date-start
                                            , output  parstock-start
                                            , output  parstock-end
                                            , output  parincome
                                            , output  parincome-cassa
                                            , output  parincome-other
                                            , output  parincass
                                            , output  parincass-bank
                                            , output  parincass-other
                                            , output  parincass-cassa
                                  ).
        display stream PrnLibStream
                "   Остаток на начало Всего на АЗК" @ v-wth-name
                parstock-start  @ v-sum
                sym1 sym2 sym3 sym4 sym5 sym6 sym7
                with frame f-wth
        .
        down stream PrnLibStream 1 with frame f-wth .
    end.
end.
if first-of(tt-rep-doc.w-p-code) then do:
  if x-radio-task <> 4 or x-date-start = x-date-end then do:
            run wth-lib_full-inf-shift-date-place(
                                    input  buf_clients.obj-type
                                  , input  buf_clients.obj-code
                                  , input  tt-rep-doc.wth-code
                                  , input  tt-rep-doc.w-p-code
                                  , input  x-date-start
                                  , output parstock-start
                                  , output parstock-end
                                  , output parincome
                                  , output parincome-cassa
                                  , output parincome-other
                                  , output parincass
                                  , output parincass-bank
                                  , output parincass-other
                                  , output parincass-cassa
            ).
            display stream PrnLibStream
                    "     Остаток на начало периода по " + buf_wth-place.w-p-name  @ v-wth-name
                    parstock-start @ v-sum
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7
                    with frame f-wth
            .
            down stream PrnLibStream 1 with frame f-wth .
  end.
  else do:
            display stream PrnLibStream
                    "     " + buf_wth-place.w-p-name  @ v-wth-name
                    parstock-start @ v-sum
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7
                    with frame f-wth
            .
            down stream PrnLibStream 1 with frame f-wth .
  end.
end.
if first-of(tt-rep-doc.chk-type) or
   first-of(tt-rep-doc.ext-doc-type)
 then do:
 v-type-sum = 0.
    if tt-rep-doc.chk-type <> 99 then case tt-rep-doc.chk-type:
      when 0 then v-chk-type = 'Реализация'.
      when 2 then v-chk-type = 'Инкассация'.
      when 3 then v-chk-type = 'Кассовый фонд'.
      when 4 then v-chk-type = 'Перевод оплаты'.
      when 5 then v-chk-type = 'Выплата'.
      otherwise  v-chk-type =  'Прочее'.
    end.
    else v-chk-type =  ENTRY(LOOKUP(tt-rep-doc.ext-doc-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u), 'приход внешний,расход внешний,приход внутренний,расход внутренний,приход внутри объекта,расход внутри объекта,приход внутриобъектн. в своб. зону,расход внутриобъектн. из своб. зоны,приход внутриобъектн. в зону погаш.,расход внутриобъектн. из зоны погаш.,списание,приход внешний через кассы,возврат покупателю через кассы,инвентаризация,возврат внутренний,приход внутр. в зону погашения,расход внутр. из зоны погашения,возврат внутр. в зону погашения,приход внутр. в своб. зону,расход внутр. из своб. зоны,возврат внутр. в своб зону,погашение через кассу,погашение за реализованное топливо,возврат от покупателя,уничтожение в свободной зоне,уничтожение в зоне погашения,уничтожение в зоне клиента,декларация,обмен':u).
    DISPLAY STREAM PrnLibStream
 '                     '  + v-chk-type
     @ v-wth-name
       with frame f-wth
.
end.
assign
    v-wth-name = wealth.wth-name
    v-doc-date = tt-rep-doc.fact-date
    v-doc-code = tt-rep-doc.doc-code
    v-sum      = (if (tt-rep-doc.doc-type = 'рас':U or tt-rep-doc.doc-type = 'спи':U) then 0 - tt-rep-doc.fact-sum else tt-rep-doc.fact-sum )
    v-type-sum = v-type-sum + v-sum
.
if tt-rep-doc.inter_ = yes
then do:
    find first buf_out_wth-place no-lock
         where buf_out_wth-place.host-code = tt-rep-doc.host-code
          and  buf_out_wth-place.obj-type = tt-rep-doc.obj-type
          and  buf_out_wth-place.obj-code = tt-rep-doc.obj-code
          and  buf_out_wth-place.w-p-code = tt-rep-doc.out-code
    .
    assign
        v-deliver  = (if     tt-rep-doc.doc-type = 'при':U
                        then buf_out_wth-place.w-p-name
                        else buf_wth-place.w-p-name
                     )
        v-receiver = (if     tt-rep-doc.doc-type = 'при':U
                        then buf_wth-place.w-p-name
                        else buf_out_wth-place.w-p-name
                     )
    .
end.
else do:
    assign
        v-deliver  = (if     tt-rep-doc.doc-type = 'при':U
                        then tt-rep-doc.cli-name
                        else buf_wth-place.w-p-name
                    )
        v-receiver = (if     tt-rep-doc.doc-type = 'при':U
                        then buf_wth-place.w-p-name
                        else tt-rep-doc.cli-name
                    )
    .
end.
DISPLAY STREAM PrnLibStream
        v-doc-date
        v-doc-code
        v-deliver
        v-receiver
        v-sum
        sym1 sym2 sym3 sym4 sym5 sym6 sym7
        with frame f-wth
.
DOWN STREAM PrnLibStream 1 with frame f-wth .
if last-of(tt-rep-doc.chk-type) or
   (last-of(tt-rep-doc.ext-doc-type) and not tt-rep-doc.chk-type = 0)
 then do:
  v-sum = v-type-sum.
    DISPLAY STREAM PrnLibStream
    '               Итого ' + v-chk-type  @ v-wth-name
    v-sum
    sym1 sym2 sym3 sym4 sym5 sym6 sym7
    with frame f-wth
    .
DOWN STREAM PrnLibStream 1 with frame f-wth .
end.
if last-of(tt-rep-doc.w-p-code) then do:
     if x-radio-task <> 4 or x-date-start = x-date-end
  then do:
            run wth-lib_full-inf-shift-date-place(
                                  input  buf_clients.obj-type
                                , input  buf_clients.obj-code
                                , input  tt-rep-doc.wth-code
                                , input  tt-rep-doc.w-p-code
                                , input  x-date-end
                                , output parstock-start
                                , output parstock-end
                                , output parincome
                                , output parincome-cassa
                                , output parincome-other
                                , output parincass
                                , output parincass-bank
                                , output parincass-other
                                , output parincass-cassa
          ).
          display stream PrnLibStream
                  "     Остаток на конец  периода по " + buf_wth-place.w-p-name @ v-wth-name
                  parstock-end @ v-sum
                  sym1 sym2 sym3 sym4 sym5 sym6 sym7
                  with frame f-wth
          .
          down stream PrnLibStream 1 with frame f-wth .
      end.
end.
if last-of (tt-rep-doc.wth-code)
then do:
   if x-radio-task <> 4 or x-date-start = x-date-end
   then do:
      for each wth-place
         where wth-place.host-code = buf_clients.host-code
         and wth-place.obj-type  = buf_clients.obj-type
         and wth-place.obj-code  = buf_clients.obj-code
         and not can-find(first buf_tt-doc where buf_tt-doc.w-p-code = wth-place.w-p-code and buf_tt-doc.wth-code = tt-rep-doc.wth-code):
                run wth-lib_full-inf-shift-date-place(
                                      input  buf_clients.obj-type
                                    , input  buf_clients.obj-code
                                    , input  tt-rep-doc.wth-code
                                    , input  wth-place.w-p-code
                                    , input  x-date-end
                                    , output parstock-start
                                    , output parstock-end
                                    , output parincome
                                    , output parincome-cassa
                                    , output parincome-other
                                    , output parincass
                                    , output parincass-bank
                                    , output parincass-other
                                    , output parincass-cassa
              ).
              display stream PrnLibStream
                      "     Остаток на конец  периода по " + wth-place.w-p-name @ v-wth-name
                      parstock-end @ v-sum
                      sym1 sym2 sym3 sym4 sym5 sym6 sym7
                      with frame f-wth
              .
              down stream PrnLibStream 1 with frame f-wth .
      end.
    run wth-lib_full-inf-shift-date (
                                          input buf_clients.obj-type
                                        , input buf_clients.obj-code
                                        , input tt-rep-doc.wth-code
                                        , input x-date-end
                                        , output  parstock-start
                                        , output  parstock-end
                                        , output  parincome
                                        , output  parincome-cassa
                                        , output  parincome-other
                                        , output  parincass
                                        , output  parincass-bank
                                        , output  parincass-other
                                        , output  parincass-cassa
                                        ).
    display stream PrnLibStream
            "   Остаток на конец  Всего на АЗК" @ v-wth-name
            parstock-end @ v-sum
            sym1 sym2 sym3 sym4 sym5 sym6 sym7
            with frame f-wth
    .
    down stream PrnLibStream 1 with frame f-wth .
  end.
end.
        end.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if x-radio-task <> 4 or x-date-start = x-date-end then do:
 for each buf_wealth no-lock where
      not can-find(first tt-rep-doc where tt-rep-doc.wth-code = buf_wealth.wth-code )
      and ((p-wth-ser and buf_wealth.is-ser = 1) or
          (p-wth-money and buf_wealth.is-money) or
          (p-wth-un and buf_wealth.is-ser = 0 and not buf_wealth.is-money )) :
          DISPLAY STREAM PrnLibStream
                buf_wealth.wth-name @ v-wth-name
                sym1 sym2 sym3 sym4 sym5 sym6 sym7
                with frame f-wth
        .
        down stream PrnLibStream 1 with frame f-wth .
      for each ub.wth-place
         where ub.wth-place.host-code = buf_clients.host-code
         and ub.wth-place.obj-type  = buf_clients.obj-type
         and ub.wth-place.obj-code  = buf_clients.obj-code:
                run wth-lib_full-inf-shift-date-place(
                                      input  buf_clients.obj-type
                                    , input  buf_clients.obj-code
                                    , input  buf_wealth.wth-code
                                    , input  wth-place.w-p-code
                                    , input  x-date-end
                                    , output parstock-start
                                    , output parstock-end
                                    , output parincome
                                    , output parincome-cassa
                                    , output parincome-other
                                    , output parincass
                                    , output parincass-bank
                                    , output parincass-other
                                    , output parincass-cassa
              ).
              display stream PrnLibStream
                      "     Остаток на конец  периода по " + wth-place.w-p-name @ v-wth-name
                      parstock-end @ v-sum
                      sym1 sym2 sym3 sym4 sym5 sym6 sym7
                      with frame f-wth
              .
              down stream PrnLibStream 1 with frame f-wth .
      end.
        run wth-lib_full-inf-shift-date (
                                              input buf_clients.obj-type
                                            , input buf_clients.obj-code
                                            , input buf_wealth.wth-code
                                            , input x-date-end
                                        , output  parstock-start
                                        , output  parstock-end
                                        , output  parincome
                                        , output  parincome-cassa
                                        , output  parincome-other
                                        , output  parincass
                                        , output  parincass-bank
                                        , output  parincass-other
                                        , output  parincass-cassa
                                        ).
    display stream PrnLibStream
            "   Остаток на конец  Всего на АЗК" @ v-wth-name
            parstock-end @ v-sum
            sym1 sym2 sym3 sym4 sym5 sym6 sym7
            with frame f-wth
    .
    down stream PrnLibStream 1 with frame f-wth .
 end.
end.
  end.
  when 3
  then do:
        for each b_wth-doc no-lock
          where b_wth-doc.obj-type  = buf_clients.obj-type
            and b_wth-doc.obj-code  = buf_clients.obj-code
            and ( b_wth-doc.shift-date > x-date-start
                  or ( b_wth-doc.shift-date = x-date-start
                       and b_wth-doc.shift-num >= x-shift-start
                     )
                )
            and ( b_wth-doc.shift-date < x-date-end
                  or ( b_wth-doc.shift-date = x-date-end
                       and b_wth-doc.shift-num <= x-shift-end
                     )
                )
            and b_wth-doc.status_   = 'факт':U
          ,each buf_wth-line
          where buf_wth-line.doc-code = b_wth-doc.doc-code
          break by b_wth-doc.doc-code by buf_wth-line.wth-code by buf_wth-line.w-p-code
          :
           run r-wth-fill-tt in this-procedure.
        end.
        for each tt-rep-doc no-lock
          , each ub.wealth
          where ub.wealth.wth-code = tt-rep-doc.wth-code
          , each buf_wth-place
          where buf_wth-place.host-code = buf_clients.host-code
            and buf_wth-place.obj-type  = buf_clients.obj-type
            and buf_wth-place.obj-code  = buf_clients.obj-code
            and buf_wth-place.w-p-code  = tt-rep-doc.w-p-code
        break by tt-rep-doc.wth-code by tt-rep-doc.w-p-code by tt-rep-doc.chk-type by tt-rep-doc.ext-doc-type
               by tt-rep-doc.shift-date   by tt-rep-doc.cli-name
        :
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (p-wth-ser and wealth.is-ser = 1) or
   (p-wth-money and wealth.is-money) or
   (p-wth-un and wealth.is-ser = 0 and not wealth.is-money ) then.
else next.
if first-of (tt-rep-doc.wth-code)
then do:
    if not first(tt-rep-doc.wth-code)
    then put stream PrnLibStream
        skip
          "|" at 3
          v-single-line format "X(178)"
          "|"
    .
        DISPLAY STREAM PrnLibStream
                wealth.wth-name @ v-wth-name
                sym1 sym2 sym3 sym4 sym5 sym6 sym7
                with frame f-wth
        .
        down stream PrnLibStream 1 with frame f-wth .
    if x-radio-task <> 4 or x-date-start = x-date-end
    then do:
        run wth-lib_full-inf-shift(
                                              input buf_clients.obj-type
                                            , input buf_clients.obj-code
                                            , input tt-rep-doc.wth-code
                                            , input x-date-start
                                              , input  x-shift-start
                                            , output  parstock-start
                                            , output  parstock-end
                                            , output  parincome
                                            , output  parincome-cassa
                                            , output  parincome-other
                                            , output  parincass
                                            , output  parincass-bank
                                            , output  parincass-other
                                            , output  parincass-cassa
                                  ).
        display stream PrnLibStream
                "   Остаток на начало Всего на АЗК" @ v-wth-name
                parstock-start  @ v-sum
                sym1 sym2 sym3 sym4 sym5 sym6 sym7
                with frame f-wth
        .
        down stream PrnLibStream 1 with frame f-wth .
    end.
end.
if first-of(tt-rep-doc.w-p-code) then do:
  if x-radio-task <> 4 or x-date-start = x-date-end then do:
            run wth-lib_full-inf-shift-place(
                                    input  buf_clients.obj-type
                                  , input  buf_clients.obj-code
                                  , input  tt-rep-doc.wth-code
                                  , input  tt-rep-doc.w-p-code
                                  , input  x-date-start
                                    , input  x-shift-start
                                  , output parstock-start
                                  , output parstock-end
                                  , output parincome
                                  , output parincome-cassa
                                  , output parincome-other
                                  , output parincass
                                  , output parincass-bank
                                  , output parincass-other
                                  , output parincass-cassa
            ).
            display stream PrnLibStream
                    "     Остаток на начало периода по " + buf_wth-place.w-p-name  @ v-wth-name
                    parstock-start @ v-sum
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7
                    with frame f-wth
            .
            down stream PrnLibStream 1 with frame f-wth .
  end.
  else do:
            display stream PrnLibStream
                    "     " + buf_wth-place.w-p-name  @ v-wth-name
                    parstock-start @ v-sum
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7
                    with frame f-wth
            .
            down stream PrnLibStream 1 with frame f-wth .
  end.
end.
if first-of(tt-rep-doc.chk-type) or
   first-of(tt-rep-doc.ext-doc-type)
 then do:
 v-type-sum = 0.
    if tt-rep-doc.chk-type <> 99 then case tt-rep-doc.chk-type:
      when 0 then v-chk-type = 'Реализация'.
      when 2 then v-chk-type = 'Инкассация'.
      when 3 then v-chk-type = 'Кассовый фонд'.
      when 4 then v-chk-type = 'Перевод оплаты'.
      when 5 then v-chk-type = 'Выплата'.
      otherwise  v-chk-type =  'Прочее'.
    end.
    else v-chk-type =  ENTRY(LOOKUP(tt-rep-doc.ext-doc-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u), 'приход внешний,расход внешний,приход внутренний,расход внутренний,приход внутри объекта,расход внутри объекта,приход внутриобъектн. в своб. зону,расход внутриобъектн. из своб. зоны,приход внутриобъектн. в зону погаш.,расход внутриобъектн. из зоны погаш.,списание,приход внешний через кассы,возврат покупателю через кассы,инвентаризация,возврат внутренний,приход внутр. в зону погашения,расход внутр. из зоны погашения,возврат внутр. в зону погашения,приход внутр. в своб. зону,расход внутр. из своб. зоны,возврат внутр. в своб зону,погашение через кассу,погашение за реализованное топливо,возврат от покупателя,уничтожение в свободной зоне,уничтожение в зоне погашения,уничтожение в зоне клиента,декларация,обмен':u).
    DISPLAY STREAM PrnLibStream
 '                     '  + v-chk-type
     @ v-wth-name
       with frame f-wth
.
end.
assign
    v-wth-name = wealth.wth-name
    v-doc-date = tt-rep-doc.fact-date
    v-doc-code = tt-rep-doc.doc-code
    v-sum      = (if (tt-rep-doc.doc-type = 'рас':U or tt-rep-doc.doc-type = 'спи':U) then 0 - tt-rep-doc.fact-sum else tt-rep-doc.fact-sum )
    v-type-sum = v-type-sum + v-sum
.
if tt-rep-doc.inter_ = yes
then do:
    find first buf_out_wth-place no-lock
         where buf_out_wth-place.host-code = tt-rep-doc.host-code
          and  buf_out_wth-place.obj-type = tt-rep-doc.obj-type
          and  buf_out_wth-place.obj-code = tt-rep-doc.obj-code
          and  buf_out_wth-place.w-p-code = tt-rep-doc.out-code
    .
    assign
        v-deliver  = (if     tt-rep-doc.doc-type = 'при':U
                        then buf_out_wth-place.w-p-name
                        else buf_wth-place.w-p-name
                     )
        v-receiver = (if     tt-rep-doc.doc-type = 'при':U
                        then buf_wth-place.w-p-name
                        else buf_out_wth-place.w-p-name
                     )
    .
end.
else do:
    assign
        v-deliver  = (if     tt-rep-doc.doc-type = 'при':U
                        then tt-rep-doc.cli-name
                        else buf_wth-place.w-p-name
                    )
        v-receiver = (if     tt-rep-doc.doc-type = 'при':U
                        then buf_wth-place.w-p-name
                        else tt-rep-doc.cli-name
                    )
    .
end.
DISPLAY STREAM PrnLibStream
        v-doc-date
        v-doc-code
        v-deliver
        v-receiver
        v-sum
        sym1 sym2 sym3 sym4 sym5 sym6 sym7
        with frame f-wth
.
DOWN STREAM PrnLibStream 1 with frame f-wth .
if last-of(tt-rep-doc.chk-type) or
   (last-of(tt-rep-doc.ext-doc-type) and not tt-rep-doc.chk-type = 0)
 then do:
  v-sum = v-type-sum.
    DISPLAY STREAM PrnLibStream
    '               Итого ' + v-chk-type  @ v-wth-name
    v-sum
    sym1 sym2 sym3 sym4 sym5 sym6 sym7
    with frame f-wth
    .
DOWN STREAM PrnLibStream 1 with frame f-wth .
end.
if last-of(tt-rep-doc.w-p-code) then do:
     if x-radio-task <> 4 or x-date-start = x-date-end
  then do:
            run wth-lib_full-inf-shift-place(
                                  input  buf_clients.obj-type
                                , input  buf_clients.obj-code
                                , input  tt-rep-doc.wth-code
                                , input  tt-rep-doc.w-p-code
                                , input  x-date-end
                                  , input  x-shift-end
                                , output parstock-start
                                , output parstock-end
                                , output parincome
                                , output parincome-cassa
                                , output parincome-other
                                , output parincass
                                , output parincass-bank
                                , output parincass-other
                                , output parincass-cassa
          ).
          display stream PrnLibStream
                  "     Остаток на конец  периода по " + buf_wth-place.w-p-name @ v-wth-name
                  parstock-end @ v-sum
                  sym1 sym2 sym3 sym4 sym5 sym6 sym7
                  with frame f-wth
          .
          down stream PrnLibStream 1 with frame f-wth .
      end.
end.
if last-of (tt-rep-doc.wth-code)
then do:
   if x-radio-task <> 4 or x-date-start = x-date-end
   then do:
      for each wth-place
         where wth-place.host-code = buf_clients.host-code
         and wth-place.obj-type  = buf_clients.obj-type
         and wth-place.obj-code  = buf_clients.obj-code
         and not can-find(first buf_tt-doc where buf_tt-doc.w-p-code = wth-place.w-p-code and buf_tt-doc.wth-code = tt-rep-doc.wth-code):
                run wth-lib_full-inf-shift-place(
                                      input  buf_clients.obj-type
                                    , input  buf_clients.obj-code
                                    , input  tt-rep-doc.wth-code
                                    , input  wth-place.w-p-code
                                    , input  x-date-end
                                      , input  x-shift-end
                                    , output parstock-start
                                    , output parstock-end
                                    , output parincome
                                    , output parincome-cassa
                                    , output parincome-other
                                    , output parincass
                                    , output parincass-bank
                                    , output parincass-other
                                    , output parincass-cassa
              ).
              display stream PrnLibStream
                      "     Остаток на конец  периода по " + wth-place.w-p-name @ v-wth-name
                      parstock-end @ v-sum
                      sym1 sym2 sym3 sym4 sym5 sym6 sym7
                      with frame f-wth
              .
              down stream PrnLibStream 1 with frame f-wth .
      end.
        run wth-lib_full-inf-shift (
                                          input buf_clients.obj-type
                                        , input buf_clients.obj-code
                                        , input tt-rep-doc.wth-code
                                        , input x-date-end
                                        , input  x-shift-end
                                        , output  parstock-start
                                        , output  parstock-end
                                        , output  parincome
                                        , output  parincome-cassa
                                        , output  parincome-other
                                        , output  parincass
                                        , output  parincass-bank
                                        , output  parincass-other
                                        , output  parincass-cassa
                                        ).
    display stream PrnLibStream
            "   Остаток на конец  Всего на АЗК" @ v-wth-name
            parstock-end @ v-sum
            sym1 sym2 sym3 sym4 sym5 sym6 sym7
            with frame f-wth
    .
    down stream PrnLibStream 1 with frame f-wth .
  end.
end.
        end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if x-radio-task <> 4 or x-date-start = x-date-end then do:
 for each buf_wealth no-lock where
      not can-find(first tt-rep-doc where tt-rep-doc.wth-code = buf_wealth.wth-code )
      and ((p-wth-ser and buf_wealth.is-ser = 1) or
          (p-wth-money and buf_wealth.is-money) or
          (p-wth-un and buf_wealth.is-ser = 0 and not buf_wealth.is-money )) :
          DISPLAY STREAM PrnLibStream
                buf_wealth.wth-name @ v-wth-name
                sym1 sym2 sym3 sym4 sym5 sym6 sym7
                with frame f-wth
        .
        down stream PrnLibStream 1 with frame f-wth .
      for each ub.wth-place
         where ub.wth-place.host-code = buf_clients.host-code
         and ub.wth-place.obj-type  = buf_clients.obj-type
         and ub.wth-place.obj-code  = buf_clients.obj-code:
                run wth-lib_full-inf-shift-place(
                                      input  buf_clients.obj-type
                                    , input  buf_clients.obj-code
                                    , input  buf_wealth.wth-code
                                    , input  wth-place.w-p-code
                                    , input  x-date-end
                                      , input  x-shift-end
                                    , output parstock-start
                                    , output parstock-end
                                    , output parincome
                                    , output parincome-cassa
                                    , output parincome-other
                                    , output parincass
                                    , output parincass-bank
                                    , output parincass-other
                                    , output parincass-cassa
              ).
              display stream PrnLibStream
                      "     Остаток на конец  периода по " + wth-place.w-p-name @ v-wth-name
                      parstock-end @ v-sum
                      sym1 sym2 sym3 sym4 sym5 sym6 sym7
                      with frame f-wth
              .
              down stream PrnLibStream 1 with frame f-wth .
      end.
            run wth-lib_full-inf-shift (
                                              input buf_clients.obj-type
                                            , input buf_clients.obj-code
                                            , input buf_wealth.wth-code
                                            , input x-date-end
                                            , input  x-shift-end
                                        , output  parstock-start
                                        , output  parstock-end
                                        , output  parincome
                                        , output  parincome-cassa
                                        , output  parincome-other
                                        , output  parincass
                                        , output  parincass-bank
                                        , output  parincass-other
                                        , output  parincass-cassa
                                        ).
    display stream PrnLibStream
            "   Остаток на конец  Всего на АЗК" @ v-wth-name
            parstock-end @ v-sum
            sym1 sym2 sym3 sym4 sym5 sym6 sym7
            with frame f-wth
    .
    down stream PrnLibStream 1 with frame f-wth .
 end.
end.
  end.
  when 4
  then do:
        for each b_wth-doc no-lock
          where b_wth-doc.obj-type  = buf_clients.obj-type
            and b_wth-doc.obj-code  = buf_clients.obj-code
            and b_wth-doc.shift-date >= x-date-start
            and b_wth-doc.shift-date <= x-date-end
            and b_wth-doc.shift-num = x-shift-alone
            and b_wth-doc.status_   = 'факт':U
          ,each buf_wth-line
          where buf_wth-line.doc-code = b_wth-doc.doc-code
          break by b_wth-doc.doc-code by buf_wth-line.wth-code by buf_wth-line.w-p-code
          :
                run r-wth-fill-tt in this-procedure.
        end.
        for each tt-rep-doc no-lock
          , each ub.wealth
          where ub.wealth.wth-code = tt-rep-doc.wth-code
          , each buf_wth-place
          where buf_wth-place.host-code = buf_clients.host-code
            and buf_wth-place.obj-type  = buf_clients.obj-type
            and buf_wth-place.obj-code  = buf_clients.obj-code
            and buf_wth-place.w-p-code  = tt-rep-doc.w-p-code
        break by tt-rep-doc.wth-code by tt-rep-doc.w-p-code by tt-rep-doc.chk-type by tt-rep-doc.ext-doc-type
        by tt-rep-doc.shift-date   by tt-rep-doc.cli-name
        :
            assign
                x-shift-start   = x-shift-alone
                x-shift-end     = x-shift-alone
            .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (p-wth-ser and wealth.is-ser = 1) or
   (p-wth-money and wealth.is-money) or
   (p-wth-un and wealth.is-ser = 0 and not wealth.is-money ) then.
else next.
if first-of (tt-rep-doc.wth-code)
then do:
    if not first(tt-rep-doc.wth-code)
    then put stream PrnLibStream
        skip
          "|" at 3
          v-single-line format "X(178)"
          "|"
    .
        DISPLAY STREAM PrnLibStream
                wealth.wth-name @ v-wth-name
                sym1 sym2 sym3 sym4 sym5 sym6 sym7
                with frame f-wth
        .
        down stream PrnLibStream 1 with frame f-wth .
    if x-radio-task <> 4 or x-date-start = x-date-end
    then do:
        run wth-lib_full-inf-shift(
                                              input buf_clients.obj-type
                                            , input buf_clients.obj-code
                                            , input tt-rep-doc.wth-code
                                            , input x-date-start
                                              , input  x-shift-start
                                            , output  parstock-start
                                            , output  parstock-end
                                            , output  parincome
                                            , output  parincome-cassa
                                            , output  parincome-other
                                            , output  parincass
                                            , output  parincass-bank
                                            , output  parincass-other
                                            , output  parincass-cassa
                                  ).
        display stream PrnLibStream
                "   Остаток на начало Всего на АЗК" @ v-wth-name
                parstock-start  @ v-sum
                sym1 sym2 sym3 sym4 sym5 sym6 sym7
                with frame f-wth
        .
        down stream PrnLibStream 1 with frame f-wth .
    end.
end.
if first-of(tt-rep-doc.w-p-code) then do:
  if x-radio-task <> 4 or x-date-start = x-date-end then do:
            run wth-lib_full-inf-shift-place(
                                    input  buf_clients.obj-type
                                  , input  buf_clients.obj-code
                                  , input  tt-rep-doc.wth-code
                                  , input  tt-rep-doc.w-p-code
                                  , input  x-date-start
                                    , input  x-shift-start
                                  , output parstock-start
                                  , output parstock-end
                                  , output parincome
                                  , output parincome-cassa
                                  , output parincome-other
                                  , output parincass
                                  , output parincass-bank
                                  , output parincass-other
                                  , output parincass-cassa
            ).
            display stream PrnLibStream
                    "     Остаток на начало периода по " + buf_wth-place.w-p-name  @ v-wth-name
                    parstock-start @ v-sum
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7
                    with frame f-wth
            .
            down stream PrnLibStream 1 with frame f-wth .
  end.
  else do:
            display stream PrnLibStream
                    "     " + buf_wth-place.w-p-name  @ v-wth-name
                    parstock-start @ v-sum
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7
                    with frame f-wth
            .
            down stream PrnLibStream 1 with frame f-wth .
  end.
end.
if first-of(tt-rep-doc.chk-type) or
   first-of(tt-rep-doc.ext-doc-type)
 then do:
 v-type-sum = 0.
    if tt-rep-doc.chk-type <> 99 then case tt-rep-doc.chk-type:
      when 0 then v-chk-type = 'Реализация'.
      when 2 then v-chk-type = 'Инкассация'.
      when 3 then v-chk-type = 'Кассовый фонд'.
      when 4 then v-chk-type = 'Перевод оплаты'.
      when 5 then v-chk-type = 'Выплата'.
      otherwise  v-chk-type =  'Прочее'.
    end.
    else v-chk-type =  ENTRY(LOOKUP(tt-rep-doc.ext-doc-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u), 'приход внешний,расход внешний,приход внутренний,расход внутренний,приход внутри объекта,расход внутри объекта,приход внутриобъектн. в своб. зону,расход внутриобъектн. из своб. зоны,приход внутриобъектн. в зону погаш.,расход внутриобъектн. из зоны погаш.,списание,приход внешний через кассы,возврат покупателю через кассы,инвентаризация,возврат внутренний,приход внутр. в зону погашения,расход внутр. из зоны погашения,возврат внутр. в зону погашения,приход внутр. в своб. зону,расход внутр. из своб. зоны,возврат внутр. в своб зону,погашение через кассу,погашение за реализованное топливо,возврат от покупателя,уничтожение в свободной зоне,уничтожение в зоне погашения,уничтожение в зоне клиента,декларация,обмен':u).
    DISPLAY STREAM PrnLibStream
 '                     '  + v-chk-type
     @ v-wth-name
       with frame f-wth
.
end.
assign
    v-wth-name = wealth.wth-name
    v-doc-date = tt-rep-doc.fact-date
    v-doc-code = tt-rep-doc.doc-code
    v-sum      = (if (tt-rep-doc.doc-type = 'рас':U or tt-rep-doc.doc-type = 'спи':U) then 0 - tt-rep-doc.fact-sum else tt-rep-doc.fact-sum )
    v-type-sum = v-type-sum + v-sum
.
if tt-rep-doc.inter_ = yes
then do:
    find first buf_out_wth-place no-lock
         where buf_out_wth-place.host-code = tt-rep-doc.host-code
          and  buf_out_wth-place.obj-type = tt-rep-doc.obj-type
          and  buf_out_wth-place.obj-code = tt-rep-doc.obj-code
          and  buf_out_wth-place.w-p-code = tt-rep-doc.out-code
    .
    assign
        v-deliver  = (if     tt-rep-doc.doc-type = 'при':U
                        then buf_out_wth-place.w-p-name
                        else buf_wth-place.w-p-name
                     )
        v-receiver = (if     tt-rep-doc.doc-type = 'при':U
                        then buf_wth-place.w-p-name
                        else buf_out_wth-place.w-p-name
                     )
    .
end.
else do:
    assign
        v-deliver  = (if     tt-rep-doc.doc-type = 'при':U
                        then tt-rep-doc.cli-name
                        else buf_wth-place.w-p-name
                    )
        v-receiver = (if     tt-rep-doc.doc-type = 'при':U
                        then buf_wth-place.w-p-name
                        else tt-rep-doc.cli-name
                    )
    .
end.
DISPLAY STREAM PrnLibStream
        v-doc-date
        v-doc-code
        v-deliver
        v-receiver
        v-sum
        sym1 sym2 sym3 sym4 sym5 sym6 sym7
        with frame f-wth
.
DOWN STREAM PrnLibStream 1 with frame f-wth .
if last-of(tt-rep-doc.chk-type) or
   (last-of(tt-rep-doc.ext-doc-type) and not tt-rep-doc.chk-type = 0)
 then do:
  v-sum = v-type-sum.
    DISPLAY STREAM PrnLibStream
    '               Итого ' + v-chk-type  @ v-wth-name
    v-sum
    sym1 sym2 sym3 sym4 sym5 sym6 sym7
    with frame f-wth
    .
DOWN STREAM PrnLibStream 1 with frame f-wth .
end.
if last-of(tt-rep-doc.w-p-code) then do:
     if x-radio-task <> 4 or x-date-start = x-date-end
  then do:
            run wth-lib_full-inf-shift-place(
                                  input  buf_clients.obj-type
                                , input  buf_clients.obj-code
                                , input  tt-rep-doc.wth-code
                                , input  tt-rep-doc.w-p-code
                                , input  x-date-end
                                  , input  x-shift-end
                                , output parstock-start
                                , output parstock-end
                                , output parincome
                                , output parincome-cassa
                                , output parincome-other
                                , output parincass
                                , output parincass-bank
                                , output parincass-other
                                , output parincass-cassa
          ).
          display stream PrnLibStream
                  "     Остаток на конец  периода по " + buf_wth-place.w-p-name @ v-wth-name
                  parstock-end @ v-sum
                  sym1 sym2 sym3 sym4 sym5 sym6 sym7
                  with frame f-wth
          .
          down stream PrnLibStream 1 with frame f-wth .
      end.
end.
if last-of (tt-rep-doc.wth-code)
then do:
   if x-radio-task <> 4 or x-date-start = x-date-end
   then do:
      for each wth-place
         where wth-place.host-code = buf_clients.host-code
         and wth-place.obj-type  = buf_clients.obj-type
         and wth-place.obj-code  = buf_clients.obj-code
         and not can-find(first buf_tt-doc where buf_tt-doc.w-p-code = wth-place.w-p-code and buf_tt-doc.wth-code = tt-rep-doc.wth-code):
                run wth-lib_full-inf-shift-place(
                                      input  buf_clients.obj-type
                                    , input  buf_clients.obj-code
                                    , input  tt-rep-doc.wth-code
                                    , input  wth-place.w-p-code
                                    , input  x-date-end
                                      , input  x-shift-end
                                    , output parstock-start
                                    , output parstock-end
                                    , output parincome
                                    , output parincome-cassa
                                    , output parincome-other
                                    , output parincass
                                    , output parincass-bank
                                    , output parincass-other
                                    , output parincass-cassa
              ).
              display stream PrnLibStream
                      "     Остаток на конец  периода по " + wth-place.w-p-name @ v-wth-name
                      parstock-end @ v-sum
                      sym1 sym2 sym3 sym4 sym5 sym6 sym7
                      with frame f-wth
              .
              down stream PrnLibStream 1 with frame f-wth .
      end.
        run wth-lib_full-inf-shift (
                                          input buf_clients.obj-type
                                        , input buf_clients.obj-code
                                        , input tt-rep-doc.wth-code
                                        , input x-date-end
                                        , input  x-shift-end
                                        , output  parstock-start
                                        , output  parstock-end
                                        , output  parincome
                                        , output  parincome-cassa
                                        , output  parincome-other
                                        , output  parincass
                                        , output  parincass-bank
                                        , output  parincass-other
                                        , output  parincass-cassa
                                        ).
    display stream PrnLibStream
            "   Остаток на конец  Всего на АЗК" @ v-wth-name
            parstock-end @ v-sum
            sym1 sym2 sym3 sym4 sym5 sym6 sym7
            with frame f-wth
    .
    down stream PrnLibStream 1 with frame f-wth .
  end.
end.
        end.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if x-radio-task <> 4 or x-date-start = x-date-end then do:
 for each buf_wealth no-lock where
      not can-find(first tt-rep-doc where tt-rep-doc.wth-code = buf_wealth.wth-code )
      and ((p-wth-ser and buf_wealth.is-ser = 1) or
          (p-wth-money and buf_wealth.is-money) or
          (p-wth-un and buf_wealth.is-ser = 0 and not buf_wealth.is-money )) :
          DISPLAY STREAM PrnLibStream
                buf_wealth.wth-name @ v-wth-name
                sym1 sym2 sym3 sym4 sym5 sym6 sym7
                with frame f-wth
        .
        down stream PrnLibStream 1 with frame f-wth .
      for each ub.wth-place
         where ub.wth-place.host-code = buf_clients.host-code
         and ub.wth-place.obj-type  = buf_clients.obj-type
         and ub.wth-place.obj-code  = buf_clients.obj-code:
                run wth-lib_full-inf-shift-place(
                                      input  buf_clients.obj-type
                                    , input  buf_clients.obj-code
                                    , input  buf_wealth.wth-code
                                    , input  wth-place.w-p-code
                                    , input  x-date-end
                                      , input  x-shift-end
                                    , output parstock-start
                                    , output parstock-end
                                    , output parincome
                                    , output parincome-cassa
                                    , output parincome-other
                                    , output parincass
                                    , output parincass-bank
                                    , output parincass-other
                                    , output parincass-cassa
              ).
              display stream PrnLibStream
                      "     Остаток на конец  периода по " + wth-place.w-p-name @ v-wth-name
                      parstock-end @ v-sum
                      sym1 sym2 sym3 sym4 sym5 sym6 sym7
                      with frame f-wth
              .
              down stream PrnLibStream 1 with frame f-wth .
      end.
            run wth-lib_full-inf-shift (
                                              input buf_clients.obj-type
                                            , input buf_clients.obj-code
                                            , input buf_wealth.wth-code
                                            , input x-date-end
                                            , input  x-shift-end
                                        , output  parstock-start
                                        , output  parstock-end
                                        , output  parincome
                                        , output  parincome-cassa
                                        , output  parincome-other
                                        , output  parincass
                                        , output  parincass-bank
                                        , output  parincass-other
                                        , output  parincass-cassa
                                        ).
    display stream PrnLibStream
            "   Остаток на конец  Всего на АЗК" @ v-wth-name
            parstock-end @ v-sum
            sym1 sym2 sym3 sym4 sym5 sym6 sym7
            with frame f-wth
    .
    down stream PrnLibStream 1 with frame f-wth .
 end.
end.
  end.
end case.
put stream PrnLibStream
  skip
    v-single-line format "X(178)" at 3 + 1
.
hide stream PrnLibStream frame bottomframe .
output stream PrnLibStream close.
run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 8
                                          ).
end.
procedure r-wth-fill-tt:
      if b_wth-doc.doc-type = 'de':U and b_wth-doc.doc-type = 'dc':U then return.
            create tt-rep-doc.
            buffer-copy buf_wth-line to tt-rep-doc.
            buffer-copy b_wth-doc using cli-name host-code inter_ doc-type ext-doc-type exter_ to tt-rep-doc.
            if b_wth-doc.source-type = 'касса':U
            then tt-rep-doc.chk-type = 99.
            else if b_wth-doc.auto-fill and b_wth-doc.borned = no then
            for first buf_chk-doc no-lock
             where buf_chk-doc.out-code = b_wth-doc.doc-code
             and buf_chk-doc.obj-type   = b_wth-doc.obj-type
             and buf_chk-doc.obj-code   = b_wth-doc.obj-code:
             tt-rep-doc.chk-type = buf_chk-doc.chk-type.
             tt-rep-doc.ext-doc-type = ''.
            end.
            else if b_wth-doc.auto-fill and b_wth-doc.borned = yes then
              for first buf_wth-doc no-lock where
                buf_wth-doc.doc-code = b_wth-doc.source-ref
                and buf_wth-doc.auto-fill = yes
             ,first buf_chk-doc no-lock
             where buf_chk-doc.out-code = buf_wth-doc.doc-code
             and buf_chk-doc.obj-type   = buf_wth-doc.obj-type
             and buf_chk-doc.obj-code   = buf_wth-doc.obj-code:
             tt-rep-doc.chk-type = buf_chk-doc.chk-type .
             tt-rep-doc.ext-doc-type = ''.
            end.
            else tt-rep-doc.chk-type = 99.
            if tt-rep-doc.chk-type = 7 then delete tt-rep-doc.
end procedure.
