block-level on error undo, throw.
/*

$Revision: 5260d850f792, 2610, rls $
$Author: SSlivenko $
$Date: 2020/10/19 06:22:02 $
$Workfile: shtoper.p $
$Archive: bge/shtoper.p $

Экспорт XML смены

Автор: Хныкин Павел Андреевич
Дата создания: 10/24/05
Author: Pavel Khnykin
Creation date: 10/24/05

Input:

Output:

*/

define input parameter p-host-code          as character        no-undo.
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-shift-date         as date             no-undo.
define input parameter p-shift-num          as integer          no-undo.
define input parameter p-xml-file-name      as character        no-undo.
define input parameter p-log-file-name      as character        no-undo.
define input parameter p-bge-editor-handle  as handle           no-undo.
define input parameter p-bge-fillin-handle  as handle           no-undo.

define variable vss-revision    as character no-undo init "$Revision: 5260d850f792, 2610, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: 2020/10/19 06:22:02 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: shtoper.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/shtoper.p $":U .
define variable vss-description as character no-undo init "Экспорт XML смены".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ bge/bge-xml.i  }
{ gbl/clntattr.i }
{ str/wth-lib.i  }
{ str/lib-trn.i  }
{ cmp/obj-list.i new } /* нужен для rep/fostatok.i */
{ rep/fostatok.i  &arh-name = "arh-fin-doc-schet-nal-obj" }
{ str/trdcalib.i }

define variable conf-par as character no-undo . /* чтобы прочесть is-wth через conf-rd.i */
define variable par-type as character no-undo . /* чтобы прочесть is-wth через conf-rd.i */
define variable is-wth   as logical   no-undo . /* is-wth true:включены МЦ в системе */


define temp-table temp_payDeskZOrder no-undo
  field pay-desk as integer
  field z-number as integer
  field sum      as decimal

  index pi is primary unique
  pay-desk
  z-number
.
define temp-table temp_sumWthInkasToBank no-undo
  field wth-code as integer
  field wth-name as character
  field fact-sum as decimal

  index pi is primary unique
  wth-code
.
define temp-table temp_sumWthInternal no-undo
  field wth-code as integer
  field wth-name as character
  field fact-sum as decimal

  index pi is primary unique
  wth-code
.
define temp-table temp_stkWthInPlace no-undo
  field w-p-code    as integer
  field wth-code    as integer
  field w-p-name    as character
  field wth-name    as character
  field stock-start as decimal
  field stock-end   as decimal

  index pi is primary unique
  w-p-code
  wth-code
.
define temp-table temp_techPro no-undo
  field artic         as character
  field prod-type     as character
  field prod-code     as integer
  field gds-code      as integer
  field gds-name      as character
  field envd          as logical
  field fact-qnty     as decimal
  field pl-code       as integer
  field qnty          as decimal
  field cli-qnty      as decimal
  field state-density as decimal

  index pi is primary unique
  artic
  prod-type
  prod-code
.


define temp-table temp_chk-doc no-undo
  field gds-code      as integer
  field b-code        as integer
  field fact-qnty     as decimal
  field pl-code       as integer
  field qnty          as decimal
  field cli-qnty      as decimal
  field state-density as decimal
  field chk-date      as date
  FIELD doc-code      as character
  FIELD doc-num2      as character
  FIELD doc-num       as character
  FIELD chk-num       as integer
  FIELD chk-time      as integer
  FIELD cashier       as integer
  field pay-desk      as integer
  field pump          as decimal
  field nozzle-code   as integer
  field sum-qnty      as decimal
  field sum-cli-qnty  as decimal
  field chk-type      as integer
  field netto         as decimal
  index pi is primary unique
  doc-code
.

define temp-table temp_chk-gds no-undo
  field gds-code    as integer
  field b-code      as integer
  field pl-code     as integer
  field qnty        as decimal
  FIELD doc-code    as character
  field pump        as decimal
  field nozzle-code as integer
  field line-num    as INTEGER
  field sbros-type  as character
  field src-sum     as decimal
  field OFDcode     as character
  field OFDvalue    as decimal
  index pi is primary unique
  b-code
  doc-code
  line-num
.


define temp-table temp_stkShiftOpen no-undo
  field gds-code  as integer
  field artic     as character
  field prod-type as character
  field prod-code as integer
  field gds-name  as character
  field envd      as logical
  field qnty      as decimal
  field cli-qnty  as decimal

  index pi is primary unique
  gds-code
.
define temp-table temp_stkPlShiftOpen no-undo
  field gds-code           as integer
  field pl-code            as integer
  field qnty               as decimal
  field cli-qnty           as decimal
  field state-density      as decimal
  field state-add-quantity as decimal
  field system-qnty        as decimal
  field systen-cli-qnty    as decimal
  field temperature        as decimal 
  field level-petrol       as decimal
  field level-water        as decimal
  field level-total        as decimal
  index pi is primary unique
  gds-code
  pl-code
.
define temp-table temp_stkTrkShiftOpen no-undo
  field pl-code      as integer
  field pump-code    as integer
  field nozzle-code  as integer
  field gds-code     as integer
  field state-mh-cnt as decimal

  index pi is primary unique
  pl-code
  pump-code
  nozzle-code
  index igds
  gds-code
.


define temp-table temp_stkShiftEnd no-undo
  field gds-code  as integer
  field artic     as character
  field prod-type as character
  field prod-code as integer
  field gds-name  as character
  field envd      as logical
  field qnty      as decimal
  field cli-qnty  as decimal

  index pi is primary unique
  gds-code
.
define temp-table temp_stkPlShiftEnd no-undo
  field gds-code           as integer
  field pl-code            as integer
  field qnty               as decimal
  field cli-qnty           as decimal
  field state-density      as decimal
  field state-add-quantity as decimal
  field system-qnty        as decimal
  field systen-cli-qnty    as decimal
  field temperature        as decimal 
  field level-petrol       as decimal
  field level-total        as decimal 
  field level-water        as decimal
  index pi is primary unique
  gds-code
  pl-code
.
define temp-table temp_stkTrkShiftEnd no-undo
  field pl-code      as integer
  field pump-code    as integer
  field nozzle-code  as integer
  field gds-code     as integer
  field state-mh-cnt as decimal

  index pi is primary unique
  pl-code
  pump-code
  nozzle-code
  index igds
  gds-code
.


define temp-table temp_stkTNP no-undo
  field artic         as character
  field prod-type     as character
  field prod-code     as integer
  field gds-code      as integer
  field gds-name      as character
  field envd          as logical
  field end-sumSale   as decimal
  field end-qnty      as decimal
  field end-sumVat    as decimal
  field start-sumSale as decimal
  field start-sumVat  as decimal

  index pi is primary unique
  artic
  prod-type
  prod-code
.
define temp-table temp_sumPriceSale no-undo
  field artic     as character
  field prod-type as character
  field prod-code as integer
  field gds-code  as integer
  field gds-name  as character
  field envd      as logical
  field sumSale   as decimal
  field sumVat    as decimal

  index pi is primary unique
  artic
  prod-type
  prod-code
.


do
on error undo, return error
:

  { gbl/conf-rd.i
"'is-wth'"
0
"''"
0
"''"
"''"
"''"
yes
conf-par
par-type
no-error
}
  IF not error-status:error then is-wth = (conf-par = "yes":U).

  output stream stmXMLOut to value( p-xml-file-name + "xm1" ) convert target "1251" append.
  run export-shift in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input p-shift-date
      , input p-shift-num
  ) no-error.
  if error-status :error then do:
    run wp-XMLWriteLog in this-procedure (
            input p-log-file-name
          , input 1
          , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
                                  , vss-description
                                  , "основных данных смены"
                                  , return-value
                                  , trim(error-status :get-message(1))
                                  , trim(error-status :get-message(2))
                          )
    ).
  end.
  run export-shift-staff in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input p-shift-date
      , input p-shift-num
  ) no-error.
  if error-status :error then do:
    run wp-XMLWriteLog in this-procedure (
            input p-log-file-name
          , input 1
          , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
                                  , vss-description
                                  , "списка операторов"
                                  , return-value
                                  , trim(error-status :get-message(1))
                                  , trim(error-status :get-message(2))
                          )
    ).
  end.
  run export-pay-desk-z-order in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input p-shift-date
      , input p-shift-num
  ) no-error.
  if error-status :error then do:
    run wp-XMLWriteLog in this-procedure (
            input p-log-file-name
          , input 1
          , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
                                  , vss-description
                                  , "сумм z-отчётов"
                                  , return-value
                                  , trim(error-status :get-message(1))
                                  , trim(error-status :get-message(2))
                          )
    ).
  end.

  if is-wth then 
  do:
    run export-sum-wth in this-procedure (
        input p-host-code
      , input p-obj-type
      , input p-obj-code
      , input p-shift-date
      , input p-shift-num
    ) no-error.
    if error-status :error then do:
      run wp-XMLWriteLog in this-procedure (
            input p-log-file-name
          , input 1
          , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
                                  , vss-description
                                  , "инкассированных и взятых для внутренних нужд средств"
                                  , return-value
                                  , trim(error-status :get-message(1))
                                  , trim(error-status :get-message(2))
                          )
      ).
    end.
    run export-stk-wth-in-place in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input p-shift-date
      , input p-shift-num
    ) no-error.
    if error-status :error then do:
      run wp-XMLWriteLog in this-procedure (
            input p-log-file-name
          , input 1
          , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
                                  , vss-description
                                  , "остатков в кассах"
                                  , return-value
                                  , trim(error-status :get-message(1))
                                  , trim(error-status :get-message(2))
                          )
      ).
    end.
  end.

  run export-techPro in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input p-shift-date
      , input p-shift-num
  ) no-error.
  if error-status :error then do:
    run wp-XMLWriteLog in this-procedure (
            input p-log-file-name
          , input 1
          , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
                                  , vss-description
                                  , "технологической прокачки"
                                  , return-value
                                  , trim(error-status :get-message(1))
                                  , trim(error-status :get-message(2))
                          )
    ).
  end.

  run export-techChk in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input p-shift-date
      , input p-shift-num
  ) no-error.
  if error-status :error then do:
    run wp-XMLWriteLog in this-procedure (
            input p-log-file-name
          , input 1
          , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
                                  , vss-description
                                  , "технологические чеки"
                                  , return-value
                                  , trim(error-status :get-message(1))
                                  , trim(error-status :get-message(2))
                          )
    ).
  end.
  
  run export-CorrChk in this-procedure (
    input p-obj-type
    , input p-obj-code
    , input p-shift-date
    , input p-shift-num
    ) no-error.
  if error-status :error then do:
    run wp-XMLWriteLog in this-procedure (
      input p-log-file-name
      , input 1
      , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
      , vss-description
      , "чеков коррекции"
      , return-value
      , trim(error-status :get-message(1))
      , trim(error-status :get-message(2))
      )
      ).
  end.

  run export-stkShift in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input p-shift-date
      , input p-shift-num

  ) no-error.
  if error-status :error then do:
    run wp-XMLWriteLog in this-procedure (
            input p-log-file-name
          , input 1
          , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
                                  , vss-description
                                  , "остатков топлива"
                                  , return-value
                                  , trim(error-status :get-message(1))
                                  , trim(error-status :get-message(2))
                          )
    ).
  end.

  run export-stkTNP in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input p-shift-date
      , input p-shift-num
  ) no-error.
  if error-status :error then do:
    run wp-XMLWriteLog in this-procedure (
            input p-log-file-name
          , input 1
          , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
                                  , vss-description
                                  , "товарных остатков ТНП"
                                  , return-value
                                  , trim(error-status :get-message(1))
                                  , trim(error-status :get-message(2))
                          )
    ).
  end.
  run export-invTRK in this-procedure (
    input p-obj-type
    , input p-obj-code
    , input p-shift-date
    , input p-shift-num
  ) no-error.
  if error-status :error then do:
    run wp-XMLWriteLog in this-procedure (
      input p-log-file-name
      , input 1
      , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
      , vss-description
      , "товарных остатков ТНП"
      , return-value
      , trim(error-status :get-message(1))
      , trim(error-status :get-message(2))
      )
      ).
  end.
  run export-price-sum in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input p-shift-date
      , input p-shift-num
  ) no-error.
  if error-status :error then do:
    run wp-XMLWriteLog in this-procedure (
            input p-log-file-name
          , input 1
          , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
                                  , vss-description
                                  , "сумм переоценок за смену"
                                  , return-value
                                  , trim(error-status :get-message(1))
                                  , trim(error-status :get-message(2))
                          )
    ).
  end.
  run export-stk-den in this-procedure (
    input p-host-code
    , input p-obj-type
    , input p-obj-code
    , input p-shift-date
    , input p-shift-num
    ) no-error.
  if error-status :error
    then 
  do:
    run wp-XMLWriteLog in this-procedure (
      input p-log-file-name
      , input 1
      , input substitute( "&1. Ошибка выгрузки &2. &3. &4. &5."
      , vss-description
      , "остатков денежных средств"
      , return-value
      , trim(error-status :get-message(1))
      , trim(error-status :get-message(2))
      )
      ).
  end.
  output stream stmxmlout close.
end.


/*==========================================================================*/
procedure export-shift :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-shift-date as date             no-undo.
define input parameter p-shift-num  as integer          no-undo.

  define buffer buf_shift-obj for ub.shift-obj.
  define buffer buf_clients   for ub.clients.
do
for buf_shift-obj
  , buf_clients
