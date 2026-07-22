&scoped-define impclass measuring
/*

$Revision: c93c7157b47d, 2925, rls $
$Author: VRukavishnikov $
$Date: Пн ноя 22 19:49:14 2021 +0300 $
$Workfile: impmeasuring.cls $
$Archive: ibs/th/bge/1crn/import/impmeasuring.cls $

Класс ипорта данных {&impclass} из 1С

Автор: Молотков Сергей
Дата создания: 04/12/17
Author: Molotkov Sergey
Creation date: 04/12/17

*/

using Progress.Lang.*.
/*using ibs.th.gbl.gbl-var.*/
using ibs.th.bge.1crn.enum-deg-auto.
using ibs.th.bge.1crn.enum-dnst-ms-type.
using ibs.th.bge.1crn.enum-level-ms-type.
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
    define variable objImp       as class {&impclass} no-undo.
    define variable v-retfl      as logical no-undo .

    define variable v-ms-code    as integer no-undo .   /* like ub.sr-izmerenia.node-code */
    define buffer buf_sr-izmerenia for ub.sr-izmerenia .

        
    objImp = cast (subjectObj, {&impclass}).
  
    assign
      v-ms-code = integer(objImp:code_)
    .
    if v-ms-code > 0 then . else undo, throw new Progress.Lang.AppError("Не задан код средства измерения") .
    
    /* По справочникам ...,  ... при логическом удалении записей на стороне ТН никаких действий не производится,
       а при передаче из 1С к названию добавляется фраза «УДАЛЕНО» (или аналог).
       05/XII-2017 Средства измерения тоже добавили к этому перечню.
    */
    if objImp:del-f > 0 then do:
      run ref/sr-izm03.p ( input v-ms-code ) .
    end .
    else do:
      run ref/sr-izm01.p
      (input v-ms-code                             /* p-node-code (int) */
      ,input mapDegAuto (objImp:deg-auto)          /* p-sr-type-izm (int) */
      ,input objImp:name_                          /* p-sr-model (chr) */
      ,input objImp:dimension-level                /* p-sr-level (int) */
      ,input objImp:dimension-temp                 /* p-sr-temperature (int) */
      ,input objImp:dimension-dnst                 /* p-sr-density (int) */
      ,input objImp:dimension-wght                 /* p-sr-Weight (int) */
      ,input mapLevelMsType (objImp:level-ms-type) /* p-sr-type-level-measuring (int) */
      ,input mapDnstMsType (objImp:dnst-ms-type)   /* p-sr-type-id (int) */
      ,input objImp:level-abs-me                   /* p-sr-abs-err-neft-water (dec) */
      ,input objImp:level-rel-me-np                /* p-sr-relative-err-neft-water (dec) */
      ,input objImp:level-abs-me-wtr               /* p-sr-abs-err-water (dec) */
      ,input objImp:level-rel-me-wtr               /* p-sr-relative-err-water (dec) */
      ,input objImp:dnst-abs-me-np                 /* p-sr-abs-err-dens (dec) */
      ,input objImp:temp-abs-me-vlm                /* p-sr-abs-err-temp-vol (dec) */
      ,input objImp:temp-abs-me-dnst               /* p-sr-abs-err-temp-dens (dec) */
      ,input objImp:dnst-rel-me-np                 /* p-sr-relative-err-dens (dec) */
      ,input objImp:dnst-abs-me-lpg-l              /* p-sr-abs-err-dens-lgas-liquid (dec) */
      ,input objImp:dnst-rel-me-lpg-l              /* p-sr-relative-err-dens-lgas-liquid (dec) */
      ,input objImp:dnst-abs-me-lpg-v              /* p-sr-abs-err-dens-lgas-vapor (dec) */
      ,input objImp:wght-rel-me                    /* p-sr-otnos (dec) */
      ,input objImp:level-tk                       /* p-sr-temp-line (dec) */
      ,input objImp:del-l                          /* p-sr-temp-line (int) */
      ) .
      
    end .
    assign
      Msg = "":U
      v-retfl = true
    .
    
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
      return v-retfl.
    end finally .
  end method. /* end_of Excute */


  /* mapping:
     коды в enum - согласно протоколу взаимодействия с 1С;
  */
  /* маппинг кодов типов средств измерения */
  method private integer mapDnstMsType (p-ms-type as enum-dnst-ms-type) :
    define variable v-ms-type as integer no-undo .
    case p-ms-type :
      when enum-dnst-ms-type:enare15     then v-ms-type = 1 . 
      when enum-dnst-ms-type:enare20     then v-ms-type = 2 . 
      when enum-dnst-ms-type:endensflow  then v-ms-type = 3 . 
      when enum-dnst-ms-type:endenssubm  then v-ms-type = 4 . 
      when enum-dnst-ms-type:enchannelfl then v-ms-type = 5 . 
      when enum-dnst-ms-type:enchannelno then v-ms-type = 6 . 
      otherwise v-ms-type = 1 .
    end case .
    return v-ms-type .
  end method .
  
  method private integer mapDegAuto (p-deg-auto as enum-deg-auto) :
    define variable v-deg-auto as integer no-undo .
    case p-deg-auto :
      when enum-deg-auto:enautoms         then v-deg-auto = 0 . 
      when enum-deg-auto:ennonautomatedms then v-deg-auto = 1 . 
      when enum-deg-auto:enmssys          then v-deg-auto = 2 . 
      otherwise v-deg-auto = 0 .
    end case .
    return v-deg-auto .
  end method .

  method private integer mapLevelMsType (p-level-ms-type as enum-level-ms-type) :
    define variable v-level-ms-type as integer no-undo .
    case p-level-ms-type :
      when enum-level-ms-type:enstatic            then v-level-ms-type = 0 . 
      when enum-level-ms-type:enroulette2class    then v-level-ms-type = 1 . 
      when enum-level-ms-type:endensitylevelmeter then v-level-ms-type = 2 . 
      otherwise v-level-ms-type = 0 .
    end case .
    return v-level-ms-type .
  end method .

  /* end_of mapping */

end class.