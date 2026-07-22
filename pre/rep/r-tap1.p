block-level on error undo, throw.
define input parameter parparentproc     as handle           no-undo.
define input parameter rec_id            as recid            no-undo.
define input parameter p-price-celection as integer          no-undo.
define input parameter p-print-null-qnty as logical          no-undo.
define input parameter p-sort-by-group   as logical          no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-tap1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-tap1.p $":U .
define variable vss-description as character no-undo init "Акт переоценки ТАП-1-ДО".
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
function hvrdtax return logical (input parrecid as recid):
define variable varresult as logical no-undo.
run hvrdtax-proc (input parrecid, output varresult).
return varresult.
end function.
procedure hvrdtax-proc:
define input  parameter parrecid  as recid   no-undo.
define output parameter parresult as logical no-undo.
define buffer bf_goods for ub.goods.
define buffer bf_units for ub.units.
define buffer rt_tax   for ub.tax.
find first rt_tax   where rt_tax.tax-code    = integer('3':U) no-lock no-error.
find first bf_goods where recid(bf_goods)    = parrecid              no-lock.
find first bf_units where bf_units.unit-name = bf_goods.unit-base    no-lock.
if available rt_tax and
    can-find(first ub.tax-units No-LOCK WHERE
                   ub.tax-units.tax-code = rt_tax.tax-code AND
                   LOOKUP(ub.tax-units.type, bf_units.type) > 0) then assign parresult = yes.
                                                    else assign parresult = no.
end procedure.
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-param no-undo   field param-code     as character   field param-sub-code as character   field param-value    as character   index xpk is primary unique param-code param-sub-code   .
procedure paramls-clear :
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    for each buf_temp-param
    on error undo, return error
    :
      delete buf_temp-param .
    end.
  end.
end procedure.
procedure paramls-write :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
      .
    end.
    assign
      buf_temp-param.param-value = p-value
    .
  end.
end procedure.
procedure paramls-read :
  define input  parameter p-code          as character no-undo .
  define input  parameter p-sub-code      as character no-undo .
  define input  parameter p-default-value as character no-undo .
  define output parameter p-value         as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if available buf_temp-param then do:
      assign
        p-value = buf_temp-param.param-value
      .
    end.
    else do:
      assign
        p-value = p-default-value
      .
    end.
  end.
end procedure.
procedure paramls-append :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
         where buf_temp-param.param-code     = p-code
           and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
        buf_temp-param.param-value    = p-value
      .
    end.
    else do:
        assign
            buf_temp-param.param-value = buf_temp-param.param-value + ",":U + p-value
        .
    end.
  end.
end procedure.
define variable vss-include-info3 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    def var v-price-list-doc-num            like ub.price-list.doc-num     no-undo.
    def var v-price-list-price-sale         like ub.price-list.price-sale  no-undo.
    def var v-price-list-price-sale_old     like ub.price-list.price-sale  no-undo.
    def var v-price-list-road-tax           like ub.price-list.road-tax    no-undo.
    def var v-price-list-excise             like ub.price-list.excise      no-undo.
    def var v-price-list-b-code             like ub.bar-code.b-code        no-undo.
    def var v-gds-obj-last-price            like ub.gds-obj.last-rubl      no-undo.
    def var v-gds-prt-node-code             like ub.gds-prt.node-code      no-undo.
    def var v-gds-prt-node-name             like ub.gds-prt.node-name      no-undo.
    def var v-code-is-main                  as logical                  no-undo.
    def var v-not-main-unit-cli             like ub.bar-code.unit-cli      no-undo.
    def var v-not-main-cli-base-rate        like ub.bar-code.cli-base-rate no-undo.
    def var v-not-main-b-code               like ub.bar-code.cli-base-rate no-undo.
    def var v-taxname                       as char                     no-undo.
    def var v-tax                           as decimal  init 0          no-undo.
    def var v-tax-sum                       as decimal  init 0          no-undo.
    def var v-tax-parts-qnty                as decimal  init 0          no-undo.
define variable vss-include-info4 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define stream excel-line.
define stream excel-cell.
define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character
    index pi is primary unique data-key
.
define variable v-tap1-sheet1-cur-data-row     as integer      no-undo.
define variable v-tap1-cell-file-name       as character    no-undo.
define variable v-tap1-data-file-name       as character    no-undo.
procedure tap1-init :
do
on error undo, return error
:
    assign
        v-tap1-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-tap1-data-file-name
    ).
    output stream excel-line to value( v-tap1-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-tap1-cell-file-name
    ).
    output stream excel-cell to value( v-tap1-cell-file-name ).
    run tap1-write-cell-data in this-procedure (
          input "sheetList":U
        , input "Лист1":U
    ).
    if printrubl
    then do:
        run tap1-write-cell-data in this-procedure (
              input "Лист1_valutCode":U
            , input "0":U
        ).
    end.
    else do:
        run tap1-write-cell-data in this-procedure (
              input "Лист1_valutCode":U
            , input "1":U
        ).
    end.
    run tap1-write-cell-data in this-procedure (
          input "Лист1_columnList":U
        , input "number,artic,name,chrt,meas,qnty,price_before,summ_before,price_after,summ_after,delta":U
    ).
    run tap1-write-cell-data in this-procedure (
          input "Лист1_columnType":U
        , input "S,S,S,S,S,S,S,S,S,S,S":U
    ).
    run tap1-write-cell-data in this-procedure (
          input "Лист1_subtotalList":U
        , input "":U
    ).
    run tap1-write-cell-data in this-procedure (
          input "Лист1_subtotalType":U
        , input "":U
    ).
end.
end procedure.
procedure tap1-sheet1-write-line-data :
define input parameter p-number       as character        no-undo.
define input parameter p-artic        as character        no-undo.
define input parameter p-name         as character        no-undo.
define input parameter p-chrt         as character        no-undo.
define input parameter p-meas         as character        no-undo.
define input parameter p-qnty         as character        no-undo.
define input parameter p-price_before as character        no-undo.
define input parameter p-summ_before  as character        no-undo.
define input parameter p-price_after  as character        no-undo.
define input parameter p-summ_after   as character        no-undo.
define input parameter p-delta        as character        no-undo.
do
on error undo, return error
:
   put stream excel-line unformatted
                        "Лист1":U
         chr(9)  "DTA":U
         chr(9)  p-number
         chr(9)  p-artic
         chr(9)  p-name
         chr(9)  p-chrt
         chr(9)  p-meas
         chr(9)  p-qnty
         chr(9)  p-price_before
         chr(9)  p-summ_before
         chr(9)  p-price_after
         chr(9)  p-summ_after
         chr(9)  p-delta
         chr(10)
   .
