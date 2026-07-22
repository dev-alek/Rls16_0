block-level on error undo, throw.
define input parameter p-node-code  like ub.c-gds-grp-hist.node-code no-undo .
define input parameter p-attr-code  like ub.c-gds-grp-hist.attr-code no-undo .
define input parameter p-tax-code  like ub.c-gds-grp-hist.tax-code no-undo .
define input parameter p-corr-user-db-num  like ub.c-gds-grp-hist.corr-user-db-num no-undo .
define input parameter p-chip-num  like ub.c-gds-grp-hist.chip-num no-undo .
define input parameter p-host-code like ub.c-gds-grp-hist.host-code no-undo .
define input parameter p-obj-type like ub.c-gds-grp-hist.obj-type no-undo .
define input parameter p-obj-code like ub.c-gds-grp-hist.obj-code no-undo .
define input parameter p-subject like ub.c-gds-grp-hist.subject no-undo .
define input parameter p-action   like ub.c-gds-grp-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .
define output parameter p-full-name-old as character no-undo .
define output parameter p-full-name-new as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cggrhisv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cggrhisv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории групп товаров".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure grp-attr-name :
do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
    case p-code :
            when 'gds-grp-nabor':U then do:     assign     p-label = "Набор"     p-type = 'L':U      p-format = "yes/no"     p-label = "Набор"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
      otherwise do:
        undo, return error "Неизвестный атрибут группы товаров на фирме" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure grp-attr-tooltip :
do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'gds-grp-nabor':U then do:     assign     p-tooltip = "Набор - не товарные позиции"     p-label = "Набор" .   end.
      otherwise do:
            undo, return error "Неизвестный атрибут группы товаров на фирме" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure grp-attr-value :
do
on error undo, return error
:
define input  parameter p-node-code   as integer    no-undo.
define input  parameter p-code        as character  no-undo.
define input  parameter p-host-code   as integer    no-undo.
define input  parameter p-obj-type    as character  no-undo.
define input  parameter p-obj-code    as integer    no-undo.
define output parameter p-value       as character  no-undo.
define output parameter p-type        as character  no-undo.
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define buffer buf_gds-grp-attr for ub.gds-grp-attr.
    run grp-attr-name in this-procedure (
          input  p-code
        , output p-type
        , output v-format
        , output v-label
        , output v-user-can-edit
        , output v-output-display
        , output v-other
    ) no-error .
    if error-status :error
    then do:
        undo, return error return-value .
    end.
    find first buf_gds-grp-attr no-lock
         where buf_gds-grp-attr.node-code = p-node-code
           and buf_gds-grp-attr.attr-code = p-code
           and buf_gds-grp-attr.host-code = p-host-code
           and buf_gds-grp-attr.obj-type  = p-obj-type
           and buf_gds-grp-attr.obj-code  = p-obj-code
    no-error .
    if available buf_gds-grp-attr
    then do:
        assign
            p-value = buf_gds-grp-attr.attr-value
        .
    end.
    else do:
        assign
            p-value = if p-type = 'L':U then "no":U else ""
        .
    end.
end.
end procedure.
procedure grp-attr-write :
do
on error undo, return error
:
define input parameter p-node-code  like ub.gds-grp-attr.node-code      no-undo.
define input parameter p-code       like ub.gds-grp-attr.attr-code      no-undo.
define input parameter p-host-code  as integer                          no-undo.
define input parameter p-obj-type   like ub.clients.obj-type            no-undo.
define input parameter p-obj-code   like ub.clients.obj-code            no-undo.
define input parameter p-value      like ub.gds-grp-attr.attr-value     no-undo.
    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.
    define buffer buf_gds-grp-attr for ub.gds-grp-attr .
    run grp-attr-name in this-procedure (
                      input  p-code
                    , output v-type
                    , output v-format
                    , output v-label
                    , output v-user-can-edit
                    , output v-output-display
                    , output v-other
    ) no-error.
    if error-status :error
    then do:
        undo, return error return-value.
    end.
    find first buf_gds-grp-attr exclusive-lock
         where buf_gds-grp-attr.node-code  = p-node-code
           and buf_gds-grp-attr.attr-code  = p-code
           and buf_gds-grp-attr.host-code  = p-host-code
           and buf_gds-grp-attr.obj-type   = p-obj-type
           and buf_gds-grp-attr.obj-code   = p-obj-code
    no-error.
    if not available buf_gds-grp-attr
    then do:
        create buf_gds-grp-attr.
        assign
                buf_gds-grp-attr.node-code  = p-node-code
                buf_gds-grp-attr.attr-code  = p-code
                buf_gds-grp-attr.host-code  = p-host-code
                buf_gds-grp-attr.obj-type   = p-obj-type
                buf_gds-grp-attr.obj-code   = p-obj-code
                buf_gds-grp-attr.attr-value = p-value
        .
    end.
    else do:
        assign
            buf_gds-grp-attr.attr-value = p-value
        .
    end.
end.
end procedure.
procedure grp-attr-delete :
do
on error undo, return error
:
define input parameter p-node-code  like ub.gds-grp-attr.node-code  no-undo.
define input parameter p-code       like ub.gds-grp-attr.attr-code  no-undo.
define input parameter p-host-code  as integer                      no-undo.
define input parameter p-obj-type   like ub.clients.obj-type        no-undo.
define input parameter p-obj-code   like ub.clients.obj-code        no-undo.
define output parameter p-deleted   as logical                      no-undo.
    define buffer buf_gds-grp-attr for ub.gds-grp-attr .
    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.
    run grp-attr-name in this-procedure
    ( input  p-code
    , output v-type
    , output v-format
    , output v-label
    , output v-user-can-edit
    , output v-output-display
    , output v-other
    ) no-error .
    if error-status :error then do:
        undo, return error return-value .
    end.
    find first buf_gds-grp-attr exclusive-lock
         where buf_gds-grp-attr.node-code  = p-node-code
           and buf_gds-grp-attr.attr-code  = p-code
           and buf_gds-grp-attr.host-code  = p-host-code
           and buf_gds-grp-attr.obj-type   = p-obj-type
           and buf_gds-grp-attr.obj-code   = p-obj-code
    no-error.
    if not available buf_gds-grp-attr
    then do:
        assign
            p-deleted = no
        .
    end.
    else do:
       delete buf_gds-grp-attr.
       assign
            p-deleted = yes
        .
    end.
