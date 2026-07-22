block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ef-serv.p $
$Archive: utl/ef-serv.p $

Обслуживание мобильного блока EasyFuel

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/30/08
Author: Bakhtadze Natalya
Creation date: 05/30/08

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ef-serv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ef-serv.p $":U .
define variable vss-description as character no-undo init "Обслуживание мобильного блока EasyFuel".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define variable v-operations as character no-undo .
define variable v-operation-codes as character no-undo .
define variable v-selected-operation as character no-undo .
define variable v-operation-name as character no-undo .
define variable v-run-file-name as character no-undo .
define variable v-can-init as logical no-undo .
/*проверим права на инициализацию*/

{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_easyfuel_initialization':U
{&cntxt-object}
v-cntxt-host-code-obj
v-cntxt-obj-type
v-cntxt-obj-code
0
0
0
false
v-can-init
}


assign
v-operations = "":U
v-operation-codes = "":U
v-selected-operation = "start"
.
if v-can-init then do:
  assign
  v-operations = "Первоначальная прошивка в МБ данных транспортного средства и лимитов" + {&delim-par} +
                "Изменение номера и марки трансп. средства" + {&delim-par} +
                "Изменение топлив, привязанных к МБ и их лимитов" + {&delim-par} +
                "Восстановление данных на МБ согласно данным, хранящимся в системе"  + {&delim-par} +
                "Считывание данных с МБ и сравнение их с хранящимися в системе"

  v-operation-codes  = "initialize" + {&delim-par} +
                       "reg-num" + {&delim-par} +
                       "petrol" + {&delim-par} +
                       "restore" + {&delim-par} +
                       "read"

  .
end.
else do:
  assign
  v-operations = "Считывание данных с МБ и сравнение их с хранящимися в системе"
  v-operation-codes  = "read"
  .
end.
do while v-selected-operation <> "":
  run gbl/d-list.w (
                INPUT "b-sel":U
                ,INPUT "Выберите операцию с МБ EasyFuel"
                ,INPUT v-operation-codes
                ,INPUT v-operations
                ,INPUT {&delim-par}
                ,INPUT "":U
                ,output v-selected-operation).
  IF v-selected-operation = "":u THEN do:
    RETURN "".
  end.
  assign
  v-operation-name = entry(lookup(v-selected-operation, v-operation-codes, {&delim-par}) , v-operations, {&delim-par})
  .
  case v-selected-operation:
    when "" then do:
      return ''.
    end.
    when "initialize" then do:
      v-run-file-name = "utl/ef-init.p".
    end.
    when "reg-num" then do:
      v-run-file-name = "utl/efregnum.p".
    end.
    when "petrol" then do:
      v-run-file-name = "utl/eflimits.p".
    end.
    when "restore" then do:
      /*v-run-file-name = "utl/efrestor.p".*/
    end.
    when "read" then do:
      v-run-file-name = "utl/ef-read.p".
    end.
  end case.
  if v-run-file-name = "" then do:
    message
    "under construction"
    view-as alert-box .
  end.
  else do:
    run str/diallog.w ( input parparentproc
                , input this-procedure
                , input v-run-file-name
                , input ""
                , input yes /*p-auto-go*/
                , input ''
                , input v-operation-name) no-error .
    if error-status:error
    or return-value = "error"
    then do:
      message
      substitute("Ошибки при выполнение операции &1:&2" +
                  "&3&2&4"
                  , v-operation-name
                  , {&new-line}
                  , error-status:get-message(1)
                  , return-value )
      view-as alert-box error .
    end.
  end.
end.