block-level on error undo, throw.
/*

$Revision: 0ed05d970e58, 3225, rls $
$Author: DRuban $
$Date: 2022/12/27 12:54:29 $
$Workfile: gds-atr1.p $
$Archive: ref/gds-atr1.p $

Сохранение изменений атрибутов товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/04/05
Author: Bakhtadze Natalya
Creation date: 10/04/05

для будущего использовани
вызывать также как и gdsoatr1.p


*/

define input parameter p-mode            as character no-undo .
define input parameter p-gds-code        like ub.goods-attr.gds-code no-undo .
{ ref/g-attr-tt.i}
DEFINE INPUT PARAMETER TABLE FOR tt0-goods-attr.


define variable vss-revision    as character no-undo init "$Revision: 0ed05d970e58, 3225, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:29 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gds-atr1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gds-atr1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменеий атрибутов товара".
{ cmp/vssrevis.i "substitute('&1':u,p-gds-code)" }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ ref/gds-attr.i }

define variable v-deleted as logical no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_goods-attr for ub.goods-attr.
define buffer buf_goods for ub.goods.
define variable v-num-section            as integer no-undo.
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
  /*обновим goods-attr */
  FOR EACH tt0-goods-attr where tt0-goods-attr.grp ne yes:
    if p-mode <> {&add-def} then do:
      find FIRST buf_goods-attr WHERE buf_goods-attr.gds-code = p-gds-code
      AND buf_goods-attr.attr-code = tt0-goods-attr.attr-code no-error.
    end.
    IF p-mode = {&add-def}
    or not available buf_goods-attr
    or buf_goods-attr.attr-value <> tt0-goods-attr.attr-value THEN DO:
      run gds-attr-write IN THIS-PROCEDURE(
                                           input p-gds-code
                                          ,INPUT tt0-goods-attr.attr-code
                                          ,INPUT tt0-goods-attr.attr-value) NO-ERROR.
      IF ERROR-STATUS:ERROR THEN DO:
        assign
        v-err-mess = substitute("Ошибка при сохранении атрибута товара &1 &2 :&3&4 &5"
                                , p-gds-code
                                , tt0-goods-attr.attr-code
                                , {&new-line}
                                ,error-status:get-message(1)
                                ,return-value).
        undo _main, return error v-err-mess.
      END.
    END. /*были изменения*/
  END. /*FOR EACH tt0-goods-attr:*/
  if p-mode <> {&add-def} then do:
    FOR EACH buf_goods-attr where buf_goods-attr.gds-code = p-gds-code:
        v-num-section = ?.
        FIND FIRST tt0-goods-attr NO-LOCK WHERE
            tt0-goods-attr.gds-code = p-gds-code
        AND tt0-goods-attr.attr-code = buf_goods-attr.attr-code 
        and tt0-goods-attr.grp ne yes NO-ERROR.
          IF NOT AVAILABLE tt0-goods-attr THEN DO:              
                run gds-attr-manual-edit in this-procedure (input buf_goods-attr.attr-code
                                                       , output v-num-section) no-error. 
                IF       error-status:error
                    and  buf_goods-attr.attr-code ne {&attr-gds-attr-lock}
                THEN DO:
                  assign
                  v-err-mess = substitute("Ошибка при удалении атрибута товара &1 &2 :&3&4 &5"
                                          , p-gds-code
                                          , buf_goods-attr.attr-code
                                          , {&new-line}
                                          ,error-status:get-message(1)
                                          ,return-value
                                          ).
                  undo _main, return error v-err-mess.
                END. /* gds-attr-manual-edit */                                                   
           if v-num-section > 0 then do:         /* Если атрибут есть, но он заполняется не через обычный интерфейс, то не надо запись удалять из базы */                                      
                  ASSIGN
                  v-deleted = NO.                
                  RUN gds-attr-delete IN THIS-PROCEDURE (
                                                        input buf_goods-attr.gds-code
                                                        ,INPUT buf_goods-attr.attr-code
                                                        ,output v-deleted ) NO-ERROR.
                                                                                                                
                IF NOT v-deleted
                or error-status:error
                THEN DO:
                  assign
                  v-err-mess = substitute("Ошибка при удалении атрибута товара &1 &2 :&3&4 &5"
                                          , p-gds-code
                                          , buf_goods-attr.attr-code
                                          , {&new-line}
                                          ,error-status:get-message(1)
                                          ,return-value
                                          ).
                  undo _main, return error v-err-mess.
                END. /* NOT v-deleted */
            end. /* v-num-section > 0 */
          END. /*IF NOT AVAILABLE tt0-goods-attr THEN DO:*/

    END. /*FOR EACH buf_goods-attr where buf_goods-attr.gds-code = p-gds-code:*/
  end.
end. /*doe*/