block-level on error undo, throw.
/*

$Revision: 00d8465b63c9, 1823, rls $
$Author: SMMolotkov $
$Date: Wed Apr 03 10:04:52 2019 +0300 $
$Workfile: impxexpi.p $
$Archive: utl/impxexpi.p $

Процедура импорта локальных таблиц УБД
запускается как обычная утилита из системы
на момент запуска в БД уже должны завершиться все утилиты закачки баркодов и конфигурации

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

define variable vss-revision    as character no-undo init "$Revision: 00d8465b63c9, 1823, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Wed Apr 03 10:04:52 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: impxexpi.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/impxexpi.p $":U .
define variable vss-description as character no-undo init "Процедура экспорта локальных таблиц УБД".
{ cmp/vssrevis.i }

define variable p-rht  as logical no-undo .
define variable p-gen  as logical no-undo .
define variable p-flt  as logical no-undo .
define variable p-pbc  as logical no-undo .
define variable p-scl  as logical no-undo .
define variable p-usr  as logical no-undo .
define variable p-seq  as logical no-undo .
define variable p-cdrg as logical no-undo .
define variable p-cdk as logical no-undo .
define variable p-thb as logical no-undo .
define variable p-pet as logical no-undo .
/*ключ БАЗЫ - он же имя файла без расширения*/
define variable p-db-key as character no-undo .
/*директория экспорта*/
define variable p-dir-name as character no-undo .
define variable p-version as character no-undo .
define variable p-glb as logical no-undo .
define variable p-old-host-code as integer no-undo .
define variable p-new-host-code as integer no-undo .
define variable p-old-obj-type as character no-undo .
define variable p-new-obj-type as character no-undo .
define variable p-old-obj-code as integer no-undo .
define variable p-new-obj-code as integer no-undo .
define variable p-from-version as character no-undo .
define variable v-rid as recid no-undo .

{ cmp/trg-def.i }
{ cmp/operfile.i }
define variable log-file-name as character no-undo init "imp-exp.log".
define variable v-view-log as logical no-undo .

{ utl/imp-expd.i }
{ utl/imp-expc.i }
{ cmp/getmcode.i ub }
{ trg/new-bcod.i }
{ ref/gdsoattr.i }
{ ref/extclass.i }
{ gbl/key-rec.i }
{ gbl/cd-attr.i }
{ cmp/thth150.i }
{ cmp/thth14.i }

&scop need-thbj-attr-list ~
"{&bef-attr-autosale},{&bef-attr-get-chk},{&bef-attr-chk-view},{&bef-attr-cd-sending},{&bef-attr-cd-inf-send}," + ~
"{&bef-attr-scale-inf},{&bef-attr-cd-type-ibm},{&bef-attr-abc-sale-day},{&bef-attr-abc-global}," + ~
"{&bef-attr-ord-global},{&bef-attr-ord-obj},{&bef-attr-fin-global},{&bef-attr-contr-in},{&bef-attr-nakl_par}," + ~
"{&bef-attr-rt-trn-doc},{&bef-attr-gds-ref},{&bef-attr-gds-ref_obj},{&bef-attr-cli-all}," + ~
"{&bef-attr-auto-task},{&bef-attr-ass-obj}"

/*не вошли {&attr-alias-tpsi}, attr-prt-glob типы касс не IBM attr-rum  {&attr-cashpays} {&attr-wthdoc} {&attr-wthrep}*/


/*определяем два набора временных таблиц  чтобы смочь закачать даже дубли*/
/*проверять будем на втором этапе - перекачки из temp-table в БД*/

define temp-table temp-sys-ctrl  NO-UNDO LIKE ub.sys-ctrl.
define temp-table temp-code-range NO-UNDO LIKE ub.code-range.
define temp-table temp-config  NO-UNDO LIKE ub.config.
define temp-table temp-thbj-attr  NO-UNDO LIKE ub.thbj-attr.
define temp-table temp-prod-bc no-undo LIKE ub.prod-bc
field old-gds-code like ub.goods.gds-code
field unit-base like ub.goods.unit-base
field unit-cli like ub.bar-code.unit-cli
field gds-code like ub.goods.gds-code
.
define temp-table temp-gds-obj-attr no-undo LIKE ub.gds-obj-attr.
define temp-table temp-scales  NO-UNDO LIKE ub.scales.
define temp-table temp-scales-gds  NO-UNDO LIKE ub.scales-gds
field old-gds-code like ub.goods.gds-code
.
define temp-table temp-scales-grp  NO-UNDO LIKE ub.scales-grp.
define temp-table temp-filter  NO-UNDO LIKE ubflt.filter.
define temp-table temp-cash-desk  NO-UNDO LIKE ub.cash-desk
.
define temp-table temp-place  NO-UNDO LIKE ub.place.
define temp-table temp-pl-gds  NO-UNDO LIKE ub.pl-gds.
define temp-table temp-pl-gds-pump  NO-UNDO LIKE ub.pl-gds-pump.
define temp-table temp-pl-pump  NO-UNDO LIKE ub.pl-pump.
define temp-table temp-pl-pump-nozzle  NO-UNDO LIKE ub.pl-pump-nozzle.
define temp-table temp-pump  NO-UNDO LIKE ub.pump.
define temp-table temp-nozzle  NO-UNDO LIKE ub.nozzle.
define temp-table temp-pump-nozzle  NO-UNDO LIKE ub.pump-nozzle.

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
define temp-table buf-code-range  NO-UNDO LIKE ub.code-range.
define temp-table buf-config  NO-UNDO LIKE ub.config.
define temp-table buf-thbj-attr  NO-UNDO LIKE ub.thbj-attr.
define temp-table buf-prod-bc no-undo LIKE ub.prod-bc
field old-gds-code like ub.goods.gds-code
field unit-base like ub.goods.unit-base
field unit-cli like ub.bar-code.unit-cli
.
define temp-table buf-gds-obj-attr no-undo LIKE ub.gds-obj-attr.
define temp-table buf-scales  NO-UNDO LIKE ub.scales.
define temp-table buf-scales-gds  NO-UNDO LIKE ub.scales-gds
field old-gds-code like ub.goods.gds-code
.
define temp-table buf-scales-grp  NO-UNDO LIKE ub.scales-grp.
define temp-table buf-filter  NO-UNDO LIKE ubflt.filter.
define temp-table buf-cash-desk  NO-UNDO LIKE ub.cash-desk.
define temp-table buf-curr-shop  NO-UNDO LIKE ub.curr-shop.
define temp-table buf-place no-undo like ub.place.
define temp-table buf-pump no-undo like ub.pump.
define temp-table buf-nozzle no-undo like ub.nozzle.
define temp-table buf-pl-gds no-undo like ub.pl-gds.
define temp-table buf-pl-gds-pump no-undo like ub.pl-gds-pump.
define temp-table buf-pl-pump no-undo like ub.pl-pump.
define temp-table buf-pl-pump-nozzle no-undo like ub.pl-pump-nozzle.
define temp-table buf-pump-nozzle no-undo like ub.pump-nozzle.

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
define variable v-is-petrolium as logical no-undo .
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
define variable v-mode as character no-undo .
define variable v-classif-name as character no-undo .
define variable v-cli-classif-name as character no-undo .

define buffer cli_units for ub.units.
define buffer buf_code-range for ub.code-range.
define buffer buf_config for ub.config.
define buffer ext_config for ub.config.
define buffer ext_thbj-attr for ub.thbj-attr.
define buffer buf_thbj-attr for ub.thbj-attr.

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
p-rht  = logical(entry({&ie-rht} , p-parameter, {&delim-par}))
p-gen  = logical(entry({&ie-gen} , p-parameter, {&delim-par}))
p-flt  = logical(entry({&ie-flt} , p-parameter, {&delim-par}))
p-pbc  = logical(entry({&ie-pbc} , p-parameter, {&delim-par}))
p-scl  = logical(entry({&ie-scl} , p-parameter, {&delim-par}))
p-usr  = logical(entry({&ie-usr} , p-parameter, {&delim-par}))
p-seq  = logical(entry({&ie-seq} , p-parameter, {&delim-par}))
p-cdrg = logical(entry({&ie-cdrg}, p-parameter, {&delim-par}))
p-cdk = logical(entry({&ie-cdk}, p-parameter, {&delim-par}))
p-thb = logical(entry({&ie-thb}, p-parameter, {&delim-par}))
p-pet = logical(entry({&ie-pet}, p-parameter, {&delim-par}))
/*ключ БАЗЫ - он же имя файла без расширения*/
p-db-key = entry(12, p-parameter, {&delim-par})
/*директория экспорта*/
p-dir-name  = entry(13, p-parameter, {&delim-par})
p-glb       = logical(entry(14, p-parameter, {&delim-par}))
p-version   = entry(15, p-parameter, {&delim-par})
p-old-host-code = integer(entry(16, p-parameter, {&delim-par}))
p-new-host-code = integer(entry(17, p-parameter, {&delim-par}))
p-old-obj-type  = entry(18, p-parameter, {&delim-par})
p-new-obj-type  = entry(19, p-parameter, {&delim-par})
p-old-obj-code  = integer(entry(20, p-parameter, {&delim-par}))
p-new-obj-code  = integer(entry(21, p-parameter, {&delim-par}))
p-from-version = entry(22, p-parameter, {&delim-par})
no-error
.
if error-status:error then return error substitute("&1 &2", error-status:get-message(1) , return-value ).

case p-from-version:
  when {&thth150-from-version} then do:
    v-classif-name = {&extclass_goods_th-th150}.
    v-cli-classif-name = {&extclass_goods_th-th150}.

  end.
  when {&thth14-from-version} then do:
    v-classif-name = {&extclass_goods_th-th14}.
    v-cli-classif-name = {&extclass_goods_th-th14}.
  end.
  otherwise do:
    message
    substitute("Неверное значение параметра p-from-version=&1", p-from-version)
    view-as alert-box error .
    undo, return error .
  end.
end case. /*case p-from-version:*/

define buffer buf_clients for ub.clients.
find first buf_clients no-lock where
          buf_clients.obj-type = p-new-obj-type
     and  buf_clients.obj-code = p-new-obj-code no-error.
if not available buf_clients then do:
  message
  substitute("Не найден объект &1&2 указанный как НОВЫЙ", p-new-obj-type, p-new-obj-code)
  view-as alert-box error .
  return .
end.
if buf_clients.db-num <> g#db-num then do:
  message
  substitute("Импорт локальных данных возможен только в БД объекта &1&2 указанного как НОВЫЙ", p-new-obj-type, p-new-obj-code)
  view-as alert-box error .
  return .
end.

&scop err-mes " Импорт локальных таблиц"
{&wl}

if p-gen then do:
  run p-gen-i in this-procedure .
end.
if p-cdrg then do:
  run p-cdrg-i in this-procedure .
end.
if p-thb then do:
  run p-thb-i in this-procedure.
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
if p-cdk then do:
  run p-cdk-i in this-procedure.
end.
if p-rht then do:
  run p-rht-i in this-procedure .
end.
if p-usr then do:
   /*
   if (not p-rht)
   and (not (p-version = "15.0")) then do:
      run p-rht-i in this-procedure .
   end.
   */
   run p-usr-i in this-procedure .
end.


{&ii0}


if p-gen then do:
  &scop current-data-group "gen":U
  &scop wait-mess "Проверка группы данных ИНФОРМАЦИЯ О БД (НАСТРОЙКИ)"
  &scop err-mes0 "Проверка группы данных ИНФОРМАЦИЯ О БД (НАСТРОЙКИ)" + ~{&new-line~}
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
if p-thb then do:
  &scop current-data-group "thb":U
  &scop wait-mess "Проверка группы данных ПАРАМЕТРЫ"
  &scop err-mes0 "Проверка группы данных ПАРАМЕТРЫ" + ~{&new-line~}
  {&waitc}
  &scop next-line _thbj-attrv
  &scop table-name temp-thbj-attr
  _thbj-attrv:
  FOR EACH temp-thbj-attr:
    if temp-thbj-attr.obj-type <> "" or temp-thbj-attr.obj-code > 0 then do:
      FIND FIRST ub.clients No-LOCK WHERE
                ub.clients.obj-type = temp-thbj-attr.obj-type AND
                ub.clients.obj-code = temp-thbj-attr.obj-code NO-ERROR.
      IF NOT AVAIL ub.clients then do:
          &scop err-mes (~{&err-mes0~} + " Отсутствует объект для НАСТРОЕЧНОГО ПАРАМЕТРА(thbj-attr)" + ~
                                         " секция " + temp-thbj-attr.upper-prop-code + ~
                                          " параметр " + temp-thbj-attr.prop-code + ~
                                          " тип объекта " + temp-thbj-attr.obj-type + ~
                                          " код объекта " + string(temp-thbj-attr.obj-code) )
          {&wl-mes}
      END.
      IF (ub.clients.obj-type = {&shop}
      or ub.clients.obj-type = {&stock})
      and ub.clients.db-num <> ub.db.db-num then do:
          &scop err-mes (~{&err-mes0~} + " Объект для НАСТРОЕЧНОГО ПАРАМЕТРА(thbj-attr) принадлежит другой БД" + ~
                                         " секция " + temp-thbj-attr.upper-prop-code + ~
                                          " параметр " + temp-thbj-attr.prop-code + ~
                                          " тип объекта " + temp-thbj-attr.obj-type + ~
                                          " код объекта " + string(temp-thbj-attr.obj-code) )
          {&wl-mes}
      END.
    end.
    FIND FIRST buf_thbj-attr WHERE
              buf_thbj-attr.prop-code = temp-thbj-attr.prop-code AND
              buf_thbj-attr.upper-prop-code = temp-thbj-attr.upper-prop-code AND
              buf_thbj-attr.obj-type = temp-thbj-attr.obj-type AND
              buf_thbj-attr.obj-code = temp-thbj-attr.obj-code
    NO-ERROR.
    if not available buf_thbj-attr then do:
      create buf_thbj-attr.
      assign
      buf_thbj-attr.upper-prop-code = temp-thbj-attr.upper-prop-code
      buf_thbj-attr.prop-code = temp-thbj-attr.prop-code
      buf_thbj-attr.obj-type = temp-thbj-attr.obj-type
      buf_thbj-attr.obj-code = temp-thbj-attr.obj-code
      buf_thbj-attr.prop-value-type = temp-thbj-attr.prop-value-type
      .
    end.
    assign
    buf_thbj-attr.property-value-character = temp-thbj-attr.property-value-character
    buf_thbj-attr.property-value-date = temp-thbj-attr.property-value-date
    buf_thbj-attr.property-value-decimal = temp-thbj-attr.property-value-decimal
    buf_thbj-attr.property-value-integer = temp-thbj-attr.property-value-integer
    buf_thbj-attr.property-value-logical = temp-thbj-attr.property-value-logical
    .
    release buf_thbj-attr no-error.


    if error-status:error then do:
      {&get-mes}
      &scop err-mes (~{&err-mes0~} +  " ошибка при сохранении НАСТРОЕЧНОГО ПАРАМЕТРA(thbj-attr):" + ~
                                      " параметр " + temp-thbj-attr.prop-code + ~
                                      " тип объекта " + temp-thbj-attr.obj-type + ~
                                      " код объекта " + string(temp-thbj-attr.obj-code) + ~
                                      er-mes)
      {&undo-mes}
    end.
  END.
