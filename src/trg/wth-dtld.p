block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление расшифровки строк документов МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания:  09/09/05
Author: Polina Gridchina
Creation date: 09/09/05

Автор1: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.wth-dtl.

define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "триггер на удаление расшифровки строк документов МЦ":U.
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                          ,ub.wth-dtl.doc-code
                          ,ub.wth-dtl.wth-code
                          ,ub.wth-dtl.w-p-code
                          ,ub.wth-dtl.par-code
                          )" }

{ cmp/trg-def.i }
{ str/wthparts.i }
define variable rid AS RECID NO-UNDO.
define variable v-mess as character no-undo .

DEF BUFFER buf-doc  FOR ub.wth-doc.
define buffer buf_wth-parts   for ub.wth-parts.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

 /*   FIND buf-doc NO-LOCK WHERE buf-doc.doc-code = ub.wth-dtl.doc-code NO-ERROR.

    if available buf-doc
    and buf-doc.status_ <> {&wayb}
    or buf-doc.is-del = no
    then do:
      assign
      v-mess = substitute("&1 &2 &3&4" +
                          "Невозможно удалить строчку документа МЦ в статусе &5&4Документ &6"
                          ,vss-workfile
                          ,vss-revision
                          ,vss-description
                          ,{&new-line}
                          ,buf-doc.status_
                        ,ub.wth-dtl.doc-code).
      if not g#news then do:
        message
        v-mess
        view-as alert-box error .
      end.
      undo Main-block, return error v-mess.
    end.
    ASSIGN rid = ( IF AVAIL buf-doc THEN RECID( buf-doc ) ELSE ? ).
                                                                     */
   /*  message 'dtldelete' view-as alert-box.  */
for each buf_wth-parts no-lock where
                           buf_wth-parts.w-p-code = ub.wth-dtl.w-p-code
                           and buf_wth-parts.wth-code = ub.wth-dtl.wth-code
                           and buf_wth-parts.par-code = ub.wth-dtl.par-code
                           and buf_wth-parts.out-code = ub.wth-dtl.doc-code
    on error undo, return error return-value:
    run wth-doc-razrez in this-procedure
          ( input recid(buf_wth-parts) ,
            input true
            ).

end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_wth-dtl}
        , input ( buffer ub.wth-dtl:handle )
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