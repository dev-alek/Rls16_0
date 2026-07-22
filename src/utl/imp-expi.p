block-level on error undo, throw.
/*

$Revision: 826c1485520b, 1287, rls $
$Author: EShklyar $
$Date: Tue Apr 10 12:02:59 2018 +0300 $
$Workfile: imp-expi.p $
$Archive: utl/imp-expi.p $

Процедура импорта локальных таблиц УБД
запускается как обычная утилита из системы
на момент запуска в БД уже должны завершиться все утилиты закачки бар-кодов и конфигурации

Автор: Бахтадзе Наталья Викторовна
Дата создания: 29/11/01
Author: Bakhtadze Natalya
Creation date: 29/11/01

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter as character no-undo .

/*p-parameter включает */
/*  /*какие группы данных импортировать*/                     */
/*  define input parameter p-rht as logical no-undo .         */
/*  define input parameter p-gen as logical no-undo .         */
/*  define input parameter p-flt as logical no-undo .         */
/*  define input parameter p-pbc as logical no-undo .         */
/*  define input parameter p-scl as logical no-undo .         */
/*  define input parameter p-usr as logical no-undo .         */
/*  define input parameter p-seq as logical no-undo .         */
/*  /*ключ БАЗЫ - он же имя файла без расширения*/            */
/*  define input parameter p-db-key as character no-undo .    */
/*  /*директория экспорта*/                                   */
/*  define input parameter p-dir-name as character no-undo .  */
/*  /*версия TH  в которой были экспортированы файлы*/        */
/*  define input parameter p-version as character no-undo .   */

define variable vss-revision    as character no-undo init "$Revision: 826c1485520b, 1287, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Apr 10 12:02:59 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-expi.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/imp-expi.p $":U .
define variable vss-description as character no-undo init "Процедура экспорта локальных таблиц УБД".
{ cmp/vssrevis.i }

define variable p-rht as logical no-undo .
define variable p-gen as logical no-undo .
define variable p-flt as logical no-undo .
define variable p-pbc as logical no-undo .
define variable p-scl as logical no-undo .
define variable p-usr as logical no-undo .
define variable p-seq as logical no-undo .
/*ключ БАЗЫ - он же имя файла без расширения*/
define variable p-db-key as character no-undo .
/*директория экспорта*/
define variable p-dir-name as character no-undo .
define variable p-version as character no-undo .
define variable p-glb as logical no-undo .

{ cmp/trg-def.i }
{ cmp/operfile.i }
define variable log-file-name as character no-undo init "imp-exp.log".
define variable v-view-log as logical no-undo .

{ utl/imp-expd.i }
{ utl/imp-expc.i }
{ cmp/getmcode.i ub }
{ trg/new-bcod.i }
{ ref/gdsoattr.i }

/*определяем два набора временных таблиц  чтобы смочь закачать даже дубли*/
/*проверять будем на втором этапе - перекачки из temp-table в БД*/

define temp-table temp-sys-ctrl  NO-UNDO LIKE ub.sys-ctrl.
define temp-table temp-config  NO-UNDO LIKE ub.config.
define temp-table temp-prod-bc no-undo LIKE ub.prod-bc.
define temp-table temp-gds-obj-attr no-undo LIKE ub.gds-obj-attr.
define temp-table temp-scales  NO-UNDO LIKE ub.scales.
define temp-table temp-scales-gds  NO-UNDO LIKE ub.scales-gds.
define temp-table temp-scales-grp  NO-UNDO LIKE ub.scales-grp.
define temp-table temp-filter  NO-UNDO LIKE ubflt.filter.
define temp-table temp-cash-desk  NO-UNDO LIKE ub.cash-desk.
define temp-table temp-curr-shop  NO-UNDO LIKE ub.curr-shop.
define temp-table temp_sequence  NO-UNDO
field seq-name like {&db-name_schema}._sequence._seq-name
field seq-val as int64
index pi is unique primary
seq-name
.
define temp-table temp-usr-flt  NO-UNDO LIKE ubflt.usr-flt.
define temp-table temp-user-account            NO-UNDO LIKE ub.user-account.
define temp-table temp-user-login              NO-UNDO LIKE ub.user-login.
define temp-table temp-user-obj                NO-UNDO LIKE ub.user-obj.
define temp-table temp-user-host               NO-UNDO LIKE ub.user-host.
define temp-table temp-user-menu-group         NO-UNDO LIKE ub.user-menu-group.
define temp-table temp-user-login-action-role  NO-UNDO LIKE ub.user-login-action-role.
define temp-table temp-user-login-action-item  NO-UNDO LIKE ub.user-login-action-item.
define temp-table temp-action-role             NO-UNDO LIKE ub.action-role.
define temp-table temp-action-role-item        NO-UNDO LIKE ub.action-role-item.

define temp-table temp-action-item no-undo
  field grp-acta-arm-code  as character
  field grp-acta-object    as character
  field grp-acta-act       as character
  field action-item-id     as character
  field action-context     as character

  index xpk is primary unique grp-acta-arm-code grp-acta-object grp-acta-act
  index ie1 action-item-id
  index ie2 action-context
  .

define temp-table temp-userconf no-undo
   field user-name      as character
   field obj-code       as integer
   field obj-type       as character
   field ARM            as character  format "X(12)"
   field on-line        as logical
   field max-discnt     as decimal
   field quest-print    as logical
   field arm-host-code  as integer
   field userid_        as character
   field user-name_     as character
   field password_      as character
   index pu is primary unique
         user-name
.
define temp-table temp-usr-grpa no-undo
   field user-name      as character
   field arm-code       as character
   field grp-name       as character format "X(20)"
   field host-code      as integer
   index pu is primary unique
         user-name
         host-code
         arm-code
.
define temp-table temp-usr-grpo no-undo
   field user-name      as character
   field obj-type       as character
   field obj-code       as integer
   field grp-name       as character format "X(20)"
   index pu is primary unique
         user-name
         obj-type
         obj-code
.
define temp-table temp-grpa no-undo
   field grp-name       as character format "X(20)"
   field arm-code       as character
   index pu is primary unique
         arm-code
         grp-name
.
define temp-table temp-grp-acta no-undo
   field grp-name       as character format "X(20)"
   field arm-code       as character
   field object         as character format "X(15)"
   field act            as character format "X(25)"
   index pu is primary unique
         grp-name
         arm-code
         object
         act
.

/*это временные таблицы из одной записи*/
define temp-table buf-sys-ctrl  NO-UNDO LIKE ub.sys-ctrl.
define temp-table buf-config  NO-UNDO LIKE ub.config.
define temp-table buf-prod-bc no-undo LIKE ub.prod-bc.
define temp-table buf-gds-obj-attr no-undo LIKE ub.gds-obj-attr.
define temp-table buf-scales  NO-UNDO LIKE ub.scales.
define temp-table buf-scales-gds  NO-UNDO LIKE ub.scales-gds.
define temp-table buf-scales-grp  NO-UNDO LIKE ub.scales-grp.
define temp-table buf-filter  NO-UNDO LIKE ubflt.filter.
define temp-table buf-cash-desk  NO-UNDO LIKE ub.cash-desk.
define temp-table buf-curr-shop  NO-UNDO LIKE ub.curr-shop.

define temp-table buf_sequence  NO-UNDO
field seq-name like {&db-name_schema}._sequence._seq-name
field seq-val as int64
index pi is unique primary
seq-name
.
define temp-table buf-usr-flt                 NO-UNDO LIKE ubflt.usr-flt.
define temp-table buf-user-account            NO-UNDO LIKE ub.user-account.
define temp-table buf-user-login              NO-UNDO LIKE ub.user-login.
define temp-table buf-user-obj                NO-UNDO LIKE ub.user-obj.
define temp-table buf-user-host               NO-UNDO LIKE ub.user-host.
define temp-table buf-user-menu-group         NO-UNDO LIKE ub.user-menu-group.
define temp-table buf-user-login-action-role  NO-UNDO LIKE ub.user-login-action-role.
define temp-table buf-user-login-action-item  NO-UNDO LIKE ub.user-login-action-item.
define temp-table buf-action-role             NO-UNDO LIKE ub.action-role.
define temp-table buf-action-role-item        NO-UNDO LIKE ub.action-role-item.

define temp-table buf-userconf  NO-UNDO LIKE temp-userconf .
define temp-table buf-grpa      NO-UNDO LIKE temp-grpa .
define temp-table buf-usr-grpa  NO-UNDO LIKE temp-usr-grpa .
define temp-table buf-usr-grpo  NO-UNDO LIKE temp-usr-grpo .
define temp-table buf-grp-acta  NO-UNDO LIKE temp-grp-acta .

define stream Instream.
DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE ss as character no-undo .
DEFINE VARIABLE current-table as character no-undo .
DEFINE VARIABLE loc-alert-box as logical no-undo .
DEFINE VARIABLE r-bar-code like ub.bar-code.b-code no-undo .
DEFINE VARIABLE v-is-global as logical no-undo .
DEFINE VARIABLE v-is-weight as logical no-undo .
DEFINE VARIABLE v-is-pgweight as logical no-undo .
DEFINE VARIABLE v-is-scaleable as logical no-undo .
DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE dopi as integer no-undo .
DEFINE VARIABLE scales-unit as character no-undo .
DEFINE VARIABLE scales-max-gds like ub.scales.max-gds no-undo.
DEFINE VARIABLE scales-tot-gds like ub.scales.tot-gds no-undo.
DEFINE VARIABLE  hnum as logical no-undo init no.
DEFINE VARIABLE  b-hnum as logical no-undo init no.
DEFINE VARIABLE  conf-par as char no-undo.                  /* для чтения параметра конфигурации */
DEFINE VARIABLE  par-type as char no-undo.
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE er-mes as character no-undo .
DEFINE VARIABLE v-b-code as integer no-undo .
define variable v-pbc-rid as recid no-undo .
define variable v-b-str as character no-undo .
define variable v-cdrg-type as character no-undo .
define buffer cli_units for ub.units.
define buffer buf_code-range for ub.code-range.
define buffer buf_config for ub.config.
define buffer ext_config for ub.config.

