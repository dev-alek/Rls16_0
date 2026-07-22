block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gdshatr1.p $
$Archive: ref/gdshatr1.p $

Сохранение изменений атрибутов товара на фирме

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/30/05
Author: Bakhtadze Natalya
Creation date: 03/30/05

*/

define input parameter p-mode            as character no-undo .
define input parameter p-gds-code        like ub.gds-host-attr.gds-code no-undo .
define input parameter p-host-code       like ub.gds-host-attr.host-code no-undo .
define input parameter p-obj-type        like ub.clients.obj-type no-undo .
define input parameter p-obj-code        like ub.clients.obj-code no-undo .
define temp-table tt0-gds-host-attr no-undo like ub.gds-host-attr.
DEFINE INPUT PARAMETER TABLE FOR tt0-gds-host-attr.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gdshatr1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gdshatr1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменеий атрибутов товара на фирме".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,p-gds-code,p-obj-type,p-obj-code)" }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ ref/gdshattr.i }

define variable v-deleted as logical no-undo .
define variable v-err-mess as character no-undo .
define variable v-host-code like ub.gds-host-attr.host-code no-undo .
define buffer buf_gds-host-attr for ub.gds-host-attr.
define buffer buf_goods for ub.goods.

_main:
do
on error undo, return error return-value
:
  find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
  if not available buf_goods then do:
    undo, return error substitute("&1 &2 &3&4Не найден товар с кодом &5"
                                 , vss-workfile
                                 , vss-revision
                                 , vss-description
                                 , {&new-line}
                                 , p-gds-code).
  end.


  { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  /*обновим gds-host-attr */
  FOR EACH tt0-gds-host-attr:
      find FIRST buf_gds-host-attr WHERE buf_gds-host-attr.gds-code = p-gds-code
       AND buf_gds-host-attr.host-code = v-host-code
      AND buf_gds-host-attr.attr-code = tt0-gds-host-attr.attr-code no-error.
    IF not available buf_gds-host-attr
    or buf_gds-host-attr.attr-value <> tt0-gds-host-attr.attr-value
    THEN DO:
      run gdshattr-write IN THIS-PROCEDURE(
                                            input p-gds-code
                                          ,INPUT p-obj-type
                                          ,INPUT p-obj-code
                                          ,INPUT tt0-gds-host-attr.attr-code
                                          ,INPUT tt0-gds-host-attr.attr-value) NO-ERROR.
      IF ERROR-STATUS:ERROR THEN DO:
        assign
        v-err-mess = substitute("Ошибка при сохранении атрибута товара на фирме &1 &2 &3 :&4&5 &6"
                                , p-gds-code
                                , tt0-gds-host-attr.host-code
                                , tt0-gds-host-attr.attr-code
                                , {&new-line}
                                ,error-status:get-message(1)
                                ,return-value).
        undo _main, return error v-err-mess.
      END.
    END.
  END.
  if p-mode <> {&add-def} then do:
    FOR EACH buf_gds-host-attr where buf_gds-host-attr.gds-code = p-gds-code:
      if buf_gds-host-attr.host-code <> p-host-code  then next.
        FIND FIRST tt0-gds-host-attr NO-LOCK WHERE
            tt0-gds-host-attr.gds-code = p-gds-code
        AND tt0-gds-host-attr.host-code = buf_gds-host-attr.host-code
        AND tt0-gds-host-attr.attr-code = buf_gds-host-attr.attr-code NO-ERROR.
      IF NOT AVAILABLE tt0-gds-host-attr THEN DO:
          ASSIGN
          v-deleted = NO.
          RUN gdshattr-delete IN THIS-PROCEDURE (
                                                input buf_gds-host-attr.gds-code
                                                ,input p-obj-type
                                                ,INPUT p-obj-code
                                                ,INPUT buf_gds-host-attr.attr-code
                                                ,output v-deleted ) NO-ERROR.
        IF NOT v-deleted
        or error-status:error
        THEN DO:
          assign
          v-err-mess = substitute("Ошибка при удалении атрибута товара на фирме &1 &2 &3 :&4&5 &6"
                                  , p-gds-code
                                  , buf_gds-host-attr.host-code
                                  , buf_gds-host-attr.attr-code
                                  , {&new-line}
                                  ,error-status:get-message(1)
                                  ,return-value
                                  ).
          undo _main, return error v-err-mess.

        END.
      END.
    END.
  end.
end. /*doe*/