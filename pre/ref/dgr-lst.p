block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dgr-lst.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dgr-lst.p $":U .
define variable vss-description as character no-undo init "Пакетное изменение по списку скидок товара на объекте".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure disgdsru-name :
define buffer buf_dis-rule for ub.dis-rule.
do
  on error undo, return error
  :
  define input  parameter p-templ-rl-root  as integer no-undo .
  define output parameter p-label          as character no-undo .
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-templ-rl-root no-error.
  if available buf_dis-rule
  then do:
    if buf_dis-rule.rule-num > 0 then
    p-label = buf_dis-rule.des.
  end.
  else do:
    p-label = substitute("Неизвестный тип правила скидки &1", p-templ-rl-root).
  end.
end.
end procedure.
function disgdsru-get-disc-label returns character ( input p-templ-rl-root as integer):
define variable v-rule-label as character no-undo .
run disgdsru-name in this-procedure ( input p-templ-rl-root
                                     ,output v-rule-label) no-error.
return v-rule-label.
end function.
function disgdsru-get-disc-role-label returns character ( input p-discnt-role as character):
define variable v-rule-label as character no-undo .
return entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u).
end function.
procedure disgdsru-write :
  do
  on error undo, return error
  :
    define input parameter p-obj-type       like ub.dis-gds-rule.obj-type   no-undo .
    define input parameter p-obj-code       like ub.dis-gds-rule.obj-code   no-undo .
    define input parameter p-gds-code       like ub.dis-gds-rule.gds-code   no-undo .
    define input parameter p-pos-type       like ub.dis-gds-rule.pos-type   no-undo .
    define input parameter p-discnt-role    like ub.dis-gds-rule.discnt-role no-undo .
    define input parameter p-templ-rl-root  like ub.dis-gds-rule.templ-rl-root  no-undo .
    define input parameter p-time-templ-rl-root  like ub.dis-gds-rule.time-templ-rl-root  no-undo .
    define input parameter p-rule-num       like ub.dis-gds-rule.rule-num    no-undo .
    define input parameter p-nonunique      like ub.dis-gds-rule.nonunique   no-undo .
    define buffer buf_dis-gds-rule for ub.dis-gds-rule .
    define buffer buf_dis-rule for ub.dis-rule.
    define buffer lock_dis-gds-rule for ub.dis-gds-rule .
    define variable v-label          as character no-undo .
    define variable v-discnt-role as character no-undo .
    run discfgru-check in this-procedure (
                                          input 'dis-gds-rule':U
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
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6не может быть по шаблону &7 и расписанию &8"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-templ-rl-root
                              ,p-rule-num).
    end.
    if p-pos-type = ? then do:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type5 as character no-undo .
define variable v-value-date5 as date no-undo .
define variable v-value-decimal5 as decimal no-undo .
define variable v-value-integer5 as INTEGER no-undo .
define variable v-value-logical5 AS LOGICAL no-undo .
define variable v-tth5 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output p-pos-type
    ,output v-value-date5
    ,output v-value-decimal5
    ,output v-value-integer5
    ,output v-value-logical5
    ,output v-param-type5
    ,INPUT-OUTPUT table-handle v-tth5
    )  .
delete object v-tth5 no-error.
    end.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-rule-num no-error.
    if not available buf_Dis-rule then do:
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6не найдено правило скидки &7"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-rule-num).
    end.
    if buf_dis-rule.root <> yes then do:
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6правило скидки &7 - некорневое"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-rule-num).
    end.
    if not (p-obj-type = buf_dis-rule.obj-type
        and p-obj-code = buf_dis-rule.obj-code)
    and not ( (p-obj-type = 'маг':U or p-obj-type = 'скл':U )
             and
             (buf_dis-rule.obj-type = 'орг':U or buf_dis-rule.obj-type = ""))
     then do:
      undo, return error (substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ) +
                          substitute("Правило скидки &1 определено для &2&3" +
                                     "а привязка к товару для &4"
                                     ,buf_dis-rule.rule-num
                                     ,get-objregion( buf_dis-rule.obj-type, buf_Dis-rule.obj-code)
                                     ,chr(10)
                                     ,get-objregion( p-obj-type, p-obj-code)
                                     ))
                              .
    end.
    find first buf_dis-gds-rule exclusive-lock where
               buf_dis-gds-rule.gds-code  = p-gds-code
           AND buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
           AND buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
           AND buf_dis-gds-rule.pos-type  = p-pos-type
           AND buf_dis-gds-rule.discnt-role = p-discnt-role
           and buf_dis-gds-rule.nonunique = p-nonunique
           no-error .
    if not available buf_dis-gds-rule then do:
      find first buf_dis-gds-rule exclusive-lock where
                buf_dis-gds-rule.gds-code  = p-gds-code
            AND buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
            AND buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
            AND buf_dis-gds-rule.pos-type  = p-pos-type
            AND buf_dis-gds-rule.discnt-role = p-discnt-role
            no-error .
      if available buf_Dis-gds-rule then do:
        if p-nonunique = ''
        and available buf_dis-gds-rule
        then do:
          return error substitute("Скидка типа &1 на товар с кодом &2 &3&4 уже существует (детализ. &3)"
                                   , entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                                   , p-gds-code
                                   , buf_Dis-rule.obj-type
                                   , buf_Dis-rule.obj-code
                                   , p-nonunique
                                  ).
        end.
        if available buf_dis-gds-rule
        and buf_dis-gds-rule.nonunique = ''
        and p-nonunique <> ''then do:
          return error substitute("Скидка типа &1 на товар с кодом &2 &3&4 уже существует"
                                   , entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                                   , p-gds-code
                                   , buf_Dis-rule.obj-type
                                   , buf_Dis-rule.obj-code
                                  ).
        end.
      end.
      create buf_dis-gds-rule .
      assign
      buf_dis-gds-rule.gds-code  = p-gds-code
      buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
      buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
      buf_dis-gds-rule.pos-type = p-pos-type
      buf_dis-gds-rule.discnt-role = v-discnt-role
      buf_dis-gds-rule.rule-num = p-rule-num
      buf_dis-gds-rule.nonunique = p-nonunique
      no-error
      .
    end.
    ASSIGN
    buf_dis-gds-rule.rule-num = p-rule-num
    buf_dis-gds-rule.rl-root = buf_Dis-rule.rl-root
    buf_dis-gds-rule.time-templ-rl-root = p-time-templ-rl-root
    buf_dis-gds-rule.templ-rl-root = p-templ-rl-root
    buf_dis-gds-rule.nonunique = p-nonunique
    no-error.
  end.