end.


if p-cdrg then do:
  find first ub.sys-ctrl no-lock .
  if ub.sys-ctrl.db-num = 0 then do:
    &scop current-data-group "cdr":U
    &scop wait-mess "Проверка группы данных ДИАПАЗОНЫ ВЕСОВЫХ КОДОВ"
    &scop err-mes0 "Проверка группы данных ДИАПАЗОНЫ ВЕСОВЫХ КОДОВ" + ~{&new-line~}
    {&waitc}
    &scop next-line _code-rg
    &scop table-name temp-code-range
    find first temp-code-range no-lock
      where temp-code-range.range-type = {&loc-sc-code}
         or temp-code-range.range-type = {&gbl-sc-code}
         or temp-code-range.range-type = {&loc-pg-code}
      no-error .
    if available temp-code-range then do:
      on delete of ub.code-range override do: end.
      for each ub.code-range exclusive-lock
        where ub.code-range.range-type = {&loc-sc-code}
           or ub.code-range.range-type = {&gbl-sc-code}
           or ub.code-range.range-type = {&loc-pg-code}
      on error  undo, retry
      on stop   undo, retry
      on endkey undo, retry
      :
        if retry then do:
          &scop err-mes (~{&err-mes0~} + " Ошибка при удалении диапазонов кодов (code-range)" )
          {&wl}
        end.
        delete ub.code-range .
      end.
      _code-rg:
      FOR EACH temp-code-range NO-LOCK
        where temp-code-range.range-type = {&loc-sc-code}
           or temp-code-range.range-type = {&gbl-sc-code}
           or temp-code-range.range-type = {&loc-pg-code}
      :
        create ub.code-range.
        buffer-copy temp-code-range to ub.code-range.
        release ub.code-range no-error.
        if error-status:error then do:
          {&get-mes}
          &scop err-mes (~{&err-mes0~} + " ошибка при сохранении записи ДИАПАЗОН КОДОВ (code-range):" + ~
                          " тип " + temp-code-range.range-type + ~
                          " начало " + string(temp-code-range.first-code) + ~
                          " окончание " + string(temp-code-range.last-code) + ~
                          er-mes)
          {&undo-mes}
        end.
      END.
    end.
    else do:
      &scop err-mes (~{&err-mes0~} + " в файле импорта нет ни одной записи типа ДИАПАЗОН КОДОВ (code-range)" )
      {&wl}
    end.
  end.
  else do:
    &scop err-mes (~{&err-mes0~} + " импорт записей типа ДИАПАЗОН КОДОВ (code-range) разрешен только в ГБД" )
    {&wl}
  end.
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

    create alias restseq    for database value( ldbname( "ub":U ) ) .
    create alias restseqflt for database value( ldbname( "ubflt":U ) ) .
    run adm/restseq.p
      ( input "rest":U
       ,input "next-num-filter":U
       ,input no
      ) no-error .
    if error-status :error then do:
      delete alias restseqflt.
      delete alias restseq.
      return error return-value .
    end.
    delete alias restseqflt.
    delete alias restseq.

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
    v-is-petrolium = no
    .
    FIND FIRST ub.prod-bc No-LOCK WHERE
               ub.prod-bc.b-str = temp-prod-bc.b-str
          AND  ub.prod-bc.b-code = temp-prod-bc.b-code NO-ERROR.
    IF AVAILABLE ub.prod-bc then do:
        &scop err-mes (~{&err-mes0~} + " Уже есть ДопБК(prod-bc):" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Баркод " + string(temp-prod-bc.b-code))
        {&wl-mes}
    end.
    find first ub.prod-bc no-lock where
              ub.prod-bc.b-str = temp-prod-bc.b-str
          AND ub.prod-bc.bc-on = yes no-error.
    IF AVAILABLE ub.prod-bc then do:
        &scop err-mes (~{&err-mes0~} + " Уже есть такой включенный ДопБК(prod-bc) на другом товаре:" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Баркод имеющегося включенного ДопБК" + string(ub.prod-bc.b-code))
        {&wl-mes}
    end.

    find first ub.bar-code no-lock where
               ub.bar-code.b-code = temp-prod-bc.b-code no-error.
    if not avail ub.bar-code then do:
        &scop err-mes (~{&err-mes0~} + " Не найден баркод для ДопБК(prod-bc):" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Баркод " + string(temp-prod-bc.b-code))
        {&wl-mes}
    end.
    FIND FIRST ub.goods no-lock where
              ub.goods.gds-code = ub.bar-code.gds-code  NO-ERROR.
    if not avail ub.bar-code then do:
        &scop err-mes (~{&err-mes0~} + " Не найден товар по баркоду для ДопБК(prod-bc):" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Баркод " + string(temp-prod-bc.b-code))
        {&wl-mes}
    end.
    find first ub.units no-lock where
               ub.units.unit-name = ub.goods.unit-base no-error .
    if not avail ub.units then do:
        &scop err-mes (~{&err-mes0~} + " Не найдена основная ед. изм товара для ДопБК(prod-bc):" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Баркод " + string(temp-prod-bc.b-code) + ~
                        " Товар " + ub.goods.artic + ~{&space-char} + ub.goods.prod-type + string(ub.goods.prod-code))
        {&wl-mes}
    end.
    if LOOKUP({&weight}, ub.units.type) = 0
    and LOOKUP({&petrolium}, ub.units.type) = 0
    and not (LOOKUP({&pieces}, ub.units.type) > 0
        and can-find(first ub.code-range no-lock where
                            ub.code-range.db-num = 0
                        and ub.code-range.range-type = {&loc-pg-code}
                        and ub.code-range.first-code <= integer(temp-prod-bc.b-str)
                        and ub.code-range.last-code >= integer(temp-prod-bc.b-str)))
    then do:
        &scop err-mes (~{&err-mes0~} + " Товар по ДопБК(prod-bc) НЕ ((весовой или штучный) и ДопБК - код для весов):" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Баркод " + string(temp-prod-bc.b-code) + ~
                        " Товар " + ub.goods.artic + ~{&space-char} + ub.goods.prod-type + string(ub.goods.prod-code) + ~
                        " Основн. ед. изм" + ub.goods.unit-base)
        {&wl-mes}
    end.
    if ub.bar-code.unit-cli = ub.goods.unit-base then do:
      /*весовой код*/
      /*убедимся что это основной баркод*/
      { gbl/gdsbcode.i ub.goods.gds-code ? r-bar-code no-error }
      if error-status:error then do:
        &scop err-mes (~{&err-mes0~} + " Ошибка при поиске основного баркода товара для ДопБК(prod-bc):" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Баркод " + string(temp-prod-bc.b-code))
        {&wl-mes}
      end.
      if r-bar-code <> ub.bar-code.b-code then do:
        &scop err-mes (~{&err-mes0~} + " Баркод для ДопБК(prod-bc) не является основным баркодом товара:" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Баркод " + string(temp-prod-bc.b-code))
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
                        " Баркод " + string(temp-prod-bc.b-code))
        {&wl-mes}
      end.
      if v-is-global
      and not p-glb
      then do:
        &scop err-mes (~{&err-mes0~} + " ДопБК(prod-bc) не локальный:" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Баркод " + string(temp-prod-bc.b-code))
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
                        " Баркод " + string(temp-prod-bc.b-code))
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
                        " Баркод " + string(temp-prod-bc.b-code))
        {&wl-mes}
      end.
      { gbl/prodbctv.i
        temp-prod-bc.b-str
        ub.bar-code.unit-cli
        ub.goods.unit-base
        'petrolium=request':U
        v-is-petrolium
        no-error
      }
      if error-status:error then do:
        &scop err-mes (~{&err-mes0~} + " Ошибка при проверке на топливность ДопБК(prod-bc):" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Баркод " + string(temp-prod-bc.b-code))
        {&wl-mes}
      end.
      if not v-is-weight
      and not v-is-pgweight
      and not v-is-petrolium
      then do:
        &scop err-mes (~{&err-mes0~} + " ДопБК(prod-bc) не код для весов:" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Баркод " + string(temp-prod-bc.b-code))
        {&wl-mes}
      end.
      if v-is-weight then do:
        v-cdrg-type = {&loc-sc-code}.
      end.
      else do:
        if v-is-petrolium then do:
          v-cdrg-type = {&loc-pt-code}.
        end.
        else do:
          v-cdrg-type = {&loc-pg-code}.
        end.
      end.
    end.
    else do:
      /*взвешиваемый*/
      find first cli_units no-lock where
                cli_units.unit-name = ub.bar-code.unit-cli no-error .
      if not avail cli_units then do:
          &scop err-mes (~{&err-mes0~} + " Не найдена ед. изм баркода для ДопБК(prod-bc):" + ~
                          " ДопБК " + string(temp-prod-bc.b-str) + ~
                          " Баркод " + string(temp-prod-bc.b-code) + ~
                          " Ед.изм.баркода "  + ub.bar-code.unit-cli)
          {&wl-mes}
      end.
      if LOOKUP({&divisional}, cli_units.type) = 0 then do:
        &scop err-mes (~{&err-mes0~} + " Единица измерения баркода по ДопБК(prod-bc) не весовая и не дробная:" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Баркод " + string(temp-prod-bc.b-code) + ~
                        " Ед. изм" + ub.bar-code.unit-cli)
        {&wl-mes}
      end.
      if ub.bar-code.part-code <> "":U or ub.bar-code.in-code <> "":U then do:
        &scop err-mes (~{&err-mes0~} + " Баркод для ДопБК(prod-bc) не является баркодом товара на доп.ед.изм:" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Баркод " + string(temp-prod-bc.b-code) + ~
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
                        " Баркод " + string(temp-prod-bc.b-code))
        {&wl-mes}
      end.
      if v-is-global
      and p-glb = no
      then do:
        &scop err-mes (~{&err-mes0~} + " ДопБК(prod-bc) не локальный:" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Баркод " + string(temp-prod-bc.b-code))
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
                        " Баркод " + string(temp-prod-bc.b-code))
        {&wl-mes}
      end.
      if not v-is-scaleable then do:
        &scop err-mes (~{&err-mes0~} + " ДопБК(prod-bc) не весовой:" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Баркод " + string(temp-prod-bc.b-code))
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
    or v-b-str <> temp-prod-bc.b-str
    then do:
      {&get-mes}
      er-mes = er-mes + {&new-line} + return-value .
      &scop err-mes (~{&err-mes0~} + " ошибка при сохранении записи ДопБК(prod-bc):" + ~
                        " ДопБК " + string(temp-prod-bc.b-str) + ~
                        " Баркод " + string(temp-prod-bc.b-code) + ~
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
  find first buf_code-range no-lock where
            buf_code-range.range-type = {&loc-pg-code}
        and buf_code-range.db-num = 0 no-error.
  if available buf_code-range then do:
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
  if available buf_code-range then do:
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
      &scop err-mes (~{&err-mes0~} + " ошибка при получении max кода диапазона локальных штучных кодов для весов(prod-bc):" + ~
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
      &scop err-mes (~{&err-mes0~} + " Ошибка при поиске основного баркода товара  для АТРИБУТА ТОВАРА ВЕСОВОЙ КОД НА ОБЪЕКТЕ(gds-obj-attr) принадлежит другой БД:" + ~
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
                        " баркод " + string(temp-scales-gds.b-code))
        {&wl-mes}
    end.
    FIND FIRST ub.bar-code No-LOCK WHERE
               ub.bar-code.b-code = temp-scales-gds.b-code No-ERROR.
    IF NOT AVAIL ub.bar-code then do:
        &scop err-mes (~{&err-mes0~} + " Не найден БАРКОД для ТОВАРА НА ВЕСАХ(scales-gds):" + ~
                        " номер весов " + string(temp-scales-gds.scales-num) + ~
                        " баркод " + string(temp-scales-gds.b-code))
        {&wl-mes}
    END.
    FIND FIRST ub.goods No-LOCK WHERE
               ub.goods.gds-code = ub.bar-code.gds-code NO-ERROR.
    IF NOT AVAILABLE ub.goods then do:
        &scop err-mes (~{&err-mes0~} + " Не найден ТОВАР для ТОВАРА НА ВЕСАХ(scales-gds):" + ~
                        " номер весов " + string(temp-scales-gds.scales-num) + ~
                        " баркод " + string(temp-scales-gds.b-code))
        {&wl-mes}
    END.
    FIND FIRST ub.units No-LOCK WHERE
               ub.units.unit-name = ub.goods.unit-base No-ERROR.
    IF NOT AVAIL ub.units then do:
        &scop err-mes (~{&err-mes0~} + " Не найдена ЕДИНИЦА ИЗМЕРЕНИЯ для ТОВАРА НА ВЕСАХ(scales-gds):" + ~
                        " номер весов " + string(temp-scales-gds.scales-num) + ~
                        " баркод " + string(temp-scales-gds.b-code))
        {&wl-mes}
    END.
    if ub.units.unit-name <> scales-unit
    and ub.units.type = {&weight}
    then do:
        &scop err-mes (~{&err-mes0~} + " ЕДИНИЦА ИЗМЕРЕНИЯ ТОВАРА НА ВЕСАХ(scales-gds):" + ~
                        " номер весов " + string(temp-scales-gds.scales-num) + ~
                        " баркод " + string(temp-scales-gds.b-code) + ~
                        " единица измерения товара " + ub.units.unit-name + ~
                        " единица измерения весов " + scales-unit )
        {&wl-mes}
    END.
    FIND FIRST ub.gds-prt No-LOCK WHERE
               ub.gds-prt.upper-code = ub.goods.prt-root NO-ERROR.
    IF NOT AVAIL(ub.gds-prt) then do:
        &scop err-mes (~{&err-mes0~} + " Не найдена ШКАЛА ПРИЗНАКОВ(пустая шкала) для ТОВАРА НА ВЕСАХ(scales-gds):" + ~
                        " номер весов " + string(temp-scales-gds.scales-num) + ~
                        " баркод " + string(temp-scales-gds.b-code))
        {&wl-mes}
    END.
    if ub.bar-code.node-code <> ub.gds-prt.node-code OR
      ub.bar-code.in-code <> "":U OR
      ub.bar-code.part-code <> "":U OR
      ub.bar-code.unit-cli <> ub.goods.unit-base then do:
        &scop err-mes (~{&err-mes0~} + " Баркод не является главным баркодом товара для ТОВАРА НА ВЕСАХ(scales-gds):" + ~
                        " номер весов " + string(temp-scales-gds.scales-num) + ~
                        " баркод " + string(temp-scales-gds.b-code))
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
                        " баркод " + string(temp-scales-gds.b-code) + ~
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
if p-cdk then do:
  &scop current-data-group "cdk":U
  &scop wait-mess "Проверка группы данных КАССЫ"
  &scop err-mes0 "Проверка группы данных КАССЫ" + ~{&new-line~}
  {&waitc}
  &scop next-line _cash-deskv
  &scop table-name temp-cash-desk
  _cash-deskv:
  FOR EACH temp-cash-desk:
    FIND FIRST ub.cash-desk No-LOCK WHERE
               ub.cash-desk.db-num = temp-cash-desk.db-num  AND
               ub.cash-desk.obj-code = temp-cash-desk.obj-code  AND
               ub.cash-desk.pos-type = temp-cash-desk.pos-type  AND
               ub.cash-desk.cash-num = temp-cash-desk.cash-num  NO-ERROR.
    IF AVAILABLE ub.cash-desk then do:
      assign
      v-mode = {&update}
      v-rid = recid(ub.cash-desk).
    end.
    else do:
      assign
      v-mode = {&add-def}
      v-rid = ?.
    end.
    run ref/cashdsk1.p (
    input-output v-rid
    ,input v-mode
    ,input temp-cash-desk.db-num
    ,input temp-cash-desk.obj-code
    ,input temp-cash-desk.pos-type
    ,input temp-cash-desk.cash-num
    ,input temp-cash-desk.autonomy
    ,input temp-cash-desk.addr-path
    ,input temp-cash-desk.cash-on
    ,input temp-cash-desk.cash-os
    ,input temp-cash-desk.is-del
    ,input temp-cash-desk.remote
    ,input temp-cash-desk.version
    ,input temp-cash-desk.registration-code
    ,input temp-cash-desk.serial-code
    ,input temp-cash-desk.fr-type
    ,input ? /* вариант исполнения кассы (ТСО,неТСО,мобильн); "?" = "оставить прежнее значение" */
    ) no-error .
    if error-status:error then do:
      {&get-mes}
      &scop err-mes (~{&err-mes0~} +  " ошибка при сохранении записи КАССА(cash-desk):" + ~
                                      " номер " + string(temp-cash-desk.cash-num) + ~
                                      er-mes)
      {&undo-mes}
    end.
  END. /*FOR EACH temp-cash-desk*/
end.
if p-pet then do:
  if p-pet then do:
    run p-pet-i in this-procedure.
  end.

  &scop current-data-group "pet":U
  &scop wait-mess "Проверка группы данных КОНФИГУРАЦИЯ АЗК"
  &scop err-mes0 "Проверка группы данных КОНФИГУРАЦИЯ АЗК" + ~{&new-line~}
  {&waitc}
  &scop next-line _placev
  &scop table-name temp-place
  _placev:
  FOR EACH temp-place:
    FIND FIRST ub.place No-LOCK WHERE
               ub.place.obj-type = temp-place.obj-type  AND
               ub.place.obj-code = temp-place.obj-code  AND
               ub.place.loc1 = temp-place.loc1  NO-ERROR.
    IF AVAILABLE ub.place then do:
      assign
      v-mode = {&update}
      v-rid = recid(ub.place)
      .
    end.
    else do:
      assign
      v-mode = {&add-def}
      v-rid = ?
      .
    end.
    run ref/place01.p (
                    input-output v-rid
                    ,INPUT v-mode
                    ,INPUT yes /*silent*/
                    ,input temp-place.obj-type
                    ,input temp-place.obj-code
                    ,input temp-place.pl-code
                    ,input temp-place.loc1
                    ,input temp-place.loc2
                    ,input temp-place.loc3
                    ,input temp-place.loc4
                    ,input temp-place.pl-name
                    ,input temp-place.ps
                    ,input temp-place.add-qnty
                    ,input temp-place.is-meas
                    ,input temp-place.max-qnty
                    ,input temp-place.issue-year
                    ,input temp-place.start-date
                    ,input temp-place.chk-max-qnty
                    ) no-error.
    if error-status:error then do:
      {&get-mes}
      &scop err-mes (~{&err-mes0~} +  " ошибка при сохранении записи СКЛ.МЕСТО(place):" + ~
                                      " номер " + string(temp-place.pl-code) + ~
                                      er-mes)
      {&undo-mes}
    end.
    find first ub.place no-lock where
              recid(ub.place) = v-rid.
    for each temp-pl-gds :
      if temp-pl-gds.pl-code = temp-place.pl-code then do:
        temp-pl-gds.pl-code = ub.place.pl-code.
      end.
    end.
    for each temp-pl-pump:
      if temp-pl-pump.pl-code = temp-place.pl-code then do:
        temp-pl-pump.pl-code = ub.place.pl-code.
      end.
    end.
    for each temp-pl-gds-pump :
      if temp-pl-gds-pump.pl-code = temp-place.pl-code then do:
        temp-pl-gds-pump.pl-code = ub.place.pl-code.
      end.
    end.
    for each temp-pl-pump-nozzle:
      if temp-pl-pump-nozzle.pl-code = temp-place.pl-code then do:
        temp-pl-pump-nozzle.pl-code = ub.place.pl-code.
      end.
    end.
  END. /*FOR EACH temp-place*/
  &scop next-line _pumpv
  &scop table-name temp-pump
  _pumpv:
  for each temp-pump:
    FIND FIRST ub.pump share-LOCK WHERE
               ub.pump.obj-type = temp-pump.obj-type  AND
               ub.pump.obj-code = temp-pump.obj-code  AND
               ub.pump.pump-code = temp-pump.pump-code  NO-ERROR.
    IF not AVAILABLE ub.pump then do:
     create ub.pump.
      buffer-copy temp-pump to ub.pump.
    end.
    buffer-copy  temp-pump to ub.pump.
    release ub.pump no-error.
    if error-status:error then do:
      {&get-mes}
      &scop err-mes (~{&err-mes0~} +  " ошибка при сохранении записи ТРК(pump):" + ~
                                      " номер " + string(temp-pump.pump-code) + ~
                                      er-mes)
      {&undo-mes}
    end.
  end.
  &scop next-line _nozzlev
  &scop table-name temp-nozzle
  _nozzlev:
  for each temp-nozzle:
    FIND FIRST ub.nozzle share-LOCK WHERE
               ub.nozzle.obj-type = temp-nozzle.obj-type  AND
               ub.nozzle.obj-code = temp-nozzle.obj-code  AND
               ub.nozzle.nozzle-code = temp-nozzle.nozzle-code  NO-ERROR.
    IF not AVAILABLE ub.nozzle then do:
      create ub.nozzle.
    end.
    buffer-copy  temp-nozzle to ub.nozzle.
    release ub.nozzle no-error.
    if error-status:error then do:
      {&get-mes}
      &scop err-mes (~{&err-mes0~} +  " ошибка при сохранении записи ПИСТОЛЕТ(nozzle):" + ~
                                      " номер " + string(temp-nozzle.nozzle-code) + ~
                                      er-mes)
      {&undo-mes}
    end.
  end.
  &scop next-line _nozzlev
  &scop table-name temp-pump-nozzle
  _nozzlev:
  for each temp-pump-nozzle:
    FIND FIRST ub.nozzle No-LOCK WHERE
               ub.nozzle.obj-type = temp-pump-nozzle.obj-type  AND
               ub.nozzle.obj-code = temp-pump-nozzle.obj-code  AND
               ub.nozzle.nozzle-code = temp-pump-nozzle.nozzle-code
               NO-ERROR.
    IF not AVAILABLE ub.nozzle then do:
        &scop err-mes (~{&err-mes0~} + " Не найден ПИСТОЛЕТ для ПРИВЯЗКИ ТРК К ПИСТОЛЕТУ(pump-nozzle):" +  ~
                        " пистолет" + string(temp-pump-nozzle.nozzle-code) + " код ТРК " + string(temp-pump-nozzle.pump-code ))
        {&wl-mes}
    end.
    FIND FIRST ub.pump No-LOCK WHERE
               ub.pump.obj-type = temp-pump-nozzle.obj-type  AND
               ub.pump.obj-code = temp-pump-nozzle.obj-code  AND
               ub.pump.pump-code = temp-pump-nozzle.pump-code
               NO-ERROR.
    IF not AVAILABLE ub.pump then do:
        &scop err-mes (~{&err-mes0~} + " Не найдено ТРК для ПРИВЯЗКИ ТРК к ПИСТОЛЕТУ(pump-nozzle):" +  ~
                        " код пистолета " + string(temp-pump-nozzle.nozzle-code)  + " код ТРК " + string(temp-pump-nozzle.pump-code ))
        {&wl-mes}
    end.

    FIND FIRST ub.pump-nozzle share-LOCK WHERE
               ub.pump-nozzle.obj-type = temp-pump-nozzle.obj-type  AND
               ub.pump-nozzle.obj-code = temp-pump-nozzle.obj-code  AND
               ub.pump-nozzle.nozzle-code = temp-pump-nozzle.nozzle-code AND
               ub.pump-nozzle.pump-code = temp-pump-nozzle.pump-code
               NO-ERROR.
    IF not AVAILABLE ub.pump-nozzle then do:
      create ub.pump-nozzle.
    end.
    buffer-copy  temp-pump-nozzle to ub.pump-nozzle.
    release ub.pump-nozzle no-error.
    if error-status:error then do:
      {&get-mes}
      &scop err-mes (~{&err-mes0~} +  " ошибка при сохранении записи СВЯЗКИ ТРК-ПИСТОЛЕТ(pump-nozzle):" + ~
                                      " ПИСТОЛЕТ " + string(temp-pump-nozzle.nozzle-code) + ~
                                      " ТРК " + string(temp-pump-nozzle.pump-code) + ~
                                      er-mes)
      {&undo-mes}
    end.
  end.

  &scop next-line _pl-gdsv
  &scop table-name temp-pl-gds
  _pl-gdsv:
  for each temp-pl-gds:
    find first ub.goods no-lock where
              ub.goods.gds-code = temp-pl-gds.gds-code no-error.
    if not avail ub.goods then do:
        &scop err-mes (~{&err-mes0~} + " Нет товара для товара на скл.месте(pl-gds):" +  ~
                        " код товара " + string(temp-pl-gds.gds-code)  + " код скл.места " + string(temp-pl-gds.pl-code) )
        {&wl-mes}
    end.
    FIND FIRST ub.place No-LOCK WHERE
               ub.place.obj-type = temp-pl-gds.obj-type  AND
               ub.place.obj-code = temp-pl-gds.obj-code  AND
               ub.place.pl-code = temp-pl-gds.pl-code
               NO-ERROR.
    IF not AVAILABLE ub.place then do:
        &scop err-mes (~{&err-mes0~} + " Не найдено СКЛ.МЕСТО для ПРИВЯЗКИ ТОВАРА К СКЛ.МЕСТУ(pl-gds):" +  ~
                        " код товара " + string(temp-pl-gds.gds-code)  + " код скл.места " + string(temp-pl-gds.pl-code) )
        {&wl-mes}
    end.

    FIND FIRST ub.pl-gds No-LOCK WHERE
               ub.pl-gds.obj-type = temp-pl-gds.obj-type  AND
               ub.pl-gds.obj-code = temp-pl-gds.obj-code  AND
               ub.pl-gds.gds-code = temp-pl-gds.gds-code  AND
               ub.pl-gds.pl-code = temp-pl-gds.pl-code
               NO-ERROR.
    IF AVAILABLE ub.pl-gds then do:
        &scop err-mes (~{&err-mes0~} + " Уже есть ПРИВЯЗКА ЭТОГО ТОВАРА К ЭТОМУ СКЛ.МЕСТУ(pl-gds):" +  ~
                        " код товара " + string(temp-pl-gds.gds-code)  + " код скл.места " + string(temp-pl-gds.pl-code) )
        {&wl-mes}
    end.

    define variable individ as logical no-undo .
    define variable glog as logical no-undo .
    define buffer buf_units for ub.units.
    define buffer buf_pl-gds for ub.pl-gds.
    /*если бензин то заливать в один бак два бензина нельзя!*/
    FIND FIRST buf_units No-LOCK where
              buf_units.unit-name = ub.goods.unit-base No-ERROR.
    if not avail buf_units then NEXT.
    if LOOKUP({&petrolium}, buf_units.type) > 0  and lookup({&divisional}, buf_units.type) > 0
    then
    assign
    individ = yes.
    else
    assign
    individ = no.
    do transaction on error undo, next :
      find first buf_pl-gds no-lock
            where buf_pl-gds.obj-type = temp-pl-gds.obj-type
              and buf_pl-gds.obj-code = temp-pl-gds.obj-code
              and buf_pl-gds.pl-code  = temp-pl-gds.pl-code
              and buf_pl-gds.gds-code = temp-pl-gds.pl-code no-error.
      if not available buf_pl-gds then do:
        /*нет еще такой связки товар-место*/
        if lookup({&petrolium}, buf_units.type) > 0
        and lookup({&divisional}, buf_units.type) > 0 then do:
          /*топливо*/
          run trg/plgdpmvc.p (
                           input  temp-pl-gds.obj-type
                          ,input  temp-pl-gds.obj-code
                          ,input  temp-pl-gds.pl-code
                          ,input  temp-pl-gds.gds-code
                          ,output glog) no-error.
          if error-status:error
          or not glog
          then do:
            &scop err-mes (~{&err-mes0~} + "Ошибка при привязке товара к резервуару(pl-gds):" +  ~
                            " код товара " + string(temp-pl-gds.gds-code)  + " код скл.места " + string(temp-pl-gds.pl-code) + ~
                            error-status:get-message(1) + ~{&new-line~} + return-value )
            {&wl-mes}
          end.
        END.
        else do:
          /*нетопливо*/
          run trg/plgdpmv0.p (
                           input temp-pl-gds.obj-type
                          ,input temp-pl-gds.obj-code
                          ,input temp-pl-gds.pl-code
                          ,input temp-pl-gds.gds-code
                          ,output glog) no-error.
          if error-status:error
          or not glog
          then do:
            &scop err-mes (~{&err-mes0~} + "Ошибка при привязке товара к резервуару(pl-gds):" +  ~
                            " код товара " + string(temp-pl-gds.gds-code)  + " код скл.места " + string(temp-pl-gds.pl-code) + ~
                            error-status:get-message(1) + ~{&new-line~} + return-value )
            {&wl-mes}
          end.
        end.
      end.
    end. /*do transact*/
  end. /*  for each temp-pl-gds:*/
  &scop next-line _pl-gds-pumpv
  &scop table-name temp-pl-gds-pump
  _pl-gds-pumpv:
  for each temp-pl-gds-pump:
    find first ub.goods no-lock where
              ub.goods.gds-code = temp-pl-gds-pump.gds-code no-error.
    if not avail ub.goods then do:
        &scop err-mes (~{&err-mes0~} + " Нет товара для товара на скл.месте и ТРК(pl-gds-pump):" +  ~
                        " код товара " + string(temp-pl-gds-pump.gds-code)  + " код скл.места " + string(temp-pl-gds-pump.pl-code) + " код ТРК " + string(temp-pl-gds-pump.pump-code ))
        {&wl-mes}
    end.
    FIND FIRST ub.place No-LOCK WHERE
               ub.place.obj-type = temp-pl-gds-pump.obj-type  AND
               ub.place.obj-code = temp-pl-gds-pump.obj-code  AND
               ub.place.pl-code = temp-pl-gds-pump.pl-code
               NO-ERROR.
    IF not AVAILABLE ub.place then do:
        &scop err-mes (~{&err-mes0~} + " Не найдено СКЛ.МЕСТО для ПРИВЯЗКИ ТОВАРА К СКЛ.МЕСТУ и ТРК(pl-gds-pump):" +  ~
                        " код товара " + string(temp-pl-gds-pump.gds-code)  + " код скл.места " + string(temp-pl-gds-pump.pl-code) + " код ТРК " + string(temp-pl-gds-pump.pump-code))
        {&wl-mes}
    end.
    FIND FIRST ub.pump No-LOCK WHERE
               ub.pump.obj-type = temp-pl-gds-pump.obj-type  AND
               ub.pump.obj-code = temp-pl-gds-pump.obj-code  AND
               ub.pump.pump-code = temp-pl-gds-pump.pump-code
               NO-ERROR.
    IF not AVAILABLE ub.pump then do:
        &scop err-mes (~{&err-mes0~} + " Не найдено ТРК для ПРИВЯЗКИ ТОВАРА К СКЛ.МЕСТУ и ТРК(pl-gds-pump):" +  ~
                        " код товара " + string(temp-pl-gds-pump.gds-code)  + " код скл.места " + string(temp-pl-gds-pump.pl-code) + " код ТРК " + string(temp-pl-gds-pump.pump-code ))
        {&wl-mes}
    end.
    FIND FIRST ub.pl-gds-pump share-LOCK WHERE
               ub.pl-gds-pump.obj-type = temp-pl-gds-pump.obj-type  AND
               ub.pl-gds-pump.obj-code = temp-pl-gds-pump.obj-code  AND
               ub.pl-gds-pump.gds-code = temp-pl-gds-pump.gds-code  AND
               ub.pl-gds-pump.pl-code = temp-pl-gds-pump.pl-code AND
               ub.pl-gds-pump.pump-code = temp-pl-gds-pump.pump-code
               NO-ERROR.
    IF not AVAILABLE ub.pl-gds-pump then do:
      create ub.pl-gds-pump.
    end.
    buffer-copy temp-pl-gds-pump to ub.pl-gds-pump.
    release ub.pl-gds-pump no-error.
    if error-status:error then do:
      {&get-mes}
      &scop err-mes (~{&err-mes0~} +  " ошибка при сохранении записи ПРИВЯЗКИ ТОВАРА К СКЛ.МЕСТУ и ТРК(pl-gds-pump):" + ~
            " код товара " + string(temp-pl-gds-pump.gds-code)  + " код скл.места " + string(temp-pl-gds-pump.pl-code) + " код ТРК " + string(temp-pl-gds-pump.pump-code ) + ~
                                      er-mes)
      {&undo-mes}
    end.

  end. /*  for each temp-pl-gds-pump:*/
  &scop next-line _pl-pumpv
  &scop table-name temp-pl-pump
  _pl-pumpv:
  for each temp-pl-pump:
    FIND FIRST ub.place No-LOCK WHERE
               ub.place.obj-type = temp-pl-pump.obj-type  AND
               ub.place.obj-code = temp-pl-pump.obj-code  AND
               ub.place.pl-code = temp-pl-pump.pl-code
               NO-ERROR.
    IF not AVAILABLE ub.place then do:
        &scop err-mes (~{&err-mes0~} + " Не найдено СКЛ.МЕСТО для ПРИВЯЗКИ ТРК К СКЛ.МЕСТУ(pl-pump):" +  ~
                        " код скл.места " + string(temp-pl-pump.pl-code) + " код ТРК " + string(temp-pl-pump.pump-code))
        {&wl-mes}
    end.
    FIND FIRST ub.pump No-LOCK WHERE
               ub.pump.obj-type = temp-pl-pump.obj-type  AND
               ub.pump.obj-code = temp-pl-pump.obj-code  AND
               ub.pump.pump-code = temp-pl-pump.pump-code
               NO-ERROR.
    IF not AVAILABLE ub.pump then do:
        &scop err-mes (~{&err-mes0~} + " Не найдено ТРК для ПРИВЯЗКИ ТРК К СКЛ.МЕСТУ(pl-pump):" +  ~
                        " код скл.места " + string(temp-pl-pump.pl-code) + " код ТРК " + string(temp-pl-pump.pump-code ))
        {&wl-mes}
    end.
    FIND FIRST ub.pl-pump share-LOCK WHERE
               ub.pl-pump.obj-type = temp-pl-pump.obj-type  AND
               ub.pl-pump.obj-code = temp-pl-pump.obj-code  AND
               ub.pl-pump.pl-code = temp-pl-pump.pl-code AND
               ub.pl-pump.pump-code = temp-pl-pump.pump-code
               NO-ERROR.
    IF not AVAILABLE ub.pl-pump then do:
      create ub.pl-pump.
    end.
     buffer-copy temp-pl-pump to ub.pl-pump.
    release ub.pl-pump no-error.
    if error-status:error then do:
      {&get-mes}
      &scop err-mes (~{&err-mes0~} +  " ошибка при сохранении записи ПРИВЯЗКИ ТРК К СКЛ.МЕСТУ(pl-pump):" + ~
                                                " код скл.места " + string(temp-pl-pump.pl-code) + " код ТРК " + string(temp-pl-pump.pump-code ) + ~
                                      er-mes)
      {&undo-mes}
    end.
  end. /*  for each temp-pl-pump:*/
  &scop next-line _pl-pump-nozzlev
  &scop table-name temp-pl-pump-nozzle
  _pl-pump-nozzlev:
  for each temp-pl-pump-nozzle:
    FIND FIRST ub.place No-LOCK WHERE
               ub.place.obj-type = temp-pl-pump-nozzle.obj-type  AND
               ub.place.obj-code = temp-pl-pump-nozzle.obj-code  AND
               ub.place.pl-code = temp-pl-pump-nozzle.pl-code
               NO-ERROR.
    IF not AVAILABLE ub.place then do:
        &scop err-mes (~{&err-mes0~} + " Не найдено СКЛ.МЕСТО для ПРИВЯЗКИ ТРК К СКЛ.МЕСТУ и ПИСТОЛЕТУ(pl-pump-nozzle):" +  ~
                        " пистолет" + string(temp-pl-pump-nozzle.nozzle-code) + " код скл.места " + string(temp-pl-pump-nozzle.pl-code) + " код ТРК " + string(temp-pl-pump-nozzle.pump-code))
        {&wl-mes}
    end.
    FIND FIRST ub.pump No-LOCK WHERE
               ub.pump.obj-type = temp-pl-pump-nozzle.obj-type  AND
               ub.pump.obj-code = temp-pl-pump-nozzle.obj-code  AND
               ub.pump.pump-code = temp-pl-pump-nozzle.pump-code
               NO-ERROR.
    IF not AVAILABLE ub.pump then do:
        &scop err-mes (~{&err-mes0~} + " Не найдено ТРК для ПРИВЯЗКИ ТРК К СКЛ.МЕСТУ и ПИСТОЛЕТУ(pl-pump-nozzle):" +  ~
                        " пистолет" + string(temp-pl-pump-nozzle.nozzle-code) + " код скл.места " + string(temp-pl-pump-nozzle.pl-code) + " код ТРК " + string(temp-pl-pump-nozzle.pump-code ))
        {&wl-mes}
    end.
    FIND FIRST ub.nozzle No-LOCK WHERE
               ub.nozzle.obj-type = temp-pl-pump-nozzle.obj-type  AND
               ub.nozzle.obj-code = temp-pl-pump-nozzle.obj-code  AND
               ub.nozzle.nozzle-code = temp-pl-pump-nozzle.nozzle-code
               NO-ERROR.
    IF not AVAILABLE ub.nozzle then do:
        &scop err-mes (~{&err-mes0~} + " Не найден ПИСТОЛЕТ для ПРИВЯЗКИ ТРК К СКЛ.МЕСТУ и ПИСТОЛЕТУ(pl-pump-nozzle):" +  ~
                        " пистолет" + string(temp-pl-pump-nozzle.nozzle-code) + " код скл.места " + string(temp-pl-pump-nozzle.pl-code) + " код ТРК " + string(temp-pl-pump-nozzle.pump-code ))
        {&wl-mes}
    end.
    FIND FIRST ub.pl-pump-nozzle share-LOCK WHERE
               ub.pl-pump-nozzle.obj-type = temp-pl-pump-nozzle.obj-type  AND
               ub.pl-pump-nozzle.obj-code = temp-pl-pump-nozzle.obj-code  AND
               ub.pl-pump-nozzle.pl-code = temp-pl-pump-nozzle.pl-code AND
               ub.pl-pump-nozzle.pump-code = temp-pl-pump-nozzle.pump-code AND
               ub.pl-pump-nozzle.nozzle-code = temp-pl-pump-nozzle.nozzle-code
               NO-ERROR.
    IF AVAILABLE ub.pl-pump-nozzle then do:
      create ub.pl-pump-nozzle.
    end.
    buffer-copy temp-pl-pump-nozzle to ub.pl-pump-nozzle.
    release ub.pl-pump-nozzle no-error.
    if error-status:error then do:
      {&get-mes}
      &scop err-mes (~{&err-mes0~} +  " ошибка при сохранении записи ПРИВЯЗКИ ТРК К СКЛ.МЕСТУ и ПИСТОЛЕТУ(pl-pump-nozzle):" + ~
                        " пистолет" + string(temp-pl-pump-nozzle.nozzle-code) + " код скл.места " + string(temp-pl-pump-nozzle.pl-code) + " код ТРК " + string(temp-pl-pump-nozzle.pump-code ) + ~
                                      er-mes)
      {&undo-mes}
    end.
  end. /*  for each temp-pl-pump-nozzle:*/
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

         create alias restseq    for database value( ldbname( "ub":U ) ) .
         create alias restseqflt for database value( ldbname( "ubflt":U ) ) .
         run adm/restseq.p
           ( input "rest":U
           , input "s-action-role":U
           , input no
           ) no-error .
         if error-status :error then do:
           delete alias restseqflt.
           delete alias restseq.
           return error return-value .
         end.
         delete alias restseqflt.
         delete alias restseq.

         &scop next-line _action-role-item
         &scop table-name temp-action-role-item
         _action-role-item:
         FOR EACH temp-action-role-item:
            FIND FIRST ub.action-role-item No-LOCK
                 WHERE ub.action-role-item.db-num           = temp-action-role-item.db-num
                   and ub.action-role-item.action-head-code = temp-action-role-item.action-head-code
                   and ub.action-role-item.action-role-code = temp-action-role-item.action-role-code
                   and ub.action-role-item.action-role-item-code = temp-action-role-item.action-role-item-code
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
            buffer-copy temp-action-role-item to ub.action-role-item.
            release ub.action-role-item No-error.
            if error-status:error then do:
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

         create alias restseq    for database value( ldbname( "ub":U ) ) .
         create alias restseqflt for database value( ldbname( "ubflt":U ) ) .
         run adm/restseq.p
           ( input "rest":U
           , input "s-action-role-item":U
           , input no
           ) no-error .
         if error-status :error then do:
           delete alias restseqflt.
           delete alias restseq.
           return error return-value .
         end.
         delete alias restseqflt.
         delete alias restseq.

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

      create alias restseq    for database value( ldbname( "ub":U ) ) .
      create alias restseqflt for database value( ldbname( "ubflt":U ) ) .
      run adm/restseq.p
        ( input "rest":U
        , input "s-user-id":U
        , input no
        ) no-error .
      if error-status :error then do:
        delete alias restseqflt.
        delete alias restseq.
        return error return-value .
      end.
      delete alias restseqflt.
      delete alias restseq.

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
                 WHERE ub.user-login-action-role.user-id  = temp-user-login-action-role.user-id
                   AND ub.user-login-action-role.db-num   = temp-user-login-action-role.db-num
                   AND ub.user-login-action-role.user-login-role-code = temp-user-login-action-role.user-login-role-code
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
      create alias restseq    for database value( ldbname( "ub":U ) ) .
      create alias restseqflt for database value( ldbname( "ubflt":U ) ) .
      run adm/restseq.p
        ( input "rest":U
        , input "s-user-login-action-role":U
        , input no
        ) no-error .
      if error-status :error then do:
        delete alias restseqflt.
        delete alias restseq.
        return error return-value .
      end.
      delete alias restseqflt.
      delete alias restseq.

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
               + {&comma-char} + 'adm':U
               v-obj-name      = 'object':U
            .
         end.
         assign
            v-menu-group-id-list = 'off,str,shp,res,fin,bge,adm':U
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
               buf_user-account.nik                   = v-user-id
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
                     v-user-menu-group-code = dynamic-next-value("s-user-menu-group":U, "{&db-name_schema}":U)
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
                           v-user-menu-group-code = dynamic-next-value("s-user-menu-group":U, "{&db-name_schema}":U)
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
              buf-config.db-num = g#db-num.
              if buf-config.host-code <> 0
              and buf-config.host-code <> p-old-host-code then do:
                delete buf-config.
                next {&next-line}.
              end.
              if buf-config.obj-code <> 0
              and not (buf-config.obj-type = p-old-obj-type
                      and
                      buf-config.obj-code = p-old-obj-code)
              then do:
                delete buf-config.
                next {&next-line}.
              end.
              if buf-config.host-code = p-old-host-code then do:
                assign
                buf-config.host-code = p-new-host-code.
              end.
              if buf-config.obj-code <> 0
              and (buf-config.obj-type = p-old-obj-type
                  and
                  buf-config.obj-code = p-old-obj-code)
              then do:
                assign
                buf-config.obj-type = p-new-obj-type
                buf-config.obj-code = p-new-obj-code
                .
              end.
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

procedure p-thb-i :
define variable v-int1 as integer no-undo .


  do
  on error undo, return error
  :
&scop next-line _thb
&scop err-mes0   ("Импорт группы данных ПАРАМЕТРЫ O БД, СТРОКА " + string(ii) + ~{&new-line~})
&scop current-data-group "thb":U
&scop wait-mess "Импорт группы данных ПАРАМЕТРЫ"
&scop err-mes (~{&wait-mess~} + " Файл: " + p-dir-name + "\":U + p-db-key + ".":U + ~{&current-data-group~})
  {&wl}
  {&check-file}
  {&ii0}
  if loc#log then do:
    {&waitc}
    {&input-stream}
    _thb:
    REPEAT:
      {&imp-stream-ss}
      CASE ss:
        when {&table_thbj-attr} then do:
          current-table = ss.
          case current-table:
            when {&table_thbj-attr} then do:
              {&ii1}
              create buf-thbj-attr.
              {&imp-stream} {&ie-thbj-attr-fields} no-error.
              &scop err-mes ~{&errimp-mes~}
              {&wlerimp-mes}
              if (buf-thbj-attr.obj-type = {&shop}
              or buf-thbj-attr.obj-type = {&stock} )
              and not (p-old-obj-type = buf-thbj-attr.obj-type
                       and
                       p-old-obj-code = buf-thbj-attr.obj-code)
              then do:
                delete buf-thbj-attr.
                next _thb.
              end.
              if buf-thbj-attr.obj-type = {&cmp}
              and p-old-host-code <> buf-thbj-attr.obj-code then do:
                delete buf-thbj-attr.
                next _thb.
              end.
              if lookup(buf-thbj-attr.upper-prop-code, {&need-thbj-attr-list}) = 0 then do:
                 delete buf-thbj-attr.
                 next _thb.
               end.
              if buf-thbj-attr.obj-type = {&cmp} then do:
                assign
                buf-thbj-attr.obj-code = p-new-host-code.
              end.
              if buf-thbj-attr.obj-type = {&shop}
              or buf-thbj-attr.obj-type = {&stock}  then do:
                assign
                buf-thbj-attr.obj-type = p-new-obj-type
                buf-thbj-attr.obj-code = p-new-obj-code
                .
              end.
              case buf-thbj-attr.upper-prop-code:
                when {&attr-autosale} then do:
                  case buf-thbj-attr.prop-code:
                    when {&attr-autosale_neg-tpsi-weight} then do:
                      next _thb.
                    end.
                    when {&attr-autosale_neg-tpsi-qnty} then do:
                      next _thb.
                    end.
                    when {&attr-autosale_neg-tpsi-oper} then do:
                      next _thb.
                    end.
                    when {&attr-autosale_tpsi-mode} then do:
                      next _thb.
                    end.
                    when {&attr-autosale_main-tpsi} then do:
                      next _thb.
                    end.
                    when {&attr-autosale_wrkr} then do:
                      run convert-thbj-attr-integer-1 in this-procedure ( input buf-thbj-attr.property-value-integer
                                                                         ,output v-int1) no-error.

                      if error-status:error then do:
                        &scop err-mes (~{&err-mes0~} + " Для значения параметра не найдено соответствие в таблице соответствий: ПАРАМЕТРА(thbj-attr)" + ~
                                        " Секция " + string(buf-thbj-attr.upper-prop-code) + ~
                                        " параметр " + buf-thbj-attr.prop-code + ~
                                        " тип объекта " + buf-thbj-attr.obj-type + ~
                                        " код объекта " + string(buf-thbj-attr.obj-code) )
                        {&wl-mes}
                      end.
                      else do:
                        buf-thbj-attr.property-value-integer = v-int1.
                      end.
                    end.
                    when {&attr-autosale_agnt} then do:
                      run convert-thbj-attr-integer-1 in this-procedure ( input buf-thbj-attr.property-value-integer
                                                                         ,output v-int1) no-error.

                      if error-status:error then do:
                        &scop err-mes (~{&err-mes0~} + " Для значения параметра не найдено соответствие в таблице соответствий: ПАРАМЕТРА(thbj-attr)" + ~
                                        " Секция " + string(buf-thbj-attr.upper-prop-code) + ~
                                        " параметр " + buf-thbj-attr.prop-code + ~
                                        " тип объекта " + buf-thbj-attr.obj-type + ~
                                        " код объекта " + string(buf-thbj-attr.obj-code) )
                        {&wl-mes}
                      end.
                      else do:
                        buf-thbj-attr.property-value-integer = v-int1.
                      end.
                    end.
                    when {&attr-autosale_boss} then do:
                      run convert-thbj-attr-integer-1 in this-procedure ( input buf-thbj-attr.property-value-integer
                                                                         ,output v-int1) no-error.

                      if error-status:error then do:
                        &scop err-mes (~{&err-mes0~} + " Для значения параметра не найдено соответствие в таблице соответствий: ПАРАМЕТРА(thbj-attr)" + ~
                                        " Секция " + string(buf-thbj-attr.upper-prop-code) + ~
                                        " параметр " + buf-thbj-attr.prop-code + ~
                                        " тип объекта " + buf-thbj-attr.obj-type + ~
                                        " код объекта " + string(buf-thbj-attr.obj-code) )
                        {&wl-mes}
                      end.
                      else do:
                        buf-thbj-attr.property-value-integer = v-int1.
                      end.
                    end.
                    when {&attr-autosale_one-sale-per-day} then do:
                      next _thb.
                    end.
                    when {&attr-autosale_close-day-period} then do:
                      next _thb.
                    end.
                  end case.
                end.
                when {&attr-get-chk} then do:
                  case buf-thbj-attr.prop-code:
                    when {&attr-get-chk_zero-cashier} then do:
                      next _thb.
                    end.
                  end case.
                end.
                when {&attr-cd-inf-send} then do:
                  case buf-thbj-attr.prop-code:
                    /*как используется скидка*/
                    when {&attr-cd-inf-send_how-temp-disc} then do:
                      next _thb.
                    end.
                    when {&attr-cd-inf-send_how-pcnt-kat} then do:
                      next _thb.
                    end.
                  end case.
                end.
                when {&attr-cd-type-ibm} then do:
                  case buf-thbj-attr.prop-code:
                    when {&attr-cd-type-ibm_specgrp} then do:
                      /*Спецгруппы в справочнике суммовых групп*/
                      next _thb.
                    end.
                  end case.
                end.
                when {&attr-ord-obj} then do:
                  case buf-thbj-attr.prop-code:
                    when {&attr-ord-obj_ord-askp} then do:
                      next _thb.
                    end.
                    when {&attr-ord-obj_ord-obj-rc} then do:
                      next _thb.
                    end.
                  end case.
                end.
                when {&attr-rt-trn-doc} then do:
                  case buf-thbj-attr.prop-code:
                    when {&attr-rt-trn-doc_wrkr} then do:
                      run convert-thbj-attr-integer-1 in this-procedure ( input buf-thbj-attr.property-value-integer
                                                                         ,output v-int1) no-error.

                      if error-status:error then do:
                        &scop err-mes (~{&err-mes0~} + " Для значения параметра не найдено соответствие в таблице соответствий: ПАРАМЕТРА(thbj-attr)" + ~
                                        " Секция " + string(buf-thbj-attr.upper-prop-code) + ~
                                        " параметр " + buf-thbj-attr.prop-code + ~
                                        " тип объекта " + buf-thbj-attr.obj-type + ~
                                        " код объекта " + string(buf-thbj-attr.obj-code) )
                        {&wl-mes}
                      end.
                      else do:
                        buf-thbj-attr.property-value-integer = v-int1.
                      end.
                    end.
                    when {&attr-rt-trn-doc_agnt} then do:
                      run convert-thbj-attr-integer-1 in this-procedure ( input buf-thbj-attr.property-value-integer
                                                                         ,output v-int1) no-error.

                      if error-status:error then do:
                        &scop err-mes (~{&err-mes0~} + " Для значения параметра не найдено соответствие в таблице соответствий: ПАРАМЕТРА(thbj-attr)" + ~
                                        " Секция " + string(buf-thbj-attr.upper-prop-code) + ~
                                        " параметр " + buf-thbj-attr.prop-code + ~
                                        " тип объекта " + buf-thbj-attr.obj-type + ~
                                        " код объекта " + string(buf-thbj-attr.obj-code) )
                        {&wl-mes}
                      end.
                      else do:
                        buf-thbj-attr.property-value-integer = v-int1.
                      end.
                    end.
                    when {&attr-rt-trn-doc_boss} then do:
                      run convert-thbj-attr-integer-1 in this-procedure ( input buf-thbj-attr.property-value-integer
                                                                         ,output v-int1) no-error.

                      if error-status:error then do:
                        &scop err-mes (~{&err-mes0~} + " Для значения параметра не найдено соответствие в таблице соответствий: ПАРАМЕТРА(thbj-attr)" + ~
                                        " Секция " + string(buf-thbj-attr.upper-prop-code) + ~
                                        " параметр " + buf-thbj-attr.prop-code + ~
                                        " тип объекта " + buf-thbj-attr.obj-type + ~
                                        " код объекта " + string(buf-thbj-attr.obj-code) )
                        {&wl-mes}
                      end.
                      else do:
                        buf-thbj-attr.property-value-integer = v-int1.
                      end.
                    end.
                  end case.
                end.
                when {&attr-gds-ref} then do:
                  case buf-thbj-attr.prop-code:
                    when {&attr-gds-ref_dfltggrp} then do:
                      next _thb.
                    end.
                  end case.
                end.
                when {&attr-gds-ref_obj} then do:
                  case buf-thbj-attr.prop-code:
                    when {&attr-gds-ref_obj_dfltggrp} then do:
                      next _thb.
                    end.
                  end case.
                end.
              end case.
              &scop table-name buf-thbj-attr
              IF CAN-FIND(FIRST temp-thbj-attr No-LOCK WHERE
                                temp-thbj-attr.prop-code = buf-thbj-attr.prop-code AND
                                temp-thbj-attr.upper-prop-code = buf-thbj-attr.upper-prop-code AND
                                temp-thbj-attr.obj-type = buf-thbj-attr.obj-type AND
                                temp-thbj-attr.obj-code = buf-thbj-attr.obj-code
                                 )
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть запись ПАРАМЕТРА(thbj-attr)" + ~
                                  " Секция " + string(buf-thbj-attr.upper-prop-code) + ~
                                  " параметр " + buf-thbj-attr.prop-code + ~
                                  " тип объекта " + buf-thbj-attr.obj-type + ~
                                  " код объекта " + string(buf-thbj-attr.obj-code) )
                  {&wl-mes}
              end.
              create temp-thbj-attr.
              buffer-copy buf-thbj-attr to temp-thbj-attr.
              delete buf-thbj-attr.
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
define variable v-b-code as integer no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .

define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_goods for ub.goods.


  do
  on error undo, return error
  :
&scop next-line _pbc
&scop err-mes0   ("Импорт группы данных ВЕС,ВЗВЕШ и ТОП КОДЫ, СТРОКА " + string(ii) + ~{&new-line~})
&scop current-data-group "pbc":U
&scop wait-mess "Импорт группы данных ВЕС,ВЗВЕШ и ТОП КОДЫ"
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
              {&imp-stream} {&ie-prod-bc-fields}
              buf-prod-bc.old-gds-code
              buf-prod-bc.unit-base
              buf-prod-bc.unit-cli
              no-error.
              &scop err-mes ~{&errimp-mes~}
              {&wlerimp-mes}
              &scop table-name buf-prod-bc
              find first buf_ext-classif no-lock where
                        buf_ext-classif.classif-subject = {&table_goods}
                   and  buf_ext-classif.classif-name = v-classif-name
                   and buf_ext-classif.key#_one = buf-prod-bc.old-gds-code no-error.
              if not available buf_ext-classif then do:
                  &scop err-mes (~{&err-mes0~} + " Не найдена запись для баркода в таблице соответствия(prod-bc):" + ~
                                 " ДопБК " + string(buf-prod-bc.b-str) + ~
                                 " Баркод " + string(buf-prod-bc.b-code))
                  {&wl-mes}
              end.
              RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT buf_ext-classif.uniq-key-rec
                                                  ,input ?
                                                  ,INPUT "ub"
                                                  ,INPUT ? /*p-bh-handle*/
                                                  ,INPUT NO-LOCK
                                                  ,OUTPUT v-rowid
                                                  ,OUTPUT v-tbl-name) no-error.
              if error-status:error then do:
                  &scop err-mes (~{&err-mes0~} + " Ошибка при восстановлении баркода полученного из таблицы соответствия(prod-bc):" + ~
                                 " ДопБК " + string(buf-prod-bc.b-str) + ~
                                 " Баркод " + string(buf-prod-bc.b-code))
                  {&wl-mes}
              end.
              find first buf_goods no-lock where
                        rowid(buf_goods) = v-rowid no-error.
              if not available buf_goods then do:
                  &scop err-mes (~{&err-mes0~} + " Не найден товар, полученный из таблицы соответствия(prod-bc):" + ~
                                 " ДопБК " + string(buf-prod-bc.b-str) + ~
                                 " Баркод " + string(buf-prod-bc.b-code))
                  {&wl-mes}
              end.
              { gbl/gdsbcode.i buf_goods.gds-code ? v-b-code no-error }
              if error-status:error then do:
                  &scop err-mes (~{&err-mes0~} + " Ошибка при определении главного баркода товара, полученный из таблицы соответствия(prod-bc):" + ~
                                 " ДопБК " + string(buf-prod-bc.b-str) + ~
                                 " Баркод " + string(buf-prod-bc.b-code))
                  {&wl-mes}
              end.
              IF CAN-FIND(FIRST temp-prod-bc No-LOCK WHERE
                                temp-prod-bc.b-str = buf-prod-bc.b-str
                            AND temp-prod-bc.b-code = buf-prod-bc.b-code )
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть ДопБК(prod-bc):" + ~
                                 " ДопБК " + string(buf-prod-bc.b-str) + ~
                                 " новый Баркод " + string(v-b-code)  + ~
                                 " старый Баркод " + string(buf-prod-bc.b-code))
                  {&wl-mes}
              end.
              create temp-prod-bc.
              buffer-copy buf-prod-bc
              except b-code
              to temp-prod-bc
              assign
              temp-prod-bc.b-code = v-b-code
              temp-prod-bc.gds-code = buf_goods.gds-code
              .
              delete buf-prod-bc.
            end.
            when "gds-obj-attr":U then do:
              {&ii1}
              if not (buf-gds-obj-attr.obj-type = p-old-obj-type
                     and
                     buf-gds-obj-attr.obj-code = p-old-obj-code) then do:
                delete buf-gds-obj-attr.
                next {&next-line}.
              end.
              assign
              buf-gds-obj-attr.obj-type = p-new-obj-type
              buf-gds-obj-attr.obj-code = p-new-obj-code
              .
              create buf-gds-obj-attr.
              {&imp-stream} {&ie-gds-obj-attr-fields} no-error.
              &scop err-mes ~{&errimp-mes~}
              {&wlerimp-mes}
              &scop table-name buf-gds-obj-attr
              find first buf_ext-classif no-lock where
                        buf_ext-classif.classif-subject = {&table_goods}
                   and  buf_ext-classif.classif-name = v-classif-name
                   and buf_ext-classif.key#_one = buf-gds-obj-attr.gds-code no-error.
              if not available buf_ext-classif then do:
                  &scop err-mes (~{&err-mes0~} + " Не найдена запись для баркода в таблице соответствия(gds-obj-attr):" + ~
                                 " Код товара " + string(buf-gds-obj-attr.gds-code) + ~
                                 " Объект " + buf-gds-obj-attr.obj-type + string(buf-gds-obj-attr.obj-code) + ~
                                 " Весовой код " + string(buf-gds-obj-attr.attr-value) )
                  {&wl-mes}
              end.
              RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT buf_ext-classif.uniq-key-rec
                                                  ,input ?
                                                  ,INPUT "ub"
                                                  ,INPUT ? /*p-bh-handle*/
                                                  ,INPUT NO-LOCK
                                                  ,OUTPUT v-rowid
                                                  ,OUTPUT v-tbl-name) no-error.
              if error-status:error then do:
                  &scop err-mes (~{&err-mes0~} + " Ошибка при восстановлении баркода полученного из таблицы соответствия(gds-obj-attr):" + ~
                                 " Код товара " + string(buf-gds-obj-attr.gds-code) + ~
                                 " Объект " + buf-gds-obj-attr.obj-type + string(buf-gds-obj-attr.obj-code) + ~
                                 " Весовой код " + string(buf-gds-obj-attr.attr-value) )
                  {&wl-mes}
              end.
              find first buf_goods no-lock where
                        rowid(buf_goods) = v-rowid no-error.
              if not available buf_goods then do:
                  &scop err-mes (~{&err-mes0~} + " Не найден товар, полученный из таблицы соответствия(gds-obj-attr):" + ~
                                 " Код товара " + string(buf-gds-obj-attr.gds-code) + ~
                                 " Объект " + buf-gds-obj-attr.obj-type + string(buf-gds-obj-attr.obj-code) + ~
                                 " Весовой код " + string(buf-gds-obj-attr.attr-value) )
                  {&wl-mes}
              end.
              IF CAN-FIND(FIRST temp-gds-obj-attr No-LOCK WHERE
                                temp-gds-obj-attr.gds-code = buf_goods.gds-code
                            AND temp-gds-obj-attr.obj-type = buf-gds-obj-attr.obj-type
                            AND temp-gds-obj-attr.obj-code = buf-gds-obj-attr.obj-code
                            AND temp-gds-obj-attr.attr-code = buf-gds-obj-attr.attr-code )
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть атрибут товара ВЕСОВОЙ КОД НА ОБЪЕКТЕ(gds-obj-attr):" + ~
                                 " Старый Код товара " + string(buf-gds-obj-attr.gds-code) + ~
                                 " новый Код товара " + string(buf_goods.gds-code) + ~
                                 " Объект " + buf-gds-obj-attr.obj-type + string(buf-gds-obj-attr.obj-code) + ~
                                 " Весовой код " + string(buf-gds-obj-attr.attr-value) )
                  {&wl-mes}
              end.
              create temp-gds-obj-attr.
              buffer-copy buf-gds-obj-attr except gds-code to temp-gds-obj-attr
              assign
              temp-gds-obj-attr.gds-code = buf_goods.gds-code
              .
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
define variable v-b-code as integer no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .

define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_goods for ub.goods.


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
              assign
              buf-scales.db-num = g#db-num
              .
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
                   {&imp-stream} {&ie-scales-gds-fields} buf-scales-gds.old-gds-code no-error.
                end.
                otherwise do:
                  {&imp-stream} {&ie-scales-gds-fields-123} no-error.
                end.
              END CASE.
              &scop err-mes ~{&errimp-mes~}
              {&wlerimp-mes}
              if not (buf-scales-gds.obj-type = p-old-obj-type
                      and
                      buf-scales-gds.obj-code = p-old-obj-code) then do:
                delete buf-scales-gds.
                next {&next-line}.
              end.
              assign
              buf-scales-gds.obj-type = p-new-obj-type
              buf-scales-gds.obj-code = p-new-obj-code
              buf-scales-gds.db-num = g#db-num
              .

              &scop table-name buf-scales-gds
              find first buf_ext-classif no-lock where
                        buf_ext-classif.classif-subject = {&table_goods}
                   and  buf_ext-classif.classif-name = v-classif-name
                   and buf_ext-classif.key#_one = buf-scales-gds.old-gds-code no-error.
              if not available buf_ext-classif then do:
                  &scop err-mes (~{&err-mes0~} + " Не найдена запись для баркода в таблице соответствия(scales-gds):" + ~
                                 " номер весов " + string(buf-scales-gds.scales-num) + ~
                                 " PLU " + string(buf-scales-gds.PLU-code))
                  {&wl-mes}
              end.
              RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT buf_ext-classif.uniq-key-rec
                                                  ,input ?
                                                  ,INPUT "ub"
                                                  ,INPUT ? /*p-bh-handle*/
                                                  ,INPUT NO-LOCK
                                                  ,OUTPUT v-rowid
                                                  ,OUTPUT v-tbl-name) no-error.
              if error-status:error then do:
                  &scop err-mes (~{&err-mes0~} + " Ошибка при восстановлении баркода полученного из таблицы соответствия(scaels-gds):" + ~
                                 " номер весов " + string(buf-scales-gds.scales-num) + ~
                                 " PLU " + string(buf-scales-gds.PLU-code))

                  {&wl-mes}
              end.
              find first buf_goods no-lock where
                        rowid(buf_goods) = v-rowid no-error.
              if not available buf_goods then do:
                  &scop err-mes (~{&err-mes0~} + " Не найден товар, полученный из таблицы соответствия(scales-gds):" + ~
                                 " номер весов " + string(buf-scales-gds.scales-num) + ~
                                 " PLU " + string(buf-scales-gds.PLU-code))
                  {&wl-mes}
              end.
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
              { gbl/gdsbcode.i buf_goods.gds-code ? v-b-code no-error }
              if error-status:error then do:
                  &scop err-mes (~{&err-mes0~} + " Ошибка при определении главного баркода товара, полученный из таблицы соответствия(prod-bc):" + ~
                                 " номер весов " + string(buf-scales-gds.scales-num) + ~
                                 " PLU " + string(buf-scales-gds.PLU-code))
                  {&wl-mes}
              end.
              IF CAN-FIND(FIRST temp-scales-gds No-LOCK WHERE
                                temp-scales-gds.db-num = buf-scales-gds.db-num AND
                                temp-scales-gds.scales-num = buf-scales-gds.scales-num AND
                                temp-scales-gds.b-code = v-b-code)
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть ТОВАР НА ВЕСАХ(scales-gds):" + ~
                                 " номер весов " + string(buf-scales-gds.scales-num) + ~
                                 " баркод новый" + string(v-b-code) + ~
                                 " баркод старый" + string(buf-scales-gds.b-code))
                  {&wl-mes}
              end.
              create temp-scales-gds.
              buffer-copy buf-scales-gds except b-code to temp-scales-gds
              assign
              temp-scales-gds.b-code = v-b-code
              temp-scales-gds.db-num = (if p-version < "15.0"
                                    then g#db-num
                                    else temp-scales-gds.db-num)
              .
              delete buf-scales-gds.
            end.
            when "scales-grp":U then do:
              next {&next-line}. /*нельзя импортировать - нет соответствия*/
              /*
              {&ii1}
              create buf-scales-grp.
              {&imp-stream} {&ie-scales-grp-fields} no-error.
              &scop err-mes ~{&errimp-mes~}
              {&wlerimp-mes}
              assign
              buf-scales-grp.db-num = g#db-num
              .
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
              */
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


procedure p-cdk-i :
define variable v-b-code as integer no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-fr-type as character no-undo .


  do
  on error undo, return error
  :
&scop next-line _cdk
&scop err-mes0   ("Импорт группы данных КАССЫ, СТРОКА " + string(ii) + ~{&new-line~})
&scop current-data-group "cdk":U
&scop wait-mess "Импорт группы данных КАССЫ"
&scop err-mes (~{&wait-mess~} + " Файл: " + p-dir-name + "\":U + p-db-key + ".":U + ~{&current-data-group~})
  {&wl}
  {&check-file}
  {&ii0}
  if loc#log then do:
    {&waitc}
    {&input-stream}
    _cdk:
    REPEAT:
      {&imp-stream-ss}
      CASE ss:
        when {&Table_cash-desk} then do:
          current-table = ss.
          case current-table:
            when {&table_cash-desk} then do:
              if p-new-obj-type <> {&shop}
              then do:
                next _cdk.
              end.
              v-fr-type = ''.
              {&ii1}
              create buf-cash-desk.
              {&imp-stream} {&ie-cash-desk-fields} no-error.
              &scop err-mes ~{&errimp-mes~}
              {&wlerimp-mes}
              if not (buf-cash-desk.obj-code = p-old-obj-code) then do:
                delete buf-cash-desk.
                next _cdk.
              end.
              assign
              buf-cash-desk.db-num = g#db-num
              buf-cash-desk.obj-code = p-new-obj-code
              .
              &scop table-name buf-cash-desk
              IF CAN-FIND(FIRST temp-cash-desk No-LOCK WHERE
                                temp-cash-desk.db-num = buf-cash-desk.db-num AND
                                temp-cash-desk.obj-code = buf-cash-desk.obj-code AND
                                temp-cash-desk.cash-num = buf-cash-desk.cash-num )
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть КАССА(cash-desk):" + ~
                                 " номер " + string(buf-cash-desk.cash-num))
                  {&wl-mes}
              end.
              create temp-cash-desk.
              buffer-copy buf-cash-desk to temp-cash-desk
              assign
              temp-cash-desk.fr-type = v-fr-type
              .
              delete buf-cash-desk.
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
end procedure. /* p-cdk-i */

procedure p-pet-i :
define variable v-b-code as integer no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_goods for ub.goods.

  do
  on error undo, return error
  :
&scop next-line _pet
&scop err-mes0   ("Импорт группы данных КОНФИГУРАЦИЯ АЗК, СТРОКА " + string(ii) + ~{&new-line~})
&scop current-data-group "pet":U
&scop wait-mess "Импорт группы данных КОНФИГУРАЦИЯ АЗК"
&scop err-mes (~{&wait-mess~} + " Файл: " + p-dir-name + "\":U + p-db-key + ".":U + ~{&current-data-group~})
  {&wl}
  {&check-file}
  {&ii0}
  if loc#log then do:
    {&waitc}
    {&input-stream}
    _pet:
    REPEAT:
      {&imp-stream-ss}
      CASE ss:
        when {&Table_place} then do:
          current-table = ss.
          case current-table:
            when {&table_place} then do:
              if p-new-obj-type <> {&shop} then do:
                next _pet.
              end.
              {&ii1}
              create buf-place.
              {&imp-stream} {&ie-place-fields} no-error.
              &scop err-mes ~{&errimp-mes~}
              {&wlerimp-mes}
              if not (buf-place.obj-type = p-old-obj-type
                      and
                      buf-place.obj-code = p-old-obj-code) then do:
                delete buf-place.
                next _pet.
              end.
              assign
              buf-place.obj-code = p-new-obj-code
              buf-place.obj-type = p-new-obj-type
              .
              &scop table-name buf-place
              IF CAN-FIND(FIRST temp-place No-LOCK WHERE
                                temp-place.obj-code = buf-place.obj-code AND
                                temp-place.obj-type = buf-place.obj-type AND
                                temp-place.pl-code = buf-place.pl-code
                                )
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть СКЛ.МЕСТО(place):" + ~
                                 " номер " + string(buf-place.pl-code) + " на " + buf-place.obj-type + string(buf-place.obj-code))
                  {&wl-mes}
              end.
              IF CAN-FIND(FIRST temp-place No-LOCK WHERE
                                temp-place.pl-code = buf-place.pl-code
                                )
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть СКЛ.МЕСТО(place):" + ~
                                 " номер " + string(buf-place.pl-code) + " на " + buf-place.obj-type + string(buf-place.obj-code))
                  {&wl-mes}
              end.
              create temp-place.
              buffer-copy buf-place to temp-place
              .
              delete buf-place.
            end.
          end CASE.
        end.
        when {&Table_pump} then do:
          current-table = ss.
          case current-table:
            when {&table_pump} then do:
              if p-new-obj-type <> {&shop} then do:
                next _pet.
              end.
              {&ii1}
              create buf-pump.
              {&imp-stream} {&ie-pump-fields} no-error.
              &scop err-mes ~{&errimp-mes~}
              {&wlerimp-mes}
              if not (buf-pump.obj-type = p-old-obj-type
                      and
                      buf-pump.obj-code = p-old-obj-code) then do:
                delete buf-pump.
                next _pet.
              end.
              assign
              buf-pump.obj-code = p-new-obj-code
              buf-pump.obj-type = p-new-obj-type
              .
              &scop table-name buf-pump
              IF CAN-FIND(FIRST temp-pump No-LOCK WHERE
                                temp-pump.obj-code = buf-pump.obj-code AND
                                temp-pump.obj-type = buf-pump.obj-type AND
                                temp-pump.pump-code = buf-pump.pump-code
                                )
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть ТРК(pump):" + ~
                                  " номер " + string(buf-pump.pump-code) + " на " + buf-pump.obj-type + string(buf-pump.obj-code))
                  {&wl-mes}
              end.
              IF CAN-FIND(FIRST temp-pump No-LOCK WHERE
                                temp-pump.pump-code = buf-pump.pump-code
                                )
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть ТРК(pump):" + ~
                                  " номер " + string(buf-pump.pump-code) + " на " + buf-pump.obj-type + string(buf-pump.obj-code))
                  {&wl-mes}
              end.
              create temp-pump.
              buffer-copy buf-pump to temp-pump
              .
              delete buf-pump.
            end.
          end case.
        end. /*when {&Table_pump} then do:*/
        when {&table_nozzle} then do:
          current-table = ss.
          case current-table:
            when {&table_nozzle} then do:
              if p-new-obj-type <> {&shop} then do:
                next _pet.
              end.
              {&ii1}
              create buf-nozzle.
              {&imp-stream} {&ie-nozzle-fields} no-error.
              &scop err-mes ~{&errimp-mes~}
              {&wlerimp-mes}
              if not (buf-nozzle.obj-type = p-old-obj-type
                      and
                      buf-nozzle.obj-code = p-old-obj-code) then do:
                delete buf-nozzle.
                next _pet.
              end.
              assign
              buf-nozzle.obj-code = p-new-obj-code
              buf-nozzle.obj-type = p-new-obj-type
              .
              &scop table-name buf-nozzle
              IF CAN-FIND(FIRST temp-nozzle No-LOCK WHERE
                                temp-nozzle.obj-code = buf-nozzle.obj-code AND
                                temp-nozzle.obj-type = buf-nozzle.obj-type AND
                                temp-nozzle.nozzle-code = buf-nozzle.nozzle-code
                                )
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть пистолет(nozzle):" + ~
                                  " номер " + string(buf-nozzle.nozzle-code) + " на " + buf-nozzle.obj-type + string(buf-nozzle.obj-code))
                  {&wl-mes}
              end.
              IF CAN-FIND(FIRST temp-nozzle No-LOCK WHERE
                                temp-nozzle.nozzle-code = buf-nozzle.nozzle-code
                                )
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть пистолет(nozzle):" + ~
                                  " номер " + string(buf-nozzle.nozzle-code) + " на " + buf-nozzle.obj-type + string(buf-nozzle.obj-code))
                  {&wl-mes}
              end.
              create temp-nozzle.
              buffer-copy buf-nozzle to temp-nozzle
              .
              delete buf-nozzle.
            end.
          end case.
        end. /*when {&table_nozzle} then do:*/
        when {&table_pl-gds} then do:
          current-table = ss.
          case current-table:
            when {&table_pl-gds} then do:
              if p-new-obj-type <> {&shop} then do:
                next _pet.
              end.
              {&ii1}
              create buf-pl-gds.
              {&imp-stream} {&ie-pl-gds-fields} no-error.
              &scop err-mes ~{&errimp-mes~}
              {&wlerimp-mes}
              if not (buf-pl-gds.obj-type = p-old-obj-type
                      and
                      buf-pl-gds.obj-code = p-old-obj-code) then do:
                delete buf-pl-gds.
                next _pet.
              end.
              assign
              buf-pl-gds.obj-code = p-new-obj-code
              buf-pl-gds.obj-type = p-new-obj-type
              .
              &scop table-name buf-pl-gds
              IF CAN-FIND(FIRST temp-pl-gds No-LOCK WHERE
                                temp-pl-gds.obj-code = buf-pl-gds.obj-code AND
                                temp-pl-gds.obj-type = buf-pl-gds.obj-type AND
                                temp-pl-gds.pl-code = buf-pl-gds.pl-code AND
                                temp-pl-gds.gds-code = buf-pl-gds.gds-code
                                )
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть ПРИВЯЗКА К СКЛ.МЕСТУ(pl-gds):" + ~
                                  " код скл.места " + string(buf-pl-gds.pl-code) +  " код товара " + string(buf-pl-gds.gds-code) + " на " + buf-pl-gds.obj-type + string(buf-pl-gds.obj-code))
                  {&wl-mes}
              end.
              create temp-pl-gds.
              buffer-copy buf-pl-gds to temp-pl-gds
              .
              delete buf-pl-gds.
              find first buf_ext-classif no-lock where
                        buf_ext-classif.classif-subject = {&table_goods}
                    and  buf_ext-classif.classif-name = v-classif-name
                    and buf_ext-classif.key#_one = temp-pl-gds.gds-code no-error.
              if not available buf_ext-classif then do:
                  &scop err-mes (~{&err-mes0~} + " Не найдена запись для товара на скл.месте  в таблице соответствия(pl-gds):" + ~
                                  " СклМесто " + string(temp-pl-gds.pl-code) + ~
                                  " Товар " + string(temp-pl-gds.gds-code))
                  {&wl-mes}
              end.
              RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT buf_ext-classif.uniq-key-rec
                                                  ,input ?
                                                  ,INPUT "ub"
                                                  ,INPUT ? /*p-bh-handle*/
                                                  ,INPUT NO-LOCK
                                                  ,OUTPUT v-rowid
                                                  ,OUTPUT v-tbl-name) no-error.
              if error-status:error then do:
                  &scop err-mes (~{&err-mes0~} + " Ошибка при восстановлении товара на скл.месте полученного из таблицы соответствия(pl-gds):" + ~
                                  " СклМесто " + string(temp-pl-gds.pl-code) + ~
                                  " Товар " + string(temp-pl-gds.gds-code))
                  {&wl-mes}
              end.
              find first buf_goods no-lock where
                        rowid(buf_goods) = v-rowid no-error.
              if not available buf_goods then do:
                  &scop err-mes (~{&err-mes0~} + " Не найден товар, полученный из таблицы соответствия(pl-gds):" + ~
                                  " СклМесто " + string(temp-pl-gds.pl-code) + ~
                                  " Товар " + string(temp-pl-gds.gds-code))
                  {&wl-mes}
              end.
              else do:
                temp-pl-gds.gds-code = buf_goods.gds-code.
              end.
            end. /*when {&table_pl-gds} then do:*/
          end case.
        end. /*when {&table_pl-gds} then do:*/
        when {&table_pl-gds-pump} then do:
          current-table = ss.
          case current-table:
            when {&table_pl-gds-pump} then do:
              if p-new-obj-type <> {&shop} then do:
                next _pet.
              end.
              {&ii1}
              create buf-pl-gds-pump.
              {&imp-stream} {&ie-pl-gds-pump-fields} no-error.
              &scop err-mes ~{&errimp-mes~}
              {&wlerimp-mes}
              if not (buf-pl-gds-pump.obj-type = p-old-obj-type
                      and
                      buf-pl-gds-pump.obj-code = p-old-obj-code) then do:
                delete buf-pl-gds-pump.
                next _pet.
              end.
              assign
              buf-pl-gds-pump.obj-code = p-new-obj-code
              buf-pl-gds-pump.obj-type = p-new-obj-type
              .
              &scop table-name buf-pl-gds-pump
              IF CAN-FIND(FIRST temp-pl-gds-pump No-LOCK WHERE
                                temp-pl-gds-pump.obj-code = buf-pl-gds-pump.obj-code AND
                                temp-pl-gds-pump.obj-type = buf-pl-gds-pump.obj-type AND
                                temp-pl-gds-pump.pl-code = buf-pl-gds-pump.pl-code AND
                                temp-pl-gds-pump.gds-code = buf-pl-gds-pump.gds-code AND
                                temp-pl-gds-pump.pump-code = buf-pl-gds-pump.pump-code
                                )
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть ПРИВЯЗКА К СКЛ.МЕСТУ И ТРК(pl-gds-pump):" + ~
                                  " код скл.места " + string(buf-pl-gds-pump.pl-code) + ~
                                  " код товара " + string(buf-pl-gds-pump.gds-code) +  ~
                                  " ТРК " + string(buf-pl-gds-pump.pump-code) + " на " + buf-pl-gds-pump.obj-type + string(buf-pl-gds-pump.obj-code))
                  {&wl-mes}
              end.
              create temp-pl-gds-pump.
              buffer-copy buf-pl-gds-pump to temp-pl-gds-pump
              .
              delete buf-pl-gds-pump.
              find first buf_ext-classif no-lock where
                        buf_ext-classif.classif-subject = {&table_goods}
                    and  buf_ext-classif.classif-name = v-classif-name
                    and buf_ext-classif.key#_one = temp-pl-gds-pump.gds-code no-error.
              if not available buf_ext-classif then do:
                  &scop err-mes (~{&err-mes0~} + " Не найдена запись для товара на скл.месте  в таблице соответствия(pl-gds-pump):" + ~
                                  " СклМесто " + string(temp-pl-gds-pump.pl-code) + ~
                                  " Товар " + string(temp-pl-gds-pump.gds-code) + ~
                                  " ТРК " + string(temp-pl-gds-pump.pump-code) )
                  {&wl-mes}
              end.
              RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT buf_ext-classif.uniq-key-rec
                                                  ,input ?
                                                  ,INPUT "ub"
                                                  ,INPUT ? /*p-bh-handle*/
                                                  ,INPUT NO-LOCK
                                                  ,OUTPUT v-rowid
                                                  ,OUTPUT v-tbl-name) no-error.
              if error-status:error then do:
                  &scop err-mes (~{&err-mes0~} + " Ошибка при восстановлении товара на скл.месте полученного из таблицы соответствия(pl-gds-pump):" + ~
                                  " СклМесто " + string(temp-pl-gds-pump.pl-code) + ~
                                  " Товар " + string(temp-pl-gds-pump.gds-code) + ~
                                  " ТРК " + string(temp-pl-gds-pump.pump-code) )
                  {&wl-mes}
              end.
              find first buf_goods no-lock where
                        rowid(buf_goods) = v-rowid no-error.
              if not available buf_goods then do:
                  &scop err-mes (~{&err-mes0~} + " Не найден товар, полученный из таблицы соответствия(pl-gds-pump):" + ~
                                  " СклМесто " + string(temp-pl-gds-pump.pl-code) + ~
                                  " Товар " + string(temp-pl-gds-pump.gds-code) + ~
                                  " ТРК " + string(temp-pl-gds-pump.pump-code) )
                  {&wl-mes}
              end.
              else do:
                temp-pl-gds-pump.gds-code = buf_goods.gds-code.
              end.
            end. /*when {&table_pl-gds-pump} then do:*/
          end case.
        end. /*when {&table_pl-gds-pump} then do:*/
        when {&table_pl-pump} then do:
          current-table = ss.
          case current-table:
            when {&table_pl-pump} then do:
              if p-new-obj-type <> {&shop} then do:
                next _pet.
              end.
              {&ii1}
              create buf-pl-pump.
              {&imp-stream} {&ie-pl-pump-fields} no-error.
              &scop err-mes ~{&errimp-mes~}
              {&wlerimp-mes}
              if not (buf-pl-pump.obj-type = p-old-obj-type
                      and
                      buf-pl-pump.obj-code = p-old-obj-code) then do:
                delete buf-pl-pump.
                next _pet.
              end.
              assign
              buf-pl-pump.obj-code = p-new-obj-code
              buf-pl-pump.obj-type = p-new-obj-type
              .
              &scop table-name buf-pl-pump
              IF CAN-FIND(FIRST temp-pl-pump No-LOCK WHERE
                                temp-pl-pump.obj-code = buf-pl-pump.obj-code AND
                                temp-pl-pump.obj-type = buf-pl-pump.obj-type AND
                                temp-pl-pump.pl-code = buf-pl-pump.pl-code AND
                                temp-pl-pump.pump-code = buf-pl-pump.pump-code
                                )
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть ПРИВЯЗКА ТРК К СКЛ.МЕСТУ(pl-pump):" + ~
                                  " код скл.места " + string(buf-pl-pump.pl-code) + ~
                                  " ТРК " + string(buf-pl-pump.pump-code) + " на " + buf-pl-pump.obj-type + string(buf-pl-pump.obj-code))
                  {&wl-mes}
              end.
              create temp-pl-pump.
              buffer-copy buf-pl-pump to temp-pl-pump
              .
              delete buf-pl-pump.
            end. /*when {&table_pl-pump} then do:*/
          end case.
        end. /*when {&table_pl-pump} then do:*/
        when {&table_pump-nozzle} then do:
          current-table = ss.
          case current-table:
            when {&table_pump-nozzle} then do:
              if p-new-obj-type <> {&shop} then do:
                next _pet.
              end.
              {&ii1}
              create buf-pump-nozzle.
              {&imp-stream} {&ie-pump-nozzle-fields} no-error.
              &scop err-mes ~{&errimp-mes~}
              {&wlerimp-mes}
              if not (buf-pump-nozzle.obj-type = p-old-obj-type
                      and
                      buf-pump-nozzle.obj-code = p-old-obj-code) then do:
                delete  buf-pump-nozzle.
                next _pet.
              end.
              assign
              buf-pump-nozzle.obj-code = p-new-obj-code
              buf-pump-nozzle.obj-type = p-new-obj-type
              .
              &scop table-name buf-pump-nozzle
              IF CAN-FIND(FIRST temp-pump-nozzle No-LOCK WHERE
                                temp-pump-nozzle.obj-code = buf-pump-nozzle.obj-code AND
                                temp-pump-nozzle.obj-type = buf-pump-nozzle.obj-type AND
                                temp-pump-nozzle.pump-code = buf-pump-nozzle.pump-code AND
                                temp-pump-nozzle.nozzle-code = buf-pump-nozzle.nozzle-code
                                )
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть ПРИВЯЗКА ТРК К ПИСТОЛЕТУ(pump-nozzle):" + ~
                                  " пистолет " + string(buf-pump-nozzle.nozzle-code) + ~
                                  " ТРК " + string(buf-pump-nozzle.pump-code) + " на " + buf-pump-nozzle.obj-type + string(buf-pump-nozzle.obj-code))
                  {&wl-mes}
              end.
              create temp-pump-nozzle.
              buffer-copy buf-pump-nozzle to temp-pump-nozzle
              .
              delete buf-pump-nozzle.
            end. /*when {&table_pump-nozzle} then do:*/
          end case.
        end. /*when {&table_pump-nozzle} then do:*/
        when {&table_pl-pump-nozzle} then do:
          current-table = ss.
          case current-table:
            when {&table_pl-pump-nozzle} then do:
              if p-new-obj-type <> {&shop} then do:
                next _pet.
              end.
              {&ii1}
              create buf-pl-pump-nozzle.
              {&imp-stream} {&ie-pl-pump-nozzle-fields} no-error.
              &scop err-mes ~{&errimp-mes~}
              {&wlerimp-mes}
              if not (buf-pl-pump-nozzle.obj-type = p-old-obj-type
                      and
                      buf-pl-pump-nozzle.obj-code = p-old-obj-code) then do:
                delete  buf-pl-pump-nozzle.
                next _pet.
              end.
              assign
              buf-pl-pump-nozzle.obj-code = p-new-obj-code
              buf-pl-pump-nozzle.obj-type = p-new-obj-type
              .
              &scop table-name buf-pl-pump-nozzle
              IF CAN-FIND(FIRST temp-pl-pump-nozzle No-LOCK WHERE
                                temp-pl-pump-nozzle.obj-code = buf-pl-pump-nozzle.obj-code AND
                                temp-pl-pump-nozzle.obj-type = buf-pl-pump-nozzle.obj-type AND
                                temp-pl-pump-nozzle.pl-code = buf-pl-pump-nozzle.pl-code AND
                                temp-pl-pump-nozzle.pump-code = buf-pl-pump-nozzle.pump-code AND
                                temp-pl-pump-nozzle.nozzle-code = buf-pl-pump-nozzle.nozzle-code
                                )
                                then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть ПРИВЯЗКА ТРК К СКЛ.МЕСТУ и ПИСТОЛЕТУ(pl-pump-nozzle):" + ~
                                  " код скл.места " + string(buf-pl-pump-nozzle.pl-code) + ~
                                  " пистолет " + string(buf-pl-pump-nozzle.nozzle-code) + ~
                                  " ТРК " + string(buf-pl-pump-nozzle.pump-code) + " на " + buf-pl-pump-nozzle.obj-type + string(buf-pl-pump-nozzle.obj-code))
                  {&wl-mes}
              end.
              create temp-pl-pump-nozzle.
              buffer-copy buf-pl-pump-nozzle to temp-pl-pump-nozzle
              .
              delete buf-pl-pump-nozzle.
            end. /*when {&table_pl-pump-nozzle} then do:*/
          end case.
        end. /*when {&table_pl-pump-nozzle} then do:*/
        otherwise do:
        end.
      END CASE.
    END.
    {&close-stream}
  end.
