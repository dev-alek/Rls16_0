define input parameter parparentproc as widget-handle no-undo .
define input  parameter parobj-type like ub.clients.obj-type no-undo.
define input  parameter parobj-code like ub.clients.obj-code no-undo.
define output parameter parrec-id as recid initial ? no-undo.
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Диалог на добавление связки резервуар-ТРК".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function nzpl-spl returns logical
(input p-obj-type as character
                                , input p-obj-code as integer):
define variable v-dopi    as integer no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .
define variable v-tth as handle no-undo .
define variable dflt-cd as character no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type1 as character no-undo .
define variable v-value-date1 as date no-undo .
define variable v-value-decimal1 as decimal no-undo .
define variable v-value-integer1 as INTEGER no-undo .
define variable v-value-logical1 AS LOGICAL no-undo .
define variable v-tth1 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date1
    ,output v-value-decimal1
    ,output v-value-integer1
    ,output v-value-logical1
    ,output v-param-type1
    ,INPUT-OUTPUT table-handle v-tth1
    ) no-error .
delete object v-tth1 no-error.
if dflt-cd <> 'IBM':U
and dflt-cd <> 'IBM-XML':U then return no.
if dflt-cd = 'IBM-XML':U then return yes.
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-type-ibm':U
    ,input  'ibmspool':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
if error-status:error then do:
  delete object v-tth.
  return no.
end.
delete object v-tth.
assign
v-dopi = v-value-integer no-error .
if v-dopi >= 6 then return yes.
end. // FUNCTION/method
FUNCTION nzpl-two returns logical
                                 (input p-obj-type as character
                                  , input p-obj-code as integer):
  define variable v-nzpl-two as logical no-undo.
  run
  nzpl-two-proc (input p-obj-type, input p-obj-code, output v-nzpl-two).
  return v-nzpl-two.
end. // FUNCTION/method
procedure nzpl-two-proc :
define input  parameter p-obj-type   as character no-undo.
define input  parameter p-obj-code   as integer   no-undo.
define output parameter varge-two-pl as logical   no-undo.
define buffer bf_pl-gds-pump       for ub.pl-gds-pump.
define buffer bf-other_pl-gds-pump for ub.pl-gds-pump.
//do on error undo, return error return-value :
assign
  varge-two-pl = no.
for each bf_pl-gds-pump where bf_pl-gds-pump.obj-type = p-obj-type        and
                              bf_pl-gds-pump.obj-code = p-obj-code        and
                              bf_pl-gds-pump.status_  = 'тек':U no-lock on error undo, return error return-value :
  find first bf-other_pl-gds-pump where bf-other_pl-gds-pump.obj-type  =  bf_pl-gds-pump.obj-type  and
                                        bf-other_pl-gds-pump.obj-code  =  bf_pl-gds-pump.obj-code  and
                                        bf-other_pl-gds-pump.pump-code =  bf_pl-gds-pump.pump-code and
                                        bf-other_pl-gds-pump.gds-code  =  bf_pl-gds-pump.gds-code  and
                                        bf-other_pl-gds-pump.status_   =  'тек':U        and
                                        bf-other_pl-gds-pump.pl-code   <> bf_pl-gds-pump.pl-code   no-lock no-error.
  if available bf-other_pl-gds-pump then do:
    assign
      varge-two-pl = yes.
    leave.
  end.
