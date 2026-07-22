block-level on error undo, throw.
/*

$Revision: d47c064bc860, 1107, rls $
$Author: SMMolotkov $
$Date: Thu Dec 14 02:13:53 2017 +0300 $
$Workfile: init-db.p $
$Archive: adm/init-db.p $

Инициализация БД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/

define input parameter loc_db-num as integer   no-undo . /* номер базы данных */
define input parameter ld-name    as character no-undo . /* логическое имя базы данных */
define input parameter p-language as character no-undo . /* язык */
define input parameter p-r-b      as character no-undo . /* валюта прайс-листа */
define input parameter p-sys-key  as character no-undo . /* системный ключ */
define input parameter mess-view  as logical   no-undo . /* выводить сообщение в начале и в конце работы утилиты */
define input parameter p-create-adm as logical          no-undo. /* */
define input parameter p-extra-to as integer   no-undo . /* раскрутка под: 0=ниподкого, 1="1С", 2= */ 

def var vss-revision    as character no-undo init "$Revision: d47c064bc860, 1107, rls $":U .
def var vss-author      as character no-undo init "$Author: SMMolotkov $":U .
def var vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:53 2017 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: init-db.p $":U .
def var vss-archive     as character no-undo init "$Archive: adm/init-db.p $":U .
def var vss-description as character no-undo init "Инициализация БД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  define variable prev-ld-name as character no-undo .
  define variable g#log        as logical   no-undo .
  define variable err-log      as logical   no-undo .

  if mess-view then do:
    message
      "Инициализация БД. Продолжать ?"
      view-as alert-box question buttons OK-Cancel update g#log
      .
    if not g#log then do:
      return error.
    end.
  end.

  assign
    prev-ld-name = LDBNAME("DICTDB")
  .
  create alias "DICTDB" for database VALUE( ld-name ) no-error.
  if error-status:error then do:
    message "Не могу выбрать в качестве рабочей БД:" ld-name
      view-as alert-box error
      .
    return error.
  end.

  assign
    err-log = FALSE
  .
  
  lv-block:
  do
  on error undo, leave lv-block
  :
    run adm/init-chk.p no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description          skip
        "Инициализируемая БД должна содержать определения" skip
        "и в ней не должно быть не одной записи." skip
        return-value skip
        view-as alert-box error .
      assign
        err-log = TRUE
      .
      undo, leave lv-block.
    end.

    run adm/initftbl.p
      ( input loc_db-num
       ,input p-language
       ,input p-r-b
       ,input p-sys-key
       ,input p-extra-to
      ) no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description                   skip
        "Не удалась первичная инициализация справочников."
        view-as alert-box error .
      assign
        err-log = TRUE
      .
      undo, leave lv-block.
    end.
    
    IF loc_db-num = 0
    THEN DO:
      run utl/kick-db.p ( input p-sys-key ) no-error .
      if error-status:error then do:
         message
         vss-workfile vss-revision vss-description                   skip
         "Не удалась первичная инициализация валют, основных единиц и пр.."
         view-as alert-box error .
         assign
         err-log = TRUE
         .
         undo, leave lv-block.
      end.
    END.

    run adm/init-adm.p
      ( input false
      , input loc_db-num
      , input p-create-adm
      ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description  skip
        "Не удалась первичная инициализация пользователей."
        view-as alert-box error .
      assign
        err-log = TRUE
      .
      undo, leave lv-block.
    end.
  end.

  create alias "DICTDB" for database VALUE( prev-ld-name ) no-error.
  if error-status:error then do:
    message "Не могу вернуть в качестве рабочей БД:" prev-ld-name
      view-as alert-box error
      .
    return error.
  end.

  if mess-view then do:
    if err-log = TRUE then do:
      message
        "Не удалось инициализировать БД №" loc_db-num
        view-as alert-box .
    end.
    else do:
      message
        "Инициализация БД №" loc_db-num "закончена успешно." skip
        "БД" ld-name "отсоеденена."
        view-as alert-box .
    end.
  end.
  if err-log = TRUE then do:
    return error.
  end.

end.


/* kick-db.p вызывается из adm/init-db.p и из gbl/menuload.p;
   чтобы не менять параметры вызова из menuload.p - получаем входные параметры через указатель на вызывающую процедуру */
procedure get-param :
define output parameter p-get-extra-to as integer no-undo.
  p-get-extra-to = p-extra-to.
end procedure.