block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр одного правила

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/14/07
Author: Bakhtadze Natalya
Creation date: 02/14/07

*/

define input parameter p-display-mode as character no-undo .
define input parameter p-rule-id as integer no-undo .

/*text graph*/
DEFINE INPUT PARAMETER p-codex-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-ruleset-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-order-id AS INTEGER NO-UNDO.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр одного правила".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ rul/tempstrn.i }
{ rul/fillrule.i }
{ rul/disprule.i }
{ rul/dispscrp.i }
{ rul/disprclp.i }
{ rul/disprdps.i }



DEFINE VARIABLE v-level AS INTEGER NO-UNDO.
run temp-string_clear in this-procedure .
CASE P-DISPLAY-MODE:
  WHEN "TEXT" THEN DO:
    if p-call-id = '':U
    or p-ruleset-id = 0 then do:
      RUN display-ruledict-params IN THIS-PROCEDURE (
                                                       input p-display-mode
                                                      ,input p-rule-id).

    end.
    else do:
      RUN display-rule-call-params IN THIS-PROCEDURE (
                                                         input p-display-mode
                                                        ,INPUT p-codex-id
                                                        ,INPUT p-ruleset-id
                                                        ,INPUT p-call-id
                                                        ,input -1
                                                        ,INPUT p-order-id
                                                        ,input this-procedure:handle
                                                        ).
   end.
     run display-rule in this-procedure ( input p-rule-id
                                      , input 0 /*p-upper-rule-id*/
                                      , input "{&language}":U
                                      , input-output v-level).

     run gbl/notese.w ( INPUT THIS-PROCEDURE:HANDLE
                          ,input substitute("Содержание правила &1", p-rule-id)).


  END.
  WHEN "GRAPH" THEN DO:
      run rul/grafdisp.p ( input p-rule-id
                          ,input "RUS"
                           ).

  END.
END CASE.

PROCEDURE request-add-line :
DEFINE INPUT PARAMETER p-notes-handle AS HANDLE NO-UNDO.
DEFINE BUFFER buf_temp-string FOR temp-string.

for each buf_temp-string:
    RUN add-line IN p-notes-handle ( INPUT buf_temp-string.v-string).
    RUN add-line IN p-notes-handle ( INPUT {&new-line}).

  end.
END PROCEDURE.