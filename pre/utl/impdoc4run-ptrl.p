block-level on error undo, throw.
define input  parameter parparentproc as handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Загружает партии свободной зоны и создаёт по ним приходные накладные".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
  // &delim-par
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
  run str/diallog.w ( parparentproc
              , this-procedure
              , 'utl/imp-doc4-ptrl.p':U
              , substitute( "&2&1&3&1&4&1&5"
                          , chr(4)
                          , v-file-name
                          , v-obj-code, v-obj-type
                          , v-is-close )
              , no
              , '':U
              , 'Импорт топливных накладных из 15.0') no-error .
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
