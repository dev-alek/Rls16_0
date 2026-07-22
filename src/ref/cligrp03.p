/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление группы клиентов из базы данных

Автор: Молотков Сергей
Дата создания: 06/10/17
Author: Molotkov Sergey
Creation date: 06/10/17

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/
BLOCK-LEVEL ON ERROR UNDO, THROW.

define input parameter p-node-code  like ub.cli-grp.node-code .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Удаление группы клиентов из базы данных".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ ref/cgrplib.i }

define variable v-root-code    as integer no-undo . /* cli-grp.node-code от корневого узла */
define variable v-is-terminal  as logical no-undo. /* true: если отсутствует дочерняя cli-grp (т.е. отсутствует upper-code = p-node-code) */ 
define variable v-have-clients as logical no-undo . /* true если can-find clients где grp-code = p-node-code */
define buffer      buf_cli-grp for ub.cli-grp .
&scoped-define buf-name buf_cli-grp
define buffer     buf2_cli-grp for ub.cli-grp .
define buffer buf_same_cli-grp for ub.cli-grp . /* для проверки совпадения имён */


    /* нельзя удалять корневые группы,
       и нельзя удалять, если корневые группы уже удалили */
    run cgrplib-get-root-code in this-procedure ( output v-root-code ) no-error .
    if error-status :error then do:
      undo, throw new Progress.Lang.AppError(
        substitute("&1 &2 &3&4Не найден корневой узел",
                   vss-workfile, vss-revision, vss-description, {&new-line})
      ) .
    end.
    if p-node-code = v-root-code then do:
      undo, throw new Progress.Lang.AppError(
        substitute("&1 &2 &3&4Запись о группе клиентов с кодом [&5] корневая. Нельзя удалить корневую группу",
                   vss-workfile, vss-revision, vss-description, {&new-line}, 
                   p-node-code )
      ) .
    end.
    

    find first {&buf-name} exclusive-lock where {&buf-name}.node-code = p-node-code no-error no-wait .
    if locked({&buf-name}) then do:
      undo, throw new Progress.Lang.AppError(
        substitute("&1 &2 &3&4Запись о группе клиентов с кодом [&5] занята другим пользователем",
                   vss-workfile, vss-revision, vss-description, {&new-line}, 
                   p-node-code )
      ) .
    end . 
    if not available {&buf-name} then do:
      undo, throw new Progress.Lang.AppError(
        substitute("&1 &2 &3&4Запись о группе клиентов с кодом [&5] отсутствует",
                   vss-workfile, vss-revision, vss-description, {&new-line}, 
                   p-node-code )
      ) .
    end .


    /* нельзя удалять последнюю группу первого уровня */
    if {&buf-name}.upper-code = v-root-code then do:
      if can-find (buf2_cli-grp where buf2_cli-grp.upper-code = v-root-code) then do:
        /* если сработал find без first, значит удаляемая группа - единственная */
        undo, throw new Progress.Lang.AppError(
          substitute("&1 &2 &3&4группа клиентов с кодом [&5] является единственной группой первого уровня.&4Нельзя удалить последнюю группу первого уровня.",
                   vss-workfile, vss-revision, vss-description, {&new-line}, 
                   p-node-code )
        ) .
      end .
    end .
    
    /* после удаления группы её подгруппы будут вынесены наружу, на текущий уровень;
       при этом нельзя, чтобы на одном уровне одновременно были подгруппы и клиенты,
       и нельзя, чтобы на одном уровне две подгруппы имели одинаковые названия */
    run cgrplib-is-terminal in this-procedure ( input p-node-code , output v-is-terminal ) no-error .
    if error-status :error then do:
      undo, throw new Progress.Lang.AppError(
        substitute("&1 &2 &3&4&6&4Ошибка определения типа группы (терм/корн) для группы [&5]",
                   vss-workfile, vss-revision, vss-description, {&new-line}, 
                   p-node-code, return-value)
      ) .
    end .
    if v-is-terminal then do: /* терминальная группа */
      run cgrplib-have-clients in this-procedure ( input p-node-code, output v-have-clients ) no-error .
      if error-status :error then do:
        undo, throw new Progress.Lang.AppError(
          substitute("&1 &2 &3&4Ошибка определения наличия клиентов в группе [&5]",
                     vss-workfile, vss-revision, vss-description, {&new-line}, 
                     p-node-code )
        ) .
      end.
      if v-have-clients then do:
        /* после удаления клиенты группы будут перепривязаны на уровень выше;
           при этом на уровне выше не должно быть других групп, иначе на одном уровне одновременно будут группы и клиенты */
        if can-find (first buf2_cli-grp
                     where buf2_cli-grp.upper-code = {&buf-name}.upper-code
                       and buf2_cli-grp.node-code <> p-node-code) then do:
          undo, throw new Progress.Lang.AppError(
            substitute("&1 &2 &3&4Группа [&5] является терминальной и содержит клиентов." +
                       "&4После удаления клиенты группы [&5] будут перенесены на уровень выше, в группу [&6]." +
                       "&4Удаление не допустимо, т.к. группа [&6] содержит другие группы." +
                       "&4В одной группе не могут быть одновременно подгруппы и клиенты." +
                       "&4Группа [&5] не может быть слита с вышестоящей группой [&6].",
                       vss-workfile, vss-revision, vss-description, {&new-line}, 
                       p-node-code, {&buf-name}.upper-code )
          ) .
        end.
      end.
    end .
    else do: /* группа с вложенными подгруппами */
      /* проверяем, не имеет ли одна из подгрупп такое же название, как и соседняя с удаляемой */
      for each buf2_cli-grp no-lock
         where buf2_cli-grp.upper-code = {&buf-name}.upper-code
           and buf2_cli-grp.node-code <> p-node-code :
        find first buf_same_cli-grp no-lock
             where buf_same_cli-grp.upper-code = p-node-code
               and buf_same_cli-grp.node-name  = buf2_cli-grp.node-name no-error .
        if available buf_same_cli-grp then do:
          undo, throw new Progress.Lang.AppError(
            substitute("&1 &2 &3&4Подгруппа [&6] группв [&5] имеет название такое же, как соседняя с удаляемой группой группа [&7]." +
                       "&4После удаления две группы на одном уровне будут иметь одинаковые названия [&8], что запрещено.",
                       vss-workfile, vss-revision, vss-description, {&new-line}, 
                       p-node-code, buf_same_cli-grp.node-code, buf2_cli-grp.node-code, buf2_cli-grp.node-name )
          ) .
        end .
      end .
    end .

     
    delete {&buf-name} .