end procedure.
PROCEDURE cmp-disgdsru-write :
do
on error undo, return error
:
  define input parameter p-gds-code like ub.dis-gds-rule.gds-code   no-undo .
  define input parameter p-obj-type like ub.dis-gds-rule.obj-type   no-undo .
  define input parameter p-obj-code like ub.dis-gds-rule.obj-code   no-undo .
  define input parameter p-pos-type like ub.dis-gds-rule.pos-type   no-undo .
  define input parameter p-templ-rl-root     like ub.dis-gds-rule.templ-rl-root  no-undo .
  define input parameter p-time-templ-rl-root     like ub.dis-gds-rule.time-templ-rl-root  no-undo .
  define input parameter p-discnt-role like ub.dis-gds-rule.discnt-role no-undo .
  define input parameter p-rule-num    like ub.dis-gds-rule.rule-num no-undo .
  define input parameter p-nonunique like ub.dis-gds-rule.nonunique no-undo .
  define variable v-rule-label          as character no-undo .
  define buffer buf_tt0-dis-gds-rule for ub.dis-gds-rule .
  define buffer buf_dis-rule     for ub.dis-rule.
  run disgdsru-name in this-procedure (
                                      input  p-templ-rl-root
                                      ,output v-rule-label
                                      ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.
  find first buf_tt0-dis-gds-rule exclusive-lock where
              buf_tt0-dis-gds-rule.gds-code  = p-gds-code
          AND buf_tt0-dis-gds-rule.obj-type  = p-obj-type
          AND buf_tt0-dis-gds-rule.obj-code  = p-obj-code
          AND buf_tt0-dis-gds-rule.pos-type  = p-pos-type
          AND buf_tt0-dis-gds-rule.discnt-role = p-discnt-role
          AND buf_tt0-dis-gds-rule.nonunique = p-nonunique
          no-error .
  if not available buf_tt0-dis-gds-rule then do:
    create buf_tt0-dis-gds-rule .
    assign
    buf_tt0-dis-gds-rule.gds-code  = p-gds-code
    buf_tt0-dis-gds-rule.obj-type  = p-obj-type
    buf_tt0-dis-gds-rule.obj-code  = p-obj-code
    buf_tt0-dis-gds-rule.pos-type  = p-pos-type
    buf_tt0-dis-gds-rule.nonunique = p-nonunique
    buf_tt0-dis-gds-rule.discnt-role = p-discnt-role
    no-error
    .
  end.
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-rule-num.
  ASSIGN
  buf_tt0-dis-gds-rule.templ-rl-root = p-templ-rl-root
  buf_tt0-dis-gds-rule.rule-num = p-rule-num
  buf_tt0-dis-gds-rule.time-templ-rl-root = p-time-templ-rl-root
  buf_tt0-dis-gds-rule.nonunique = p-nonunique
  buf_tt0-dis-gds-rule.templ-rl-root = p-templ-rl-root
  buf_tt0-dis-gds-rule.rl-root = buf_Dis-rule.rl-root
  no-error.
  release buf_tt0-dis-gds-rule no-error .
  if error-status:error then do:
    undo, return error return-value .
  end.
end.
END PROCEDURE.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def shared temp-table bb-list no-undo like ub.goods
  field b-code as integer
  field b-str  as character
  field f-name like ub.gds-prt.f-name
  field bc-cli-base-rate like ub.bar-code.cli-base-rate
  field bc-cr-db-num     like ub.bar-code.cr-db-num
  field in-code       like ub.bar-code.in-code
  field node-code     like ub.bar-code.node-code
  field part-code     like ub.bar-code.part-code
  field stts_         like ub.bar-code.stts_
  field bc-unit-cli      like ub.bar-code.unit-cli
  field bc-on-type    like ub.prod-bc.bc-on-type
  field bc-on         like ub.prod-bc.bc-on
  field pbc-cr-db-num     like ub.prod-bc.cr-db-num
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field loc-ean as logical
  index pi  is primary unique b-code b-str
  index art artic prod-type prod-code
  index code gds-code
  index oi order-num
  index ibc-on-type bc-on-type
  index iprt
  gds-code
  node-code
  part-code
  in-code
  unit-cli
  b-str
  index iprt2
  gds-code
  node-code
  unit-cli
  part-code
  in-code
  b-str
  .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table bb-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
def new shared var bc-frmt as character no-undo .
def new shared var bc-pfx  as character no-undo .
def var bc-par-type as character no-undo .
    run gbl/conf-rd.p ("bc-frmt", "", "", 0, "", "", "",  no , output bc-frmt, output bc-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR bc-par-type <> "C":U OR not can-do ("EAN8,EAN13", bc-frmt) ) then
        do:
            message "Не задан или не верно задан ТИП собственного бар-кода!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
    run gbl/conf-rd.p ("bc-pfx", "", "", 0, "", "", "",  no , output bc-pfx, output bc-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR bc-par-type <> "C":U ) then
        do:
            message "Не задан или не верно задан ПРЕФИКС бар-кода складского места!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
PROCEDURE gen-bc:
  def input  parameter internal-b-code like ub.bar-code.b-code no-undo .
  def output parameter full-b-code     as character init ""    no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str10  as character no-undo.
  define variable tmp-num10  as character no-undo.
  define variable i10        as integer   no-undo.
  define variable sum10      as integer   no-undo.
  define variable len-code10 as integer   no-undo.
  define variable varcont10  as logical   initial yes no-undo.
  CASE bc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str10 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str10 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " bc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont10 = yes then do:
    if integer( substring( tmp-str10, 1, length( bc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = bc-pfx + substring( tmp-str10, length( bc-pfx ) + 1, length( tmp-str10 ) - length( bc-pfx ) )
        len-code10    = length( full-b-code )
      .
      define variable v-sum-char10 as character no-undo .
      assign
        sum10 = 0
      .
      do i10 = 1 to len-code10 by 2
      :
        assign
          v-sum-char10 = substr(full-b-code, len-code10 - i10 + 1, 1)
        .
        if v-sum-char10 < "0"
        or v-sum-char10 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum10 = sum10 + integer(v-sum-char10)
        .
      end.
      if varcont10 = yes then do:
        assign
          sum10 = sum10 * 3
        .
        do i10 = 2 to len-code10 by 2
        :
          assign
            v-sum-char10 = substr(full-b-code, len-code10 - i10 + 1, 1)
          .
          if v-sum-char10 < "0"
          or v-sum-char10 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum10 = sum10 + integer(v-sum-char10)
          .
        end.
        if varcont10 = yes then do:
           if sum10 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum10 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
END PROCEDURE.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cr_dis-gds-rule-attr :
def input parameter v-recid-rule-gds as int no-undo .
def buffer buf_dis-gds-rule-attr for dis-gds-rule-attr .
def buffer buf_dis-gds-rule for dis-gds-rule .
def buffer buf_bar-code for ub.bar-code .
def buffer buf_prod-bc  for prod-bc .
def buffer buf_templ-dis-rule for dis-rule .
def buffer buf_templ-dis-time-rule for dis-time-rule .
def buffer buf_dis-cfg-rule   for dis-cfg-rule .
def buffer buf_dis-rule   for dis-rule .
define variable v-upd as character no-undo .
define variable v-number-action as character no-undo .
define variable v-bar-code as character no-undo .
find buf_dis-gds-rule no-lock where recid(buf_dis-gds-rule) = v-recid-rule-gds  no-error.
if avail buf_dis-gds-rule then
do:
  find first buf_dis-rule no-lock where buf_dis-rule.rule-num = buf_dis-gds-rule.rule-num  no-error .
  find first buf_templ-dis-rule no-lock where buf_templ-dis-rule.rule-num = buf_dis-rule.templ-rl-root  no-error .
  if avail buf_templ-dis-rule and avail buf_dis-rule then
  do:
     find first buf_dis-cfg-rule no-lock where
                buf_dis-cfg-rule.table-name = "dis-gds-rule"
            and buf_dis-cfg-rule.pos-type = buf_dis-gds-rule.pos-type
            and buf_dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
            and buf_dis-cfg-rule.time-templ-rl-root =  buf_dis-rule.time-templ-rl-root
            and buf_dis-cfg-rule.self-nonunique = ""
            and buf_dis-cfg-rule.nonunique = "bar-code.b-code"
            no-error.
     if avail buf_dis-cfg-rule then
     do:
       find first buf_bar-code no-lock where buf_bar-code.b-code = integer(buf_dis-gds-rule.nonunique) no-error.
       if avail buf_bar-code then
       do:
          run gen-bc(input buf_bar-code.b-code,output v-bar-code) .
          for each buf_prod-bc no-lock where buf_prod-bc.b-code = buf_bar-code.b-code :
            if buf_prod-bc.bc-on = yes then
            do:
               v-upd = 'A' .
            end.
            else
            do:
               v-upd = "D" .
            end.
            find first  buf_dis-gds-rule-attr WHERE
                buf_dis-gds-rule-attr.gds-code = buf_dis-gds-rule.gds-code
            AND buf_dis-gds-rule-attr.obj-type = buf_dis-gds-rule.obj-type
            AND buf_dis-gds-rule-attr.obj-code = buf_dis-gds-rule.obj-code
            AND buf_dis-gds-rule-attr.pos-type = buf_dis-gds-rule.pos-type
            AND buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
            and buf_dis-gds-rule-attr.nonunique = buf_dis-gds-rule.nonunique
            and entry(1,buf_dis-gds-rule-attr.attr-value,",") = buf_prod-bc.b-str
                 exclusive-lock no-error .
            if (not avail buf_dis-gds-rule-attr) and (not locked buf_dis-gds-rule-attr) then
            do:
                if v-upd = "A" then
                do:
                    run def-number-action(buf_templ-dis-rule.rule-num,output v-number-action) .
                    create buf_dis-gds-rule-attr .
                    assign
                     buf_dis-gds-rule-attr.gds-code = buf_dis-gds-rule.gds-code
                     buf_dis-gds-rule-attr.obj-type = buf_dis-gds-rule.obj-type
                     buf_dis-gds-rule-attr.obj-code = buf_dis-gds-rule.obj-code
                     buf_dis-gds-rule-attr.pos-type = buf_dis-gds-rule.pos-type
                     buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
                     buf_dis-gds-rule-attr.nonunique = buf_dis-gds-rule.nonunique
                     buf_dis-gds-rule-attr.attr-code = v-number-action
                     buf_dis-gds-rule-attr.attr-value = buf_prod-bc.b-str + "," + v-upd
                    .
                end.
            end.
            else
            do:
              if avail buf_dis-gds-rule-attr and  buf_dis-gds-rule-attr.attr-value <> v-upd then
              do:
               assign
                buf_dis-gds-rule-attr.attr-value = buf_prod-bc.b-str + "," + v-upd
                .
              end.
            end.
          end.
          if v-bar-code <> '' then
          do:
            find first  buf_dis-gds-rule-attr WHERE
                buf_dis-gds-rule-attr.gds-code = buf_dis-gds-rule.gds-code
            AND buf_dis-gds-rule-attr.obj-type = buf_dis-gds-rule.obj-type
            AND buf_dis-gds-rule-attr.obj-code = buf_dis-gds-rule.obj-code
            AND buf_dis-gds-rule-attr.pos-type = buf_dis-gds-rule.pos-type
            AND buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
            and buf_dis-gds-rule-attr.nonunique = buf_dis-gds-rule.nonunique
            and entry(1,buf_dis-gds-rule-attr.attr-value,",") = v-bar-code
                 exclusive-lock no-error .
            if not avail buf_dis-gds-rule-attr  then
            do:
                    run def-number-action(buf_templ-dis-rule.rule-num,output v-number-action) .
                    create buf_dis-gds-rule-attr .
                    assign
                     buf_dis-gds-rule-attr.gds-code = buf_dis-gds-rule.gds-code
                     buf_dis-gds-rule-attr.obj-type = buf_dis-gds-rule.obj-type
                     buf_dis-gds-rule-attr.obj-code = buf_dis-gds-rule.obj-code
                     buf_dis-gds-rule-attr.pos-type = buf_dis-gds-rule.pos-type
                     buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
                     buf_dis-gds-rule-attr.nonunique = buf_dis-gds-rule.nonunique
                     buf_dis-gds-rule-attr.attr-code = v-number-action
                     buf_dis-gds-rule-attr.attr-value = v-bar-code + "," + "A"
                    .
            end.
          end.
          for each  buf_dis-gds-rule-attr WHERE
                buf_dis-gds-rule-attr.gds-code = buf_dis-gds-rule.gds-code
            AND buf_dis-gds-rule-attr.obj-type = buf_dis-gds-rule.obj-type
            AND buf_dis-gds-rule-attr.obj-code = buf_dis-gds-rule.obj-code
            AND buf_dis-gds-rule-attr.pos-type = buf_dis-gds-rule.pos-type
            AND buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
            and buf_dis-gds-rule-attr.nonunique = buf_dis-gds-rule.nonunique
                  :
             find first buf_prod-bc no-lock where
                  buf_prod-bc.b-str = entry(1,buf_dis-gds-rule-attr.attr-value,",")
                     and can-find(first buf_bar-code where buf_bar-code.b-code = int(buf_dis-gds-rule.nonunique))
                     no-error.
             if not avail buf_prod-bc or (avail buf_prod-bc and buf_prod-bc.bc-on = no) then
             do:
               if entry(1,buf_dis-gds-rule-attr.attr-value,",") <> v-bar-code then
               do:
                 v-upd = "D" .
                 if buf_dis-gds-rule-attr.attr-value <> v-upd then
                 do:
                   assign
                   buf_dis-gds-rule-attr.attr-value = buf_prod-bc.b-str + "," + v-upd
                   .
                 end.
               end.
             end.
          end.
       end.
     end.
  end.
end.
end procedure .
procedure def-number-action :
  define input  parameter p-templ-rl-root as int no-undo .
  define output parameter p-number-action as char no-undo .
  define variable v-action as integer   no-undo .
  def buffer buf_dis-rule-attr for dis-rule-attr .
  find first buf_dis-rule-attr exclusive-lock where buf_dis-rule-attr.rule-num = p-templ-rl-root
                                       and buf_dis-rule-attr.attr-code =  "NCR bonus-qnty"
                                       no-error.
  if not avail buf_dis-rule-attr then
  do:
    create buf_dis-rule-attr .
    assign
       buf_dis-rule-attr.rule-num = p-templ-rl-root
       buf_dis-rule-attr.attr-code =  "NCR bonus-qnty"
       buf_dis-rule-attr.attr-value = "3100101"
       p-number-action = buf_dis-rule-attr.attr-value
       .
  end.
  else
  do:
     v-action = integer(buf_dis-rule-attr.attr-value) no-error .
     if error-status:error = no then
     do:
       assign
          v-action = v-action + 1
          buf_dis-rule-attr.attr-value = string(v-action)
          p-number-action = buf_dis-rule-attr.attr-value
          .
     end.
  end.
end procedure.
define variable p-obj-type like ub.clients.obj-type no-undo .
define variable p-obj-code like ub.clients.obj-code no-undo .
define variable pardelete-ok as logical no-undo .
define variable p-list-name as character no-undo .
DEFINE VARIABLE var-object as character no-undo init 'dis-gds-rule':U.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION CIntBinS RETURNS CHARACTER(input vl_int as integer):
def var vl_bin as char no-undo init "".
if vl_int < 0 OR vl_int = ? then return ?.
do while vl_int > 0:
  assign
  vl_bin = (if vl_int modulo 2 = 0
              then "0":U
              else "1":U) + vl_bin
  vl_int = truncate(vl_int / 2,0).
end.
return fill( "0":U, 32 - length(vl_bin)) + vl_bin .
END FUNCTION.
FUNCTION BinMask RETURNS LOGICAL(input vl_int as integer,
                                 input vl_binm as character):
DEFINE VARIABLE vl_bin as character no-undo.
DEFINE VARIABLE ii as integer no-undo.
DEFINE VARIABLE ii-len as integer no-undo.
DEFINE VARIABLE ii-lenm as integer no-undo.
DEFINE VARIABLE mchar as character no-undo.
DEFINE VARIABLE ichar as character no-undo.
if vl_binm = ? then return ?.
vl_bin = CIntBinS(vl_int).
if vl_bin = ? then return ?.
assign
vl_binm = LEFT-TRIM(vl_binm, "X":U)
ii-lenm = LENGTH(vl_binm)
ii-len = LENGTH(vl_bin) - ii-lenm
.
if II-LENM > 32 THEN RETURN ?.
DO II = 1 to II-LENm:
  assign
  mchar = SUBSTR(vl_binm, ii, 1)
  ichar = SUBSTR(vl_bin, ii + ii-len, 1)
  .
  IF not (MCHAR = "0":u or MCHAR = "1":u or MCHAR = "X":u) then return ?.
  IF ichar <> mchar AND mchar <> "X":U then return no.
END.
return yes.
END FUNCTION.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define SHARED temp-table temp-disc no-undo
field rule-num as integer
field host-code as integer
field obj-type as character
field obj-code as integer
field templ-rl-root as integer
field time-templ-rl-root as integer
field discnt-role as character
field nonunique as character
field cfg-nonunique as character
field pos-type as character
field action as logical
field label_ as character
index pi is  unique primary
pos-type discnt-role nonunique host-code obj-type obj-code action ASCENDING
index action
action
index ipos
pos-type discnt-role
.
procedure temp-dsc-value :
define input  parameter p-pos-type  as character  no-undo .
define input  parameter p-templ-rl-root as integer  no-undo .
define input  parameter p-time-templ-rl-root as integer no-undo .
define input  parameter p-discnt-role  as character  no-undo .
define input  parameter p-cfg-nonunique as character no-undo .
define input  parameter p-host-code as integer no-undo .
define input  parameter p-obj-type  as character no-undo .
define input  parameter p-obj-code as integer no-undo .
define input  parameter p-0mode as character no-undo .
define input  parameter p-mode      as character no-undo .
define input  parameter p-rec as recid no-undo .
define output parameter p-rule-num    as integer no-undo .
define output parameter p-nonunique   as character no-undo .
define buffer buf_temp-disc for temp-disc .
define variable v-discnt-role as character no-undo .
define variable v-rule-num as integer no-undo .
define variable v-nonunique as character no-undo .
define variable v-templ-rl-root as integer no-undo .
define variable v-time-templ-rl-root as integer no-undo .
define variable v-setted         as logical   no-undo .
define variable choice as integer no-undo .
do
on error undo, return error
:
  case var-object:
    when 'dis-gds-rule':U
    then do:
      run discfgru-check  in this-procedure (
                                               input 'dis-gds-rule':U
                                              ,input p-templ-rl-root
                                              ,input p-time-templ-rl-root
                                              ,input p-pos-type
                                              ,output v-discnt-role) no-error.
    end.
    when 'dis-dc-rule':U then do:
      run discfgru-check  in this-procedure (
                                               input 'dis-dc-rule':U
                                              ,input p-templ-rl-root
                                              ,input p-time-templ-rl-root
                                              ,input p-pos-type
                                              ,output v-discnt-role) no-error.
    end.
    when 'dis-cp-rule':U then do:
      run discfgru-check  in this-procedure (
                                               input 'dis-cp-rule':U
                                              ,input p-templ-rl-root
                                              ,input p-time-templ-rl-root
                                              ,input p-pos-type
                                              ,output v-discnt-role) no-error.
    end.
    otherwise do:
      undo, return error .
    end.
  end case.
  if error-status :error
  then do:
    undo, return error return-value .
  end.
  if p-mode = "change":U
  then do:
    if p-rec <> ? then do:
      find first buf_temp-disc no-lock where
            recid(buf_temp-disc) = p-rec
        no-error .
    end.
    else do:
      find first buf_temp-disc no-lock where
                buf_temp-disc.pos-type = p-pos-type
            and buf_temp-disc.discnt-role = p-discnt-role
            and buf_temp-disc.nonunique  = p-nonunique
            and buf_temp-disc.host-code = p-host-code
            and buf_temp-disc.obj-type = p-obj-type
            and buf_temp-disc.obj-code = p-obj-code
        no-error .
    end.
    if avail buf_temp-disc then do:
      assign
      v-rule-num =  buf_temp-disc.rule-num
      v-nonunique = buf_temp-disc.nonunique
      v-templ-rl-root = buf_temp-disc.templ-rl-root
      v-time-templ-rl-root = buf_temp-disc.time-templ-rl-root
      .
    end.
  end.
  CASE var-object:
  END CASE.
  if v-setted = no then do:
    return "not-set":U.
  end.
  p-rule-num = v-rule-num.
  p-nonunique = v-nonunique.
end.
end procedure.
procedure temp-dsc-write :
  do
  on error undo, return error
  :
    define input parameter p-add      as logical no-undo .
    define input parameter p-pos-type as character  no-undo .
    define input parameter p-templ-rl-root as integer  no-undo .
    define input parameter p-time-templ-rl-root as integer  no-undo .
    define input parameter p-discnt-role as character  no-undo .
    define input parameter p-cfg-nonunique as character no-undo .
    define input parameter p-host-code as integer no-undo .
    define input parameter p-obj-type as character no-undo .
    define input parameter p-obj-code as integer no-undo .
    define input parameter p-rule-num  as integer no-undo .
    define input parameter p-action   like temp-disc.action no-undo .
    define input-output parameter p-rec as recid no-undo .
    define buffer buf_temp-disc for temp-disc .
    define variable v-discnt-role as character no-undo .
    define variable varhost-code like ub.clients.host-code no-undo.
    define variable varobj-type like ub.clients.obj-type no-undo.
    define variable varobj-code like ub.clients.obj-code no-undo.
    define variable choice as integer no-undo .
    define var loc#log as logical no-undo.
    define variable loc-action as logical no-undo.
    define variable v-nonunique as character no-undo .
    define buffer buf_dis-rule for ub.dis-rule.
    case var-object:
      when 'dis-gds-rule':U
      then do:
        run discfgru-check  in this-procedure (
                                                input 'dis-gds-rule':U
                                               ,input p-templ-rl-root
                                               ,input p-time-templ-rl-root
                                               ,input p-pos-type
                                               ,output v-discnt-role) no-error.
      end.
      when 'dis-dc-rule':U
      then do:
        run discfgru-check  in this-procedure (
                                                input 'dis-dc-rule':U
                                               ,input p-templ-rl-root
                                               ,input p-time-templ-rl-root
                                               ,input p-pos-type
                                               ,output v-discnt-role) no-error.
      end.
      when 'dis-cp-rule':U
      then do:
        run discfgru-check  in this-procedure (
                                                input 'dis-cp-rule':U
                                               ,input p-templ-rl-root
                                               ,input p-time-templ-rl-root
                                               ,input p-pos-type
                                               ,output v-discnt-role) no-error.
      end.
      otherwise do:
        undo, return error .
      end.
    END CASE.
    if error-status :error then do:
      undo, return error return-value .
    end.
    if p-cfg-nonunique <> '':U
    and p-rule-num <> 0
    and p-rule-num <> ?
    then do:
      find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-rule-num no-error.
      if not available buf_dis-rule then do:
        undo, return error substitute("Не найдено правило скидок &1", p-rule-num).
      end.
      assign
      v-nonunique = (if p-cfg-nonunique = '':U
                    then '':U
                    else (if p-cfg-nonunique begins "@"
                          then left-trim(p-cfg-nonunique, "@")
                          else string(buffer buf_Dis-rule:handle:buffer-field(p-cfg-nonunique):buffer-value)
                          ))
      .
    end.
    if p-rec <> ? then do:
      find first buf_temp-disc exclusive-lock where
                recid(buf_temp-disc) = p-rec no-error .
    end.
    else do:
      find first buf_temp-disc exclusive-lock where
                buf_temp-disc.pos-type = p-pos-type
              and buf_temp-disc.discnt-role = p-discnt-role
              and buf_temp-disc.host-code = p-host-code
              and buf_temp-disc.obj-type = p-obj-type
              and buf_temp-disc.obj-code = p-obj-code
              and buf_temp-disc.nonunique = v-nonunique
              no-error .
    end.
    if not available buf_temp-disc then do:
      create buf_temp-disc .
      assign
      buf_temp-disc.host-code = p-host-code
      buf_temp-disc.obj-type = p-obj-type
      buf_temp-disc.obj-code = p-obj-code
      buf_temp-disc.rule-num = p-rule-num
      buf_temp-disc.action = p-action
      buf_temp-disc.pos-type = p-pos-type
      buf_temp-disc.discnt-role = p-discnt-role
      buf_temp-disc.cfg-nonunique = p-cfg-nonunique
      buf_temp-disc.rule-num = p-rule-num
      buf_temp-disc.nonunique = v-nonunique
      buf_temp-disc.time-templ-rl-root = p-time-templ-rl-root
      buf_temp-disc.templ-rl-root = p-templ-rl-root
      p-rec = recid(buf_temp-disc)
      no-error
      .
    end.
    ELSE do:
      if p-add then do:
         message
         substitute("Такая скидка уже добавлена&1"
                    ,chr(10)
                )
         view-as alert-box error .
        undo, return error "not-set" .
      end.
      ASSIGN
      buf_temp-disc.rule-num = p-rule-num
      buf_temp-disc.nonunique = v-nonunique
      buf_temp-disc.time-templ-rl-root = p-time-templ-rl-root
      buf_temp-disc.templ-rl-root = p-templ-rl-root
      p-rec = recid(buf_temp-disc)
      no-error.
    end.
  end.
end procedure.
procedure temp-dsc-exist :
define input parameter p-pos-type as character  no-undo .
define input parameter p-templ-rl-root as integer  no-undo .
define input parameter p-time-templ-rl-root as integer no-undo .
define input parameter p-discnt-role as character  no-undo .
define input parameter p-nonunique as character no-undo .
define input parameter p-host-code as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define output parameter p-exist    as logical no-undo .
define output parameter p-action as logical no-undo .
define variable v-discnt-role as character no-undo .
define buffer buf_temp-disc for temp-disc .
  do
  on error undo, return error
  :
    case var-object:
      when 'dis-gds-rule':U then do:
        run discfgru-check  in this-procedure (
                                                input 'dis-gds-rule':U
                                               ,input p-templ-rl-root
                                               ,input p-time-templ-rl-root
                                               ,input p-pos-type
                                               ,output v-discnt-role) no-error.
      end.
      when 'dis-dc-rule':U then do:
        run discfgru-check  in this-procedure (
                                                input 'dis-dc-rule':U
                                               ,input p-templ-rl-root
                                               ,input p-time-templ-rl-root
                                               ,input p-pos-type
                                               ,output v-discnt-role) no-error.
      end.
      otherwise do:
        undo, return error .
      end.
    end case.
    if error-status :error
    then do:
      undo, return error return-value .
    end.
    find first buf_temp-disc no-lock where
               buf_temp-disc.pos-type = p-pos-type
            and buf_temp-disc.discnt-role = p-discnt-role
            and buf_temp-disc.host-code = p-host-code
            and buf_temp-disc.obj-type = p-obj-type
            and buf_temp-disc.obj-code = p-obj-code
            and buf_temp-disc.nonunique = p-nonunique no-error .
    if available buf_temp-disc then do:
      P-EXIST = YES.
      p-action = buf_temp-disc.action.
    end.
  end.
end procedure.
procedure temp-dsc-delete :
define input parameter p-pos-type as character  no-undo .
define input parameter p-discnt-role as character no-undo .
define input parameter p-nonunique as character no-undo .
define input parameter p-host-code  as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-action as logical no-undo .
define output parameter p-deleted  as logical no-undo .
define buffer buf_temp-disc for temp-disc .
  do
  on error undo, return error :
    case var-object:
      when 'dis-gds-rule':U
      then do:
        error-status:error = no.
      end.
      when 'dis-dc-rule':U
      then do:
        error-status:error = no.
      end.
      when 'dis-cp-rule':U
      then do:
        error-status:error = no.
      end.
      otherwise do:
        undo, return error .
      end.
    END CASE.
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_temp-disc exclusive-lock where
               buf_temp-disc.pos-type = p-pos-type
           and buf_temp-disc.discnt-role = p-discnt-role
           and buf_temp-disc.host-code = p-host-code
           and buf_temp-disc.obj-type = p-obj-type
           and buf_temp-disc.obj-code = p-obj-code
           and buf_temp-disc.nonunique = p-nonunique
           and buf_temp-disc.action = p-action
           no-error .
    if not available buf_temp-disc then do:
      P-DELETED = NO.
    end.
    ELSE DO:
       delete buf_temp-disc.
       P-DELETED = YES.
    END.
  end.
end procedure.
define variable v-no-ask as logical no-undo .
define variable v-view-log as logical no-undo .
define variable log-file-name                as character      no-undo init "dgr-lst.txt".
define variable v-stop                       as logical        no-undo .
define variable v-choice as integer no-undo .
DEFINE VARIABLE num-rec as integer no-undo .
DEFINE VARIABLE num-rec-ok as integer no-undo .
define variable v-mes as character no-undo .
define variable v-ok as logical no-undo .
define variable loc-glob as logical no-undo.
define variable loc-firm as logical no-undo.
define variable loc-object as logical no-undo.
assign
p-obj-type  = entry(1, p-parameter, chr(4))
p-obj-code = integer(entry(2, p-parameter, chr(4)))
pardelete-ok = logical(entry(3, p-parameter, chr(4)))
p-list-name = entry(4, p-parameter, chr(4))
no-error
.
if error-status:error then do:
 run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , chr(10)
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При изменении скидок товара на объекте по списку товаров произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action15   as character no-undo .
  define variable v-printed15       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При изменении скидок товара на объекте по списку товаров произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'dgr-lst.txt')
    ,input  7
    ,output v-user-action15
    ,output v-printed15
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'dgr-lst.txt').
end.
  return .
end.
run write-log  in p-log-handle(
                                 input 0
                               , "&DLine").
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Изменение скидок товара на объекте &1&2 по списку товаров", p-obj-type, p-obj-code)).
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if p-list-name = "gds-list" then do:
  _gds-list:
  for each gds-list
    ON ERROR undo, NEXT:
      num-rec = num-rec + 1.
      v-ok = false.
      run check-actg in this-procedure (
                                        input gds-list.grp-code
                                        ,input gds-list.gds-code
                                        ,output v-ok ) no-error.
      if v-ok = true then do :
          run do-changes in this-procedure (
                                    input gds-list.gds-code
                                    ,input p-obj-type
                                    ,input p-obj-code) no-error .
      end.
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input return-value
                                            ).
        assign
        v-view-log = yes.
        if v-no-ask  then do:
          run gbl/d-askw.w (
                        input "Изменение скидок товара на объекте по списку товаров"
                        ,input substitute("Товар с кодом &1 &2&3 - не удалось провести изменение скидок товара на объекте"
                                        , gds-list.gds-code
                                        , p-obj-type
                                        , p-obj-code
                                        )
                        ,input "|"
                        ,input ("Продолжить|" +
                              "Продолжить и больше не запрашивать подтверждения на продолжение|" +
                              "Прекратить")
                        ,input "||"
                        ,input 1
                        ,input 3
                        ,output v-choice).
          if v-choice = 3 then do:
            leave.
          end.
          if v-choice = 2 then do:
            assign
            v-no-ask = yes.
          end.
        end.
      end.
      else do:
        num-rec-ok = num-rec-ok + 1.
        if pardelete-ok then delete gds-list.
      end.
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Обработано &1 из них успешно &2"
                                                  , num-rec
                                                  , num-rec-ok
                                                  )) no-error.
      run get-stop-state in p-log-handle (
          output v-stop
      ).
      if v-stop then do:
        leave _gds-list.
      end.
  END.