end.
end procedure.
procedure grp-attr-news :
do
on error undo, return error
:
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'gds-grp-nabor':U then do:     assign     p-news = true.   end.
      otherwise do:
        undo, return error "неизвестный атрибут товара на фирме" + " " + p-code .
      end.
    end.
end.
end procedure.
procedure grp-attr-obj-value :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define input parameter p-attr-code as character    no-undo .
define output parameter p-attr-value     as character   no-undo.
define output parameter p-range     as integer      no-undo.
define output parameter p-exists    as logical      no-undo.
define variable v-host-code as integer      no-undo.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-attr      for ub.gds-grp-attr.
find first buf_gds-grp-attr no-lock
     where buf_gds-grp-attr.node-code = p-node-code
       and buf_gds-grp-attr.attr-code = p-attr-code
       and buf_gds-grp-attr.host-code = v-host-code
       and buf_gds-grp-attr.obj-type  = p-obj-type
       and buf_gds-grp-attr.obj-code  = p-obj-code
no-error .
if not available buf_gds-grp-attr
then do:
    find first buf_gds-grp-attr no-lock
         where buf_gds-grp-attr.node-code = p-node-code
           and buf_gds-grp-attr.attr-code = p-attr-code
           and buf_gds-grp-attr.host-code = v-host-code
           and buf_gds-grp-attr.obj-type  = ""
           and buf_gds-grp-attr.obj-code  = 0
    no-error .
    if not available buf_gds-grp-attr
    then do:
        find first buf_gds-grp-attr no-lock
            where buf_gds-grp-attr.node-code = p-node-code
            and buf_gds-grp-attr.attr-code = p-attr-code
            and buf_gds-grp-attr.host-code = 0
            and buf_gds-grp-attr.obj-type  = ""
            and buf_gds-grp-attr.obj-code  = 0
        no-error .
        if not available buf_gds-grp-attr
        then do:
            assign
                p-exists = no
            .
        end.
        else do:
            assign
                p-exists = yes
                p-range  = 1
            .
        end.
    end.
    else do:
        assign
            p-exists = yes
            p-range  = 2
        .
    end.
end.
else do:
    assign
        p-exists = yes
        p-range  = 3
    .
end.
if available buf_gds-grp-attr
then do:
  assign
  p-attr-value = buf_gds-grp-attr.attr-value
  .
end.
end.
end procedure.
procedure ver-gds-grp-nabor :
do
on error undo, return error return-value
:
define input  parameter p-gds-code as integer   no-undo .
define output parameter p-nabor as logical   no-undo .
define buffer buf_goods for ub.goods.
p-nabor = false .
find first  buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
if error-status :error then return error .
define variable v-value       as character  no-undo.
define variable v-type        as character  no-undo.
  run grp-attr-value (
     input   buf_goods.grp-code
    ,input   'gds-grp-nabor':U
    ,input   0
    ,input   ""
    ,input   0
    ,output  v-value
    ,output  v-type       ) no-error .
    if error-status :error then return error .
  if v-value = "yes" then p-nabor = true  .
end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-drt-prop no-undo like ub.drt-prop.
procedure disrules-fill-properties:
define input  parameter p-templ-rl-root as integer   no-undo .
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_temp-drt-prop for temp-drt-prop.
do
on error undo, return error return-value
:
  for each buf_temp-drt-prop:
    delete buf_temp-drt-prop.
  end.
  for each buf_drt-prop where buf_drt-prop.templ-rl-root = p-templ-rl-root:
    create buf_temp-drt-prop.
    buffer-copy buf_drt-prop to buf_temp-drt-prop.
  end.
end.
end procedure.
~
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure discfgru-check :
define input parameter p-table-name as character no-undo .
define input parameter p-templ-rl-root as integer no-undo .
define input parameter p-time-templ-rl-root as integer no-undo .
define input parameter p-pos-type as character no-undo .
define output parameter p-disnct-role as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
  do
  on error undo, return error return-value
  :
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.table-name = p-table-name
        and buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
        and (p-time-templ-rl-root = ? or  buf_dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root)
        and buf_dis-cfg-rule.pos-type = p-pos-type no-error.
    if not available buf_dis-cfg-rule
    or p-pos-type = "":U
    then do:
       return error substitute("Для места использования типа &1 не определен тип скидки с шаблоном &2 &3"
                               ,entry (lookup (p-pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U)
                               , p-templ-rl-root
                               , (if p-time-templ-rl-root = ?
                                  then '':U
                                  else substitute("с расписанием типа &1", p-time-templ-rl-root)
                                  )
                               ).
    end.
    assign
    p-disnct-role = buf_dis-cfg-rule.discnt-role
    .
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = 'орг':U then do:
       par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parhost-code).
       return par-region.
    end.
    if parobj-type = 'регион':U
    then do:
       par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
       return par-region.
    end.
    par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
    return par-region.
END FUNCTION.
FUNCTION get-objregion RETURNS CHARACTER
  (  input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if  parobj-type = "":U and
      parobj-code = 0
  then do:
     par-region = "Глобально".
  end.
  else if parobj-type = 'орг':U
  then do:
     par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parobj-code).
  end.
  else if parobj-type = 'регион':U
  then do:
     par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
  end.
  else
     par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
  return par-region.
