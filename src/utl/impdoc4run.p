/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Загружает партии свободной зоны и создаёт по ним приходные накладные

Автор: Молотков Сергей
Дата создания: 18/04/18
Author: Molotkov Sergey
Creation date: 18/04/18
*/
block-level on error undo, throw.

define input  parameter parparentproc as handle no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Загружает партии свободной зоны и создаёт по ним приходные накладные".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i } // &delim-par

define variable v-imp-dialog  as class ibs.th.str.impdoc4dlg .
define variable v-code-system as integer no-undo .
define variable v-obj-type    as character no-undo .
define variable v-obj-code    as integer no-undo .
define variable v-file-name   as character no-undo .
define variable v-is-close    as logical no-undo .

  v-imp-dialog = new ibs.th.str.impdoc4dlg () .
  v-imp-dialog:setParentproc(parparentproc) .
  v-imp-dialog:ShowModalDialog().
  if v-imp-dialog:DialogResult = System.Windows.Forms.DialogResult:Ok then do:
    assign
      v-file-name   = v-imp-dialog:fi-file-name
      v-obj-type    = v-imp-dialog:fi-obj-type
      v-obj-code    = v-imp-dialog:fi-obj-code
      v-is-close    = v-imp-dialog:is-doc-close
    .
    /*
    /* Проверим каталог */
    file-info:file-name = v-file-name .
    log-file-name = v-directory + "nakl-imp.log" .
    */
  run str/diallog.w ( parparentproc
              , this-procedure
              , 'utl/imp-doc4.p':U
              , substitute( "&2&1&3&1&4&1&5"
                          , {&delim-par}
                          , v-file-name
                          , v-obj-code, v-obj-type
                          , v-is-close )
              , no /*p-auto-go*/
              , '':U
              , 'Импорт накладных из 15.0') no-error .
    
    /*
    run waitfram-show in this-procedure ("Импорт накладных. Ждите...").
...run ...
  run waitfram-hide in this-procedure .   
    */
  message "Импорт партий завершен" view-as alert-box .         
  end .

define variable Msg as character no-undo .
    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg > "" then . else do :
        Msg = exAppErrors:GetMessage(1) .
        if Msg > "" then . else Msg = "AppError в импорте партий" .
      end .
      message "Ошибка импорта" skip Msg view-as alert-box .         
//      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      Msg = exProErrors:GetMessage(1) . 
      if Msg > "" then . else Msg = "ProError в импорте партий" .
      message "Ошибка импорта" skip Msg view-as alert-box .         
//      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error в импорте партий" .
      message "Ошибка импорта" skip Msg view-as alert-box .         
//      undo, throw exAnyErrors .
    end catch .
    finally :
      if valid-object(v-imp-dialog) then delete object v-imp-dialog .
    end finally .
