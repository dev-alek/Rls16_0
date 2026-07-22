
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Структура данных OsnovCorr в 1С

Автор: Александр Морозов
Дата создания: 26/09/17
Author: Morozov Alexandr
Creation date: 26/09/17

*/

using Progress.Lang.*.
block-level on error undo, throw.


class ibs.th.bge.1crn.subjects.osnovcorr inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  
  define property code_       as integer    no-undo get. 
    private set.
  define property del-l       as integer      no-undo get. 
    private set.
  define property del-f       as integer      no-undo get. 
    private set.
  define property osn_name    as character    no-undo get. 
    private set.
/*  define property full-name  as character    no-undo get.*/
/*    private set.                                         */

  define override property InitTag as character no-undo init "osnovcorr"
    get. 
    
  method OVERRIDE PROTECTED void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "code" then 
        do:
          assign 
            code_ = integer(inValue) .
        end.
      when "del-l" then 
        do:
          assign 
            del-l = integer (inValue).
        end.
      when "del-f" then 
        do:
          assign 
            del-f = integer (inValue).
        end.
      when "osn_name" then 
        do:
          assign 
            osn_name = inValue .
        end.
/*      when "full-name" then      */
/*        do:                      */
/*          assign                 */
/*            full-name = inValue .*/
/*        end.                     */
    end case.
  end.

  method override protected void CheckData ():

    def var v-str as char no-undo.
    
    assign
      v-str = "code" 
      when code_ = ?
      v-str = v-str + ",osn_name" 
      when osn_name = ?
/*      v-str = v-str + ",full-name"*/
/*      when full-name = ?          */
      .
    v-str = trim (v-str, ",").
    if v-str > ''
      then 
      undo, throw new Progress.Lang.AppError( substitute ("Теги &1 не могут иметь неопределное значение", v-str)).

  end.

  method override protected void ClearSub():
    assign 
      code_     = ?
      del-l     = ?
      del-f     = ?
      osn_name  = ?
/*      full-name = ?*/
      .
  end.
  
end class.