end.
if p-list-name = "bb-list" then do:
  _bb-list:
  for each bb-list no-lock
  group by bb-list.b-code
    ON ERROR undo, NEXT:
      if not first-of(bb-list.b-code) then next _bb-list .
      num-rec = num-rec + 1.
      v-ok = false.
      run check-actg in this-procedure (
                                        input bb-list.grp-code
                                        ,input bb-list.gds-code
                                        ,output v-ok ) no-error.
      if v-ok = true then do :
            run do-changes-bb in this-procedure (
                                          input bb-list.gds-code
                                          ,input bb-list.b-code
                                          ,input p-obj-type
                                          ,input p-obj-code) no-error .
      end.
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input return-value
                                            ).
        assign
        v-view-log = yes.
        if v-no-ask  then do:
          run gbl/d-askw.w (
                        input "Изменение скидок товара на объекте по списку бар-кодов"
                        ,input substitute("Товар с кодом &1 бар-код &2 &3&4 - не удалось провести изменение скидок товара на объекте"
                                        , bb-list.gds-code
                                        , bb-list.b-code
                                        , p-obj-type
                                        , p-obj-code
                                        )
                        ,input "|"
                        ,input ("Продолжить|" +
                              "Продолжить и больше не запрашивать подтверждения на продолжение|" +
                              "Прекратить")
                        ,input "||"
                        ,input 1
                        ,input 3
                        ,output v-choice).
          if v-choice = 3 then do:
            leave.
          end.
          if v-choice = 2 then do:
            assign
            v-no-ask = yes.
          end.
        end.
      end.
      else do:
        num-rec-ok = num-rec-ok + 1.
        if pardelete-ok then delete bb-list.
      end.
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Обработано &1 из них успешно &2"
                                                  , num-rec
                                                  , num-rec-ok
                                                  )) no-error.
      run get-stop-state in p-log-handle (
          output v-stop
      ).
      if v-stop then do:
        leave _bb-list.
      end.
  END.