on error undo, return error
:
    find first buf_shift-obj no-lock
         where buf_shift-obj.obj-type   = p-obj-type
           and buf_shift-obj.obj-code   = p-obj-code
           and buf_shift-obj.shift-date = p-shift-date
           and buf_shift-obj.shift-num  = p-shift-num
    .
    find first buf_clients no-lock
         where buf_clients.obj-type = p-obj-type
           and buf_clients.obj-code = p-obj-code
    .
    run wp-xmltagopen( input 2, input "shift", input "" ).
    run wp-xmltagput( input 3, "objType"    , input string( buf_shift-obj.obj-type                  ), input 0 ).
    run wp-xmltagput( input 3, "objCode"    , input string( buf_shift-obj.obj-code                  ), input 0 ).
    run wp-xmltagput( input 3, "objName"    , input string( buf_clients.obj-name                    ), input 0 ).
    run wp-xmltagput( input 3, "shiftNum"   , input string( buf_shift-obj.shift-num                 ), input 0 ).
    run wp-xmltagput( input 3, "shiftName"  , input string( buf_shift-obj.shift-name                ), input 0 ).
    run wp-xmltagput( input 3, "shiftDate"  , input string( buf_shift-obj.shift-date, "99.99.9999"  ), input 0 ).
    run wp-xmltagput( input 3, "shiftTime"  , input string( buf_shift-obj.open-time, "HH:MM:SS"     ), input 0 ).
    run wp-xmltagput( input 3, "shiftEndDate"  , input string( buf_shift-obj.close-date, "99.99.9999"  ), input 0 ).
    run wp-xmltagput( input 3, "shiftEndTime"  , input string( buf_shift-obj.close-time, "HH:MM:SS"     ), input 0 ).

    run wp-xmltagclose( input 2, input "shift" ).
  end.
end procedure. /* export-shift */


/*==========================================================================*/
procedure export-shift-staff :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-shift-date as date             no-undo.
define input parameter p-shift-num  as integer          no-undo.

  define buffer buf_shift-staff for ub.shift-staff.
do
for buf_shift-staff
on error undo, return error
:
    for each buf_shift-staff no-lock
       where buf_shift-staff.obj-type   = p-obj-type
         and buf_shift-staff.obj-code   = p-obj-code
         and buf_shift-staff.shift-date = p-shift-date
         and buf_shift-staff.shift-num  = p-shift-num
         and buf_shift-staff.next-shift = no
         and buf_shift-staff.psn-num   >= 0
    by buf_shift-staff.staff-role descending
    on error undo, return error
    :
      run wp-xmltagopen( input 2, input "shiftStaff", input "" ).
      run wp-xmltagput( input 3, "objType"    , input string( buf_shift-staff.obj-type                  ), input 0 ).
      run wp-xmltagput( input 3, "objCode"    , input string( buf_shift-staff.obj-code                  ), input 0 ).
      run wp-xmltagput( input 3, "shiftDate"  , input string( buf_shift-staff.shift-date, "99.99.9999"  ), input 0 ).
      run wp-xmltagput( input 3, "shiftNum"   , input string( buf_shift-staff.shift-num                 ), input 0 ).
      run wp-xmltagput( input 3, "stfPsnCode" , input string( buf_shift-staff.psn-code                  ), input 0 ).
      run wp-xmltagput( input 3, "stfName"    , input string( buf_shift-staff.name                      ), input 0 ).
      run wp-xmltagput( input 3, "stfCashier" , input string( ( buf_shift-staff.cashier <> 0 )          ), input 2 ).
      run wp-xmltagclose( input 2, input "shiftStaff" ).
    end.        /* for each buf_shift-staff */
  end.
end procedure. /* export-shift-staff */


/*==========================================================================*/
procedure export-pay-desk-z-order :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-shift-date as date             no-undo.
define input parameter p-shift-num  as integer          no-undo.

  define buffer buf_chk-doc for ub.chk-doc.
do
for buf_chk-doc
on error undo, return error
:
    empty temp-table temp_payDeskZOrder.
    for each buf_chk-doc no-lock
       where buf_chk-doc.obj-type   = p-obj-type
         and buf_chk-doc.obj-code   = p-obj-code
         and buf_chk-doc.shift-date = p-shift-date
         and buf_chk-doc.shift-num  = p-shift-num
    :
      if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next.
      /*только за вычето таких чеков имеет смысл сичтать*/
      find first temp_payDeskZOrder
           where temp_payDeskZOrder.pay-desk = buf_chk-doc.pay-desk
             and temp_payDeskZOrder.z-number = buf_chk-doc.z-number
      no-error.
      if not available temp_payDeskZOrder
      then do:
        create temp_payDeskZOrder.
        assign
          temp_payDeskZOrder.pay-desk = buf_chk-doc.pay-desk
          temp_payDeskZOrder.z-number = buf_chk-doc.z-number
        .
      end.
      assign
        temp_payDeskZOrder.sum = temp_payDeskZOrder.sum + buf_chk-doc.netto
      .
    end.
    for each temp_payDeskZOrder
    :
      if temp_payDeskZOrder.sum <> 0 then do:
        run wp-xmltagopen( input 2, input "shiftPayDeskZOrder", input "" ).
        run wp-xmltagput( input 3, "objType"    , input string( p-obj-type                  ), input 0 ).
        run wp-xmltagput( input 3, "objCode"    , input string( p-obj-code                  ), input 0 ).
        run wp-xmltagput( input 3, "shiftDate"  , input string( p-shift-date, "99.99.9999"  ), input 0 ).
        run wp-xmltagput( input 3, "shiftNum"   , input string( p-shift-num                 ), input 0 ).
        run wp-xmltagput( input 3, "pdzPayDesk" , input string( temp_payDeskZOrder.pay-desk ), input 0 ).
        run wp-xmltagput( input 3, "pdzZOrder"  , input string( temp_payDeskZOrder.z-number ), input 0 ).
        run wp-xmltagput( input 3, "pdzSum"     , input string( temp_payDeskZOrder.sum      ), input 0 ).
        run wp-xmltagclose( input 3, input "shiftPayDeskZOrder").
      end.
    end.
  end.
end procedure. /* export-pay-desk-z-order */


/*==========================================================================*/
procedure export-sum-wth :
define input parameter p-host-code  as integer          no-undo.
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-shift-date as date             no-undo.
define input parameter p-shift-num  as integer          no-undo.

  define variable v-is-inkassator as character no-undo.
  define variable v-attr-type     as character no-undo.
  define variable v-sale-type     as character no-undo.
  define variable v-sale-code     as integer   no-undo.

  define buffer buf_clients                for ub.clients.
  define buffer buf_wth-doc                for ub.wth-doc.
  define buffer buf_wth-line               for ub.wth-line.
  define buffer buf_wealth                 for ub.wealth.
  define buffer buf_sysconf                for ub.sysconf.
  define buffer buf_temp_sumWthInkasToBank for temp_sumWthInkasToBank.
  define buffer buf_temp_sumWthInternal    for temp_sumWthInternal.
do
for buf_clients
  , buf_wth-doc
  , buf_wth-line
  , buf_wealth
  , buf_temp_sumWthInkasToBank
  , buf_temp_sumWthInternal
on error undo, return error
:
    empty temp-table buf_temp_sumWthInkasToBank.
    empty temp-table buf_temp_sumWthInternal.
    find first buf_sysconf no-lock
         where buf_sysconf.host-code = p-host-code
    no-error.
    if available buf_sysconf then do:
      assign
        v-sale-type = buf_sysconf.sale-type
        v-sale-code = buf_sysconf.sale-code
      .
    end.
    else do:
      assign
        v-sale-type = "":U
        v-sale-code = 0
      .
    end.
    see-all-clients:
    for each buf_clients no-lock
    on error undo, return error
    :
      if buf_clients.obj-type  = v-sale-type
      and buf_clients.obj-code = v-sale-code
      then do:
        undo see-all-clients, next see-all-clients.
      end.
      run clntattr-value in this-procedure (
            input buf_clients.obj-type
          , input buf_clients.obj-code
          , input {&attr-is-inkassator}
          , output v-is-inkassator
          , output v-attr-type
      ).
      if v-is-inkassator = "yes":U
      then do:
        if buf_clients.obj-type = {&cmp}
        then do:
          for each buf_wth-doc no-lock
             where buf_wth-doc.obj-type   = p-obj-type
               and buf_wth-doc.obj-code   = p-obj-code
               and buf_wth-doc.shift-date = p-shift-date
               and buf_wth-doc.shift-num  = p-shift-num
               and buf_wth-doc.status_    = {&fact}
               and buf_wth-doc.doc-type   = {&expense}
          use-index sht-clos
          on error undo, return error
          :
            if  buf_wth-doc.cli-type   = buf_clients.obj-type
            and buf_wth-doc.cli-code   = buf_clients.obj-code
            then do:
              for each buf_wth-line no-lock
                 where buf_wth-line.doc-code = buf_wth-doc.doc-code
              on error undo, return error
              :
                if buf_wth-line.status_ = {&fact}
                then do:
                  find first buf_temp_sumWthInkasToBank
                       where buf_temp_sumWthInkasToBank.wth-code = buf_wth-line.wth-code
                  no-error.
                  if not available buf_temp_sumWthInkasToBank
                  then do:
                    create buf_temp_sumWthInkasToBank.
                    assign
                      buf_temp_sumWthInkasToBank.wth-code = buf_wth-line.wth-code
                    .
                    find first buf_wealth no-lock
                         where buf_wealth.wth-code = buf_wth-line.wth-code
                    no-error.
                    if available buf_wealth
                    then do:
                      assign
                        buf_temp_sumWthInkasToBank.wth-name = buf_wealth.wth-name
                      .
                    end.
                  end.
                  assign
                    buf_temp_sumWthInkasToBank.fact-sum = buf_temp_sumWthInkasToBank.fact-sum + buf_wth-line.fact-sum
                  .
                end.
              end.        /* for each buf_wth-line */
            end.
          end.        /* for each buf_wth-doc */
        end.        /* buf_clients.obj-type = {&cmp} */
      end.        /* if v-is-inkassator = "yes":U */
      else do:
        if buf_clients.host-code <> p-host-code
        and ( buf_clients.obj-type <> p-obj-type
           or buf_clients.obj-code <> p-obj-code )
        then do:
          for each buf_wth-doc no-lock
             where buf_wth-doc.obj-type   = p-obj-type
               and buf_wth-doc.obj-code   = p-obj-code
               and buf_wth-doc.shift-date = p-shift-date
               and buf_wth-doc.shift-num  = p-shift-num
               and buf_wth-doc.status_    = {&fact}
               and buf_wth-doc.doc-type   = {&expense}
          use-index sht-clos
          on error undo, return error
          :
            if  buf_wth-doc.cli-type   = buf_clients.obj-type
            and buf_wth-doc.cli-code   = buf_clients.obj-code
            then do:
              for each buf_wth-line no-lock
                 where buf_wth-line.doc-code = buf_wth-doc.doc-code
              on error undo, return error
              :
                if buf_wth-line.status_ = {&fact}
                then do:
                  find first buf_temp_sumWthInternal
                       where buf_temp_sumWthInternal.wth-code = buf_wth-line.wth-code
                  no-error.
                  if not available buf_temp_sumWthInternal
                  then do:
                    create buf_temp_sumWthInternal.
                    assign
                      buf_temp_sumWthInternal.wth-code = buf_wth-line.wth-code
                    .
                    find first buf_wealth no-lock
                         where buf_wealth.wth-code = buf_wth-line.wth-code
                    no-error.
                    if available buf_wealth
                    then do:
                      assign
                        buf_temp_sumWthInternal.wth-name = buf_wealth.wth-name
                      .
                    end.
                  end.
                  assign
                    buf_temp_sumWthInternal.fact-sum = buf_temp_sumWthInternal.fact-sum + buf_wth-line.fact-sum
                  .
                end.
              end.        /* for each buf_wth-line */
            end.
          end.        /* for each buf_wth-doc */
        end.
      end.        /* if NOT ( v-is-inkassator = "yes":U ) */
    end.        /* for each buf_clients */
    for each buf_temp_sumWthInkasToBank
    :
      if buf_temp_sumWthInkasToBank.fact-sum <> 0
      then do:
        run wp-xmltagopen( input 2, input "sumWthInkasToBank", input "" ).
        run wp-xmltagput( input 3, "objType"    , input string( p-obj-type                          ), input 0 ).
        run wp-xmltagput( input 3, "objCode"    , input string( p-obj-code                          ), input 0 ).
        run wp-xmltagput( input 3, "shiftDate"  , input string( p-shift-date, "99.99.9999"          ), input 0 ).
        run wp-xmltagput( input 3, "shiftNum"   , input string( p-shift-num                         ), input 0 ).
        run wp-xmltagput( input 3, "itbWthCode" , input string( buf_temp_sumWthInkasToBank.wth-code  ), input 0 ).
        run wp-xmltagput( input 3, "itbWthName" , input string( buf_temp_sumWthInkasToBank.wth-name  ), input 0 ).
        run wp-xmltagput( input 3, "itbWthSum"  , input string( buf_temp_sumWthInkasToBank.fact-sum  ), input 0 ).
        run wp-xmltagclose( input 3, input "sumWthInkasToBank").
      end.
    end.
    for each buf_temp_sumWthInternal
    :
      if buf_temp_sumWthInternal.fact-sum <> 0
      then do:
        run wp-xmltagopen( input 2, input "sumWthInternal", input "" ).
        run wp-xmltagput( input 3, "objType"    , input string( p-obj-type                          ), input 0 ).
        run wp-xmltagput( input 3, "objCode"    , input string( p-obj-code                          ), input 0 ).
        run wp-xmltagput( input 3, "shiftDate"  , input string( p-shift-date, "99.99.9999"          ), input 0 ).
        run wp-xmltagput( input 3, "shiftNum"   , input string( p-shift-num                         ), input 0 ).
        run wp-xmltagput( input 3, "inWthCode"  , input string( buf_temp_sumWthInternal.wth-code       ), input 0 ).
        run wp-xmltagput( input 3, "inWthName"  , input string( buf_temp_sumWthInternal.wth-name       ), input 0 ).
        run wp-xmltagput( input 3, "inWthSum"   , input string( buf_temp_sumWthInternal.fact-sum      ), input 0 ).
        run wp-xmltagclose( input 3, input "sumWthInternal").
      end.
    end.
  end.
