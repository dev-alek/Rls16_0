block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись партий номинала МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 05/10/07
Author: Polina Gridchina
Creation date: 05/10/07

Input:

Output:

*/

 TRIGGER PROCEDURE FOR WRITE OF ub.wth-parts NEW BUFFER Buf-New OLD BUFFER Buf-Old.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись партий номинала МЦ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                          ,buf-new.out-code
                          ,buf-new.wth-code
                          ,buf-new.w-p-code
                          ,buf-new.par-code
                          )" }
{ cmp/trg-def.i  }
{ cmp/library.i  }
 define buffer buf-lin for ub.wth-line.
 define buffer buf-doc for ub.wth-doc.
 define variable v-mess     as character no-undo .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  IF NOT g#news  THEN DO:
     FIND FIRST buf-doc NO-LOCK WHERE
               buf-doc.doc-code = (if lookup(Buf-New.out-code,{&WDEDT_List-Zone}) > 0 then buf-new.doc-code   else buf-new.out-code)
                NO-ERROR.
    IF NOT AVAIL buf-doc and lookup(Buf-New.out-code,{&WDEDT_List-Zone}) = 0 /*buf-new.doc-code > '' */  THEN DO:
      UNDO Main-Block, RETURN ERROR "Не найден документ движения МЦ с номером " + (if lookup(Buf-New.out-code,{&WDEDT_List-Zone}) > 0 then buf-new.doc-code   else buf-new.out-code) .
    END.
    /*FIND FIRST buf-lin NO-LOCK WHERE
              buf-lin.doc-code = Buf-New.out-code AND
              buf-lin.wth-code = Buf-New.wth-code AND
              buf-lin.w-p-code = Buf-New.w-p-code NO-ERROR.
    IF NOT AVAIL buf-lin THEN DO:
      MESSAGE
        vss-workfile vss-revision SKIP vss-description SKIP( 1 )
        "Нет строки" Buf-New.wth-code "для места хранения МЦ" Buf-New.w-p-code "документа" Buf-New.out-code "!"
      VIEW-AS ALERT-BOX ERROR.
      UNDO Main-Block, RETURN ERROR.
    END. */

    if new(buf-new) and lookup(Buf-New.out-code,{&WDEDT_List-Zone}) = 0
    and buf-doc.status_ <> {&wayb}     then do:
      assign
      v-mess = substitute("&1 &2 &3&4" +
                          "Невозможно добавлять по документу МЦ в статусе &5&4Документ &6"
                          ,vss-workfile
                          ,vss-revision
                          ,vss-description
                          ,{&new-line}
                          ,buf-doc.status_
                          ,buf-new.out-code).
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
        , input {&table_arh-wth-cli-doc}
        , input ( buffer ub.arh-wth-cli-doc:handle )
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

end.