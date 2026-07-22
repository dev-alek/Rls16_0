block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись таблицы cbr-bank

Автор: Булгаков Андрей Николаевич
Дата создания: 02/16/05
Author: Andrew Bulgakoff
Creation date: 02/16/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.cbr-bank NEW BUFFER Buf-New OLD BUFFER Buf-Old.

DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision$":U.
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author$":U.
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date$":U.
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile$":U.
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive$":U.
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "Триггер на запись таблицы cbr-bank":U.

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

DEFINE BUFFER buf_fin FOR ub.fin-bank.

Main-Block:
DO ON ERROR   UNDO Main-Block, LEAVE Main-Block
   ON END-KEY UNDO Main-Block, LEAVE Main-Block :
  IF  not new(buf-new)
  and Buf-New.bic <> Buf-Old.bic
  THEN DO:
    message
      vss-workfile vss-revision vss-description skip
      "Нельзя менять БИК код" skip
      "Старый БИК" Buf-Old.bic skip
      "Новый БИК" Buf-New.bic skip
      view-as alert-box error .
    undo, return error return-value .
  END.
  IF g#news <> YES THEN DO:
    CREATE ub.c-cbr-bank.
    BUFFER-COPY Buf-Old EXCEPT bic TO ub.c-cbr-bank NO-ERROR.
    IF ERROR-STATUS :ERROR THEN DO: UNDO, RETURN ERROR. END.
    ASSIGN ub.c-cbr-bank.action           = INTEGER( IF NEW( Buf-New )            THEN {&hn-create} ELSE
                                                   ( IF Buf-New.bic = Buf-Old.bic THEN {&hn-update} ELSE
                                                                                       {&hn-rename} ) )
           ub.c-cbr-bank.bic              = ( IF NEW( Buf-New ) THEN Buf-New.bic ELSE Buf-Old.bic )
           ub.c-cbr-bank.corr-date        = TODAY
           ub.c-cbr-bank.corr-time        = TIME
           ub.c-cbr-bank.corr-user-name   = g#userid
           ub.c-cbr-bank.corr-user-db-num = g#db-num
           ub.c-cbr-bank.chip-num         = NEXT-VALUE( s-corr-chip, {&db-name_schema} ) NO-ERROR.
    IF ERROR-STATUS :ERROR THEN DO:
      MESSAGE vss-workfile SKIP vss-revision SKIP vss-date SKIP vss-archive SKIP vss-description SKIP( 1 )
              "Ошибка при записи истории банка ЦБ РФ" Buf-New.bic SKIP
              ERROR-STATUS :GET-MESSAGE( 1 ) SKIP RETURN-VALUE
      VIEW-AS ALERT-BOX ERROR.
      UNDO Main-Block, RETURN ERROR.
    END.
  END. /* NOT g#news */
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_fin-bank}
        , input ( buffer ub.fin-bank:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
END. /* Main-Block */