end.
end procedure.
procedure tap1-write-cell-data :
define input parameter p-data-key   as character        no-undo.
define input parameter p-data-value as character        no-undo.
    define buffer buf_temp_cell-data     for temp_cell-data.
do
for buf_temp_cell-data
on error undo, return error
:
    find first buf_temp_cell-data
         where buf_temp_cell-data.data-key = p-data-key
    no-error.
    if not available buf_temp_cell-data
    then do:
        create buf_temp_cell-data.
        assign
            buf_temp_cell-data.data-key = p-data-key
        .
    end.
    assign
        buf_temp_cell-data.data-value = p-data-value
    .
    put stream excel-cell unformatted
                        buf_temp_cell-data.data-key
        chr(9)   buf_temp_cell-data.data-value
        chr(10)
    .
end.
end procedure.
procedure tap1-run-excel :
define input parameter p-header-filename    as character        no-undo.
define input parameter p-data-filename      as character        no-undo.
define variable v-template-file-name    as character    no-undo.
define variable v-vb-file-name          as character    no-undo.
define buffer buf_temp-param for temp-param .
do
for buf_temp-param
on error undo, return error
:
    create buf_temp-param.
    assign
        v-template-file-name    = search( "exe/wth-tap1.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas" )
    .
    if v-template-file-name = ?
    or v-template-file-name = "":U
    then do:
        message
            "Ошибка имени файла шаблона."
        view-as alert-box error.
    end.
    if v-vb-file-name = ?
    or v-vb-file-name = "":U
    then do:
        message
            "Ошибка имени файла кода обработки."
        view-as alert-box error.
    end.
    run paramls-write in this-procedure (
          input "template":U
        , input "template-file-name":U
        , input v-template-file-name
    ).
    run paramls-write in this-procedure (
          input "template":U
        , input "vb-file-name":U
        , input v-vb-file-name
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-header-filename":U
        , input p-header-filename
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-filename":U
        , input p-data-filename
    ).
    run gbl/macroxlt.p (
        input-output table buf_temp-param
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка создания файла Excel."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
end.
end procedure.
procedure tap1-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/wth-tap1.xlt" .
        export "exe/t_form.bas" .
        export v-tap1-cell-file-name.
        export v-tap1-data-file-name.
    output close.
end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define new shared variable str1   as character  no-undo.
define new shared variable str2   as character  no-undo.
define new shared variable str3   as character  no-undo.
define new shared variable str4   as character  no-undo.
define new shared variable ReportNAme   as character  no-undo.
define new shared variable ReportProc   as character  no-undo.
define new shared variable ReportHeader as character  no-undo.
define new shared variable ReportPageWidth  as integer no-undo.
define new shared variable ReportPageHeight as integer no-undo.
define new shared variable ReportFontNum    as integer no-undo.
define new shared variable my-request as logical  init false no-undo.
define new shared variable v-delim as character no-undo .
define new shared variable v-sdate as character no-undo initial "/":U.
define new shared variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .
define new shared variable my-handle  as handle no-undo .
define new shared variable parent-handle  as handle no-undo .
define new shared variable v-show-all-goods as logical  no-undo .
define new shared variable params-only      as logical   no-undo .
define new shared variable params-only-mode as character no-undo .
define new shared variable place-call       as character no-undo .
define new shared variable x-Goods-Editor   as character  no-undo .
define new shared variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-End       as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-Start     as date format "99/99/9999":u   no-undo .
define new shared variable x-Shift-Alone    as integer format ">9":u         no-undo .
define new shared variable x-Shift-End      as integer format ">9":u         no-undo .
define new shared variable x-Shift-Start    as integer format ">9":u         no-undo .
define new shared variable x-SelectGood     as integer                      no-undo .
define new shared variable x-SelectObject   as character                          no-undo .
define new shared variable x-SET_PAY_TYPE   as integer  no-undo .
define new shared variable x-SET_val_TYPE   as integer  no-undo .
define new shared variable x-TOG-Shift      as logical  no-undo .
define new shared variable x-Radio-Task     as integer  no-undo .
define new shared variable x-TOG-Excel      as logical  no-undo .
define new shared variable x-TOG-list-hist  as logical  no-undo .
define new shared variable x-text-1 as character  no-undo .
define new shared variable x-text-2 as character  no-undo .
define new shared variable x-text-3 as character  no-undo .
define new shared variable x-text-4 as character  no-undo .
define new shared variable init-date-start  like x-date-start  no-undo .
define new shared variable init-date-end    like x-date-end    no-undo .
define new shared variable init-date-alone  like x-date-alone  no-undo .
define new shared variable init-shift-alone like x-shift-alone no-undo .
define new shared variable init-shift-start like x-shift-start no-undo .
define new shared variable init-shift-end   like x-shift-end   no-undo .
define new shared variable init-set_pay_type like x-set_pay_type   no-undo .
define new shared variable init-set_val_type like x-set_val_type   no-undo .
define new shared variable ref_date-start    as character   no-undo .
define new shared variable ref_date-end      as character   no-undo .
define new shared variable ref_date-alone    as character   no-undo .
define new shared work-table TDEDT  no-undo
  field id as char
  field name as character  format "x(40)"
  field n as character
  .
define variable tempstr as character  no-undo.
define variable b1-name as character  no-undo.
define variable b2-name as character  no-undo.
define variable source-str   as character no-undo .
define variable I#           as integer    no-undo.
define variable p-price-med  as decimal init 0 no-undo .
define new shared variable str-obj-type as character  no-undo.
define new shared variable str-obj-code as character  no-undo.
define new shared variable str-obj-name as character  no-undo.
define new shared variable str-obj      as character  no-undo.
define new shared variable link#        as logical  no-undo init false.
define new shared variable  Verify-Arc-ot      as logical  no-undo init false.
define new shared variable  Verify-Arc-stk     as logical  no-undo init false.
define new shared variable  Verify-Arc-supp    as logical  no-undo init false.
define new shared variable  Verify-Arc-hold    as logical  no-undo init false.
define new shared variable  Verify-Arc-aht     as logical  no-undo init false.
define new shared variable  Verify-send-check  as logical  no-undo init false.
define new shared variable  Verify-Arc-fin     as logical  no-undo init false.
define new shared variable  Verify-Arc-strong  as logical  no-undo init false.
define new shared variable  Show-Crsa         as logical  no-undo init false.
define new shared variable  Show-Cost         as logical  no-undo init false.
define new shared variable  Show-Sale         as logical  no-undo init false.
define new shared variable  Name-Sale-price   as character no-undo .
define new shared variable  Format-Folder     as logical no-undo .
define new shared variable  Print-List-Hist   as logical no-undo init false.
define new shared variable Make-Excel     as logical  no-undo init false.
define new shared variable Make-Excel-com as logical  no-undo init false.
define new shared stream ForExcel.
define new shared variable Use-column   as logical extent 256 no-undo .
define new shared variable right-column as logical extent 256 no-undo .
define new shared temp-table Sheetf no-undo
field Excel-Column-Lable as character
field Excel-Row-Heder    as integer
field Excel-Row-Title    as integer
field Sizes              as character
field Make-correct       as character
field Rights-column      as character
field MergeCellsH        as character
field MergeCellsV        as character
field sheet-num          as integer
field ColFormat          as character
field Bas-FIle           as character
field Bas-Params         as character
field Bas-Param-Add      as logical
field File-name          as character
field Silent-save        as logical
index pi as primary unique
      sheet-num
.
  create Sheetf.
  assign
  sheetf.sheet-num = 1.
define variable l-stroka as character no-undo .
define new shared  variable ch#ExcelApplication as com-handle no-undo .
define new shared  variable ch#Workbook         as com-handle no-undo .
define new shared  variable ch#Worksheet        as com-handle no-undo .
define new shared  variable Num#Str#            as integer no-undo.
define new shared  variable Number-List         as integer no-undo init 1.
define new shared  variable v-excel-file        as character no-undo .
define variable Col-name as character  extent 256.
define variable Col-format as character  extent 256.
define variable Col-Post-format as character  extent 256.
run proc-page0-assign in this-procedure .
define variable v-del-1 as character no-undo .
if  v-delim = " " or v-delim = ? or v-delim = ""  then do:
    run gbl/getlocal.p ( output v-delim  , output v-del-1, output v-sdate, output v-shortdate ) no-error .
    if error-status :error then do:
      message error-status :error error-status :get-message(1)
              v-delim v-del-1.
        v-delim = ','  .
    end.
end.
procedure proc-page0-assign :
 do
 on error undo, return error return-value
 :
Assign
  Col-name[1] = 'A':U
  Col-name[2] = 'B':U
  Col-name[3] = 'C':U
  Col-name[4] = 'D':U
  Col-name[5] = 'E':U
  Col-name[6] = 'F':U
  Col-name[7] = 'G':U
  Col-name[8] = 'H':U
  Col-name[9] = 'I':U
  Col-name[10]= 'J':U
  Col-name[11]= 'K':U
  Col-name[12]= 'L':U
  Col-name[13]= 'M':U
  Col-name[14]= 'N':U
  Col-name[15]= 'O':U
  Col-name[16]= 'P':U
  Col-name[17]= 'Q':U
  Col-name[18]= 'R':U
  Col-name[19]= 'S':U
  Col-name[20]= 'T':U
  Col-name[21]= 'U':U
  Col-name[22]= 'V':U
  Col-name[23]= 'W':U
  Col-name[24]= 'X':U
  Col-name[25]= 'Y':U
  Col-name[26]= 'Z':U
  Col-name[27]= 'AA':U
  Col-name[28]= 'AB':U
  Col-name[29]= 'AC':U
  Col-name[30]= 'AD':U
  Col-name[31]= 'AE':U
  Col-name[32]= 'AF':U
  Col-name[33]= 'AG':U
  Col-name[34]= 'AH':U
  Col-name[35]= 'AI':U
  Col-name[36]= 'AJ':U
  Col-name[37]= 'AK':U
  Col-name[38]= 'AL':U
  Col-name[39]= 'AM':U
  Col-name[40]= 'AN':U
  Col-name[41]= 'AO':U
  Col-name[42]= 'AP':U
  Col-name[43]= 'AQ':U
  Col-name[44]= 'AR':U
  Col-name[45]= 'AS':U
  Col-name[46]= 'AT':U
  Col-name[47]= 'AU':U
  Col-name[48]= 'AV':U
  Col-name[49]= 'AW':U
  Col-name[50]= 'AX':U
  Col-name[51]= 'AY':U
  Col-name[52]= 'AZ':U
  Col-name[53]= 'BA':U
  Col-name[54]= 'BB':U
  Col-name[55]= 'BC':U
  Col-name[56]= 'BD':U
  Col-name[57]= 'BE':U
  Col-name[58]= 'BF':U
  Col-name[59]= 'BG':U
  Col-name[60]= 'BH':U
  Col-name[61]= 'BI':U
  Col-name[62]= 'BJ':U
  Col-name[63]= 'BK':U
  Col-name[64]= 'BL':U
  Col-name[65]= 'BM':U
  Col-name[66]= 'BN':U
  Col-name[67]= 'BO':U
  Col-name[68]= 'BP':U
  Col-name[69]= 'BQ':U
  Col-name[70]= 'BR':U
  Col-name[71]= 'BS':U
  Col-name[72]= 'BT':U
  Col-name[73]= 'BU':U
  Col-name[74]= 'BV':U
  Col-name[75]= 'BW':U
  Col-name[76]= 'BX':U
  Col-name[77]= 'BY':U
  Col-name[78]= 'BZ':U
  Col-name[79]= 'CA':U
  Col-name[80]= 'CB':U
  Col-name[81]= 'CC':U
  Col-name[82]= 'CD':U
  Col-name[83]= 'CE':U
  Col-name[84]= 'CF':U
  Col-name[85]= 'CG':U
  Col-name[86]= 'CH':U
  Col-name[87]= 'CI':U
  Col-name[88]= 'CJ':U
  Col-name[89]= 'CK':U
  Col-name[90]= 'CL':U
  Col-name[91]= 'CM':U
  Col-name[92]= 'CN':U
  Col-name[93]= 'CO':U
  Col-name[94]= 'CP':U
  Col-name[95]= 'CQ':U
  Col-name[96]= 'CR':U
  Col-name[97]= 'CS':U
  Col-name[98]= 'CT':U
  Col-name[99]= 'CU':U
  Col-name[100]= 'CV':U
Col-name[101]= 'CW':U
Col-name[102]= 'CX':U
Col-name[103]= 'CY':U
Col-name[104]= 'CZ':U
Col-name[105]= 'DA':U
Col-name[106]= 'DB':U
Col-name[107]= 'DC':U
Col-name[108]= 'DD':U
Col-name[109]= 'DE':U
Col-name[110]= 'DF':U
Col-name[111]= 'DG':U
Col-name[112]= 'DH':U
Col-name[113]= 'DI':U
Col-name[114]= 'DJ':U
Col-name[115]= 'DK':U
Col-name[116]= 'DL':U
Col-name[117]= 'DM':U
Col-name[118]= 'DN':U
Col-name[119]= 'DO':U
Col-name[120]= 'DP':U
Col-name[121]= 'DQ':U
Col-name[122]= 'DR':U
Col-name[123]= 'DS':U
Col-name[124]= 'DT':U
Col-name[125]= 'DU':U
Col-name[126]= 'DV':U
Col-name[127]= 'DW':U
Col-name[128]= 'DX':U
Col-name[129]= 'DY':U
Col-name[130]= 'DZ':U
Col-name[131]= 'EA':U
Col-name[132]= 'EB':U
Col-name[133]= 'EC':U
Col-name[134]= 'ED':U
Col-name[135]= 'EE':U
Col-name[136]= 'EF':U
Col-name[137]= 'EG':U
Col-name[138]= 'EH':U
Col-name[139]= 'EI':U
Col-name[140]= 'EJ':U
Col-name[141]= 'EK':U
Col-name[142]= 'EL':U
Col-name[143]= 'EM':U
Col-name[144]= 'EN':U
Col-name[145]= 'EO':U
Col-name[146]= 'EP':U
Col-name[147]= 'EQ':U
Col-name[148]= 'ER':U
Col-name[149]= 'ES':U
Col-name[150]= 'ET':U
Col-name[151]= 'EU':U
Col-name[152]= 'EV':U
Col-name[153]= 'EW':U
Col-name[154]= 'EX':U
Col-name[155]= 'EY':U
Col-name[156]= 'EZ':U
Col-name[157]= 'FA':U
.
assign
  Col-name[158]= 'FB':U
  Col-name[159]= 'FC':U
  Col-name[160]= 'FD':U
  Col-name[161]= 'FE':U
  Col-name[162]= 'FF':U
  Col-name[163]= 'FG':U
  Col-name[164]= 'FH':U
  Col-name[165]= 'FI':U
  Col-name[166]= 'FJ':U
  Col-name[167]= 'FK':U
  Col-name[168]= 'FL':U
  Col-name[169]= 'FM':U
  Col-name[170]= 'FN':U
  Col-name[171]= 'FO':U
  Col-name[172]= 'FP':U
  Col-name[173]= 'FQ':U
  Col-name[174]= 'FR':U
  Col-name[175]= 'FS':U
  Col-name[176]= 'FT':U
  Col-name[177]= 'FU':U
  Col-name[178]= 'FV':U
  Col-name[179]= 'FW':U
  Col-name[180]= 'FX':U
  Col-name[181]= 'FY':U
  Col-name[182]= 'FZ':U
  Col-name[183]= 'GA':U
  Col-name[184]= 'GB':U
  Col-name[185]= 'GC':U
  Col-name[186]= 'GD':U
  Col-name[187]= 'GE':U
  Col-name[188]= 'GF':U
  Col-name[189]= 'GG':U
  Col-name[190]= 'GH':U
  Col-name[191]= 'GI':U
  Col-name[192]= 'GJ':U
  Col-name[193]= 'GK':U
  Col-name[194]= 'GL':U
  Col-name[195]= 'GM':U
  Col-name[196]= 'GN':U
  Col-name[197]= 'GO':U
  Col-name[198]= 'GP':U
  Col-name[199]= 'GQ':U
  Col-name[200]=   'GR':U
  Col-name[201]=   'GS':U
  Col-name[202]=   'GT':U
  Col-name[203]=   'GU':U
  Col-name[204]=   'GV':U
  Col-name[205]=   'GW':U
  Col-name[206]=   'GX':U
  Col-name[207]=   'GY':U
  Col-name[208]=   'GZ':U
  Col-name[209]=   'HA':U
  Col-name[210]=   'HB':U
  Col-name[211]=   'HC':U
  Col-name[212]=   'HD':U
  Col-name[213]=   'HE':U
  Col-name[214]=   'HF':U
  Col-name[215]=   'HG':U
  Col-name[216]=   'HH':U
  Col-name[217]=   'HI':U
  Col-name[218]=   'HJ':U
  Col-name[219]=   'HK':U
  Col-name[220]=   'HL':U
  Col-name[221]=   'HM':U
  Col-name[222]=   'HN':U
  Col-name[223]=   'HO':U
  Col-name[224]=   'HP':U
  Col-name[225]=   'HQ':U
  Col-name[226]=   'HR':U
  Col-name[227]=   'HS':U
  Col-name[228]=   'HT':U
  Col-name[229]=   'HU':U
  Col-name[230]=   'HV':U
  Col-name[231]=   'HW':U
  Col-name[232]=   'HX':U
  Col-name[233]=   'HY':U
  Col-name[234]=   'HZ':U
  Col-name[235]=   'IA':U
  Col-name[236]=   'IB':U
  Col-name[237]=   'IC':U
  Col-name[238]=   'ID':U
  Col-name[239]=   'IE':U
  Col-name[240]=   'IF':U
  Col-name[241]=   'IG':U
  Col-name[242]=   'IH':U
  Col-name[243]=   'II':U
  Col-name[244]=   'IJ':U
  Col-name[245]=   'IK':U
  Col-name[246]=   'IL':U
  Col-name[247]=   'IM':U
  Col-name[248]=   'IN':U
  Col-name[249]=   'IO':U
  Col-name[250]=   'IP':U
  Col-name[251]=   'IQ':U
  Col-name[252]=   'IR':U
  Col-name[253]=   'IS':U
  Col-name[254]=   'IT':U
  Col-name[255]=   'IU':U
  Col-name[256]=   'IV':U
  .
 end.
end procedure.
def var vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tax-name:
define input  parameter pardef-tax  as character           no-undo.
define output parameter parname-tax as character initial ? no-undo.
define buffer bf_tax for ub.tax.
do on error undo, return error :
   case pardef-tax:
      when 'vat':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('1':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '1':U(не задействован)".
      end.
      when 'slt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('2':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '2':U(не задействован)".
      end.
      when 'rdt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('3':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '3':U(не задействован)".
      end.
      when 'exc':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('4':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '4':U(не задействован)".
      end.
      otherwise do:
         return error "Задан неверный параметр " + pardef-tax + " .".
      end.
   end case.
end.
end procedure.
define stream outstream .
define buffer obj_clients     for ub.clients .
define buffer firm_clients    for ub.clients .
define buffer buf_trn-doc     for ub.trn-doc .
define buffer buf_price-doc   for ub.price-doc .
define buffer buf_bar-code    for ub.bar-code .
define buffer buf_gds-prt     for ub.gds-prt .
define buffer buf_price-list  for ub.price-list .
define buffer buf_gds-obj     for ub.gds-obj .
define buffer buf_goods    for ub.goods .
define buffer buf_parts    for ub.parts .
define variable v-single-line       as character    no-undo .
define variable v-rb-is-base        as logical      no-undo .
define variable v-ok                as logical      no-undo .
define variable v-b-code            as character    no-undo .
define variable v-old-sum           as decimal      no-undo .
define variable v-new-sum           as decimal      no-undo .
define variable v-up-fact           as decimal      no-undo .
define variable propis              as character    no-undo .
define variable v-summ-all-before   as decimal      no-undo.
define variable v-qnty-all          as decimal      no-undo.
define variable abbr                as character    no-undo .
define variable v-line-counter      as integer      no-undo .
define variable v-empty             as character    no-undo .
define variable sym1                as character init "|"   no-undo .
define variable sym2                as character init "|"   no-undo .
define variable sym3                as character init "|"   no-undo .
define variable sym4                as character init "|"   no-undo .
define variable sym5                as character init "|"   no-undo .
define variable sym6                as character init "|"   no-undo .
define variable sym7                as character init "|"   no-undo .
define variable sym8                as character init "|"   no-undo .
define variable sym9                as character init "|"   no-undo .
define variable sym10               as character init "|"   no-undo .
define variable sym11               as character init "|"   no-undo .
define variable sym12               as character init "|"   no-undo .
define variable v-delta             as decimal      no-undo .
  define frame f-tap
    sym1                         no-label format "X(1)"              space(0)
    v-line-counter               no-label format ">>>>9"             space(0)
    sym2                         no-label format "X(1)"              space(0)
    buf_price-list.artic         no-label format "X(16)"             space(0)
    sym3                         no-label format "X(1)"              space(0)
    buf_goods.gds-name           no-label format "X(35)"             space(0)
    sym4                         no-label format "X(1)"              space(0)
    v-empty                      no-label format "x(9)"              space(0)
    sym5                         no-label format "X(1)"              space(0)
    buf_goods.unit-base          no-label format "X(10)"             space(0)
    sym6                         no-label format "X(1)"              space(0)
    buf_price-list.doc-qnty      no-label format "->>>>>9.999"       space(0)
    sym7                         no-label format "X(1)"              space(0)
    v-price-list-price-sale_old  no-label format "->>>>>>>9.99"      space(0)
    sym8                         no-label format "X(1)"              space(0)
    v-old-sum                    no-label format "->>>>>>>>>>9.99"   space(0)
    sym9                         no-label format "X(1)"              space(0)
    buf_price-list.price-sale    no-label format "->>>>>>>9.99"      space(0)
    sym10                        no-label format "X(1)"              space(0)
    v-new-sum                    no-label format "->>>>>>>>>>9.99"   space(0)
    sym11                        no-label format "X(1)"              space(0)
    v-delta                      no-label format "->>>>>>>>>>9.99"   space(0)
    sym12                        no-label format "X(1)"              space(0)
    skip
  header
    "+-----+----------------+-----------------------------------+---------+----------+-----------+------------+---------------+------------+---------------+---------------+" skip
    "|  №  |      Код       |          Наименование ТМЦ         |Характер-|    Ед.   |  Кол-во   |       До переоценки        |      После переоценки      |     Сумма     |" skip
    "| п/п |   (номенклат.  |                                   | истика  |  измер.  |  (масса)  |                            |                            |   разницы от  |" skip
    "|     |     номер.)    |                                   |  ТМЦ    |          |           +------------+---------------+------------+---------------+   переоценки  |" skip
    "|     |                |                                   |         |          |           |    Цена    |     Сумма     |    Цена    |     Сумма     |   дооценки(+) |" skip
    "|     |                |                                   |         |          |           |            |               |            |               |   уценки(-)   |" skip
    "+-----+----------------+-----------------------------------+---------+----------+-----------+------------+---------------+------------+---------------+---------------+" skip
    "|  1  |       2        |                 3                 |    4    |     5    |     6     |      7     |       8       |      9     |       10      |       11      |" skip
  with width 168 down stream-io no-labels no-box.
do
on error undo, return error
:
   RUN fill-tt         IN THIS-PROCEDURE .
   run open-stream     IN THIS-PROCEDURE .
   run print-header    in this-procedure .
   run print-body      in this-procedure .
   run print-footer    in this-procedure .
   run close-stream    IN THIS-PROCEDURE .
end.
procedure fill-tt :
do
on error undo, return error
:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if session :set-wait-state( "compiler" ) then.
   run get-report-num in parparentproc (
      output g#report-num
   ).
   run get-quest-print in parparentproc (
      output g#quest-print
   ).
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-rb-is-base
  )  .
   find first buf_price-doc
        where recid(buf_price-doc) = rec_id
        no-lock
        .
   if not available buf_price-doc
   then do:
      bell.
      message 'Порушена табличка "price-doc"(r-tap1.p).'.
      return error.
   end.
   if  buf_price-doc.status_ <> 'акт':U
   then do:
      bell.
      message 'Документ не акт переоценки (r-tap1.p).'.
      return error.
   end.
   find     obj_clients
      where obj_clients.obj-code = buf_price-doc.obj-code
      and   obj_clients.obj-type = buf_price-doc.obj-type
      no-lock
      .
   if not available obj_clients
   then do:
      bell.
      message 'Порушена табличка "clients" (r-tap1.p).'.
      return error.
   end.
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue-cast_print':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-ok
    )  .
end.
   find     buf_trn-doc
      where buf_trn-doc.doc-code = buf_price-doc.doc-num
      no-lock
      no-error
      .
   find     firm_clients
      where firm_clients.obj-type = 'орг':U
      and   firm_clients.obj-code = buf_price-doc.host-code
      no-lock
   .
   assign
      v-single-line = fill("-", 168)
   .
end.
end procedure.
procedure open-stream :
do
on error undo, return error
:
output stream outstream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size 62 .
   run tap1-init in this-procedure.
end.
end procedure.
procedure print-header :
do
on error undo, return error
:
   put stream outstream
   skip(1)
   .
   put stream outstream skip(2)
      space(150)  "Форма ТАП-1-ДО"                                                            SKIP
         "Организация:"   firm_clients.obj-name "Утверждаю:  _____________________________" AT 108                SKIP
                                                   "должность"                AT 130                SKIP
         "структурное подразделение:"   obj_clients.obj-name  "_____________________________________" AT 120                SKIP
                                                            "  подпись      расшифровка подписи"  AT 120     SKIP
                                                            "«______» ____________ 200__г."AT 120  SKIP
      space(57)   "АКТ"                      "+-----------------+------------+" AT 101        SKIP
      space(50)   "О ПЕРЕОЦЕНКЕ ТОВАРОВ"     "|      Номер      |     от     |" AT 101        SKIP
                                             "+-----------------+------------+" AT 101        SKIP
                                             "|" AT 101       buf_price-doc.doc-num AT 102 "|" AT 119 buf_price-doc.doc-date format "99.99.9999" AT 121  "|" AT 132 SKIP
                                             "+----------------------+-------+-----------------+------------+"  AT 70       SKIP
                        "Основание составления акта" AT 30    "| Приказ, распоряжение | Номер |                 |" AT 70 SKIP
                                                              "+----------------------+-------+-----------------+" AT 70 SKIP
                                                              "| Ненужное зачеркнуть  |  от   |                 |" AT 70 SKIP
                                                              "+----------------------+-------+-----------------+" AT 70 SKIP
                  "Комиссия в составе: Председатель комиссии : _____________________________"            SKIP
      space(27)   "Члены комиссии : ____________________________________________________________________________________________________________________"          SKIP
                  "произвела переоценку товаров. Переоцененные товары перемаркированы."                  SKIP
      skip .
   form header
               "Продолжение - на следующей странице" at 30 skip
               with frame Bottomframe width 160 page-bottom no-labels no-box .
   view stream outstream frame bottomframe .
   RUN tap1-write-cell-data IN THIS-PROCEDURE
       ( INPUT "firm":U
       , INPUT firm_clients.obj-name
       ) .
   RUN tap1-write-cell-data IN THIS-PROCEDURE
       ( INPUT "object":U
       , INPUT obj_clients.obj-name
       ) .
   RUN tap1-write-cell-data IN THIS-PROCEDURE
       ( INPUT "doc_num":U
       , INPUT buf_price-doc.doc-num
       ) .
   RUN tap1-write-cell-data IN THIS-PROCEDURE
       ( INPUT "doc_date":U
       , INPUT buf_price-doc.doc-date
       ) .
end.
end procedure.
procedure print-body :
do
on error undo, return error
:
   form with frame f-tap .
   for each buf_price-list
      no-lock
      where buf_price-list.doc-num = buf_price-doc.doc-num
      ,
      each buf_goods
      no-lock
      where buf_goods.artic     = buf_price-list.artic
        and buf_goods.prod-type = buf_price-list.prod-type
        and buf_goods.prod-code = buf_price-list.prod-code
      break by buf_goods.artic descending
      :
define variable vss-include-info11 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
            find first buf_bar-code no-lock
                 where buf_bar-code.b-code = buf_price-list.b-code
            .
            if buf_bar-code.unit-cli = buf_goods.unit-base
            then do:
                assign
                    v-code-is-main = yes
                .
            end.
            else do:
                assign
                    v-code-is-main = no
                .
            end.
            if not (v-code-is-main = yes)
            then do:
                assign
                    v-not-main-unit-cli       = buf_bar-code.unit-cli
                    v-not-main-cli-base-rate  = buf_bar-code.cli-base-rate
                    v-not-main-b-code         = buf_bar-code.b-code
                .
            end.
            find first buf_gds-prt no-lock
                 where buf_gds-prt.node-code = buf_bar-code.node-code
            .
            assign
              v-gds-prt-node-name =
              ( if buf_gds-prt.upper-code = buf_goods.prt-root
                then if buf_bar-code.in-code = ''
                    then buf_goods.gds-name
                    else buf_bar-code.in-code + '    ' + buf_bar-code.part-code
                else
                        '    ' + buf_gds-prt.f-name
              )
            .
            find first buf_gds-obj no-lock
                 where buf_gds-obj.obj-type  = buf_price-list.obj-type
                   and buf_gds-obj.obj-code  = buf_price-list.obj-code
                   and buf_gds-obj.prod-type = buf_price-list.prod-type
                   and buf_gds-obj.prod-code = buf_price-list.prod-code
                   and buf_gds-obj.artic     = buf_price-list.artic
            no-error.
            if available buf_gds-obj
            then do:
                assign
                    v-gds-obj-last-price = ( if v-rb-is-base = yes then buf_gds-obj.last-base else buf_gds-obj.last-rubl )
                .
                if v-gds-obj-last-price = ?
                then do:
                    assign
                        v-gds-obj-last-price = 0
                    .
                end.
            end.
            else do:
                assign
                    v-gds-obj-last-price = 0
                .
            end.
            find first buf_gds-prt no-lock
                 where buf_gds-prt.upper-code = buf_goods.prt-root
            .
            assign
                v-gds-prt-node-code = buf_gds-prt.node-code
            .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_price-list.obj-type
  ,input  buf_price-list.obj-code
  ,input  buf_price-list.b-code
  ,input  0
  ,input  buf_price-list.fact-order
  ,output v-price-list-doc-num
  ,output v-price-list-price-sale
  ,output v-price-list-road-tax
  ,output v-price-list-excise
  )  .
            if v-price-list-price-sale = ?
            then do:
                assign
                    v-price-list-price-sale = 0
                .
            end.
            if v-price-list-road-tax = ?
            then do:
                assign
                    v-price-list-road-tax = 0
                .
            end.
            assign
                v-price-list-price-sale_old = v-price-list-price-sale
            .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  buf_bar-code.node-code
  ,output v-price-list-b-code
  )  .
            find first buf_bar-code no-lock
                 where buf_bar-code.b-code = v-price-list-b-code
            .
            accumulate buf_bar-code.b-code ( count ) .
      if v-code-is-main = yes
      then do:
         accumulate ( ( buf_price-list.price-sale - v-price-list-price-sale_old ) * buf_price-list.doc-qnty ) (total)
                      ( buf_price-list.doc-qnty ) (total)
                      ( buf_price-list.doc-qnty * v-price-list-price-sale_old ) (total)
                      ( buf_price-list.doc-qnty * buf_price-list.price-sale ) (total)
                      ( buf_price-list.doc-qnty * v-gds-obj-last-price ) (total) .
         run print-line-fact in this-procedure.
      end.
      if line-counter( outstream ) + 9 > page-size( outstream ) then
            page stream outstream .
   end.
   ASSIGN
      v-delta     = accum total ( ( buf_price-list.price-sale - v-price-list-price-sale_old) * buf_price-list.doc-qnty)
      v-new-sum   = accum total ( buf_price-list.doc-qnty * buf_price-list.price-sale )
      v-old-sum   = accum total ( buf_price-list.doc-qnty * v-price-list-price-sale_old )
      v-qnty-all  = accum total ( buf_price-list.doc-qnty )
   .
