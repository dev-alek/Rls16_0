define input parameter parparentproc as widget-handle no-undo .
define input-output parameter CashierQRCode as char no-undo .
define temp-table tt0-staff no-undo like ub.staff.
DEFINE INPUT PARAMETER TABLE FOR tt0-staff.
define output parameter p-update as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: view-qrCode.w $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/view-qrCode.w $":U .
define variable vss-description as character no-undo init "QrCode".
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
DEFINE VARIABLE v-image-order      AS CHARACTER NO-UNDO INIT "jpg,bmp":U.
define variable v-image-format     as character extent 62 init
[
 "Windows bitmap                                                          ", "*.bmp"
,"Computer-aided Acquisition and Logistics Support                        ", "*.cal"
,"Microsoft Windows Clipboard                                             ", "*.clp"
,"Halo CUT                                                                ", "*.cut"
,"Intel FAX format                                                        ", "*.dcx"
,"Windows device-independent bitmap                                       ", "*.dib"
,"Encapsulated PostScript                                                 ", "*.eps"
,"1 Graphics Interchange Format                                           ", "*.gif"
,"IBM IOCA                                                                ", "*.ica"
,"Microsoft Icon File format                                              ", "*.ico"
,"Amiga IFF                                                               ", "*.iff"
,"GEM bitmap                                                              ", "*.img"
,"Joint Bi-level Image Experts Group                                      ", "*.jbig"
,"JPEG                                                                    ", "*.jpg"
,"serView                                                                 ", "*.lv "
,"Macintosh MacPaint                                                      ", "*.mac"
,"Microsoft Windows Paint                                                 ", "*.msp"
,"Kodak Photo CD                                                          ", "*.pcd"
,"Macintosh PICT                                                          ", "*.pct"
,"PC Paintbrush                                                           ", "*.pcx"
,"GIF (Graphics Interchange Format) replacement                           ", "*.png"
,"Adobe Photoshop                                                         ", "*.psd"
,"Sun Raster (1-, 8-, 24-, or 32-bit Standard, BGR, RGB, and byte encoded)", "*.ras"
,"TARGA                                                                   ", "*.tga"
,"Tag image file format                                                   ", "*.tif"
,"Windows bitmap for wireless devices                                     ", "*.wbmp"
,"Windows metafiles                                                       ", "*.wmf"
,"WordPerfect graphics                                                    ", "*.wpg"
,"(also .bm) X bitmap                                                     ", "*.xbm"
,"Pixmap                                                                  ", "*.xpm"
,"UNIX X Window Dump File format                                          ", "*.xwd"
] no-undo.
procedure get-custom-img-order :
define output parameter p-descriptions as character no-undo .
define output parameter p-extensiond   as character no-undo .
define output parameter p-extensiont   as character no-undo .
define variable ii as integer no-undo .
define variable v-entry as integer no-undo .
  do
  on error undo, return error
  :
    assign
    p-descriptions = fill(chr(4), 30)
    p-extensiond   = fill(chr(4), 30)
    p-extensiont   = fill(chr(4), 30)
    .
    do ii = 2 to 62 by 2:
      assign
      v-entry = lookup(left-trim(v-image-format[ii], ".*"), v-image-order)
      .
      if v-entry > 0 then do:
        assign
        entry(v-entry, p-descriptions, chr(4)) = substitute("&1 &2", trim(v-image-format[ii - 1]), v-image-format[ii])
        entry(v-entry, p-extensiond, chr(4)) = v-image-format[ii]
        entry(v-entry, p-extensiont, chr(4)) = left-trim(v-image-format[ii], ".*")
        .
      end.
    end.
    assign
    p-descriptions = trim(p-descriptions, chr(4))
    p-extensiond   = trim(p-extensiond, chr(4))
    p-extensiont   = trim(p-extensiont, chr(4))
    p-descriptions = replace(p-descriptions, (chr(4) + chr(4)), chr(4))
    p-extensiond   = replace(p-extensiond, (chr(4) + chr(4)),  chr(4))
    p-extensiont   = replace(p-extensiont, (chr(4) + chr(4)), chr(4))
    .
  end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure base64-encode :
  define input  parameter v-string        as character no-undo .
  define output parameter v-base64-encode as character no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-raw     as raw       no-undo .
    define variable v-raw-str as character no-undo .
    if v-string = ?
    then do:
      undo, return error "base64-encode: строка имеет неопределенное значение" .
    end.
    assign
      length(v-raw) = length(v-string) + 1
    .
    assign
      put-string(v-raw, 1) = v-string
    .
    assign
      v-raw-str = string(v-raw)
    .
    assign
      length(v-raw) = 0
    .
    assign
      v-base64-encode = substring(v-raw-str, 7)
    .
  end.
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure db-attr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-code in g#attr-lib
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
procedure db-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-tooltip in g#attr-lib
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
procedure db-attr-value :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-value     like ub.db-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-value in g#attr-lib
      (input  p-db-num
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
procedure db-attr-write :
  define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input parameter p-code      like ub.db-attr.attr-code  no-undo .
  define input parameter p-value     like ub.db-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-write in g#attr-lib
      (input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-exist :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-delete :
  define input  parameter p-db-num   like ub.db-attr.db-num     no-undo .
  define input  parameter p-code     like ub.db-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile: frmlib.i $ $Revision: aea5316774be, 0, rls $".
FUNCTION Break-n-line RETURNS CHARACTER
  ( INPUT p-ost as char,
    INPUT p-lengths  as character,
    OUTPUT output-num-lines as integer
    ) :
define variable ii as integer no-undo.
define variable jj as integer no-undo.
define variable linei as character no-undo extent 10.
define variable line-length as integer no-undo extent 10.
define variable num-line as integer no-undo .
define variable v-line as character no-undo .
do ii = 1 to MIN(num-entries(p-lengths), 10):
  assign
  line-length[ii] = integer(entry(ii, p-lengths))
  num-line = ii
  .
end.
do jj = 1 to num-line:
  if Length ( p-ost ) <= line-length[jj] then do:
    assign
    output-num-lines = jj
    v-line = v-line + (if jj = 1 then "":U else chr(4)) + p-ost
    .
    return v-line.
  end.
  assign
  ii = 1
  .
  if length( entry( ii, p-ost , chr(32)) ) > line-length[jj]
  then do:
    assign
    linei[jj] = substr( p-ost , 1 , line-length[jj] )
    p-ost = trim( substr( p-ost , line-length[jj] + 1 ) )
    .
  end.
  else do:
    DO WHILE length( linei[jj] + entry( ii, p-ost , chr(32)) ) < ( line-length[jj] + 1 ) :
      assign
      linei[jj] = linei[jj] + entry( ii, p-ost , chr(32)) + chr(32)
      ii = ii + 1
      .
      if length( entry( ii, p-ost, chr(32) ) ) > line-length[jj] then
      assign
      linei[jj] = linei[jj] + substr( p-ost , length( linei[jj] ) , line-length[jj] - length( linei[jj] ) + 1 )
      .
    END.
    assign
    p-ost = trim( substr( p-ost , length(linei[jj]) + 1  ))
    .
  end.
  assign
  v-line = v-line + (if jj = 1 then "":U else chr(4)) + linei[jj]
  .
  if p-ost = "":U then LEAVE.
end.
assign
output-num-lines = jj.
RETURN v-line.
END FUNCTION.
FUNCTION Center-Field RETURNS CHARACTER
  ( INPUT p-str as char,
    INPUT p-format as integer,
    INPUT p-Length as integer,
    INPUT p-fill as character
    ) :
define variable v-str as character no-undo .
define variable v-left as integer no-undo .
define variable v-dop as integer no-undo .
assign
p-str = trim(p-str)
.
if p-str = "":U then return fill(p-fill, p-length).
if length(p-str) >= p-format then
p-str = substr(p-str, 1, p-format).
else do:
  p-format = length(p-str).
end.
if p-format < p-length then do:
  assign
  v-left = (p-length - p-format )
  v-dop = (if v-left modulo 2 = 1
           then 1
           else 0)
  v-left = (if (v-left modulo 2 = 1)
           then (v-left - 1 ) / 2
           else v-left / 2)
  v-str =  fill(p-fill, v-left) +
           string(p-str, "X(":U + string(p-format) + ")":U) +
           fill(p-fill, v-left) + fill(p-fill, v-dop)
  .
  return v-str.
end.
else do:
  return string(p-str, "X(":U + string(p-length) + ")":U).
end.
END FUNCTION.
FUNCTION Left-Field RETURNS CHARACTER
  ( INPUT p-str as char,
    INPUT p-format as integer,
    INPUT p-Length as integer,
    INPUT p-fill as character
    ) :
define variable v-str as character no-undo .
define variable v-left as integer no-undo .
define variable v-dop as integer no-undo .
assign
p-str = trim(p-str)
.
if p-str = "":U then return fill(p-fill, p-length).
if length(p-str) >= p-format then
p-str = substr(p-str, 1, p-format).
else do:
  p-format = length(p-str).
end.
if p-format < p-length then do:
  assign
  v-dop =  p-length - p-format
  v-str =  string(p-str, "X(":U + string(p-format) + ")":U) +
           fill(p-fill, v-dop)
  .
  return v-str.
end.
else do:
  return string(p-str, "X(":U + string(p-length) + ")":U).
end.
END FUNCTION.
FUNCTION Sum-Rub-Kop-Digit RETURNS CHARACTER
  ( INPUT p-sum as decimal,
    INPUT p-rub-length as integer,
    INPUT p-kop-length as integer,
    INPUT p-fill as character,
    INPUT p-razr-delim as character,
    INPUT p-rub-str  as character,
    INPUT p-kop-str  as character
    ) :
define variable v-str as character no-undo .
define variable v-format as character no-undo .
define variable v-dopi as integer no-undo .
define variable v-dopi2 as integer no-undo .
assign
v-dopi = length(string(truncate(ABS(p-sum), 0)))
v-dopi2 = truncate(v-dopi / 3, 0) - (if v-dopi modulo  3 = 0 then 1 else 0)
.
if v-dopi > p-rub-length or p-kop-length < 2 then return "?".
assign
v-format = (if p-sum < 0 then "-":U else "":U) + fill((">>>":U + p-razr-delim), v-dopi2) + ">>9":U
v-dopi = length(trim(string(truncate(p-sum, 0), v-format)))
.
assign
v-str = fill(p-fill, p-rub-length - v-dopi) +
        string(truncate(p-sum, 0), v-format) +
        p-rub-str +
        fill(p-fill, p-kop-length - 2) +
        string(truncate((ABS(p-sum) - ABS(truncate(p-sum, 0))), 2) * 100, "99":U) + p-kop-str
.
return v-str.
END FUNCTION.
FUNCTION Sum-Invalut-Digit RETURNS CHARACTER
  ( INPUT p-sum as decimal,
    INPUT p-sum-length as integer,
    INPUT p-curr-code as integer,
    INPUT p-fill as character,
    INPUT p-razr-delim as character
    ) :
define variable v-str as character no-undo .
define variable v-format as character no-undo .
define variable v-dopi as integer no-undo .
define variable v-dopi2 as integer no-undo .
define variable v-curr-name as character no-undo .
define buffer buf_currency for ub.currency.
find first buf_currency no-lock where
          buf_currency.curr-code = p-curr-code no-error .
if not avail buf_currency
then v-curr-name = "неизвестная валюта".
else
assign
v-curr-name = buf_currency.curr-name
.
assign
v-dopi = length(string(truncate(ABS(p-sum), 0)))
v-dopi2 = truncate(v-dopi / 3, 0) - (if v-dopi modulo  3 = 0 then 1 else 0)
.
if v-dopi > p-sum-length then return "?".
assign
v-format = (if p-sum < 0 then "-":U else "":U) + fill((">>>":U + p-razr-delim), v-dopi2) + ">>9.99":U
v-dopi = length(trim(string(p-sum, v-format)))
.
assign
v-str = "(":U + chr(32) + v-curr-name +  chr(32) + ")":U +
        fill(p-fill, p-sum-length - v-dopi - length(v-curr-name) - 4)  +
        trim(string(p-sum, v-format))
.
return v-str.
END FUNCTION.
FUNCTION Sum-in-Words-Without-Dec RETURNS CHARACTER
(input v-sum as decimal
):
define variable v-str as character no-undo .
run gbl/num-rus.p ( input absolute( v-sum ) , output v-str).
v-str = trim( caps( substring( v-str, 1, 1 ) ) ) + substring( v-str, 2 ).
return v-str.
END FUNCTION.
FUNCTION Sum-in-Words-Invalut RETURNS CHARACTER
(input p-sum as decimal
 ,input p-curr-code as integer
):
define variable v-str as character no-undo .
define variable Copeck as character no-undo.
define variable Rouble as character no-undo.
define variable v-Word as character no-undo.
define variable ii as integer init 18 no-undo.
define variable v-str-rubl as character no-undo .
define variable v-kop as integer no-undo .
define buffer buf_currency for ub.currency.
assign
v-Word = string( absolute( p-sum ) , "999999999999999.99" ).
find first buf_currency no-lock where
          buf_currency.curr-code = p-curr-code no-error .
if not available buf_currency then return chr(63).
if decimal( substring(v-Word,1,ii - 3) ) <> 0 then do:
  CASE substring(v-Word, ii - 3,1):
    WHEN "1" THEN DO:
      if substring(v-Word, ii - 4,1) = "1" then
          Rouble = buf_currency.curr-name-five .
      else
          Rouble = buf_currency.curr-name-one .
    END.
    WHEN "2" OR WHEN "3" OR WHEN "4" THEN  DO:
      if substring(v-Word, ii - 4,1) = "1" then
         Rouble = buf_currency.curr-name-five .
         else
         Rouble = buf_currency.curr-name-three .
      END.
    WHEN "0" OR WHEN "5" OR WHEN "6" OR WHEN "7" OR WHEN "8" OR WHEN "9" THEN  DO:
       Rouble = buf_currency.curr-name-five .
    END.
  END CASE.
end.
CASE substring(v-Word, ii, 1):
  WHEN "1" THEN DO:
    if substring(v-Word, ii - 1, 1) = "1" then
        Copeck = buf_currency.part-name-five .
    else
        Copeck = buf_currency.part-name-one .
  END.
  WHEN "2" OR WHEN "3" OR WHEN "4" THEN DO:
    if substring(v-Word, ii - 1, 1) = "1" then
        Copeck = buf_currency.part-name-five .
    else
        Copeck = buf_currency.part-name-three .
  END.
  WHEN "0" OR WHEN "5" OR WHEN "6" OR WHEN "7" OR WHEN "8" OR WHEN "9" THEN DO:
    Copeck = buf_currency.part-name-five .
  END.
END CASE.
run gbl/num-rus.p ( input absolute( p-sum )
             , output v-str-rubl).
assign
v-kop = (absolute( p-sum ) - truncate(absolute(p-sum), 0)
        ) * 100
.
v-str = ( if p-Sum < 0 then "- " else "" ) +
            caps(substring(v-str-rubl, 1, 1)) +  substring(v-str-rubl, 2) + chr(32) + Rouble + chr(32) +
            string(v-kop, "99":U) + chr(32) + Copeck .
return v-str.
END FUNCTION.
FUNCTION Sum-delim-with-defis RETURNS CHARACTER
(input v-sum as decimal,
input v-razr as integer
):
define variable v-str as character no-undo .
define variable v-dec-separ as character no-undo .
case SESSION:NUMERIC-FORMAT:
  when "American":U then do:
    assign
    v-dec-separ = ".":U
    .
  end.
  when "European":U then do:
    assign
    v-dec-separ = ",":U
    .
  end.
END CASE.
assign
v-str = replace(string(v-sum, fill(">":U, v-razr - 1) + "9.99"), v-dec-separ, "-":U)
.
return v-str.
END FUNCTION.
FUNCTION MonthNameRusGen RETURNS CHARACTER ( INPUT i-month AS INTEGER ) :
  DEFINE VARIABLE v-name AS CHARACTER NO-UNDO.
  RUN get-month-name-gen IN THIS-PROCEDURE ( INPUT i-month, OUTPUT v-name ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v-name ).
END FUNCTION.
PROCEDURE get-month-name-gen :
  DEFINE  INPUT PARAMETER p-month AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-name  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-list AS CHARACTER NO-UNDO INITIAL "Января,Февраля,Марта,Апреля,Мая,Июня,Июля,Августа,Сентября,Октября,Ноября,Декабря".
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-name = ( IF p-month >= 1 AND p-month <= 12 THEN ENTRY( p-month, v-list ) ELSE ? ).
  END.
END PROCEDURE.
define variable stat as log no-undo .
define variable v-param-type as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable v-descriptions as character no-undo .
define variable v-extensiond   as character no-undo .
define variable v-extensiont   as character no-undo .
define variable new-code as character no-undo .
define stream Out-Stream.
define stream OutStr-html.
FUNCTION get-staff-name RETURNS CHARACTER ( input p-obj-name as character
                                          , input p-psn-code as integer
                                          , input p-stts as integer):
define variable v-full-name as character no-undo .
define buffer buf_person for ub.person.
find first buf_person no-lock where
          buf_person.psn-code = p-psn-code no-error.
v-full-name = substitute("&1 &2 &3"
                   , p-obj-name
                   , (if available buf_person then buf_person.name1 else '')
                   , (if available buf_person then buf_person.name2 else '')
                   ).
RETURN
(IF (p-stts = integer('0':U))
THEN v-full-name
ELSE (substring (v-full-name,1, 25) +
                FILL (chr(32), 25 - LENGTH (substring (v-full-name, 1, 25)) )) +
                '---  УДАЛЕН  ---':U).
END FUNCTION.
DEFINE BUTTON b-print
     IMAGE-UP FILE "cmp/b-print.bmp":U
     IMAGE-DOWN FILE "cmp/b-print.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/b-print.bmp":U NO-CONVERT-3D-COLORS
     LABEL "Печать"
     SIZE 3 BY 1.
DEFINE BUTTON B-qrCode
     LABEL "&Новый QR-код"
     SIZE 15 BY 1.
DEFINE BUTTON Btn_Close AUTO-GO
     LABEL "&Выход ":L
     SIZE 15 BY 1
     BGCOLOR 8 .
DEFINE IMAGE qr-code
     STRETCH-TO-FIT RETAIN-SHAPE
     SIZE 30.5 BY 10.75.
DEFINE FRAME DLGCLOSE
     Btn_Close AT ROW 1 COL 1
     B-qrCode AT ROW 1 COL 16
     b-print AT ROW 1 COL 36.75 WIDGET-ID 62
     qr-code AT ROW 3 COL 5.63
     SPACE(4.36) SKIP(0.95)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS THREE-D  SCROLLABLE
         BGCOLOR 8
         TITLE BGCOLOR 8 "QR-code кассира":L
         DEFAULT-BUTTON Btn_Close.
ASSIGN
       FRAME DLGCLOSE:SCROLLABLE       = FALSE
       FRAME DLGCLOSE:PRIVATE-DATA     =
                "DLGCLOSE".
ASSIGN
       Btn_Close:PRIVATE-DATA IN FRAME DLGCLOSE     =
                "Btn_Close".
ASSIGN
       qr-code:RESIZABLE IN FRAME DLGCLOSE        = TRUE.
ON CHOOSE OF B-qrCode IN FRAME DLGCLOSE
DO:
  define variable recid_attr as recid no-undo .
  run generate_qrCode(output CashierQRCode) .
  find first ub.staff-attr exclusive-lock where ub.staff-attr.attr-code = "CashierQRCode" and
    ub.staff-attr.date-start <= today and
    ub.staff-attr.role = tt0-staff.role and
    ub.staff-attr.staff-code = tt0-staff.staff-code and
    ub.staff-attr.role-level = tt0-staff.role-level no-error .
  if not available (ub.staff-attr) then
  do:
    create ub.staff-attr .
    assign
      ub.staff-attr.attr-code  = "CashierQRCode"
      ub.staff-attr.date-start = today
      ub.staff-attr.role       = tt0-staff.role
      ub.staff-attr.role-level = tt0-staff.role-level
      ub.staff-attr.staff-code = tt0-staff.staff-code
      .
  end.
  ub.staff-attr.attr-value = CashierQRCode .
  run print_qrCode(CashierQRCode).
  stat = qr-code:load-image( "" + session:temp-directory + "\qr-code.png":U) .
  p-update = true .
  DISPLAY
    qr-code
    WITH FRAME DLGCLOSE.
END.
ON choose of b-print in frame DLGCLOSE
DO:
  define variable p-report-id as character no-undo .
  define variable v-firm as character no-undo .
  define variable v-obj-name as character no-undo .
  define variable v-hist-code as character no-undo .
  define variable v-hist-name as character no-undo .
  define variable v-file-name-rep-htm as character no-undo .
  define variable par-type as character no-undo .
  define buffer buf_clients for ub.clients .
  define buffer buf_shop for ub.shop .
  run get-report-num (output p-report-id).
  v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".
  output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' .
  find first buf_clients no-lock where buf_clients.obj-type = 'орг':U and buf_clients.obj-code = v-cntxt-host-code-obj no-error .
  if available (buf_clients) then v-firm = buf_clients.obj-name .
  find first ub.firm no-lock where ub.firm.firm-code = v-cntxt-host-code-obj no-error .
  find first buf_shop no-lock where buf_shop.obj-code = v-cntxt-obj-code no-error .
  run db-attr-value(INPUT v-cntxt-db-num,INPUT 'hist-code':U,OUTPUT v-hist-code ,OUTPUT par-type) .
  run db-attr-value(INPUT v-cntxt-db-num,INPUT 'hist-name':U,OUTPUT v-hist-name ,OUTPUT par-type) .
  if v-hist-name = "" then v-hist-name = v-obj-name .
  do:
    put stream OutStr-html unformatted
"<!DOCTYPE HTML>" skip
' <html>' skip
'  <head>' skip
'   <meta charset="utf-8">' skip
'    <style type="text/css">' skip
'      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
'      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
'      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black;' + chr(125) skip
'   </style>' skip
'  </head>' skip
      '<body>' skip
      substitute('<TABLE name="&1" fit_to_page="true" orientation="portrait" repeat_rows="1:4" outline_below="false">', 'QR-code') skip
      '<thead>' skip
      '  <tr class="set_columns">' skip
      '    <td style="width: 400px;"></td>' skip
      '  </tr>' skip
      '  <tr>' skip
      '    <td text_wrap="true" style="text-align: center;">' + v-firm + '</td>' skip
      '  </tr>' skip
      '  <tr>' skip
      '    <td text_wrap="true" style="text-align: center;">' + v-hist-name + '</td>' skip
      '  </tr>' skip
      '  <tr>' skip
      '    <td text_wrap="true" style="text-align: center;">' + buf_shop.addres1 + '</td>' skip
      '  </tr>' skip
      '  <tr>' skip
      '    <td text_wrap="true" style="text-align: center;">' + buf_shop.addres2 + '</td>' skip
      '  </tr>' skip
      .
    if search( "" + session:temp-directory + "\qr-code.png":U ) <> ? then
    do:
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td style="text-align: center;"><img src="' + session:temp-directory + '\qr-code.png" width="130" height="130" alt=""/></td>' skip
        '</tr>' skip .
    end.
    else
    do:
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td text_wrap="true" style="text-align: center;"></td>' skip
        '</tr>' skip.
    end.
    find first ub.clients NO-LOCK WHERE ub.clients.obj-type = 'чел':U and ub.clients.obj-code = tt0-staff.psn-code no-error .
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td text_wrap="true" style="text-align: center;">' + get-staff-name ( ub.clients.obj-name, ub.clients.obj-code, ub.clients.stts ) + '</td>' skip
      '</tr>' skip.
  end.
  put stream OutStr-html unformatted
    '</thead>' skip
    '<tbody>' skip
    .
  put stream OutStr-html unformatted
    '</tbody>' skip
    '<tfoot>' skip
    .
  put stream OutStr-html unformatted
    '</tfoot>' skip
    '</table>' skip
    '</body>' skip
    '</html>' skip
    .
  output stream OutStr-html close.
  run prn-lib-reportviewer in this-procedure (
    input this-procedure
    ,input v-file-name-rep-htm
    ,input ""
    ) .
  if error-status:error then
  do:
    message return-value view-as alert-box.
    return .
  end.
  END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME DLGCLOSE:PARENT eq ?
THEN FRAME DLGCLOSE:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME DLGCLOSE APPLY "END-ERROR":U TO SELF.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
find first tt0-staff no-error .
  run print_qrCode(CashierQRCode).
  if CashierQRCode <> "" then
    stat = qr-code:load-image( "" + session:temp-directory + "\qr-code.png":U) .
    run enable_UI in this-procedure .
    WAIT-FOR GO OF FRAME DLGCLOSE.
END.
run disable_UI in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME DLGCLOSE.
END PROCEDURE.
PROCEDURE print_qrCode :
  define input parameter p-code as character no-undo .
    define variable v-arc as character no-undo .
    define variable v-cmd as character no-undo .
    assign
      v-arc = search( "exe/qrgen.exe":U )
      .
    if v-arc = ? then
    do:
      return error "Не найдена программа qrgen.exe" .
    end.
    os-command silent value (v-arc + ' -size=128 -content="' + p-code + '"' + ' -filename="' + session:temp-directory + '\qr-code"') .
END PROCEDURE.
PROCEDURE generate_qrCode :
  define output parameter qr-code-out as character no-undo .
  define variable new-code as character no-undo .
  define variable v-code as character no-undo .
  v-code = string(v-cntxt-obj-code,"99999") + string(tt0-staff.staff-code,"999") + string(random( 11111 , 99999 )) .
  run adm/pswd-enc.p (input v-code, output new-code) .
  run base64-encode (new-code,output qr-code-out).
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE Btn_Close qr-code B-qrCode b-print
      WITH FRAME DLGCLOSE.
END PROCEDURE.
PROCEDURE get-report-num :
  define output parameter p-report-num as integer no-undo .
  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.
END PROCEDURE.