end procedure. /* export-sumWthInkasToBank */


/*==========================================================================*/
procedure export-stk-wth-in-place :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-shift-date as date             no-undo.
define input parameter p-shift-num  as integer          no-undo.

  define variable v-stock-start  as decimal no-undo.
  define variable v-stock-end    as decimal no-undo.
  define variable v-income       as decimal no-undo.
  define variable v-income-cassa as decimal no-undo.
  define variable v-income-other as decimal no-undo.
  define variable v-incass       as decimal no-undo.
  define variable v-incass-bank  as decimal no-undo.
  define variable v-incass-other as decimal no-undo.
  define variable v-incass-cassa as decimal no-undo.

  define buffer buf_wth-place          for ub.wth-place.
  define buffer buf_wth-pobj           for ub.wth-pobj.
  define buffer buf_wealth             for ub.wealth.
  define buffer buf_temp_stkWthInPlace for temp_stkWthInPlace.
do
for buf_wth-place
  , buf_wth-pobj
  , buf_wealth
  , buf_temp_stkWthInPlace
on error undo, return error
:
    empty temp-table buf_temp_stkWthInPlace.
    for each buf_wth-place no-lock
       where buf_wth-place.obj-type     = p-obj-type
         and buf_wth-place.obj-code     = p-obj-code
         and buf_wth-place.cash-desk    <> ?
    :
      for each buf_wth-pobj no-lock
         where buf_wth-pobj.obj-type  = p-obj-type
           and buf_wth-pobj.obj-code  = p-obj-code
           and buf_wth-pobj.w-p-code  = buf_wth-place.w-p-code
      on error undo, return error
      :
        run wth-lib_full-inf-shift-place in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input buf_wth-pobj.wth-code
            , input buf_wth-pobj.w-p-code
            , input p-shift-date
            , input p-shift-num
            , output v-stock-start
            , output v-stock-end
            , output v-income
            , output v-income-cassa
            , output v-income-other
            , output v-incass
            , output v-incass-bank
            , output v-incass-other
            , output v-incass-cassa
        ).
        find first buf_temp_stkWthInPlace
             where buf_temp_stkWthInPlace.w-p-code = buf_wth-pobj.w-p-code
               and buf_temp_stkWthInPlace.wth-code = buf_wth-pobj.wth-code
        no-error.
        if not available buf_temp_stkWthInPlace
        then do:
          create buf_temp_stkWthInPlace.
          assign
            buf_temp_stkWthInPlace.w-p-code    = buf_wth-pobj.w-p-code
            buf_temp_stkWthInPlace.wth-code    = buf_wth-pobj.wth-code
            buf_temp_stkWthInPlace.w-p-name    = buf_wth-place.w-p-name
            buf_temp_stkWthInPlace.stock-start = v-stock-start
            buf_temp_stkWthInPlace.stock-end   = v-stock-end
          .
          find first buf_wealth no-lock
               where buf_wealth.wth-code = buf_wth-pobj.wth-code
          no-error.
          if available buf_wealth
          then do:
            assign
              buf_temp_stkWthInPlace.wth-name = buf_wealth.wth-name
            .
          end.
        end.
      end.        /* for each buf_wth-pobj */
    end.
    for each buf_temp_stkWthInPlace
    :
      if buf_temp_stkWthInPlace.stock-start <> 0
      or buf_temp_stkWthInPlace.stock-end <> 0
      then do:
        run wp-xmltagopen( input 2, input "stkWthInPlace", input "" ).
        run wp-xmltagput( input 3, "objType"        , input string( p-obj-type                            ), input 0 ).
        run wp-xmltagput( input 3, "objCode"        , input string( p-obj-code                            ), input 0 ).
        run wp-xmltagput( input 3, "shiftDate"      , input string( p-shift-date, "99.99.9999"            ), input 0 ).
        run wp-xmltagput( input 3, "shiftNum"       , input string( p-shift-num                           ), input 0 ).
        run wp-xmltagput( input 3, "swpWPCode"      , input string( buf_temp_stkWthInPlace.w-p-code       ), input 0 ).
        run wp-xmltagput( input 3, "swpWthCode"     , input string( buf_temp_stkWthInPlace.wth-code       ), input 0 ).
        run wp-xmltagput( input 3, "swpWPName"      , input string( buf_temp_stkWthInPlace.w-p-name       ), input 0 ).
        run wp-xmltagput( input 3, "swpWthName"     , input string( buf_temp_stkWthInPlace.wth-name       ), input 0 ).
        run wp-xmltagput( input 3, "swpStockStart"  , input string( buf_temp_stkWthInPlace.stock-start    ), input 0 ).
        run wp-xmltagput( input 3, "swpStockEnd"    , input string( buf_temp_stkWthInPlace.stock-end      ), input 0 ).
        run wp-xmltagclose( input 3, input "stkWthInPlace").
      end.
    end.
  end.
end procedure. /* export-stk-wth-in-place */


/*==========================================================================*/
procedure export-techPro :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-shift-date as date             no-undo.
define input parameter p-shift-num  as integer          no-undo.

  define variable v-shftrep2   as character no-undo.
  define variable v-attr-value as character no-undo.
  define variable v-attr-type  as character no-undo.

  define buffer buf_clients        for ub.clients.
  define buffer buf_trn-doc        for ub.trn-doc.
  define buffer buf_doc-line       for ub.doc-line.
  define buffer buf_goods          for ub.goods.
  define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
  define buffer buf_temp_techPro   for temp_techPro.
  define buffer buf_doc-pl         for ub.doc-pl.
  define buffer buf_chk-gds        for ub.chk-gds.
  define buffer buf_chk-gds-pay    for ub.chk-gds-pay.
  DEFINE buffer buf_chk-doc        for ub.chk-doc.
  define buffer buf_temp_chk-doc   for temp_chk-doc.
  define buffer buf_bar-code       for ub.bar-code.
do
for buf_clients
  , buf_trn-doc
  , buf_doc-line
  , buf_goods
  , buf_temp_techPro
  , buf_doc-pl
  , buf_chk-gds
  , buf_bar-code
on error undo, return error
:
    empty temp-table buf_temp_techPro.

    for each buf_clients no-lock
    on error undo, return error
    :
      run clntattr-value in this-procedure ( input buf_clients.obj-type
                                             , input buf_clients.obj-code
                                             , input {&attr-shftrep2}
                                             , output v-shftrep2
                                             , output v-attr-type
                                           ).
      if v-shftrep2 = "yes":U
      then do:
        sum-all-trn-doc-tech-pro:
        for each buf_trn-doc no-lock
           where buf_trn-doc.obj-type   = p-obj-type
             and buf_trn-doc.obj-code   = p-obj-code
             and buf_trn-doc.shift-date = p-shift-date
             and buf_trn-doc.shift-num  = p-shift-num
             and buf_trn-doc.status_    = {&fact}
            on error undo, return error
            :
          def var v-value as character no-undo.
          def var v-type  as character no-undo.
          def var v-tech-pass as logical no-undo.
          { str/tdat-val.i                                    
            buf_trn-doc.doc-code
            {&trdcattr-techpass}
            v-value 
            v-type 
            no-error
          }
          assign
            v-tech-pass = yes when v-value = "yes".
          if  buf_trn-doc.cli-type = buf_clients.obj-type   and
              buf_trn-doc.cli-code = buf_clients.obj-code   and
              buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh}
          then do:
            if not (v-tech-pass or can-find(first ub.sale-doc where ub.sale-doc.doc-code = buf_trn-doc.doc-code and ub.sale-doc.doc-kind = {&sale-add-tech-refuell}))
              then 
            do:
              /* это не техпролив */
              undo sum-all-trn-doc-tech-pro, next sum-all-trn-doc-tech-pro.
            end.

            for each buf_doc-line no-lock
               where buf_doc-line.doc-code = buf_trn-doc.doc-code
              on error undo, return error
              :
              find first buf_temp_techPro
                   where buf_temp_techPro.artic       = buf_doc-line.artic
                     and buf_temp_techPro.prod-type   = buf_doc-line.prod-type
                     and buf_temp_techPro.prod-code   = buf_doc-line.prod-code
                no-error.
              if not available buf_temp_techPro then do:
                create buf_temp_techPro.
                assign
                  buf_temp_techPro.artic     = buf_doc-line.artic
                  buf_temp_techPro.prod-type = buf_doc-line.prod-type
                  buf_temp_techPro.prod-code = buf_doc-line.prod-code
                .
                find first buf_goods no-lock
                     where buf_goods.artic     = buf_temp_techPro.artic
                       and buf_goods.prod-type = buf_temp_techPro.prod-type
                       and buf_goods.prod-code = buf_temp_techPro.prod-code
                  no-error.
                if available buf_goods then do:
                  assign
                    buf_temp_techPro.gds-code = buf_goods.gds-code
                    buf_temp_techPro.gds-name = buf_goods.gds-name
                  .
                    /* 07/IX-2018 - не используется. Возвращает предустановленное значение no
                  run get-goods-envd in this-procedure (
                    input p-obj-type
                    , input p-obj-code
                    , input buf_goods.gds-code
                    , output buf_temp_techPro.envd
                    ). */
                    buf_temp_techPro.envd = no .
                  for each buf_doc-pl no-lock
                     where buf_doc-pl.gds-code = buf_goods.gds-code 
                       and buf_doc-pl.obj-code = p-obj-code
                       and buf_doc-pl.obj-type = p-obj-type
                       and buf_doc-pl.out-code = buf_trn-doc.doc-code:
                        
                    assign
                      buf_temp_techPro.pl-code       = buf_doc-pl.pl-code
                      buf_temp_techPro.qnty          = buf_doc-pl.fact-qnty
                      buf_temp_techPro.cli-qnty      = buf_doc-pl.cli-fact-qnty
                      buf_temp_techPro.state-density = buf_doc-pl.cli-fact-qnty / buf_doc-pl.fact-qnty 
                    .
                  end.
                end.
              end.
              assign
                buf_temp_techPro.fact-qnty = buf_temp_techPro.fact-qnty + buf_doc-line.fact-qnty
              .
              for each buf_bar-code no-lock
                 where buf_bar-code.gds-code = buf_goods.gds-code :
                for each buf_chk-doc where buf_chk-doc.chk-type = integer({&rcpt-tech-refuell}) 
                     and buf_chk-doc.out-code = buf_trn-doc.out-code:
                            
                  find first buf_chk-gds no-lock where buf_chk-gds.b-code = buf_bar-code.b-code
                        and  buf_chk-gds.doc-code = buf_chk-doc.doc-code no-error .
                              
                  if AVAILABLE buf_chk-gds then 
                  do:
                    find first buf_temp_chk-doc where buf_temp_chk-doc.b-code = buf_chk-gds.b-code and
                              buf_temp_chk-doc.doc-code = buf_chk-gds.doc-code and
                              buf_temp_chk-doc.chk-type = integer({&rcpt-tech-refuell})  no-error.

                    if not AVAILABLE buf_temp_chk-doc then
                    do:

                      create buf_temp_chk-doc .
                      ASSIGN
                        buf_temp_chk-doc.doc-code      = buf_chk-gds.doc-code
                        buf_temp_chk-doc.gds-code      = buf_goods.gds-code
                        buf_temp_chk-doc.b-code        = buf_chk-gds.b-code
                        buf_temp_chk-doc.chk-date      = buf_chk-doc.chk-date
                        buf_temp_chk-doc.qnty          = buf_chk-gds.doc-qnty
                        buf_temp_chk-doc.nozzle-code   = buf_chk-gds.nozzle-code
                        buf_temp_chk-doc.pump          = buf_chk-gds.pump
                        buf_temp_chk-doc.state-density = buf_chk-gds.density
                        buf_temp_chk-doc.pay-desk      = buf_chk-doc.pay-desk
                        buf_temp_chk-doc.pl-code       = integer(buf_chk-gds.loc1)
                        buf_temp_chk-doc.chk-type      = integer({&rcpt-tech-refuell})
                        buf_temp_chk-doc.cashier       = buf_chk-doc.cashier
                        buf_temp_chk-doc.chk-num       = buf_chk-doc.chk-num
                        buf_temp_chk-doc.chk-time      = buf_chk-doc.chk-time 
                      .
                    end.
                  end.                            
                end.                          
              end.         

            end.        /* for each buf_doc-line */
          end.
        end.        /* for each buf_trn-doc */
      end.        /* if v-shftrep2 = "yes":U */
    end.        /* for each buf_clients */

    for each buf_temp_techPro
    :
      if buf_temp_techPro.fact-qnty <> 0
      then do:
        run wp-xmltagopen( input 2, input "techPro", input "" ).
        run wp-xmltagput( input 3, "objType"    , input string( p-obj-type                   ), input 0 ).
        run wp-xmltagput( input 3, "objCode"    , input string( p-obj-code                   ), input 0 ).
        run wp-xmltagput( input 3, "shiftDate"  , input string( p-shift-date, "99.99.9999"   ), input 0 ).
        run wp-xmltagput( input 3, "shiftNum"   , input string( p-shift-num                  ), input 0 ).
        run wp-xmltagput( input 3, "tprArtic"   , input string( buf_temp_techPro.artic       ), input 0 ).
        run wp-xmltagput( input 3, "tprProdType", input string( buf_temp_techPro.prod-type   ), input 0 ).
        run wp-xmltagput( input 3, "tprProdCode", input string( buf_temp_techPro.prod-code   ), input 0 ).
        run wp-xmltagput( input 3, "tprGdsCode" , input string( buf_temp_techPro.gds-code    ), input 0 ).
        run wp-xmltagput( input 3, "tprGdsName" , input string( buf_temp_techPro.gds-name    ), input 0 ).
        run wp-xmltagput( input 3, "tprGdsENVD" , input string( buf_temp_techPro.envd        ), input 3 ).
        run wp-xmltagput( input 3, "tprFactQnty", input string( buf_temp_techPro.fact-qnty   ), input 0 ).
        run wp-xmltagopen( input 3, input "tprProPL", input "" ).
        run wp-xmltagput( input 4, "tprProPLCode"  , input string( buf_temp_techPro.pl-code     ), input 0 ).
        run wp-xmltagput( input 4, "tprProQnty"    , input string( buf_temp_techPro.qnty        ), input 0 ).
        run wp-xmltagput( input 4, "tprProCliQnty" , input string( buf_temp_techPro.cli-qnty    ), input 0 ).
        run wp-xmltagput( input 4, "tprProDensity" , input string( buf_temp_techPro.state-density, ">>>>>>>>>9.99"), input 0 ).
        run wp-xmltagclose( input 3, input "tprProPL").

        for each buf_temp_chk-doc where buf_temp_chk-doc.gds-code = buf_temp_techPro.gds-code and buf_temp_chk-doc.chk-type = integer({&rcpt-tech-refuell}) :
          run wp-xmltagopen( input 3, input "techProChk", input "" ).
          run wp-xmltagput( input 4, "ChkDate"    , input string( buf_temp_chk-doc.chk-date   ), input 0 ).
          run wp-xmltagput( input 4, "ChkTime"    , input string( buf_temp_chk-doc.chk-time, "hh:mm:ss"   ), input 0 ).
          run wp-xmltagput( input 4, "ChkNum"     , input string( buf_temp_chk-doc.doc-code   ), input 0 ).
          run wp-xmltagput( input 4, "ChkNumDesk" , input string( buf_temp_chk-doc.pay-desk   ), input 0 ).
          run wp-xmltagput( input 4, "ChkQnty"    , input string( buf_temp_chk-doc.qnty       ), input 0 ).
          run wp-xmltagput( input 4, "ChkTRK"     , input string( buf_temp_chk-doc.pump       ), input 0 ).
          run wp-xmltagput( input 4, "ChkNozzle"  , input string( buf_temp_chk-doc.nozzle-code), input 0 ).
          run wp-xmltagput( input 4, "ChkPL"      , input string( buf_temp_chk-doc.pl-code    ), input 2 ).            
          run wp-xmltagclose( input 3, input "techProChk").
          
        end.
      end.            
      run wp-xmltagclose( input 2, input "techPro").
    end.


  end.

