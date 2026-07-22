define input parameter ParParentProc as widget-handle no-undo .
define input parameter t-action      as character no-undo .
define input parameter g#type        as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма ввода заказа" .
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
define variable curclivalue     as character initial ? no-undo.
define variable multdtypvalue   as character initial ? no-undo.
define variable v-dayship       as integer   no-undo .
define variable is-edoc-nn      as logical   no-undo .
define variable par-is-edoc-nn  as character no-undo .
define variable is-edi          as logical   no-undo .
define variable par-is-edi      as character no-undo .
define variable is-edoc-nn-doc  as logical   no-undo .
define variable is-edi-doc      as logical   no-undo .
define variable v-err           as logical   no-undo .
define variable head-col        as character no-undo .
define variable v-order-column  as character no-undo .
define variable v-spis-size     as character no-undo .
define variable v-spis-vis      as character no-undo .
define variable hcolumn         as handle extent 100  no-undo.
define variable curclitype   as character no-undo .
define variable multdtyptype as character no-undo .
define variable loc-sum-rcv  as decimal   no-undo .
define variable var-f-prt         as logical   no-undo .
define variable v-i-doc           as character no-undo .
define variable is-error          as logical   no-undo .
define variable is-em             as character no-undo .
define variable t5                as decimal   no-undo .
define variable v-ok              as logical   no-undo .
define variable varcontract       as character no-undo .
define variable v-mastc           as logical   no-undo .
define variable varcontract-type  as character no-undo .
define variable v-dm-edi    as integer   no-undo .
define temp-table tt-date no-undo
field exch-date as date
index pi is unique primary   exch-date
.
define temp-table tt-gds-list no-undo like ub.goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable gdsgrp_recids      as character no-undo.
define new shared variable fin-schet-recid    as character no-undo.
define new shared variable v-d-report-handle  as handle    no-undo .
define new shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table tmp#grp no-undo
    field node-code like ub.gds-grp.node-code
    field grp-name like ub.gds-grp.node-name
    field lvl-num  like ub.gds-grp.lvl-num
    field is-term  like ub.gds-grp.is-term
    index pi is unique primary grp-name node-code
    index i-node-code    node-code
    index level-num   lvl-num  grp-name
    index is-term is-term  grp-name
    .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
new shared
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
define new shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.
define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable var-report-r-b as character no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table tmp#zakaz1 no-undo like ub.ord-line field sum       as decimal   field all-day   as integer   field qnty-sale as decimal   field negative-rest as logical    field gds-name  as character field unit-base as character field unit-type as character field unit-cli-type as character field min-order     as decimal   field service-order as decimal field local-mark    as character field max-stock     as decimal   field season-coef   as decimal   field min-stock-old as decimal   field gds-way       as decimal   index pi is unique primary artic prod-type prod-code  ascending index idx-ln line-num.
define new shared temp-table tmp#zakaz-prn1 no-undo field artic         like ub.goods.artic      field prod-type     like ub.goods.prod-type  field prod-code     like ub.goods.prod-code  field obj-type      like ub.clients.obj-type field obj-code      like ub.clients.obj-code field prt-code      as   integer    field qnty-sale     as   decimal    field qnty-ord      as   decimal    index pi is unique primary artic prod-type prod-code obj-type obj-code prt-code  ascending.
define new shared temp-table tmp#zakaz-dtl1 no-undo like ub.ord-dtl field prt-name as character index bi is unique primary artic prod-type prod-code node-code  ascending.
define new shared buffer clients-doc for ub.clients   .
define  buffer clients-doc1 for ub.clients   .
define  buffer clients-doc2 for ub.clients   .
define new shared buffer buf-goods   for ub.goods     .
define new shared buffer sb-cli-gds  for ub.cli-gds   .
define new shared buffer sb-gds-obj  for ub.gds-obj   .
define new shared buffer tmp#zakaz     for tmp#zakaz1.
define new shared buffer tmp#zakaz-prn     for tmp#zakaz-prn1.
define new shared buffer tmp#zakaz-dtl for tmp#zakaz-dtl1.
define buffer buf_contract for ub.contract .
define new shared  buffer shar_ord-doc  for ub.ord-doc .
define new shared  buffer shar_ord-line for ub.ord-line.
define new shared  buffer shar_ord-dtl  for ub.ord-dtl .
define new shared variable chexcelapplication      as com-handle no-undo .
define new shared variable chworkbook              as com-handle no-undo .
define new shared variable chworksheet             as com-handle no-undo .
define new shared variable chrange                 as com-handle no-undo .
define new shared variable chworksheet2            as com-handle no-undo .
define new shared variable chworksheet3            as com-handle no-undo .
define new shared variable accum-zakaz             as decimal no-undo .
define new shared variable accum-sum-zakaz         as decimal no-undo .
define new shared variable accum-count             as integer no-undo .
define new shared buffer buf-cli for ub.clients.
define new shared variable loc-obj-name as character format "x(256)":u
     view-as text
     size 39.25 by 1 tooltip "Поставщик"
     fgcolor 4  no-undo.
define new shared variable agnt as integer format ">>>>>>>>>" initial ?
     label "И&сп"
     view-as fill-in tooltip "Код исполнителя"
     size 9.75 by 1 no-undo.
define new shared  variable boss as integer format ">>>>>>>>>" initial ?
     label "&М-р"
     view-as fill-in    tooltip "Код менеджера"
     size 9.75 by 1 no-undo.
define  new  shared  variable date-1 as date format "99/99/9999":u
     label "Период с"
     view-as fill-in   tooltip "Период, для которого рассчитан темп продаж"
     size 11 by 1 fgcolor 1 no-undo.
define  new  shared  variable date-2 as date format "99/99/9999":u
     label "по"
     view-as fill-in  tooltip "Период, для которого рассчитан темп продаж"
     size 11 by 1 fgcolor 1 no-undo.
define  new  shared  variable date-sale-1 as date format "99/99/9999":u
     label "Для продажи с"
     view-as fill-in   tooltip "Период продаж товара"
     size 11 by 1  no-undo.
define  new  shared  variable date-sale-2 as date format "99/99/9999":u
     label "по"
     view-as fill-in  tooltip "Период продаж товара"
     size 11 by 1  no-undo.
define  new  shared  variable loc-cli-code as integer format ">>>>>>>>>" initial ?
     view-as fill-in
     size 9.75 by 1 tooltip "Код Поставщика" no-undo.
define  new  shared  variable loc-cli-type as character format "x(3)":u initial "орг"
     label "Код"
     view-as fill-in
     size 5.13 by 1 tooltip "Тип Поставщика" no-undo.
define  new  shared  variable loc-date-ship as date format "99/99/9999":u
     label "&Заказ на"
     view-as fill-in
     size 11 by 1 tooltip "Дата, на которую формируется заказ"
     fgcolor 4
     no-undo.
define  new  shared  variable loc-ord-num as character format "x(256)":u
     label "№"
     view-as text
     size 14 by 1
     fgcolor 4
     no-undo.
define  new  shared  variable wrkr as integer format ">>>>>>>>>" initial ?
     label "К&л-к"
     view-as fill-in
     size 9.75 by 1 tooltip "Код кладовщика"
     no-undo.
define  new  shared  variable loc-service as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Ст-ть обслу&живания"
     view-as fill-in
     size 14 by 1 tooltip "Стоимость обслуживания" no-undo.
define  new  shared  variable paytype as integer format "99999" initial ?
     label "Опл"
     view-as fill-in
     size 7.75 by 1 tooltip "Код типа оплаты"
     no-undo.
define new  shared  variable loc-time-ship as character
      view-as fill-in
      size 7 by 1 tooltip "Время доставки" no-undo.
define new  shared  variable loc-hour as integer format "99":u initial 0
     view-as fill-in
     size 3.5 by 1 no-undo.
define new  shared  variable loc-min as integer format "99":u initial 0
     view-as fill-in
     size 3.5 by 1 no-undo.
define new  shared  variable cycle-day as integer format ">>>":u initial 0
     label "через"
     view-as fill-in
     size 4.75 by 1
     fgcolor 4
     no-undo.
define new shared  variable pay-day as integer format ">>9":u initial 1
     label "На дней продаж"
     view-as fill-in
     size 7.13 by 1
     fgcolor 4
     no-undo.
define  new  shared  variable tog-type as int initial 0
     label "цкл"
     view-as radio-set horizontal radio-buttons
     "П",0,
     "Ц",1,
     "О",4
     size 11 by 1 tooltip "Тип заказа : простой,цикличный,объединенный цикличный" no-undo.
define new shared variable loc-status  as character  no-undo.
define new shared variable loc-base-rate as decimal format "->,>>>,>>>,>>>,>>9.9999":u initial 0
     label "Кур&с б.в."
     view-as fill-in
     size 9.4 by 1 no-undo.
define new shared variable loc-base-scale as integer format ">,>>>,>>9":u initial 0
     label "М&-б"
     view-as fill-in
     size 3.5 by 1 no-undo.
define new shared variable loc-cli-qnty as decimal format "->,>>>,>>>,>>>,>>9.999":u initial 0
     label "Кол.п-ка"
     view-as text
     size 14 by 0.67
     tooltip "Количество в ед.из. поставщика"
     fgcolor 4
     no-undo.
define new shared variable loc-exch-code as integer format "->,>>>,>>9":u initial 0
     label "Вал&."
     view-as fill-in
     size 7 by 1
     no-undo.
define new shared variable loc-exch-rate as decimal format "->,>>>,>>>,>>>,>>9.9999":u initial 0
     label "Курс п&-ка"
     view-as fill-in
     size 9.4 by 1
     no-undo.
define new shared variable loc-exch-scale as integer format ">,>>>,>>9":u initial 0
     label "М&-б"
     view-as fill-in
     size 3.5 by 1
     no-undo.
define new shared variable loc-out-code as character format "x(256)":u
     label "№ Поставки"
     view-as fill-in
     size 9.38 by 1 tooltip "Номер документа поставки по данному заказу"
     no-undo.
define new shared variable loc-cli-out-doc  as character format "x(256)":u
     label "№ Заказа по пост"
     view-as fill-in
     size 14 by 1 tooltip "Номер заказа в системе учета поставщика"
     no-undo.
define new shared variable loc-qnty as decimal format "->,>>>,>>>,>>>,>>9.999":u initial 0
     label "Кол-во"
     view-as text
     size 14 by 0.67 tooltip "Количество по заказу в баз.ед."
     fgcolor 4
     no-undo.
define new shared variable loc-sum-base as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(б.в.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа(б.в.)"
     fgcolor 4
     no-undo.
define new shared variable loc-sum-cli as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(в.п.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа в вал. поставщика"
     fgcolor 4
     no-undo.
define new shared variable loc-sum-rubl as decimal format "->,>>>,>>>,>>>,>>9.99":u initial 0
     label "Сумма заказа(руб.)"
     view-as text
     size 14 by 0.67 tooltip "Сумма заказа(руб)"
     fgcolor 4
     no-undo.
define new shared variable loc-tot-lines as integer format "->,>>>,>>9":u initial 0
     label "Строк"
     view-as text
     size 7.38 by .67 tooltip "Контрольное количество строк в заказе"
     fgcolor 4
     no-undo.
define new shared variable doc-date as date format "99/99/99":u
     label "&Дата"
     view-as text
     size 9 by .67 tooltip "Дата документа"
     no-undo.
define new shared variable fact-date as date format "99/99/99":u
     label "&Факт"
     view-as text
     size 9 by .67 tooltip "Дата документа фактическая"
     fgcolor 4
     no-undo.
define new shared var loc-print-rubl as logical no-undo .
define new shared variable slt_type as character format "x(256)":u
     label "НсП"
     view-as combo-box inner-lines 3
     list-items
        'без':U,
        'нет':U,
        'в т. ч.':U
     size 9.75 by 1
     no-undo.
define new shared  variable vat_type as character format "x(256)":u
     label "НДС"
     view-as combo-box inner-lines 3
     list-items
        'без':U,
        'нет':U,
        'в т. ч.':U
     size 9.75 by 1
     no-undo.
define new shared  variable e-method as character
     view-as editor scrollbar-vertical
     size 30 by 3.42 tooltip "Метод расчета темпа продаж и количества заказа/заявки"
     bgcolor 8
     no-undo.
define  new  shared  variable loc-contract as integer
     label "Вн.№ дог-ра"
     view-as fill-in
     size 10 by 1 tooltip "Номер договора"
     format ">>>>>>>>>"
     fgcolor 1
     no-undo.
define new shared  variable loc-store-code like ub.ord-doc.obj-code no-undo .
define new shared  variable loc-store-type like ub.ord-doc.obj-type no-undo .
define new shared  variable loc-doc-type   like ub.ord-doc.doc-type no-undo .
define new shared  variable temp-e-method  as character no-undo .
define new shared  variable x-tog-artic as logical   no-undo .
define new shared  variable x-tog-grp    as logical   no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define new global shared variable g#libbcrcn as handle no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxp-doc-prt         like ub.store.doc-prt         no-undo.
  define variable v-cntxp-price-calc      like ub.store.price-calc      no-undo.
  define variable v-cntxp-inout-price     like ub.store.inout-price     no-undo.
  define variable v-cntxp-unit-cli-perm   like ub.store.unit-cli-perm   no-undo.
  define variable v-cntxp-out-rate        like ub.store.out-rate        no-undo.
  define variable v-cntxp-out-line-discnt like ub.store.out-line-discnt no-undo.
  define variable v-cntxp-in-ov           like ub.store.in-ov           no-undo.
  define variable v-cntxp-in-perm         like ub.store.in-perm         no-undo.
  define variable v-cntxp-no-eq           like ub.store.no-eq           no-undo.
  define variable v-cntxp-rsrv-time       like ub.store.rsrv-time       no-undo.
  define variable v-cntxp-load-time       like ub.store.load-time       no-undo.
  define variable v-cntxp-holidays        like ub.store.holidays        no-undo.
  define variable v-cntxp-in-pay          like ub.store.in-pay          no-undo.
  define variable v-cntxp-out-pay         like ub.store.out-pay         no-undo.
  define variable v-cntxp-ret-pay         like ub.store.ret-pay         no-undo.
  define variable v-cntxp-ret-sup-pay     like ub.store.ret-sup-pay     no-undo.
  define variable v-cntxp-down-pay        like ub.store.down-pay        no-undo.
  define variable v-cntxp-inv-pay         like ub.store.inv-pay         no-undo.
  define variable v-cntxp-chk-pay         like ub.store.chk-pay         no-undo.
  define variable v-cntxp-retail          like ub.sysconf.ord-prt       no-undo.
  define variable v-cntxp-osn-base        like ub.sysconf.osn-base      no-undo.
  define variable v-cntxp-conf-par        as   character                no-undo.
  define variable v-cntxp-par-type        as   character                no-undo.
  define variable v-cntxp-curr-host-code  like ub.store.host-code       no-undo.
  define variable v-cntxp-obj-type        like ub.clients.obj-type      no-undo.
  define variable v-cntxp-obj-code        like ub.clients.obj-code      no-undo.
  define variable v-cntxp-db-num          as integer   no-undo .
  define variable v-cntxp-userid          as character no-undo .
  define variable v-cntxp-level           as character no-undo .
  define variable v-cntxp-db-num-obj      as integer   no-undo .
  define variable v-cntxp-is-admin        as logical   no-undo .
  define buffer bf-cntxp_store for ub.store.
  define buffer bf-cntxp_shop  for ub.shop.
  define buffer bf-cntxp_sysconf for ub.sysconf.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-uf-List_        like ubflt.usr-flt.List_        no-undo .
define variable v-uf-Naim         like ubflt.usr-flt.Naim         no-undo .
define variable v-uf-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
define variable v-uf-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
define variable v-uf-type-price   like ubflt.usr-flt.type-price   no-undo .
define variable v-uf-type-val     like ubflt.usr-flt.type-val     no-undo .
define temp-table usr-flt_custom-labels no-undo like ub.custom-labels.
procedure uf-name :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define output parameter p-use-List_     as logical   no-undo .
  define output parameter p-type-List_     as character no-undo .
  define output parameter p-format-List_   as character no-undo .
  define output parameter p-use-Naim      as logical   no-undo .
  define output parameter p-type-Naim      as character no-undo .
  define output parameter p-format-Naim    as character no-undo .
  define output parameter p-use-print-graft as logical   no-undo .
  define output parameter p-use-sort-gr   as logical   no-undo .
  define output parameter p-use-type-price as logical   no-undo .
  define output parameter p-use-type-val  as logical   no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-tooltip        as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
    case p-code :
            when 'cli-all-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'oldscode':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника неиспользуемых весовых кодов"     p-tooltip = "Настройки справочника неиспользуемых весовых кодов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-ref-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(8)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = yes      p-label = "Параметры вызова справочника товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fbr-gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп блюд"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп блюд"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findoci-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findocs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника платежей"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-obi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'seqeallo':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Порядок колонок в АВТО-ЗАКАЗЕ"     p-tooltip = "Порядок колонок в РАСЧЕТЕ потребности заказа и его импорте"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'skm-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова выгрузки файла данных по продажам по СКМ"     p-tooltip = "Параметры по умолчанию, используемые для вызова выгрузки файла данных по продажам по СКМ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'imp-goods':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Импорт в карточке товара"     p-tooltip = "Заполнение по умолчанию параметров импорта товаров из карточки товара"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'discards-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник ДК"     p-tooltip = "Справочник дисконтных карт"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'finsttms-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника банковских выписок"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника банковских выписок"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список фин.обязательств"     p-tooltip = "Список фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'mpl-gds-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список цен по товару"     p-tooltip = "Список цен по товару"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'tpl-mode-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список мод"     p-tooltip = "Список мод"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-sost-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Состояние заказа"     p-tooltip = "Просмотр несоответствий поставок и накладных по заказам ОП ФП и ПО"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'planplat-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Планирование платежей"     p-tooltip = "Планирование платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа"     p-tooltip = "Форма ввода заказа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОП"     p-tooltip = "Форма ввода заказа ОП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pФП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ФП"     p-tooltip = "Форма ввода заказа ФП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОФ':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОФ"     p-tooltip = "Форма ввода заказа ОФ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'list-abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список заголовков ABC-анализа"     p-tooltip = "Список заголовков ABC-анализа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "ABC-анализ"     p-tooltip = "ABC-анализ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-rc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Заказ О-РЦ"     p-tooltip = "Заказ О-РЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cfin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список удаленных фин.обязательств"     p-tooltip = "Список удаленных фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'color-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = yes      p-use-type-price = no      p-use-type-val = no      p-label = "Раскрасить экран"     p-tooltip = "Изменение цветовой палитры брауза"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bon1-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-tooltip = "Параметры вызова отчета НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-shift':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Сменный отчет"     p-tooltip = "Сменный отчет"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsreffi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник товаров - доп поля"     p-tooltip = "Справочник товаров - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsfrmfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Карточка товара - доп поля"     p-tooltip = "Карточка товара - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-g':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrst':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = YES      p-use-type-val =       p-label = "Остатки МЦ"     p-tooltip = "Остатки МЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthcom':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = no      p-use-type-val =       p-label = "Сводный отчет о реализованных талонах"     p-tooltip = "Сводный отчет о реализованных талонах"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'bge-active-vbrr':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper-new':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов(расширенный)"     p-tooltip = "Параметры для выгрузки документов(расширенный)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/i-egais.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Интерфейс импорта классификатора ЕГАИС"     p-tooltip = "Интерфейс импорта классификатора ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'alc-rees':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр документов ЕГАИС"     p-tooltip = "Реестр документов ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-optprc.w':U then do:     assign     p-use-List_ = no      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оптовый прайс-лист"     p-tooltip = "Оптовый прайс-лист"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/iecliart.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Процедуры импорта экспорта артикулов поставщиков"     p-tooltip = "Процедуры импорта экспорта артикулов поставщиков"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthps-zone':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthparts-obj':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '&bef-wthsref-stts}':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrd':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthob':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-type':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-stts':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = yes      p-use-type-price = yes      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-sup':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-wth':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-ptlbal':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ctrasm':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Контроль ассортиментной матрицы"     p-tooltip = "Контроль ассортиментной матрицы"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-eslg-e':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'prphoto':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(2256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(2256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Прайс-лист с фото товаров"     p-tooltip = "Прайс-лист с фото товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkgdsfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Товарная строка чека - доп поля"     p-tooltip = "Товарная строка чека - доп поля "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkdocfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Чек - доп поля"     p-tooltip = "Чек - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'barcodfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Бар-код - доп поля"     p-tooltip = "Бар-код - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'UPD':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника Электронного документоборота"     p-tooltip = "Настройки справочника Электронного документоборота"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'LK_RECEIPT':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-tooltip = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
      otherwise do:
        undo, return error "неизвестная настройка пользователя usr-flt" + " " + p-code .
      end.
    end CASE.
  end.
end procedure.
procedure uf-get :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define output parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define output parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define output parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define output parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define output parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define output parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr     as logical   no-undo .
    define variable v-use-type-price  as logical   no-undo .
    define variable v-use-type-val    as logical   no-undo .
    define variable v-label          as character no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
       (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt no-lock where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if avail buf_usr-flt then do:
      assign
      p-List_        = (if v-use-List_       then buf_usr-flt.List_       else ?)
      p-Naim         = (if v-use-Naim        then buf_usr-flt.Naim        else ?)
      p-print-graft  = (if v-use-print-graft then buf_usr-flt.print-graft else ?)
      p-sort-gr      = (if v-use-sort-gr     then buf_usr-flt.sort-gr     else ?)
      p-type-price   = (if v-use-type-price  then buf_usr-flt.type-price  else ?)
      p-type-val     = (if v-use-List_       then buf_usr-flt.type-val    else ?)
      .
    end.
    else do:
      assign
      p-List_        = (if v-use-List_       then "":U                    else ?)
      p-Naim         = (if v-use-Naim        then "":U                    else ?)
      p-print-graft  = (if v-use-print-graft then no                      else ?)
      p-sort-gr      = (if v-use-sort-gr     then no                      else ?)
      p-type-price   = (if v-use-type-price  then no                      else ?)
      p-type-val     = (if v-use-List_       then no                      else ?)
      .
    end.
  end.
end procedure.
procedure uf-set :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define input  parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define input  parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define input  parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define input  parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define input  parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define input  parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr   as logical   no-undo .
    define variable v-use-type-price as logical   no-undo .
    define variable v-use-type-val  as logical   no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
      (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if not avail buf_usr-flt then do:
        create buf_usr-flt .
        assign
        buf_usr-flt.call-point = p-code
        buf_usr-flt.user-name  = p-user-name
        .
    end.
    if avail buf_usr-flt then do:
     assign
     buf_usr-flt.List_       =  (if v-use-List_       then  p-List_        else ?)
     buf_usr-flt.Naim        =  (if v-use-Naim        then  p-Naim         else ?)
     buf_usr-flt.print-graft =  (if v-use-print-graft then  p-print-graft  else ?)
     buf_usr-flt.sort-gr     =  (if v-use-sort-gr     then  p-sort-gr      else ?)
     buf_usr-flt.type-price  =  (if v-use-type-price  then  p-type-price   else ?)
     buf_usr-flt.type-val    =  (if v-use-List_       then  p-type-val     else ?)
    .
    release buf_usr-flt.
    end.
    else undo, return error ("Ошибка при записи usr-flt" + substitute(" call-point=&1, user-name=&2", p-code, p-user-name)).
  end.
end procedure.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info21 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info21, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info21, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info21, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info21, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info21 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info21, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info21 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info21, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info21, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info21, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info21, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info21, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info21, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info21 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info21 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info21, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info21, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info21, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info21 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info21 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info21, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info21, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
def var vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ggoattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-value :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-value in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-write :
  define input parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define input parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-write in g#attr-lib
      (input p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-exist :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-exist in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-delete :
  define input  parameter p-node-code   like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code     like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-delete in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure grp-obj-notcorr-value :
do
on error undo, return error
:
define input parameter p-node-code             as integer      no-undo.
define input parameter p-obj-type              as character    no-undo.
define input parameter p-obj-code              as integer      no-undo.
define output parameter p-notcorr              as character    no-undo init ?.
define output parameter p-range-notcorr     as integer      no-undo.
define output parameter p-exists-notcorr    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-notcorr-found as logical no-undo .
DEFINE VARIABLE v-notcorr-value as char      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    find first buf_gds-grp-obj-attr no-lock
      where buf_gds-grp-obj-attr.node-code   = p-node-code
        and buf_gds-grp-obj-attr.host-code   = buf_gds-grp-obj.host-code
        and buf_gds-grp-obj-attr.obj-type    = buf_gds-grp-obj.obj-type
        and buf_gds-grp-obj-attr.obj-code    = buf_gds-grp-obj.obj-code
        and buf_gds-grp-obj-attr.attr-code   = 'NotCorrOP':U
      no-error .
    if available buf_gds-grp-obj-attr then do:
      assign
        v-notcorr-value = (if buf_gds-grp-obj-attr.attr-value = '' then ? else buf_gds-grp-obj-attr.attr-value)
      .
    end.
    else do:
      assign
        v-notcorr-value = ?
      .
    end.
    assign
    p-exists-notcorr = (if v-notcorr-value <> ? and p-notcorr = ?
                        then yes
                        else p-exists-notcorr)
    p-range-notcorr = if p-exists-notcorr and p-notcorr = ?
                      then v-range
                      else p-range-notcorr
    p-notcorr   =  if p-exists-notcorr and  p-notcorr = ?
                      then v-notcorr-value
                      else p-notcorr
    v-found =  (p-exists-notcorr ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-notcorr  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ver-clients :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-error as logical   no-undo .
define variable v-veto-man-doc as character no-undo .
define variable v-type        as character no-undo .
  do
  on error undo, return error return-value
  :
  p-error = false .
run clntattr-value in this-procedure (
 input p-obj-type ,
 input p-obj-code ,
 input 'veto-man-doc':U     ,
 output v-veto-man-doc ,
 output v-type        ) no-error .
 if error-status :error then message
   error-status :get-message(1) skip
   return-value skip
   "Ошибка clntattr-veto-man-doc"
   view-as alert-box error
 .
  if v-veto-man-doc = 'ALL' then do:
      message "Запрещено создание документа на этого контрагента оператору вручную." view-as alert-box error  .
      p-error = true .
  end.
 end.
end procedure.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gdsoattr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ver-clients-calc :
define input  parameter p-cli-type as character no-undo .
define input  parameter p-cli-code as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-method   as character no-undo .
define output parameter p-error    as logical   no-undo .
define variable v-not-corr-op as character no-undo .
define variable v-type as character no-undo .
  do
  on error undo, return error return-value
  :
 p-error = false .
 v-not-corr-op  = 'no' .
 run clntattr-value (
    input   p-obj-type
  , input   p-obj-code
  , input   'not-corr-op':U
  , output  v-not-corr-op
  , output  v-type
  ) no-error .
  if error-status :error then v-not-corr-op  = 'no' .
  if v-not-corr-op = 'yes' and  p-method = ""  then do:
    assign v-not-corr-op = 'no' .
    run clntattr-value (
    input   p-cli-type
  , input   p-cli-code
  , input   'not-corr-op':U
  , output  v-not-corr-op
  , output  v-type
  ) no-error .
  if error-status :error then v-not-corr-op  = 'no' .
  if v-not-corr-op = 'yes'  and  p-method = ""  then p-error = true .
  end.
  end.
end procedure.
procedure ver-ord-line :
define input parameter  p-doc-code like ub.ord-doc.doc-code no-undo .
define output parameter p-error    as logical               no-undo .
define variable v-longchar          as longchar  no-undo .
define variable v-err-ext           as logical   no-undo .
define variable var-ok-assort-pol   as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define variable v-event-code        as character no-undo .
define variable v-ok                as logical   no-undo .
define variable v-nabor             as logical   no-undo .
define buffer buf_ord-line for ub.ord-line.
define buffer buf_ord-doc  for ub.ord-doc.
v-err-ext  = false .
find first buf_ord-doc no-lock
  where buf_ord-doc.doc-code = p-doc-code no-error.
  if not available buf_ord-doc then do:
  end.
  else do:
for each buf_ord-line of buf_ord-doc
  break by buf_ord-line.cli-art :
    if buf_ord-doc.doc-type <> 'ПО':U  and
       buf_ord-doc.doc-type <> 'ФП':U  then do:
       var-ok-assort-pol = true .
       v-event-code = buf_ord-doc.doc-type + "-" .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  v-event-code
  ,input  buf_ord-line.gds-code
  ,input  buf_ord-doc.obj-type
  ,input  buf_ord-doc.obj-code
  ,input  false
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  ) .
           if var-ok-assort-pol = false then do:
              v-err-ext  = true  .
              v-longchar = v-longchar + var-mess-assort-pol + chr(10) .
           end.
    end.
    if  buf_ord-doc.cli-type = 'маг':U or
           buf_ord-doc.cli-type = 'скл':U then do:
            var-ok-assort-pol = true .
            v-event-code = "cli_" + buf_ord-doc.doc-type + "-" .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  v-event-code
  ,input  buf_ord-line.gds-code
  ,input  buf_ord-doc.cli-type
  ,input  buf_ord-doc.cli-code
  ,input  false
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  ) .
           if var-ok-assort-pol = false then do:
              v-err-ext  = true  .
              v-longchar = v-longchar + var-mess-assort-pol  + chr(10) .
           end.
       end.
    if buf_ord-doc.doc-type = 'ПО':U  then do:
        var-ok-assort-pol = true .
        v-event-code = buf_ord-doc.doc-type + "-" .
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassmat in g#library2
  (input  buf_ord-line.gds-code
  ,input  buf_ord-doc.obj-type
  ,input  buf_ord-doc.obj-code
  ,input  false
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  )  .
        if var-ok-assort-pol = false then do:
          v-err-ext  = true  .
          v-longchar = v-longchar + var-mess-assort-pol  + chr(10) .
        end.
    end.
  end.
  if v-err-ext = true  then do:
      run gbl/d-longchar.w (
              ?,
              'Editor_row=2\':u
            + 'title=Проверка строк заказа\':u
            + 'Editor_col=1\':u
            + 'Editor_width=96\':u
            + 'Editor_height=21\':u
            + 'readonly=yes\':u
          ,input-output v-longchar
          ,output v-ok ) no-error .
          if error-status :error then message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "4"
            view-as alert-box error
          .
          assign
          v-longchar = '':U.
      define variable vq as logical   no-undo init true .
      return error .
    end.
  end.
end procedure.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION status-edoc-nn RETURN CHAR (buffer loc-o-doc for ub.ord-doc
                                   , input is-edoc-nn as logical
                                   , input is-edi as logical
                                   , output p-color as integer ).
define variable v-obj-db-num as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-obj-uniq-key-rec as character no-undo .
define buffer buf_clients for ub.clients  .
define buffer obj_clients for ub.clients  .
define buffer buf_ext-classif for ub.ext-classif  .
define buffer buf2_ext-classif for ub.ext-classif  .
define buffer buf_ext-system  for ub.ext-system  .
p-color = ?.
if not available loc-o-doc then do:
  return ''.
end.
if not ( is-edoc-nn or is-edi)
or loc-o-doc.doc-type <> 'ОП':U  then do:
  p-color = ?.
  return ''.
end.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  loc-o-doc.obj-type
  ,input  loc-o-doc.obj-code
  ,output v-obj-db-num
  )  .
find first  buf_clients no-lock where
            buf_clients.obj-type = loc-o-doc.cli-type and
            buf_clients.obj-code = loc-o-doc.cli-code
              no-error .
if not available buf_clients then do:
  p-color = ?.
  return "" .
end.
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer buf_clients:handle)
                                  , output v-uniq-key-rec).
find first buf_ext-classif no-lock
      where buf_ext-classif.uniq-key-rec = v-uniq-key-rec
        and buf_ext-classif.classif-subject = 'clients':U
        and buf_ext-classif.classif-name    = 'clients-edoc-nn':U no-error.
if available buf_ext-classif then do :
  assign
  p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , '14,12,?,10,10,?,?,?,?,?,4'))
  no-error .
  return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , ',отправлен,принят,подтвержден,подтвержденOk,согласованный ушел,принят согласованный,поставка пришла,поставка принята,ПН отправлена,Отказ') .
end.
else do :
  find first obj_clients no-lock where
            obj_clients.obj-type = loc-o-doc.obj-type
        and obj_clients.obj-code = loc-o-doc.obj-code no-error.
  if not available obj_clients then do:
    return ''.
  end.
  run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                    , input (buffer obj_clients:handle)
                                    , output v-obj-uniq-key-rec).
  for each buf_ext-classif no-lock
        where buf_ext-classif.uniq-key-rec = v-uniq-key-rec
          and buf_ext-classif.classif-subject = 'clients':U
          and buf_ext-classif.classif-name    = 'exite-edi':U,
     first buf_ext-system no-lock
        where buf_ext-system.esys-id = buf_ext-classif.key#_one
          and buf_ext-system.db-num  = 0
          and buf_ext-system.esys-have-export = yes
          and buf_ext-system.esys-db-num-exp = v-obj-db-num,
     first buf2_ext-classif no-lock
              where buf2_ext-classif.uniq-key-rec = v-obj-uniq-key-rec
                and buf2_ext-classif.classif-subject = 'clients':U
                and buf2_ext-classif.classif-name    = 'exite-edi':U
                and buf2_ext-classif.key#_one  = buf_ext-classif.key#_one:
    assign
    p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , '14,12,?,14,?,?,10,?,?,?,?,4,10,4'))
    no-error .
    return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , ',отправлен,принят,подтвержден,подтвержден-,подтвержден+,подтвержденОк,поставка пришла,поставка принята,ПН отправлена,ПН получена,Отказ,Доставлен,Ошибка') .
  end.
  return ''.
end.
return ''.
END FUNCTION.
FUNCTION status-is-edoc-nn RETURN logical ( input p-is-edoc-nn   as logical
                                             , input p-cli-type     as character
                                             , input p-cli-code     as integer
                                             , input p-obj-type     as character
                                             , input p-obj-code     as integer
                                             ) .
define variable v-uniq-key-rec as character no-undo .
define buffer buf_clients     for ub.clients .
define buffer buf_ext-classif for ub.ext-classif .
define buffer buf_ext-system  for ub.ext-system  .
if not p-is-edoc-nn then do:
  return no.
end.
find first buf_clients no-lock
     where buf_clients.obj-type = p-cli-type
       and buf_clients.obj-code = p-cli-code
       no-error .
if not available buf_clients then do:
  return no .
end.
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer buf_clients:handle)
                                  , output v-uniq-key-rec).
find first buf_ext-classif no-lock
     where buf_ext-classif.uniq-key-rec    = v-uniq-key-rec
       and buf_ext-classif.classif-subject = 'clients':U
       and buf_ext-classif.classif-name    = 'clients-edoc-nn':U
       no-error.
if available buf_ext-classif then do :
  return yes .
end.
return no.
END FUNCTION.
FUNCTION status-is-edi RETURN logical ( input p-is-edi as logical
                                         , input p-cli-type as character
                                         , input p-cli-code as integer
                                         , input p-obj-type     as character
                                         , input p-obj-code     as integer
                                         , output p-dm-edi as integer
                                         ) .
define variable v-obj-db-num   as integer   no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-obj-uniq-key-rec as character no-undo .
define buffer buf_clients     for ub.clients .
define buffer obj_clients     for ub.clients .
define buffer buf_ext-classif for ub.ext-classif .
define buffer buf2_ext-classif for ub.ext-classif .
define buffer buf_ext-system  for ub.ext-system  .
if not p-is-edi then do:
  return no.
end.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-obj-db-num
  )  .
find first buf_clients no-lock
     where buf_clients.obj-type = p-cli-type
       and buf_clients.obj-code = p-cli-code
       no-error .
if not available buf_clients then do:
  return no .
end.
find first obj_clients no-lock where
          obj_clients.obj-type = p-obj-type
      and obj_clients.obj-code = p-obj-code no-error.
if not available buf_clients then do:
  return no .
end.
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer buf_clients:handle)
                                  , output v-uniq-key-rec).
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer obj_clients:handle)
                                  , output v-obj-uniq-key-rec).
for each buf_ext-classif no-lock
      where buf_ext-classif.uniq-key-rec = v-uniq-key-rec
        and buf_ext-classif.classif-subject = 'clients':U
        and buf_ext-classif.classif-name    = 'exite-edi':U,
    first buf_ext-system no-lock
      where buf_ext-system.esys-id = buf_ext-classif.key#_one
        and buf_ext-system.db-num  = 0
        and buf_ext-system.esys-have-export = yes
        and (buf_ext-system.esys-db-num-exp = v-obj-db-num
        or buf_ext-system.esys-db-num-exp = 0),
    first buf2_ext-classif no-lock
            where buf2_ext-classif.uniq-key-rec = v-obj-uniq-key-rec
              and buf2_ext-classif.classif-subject = 'clients':U
              and buf2_ext-classif.classif-name    = 'exite-edi':U
              and buf2_ext-classif.key#_one  = buf_ext-classif.key#_one:
  leave.
end.
if available buf_ext-classif then do :
  p-dm-edi = buf_ext-system.whole-send-news.
  return yes .
end.
return no .
END FUNCTION.
FUNCTION get-gln returns character ( input p-obj-type as character
                                    ,input p-obj-code as integer):
define variable v-uniq-key-rec as character no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_ext-classif for ub.ext-classif.
find first buf_clients no-lock where
          buf_clients.obj-type = p-obj-type
      and buf_clients.obj-code = p-obj-code no-error.
if not available buf_clients then do:
  return chr(63).
end.
run gen-key-rec  in this-procedure ( input 'clients':U
                                    ,input (buffer buf_clients:handle)
                                    ,output v-uniq-key-rec) no-error.
if error-status:error then do:
   return chr(63).
end.
find first buf_ext-classif no-lock where
          buf_ext-classif.classif-subject = 'clients':U
      and buf_ext-classif.classif-name = 'GLN':U
      and buf_ext-classif.uniq-key-rec = v-uniq-key-rec no-error .