end.
end procedure.
procedure print-footer :
do
on error undo, return error
:
   put stream outstream v-single-line format "X(168)" skip.
   display stream outstream
      "Всего" format "X(8)" @ buf_goods.gds-name
      v-qnty-all @ buf_price-list.doc-qnty
      v-old-sum
      v-new-sum
      v-delta
      with frame f-tap
   .
   hide stream outstream frame Bottomframe .
   RUN tap1-write-cell-data IN THIS-PROCEDURE
       ( INPUT "it_qnty":U
       , INPUT v-qnty-all
       ) .
   RUN tap1-write-cell-data IN THIS-PROCEDURE
       ( INPUT "it_summ_before":U
       , INPUT v-old-sum
       ) .
   RUN tap1-write-cell-data IN THIS-PROCEDURE
       ( INPUT "it_summ_after":U
       , INPUT v-new-sum
       ) .
   RUN tap1-write-cell-data IN THIS-PROCEDURE
       ( INPUT "it_delta":U
       , INPUT v-delta
       ) .
   IF v-line-counter > 0
   THEN DO:
      run rep/wp-qnty.p (
            input absolute( 1 )
            , output propis
      ) .
      RUN tap1-write-cell-data IN THIS-PROCEDURE
         ( INPUT "number_begin":U
         , INPUT propis
         ) .
      define variable v-out-str    as character    no-undo.
      assign
         v-out-str = "Количество порядковых номеров: с № " + propis
      .
      run rep/wp-qnty.p (
            input absolute( v-line-counter )
            , output propis
      ) .
      RUN tap1-write-cell-data IN THIS-PROCEDURE
         ( INPUT "number_end":U
         , INPUT propis
         ) .
      assign
         v-out-str = v-out-str + " по № " + propis
      .
      put stream outstream
         v-out-str FORMAT "x(168)"
      .
   END.
   ELSE DO:
      ASSIGN
         propis = "Ноль"
      .
      RUN tap1-write-cell-data IN THIS-PROCEDURE
         ( INPUT "number_begin":U
         , INPUT propis
         ) .
      RUN tap1-write-cell-data IN THIS-PROCEDURE
         ( INPUT "number_end":U
         , INPUT propis
         ) .
      assign
         v-out-str = "Количество порядковых номеров: с № " + propis + " по № " + propis
      .
      put stream outstream
         v-out-str FORMAT "x(168)"
      .
   END.
   run rep/wp-qnty.p (
           input absolute( v-qnty-all )
         , output propis
   ) .
   IF propis = "":U
   OR TRUNCATE( v-qnty-all, 0) = 0
   THEN DO:
      ASSIGN
         propis = "Ноль " + propis
      .
   END.
   IF v-qnty-all < 0
   THEN DO:
      ASSIGN
         propis = "Минус " + propis
      .
   END.
   assign
      v-out-str = "Количество в натуральных показателях " + propis
   .
   put stream outstream skip
      v-out-str FORMAT "x(168)"
   .
   RUN tap1-write-cell-data IN THIS-PROCEDURE
       ( INPUT "qnty_prop":U
       , INPUT propis
       ) .
   if v-rb-is-base = yes
   then do:
      run rep/wp.p (
            input parparentproc
            , input absolute( v-delta )
            , output propis
            , output abbr
      ) .
   end.
   else do:
      run rep/wp-rub.p (
            input absolute( v-delta )
            , output propis
            , output abbr
      ) .
   end.
   put stream outstream skip
            "Cумма переоценки: " format "X(18)"
            ( v-delta ) format "->>>>>>>>9.99"
            space(1)
            ( if v-rb-is-base = yes then "баз.вал" else "руб" )         format "X(3)"
            " (" format "X(2)"
            .
   IF v-delta < 0
   THEN DO:
      ASSIGN
         propis = "Минус " + propis
      .
   END.
   put stream outstream
            string( propis + ")" )
               format "X(95)"
            .
   RUN tap1-write-cell-data IN THIS-PROCEDURE
       ( INPUT "summ_prop":U
       , INPUT propis
       ) .
   put stream outstream skip
      "Все члены комиссии предупреждены об ответственности за подписание акта, содержащего данные, несоответствующие действительности." SKIP(1)
      "          Председатель комиссии : _____________________  __________________  __________________________________" SKIP
      "                                        должность              подпись               расшифровка подписи       " SKIP(1)
      "                 Члены комиссии : _____________________  __________________  __________________________________" SKIP
      "                                        должность              подпись               расшифровка подписи       " SKIP(1)
      "                                : _____________________  __________________  __________________________________" SKIP
      "                                        должность              подпись               расшифровка подписи       " SKIP
   .
   if v-rb-is-base = yes
   then do:
      run rep/wp.p (
            input parparentproc
            , input absolute( v-new-sum )
            , output propis
            , output abbr
      ) .
   end.
   else do:
      run rep/wp-rub.p (
            input absolute( v-new-sum )
            , output propis
            , output abbr
      ) .
   end.
   IF v-new-sum < 0
   THEN DO:
      ASSIGN
         propis = "Минус " + propis
      .
   END.
   RUN tap1-write-cell-data IN THIS-PROCEDURE
       ( INPUT "summ_after_prop":U
       , INPUT propis
       ) .
   put stream outstream UNFORMATTED skip
      "Товарные ценности, перечисленные на общую сумму после переоценки " propis SKIP
      "находятся на моем (нашем) ответственном хранении. Материально-ответственное (ые) лицо (а)_____________________  __________________  __________________________________" SKIP
      "                должность              подпись               расшифровка подписи       " AT 77
   .