END FUNCTION.
procedure disgrpru-name :
define buffer buf_dis-rule for ub.dis-rule.
do
  on error undo, return error
  :
  define input  parameter p-templ-rl-root  as integer no-undo .
  define output parameter p-label          as character no-undo .
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-templ-rl-root no-error.
  if available buf_dis-rule then do:
    if buf_dis-rule.rule-num > 0 then
    p-label = buf_dis-rule.des.
  end.
  else do:
    p-label = substitute("Неизвестный тип правила скидки &1", p-templ-rl-root).
  end.
end.
end procedure.
function disgrpru-get-disc-label returns character ( input p-templ-rl-root as integer):
define variable v-rule-label as character no-undo .
run disgrpru-name in this-procedure ( input p-templ-rl-root
                                     ,output v-rule-label) no-error.
return v-rule-label.
end function.
function disgrpru-get-disc-role-label returns character ( input p-discnt-role as character):
define variable v-role-label as character no-undo .
v-role-label =  entry (lookup (p-discnt-role, 'gds-grp-pcnt,gds-grp-pcnt-kat,gds-grp-abs,gds-grp-qnty,gds-grp-sum':u) + 1, ',' + '% скидка на группу товара,% скидка на группу товара для кат.клиентов,Abs скидка на группу товара,% Скидка на группу товара по кол-ву,% Скидка на группу товара на сумму':u).
if v-role-label = '':u then do:
  v-role-label = entry (lookup (p-discnt-role, 'cli-grp-pcnt':u) + 1, ',' + '% скидка на группу клиентов':u).
end.
return v-role-label.
end function.
procedure disgrpru-write :
  do
  on error undo, return error
  :
    define input parameter p-classif-type   like ub.dis-grp-rule.classif-type no-undo .
    define input parameter p-node-code      like ub.dis-grp-rule.node-code  no-undo .
    define input parameter p-host-code      like ub.dis-grp-rule.host-code no-undo .
    define input parameter p-obj-type       like ub.dis-grp-rule.obj-type   no-undo .
    define input parameter p-obj-code       like ub.dis-grp-rule.obj-code   no-undo .
    define input parameter p-pos-type       like ub.dis-grp-rule.pos-type   no-undo .
    define input parameter p-discnt-role    like ub.dis-grp-rule.discnt-role no-undo .
    define input parameter p-templ-rl-root  like ub.dis-grp-rule.templ-rl-root  no-undo .
    define input parameter p-time-templ-rl-root  like ub.dis-grp-rule.time-templ-rl-root  no-undo .
    define input parameter p-rule-num       like ub.dis-grp-rule.rule-num    no-undo .
    define input parameter p-nonunique      like ub.dis-grp-rule.nonunique   no-undo .
    define buffer buf_dis-grp-rule for ub.dis-grp-rule .
    define buffer lock_dis-grp-rule for ub.dis-grp-rule .
    define buffer buf_dis-rule for ub.dis-rule.
    define variable v-label          as character no-undo .
    define variable v-discnt-role as character no-undo .
    define variable v-host-code as integer no-undo .
    run discfgru-check in this-procedure (
                                          input 'dis-grp-rule':U
                                         ,input p-templ-rl-root
                                         ,input p-time-templ-rl-root
                                         ,input p-pos-type
                                         ,output v-discnt-role
                                          ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
   if p-discnt-role = ? then do:
      p-discnt-role = v-discnt-role.
    end.
    if p-discnt-role <> v-discnt-role then do:
      undo, return error substitute("Группа с кодом &1 &2 место использ.&3 уже есть скидка типа &4&5не может быть по шаблону &6 и расписанию &7"
                              ,p-node-code
                              ,p-obj-type + string(p-obj-code)
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'gds-grp-pcnt,gds-grp-pcnt-kat,gds-grp-abs,gds-grp-qnty,gds-grp-sum':u) + 1, ',' + '% скидка на группу товара,% скидка на группу товара для кат.клиентов,Abs скидка на группу товара,% Скидка на группу товара по кол-ву,% Скидка на группу товара на сумму':u)
                              ,chr(10)
                              ,p-templ-rl-root
                              ,p-rule-num).
    end.
    if p-pos-type = ? then do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type6 as character no-undo .
define variable v-value-date6 as date no-undo .
define variable v-value-decimal6 as decimal no-undo .
define variable v-value-integer6 as INTEGER no-undo .
define variable v-value-logical6 AS LOGICAL no-undo .
define variable v-tth6 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output p-pos-type
    ,output v-value-date6
    ,output v-value-decimal6
    ,output v-value-integer6
    ,output v-value-logical6
    ,output v-param-type6
    ,INPUT-OUTPUT table-handle v-tth6
    )  .
