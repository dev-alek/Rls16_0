using Progress.Lang.*.
using ibs.th.bge.1crn.enum-recipe-status.
using ibs.th.bge.1crn.enum-recipe-type.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.imprecipe implements ibs.th.bge.1crn.import.iimpsubject:
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable v-mode       as character no-undo .
    define variable objImp       as class recipe no-undo.
    define variable v-gds-list   as class ibs.th.bge.1crn.subjects.subjects no-undo . // imp:recipe-gds[]
    define variable v-recipe-gd  as class recipe-gd no-undo .
    define variable v-retfl      as logical no-undo .
    define variable v-db-num     as integer no-undo .
    define variable v-recipe-code as character no-undo .
    define variable v-recipe-name as character no-undo .
    define variable v-gds-code    as integer no-undo .
    define variable v-stts        as integer no-undo init 0 .
    define buffer buf_recipe     for ub.recipe .
    define buffer buf_recipe-gds for ub.recipe-gds .
    define buffer buf_fbr-line   for ub.fbr-line .
    define buffer buf_fbr-doc    for ub.fbr-doc .
    define buffer buf_fbr-gds-obj for ub.fbr-gds-obj .
    objImp = cast (subjectObj, recipe).
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
        return false.
      end .
      Msg = "физическое удаление рецептов не предусмотрено".
      v-retfl = false .
      return false.
    end.
    find first buf_recipe no-lock where buf_recipe.recipe-code = v-recipe-code no-error .
    if available buf_recipe then do:
      if v-recipe-name > "" then . else v-recipe-name = buf_recipe.recipe-name .
      assign
        v-mode = 'ИЗМЕНЕНИЕ':U
      .
    end .
    else do:
      assign
        v-mode = 'ДОБАВЛЕНИЕ':U
      .
    end .
    if objImp:status_ = enum-recipe-status:enclose
    then do :
      assign
        v-recipe-name = "ЗАКРЫТ." + v-recipe-name
        v-stts = 2
      .
    end .
    define variable proc-fbrlib   as class ibs.th.str.fbrlib no-undo .
    proc-fbrlib = new ibs.th.str.fbrlib () .
    proc-fbrlib:create-new-recipe
    (input v-mode
    ,input v-recipe-code
    ,input mapRecipeTypes (objImp:recipe-type)
    ,input v-recipe-name
    ,input objImp:recipe-num
    ,input v-gds-code
    ,input objImp:qnty-netto
    ,input objImp:qnty
    ,input objImp:weight
    ,input v-stts
    ) .
    if objImp:main = 1  then do:
        run gbl/getdbnum.p (output v-db-num).
        find first ub.clients no-lock where ub.clients.db-num = v-db-num
                                  and ub.clients.obj-type = 'маг':U
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
        end.
    end.
    define variable v-rgds  as character no-undo .
    define variable v-ii    as integer no-undo .
    define variable v-rowid as rowid no-undo .
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
      ,input v-recipe-gd:lf
      ,input v-recipe-gd:gds-recipe-code
      ,input v-recipe-gd:wst
      ) .
      if (v-mode = 'ИЗМЕНЕНИЕ':U) then v-rgds = v-rgds + "," + string(v-rowid) .
    end .
    v-rgds = substring(v-rgds, 2) .
    if (v-mode = 'ИЗМЕНЕНИЕ':U) and (v-rgds > "") then do:
      for each buf_recipe-gds exclusive-lock
         where buf_recipe-gds.recipe-code = v-recipe-code
           and can-do (  v-rgds,  string(rowid(buf_recipe-gds))  ) = false:
        assign
          buf_recipe-gds.nws-self    = yes
        .
        delete buf_recipe-gds .
      end.
    end.
    end .
    else do :
      Msg = substitute(
        "Ошибка импорта рецепта [&1]: отсутствуют товары в рецепте - в секции &2 отсутствуют элементы &3",
        v-recipe-code, "recipe-gds", "recipe-gd" ) .
        v-retfl = false .
        return false.
    end .
    v-retfl = true .
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
  end method.
  method private character mapRecipeTypes (p-recipe-type as enum-recipe-type) :
    define variable v-th-recipe-type as character no-undo .
    case p-recipe-type :
      when enum-recipe-type:enmanufacturing then v-th-recipe-type = 'производство':U .
      when enum-recipe-type:engathering     then v-th-recipe-type = 'комплектация':U .
      when enum-recipe-type:enalternative   then v-th-recipe-type = 'альтернатива':U .
      otherwise v-th-recipe-type = "":U .
    end case .
    return v-th-recipe-type .
  end method .
end class.