end.
end procedure. /* p-pet-i */




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
                           buf-action-role.db-num = g#db-num.
                           &scop table-name buf-action-role
                           IF CAN-FIND(FIRST temp-action-role No-LOCK
                                       WHERE temp-action-role.db-num    = buf-action-role.db-num
                                         and temp-action-role.action-head-code = buf-action-role.action-head-code
                                         and temp-action-role.action-role-code = buf-action-role.action-role-code
                                       )
                                             then do:
                                 &scop err-mes (~{&err-mes0~} + " Уже есть ПОЛЬЗОВАТЕЛЬ(action-role): " ~
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
                           buf-action-role-item.db-num = g#db-num.
                           &scop table-name buf-action-role-item
                           IF CAN-FIND(FIRST temp-action-role-item No-LOCK
                                       WHERE temp-action-role-item.db-num                = buf-action-role-item.db-num
                                         and temp-action-role-item.action-head-code      = buf-action-role-item.action-head-code
                                         and temp-action-role-item.action-role-code      = buf-action-role-item.action-role-code
                                         and temp-action-role-item.action-role-item-code = buf-action-role-item.action-role-item-code
                                       )
                                             then do:
                                 &scop err-mes (~{&err-mes0~} + " Уже есть ПОЛЬЗОВАТЕЛЬ(action-role-item): " ~
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
                  when "user-action-role":U or
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
                           buf-user-account.user-id = substitute("&1-&2"
                                                                 ,g#db-num
                                                                 , entry(2, buf-user-account.user-id, "-")).
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
                           buf-user-login.db-num = g#db-num.
                           buf-user-login.user-id = substitute("&1-&2"
                                                                 ,g#db-num
                                                                 , entry(2, buf-user-login.user-id, "-")).
                           &scop table-name buf-user-login
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
                           if not (buf-user-obj.obj-type = p-old-obj-type
                                   and
                                   buf-user-obj.obj-code = p-old-obj-code) then do:
                             delete buf-user-obj.
                             next {&next-line}.
                           end.
                           assign
                           buf-user-obj.db-num = g#db-num
                           buf-user-obj.obj-type = p-new-obj-type
                           buf-user-obj.obj-code = p-new-obj-code
                           buf-user-obj.host-code = p-new-host-code
                           buf-user-obj.user-id = substitute("&1-&2"
                                                            ,g#db-num
                                                            ,entry(2, buf-user-obj.user-id, "-"))
                           .
                           &scop table-name buf-user-obj
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
                           if not buf-user-host.host-code = p-old-host-code
                                   then do:
                             delete buf-user-host.
                             next {&next-line}.
                           end.
                           assign
                           buf-user-host.db-num = g#db-num
                           buf-user-host.host-code = p-new-host-code
                           buf-user-host.user-id = substitute("&1-&2"
                                                            ,g#db-num
                                                            ,entry(2, buf-user-host.user-id, "-"))
                           .
                           &scop table-name buf-user-host
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
                           if (buf-user-login-action-role.host-code <> 0
                           and buf-user-login-action-role.host-code <> p-old-host-code) then do:
                             delete buf-user-login-action-role.
                             next {&next-line}.
                           end.
                           if buf-user-login-action-role.obj-code <> 0
                           and not (buf-user-login-action-role.obj-type = p-old-obj-type
                                    and
                                    buf-user-login-action-role.obj-code = p-old-obj-code
                           ) then do:
                             delete buf-user-login-action-role.
                             next {&next-line}.
                           end.
                           assign
                           buf-user-login-action-role.db-num = g#db-num
                           buf-user-login-action-role.obj-type = (if buf-user-login-action-role.obj-code > 0
                                                                  then p-new-obj-type
                                                                  else buf-user-login-action-role.obj-type)
                           buf-user-login-action-role.obj-code = (if buf-user-login-action-role.obj-code > 0
                                                                  then  p-new-obj-code
                                                                  else buf-user-login-action-role.obj-code)
                           buf-user-login-action-role.host-code = (if buf-user-login-action-role.host-code > 0
                                                                  then p-new-host-code
                                                                  else buf-user-login-action-role.host-code)
                           buf-user-login-action-role.user-id = substitute("&1-&2"
                                                            ,g#db-num
                                                            ,entry(2, buf-user-login-action-role.user-id, "-"))
                           .
                           &scop table-name buf-user-login-action-role
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
                           if (buf-user-menu-group.host-code <> 0
                           and buf-user-menu-group.host-code <> p-old-host-code) then do:
                              delete buf-user-menu-group.
                              next {&next-line}.
                           end.
                           if buf-user-menu-group.obj-code <> 0
                           and not (buf-user-menu-group.obj-type = p-old-obj-type
                                    and
                                    buf-user-menu-group.obj-code = p-old-obj-code
                           ) then do:
                             delete buf-user-menu-group.
                              next {&next-line}.
                           end.
                           assign
                           buf-user-menu-group.db-num = g#db-num
                           buf-user-menu-group.obj-type = (if buf-user-menu-group.obj-code > 0
                                                                  then p-new-obj-type
                                                                  else buf-user-menu-group.obj-type)
                           buf-user-menu-group.obj-code = (if buf-user-menu-group.obj-code > 0
                                                                  then  p-new-obj-code
                                                                  else buf-user-menu-group.obj-code)
                           buf-user-menu-group.host-code = (if buf-user-menu-group.host-code > 0
                                                                  then p-new-host-code
                                                                  else buf-user-menu-group.host-code)
                           buf-user-menu-group.user-id = substitute("&1-&2"
                                                            ,g#db-num
                                                            ,entry(2, buf-user-menu-group.user-id, "-"))
                           .
                           &scop table-name buf-user-menu-group
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

procedure p-cdrg-i :

  do
  on error undo, return error
  :
&scop next-line _cdrg
&scop err-mes0   ("Импорт группы данных ДИАПАЗОНЫ ВЕСОВЫХ КОДОВ, СТРОКА " + string(ii) + ~{&new-line~})
&scop current-data-group "cdr":U
&scop wait-mess "Импорт группы данных ДИАПАЗОНЫ ВЕСОВЫХ КОДОВ"
&scop err-mes (~{&wait-mess~} + " Файл: " + p-dir-name + "\":U + p-db-key + ".":U + ~{&current-data-group~})
  {&wl}
  {&check-file}
  {&ii0}
  if loc#log then do:
    {&waitc}
    {&input-stream}
    _cdrg:
    REPEAT:
      {&imp-stream-ss}
      CASE ss:
        when "code-range":U then do:
          current-table = ss.
          case current-table:
            when "code-range":U then do:
              {&ii1}

              create buf-code-range.
              {&imp-stream} {&ie-code-range-fields} no-error.
              &scop err-mes ~{&errimp-mes~}
              {&wlerimp-mes}
              &scop table-name buf-code-range

              find first temp-code-range No-LOCK
                WHERE ( temp-code-range.range-type     = buf-code-range.range-type
                        AND temp-code-range.first-code = buf-code-range.first-code
                      )
                      or
                      ( temp-code-range.range-type     = buf-code-range.range-type
                        AND temp-code-range.last-code = buf-code-range.last-code
                      )
                no-error .
              if available temp-code-range then do:
                  &scop err-mes (~{&err-mes0~} + " Уже есть ДИАПАЗОН КОДОВ (code-range):" + ~
                                 " тип " + buf-code-range.range-type + ~
                                 " начало " + string(buf-code-range.first-code) + ~
                                 " и/или " + ~
                                 " тип " + buf-code-range.range-type + ~
                                 " окончание " + string(buf-code-range.last-code) ~
                                )
                  {&wl-mes}
              end.
              create temp-code-range.
              buffer-copy buf-code-range to temp-code-range.
              delete buf-code-range.
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

end procedure. /* p-cdrg-i */



procedure create-scales-gds :
define parameter buffer bc for ub.bar-code.
define parameter buffer sc for ub.scales.
define parameter buffer goods for ub.goods.
define parameter buffer ltemp-scales-gds  for temp-scales-gds.

define variable ii as integer no-undo.
define variable sc-code like ub.bar-code.b-code no-undo .
define variable v-found as logical no-undo .
define variable v-on as logical no-undo .
define variable v-b-str like ub.prod-bc.b-str no-undo .
define variable f-sc-code as integer no-undo .
define buffer for-pbc for ub.prod-bc.
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
      ub.scales-gds.whole-send-news = ltemp-scales-gds.whole-send-news
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
    run add-right in this-procedure ("cmm",    "acp",                      "update-closed",                           "actn_income_update-closed",                          "object") .
    run add-right in this-procedure ("cmm",    "acp",                      "update-last-date",                        "actn_income_update-last-date",                       "object") .
    run add-right in this-procedure ("cmm",    "alt-barcode",              "preparation",                             "actn_alt-barcode_preparation",                       "global") .
    run add-right in this-procedure ("cmm",    "alt-barcode",              "scgb",                                    "actn_alt-barcode_gbl-sc-code",                       "global") .
    run add-right in this-procedure ("cmm",    "alt-barcode",              "sclc",                                    "actn_alt-barcode_loc-sc-code",                       "global") .
    run add-right in this-procedure ("cmm",    "alt-barcode",              "ssgb",                                    "actn_alt-barcode_gbl-ss-code",                       "global") .
    run add-right in this-procedure ("cmm",    "alt-barcode",              "sslc",                                    "actn_alt-barcode_loc-ss-code",                       "global") .
    run add-right in this-procedure ("cmm",    "alt-barcode",              "turn-on",                                 "actn_alt-barcode_turn-on",                           "global") .
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

procedure convert-thbj-attr-integer-1 :
define input parameter p-old-int as integer no-undo .
define output parameter p-new-int as integer no-undo .

define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .

define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_clients for ub.clients.

find first buf_ext-classif no-lock where
          buf_ext-classif.classif-subject = {&table_clients}
    and  buf_ext-classif.classif-name = v-cli-classif-name
    and buf_ext-classif.key#_one = p-old-int
    and buf_ext-classif.charkey_one = {&prs} no-error.
if not available buf_ext-classif then do:
  return error.
end.
else do:
  run gen-row-keyr in this-procedure (
                                      input  buf_ext-classif.uniq-key-rec
                                      ,input  ? /*p-key-handle буфер записи которую будем искать. если ищем по key-rec то ? */
                                    , input  "ub"
                                    , input  ? /*p-tt-handle  буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
                                    , input  NO-LOCK
                                    , output v-tbl-row
                                    , output v-tbl-name   ) no-error.
  if error-status:error then do:
    return error.
  end.
  find first buf_Clients no-lock where
            rowid(buf_clients) = v-tbl-row no-error.
  if not available buf_clients then do:
    return error.
  end.
  else do:
    assign
    p-new-int = buf_clients.obj-code.
  end.
end.
end procedure. /* convert-thbj-attr-integer-1 */