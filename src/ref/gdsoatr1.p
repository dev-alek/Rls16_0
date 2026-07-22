block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gdsoatr1.p $
$Archive: ref/gdsoatr1.p $

Сохранение изменеий атрибутов товара на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/30/05
Author: Bakhtadze Natalya
Creation date: 03/30/05

*/

define input parameter p-mode            as character no-undo .
define input parameter p-gds-code        like ub.gds-obj-attr.gds-code no-undo .
define input parameter p-obj-type        like ub.gds-obj-attr.obj-type no-undo .
define input parameter p-obj-code        like ub.gds-obj-attr.obj-code no-undo .
define temp-table tt0-gds-obj-attr no-undo like ub.gds-obj-attr.
DEFINE INPUT PARAMETER TABLE FOR tt0-gds-obj-attr.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gdsoatr1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gdsoatr1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменеий атрибутов товара на объекте".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,p-gds-code,p-obj-type,p-obj-code)" }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ ref/gdsoattr.i }

define variable v-deleted as logical no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_gds-obj-attr for ub.gds-obj-attr.
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
  /*обновим gds-obj-attr */
  FOR EACH tt0-gds-obj-attr where
           tt0-gds-obj-attr.obj-type = p-obj-type
       AND tt0-gds-obj-attr.obj-code = p-obj-code
  on error undo, return error return-value
       :
    if p-mode <> {&add-def} then do:
      find FIRST buf_gds-obj-attr WHERE buf_gds-obj-attr.gds-code = p-gds-code
      AND buf_gds-obj-attr.obj-type = tt0-gds-obj-attr.obj-type
      AND buf_gds-obj-attr.obj-code = tt0-gds-obj-attr.obj-code
      AND buf_gds-obj-attr.attr-code = tt0-gds-obj-attr.attr-code no-error.
    end.
    IF p-mode = {&add-def}
    or not available buf_gds-obj-attr
    or buf_gds-obj-attr.attr-value <> tt0-gds-obj-attr.attr-value THEN DO:
      run gdsoattr-write IN THIS-PROCEDURE(
                                           input p-gds-code
                                          ,INPUT tt0-gds-obj-attr.obj-type
                                          ,INPUT tt0-gds-obj-attr.obj-code
                                          ,INPUT tt0-gds-obj-attr.attr-code
                                          ,INPUT tt0-gds-obj-attr.attr-value) NO-ERROR.
      IF ERROR-STATUS:ERROR THEN DO:
        assign
        v-err-mess = substitute("Ошибка при сохранении атрибута товара на объекте &1 &2 &3 :&4&5 &6"
                                , p-gds-code
                                , (tt0-gds-obj-attr.obj-type + string(tt0-gds-obj-attr.obj-code))
                                , tt0-gds-obj-attr.attr-code
                                , {&new-line}
                                ,error-status:get-message(1)
                                ,return-value).
        undo _main, return error v-err-mess.
      END.
    END. /*были изменения*/
  END. /*FOR EACH tt0-gds-obj-attr:*/
  if p-mode <> {&add-def} then do:
    FOR EACH buf_gds-obj-attr where buf_gds-obj-attr.gds-code = p-gds-code
    on error undo, return error return-value
    :
      if buf_gds-obj-attr.obj-type <> p-obj-type
      or buf_gds-obj-attr.obj-code <> p-obj-code  then next.
      if buf_gds-obj-attr.attr-code = {&attr-gds-obj-attr-lock-o} then next.
        FIND FIRST tt0-gds-obj-attr NO-LOCK WHERE
            tt0-gds-obj-attr.gds-code = p-gds-code
        AND tt0-gds-obj-attr.obj-type = buf_gds-obj-attr.obj-type
        AND tt0-gds-obj-attr.obj-code = buf_gds-obj-attr.obj-code
        AND tt0-gds-obj-attr.attr-code = buf_gds-obj-attr.attr-code NO-ERROR.
      IF NOT AVAILABLE tt0-gds-obj-attr THEN DO:
          ASSIGN
          v-deleted = NO.
          RUN gdsoattr-delete IN THIS-PROCEDURE (
                                                input buf_gds-obj-attr.gds-code
                                                ,input buf_gds-obj-attr.obj-type
                                                ,INPUT buf_gds-obj-attr.obj-code
                                                ,INPUT buf_gds-obj-attr.attr-code
                                                ,output v-deleted ) NO-ERROR.
        IF NOT v-deleted
        or error-status:error
        THEN DO:
          assign
          v-err-mess = substitute("Ошибка при удалении атрибута товара на объекте &1 &2 &3 :&4&5 &6"
                                  , p-gds-code
                                  , (buf_gds-obj-attr.obj-type + string(buf_gds-obj-attr.obj-code))
                                  , buf_gds-obj-attr.attr-code
                                  , {&new-line}
                                  ,error-status:get-message(1)
                                  ,return-value
                                  ).
          undo _main, return error v-err-mess.
        END. /*tt0-gds-obj-attr.attr-code*/
      END. /*IF NOT AVAILABLE tt0-gds-obj-attr THEN DO:*/
    END. /*FOR EACH buf_gds-obj-attr where buf_gds-obj-attr.gds-code = p-gds-code:*/
  end.
end. /*doe*/