end.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Пакетное изменение скидок по списку завершено: из &1 элементов списка успешно изменено &2", num-rec, num-rec-ok )).
.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При изменении скидок товара на объекте по списку произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action18   as character no-undo .
  define variable v-printed18       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При изменении скидок товара на объекте по списку произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'dgr-lst.txt')
    ,input  7
    ,output v-user-action18
    ,output v-printed18
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'dgr-lst.txt').
end.
procedure do-changes :
define input parameter pargds-code like ub.gds-obj.gds-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE var-deleted as logical no-undo .
define variable v-check as character no-undo .
define variable v-correct as logical no-undo .
define variable v-error-code as character no-undo .
define variable v-rule-num as integer no-undo .
define variable v-obj-type like ub.clients.obj-type no-undo .
define variable v-obj-code like ub.clients.obj-code no-undo .
define variable v-host-code  as integer   no-undo .
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_del-dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-rule         for ub.dis-rule.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    _main:
  do
  on error undo, return error
  :
    _temp-disc:
    for each temp-disc no-lock
        on error undo _main, return error:
      find first buf_dis-rule no-lock where buf_dis-rule.rule-num = temp-disc.rule-num no-error.
      if avail buf_dis-rule then do:
          if buf_dis-rule.host-code = 0 then     assign v-obj-type = ''         v-obj-code = 0 .
          else if buf_dis-rule.obj-code = 0 then assign v-obj-type = 'орг':U     v-obj-code = v-host-code .
          else                                   assign v-obj-type = p-obj-type v-obj-code = p-obj-code .
      end.
      CASE temp-disc.action:
        when yes then do:
          if v-obj-type = p-obj-type then do:
          run disgdsru-write in this-procedure (
                                                 input p-obj-type
                                                ,input p-obj-code
                                                ,input pargds-code
                                                ,input temp-disc.pos-type
                                                ,input temp-disc.discnt-role
                                                ,input temp-disc.templ-rl-root
                                                ,input temp-disc.time-templ-rl-root
                                                ,input temp-disc.rule-num
                                                ,input temp-disc.nonunique
                                                    )  no-error.
          end.
          else do:
              run cmp-disgdsru-write in this-procedure (
                                                 input pargds-code
                                                ,input v-obj-type
                                                ,input v-obj-code
                                                ,input temp-disc.pos-type
                                                ,input temp-disc.templ-rl-root
                                                ,input temp-disc.time-templ-rl-root
                                                ,input temp-disc.discnt-role
                                                ,input temp-disc.rule-num
                                                ,input temp-disc.nonunique
                                                    )  no-error.
          end.
          if error-status:error then do:
            assign v-mes = substitute("товар с кодом &1, &2, POS &3, тип скидки &4: ошибка при записи скидки товара на объекте:&5&6&5&7"                      , gds-list.gds-code                    , (p-obj-type  + string(p-obj-code))                      , entry (lookup (temp-disc.pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U)                    , entry (lookup (temp-disc.discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)                   , chr(10)                        , error-status:get-message(1)                    , return-value ).
            undo _main, return error v-mes.
          end.
        end.
        when no then do:
          var-deleted = no.
          for each buf_dis-gds-rule no-lock where
                    ( buf_dis-gds-rule.obj-type = p-obj-type or buf_dis-gds-rule.obj-type = 'орг':U      or buf_dis-gds-rule.obj-type = '' )
                and ( buf_dis-gds-rule.obj-code = p-obj-code or buf_dis-gds-rule.obj-code = v-host-code or buf_dis-gds-rule.obj-code = 0 )
                and buf_dis-gds-rule.gds-code = pargds-code
                and buf_dis-gds-rule.pos-type = temp-disc.pos-type
                and buf_dis-gds-rule.discnt-role = temp-disc.discnt-role
                and ( if buf_dis-gds-rule.rule-num = temp-disc.rule-num then buf_dis-gds-rule.nonunique = temp-disc.nonunique else true )
          and buf_dis-gds-rule.time-templ-rl-root = temp-disc.time-templ-rl-root
          and buf_dis-gds-rule.templ-rl-root = temp-disc.templ-rl-root
          and (temp-disc.rule-num = ? or temp-disc.rule-num = 0 or buf_dis-gds-rule.rule-num = temp-disc.rule-num )
          :
            assign
            v-rule-num = buf_dis-gds-rule.rule-num
            .
            find first buf_del-dis-gds-rule exclusive-lock where
              recid(buf_del-dis-gds-rule) = recid(buf_dis-gds-rule)
            no-wait no-error.
            if not available buf_del-dis-gds-rule then do:
              undo _main, return error substitute( "Товар &1 &2 POS &3 шаблон правила &4, правило &5&6" +
                                                   "занята запись скидки на объекте"
                                                   , pargds-code
                                                   , (p-obj-type  + string(p-obj-code))
                                                   , entry (lookup (temp-disc.pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U)
                                                   , temp-disc.templ-rl-root
                                                   , v-rule-num
                                                   , chr(10)
                                                   ).
            end.
            delete buf_del-dis-gds-rule no-error.
            if error-status:error then do:
              assign v-mes = substitute("товар с кодом &1, &2, POS &3, тип скидки &4: ошибка при удалении скидки товара на объекте:&5&6&5&7"                    , gds-list.gds-code                    , (p-obj-type  + string(p-obj-code))                      , entry (lookup (temp-disc.pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U)                    , entry (lookup (temp-disc.discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)                   , chr(10)                        , error-status:get-message(1)                    , return-value ).
              undo _main, return error v-mes.
            end.
          end.
        end.
      END CASE.
    end.
  end.
end procedure.
procedure do-changes-bb :
define input parameter pargds-code like ub.gds-obj.gds-code no-undo .
define input parameter parb-code like ub.bar-code.b-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE var-deleted as logical no-undo .
define variable v-check as character no-undo .
define variable v-correct as logical no-undo .
define variable v-error-code as character no-undo .
define variable v-rule-num as integer no-undo .
define variable v-number-action as character no-undo .
define variable v-bar-code as character no-undo .
define variable v-obj-type like ub.clients.obj-type no-undo .
define variable v-obj-code like ub.clients.obj-code no-undo .
define variable v-host-code  as integer             no-undo .
define buffer buf_dis-rule          for ub.dis-rule.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_del-dis-gds-rule  for ub.dis-gds-rule.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_dis-gds-rule-attr for ub.dis-gds-rule-attr.
define buffer buf_bb-list           for bb-list.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    _main:
  do
  on error undo, return error
  :
    _temp-disc:
    for each temp-disc no-lock
        on error undo _main, return error:
      find first buf_dis-rule no-lock where buf_dis-rule.rule-num = temp-disc.rule-num no-error.
      if avail buf_dis-rule then do:
          if buf_dis-rule.host-code = 0 then     assign v-obj-type = ''         v-obj-code = 0 .
          else if buf_dis-rule.obj-code = 0 then assign v-obj-type = 'орг':U     v-obj-code = v-host-code .
          else                                   assign v-obj-type = p-obj-type v-obj-code = p-obj-code .
      end.
      CASE temp-disc.action:
        when yes then do:
          if v-obj-type = p-obj-type then do:
          run disgdsru-write in this-procedure (
                                                 input p-obj-type
                                                ,input p-obj-code
                                                ,input pargds-code
                                                ,input temp-disc.pos-type
                                                ,input temp-disc.discnt-role
                                                ,input temp-disc.templ-rl-root
                                                ,input temp-disc.time-templ-rl-root
                                                ,input temp-disc.rule-num
                                                ,input string(parb-code)
                                                    )  no-error.
          end.
          else do:
              run cmp-disgdsru-write in this-procedure (
                                                 input pargds-code
                                                ,input v-obj-type
                                                ,input v-obj-code
                                                ,input temp-disc.pos-type
                                                ,input temp-disc.templ-rl-root
                                                ,input temp-disc.time-templ-rl-root
                                                ,input temp-disc.discnt-role
                                                ,input temp-disc.rule-num
                                                ,input string(parb-code)
                                                    )  no-error.
          end.
          if error-status:error then do:
            assign v-mes = substitute("товар с кодом &1, &2, POS &3, тип скидки &4: ошибка при записи скидки товара на объекте:&5&6&5&7"                      , bb-list.gds-code                    , (p-obj-type  + string(p-obj-code))                      , entry (lookup (temp-disc.pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U)                    , entry (lookup (temp-disc.discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)                   , chr(10)                        , error-status:get-message(1)                    , return-value ).
            undo _main, return error v-mes.
          end.
          find first buf_dis-gds-rule no-lock where
                ( buf_dis-gds-rule.obj-type = v-obj-type )
            and ( buf_dis-gds-rule.obj-code = v-obj-code )
            and buf_dis-gds-rule.gds-code           = pargds-code
            and buf_dis-gds-rule.pos-type           = temp-disc.pos-type
            and buf_dis-gds-rule.discnt-role        = temp-disc.discnt-role
            and buf_dis-gds-rule.templ-rl-root      = temp-disc.templ-rl-root
            and buf_dis-gds-rule.time-templ-rl-root = temp-disc.time-templ-rl-root
            and buf_dis-gds-rule.rule-num           = temp-disc.rule-num
            and buf_dis-gds-rule.nonunique          = string(parb-code)
          no-error .
          if avail buf_dis-gds-rule then do:
               find first buf_dis-cfg-rule no-lock
               where buf_dis-cfg-rule.table-name    = 'dis-gds-rule':U
                 and buf_dis-cfg-rule.templ-rl-root = temp-disc.templ-rl-root
                 and buf_dis-cfg-rule.pos-type      = temp-disc.pos-type
                 and buf_dis-cfg-rule.time-templ-rl-root = temp-disc.time-templ-rl-root
               no-error .
               if avail buf_dis-cfg-rule and
                  buf_dis-cfg-rule.discnt-role = 'bonus-qnty' and
                  buf_dis-cfg-rule.nonunique   = 'bar-code.b-code'
               then do:
                 for each buf_bb-list no-lock where buf_bb-list.b-code = parb-code :
                   if buf_bb-list.b-str = '' then v-bar-code = string(buf_bb-list.b-code) .
                   else v-bar-code = buf_bb-list.b-str .
                   find first buf_dis-gds-rule-attr exclusive-lock
                   where buf_dis-gds-rule-attr.gds-code    = buf_dis-gds-rule.gds-code
                     and buf_dis-gds-rule-attr.obj-type    = buf_dis-gds-rule.obj-type
                     and buf_dis-gds-rule-attr.obj-code    = buf_dis-gds-rule.obj-code
                     and buf_dis-gds-rule-attr.pos-type    = buf_dis-gds-rule.pos-type
                     and buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
                     and buf_dis-gds-rule-attr.nonunique   = buf_dis-gds-rule.nonunique
                     and entry(1,buf_dis-gds-rule-attr.attr-value,",") = v-bar-code
                   no-error.
                   if not avail buf_dis-gds-rule-attr then do:
                      create buf_dis-gds-rule-attr .
                   end.
                      run def-number-action(temp-disc.templ-rl-root, output v-number-action) .
                      assign
                       buf_dis-gds-rule-attr.gds-code    = buf_dis-gds-rule.gds-code
                       buf_dis-gds-rule-attr.obj-type    = buf_dis-gds-rule.obj-type
                       buf_dis-gds-rule-attr.obj-code    = buf_dis-gds-rule.obj-code
                       buf_dis-gds-rule-attr.pos-type    = buf_dis-gds-rule.pos-type
                       buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
                       buf_dis-gds-rule-attr.nonunique   = buf_dis-gds-rule.nonunique
                       buf_dis-gds-rule-attr.attr-code   = v-number-action
                       buf_dis-gds-rule-attr.attr-value  = v-bar-code + ",A"
                      .
                 end.
               end.
          end.
        end.
        when no then do:
          var-deleted = no.
          for each buf_dis-gds-rule no-lock where
                    ( buf_dis-gds-rule.obj-type = p-obj-type or buf_dis-gds-rule.obj-type = 'орг':U      or buf_dis-gds-rule.obj-type = '' )
                and ( buf_dis-gds-rule.obj-code = p-obj-code or buf_dis-gds-rule.obj-code = v-host-code or buf_dis-gds-rule.obj-code = 0 )
                and buf_dis-gds-rule.gds-code = pargds-code
                and buf_dis-gds-rule.pos-type = temp-disc.pos-type
                and buf_dis-gds-rule.discnt-role = temp-disc.discnt-role
                and buf_dis-gds-rule.nonunique = string(parb-code)
          and buf_dis-gds-rule.time-templ-rl-root = temp-disc.time-templ-rl-root
          and buf_dis-gds-rule.templ-rl-root = temp-disc.templ-rl-root
          and (temp-disc.rule-num = ? or temp-disc.rule-num = 0 or buf_dis-gds-rule.rule-num = temp-disc.rule-num)
          :
            assign
            v-rule-num = buf_dis-gds-rule.rule-num
            .
            find first buf_del-dis-gds-rule exclusive-lock where
              recid(buf_del-dis-gds-rule) = recid(buf_dis-gds-rule)
            no-wait no-error.
            if not available buf_del-dis-gds-rule then do:
              undo _main, return error substitute( "Товар &1 бар-код &2 &3 POS &4 шаблон правила &5, правило &6&7" +
                                                   "занята запись скидки на объекте"
                                                   , pargds-code
                                                   , parb-code
                                                   , (p-obj-type  + string(p-obj-code))
                                                   , entry (lookup (temp-disc.pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U)
                                                   , temp-disc.templ-rl-root
                                                   , v-rule-num
                                                   , chr(10)
                                                   ).
            end.
            for each buf_dis-gds-rule-attr exclusive-lock
            where buf_dis-gds-rule-attr.gds-code    = buf_dis-gds-rule.gds-code
              and buf_dis-gds-rule-attr.obj-type    = buf_dis-gds-rule.obj-type
              and buf_dis-gds-rule-attr.obj-code    = buf_dis-gds-rule.obj-code
              and buf_dis-gds-rule-attr.pos-type    = buf_dis-gds-rule.pos-type
              and buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
              and buf_dis-gds-rule-attr.nonunique   = buf_dis-gds-rule.nonunique
            :
                delete buf_dis-gds-rule-attr no-error .
                if error-status:error then do:
                    assign v-mes = substitute("товар с кодом &1, &2, POS &3, тип скидки &4: ошибка при удалении атрибутов скидки товара на объекте:&5&6&5&7"                    , bb-list.gds-code                    , (p-obj-type  + string(p-obj-code))                      , entry (lookup (temp-disc.pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U)                    , entry (lookup (temp-disc.discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)                   , chr(10)                        , error-status:get-message(1)                    , return-value ).
                    undo _main, return error v-mes.
                end.
            end.
            delete buf_del-dis-gds-rule no-error.
            if error-status:error then do:
              assign v-mes = substitute("товар с кодом &1, &2, POS &3, тип скидки &4: ошибка при удалении скидки товара на объекте:&5&6&5&7"                    , bb-list.gds-code                    , (p-obj-type  + string(p-obj-code))                      , entry (lookup (temp-disc.pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U)                    , entry (lookup (temp-disc.discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)                   , chr(10)                        , error-status:get-message(1)                    , return-value ).
              undo _main, return error v-mes.
            end.
          end.
        end.
      END CASE.
    end.
  end.
end procedure.
procedure check-actg :
define input parameter p-grp-code as integer no-undo.
define input parameter p-gds-code as integer no-undo.
define output parameter p-ok as logical no-undo.
do
on error undo, return error
:
      if v-cntxt-db-num = 0 then do:
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_gds-discount_global_work':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  p-grp-code
    ,input  0
    ,input  false
    ,output loc-glob
    )  .
end.
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_gds-discount_firm_work':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  p-grp-code
    ,input  0
    ,input  false
    ,output loc-firm
    )  .
end.
      end.
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_gds-discount_object_work':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  p-grp-code
    ,input  0
    ,input  false
    ,output loc-object
    )  .
end.
      if ((if v-cntxt-db-num = 0 and loc-glob then 1 else 0) +
      (if v-cntxt-db-num = 0 and loc-firm then 1 else 0) +
      (if loc-object then 1 else 0)) <> 0 then do:
        p-ok = true.
      end.
      else do :
        find first gds-grp no-lock
             where gds-grp.node-code = p-grp-code no-error.
        v-mes = substitute("товар с кодом &1, &2,группа товаров &3 : У Вас отсутствуют права на назначение скидки на товар как по объекту,"
                          + "так и глобально либо Вы находитесь в БД, в которой их назначить невозможно"
                          , p-gds-code
                          , (p-obj-type  + string(p-obj-code))
                          , (string(gds-grp.node-code) + " " + gds-grp.node-name)
                          ).
         undo,return error v-mes.
      end.
end.
end procedure.