end.
//end.
end. // procedure/method .
procedure cplgdspm :
  define input parameter parobj-type  like ub.pl-gds-pump.obj-type  no-undo.
  define input parameter parobj-code  like ub.pl-gds-pump.obj-code  no-undo.
  define input parameter parpl-code   like ub.pl-gds-pump.pl-code   no-undo.
  define input parameter pargds-code  like ub.pl-gds-pump.gds-code  no-undo.
  define input parameter parpump-code like ub.pl-gds-pump.pump-code no-undo.
  define input parameter parstatus    like ub.pl-gds-pump.status_   no-undo.
    define buffer bf_pl-gds-pump          for ub.pl-gds-pump.
    define buffer bf_pl-pump-nozzle       for ub.pl-pump-nozzle.
    define buffer bf-other_pl-pump-nozzle for ub.pl-pump-nozzle.
    define buffer bf-place                for ub.place.
    if parstatus = 'тек':U then do:
      for each bf_pl-gds-pump no-lock
        where bf_pl-gds-pump.obj-type  =  parobj-type
          and bf_pl-gds-pump.obj-code  =  parobj-code
          and bf_pl-gds-pump.gds-code  =  pargds-code
          and bf_pl-gds-pump.pump-code =  parpump-code
          and bf_pl-gds-pump.pl-code   <> parpl-code
          and bf_pl-gds-pump.status_   =  'тек':U
      on error undo, return error
      :
        find first place where
                   place.obj-type = parobj-type
               and place.obj-code = parobj-code
               and place.pl-code  = parpl-code
             no-lock no-error.
        find first bf-place where
                   bf-place.obj-type = parobj-type
               and bf-place.obj-code = parobj-code
               and bf-place.pl-code = bf_pl-gds-pump.pl-code
             no-lock no-error.
        if nzpl-spl(parobj-type, parobj-code) <> yes then do:
          return error substitute( "Попытка создать запись на объекте &1 &2 резервуар &3 товар с внутренним кодом &4 ТРК &5 статус &6.&7"
                                     ,parobj-type
                                     ,parobj-code
                                     ,if available place then place.loc1 else string(parpl-code)
                                     ,pargds-code
                                     ,parpump-code
                                     ,parstatus
                                     ,chr(10)
                                    )
                      + substitute( "КАССА не возвращает номер пистолета в чеке, а на объекте уже есть резервуар &1 с тем же товаром и связан он с этой же ТРК."
                                    ,if available bf-place then bf-place.loc1 else string(bf_pl-gds-pump.pl-code)
                                  ).
        end.
        else do:
          find first bf_pl-pump-nozzle no-lock
            where bf_pl-pump-nozzle.obj-type  = parobj-type
              and bf_pl-pump-nozzle.obj-code  = parobj-code
              and bf_pl-pump-nozzle.pump-code = parpump-code
              and bf_pl-pump-nozzle.pl-code   = parpl-code
            no-error.
          if available bf_pl-pump-nozzle then do:
            find first bf-other_pl-pump-nozzle no-lock
              where bf-other_pl-pump-nozzle.obj-type  = bf_pl-gds-pump.obj-type
                and bf-other_pl-pump-nozzle.obj-code  = bf_pl-gds-pump.obj-code
                and bf-other_pl-pump-nozzle.pump-code = bf_pl-gds-pump.pump-code
                and bf-other_pl-pump-nozzle.pl-code   = bf_pl-gds-pump.pl-code
              no-error.
            if available bf-other_pl-pump-nozzle
              and bf-other_pl-pump-nozzle.nozzle-code = bf_pl-pump-nozzle.nozzle-code
            then do:
              return error substitute( "Попытка создать запись на объекте &1 &2 резервуар &3 товар с внутренним кодом &4 ТРК &5 статус &6.&7"
                                       ,parobj-type
                                       ,parobj-code
                                       ,if available place then place.loc1 else string(parpl-code)
                                       ,pargds-code
                                       ,parpump-code
                                       ,parstatus
                                       ,chr(10)
                                     )
                          + substitute( "На объекте &1 &2 уже есть запись резервуар &3 в статусе &4, в котором находится этот же товар и он связан с этой же ТРК через этот же пистолет."
                                        ,bf_pl-gds-pump.obj-type
                                        ,bf_pl-gds-pump.obj-code
                                        ,if available bf-place then bf-place.loc1 else string(bf_pl-gds-pump.pl-code)
                                        ,bf_pl-gds-pump.status_
                                      ).
            end.
          end.
        end.
      end.
    end.