&scop check-file  run check-iefile in this-procedure(input p-dir-name, ~
                                     input ~{&current-data-group~}, ~
                                     input "import":U, ~
                                     output loc#log).

&scop Input-stream   input stream Instream from value(p-dir-name + "\":U + p-db-key + ".":U + ~{&current-data-group~}).
&scop close-stream   input stream InStream close.
&scop imp-stream-ss  import stream Instream unformatted ss.
&scop imp-stream     import stream Instream
&scop ii0 ii = 0.
&scop ii1 ii = ii + 1. run write-counter in p-log-handle (substitute("Считано &1 записей", ii)).
&scop errimp-mes  (~{&err-mes0~} + error-status:get-message(error-status:num-messages))
&scop wlerimp-mes if error-status:error then do: ~
                      ~{&wl~} ~
                      NEXT ~{&next-line~}. ~
                  end.

&scop wl-mes ~{&wl~} ~
             delete ~{&table-name~}. ~
                  NEXT ~{&next-line~}.

&scop undo-mes ~{&wl~} ~
               NEXT ~{&next-line~}.


&scop get-mes       er-mes = "". ~
      do jj = 1 to error-status:num-messages: ~
        er-mes = er-mes + ~{&new-line~} + error-status:get-message(JJ). ~
      end.

assign
p-rht = logical(entry(1, p-parameter, {&delim-par}))
p-gen = logical(entry(2, p-parameter, {&delim-par}))
p-flt = logical(entry(3, p-parameter, {&delim-par}))
p-pbc = logical(entry(4, p-parameter, {&delim-par}))
p-scl = logical(entry(5, p-parameter, {&delim-par}))
p-usr = logical(entry(6, p-parameter, {&delim-par}))
p-seq = logical(entry(7, p-parameter, {&delim-par}))
/*ключ БАЗЫ - он же имя файла без расширения*/
p-db-key = entry(8, p-parameter, {&delim-par})
/*директория экспорта*/
p-dir-name  = entry(9, p-parameter, {&delim-par})
p-glb       = logical(entry(10, p-parameter, {&delim-par}))
p-version   = entry(11, p-parameter, {&delim-par})
no-error
.
if error-status:error then return error substitute("&1 &2", error-status:get-message(1) , return-value ).


&scop err-mes " Импорт локальных таблиц"
{&wl}

if p-gen then do:
  run p-gen-i in this-procedure .
end.
if p-flt then do:
  run p-flt-i in this-procedure .
end.
if p-scl then do:
  run p-scl-i in this-procedure .
end.
if p-seq then do:
  run p-seq-i in this-procedure .
end.
if p-pbc then do:
  run p-pbc-i in this-procedure .
end.
if p-rht then do:
  run p-rht-i in this-procedure .
end.
if p-usr then do:
   if (not p-rht)
   and (not (p-version = "15.0")) then do:
      run p-rht-i in this-procedure .
   end.
   run p-usr-i in this-procedure .
end.


{&ii0}


if p-gen then do:
  &scop current-data-group "gen":U
  &scop wait-mess "Проверка группы данных ИНФОРМАЦИЯ О БД"
  &scop err-mes0 "Проверка группы данных ИНФОРМАЦИЯ О БД" + ~{&new-line~}
  {&waitc}
  &scop next-line _configv
  &scop table-name temp-config
  _configv:
  FOR EACH temp-config:
    find first ub.config no-lock where
              ub.config.param-code = temp-config.param-code
          AND ub.config.host-code = 0
          AND ub.config.obj-type = '':U
          AND ub.config.obj-code = 0
    NO-ERROR.
    if not available ub.config then do:
        &scop err-mes (~{&err-mes0~} + " НАСТРОЕЧНЫЙ ПАРАМЕТР(config)" + ~
                                        " " + temp-config.param-code + ~
                                        " Фирма " + string(temp-config.host-code) + ~
                                        " тип объекта " + temp-config.obj-type + ~
                                        " код объекта " + string(temp-config.obj-code) + ~
                                        " не является валидным в данной конфигурации" )
        {&wl-mes}
    end.
    if lookup(ub.config.conf-type, {&cnf-type-list-protect}) > 0
    then do:
        &scop err-mes (~{&err-mes0~} + " НАСТРОЕЧНЫЙ ПАРАМЕТР(config)" + ~
                                        " " + temp-config.param-code + ~
                                        " является кодированным - импорт запрещен" )
        {&wl-mes}
    end.

    FIND FIRST ext_config No-LOCK WHERE
              ext_config.param-code = temp-config.param-code AND
              ext_config.host-code = temp-config.host-code AND
              ext_config.obj-type = temp-config.obj-type AND
              ext_config.obj-code = temp-config.obj-code
    NO-ERROR.
    IF AVAILABLE ext_config then do:
        &scop err-mes (~{&err-mes0~} + " Уже есть запись НАСТРОЕЧНОГО ПАРАМЕТРА(config)" + ~
                                        " параметр " + temp-config.param-code + ~
                                        " Фирма " + string(temp-config.host-code) + ~
                                        " тип объекта " + temp-config.obj-type + ~
                                        " код объекта " + string(temp-config.obj-code) )
        {&wl-mes}
    end.
    if temp-config.host-code > 0 then do:
      FIND FIRST ub.sysconf No-LOCK WHERE
                ub.sysconf.host-code = temp-config.host-code No-ERROR.
      IF NOT AVAIL ub.sysconf then do:
          &scop err-mes (~{&err-mes0~} + " Отсутствует фирма для НАСТРОЕЧНОГО ПАРАМЕТРА(config)" + ~
                                          " параметр " + temp-config.param-code + ~
                                          " Фирма " + string(temp-config.host-code) + ~
                                          " тип объекта " + temp-config.obj-type + ~
                                          " код объекта " + string(temp-config.obj-code) )
          {&wl-mes}
      END.
    end.
    if temp-config.obj-type <> "" or temp-config.obj-code > 0 then do:
      FIND FIRST ub.clients No-LOCK WHERE
                ub.clients.obj-type = temp-config.obj-type AND
                ub.clients.obj-code = temp-config.obj-code NO-ERROR.
      IF NOT AVAIL ub.clients then do:
          &scop err-mes (~{&err-mes0~} + " Отсутствует объект для НАСТРОЕЧНОГО ПАРАМЕТРА(config)" + ~
                                          " параметр " + temp-config.param-code + ~
                                          " Фирма " + string(temp-config.host-code) + ~
                                          " тип объекта " + temp-config.obj-type + ~
                                          " код объекта " + string(temp-config.obj-code) )
          {&wl-mes}
      END.
      IF ub.clients.db-num <> ub.db.db-num then do:
          &scop err-mes (~{&err-mes0~} + " Объект для НАСТРОЕЧНОГО ПАРАМЕТРА(config) принадлежит другой БД" + ~
                                          " параметр " + temp-config.param-code + ~
                                          " Фирма " + string(temp-config.host-code) + ~
                                          " тип объекта " + temp-config.obj-type + ~
                                          " код объекта " + string(temp-config.obj-code) )
          {&wl-mes}
      END.
    end.
    create buf_config.
    buffer-copy ub.config to buf_config
    assign
    buf_config.host-code = temp-config.host-code
    buf_config.obj-type = temp-config.obj-type
    buf_config.obj-code = temp-config.obj-code
    buf_config.param-value = temp-config.param-value
    .
    release buf_config no-error.


    if error-status:error then do:
      {&get-mes}
      &scop err-mes (~{&err-mes0~} +  " ошибка при сохранении НАСТРОЕЧНОГО ПАРАМЕТРA(config):" + ~
                                      " параметр " + temp-config.param-code + ~
                                      " Фирма " + string(temp-config.host-code) + ~
                                      " тип объекта " + temp-config.obj-type + ~
                                      " код объекта " + string(temp-config.obj-code) + ~
                                      er-mes)
      {&undo-mes}
    end.
  END.
end.
if p-flt then do:
  &scop current-data-group "flt":U
  &scop wait-mess "Проверка группы данных ФИЛЬТРЫ"
  &scop err-mes0 "Проверка группы данных ФИЛЬТРЫ" + ~{&new-line~}
  {&waitc}
  &scop next-line _filterv
  &scop table-name temp-filter
  _filterv:
  FOR EACH temp-filter NO-LOCK:
    FIND FIRST ubflt.filter No-LOCK WHERE
              ubflt.filter.call-point = temp-filter.call-point AND
              ubflt.filter.NAIM = temp-filter.NAIM NO-ERROR.
    IF AVAILABLE ubflt.filter then do:
      &scop err-mes (~{&err-mes0~} + " Уже есть ФИЛЬТР(filter):" + ~
                      " название " + string(temp-filter.Naim) + ~
                      " точка вызова " + temp-filter.call-point)
      {&wl-mes}
    end.
    create ubflt.filter.
    buffer-copy temp-filter to ubflt.filter.
    release ubflt.filter no-error.
    if error-status:error then do:
      {&get-mes}
      &scop err-mes (~{&err-mes0~} + " ошибка при сохранении записи ФИЛЬТР(filter):" + ~
                      " название " + string(temp-filter.Naim) + ~
                      " точка вызова " + temp-filter.call-point + ~
                      er-mes)
      {&undo-mes}
    end.

  run adm/restseqr.p
    ( input "rest-no-msg":U
     ,input "next-num-filter":U
     ,input no
    ) no-error .

  if error-status :error then do:
    return error return-value .
  end.
  END.
end.
if p-pbc then do:
  &scop current-data-group "pbc":U
  &scop wait-mess "Проверка группы данных ВЕС и ВЗВЕШ КОДЫ"
  &scop err-mes0 "Проверка группы данных ВЕС И ВЗВЕШ КОДЫ" + ~{&new-line~}
  {&waitc}
  &scop next-line _prod-bcv
  &scop table-name temp-prod-bc
  _prod-bcv:
  FOR EACH temp-prod-bc:
    assign
    v-is-global = no
    v-is-weight = no
    v-is-pgweight = no
    v-is-scaleable = no
    .
    FIND FIRST ub.prod-bc No-LOCK WHERE
               ub.prod-bc.b-str = temp-prod-bc.b-str
          AND  ub.prod-bc.b-code = temp-prod-bc.b-code NO-ERROR.
    IF AVAILABLE ub.prod-bc then do:
        &scop err-mes (~{&err-mes0~} + " Уже есть ДопБК(prod-bc):" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Бар-код " + string(temp-prod-bc.b-code))
        {&wl-mes}
    end.
    find first ub.prod-bc no-lock where
              ub.prod-bc.b-str = temp-prod-bc.b-str
          AND ub.prod-bc.bc-on = yes no-error.
    IF AVAILABLE ub.prod-bc then do:
        &scop err-mes (~{&err-mes0~} + " Уже есть такой включенный ДопБК(prod-bc) на другом товаре:" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Бар-код имеющегося включенного ДопБК" + string(ub.prod-bc.b-code))
        {&wl-mes}
    end.

    find first ub.bar-code no-lock where
               ub.bar-code.b-code = temp-prod-bc.b-code no-error.
    if not avail ub.bar-code then do:
        &scop err-mes (~{&err-mes0~} + " Не найден бар-код для ДопБК(prod-bc):" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Бар-код " + string(temp-prod-bc.b-code))
        {&wl-mes}
    end.
    FIND FIRST ub.goods no-lock where
              ub.goods.gds-code = ub.bar-code.gds-code  NO-ERROR.
    if not avail ub.bar-code then do:
        &scop err-mes (~{&err-mes0~} + " Не найден товар по бар-коду для ДопБК(prod-bc):" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Бар-код " + string(temp-prod-bc.b-code))
        {&wl-mes}
    end.
    find first ub.units no-lock where
               ub.units.unit-name = ub.goods.unit-base no-error .
    if not avail ub.units then do:
        &scop err-mes (~{&err-mes0~} + " Не найдена основная ед. изм товара для ДопБК(prod-bc):" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Бар-код " + string(temp-prod-bc.b-code) + ~
                        " Товар " + ub.goods.artic + ~{&space-char} + ub.goods.prod-type + string(ub.goods.prod-code))
        {&wl-mes}
    end.
    if LOOKUP({&weight}, ub.units.type) = 0
    and not (LOOKUP({&pieces}, ub.units.type) > 0
         and can-find(first ub.code-range no-lock where
                            ub.code-range.db-num = 0
                        and ub.code-range.range-type = {&loc-pg-code}
                        and ub.code-range.first-code <= integer(temp-prod-bc.b-str)
                        and ub.code-range.last-code >= integer(temp-prod-bc.b-str)))
    then do:
        &scop err-mes (~{&err-mes0~} + " Товар по ДопБК(prod-bc) НЕ ((весовой или штучный) и ДопБК - код для весов):" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Бар-код " + string(temp-prod-bc.b-code) + ~
                        " Товар " + ub.goods.artic + ~{&space-char} + ub.goods.prod-type + string(ub.goods.prod-code) + ~
                        " Основн. ед. изм" + ub.goods.unit-base)
        {&wl-mes}
    end.
    if ub.bar-code.unit-cli = ub.goods.unit-base then do:
      /*весовой код*/
      /*убедимся что это основной бар-код*/
      { gbl/gdsbcode.i ub.goods.gds-code ? r-bar-code no-error }
      if error-status:error then do:
        &scop err-mes (~{&err-mes0~} + " Ошибка при поиске основного бар-кода товара для ДопБК(prod-bc):" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Бар-код " + string(temp-prod-bc.b-code))
        {&wl-mes}
      end.
      if r-bar-code <> ub.bar-code.b-code then do:
        &scop err-mes (~{&err-mes0~} + " Бар-код для ДопБК(prod-bc) не является основным бар-кодом товара:" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Бар-код " + string(temp-prod-bc.b-code))
        {&wl-mes}
      end.
      /*проверка на глобальность и весовость*/
      { gbl/prodbctv.i
        temp-prod-bc.b-str
        ub.bar-code.unit-cli
        ub.goods.unit-base
        'global=request':U
        v-is-global
        no-error
      }
      if error-status:error then do:
        &scop err-mes (~{&err-mes0~} + " Ошибка при проверке на локальность ДопБК(prod-bc):" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Бар-код " + string(temp-prod-bc.b-code))
        {&wl-mes}
      end.
      if v-is-global
      and not p-glb
      then do:
        &scop err-mes (~{&err-mes0~} + " ДопБК(prod-bc) не локальный:" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Бар-код " + string(temp-prod-bc.b-code))
        {&wl-mes}
      end.
      { gbl/prodbctv.i
        temp-prod-bc.b-str
        ub.bar-code.unit-cli
        ub.goods.unit-base
        'weight=request':U
        v-is-weight
        no-error
      }
      if error-status:error then do:
        &scop err-mes (~{&err-mes0~} + " Ошибка при проверке весовой ли ДопБК(prod-bc):" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Бар-код " + string(temp-prod-bc.b-code))
        {&wl-mes}
      end.
      { gbl/prodbctv.i
        temp-prod-bc.b-str
        ub.bar-code.unit-cli
        ub.goods.unit-base
        'pgweight=request':U
        v-is-pgweight
        no-error
      }
      if error-status:error then do:
        &scop err-mes (~{&err-mes0~} + " Ошибка при проверке штучный ли ДопБК для весов(prod-bc):" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Бар-код " + string(temp-prod-bc.b-code))
        {&wl-mes}
      end.
      if not v-is-weight
      and not v-is-pgweight
      then do:
        &scop err-mes (~{&err-mes0~} + " ДопБК(prod-bc) не код для весов:" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Бар-код " + string(temp-prod-bc.b-code))
        {&wl-mes}
      end.
      if v-is-weight then do:
      v-cdrg-type = {&loc-sc-code}.
    end.
    else do:
        v-cdrg-type = {&loc-pg-code}.
      end.
    end.
    else do:
      /*взвешиваемый*/
      find first cli_units no-lock where
                cli_units.unit-name = ub.bar-code.unit-cli no-error .
      if not avail cli_units then do:
          &scop err-mes (~{&err-mes0~} + " Не найдена ед. изм бар-кода для ДопБК(prod-bc):" + ~
                          " ДопБК " + string(temp-prod-bc.b-str) + ~
                          " Бар-код " + string(temp-prod-bc.b-code) + ~
                          " Ед.изм.бар-кода "  + ub.bar-code.unit-cli)
          {&wl-mes}
      end.
      if LOOKUP({&divisional}, cli_units.type) = 0 then do:
        &scop err-mes (~{&err-mes0~} + " Единица измерения бар-кода по ДопБК(prod-bc) не весовая и не дробная:" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Бар-код " + string(temp-prod-bc.b-code) + ~
                        " Ед. изм" + ub.bar-code.unit-cli)
        {&wl-mes}
      end.
      if ub.bar-code.part-code <> "":U or ub.bar-code.in-code <> "":U then do:
        &scop err-mes (~{&err-mes0~} + " Бар-код для ДопБК(prod-bc) не является бар-кодом товара на доп.ед.изм:" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Бар-код " + string(temp-prod-bc.b-code) + ~
                        " in-code " + ub.bar-code.in-code + ~
                        " part-code " + ub.bar-code.part-code )
        {&wl-mes}
      end.
      /*проверка на глобальность и весовость*/
      { gbl/prodbctv.i
        temp-prod-bc.b-str
        ub.bar-code.unit-cli
        ub.goods.unit-base
        'global=request':U
        v-is-global
        no-error
      }
      if error-status:error then do:
        &scop err-mes (~{&err-mes0~} + " Ошибка при проверке на локальность ДопБК(prod-bc):" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Бар-код " + string(temp-prod-bc.b-code))
        {&wl-mes}
      end.
      if v-is-global
      and p-glb = no
      then do:
        &scop err-mes (~{&err-mes0~} + " ДопБК(prod-bc) не локальный:" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Бар-код " + string(temp-prod-bc.b-code))
        {&wl-mes}
      end.
      { gbl/prodbctv.i
        temp-prod-bc.b-str
        ub.bar-code.unit-cli
        ub.goods.unit-base
        'scaleable=request':U
        v-is-scaleable
        no-error
      }
      if error-status:error then do:
        &scop err-mes (~{&err-mes0~} + " Ошибка при проверке взвешиваемый ли ДопБК(prod-bc):" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Бар-код " + string(temp-prod-bc.b-code))
        {&wl-mes}
      end.
      if not v-is-scaleable then do:
        &scop err-mes (~{&err-mes0~} + " ДопБК(prod-bc) не весовой:" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Бар-код " + string(temp-prod-bc.b-code))
        {&wl-mes}

      end.
      v-cdrg-type = {&loc-ss-code}.
    end.
    v-pbc-rid = ?.
    v-b-str = temp-prod-bc.b-str.
    run trg/prod-bc1.p ( input parparentproc
                        ,input yes /*p-silent*/
                        ,input no /* dif-pdbc здесь не важно*/
                        ,input no /*pbc-veto здесь не важно*/
                        ,input no /*send-ref*/
                        ,input v-cdrg-type
                        ,input "" /*p-ean-type*/
                        ,buffer ub.goods
                        ,input ub.bar-code.b-code
                        ,input-output v-b-str /*p-b-str*/
                        ,output v-pbc-rid
                        ) no-error.
    if error-status:error
    or v-pbc-rid = ?
    then do:
      {&get-mes}
      er-mes = er-mes + {&new-line} + return-value .
      &scop err-mes (~{&err-mes0~} + " ошибка при сохранении записи ДопБК(prod-bc):" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Бар-код " + string(temp-prod-bc.b-code) + ~
                      er-mes)
      {&undo-mes}
    end.
  END.
  run get-max-code in this-procedure
    ( input "f-u":U
      ,input ub.sys-ctrl.db-num
      ,input {&loc-ss-code}
      ,input ?
      ,input ?
      ,input TRUE
      ,output v-b-code
    ) no-error .
  if error-status:error then do:
    {&get-mes}
    &scop err-mes (~{&err-mes0~} + " ошибка при исправлении статуса диапазонов взвешиваемых кодов(prod-bc):" + ~
                    er-mes)
    {&wl}
  end.
  run get-max-code in this-procedure
    ( input "f-u":U
      ,input ub.sys-ctrl.db-num
      ,input {&loc-sc-code}
      ,input ?
      ,input ?
      ,input TRUE
      ,output v-b-code
    ) no-error .
  if error-status:error then do:
    {&get-mes}
    &scop err-mes (~{&err-mes0~} + " ошибка при исправлении статуса диапазонов локальных весовых кодов(prod-bc):" + ~
                    er-mes)
    {&wl}
  end.
  run get-max-code in this-procedure
    ( input "f-u":U
      ,input ub.sys-ctrl.db-num
      ,input {&loc-pg-code}
      ,input ?
      ,input ?
      ,input TRUE
      ,output v-b-code
    ) no-error .
  if error-status:error then do:
    {&get-mes}
    &scop err-mes (~{&err-mes0~} + " ошибка при исправлении статуса диапазонов штучных кодов для  весовых (prod-bc):" + ~
                    er-mes)
    {&wl}
  end.
  find first buf_code-range no-lock
    where buf_code-range.db-num     = 0
      and buf_code-range.range-type = {&loc-sc-code}
      and buf_code-range.stts       = "a":U
    no-error .
  if not available buf_code-range then do:
    {&get-mes}
    &scop err-mes (~{&err-mes0~} + " ошибка при установке значения sequence внутрь активного диапазонов локальных весовых кодов(prod-bc):" + ~
                    er-mes)
    {&wl}
  end.
  else do:
    run get-max-code ( input "get-m-code":U
                      ,input buf_code-range.db-num
                      ,input buf_code-range.range-type
                      ,input buf_code-range.first-code
                      ,input buf_code-range.last-code
                      ,input TRUE
                      ,output v-b-code
                      ) no-error .
    if error-status:error then do:
      {&get-mes}
      &scop err-mes (~{&err-mes0~} + " ошибка при получении max кода диапазона взвешиваемых кодов(prod-bc):" + ~
                      er-mes)
      {&wl}
    end.
    if v-b-code <= buf_code-range.last-code then do:
      /* устанавливаем */
      current-value(s-sclc-code, {&db-name_schema}) = v-b-code.
    end.
    else do:
      current-value(s-sclc-code, {&db-name_schema}) = buf_code-range.last-code.
    end.
  end.
  find first buf_code-range no-lock
    where buf_code-range.db-num     = 0
      and buf_code-range.range-type = {&loc-pg-code}
      and buf_code-range.stts       = "a":U
    no-error .
  if not available buf_code-range then do:
    {&get-mes}
    &scop err-mes (~{&err-mes0~} + " ошибка при установке значения sequence внутрь активного диапазонов локальных штучных кодов для весов(prod-bc):" + ~
                    er-mes)
    {&wl}
  end.
  else do:
    run get-max-code ( input "get-m-code":U
                      ,input buf_code-range.db-num
                      ,input buf_code-range.range-type
                      ,input buf_code-range.first-code
                      ,input buf_code-range.last-code
                      ,input TRUE
                      ,output v-b-code
                      ) no-error .
    if error-status:error then do:
      {&get-mes}
      &scop err-mes (~{&err-mes0~} + " ошибка при получении max кода диапазона локальных штуных кодов для весов(prod-bc):" + ~
                      er-mes)
      {&wl}
    end.
    if v-b-code <= buf_code-range.last-code then do:
      /* устанавливаем */
      current-value(s-pglc-code, {&db-name_schema}) = v-b-code.
    end.
    else do:
      current-value(s-pglc-code, {&db-name_schema}) = buf_code-range.last-code.
    end.
  end.
  {&waitc}
  &scop next-line _gds-obj-attrv
  &scop table-name temp-gds-obj-attr
  _gds-obj-attrv:
  FOR EACH temp-gds-obj-attr NO-LOCK:
    /*проверим что такого в БД нет*/
    FIND FIRST ub.gds-obj-attr No-LOCK WHERE
              ub.gds-obj-attr.gds-code = temp-gds-obj-attr.gds-code
          AND ub.gds-obj-attr.obj-code = temp-gds-obj-attr.obj-code
          AND ub.gds-obj-attr.obj-type  = temp-gds-obj-attr.obj-type
          AND ub.gds-obj-attr.attr-code  = temp-gds-obj-attr.attr-code NO-ERROR.
    IF AVAILABLE ub.gds-obj-attr then do:
      &scop err-mes (~{&err-mes0~} + " Уже есть АТРИБУТ ТОВАРА ВЕСОВОЙ КОД НА ОБЪЕКТЕ(gds-obj-attr):" + ~
                      " код товара " + string(temp-gds-obj-attr.gds-code) + ~
                      " объект " + temp-gds-obj-attr.obj-type + string(temp-gds-obj-attr.obj-code) + ~
                      " весовой код " + temp-gds-obj-attr.attr-value + ~
                      er-mes)
      {&wl-mes}
    end.
    /*проверим что есть товар*/
    FIND FIRST ub.goods No-LOCK WHERE
              ub.goods.gds-code = temp-gds-obj-attr.gds-code no-error .
    IF NOT AVAILABLE ub.goods then do:
      &scop err-mes (~{&err-mes0~} + " Нет товара для АТРИБУТА ТОВАРА ВЕСОВОЙ КОД НА ОБЪЕКТЕ(gds-obj-attr):" + ~
                      " код товара " + string(temp-gds-obj-attr.gds-code) + ~
                      " объект " + temp-gds-obj-attr.obj-type + string(temp-gds-obj-attr.obj-code) + ~
                      " весовой код " + temp-gds-obj-attr.attr-value + ~
                      er-mes)
      {&wl-mes}
    end.
    /*проверим что товар весовой*/
    find first ub.units no-lock where
               ub.units.unit-name = ub.goods.unit-base no-error .
    if not avail ub.units
    or (lookup({&weight}, ub.units.type) = 0
        and
        lookup({&pieces}, ub.units.type) = 0)
    then do:
      &scop err-mes (~{&err-mes0~} + " Не найдена основная единица измерения для товара или товар не весовой и не штучный для АТРИБУТА ТОВАРА ВЕСОВОЙ КОД НА ОБЪЕКТЕ(gds-obj-attr):" + ~
                      " код товара " + string(temp-gds-obj-attr.gds-code) + ~
                      " объект " + temp-gds-obj-attr.obj-type + string(temp-gds-obj-attr.obj-code) + ~
                      " весовой код " + temp-gds-obj-attr.attr-value + ~
                      er-mes)
      {&wl-mes}
    end.
    /*проверим что есть объект*/
    FIND FIRST ub.clients No-LOCK WHERE
              ub.clients.obj-type = temp-gds-obj-attr.obj-type
          AND ub.clients.obj-code = temp-gds-obj-attr.obj-code no-error .
    IF NOT AVAILABLE ub.clients then do:
      &scop err-mes (~{&err-mes0~} + " Нет объекта для АТРИБУТА ТОВАРА ВЕСОВОЙ КОД НА ОБЪЕКТЕ(gds-obj-attr):" + ~
                      " код товара " + string(temp-gds-obj-attr.gds-code) + ~
                      " объект " + temp-gds-obj-attr.obj-type + string(temp-gds-obj-attr.obj-code) + ~
                      " весовой код " + temp-gds-obj-attr.attr-value + ~
                      er-mes)
      {&wl-mes}
    end.
    if LOOKUP(ub.clients.obj-type, {&shop} + {&comma-char} + {&stock}) = 0 then do:
      &scop err-mes (~{&err-mes0~} + " Неверный тип объекта для АТРИБУТА ТОВАРА ВЕСОВОЙ КОД НА ОБЪЕКТЕ(gds-obj-attr):" + ~
                      " код товара " + string(temp-gds-obj-attr.gds-code) + ~
                      " объект " + temp-gds-obj-attr.obj-type + string(temp-gds-obj-attr.obj-code) + ~
                      " весовой код " + temp-gds-obj-attr.attr-value + ~
                      er-mes)
      {&wl-mes}
    end.
    /*проверим что объект текущей БД*/
    if ub.clients.db-num <> ub.db.db-num then do:
      &scop err-mes (~{&err-mes0~} + " Объект для АТРИБУТА ТОВАРА ВЕСОВОЙ КОД НА ОБЪЕКТЕ(gds-obj-attr) принадлежит другой БД:" + ~
                      " код товара " + string(temp-gds-obj-attr.gds-code) + ~
                      " объект " + temp-gds-obj-attr.obj-type + string(temp-gds-obj-attr.obj-code) + ~
                      " весовой код " + temp-gds-obj-attr.attr-value + ~
                      er-mes)
      {&wl-mes}
    end.
    /*проверим что есть соответствующий prod-bc*/
    { gbl/gdsbcode.i ub.goods.gds-code ? r-bar-code no-error }
    if error-status:error then do:
      &scop err-mes (~{&err-mes0~} + " Ошибка при поиске основного бар-кода товара  для АТРИБУТА ТОВАРА ВЕСОВОЙ КОД НА ОБЪЕКТЕ(gds-obj-attr) принадлежит другой БД:" + ~
                      " код товара " + string(temp-gds-obj-attr.gds-code) + ~
                      " объект " + temp-gds-obj-attr.obj-type + string(temp-gds-obj-attr.obj-code) + ~
                      " весовой код " + temp-gds-obj-attr.attr-value + ~
                      er-mes)
      {&wl-mes}
    end.
    find first ub.prod-bc no-lock where
               ub.prod-bc.b-str = temp-gds-obj-attr.attr-value
            AND ub.prod-bc.b-code = r-bar-code
            AND ub.prod-bc.bc-on = yes no-error .
    if not avail ub.prod-bc then do:
      &scop err-mes (~{&err-mes0~} + " Нет соответствующего весового кода или он выключен для АТРИБУТА ТОВАРА ВЕСОВОЙ КОД НА ОБЪЕКТЕ(gds-obj-attr) принадлежит другой БД:" + ~
                      " код товара " + string(temp-gds-obj-attr.gds-code) + ~
                      " объект " + temp-gds-obj-attr.obj-type + string(temp-gds-obj-attr.obj-code) + ~
                      " весовой код " + temp-gds-obj-attr.attr-value + ~
                      er-mes)
      {&wl-mes}
    end.
    create ub.gds-obj-attr.
    buffer-copy temp-gds-obj-attr to ub.gds-obj-attr.
    release ub.gds-obj-attr no-error.
    if error-status:error then do:
      {&get-mes}
      &scop err-mes (~{&err-mes0~} + " ошибка при сохранении записи АТРИБУТ ТОВАРА ВЕСОВОЙ КОД НА ОБЪЕКТЕ(gds-obj-attr):" + ~
                      " код товара " + string(temp-gds-obj-attr.gds-code) + ~
                      " объект " + temp-gds-obj-attr.obj-type + string(temp-gds-obj-attr.obj-code) + ~
                      " весовой код " + temp-gds-obj-attr.attr-value + ~
                      er-mes)
      {&undo-mes}
    end.
  END.
end.
if p-scl then do:
  &scop current-data-group "scl":U
  &scop wait-mess "Проверка группы данных ВЕСЫ"
  &scop err-mes0 "Проверка группы данных ВЕСЫ" + ~{&new-line~}
  {&waitc}
  &scop next-line _scalesv
  &scop table-name temp-scales
  _scalesv:
  FOR EACH temp-scales:
    FIND FIRST ub.scales No-LOCK WHERE
               ub.scales.db-num = temp-scales.db-num  AND
               ub.scales.scales-num = temp-scales.scales-num  NO-ERROR.
    IF AVAILABLE ub.scales then do:
        &scop err-mes (~{&err-mes0~} + " Уже есть ВЕСЫ(scales):" + ~
                        " номер " + string(temp-scales.scales-num))
        {&wl-mes}
    end.
    IF temp-scales.master > 0 then do:
      dopi = temp-scales.master.
      IF NOT (CAN-FIND(FIRST ub.scales No-LOCK WHERE
                            ub.scales.db-num = g#db-num
                        AND ub.scales.scales-num = dopi) OR
              CAN-FIND(FIRST temp-scales No-LOCK WHERE
                             temp-scales.db-num = g#db-num
                        AND temp-scales.scales-num = dopi)) then do:
        &scop err-mes (~{&err-mes0~} + " Не найдены главные весы для подчиненных ВЕСОВ(scales):" + ~
                        " номер " + string(temp-scales.scales-num))
        {&wl-mes}
      END.
    end.
    define variable v-rid as recid no-undo .
    run ref/scales1.p (
    input-output v-rid
    ,input {&add-def}
    ,INPUT yes /*p-silent*/
    ,input temp-scales.db-num
    ,input temp-scales.scales-num
    ,input temp-scales.address
    ,input temp-scales.master
    ,input temp-scales.max-gds
    ,input temp-scales.scales-name
    ,input temp-scales.scales-type
    ,input temp-scales.remote
    ,input temp-scales.sts
    ,input temp-scales.unit-base
    ,input temp-scales.wt-cart
    ) no-error .
    if error-status:error then do:
      {&get-mes}
      &scop err-mes (~{&err-mes0~} +  " ошибка при сохранении записи ВЕСЫ(scales):" + ~
                                      " номер " + string(temp-scales.scales-num) + ~
                                      er-mes)
      {&undo-mes}
    end.
  END. /*FOR EACH temp-scales*/
  &scop next-line _scales-gdsv
  &scop table-name temp-scales-gds
  _scales-gdsv:
  FOR EACH temp-scales-gds :
    assign
    dopi = temp-scales-gds.scales-num
    scales-unit = "":U
    scales-max-gds = 0
    scales-tot-gds = 0
    .
    FIND FIRST ub.scales where
               ub.scales.db-num = g#db-num
         AND ub.scales.scales-num = dopi NO-ERROR.
    IF NOT AVAIL ub.scales then do:
      IF NOT AVAIL ub.scales then do:
        &scop err-mes (~{&err-mes0~} + " Не найдены ВЕСЫ для ТОВАРА НА ВЕСАХ(scales-gds):" + ~
                        " номер весов " + string(temp-scales-gds.scales-num) + ~
                        " PLU " + string(temp-scales-gds.PLU-code))
        {&wl-mes}
      END.
      if ub.scales.master > 0 then do:
        &scop err-mes (~{&err-mes0~} + " ВЕСЫ для ТОВАРА НА ВЕСАХ(scales-gds) являются подчиненными - импортировать нельзя:" + ~
                        " номер весов " + string(temp-scales-gds.scales-num) + ~
                        " PLU " + string(temp-scales-gds.PLU-code))
        {&wl-mes}
      end.
    END.
    ELSE do:
      assign
      scales-unit = ub.scales.unit-base
      scales-max-gds = ub.scales.max-gds
      scales-tot-gds = ub.scales.tot-gds
      .
    END.
    FIND FIRST ub.shop No-LOCK WHERE
               ub.shop.obj-code = temp-scales-gds.obj-code  NO-ERROR.
    IF NOT AVAILABLE ub.shop then do:
        &scop err-mes (~{&err-mes0~} + " Нет магазина для ТОВАРА НА ВЕСАХ(scales-gds)" + ~
                        " номер весов " + string(temp-scales-gds.scales-num) + ~
                        " PLU " + string(temp-scales-gds.PLU-code) + ~
                        " temp-scales-gds.obj-code " + string(temp-scales-gds.obj-code))
        {&wl-mes}
    end.
    FIND FIRST ub.clients WHERE
               ub.clients.obj-type = {&shop} AND
               ub.clients.obj-code = temp-scales-gds.obj-code NO-LOCK NO-ERROR.
    if avail ub.clients and clients.db-num <> ub.db.db-num then do:
        &scop err-mes (~{&err-mes0~} + " Магазин для ТОВАРОВ ДЛЯ ВЕСОВ относится к другой БД - ТОВАР НА ВЕСАХ(scales-gds):" + ~
                        " номер весов " + string(temp-scales-gds.scales-num) + ~
                        " PLU " + string(temp-scales-gds.PLU-code) + ~
                        " temp-scales-gds.obj-code " + string(temp-scales-gds.obj-code) + ~
                        " db-num " + string(ub.db.db-num))
        {&wl-mes}
   end.
    if temp-scales-gds.plu-code > scales-max-gds then do:
        &scop err-mes (~{&err-mes0~} + " PLU больше Max кол-ва товаров на весах для ТОВАРА НА ВЕСАХ(scales-gds):" + ~
                        " номер весов " + string(temp-scales-gds.scales-num) + ~
                        " PLU " + string(temp-scales-gds.PLU-code))
        {&wl-mes}
    END.
    FIND FIRST ub.scales-gds No-LOCK WHERE
              ub.scales-gds.db-num = temp-scales-gds.db-num AND
              ub.scales-gds.scales-num = temp-scales-gds.scales-num AND
              ub.scales-gds.PLU-code = temp-scales-gds.PLU-code NO-ERROR.
    IF AVAIL ub.scales-gds then do:
        &scop err-mes (~{&err-mes0~} + " Уже есть ТОВАР НА ВЕСАХ(scales-gds):" + ~
                        " номер весов " + string(temp-scales-gds.scales-num) + ~
                        " PLU " + string(temp-scales-gds.PLU-code))
        {&wl-mes}
    end.
    FIND FIRST ub.scales-gds No-LOCK WHERE
              ub.scales-gds.db-num = temp-scales-gds.db-num AND
              ub.scales-gds.scales-num = temp-scales-gds.scales-num AND
              ub.scales-gds.b-code = temp-scales-gds.b-code NO-ERROR.
    IF AVAILABLE ub.scales-gds then do:
        &scop err-mes (~{&err-mes0~} + " Уже есть ТОВАР НА ВЕСАХ(scales-gds):" + ~
                        " номер весов " + string(temp-scales-gds.scales-num) + ~
                        " бар-код " + string(temp-scales-gds.b-code))
        {&wl-mes}
    end.
    FIND FIRST ub.bar-code No-LOCK WHERE
               ub.bar-code.b-code = temp-scales-gds.b-code No-ERROR.
    IF NOT AVAIL ub.bar-code then do:
        &scop err-mes (~{&err-mes0~} + " Не найден БАР-КОД для ТОВАРА НА ВЕСАХ(scales-gds):" + ~
                        " номер весов " + string(temp-scales-gds.scales-num) + ~
                        " бар-код " + string(temp-scales-gds.b-code))
        {&wl-mes}
    END.
    FIND FIRST ub.goods No-LOCK WHERE
               ub.goods.gds-code = ub.bar-code.gds-code NO-ERROR.
    IF NOT AVAILABLE ub.goods then do:
        &scop err-mes (~{&err-mes0~} + " Не найден ТОВАР для ТОВАРА НА ВЕСАХ(scales-gds):" + ~
                        " номер весов " + string(temp-scales-gds.scales-num) + ~
                        " бар-код " + string(temp-scales-gds.b-code))
        {&wl-mes}
    END.
    FIND FIRST ub.units No-LOCK WHERE
               ub.units.unit-name = ub.goods.unit-base No-ERROR.
    IF NOT AVAIL ub.units then do:
        &scop err-mes (~{&err-mes0~} + " Не найдена ЕДИНИЦА ИЗМЕРЕНИЯ для ТОВАРА НА ВЕСАХ(scales-gds):" + ~
                        " номер весов " + string(temp-scales-gds.scales-num) + ~
                        " бар-код " + string(temp-scales-gds.b-code))
        {&wl-mes}
    END.
    if ub.units.unit-name <> scales-unit
    and ub.units.type = {&weight}
    then do:
        &scop err-mes (~{&err-mes0~} + " ЕДИНИЦА ИЗМЕРЕНИЯ ТОВАРА НА ВЕСАХ(scales-gds):" + ~
                        " номер весов " + string(temp-scales-gds.scales-num) + ~
                        " бар-код " + string(temp-scales-gds.b-code) + ~
                        " единица измерения товара " + ub.units.unit-name + ~
                        " единица измерения весов " + scales-unit )
        {&wl-mes}
    END.
    FIND FIRST ub.gds-prt No-LOCK WHERE
               ub.gds-prt.upper-code = ub.goods.prt-root NO-ERROR.
    IF NOT AVAIL(ub.gds-prt) then do:
        &scop err-mes (~{&err-mes0~} + " Не найдена ШКАЛА ПРИЗНАКОВ(пустая шкала) для ТОВАРА НА ВЕСАХ(scales-gds):" + ~
                        " номер весов " + string(temp-scales-gds.scales-num) + ~
                        " бар-код " + string(temp-scales-gds.b-code))
        {&wl-mes}
    END.
    if ub.bar-code.node-code <> ub.gds-prt.node-code OR
      ub.bar-code.in-code <> "":U OR
      ub.bar-code.part-code <> "":U OR
      ub.bar-code.unit-cli <> ub.goods.unit-base then do:
        &scop err-mes (~{&err-mes0~} + " Бар-код не является главным бар-кодом товара для ТОВАРА НА ВЕСАХ(scales-gds):" + ~
                        " номер весов " + string(temp-scales-gds.scales-num) + ~
                        " бар-код " + string(temp-scales-gds.b-code))
        {&wl-mes}
    END.
    run create-scales-gds in this-procedure (
                                              buffer ub.bar-code
                                             ,buffer ub.scales
                                             ,buffer ub.goods
                                             ,buffer temp-scales-gds
                                             ) no-error .
    if error-status:error then dO:
        &scop err-mes (~{&err-mes0~} + " Ошибка при создании ТОВАРА НА ВЕСАХ(scales-gds):" + ~
                        " номер весов " + string(temp-scales-gds.scales-num) + ~
                        " бар-код " + string(temp-scales-gds.b-code) + ~
                        return-value)
        {&wl-mes}
    end.
    FIND LAST scales-gds WHERE
               scales-gds.db-num = g#db-num
         AND scales-gds.scales-num = ub.scales.scales-num NO-LOCK use-index pi no-error .
    if available scales-gds and ub.scales.max-plu < ub.scales-gds.PLU-code then
    ub.scales.max-plu = scales-gds.PLU-code .
  END.

  &scop next-line _scales-grpv
  &scop table-name temp-scales-grp
  _scales-grpv:
    FOR EACH temp-scales-grp:
    assign
    dopi = temp-scales-grp.scales-num
    .
    FIND FIRST ub.scales  NO-LOCK where
               ub.scales.db-num = g#db-num AND
               ub.scales.scales-num = dopi NO-ERROR.
    IF NOT AVAIL ub.scales then do:
      FIND FIRST temp-scales NO-LOCK WHERE
                 temp-scales.db-num = g#db-num
            AND temp-scales.scales-num = dopi No-ERROR.
      IF NOT AVAIL temp-scales then do:
        &scop err-mes (~{&err-mes0~} + " Не найдены ВЕСЫ для ГРУППЫ ТОВАРОВ НА ВЕСАХ(scales-gds):" + ~
                        " номер весов " + string(temp-scales-grp.scales-num) + ~
                        " код группы " + string(temp-scales-grp.node-code))
        {&wl-mes}
      END.
    END.
    FIND FIRST ub.Scales-grp No-LOCK WHERE
              ub.scales-grp.db-num = temp-scales-grp.db-num AND
              ub.scales-grp.scales-num = temp-scales-grp.scales-num AND
              ub.scales-grp.node-code = temp-scales-grp.node-code NO-ERROR.
    IF  AVAILABLE ub.scales-grp then do:
          &scop err-mes (~{&err-mes0~} + " Уже есть ГРУППА ТОВАРА НА ВЕСАХ(scales-grp):" + ~
                          " номер группы " + string(temp-scales-grp.node-code) + ~
                          " номер весов " + string(temp-scales-grp.scales-num))
      {&wl-mes}
    end.
    dopi = 0.
    FIND FIRST ub.gds-grp No-LOCK WHERE
               ub.gds-grp.node-code = temp-scales-grp.node-code No-ERROR.
    if avail ub.gds-grp then dopi = ub.gds-grp.node-code.
    IF dopi = 0 or (CAN-find(FIRST ub.gds-grp NO-LOCK WHERE
                                   ub.gds-grp.upper-code = dopi)) then do:
      &scop err-mes (~{&err-mes0~} + " Не найдена ГРУППА ТОВАРОВ или нетерминальная для ГРУППЫ ТОВАРОВ НА ВЕСАХ(scales-grp):" + ~
                      " номер группы " + string(temp-scales-grp.node-code) + ~
                      " номер весов " + string(temp-scales-grp.scales-num))
      {&wl-mes}
    END.
    create ub.scales-grp.
    buffer-copy temp-scales-grp to ub.scales-grp.
    release ub.scales-grp no-error.
    if error-status:error then do:
      {&get-mes}
      &scop err-mes (~{&err-mes0~} +  " ошибка при сохранении записи ГРУППА ТОВАРОВ НА ВЕСАХ(scales-grp):" + ~
                                      " номер группы " + string(temp-scales-grp.node-code) + ~
                                      " номер весов " + string(temp-scales-grp.scales-num) + ~
                                      er-mes)
      {&undo-mes}
    end.
  END.
end.

if p-rht then do:
   define buffer buf_action-item    for ub.action-item.

   CASE p-version:
      when "15.0":U then do:

         &scop next-line _action-role
         &scop table-name temp-action-role
         _action-role:
         FOR EACH temp-action-role:
            FIND FIRST ub.action-role No-LOCK
                 WHERE ub.action-role.db-num           = temp-action-role.db-num
                   and ub.action-role.action-head-code = temp-action-role.action-head-code
                   and ub.action-role.action-role-code = temp-action-role.action-role-code
                 NO-ERROR
                 .
            IF AVAILABLE ub.action-role then do:
               &scop err-mes (~{&err-mes0~} + " Уже есть ГРУППА ПРАВ (action-role):" ~
                                            + STRING(temp-action-role.db-num) ~
                                            + STRING(temp-action-role.action-head-code) ~
                                            + STRING(temp-action-role.action-role-code) ~
                                            )
               {&wl-mes}
            END.
            create ub.action-role.
            buffer-copy temp-action-role to ub.action-role.
            release ub.action-role No-error.
            if error-status:error then do:
               {&get-mes}
               &scop err-mes (~{&err-mes0~} +  " ошибка при сохранении записи ГРУППЫ ПРАВ (action-role):" ~
                                            + STRING(temp-action-role.db-num) ~
                                            + STRING(temp-action-role.action-head-code) ~
                                            + STRING(temp-action-role.action-role-code) ~
                                            )
               {&undo-mes}
            end.
         END. /*for each temp-action-role*/

         run adm/restseqr.p
           ( input "rest":U
           , input "s-action-role":U
           , input no
           ) no-error .
         if error-status :error then do:
           return error return-value .
         end.

         &scop next-line _action-role-item
         &scop table-name temp-action-role-item
         _action-role-item:
         FOR EACH temp-action-role-item:
            FIND FIRST ub.action-role-item No-LOCK
                 WHERE ub.action-role-item.db-num           = temp-action-role-item.db-num
                   and ub.action-role-item.action-head-code = temp-action-role-item.action-head-code
                   and ub.action-role-item.action-role-code = temp-action-role-item.action-role-code
                   and ub.action-role-item.action-item-id = temp-action-role-item.action-item-id
                 NO-ERROR
                 .
            IF AVAILABLE ub.action-role-item then do:
               &scop err-mes (~{&err-mes0~} + " Уже есть привязка к ГРУППЕ ПРАВ (action-role-item):" ~
                                            + STRING(temp-action-role-item.db-num) ~
                                            + STRING(temp-action-role-item.action-head-code) ~
                                            + STRING(temp-action-role-item.action-role-code) ~
                                            + STRING(temp-action-role-item.action-role-item-code) ~
                                            )
            {&wl-mes}
             END.
          create ub.action-role-item.
          
          assign
            ub.action-role-item.action-head-code = temp-action-role-item.action-head-code
            ub.action-role-item.action-item-id   = temp-action-role-item.action-item-id
            ub.action-role-item.action-role-code = temp-action-role-item.action-role-code
            ub.action-role-item.action-role-item-code = dynamic-next-value("s-action-role-item":U, "{&db-name_schema}":U)
            ub.action-role-item.db-num          = temp-action-role-item.db-num
            ub.action-role-item.whole-send-news = temp-action-role-item.whole-send-news 
          .
/*          buffer-copy temp-action-role-item EXCEPT temp-action-role-item.action-role-item-code temp-action-role-item.action-item-id to ub.action-role-item*/
/*            .                                                                                                                                             */
/*          assign                                                                                                                                          */
/*            ub.action-role-item.action-role-item-code = dynamic-next-value("s-action-role":U, "{&db-name_schema}":U)                                      */
/*            .                                                                                                                                             */
          find first ub.action-item
            where ub.action-item.action-head-code = ub.action-role-item.action-head-code
            and ub.action-item.action-item-id  = ub.action-role-item.action-item-id
            no-lock
            no-error
            .
          if available ub.action-item then 
          do:
            assign
              ub.action-role-item.action-item-code = ub.action-item.action-item-code
              .
          end.
            
          release ub.action-role-item No-error.
          if error-status:error then 
          do:
            {&get-mes}
               &scop err-mes (~{&err-mes0~} +  " ошибка при сохранении привязки к ГРУППЕ ПРАВ (action-role-item):" ~
                                            + STRING(temp-action-role-item.db-num) ~
                                            + STRING(temp-action-role-item.action-head-code) ~
                                            + STRING(temp-action-role-item.action-role-code) ~
                                            + STRING(temp-action-role-item.action-role-item-code) ~
                                            )
               {&undo-mes}
            end.
         END. /*for each temp-action-role-item*/

         run adm/restseqr.p
           ( input "rest":U
           , input "s-action-role-item":U
           , input no
           ) no-error .
         if error-status :error then do:
           return error return-value .
         end.

      end.
      otherwise do:
         define variable v-global-action-role-code     as integer   no-undo .
         define variable v-firm-action-role-code       as integer   no-undo .
         define variable v-object-action-role-code     as integer   no-undo .
         define variable v-action-role-code            as integer   no-undo .
         define variable v-action-role-item-code       as integer   no-undo .

         define buffer buf_action-role       for ub.action-role .
         define buffer buf_action-role-item  for ub.action-role-item .

         run p-right-i in this-procedure .

         _gpr:
         for each temp-grpa no-lock
         on error undo, return error return-value
         :
            assign
               v-global-action-role-code = 0
               v-firm-action-role-code   = 0
               v-object-action-role-code = 0
            .

            for each temp-grp-acta no-lock
               where temp-grp-acta.grp-name = temp-grpa.grp-name
               and temp-grp-acta.arm-code = temp-grpa.arm-code
            on error undo, return error return-value
            :
               find first temp-action-item
               where temp-action-item.grp-acta-arm-code = temp-grp-acta.arm-code
                  and temp-action-item.grp-acta-object   = temp-grp-acta.object
                  and temp-action-item.grp-acta-act      = temp-grp-acta.act
               no-error .
               if not available temp-action-item
               then do:
                  /* error */
               end.
               else do:
               case temp-action-item.action-context
               :
                  when {&right-type-global}
                  then do:
                     if v-global-action-role-code = 0
                     then do:
                        IF NOT CAN-FIND ( FIRST buf_action-role
                                          WHERE buf_action-role.db-num            = g#db-num
                                          and buf_action-role.action-head-code    = {&action-head-code-main}
                                          and buf_action-role.action-role-context = {&right-type-global}
                                          and buf_action-role.action-role-name    = temp-grpa.arm-code + ' ':U + temp-grpa.grp-name
                                       )
                        THEN DO:
                           assign
                              v-action-role-code = dynamic-next-value("s-action-role":U, "{&db-name_schema}":U)
                           .
                           create buf_action-role .
                           assign
                              buf_action-role.db-num              = g#db-num
                              buf_action-role.action-head-code    = {&action-head-code-main}
                              buf_action-role.action-role-code    = v-action-role-code
                              buf_action-role.action-role-context = temp-action-item.action-context
                              buf_action-role.action-role-name    = temp-grpa.arm-code + ' ':U + temp-grpa.grp-name
                           .
                           assign
                              v-global-action-role-code = v-action-role-code
                           .
                        END.
                     end.

                     IF NOT CAN-FIND ( FIRST buf_action-role-item
                                       WHERE buf_action-role-item.db-num              = g#db-num
                                         and buf_action-role-item.action-head-code    = {&action-head-code-main}
                                         and buf_action-role-item.action-role-code    = v-global-action-role-code
                                         and buf_action-role-item.action-item-id      = temp-action-item.action-item-id
                                     )
                     THEN DO:
                        assign
                           v-action-role-item-code = dynamic-next-value("s-action-role-item":U, "{&db-name_schema}":U)
                        .
                        create buf_action-role-item .
                        assign
                           buf_action-role-item.db-num                = g#db-num
                           buf_action-role-item.action-head-code      = {&action-head-code-main}
                           buf_action-role-item.action-role-code      = v-global-action-role-code
                           buf_action-role-item.action-role-item-code = v-action-role-item-code
                           buf_action-role-item.action-item-id        = temp-action-item.action-item-id
                        .
                        find first buf_action-item
                           where buf_action-item.action-head-code = buf_action-role-item.action-head-code
                              and buf_action-item.action-item-id  = buf_action-role-item.action-item-id
                           no-lock
                           no-error
                           .
                        if available buf_action-item then do:
                           assign
                              buf_action-role-item.action-item-code = buf_action-item.action-item-code
                           .
                        end.
                     end.
                  end.
                  when {&right-type-firm}
                  then do:
                     if v-firm-action-role-code = 0
                     then do:
                        assign
                           v-action-role-code = dynamic-next-value("s-action-role":U, "{&db-name_schema}":U)
                        .
                        create buf_action-role .
                        assign
                           buf_action-role.db-num              = g#db-num
                           buf_action-role.action-head-code    = {&action-head-code-main}
                           buf_action-role.action-role-code    = v-action-role-code
                           buf_action-role.action-role-context = temp-action-item.action-context
                           buf_action-role.action-role-name    = temp-grpa.arm-code + ' ':U + temp-grpa.grp-name
                        .
                        assign
                           v-firm-action-role-code = v-action-role-code
                        .
                        end.

                        assign
                           v-action-role-item-code = dynamic-next-value("s-action-role-item":U, "{&db-name_schema}":U)
                        .
                        create buf_action-role-item .
                        assign
                           buf_action-role-item.db-num                = g#db-num
                           buf_action-role-item.action-head-code      = {&action-head-code-main}
                           buf_action-role-item.action-role-code      = v-firm-action-role-code
                           buf_action-role-item.action-role-item-code = v-action-role-item-code
                           buf_action-role-item.action-item-id        = temp-action-item.action-item-id
                        .
                        find first buf_action-item
                           where buf_action-item.action-head-code = buf_action-role-item.action-head-code
                              and buf_action-item.action-item-id  = buf_action-role-item.action-item-id
                           no-lock
                           no-error
                           .
                        if available buf_action-item then do:
                           assign
                              buf_action-role-item.action-item-code = buf_action-item.action-item-code
                           .
                        end.
                  end.
                  when {&right-type-object}
                  then do:
                     if v-object-action-role-code = 0
                     then do:
                        assign
                           v-action-role-code = dynamic-next-value("s-action-role":U, "{&db-name_schema}":U)
                        .
                        create buf_action-role .
                        assign
                           buf_action-role.db-num              = g#db-num
                           buf_action-role.action-head-code    = {&action-head-code-main}
                           buf_action-role.action-role-code    = v-action-role-code
                           buf_action-role.action-role-context = temp-action-item.action-context
                           buf_action-role.action-role-name    = temp-grpa.arm-code + ' ':U + temp-grpa.grp-name
                        .
                        assign
                           v-object-action-role-code = v-action-role-code
                        .
                        end.

                        assign
                           v-action-role-item-code = dynamic-next-value("s-action-role-item":U, "{&db-name_schema}":U)
                        .
                        create buf_action-role-item .
                        assign
                           buf_action-role-item.db-num                = g#db-num
                           buf_action-role-item.action-head-code      = {&action-head-code-main}
                           buf_action-role-item.action-role-code      = v-object-action-role-code
                           buf_action-role-item.action-role-item-code = v-action-role-item-code
                           buf_action-role-item.action-item-id        = temp-action-item.action-item-id
                        .
                        find first buf_action-item
                           where buf_action-item.action-head-code = buf_action-role-item.action-head-code
                              and buf_action-item.action-item-id  = buf_action-role-item.action-item-id
                           no-lock
                           no-error
                           .
                        if available buf_action-item then do:
                           assign
                              buf_action-role-item.action-item-code = buf_action-item.action-item-code
                           .
                        end.
                  end.
                  otherwise do:
                  /* error */
                  end.
               end. /* case action-context */
               end. /* available temp-action-item */
            end. /* each temp-grp-acta */
         end. /* each grpa */
      end.
   END CASE.

end.

if p-usr then do:
   define buffer buf__user          for ub._user.
   define buffer buf_user-account   for ub.user-account.
   define buffer buf_menu-group     for ub.menu-group.
   define buffer buf_clients        for ub.clients.
   define buffer buf_user-login     for ub.user-login.
   define buffer buf_user-context-history    for ubflt.user-context-history.
   define buffer buf_user-login-action-role  for ub.user-login-action-role.
   define buffer buf_user-menu-group      for ub.user-menu-group.
   define buffer buf_user-host      for ub.user-host.
   define buffer buf_user-obj       for ub.user-obj.

  &scop current-data-group "usr":U
  &scop wait-mess "Проверка группы данных ПОЛЬЗОВАТЕЛИ"
  &scop err-mes0 "Проверка группы данных ПОЛЬЗОВАТЕЛИ" + ~{&new-line~}
  {&waitc}
  &scop next-line _userconfv
  &scop table-name temp-userconf

   define variable v-ok                          as logical   no-undo .
   define variable v-user-id                     as character no-undo .
   define variable v-user-login                  as character no-undo .
   define variable v-last-name                   as character no-undo .
   define variable v-user-password-encoded       as character no-undo .
   define variable v-cntxt-menu-group-id         as character no-undo .
   define variable v-cntxt-level                 as character no-undo .
   define variable v-cntxt-host-code-obj         as integer   no-undo .
   define variable v-cntxt-obj-type              as character no-undo .
   define variable v-cntxt-obj-code              as integer   no-undo .
   define variable v-arm-code-list               as character no-undo .
   define variable v-arm-code-lookup-index       as integer   no-undo .
   define variable v-menu-group-id-list          as character no-undo .
   define variable v-menu-group-id               as character no-undo .
   define variable v-user-login-role-code        as integer   no-undo .
   define variable v-obj-name                    as character no-undo .
   define variable v-user-menu-group-code        as integer   no-undo .

   CASE p-version:
      when "15.0" then do:

         &scop next-line _user-account
         &scop table-name temp-user-account
         _user-account:
         FOR EACH temp-user-account:
            FIND FIRST ub.user-account No-LOCK
                 WHERE ub.user-account.user-id = temp-user-account.user-id
                 NO-ERROR
                 .
            IF AVAILABLE ub.user-account then do:
               &scop err-mes (~{&err-mes0~} + " Уже есть ПОЛЬЗОВАТЕЛЬ(user-account):" + temp-user-account.user-id)
               {&wl-mes}
            END.
            create ub.user-account.
            buffer-copy temp-user-account to ub.user-account.
            release ub.user-account No-error.
            if error-status:error then do:
               {&get-mes}
               &scop err-mes (~{&err-mes0~} +  " ошибка при сохранении записи ПОЛЬЗОВАТЕЛЯ(user-account): " + temp-user-account.user-id + " " + er-mes)
               {&undo-mes}
            end.
         END. /*for each temp-user-account*/

         run adm/restseqr.p
           ( input "rest":U
           , input "s-user-id":U
           , input no
           ) no-error .
         if error-status :error then do:
           return error return-value .
         end.

         &scop next-line _user-login
         &scop table-name temp-user-login
         _user-login:
         FOR EACH temp-user-login:
            FIND FIRST ub.user-login No-LOCK
                 WHERE ub.user-login.user-id = temp-user-login.user-id
                   AND ub.user-login.db-num  = temp-user-login.db-num
                 NO-ERROR
                 .
            IF AVAILABLE ub.user-login then do:
               &scop err-mes (~{&err-mes0~} + " Уже есть логин ПОЛЬЗОВАТЕЛЯ(user-login): " ~
                                            + temp-user-login.user-id ~
                                            + "БД:" + string(temp-user-login.db-num) ~
                                            )
               {&wl-mes}
            END.
            FIND FIRST ub.user-account No-LOCK
                 WHERE ub.user-account.user-id = temp-user-login.user-id
                 NO-ERROR
                 .
            IF NOT AVAILABLE ub.user-account then do:
               &scop err-mes (~{&err-mes0~} + " Не найден ПОЛЬЗОВАТЕЛЬ(user-account):" + temp-user-login.user-id)
               {&wl-mes}
            END.
            create ub.user-login.
            buffer-copy temp-user-login to ub.user-login.
            release ub.user-login No-error.
            if error-status:error then do:
               {&get-mes}
               &scop err-mes (~{&err-mes0~} +  " ошибка при сохранении догина ПОЛЬЗОВАТЕЛЯ(user-login): " + temp-user-login.user-id + "БД:" + string(temp-user-login.db-num) + " " + er-mes)
               {&undo-mes}
            end.
         END. /*for each temp-user-login*/

         &scop next-line _user-obj
         &scop table-name temp-user-obj
         _user-obj:
         FOR EACH temp-user-obj:
            FIND FIRST ub.user-obj No-LOCK
                 WHERE ub.user-obj.user-id  = temp-user-obj.user-id
                   AND ub.user-obj.db-num   = temp-user-obj.db-num
                   AND ub.user-obj.obj-type = temp-user-obj.obj-type
                   AND ub.user-obj.obj-code = temp-user-obj.obj-code
                 NO-ERROR
                 .
            IF AVAILABLE ub.user-obj then do:
               &scop err-mes (~{&err-mes0~} + " Уже есть объект ПОЛЬЗОВАТЕЛЯ(user-obj): " ~
                                            + temp-user-obj.user-id ~
                                            + "БД:" + string(temp-user-obj.db-num) + " " ~
                                            + temp-user-obj.obj-type + "," ~
                                            + STRING(temp-user-obj.obj-code)       ~
                                            )
               {&wl-mes}
            END.
            FIND FIRST ub.user-login No-LOCK
                 WHERE ub.user-login.user-id = temp-user-obj.user-id
                   AND ub.user-login.db-num  = temp-user-obj.db-num
                 NO-ERROR
                 .
            IF NOT AVAILABLE ub.user-login then do:
               &scop err-mes (~{&err-mes0~} + " Не найден логин ПОЛЬЗОВАТЕЛЬ(user-obj):" + temp-user-obj.user-id + "БД:" + string(temp-user-obj.db-num))
               {&wl-mes}
            END.
            if not can-find(first ub.clients no-lock where
                                  ub.clients.obj-type = temp-user-obj.obj-type
                              and ub.clients.obj-code = temp-user-obj.obj-code) then do:
               &scop err-mes (~{&err-mes0~} + " Не найден объект ПОЛЬЗОВАТЕЛЬ(user-obj):" + temp-user-obj.user-id + "БД:" + string(temp-user-obj.db-num))
               {&wl-mes}
            end.
            create ub.user-obj.
            buffer-copy temp-user-obj to ub.user-obj.
            release ub.user-obj No-error.
            if error-status:error then do:
               {&get-mes}
               &scop err-mes (~{&err-mes0~} +  " ошибка при сохранении объекта ПОЛЬЗОВАТЕЛЯ(user-obj): "~
                                            + temp-user-obj.user-id ~
                                            + "БД:" + string(temp-user-obj.db-num) + " " ~
                                            + temp-user-obj.obj-type + "," ~
                                            + STRING(temp-user-obj.obj-code)       ~
                                            )
               {&undo-mes}
            end.
         END. /*for each temp-user-obj */

         &scop next-line _user-host
         &scop table-name temp-user-host
         _user-host:
         FOR EACH temp-user-host:
            FIND FIRST ub.user-host No-LOCK
                 WHERE ub.user-host.user-id  = temp-user-host.user-id
                   AND ub.user-host.db-num   = temp-user-host.db-num
                   AND ub.user-host.host-code = temp-user-host.host-code
                 NO-ERROR
                 .
            IF AVAILABLE ub.user-host then do:
               &scop err-mes (~{&err-mes0~} + " Уже есть фирма ПОЛЬЗОВАТЕЛЯ(user-host): " ~
                                            + temp-user-host.user-id ~
                                            + "БД:" + string(temp-user-host.db-num) + " " ~
                                            + STRING(temp-user-host.host-code)       ~
                                            )
               {&wl-mes}
            END.
            FIND FIRST ub.user-login No-LOCK
                 WHERE ub.user-login.user-id = temp-user-host.user-id
                   AND ub.user-login.db-num  = temp-user-host.db-num
                 NO-ERROR
                 .
            IF NOT AVAILABLE ub.user-login then do:
               &scop err-mes (~{&err-mes0~} + " Не найден логин ПОЛЬЗОВАТЕЛЬ(user-host):" + temp-user-host.user-id + "БД:" + string(temp-user-host.db-num))
               {&wl-mes}
            END.
            if not can-find(first ub.sysconf no-lock where
                                  ub.sysconf.host-code = temp-user-host.host-code
                              ) then do:
               &scop err-mes (~{&err-mes0~} + " Не найдена фирма ПОЛЬЗОВАТЕЛЬ(user-host):" + temp-user-obj.user-id + "БД:" + string(temp-user-obj.db-num))
               {&wl-mes}
            end.

            create ub.user-host.
            buffer-copy temp-user-host to ub.user-host.
            release ub.user-host No-error.
            if error-status:error then do:
               {&get-mes}
               &scop err-mes (~{&err-mes0~} +  " ошибка при сохранении фирмы ПОЛЬЗОВАТЕЛЯ(user-host): " ~
                                            + temp-user-host.user-id ~
                                            + "БД:" + string(temp-user-host.db-num) + " " ~
                                            + STRING(temp-user-host.host-code)       ~
                                            + " " + er-mes)
               {&undo-mes}
            end.
         END. /*for each temp-user-host */

         &scop next-line _user-menu-group
         &scop table-name temp-user-menu-group
         _user-menu-group:
         FOR EACH temp-user-menu-group:
            FIND FIRST ub.user-menu-group No-LOCK
                 WHERE ub.user-menu-group.user-id  = temp-user-menu-group.user-id
                   AND ub.user-menu-group.db-num   = temp-user-menu-group.db-num
                   AND ub.user-menu-group.user-menu-group-code = temp-user-menu-group.user-menu-group-code
                 NO-ERROR
                 .
            IF AVAILABLE ub.user-menu-group then do:
               &scop err-mes (~{&err-mes0~} + " Уже есть группа меню ПОЛЬЗОВАТЕЛЯ(user-menu-group): " ~
                                            + temp-user-menu-group.user-id ~
                                            + "БД:" + string(temp-user-menu-group.db-num) + " " ~
                                            + STRING(temp-user-menu-group.user-menu-group-code)       ~
                                            )
               {&wl-mes}
            END.
            FIND FIRST ub.user-login No-LOCK
                 WHERE ub.user-login.user-id = temp-user-menu-group.user-id
                   AND ub.user-login.db-num  = temp-user-menu-group.db-num
                 NO-ERROR
                 .
            IF NOT AVAILABLE ub.user-login then do:
               &scop err-mes (~{&err-mes0~} + " Не найден логин ПОЛЬЗОВАТЕЛЬ(user-menu-group):" + temp-user-menu-group.user-id + "БД:" + string(temp-user-menu-group.db-num))
               {&wl-mes}
            END.
            if not can-find(first ub.sysconf no-lock where
                                  ub.sysconf.host-code = temp-user-menu-group.host-code
                              ) then do:
               &scop err-mes (~{&err-mes0~} + " Не найдена фирма ПОЛЬЗОВАТЕЛЬ(user-menu-group):" + temp-user-menu-group.user-id + "БД:" + string(temp-user-menu-group.db-num))
               {&wl-mes}
            end.
            if not can-find(first ub.clients no-lock where
                                  ub.clients.obj-type = temp-user-menu-group.obj-type
                              and ub.clients.obj-code = temp-user-menu-group.obj-code) then do:
               &scop err-mes (~{&err-mes0~} + " Не найден объект ПОЛЬЗОВАТЕЛЬ(user-menu-group):" + temp-user-menu-group.user-id + "БД:" + string(temp-user-menu-group.db-num))
               {&wl-mes}
            end.

            create ub.user-menu-group.
            buffer-copy temp-user-menu-group to ub.user-menu-group.
            release ub.user-menu-group No-error.
            if error-status:error then do:
               {&get-mes}
               &scop err-mes (~{&err-mes0~} +  " ошибка при сохранении группы меню ПОЛЬЗОВАТЕЛЯ(user-menu-group): " ~
                                            + temp-user-menu-group.user-id ~
                                            + "БД:" + string(temp-user-menu-group.db-num) + " " ~
                                            + STRING(temp-user-menu-group.user-menu-group-code)       ~
                                            + " " + er-mes)
               {&undo-mes}
            end.
         END. /*for each temp-user-menu-group */
         &scop next-line _user-login-action-role
         &scop table-name temp-user-login-action-role
         _user-login-action-role:
         FOR EACH temp-user-login-action-role:
            FIND FIRST ub.user-login-action-role No-LOCK
                 WHERE 
/*                 ub.user-login-action-role.user-id  = temp-user-login-action-role.user-id*/
/*                   AND                                                                   */
                   ub.user-login-action-role.db-num   = temp-user-login-action-role.db-num
                   AND ub.user-login-action-role.user-login-role-code = temp-user-login-action-role.user-login-role-code
                   AND ub.user-login-action-role.action-head-code   =   temp-user-login-action-role.action-head-code
                 NO-ERROR
                 .
            IF AVAILABLE ub.user-login-action-role then do:
               &scop err-mes (~{&err-mes0~} + " Уже есть группа прав ПОЛЬЗОВАТЕЛЯ(user-login-action-role): " ~
                                            + temp-user-login-action-role.user-id ~
                                            + "БД:" + string(temp-user-login-action-role.db-num) + " " ~
                                            + STRING(temp-user-login-action-role.user-login-role-code)       ~
                                            )
               {&wl-mes}
            END.
            FIND FIRST ub.user-login No-LOCK
                 WHERE ub.user-login.user-id = temp-user-login-action-role.user-id
                   AND ub.user-login.db-num  = temp-user-login-action-role.db-num
                 NO-ERROR
                 .
            IF NOT AVAILABLE ub.user-login then do:
               &scop err-mes (~{&err-mes0~} + " Не найден логин ПОЛЬЗОВАТЕЛЬ(user-login):" + temp-user-login-action-role.user-id + "БД:" + string(temp-user-login-action-role.db-num))
               {&wl-mes}
            END.
            create ub.user-login-action-role.
            buffer-copy temp-user-login-action-role to ub.user-login-action-role.
            release ub.user-login-action-role no-error.
            if error-status:error then do:
               {&get-mes}
               &scop err-mes (~{&err-mes0~} +  " ошибка при сохранении группы прав ПОЛЬЗОВАТЕЛЯ(user-login-action-role): " ~
                                            + temp-user-login-action-role.user-id ~
                                            + "БД:" + string(temp-user-login-action-role.db-num) + " " ~
                                            + STRING(temp-user-login-action-role.user-login-role-code) ~
                                            + " " + er-mes )
               {&undo-mes}
            end.
         END. /*for each temp-user-login-action-role */

         run adm/restseqr.p
           ( input "rest":U
           , input "s-user-login-action-role":U
           , input no
           ) no-error .
         if error-status :error then do:
           return error return-value .
         end.
      end.
      otherwise do:
         if "{&language}" = "rus":U
         then do:
            assign
               v-arm-code-list = 'офи':U
               + {&comma-char} + 'скл':U
               + {&comma-char} + 'маг':U
               + {&comma-char} + 'рес':U
               + {&comma-char} + 'фин':U
               + {&comma-char} + 'бгх':U
               + {&comma-char} + 'бух':U
               + {&comma-char} + 'осн':U
               + {&comma-char} + 'адм':U
               v-obj-name      = 'объ':U
               .
         end.
         else do:
            assign
               v-arm-code-list = 'off':U
               + {&comma-char} + 'str':U
               + {&comma-char} + 'shp':U
               + {&comma-char} + 'res':U
               + {&comma-char} + 'fin':U
               + {&comma-char} + 'eac':U
               + {&comma-char} + 'acc':U
               + {&comma-char} + 'fas':U
               + {&comma-char} + 'adm':U
               v-obj-name      = 'object':U
            .
         end.
         assign
            v-menu-group-id-list = 'off,str,shp,res,fin,bge,buh,fas,adm':U
         .

         &scop next-line _userconf
         &scop table-name temp-userconf
         _userconf:
         FOR EACH temp-userconf:
            find first buf__user
               where buf__user._userid = temp-userconf.user-name
               no-error .
            if available buf__user
            then do:
               assign
               v-user-login            = buf__user._userid
               v-last-name             = buf__user._user-name
               v-user-password-encoded = buf__user._password
               .
            end.
            else do:
               assign
               v-user-login            = temp-userconf.userid_
               v-last-name             = temp-userconf.user-name_
               v-user-password-encoded = temp-userconf.password_
               .
            end.

            assign
               v-user-id = substitute('&1-&2':U
                                    ,g#db-num
                                    ,dynamic-next-value("s-user-id":U, "{&db-name_schema}":U)
                                    )
            .

            create buf_user-account .
            assign
               buf_user-account.user-id               = v-user-id
               buf_user-account.status_               = 0
               buf_user-account.first-name            = '':U
               buf_user-account.second-name           = '':U
               buf_user-account.last-name             = v-last-name
               buf_user-account.company               = '':U
               buf_user-account.department            = '':U
               buf_user-account.e-mail                = '':U
               buf_user-account.internal-phone-number = '':U
               buf_user-account.mobile-phone-number   = '':U
               buf_user-account.phone-number          = '':U
               buf_user-account.position              = '':U
               buf_user-account.PS                    = '':U
               buf_user-account.room                  = '':U
               buf_user-account.parent-user-id        = '':U
               buf_user-account.check-parent          = false
            .

            assign
               v-cntxt-menu-group-id        = '':U
               v-cntxt-level                = {&cntxt-global}
               v-cntxt-host-code-obj        = ?
               v-cntxt-obj-type             = '':U
               v-cntxt-obj-code             = ?
            .

            assign
               v-arm-code-lookup-index = lookup(temp-userconf.ARM, v-arm-code-list)
            .
            if v-arm-code-lookup-index > 0
            then do:
               assign
               v-menu-group-id = entry(v-arm-code-lookup-index
                                       ,v-menu-group-id-list
                                       ,{&comma-char}
                                       )
               .
               find first buf_menu-group
                    where buf_menu-group.menu-code     = {&menu-code-main}
                      and buf_menu-group.menu-group-id = v-menu-group-id
                    no-lock
                    no-error
                    .
               if available buf_menu-group
               then do:
               assign
                  v-cntxt-menu-group-id = buf_menu-group.menu-group-id
               .
               end.
            end.

            find first buf_clients
                 where buf_clients.obj-type = temp-userconf.obj-type
                   and buf_clients.obj-code = temp-userconf.obj-code
                 no-lock
                 no-error
                 .
            if available buf_clients
            then do:
               assign
               v-cntxt-level         = {&cntxt-object}
               v-cntxt-host-code-obj = buf_clients.host-code
               v-cntxt-obj-type      = buf_clients.obj-type
               v-cntxt-obj-code      = buf_clients.obj-code
               .
            end.
            else do:
               find first buf_clients
                    where buf_clients.obj-type = {&cmp}
                      and buf_clients.obj-code = temp-userconf.arm-host-code
                    no-lock
                    no-error
                    .
               if available buf_clients
               then do:
               assign
                  v-cntxt-level         = {&cntxt-firm}
                  v-cntxt-host-code-obj = buf_clients.host-code
                  v-cntxt-obj-type      = buf_clients.obj-type
                  v-cntxt-obj-code      = buf_clients.obj-code
               .
               end.
            end.

            IF NOT CAN-FIND (FIRST ub.user-login
                             where ub.user-login.db-num  = g#db-num
                               and ub.user-login.user-id = v-user-id  )
            then do:
               IF CAN-FIND (FIRST ub.user-login
                            where ub.user-login.db-num  = g#db-num
                              and ub.user-login.user-login = v-user-login)
               THEN DO:
                  message
                     "В системе уже есть пользователь с логином" v-user-login
                     skip
                  view-as alert-box information.
               END.
               ELSE DO:
                  create ub.user-login .
                  assign
                     ub.user-login.db-num                     = g#db-num
                     ub.user-login.user-id                    = v-user-id
                     ub.user-login.last-login-computer-name   = '':U
                     ub.user-login.last-login-computer-userid = '':U
                     ub.user-login.last-login-mjd             = 0.0
                     ub.user-login.last-login-process-id      = 0
                     ub.user-login.login-error-count          = 0
                     ub.user-login.max-discnt                 = temp-userconf.max-discnt
                     ub.user-login.quest-print                = temp-userconf.quest-print
                     ub.user-login.status_                    = {&bef-user-status-normal}
                     ub.user-login.user-administrator         = (if v-user-login = 'адм':U
                                                                  then true
                                                                  else false
                                                               )
                     ub.user-login.user-login                 = v-user-login
                     ub.user-login.user-password-encoded      = v-user-password-encoded
                  .
               END.
            end.
            create buf_user-context-history .
            assign
               buf_user-context-history.db-num                  = g#db-num
               buf_user-context-history.user-id                 = v-user-id
               buf_user-context-history.user-context-history-id = 1
               buf_user-context-history.cntxt-menu-code         = {&menu-code-main}
               buf_user-context-history.cntxt-menu-group-id     = v-cntxt-menu-group-id
               buf_user-context-history.cntxt-level             = v-cntxt-level
               buf_user-context-history.cntxt-host-code         = v-cntxt-host-code-obj
               buf_user-context-history.cntxt-obj-type          = v-cntxt-obj-type
               buf_user-context-history.cntxt-obj-code          = v-cntxt-obj-code
               buf_user-context-history.cntxt-change-mjd        = 0
            .
         END. /* _userconf */
         _user-login:
         for each buf_user-login no-lock
            /* where buf_user-login.db-num = g#db-num */
         on error undo, return error return-value
         :
            _usr-grpa:
            for each  temp-usr-grpa no-lock
                where temp-usr-grpa.user-name = buf_user-login.user-login
            on error undo, return error return-value
            :
               IF lookup( temp-usr-grpa.arm-code, v-arm-code-list) > 0 then do:
               assign
                  v-menu-group-id = entry( lookup( temp-usr-grpa.arm-code, v-arm-code-list), v-menu-group-id-list)
               .
               end.
               else do:
                  next _usr-grpa.
               end. /* lookup */
               FIND FIRST buf_menu-group
                    where buf_menu-group.menu-code     = {&menu-code-main}
                      AND buf_menu-group.menu-group-id = v-menu-group-id
                    no-lock
                    no-error
                    .
               IF NOT AVAILABLE buf_menu-group
               THEN DO:
                  next _usr-grpa.
               END.

               find first buf_user-menu-group
               where buf_user-menu-group.db-num          = g#db-num
                  and buf_user-menu-group.user-id         = buf_user-login.user-id
                  and buf_user-menu-group.menu-code       = {&menu-code-main}
                  and buf_user-menu-group.menu-group-code = buf_menu-group.menu-group-code
                  and buf_user-menu-group.menu-group-context = {&cntxt-firm}
                  and buf_user-menu-group.host-code       = temp-usr-grpa.host-code
                  and buf_user-menu-group.obj-type        = "":U
                  and buf_user-menu-group.obj-code        = 0
                  and buf_user-menu-group.menu-group-id   = v-menu-group-id
               no-error .
               if not available buf_user-menu-group then do:
                  ASSIGN
                     v-user-menu-group-code = next-value(s-user-menu-group, {&db-name_schema})
                  .
                  create buf_user-menu-group.
                  assign
                     buf_user-menu-group.db-num        = g#db-num
                     buf_user-menu-group.user-id       = buf_user-login.user-id
                     buf_user-menu-group.menu-code     = {&menu-code-main}
                     buf_user-menu-group.menu-group-code = buf_menu-group.menu-group-code
                     buf_user-menu-group.menu-group-id = v-menu-group-id
                     buf_user-menu-group.menu-group-context       = {&cntxt-firm}
                     buf_user-menu-group.user-menu-group-code      = v-user-menu-group-code
                     buf_user-menu-group.host-code     = temp-usr-grpa.host-code
                     buf_user-menu-group.obj-type      = "":U
                     buf_user-menu-group.obj-code      = 0
                  .
                  for each temp-usr-grpo no-lock
                     where temp-usr-grpo.user-name = buf_user-login.user-login
                  on error undo, return error return-value
                  :
                     find first buf_clients no-lock
                        where buf_clients.obj-type   = temp-usr-grpo.obj-type
                           and buf_clients.obj-code  = temp-usr-grpo.obj-code
                           and buf_clients.host-code = temp-usr-grpa.host-code
                        no-error .
                     find first buf_user-menu-group
                        where buf_user-menu-group.db-num          = g#db-num
                           and buf_user-menu-group.user-id         = buf_user-login.user-id
                           and buf_user-menu-group.menu-code       = {&menu-code-main}
                           and buf_user-menu-group.menu-group-code = buf_menu-group.menu-group-code
                           and buf_user-menu-group.menu-group-context = {&cntxt-object}
                           and buf_user-menu-group.host-code       = temp-usr-grpa.host-code
                           and buf_user-menu-group.obj-type        = temp-usr-grpo.obj-type
                           and buf_user-menu-group.obj-code        = temp-usr-grpo.obj-code
                           and buf_user-menu-group.menu-group-id   = v-menu-group-id
                        no-error .
                     if  available buf_clients
                     and not available buf_user-menu-group
                     then DO:
                        ASSIGN
                           v-user-menu-group-code = next-value(s-user-menu-group, {&db-name_schema})
                        .
                        create buf_user-menu-group.
                        assign
                           buf_user-menu-group.db-num        = g#db-num
                           buf_user-menu-group.user-id       = buf_user-login.user-id
                           buf_user-menu-group.menu-code     = {&menu-code-main}
                           buf_user-menu-group.menu-group-id = v-menu-group-id
                           buf_user-menu-group.menu-group-code = buf_menu-group.menu-group-code
                           buf_user-menu-group.menu-group-context       = {&cntxt-object}
                           buf_user-menu-group.user-menu-group-code     = v-user-menu-group-code
                           buf_user-menu-group.host-code     = buf_clients.host-code
                           buf_user-menu-group.obj-type      = buf_clients.obj-type
                           buf_user-menu-group.obj-code      = buf_clients.obj-code
                        .
                     end.
                  END. /* usr-grpo */
               end. /* not available buf_user-menu-group */

               find first buf_user-host
               where buf_user-host.db-num    = g#db-num
                  and buf_user-host.user-id   = buf_user-login.user-id
                  and buf_user-host.host-code = temp-usr-grpa.host-code
               no-error .
               if not available buf_user-host
               then do:
                  find first buf_clients no-lock
                     where buf_clients.obj-type = {&cmp}
                        and buf_clients.obj-code = temp-usr-grpa.host-code
                     no-error .
                  if not available buf_clients
                  then do:
                     next _usr-grpa.
                  end.
                  else DO:
                     create buf_user-host .
                     assign
                        buf_user-host.db-num    = g#db-num
                        buf_user-host.user-id   = buf_user-login.user-id
                        buf_user-host.host-code = temp-usr-grpa.host-code
                     .
                  end.
               end. /* not available buf_user-host */
            end. /* usr-grpa */

            _usr-grpo:
            for each temp-usr-grpo no-lock
               where temp-usr-grpo.user-name = buf_user-login.user-login
            on error undo, return error return-value
            :
               find first buf_user-obj
               where buf_user-obj.db-num    = g#db-num
                  and buf_user-obj.user-id   = buf_user-login.user-id
                  and buf_user-obj.obj-type  = temp-usr-grpo.obj-type
                  and buf_user-obj.obj-code  = temp-usr-grpo.obj-code
               no-error .
               if not available buf_user-obj
               then do:
               find first buf_clients no-lock
                  where buf_clients.obj-type = temp-usr-grpo.obj-type
                     and buf_clients.obj-code = temp-usr-grpo.obj-code
                  no-error .
               if not available buf_clients
               then do:
                  next _usr-grpo.
               end.
               else do:
                     create buf_user-obj .
                     assign
                        buf_user-obj.db-num    = g#db-num
                        buf_user-obj.user-id   = buf_user-login.user-id
                        buf_user-obj.obj-type  = temp-usr-grpo.obj-type
                        buf_user-obj.obj-code  = temp-usr-grpo.obj-code
                        buf_user-obj.host-code = buf_clients.host-code
                     .
                     /* Если доступен объект, то должна быть и доступна фирма */
                     find first buf_user-host
                        where buf_user-host.db-num    = g#db-num
                           and buf_user-host.user-id   = buf_user-login.user-id
                           and buf_user-host.host-code = buf_clients.host-code
                     no-error .
                     if not available buf_user-host
                     then do:
                        find first buf_clients no-lock
                           where buf_clients.obj-type = {&cmp}
                              and buf_clients.obj-code = buf_user-obj.host-code
                           no-error .
                        if not available buf_clients
                        then do:
                           next _usr-grpo.
                        end.
                        ELSE DO:
                        create buf_user-host .
                           assign
                              buf_user-host.db-num    = g#db-num
                              buf_user-host.user-id   = buf_user-login.user-id
                              buf_user-host.host-code = buf_user-obj.host-code
                           .
                        end.
                     end.
               end.
               end.
            end.
         end.


         &scop next-line _temp-grpa
         &scop table-name temp-grpa
         _temp-grpa:
         for each temp-grpa no-lock
         on error undo, return error return-value
         :
            /*
            define buffer buf_action-role       for ub.action-role .

            define variable v-global-action-role-code     as integer   no-undo .
            define variable v-firm-action-role-code       as integer   no-undo .
            define variable v-object-action-role-code     as integer   no-undo .
            */

            FIND FIRST buf_action-role
                 WHERE buf_action-role.db-num              = g#db-num
                   and buf_action-role.action-head-code    = {&action-head-code-main}
                   and buf_action-role.action-role-name    = temp-grpa.arm-code + ' ':U + temp-grpa.grp-name
                 no-lock
                 no-error
                 .
            IF NOT AVAILABLE buf_action-role then do:
               next _temp-grpa.
            end.
            assign
               v-object-action-role-code = 0
               v-global-action-role-code = 0
               v-firm-action-role-code   = 0
            .
            case buf_action-role.action-role-context:
               when {&cntxt-object} then do:
                  assign
                     v-object-action-role-code = buf_action-role.action-role-code
                  .
               end.
               when {&cntxt-firm} then do:
                  assign
                     v-firm-action-role-code = buf_action-role.action-role-code
                  .
               end.
               when {&cntxt-global} then do:
                  assign
                     v-global-action-role-code = buf_action-role.action-role-code
                  .
               end.
               otherwise DO:
                  next _temp-grpa.
               end.
             end case.

            if temp-grpa.arm-code = v-obj-name
            then do:
               _temp-grpo:
               for each temp-usr-grpo
                   no-lock
                   where temp-usr-grpo.grp-name = temp-grpa.grp-name
               on error undo, return error return-value
               :
                  find first buf_user-login
                       where buf_user-login.db-num     = g#db-num
                         and buf_user-login.user-login = temp-usr-grpo.user-name
                       no-lock
                       no-error
                       .
                  if not available buf_user-login
                  then do:
                        &scop err-mes (~{&err-mes0~} + " Не найден логин ПОЛЬЗОВАТЕЛЬ(user-login):" ~
                                                     + temp-user-login-action-role.user-id + " БД: "  ~
                                                     + string(temp-user-login-action-role.db-num) ~
                                                     )
                        next _temp-grpo.
                  end.
                  else do:
                     find first buf_clients
                          where buf_clients.obj-type = temp-usr-grpo.obj-type
                            and buf_clients.obj-code = temp-usr-grpo.obj-code
                          no-lock
                          no-error
                          .
                     if not available buf_clients
                     then do:
                        &scop err-mes (~{&err-mes0~} + " Не найден ОБЪЕКТ(clients):" ~
                                                     + temp-usr-grpo.obj-type + " "  ~
                                                     + string(temp-usr-grpo.obj-code) ~
                                                     )
                        next _temp-grpo.
                     end.
                     else do:
                        if v-global-action-role-code <> 0
                        then do:
                           assign
                              v-user-login-role-code = NEXT-VALUE(s-user-login-action-role, {&db-name_schema})
                           .
                           create buf_user-login-action-role .
                           assign
                              buf_user-login-action-role.db-num               = g#db-num
                              buf_user-login-action-role.action-head-code     = {&action-head-code-main}
                              buf_user-login-action-role.user-login-role-code = v-user-login-role-code
                              buf_user-login-action-role.user-id              = buf_user-login.user-id
                              buf_user-login-action-role.action-role-code     = v-global-action-role-code
                              buf_user-login-action-role.action-role-context  = {&right-type-global}
                              buf_user-login-action-role.host-code            = 0
                              buf_user-login-action-role.obj-type             = '':U
                              buf_user-login-action-role.obj-code             = 0
                              buf_user-login-action-role.gds-grp-code         = ?
                              buf_user-login-action-role.gds-code             = ?
                              buf_user-login-action-role.cli-grp-code         = ?
                           .
                        end.

                        if v-firm-action-role-code <> 0
                        then do:
                        assign
                          v-user-login-role-code = dynamic-next-value("s-user-login-action-role":U, "{&db-name_schema}":U)
                        .
                        create buf_user-login-action-role .
                        assign
                           buf_user-login-action-role.db-num               = g#db-num
                           buf_user-login-action-role.action-head-code     = {&action-head-code-main}
                           buf_user-login-action-role.user-login-role-code = v-user-login-role-code
                           buf_user-login-action-role.user-id              = buf_user-login.user-id
                           buf_user-login-action-role.action-role-code     = v-firm-action-role-code
                           buf_user-login-action-role.action-role-context  = {&right-type-firm}
                           buf_user-login-action-role.host-code            = buf_clients.host-code
                           buf_user-login-action-role.obj-type             = '':U
                           buf_user-login-action-role.obj-code             = 0
                           buf_user-login-action-role.gds-grp-code         = ?
                           buf_user-login-action-role.gds-code             = ?
                           buf_user-login-action-role.cli-grp-code         = ?
                        .
                        end.

                        if v-object-action-role-code <> 0
                        then do:
                        assign
                          v-user-login-role-code = dynamic-next-value("s-user-login-action-role":U, "{&db-name_schema}":U)
                        .
                        create buf_user-login-action-role .
                        assign
                           buf_user-login-action-role.db-num               = g#db-num
                           buf_user-login-action-role.action-head-code     = {&action-head-code-main}
                           buf_user-login-action-role.user-login-role-code = v-user-login-role-code
                           buf_user-login-action-role.user-id              = buf_user-login.user-id
                           buf_user-login-action-role.action-role-code     = v-object-action-role-code
                           buf_user-login-action-role.action-role-context  = {&right-type-object}
                           buf_user-login-action-role.host-code            = buf_clients.host-code
                           buf_user-login-action-role.obj-type             = buf_clients.obj-type
                           buf_user-login-action-role.obj-code             = buf_clients.obj-code
                           buf_user-login-action-role.gds-grp-code         = ?
                           buf_user-login-action-role.gds-code             = ?
                           buf_user-login-action-role.cli-grp-code         = ?
                        .
                        end.
                     end.
                  end. /* available user-login */
               end. /* each usr-grpo */
            end.
            else do:
               _temp-usr-grpa:
               for each  temp-usr-grpa
                   where temp-usr-grpa.grp-name = temp-grpa.grp-name
                     and temp-usr-grpa.arm-code = temp-grpa.arm-code
                   no-lock
               on error undo, return error return-value
               :
                  find first buf_user-login
                       where buf_user-login.db-num     = g#db-num
                         and buf_user-login.user-login = temp-usr-grpa.user-name
                       no-lock
                       no-error .
                  if not available buf_user-login
                  then do:
                        &scop err-mes (~{&err-mes0~} + " Не найден логин ПОЛЬЗОВАТЕЛЬ(user-login):" ~
                                                     + temp-user-login-action-role.user-id + "БД:"  ~
                                                     + string(temp-user-login-action-role.db-num) ~
                                                     )
                        next _temp-usr-grpa.
                  end.
                  else do:
                     find first buf_clients no-lock
                        where buf_clients.obj-type = {&cmp}
                        and buf_clients.obj-code = temp-usr-grpa.host-code
                        no-error .
                     if not available buf_clients
                     then do:
                        /* error */
                     end.
                     else do:
                        if v-global-action-role-code <> 0
                        then do:

                        assign
                          v-user-login-role-code = dynamic-next-value("s-user-login-action-role":U, "{&db-name_schema}":U)
                        .
                        create buf_user-login-action-role .
                        assign
                           buf_user-login-action-role.db-num               = g#db-num
                           buf_user-login-action-role.action-head-code     = {&action-head-code-main}
                           buf_user-login-action-role.user-login-role-code = v-user-login-role-code
                           buf_user-login-action-role.user-id              = buf_user-login.user-id
                           buf_user-login-action-role.action-role-code     = v-global-action-role-code
                           buf_user-login-action-role.action-role-context  = {&right-type-global}
                           buf_user-login-action-role.host-code            = 0
                           buf_user-login-action-role.obj-type             = '':U
                           buf_user-login-action-role.obj-code             = 0
                           buf_user-login-action-role.gds-grp-code         = ?
                           buf_user-login-action-role.gds-code             = ?
                           buf_user-login-action-role.cli-grp-code         = ?
                        .
                        end.
                        if v-firm-action-role-code <> 0
                        then do:
                        assign
                          v-user-login-role-code = dynamic-next-value("s-user-login-action-role":U, "{&db-name_schema}":U)
                        .
                        create buf_user-login-action-role .
                        assign
                           buf_user-login-action-role.db-num               = g#db-num
                           buf_user-login-action-role.action-head-code     = {&action-head-code-main}
                           buf_user-login-action-role.user-login-role-code = v-user-login-role-code
                           buf_user-login-action-role.user-id              = buf_user-login.user-id
                           buf_user-login-action-role.action-role-code     = v-firm-action-role-code
                           buf_user-login-action-role.action-role-context  = {&right-type-firm}
                           buf_user-login-action-role.host-code            = buf_clients.obj-code
                           buf_user-login-action-role.obj-type             = '':U
                           buf_user-login-action-role.obj-code             = 0
                           buf_user-login-action-role.gds-grp-code         = ?
                           buf_user-login-action-role.gds-code             = ?
                           buf_user-login-action-role.cli-grp-code         = ?
                        .
                        end.
                     end.
                  end.
               end. /* each usr-gpra */
            end.
         end.



      end.
   end case. /* p-vertion */

   _usr-flt:
   FOR EACH temp-usr-flt:
      /*
      FIND FIRST ubflt.usr-flt No-LOCK WHERE
                  ubflt.usr-flt.user-name = temp-usr-flt.user-name AND
                  ubflt.usr-flt.call-point = temp-usr-flt.call-point NO-ERROR.
      IF AVAILABLE ubflt.usr-flt then do:
         &scop err-mes (~{&err-mes0~} + " Уже есть ФИЛЬТР ДЛЯ ПОЛЬЗОВАТЕЛЯ(usr-flt):" + ~
                        " имя пользователя " + temp-usr-flt.user-name + ~
                        " точка вызова фильтра " + temp-usr-flt.call-point)
         {&wl-mes}
      END.
      FIND FIRST ub.userconf No-LOCK WHERE
                  ub.userconf.user-name = temp-usr-flt.user-name No-ERROR.
      IF NOT AVAILABLE ub.userconf then do:
         &scop err-mes (~{&err-mes0~} + " Нет ПОЛЬЗОВАТЕЛЯ для ФИЛЬТРА ДЛЯ ПОЛЬЗОВАТЕЛЯ(usr-flt):" + ~
                        " имя пользователя " + temp-usr-flt.user-name + ~
                        " точка вызова фильтра " + temp-usr-flt.call-point)
         {&wl-mes}
      END.
      FIND FIRST buf-filter No-LOCK WHERE
                  buf-filter.NAIM = temp-usr-flt.NAIM AND
                  buf-filter.call-point = temp-usr-flt.call-point No-ERROR.
      IF NOT AVAILABLE buf-filter then do:
         &scop err-mes (~{&err-mes0~} + " Нет ФИЛЬТРА для ФИЛЬТРА ДЛЯ ПОЛЬЗОВАТЕЛЯ(usr-flt):" + ~
                        " имя пользователя " + temp-usr-flt.user-name + ~
                        " точка вызова фильтра " + temp-usr-flt.call-point)
         {&wl-mes}
      END.
      create ubflt.usr-flt.
      buffer-copy temp-usr-flt to ubflt.usr-flt.
      release ubflt.usr-flt No-error.
      if error-status:error then do:
         {&get-mes}
         &scop err-mes (~{&err-mes0~} +  " ошибка при сохранении записи ФИЛЬТР ДЛЯ ПОЛЬЗОВАТЕЛЯ(usr-flt):" + ~
                                       " имя пользователя " + temp-usr-flt.user-name + ~
                                       " точка вызова фильтра " + temp-usr-flt.call-point + ~
                                       er-mes)
         {&undo-mes}
      end.
      */
   END. /*for each temp-usr-flt*/
end.

if p-seq then do:
  &scop current-data-group "seq":U
  &scop err-mes0 "Проверка группы данных СЧЕТЧИКИ" + ~{&new-line~}
  &scop wait-mess "Проверка группы данных СЧЕТЧИКИ"
  {&waitc}
  &scop next-line _sequencev
  &scop table-name temp_sequence
  _sequencev:
  FOR EACH temp_sequence NO-LOCK:
    FIND FIRST {&db-name_schema}._sequence No-LOCK WHERE
              {&db-name_schema}._sequence._seq-name = temp_sequence.seq-name NO-ERROR.
    IF NOT AVAILABLE ubflt.filter then do:
      &scop err-mes (~{&err-mes0~} + " В БД нет СЧЕТЧИКА(sequence):" + ~
                      " название " + string(temp_sequence.seq-name))
      {&wl-mes}
    end.
    if dynamic-current-value( temp_sequence.seq-name, "{&db-name_schema}":U ) < temp_sequence.seq-val then do:
      assign
        dynamic-current-value( temp_sequence.seq-name, "{&db-name_schema}":U ) = temp_sequence.seq-val
      .
    end. /* v-seq-val < temp_sequence.seq-val*/
  END.
end.




session:system-alert-boxes = loc-alert-box.


procedure p-gen-i :

  do
  on error undo, return error
  :
&scop next-line _gen
&scop err-mes0   ("Импорт группы данных ИНФОРМАЦИЯ O БД, СТРОКА " + string(ii) + ~{&new-line~})
&scop current-data-group "gen":U
&scop wait-mess "Импорт группы данных ИНФОРМАЦИЯ O БД"
&scop err-mes (~{&wait-mess~} + " Файл: " + p-dir-name + "\":U + p-db-key + ".":U + ~{&current-data-group~})
  {&wl}
  {&check-file}
  {&ii0}
  if loc#log then do:
    {&waitc}
    {&input-stream}
    _gen:
    REPEAT:
      {&imp-stream-ss}
      CASE ss:
        when "config":U then do:
          current-table = ss.
          case current-table:
            when "config":U then do:
              {&ii1}
              create buf-config.
              CASE p-version:
                when "12.3" then do:
                  {&imp-stream} {&ie-config-fields-123} no-error.
                end.
                when "14.1" then do:
                  {&imp-stream} {&ie-config-fields-14} no-error.
                end.
                otherwise do:
                  {&imp-stream} {&ie-config-fields} no-error.
                end.
              END CASE.
              &scop err-mes ~{&errimp-mes~}
              {&wlerimp-mes}
              &scop table-name buf-config
              IF CAN-FIND(FIRST temp-config No-LOCK WHERE
                                temp-config.param-code = buf-config.param-code AND
                                temp-config.host-code = buf-config.host-code AND
                                temp-config.obj-type = buf-config.obj-type AND
                                temp-config.obj-code = buf-config.obj-code
                                 )
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть запись НАСТРОЕЧНОГО ПАРАМЕТРА(config)" + ~
                                  " параметр " + buf-config.param-code + ~
                                  " Фирма " + string(buf-config.host-code) + ~
                                  " тип объекта " + buf-config.obj-type + ~
                                  " код объекта " + string(buf-config.obj-code) )
                  {&wl-mes}
              end.
              if lookup( buf-config.conf-type, {&cnf-type-list-protect} ) > 0 then do:
                  &scop err-mes (~{&err-mes0~} + " НАСТРОЕЧНОГО ПАРАМЕТРА(config) является кодированным" + ~
                                  " параметр " + buf-config.param-code + ~
                                  " Фирма " + string(buf-config.host-code) + ~
                                  " тип объекта " + buf-config.obj-type + ~
                                  " код объекта " + string(buf-config.obj-code) )
                  {&wl-mes}
              end.
              create temp-config.
              buffer-copy buf-config to temp-config.
              delete buf-config.
            end.
          end CASE.
        end.
        otherwise do:
        end.
      END CASE.
    END.
    {&close-stream}
  end.

  end.

end procedure. /* p-gen-i */

procedure p-flt-i :

  do
  on error undo, return error
  :
&scop next-line _flt
&scop err-mes0   ("Импорт группы данных ФИЛЬТРЫ, СТРОКА " + string(ii) + ~{&new-line~})
&scop current-data-group "flt":U
&scop wait-mess "Импорт группы данных ФИЛЬТРЫ"
&scop err-mes (~{&wait-mess~} + " Файл: " + p-dir-name + "\":U + p-db-key + ".":U + ~{&current-data-group~})
  {&wl}
  {&check-file}
  {&ii0}
  if loc#log then do:
    {&waitc}
    {&input-stream}
    _flt:
    REPEAT:
      {&imp-stream-ss}
      CASE ss:
        when "filter":U then do:
          current-table = ss.
          case current-table:
            when "filter":U then do:
              {&ii1}
              create buf-filter.
              {&imp-stream} {&ie-filter-fields} no-error.
              &scop err-mes ~{&errimp-mes~}
              {&wlerimp-mes}
              &scop table-name buf-filter
              assign
              buf-filter.where-ysl = replace(buf-filter.where-ysl, {&delim-nws}, {&delim-par})
              buf-filter.where-ysl-rus = replace(buf-filter.where-ysl-rus, {&delim-nws}, {&delim-par})
              buf-filter.fields-sort-rus = replace(buf-filter.fields-sort-rus, {&delim-nws}, {&delim-par})
              buf-filter.fields-sort = replace(buf-filter.fields-sort, {&delim-nws}, {&delim-par})
              buf-filter.call-point = replace(buf-filter.call-point, {&delim-nws}, {&delim-par})
              .
              IF CAN-FIND(FIRST temp-filter No-LOCK WHERE
                                temp-filter.call-point = buf-filter.call-point AND
                                temp-filter.NAIM = buf-filter.NAIM
                                )
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть ФИЛЬТР(filter):" + ~
                                 " название " + string(buf-filter.Naim) + ~
                                 " точка вызова " + buf-filter.call-point)
                  {&wl-mes}
              end.
              create temp-filter.
              buffer-copy buf-filter to temp-filter.
              delete buf-filter.
            end.
          end CASE.
        end.
        otherwise do:
        end.
      END CASE.
    END.
    {&close-stream}
  end.
  end.

end procedure. /* p-flt-i */

procedure p-pbc-i :

  do
  on error undo, return error
  :
&scop next-line _pbc
&scop err-mes0   ("Импорт группы данных ВЕС и ВЗВЕШ КОДЫ, СТРОКА " + string(ii) + ~{&new-line~})
&scop current-data-group "pbc":U
&scop wait-mess "Импорт группы данных ВЕС и ВЗВЕШ КОДЫ"
&scop err-mes (~{&wait-mess~} + " Файл: " + p-dir-name + "\":U + p-db-key + ".":U + ~{&current-data-group~})
  {&wl}
  {&check-file}
  {&ii0}
  if loc#log then do:
    {&waitc}
    {&input-stream}
    _pbc:
    REPEAT:
      {&imp-stream-ss}
      CASE ss:
        when "prod-bc":U then do:
          current-table = ss.
          case current-table:
            when "prod-bc":U then do:
              {&ii1}
              create buf-prod-bc.
              {&imp-stream} {&ie-prod-bc-fields} no-error.
              &scop err-mes ~{&errimp-mes~}
              {&wlerimp-mes}
              &scop table-name buf-prod-bc
              IF CAN-FIND(FIRST temp-prod-bc No-LOCK WHERE
                                temp-prod-bc.b-str = buf-prod-bc.b-str
                            AND temp-prod-bc.b-code = buf-prod-bc.b-code )
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть ДопБК(prod-bc):" + ~
                                 " ДопБК " + string(buf-prod-bc.b-str) + ~
                                 " Бар-код " + string(buf-prod-bc.b-code))
                  {&wl-mes}
              end.
              create temp-prod-bc.
              buffer-copy buf-prod-bc to temp-prod-bc.
              delete buf-prod-bc.
            end.
            when "gds-obj-attr":U then do:
              {&ii1}
              create ub.gds-obj-attr.
              {&imp-stream} {&ie-gds-obj-attr-fields} no-error.
              &scop err-mes ~{&errimp-mes~}
              {&wlerimp-mes}
              &scop table-name buf-gds-obj-attr
              IF CAN-FIND(FIRST temp-gds-obj-attr No-LOCK WHERE
                                temp-gds-obj-attr.gds-code = buf-gds-obj-attr.gds-code
                            AND temp-gds-obj-attr.obj-type = buf-gds-obj-attr.obj-type
                            AND temp-gds-obj-attr.obj-code = buf-gds-obj-attr.obj-code
                            AND temp-gds-obj-attr.attr-code = buf-gds-obj-attr.attr-code )
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть атрибут товара ВЕСОВОЙ КОД НА ОБЪЕКТЕ(gds-obj-attr):" + ~
                                 " Код товара " + string(buf-gds-obj-attr.gds-code) + ~
                                 " Объект " + gds-obj-attr.obj-type + string(buf-gds-obj-attr.obj-code) + ~
                                 " Весовой код " + string(buf-gds-obj-attr.attr-value) )
                  {&wl-mes}
              end.
              create temp-gds-obj-attr.
              buffer-copy buf-gds-obj-attr to temp-gds-obj-attr.
              delete buf-gds-obj-attr.
            end.
          end CASE.
        end.
        otherwise do:
        end.
      END CASE.
    END.
    {&close-stream}
  end.

  end.

end procedure. /* p-pbc-i */

procedure p-scl-i :

  do
  on error undo, return error
  :
&scop next-line _scl
&scop err-mes0   ("Импорт группы данных ВЕСЫ, СТРОКА " + string(ii) + ~{&new-line~})
&scop current-data-group "scl":U
&scop wait-mess "Импорт группы данных ВЕСЫ"
&scop err-mes (~{&wait-mess~} + " Файл: " + p-dir-name + "\":U + p-db-key + ".":U + ~{&current-data-group~})
  {&wl}
  {&check-file}
  {&ii0}
  if loc#log then do:
    {&waitc}
    {&input-stream}
    _scl:
    REPEAT:
      {&imp-stream-ss}
      CASE ss:
        when "scales":U or when "scales-gds":U or when "scales-grp":U then do:
          current-table = ss.
          case current-table:
            when "scales":U then do:
              {&ii1}
              create buf-scales.
              CASE p-version:
                when "12.3" then do:
                  {&imp-stream} {&ie-scales-fields-123} no-error.
                end.
                when "14.1" then do:
                  {&imp-stream} {&ie-scales-fields-141} no-error.
                end.
                when "15.0" then do:
                  {&imp-stream} {&ie-scales-fields} no-error.
                end.
              END CASE.
              &scop err-mes ~{&errimp-mes~}
              {&wlerimp-mes}
              &scop table-name buf-scales
              IF CAN-FIND(FIRST temp-scales No-LOCK WHERE
                                temp-scales.db-num = buf-scales.db-num AND
                                temp-scales.scales-num = buf-scales.scales-num )
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть ВЕСЫ(scales):" + ~
                                 " номер " + string(buf-scales.scales-num))
                  {&wl-mes}
              end.
              create temp-scales.
              buffer-copy buf-scales to temp-scales.
              assign
              temp-scales.db-num = (if p-version < "15.0"
                                    then g#db-num
                                    else temp-scales.db-num)
              .
              delete buf-scales.
            end.
            when "scales-gds":U then do:
              {&ii1}
              create buf-scales-gds.
              CASE p-version:
                when "15.0" then do:
                   {&imp-stream} {&ie-scales-gds-fields} no-error.
                end.
                otherwise do:
                  {&imp-stream} {&ie-scales-gds-fields-123} no-error.
                end.
              END CASE.
              &scop err-mes ~{&errimp-mes~}
              {&wlerimp-mes}
              &scop table-name buf-scales-gds
              IF CAN-FIND(FIRST temp-scales-gds No-LOCK WHERE
                                temp-scales-gds.db-num = buf-scales-gds.db-num AND
                                temp-scales-gds.scales-num = buf-scales-gds.scales-num AND
                                temp-scales-gds.PLU-code = buf-scales-gds.PLU-code)
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть ТОВАР НА ВЕСАХ(scales-gds):" + ~
                                 " номер весов " + string(buf-scales-gds.scales-num) + ~
                                 " PLU " + string(buf-scales-gds.PLU-code))
                  {&wl-mes}
              end.
              IF CAN-FIND(FIRST temp-scales-gds No-LOCK WHERE
                                temp-scales-gds.db-num = buf-scales-gds.db-num AND
                                temp-scales-gds.scales-num = buf-scales-gds.scales-num AND
                                temp-scales-gds.b-code = buf-scales-gds.b-code)
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть ТОВАР НА ВЕСАХ(scales-gds):" + ~
                                 " номер весов " + string(buf-scales-gds.scales-num) + ~
                                 " бар-код " + string(buf-scales-gds.b-code))
                  {&wl-mes}
              end.
              create temp-scales-gds.
              buffer-copy buf-scales-gds to temp-scales-gds
              assign
              temp-scales-gds.db-num = (if p-version < "15.0"
                                    then g#db-num
                                    else temp-scales-gds.db-num)
              .
              delete buf-scales-gds.
            end.
            when "scales-grp":U then do:
              {&ii1}
              create buf-scales-grp.
              {&imp-stream} {&ie-scales-grp-fields} no-error.
              &scop err-mes ~{&errimp-mes~}
              {&wlerimp-mes}
              &scop table-name buf-scales-grp
              IF CAN-FIND(FIRST temp-scales-grp No-LOCK WHERE
                                temp-scales-grp.db-num = buf-scales-grp.db-num AND
                                temp-scales-grp.scales-num = buf-scales-grp.scales-num AND
                                temp-scales-grp.node-code = buf-scales-grp.node-code)
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть ГРУППА ТОВАРА НА ВЕСАХ(scales-grp):" + ~
                                 " номер группы " + string(buf-scales-grp.node-code) + ~
                                 " номер весов " + string(buf-scales-grp.scales-num))
                  {&wl-mes}
              end.
              create temp-scales-grp.
              buffer-copy buf-scales-grp to temp-scales-grp.
              assign temp-scales-grp.db-num = g#db-num.
              delete buf-scales-grp.
            end.
          end CASE.
        end.
        otherwise do:
        end.
      END CASE.
    END.
    {&close-stream}
  end.

  end.

end procedure. /* p-scl-i */


procedure p-seq-i :

  do
  on error undo, return error
  :
&scop next-line _seq
&scop err-mes0   ("Импорт группы данных СЧЕТЧИКИ, СТРОКА " + string(ii) + ~{&new-line~})
&scop current-data-group "seq":U
&scop wait-mess "Импорт группы данных СЧЕТЧИКИ"
&scop err-mes (~{&wait-mess~} + " Файл: " + p-dir-name + "\":U + p-db-key + ".":U + ~{&current-data-group~})
  {&wl}
  {&check-file}
  {&ii0}
  if loc#log then do:
    {&waitc}
    {&input-stream}
    _seq:
    REPEAT:
      {&imp-stream-ss}
      CASE ss:
        when "_sequence":U then do:
          current-table = ss.
          case current-table:
            when "sequence":U then do:
              {&ii1}
              create buf_sequence.
              {&imp-stream} {&ie_sequence-fields} no-error.
              &scop err-mes ~{&errimp-mes~}
              {&wlerimp-mes}
              &scop table-name buf_sequence
              if LOOKUP(buf_sequence.seq-name, {&load-sequence} ) = 0 then next _seq.
              IF CAN-FIND(FIRST temp_sequence No-LOCK WHERE
                                temp_sequence.seq-name = buf_sequence.seq-name
                                )
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть СЧЕТЧИК(sequence):" + ~
                                 " название " + string(buf_sequence.seq-name))
                  {&wl-mes}
              end.
              create temp_sequence.
              buffer-copy buf_sequence to temp_sequence.
              delete buf_sequence.
            end.
          end CASE.
        end.
        otherwise do:
        end.
      END CASE.
    END.
    {&close-stream}
  end.

  end.

end procedure. /* p-seq-i */

procedure p-rht-i :
define variable v-curr-seek as integer no-undo .

  do
  on error undo, return error
  :
&scop next-line _rht
&scop err-mes0   ("Импорт группы данных ПРАВА, СТРОКА " + string(ii) + ~{&new-line~})
&scop current-data-group "rht":U
&scop wait-mess "Импорт группы данных ПРАВА"
&scop err-mes (~{&wait-mess~} + " Файл: " + p-dir-name + "\":U + p-db-key + ".":U + ~{&current-data-group~})
   {&wl}
   {&check-file}
   {&ii0}
   if loc#log then do:
      {&waitc}
      {&input-stream}
      CASE p-version:
         when "15.0" then do:
               _rht:
               REPEAT:
                  {&imp-stream-ss}
                  {&ii1}
                  CASE ss:
                  when "action-role":U or
                  when "action-role-item":U
                  then do:
                     current-table = ss.
                     case current-table:
                        when "action-role":U then do:
                           {&ii1}
                           create buf-action-role.
                           v-curr-seek = seek(instream).
                           {&imp-stream} {&ie-action-role-fields} no-error.
                           &scop err-mes ~{&errimp-mes~}
                           {&wlerimp-mes}
                           &scop table-name buf-action-role
                           if buf-action-role.db-num <> g#db-num then do:
                              &scop err-mes (~{&err-mes0~} + "  ИГНОРИРУЕМ РОЛЬ(action-role) ЧУЖОЙ БД: " ~
                                                          + STRING(buf-action-role.db-num) + " " ~
                                                          + STRING(buf-action-role.action-head-code) + " " ~
                                                          + STRING(buf-action-role.action-role-code) ~
                                                          )
                              {&wl-mes}
                           end.
                           IF CAN-FIND(FIRST temp-action-role No-LOCK
                                       WHERE temp-action-role.db-num    = buf-action-role.db-num
                                         and temp-action-role.action-head-code = buf-action-role.action-head-code
                                         and temp-action-role.action-role-code = buf-action-role.action-role-code
                                       )
                                             then do:
                                 &scop err-mes (~{&err-mes0~} + " Уже есть РОЛЬ(action-role): " ~
                                                              + STRING(buf-action-role.db-num) + " " ~
                                                              + STRING(buf-action-role.action-head-code) + " " ~
                                                              + STRING(buf-action-role.action-role-code) ~
                                                              )
                                 {&wl-mes}
                           end.
                           create temp-action-role.
                           buffer-copy
                           buf-action-role to temp-action-role.
                           delete buf-action-role.
                        end.
                        when "action-role-item":U then do:
                           {&ii1}
                           create buf-action-role-item.
                           v-curr-seek = seek(instream).
                           {&imp-stream} {&ie-action-role-item-fields} no-error.
                           &scop err-mes ~{&errimp-mes~}
                           {&wlerimp-mes}
                           &scop table-name buf-action-role-item
                           if buf-action-role-item.db-num <> g#db-num then do:
                              &scop err-mes (~{&err-mes0~} + " ИГНОРИРУЕМ РОЛЬ(action-role-item) ДЛЯ ЧУЖОЙ БД: " ~
                                                          + STRING(buf-action-role-item.db-num) + " " ~
                                                          + STRING(buf-action-role-item.action-head-code) + " " ~
                                                          + STRING(buf-action-role-item.action-role-code) + " " ~
                                                          + STRING(buf-action-role-item.action-role-item-code) ~
                                                          )
                              {&wl-mes}
                           end.
                           IF CAN-FIND(FIRST temp-action-role-item No-LOCK
                                       WHERE temp-action-role-item.db-num                = buf-action-role-item.db-num
                                         and temp-action-role-item.action-head-code      = buf-action-role-item.action-head-code
                                         and temp-action-role-item.action-role-code      = buf-action-role-item.action-role-code
                                         and temp-action-role-item.action-role-item-code = buf-action-role-item.action-role-item-code
                                       )
                                             then do:
                                 &scop err-mes (~{&err-mes0~} + " Уже есть РОЛЬ(action-role-item): " ~
                                                              + STRING(buf-action-role-item.db-num) + " " ~
                                                              + STRING(buf-action-role-item.action-head-code) + " " ~
                                                              + STRING(buf-action-role-item.action-role-code) + " " ~
                                                              + STRING(buf-action-role-item.action-role-item-code) ~
                                                              )
                                 {&wl-mes}
                           end.
                           create temp-action-role-item.
                           buffer-copy
                           buf-action-role-item to temp-action-role-item.
                           delete buf-action-role-item.
                        end.
                     end CASE. /* current-table */
                  end.
                  otherwise do:
                  end.
                  END CASE. /* ss */
               END. /* repeat*/
         end. /* 15.0 */
         otherwise do:
            _rht:
            REPEAT:
               {&imp-stream-ss}
               CASE ss:
               when "grpa":U or when "grp-acta":U then do:
                  current-table = ss.
                  case current-table:
                     when "grpa":U then do:
                     {&ii1}
                     create buf-grpa.
                     {&imp-stream} {&ie-grpa-fields} no-error.
                     &scop err-mes ~{&errimp-mes~}
                     {&wlerimp-mes}
                     &scop table-name buf-grpa
                     IF CAN-FIND(FIRST temp-grpa NO-LOCK WHERE
                                       temp-grpa.grp-name = buf-grpa.grp-name AND
                                       temp-grpa.arm-code = buf-grpa.arm-code) then do:
                           &scop err-mes (~{&err-mes0~} + " Уже есть ГРУППЫ ПРАВ(grpa):" + ~
                                          " группа " + buf-grpa.grp-name + ~
                                          " АРМ " + buf-grpa.arm-code)
                        {&wl-mes}
                     END.
                     create temp-grpa.
                     buffer-copy buf-grpa to temp-grpa.
                     delete buf-grpa.
                     end.
                     when "grp-acta":U then do:
                     {&ii1}
                     create buf-grp-acta.
                     {&imp-stream} {&ie-grp-acta-fields} no-error.
                     &scop err-mes ~{&errimp-mes~}
                     {&wlerimp-mes}
                     &scop table-name buf-grp-acta
                     IF CAN-FIND(FIRST temp-grp-acta NO-LOCK WHERE
                                       temp-grp-acta.grp-name = buf-grp-acta.grp-name AND
                                       temp-grp-acta.arm-code = buf-grp-acta.arm-code AND
                                       temp-grp-acta.object = buf-grp-acta.object AND
                                       temp-grp-acta.act = buf-grp-acta.act) then do:
                           &scop err-mes (~{&err-mes0~} + " Уже есть ПРАВА ДЛЯ ГРУППЫ(grp-acta):" + ~
                                          " АРМ " + buf-grp-acta.arm-code + ~
                                          " группа " + buf-grp-acta.grp-name + ~
                                          " объект " + buf-grp-acta.object + ~
                                          " действие " + buf-grp-acta.act)
                        {&wl-mes}
                     END.
                     create temp-grp-acta.
                     buffer-copy buf-grp-acta to temp-grp-acta.
                     delete buf-grp-acta.
                     end.
                  end CASE.
               end.
               otherwise do:
               end.
               END CASE.
            END. /* repeat */
            end. /* otherwise */
      END CASE. /* p-version */
      {&close-stream}
     end. /* loc#log */
     else do:
         return error.
     end.
  end. /* do on error */
end procedure. /* p-rht-i */

procedure p-usr-i :
define variable v-curr-seek as integer no-undo .

  do
  on error undo, return error
  :
&scop current-data-group "usr":U
&scop wait-mess "Импорт группы данных ПОЛЬЗОВАТЕЛИ"
&scop next-line _usr
&scop err-mes0   ("Импорт ПОЛЬЗОВАТЕЛЕЙ, СТРОКА " + string(ii) + ~{&new-line~})
&scop err-mes (~{&wait-mess~} + " Файл: " + p-dir-name + "\":U + p-db-key + ".":U + ~{&current-data-group~})
   {&wl}
   {&check-file}
   {&ii0}
   if loc#log then do:
      {&waitc}
      {&input-stream}
      CASE p-version:
         when "15.0" then do:
               _usr:
               REPEAT:
                  {&imp-stream-ss}
                  {&ii1}
                  CASE ss:
                  when "user-account":U or
                  when "user-login":U or
                  when "user-obj":U or
                  when "user-host":U or
                  when "user-menu-group":U or
                  when "user-login-action-role":U or
                  when "action-role":U or
                  when "action-role-item":U or
                  when "usr-flt":U
                  then do:
                     current-table = ss.
                     case current-table:
                        when "user-account":U then do:
                           {&ii1}
                           create buf-user-account.
                           v-curr-seek = seek(instream).
                           {&imp-stream} {&ie-user-account-fields} no-error.
                           &scop err-mes ~{&errimp-mes~}
                           {&wlerimp-mes}
                           &scop table-name buf-user-account
                           IF CAN-FIND(FIRST temp-user-account No-LOCK WHERE
                                             temp-user-account.user-id = buf-user-account.user-id) then do:
                                 &scop err-mes (~{&err-mes0~} + " Уже есть ПОЛЬЗОВАТЕЛЬ(user-account): " + buf-user-account.user-id)
                                 {&wl-mes}
                           end.
                           create temp-user-account.
                           buffer-copy
                           buf-user-account to temp-user-account.
                           delete buf-user-account.
                        end.
                        when "user-login":U then do:
                           {&ii1}
                           create buf-user-login.
                           v-curr-seek = seek(instream).
                           {&imp-stream} {&ie-user-login-fields} no-error.
                           &scop err-mes ~{&errimp-mes~}
                           {&wlerimp-mes}
                           &scop table-name buf-user-login
                           if buf-user-login.db-num <> g#db-num then do:
                              &scop err-mes (~{&err-mes0~} + " ИГНОРИРУЕМ ПОЛЬЗОВАТЕЛЯ(user-login) ЧУЖОЙ БД: " + buf-user-login.user-id)
                              {&wl-mes}
                           end.
                           IF CAN-FIND(FIRST temp-user-login No-LOCK
                                       WHERE temp-user-login.user-id = buf-user-login.user-id
                                         and temp-user-login.db-num  = buf-user-login.db-num
                                       )
                                             then do:
                                 &scop err-mes (~{&err-mes0~} + " Уже есть ПОЛЬЗОВАТЕЛЬ(user-login): " + buf-user-login.user-id)
                                 {&wl-mes}
                           end.
                           create temp-user-login.
                           buffer-copy
                           buf-user-login to temp-user-login.
                           delete buf-user-login.
                        end.
                        when "user-obj":U then do:
                           {&ii1}
                           create buf-user-obj.
                           v-curr-seek = seek(instream).
                           {&imp-stream} {&ie-user-obj-fields} no-error.
                           &scop err-mes ~{&errimp-mes~}
                           {&wlerimp-mes}
                           &scop table-name buf-user-obj
                           if buf-user-obj.db-num <> g#db-num then do:
                              &scop err-mes (~{&err-mes0~} + " ИГНОРИРЕУМ ПОЛЬЗОВАТЕЛЯ(user-obj) ЧУЖОЙ БД: " + buf-user-obj.user-id)
                              {&wl-mes}
                           end.
                           IF CAN-FIND(FIRST temp-user-obj No-LOCK
                                       WHERE temp-user-obj.user-id  = buf-user-obj.user-id
                                         and temp-user-obj.db-num   = buf-user-obj.db-num
                                         and temp-user-obj.obj-type = buf-user-obj.obj-type
                                         and temp-user-obj.obj-code = buf-user-obj.obj-code
                                       )
                                             then do:
                                 &scop err-mes (~{&err-mes0~} + " Уже есть ПОЛЬЗОВАТЕЛЬ(user-obj): " + buf-user-obj.user-id)
                                 {&wl-mes}
                           end.
                           create temp-user-obj.
                           buffer-copy
                           buf-user-obj to temp-user-obj.
                           delete buf-user-obj.
                        end.
                        when "user-host":U then do:
                           {&ii1}
                           create buf-user-host.
                           v-curr-seek = seek(instream).
                           {&imp-stream} {&ie-user-host-fields} no-error.
                           &scop err-mes ~{&errimp-mes~}
                           {&wlerimp-mes}
                           &scop table-name buf-user-host
                           if buf-user-host.db-num <> g#db-num then do:
                              &scop err-mes (~{&err-mes0~} + " ИГНОРИРУЕМ ПОЛЬЗОВАТЕЛЯ(user-host) ЧУЖОЙ БД: " + buf-user-host.user-id)
                              {&wl-mes}
                           end.
                           IF CAN-FIND(FIRST temp-user-host No-LOCK
                                       WHERE temp-user-host.user-id   = buf-user-host.user-id
                                         and temp-user-host.db-num    = buf-user-host.db-num
                                         and temp-user-host.host-code = buf-user-host.host-code
                                       )
                                             then do:
                                 &scop err-mes (~{&err-mes0~} + " Уже есть ПОЛЬЗОВАТЕЛЬ(user-host): " + buf-user-host.user-id)
                                 {&wl-mes}
                           end.
                           create temp-user-host.
                           buffer-copy
                           buf-user-host to temp-user-host.
                           delete buf-user-host.
                        end.
                        when "user-login-action-role":U then do:
                           {&ii1}
                           create buf-user-login-action-role.
                           v-curr-seek = seek(instream).
                           {&imp-stream} {&ie-user-login-action-role-fields} no-error.
                           &scop err-mes ~{&errimp-mes~}
                           {&wlerimp-mes}
                           &scop table-name buf-user-login-action-role
                           if buf-user-login-action-role.db-num <> g#db-num then do:
                              &scop err-mes (~{&err-mes0~} + " ИГНОРИРЕМ ПОЛЬЗОВАТЕЛЯ(user-login-action-role) ЧУЖОЙ БД: " + STRING(buf-user-login-action-role.user-login-role-code))
                              {&wl-mes}
                           end.
                           IF CAN-FIND(FIRST temp-user-login-action-role No-LOCK
                                       WHERE temp-user-login-action-role.db-num               = buf-user-login-action-role.db-num
                                         and temp-user-login-action-role.action-head-code     = buf-user-login-action-role.action-head-code
                                         and temp-user-login-action-role.user-login-role-code = buf-user-login-action-role.user-login-role-code
                                       )
                                             then do:
                                 &scop err-mes (~{&err-mes0~} + " Уже есть ПОЛЬЗОВАТЕЛЬ(user-login-action-role): " + STRING(buf-user-login-action-role.user-login-role-code))
                                 {&wl-mes}
                           end.
                           create temp-user-login-action-role.
                           buffer-copy
                           buf-user-login-action-role to temp-user-login-action-role.
                           delete buf-user-login-action-role.
                        end.
                        when "user-menu-group":U then do:
                           {&ii1}
                           create buf-user-menu-group.
                           v-curr-seek = seek(instream).
                           {&imp-stream} {&ie-user-menu-group-fields} no-error.
                           &scop err-mes ~{&errimp-mes~}
                           {&wlerimp-mes}
                           &scop table-name buf-user-menu-group
                           if buf-user-menu-group.db-num <> g#db-num then do:
                              &scop err-mes (~{&err-mes0~} + " ИГНОРИРЕУМ ПОЛЬЗОВАТЕЛЯ(user-menu-group) ЧУЖОЙ БД: " + STRING(buf-user-menu-group.user-menu-group-code))
                              {&wl-mes}
                           end.
                           IF CAN-FIND(FIRST temp-user-menu-group No-LOCK
                                       WHERE temp-user-menu-group.db-num               = buf-user-menu-group.db-num
                                         and temp-user-menu-group.user-id              = buf-user-menu-group.user-id
                                         and temp-user-menu-group.user-menu-group-code = buf-user-menu-group.user-menu-group-code
                                       )
                                             then do:
                                 &scop err-mes (~{&err-mes0~} + " Уже есть ПОЛЬЗОВАТЕЛЬ(user-menu-group): " + STRING(buf-user-menu-group.user-menu-group-code))
                                 {&wl-mes}
                           end.
                           create temp-user-menu-group.
                           buffer-copy
                           buf-user-menu-group to temp-user-menu-group.
                           delete buf-user-menu-group.
                        end.
                        when "usr-flt":U then do:
                           {&ii1}
                           create buf-usr-flt.
                           {&imp-stream} {&ie-usr-flt-fields} no-error.
                           &scop err-mes ~{&errimp-mes~}
                           {&wlerimp-mes}
                           &scop table-name buf-usr-flt
                           assign
                           buf-usr-flt.call-point = replace(buf-usr-flt.call-point, {&delim-nws}, {&delim-par})
                           .
                           IF CAN-FIND(FIrst temp-usr-flt NO-LOCK WHERE
                                             temp-usr-flt.user-name = buf-usr-flt.user-name AND
                                             temp-usr-flt.call-point = buf-usr-flt.call-point) then do:
                                 &scop err-mes (~{&err-mes0~} + " Уже есть ФИЛЬТР ДЛЯ ПОЛЬЗОВАТЕЛЯ(usr-flt):" + ~
                                                " имя пользователя " + buf-usr-flt.user-name + ~
                                                " точка вызова фильтра " + buf-usr-flt.call-point)
                                 {&wl-mes}
                           end.
                           create temp-usr-flt.
                           buffer-copy buf-usr-flt to temp-usr-flt.
                           delete buf-usr-flt.
                        end.
                     end CASE. /* current-table */
                  end.
                  otherwise do:
                  end.
                  END CASE. /* ss */
               END. /* repeat*/
         end. /* 15.0 */
         otherwise do:
               _usr:
               REPEAT:
                  {&imp-stream-ss}
                  {&ii1}
                  CASE ss:
                  when "userconf":U or
                  when "usr-flt":U or
                  when "usr-grpa":U or
                  when "usr-grpo":U
                  then do:
                     current-table = ss.
                     case current-table:
                        when "userconf":U then do:
                           {&ii1}
                           create buf-userconf.
                           v-curr-seek = seek(instream).
                           {&imp-stream} {&ie-userconf-fields} no-error.
                           if error-status:error then do:
                              seek stream instream to v-curr-seek.
                              {&imp-stream} {&ie-userconf-fields-old} no-error.
                           end.
                           &scop err-mes ~{&errimp-mes~}
                           {&wlerimp-mes}
                           &scop table-name buf-userconf
                           IF CAN-FIND(FIRST temp-userconf No-LOCK WHERE
                                             temp-userconf.user-name = buf-userconf.user-name) then do:
                                 &scop err-mes (~{&err-mes0~} + " Уже есть ПОЛЬЗОВАТЕЛЬ(userconf):" + ~
                                                " имя " + buf-userconf.user-name)
                                 {&wl-mes}
                           end.
                           create temp-userconf.
                           buffer-copy
                           buf-userconf to temp-userconf.
                           delete buf-userconf.
                        end.
                        when "usr-flt":U then do:
                           {&ii1}
                           create buf-usr-flt.
                           {&imp-stream} {&ie-usr-flt-fields} no-error.
                           &scop err-mes ~{&errimp-mes~}
                           {&wlerimp-mes}
                           &scop table-name buf-usr-flt
                           assign
                           buf-usr-flt.call-point = replace(buf-usr-flt.call-point, {&delim-nws}, {&delim-par})
                           .
                           IF CAN-FIND(FIrst temp-usr-flt NO-LOCK WHERE
                                             temp-usr-flt.user-name = buf-usr-flt.user-name AND
                                             temp-usr-flt.call-point = buf-usr-flt.call-point) then do:
                                 &scop err-mes (~{&err-mes0~} + " Уже есть ФИЛЬТР ДЛЯ ПОЛЬЗОВАТЕЛЯ(usr-flt):" + ~
                                                " имя пользователя " + buf-usr-flt.user-name + ~
                                                " точка вызова фильтра " + buf-usr-flt.call-point)
                                 {&wl-mes}
                           end.
                           create temp-usr-flt.
                           buffer-copy buf-usr-flt to temp-usr-flt.
                           delete buf-usr-flt.
                        end.
                        when "usr-grpa":U then do:
                           {&ii1}
                           create buf-usr-grpa.
                           {&imp-stream} {&ie-usr-grpa-fields} no-error.
                           &scop err-mes ~{&errimp-mes~}
                           {&wlerimp-mes}
                           &scop table-name buf-usr-grpa
                           IF CAN-FIND(FIRST temp-usr-grpa NO-LOCK WHERE
                                             temp-usr-grpa.user-name = buf-usr-grpa.user-name AND
                                             temp-usr-grpa.host-code = buf-usr-grpa.host-code AND
                                             temp-usr-grpa.arm-code = buf-usr-grpa.arm-code) then do:
                                 &scop err-mes (~{&err-mes0~} + " Уже есть ПРАВА В АРМЕ ДЛЯ ПОЛЬЗОВАТЕЛЯ(usr-grpa):" + ~
                                                " имя пользователя " + buf-usr-grpa.user-name + ~
                                                " фирма " + string(buf-usr-grpa.host-code) + ~
                                                " АРМ " + buf-usr-grpa.arm-code)
                              {&wl-mes}
                           END.
                           create temp-usr-grpa.
                           buffer-copy buf-usr-grpa to temp-usr-grpa.
                           delete buf-usr-grpa.
                        end.
                        when "usr-grpo":U then do:
                           {&ii1}
                           create buf-usr-grpo.
                           {&imp-stream} {&ie-usr-grpo-fields} no-error.
                           &scop err-mes ~{&errimp-mes~}
                           {&wlerimp-mes}
                           &scop table-name buf-usr-grpo
                           IF CAN-FIND(FIRST temp-usr-grpo NO-LOCK WHERE
                                             temp-usr-grpo.user-name = buf-usr-grpo.user-name AND
                                             temp-usr-grpo.obj-type = buf-usr-grpo.obj-type AND
                                             temp-usr-grpo.obj-code = buf-usr-grpo.obj-code) then do:
                                 &scop err-mes (~{&err-mes0~} + " Уже есть ПРАВА НА ОБЪЕКТЕ ДЛЯ ПОЛЬЗОВАТЕЛЯ(usr-grpo):" + ~
                                                " имя пользователя " + buf-usr-grpo.user-name + ~
                                                " тип объекта " + buf-usr-grpo.obj-type + ~
                                                " код объекта " + string(buf-usr-grpo.obj-code))
                              {&wl-mes}
                           END.
                           create temp-usr-grpo.
                           buffer-copy buf-usr-grpo to temp-usr-grpo.
                           delete buf-usr-grpo.
                        end.
                     end CASE.
                  end.
                  otherwise do:
                  end.
                  END CASE.
               END. /* repeat*/
            end.
      END CASE.
      {&close-stream}
     end. /* loc#log */
  end. /* DO ON ERROR */

end procedure. /* p-usr-i */




procedure create-scales-gds :
define parameter buffer bc for ub.bar-code.
define parameter buffer sc for ub.scales.
define parameter buffer goods for ub.goods.
define parameter buffer ltemp-scales-gds  for temp-scales-gds.

define variable ii as integer no-undo.
def buffer for-pbc for ub.prod-bc.
define variable sc-code like ub.bar-code.b-code no-undo .
define variable v-found as logical no-undo .
define variable v-on as logical no-undo .
define variable v-b-str like ub.prod-bc.b-str no-undo .
define variable f-sc-code as integer no-undo .
define buffer dubl_prod-bc for ub.prod-bc.
define buffer buf_units for ub.units.


  do
  on error undo, return error
  :
    if sc.tot-gds + 1 > sc.max-gds then do:
      undo, return error ("Превышено максимальное количество товаров на весах" + {&space-char} + string(sc.scales-num)).
    end.
    find first buf_units no-lock where buf_units.unit-name = goods.unit-base.
    { ref/cves-pbc.i bc _main goods ltemp-scales-gds.obj-type ltemp-scales-gds.obj-code silence buf_units.type }
    _main:
    DO ON ERROR undo, return error on stop undo, return error:
      create ub.scales-gds.
      assign
      sc.tot-gds  = sc.tot-gds + 1
      ub.scales-gds.db-num    = g#db-num
      ub.scales-gds.obj-type  = ltemp-scales-gds.obj-type
      ub.scales-gds.obj-code = ltemp-scales-gds.obj-code
      ub.scales-gds.b-code = ltemp-scales-gds.b-code
      ub.scales-gds.scales-num = ltemp-scales-gds.scales-num
      ub.scales-gds.to-send = TRUE
      sc.to-send = TRUE
      ub.scales-gds.to-del = FALSE    /* отметка, что запись нужна */
      ub.scales-gds.deadline = ltemp-scales-gds.deadline
      ub.scales-gds.wt-cart = ltemp-scales-gds.wt-cart
      ub.scales-gds.plu-code = ltemp-scales-gds.plu-code
      .
    END.
  end. /*doe*/
end procedure. /* create-scales-gds */

procedure add-right :

  define input parameter p-grp-acta-arm-code  as character no-undo .
  define input parameter p-grp-acta-object    as character no-undo .
  define input parameter p-grp-acta-act       as character no-undo .
  define input parameter p-action-item-id     as character no-undo .
  define input parameter p-action-context     as character no-undo .

  define buffer buf_temp-action-item for temp-action-item .

  do transaction
  on error undo, return error return-value
  :
      create buf_temp-action-item .
      assign
        buf_temp-action-item.grp-acta-arm-code  = p-grp-acta-arm-code
        buf_temp-action-item.grp-acta-object    = p-grp-acta-object
        buf_temp-action-item.grp-acta-act       = p-grp-acta-act
        buf_temp-action-item.action-item-id     = p-action-item-id
        buf_temp-action-item.action-context     = p-action-context
      .
  end.

end procedure. /* add-right */



procedure p-right-i :

do
on error undo, return error
:
  if "{&language}" = "rus":U
  then do:
    run fill-right-rus in this-procedure .
  end.
  else do:
    run fill-right-eng in this-procedure .
  end.

end.
end procedure. /* p-right-i */



procedure fill-right-rus :

  do
  on error undo, return error return-value
  :
    run add-right in this-procedure ("маг", "отчеты",                                              "печать",                                         "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("общ", "edi_код_GLN",                                         "ИЗМЕНЕНИЕ",                                      "actn_rh-attr-gln_update",                            "global") .
    run add-right in this-procedure ("общ", "edi_работа_по_EDI",                                   "ИЗМЕНЕНИЕ",                                      "actn_rh-attr-edi_update",                            "global") .
    run add-right in this-procedure ("общ", "openxml-subsystem",                                   "ДОБАВЛЕНИЕ",                                     "actn_openxml-subsystem_add-def",                     "object") .
    run add-right in this-procedure ("общ", "openxml-subsystem",                                   "ИЗМЕНЕНИЕ",                                      "actn_openxml-subsystem_update",                      "object") .
    run add-right in this-procedure ("общ", "openxml-subsystem",                                   "ПРОСМОТР",                                       "actn_openxml-subsystem_lookup",                      "object") .
    run add-right in this-procedure ("общ", "openxml-subsystem",                                   "вкл./выкл.",                                     "actn_openxml-subsystem_on-off",                      "object") .
    run add-right in this-procedure ("общ", "openxml-subsystem",                                   "удаление",                                       "actn_openxml-subsystem_deletion",                    "object") .
    run add-right in this-procedure ("общ", "аналитика",                                           "архив",                                          "actn_analitic_archive",                              "firm") .
    run add-right in this-procedure ("общ", "артикул_и_производитель",                             "ИЗМЕНЕНИЕ",                                      "actn_ren-art_update",                                "global") .
    run add-right in this-procedure ("общ", "архив",                                               "ПРОСМОТР",                                       "actn_archive_lookup",                                "object") .
    run add-right in this-procedure ("общ", "архив-межфирм",                                       "ИЗМЕНЕНИЕ",                                      "actn_archive-hold_update",                           "firm") .
    run add-right in this-procedure ("общ", "архив-переоценка",                                    "ИЗМЕНЕНИЕ",                                      "actn_archive-prc_update",                            "object") .
    run add-right in this-procedure ("общ", "архив-поставщик",                                     "ИЗМЕНЕНИЕ",                                      "actn_archive-ahsp_update",                           "object") .
    run add-right in this-procedure ("общ", "архив-приобретение",                                  "ИЗМЕНЕНИЕ",                                      "actn_archive-aht_update",                            "object") .
    run add-right in this-procedure ("общ", "архив-товар",                                         "ИЗМЕНЕНИЕ",                                      "actn_archive-arh_update",                            "object") .
    run add-right in this-procedure ("общ", "банки_и_счета",                                       "ДОБАВЛЕНИЕ",                                     "actn_fin-bank-accounts_add-def",                     "firm") .
    run add-right in this-procedure ("общ", "банки_и_счета",                                       "ИЗМЕНЕНИЕ",                                      "actn_fin-bank-accounts_update",                      "firm") .
    run add-right in this-procedure ("общ", "банки_и_счета",                                       "КОПИРОВАНИЕ",                                    "actn_fin-bank-accounts_add-copy",                    "firm") .
    run add-right in this-procedure ("общ", "банки_и_счета",                                       "удаление",                                       "actn_fin-bank-accounts_deletion",                    "firm") .
    run add-right in this-procedure ("общ", "буг_сервис",                                          "генер-пров",                                     "actn_acc-service_trans-generation",                  "firm") .
    run add-right in this-procedure ("общ", "буг_сервис",                                          "убр-накл-из-списка",                             "actn_acc-service_waybill-clear-list",                "firm") .
    run add-right in this-procedure ("общ", "весы",                                                "удаление",                                       "actn_scales_deletion",                               "global") .
    run add-right in this-procedure ("общ", "весы/группы-товаров",                                 "добавление,удаление",                            "actn_scales-goods-groups_adding-deletion",           "global") .
    run add-right in this-procedure ("общ", "виды-налогов",                                        "ИЗМЕНЕНИЕ",                                      "actn_tax-kinds_update",                              "global") .
    run add-right in this-procedure ("общ", "вывод-накладных-в-файл",                              "печать",                                         "actn_waybills-to-file_print",                        "firm") .
    run add-right in this-procedure ("общ", "группы-товаров-на-кассах",                            "ДОБАВЛЕНИЕ",                                     "actn_group-goods-cash-desk_add-def",                 "object") .
    run add-right in this-procedure ("общ", "группы-товаров-на-кассах",                            "ИЗМЕНЕНИЕ",                                      "actn_group-goods-cash-desk_update",                  "object") .
    run add-right in this-procedure ("общ", "дата-объекта",                                        "ИЗМЕНЕНИЕ",                                      "actn_obj-date-change_update",                        "firm") .
    run add-right in this-procedure ("общ", "документы",                                           "все",                                            "actn_documents_all",                                 "global") .
    run add-right in this-procedure ("общ", "документы",                                           "экспорт",                                        "actn_documents_export",                              "firm") .
    run add-right in this-procedure ("общ", "доп-БК",                                              "scgb",                                           "actn_alt-barcode_gbl-sc-code",                       "global") .
    run add-right in this-procedure ("общ", "доп-БК",                                              "sclc",                                           "actn_alt-barcode_loc-sc-code",                       "global") .
    run add-right in this-procedure ("общ", "доп-БК",                                              "sslc",                                           "actn_alt-barcode_loc-ss-code",                       "global") .
    run add-right in this-procedure ("общ", "доп-БК",                                              "включение",                                      "actn_alt-barcode_turn-on",                           "global") .
    run add-right in this-procedure ("общ", "доп-БК",                                              "подготовка",                                     "actn_alt-barcode_preparation",                       "global") .
    run add-right in this-procedure ("общ", "доставка-хранение",                                   "работа",                                         "actn_delivery-storage_work",                         "global") .
    run add-right in this-procedure ("общ", "ед.измерения",                                        "ИЗМЕНЕНИЕ",                                      "actn_unit_update",                                   "global") .
    run add-right in this-procedure ("общ", "заказ",                                               "ПРОСМОТР",                                       "actn_pmnt-ord-doc_lookup",                           "object") .
    run add-right in this-procedure ("общ", "заказ",                                               "отправка",                                       "actn_pmnt-ord-doc_sending",                          "global") .
    run add-right in this-procedure ("общ", "значения-ставок-налогов",                             "ИЗМЕНЕНИЕ",                                      "actn_tax-rate-values_update",                        "object") .
    run add-right in this-procedure ("общ", "итоги-по-дисконтным-картам",                          "печать",                                         "actn_discount-cards-totals_print",                   "firm") .
    run add-right in this-procedure ("общ", "кассиры",                                             "статистика-по-кассирам",                         "actn_cashiers_stat-on-cashiers",                     "firm") .
    run add-right in this-procedure ("общ", "коды-ставок-налогов",                                 "ИЗМЕНЕНИЕ",                                      "actn_tax-rates_update",                              "firm") .
    run add-right in this-procedure ("общ", "курс-ММВБ",                                           "ИЗМЕНЕНИЕ",                                      "actn_micex-rate_update",                             "global") .
    run add-right in this-procedure ("общ", "курс-ЦБ",                                             "ИЗМЕНЕНИЕ",                                      "actn_cb-rate_update",                                "global") .
    run add-right in this-procedure ("общ", "курс-магазин",                                        "ИЗМЕНЕНИЕ",                                      "actn_shop-rate_update",                              "object") .
    run add-right in this-procedure ("общ", "назначение-прав",                                     "ИЗМЕНЕНИЕ",                                      "actn_rights_update",                                 "global") .
    run add-right in this-procedure ("общ", "обнов-рекв-фин-док",                                  "ИЗМЕНЕНИЕ",                                      "actn_updfind_update",                                "firm") .
    run add-right in this-procedure ("общ", "отчет-по-продажам-постоянным-клиентам",               "печать",                                         "actn_permanent-client-sale_print",                   "firm") .
    run add-right in this-procedure ("общ", "отчет-по-реализации",                                 "печать",                                         "actn_sale-report_print",                             "firm") .
    run add-right in this-procedure ("общ", "отчеты-по-док-там,-продажные-цены",                   "печать",                                         "actn_document-reports-sale_print",                   "firm") .
    run add-right in this-procedure ("общ", "отчеты-по-док-там,-учетные-цены",                     "печать",                                         "actn_document-reports-cost_print",                   "firm") .
    run add-right in this-procedure ("общ", "партии",                                              "все",                                            "actn_parts_all",                                     "firm") .
    run add-right in this-procedure ("общ", "партии",                                              "порождение",                                     "actn_parts_createneg",                               "object") .
    run add-right in this-procedure ("общ", "переоценка,-учетные-цены",                            "печать",                                         "actn_overvalue-cast_print",                          "firm") .
    run add-right in this-procedure ("общ", "платежные документы",                                 "ДОБАВЛЕНИЕ",                                     "actn_bgh-paydocs_add-def",                           "firm") .
    run add-right in this-procedure ("общ", "платежные документы",                                 "ИЗМЕНЕНИЕ",                                      "actn_bgh-paydocs_update",                            "firm") .
    run add-right in this-procedure ("общ", "платежные документы",                                 "ПРОСМОТР",                                       "actn_bgh-paydocs_lookup",                            "firm") .
    run add-right in this-procedure ("общ", "платежные документы",                                 "печать",                                         "actn_bgh-paydocs_print",                             "firm") .
    run add-right in this-procedure ("общ", "платежные документы",                                 "удаление",                                       "actn_bgh-paydocs_deletion",                          "firm") .
    run add-right in this-procedure ("общ", "помесячная-выручка-по-магазинам",                     "печать",                                         "actn_proceeds-monthly_print",                        "firm") .
    run add-right in this-procedure ("общ", "помесячные-обороты-по-производителям",                "печать",                                         "actn_prod-monthly_print",                            "firm") .
    run add-right in this-procedure ("общ", "помесячный-оборот-по-производителю-и-классификатору", "печать",                                         "actn_prod-classifier-monthly_print",                 "firm") .
    run add-right in this-procedure ("общ", "поставка",                                            "ПРОСМОТР",                                       "actn_ord-rcv_lookup",                                "object") .
    run add-right in this-procedure ("общ", "прайс-лист",                                          "печать",                                         "actn_price-list_print",                              "firm") .
    run add-right in this-procedure ("общ", "прайс-лист,вывод-в-файл",                             "печать",                                         "actn_price-list-to-file_print",                      "firm") .
    run add-right in this-procedure ("общ", "при",                                                 "коррекция_закрытых",                             "actn_income_update-closed",                          "object") .
    run add-right in this-procedure ("общ", "при",                                                 "коррекция_сроки_годности",                       "actn_income_update-last-date",                       "object") .
    run add-right in this-procedure ("общ", "примечание-(факт)",                                   "печать",                                         "actn_ps-fact_print",                                 "firm") .
    run add-right in this-procedure ("общ", "принтер кухни",                                       "работа",                                         "actn_fbr-prn_work",                                  "global") .
    run add-right in this-procedure ("общ", "расчет-налогов",                                      "печать",                                         "actn_tax-settlement_print",                          "firm") .
    run add-right in this-procedure ("общ", "реквизиты-клиента",                                   "ввод,изменение",                                 "actn_client-requisite_add-upd",                      "firm") .
    run add-right in this-procedure ("общ", "рт-котроль-цены",                                     "работа",                                         "actn_rt-check-price_work",                           "object") .
    run add-right in this-procedure ("общ", "рт-приемка-товара",                                   "<закрытие документа на факт>",                   "actn_rt-edit-doc_close-fact",                        "object") .
    run add-right in this-procedure ("общ", "рт-приемка-товара",                                   "<закрытие документа>",                           "actn_rt-edit-doc_close-doc",                         "object") .
    run add-right in this-procedure ("общ", "рт-приемка-товара",                                   "ДОБАВЛЕНИЕ",                                     "actn_rt-edit-doc_add-def",                           "object") .
    run add-right in this-procedure ("общ", "рт-приемка-товара",                                   "работа",                                         "actn_rt-edit-doc_work",                              "object") .
    run add-right in this-procedure ("общ", "скидка",                                              "работа",                                         "actn_discount_work",                                 "object") .
    run add-right in this-procedure ("общ", "соб-БК",                                              "подготовка",                                     "actn_main-barcode_preparation",                      "global") .
    run add-right in this-procedure ("общ", "соб-БК",                                              "удаление",                                       "actn_main-barcode_deletion",                         "global") .
    run add-right in this-procedure ("общ", "списки-из-справочников",                              "печать",                                         "actn_reference-lists_print",                         "firm") .
    run add-right in this-procedure ("общ", "список-платежей",                                     "ПРОСМОТР",                                       "actn_payments-reference_lookup",                     "firm") .
    run add-right in this-procedure ("общ", "спр-к_рецептов",                                      "ввод,удал,изм",                                  "actn_recipe-reference_input-deletion-updating",      "object") .
    run add-right in this-procedure ("общ", "спр-к_рецептов",                                      "общ",                                            "actn_recipe-reference_conjoint",                     "object") .
    run add-right in this-procedure ("общ", "справочник",                                          "ИЗМЕНЕНИЕ",                                      "actn_reference_update",                              "global") .
    run add-right in this-procedure ("общ", "справочник",                                          "архив",                                          "actn_reference_archive",                             "firm") .
    run add-right in this-procedure ("общ", "справочник",                                          "изм_группы",                                     "actn_reference_upd-group",                           "global") .
    run add-right in this-procedure ("общ", "справочник",                                          "изм_налогов_на_товар",                           "actn_reference_upd-gds-tax",                         "global") .
    run add-right in this-procedure ("общ", "справочник",                                          "исходная-наценка",                               "actn_reference_calc-increase",                       "global") .
    run add-right in this-procedure ("общ", "справочник",                                          "печать",                                         "actn_reference_print",                               "firm") .
    run add-right in this-procedure ("общ", "справочник",                                          "удаление",                                       "actn_reference_deletion",                            "global") .
    run add-right in this-procedure ("общ", "справочник-акцизные-марки",                           "ИЗМЕНЕНИЕ",                                      "actn_exmark-reference_update",                       "global") .
    run add-right in this-procedure ("общ", "справочник-дис",                                      "ввод,удал,изм",                                  "actn_referense-dis_input-deletion-updating",         "firm") .
    run add-right in this-procedure ("общ", "справочник-кли",                                      "ИЗМЕНЕНИЕ",                                      "actn_client-reference_update",                       "global") .
    run add-right in this-procedure ("общ", "справочник-кли",                                      "ПРОСМОТР",                                       "actn_client-reference_lookup",                       "global") .
    run add-right in this-procedure ("общ", "справочник-кли",                                      "ввод,удал",                                      "actn_client-reference_add-del",                      "global") .
    run add-right in this-procedure ("общ", "справочник-кли-чел",                                  "ввод,удал",                                      "actn_client-reference-prs_add-del",                  "global") .
    run add-right in this-procedure ("общ", "справочник-типов-дис",                                "ввод,удал,изм",                                  "actn_reference-dc-type_input-deletion-updating",     "global") .
    run add-right in this-procedure ("общ", "справочник-топливо",                                  "ИЗМЕНЕНИЕ",                                      "actn_reference-petrolium_update",                    "global") .
    run add-right in this-procedure ("общ", "справочник-услуги",                                   "ИЗМЕНЕНИЕ",                                      "actn_reference-services_update",                     "global") .
    run add-right in this-procedure ("общ", "справочник-услуги",                                   "удаление",                                       "actn_reference-services_deletion",                   "global") .
    run add-right in this-procedure ("общ", "справочник_касс",                                     "ввод,удал,изм",                                  "actn_cashdesk-reference_input-deletion-updating",    "object") .
    run add-right in this-procedure ("общ", "справочник_касс",                                     "вкл./выкл.",                                     "actn_cashdesk-reference_on-off",                     "object") .
    run add-right in this-procedure ("общ", "справочники",                                         "экспорт",                                        "actn_references_export",                             "object") .
    run add-right in this-procedure ("общ", "счет-фактура",                                        "ДОБАВЛЕНИЕ",                                     "actn_invoice_add-def",                               "object") .
    run add-right in this-procedure ("общ", "счет-фактура",                                        "удаление",                                       "actn_invoice_deletion",                              "object") .
    run add-right in this-procedure ("общ", "счета-фактуры",                                       "ДОБАВЛЕНИЕ",                                     "actn_schet-fact-doc_add-def",                        "firm") .
    run add-right in this-procedure ("общ", "счета-фактуры",                                       "ИЗМЕНЕНИЕ",                                      "actn_schet-fact-doc_update",                         "firm") .
    run add-right in this-procedure ("общ", "счета-фактуры",                                       "ПРОСМОТР",                                       "actn_schet-fact-doc_lookup",                         "firm") .
    run add-right in this-procedure ("общ", "счета-фактуры",                                       "закрыть",                                        "actn_schet-fact-doc_close",                          "firm") .
    run add-right in this-procedure ("общ", "счета-фактуры",                                       "открыть",                                        "actn_schet-fact-doc_open",                           "firm") .
    run add-right in this-procedure ("общ", "счета-фактуры",                                       "удаление",                                       "actn_schet-fact-doc_deletion",                       "firm") .
    run add-right in this-procedure ("общ", "счета-фактуры",                                       "экспорт",                                        "actn_schet-fact-doc_export",                         "firm") .
    run add-right in this-procedure ("общ", "удал_документы",                                      "все",                                            "actn_c-documents_all",                               "object") .
    run add-right in this-procedure ("общ", "фин_договор",                                         "ПРОСМОТР",                                       "actn_fin-contract_lookup",                           "firm") .
    run add-right in this-procedure ("общ", "чеки",                                                "удаление",                                       "actn_receipts_deletion",                             "object") .
    run add-right in this-procedure ("общ", "чеки-МЦ",                                             "ИЗМЕНЕНИЕ",                                      "actn_wth-receipts_update",                           "object") .
    run add-right in this-procedure ("общ", "чеки-МЦ",                                             "ПРОСМОТР",                                       "actn_wth-receipts_lookup",                           "object") .
    run add-right in this-procedure ("общ", "чеки-МЦ",                                             "удаление",                                       "actn_wth-receipts_deletion",                         "object") .
    run add-right in this-procedure ("общ", "чеки-и-выручка",                                      "печать",                                         "actn_cur-obj-proceeds_print",                        "firm") .
    run add-right in this-procedure ("объ", "hold_возврат",                                        "удаление документа закрытого на факт",           "actn_hold-return_del-fact",                          "object") .
    run add-right in this-procedure ("объ", "hold_при",                                            "удаление документа закрытого на факт",           "actn_hold-income_del-fact",                          "object") .
    run add-right in this-procedure ("объ", "hold_рас",                                            "подготовка",                                     "actn_hold-expense_preparation",                      "object") .
    run add-right in this-procedure ("объ", "hold_рас",                                            "удаление документа закрытого на факт",           "actn_hold-expense_del-fact",                         "object") .
    run add-right in this-procedure ("объ", "Документ перемещения МЦ",                             "ДОБАВЛЕНИЕ",                                     "actn_wth-doc_add-def",                               "object") .
    run add-right in this-procedure ("объ", "Документ перемещения МЦ",                             "ИЗМЕНЕНИЕ",                                      "actn_wth-doc_update",                                "object") .
    run add-right in this-procedure ("объ", "Документ перемещения МЦ",                             "ПРОСМОТР",                                       "actn_wth-doc_lookup",                                "object") .
    run add-right in this-procedure ("объ", "Документ перемещения МЦ",                             "печать",                                         "actn_wth-doc_print",                                 "object") .
    run add-right in this-procedure ("объ", "Документ перемещения МЦ",                             "удаление документа закрытого на факт",           "actn_wth-doc_del-fact",                              "object") .
    run add-right in this-procedure ("объ", "Документ перемещения МЦ",                             "удаление",                                       "actn_wth-doc_deletion",                              "object") .
    run add-right in this-procedure ("объ", "Объект-Объект",                                       "ДОБАВЛЕНИЕ",                                     "actn_o-o_add-def",                                   "object") .
    run add-right in this-procedure ("объ", "Объект-Объект",                                       "ИЗМЕНЕНИЕ",                                      "actn_o-o_update",                                    "object") .
    run add-right in this-procedure ("объ", "Объект-Объект",                                       "удаление",                                       "actn_o-o_deletion",                                  "object") .
    run add-right in this-procedure ("объ", "архив",                                               "учет",                                           "actn_archive_cost",                                  "object") .
    run add-right in this-procedure ("объ", "весовой-код-на-объекте",                              "ИЗМЕНЕНИЕ",                                      "actn_object-weight-code_update",                     "object") .
    run add-right in this-procedure ("объ", "весы",                                                "ИЗМЕНЕНИЕ",                                      "actn_scales_update",                                 "global") .
    run add-right in this-procedure ("объ", "весы",                                                "отправка",                                       "actn_scales_sending",                                "global") .
    run add-right in this-procedure ("объ", "возврат",                                             "reserv",                                         "actn_return_rsrv-dtl-action-reserv",                 "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "ПРОСМОТР",                                       "actn_return_lookup",                                 "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "добавление документа задним числом",             "actn_return_add-back-date",                          "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "добавление топлива в документ задним числом",    "actn_return_add-ptrl-back-date",                     "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "открытие",                                       "actn_return_opening",                                "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "отмена-разр",                                    "actn_return_perm-cancellation",                      "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "печать",                                         "actn_return_print",                                  "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "подготовка",                                     "actn_return_preparation",                            "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "подготовка-по-собств-фирме",                     "actn_return_prepownfirmhold",                        "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "разрешение",                                     "actn_return_permission",                             "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "удаление документа закрытого на факт",           "actn_return_del-fact",                               "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "удаление документа по топливу в прошлых сменах", "actn_return_del-ptrl-prev-shft",                     "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "факт",                                           "actn_return_fact",                                   "object") .
    run add-right in this-procedure ("объ", "возврат",                                             "цена",                                           "actn_return_price",                                  "object") .
    run add-right in this-procedure ("объ", "дата_на_объекте",                                     "ИЗМЕНЕНИЕ",                                      "actn_object-date_update",                            "object") .
    run add-right in this-procedure ("объ", "заказ",                                               "ДОБАВЛЕНИЕ",                                     "actn_pmnt-ord-doc_add-def",                          "object") .
    run add-right in this-procedure ("объ", "заказ",                                               "ИЗМЕНЕНИЕ",                                      "actn_pmnt-ord-doc_update",                           "object") .
    run add-right in this-procedure ("объ", "заказ",                                               "ПРОСМОТР",                                       "actn_pmnt-ord-doc_lookup",                           "object") .
    run add-right in this-procedure ("объ", "заказ",                                               "удаление",                                       "actn_pmnt-ord-doc_deletion",                         "object") .
    run add-right in this-procedure ("объ", "значения-ставок-налогов",                             "ИЗМЕНЕНИЕ",                                      "actn_tax-rate-values_update",                        "object") .
    run add-right in this-procedure ("объ", "инв",                                                 "ПРОСМОТР",                                       "actn_inventory_lookup",                              "object") .
    run add-right in this-procedure ("объ", "инв",                                                 "открытие",                                       "actn_inventory_opening",                             "object") .
    run add-right in this-procedure ("объ", "инв",                                                 "печать",                                         "actn_inventory_print",                               "object") .
    run add-right in this-procedure ("объ", "инв",                                                 "подготовка",                                     "actn_inventory_preparation",                         "object") .
    run add-right in this-procedure ("объ", "инв",                                                 "разрешение",                                     "actn_inventory_permission",                          "object") .
    run add-right in this-procedure ("объ", "инв",                                                 "редакт-факт",                                    "actn_inventory_fact-edit",                           "object") .
    run add-right in this-procedure ("объ", "инв",                                                 "резервы",                                        "actn_inventory_reserves",                            "object") .
    run add-right in this-procedure ("объ", "инв",                                                 "удаление документа закрытого на факт",           "actn_inventory_del-fact",                            "object") .
    run add-right in this-procedure ("объ", "инв",                                                 "факт",                                           "actn_inventory_fact",                                "object") .
    run add-right in this-procedure ("объ", "инв",                                                 "добавление задним числом",                       "actn_inventory_add-back-date",                       "object") .
    run add-right in this-procedure ("объ", "инв-сч-трк",                                          "ПРОСМОТР",                                       "actn_icnt-doc_lookup",                               "object") .
    run add-right in this-procedure ("объ", "инв-сч-трк",                                          "изм-эл-сч",                                      "actn_icnt-doc_upd-el-cnt",                           "object") .
    run add-right in this-procedure ("объ", "инв-сч-трк",                                          "печать",                                         "actn_icnt-doc_print",                                "object") .
    run add-right in this-procedure ("объ", "инв-сч-трк",                                          "подготовка",                                     "actn_icnt-doc_preparation",                          "object") .
    run add-right in this-procedure ("объ", "инв-сч-трк",                                          "удаление",                                       "actn_icnt-doc_deletion",                             "object") .
    run add-right in this-procedure ("объ", "инв-сч-трк",                                          "факт",                                           "actn_icnt-doc_fact",                                 "object") .
    run add-right in this-procedure ("объ", "карты-клиента",                                       "ввод-платежа",                                   "actn_client-cards_payment-input",                    "object") .
    run add-right in this-procedure ("объ", "карты-клиента",                                       "удаление-платежа",                               "actn_client-cards_payment-deletion",                 "object") .
    run add-right in this-procedure ("объ", "касса/группы товаров",                                "ИЗМЕНЕНИЕ",                                      "actn_cashdesk-goods-groups_update",                  "object") .
    run add-right in this-procedure ("объ", "касса/кассиры",                                       "ИЗМЕНЕНИЕ",                                      "actn_cashdesk-cashiers_update",                      "object") .
    run add-right in this-procedure ("объ", "касса/категории_и_ставки_налогов",                    "ДОБАВЛЕНИЕ",                                     "actn_cashdesk-taxn_add-def",                         "object") .
    run add-right in this-procedure ("объ", "касса/категории_и_ставки_налогов",                    "удаление",                                       "actn_cashdesk-taxn_deletion",                        "object") .
    run add-right in this-procedure ("объ", "касса/клиенты",                                       "ДОБАВЛЕНИЕ",                                     "actn_cashdesk-clients_add-def",                      "object") .
    run add-right in this-procedure ("объ", "касса/клиенты",                                       "удаление",                                       "actn_cashdesk-clients_deletion",                     "object") .
    run add-right in this-procedure ("объ", "касса/курсы",                                         "ИЗМЕНЕНИЕ",                                      "actn_cashdesk-rates_update",                         "object") .
    run add-right in this-procedure ("объ", "касса/налоги_на_товар",                               "ДОБАВЛЕНИЕ",                                     "actn_cashdesk-taxg_add-def",                         "object") .
    run add-right in this-procedure ("объ", "касса/налоги_на_товар",                               "удаление",                                       "actn_cashdesk-taxg_deletion",                        "object") .
    run add-right in this-procedure ("объ", "касса/платежи",                                       "ДОБАВЛЕНИЕ",                                     "actn_cashdesk-payments_add-def",                     "object") .
    run add-right in this-procedure ("объ", "касса/платежи",                                       "удаление",                                       "actn_cashdesk-payments_deletion",                    "object") .
    run add-right in this-procedure ("объ", "касса/продавцы",                                      "ИЗМЕНЕНИЕ",                                      "actn_cashdesk-sellers_update",                       "object") .
    run add-right in this-procedure ("объ", "касса/скидки_на_итог",                                "ДОБАВЛЕНИЕ",                                     "actn_cashdesk-discnt-total_add-def",                 "object") .
    run add-right in this-procedure ("объ", "касса/скидки_на_итог",                                "удаление",                                       "actn_cashdesk-discnt-total_deletion",                "object") .
    run add-right in this-procedure ("объ", "касса/товары",                                        "ДОБАВЛЕНИЕ",                                     "actn_cashdesk-goods_add-def",                        "object") .
    run add-right in this-procedure ("объ", "касса/товары",                                        "удаление",                                       "actn_cashdesk-goods_deletion",                       "object") .
    run add-right in this-procedure ("объ", "контроль",                                            "ПРОСМОТР",                                       "actn_rvs-control_lookup",                            "object") .
    run add-right in this-procedure ("объ", "контроль",                                            "изменение-сверки",                               "actn_rvs-control_upd-revision",                      "object") .
    run add-right in this-procedure ("объ", "контроль",                                            "печать",                                         "actn_rvs-control_print",                             "object") .
    run add-right in this-procedure ("объ", "контроль",                                            "создание-сверки",                                "actn_rvs-control_cr-revision",                       "object") .
    run add-right in this-procedure ("объ", "контроль",                                            "удаление документа закрытого на факт",           "actn_rvs-control_del-fact",                          "object") .
    run add-right in this-procedure ("объ", "контроль",                                            "удаление",                                       "actn_rvs-control_deletion",                          "object") .
    run add-right in this-procedure ("объ", "контроль",                                            "факт",                                           "actn_rvs-control_fact",                              "object") .
    run add-right in this-procedure ("объ", "куц",                                                 "подготовка",                                     "actn_corr-acc-pr-view_preparation",                  "object") .
    run add-right in this-procedure ("объ", "отчеты",                                              "отчет_benet1",                                   "actn_reports_report-benet1",                         "object") .
    run add-right in this-procedure ("объ", "отчеты",                                              "отчет_benet2",                                   "actn_reports_report-benet2",                         "object") .
    run add-right in this-procedure ("объ", "отчеты",                                              "отчет_benet3",                                   "actn_reports_report-benet3",                         "object") .
    run add-right in this-procedure ("объ", "отчеты",                                              "отчет_benet4",                                   "actn_reports_report-benet4",                         "object") .
    run add-right in this-procedure ("объ", "отчеты",                                              "отчет_benet5",                                   "actn_reports_report-benet5",                         "object") .
    run add-right in this-procedure ("объ", "отчеты",                                              "отчет_g-ben-dt",                                 "actn_reports_report-benet6",                         "object") .
    run add-right in this-procedure ("объ", "отчеты",                                              "продажные_цены",                                 "actn_reports_lookup-crsa",                           "object") .
    run add-right in this-procedure ("объ", "отчеты",                                              "учетные_цены",                                   "actn_reports_lookup-cost",                           "object") .
    run add-right in this-procedure ("объ", "отчеты",                                              "цены_документа",                                 "actn_reports_lookup-sale",                           "object") .
    run add-right in this-procedure ("объ", "отчеты",                                              "цены_посредника",                                "actn_reports_lookup-medi",                           "object") .
    run add-right in this-procedure ("объ", "партии",                                              "разбиение-слияние",                              "actn_parts_split-fuse",                              "object") .
    run add-right in this-procedure ("объ", "переоценка",                                          "ИЗМЕНЕНИЕ",                                      "actn_overvalue_update",                              "object") .
    run add-right in this-procedure ("объ", "переоценка",                                          "ПРОСМОТР",                                       "actn_overvalue_lookup",                              "object") .
    run add-right in this-procedure ("объ", "переоценка",                                          "приказ",                                         "actn_overvalue_order",                               "object") .
    run add-right in this-procedure ("объ", "переоценка",                                          "печать",                                         "actn_overvalue_print",                               "object") .
    run add-right in this-procedure ("объ", "переоценка",                                          "подготовка",                                     "actn_overvalue_preparation",                         "object") .
    run add-right in this-procedure ("объ", "переоценка",                                          "признаки",                                       "actn_overvalue_properties",                          "object") .
    run add-right in this-procedure ("объ", "переоценка",                                          "разрешение",                                     "actn_overvalue_permission",                          "object") .
    run add-right in this-procedure ("объ", "переоценка",                                          "скидка",                                         "actn_overvalue_discount",                            "object") .
    run add-right in this-procedure ("объ", "переоценка",                                          "факт",                                           "actn_overvalue_fact",                                "object") .
    run add-right in this-procedure ("объ", "по_док",                                              "ПРОСМОТР",                                       "actn_rvs-on-doc_lookup",                             "object") .
    run add-right in this-procedure ("объ", "по_док",                                              "изменение-сверки",                               "actn_rvs-on-doc_upd-revision",                       "object") .
    run add-right in this-procedure ("объ", "по_док",                                              "печать",                                         "actn_rvs-on-doc_print",                              "object") .
    run add-right in this-procedure ("объ", "по_док",                                              "создание-сверки",                                "actn_rvs-on-doc_cr-revision",                        "object") .
    run add-right in this-procedure ("объ", "по_док",                                              "удаление",                                       "actn_rvs-on-doc_deletion",                           "object") .
    run add-right in this-procedure ("объ", "по_док",                                              "факт",                                           "actn_rvs-on-doc_fact",                               "object") .
    run add-right in this-procedure ("объ", "поставка",                                            "ДОБАВЛЕНИЕ",                                     "actn_ord-rcv_add-def",                               "object") .
    run add-right in this-procedure ("объ", "поставка",                                            "ИЗМЕНЕНИЕ",                                      "actn_ord-rcv_update",                                "object") .
    run add-right in this-procedure ("объ", "поставка",                                            "ПРОСМОТР",                                       "actn_ord-rcv_lookup",                                "object") .
    run add-right in this-procedure ("объ", "поставка",                                            "накладная",                                      "actn_ord-rcv_h-wbill",                               "object") .
    run add-right in this-procedure ("объ", "поставка",                                            "удаление",                                       "actn_ord-rcv_deletion",                              "object") .
    run add-right in this-procedure ("объ", "при",                                                 "import",                                         "actn_income_import",                                 "object") .
    run add-right in this-procedure ("объ", "при",                                                 "ПРОСМОТР",                                       "actn_income_lookup",                                 "object") .
    run add-right in this-procedure ("объ", "при",                                                 "добавление документа задним числом",             "actn_income_add-back-date",                          "object") .
    run add-right in this-procedure ("объ", "при",                                                 "добавление топлива в документ задним числом",    "actn_income_add-ptrl-back-date",                     "object") .
    run add-right in this-procedure ("объ", "при",                                                 "открытие",                                       "actn_income_opening",                                "object") .
    run add-right in this-procedure ("объ", "при",                                                 "открытие-запроса",                               "actn_income_opening-inquiry",                        "object") .
    run add-right in this-procedure ("объ", "при",                                                 "печать",                                         "actn_income_print",                                  "object") .
    run add-right in this-procedure ("объ", "при",                                                 "подготовка",                                     "actn_income_preparation",                            "object") .
    run add-right in this-procedure ("объ", "при",                                                 "подготовка-по-собств-фирме",                     "actn_income_prepownfirmhold",                        "object") .
    run add-right in this-procedure ("объ", "при",                                                 "удаление документа закрытого на факт",           "actn_income_del-fact",                               "object") .
    run add-right in this-procedure ("объ", "при",                                                 "удаление документа по топливу в прошлых сменах", "actn_income_del-ptrl-prev-shft",                     "object") .
    run add-right in this-procedure ("объ", "при",                                                 "факт",                                           "actn_income_fact",                                   "object") .
    run add-right in this-procedure ("объ", "принтер кухни/товары",                                "работа",                                         "actn_fbr-prn-goods_work",                            "object") .
    run add-right in this-procedure ("объ", "продажа",                                             "ПРОСМОТР",                                       "actn_sale_lookup",                                   "object") .
    run add-right in this-procedure ("объ", "продажа",                                             "удаление продажи закрытой на факт",              "actn_sale_del-sale-fact",                            "object") .
    run add-right in this-procedure ("объ", "продажа",                                             "факт",                                           "actn_sale_fact",                                     "object") .
    run add-right in this-procedure ("объ", "производство",                                        "ПРОСМОТР",                                       "actn_manufacturing_lookup",                          "object") .
    run add-right in this-procedure ("объ", "производство",                                        "альтернатива",                                   "actn_manufacturing_alternative",                     "object") .
    run add-right in this-procedure ("объ", "производство",                                        "комплектация",                                   "actn_manufacturing_gathering",                       "object") .
    run add-right in this-procedure ("объ", "производство",                                        "печать",                                         "actn_manufacturing_print",                           "object") .
    run add-right in this-procedure ("объ", "производство",                                        "подготовка",                                     "actn_manufacturing_preparation",                     "object") .
    run add-right in this-procedure ("объ", "производство",                                        "прод.ц.ингр",                                    "actn_manufacturing_price-sale-ingr",                 "object") .
    run add-right in this-procedure ("объ", "производство",                                        "прод.ц.сост",                                    "actn_manufacturing_price-sale-comp",                 "object") .
    run add-right in this-procedure ("объ", "производство",                                        "производство",                                   "actn_manufacturing_manufacturing",                   "object") .
    run add-right in this-procedure ("объ", "производство",                                        "разделка",                                       "actn_manufacturing_dressing",                        "object") .
    run add-right in this-procedure ("объ", "производство",                                        "свободно",                                       "actn_manufacturing_free",                            "object") .
    run add-right in this-procedure ("объ", "производство",                                        "свободно,ИЗМЕНЕНИЕ",                             "actn_manufacturing_free-update",                     "object") .
    run add-right in this-procedure ("объ", "производство",                                        "удаление производства закрытого на факт",        "actn_manufacturing_del-manuf-fact",                  "object") .
    run add-right in this-procedure ("объ", "производство",                                        "факт",                                           "actn_manufacturing_fact",                            "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "reserv",                                         "actn_expense_rsrv-dtl-action-reserv",                "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "ПРОСМОТР",                                       "actn_expense_lookup",                                "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "добавление документа задним числом",             "actn_expense_add-back-date",                         "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "добавление топлива в документ задним числом",    "actn_expense_add-ptrl-back-date",                    "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "отгрузка",                                       "actn_expense_shipping",                              "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "открытие",                                       "actn_expense_opening",                               "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "отмена-разр",                                    "actn_expense_perm-cancellation",                     "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "печать",                                         "actn_expense_print",                                 "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "подготовка",                                     "actn_expense_preparation",                           "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "подготовка-по-собств-фирме",                     "actn_expense_prepownfirmhold",                       "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "право на закрытие расхода ниже учетной цен",     "actn_expense_chkslpr",                               "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "разрешение",                                     "actn_expense_permission",                            "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "удаление документа закрытого на факт",           "actn_expense_del-fact",                              "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "удаление документа по топливу в прошлых сменах", "actn_expense_del-ptrl-prev-shft",                    "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "факт",                                           "actn_expense_fact",                                  "object") .
    run add-right in this-procedure ("объ", "рас",                                                 "цена",                                           "actn_expense_price",                                 "object") .
    run add-right in this-procedure ("объ", "расход внутренний",                                   "удаление документа закрытого на факт",           "actn_tdedt-ras-perem_del-fact",                      "object") .
    run add-right in this-procedure ("объ", "смена",                                               "ПРОСМОТР",                                       "actn_rvs-shift_lookup",                              "object") .
    run add-right in this-procedure ("объ", "смена",                                               "изменение-сверки",                               "actn_rvs-shift_upd-revision",                        "object") .
    run add-right in this-procedure ("объ", "смена",                                               "печать",                                         "actn_rvs-shift_print",                               "object") .
    run add-right in this-procedure ("объ", "смена",                                               "режим-менеджера",                                "actn_shift_super",                                   "object") .
    run add-right in this-procedure ("объ", "смена",                                               "создание-сверки",                                "actn_rvs-shift_cr-revision",                         "object") .
    run add-right in this-procedure ("объ", "смена",                                               "удаление",                                       "actn_rvs-shift_deletion",                            "object") .
    run add-right in this-procedure ("объ", "смена",                                               "факт",                                           "actn_rvs-shift_fact",                                "object") .
    run add-right in this-procedure ("объ", "смена",                                               "штатный-режим",                                  "actn_shift_regular",                                 "object") .
    run add-right in this-procedure ("объ", "создание-чека",                                       "ввод",                                           "actn_receipt_input",                                 "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "reserv",                                         "actn_write-off_rsrv-dtl-action-reserv",              "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "ПРОСМОТР",                                       "actn_write-off_lookup",                              "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "добавление документа задним числом",             "actn_write-off_add-back-date",                       "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "добавление топлива в документ задним числом",    "actn_write-off_add-ptrl-back-date",                  "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "отгрузка",                                       "actn_write-off_shipping",                            "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "открытие",                                       "actn_write-off_opening",                             "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "отмена-разр",                                    "actn_write-off_perm-cancellation",                   "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "печать",                                         "actn_write-off_print",                               "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "подготовка",                                     "actn_write-off_preparation",                         "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "разрешение",                                     "actn_write-off_permission",                          "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "удаление документа закрытого на факт",           "actn_write-off_del-fact",                            "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "удаление документа по топливу в прошлых сменах", "actn_write-off_del-ptrl-prev-shft",                  "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "факт",                                           "actn_write-off_fact",                                "object") .
    run add-right in this-procedure ("объ", "спи",                                                 "цена",                                           "actn_write-off_price",                               "object") .
    run add-right in this-procedure ("объ", "справочник мест отгрузки\приемки",                    "ДОБАВЛЕНИЕ",                                     "actn_place-io-reference_add-def",                    "object") .
    run add-right in this-procedure ("объ", "справочник мест отгрузки\приемки",                    "ИЗМЕНЕНИЕ",                                      "actn_place-io-reference_update",                     "object") .
    run add-right in this-procedure ("объ", "справочник мест отгрузки\приемки",                    "удаление",                                       "actn_place-io-reference_deletion",                   "object") .
    run add-right in this-procedure ("объ", "справочник пунктов отгрузки\доставки",                "ДОБАВЛЕНИЕ",                                     "actn_point-io-reference_add-def",                    "global") .
    run add-right in this-procedure ("объ", "справочник пунктов отгрузки\доставки",                "ИЗМЕНЕНИЕ",                                      "actn_point-io-reference_update",                     "global") .
    run add-right in this-procedure ("объ", "справочник пунктов отгрузки\доставки",                "удаление",                                       "actn_point-io-reference_deletion",                   "global") .
    run add-right in this-procedure ("объ", "справочник-ТРК",                                      "работа",                                         "actn_pump-reference_work",                           "object") .
    run add-right in this-procedure ("объ", "справочник-места-хранения-МЦ",                        "работа",                                         "actn_wth-place-reference_work",                      "object") .
    run add-right in this-procedure ("объ", "справочник-складские-места",                          "работа",                                         "actn_place-reference_work",                          "global") .
    run add-right in this-procedure ("объ", "справочник_касс",                                     "ИЗМЕНЕНИЕ",                                      "actn_cashdesk-reference_update",                     "object") .
    run add-right in this-procedure ("объ", "срок",                                                "запросы",                                        "actn_period_inquires",                               "object") .
    run add-right in this-procedure ("объ", "срок",                                                "резервы",                                        "actn_period_reserves",                               "object") .
    run add-right in this-procedure ("объ", "статус-скл_места-трк_товар",                          "работа",                                         "actn_plgdspm-sts_work",                              "object") .
    run add-right in this-procedure ("объ", "счет-фактура",                                        "ИЗМЕНЕНИЕ общ счет-фактура ИЗМЕНЕНИЕ",           "actn_invoice_update",                                "object") .
    run add-right in this-procedure ("объ", "счет-фактура",                                        "ПРОСМОТР общ счет-фактура ПРОСМОТР",             "actn_invoice_lookup",                                "object") .
    run add-right in this-procedure ("объ", "счет-фактура",                                        "печать общ счет-фактура печать",                 "actn_invoice_print",                                 "object") .
    run add-right in this-procedure ("объ", "счет-фактура",                                        "подготовка",                                     "actn_invoice_preparation",                           "object") .
    run add-right in this-procedure ("объ", "чек-МЦ",                                              "ввод",                                           "actn_wth-receipt_input",                             "object") .
    run add-right in this-procedure ("осн", "вариант операций ОС",                                 "ДОБАВЛЕНИЕ",                                     "actn_os-oper-var_add-def",                           "firm") .
    run add-right in this-procedure ("осн", "вариант операций ОС",                                 "ИЗМЕНЕНИЕ",                                      "actn_os-oper-var_update",                            "firm") .
    run add-right in this-procedure ("осн", "вариант операций ОС",                                 "удаление",                                       "actn_os-oper-var_deletion",                          "firm") .
    run add-right in this-procedure ("осн", "вид деятельности",                                    "ДОБАВЛЕНИЕ",                                     "actn_os-act-kind_add-def",                           "firm") .
    run add-right in this-procedure ("осн", "вид деятельности",                                    "ИЗМЕНЕНИЕ",                                      "actn_os-act-kind_update",                            "firm") .
    run add-right in this-procedure ("осн", "вид деятельности",                                    "удаление",                                       "actn_os-act-kind_deletion",                          "firm") .
    run add-right in this-procedure ("осн", "группа налогового учета",                             "ДОБАВЛЕНИЕ",                                     "actn_os-group-tax_add-def",                          "firm") .
    run add-right in this-procedure ("осн", "группа налогового учета",                             "ИЗМЕНЕНИЕ",                                      "actn_os-group-tax_update",                           "firm") .
    run add-right in this-procedure ("осн", "группа налогового учета",                             "удаление",                                       "actn_os-group-tax_deletion",                         "firm") .
    run add-right in this-procedure ("осн", "группы-ОС",                                           "ДОБАВЛЕНИЕ",                                     "actn_fixed-assets-groups_add-def",                   "firm") .
    run add-right in this-procedure ("осн", "группы-ОС",                                           "ИЗМЕНЕНИЕ",                                      "actn_fixed-assets-groups_update",                    "firm") .
    run add-right in this-procedure ("осн", "группы-ОС",                                           "удаление",                                       "actn_fixed-assets-groups_deletion",                  "firm") .
    run add-right in this-procedure ("осн", "карточки-МБП",                                        "ДОБАВЛЕНИЕ",                                     "actn_supplies-cards_add-def",                        "firm") .
    run add-right in this-procedure ("осн", "карточки-МБП",                                        "ИЗМЕНЕНИЕ",                                      "actn_supplies-cards_update",                         "firm") .
    run add-right in this-procedure ("осн", "карточки-МБП",                                        "ликв/вост",                                      "actn_supplies-cards_disposition-reconstruction",     "firm") .
    run add-right in this-procedure ("осн", "карточки-МБП",                                        "модернизация",                                   "actn_supplies-cards_modernization",                  "firm") .
    run add-right in this-procedure ("осн", "карточки-МБП",                                        "перемещение",                                    "actn_supplies-cards_displacement",                   "firm") .
    run add-right in this-procedure ("осн", "карточки-МБП",                                        "удаление",                                       "actn_supplies-cards_deletion",                       "firm") .
    run add-right in this-procedure ("осн", "карточки-Материалов",                                 "ДОБАВЛЕНИЕ",                                     "actn_row-cards_add-def",                             "firm") .
    run add-right in this-procedure ("осн", "карточки-Материалов",                                 "ИЗМЕНЕНИЕ",                                      "actn_row-cards_update",                              "firm") .
    run add-right in this-procedure ("осн", "карточки-Материалов",                                 "ликв/вост",                                      "actn_row-cards_disposition-reconstruction",          "firm") .
    run add-right in this-procedure ("осн", "карточки-Материалов",                                 "перемещение",                                    "actn_row-cards_displacement",                        "firm") .
    run add-right in this-procedure ("осн", "карточки-Материалов",                                 "удаление",                                       "actn_row-cards_deletion",                            "firm") .
    run add-right in this-procedure ("осн", "карточки-ОС",                                         "ДОБАВЛЕНИЕ",                                     "actn_fixed-assets-cards_add-def",                    "firm") .
    run add-right in this-procedure ("осн", "карточки-ОС",                                         "ИЗМЕНЕНИЕ",                                      "actn_fixed-assets-cards_update",                     "firm") .
    run add-right in this-procedure ("осн", "карточки-ОС",                                         "ликв/вост",                                      "actn_fixed-assets-cards_disposition-reconstruction", "firm") .
    run add-right in this-procedure ("осн", "карточки-ОС",                                         "модернизация",                                   "actn_fixed-assets-cards_modernization",              "firm") .
    run add-right in this-procedure ("осн", "карточки-ОС",                                         "перемещение",                                    "actn_fixed-assets-cards_displacement",               "firm") .
    run add-right in this-procedure ("осн", "карточки-ОС",                                         "переоценка",                                     "actn_fixed-assets-cards_overvalue",                  "firm") .
    run add-right in this-procedure ("осн", "карточки-ОС",                                         "печать-карточки",                                "actn_fixed-assets-cards_card-print",                 "firm") .
    run add-right in this-procedure ("осн", "карточки-ОС",                                         "удаление",                                       "actn_fixed-assets-cards_deletion",                   "firm") .
    run add-right in this-procedure ("осн", "нормы-амортизации",                                   "ДОБАВЛЕНИЕ",                                     "actn_depreciation-rate_add-def",                     "firm") .
    run add-right in this-procedure ("осн", "нормы-амортизации",                                   "ИЗМЕНЕНИЕ",                                      "actn_depreciation-rate_update",                      "firm") .
    run add-right in this-procedure ("осн", "нормы-амортизации",                                   "удаление",                                       "actn_depreciation-rate_deletion",                    "firm") .
    run add-right in this-procedure ("осн", "отчеты",                                              "печать",                                         "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("осн", "первичный документ ОС",                               "ДОБАВЛЕНИЕ",                                     "actn_os-src-docs_add-def",                           "firm") .
    run add-right in this-procedure ("осн", "первичный документ ОС",                               "ИЗМЕНЕНИЕ",                                      "actn_os-src-docs_update",                            "firm") .
    run add-right in this-procedure ("осн", "первичный документ ОС",                               "удаление",                                       "actn_os-src-docs_deletion",                          "firm") .
    run add-right in this-procedure ("осн", "печатная форма ОС",                                   "ДОБАВЛЕНИЕ",                                     "actn_os-frm-docs_add-def",                           "firm") .
    run add-right in this-procedure ("осн", "печатная форма ОС",                                   "ИЗМЕНЕНИЕ",                                      "actn_os-frm-docs_update",                            "firm") .
    run add-right in this-procedure ("осн", "печатная форма ОС",                                   "удаление",                                       "actn_os-frm-docs_deletion",                          "firm") .
    run add-right in this-procedure ("осн", "тип операций ОС",                                     "ДОБАВЛЕНИЕ",                                     "actn_os-oper-type_add-def",                          "firm") .
    run add-right in this-procedure ("осн", "тип операций ОС",                                     "ИЗМЕНЕНИЕ",                                      "actn_os-oper-type_update",                           "firm") .
    run add-right in this-procedure ("осн", "тип операций ОС",                                     "удаление",                                       "actn_os-oper-type_deletion",                         "firm") .
    run add-right in this-procedure ("офи", "МЦ",                                                  "работа",                                         "actn_wealth_work",                                   "global") .
    run add-right in this-procedure ("офи", "группа-клиентов",                                     "скидка",                                         "actn_clients-group_discount",                        "global") .
    run add-right in this-procedure ("офи", "книга-покупок",                                       "печать",                                         "actn_purchase-book_print",                           "firm") .
    run add-right in this-procedure ("офи", "книга-продаж",                                        "печать",                                         "actn_sales-book_print",                              "firm") .
    run add-right in this-procedure ("офи", "оплаты",                                              "ИЗМЕНЕНИЕ",                                      "actn_payments_update",                               "global") .
    run add-right in this-procedure ("офи", "отчеты",                                              "печать",                                         "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("офи", "платежи-ожидаемые",                                   "работа",                                         "actn_payments-expected_work",                        "firm") .
    run add-right in this-procedure ("офи", "справочник",                                          "изменение-групп",                                "actn_reference_groups-edit",                         "global") .
    run add-right in this-procedure ("офи", "справочник-валют",                                    "работа",                                         "actn_currency-reference_work",                       "global") .
    run add-right in this-procedure ("офи", "справочник-стран",                                    "работа",                                         "actn_country-reference_work",                        "global") .
    run add-right in this-procedure ("офи", "типы-платежей",                                       "ввод,удал,изм",                                  "actn_payments-types_input-deletion-updating",        "global") .
    run add-right in this-procedure ("офи", "фин_обязательства",                                   "ПРОСМОТР",                                       "actn_fin-liability_lookup",                          "firm") .
    run add-right in this-procedure ("офи", "шкалы",                                               "ИЗМЕНЕНИЕ",                                      "actn_scale_update",                                  "global") .
    run add-right in this-procedure ("рес", "касса/ресторан",                                      "работа",                                         "actn_cashdesk-restaurant_work",                      "firm") .
    run add-right in this-procedure ("рес", "отчеты",                                              "печать",                                         "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("рес", "рес_автопроизводство",                                "работа",                                         "actn_res-autofbr_work",                              "firm") .
    run add-right in this-procedure ("рес", "рес_печать",                                          "печать",                                         "actn_res-print_print",                               "firm") .
    run add-right in this-procedure ("рес", "рес_план-меню",                                       "ИЗМЕНЕНИЕ",                                      "actn_res-pln-menu_update",                           "firm") .
    run add-right in this-procedure ("рес", "рес_план-меню",                                       "ПРОСМОТР",                                       "actn_res-pln-menu_lookup",                           "firm") .
    run add-right in this-procedure ("рес", "рес_справочник",                                      "ИЗМЕНЕНИЕ",                                      "actn_res-reference_update",                          "firm") .
    run add-right in this-procedure ("рес", "рес_справочник",                                      "ПРОСМОТР",                                       "actn_res-reference_lookup",                          "firm") .
    run add-right in this-procedure ("скл", "отчеты",                                              "печать",                                         "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("скл", "печать-в-набор",                                      "печать",                                         "actn_composition-print_print",                       "firm") .
    run add-right in this-procedure ("скл", "печать-в-набор,-повторно",                            "печать",                                         "actn_composition-reprint_print",                     "firm") .
    run add-right in this-procedure ("фин", "апп",                                                 "<закрытие документа на факт>",                   "actn_income-payoff_close-fact",                      "firm") .
    run add-right in this-procedure ("фин", "апп",                                                 "<закрытие документа>",                           "actn_income-payoff_close-doc",                       "firm") .
    run add-right in this-procedure ("фин", "апп",                                                 "<открытие документа>",                           "actn_income-payoff_open-doc",                        "firm") .
    run add-right in this-procedure ("фин", "апр",                                                 "<закрытие документа на факт>",                   "actn_expense-payoff_close-fact",                     "firm") .
    run add-right in this-procedure ("фин", "апр",                                                 "<закрытие документа>",                           "actn_expense-payoff_close-doc",                      "firm") .
    run add-right in this-procedure ("фин", "апр",                                                 "<открытие документа>",                           "actn_expense-payoff_open-doc",                       "firm") .
    run add-right in this-procedure ("фин", "отчеты",                                              "печать",                                         "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("фин", "пко",                                                 "<закрытие документа на факт>",                   "actn_income-cash_close-fact",                        "firm") .
    run add-right in this-procedure ("фин", "пко",                                                 "<закрытие документа>",                           "actn_income-cash_close-doc",                         "firm") .
    run add-right in this-procedure ("фин", "пко",                                                 "<открытие документа>",                           "actn_income-cash_open-doc",                          "firm") .
    run add-right in this-procedure ("фин", "платежи",                                             "ДОБАВЛЕНИЕ",                                     "actn_fin-doc_add-def",                               "firm") .
    run add-right in this-procedure ("фин", "платежи",                                             "ИЗМЕНЕНИЕ",                                      "actn_fin-doc_update",                                "firm") .
    run add-right in this-procedure ("фин", "платежи",                                             "ПРОСМОТР",                                       "actn_fin-doc_lookup",                                "firm") .
    run add-right in this-procedure ("фин", "платежи",                                             "удаление",                                       "actn_fin-doc_deletion",                              "firm") .
    run add-right in this-procedure ("фин", "ппп",                                                 "<закрытие документа на факт>",                   "actn_income-cashless_close-fact",                    "firm") .
    run add-right in this-procedure ("фин", "ппп",                                                 "<закрытие документа>",                           "actn_income-cashless_close-doc",                     "firm") .
    run add-right in this-procedure ("фин", "ппп",                                                 "<отказ от документа>",                           "actn_income-cashless_reject-doc",                    "firm") .
    run add-right in this-procedure ("фин", "ппп",                                                 "<открытие документа>",                           "actn_income-cashless_open-doc",                      "firm") .
    run add-right in this-procedure ("фин", "рко",                                                 "<закрытие документа на факт>",                   "actn_expense-cash_close-fact",                       "firm") .
    run add-right in this-procedure ("фин", "рко",                                                 "<закрытие документа>",                           "actn_expense-cash_close-doc",                        "firm") .
    run add-right in this-procedure ("фин", "рко",                                                 "<открытие документа>",                           "actn_expense-cash_open-doc",                         "firm") .
    run add-right in this-procedure ("фин", "рпп",                                                 "<закрытие документа на факт>",                   "actn_expense-cashless_close-fact",                   "firm") .
    run add-right in this-procedure ("фин", "рпп",                                                 "<закрытие документа>",                           "actn_expense-cashless_close-doc",                    "firm") .
    run add-right in this-procedure ("фин", "рпп",                                                 "<отказ от документа>",                           "actn_expense-cashless_reject-doc",                   "firm") .
    run add-right in this-procedure ("фин", "рпп",                                                 "<открытие документа>",                           "actn_expense-cashless_open-doc",                     "firm") .
    run add-right in this-procedure ("фин", "фин_договор",                                         "ДОБАВЛЕНИЕ",                                     "actn_fin-contract_add-def",                          "firm") .
    run add-right in this-procedure ("фин", "фин_договор",                                         "ИЗМЕНЕНИЕ",                                      "actn_fin-contract_update",                           "firm") .
    run add-right in this-procedure ("фин", "фин_договор",                                         "модернизация",                                   "actn_fin-contract_modernization",                    "firm") .
    run add-right in this-procedure ("фин", "фин_договор",                                         "удаление",                                       "actn_fin-contract_deletion",                         "firm") .
    run add-right in this-procedure ("фин", "фин_договор",                                         "экспорт",                                        "actn_fin-contract_export",                           "firm") .
    run add-right in this-procedure ("фин", "фин_обязательства",                                   "<закрытие документа на факт>",                   "actn_fin-liability_close-fact",                      "firm") .
    run add-right in this-procedure ("фин", "фин_обязательства",                                   "ДОБАВЛЕНИЕ",                                     "actn_fin-liability_add-def",                         "firm") .
    run add-right in this-procedure ("фин", "фин_обязательства",                                   "ИЗМЕНЕНИЕ",                                      "actn_fin-liability_update",                          "firm") .
    run add-right in this-procedure ("фин", "фин_обязательства",                                   "ПРОСМОТР",                                       "actn_fin-liability_lookup",                          "firm") .
    run add-right in this-procedure ("фин", "фин_обязательства",                                   "печать",                                         "actn_fin-liability_print",                           "firm") .
    run add-right in this-procedure ("фин", "фин_обязательства",                                   "удаление",                                       "actn_fin-liability_deletion",                        "firm") .
    run add-right in this-procedure ("фин", "фин_обязательства",                                   "экспорт",                                        "actn_fin-liability_export",                          "firm") .
    run add-right in this-procedure ("фин", "фин_справочник",                                      "ДОБАВЛЕНИЕ",                                     "actn_fin-reference_add-def",                         "firm") .
    run add-right in this-procedure ("фин", "фин_справочник",                                      "ИЗМЕНЕНИЕ",                                      "actn_fin-reference_update",                          "firm") .
    run add-right in this-procedure ("фин", "фин_справочник",                                      "ПРОСМОТР",                                       "actn_fin-reference_lookup",                          "firm") .
    run add-right in this-procedure ("фин", "фин_справочник",                                      "печать",                                         "actn_fin-reference_print",                           "firm") .
    run add-right in this-procedure ("фин", "фин_справочник",                                      "удаление",                                       "actn_fin-reference_deletion",                        "firm") .
    run add-right in this-procedure ("фин", "фин_справочник",                                      "экспорт",                                        "actn_fin-reference_export",                          "firm") .
  end.

end procedure. /* fill-right-rus */


procedure fill-right-eng :

  do
  on error undo, return error return-value
  :
    run add-right in this-procedure ("acc",    "account-function",         "balance",                                 "actn_acc-functions_balance",                         "firm") .
    run add-right in this-procedure ("acc",    "account-function",         "close",                                   "actn_acc-functions_close",                           "firm") .
    run add-right in this-procedure ("acc",    "account-function",         "main-book",                               "actn_acc-functions_main-book",                       "firm") .
    run add-right in this-procedure ("acc",    "account-function",         "multibalance",                            "actn_acc-functions_multibalance",                    "firm") .
    run add-right in this-procedure ("acc",    "account-function",         "open",                                    "actn_acc-functions_open",                            "firm") .
    run add-right in this-procedure ("acc",    "account-function",         "waybill-without-trans",                   "actn_acc-functions_transless-waybill",               "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "add-acc-item",                            "actn_acc-options_add-acc-item",                      "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "delete-acc-item",                         "actn_acc-options_del-acc-item",                      "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "external-transaction",                    "actn_acc-options_external-auto-transaction",         "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "form-add",                                "actn_acc-options_form-add",                          "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "form-delete",                             "actn_acc-options_form-del",                          "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "form-update",                             "actn_acc-options_form-upd",                          "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "oper-sum-add",                            "actn_acc-options_oper-sum-add",                      "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "oper-sum-delete",                         "actn_acc-options_oper-sum-del",                      "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "oper-sum-update",                         "actn_acc-options_oper-sum-upd",                      "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "typical-oper-add",                        "actn_acc-options_typical-oper-add",                  "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "typical-oper-delete",                     "actn_acc-options_typical-oper-del",                  "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "typical-oper-update",                     "actn_acc-options_typical-oper-upd",                  "firm") .
    run add-right in this-procedure ("acc",    "account-options",          "update-acc-item",                         "actn_acc-options_upd-acc-item",                      "firm") .
    run add-right in this-procedure ("acc",    "account-service",          "utilities",                               "actn_acc-service_utilities",                         "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "add-acc-item",                            "actn_analitic_add-acc-item",                         "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "add-node",                                "actn_analitic_add-nodes",                            "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "cash-book",                               "actn_analitic_cash-book",                            "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "delete-acc-item",                         "actn_analitic_del-acc-item",                         "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "delete-archive",                          "actn_analitic_del-archive",                          "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "delete-node",                             "actn_analitic_del-nodes",                            "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "function",                                "actn_analitic_functions",                            "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "jobber-turn",                             "actn_analitic_jobber-turn",                          "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "jobber-turn-base-curr",                   "actn_analitic_jobber-turn-base-curr",                "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "jobber-turn-roubles",                     "actn_analitic_jobber-turn-roubles",                  "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "print",                                   "actn_analitic_print",                                "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "update-acc-item",                         "actn_analitic_upd-acc-item",                         "firm") .
    run add-right in this-procedure ("acc",    "analitic",                 "update-node",                             "actn_analitic_upd-nodes",                            "firm") .
    run add-right in this-procedure ("acc",    "purchase-book",            "print",                                   "actn_purchase-book_print",                           "firm") .
    run add-right in this-procedure ("acc",    "report",                   "print",                                   "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("acc",    "sale-book",                "print",                                   "actn_sales-book_print",                              "firm") .
    run add-right in this-procedure ("acc",    "transaction",              "LOOKUP",                                  "actn_transactions_lookup",                           "firm") .
    run add-right in this-procedure ("acc",    "transaction",              "base-curr-amount",                        "actn_transactions_base-curr-amount",                 "firm") .
    run add-right in this-procedure ("acc",    "transaction",              "print",                                   "actn_transactions_print",                            "firm") .
    run add-right in this-procedure ("acc",    "transaction",              "update-complete-transaction",             "actn_transactions_upd-comlete-trans",                "firm") .
    run add-right in this-procedure ("acc",    "transaction",              "update-group",                            "actn_transactions_upd-group",                        "firm") .
    run add-right in this-procedure ("acc",    "transaction",              "update-status",                           "actn_transactions_upd-status",                       "firm") .
    run add-right in this-procedure ("acc",    "transaction",              "work",                                    "actn_transactions_work",                             "firm") .
    run add-right in this-procedure ("cmm",    "CB-rate",                  "UPDATE",                                  "actn_cb-rate_update",                                "global") .
    run add-right in this-procedure ("cmm",    "GLN",                      "UPDATE",                                  "actn_rh-attr-gln_update",                            "global") .
    run add-right in this-procedure ("cmm",    "MICEX-rate",               "UPDATE",                                  "actn_micex-rate_update",                             "global") .
    run add-right in this-procedure ("cmm",    "POS-reference",            "on-off",                                  "actn_cashdesk-reference_on-off",                     "object") .
    run add-right in this-procedure ("cmm",    "POS-reference",            "preparation",                             "actn_cashdesk-reference_input-deletion-updating",    "object") .
    run add-right in this-procedure ("cmm",    "PS-fact",                  "print",                                   "actn_ps-fact_print",                                 "firm") .
    run add-right in this-procedure ("cmm",    "Parts",                    "CreateNeg",                               "actn_parts_createneg",                               "object") .
    run add-right in this-procedure ("cmm",    "Parts",                    "all",                                     "actn_parts_all",                                     "firm") .
    run add-right in this-procedure ("cmm",    "account-service",          "transaction-generation",                  "actn_acc-service_trans-generation",                  "firm") .
    run add-right in this-procedure ("cmm",    "account-service",          "waybill-clear-list",                      "actn_acc-service_waybill-clear-list",                "firm") .
    run add-right in this-procedure ("cmm",    "acp",                      "update-closed",                           "actn_income_update-closed",                          "object") .
    run add-right in this-procedure ("cmm",    "acp",                      "update-last-date",                        "actn_income_update-last-date",                       "object") .
    run add-right in this-procedure ("cmm",    "alt-barcode",              "preparation",                             "actn_alt-barcode_preparation",                       "global") .
    run add-right in this-procedure ("cmm",    "alt-barcode",              "scgb",                                    "actn_alt-barcode_gbl-sc-code",                       "global") .
    run add-right in this-procedure ("cmm",    "alt-barcode",              "sclc",                                    "actn_alt-barcode_loc-sc-code",                       "global") .
    run add-right in this-procedure ("cmm",    "alt-barcode",              "ssgb",                                    "actn_alt-barcode_gbl-ss-code",                       "global") .
    run add-right in this-procedure ("cmm",    "alt-barcode",              "sslc",                                    "actn_alt-barcode_loc-ss-code",                       "global") .
    run add-right in this-procedure ("cmm",    "alt-barcode",              "turn-on",                                 "actn_alt-barcode_turn-on",                           "global") .
    run add-right in this-procedure ("cmm",    "analitic",                 "archive",                                 "actn_analitic_archive",                              "firm") .
    run add-right in this-procedure ("cmm",    "archive",                  "LOOKUP",                                  "actn_archive_lookup",                                "object") .
    run add-right in this-procedure ("cmm",    "archive-ahsp",             "UPDATE",                                  "actn_archive-ahsp_update",                           "object") .
    run add-right in this-procedure ("cmm",    "archive-aht",              "UPDATE",                                  "actn_archive-aht_update",                            "object") .
    run add-right in this-procedure ("cmm",    "archive-arh",              "UPDATE",                                  "actn_archive-arh_update",                            "object") .
    run add-right in this-procedure ("cmm",    "archive-multyfirm",        "UPDATE",                                  "actn_archive-hold_update",                           "firm") .
    run add-right in this-procedure ("cmm",    "archive-prc",              "UPDATE",                                  "actn_archive-prc_update",                            "object") .
    run add-right in this-procedure ("cmm",    "cashier",                  "stat-on-cashiers",                        "actn_cashiers_stat-on-cashiers",                     "firm") .
    run add-right in this-procedure ("cmm",    "client-reference",         "LOOKUP",                                  "actn_client-reference_lookup",                       "global") .
    run add-right in this-procedure ("cmm",    "client-reference",         "UPDATE",                                  "actn_client-reference_update",                       "global") .
    run add-right in this-procedure ("cmm",    "client-reference",         "add-del",                                 "actn_client-reference_add-del",                      "global") .
    run add-right in this-procedure ("cmm",    "client-reference-prs",     "add-del",                                 "actn_client-reference-prs_add-del",                  "global") .
    run add-right in this-procedure ("cmm",    "client-requisite",         "add-upd",                                 "actn_client-requisite_add-upd",                      "firm") .
    run add-right in this-procedure ("cmm",    "del_document",             "all",                                     "actn_c-documents_all",                               "object") .
    run add-right in this-procedure ("cmm",    "delivery-storage",         "work",                                    "actn_delivery-storage_work",                         "global") .
    run add-right in this-procedure ("cmm",    "discount",                 "work",                                    "actn_discount_work",                                 "object") .
    run add-right in this-procedure ("cmm",    "discount-cards-totals",    "print",                                   "actn_discount-cards-totals_print",                   "firm") .
    run add-right in this-procedure ("cmm",    "document",                 "all",                                     "actn_documents_all",                                 "global") .
    run add-right in this-procedure ("cmm",    "document",                 "export",                                  "actn_documents_export",                              "firm") .
    run add-right in this-procedure ("cmm",    "document-reports-cost",    "print",                                   "actn_document-reports-cost_print",                   "firm") .
    run add-right in this-procedure ("cmm",    "document-reports-sale",    "print",                                   "actn_document-reports-sale_print",                   "firm") .
    run add-right in this-procedure ("cmm",    "edi",                      "UPDATE",                                  "actn_rh-attr-edi_update",                            "global") .
    run add-right in this-procedure ("cmm",    "exmark-reference",         "UPDATE",                                  "actn_exmark-reference_update",                       "global") .
    run add-right in this-procedure ("cmm",    "fin-bank-accounts",        "COPY",                                    "actn_fin-bank-accounts_add-copy",                    "firm") .
    run add-right in this-procedure ("cmm",    "fin-bank-accounts",        "CREATE",                                  "actn_fin-bank-accounts_add-def",                     "firm") .
    run add-right in this-procedure ("cmm",    "fin-bank-accounts",        "UPDATE",                                  "actn_fin-bank-accounts_update",                      "firm") .
    run add-right in this-procedure ("cmm",    "fin-bank-accounts",        "deletion",                                "actn_fin-bank-accounts_deletion",                    "firm") .
    run add-right in this-procedure ("cmm",    "fin-contract",             "LOOKUP",                                  "actn_fin-contract_lookup",                           "firm") .
    run add-right in this-procedure ("cmm",    "group-goods-cash-desk",    "CREATE",                                  "actn_group-goods-cash-desk_add-def",                 "object") .
    run add-right in this-procedure ("cmm",    "group-goods-cash-desk",    "UPDATE",                                  "actn_group-goods-cash-desk_update",                  "object") .
    run add-right in this-procedure ("cmm",    "invoice",                  "CREATE",                                  "actn_invoice_add-def",                               "object") .
    run add-right in this-procedure ("cmm",    "invoice",                  "LOOKUP",                                  "actn_invoice_lookup",                                "object") .
    run add-right in this-procedure ("cmm",    "invoice",                  "UPDATE",                                  "actn_invoice_update",                                "object") .
    run add-right in this-procedure ("cmm",    "invoice",                  "deletion",                                "actn_invoice_deletion",                              "object") .
    run add-right in this-procedure ("cmm",    "invoice",                  "print",                                   "actn_invoice_print",                                 "object") .
    run add-right in this-procedure ("cmm",    "kitchen",                  "work",                                    "actn_fbr-prn_work",                                  "global") .
    run add-right in this-procedure ("cmm",    "main-barcode",             "deletion",                                "actn_main-barcode_deletion",                         "global") .
    run add-right in this-procedure ("cmm",    "main-barcode",             "preparation",                             "actn_main-barcode_preparation",                      "global") .
    run add-right in this-procedure ("cmm",    "obj-date",                 "UPDATE",                                  "actn_obj-date-change_update",                        "firm") .
    run add-right in this-procedure ("cmm",    "only-edi",                 "UPDATE",                                  "actn_rh-attr-only-edi_update",                       "global") .
    run add-right in this-procedure ("cmm",    "openxml-subsystem",        "CREATE",                                  "actn_openxml-subsystem_add-def",                     "object") .
    run add-right in this-procedure ("cmm",    "openxml-subsystem",        "LOOKUP",                                  "actn_openxml-subsystem_lookup",                      "object") .
    run add-right in this-procedure ("cmm",    "openxml-subsystem",        "UPDATE",                                  "actn_openxml-subsystem_update",                      "object") .
    run add-right in this-procedure ("cmm",    "openxml-subsystem",        "deletion",                                "actn_openxml-subsystem_deletion",                    "object") .
    run add-right in this-procedure ("cmm",    "openxml-subsystem",        "on-off",                                  "actn_openxml-subsystem_on-off",                      "object") .
    run add-right in this-procedure ("cmm",    "order",                    "POS/send",                                "actn_pmnt-ord-doc_sending",                          "global") .
    run add-right in this-procedure ("cmm",    "overvalue-cast",           "print",                                   "actn_overvalue-cast_print",                          "firm") .
    run add-right in this-procedure ("cmm",    "pay docs",                 "CREATE",                                  "actn_bgh-paydocs_add-def",                           "firm") .
    run add-right in this-procedure ("cmm",    "pay docs",                 "LOOKUP",                                  "actn_bgh-paydocs_lookup",                            "firm") .
    run add-right in this-procedure ("cmm",    "pay docs",                 "UPDATE",                                  "actn_bgh-paydocs_update",                            "firm") .
    run add-right in this-procedure ("cmm",    "pay docs",                 "deletion",                                "actn_bgh-paydocs_deletion",                          "firm") .
    run add-right in this-procedure ("cmm",    "pay docs",                 "print",                                   "actn_bgh-paydocs_print",                             "firm") .
    run add-right in this-procedure ("cmm",    "payments-reference",       "LOOKUP",                                  "actn_payments-reference_lookup",                     "firm") .
    run add-right in this-procedure ("cmm",    "permanent-client-sale",    "print",                                   "actn_permanent-client-sale_print",                   "firm") .
    run add-right in this-procedure ("cmm",    "price-list",               "print",                                   "actn_price-list_print",                              "firm") .
    run add-right in this-procedure ("cmm",    "price-list-to-file",       "print",                                   "actn_price-list-to-file_print",                      "firm") .
    run add-right in this-procedure ("cmm",    "proceeds-monthly",         "print",                                   "actn_proceeds-monthly_print",                        "firm") .
    run add-right in this-procedure ("cmm",    "prod-classifier-monthly",  "print",                                   "actn_prod-classifier-monthly_print",                 "firm") .
    run add-right in this-procedure ("cmm",    "prod-monthly",             "print",                                   "actn_prod-monthly_print",                            "firm") .
    run add-right in this-procedure ("cmm",    "receipt",                  "deletion",                                "actn_receipts_deletion",                             "object") .
    run add-right in this-procedure ("cmm",    "receipts-and-revenue",     "print",                                   "actn_cur-obj-proceeds_print",                        "firm") .
    run add-right in this-procedure ("cmm",    "recipe-reference",         "cmm",                                     "actn_recipe-reference_conjoint",                     "object") .
    run add-right in this-procedure ("cmm",    "recipe-reference",         "preparation",                             "actn_recipe-reference_input-deletion-updating",      "object") .
    run add-right in this-procedure ("cmm",    "reference",                "UPDATE",                                  "actn_reference_update",                              "global") .
    run add-right in this-procedure ("cmm",    "reference",                "archive",                                 "actn_reference_archive",                             "firm") .
    run add-right in this-procedure ("cmm",    "reference",                "deletion",                                "actn_reference_deletion",                            "global") .
    run add-right in this-procedure ("cmm",    "reference",                "export",                                  "actn_references_export",                             "object") .
    run add-right in this-procedure ("cmm",    "reference",                "price-calc-param",                        "actn_reference_calc-increase",                       "global") .
    run add-right in this-procedure ("cmm",    "reference",                "print",                                   "actn_reference_print",                               "firm") .
    run add-right in this-procedure ("cmm",    "reference",                "update-goods-tax",                        "actn_reference_upd-gds-tax",                         "global") .
    run add-right in this-procedure ("cmm",    "reference",                "update-group",                            "actn_reference_upd-group",                           "global") .
    run add-right in this-procedure ("cmm",    "reference-dc-type",        "preparation",                             "actn_reference-dc-type_input-deletion-updating",     "global") .
    run add-right in this-procedure ("cmm",    "reference-list",           "print",                                   "actn_reference-lists_print",                         "firm") .
    run add-right in this-procedure ("cmm",    "reference-petrolium",      "UPDATE",                                  "actn_reference-petrolium_update",                    "global") .
    run add-right in this-procedure ("cmm",    "reference-services",       "UPDATE",                                  "actn_reference-services_update",                     "global") .
    run add-right in this-procedure ("cmm",    "reference-services",       "deletion",                                "actn_reference-services_deletion",                   "global") .
    run add-right in this-procedure ("cmm",    "refernse-dis",             "preparation",                             "actn_referense-dis_input-deletion-updating",         "firm") .
    run add-right in this-procedure ("cmm",    "ren-art",                  "UPDATE",                                  "actn_ren-art_update",                                "global") .
    run add-right in this-procedure ("cmm",    "right-assignment",         "UPDATE",                                  "actn_rights_update",                                 "global") .
    run add-right in this-procedure ("cmm",    "rt-check-price",           "work",                                    "actn_rt-check-price_work",                           "object") .
    run add-right in this-procedure ("cmm",    "rt-edit-doc",              "<close document fact>",                   "actn_rt-edit-doc_close-fact",                        "object") .
    run add-right in this-procedure ("cmm",    "rt-edit-doc",              "<close document>",                        "actn_rt-edit-doc_close-doc",                         "object") .
    run add-right in this-procedure ("cmm",    "rt-edit-doc",              "CREATE",                                  "actn_rt-edit-doc_add-def",                           "object") .
    run add-right in this-procedure ("cmm",    "rt-edit-doc",              "work",                                    "actn_rt-edit-doc_work",                              "object") .
    run add-right in this-procedure ("cmm",    "sale-report",              "print",                                   "actn_sale-report_print",                             "firm") .
    run add-right in this-procedure ("cmm",    "scales",                   "deletion",                                "actn_scales_deletion",                               "global") .
    run add-right in this-procedure ("cmm",    "scales/goods-group",       "add-delete",                              "actn_scales-goods-groups_adding-deletion",           "global") .
    run add-right in this-procedure ("cmm",    "schet-fact-doc",           "CREATE",                                  "actn_schet-fact-doc_add-def",                        "firm") .
    run add-right in this-procedure ("cmm",    "schet-fact-doc",           "LOOKUP",                                  "actn_schet-fact-doc_lookup",                         "firm") .
    run add-right in this-procedure ("cmm",    "schet-fact-doc",           "UPDATE",                                  "actn_schet-fact-doc_update",                         "firm") .
    run add-right in this-procedure ("cmm",    "schet-fact-doc",           "close",                                   "actn_schet-fact-doc_close",                          "firm") .
    run add-right in this-procedure ("cmm",    "schet-fact-doc",           "deletion",                                "actn_schet-fact-doc_deletion",                       "firm") .
    run add-right in this-procedure ("cmm",    "schet-fact-doc",           "export",                                  "actn_schet-fact-doc_export",                         "firm") .
    run add-right in this-procedure ("cmm",    "schet-fact-doc",           "open",                                    "actn_schet-fact-doc_open",                           "firm") .
    run add-right in this-procedure ("cmm",    "send-trn-edi",             "UPDATE",                                  "actn_rh-attr-send-trn-edi_update",                   "global") .
    run add-right in this-procedure ("cmm",    "shop-rate",                "UPDATE",                                  "actn_shop-rate_update",                              "object") .
    run add-right in this-procedure ("cmm",    "tax-kinds",                "UPDATE",                                  "actn_tax-kinds_update",                              "global") .
    run add-right in this-procedure ("cmm",    "tax-rate-codes",           "UPDATE",                                  "actn_tax-rates_update",                              "firm") .
    run add-right in this-procedure ("cmm",    "tax-rate-values",          "UPDATE",                                  "actn_tax-rate-values_update",                        "object") .
    run add-right in this-procedure ("cmm",    "tax-settlement",           "print",                                   "actn_tax-settlement_print",                          "firm") .
    run add-right in this-procedure ("cmm",    "unit",                     "UPDATE",                                  "actn_unit_update",                                   "global") .
    run add-right in this-procedure ("cmm",    "updfind",                  "UPDATE",                                  "actn_updfind_update",                                "firm") .
    run add-right in this-procedure ("cmm",    "waybills-to-file",         "print",                                   "actn_waybills-to-file_print",                        "firm") .
    run add-right in this-procedure ("cmm",    "wth-receipt",              "LOOKUP",                                  "actn_wth-receipts_lookup",                           "object") .
    run add-right in this-procedure ("cmm",    "wth-receipt",              "UPDATE",                                  "actn_wth-receipts_update",                           "object") .
    run add-right in this-procedure ("cmm",    "wth-receipt",              "deletion",                                "actn_wth-receipts_deletion",                         "object") .
    run add-right in this-procedure ("fas",    "assets kind of activity",  "CREATE",                                  "actn_os-act-kind_add-def",                           "firm") .
    run add-right in this-procedure ("fas",    "assets kind of activity",  "UPDATE",                                  "actn_os-act-kind_update",                            "firm") .
    run add-right in this-procedure ("fas",    "assets kind of activity",  "deletion",                                "actn_os-act-kind_deletion",                          "firm") .
    run add-right in this-procedure ("fas",    "assets operation type",    "CREATE",                                  "actn_os-oper-type_add-def",                          "firm") .
    run add-right in this-procedure ("fas",    "assets operation type",    "UPDATE",                                  "actn_os-oper-type_update",                           "firm") .
    run add-right in this-procedure ("fas",    "assets operation type",    "deletion",                                "actn_os-oper-type_deletion",                         "firm") .
    run add-right in this-procedure ("fas",    "assets operation variant", "CREATE",                                  "actn_os-oper-var_add-def",                           "firm") .
    run add-right in this-procedure ("fas",    "assets operation variant", "UPDATE",                                  "actn_os-oper-var_update",                            "firm") .
    run add-right in this-procedure ("fas",    "assets operation variant", "deletion",                                "actn_os-oper-var_deletion",                          "firm") .
    run add-right in this-procedure ("fas",    "assets print form",        "CREATE",                                  "actn_os-frm-docs_add-def",                           "firm") .
    run add-right in this-procedure ("fas",    "assets print form",        "UPDATE",                                  "actn_os-frm-docs_update",                            "firm") .
    run add-right in this-procedure ("fas",    "assets print form",        "deletion",                                "actn_os-frm-docs_deletion",                          "firm") .
    run add-right in this-procedure ("fas",    "assets source documents",  "CREATE",                                  "actn_os-src-docs_add-def",                           "firm") .
    run add-right in this-procedure ("fas",    "assets source documents",  "UPDATE",                                  "actn_os-src-docs_update",                            "firm") .
    run add-right in this-procedure ("fas",    "assets source documents",  "deletion",                                "actn_os-src-docs_deletion",                          "firm") .
    run add-right in this-procedure ("fas",    "assets tax group",         "CREATE",                                  "actn_os-group-tax_add-def",                          "firm") .
    run add-right in this-procedure ("fas",    "assets tax group",         "UPDATE",                                  "actn_os-group-tax_update",                           "firm") .
    run add-right in this-procedure ("fas",    "assets tax group",         "deletion",                                "actn_os-group-tax_deletion",                         "firm") .
    run add-right in this-procedure ("fas",    "depreciation-rate",        "CREATE",                                  "actn_depreciation-rate_add-def",                     "firm") .
    run add-right in this-procedure ("fas",    "depreciation-rate",        "UPDATE",                                  "actn_depreciation-rate_update",                      "firm") .
    run add-right in this-procedure ("fas",    "depreciation-rate",        "deletion",                                "actn_depreciation-rate_deletion",                    "firm") .
    run add-right in this-procedure ("fas",    "fixed-assets-card",        "CREATE",                                  "actn_fixed-assets-cards_add-def",                    "firm") .
    run add-right in this-procedure ("fas",    "fixed-assets-card",        "UPDATE",                                  "actn_fixed-assets-cards_update",                     "firm") .
    run add-right in this-procedure ("fas",    "fixed-assets-card",        "card-print",                              "actn_fixed-assets-cards_card-print",                 "firm") .
    run add-right in this-procedure ("fas",    "fixed-assets-card",        "deletion",                                "actn_fixed-assets-cards_deletion",                   "firm") .
    run add-right in this-procedure ("fas",    "fixed-assets-card",        "displacement",                            "actn_fixed-assets-cards_displacement",               "firm") .
    run add-right in this-procedure ("fas",    "fixed-assets-card",        "disposition-reconstruction",              "actn_fixed-assets-cards_disposition-reconstruction", "firm") .
    run add-right in this-procedure ("fas",    "fixed-assets-card",        "modernization",                           "actn_fixed-assets-cards_modernization",              "firm") .
    run add-right in this-procedure ("fas",    "fixed-assets-card",        "overvalue",                               "actn_fixed-assets-cards_overvalue",                  "firm") .
    run add-right in this-procedure ("fas",    "fixed-assets-group",       "CREATE",                                  "actn_fixed-assets-groups_add-def",                   "firm") .
    run add-right in this-procedure ("fas",    "fixed-assets-group",       "UPDATE",                                  "actn_fixed-assets-groups_update",                    "firm") .
    run add-right in this-procedure ("fas",    "fixed-assets-group",       "deletion",                                "actn_fixed-assets-groups_deletion",                  "firm") .
    run add-right in this-procedure ("fas",    "report",                   "print",                                   "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("fas",    "row-cards",                "CREATE",                                  "actn_row-cards_add-def",                             "firm") .
    run add-right in this-procedure ("fas",    "row-cards",                "UPDATE",                                  "actn_row-cards_update",                              "firm") .
    run add-right in this-procedure ("fas",    "row-cards",                "deletion",                                "actn_row-cards_deletion",                            "firm") .
    run add-right in this-procedure ("fas",    "row-cards",                "displacement",                            "actn_row-cards_displacement",                        "firm") .
    run add-right in this-procedure ("fas",    "row-cards",                "disposition-reconstruction",              "actn_row-cards_disposition-reconstruction",          "firm") .
    run add-right in this-procedure ("fas",    "supplies-cards",           "CREATE",                                  "actn_supplies-cards_add-def",                        "firm") .
    run add-right in this-procedure ("fas",    "supplies-cards",           "UPDATE",                                  "actn_supplies-cards_update",                         "firm") .
    run add-right in this-procedure ("fas",    "supplies-cards",           "deletion",                                "actn_supplies-cards_deletion",                       "firm") .
    run add-right in this-procedure ("fas",    "supplies-cards",           "displacement",                            "actn_supplies-cards_displacement",                   "firm") .
    run add-right in this-procedure ("fas",    "supplies-cards",           "disposition-reconstruction",              "actn_supplies-cards_disposition-reconstruction",     "firm") .
    run add-right in this-procedure ("fas",    "supplies-cards",           "modernization",                           "actn_supplies-cards_modernization",                  "firm") .
    run add-right in this-procedure ("fin",    "ec",                       "<close document fact>",                   "actn_expense-cash_close-fact",                       "firm") .
    run add-right in this-procedure ("fin",    "ec",                       "<close document>",                        "actn_expense-cash_close-doc",                        "firm") .
    run add-right in this-procedure ("fin",    "ec",                       "<open document>",                         "actn_expense-cash_open-doc",                         "firm") .
    run add-right in this-procedure ("fin",    "ei",                       "<close document fact>",                   "actn_expense-cashless_close-fact",                   "firm") .
    run add-right in this-procedure ("fin",    "ei",                       "<close document>",                        "actn_expense-cashless_close-doc",                    "firm") .
    run add-right in this-procedure ("fin",    "ei",                       "<open document>",                         "actn_expense-cashless_open-doc",                     "firm") .
    run add-right in this-procedure ("fin",    "ei",                       "<reject document>",                       "actn_expense-cashless_reject-doc",                   "firm") .
    run add-right in this-procedure ("fin",    "eo",                       "<close document fact>",                   "actn_expense-payoff_close-fact",                     "firm") .
    run add-right in this-procedure ("fin",    "eo",                       "<close document>",                        "actn_expense-payoff_close-doc",                      "firm") .
    run add-right in this-procedure ("fin",    "eo",                       "<open document>",                         "actn_expense-payoff_open-doc",                       "firm") .
    run add-right in this-procedure ("fin",    "fin-contract",             "CREATE",                                  "actn_fin-contract_add-def",                          "firm") .
    run add-right in this-procedure ("fin",    "fin-contract",             "UPDATE",                                  "actn_fin-contract_update",                           "firm") .
    run add-right in this-procedure ("fin",    "fin-contract",             "deletion",                                "actn_fin-contract_deletion",                         "firm") .
    run add-right in this-procedure ("fin",    "fin-contract",             "export",                                  "actn_fin-contract_export",                           "firm") .
    run add-right in this-procedure ("fin",    "fin-contract",             "modernization",                           "actn_fin-contract_modernization",                    "firm") .
    run add-right in this-procedure ("fin",    "fin-doc",                  "CREATE",                                  "actn_fin-doc_add-def",                               "firm") .
    run add-right in this-procedure ("fin",    "fin-doc",                  "LOOKUP",                                  "actn_fin-doc_lookup",                                "firm") .
    run add-right in this-procedure ("fin",    "fin-doc",                  "UPDATE",                                  "actn_fin-doc_update",                                "firm") .
    run add-right in this-procedure ("fin",    "fin-doc",                  "deletion",                                "actn_fin-doc_deletion",                              "firm") .
    run add-right in this-procedure ("fin",    "fin-liability",            "<close document fact>",                   "actn_fin-liability_close-fact",                      "firm") .
    run add-right in this-procedure ("fin",    "fin-liability",            "CREATE",                                  "actn_fin-liability_add-def",                         "firm") .
    run add-right in this-procedure ("fin",    "fin-liability",            "LOOKUP",                                  "actn_fin-liability_lookup",                          "firm") .
    run add-right in this-procedure ("fin",    "fin-liability",            "UPDATE",                                  "actn_fin-liability_update",                          "firm") .
    run add-right in this-procedure ("fin",    "fin-liability",            "deletion",                                "actn_fin-liability_deletion",                        "firm") .
    run add-right in this-procedure ("fin",    "fin-liability",            "export",                                  "actn_fin-liability_export",                          "firm") .
    run add-right in this-procedure ("fin",    "fin-liability",            "print",                                   "actn_fin-liability_print",                           "firm") .
    run add-right in this-procedure ("fin",    "fin-reference",            "CREATE",                                  "actn_fin-reference_add-def",                         "firm") .
    run add-right in this-procedure ("fin",    "fin-reference",            "LOOKUP",                                  "actn_fin-reference_lookup",                          "firm") .
    run add-right in this-procedure ("fin",    "fin-reference",            "UPDATE",                                  "actn_fin-reference_update",                          "firm") .
    run add-right in this-procedure ("fin",    "fin-reference",            "deletion",                                "actn_fin-reference_deletion",                        "firm") .
    run add-right in this-procedure ("fin",    "fin-reference",            "export",                                  "actn_fin-reference_export",                          "firm") .
    run add-right in this-procedure ("fin",    "fin-reference",            "print",                                   "actn_fin-reference_print",                           "firm") .
    run add-right in this-procedure ("fin",    "ic",                       "<close document fact>",                   "actn_income-cash_close-fact",                        "firm") .
    run add-right in this-procedure ("fin",    "ic",                       "<close document>",                        "actn_income-cash_close-doc",                         "firm") .
    run add-right in this-procedure ("fin",    "ic",                       "<open document>",                         "actn_income-cash_open-doc",                          "firm") .
    run add-right in this-procedure ("fin",    "ii",                       "<close document fact>",                   "actn_income-cashless_close-fact",                    "firm") .
    run add-right in this-procedure ("fin",    "ii",                       "<close document>",                        "actn_income-cashless_close-doc",                     "firm") .
    run add-right in this-procedure ("fin",    "ii",                       "<open document>",                         "actn_income-cashless_open-doc",                      "firm") .
    run add-right in this-procedure ("fin",    "ii",                       "<reject document>",                       "actn_income-cashless_reject-doc",                    "firm") .
    run add-right in this-procedure ("fin",    "io",                       "<close document fact>",                   "actn_income-payoff_close-fact",                      "firm") .
    run add-right in this-procedure ("fin",    "io",                       "<close document>",                        "actn_income-payoff_close-doc",                       "firm") .
    run add-right in this-procedure ("fin",    "io",                       "<open document>",                         "actn_income-payoff_open-doc",                        "firm") .
    run add-right in this-procedure ("fin",    "report",                   "print",                                   "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("object", "Object-Object",            "CREATE",                                  "actn_o-o_add-def",                                   "object") .
    run add-right in this-procedure ("object", "Object-Object",            "UPDATE",                                  "actn_o-o_update",                                    "object") .
    run add-right in this-procedure ("object", "Object-Object",            "deletion",                                "actn_o-o_deletion",                                  "object") .
    run add-right in this-procedure ("object", "POS-reference",            "UPDATE",                                  "actn_cashdesk-reference_update",                     "object") .
    run add-right in this-procedure ("object", "POS/cashier",              "UPDATE",                                  "actn_cashdesk-cashiers_update",                      "object") .
    run add-right in this-procedure ("object", "POS/client",               "CREATE",                                  "actn_cashdesk-clients_add-def",                      "object") .
    run add-right in this-procedure ("object", "POS/client",               "deletion",                                "actn_cashdesk-clients_deletion",                     "object") .
    run add-right in this-procedure ("object", "POS/curr-rate",            "UPDATE",                                  "actn_cashdesk-rates_update",                         "object") .
    run add-right in this-procedure ("object", "POS/goods",                "CREATE",                                  "actn_cashdesk-goods_add-def",                        "object") .
    run add-right in this-procedure ("object", "POS/goods",                "deletion",                                "actn_cashdesk-goods_deletion",                       "object") .
    run add-right in this-procedure ("object", "POS/goods-group",          "UPDATE",                                  "actn_cashdesk-goods-groups_update",                  "object") .
    run add-right in this-procedure ("object", "POS/payment",              "CREATE",                                  "actn_cashdesk-payments_add-def",                     "object") .
    run add-right in this-procedure ("object", "POS/payment",              "deletion",                                "actn_cashdesk-payments_deletion",                    "object") .
    run add-right in this-procedure ("object", "POS/seller",               "UPDATE",                                  "actn_cashdesk-sellers_update",                       "object") .
    run add-right in this-procedure ("object", "POS/taxes-goods",          "CREATE",                                  "actn_cashdesk-taxg_add-def",                         "object") .
    run add-right in this-procedure ("object", "POS/taxes-goods",          "deletion",                                "actn_cashdesk-taxg_deletion",                        "object") .
    run add-right in this-procedure ("object", "POS/taxes-value",          "CREATE",                                  "actn_cashdesk-taxn_add-def",                         "object") .
    run add-right in this-procedure ("object", "POS/taxes-value",          "deletion",                                "actn_cashdesk-taxn_deletion",                        "object") .
    run add-right in this-procedure ("object", "POS/total-discount",       "CREATE",                                  "actn_cashdesk-discnt-total_add-def",                 "object") .
    run add-right in this-procedure ("object", "POS/total-discount",       "deletion",                                "actn_cashdesk-discnt-total_deletion",                "object") .
    run add-right in this-procedure ("object", "Parts",                    "split-fuse",                              "actn_parts_split-fuse",                              "object") .
    run add-right in this-procedure ("object", "acp",                      "LOOKUP",                                  "actn_income_lookup",                                 "object") .
    run add-right in this-procedure ("object", "acp",                      "add document back date",                  "actn_income_add-back-date",                          "object") .
    run add-right in this-procedure ("object", "acp",                      "add petrol in document back date",        "actn_income_add-ptrl-back-date",                     "object") .
    run add-right in this-procedure ("object", "acp",                      "delete document in status fact",          "actn_income_del-fact",                               "object") .
    run add-right in this-procedure ("object", "acp",                      "delete document on petrol in prev shift", "actn_income_del-ptrl-prev-shft",                     "object") .
    run add-right in this-procedure ("object", "acp",                      "fact",                                    "actn_income_fact",                                   "object") .
    run add-right in this-procedure ("object", "acp",                      "import",                                  "actn_income_import",                                 "object") .
    run add-right in this-procedure ("object", "acp",                      "open",                                    "actn_income_opening",                                "object") .
    run add-right in this-procedure ("object", "acp",                      "open-inquiry",                            "actn_income_opening-inquiry",                        "object") .
    run add-right in this-procedure ("object", "acp",                      "preparation",                             "actn_income_preparation",                            "object") .
    run add-right in this-procedure ("object", "acp",                      "prepownfirmhold",                         "actn_income_prepownfirmhold",                        "object") .
    run add-right in this-procedure ("object", "acp",                      "print",                                   "actn_income_print",                                  "object") .
    run add-right in this-procedure ("object", "on_doc",                   "LOOKUP",                                  "actn_rvs-on-doc_lookup",                             "object") .
    run add-right in this-procedure ("object", "on_doc",                   "cr-revision",                             "actn_rvs-on-doc_cr-revision",                        "object") .
    run add-right in this-procedure ("object", "on_doc",                   "deletion",                                "actn_rvs-on-doc_deletion",                           "object") .
    run add-right in this-procedure ("object", "on_doc",                   "fact",                                    "actn_rvs-on-doc_fact",                               "object") .
    run add-right in this-procedure ("object", "on_doc",                   "print",                                   "actn_rvs-on-doc_print",                              "object") .
    run add-right in this-procedure ("object", "on_doc",                   "upd-revision",                            "actn_rvs-on-doc_upd-revision",                       "object") .
    run add-right in this-procedure ("object", "archive",                  "cost",                                    "actn_archive_cost",                                  "object") .
    run add-right in this-procedure ("object", "cap",                      "preparation",                             "actn_corr-acc-pr-view_preparation",                  "object") .
    run add-right in this-procedure ("object", "client-card",              "payment-deletion",                        "actn_client-cards_payment-deletion",                 "object") .
    run add-right in this-procedure ("object", "client-card",              "payment-input",                           "actn_client-cards_payment-input",                    "object") .
    run add-right in this-procedure ("object", "control",                  "LOOKUP",                                  "actn_rvs-control_lookup",                            "object") .
    run add-right in this-procedure ("object", "control",                  "cr-revision",                             "actn_rvs-control_cr-revision",                       "object") .
    run add-right in this-procedure ("object", "control",                  "delete document in status fact",          "actn_rvs-control_del-fact",                          "object") .
    run add-right in this-procedure ("object", "control",                  "deletion",                                "actn_rvs-control_deletion",                          "object") .
    run add-right in this-procedure ("object", "control",                  "fact",                                    "actn_rvs-control_fact",                              "object") .
    run add-right in this-procedure ("object", "control",                  "print",                                   "actn_rvs-control_print",                             "object") .
    run add-right in this-procedure ("object", "control",                  "upd-revision",                            "actn_rvs-control_upd-revision",                      "object") .
    run add-right in this-procedure ("object", "cre-receipt",              "input",                                   "actn_receipt_input",                                 "object") .
    run add-right in this-procedure ("object", "exp",                      "LOOKUP",                                  "actn_expense_lookup",                                "object") .
    run add-right in this-procedure ("object", "exp",                      "add document back date",                  "actn_expense_add-back-date",                         "object") .
    run add-right in this-procedure ("object", "exp",                      "add petrol in document back date",        "actn_expense_add-ptrl-back-date",                    "object") .
    run add-right in this-procedure ("object", "exp",                      "close expense less acc-price",            "actn_expense_chkslpr",                               "object") .
    run add-right in this-procedure ("object", "exp",                      "delete document in status fact",          "actn_expense_del-fact",                              "object") .
    run add-right in this-procedure ("object", "exp",                      "delete document on petrol in prev shift", "actn_expense_del-ptrl-prev-shft",                    "object") .
    run add-right in this-procedure ("object", "exp",                      "fact",                                    "actn_expense_fact",                                  "object") .
    run add-right in this-procedure ("object", "exp",                      "open",                                    "actn_expense_opening",                               "object") .
    run add-right in this-procedure ("object", "exp",                      "perm-cancellation",                       "actn_expense_perm-cancellation",                     "object") .
    run add-right in this-procedure ("object", "exp",                      "permission",                              "actn_expense_permission",                            "object") .
    run add-right in this-procedure ("object", "exp",                      "preparation",                             "actn_expense_preparation",                           "object") .
    run add-right in this-procedure ("object", "exp",                      "prepownfirmhold",                         "actn_expense_prepownfirmhold",                       "object") .
    run add-right in this-procedure ("object", "exp",                      "price",                                   "actn_expense_price",                                 "object") .
    run add-right in this-procedure ("object", "exp",                      "print",                                   "actn_expense_print",                                 "object") .
    run add-right in this-procedure ("object", "exp",                      "reserv",                                  "actn_expense_rsrv-dtl-action-reserv",                "object") .
    run add-right in this-procedure ("object", "exp",                      "shipping",                                "actn_expense_shipping",                              "object") .
    run add-right in this-procedure ("object", "expense internal",         "delete document in status fact",          "actn_tdedt-ras-perem_del-fact",                      "object") .
    run add-right in this-procedure ("object", "hold_acp",                 "delete document in status fact",          "actn_hold-income_del-fact",                          "object") .
    run add-right in this-procedure ("object", "hold_exp",                 "delete document in status fact",          "actn_hold-expense_del-fact",                         "object") .
    run add-right in this-procedure ("object", "hold_exp",                 "preparation",                             "actn_hold-expense_preparation",                      "object") .
    run add-right in this-procedure ("object", "hold_ret",                 "delete document in status fact",          "actn_hold-return_del-fact",                          "object") .
    run add-right in this-procedure ("object", "inv",                      "LOOKUP",                                  "actn_inventory_lookup",                              "object") .
    run add-right in this-procedure ("object", "inv",                      "delete document in status fact",          "actn_inventory_del-fact",                            "object") .
    run add-right in this-procedure ("object", "inv",                      "fact",                                    "actn_inventory_fact",                                "object") .
    run add-right in this-procedure ("object", "inv",                      "fact-edit",                               "actn_inventory_fact-edit",                           "object") .
    run add-right in this-procedure ("object", "inv",                      "open",                                    "actn_inventory_opening",                             "object") .
    run add-right in this-procedure ("object", "inv",                      "permission",                              "actn_inventory_permission",                          "object") .
    run add-right in this-procedure ("object", "inv",                      "preparation",                             "actn_inventory_preparation",                         "object") .
    run add-right in this-procedure ("object", "inv",                      "print",                                   "actn_inventory_print",                               "object") .
    run add-right in this-procedure ("object", "inv",                      "reserve",                                 "actn_inventory_reserves",                            "object") .
    run add-right in this-procedure ("object", "inv-cnt-pump",             "LOOKUP",                                  "actn_icnt-doc_lookup",                               "object") .
    run add-right in this-procedure ("object", "inv-cnt-pump",             "deletion",                                "actn_icnt-doc_deletion",                             "object") .
    run add-right in this-procedure ("object", "inv-cnt-pump",             "fact",                                    "actn_icnt-doc_fact",                                 "object") .
    run add-right in this-procedure ("object", "inv-cnt-pump",             "preparation",                             "actn_icnt-doc_preparation",                          "object") .
    run add-right in this-procedure ("object", "inv-cnt-pump",             "print",                                   "actn_icnt-doc_print",                                "object") .
    run add-right in this-procedure ("object", "inv-cnt-pump",             "upd-el-cnt",                              "actn_icnt-doc_upd-el-cnt",                           "object") .
    run add-right in this-procedure ("object", "invoice",                  "LOOKUP",                                  "actn_invoice_lookup",                                "object") .
    run add-right in this-procedure ("object", "invoice",                  "UPDATE",                                  "actn_invoice_update",                                "object") .
    run add-right in this-procedure ("object", "invoice",                  "preparation",                             "actn_invoice_preparation",                           "object") .
    run add-right in this-procedure ("object", "invoice",                  "print",                                   "actn_invoice_print",                                 "object") .
    run add-right in this-procedure ("object", "kitchen",                  "work",                                    "actn_fbr-prn-goods_work",                            "object") .
    run add-right in this-procedure ("object", "manufacturing",            "LOOKUP",                                  "actn_manufacturing_lookup",                          "object") .
    run add-right in this-procedure ("object", "manufacturing",            "alternative",                             "actn_manufacturing_alternative",                     "object") .
    run add-right in this-procedure ("object", "manufacturing",            "delete manufactured close in fact",       "actn_manufacturing_del-manuf-fact",                  "object") .
    run add-right in this-procedure ("object", "manufacturing",            "dressing",                                "actn_manufacturing_dressing",                        "object") .
    run add-right in this-procedure ("object", "manufacturing",            "fact",                                    "actn_manufacturing_fact",                            "object") .
    run add-right in this-procedure ("object", "manufacturing",            "free",                                    "actn_manufacturing_free",                            "object") .
    run add-right in this-procedure ("object", "manufacturing",            "free,UPDATE",                             "actn_manufacturing_free-update",                     "object") .
    run add-right in this-procedure ("object", "manufacturing",            "gathering",                               "actn_manufacturing_gathering",                       "object") .
    run add-right in this-procedure ("object", "manufacturing",            "manufacturing",                           "actn_manufacturing_manufacturing",                   "object") .
    run add-right in this-procedure ("object", "manufacturing",            "preparation",                             "actn_manufacturing_preparation",                     "object") .
    run add-right in this-procedure ("object", "manufacturing",            "price-sale-comp",                         "actn_manufacturing_price-sale-comp",                 "object") .
    run add-right in this-procedure ("object", "manufacturing",            "price-sale-ingr",                         "actn_manufacturing_price-sale-ingr",                 "object") .
    run add-right in this-procedure ("object", "manufacturing",            "print",                                   "actn_manufacturing_print",                           "object") .
    run add-right in this-procedure ("object", "object-date",              "UPDATE",                                  "actn_object-date_update",                            "object") .
    run add-right in this-procedure ("object", "off",                      "LOOKUP",                                  "actn_write-off_lookup",                              "object") .
    run add-right in this-procedure ("object", "off",                      "add document back date",                  "actn_write-off_add-back-date",                       "object") .
    run add-right in this-procedure ("object", "off",                      "add petrol in document back date",        "actn_write-off_add-ptrl-back-date",                  "object") .
    run add-right in this-procedure ("object", "off",                      "delete document in status fact",          "actn_write-off_del-fact",                            "object") .
    run add-right in this-procedure ("object", "off",                      "delete document on petrol in prev shift", "actn_write-off_del-ptrl-prev-shft",                  "object") .
    run add-right in this-procedure ("object", "off",                      "fact",                                    "actn_write-off_fact",                                "object") .
    run add-right in this-procedure ("object", "off",                      "open",                                    "actn_write-off_opening",                             "object") .
    run add-right in this-procedure ("object", "off",                      "perm-cancellation",                       "actn_write-off_perm-cancellation",                   "object") .
    run add-right in this-procedure ("object", "off",                      "permission",                              "actn_write-off_permission",                          "object") .
    run add-right in this-procedure ("object", "off",                      "preparation",                             "actn_write-off_preparation",                         "object") .
    run add-right in this-procedure ("object", "off",                      "price",                                   "actn_write-off_price",                               "object") .
    run add-right in this-procedure ("object", "off",                      "print",                                   "actn_write-off_print",                               "object") .
    run add-right in this-procedure ("object", "off",                      "reserv",                                  "actn_write-off_rsrv-dtl-action-reserv",              "object") .
    run add-right in this-procedure ("object", "off",                      "shipping",                                "actn_write-off_shipping",                            "object") .
    run add-right in this-procedure ("object", "order",                    "CREATE",                                  "actn_pmnt-ord-doc_add-def",                          "object") .
    run add-right in this-procedure ("object", "order",                    "LOOKUP cmm order LOOKUP",                 "actn_pmnt-ord-doc_lookup",                           "object") .
    run add-right in this-procedure ("object", "order",                    "UPDATE",                                  "actn_pmnt-ord-doc_update",                           "object") .
    run add-right in this-procedure ("object", "order",                    "deletion",                                "actn_pmnt-ord-doc_deletion",                         "object") .
    run add-right in this-procedure ("object", "overvalue",                "LOOKUP",                                  "actn_overvalue_lookup",                              "object") .
    run add-right in this-procedure ("object", "overvalue",                "UPDATE",                                  "actn_overvalue_update",                              "object") .
    run add-right in this-procedure ("object", "overvalue",                "discount",                                "actn_overvalue_discount",                            "object") .
    run add-right in this-procedure ("object", "overvalue",                "fact",                                    "actn_overvalue_fact",                                "object") .
    run add-right in this-procedure ("object", "overvalue",                "order",                                   "actn_overvalue_order",                               "object") .
    run add-right in this-procedure ("object", "overvalue",                "permission",                              "actn_overvalue_permission",                          "object") .
    run add-right in this-procedure ("object", "overvalue",                "preparation",                             "actn_overvalue_preparation",                         "object") .
    run add-right in this-procedure ("object", "overvalue",                "print",                                   "actn_overvalue_print",                               "object") .
    run add-right in this-procedure ("object", "overvalue",                "properties",                              "actn_overvalue_properties",                          "object") .
    run add-right in this-procedure ("object", "period",                   "inquiry",                                 "actn_period_inquires",                               "object") .
    run add-right in this-procedure ("object", "period",                   "reserve",                                 "actn_period_reserves",                               "object") .
    run add-right in this-procedure ("object", "place-io-reference",       "CREATE",                                  "actn_place-io-reference_add-def",                    "object") .
    run add-right in this-procedure ("object", "place-io-reference",       "UPDATE",                                  "actn_place-io-reference_update",                     "object") .
    run add-right in this-procedure ("object", "place-io-reference",       "deletion",                                "actn_place-io-reference_deletion",                   "object") .
    run add-right in this-procedure ("object", "place-reference",          "work",                                    "actn_place-reference_work",                          "global") .
    run add-right in this-procedure ("object", "plgdspm-sts",              "work",                                    "actn_plgdspm-sts_work",                              "object") .
    run add-right in this-procedure ("object", "point-io-reference",       "CREATE",                                  "actn_point-io-reference_add-def",                    "global") .
    run add-right in this-procedure ("object", "point-io-reference",       "UPDATE",                                  "actn_point-io-reference_update",                     "global") .
    run add-right in this-procedure ("object", "point-io-reference",       "deletion",                                "actn_point-io-reference_deletion",                   "global") .
    run add-right in this-procedure ("object", "pump-reference",           "work",                                    "actn_pump-reference_work",                           "object") .
    run add-right in this-procedure ("object", "reciev",                   "CREATE",                                  "actn_ord-rcv_add-def",                               "object") .
    run add-right in this-procedure ("object", "reciev",                   "LOOKUP cmm reciev LOOKUP",                "actn_ord-rcv_lookup",                                "object") .
    run add-right in this-procedure ("object", "reciev",                   "UPDATE",                                  "actn_ord-rcv_update",                                "object") .
    run add-right in this-procedure ("object", "reciev",                   "deletion",                                "actn_ord-rcv_deletion",                              "object") .
    run add-right in this-procedure ("object", "reciev",                   "waybill",                                 "actn_ord-rcv_h-wbill",                               "object") .
    run add-right in this-procedure ("object", "report",                   "lookup-price-cost",                       "actn_reports_lookup-cost",                           "object") .
    run add-right in this-procedure ("object", "report",                   "lookup-price-crsa",                       "actn_reports_lookup-crsa",                           "object") .
    run add-right in this-procedure ("object", "report",                   "lookup-price-mediatr",                    "actn_reports_lookup-medi",                           "object") .
    run add-right in this-procedure ("object", "report",                   "lookup-price-sale",                       "actn_reports_lookup-sale",                           "object") .
    run add-right in this-procedure ("object", "report",                   "report-benet1",                           "actn_reports_report-benet1",                         "object") .
    run add-right in this-procedure ("object", "report",                   "report-benet2",                           "actn_reports_report-benet2",                         "object") .
    run add-right in this-procedure ("object", "report",                   "report-benet3",                           "actn_reports_report-benet3",                         "object") .
    run add-right in this-procedure ("object", "report",                   "report-benet4",                           "actn_reports_report-benet4",                         "object") .
    run add-right in this-procedure ("object", "report",                   "report-benet5",                           "actn_reports_report-benet5",                         "object") .
    run add-right in this-procedure ("object", "report",                   "report-benet6",                           "actn_reports_report-benet6",                         "object") .
    run add-right in this-procedure ("object", "ret",                      "LOOKUP",                                  "actn_return_lookup",                                 "object") .
    run add-right in this-procedure ("object", "ret",                      "add document back date",                  "actn_return_add-back-date",                          "object") .
    run add-right in this-procedure ("object", "ret",                      "add petrol in document back date",        "actn_return_add-ptrl-back-date",                     "object") .
    run add-right in this-procedure ("object", "ret",                      "delete document in status fact",          "actn_return_del-fact",                               "object") .
    run add-right in this-procedure ("object", "ret",                      "delete document on petrol in prev shift", "actn_return_del-ptrl-prev-shft",                     "object") .
    run add-right in this-procedure ("object", "ret",                      "fact",                                    "actn_return_fact",                                   "object") .
    run add-right in this-procedure ("object", "ret",                      "open",                                    "actn_return_opening",                                "object") .
    run add-right in this-procedure ("object", "ret",                      "perm-cancellation",                       "actn_return_perm-cancellation",                      "object") .
    run add-right in this-procedure ("object", "ret",                      "permission",                              "actn_return_permission",                             "object") .
    run add-right in this-procedure ("object", "ret",                      "preparation",                             "actn_return_preparation",                            "object") .
    run add-right in this-procedure ("object", "ret",                      "prepownfirmhold",                         "actn_return_prepownfirmhold",                        "object") .
    run add-right in this-procedure ("object", "ret",                      "price",                                   "actn_return_price",                                  "object") .
    run add-right in this-procedure ("object", "ret",                      "print",                                   "actn_return_print",                                  "object") .
    run add-right in this-procedure ("object", "ret",                      "reserv",                                  "actn_return_rsrv-dtl-action-reserv",                 "object") .
    run add-right in this-procedure ("object", "sale",                     "LOOKUP",                                  "actn_sale_lookup",                                   "object") .
    run add-right in this-procedure ("object", "sale",                     "delete sale in status fact",              "actn_sale_del-sale-fact",                            "object") .
    run add-right in this-procedure ("object", "sale",                     "fact",                                    "actn_sale_fact",                                     "object") .
    run add-right in this-procedure ("object", "scales",                   "POS/send",                                "actn_scales_sending",                                "global") .
    run add-right in this-procedure ("object", "scales",                   "UPDATE",                                  "actn_scales_update",                                 "global") .
    run add-right in this-procedure ("object", "shift",                    "LOOKUP",                                  "actn_rvs-shift_lookup",                              "object") .
    run add-right in this-procedure ("object", "shift",                    "cr-revision",                             "actn_rvs-shift_cr-revision",                         "object") .
    run add-right in this-procedure ("object", "shift",                    "deletion",                                "actn_rvs-shift_deletion",                            "object") .
    run add-right in this-procedure ("object", "shift",                    "fact",                                    "actn_rvs-shift_fact",                                "object") .
    run add-right in this-procedure ("object", "shift",                    "print",                                   "actn_rvs-shift_print",                               "object") .
    run add-right in this-procedure ("object", "shift",                    "regular-mode",                            "actn_shift_regular",                                 "object") .
    run add-right in this-procedure ("object", "shift",                    "supervisor",                              "actn_shift_super",                                   "object") .
    run add-right in this-procedure ("object", "shift",                    "upd-revision",                            "actn_rvs-shift_upd-revision",                        "object") .
    run add-right in this-procedure ("object", "tax-rate-values",          "UPDATE",                                  "actn_tax-rate-values_update",                        "object") .
    run add-right in this-procedure ("object", "wealth moving document",   "CREATE",                                  "actn_wth-doc_add-def",                               "object") .
    run add-right in this-procedure ("object", "wealth moving document",   "LOOKUP",                                  "actn_wth-doc_lookup",                                "object") .
    run add-right in this-procedure ("object", "wealth moving document",   "UPDATE",                                  "actn_wth-doc_update",                                "object") .
    run add-right in this-procedure ("object", "wealth moving document",   "delete document in status fact",          "actn_wth-doc_del-fact",                              "object") .
    run add-right in this-procedure ("object", "wealth moving document",   "deletion",                                "actn_wth-doc_deletion",                              "object") .
    run add-right in this-procedure ("object", "wealth moving document",   "print",                                   "actn_wth-doc_print",                                 "object") .
    run add-right in this-procedure ("object", "weight-code-on-object",    "UPDATE",                                  "actn_object-weight-code_update",                     "object") .
    run add-right in this-procedure ("object", "wth-place-reference",      "work",                                    "actn_wth-place-reference_work",                      "object") .
    run add-right in this-procedure ("object", "wth-receipt",              "input",                                   "actn_wth-receipt_input",                             "object") .
    run add-right in this-procedure ("off",    "client-group",             "discount",                                "actn_clients-group_discount",                        "global") .
    run add-right in this-procedure ("off",    "country-reference",        "work",                                    "actn_country-reference_work",                        "global") .
    run add-right in this-procedure ("off",    "currency-reference",       "work",                                    "actn_currency-reference_work",                       "global") .
    run add-right in this-procedure ("off",    "fin-liability",            "LOOKUP",                                  "actn_fin-liability_lookup",                          "firm") .
    run add-right in this-procedure ("off",    "payment",                  "UPDATE",                                  "actn_payments_update",                               "global") .
    run add-right in this-procedure ("off",    "payment-type",             "preparation",                             "actn_payments-types_input-deletion-updating",        "global") .
    run add-right in this-procedure ("off",    "payments-expected",        "work",                                    "actn_payments-expected_work",                        "firm") .
    run add-right in this-procedure ("off",    "purchase-book",            "print",                                   "actn_purchase-book_print",                           "firm") .
    run add-right in this-procedure ("off",    "reference",                "group-edit",                              "actn_reference_groups-edit",                         "global") .
    run add-right in this-procedure ("off",    "report",                   "print",                                   "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("off",    "sale-book",                "print",                                   "actn_sales-book_print",                              "firm") .
    run add-right in this-procedure ("off",    "scale",                    "UPDATE",                                  "actn_scale_update",                                  "global") .
    run add-right in this-procedure ("off",    "wealth",                   "work",                                    "actn_wealth_work",                                   "global") .
    run add-right in this-procedure ("res",    "POS/restaurant",           "work",                                    "actn_cashdesk-restaurant_work",                      "firm") .
    run add-right in this-procedure ("res",    "report",                   "print",                                   "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("res",    "res-autofbr",              "work",                                    "actn_res-autofbr_work",                              "firm") .
    run add-right in this-procedure ("res",    "res-pln-menu",             "LOOKUP",                                  "actn_res-pln-menu_lookup",                           "firm") .
    run add-right in this-procedure ("res",    "res-pln-menu",             "UPDATE",                                  "actn_res-pln-menu_update",                           "firm") .
    run add-right in this-procedure ("res",    "res-print",                "print",                                   "actn_res-print_print",                               "firm") .
    run add-right in this-procedure ("res",    "res-reference",            "LOOKUP",                                  "actn_res-reference_lookup",                          "firm") .
    run add-right in this-procedure ("res",    "res-reference",            "UPDATE",                                  "actn_res-reference_update",                          "firm") .
    run add-right in this-procedure ("shp",    "report",                   "print",                                   "actn_reports_print",                                 "firm") .
    run add-right in this-procedure ("str",    "composition-print",        "print",                                   "actn_composition-print_print",                       "firm") .
    run add-right in this-procedure ("str",    "composition-reprint",      "print",                                   "actn_composition-reprint_print",                     "firm") .
    run add-right in this-procedure ("str",    "report",                   "print",                                   "actn_reports_print",                                 "firm") .
  end.
end procedure. /* fill-right-eng */