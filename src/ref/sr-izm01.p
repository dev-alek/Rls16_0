/*

$Revision: c93c7157b47d, 2925, rls $
$Author: VRukavishnikov $
$Date: Пн ноя 22 19:49:14 2021 +0300 $
$Workfile: sr-izm01.p $
$Archive: ref/sr-izm01.p $

Сохранение изменений в карточке средства измерения (прибора)

Автор: Молотков Сергей
Дата создания: 04/12/17
Author: Molotkov Sergey
Creation date: 04/12/17

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/
block-level on error undo, throw.

define input parameter p-node-code                   as integer   no-undo . /* like ub.sr-izmerenia.node-code */
define input parameter p-sr-type-izm                 as integer   no-undo . /* like ub.sr-izmerenia.sr-type-izm */
define input parameter p-sr-model                    as character no-undo . /* like ub.sr-izmerenia.sr-model */
define input parameter p-sr-level                    as integer   no-undo . /* like ub.sr-izmerenia.sr-level */
define input parameter p-sr-temperature              as integer   no-undo . /* like ub.sr-izmerenia.sr-temperature */
define input parameter p-sr-density                  as integer   no-undo . /* like ub.sr-izmerenia.sr-density */
define input parameter p-sr-Weight                   as integer   no-undo . /* like ub.sr-izmerenia.sr-Weight */
define input parameter p-sr-type-level-measuring     as integer   no-undo . /* like ub.sr-izmerenia.sr-type-level-measuring */
define input parameter p-sr-type-id                  as integer   no-undo . /* like ub.sr-izmerenia.sr-type-id */
define input parameter p-sr-abs-err-neft-water       as decimal   no-undo . /* like ub.sr-izmerenia.sr-abs-err-neft-water */
define input parameter p-sr-relative-err-neft-water  as decimal   no-undo . /* like ub.sr-izmerenia.sr-relative-err-neft-water */
define input parameter p-sr-abs-err-water            as decimal   no-undo . /* like ub.sr-izmerenia.sr-abs-err-water */
define input parameter p-sr-relative-err-water       as decimal   no-undo . /* like ub.sr-izmerenia.sr-relative-err-water */
define input parameter p-sr-abs-err-dens             as decimal   no-undo . /* like ub.sr-izmerenia.sr-abs-err-dens */
define input parameter p-sr-abs-err-temp-vol         as decimal   no-undo . /* like ub.sr-izmerenia.sr-abs-err-temp-vol */
define input parameter p-sr-abs-err-temp-dens        as decimal   no-undo . /* like ub.sr-izmerenia.sr-abs-err-temp-dens */
define input parameter p-sr-relative-err-dens        as decimal   no-undo . /* like ub.sr-izmerenia.sr-relative-err-dens */
define input parameter p-sr-abs-err-dens-lgas-liquid as decimal   no-undo . /* like ub.sr-izmerenia.sr-abs-err-dens-lgas-liquid */
define input parameter p-sr-relative-err-dens-lgas-liquid as decimal   no-undo . /* like ub.sr-izmerenia.sr-relative-err-dens-lgas-liquid */
define input parameter p-sr-abs-err-dens-lgas-vapor  as decimal   no-undo . /* like ub.sr-izmerenia.sr-abs-err-dens-lgas-vapor */
define input parameter p-sr-otnos                    as decimal   no-undo . /* like ub.sr-izmerenia.sr-otnos */
define input parameter p-sr-temp-line                as decimal   no-undo . /* like ub.sr-izmerenia.sr-temp-line */
define input parameter p-sr-not-used                 as integer   no-undo . /*  */

define variable vss-revision    as character no-undo init "$Revision: c93c7157b47d, 2925, rls $":U .
define variable vss-author      as character no-undo init "$Author: VRukavishnikov $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:14 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sr-izm01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/sr-izm01.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке средства измерения (прибора)".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }

define buffer buf_sr-izmerenia for ub.sr-izmerenia .


  if p-sr-model > "" then .
  else do: /* Название не может быть пустым */
    undo, throw new Progress.Lang.AppError(
      substitute("&1 &2 &3&4Пожалуйста заполните наименование модели средства измерения",
                 vss-workfile, vss-revision, vss-description, {&new-line})
    ) .
  end .