end procedure. /* export-techPro */

/*==========================================================================*/
procedure export-CorrChk :
  define input parameter p-obj-type   as character        no-undo.
  define input parameter p-obj-code   as integer          no-undo.
  define input parameter p-shift-date as date             no-undo.
  define input parameter p-shift-num  as integer          no-undo.

  define buffer buf_goods        for ub.goods.
  define buffer buf_chk-gds      for ub.chk-gds.
  define buffer buf_chk-pay      for ub.chk-pay.
  define buffer buf_chk-pay-attr for ub.chk-pay-attr.
  DEFINE buffer buf_chk-doc      for ub.chk-doc.
  define buffer buf_temp_chk-doc for temp_chk-doc.
  define buffer buf_temp_chk-gds for temp_chk-gds.
  define buffer buf_bar-code     for ub.bar-code.
  
  define variable v-RRN               as character no-undo.
  
  do
    for  buf_chk-gds
    , buf_chk-pay
    , buf_chk-doc
    on error undo, return error
    :
    empty temp-table buf_temp_chk-doc.
    empty temp-table buf_temp_chk-gds.
            
    for each buf_chk-doc where (buf_chk-doc.chk-type = integer({&expense-corr}) or buf_chk-doc.chk-type = integer({&income-corr}) )
      and buf_chk-doc.shift-date = p-shift-date and buf_chk-doc.shift-num = p-shift-num
      and buf_chk-doc.obj-code = p-obj-code and buf_chk-doc.obj-type = p-obj-type    :
      find first buf_temp_chk-doc where buf_temp_chk-doc.doc-code = buf_chk-doc.doc-code no-error.

      if not AVAILABLE buf_temp_chk-doc then
      do:
        create buf_temp_chk-doc .
        ASSIGN
          buf_temp_chk-doc.doc-code = buf_chk-doc.doc-code
          buf_temp_chk-doc.doc-num  = buf_chk-doc.doc-num
          buf_temp_chk-doc.doc-num2 = buf_chk-doc.doc-num2
          buf_temp_chk-doc.chk-date = buf_chk-doc.chk-date
          buf_temp_chk-doc.pay-desk = buf_chk-doc.pay-desk
          buf_temp_chk-doc.chk-type = buf_chk-doc.chk-type
          buf_temp_chk-doc.cashier  = buf_chk-doc.cashier
          buf_temp_chk-doc.chk-num  = buf_chk-doc.chk-num
          buf_temp_chk-doc.chk-time = buf_chk-doc.chk-time 
          buf_temp_chk-doc.netto    = buf_chk-doc.netto
        .
        if num-entries(buf_chk-doc.doc-num2, ":") = 2
        then do :
          if entry(1, buf_chk-doc.doc-num2, ":") = "0"
          then buf_temp_chk-doc.doc-num2 = "самостоятельно" .
          else
          if entry(1, buf_chk-doc.doc-num2, ":") = "1"
          then buf_temp_chk-doc.doc-num2 = "по предписанию" .
          else
          buf_temp_chk-doc.doc-num2 = "неизвестн." .
        end.
        else
        buf_temp_chk-doc.doc-num2 = "неизвестн." .
      end.
                                        
      for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code :
        find first buf_temp_chk-gds where buf_temp_chk-gds.doc-code = buf_chk-gds.doc-code and buf_temp_chk-gds.line-num = buf_chk-gds.line-num no-error . 
        if not AVAILABLE buf_temp_chk-gds then 
        do:
          create buf_temp_chk-gds .
          assign      
            buf_temp_chk-gds.doc-code    = buf_chk-gds.doc-code         
            buf_temp_chk-gds.b-code      = buf_chk-gds.b-code
            buf_temp_chk-gds.src-sum     = buf_chk-gds.src-sum
            buf_temp_chk-gds.OFDcode     = buf_chk-gds.depart-type
            buf_temp_chk-gds.OFDvalue    = buf_chk-gds.road-tax
            buf_temp_chk-gds.line-num    = buf_chk-gds.line-num
            . 
        end.
      end.   
    end.                       
    run wp-xmltagopen( input 2, input "CorrChk", input "" ).
        
    for each buf_temp_chk-doc where buf_temp_chk-doc.chk-type = integer({&income-corr}): 
      run wp-xmltagopen( input 3, input "Check", input "" ).
      run wp-xmltagput( input 4, "ChkTypeName", input string( "ПриходКорр" ), input 0 ).
      run wp-xmltagput( input 4, "ChkType"    , input string( {&income-corr}   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDate"    , input string( buf_temp_chk-doc.chk-date   ), input 0 ).
      run wp-xmltagput( input 4, "ChkTime"    , input string( buf_temp_chk-doc.chk-time, "hh:mm:ss"   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDocNum"  , input string( buf_temp_chk-doc.doc-code   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNum"     , input string( buf_temp_chk-doc.chk-num   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNumDesk" , input string( buf_temp_chk-doc.pay-desk   ), input 0 ).
      run wp-xmltagput( input 4, "ChkTotal"   , input string( buf_temp_chk-doc.netto   ), input 0 ).
      run wp-xmltagput( input 4, "Cashier"    , input string( buf_temp_chk-doc.cashier   ), input 0 ).
      run wp-xmltagput( input 4, "Reason"     , input string( buf_temp_chk-doc.doc-num   ), input 0 ).
      run wp-xmltagput( input 4, "CorrType"   , input string( buf_temp_chk-doc.doc-num2   ), input 0 ).
      for each buf_temp_chk-gds where buf_temp_chk-gds.doc-code = buf_temp_chk-doc.doc-code:
        run wp-xmltagopen( input 4, input "CheckLine", input "" ).
        run wp-xmltagput( input 5, "ChkTaxCode", input string( buf_temp_chk-gds.b-code ), input 0 ).
        run wp-xmltagput( input 5, "ChkSum"    , input string( buf_temp_chk-gds.src-sum ), input 0 ).
        run wp-xmltagput( input 5, "ChkCSTCode"  , input string( buf_temp_chk-gds.OFDcode ), input 0 ).
        run wp-xmltagput( input 5, "ChkCSTValue" , input string( buf_temp_chk-gds.OFDvalue ), input 0 ).
        run wp-xmltagclose( input 4, input "CheckLine").
      end .          
      for each buf_chk-pay no-lock where buf_chk-pay.doc-code = buf_temp_chk-doc.doc-code :
        run wp-xmltagopen( input 4, input "CheckPay", input "" ).
        run wp-xmltagput( input 5, "ChkPayCode", input string( buf_chk-pay.pay-code ), input 0 ).
        run wp-xmltagput( input 5, "ChkPaySum" , input string( buf_chk-pay.tot-sum ), input 0 ).
        v-RRN = '' .
        for first buf_chk-pay-attr no-lock
            where buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code 
            and buf_chk-pay-attr.attr-code = "CPDOC" 
            and buf_chk-pay-attr.line-num = buf_chk-pay.line-num  :
            v-RRN = buf_chk-pay-attr.attr-value .
        end.       
        if v-RRN = '' 
        then 
        do: 
            for first buf_chk-pay-attr no-lock
                where buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code 
                and buf_chk-pay-attr.attr-code = "RRN"
                and buf_chk-pay-attr.line-num = buf_chk-pay.line-num:
                v-RRN = buf_chk-pay-attr.attr-value .
            end.
        end.
        run wp-xmltagput( input 5, input "OperationCode", input v-RRN                              , input 0 ).
        run wp-xmltagclose( input 4, input "CheckPay").
      end . 
      run wp-xmltagclose( input 3, input "Check").
    end.
        
    for each buf_temp_chk-doc where buf_temp_chk-doc.chk-type = integer({&expense-corr}): 
      run wp-xmltagopen( input 3, input "Check", input "" ).
      run wp-xmltagput( input 4, "ChkTypeName", input string( "РасходКорр" ), input 0 ).
      run wp-xmltagput( input 4, "ChkType"    , input string( {&expense-corr}   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDate"    , input string( buf_temp_chk-doc.chk-date   ), input 0 ).
      run wp-xmltagput( input 4, "ChkTime"    , input string( buf_temp_chk-doc.chk-time, "hh:mm:ss"   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDocNum"  , input string( buf_temp_chk-doc.doc-code   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNum"     , input string( buf_temp_chk-doc.chk-num   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNumDesk" , input string( buf_temp_chk-doc.pay-desk   ), input 0 ).
      run wp-xmltagput( input 4, "ChkTotal"   , input string( buf_temp_chk-doc.netto   ), input 0 ).
      run wp-xmltagput( input 4, "Cashier"    , input string( buf_temp_chk-doc.cashier   ), input 0 ).
      run wp-xmltagput( input 4, "Reason"     , input string( buf_temp_chk-doc.doc-num   ), input 0 ).
      run wp-xmltagput( input 4, "CorrType"   , input string( buf_temp_chk-doc.doc-num2   ), input 0 ).
      for each buf_temp_chk-gds where buf_temp_chk-gds.doc-code = buf_temp_chk-doc.doc-code:
        run wp-xmltagopen( input 4, input "CheckLine", input "" ).
        run wp-xmltagput( input 5, "ChkTaxCode", input string( buf_temp_chk-gds.b-code ), input 0 ).
        run wp-xmltagput( input 5, "ChkSum"    , input string( buf_temp_chk-gds.src-sum), input 0 ).
        run wp-xmltagput( input 5, "ChkCSTCode"  , input string( buf_temp_chk-gds.OFDcode ), input 0 ).
        run wp-xmltagput( input 5, "ChkCSTValue" , input string( buf_temp_chk-gds.OFDvalue ), input 0 ).
        run wp-xmltagclose( input 4, input "CheckLine").
      end .      
      for each buf_chk-pay no-lock where buf_chk-pay.doc-code = buf_temp_chk-doc.doc-code :
        run wp-xmltagopen( input 4, input "CheckPay", input "" ).
        run wp-xmltagput( input 5, "ChkPayCode", input string( buf_chk-pay.pay-code ), input 0 ).
        run wp-xmltagput( input 5, "ChkPaySum" , input string( buf_chk-pay.tot-sum ), input 0 ).
        run wp-xmltagclose( input 4, input "CheckPay").
      end .       
      run wp-xmltagclose( input 3, input "Check").
    end.
	
	run wp-xmltagclose( input 2, input "CorrChk").

  end.
end procedure. /* export-CorrChk */

/*==========================================================================*/
procedure export-techChk :
  define input parameter p-obj-type   as character        no-undo.
  define input parameter p-obj-code   as integer          no-undo.
  define input parameter p-shift-date as date             no-undo.
  define input parameter p-shift-num  as integer          no-undo.

  define buffer buf_goods        for ub.goods.
  define buffer buf_chk-gds      for ub.chk-gds.
  DEFINE buffer buf_chk-doc      for ub.chk-doc.
  define buffer buf_temp_chk-doc for temp_chk-doc.
  define buffer buf_temp_chk-gds for temp_chk-gds.
  define buffer buf_bar-code     for ub.bar-code.
  do
    for buf_goods
    , buf_chk-gds
    , buf_bar-code
    , buf_chk-doc
    on error undo, return error
    :
    empty temp-table buf_temp_chk-doc.
    empty temp-table buf_temp_chk-gds.
          
    for each buf_chk-doc no-lock
       where buf_chk-doc.obj-type = p-obj-type 
         and buf_chk-doc.obj-code = p-obj-code
         and buf_chk-doc.shift-date = p-shift-date
         and buf_chk-doc.shift-num  = p-shift-num
         and (buf_chk-doc.chk-type = integer({&rcpt-trans-transfer})
           or buf_chk-doc.chk-type = integer({&rcpt-trans-cancell})
           or buf_chk-doc.chk-type = integer({&rcpt-unlock-trans})
           or buf_chk-doc.chk-type = integer({&rcpt-overflow})
             ) :
        find first buf_temp_chk-doc where buf_temp_chk-doc.doc-code = buf_chk-doc.doc-code no-error.

      if not AVAILABLE buf_temp_chk-doc then do:
        create buf_temp_chk-doc .
        ASSIGN
          buf_temp_chk-doc.doc-code = buf_chk-doc.doc-code
          buf_temp_chk-doc.doc-num2 = buf_chk-doc.doc-num2
          buf_temp_chk-doc.chk-date = buf_chk-doc.chk-date
          buf_temp_chk-doc.pay-desk = buf_chk-doc.pay-desk
          buf_temp_chk-doc.chk-type = buf_chk-doc.chk-type
          buf_temp_chk-doc.cashier  = buf_chk-doc.cashier
          buf_temp_chk-doc.chk-num  = buf_chk-doc.chk-num
          buf_temp_chk-doc.chk-time = buf_chk-doc.chk-time 
        .
      end.
                                  
      for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code :

        find first buf_bar-code where buf_bar-code.b-code = buf_chk-gds.b-code no-error .
        if AVAILABLE buf_bar-code then 
        do:
            find first buf_temp_chk-gds
                 where buf_temp_chk-gds.doc-code = buf_chk-gds.doc-code
                   and buf_temp_chk-gds.line-num = buf_chk-gds.line-num no-error . 
            if not AVAILABLE buf_temp_chk-gds then 
            do:
              create buf_temp_chk-gds .
              assign      
                buf_temp_chk-gds.doc-code    = buf_chk-gds.doc-code         
                buf_temp_chk-gds.gds-code    = buf_bar-code.gds-code
                buf_temp_chk-gds.b-code      = buf_chk-gds.b-code
                buf_temp_chk-gds.qnty        = buf_chk-gds.doc-qnty
                buf_temp_chk-gds.nozzle-code = buf_chk-gds.nozzle-code
                buf_temp_chk-gds.pump        = buf_chk-gds.pump
                buf_temp_chk-gds.line-num    = buf_chk-gds.line-num
              . 
              if buf_chk-doc.chk-type = integer({&rcpt-trans-cancell}) then 
              do:
                if buf_chk-gds.write-off-code = 0 then buf_temp_chk-gds.sbros-type = "не пролито".
                if buf_chk-gds.write-off-code = 1 then buf_temp_chk-gds.sbros-type = "пролито".
              end.     
            end.
        end.                        
      end.   
    end.                       
    run wp-xmltagopen( input 2, input "TechChk", input "" ).
    
    for each buf_temp_chk-doc where buf_temp_chk-doc.chk-type = integer({&rcpt-trans-transfer}): 
      run wp-xmltagopen( input 3, input "Check", input "" ).
      run wp-xmltagput( input 4, "ChkTypeName", input string( "ПеревТрнзкц" ), input 0 ).
      run wp-xmltagput( input 4, "ChkType"    , input string( {&rcpt-trans-transfer}   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDate"    , input string( buf_temp_chk-doc.chk-date   ), input 0 ).
      run wp-xmltagput( input 4, "ChkTime"    , input string( buf_temp_chk-doc.chk-time, "hh:mm:ss"   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDocNum"  , input string( buf_temp_chk-doc.doc-code   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNum"     , input string( buf_temp_chk-doc.chk-num   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNumDesk" , input string( buf_temp_chk-doc.pay-desk   ), input 0 ).
      run wp-xmltagput( input 4, "Cashier"    , input string( buf_temp_chk-doc.cashier   ), input 0 ).
      run wp-xmltagput( input 4, "Reference-num"    , input string( buf_temp_chk-doc.doc-num2   ), input 0 ).
      for each buf_temp_chk-gds where buf_temp_chk-gds.doc-code = buf_temp_chk-doc.doc-code:
        run wp-xmltagopen( input 4, input "CheckGds", input "" ).
        run wp-xmltagput( input 5, "ChkGds-code", input string( buf_temp_chk-gds.gds-code   ), input 0 ).
        run wp-xmltagput( input 5, "ChkQnty"    , input string( buf_temp_chk-gds.qnty,  "->>>>>>>>>9.99"       ), input 0 ).
        run wp-xmltagput( input 5, "ChkTRK"     , input string( buf_temp_chk-gds.pump       ), input 0 ).
        run wp-xmltagput( input 5, "ChkNozzle"  , input string( buf_temp_chk-gds.nozzle-code), input 0 ).
        run wp-xmltagput( input 5, "ChkPL"      , input string( buf_temp_chk-gds.pl-code    ), input 2 ).
        run wp-xmltagclose( input 4, input "CheckGds").
      end.            
      run wp-xmltagclose( input 3, input "Check").
    end.
    
    for each buf_temp_chk-doc where buf_temp_chk-doc.chk-type = integer({&rcpt-trans-cancell}): 
      run wp-xmltagopen( input 3, input "Check", input "" ).
      run wp-xmltagput( input 4, "ChkTypeName", input string( "СбросТрнзкц" ), input 0 ).
      run wp-xmltagput( input 4, "ChkType"    , input string( {&rcpt-trans-cancell}   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDate"    , input string( buf_temp_chk-doc.chk-date   ), input 0 ).
      run wp-xmltagput( input 4, "ChkTime"    , input string( buf_temp_chk-doc.chk-time, "hh:mm:ss"   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDocNum"  , input string( buf_temp_chk-doc.doc-code   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNum"     , input string( buf_temp_chk-doc.chk-num   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNumDesk" , input string( buf_temp_chk-doc.pay-desk   ), input 0 ).
      run wp-xmltagput( input 4, "Cashier"    , input string( buf_temp_chk-doc.cashier   ), input 0 ).
      run wp-xmltagput( input 4, "Reference-num"    , input string( buf_temp_chk-doc.doc-num2   ), input 0 ).
      for each buf_temp_chk-gds where buf_temp_chk-gds.doc-code = buf_temp_chk-doc.doc-code:
        run wp-xmltagopen( input 4, input "CheckGds", input "" ).
        run wp-xmltagput( input 5, "ChkGds-code", input string( buf_temp_chk-gds.gds-code   ), input 0 ).
        run wp-xmltagput( input 5, "ChkReason"  , input string( buf_temp_chk-gds.sbros-type   ), input 0 ).
        run wp-xmltagput( input 5, "ChkQnty"    , input string( buf_temp_chk-gds.qnty,  "->>>>>>>>>9.99"       ), input 0 ).
        run wp-xmltagput( input 5, "ChkTRK"     , input string( buf_temp_chk-gds.pump       ), input 0 ).
        run wp-xmltagput( input 5, "ChkNozzle"  , input string( buf_temp_chk-gds.nozzle-code), input 0 ).
        run wp-xmltagput( input 5, "ChkPL"      , input string( buf_temp_chk-gds.pl-code    ), input 2 ).
        run wp-xmltagclose( input 4, input "CheckGds").
      end.            
      run wp-xmltagclose( input 3, input "Check").
    end.

    
    for each buf_temp_chk-doc where buf_temp_chk-doc.chk-type = integer({&rcpt-unlock-trans}): 
      run wp-xmltagopen( input 3, input "Check", input "" ).
      run wp-xmltagput( input 4, "ChkTypeName", input string( "РазблТрнзкц" ), input 0 ).
      run wp-xmltagput( input 4, "ChkType"    , input string( {&rcpt-unlock-trans}   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDate"    , input string( buf_temp_chk-doc.chk-date   ), input 0 ).
      run wp-xmltagput( input 4, "ChkTime"    , input string( buf_temp_chk-doc.chk-time, "hh:mm:ss"   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDocNum"  , input string( buf_temp_chk-doc.doc-code   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNum"     , input string( buf_temp_chk-doc.chk-num   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNumDesk" , input string( buf_temp_chk-doc.pay-desk   ), input 0 ).
      run wp-xmltagput( input 4, "Cashier"    , input string( buf_temp_chk-doc.cashier   ), input 0 ).
      run wp-xmltagput( input 4, "Reference-num"    , input string( buf_temp_chk-doc.doc-num2   ), input 0 ).
      for each buf_temp_chk-gds where buf_temp_chk-gds.doc-code = buf_temp_chk-doc.doc-code:
        run wp-xmltagopen( input 4, input "CheckGds", input "" ).
        run wp-xmltagput( input 5, "ChkGds-code", input string( buf_temp_chk-gds.gds-code   ), input 0 ).
        run wp-xmltagput( input 5, "ChkQnty"    , input string( buf_temp_chk-gds.qnty,  "->>>>>>>>>9.99"       ), input 0 ).
        run wp-xmltagput( input 5, "ChkTRK"     , input string( buf_temp_chk-gds.pump       ), input 0 ).
        run wp-xmltagput( input 5, "ChkNozzle"  , input string( buf_temp_chk-gds.nozzle-code), input 0 ).
        run wp-xmltagput( input 5, "ChkPL"      , input string( buf_temp_chk-gds.pl-code    ), input 2 ).
        run wp-xmltagclose( input 4, input "CheckGds").
      end.            
      run wp-xmltagclose( input 3, input "Check").
    end.
    
    
    for each buf_temp_chk-doc where buf_temp_chk-doc.chk-type = integer({&rcpt-overflow}): 
      run wp-xmltagopen( input 3, input "Check", input "" ).
      run wp-xmltagput( input 4, "ChkTypeName", input string( "Перелив" ), input 0 ).
      run wp-xmltagput( input 4, "ChkType"    , input string( {&rcpt-overflow}   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDate"    , input string( buf_temp_chk-doc.chk-date   ), input 0 ).
      run wp-xmltagput( input 4, "ChkTime"    , input string( buf_temp_chk-doc.chk-time, "hh:mm:ss"   ), input 0 ).
      run wp-xmltagput( input 4, "ChkDocNum"  , input string( buf_temp_chk-doc.doc-code   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNum"     , input string( buf_temp_chk-doc.chk-num   ), input 0 ).
      run wp-xmltagput( input 4, "ChkNumDesk" , input string( buf_temp_chk-doc.pay-desk   ), input 0 ).
      run wp-xmltagput( input 4, "Cashier"    , input string( buf_temp_chk-doc.cashier   ), input 0 ).
      run wp-xmltagput( input 4, "Reference-num"    , input string( buf_temp_chk-doc.doc-num2   ), input 0 ).
      for each buf_temp_chk-gds where buf_temp_chk-gds.doc-code = buf_temp_chk-doc.doc-code:
        run wp-xmltagopen( input 4, input "CheckGds", input "" ).
        run wp-xmltagput( input 5, "ChkGds-code", input string( buf_temp_chk-gds.gds-code   ), input 0 ).
        run wp-xmltagput( input 5, "ChkQnty"    , input string( buf_temp_chk-gds.qnty,  "->>>>>>>>>9.99"       ), input 0 ).
        run wp-xmltagput( input 5, "ChkTRK"     , input string( buf_temp_chk-gds.pump       ), input 0 ).
        run wp-xmltagput( input 5, "ChkNozzle"  , input string( buf_temp_chk-gds.nozzle-code), input 0 ).
        run wp-xmltagput( input 5, "ChkPL"      , input string( buf_temp_chk-gds.pl-code    ), input 2 ).
        run wp-xmltagclose( input 4, input "CheckGds").
      end.            
      run wp-xmltagclose( input 3, input "Check").
    end.
    run wp-xmltagclose( input 2, input "TechChk").

  end.
end procedure. /* export-techChk */

/*==========================================================================*/
procedure export-stkShift :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-shift-date as date             no-undo.
define input parameter p-shift-num  as integer          no-undo.
define VARIABLE v-shift-date as date             no-undo.
define VARIABLE v-shift-num  as integer          no-undo.

define buffer end_shift-obj      for ub.shift-obj .
define buffer previous-shift-obj for ub.shift-obj.
define variable fo      as decimal no-undo init 0.
define variable prev-fo as decimal no-undo init 0.
define variable moving  as logical no-undo init yes.


  define buffer buf_rvs-doc              for ub.rvs-doc.
  define buffer buf_rvs-line             for ub.rvs-line.
  define buffer buf_rvs-line-pump        for ub.rvs-line-pump.
  define buffer buf_goods                for ub.goods.
  define buffer buf_temp_stkShiftEnd     for temp_stkShiftEnd.
  define buffer buf_temp_stkPlShiftEnd   for temp_stkPlShiftEnd.
  define buffer buf_temp_stkTRKShiftEnd  for temp_stkTRKShiftEnd.
  define buffer buf_temp_stkShiftOpen    for temp_stkShiftOpen.
  define buffer buf_temp_stkPlShiftOpen  for temp_stkPlShiftOpen.
  define buffer buf_temp_stkTRKShiftOpen for temp_stkTRKShiftOpen.
    
  find first end_shift-obj share-lock
       where end_shift-obj.obj-type   = p-obj-type
         and end_shift-obj.obj-code   = p-obj-code
         and end_shift-obj.shift-date = p-shift-date
         and end_shift-obj.shift-num  = p-shift-num
    no-error.
  if not available end_shift-obj then do:
    run wp-XMLWriteLog in this-procedure (
         input p-log-file-name
       , input 1
       , input substitute( "&1. Не найдена смена с порядковым номером &2 от &3 для объекта &4 &5. &6. &7. &8."
                               , vss-description
                               , p-shift-num
                               , p-shift-date
                               , p-obj-type
                               , p-obj-code
                               , return-value
                               , trim(error-status :get-message(1))
                               , trim(error-status :get-message(2))
                       )
    ).
  end.
  else do:
    assign
      fo = end_shift-obj.fact-order
    .
  end.
  find last previous-shift-obj share-lock
      where previous-shift-obj.obj-type = p-obj-type
        and previous-shift-obj.obj-code = p-obj-code
        and (( previous-shift-obj.shift-date = p-shift-date
           and previous-shift-obj.shift-num < p-shift-num
             )
         or previous-shift-obj.shift-date < p-shift-date
            )
    use-index pi no-error.
  if available previous-shift-obj then do:
    assign
      prev-fo = previous-shift-obj.fact-order
    .
  end.    
    
  do
    for buf_rvs-doc
    , buf_rvs-line
    , buf_goods
    , buf_temp_stkShiftEnd
    , buf_temp_stkPlShiftEnd
    , buf_temp_stkTRKShiftEnd
    on error undo, return error
    :
    empty temp-table buf_temp_stkShiftEnd.
    empty temp-table buf_temp_stkPlShiftEnd.
    empty temp-table buf_temp_stkTRKShiftEnd.

    if available previous-shift-obj then do:
      assign
        v-shift-date = previous-shift-obj.shift-date
        v-shift-num  = previous-shift-obj.shift-num
      .
    end.

    find first buf_rvs-doc no-lock
         where buf_rvs-doc.obj-type     = p-obj-type
           and buf_rvs-doc.obj-code     = p-obj-code
           and buf_rvs-doc.shift-date   = p-shift-date
           and buf_rvs-doc.shift-num    = p-shift-num
           and buf_rvs-doc.status_      = {&fact}
           and buf_rvs-doc.rvs-type     = {&rvs-shift}
    use-index shift
    no-error.
    if available buf_rvs-doc
    then do:
      for each buf_rvs-line no-lock
         where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
           and buf_rvs-line.obj-type = p-obj-type
           and buf_rvs-line.obj-code = p-obj-code
        on error undo, return error
        :
        find first buf_temp_stkShiftEnd
             where buf_temp_stkShiftEnd.gds-code = buf_rvs-line.gds-code
        no-error.
        if not available buf_temp_stkShiftEnd
        then do:
          create buf_temp_stkShiftEnd.
          assign
            buf_temp_stkShiftEnd.gds-code = buf_rvs-line.gds-code
          .
          find first buf_goods no-lock
               where buf_goods.gds-code = buf_rvs-line.gds-code
          no-error.
          if available buf_goods
          then do:
            assign
              buf_temp_stkShiftEnd.artic     = buf_goods.artic
              buf_temp_stkShiftEnd.prod-type = buf_goods.prod-type
              buf_temp_stkShiftEnd.prod-code = buf_goods.prod-code
              buf_temp_stkShiftEnd.gds-name  = buf_goods.gds-name
              buf_temp_stkShiftEnd.qnty      = 0.0
              buf_temp_stkShiftEnd.cli-qnty  = 0.0
            .
              /* 07/IX-2018 - не используется. Возвращает предустановленное значение no            
            run get-goods-envd in this-procedure (
                  input p-obj-type
                , input p-obj-code
                , input buf_goods.gds-code
                , output buf_temp_stkShiftEnd.envd
            ). */
              buf_temp_stkShiftEnd.envd = no .
          end.
        end.
        assign
          buf_temp_stkShiftEnd.qnty     = buf_temp_stkShiftEnd.qnty + buf_rvs-line.state-measure-qnty
          buf_temp_stkShiftEnd.cli-qnty = buf_temp_stkShiftEnd.cli-qnty + buf_rvs-line.state-measure-cli-qnty
        .
        find first buf_temp_stkPlShiftEnd
             where buf_temp_stkPlShiftEnd.gds-code = buf_rvs-line.gds-code
               and buf_temp_stkPlShiftEnd.pl-code = buf_rvs-line.pl-code
        no-error.
        if not available buf_temp_stkPlShiftEnd
        then do:
          create buf_temp_stkPlShiftEnd.
          assign
            buf_temp_stkPlShiftEnd.gds-code = buf_rvs-line.gds-code
            buf_temp_stkPlShiftEnd.pl-code  = buf_rvs-line.pl-code
          .
          find first buf_goods no-lock
               where buf_goods.gds-code = buf_rvs-line.gds-code
          no-error.
          if available buf_goods
          then do:
            assign
              buf_temp_stkPlShiftEnd.qnty            = buf_rvs-line.state-measure-qnty
              buf_temp_stkPlShiftEnd.cli-qnty        = buf_rvs-line.state-measure-cli-qnty
              buf_temp_stkPlShiftEnd.state-density   = buf_rvs-line.state-density
              buf_temp_stkPlShiftEnd.system-qnty     = buf_rvs-line.system-qnty
              buf_temp_stkPlShiftEnd.systen-cli-qnty = buf_rvs-line.system-cli-qnty
              buf_temp_stkPlShiftEnd.temperature     = buf_rvs-line.state-temperature
              buf_temp_stkPlShiftEnd.level-petrol    = buf_rvs-line.state-level-petrol
              buf_temp_stkPlShiftEnd.level-total     = buf_rvs-line.state-level-total
              buf_temp_stkPlShiftEnd.level-water     = buf_rvs-line.state-level-water
              buf_temp_stkPlShiftEnd.state-add-quantity        = buf_rvs-line.state-add-qnty
            .
          end. /*if available buf_goods*/
        end. /*if not available buf_temp_stkPlShiftEnd*/
      end.        /* for each buf_rvs-line */
      for each buf_rvs-line-pump no-lock where
            buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
        and buf_rvs-line-pump.obj-type = p-obj-type
        and buf_rvs-line-pump.obj-code = p-obj-code
        break
        by buf_rvs-line-pump.pump-code
        by buf_rvs-line-pump.nozzle-code
        on error undo, return error:
        if first-of(buf_rvs-line-pump.nozzle-code) then do:
          find first buf_temp_stkTrkShiftEnd where
                     buf_temp_stkTrkShiftEnd.pump-code = buf_rvs-line-pump.pump-code
            and buf_temp_stkTrkShiftEnd.nozzle-code = buf_rvs-line-pump.nozzle-code
            and buf_temp_stkTRKShiftEnd.pl-code = buf_rvs-line-pump.pl-code no-error.
          if not available buf_temp_stkTrkShiftEnd then do:
            create buf_temp_stkTrkShiftEnd.
            assign
              buf_temp_stkTRKShiftEnd.pl-code      = buf_rvs-line-pump.pl-code
              buf_temp_stkTrkShiftEnd.pump-code    = buf_rvs-line-pump.pump-code
              buf_temp_stkTrkShiftEnd.nozzle-code  = buf_rvs-line-pump.nozzle-code
              buf_temp_stkTrkShiftEnd.gds-code     = buf_rvs-line-pump.gds-code
              buf_temp_stkTrkShiftEnd.state-mh-cnt = buf_rvs-line-pump.state-mh-cnt
            .
          end.
        end. /*if first-of(buf_rvs-line-pump.nozzle-code) then do:*/
      end. /*        for each buf_rvs-line-pump no-lock where*/
    end. /*if available buf_rvs-doc*/

    find first buf_rvs-doc no-lock
         where buf_rvs-doc.obj-type     = p-obj-type
           and buf_rvs-doc.obj-code     = p-obj-code
           and buf_rvs-doc.shift-date   = v-shift-date
           and buf_rvs-doc.shift-num    = v-shift-num
           and buf_rvs-doc.status_      = {&fact}
           and buf_rvs-doc.rvs-type     = {&rvs-shift}
    use-index shift
    no-error.
    if available buf_rvs-doc
    then do:
      for each buf_rvs-line no-lock
         where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
           and buf_rvs-line.obj-type = p-obj-type
           and buf_rvs-line.obj-code = p-obj-code
        on error undo, return error
        :
        find first buf_temp_stkShiftOpen
             where buf_temp_stkShiftOpen.gds-code = buf_rvs-line.gds-code
        no-error.
        if not available buf_temp_stkShiftOpen
        then do:
          create buf_temp_stkShiftOpen.
          assign
            buf_temp_stkShiftOpen.gds-code = buf_rvs-line.gds-code
          .
          find first buf_goods no-lock
               where buf_goods.gds-code = buf_rvs-line.gds-code
          no-error.
          if available buf_goods
          then do:
            assign
              buf_temp_stkShiftOpen.artic     = buf_goods.artic
              buf_temp_stkShiftOpen.prod-type = buf_goods.prod-type
              buf_temp_stkShiftOpen.prod-code = buf_goods.prod-code
              buf_temp_stkShiftOpen.gds-name  = buf_goods.gds-name
              buf_temp_stkShiftOpen.qnty      = 0.0
              buf_temp_stkShiftOpen.cli-qnty  = 0.0
            .
              /* 07/IX-2018 - не используется. Возвращает предустановленное значение no
            run get-goods-envd in this-procedure (
                  input p-obj-type
                , input p-obj-code
                , input buf_goods.gds-code
                , output buf_temp_stkShiftOpen.envd
            ). */
              buf_temp_stkShiftOpen.envd = no .            
          end.
        end.
        assign
          buf_temp_stkShiftOpen.qnty     = buf_temp_stkShiftOpen.qnty + buf_rvs-line.state-measure-qnty
          buf_temp_stkShiftOpen.cli-qnty = buf_temp_stkShiftOpen.cli-qnty + buf_rvs-line.state-measure-cli-qnty
        .
        find first buf_temp_stkPlShiftOpen
             where buf_temp_stkPlShiftOpen.gds-code = buf_rvs-line.gds-code
               and buf_temp_stkPlShiftOpen.pl-code = buf_rvs-line.pl-code
        no-error.
        if not available buf_temp_stkPlShiftOpen
        then do:
          create buf_temp_stkPlShiftOpen.
          assign
            buf_temp_stkPlShiftOpen.gds-code = buf_rvs-line.gds-code
            buf_temp_stkPlShiftOpen.pl-code  = buf_rvs-line.pl-code
          .
          find first buf_goods no-lock
               where buf_goods.gds-code = buf_rvs-line.gds-code
          no-error.
          if available buf_goods
          then do:
            assign
              buf_temp_stkPlShiftOpen.qnty            = buf_rvs-line.state-measure-qnty
              buf_temp_stkPlShiftOpen.cli-qnty        = buf_rvs-line.state-measure-cli-qnty
              buf_temp_stkPlShiftOpen.state-density   = buf_rvs-line.state-density
              buf_temp_stkPlShiftOpen.system-qnty     = buf_rvs-line.system-qnty
              buf_temp_stkPlShiftOpen.systen-cli-qnty = buf_rvs-line.system-cli-qnty
              buf_temp_stkPlShiftOpen.temperature     = buf_rvs-line.state-temperature
              buf_temp_stkPlShiftOpen.level-petrol    = buf_rvs-line.state-level-petrol
              buf_temp_stkPlShiftOpen.level-total     = buf_rvs-line.state-level-total
              buf_temp_stkPlShiftOpen.level-water     = buf_rvs-line.state-level-water
              buf_temp_stkPlShiftOpen.state-add-quantity  = buf_rvs-line.state-add-qnty
            .
          end. /*if available buf_goods*/
        end. /*if not available buf_temp_stkPlShiftEnd*/
      end.        /* for each buf_rvs-line */
      for each buf_rvs-line-pump no-lock where
            buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
        and buf_rvs-line-pump.obj-type = p-obj-type
        and buf_rvs-line-pump.obj-code = p-obj-code
        break
        by buf_rvs-line-pump.pump-code
        by buf_rvs-line-pump.nozzle-code
        on error undo, return error:
        if first-of(buf_rvs-line-pump.nozzle-code) then do:
          find first buf_temp_stkTrkShiftOpen where
                     buf_temp_stkTrkShiftOpen.pump-code = buf_rvs-line-pump.pump-code
            and buf_temp_stkTrkShiftOpen.nozzle-code = buf_rvs-line-pump.nozzle-code
            and buf_temp_stkTRKShiftOpen.pl-code = buf_rvs-line-pump.pl-code no-error.
          if not available buf_temp_stkTrkShiftOpen then do:
            create buf_temp_stkTrkShiftOpen.
            assign
              buf_temp_stkTRKShiftOpen.pl-code      = buf_rvs-line-pump.pl-code
              buf_temp_stkTrkShiftOpen.pump-code    = buf_rvs-line-pump.pump-code
              buf_temp_stkTrkShiftOpen.nozzle-code  = buf_rvs-line-pump.nozzle-code
              buf_temp_stkTrkShiftOpen.gds-code     = buf_rvs-line-pump.gds-code
              buf_temp_stkTrkShiftOpen.state-mh-cnt = buf_rvs-line-pump.state-mh-cnt
            .
          end.
        end. /*if first-of(buf_rvs-line-pump.nozzle-code) then do:*/
      end. /*        for each buf_rvs-line-pump no-lock where*/
    end. /*if available buf_rvs-doc*/
    for each buf_temp_stkShiftEnd
    :
      run wp-xmltagopen( input 2, input "stkShiftEnd", input "" ).
      run wp-xmltagput( input 3, "objType"    , input string( p-obj-type                      ), input 0 ).
      run wp-xmltagput( input 3, "objCode"    , input string( p-obj-code                      ), input 0 ).
      run wp-xmltagput( input 3, "shiftDate"  , input string( p-shift-date, "99.99.9999"      ), input 0 ).
      run wp-xmltagput( input 3, "shiftNum"   , input string( p-shift-num                     ), input 0 ).
      run wp-xmltagput( input 3, "sseArtic"   , input string( buf_temp_stkShiftEnd.artic      ), input 0 ).
      run wp-xmltagput( input 3, "sseProdType", input string( buf_temp_stkShiftEnd.prod-type  ), input 0 ).
      run wp-xmltagput( input 3, "sseProdCode", input string( buf_temp_stkShiftEnd.prod-code  ), input 0 ).
      run wp-xmltagput( input 3, "sseGdsCode" , input string( buf_temp_stkShiftEnd.gds-code   ), input 0 ).
      run wp-xmltagput( input 3, "sseGdsName" , input string( buf_temp_stkShiftEnd.gds-name   ), input 0 ).
      run wp-xmltagput( input 3, "sseGdsENVD" , input string( buf_temp_stkShiftEnd.envd       ), input 3 ).
      run wp-xmltagput( input 3, "sseFactQnty", input string( buf_temp_stkShiftEnd.qnty       ), input 0 ).
      run wp-xmltagput( input 3, "sseCliFactQnty", input string( buf_temp_stkShiftEnd.cli-qnty       ), input 0 ).

      for each buf_temp_stkPlShiftEnd where buf_temp_stkPlShiftEnd.gds-code = buf_temp_stkShiftEnd.gds-code:
        for first buf_temp_stkPlShiftOpen where buf_temp_stkPlShiftOpen.gds-code = buf_temp_stkPlShiftEnd.gds-code 
          and buf_temp_stkPlShiftOpen.pl-code = buf_temp_stkPlShiftEnd.pl-code :
          run wp-xmltagopen( input 3, input "stkPlShiftOpen", input "" ).
          run wp-xmltagput( input 4, "ssePlCode", input string( buf_temp_stkPlShiftOpen.pl-code       ), input 0 ).
          run wp-xmltagput( input 4, "ssePlFactQnty", input string( buf_temp_stkPlShiftOpen.qnty       ), input 0 ).
          run wp-xmltagput( input 4, "ssePlCliFactQnty", input string( buf_temp_stkPlShiftOpen.cli-qnty       ), input 0 ).
          run wp-xmltagput( input 4, "ssePlDensity", input string( buf_temp_stkPlShiftOpen.state-density), input 0 ).
          run wp-xmltagput( input 4, "ssePlTemperature", input string( buf_temp_stkPlShiftOpen.temperature), input 0 ).
          run wp-xmltagput( input 4, "ssePlLevelPetrol", input string( buf_temp_stkPlShiftOpen.level-petrol), input 0 ).
          run wp-xmltagput( input 4, "ssePlLevelTotal", input string( buf_temp_stkPlShiftOpen.level-total), input 0 ).
          run wp-xmltagput( input 4, "ssePlLevelWater", input string( buf_temp_stkPlShiftOpen.level-water), input 0 ).
          
          run wp-xmltagput( input 4, "ssePlAddQuantity", input string( buf_temp_stkPlShiftOpen.state-add-quantity), input 0 ).
          run wp-xmltagput( input 4, "ssePlSysQnty", input string( buf_temp_stkPlShiftOpen.system-qnty), input 0 ).
          run wp-xmltagput( input 4, "ssePlSysWeight", input string( buf_temp_stkPlShiftOpen.systen-cli-qnty), input 0 ).
          run wp-xmltagclose( input 3, input "stkPlShiftOpen").
        end.
        run wp-xmltagopen( input 3, input "stkPlShiftEnd", input "" ).
        run wp-xmltagput( input 4, "ssePlCode", input string( buf_temp_stkPlShiftEnd.pl-code       ), input 0 ).
        run wp-xmltagput( input 4, "ssePlFactQnty", input string( buf_temp_stkPlShiftEnd.qnty       ), input 0 ).
        run wp-xmltagput( input 4, "ssePlCliFactQnty", input string( buf_temp_stkPlShiftEnd.cli-qnty       ), input 0 ).
        run wp-xmltagput( input 4, "ssePlDensity", input string( buf_temp_stkPlShiftEnd.state-density), input 0 ).
        run wp-xmltagput( input 4, "ssePlTemperature", input string(  buf_temp_stkPlShiftEnd.temperature), input 0 ).
        run wp-xmltagput( input 4, "ssePlLevelPetrol", input string(  buf_temp_stkPlShiftEnd.level-petrol), input 0 ).
        run wp-xmltagput( input 4, "ssePlLevelTotal", input string(  buf_temp_stkPlShiftEnd.level-total), input 0 ).
        run wp-xmltagput( input 4, "ssePlLevelWater", input string(  buf_temp_stkPlShiftEnd.level-water), input 0 ).          
        run wp-xmltagput( input 4, "ssePlAddQuantity", input string( buf_temp_stkPlShiftEnd.state-add-quantity), input 0 ).
        run wp-xmltagput( input 4, "ssePlSysQnty", input string( buf_temp_stkPlShiftEnd.system-qnty), input 0 ).
        run wp-xmltagput( input 4, "ssePlSysWeight", input string( buf_temp_stkPlShiftEnd.systen-cli-qnty), input 0 ).
        run wp-xmltagclose( input 3, input "stkPlShiftEnd").
      end.
      for each buf_temp_stkTrkShiftEnd where buf_temp_stkTrkShiftEnd.gds-code = buf_temp_stkShiftEnd.gds-code:
        for first  buf_temp_stkTrkShiftOpen where buf_temp_stkTrkShiftOpen.gds-code = buf_temp_stkShiftEnd.gds-code
          and buf_temp_stkTRKShiftOpen.gds-code = buf_temp_stkTRKShiftEnd.gds-code   
          and buf_temp_stkTRKShiftOpen.pl-code = buf_temp_stkTRKShiftEnd.pl-code
          and buf_temp_stkTRKShiftOpen.pump-code = buf_temp_stkTRKShiftEnd.pump-code
          and buf_temp_stkTRKShiftOpen.nozzle-code = buf_temp_stkTRKShiftEnd.nozzle-code :              
        
          run wp-xmltagopen( input 3, input "stkTRKShiftOpen", input "" ).
          run wp-xmltagput( input 4, "sseTRKPlCode", input string( buf_temp_stkTRKShiftOpen.pl-code   ), input 0 ).
          run wp-xmltagput( input 4, "sseTRKPump", input string( buf_temp_stkTRKShiftOpen.pump-code   ), input 0 ).
          run wp-xmltagput( input 4, "sseTRKNozzle", input string( buf_temp_stkTRKShiftOpen.nozzle-code   ), input 0 ).
          run wp-xmltagput( input 4, "sseTRKCnt", input string( buf_temp_stkTRKShiftOpen.state-mh-cnt   ), input 0 ).
          run wp-xmltagclose( input 3, input "stkTRKShiftOpen").
        end.
        run wp-xmltagopen( input 3, input "stkTRKShiftEnd", input "" ).
        run wp-xmltagput( input 4, "sseTRKPlCode", input string( buf_temp_stkTRKShiftEnd.pl-code   ), input 0 ).
        run wp-xmltagput( input 4, "sseTRKPump", input string( buf_temp_stkTRKShiftEnd.pump-code   ), input 0 ).
        run wp-xmltagput( input 4, "sseTRKNozzle", input string( buf_temp_stkTRKShiftEnd.nozzle-code   ), input 0 ).
        run wp-xmltagput( input 4, "sseTRKCnt", input string( buf_temp_stkTRKShiftEnd.state-mh-cnt   ), input 0 ).
        run wp-xmltagclose( input 3, input "stkTRKShiftEnd").
      end.
      run wp-xmltagclose( input 2, input "stkShiftEnd").
    end. /*for each buf_temp_stkShiftEnd*/

  end.
end procedure. /* export-stkShiftEnd */


/*==========================================================================*/
procedure export-stkTNP :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-shift-date as date             no-undo.
define input parameter p-shift-num  as integer          no-undo.


  define variable v-fact-order-from as decimal no-undo.
  define variable v-fact-order-to   as decimal no-undo.
  define variable v-docs-exists     as logical no-undo.
  define variable v-is-petrol       as logical no-undo.
  define variable v-is-pieces       as logical no-undo.

  define buffer buf_stk-line    for ub.stk-line.
  define buffer buf_ot-line     for ub.ot-line.
  define buffer buf_gds-obj     for ub.gds-obj.
  define buffer buf_goods       for ub.goods.
  define buffer buf_temp_stkTNP for temp_stkTNP.
  do
    for buf_stk-line
    , buf_ot-line
    , buf_gds-obj
    , buf_goods
    , buf_temp_stkTNP
    on error undo, return error
    :
    empty temp-table buf_temp_stkTNP.
    run rep/getfosht.p (
          input p-obj-type
        , input p-obj-code
        , input p-shift-date
        , input p-shift-num
        , output v-fact-order-from
        , output v-fact-order-to
        , output v-docs-exists
    ).
    goods-on-object:
    for each buf_gds-obj no-lock
       where buf_gds-obj.obj-type = p-obj-type
         and buf_gds-obj.obj-code = p-obj-code
      on error undo, return error
      :
      if buf_gds-obj.first-doc > p-shift-date
      then do:
        undo goods-on-object, next goods-on-object.
      end.
      { str/is-petrl.i
          buf_gds-obj.artic
          buf_gds-obj.prod-type
          buf_gds-obj.prod-code
          v-is-petrol
          v-is-pieces
      }
      if v-is-petrol  = yes
      and v-is-pieces = no
      then do:        /* Только ТНП, не топливо */
        undo goods-on-object, next goods-on-object.
      end.
      find last buf_stk-line no-lock
          where buf_stk-line.obj-type   = p-obj-type
            and buf_stk-line.obj-code   = p-obj-code
            and buf_stk-line.artic      = buf_gds-obj.artic
            and buf_stk-line.prod-type  = buf_gds-obj.prod-type
            and buf_stk-line.prod-code  = buf_gds-obj.prod-code
            and buf_stk-line.fact-order <= v-fact-order-to
            and buf_stk-line.sum-type   = {&arh-crsa}
      no-error.
      if available buf_stk-line
      then do:
        find first buf_temp_stkTNP
             where buf_temp_stkTNP.artic     = buf_gds-obj.artic
               and buf_temp_stkTNP.prod-type = buf_gds-obj.prod-type
               and buf_temp_stkTNP.prod-code = buf_gds-obj.prod-code
        no-error.
        if not available buf_temp_stkTNP
        then do:
          create buf_temp_stkTNP.
          assign
            buf_temp_stkTNP.artic     = buf_gds-obj.artic
            buf_temp_stkTNP.prod-type = buf_gds-obj.prod-type
            buf_temp_stkTNP.prod-code = buf_gds-obj.prod-code
          .
        end.
        find first buf_goods no-lock
             where buf_goods.artic     = buf_temp_stkTNP.artic
               and buf_goods.prod-type = buf_temp_stkTNP.prod-type
               and buf_goods.prod-code = buf_temp_stkTNP.prod-code
        no-error.
        if available buf_goods
        then do:
          assign
            buf_temp_stkTNP.gds-code = buf_goods.gds-code
            buf_temp_stkTNP.gds-name = buf_goods.gds-name
          .
            /* 07/IX-2018 - не используется. Возвращает предустановленное значение no
          run get-goods-envd in this-procedure (
                input p-obj-type
              , input p-obj-code
              , input buf_goods.gds-code
              , output buf_temp_stkTNP.envd
          ). */
            buf_temp_stkTNP.envd = no .          
        end.
        assign
          buf_temp_stkTNP.end-sumSale = buf_stk-line.sum-rubl
          buf_temp_stkTNP.end-sumVat  = buf_stk-line.VAT-rubl
          buf_temp_stkTNP.end-qnty    = buf_stk-line.fact-qnty
        .
      end.
    end.        /* for each buf_gds-obj */
    for each buf_temp_stkTNP
    :
      assign
        buf_temp_stkTNP.start-sumSale = buf_temp_stkTNP.end-sumSale
        buf_temp_stkTNP.start-sumVat  = buf_temp_stkTNP.end-sumVat
      .
      for each buf_ot-line no-lock
         where buf_ot-line.obj-type  = p-obj-type
           and buf_ot-line.obj-code  = p-obj-code
           and buf_ot-line.artic     = buf_temp_stkTNP.artic
           and buf_ot-line.prod-type = buf_temp_stkTNP.prod-type
           and buf_ot-line.prod-code = buf_temp_stkTNP.prod-code
           and buf_ot-line.fact-order >= v-fact-order-from
           and buf_ot-line.fact-order <= v-fact-order-to
        on error undo, return error
        :
        if buf_ot-line.sum-type  = {&arh-crsa}
        or buf_ot-line.sum-type  = {&arh-crsa-service}
        then do:
          assign
            buf_temp_stkTNP.start-sumSale = buf_temp_stkTNP.start-sumSale - buf_ot-line.sum-rubl
            buf_temp_stkTNP.start-sumVat  = buf_temp_stkTNP.start-sumVat  - buf_ot-line.VAT-rubl
          .
        end.
      end.        /* for each buf_ot-line */
    end.
    for each buf_temp_stkTNP
    :
      if buf_temp_stkTNP.start-sumSale    <> 0
      or buf_temp_stkTNP.start-sumVat     <> 0
      or buf_temp_stkTNP.end-sumSale      <> 0
      or buf_temp_stkTNP.end-sumVat       <> 0
      then do:
        run wp-xmltagopen( input 2, input "stkTNP", input "" ).
        run wp-xmltagput( input 3, "objType"        , input string( p-obj-type                      ), input 0 ).
        run wp-xmltagput( input 3, "objCode"        , input string( p-obj-code                      ), input 0 ).
        run wp-xmltagput( input 3, "shiftDate"      , input string( p-shift-date, "99.99.9999"      ), input 0 ).
        run wp-xmltagput( input 3, "shiftNum"       , input string( p-shift-num                     ), input 0 ).
        run wp-xmltagput( input 3, "stnArtic"       , input string( buf_temp_stkTNP.artic           ), input 0 ).
        run wp-xmltagput( input 3, "stnProdType"    , input string( buf_temp_stkTNP.prod-type       ), input 0 ).
        run wp-xmltagput( input 3, "stnProdCode"    , input string( buf_temp_stkTNP.prod-code       ), input 0 ).
        run wp-xmltagput( input 3, "stnGdsCode"     , input string( buf_temp_stkTNP.gds-code        ), input 0 ).
        run wp-xmltagput( input 3, "stnGdsName"     , input string( buf_temp_stkTNP.gds-name        ), input 0 ).
        run wp-xmltagput( input 3, "stnGdsENVD"     , input string( buf_temp_stkTNP.envd            ), input 3 ).
        run wp-xmltagput( input 3, "stnStartSumSale", input string( buf_temp_stkTNP.start-sumSale   ), input 0 ).
        run wp-xmltagput( input 3, "stnStartSumVat" , input string( buf_temp_stkTNP.start-sumVat    ), input 0 ).
        run wp-xmltagput( input 3, "stnEndSumSale"  , input string( buf_temp_stkTNP.end-sumSale     ), input 0 ).
        run wp-xmltagput( input 3, "stnEndSumVat"   , input string( buf_temp_stkTNP.end-sumVat      ), input 0 ).
        run wp-xmltagput( input 3, "stnEndQnty"     , input string( buf_temp_stkTNP.end-qnty        ), input 0 ).
        run wp-xmltagclose( input 3, input "stkTNP").
      end.
    end.
  end.
end procedure. /* export-stkTNP */


procedure export-invTRK :
  define input parameter p-obj-type   as character        no-undo.
  define input parameter p-obj-code   as integer          no-undo.
  define input parameter p-shift-date as date             no-undo.
  define input parameter p-shift-num  as integer          no-undo.

  define buffer buf_icnt-doc  for ub.icnt-doc .
  define buffer buf_icnt-line for ub.icnt-line .
  
  
  for each buf_icnt-doc no-lock where buf_icnt-doc.obj-type = p-obj-type
    and buf_icnt-doc.obj-code = p-obj-code
    and buf_icnt-doc.shift-date = p-shift-date
    and buf_icnt-doc.shift-num = p-shift-num
    :
        
    run wp-xmltagopen( input 2, input "invTRK", input "" ).
    run wp-xmltagput( input 3, "DocCode"        , input string( buf_icnt-doc.doc-code                      ), input 0 ).
    run wp-xmltagput( input 3, "DocDate"        , input string( buf_icnt-doc.doc-date                      ), input 0 ).
    run wp-xmltagput( input 3, "shiftDate"      , input string( p-shift-date, "99.99.9999"      ), input 0 ).
    run wp-xmltagput( input 3, "shiftNum"       , input string( p-shift-num                     ), input 0 ).
    for each buf_icnt-line no-lock where buf_icnt-line.doc-code = buf_icnt-doc.doc-code:
      run wp-xmltagopen( input 3, input "indTRK", input "" ).
      run wp-xmltagput( input 4, "GdsCode"      , input string( buf_icnt-line.gds-code           ), input 0 ).
      run wp-xmltagput( input 4, "TrkNum"       , input string( buf_icnt-line.pump-code          ), input 0 ).
      run wp-xmltagput( input 4, "TrkNozzle"    , input string( buf_icnt-line.nozzle-code        ), input 0 ).
      run wp-xmltagput( input 4, "IndEl"        , input string( buf_icnt-line.state-el-cnt       ), input 0 ).
      run wp-xmltagput( input 4, "IndMeh"       , input string( buf_icnt-line.state-mh-cnt       ), input 0 ).
      run wp-xmltagput( input 4, "DIF"          , input string( buf_icnt-line.state-el-cnt - buf_icnt-line.state-mh-cnt   ), input 0 ).
      run wp-xmltagput( input 4, "IndAuto"      , input string( buf_icnt-line.meas-el-cnt    ), input 0 ).
      run wp-xmltagclose( input 3, input "indTRK").
    end.
    run wp-xmltagclose( input 2, input "invTRK").
  end.

end procedure. /* export-invTRK */


/*==========================================================================*/
procedure export-price-sum :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-shift-date as date             no-undo.
define input parameter p-shift-num  as integer          no-undo.

  define variable v-fact-order-from as decimal no-undo.
  define variable v-fact-order-to   as decimal no-undo.
  define variable v-docs-exists     as logical no-undo.
  define variable v-is-petrol       as logical no-undo.
  define variable v-is-pieces       as logical no-undo.

  define buffer buf_ot-line           for ub.ot-line.
  define buffer buf_gds-obj           for ub.gds-obj.
  define buffer buf_goods             for ub.goods.
  define buffer buf_temp_sumPriceSale for temp_sumPriceSale.
  do
    for buf_ot-line
    , buf_gds-obj
    , buf_goods
    , buf_temp_sumPriceSale
    on error undo, return error
    :
    empty temp-table buf_temp_sumPriceSale.
    run rep/getfosht.p (
          input p-obj-type
        , input p-obj-code
        , input p-shift-date
        , input p-shift-num
        , output v-fact-order-from
        , output v-fact-order-to
        , output v-docs-exists
    ).
    goods-on-object:
    for each buf_gds-obj no-lock
       where buf_gds-obj.obj-type = p-obj-type
         and buf_gds-obj.obj-code = p-obj-code
    on error undo, return error
    :
        { str/is-petrl.i
            buf_gds-obj.artic
            buf_gds-obj.prod-type
            buf_gds-obj.prod-code
            v-is-petrol
            v-is-pieces
        }
      if v-is-petrol  = yes
      and v-is-pieces = no
      then do:        /* Только ТНП, не топливо */
        undo goods-on-object, next goods-on-object.
      end.
      if buf_gds-obj.first-doc > p-shift-date
      then do:
        undo goods-on-object, next goods-on-object.
      end.
      for each buf_ot-line no-lock
         where buf_ot-line.obj-type  = p-obj-type
           and buf_ot-line.obj-code  = p-obj-code
           and buf_ot-line.artic     = buf_gds-obj.artic
           and buf_ot-line.prod-type = buf_gds-obj.prod-type
           and buf_ot-line.prod-code = buf_gds-obj.prod-code
           and buf_ot-line.fact-order >= v-fact-order-from
           and buf_ot-line.fact-order <= v-fact-order-to
        on error undo, return error
        :
        if buf_ot-line.ext-doc-type  = {&TDEDT_Overturn}
        then do:
          find first buf_temp_sumPriceSale
               where buf_temp_sumPriceSale.artic     = buf_ot-line.artic
                 and buf_temp_sumPriceSale.prod-type = buf_ot-line.prod-type
                 and buf_temp_sumPriceSale.prod-code = buf_ot-line.prod-code
          no-error.
          if not available buf_temp_sumPriceSale
          then do:
            create buf_temp_sumPriceSale.
            assign
              buf_temp_sumPriceSale.artic     = buf_ot-line.artic
              buf_temp_sumPriceSale.prod-type = buf_ot-line.prod-type
              buf_temp_sumPriceSale.prod-code = buf_ot-line.prod-code
            .
            find first buf_goods no-lock
                 where buf_goods.artic     = buf_ot-line.artic
                   and buf_goods.prod-type = buf_ot-line.prod-type
                   and buf_goods.prod-code = buf_ot-line.prod-code
            no-error.
            if available buf_goods
            then do:
              assign
                buf_temp_sumPriceSale.gds-code = buf_goods.gds-code
                buf_temp_sumPriceSale.gds-name = buf_goods.gds-name
              .
                /* 07/IX-2018 - не используется. Возвращает предустановленное значение no
              run get-goods-envd in this-procedure (
                    input p-obj-type
                  , input p-obj-code
                  , input buf_goods.gds-code
                  , output buf_temp_sumPriceSale.envd
              ). */
                buf_temp_sumPriceSale.envd = no .              
            end.
          end.
          assign
            buf_temp_sumPriceSale.sumSale = buf_temp_sumPriceSale.sumSale + buf_ot-line.sum-rubl
            buf_temp_sumPriceSale.sumVat  = buf_temp_sumPriceSale.sumSale + buf_ot-line.VAT-rubl
          .
        end.
      end.        /* for each buf_ot-line */
    end.        /* for each buf_gds-obj no-lock */
    for each buf_temp_sumPriceSale
    :
      if buf_temp_sumPriceSale.sumSale    <> 0
      or buf_temp_sumPriceSale.sumVat     <> 0
      then do:
        run wp-xmltagopen( input 2, input "sumPriceSale", input "" ).
        run wp-xmltagput( input 3, "objType"        , input string( p-obj-type                      ), input 0 ).
        run wp-xmltagput( input 3, "objCode"        , input string( p-obj-code                      ), input 0 ).
        run wp-xmltagput( input 3, "shiftDate"      , input string( p-shift-date, "99.99.9999"      ), input 0 ).
        run wp-xmltagput( input 3, "shiftNum"       , input string( p-shift-num                     ), input 0 ).
        run wp-xmltagput( input 3, "spsArtic"       , input string( buf_temp_sumPriceSale.artic     ), input 0 ).
        run wp-xmltagput( input 3, "spsProdType"    , input string( buf_temp_sumPriceSale.prod-type ), input 0 ).
        run wp-xmltagput( input 3, "spsProdCode"    , input string( buf_temp_sumPriceSale.prod-code ), input 0 ).
        run wp-xmltagput( input 3, "spsGdsCode"     , input string( buf_temp_sumPriceSale.gds-code  ), input 0 ).
        run wp-xmltagput( input 3, "spsGdsName"     , input string( buf_temp_sumPriceSale.gds-name  ), input 0 ).
        run wp-xmltagput( input 3, "spsGdsENVD"     , input string( buf_temp_sumPriceSale.envd      ), input 3 ).
        run wp-xmltagput( input 3, "spsSumSale"     , input string( buf_temp_sumPriceSale.sumSale   ), input 0 ).
        run wp-xmltagput( input 3, "spsSumVat"      , input string( buf_temp_sumPriceSale.sumVat    ), input 0 ).
        run wp-xmltagclose( input 3, input "sumPriceSale").
      end.
    end.
  end.
end procedure. /* export-price-sum */


/*==========================================================================*/
/* остатки денежных средств */
procedure export-stk-den :
  define input parameter p-host-code  as character        no-undo .
  define input parameter p-obj-type   as character        no-undo .
  define input parameter p-obj-code   as integer          no-undo .
  define input parameter p-shift-date as date             no-undo .
  define input parameter p-shift-num  as integer          no-undo .
  define variable v-ost-begin  as decimal no-undo .
  define variable v-ost-end    as decimal no-undo .
  define variable Fact-order-1 like ub.stk-tot.Fact-order no-undo .
  define variable Fact-order-2 like ub.stk-tot.Fact-order no-undo .

  /* функция fostatok() перебирает все магазины, равные заданному, из таблицы obj-list */
  run create_obj-list in this-procedure (p-obj-type, p-obj-code).

  run fostatok in this-procedure (
    input   p-host-code
    ,input   p-obj-code
    ,input   p-obj-type
    
    /* раз отчёт по сменам - то смены точно включены */
    ,input   true /* x-tog-shift - shared-переменная, определена в r-page0.i */
    
    /* остаток на начало: x-date-end = '' */
    ,input   p-shift-date - 1 /* fostatok() ищет за x-date-start + 1 */
    ,input   date('')
    
    /* за одну смену x-shift-start = X-shift-end */
    ,input   p-shift-num
    ,input   p-shift-num

    ,input   yes /*xTog-obj*/
    ,input   0 /*p-curr-code*/
    ,input   0
    ,output  v-ost-begin
    ,output  Fact-order-1
    ) no-error .
  run fostatok in this-procedure (
    input   p-host-code
    ,input   p-obj-code
    ,input   p-obj-type
    
    ,input   true
    
    /* остаток на конец: в r-ddinam.p почему-то вызывается без (-1) */
    ,input   p-shift-date
    ,input   p-shift-date
    ,input   p-shift-num
    ,input   p-shift-num
    
    ,input   yes /*xTog-obj*/
    ,input   0 /*p-curr-code*/
    ,input   0
    ,output  v-ost-end
    ,output  Fact-order-2
    ) no-error .
    
  run wp-xmltagopen ( input 2, input "stkDen", input "" ).
  run wp-xmltagput( input 3, "objType"        , input string( p-obj-type                            ), input 0 ).
  run wp-xmltagput( input 3, "objCode"        , input string( p-obj-code                            ), input 0 ).
  run wp-xmltagput( input 3, "shiftDate"      , input string( p-shift-date, "99.99.9999"            ), input 0 ).
  run wp-xmltagput( input 3, "shiftNum"       , input string( p-shift-num                           ), input 0 ).
  run wp-xmltagput( input 3, "ostBegin"       , input string( v-ost-begin                           ), input 0 ).
  run wp-xmltagput( input 3, "ostEnd"         , input string( v-ost-end                             ), input 0 ).
  run wp-xmltagclose( input 2, input "stkDen").

end procedure.  /* export-stk-den */
/*==========================================================================*/
/* procedure get-goods-envd : 07/IX-2018 - не используется. Возвращает предустановленное значение no
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-gds-code   as integer          no-undo.
define output parameter p-is-envd   as logical          no-undo.

  define variable v-host-code as integer no-undo.

  define buffer buf_clients-attr  for ub.clients-attr.
  define buffer buf_gds-host-attr for ub.gds-host-attr.
  do
    for buf_clients-attr
    , buf_gds-host-attr
    on error undo, return error
    :
    assign
      p-is-envd = no
    .
/***
    find first buf_clients-attr no-lock
         where buf_clients-attr.obj-type  = p-obj-type
           and buf_clients-attr.obj-code  = p-obj-code
           and buf_clients-attr.attr-code = {&attr-taxation}
    no-error.
    if available buf_clients-attr
    then do:
        { gbl/hostcode.i
            p-obj-type
            p-obj-code
            v-host-code
        }
        if caps( buf_clients-attr.attr-value ) = "ЕНВД":U
        then do:
            find first buf_gds-host-attr no-lock
                 where buf_gds-host-attr.host-code = v-host-code
                   and buf_gds-host-attr.gds-code  = p-gds-code
                   and buf_gds-host-attr.attr-code = "no-envd":U
            no-error.
            if not available buf_gds-host-attr
            then do:
                assign
                    p-is-envd = yes
                .
            end.
            else do:
                assign
                    p-is-envd = ( buf_gds-host-attr.attr-value = "no":U )
                .
            end.
        end.
    end.       ***/
  end.
end procedure. /* get-goods-envd */ */