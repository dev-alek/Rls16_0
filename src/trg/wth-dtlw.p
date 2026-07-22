block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись расшифровки строк документов МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.wth-dtl NEW BUFFER Buf-New OLD BUFFER Buf-Old.

define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Триггер на запись расшифровки строк документов МЦ":U.
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                          ,buf-new.doc-code
                          ,buf-new.wth-code
                          ,buf-new.w-p-code
                          ,buf-new.par-code
                          )" }

{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-mess as character no-undo .
define variable v-cmp as character no-undo .

DEF BUFFER buf-doc FOR ub.wth-doc.
DEF BUFFER buf-lin FOR ub.wth-line.
DEF BUFFER buf-dtl FOR ub.wth-dtl.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if buf-new.gds-code = 0 then buf-new.gds-code = ?.

  IF NOT g#news THEN DO:
    FIND FIRST buf-doc NO-LOCK WHERE
               buf-doc.doc-code = Buf-New.doc-code NO-ERROR.
    IF NOT AVAIL buf-doc THEN DO:
      MESSAGE
        vss-workfile vss-revision SKIP vss-description SKIP( 1 )
        "Нет документа" Buf-New.doc-code "!"
      VIEW-AS ALERT-BOX ERROR.
      UNDO Main-Block, RETURN ERROR.
    END.
    FIND FIRST buf-lin NO-LOCK WHERE
              buf-lin.doc-code = Buf-New.doc-code AND
              buf-lin.wth-code = Buf-New.wth-code AND
              buf-lin.w-p-code = Buf-New.w-p-code NO-ERROR.
    IF NOT AVAIL buf-lin THEN DO:
      MESSAGE
        vss-workfile vss-revision SKIP vss-description SKIP( 1 )
        "Нет строки" Buf-New.wth-code "для места хранения МЦ" Buf-New.w-p-code "документа" Buf-New.doc-code "!"
      VIEW-AS ALERT-BOX ERROR.
      UNDO Main-Block, RETURN ERROR.
    END.
    if new(buf-new)
    and buf-doc.status_ = {&fact}
    then do:
      assign
      v-mess = substitute("&1 &2 &3&4" +
                          "Невозможно добавлять детализацию по строчке документа МЦ в статусе &5&4Документ &6"
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
  END. /* IF NOT g#news */
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_wth-dtl}
        , input ( buffer ub.wth-dtl:handle )
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