block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись строк документов МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.wth-line NEW BUFFER Buf-New OLD BUFFER Buf-Old.

define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Триггер на запись строк документов МЦ":U.
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                          ,buf-new.doc-code
                          ,buf-new.wth-code
                          ,buf-new.w-p-code)" }

{ cmp/trg-def.i  }
{ gbl/cur-time.i }

DEFINE VARIABLE var-entry as character no-undo .
DEFINE VARIABLE v-stts like ub.wealth.stts no-undo .
define variable v-mess as character no-undo .
define variable v-cmp as character no-undo .

DEF BUFFER buf-doc FOR ub.wth-doc.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  IF NOT g#news THEN DO:
    FIND FIRST buf-doc NO-LOCK WHERE
                buf-doc.doc-code = Buf-New.doc-code NO-ERROR.
    IF NOT AVAIL buf-doc THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description SKIP
      "Нет документа" Buf-New.doc-code "!"
      VIEW-AS ALERT-BOX ERROR.
      UNDO Main-Block, RETURN ERROR.
    END.
    if new(buf-new)
    and buf-doc.status_ <> {&wayb}
    and buf-Doc.auto-fill = no
    then do:
      assign
      v-mess = substitute("&1 &2 &3&4" +
                          "Невозможно добавлять строчку документа МЦ в статусе &5&4Документ &6"
                          ,vss-workfile
                          ,vss-revision
                          ,vss-description
                          ,{&new-line}
                          ,buf-doc.status_
                          ,buf-new.doc-code).
      if not g#news then do:
        message
        v-mess
        view-as alert-box error .
      end.
      undo Main-block, return error v-mess.
    end.
    if buf-new.status_ <> buf-old.status_ then do:
      CASE buf-doc.doc-type:
        when {&inventory} then do:
          run trg/wth-lnv2.p (
                          input buf-new.doc-code,
                          input buf-doc.host-code,
                          input buf-doc.obj-type,
                          input buf-doc.obj-code,
                          input buf-doc.cli-type,
                          input buf-doc.cli-code,
                          input buf-doc.auto-fill,
                          input buf-doc.borned,
                          input recid(buf-new),
                          input buf-new.wth-code,
                          input buf-new.w-p-code
                          ) no-error.
        end.
        otherwise do:
          run trg/wth-lnc2.p (
                          input buf-new.doc-code,
                          input buf-doc.host-code,
                          input buf-doc.obj-type,
                          input buf-doc.obj-code,
                          input buf-doc.cli-type,
                          input buf-doc.cli-code,
                          input buf-doc.auto-fill,
                          input buf-doc.borned,
                          input buf-doc.exter_,
                          input recid(buf-new),
                          input buf-new.wth-code,
                          input buf-new.w-p-code,
                          input buf-new.out-code,
                          input buf-new.doc-sum,
                          input buf-new.fact-sum,
                          output v-stts
                          ) no-error.
        end.
      END CASE.
      if error-status:error then do:
          var-entry = return-value.
          UNDO Main-Block, RETURN ERROR var-entry.
      end.
      if buf-new.status_ = {&fact} and v-stts <> 0 then do:
         message
         "МЦ" buf-new.wth-code "удалена"
         view-as alert-box error .
         UNDO Main-Block, RETURN ERROR var-entry.
      end.
    end. /*if buf-new.status_ <> buf-old.status_*/
  END. /* IF NOT g#news */
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_wth-line}
        , input ( buffer ub.wth-line:handle )
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