if available buf_ext-classif then do:
  return buf_ext-classif.charkey_one.
end.
else do:
 return ''.
end.
END FUNCTION.
FUNCTION get-type-code-from-gln returns logical ( input  p-gln      as character
                                                    ,output p-obj-type as character
                                                    ,output p-obj-code as integer) :
define variable v-uniq-key-rec as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_ext-classif for ub.ext-classif.
find first buf_ext-classif no-lock where
          buf_ext-classif.classif-subject = 'clients':U
      and buf_ext-classif.classif-name = 'GLN':U
      and buf_ext-classif.charkey_one = p-gln no-error .
if available buf_ext-classif then do:
  assign v-uniq-key-rec = buf_ext-classif.uniq-key-rec.
end.
else do:
  assign
    p-obj-type = ''
    p-obj-code = 0
  .
  return no.
end.
if v-uniq-key-rec <> '' then do:
    run gen-key-fv in this-procedure ( input  v-uniq-key-rec
                                      ,output v-field-list
                                      ,output v-value-list).
end.
assign
  p-obj-type = entry(lookup("obj-type":U
                          , v-field-list
                          , chr(3))
                          , v-value-list, chr(3))
  p-obj-code = integer(entry(lookup("obj-code":U
                                  , v-field-list
                                  , chr(3))
                                  , v-value-list, chr(3)))
no-error .
if error-status:error then do:
  assign
    p-obj-type = ''
    p-obj-code = 0
  .
  return no.
end.
else do:
  return yes.
end.
END FUNCTION.
FUNCTION status-edoc-edi-light RETURN CHAR (buffer loc-o-doc for ub.ord-doc
                                   , input is-edoc-nn as logical
                                   , input is-edi as logical
                                   , output p-color as integer ).
p-color = ?.
if not available loc-o-doc then do:
  return ''.
end.
if not ( is-edoc-nn or is-edi)
or loc-o-doc.doc-type <> 'ОП':U  then do:
  p-color = ?.
  return ''.
end.
case loc-o-doc.whole-send-news:
  when integer('1':U) then do:
    assign
    p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , '14,12,?,10,10,?,?,?,?,?,4'))
    no-error .
    return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , ',отправлен,принят,подтвержден,подтвержденOk,согласованный ушел,принят согласованный,поставка пришла,поставка принята,ПН отправлена,Отказ') .
  end.
  when integer('2':U) then do:
    assign
    p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , '14,12,?,14,?,?,10,?,?,?,?,4,10,4'))
    no-error .
    return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , ',отправлен,принят,подтвержден,подтвержден-,подтвержден+,подтвержденОк,поставка пришла,поставка принята,ПН отправлена,ПН получена,Отказ,Доставлен,Ошибка') .
  end .
  otherwise do:
    p-color = ?.
    return ''.
  end.
end case.
end function.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-S_CONTRACT               AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-S_CODE_LAST_MASTER_NUM   AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-DELIM_CHR_3              AS CHARACTER NO-UNDO INITIAL "".
ASSIGN
   v-S_CONTRACT                = "Contract":U
   v-S_CODE_LAST_MASTER_NUM    = "LastMasterNum":U
   v-DELIM_CHR_3               = ","
   .
DEFINE VARIABLE i-gl-Host-Code      AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Contract-Code  AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Extent3        AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
FUNCTION Can-Find-Spec RETURN LOGICAL (
   INPUT iHost-Code    AS INTEGER,
   INPUT iContract-Num AS INTEGER,
   INPUT iGds-Code     AS INTEGER ):
   DEFINE BUFFER buf_Spec FOR ub.Contract-Specif.
   DEFINE VARIABLE iTmp-Host-Code     AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Contract-Num  AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Extent3       AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
   DEFINE VARIABLE lRet               AS LOGICAL NO-UNDO INITIAL FALSE.
   RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
       INPUT  iHost-Code,
       INPUT  iContract-Num,
       OUTPUT iTmp-Extent3
       ).
   IF iTmp-Extent3[1] = 2 THEN DO:
      ASSIGN
         iTmp-Host-Code      = iTmp-Extent3[2]
         iTmp-Contract-Num   = iTmp-Extent3[3]
         .
   END. ELSE DO:
      ASSIGN
         iTmp-Host-Code      = iHost-Code
         iTmp-Contract-Num   = iContract-Num
         .
   END.
   IF iGds-Code = ? THEN DO:
      ASSIGN
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                        ).
   END. ELSE DO:
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                           AND buf_Spec.Gds-Code      = iGds-Code
                         ).
   END.
   RETURN (lRet).
END FUNCTION.
PROCEDURE MS-Contract-EXTENT-3:
   DEFINE INPUT  PARAMETER i-Host-Code     AS INTEGER NO-UNDO.
   DEFINE INPUT  PARAMETER i-Contract-Code AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER i-Ret           AS INTEGER NO-UNDO EXTENT 3 INITIAL 0.
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   DEFINE BUFFER buf_Cont-2      FOR ub.Contract.
   FIND FIRST buf_Cont-2 WHERE
              buf_Cont-2.Host-Code      = i-Host-Code
          AND buf_Cont-2.Contract-Code  = i-Contract-Code
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_Cont-2 THEN DO:
      RETURN.
   END.
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                            STRING(i-Contract-code)
        AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       ASSIGN
          i-Ret[1] = 1
          i-Ret[2] = buf_Cont.Host-code
          i-Ret[3] = buf_Cont.Contract-code
          .
       LEAVE.
   END.
   IF i-Ret[1] <> 1 THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                               STRING(i-Contract-code)
           AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          ASSIGN
             i-Ret[1] = 2
             i-Ret[2] = buf_Cont.Host-code
             i-Ret[3] = buf_Cont.Contract-code
             .
          LEAVE.
      END.
   END.
   RETURN.
END PROCEDURE.
procedure check-contract-code :
define input  parameter parmode           as   character                     no-undo.
define input  parameter parhost-code      like ub.trn-doc.host-code          no-undo.
define input  parameter parcli-type       like ub.trn-doc.cli-type           no-undo.
define input  parameter parcli-code       like ub.trn-doc.cli-code           no-undo.
define input  parameter parframe-value    as   character                     no-undo.
define input  parameter parmenu-handle    as   handle                        no-undo.
define input  parameter parobj-date       as   date                          no-undo.
define input  parameter partype-contract  as   character                     no-undo .
define output parameter parcontract-code  like ub.contract.contract-code     no-undo.
define buffer bf_contract     for ub.contract.
define buffer bf-oth_contract for ub.contract.
define variable varrid-list as character no-undo.
define variable varrecid    as recid     no-undo.
define variable varlog      as logical   no-undo.
define variable var-args    as char      no-undo.
define variable var-ext-doc-type as char     no-undo.
do on error undo, return error return-value :
var-args = parmode.
parmode = entry(1, parmode).
run cntrcode-get-arg-val(var-args, "doc-type", output var-ext-doc-type).
if partype-contract = "" or partype-contract = ? then
   partype-contract = 'при':U .
assign
  parcontract-code = 0
.
if parmode = "input":u
then do:
  if parframe-value = ""
  then do:
    assign
      parcontract-code = 0
    .
  end.
  else do:
    find first bf_contract no-lock
      where bf_contract.host-code         = parhost-code
        and bf_contract.cli-type          = parcli-type
        and bf_contract.cli-code          = parcli-code
        and bf_contract.contract-prn-code = parframe-value
      no-error.
    if available bf_contract
    then do:
      find first bf-oth_contract no-lock
        where bf-oth_contract.host-code          = parhost-code
          and bf-oth_contract.contract-prn-code  = parframe-value
          and bf-oth_contract.cli-type           = parcli-type
          and bf-oth_contract.cli-code           = parcli-code
          and rowid(bf_contract)                 <> rowid(bf-oth_contract)
        no-error .
      if available bf-oth_contract
      then do:
        message
          "На фирме " parhost-code skip
          "у контрагента" parcli-type parcli-code skip
          "имеются два контракта с номером" parframe-value skip
        view-as alert-box .
      end.
      else do:
        assign
          parcontract-code = bf_contract.contract-code
        .
      end.
    end.
  end.
end.
if parmode <> "input":u
or parcontract-code = 0
then do:
  run str/cont-all.w (input parmenu-handle,
                  input parhost-code,
                  input "b-sel",
                  input if var-ext-doc-type = 'ee':U then 'фирма':U else "firm-curr" ,
                  input parcli-type,
                  input parcli-code,
                  input ?,
                  input ?,
                  input "current":u,
                  input partype-contract,
                  input-output varrid-list ) no-error.
  if error-status:error then do:
    message "Ошибка при вызове справочника договоров." skip
            return-value                skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    return error.
  end.
  assign
    varrecid = integer(entry(1, varrid-list)).
  find first bf_contract where recid(bf_contract) = varrecid no-lock no-error.
  if available bf_contract then do:
    assign
      parcontract-code = bf_contract.contract-code.
  end.
end.
if parcontract-code <> 0
then do:
  if (bf_contract.status_ = 'зкр':U or
      (bf_contract.contract-date-end <> ? and bf_contract.contract-date-end < parobj-date)) then do:
    if lookup(var-ext-doc-type, 'ep,re,rs,ee') = 0
    then do:
        assign
          varlog = no.
        message "Договор с номером " bf_contract.contract-prn-code " закрыт." skip
        view-as alert-box.
        assign
          parcontract-code = 0
        .
    end.
  end.
  if bf_contract.contract-date-beg > parobj-date then do:
    assign
      varlog = no.
    message "Дата открытия договора " bf_contract.contract-date-beg " . Договор с номером " bf_contract.contract-prn-code " еще не открыт." skip
    view-as alert-box.
    assign
      parcontract-code = 0
    .
  end.
  if parcontract-code <> 0
  then do:
    if bf_contract.cli-type <> parcli-type
    or bf_contract.cli-code <> parcli-code
    then do:
       message "По договору " bf_contract.contract-code
               ( if bf_contract.doc-type =  'при':U
                 then " поставщиком является "
                 else " покупателем является " )
               bf_contract.cli-type " " bf_contract.cli-code " ." skip
               "По документу контрагент " parcli-type " " parcli-code " ." skip
       view-as alert-box error.
       assign
         parcontract-code = 0.
    end.
    if parcontract-code <> ? then do:
      if not ( bf_contract.doc-type =  'при':U or bf_contract.doc-type =  'рас':U ) then do:
        message "Контракт имеет недопустимый тип." view-as alert-box.
        assign
          parcontract-code = 0.
      end.
    end.
  end.
end.
end.
end procedure.
procedure cntrcode-get-arg-val:
    def input param p-args as char no-undo.
    def input param p-key as char no-undo.
    def output param p-val as char no-undo.
    def var i as int no-undo.
    def var nums as int no-undo.
    def var key-val as char no-undo.
    nums = num-entries(p-args).
    do i = 1 to nums:
        key-val = entry(i, p-args).
        if key-val begins (p-key + "=") then do:
            p-val = entry(2, key-val, "=").
            return.
        end.
    end.
    p-val = "".
end.
define variable v-cntxt-host-name-obj  as character no-undo .
define  shared variable rep-rec   as recid     no-undo .
define  shared variable list-mode as character no-undo .
define  shared variable doc-rec   as recid     no-undo .
define variable notes                     as character no-undo .
define variable v-update-price            as integer   no-undo .
define variable v-deliv-type-code         as integer   no-undo .
define variable v-point-obj-code          as integer   no-undo .
define variable v-point-cli-code          as integer   no-undo .
define variable v-point-obj-db-num        as integer   no-undo .
define variable v-point-cli-db-num        as integer   no-undo .
define variable v-transport-host-code     as integer   no-undo .
define variable v-transport-cli-type      as character no-undo .
define variable v-transport-cli-code      as integer   no-undo .
define variable v-transport-contract      as integer   no-undo .
define variable v-transport-condition     as integer   no-undo .
define variable v-transport-value         as decimal   no-undo .
define variable v-transport-sum           as decimal   no-undo .
define variable v-transport-vat           as decimal   no-undo .
define variable v-num                     as integer   no-undo .
define variable v-error                   as logical   no-undo .
define variable doc-mode    as character no-undo .
define variable line-mode   as character no-undo .
define variable line-rec    as recid no-undo .
define variable gds-rec     as recid no-undo .
define variable prt-rec     as recid no-undo .
define variable flt-rec      as recid     no-undo .
define variable g#report-num as integer   no-undo .
define variable next-prev    as logical   no-undo .
define variable g#log        as logical   no-undo .
define variable ref-rec      as recid     no-undo .
define variable base-code    as integer   no-undo .
define variable g#out-pay    as integer   no-undo .
define variable g#stat       as character no-undo .
define variable prt-mode     as character no-undo .
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxp-db-num
    ,output v-cntxp-userid
    ,output v-cntxp-level
    ,output v-cntxp-curr-host-code
    ,output v-cntxp-obj-type
    ,output v-cntxp-obj-code
    ,output v-cntxp-db-num-obj
    ,output v-cntxp-is-admin
    ) .
  if (v-cntxp-obj-type = 'маг':U or v-cntxp-obj-type = 'скл':U) and
     v-cntxp-obj-code <> 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output v-cntxp-conf-par
  ,output v-cntxp-par-type
  ) no-error .
    case v-cntxp-obj-type :
      when 'скл':U then do:
        find first bf-cntxp_store where bf-cntxp_store.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_store.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_store.doc-prt
          v-cntxp-price-calc      = bf-cntxp_store.price-calc
          v-cntxp-inout-price     = bf-cntxp_store.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_store.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_store.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_store.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_store.in-ov
          v-cntxp-in-perm         = bf-cntxp_store.in-perm
          v-cntxp-no-eq           = bf-cntxp_store.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_store.rsrv-time
          v-cntxp-load-time       = bf-cntxp_store.load-time
          v-cntxp-holidays        = bf-cntxp_store.holidays
          v-cntxp-in-pay          = bf-cntxp_store.in-pay
          v-cntxp-out-pay         = bf-cntxp_store.out-pay
          v-cntxp-ret-pay         = bf-cntxp_store.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_store.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_store.down-pay
          v-cntxp-inv-pay         = bf-cntxp_store.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_store.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
      when 'маг':U then do:
        find first bf-cntxp_shop where bf-cntxp_shop.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_shop.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_shop.doc-prt
          v-cntxp-price-calc      = bf-cntxp_shop.price-calc
          v-cntxp-inout-price     = bf-cntxp_shop.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_shop.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_shop.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_shop.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_shop.in-ov
          v-cntxp-in-perm         = bf-cntxp_shop.in-perm
          v-cntxp-no-eq           = bf-cntxp_shop.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_shop.rsrv-time
          v-cntxp-load-time       = bf-cntxp_shop.load-time
          v-cntxp-holidays        = bf-cntxp_shop.holidays
          v-cntxp-in-pay          = bf-cntxp_shop.in-pay
          v-cntxp-out-pay         = bf-cntxp_shop.out-pay
          v-cntxp-ret-pay         = bf-cntxp_shop.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_shop.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_shop.down-pay
          v-cntxp-inv-pay         = bf-cntxp_shop.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_shop.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
    end case.
  end.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-cntxt-host-code-obj
  ,output v-cntxt-host-name-obj
  )  .