end . // procedure/method
define variable varmes-log as logical no-undo.
define variable varobj-type like ub.clients.obj-type no-undo.
define variable varobj-code like ub.clients.obj-code no-undo.
define variable varbuttons  as   character        no-undo.
define variable varps-upd   as   logical          no-undo.
procedure plpumpav:
  define input parameter parobj-type  like ub.clients.obj-type no-undo.
  define input parameter parobj-code  like ub.clients.obj-code no-undo.
  define input parameter parpl-code   like ub.place.pl-code    no-undo.
  define input parameter parpump-code like ub.pump.pump-code   no-undo.
  define buffer bf_clients           for ub.clients.
  define buffer bf_pump              for ub.pump.
  define buffer bf_place             for ub.place.
  define buffer bf_pl-pump           for ub.pl-pump.
  define buffer bf_pl-gds            for ub.pl-gds.
  define buffer bf_goods             for ub.goods.
  define buffer bf_pl-gds-pump       for ub.pl-gds-pump.
  define buffer bf-other_pl-gds-pump for ub.pl-gds-pump.
  define variable varstatus as character no-undo.
find first bf_clients where bf_clients.obj-type = parobj-type and
                            bf_clients.obj-code = parobj-code no-lock no-error.
if not available bf_clients then
   return error SUBSTITUTE("Нет такого объекта &1 &2 .", parobj-type, parobj-code).
find first bf_pump where bf_pump.obj-type  = parobj-type  and
                         bf_pump.obj-code  = parobj-code  and
                         bf_pump.pump-code = parpump-code no-lock no-error.
if not available bf_pump then
   return error SUBSTITUTE("Нет ТРК с номером &1", parpump-code) + SUBSTITUTE(" на объекте &1 &2 .", parobj-type, parobj-code).
find first bf_place where bf_place.obj-type = parobj-type and
                          bf_place.obj-code = parobj-code and
                          bf_place.pl-code  = parpl-code  no-lock no-error.
if not available bf_place then return error SUBSTITUTE("Нет такого складского места &1", parpl-code) + SUBSTITUTE(" на объекте &1 &2 .", parobj-type, parobj-code).
  find first bf_pl-pump no-lock
    where bf_pl-pump.obj-type   = parobj-type
      and bf_pl-pump.obj-code   = parobj-code
      and bf_pl-pump.pl-code    = parpl-code
      and bf_pl-pump.pump-code  = parpump-code
    no-error.
  if available bf_pl-pump then do:
    return error SUBSTITUTE("Уже есть запись резервуар-ТРК с номером резервуара &1 и номером ТРК &2", parpl-code, parpump-code) + SUBSTITUTE(" на объекте &1 &2 .", parobj-type, parobj-code).
  end.
  find first bf_pl-gds no-lock
    where bf_pl-gds.obj-type = parobj-type
      and bf_pl-gds.obj-code = parobj-code
      and bf_pl-gds.pl-code  = parpl-code
    no-error.
  tr:
  do transaction
  on error undo tr, return error return-value
  :
    if available bf_pl-gds then do:
      find first bf_goods no-lock
        where bf_goods.gds-code = bf_pl-gds.gds-code
      .
      assign
        varstatus = 'тек':U
      .
      find first bf-other_pl-gds-pump no-lock
        where bf-other_pl-gds-pump.obj-type  = parobj-type
          and bf-other_pl-gds-pump.obj-code  = parobj-code
          and bf-other_pl-gds-pump.gds-code  = bf_goods.gds-code
          and bf-other_pl-gds-pump.pump-code = parpump-code
          and bf-other_pl-gds-pump.status_   = 'тек':U
        no-error.
      if available bf-other_pl-gds-pump
        and nzpl-spl(bf-other_pl-gds-pump.obj-type, bf-other_pl-gds-pump.obj-code) <> yes
      then do:
        message
          "Через ТРК с номером " parpump-code " уже продается топливо " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name
          " которое связано с резервуаром " bf-other_pl-gds-pump.pl-code "." skip
          "Данная привязка Резервуар-ТРК-Товар получит статус блокированный."
          view-as alert-box information.
        assign
          varstatus = 'блок':U
        .
      end.
      create bf_pl-gds-pump.
      assign
        bf_pl-gds-pump.obj-type  = parobj-type
        bf_pl-gds-pump.obj-code  = parobj-code
        bf_pl-gds-pump.pl-code   = parpl-code
        bf_pl-gds-pump.gds-code  = bf_goods.gds-code
        bf_pl-gds-pump.pump-code = parpump-code
        bf_pl-gds-pump.status_   = varstatus
      .
      run cplgdspm in this-procedure
        ( input bf_pl-gds-pump.obj-type
         ,input bf_pl-gds-pump.obj-code
         ,input bf_pl-gds-pump.pl-code
         ,input bf_pl-gds-pump.gds-code
         ,input bf_pl-gds-pump.pump-code
         ,input bf_pl-gds-pump.status_
        ) no-error.
      if error-status:error then do:
        undo tr, return error substitute ("Ошибка при смене статуса записи резервуар-ТРК-пистолет: &1 &2.", return-value, error-status:get-message(1)).
      end.
    end.
    create bf_pl-pump.
    assign
      bf_pl-pump.obj-type   = parobj-type
      bf_pl-pump.obj-code   = parobj-code
      bf_pl-pump.pl-code    = parpl-code
      bf_pl-pump.pump-code  = parpump-code
    .
  end.
