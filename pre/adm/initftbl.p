block-level on error undo, throw.
define input parameter loc_db-num as integer   no-undo .
define input parameter p-language as character no-undo .
define input parameter p-r-b      as character no-undo .
define input parameter p-sys-key  as character no-undo .
define input parameter p-extra-to as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: d58b016346f1, 2327, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:32 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: initftbl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/initftbl.p $":U .
define variable vss-description as character no-undo init "Начальная инициализация справочников".
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
  create buf_db.
  assign
    buf_db.db-num      = 0
    buf_db.db-name     = "Главная БД"
    buf_db.add-clients = true when (p-extra-to = 1)
  .
  if p-extra-to = 1 then do:
    create buf_db-attr .
    assign
      buf_db-attr.db-num     = 0
      buf_db-attr.attr-code  = 'int-point':U
      buf_db-attr.attr-value = "00001":U
    .
  end.
  if loc_db-num = 0
  then do:
    find first ub.sys-ctrl where ub.sys-ctrl.db-num = 0 no-lock .
    create ub.upgrade.
        assign
          ub.upgrade.db-num      = ub.sys-ctrl.db-num
          ub.upgrade.version-num = "v16_0000.000.000":U
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
  create buf_cli-grp.
  assign
    buf_cli-grp.upper-code = 0
    buf_cli-grp.node-code  = 1
    buf_cli-grp.node-name  = "Клиенты"
    dynamic-current-value( "s-cli-grp":U, LDBNAME("DICTDB":U) ) = 1
  .
  validate buf_cli-grp.
  if p-extra-to = 1 then do:
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
  end.
  create buf_gds-grp.
  assign
    buf_gds-grp.upper-code = 0
    buf_gds-grp.node-code  = 1
    buf_gds-grp.node-name  = "Товары"
    buf_gds-grp.calc-method = 'Не-считать':U
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
  create buf_gds-prt .
  assign
    buf_gds-prt.upper-code = 0
    buf_gds-prt.node-code  = 1
    buf_gds-prt.node-name  = '_Пустая шкала':U
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
    buf_hist-nws-option.smart-nws = integer('-1':U)
    buf_hist-nws-option.nws-to-hist = integer('0':U)
    buf_hist-nws-option.nws-to-cd = integer('0':U)
    buf_hist-nws-option.hist-to-nws = integer('0':U)
    buf_hist-nws-option.hist-from-prim = integer('0':U)
    buf_hist-nws-option.get-hist-from-nws = integer('0':U)
    buf_hist-nws-option.fill-option = '':U
    buf_hist-nws-option.hn-id = 0
   dynamic-current-value( "s-hn-id":U, LDBNAME("DICTDB":U) ) = 1
  .
  if loc_db-num = 0 then do:
    create buf_code-range.
    assign
      buf_code-range.range-type = 'ptlc':U
      buf_code-range.PS         = "топливный код"
      buf_code-range.beg-date   = today
      buf_code-range.first-code = 1
      buf_code-range.last-code  = 99
      buf_code-range.db-num = loc_db-num
      buf_code-range.stts = "u":U
    .
    create buf_code-range.
    assign
      buf_code-range.range-type = 'sclc':U
      buf_code-range.PS         = "локальный весовой код"
      buf_code-range.beg-date   = today
      buf_code-range.first-code = 100
      buf_code-range.last-code  = 999
      buf_code-range.db-num = loc_db-num
      buf_code-range.stts = "a":U
      dynamic-current-value( "s-sclc-code":U, LDBNAME("DICTDB":U) ) = buf_code-range.first-code - 1
    .
    define variable v-last-code as integer no-undo .
    v-last-code = (  if p-extra-to = 1 then 999999999
                                       else (if p-sys-key <> "raimbek":U then 199999 else 2000000000)  ) .
    create buf_code-range.
    assign
      buf_code-range.range-type = 'bcgb':U
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
         buf_code-range.range-type = 'bcgb':U
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
      buf_code-range.range-type = 'dcgb':U
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
      buf_code-range.range-type = 'fmgb':U
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
      buf_code-range.range-type = 'fmgb':U
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
      buf_code-range.range-type = 'pngb':U
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
      buf_code-range.range-type = 'drgb':U
      buf_code-range.PS         = "авто"
      buf_code-range.beg-date   = today
      buf_code-range.first-code = 1
      buf_code-range.last-code  = 99999
      buf_code-range.db-num = 0
      buf_code-range.stts = "l":U
    .
    create buf_code-range.
    assign
      buf_code-range.range-type = 'drgb':U
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
      buf_code-range.range-type = 'ctgb':U
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
      buf_code-range.range-type = 'cagb':U
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
      buf_code-range.range-type = 'fdgb':U
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
