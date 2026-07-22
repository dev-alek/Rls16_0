define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экспорт результатов продаж".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define stream txt.
define variable prt-name as char no-undo.
define variable t1 as char no-undo.
define variable ref-list as char no-undo.
define buffer ret-doc for ub.trn-doc.
define variable parts_qnty as dec no-undo.
define variable p-t like ub.doc-line.prod-type no-undo.
define variable p-c like ub.doc-line.prod-code no-undo.
define variable p-a like ub.doc-line.artic no-undo.
define variable b-c like ub.chk-gds.src-code no-undo.
define variable chk-qnty like ub.doc-line.fact-qnty no-undo.
define variable chk-price like ub.doc-line.price-base no-undo.
DEFINE BUTTON B-file
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-file-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.25.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE cli-code AS INTEGER FORMAT ">>>>>>>>>9":U INITIAL 0
     LABEL "Поставщик"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE cli-name AS CHARACTER FORMAT "X(25)":U
     VIEW-AS FILL-IN
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE date-beg AS DATE FORMAT "99/99/9999":U
     LABEL "Даты С"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE date-End AS DATE FORMAT "99/99/9999":U
     LABEL "По"
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1 NO-UNDO.
DEFINE VARIABLE file-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл"
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     date-beg AT ROW 2.75 COL 10.5 COLON-ALIGNED
     date-End AT ROW 2.75 COL 30 COLON-ALIGNED
     cli-code AT ROW 4.25 COL 11.5 COLON-ALIGNED
     cli-name AT ROW 4.25 COL 22 COLON-ALIGNED NO-LABEL
     B-file AT ROW 4.25 COL 48.5
     B-file-2 AT ROW 5.5 COL 48.5
     file-name AT ROW 5.75 COL 2.5
     SPACE(4.62) SKIP(0.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Экспорт чеков по поставщику в файл"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-file IN FRAME Dialog-Frame
DO:
  run ref/cli-all.w (input parparentproc, "b-sel,b-add", ?, ?, ?, ?, ?, ?, output ref-list).
  if ref-list = "" then
    return no-apply.
  find ub.clients where recid (ub.clients) = integer (ref-list) no-lock.
  if avail ub.clients then do:
     assign
         cli-code = ub.clients.obj-code
         cli-name = ub.clients.obj-name.
         DISP cli-code cli-name WITH FRAME Dialog-Frame.
  end.
  else     return no-apply.
END.
ON CHOOSE OF B-file-2 IN FRAME Dialog-Frame
DO:
    DEF VAR ll_commit AS LOG    NO-UNDO INIT NO.
    SYSTEM-DIALOG GET-FILE file-name
        TITLE "Выберите файл для экспорта"
        FILTERS
          " Текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
        ask-overwrite
        save-as
        use-filename
        update ll_commit
        default-extension "txt"
        .
    IF ll_commit <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF file-name = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN file-name = ( IF SEARCH( file-name ) = ? THEN file-name ELSE SEARCH( file-name ) ).
    DISP file-name WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
define buffer buf_inkas for ub.inkas.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_parts for ub.parts.
define buffer buf_doc-line for ub.doc-line.
define variable v-gds-code as integer no-undo .
assign
date-beg
date-end
.
if date-beg > date-end then do:
  message
  "Дата начала периода должна быть меньше даты конца"
  view-as alert-box error .
  undo, return no-apply.
end.
if date-beg = ? then do:
  message
  "Не задана дата C"
  view-as alert-box error .
  undo, return no-apply.
end.
if date-end = ? then do:
  message
  "Не задана дата По"
  view-as alert-box error .
  undo, return no-apply.
end.
if trim(file-name) = "" then do:
  message
  "Не задан файл для экспорта"
  view-as alert-box error .
  undo, return no-apply.
end.
output stream txt to value (file-name) no-echo.
FOR EACH buf_inkas no-LOCK where
buf_inkas.doc-date >= date-beg AND
buf_inkas.doc-date <= date-end AND
buf_inkas.obj-type = v-cntxt-obj-type AND
buf_inkas.obj-code = v-cntxt-obj-code AND
buf_inkas.status_ = 'факт':U
by buf_inkas.doc-date :
  FIND FIRST buf_trn-doc No-LOCK WHERE buf_trn-doc.doc-code = buf_inkas.inkas-code   NO-ERROR.
  if avail buf_trn-doc
  then do:
    assign
    b-c = ""
    chk-price = 0
    chk-qnty = 0
    p-t = ""
    p-c = ?
    p-a = ""
    parts_qnty = 0
    v-gds-code = 0
    .
    FOR  each buf_doc-line NO-LOCk WHERE buf_doc-line.doc-code = buf_trn-doc.doc-code
    by buf_doc-line.prod-type
    by buf_doc-line.prod-code
    by buf_doc-line.artic
    :
      display
      buf_doc-line.doc-code
      buf_doc-line.artic
      with frame ff view-as dialog-box
      title ": Экспорт чеков в файл".
      pause 0.
      if p-c <> ? then do:
        if  p-t <> buf_doc-line.prod-type
        or  p-c <> buf_doc-line.prod-code
        or p-a <> buf_doc-line.artic   then do:
          if  parts_qnty <> 0 then do:
            for each buf_CHK-GDS no-lock where
            buf_CHK-GDS.out-code = buf_trn-doc.doc-code   and
            buf_CHK-GDS.doc-qnty <> 0          :
              find buf_bar-code where buf_bar-code.b-code = buf_CHK-GDS.b-code no-lock no-error.
              if not avail buf_bar-code then next.
              if  buf_bar-code.gds-code = v-gds-code then do:
                chk-qnty = chk-qnty + buf_CHK-GDS.doc-qnty.
                chk-price = chk-price + ((buf_CHK-GDS.price-base - buf_CHK-GDS.discnt) * buf_CHK-GDS.doc-qnty).
                b-c = entry(1, buf_CHK-GDS.src-code, chr(4)).
              end.
            end.
            if parts_qnty > 0 then do:
              put stream txt unformatted
              trim(string(buf_trn-doc.fact-date, "99/99/9999"))  ";"
              trim(string(b-c)) ";"
              trim(string(parts_qnty)) ";"
              trim(string(chk-price / chk-qnty, "->>>,>>>,>>9.99"))  ";1;"
              trim(string(cli-code))
              skip.
              assign
              b-c = ""
              chk-price = 0
              chk-qnty = 0
              parts_qnty = 0.
            end.
          end.
          assign
          p-t  = buf_doc-line.prod-type
          p-c  = buf_doc-line.prod-code
          p-a  = buf_doc-line.artic
          b-c = ""
          chk-price = 0
          chk-qnty = 0
          parts_qnty = 0.
        end.
      end.
      find buf_goods  where
          buf_goods.prod-type = buf_doc-line.prod-type and
          buf_goods.prod-code = buf_doc-line.prod-code and
          buf_goods.artic         = buf_doc-line.artic no-lock no-error.
      assign
      p-t  = buf_doc-line.prod-type
      p-c  = buf_doc-line.prod-code
      p-a  = buf_doc-line.artic
      b-c = ""
      v-gds-code = buf_goods.gds-code
      chk-price = 0
      chk-qnty = 0
      parts_qnty = 0.
      FOR EACH buf_parts NO-LOCK WHERE
              buf_parts.obj-type  = buf_doc-line.obj-type AND
              buf_parts.obj-code  = buf_doc-line.obj-code AND
              buf_parts.artic        = buf_doc-line.artic AND
              buf_parts.prod-type = buf_doc-line.prod-type AND
              buf_parts.prod-code = buf_doc-line.prod-code AND
              buf_parts.out-code   = buf_doc-line.doc-code
              :
        if buf_parts.supp-code <> cli-code  then next.
        parts_qnty = parts_qnty + buf_parts.fact-qnty.
      end.
      if  parts_qnty <> 0 then do:
        for each buf_CHK-GDS no-lock where
        buf_CHK-GDS.out-code = buf_trn-doc.doc-code and
        buf_CHK-GDS.doc-qnty <> 0
      :
          find buf_bar-code where buf_bar-code.b-code = buf_CHK-GDS.b-code no-lock no-error.
          if not avail buf_bar-code then next.
          if buf_bar-code.gds-code = buf_goods.gds-code then do:
            chk-qnty = chk-qnty + buf_CHK-GDS.doc-qnty.
            chk-price = chk-price + ((buf_CHK-GDS.price-base - buf_CHK-GDS.discnt) * buf_CHK-GDS.doc-qnty).
            b-c = entry(1, buf_CHK-GDS.src-code, chr(4)).
          end.
        end.
        if parts_qnty > 0 then do:
          put stream txt unformatted
          trim(string(buf_trn-doc.fact-date, "99/99/9999"))  ";"
          trim(string(b-c)) ";"
          trim(string(parts_qnty)) ";"
          trim(string(chk-price / chk-qnty, "->>>,>>>,>>9.99"))  ";1;"
          trim(string(cli-code))
          skip.
          assign
          b-c = ""
          chk-price = 0
          chk-qnty = 0
          parts_qnty = 0.
        end.
      end.
    end.
  end.
FIND FIRST ret-doc No-LOCK WHERE ret-doc.doc-code = buf_trn-doc.out-code No-ERROR.
if avail ret-doc
and ret-doc.office = no
then do:
  assign
  b-c = ""
  chk-price = 0
  chk-qnty = 0
  p-t = ""
  p-c = ?
  p-a = ""
  v-gds-code = 0
  .
  FOR  each buf_doc-line NO-LOCk WHERE buf_doc-line.doc-code = ret-doc.doc-code
  by buf_doc-line.prod-type
  by buf_doc-line.prod-code
  by buf_doc-line.artic
  :
    if p-c <> ? then do:
      if  p-t <> buf_doc-line.prod-type
      or  p-c <> buf_doc-line.prod-code
      or p-a <> buf_doc-line.artic   then do:
        if  parts_qnty <> 0 then do:
          for each buf_CHK-GDS no-lock where
              buf_CHK-GDS.out-code = buf_trn-doc.doc-code and
              buf_CHK-GDS.doc-qnty < 0
              :
            find buf_bar-code where buf_bar-code.b-code = buf_CHK-GDS.b-code no-lock no-error.
            if not avail buf_bar-code then next.
            if buf_bar-code.gds-code = buf_goods.gds-code then do:
              chk-qnty = chk-qnty + buf_CHK-GDS.doc-qnty.
              chk-price = chk-price + ((buf_CHK-GDS.price-base - buf_CHK-GDS.discnt) * buf_CHK-GDS.doc-qnty).
              b-c = entry(1, buf_CHK-GDS.src-code, chr(4)).
            end.
          end.
          if parts_qnty > 0 then do:
            put stream txt unformatted
            trim(string(ret-doc.fact-date, "99/99/9999"))  ";"
            trim(string(b-c)) ";"
            trim(string(parts_qnty)) ";"
            trim(string(chk-price / chk-qnty, "->>>,>>>,>>9.99"))  ";0;"
            trim(string(cli-code))
            skip.
            assign
            b-c = ""
            chk-price = 0
            chk-qnty = 0
            parts_qnty = 0.
          end.
        end.
        assign
        p-t  = buf_doc-line.prod-type
        p-c  = buf_doc-line.prod-code
        p-a  = buf_doc-line.artic
        parts_qnty = 0.
      end.
    end.
    find buf_goods  where
        buf_goods.prod-type = buf_doc-line.prod-type and
        buf_goods.prod-code = buf_doc-line.prod-code and
        buf_goods.artic     = buf_doc-line.artic no-lock no-error.
    assign
    p-t  = buf_doc-line.prod-type
    p-c  = buf_doc-line.prod-code
    p-a  = buf_doc-line.artic
    parts_qnty = 0.
    FOR EACH buf_parts NO-LOCK WHERE
          buf_parts.obj-type  = buf_doc-line.obj-type AND
          buf_parts.obj-code  = buf_doc-line.obj-code AND
          buf_parts.artic     = buf_doc-line.artic AND
          buf_parts.prod-type = buf_doc-line.prod-type AND
          buf_parts.prod-code = buf_doc-line.prod-code AND
          buf_parts.out-code   = buf_doc-line.doc-code
        :
      if buf_parts.supp-code <> cli-code then next.
      parts_qnty = parts_qnty + buf_parts.fact-qnty.
    end.
  end.
  if  parts_qnty <> 0 then do:
    for each buf_CHK-GDS no-lock where
            buf_CHK-GDS.out-code = buf_trn-doc.doc-code and
            buf_CHK-GDS.doc-qnty < 0
        :
      find buf_bar-code where buf_bar-code.b-code = buf_CHK-GDS.b-code no-lock no-error.
      if not avail buf_bar-code then next.
      if buf_bar-code.gds-code = buf_goods.gds-code then do:
        chk-qnty = chk-qnty + buf_CHK-GDS.doc-qnty.
        chk-price = chk-price + ((buf_CHK-GDS.price-base - buf_CHK-GDS.discnt) * buf_CHK-GDS.doc-qnty).
        b-c = entry(1, buf_CHK-GDS.src-code, chr(4)).
      end.
    end.
    if parts_qnty > 0 then do:
      put stream txt unformatted
      trim(string(buf_trn-doc.fact-date, "99/99/9999"))  ";"
      trim(string(b-c)) ";"
      trim(string(parts_qnty)) ";"
      trim(string(chk-price / chk-qnty, "->>>,>>>,>>9.99"))  ";0;"
      trim(string(cli-code))
      skip.
      assign
      b-c = ""
      chk-price = 0
      chk-qnty = 0
      parts_qnty = 0.
    end.
  end.
end.
end.
output stream txt close.
message
" Экспорт в файл закончен. "
view-as alert-box information .
END.
ON LEAVE OF cli-code IN FRAME Dialog-Frame
DO:
  assign
      cli-code.
  if cli-code <> 0 then do:
       find ub.clients where ub.clients.obj-type = "орг" and
             ub.clients.obj-code = cli-code
       no-lock no-error.
       if avail ub.clients then do:
          assign
              cli-code = ub.clients.obj-code
              cli-name = ub.clients.obj-name.
              DISP cli-code cli-name WITH FRAME Dialog-Frame.
       end.
       else  do:
             message "Такой поставщик не существует !!!!!!!!!!!!!!!!!!!!!!!!!!"
             view-as alert-box ERROR.
             assign
                 cli-code = 0
                 cli-name = "".
             return no-apply.
       end.
  end.
END.
ON LEAVE OF file-name IN FRAME Dialog-Frame
DO:
    ASSIGN file-name.
    IF SEARCH( file-name ) <> ? AND SEARCH( file-name ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = file-name.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN file-name = FILE-INFO:FULL-PATHNAME.
        DISP file-name WITH FRAME Dialog-Frame.
    END.
    APPLY "TAB":U TO file-name IN FRAME Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if v-cntxt-obj-type <> 'маг':U then do:
    message "Текущий объект не МАГАЗИН!"
    view-as alert-box ERROR.
    BELL.
    undo, return error.
  end.
  date-beg = today.
  date-end = today.
  assign
  date-beg
  date-end.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY date-beg date-End cli-code cli-name file-name
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel b-help date-beg date-End cli-code B-file B-file-2
         file-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