delete object v-tth6 no-error.
    end.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-rule-num no-error.
    if not available buf_Dis-rule then do:
      undo, return error substitute("Группа с кодом &1 &2 место использ.&3 уже есть скидка типа &4&5не найдено правило скидки &6"
                              ,p-node-code
                              ,p-obj-type + string(p-obj-code)
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'gds-grp-pcnt,gds-grp-pcnt-kat,gds-grp-abs,gds-grp-qnty,gds-grp-sum':u) + 1, ',' + '% скидка на группу товара,% скидка на группу товара для кат.клиентов,Abs скидка на группу товара,% Скидка на группу товара по кол-ву,% Скидка на группу товара на сумму':u)
                              ,chr(10)
                              ,p-rule-num).
    end.
    if buf_dis-rule.root <> yes then do:
      undo, return error substitute("Группа с кодом &1 &2 место использ.&3 уже есть скидка типа &4&5правило скидки &6 - некорневое"
                              ,p-node-code
                              ,p-obj-type + string(p-obj-code)
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'gds-grp-pcnt,gds-grp-pcnt-kat,gds-grp-abs,gds-grp-qnty,gds-grp-sum':u) + 1, ',' + '% скидка на группу товара,% скидка на группу товара для кат.клиентов,Abs скидка на группу товара,% Скидка на группу товара по кол-ву,% Скидка на группу товара на сумму':u)
                              ,chr(10)
                              ,p-rule-num).
    end.
    if not (p-obj-type = buf_dis-rule.obj-type
        and p-obj-code = buf_dis-rule.obj-code) then do:
      undo, return error (substitute("Группа с кодом &1 &2 место использ.&3 уже есть скидка типа &4&5правило скидки &6"
                              ,p-node-code
                              ,p-obj-type + string(p-obj-code)
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'gds-grp-pcnt,gds-grp-pcnt-kat,gds-grp-abs,gds-grp-qnty,gds-grp-sum':u) + 1, ',' + '% скидка на группу товара,% скидка на группу товара для кат.клиентов,Abs скидка на группу товара,% Скидка на группу товара по кол-ву,% Скидка на группу товара на сумму':u)
                              ,chr(10)
                              ,p-rule-num)
                          +
                          substitute("Правило скидки &1 определено для &1&2" +
                                     "а привязка к ДК для &3"
                                     ,get-region( buf_Dis-rule.host-code, buf_dis-rule.obj-type, buf_Dis-rule.obj-code)
                                     ,chr(10)
                                     ,get-region( p-host-code, p-obj-type, p-obj-code)
                                     ))
                              .
    end.
    find first buf_dis-grp-rule exclusive-lock where
               buf_dis-grp-rule.classif-type  = p-classif-type
           AND buf_dis-grp-rule.node-code  = p-node-code
           AND buf_dis-grp-rule.host-code  = p-host-code
           AND buf_dis-grp-rule.obj-type  = p-obj-type
           AND buf_dis-grp-rule.obj-code  = p-obj-code
           AND buf_dis-grp-rule.pos-type  = p-pos-type
           AND buf_dis-grp-rule.discnt-role = p-discnt-role
           and buf_dis-grp-rule.nonunique = p-nonunique
           no-error .
    if not available buf_dis-grp-rule then do:
      create buf_dis-grp-rule .
      assign
      buf_dis-grp-rule.classif-type  = p-classif-type
      buf_dis-grp-rule.node-code  = p-node-code
      buf_dis-grp-rule.obj-type  = p-obj-type
      buf_dis-grp-rule.obj-code  = p-obj-code
      buf_dis-grp-rule.host-code  = p-host-code
      buf_dis-grp-rule.pos-type = p-pos-type
      buf_dis-grp-rule.discnt-role = v-discnt-role
      buf_dis-grp-rule.rule-num = p-rule-num
      buf_dis-grp-rule.nonunique = p-nonunique
      no-error
      .
    end.
    ASSIGN
    buf_dis-grp-rule.rule-num = p-rule-num
    buf_dis-grp-rule.rl-root = p-rule-num
    buf_dis-grp-rule.templ-rl-root = p-templ-rl-root
    buf_dis-grp-rule.time-templ-rl-root = p-time-templ-rl-root
    buf_dis-grp-rule.nonunique = p-nonunique
    no-error.
  end.
end procedure.
procedure disgrpru-delete :
define input parameter p-classif-type   like ub.dis-grp-rule.classif-type no-undo .
define input parameter p-node-code      like ub.dis-grp-rule.node-code  no-undo .
define input parameter p-host-code      like ub.dis-grp-rule.host-code   no-undo .
define input parameter p-obj-type       like ub.dis-grp-rule.obj-type   no-undo .
define input parameter p-obj-code       like ub.dis-grp-rule.obj-code   no-undo .
define input parameter p-pos-type       like ub.dis-grp-rule.pos-type   no-undo .
define input parameter p-discnt-role    like ub.dis-grp-rule.discnt-role no-undo .
define input parameter p-nonunique      like ub.dis-grp-rule.nonunique   no-undo .
define output parameter p-deleted       as logical no-undo .
define variable v-rule-label as character no-undo .
define buffer buf_dis-grp-rule for ub.dis-grp-rule.
do
on error undo, return error
:
find first buf_dis-grp-rule exclusive-lock where
            buf_dis-grp-rule.classif-type  = p-classif-type
        AND buf_dis-grp-rule.node-code  = p-node-code
        AND buf_dis-grp-rule.obj-type  = p-obj-type
        AND buf_dis-grp-rule.host-code = p-host-code
        AND buf_dis-grp-rule.obj-code  = p-obj-code
        AND buf_dis-grp-rule.pos-type  = p-pos-type
        AND buf_dis-grp-rule.discnt-role = p-discnt-role
        and buf_dis-grp-rule.nonunique = p-nonunique
        no-error .
if not available buf_dis-grp-rule then do:
  return '':U.
