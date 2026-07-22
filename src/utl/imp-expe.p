block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: imp-expe.p $
$Archive: utl/imp-expe.p $

Процедура экспорта локальных таблиц УБД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/09/05
Author: Bakhtadze Natalya
Creation date: 09/09/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter as character no-undo .

/*p-parameter включает
/*какие группы данных экспортировать*/
define input parameter p-rht as logical no-undo .
define input parameter p-gen as logical no-undo .
define input parameter p-flt as logical no-undo .
define input parameter p-pbc as logical no-undo .
define input parameter p-scl as logical no-undo .
define input parameter p-usr as logical no-undo .
define input parameter p-seq as logical no-undo .
/*ключ БАЗЫ - он же имя файла без расширения*/
define input parameter p-db-key as character no-undo .
/*директория экспорта*/
define input parameter p-dir-name as character no-undo .
*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-expe.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/imp-expe.p $":U .
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
define variable p-glb as logical no-undo .


{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/operfile.i }
define variable log-file-name as character no-undo init "imp-exp.log".
define variable v-view-log as logical no-undo .
{ utl/imp-expd.i }
{ cmp/library.i }
{ ref/gdsoattr.i }
DEFINE VARIABLE v-is-global as logical no-undo .
DEFINE VARIABLE v-is-weight as logical no-undo .
DEFINE VARIABLE v-is-scaleable as logical no-undo .
DEFINE VARIABLE v-is-pgweight as logical no-undo .
DEFINE VARIABLE r-bar-code like ub.bar-code.b-code no-undo .

define buffer buf-sys-ctrl     for ub.sys-ctrl .
define buffer buf-config       for ub.config .
define buffer buf_goods        for ub.goods .
define buffer buf_units        for ub.units .
define buffer buf_cli_units    for ub.units .
define buffer buf_bar-code     for ub.bar-code .
define buffer buf-prod-bc      for ub.prod-bc .
define buffer buf_prod-bc      for ub.prod-bc .
define buffer buf_clients      for ub.clients .
define buffer buf-gds-obj-attr for ub.gds-obj-attr .
define buffer buf_gds-prt      for ub.gds-prt .
define buffer buf-scales       for ub.scales .
define buffer buf-scales-gds   for ub.scales-gds .
define buffer buf-scales-grp   for ub.scales-grp .
define buffer buf-filter       for ubflt.filter .
define buffer buf-cash-desk    for ub.cash-desk .
define buffer buf-curr-shop    for ub.curr-shop .
define buffer buf-usr-flt      for ubflt.usr-flt .
define buffer buf-user-account            for ub.user-account.
define buffer buf-user-login              for ub.user-login.
define buffer buf-user-obj                for ub.user-obj.
define buffer buf-user-host               for ub.user-host.
define buffer buf-user-menu-group         for ub.user-menu-group.
define buffer buf-user-login-action-role  for ub.user-login-action-role.
define buffer buf-action-role             for ub.action-role.
define buffer buf-action-role-item        for ub.action-role-item.


DEFINE VARIABLE v-seq-val as int64 no-undo .

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
no-error
.
if error-status:error then return error substitute("&1 &2", error-status:get-message(1) , return-value ).


