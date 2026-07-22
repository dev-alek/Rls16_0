block-level on error undo, throw.
/*

$Revision: 8c1a0fd433e1, 1120, rls $
$Author: SMMolotkov $
$Date: Thu Dec 14 02:13:53 2017 +0300 $
$Workfile: db01.p $
$Archive: adm/db01.p $

Сохранение изменений в карточке базы данных

Автор: Молотков Сергей
Дата создания: 05/10/17
Author: Molotkov Sergey
Creation date: 05/10/17

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/
define input-output parameter p-rec                 as recid no-undo .
define input parameter        p-mode                as character no-undo .
define input parameter        p-db-num              like ub.db.db-num no-undo .
define input parameter        p-db-name             like ub.db.db-name no-undo .
define input parameter        p-add-clients         like ub.db.add-clients no-undo .
define input parameter        p-send-check          like ub.db.send-check no-undo .
define input parameter        p-add-goods           like ub.db.add-goods no-undo .
define input parameter        p-save-packs          like ub.db.save-packs no-undo .

define variable vss-revision    as character no-undo init "$Revision: 8c1a0fd433e1, 1120, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:53 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: db01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/db01.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке магазина".
{ cmp/vssrevis.i }

/* { cmp/trg-def.i } */
{ cmp/str-glbl.i }

define buffer buf_db for ub.db .


/* часть вышестоящей транзакции: если отваливается создание записи о БД - вместе с ней отлетает и создание записи о магазине */
do on error undo, throw:
  
  if lookup(p-mode, "{&bef-add-def},{&bef-update}") = 0 then do:
    undo, throw new Progress.Lang.AppError(
      substitute("&1 &2 &3&4Неверный параметр p-mode. Не предусмотрена операция [&5]",
                 vss-workfile, vss-revision, vss-description, {&new-line}, 
                 p-mode )
    ) .
  end .

  if p-db-name > "" then .
  else do: /* "Название БД не может быть пустым." */
    undo, throw new Progress.Lang.AppError(
      substitute("&1 &2 &3&4Имя БД отсутствует",
                 vss-workfile, vss-revision, vss-description, {&new-line})
    ) .
  end .
  
  if p-save-packs < 10 then do:
    undo, throw new Progress.Lang.AppError(
      substitute("&1 &2 &3&4Минимальный период хранения пакетов 10 дней.&4Удалять пакеты через [&5] дней нельзя.",
                 vss-workfile, vss-revision, vss-description, {&new-line},
                 p-save-packs )
    ) .
  end.
  

  case p-mode:
    when {&add-def} then do:
      /* поле ub.db-num присваивается только при создании;
         при редактировании параметр p-db-num не используется */
      if p-db-num = ? then do:
        undo, throw new Progress.Lang.AppError(
          substitute("&1 &2 &3&4Номер БД отсутствует",
                     vss-workfile, vss-revision, vss-description, {&new-line})
        ) .
      end .
      if can-find (first buf_db where buf_db.db-num = p-db-num) then do:
        undo, throw new Progress.Lang.AppError(
          substitute("&1 &2 &3&4БД с номером [&5] уже существует",
                     vss-workfile, vss-revision, vss-description, {&new-line}, 
                     p-db-num )
        ) .
      end .
      create buf_db .
      assign
        buf_db.db-num       = p-db-num
        buf_db.db-key       = "":U
        buf_db.db-key-enc   = "":U
        buf_db.remote-stock = false
        buf_db.on-line-rest = false
        buf_db.max-p-size   = 10000 /* согласно скрин-шоту Юрия Румянцева от 02-мар-2017 */
        buf_db.max-p-queue  = 10    /* согласно скрин-шоту Юрия Румянцева от 02-мар-2017 */
        buf_db.max-p-time   = 0
        buf_db.unload-arch  = true
        buf_db.unload-aht   = true
      .
    end. /* end_of CREATE */
    when {&update} then do:
      find first buf_db exclusive-lock where recid(buf_db) = p-rec no-error no-wait .
      if locked(buf_db) then do:
        undo, throw new Progress.Lang.AppError(
          substitute("&1 &2 &3&4Запись о БД с ид. [&5] занята другим пользователем",
                     vss-workfile, vss-revision, vss-description, {&new-line}, 
                     p-rec )
        ) .
      end . 
      if not available buf_db then do:
        undo, throw new Progress.Lang.AppError(
          substitute("&1 &2 &3&4Запись о БД с ид. [&5] отсутствует",
                     vss-workfile, vss-revision, vss-description, {&new-line}, 
                     p-rec )
        ) .
      end .
    end . /* end_of UPDATE */
    otherwise .
  end case .

  assign
    buf_db.db-name     = p-db-name
    buf_db.add-clients = p-add-clients
    buf_db.send-check  = p-send-check
    buf_db.add-goods   = p-add-goods
    buf_db.save-packs  = p-save-packs
  .
  validate buf_db .
    
end. /* end_of doe */    