end.
end procedure.
procedure close-stream :
do
on error undo, return error
:
   output stream outstream close.
if session :set-wait-state( "" ) then.
   run tap1-close in this-procedure .
   os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )  .
   os-rename
      value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
      value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
   .
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 8 >= 8 then 2 else 0), 0, 0,
                                      OUTPUT g#log ).
end.
else do:
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + " " +
      string( session:temp-directory) +  "$" + string( g#report-num )
              ) .
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl" + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txl" + " " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl"
              ) .
end.
end.
end procedure.
procedure print-line-fact :
do
on error undo, return error
:
   if ( ( buf_price-list.price-sale - v-price-list-price-sale_old ) * buf_price-list.doc-qnty  <> 0 ) or ( p-print-null-qnty = yes )
   then do:
      assign
         v-line-counter = v-line-counter + 1
      .
      display stream outstream
         v-line-counter
         buf_price-list.artic
         v-gds-prt-node-name                                         @ buf_goods.gds-name
         buf_goods.unit-base
         buf_price-list.doc-qnty       when buf_price-list.doc-qnty <> ?
         v-price-list-price-sale_old
         ( buf_price-list.doc-qnty * v-price-list-price-sale_old )   @ v-old-sum
         buf_price-list.price-sale
         ( buf_price-list.doc-qnty * buf_price-list.price-sale )     @ v-new-sum
         (( buf_price-list.price-sale - v-price-list-price-sale_old ) * buf_price-list.doc-qnty )  @ v-delta
         sym1
         sym2
         sym3
         sym4
         sym5
         sym6
         sym7
         sym8
         sym9
         sym10
         sym11
         sym12
      with frame f-tap .
      down stream outstream 1 with frame f-tap .