define stream Outstream.
&scop output-stream  output stream OUTstream to value(p-dir-name + "\":U + corr-file-name(p-db-key) + ".":U + ~{&current-data-group~}).
&scop close-stream   output stream OutStream close.
&scop p-stream       put stream outstream unformatted
&scop exp-stream      export stream outstream

&scop err-mes " Экспорт локальных таблиц"
{&wl}


if p-gen then do:
&scop current-data-group "gen":U
&scop wait-mess "Экспорт группы данных НАСТРОЙКИ БД"
&scop err-mes (~{&wait-mess~} + " Файл: " + p-dir-name + "\":U + corr-file-name(p-db-key) + ".":U + ~{&current-data-group~})
  {&wl}
  {&waitc}
  {&output-stream}
/*
  FOR EACH buf-sys-ctrl No-LOCK:
    {&p-stream}
    "sys-ctrl":U skip.
    {&exp-stream}
    {&ie-sys-ctrl-fields}
    .
  END.
*/
  FOR EACH buf-config No-LOCK:
    if lookup( buf-config.conf-type, {&cnf-type-list-protect} ) > 0 then NEXT.
    {&p-stream}
    "config":U skip.
    {&exp-stream}
    {&ie-config-fields}
    .
  END.
   {&close-stream}
end.
if p-flt then do:
&scop current-data-group "flt":U
&scop wait-mess "Экспорт группы данных ФИЛЬТРЫ"
&scop err-mes (~{&wait-mess~} + " Файл: " + p-dir-name + "\":U + corr-file-name(p-db-key) + ".":U + ~{&current-data-group~})
  {&wl}
  {&waitc}
   {&output-stream}
  FOR EACH buf-filter No-LOCK:
    {&p-stream}
    "filter":U skip.
    {&exp-stream}
    {&ie-filter-fields}
    .
  END.
  {&close-stream}
end.
if p-pbc then do:
&scop current-data-group "pbc":U
&scop wait-mess "Экспорт группы данных ВЕС И ВЗВЕШ КОДЫ"
&scop err-mes (~{&wait-mess~} + " Файл: " + p-dir-name + "\":U + corr-file-name(p-db-key) + ".":U + ~{&current-data-group~})
  find first buf-sys-ctrl no-lock.
  {&wl}
  {&waitc}
   {&output-stream}
  _goods:
  for each buf_goods no-lock,
      first buf_units no-lock where
            buf_units.type = {&weight}
        AND buf_units.unit-name = buf_goods.unit-base
          :
    { gbl/gdsbcode.i buf_goods.gds-code ? r-bar-code no-error }
    if error-status:error then dO:
      NEXT _goods.
    end.
    _pbc1:
    for each buf-prod-bc no-lock where
            buf-prod-bc.b-code = r-bar-code :
      assign
      v-is-global = no
      v-is-weight = no
      .
       /*проверим что это весовой локальный код*/
      { gbl/prodbcat.i buf-prod-bc 'global=request':U v-is-global  }
      if error-status:error
      or (v-is-global
         and
         p-glb = no)
      then do:
        next _pbc1.
      end.
      { gbl/prodbcat.i buf-prod-bc 'weight=request':U v-is-weight  }
      if error-status:error or not v-is-weight then do:
        next _pbc1.
      end.
      {&p-stream}
      "prod-bc":U skip.
      {&exp-stream}
      {&ie-prod-bc-fields}
      .
    END.
    find first buf_gds-prt no-lock where
              buf_gds-prt.upper-code = buf_goods.prt-root no-error .
    if not avail buf_gds-prt then NEXT _goods.
    for each buf_bar-code no-lock where
            buf_bar-code.gds-code = buf_goods.gds-code
        AND buf_bar-code.in-code = "":U
        AND buf_bar-code.part-code = "":U
        AND buf_bar-code.node-code = buf_gds-prt.node-code
        AND buf_bar-code.unit-cli <> buf_goods.unit-base,
      first buf_clI_units no-lock where
            buf_cli_units.type = {&divisional}
         AND buf_cli_units.unit-name = buf_bar-code.unit-cli:
      _pbc2:
      for each Buf-prod-bc no-lock where
              buf-prod-bc.b-code = buf_bar-code.b-code:
        /*проверим что это взвешиваемый локальный код*/
        assign
        v-is-global = no
        v-is-scaleable = no
        .
        /*проверим что это весовой локальный код*/
        { gbl/prodbcat.i buf-prod-bc 'global=request':U v-is-global no-error }
        if error-status:error or v-is-global then next _pbc2.
        { gbl/prodbcat.i buf-prod-bc 'scaleable=request':U v-is-scaleable no-error }
        if error-status:error or not v-is-scaleable then next _pbc2.
        {&p-stream}
        "prod-bc":U skip.
        {&exp-stream}
        {&ie-prod-bc-fields}
        .
      end.
    end.
    /*выгрузим также все gds-obj-attr where gds-obj-attr.attr-code = {&attr-scales-code-o}*/
    for each buf_clients no-lock where
            buf_clients.db-num = buf-sys-ctrl.db-num,
        first buf-gds-obj-attr no-lock where
            buf-gds-obj-attr.gds-code = buf_goods.gds-code
        AND buf-gds-obj-attr.obj-type = buf_clients.obj-type
        AND buf-gds-obj-attr.obj-code = buf_clients.obj-code
        AND buf-gds-obj-attr.attr-code = {&attr-scales-code-o}
        :
        {&p-stream}
        "gds-obj-attr":U skip.
        {&exp-stream}
        {&ie-gds-obj-attr-fields}
        .
     end.
  end. /*for each goods*/
  /*выгружаем пирожковые коды*/
  /*заход от code-range*/
  _pbc2:
  for each buf-prod-bc no-lock where
                buf-prod-bc.b-str >= "00100"
            and buf-prod-bc.b-str <= "99999"
            and buf-prod-bc.bc-on-type = {&loc-pg-code}
            and length(buf-prod-bc.b-str) = 5,
     first buf_bar-code no-lock  where
          buf_bar-code.b-code = buf-prod-bc.b-code,
     first buf_goods no-lock where
          buf_goods.gds-code = buf_bar-code.gds-code:


    { gbl/prodbcat.i buf-prod-bc 'pgweight=request':U v-is-pgweight  }
    if error-status:error or not v-is-pgweight then do:
      next _pbc2.
    end.
    {&p-stream}
    "prod-bc":U skip.
    {&exp-stream}
    {&ie-prod-bc-fields}
     .
    /*выгрузим также все gds-obj-attr where gds-obj-attr.attr-code = {&attr-scales-code-o}*/
    for each buf_clients no-lock where
            buf_clients.db-num = buf-sys-ctrl.db-num,
        first buf-gds-obj-attr no-lock where
            buf-gds-obj-attr.gds-code = buf_goods.gds-code
        AND buf-gds-obj-attr.obj-type = buf_clients.obj-type
        AND buf-gds-obj-attr.obj-code = buf_clients.obj-code
        AND buf-gds-obj-attr.attr-code = {&attr-scales-code-o}
        :
        {&p-stream}
        "gds-obj-attr":U skip.
        {&exp-stream}
        {&ie-gds-obj-attr-fields}
        .
     end.
  end.
  {&close-stream}
end.
if p-scl then do:
&scop current-data-group "scl":U
&scop wait-mess "Экспорт группы данных ВЕСЫ"
&scop err-mes (~{&wait-mess~} + " Файл: " + p-dir-name + "\":U + corr-file-name(p-db-key) + ".":U + ~{&current-data-group~})
  {&wl}
  {&waitc}
   {&output-stream}
  FOR EACH buf-scales No-LOCK:
    {&p-stream}
    "scales":U skip.
    {&exp-stream}
    {&ie-scales-fields}
    .
  END.
  FOR EACH buf-scales-gds No-LOCK:
    {&p-stream}
    "scales-gds":U skip.
    {&exp-stream}
    {&ie-scales-gds-fields}
    .
  END.
  FOR EACH buf-scales-grp No-LOCK:
    {&p-stream}
    "scales-grp":U skip.
    {&exp-stream}
    {&ie-scales-grp-fields}
    .
  END.
  {&close-stream}
end.
if p-usr then do:
&scop current-data-group "rht":U
&scop wait-mess "Экспорт группы данных ПРАВА"
&scop err-mes (~{&wait-mess~} + " Файл: " + p-dir-name + "\":U + corr-file-name(p-db-key) + ".":U + ~{&current-data-group~})
  {&wl}
  {&waitc}
  {&output-stream}
  FOR EACH buf-action-role No-LOCK:
    {&p-stream}
    "action-role":U skip.
    {&exp-stream}
    {&ie-action-role-fields}
    .
  END.
  FOR EACH buf-action-role-item No-LOCK:
    {&p-stream}
    "action-role-item":U skip.
    {&exp-stream}
    {&ie-action-role-item-fields}
    .
  END.
  {&close-stream}
end.
if p-usr then do:
&scop current-data-group "usr":U
&scop wait-mess "Экспорт группы данных ПОЛЬЗОВАТЕЛИ"
&scop err-mes (~{&wait-mess~} + " Файл: " + p-dir-name + "\":U + corr-file-name(p-db-key) + ".":U + ~{&current-data-group~})
  {&wl}
  {&waitc}
   {&output-stream}
    FOR EACH buf-user-account No-LOCK:
    {&p-stream}
    "user-account":U skip.
    {&exp-stream}
    {&ie-user-account-fields}
    .
  END.
  FOR EACH buf-user-login No-LOCK:
    {&p-stream}
    "user-login":U skip.
    {&exp-stream}
    {&ie-user-login-fields}
    .
  END.
  FOR EACH buf-user-obj No-LOCK:
    {&p-stream}
    "user-obj":U skip.
    {&exp-stream}
    {&ie-user-obj-fields}
    .
  END.
  FOR EACH buf-user-host No-LOCK:
    {&p-stream}
    "user-host":U skip.
    {&exp-stream}
    {&ie-user-host-fields}
    .
  END.
  FOR EACH buf-user-menu-group No-LOCK:
    {&p-stream}
    "user-menu-group":U skip.
    {&exp-stream}
    {&ie-user-menu-group-fields}
    .
  END.
  FOR EACH buf-user-login-action-role No-LOCK:
    {&p-stream}
    "user-login-action-role":U skip.
    {&exp-stream}
    {&ie-user-login-action-role-fields}
    .
  END.
  FOR EACH buf-usr-flt No-LOCK:
    {&p-stream}
    "usr-flt":U skip.
    {&exp-stream}
    {&ie-usr-flt-fields}
    .
  END.
  {&close-stream}
end.
if p-seq then do:
&scop current-data-group "seq":U
&scop wait-mess "Экспорт группы данных СЧЕТЧИКИ"
&scop err-mes (~{&wait-mess~} + " Файл: " + p-dir-name + "\":U + corr-file-name(p-db-key) + ".":U + ~{&current-data-group~})
  {&wl}
  {&waitc}
   {&output-stream}
   _seq:
   FOR EACH {&db-name_schema}._sequence No-LOCK :
    assign
      v-seq-val = dynamic-current-value( {&db-name_schema}._sequence._seq-name, "{&db-name_schema}":U )
    .
    {&p-stream}
    "sequence":U skip.
    {&exp-stream}
    {&db-name_schema}._sequence._seq-name
    v-seq-val
    .
  END.
END.