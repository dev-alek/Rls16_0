&scoped-define impclass recipe
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Класс ипорта данных {&impclass} из 1С

Автор: Молотков Сергей
Дата создания: 25/10/17
Author: Molotkov Sergey
Creation date: 25/10/17

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.enum-recipe-status.
using ibs.th.bge.1crn.enum-recipe-type.
using ibs.th.bge.1crn.subjects.*.

block-level on error undo, throw.

class ibs.th.bge.1crn.import.imp{&impclass} implements ibs.th.bge.1crn.import.iimpsubject: 
  
  { cmp/str-glbl.i class }
  
  
  define property Msg as character no-undo
    get. 
    set.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable v-mode       as character no-undo . /* create/update */
    define variable objImp       as class {&impclass} no-undo.
    define variable v-gds-list   as class ibs.th.bge.1crn.subjects.subjects no-undo . // imp:recipe-gds[]
    define variable v-recipe-gd  as class recipe-gd no-undo .
    define variable v-retfl      as logical no-undo .
    define variable v-db-num     as integer no-undo .
    
    define variable v-recipe-code as character no-undo . /* like ub.recipe.recipe-code */
    define variable v-recipe-name as character no-undo . /* like up.recipe.recipe-name */
    define variable v-gds-code    as integer no-undo .   /* like ub.goods.gds-code */
    define variable v-stts        as integer no-undo init 0 .
    
    define buffer buf_recipe     for ub.recipe .
    define buffer buf_recipe-gds for ub.recipe-gds .
    define buffer buf_fbr-line   for ub.fbr-line .
    define buffer buf_fbr-doc    for ub.fbr-doc .
    define buffer buf_fbr-gds-obj for ub.fbr-gds-obj .
    
    
    objImp = cast (subjectObj, {&impclass}).
    
    assign
      v-recipe-code = objImp:recipe-code
      v-recipe-name = objImp:recipe-name
      v-gds-code    = integer(objImp:gd-code)
      Msg           = "":U
    .
    if v-recipe-code > "" then . else undo, throw new Progress.Lang.AppError("Не задан ид. рецепта") .
    
    if objImp:del-f > 0 then do:
      find first buf_fbr-line no-lock
           where buf_fbr-line.recipe-code = v-recipe-code no-error.
      if available buf_fbr-line then do:
        find first buf_fbr-doc no-lock
             where buf_fbr-doc.doc-code = buf_fbr-line.doc-code no-error.
        if available buf_fbr-doc then
          Msg = substitute( "Удаление рецепта [&1] невозможно: рецепт используется в производственных операциях." +
                            " Документ: &2 &3 от &4",
                            v-recipe-code, ub.fbr-doc.doc-type, ub.fbr-doc.doc-code, ub.fbr-doc.doc-date ) .
        else Msg = substitute( "Удаление рецепта [&1] невозможно: рецепт используется в производственных операциях." +
                               " Документ: [&2]",
                            v-recipe-code, buf_fbr-line.doc-code ) .
        v-retfl = false .
        return false. /* уходит в finally, где перевозвращает v-retfl вместо false */
      end .
      Msg = "физическое удаление рецептов не предусмотрено".
      v-retfl = false .
      return false. /* уходит в finally, где перевозвращает v-retfl вместо false */