end.
delete buf_dis-grp-rule no-error.
if error-status:error then do:
  run disgrpru-name in this-procedure
    (input  buf_dis-grp-rule.templ-rl-root
    ,output v-rule-label
    ) no-error .
  undo, return error substitute("Ошибка при удалении скидки по группе:&1" +
                               "&2 (место использ. &3) на фирме &4 &5&6 для группы &7&1&8&1&9"
                                ,chr(10)
                                ,v-rule-label
                                ,entry (lookup (p-pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U)
                                ,p-host-code
                                ,p-obj-type
                                ,p-obj-code
                                ,error-status:get-message(1)
                                ,return-value ).
end.
p-deleted = yes.
return '':U.
end.
end procedure.
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .
define buffer buf_c-gds-grp-hist for ub.c-gds-grp-hist.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define SHARED temp-table temp-changes no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
field t_name as character
field num_ as integer
field uniq-key-rec as character
field action as integer
field fNotChange as logical
index pi is unique primary
num_
t_name
f_name
index
Chan
fnotChange
t_name
f_name
index imain uniq-key-rec
.
FUNCTION get-all-fields returns character (p-file-name as character ):
define variable v-dop as character no-undo .
  find first _file no-lock where _file._file-name = p-file-name no-error .
  if not available _file then return "":U.
  for each _field no-lock where
           _field._file-recid = recid(_file) :
    assign
    v-dop = v-dop + _field._field-name + chr(44)
    .
  end.
  return trim(v-dop).
END FUNCTION.
PROCEDURE proc-full-temp-changes :
  define input  parameter p-act-create as logical   no-undo .
  define input  parameter p-act-delete as logical   no-undo .
  define input  parameter p-hst-handle as handle    no-undo .
  define input  parameter p-main-table as character no-undo .
  define input  parameter p-field-list as character no-undo .
  define input  parameter p-label-form as character no-undo .
  define variable h-new-buf         as handle    no-undo .
  define variable h-main-buf        as handle    no-undo .
  define variable h-for-comp        as handle    no-undo .
  define variable v-inform          as character no-undo .
  define variable v-ind             as integer   no-undo .
  define variable v-idx-field-qnty  as integer   no-undo .
  define variable v-num-entries     as integer   no-undo .
  define variable fh                as handle    no-undo .
  define variable fh-main           as handle    no-undo .
  define variable fh-old            as handle    no-undo .
  define variable fh-new            as handle    no-undo .
  define variable v-field-name      as character no-undo .
  define variable v-field-lvl       as character no-undo .
  define variable v-field-form      as character no-undo .
  define variable v-search-exp      as character no-undo .
  define variable v-srch-main       as character no-undo .
  define variable v-word-link       as character no-undo .
  define variable v-av-chip-num     as logical   no-undo .
  define variable v-main-pi-fld-lst as character no-undo .
  define variable v-main-fld-lst    as character no-undo .
  define variable v-delim-list      as character no-undo .
  define variable v-label           as character no-undo .
  define variable v-old-value       as character no-undo case-sensitive.
  define variable v-new-value       as character no-undo case-sensitive.
  define variable v-chg-fields as character no-undo.
  for each temp-changes:
    delete temp-changes.
  end.
  if not p-hst-handle:available then do:
    return .
  end.
  create buffer h-new-buf  for table p-hst-handle .
  create buffer h-main-buf for table p-main-table .
  assign
    v-inform = h-main-buf:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = h-main-buf:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, h-main-buf:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, h-main-buf:name ).
  end.
  assign
    v-srch-main   = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
    v-delim-list  = "":U
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name      = entry( 4 + v-ind, v-inform, ",":U )
      fh                = p-hst-handle:buffer-field( v-field-name )
      fh-main           = h-main-buf:buffer-field( v-field-name )
      v-srch-main       = substitute( "&1 &2 &3.&4 =", v-srch-main, v-word-link, fh-main:table, v-field-name )
      v-main-pi-fld-lst = v-main-pi-fld-lst + v-delim-list + v-field-name
    .
    if fh:data-type ="character":U then do:
      assign
        v-srch-main = substitute( '&1 "&2"', v-srch-main, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-srch-main = substitute( "&1 &2", v-srch-main, fh:buffer-value() )
      .
    end.
    if v-delim-list = "":U then do:
      assign
        v-delim-list = ",":U
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  assign
    v-delim-list  = "":U
  .
  do v-ind = 1 to h-main-buf:num-fields
  on error undo, return error
  :
    assign
      fh-main      = h-main-buf:buffer-field( v-ind )
      v-field-name = fh-main:name
    .
      assign
        v-main-fld-lst = v-main-fld-lst + v-delim-list + v-field-name
      .
      if v-delim-list = "":U then do:
        assign
          v-delim-list = ",":U
        .
      end.
  end.
  assign
    v-inform = p-hst-handle:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = p-hst-handle:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, p-hst-handle:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, p-hst-handle:name ).
  end.
  assign
    v-search-exp  = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name = entry( 4 + v-ind, v-inform, ",":U )
      fh           = p-hst-handle:buffer-field( v-field-name )
      v-search-exp = substitute( "&1 &2 &3.&4", v-search-exp, v-word-link, fh:table, v-field-name )
    .
    if v-field-name = "chip-num":U then do:
      assign
        v-search-exp  = substitute( "&1 >", v-search-exp )
        v-av-chip-num = true
      .
    end.
    else do:
      assign
        v-search-exp = substitute( "&1 =", v-search-exp )
      .
    end.
    if fh:data-type ="character":U then do:
      assign
        v-search-exp = substitute( '&1 "&2"', v-search-exp, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-search-exp = substitute( '&1 &2', v-search-exp, fh:buffer-value() )
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  if v-av-chip-num = false then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Таблица &2 не содержит поля chip-num.", vss-workfile, p-hst-handle:name ) skip
      "Использование данной процедуры невозможно!" skip
      view-as alert-box error .
    return error .
  end.
  h-new-buf:find-first( v-search-exp, no-lock ) no-error .
  if not h-new-buf:available then do:
    h-main-buf:find-first( v-srch-main, no-lock ) no-error .
    if not h-main-buf:available then do:
      assign
        h-for-comp = ?
      .
    end.
    else do:
      assign
        h-for-comp = h-main-buf
      .
    end.
  end.
  else do:
    assign
      h-for-comp = h-new-buf
    .
  end.
  assign
    v-num-entries = num-entries( v-main-fld-lst, ",":U )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    assign
      v-field-name = entry( v-ind, v-main-fld-lst )
      fh-old       = p-hst-handle:buffer-field( v-field-name )
      v-old-value  = fh-old:buffer-value()
      v-label      = trim( fh-old:label )
    .
    if ( trim( p-field-list ) <> "":U
         and lookup( v-field-name, p-field-list ) > 0
       )
       or trim( p-field-list ) = "":U
    then do:
      if h-for-comp <> ? then do:
        assign
          fh-new      = h-for-comp:buffer-field( v-field-name )
          v-new-value = fh-new:buffer-value()
        .
      end.
      else do:
        assign
          v-new-value = "":U
        .
      end.
        if p-act-create = true then do:
          assign
            v-old-value = "":U
          .
        end.
        if p-act-delete = true then do:
          assign
            v-new-value = "":U
          .
        end.
      if v-old-value <> v-new-value
      then do:
        create temp-changes.
        assign
          temp-changes.t_name = p-main-table
          temp-changes.f_name = v-field-name
          temp-changes.l_name = replace( v-label, "&":U, "":U )
          temp-changes.v_old  = trim( v-old-value )
          temp-changes.v_new  = trim( v-new-value )
          temp-changes.num_   = 0
          temp-changes.fNotChange = v-old-value eq v-new-value
        .
      end.
    end.
  end.
  assign
    v-num-entries = num-entries( p-label-form, chr(8) )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    if num-entries( entry( v-ind, p-label-form, chr(8) ), chr(4) ) = 3 then do:
      assign
        v-field-name = entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-lvl  = entry( 2, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-form = entry( 3, entry( v-ind, p-label-form, chr(8) ), chr(4) )
      .
      find first temp-changes
        where temp-changes.f_name = v-field-name
        no-error .
      if available temp-changes then do:
        if trim( v-field-lvl ) <> "":U then do:
          assign
            temp-changes.l_name = v-field-lvl
          .
        end.
        if trim( v-field-form ) <> "":U then do:
          assign
            temp-changes.v_old = dynamic-function( v-field-form, temp-changes.v_old )
          .
          if h-for-comp <> ? then do:
            assign
              temp-changes.v_new = dynamic-function( v-field-form, temp-changes.v_new )
            .
          end.
        end.
      end.
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка! Список должен содержать три поля с разделителем delim-par!" skip
        substitute( "список для поля '&1': '&2'"
                    ,entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
                    ,entry( v-ind, p-label-form, chr(8) )
                  ) skip
        substitute( "полный список: &2", p-label-form ) skip
        view-as alert-box error .
    end.
  end.
  delete object h-new-buf .
  delete object h-main-buf .
END PROCEDURE.
find first buf_c-gds-grp-hist no-lock where
          buf_c-gds-grp-hist.node-code = p-node-code
      AND buf_c-gds-grp-hist.attr-code = p-attr-code
      AND buf_c-gds-grp-hist.tax-code = p-tax-code
      AND buf_c-gds-grp-hist.chip-num = p-chip-num
      AND buf_c-gds-grp-hist.corr-user-db-num = p-corr-user-db-num
      AND buf_c-gds-grp-hist.host-code = p-host-code
      AND buf_c-gds-grp-hist.obj-type = p-obj-type
      AND buf_c-gds-grp-hist.obj-code = p-obj-code
      AND buf_c-gds-grp-hist.subject  = p-subject no-error .
if not available buf_c-gds-grp-hist then do:
  return error .
end.
CASE p-subject:
  when 'gds-grp':U then do:
    run gds-grp-proc in this-procedure(output p-description) no-error .
  end.
  when 'gds-grp-attr':U then do:
    run gds-grp-attr-proc in this-procedure(output p-description) no-error .
  end.
  when 'gds-grp-obj':U then do:
    run gds-grp-obj-proc in this-procedure(output p-description) no-error .
  end.
  when 'tax-rate-gds-grp':U then do:
    run tax-rate-gds-grp-proc in this-procedure(output p-description) no-error .
  end.
  when 'dis-grp-rule':U then do:
    run dis-grp-rule-proc in this-procedure(output p-description) no-error .
  end.
END CASE.
if error-status:error then do:
  return error .
end.
procedure gds-grp-proc :
define output parameter p-description as character no-undo .
define variable v-is-created as logical no-undo .
define variable v-is-deleted as logical no-undo .
define variable v-field-name as character no-undo .
define variable v-field-function as character no-undo .
define variable jj as integer no-undo .
define variable v-field-label  as character no-undo .
define variable v-field-list as character no-undo .
define buffer current_gds-grp for ub.gds-grp  .
define buffer current_c-gds-grp for ub.c-gds-grp  .
define buffer new_c-gds-grp for ub.c-gds-grp  .
  do
  on error undo, return error
  :
    find first current_c-gds-grp no-lock where
               current_c-gds-grp.node-code = p-node-code
           AND current_c-gds-grp.chip-num = p-chip-num
           AND current_c-gds-grp.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-gds-grp then do:
       v-mess = "Неверная ссылка на c-gds-grp в таблице c-gds-grp-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.
    if buf_c-gds-grp-hist.action = integer('1':U) then do:
      assign
      v-is-created = yes
      v-chg-fields = get-all-fields ("gds-grp")
      .
    end.
    if buf_c-gds-grp-hist.action = integer('99':U) then do:
      assign
      v-is-deleted = yes
      v-chg-fields = get-all-fields ("gds-grp")
      .
    end.
    find first new_c-gds-grp no-lock where
               new_c-gds-grp.node-code = p-node-code
           AND new_c-gds-grp.chip-num > p-chip-num
           AND new_c-gds-grp.corr-user-db-num = p-corr-user-db-num
            no-error .
    if not available new_c-gds-grp then do:
        find first current_gds-grp no-lock where
               current_gds-grp.node-code = p-node-code no-error .
        if not available current_gds-grp
        and not  v-is-deleted
        then do:
            return error.
        end.
        if available current_gds-grp then
        buffer-compare current_gds-grp to current_c-gds-grp
        case-sensitive
        save result in v-chg-fields.
    end.
    else do:
        buffer-compare new_c-gds-grp except chip-num corr-date corr-time corr-user-name corr-user-db-num
        to current_c-gds-grp
        case-sensitive
        save result in v-chg-fields.
    end.
    if lookup("node-code", v-chg-fields ) > 0
    or lookup("upper-code", v-chg-fields ) > 0 then do:
       if not v-is-created then
       run c-get-full-name  in this-procedure (
                                                  input  yes
                                                 ,input p-node-code
                                                 ,input p-chip-num
                                                 ,input p-corr-user-db-num
                                                 ,output p-full-name-old
                                                ) no-error .
       if not v-is-deleted then
       run c-get-full-name  in this-procedure (
                                                  input  (if available new_c-gds-grp
                                                          then yes
                                                          else no)
                                                 ,input p-node-code
                                                 ,input (if available new_c-gds-grp
                                                         then new_c-gds-grp.chip-num
                                                         else 0)
                                                 ,input p-corr-user-db-num
                                                 ,output p-full-name-new
                                                ) no-error .
    end.
  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, "calc-method,d-pcnt,increase-pc,is-term,lvl-num,node-code,node-name,unit-base,upper-code").
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, "Способ расчета,Процент скидки,Процент наценки,Терминальная,Уровень,Вн №,Наименование,Осн.ед.изм.,Вн № выш.группы")
    v-field-function = entry(jj, ",,,,,,,,")
    .
    create temp-changes.
    assign
    temp-changes.f_name = v-field-name
    temp-changes.l_name = v-field-label
    temp-changes.v_old =  (if v-is-created
                           then "":U
                           else  string(buffer current_c-gds-grp:buffer-field(v-field-name):buffer-value))
    temp-changes.v_new =  if available new_c-gds-grp
                          then string(buffer new_c-gds-grp:buffer-field(v-field-name):buffer-value)
                          else (if v-is-deleted
                                then '':U
                               else string(buffer current_gds-grp:buffer-field(v-field-name):buffer-value))
    .
    if v-field-function <> '':U then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.
  end.
