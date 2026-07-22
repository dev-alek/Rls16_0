block-level on error undo, throw.
/*

$Revision: d58b016346f1, 2327, rls $
$Author: druban $
$Date: Ср июн 10 21:13:32 2020 +0300 $
$Workfile: initftbl.p $
$Archive: adm/initftbl.p $

Начальная инициализация справочников

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/
define input parameter loc_db-num as integer   no-undo . /* номер базы данных */
define input parameter p-language as character no-undo . /* язык */
define input parameter p-r-b      as character no-undo . /* валюта прайс-листа */
define input parameter p-sys-key  as character no-undo . /* системный ключ */
define input parameter p-extra-to as integer   no-undo . /* раскрутка под: 0=ниподкого, 1="1С", 2= */ 

define variable vss-revision    as character no-undo init "$Revision: d58b016346f1, 2327, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:32 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: initftbl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/initftbl.p $":U .
define variable vss-description as character no-undo init "Начальная инициализация справочников".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

&scop new-ver-num "v16_0000.000.000":U

do
on error undo, return error
:

  disable triggers for load of DICTDB.db.
  disable triggers for load of DICTDB.db-attr.
  disable triggers for load of DICTDB.cli-grp.
  disable triggers for load of DICTDB.gds-grp.
  disable triggers for load of DICTDB.fbr-gds-grp.
  disable triggers for load of DICTDB.gds-prt.
  disable triggers for load of DICTDB.hist-nws-option.
  disable triggers for load of DICTDB.code-range.
  disable triggers for load of DICTDB.upgrade.

  define buffer buf_sys-ctrl for DICTDB.sys-ctrl .
  define buffer buf_db      for DICTDB.db .
  define buffer buf_db-attr for DICTDB.db-attr .
  define buffer buf_cli-grp for DICTDB.cli-grp .
  define buffer buf_gds-grp for DICTDB.gds-grp .
  define buffer buf_fbr-gds-grp for DICTDB.fbr-gds-grp .
  define buffer buf_gds-prt for DICTDB.gds-prt .
  define buffer buf_hist-nws-option for DICTDB.hist-nws-option.
  define buffer buf_code-range      for DICTDB.code-range .

  define variable seq-val as integer no-undo .

  create buf_sys-ctrl.
  assign
    buf_sys-ctrl.db-num   = loc_db-num
    buf_sys-ctrl.sys-date = today
    buf_sys-ctrl.sys-key  = p-sys-key
    buf_sys-ctrl.language = p-language
    buf_sys-ctrl.r-b      = p-r-b
  .

  /* В ГБД в табл. db содержатся все БД (добавляются из АРМ Адм и не ходят по новостям),
                  в т.ч. ГБД (добавляется здесь);
      в УБД в табл. db содержится только ГБД (добавляется здесь) */
  create buf_db.
  assign
    buf_db.db-num      = 0
    buf_db.db-name     = "Главная БД" /* db.db-name = "Cartea DB" */
    /* по умолчанию в обычной ГБД флажок добавления клиентов не проставлялся; для раскрутки под 1С его надо проставлять */
    buf_db.add-clients = true when (p-extra-to = 1) 
  .
  if p-extra-to = 1 then do:
    /* к записи о ГБД - запись о точке интеграции */
    create buf_db-attr .
    assign
      buf_db-attr.db-num     = 0
      buf_db-attr.attr-code  = {&attr-int-point}
      buf_db-attr.attr-value = "00001":U
    .
  end.
  
  /*инициализация записи о версии TH для гбд первоночальным запускм*/
  if loc_db-num = 0
  then do:
    find first ub.sys-ctrl where ub.sys-ctrl.db-num = 0 no-lock .
    create ub.upgrade.
        assign
          ub.upgrade.db-num      = ub.sys-ctrl.db-num
          ub.upgrade.version-num = {&new-ver-num}
          ub.upgrade.version-ord = next-value( s-upg-ord, ub )
        .
    assign
      ub.upgrade.step-num    = step-num
      ub.upgrade.err-msgs    = "":U
      ub.upgrade.err-code    = 0
      ub.upgrade.complete    = false
      ub.upgrade.UpgDate     = today
      ub.upgrade.UpgTimeInt  = time
      ub.upgrade.UpgTime     = string( time, "HH:MM:SS" )
    .
  end.


  /*____________ дерево клиентов _____________________*/
  create buf_cli-grp.
  assign
    buf_cli-grp.upper-code = 0
    buf_cli-grp.node-code  = 1
    buf_cli-grp.node-name  = "Клиенты" /* &IF "rom" &THEN  cli-grp.node-name = "Clienti" */
    dynamic-current-value( "s-cli-grp":U, LDBNAME("DICTDB":U) ) = 1
  .
  validate buf_cli-grp.
  if p-extra-to = 1 then do:
    /* с техносервом договорились, что группы клиентов нам не передают;
       мы сами создаём:
       2 - Фирмы, Объекты
       3 - Поставщики
       4 – Физ.лица
       5 – Технологические контрагенты
       наши технологические клиенты будут в диапазоне кодов 9 000 000, в группе 5 */
    create buf_cli-grp.
    assign
      buf_cli-grp.upper-code = 1
      buf_cli-grp.node-code  = 2
      buf_cli-grp.node-name  = "Фирмы, Объекты"
    .
    validate buf_cli-grp.
    create buf_cli-grp.
    assign
      buf_cli-grp.upper-code = 1
      buf_cli-grp.node-code  = 3
      buf_cli-grp.node-name  = "Поставщики"
    .
    validate buf_cli-grp.
    create buf_cli-grp.
    assign
      buf_cli-grp.upper-code = 1
      buf_cli-grp.node-code  = 4
      buf_cli-grp.node-name  = "Физ.лица"
    .
    validate buf_cli-grp.
    create buf_cli-grp.
    assign
      buf_cli-grp.upper-code = 1
      buf_cli-grp.node-code  = 5
      buf_cli-grp.node-name  = "Технологические контрагенты"
      dynamic-current-value( "s-cli-grp":U, LDBNAME("DICTDB":U) ) = 5
    .
    validate buf_cli-grp.
  end. /* end_of группы клиентов для p-extra-to = 1 */
  
  /*____________ дерево товаров _____________________*/
  create buf_gds-grp.
  assign
    buf_gds-grp.upper-code = 0
    buf_gds-grp.node-code  = 1
    buf_gds-grp.node-name  = "Товары" /* &IF "rom" &THEN gds-grp.node-name = "Marfuri" */
    buf_gds-grp.calc-method = {&pr-calc-fix}
    dynamic-current-value( "s-gds-grp":U, LDBNAME("DICTDB":U) ) = 1
  .

  create buf_fbr-gds-grp.
  assign
    buf_fbr-gds-grp.upper-code = 0
    buf_fbr-gds-grp.node-code  = 1
    buf_fbr-gds-grp.node-name  = "Блюда"
    buf_fbr-gds-grp.host-code  = 0
    buf_fbr-gds-grp.obj-type   = ""
    buf_fbr-gds-grp.obj-code   = 0
    buf_fbr-gds-grp.out-code   = 0
  .

  /*____________ пустая шкала _____________________*/
  create buf_gds-prt .
  assign
    buf_gds-prt.upper-code = 0
    buf_gds-prt.node-code  = 1
    buf_gds-prt.node-name  = {&empty-scale}
    buf_gds-prt.root       = yes
    buf_gds-prt.prt-root   = buf_gds-prt.upper-code
    buf_gds-prt.is-term    = true
    dynamic-current-value( "s-gds-prt":U, LDBNAME("DICTDB":U) ) = 1
  .

  create buf_hist-nws-option .
  assign
    buf_hist-nws-option.table-name = '':U
    buf_hist-nws-option.subject-group = '':U
    buf_hist-nws-option.db-num = loc_db-num
    buf_hist-nws-option.smart-nws = integer({&hn-is-off})
    buf_hist-nws-option.nws-to-hist = integer({&hn-is-on})
    buf_hist-nws-option.nws-to-cd = integer({&hn-is-on})
    buf_hist-nws-option.hist-to-nws = integer({&hn-is-on})
    buf_hist-nws-option.hist-from-prim = integer({&hn-is-on})
    buf_hist-nws-option.get-hist-from-nws = integer({&hn-is-on})
    buf_hist-nws-option.fill-option = '':U
    buf_hist-nws-option.hn-id = 0
   dynamic-current-value( "s-hn-id":U, LDBNAME("DICTDB":U) ) = 1
  .


  /* создание интервалов для code-range */
  if loc_db-num = 0 then do:

    create buf_code-range.
    assign
      buf_code-range.range-type = {&loc-pt-code}
      buf_code-range.PS         = "топливный код"
      buf_code-range.beg-date   = today
      buf_code-range.first-code = 1
      buf_code-range.last-code  = 99
      buf_code-range.db-num = loc_db-num
      buf_code-range.stts = "u":U
    .

    create buf_code-range.
    assign
      buf_code-range.range-type = {&loc-sc-code}
      buf_code-range.PS         = "локальный весовой код"
      buf_code-range.beg-date   = today
      buf_code-range.first-code = 100
      buf_code-range.last-code  = 999
      buf_code-range.db-num = loc_db-num
      buf_code-range.stts = "a":U
      dynamic-current-value( "s-sclc-code":U, LDBNAME("DICTDB":U) ) = buf_code-range.first-code - 1
    .

    /* границы интервалов для выгрузки в ЕРП-1С:
       - технологические = 900 000 000,
       - товары          = 999 999 999
    */
    define variable v-last-code as integer no-undo .
    
    v-last-code = (  if p-extra-to = 1 then 999999999
                                       else (if p-sys-key <> "raimbek":U then 199999 else 2000000000)  ) .
    create buf_code-range.
    assign
      buf_code-range.range-type = {&gbl-bc-code}
      buf_code-range.PS         = "авто"
      buf_code-range.beg-date   = today
      buf_code-range.first-code = 100000
      buf_code-range.last-code  = v-last-code
      buf_code-range.db-num = loc_db-num
      buf_code-range.stts = "a":U
      dynamic-current-value( "s-bcgb-code":U, LDBNAME("DICTDB":U) ) =
       (if p-sys-key <> "raimbek":U  and p-extra-to <> 1 then buf_code-range.first-code - 1 else buf_code-range.last-code + 1 )
    .
    if p-extra-to = 1 then do:
       buf_code-range.stts = "u".
       create buf_code-range.
       assign
         buf_code-range.range-type = {&gbl-bc-code}
         buf_code-range.PS         = "авто"
         buf_code-range.beg-date   = today
         buf_code-range.first-code = 1000000000
         buf_code-range.last-code  = 2000000000
         buf_code-range.db-num = loc_db-num
         buf_code-range.stts = "a":U
         dynamic-current-value( "s-bcgb-code":U, LDBNAME("DICTDB":U) ) =
            (if p-sys-key <> "raimbek":U  and p-extra-to <> 1 then buf_code-range.first-code - 1 else buf_code-range.last-code + 1 )
       .
    end.
    create buf_code-range.
    assign
      buf_code-range.range-type = {&gbl-dc-code}
      buf_code-range.PS         = "авто"
      buf_code-range.beg-date   = today
      buf_code-range.first-code = 1
      buf_code-range.last-code  = 99999
      buf_code-range.db-num = loc_db-num
      buf_code-range.stts = "a":U
      dynamic-current-value( "s-dcgb-code":U, LDBNAME("DICTDB":U) ) = buf_code-range.first-code
    .

    create buf_code-range.
    assign
      buf_code-range.range-type = {&gbl-fm-code}
      buf_code-range.PS         = "авто"
      buf_code-range.beg-date   = today
      buf_code-range.first-code = 1
      buf_code-range.last-code  = 999
      buf_code-range.db-num = 0
      buf_code-range.stts = "u":U
    .
    v-last-code = ( if (p-sys-key  = "raimbek":U) or
                       (p-extra-to = 1) then 2000000000 else 99999 ). 
    create buf_code-range.
    assign
      buf_code-range.range-type = {&gbl-fm-code}
      buf_code-range.PS         = "авто"
      buf_code-range.beg-date   = today
      buf_code-range.first-code = 1000
      buf_code-range.last-code  = v-last-code
      buf_code-range.db-num = 0
      buf_code-range.stts = "a":U
      dynamic-current-value( "s-fmgb-code":U, LDBNAME("DICTDB":U) ) =
       (if (p-sys-key  = "raimbek":U) or
           (p-extra-to = 1) then buf_code-range.last-code + 1 else buf_code-range.first-code - 1 )
    .

    create buf_code-range.
    assign
      buf_code-range.range-type = {&gbl-pn-code}
      buf_code-range.PS         = "авто"
      buf_code-range.beg-date   = today
      buf_code-range.first-code = 1
      buf_code-range.last-code  = ( if p-sys-key <> "raimbek":U then 99999 else 2000000000 )
      buf_code-range.db-num = 0
      buf_code-range.stts = "a":U
      dynamic-current-value( "s-pngb-code":U, LDBNAME("DICTDB":U) ) = (if p-sys-key <> "raimbek":U then buf_code-range.first-code else buf_code-range.last-code + 1 )
    .

    create buf_code-range.
    assign
      buf_code-range.range-type = {&gbl-dr-code}
      buf_code-range.PS         = "авто"
      buf_code-range.beg-date   = today
      buf_code-range.first-code = 1
      buf_code-range.last-code  = 99999
      buf_code-range.db-num = 0
      buf_code-range.stts = "l":U
    .


    create buf_code-range.
    assign
      buf_code-range.range-type = {&gbl-dr-code}
      buf_code-range.PS         = "авто"
      buf_code-range.beg-date   = today
      buf_code-range.first-code = 100000
      buf_code-range.last-code  = 199999
      buf_code-range.db-num = loc_db-num
      buf_code-range.stts = "a":U
      dynamic-current-value( "s-drgb-code":U, LDBNAME("DICTDB":U) ) = buf_code-range.first-code - 1
    .

    create buf_code-range.
    assign
      buf_code-range.range-type = {&gbl-ct-code}
      buf_code-range.PS         = "авто"
      buf_code-range.beg-date   = today
      buf_code-range.first-code = 1
      buf_code-range.last-code  = ( if p-sys-key <> "raimbek":U then 1999 else 2000000000 )
      buf_code-range.db-num = loc_db-num
      buf_code-range.stts = "a":U
      dynamic-current-value( "s-ctgb-code":U, LDBNAME("DICTDB":U) ) = (if p-sys-key <> "raimbek":U then buf_code-range.first-code else buf_code-range.last-code + 1 )
    .


    create buf_code-range.
    assign
      buf_code-range.range-type = {&gbl-ca-code}
      buf_code-range.PS         = "авто"
      buf_code-range.beg-date   = today
      buf_code-range.first-code = 1
      buf_code-range.last-code  = 99999
      buf_code-range.db-num = loc_db-num
      buf_code-range.stts = "a":U
      dynamic-current-value( "s-cagb-code":U, LDBNAME("DICTDB":U) ) = buf_code-range.first-code
    .
    create buf_code-range.
    assign
      buf_code-range.range-type = {&gbl-fd-code}
      buf_code-range.PS         = "авто"
      buf_code-range.beg-date   = today
      buf_code-range.first-code = 1
      buf_code-range.last-code  = 999
      buf_code-range.db-num = 0
      buf_code-range.stts = "a":U
      dynamic-current-value( "s-fin-doc":U, LDBNAME("DICTDB":U) ) = buf_code-range.first-code
    .

  end.
end.
return.