/* физическое удаление рецептов:
  if not available ub.fbr-line then "Удаление выбранного рецепта не повлияет на сформированные по этому рецепту документы,"
  find first b-recipe exclusive-lock where recid( b-recipe ) = recid( ub.recipe )    .
  delete b-recipe .
  run fbrlib-set-default-recipe in this-procedure (
                      input p-store-type
                    , input p-store-code
                    , input ub.goods.gds-code
  ).
*/      
    end.
    /* По справочникам ..., Рецепты, ... при логическом удалении записей на стороне ТН никаких действий не производится,
       а при передаче из 1С к названию добавляется фраза «УДАЛЕНО» (или аналог). */
    /* Если придет удалено, то 1С сам поставит слово Удалено. */
    /* ИТОГО ПО ЛОГИЧЕСКОМУ УДАЛЕНИЮ:
       т.к. 1С сам впишет "Удалено" или "Не удалено" - то мы на del-l никак не реагируем.
       У нас это "Удалено" пройдёт штатным обновлением записи.
    */


    find first buf_recipe no-lock where buf_recipe.recipe-code = v-recipe-code no-error .
    if available buf_recipe then do:
      if v-recipe-name > "" then . else v-recipe-name = buf_recipe.recipe-name .

      assign
        v-mode = {&update}
      .
    end . /* end_of update */
    else do:
      assign
        v-mode = {&add-def}
      .
    end . /* end_of create */

    /* 06/XII-2017 Если придет статус 2, то в начало названия добавляем ЗАКРЫТ.  Это закрытие рецепта в 1С. */    
    if objImp:status_ = enum-recipe-status:enclose
    then do :
      assign
        v-recipe-name = "ЗАКРЫТ." + v-recipe-name
        v-stts = 2  
      .
    end .
      
    /* ----- создание/обновление рецепта ----- */
    define variable proc-fbrlib   as class ibs.th.str.fbrlib no-undo .

    /* Создание и изменение рецепта */
    proc-fbrlib = new ibs.th.str.fbrlib () .
    proc-fbrlib:create-new-recipe
    (input v-mode            /* p-mode character {&add-def} или {&update} */
    /* все рецепты создаются глобальными,
       код рецепта в обязательном порядке формируется во внешней системе */
    ,input v-recipe-code                       /* p-recipe-code character код (id) рецепта */
    ,input mapRecipeTypes (objImp:recipe-type) /* p-recipe-type character тип рецепта */
    ,input v-recipe-name                       /* p-recipe-name character наименование рецепта */
    ,input objImp:recipe-num                   /* p-recipe-num  character Номер рецепта по справочнику рецептур */
    ,input v-gds-code        /* p-gds-code integer код товара производимого по рецепту */
    ,input objImp:qnty-netto /* p-qnty-netto decimal Количество нетто */
    ,input objImp:qnty       /* p-portion-qnty integer Количество порций */
    ,input objImp:weight     /* p-portion-weight Вес порции */
    ,input v-stts
    ) .
      
      /* делать рецепт установленным по умолчанию? */
    if objImp:main = 1  then do:        /* ri = recid( recipe ) */
        run gbl/getdbnum.p (output v-db-num).
        find first ub.clients no-lock where ub.clients.db-num = v-db-num
                                  and ub.clients.obj-type = {&shop}
                                  and ub.clients.stts = 0 .
        proc-fbrlib:fbrlib-set-default-recipe(
              input ub.clients.obj-type
            , input ub.clients.obj-code
            , input v-gds-code
        ).
        for each buf_fbr-gds-obj exclusive-lock
           where buf_fbr-gds-obj.obj-type = ub.clients.obj-type
             and buf_fbr-gds-obj.obj-code = ub.clients.obj-code
             and buf_fbr-gds-obj.gds-code = v-gds-code
        on error undo, return error
        :
            assign
                buf_fbr-gds-obj.default-recipe-code = v-recipe-code
            .
        end.        /* for each buf_recipe */
    end.
      
      
    /* Добавление/обновление товаров в рецепте: 
1. для режима добавления - просто добавить товар
2. для режима обновления:
  а) если товара не было - создать его
  б) если товар был - обновить его
  в) оставшиеся товары были, но теперь не пришли. Удалить их.         
    */
    define variable v-rgds  as character no-undo . /* список обработанных товаров рецепта */
    define variable v-ii    as integer no-undo .
    define variable v-rowid as rowid no-undo .
    
    /* Глобальный момент: у нас есть проверка наличия обязательных тегов в сущности,
                          но нет проверки наличия обязательных элементов в коллекции.
       Поэтому наш импорт принимает пустую секцию <recipe-gds /> при том, что он исправно проверяет
       как наличие этой секции внутри <recipe>, так и наличие <gd-code> внутри <recipe-gd>.
       Место для проверки наличия <recipe-gd> внутри <recipe-gds> в нашей архитектуре пока отсутствует.
    */
    assign
      v-gds-list = objImp:recipe-gds
      v-rgds     = ""      
    .
    if valid-object (v-gds-list) then do :
    do v-ii = 1 to v-gds-list:Get(v-ii):
      v-recipe-gd = cast (v-gds-list:SubjectObjCurr, recipe-gd) .
      v-gds-code = integer (v-recipe-gd:gd-code) .
      v-rowid = proc-fbrlib:create-new-recipe-gds
      (input v-recipe-code
      ,input v-gds-code
      ,input v-recipe-gd:qnty-net
      ,input v-recipe-gd:qnty-gross
      ,input v-recipe-gd:lf /* внутри для новой записи = 0, далее присваивается только если gd:lf определено (gd:lf <> ?) */
      ,input v-recipe-gd:gds-recipe-code /* внутри присваивается только если значение определено (gds-recipe-code <> ?) */
      ,input v-recipe-gd:wst
      ) .
      if (v-mode = {&update}) then v-rgds = v-rgds + "," + string(v-rowid) . 
    end . /* end_of do_in_gds-list */
    v-rgds = substring(v-rgds, 2) .
      
    if (v-mode = {&update}) and (v-rgds > "") then do:
      /* уничтожение лишних записей */
      for each buf_recipe-gds exclusive-lock
         where buf_recipe-gds.recipe-code = v-recipe-code
           and can-do (  v-rgds,  string(rowid(buf_recipe-gds))  ) = false:
        assign
          buf_recipe-gds.nws-self    = yes
        .
        delete buf_recipe-gds .
      end.
      
    end. /* end_of clear recipe-gds */
    end .
    else do :
      Msg = substitute(
        "Ошибка импорта рецепта [&1]: отсутствуют товары в рецепте - в секции &2 отсутствуют элементы &3",
        v-recipe-code, "recipe-gds", "recipe-gd" ) .
        v-retfl = false .
        return false. /* уходит в finally, где перевозвращает v-retfl вместо false */
    end . 

    v-retfl = true .
    /* ----- end_of создание/обновление рецепта ----- */


    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg = "" then Msg = exAppErrors:GetMessage(1) .
      v-retfl = false.
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      Msg = exProErrors:GetMessage(1) .
      v-retfl = false.
      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error occurred..." .
      v-retfl = false.
      undo, throw exAnyErrors .
    end catch .
    finally :
      if valid-object(proc-fbrlib) then delete object proc-fbrlib .
      return v-retfl.
    end finally .
  end method. /* end_of Excute */


  /* mapping:
     коды в enum - согласно протоколу взаимодействия с 1С;
  */
  /* маппинг типов рецептов наших на 1с */
  method private character mapRecipeTypes (p-recipe-type as enum-recipe-type) :
    define variable v-th-recipe-type as character no-undo .
    case p-recipe-type :
      when enum-recipe-type:enmanufacturing then v-th-recipe-type = {&manufacturing} .
      when enum-recipe-type:engathering     then v-th-recipe-type = {&gathering} . 
      when enum-recipe-type:enalternative   then v-th-recipe-type = {&alternative} . 
      otherwise v-th-recipe-type = "":U .
    end case .
    return v-th-recipe-type .
  end method .  /* end_of mapping */


end class.