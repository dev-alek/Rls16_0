block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cli-atr1.p $
$Archive: ref/cli-atr1.p $

Сохранение изменений атрибутов клиента

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/04/05
Author: Bakhtadze Natalya
Creation date: 04/04/05

*/

define input parameter p-mode            as character no-undo .
define input parameter p-obj-type        like ub.clients-attr.obj-type no-undo .
define input parameter p-obj-code        like ub.clients-attr.obj-code no-undo .
define temp-table tt0-clients-attr no-undo like ub.clients-attr.
DEFINE INPUT PARAMETER TABLE FOR tt0-clients-attr.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cli-atr1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cli-atr1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений атрибутов клиента".
{ cmp/vssrevis.i "substitute('&1|&2':u,p-obj-type,p-obj-code)" }
{ cmp/trg-def.i }
{ gbl/clntattr.i }

define variable v-deleted as logical no-undo .
define variable v-err-mess as character no-undo .
define variable v-attr-type as character no-undo . /*тип атрибута*/
define variable v-attr-format as character no-undo .  /* формат атрибута*/
define variable v-attr-label as character no-undo .         /*лабел атрибута */
define variable v-attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable v-attr-output-display as logical no-undo .  /*виден в броусе*/
define variable v-attr-other as char no-undo .              /*еще чего - нибудь*/

define buffer buf_clients-attr for ub.clients-attr.
define buffer buf_clients for ub.clients.

_main:
do
on error undo, return error return-value
:
  find first buf_clients no-lock where
          buf_clients.obj-type = p-obj-type
     AND  buf_clients.obj-code = p-obj-code no-error .
  if not available buf_clients then do:
    undo, return error substitute("&1 &2 &3&4Не найден клиент с типом &5 кодом 6"
                                 , vss-workfile
                                 , vss-revision
                                 , vss-description
                                 , {&new-line}
                                 , p-obj-type
                                 , p-obj-code
                                 ).
  end.
  /*обновим clients-attr */
  FOR EACH tt0-clients-attr:
      find FIRST buf_clients-attr WHERE
              buf_clients-attr.obj-type = p-obj-type
          AND buf_clients-attr.obj-code = p-obj-code
          AND buf_clients-attr.attr-code = tt0-clients-attr.attr-code no-error.
    IF not available buf_clients-attr
    or buf_clients-attr.attr-value <> tt0-clients-attr.attr-value
    THEN DO:
      run clntattr-code in this-procedure (
                                                input  tt0-clients-attr.attr-code
                                                ,output v-attr-type
                                                ,output v-attr-format
                                                ,output v-attr-label
                                                ,output v-attr-user-can-edit
                                                ,output v-attr-output-display
                                                ,output v-attr-other
                                             ).
      if v-attr-user-can-edit then do:
        run clntattr-write IN THIS-PROCEDURE(
                                            INPUT p-obj-type
                                            ,INPUT p-obj-code
                                            ,INPUT tt0-clients-attr.attr-code
                                            ,INPUT tt0-clients-attr.attr-value) NO-ERROR.
        IF ERROR-STATUS:ERROR THEN DO:
          assign
          v-err-mess = substitute("Ошибка при сохранении атрибута клиента &1 &2 &3 :&4&5 &6"
                                  , p-obj-type
                                  , p-obj-code
                                  , tt0-clients-attr.attr-code
                                  , {&new-line}
                                  ,error-status:get-message(1)
                                  ,return-value).
          undo _main, return error v-err-mess.
        END.
      end.
      else do:
        undo, return error substitute("Ошибка при сохранении атрибута клиента &1 &2 &3 :&4атрибут не может быть изменен вручную"
                                  , p-obj-type
                                  , p-obj-code
                                  , tt0-clients-attr.attr-code
                                  , {&new-line}).

      end.
    END.
  END.
  if p-mode <> {&add-def} then do:
    FOR EACH buf_clients-attr where
            buf_clients-attr.obj-type = p-obj-type
        AND buf_clients-attr.obj-code = p-obj-code       :
        FIND FIRST tt0-clients-attr NO-LOCK WHERE
            tt0-clients-attr.obj-type = p-obj-type
        AND tt0-clients-attr.obj-code = buf_clients-attr.obj-code
        AND tt0-clients-attr.attr-code = buf_clients-attr.attr-code NO-ERROR.
      IF NOT AVAILABLE tt0-clients-attr THEN DO:
        run clntattr-code in this-procedure (
                                                  input  buf_clients-attr.attr-code
                                                  ,output v-attr-type
                                                  ,output v-attr-format
                                                  ,output v-attr-label
                                                  ,output v-attr-user-can-edit
                                                  ,output v-attr-output-display
                                                  ,output v-attr-other
                                              ).
        if v-attr-user-can-edit then do:
            ASSIGN
            v-deleted = NO.
            RUN clntattr-delete  IN THIS-PROCEDURE (
                                                  input buf_clients-attr.obj-type
                                                  ,input buf_clients-attr.obj-code
                                                  ,INPUT buf_clients-attr.attr-code
                                                  ,output v-deleted ) NO-ERROR.
          IF NOT v-deleted
          or error-status:error
          THEN DO:
            assign
            v-err-mess = substitute("Ошибка при удалении атрибута клиента &1 &2 &3 :&4&5 &6"
                                    , buf_clients-attr.obj-type
                                    , buf_clients-attr.obj-code
                                    , buf_clients-attr.attr-code
                                    , {&new-line}
                                    ,error-status:get-message(1)
                                    ,return-value
                                    ).
            undo _main, return error v-err-mess.

          END.
        end.
        else do:
          if v-attr-output-display then do:
            undo, return error substitute("Ошибка при удалении атрибута клиента &1 &2 &3 :&4атрибут не может быть удален вручную"
                                      , p-obj-type
                                      , p-obj-code
                                      , buf_clients-attr.attr-code
                                      , {&new-line}).
          end.
        end.
      END.
    END.
  end.
end. /*doe*/