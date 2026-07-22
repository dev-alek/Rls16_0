block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sendgrup.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sendgrup.p $":U .
define variable vss-description as character no-undo init "Пересылка групп товаров на кассу - пускальник".
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
define variable i-obj-code like ub.shop.obj-code no-undo.
define variable mode as char no-undo.
define variable log-file-name as character no-undo init "send-cd.txt":U .
define variable v-view-log as logical no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE cash-grp no-undo
FIELD stts like ub.clients.stts
FIELD grp-code like ub.sum-grp.grp-code
FIELD upper-code like ub.gds-grp.upper-code
FIELD grp-name like ub.sum-grp.grp-name
FIELD news-action as logical
index pi IS UNIQUE PRIMARY
grp-code
.
DEFINE NEW SHARED TEMP-TABLE cash-units no-undo  like ub.units
.
DEFINE NEW SHARED TEMP-TABLE cash-gds-prt no-undo like ub.gds-prt
.
DEFINE NEW SHARED TEMP-TABLE cash-country no-undo like ub.country
.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
 shared
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
DEFINE VARIABLE choice as integer no-undo.
DEFINE VARIABLE grp-list            as char no-undo.
DEFINE VARIABLE kk                  as int      no-undo.
DEFINE VARIABLE callpoint as char no-undo.
define variable glog as logical no-undo .
define variable is-bo as character no-undo .
define variable is-bo-name as character no-undo .
assign
i-obj-code = integer(entry(1, p-parameter, chr(4)))
mode       = entry(2, p-parameter, chr(4))
is-bo      = (if num-entries(p-parameter, chr(4)) > 2
              then entry(3, p-parameter, chr(4))
              else '':U
             )
no-error
.
if error-status:error then return error.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
assign
callpoint = mode.
mode = if mode = "R" then "U" else mode.
mode = if mode = "A" then "U" else mode.
for each cash-grp:
  delete cash-grp.
end.
CASE is-bo:
  when '':U then do:
    assign
    is-bo-name = "группы товара на кассе"
    .
  end.
  when 'group-BO':U then do:
    assign
    is-bo-name = "группы товара TH"
    .
  end.
  when 'units':U then do:
    assign
    is-bo-name = "единицы измерения"
    .
  end.
  when 'gds-prt':U then do:
    assign
    is-bo-name = "шкалы"
    .
  end.
  when 'country':U then do:
    assign
    is-bo-name = "страны"
    .
  end.
END.
if is-bo = '':U then do:
  FIND FIRST ub.cash-desk NO-LOCK WHERE
            ub.cash-desk.db-num = g#db-num
        AND (ub.cash-desk.pos-type = 'IBM':U
            or
            ub.cash-desk.pos-type = 'IBM-XML':U
            or
            ub.cash-desk.pos-type = 'NCR-AS@R':U
            )
        AND ub.cash-desk.obj-code = i-obj-code No-error.
end.
else do:
  FIND FIRST ub.cash-desk NO-LOCK WHERE
            ub.cash-desk.db-num = g#db-num
        AND ub.cash-desk.pos-type = 'InfoKiosk':U
        AND ub.cash-desk.obj-code = i-obj-code No-error.
end.
IF not avail(ub.cash-desk)
then do:
  if callpoint <> "R" then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!&1 &2 реализуется только для касс &3"
                            , (if mode = "U" then "Передача" else "Удаление")
                            , is-bo-name
                            , (if is-bo = '':U
                               then substitute("&1 &2 &3"
                                              , 'IBM':U
                                              , 'IBM-XML':U
                                              , 'NCR-AS@R':U
                                              )
                               else 'InfoKiosk':U
                              )
                          )
                                         ) .
    return.
  end.
