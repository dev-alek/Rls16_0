block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление строк документов МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.wth-line.

define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "триггер на удаление строк документов МЦ":U.
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                          ,ub.wth-line.doc-code
                          ,ub.wth-line.wth-code
                          ,ub.wth-line.w-p-code)" }
{ cmp/trg-def.i }

define variable rid AS RECID NO-UNDO.
define variable v-mess as character no-undo .

DEF BUFFER buf-doc  FOR ub.wth-doc.
DEF BUFFER buf-dtl  FOR ub.wth-dtl.
DEF BUFFER buf_dtl  FOR ub.wth-dtl.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
 /*  FIND buf-doc NO-LOCK WHERE buf-doc.doc-code = ub.wth-line.doc-code NO-ERROR.
 if available buf-doc
  and (buf-doc.status_ <> {&wayb}
  or buf-doc.is-del = no)
  then do:
    assign
    v-mess = substitute("&1 &2 &3&4" +
                        "Невозможно удалить строчку документа МЦ в статусе &5&4Документ &6"
                        ,vss-workfile
                        ,vss-revision
                        ,vss-description
                        ,{&new-line}
                        ,buf-doc.status_
                       ,ub.wth-line.doc-code).
    if not g#news then do:
      message
      v-mess
      view-as alert-box error .
    end.
    undo Main-block, return error v-mess.
  end.
  ASSIGN rid = ( IF AVAIL buf-doc THEN RECID( buf-doc ) ELSE ? ).   */

  FOR EACH buf-dtl NO-LOCK WHERE
   buf-dtl.doc-code = ub.wth-line.doc-code AND
   buf-dtl.wth-code = ub.wth-line.wth-code AND
   buf-dtl.w-p-code = ub.wth-line.w-p-code :
    FIND buf_dtl EXCLUSIVE-LOCK WHERE RECID( buf_dtl ) = RECID( buf-dtl ).
    /* запись истории на удаление buf_wtl есть в евоном триггере*/
    DELETE buf_dtl.
  END. /* buf-dtl */

  /* история */
  IF NOT g#news THEN DO:

  END. /* g#news */
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_wth-line}
        , input ( buffer ub.wth-line:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
END. /* Main-Block */