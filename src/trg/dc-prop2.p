block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка валидности записи свойства ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/28/07
Author: Bakhtadze Natalya
Creation date: 03/28/07

*/

define input parameter p-range  as integer no-undo .
define input parameter p-d-card like ub.dis-card-property.d-card no-undo .
define input parameter p-host-code like ub.dis-card-property.host-code no-undo .
define input parameter p-obj-type like ub.dis-card-property.obj-type no-undo .
define input parameter p-obj-code like ub.dis-card-property.obj-code no-undo .
define input parameter p-dtm-code like ub.dis-card-property.dtm-code no-undo .
define input parameter p-node-code like ub.dis-card-property.node-code no-undo .
define input parameter p-dt-code like ub.dis-card-property.dt-code no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка валидности записи свойства ДК".
{ cmp/vssrevis.i }
define buffer buf_sysconf for ub.sysconf.
define buffer buf_clients for ub.clients.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_attr-prop for ub.attr-prop.


{ cmp/trg-def.i }
define variable v-message as character no-undo .

if p-host-code > 0 then do:
  FIND FIRST buf_sysconf No-LOCK WHERE
            buf_sysconf.host-code = p-host-code No-ERROR.
  IF NOT AVAIL buf_sysconf THEN DO:
    run err-mess  in this-procedure (substitute("Не найдена фирма &1", p-host-code)).
    RETURN ERROR v-message.
  END.
end.
if p-obj-type <> "":U or
    p-obj-code <> 0 then do:
  find first buf_clients No-LOCK WHERE
             buf_clients.obj-type = p-obj-type AND
             buf_clients.obj-code = p-obj-code no-error .
  if not available buf_clients then do:
    run err-mess in this-procedure ( input substitute("Не найден объект &1&2", p-obj-type, p-obj-code)).
    RETURN ERROR v-message.

  end.
end.
else if NOT (p-obj-type = "":U and p-obj-code = 0) then do:
  run err-mess in this-procedure ( input  substitute("Неверные значения параметров p-obj-type/p-obj-code и/или p-host-code: &1&2 &3"
                          , p-obj-type
                          , p-obj-code
                          , p-host-code)).
  RETURN ERROR v-message.
end.

if p-d-card <> "":U then do:
  find first buf_dis-card No-LOCK WHERE
              buf_dis-card.d-card = p-d-card No-ERROR.
    if not avail buf_dis-card then do:
    run err-mess in this-procedure ( input  substitute("Не найдена ДК")).
    return error  v-message.
  end.
  if buf_dis-card.emitent-host-code <> 0
  and p-host-code <> buf_dis-card.emitent-host-code then do:
    run err-mess in this-procedure ( input  substitute("Для фирменной карты свойство можно ввести только с привязкой к фирме-эмитенту")).
    return error v-message.
  end.
  if buf_dis-card.emitent-host-code = 0
  and p-range = 1
  and p-host-code <> 0 then do:
    run err-mess in this-procedure ( input  substitute("Для свойство с ОБЛАСТЬЮ ДЕЙСТВИЯ СОГЛАСНО КОДУ ЭМИТЕНТА&1" +
                           "для ГЛОБАЛЬНОЙ карты можно ввести только ГЛОБАЛЬНОЕ свойство"
                            , {&new-line}
                           )).
    return error v-message.
  end.


end.

 PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  assign
  v-message =  substitute("Карта №&1: свойство &2.&3 срез &4 для фирмы &5 объект &6&7&8"
                 , p-d-card
                 , p-dtm-code
                 , p-node-code
                 , p-dt-code
                 , p-host-code
                 , p-obj-type
                 , p-obj-code
                 , {&new-line}
                 )    +
               p-mess
  .
END PROCEDURE.