end.
else do:
  if callpoint = "R"
  then do:
    glog = yes.
  end.
  else do:
    define variable v-host-code as integer   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  'маг':U
  ,input  abs(i-obj-code)
  ,output v-host-code
  )  .
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cashdesk-goods-groups_update':U
    ,input  'object':U
    ,input  v-host-code
    ,input  'маг':U
    ,input  abs(i-obj-code)
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  end.
  if NOT glog then return .
  glog = yes.
  if callpoint = "R" then choice = 2.
  if callpoint = "A" then choice = 1.
  if choice = 0 then do:
    run gbl/d-askw.w (
                  input substitute("Выбор для пересылки: &1", is-bo-name)
                ,input ( (if mode = "U"
                          then "Переслать на кассу"
                          else "Удалить из кассы" ) +
                          chr(10) + substitute("информацию по: &1", is-bo-name)
                          )
                ,input "|"
                ,input substitute("Все  имеющиеся в базе|&1Отказ от пересылки", (if is-bo <> '' then '':U else "Выборочно|"))
                ,input (if is-bo <> '':U then "|" else "||")
                ,input 1
                ,input (if is-bo <> '':U then 2 else 3)
                ,output choice).
  end.
  CASE choice :
    when 3 then return .
    when 2 then do:
      if is-bo <> '':U then return.
      if callpoint = "R" then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Подготовка данных")
                                              ).
        FOR EACH obj-list No-LOCK:
          find first ub.sum-grp NO-LOCK WHERE
                  ub.sum-grp.grp-code = obj-list.obj-code no-error .
          FIND FIRST cash-grp WHERE
                      cash-grp.grp-code = ub.sum-grp.grp-code NO-ERROR.
          if not avail cash-grp and
          (available ub.sum-grp or obj-list.obj-name = "D":U) then do:
            create cash-grp.
            assign
            cash-grp.grp-code = obj-list.obj-code
            cash-grp.grp-name = (if available ub.sum-grp
                                 then ub.sum-grp.grp-name
                                 else "":U)
            cash-grp.news-action = (if obj-list.obj-name = "D":U then yes else no)
            .
          end.
        END.
      end.
      else do:
        run ref/sum-grps.w ( input parparentproc, "b-sel,b-mark", input-output grp-list ) .
        if grp-list <> "" then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("&1 магазина &2: выборочная пересылка: &3"
                                , (if mode = "U" then "Пересылка на кассы" else "Удаление с касс" )
                                , i-obj-code
                                , is-bo-name
                                )
              ).
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Подготовка данных")
                                              ).
          DO kk = 1 TO num-entries( grp-list ) :
            FIND FIRST ub.sum-grp NO-LOCK WHERE
                      recid(ub.sum-grp) = integer(ENTRY(kk, grp-list)) NO-ERROR.
            IF AVAIL ub.sum-grp then do:
              FIND FIRST cash-grp WHERE
                        cash-grp.grp-code = ub.sum-grp.grp-code NO-ERROR.
              if not avail cash-grp then do:
                create cash-grp.
                assign
                cash-grp.grp-code = ub.sum-grp.grp-code
                cash-grp.grp-name = ub.sum-grp.grp-name
                cash-grp.news-action = no
                .
              end.
            END.
          END.
        end.
        else  do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Не определен список для пересылки: &1", is-bo-name)
                                              ).
          return .
        end.
      end.
    end.
    when 1 then do:
      run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Подготовка данных")
                                              ).
      CASE is-bo:
        when "group-BO" then do:
          FOR EACH ub.gds-grp NO-LOCK:
            FIND FIRST cash-grp WHERE
                    cash-grp.grp-code = ub.gds-grp.node-code NO-ERROR.
            if not avail cash-grp then do:
              create cash-grp.
              assign
              cash-grp.grp-code = ub.gds-grp.node-code
              cash-grp.upper-code = ub.gds-grp.upper-code
              cash-grp.grp-name = ub.gds-grp.node-name
              cash-grp.news-action = no
              .
            end.
          END.
        end.
        when '':U then do:
          FOR EACH ub.sum-grp NO-LOCK:
            FIND FIRST cash-grp WHERE
                    cash-grp.grp-code = ub.sum-grp.grp-code NO-ERROR.
            if not avail cash-grp then do:
              create cash-grp.
              assign
              cash-grp.grp-code = ub.sum-grp.grp-code
              cash-grp.grp-name = ub.sum-grp.grp-name
              cash-grp.news-action = no
              .
            end.
          END.
        END.
        when "units":U then do:
          FOR EACH ub.units NO-LOCK:
            FIND FIRST cash-units WHERE
                    cash-units.unit-name = ub.units.unit-name NO-ERROR.
            if not avail cash-units then do:
              create cash-units.
              assign
              cash-units.unit-name = ub.units.unit-name
              cash-units.long-name = ub.units.long-name
              .
            end.
          END.
        end.
        when "gds-prt":U then do:
          FOR EACH ub.gds-prt NO-LOCK:
            FIND FIRST cash-gds-prt WHERE
                    cash-gds-prt.node-code = ub.gds-prt.node-code NO-ERROR.
            if not avail cash-gds-prt then do:
              create cash-gds-prt.
              buffer-copy ub.gds-prt to cash-gds-prt.
            end.
          END.
        end.
        when "country":U then do:
          FOR EACH ub.country NO-LOCK:
            FIND FIRST cash-country WHERE
                    cash-country.alpha1 = ub.country.alpha1 NO-ERROR.
            if not avail cash-country then do:
              create cash-country.
              buffer-copy ub.country to cash-country.
            end.
          END.
        end.
      end CASE.
    end.
  END CASE.
  if ((is-bo = '':U or is-bo = "group-BO")
     and
     can-find(first cash-grp)
     )
  or (is-bo = "Units"
      and
      can-find(first cash-units)
     )
  or (is-bo = "gds-prt":U
      and
      can-find(first cash-gds-prt)
     )
  or (is-bo = "country":U
      and
      can-find(first cash-country)
     )
       then do:
      run str/send-grp.p (
                      input parparentproc
                    , input p-parent-handle
                    , input p-log-handle
                    , input i-obj-code
                    , input  mode
                    , input is-bo
                    , input log-file-name
                    , input-output v-view-log
                    ) no-error.
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("&1 маг&2 &3"
                              , (if mode = "U"
                                then substitute("&1 Передача на кассы", is-bo-name)
                                else substitute("&1 Удаление с касс", is-bo-name)
                                )
                              , i-obj-code
                              , (if mode = "U"
                                then "проведена"
                                else "проведено")
                              )
                                          ).
  end.
  else do:
     run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Не найдено информации по: &1 для передачи на кассы маг&2"
                             , is-bo-name
                             , i-obj-code
                                          )).
  end.
end.
