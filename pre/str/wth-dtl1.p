block-level on error undo, throw.
define output parameter par-rid as recid no-undo .
define input parameter par-mode    as character no-undo .
define input parameter pardoc-code like ub.wth-dtl.doc-code no-undo .
define input parameter parwth-code like ub.wth-dtl.wth-code no-undo .
define input parameter parw-p-code like ub.wth-dtl.w-p-code no-undo .
define input parameter parpar-code like ub.wth-dtl.par-code no-undo .
define input parameter pardoc-sum  like ub.wth-dtl.doc-sum no-undo .
define input parameter parfact-sum  like ub.wth-dtl.fact-sum no-undo .
define input parameter parsum-gds-rubl like  ub.wth-dtl.sum-gds-rubl no-undo .
define input parameter parsum-gds-base like  ub.wth-dtl.sum-gds-base no-undo .
define input parameter parline-exist as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wth-dtl1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/wth-dtl1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в строке детализации документа МЦ".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
DEFINE VARIABLE var-entry as character no-undo .
DEFINE VARIABLE loc#log as logical no-undo .
define buffer buf_wth-line for ub.wth-line.
define buffer buf_wth-doc for ub.wth-doc.
define buffer buf_wth-parts for ub.wth-parts.
if NOT (par-mode = 'ДОБАВЛЕНИЕ':U OR par-mode = 'ИЗМЕНЕНИЕ':U) then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр вызова par-mode" par-mode
  view-as alert-box ERROR.
  return error '':U.
end.
FIND FIRST buf_wth-doc EXCLUSIVE-LOCK WHERE
           buf_wth-doc.doc-code = pardoc-code No-ERROR No-WAIT.
IF LOCKED buf_wth-doc then do:
  message vss-workfile vss-revision vss-description skip
          "Запись документа МЦ" pardoc-code "занята"
          "добавление/изменение строки невозможно"
  view-as alert-box error .
end.
IF NOT available buf_wth-doc then do:
  message vss-workfile vss-revision vss-description skip
          "Не найден документа МЦ" pardoc-code
  view-as alert-box error .
end.
FIND FIRST buf_wth-line EXCLUSIVE-LOCK WHERE
           buf_wth-line.doc-code = buf_wth-doc.doc-code AND
           buf_wth-line.wth-code = parwth-code AND
           buf_wth-line.w-p-code = parw-p-code No-ERROR No-WAIT.
IF LOCKED buf_wth-line then do:
  message vss-workfile vss-revision vss-description skip
          "Запись строки документа МЦ" pardoc-code "занята"
          "добавление/изменение строки невозможно"
  view-as alert-box error .
end.
IF NOT available buf_wth-line then do:
  message vss-workfile vss-revision vss-description skip
          "Не найдена строка документа МЦ" pardoc-code parwth-code parw-p-code
  view-as alert-box error .
end.
IF NOT CAN-FIND( ub.wealth NO-LOCK WHERE ub.wealth.wth-code = parwth-code ) THEN DO:
  MESSAGE "Материальная ценность" parwth-code "не найдена в справочнике!"
  VIEW-AS ALERT-BOX ERROR.
  var-entry = "wth-code":U.
  RETURN ERROR var-entry.
END.
FIND FIRST ub.wth-dtl NO-LOCK WHERE
          ub.wth-dtl.doc-code = pardoc-code   AND
          ub.wth-dtl.wth-code = parwth-code   AND
          ub.wth-dtl.w-p-code = parw-p-code   AND
          ub.wth-dtl.par-code = parpar-code NO-ERROR.
if buf_wth-doc.status_ = 'разрешен':U then do:
  if (
      (not available ub.wth-dtl and pardoc-sum <> 0) OR
      (avail ub.wth-dtl AND
        (ub.wth-dtl.doc-code <> pardoc-code OR
        ub.wth-dtl.wth-code <> parwth-code OR
        ub.wth-dtl.w-p-code <> parw-p-code OR
        (buf_wth-doc.doc-type <> 'инв':U and ub.wth-dtl.doc-sum <> pardoc-sum )
      )
      )
    ) then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Документ МЦ имеет статус" buf_wth-doc.status_
    "возможно изменить только сумму факт"
    view-as alert-box ERROR.
    return error '':U.
  end.
end.
DO ON ERROR UNDO, return error '':U
   ON STOP UNDO, return error '':U:
IF AVAIL ub.wth-dtl THEN DO:
  ASSIGN
  par-rid = RECID( ub.wth-dtl ).
  FIND FIRST ub.wth-dtl EXCLUSIVE-LOCK WHERE
             RECID( ub.wth-dtl ) = par-rid.
END.
ELSE DO:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
CREATE ub.wth-dtl.
ASSIGN
  ub.wth-dtl.doc-code = buf_wth-line.doc-code
  ub.wth-dtl.wth-code = buf_wth-line.wth-code
  ub.wth-dtl.w-p-code = buf_wth-line.w-p-code
  ub.wth-dtl.par-code = parpar-code
  ub.wth-dtl.creid    = g#userid
  ub.wth-dtl.credate  = TODAY
.
  ASSIGN par-rid = RECID( ub.wth-dtl ).
END.
IF buf_wth-doc.doc-type = 'инв':U THEN DO:
  ASSIGN
  ub.wth-dtl.bef-sum  = (if parline-exist then (ub.wth-dtl.bef-sum + pardoc-sum) else pardoc-sum )
  ub.wth-dtl.aft-sum  = (if parline-exist then (ub.wth-dtl.aft-sum + parfact-sum) else parfact-sum )
  .
END.
ELSE DO:
  ASSIGN
  ub.wth-dtl.doc-sum  =  (if parline-exist then (ub.wth-dtl.doc-sum + pardoc-sum) else pardoc-sum )
  ub.wth-dtl.fact-sum = (if parline-exist then (ub.wth-dtl.fact-sum + parfact-sum) else parfact-sum )
  ub.wth-dtl.sum-gds-rubl = (if parline-exist then (ub.wth-dtl.sum-gds-rubl + parsum-gds-rubl) else parsum-gds-rubl )
  ub.wth-dtl.sum-gds-base = (if parline-exist then (ub.wth-dtl.sum-gds-base + parsum-gds-base) else parsum-gds-base )
  .
END.
if ub.wth-dtl.doc-sum = 0 AND
    ub.wth-dtl.fact-sum = 0 and
    ub.wth-dtl.bef-sum = 0 and
    ub.wth-dtl.aft-sum = 0
    and not can-find(first buf_wth-parts where
                           buf_wth-parts.w-p-code = ub.wth-dtl.w-p-code
                           and buf_wth-parts.wth-code = ub.wth-dtl.wth-code
                           and buf_wth-parts.par-code = ub.wth-dtl.par-code
                           and buf_wth-parts.out-code = ub.wth-dtl.doc-code ) then do:
  delete ub.wth-dtl.
end.
else do:
     find first buf_wth-parts no-lock where
                           buf_wth-parts.w-p-code = ub.wth-dtl.w-p-code
                           and buf_wth-parts.wth-code = ub.wth-dtl.wth-code
                           and buf_wth-parts.par-code = ub.wth-dtl.par-code
                           and buf_wth-parts.out-code = ub.wth-dtl.doc-code no-error.
     if available buf_wth-parts then ub.wth-dtl.gds-code = buf_wth-parts.gds-code.
end.
END.