define variable vss-include-info13 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    if hvrdtax (recid(buf_goods))
    then do:
        run tax-name (  input 'rdt':U
                      , output v-taxname
                     ).
        assign
            v-tax       = buf_price-list.road-tax * buf_price-list.doc-qnty
            v-tax-sum   = v-tax-sum + v-tax
        .
         for each buf_parts
         where buf_parts.obj-type         = buf_price-list.obj-type
               and buf_parts.obj-code     = buf_price-list.obj-code
               and buf_parts.artic        = buf_price-list.artic
               and buf_parts.prod-type    = buf_price-list.prod-type
               and buf_parts.prod-code    = buf_price-list.prod-code
               and buf_parts.out-code     = buf_price-list.doc-num
         break by buf_parts.road-tax-rubl
         :
               if first-of( buf_parts.road-tax-rubl )
               then do:
                  assign
                     v-tax-parts-qnty  = 0
                  .
               end.
               assign
                  v-tax-parts-qnty    = v-tax-parts-qnty  + buf_parts.fact-qnty
               .
               if last-of( buf_parts.road-tax-rubl )
               then do:
                  display stream outstream
                     "     В том числе"                                  @ buf_price-list.artic
                     v-taxname                                           @ buf_goods.gds-name
                     v-tax-parts-qnty          @ buf_price-list.doc-qnty
                     buf_goods.unit-base
                     buf_parts.road-tax-rubl                             @ buf_price-list.price-sale
                     v-tax-parts-qnty * buf_parts.road-tax-rubl              @ v-new-sum
                     sym1
                     sym2
                     sym3
                     sym4
                     sym5
                     sym6
                     sym7
                     sym8
                     sym9
                     sym10
                     sym11
                     sym12
                  with frame f-tap
                  .
                  down stream outstream 1
                  with frame f-tap  .
                  RUN tap1-sheet1-write-line-data IN THIS-PROCEDURE
                     ( INPUT "":U
                     , INPUT "В том числе"
                     , INPUT v-taxname
                     , INPUT "":U
                     , INPUT buf_goods.unit-base
                     , INPUT v-tax-parts-qnty
                     , INPUT "":U
                     , INPUT "":U
                     , INPUT buf_parts.road-tax-rubl
                     , INPUT ( v-tax-parts-qnty * buf_parts.road-tax-rubl )
                     , INPUT "":U
                     ) .
               end.
         end.
    end.
      RUN tap1-sheet1-write-line-data IN THIS-PROCEDURE
         ( INPUT v-line-counter
         , INPUT buf_price-list.artic
         , INPUT v-gds-prt-node-name
         , INPUT "":U
         , INPUT buf_goods.unit-base
         , INPUT buf_price-list.doc-qnty
         , INPUT v-price-list-price-sale_old
         , INPUT ( buf_price-list.doc-qnty * v-price-list-price-sale_old )
         , INPUT buf_price-list.price-sale
         , INPUT ( buf_price-list.doc-qnty * buf_price-list.price-sale )
         , INPUT (( buf_price-list.price-sale - v-price-list-price-sale_old ) * buf_price-list.doc-qnty )
         ) .
   end.
end.
end procedure.