/*
  if p-sr-density = 1 and (p-sr-abs-err-dens-lgas-liquid = 0.0 or p-sr-abs-err-dens-lgas-liquid = ?) and
     (p-sr-relative-err-dens-lgas-liquid = 0.0 or p-sr-relative-err-dens-lgas-liquid = ?) then do:
        undo, throw new Progress.Lang.AppError(
                substitute("&1 &2 &3&4Хотя бы один из атрибутов <dnst-abs-me-lpg-l> и <dnst-rel-me-lpg-l> должен быть не нулевым [&5]",
                 vss-workfile, vss-revision, vss-description, {&new-line},
                 p-node-code) 
      ) .  
  end.
/*  BTS-778 Удаление проверок на обязательность/заполненность тегов   */
*/

  if can-find (first buf_sr-izmerenia
  where buf_sr-izmerenia.sr-model                    = p-sr-model
    AND buf_sr-izmerenia.sr-level                    = (p-sr-level > 0)
    AND buf_sr-izmerenia.sr-temperature              = (p-sr-temperature > 0)
    AND buf_sr-izmerenia.sr-density                  = (p-sr-density > 0)
    AND buf_sr-izmerenia.sr-Weight                   = (p-sr-Weight > 0)
    AND buf_sr-izmerenia.sr-type-id                  = p-sr-type-id
    AND buf_sr-izmerenia.sr-abs-err-neft-water       = p-sr-abs-err-neft-water
    AND buf_sr-izmerenia.sr-abs-err-water            = p-sr-abs-err-water
    AND buf_sr-izmerenia.sr-abs-err-dens             = p-sr-abs-err-dens
    AND buf_sr-izmerenia.sr-abs-err-temp-vol         = p-sr-abs-err-temp-vol
    AND buf_sr-izmerenia.sr-abs-err-temp-dens        = p-sr-abs-err-temp-dens
    AND buf_sr-izmerenia.sr-otnos                    = p-sr-otnos
    AND buf_sr-izmerenia.sr-temp-line                = p-sr-temp-line
    AND buf_sr-izmerenia.sr-type-izm                 = p-sr-type-izm
    AND buf_sr-izmerenia.sr-type-level-measuring     = p-sr-type-level-measuring     
    AND buf_sr-izmerenia.sr-relative-err-neft-water  = p-sr-relative-err-neft-water  
    AND buf_sr-izmerenia.sr-relative-err-water       = p-sr-relative-err-water       
    AND buf_sr-izmerenia.sr-relative-err-dens        = p-sr-relative-err-dens        
    AND buf_sr-izmerenia.sr-abs-err-dens-lgas-liquid = p-sr-abs-err-dens-lgas-liquid 
    AND buf_sr-izmerenia.sr-relative-err-dens-lgas-liquid = p-sr-relative-err-dens-lgas-liquid 
    AND buf_sr-izmerenia.sr-abs-err-dens-lgas-vapor       = p-sr-abs-err-dens-lgas-vapor  
    AND buf_sr-izmerenia.node-code                       <> p-node-code
  ) then do:
    undo, throw new Progress.Lang.AppError(
      substitute("&1 &2 &3&4Уже существует запись с совпадающими характеристиками, код которой отличается от [&5]",
                 vss-workfile, vss-revision, vss-description, {&new-line},
                 p-node-code) 
    ) .
  end .

  
  find first buf_sr-izmerenia exclusive-lock
       where buf_sr-izmerenia.node-code = p-node-code no-error no-wait .
  if locked(buf_sr-izmerenia) then do:
    undo, throw new Progress.Lang.AppError(
      substitute("&1 &2 &3&4Запись о средстве измерения с ид. [&5] занята другим пользователем",
                 vss-workfile, vss-revision, vss-description, {&new-line}, 
                 p-node-code )
      ) .
  end . 
  
  if available buf_sr-izmerenia then do:
  end .
  else do :
    create buf_sr-izmerenia .
    assign
      buf_sr-izmerenia.node-code = p-node-code
    .
  end .
  assign
    buf_sr-izmerenia.sr-model                    = p-sr-model
    buf_sr-izmerenia.sr-level                    = (p-sr-level > 0)
    buf_sr-izmerenia.sr-temperature              = (p-sr-temperature > 0)
    buf_sr-izmerenia.sr-density                  = (p-sr-density > 0)
    buf_sr-izmerenia.sr-Weight                   = (p-sr-Weight > 0)
    buf_sr-izmerenia.sr-type-id                  = p-sr-type-id
    buf_sr-izmerenia.sr-abs-err-neft-water       = p-sr-abs-err-neft-water
    buf_sr-izmerenia.sr-abs-err-water            = p-sr-abs-err-water
    buf_sr-izmerenia.sr-abs-err-dens             = p-sr-abs-err-dens
    buf_sr-izmerenia.sr-abs-err-temp-vol         = p-sr-abs-err-temp-vol
    buf_sr-izmerenia.sr-abs-err-temp-dens        = p-sr-abs-err-temp-dens
    buf_sr-izmerenia.sr-otnos                    = p-sr-otnos
    buf_sr-izmerenia.sr-temp-line                = p-sr-temp-line
    buf_sr-izmerenia.sr-type-izm                 = p-sr-type-izm                 
    buf_sr-izmerenia.sr-type-level-measuring     = p-sr-type-level-measuring     
    buf_sr-izmerenia.sr-relative-err-neft-water  = p-sr-relative-err-neft-water  
    buf_sr-izmerenia.sr-relative-err-water       = p-sr-relative-err-water       
    buf_sr-izmerenia.sr-relative-err-dens        = p-sr-relative-err-dens        
    buf_sr-izmerenia.sr-abs-err-dens-lgas-liquid = p-sr-abs-err-dens-lgas-liquid 
    buf_sr-izmerenia.sr-relative-err-dens-lgas-liquid = p-sr-relative-err-dens-lgas-liquid 
    buf_sr-izmerenia.sr-abs-err-dens-lgas-vapor  = p-sr-abs-err-dens-lgas-vapor  
    buf_sr-izmerenia.sr-not-used                 = (p-sr-not-used > 0)
  .
  validate buf_sr-izmerenia .