end procedure.
define new shared variable list-mode as character no-undo.
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-place
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON b-pump
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON b-save AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE varpl-code AS INTEGER FORMAT "99999999999":U INITIAL 0
     LABEL "Бар-код резервуара"
     VIEW-AS FILL-IN
     SIZE 10.38 BY 1 NO-UNDO.
DEFINE VARIABLE varpump-code AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "Номер ТРК"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     varpl-code AT ROW 2.54 COL 2.88
     b-place AT ROW 2.67 COL 34
     varpump-code AT ROW 3.92 COL 20.88 COLON-ALIGNED
     b-pump AT ROW 4 COL 34
     SPACE(1.74) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Добавление  резервуар-ТРК"
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-place IN FRAME Dialog-Frame
DO:
  define variable place-list as character no-undo.
  run ref/pl-list.w (
                 input parparentproc
                ,input "b-sel"
                ,input parobj-type
                ,input parobj-code
                ,input 'объект':U
                ,input-output place-list).
  if place-list = "cancel"
  then do :
    return no-apply .
  end .
  if place-list <> '':U then do:
     FIND FIRST ub.place No-LOCK WHERE recid(ub.place) = integer(entry(1, place-list)) NO-ERROR.
     if available ub.place then display ub.place.pl-code @ varpl-code with frame Dialog-Frame.
  end.
END.
ON CHOOSE OF b-pump IN FRAME Dialog-Frame
DO:
  define variable varrec-id_pump as recid initial ? no-undo.
  define buffer bf_pump for ub.pump.
  run str/pumprf.w
    ( input parparentproc
     ,input  parobj-type
     ,input  parobj-code
     ,output varrec-id_pump
    ).
  if varrec-id_pump <> ? then do:
     find first bf_pump where recid(bf_pump) = varrec-id_pump no-lock no-error.
     if available bf_pump then do:
        display bf_pump.pump-code @ varpump-code with frame Dialog-Frame.
     end.
  end.
END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
DO:
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  assign frame Dialog-Frame varpl-code varpump-code .
  run plpumpav in this-procedure
               (input parobj-type,
                input parobj-code,
                input varpl-code,
                input varpump-code) no-error.
  if error-status:error then do:
message
  vss-workfile vss-revision vss-description skip
  "Ошибка при создании записи резервуар-ТРК" skip
  "-----------Cистемная ошибка------------" skip
  return-value skip
  "------Ошибка исполнения программы------" skip
  trim(error-status :get-message(1)) +
  trim(error-status :get-message(2)) +
  trim(error-status :get-message(3)) +
  trim(error-status :get-message(4)) +
  trim(error-status :get-message(5)) skip
  view-as alert-box error .
     return no-apply.
  end.
  find first ub.pl-pump where ub.pl-pump.obj-type    = parobj-type  and
                           ub.pl-pump.obj-code    = parobj-code  and
                           ub.pl-pump.pl-code     = varpl-code   and
                           ub.pl-pump.pump-code   = varpump-code
                           no-lock.
  assign parrec-id = recid(ub.pl-pump).
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY varpl-code varpump-code
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-cancel b-help varpl-code b-place varpump-code b-pump
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
