block-level on error undo, throw.
define input parameter h_focus-widget      as handle    no-undo .
define input parameter h_current-procedure as handle    no-undo .
define input parameter p-action            as character no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: infrmact.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/infrmact.p $":U .
def var vss-description as character no-undo init "Программа обработки событий в информационном диалоге".
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
define variable v-proc-name as character no-undo .
do
on error undo, return error return-value
:
  case entry(1, p-action) :
    when "":u then do:
    end.
    when "run":U then do:
      if num-entries(p-action) = 2
      then do:
        assign
          v-proc-name = entry(2, p-action)
        .
        if lookup(h_current-procedure :file-name
                  ,'gbl/mainmenu.w'
                  ) > 0 then do:
          run value(v-proc-name) .
        end.
        else do:
          message
            "Программа может быть запущена только из главного окна модуля." skip
            "Вы пытаетесь запустить его из программы" h_current-procedure :file-name skip
            "Закройте все окна и поробуйте еще раз" skip
            view-as alert-box information .
        end.
      end.
      else do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное событие" skip
          "p-action" p-action skip
          view-as alert-box error .
      end.
    end.
    when "runpersistent":u then do:
      if num-entries(p-action) = 2
      then do:
        assign
          v-proc-name = entry(2, p-action)
        .
        if lookup(h_current-procedure :file-name
                  ,'gbl/mainmenu.w'
                  ) > 0 then do:
          run value(v-proc-name) persistent.
        end.
        else do:
          message
            "Программа может быть запущена только из главного окна модуля." skip
            "Вы пытаетесь запустить его из программы" h_current-procedure :file-name skip
            "Закройте все окна и поробуйте еще раз" skip
            view-as alert-box information .
        end.
      end.
      else do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное событие" skip
          "p-action" p-action skip
          view-as alert-box error .
      end.
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестное событие" skip
        "p-action" p-action skip
        view-as alert-box error .
    end.
  end.
end.