end.
end procedure.
procedure gds-grp-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-gds-grp-attr for ub.c-gds-grp-attr  .
  do
  on error undo, return error
  :
    find first current_c-gds-grp-attr no-lock where
               current_c-gds-grp-attr.node-code = p-node-code
           AND current_c-gds-grp-attr.attr-code = p-attr-code
           AND current_c-gds-grp-attr.host-code = p-host-code
           AND current_c-gds-grp-attr.obj-type  = p-obj-type
           AND current_c-gds-grp-attr.obj-code = p-obj-code
           AND current_c-gds-grp-attr.chip-num = p-chip-num
           AND current_c-gds-grp-attr.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-gds-grp-attr then do:
       v-mess = "Неверная ссылка на c-gds-grp-attr в таблице c-gds-grp-attr-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.
    run grp-attr-tooltip in this-procedure (
                input  string(current_c-gds-grp-attr.attr-code)
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + chr(32) + v-label
    .
define variable v-label-param as character no-undo .
v-label-param =
  "node-code" + chr(4) + "Вн № группы" + chr(4) + "" + chr(8)
 + "attr-code" + chr(4) + "Атрибут" + chr(4) + "" + chr(8)
 + "attr-value" + chr(4) + "Значение" + chr(4) + "" + chr(8)
 + "host-code" + chr(4) + "Фирма" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-grp-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-grp-hist.action = integer('99':U))
                                            ,input  buffer current_c-gds-grp-attr:handle
                                            ,input  'gds-grp-attr':U
                                            ,input  "node-code,attr-code,attr-value,host-code,obj-type,obj-code"
                                            ,input  v-label-param).
