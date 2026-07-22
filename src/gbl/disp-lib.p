block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: disp-lib.p $
$Archive: gbl/disp-lib.p $

Библионтека для дисплея покупателя.

Автор: Белоусов Илья Александрович
Дата создания: 09/24/08
Author: Ilia Belousov
Creation date: 09/24/08

Input:

Output:

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: disp-lib.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/disp-lib.p $":U .
define variable vss-description as character no-undo init "Библионтека для обслуживания банковских карт (Сбербанк)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/disp-lib.i   }


if valid-handle (g#disp-lib)
and g#disp-lib <> this-procedure :handle
and g#disp-lib :get-signature('library_testproc':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки" skip
    g#disp-lib skip
    g#disp-lib :type skip
    g#disp-lib :file-name skip
    valid-handle(g#disp-lib) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error return-value .
end.
else do:
  assign
    g#disp-lib = this-procedure :handle
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
    g#disp-lib = ?
  .
end.


&scop DPD201     201
&scop DPD201-ln  20
&scop DP2800-320     320


DEFINE VARIABLE v-disp          AS COM-HANDLE     NO-UNDO . /* Ссылка на драйвер */
define variable v-disp-type    as integer      no-undo. /* Тип */
define variable v-disp-Open    as logical      no-undo.
define variable v-str-len      as integer      no-undo.
DEFINE VARIABLE CtrlFrame-2     AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chCtrlFrame-2   AS COMPONENT-HANDLE NO-UNDO.
DEFINE FRAME Dialog-Frame-2
           SPACE(9.13) SKIP(1.57)
        WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         .



/*==========================================================================*/
procedure disp-init :
define input parameter  p-first-string          as character      no-undo .
define input parameter  p-second-string         as character      no-undo .
define input parameter  p-customer-display-type as character        no-undo .
define input parameter  p-customer-display-port as integer        no-undo .
define output parameter p-message               as character      no-undo .
define output parameter p-ok                    as logical        no-undo .

bl:
do
on error undo, return error
:
   RELEASE OBJECT v-disp NO-ERROR.
   v-disp = ?.

   CASE p-customer-display-type:
      WHEN {&cd-cd-Shtrih-m-a1_40}
      THEN DO:
         CREATE "DrvDspl.v1_2":U v-disp NO-ERROR.

         IF ERROR-STATUS:ERROR
         OR NOT VALID-HANDLE(v-disp)
         THEN DO:
            ASSIGN
               p-message = "Не найден COM-сервер для дисплея покупателя"
            .
            RETURN.
         END.
         assign
            v-disp-Open = YES
            v-disp-type = {&DPD201}
            v-str-len   = {&DPD201-ln}
         .

         v-disp:CONNECT() NO-ERROR.
         IF ERROR-STATUS:ERROR
         THEN DO:
            ASSIGN
               p-message = RETURN-VALUE
               p-ok = FALSE
            .
            RETURN.
         END.


         v-disp:InitialDispl () NO-ERROR.
         IF ERROR-STATUS:ERROR
         THEN DO:
            ASSIGN
               p-message = RETURN-VALUE
               p-ok = FALSE
            .
            RETURN.
         END.

         v-disp:Test () NO-ERROR.
         IF ERROR-STATUS:ERROR
         THEN DO:
            ASSIGN
               p-message = RETURN-VALUE
               p-ok = FALSE
            .
            RETURN.
         END.

         run disp-str IN THIS-PROCEDURE ( INPUT  p-first-string
                                       , INPUT  p-second-string
                                       , OUTPUT p-message
                                       , OUTPUT p-ok
                                       ) .
      END.
      WHEN {&cd-cd-Posiflex-pd2800-320} THEN
      DO:

       DEF VAR v-pd     AS COM-HANDLE NO-UNDO .


       run control_load in this-procedure  .

       DEF VAR v-i AS INT NO-UNDO .
       v-pd = chCtrlFrame-2:controls .
       v-disp = v-pd:ITEM(1) .
       IF VALID-HANDLE(v-disp) THEN
       DO:

           v-i = v-disp:OPEN("pd320") .

           v-i = v-disp:ClaimDevice(0) .
           IF v-disp:claimed THEN
           DO:
             assign
               v-disp:DeviceEnabled = YES
               v-disp-open = yes
               v-disp:CharacterSet = 866
               v-str-len = v-disp:DeviceColumns
               v-disp-type = {&DP2800-320}
               .

               run disp-str IN THIS-PROCEDURE ( INPUT  p-first-string
                                       , INPUT  p-second-string
                                       , OUTPUT p-message
                                       , OUTPUT p-ok
                                       ) .




           END.
       END.
      END.
      OTHERWISE DO:

      end.

   END CASE.
   /*
   { gbl/disp-str.i
      p-first-string
      p-second-string
      p-message
      p-ok
      NO-ERROR
   }
   IF ERROR-STATUS:ERROR
   THEN DO:
      ASSIGN
         p-message = RETURN-VALUE
         p-ok = FALSE
      .
      RETURN.
   END.
   */

   assign
      p-ok = TRUE
   .


end. /* do on error */
end procedure. /* disp-init */




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disp-str Include
PROCEDURE disp-str :
/*------------------------------------------------------------------------------
  Purpose: Вывод строки на дисплей покупателя.
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter  p-first-string    as character        no-undo.
define input parameter  p-second-string   as character        no-undo.
define output parameter p-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.

define variable v-line    as character    no-undo.

IF VALID-HANDLE(v-disp)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-disp-type :
      WHEN {&DPD201} THEN DO:
         /*
         { gbl/disp-clear.i
            p-message
            p-ok
            NO-ERROR
         }
         IF ERROR-STATUS:ERROR
         THEN DO:
            ASSIGN
               p-message = RETURN-VALUE
               p-ok = FALSE
            .
            RETURN.
         END.

         */

         run disp-clear IN THIS-PROCEDURE ( OUTPUT p-message
                                          , OUTPUT  p-ok
                                          ) .

         run disp-fmt IN THIS-PROCEDURE ( INPUT  p-first-string
                                        , INPUT  p-second-string
                                        , OUTPUT v-line
                                        , OUTPUT p-message
                                        , OUTPUT  p-ok
                                        ) .

         v-disp:EnterStr( INPUT 0, INPUT v-line ) NO-ERROR.
         IF ERROR-STATUS:ERROR
         THEN DO:
            ASSIGN
               p-message = RETURN-VALUE
               p-ok = FALSE
            .
            RETURN.
         END.

         /*
         v-disp:EnterStr( INPUT 0, INPUT p-first-string ) NO-ERROR.
         IF ERROR-STATUS:ERROR
         THEN DO:
            ASSIGN
               p-message = RETURN-VALUE
               p-ok = FALSE
            .
            RETURN.
         END.
         v-disp:EnterStr( INPUT 20, INPUT p-second-string ) NO-ERROR.
         IF ERROR-STATUS:ERROR
         THEN DO:
            ASSIGN
               p-message = RETURN-VALUE
               p-ok = FALSE
            .
            RETURN.
         END.
         */

      END.
      WHEN {&DP2800-320} THEN DO:


            run disp-clear IN THIS-PROCEDURE ( OUTPUT p-message
                                          , OUTPUT  p-ok
                                          ) .



               v-disp:DisplayTextAT(2,1,
                     codepage-convert(substr(p-first-string,1,v-str-len),"ibm866",SESSION:CHARSET),6)
                     .
               v-disp:DisplayTextAT(1,1,
                         codepage-convert(substr(p-second-string,1,v-str-len),"ibm866",SESSION:CHARSET),6)
                         .

      END.
      OTHERWISE DO:
      end.
   END CASE.
   ASSIGN
      p-ok = TRUE
   .
END.  /* do on error */
ELSE DO:
   ASSIGN
      p-ok = TRUE
   .
END.
END PROCEDURE. /* disp-str */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disp-fmt Include
PROCEDURE disp-fmt :
/*------------------------------------------------------------------------------
  Purpose: форматирование строки
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter  p-line-1    as character        no-undo.
define input parameter  p-line-2    as character        no-undo.
define output parameter p-out-line  as character        no-undo.
define output parameter p-message   as character        no-undo.
define output parameter p-ok        as logical          no-undo.

IF VALID-HANDLE(v-disp)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   IF num-entries(p-line-1, {&delim-par}) >= 2
   THEN DO:
      assign
         p-line-2 = entry(2, p-line-1, {&delim-par})
         p-line-1 = entry(1, p-line-1, {&delim-par})
      .
   END.

   ASSIGN
      p-line-1 = TRIM(p-line-1)
      p-line-2 = TRIM(p-line-2)
   .


   IF LENGTH(p-line-1) <= v-str-len
   THEN DO:
      ASSIGN
         p-line-1 = p-line-1 + FILL(" ", v-str-len - LENGTH(p-line-1) )
      .
   END.
   ELSE DO:
      ASSIGN
         p-line-1 = SUBSTRING(p-line-1, 1, v-str-len)
      .
   END.
   IF LENGTH(p-line-2) <= v-str-len
   THEN DO:
      ASSIGN
         p-line-2 = p-line-2 + FILL(" ", v-str-len - LENGTH(p-line-2) )
      .
   END.
   ELSE DO:
      ASSIGN
         p-line-2 = SUBSTRING(p-line-2, 1, v-str-len)
      .
   END.

   ASSIGN
      p-out-line = p-line-1 + p-line-2
      p-ok = TRUE
   .
END.  /* do on error */
ELSE DO:
   ASSIGN
      p-ok = TRUE
   .
END.
END PROCEDURE. /* disp-fmt */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disp-clear Include
PROCEDURE disp-clear :
/*------------------------------------------------------------------------------
  Purpose: Открыть чек
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.
IF VALID-HANDLE(v-disp)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-disp-type :
      WHEN {&DPD201} THEN DO:
         v-disp:ClearDispl () NO-ERROR.
         IF ERROR-STATUS:ERROR
         THEN DO:
            ASSIGN
               p-message = RETURN-VALUE
               p-ok = FALSE
            .
            RETURN.
         END.
         ASSIGN
            p-ok = TRUE
         .
      END.
      WHEN {&DP2800-320} THEN DO:
         v-disp:ClearText() .

         ASSIGN
            p-ok = TRUE
         .

      END.
      OTHERWISE DO:

      end.
   END CASE.
END.  /* do on error */
ELSE DO:
   ASSIGN
      p-ok = TRUE
   .
END.
END PROCEDURE. /* disp-clear */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disp-beg Include
PROCEDURE disp-beg :
/*------------------------------------------------------------------------------
  Purpose: Открыть чек
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-message as character        no-undo.
define output parameter p-ok      as logical          no-undo.
IF VALID-HANDLE(v-disp)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-disp-type :
      WHEN {&DPD201} THEN DO:
         ASSIGN
            p-ok = TRUE
         .
      END.
      OTHERWISE DO:
      END.
   END CASE.
END.  /* do on error */
ELSE DO:
   ASSIGN
      p-ok = TRUE
   .
END.
END PROCEDURE. /* disp-beg */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disp-beg Include
PROCEDURE disp-terminate :
/*------------------------------------------------------------------------------
  Purpose: закрыть устройство
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-message as character        no-undo.
define output parameter p-ok      as logical          no-undo.
IF VALID-HANDLE(v-disp)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-disp-type :
      WHEN {&DPD201} THEN DO:
         ASSIGN
            p-ok = TRUE
         .
      END.
      WHEN {&DP2800-320} THEN DO:
        v-disp:ReleaseDevice() .
        v-disp:close() .

      END.
      OTHERWISE DO:

      end.

   END CASE.
assign
      p-ok = yes .

END.  /* do on error */
ELSE DO:
   ASSIGN
      p-ok = TRUE
   .
END.
END PROCEDURE. /* disp-beg */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* шаблон
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disp-chkcl Include
PROCEDURE disp-chkcl :
/*------------------------------------------------------------------------------
  Purpose: Открыть чек
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-message as character        no-undo.
define output parameter p-ok      as logical          no-undo.
IF VALID-HANDLE(v-disp)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-disp-type :
      WHEN {&DPD201} THEN DO:
         ASSIGN
            p-ok = TRUE
         .
      END.
      OTHERWISE DO:
      END.
   END CASE.
END.  /* do on error */
ELSE DO:
   ASSIGN
      p-ok = TRUE
   .
END.
END PROCEDURE. /* disp-chkcl */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
*/


PROCEDURE control_load :
/*------------------------------------------------------------------------------
  Purpose:     Load the OCXs
  Parameters:  <none>
  Notes:       Here we load, initialize and make visible the
               OCXs in the interface.
------------------------------------------------------------------------------*/

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN
DEFINE VARIABLE UIB_S    AS LOGICAL    NO-UNDO.
DEFINE VARIABLE OCXFile  AS CHARACTER  NO-UNDO.
CREATE CONTROL-FRAME CtrlFrame-2 ASSIGN
       FRAME           = frame dialog-frame-2:handle
       ROW             = 3.38
       COLUMN          = 18
       HEIGHT          = 4.76
       WIDTH           = 20
       WIDGET-ID       = 8
       HIDDEN          = yes
       SENSITIVE       = yes.

OCXFile = SEARCH( "gbl\dp2800_320.wrx":U ).
IF OCXFile = ? THEN
  OCXFile = SEARCH(SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1,
                     R-INDEX(THIS-PROCEDURE:FILE-NAME, ".":U), "CHARACTER":U)
                     + "wrx":U).

IF OCXFile <> ? THEN
DO:

  ASSIGN
    chCtrlFrame-2 = CtrlFrame-2:COM-HANDLE
    UIB_S = chCtrlFrame-2:LoadControls( OCXFile, "CtrlFrame-2":U)
    CtrlFrame-2:NAME = "CtrlFrame-2":U
  .

  RUN initialize-controls IN THIS-PROCEDURE NO-ERROR.

END.
ELSE MESSAGE "gbl/dp2800_320.wrx":U SKIP(1)
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.