run get-report-num  in parParentProc ( output g#report-num ).
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure proc-ord-code :
define input  parameter  p-type as character no-undo .
define input  parameter  v-cntxt-db-num   as integer   no-undo .
define input  parameter  v-cntxt-obj-type as character no-undo .
define input  parameter  v-cntxt-obj-code as integer   no-undo .
define input  parameter  p-i-doc    as character no-undo .
define output parameter  p-ord-doc  as character no-undo .
define variable          v-idop     as character no-undo .
  do
  on error undo, return error return-value
  :
case p-type :
    when "main-no-ver" then do:
      if  (v-cntxt-db-num <> 0) then
        p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (v-cntxt-obj-code, ">>>>9")) + substring (v-cntxt-obj-type, (if g#language = "RUS" then 1 else 2), 1).
      else
        p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-".
    end.
    when "main" then do:
          do while true:
          if  (v-cntxt-db-num <> 0) then
            p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (v-cntxt-obj-code, ">>>>9")) + substring (v-cntxt-obj-type, (if g#language = "RUS" then 1 else 2), 1).
          else
            p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-".
          if not can-find (ub.ord-doc where ub.ord-doc.doc-code = p-ord-doc no-lock) then leave.
          End.
    end.
    when "chip" then do:
      assign
        v-idop = p-i-doc .
      do while true :
        if index (v-idop , ".") = 0 then
          v-idop  = replace (v-idop , "-", "-1.").
        else
          v-idop  =
          substring (v-idop , 1, index (v-idop, "-")) +
          string (integer (substring (v-idop, index (v-idop, "-") + 1, index (v-idop, ".") - index (v-idop, "-") - 1)) + 1) +
          substring (v-idop, index (v-idop, ".")).
        if not can-find (ub.ord-doc where ub.ord-doc.doc-code = v-idop no-lock) then leave.
      end.
      assign
        p-ord-doc = v-idop.
    end.
end case.
  end.
end procedure.
define buffer l-shar_ord-line for ub.ord-line.
define buffer buf_ord-line-attr for ub.ord-line-attr.
define variable store-type as character no-undo .
define variable store-code as integer   no-undo .
assign
  store-type = v-cntxt-obj-type
  store-code = v-cntxt-obj-code
  loc-store-type = v-cntxt-obj-type
  loc-store-code = v-cntxt-obj-code
.
define shared variable x-mode as character  no-undo .
define buffer buf-units for ub.units.
define buffer for-cli   for ub.clients.
define buffer for-obj   for ub.clients.
define variable p-doc-code like ub.ord-line.doc-code no-undo .
define variable tmp-rec    as recid   no-undo.
define variable choice     as logical no-undo  init ? .
define variable var#import as logical no-undo  init false .
define buffer l-ord-line for ub.ord-line .
define variable last-curr-code like ub.currency.curr-abbr no-undo.
define variable cli-name       like ub.clients.obj-name   no-undo.
define variable gds-name       like ub.goods.gds-name     no-undo.
define variable unit-base      like ub.goods.unit-base    no-undo.
define stream cg-stream.
define variable date_string as character no-undo.
define variable line        as character no-undo.
define variable for-time    as character no-undo.
define variable producer    as character no-undo.
define variable filter-point as character no-undo init "cli-zakz-new" .
define variable filter-label as character no-undo init "Заказ_поставщику_new" .
define variable sort-column-name as character no-undo .
define variable t#query-was-opened as logical init false no-undo .
define variable rep-rec2 as recid   no-undo .
define variable rep-rec3 as recid   no-undo .
define variable t-ret    as logical no-undo .
define variable x-prod-type like ub.goods.prod-type no-undo .
define variable x-prod-code like ub.goods.prod-code no-undo .
define variable x-artic     like ub.goods.artic     no-undo .
define variable v-fl     as logical no-undo .
define variable jj       as integer no-undo .
define variable a-n-c as character view-as radio-set horizontal radio-buttons
"&А","art",
"&Н","name",
"&К","code"
size 12 by 1 no-undo.
define variable loc-art  as character  format "x(10)":u label "Нач.артик." view-as fill-in size 14 by 1 fgcolor red_color no-undo .
define variable loc-name as character  label "Нач.назв."  view-as fill-in size 14 by 1 fgcolor red_color  no-undo.
define variable loc-code as character  format "x(14)":u label "Бар-код" view-as fill-in  size 14 by 1 fgcolor red_color  no-undo.
define variable base-abbr as character format "x(3)":u
      view-as text
     size 4 by 1 no-undo.
define variable v-copy-doc-code as character no-undo .
head-col =
  '*! '     + '#' +
  '№!п/п'     + '#' +
  'ш! '      + '#' +
  'Артикул! '      + '#' +
  'Название! '      + '#' +
  'Е.и.!пост'      + '#' +
  'Заказ!ед.пост'      + '#' +
  'Запрошено!количество'     + '#' +
  'Последн.цена!пост-ка'      + '#' +
  'Запрошена!цена'     + '#' +
  'Сумма!ед.пост'      + '#' +
  'Артикул!поставщика'      + '#' +
  'Е.и.!баз.'      + '#' +
  'Заказ! '     + '#' +
  'Цена!(руб)'     + '#' +
  'Сумма!(руб) '     + '#' +
  'Темп продаж!при расчете'     + '#' +
  'Кол-во остатки!при расчете'     + '#' +
  'x! '     + '#' +
  'Код!товара'     + '#' +
  'Расcчитн.!кол-во'     + '#' +
  'Мин.!остаток'     + '#' +
  'Тов.!в пути'
  .
define menu m-del
       menu-item m_del2         label "&1. Удалить отмеченные * товары" accelerator "alt-1"
       menu-item m_del4         label "&2. Удалить текущий товар" accelerator "alt-2"
       menu-item m_del3         label "&3. Удалить по списку товаров" accelerator "alt-3"
       menu-item m_del1         label "&4. Удалить товары с нулевым кол-вом " accelerator "alt-4" .
define menu m-export
       menu-item m_export_text  label "&1. Экспорт заказа в формат Моб.сканера" accelerator "alt-1"
       menu-item m_export_excel label "&2. Экспорт заказа в Еxcel" accelerator "alt-2"
       rule
       menu-item m_export_ras   label "&3. Экспорт предварительного расчета в Еxcel" accelerator "alt-3"  .
define menu m-import
       menu-item m_import_text  label "&1. Импорт из формата Моб.сканера" accelerator "alt-1"
       menu-item m_import_excel label "&2. Импорт из Excel" accelerator "alt-2"      .
define menu m-way
       menu-item m_way1         label "&1. Заказано до даты поставки по товару" accelerator "alt-1"
       menu-item m_way2         label "&2. Заказано на период продажи по товару" accelerator "alt-2"
       rule
       menu-item m_way3         label "&3. Заказано до даты поставки по всем товарам" accelerator "alt-2"
       menu-item m_way4         label "&4. Заказано на период продажи по всем товарам" accelerator "alt-4"       .
define menu m-spec
       menu-item m_spec1         label "&1. Добавление по спецификации"
       menu-item m_spec2         label "&2. Обновление по спецификации"  .
DEFINE BUTTON B-protocol
     LABEL "Протокол"
     SIZE 10 BY 1 TOOLTIP "Протокол расчета заказа".
DEFINE BUTTON B-delivery
     LABEL "Доставка"
     SIZE 10 BY 1 TOOLTIP "Условия доставки".
define button b-alt-post
     label "Др&угие"
     size 8 by 1 tooltip "А что у других поставщиков?"
     bgcolor 8 .
define button b-del
     label "&Удал"
     size 8 by 1 tooltip "Удалить товары"
     bgcolor 8 .
define button b-spec
     label "Специ&фикация"
     size 16 by 1 tooltip "Добавить по спецификации договора"
     bgcolor 8 .
define button b-exit   auto-go
     label "Вы&ход"
     size 7 by 1 tooltip "Выход с сохранением"
     bgcolor 8 .
define button b-export
     label "&Экспорт"
     size 8 by 1 tooltip "Экспорт в разные форматы"
     bgcolor 8 .
define button b-gds-prt
     label "&Шкала"
     size 8 by 1 tooltip "Шкала"
     bgcolor 8 .
define button b-chg
     label "&Изм"
     size 8 by 1 tooltip "Изменить строку заказа.заявки"
     bgcolor 8 .
define button b-help
     label "Помо&щь"
     size 8 by 1 tooltip "Помощь"
     bgcolor 8 .
define button b-import
     label "Имп&орт"
     size 8 by 1 tooltip "Импорт из excel"
     bgcolor 8 .
define button b-add
     label "&Добав"
     size 8 by 1 tooltip "Добавить товары"
     bgcolor 8 .
define button b-way
     label "&В пути"
     size 8 by 1 tooltip "Список заказов товара в пути"
     bgcolor 8 .
define button b-itogs
     label "&Итоги"
     size 8 by 1 tooltip ""
     bgcolor 8 .
define button b-notes
     label "При&м":l
     size 8 by 1 tooltip "Изменить примечание к заказу.заявке".
define button b-uf
     image file "cmp/b-must.bmp":u
     tooltip "Настройка колонок в таблице для пользователя"
     SIZE 3 BY 1.
define button b-producer
     label "&Пр-ль"
     size 8 by 1 tooltip "Данные о Производителе"
     bgcolor 8 .
define button b-remove
     label "&х"
     size 3 by 1 tooltip "Проставить/снять пометку по товару, если его нет у Поставщика"
     bgcolor 8 .
define button b-mark
     label "&*":l
     size 3 by 1 tooltip "Проставить/снять пометку по товару, используется для удаления".
define button b-main-calc
     label "&Расчет"
     size 8 by 1 tooltip "Расчет заказа/заявки"
     bgcolor 8 .
define button b-sch
     label "&Фильтр"
     size 8 by 1 tooltip "Установка и снятие фильтра по записям"
     bgcolor 8 .
define button r-acc
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     label "r-acc"
     size 3 by .88 tooltip "Выбор из списка".
define button r-agnt
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     label "r-acc"
     size 3 by .88 tooltip "Выбор из списка".
define button r-boss
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     label "r-acc"
     size 3 by .88 tooltip "Выбор из списка".
define button r-clients
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     label "r-cli"
     size 3 by .88 tooltip "Выбор из списка".
define button r-currency
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     label "r-acc"
     size 3 by .88.
define button r-paytype
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     label "r-paytype"
     size 3 by .88 tooltip "Выбор из списка типа оплаты".
define button r-contract
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     size 3 by .88 tooltip "Выбор из списка договоров".
define button r-wrkr
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     label "r-acc"
     size 3 by .88 tooltip "Выбор из списка".
define button b-renum
     label "&№п/п"
     size 8 by 1 tooltip "Перенумеровать список товаров" .
define button b-contract
     image-up file "cmp/btn-fnd.bmp":u
     image-down file "cmp/btn-fnd.bmp":u
     image-insensitive file "cmp/btn-fnd.bmp":u no-convert-3d-colors
     label "b-contract"
     size 3 by 1 tooltip "Посмотреть До&говор".
define variable agnt-name as character format "x(256)":u
      view-as text
     size 14 by 1 tooltip "Исполнитель"
     fgcolor 4  no-undo.
define variable boss-name as character format "x(256)":u
     view-as text
     size 14 by 1 tooltip "Менеджер"
     fgcolor 4  no-undo.
define variable goods-name as character format "x(256)":u
     label "Наим."
      view-as text
     size 54.38 by .67 tooltip "Наименование товара"
     fgcolor 4  no-undo.
define variable loc-pay-type as character format "x(256)":u
      view-as text
     size 12.5 by .67 tooltip "Тип оплаты"
     fgcolor 4  no-undo.
define variable prod-name as character format "x(256)":u
     label "Пр.-ль"
      view-as text
     size 54.38 by .67 tooltip "Производитель товара"
     fgcolor 4  no-undo.
define variable t as character format "x(2)":u initial "дн"
      view-as text
     size 2 by 1 no-undo.
define variable wrkr-name as character format "x(256)":u
      view-as text
     size 14 by 1 tooltip "Исполнитель"
     fgcolor 4  no-undo.
define variable t-auto as logical
     label "авто"
     view-as toggle-box
     size 7.25 by .83 tooltip "Рассчитывать заказ\заявку автоматически" no-undo.
define variable loc-obj-name-2 as character format "x(256)":u
      label "От"
      view-as text
      size 29 by .69 tooltip "От кого"
     fgcolor 4  no-undo.
define rectangle rect-4
     edge-pixels 2 graphic-edge  no-fill
     size 30.38 by 8.46.
define rectangle rect-5
     edge-pixels 2 graphic-edge  no-fill
     size 35.25 by 9.92.
define rectangle rect-6
     edge-pixels 2 graphic-edge  no-fill
     size 33.88 by 8.42.
define rectangle rect-7
     edge-pixels 2 graphic-edge  no-fill
     size 64.13 by 1.63.
define new shared query br-docs for
      shar_ord-line, tmp#zakaz  scrolling.
define query br-docs-2 for
      tmp#zakaz-dtl scrolling.
define browse br-docs
  query br-docs no-lock display
   tmp#zakaz.local-mark  column-label '*! '   format "x(1)"
   tmp#zakaz.line-num  column-label '№!п/п'   format ">>>>"
   tmp#zakaz.prt-ok   column-label 'ш! '    format "+/-"
   tmp#zakaz.artic   column-label 'Артикул! '
   tmp#zakaz.gds-name   column-label 'Название! '    format "x(50)"
   tmp#zakaz.unit-cli   column-label 'Е.и.!пост'    format "x(3)"
   tmp#zakaz.cli-qnty   column-label 'Заказ!ед.пост'    format "->,>>>,>>9.999"
   tmp#zakaz.order-cli-qnty  column-label 'Запрошено!количество'   format "->,>>>,>>>,>>9.999"
   tmp#zakaz.price-cli   column-label 'Последн.цена!пост-ка'    format "->>>,>>>,>>9.99"
   tmp#zakaz.ord-dec1  column-label 'Запрошена!цена'   format "->,>>>,>>>,>>9.99"
   tmp#zakaz.sum-cli   column-label 'Сумма!ед.пост'    format "->,>>>,>>>,>>9.99"
   tmp#zakaz.cli-art   column-label 'Артикул!поставщика'    format "x(16)"
   tmp#zakaz.unit-base   column-label 'Е.и.!баз.'     format "x(3)"
   tmp#zakaz.qnty  column-label 'Заказ! '    format "->,>>>,>>9.999"
   tmp#zakaz.price-rubl  column-label 'Цена!(руб)'    format "->>>,>>>,>>9.99"
   tmp#zakaz.sum-rubl  column-label 'Сумма!(руб) '    format "->,>>>,>>>,>>9.99"
   tmp#zakaz.temp-rash  column-label 'Темп продаж!при расчете'    format "->,>>>,>>>,>>9.99"
   tmp#zakaz.qnty-stk  column-label 'Кол-во остатки!при расчете'    format "->,>>>,>>>,>>9.99"
   (if tmp#zakaz.cancel-date = ? then '' else '*' )  column-label 'x! '    format "x(1)"
   tmp#zakaz.gds-code  column-label 'Код!товара'
   tmp#zakaz.initial-qnty  column-label 'Расcчитн.!кол-во'
   tmp#zakaz.min-stock-old  column-label 'Мин.!остаток'
   tmp#zakaz.gds-way  column-label 'Тов.!в пути'
  enable
      tmp#zakaz.cli-art
    with no-assign  separators size-char 98  by 8.54.
define browse br-docs-2
  query br-docs-2 no-lock display
      tmp#zakaz-dtl.prt-name   column-label "Признак! ":c8            format "x(16)"
      tmp#zakaz-dtl.cli-qnty   column-label "Заказ!ед.пост":c13       format "->>>,>>>,>>9.999"
      tmp#zakaz-dtl.price-cli  column-label "Цена!поставщика":c15     format "->>>,>>>,>>9.99"
      tmp#zakaz-dtl.sum-cli    column-label "Сумма! ":c6              format "->,>>>,>>>,>>9.99"
    with separators size-char 0.1 by 8.54 .
define frame dialog-frame
     b-exit at row 1.08 col 1
     loc-cli-type at row 1.08 col 11 colon-aligned
     loc-cli-code at row 1.08 col 15.13 colon-aligned no-label
     r-clients at row 1.08 col 27
     doc-date view-as fill-in    size 9 by 1 at row 8.5 col 8.38 colon-aligned
     fact-date at row 9.63 col 8.38 colon-aligned
     r-wrkr at row 2.21 col 31.63
     wrkr   at row 2.29 col 6 colon-aligned
     tog-type  at row 2.4 col 34.9
     cycle-day at row 2.4 col 55.5 colon-aligned
     t         at row 2.4 col 60.5 colon-aligned no-label
     loc-cli-out-doc at row 2.1 col 82.38 colon-aligned
     loc-pay-type    at row 3.1 col 82.38 colon-aligned no-label
     paytype         at row 3.1 col 73.25 colon-aligned
     r-paytype       at row 3.1 col 97
     r-agnt at row 3.13 col 31.63
     agnt at row 3.21 col 6 colon-aligned
     loc-date-ship at row 3.38 col 43 colon-aligned
     loc-service at row 4.08 col 83.63 colon-aligned
     r-boss at row 4.17 col 31.63
     boss at row 4.25 col 6 colon-aligned
     pay-day      at row 4.38 col 54.88 colon-aligned
     loc-out-code at row 5.38 col 52.75 colon-aligned
     date-sale-1  at row 4.38 col 51.25 colon-aligned
     date-sale-2  at row 5.38 col 51.25 colon-aligned
     loc-qnty at row 5.08 col 83.63 colon-aligned
     r-currency at row 5.29 col 31.63
     loc-exch-code at row 5.38 col 10.5 colon-aligned
     loc-cli-qnty at row 6.08 col 83.63 colon-aligned
     r-acc at row 6.29 col 31.63
     loc-exch-rate at row 6.42 col 10.63 colon-aligned
     loc-exch-scale at row 6.42 col 25.25 colon-aligned
     loc-sum-rubl at row 7.04 col 83.63 colon-aligned
     loc-sum-base at row 7.96 col 83.63 colon-aligned
     loc-sum-cli at row 8.92 col 83.63 colon-aligned
     loc-contract at row 9.88 col 78 colon-aligned
     r-contract   at row 9.88 col 97
     b-contract   at row 9.88 col 94
     e-method at row 7.08 col 35 no-label
     loc-base-rate at row 7.46 col 1.63
     loc-base-scale at row 7.46 col 25.25 colon-aligned
     loc-tot-lines at row 8.7 col 25 colon-aligned
     slt_type at row 10.96 col 72.75 colon-aligned
     vat_type at row 10.96 col 87.75 colon-aligned
     br-docs-2 at row 12.08 col 98
     br-docs at row 12.08 col 1
     b-mark at row 20.71 col 1
     b-add at row 20.71 col 4
     b-del at row 20.71 col 12
     b-spec at row 21.71 col 12
     b-chg at row 20.71 col 20
     b-producer at row 20.71 col 28
     b-alt-post at row 20.71 col 36
     b-export at row 20.71 col 44
     b-import at row 20.71 col 52
     b-main-calc at row 20.71 col 60
     b-gds-prt at row 20.71 col 68
     b-way  at row 20.71 col 76
     b-sch at row 20.71 col 73
     b-notes at row 20.71 col 84
     b-uf at row 20.71 col 92
     b-help at row 20.71 col 92
     b-itogs  at row 21.71 col 1
     t-auto   at row 21.71 col 1
     b-delivery at row 21.71  col 28
     B-protocol at row 21.71  col 38
     loc-code at row 21.71 col 50 colon-aligned
     loc-name at row 21.71 col 50 colon-aligned
     loc-art  at row 21.71 col 50 colon-aligned
     a-n-c    at row 21.71 col 76 no-label
     b-remove at row 21.71 col 89
     b-renum  at row 21.71 col 92
     loc-obj-name at row 1.08 col 28.25 colon-aligned no-label
     loc-obj-name-2 at row 1.08 col 67.5 colon-aligned
     wrkr-name at row 2.33 col 17.63 no-label
     agnt-name at row 3.25 col 17.63 no-label
     boss-name at row 4.29 col 17.63 no-label
     ub.currency.curr-abbr at row 5.42 col 25.25 colon-aligned no-label
          view-as text
          size 4 by 1
          fgcolor 4
     prod-name at row 10.58 col 8.5 colon-aligned
     goods-name at row 11.29 col 8.5 colon-aligned
.
define frame dialog-frame
     rect-6 at row 2.13  col 1
     rect-7 at row 10.46 col 1
     rect-5 at row 2.13  col 65
     rect-4 at row 2.13  col 34.75
     ":" view-as text
         size 1.25 by 1 at row 3.38 col 59.5
     loc-time-ship at row 3.38 col 54.88 colon-aligned no-label
     loc-min  at row 3.38 col 59.13 colon-aligned no-label
     loc-hour at row 3.38 col 53.88 colon-aligned no-label
     "Метод расчета заказа\заявки" view-as text
          size 27 by .67 at row 6.5 col 35.75
    with view-as dialog-box keep-tab-order
         side-labels no-underline three-d  scrollable
         title "ЗАКАЗ".
assign
       frame dialog-frame:scrollable  = false
       frame dialog-frame:hidden      = true
       b-del:popup-menu in frame dialog-frame       = menu m-del:handle
       b-spec:popup-menu in frame dialog-frame      = menu m-spec:handle
       b-way:popup-menu in frame dialog-frame       = menu m-way:handle
       b-export:popup-menu in frame dialog-frame    = menu m-export:handle
       b-import:popup-menu in frame dialog-frame    = menu m-import:handle
       b-del:menu-mouse = 1
       b-spec:menu-mouse = 1
       b-way:menu-mouse = 1
       b-export:menu-mouse = 1
       b-import:menu-mouse = 1
       br-docs-2:num-locked-columns in frame dialog-frame = 1
 .
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON MOUSE-SELECT-DBLCLICK OF loc-date-ship IN FRAME dialog-frame
DO:
  apply "entry" to loc-date-ship in frame dialog-frame.
  apply "entry" to loc-time-ship in frame dialog-frame.
   return no-apply .
end.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON MOUSE-SELECT-DBLCLICK OF loc-time-ship IN FRAME dialog-frame
DO:
  apply "entry" to loc-time-ship in frame dialog-frame.
  apply "entry" to paytype in frame dialog-frame.
   return no-apply .
end.
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON MOUSE-SELECT-DBLCLICK OF loc-service IN FRAME dialog-frame
DO:
  apply "entry" to loc-service in frame dialog-frame.
  apply "entry" to b-add in frame dialog-frame.
   return no-apply .
end.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON CHOOSE OF r-wrkr IN FRAME Dialog-Frame
DO:
   run proc-r-wrkr in this-procedure .
END.
ON LEAVE OF wrkr IN FRAME Dialog-Frame
DO:
run leave-proc-wrkr in this-procedure .
END.
procedure leave-proc-wrkr :
 do
 on error undo, return error return-value
 :
  Assign frame dialog-frame wrkr .
  def buffer wrkr-clients for ub.clients.
  if wrkr <> ? OR wrkr <> 0 THEN DO:
    find first wrkr-clients WHERE wrkr-clients.obj-type = 'чел':U  AND wrkr = wrkr-clients.obj-code  No-LOCK No-ERROR.
    if error-status :error then error-status :error = false .
    if avail wrkr-clients Then DO:
          wrkr-name = wrkr-clients.obj-name .
          wrkr-name:screen-value  = wrkr-clients.obj-name .
          Display  wrkr wrkr-name with frame dialog-frame.
          Enable wrkr wrkr-name b-producer B-Alt-post with frame dialog-frame.
        End.
        Else DO:
          Assign
          wrkr-name:screen-value = ""
          wrkr:screen-value = ?
          .
          apply "entry" to wrkr in frame dialog-frame.
        End.
    End.
end.
end procedure.
ON  RETURN OF wrkr IN FRAME Dialog-Frame
DO:
    if wrkr = ? then run proc-r-wrkr in this-procedure .
    run apply-focus-next-entry in this-procedure  (input  wrkr:handle ) .
    return no-apply .
END.
ON MOUSE-SELECT-DBLCLICK OF wrkr IN FRAME dialog-frame
DO:
  apply "choose" to r-wrkr in frame dialog-frame.
  apply "entry" to wrkr in frame dialog-frame.
    return no-apply .
end.
Procedure proc-r-wrkr :
 do
 on error undo, return error return-value
 :
  define variable rid-list    as  char no-undo .
  def buffer wrkr#clients for ub.clients.
    run ref/cli-all.w
    ( input parParentProc,
      input "b-sel",
      input 'чел':U,
      input ?,
      input ?,
      input ref-rec ,
      input ",,,,,,NO"   ,
      input "lock-cli-type",
      output  rid-list
      ) .
    Assign
      rep-rec2 = integer(rid-list)
      ref-rec = integer(rid-list)
      no-error.
    find first wrkr#clients WHERE recid(wrkr#clients) = rep-rec2 No-LOCK No-ERROR.
    if avail wrkr#clients then
        Assign
            wrkr = wrkr#clients.obj-code
            wrkr-name = wrkr#clients.obj-name .
    Enable  wrkr wrkr-name with frame dialog-frame .
    Display wrkr wrkr-name with frame dialog-frame .
end.
end procedure.
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON CHOOSE OF r-agnt IN FRAME Dialog-Frame
DO:
   run proc-r-agnt in this-procedure .
END.
ON LEAVE OF agnt IN FRAME Dialog-Frame
DO:
run leave-proc-agnt in this-procedure .
END.
procedure leave-proc-agnt :
 do
 on error undo, return error return-value
 :
  Assign frame dialog-frame agnt .
  def buffer agnt-clients for ub.clients.
  if agnt <> ? OR agnt <> 0 THEN DO:
    find first agnt-clients WHERE agnt-clients.obj-type = 'чел':U  AND agnt = agnt-clients.obj-code  No-LOCK No-ERROR.
    if error-status :error then error-status :error = false .
    if avail agnt-clients Then DO:
          agnt-name = agnt-clients.obj-name .
          agnt-name:screen-value  = agnt-clients.obj-name .
          Display  agnt agnt-name with frame dialog-frame.
          Enable agnt agnt-name b-producer B-Alt-post with frame dialog-frame.
        End.
        Else DO:
          Assign
          agnt-name:screen-value = ""
          agnt:screen-value = ?
          .
          apply "entry" to agnt in frame dialog-frame.
        End.
    End.
end.
end procedure.
ON  RETURN OF agnt IN FRAME Dialog-Frame
DO:
    if agnt = ? then run proc-r-agnt in this-procedure .
    run apply-focus-next-entry in this-procedure  (input  agnt:handle ) .
    return no-apply .
END.
ON MOUSE-SELECT-DBLCLICK OF agnt IN FRAME dialog-frame
DO:
  apply "choose" to r-agnt in frame dialog-frame.
  apply "entry" to agnt in frame dialog-frame.
    return no-apply .
end.
Procedure proc-r-agnt :
 do
 on error undo, return error return-value
 :
  define variable rid-list    as  char no-undo .
  def buffer agnt#clients for ub.clients.
    run ref/cli-all.w
    ( input parParentProc,
      input "b-sel",
      input 'чел':U,
      input ?,
      input ?,
      input ref-rec ,
      input ",,,,,,NO"   ,
      input "lock-cli-type",
      output  rid-list
      ) .
    Assign
      rep-rec2 = integer(rid-list)
      ref-rec = integer(rid-list)
      no-error.
    find first agnt#clients WHERE recid(agnt#clients) = rep-rec2 No-LOCK No-ERROR.
    if avail agnt#clients then
        Assign
            agnt = agnt#clients.obj-code
            agnt-name = agnt#clients.obj-name .
    Enable  agnt agnt-name with frame dialog-frame .
    Display agnt agnt-name with frame dialog-frame .
end.
end procedure.
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON CHOOSE OF r-boss IN FRAME Dialog-Frame
DO:
   run proc-r-boss in this-procedure .
END.
ON LEAVE OF boss IN FRAME Dialog-Frame
DO:
run leave-proc-boss in this-procedure .
END.
procedure leave-proc-boss :
 do
 on error undo, return error return-value
 :
  Assign frame dialog-frame boss .
  def buffer boss-clients for ub.clients.
  if boss <> ? OR boss <> 0 THEN DO:
    find first boss-clients WHERE boss-clients.obj-type = 'чел':U  AND boss = boss-clients.obj-code  No-LOCK No-ERROR.
    if error-status :error then error-status :error = false .
    if avail boss-clients Then DO:
          boss-name = boss-clients.obj-name .
          boss-name:screen-value  = boss-clients.obj-name .
          Display  boss boss-name with frame dialog-frame.
          Enable boss boss-name b-producer B-Alt-post with frame dialog-frame.
        End.
        Else DO:
          Assign
          boss-name:screen-value = ""
          boss:screen-value = ?
          .
          apply "entry" to boss in frame dialog-frame.
        End.
    End.
end.
end procedure.
ON  RETURN OF boss IN FRAME Dialog-Frame
DO:
    if boss = ? then run proc-r-boss in this-procedure .
    run apply-focus-next-entry in this-procedure  (input  boss:handle ) .
    return no-apply .
END.
ON MOUSE-SELECT-DBLCLICK OF boss IN FRAME dialog-frame
DO:
  apply "choose" to r-boss in frame dialog-frame.
  apply "entry" to boss in frame dialog-frame.
    return no-apply .
end.
Procedure proc-r-boss :
 do
 on error undo, return error return-value
 :
  define variable rid-list    as  char no-undo .
  def buffer boss#clients for ub.clients.
    run ref/cli-all.w
    ( input parParentProc,
      input "b-sel",
      input 'чел':U,
      input ?,
      input ?,
      input ref-rec ,
      input ",,,,,,NO"   ,
      input "lock-cli-type",
      output  rid-list
      ) .
    Assign
      rep-rec2 = integer(rid-list)
      ref-rec = integer(rid-list)
      no-error.
    find first boss#clients WHERE recid(boss#clients) = rep-rec2 No-LOCK No-ERROR.
    if avail boss#clients then
        Assign
            boss = boss#clients.obj-code
            boss-name = boss#clients.obj-name .
    Enable  boss boss-name with frame dialog-frame .
    Display boss boss-name with frame dialog-frame .
end.
end procedure.
ON CHOOSE OF r-contract IN FRAME Dialog-Frame
DO:
 run r-contract-choose in this-procedure no-error .
 if error-status :error then return no-apply .
END.
ON CHOOSE OF r-paytype IN FRAME Dialog-Frame
DO:
   run r-paytype-CHOOSE in this-procedure .
end.
ON LEAVE OF paytype IN FRAME Dialog-Frame
DO:
   run paytype-leave-proc in this-procedure .
end.
ON  return OF paytype IN FRAME Dialog-Frame
DO:
    run apply-focus-next-entry in this-procedure  (input  PAYTYPE:handle ) .
    return no-apply .
END.
ON LEAVE OF loc-time-ship IN FRAME Dialog-Frame
DO:
   run leave-loc-time-ship in this-procedure .
END.
ON  return OF loc-time-ship IN FRAME Dialog-Frame
DO:
   run apply-focus-next-entry in this-procedure  (input  PAYTYPE:handle ) .
   return no-apply .
END.
ON VALUE-CHANGED of TOG-type IN FRAME dialog-frame
DO:
  run vg-TOG-type in this-procedure .
End.
ON LEAVE  OF loc-cli-type IN FRAME Dialog-Frame
DO:
  run LEAVE-loc-cli-type in this-procedure.
END.
ON  RETURN OF loc-cli-type IN FRAME Dialog-Frame
DO:
  run apply-focus-next-entry in this-procedure  (input  loc-cli-code :handle ) .
END.
ON LEAVE OF loc-cli-code IN FRAME Dialog-Frame
DO:
  run LEAVE-loc-cli-code in this-procedure no-error .
  if error-status :error then do:
     apply "choose" to r-clients in frame dialog-frame .
  end.
  if can-find (first ub.contract where ub.contract.cli-code = loc-cli-code and ub.contract.cli-type = loc-cli-type and ub.contract.host-code = v-cntxt-host-code-obj) then do:
    if loc-cli-code <> ? then do:
      run r-contract-choose in this-procedure no-error .
      if error-status :error then return no-apply .
    end.
  end.
END.
ON  RETURN OF loc-cli-code IN FRAME Dialog-Frame
DO:
  run apply-focus-next-entry in this-procedure  (input  loc-cli-code :handle ) .
  return no-apply .
END.
ON any-key OF loc-cli-code IN FRAME Dialog-Frame
DO:
  v-fl = false .
END.
on end-error, stop of frame dialog-frame do:
  apply "choose" to b-exit in frame dialog-frame.
  ERROR-STATUS:ERROR = false .
  return .
end.
ON MOUSE-SELECT-DBLCLICK OF loc-cli-code IN FRAME dialog-frame
DO:
  apply "choose" to r-clients in frame dialog-frame.
  apply "entry" to loc-date-ship  in frame dialog-frame.
end.
ON MOUSE-SELECT-DBLCLICK OF paytype IN FRAME dialog-frame
DO:
  apply "choose" to r-paytype in frame dialog-frame.
  apply "entry" to wrkr  in frame dialog-frame.
end.
ON CHOOSE OF r-clients IN FRAME Dialog-Frame
DO:
  run r-clients-ch in this-procedure no-error  .
  if error-status :error then return no-apply.
  if can-find (first ub.contract where ub.contract.cli-code = loc-cli-code and ub.contract.cli-type = loc-cli-type and ub.contract.host-code = v-cntxt-host-code-obj) then do:
    if loc-cli-code <> ? then do:
      run r-contract-choose in this-procedure no-error .
      if error-status :error then return no-apply .
    end.
  end.
END.
ON value-changed OF slt_type IN FRAME dialog-frame
OR value-changed OF VAT_type IN FRAME dialog-frame run val-ch-type in this-procedure (input self:name) no-error.
ON LEAVE, return OF loc-exch-rate  IN FRAME dialog-frame
OR LEAVE, return OF loc-exch-scale IN FRAME dialog-frame
OR LEAVE, return OF loc-base-rate  IN FRAME dialog-frame
OR LEAVE, return OF loc-base-scale IN FRAME dialog-frame
DO:
   run update-rate-doc in this-procedure no-error.
   if error-status:error then do:
      run disp-exch in this-procedure .
      return no-apply.
   end.
END.
ON RETURN, leave OF loc-exch-code IN FRAME dialog-frame
DO:
   run choice-currency in this-procedure no-error.
   if error-status:error then return no-apply.
   run update-rate-doc in this-procedure no-error.
END.
ON CHOOSE OF r-currency IN FRAME dialog-frame
DO:
run r-proc-currency in this-procedure no-error.
if error-status:error then return no-apply.
END.
ON CHOOSE OF r-acc IN FRAME dialog-frame
DO:
 run r-acc-proc in this-procedure .
END.
ON LEAVE OF loc-base-rate  IN FRAME dialog-frame OR
   LEAVE OF loc-base-scale IN FRAME dialog-frame DO:
   run check-rate in this-procedure no-error.
   if error-status:error then return no-apply.
   run UI-on in this-procedure .
END.
ON CURSOR-DOWN OF loc-hour IN FRAME Dialog-Frame
DO:
  assign  frame dialog-frame loc-hour .
  loc-hour = loc-hour -  1.
  if loc-hour < 0 then return no-apply.
  display loc-hour with frame dialog-frame.
END.
ON CURSOR-UP OF loc-hour IN FRAME Dialog-Frame
DO:
  assign  frame dialog-frame loc-hour .
  loc-hour = loc-hour +  1.
  if loc-hour > 24 then return no-apply.
  display loc-hour with frame dialog-frame.
END.
ON LEAVE OF loc-hour IN FRAME Dialog-Frame
DO:
  assign frame dialog-frame loc-hour .
   if loc-hour > 24 then do:
   message "Часы должны быть   до 24 ! " .
   return no-apply.
   end.
    if loc-hour < 0 then do:
   message "Часы должны быть  от 0 до 24 ! " .
   return no-apply.
   end.
END.
ON CURSOR-DOWN OF loc-min IN FRAME Dialog-Frame
DO:
  assign  frame dialog-frame loc-min .
  loc-min = loc-min -  1.
  if loc-min < 0 then return no-apply.
  display loc-min with frame dialog-frame.
END.
ON CURSOR-UP OF loc-min IN FRAME Dialog-Frame
DO:
   assign  frame dialog-frame loc-min .
  loc-min = loc-min +  1.
  if loc-min > 59 then return no-apply.
  display loc-min with frame dialog-frame.
END.
ON LEAVE OF loc-min IN FRAME Dialog-Frame
DO:
 run leave-loc-min in this-procedure   no-error .
     if error-status :error then return no-apply.
END.
procedure vg-TOG-type :
  Assign frame  dialog-frame
  tog-type .
   If tog-type = 1  then Do:
      view    t          in   frame dialog-frame
              cycle-day  in   frame dialog-frame .
      display t cycle-day  with frame dialog-frame .
      Enable  t cycle-day  with frame dialog-frame .
      display t cycle-day  with frame dialog-frame .
   End.
   Else DO: Hide  t  cycle-day  in frame dialog-frame. End.
end procedure.
procedure leave-loc-min:
   assign frame dialog-frame loc-min .
   if loc-min > 59 then do:
      message "Минуты должны быть  от 0 до 59 ! " .
      return error.
      end.
end procedure.
procedure leave-loc-time-ship :
  Assign frame dialog-frame loc-time-ship .
    if integer(entry(1,loc-time-ship,":")) > 24 then
      DO:
          Message "Неправильно задано время !" view-as alert-box error .
          apply "entry" to loc-time-ship  in frame dialog-frame.
      End.
    if integer(entry(2,loc-time-ship,":")) > 60 then
      DO:
          Message "Неправильно задано время !" view-as alert-box error .
          apply "entry" to loc-time-ship  in frame dialog-frame.
      End.
end procedure.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure last-price :
do on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define input parameter  p-host-code     as integer no-undo .
define input parameter  p-artic         like ub.doc-line.artic  no-undo .
define input parameter  p-prod-type     like ub.doc-line.prod-type  no-undo .
define input parameter  p-prod-code     like ub.doc-line.prod-code  no-undo .
define input parameter  p-cli-code      like ub.ord-doc.cli-code  no-undo .
define input parameter  p-cli-type      like ub.ord-doc.cli-type  no-undo .
define input parameter  p-cli-base-rate like ub.ord-line.cli-base-rate no-undo .
define input parameter  p-curr-code  as integer   no-undo .
define output parameter p-price-base like ub.doc-line.price-base no-undo .
define output parameter p-price-rubl like ub.doc-line.price-rubl no-undo .
define output parameter p-price-cli  like ub.doc-line.price-cli  no-undo .
define buffer buf-lib-doc-line for ub.doc-line.
define buffer buf_cli-gds for ub.cli-gds .
define buffer buf_trn-doc for ub.trn-doc  .
define variable vp-curr-code  like ub.trn-doc.exch-code.
define variable vp-exch-rate  like ub.trn-doc.exch-rate.
define variable vp-exch-scale like ub.trn-doc.exch-scale.
define variable v-last-in-code   like ub.doc-line.doc-code  no-undo .
define variable v-last-obj-type  like ub.clients.obj-type no-undo .
define variable v-last-obj-code  like ub.clients.obj-code no-undo .
define variable v-cli-base-rate as decimal   no-undo .
 find first buf_cli-gds no-lock where
            buf_cli-gds.cli-type   = p-cli-type    and
            buf_cli-gds.cli-code   = p-cli-code    and
            buf_cli-gds.host-code  = p-host-code   and
            buf_cli-gds.artic      = p-artic       and
            buf_cli-gds.prod-type  = p-prod-type   and
            buf_cli-gds.prod-code  = p-prod-code
            no-error .
if available buf_cli-gds then do:
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code  = buf_cli-gds.in-code no-error .
     if available buf_trn-doc then do:
        vp-curr-code  = buf_trn-doc.exch-code.
        vp-exch-rate  = buf_trn-doc.exch-rate.
        vp-exch-scale = buf_trn-doc.exch-scale.
     end.
    find first buf-lib-doc-line no-lock
      where buf-lib-doc-line.doc-code  = buf_cli-gds.in-code
        and buf-lib-doc-line.artic     = p-artic
        and buf-lib-doc-line.prod-type = p-prod-type
        and buf-lib-doc-line.prod-code = p-prod-code
      no-error .
end.
else do:
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lastindc in g#library
  (input  p-host-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-last-in-code
  ,output v-last-obj-type
  ,output v-last-obj-code
  )  .
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code  = v-last-in-code no-error .
     if available buf_trn-doc then do:
        vp-curr-code  = buf_trn-doc.exch-code.
        vp-exch-rate  = buf_trn-doc.exch-rate.
        vp-exch-scale = buf_trn-doc.exch-scale.
     end.
    find first buf-lib-doc-line no-lock
      where buf-lib-doc-line.doc-code  = v-last-in-code
        and buf-lib-doc-line.artic     = p-artic
        and buf-lib-doc-line.prod-type = p-prod-type
        and buf-lib-doc-line.prod-code = p-prod-code
      no-error .
end.
    if available buf-lib-doc-line then do:
      assign
        v-cli-base-rate = buf-lib-doc-line.cli-base-rate
        p-price-base = buf-lib-doc-line.price-base
        p-price-rubl = buf-lib-doc-line.price-rubl
        p-price-cli  = (if vp-curr-code = 0 then buf-lib-doc-line.price-rubl else buf-lib-doc-line.price-base) * p-cli-base-rate
      .
      if v-cli-base-rate <> p-cli-base-rate
      then do:
          p-price-cli  = p-price-cli / v-cli-base-rate  .
      end.
       if p-curr-code <> vp-curr-code then do:
          p-price-cli  = p-price-rubl  .
      end.
    end.
    Else do:
      assign
        p-price-base = 0
        p-price-rubl = 0
        p-price-cli  = 0
      .
    end.
  end.
end procedure.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame dialog-frame anywhere do:
  run init-gds-rec.
  if gds-rec = ? then
    return no-apply.
  run ref/gds-form.w ( input parParentProc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to br-docs in frame dialog-frame.
  return no-apply.
end.
ON CHOOSE OF b-protocol IN FRAME Dialog-Frame
DO:
define variable vss-include-info52 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run show-protocol in this-procedure .
END.
ON CHOOSE OF b-contract IN FRAME Dialog-Frame
DO:
define variable vss-include-info53 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run show-contract-code in this-procedure .
END.
ON CHOOSE OF B-delivery IN FRAME Dialog-Frame
DO:
  run cus/pardeliv.w
      (input        parParentproc
      ,input        if t-action = "lkp" then 'ПРОСМОТР':U else t-action
      ,input        "ord" + g#type
      ,input        loc-store-type
      ,input        loc-store-code
      ,input        loc-cli-type
      ,input        loc-cli-code
      ,input-output v-deliv-type-code
      ,input-output v-point-obj-code
      ,input-output v-point-obj-db-num
      ,input-output v-point-cli-code
      ,input-output v-point-cli-db-num
      ,input-output v-transport-host-code
      ,input-output v-transport-cli-type
      ,input-output v-transport-cli-code
      ,input-output v-transport-contract
      ,input-output v-transport-condition
      ,input-output v-transport-value
      ,input-output v-transport-sum
      ,input-output v-transport-vat
         ) no-error  .
         if error-status :error then message
           vss-workfile vss-revision vss-description skip
           error-status :get-message(1) skip
           return-value skip
           "Ошибка"
           view-as alert-box error
         .
END.
on choose of b-gds-prt in frame dialog-frame
do:
run proc-gds-prt.
end.
on choose of b-renum in frame dialog-frame
do:
run proc-renum.
end.
on choose of b-mark in frame dialog-frame
do:
run proc-b-mark .
end.
on choose of b-alt-post in frame dialog-frame
do:
  run pp-1.
 end.
on choose of b-del in frame dialog-frame
do:
   find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
   if available shar_ord-doc
   and (( is-edoc-nn and ( shar_ord-doc.ord-int1 = integer('3':U)   or shar_ord-doc.ord-int1 = integer('4':U)))
    or  ( is-edi     and ( shar_ord-doc.ord-int1 = integer('3':U) or shar_ord-doc.ord-int1 = integer('5':U))))
    then do:
       message "Заказ по системе EDOC/EDI не должен корректироватся в этом статусе. Только НОВЫЙ желтый! " view-as alert-box information .
       return .
    end.
    if choice = ? then do:
      run gbl/pop-up.p (self:handle, no) no-error.
      if error-status:error then return no-apply.
   end.
end.
on choose of b-chg in frame dialog-frame
or mouse-select-dblclick of br-docs in frame dialog-frame
do:
 run proc_ch_b-chg.
end.
on choose of b-add in frame dialog-frame
do:
   find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
   if available shar_ord-doc
   and (( is-edoc-nn and ( shar_ord-doc.ord-int1 = integer('3':U) or shar_ord-doc.ord-int1 = integer('4':U)))
    or  ( is-edi     and   shar_ord-doc.ord-int1 = integer('3':U)))
    then do:
       message "Заказ по системе EDOC/EDI не должен корректироватся в этом статусе. Только НОВЫЙ желтый! " view-as alert-box information .
       return .
    end.
   line-mode = 'ДОБАВЛЕНИЕ':U.
   assign frame dialog-frame loc-date-ship date-sale-1 date-sale-2 loc-service doc-date .
   run choose-menu-add2 in this-procedure.
end.
on choose of b-spec in frame dialog-frame
do:
end.
on choose of b-way in frame dialog-frame
do:
   if choice = ? then do:
        run gbl/pop-up.p (self:handle, no) no-error.
        if error-status:error then return no-apply.
    end.
end.
on choose of b-producer in frame dialog-frame
do:
run pp-2.
return no-apply.
end.
on choose of b-sch in frame dialog-frame
do:
   assign
        tbl = 'cli-gds,goods'
        join-tbl = 'tmp#zakaz,tmp#zakaz'
        fld = 'artic,cli-art,unit-cli,deadline,gds-name'
        lab = ',,,Срок хранения,название'
        spr = ',,unit,,'
        dim = '3,2'.
    do on stop undo, leave:
        run gbl/filter.w (input parparentproc,
        filter-point + chr(4) + filter-label + chr(4) + "yes",
        tbl, join-tbl, fld, lab, spr, dim).
        run openbr in this-procedure.
    end .
end.
on choose of menu-item m_export_excel
do:
  assign frame dialog-frame loc-date-ship date-sale-1 date-sale-2 loc-service .
  run b-export-ch  in this-procedure .
end.
on choose of menu-item m_export_text
do:
   run proc_chg_m_export_text.
end.
on choose of menu-item m_export_ras
do:
run proc_export_ras.
end.
on choose of menu-item m_import_excel
do:
  run b-import-excel in this-procedure.
end.
on choose of menu-item m_import_text
do:
run proc_import_text in this-procedure .
end.
on choose of menu-item m_del3
do:
run del-3 in this-procedure .
end.
on choose of menu-item m_del2
do:
  run del-2 in this-procedure .
end.
on choose of menu-item m_spec1
do:
  run spec1 in this-procedure .
end.
on choose of menu-item m_spec2
do:
  run spec2 in this-procedure .
end.
on choose of menu-item m_del4
do:
run proc-del4 in this-procedure no-error .
 if error-status :error then return no-apply.
end.
on choose of menu-item m_del1
do:
   run proc-menu-item-m_del1.
end.
on choose of b-notes in frame dialog-frame
do:
 run proc-d-notes in this-procedure .
end.
ON CHOOSE OF b-uf IN FRAME dialog-frame
DO:
  run gbl/vi-coll.w ( input Parparentproc, input this-procedure , input 'cli-zakz-p':U + g#type , input  head-col ) .
END.
on choose of b-remove in frame dialog-frame
do:
run proc-b-remove.
end.
on choose of b-itogs in frame dialog-frame
do:
 run p-b-itogs in this-procedure no-error .
end.
on choose of b-main-calc in frame dialog-frame
do:
 assign frame  dialog-frame cycle-day loc-date-ship loc-service date-sale-1 date-sale-2 loc-cli-out-doc doc-date .
 run ver-date  in this-procedure .
 if return-value <> "" then return.
 if LOC-DATE-SHIP < to-day then do:
      message "Дата доставки меньше текущей !!! "
      view-as alert-box information .
      return  .
  end.
   find first tmp#zakaz no-error  .
     if avail tmp#zakaz then do:
     if e-method <> "" then do:
       message  "Заказ уже был рассчитан ! Вы хотите повторно пересчитать заказ ? "
       view-as alert-box question buttons ok-cancel update g#log.
           if not g#log then return no-apply.
     end.
     run cus/ord-m.w ( input PARPARENTPROC , input ? , input g#type ) .
     run openbr in this-procedure .
     enable  e-method with frame dialog-frame .
     display e-method with frame dialog-frame .
     end.
end.
on end-error, stop of frame dialog-frame  do:
  apply "choose" to b-exit in frame dialog-frame .
  return no-apply.
end.
on choose of b-exit in frame dialog-frame
do:
  t-ret =  session:set-wait-state("general") .
  run proc-b-exit no-error .
  if error-status :error then do:
     t-ret =  session:set-wait-state("") .
     if return-value = "no-calc"  then do:
        message "Заказ не был рассчитан !!! Вернитесь в режим расчета." view-as alert-box information .
        apply "choose" to b-main-calc in frame dialog-frame .
        return no-apply .
     end.
     else do:
       return no-apply .
     end.
  end.
  else do:
      t-ret =  session:set-wait-state("") .
      apply "window-close" to self.
      return .
  end.
end.
on value-changed of t-auto in frame dialog-frame
do:
  assign t-auto.
  if t-auto then apply "choose":u to b-main-calc .
end.
on choose of menu-item m_way1
do:
  run choose-menu-way1 in this-procedure.
end.
on choose of menu-item m_way2
do:
  run choose-menu-way2 in this-procedure.
end.
on choose of menu-item m_way3
do:
  run choose-menu-way3 in this-procedure.
end.
on choose of menu-item m_way4
do:
  run choose-menu-way4 in this-procedure.
end.
on window-close of frame dialog-frame
do:
  apply "end-error":u to self.
  return .
end.
on row-leave of br-docs in frame dialog-frame
do:
   run row-leave-br-doc.
end.
ON ROW-DISPLAY OF BR-DOCS  in frame dialog-frame
DO:
   run  row-display-br-doc.
end.
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref54 as character no-undo .
define variable varpgscales-pref54 as character no-undo.
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref-type55 as character no-undo.
varscales-pref54  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref54
  ,output varscales-pref-type55
  ) no-error .
if varscales-pref54 = ? then do:
  assign
  varscales-pref54 = '21,23,25':U.
end.
define variable varpgscales-pref-type55 as character no-undo.
varpgscales-pref54  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref54
  ,output varpgscales-pref-type55
  ) no-error .
if varpgscales-pref54 = ? then do:
  assign
  varpgscales-pref54 = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
on value-changed of a-n-c in frame dialog-frame do:
  run proc-valchg-a-n-c in this-procedure  no-error.
  return no-apply.
end.
on any-printable of br-docs in frame dialog-frame do:
  run proc-any-printable-br-docs in this-procedure   no-error.
  return no-apply.
end.
on backspace of br-docs in frame dialog-frame do:
  run proc-backspace-br-docs in this-procedure   no-error.
  return no-apply.
end.
ON return OF loc-code IN FRAME dialog-frame do:
  run proc-mouse-dbl-click-loc-code in this-procedure   no-error.
  return no-apply.
end.
ON return, Ctrl-J OF loc-name IN FRAME dialog-frame do:
  run proc-mouse-dbl-click-loc-name in this-procedure   no-error.
  return no-apply.
end.
PROCEDURE proc-valchg-a-n-c:
  case input frame dialog-frame a-n-c :
    when "art" then do:
      apply "entry" to br-docs in frame dialog-frame.
      hide loc-name loc-code
      in frame dialog-frame.
      loc-art = "".
    end.
    when "name" then do:
      enable loc-name with frame dialog-frame.
      disp loc-name with frame dialog-frame.
      hide loc-art loc-code
      in frame dialog-frame.
      apply "entry" to loc-name in frame dialog-frame.
    end.
    when "code"
 or when "DataMatrix" then
    do:
      enable loc-code with frame dialog-frame.
      disp loc-code with frame dialog-frame.
      hide loc-art loc-name
      in frame dialog-frame.
      apply "entry" to loc-code in frame dialog-frame.
    end.
  end CASE.
END PROCEDURE.
PROCEDURE proc-any-printable-br-docs :
  if input frame dialog-frame a-n-c = "art" then do:
    if last-event:label = " " and
       loc-art = "" then
    return error.
    find first l-shar_ord-line where
               l-shar_ord-line.doc-code = loc-ord-num and l-shar_ord-line.artic begins (loc-art + last-event:label)
               no-lock no-error.
    if available l-shar_ord-line then do:
      loc-art = loc-art + last-event:label.
      disp loc-art with frame dialog-frame.
      line-rec = recid (l-shar_ord-line).
      reposition br-docs to recid line-rec no-error.
    end.
  end.
END PROCEDURE.
PROCEDURE proc-backspace-br-docs:
  if input frame dialog-frame a-n-c = "art" then do:
    if loc-art = "" then
      return error.
    loc-art = substr (loc-art, 1, length (loc-art) - 1).
    find first l-shar_ord-line where
               l-shar_ord-line.doc-code = loc-ord-num and l-shar_ord-line.artic begins loc-art
               no-lock.
    disp loc-art with frame dialog-frame.
    line-rec = recid (l-shar_ord-line).
    reposition br-docs to recid line-rec no-error.
  end.
END PROCEDURE.
PROCEDURE proc-mouse-dbl-click-loc-code:
def var str-code as integer no-undo.
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
define buffer l-goods for ub.goods.
define buffer l-bar-code for ub.bar-code.
define buffer buf_bar-code for ub.bar-code .
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_place for ub.place.
  assign
  frame dialog-frame
  loc-code
  a-n-c.
  if a-n-c = "datamatrix"
  then do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_dm-rcnz in g#libbcrcn
(
 input  parparentproc
,input  loc-code
,input  ?
,input  store-type
,input  store-code
,input  yes
,input  no
,input  varscales-pref54
,input  varpgscales-pref54
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
     if varresult eq "prod-bc"
     then
        loc-code:screen-value in frame dialog-frame = buf_prod-bc.b-str.
  end.
  else do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  loc-code
,input  ?
,input  store-type
,input  store-code
,input  yes
,input  no
,input  varscales-pref54
,input  varpgscales-pref54
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
end.
  if available buf_bar-code then do:
        find first l-goods where
                  l-goods.gds-code =
  buf_bar-code.gds-code No-LOCK.
        find first l-shar_ord-line where l-shar_ord-line.doc-code = loc-ord-num and
                  l-shar_ord-line.artic = l-goods.artic AND
                  l-shar_ord-line.prod-type = l-goods.prod-type AND
                  l-shar_ord-line.prod-code = l-goods.prod-code no-lock no-error.
    if available l-shar_ord-line then do:
      line-rec = recid (l-shar_ord-line).
      reposition br-docs to recid line-rec no-error.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
    end.
  end.
  else
    message "Бар-код не найден."
            view-as alert-box error.
  apply "entry" to loc-code in frame dialog-frame.
END PROCEDURE.
PROCEDURE  proc-mouse-dbl-click-loc-name:
  assign
  frame dialog-frame
  loc-name.
    if last-event:label = "Ctrl-J" then
      find next l-shar_ord-line where l-shar_ord-line.doc-code = loc-ord-num and
                can-find (ub.goods where ub.goods.artic = l-shar_ord-line.artic and
                ub.goods.prod-type = l-shar_ord-line.prod-type and
                ub.goods.prod-code = l-shar_ord-line.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    else
      find first l-shar_ord-line where l-shar_ord-line.doc-code = loc-ord-num and
                can-find (ub.goods where ub.goods.artic = l-shar_ord-line.artic and
                ub.goods.prod-type = l-shar_ord-line.prod-type and
                ub.goods.prod-code = l-shar_ord-line.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    if available l-shar_ord-line then do:
      line-rec = recid (l-shar_ord-line).
      reposition br-docs to recid line-rec no-error.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
    end.
  apply "entry" to loc-name in frame dialog-frame.
END PROCEDURE.
on value-changed of br-docs in frame dialog-frame do:
if not available shar_ord-line or recid (shar_ord-line) <> line-rec then do:
    hide loc-art in frame dialog-frame.
    loc-art = "".
end.
end.
on value-changed of br-docs in frame dialog-frame
do:
   run select-good-scala .
end.
ON LEAVE OF date-sale-2 IN FRAME dialog-frame
DO:
 assign frame dialog-frame loc-date-ship
                            date-sale-1
                            date-sale-2
                            doc-date
                            no-error .
  if error-status :error then
  message
    error-status :get-message(1) skip
    return-value skip
    "Не вверно введена дата"
    view-as alert-box error
  .
END.
ON LEAVE OF loc-contract IN FRAME dialog-frame
DO:
  assign
    loc-contract
  .
  run from-contract in this-procedure .
END.
ON  RETURN OF r-contract IN FRAME Dialog-Frame
DO:
    run apply-focus-next-entry in this-procedure  (input  r-contract:handle ) .
    return no-apply .
END.
ON  RETURN OF loc-cli-type IN FRAME Dialog-Frame
DO:
    run apply-focus-next-entry in this-procedure  (input  loc-cli-type:handle ) .
    return no-apply .
END.
ON MOUSE-SELECT-DBLCLICK, return, Ctrl-J OF loc-name IN FRAME dialog-frame do:
  run my-proc-mouse-dbl-click-loc-name in this-procedure   no-error.
  return no-apply.
end.
if valid-handle(active-window) and frame dialog-frame:parent eq ?
then frame dialog-frame:parent = active-window.
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame dialog-frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame dialog-frame
do:
  apply "help":u to frame dialog-frame .
end.
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame dialog-frame:width - 0.3
                fh            = frame dialog-frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame dialog-frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame dialog-frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame dialog-frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame dialog-frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame dialog-frame :height = v-frame-height
          .
          if frame dialog-frame :scrollable = true
          then do:
            assign
              frame dialog-frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame dialog-frame :scrollable = true
          then do:
            assign
              frame dialog-frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame dialog-frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame dialog-frame :height
      v-frame-virtual-height = frame dialog-frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame dialog-frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame dialog-frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame dialog-frame :scrollable = true
      then do:
        assign
          frame dialog-frame :virtual-height = frame dialog-frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame dialog-frame :height = frame dialog-frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame dialog-frame :height = frame dialog-frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame dialog-frame :scrollable = true
      then do:
        assign
          frame dialog-frame :virtual-height = frame dialog-frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame dialog-frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame dialog-frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame dialog-frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame dialog-frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame dialog-frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame dialog-frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame dialog-frame :width = v-frame-width
          .
          if frame dialog-frame :scrollable = true
          then do:
            assign
              frame dialog-frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame dialog-frame :scrollable = true
          then do:
            assign
              frame dialog-frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame dialog-frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame dialog-frame :width
      v-frame-virtual-width = frame dialog-frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame dialog-frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame dialog-frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame dialog-frame :scrollable = true
      then do:
        assign
          frame dialog-frame :virtual-width = frame dialog-frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame dialog-frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame dialog-frame :width = frame dialog-frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame dialog-frame :scrollable = true
      then do:
        assign
          frame dialog-frame :virtual-width = frame dialog-frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame dialog-frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame dialog-frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame dialog-frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame dialog-frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame dialog-frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame dialog-frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame dialog-frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame dialog-frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame dialog-frame :height
      v-col-delta = v-new-col - frame dialog-frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame dialog-frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame dialog-frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame dialog-frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame dialog-frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame dialog-frame :width
      v-diasize-current-frame-height = frame dialog-frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame dialog-frame
    :
      assign
        v-diasize-orig-frame-height = frame dialog-frame :height
        v-diasize-orig-frame-width  = frame dialog-frame :width
        v-diasize-browse-handle     = browse br-docs :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame dialog-frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame dialog-frame anywhere
do:
  open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code by tmp#zakaz.line-num .
    apply "VALUE-CHANGED" to br-docs.
end.
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of loc-date-ship in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of loc-date-ship in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of loc-date-ship in frame dialog-frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of loc-date-ship in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of loc-date-ship in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of loc-date-ship in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date61
    MENU-ITEM m-ed-date61-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date61-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date61-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date61-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if loc-date-ship :POPUP-MENU in frame dialog-frame = ?
  then do:
    ASSIGN
      loc-date-ship :POPUP-MENU in frame dialog-frame = MENU m-ed-date61 :HANDLE
      loc-date-ship :MENU-MOUSE in frame dialog-frame = 3
    .
  end.
  define variable v-label-handle61 as handle no-undo .
  assign
    v-label-handle61 = loc-date-ship :side-label-handle in frame dialog-frame
  .
  if valid-handle (v-label-handle61)
  then do:
    if v-label-handle61 :tooltip = ""
    or v-label-handle61 :tooltip = ?
    then do:
      assign
        v-label-handle61 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date61-1 in menu m-ed-date61 DO:
    apply "ctrl-b":U to loc-date-ship in frame dialog-frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date61-2 in menu m-ed-date61 DO:
    apply "ctrl-d":U to loc-date-ship in frame dialog-frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date61-3 in menu m-ed-date61 DO:
    apply "ctrl-e":U to loc-date-ship in frame dialog-frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date61-4 in menu m-ed-date61 DO:
    apply "ctrl-f":U to loc-date-ship in frame dialog-frame .
  END.
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of date-sale-1 in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of date-sale-1 in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of date-sale-1 in frame dialog-frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of date-sale-1 in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of date-sale-1 in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of date-sale-1 in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date63
    MENU-ITEM m-ed-date63-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date63-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date63-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date63-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if date-sale-1 :POPUP-MENU in frame dialog-frame = ?
  then do:
    ASSIGN
      date-sale-1 :POPUP-MENU in frame dialog-frame = MENU m-ed-date63 :HANDLE
      date-sale-1 :MENU-MOUSE in frame dialog-frame = 3
    .
  end.
  define variable v-label-handle63 as handle no-undo .
  assign
    v-label-handle63 = date-sale-1 :side-label-handle in frame dialog-frame
  .
  if valid-handle (v-label-handle63)
  then do:
    if v-label-handle63 :tooltip = ""
    or v-label-handle63 :tooltip = ?
    then do:
      assign
        v-label-handle63 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date63-1 in menu m-ed-date63 DO:
    apply "ctrl-b":U to date-sale-1 in frame dialog-frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date63-2 in menu m-ed-date63 DO:
    apply "ctrl-d":U to date-sale-1 in frame dialog-frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date63-3 in menu m-ed-date63 DO:
    apply "ctrl-e":U to date-sale-1 in frame dialog-frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date63-4 in menu m-ed-date63 DO:
    apply "ctrl-f":U to date-sale-1 in frame dialog-frame .
  END.
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of date-sale-2 in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of date-sale-2 in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of date-sale-2 in frame dialog-frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of date-sale-2 in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of date-sale-2 in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of date-sale-2 in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date65
    MENU-ITEM m-ed-date65-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date65-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date65-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date65-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if date-sale-2 :POPUP-MENU in frame dialog-frame = ?
  then do:
    ASSIGN
      date-sale-2 :POPUP-MENU in frame dialog-frame = MENU m-ed-date65 :HANDLE
      date-sale-2 :MENU-MOUSE in frame dialog-frame = 3
    .
  end.
  define variable v-label-handle65 as handle no-undo .
  assign
    v-label-handle65 = date-sale-2 :side-label-handle in frame dialog-frame
  .
  if valid-handle (v-label-handle65)
  then do:
    if v-label-handle65 :tooltip = ""
    or v-label-handle65 :tooltip = ?
    then do:
      assign
        v-label-handle65 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date65-1 in menu m-ed-date65 DO:
    apply "ctrl-b":U to date-sale-2 in frame dialog-frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date65-2 in menu m-ed-date65 DO:
    apply "ctrl-d":U to date-sale-2 in frame dialog-frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date65-3 in menu m-ed-date65 DO:
    apply "ctrl-e":U to date-sale-2 in frame dialog-frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date65-4 in menu m-ed-date65 DO:
    apply "ctrl-f":U to date-sale-2 in frame dialog-frame .
  END.
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of doc-date in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of doc-date in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of doc-date in frame dialog-frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of doc-date in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of doc-date in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of doc-date in frame dialog-frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date67
    MENU-ITEM m-ed-date67-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date67-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date67-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date67-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if doc-date :POPUP-MENU in frame dialog-frame = ?
  then do:
    ASSIGN
      doc-date :POPUP-MENU in frame dialog-frame = MENU m-ed-date67 :HANDLE
      doc-date :MENU-MOUSE in frame dialog-frame = 3
    .
  end.
  define variable v-label-handle67 as handle no-undo .
  assign
    v-label-handle67 = doc-date :side-label-handle in frame dialog-frame
  .
  if valid-handle (v-label-handle67)
  then do:
    if v-label-handle67 :tooltip = ""
    or v-label-handle67 :tooltip = ?
    then do:
      assign
        v-label-handle67 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date67-1 in menu m-ed-date67 DO:
    apply "ctrl-b":U to doc-date in frame dialog-frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date67-2 in menu m-ed-date67 DO:
    apply "ctrl-d":U to doc-date in frame dialog-frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date67-3 in menu m-ed-date67 DO:
    apply "ctrl-e":U to doc-date in frame dialog-frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date67-4 in menu m-ed-date67 DO:
    apply "ctrl-f":U to doc-date in frame dialog-frame .
  END.
def var sort-labelbr-docs   as character no-undo .
def var sort-clmnbr-docs    as handle    no-undo .
def var cur-clmnbr-docs     as handle    no-undo .
def var cur-clmn-locbr-docs as integer   no-undo .
def var re-querybr-docs     as logical   initial no no-undo .
on start-search, ctrl-o of br-docs in frame dialog-frame do:
   run sort-brbr-docs
     (input (if available shar_ord-line
             then recid(shar_ord-line)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-docs :
  define input parameter p-recid as recid no-undo .
  if re-querybr-docs = no then do:
    assign
       cur-clmnbr-docs = br-docs:current-column in frame dialog-frame
    .
    if sort-clmnbr-docs <> ? then sort-clmnbr-docs:column-fgcolor = 0.
    if cur-clmnbr-docs = sort-clmnbr-docs then do:
      assign
         sort-labelbr-docs = ""
         sort-clmnbr-docs = ?
      .
     end.
     else do:
       assign
         sort-labelbr-docs = cur-clmnbr-docs:label
         sort-clmnbr-docs  = cur-clmnbr-docs
         sort-clmnbr-docs:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-docs = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-docs:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-docs then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-docs = cur-clmn-locbr-docs + 1
    .
  end.
  case sort-labelbr-docs:
        when 'ш! '  then DO:   assign     sort-column-name = "tmp#zakaz.prt-ok"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.prt-ok .   . END.
        when 'Артикул! '  then DO:   assign     sort-column-name = "tmp#zakaz.artic"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.artic .   . END.
        when 'Название! '  then DO:   assign     sort-column-name = "tmp#zakaz.gds-name"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.gds-name .   . END.
        when 'Е.и.!пост'  then DO:   assign     sort-column-name = "tmp#zakaz.unit-cli"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.unit-cli .   . END.
        when 'Заказ!ед.пост'  then DO:   assign     sort-column-name = "tmp#zakaz.cli-qnty"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.cli-qnty .   . END.
        when 'Последн.цена!пост-ка'  then DO:   assign     sort-column-name = "tmp#zakaz.price-cli"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.price-cli .   . END.
        when 'Сумма!ед.пост'  then DO:   assign     sort-column-name = "tmp#zakaz.sum-cli"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.sum-cli .   . END.
        when 'Артикул!поставщика'  then DO:   assign     sort-column-name = "tmp#zakaz.cli-art"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.cli-art .   . END.
        when 'Е.и.!баз.'  then DO:   assign     sort-column-name = "tmp#zakaz.unit-base"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.unit-base .   . END.
        when 'Заказ! '  then DO:   assign     sort-column-name = "tmp#zakaz.qnty"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.qnty .   . END.
        when 'Цена!(руб)'  then DO:   assign     sort-column-name = "tmp#zakaz.price-rubl"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.price-rubl .   . END.
        when 'Сумма!(руб) '  then DO:   assign     sort-column-name = "tmp#zakaz.sum-rubl"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.sum-rubl .   . END.
        when 'Темп продаж!при расчете'  then DO:   assign     sort-column-name = "tmp#zakaz.temp-rash"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.temp-rash .   . END.
        when 'Объем продаж!за период'  then DO:   assign     sort-column-name = "tmp#zakaz.qnty-sale"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.qnty-sale .   . END.
        when 'Кол-во остатки!при расчете'  then DO:   assign     sort-column-name = "tmp#zakaz.qnty-stk"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.qnty-stk .   . END.
        when 'Минимальный!запас'  then DO:   assign     sort-column-name = "tmp#zakaz.min-stock"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.min-stock .   . END.
        when 'x! '  then DO:   assign     sort-column-name = "(if tmp#zakaz.cancel-date = ? then '' else '*' )"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY (if tmp#zakaz.cancel-date = ? then '' else '*' ) .   . END.
        when '№!п/п'  then DO:   assign     sort-column-name = "tmp#zakaz.line-num"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.line-num .   . END.
        when 'Код!товара'  then DO:   assign     sort-column-name = "tmp#zakaz.gds-code"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.gds-code .   . END.
        when '*! '  then DO:   assign     sort-column-name = "tmp#zakaz.local-mark"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.local-mark .   . END.
        when 'Запрошено!количество'  then DO:   assign     sort-column-name = "tmp#zakaz.order-cli-qnty"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.order-cli-qnty .   . END.
        when 'Запрошена!цена'  then DO:   assign     sort-column-name = "tmp#zakaz.ord-dec1"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.ord-dec1 .   . END.
        when 'Расcчитн.!кол-во'  then DO:   assign     sort-column-name = "tmp#zakaz.initial-qnty"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.initial-qnty .   . END.
        when 'Мин.!остаток'  then DO:   assign     sort-column-name = "tmp#zakaz.min-stock-old"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.min-stock-old .   . END.
        when 'Тов.!в пути'  then DO:   assign     sort-column-name = "tmp#zakaz.gds-way"   .   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.gds-way .   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code by tmp#zakaz.line-num .
      if sort-labelbr-docs <> "" then do:
        assign
          cur-clmnbr-docs:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-docs = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-docs to recid p-recid no-error.
    apply "value-changed" to br-docs in frame dialog-frame.
  end.
  apply "entry" to br-docs in frame dialog-frame.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-docs:
if cur-clmnbr-docs = ? then do:
   open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code by tmp#zakaz.line-num .
end.
else do:
   assign re-querybr-docs = yes.
   run sort-brbr-docs
     (input (if available shar_ord-line
             then recid(shar_ord-line)
             else ?
            )
     ).
   assign re-querybr-docs = no.
end.
end.
main-block:
do on error   undo main-block, leave main-block
   on end-key undo main-block, leave main-block
   on stop    undo main-block, leave main-block :
  run local-conf-rd no-error.
  if error-status:error then return error.
  run make-obj-list no-error .
  if error-status:error then return error.
      tmp#zakaz.artic:RESIZABLE in browse br-docs =  true .
      tmp#zakaz.gds-name:RESIZABLE in browse br-docs =  true .
  if t-action <> "lkp":u then
    assign
      tmp#zakaz.cli-art   :read-only in browse br-docs =   true
      tmp#zakaz.cli-qnty  :read-only in browse br-docs =  false
      tmp#zakaz.price-cli :read-only in browse br-docs =  false
      no-error .
      if error-status :error then error-status :error = false .
 run mode-on in this-procedure .
  t#query-was-opened = true .
   if not (g#type = 'ОП':U or g#type = 'ОФ':U) then do:
      tmp#zakaz.temp-rash:visible in browse br-docs = false .
      tmp#zakaz.qnty-stk:visible  in browse br-docs = false .
   end.
 v-fl = true .
 if t-action = "add":u  then  run enable_ui .
 if t-action <> "lkp":u then  run ui-on     .
 run edoc-edi-proc in this-procedure .
run init-browse-p  in this-procedure .
apply "VALUE-CHANGED" to br-docs in frame dialog-frame.
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-docs as INT EXTENT 25 no-undo.
DEF VAR varmvibr-docs       as INT no-undo.
DEF VAR varmvjbr-docs       as INT no-undo.
DEF VAR varmvkbr-docs       as INT no-undo.
DEF VAR varmvlbr-docs       as INT no-undo.
DEF VAR move-elementbr-docs as INT no-undo.
def var jjbr-docs           as int no-undo.
do varmvibr-docs = 1 to EXTENT(cur-clmn-numbr-docs):
  ASSIGN cur-clmn-numbr-docs[varmvibr-docs] = varmvibr-docs.
END.
RUN start-mv-clmnbr-docs.
PROCEDURE start-mv-clmnbr-docs:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  true = true  THEN DO:
   DO jjbr-docs = NUM-ENTRIES(v-order-column) TO 1 BY -1:
     RUN re-move-clmnbr-docs ( cur-clmn-numbr-docs[INTEGER(ENTRY (jjbr-docs, v-order-column))] , 1).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-docs do:
  RUN re-move-clmnbr-docs ( 1, 25).
END.
ON ctrl-cursor-left OF BROWSE br-docs do:
  RUN re-move-clmnbr-docs (25, 1).
END.
PROCEDURE re-move-clmnbr-docs:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = source-column THEN cur-clmn-numbr-docs[varmvibr-docs] = -1.
  END.
  if br-docs:MOVE-COLUMN(source-column, target-column) IN FRAME dialog-frame then.
  if source-column > target-column THEN
  DO varmvjbr-docs = source-column - 1 to target-column BY -1:
    DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
        if cur-clmn-numbr-docs[varmvibr-docs] = varmvjbr-docs THEN DO:
          cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-numbr-docs[varmvibr-docs] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-docs = source-column + 1 to target-column:
    DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
      if cur-clmn-numbr-docs[varmvibr-docs] = varmvjbr-docs THEN DO:
        cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-numbr-docs[varmvibr-docs] - 1.
      END.
    END.
  END.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = -1 THEN cur-clmn-numbr-docs[varmvibr-docs] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-docs:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-loc THEN move-elementbr-docs = varmvibr-docs.
  END.
  RUN re-move-clmnbr-docs (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-docs:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-docs = 1 to EXTENT(cur-clmn-numbr-docs):
    RUN re-move-clmnbr-docs (cur-clmn-numbr-docs[varmvlbr-docs], varmvlbr-docs).
  END.
  RUN start-mv-clmnbr-docs.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
if tog-type = 4 then disable tog-type with frame dialog-frame .
   else  v-ok = tog-type:disable("О") in frame dialog-frame .
  if t-action = "add":u then do:
      if g#type = 'ОФ':U then do:
         frame dialog-frame:visible = true .
           wait-for go of frame dialog-frame focus  wrkr .
      end.
      else do:
           wait-for go of frame dialog-frame focus loc-cli-code.
      end.
  end.
  else do:
    WAIT-FOR GO OF FRAME dialog-frame focus br-docs .
  end.
end.
run disable_ui  in this-procedure  .
procedure pp-1 :
 do
 on error undo, return error return-value
 :
  find current shar_ord-line  no-lock  no-error .
  if not avail shar_ord-line then return.
  find first tmp#zakaz no-lock    where
              shar_ord-line.prod-type       = tmp#zakaz.prod-type and
              shar_ord-line.prod-code       = tmp#zakaz.prod-code and
              shar_ord-line.artic           = tmp#zakaz.artic        no-error  .
  if not avail tmp#zakaz   then do:
       message error-status :get-message(1) .
       return.
       end.
 run cus/cli-othr.w (
 input tmp#zakaz.artic,
 input tmp#zakaz.prod-type,
 input tmp#zakaz.prod-code,
 input buf-cli.obj-type ,
 input buf-cli.obj-code ).
 end.
end procedure.
procedure pp-2 :
 do
 on error undo, return error return-value
 :
  find current shar_ord-line  no-lock  no-error .
  if not avail shar_ord-line then return.
  find first tmp#zakaz no-lock    where
              shar_ord-line.prod-type       = tmp#zakaz.prod-type and
              shar_ord-line.prod-code       = tmp#zakaz.prod-code and
              shar_ord-line.artic           = tmp#zakaz.artic        no-error  .
  if not avail tmp#zakaz   then do:
       message error-status :get-message(1) .
       return.
       end.
    run ref/showcli.p
    (input parparentproc
    ,input tmp#zakaz.prod-type
    ,input tmp#zakaz.prod-code
    ).
 end.
end procedure.
procedure proc-d-notes :
 do
 on error undo, return error return-value
 :
 find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
   notes = shar_ord-doc.ps.
    run gbl/d-prompt.w (
        'title=примечание\'
      + 'type=editor\'
      + 'fillin_width=96\'
      + 'fillin_height=15\'
      , input-output notes).
      if return-value = 'false':u
      then do:
        return .
      end.
    if shar_ord-doc.ps <> notes then do:
      do on stop undo, return error:
        find shar_ord-doc where recid (shar_ord-doc) = doc-rec exclusive-lock no-error .
        shar_ord-doc.ps = notes.
      end.
    end.
    find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
 end.
end procedure.
procedure proc-del4 :
 do
 on error undo, return error return-value
 :
   find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
   if available shar_ord-doc
   and (( is-edoc-nn and ( shar_ord-doc.ord-int1 = integer('3':U) or shar_ord-doc.ord-int1 = integer('4':U)))
    or  ( is-edi     and   shar_ord-doc.ord-int1 = integer('3':U)))
    then do:
       message "Заказ по системе EDOC/EDI не должен корректироватся в этом статусе. Только НОВЫЙ желтый! " view-as alert-box information .
       return .
    end.
define variable ii as integer init 0 no-undo.
  find current shar_ord-line  no-lock  no-error .
  if not avail shar_ord-line then return.
  find first tmp#zakaz no-lock    where
              shar_ord-line.prod-type       = tmp#zakaz.prod-type and
              shar_ord-line.prod-code       = tmp#zakaz.prod-code and
              shar_ord-line.artic           = tmp#zakaz.artic        no-error  .
  if not avail tmp#zakaz   then do:
       message error-status :get-message(1) .
       return.
       end.
   if not avail tmp#zakaz then do:
   message "Не выбрана строка" view-as alert-box information .
   return error.
   end.
   if avail tmp#zakaz then do:
      message "Удалять товар " + tmp#zakaz.artic + ' ' +   tmp#zakaz.gds-name + " из заказа ? " skip "Продолжать?"
           view-as alert-box question buttons ok-cancel update g#log.
           if not g#log then return no-apply.
            do transaction :
                find first shar_ord-line  exclusive-lock   where
                    shar_ord-line.doc-code        = loc-ord-num    and
                    shar_ord-line.prod-type       = tmp#zakaz.prod-type and
                    shar_ord-line.prod-code       = tmp#zakaz.prod-code and
                    shar_ord-line.artic           = tmp#zakaz.artic        no-error  .
                delete  shar_ord-line  no-error.
                for each tmp#zakaz-dtl where
                    tmp#zakaz-dtl.doc-code        = loc-ord-num    and
                    tmp#zakaz-dtl.prod-type       = tmp#zakaz.prod-type and
                    tmp#zakaz-dtl.prod-code       = tmp#zakaz.prod-code and
                    tmp#zakaz-dtl.artic           = tmp#zakaz.artic   :
                    delete tmp#zakaz-dtl .
                end.
                delete  tmp#zakaz     no-error.
            end.
      run openbr  in this-procedure  .
      end.
 end.
end procedure.
procedure proc-menu-item-m_del1 :
 do
 on error undo, return error return-value
 :
find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
if available shar_ord-doc
and (( is-edoc-nn and ( shar_ord-doc.ord-int1 = integer('3':U) or shar_ord-doc.ord-int1 = integer('4':U)))
 or  ( is-edi     and   shar_ord-doc.ord-int1 = integer('3':U)))
then do:
    message "Заказ по системе EDOC/EDI не должен корректироватся в этом статусе. Только НОВЫЙ желтый! " view-as alert-box information .
    return .
end.
define variable ii as integer init 0 no-undo.
   t-ret =  session:set-wait-state("general") .
   for each    tmp#zakaz  where
               tmp#zakaz.qnty = 0  or
               tmp#zakaz.qnty = ? :
       ii = ii + 1.
            do transaction :
                find first shar_ord-line  exclusive-lock   where
                    shar_ord-line.doc-code        = loc-ord-num    and
                    shar_ord-line.prod-type       = tmp#zakaz.prod-type and
                    shar_ord-line.prod-code       = tmp#zakaz.prod-code and
                    shar_ord-line.artic           = tmp#zakaz.artic        no-error  .
                delete  shar_ord-line  no-error.
                for each tmp#zakaz-dtl where
                    tmp#zakaz-dtl.doc-code        = loc-ord-num    and
                    tmp#zakaz-dtl.prod-type       = tmp#zakaz.prod-type and
                    tmp#zakaz-dtl.prod-code       = tmp#zakaz.prod-code and
                    tmp#zakaz-dtl.artic           = tmp#zakaz.artic   :
                    delete tmp#zakaz-dtl .
                end.
                delete  tmp#zakaz     no-error.
            end.
   end.
   t-ret =  session:set-wait-state("") .
   choice = ?.
   run openbr  in this-procedure  .
   message "Удалено " + string(ii) + " товаров".
 end.
end procedure.
procedure proc-b-remove :
 do
 on error undo, return error return-value
 :
define variable tt-rec as recid no-undo .
  find current shar_ord-line  exclusive-lock  no-error .
  if not avail shar_ord-line then return.
  find first tmp#zakaz no-lock    where
              shar_ord-line.prod-type       = tmp#zakaz.prod-type and
              shar_ord-line.prod-code       = tmp#zakaz.prod-code and
              shar_ord-line.artic           = tmp#zakaz.artic        no-error  .
   if not avail tmp#zakaz   then do:
       message error-status :get-message(1) .
       return.
       end.
 tt-rec = recid (shar_ord-line) .
 if tmp#zakaz.cancel-date = ? then do :
  message "Товар " + tmp#zakaz.artic + ' ' +
   tmp#zakaz.gds-name
   + " больше не будет заказываться у Поставщика " + loc-obj-name + " ! " skip "  Вы уверены ?"
           view-as alert-box question buttons ok-cancel update g#log.
           if not g#log then return no-apply.
    tmp#zakaz.cancel-date = to-day.
    end.
  else do:
    message "Снять отметку с товара " + tmp#zakaz.artic + ' ' +
    tmp#zakaz.gds-name
    + " ? " skip "  Вы уверены ?"
           view-as alert-box question buttons ok-cancel update g#log.
           if not g#log then return no-apply.
    tmp#zakaz.cancel-date = ? .
  end.
 shar_ord-line.cancel-date = tmp#zakaz.cancel-date .
 find current shar_ord-line  no-lock  no-error .
  run openbr  in this-procedure  .
  reposition br-docs to recid tt-rec no-error.
 end.
end procedure.
procedure proc-b-exit :
 do
 on error undo, return error return-value
 :
define variable t-sum like tmp#zakaz.qnty no-undo .
define variable ord-qnty    as decimal    no-undo .
define variable ord-sum-cli as decimal    no-undo .
define variable k           as integer    no-undo .
define variable p-nabor     as logical    no-undo .
define variable v-list-new  as character  no-undo .
define buffer buf_contract for ub.contract.
next-prev = ?.
assign frame dialog-frame tog-type cycle-day doc-date
.
if tog-type = 1 and cycle-day  = 0 then do:
   message "Внимание ! Задайте количество дней для цикличного заказа !" view-as alert-box .
   return error.
end.
run leave-loc-cli-code in this-procedure no-error .
if error-status :error then do:
    message "Документ будет удален"   view-as alert-box information .
    find first shar_ord-doc  exclusive-lock where shar_ord-doc.doc-code = loc-ord-num  no-error  .
    if available shar_ord-doc then  delete shar_ord-doc.
    return .
end.
if ( loc-cli-type = 'маг':U or loc-cli-type = 'скл':U ) and t-action <> "lkp":u then do:
    message "Неправильно задан КОНТРАГЕНТ !" loc-cli-type view-as alert-box.
    return error.
end.
run ver-clients  in this-procedure ( input loc-cli-type , input loc-cli-code , output v-err) .
if  v-err then return error.
define variable varcontract       as character no-undo .
define variable varcontract-type  as character no-undo .
if v-mastc = true then varcontract = "yes"  .
if v-mastc = true and loc-contract = 0 and
  ( g#type = 'ОП':U or g#type = 'ФП':U )
  then do:
    message "Не задан договор !" view-as alert-box.
    run r-contract-choose no-error .
    if error-status :error then return error.
end.
if loc-contract > 0 and ( g#type = 'ОП':U or g#type = 'ФП':U ) then do:
find first buf_contract no-lock where
           buf_contract.host-code = v-cntxt-host-code-obj and
           buf_contract.contract-code = loc-contract no-error .
    if available buf_contract  then do:
      if loc-exch-code  <> buf_contract.curr-code then do:
        message "Валюта договора не совпадает с валютой заказа !" skip loc-contract view-as alert-box error .
        return error.
      end.
      if loc-cli-code  <> buf_contract.cli-code or
        loc-cli-type  <> buf_contract.cli-type then do:
        message "Плательщик договора не совпадает с Контрагентом заказа !" skip loc-contract view-as alert-box error .
        return error.
      end.
    end.
end.
if loc-contract = 0 and ( g#type = 'ОП':U or g#type = 'ФП':U ) and tog-type = 4 then do:
define buffer buff_ord-doc-attr for ub.ord-doc-attr  .
define variable ev-exch-rate  as decimal   no-undo .
define variable ev-exch-scale as decimal   no-undo .
define variable ev-curr-abbr  as character no-undo .
  for each buff_ord-doc-attr no-lock where
           buff_ord-doc-attr.doc-code   begins  string( loc-ord-num + chr(4) ) and
           buff_ord-doc-attr.attr-code = 'exch-code':U :
        if integer(buff_ord-doc-attr.attr-value) <> loc-exch-code then do:
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  integer(buff_ord-doc-attr.attr-value)
  ,input  today
  ,output ev-exch-rate
  ,output ev-exch-scale
  ,output ev-curr-abbr
  ) no-error .
        message substitute("Валюта объединенного заказа должна совпадать с валютой заказов, вошедших в состав!&2 Валюта заказов &1.",ev-curr-abbr, chr(10) )
                 view-as alert-box error .
        return error.
         end.
  end.
end.
define variable v-longchar as longchar no-undo .
define variable v-err-ext  as logical   no-undo .
define variable var-ok-assort-pol as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define variable v-event-code as character no-undo .
v-err-ext  = false .
for each tmp#zakaz break by tmp#zakaz.cli-art :
  if loc-contract > 0 and  g#type  =  'ОП':U  then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_ckcntspc in g#lib-trn3
( input v-cntxt-host-code-obj
 ,input loc-contract
 ,input tmp#zakaz.gds-code
 ,input tmp#zakaz.price-cli
 ,input VAT_type
 ,input tmp#zakaz.VAT-pc
) no-error .
      if error-status :error then do:
        assign
          v-err-ext = true
          v-longchar = v-longchar + trim(return-value) + trim(error-status :get-message(1)) + chr(10)
        .
      end.
  end.
    if loc-doc-type <> 'ПО':U  and
       loc-doc-type <> 'ФП':U  then do:
       var-ok-assort-pol = true .
       v-event-code = loc-doc-type + "-" .
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  v-event-code
  ,input  tmp#zakaz.gds-code
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  false
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  ) .
           if var-ok-assort-pol = false then do:
              v-err-ext  = true  .
              v-longchar = v-longchar + var-mess-assort-pol + chr(10) .
           end.
    end.
    if  loc-cli-type = 'маг':U or
           loc-cli-type = 'скл':U then do:
            var-ok-assort-pol = true .
            v-event-code = "cli_" + loc-doc-type + "-" .
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  v-event-code
  ,input  tmp#zakaz.gds-code
  ,input  loc-cli-type
  ,input  loc-cli-code
  ,input  false
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  ) .
           if var-ok-assort-pol = false then do:
              v-err-ext  = true  .
              v-longchar = v-longchar + var-mess-assort-pol  + chr(10) .
           end.
       end.
    if loc-doc-type = 'ПО':U  then do:
        var-ok-assort-pol = true .
        v-event-code = loc-doc-type + "-" .
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassmat in g#library2
  (input  tmp#zakaz.gds-code
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  false
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  )  .
        if var-ok-assort-pol = false then do:
          v-err-ext  = true  .
          v-longchar = v-longchar + var-mess-assort-pol  + chr(10) .
        end.
    end.
   run ver-gds-flor ( input tmp#zakaz.gds-code , output p-nabor ) no-error .
   if p-nabor    = true then do:
      v-err-ext  = true  .
      v-longchar = v-longchar +
      substitute("Артикул &1 &2&3 &4 Является набором (букет) !!! Удалите его из списка товаров !  "  ,tmp#zakaz.artic, tmp#zakaz.prod-type ,tmp#zakaz.prod-code, tmp#zakaz.gds-name ,chr(10)) .
   end.
  t-sum = 0.
  for each tmp#zakaz-dtl where
      tmp#zakaz-dtl.artic     = tmp#zakaz.artic and
      tmp#zakaz-dtl.prod-type = tmp#zakaz.prod-type and
      tmp#zakaz-dtl.prod-code = tmp#zakaz.prod-code  :
      t-sum = t-sum + tmp#zakaz-dtl.qnty.
   end.
   if t-sum > tmp#zakaz.qnty then do:
      v-err-ext  = true  .
      v-longchar = v-longchar +
      substitute ("Количество по признакам больше чем по строке товара ! &1 &2&3 &4 (количества по признакам=&5 и по строке=&6)&7" ,tmp#zakaz.artic, tmp#zakaz.prod-type ,tmp#zakaz.prod-code, tmp#zakaz.gds-name ,t-sum,  tmp#zakaz.qnty, chr(10)) .
   end.
define buffer bf2_ext-artic for ub.ext-artic  .
define buffer bf2_goods for ub.goods  .
define buffer bf3_goods for ub.goods  .
define buffer bf2_tmp#zakaz for tmp#zakaz  .
    if ( is-edoc-nn-doc = true and shar_ord-doc.ord-int1 = int('0':U) )
    or ( is-edi-doc     = true and shar_ord-doc.ord-int1 = int('0':U)  )
    then do:
      if tmp#zakaz.cli-art = ""
      or tmp#zakaz.cli-art = "0"
      or tmp#zakaz.cli-art = ?
      then do:
          v-err-ext = true .
          v-longchar = v-longchar +
          substitute( "Для данного контрагента, работающего по EDOC\EDI, для товара &1 &2&3 не указан внешний артикул"
        , tmp#zakaz.artic
        , tmp#zakaz.prod-type
        , tmp#zakaz.prod-code
        ) + chr(10) .
      end.
    end.
    if tmp#zakaz.cli-art <> "" then do:
        for each bf2_ext-artic where
                 bf2_ext-artic.cli-type  = loc-cli-type  and
                 bf2_ext-artic.cli-code  = loc-cli-code  and
                 bf2_ext-artic.ext-artic = tmp#zakaz.cli-art   :
          if     bf2_ext-artic.gds-code     = tmp#zakaz.gds-code
          or     bf2_ext-artic.status_   = 'удал':U then next.
          leave.
        end.
        if available bf2_ext-artic then do:
          find first bf2_goods no-lock where
                    bf2_goods.gds-code = bf2_ext-artic.gds-code no-error .
          find first bf3_goods no-lock where
                    bf3_goods.gds-code =  tmp#zakaz.gds-code no-error .
                    v-err-ext = true .
                    v-longchar = v-longchar +
                    substitute( "Для данного контрагента уже есть товар &1 &2&3 &4 с таким же внешним артикулом &5 как у &6 &7&8 &9"
                  , bf2_goods.artic
                  , bf2_goods.prod-type
                  , bf2_goods.prod-code
                  , bf2_goods.gds-name
                  , tmp#zakaz.cli-art
                  , tmp#zakaz.artic
                  , tmp#zakaz.prod-type
                  , tmp#zakaz.prod-code
                  , bf3_goods.gds-name
                  ) +  chr(10).
        end.
    end.
    if last-of (tmp#zakaz.cli-art) then do:
       if tmp#zakaz.cli-art <> "" then do:
        for each bf2_tmp#zakaz where
                 bf2_tmp#zakaz.cli-art = tmp#zakaz.cli-art and
                 bf2_tmp#zakaz.gds-code <> tmp#zakaz.gds-code break by bf2_tmp#zakaz.cli-art :
                find first bf2_goods no-lock where
                          bf2_goods.gds-code = bf2_tmp#zakaz.gds-code
                          no-error .
                    v-err-ext = true .
                    if first-of(bf2_tmp#zakaz.cli-art) then do:
                        v-longchar = v-longchar +
                        substitute( "В заказе есть повторяющиеся артикулы Поставщика &1 товар &2 &3&4 &5:&6"
                      , tmp#zakaz.cli-art
                      , tmp#zakaz.artic
                      , tmp#zakaz.prod-type
                      , tmp#zakaz.prod-code
                      , tmp#zakaz.gds-name
                      ,  chr(10)).
                    end.
                    v-longchar = v-longchar +
                    substitute( "- такой же артикул поставщика у товара &1 &2&3 &4 &5"
                  , bf2_goods.artic
                  , bf2_goods.prod-type
                  , bf2_goods.prod-code
                  , bf2_goods.gds-name
                  , chr(10) ).
        end.
       end.
    end.
  end.
  if v-err-ext = true  then do:
      run gbl/d-longchar.w (
              ?,
              'Editor_row=2\':u
            + 'title=Проверка строк заказа\':u
            + 'Editor_col=1\':u
            + 'Editor_width=96\':u
            + 'Editor_height=21\':u
            + 'readonly=yes\':u
          ,input-output v-longchar
          ,output v-ok ) no-error .
          if error-status :error then message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "4"
            view-as alert-box error
          .
          assign
          v-longchar = '':U.
      define variable vq as logical   no-undo init true .
      message
      "При проверке была обнаружена ошибка!"
      "Остаться в заказе для исправления ?"
      view-as alert-box question
      button yes-no
      update vq
      .
      if vq then  return error .
    end.
  if can-find
    ( first tmp#zakaz  no-lock    where
      tmp#zakaz.qnty  =  0 or
      tmp#zakaz.qnty  =  ?
    )
  and not is-edi-doc
  then do:
      message "В заказе есть нерассчитанные строки . Удаляем их ? " view-as alert-box question  buttons yes-no update g#log.
       if g#log then do:
            assign
              ord-qnty = 0
              ord-sum-cli = 0
              k = 0
              .
            for each tmp#zakaz no-lock :
                    if not  (tmp#zakaz.qnty = 0  or  tmp#zakaz.qnty = ? ) then do:
                      assign
                        k = k + 1
                        ord-qnty = ord-qnty + tmp#zakaz.qnty
                        ord-sum-cli = ord-sum-cli + ( tmp#zakaz.qnty * tmp#zakaz.price-cli )
                        .
                    end.
                    else do:
                        find first shar_ord-line  exclusive-lock   where
                                    shar_ord-line.doc-code   =  loc-ord-num   and
                                    shar_ord-line.artic      =   tmp#zakaz.artic and
                                    shar_ord-line.prod-type  =   tmp#zakaz.prod-type and
                                    shar_ord-line.prod-code  =   tmp#zakaz.prod-code no-error .
                          delete shar_ord-line .
                          delete tmp#zakaz.
                    end.
            end.
       end.
       else do:
       end.
  end.
  if not can-find
    ( first tmp#zakaz  no-lock    where
      tmp#zakaz.qnty  <>  0 and
      tmp#zakaz.qnty  <>  ?
    )
  and is-edi-doc
  then do :
      message "В заказе все строки нерассчитанные. Такой заказ нельзя отправлять по EDI. Удаляем строки? " view-as alert-box question  buttons yes-no update g#log.
       if g#log then do:
            assign
              ord-qnty = 0
              ord-sum-cli = 0
              k = 0
              .
            for each tmp#zakaz no-lock :
                    if not  (tmp#zakaz.qnty = 0  or  tmp#zakaz.qnty = ? ) then do:
                      assign
                        k = k + 1
                        ord-qnty = ord-qnty + tmp#zakaz.qnty
                        ord-sum-cli = ord-sum-cli + ( tmp#zakaz.qnty * tmp#zakaz.price-cli )
                        .
                    end.
                    else do:
                        find first shar_ord-line  exclusive-lock   where
                                    shar_ord-line.doc-code   =  loc-ord-num   and
                                    shar_ord-line.artic      =   tmp#zakaz.artic and
                                    shar_ord-line.prod-type  =   tmp#zakaz.prod-type and
                                    shar_ord-line.prod-code  =   tmp#zakaz.prod-code no-error .
                          delete shar_ord-line .
                          delete tmp#zakaz.
                    end.
            end.
       end.
  end.
   is-error = false  .
   is-em = "" .
   assign  frame dialog-frame wrkr loc-exch-code
          agnt boss loc-date-ship loc-time-ship loc-service
          paytype  cycle-day tog-type pay-day loc-tot-lines
          date-sale-1 date-sale-2 loc-cli-out-doc doc-date
          no-error .
   if error-status:error then do:
     is-error = true .
     is-em = error-status :get-message(1) .
   end.
   if date-sale-1 = loc-date-ship then do:
     pay-day = date-sale-2 - date-sale-1  .
   end.
   else do:
     pay-day = date-sale-2 - date-sale-1 + 1 .
   end.
   run ver-date  in this-procedure .
   if ( is-edoc-nn-doc = false and shar_ord-doc.ord-int1 = int('0':U) )
   or ( is-edi-doc     = false and shar_ord-doc.ord-int1 = int('0':U)  )
   then do:
     find first shar_ord-line  no-lock  where
                shar_ord-line.doc-code   =  loc-ord-num   and
                shar_ord-line.artic      =   tmp#zakaz.artic and
                shar_ord-line.prod-type  =   tmp#zakaz.prod-type and
                shar_ord-line.prod-code  =   tmp#zakaz.prod-code no-error .
      if available shar_ord-line then do:
          run ver-clients-calc in this-procedure (
            input loc-cli-type
          , input loc-cli-code
          , input store-type
          , input store-code
          , input e-method
          , output v-err
          ) .
          if v-err then return error 'no-calc'.
      end.
      run ver-calc no-error .
      if error-status :error then do:
        is-error = true .
        is-em    =  substitute("Была корректировка рассчитанного заказа!&1Пересчитайте заказ  " , chr(10)) .
        message "Документ не может быть сохранен в базу данных ! " skip
                is-em  skip
                view-as alert-box error  .
        return error return-value .
      end.
   end.
   if is-error = true then do:
        message "Документ в базу не добавлен ! " skip
        is-em  skip
        return-value skip
        view-as alert-box information .
        error-status:error = false .
   end.
   else do:
     run full-recount in this-procedure no-error.
     run local-conf-rd in this-procedure .
     run cus/ord-save.p (
          input parParentProc ,
          input t-action ,
          input v-deliv-type-code   ,
          input v-point-obj-code    ,
          input v-point-cli-code    ,
          input v-point-obj-db-num  ,
          input v-point-cli-db-num  ,
          input v-transport-host-code    ,
          input v-transport-cli-type    ,
          input v-transport-cli-code    ,
          input v-transport-contract ,
          input v-transport-condition,
          input v-transport-value    ,
          input v-transport-sum      ,
          input v-transport-vat    ,
          input  if v-err-ext then false else is-edoc-nn-doc  ,
          input  if v-err-ext then false else is-edi-doc      ,
          input v-dm-edi                                      )
          no-error .
     if error-status :error then return error return-value .
   end.
 end.
end procedure.
procedure proc-b-mark :
 do
 on error undo, return error return-value
 :
define variable tt-rec as recid no-undo .
  find current shar_ord-line  no-lock  no-error .
  if not avail shar_ord-line then return.
  find first tmp#zakaz no-lock    where
              shar_ord-line.prod-type       = tmp#zakaz.prod-type and
              shar_ord-line.prod-code       = tmp#zakaz.prod-code and
              shar_ord-line.artic           = tmp#zakaz.artic        no-error  .
   if not avail tmp#zakaz   then do:
       message error-status :get-message(1) .
       return.
       end.
 tt-rec = recid (shar_ord-line) .
 if tmp#zakaz.local-mark = "*" then do :
    tmp#zakaz.local-mark = "".
    end.
  else do:
   tmp#zakaz.local-mark = "*" .
  end.
if br-docs:refresh() in frame dialog-frame  then.
reposition br-docs to recid tt-rec no-error.
g#log = br-docs:select-next-row () in frame dialog-frame.
apply "entry" to br-docs in frame dialog-frame.
 end.
end procedure.
procedure ver-gds-flor :
 do
 on error undo, return error return-value
 :
define input  parameter p-gds-code as integer   no-undo .
define output parameter  v-nabor   as logical   no-undo .
v-nabor = false .
   run ver-gds-grp-nabor( input p-gds-code, output v-nabor) .
end.
end procedure.
procedure chg-action :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define buffer buff_contract for ub.contract.
t-ret =  session:set-wait-state("general") .
 find first buf-cli where recid(buf-cli) = rep-rec no-lock no-error.
 find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
 p-doc-code  = shar_ord-doc.doc-code.
  if available shar_ord-doc then  do:
     find first for-obj where for-obj.obj-code = shar_ord-doc.obj-code and
                              for-obj.obj-type = shar_ord-doc.obj-type no-lock no-error .
     if error-status :error then return error.
    assign
      date-1 = shar_ord-doc.start-date
      date-2 = shar_ord-doc.end-date no-error .
      if error-status :error then
         assign
            date-1 = to-day - 7
            date-2 = to-day.
    assign
      loc-obj-name-2  = "(" + shar_ord-doc.obj-type + " " + string(shar_ord-doc.obj-code ) + ")" + for-obj.obj-name
      wrkr            = shar_ord-doc.wrkr
      agnt            = shar_ord-doc.agnt
      boss            = shar_ord-doc.boss
      loc-time-ship   = string(shar_ord-doc.ship-time,"hh:mm")
      loc-hour        = integer (entry(1,string(shar_ord-doc.ship-time,"hh:mm"),":"))
      loc-min         = integer (entry(2,string(shar_ord-doc.ship-time,"hh:mm"),":"))
      date-sale-1     = shar_ord-doc.date-sale-1
      date-sale-2     = shar_ord-doc.date-sale-2
      e-method        = shar_ord-doc.e-method
      temp-e-method   = e-method
      loc-date-ship   = shar_ord-doc.ship-date
      loc-status      = shar_ord-doc.status_
      paytype         = shar_ord-doc.pay-code
      loc-service     = shar_ord-doc.sum-service
      cycle-day       = shar_ord-doc.cycle-day
      pay-day         = shar_ord-doc.pay-day
      tog-type        = shar_ord-doc.order-type
      loc-base-rate   = shar_ord-doc.base-rate
      loc-base-scale  = shar_ord-doc.base-scale
      loc-cli-qnty    = shar_ord-doc.cli-qnty
      loc-qnty        = shar_ord-doc.qnty
      loc-sum-base    = shar_ord-doc.sum-base
      loc-sum-cli     = shar_ord-doc.sum-cli
      loc-sum-rubl    = shar_ord-doc.sum-rubl
      loc-tot-lines   = shar_ord-doc.tot-lines
      loc-exch-code         = shar_ord-doc.exch-code
      loc-exch-rate         = shar_ord-doc.exch-rate
      loc-exch-scale        = shar_ord-doc.exch-scale
      loc-out-code          = shar_ord-doc.out-code
      doc-date              = shar_ord-doc.doc-date
      loc-doc-type          = shar_ord-doc.doc-type
      fact-date             = shar_ord-doc.fact-date
      vat_type              = shar_ord-doc.vat-type
      slt_type              = shar_ord-doc.slt-type
      loc-print-rubl        = true
      loc-store-code        = shar_ord-doc.obj-code
      loc-store-type        = shar_ord-doc.obj-type
      v-deliv-type-code     = shar_ord-doc.deliv-type-code
      v-point-obj-code      = shar_ord-doc.obj-point-code
      v-point-cli-code      = shar_ord-doc.cli-point-code
      v-point-obj-db-num    = shar_ord-doc.obj-point-db-num
      v-point-cli-db-num    = shar_ord-doc.cli-point-db-num
      v-transport-host-code = shar_ord-doc.transport-host-code
      v-transport-cli-type  = shar_ord-doc.transport-cli-type
      v-transport-cli-code  = shar_ord-doc.transport-cli-code
      v-transport-contract  = shar_ord-doc.transport-contract
      v-transport-condition = shar_ord-doc.transport-condition
      v-transport-value     = shar_ord-doc.transport-value
      v-transport-sum       = shar_ord-doc.sum-ship
      v-transport-vat       = shar_ord-doc.transport-vat
      loc-cli-out-doc       = entry(1, shar_ord-doc.cli-out-doc, chr(4))
      .
    find first buff_contract no-lock where buff_contract.host-code     = shar_ord-doc.host-code and
                                           buff_contract.contract-code = shar_ord-doc.contract-code no-error .
    if available buff_contract then
        assign
          loc-exch-code       = buff_contract.curr-code
          loc-contract        = buff_contract.contract-code
        .
      find ub.currency where ub.currency.curr-code = loc-exch-code no-lock no-error.
        if available ub.currency then disp ub.currency.curr-abbr with frame dialog-frame.
                              else disp ? @ ub.currency.curr-abbr with frame dialog-frame.
   end.
   find ub.pay-type where ub.pay-type.obj-code = shar_ord-doc.pay-code no-lock no-error.
   if available ub.pay-type then  do:
    assign
    loc-pay-type = ub.pay-type.obj-name  .
    end.
    if available buf-cli then
    assign
        loc-cli-code = buf-cli.obj-code
        loc-cli-type = buf-cli.obj-type
        loc-obj-name = buf-cli.obj-name
        .
     else
     assign
        loc-cli-code = ?
        loc-cli-type = ?
        loc-obj-name = ?
        .
    if t-action = "copy":u
       then do:
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run proc-ord-code in this-procedure
 (input   'main' ,
  input   v-cntxt-db-num ,
  input   v-cntxt-obj-type ,
  input   v-cntxt-obj-code ,
  input   v-i-doc ,
  output  loc-ord-num
 ) .
       assign
          loc-status  = 'новый':U
          loc-date-ship = ?
          date-sale-2   = ?
          date-sale-1   = ?
       .
       end.
       else assign loc-ord-num = shar_ord-doc.doc-code
                   loc-status  = shar_ord-doc.status_  .
    find first clients-doc where clients-doc.obj-code = wrkr
                             and clients-doc.obj-type = 'чел':U no-lock no-error.
         if  error-status :error then error-status :error = false .
        if avail clients-doc then do:
         wrkr-name = clients-doc.obj-name.
       end.
    find first clients-doc1 where clients-doc1.obj-code = agnt
                             and clients-doc1.obj-type = 'чел':U no-lock no-error.
         if  error-status :error then error-status :error = false .
         if avail clients-doc1 then agnt-name = clients-doc1.obj-name.
    find first clients-doc2 where clients-doc2.obj-code = boss
                             and clients-doc2.obj-type = 'чел':U no-lock no-error.
     if  error-status :error then error-status :error = false .
     if avail clients-doc2 then boss-name = clients-doc2.obj-name.
     if  error-status :error then error-status :error = false .
    disable loc-cli-code
            loc-cli-type
            loc-obj-name
            r-clients with frame dialog-frame.
     display
        wrkr agnt boss
        wrkr-name agnt-name
        boss-name
        with frame dialog-frame.
  for each shar_ord-line where shar_ord-line.doc-code = shar_ord-doc.doc-code  no-lock :
     run create-tmp in this-procedure  (input "doc":u,"") no-error .
     if error-status :error then message
         vss-workfile vss-revision vss-description skip
         error-status :get-message(1)  skip
        "Ошибка вызова процедуры create-tmp"  skip
        .
  end.
  run create-tmp-dtl  .
  run openbr in this-procedure  .
  run enable_ui.
 t-ret =  session:set-wait-state("") .
end.
end procedure.
procedure create-tmp :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define input parameter tt as character no-undo.
define input parameter t  as character no-undo.
define variable prod-type#   like ub.ord-line.prod-type no-undo .
define variable prod-code#   like ub.ord-line.prod-code no-undo .
define variable artic#       like ub.ord-line.artic     no-undo .
define variable v-price-exel as decimal   no-undo .
define variable p-recid as recid no-undo .
define buffer buf_ord-dtl  for ub.ord-dtl.
define buffer ll-tmp#zakaz for tmp#zakaz .
define buffer bufff-units  for ub.units     .
 case tt :
    when "price":u  then do:
      find  first sb-cli-gds  where
            sb-cli-gds.cli-type  = buf-cli.obj-type and
            sb-cli-gds.cli-code  = buf-cli.obj-code and
            sb-cli-gds.host-code = v-cntxt-host-code-obj  and
            sb-cli-gds.artic     = ub.goods.artic      and
            sb-cli-gds.prod-type = ub.goods.prod-type  and
            sb-cli-gds.prod-code = ub.goods.prod-code  no-lock no-error.
            if available sb-cli-gds then p-recid = recid(sb-cli-gds).
            else do:
                find first sb-cli-gds where
                      sb-cli-gds.artic     = ub.goods.artic      and
                      sb-cli-gds.prod-type = ub.goods.prod-type  and
                      sb-cli-gds.prod-code = ub.goods.prod-code  and
                      sb-cli-gds.host-code = v-cntxt-host-code-obj
                      no-lock no-error.
                      if available sb-cli-gds then p-recid = recid(sb-cli-gds).
                      else p-recid = ?.
            end.
            run proc-eq-tmp-price ( p-recid,tt)  no-error .
            if error-status :error
            then do:
                message vss-workfile vss-revision vss-description skip
                error-status :get-message(1)
                'proc-eq-tmp-price 67'
                view-as alert-box error .
            end.
       end.
    when "goods":u  then do:
      find  first sb-cli-gds  where
            sb-cli-gds.cli-type  = buf-cli.obj-type and
            sb-cli-gds.cli-code  = buf-cli.obj-code and
            sb-cli-gds.host-code = v-cntxt-host-code-obj  and
            sb-cli-gds.artic     = ub.goods.artic      and
            sb-cli-gds.prod-type = ub.goods.prod-type  and
            sb-cli-gds.prod-code = ub.goods.prod-code  no-lock no-error.
            if available sb-cli-gds then p-recid = recid(sb-cli-gds).
            else p-recid = ?.
            run proc-eq-tmp-price ( p-recid,tt)  no-error .
            if error-status :error
            then do:
                message vss-workfile vss-revision vss-description skip
                error-status :get-message(1)
                232
                view-as alert-box error .
            end.
    end.
    when "gds-list":u  then do:
      find first ub.goods where
            gds-list.artic     = ub.goods.artic     and
            gds-list.prod-type = ub.goods.prod-type and
            gds-list.prod-code = ub.goods.prod-code no-lock no-error.
            if error-status :error
            then do:
                message vss-workfile vss-revision vss-description skip
                error-status :get-message(1)
                "Плохо ! gds-list не = goods !"
                123
                view-as alert-box error .
            end.
      find  first sb-cli-gds  where
            sb-cli-gds.cli-type  = buf-cli.obj-type and
            sb-cli-gds.cli-code  = buf-cli.obj-code and
            sb-cli-gds.artic     = gds-list.artic      and
            sb-cli-gds.host-code = v-cntxt-host-code-obj         and
            sb-cli-gds.prod-type = gds-list.prod-type  and
            sb-cli-gds.prod-code = gds-list.prod-code  no-lock no-error.
            if available sb-cli-gds then p-recid = recid(sb-cli-gds).
            else p-recid = ?.
            run proc-eq-tmp-price ( p-recid,tt)  no-error .
            if error-status :error
            then do:
                message vss-workfile vss-revision vss-description skip
                error-status :get-message(1)
                "Плохо !  Ошибка в proc-eq-tmp-price !"
                333
                view-as alert-box error .
            end.
    end.
    when "tt-gds-list":u  then do:
      find first ub.goods where
            ub.goods.artic     = tt-gds-list.artic     and
            ub.goods.prod-type = tt-gds-list.prod-type and
            ub.goods.prod-code = tt-gds-list.prod-code no-lock no-error.
            if error-status :error  then do:
                message vss-workfile vss-revision vss-description skip
                error-status :get-message(1)
                "Плохо ! tt-gds-list не = goods !"
                1
                view-as alert-box error .
            end.
      find  first sb-cli-gds  where
            sb-cli-gds.cli-type  = buf-cli.obj-type and
            sb-cli-gds.cli-code  = buf-cli.obj-code and
            sb-cli-gds.artic     = tt-gds-list.artic      and
            sb-cli-gds.host-code = v-cntxt-host-code-obj         and
            sb-cli-gds.prod-type = tt-gds-list.prod-type  and
            sb-cli-gds.prod-code = tt-gds-list.prod-code  no-lock no-error.
            if available sb-cli-gds then p-recid = recid(sb-cli-gds).
            else p-recid = ?.
            run proc-eq-tmp-price ( p-recid,tt)  no-error .
            if error-status :error
            then do:
                message vss-workfile vss-revision vss-description skip
                error-status :get-message(1)
                "Плохо !  Ошибка в proc-eq-tmp-price !"
                333
                view-as alert-box error .
            end.
    end.
    when "contract-spec":u  then do:
      find first ub.goods where
            ub.goods.gds-code  = ub.contract-specif.gds-code  no-lock no-error.
            if error-status :error  then do:
                message vss-workfile vss-revision vss-description skip
                        "При добавлении товаров из спецификации по договору произошла ошибка :" skip
                        "Нет товара с кодом : " ub.contract-specif.gds-code
                        view-as alert-box error .
            end.
      find  first sb-cli-gds  where
            sb-cli-gds.host-code = v-cntxt-host-code-obj and
            sb-cli-gds.cli-type  = buf-cli.obj-type and
            sb-cli-gds.cli-code  = buf-cli.obj-code and
            sb-cli-gds.artic     = ub.goods.artic      and
            sb-cli-gds.prod-type = ub.goods.prod-type  and
            sb-cli-gds.prod-code = ub.goods.prod-code  no-lock no-error.
            if available sb-cli-gds then p-recid = recid(sb-cli-gds).
            else p-recid = ?.
            if not available tmp#zakaz then do:
                  run proc-eq-tmp-price ( p-recid, tt)  no-error .
            end.
            case t :
              when "only-price" then do:
                if ub.contract-specif.price-cli <> tmp#zakaz.price-cli
                or ub.contract-specif.vat-pc    <> tmp#zakaz.vat-pc
                then do:
                  assign v-update-price = v-update-price + 1 .
                end.
              end.
              when "only-qnty" then do:
                if ub.contract-specif.qnty <> tmp#zakaz.cli-qnty
                then do:
                  assign v-update-price = v-update-price + 1 .
                end.
              end.
              when "" then do:
                if ub.contract-specif.qnty      <> tmp#zakaz.cli-qnty
                or ub.contract-specif.price-cli <> tmp#zakaz.price-cli
                or ub.contract-specif.vat-pc    <> tmp#zakaz.vat-pc
                then do:
                  assign v-update-price = v-update-price + 1 .
                end.
              end.
            end case.
             if t <> "only-qnty"  then do:
                run proc-eq-tmp-price ( p-recid,tt)  no-error .
             end .
            if ub.contract-specif.cli-base-rate <> 0 then do:
              assign
                tmp#zakaz.cli-base-rate = ub.contract-specif.cli-base-rate
                tmp#zakaz.unit-cli      = ub.contract-specif.unit-base
              .
            end.
            if t <> "only-price"  then do:
                if  ub.contract-specif.qnty <> 0 then do:
                  assign
                    tmp#zakaz.cli-qnty = ub.contract-specif.qnty
                  .
                end.
            end.
            if t <> "only-qnty"  then do:
              assign
                tmp#zakaz.vat-pc     =  ub.contract-specif.vat-pc
                tmp#zakaz.price-cli  =  ub.contract-specif.price-cli
              .
            end.
          assign
              tmp#zakaz.qnty       =  tmp#zakaz.cli-qnty   * tmp#zakaz.cli-base-rate
              tmp#zakaz.price-rubl =  tmp#zakaz.price-cli  * loc-exch-rate / loc-exch-scale / tmp#zakaz.cli-base-rate
              tmp#zakaz.price-base =  tmp#zakaz.price-rubl / loc-base-rate * loc-base-scale
              tmp#zakaz.sum        =  tmp#zakaz.price-rubl * tmp#zakaz.qnty
              tmp#zakaz.sum-rubl   =  tmp#zakaz.price-rubl * tmp#zakaz.qnty
              tmp#zakaz.sum-base   =  tmp#zakaz.price-base * tmp#zakaz.qnty
              tmp#zakaz.sum-cli    =  tmp#zakaz.price-cli  * tmp#zakaz.cli-qnty
              .
    end.
    when "doc":u  then do:
        find first ub.goods where
                ub.goods.artic     = shar_ord-line.artic     and
                ub.goods.prod-type = shar_ord-line.prod-type and
                ub.goods.prod-code = shar_ord-line.prod-code no-lock no-error.
       if not (line-mode = "" and  t-action = "chg":U  )  then do:
              if available ub.goods then do:
                    p-recid = ?.
                    find first sb-cli-gds  where
                        sb-cli-gds.cli-type  = buf-cli.obj-type and
                        sb-cli-gds.cli-code  = buf-cli.obj-code and
                        sb-cli-gds.host-code = v-cntxt-host-code-obj      and
                        sb-cli-gds.artic     = ub.goods.artic      and
                        sb-cli-gds.prod-type = ub.goods.prod-type  and
                        sb-cli-gds.prod-code = ub.goods.prod-code  no-lock no-error .
                        if available sb-cli-gds then p-recid = recid(sb-cli-gds).
                        else p-recid = ?.
                    run proc-eq-tmp-price ( p-recid,tt)  no-error .
                    if error-status :error then message vss-workfile vss-revision vss-description skip
                                                        error-status :get-message(1)  skip
                                                        "Ошибка вызова процедуры proc-eq-tmp-price"  skip
                                                        .
              end.
           buffer-copy shar_ord-line to tmp#zakaz.
        end.
        else do:
           create  tmp#zakaz.
           buffer-copy shar_ord-line to tmp#zakaz
             assign
                tmp#zakaz.gds-name      = ub.goods.gds-name
                tmp#zakaz.negative-rest = ub.goods.negative-rest
                tmp#zakaz.unit-base     = ub.goods.unit-base
                tmp#zakaz.sum           = tmp#zakaz.price-rubl * tmp#zakaz.qnty
           .
            find first buf_ord-line-attr where buf_ord-line-attr.doc-code = shar_ord-line.doc-code
              and buf_ord-line-attr.gds-code = shar_ord-line.gds-code
              and buf_ord-line-attr.attr-code = 'min-stock':U no-error.
            if available buf_ord-line-attr then tmp#zakaz.min-stock-old = decimal(buf_ord-line-attr.attr-value).
            find first buf_ord-line-attr where buf_ord-line-attr.doc-code = shar_ord-line.doc-code
              and buf_ord-line-attr.gds-code = shar_ord-line.gds-code
              and buf_ord-line-attr.attr-code = 'gds-way':U no-error.
            if available buf_ord-line-attr then tmp#zakaz.gds-way = decimal(buf_ord-line-attr.attr-value).
            find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-base no-lock no-error.
            if available bufff-units then
            assign
              tmp#zakaz.unit-type       = bufff-units.type .
            find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-cli no-lock no-error.
            if available bufff-units then
            assign
              tmp#zakaz.unit-cli-type       = bufff-units.type .
        end.
    end.
    when "excel":u  then do:
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
 Assign
 artic#           = chWorkSheet:Range ("A" + T):Value
 prod-type#       = chWorkSheet:Range ("B" + T):Value
 prod-code#       = chWorkSheet:Range ("C" + T):Value  no-error.
  Find FIRST TMP#zakaz   where
    TMP#zakaz.artic           = artic#      and
    TMP#zakaz.prod-type       = prod-type#  and
    TMP#zakaz.prod-code       = prod-code#  no-error.
  if not available TMP#zakaz  THEN  CREATE TMP#zakaz .
  ASSIGN
    TMP#zakaz.artic           = chWorkSheet:Range ("A" + T):Value
    TMP#zakaz.prod-type       = chWorkSheet:Range ("B" + T):Value
    TMP#zakaz.prod-code       = chWorkSheet:Range ("C" + T):Value
    TMP#zakaz.cli-art         = chWorkSheet:Range ("E" + T):Value
    TMP#zakaz.price-cli       = chWorkSheet:Range ("F" + T):Value
    TMP#zakaz.qnty            = chWorkSheet:Range ("G" + T):Value
    TMP#zakaz.initial-qnty    = chWorkSheet:Range ("G" + T):Value no-error .
  if error-status :error then do:
      message "Файл не соответствует заданному формату." view-as alert-box error .
      return error .
  end.
  FIND FIRST ub.goods No-LOCK WHERE ub.goods.prod-type = TMP#zakaz.prod-type AND
                                 ub.goods.prod-code = TMP#zakaz.prod-code AND
                                 ub.goods.artic     = TMP#zakaz.artic   NO-ERROR.
   if error-status :error then return error .
       V-PRICE-EXEL = tmp#zakaz.price-cli.
       find  first sb-cli-gds  where
            sb-cli-gds.host-code = v-cntxt-host-code-obj and
            sb-cli-gds.cli-type  = buf-cli.obj-type and
            sb-cli-gds.cli-code  = buf-cli.obj-code and
            sb-cli-gds.artic     = ub.goods.artic      and
            sb-cli-gds.prod-type = ub.goods.prod-type  and
            sb-cli-gds.prod-code = ub.goods.prod-code  no-lock no-error.
            if available sb-cli-gds then p-recid = recid(sb-cli-gds).
            else p-recid = ?.
       run proc-eq-tmp-price ( p-recid , tt)  no-error .
       if error-status :error then message vss-workfile vss-revision vss-description skip
                                           error-status :get-message(1)  skip
                                          "Ошибка вызова процедуры proc-eq-tmp-price exel 2"  skip
                                          .
          assign
            tmp#zakaz.price-cli  = IF V-PRICE-EXEL = 0 OR V-PRICE-EXEL = ? THEN tmp#zakaz.price-cli ELSE V-PRICE-EXEL * tmp#zakaz.cli-base-rate
            tmp#zakaz.price-RUBL = IF V-PRICE-EXEL = 0 OR V-PRICE-EXEL = ? THEN tmp#zakaz.price-RUBL ELSE V-PRICE-EXEL
            tmp#zakaz.cli-qnty   = tmp#zakaz.qnty       / tmp#zakaz.cli-base-rate
            tmp#zakaz.sum        = tmp#zakaz.price-rubl * tmp#zakaz.qnty
            tmp#zakaz.sum-rubl   = tmp#zakaz.price-rubl * tmp#zakaz.qnty
            tmp#zakaz.sum-cli    = tmp#zakaz.price-cli  * tmp#zakaz.cli-qnty
            .
    end.
    when "excel2":u  then do:
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
 Assign
 artic#           = chWorkSheet2:Range ("A" + T):Value
 prod-type#       = chWorkSheet2:Range ("B" + T):Value
 prod-code#       = chWorkSheet2:Range ("C" + T):Value  no-error.
  Find FIRST TMP#zakaz   where
    TMP#zakaz.artic           = artic#      and
    TMP#zakaz.prod-type       = prod-type#  and
    TMP#zakaz.prod-code       = prod-code#  no-error.
  if not available TMP#zakaz  THEN  CREATE TMP#zakaz .
  ASSIGN
    TMP#zakaz.artic           = chWorkSheet2:Range ("A" + T):Value
    TMP#zakaz.prod-type       = chWorkSheet2:Range ("B" + T):Value
    TMP#zakaz.prod-code       = chWorkSheet2:Range ("C" + T):Value
    TMP#zakaz.cli-art         = chWorkSheet2:Range ("E" + T):Value
    TMP#zakaz.price-cli       = chWorkSheet2:Range ("F" + T):Value
    TMP#zakaz.qnty            = chWorkSheet2:Range ("G" + T):Value
    TMP#zakaz.initial-qnty    = chWorkSheet2:Range ("G" + T):Value no-error .
  if error-status :error then do:
      message "Файл не соответствует заданному формату." view-as alert-box error .
      return error .
  end.
  FIND FIRST ub.goods No-LOCK WHERE ub.goods.prod-type = TMP#zakaz.prod-type AND
                                 ub.goods.prod-code = TMP#zakaz.prod-code AND
                                 ub.goods.artic     = TMP#zakaz.artic   NO-ERROR.
   if error-status :error then return error .
       V-PRICE-EXEL = tmp#zakaz.price-cli .
      find  first sb-cli-gds  where
            sb-cli-gds.host-code = v-cntxt-host-code-obj and
            sb-cli-gds.cli-type  = buf-cli.obj-type and
            sb-cli-gds.cli-code  = buf-cli.obj-code and
            sb-cli-gds.artic     = ub.goods.artic      and
            sb-cli-gds.prod-type = ub.goods.prod-type  and
            sb-cli-gds.prod-code = ub.goods.prod-code  no-lock no-error.
            if available sb-cli-gds then p-recid = recid(sb-cli-gds).
            else p-recid = ?.
       run proc-eq-tmp-price ( p-recid,tt)  no-error .
      if error-status :error then message vss-workfile vss-revision vss-description skip
                                          error-status :get-message(1)  skip
                                          "Ошибка вызова процедуры proc-eq-tmp-price exel2 "  skip
                                          .
      assign
        tmp#zakaz.price-cli = IF V-PRICE-EXEL = 0 OR V-PRICE-EXEL = ? THEN tmp#zakaz.price-cli ELSE V-PRICE-EXEL * tmp#zakaz.cli-base-rate
        tmp#zakaz.price-RUBL = IF V-PRICE-EXEL = 0 OR V-PRICE-EXEL = ? THEN tmp#zakaz.price-RUBL ELSE V-PRICE-EXEL
        tmp#zakaz.cli-qnty  =   tmp#zakaz.qnty  / tmp#zakaz.cli-base-rate
        tmp#zakaz.sum       =   tmp#zakaz.price-rubl * tmp#zakaz.qnty
        tmp#zakaz.sum-rubl       =   tmp#zakaz.price-rubl * tmp#zakaz.qnty
        tmp#zakaz.sum-cli   =   tmp#zakaz.price-cli  * tmp#zakaz.cli-qnty
        .
    end.
 end case.
  tmp#zakaz.doc-code        = loc-ord-num   .
  find first buf_ord-dtl  no-lock where
        buf_ord-dtl.artic       = tmp#zakaz.artic     and
        buf_ord-dtl.prod-code   = tmp#zakaz.prod-code and
        buf_ord-dtl.prod-type   = tmp#zakaz.prod-type
    no-error .
    if available buf_ord-dtl
      then assign tmp#zakaz.prt-ok   =   true .
      else assign tmp#zakaz.prt-ok   =   false  .
    find first shar_ord-line exclusive-lock  where
               shar_ord-line.doc-code  = loc-ord-num    and
               shar_ord-line.prod-type = tmp#zakaz.prod-type and
               shar_ord-line.prod-code = tmp#zakaz.prod-code and
               shar_ord-line.artic     = tmp#zakaz.artic
    no-error.
    if not available shar_ord-line  then  do:
       create shar_ord-line  .
    end.
    if (lookup('шту':U, tmp#zakaz.unit-cli-type) > 0
    or lookup('сер':U, tmp#zakaz.unit-cli-type) > 0 ) and
        tmp#zakaz.cli-qnty <> truncate(tmp#zakaz.cli-qnty, 0) then do:
        tmp#zakaz.cli-qnty = truncate(tmp#zakaz.cli-qnty, 0) + 1 .
        tmp#zakaz.sum-cli  = tmp#zakaz.cli-qnty * tmp#zakaz.price-cli .
        tmp#zakaz.qnty     = tmp#zakaz.cli-qnty * tmp#zakaz.cli-base-rate .
        tmp#zakaz.sum-rubl = tmp#zakaz.qnty * tmp#zakaz.price-rubl .
        tmp#zakaz.sum-base = tmp#zakaz.qnty * tmp#zakaz.price-base .
    end.
    buffer-copy tmp#zakaz to shar_ord-line
         assign shar_ord-line.doc-code    = loc-ord-num
      .
  if tmp#zakaz.line-num = 0 or
     tmp#zakaz.line-num = ? or
     shar_ord-line.line-num = 0 then do:
       find last ll-tmp#zakaz where ll-tmp#zakaz.gds-code  <> tmp#zakaz.gds-code use-index idx-ln no-lock no-error.
        if available ll-tmp#zakaz
            then tmp#zakaz.line-num = ll-tmp#zakaz.line-num + 1.
            else tmp#zakaz.line-num = 1.
       find current shar_ord-line  exclusive-lock  no-error .
       if not error-status :error  then
          shar_ord-line.line-num = tmp#zakaz.line-num .
  end.
end .
end procedure.
procedure disable_ui :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  hide frame dialog-frame.
end.
end procedure.
procedure enable_ui :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if g#type <> 'ОФ':U then do:
  display  loc-cli-type loc-cli-code  doc-date fact-date paytype wrkr tog-type  agnt r-agnt loc-date-ship loc-service boss r-boss loc-qnty loc-exch-code r-currency loc-cli-qnty loc-exch-rate loc-exch-scale r-acc loc-sum-rubl loc-base-rate loc-base-scale loc-sum-base  loc-contract loc-tot-lines  loc-sum-cli slt_type vat_type br-docs e-method br-docs-2 loc-obj-name loc-obj-name-2 loc-pay-type loc-cli-out-doc t agnt-name boss-name prod-name goods-name t-auto date-sale-1 date-sale-2  loc-hour loc-min  b-contract B-protocol      with frame dialog-frame.
  enable   rect-4 rect-5  rect-7 rect-6 b-exit doc-date fact-date paytype r-paytype r-contract b-contract B-protocol wrkr tog-type  r-wrkr agnt r-agnt loc-date-ship loc-service boss r-boss  loc-qnty loc-exch-code r-currency loc-cli-qnty loc-exch-rate loc-exch-scale r-acc loc-sum-rubl loc-base-rate loc-base-scale  loc-sum-base loc-tot-lines  loc-sum-cli slt_type vat_type br-docs   br-docs-2 b-add b-spec b-way b-del b-chg b-main-calc b-producer b-sch b-alt-post b-gds-prt b-notes  b-uf b-remove  b-renum  b-mark  b-help b-itogs b-export b-import loc-obj-name wrkr-name e-method  a-n-c loc-pay-type loc-cli-out-doc t agnt-name boss-name prod-name goods-name t-auto date-sale-1 date-sale-2 loc-hour loc-min doc-date      with frame dialog-frame.
end.
else do:
  display loc-cli-type loc-cli-code  doc-date fact-date  wrkr tog-type  agnt r-agnt loc-date-ship boss r-boss loc-qnty loc-cli-qnty loc-tot-lines  br-docs e-method br-docs-2 loc-obj-name loc-obj-name-2 loc-pay-type loc-cli-out-doc t agnt-name boss-name prod-name goods-name t-auto date-sale-1 date-sale-2  loc-hour loc-min      with frame dialog-frame.
  enable  rect-4 rect-5  rect-7 rect-6 b-exit doc-date fact-date  B-protocol wrkr tog-type  r-wrkr agnt r-agnt loc-date-ship boss r-boss  loc-qnty loc-cli-qnty loc-tot-lines  br-docs br-docs-2 b-add b-way b-del b-chg b-main-calc b-producer b-sch b-alt-post b-gds-prt b-notes b-uf b-remove  b-renum  b-mark  b-help b-itogs b-export b-import loc-obj-name wrkr-name e-method  a-n-c t agnt-name boss-name prod-name goods-name t-auto date-sale-1 date-sale-2 loc-hour loc-min      with frame dialog-frame.
end.
  if t-action = "add":u  and  g#type <> 'ОФ':U  then do :
     enable  loc-cli-code r-clients with frame dialog-frame .
     disable b-add b-way b-main-calc b-del b-chg b-producer b-alt-post b-export b-import with frame dialog-frame .
  end.
hide pay-day loc-out-code loc-time-ship b-sch  b-itogs
    in frame dialog-frame .
 disable b-gds-prt with frame dialog-frame .
if g#type = 'ОФ':U then do:
  hide  loc-exch-code
        loc-exch-rate
        loc-base-rate
        ub.currency.curr-abbr
        loc-exch-scale
        loc-base-scale
        paytype
        loc-pay-type
        loc-cli-out-doc
        r-paytype
        loc-service
        loc-sum-rubl
        loc-sum-base
        loc-sum-cli
        loc-contract
        slt_type
        vat_type
        r-currency
        r-acc
        in frame dialog-frame .
end.
view frame dialog-frame.
end.
end procedure.
procedure enable_ui_2 :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if g#type <> 'ОФ':U then do:
  display  loc-cli-type loc-cli-code  doc-date fact-date paytype wrkr tog-type  agnt r-agnt loc-date-ship loc-service boss r-boss loc-qnty loc-exch-code r-currency loc-cli-qnty loc-exch-rate loc-exch-scale r-acc loc-sum-rubl loc-base-rate loc-base-scale loc-sum-base  loc-contract loc-tot-lines  loc-sum-cli slt_type vat_type br-docs e-method br-docs-2 loc-obj-name loc-obj-name-2 loc-pay-type loc-cli-out-doc t agnt-name boss-name prod-name goods-name t-auto date-sale-1 date-sale-2  loc-hour loc-min  b-contract B-protocol      with frame dialog-frame.
  enable   rect-4 rect-5  rect-7 rect-6 b-exit doc-date fact-date paytype r-paytype r-contract b-contract B-protocol wrkr tog-type  r-wrkr agnt r-agnt loc-date-ship loc-service boss r-boss  loc-qnty loc-exch-code r-currency loc-cli-qnty loc-exch-rate loc-exch-scale r-acc loc-sum-rubl loc-base-rate loc-base-scale  loc-sum-base loc-tot-lines  loc-sum-cli slt_type vat_type br-docs   br-docs-2 b-add b-spec b-way b-del b-chg b-main-calc b-producer b-sch b-alt-post b-gds-prt b-notes  b-uf b-remove  b-renum  b-mark  b-help b-itogs b-export b-import loc-obj-name wrkr-name e-method  a-n-c loc-pay-type loc-cli-out-doc t agnt-name boss-name prod-name goods-name t-auto date-sale-1 date-sale-2 loc-hour loc-min doc-date      with frame dialog-frame.
end.
else do:
  display loc-cli-type loc-cli-code  doc-date fact-date  wrkr tog-type  agnt r-agnt loc-date-ship boss r-boss loc-qnty loc-cli-qnty loc-tot-lines  br-docs e-method br-docs-2 loc-obj-name loc-obj-name-2 loc-pay-type loc-cli-out-doc t agnt-name boss-name prod-name goods-name t-auto date-sale-1 date-sale-2  loc-hour loc-min      with frame dialog-frame.
  enable  rect-4 rect-5  rect-7 rect-6 b-exit doc-date fact-date  B-protocol wrkr tog-type  r-wrkr agnt r-agnt loc-date-ship boss r-boss  loc-qnty loc-cli-qnty loc-tot-lines  br-docs br-docs-2 b-add b-way b-del b-chg b-main-calc b-producer b-sch b-alt-post b-gds-prt b-notes b-uf b-remove  b-renum  b-mark  b-help b-itogs b-export b-import loc-obj-name wrkr-name e-method  a-n-c t agnt-name boss-name prod-name goods-name t-auto date-sale-1 date-sale-2 loc-hour loc-min      with frame dialog-frame.
end.
disable   all      with frame dialog-frame.
  enable b-exit  b-producer b-sch b-alt-post  b-notes  b-help b-gds-prt
         br-docs b-export a-n-c
      with frame dialog-frame.
   enable e-method with frame dialog-frame.
   e-method:read-only = true .
 disable b-gds-prt with frame dialog-frame .
  display
   b-exit  b-producer b-sch b-alt-post  b-notes  b-help b-gds-prt
   br-docs b-export  a-n-c
  with frame dialog-frame.
  view frame dialog-frame.
end.
end procedure.
procedure openbr :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
t-ret =  session:set-wait-state("general") .
define variable l-query-was-opened as logical no-undo .
for each tmp#zakaz :
  if (lookup('шту':U, tmp#zakaz.unit-cli-type) > 0
  or lookup('сер':U, tmp#zakaz.unit-cli-type) > 0 ) and
    tmp#zakaz.cli-qnty <> truncate(tmp#zakaz.cli-qnty, 0) then do:
    assign
      tmp#zakaz.cli-qnty = truncate(tmp#zakaz.cli-qnty, 0) + 1 .
    end.
  if (lookup('шту':U, tmp#zakaz.unit-type) > 0
  or lookup('сер':U, tmp#zakaz.unit-type) > 0 ) and
    tmp#zakaz.qnty <> truncate(tmp#zakaz.qnty, 0) then do:
    assign
      tmp#zakaz.qnty = truncate(tmp#zakaz.qnty, 0) + 1 .
    end.
  if tmp#zakaz.cli-base-rate = 0 or tmp#zakaz.cli-base-rate = ? then   do:
  find first ub.goods where
                         tmp#zakaz.artic = ub.goods.artic and
                         tmp#zakaz.prod-type = ub.goods.prod-type and
                         tmp#zakaz.prod-code = ub.goods.prod-code no-lock no-error  .
     if error-status :error then do:
        find first shar_ord-line   where
            shar_ord-line.doc-code        = loc-ord-num    and
            shar_ord-line.prod-type       = tmp#zakaz.prod-type and
            shar_ord-line.prod-code       = tmp#zakaz.prod-code and
            shar_ord-line.artic           = tmp#zakaz.artic   exclusive-lock  no-error.
         if available shar_ord-line  then  delete shar_ord-line  .
         delete tmp#zakaz.
         next.
         end.
     tmp#zakaz.cli-base-rate  = ub.goods.cli-base-rate.
  end.
end.
define variable sort-column-phrase as character no-undo .
case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.
case list-mode:
    when 'Контрагент,Обороты':U or when 'Контрагент,Остатки':U then do:
        assign frame dialog-frame:title =  " по фирме :" + v-cntxt-host-name-obj +
        ( if g#type = 'ОФ':U then  " ЗАЯВКА № "
        else
        " ЗАКАЗ  № "  )
        + loc-ord-num
        filter-point = "Заказ_поставщику_new".
        if t-action = "add":u then  frame dialog-frame:title = frame dialog-frame:title + "  - " + 'ДОБАВЛЕНИЕ':U.
        if t-action = "chg":u then  frame dialog-frame:title = frame dialog-frame:title + "  - " + 'ИЗМЕНЕНИЕ':U.
        if t-action = "lkp":u then  frame dialog-frame:title = frame dialog-frame:title + "  - " + 'ПРОСМОТР':U.
        open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code by tmp#zakaz.line-num .
    end.
end case.
run select-good-scala in this-procedure .
 apply "home" to br-docs in frame dialog-frame.
assign
      loc-cli-qnty    = 0
      loc-qnty        = 0
      loc-sum-base    = 0
      loc-sum-cli     = 0
      loc-sum-rubl    = 0
      loc-tot-lines   = 0
     .
for each tmp#zakaz :
assign
      loc-cli-qnty    = loc-cli-qnty  +  tmp#zakaz.cli-qnty
      loc-qnty        = loc-qnty      +  tmp#zakaz.qnty
      loc-sum-base    = loc-sum-base  +  tmp#zakaz.sum-base
      loc-sum-cli     = loc-sum-cli   +  tmp#zakaz.sum-cli
      loc-sum-rubl    = loc-sum-rubl  +  tmp#zakaz.sum-rubl
      loc-tot-lines   = loc-tot-lines + 1
     .
end.
display
  loc-cli-qnty
  loc-qnty
  loc-sum-base
  loc-sum-cli
  loc-sum-rubl
  loc-tot-lines
  with frame dialog-frame .
  if t-action = "lkp":U then run enable_ui_2 .
  t-ret =  session:set-wait-state("") .
  error-status :error = false .
end.
end procedure.
procedure set-filter-name :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  define input parameter p-filter-name as character no-undo .
  do with frame dialog-frame:
    if p-filter-name > "" then do:
      assign
        frame dialog-frame:title
          = frame dialog-frame:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :tooltip = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :tooltip = ""
      .
    end.
  end.
end.
end procedure.
procedure ex-file :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define input parameter ff as character no-undo .
define input parameter ex as logical no-undo .
  if ex = false then do:
      create "excel.application" chexcelapplication connect no-error.
     if error-status:error then
     do:
        create "excel.application" chexcelapplication no-error.
        if error-status :error then
        do:
           message
              "Ошибка при запуске Excel" skip
              error-status :get-message(1) skip
              view-as alert-box error .
           undo, return error .
        end.
     end.
    if ff = ""  then do:
      chworkbook   = chexcelapplication:workbooks:add( ).
    end.
    else do:
      chworkbook   = chexcelapplication:workbooks:open( ff ).
    end.
  end.
  assign     chexcelapplication:interactive = false      chexcelapplication:screenupdating = false      chexcelapplication:visible = false  .
  chworksheet  = chexcelapplication:sheets:item (1).
end.
end procedure.
procedure export-proc :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define input parameter numbersheet as integer no-undo .
define variable ii as integer init 6 no-undo.
t-ret =  session:set-wait-state("general") .
mm:
 repeat   :
    ii = ii  + 1.
        if numbersheet = 1 then do:
           if (chworksheet:range("a" + string(ii)):value ="" or chworksheet:range("a" + string(ii)):value = ?) then leave mm.
              run create-tmp in this-procedure  (input "excel":u , string (ii)  ).
           end.
        if numbersheet = 2 then do:
           if (chworksheet2:range("a" + string(ii)):value ="" or chworksheet2:range("a" + string(ii)):value = ?) then leave mm.
              run create-tmp in this-procedure  (input "excel2":u , string (ii)  ).
           end.
  end.
  if ii = 6 then disable  loc-cli-code loc-cli-type loc-obj-name r-clients with frame dialog-frame.
  t-ret =  session:set-wait-state("") .
  run openbr in this-procedure  .
  message "Импортировано " + string (ii - 7) + " товаров".
  end.
end.
procedure p-b-itogs :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  g#log = true  .
  tmp-rec = recid( tmp#zakaz ).
  do while available tmp#zakaz :
        get prev br-docs.
  end.
  run cus/z-tot.p
    (input parparentproc,
     input "":u,
     input date-1,
     input date-2) .
  reposition br-docs to recid tmp-rec no-error.
end.
end procedure.
procedure  b-import-excel :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   define variable ff as character no-undo.
   define variable var-name-sheet as character no-undo .
  message "Импорт из excel данных по заказу ."
  "При импорте используется работа с COM объектом Excel, поэтому не прерывайте работу Excel и не нарушайте уже законнекченную связь!"
  skip "Продолжать ?"
           view-as alert-box question
           buttons
           ok-cancel update g#log.
           if not g#log then return no-apply.
   var#import = true.
   chworkbook = chexcelapplication:activeworkbook no-error.
   g#log = false .
   if chworkbook = 0 or chworkbook = ? then  do:
        define variable okpressed as logical initial true no-undo.
        system-dialog get-file ff
            title      "Выберите файл ..."
            filters    "excel (*.xls)"   "*.xls"
                        use-filename
                        must-exist
                        update okpressed.
                        if okpressed = true then
                           do: run ex-file in this-procedure   (ff, false) . end.
                        else return no-apply .
   end.
   chworkbook = chexcelapplication:activeworkbook no-error.
   chworksheet  = chexcelapplication:sheets:item(1):select  no-error.
   chworksheet  = chexcelapplication:sheets:item(1) no-error.
   assign
   g#log = true  .
    var-name-sheet = chexcelapplication:sheets:item(1):name no-error.
    if   var-name-sheet = "Результат" then do:
    message "Начинаем экспорт  " skip
            "файл:  " chworkbook:fullname  skip
            "закладка: "  var-name-sheet  skip
            "Продолжить ? "
             view-as alert-box question buttons ok-cancel update g#log.
             if g#log = true then  run export-proc in this-procedure  (1).
        end.
   else do:
    message "Начинаем экспорт  " skip
            "Файл сделан не в системе 'ЗАКАЗЫ' !!! "
            "файл:  " chworkbook:fullname  skip
              "Продолжить ? "
             view-as alert-box question buttons ok-cancel update g#log.
             if g#log = true then  run export-proc in this-procedure  (1).
   end.
  RELEASE OBJECT chWorksheet2 NO-ERROR.
  RELEASE OBJECT chWorksheet NO-ERROR.
  RELEASE OBJECT chWorkbook NO-ERROR.
  chExcelApplication :QUIT().
  RELEASE OBJECT  chExcelApplication  NO-ERROR.
end.
end procedure.
procedure r-clients-ch :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define variable bttns     as   character no-undo.
define variable rid-list    as  character no-undo .
  run ref/cli-all.w (input parparentproc, input "b-sel", 'орг':U, ?, ?, ?, ?, ?, output  rid-list) no-error .
   if error-status :error or rid-list = '' then return error return-value .
    assign
     rep-rec = integer(rid-list)
     no-error.
  find first buf-cli where recid(buf-cli) = rep-rec no-lock no-error.
  if not( buf-cli.obj-type = 'орг':U or buf-cli.obj-type = 'чел':U ) then do:
    message "Заказать можно только у ОРГАНИЗАЦИЙ или Физ.лиц" view-as alert-box .
    return error return-value .
  end.
  find first ub.clients where recid(ub.clients) = rep-rec no-lock no-error.
  assign
  loc-cli-code = buf-cli.obj-code
  loc-cli-type = buf-cli.obj-type
  loc-obj-name = buf-cli.obj-name
  loc-cli-code:screen-value in frame dialog-frame = string( buf-cli.obj-code)
  loc-cli-type:screen-value in frame dialog-frame = buf-cli.obj-type
  loc-obj-name:screen-value in frame dialog-frame = buf-cli.obj-name no-error.
    if avail buf-cli then do:
        enable  b-spec  b-add b-way b-main-calc b-del b-chg b-producer b-alt-post b-export b-import with frame dialog-frame.
        disable
           loc-cli-code
           loc-cli-type
           loc-obj-name
           r-clients
           with frame dialog-frame.
          run ver-clients  in this-procedure ( input loc-cli-type , input loc-cli-code , output v-err) .
          if  v-err then return error.
    end.
    else return error .
    display loc-cli-code loc-cli-type loc-obj-name
    with frame dialog-frame.
end.
end procedure.
procedure b-export-ch :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  message "Экспорт в excel ." skip "Продолжать ?"
           view-as alert-box question buttons ok-cancel update g#log.
           if not g#log then return no-apply.
      run cus/z-tot1.p (PARPARENTPROC , loc-ord-num , v-cntxt-obj-type , v-cntxt-obj-code ).
end.
end procedure.
procedure leave-loc-cli-code.
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
 assign frame dialog-frame loc-cli-code loc-cli-type .
 if v-fl = false  then do:
  assign frame dialog-frame loc-cli-code  .
    if loc-cli-type = ? or loc-cli-type = "" then loc-cli-type = 'орг':U .
    find first buf-cli no-lock where  buf-cli.obj-type = loc-cli-type
                                  and buf-cli.obj-code = loc-cli-code  no-error.
    rep-rec = recid (buf-cli) no-error.
    find first ub.clients where recid(ub.clients) = rep-rec no-lock no-error.
    if avail ub.clients then do:
          loc-obj-name = ub.clients.obj-name .
          display  loc-cli-code loc-cli-type loc-obj-name with frame dialog-frame.
          enable   b-spec b-add b-way b-main-calc b-del b-chg b-producer b-alt-post b-export b-import with frame dialog-frame.
          disable  loc-cli-code loc-cli-type loc-obj-name r-clients  with frame dialog-frame.
        end.
        else do:
          assign
          loc-obj-name:screen-value = ""
          loc-cli-type:screen-value = ""
          loc-cli-code:screen-value = ?
          .
          disable b-add b-way b-del b-chg b-producer b-alt-post b-main-calc b-export b-import with frame dialog-frame.
          return error .
        end.
 end.
 else v-fl = false .
  assign
  is-edoc-nn-doc = status-is-edoc-nn ( input is-edoc-nn
                                      , input loc-cli-type
                                      , input loc-cli-code
                                      , input loc-store-type
                                      , input loc-store-code
                                      ) .
  assign
  is-edi-doc = status-is-edi ( input is-edi
                              , input loc-cli-type
                              , input loc-cli-code
                              , input loc-store-type
                              , input loc-store-code
                              , output v-dm-edi
                              ) .
end.
end procedure.
procedure leave-loc-cli-type :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  assign frame dialog-frame loc-cli-type .
  if loc-cli-code <> ? or loc-cli-code <> 0 then do:
    find first buf-cli where loc-cli-type = buf-cli.obj-type  and loc-cli-code = buf-cli.obj-code  no-lock no-error.
    rep-rec = recid(buf-cli)  no-error.
    find first ub.clients where recid ( ub.clients) = rep-rec no-lock no-error.
    if available ub.clients then do:
        loc-obj-name = ub.clients.obj-name .
        display  loc-cli-code loc-cli-type loc-obj-name with frame dialog-frame.
        enable b-spec b-add b-way b-del b-chg b-producer b-alt-post b-main-calc with frame dialog-frame.
        end.
        else do:
          assign
          loc-obj-name:screen-value = ""
          loc-cli-type:screen-value = ""
          loc-cli-code:screen-value = ?
          .
          message "Неправильно задан код или тип Поставщика !".
          disable b-add b-way b-del b-chg b-producer b-alt-post b-main-calc with frame dialog-frame.
        end.
    end.
  assign
  is-edoc-nn-doc = status-is-edoc-nn ( input is-edoc-nn
                                      , input loc-cli-type
                                      , input loc-cli-code
                                      , input loc-store-type
                                      , input loc-store-code
                                      ) .
  assign
  is-edi-doc = status-is-edi ( input is-edi
                              , input loc-cli-type
                              , input loc-cli-code
                              , input loc-store-type
                              , input loc-store-code
                              , output v-dm-edi
                              ) .
end.
end procedure.
procedure choose-menu-add1 :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if lookup( date-sale-2 :type in frame dialog-frame
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" date-sale-2 :name  in frame dialog-frame skip
    "Тип" date-sale-2 :type  in frame dialog-frame skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to date-sale-2  in frame dialog-frame .
  assign frame dialog-frame LOC-DATE-SHIP
                             DATE-sale-1
                             DATE-sale-2
                             doc-date
                             .
end.
define variable ii as integer init 0 no-undo.
define variable r-tmp as recid no-undo .
define variable r-stop as logical no-undo .
define variable r-exit as logical no-undo .
if g#type = 'ОФ':U then do:
   message "Режим не доступен для Заявок."  view-as alert-box information.
   return.
   end.
t-ret =  session:set-wait-state("general") .
 line-mode = 'ДОБАВЛЕНИЕ':U .
  find first buf-cli where recid(buf-cli) = rep-rec no-lock no-error.
  for each sb-cli-gds where sb-cli-gds.host-code = v-cntxt-host-code-obj
                            and sb-cli-gds.cli-type = buf-cli.obj-type
                            and sb-cli-gds.cli-code = buf-cli.obj-code
                            and ( sb-cli-gds.cancel-date = ?  or  sb-cli-gds.cancel-date > to-day ) no-lock :
     find first ub.goods  where ub.goods.prod-type = sb-cli-gds.prod-type and
                                ub.goods.prod-code = sb-cli-gds.prod-code and
                                ub.goods.artic =     sb-cli-gds.artic no-lock no-error.
     ii = ii  + 1.
     if ii > 1 then assign line-mode = "ЦИКЛ":u.
     run create-tmp in this-procedure  (input "price":u ,"") no-error .
      if not  error-status :error  and not t-auto then do:
            run cus/ord-frm.w ( input ParParentProc,  input recid ( tmp#zakaz ) , input line-mode , output r-stop , output r-exit) .
            if r-stop then do:
               run p-delete( recid ( tmp#zakaz ) ,input-output ii ) .
               leave.
               end.
            if r-exit then do:
               run p-delete( recid ( tmp#zakaz ) ,input-output ii ) .
               end.
        end.
  end.
  if ii > 0 then disable  loc-cli-code loc-cli-type loc-obj-name r-clients with frame dialog-frame.
  t-ret =  session:set-wait-state("") .
  run openbr in this-procedure  .
  reposition br-docs to recid tmp-rec no-error.
  message "Добавлено по поставщику " + string (ii) + " товаров".
end.
end procedure.
procedure apply-focus-next-entry :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  define input parameter p-widget-handle as handle no-undo .
  define variable l-apply-entry as logical no-undo .
  assign
    l-apply-entry =   true
  .
  do with frame dialog-frame:
  if loc-cli-type :handle = p-widget-handle then do:   if loc-cli-code :sensitive then do:  apply "entry":u to loc-cli-code. return . end. end.
  if loc-cli-code :handle = p-widget-handle then do:   if wrkr         :sensitive then do:  apply "entry":u to wrkr        . return . end. end.
  if wrkr    :handle       = p-widget-handle then do:  if agnt         :sensitive then do:  apply "entry":u to agnt        . return . end. end.
  if agnt    :handle = p-widget-handle then do:        if boss         :sensitive then do:  apply "entry":u to boss        . return . end. end.
  if boss    :handle = p-widget-handle then do:
             if paytype      :sensitive then do:
                apply "entry":u to paytype     . return .
             end.
             else do:
                apply "entry":u to  b-add  . return .
             end.
  end.
  if paytype :handle = p-widget-handle then do:      if b-add  :sensitive then do:  apply "choose":u to b-add .  return . end. end.
  if r-contract :handle = p-widget-handle then do:   if b-spec :sensitive then do:  apply "choose":u to b-spec . return . end. end.
  end.
end.
end procedure.
procedure create-tmp-dtl :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  if not avail  shar_ord-doc  then return.
        for each shar_ord-dtl where shar_ord-dtl.doc-code = shar_ord-doc.doc-code no-lock :
          find first ub.gds-prt where ub.gds-prt.node-code =  shar_ord-dtl.node-code no-lock no-error .
          if avail ub.gds-prt then do :
           create tmp#zakaz-dtl no-error.
           if error-status :error then do:
              find first  tmp#zakaz-dtl where
                    tmp#zakaz-dtl.artic       = shar_ord-dtl.artic     and
                    tmp#zakaz-dtl.prod-code   = shar_ord-dtl.prod-code and
                    tmp#zakaz-dtl.prod-type   = shar_ord-dtl.prod-type and
                    tmp#zakaz-dtl.node-code   = shar_ord-dtl.node-code no-error .
              end.
           assign
              tmp#zakaz-dtl.prt-name               = ub.gds-prt.f-name
              tmp#zakaz-dtl.artic                  = shar_ord-dtl.artic
              tmp#zakaz-dtl.prod-code              = shar_ord-dtl.prod-code
              tmp#zakaz-dtl.prod-type              = shar_ord-dtl.prod-type
              tmp#zakaz-dtl.node-code              = shar_ord-dtl.node-code
              tmp#zakaz-dtl.cancel-cli-qnty        = shar_ord-dtl.cancel-cli-qnty
              tmp#zakaz-dtl.cancel-qnty            = shar_ord-dtl.cancel-qnty
              tmp#zakaz-dtl.qnty                   = shar_ord-dtl.qnty
              tmp#zakaz-dtl.cli-qnty               = shar_ord-dtl.cli-qnty
              tmp#zakaz-dtl.doc-code               = shar_ord-dtl.doc-code
              tmp#zakaz-dtl.initial-cli-qnty       = shar_ord-dtl.initial-cli-qnty
              tmp#zakaz-dtl.initial-qnty           = shar_ord-dtl.initial-qnty
              tmp#zakaz-dtl.add-cli-qnty           = shar_ord-dtl.add-cli-qnty
              tmp#zakaz-dtl.add-qnty               = shar_ord-dtl.add-qnty
              tmp#zakaz-dtl.order-cli-qnty         = shar_ord-dtl.order-cli-qnty
              tmp#zakaz-dtl.order-qnty             = shar_ord-dtl.order-qnty
              tmp#zakaz-dtl.price-base             = shar_ord-dtl.price-base
              tmp#zakaz-dtl.price-cli              = shar_ord-dtl.price-cli
              tmp#zakaz-dtl.price-rubl             = shar_ord-dtl.price-rubl
              tmp#zakaz-dtl.receive-cli-qnty       = shar_ord-dtl.receive-cli-qnty
              tmp#zakaz-dtl.receive-qnty           = shar_ord-dtl.receive-qnty
              tmp#zakaz-dtl.sum-base               = shar_ord-dtl.sum-base
              tmp#zakaz-dtl.sum-cli                = shar_ord-dtl.sum-cli
              tmp#zakaz-dtl.sum-rubl               = shar_ord-dtl.sum-rubl
              no-error  .
             if error-status :error then message 'error create tmp#zakaz-dtl'.
              find first  tmp#zakaz where
                    tmp#zakaz.artic       = shar_ord-dtl.artic     and
                    tmp#zakaz.prod-code   = shar_ord-dtl.prod-code and
                    tmp#zakaz.prod-type   = shar_ord-dtl.prod-type
                    no-error .
               if avail tmp#zakaz then
               assign tmp#zakaz.prt-ok   =   true .
           end.
  end.
end.
end procedure.
procedure select-good-scala :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  find current shar_ord-line  no-lock  no-error .
  if not avail shar_ord-line then return.
  find first TMP#zakaz no-lock    where
              shar_ord-line.prod-type       = tmp#zakaz.prod-type and
              shar_ord-line.prod-code       = tmp#zakaz.prod-code and
              shar_ord-line.artic           = tmp#zakaz.artic        no-error  .
  if not avail TMP#zakaz   then do:
     return.
  end.
assign
    x-prod-type = tmp#zakaz.prod-type
    x-prod-code = tmp#zakaz.prod-code
    x-artic     = tmp#zakaz.artic
    .
open query br-docs-2 for each tmp#zakaz-dtl no-lock where tmp#zakaz-dtl.artic = x-artic and tmp#zakaz-dtl.prod-type = x-prod-type and tmp#zakaz-dtl.prod-code = x-prod-code .
  find first for-cli no-lock where for-cli.obj-type = tmp#zakaz.prod-type and
                                   for-cli.obj-code = tmp#zakaz.prod-code no-error.
  if avail for-cli then do:
      display for-cli.obj-name      @ prod-name
              tmp#zakaz.gds-name    @ goods-name
              with frame dialog-frame .
  end.
  else do:
      display "" @ prod-name  with frame dialog-frame.
  end.
  if error-status :error  then message "123-" error-status :error.
end.
end procedure .
procedure check-exch :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  find ub.currency where ub.currency.curr-code = (input frame dialog-frame loc-exch-code   ) no-lock no-error.
  if not available ub.currency then do:
    message "Неправильная валюта поставщика - такой валюты нет.".
    apply "entry" to loc-exch-code in frame dialog-frame.
    return error.
  end.
  if loc-exch-code <> ub.currency.curr-code then do:
    if ub.currency.curr-code = 0 then do:
      if (loc-exch-rate <> ? and loc-exch-scale <> ? and
          (loc-exch-rate <> 1 or loc-exch-scale <> 1)) then do:
        g#log = no.
        message "Пересчитать цены поставщика в рубли по курсу поставщика ?"
                        view-as alert-box question buttons yes-no update g#log.
        if g#log then do:
          run waitfram-show ("Пересчет цен поставщика в рубли. Ждите...").
          for each tmp#zakaz where :
            tmp#zakaz.price-cli = tmp#zakaz.price-cli * loc-exch-rate / loc-exch-scale.
          end.
          run waitfram-hide.
        end.
      end.
      loc-print-rubl = yes.
      assign
        loc-exch-rate = 1
        loc-exch-scale = 1
        .
      disable loc-exch-rate loc-exch-scale r-acc with frame dialog-frame.
    end.
    else do:
      find last ub.curr-accnt where ub.curr-accnt.curr-code = ub.currency.curr-code
                             use-index pi no-lock no-error.
      if available ub.curr-accnt then assign
          loc-exch-rate = ub.curr-accnt.exch-rate
          loc-exch-scale = ub.curr-accnt.exch-scale.
      else assign
          loc-exch-rate = ?
          loc-exch-scale = ?.
      if loc-exch-code = 0 and
        (loc-exch-rate  <> ? and
         loc-exch-scale <> ? and
         (loc-exch-rate <> 1 or loc-exch-scale <> 1)
        ) then do:
        g#log = no.
        message "Пересчитать цены поставщика в валюту ГТД по курсу ММВБ (справочника) ?"
                        view-as alert-box question buttons yes-no update g#log.
        if g#log then do:
          run waitfram-show ("Пересчет цен поставщика в валюту ГТД. Ждите...").
            for each tmp#zakaz where  :
            tmp#zakaz.price-cli = tmp#zakaz.price-cli / loc-exch-rate * loc-exch-scale.
          end.
          run waitfram-hide.
        end.
      end.
      loc-print-rubl = no.
      enable loc-exch-rate loc-exch-scale r-acc with frame dialog-frame.
    end.
     loc-exch-code = ub.currency.curr-code.
     run enable_Ui.
      enable b-add b-way b-main-calc b-del b-chg b-producer b-alt-post b-export b-import  with frame dialog-frame .
      disable  loc-cli-code loc-cli-type r-clients  with frame dialog-frame .
  end.
end.
end procedure.
procedure row-leave-br-doc :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  find current shar_ord-line  no-lock  no-error .
       if not avail shar_ord-line then return.
  find first TMP#zakaz no-lock    where
            tmp#zakaz.prod-type = shar_ord-line.prod-type       and
            tmp#zakaz.prod-code = shar_ord-line.prod-code       and
            tmp#zakaz.artic     = shar_ord-line.artic           no-error  .
  if not avail TMP#zakaz   then do:
       message  vss-workfile vss-revision vss-description skip
        error-status :get-message(1)    skip
       "Ни чего не могу найти !!!".
       return.
       end.
  if (lookup('шту':U, tmp#zakaz.unit-cli-type) > 0
  or lookup('сер':U, tmp#zakaz.unit-cli-type) > 0 ) and
     dec(tmp#zakaz.cli-qnty:screen-value in browse br-docs) <> truncate(dec(tmp#zakaz.cli-qnty:screen-value in browse br-docs), 0) then do:
        message "Количество заказа не может быть дробным ! " view-as alert-box .
          tmp#zakaz.cli-qnty:screen-value in browse br-docs = string(truncate(dec(tmp#zakaz.cli-qnty:screen-value in browse br-docs), 0) + 1).
  end.
  if not current-changed(tmp#zakaz) then
  assign tmp#zakaz.cli-art = tmp#zakaz.cli-art:screen-value in browse br-docs
         tmp#zakaz.cli-qnty = decimal(tmp#zakaz.cli-qnty:screen-value in browse br-docs)
         tmp#zakaz.sum-cli  = tmp#zakaz.cli-qnty * tmp#zakaz.price-cli
         tmp#zakaz.sum-cli:screen-value in browse br-docs = string (tmp#zakaz.sum-cli , "->>>>>>>>>>>9.99") no-error.
end.
end procedure.
procedure make-obj-list :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    if x-mode = "obj":u then do:
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input v-cntxt-obj-type ,
   input v-cntxt-obj-code )
  no-error .
    end.
    else do:
      for each ub.shop where ub.shop.host-code   = v-cntxt-host-code-obj:
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input 'маг':U ,
   input ub.shop.obj-code )
  no-error .
      end.
      for each ub.store where ub.store.host-code  = v-cntxt-host-code-obj:
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input 'скл':U ,
   input ub.store.obj-code )
  no-error .
      end.
     end.
end.
end procedure.
procedure val-ch-type:
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define input parameter parself-name as character no-undo.
if caps(parself-name) = "slt_type" then run val-ch-slt-type no-error.
else do:
   if caps(parself-name) = "vat_type" then run val-ch-vat-type no-error.
      else do:
          message "Неверный self:name " parself-name
                  " при передаче в процедуру val-ch-type."
          view-as alert-box error.
          return error.
      end.
end.
if error-status:error then do:
      display slt_type with frame dialog-frame.
      display vat_type with frame dialog-frame.
      return no-apply.
end.
end.
end procedure.
procedure r-proc-currency :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
assign
ref-rec = ?.
run ref/currency.w ( input parparentproc, "b-sel", input-output ref-rec ).
if ref-rec = ? then return .
find ub.currency where recid ( ub.currency ) = ref-rec no-lock.
  if ub.currency.curr-code <> loc-exch-code then do:
    run check-update no-error.
    if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          ""
          view-as alert-box error
        .
       return error.
    end.
  end.
run exch-rate.
run full-recount.
display loc-sum-rubl
       loc-sum-base
       loc-sum-cli
       loc-exch-code
       with frame dialog-frame .
run openbr in this-procedure  .
end.
end procedure.
procedure update-rate-doc:
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
if input frame dialog-frame loc-exch-rate  <> loc-exch-rate  or
   input frame dialog-frame loc-exch-scale <> loc-exch-scale or
   input frame dialog-frame loc-base-rate  <> loc-base-rate  or
   input frame dialog-frame loc-base-scale <> loc-base-scale then
   do transaction on error     undo, return error
                    on end-key undo, return error
                    on stop    undo, return error :
     run check-exch.
     run check-update.
     run check-rate.
    end.
    run ui-on .
end.
end procedure.
procedure choice-currency:
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
assign frame  dialog-frame cycle-day loc-date-ship  loc-service date-sale-1 date-sale-2 .
find ub.currency where ub.currency.curr-code = input frame dialog-frame loc-exch-code no-error.
if not available ub.currency then do:
  assign
  ref-rec = ?.
  run ref/currency.w ( input parparentproc, "b-sel", input-output ref-rec ).
  if ref-rec = ? then return error.
  find ub.currency where recid ( ub.currency ) = ref-rec.
end.
run exch-rate.
end.
end procedure.
procedure exch-rate:
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
disp ub.currency.curr-code @ loc-exch-code with frame dialog-frame.
do transaction on error   undo, return no-apply
               on end-key undo, return no-apply
               on stop    undo, return no-apply:
   run check-exch.
   run check-rate.
   run full-recount.
        display loc-sum-rubl
                loc-sum-base
                loc-sum-cli
                loc-exch-code
                with frame dialog-frame .
          run openbr in this-procedure  .
end.
run ui-on .
end.
end procedure.
procedure full-recount:
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define variable     varprice-cli                    like ub.doc-line.price-base no-undo .
define variable     varprice-cli-unit-base          like ub.doc-line.price-base no-undo .
define variable     varprice-road-tax               like ub.doc-line.price-base no-undo .
define variable     varprice-other-exp              like ub.doc-line.price-base no-undo .
define variable     varprice-transport-exp          like ub.doc-line.price-base no-undo .
define variable     varprice-without-abs            like ub.doc-line.price-base no-undo .
define variable     varprice-slt                    like ub.doc-line.price-base no-undo .
define variable     varprice-no-slt                 like ub.doc-line.price-base no-undo .
define variable     varprice-vat                    like ub.doc-line.price-base no-undo .
define variable     varprice-no-vat-slt             like ub.doc-line.price-base no-undo .
define variable     varprice-rubl                   like ub.doc-line.price-base no-undo .
define variable     varprice-road-tax-rubl          like ub.doc-line.price-base no-undo .
define variable     varprice-other-exp-rubl         like ub.doc-line.price-base no-undo .
define variable     varprice-transport-exp-rubl     like ub.doc-line.price-base no-undo .
define variable     varprice-without-abs-rubl       like ub.doc-line.price-base no-undo .
define variable     varprice-slt-rubl               like ub.doc-line.price-base no-undo .
define variable     varprice-no-slt-rubl            like ub.doc-line.price-base no-undo .
define variable     varprice-vat-rubl               like ub.doc-line.price-base no-undo .
define variable     varprice-no-vat-slt-rubl        like ub.doc-line.price-base no-undo .
define variable     varprice-base                   like ub.doc-line.price-base no-undo .
define variable     varprice-road-tax-base          like ub.doc-line.price-base no-undo .
define variable     varprice-other-exp-base         like ub.doc-line.price-base no-undo .
define variable     varprice-transport-exp-base     like ub.doc-line.price-base no-undo .
define variable     varprice-without-abs-base       like ub.doc-line.price-base no-undo .
define variable     varprice-slt-base               like ub.doc-line.price-base no-undo .
define variable     varprice-no-slt-base            like ub.doc-line.price-base no-undo .
define variable     varprice-vat-base               like ub.doc-line.price-base no-undo .
define variable     varprice-no-vat-slt-base        like ub.doc-line.price-base no-undo .
   assign
      loc-sum-rubl  = 0
      loc-sum-base  = 0
      loc-sum-cli   = 0
   .
for each tmp#zakaz  :
    if vat_type = 'без':U then  do:
       tmp#zakaz.vat-pc = 0.
    end.
    if slt_type = 'без':U then  do:
       tmp#zakaz.slt-pc = 0.
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   'zakaz':u
  ,input   loc-base-rate
  ,input   loc-base-scale
  ,input   loc-exch-rate
  ,input   loc-exch-scale
  ,input   vat_type
  ,input   slt_type
  ,input   tmp#zakaz.artic
  ,input   tmp#zakaz.prod-type
  ,input   tmp#zakaz.prod-code
  ,input   tmp#zakaz.price-cli
  ,input   tmp#zakaz.cli-base-rate
  ,input   tmp#zakaz.price-rubl
  ,input   tmp#zakaz.vat-pc
  ,input   tmp#zakaz.slt-pc
  ,input   tmp#zakaz.road-tax
  ,input   tmp#zakaz.transport-rubl
  ,input   tmp#zakaz.other-rubl
  ,output  varprice-cli
  ,output  varprice-cli-unit-base
  ,output  varprice-road-tax
  ,output  varprice-other-exp
  ,output  varprice-transport-exp
  ,output  varprice-without-abs
  ,output  varprice-slt
  ,output  varprice-no-slt
  ,output  varprice-vat
  ,output  varprice-no-vat-slt
  ,output  varprice-rubl
  ,output  varprice-road-tax-rubl
  ,output  varprice-other-exp-rubl
  ,output  varprice-transport-exp-rubl
  ,output  varprice-without-abs-rubl
  ,output  varprice-slt-rubl
  ,output  varprice-no-slt-rubl
  ,output  varprice-vat-rubl
  ,output  varprice-no-vat-slt-rubl
  ,output  varprice-base
  ,output  varprice-road-tax-base
  ,output  varprice-other-exp-base
  ,output  varprice-transport-exp-base
  ,output  varprice-without-abs-base
  ,output  varprice-slt-base
  ,output  varprice-no-slt-base
  ,output  varprice-vat-base
  ,output  varprice-no-vat-slt-base
  ) no-error.
  if error-status:error then do:
     return error substitute("Ошибка при пересчете линии ЗАКАЗА , &1" , return-value  ) .
  end.
  assign tmp#zakaz.price-cli  = round(varprice-cli,2)
         tmp#zakaz.price-rubl = round(varprice-rubl,2)
         tmp#zakaz.price-base = round(varprice-base,2)
         tmp#zakaz.sum-vat    = if var-report-r-b = "rubl" then round(varprice-vat-rubl,2)
                                                           else round(varprice-vat-base,2)
         tmp#zakaz.sum-cli    = round(varprice-cli ,2) * tmp#zakaz.cli-qnty
         tmp#zakaz.sum-rubl   = round(varprice-rubl,2) * tmp#zakaz.qnty
         tmp#zakaz.sum        = round(varprice-rubl,2) * tmp#zakaz.qnty
         tmp#zakaz.sum-base   = round(varprice-base,2) * tmp#zakaz.qnty
         .
    find first shar_ord-line  exclusive-lock   where
        shar_ord-line.doc-code   = loc-ord-num    and
        shar_ord-line.prod-type  = tmp#zakaz.prod-type and
        shar_ord-line.prod-code  = tmp#zakaz.prod-code and
        shar_ord-line.artic      = tmp#zakaz.artic
        no-error  .
    if not available shar_ord-line then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "Ошибка!"
      view-as alert-box error
    .
  assign shar_ord-line.price-cli  = round(varprice-cli ,2)
         shar_ord-line.price-rubl = round(varprice-rubl,2)
         shar_ord-line.price-base = round(varprice-base,2)
         shar_ord-line.sum-vat    = if var-report-r-b = "rubl" then round(varprice-vat-rubl ,2 )
                                                               else round(varprice-vat-base ,2 )
         shar_ord-line.sum-cli    = round(varprice-cli ,2) * shar_ord-line.cli-qnty
         shar_ord-line.sum-rubl   = round(varprice-rubl,2) * shar_ord-line.qnty
         shar_ord-line.sum-base   = round(varprice-base,2) * shar_ord-line.qnty
         shar_ord-line.vat-pc     = tmp#zakaz.vat-pc
         shar_ord-line.slt-pc     = tmp#zakaz.slt-pc
         .
   assign
      loc-sum-rubl  = loc-sum-rubl + shar_ord-line.sum-rubl
      loc-sum-base  = loc-sum-base + shar_ord-line.sum-base
      loc-sum-cli   = loc-sum-cli  + shar_ord-line.sum-cli
   .
  end.
 end.
end procedure.
procedure check-rate :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define variable flag-recount as logical initial no no-undo.
if input frame dialog-frame loc-exch-rate  <> loc-exch-rate  or
   input frame dialog-frame loc-exch-scale <> loc-exch-scale or
   input frame dialog-frame loc-base-rate  <> loc-base-rate  or
   input frame dialog-frame loc-base-scale <> loc-base-scale then flag-recount = yes.
if input frame dialog-frame loc-base-rate = ? or
   input frame dialog-frame loc-base-rate = 0 then do:
  message "Не задан курс базовой валюты.".
  apply "entry" to loc-base-rate in frame dialog-frame.
  return error.
end.
if input frame dialog-frame loc-base-scale = ? or
   input frame dialog-frame loc-base-scale = 0 then do:
  message "Не задан масштаб базовой валюты.".
  apply "entry" to loc-base-scale in frame dialog-frame.
  return error.
end.
assign  frame dialog-frame
  loc-base-rate
  loc-base-scale.
if input frame dialog-frame loc-exch-rate = ? or
   input frame dialog-frame loc-exch-rate = 0 then do:
  message "Не задан курс валюты поставщика.".
  apply "entry" to loc-exch-rate in frame dialog-frame.
  return error.
end.
if input frame dialog-frame loc-exch-scale = ? or
   input frame dialog-frame loc-exch-scale = 0 then do:
  message "Не задан масштаб валюты поставщика.".
  apply "entry" to loc-exch-scale in frame dialog-frame.
  return error.
end.
assign
  loc-exch-rate
  loc-exch-scale.
run waitfram-show ("ЖДИТЕ.  Пересчет документа ...").
if flag-recount then do:
   run full-recount.
 display loc-sum-rubl
        loc-sum-base
        loc-sum-cli
        loc-exch-code
        with frame dialog-frame .
  run openbr in this-procedure  .
end.
run waitfram-hide.
end.
end procedure.
procedure val-ch-vat-type:
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define buffer d-l-b    for tmp#zakaz.
define buffer bf-goods for ub.goods.
define variable old-vat         like ub.trn-doc.vat-type .
define variable v-vat-pc        like ub.doc-line.vat-pc    no-undo.
define variable v-host-code     like ub.sysconf.host-code  no-undo.
  run check-update no-error.
  if error-status:error then return error.
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  loc-store-type
  ,input  loc-store-code
  ,output v-host-code
  )  .
  assign
    old-vat = vat_type
  .
  assign frame dialog-frame vat_type.
  find first d-l-b no-lock no-error.
  if available d-l-b then do:
     if vat_type = 'без':U and
        old-vat <> 'без':U then do:
        message "НДС в строках устанавливаем в 0" view-as alert-box information.
        for each d-l-b :
            assign d-l-b.vat-pc = 0.
        end.
     end.
     else if vat_type <> 'без':U and
             old-vat  =  'без':U then do:
        message "НДС в строках устанавливаем из товара " view-as alert-box information.
        for each d-l-b ,
                 first bf-goods where bf-goods.artic     = d-l-b.artic and
                                      bf-goods.prod-type = d-l-b.prod-type and
                                      bf-goods.prod-code = d-l-b.prod-code:
define variable vss-include-info80 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf-goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  loc-store-type
  ,input  loc-store-code
  ,output v-vat-pc
  ) no-error .
            assign d-l-b.vat-pc = v-vat-pc.
        end.
     end.
    end.
    run check-rate no-error.
    if error-status:error then  message      error-status :get-message(1) skip 1 .
    run full-recount no-error.
    if error-status:error then  message      error-status :get-message(1) skip 2 .
 display loc-sum-rubl
        loc-sum-base
        loc-sum-cli
        loc-exch-code
        with frame dialog-frame .
  run openbr in this-procedure  .
  run ui-on.
end.
end procedure.
procedure val-ch-slt-type:
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define buffer d-l-b    for tmp#zakaz.
define buffer bf-goods for ub.goods.
define variable old-slt         like ub.trn-doc.slt-type .
define variable v-slt-pc        like ub.doc-line.slt-pc    no-undo.
define variable v-host-code     like ub.sysconf.host-code  no-undo.
  run check-update no-error.
  if error-status:error then return error.
define variable vss-include-info81 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  loc-store-type
  ,input  loc-store-code
  ,output v-host-code
  )  .
  assign
    old-slt = slt_type
  .
  assign frame dialog-frame slt_type.
  find first d-l-b no-lock no-error.
  if available d-l-b then do:
     if slt_type = 'без':U and
        old-slt <> 'без':U then do:
        message "Налог с продаж в строках устанавливаем в 0" view-as alert-box information.
        for each d-l-b :
            assign d-l-b.slt-pc = 0.
        end.
     end.
     else if slt_type <> 'без':U and
             old-slt = 'без':U then do:
        message "Налог с продаж в строках устанавливаем из товара " view-as alert-box information.
        for each d-l-b ,
                 first bf-goods where bf-goods.artic     = d-l-b.artic and
                                      bf-goods.prod-type = d-l-b.prod-type and
                                      bf-goods.prod-code = d-l-b.prod-code:
define variable vss-include-info82 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf-goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  v-host-code
  ,input  loc-store-type
  ,input  loc-store-code
  ,output v-slt-pc
  ) no-error .
            assign d-l-b.slt-pc = v-slt-pc.
        end.
     end.
     run check-rate no-error.
     if error-status :error then message error-status:error error-status :get-message(1)  skip 3.
     run full-recount no-error.
     if error-status :error then message error-status:error error-status :get-message(1)  skip 4 .
      display loc-sum-rubl
              loc-sum-base
              loc-sum-cli
              loc-exch-code
              with frame dialog-frame .
        run openbr in this-procedure  .
  end.
run ui-on .
end.
end procedure.
procedure check-update:
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
assign frame  dialog-frame cycle-day loc-date-ship  loc-service date-sale-1 date-sale-2 loc-cli-out-doc.
  define buffer ch-ord-line for tmp#zakaz.
  define buffer ch-goods    for ub.goods.
  define buffer ch-units    for ub.units.
  define variable p-same-price as logical no-undo.
  define variable v-insalepr   as logical   no-undo .
  for each ch-ord-line :
      find first ch-goods where ch-goods.artic     = ch-ord-line.artic     and
                                ch-goods.prod-type = ch-ord-line.prod-type and
                                ch-goods.prod-code = ch-ord-line.prod-code no-lock.
      find ch-units where ch-units.unit-name = ch-goods.unit-base no-lock.
define variable vss-include-info83 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ch-ord-line.obj-type
  ,input  ch-ord-line.obj-code
  ,input  ch-ord-line.artic
  ,input  ch-ord-line.prod-type
  ,input  ch-ord-line.prod-code
  ,input  'insalepr=request':U
  ,output v-insalepr
  )  .
      if v-insalepr = true then do:
         message "Товар " ch-goods.artic " " ch-goods.prod-type " " ch-goods.prod-code
                 " принимается по продажной цене. Смена цен недопустима."
                 view-as alert-box error.
         return error.
      end.
  end.
end.
end procedure.
procedure disp-exch:
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
display
 loc-exch-rate
 loc-exch-scale
 loc-base-rate
 loc-base-scale
 with frame dialog-frame.
 end.
end procedure.
procedure r-acc-proc :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
run check-update no-error.
if error-status:error then return no-apply.
run check-exch no-error.
if error-status:error then return no-apply.
g#log = yes.
message "Подставить БИРЖЕВЫЕ курсы базовой валюты :" base-abbr "и валюты поставщика :"
                 ub.currency.curr-abbr "на дату растаможивания ?"
                  view-as alert-box question buttons ok-cancel
                  update g#log.
if g#log <> true then return no-apply.
find last ub.curr-accnt where ub.curr-accnt.curr-code = base-code
        use-index pi no-lock no-error.
if not available ub.curr-accnt then do:
  message "На эту дату неизвестен курс базовой валюты.".
  apply "entry" to loc-base-rate in frame dialog-frame.
  return no-apply.
end.
     loc-base-rate  = ub.curr-accnt.exch-rate .
     loc-base-scale = ub.curr-accnt.exch-scale.
     loc-base-rate:screen-value  = string(curr-accnt.exch-rate) .
     loc-base-scale:screen-value = string(curr-accnt.exch-scale).
display loc-base-rate
        loc-base-scale
     with frame d-in-doc.
find last ub.curr-accnt where ub.curr-accnt.curr-code = input loc-exch-code
           use-index pi no-lock no-error.
if not available ub.curr-accnt then do:
  message "На дату "  + " неизвестен курс валюты поставщика.".
  apply "entry" to loc-exch-rate.
  return no-apply.
end.
 loc-exch-rate  = ub.curr-accnt.exch-rate .
 loc-exch-scale = ub.curr-accnt.exch-scale.
 loc-exch-rate:screen-value  = string(curr-accnt.exch-rate ).
 loc-exch-scale:screen-value = string(curr-accnt.exch-scale).
disp loc-exch-rate
     loc-exch-scale with frame d-in-doc.
run check-rate.
run ui-on.
run disp-exch.
end.
end procedure.
procedure ui-on :
 do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
run vg-TOG-type.
hide loc-art in frame dialog-frame
 loc-name
 loc-code .
 loc-art  = "" .
if g#type <> 'ОФ':U then do:
    if curclivalue <> "no" then do:
            if loc-exch-code <> 0 then enable r-acc loc-exch-rate loc-exch-scale with frame dialog-frame.
            enable loc-exch-code r-currency with frame dialog-frame.
    end.
    else do:
          hide r-acc r-currency in frame dialog-frame.
    end.
    enable loc-base-rate loc-base-scale with frame dialog-frame.
    if curclivalue <> "no" then do:
            find ub.currency where ub.currency.curr-code = loc-exch-code no-lock no-error.
            if available ub.currency then disp ub.currency.curr-abbr with frame dialog-frame.
                                  else disp ? @ ub.currency.curr-abbr with frame dialog-frame.
    end.
    else DO:
      hide ub.currency.curr-abbr in frame dialog-frame.
    END.
if multdtypvalue <> "no"
    then enable  vat_type slt_type with frame dialog-frame.
    else disable  vat_type slt_type with frame dialog-frame.
end.
end.
end procedure .
procedure paytype-leave-proc:
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define buffer paytype-clients for ub.pay-type.
    if g#type <> 'ОФ':U then do:
      assign  frame dialog-frame  paytype .
            if paytype <> ? or paytype <> 0 then do:
                    find first paytype-clients where paytype = paytype-clients.obj-code  no-lock no-error.
                    if error-status :error then error-status :error = false .
                    if avail paytype-clients then do:
                          loc-pay-type = paytype-clients.obj-name .
                          loc-pay-type:screen-value  = paytype-clients.obj-name .
                          display  paytype loc-pay-type with frame dialog-frame.
                          enable   paytype loc-pay-type b-chg b-producer b-alt-post with frame dialog-frame.
                    end.
                    else do:
                          find first paytype-clients where paytype = v-cntxp-in-pay no-lock no-error.
                          if available paytype-clients then do:
                            assign
                              paytype = v-cntxp-in-pay
                              loc-pay-type = paytype-clients.obj-name
                              .
                              if available shar_ord-doc then
                                 shar_ord-doc.pay-code = v-cntxp-in-pay
                            .
                            display  paytype loc-pay-type with frame dialog-frame.
                          end.
                    end.
            end.
    end.
end.
end procedure.
procedure  r-paytype-choose :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define variable rid-list    as  character no-undo .
define buffer paytype# for ub.pay-type.
  run ref/paytype.w (input parparentproc, input "b-sel", output  rid-list).
  assign rep-rec3 = integer(rid-list) no-error.
  find first paytype# where recid(paytype#) = rep-rec3 no-lock no-error.
  if avail paytype# then
    assign
      paytype = paytype#.obj-code
      loc-pay-type= paytype#.obj-name
      .
  enable  loc-pay-type paytype  with frame dialog-frame.
  display loc-pay-type paytype with frame dialog-frame.
end.
end procedure.
procedure local-conf-rd:
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define variable vss-include-info84 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'nakl-glob':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
  if thbjattr_thbj-attr.prop-code = 'multdtyp':U then multdtypvalue = string (thbjattr_thbj-attr.property-value-logical) .
  if thbjattr_thbj-attr.prop-code = 'curcli':U   then curclivalue   = string (thbjattr_thbj-attr.property-value-logical) .
end.
define variable vss-include-info85 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'ord-global':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
  if thbjattr_thbj-attr.prop-code = 'ordshipd':U then v-dayship = thbjattr_thbj-attr.property-value-integer .
end.
define variable vss-include-info86 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input v-cntxt-obj-type
  ,input v-cntxt-obj-code
  ,input 'contr-in':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
  if thbjattr_thbj-attr.prop-code = 'contr-in-income':U then v-mastc = thbjattr_thbj-attr.property-value-logical .
end.
empty temp-table thbjattr_thbj-attr.
if v-mastc = true then varcontract = "yes"  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'edoc-nn'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output par-is-edoc-nn
  ,output par-type
  ) no-error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-edi'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output par-is-edi
  ,output par-type
  ) no-error .
assign
is-edoc-nn = lookup(par-is-edoc-nn, "true,yes":U) > 0
is-edi     = lookup(par-is-edi,     "true,yes":U) > 0
.
end.
end procedure.
procedure mode-on :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  define buffer buf_contract for ub.contract  .
  define buffer buf_sysconf for ub.sysconf  .
define variable vss-include-info87 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output to-day
  )  .
  enable b-delivery with frame dialog-frame .
  if g#type = 'ОФ':U then do:
      t-auto = true .
      display t-auto with frame  dialog-frame.
  end.
  if g#type <> 'ОФ':U then do:
      t-auto = true .
      display t-auto with frame  dialog-frame.
  end.
    if t-action = "add":u then do:
      find first buf_sysconf no-lock where buf_sysconf.host-code = v-cntxt-host-code-obj .
define variable vss-include-info88 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run proc-ord-code in this-procedure
 (input   'main' ,
  input   v-cntxt-db-num ,
  input   v-cntxt-obj-type ,
  input   v-cntxt-obj-code ,
  input   v-i-doc ,
  output  loc-ord-num
 ) .
        assign
          loc-status    = 'новый':U
          date-1 = to-day - 7
          date-2 = to-day
          loc-obj-name = ""
          loc-obj-name:screen-value in frame dialog-frame = ""
          doc-date = to-day
          loc-date-ship = to-day + v-dayship
          date-sale-1 = to-day + v-dayship
          date-sale-2 = to-day + 1 + v-dayship
          loc-hour = 10
          loc-time-ship = string(loc-hour,"99") + ":" + string(loc-min,"99")
          loc-store-code  = v-cntxt-obj-code
          loc-store-type  = v-cntxt-obj-type
          loc-doc-type    = g#type
          paytype         = v-cntxp-in-pay
          no-error
          .
        run paytype-leave-proc.
        loc-exch-code = 0 .
        find ub.currency where ub.currency.curr-code = loc-exch-code no-lock no-error.
          if available ub.currency then disp ub.currency.curr-abbr with frame dialog-frame.
                                else disp ? @ ub.currency.curr-abbr with frame dialog-frame.
        find last ub.curr-accnt where ub.curr-accnt.curr-code = ub.currency.curr-code  use-index pi no-lock no-error.
          if available ub.curr-accnt then assign
            loc-exch-rate = ub.curr-accnt.exch-rate
            loc-exch-scale = ub.curr-accnt.exch-scale.
          else assign
            loc-exch-rate = ?
            loc-exch-scale = ?.
define variable vss-include-info89 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-cntxt-host-code-obj
  ,input  DOC-DATE
  ,output loc-base-rate
  ,output loc-base-scale
  ) no-error .
        vat_type = 'в т. ч.':U .
        slt_type = 'без':U .
    disable b-add b-way b-del b-chg b-producer b-alt-post b-main-calc with frame dialog-frame.
    if g#type = 'ОФ':U then do:
      find first buf-cli where buf-cli.obj-code = v-cntxt-host-code-obj and
                                buf-cli.obj-type = 'орг':U no-lock no-error .
      if available buf-cli then
      assign
          loc-cli-code = buf-cli.obj-code
          loc-cli-type = buf-cli.obj-type
          loc-obj-name = buf-cli.obj-name
          no-error.
      else
      assign
          loc-cli-code = ?
          loc-cli-type = ?
          loc-obj-name = ?
          no-error.
      disable loc-cli-code  loc-cli-type  loc-obj-name  r-clients  with frame dialog-frame.
      display loc-cli-code  loc-cli-type  loc-obj-name  r-clients  with frame dialog-frame.
      enable  b-spec b-add b-way b-del b-chg b-producer b-alt-post b-main-calc with frame dialog-frame.
      find first buf-cli where buf-cli.obj-code = v-cntxt-host-code-obj and
                              buf-cli.obj-type = 'орг':U no-lock no-error .
      rep-rec = recid(buf-cli) .
    end.
    create shar_ord-doc .
      assign
          shar_ord-doc.doc-code     = loc-ord-num
          shar_ord-doc.start-date   = date-1
          shar_ord-doc.end-date     = date-2
          shar_ord-doc.doc-date     = doc-date
          shar_ord-doc.cli-code     = loc-cli-code
          shar_ord-doc.cli-name     = loc-obj-name
          shar_ord-doc.cli-type     = loc-cli-type
          shar_ord-doc.creid        = v-cntxt-userid
          shar_ord-doc.agnt         = agnt
          shar_ord-doc.boss         = boss
          shar_ord-doc.fact-date   = ?
          shar_ord-doc.pay-code    = paytype
          shar_ord-doc.ship-date   = loc-date-ship
          shar_ord-doc.sum-service = loc-service
          shar_ord-doc.flag_        = false
          shar_ord-doc.status_      = 'новый':U
          shar_ord-doc.wrkr         = wrkr
          shar_ord-doc.host-code    = v-cntxt-host-code-obj
          shar_ord-doc.doc-type     = loc-doc-type
          shar_ord-doc.order-type   = tog-type
          shar_ord-doc.cycle-day    = cycle-day
          shar_ord-doc.pay-day      = pay-day
          shar_ord-doc.obj-type     = loc-store-type
          shar_ord-doc.obj-code     = loc-store-code
          shar_ord-doc.vat-type     = vat_type
          shar_ord-doc.slt-type     = slt_type
          shar_ord-doc.base-rate   =  loc-base-rate
          shar_ord-doc.base-scale  =  loc-base-scale
          shar_ord-doc.cli-qnty    =  loc-cli-qnty
          shar_ord-doc.exch-code   =  loc-exch-code
          shar_ord-doc.exch-rate   =  loc-exch-rate
          shar_ord-doc.exch-scale  =  loc-exch-scale
          shar_ord-doc.out-code    =  loc-out-code
          shar_ord-doc.qnty        =  loc-qnty
          shar_ord-doc.sum-base    =  loc-sum-base
          shar_ord-doc.sum-cli     =  loc-sum-cli
          shar_ord-doc.sum-rubl    =  loc-sum-rubl
          shar_ord-doc.tot-lines   =  loc-tot-lines
          shar_ord-doc.e-method    =  e-method
          shar_ord-doc.date-sale-1  = date-sale-1
          shar_ord-doc.date-sale-2  = date-sale-2
          shar_ord-doc.deliv-type-code    = v-deliv-type-code
          shar_ord-doc.obj-point-code     = v-point-obj-code
          shar_ord-doc.cli-point-code     = v-point-cli-code
          shar_ord-doc.obj-point-db-num   = v-point-obj-db-num
          shar_ord-doc.cli-point-db-num   = v-point-cli-db-num
          shar_ord-doc.transport-host-code    = v-transport-host-code
          shar_ord-doc.transport-cli-type     = v-transport-cli-type
          shar_ord-doc.transport-cli-code     = v-transport-cli-code
          shar_ord-doc.transport-contract  = v-transport-contract
          shar_ord-doc.transport-condition = v-transport-condition
          shar_ord-doc.transport-value     = v-transport-value
          shar_ord-doc.sum-ship            = v-transport-sum
          shar_ord-doc.transport-vat       = v-transport-vat
          .
          find first buf_contract where buf_contract.contract-code = loc-contract
                                    and buf_contract.host-code     = v-cntxt-host-code-obj
                                        no-lock no-error .
          if available buf_contract then do:
                       shar_ord-doc.contract-code = buf_contract.contract-code .
          end.
          else shar_ord-doc.contract-code = 0.
        .
      assign
        shar_ord-doc.ship-time   = ( loc-hour * 3600 ) +  ( loc-min * 60 )
        .
      doc-rec =  recid (shar_ord-doc).
    end.
    if t-action = "chg":u or t-action = "copy":u then do:
        run chg-action in this-procedure  .
        run enable_ui in this-procedure  .
    end.
    if t-action = "lkp":u then do:
        assign
            tmp#zakaz.cli-art   :read-only in browse br-docs =  true
            tmp#zakaz.cli-qnty  :read-only in browse br-docs =  true
            tmp#zakaz.price-cli :read-only in browse br-docs =  true  no-error .
        run chg-action  in this-procedure  .
        run enable_ui_2  in this-procedure  .
    end.
end.
if loc-cli-type <> "" and loc-cli-code <> 0  then do:
  assign
  is-edoc-nn-doc = status-is-edoc-nn ( input is-edoc-nn
                                      , input loc-cli-type
                                      , input loc-cli-code
                                      , input loc-store-type
                                      , input loc-store-code
                                      ) .
  assign
  is-edi-doc = status-is-edi ( input is-edi
                              , input loc-cli-type
                              , input loc-cli-code
                              , input loc-store-type
                              , input loc-store-code
                              , output v-dm-edi
                              ) .
end.
end procedure.
procedure proc-eq-tmp-price :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define input parameter p-recid as recid no-undo .
define input parameter tt as character no-undo  .
define buffer bufff-units  for ub.units     .
define buffer ll-tmp#zakaz for tmp#zakaz    .
define buffer buf_doc-line for ub.doc-line  .
define variable max-num as integer no-undo .
define variable t-type as character no-undo .
find first tmp#zakaz   where
           tmp#zakaz.prod-type = ub.goods.prod-type and
           tmp#zakaz.prod-code = ub.goods.prod-code and
           tmp#zakaz.artic     = ub.goods.artic
           no-error.
 if not available tmp#zakaz  then  do:
    max-num = 0.
    for each  ll-tmp#zakaz  where ll-tmp#zakaz.doc-code        = loc-ord-num and
                                  ll-tmp#zakaz.gds-code        <> ub.goods.gds-code :
        if max-num < ll-tmp#zakaz.line-num then
           max-num = ll-tmp#zakaz.line-num .
    end.
  create tmp#zakaz .
  assign
    tmp#zakaz.doc-code        = loc-ord-num
    tmp#zakaz.gds-code        = ub.goods.gds-code
    tmp#zakaz.prod-type       = ub.goods.prod-type
    tmp#zakaz.prod-code       = ub.goods.prod-code
    tmp#zakaz.artic           = ub.goods.artic
    tmp#zakaz.line-num        = max-num + 1
  .
 end.
  assign
    tmp#zakaz.doc-code        = loc-ord-num
    tmp#zakaz.gds-code        = ub.goods.gds-code
    tmp#zakaz.prod-type       = ub.goods.prod-type
    tmp#zakaz.prod-code       = ub.goods.prod-code
    tmp#zakaz.artic           = ub.goods.artic
    tmp#zakaz.gds-name        = ub.goods.gds-name
    tmp#zakaz.negative-rest   = ub.goods.negative-rest
    tmp#zakaz.deadline        = ub.goods.deadline
    tmp#zakaz.unit-base       = ub.goods.unit-base
    tmp#zakaz.unit-cli        = ub.goods.unit-cli
    tmp#zakaz.cli-base-rate   = ub.goods.cli-base-rate
    tmp#zakaz.ms-cart         = ub.goods.qnty-cart
    .
   find first ub.ext-artic where ub.ext-artic.cli-type    = loc-cli-type
                          and ub.ext-artic.cli-code    = loc-cli-code
                          and ub.ext-artic.gds-code    = ub.goods.gds-code
                          and ub.ext-artic.gds-code    = ub.goods.gds-code
                          and ub.ext-artic.status_    <> 'удал':U no-error .
  if available ub.ext-artic then do:
     tmp#zakaz.cli-art = ub.ext-artic.ext-artic.
  end.
  else do:
     tmp#zakaz.cli-art = ''.
  end.
define variable vss-include-info90 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-cntxt-host-code-obj
  ,input  loc-store-type
  ,input  loc-store-code
  ,output tmp#zakaz.vat-pc
  ) no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .
  find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-base no-lock no-error.
  if available bufff-units then
  assign
    tmp#zakaz.unit-type       = bufff-units.type .
  find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-cli no-lock no-error.
  if available bufff-units then
  assign
    tmp#zakaz.unit-cli-type       = bufff-units.type .
  find first sb-cli-gds where recid(sb-cli-gds) = p-recid no-lock no-error .
  if available sb-cli-gds then do:
        assign
          tmp#zakaz.cancel-date     = sb-cli-gds.cancel-date
          tmp#zakaz.in-qnty         = sb-cli-gds.in-qnty
          tmp#zakaz.out-qnty        = sb-cli-gds.out-qnty
          tmp#zakaz.ret-qnty        = sb-cli-gds.ret-qnty
          tmp#zakaz.in-base         = sb-cli-gds.in-base
          tmp#zakaz.in-rubl         = sb-cli-gds.in-rubl
          tmp#zakaz.out-sum         = sb-cli-gds.out-sum
          tmp#zakaz.ret-sum         = sb-cli-gds.ret-sum
          tmp#zakaz.in-code         = sb-cli-gds.in-code
          tmp#zakaz.last-curr-code  = sb-cli-gds.exch-code
          tmp#zakaz.supp-qnty       = sb-cli-gds.supp-qnty
          tmp#zakaz.supp-base       = sb-cli-gds.supp-base
          tmp#zakaz.supp-rubl       = sb-cli-gds.supp-rubl
        .
        find first buf_doc-line no-lock where
                   buf_doc-line.doc-code  = sb-cli-gds.in-code and
                   buf_doc-line.artic     = sb-cli-gds.artic and
                   buf_doc-line.prod-type = sb-cli-gds.prod-type and
                   buf_doc-line.prod-code = sb-cli-gds.prod-code
                   no-error .
        if available buf_doc-line  then do:
            assign
              tmp#zakaz.unit-cli        = buf_doc-line.unit-cli
              tmp#zakaz.cli-base-rate   = buf_doc-line.cli-base-rate
              .
        end.
  end.
  else do:
  end.
 run last-price (
      input  v-cntxt-host-code-obj ,
      input  tmp#zakaz.artic ,
      input  tmp#zakaz.prod-type ,
      input  tmp#zakaz.prod-code ,
      input  loc-cli-code  ,
      input  loc-cli-type  ,
      input  tmp#zakaz.cli-base-rate ,
      input  loc-exch-code ,
      output tmp#zakaz.price-base ,
      output tmp#zakaz.price-rubl ,
      output tmp#zakaz.price-cli   )
 no-error  .
 if error-status :error then do:
 end.
  If tt <> "doc"  then do:
      find first shar_ord-line   where
          shar_ord-line.doc-code        = loc-ord-num    and
          shar_ord-line.prod-type       = tmp#zakaz.prod-type and
          shar_ord-line.prod-code       = tmp#zakaz.prod-code and
          shar_ord-line.artic           = tmp#zakaz.artic     no-error.
          if not available shar_ord-line  then
             create shar_ord-line .
             buffer-copy tmp#zakaz to shar_ord-line
               assign shar_ord-line.doc-code    = loc-ord-num
               no-error .
  end.
  if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "ошибка"
    view-as alert-box error
  .
  end .
 end.
end procedure.
procedure choose-menu-add2 :
do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
define variable ii         as integer init 0 no-undo.
define variable r-tmp      as recid no-undo .
define variable r-stop     as logical no-undo .
define variable r-exit     as logical no-undo .
define variable l-g#type   as character no-undo .
define variable l-g#status as character no-undo .
l-g#status = g#stat.
l-g#type = g#type.
define variable varschartic  as character initial " " no-undo.
define variable v-ref-list  as character  no-undo.
    run str/chsgdsls.w (
        parParentProc ,
        input "order" + g#type ,
        input "Строка документа № "  ,
        input loc-cli-type ,
        input loc-cli-code ,
        input v-cntxt-host-code-obj,
        input-output varschartic,
        output v-ref-list,
        output table tt-gds-list,
        false
        ) no-error.
   g#type = l-g#type.
   g#stat = l-g#status.
   t-ret =  session:set-wait-state("general") .
   line-mode = 'ДОБАВЛЕНИЕ':U .
 _tt:  for each tt-gds-list :
     ii = ii + 1 .
     if ii > 1 then assign line-mode = "ЦИКЛ":u.
define variable vss-include-info91 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  loc-contract,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = loc-contract
      .
END.
    FIND FIRST contract-specif
           NO-LOCK
           WHERE
               contract-specif.Host-code    = i-gl-Host-Code
           AND contract-specif.Contract-num = i-gl-Contract-Code
           AND contract-specif.Gds-code     = tt-gds-list.gds-code
           NO-ERROR
           .
     if  available contract-specif then do:
          run create-tmp in this-procedure  (input "contract-spec":u, "" ) no-error .
     end.
     else run create-tmp in this-procedure  (input "tt-gds-list":u, "" ) no-error .
     if error-status :error then message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "create-tmp"
       view-as alert-box error
     .
     release tmp#zakaz.
     find tmp#zakaz where tmp#zakaz.gds-code = tt-gds-list.gds-code no-error .
        if not  error-status :error  and not t-auto then do:
            run cus/ord-frm.w ( input ParParentProc,  input recid ( tmp#zakaz ) , input line-mode , output r-stop , output r-exit) no-error .
            if r-stop then do:
              run p-delete ( recid ( tmp#zakaz ), input-output ii) .
              leave _tt.
            end.
            if r-exit then do:
               run p-delete ( recid ( tmp#zakaz ) ,input-output ii ) .
            end.
        end.
   end.
   if ii > 0 then disable loc-cli-code loc-cli-type loc-obj-name r-clients with frame dialog-frame.
    choice = ?.
    run openbr in this-procedure  .
    t-ret =  session:set-wait-state("") .
    message "Добавлено " + string(ii) + " товаров".
 end.
end procedure.
procedure my-proc-mouse-dbl-click-loc-name :
 do
 on error undo, return error return-value
 :
  assign
  frame dialog-frame loc-name.
    if last-event:label = "Ctrl-J" then
      find next tmp#zakaz where
                tmp#zakaz.gds-name begins loc-name no-error.
    else
      find first tmp#zakaz where
                 tmp#zakaz.gds-name begins loc-name no-error.
      if not avail tmp#zakaz then return.
      find first shar_ord-line no-lock
            where shar_ord-line.doc-code = loc-ord-num  and
                  shar_ord-line.artic      = tmp#zakaz.artic     and
                  shar_ord-line.prod-type  = tmp#zakaz.prod-type and
                  shar_ord-line.prod-code  = tmp#zakaz.prod-code no-error .
    if available tmp#zakaz and available shar_ord-line then do:
      line-rec = recid (shar_ord-line).
      reposition br-docs to recid line-rec no-error.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
    end.
  apply "entry" to loc-name in frame dialog-frame.
 end.
end procedure.
procedure init-gds-rec :
 do
 on error undo, return error return-value
 :
 define buffer bb_goods for ub.goods.
 gds-rec = ? .
  find current shar_ord-line  no-lock  no-error .
  if not avail shar_ord-line then return.
  find first TMP#zakaz no-lock    where
              shar_ord-line.prod-type       = tmp#zakaz.prod-type and
              shar_ord-line.prod-code       = tmp#zakaz.prod-code and
              shar_ord-line.artic           = tmp#zakaz.artic        no-error  .
  if not available TMP#zakaz   then do:
       return.
  end.
  if available tmp#zakaz then do:
      find first bb_goods no-lock where bb_goods.gds-code = tmp#zakaz.gds-code no-error .
      gds-rec = recid (bb_goods).
   end.
 end.
end procedure.
procedure p-delete :
 do
 on error undo, return error return-value
 :
   find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
   if available shar_ord-doc
    and (( is-edoc-nn and ( shar_ord-doc.ord-int1 = integer('3':U) or shar_ord-doc.ord-int1 = integer('4':U)))
     or  ( is-edi     and   shar_ord-doc.ord-int1 = integer('3':U)))
    then do:
       message "Заказ по системе EDOC/EDI не должен корректироватся в этом статусе. Только НОВЫЙ желтый! " view-as alert-box information .
       return .
    end.
    define input parameter tmp-recid as recid no-undo .
    define input-output parameter ii as integer no-undo . .
    find first tmp#zakaz where recid(tmp#zakaz) = tmp-recid no-error .
    if not avail tmp#zakaz then return error.
    find first shar_ord-line   where
        shar_ord-line.doc-code        = loc-ord-num    and
        shar_ord-line.prod-type       = tmp#zakaz.prod-type and
        shar_ord-line.prod-code       = tmp#zakaz.prod-code and
        shar_ord-line.artic           = tmp#zakaz.artic     no-error.
    if not available shar_ord-line  then  return error .
    delete shar_ord-line .
    delete tmp#zakaz .
    ii = ii - 1 .
 end.
end procedure.
procedure CHOOSE-MENU-way1 :
 do
 on error undo, return error return-value
 :
 assign frame dialog-frame LOC-DATE-SHIP
                            DATE-sale-1
                            DATE-sale-2 .
 run ver-date  in this-procedure .
 if return-value <> "" then return.
 find current shar_ord-line no-lock no-error .
 if not avail shar_ord-line then return.
 run cus/ord-way.w (    pARPARENTPROC,
                    shar_ord-line.artic     ,
                   shar_ord-line.prod-type ,
                   shar_ord-line.prod-code ,
                   1,
                    LOC-DATE-SHIP  ,
                    DATE-sale-1    ,
                    DATE-sale-2    ,
                    loc-store-type ,
                    loc-store-code ,
                    loc-doc-type  ) .
 end.
end procedure.
procedure CHOOSE-MENU-way2 :
 do
 on error undo, return error return-value
 :
 assign frame dialog-frame LOC-DATE-SHIP
                            DATE-sale-1
                            DATE-sale-2 .
 run ver-date  in this-procedure .
 if return-value <> "" then return.
 find current shar_ord-line no-lock no-error .
 if not avail shar_ord-line then return.
 run cus/ord-way.w (   pARPARENTPROC,
                   shar_ord-line.artic     ,
                   shar_ord-line.prod-type ,
                   shar_ord-line.prod-code ,
                   2,
                    LOC-DATE-SHIP  ,
                    DATE-sale-1    ,
                    DATE-sale-2    ,
                    loc-store-type ,
                    loc-store-code ,
                    loc-doc-type  ) .
 end.
end procedure.
procedure CHOOSE-MENU-way3 :
 do
 on error undo, return error return-value
 :
 assign frame dialog-frame LOC-DATE-SHIP
                            DATE-sale-1
                            DATE-sale-2 .
 run ver-date  in this-procedure .
 if return-value <> "" then return.
 find current shar_ord-line no-lock no-error .
 if not avail shar_ord-line then return.
 run cus/ord-waya.w (  PARPARENTPROC ,
                   shar_ord-line.doc-code  ,
                   1,
                    LOC-DATE-SHIP  ,
                    DATE-sale-1    ,
                    DATE-sale-2    ,
                    loc-store-type ,
                    loc-store-code ,
                    loc-doc-type  ) .
 end.
end procedure.
procedure CHOOSE-MENU-way4 :
 do
 on error undo, return error return-value
 :
 assign frame dialog-frame LOC-DATE-SHIP
                            DATE-sale-1
                            DATE-sale-2 .
 run ver-date  in this-procedure .
 if return-value <> "" then return.
 find current shar_ord-line no-lock no-error .
 if not avail shar_ord-line then return.
 run cus/ord-waya.w (   PARPARENTPROC,
                    shar_ord-line.doc-code  ,
                   2,
                    LOC-DATE-SHIP  ,
                    DATE-sale-1    ,
                    DATE-sale-2    ,
                    loc-store-type ,
                    loc-store-code ,
                    loc-doc-type  ) .
 end.
end procedure.
procedure ver-date :
do
on error undo, return error return-value
:
  assign frame dialog-frame
  LOC-DATE-SHIP
  DATE-sale-1
  DATE-sale-2
  doc-date
                            .
  if date-sale-1 = ?
  and is-edi-doc
  then do:
    message
    "Не задана дата начала продажи !!!"
    view-as alert-box error .
    return error "Не задана дата начала продажи !!!".
  end.
  if date-sale-2 = ?
  and is-edi-doc
  then do:
    message
    "Не задана дата конца продажи !!!"
    view-as alert-box error .
    return error "Не задана дата конца продажи !!!".
  end.
  if t-action = "add":u then do:
    if LOC-DATE-SHIP < to-day then do:
      message "Дата доставки меньше текущей !!! "
      view-as alert-box information .
      return error "Дата доставки меньше текущей !!! "  .
    end.
  end.
  if LOC-DATE-SHIP > DATE-sale-1 then do:
    message "Дата доставки больше даты начала продажи !!! "
    view-as alert-box information .
    return error "Дата доставки больше даты начала продажи !!! ".
  end.
  if DATE-sale-1 > DATE-sale-2 then do:
    message "Не правильный интервал даты продажи !!! "
    view-as alert-box information .
    return error "Не правильный интервал даты продажи !!! ".
  end.
  return .
end.
end procedure.
procedure proc_import_TEXT :
 do
 on error undo, return error return-value
 :
define variable l-ok as logical no-undo .
  message "Проводить импорт из формата мобильного сканера ? "
    view-as alert-box question
    buttons yes-no
    update l-ok .
  if l-ok = false then return.
  if shar_ord-doc.cli-code = 0 or shar_ord-doc.cli-code = ? then do:
      find first shar_ord-doc where recid(shar_ord-doc) = doc-rec exclusive-lock no-error.
        shar_ord-doc.cli-code = loc-cli-code .
        shar_ord-doc.cli-type = loc-cli-type .
   end.
 run cus/scan-n.p ( parparentproc, loc-ord-num ) .
  for each shar_ord-line where shar_ord-line.doc-code = shar_ord-doc.doc-code  no-lock :
    run create-tmp in this-procedure  (input "doc":u,"") no-error .
  end.
  run create-tmp-dtl  .
  run openbr in this-procedure  .
 end.
end procedure.
procedure proc-renum :
 do
 on error undo, return error return-value
 :
define variable g-ok as logical no-undo .
define variable g as integer no-undo .
define buffer buf_ord-line for ub.ord-line.
define buffer t-tmp#zakaz for tmp#zakaz.
 message " Перенумеровать список товаров ? "
    view-as alert-box question
    buttons yes-no
    UPDATE g-ok
    .
    if g-ok = false then return.
    g = 0 .
    for each t-tmp#zakaz by t-tmp#zakaz.line-num :
        g = g + 1.
        t-tmp#zakaz.line-num = g.
        find first buf_ord-line  exclusive-lock  where
                    buf_ord-line.doc-code        = loc-ord-num    and
                    buf_ord-line.prod-type       = t-tmp#zakaz.prod-type and
                    buf_ord-line.prod-code       = t-tmp#zakaz.prod-code and
                    buf_ord-line.artic           = t-tmp#zakaz.artic
                    no-error  .
                    if not error-status :error then
                        buf_ord-line.line-num = t-tmp#zakaz.line-num .
    end.
    run openbr.
    open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,each tmp#zakaz where tmp#zakaz.artic = shar_ord-line.artic and tmp#zakaz.prod-type = shar_ord-line.prod-type and tmp#zakaz.prod-code = shar_ord-line.prod-code BY tmp#zakaz.line-num .
 end.
end procedure.
procedure proc-gds-prt:
 do
 on error undo, return error return-value
 :
  find current shar_ord-line  no-lock  no-error .
  if not avail shar_ord-line then return.
  find first TMP#zakaz no-lock    where
              shar_ord-line.prod-type       = tmp#zakaz.prod-type and
              shar_ord-line.prod-code       = tmp#zakaz.prod-code and
              shar_ord-line.artic           = tmp#zakaz.artic        no-error  .
  if not avail TMP#zakaz   then do:
       message error-status :get-message(1) .
       return.
       end.
define variable vss-include-info92 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  find current TMP#zakaz no-lock no-error  .
  if error-status :error or  not avail TMP#zakaz   then do:
       message "Не выбрана строка заказа" .
       return.
       end.
  find first ub.goods no-lock where ub.goods.prod-type = tmp#zakaz.prod-type and
                                 ub.goods.prod-code = tmp#zakaz.prod-code and
                                 ub.goods.artic     = tmp#zakaz.artic   no-error.
      run cus/ord-p.p
      ( parParentProc
      , ?
      , recid(TMP#zakaz)
      , recid(goods)
      , (If t-action = "lkp":U then  'ПРОСМОТР':U  else 'ШКАЛА':U )
      , input TMP#zakaz.qnty
      , input TMP#zakaz.cli-qnty
      ) .
  apply "VALUE-CHANGED":U to br-docs in frame dialog-frame.
  open query br-docs-2 for each tmp#zakaz-dtl no-lock where tmp#zakaz-dtl.artic = x-artic and tmp#zakaz-dtl.prod-type = x-prod-type and tmp#zakaz-dtl.prod-code = x-prod-code .
 end.
END PROCEDURE.
procedure proc_export_ras :
 do
 on error undo, return error return-value
 :
 define variable old-e-method as character no-undo .
    old-e-method = e-method.
    e-method     = temp-e-method.
 assign frame  dialog-frame cycle-day loc-date-ship loc-service date-sale-1 date-sale-2 loc-cli-out-doc doc-date .
 run ver-date .
 if return-value <> "" then return.
find first tmp#zakaz no-error  .
  if avail tmp#zakaz then do:
    run cus/ord-m.w (input PARPARENTPROC , input "export":u , input g#type ) .
    temp-e-method = e-method.
    e-method = old-e-method.
  end.
 end.
end procedure.
procedure r-contract-choose :
 do
 on error undo, return error return-value
 :
define buffer buff_contract for  ub.contract .
define variable   p-rid-list   as character no-undo .
if loc-contract > 0  then do:
  find first buff_contract no-lock where
            buff_contract.host-code = v-cntxt-host-code-obj and
            buff_contract.contract-code = loc-contract no-error .
  if available buff_contract then
               p-rid-list = string(recid(buff_contract)).
end.
  run str/cont-all.w (
      input   parparentproc  ,
      input   v-cntxt-host-code-obj     ,
      input   "b-sel"         ,
      input   "firm-curr"      ,
      input   loc-cli-type    ,
      input   loc-cli-code    ,
      input   ?               ,
      input   ?               ,
      input   "current"       ,
      input   'при':U       ,
      input-output p-rid-list )
      .
    if p-rid-list > '' then do:
    find first buff_contract no-lock where recid(buff_contract) = integer(p-rid-list) no-error .
        if available buff_contract then
           loc-contract        =  buff_contract.contract-code .
           else loc-contract   = 0.
       display loc-contract with frame dialog-frame.
      run from-contract no-error .
      if error-status :error then return error return-value .
    end.
 end.
end procedure.
procedure from-contract :
 do
 on error undo, return error return-value
 :
define buffer buf_contract for ub.contract  .
  if loc-contract <> 0 then do:
      find first buf_contract where buf_contract.contract-code = loc-contract
                            and buf_contract.host-code         = v-cntxt-host-code-obj
                            no-lock no-error .
      if not available buf_contract then do:
        message "Неверно введен Номер договора!!! " view-as alert-box .
        return error.
      end.
  end.
  if  available buf_contract then do:
      if buf_contract.status_ = 'зкр':U then do:
            loc-contract = 0 .
            message "Договор в статусе <<зкр>> !!! " view-as alert-box information .
            display loc-contract with frame dialog-frame .
            return error.
      end.
      if  buf_contract.contract-date-end <> ? and buf_contract.contract-date-end < date(loc-date-ship:screen-value) then do:
            loc-contract = 0 .
            message "Дата закрытия Договора " buf_contract.contract-date-end
                   " меньше даты доставки заказа " loc-date-ship:screen-value  view-as alert-box information .
            display loc-contract with frame dialog-frame .
            return error.
      end.
      loc-exch-code       = buf_contract.curr-code .
      find ub.currency where ub.currency.curr-code = loc-exch-code no-lock no-error.
      if available ub.currency then do:
          find last ub.curr-accnt where ub.curr-accnt.curr-code = loc-exch-code  use-index pi no-lock no-error.
            if available ub.curr-accnt then
                assign
                  loc-exch-rate = ub.curr-accnt.exch-rate
                  loc-exch-scale = ub.curr-accnt.exch-scale
                  .
            else
                assign
                  loc-exch-rate = ?
                  loc-exch-scale = ?
                  .
      end.
      if available currency then disp loc-exch-code loc-exch-rate loc-exch-scale currency.curr-abbr with frame dialog-frame.
                            else disp ? @ currency.curr-abbr with frame dialog-frame.
define variable vss-include-info93 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  loc-contract,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = loc-contract
      .
END.
    FIND FIRST ub.contract-specif
           NO-LOCK
           WHERE
               ub.contract-specif.Host-code    = i-gl-Host-Code
           AND ub.contract-specif.Contract-num = i-gl-Contract-Code
           NO-ERROR
           .
        if available ub.contract-specif then do:
            define variable old_vat_type as character no-undo .
            define variable vat_type1 as character no-undo .
            define variable v-diff as logical   no-undo .
            v-diff = false  .
define variable vss-include-info94 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  loc-contract,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = loc-contract
      .
END.
    FIND FIRST ub.contract-specif
           NO-LOCK
           WHERE
               ub.contract-specif.Host-code    = i-gl-Host-Code
           AND ub.contract-specif.Contract-num = i-gl-Contract-Code
           NO-ERROR
           .
                if available ub.contract-specif then do:
                  vat_type1 = ub.contract-specif.vat-type .
                end.
define variable vss-include-info95 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  loc-contract,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = loc-contract
      .
END.
FOR EACH
    ub.contract-specif
     NO-LOCK
     WHERE
         ub.contract-specif.Host-code    = i-gl-Host-Code
     AND ub.contract-specif.Contract-num = i-gl-Contract-Code
     :
                if vat_type1 <> ub.contract-specif.vat-type then do:
                  v-diff = true .
                  leave.
                end.
              end.
              if v-diff = true then do:
                message "В договоре в спецификации указаны разные типы НДС. Выберите правильный тип вручную." view-as alert-box information .
              end.
              else do:
                  old_vat_type = vat_type .
define variable vss-include-info96 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  loc-contract,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = loc-contract
      .
END.
FOR EACH
    ub.contract-specif
     NO-LOCK
     WHERE
         ub.contract-specif.Host-code    = i-gl-Host-Code
     AND ub.contract-specif.Contract-num = i-gl-Contract-Code
     :
                    vat_type = ub.contract-specif.VAT-type.
                    leave.
                  end.
                if old_vat_type <> vat_type then do:
                    message substitute("Изменен тип НДС c <<&1>> на <<&2>> (взято из спецификации по договору) !!! " , old_vat_type , vat_type )  view-as alert-box information .
                end.
                run full-recount in this-procedure .
                display vat_type with frame dialog-frame.
            end.
       end.
     assign
        v-transport-cli-code     =  buf_contract.transport-cli-code
        v-transport-cli-type     =  buf_contract.transport-cli-type
        v-transport-host-code    =  buf_contract.transport-host
        v-transport-contract     =  buf_contract.transport-contract
        v-transport-condition    =  buf_contract.transport-uslov
        v-transport-value        =  buf_contract.transport-value
        .
  end.
 end.
end procedure.
procedure del-3 :
 do
 on error undo, return error return-value
 :
   find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
   if available shar_ord-doc
   and (( is-edoc-nn and ( shar_ord-doc.ord-int1 = integer('3':U) or shar_ord-doc.ord-int1 = integer('4':U)))
    or  ( is-edi     and   shar_ord-doc.ord-int1 = integer('3':U)))
    then do:
       message "Заказ по системе EDOC/EDI не должен корректироватся в этом статусе. Только НОВЫЙ желтый! " view-as alert-box information .
       return .
    end.
define variable ii as integer init 0 no-undo.
   run str/gds-list.w (
    input parparentproc
   ,input v-cntxt-host-code-obj
   ,input v-cntxt-obj-type
   ,input v-cntxt-obj-code )
   .
   t-ret =  session:set-wait-state("general") .
   for each gds-list no-lock :
     find first   tmp#zakaz  where
                  tmp#zakaz.prod-type       = gds-list.prod-type and
                  tmp#zakaz.prod-code       = gds-list.prod-code and
                  tmp#zakaz.artic           = gds-list.artic  no-error.
     if avail tmp#zakaz then do:
         ii = ii + 1.
            do transaction :
                find first shar_ord-line  exclusive-lock   where
                    shar_ord-line.doc-code        = loc-ord-num    and
                    shar_ord-line.prod-type       = tmp#zakaz.prod-type and
                    shar_ord-line.prod-code       = tmp#zakaz.prod-code and
                    shar_ord-line.artic           = tmp#zakaz.artic        no-error  .
                delete  shar_ord-line  no-error.
                for each tmp#zakaz-dtl where
                    tmp#zakaz-dtl.doc-code        = loc-ord-num    and
                    tmp#zakaz-dtl.prod-type       = tmp#zakaz.prod-type and
                    tmp#zakaz-dtl.prod-code       = tmp#zakaz.prod-code and
                    tmp#zakaz-dtl.artic           = tmp#zakaz.artic   :
                    delete tmp#zakaz-dtl .
                end.
                delete  tmp#zakaz     no-error.
            end.
         end.
   end.
   choice = ?.
   t-ret =  session:set-wait-state("") .
   run openbr in this-procedure  .
   message "Удалено " + string(ii) + " товаров".
end.
end procedure.
procedure del-2 :
 do
 on error undo, return error return-value
 :
  find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
  if available shar_ord-doc
  and (( is-edoc-nn and ( shar_ord-doc.ord-int1 = integer('3':U) or shar_ord-doc.ord-int1 = integer('4':U)))
   or  ( is-edi     and   shar_ord-doc.ord-int1 = integer('3':U)))
  then do:
      message "Заказ по системе EDOC/EDI не должен корректироватся в этом статусе. Только НОВЫЙ желтый! " view-as alert-box information .
      return .
  end.
define variable ii as integer init 0 no-undo.
   t-ret =  session:set-wait-state("general") .
   for each tmp#zakaz where tmp#zakaz.local-mark = "*" no-lock :
         ii = ii + 1.
            do transaction :
                find first shar_ord-line  exclusive-lock   where
                    shar_ord-line.doc-code        = loc-ord-num    and
                    shar_ord-line.prod-type       = tmp#zakaz.prod-type and
                    shar_ord-line.prod-code       = tmp#zakaz.prod-code and
                    shar_ord-line.artic           = tmp#zakaz.artic        no-error  .
                if not error-status :error then
                   delete  shar_ord-line  no-error.
                for each tmp#zakaz-dtl where
                    tmp#zakaz-dtl.doc-code        = loc-ord-num    and
                    tmp#zakaz-dtl.prod-type       = tmp#zakaz.prod-type and
                    tmp#zakaz-dtl.prod-code       = tmp#zakaz.prod-code and
                    tmp#zakaz-dtl.artic           = tmp#zakaz.artic   :
                    delete tmp#zakaz-dtl .
                end.
                   delete  tmp#zakaz     no-error.
            end.
   end.
   choice = ?.
   t-ret =  session:set-wait-state("") .
   run openbr in this-procedure  .
   message "Удалено " + string(ii) + " товаров".
end.
end procedure.
procedure proc_chg_m_export_text :
 do
 on error undo, return error return-value
 :
  g#log = true  .
  message "Экспорт в текстовый файл ." skip "Продолжать ?"
           view-as alert-box question buttons ok-cancel update g#log.
           if not g#log then return no-apply.
      tmp-rec = recid( tmp#zakaz ).
      do while available tmp#zakaz :
            get prev br-docs.
      end.
      run cus/z-tot.p
        (input parparentproc,
         input "m":u,
         input date-1,
         input date-2) .
end.
end procedure.
procedure proc_ch_b-chg :
 do
 on error undo, return error return-value
 :
 define variable r-tmp  as recid no-undo   .
 define variable r-stop as logical no-undo  .
 define variable r-exit as logical no-undo    .
  find current shar_ord-line  no-lock  no-error .
  if not available shar_ord-line then do:
     return.
  end.
  else do:
  end.
  find first tmp#zakaz no-lock    where
             tmp#zakaz.prod-type = shar_ord-line.prod-type        and
             tmp#zakaz.prod-code = shar_ord-line.prod-code        and
             tmp#zakaz.artic     = shar_ord-line.artic            no-error  .
  if not avail tmp#zakaz   then do:
       message error-status :get-message(1)
       shar_ord-line.prod-type
       shar_ord-line.prod-code
       shar_ord-line.artic
       .
       return no-apply.
       end.
  tmp-rec =  recid ( shar_ord-line ) .
  if t-action = "lkp":u then do:
     line-mode = 'ПРОСМОТР':U .
  end.
  else do:
    line-mode = 'ИЗМЕНЕНИЕ':U .
    assign frame dialog-frame loc-date-ship
                              date-sale-1
                              date-sale-2 .
    run ver-date  .
    if return-value <> "" then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .
       return.
       end.
   end.
  r-tmp = recid ( shar_ord-line ) .
  run cus/ord-frm.w ( input ParParentProc , input recid ( tmp#zakaz ) , input line-mode , output r-stop , output r-exit) no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "123"
    view-as alert-box error
  .
  if t-action <> "lkp":u then do:
      run openbr in this-procedure  .
      reposition br-docs to recid tmp-rec no-error.
  end.
end.
end procedure.
procedure show-contract-code :
  do
  on error undo, return error return-value
  :
  define buffer buf_contract for ub.contract .
  define variable v-host-code as integer   no-undo .
  if t-action <> "add":u then do:
    if available shar_ord-doc
    then do:
      if shar_ord-doc.contract-code = 0
      then do:
        message
          "У заказа не задан договор" skip
          view-as alert-box information .
      end.
      else do:
        define variable v-recid as recid no-undo .
define variable vss-include-info97 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  shar_ord-doc.obj-type
  ,input  shar_ord-doc.obj-code
  ,output v-host-code
  ) no-error .
        if error-status :error then v-host-code = shar_ord-doc.host-code .
        find first buf_contract no-lock
          where buf_contract.host-code     = v-host-code
            and buf_contract.contract-code = shar_ord-doc.contract-code
          no-error .
        if available buf_contract
        then do:
          assign
            v-recid = recid( buf_contract )
          .
          run str/sh-contr.p
            (input  parParentProc
            ,input v-recid
            ) .
        end.
        else do:
          message
            "Договор не найден" skip
            "Код фирмы" v-host-code skip
            "Код договора" shar_ord-doc.contract-code skip
            "Объект" shar_ord-doc.obj-type shar_ord-doc.obj-code skip
            view-as alert-box error .
        end.
      end.
    end.
  end.
  else do:
      find first buf_contract no-lock
      where buf_contract.host-code     = v-cntxt-host-code-obj
        and buf_contract.contract-code = loc-contract
      no-error .
      if available buf_contract
      then do:
        assign
          v-recid = recid( buf_contract )
        .
        run str/sh-contr.p
          (input  parParentProc
          ,input v-recid
          ) .
        end.
  end.
  end.
end procedure.
procedure show-protocol :
  do
  on error undo, return error return-value
  :
define variable v-gds-code as integer   no-undo .
define buffer buf1_goods for ub.goods  .
  find current shar_ord-line  no-lock  no-error .
  if not available shar_ord-line then return .
  v-gds-code = shar_ord-line.gds-code .
  if shar_ord-line.gds-code = 0  or shar_ord-line.gds-code = ? then do:
     find first buf1_goods no-lock where
                buf1_goods.artic = shar_ord-line.artic and
                buf1_goods.prod-type = shar_ord-line.prod-type and
                buf1_goods.prod-code = shar_ord-line.prod-code no-error .
     v-gds-code = buf1_goods.gds-code .
  end.
  run cus/ord-prot.w
      ( input loc-ord-num ,
        input v-gds-code
        ) .
  end.
end procedure.
PROCEDURE edoc-edi-proc :
if  ((is-edoc-nn and
    ( shar_ord-doc.ord-int1 = int ('4':U) or
      shar_ord-doc.ord-int1 = int ('3':U)  or
    ( shar_ord-doc.ord-int1 = int ('0':U)  and
      shar_ord-doc.ord-int2 = int ('1':U))
      ))
or  (is-edi and
     (shar_ord-doc.ord-int1 = int ('3':U)
      and
      shar_ord-doc.ord-int2 = int ('1':U))
     )
     )
and   shar_ord-doc.doc-type = 'ОП':U
and   shar_ord-doc.status_ = 'новый':U
then do:
      tmp#zakaz.order-cli-qnty:visible in browse br-docs = true .
      tmp#zakaz.ord-dec1:visible       in browse br-docs = true .
  if is-edi then do:
    disable
    loc-cli-out-doc
    with frame dialog-frame .
  end.
end.
else do:
    tmp#zakaz.order-cli-qnty:visible in browse br-docs = false .
    tmp#zakaz.ord-dec1:visible       in browse br-docs = false .
end.
END PROCEDURE.
PROCEDURE row-display-br-doc :
if  ((is-edoc-nn and
    ( shar_ord-doc.ord-int1 = int ('4':U) or
      shar_ord-doc.ord-int1 = int ('3':U)  or
    ( shar_ord-doc.ord-int1 = int ('0':U)  and
      shar_ord-doc.ord-int2 = int ('1':U))
      ))
or  (is-edi and
    ( shar_ord-doc.ord-int1 = int ('3':U) or
    ( shar_ord-doc.ord-int1 = int ('0':U)  and
      shar_ord-doc.ord-int2 = int ('1':U))
      )))
and   shar_ord-doc.doc-type = 'ОП':U
and   shar_ord-doc.status_ = 'новый':U
  then do:
      if tmp#zakaz.order-cli-qnty <> tmp#zakaz.cli-qnty
        then tmp#zakaz.order-cli-qnty:bgcolor in browse br-docs = 12  .
        else tmp#zakaz.order-cli-qnty:bgcolor in browse br-docs = ? .
      if tmp#zakaz.ord-dec1 <> tmp#zakaz.price-cli
        then tmp#zakaz.ord-dec1:bgcolor = 12.
        else tmp#zakaz.ord-dec1:bgcolor = ? .
  end.
  else do:
        tmp#zakaz.order-cli-qnty:bgcolor in browse br-docs = ?      .
        tmp#zakaz.ord-dec1:bgcolor       in browse br-docs = ?      .
  end.
END PROCEDURE.
procedure init-browse-p :
  do
  on error undo, return error return-value
  :
define variable cur-clmn-loc as integer   no-undo .
define variable column-handle as handle no-undo .
  assign
    cur-clmn-loc  = 1
    column-handle = br-docs:first-column   in frame dialog-frame
    hcolumn [cur-clmn-loc] = column-handle
  .
  do while valid-handle(column-handle) :
    if cur-clmn-loc = br-docs:num-columns then do:
      leave .
    end.
    assign
      column-handle = column-handle:NEXT-COLUMN
      cur-clmn-loc  = cur-clmn-loc + 1
      hcolumn [cur-clmn-loc] = column-handle
    .
  end.
run uf-get in this-procedure (
     input  'cli-zakz-p':U + g#type
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
    ) no-error  .
    if error-status :error then message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "e"
      view-as alert-box error
    .
v-order-column  =  (entry(1, v-uf-List_ ,chr(4))) no-error.
v-spis-size     =  (entry(2, v-uf-List_ ,chr(4))) no-error.
v-spis-vis      =  (entry(3, v-uf-List_ ,chr(4))) no-error.
case g#type :
          when  'ФП':U then do:
            if v-order-column  = ? or v-order-column  = "" or error-status :error  then  v-order-column  =  '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23':U     .
            if v-spis-size     = ? or v-spis-size    = ""  or error-status :error  then  v-spis-size     =  '1,3,1,8,20,4,7,9,12,10,10,10,3,9,9,9,12,14,1,9,10,10,10':U     .
            if v-spis-vis      = ? or v-spis-vis     = ""  or error-status :error  then  v-spis-vis      =  'yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,no,no,yes,yes,no,no,no':U     .
          end.
          when  'ОП':U then do:
              if v-order-column  = ? or v-order-column  = "" or error-status :error  then  v-order-column = '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23':U     .
              if v-spis-size     = ? or v-spis-size    = ""  or error-status :error  then  v-spis-size    = '1,3,1,8,20,4,7,10,12,10,10,10,3,9,9,9,12,14,1,9,10,10,10':U     .
              if v-spis-vis      = ? or v-spis-vis     = ""  or error-status :error  then  v-spis-vis     = trim(fill('yes,',23),',') .
          end.
          when 'ОФ':U then do:
              if v-order-column  = ? or v-order-column  = "" or error-status :error  then  v-order-column = '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23':U      .
              if v-spis-size     = ? or v-spis-size    = ""  or error-status :error  then  v-spis-size    = '1,3,1,10,26,4,7,9,12,10,10,10,3,11,11,11,12,14,1,9,10,10,10':U      .
              if v-spis-vis      = ? or v-spis-vis     = ""  or error-status :error  then  v-spis-vis     = 'yes,yes,yes,yes,yes,no,no,no,no,no,no,no,yes,yes,yes,yes,yes,yes,yes,yes,no,no,no':U      .
          end.
end case.
define variable col-h as handle no-undo .
define variable ii as integer   no-undo .
repeat ii = 1 to cur-clmn-loc   :
    col-h = hcolumn [ ii ]  .
    col-h:width  = max (0.1, decimal(entry(ii, v-spis-size))) .
    col-h:visible  = logical(entry(ii,v-spis-vis))  .
 end.
  end.
end procedure.
procedure ver-calc :
  do
  on error undo, return error return-value
  :
  define variable v-not-corr-op as character no-undo .
  define variable p-type as character no-undo .
  define buffer buf_goods for ub.goods  .
for each tmp#zakaz :
  if tmp#zakaz.qnty <> tmp#zakaz.initial-qnty and e-method <> "" then do:
      assign v-not-corr-op = 'no' .
      run clntattr-value (
            input   loc-store-type
          , input   loc-store-code
          , input   'not-corr-op':U
          , output  v-not-corr-op
          , output  p-type
          ) no-error .
      if error-status :error then v-not-corr-op  = 'no' .
      if v-not-corr-op  = 'yes' then do:
        assign v-not-corr-op  = 'no' .
        run clntattr-value (
              input   loc-cli-type
            , input   loc-cli-code
            , input   'not-corr-op':U
            , output  v-not-corr-op
            , output  p-type
        ) no-error .
        if error-status :error then v-not-corr-op  = 'no' .
        if v-not-corr-op  = 'yes' then do:
          message substitute ( "Был произведен автоматический расчет заказа, количество должно быть &1&4Запрещено менять рассчитанные количества  по Поставщику &2&3 " ,
                  tmp#zakaz.initial-qnty ,
                  shar_ord-doc.cli-type ,
                  shar_ord-doc.cli-code ,
                  chr(10) )
          view-as alert-box information .
          return error.
        end.
        find first  buf_goods no-lock where
                    buf_goods.artic = tmp#zakaz.artic and
                    buf_goods.prod-type = tmp#zakaz.prod-type and
                    buf_goods.prod-code = tmp#zakaz.prod-code no-error .
        assign
          tmp#zakaz.gds-code = buf_goods.gds-code
          v-not-corr-op  = 'no'
        .
        run ggoattr-value (
          input   buf_goods.grp-code
          ,input   v-cntxt-host-code-obj
          ,input   v-cntxt-obj-type
          ,input   v-cntxt-obj-code
          ,input   'NotCorrOP':U
          ,output  v-not-corr-op
          ,output  p-type
          ) no-error .
        if error-status :error then v-not-corr-op = 'no' .
        if v-not-corr-op = 'yes' then do:
          message substitute("Был произведен автоматический расчет заказа, количество должно быть &1&4Запрещено менять рассчитанные количества  по Группе товаров (&2) &3 " ,
                  tmp#zakaz.initial-qnty ,
                  buf_goods.grp-code ,
                  buf_goods.grp-name ,
                  chr(10))
          view-as alert-box information .
          return error.
        end.
      end.
    end.
  end.
end.
end procedure.
procedure spec1 :
  do
  on error undo, return error return-value
  :
   find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
   if available shar_ord-doc
   and (( is-edoc-nn and ( shar_ord-doc.ord-int1 = integer('3':U) or shar_ord-doc.ord-int1 = integer('4':U)))
   or   ( is-edi     and   shar_ord-doc.ord-int1 = integer('3':U)))
   then do:
       message "Заказ по системе EDOC/EDI не должен корректироватся в этом статусе. Только НОВЫЙ желтый! " view-as alert-box information .
       return .
   end.
   line-mode = 'ДОБАВЛЕНИЕ':U.
   assign frame dialog-frame loc-contract.
   run add-spec-contract in this-procedure.
  end.
end procedure.
procedure spec2 :
  do
  on error undo, return error return-value
  :
   find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
   if available shar_ord-doc
   and (( is-edoc-nn and ( shar_ord-doc.ord-int1 = integer('3':U) or shar_ord-doc.ord-int1 = integer('4':U)))
   or   ( is-edi     and   shar_ord-doc.ord-int1 = integer('3':U)))
   then do:
       message "Заказ по системе EDOC/EDI не должен корректироватся в этом статусе. Только НОВЫЙ желтый! " view-as alert-box information .
       return .
   end.
   line-mode = 'ДОБАВЛЕНИЕ':U.
   assign frame dialog-frame loc-contract.
   run update-spec-contract in this-procedure.
  end.
end procedure.
procedure update-spec-contract :
define variable ii as integer   no-undo .
define variable v-i as integer   no-undo .
define variable t-ret as logical   no-undo .
define variable r-tmp as recid no-undo .
define variable r-stop as logical no-undo .
define variable r-exit as logical no-undo .
define variable v-rid-list as character no-undo .
define variable v-choice as integer   no-undo .
define buffer bf_contract-specif for ub.contract-specif  .
define buffer old_tmp#zakaz for tmp#zakaz  .
  do
  on error undo, return error return-value
  :
if loc-contract = 0 or loc-contract = ? then return .
define variable vss-include-info98 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  loc-contract,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = loc-contract
      .
END.
    FIND FIRST bf_contract-specif
           NO-LOCK
           WHERE
               bf_contract-specif.Host-code    = i-gl-Host-Code
           AND bf_contract-specif.Contract-num = i-gl-Contract-Code
           NO-ERROR
           .
if not available bf_contract-specif then return .
      run gbl/d-askw.w
        (input "Обновление данных по спецификации"
        ,input "Выберите один из пунктов для обновления данных в заказе" + chr(10)
             + "по спецификации к договору" + chr(10)
        ,input "|"
        ,input "Все поля|Цены и НДС|Количества|Отказ"
        ,input "Обновить цены,количества и НДС из спецификации|"
             + "Обновить только цены и НДС из спецификации|"
             + "Обновить только количества из спецификации|"
             + "Отказ от выполнения операции"
        ,input 1
        ,input 4
        ,output v-choice
        ).
      if v-choice = 4 then do:
        return.
      end.
t-ret =  session:set-wait-state("general") .
ii = 0.
case v-choice :
when 1 then do:
   v-update-price = 0 .
   for each tmp#zakaz :
define variable vss-include-info99 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  loc-contract,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = loc-contract
      .
END.
    FIND FIRST ub.contract-specif
           NO-LOCK
           WHERE
               ub.contract-specif.Host-code    = i-gl-Host-Code
           AND ub.contract-specif.Contract-num = i-gl-Contract-Code
           AND ub.contract-specif.Gds-code     = tmp#zakaz.gds-code
           NO-ERROR
           .
   if not available contract-specif then next .
     ii = ii + 1 .
     run create-tmp in this-procedure  (input "contract-spec":u, "") no-error .
   end.
end.
when 2 then do:
   v-update-price = 0 .
   for each tmp#zakaz :
define variable vss-include-info100 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  loc-contract,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = loc-contract
      .
END.
    FIND FIRST ub.contract-specif
           NO-LOCK
           WHERE
               ub.contract-specif.Host-code    = i-gl-Host-Code
           AND ub.contract-specif.Contract-num = i-gl-Contract-Code
           AND ub.contract-specif.Gds-code     = tmp#zakaz.gds-code
           NO-ERROR
           .
   if not available contract-specif then next .
     ii = ii + 1 .
     run create-tmp in this-procedure  (input "contract-spec":u, "only-price") no-error .
   end.
end.
when 3 then do:
   v-update-price = 0 .
   for each tmp#zakaz :
define variable vss-include-info101 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  loc-contract,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = loc-contract
      .
END.
    FIND FIRST ub.contract-specif
           NO-LOCK
           WHERE
               ub.contract-specif.Host-code    = i-gl-Host-Code
           AND ub.contract-specif.Contract-num = i-gl-Contract-Code
           AND ub.contract-specif.Gds-code     = tmp#zakaz.gds-code
           NO-ERROR
           .
   if not available contract-specif then next .
     ii = ii + 1 .
     run create-tmp in this-procedure  (input "contract-spec":u, "only-qnty") no-error .
   end.
end.
end case.
run full-recount in this-procedure .
choice = ?.
run openbr in this-procedure  .
t-ret =  session:set-wait-state("") .
message
  substitute("Исправлено  &1 из &2 товаров", v-update-price, ii )
  view-as alert-box information
  .
  ii = 0.
  v-update-price = 0 .
end.
end procedure.
procedure add-spec-contract :
define variable ii as integer   no-undo .
define variable v-i as integer   no-undo .
define variable t-ret as logical   no-undo .
define variable r-tmp as recid no-undo .
define variable r-stop as logical no-undo .
define variable r-exit as logical no-undo .
define variable v-rid-list as character no-undo .
define variable v-choice as integer   no-undo .
define buffer bf_contract-specif for ub.contract-specif  .
define buffer old_tmp#zakaz for tmp#zakaz  .
  do
  on error undo, return error return-value
  :
if loc-contract = 0 or loc-contract = ? then return .
define variable vss-include-info102 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  loc-contract,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = loc-contract
      .
END.
    FIND FIRST bf_contract-specif
           NO-LOCK
           WHERE
               bf_contract-specif.Host-code    = i-gl-Host-Code
           AND bf_contract-specif.Contract-num = i-gl-Contract-Code
           NO-ERROR
           .
if not available bf_contract-specif then return .
      run gbl/d-askw.w
        (input "Добавление данных из спецификации"
        ,input "Выберите один из пунктов для добавления в заказ" + chr(10)
             + "товаров по спецификации к договору" + chr(10)
        ,input "|"
        ,input "Все|Выборочно|Отказ"
        ,input "Все недобавленные товары по спецификации|"
             + "Выборочно товары по спецификации|"
             + "Отказ от выполнения операции"
        ,input 1
        ,input 3
        ,output v-choice
        ).
      if v-choice = 3 then do:
        return.
      end.
t-ret =  session:set-wait-state("general") .
ii = 0.
case v-choice :
when 1 then do:
   line-mode = 'ДОБАВЛЕНИЕ':U .
define variable vss-include-info103 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  loc-contract,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = loc-contract
      .
END.
FOR EACH
    ub.contract-specif
     NO-LOCK
     WHERE
         ub.contract-specif.Host-code    = i-gl-Host-Code
     AND ub.contract-specif.Contract-num = i-gl-Contract-Code
     :
     find first old_tmp#zakaz where
                old_tmp#zakaz.gds-code = ub.contract-specif.gds-code no-error .
     if available old_tmp#zakaz then next .
    if not g#type = 'ФП':U then do:
      run ver-izt ( loc-doc-type , contract-specif.gds-code , v-cntxt-obj-type , v-cntxt-obj-code , output v-error) .
      if  v-error then next.
    end.
     ii = ii + 1 .
     run create-tmp in this-procedure  (input "contract-spec":u, "") no-error .
        find first tmp#zakaz where
                   tmp#zakaz.gds-code = ub.contract-specif.gds-code no-error .
         if not  error-status :error  and not t-auto then do:
            r-tmp = recid ( tmp#zakaz   ) .
            run cus/ord-frm.w (input ParParentProc , input recid ( tmp#zakaz )  , input line-mode , output r-stop , output r-exit) .
            if r-stop then do:
              run p-delete ( r-tmp , input-output ii).
              leave.
            end.
            if r-exit then do:
               run p-delete( r-tmp ,input-output ii ) .
            end.
        end.
   end.
end.
when 2 then do:
   run str/contspec.w (input parparentproc,
                      input "b-sel,b-mark",
                      input 'ПРОСМОТР':U,
                      input v-cntxt-host-code-obj,
                      input loc-contract,
                      output v-rid-list) .
      if v-rid-list = '':u then do:
        message "Нет выбранных товаров по спецификации."
          view-as alert-box.
      end.
    line-mode = 'ДОБАВЛЕНИЕ':U .
    do v-i = 1 to num-entries(v-rid-list) :
     find ub.contract-specif where recid(ub.contract-specif) = integer(entry(v-i, v-rid-list)) no-lock no-error.
     if error-status :error then next.
     run ver-izt ( loc-doc-type , ub.contract-specif.gds-code ,v-cntxt-obj-type , v-cntxt-obj-code , output v-error) .
     if  v-error then next.
     ii = ii + 1 .
     run create-tmp in this-procedure  (input "contract-spec":u, "") no-error .
        find first tmp#zakaz where
                   tmp#zakaz.gds-code = ub.contract-specif.gds-code no-error .
        if not  error-status :error  and not t-auto then do:
            r-tmp = recid ( tmp#zakaz   ) .
            run cus/ord-frm.w (input ParParentProc , input r-tmp  , input line-mode , output r-stop , output r-exit) .
            if r-stop then do:
              run p-delete ( r-tmp , input-output ii).
              leave.
            end.
            if r-exit then do:
               run p-delete( r-tmp ,input-output ii ) .
            end.
        end.
   end.
end.
end case.
run full-recount in this-procedure .
choice = ?.
run openbr in this-procedure  .
t-ret =  session:set-wait-state("") .
message
  'Добавлено'
  ii 'товаров'
  view-as alert-box information
  .
  ii = 0.
  v-update-price = 0 .
end.
end procedure.
procedure ver-izt :
define input  parameter p-event-code as character no-undo .
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-error as logical   no-undo .
define variable p-Ok as logical   no-undo .
define variable p-mess as character no-undo .
  do
  on error undo, return error return-value
  :
  p-error = false .
define variable vss-include-info104 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  p-event-code
  ,input  p-gds-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,input  no
  ,output p-Ok
  ,output p-mess
  ) no-error.
     if p-mess <> "" then do:
     end.
    if p-ok = false then p-error = true  .
  end.
end procedure.
procedure choose-contract :
define variable varcontract-code like ub.contract.contract-code no-undo.
define buffer buf_contract for ub.contract.
  find first buf_contract where buf_contract.host-code = v-cntxt-host-code-obj and
                                buf_contract.cli-type  = loc-cli-type and
                                buf_contract.cli-code  = loc-cli-code no-lock no-error.
  if available buf_contract then do:
      run check-contract-code in this-procedure (input  "choose":u,
                                                 input  v-cntxt-host-code-obj,
                                                 input  loc-cli-type,
                                                 input  loc-cli-code,
                                                 input  ?,
                                                 input  parparentproc,
                                                 input  shar_ord-doc.doc-date,
                                                 input  'при':U ,
                                                 output varcontract-code) no-error.
      if error-status :error    or
         varcontract-code = ?  or
         varcontract-code = 0  then do:
      end.
      else do:
        assign
          loc-contract:screen-value in frame dialog-frame  = string(varcontract-code)
          loc-contract = varcontract-code
          shar_ord-doc.contract-code = varcontract-code
        .
      end.
  end.
end procedure.