end.
end procedure.
procedure gds-grp-obj-proc :
define output parameter p-description as character no-undo .
define buffer current_c-gds-grp-obj for ub.c-gds-grp-obj  .
  do
  on error undo, return error
  :
    find first current_c-gds-grp-obj no-lock where
               current_c-gds-grp-obj.node-code = p-node-code
           AND current_c-gds-grp-obj.host-code = p-host-code
           AND current_c-gds-grp-obj.obj-type  = p-obj-type
           AND current_c-gds-grp-obj.obj-code = p-obj-code
           AND current_c-gds-grp-obj.chip-num = p-chip-num
           AND current_c-gds-grp-obj.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-gds-grp-obj then do:
       v-mess = "Неверная ссылка на c-gds-grp-obj в таблице c-gds-grp-obj-hist".
       run err-mess in this-procedure ( input-output v-mess ).
       return error (if p-silent then v-mess else '':U).
    end.
                                             define variable v-label-param as character no-undo .
v-label-param =
  "node-code" + chr(4) + "Вн № группы" + chr(4) + "" + chr(8)
 + "host-code" + chr(4) + "Фирма" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "calc-method" + chr(4) + "Способ расчета" + chr(4) + "" + chr(8)
 + "cli-code" + chr(4) + "Код поставщика" + chr(4) + "" + chr(8)
 + "cli-type" + chr(4) + "Тип поставщика" + chr(4) + "" + chr(8)
 + "increase-pc" + chr(4) + "% наценки" + chr(4) + "" + chr(8)
 + "max-increase" + chr(4) + "Max % наценки" + chr(4) + "" + chr(8)
 + "min-increase" + chr(4) + "Min % наценки" + chr(4) + "" + chr(8)
 + "round-coeff" + chr(4) + "Коэф.округ." + chr(4) + "" + chr(8)
 + "round-method" + chr(4) + "Метод округл." + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-grp-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-grp-hist.action = integer('99':U))
                                            ,input  buffer current_c-gds-grp-obj:handle
                                            ,input  'gds-grp-obj':U
                                            ,input  "node-code,host-code,obj-type,obj-code,calc-method,cli-code,cli-type,increase-pc,max-increase," + "min-increase,round-coeff,round-method"
                                            ,input  v-label-param).
end.
end procedure.
procedure tax-rate-gds-grp-proc :
define output parameter p-description as character no-undo .
define buffer current_c-tax-rate-gds-grp for ub.c-tax-rate-gds-grp  .
define buffer buf_tax for ub.tax.
  do
  on error undo, return error
  :
    find first current_c-tax-rate-gds-grp no-lock where
               current_c-tax-rate-gds-grp.node-code = p-node-code
           AND current_c-tax-rate-gds-grp.tax-code = p-tax-code
           AND current_c-tax-rate-gds-grp.host-code = p-host-code
           AND current_c-tax-rate-gds-grp.obj-type  = p-obj-type
           AND current_c-tax-rate-gds-grp.obj-code = p-obj-code
           AND current_c-tax-rate-gds-grp.chip-num = p-chip-num
           AND current_c-tax-rate-gds-grp.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-tax-rate-gds-grp then do:
       v-mess = "Неверная ссылка на c-tax-rate-gds-grp в таблице c-tax-rate-gds-grp-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.
    find first buf_tax no-lock where buf_tax.tax-code = p-tax-code .
    assign
    p-description = buf_tax.tax-name
    .
  define variable v-label-param as character no-undo .
