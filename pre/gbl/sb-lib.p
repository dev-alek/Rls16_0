block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sb-lib.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/sb-lib.p $":U .
define variable vss-description as character no-undo init "Библионтека для обслуживания банковских карт (Сбербанк)".
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
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#sb-lib as handle no-undo.
if valid-handle (g#sb-lib)
and g#sb-lib <> this-procedure :handle
and g#sb-lib :get-signature('library_testproc':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки" skip
    g#sb-lib skip
    g#sb-lib :type skip
    g#sb-lib :file-name skip
    valid-handle(g#sb-lib) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error return-value .
end.
else do:
  assign
    g#sb-lib = this-procedure :handle
  .
end.
if this-procedure :persistent <> true
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка запуска библиотеки" program-name(1) skip
    "Попытка запустить ее как обычную процедуру" skip
    view-as alert-box error .
end.
on delete of this-procedure do:
  assign
    g#sb-lib = ?
  .
end.
DEFINE VARIABLE v-sb         AS COM-HANDLE   NO-UNDO .
define variable v-sb-type    as integer      no-undo.
procedure sb-init :
define input parameter  p-cashless-system as character        no-undo.
define output parameter p-message as character        no-undo.
define output parameter p-ok      as logical          no-undo.
define variable v-output    as character    no-undo.
bl:
do
on error undo, return error
:
   RELEASE OBJECT v-sb NO-ERROR.
   v-sb = ?.
   IF  p-cashless-system = 'sberbank':U
   THEN DO:
      CREATE "SBRFSRV.server":U v-sb NO-ERROR.
      IF ERROR-STATUS:ERROR
      OR NOT VALID-HANDLE(v-sb)
      THEN DO:
         ASSIGN
            p-message = "Не найден COM-сервер для Сбербанка"
         .
         RETURN.
      END.
      assign
         v-sb-type = 100
      .
      v-sb:CONNECT() NO-ERROR.
      IF ERROR-STATUS:ERROR
      THEN DO:
         ASSIGN
            p-message = RETURN-VALUE
            p-ok      = FALSE
         .
         RETURN.
      END.
   END.
   assign
      p-ok = TRUE
   .
end.
end procedure.
PROCEDURE sb-cardinfo :
define output parameter p-card-num as character        no-undo.
define output parameter p-card-type as character        no-undo.
define output parameter p-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.
define variable v-clientcard    as character    no-undo.
define variable v-output    as character    no-undo.
IF VALID-HANDLE(v-sb)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-sb-type :
      WHEN 100 THEN DO:
         p-message = v-sb:Clear() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         v-sb:sParam(INPUT "CardType", INPUT 0).
         v-sb:sParam(INPUT "Amount",   INPUT 0).
         v-sb:sParam(INPUT "Track2",  INPUT "").
         p-message = v-sb:NFun (INPUT 5000) NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         ASSIGN
            p-card-num  = v-sb:gParamString(INPUT "CardName")
            p-card-type = v-sb:gParamString(INPUT "CardType")
         .
         p-message = v-sb:Clear() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         ASSIGN
            p-ok = TRUE
         .
      END.
      OTHERWISE DO:
      END.
   END CASE.
   ASSIGN
      p-ok = TRUE
   .
END.
ELSE DO:
   ASSIGN
      p-ok = TRUE
   .
END.
END PROCEDURE.
PROCEDURE sb-sale :
define input parameter  p-summ     as decimal          no-undo.
define output parameter p-slip     as character        no-undo.
define output parameter p-card-num as character        no-undo.
define output parameter p-message  as character        no-undo.
define output parameter p-ok       as logical          no-undo.
IF VALID-HANDLE(v-sb)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-sb-type :
      WHEN 100 THEN DO:
         p-message = v-sb:Clear() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (    p-message <> ?
             AND p-message <> "":U
             AND p-message <> "0":U
             )
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         v-sb:sParam(INPUT "CardType", INPUT 0).
         v-sb:sParam(INPUT "Amount",   INPUT TRUNCATE((p-summ * 100), 0)).
         v-sb:sParam(INPUT "Track2",  INPUT "").
         p-message = v-sb:NFun (INPUT 4000) NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         assign
            p-slip      = v-sb:gParamString(INPUT "Cheque")
            p-card-num  = v-sb:gParamString(INPUT "ClientCard")
         .
         p-message = v-sb:Clear() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         ASSIGN
            p-ok = TRUE
         .
      END.
      OTHERWISE DO:
      END.
   END CASE.
END.
ELSE DO:
   ASSIGN
      p-ok = TRUE
   .
END.
END PROCEDURE.
PROCEDURE sb-ret :
define input parameter  p-summ      as decimal          no-undo .
define input parameter  p-card-num  as character        no-undo .
define output parameter p-slip      as character        no-undo .
define output parameter p-message   as character        no-undo .
define output parameter p-ok        as logical          no-undo .
IF VALID-HANDLE(v-sb)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-sb-type :
      WHEN 100 THEN DO:
         p-message = v-sb:Clear() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         v-sb:sParam(INPUT "CardType", INPUT 0).
         v-sb:sParam(INPUT "Amount",   INPUT TRUNCATE((ABS(p-summ) * 100), 0)).
         v-sb:sParam(INPUT "Track2",  INPUT "").
         p-message = v-sb:NFun (INPUT 4002) NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         assign
            p-slip      = v-sb:gParamString(INPUT "Cheque")
            p-card-num  = v-sb:gParamString(INPUT "ClientCard")
         .
         p-message = v-sb:Clear() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         ASSIGN
            p-ok = TRUE
         .
      END.
      OTHERWISE DO:
      END.
   END CASE.
END.
ELSE DO:
   ASSIGN
      p-ok = TRUE
   .
END.
END PROCEDURE.
PROCEDURE sb-revert :
define input parameter  p-summ    as decimal          no-undo.
define output parameter p-slip    as character          no-undo.
define output parameter p-card-num  as character        no-undo .
define output parameter p-message as character        no-undo.
define output parameter p-ok      as logical          no-undo.
IF VALID-HANDLE(v-sb)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-sb-type :
      WHEN 100 THEN DO:
         p-message = v-sb:Clear() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         v-sb:sParam(INPUT "CardType", INPUT 0).
         v-sb:sParam(INPUT "Amount",   INPUT TRUNCATE((p-summ * 100), 0)).
         v-sb:sParam(INPUT "Track2",  INPUT "").
         p-message = v-sb:NFun (INPUT 4003) NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         assign
            p-slip = v-sb:gParamString(INPUT "Cheque")
            p-card-num  = v-sb:gParamString(INPUT "ClientCard")
         .
         p-message = v-sb:Clear() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         ASSIGN
            p-ok = TRUE
         .
      END.
      OTHERWISE DO:
      END.
   END CASE.
END.
ELSE DO:
   ASSIGN
      p-ok = TRUE
   .
END.
END PROCEDURE.
PROCEDURE sb-day :
define output parameter p-message as character        no-undo.
define output parameter p-ok      as logical          no-undo.
IF VALID-HANDLE(v-sb)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-sb-type :
      WHEN 100 THEN DO:
         p-message = v-sb:Clear() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         p-message = v-sb:NFun (INPUT 6000) NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         p-message = v-sb:Clear() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         ASSIGN
            p-ok = TRUE
         .
      END.
      OTHERWISE DO:
      END.
   END CASE.
END.
ELSE DO:
   ASSIGN
      p-ok = TRUE
   .
END.
END PROCEDURE.