v-label-param =
  "node-code" + chr(4) + "Вн № группы" + chr(4) + "" + chr(8)
 + "host-code" + chr(4) + "Фирма" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "tax-code" + chr(4) + "Код налога" + chr(4) + "" + chr(8)
 + "rate-code" + chr(4) + "Код ставки налога" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-grp-hist.action = integer('1':U))
                                            ,input  (buf_c-gds-grp-hist.action = integer('99':U))
                                            ,input  buffer current_c-tax-rate-gds-grp:handle
                                            ,input  'tax-rate-gds-grp':U
                                            ,input  "node-code,host-code,obj-type,obj-code,tax-code,rate-code"
                                            ,input  v-label-param).
end.
end procedure.
procedure dis-grp-rule-proc :
define output parameter p-description as character no-undo .
define buffer current_c-dis-grp-rule for ub.c-dis-grp-rule  .
  do
  on error undo, return error
  :
    find first current_c-dis-grp-rule no-lock where
               current_c-dis-grp-rule.classif-type = 'gds-grp':U
           AND current_c-dis-grp-rule.node-code = p-node-code
           AND current_c-dis-grp-rule.host-code  = p-host-code
           AND current_c-dis-grp-rule.obj-type  = p-obj-type
           AND current_c-dis-grp-rule.obj-code = p-obj-code
           AND current_c-dis-grp-rule.chip-num = p-chip-num
           AND current_c-dis-grp-rule.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-dis-grp-rule then do:
       v-mess = "Неверная ссылка на c-dis-grp-rule в таблице c-dis-grp-rule-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.
    define variable v-label-param as character no-undo .
    v-label-param =
  "rule-num" + chr(4) + "Номер правила скидки" + chr(4) + "" + chr(8)
 + "pos-type" + chr(4) + "Место использ." + chr(4) + "" + chr(8)
 + "templ-rl-root" + chr(4) + "Тип шаблона" + chr(4) + "disgrpru-get-disc-label"  + chr(8)
 + "discnt-role" + chr(4) + "Тип скидки" + chr(4) + "disgrpru-get-disc-role-label"
 .
    run proc-full-temp-changes in this-procedure (
                                                input  (p-action = integer('1':U))
                                                ,input  (p-action = integer('99':U))
                                                ,input  buffer current_c-dis-grp-rule:handle
                                                ,input  'dis-grp-rule':U
                                                ,input  "rule-num,pos-type,templ-rl-root,discnt-role"
                                                ,input  v-label-param).
end.
end procedure.
procedure c-get-full-name :
do
on error undo, return error
:
define input parameter p-c          as logical no-undo .
define input parameter p-node-code  as integer      no-undo.
define input parameter p-chip-num  as integer no-undo .
define input parameter p-corr-user-db-num as integer no-undo .
define output parameter p-full-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define variable v-c as logical no-undo .
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    define buffer buf_c-gds-grp       for ub.c-gds-grp.
    define buffer buf_c-upper_gds-grp for ub.c-gds-grp.
    if p-c then do:
      find first buf_c-gds-grp no-lock
          where buf_c-gds-grp.node-code = p-node-code
            AND buf_c-gds-grp.chip-num  = p-chip-num
            AND buf_c-gds-grp.corr-user-db-num  = p-corr-user-db-num
      no-error.
      if not available buf_c-gds-grp
      then do:
          undo, return error substitute("Не найдена запись истории для группа товаров: вн № &1, chip-num &2, БД-корректор &3"
                                        , p-node-code
                                        , p-chip-num
                                        , p-corr-user-db-num
                                        ).
      end.
    end.
    else do:
      find first buf_gds-grp no-lock
          where buf_gds-grp.node-code = p-node-code
      no-error.
      if not available buf_gds-grp
      then do:
          undo, return error substitute("Не найдена запись группы товаров: вн № &1"
                                        , p-node-code
                                        ).
      end.
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
        v-c = p-c
    .
    do while
    ( v-c = no and buf_gds-grp.upper-code <> 0)
    or ( v-c = yes and  buf_c-gds-grp.upper-code <> 0)
    on error undo, return error "Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = (if v-c = yes
                            then buf_c-gds-grp.node-name
                            else buf_gds-grp.node-name)
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = (if v-c
                            then buf_c-gds-grp.upper-code
                            else buf_gds-grp.upper-code)
        .
        find first buf_c-gds-grp no-lock
             where buf_c-gds-grp.node-code = v-upper-code
               AND buf_c-gds-grp.chip-num  > p-chip-num
               AND buf_c-gds-grp.corr-user-db-num  > p-corr-user-db-num no-error .
        if not available buf_c-gds-grp then do:
          assign
          v-c = no
          .
          find first buf_gds-grp no-lock
              where buf_gds-grp.node-code = v-upper-code
          no-error.
          if not available buf_gds-grp
          then do:
              undo, return error substitute("Не найдена группа товаров с кодом &1" +
                                             ". Ошибка ссылки в дереве товаров для записи истории групп товаров:" +
                                             "вн № &2, chip-num &3, БД-корректор &4"
                                            ,  v-upper-code
                                            ,  p-node-code
                                            , p-chip-num
                                            , p-corr-user-db-num).
          end.
        end.
        else do:
          assign
          v-c = yes
          .
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end procedure.
PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("История групп товаров&1" +
                          "Вн Код группы: &2&1" +
                          "щепка &3 БД:&4&1&5&6"
                          ,chr(10)
                          ,p-node-code
                          ,p-chip-num
                          ,p-corr-user-db-num
                          ,chr(10)
                          ,p-mess).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
