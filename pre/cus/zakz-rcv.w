define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter g#type         as character no-undo .
define input  parameter g#stat         as character no-undo .
define input  parameter list-mode      as character no-undo .
define input  parameter p-doc-rec      as recid     no-undo .
define input  parameter p-buttons      as character no-undo .
define input  parameter p-str-recid    as character no-undo .
define output parameter del-list       as character no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список Заказов и Поставок".
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
  define temp-table  tt-tax no-undo
field tax-code    like ub.tax.tax-code
FIELD individual  like ub.tax.individual
FIELD tax-name    like ub.tax.tax-name format "X(12)" column-label "Налог"
field rate-code   like ub.tax-rate.rate-code
FIELD rate-name   like ub.tax-rate.rate-name FORMAT "X(12)"
FIELD tax-type    like ub.tax.tax-type
field rate-value  like ub.tax-rate-value.rate-value
FIELD tax-rate-gds-rc  as recid
FIELD to-cashdesk like ub.tax.to-cashdesk
index tax-code is unique primary tax-code.
function cross-list returns logical (
  input parfirst-stream  as character,
  input parsecond-stream as character,
  input pardelim         as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  define variable vari            as integer no-undo .
  define variable varresult-cross as logical no-undo .
  assign
    varresult-cross = no
  .
  def var v-num-parfirst-stream as integer no-undo .
  assign
    v-num-parfirst-stream = num-entries(parfirst-stream, pardelim)
  .
  do vari = 1 to v-num-parfirst-stream
  :
    if lookup(entry(vari, parfirst-stream, pardelim)
             ,parsecond-stream
             ,pardelim
             ) > 0 then do:
      assign
        varresult-cross = yes
      .
      leave.
    end.
  end.
  return varresult-cross .
end function.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function octal-to-char return character
( p-string as character ) :
  def var v-asc     as integer no-undo .
  def var v-new-asc as integer no-undo .
  def var ind       as integer no-undo .
  if length(p-string) <> 3 then do:
    return ? .
  end.
  assign
    v-asc = 0
  .
  do ind = 1 to length(p-string)
  :
    assign
      v-new-asc = asc(substring(p-string, ind, 1)) - asc('0')
    .
    if v-new-asc < 0 or v-new-asc >= 8 then do:
      return ? .
    end.
    assign
      v-asc = v-asc * 8 + v-new-asc
    .
  end.
  return chr(v-asc) .
end function .
function char-to-octal return character
( p-chr as character ) :
  def var v-asc    as integer   no-undo .
  def var ind      as integer   no-undo .
  def var v-string as character no-undo .
  if length(p-chr) <> 1 then do:
    return ? .
  end.
  assign
    v-asc    = asc(p-chr)
    v-string = ""
  .
  do ind = 1 to 3
  :
    assign
      v-string = chr( v-asc mod 8 + asc('0')) + v-string
    .
    assign
      v-asc = truncate(v-asc / 8, 0)
    .
  end.
  return v-string .
end.
function str-encode return character
(   p-init-string       as character
  , p-encode-char       as character
  , p-special-char-list as character
) :
  def var p-encode-string as character no-undo .
  def var ind                as integer no-undo .
  def var v-num-special-char as integer no-undo .
  def var v-special-char     as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = ? then do:
    return "?" .
  end.
  if p-init-string = "?" then do:
    return p-encode-char + char-to-octal("?") .
  end.
  assign
    v-num-special-char = length(p-special-char-list)
    p-encode-string    = replace(p-init-string
                                ,p-encode-char
                                ,p-encode-char + char-to-octal(p-encode-char)
                                )
  .
  do ind = 1 to v-num-special-char
  :
    assign
      v-special-char = substring(p-special-char-list, ind, 1)
    .
    if v-special-char <> p-encode-char then do:
      assign
        p-encode-string = replace (p-encode-string
                                  ,v-special-char
                                  ,p-encode-char + char-to-octal(v-special-char)
                                  )
      .
    end.
  end.
  return p-encode-string .
end.
function str-decode returns character
  (p-init-string   as character
  ,p-encode-char   as character
  ) :
  def var p-decode-string as character no-undo .
  def var ind                       as integer no-undo .
  def var v-num-entries-init-string as integer no-undo .
  def var v-sub-phrase              as character no-undo .
  def var v-special-char            as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = "?" then do:
    return ? .
  end.
  assign
    v-num-entries-init-string = num-entries(p-init-string, p-encode-char)
  .
  if v-num-entries-init-string > 1 then do:
    assign
      p-decode-string = entry(1, p-init-string, p-encode-char)
    .
    do ind = 2 to v-num-entries-init-string
    :
      assign
        v-sub-phrase = entry(ind, p-init-string, p-encode-char)
      .
      assign
        v-special-char = octal-to-char(substring(v-sub-phrase, 1, 3))
      .
      if v-special-char <> ? then do:
        assign
          p-decode-string = p-decode-string
                          + v-special-char
                          + substring(v-sub-phrase, 4)
        .
      end.
      else do:
        assign
          p-decode-string = p-decode-string
                          + p-encode-char
                          + v-sub-phrase
        .
      end.
    end.
  end.
  else do:
    assign
      p-decode-string = p-init-string
    .
  end.
  return p-decode-string .
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info12 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info12, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info12, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info12, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info12, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info12 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info12, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info12 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info12, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info12, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info12, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info12, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info12, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info12, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info12 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info12 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info12, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info12, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info12, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info12 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info12 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info12, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info12, v-inform, v-tbl-name ).
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable g#host-name  as character no-undo .
define variable g#host-code  as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#log        as logical   no-undo .
define variable is-edi as logical no-undo .
define variable is-edoc-nn as logical no-undo .
define new shared variable doc-rec   as recid   no-undo .
define new shared variable next-prev as logical no-undo .
define temp-table tt-ord-doc-rcv no-undo
        field nn as integer
        field gds-name like ub.goods.gds-name
        field gds-sort like ub.goods.sort
        field gds-code like ub.goods.gds-code
        field unit-cli like ub.ord-line-rcv.unit-cli
        field OKEI     as character
        field cli-art  as character
        field artic    like ub.goods.artic
        field cli-qnty like ub.ord-line-rcv.cli-qnty
        field price-cli like ub.ord-line-rcv.price-cli
        field summa   as decimal
        field cost    like ub.ord-line-rcv.price-cli
        field cli-name like ub.ord-doc.cli-name
        field cli-code like ub.ord-doc.cli-code
        field cli-type like ub.ord-doc.cli-type
        field addres1  like ub.firm.addres1
        field addres2  like ub.firm.addres2
        index pi nn
        .
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
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
if store-type = ? or store-type = "" then do:
    g#host-code = v-cntxt-host-code-obj .
    define buffer buf_clients-name for ub.clients  .
    find first buf_clients-name no-lock where buf_clients-name.obj-code =  g#host-code and
                                              buf_clients-name.obj-type = 'орг':U no-error .
   g#host-name = buf_clients-name.obj-name.
end.
else do:
  g#host-code   = v-cntxt-host-code-obj.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  store-type
  ,input  store-code
  ,output g#host-code
  ,output g#host-name
  )  .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  store-type
  ,input  store-code
  ,output to-day
  )  .
end.
run get-report-num in parParentProc ( output g#report-num ).
define new shared variable x-mode as character  no-undo .
define NEW SHARED var br-handle as handle no-undo.
define NEW SHARED var br-rcv-handle as handle no-undo.
define NEW SHARED buffer shar-buf_ord-doc for ub.ord-doc.
define NEW SHARED buffer bufs_ord-doc-rcv for ub.ord-doc-rcv.
define variable v-fo          as   character             no-undo.
define buffer t-doc-line for ub.ord-line.
define variable pay-type as char format "x(64)" no-undo .
DEFINE NEW SHARED VARIABLE Sort-gr AS LOGICAL INIT false
     LABEL "Сортировать по группам товаров"
     VIEW-AS TOGGLE-BOX
     size 42.25 by 0.75 NO-UNDO.
DEFINE NEW Shared VARIABLE print-graft AS LOGICAL INIT true
     LABEL "Отладочная печать"
     VIEW-AS TOGGLE-BOX
     size 42.25 by 0.75 NO-UNDO.
def new shared buffer sch-pay for ub.pay-type.
def new shared buffer sch-curr for ub.currency.
def new shared buffer sch-cli for ub.clients.
def new shared buffer sch-cons for ub.ord-cons.
def new shared buffer sch-contract for ub.contract.
def new shared buffer sch-inv for ub.ord-doc.
def buffer cli-buf for ub.clients.
def buffer t-d-b for ub.ord-doc.
define variable  sch-field as char no-undo.
define variable  mark as char no-undo.
define variable  blank#name as character no-undo .
define variable  blank#name-rcv as character no-undo .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable old-list as char no-undo.
define variable old-stat as char no-undo.
def buffer c-in for ub.ord-doc.
define variable chg-qnty like ub.gds-dtl.doc-qnty no-undo.
define variable payment-type as char no-undo.
define variable choice   as      logical no-undo    init ?.
define variable objects as integer no-undo.
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход ":L
     TOOLTIP "Выход из режима"
     SIZE 12 BY 1.
DEFINE BUTTON b-sel
     LABEL "Вы&бор ":L
     TOOLTIP "Выход из режима и выбор текущего номера заказа"
     SIZE 12 BY 1.
DEFINE BUTTON b-rep
     LABEL "О&тчеты":L
     TOOLTIP "Список отчетов по заказам"
     SIZE 12 BY 1.
DEFINE BUTTON b-sch
     LABEL "&Фильтр":L
     TOOLTIP "Фильтр по списку заказов"
     SIZE 12 BY 1.
DEFINE BUTTON b-payment
     LABEL "П&латежи":L
     TOOLTIP "Платежи по документу и по контрагенту"
     SIZE 12 BY 1.
DEFINE BUTTON b-sost
     LABEL "Отказ":L
     TOOLTIP "Отказать заказу"
     SIZE 12 BY 1.
DEFINE BUTTON b-exec
     LABEL "Расч&ёт":L
     TOOLTIP "Функции автоматического заказа"
     SIZE 13 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 12 BY 1.
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     TOOLTIP "Добавить новый заказ"
     SIZE 9 BY 1.
DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     TOOLTIP "Просмотр заказа без корректировки"
     SIZE 12 BY 1.
DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     TOOLTIP "Корректировка заказа"
     SIZE 12 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удалить":L
     TOOLTIP "Удалить заказ"
     SIZE 12 BY 1.
DEFINE BUTTON b-close
     LABEL "&Закрыть":L
     TOOLTIP "Закрыть корректировку заказа"
     SIZE 12 BY 1.
DEFINE BUTTON b-open
     LABEL "&Открыть":L
     TOOLTIP "Открыть корректировку заказа"
     SIZE 12 BY 1.
DEFINE BUTTON b-history
     LABEL "&История":L
     TOOLTIP "История заказа"
     SIZE 12 BY 1.
DEFINE BUTTON b-copy
     LABEL "К&опия":L
     TOOLTIP "Копирование заказа"
     SIZE 13 BY 1.
DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     TOOLTIP "Печать заказа"
     SIZE 12 BY 1.
DEFINE BUTTON b-print-rcv
     IMAGE-UP FILE "cmp/b-print.bmp":U
     IMAGE-DOWN FILE "cmp/b-print.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/b-print.bmp":U
     TOOLTIP "Печать поставки"
     SIZE 4 BY 1.
DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1.
DEFINE BUTTON b-cons
     LABEL "&s":L
     TOOLTIP "Объединение нескольких заказов в один, ALT-S"
     SIZE 3 BY 1.
DEFINE BUTTON b-email
    LABEL "&s":L
    TOOLTIP "Отправка файла на e-mail"
    SIZE 3 BY 1.
DEFINE VARIABLE agnt-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE wrkr-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-user-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE boss-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 34 BY 1 NO-UNDO.
DEFINE VARIABLE ed-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 99 BY 2 TOOLTIP "Дополнительные сведения по заказу"
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE BUTTON b-add-2
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Создать новую поставку".
DEFINE BUTTON b-chg-2
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Корректировка поставки".
DEFINE BUTTON b-close-2
     LABEL "&Закрыть":L
     SIZE 10 BY 1 TOOLTIP "Закрыть поставку".
DEFINE BUTTON b-del-2
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалить поставку".
DEFINE BUTTON b-lkp-2
     LABEL "&Просмотр":L
     SIZE 10 BY 1 TOOLTIP "Просмотр поставки без корректировки".
DEFINE BUTTON b-add-obj-2
     LABEL "По &объектам":L
     SIZE 12 BY 1 TOOLTIP "Добавить поставки по объектам".
def MENU m-rep
    .
DEFINE MENU M-print
       MENU-ITEM m_print1       LABEL "ТОРГ-26" ACCELERATOR "ALT-7"
       MENU-ITEM m_print2       LABEL "Печать по форме Поставщика" ACCELERATOR "ALT-8"
       MENU-ITEM m_print6       LABEL "Заказ по форме поставщика с детализацией по поставкам"
       MENU-ITEM m_print4       LABEL "Стандартная форма"
       menu-item m_print5       label "Заказ с детализацией по объектам"
       RULE
       MENU-ITEM m_print3       LABEL "Выбор формы печати" ACCELERATOR "ALT-9"
 .
DEFINE MENU M-print-rcv
       MENU-ITEM m_print1-rcv       LABEL "Печать Поставки"
       MENU-ITEM m_print2-rcv       LABEL "Печать по форме Поставщика"
       RULE
       MENU-ITEM m_print3-rcv       LABEL "Выбор формы печати"
 .
def MENU m-payment
    MENU-ITEM m-client       Label "Все платежи контрагента" ACCELERATOR "ALT-3"
    MENU-ITEM m-doc          Label "Платежи по документу" ACCELERATOR "ALT-4"
  .
def MENU m-exec
    MENU-ITEM m-exp          Label "Расчет потребности товаров"   ACCELERATOR "ALT-5"
    RULE
    MENU-ITEM m-cycle        Label "Расчет цикличных заказов" ACCELERATOR "ALT-6"
    MENU-ITEM m-del-cycle    Label "Снять пометку у цикличного заказа"
    RULE
    MENU-ITEM m-cl           Label "Закрытие выполненных заказов"
    MENU-ITEM m-del          Label "Удаление невыполненных заказов"
    RULE
    MENU-ITEM m-imp          Label "Импорт заказов"                  ACCELERATOR "ALT-0"
    menu-item m-edoc-nn      Label "Отправить новый заказ вручную (по EDOC_NN/EDI)"
    menu-item m-edoc-rpl-ok  Label "Отправить подтверждения rpl-ok,pst-ok вручную (по EDOC_NN)"
    menu-item m-edoc-trn     Label "Отправить накладную вручную (по EDOC_NN)"
    menu-item m-edoc-ok      Label "Получить ответы вручную (по EDOC_NN)"
    RULE
    menu-item m-sost         Label "Состояние заказа"
    RULE
    MENU-ITEM m_gen-1        Label "Генерация ФО поставщиков"
    MENU-ITEM m_gen-1_buyer  Label "Генерация ФО покупателей"
    MENU-ITEM m_lkp-fo       Label "Просмотр  ФО"
    MENU-ITEM m_gen-2        Label "Отказаться от генерации ФО"
    MENU-ITEM m_gen-3        Label "Снять признак - есть генерация ФО"
    MENU-ITEM m_gen-4        Label "Снять 'не опред'"
    RULE
    MENU-ITEM m_gen-2-2   Label "Отказаться от генерации 2го-ФО"
    MENU-ITEM m_gen-3-2   Label "Снять признак - есть генерация 2го-ФО"
    MENU-ITEM m_gen-4-2   Label "Снять 'не опред' 2го-ФО"
  .
DEFINE new shared VARIABLE sch-code AS CHARACTER format "x(12)" VIEW-AS fill-in SIZE 12 BY 1 NO-UNDO.
DEFINE new shared VARIABLE sch-date AS date VIEW-AS fill-in SIZE 12 BY 1 FORMAT "99/99/9999" NO-UNDO.
DEFINE new shared VARIABLE sch-fact AS date VIEW-AS fill-in SIZE 12 BY 1 FORMAT "99/99/9999" NO-UNDO.
DEFINE new shared var sch-num as integer view-as fill-in size 3 by 1 no-undo.
DEFINE new shared QUERY br-docs for shar-buf_ord-doc SCROLLING.
DEFINE QUERY BR-rcv FOR
      ub.ord-doc-rcv,
      bufs_ord-doc-rcv,
      ub.ord-chain ,
      ub.trn-doc SCROLLING.
FUNCTION f-fo RETURNS CHARACTER
  ( buffer loc-t-doc for ub.ord-doc ) :
define buffer bufb_contract for ub.contract  .
define variable v-proc as character no-undo .
   find first bufb_contract no-lock where
              bufb_contract.contract-code = loc-t-doc.contract-code and
              bufb_contract.host-code     = loc-t-doc.host-code and
              bufb_contract.usl-opl       = 'Предоплата(%)':U
              no-error .
    if available bufb_contract then v-proc = "%" + trim( string(bufb_contract.srok-opl)).
                               else v-proc = "".
if v-proc = ? then v-proc = "err" .
 if loc-t-doc.cr-fo = yes then do:
   if loc-t-doc.status_ = 'факт':U
   then do:
    if loc-t-doc.cr-fo2 = yes then return substring(string ( loc-t-doc.fo-date, "99/99/99"),1,5) + "-" + substring (string (loc-t-doc.fo-date2, "99/99/99"),1,5)  .
    else return string (loc-t-doc.fo-date, "99/99/99") + v-proc.
   end.
   else return string (loc-t-doc.fo-date, "99/99/99") + v-proc.
 end.
 else do:
   if loc-t-doc.need-fo = 0 then do:
     return "--------".
   end.
   if loc-t-doc.need-fo = 1 then do:
     return "".
   end.
   if loc-t-doc.need-fo = 2 then do:
     return "не опред".
   end.
 end.
END FUNCTION.
FUNCTION mark-string RETURN CHAR (buffer loc-t-doc for shar-buf_ord-doc ).
  if can-do (del-list, string (recid (loc-t-doc))) then RETURN "*".
  else RETURN "".
END FUNCTION.
  define variable str-status-edoc-nn as character no-undo .
define variable v-color as integer no-undo init ?.
DEFINE BROWSE br-docs QUERY br-docs NO-LOCK DISPLAY
      mark-string (buffer shar-buf_ord-doc) @ mark COLUMN-LABEL "*" FORMAT "x(1)"
      if shar-buf_ord-doc.order-type = 1 then "*" Else (if shar-buf_ord-doc.order-type = 4 then chr(176) Else "" ) COLUMN-LABEL "Ц" FORMAT "x(1)"    COLUMN-FGCOLOR 3
      (substring (shar-buf_ord-doc.doc-type, 1, 2)) COLUMN-LABEL "Т" FORMAT "x(2)"
      IF (shar-buf_ord-doc.status_ = 'факт':U or shar-buf_ord-doc.status_ = 'закрыто':U) THEN (shar-buf_ord-doc.status_ + string(shar-buf_ord-doc.flag_,"+/-")) ELSE (shar-buf_ord-doc.status_) COLUMN-LABEL "Статус" format "x(8)"
      status-edoc-edi-light (buffer shar-buf_ord-doc,
                              input is-edoc-nn,
                              input is-edi,
                              output v-color)
                              @ str-status-edoc-nn COLUMN-LABEL "Статус EDOC/EDI" FORMAT "x(20)"
      shar-buf_ord-doc.doc-date   format "99/99/9999" column-label "Дата"
      shar-buf_ord-doc.fact-date  format "99/99/9999" COLUMN-LABEL "Факт"
      shar-buf_ord-doc.cli-type + " " + String(shar-buf_ord-doc.cli-code)   format "x(13)" column-label "Код"
      shar-buf_ord-doc.cli-name  format "x(27)"
      shar-buf_ord-doc.doc-code   format "x(12)"
      shar-buf_ord-doc.cons-code  column-label "СЗФП"
      shar-buf_ord-doc.host-code  format "9999999999" column-label "Фирма"
      shar-buf_ord-doc.obj-type + " " + string(shar-buf_ord-doc.obj-code)  column-label "Объект"
      shar-buf_ord-doc.ship-date column-label "Доставка"
      string(shar-buf_ord-doc.ship-time,"hh:mm") column-label "Время" format "x(5)"
      entry(1, shar-buf_ord-doc.cli-out-doc, chr(4)) format "x(12)" column-label "№ по ПОСТ-КУ"
      shar-buf_ord-doc.contract-code format ">>>>>>>>>>>>9" column-label "№ договора"
      f-fo ( buffer shar-buf_ord-doc ) @ v-fo column-label "ФО" format "x(11)"
      shar-buf_ord-doc.ord-date1 format  "99/99/9999" column-label "Выгрузка"
    WITH SIZE 99 BY 9 separators
     TITLE "Список заказов".
    DEFINE BROWSE BR-rcv  QUERY BR-rcv NO-LOCK DISPLAY
      if ub.ord-doc-rcv.ord-int2 = integer('2':U) then "!" else "" column-label "!" FORMAT "x(1)"  COLUMN-FGCOLOR 12
      ub.ord-doc-rcv.rcv-code column-label "№ пост-ки"
      ub.ord-doc-rcv.status_
      ub.ord-doc-rcv.doc-date FORMAT "99/99/99"
      (if ub.ord-doc-rcv.doc-type = "in":U then "внутр" else "внешн") column-label "Тип" FORMAT "x(5)"
      ub.ord-doc-rcv.obj-type + " " + string(ub.ord-doc-rcv.obj-code)  column-label "Объект"
      ub.ord-doc-rcv.cli-type + " " + string(ub.ord-doc-rcv.cli-code)  column-label "Поставщик"
      ub.ord-doc-rcv.ship-date column-label "Доставка" FORMAT "99/99/99"
      string(ub.ord-doc-rcv.ship-time,"hh:mm") column-label "Время" FORMAT "x(5)"
      ub.trn-doc.doc-code column-label "№ ПН"
      ub.trn-doc.status_
      ub.trn-doc.doc-date FORMAT "99/99/99"
      ub.trn-doc.fact-date FORMAT "99/99/99"
      string(ub.trn-doc.fact-time,"hh:mm") column-label "Время"   FORMAT "x(5)"
    WITH NO-ROW-MARKERS SEPARATORS size 99 BY 5.76
             TITLE "Поставки по заказу".
DEFINE FRAME d-all-docs
     b-quit     AT ROW 1 COL 2
     b-sel      AT ROW 1 COL 14
     b-rep      AT ROW 1 COL 26
     b-sch      AT ROW 1 COL 38
     b-payment  AT ROW 1 COL 50
     b-sost     AT ROW 1 COL 62
     b-exec     AT ROW 1 COL 74
     b-help     AT ROW 1 COL 87
     b-mark    AT ROW 2 COL 2
     b-add     AT ROW 2 COL 5
     b-lkp     AT ROW 2 COL 14
     b-chg     AT ROW 2 COL 26
     b-del     AT ROW 2 COL 38
     b-close   AT ROW 2 COL 50
     b-open    AT ROW 2 COL 62
     b-history AT ROW 2 COL 62
     b-copy    AT ROW 2 COL 74
     b-cons    at row 2 col 89.5
     b-print   AT ROW 2 COL 87
     b-email   AT ROW 2 COL 92.5
     "Поиск:"  VIEW-AS TEXT SIZE 7 BY 1 AT ROW 3 COL 1.5
     sch-code  at row 3 col 11 label "&Начало номера"
     sch-date  at row 3 col 42 label "Д&ата"
     sch-fact  at row 3 col 62 label "Фа&кт"
     br-docs                    AT ROW 4  COL 1
     pay-type                   at row 13 col 5 COLON-ALIGNED LABEL "Опл" VIEW-AS FILL-IN SIZE 25 BY 1 fgcolor 4
     shar-buf_ord-doc.tot-lines at row 13 col 85 COLON-ALIGNED LABEL "Кол-во строк" VIEW-AS TEXT SIZE 10 BY .79 fgcolor 4
     boss-name at row 14 col 5  COLON-ALIGNED LABEL "М-р"  VIEW-AS FILL-IN SIZE 20 BY 1 fgcolor 4
     agnt-name at row 14 col 31 COLON-ALIGNED LABEL "Исп"  VIEW-AS FILL-IN SIZE 20 BY 1 fgcolor 4
     wrkr-name at row 14 col 57 COLON-ALIGNED LABEL "Кл-к" VIEW-AS FILL-IN SIZE 20 BY 1 fgcolor 4
     v-user-name at row 14 col 85 COLON-ALIGNED LABEL "Опер" VIEW-AS FILL-IN SIZE 14 BY 1 fgcolor 4
     sch-num     at row 14 col 70 label "Найдено" fgcolor 12
     ed-notes AT ROW 15 COL 1 no-label bgcolor 8 fgcolor 4
     b-add-2     AT ROW 17.5 COL 1
     b-add-obj-2 AT ROW 17.5 COL 11
     b-lkp-2     AT ROW 17.5 COL 23
     b-chg-2     AT ROW 17.5 COL 33
     b-del-2     AT ROW 17.5 COL 43
     b-close-2   AT ROW 17.5 COL 53
     b-print-rcv at row 17.5 col 93
     BR-rcv      AT ROW 18.5 COL 1
     SPACE(0) SKIP(0.5)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
         DEFAULT-BUTTON b-quit.
  if g#type = 'ФП':U  then do:
     enable  b-add-obj-2  with FRAME d-all-docs .
     display  b-add-obj-2  with FRAME d-all-docs .
  end.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION status-edoc-nnno RETURN CHAR (buffer loc-o-doc for ub.ord-doc
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
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
FUNCTION status-is-edoc-nnno RETURN logical ( input p-is-edoc-nn   as logical
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
FUNCTION status-is-edino RETURN logical ( input p-is-edi as logical
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
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
FUNCTION get-glnno returns character ( input p-obj-type as character
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
FUNCTION get-type-code-from-glnno returns logical ( input  p-gln      as character
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
FUNCTION status-edoc-edi-lightno RETURN CHAR (buffer loc-o-doc for ub.ord-doc
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
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fltfield-clear :
  define output parameter loc-fld as character no-undo.
  define output parameter loc-lab as character no-undo .
  define output parameter loc-spr as character no-undo .
  define output parameter loc-dim as character no-undo .
  assign
    loc-fld = ""
    loc-lab = ""
    loc-spr = ""
    loc-dim = "0"
  .
end procedure .
procedure fltfield-add :
  define input        parameter par-fld as character no-undo.
  define input        parameter par-lab as character no-undo .
  define input        parameter par-spr as character no-undo .
  define input-output parameter loc-fld as character no-undo.
  define input-output parameter loc-lab as character no-undo .
  define input-output parameter loc-spr as character no-undo .
  define input-output parameter loc-dim as character no-undo .
  do
  on error undo, return error
  :
    assign
    loc-fld = if loc-dim = '0'
              then par-fld
              else (loc-fld + chr(44) + par-fld)
    loc-lab = if loc-dim = '0'
              then par-lab
              else (loc-lab + chr(44) + par-lab)
    loc-spr = if loc-dim = '0'
              then par-spr
              else (loc-spr + chr(44) + par-spr)
    loc-dim = (if num-entries(loc-dim) > 1 then (entry(1, loc-dim) + chr(44)) else "") +
              string(integer(if num-entries(loc-dim) > 1
                            then entry(2, loc-dim)
                            else entry(1, loc-dim)
                            ) + 1)
    no-error
    .
  end.
end procedure.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-fltopend-rowid as rowid extent 18 no-undo .
procedure fltopend_fltopend :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
  do
  on error undo, return error
  :
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
assign
v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                   p-where-cond + chr(32)  +
                   p-use-indFIRST-query-tail + chr(32) +
                   p-use-ind-sort-clmn-by + chr(32) +
                   p-indexed-reposition
.
assign
glog = p-qh:query-prepare(v-prepare-string) no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
assign
glog = p-qh:query-open no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
  end.
end procedure.
procedure fltopend_fltfindd :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-index-phrase as character no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-recid as recid no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  glog = p-bh:find-by-rowid( p-rowid, p-lock) no-error.
  create buffer v-bh for table p-bh buffer-name p-bh:name.
  create query v-qh.
  v-qh:set-buffers(v-bh).
  v-prepare-string = substitute("for each &1 &2 &3"
                                  ,v-bh:name
                                  ,p-where-cond
                                  ,p-use-index-phrase).
  glog = v-qh:query-prepare(v-prepare-string) no-error.
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  if p-next then do:
    v-qh:reposition-to-rowid(p-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  v-recid = v-bh:recid no-error .
  delete object v-qh.
  delete object v-bh.
  return string(v-recid) .
end.
end procedure.
procedure fltopend_fltfindq :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
define output parameter p-fltopend-rowid as rowid extent 18 no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo extent 18.
define variable v-rowid as rowid no-undo extent 18.
define variable v-ii as integer no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  create query v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    create buffer v-bh[v-ii] for table p-qh:get-buffer-handle(v-ii) buffer-name p-qh:get-buffer-handle(v-ii):name .
    assign
    v-rowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid
    no-error.
    v-qh:add-buffer(v-bh[v-ii]).
  end.
  assign
  v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                    p-where-cond + chr(32)  +
                    p-use-indFIRST-query-tail + chr(32) +
                    p-use-ind-sort-clmn-by + chr(32) +
                    p-indexed-reposition
  .
  glog = v-qh:query-prepare( v-prepare-string) no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  if p-next then do:
    glog = v-qh:reposition-to-rowid(v-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  do v-ii = 1 to p-qh:num-buffers:
    assign
    p-fltopend-rowid[v-ii] = v-bh[v-ii]:rowid
    no-error.
  end.
  delete object v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    delete object v-bh[v-ii].
  end.
end.
end procedure.
def var vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure orddocattr-value :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.ord-doc-attr.doc-code   no-undo .
    define input  parameter p-code     like ub.ord-doc-attr.attr-code  no-undo .
    define output parameter p-value    like ub.ord-doc-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_ord-doc-attr for ub.ord-doc-attr .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    run orddocattr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-doc-attr no-lock
      where buf_ord-doc-attr.doc-code  = p-doc-code
        and buf_ord-doc-attr.attr-code = p-code
      no-error .
    if avail buf_ord-doc-attr then do:
      assign
        p-value =  buf_ord-doc-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure orddocattr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-doc-attr.doc-code   no-undo .
    define input parameter p-code     like ub.ord-doc-attr.attr-code  no-undo .
    define input parameter p-value    like ub.ord-doc-attr.attr-value no-undo .
    define buffer buf_ord-doc-attr for ub.ord-doc-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    run orddocattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-doc-attr exclusive-lock
      where buf_ord-doc-attr.doc-code  = p-doc-code
        and buf_ord-doc-attr.attr-code = p-code
      no-error .
    if not available buf_ord-doc-attr then do:
      create buf_ord-doc-attr .
      assign
        buf_ord-doc-attr.doc-code  = p-doc-code
        buf_ord-doc-attr.attr-code = p-code
      .
    end.
    assign
      buf_ord-doc-attr.attr-value = p-value
    .
end.
end procedure.
procedure orddocattr-exist :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-doc-attr.doc-code   no-undo .
    define input parameter p-code     like ub.ord-doc-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_ord-doc-attr for ub.ord-doc-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    run orddocattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-doc-attr no-lock
      where buf_ord-doc-attr.doc-code  = p-doc-code
        and buf_ord-doc-attr.attr-code = p-code
      no-error .
    if  available buf_ord-doc-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure orddocattr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-doc-attr.doc-code   no-undo .
    define input parameter p-code     like ub.ord-doc-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_ord-doc-attr for ub.ord-doc-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    define variable v-other          as character no-undo .
    run orddocattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-doc-attr exclusive-lock
      where buf_ord-doc-attr.doc-code  = p-doc-code
        and buf_ord-doc-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_ord-doc-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_ord-doc-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure orddocattr-code :
  do on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-fillin_width   as integer   no-undo .
    define output parameter p-fillin_height  as integer   no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-proc           as character no-undo .
    define output parameter p-func           as character no-undo .
    define output parameter p-sort           as integer   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'cycle-doc-code':U then do:     assign     p-label          = "Номер заказа цикличного"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Номер заказа цикличного"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-day':U then do:     assign     p-label          = "период цикличности"     p-type           = 'I':U      p-format         = ">>>>>>9"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "период цикличности"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-done':U then do:     assign     p-label          = "Заказ рассчитан"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Заказ рассчитан"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'exch-code':U then do:     assign     p-label          = "Валюта Заказа"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Валюта Заказа"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'exch-rate':U then do:     assign     p-label          = "Валюта Заказа"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Валюта Заказа"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'exch-scale':U then do:     assign     p-label          = "Валюта Заказа"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Валюта Заказа"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'base-rate':U then do:     assign     p-label          = "Валюта Заказа"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Валюта Заказа"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'base-scale':U then do:     assign     p-label          = "Валюта Заказа"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Валюта Заказа"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-contract-code':U then do:     assign     p-label          = "договор"     p-type           = 'C':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "договор"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-ship-date':U then do:     assign     p-label          = "дата доставки"     p-type           = 'T':U      p-format         = "99/99/9999"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "дата доставки"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-ship-time':U then do:     assign     p-label          = "время доставки"     p-type           = 'I':U      p-format         = "x(16)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "время доставки"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-date1':U then do:     assign     p-label          = "период продаж"     p-type           = 'T':U      p-format         = "99/99/9999"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "период продаж"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-date2':U then do:     assign     p-label          = "период продаж"     p-type           = 'T':U      p-format         = "99/99/9999"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "период продаж"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'cycle-doc-date':U then do:     assign     p-label          = "дата заказа"     p-type           = 'T':U      p-format         = "99/99/9999"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "дата заказа"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'ora-exp-seq-num':U then do:     assign     p-label          = "Номер выгрузки в Oracle Retail"     p-type           = 'I':U      p-format         = "999999999"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Номер выгрузки в Oracle Retail"     p-user-can-edit  = false     p-output-display = false     p-sort           = 100     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут строки заказа" + " " + p-code .
      end.
    end.
  end.
end procedure.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ordlineattr-value :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.ord-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.ord-line-attr.gds-code   no-undo .
    define input  parameter p-code     like ub.ord-line-attr.attr-code  no-undo .
    define output parameter p-value    like ub.ord-line-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_ord-line-attr for ub.ord-line-attr .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    run ordlineattr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-line-attr no-lock
      where buf_ord-line-attr.doc-code  = p-doc-code
        and buf_ord-line-attr.gds-code  = p-gds-code
        and buf_ord-line-attr.attr-code = p-code
      no-error .
    if avail buf_ord-line-attr then do:
      assign
        p-value =  buf_ord-line-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure ordlineattr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.ord-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.ord-line-attr.attr-code  no-undo .
    define input parameter p-value    like ub.ord-line-attr.attr-value no-undo .
    define buffer buf_ord-line-attr for ub.ord-line-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    run ordlineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .
      undo, return error return-value .
    end.
    find first buf_ord-line-attr exclusive-lock
      where buf_ord-line-attr.doc-code  = p-doc-code
        and buf_ord-line-attr.gds-code  = p-gds-code
        and buf_ord-line-attr.attr-code = p-code
      no-error .
    if not available buf_ord-line-attr then do:
      create buf_ord-line-attr .
      assign
        buf_ord-line-attr.doc-code   = p-doc-code
        buf_ord-line-attr.gds-code   = p-gds-code
        buf_ord-line-attr.attr-code  = p-code
      .
    end.
    assign
      buf_ord-line-attr.attr-value = p-value
    .
end.
end procedure.
procedure ordlineattr-exist :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.ord-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.ord-line-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_ord-line-attr for ub.ord-line-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    run ordlineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-line-attr no-lock
      where buf_ord-line-attr.doc-code  = p-doc-code
        and buf_ord-line-attr.gds-code = p-gds-code
        and buf_ord-line-attr.attr-code = p-code
      no-error .
    if  available buf_ord-line-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure ordlineattr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.ord-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.ord-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_ord-line-attr for ub.ord-line-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    define variable v-other          as character no-undo .
    run ordlineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-line-attr exclusive-lock
      where buf_ord-line-attr.doc-code  = p-doc-code
        and buf_ord-line-attr.gds-code  = p-gds-code
        and buf_ord-line-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_ord-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_ord-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure ordlineattr-code :
  do on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-fillin_width   as integer   no-undo .
    define output parameter p-fillin_height  as integer   no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-proc           as character no-undo .
    define output parameter p-func           as character no-undo .
    define output parameter p-sort           as integer   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'cycle-cli-qnty':U then do:     assign     p-label          = "Количество"     p-type           = 'D':U      p-format         = ">>>>>>>>>>>>>>>9.999"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Количество"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'ord-EAN13':U then do:     assign     p-label          = "EAN в EDI"     p-type           = 'C':U      p-format         = "X(13)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "EAN в EDI"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут строки заказа" + " " + p-code .
      end.
    end.
  end.
end procedure.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
procedure ver-qnty-rcv-from-ord :
define input  parameter p-ord-doc as character no-undo .
define output parameter p-is-lim as logical    no-undo .
define buffer buf_ord-doc     for ub.ord-doc      .
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
define variable v-kol as integer   no-undo .
define variable v-ver as logical   no-undo .
  do
  on error undo, return error return-value
  :
   p-is-lim = false .
  find first buf_ord-doc no-lock where buf_ord-doc.doc-code = p-ord-doc no-error .
  if buf_ord-doc.doc-type <> 'ОП':U then return .
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input buf_ord-doc.obj-type
  ,input buf_ord-doc.obj-code
  ,input 'ord-obj':U
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
      if thbjattr_thbj-attr.prop-code = 'ord-11':U then v-ver = thbjattr_thbj-attr.property-value-logical .
  end.
v-kol = 0.
  if v-ver then do:
     for each buf_ord-doc-rcv no-lock where
              buf_ord-doc-rcv.doc-code = p-ord-doc :
       v-kol = v-kol + 1.
       leave.
     end.
   if v-kol > 0 then p-is-lim = true .
  end.
end.
end procedure.
procedure ver-qnty-trn-from-rcv :
define input  parameter p-rcv-code as character no-undo .
define output parameter p-is-lim as logical   no-undo .
define buffer buf_ord-doc for ub.ord-doc  .
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
define buffer buf_ord-chain for ub.ord-chain .
define buffer buf_trn-doc for ub.trn-doc  .
define variable v-kol as integer   no-undo .
define variable v-ver as logical   no-undo .
  do
  on error undo, return error return-value
  :
   p-is-lim = false .
  find first buf_ord-doc-rcv no-lock where buf_ord-doc-rcv.rcv-code = p-rcv-code no-error .
  find first buf_ord-doc no-lock where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code no-error .
  if buf_ord-doc.doc-type <> 'ОП':U then return .
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input buf_ord-doc.obj-type
  ,input buf_ord-doc.obj-code
  ,input 'ord-obj':U
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
      if thbjattr_thbj-attr.prop-code = 'ord-11':U then v-ver = thbjattr_thbj-attr.property-value-logical .
  end.
    if v-ver then do:
    v-kol = 0.
        for each buf_ord-chain no-lock where
                buf_ord-chain.doc-code = p-rcv-code and
                buf_ord-chain.doc-type = 'rcv' and
                buf_ord-chain.rel-doc-type = 'trn' ,
            first buf_trn-doc NO-LOCK where
                  buf_trn-doc.doc-code = buf_ord-chain.rel-doc-code
                  :
            v-kol = v-kol + 1.
            leave.
        end.
        if v-kol > 0 then p-is-lim = true .
    end.
  end.
end procedure.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION isoraret_on returns logical :
define buffer buf_ext-system for ub.ext-system.
define buffer buf_db for ub.db  .
find first buf_db no-lock where buf_db.db-num > 0 no-error .
if available buf_db then  do:
   return no.
end.
find first buf_ext-system no-lock no-error .
if available buf_ext-system
and buf_ext-system.esys-type = integer('3':U)
and buf_ext-system.delivery-method = integer('3':U) then return yes.
return no.
end function.
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new shared variable x-make-avto as integer  no-undo .
define new shared buffer   buf-oo_ord-doc for ub.ord-doc.
define new shared buffer   buf-or_ord-doc for ub.ord-doc.
define temp-table tempclip-orddoc no-undo like ub.ord-doc.
define variable varnext-prev      as logical   no-undo.
define variable p-file as character no-undo.
define variable bf-handle         as handle    no-undo.
define variable v-spis-status     as character no-undo .
define variable g-log             as logical   no-undo .
define variable v-doc-mode        as character no-undo .
define variable filter-point      as character no-undo init "zakz-rcv" .
define variable filter-point0     as character no-undo init "zakz-rcv" .
define variable filter-label      as character no-undo init "Список заказов" .
define variable sort-column-name  as character no-undo .
define variable g#db-remote       as logical   no-undo .
define variable v-fin-block       as logical   no-undo init true .
define variable par-is-finby      as character no-undo .
define variable is-finby          as logical   no-undo .
define variable par-is-edi        as character no-undo .
define variable par-is-edoc-nn    as character no-undo .
define variable p-status   as date      no-undo .
define variable v-edoc-status as integer   no-undo .
define variable v-edoc-ora as logical   no-undo .
define variable v-dm-edi  as integer no-undo .
define variable kk as integer no-undo .
 v-edoc-ora = isoraret_on () .
if Lookup("fin-block", p-buttons) <> 0 then v-fin-block = true.
                                       else v-fin-block = false .
if v-cntxt-db-num <> 0 then g#db-remote = true .
                       else g#db-remote = false .
define variable v-obj-active  as character no-undo .
if v-cntxt-obj-type <> "" then do:
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  'active=request':u
  ,output v-obj-active
  )  .
end.
else do:
  v-obj-active = 'no' .
end.
define variable v-not-activ  as logical   no-undo .
if v-obj-active <> "yes" and g#db-remote = true then v-not-activ = true .
else v-not-activ = false .
ASSIGN
  frame d-all-docs:scrollable       = false
  br-docs:num-locked-columns in frame d-all-docs = 4
  b-rep:popup-menu in frame d-all-docs   = menu m-rep:handle
  b-rep:menu-mouse   = 1
  b-print:popup-menu in frame d-all-docs = menu m-print:handle
  b-print:menu-mouse = 1
  b-print-rcv:popup-menu in frame d-all-docs = menu m-print-rcv:handle
  b-print-rcv:menu-mouse = 1
  br-docs:num-locked-columns in frame d-all-docs = 5
  b-payment:popup-menu in frame d-all-docs = menu m-payment:handle
  b-payment:menu-mouse = 1
  b-exec:popup-menu in frame d-all-docs = menu m-exec:handle
  b-exec:menu-mouse = 1
  shar-buf_ord-doc.cli-name:resizable in browse br-docs   = true .
  shar-buf_ord-doc.cons-code:resizable in browse br-docs   = true .
.
if  v-fin-block = true   then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-finby'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output par-is-finby
  ,output par-type
  ) no-error .
if error-status :error then par-is-finby = 'no' .
  assign
    is-finby = lookup(par-is-finby, "true,yes":U) > 0
  .
define variable v-right-supp  as logical no-undo .
define variable v-right-buyer as logical no-undo .
  v-right-supp = true .
  v-right-buyer = true .
define variable vss-include-info47 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-supp':U
    ,input  'firm':U
    ,input  g#host-code
    ,input  ''
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-right-supp
    )  .
end.
define variable vss-include-info48 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-buyer':U
    ,input  'firm':U
    ,input  g#host-code
    ,input  ''
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-right-buyer
    )  .
end.
  if v-right-supp = false or v-right-buyer = false  then return .
    ASSIGN
      MENU-ITEM m_lkp-fo    :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m_gen-1     :SENSITIVE IN MENU m-exec =  ( if v-cntxt-db-num = 0 then true else false )
      MENU-ITEM m_gen-1_buyer :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m_gen-2     :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m_gen-3     :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m_gen-4     :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m_gen-2-2   :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m_gen-3-2   :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m_gen-4-2   :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m-exp       :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m-cycle     :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m-del-cycle :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m-cl        :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m-del       :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m-imp       :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m-edoc-nn   :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m-edoc-ok   :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m-sost      :SENSITIVE IN MENU m-exec = true
      b-exec:label in frame d-all-docs  = "Генерация ФО"
      b-exec:width-chars in frame d-all-docs  = 13
      b-exec:tooltip in frame d-all-docs  = "Функции по генерации и просмотру ФО"
    .
    if is-finby = false or v-right-buyer = false then
    assign
      MENU-ITEM m_gen-1_buyer :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-2-2     :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-3-2     :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-4-2     :SENSITIVE IN MENU m-exec = false
    .
    if v-right-supp = false then
    assign
      MENU-ITEM m_gen-1 :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-2 :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-3 :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-4 :SENSITIVE IN MENU m-exec = false
     .
    if v-right-supp = false and v-right-buyer = false then
    assign
      MENU-ITEM m_gen-1_buyer :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-2-2     :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-3-2     :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-4-2     :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_lkp-fo      :SENSITIVE IN MENU m-exec = false
    .
end.
else do:
    ASSIGN
      MENU-ITEM m_lkp-fo    :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-1     :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-1_buyer :SENSITIVE IN MENU m-exec =  false
      MENU-ITEM m_gen-2     :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-3     :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-4     :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-2-2   :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-3-2   :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-4-2   :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m-exp       :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m-cycle     :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m-del-cycle :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m-cl        :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m-del       :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m-imp       :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m-edoc-nn   :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m-edoc-ok   :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m-sost      :SENSITIVE IN MENU m-exec = true
      b-exec:label in frame d-all-docs   = "Функции"
      b-exec:tooltip in frame d-all-docs  = "Функции по расчету заказов"
      .
end.
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
if error-status :error then is-edi = false .
assign
  is-edi = lookup(par-is-edi, "true,yes":U) > 0
.
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
if error-status :error then is-edoc-nn = false .
assign
  is-edoc-nn = lookup(par-is-edoc-nn, "true,yes":U) > 0
.
if ( is-edi = false and is-edoc-nn = false ) then do:
   assign
    menu-item m-edoc-nn     :sensitive in menu m-exec = false
    menu-item m-edoc-ok     :sensitive in menu m-exec = false
    menu-item m-edoc-rpl-ok :sensitive in menu m-exec = false
    menu-item m-edoc-trn    :sensitive in menu m-exec = false
    .
end.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION RedLine RETURNS CHARACTER ( INPUT i-str AS CHARACTER ) :
  DEFINE VARIABLE v-str AS CHARACTER NO-UNDO.
  RUN get-red-line IN THIS-PROCEDURE ( INPUT i-str, OUTPUT v-str ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN i-str ELSE v-str ).
END FUNCTION.
PROCEDURE get-red-line :
  DEFINE  INPUT PARAMETER p-str AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS CHARACTER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-res = CAPS( SUBSTRING( p-str, 1, 1 ) ) + LC( SUBSTRING( p-str, 2 ) ).
  END.
END PROCEDURE.
FUNCTION get-decade-word RETURNS CHARACTER ( INPUT i-dec AS INTEGER, INPUT i-num AS INTEGER ) :
  DEFINE VARIABLE v-grade AS CHARACTER NO-UNDO.
  RUN get-number-grade IN THIS-PROCEDURE ( INPUT i-dec, INPUT i-num, OUTPUT v-grade ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "":U ELSE v-grade ).
END FUNCTION.
FUNCTION Word-Sum RETURNS CHARACTER ( INPUT i-sum AS DECIMAL ) :
  DEFINE VARIABLE OutSum AS CHARACTER NO-UNDO.
  RUN conv-sum-to-word IN THIS-PROCEDURE ( INPUT i-sum, OUTPUT OutSum ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE OutSum ).
END FUNCTION.
PROCEDURE get-number-grade :
  DEFINE  INPUT PARAMETER p-dec AS INTEGER   NO-UNDO.
  DEFINE  INPUT PARAMETER p-num AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-list AS CHARACTER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    IF      p-dec = 1 THEN DO: ASSIGN v-list = ",один,два,три,четыре,пять,шесть,семь,восемь,девять".    END.
    ELSE IF p-dec = 2 THEN DO: ASSIGN v-list = "десять,одиннадцать,двенадцать,тринадцать,четырнадцать,пятнадцать,шестнадцать,семнадцать,восемнадцать,девятнадцать".    END.
    ELSE IF p-dec = 3 THEN DO: ASSIGN v-list = ",,двадцать,тридцать,сорок,пятьдесят,шестьдесят,семьдесят,восемьдесят,девяносто".   END.
    ELSE IF p-dec = 4 THEN DO: ASSIGN v-list = ",сто,двести,триста,четыреста,пятьсот,шестьсот,семьсот,восемьсот,девятьсот".  END.
                      ELSE DO: ASSIGN v-list = ",,,,,,,,,". END.
    ASSIGN p-res = ENTRY( p-num + 1, v-list ).
  END.
END PROCEDURE.
PROCEDURE conv-sum-to-word :
  DEFINE  INPUT PARAMETER p-sum AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Formatted  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Word       AS CHARACTER NO-UNDO.
  DEFINE VARIABLE OutSum     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE jj         AS INTEGER   NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN Formatted = STRING( ABS( p-sum ), "999999999999999.99":U ) NO-ERROR.
    IF ERROR-STATUS :ERROR THEN DO:
      ASSIGN p-res = ?.
      UNDO, RETURN ERROR.
    END.
    DO jj = ( LENGTH( Formatted ) - 3 ) TO 3 BY -3 :
      IF SUBSTRING( Formatted, jj - 2, 3 ) = "000" THEN DO: NEXT. END.
      IF jj < 15 THEN DO:
        ASSIGN Word = ENTRY( jj, ",,триллион,,,миллиард,,,миллион,,,тысяч" ).
        IF SUBSTRING( Formatted, jj,     1 )  = "1" AND
           SUBSTRING( Formatted, jj - 1, 1 ) <> "1" AND jj = 12 THEN DO: ASSIGN Word = TRIM( Word ) + "а". END.
        IF SUBSTRING( Formatted, jj, 1 ) = "2" OR
           SUBSTRING( Formatted, jj, 1 ) = "3" OR
           SUBSTRING( Formatted, jj, 1 ) = "4" THEN DO:
          IF jj = 12 THEN DO:
            IF SUBSTRING( Formatted, jj - 1, 1 ) <> "1" THEN DO: ASSIGN Word = TRIM( Word ) + "и". END.
          END.       ELSE DO:
            IF SUBSTRING( Formatted, jj - 1, 1 ) <> "1" THEN DO: ASSIGN Word = TRIM( Word ) + "а". END.
          END.
        END.
        IF ( SUBSTRING( Formatted, jj,     1 ) <> "1" AND
             SUBSTRING( Formatted, jj,     1 ) <> "2" AND
             SUBSTRING( Formatted, jj,     1 ) <> "3" AND
             SUBSTRING( Formatted, jj,     1 ) <> "4" AND jj <> 12 ) OR
           ( SUBSTRING( Formatted, jj - 1, 1 )  = "1" AND jj <  12 ) THEN DO: ASSIGN Word = TRIM( Word ) + "ов". END.
        IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
      END.
      IF SUBSTRING( Formatted, jj - 1, 1 ) <> "1" THEN DO:
        IF      jj = 12 AND SUBSTRING( Formatted, jj, 1 ) = "1" THEN DO: ASSIGN Word = "одна". END.
        ELSE IF jj = 12 AND SUBSTRING( Formatted, jj, 1 ) = "2" THEN DO: ASSIGN Word = "две".  END.
        ELSE DO: ASSIGN Word = get-decade-word( 1, INTEGER( SUBSTRING( Formatted, jj, 1 ) ) ). END.
        IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
        ASSIGN Word = get-decade-word( 3, INTEGER( SUBSTRING( Formatted, jj - 1, 1 ) ) ).
      END.                                        ELSE DO:
        ASSIGN Word = get-decade-word( 2, INTEGER( SUBSTRING( Formatted, jj,     1 ) ) ).
      END.
      IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
      ASSIGN Word = get-decade-word( 4, INTEGER( SUBSTRING( Formatted, jj - 2, 1 ) ) ).
      IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
    END.
    ASSIGN OutSum = CAPS( SUBSTRING( OutSum, 1, 1 ) ) + SUBSTRING( OutSum, 2 ).
    IF OutSum = "":U AND TRUNCATE( p-sum, 0 ) = 0 THEN DO: ASSIGN OutSum = "Ноль". END.
    ASSIGN p-res = TRIM( OutSum ).
  END.
END PROCEDURE.
FUNCTION Total-Word RETURNS CHARACTER ( INPUT i-sum AS DECIMAL, INPUT i-curr AS CHARACTER, INPUT i-part AS CHARACTER ) :
  DEFINE VARIABLE word_sum AS CHARACTER NO-UNDO.
  RUN get-total-word IN THIS-PROCEDURE ( INPUT i-sum, INPUT i-curr, INPUT i-part, OUTPUT word_sum ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE word_sum ).
END FUNCTION.
PROCEDURE get-total-word :
  DEFINE  INPUT PARAMETER p-sum  AS DECIMAL   NO-UNDO.
  DEFINE  INPUT PARAMETER p-curr AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-part AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-word AS CHARACTER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-word = Word-Sum( p-sum ).
               ASSIGN p-word = ( IF p-sum < 0 THEN "- " ELSE "":U ) + TRIM(
                      RedLine( p-word )
               ) +
                      " ":U + p-curr + " ":U +
                      SUBSTRING( STRING( ABS( p-sum ), "999999999999999999999999999999.99" ), 32, 2 ) +
                      " ":U + p-part + ".".
                        END.
END PROCEDURE.
ON CHOOSE OF MENU-ITEM m_PRINT1
DO:
  if not available shar-buf_ord-doc then return .
  run cus/torg-26.p ( parParentProc, recid(shar-buf_ord-doc) ).
END.
ON CHOOSE OF MENU-ITEM m_print4
DO:
      g#log = true  .
            message "Экспорт в excel ." skip "Продолжать ?"
                view-as alert-box question buttons ok-cancel update g#log.
            if not g#log then do:   find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec no-lock.   return no-apply. end.
            IF NOT AVAILABLE shar-buf_ord-doc THEN RETURN .
            RUN cus/z-tot1.p (PARPARENTPROC ,  shar-buf_ord-doc.doc-code , shar-buf_ord-doc.obj-TYPE ,shar-buf_ord-doc.obj-code   ).
    END.
     ON CHOOSE OF MENU-ITEM m_print5
        DO:
            if  g#type = 'ФП':U then do:
            IF NOT AVAILABLE shar-buf_ord-doc THEN RETURN .
            RUN cus/z-tot-det.p (PARPARENTPROC ,  shar-buf_ord-doc.doc-code , shar-buf_ord-doc.obj-TYPE ,shar-buf_ord-doc.obj-code   ).
 end.
 else do:
     message "Печать документа только для заказов Фирма - Поставщик" view-as alert-box.
     end.
        END.
ON CHOOSE OF MENU-ITEM m_PRINT2
DO:
define variable j as integer init 0 no-undo .
DEFINE  BUFFER post-firm    for ub.firm.
DEFINE  BUFFER zak-firm     for ub.firm.
DEFINE  BUFFER ord-blank-1  for ub.ord-blank.
DEFINE VARIABLE chExcelApplication      AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorkbook              AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorksheet             AS COM-HANDLE no-undo .
define variable PrintRubl  as logical   no-undo .
define variable Abbr       as character no-undo .
define variable PropisSum  as character no-undo .
define variable B-Sum      as decimal   no-undo .
DEFINE VARIABLE N#ROW         as  integer  no-undo .
DEFINE VARIABLE GoodN#ROW     as  integer  no-undo .
DEFINE VARIABLE GoodEI#ROW    as  integer  no-undo .
DEFINE VARIABLE OKEI#ROW      as  integer  no-undo .
DEFINE VARIABLE Qnty#ROW      as  integer  no-undo .
DEFINE VARIABLE Cost#ROW      as  integer  no-undo .
DEFINE VARIABLE Summa#ROW     as  integer  no-undo .
DEFINE VARIABLE N#col         as  integer  no-undo .
DEFINE VARIABLE GoodN#col     as  integer  no-undo .
DEFINE VARIABLE GoodEI#col    as  integer  no-undo .
DEFINE VARIABLE OKEI#col      as  integer  no-undo .
DEFINE VARIABLE Qnty#col      as  integer  no-undo .
DEFINE VARIABLE Cost#col      as  integer  no-undo .
DEFINE VARIABLE Summa#col     as  integer  no-undo .
DEFINE VARIABLE Sort#ROW      as  integer  no-undo .
DEFINE VARIABLE Sort#COL      as  integer  no-undo .
DEFINE VARIABLE GoodCode#ROW  as  integer  no-undo .
DEFINE VARIABLE GoodCode#COL  as  integer  no-undo .
DEFINE VARIABLE CliArt#ROW    as  integer  no-undo .
DEFINE VARIABLE CliArt#COL    as  integer  no-undo .
DEFINE VARIABLE Art#ROW       as  integer  no-undo .
DEFINE VARIABLE Art#COL       as  integer  no-undo .
  if not available shar-buf_ord-doc then return .
define variable Current-ROW  as integer no-undo .
 if blank#name = ?  or blank#name = "" Then
    Find first ub.ord-blank
         where ub.ord-blank.cli-code = shar-buf_ord-doc.cli-code
           and ub.ord-blank.cli-type = shar-buf_ord-doc.cli-type
           and ub.ord-blank.last-use = TRUE
         no-lock no-error.
   else
    Find first ub.ord-blank
         where ub.ord-blank.cli-code = shar-buf_ord-doc.cli-code
           and ub.ord-blank.cli-type = shar-buf_ord-doc.cli-type
           and ub.ord-blank.blank-name = blank#name
          no-lock no-error.
   if not  available  ub.ord-blank  then do :
      Message "Для этого поставщика нет формы !   Задайте ее в режиме  <<выбор формы печати>>".
      Return.
      End.
   if  available  ub.ord-blank  then do :
       Assign blank#name = ?.
       For each ord-blank-1 where ub.ord-blank-1.cli-code = shar-buf_ord-doc.cli-code
                              and ub.ord-blank-1.cli-type = shar-buf_ord-doc.cli-type   exclusive-lock :
       if  ord-blank.blank-name = ub.ord-blank-1.blank-name and
           ord-blank.cli-code = ub.ord-blank-1.cli-code     and
           ord-blank.cli-type = ub.ord-blank-1.cli-type then  ord-blank-1.last-use = TRUE .
           Else ord-blank-1.last-use = false  .
       End.
 B-Sum = shar-buf_ord-doc.sum-Service + shar-buf_ord-doc.sum-Ship + shar-buf_ord-doc.sum-cli.
 FIND ub.currency NO-LOCK WHERE ub.currency.curr-code = shar-buf_ord-doc.exch-code no-error .
 if shar-buf_ord-doc.exch-code <> 0 then
       assign
        PrintRubl = false
        abbr = ub.currency.curr-abbr
        .
 else  PrintRubl =  true .
      if NOT PrintRubl then
           assign
            PropisSum = Total-Word( B-Sum, ub.currency.curr-abbr, ub.currency.part-abbr )
          .
      else
          run rep/wp-rub.p ( B-Sum , output PropisSum, output abbr).
CREATE "Excel.Application" chExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        return no-apply .
    end.
ASSIGN
  chExcelApplication:Visible = FALSE
  chWorkbook  = chExcelApplication:Workbooks:Add ( ub.ord-blank.file-name )
  chWorkSheet = chExcelApplication:Sheets:Item (1)
  chExcelApplication:Interactive    = false
  chExcelApplication:ScreenUpdating = false
  .
      Find first post-firm where  post-firm.firm-code = shar-buf_ord-doc.cli-code no-lock  no-error .
      if available post-firm THEN
       Assign
        chWorkSheet:Range ("PosAddres1"):Value   = post-firm.addres1
        chWorkSheet:Range ("PosAddres2"):Value   = post-firm.addres2
        chWorkSheet:Range ("PosOKPO")   :Value   = post-firm.okpo
        chWorkSheet:Range ("PosPhone1") :Value   = post-firm.phone1-note
        chWorkSheet:Range ("PosPhone2") :Value   = post-firm.phone no-error.
       Find first Zak-firm where  Zak-firm.firm-code = g#host-code no-lock  no-error .
       if available Zak-firm THEN
       Assign
        chWorkSheet:Range ("ZakAddres1"):Value   = Zak-firm.addres1
        chWorkSheet:Range ("ZakAddres2"):Value   = Zak-firm.addres2
        chWorkSheet:Range ("ZakOKPO")   :Value   = Zak-firm.okpo
        chWorkSheet:Range ("ZakPhone1") :Value   = Zak-firm.phone1-note
        chWorkSheet:Range ("ZakPhone2") :Value   = Zak-firm.phone no-error.
       Assign chWorkSheet:Range ("ZakFullname"):Value = G#host-name no-error.
       Assign chWorkSheet:Range ("Number")     :Value = shar-buf_ord-doc.doc-code no-error .
       Assign chWorkSheet:Range ("NumberPost") :Value = entry(1, shar-buf_ord-doc.cli-out-doc, chr(4)) no-error.
       Assign chWorkSheet:Range ("TimePost")   :Value = string(shar-buf_ord-doc.ship-time, "HH:MM") no-error.
       Assign chWorkSheet:Range ("DatePost")   :Value = string(shar-buf_ord-doc.ship-date, "99/99/9999") no-error.
       Assign chWorkSheet:Range ("FullName")   :Value = shar-buf_ord-doc.cli-name     no-error.
       Assign
        chWorkSheet:Range ("DateDoc") :Value  = if shar-buf_ord-doc.fact-date <> ?
          THEN string(shar-buf_ord-doc.fact-date, "99/99/9999")
          Else string(shar-buf_ord-doc.doc-date, "99/99/9999")
        no-error.
       Assign chWorkSheet:Range ("SumShip")   :Value = shar-buf_ord-doc.sum-Ship no-error.
       Assign chWorkSheet:Range ("SumService"):Value = shar-buf_ord-doc.sum-Service no-error.
       Assign chWorkSheet:Range ("SumPropis") :Value = PropisSum  no-error .
     Assign
     N#ROW            =   chWorkSheet:Range ("N" ):Row
     N#COL            =   chWorkSheet:Range ("N" ):Column
     Sort#ROW         =   chWorkSheet:Range ("Sort" ):Row
     Sort#COL         =   chWorkSheet:Range ("Sort" ):Column
     GoodCode#ROW     =   chWorkSheet:Range ("GoodCode" ):Row
     GoodCode#COL     =   chWorkSheet:Range ("GoodCode" ):Column
     GoodN#ROW  = chWorkSheet:Range ("GoodN" ):Row
     GoodEI#ROW = chWorkSheet:Range ("EIn"   ):Row
     OKEI#ROW   = chWorkSheet:Range ("GoodEI"):Row
     Qnty#ROW   = chWorkSheet:Range ("Qnty"  ):Row
     Cost#ROW   = chWorkSheet:Range ("Cost"  ):Row
     Summa#ROW  = chWorkSheet:Range ("Summa" ):Row
     CliArt#ROW = chWorkSheet:Range ("CliArt" ):Row
     Art#ROW = chWorkSheet:Range ("Art" ):Row
     GoodN#COL  = chWorkSheet:Range ("GoodN" ):Column
     GoodEI#COL = chWorkSheet:Range ("EIn"   ):Column
     OKEI#COL   = chWorkSheet:Range ("GoodEI"):Column
     Qnty#COL   = chWorkSheet:Range ("Qnty"  ):Column
     Cost#COL   = chWorkSheet:Range ("Cost"  ):Column
     Summa#COL  = chWorkSheet:Range ("Summa" ):Column
     CliArt#COL = chWorkSheet:Range ("CliArt" ):Column
     Art#COL = chWorkSheet:Range ("Art" ):Column
     no-error.
         Current-ROW = maximum( if N#ROW       = ? then 0 else N#ROW      ,
                                if GoodN#ROW   = ? then 0 else GoodN#ROW  ,
                                if GoodEI#ROW  = ? then 0 else GoodEI#ROW ,
                                if OKEI#ROW    = ? then 0 else OKEI#ROW   ,
                                if Art#ROW     = ? then 0 else Art#ROW    ,
                                if CliArt#ROW  = ? then 0 else CliArt#ROW ,
                                if Qnty#ROW    = ? then 0 else Qnty#ROW   ,
                                if Cost#ROW    = ? then 0 else Cost#ROW   ,
                                if Summa#ROW   = ? then 0 else Summa#ROW  )
                                .
      For each  t-doc-line where t-doc-line.doc-code = shar-buf_ord-doc.doc-code no-lock :
       chWorkSheet:Rows(Current-ROW):Insert .
      End.
      For each  t-doc-line where t-doc-line.doc-code = shar-buf_ord-doc.doc-code no-lock :
         J = J + 1 .
                  FIND FIRST ub.goods No-LOCK
              WHERE ub.goods.prod-type = t-doc-line.prod-type
               AND  ub.goods.prod-code = t-doc-line.prod-code
               AND  ub.goods.artic     = t-doc-line.artic
                    NO-ERROR.
         FIND FIRST ub.units WHERE ub.units.unit-name = t-doc-line.unit-cli NO-LOCK NO-ERROR .
         Assign chWorkSheet:Range (string(COL-NAME[N#col])        + String(N#ROW        + J)):Value  = J no-error.
         Assign chWorkSheet:Range (string(COL-NAME[GoodN#col])    + String(GoodN#ROW    + J)):Value  = ub.goods.gds-name no-error.
         Assign chWorkSheet:Range (string(COL-NAME[Sort#col])     + String(Sort#ROW     + J)):Value  = ub.goods.Sort     no-error.
         Assign chWorkSheet:Range (string(COL-NAME[GoodCode#col]) + String(GoodCode#ROW + J)):Value  = ub.goods.gds-code no-error.
         Assign chWorkSheet:Range (string(COL-NAME[GoodEI#col])   + String(GoodEI#ROW   + J)):Value  = t-doc-line.unit-cli  no-error.
         Assign chWorkSheet:Range (string(COL-NAME[OKEI#col])     + String(OKEI#ROW     + J)):Value  = if available ub.units THEN String(ub.units.OKEI,">>>>>") Else "" no-error.
         Assign chWorkSheet:Range (string(COL-NAME[CliArt#col])   + String(CliArt#ROW   + J)):Value  = t-doc-line.cli-art no-error.
         Assign chWorkSheet:Range (string(COL-NAME[Art#col])      + String(Art#ROW      + J)):Value  = t-doc-line.artic no-error.
         Assign chWorkSheet:Range (string(COL-NAME[Qnty#col])     + String(Qnty#ROW     + J)):Value  = t-doc-line.cli-qnty no-error .
         Assign chWorkSheet:Range (string(COL-NAME[Cost#col])     + String(Cost#ROW     + J)):Value  = t-doc-line.price-cli no-error .
         Assign chWorkSheet:Range (string(COL-NAME[Summa#col])    + String(Summa#ROW    + J)):Value  = round ( t-doc-line.cli-qnty * t-doc-line.price-cli , 2) no-error .
       END.
      chWorkSheet:Rows(Current-ROW):Delete.
      assign
      chExcelApplication:Interactive    = true
      chExcelApplication:ScreenUpdating = true
      chExcelApplication:Visible        = TRUE
      .
   End.
  message "Форма Заказа подготовлена. Связь с Excel будет закрыта."  view-as alert-box .
  RELEASE OBJECT chWorksheet NO-ERROR.
  RELEASE OBJECT chWorkbook NO-ERROR.
  chExcelApplication :QUIT().
  RELEASE OBJECT  chExcelApplication  NO-ERROR.
  RETURN NO-APPLY.
END.
  ON CHOOSE OF MENU-ITEM m_print6 IN MENU M-print
    DO:
      define variable j as integer init 0 no-undo .
      DEFINE  BUFFER post-firm    for ub.firm.
      DEFINE  BUFFER zak-firm     for ub.firm.
      DEFINE  BUFFER ord-blank-1  for ub.ord-blank.
      DEFINE VARIABLE chExcelApplication      AS COM-HANDLE no-undo .
      DEFINE VARIABLE chWorkbook              AS COM-HANDLE no-undo .
      DEFINE VARIABLE chWorksheet             AS COM-HANDLE no-undo .
      define variable PrintRubl  as logical   no-undo .
      define variable Abbr       as character no-undo .
      define variable PropisSum  as character no-undo .
      define variable B-Sum      as decimal   no-undo .
      DEFINE VARIABLE N#ROW         as  integer  no-undo .
      DEFINE VARIABLE GoodN#ROW     as  integer  no-undo .
      DEFINE VARIABLE GoodEI#ROW    as  integer  no-undo .
      DEFINE VARIABLE OKEI#ROW      as  integer  no-undo .
      DEFINE VARIABLE Qnty#ROW      as  integer  no-undo .
      DEFINE VARIABLE Cost#ROW      as  integer  no-undo .
      DEFINE VARIABLE Summa#ROW     as  integer  no-undo .
      DEFINE VARIABLE N#col         as  integer  no-undo .
      DEFINE VARIABLE GoodN#col     as  integer  no-undo .
      DEFINE VARIABLE GoodEI#col    as  integer  no-undo .
      DEFINE VARIABLE OKEI#col      as  integer  no-undo .
      DEFINE VARIABLE Qnty#col      as  integer  no-undo .
      DEFINE VARIABLE Cost#col      as  integer  no-undo .
      DEFINE VARIABLE Summa#col     as  integer  no-undo .
      DEFINE VARIABLE Sort#ROW      as  integer  no-undo .
      DEFINE VARIABLE Sort#COL      as  integer  no-undo .
      DEFINE VARIABLE GoodCode#ROW  as  integer  no-undo .
      DEFINE VARIABLE GoodCode#COL  as  integer  no-undo .
      DEFINE VARIABLE CliArt#ROW    as  integer  no-undo .
      DEFINE VARIABLE CliArt#COL    as  integer  no-undo .
      DEFINE VARIABLE Art#ROW       as  integer  no-undo .
      DEFINE VARIABLE Art#COL       as  integer  no-undo .
      DEFINE VARIABLE CliName#COL         as  integer  no-undo .
      DEFINE VARIABLE CliCode#COL         as  integer  no-undo .
      DEFINE VARIABLE CliType#COL         as  integer  no-undo .
      DEFINE VARIABLE CliAdress1#COL      as  integer  no-undo .
      DEFINE VARIABLE CliAdress2#COL      as  integer  no-undo .
      DEFINE VARIABLE CliName#ROW         as  integer  no-undo .
      DEFINE VARIABLE CliCode#ROW         as  integer  no-undo .
      DEFINE VARIABLE CliType#ROW         as  integer  no-undo .
      DEFINE VARIABLE CliAdress1#ROW      as  integer  no-undo .
      DEFINE VARIABLE CliAdress2#ROW      as  integer  no-undo .
      if not available shar-buf_ord-doc then return .
      define buffer buf_ord-line-rcv for ub.ord-line-rcv  .
      define buffer buf_ord-line     for ub.ord-line      .
      define variable Current-ROW  as integer no-undo .
      define variable v-rez as logical   no-undo .
      define variable v-cli-art as character no-undo .
      define buffer buf_clients for ub.clients  .
      if blank#name = ?  or blank#name = "" Then
        Find first ub.ord-blank
          where ub.ord-blank.cli-code = shar-buf_ord-doc.cli-code
          and ub.ord-blank.cli-type = shar-buf_ord-doc.cli-type
          and ub.ord-blank.last-use = TRUE
          no-lock no-error.
      else
        Find first ub.ord-blank
          where ub.ord-blank.cli-code = shar-buf_ord-doc.cli-code
          and ub.ord-blank.cli-type = shar-buf_ord-doc.cli-type
          and ub.ord-blank.blank-name = blank#name
          no-lock no-error.
      if not  available  ub.ord-blank  then
      do :
        Message "Для этого поставщика нет формы !   Задайте ее в режиме  <<выбор формы печати>>".
        Return.
      End.
      if  available  ub.ord-blank  then
      do :
        Assign
          blank#name = ?.
        For each ord-blank-1 where ub.ord-blank-1.cli-code = shar-buf_ord-doc.cli-code
          and ub.ord-blank-1.cli-type = shar-buf_ord-doc.cli-type   exclusive-lock :
          if  ord-blank.blank-name = ub.ord-blank-1.blank-name and
            ord-blank.cli-code = ub.ord-blank-1.cli-code     and
            ord-blank.cli-type = ub.ord-blank-1.cli-type then  ord-blank-1.last-use = TRUE .
          Else ord-blank-1.last-use = false  .
        End.
        CREATE "Excel.Application" chExcelApplication.
        assign
          chExcelApplication:Visible = false
          chWorkbook  = chExcelApplication:Workbooks:Add ( ub.ord-blank.file-name )
          chWorkSheet = chExcelApplication:Sheets:Item (1)
          chExcelApplication:Interactive    = false
          chExcelApplication:ScreenUpdating = false
          .
        Find first post-firm where  post-firm.firm-code = shar-buf_ord-doc.cli-code no-lock  no-error .
        if available post-firm THEN
          Assign
            chWorkSheet:Range ("PosAddres1"):Value   = post-firm.addres1
            chWorkSheet:Range ("PosAddres2"):Value   = post-firm.addres2
            chWorkSheet:Range ("PosOKPO")   :Value   = post-firm.okpo
            chWorkSheet:Range ("PosPhone1") :Value   = post-firm.phone1-note
            chWorkSheet:Range ("PosPhone2") :Value   = post-firm.phone no-error.
        Find first Zak-firm where  Zak-firm.firm-code = g#host-code no-lock  no-error .
        if available Zak-firm THEN
          Assign
            chWorkSheet:Range ("ZakAddres1"):Value   = Zak-firm.addres1
            chWorkSheet:Range ("ZakAddres2"):Value   = Zak-firm.addres2
            chWorkSheet:Range ("ZakOKPO")   :Value   = Zak-firm.okpo
            chWorkSheet:Range ("ZakPhone1") :Value   = Zak-firm.phone1-note
            chWorkSheet:Range ("ZakPhone2") :Value   = Zak-firm.phone no-error.
        Assign
          chWorkSheet:Range ("ZakFullname"):Value = G#host-name no-error.
        Assign
          chWorkSheet:Range ("Number")     :Value = shar-buf_ord-doc.doc-code no-error .
        Assign
          chWorkSheet:Range ("NumberPost") :Value = entry(1, shar-buf_ord-doc.cli-out-doc, chr(4)) no-error.
        Assign
          chWorkSheet:Range ("TimePost")   :Value = string(shar-buf_ord-doc.ship-time, "HH:MM") no-error.
        Assign
          chWorkSheet:Range ("DatePost")   :Value = string(shar-buf_ord-doc.ship-date, "99/99/9999") no-error.
        Assign
          chWorkSheet:Range ("FullName")   :Value = shar-buf_ord-doc.cli-name     no-error.
        Assign
          chWorkSheet:Range ("DateDoc") :Value  = if shar-buf_ord-doc.fact-date <> ?
          THEN string(shar-buf_ord-doc.fact-date, "99/99/9999")
          Else string(shar-buf_ord-doc.doc-date, "99/99/9999")
        no-error.
        Assign
          chWorkSheet:Range ("SumShip")   :Value = shar-buf_ord-doc.sum-Ship no-error.
        Assign
          chWorkSheet:Range ("SumService"):Value = shar-buf_ord-doc.sum-Service no-error.
        Assign
          N#ROW        = chWorkSheet:Range ("N" ):Row
          N#COL        = chWorkSheet:Range ("N" ):Column
          Sort#ROW     = chWorkSheet:Range ("Sort" ):Row
          Sort#COL     = chWorkSheet:Range ("Sort" ):Column
          GoodCode#ROW = chWorkSheet:Range ("GoodCode" ):Row
          GoodCode#COL = chWorkSheet:Range ("GoodCode" ):Column
          GoodN#ROW    = chWorkSheet:Range ("GoodN" ):Row
          GoodEI#ROW   = chWorkSheet:Range ("EIn"   ):Row
          OKEI#ROW     = chWorkSheet:Range ("GoodEI"):Row
     Qnty#ROW     = chWorkSheet:Range ("Qnty"  ):Row
     Cost#ROW     = chWorkSheet:Range ("Cost"  ):Row
     Summa#ROW    = chWorkSheet:Range ("Summa" ):Row
     CliArt#ROW   = chWorkSheet:Range ("CliArt"):Row
     Art#ROW      = chWorkSheet:Range ("Art"   ):Row
     CliName#ROW  = chWorkSheet:Range ("CliName"   ):ROW
     CliCode#ROW  = chWorkSheet:Range ("CliCode"   ):ROW
     CliType#ROW  = chWorkSheet:Range ("CliType"   ):ROW
     CliAdress1#ROW = chWorkSheet:Range ("CliAdress1"   ):ROW
     CliAdress2#ROW = chWorkSheet:Range ("CliAdress2"   ):ROW
     GoodN#COL    = chWorkSheet:Range ("GoodN" ):Column
     GoodEI#COL   = chWorkSheet:Range ("EIn"   ):Column
     OKEI#COL     = chWorkSheet:Range ("GoodEI"):Column
     Qnty#COL     = chWorkSheet:Range ("Qnty"  ):Column
     Cost#COL     = chWorkSheet:Range ("Cost"  ):Column
     Summa#COL    = chWorkSheet:Range ("Summa" ):Column
     CliArt#COL   = chWorkSheet:Range ("CliArt"):Column
     Art#COL      = chWorkSheet:Range ("Art"   ):Column
     CliName#COL  = chWorkSheet:Range ("CliName"   ):Column
     CliCode#COL  = chWorkSheet:Range ("CliCode"   ):Column
     CliType#COL  = chWorkSheet:Range ("CliType"   ):Column
     CliAdress1#COL = chWorkSheet:Range ("CliAdress1"   ):Column
     CliAdress2#COL = chWorkSheet:Range ("CliAdress2"   ):Column
     no-error.
      Current-ROW = maximum( if N#ROW       = ? then 0 else N#ROW      ,
        if GoodN#ROW   = ? then 0 else GoodN#ROW  ,
        if GoodEI#ROW  = ? then 0 else GoodEI#ROW ,
        if OKEI#ROW    = ? then 0 else OKEI#ROW   ,
        if Art#ROW  = ? then 0 else Art#ROW ,
        if CliArt#ROW  = ? then 0 else CliArt#ROW ,
        if Qnty#ROW    = ? then 0 else Qnty#ROW   ,
        if Cost#ROW    = ? then 0 else Cost#ROW   ,
        if Summa#ROW   = ? then 0 else Summa#ROW  ,
        if CliName#ROW = ? then 0 else CliName#ROW,
        if CliCode#ROW = ? then 0 else CliCode#ROW,
        if CliAdress1#ROW = ? then 0 else CliAdress1#ROW,
        if CliType#ROW = ? then 0 else CliType#ROW,
        if CliAdress2#ROW = ? then 0 else CliAdress2#ROW)
        .
      for each tt-ord-doc-rcv :
        delete tt-ord-doc-rcv .
      end.
      for each ub.ord-doc-rcv where ub.ord-doc-rcv.doc-code = shar-buf_ord-doc.doc-code:
        For each  buf_ord-line-rcv where
          buf_ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code and
          buf_ord-line-rcv.doc-code = ub.ord-doc-rcv.doc-code
          no-lock :
          chWorkSheet:Rows(Current-ROW):Insert .
        End.
        For each  buf_ord-line-rcv where
          buf_ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code and
          buf_ord-line-rcv.doc-code = ub.ord-doc-rcv.doc-code
          no-lock :
          J = J + 1 .
          FIND FIRST ub.goods No-LOCK WHERE ub.goods.prod-type = buf_ord-line-rcv.prod-type AND
            ub.goods.prod-code = buf_ord-line-rcv.prod-code AND
            ub.goods.artic     = buf_ord-line-rcv.artic  NO-ERROR.
          find first ub.units where ub.units.unit-name = buf_ord-line-rcv.unit-cli no-lock no-error .
                   find first buf_ord-line no-lock where
                              buf_ord-line.artic = buf_ord-line-rcv.artic and
                              buf_ord-line.prod-type = buf_ord-line-rcv.prod-type and
                              buf_ord-line.prod-code = buf_ord-line-rcv.prod-code no-error.
          if available buf_ord-line then v-cli-art = buf_ord-line.cli-art .
          else v-cli-art = "" .
          create tt-ord-doc-rcv .
          assign
          tt-ord-doc-rcv.nn = J
          tt-ord-doc-rcv.gds-name = ub.goods.gds-name
          tt-ord-doc-rcv.gds-sort = ub.goods.Sort
          tt-ord-doc-rcv.gds-code = ub.goods.gds-code
          tt-ord-doc-rcv.unit-cli = buf_ord-line-rcv.unit-cli
          .
          assign
          tt-ord-doc-rcv.OKEI = if available ub.units THEN String(ub.units.OKEI,">>>>>") Else "" no-error.
          assign
          tt-ord-doc-rcv.cli-art = v-cli-art
          tt-ord-doc-rcv.artic = buf_ord-line-rcv.artic
          tt-ord-doc-rcv.cli-qnty = buf_ord-line-rcv.cli-qnty
          tt-ord-doc-rcv.price-cli = buf_ord-line-rcv.price-cli
          tt-ord-doc-rcv.cost = buf_ord-line-rcv.price-cli
          tt-ord-doc-rcv.summa = round ( buf_ord-line-rcv.cli-qnty * buf_ord-line-rcv.price-cli , 2) no-error.
          assign
          tt-ord-doc-rcv.cli-name = ub.ord-doc-rcv.obj-type + " " + string(ub.ord-doc-rcv.obj-code)
          tt-ord-doc-rcv.cli-code = shar-buf_ord-doc.cli-code
          tt-ord-doc-rcv.cli-type = shar-buf_ord-doc.cli-type.
          if ub.ord-doc-rcv.obj-type = 'маг':U then do:
            find first ub.shop where ub.shop.obj-code = ub.ord-doc-rcv.obj-code no-lock no-error.
            assign
              tt-ord-doc-rcv.addres1 = ub.shop.addres1
              tt-ord-doc-rcv.addres2 = ub.shop.addres2
            .
          end.
          if ub.ord-doc-rcv.obj-type = 'скл':U then do:
            find first ub.store where ub.store.obj-code = ub.ord-doc-rcv.obj-code no-lock no-error.
            assign
              tt-ord-doc-rcv.addres1 = ub.store.addres1
              tt-ord-doc-rcv.addres2 = ub.store.addres2
            .
          end.
          .
        End.
      end.
for each tt-ord-doc-rcv exclusive-lock:
chWorkSheet:Rows(Current-ROW):Insert .
end.
for each tt-ord-doc-rcv exclusive-lock:
  B-sum = B-sum + tt-ord-doc-rcv.summa .
          Assign
            chWorkSheet:Range (string(COL-NAME[N#col])        + String(N#ROW        + J)):Value  = tt-ord-doc-rcv.nn no-error.
          Assign
            chWorkSheet:Range (string(COL-NAME[GoodN#col])    + String(GoodN#ROW    + J)):Value  = tt-ord-doc-rcv.gds-name no-error.
          Assign
            chWorkSheet:Range (string(COL-NAME[Sort#col])     + String(Sort#ROW     + J)):Value  = tt-ord-doc-rcv.gds-sort     no-error.
          Assign
            chWorkSheet:Range (string(COL-NAME[GoodCode#col]) + String(GoodCode#ROW + J)):Value  = tt-ord-doc-rcv.gds-code no-error.
          Assign
            chWorkSheet:Range (string(COL-NAME[GoodEI#col])   + String(GoodEI#ROW   + J)):Value  = tt-ord-doc-rcv.unit-cli  no-error.
          Assign
            chWorkSheet:Range (string(COL-NAME[OKEI#col])     + String(OKEI#ROW     + J)):Value  = tt-ord-doc-rcv.OKEI no-error.
          Assign
            chWorkSheet:Range (string(COL-NAME[CliArt#col])   + String(CliArt#ROW   + J)):Value  = tt-ord-doc-rcv.cli-art no-error.
          Assign
            chWorkSheet:Range (string(COL-NAME[Art#col])      + String(Art#ROW      + J)):Value  = tt-ord-doc-rcv.artic no-error.
          Assign
            chWorkSheet:Range (string(COL-NAME[Qnty#col])     + String(Qnty#ROW     + J)):Value  = tt-ord-doc-rcv.cli-qnty no-error .
          Assign
            chWorkSheet:Range (string(COL-NAME[Cost#col])     + String(Cost#ROW     + J)):Value  = tt-ord-doc-rcv.price-cli no-error .
          Assign
            chWorkSheet:Range (string(COL-NAME[Summa#col])    + String(Summa#ROW    + J)):Value  = tt-ord-doc-rcv.summa no-error .
          Assign
            chWorkSheet:Range (string(COL-NAME[Cost#col])     + String(Cost#ROW     + J)):Value  = tt-ord-doc-rcv.price-cli no-error .
          Assign
            chWorkSheet:Range (string(COL-NAME[CliName#COL])  + String(CliName#ROW  + J)):Value  = tt-ord-doc-rcv.cli-name no-error.
          Assign
            chWorkSheet:Range (string(COL-NAME[CliCode#COL])  + String(CliCode#ROW  + J)):Value  = tt-ord-doc-rcv.cli-code no-error.
          Assign
            chWorkSheet:Range (string(COL-NAME[CliType#COL])  + String(CliType#ROW     + J)):Value  = tt-ord-doc-rcv.cli-type no-error .
          Assign
            chWorkSheet:Range (string(COL-NAME[CliAdress1#COL]) + String(CliAdress1#ROW     + J)):Value  = tt-ord-doc-rcv.addres1 no-error .
          Assign
            chWorkSheet:Range (string(COL-NAME[CliAdress2#COL]) + String(CliAdress2#ROW    + J)):Value  = tt-ord-doc-rcv.addres2 no-error .
          chWorkSheet:Rows(Current-ROW):Delete.
end.
          assign
            chExcelApplication:Interactive    = true
            chExcelApplication:ScreenUpdating = true
            chExcelApplication:Visible        = TRUE .
        FIND ub.currency NO-LOCK WHERE ub.currency.curr-code = shar-buf_ord-doc.exch-code no-error .
        if shar-buf_ord-doc.exch-code <> 0 then
          assign
            PrintRubl = false
            abbr = ub.currency.curr-abbr
            .
        else  PrintRubl =  true .
        if NOT PrintRubl then
          assign
            PropisSum = Total-Word( B-Sum, ub.currency.curr-abbr, ub.currency.part-abbr )
            .
        else
          run rep/wp-rub.p ( B-Sum , output PropisSum, output abbr).
         Assign
          chWorkSheet:Range ("SumPropis") :Value = PropisSum  no-error .
    End.
  RELEASE OBJECT chWorksheet NO-ERROR.
  RELEASE OBJECT chWorkbook NO-ERROR.
  chExcelApplication :QUIT().
  RELEASE OBJECT  chExcelApplication  NO-ERROR.
  RETURN NO-APPLY.
END.
ON CHOOSE OF MENU-ITEM m_PRINT3
DO:
  if not available shar-buf_ord-doc then return .
  run cus/l-blank.w ( INPUT shar-buf_ord-doc.cli-TYPE , INPUT shar-buf_ord-doc.cli-CODE, output blank#name ).
  RETURN NO-APPLY.
END.
procedure ver-edi :
define parameter buffer buf_ord-doc for ub.ord-doc.
define output parameter v-res as logical   no-undo .
v-res = (buf_ord-doc.whole-send-news <> integer('2':U)).
if not v-res then do:
  message "Печатать запрещено!"
  view-as alert-box warning .
end.
end procedure.
ON CHOOSE OF MENU-ITEM m_print1-rcv
DO:
  define variable v-rez as logical   no-undo .
  if not available ub.ord-doc-rcv then return .
  run cus/torg-261.p ( parParentProc, recid(ub.ord-doc-rcv) ).
END.
ON CHOOSE OF MENU-ITEM m_print2-rcv
DO:
define buffer post-firm   for ub.firm.
define buffer zakz-shop   for ub.shop.
define buffer zakz-store  for ub.store.
define buffer ord-blank-1 for ub.ord-blank.
define variable j as integer init 0 no-undo .
define variable chexcelapplication      as com-handle no-undo .
define variable chworkbook              as com-handle no-undo .
define variable chworksheet             as com-handle no-undo .
define variable printrubl     as logical no-undo .
define variable abbr          as character no-undo .
define variable propissum     as character no-undo .
define variable b-sum         as decimal no-undo .
define variable N#ROW         as integer  no-undo .
define variable GoodN#ROW     as integer  no-undo .
define variable GoodEI#ROW    as integer  no-undo .
define variable OKEI#ROW      as integer  no-undo .
define variable Qnty#ROW      as integer  no-undo .
define variable Cost#ROW      as integer  no-undo .
define variable Summa#ROW     as integer  no-undo .
define variable N#col         as integer  no-undo .
define variable GoodN#col     as integer  no-undo .
define variable GoodEI#col    as integer  no-undo .
define variable OKEI#col      as integer  no-undo .
define variable Qnty#col      as integer  no-undo .
define variable Cost#col      as integer  no-undo .
define variable Summa#col     as integer  no-undo .
define variable Sort#ROW      as integer  no-undo .
define variable Sort#COL      as integer  no-undo .
define variable GoodCode#ROW  as integer  no-undo .
define variable GoodCode#COL  as integer  no-undo .
define variable CliArt#ROW    as integer  no-undo .
define variable CliArt#COL    as integer  no-undo .
define variable Art#ROW       as integer  no-undo .
define variable Art#COL       as integer  no-undo .
define buffer buf_ord-line-rcv for ub.ord-line-rcv  .
define buffer buf_ord-line     for ub.ord-line      .
define variable v-rez as logical   no-undo .
define variable v-cli-art as character no-undo .
if not available ub.ord-doc-rcv then return .
define variable Current-ROW  as integer no-undo .
define buffer buf_clients for ub.clients  .
find first buf_clients no-lock where
           buf_clients.obj-code = ub.ord-doc-rcv.cli-code and
           buf_clients.obj-type = ub.ord-doc-rcv.cli-type
           no-error .
 if blank#name-rcv = ?  or blank#name-rcv = "" Then
    Find first ub.ord-blank
         where ub.ord-blank.cli-code = ub.ord-doc-rcv.cli-code
           and ub.ord-blank.cli-type = ub.ord-doc-rcv.cli-type
           and ub.ord-blank.last-use-rcv = TRUE
          no-lock no-error.
   else
    Find first ub.ord-blank
         where ub.ord-blank.cli-code = ub.ord-doc-rcv.cli-code
           and ub.ord-blank.cli-type = ub.ord-doc-rcv.cli-type
           and ub.ord-blank.blank-name = blank#name-rcv
          no-lock no-error.
   if not  available  ub.ord-blank  then do :
      message "Для этого поставщика нет формы !   Задайте ее в режиме  <<выбор формы печати>>".
      return.
   end.
   if  available  ub.ord-blank  then do :
       Assign blank#name-rcv = ?.
       For each ord-blank-1
          where ord-blank-1.cli-code = ub.ord-doc-rcv.cli-code
            and ord-blank-1.cli-type = ub.ord-doc-rcv.cli-type
            exclusive-lock :
       if  ub.ord-blank.blank-name = ord-blank-1.blank-name and
           ub.ord-blank.cli-code = ord-blank-1.cli-code     and
           ub.ord-blank.cli-type = ord-blank-1.cli-type then
           ord-blank-1.last-use-rcv = TRUE .
           Else ord-blank-1.last-use-rcv = false  .
       End.
define variable v-sum as decimal   no-undo .
v-sum = 0 .
  For each  buf_ord-line-rcv where
            buf_ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code  and
            buf_ord-line-rcv.doc-code = ub.ord-doc-rcv.doc-code
            no-lock :
            v-sum = v-sum + (buf_ord-line-rcv.cli-qnty * buf_ord-line-rcv.price-cli).
  end.
 B-Sum = ub.ord-doc-rcv.sum-Service + ub.ord-doc-rcv.sum-Ship + v-sum.
 FIND ub.currency NO-LOCK WHERE ub.currency.curr-code = ub.ord-doc-rcv.exch-code no-error .
 if ub.ord-doc-rcv.exch-code <> 0 then
       assign
        PrintRubl = false
        abbr = ub.currency.curr-abbr
        .
 else  PrintRubl =  true .
      if NOT PrintRubl then
           assign
            PropisSum = Total-Word( B-Sum, ub.currency.curr-abbr, ub.currency.part-abbr )
          .
      else
          run rep/wp-rub.p ( B-Sum , output PropisSum, output abbr).
CREATE "Excel.Application" chExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        return no-apply .
    end.
ASSIGN
  chExcelApplication:Visible = FALSE
  chWorkbook  = chExcelApplication:Workbooks:Add ( ub.ord-blank.file-name )
  chWorkSheet = chExcelApplication:Sheets:Item (1)
  chExcelApplication:Interactive    = false
  chExcelApplication:ScreenUpdating = false
  .
      Find first post-firm where  post-firm.firm-code = ub.ord-doc-rcv.cli-code no-lock  no-error .
      if available post-firm THEN
       Assign
        chworksheet:range ("Fullname")  :Value   = buf_clients.obj-name
        chWorkSheet:Range ("PosAddres1"):Value   = post-firm.addres1
        chWorkSheet:Range ("PosAddres2"):Value   = post-firm.addres2
        chWorkSheet:Range ("PosOKPO")   :Value   = post-firm.okpo
        chWorkSheet:Range ("PosPhone1") :Value   = post-firm.phone1-note
        chWorkSheet:Range ("PosPhone2") :Value   = post-firm.phone no-error.
       find first buf_clients no-lock where
                  buf_clients.obj-code = ub.ord-doc-rcv.obj-code and
                  buf_clients.obj-type = ub.ord-doc-rcv.obj-type no-error .
       if ub.ord-doc-rcv.obj-type = 'маг':U then do:
          find first zakz-shop where  zakz-shop.obj-code = ub.ord-doc-rcv.obj-code no-lock  no-error .
          if available zakz-shop then
          assign
            chworksheet:range ("ZakFullname"):Value  = buf_clients.obj-name
            chWorkSheet:Range ("ZakAddres1"):Value   = zakz-shop.addres1
            chWorkSheet:Range ("ZakAddres2"):Value   = zakz-shop.addres2
            chWorkSheet:Range ("ZakPhone2") :Value   = zakz-shop.phone
            no-error.
       end.
       else do:
          find first zakz-store where  zakz-store.obj-code = ub.ord-doc-rcv.obj-code no-lock  no-error .
          if available zakz-store then
          assign
            chworksheet:range ("ZakFullname"):Value  = buf_clients.obj-name
            chWorkSheet:Range ("ZakAddres1"):Value   = zakz-store.addres1
            chWorkSheet:Range ("ZakAddres2"):Value   = zakz-store.addres2
            chWorkSheet:Range ("ZakPhone2") :Value   = zakz-store.phone
            no-error.
       end.
       Assign chworksheet:range ("Number")     :value = ub.ord-doc-rcv.rcv-code no-error.
       Assign chworksheet:range ("NumberZakaz"):value = ub.ord-doc-rcv.doc-code no-error.
       Assign chworksheet:range ("NumberPost") :value = entry( 1, ub.ord-doc-rcv.sub-par, chr(4) ) no-error.
       Assign chworksheet:range ("TimePost")   :value = string(ub.ord-doc-rcv.ship-time,"hh:mm") no-error.
       Assign chworksheet:range ("DatePost")   :value = string(ub.ord-doc-rcv.ship-date, "99/99/9999") no-error.
       Assign chworksheet:range ("SumShip")    :value = ub.ord-doc-rcv.sum-ship no-error.
       Assign chworksheet:range ("SumService") :value = ub.ord-doc-rcv.sum-service  no-error.
       Assign chworksheet:range ("SumPropis")  :value = propissum      no-error .
       Assign
        chworksheet:range ("DateDoc") :value  = if ub.ord-doc-rcv.fact-date <> ?
        then string(ub.ord-doc-rcv.fact-date, "99/99/9999" )
        else string(ub.ord-doc-rcv.doc-date,  "99/99/9999" )
        no-error .
     Assign
    N#ROW        = chWorkSheet:Range ("N" ):Row
     N#COL        = chWorkSheet:Range ("N" ):Column
     Sort#ROW     = chWorkSheet:Range ("Sort" ):Row
     Sort#COL     = chWorkSheet:Range ("Sort" ):Column
     GoodCode#ROW = chWorkSheet:Range ("GoodCode" ):Row
     GoodCode#COL = chWorkSheet:Range ("GoodCode" ):Column
     GoodN#ROW    = chWorkSheet:Range ("GoodN" ):Row
     GoodEI#ROW   = chWorkSheet:Range ("EIn"   ):Row
     OKEI#ROW     = chWorkSheet:Range ("GoodEI"):Row
     Qnty#ROW     = chWorkSheet:Range ("Qnty"  ):Row
     Cost#ROW     = chWorkSheet:Range ("Cost"  ):Row
     Summa#ROW    = chWorkSheet:Range ("Summa" ):Row
     CliArt#ROW   = chWorkSheet:Range ("CliArt"):Row
     Art#ROW      = chWorkSheet:Range ("Art"   ):Row
     GoodN#COL    = chWorkSheet:Range ("GoodN" ):Column
     GoodEI#COL   = chWorkSheet:Range ("EIn"   ):Column
     OKEI#COL     = chWorkSheet:Range ("GoodEI"):Column
     Qnty#COL     = chWorkSheet:Range ("Qnty"  ):Column
     Cost#COL     = chWorkSheet:Range ("Cost"  ):Column
     Summa#COL    = chWorkSheet:Range ("Summa" ):Column
     CliArt#COL   = chWorkSheet:Range ("CliArt"):Column
     Art#COL      = chWorkSheet:Range ("Art"   ):Column
     no-error.
         Current-ROW = maximum( if N#ROW       = ? then 0 else N#ROW      ,
                                if GoodN#ROW   = ? then 0 else GoodN#ROW  ,
                                if GoodEI#ROW  = ? then 0 else GoodEI#ROW ,
                                if OKEI#ROW    = ? then 0 else OKEI#ROW   ,
                                if Art#ROW  = ? then 0 else Art#ROW ,
                                if CliArt#ROW  = ? then 0 else CliArt#ROW ,
                                if Qnty#ROW    = ? then 0 else Qnty#ROW   ,
                                if Cost#ROW    = ? then 0 else Cost#ROW   ,
                                if Summa#ROW   = ? then 0 else Summa#ROW  )
                                .
      For each  buf_ord-line-rcv where
                buf_ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code and
                buf_ord-line-rcv.doc-code = ub.ord-doc-rcv.doc-code
                no-lock :
       chWorkSheet:Rows(Current-ROW):Insert .
      End.
      For each  buf_ord-line-rcv where
                buf_ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code  and
                buf_ord-line-rcv.doc-code = ub.ord-doc-rcv.doc-code
                no-lock :
         J = J + 1 .
         FIND FIRST ub.goods No-LOCK WHERE ub.goods.prod-type = buf_ord-line-rcv.prod-type AND
                                        ub.goods.prod-code = buf_ord-line-rcv.prod-code AND
                                        ub.goods.artic     = buf_ord-line-rcv.artic  NO-ERROR.
         find first ub.units where ub.units.unit-name = buf_ord-line-rcv.unit-cli no-lock no-error .
         find first buf_ord-line no-lock where
                    buf_ord-line.artic = buf_ord-line-rcv.artic and
                    buf_ord-line.prod-type = buf_ord-line-rcv.prod-type and
                    buf_ord-line.prod-code = buf_ord-line-rcv.prod-code and
                    buf_ord-line.doc-code  = buf_ord-line-rcv.doc-code no-error .
          if available buf_ord-line then v-cli-art = buf_ord-line.cli-art .
                                    else v-cli-art = "" .
         Assign chWorkSheet:Range (string(COL-NAME[N#col])        + String(N#ROW        + J)):Value  = J no-error.
         Assign chWorkSheet:Range (string(COL-NAME[GoodN#col])    + String(GoodN#ROW    + J)):Value  = ub.goods.gds-name no-error.
         Assign chWorkSheet:Range (string(COL-NAME[Sort#col])     + String(Sort#ROW     + J)):Value  = ub.goods.Sort     no-error.
         Assign chWorkSheet:Range (string(COL-NAME[GoodCode#col]) + String(GoodCode#ROW + J)):Value  = ub.goods.gds-code no-error.
         Assign chWorkSheet:Range (string(COL-NAME[GoodEI#col])   + String(GoodEI#ROW   + J)):Value  = buf_ord-line-rcv.unit-cli  no-error.
         Assign chWorkSheet:Range (string(COL-NAME[OKEI#col])     + String(OKEI#ROW     + J)):Value  = if available ub.units THEN String(ub.units.OKEI,">>>>>") Else "" no-error.
         Assign chWorkSheet:Range (string(COL-NAME[CliArt#col])   + String(CliArt#ROW   + J)):Value  = v-cli-art no-error.
         Assign chWorkSheet:Range (string(COL-NAME[Art#col])      + String(Art#ROW      + J)):Value  = buf_ord-line-rcv.artic no-error.
         Assign chWorkSheet:Range (string(COL-NAME[Qnty#col])     + String(Qnty#ROW     + J)):Value  = buf_ord-line-rcv.cli-qnty no-error .
         Assign chWorkSheet:Range (string(COL-NAME[Cost#col])     + String(Cost#ROW     + J)):Value  = buf_ord-line-rcv.price-cli no-error .
         Assign chWorkSheet:Range (string(COL-NAME[Summa#col])    + String(Summa#ROW    + J)):Value  = round ( buf_ord-line-rcv.cli-qnty * buf_ord-line-rcv.price-cli , 2) no-error .
       END.
      chWorkSheet:Rows(Current-ROW):Delete.
      assign
      chExcelApplication:Interactive    = true
      chExcelApplication:ScreenUpdating = true
      chExcelApplication:Visible        = TRUE .
   End.
  message "Форма Поставки подготовлена. Связь с Excel будет закрыта."  view-as alert-box .
  RELEASE OBJECT chWorksheet NO-ERROR.
  RELEASE OBJECT chWorkbook NO-ERROR.
  chExcelApplication :QUIT().
  RELEASE OBJECT  chExcelApplication  NO-ERROR.
  RETURN NO-APPLY.
END.
ON CHOOSE OF MENU-ITEM m_PRINT3-rcv
DO:
  if not available ub.ord-doc-rcv then return .
  run cus/l-blank.w ( input ub.ord-doc-rcv.cli-type , input ub.ord-doc-rcv.cli-code, output blank#name-rcv ).
  return no-apply.
END.
ON RETURN, MOUSE-SELECT-DBLCLICK OF sch-code IN FRAME d-all-docs DO:
    run proc-doc-code in this-procedure( no, input frame d-all-docs sch-code ) no-error.
    return no-apply.
END.
ON RETURN, MOUSE-SELECT-DBLCLICK OF sch-date IN FRAME d-all-docs DO:
    assign
      sch-date
      no-error
    .
    run proc-doc-date in this-procedure( no, sch-date ) no-error.
    return no-apply.
END.
ON RETURN, MOUSE-SELECT-DBLCLICK OF sch-fact IN FRAME d-all-docs DO:
   assign
     sch-fact
     no-error
   .
    run proc-fact-date in this-procedure( no, sch-fact ) no-error.
    return no-apply.
END.
ON CTRL-J OF sch-code IN FRAME d-all-docs
DO:
  run proc-doc-code in this-procedure(yes, input frame d-all-docs sch-code) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-date IN FRAME d-all-docs
DO:
  assign
    sch-date
  .
  run proc-doc-date in this-procedure(yes, sch-date) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-fact IN FRAME d-all-docs
DO:
assign
  sch-fact
.
  run proc-fact-date in this-procedure(yes,  sch-fact) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m-sost in menu m-exec DO:
define variable pardoc-rec as recid no-undo .
find current shar-buf_ord-doc no-lock no-error .
if not  available shar-buf_ord-doc then return no-apply .
varnext-prev = no.
br-handle = br-docs:handle  in frame d-all-docs .
bf-handle = buffer shar-buf_ord-doc:handle in frame d-all-docs .
do while varnext-prev <> ?:
  if not available shar-buf_ord-doc then do:
    message "Неправильный выбор документа.".
    return no-apply.
  end.
  pardoc-rec = recid (shar-buf_ord-doc)  .
  run cus/ord-sost.w
    ( parParentProc ,
      'ПРОСМОТР':U ,
      shar-buf_ord-doc.doc-code ,
      br-handle ,
      bf-handle ,
      input-output varnext-prev ,
      input-output pardoc-rec
      )  .
  if br-handle = ? then do:
     reposition br-docs to recid pardoc-rec no-error.
     apply "value-changed" to br-docs in frame d-all-docs .
  end.
 end.
END.
ON CHOOSE OF MENU-ITEM m-edoc-nn in menu m-exec DO:
define variable v-rec as recid no-undo .
define variable v-err as logical no-undo .
define variable is-edi-doc as logical no-undo .
 if ( is-edoc-nn = false and is-edi = false ) then return .
    find current shar-buf_ord-doc no-lock no-error .
    v-rec = recid(shar-buf_ord-doc) .
    run ver-clients-calc (
          input shar-buf_ord-doc.cli-type
        , input shar-buf_ord-doc.cli-code
        , input shar-buf_ord-doc.obj-type
        , input shar-buf_ord-doc.obj-code
        , input shar-buf_ord-doc.e-method
        , output v-err
                          ) .
    if v-err then do:
     message 'Заказ не был раcсчитан !!!' view-as alert-box error .
     return .
    end.
    run ver-ord-line (input shar-buf_ord-doc.doc-code, output v-err ) .
    if v-err then do:
     message 'Имеются ошибки в линиях !!!' view-as alert-box error .
     return .
    end.
    run cus/edocsord.p ( input parparentproc
                        ,input v-rec
                        ,input 'ord-doc':U
                        ,input no
                        )  .
    run UI-on in this-procedure (yes, no, '':U).
    reposition br-docs to recid v-rec no-error.
    apply "value-changed" to br-docs in frame d-all-docs .
END.
ON CHOOSE OF MENU-ITEM m-edoc-ok in menu m-exec DO:
define variable v-rec as recid no-undo .
    find current shar-buf_ord-doc no-lock no-error .
    v-rec = recid(shar-buf_ord-doc) .
    if  ( is-edi     = false or shar-buf_ord-doc.whole-send-news <> integer('2':U) )
    and ( is-edoc-nn = false or shar-buf_ord-doc.whole-send-news <> integer('1':U) )
    then return.
    run cus/edocrok.p ( input parparentproc).
    run UI-on in this-procedure (yes, no, '':U).
    reposition br-docs to recid v-rec no-error.
    apply "value-changed" to br-docs in frame d-all-docs .
END.
ON CHOOSE OF MENU-ITEM m-edoc-rpl-ok in menu m-exec DO:
define variable v-rec as recid no-undo .
if ( is-edoc-nn = false and is-edi = false ) then return .
    find current shar-buf_ord-doc share-lock no-error .
    v-rec = recid (shar-buf_ord-doc) .
    if  ( is-edoc-nn = false or shar-buf_ord-doc.whole-send-news <> integer('1':U) )
    then return.
    if not
    (shar-buf_ord-doc.whole-send-news = integer('1':U)
      and (shar-buf_ord-doc.ord-int1  =  integer('3':U)
            or
            shar-buf_ord-doc.ord-int1  =  integer('7':U)
          )
            )
    then do:
          message
      substitute("Заказ &1 находится в статусе &2&3" +
                 "отсылка подтверждения в этом статусе НЕПРЕДУСМОТРЕНА&3" +
                 "Попробуйте ОБНОВИТЬ данные на экране (нажмите F5),&3" +
                 "чтобы увидеть текущий статус заказа"
                , shar-buf_ord-doc.doc-code
                , entry (lookup (string(shar-buf_ord-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , ',отправлен,принят,подтвержден,подтвержденOk,согласованный ушел,принят согласованный,поставка пришла,поставка принята,ПН отправлена,Отказ')
                , chr(10))
     view-as alert-box error .
     return no-apply.
    end.
    run cus/edocsord.p ( input parparentproc
                        ,input v-rec
                        ,input 'ord-doc':U
                        ,input no
                        )  .
    run UI-on in this-procedure (yes, no, '':U).
    reposition br-docs to recid v-rec no-error.
    apply "value-changed" to br-docs in frame d-all-docs .
END.
ON CHOOSE OF MENU-ITEM m-edoc-trn in menu m-exec DO:
define variable v-rec1 as recid no-undo .
define variable v-rec2 as recid no-undo .
define variable v-rec as recid no-undo .
 if is-edoc-nn = false then return .
    find current shar-buf_ord-doc no-lock no-error .
    v-rec2 = recid( shar-buf_ord-doc ) .
if  ( is-edoc-nn = false or shar-buf_ord-doc.whole-send-news <> integer('1':U) )
    then return.
    find current ord-doc-rcv no-lock no-error .
    v-rec1 = recid( ord-doc-rcv ) .
    find current trn-doc no-lock no-error .
    if not available trn-doc then do:
       message "Накладной нет! " view-as alert-box information .
       return .
    end.
    if trn-doc.status_ <>  'факт':U then do:
       message "Статус накладной должен быть ФАКТ ! " view-as alert-box information .
       return .
    end.
    v-rec = recid ( trn-doc ) .
    Message
    substitute("Пересылать вручную накладную &1. Продолжать ?" , trn-doc.doc-code  )view-as alert-box
              QUESTION buttons YES-NO update g#log.
              if NOT g#log then return .
    run cus/edocsord.p ( input parparentproc
                        ,input v-rec
                        ,input 'trn-doc':U
                        ,input no
                        )  .
    run ui-on in this-procedure (yes, no, '':u).
    reposition br-rcv to recid v-rec1 no-error.
    apply "value-changed" to br-rcv in frame d-all-docs .
    reposition br-docs to recid v-rec2 no-error.
    apply "value-changed" to br-docs in frame d-all-docs .
END.
ON CHOOSE OF MENU-ITEM m-exp in menu m-exec DO:
   run cus/g-allord.p (parParentProc , g#type ).
END.
ON CHOOSE OF MENU-ITEM m-imp in menu m-exec DO:
   run cus/ord-load.p (parParentProc , g#type) .
   run UI-on (yes, no, '':U) .
END.
ON CHOOSE OF MENU-ITEM m-cycle in menu m-exec DO:
  define variable ll-recid as recid no-undo .
  define variable v-kol-ord as integer   no-undo .
  find current shar-buf_ord-doc no-lock no-error .
  if avail shar-buf_ord-doc then do:
    ll-recid = recid ( shar-buf_ord-doc ).
    run cus/ord-cyc.p
      (input v-cntxt-obj-type ,
       input v-cntxt-obj-code ,
       input this-procedure ,
       output v-kol-ord
    ).
    run UI-on in this-procedure  (yes, no, '':U) .
    apply "value-changed" to br-docs in frame d-all-docs .
END.
END.
ON CHOOSE OF MENU-ITEM m-del-cycle in menu m-exec DO:
  define variable ll-recid as recid no-undo .
  find current shar-buf_ord-doc no-lock no-error .
  if avail shar-buf_ord-doc then do:
    ll-recid = recid (shar-buf_ord-doc).
    run cus/ord-dcyc.p ( ll-recid) .
    run UI-on in this-procedure (yes, no, '':U) .
    reposition br-docs to recid ll-recid no-error.
    apply "value-changed" to br-docs in frame d-all-docs .
  end.
END.
ON CHOOSE OF MENU-ITEM m-del in menu m-exec DO:
   If v-cntxt-db-num <> 0  Then message "Расчет возможен только в ГБД" view-as alert-box .
   Else DO :
      run cus/ord-date.w ( parParentProc , g#type).
      run UI-on in this-procedure  (yes, no, '':U) .
   End.
END.
ON CHOOSE OF MENU-ITEM m-cl in menu m-exec DO:
    run UI-on in this-procedure  (yes, no, '':U) .
    Message "Автоматическое закрытие документов в текущем списке в статусе ЗАКРЫТО. Продолжать ?" view-as alert-box
              QUESTION buttons YES-NO update g#log.
              if NOT g#log then return .
      DO WHILE AVAILABLE(shar-buf_ord-doc)  :
        if shar-buf_ord-doc.status_ = 'закрыто':U then do:
                 run cus/ord-clos.p
                 (
                   input   parParentProc
                  ,input   recid(shar-buf_ord-doc)
                  ,input   store-type
                  ,input   store-code
                  ,input   v-cntxt-db-num
                  ,input   false
                  , input  "no"
                  ) no-error .
        end.
        GET NEXT br-docs.
      END.
    run UI-on in this-procedure (yes, no, '':U) .
END.
ON CHOOSE OF MENU-ITEM m-client in menu m-payment DO:
    payment-type = 'Контрагент':U.
    apply "choose" to b-payment in frame d-all-docs.
END.
ON CHOOSE OF MENU-ITEM m-doc in menu m-payment DO:
    payment-type = 'документы':U.
    apply "choose" to b-payment in frame d-all-docs.
END.
ON CHOOSE OF b-history IN FRAME d-all-docs
DO:
    if available shar-buf_ord-doc then do:
        run cus/ordcdoc.w
        (
        parParentProc,
        shar-buf_ord-doc.host-code,
        shar-buf_ord-doc.doc-code,
        "" ) .
    end.
END.
on choose of b-mark in frame d-all-docs do:
  run local-mark  in this-procedure no-error .
  if error-status :error  then return .
  g#log = br-docs:select-next-row ().
  apply "entry" to br-docs in frame d-all-docs.
end.
on choose of b-sost in frame d-all-docs do:
   define variable g-log as logical   no-undo .
   if not available shar-buf_ord-doc then return.
   if not ( shar-buf_ord-doc.doc-type = 'ОФ':U or shar-buf_ord-doc.doc-type = 'ОП':U  ) then return no-apply .
define variable vss-include-info50 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_pmnt-ord-doc_reject':U
    ,input  'object':U
    ,input  g#host-code
    ,input  shar-buf_ord-doc.obj-type
    ,input  shar-buf_ord-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
   if not g-log then do:
      message
        "Отказ от заказа запрещен!"
      view-as alert-box error.
      return .
   end.
   run set-reject  in this-procedure no-error .
   if error-status :error then
   message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     "Ошибка в процедуре  set-reject"
     view-as alert-box error
   .
end.
on any-printable of br-docs in frame d-all-docs do:
  apply "entry" to sch-code in frame d-all-docs.
end.
ON CHOOSE OF b-copy IN FRAME d-all-docs
DO:
 define variable g-log as logical   no-undo .
define variable vss-include-info51 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_pmnt-ord-doc_add-def':U
    ,input  'object':U
    ,input  g#host-code
    ,input  store-type
    ,input  store-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
 if not g-log then  return .
 run pp-1 in this-procedure .
End.
ON CHOOSE OF b-add IN FRAME d-all-docs
DO:
 define variable g-log as logical   no-undo .
define variable vss-include-info52 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_pmnt-ord-doc_add-def':U
    ,input  'object':U
    ,input  g#host-code
    ,input  store-type
    ,input  store-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
 if not g-log then  return .
  run proc-b-add in this-procedure .
END.
ON CHOOSE OF b-chg IN FRAME d-all-docs
DO:
 define variable g-log as logical   no-undo .
define variable vss-include-info53 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_pmnt-ord-doc_update':U
    ,input  'object':U
    ,input  g#host-code
    ,input  shar-buf_ord-doc.obj-type
    ,input  shar-buf_ord-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
 if not g-log then  return .
  run proc-b-chg in this-procedure .
END.
ON CHOOSE OF b-del IN FRAME d-all-docs  DO:
 define variable g-log as logical   no-undo .
define variable vss-include-info54 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_pmnt-ord-doc_deletion':U
    ,input  'object':U
    ,input  g#host-code
    ,input  store-type
    ,input  store-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
 if not g-log then  return .
run pp-2 in this-procedure .
END.
on choose of b-sch in frame d-all-docs do:
assign
  tbl = 'ord-doc'
  join-tbl = 'shar-buf_ord-doc'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('doc-code'                      , '№ заказа'  , '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('order-type'                    , 'Цикличность' , '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-type'                      , 'Тип'       , 'order-type-all',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_'                       , 'Статус'    , 'order-status-all',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('flag_'                         , 'ОК'        , '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-date'                      , 'Дата док-та', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date'                     , 'Дата факт'  , '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-type*cli-code'  , 'Контрагент' , 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type*obj-code'  , 'Объект'     , 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('agnt'                          , 'Исполнитель', 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('boss'                          , 'Менеджер'   , 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('wrkr'                          , 'Кладовщик'  , 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('creid'                         , 'Создал'     , 'usr',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code'                     , 'Фирма'      , '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-code'                      , 'Код оплаты' , 'pay',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ship-date'                     , 'Дата отгрузки' , '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ship-time'                     , 'Время отгрузки', 'time',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('PS'                            , 'Примечание', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('buyer-out-code'                , '', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-out-doc'                   , '', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('contract-code'                 , 'Вн.№ договора', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('exch-code'                     , 'Валюта','curr',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name'                     , 'Правил', 'usr',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    Filter-Block:
    DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
        ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
        ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
      run gbl/filter.w (
        INPUT parparentproc,
        INPUT filter-point  + chr(4) + filter-label + chr(4) + "yes",
        INPUT tbl,
        INPUT join-tbl,
        INPUT fld,
        INPUT lab,
        INPUT spr,
        INPUT dim ).
      run UI-on in this-procedure (yes, no, '':U).
    END.
end.
ON CHOOSE OF b-lkp IN FRAME d-all-docs
DO:
 define variable g-log as logical   no-undo .
define variable vss-include-info55 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_pmnt-ord-doc_lookup':U
    ,input  'object':U
    ,input  g#host-code
    ,input  store-type
    ,input  store-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
  if not g-log
  then do:
    return .
  end.
if not available shar-buf_ord-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (shar-buf_ord-doc). do on stop undo, return no-apply :   find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec no-lock .   end.
next-prev = no.
br-handle = br-docs:handle.
do while next-prev <> ?:
  if not available shar-buf_ord-doc then do:
    message "Неправильный выбор документа.".
    return no-apply.
  end.
  bf-handle = buffer shar-buf_ord-doc:handle in frame d-all-docs .
  run cus/ord-zakz.p (
     input        parParentProc ,
     input        'ПРОСМОТР':U ,
     input        shar-buf_ord-doc.doc-type ,
     output       doc-rec ,
     input-output br-handle ,
     input-output bf-handle ,
     input-output next-prev
     ) .
end.
if br-handle = ? then do:
  reposition br-docs to recid doc-rec no-error.
end.
  apply "value-changed" to br-docs in frame d-all-docs .
END.
ON CHOOSE OF b-print IN FRAME d-all-docs
DO:
    run gbl/pop-up.p ( self:handle, no) no-error.
    if error-status:error then return no-apply.
END.
ON CHOOSE OF b-email IN FRAME d-all-docs
    DO:
         g#log = true  .
         IF NOT AVAILABLE shar-buf_ord-doc THEN RETURN .
  message "Отправить письмо по e-mail? ." skip "Продолжать ?"
           view-as alert-box question buttons ok-cancel update g#log.
           if not g#log then do:   find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec no-lock.   return no-apply. end.
        run cus/z-tott.p (parParentProc, shar-buf_ord-doc.doc-code,  shar-buf_ord-doc.obj-type, shar-buf_ord-doc.obj-code, output p-file).
        RETURN NO-APPLY.
    END.
ON CHOOSE OF b-cons IN FRAME d-all-docs
DO:
  define variable v-recid as recid no-undo .
  run clip-ord in this-procedure ( output v-recid ).
  run UI-on    in this-procedure ( yes, no, '':U  ).
  reposition br-docs to recid v-recid no-error.
  apply "value-changed" to br-docs in frame d-all-docs .
END.
ON CHOOSE OF b-print-rcv IN FRAME d-all-docs
DO:
    run gbl/pop-up.p ( self:handle, no) no-error.
    if error-status:error then return no-apply.
END.
ON CHOOSE OF b-rep IN FRAME d-all-docs
DO:
    if choice = ? then do:
        run gbl/pop-up.p (self:handle, no) no-error.
        if error-status:error then return no-apply.
    end.
END.
ON CHOOSE OF b-exec IN FRAME d-all-docs
DO:
    if choice = ? then do:
        run gbl/pop-up.p (self:handle, no) no-error.
        if error-status:error then return no-apply.
    end.
END.
ON CHOOSE OF b-sel IN FRAME d-all-docs
DO:
if not available shar-buf_ord-doc then do:
  message "Неправильный выбор документа.".
  return no-apply.
end.
doc-rec = recid (shar-buf_ord-doc).
if del-list = ? or del-list = "" then del-list = string(recid (shar-buf_ord-doc)).
DELETE WIDGET-POOL "My-pool" no-error  .
apply "go" to frame d-all-docs.
END.
ON CHOOSE OF b-quit IN FRAME d-all-docs
DO:
  if not ( del-list = ?  or  del-list = "" )  then do:
      run gbl/markqwa.p (
                    input b-mark:sensitive
                  , input ? ) no-error.
      if error-status:error then return no-apply.
  end.
  doc-rec = ?.
  del-list = ? .
  DELETE WIDGET-POOL "My-pool" no-error  .
END.
ON entry OF ed-notes IN FRAME d-all-docs
DO:
if not available shar-buf_ord-doc then do:
  message "Неправильный выбор документа.".
  return no-apply.
end.
doc-rec = recid (shar-buf_ord-doc).
if shar-buf_ord-doc.status_ <> 'факт':U and substring (shar-buf_ord-doc.PS, 1, 1) = "@" then
  message "Чтобы программа не могла заново переписать Ваше примечание, удалите знак @.".
END.
on leave of ed-notes in frame d-all-docs
do:
  do on stop undo, return no-apply:
    find first t-d-b where t-d-b.doc-code = shar-buf_ord-doc.doc-code exclusive-lock no-error .
    if available t-d-b then
      t-d-b.ps = input frame d-all-docs ed-notes.
    find first t-d-b where t-d-b.doc-code = shar-buf_ord-doc.doc-code no-lock  no-error .
  end.
end.
ON RETURN, MOUSE-SELECT-DBLCLICK OF ed-notes IN FRAME d-all-docs DO:
apply "entry" to br-docs in frame d-all-docs.
return no-apply.
END.
ON RETURN, MOUSE-SELECT-DBLCLICK OF br-docs IN FRAME d-all-docs DO:
apply "choose" to b-lkp in frame d-all-docs.
END.
ON iteration-changed OF br-docs do:
  if available shar-buf_ord-doc then do:
    find cli-buf where cli-buf.obj-type = 'чел':U and cli-buf.obj-code = shar-buf_ord-doc.boss no-lock no-error.
    if available cli-buf then boss-name = cli-buf.obj-name. else boss-name = ?.
    find cli-buf where cli-buf.obj-type = 'чел':U and cli-buf.obj-code = shar-buf_ord-doc.agnt no-lock no-error.
    if available cli-buf then agnt-name = cli-buf.obj-name. else agnt-name = ?.
    find cli-buf where cli-buf.obj-type = 'чел':U and cli-buf.obj-code = shar-buf_ord-doc.wrkr no-lock no-error.
    if available cli-buf then wrkr-name = cli-buf.obj-name. else wrkr-name = ?.
define variable vss-include-info56 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  shar-buf_ord-doc.creid
  ,output v-user-name
  )  .
    find ub.pay-type where ub.pay-type.obj-code = shar-buf_ord-doc.pay-code no-lock no-error.
    if available ub.pay-type then pay-type = ub.pay-type.obj-name .
    ed-notes = trim(shar-buf_ord-doc.PS).
    disp ed-notes  boss-name agnt-name wrkr-name v-user-name shar-buf_ord-doc.tot-lines pay-type with frame d-all-docs.
    OPEN QUERY BR-rcv FOR EACH ub.ord-doc-rcv no-lock where ub.ord-doc-rcv.doc-code = shar-buf_ord-doc.doc-code,       first bufs_ord-doc-rcv no-lock  where bufs_ord-doc-rcv.rcv-code =  ub.ord-doc-rcv.rcv-code and       bufs_ord-doc-rcv.doc-code =  ub.ord-doc-rcv.doc-code  ,       first ub.ord-chain no-lock where              ub.ord-chain.doc-code = ub.ord-doc-rcv.rcv-code and             ub.ord-chain.doc-type = 'rcv'                  and              ub.ord-chain.rel-doc-type = 'trn' OUTER-JOIN,       EACH ub.trn-doc no-lock WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code OUTER-JOIN.
    if shar-buf_ord-doc.doc-type = 'ОО':U or
       shar-buf_ord-doc.doc-type = 'ОР':U then do:
    disable b-add-2
            b-lkp-2
            b-chg-2
            b-del-2
            b-close-2  with frame d-all-docs .
    end.
    else do:
    if x-mode <> "contract"  then
        enable b-add-2
                b-lkp-2
                b-chg-2
                b-del-2
                b-close-2  with frame d-all-docs .
    end.
    if doc-rec <> recid (shar-buf_ord-doc) then do:
      sch-num = 0.
      hide sch-num in frame d-all-docs.
    end.
  end.
end.
ON ROW-DISPLAY OF BR-DOCS DO:
define variable v-str as character no-undo .
define variable v-loc-color as integer no-undo .
assign
v-str = status-edoc-edi-light(buffer shar-buf_ord-doc, input is-edoc-nn, input is-edi, output v-loc-color)
no-error.
if error-status:error then do:
            str-status-edoc-nn:bgcolor in browse BR-DOCS = ?.
          end.
    else do:
  str-status-edoc-nn:bgcolor in browse BR-DOCS = v-loc-color.
    end.
    if ( shar-buf_ord-doc.need-fo = 1    and
       shar-buf_ord-doc.cr-fo    = true  and
       shar-buf_ord-doc.need-fo2  = 1    and
    shar-buf_ord-doc.cr-fo2 = false   )   then do:
       v-fo:fgcolor in browse BR-DOCS = 5   .
end.
end.
ON CHOOSE OF b-add-obj-2 IN FRAME d-all-docs
DO:
define variable t-ret as logical no-undo .
 define variable g-log as logical   no-undo .
define variable vss-include-info57 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_ord-rcv_add-def':U
    ,input  'object':U
    ,input  g#host-code
    ,input  store-type
    ,input  store-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
 if not g-log then  return .
if not available shar-buf_ord-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (shar-buf_ord-doc). do on stop undo, return no-apply :   find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec exclusive-lock .   end. if shar-buf_ord-doc.status_     = 'факт':U and shar-buf_ord-doc.flag_= true  then do:    find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec no-lock.    message "Заказ закрыт до статуса ФАКТ .".    return no-apply. end.
  t-ret =  session:SET-WAIT-STATE("GENERAL") .
   if shar-buf_ord-doc.status_ <> 'поставка':U
     then do:
     message
     "Нельзя делать Поставку на  Заказ в статусе " caps(shar-buf_ord-doc.status_) " !"
                 view-as alert-box information .
        return.
   end.
   if (( ( shar-buf_ord-doc.ord-int1 = int('5':U)
      or shar-buf_ord-doc.ord-int1 = int('6':U) )
     and is-edoc-nn
          and shar-buf_ord-doc.whole-send-news = integer('1':U)
      )
   or (  shar-buf_ord-doc.ord-int1 = int('6':U)
     and is-edi
        and shar-buf_ord-doc.whole-send-news = integer('2':U)
      )
   )
   and   shar-buf_ord-doc.doc-type = 'ОП':U then do:
     message
     "Нельзя делать Поставки на Заказ при работе в EDOC\EDI ! Она придет в электронном виде от поставщика."
                 view-as alert-box information .
        return.
   end.
   if can-find (first ord-doc-rcv where ord-doc-rcv.doc-code = shar-buf_ord-doc.doc-code no-lock ) then do:
        message "Не могу сделать автоматические поставки по заказу " caps(shar-buf_ord-doc.doc-code) "!" "Поставки уже сформированы !"
                 view-as alert-box information .
        return.
        end.
   if shar-buf_ord-doc.e-method = "" then do:
     message
     "Не могу сделать автоматические поставки по заказу " caps(shar-buf_ord-doc.doc-code) "!" "Неизвестен список объектов."
                 view-as alert-box information .
        return.
   end.
   e-method = shar-buf_ord-doc.e-method .
   define buffer buf55_ord-line for ub.ord-line  .
   define buffer buf55_ord-line-attr for ub.ord-line-attr  .
   find first buf55_ord-line no-lock where
              buf55_ord-line.doc-code = shar-buf_ord-doc.doc-code no-error .
   if (not can-find ( first buf55_ord-line-attr where
                       buf55_ord-line-attr.doc-code = buf55_ord-line.doc-code and
                       buf55_ord-line-attr.gds-code = buf55_ord-line.gds-code and
                       buf55_ord-line-attr.attr-code  begins "objqnty" ) )
      or
      ( can-find ( first buf55_ord-line where
                          buf55_ord-line.doc-code = shar-buf_ord-doc.doc-code and
                          buf55_ord-line.qnty <> buf55_ord-line.order-qnty ) )
     then do:
     message "Количество заказа по объектам не определено или изменено вручную, предлагается распределение по поставкам пропорционально темпу продаж на объекте"
     view-as alert-box information .
     run cus/ord-mthd.w ( input parParentProc , input recid(shar-buf_ord-doc) ,input  shar-buf_ord-doc.doc-type ) .
   end.
   else do:
   run cus/ord-fpat.p ( input parParentProc ,input shar-buf_ord-doc.doc-code  ) .
   end.
  OPEN QUERY BR-rcv FOR EACH ub.ord-doc-rcv no-lock where ub.ord-doc-rcv.doc-code = shar-buf_ord-doc.doc-code,       first bufs_ord-doc-rcv no-lock  where bufs_ord-doc-rcv.rcv-code =  ub.ord-doc-rcv.rcv-code and       bufs_ord-doc-rcv.doc-code =  ub.ord-doc-rcv.doc-code  ,       first ub.ord-chain no-lock where              ub.ord-chain.doc-code = ub.ord-doc-rcv.rcv-code and             ub.ord-chain.doc-type = 'rcv'                  and              ub.ord-chain.rel-doc-type = 'trn' OUTER-JOIN,       EACH ub.trn-doc no-lock WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code OUTER-JOIN.
  t-ret =  session:SET-WAIT-STATE("") .
END.
ON CHOOSE OF b-add-2 IN FRAME d-all-docs
DO:
define variable ll-rec as recid no-undo .
define variable t-ret as logical no-undo .
 define variable g-log as logical   no-undo .
define variable vss-include-info58 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_ord-rcv_add-def':U
    ,input  'object':U
    ,input  g#host-code
    ,input  store-type
    ,input  store-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
 if not g-log then  return .
if not available shar-buf_ord-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (shar-buf_ord-doc). do on stop undo, return no-apply :   find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec exclusive-lock .   end. if shar-buf_ord-doc.status_     = 'факт':U and shar-buf_ord-doc.flag_= true  then do:    find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec no-lock.    message "Заказ закрыт до статуса ФАКТ .".    return no-apply. end.
  t-ret =  session:SET-WAIT-STATE("GENERAL") .
  run make-fp-rcv in this-procedure (output ll-rec).
  OPEN QUERY BR-rcv FOR EACH ub.ord-doc-rcv no-lock where ub.ord-doc-rcv.doc-code = shar-buf_ord-doc.doc-code,       first bufs_ord-doc-rcv no-lock  where bufs_ord-doc-rcv.rcv-code =  ub.ord-doc-rcv.rcv-code and       bufs_ord-doc-rcv.doc-code =  ub.ord-doc-rcv.doc-code  ,       first ub.ord-chain no-lock where              ub.ord-chain.doc-code = ub.ord-doc-rcv.rcv-code and             ub.ord-chain.doc-type = 'rcv'                  and              ub.ord-chain.rel-doc-type = 'trn' OUTER-JOIN,       EACH ub.trn-doc no-lock WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code OUTER-JOIN.
  reposition BR-rcv to recid ll-rec no-error .
  t-ret =  session:SET-WAIT-STATE("") .
END.
ON CHOOSE OF b-chg-2 IN FRAME d-all-docs
DO:
define variable ll-rec as recid no-undo .
define variable t-ret as logical no-undo .
define variable  v-line-mode  as character no-undo .
define variable  v-doc-mode   as character no-undo .
define variable  v-list-mode  as character no-undo .
 define variable g-log as logical   no-undo .
define variable vss-include-info59 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_ord-rcv_update':U
    ,input  'object':U
    ,input  g#host-code
    ,input  store-type
    ,input  store-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
 if not g-log then  return .
if not available shar-buf_ord-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (shar-buf_ord-doc). do on stop undo, return no-apply :   find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec exclusive-lock .   end. if shar-buf_ord-doc.status_     = 'факт':U and shar-buf_ord-doc.flag_= true  then do:    find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec no-lock.    message "Заказ закрыт до статуса ФАКТ .".    return no-apply. end.
  t-ret =  session:SET-WAIT-STATE("GENERAL") .
  find current ub.ord-doc-rcv no-lock no-error.
    if available ub.ord-doc-rcv then do:
      if ub.ord-doc-rcv.status_ = 'факт':U then do :
        message "Документ в статусе" ub.ord-doc-rcv.status_  "изменять нельзя! " view-as alert-box error .
        return.
      end.
      if ub.ord-doc-rcv.cons-code <> ""  and  not v-edoc-ora
        then  do:
        Message "Внимание !!! Поставка из СЗФП ." view-as alert-box information  .
      end.
        v-doc-mode  = 'ИЗМЕНЕНИЕ':U.
        ll-rec = recid(ub.ord-doc-rcv) .
        if ub.ord-doc-rcv.status_ = 'поставка':U then  do:
          assign
            v-line-mode  = 'ПРОСМОТР':U
            v-doc-mode   = 'ПРОСМОТР':U
            v-list-mode  = 'поставка':U
            .
        end.
        else  do:
          assign
            v-line-mode = 'ИЗМЕНЕНИЕ':U
            v-doc-mode  = 'ИЗМЕНЕНИЕ':U
            .
        end.
        run cus/or-obj.w
        (      input  parParentProc
             , input  ub.ord-doc-rcv.host-code
             , input  recid(ub.ord-doc-rcv)
             , input  3
             , input  v-list-mode
             , input  v-line-mode
             , input-output  v-doc-mode  ) .
        OPEN QUERY BR-rcv FOR EACH ub.ord-doc-rcv no-lock where ub.ord-doc-rcv.doc-code = shar-buf_ord-doc.doc-code,       first bufs_ord-doc-rcv no-lock  where bufs_ord-doc-rcv.rcv-code =  ub.ord-doc-rcv.rcv-code and       bufs_ord-doc-rcv.doc-code =  ub.ord-doc-rcv.doc-code  ,       first ub.ord-chain no-lock where              ub.ord-chain.doc-code = ub.ord-doc-rcv.rcv-code and             ub.ord-chain.doc-type = 'rcv'                  and              ub.ord-chain.rel-doc-type = 'trn' OUTER-JOIN,       EACH ub.trn-doc no-lock WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code OUTER-JOIN.
        reposition BR-rcv to recid ll-rec no-error .
    end.
  find current shar-buf_ord-doc no-lock .
  t-ret =  session:SET-WAIT-STATE("") .
END.
ON CHOOSE OF b-lkp-2 IN FRAME d-all-docs
DO:
define variable ll-rec as recid no-undo .
define variable t-ret as logical no-undo .
define variable g-log as logical   no-undo .
define variable vss-include-info60 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_ord-rcv_lookup':U
    ,input  'object':U
    ,input  g#host-code
    ,input  store-type
    ,input  store-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
 if not g-log then  return .
next-prev = no.
br-rcv-handle = br-rcv:handle.
apply "entry" to BR-rcv .
do while next-prev <> ?:
  if not available bufs_ord-doc-rcv then do:
    message "Неправильный выбор документа.".
    return no-apply.
  end.
if not available shar-buf_ord-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (shar-buf_ord-doc). do on stop undo, return no-apply :   find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec no-lock .   end.
  t-ret =  session:SET-WAIT-STATE("GENERAL") .
find current ub.ord-doc-rcv no-lock no-error.
    if available ub.ord-doc-rcv then do:
        ll-rec = recid(ub.ord-doc-rcv) .
        run cus/lkp-rcv.w (input parParentProc, input-output ll-rec ) .
        OPEN QUERY BR-rcv FOR EACH ub.ord-doc-rcv no-lock where ub.ord-doc-rcv.doc-code = shar-buf_ord-doc.doc-code,       first bufs_ord-doc-rcv no-lock  where bufs_ord-doc-rcv.rcv-code =  ub.ord-doc-rcv.rcv-code and       bufs_ord-doc-rcv.doc-code =  ub.ord-doc-rcv.doc-code  ,       first ub.ord-chain no-lock where              ub.ord-chain.doc-code = ub.ord-doc-rcv.rcv-code and             ub.ord-chain.doc-type = 'rcv'                  and              ub.ord-chain.rel-doc-type = 'trn' OUTER-JOIN,       EACH ub.trn-doc no-lock WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code OUTER-JOIN.
        reposition BR-rcv to recid ll-rec no-error .
    end.
    else
      t-ret =  session:SET-WAIT-STATE("") .
end.
  if br-rcv-handle = ? then do:
    reposition  br-rcv to recid ll-rec no-error.
  end.
  t-ret =  session:SET-WAIT-STATE("") .
END.
ON CHOOSE OF b-del-2 IN FRAME d-all-docs
DO:
 define variable g-log as logical   no-undo .
define variable vss-include-info61 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_ord-rcv_deletion':U
    ,input  'object':U
    ,input  g#host-code
    ,input  store-type
    ,input  store-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
 if not g-log then  return .
   run proc-b-del-2 in this-procedure .
END.
oN CHOOSE OF b-close-2 IN FRAME d-all-docs
DO:
   run proc-close-2 in this-procedure .
END.
 on choose of b-payment in frame d-all-docs do:
 if not available shar-buf_ord-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (shar-buf_ord-doc). do on stop undo, return no-apply :   find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec no-lock .   end.
    define variable ri-list as char no-undo .
    if payment-type = "" then do:
       run gbl/pop-up.p (self:handle, no) no-error.
    end.
    if payment-type = "" then return no-apply.
define variable vss-include-info62 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_payments-reference_lookup':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
    if not g#log then do:
      return no-apply.
    end.
    case payment-type:
      when 'документы':U then do:
        if (shar-buf_ord-doc.status_  = 'факт':U and shar-buf_ord-doc.flag_ = yes) then do:
          run ref/payments.w
          (
            input parparentproc ,
            input (if v-cntxt-db-num = 0  then "b-add" else ""),
            input 'документы':U ,
            input ?,
            input ?,
            input 'заказ':U,
            input shar-buf_ord-doc.doc-code,
            input "",
            output ri-list) no-error.
        end.
        else do:
          assign
          payment-type = "".
          return no-apply.
        end.
      end.
      when 'Контрагент':U then do:
        find first ub.clients WHERE
                   ub.clients.obj-code = shar-buf_ord-doc.cli-code  AND
                   ub.clients.obj-type = shar-buf_ord-doc.cli-type  No-LOCK No-ERROR.
        run ref/payments.w
        (input parparentproc ,
                      input (if v-cntxt-db-num = 0 then "b-add" else ""),
                      input 'Контрагент':U ,
                      input recid(clients),
                      input ?,
                      input "",
                      input "",
                      input "",
                      output ri-list) no-error.
      end.
    end case.
    assign
    payment-type = "".
    .
run UI-on in this-procedure (yes, no, '':U) .
end.
ON CHOOSE OF MENU-ITEM m_gen-1  IN MENU m-exec DO:
run proc-m_gen-1 in this-procedure no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF MENU-ITEM m_gen-1_buyer  IN MENU m-exec DO:
run proc-m_gen-1_buyer in this-procedure no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF MENU-ITEM m_gen-2  IN MENU m-exec DO:
run proc-m_gen-2 in this-procedure no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF MENU-ITEM m_gen-3  IN MENU m-exec DO:
run proc-m_gen-3 in this-procedure no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF MENU-ITEM m_gen-4  in MENU m-exec DO:
run proc-m_gen-4 in this-procedure no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF MENU-ITEM m_lkp-fo  in MENU m-exec DO:
run proc-m_lkp-fo in this-procedure no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF MENU-ITEM m_gen-2-2  IN MENU m-exec DO:
run proc-m_gen-2-2 in this-procedure no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF MENU-ITEM m_gen-3-2  IN MENU m-exec DO:
run proc-m_gen-3-2 in this-procedure no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF MENU-ITEM m_gen-4-2  IN MENU m-exec DO:
run proc-m_gen-4-2 in this-procedure no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF b-close IN FRAME d-all-docs
DO:
define variable ll-recid as recid no-undo .
define variable mark-list as character no-undo.
define buffer buf_clients for ub.clients  .
define buffer buf_ext-classif for ub.ext-classif  .
define buffer buf1_ord-doc for ub.ord-doc.
  find current shar-buf_ord-doc no-lock no-error.
  if del-list = "" then
    assign
      mark-list = string(recid(shar-buf_ord-doc))
      .
  else
    assign
      mark-list = del-list
      .
  do kk = 1 to num-entries(mark-list) :
    for each shar-buf_ord-doc share-lock where recid(shar-buf_ord-doc) = integer(entry(kk,mark-list)):
      if shar-buf_ord-doc.status_ = 'факт':U and shar-buf_ord-doc.flag_= true  then do:
         message "Заказ закрыт до статуса ФАКТ .".
         next.
      end.
  if ( shar-buf_ord-doc.status_ = 'новый':U or
       shar-buf_ord-doc.status_ = 'поставка':U) and
       shar-buf_ord-doc.doc-type = 'ОП':U then do:
    if status-is-edoc-nn ( input is-edoc-nn
                          , input shar-buf_ord-doc.cli-type
                          , input shar-buf_ord-doc.cli-code
                          , input shar-buf_ord-doc.obj-type
                          , input shar-buf_ord-doc.obj-code
                          )
     or  (status-is-edi ( input is-edi
                      , input shar-buf_ord-doc.cli-type
                      , input shar-buf_ord-doc.cli-code
                      , input shar-buf_ord-doc.obj-type
                      , input shar-buf_ord-doc.obj-code
                      , output v-dm-edi
                      )
          and
          shar-buf_ord-doc.whole-send-news = integer('2':U)
          )
    then do:
      if shar-buf_ord-doc.status_ = 'новый':U then do:
        message
        substitute(" По ПОСТАВЩИКУ &1&2 система работает по EDOC\EDI , Закрыть можно будет при корректировке заказа в статусе EDOC\EDI ПОДТВЕРЖДЕН"
                   ,shar-buf_ord-doc.cli-type
                   ,shar-buf_ord-doc.cli-code
                   )
        view-as alert-box information .
            next .
      end.
      if shar-buf_ord-doc.status_ = 'поставка':U then do:
       define variable vv-ok as logical   no-undo .
       vv-ok = false .
       message
        substitute(" По ПОСТАВЩИКУ &1&2 система работает по EDOC\EDI. Заказ ожидает поставку. Вы уверены что хотите закрыть заказ без поставки?"
                   ,shar-buf_ord-doc.cli-type
                   ,shar-buf_ord-doc.cli-code)
           view-as alert-box question
           buttons yes-no
           update vv-ok
          .
            if not vv-ok then  next .
      end.
    end.
  end.
  message
    "Закрыть " (if shar-buf_ord-doc.doc-type  =  'ОФ':U then " заявку " else " заказ " ) shar-buf_ord-doc.doc-code  " ?"
    view-as alert-box question
    buttons yes-no
    update g#log .
      if not g#log then next.
      ll-recid = recid(shar-buf_ord-doc).
      run cus/ord-clos.p
        (input  parParentProc
        ,input  recid(shar-buf_ord-doc)
        ,input  store-type
        ,input  store-code
        ,input  v-cntxt-db-num
        ,input  true
        ,input  "no"
        ) no-error .
        if error-status :error or return-value <> "" then do:
            message return-value         skip
            error-status :get-message(1) skip
            view-as alert-box error
            title "Закрытие заказа"
          .
        end.
    end.
  end.
  find current shar-buf_ord-doc no-lock no-error.
  run ui-on in this-procedure (yes, no, '':U).
  reposition br-docs to recid ll-recid no-error.
  apply "value-changed" to br-docs in frame d-all-docs .
  return no-apply.
 END.
define variable vss-include-info63 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame d-all-docs anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame d-all-docs. END.
  return no-apply.
end.
define variable vss-include-info64 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame d-all-docs anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame d-all-docs. END.
  return no-apply.
end.
define variable vss-include-info65 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame d-all-docs anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame d-all-docs. END.
  return no-apply.
end.
define variable vss-include-info66 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame d-all-docs anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame d-all-docs. END.
  return no-apply.
end.
define variable vss-include-info67 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-F7 of frame d-all-docs anywhere do:
  if b-close :sensitive then DO: apply "CHOOSE":U to b-close in frame d-all-docs. END.
  return no-apply.
end.
define variable vss-include-info68 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame d-all-docs anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame d-all-docs. END.
  return no-apply.
end.
define variable vss-include-info69 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame d-all-docs anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame d-all-docs. END.
  return no-apply.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-all-docs:PARENT eq ?
THEN FRAME d-all-docs:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME d-all-docs APPLY "END-ERROR":U TO SELF.
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-all-docs
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
on choose of b-help in frame d-all-docs
do:
  apply "help":u to frame d-all-docs .
end.
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-all-docs:width - 0.3
                fh            = frame d-all-docs:first-child
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
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame d-all-docs :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-all-docs :height-chars)
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
    if frame d-all-docs :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-all-docs :height-chars)
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
            frame d-all-docs :height = v-frame-height
          .
          if frame d-all-docs :scrollable = true
          then do:
            assign
              frame d-all-docs :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-all-docs :scrollable = true
          then do:
            assign
              frame d-all-docs :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-all-docs :height = v-frame-height
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
      v-frame-height = frame d-all-docs :height
      v-frame-virtual-height = frame d-all-docs :virtual-height
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
      v-field-group-handle = frame d-all-docs :first-child
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
    do with frame d-all-docs
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-all-docs :scrollable = true
      then do:
        assign
          frame d-all-docs :virtual-height = frame d-all-docs :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-all-docs :height = frame d-all-docs :height + p-change-value
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
        frame d-all-docs :height = frame d-all-docs :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-all-docs :scrollable = true
      then do:
        assign
          frame d-all-docs :virtual-height = frame d-all-docs :virtual-height + p-change-value
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
          ,input  string(frame d-all-docs :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame d-all-docs :height)
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
    if frame d-all-docs :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-all-docs :width
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
    if frame d-all-docs :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-all-docs :width
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
            frame d-all-docs :width = v-frame-width
          .
          if frame d-all-docs :scrollable = true
          then do:
            assign
              frame d-all-docs :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-all-docs :scrollable = true
          then do:
            assign
              frame d-all-docs :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-all-docs :width = v-frame-width
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
      v-frame-width = frame d-all-docs :width
      v-frame-virtual-width = frame d-all-docs :virtual-width
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
      v-field-group-handle = frame d-all-docs :first-child
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
    do with frame d-all-docs
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-all-docs :scrollable = true
      then do:
        assign
          frame d-all-docs :virtual-width = frame d-all-docs :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-all-docs :width = v-frame-width + p-change-value
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
        frame d-all-docs :width = frame d-all-docs :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-all-docs :scrollable = true
      then do:
        assign
          frame d-all-docs :virtual-width = frame d-all-docs :virtual-width + p-change-value
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
          ,input  string(frame d-all-docs :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame d-all-docs :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-all-docs
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-all-docs :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-all-docs :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-all-docs :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-all-docs :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame d-all-docs
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
      v-row-delta = v-new-row - frame d-all-docs :height
      v-col-delta = v-new-col - frame d-all-docs :width
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
            - frame d-all-docs :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-all-docs :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-all-docs :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-all-docs :height-chars
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
      v-diasize-current-frame-width  = frame d-all-docs :width
      v-diasize-current-frame-height = frame d-all-docs :height
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
    do with frame d-all-docs
    :
      assign
        v-diasize-orig-frame-height = frame d-all-docs :height
        v-diasize-orig-frame-width  = frame d-all-docs :width
        v-diasize-browse-handle     = browse BR-docs :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-all-docs :first-child
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
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame d-all-docs anywhere
do:
  run UI-on (yes, no, '':U) .
    apply "VALUE-CHANGED" to br-docs.
end.
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of sch-date in frame d-all-docs
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
on delete-character of sch-date in frame d-all-docs
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
on ctrl-d of sch-date in frame d-all-docs
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
on ctrl-b of sch-date in frame d-all-docs
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
on ctrl-e of sch-date in frame d-all-docs
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
on ctrl-f of sch-date in frame d-all-docs
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
  define MENU m-ed-date75
    MENU-ITEM m-ed-date75-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date75-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date75-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date75-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-date :POPUP-MENU in frame d-all-docs = ?
  then do:
    ASSIGN
      sch-date :POPUP-MENU in frame d-all-docs = MENU m-ed-date75 :HANDLE
      sch-date :MENU-MOUSE in frame d-all-docs = 3
    .
  end.
  define variable v-label-handle75 as handle no-undo .
  assign
    v-label-handle75 = sch-date :side-label-handle in frame d-all-docs
  .
  if valid-handle (v-label-handle75)
  then do:
    if v-label-handle75 :tooltip = ""
    or v-label-handle75 :tooltip = ?
    then do:
      assign
        v-label-handle75 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date75-1 in menu m-ed-date75 DO:
    apply "ctrl-b":U to sch-date in frame d-all-docs .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date75-2 in menu m-ed-date75 DO:
    apply "ctrl-d":U to sch-date in frame d-all-docs .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date75-3 in menu m-ed-date75 DO:
    apply "ctrl-e":U to sch-date in frame d-all-docs .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date75-4 in menu m-ed-date75 DO:
    apply "ctrl-f":U to sch-date in frame d-all-docs .
  END.
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of sch-fact in frame d-all-docs
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
on delete-character of sch-fact in frame d-all-docs
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
on ctrl-d of sch-fact in frame d-all-docs
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
on ctrl-b of sch-fact in frame d-all-docs
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
on ctrl-e of sch-fact in frame d-all-docs
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
on ctrl-f of sch-fact in frame d-all-docs
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
  define MENU m-ed-date77
    MENU-ITEM m-ed-date77-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date77-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date77-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date77-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-fact :POPUP-MENU in frame d-all-docs = ?
  then do:
    ASSIGN
      sch-fact :POPUP-MENU in frame d-all-docs = MENU m-ed-date77 :HANDLE
      sch-fact :MENU-MOUSE in frame d-all-docs = 3
    .
  end.
  define variable v-label-handle77 as handle no-undo .
  assign
    v-label-handle77 = sch-fact :side-label-handle in frame d-all-docs
  .
  if valid-handle (v-label-handle77)
  then do:
    if v-label-handle77 :tooltip = ""
    or v-label-handle77 :tooltip = ?
    then do:
      assign
        v-label-handle77 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date77-1 in menu m-ed-date77 DO:
    apply "ctrl-b":U to sch-fact in frame d-all-docs .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date77-2 in menu m-ed-date77 DO:
    apply "ctrl-d":U to sch-fact in frame d-all-docs .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date77-3 in menu m-ed-date77 DO:
    apply "ctrl-e":U to sch-fact in frame d-all-docs .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date77-4 in menu m-ed-date77 DO:
    apply "ctrl-f":U to sch-fact in frame d-all-docs .
  END.
 x-mode =  list-mode.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP    UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
find sch-cli where recid (sch-cli) = p-doc-rec no-lock no-error.
find sch-cons where recid (sch-cons) = p-doc-rec no-lock no-error.
find sch-contract where recid (sch-contract) = p-doc-rec no-lock no-error.
doc-rec = ?.
define variable v-ok as logical   no-undo .
define variable v-mail as logical no-undo.
v-mail = b-email:load-image ("cmp/www.bmp").
v-ok = b-cons:load-IMAGE ("cmp/group.bmp") .
ENABLE b-quit  b-print b-sch b-history b-help br-docs  sch-code sch-date sch-fact ed-notes  b-rep  b-exec b-cons b-email
 b-print-rcv
 br-rcv
WITH FRAME d-all-docs.
 hide b-open in frame d-all-docs .
if is-edoc-nn = false and is-edi = false then  do:
   str-status-edoc-nn:VISIBLE IN BROWSE br-docs = FALSE.
end.
if g#type = 'ФП':U or  g#type = 'ОФ':U then
    assign
      str-status-edoc-nn:VISIBLE IN BROWSE br-docs = FALSE
    .
if lookup (x-mode,"firm-fin,firm-fintypestatus,without-fotypestatus,without-fo,with-fotypestatus,with-fo") > 0 then
br-docs:MOVE-COLUMN ( 15, 8 ) IN FRAME d-all-docs .
run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  browse br-rcv :handle
    ) .
run diasize_init in this-procedure .
run UI-on in this-procedure (yes, no, '':U).
run mode-g#type in this-procedure.
apply "value-changed" to br-docs in frame d-all-docs   .
WAIT-FOR GO OF FRAME d-all-docs focus br-docs.
END.
run disable_UI in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME d-all-docs.
END PROCEDURE.
PROCEDURE UI-on :
define input  parameter   p-open-query     as logical   no-undo init true .
define input  parameter   p-find-next      as logical   no-undo init false .
define input  parameter   p-find-condition as character no-undo .
  if p-open-query then frame d-all-docs:title = "ВСЕ  ДОКУМЕНТЫ".
  sch-num = 0.
  hide sch-num in frame d-all-docs.
define variable v-l-mode as character no-undo .
v-l-mode = list-mode .
x-mode  = list-mode.
if g#type <> "all" and g#type <> ? then x-mode  = list-mode + "type" .
if g#stat <> "all" and g#stat <> ? then x-mode  = list-mode + "type" + "status".
Disable b-payment  WITH FRAME d-all-docs.
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
filter-point = filter-point0 + v-l-mode.
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
define variable l-open-query as logical   no-undo .
if Lookup("nob-exec",p-buttons) <> 0 then disable b-exec WITH FRAME d-all-docs. else enable b-exec  WITH FRAME d-all-docs.
if Lookup("nob-copy",p-buttons) <> 0 then disable b-copy WITH FRAME d-all-docs. else enable b-copy  WITH FRAME d-all-docs.
enable b-mark WITH FRAME d-all-docs.
if Lookup("b-sel",p-buttons) <> 0 then enable  b-sel WITH FRAME d-all-docs.  else disable b-sel   WITH FRAME d-all-docs.
if Lookup("b-del",p-buttons) <> 0 then
   enable  b-del   b-del-2 WITH FRAME d-all-docs.
   else disable b-del b-del-2  WITH FRAME d-all-docs.
if Lookup("b-lkp",p-buttons) <> 0 then
   enable b-lkp  b-lkp-2 WITH FRAME d-all-docs.
   else  disable b-lkp b-lkp-2 WITH FRAME d-all-docs.
if Lookup("b-chg",p-buttons) <> 0 then
   enable b-chg  b-chg-2 WITH FRAME d-all-docs.
   else  disable b-chg b-chg-2 WITH FRAME d-all-docs.
if Lookup("b-add",p-buttons) <> 0 then
   enable b-add  b-add-2 WITH FRAME d-all-docs.
   else  disable b-add b-add-2 WITH FRAME d-all-docs.
if Lookup("b-close",p-buttons) <> 0 then
   enable b-close b-close-2 WITH FRAME d-all-docs.
   else  disable b-close b-close-2 WITH FRAME d-all-docs.
if Lookup("fin-block",p-buttons) <> 0 then
   disable b-close b-payment  b-copy
           b-add-2
           b-chg-2
           b-close-2
           b-del-2
           b-add-obj-2
           WITH FRAME d-all-docs.
if g#type = ?  then  do:
  disable b-add with frame d-all-docs .
end.
if g#type = 'ОФ':U and v-cntxt-db-num = 0  then  do:
  disable  b-copy   with frame d-all-docs .
end.
if g#type = 'ОП':U and v-cntxt-db-num = 0  then  do:
  disable b-copy with frame d-all-docs .
end.
CASE x-mode :
  when "firm":U then do:
      if p-open-query then frame d-all-docs:title = " Фирма : " + g#host-name.
      Disable b-add b-chg b-del b-close   b-close b-copy b-sost  WITH FRAME d-all-docs.
      Enable b-lkp
      WITH FRAME d-all-docs.
      if v-cntxt-level <>  'object':U then do:
        Disable b-payment   WITH FRAME d-all-docs.
        disable b-add-2
              b-chg-2
              b-del-2
              b-close-2
              with frame d-all-docs .
      end.
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-79  as logical   no-undo .
define variable  l-filter-open-79    as logical   .
define variable  flt-rec-79       as recid     no-undo .
define variable  filter-name-79      as character no-undo .
define variable  where-phrase-79     as character no-undo .
define variable  sort-phrase-79      as character no-undo .
define variable  where-phrase-rus-79 as character no-undo .
define variable  sort-phrase-rus-79  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-79
  ,output filter-name-79
  ,output where-phrase-79
  ,output sort-phrase-79
  ,output where-phrase-rus-79
  ,output sort-phrase-rus-79
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-79
      ) no-error .
  assign
    l-filter-open-79 = false
  .
  if flt-rec-79 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-79 as character no-undo .
    define variable  parameter-3-79 as character no-undo .
    define variable  parameter-4-79 as character no-undo .
    define variable  parameter-5-79 as character no-undo .
    define variable  parameter-6-79 as character no-undo .
    define variable  parameter-7-79 as character no-undo .
      assign
      parameter-3-79 =
                              "FOR EACH shar-buf_ord-doc"
      parameter-4-79 =
        (
          if (" shar-buf_ord-doc.host-code = g#host-code " + " " + where-phrase-79) <> ""
          then  substitute(' shar-buf_ord-doc.host-code =  &1 ' , g#host-code )  + " " + where-phrase-79
          else "true"
        )
      parameter-5-79 = (" " + "" + " " + "")
      parameter-6-79 = if sort-phrase-79 = ''
                           then
        (
        " " + " USE-INDEX ByFirm " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX ByFirm " +
          " " + sort-column-phrase +
        " " + sort-phrase-79
        )
      parameter-7-79 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-79 =
          (" shar-buf_ord-doc.host-code = g#host-code " + " " + where-phrase-79 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-79
                          ,input parameter-4-79
                          ,input parameter-5-79
                          ,input parameter-6-79
                          ,input parameter-7-79
                          )
      .
      assign
        l-filter-open-79 = true
      .
    end.
    if l-filter-open-79 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-79 = false then do:
    OPEN QUERY br-docs FOR EACH shar-buf_ord-doc no-lock
      where  shar-buf_ord-doc.host-code = g#host-code
       USE-INDEX ByFirm
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( shar-buf_ord-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer shar-buf_ord-doc:handle) then do:
      assign
      parameter-2-79 = (if p-find-next then "true":u else "false":u )
      parameter-4-79 =
        "where ":u +  substitute(' shar-buf_ord-doc.host-code =  &1 ' , g#host-code )  + " ":u + where-phrase-79 + " ":u + p-find-condition + " " + ""
      parameter-5-79 = " USE-INDEX ByFirm "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(shar-buf_ord-doc)
                          ,input logical(parameter-2-79)
                          ,input no-lock
                          ,input (buffer shar-buf_ord-doc:handle)
                          ,input parameter-4-79
                          ,input parameter-5-79
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-79 = (if p-find-next then "true":u else "false":u )
      parameter-3-79 =  "FOR EACH shar-buf_ord-doc"
      parameter-4-79 =
        (
          if (" shar-buf_ord-doc.host-code = g#host-code " + " " + where-phrase-79) <> ""
          then  substitute(' shar-buf_ord-doc.host-code =  &1 ' , g#host-code )  + " " + where-phrase-79
          else "true"
        )
      parameter-5-79 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-79 = if sort-phrase-79 = ''
                           then
        (
        " " + " USE-INDEX ByFirm " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX ByFirm " +
          " " + sort-column-phrase +
        " " + sort-phrase-79
        )
      parameter-7-79 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-79)
                          ,input no-lock
                          ,input parameter-3-79
                          ,input parameter-4-79
                          ,input parameter-5-79
                          ,input parameter-6-79
                          ,input parameter-7-79
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
  when "firmord":U then do:
      if p-open-query then frame d-all-docs:title = " Фирма : " + g#host-name + " и для объекта " + string( store-code) +  store-type .
      Disable b-add b-chg b-del b-close   b-close b-copy b-sost  WITH FRAME d-all-docs.
      Enable b-lkp
      WITH FRAME d-all-docs.
      if v-cntxt-level <>  'object':U then do:
        Disable b-payment   WITH FRAME d-all-docs.
        disable b-add-2
              b-chg-2
              b-del-2
              b-close-2
              with frame d-all-docs .
      end.
define variable vss-include-info80 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-81  as logical   no-undo .
define variable  l-filter-open-81    as logical   .
define variable  flt-rec-81       as recid     no-undo .
define variable  filter-name-81      as character no-undo .
define variable  where-phrase-81     as character no-undo .
define variable  sort-phrase-81      as character no-undo .
define variable  where-phrase-rus-81 as character no-undo .
define variable  sort-phrase-rus-81  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-81
  ,output filter-name-81
  ,output where-phrase-81
  ,output sort-phrase-81
  ,output where-phrase-rus-81
  ,output sort-phrase-rus-81
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-81
      ) no-error .
  assign
    l-filter-open-81 = false
  .
  if flt-rec-81 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-81 as character no-undo .
    define variable  parameter-3-81 as character no-undo .
    define variable  parameter-4-81 as character no-undo .
    define variable  parameter-5-81 as character no-undo .
    define variable  parameter-6-81 as character no-undo .
    define variable  parameter-7-81 as character no-undo .
      assign
      parameter-3-81 =
                              "FOR EACH shar-buf_ord-doc"
      parameter-4-81 =
        (
          if (" (shar-buf_ord-doc.host-code = g#host-code or ( shar-buf_ord-doc.cli-code = store-code and  shar-buf_ord-doc.cli-type = store-type)) " + " " + where-phrase-81) <> ""
          then  substitute(' (shar-buf_ord-doc.host-code =  &1         or ( shar-buf_ord-doc.cli-code = &2         and  shar-buf_ord-doc.cli-type = &4&3&4 ))' , g#host-code , store-code, store-type, chr(34) )  + " " + where-phrase-81
          else "true"
        )
      parameter-5-81 = (" " + "" + " " + "")
      parameter-6-81 = if sort-phrase-81 = ''
                           then
        (
        " " + "" +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + "" +
          " " + sort-column-phrase +
        " " + sort-phrase-81
        )
      parameter-7-81 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-81 =
          (" (shar-buf_ord-doc.host-code = g#host-code or ( shar-buf_ord-doc.cli-code = store-code and  shar-buf_ord-doc.cli-type = store-type)) " + " " + where-phrase-81 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-81
                          ,input parameter-4-81
                          ,input parameter-5-81
                          ,input parameter-6-81
                          ,input parameter-7-81
                          )
      .
      assign
        l-filter-open-81 = true
      .
    end.
    if l-filter-open-81 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-81 = false then do:
    OPEN QUERY br-docs FOR EACH shar-buf_ord-doc no-lock
      where  (shar-buf_ord-doc.host-code = g#host-code or ( shar-buf_ord-doc.cli-code = store-code and  shar-buf_ord-doc.cli-type = store-type))
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( shar-buf_ord-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer shar-buf_ord-doc:handle) then do:
      assign
      parameter-2-81 = (if p-find-next then "true":u else "false":u )
      parameter-4-81 =
        "where ":u +  substitute(' (shar-buf_ord-doc.host-code =  &1         or ( shar-buf_ord-doc.cli-code = &2         and  shar-buf_ord-doc.cli-type = &4&3&4 ))' , g#host-code , store-code, store-type, chr(34) )  + " ":u + where-phrase-81 + " ":u + p-find-condition + " " + ""
      parameter-5-81 = ""
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(shar-buf_ord-doc)
                          ,input logical(parameter-2-81)
                          ,input no-lock
                          ,input (buffer shar-buf_ord-doc:handle)
                          ,input parameter-4-81
                          ,input parameter-5-81
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-81 = (if p-find-next then "true":u else "false":u )
      parameter-3-81 =  "FOR EACH shar-buf_ord-doc"
      parameter-4-81 =
        (
          if (" (shar-buf_ord-doc.host-code = g#host-code or ( shar-buf_ord-doc.cli-code = store-code and  shar-buf_ord-doc.cli-type = store-type)) " + " " + where-phrase-81) <> ""
          then  substitute(' (shar-buf_ord-doc.host-code =  &1         or ( shar-buf_ord-doc.cli-code = &2         and  shar-buf_ord-doc.cli-type = &4&3&4 ))' , g#host-code , store-code, store-type, chr(34) )  + " " + where-phrase-81
          else "true"
        )
      parameter-5-81 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-81 = if sort-phrase-81 = ''
                           then
        (
        " " + "" +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + "" +
          " " + sort-column-phrase +
        " " + sort-phrase-81
        )
      parameter-7-81 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-81)
                          ,input no-lock
                          ,input parameter-3-81
                          ,input parameter-4-81
                          ,input parameter-5-81
                          ,input parameter-6-81
                          ,input parameter-7-81
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
  when "firmtype":U then do:
      if p-open-query then frame d-all-docs:title = "Фирма : " + g#host-name  + "  Тип : " + ( if g#type = 'ОП':U THEN 'Объект-Поставщик':U ELSE   (if g#type = 'ОФ':U THEN 'Объект-Фирма':U else       (if g#type = 'ФП':U THEN 'Фирма-Поставщик':U else ? ))).
      Enable
             b-sost WITH FRAME d-all-docs.
      if g#type = 'ОФ':U or g#type = 'ОП':U then do:   b-sost:tooltip in FRAME d-all-docs = "Проставить статус 'Отказать' по заказу 'ОФ'".   end. else disable b-sost with FRAME d-all-docs.
define variable vss-include-info82 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-83  as logical   no-undo .
define variable  l-filter-open-83    as logical   .
define variable  flt-rec-83       as recid     no-undo .
define variable  filter-name-83      as character no-undo .
define variable  where-phrase-83     as character no-undo .
define variable  sort-phrase-83      as character no-undo .
define variable  where-phrase-rus-83 as character no-undo .
define variable  sort-phrase-rus-83  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-83
  ,output filter-name-83
  ,output where-phrase-83
  ,output sort-phrase-83
  ,output where-phrase-rus-83
  ,output sort-phrase-rus-83
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-83
      ) no-error .
  assign
    l-filter-open-83 = false
  .
  if flt-rec-83 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-83 as character no-undo .
    define variable  parameter-3-83 as character no-undo .
    define variable  parameter-4-83 as character no-undo .
    define variable  parameter-5-83 as character no-undo .
    define variable  parameter-6-83 as character no-undo .
    define variable  parameter-7-83 as character no-undo .
      assign
      parameter-3-83 =
                              "FOR EACH shar-buf_ord-doc"
      parameter-4-83 =
        (
          if (" shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.doc-type = g#type" + " " + where-phrase-83) <> ""
          then  substitute(' shar-buf_ord-doc.host-code =  &1 and shar-buf_ord-doc.doc-type = &3&2&3 ' , g#host-code , g#type , chr(34) )  + " " + where-phrase-83
          else "true"
        )
      parameter-5-83 = (" " + "" + " " + "")
      parameter-6-83 = if sort-phrase-83 = ''
                           then
        (
        " " + " USE-INDEX ByType " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX ByType " +
          " " + sort-column-phrase +
        " " + sort-phrase-83
        )
      parameter-7-83 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-83 =
          (" shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.doc-type = g#type" + " " + where-phrase-83 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-83
                          ,input parameter-4-83
                          ,input parameter-5-83
                          ,input parameter-6-83
                          ,input parameter-7-83
                          )
      .
      assign
        l-filter-open-83 = true
      .
    end.
    if l-filter-open-83 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-83 = false then do:
    OPEN QUERY br-docs FOR EACH shar-buf_ord-doc no-lock
      where  shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.doc-type = g#type
       USE-INDEX ByType
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( shar-buf_ord-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer shar-buf_ord-doc:handle) then do:
      assign
      parameter-2-83 = (if p-find-next then "true":u else "false":u )
      parameter-4-83 =
        "where ":u +  substitute(' shar-buf_ord-doc.host-code =  &1 and shar-buf_ord-doc.doc-type = &3&2&3 ' , g#host-code , g#type , chr(34) )  + " ":u + where-phrase-83 + " ":u + p-find-condition + " " + ""
      parameter-5-83 = " USE-INDEX ByType "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(shar-buf_ord-doc)
                          ,input logical(parameter-2-83)
                          ,input no-lock
                          ,input (buffer shar-buf_ord-doc:handle)
                          ,input parameter-4-83
                          ,input parameter-5-83
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-83 = (if p-find-next then "true":u else "false":u )
      parameter-3-83 =  "FOR EACH shar-buf_ord-doc"
      parameter-4-83 =
        (
          if (" shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.doc-type = g#type" + " " + where-phrase-83) <> ""
          then  substitute(' shar-buf_ord-doc.host-code =  &1 and shar-buf_ord-doc.doc-type = &3&2&3 ' , g#host-code , g#type , chr(34) )  + " " + where-phrase-83
          else "true"
        )
      parameter-5-83 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-83 = if sort-phrase-83 = ''
                           then
        (
        " " + " USE-INDEX ByType " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX ByType " +
          " " + sort-column-phrase +
        " " + sort-phrase-83
        )
      parameter-7-83 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-83)
                          ,input no-lock
                          ,input parameter-3-83
                          ,input parameter-4-83
                          ,input parameter-5-83
                          ,input parameter-6-83
                          ,input parameter-7-83
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
  when "firmtypestatus" then do:
      if p-open-query then frame d-all-docs:title = "Фирма : " + g#host-name
                              + "  Тип : " + ( if g#type = 'ОП':U THEN 'Объект-Поставщик':U ELSE   (if g#type = 'ОФ':U THEN 'Объект-Фирма':U else       (if g#type = 'ФП':U THEN 'Фирма-Поставщик':U else ? )))
                              + "  Статус : " + g#stat.
      Enable b-sost
             WITH FRAME d-all-docs.
      if g#type = 'ОФ':U or g#type = 'ОП':U then do:   b-sost:tooltip in FRAME d-all-docs = "Проставить статус 'Отказать' по заказу 'ОФ'".   end. else disable b-sost with FRAME d-all-docs.
define variable vss-include-info84 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-85  as logical   no-undo .
define variable  l-filter-open-85    as logical   .
define variable  flt-rec-85       as recid     no-undo .
define variable  filter-name-85      as character no-undo .
define variable  where-phrase-85     as character no-undo .
define variable  sort-phrase-85      as character no-undo .
define variable  where-phrase-rus-85 as character no-undo .
define variable  sort-phrase-rus-85  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-85
  ,output filter-name-85
  ,output where-phrase-85
  ,output sort-phrase-85
  ,output where-phrase-rus-85
  ,output sort-phrase-rus-85
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-85
      ) no-error .
  assign
    l-filter-open-85 = false
  .
  if flt-rec-85 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-85 as character no-undo .
    define variable  parameter-3-85 as character no-undo .
    define variable  parameter-4-85 as character no-undo .
    define variable  parameter-5-85 as character no-undo .
    define variable  parameter-6-85 as character no-undo .
    define variable  parameter-7-85 as character no-undo .
      assign
      parameter-3-85 =
                              "FOR EACH shar-buf_ord-doc"
      parameter-4-85 =
        (
          if (" shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.doc-type = g#type and shar-buf_ord-doc.status_ = g#stat" + " " + where-phrase-85) <> ""
          then  substitute(' shar-buf_ord-doc.host-code =  &1 and shar-buf_ord-doc.doc-type = &3&2&3  and shar-buf_ord-doc.status_ = &3&4&3 ' , g#host-code , g#type , chr(34) , g#stat)  + " " + where-phrase-85
          else "true"
        )
      parameter-5-85 = (" " + "" + " " + "")
      parameter-6-85 = if sort-phrase-85 = ''
                           then
        (
        " " + " USE-INDEX ByType " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX ByType " +
          " " + sort-column-phrase +
        " " + sort-phrase-85
        )
      parameter-7-85 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-85 =
          (" shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.doc-type = g#type and shar-buf_ord-doc.status_ = g#stat" + " " + where-phrase-85 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-85
                          ,input parameter-4-85
                          ,input parameter-5-85
                          ,input parameter-6-85
                          ,input parameter-7-85
                          )
      .
      assign
        l-filter-open-85 = true
      .
    end.
    if l-filter-open-85 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-85 = false then do:
    OPEN QUERY br-docs FOR EACH shar-buf_ord-doc no-lock
      where  shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.doc-type = g#type and shar-buf_ord-doc.status_ = g#stat
       USE-INDEX ByType
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( shar-buf_ord-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer shar-buf_ord-doc:handle) then do:
      assign
      parameter-2-85 = (if p-find-next then "true":u else "false":u )
      parameter-4-85 =
        "where ":u +  substitute(' shar-buf_ord-doc.host-code =  &1 and shar-buf_ord-doc.doc-type = &3&2&3  and shar-buf_ord-doc.status_ = &3&4&3 ' , g#host-code , g#type , chr(34) , g#stat)  + " ":u + where-phrase-85 + " ":u + p-find-condition + " " + ""
      parameter-5-85 = " USE-INDEX ByType "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(shar-buf_ord-doc)
                          ,input logical(parameter-2-85)
                          ,input no-lock
                          ,input (buffer shar-buf_ord-doc:handle)
                          ,input parameter-4-85
                          ,input parameter-5-85
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-85 = (if p-find-next then "true":u else "false":u )
      parameter-3-85 =  "FOR EACH shar-buf_ord-doc"
      parameter-4-85 =
        (
          if (" shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.doc-type = g#type and shar-buf_ord-doc.status_ = g#stat" + " " + where-phrase-85) <> ""
          then  substitute(' shar-buf_ord-doc.host-code =  &1 and shar-buf_ord-doc.doc-type = &3&2&3  and shar-buf_ord-doc.status_ = &3&4&3 ' , g#host-code , g#type , chr(34) , g#stat)  + " " + where-phrase-85
          else "true"
        )
      parameter-5-85 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-85 = if sort-phrase-85 = ''
                           then
        (
        " " + " USE-INDEX ByType " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX ByType " +
          " " + sort-column-phrase +
        " " + sort-phrase-85
        )
      parameter-7-85 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-85)
                          ,input no-lock
                          ,input parameter-3-85
                          ,input parameter-4-85
                          ,input parameter-5-85
                          ,input parameter-6-85
                          ,input parameter-7-85
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
  when "firm-fintypestatus" then do:
      if p-open-query then frame d-all-docs:title = "Фирма : " + g#host-name
                              + "  Статус : " + g#stat.
      v-spis-status = 'факт':U + ","  + 'поставка':U .
      Enable b-mark b-sost    WITH FRAME d-all-docs.
      disable b-add b-chg b-del b-close   b-close b-copy b-payment  WITH FRAME d-all-docs.
        disable b-add-2
                b-chg-2
                b-del-2
                b-close-2
             with frame d-all-docs .
      if g#type = 'ОФ':U or g#type = 'ОП':U then do:   b-sost:tooltip in FRAME d-all-docs = "Проставить статус 'Отказать' по заказу 'ОФ'".   end. else disable b-sost with FRAME d-all-docs.
define variable vss-include-info86 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-87  as logical   no-undo .
define variable  l-filter-open-87    as logical   .
define variable  flt-rec-87       as recid     no-undo .
define variable  filter-name-87      as character no-undo .
define variable  where-phrase-87     as character no-undo .
define variable  sort-phrase-87      as character no-undo .
define variable  where-phrase-rus-87 as character no-undo .
define variable  sort-phrase-rus-87  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-87
  ,output filter-name-87
  ,output where-phrase-87
  ,output sort-phrase-87
  ,output where-phrase-rus-87
  ,output sort-phrase-rus-87
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-87
      ) no-error .
  assign
    l-filter-open-87 = false
  .
  if flt-rec-87 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-87 as character no-undo .
    define variable  parameter-3-87 as character no-undo .
    define variable  parameter-4-87 as character no-undo .
    define variable  parameter-5-87 as character no-undo .
    define variable  parameter-6-87 as character no-undo .
    define variable  parameter-7-87 as character no-undo .
      assign
      parameter-3-87 =
                              "FOR EACH shar-buf_ord-doc"
      parameter-4-87 =
        (
          if (" ((shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.status_ = g#stat and  shar-buf_ord-doc.doc-type = 'ФП':U) or
       (shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.status_ = g#stat and  shar-buf_ord-doc.doc-type = 'ОП':U) or
       (shar-buf_ord-doc.host-code = g#host-code and lookup (shar-buf_ord-doc.status_,v-spis-status) > 0 and  shar-buf_ord-doc.doc-type = 'ПО':U)) " + " " + where-phrase-87) <> ""
          then  substitute('        ((shar-buf_ord-doc.host-code = &2  and shar-buf_ord-doc.status_ = &1&3&1 and  shar-buf_ord-doc.doc-type = &1&4&1) or        (shar-buf_ord-doc.host-code = &2 and shar-buf_ord-doc.status_ = &1&3&1 and  shar-buf_ord-doc.doc-type = &1&5&1) or           (shar-buf_ord-doc.host-code = &2 and lookup (shar-buf_ord-doc.status_,&1&6&1) > 0 and  shar-buf_ord-doc.doc-type = &1&7&1))        ' , chr(34)         , g#host-code        , g#stat            , 'ФП':U          , 'ОП':U          , v-spis-status        , 'ПО':U         )  + " " + where-phrase-87
          else "true"
        )
      parameter-5-87 = (" " + "" + " " + "")
      parameter-6-87 = if sort-phrase-87 = ''
                           then
        (
        " " + " USE-INDEX bytype " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX bytype " +
          " " + sort-column-phrase +
        " " + sort-phrase-87
        )
      parameter-7-87 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-87 =
          (" ((shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.status_ = g#stat and  shar-buf_ord-doc.doc-type = 'ФП':U) or
       (shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.status_ = g#stat and  shar-buf_ord-doc.doc-type = 'ОП':U) or
       (shar-buf_ord-doc.host-code = g#host-code and lookup (shar-buf_ord-doc.status_,v-spis-status) > 0 and  shar-buf_ord-doc.doc-type = 'ПО':U)) " + " " + where-phrase-87 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-87
                          ,input parameter-4-87
                          ,input parameter-5-87
                          ,input parameter-6-87
                          ,input parameter-7-87
                          )
      .
      assign
        l-filter-open-87 = true
      .
    end.
    if l-filter-open-87 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-87 = false then do:
    OPEN QUERY br-docs FOR EACH shar-buf_ord-doc no-lock
      where  ((shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.status_ = g#stat and  shar-buf_ord-doc.doc-type = 'ФП':U) or
       (shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.status_ = g#stat and  shar-buf_ord-doc.doc-type = 'ОП':U) or
       (shar-buf_ord-doc.host-code = g#host-code and lookup (shar-buf_ord-doc.status_,v-spis-status) > 0 and  shar-buf_ord-doc.doc-type = 'ПО':U))
       USE-INDEX bytype
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( shar-buf_ord-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer shar-buf_ord-doc:handle) then do:
      assign
      parameter-2-87 = (if p-find-next then "true":u else "false":u )
      parameter-4-87 =
        "where ":u +  substitute('        ((shar-buf_ord-doc.host-code = &2  and shar-buf_ord-doc.status_ = &1&3&1 and  shar-buf_ord-doc.doc-type = &1&4&1) or        (shar-buf_ord-doc.host-code = &2 and shar-buf_ord-doc.status_ = &1&3&1 and  shar-buf_ord-doc.doc-type = &1&5&1) or           (shar-buf_ord-doc.host-code = &2 and lookup (shar-buf_ord-doc.status_,&1&6&1) > 0 and  shar-buf_ord-doc.doc-type = &1&7&1))        ' , chr(34)         , g#host-code        , g#stat            , 'ФП':U          , 'ОП':U          , v-spis-status        , 'ПО':U         )  + " ":u + where-phrase-87 + " ":u + p-find-condition + " " + ""
      parameter-5-87 = " USE-INDEX bytype "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(shar-buf_ord-doc)
                          ,input logical(parameter-2-87)
                          ,input no-lock
                          ,input (buffer shar-buf_ord-doc:handle)
                          ,input parameter-4-87
                          ,input parameter-5-87
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-87 = (if p-find-next then "true":u else "false":u )
      parameter-3-87 =  "FOR EACH shar-buf_ord-doc"
      parameter-4-87 =
        (
          if (" ((shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.status_ = g#stat and  shar-buf_ord-doc.doc-type = 'ФП':U) or
       (shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.status_ = g#stat and  shar-buf_ord-doc.doc-type = 'ОП':U) or
       (shar-buf_ord-doc.host-code = g#host-code and lookup (shar-buf_ord-doc.status_,v-spis-status) > 0 and  shar-buf_ord-doc.doc-type = 'ПО':U)) " + " " + where-phrase-87) <> ""
          then  substitute('        ((shar-buf_ord-doc.host-code = &2  and shar-buf_ord-doc.status_ = &1&3&1 and  shar-buf_ord-doc.doc-type = &1&4&1) or        (shar-buf_ord-doc.host-code = &2 and shar-buf_ord-doc.status_ = &1&3&1 and  shar-buf_ord-doc.doc-type = &1&5&1) or           (shar-buf_ord-doc.host-code = &2 and lookup (shar-buf_ord-doc.status_,&1&6&1) > 0 and  shar-buf_ord-doc.doc-type = &1&7&1))        ' , chr(34)         , g#host-code        , g#stat            , 'ФП':U          , 'ОП':U          , v-spis-status        , 'ПО':U         )  + " " + where-phrase-87
          else "true"
        )
      parameter-5-87 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-87 = if sort-phrase-87 = ''
                           then
        (
        " " + " USE-INDEX bytype " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX bytype " +
          " " + sort-column-phrase +
        " " + sort-phrase-87
        )
      parameter-7-87 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-87)
                          ,input no-lock
                          ,input parameter-3-87
                          ,input parameter-4-87
                          ,input parameter-5-87
                          ,input parameter-6-87
                          ,input parameter-7-87
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
  when "without-fotypestatus" then do:
      if p-open-query then frame d-all-docs:title = "НЕТ финансовых обязательств    Фирма : " + g#host-name .
      Enable b-mark b-sost     WITH FRAME d-all-docs.
      disable b-add b-chg b-del b-close   b-close b-copy b-payment   WITH FRAME d-all-docs.
        disable b-add-2
              b-chg-2
              b-del-2
              b-close-2
             with frame d-all-docs .
      if g#type = 'ОФ':U or g#type = 'ОП':U then do:   b-sost:tooltip in FRAME d-all-docs = "Проставить статус 'Отказать' по заказу 'ОФ'".   end. else disable b-sost with FRAME d-all-docs.
define variable vss-include-info88 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-89  as logical   no-undo .
define variable  l-filter-open-89    as logical   .
define variable  flt-rec-89       as recid     no-undo .
define variable  filter-name-89      as character no-undo .
define variable  where-phrase-89     as character no-undo .
define variable  sort-phrase-89      as character no-undo .
define variable  where-phrase-rus-89 as character no-undo .
define variable  sort-phrase-rus-89  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-89
  ,output filter-name-89
  ,output where-phrase-89
  ,output sort-phrase-89
  ,output where-phrase-rus-89
  ,output sort-phrase-rus-89
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-89
      ) no-error .
  assign
    l-filter-open-89 = false
  .
  if flt-rec-89 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-89 as character no-undo .
    define variable  parameter-3-89 as character no-undo .
    define variable  parameter-4-89 as character no-undo .
    define variable  parameter-5-89 as character no-undo .
    define variable  parameter-6-89 as character no-undo .
    define variable  parameter-7-89 as character no-undo .
      assign
      parameter-3-89 =
                              "FOR EACH shar-buf_ord-doc"
      parameter-4-89 =
        (
          if (" ( shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.need-fo = 1  and  shar-buf_ord-doc.cr-fo = no ) " + " " + where-phrase-89) <> ""
          then  substitute(' shar-buf_ord-doc.host-code =  &1 and and shar-buf_ord-doc.need-fo = 1  and  shar-buf_ord-doc.cr-fo = no ' , g#host-code )  + " " + where-phrase-89
          else "true"
        )
      parameter-5-89 = (" " + "" + " " + "")
      parameter-6-89 = if sort-phrase-89 = ''
                           then
        (
        " " + " USE-INDEX By_need-fo " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX By_need-fo " +
          " " + sort-column-phrase +
        " " + sort-phrase-89
        )
      parameter-7-89 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-89 =
          (" ( shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.need-fo = 1  and  shar-buf_ord-doc.cr-fo = no ) " + " " + where-phrase-89 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-89
                          ,input parameter-4-89
                          ,input parameter-5-89
                          ,input parameter-6-89
                          ,input parameter-7-89
                          )
      .
      assign
        l-filter-open-89 = true
      .
    end.
    if l-filter-open-89 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-89 = false then do:
    OPEN QUERY br-docs FOR EACH shar-buf_ord-doc no-lock
      where  ( shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.need-fo = 1  and  shar-buf_ord-doc.cr-fo = no )
       USE-INDEX By_need-fo
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( shar-buf_ord-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer shar-buf_ord-doc:handle) then do:
      assign
      parameter-2-89 = (if p-find-next then "true":u else "false":u )
      parameter-4-89 =
        "where ":u +  substitute(' shar-buf_ord-doc.host-code =  &1 and and shar-buf_ord-doc.need-fo = 1  and  shar-buf_ord-doc.cr-fo = no ' , g#host-code )  + " ":u + where-phrase-89 + " ":u + p-find-condition + " " + ""
      parameter-5-89 = " USE-INDEX By_need-fo "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(shar-buf_ord-doc)
                          ,input logical(parameter-2-89)
                          ,input no-lock
                          ,input (buffer shar-buf_ord-doc:handle)
                          ,input parameter-4-89
                          ,input parameter-5-89
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-89 = (if p-find-next then "true":u else "false":u )
      parameter-3-89 =  "FOR EACH shar-buf_ord-doc"
      parameter-4-89 =
        (
          if (" ( shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.need-fo = 1  and  shar-buf_ord-doc.cr-fo = no ) " + " " + where-phrase-89) <> ""
          then  substitute(' shar-buf_ord-doc.host-code =  &1 and and shar-buf_ord-doc.need-fo = 1  and  shar-buf_ord-doc.cr-fo = no ' , g#host-code )  + " " + where-phrase-89
          else "true"
        )
      parameter-5-89 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-89 = if sort-phrase-89 = ''
                           then
        (
        " " + " USE-INDEX By_need-fo " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX By_need-fo " +
          " " + sort-column-phrase +
        " " + sort-phrase-89
        )
      parameter-7-89 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-89)
                          ,input no-lock
                          ,input parameter-3-89
                          ,input parameter-4-89
                          ,input parameter-5-89
                          ,input parameter-6-89
                          ,input parameter-7-89
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
  when "with-fotypestatus" then do:
      if p-open-query then frame d-all-docs:title = "ЕСТЬ финансовые обязательства    Фирма : " + g#host-name .
      Enable b-mark  b-sost      WITH FRAME d-all-docs.
      disable b-add b-chg b-del b-close   b-close b-copy b-payment   WITH FRAME d-all-docs.
        disable b-add-2
              b-chg-2
              b-del-2
              b-close-2
             with frame d-all-docs .
      if g#type = 'ОФ':U or g#type = 'ОП':U then do:   b-sost:tooltip in FRAME d-all-docs = "Проставить статус 'Отказать' по заказу 'ОФ'".   end. else disable b-sost with FRAME d-all-docs.
define variable vss-include-info90 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-91  as logical   no-undo .
define variable  l-filter-open-91    as logical   .
define variable  flt-rec-91       as recid     no-undo .
define variable  filter-name-91      as character no-undo .
define variable  where-phrase-91     as character no-undo .
define variable  sort-phrase-91      as character no-undo .
define variable  where-phrase-rus-91 as character no-undo .
define variable  sort-phrase-rus-91  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-91
  ,output filter-name-91
  ,output where-phrase-91
  ,output sort-phrase-91
  ,output where-phrase-rus-91
  ,output sort-phrase-rus-91
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-91
      ) no-error .
  assign
    l-filter-open-91 = false
  .
  if flt-rec-91 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-91 as character no-undo .
    define variable  parameter-3-91 as character no-undo .
    define variable  parameter-4-91 as character no-undo .
    define variable  parameter-5-91 as character no-undo .
    define variable  parameter-6-91 as character no-undo .
    define variable  parameter-7-91 as character no-undo .
      assign
      parameter-3-91 =
                              "FOR EACH shar-buf_ord-doc"
      parameter-4-91 =
        (
          if (" shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.need-fo = 1  and  shar-buf_ord-doc.cr-fo = yes " + " " + where-phrase-91) <> ""
          then  substitute(' shar-buf_ord-doc.host-code =  &1 and shar-buf_ord-doc.need-fo = 1  and  shar-buf_ord-doc.cr-fo = yes  ' , g#host-code )  + " " + where-phrase-91
          else "true"
        )
      parameter-5-91 = (" " + "" + " " + "")
      parameter-6-91 = if sort-phrase-91 = ''
                           then
        (
        " " + " USE-INDEX By_need-fo " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX By_need-fo " +
          " " + sort-column-phrase +
        " " + sort-phrase-91
        )
      parameter-7-91 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-91 =
          (" shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.need-fo = 1  and  shar-buf_ord-doc.cr-fo = yes " + " " + where-phrase-91 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-91
                          ,input parameter-4-91
                          ,input parameter-5-91
                          ,input parameter-6-91
                          ,input parameter-7-91
                          )
      .
      assign
        l-filter-open-91 = true
      .
    end.
    if l-filter-open-91 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-91 = false then do:
    OPEN QUERY br-docs FOR EACH shar-buf_ord-doc no-lock
      where  shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.need-fo = 1  and  shar-buf_ord-doc.cr-fo = yes
       USE-INDEX By_need-fo
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( shar-buf_ord-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer shar-buf_ord-doc:handle) then do:
      assign
      parameter-2-91 = (if p-find-next then "true":u else "false":u )
      parameter-4-91 =
        "where ":u +  substitute(' shar-buf_ord-doc.host-code =  &1 and shar-buf_ord-doc.need-fo = 1  and  shar-buf_ord-doc.cr-fo = yes  ' , g#host-code )  + " ":u + where-phrase-91 + " ":u + p-find-condition + " " + ""
      parameter-5-91 = " USE-INDEX By_need-fo "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(shar-buf_ord-doc)
                          ,input logical(parameter-2-91)
                          ,input no-lock
                          ,input (buffer shar-buf_ord-doc:handle)
                          ,input parameter-4-91
                          ,input parameter-5-91
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-91 = (if p-find-next then "true":u else "false":u )
      parameter-3-91 =  "FOR EACH shar-buf_ord-doc"
      parameter-4-91 =
        (
          if (" shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.need-fo = 1  and  shar-buf_ord-doc.cr-fo = yes " + " " + where-phrase-91) <> ""
          then  substitute(' shar-buf_ord-doc.host-code =  &1 and shar-buf_ord-doc.need-fo = 1  and  shar-buf_ord-doc.cr-fo = yes  ' , g#host-code )  + " " + where-phrase-91
          else "true"
        )
      parameter-5-91 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-91 = if sort-phrase-91 = ''
                           then
        (
        " " + " USE-INDEX By_need-fo " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX By_need-fo " +
          " " + sort-column-phrase +
        " " + sort-phrase-91
        )
      parameter-7-91 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-91)
                          ,input no-lock
                          ,input parameter-3-91
                          ,input parameter-4-91
                          ,input parameter-5-91
                          ,input parameter-6-91
                          ,input parameter-7-91
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
  when 'Контрагент':U OR
  when 'Контрагент':U + "typestatus":U then do:
      if p-open-query then frame d-all-docs:title = "Контрагент : " + sch-cli.obj-name.
      Enable b-sost
      WITH FRAME d-all-docs.
define variable vss-include-info92 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-93  as logical   no-undo .
define variable  l-filter-open-93    as logical   .
define variable  flt-rec-93       as recid     no-undo .
define variable  filter-name-93      as character no-undo .
define variable  where-phrase-93     as character no-undo .
define variable  sort-phrase-93      as character no-undo .
define variable  where-phrase-rus-93 as character no-undo .
define variable  sort-phrase-rus-93  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-93
  ,output filter-name-93
  ,output where-phrase-93
  ,output sort-phrase-93
  ,output where-phrase-rus-93
  ,output sort-phrase-rus-93
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-93
      ) no-error .
  assign
    l-filter-open-93 = false
  .
  if flt-rec-93 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-93 as character no-undo .
    define variable  parameter-3-93 as character no-undo .
    define variable  parameter-4-93 as character no-undo .
    define variable  parameter-5-93 as character no-undo .
    define variable  parameter-6-93 as character no-undo .
    define variable  parameter-7-93 as character no-undo .
      assign
      parameter-3-93 =
                              "FOR EACH shar-buf_ord-doc"
      parameter-4-93 =
        (
          if (" shar-buf_ord-doc.cli-type  = sch-cli.obj-type and shar-buf_ord-doc.cli-code  = sch-cli.obj-code and shar-buf_ord-doc.host-code = g#host-code " + " " + where-phrase-93) <> ""
          then  substitute(' shar-buf_ord-doc.host-code =  &2 and                             shar-buf_ord-doc.cli-type  = &1&3&1 and                             shar-buf_ord-doc.cli-code  =  &4' , chr(34) , g#host-code , sch-cli.obj-type , sch-cli.obj-code )  + " " + where-phrase-93
          else "true"
        )
      parameter-5-93 = (" " + "" + " " + "")
      parameter-6-93 = if sort-phrase-93 = ''
                           then
        (
        " " + " USE-INDEX Bycli " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX Bycli " +
          " " + sort-column-phrase +
        " " + sort-phrase-93
        )
      parameter-7-93 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-93 =
          (" shar-buf_ord-doc.cli-type  = sch-cli.obj-type and shar-buf_ord-doc.cli-code  = sch-cli.obj-code and shar-buf_ord-doc.host-code = g#host-code " + " " + where-phrase-93 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-93
                          ,input parameter-4-93
                          ,input parameter-5-93
                          ,input parameter-6-93
                          ,input parameter-7-93
                          )
      .
      assign
        l-filter-open-93 = true
      .
    end.
    if l-filter-open-93 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-93 = false then do:
    OPEN QUERY br-docs FOR EACH shar-buf_ord-doc no-lock
      where  shar-buf_ord-doc.cli-type  = sch-cli.obj-type and shar-buf_ord-doc.cli-code  = sch-cli.obj-code and shar-buf_ord-doc.host-code = g#host-code
       USE-INDEX Bycli
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( shar-buf_ord-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer shar-buf_ord-doc:handle) then do:
      assign
      parameter-2-93 = (if p-find-next then "true":u else "false":u )
      parameter-4-93 =
        "where ":u +  substitute(' shar-buf_ord-doc.host-code =  &2 and                             shar-buf_ord-doc.cli-type  = &1&3&1 and                             shar-buf_ord-doc.cli-code  =  &4' , chr(34) , g#host-code , sch-cli.obj-type , sch-cli.obj-code )  + " ":u + where-phrase-93 + " ":u + p-find-condition + " " + ""
      parameter-5-93 = " USE-INDEX Bycli "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(shar-buf_ord-doc)
                          ,input logical(parameter-2-93)
                          ,input no-lock
                          ,input (buffer shar-buf_ord-doc:handle)
                          ,input parameter-4-93
                          ,input parameter-5-93
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-93 = (if p-find-next then "true":u else "false":u )
      parameter-3-93 =  "FOR EACH shar-buf_ord-doc"
      parameter-4-93 =
        (
          if (" shar-buf_ord-doc.cli-type  = sch-cli.obj-type and shar-buf_ord-doc.cli-code  = sch-cli.obj-code and shar-buf_ord-doc.host-code = g#host-code " + " " + where-phrase-93) <> ""
          then  substitute(' shar-buf_ord-doc.host-code =  &2 and                             shar-buf_ord-doc.cli-type  = &1&3&1 and                             shar-buf_ord-doc.cli-code  =  &4' , chr(34) , g#host-code , sch-cli.obj-type , sch-cli.obj-code )  + " " + where-phrase-93
          else "true"
        )
      parameter-5-93 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-93 = if sort-phrase-93 = ''
                           then
        (
        " " + " USE-INDEX Bycli " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX Bycli " +
          " " + sort-column-phrase +
        " " + sort-phrase-93
        )
      parameter-7-93 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-93)
                          ,input no-lock
                          ,input parameter-3-93
                          ,input parameter-4-93
                          ,input parameter-5-93
                          ,input parameter-6-93
                          ,input parameter-7-93
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
  when "obj":U then do:
      if p-open-query then frame d-all-docs:title = "Объект : " + store-type + " " + string(store-code)   .
      Disable b-add WITH FRAME d-all-docs.
      Enable  b-sost WITH FRAME d-all-docs.
define variable vss-include-info94 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-95  as logical   no-undo .
define variable  l-filter-open-95    as logical   .
define variable  flt-rec-95       as recid     no-undo .
define variable  filter-name-95      as character no-undo .
define variable  where-phrase-95     as character no-undo .
define variable  sort-phrase-95      as character no-undo .
define variable  where-phrase-rus-95 as character no-undo .
define variable  sort-phrase-rus-95  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-95
  ,output filter-name-95
  ,output where-phrase-95
  ,output sort-phrase-95
  ,output where-phrase-rus-95
  ,output sort-phrase-rus-95
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-95
      ) no-error .
  assign
    l-filter-open-95 = false
  .
  if flt-rec-95 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-95 as character no-undo .
    define variable  parameter-3-95 as character no-undo .
    define variable  parameter-4-95 as character no-undo .
    define variable  parameter-5-95 as character no-undo .
    define variable  parameter-6-95 as character no-undo .
    define variable  parameter-7-95 as character no-undo .
      assign
      parameter-3-95 =
                              "FOR EACH shar-buf_ord-doc"
      parameter-4-95 =
        (
          if (" shar-buf_ord-doc.obj-code = store-code and shar-buf_ord-doc.obj-type = store-type" + " " + where-phrase-95) <> ""
          then  substitute(' shar-buf_ord-doc.obj-code = &2 and                             shar-buf_ord-doc.obj-type  = &1&3&1                             ' , chr(34) , store-code , store-type )  + " " + where-phrase-95
          else "true"
        )
      parameter-5-95 = (" " + "" + " " + "")
      parameter-6-95 = if sort-phrase-95 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-95
        )
      parameter-7-95 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-95 =
          (" shar-buf_ord-doc.obj-code = store-code and shar-buf_ord-doc.obj-type = store-type" + " " + where-phrase-95 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-95
                          ,input parameter-4-95
                          ,input parameter-5-95
                          ,input parameter-6-95
                          ,input parameter-7-95
                          )
      .
      assign
        l-filter-open-95 = true
      .
    end.
    if l-filter-open-95 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-95 = false then do:
    OPEN QUERY br-docs FOR EACH shar-buf_ord-doc no-lock
      where  shar-buf_ord-doc.obj-code = store-code and shar-buf_ord-doc.obj-type = store-type
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( shar-buf_ord-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer shar-buf_ord-doc:handle) then do:
      assign
      parameter-2-95 = (if p-find-next then "true":u else "false":u )
      parameter-4-95 =
        "where ":u +  substitute(' shar-buf_ord-doc.obj-code = &2 and                             shar-buf_ord-doc.obj-type  = &1&3&1                             ' , chr(34) , store-code , store-type )  + " ":u + where-phrase-95 + " ":u + p-find-condition + " " + ""
      parameter-5-95 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(shar-buf_ord-doc)
                          ,input logical(parameter-2-95)
                          ,input no-lock
                          ,input (buffer shar-buf_ord-doc:handle)
                          ,input parameter-4-95
                          ,input parameter-5-95
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-95 = (if p-find-next then "true":u else "false":u )
      parameter-3-95 =  "FOR EACH shar-buf_ord-doc"
      parameter-4-95 =
        (
          if (" shar-buf_ord-doc.obj-code = store-code and shar-buf_ord-doc.obj-type = store-type" + " " + where-phrase-95) <> ""
          then  substitute(' shar-buf_ord-doc.obj-code = &2 and                             shar-buf_ord-doc.obj-type  = &1&3&1                             ' , chr(34) , store-code , store-type )  + " " + where-phrase-95
          else "true"
        )
      parameter-5-95 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-95 = if sort-phrase-95 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-95
        )
      parameter-7-95 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-95)
                          ,input no-lock
                          ,input parameter-3-95
                          ,input parameter-4-95
                          ,input parameter-5-95
                          ,input parameter-6-95
                          ,input parameter-7-95
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
  when "objtype":U then do:
      if p-open-query then frame d-all-docs:title = "Объект : " + store-type + " " + string(store-code)  +
             "  Тип : " + ( if g#type = 'ОП':U THEN 'Объект-Поставщик':U ELSE   (if g#type = 'ОФ':U THEN 'Объект-Фирма':U else       (if g#type = 'ФП':U THEN 'Фирма-Поставщик':U else ? ))).
      Enable b-sost
             WITH FRAME d-all-docs.
define variable vss-include-info96 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-97  as logical   no-undo .
define variable  l-filter-open-97    as logical   .
define variable  flt-rec-97       as recid     no-undo .
define variable  filter-name-97      as character no-undo .
define variable  where-phrase-97     as character no-undo .
define variable  sort-phrase-97      as character no-undo .
define variable  where-phrase-rus-97 as character no-undo .
define variable  sort-phrase-rus-97  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-97
  ,output filter-name-97
  ,output where-phrase-97
  ,output sort-phrase-97
  ,output where-phrase-rus-97
  ,output sort-phrase-rus-97
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-97
      ) no-error .
  assign
    l-filter-open-97 = false
  .
  if flt-rec-97 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-97 as character no-undo .
    define variable  parameter-3-97 as character no-undo .
    define variable  parameter-4-97 as character no-undo .
    define variable  parameter-5-97 as character no-undo .
    define variable  parameter-6-97 as character no-undo .
    define variable  parameter-7-97 as character no-undo .
      assign
      parameter-3-97 =
                              "FOR EACH shar-buf_ord-doc"
      parameter-4-97 =
        (
          if (" shar-buf_ord-doc.obj-code = store-code and shar-buf_ord-doc.obj-type = store-type and shar-buf_ord-doc.doc-type = g#type " + " " + where-phrase-97) <> ""
          then  substitute('                             shar-buf_ord-doc.obj-code =  &3 and                             shar-buf_ord-doc.obj-type = &1&2&1 and                             shar-buf_ord-doc.doc-type = &1&4&1                             ' , chr(34) , store-type , store-code , g#type )  + " " + where-phrase-97
          else "true"
        )
      parameter-5-97 = (" " + "" + " " + "")
      parameter-6-97 = if sort-phrase-97 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-97
        )
      parameter-7-97 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-97 =
          (" shar-buf_ord-doc.obj-code = store-code and shar-buf_ord-doc.obj-type = store-type and shar-buf_ord-doc.doc-type = g#type " + " " + where-phrase-97 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-97
                          ,input parameter-4-97
                          ,input parameter-5-97
                          ,input parameter-6-97
                          ,input parameter-7-97
                          )
      .
      assign
        l-filter-open-97 = true
      .
    end.
    if l-filter-open-97 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-97 = false then do:
    OPEN QUERY br-docs FOR EACH shar-buf_ord-doc no-lock
      where  shar-buf_ord-doc.obj-code = store-code and shar-buf_ord-doc.obj-type = store-type and shar-buf_ord-doc.doc-type = g#type
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( shar-buf_ord-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer shar-buf_ord-doc:handle) then do:
      assign
      parameter-2-97 = (if p-find-next then "true":u else "false":u )
      parameter-4-97 =
        "where ":u +  substitute('                             shar-buf_ord-doc.obj-code =  &3 and                             shar-buf_ord-doc.obj-type = &1&2&1 and                             shar-buf_ord-doc.doc-type = &1&4&1                             ' , chr(34) , store-type , store-code , g#type )  + " ":u + where-phrase-97 + " ":u + p-find-condition + " " + ""
      parameter-5-97 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(shar-buf_ord-doc)
                          ,input logical(parameter-2-97)
                          ,input no-lock
                          ,input (buffer shar-buf_ord-doc:handle)
                          ,input parameter-4-97
                          ,input parameter-5-97
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-97 = (if p-find-next then "true":u else "false":u )
      parameter-3-97 =  "FOR EACH shar-buf_ord-doc"
      parameter-4-97 =
        (
          if (" shar-buf_ord-doc.obj-code = store-code and shar-buf_ord-doc.obj-type = store-type and shar-buf_ord-doc.doc-type = g#type " + " " + where-phrase-97) <> ""
          then  substitute('                             shar-buf_ord-doc.obj-code =  &3 and                             shar-buf_ord-doc.obj-type = &1&2&1 and                             shar-buf_ord-doc.doc-type = &1&4&1                             ' , chr(34) , store-type , store-code , g#type )  + " " + where-phrase-97
          else "true"
        )
      parameter-5-97 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-97 = if sort-phrase-97 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-97
        )
      parameter-7-97 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-97)
                          ,input no-lock
                          ,input parameter-3-97
                          ,input parameter-4-97
                          ,input parameter-5-97
                          ,input parameter-6-97
                          ,input parameter-7-97
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
  when "objtypestatus":U then do:
      if p-open-query then frame d-all-docs:title = "Объект : "   + store-type    + " " + string(store-code)
                                + "  Тип : "    + ( if g#type = 'ОП':U THEN 'Объект-Поставщик':U ELSE   (if g#type = 'ОФ':U THEN 'Объект-Фирма':U else       (if g#type = 'ФП':U THEN 'Фирма-Поставщик':U else ? )))
                                + "  Статус : " + g#stat.
      Enable
            b-sost WITH FRAME d-all-docs.
define variable vss-include-info98 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-99  as logical   no-undo .
define variable  l-filter-open-99    as logical   .
define variable  flt-rec-99       as recid     no-undo .
define variable  filter-name-99      as character no-undo .
define variable  where-phrase-99     as character no-undo .
define variable  sort-phrase-99      as character no-undo .
define variable  where-phrase-rus-99 as character no-undo .
define variable  sort-phrase-rus-99  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-99
  ,output filter-name-99
  ,output where-phrase-99
  ,output sort-phrase-99
  ,output where-phrase-rus-99
  ,output sort-phrase-rus-99
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-99
      ) no-error .
  assign
    l-filter-open-99 = false
  .
  if flt-rec-99 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-99 as character no-undo .
    define variable  parameter-3-99 as character no-undo .
    define variable  parameter-4-99 as character no-undo .
    define variable  parameter-5-99 as character no-undo .
    define variable  parameter-6-99 as character no-undo .
    define variable  parameter-7-99 as character no-undo .
      assign
      parameter-3-99 =
                              "FOR EACH shar-buf_ord-doc"
      parameter-4-99 =
        (
          if (" shar-buf_ord-doc.obj-code = store-code and shar-buf_ord-doc.obj-type = store-type and shar-buf_ord-doc.doc-type = g#type and shar-buf_ord-doc.status_  = g#stat " + " " + where-phrase-99) <> ""
          then  substitute('                             shar-buf_ord-doc.obj-code =  &3 and                             shar-buf_ord-doc.obj-type = &1&2&1 and                             shar-buf_ord-doc.doc-type = &1&4&1 and                             shar-buf_ord-doc.status_  = &1&5&1                             ' , chr(34) , store-type , store-code , g#type , g#stat)  + " " + where-phrase-99
          else "true"
        )
      parameter-5-99 = (" " + "" + " " + "")
      parameter-6-99 = if sort-phrase-99 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-99
        )
      parameter-7-99 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-99 =
          (" shar-buf_ord-doc.obj-code = store-code and shar-buf_ord-doc.obj-type = store-type and shar-buf_ord-doc.doc-type = g#type and shar-buf_ord-doc.status_  = g#stat " + " " + where-phrase-99 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-99
                          ,input parameter-4-99
                          ,input parameter-5-99
                          ,input parameter-6-99
                          ,input parameter-7-99
                          )
      .
      assign
        l-filter-open-99 = true
      .
    end.
    if l-filter-open-99 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-99 = false then do:
    OPEN QUERY br-docs FOR EACH shar-buf_ord-doc no-lock
      where  shar-buf_ord-doc.obj-code = store-code and shar-buf_ord-doc.obj-type = store-type and shar-buf_ord-doc.doc-type = g#type and shar-buf_ord-doc.status_  = g#stat
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( shar-buf_ord-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer shar-buf_ord-doc:handle) then do:
      assign
      parameter-2-99 = (if p-find-next then "true":u else "false":u )
      parameter-4-99 =
        "where ":u +  substitute('                             shar-buf_ord-doc.obj-code =  &3 and                             shar-buf_ord-doc.obj-type = &1&2&1 and                             shar-buf_ord-doc.doc-type = &1&4&1 and                             shar-buf_ord-doc.status_  = &1&5&1                             ' , chr(34) , store-type , store-code , g#type , g#stat)  + " ":u + where-phrase-99 + " ":u + p-find-condition + " " + ""
      parameter-5-99 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(shar-buf_ord-doc)
                          ,input logical(parameter-2-99)
                          ,input no-lock
                          ,input (buffer shar-buf_ord-doc:handle)
                          ,input parameter-4-99
                          ,input parameter-5-99
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-99 = (if p-find-next then "true":u else "false":u )
      parameter-3-99 =  "FOR EACH shar-buf_ord-doc"
      parameter-4-99 =
        (
          if (" shar-buf_ord-doc.obj-code = store-code and shar-buf_ord-doc.obj-type = store-type and shar-buf_ord-doc.doc-type = g#type and shar-buf_ord-doc.status_  = g#stat " + " " + where-phrase-99) <> ""
          then  substitute('                             shar-buf_ord-doc.obj-code =  &3 and                             shar-buf_ord-doc.obj-type = &1&2&1 and                             shar-buf_ord-doc.doc-type = &1&4&1 and                             shar-buf_ord-doc.status_  = &1&5&1                             ' , chr(34) , store-type , store-code , g#type , g#stat)  + " " + where-phrase-99
          else "true"
        )
      parameter-5-99 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-99 = if sort-phrase-99 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-99
        )
      parameter-7-99 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-99)
                          ,input no-lock
                          ,input parameter-3-99
                          ,input parameter-4-99
                          ,input parameter-5-99
                          ,input parameter-6-99
                          ,input parameter-7-99
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
  when "constype":U then do:
      if p-open-query then frame d-all-docs:title = "Фирма : " + g#host-name  + "  Тип : " + ( if g#type = 'ОП':U THEN 'Объект-Поставщик':U ELSE   (if g#type = 'ОФ':U THEN 'Объект-Фирма':U else       (if g#type = 'ФП':U THEN 'Фирма-Поставщик':U else ? ))) +  " № СЗФП: " +  sch-cons.cons-code.
      Enable
             b-sost WITH FRAME d-all-docs.
      if g#type = 'ОФ':U or g#type = 'ОП':U then do:   b-sost:tooltip in FRAME d-all-docs = "Проставить статус 'Отказать' по заказу 'ОФ'".   end. else disable b-sost with FRAME d-all-docs.
define variable vss-include-info100 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-101  as logical   no-undo .
define variable  l-filter-open-101    as logical   .
define variable  flt-rec-101       as recid     no-undo .
define variable  filter-name-101      as character no-undo .
define variable  where-phrase-101     as character no-undo .
define variable  sort-phrase-101      as character no-undo .
define variable  where-phrase-rus-101 as character no-undo .
define variable  sort-phrase-rus-101  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-101
  ,output filter-name-101
  ,output where-phrase-101
  ,output sort-phrase-101
  ,output where-phrase-rus-101
  ,output sort-phrase-rus-101
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-101
      ) no-error .
  assign
    l-filter-open-101 = false
  .
  if flt-rec-101 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-101 as character no-undo .
    define variable  parameter-3-101 as character no-undo .
    define variable  parameter-4-101 as character no-undo .
    define variable  parameter-5-101 as character no-undo .
    define variable  parameter-6-101 as character no-undo .
    define variable  parameter-7-101 as character no-undo .
      assign
      parameter-3-101 =
                              "FOR EACH shar-buf_ord-doc"
      parameter-4-101 =
        (
          if (" shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.cons-code = sch-cons.cons-code and shar-buf_ord-doc.doc-type = g#type " + " " + where-phrase-101) <> ""
          then  substitute('                             shar-buf_ord-doc.host-code =  &2 and                             shar-buf_ord-doc.cons-code = &1&3&1 and                             shar-buf_ord-doc.doc-type = &1&4&1                              ' , chr(34) , g#host-code , sch-cons.cons-code , g#type )  + " " + where-phrase-101
          else "true"
        )
      parameter-5-101 = (" " + "" + " " + "")
      parameter-6-101 = if sort-phrase-101 = ''
                           then
        (
        " " + "use-index ByType " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + "use-index ByType " +
          " " + sort-column-phrase +
        " " + sort-phrase-101
        )
      parameter-7-101 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-101 =
          (" shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.cons-code = sch-cons.cons-code and shar-buf_ord-doc.doc-type = g#type " + " " + where-phrase-101 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-101
                          ,input parameter-4-101
                          ,input parameter-5-101
                          ,input parameter-6-101
                          ,input parameter-7-101
                          )
      .
      assign
        l-filter-open-101 = true
      .
    end.
    if l-filter-open-101 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-101 = false then do:
    OPEN QUERY br-docs FOR EACH shar-buf_ord-doc no-lock
      where  shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.cons-code = sch-cons.cons-code and shar-buf_ord-doc.doc-type = g#type
      use-index ByType
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( shar-buf_ord-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer shar-buf_ord-doc:handle) then do:
      assign
      parameter-2-101 = (if p-find-next then "true":u else "false":u )
      parameter-4-101 =
        "where ":u +  substitute('                             shar-buf_ord-doc.host-code =  &2 and                             shar-buf_ord-doc.cons-code = &1&3&1 and                             shar-buf_ord-doc.doc-type = &1&4&1                              ' , chr(34) , g#host-code , sch-cons.cons-code , g#type )  + " ":u + where-phrase-101 + " ":u + p-find-condition + " " + ""
      parameter-5-101 = "use-index ByType "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(shar-buf_ord-doc)
                          ,input logical(parameter-2-101)
                          ,input no-lock
                          ,input (buffer shar-buf_ord-doc:handle)
                          ,input parameter-4-101
                          ,input parameter-5-101
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-101 = (if p-find-next then "true":u else "false":u )
      parameter-3-101 =  "FOR EACH shar-buf_ord-doc"
      parameter-4-101 =
        (
          if (" shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.cons-code = sch-cons.cons-code and shar-buf_ord-doc.doc-type = g#type " + " " + where-phrase-101) <> ""
          then  substitute('                             shar-buf_ord-doc.host-code =  &2 and                             shar-buf_ord-doc.cons-code = &1&3&1 and                             shar-buf_ord-doc.doc-type = &1&4&1                              ' , chr(34) , g#host-code , sch-cons.cons-code , g#type )  + " " + where-phrase-101
          else "true"
        )
      parameter-5-101 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-101 = if sort-phrase-101 = ''
                           then
        (
        " " + "use-index ByType " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + "use-index ByType " +
          " " + sort-column-phrase +
        " " + sort-phrase-101
        )
      parameter-7-101 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-101)
                          ,input no-lock
                          ,input parameter-3-101
                          ,input parameter-4-101
                          ,input parameter-5-101
                          ,input parameter-6-101
                          ,input parameter-7-101
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
  when "contract":U then do:
      if p-open-query then frame d-all-docs:title = "По договору : " + sch-contract.contract-prn-code + "/" + string( sch-contract.contract-code)  .
      disable b-add b-chg b-del b-close   b-close b-copy b-payment b-sost with frame d-all-docs .
       disable b-add-2
            b-chg-2
            b-del-2
            b-close-2
            with frame d-all-docs .
define variable vss-include-info102 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-103  as logical   no-undo .
define variable  l-filter-open-103    as logical   .
define variable  flt-rec-103       as recid     no-undo .
define variable  filter-name-103      as character no-undo .
define variable  where-phrase-103     as character no-undo .
define variable  sort-phrase-103      as character no-undo .
define variable  where-phrase-rus-103 as character no-undo .
define variable  sort-phrase-rus-103  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-103
  ,output filter-name-103
  ,output where-phrase-103
  ,output sort-phrase-103
  ,output where-phrase-rus-103
  ,output sort-phrase-rus-103
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-103
      ) no-error .
  assign
    l-filter-open-103 = false
  .
  if flt-rec-103 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-103 as character no-undo .
    define variable  parameter-3-103 as character no-undo .
    define variable  parameter-4-103 as character no-undo .
    define variable  parameter-5-103 as character no-undo .
    define variable  parameter-6-103 as character no-undo .
    define variable  parameter-7-103 as character no-undo .
      assign
      parameter-3-103 =
                              "FOR EACH shar-buf_ord-doc"
      parameter-4-103 =
        (
          if (" shar-buf_ord-doc.contract-code = sch-contract.contract-code and shar-buf_ord-doc.host-code = g#host-code " + " " + where-phrase-103) <> ""
          then  substitute('                             shar-buf_ord-doc.host-code =  &2 and                             shar-buf_ord-doc.contract-code = &3                             ' , chr(34) , g#host-code , sch-contract.contract-code )  + " " + where-phrase-103
          else "true"
        )
      parameter-5-103 = (" " + "" + " " + "")
      parameter-6-103 = if sort-phrase-103 = ''
                           then
        (
        " " + "use-index by_contract " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + "use-index by_contract " +
          " " + sort-column-phrase +
        " " + sort-phrase-103
        )
      parameter-7-103 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-103 =
          (" shar-buf_ord-doc.contract-code = sch-contract.contract-code and shar-buf_ord-doc.host-code = g#host-code " + " " + where-phrase-103 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-103
                          ,input parameter-4-103
                          ,input parameter-5-103
                          ,input parameter-6-103
                          ,input parameter-7-103
                          )
      .
      assign
        l-filter-open-103 = true
      .
    end.
    if l-filter-open-103 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-103 = false then do:
    OPEN QUERY br-docs FOR EACH shar-buf_ord-doc no-lock
      where  shar-buf_ord-doc.contract-code = sch-contract.contract-code and shar-buf_ord-doc.host-code = g#host-code
      use-index by_contract
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( shar-buf_ord-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer shar-buf_ord-doc:handle) then do:
      assign
      parameter-2-103 = (if p-find-next then "true":u else "false":u )
      parameter-4-103 =
        "where ":u +  substitute('                             shar-buf_ord-doc.host-code =  &2 and                             shar-buf_ord-doc.contract-code = &3                             ' , chr(34) , g#host-code , sch-contract.contract-code )  + " ":u + where-phrase-103 + " ":u + p-find-condition + " " + ""
      parameter-5-103 = "use-index by_contract "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(shar-buf_ord-doc)
                          ,input logical(parameter-2-103)
                          ,input no-lock
                          ,input (buffer shar-buf_ord-doc:handle)
                          ,input parameter-4-103
                          ,input parameter-5-103
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-103 = (if p-find-next then "true":u else "false":u )
      parameter-3-103 =  "FOR EACH shar-buf_ord-doc"
      parameter-4-103 =
        (
          if (" shar-buf_ord-doc.contract-code = sch-contract.contract-code and shar-buf_ord-doc.host-code = g#host-code " + " " + where-phrase-103) <> ""
          then  substitute('                             shar-buf_ord-doc.host-code =  &2 and                             shar-buf_ord-doc.contract-code = &3                             ' , chr(34) , g#host-code , sch-contract.contract-code )  + " " + where-phrase-103
          else "true"
        )
      parameter-5-103 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-103 = if sort-phrase-103 = ''
                           then
        (
        " " + "use-index by_contract " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + "use-index by_contract " +
          " " + sort-column-phrase +
        " " + sort-phrase-103
        )
      parameter-7-103 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-103)
                          ,input no-lock
                          ,input parameter-3-103
                          ,input parameter-4-103
                          ,input parameter-5-103
                          ,input parameter-6-103
                          ,input parameter-7-103
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
end case.
if not p-open-query then do:
   reposition br-docs to recid doc-rec no-error.
   if error-status :error then message "Документ не найден." view-as alert-box information .
   apply "value-changed" to br-docs in frame d-all-docs .
end.
apply "entry" to br-docs in frame d-all-docs.
    OPEN QUERY BR-rcv FOR EACH ub.ord-doc-rcv no-lock where ub.ord-doc-rcv.doc-code = shar-buf_ord-doc.doc-code,       first bufs_ord-doc-rcv no-lock  where bufs_ord-doc-rcv.rcv-code =  ub.ord-doc-rcv.rcv-code and       bufs_ord-doc-rcv.doc-code =  ub.ord-doc-rcv.doc-code  ,       first ub.ord-chain no-lock where              ub.ord-chain.doc-code = ub.ord-doc-rcv.rcv-code and             ub.ord-chain.doc-type = 'rcv'                  and              ub.ord-chain.rel-doc-type = 'trn' OUTER-JOIN,       EACH ub.trn-doc no-lock WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code OUTER-JOIN.
END PROCEDURE.
PROCEDURE local-mark:
  if not available shar-buf_ord-doc then do:
    message "Неправильный выбор строки.".
    return error.
  end.
define variable vss-include-info104 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid105 as character no-undo .
define variable v-num-entry105 as integer   no-undo .
assign
  v-str-recid105 = trim( string( recid( shar-buf_ord-doc ) , "->>>>>>>>>>>9":U ) )
  v-num-entry105 = lookup( v-str-recid105 , del-list )
.
if v-num-entry105 > 0 then do:
  assign
    entry( v-num-entry105, del-list ) = "":U
    del-list = trim( replace( del-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    del-list = del-list + ( if del-list = "":U then "":U else chr(44) ) + v-str-recid105
  .
end.
  if lookup(string( recid(shar-buf_ord-doc) ), del-list ) > 0
      then disp "*"  @ mark with browse  br-docs.
      else disp "" @ mark with browse  br-docs.
END PROCEDURE.
procedure set-reject :
define buffer t-ord-line for ub.ord-line.
if not available shar-buf_ord-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (shar-buf_ord-doc). do on stop undo, return no-apply :   find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec exclusive-lock .   end. if shar-buf_ord-doc.status_     = 'факт':U and shar-buf_ord-doc.flag_= true  then do:    find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec no-lock.    message "Заказ закрыт до статуса ФАКТ .".    return no-apply. end.
 find current shar-buf_ord-doc no-lock  no-error.
  if avail shar-buf_ord-doc and shar-buf_ord-doc.status_ = 'отказ':U then do:
      Message "Документ уже находится в статусе " shar-buf_ord-doc.status_ view-as alert-box.
      return.
  end.
  if not( shar-buf_ord-doc.status_ = 'новый':U OR
          shar-buf_ord-doc.status_ = 'согласование':U or
          shar-buf_ord-doc.status_ = 'поставка':U
          ) then do:
      Message "Документ  находится в статусе " CAPS(shar-buf_ord-doc.status_) " Отказать нельзя !" view-as alert-box.
      return.
  end.
  if shar-buf_ord-doc.status_ = 'поставка':U then do:
  g#log = false .
  Message "Вы собираетесь проставить статус ОТКАЗАТЬ заказу в статусе ПОСТАВКА !" skip (2)
          "Это означает, что ВЫ не сможете по нему сформировать или получить ПН !" skip(2)
           " Если поставки и накладные уже созданы, то они будут существовать самостоятельно !" skip(2)
          "Отказать заказу № " shar-buf_ord-doc.doc-code  " ?"
           view-as alert-box question
           buttons YES-NO
           title "В Н И М А Н И Е !!! "
           update g#log
           .
           if NOT g#log then return .
  end.
  Message "Отказать заказу № " shar-buf_ord-doc.doc-code  " ?" view-as alert-box
           QUESTION buttons YES-NO update g#log.
           if NOT g#log then return .
 if shar-buf_ord-doc.cons-code <> "" and shar-buf_ord-doc.cons-code <> ? then do:
 define buffer b_ord-cons for ub.ord-cons.
    find first b_ord-cons where b_ord-cons.cons-code = shar-buf_ord-doc.cons-code no-lock no-error .
    if avail b_ord-cons and b_ord-cons.status_ <> 'новый':U then do:
        Message "Нельзя отказать заказу № " shar-buf_ord-doc.doc-code  " , так как СЗФП уже находится в статусе " b_ord-cons.status_ view-as alert-box.
        return.
    end.
 end.
 define variable tt as character no-undo .
 define variable tt2 as character no-undo .
 find current shar-buf_ord-doc EXCLUSIVE-LOCK no-error.
    if available shar-buf_ord-doc then do:
      if shar-buf_ord-doc.status_ = 'поставка':U then do:
         shar-buf_ord-doc.PS =  substitute("ОТКАЗ со статуса ПОСТАВКА !!! &1" ,shar-buf_ord-doc.PS ) .
      end.
      assign
        tt = shar-buf_ord-doc.cons-code
        shar-buf_ord-doc.status_ = 'отказ':U
        shar-buf_ord-doc.fact-date = to-day
        shar-buf_ord-doc.cons-code  = shar-buf_ord-doc.cons-code + 'отказ':U .
        .
       if tt <> "" and tt <> ? then do:
          for each t-ord-line where t-ord-line.doc-code = shar-buf_ord-doc.doc-code :
                find first  ub.ord-gds-cons where
                  ub.ord-gds-cons.cons-code = tt                    and
                  ub.ord-gds-cons.artic =     t-ord-line.artic       and
                  ub.ord-gds-cons.prod-code = t-ord-line.prod-code   and
                  ub.ord-gds-cons.prod-type = t-ord-line.prod-type   exclusive-lock use-index pi no-error .
                  if available ub.ord-gds-cons then do:
                      ub.ord-gds-cons.sum-qnty = ub.ord-gds-cons.sum-qnty - t-ord-line.qnty.
                      if ub.ord-gds-cons.sum-qnty  = 0 then do:
                        delete ub.ord-gds-cons.
                      end.
                  end.
          end.
        end.
       find current shar-buf_ord-doc  no-lock  no-error .
       define variable v-recid as recid no-undo .
       if error-status :error then
          message 'ошибка поиска shar-buf_ord-doc'skip
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) .
        v-recid = recid (shar-buf_ord-doc) .
       run str/callnews.p     (input "ord-doc"      ,input (buffer shar-buf_ord-doc:handle)    ) no-error .        if error-status:error then do:     Assign shar-buf_ord-doc.flag_ = True  shar-buf_ord-doc.status_ = 'новый':U.     Message                                                      vss-workfile vss-revision vss-description skip             "Ошибка при передаче заказа в новости" skip                "Документ" shar-buf_ord-doc.doc-code skip                             view-as alert-box .                                        return no-apply.                                       end.
        run UI-on in this-procedure (yes, no, '':U) no-error .
        if error-status :error then
            message 'ошибка процедуры UI-on' skip
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) .
         reposition br-docs to recid v-recid no-error .
         apply "value-changed" to br-docs in frame d-all-docs .
    end.
END PROCEDURE.
PROCEDURE mode-g#type :
define variable  m-i-of  as widget-handle.
define variable  m-i-op  as widget-handle.
define variable  m-i-fp  as widget-handle.
CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .
if  g#type <> 'ОФ':U
and g#type <> 'ОП':U
and g#type <> 'ФП':U
then do:
  disable b-rep with frame d-all-docs .
end.
if g#type = 'ОФ':U then  do:
frame d-all-docs:title = "ЗАЯВКИ   " + frame d-all-docs:title .
    create menu-item m-i-of IN WIDGET-POOL "My-pool"
      assign parent = menu m-rep:handle
      label = 'Отчет об исполнении заявок'
      .
      ON CHOOSE OF m-i-of PERSISTENT
       run run-rep (1) .
end.
if g#type = 'ОП':U then  do:
frame d-all-docs:title = "ЗАКАЗЫ   " + frame d-all-docs:title .
    create menu-item m-i-op IN WIDGET-POOL "My-pool"
      assign parent = menu m-rep:handle
            label = 'Отчет об исполнении заказов ОП'
      .
      ON CHOOSE OF m-i-op PERSISTENT run run-rep (2) .
      g#log =  br-docs:MOVE-COLUMN(10, 14) IN FRAME d-all-docs  no-error .
      shar-buf_ord-doc.cons-code:label in browse  br-docs = "Ссылка".
end.
if g#type = 'ФП':U then  do:
frame d-all-docs:title = "ЗАКАЗЫ   " + frame d-all-docs:title .
    create menu-item m-i-fp IN WIDGET-POOL "My-pool"
      assign parent = menu m-rep:handle
            label = 'Отчет об исполнении заказов ФП'
      .
      ON CHOOSE OF m-i-fp PERSISTENT run run-rep (3) .
end.
end procedure.
procedure run-rep :
define input parameter j as integer no-undo .
if j = 1 then do:
   run cus/g-isp-zy.p
     (input parparentproc
     ) .
end.
if j = 2 then do:
   run cus/g-isp-zk.p
     (input parparentproc
     ) .
end.
if j = 3 then do:
   run cus/g-isp-zf.p
     (input parparentproc
     ) .
end.
end procedure.
procedure proc-b-chg:
 if not available shar-buf_ord-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (shar-buf_ord-doc). do on stop undo, return no-apply :   find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec exclusive-lock .   end. if shar-buf_ord-doc.status_     = 'факт':U and shar-buf_ord-doc.flag_= true  then do:    find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec no-lock.    message "Заказ закрыт до статуса ФАКТ .".    return no-apply. end.
  if (( shar-buf_ord-doc.ord-int1 = int('1':U)
     or shar-buf_ord-doc.ord-int1 = int('2':U) )
    and shar-buf_ord-doc.whole-send-news = integer('1':U))
  or (( shar-buf_ord-doc.ord-int1 = int('1':U)
     or shar-buf_ord-doc.ord-int1 = int('2':U) )
    and shar-buf_ord-doc.whole-send-news = integer('2':U))
  then do:
    message
    "Документ "  shar-buf_ord-doc.doc-code  " нельзя корректировать, по системе EDOC\EDI заказ направлен поставщику"  view-as  alert-box .
        return .
  end.
  if v-cntxt-db-num = 0 then do:
    if not (shar-buf_ord-doc.status_  = 'новый':U or
            shar-buf_ord-doc.status_  = 'согласование':U)
        or (shar-buf_ord-doc.status_  = 'новый':U and not v-obj-active = "yes")
    then do:
        message "Документ "  shar-buf_ord-doc.doc-code  " нельзя корректировать ,  статус " caps(shar-buf_ord-doc.status_) if v-not-activ then "на неактивном складе" else ""  view-as  alert-box .
        return .
    end.
  end.
  else do:
    if shar-buf_ord-doc.status_  <> 'новый':U then do:
        message "Документ "  shar-buf_ord-doc.doc-code  " нельзя корректировать ,  статус " caps(shar-buf_ord-doc.status_) view-as  alert-box .
        return .
    end.
  end.
 if shar-buf_ord-doc.doc-type  =  'ФП':U and v-not-activ then do :
    message "Заказ "  shar-buf_ord-doc.doc-code  " нельзя корректировать ,  статус " shar-buf_ord-doc.status_ " на неактивном складе "
    view-as alert-box information.
    return .
  end.
define variable v-ri as recid no-undo .
v-ri = recid (shar-buf_ord-doc) .
run cus/ord-zakz.p
  (  input parParentProc ,
     input 'ИЗМЕНЕНИЕ':U ,
     input shar-buf_ord-doc.doc-type ,
     output doc-rec ,
     input-output  br-handle ,
     input-output  bf-handle ,
     input-output  next-prev
    ) .
run UI-on in this-procedure (yes, no, '':U).
reposition br-docs to recid v-ri no-error.
apply "value-changed" to br-docs in frame d-all-docs .
end procedure.
PROCEDURE make-fp-rcv :
define output param r-rec as recid no-undo.
define variable l-recid as recid no-undo.
define variable ks          as  integer no-undo .
define variable loc-ord-num as  character no-undo .
define variable ii          as  integer no-undo .
define buffer   b-goods     for ub.goods .
define buffer   bfp-ord-doc for ub.ord-doc .
define buffer   buf2-ord-line-rcv for ub.ord-line-rcv.
define variable last-all-rcv as decimal no-undo .
define variable glog as logical no-undo .
ks = 0.
define variable v-i-doc as character no-undo .
if not available shar-buf_ord-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (shar-buf_ord-doc). do on stop undo, return no-apply :   find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec exclusive-lock .   end. if shar-buf_ord-doc.status_     = 'факт':U and shar-buf_ord-doc.flag_= true  then do:    find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec no-lock.    message "Заказ закрыт до статуса ФАКТ .".    return no-apply. end.
   find current shar-buf_ord-doc  no-lock no-error .
      if not available  shar-buf_ord-doc then do:
        message "Не выбран Заказ ФП !!! " .
        return.
      end.
  find first bfp-ord-doc where bfp-ord-doc.doc-code = shar-buf_ord-doc.doc-code no-lock no-error.
            if error-status :error  then return.
   if bfp-ord-doc.status_ <> 'поставка':U
     then do:
        message "Нельзя делать Поставку на  Заказ в статусе " caps(bfp-ord-doc.status_) " !"
                 view-as alert-box information .
        return.
   end.
   if (( bfp-ord-doc.ord-int1 = int('5':U)
      or bfp-ord-doc.ord-int1 = int('6':U))
     and is-edoc-nn
     and bfp-ord-doc.whole-send-news = integer('1':U) )
  or  (
  is-edi
     and bfp-ord-doc.whole-send-news = integer('2':U) )
        and bfp-ord-doc.doc-type = 'ОП':U
     then do:
    if is-edi
    and bfp-ord-doc.whole-send-news = integer('2':U) then do:
define variable vss-include-info106 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_ord-rcv_add-def-bypass-EDI':U
    ,input  'object':U
    ,input  g#host-code
    ,input  store-type
    ,input  store-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
      if g-log = false then do:
        return.
      end.
      else do:
        glog = no.
        message
        "Вы уверены, что хотите сделать вручную поставку на Заказ, маршрутизируемый по EDI?" skip
        view-as alert-box question buttons yes-no update glog .
        if not glog then return.
      end.
    end.
    if is-edoc-nn
    and bfp-ord-doc.whole-send-news = integer('1':U) then do:
     message
      "Нельзя делать Поставку на Заказ при работе в EDOC ! Она придет в электронном виде от поставщика."
                 view-as alert-box information .
        return.
   end.
   end.
   if ( trim(bfp-ord-doc.cons-code) = ""  or  bfp-ord-doc.cons-code = ? ) and bfp-ord-doc.doc-type = 'ОП':U  and v-edoc-ora then do:
     message
     "Нельзя делать Поставку на Заказ . Заказ отправлен во внешнюю систему ! Ждем подтверждения от внешней системы."
                 view-as alert-box information .
        return.
   end.
   define variable v-is-limit as logical   no-undo .
   run ver-qnty-rcv-from-ord (input bfp-ord-doc.doc-code , output v-is-limit ) .
   if v-is-limit then do:
        message "Нельзя делать Поставку на Заказ. Система настроена на работу 1:1."
                 view-as alert-box information .
        return.
   end.
define variable vss-include-info107 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run proc-ord-code in this-procedure
 (input   'main' ,
  input   v-cntxt-db-num ,
  input   v-cntxt-obj-type ,
  input   v-cntxt-obj-code ,
  input   v-i-doc ,
  output  loc-ord-num
 ) .
create ub.ord-doc-rcv.
buffer-copy bfp-ord-doc
except whole-send-news
to ub.ord-doc-rcv
   assign
      ub.ord-doc-rcv.rcv-code  = loc-ord-num
      ub.ord-doc-rcv.doc-type  = "out":u
      ub.ord-doc-rcv.doc-date  = to-day
      ub.ord-doc-rcv.status_   = 'новый':U
      ub.ord-doc-rcv.sub-par   = trim(entry(1, bfp-ord-doc.cli-out-doc, chr(4))) + chr(4) +
                              trim(bfp-ord-doc.vat-type) + chr(4)
   .
v-doc-mode  = 'ДОБАВЛЕНИЕ':U.
x-make-avto = 2 .
define variable loc-make-avto as logical no-undo .
        run cus/or-obj.w
        ( input  parParentProc
        , input  ub.ord-doc-rcv.host-code
        , input  recid(ub.ord-doc-rcv)
        , input  1
        , input  'ИЗМЕНЕНИЕ':U
        , input  'ИЗМЕНЕНИЕ':U
        , input-output  v-doc-mode  ) .
        case x-make-avto :
          when 1 then loc-make-avto = true  .
          when 4 then loc-make-avto = true  .
          when 2 then loc-make-avto = false  .
          when 3 then loc-make-avto = ? .
        end case.
  if v-doc-mode = "cancel":U then do :
      find first ub.ord-doc-rcv where ub.ord-doc-rcv.rcv-code  = loc-ord-num  exclusive-lock  no-error .
      delete ub.ord-doc-rcv .
      r-rec = ? .
      return .
  end .
 r-rec = recid ( ub.ord-doc-rcv ) .
v-doc-mode  = 'ДОБАВЛЕНИЕ':U .
if loc-make-avto <> ? then do:
   for each ub.ord-line where ub.ord-line.doc-code = bfp-ord-doc.doc-code  no-lock :
        ks = ks + 1 .
        if not can-find  (first ub.ord-line-rcv where
          ub.ord-line-rcv.doc-code  = ub.ord-doc-rcv.doc-code and
          ub.ord-line-rcv.rcv-code  = ub.ord-doc-rcv.rcv-code and
          ub.ord-line-rcv.artic     = ub.ord-line.artic and
          ub.ord-line-rcv.prod-code = ub.ord-line.prod-code and
          ub.ord-line-rcv.prod-type = ub.ord-line.prod-type no-lock ) then do:
          last-all-rcv = 0 .
          for each buf2-ord-line-rcv where
                  buf2-ord-line-rcv.doc-code  = ub.ord-doc-rcv.doc-code and
                  buf2-ord-line-rcv.artic     = ub.ord-line.artic and
                  buf2-ord-line-rcv.prod-code = ub.ord-line.prod-code and
                  buf2-ord-line-rcv.prod-type = ub.ord-line.prod-type no-lock
                  :
                  last-all-rcv =  last-all-rcv + buf2-ord-line-rcv.qnty .
          end.
         create ub.ord-line-rcv.
         buffer-copy ub.ord-line to ub.ord-line-rcv
         assign
           ub.ord-line-rcv.rcv-code  = ub.ord-doc-rcv.rcv-code
           ub.ord-line-rcv.line-num  = ks
           ub.ord-line-rcv.qnty      = if (ub.ord-line.qnty - last-all-rcv) < 0 then 0 else  (ub.ord-line.qnty - last-all-rcv)
           ub.ord-line-rcv.cli-qnty  = ub.ord-line-rcv.qnty / ub.ord-line-rcv.cli-base-rate
         .
         l-recid = recid(ub.ord-line-rcv) .
         case loc-make-avto :
              when false  then do:
                    v-doc-mode  = 'ДОБАВЛЕНИЕ':U.
                    run cus/or-obj.w
                    ( input  parParentProc
                    , input  bfp-ord-doc.host-code
                    , input  recid(ub.ord-line-rcv)
                    , input  2
                    , input  'ИЗМЕНЕНИЕ':U
                    , input "ЦИКЛ":U
                    , input-output  v-doc-mode  ) .
                    if v-doc-mode =  "stopcycle":U   then do:
                          find first ub.ord-line-rcv where
                              recid(ub.ord-line-rcv) = l-recid exclusive-lock  no-error .
                          delete ub.ord-line-rcv.
                          ks = ks - 1 .
                          leave .
                      end.
                    if v-doc-mode =  "cancel":U   then do:
                          find first ub.ord-line-rcv where
                              recid(ub.ord-line-rcv) = l-recid exclusive-lock  no-error .
                          delete ub.ord-line-rcv.
                          ks = ks - 1 .
                      end.
                  l-recid = recid(ub.ord-line-rcv).
              end.
              when true then do:
                  l-recid = recid(ub.ord-line-rcv).
              end.
           end case.
         end.
   end.
end.
if x-make-avto = 3 then do:
   ks = 1.
   run cus/scan-r.p (parparentproc,ub.ord-doc-rcv.rcv-code,ub.ord-doc-rcv.doc-code) .
end.
 if ks > 0 then do:
    r-rec = recid(ord-doc-rcv).
    define variable g-log as logical   no-undo .
    if x-make-avto = 4 then do:
   find first ord-doc-rcv exclusive-lock where recid(ord-doc-rcv) =  r-rec .
    run cus/rcv-clos.p
    (
        input parparentproc ,
        input ord-doc-rcv.rcv-code ,
        input yes ,
        input store-type ,
        input store-code ,
        input false
        ) no-error .
    if error-status :error then do:
          message  return-value  view-as alert-box error .
          release ord-doc-rcv .
          find first ord-doc-rcv no-lock where recid(ord-doc-rcv) = r-rec no-error .
          return .
    end.
    OPEN QUERY BR-rcv FOR EACH ub.ord-doc-rcv no-lock where ub.ord-doc-rcv.doc-code = shar-buf_ord-doc.doc-code,       first bufs_ord-doc-rcv no-lock  where bufs_ord-doc-rcv.rcv-code =  ub.ord-doc-rcv.rcv-code and       bufs_ord-doc-rcv.doc-code =  ub.ord-doc-rcv.doc-code  ,       first ub.ord-chain no-lock where              ub.ord-chain.doc-code = ub.ord-doc-rcv.rcv-code and             ub.ord-chain.doc-type = 'rcv'                  and              ub.ord-chain.rel-doc-type = 'trn' OUTER-JOIN,       EACH ub.trn-doc no-lock WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code OUTER-JOIN.
    reposition BR-rcv to recid r-rec no-error  .
    g-log =  br-docs:refresh()  in frame d-all-docs .
    release ord-doc-rcv .
    find first ord-doc-rcv no-lock where recid(ord-doc-rcv) = r-rec no-error .
       run cus/ord-trn.p ( parParentProc ,  recid(ord-doc-rcv), no) no-error .
       if error-status :error then do:
       message
         vss-workfile vss-revision vss-description skip
         error-status :get-message(1) skip
         return-value skip
         "Ошибка при создании накладной"
         view-as alert-box error
       .
       end.
    end.
  message "Сделана поставка № " loc-ord-num .
 end.
 else do:
   find first ord-doc-rcv where ord-doc-rcv.rcv-code  = loc-ord-num  exclusive-lock  .
   delete ord-doc-rcv .
   r-rec = ?.
 end.
END PROCEDURE.
procedure proc-close-2:
  define variable g-log as logical   no-undo .
  define variable ll-rec as recid no-undo .
  find current ub.ord-doc-rcv no-lock no-error.
  if not available ub.ord-doc-rcv then return .
  ll-rec = recid(ub.ord-doc-rcv) .
    run cus/rcv-clos.p
    (
        input parparentproc ,
        input ub.ord-doc-rcv.rcv-code ,
        input yes ,
        input store-type ,
        input store-code ,
        input yes
        ) no-error .
    if error-status :error then do:
          message  return-value  view-as alert-box error .
          release ub.ord-doc-rcv .
          find first ub.ord-doc-rcv no-lock where recid(ub.ord-doc-rcv) = ll-rec no-error .
          return .
    end.
    OPEN QUERY BR-rcv FOR EACH ub.ord-doc-rcv no-lock where ub.ord-doc-rcv.doc-code = shar-buf_ord-doc.doc-code,       first bufs_ord-doc-rcv no-lock  where bufs_ord-doc-rcv.rcv-code =  ub.ord-doc-rcv.rcv-code and       bufs_ord-doc-rcv.doc-code =  ub.ord-doc-rcv.doc-code  ,       first ub.ord-chain no-lock where              ub.ord-chain.doc-code = ub.ord-doc-rcv.rcv-code and             ub.ord-chain.doc-type = 'rcv'                  and              ub.ord-chain.rel-doc-type = 'trn' OUTER-JOIN,       EACH ub.trn-doc no-lock WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code OUTER-JOIN.
    reposition BR-rcv to recid ll-rec no-error  .
    g-log =  br-docs:refresh() in frame d-all-docs .
    release ub.ord-doc-rcv .
    find first ub.ord-doc-rcv no-lock where recid(ub.ord-doc-rcv) = ll-rec no-error .
END procedure.
procedure proc-b-del-2 :
define variable t-ret as logical no-undo .
if not available shar-buf_ord-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (shar-buf_ord-doc). do on stop undo, return no-apply :   find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec exclusive-lock .   end. if shar-buf_ord-doc.status_     = 'факт':U and shar-buf_ord-doc.flag_= true  then do:    find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec no-lock.    message "Заказ закрыт до статуса ФАКТ .".    return no-apply. end.
  t-ret =  session:SET-WAIT-STATE("GENERAL") .
find current ub.ord-doc-rcv no-lock no-error.
if available ub.ord-doc-rcv then do:
  find current ub.ord-doc-rcv exclusive-lock no-error.
  if available ub.ord-doc-rcv then do:
    if ub.ord-doc-rcv.status_ <> 'новый':U then do :
    message "Статус" ub.ord-doc-rcv.status_ "удалять нельзя! " view-as alert-box error .
    return.
    end.
    message "Удалить поставку №"  ub.ord-doc-rcv.rcv-code "?" view-as alert-box
          question buttons yes-no title "Вопрос" update g#log.
      if g#log then do:
        delete  ub.ord-doc-rcv .
        OPEN QUERY BR-rcv FOR EACH ub.ord-doc-rcv no-lock where ub.ord-doc-rcv.doc-code = shar-buf_ord-doc.doc-code,       first bufs_ord-doc-rcv no-lock  where bufs_ord-doc-rcv.rcv-code =  ub.ord-doc-rcv.rcv-code and       bufs_ord-doc-rcv.doc-code =  ub.ord-doc-rcv.doc-code  ,       first ub.ord-chain no-lock where              ub.ord-chain.doc-code = ub.ord-doc-rcv.rcv-code and             ub.ord-chain.doc-type = 'rcv'                  and              ub.ord-chain.rel-doc-type = 'trn' OUTER-JOIN,       EACH ub.trn-doc no-lock WHERE ub.trn-doc.doc-code = ub.ord-chain.rel-doc-code OUTER-JOIN.
      end.
    end.
end.
  t-ret =  session:SET-WAIT-STATE("") .
END PROCEDURE.
PROCEDURE proc-b-add :
 define variable v-par-prt as logical no-undo .
 define buffer buff_ord-doc for ub.ord-doc  .
 if g#type = 'ОП':U  then do:
    if v-cntxt-db-num <> v-cntxt-db-num-obj then do:
       message  substitute("Заказ &1 можно создать только в  БД №  &2" ,  g#type,v-cntxt-db-num-obj )
                view-as alert-box information .
       return .
    end.
 end.
  run cus/ord-zakz.p
    (input  parParentProc,
     input  'ДОБАВЛЕНИЕ':U ,
     input  g#type,
     output doc-rec ,
     input-output  br-handle ,
     input-output  bf-handle ,
     input-output  next-prev
      ) no-error .
     if error-status :error then
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "Ошибка при создании заказа"
       view-as alert-box error
     .
  find first buff_ord-doc no-lock where recid(buff_ord-doc) =  doc-rec no-error .
  if  available buff_ord-doc then do:
      run UI-on in this-procedure (yes, no, '':U).
      reposition br-docs to recid doc-rec no-error.
      apply "value-changed" to br-docs in frame d-all-docs .
  end.
END PROCEDURE.
procedure pp-1 :
 do
 on error undo, return error return-value
 :
  if not available shar-buf_ord-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (shar-buf_ord-doc). do on stop undo, return no-apply :   find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec no-lock .   end.
  run cus/ord-zakz.p
 (input parParentProc,
  input "copy":u ,
  input  shar-buf_ord-doc.doc-type ,
  output doc-rec ,
  input-output  br-handle ,
  input-output  bf-handle ,
  input-output  next-prev
  ) .
  run UI-on in this-procedure (yes, no, '':U).
  reposition br-docs to recid doc-rec no-error.
  apply "value-changed" to br-docs in frame d-all-docs .
 end.
end procedure.
procedure pp-2 :
 do
 on error undo, return error return-value
 :
define variable del-rec as recid no-undo.
define variable unrv-qnty as dec no-undo.
    if not available shar-buf_ord-doc then do:   message "Неправильно выбран документ.".   return no-apply. end. doc-rec = recid (shar-buf_ord-doc). do on stop undo, return no-apply :   find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec exclusive-lock .   end. if shar-buf_ord-doc.status_     = 'факт':U and shar-buf_ord-doc.flag_= true  then do:    find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec no-lock.    message "Заказ закрыт до статуса ФАКТ .".    return no-apply. end.
    find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec no-lock.
    if shar-buf_ord-doc.status_ <> 'новый':U or (shar-buf_ord-doc.status_ = 'новый':U and not v-obj-active = "yes") then do:
      message "Документ в статусе" shar-buf_ord-doc.status_ "удалять нельзя! " view-as alert-box error .
      return no-apply.
    end.
    if (( shar-buf_ord-doc.ord-int1 = int('1':U)
       or shar-buf_ord-doc.ord-int1 = int('2':U) )
      and is-edoc-nn
      and shar-buf_ord-doc.whole-send-news = integer('1':U) )
    or (( shar-buf_ord-doc.ord-int1 = int('1':U)
       or shar-buf_ord-doc.ord-int1 = int('2':U) )
      and is-edi
      and shar-buf_ord-doc.whole-send-news = integer('2':U) )
      then do:
      message
      "Документ "  shar-buf_ord-doc.doc-code  " нельзя удалить ,  статус EDOC\EDI " caps('отправлен':U) "(Отправлен поставщику)"  view-as  alert-box .
          return .
    end.
    if (( shar-buf_ord-doc.ord-int1 = int('3':U)
       or shar-buf_ord-doc.ord-int1 = int('4':U) )
      and is-edoc-nn
      and shar-buf_ord-doc.whole-send-news = integer('1':U) )
    or (( shar-buf_ord-doc.ord-int1 = int('3':U)
       or shar-buf_ord-doc.ord-int1 = int('5':U))
      and is-edi
      and shar-buf_ord-doc.whole-send-news = integer('2':U) )
      then do:
      message
      "Документ "  shar-buf_ord-doc.doc-code  " нельзя удалить ,  статус EDOC\EDI " caps('отправлен':U) "(Ожидает решения)"  view-as  alert-box .
          return .
    end.
    g#log = no.
    message "Удалить документ №" shar-buf_ord-doc.doc-code "?   Вы уверены ?"
                    view-as alert-box question buttons OK-Cancel update g#log.
    if not g#log then do:   find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec no-lock.   return no-apply. end.
    run waitfram-show in this-procedure ("Удаление документа № " + shar-buf_ord-doc.doc-code + ". Ждите...").
    br-handle  = br-docs:handle  in frame d-all-docs .
    if valid-handle (br-handle) then do:
      g#log = br-handle:select-next-row().
      if not g#log then g#log = br-handle:select-prev-row().
      del-rec = recid (shar-buf_ord-doc).
    end.
    find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec.
    del-doc:
    do on stop undo del-doc, return no-apply on error undo del-doc, return no-apply:
      delete shar-buf_ord-doc.
    end.
    doc-rec = del-rec.
    run waitfram-hide in this-procedure .
    run UI-on in this-procedure (yes, no, '':U).
 end.
end procedure.
PROCEDURE set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame d-all-docs:
    if p-filter-name > "" then do:
      assign
        frame d-all-docs:title
          = frame d-all-docs:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :TOOLTIP = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :TOOLTIP = ""
      .
    end.
  end.
END PROCEDURE.
procedure proc-doc-code :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as char no-undo.
  do
  on error undo, return error return-value
  :
display "" @ sch-date with frame d-all-docs.
display "" @ sch-fact with frame d-all-docs.
assign
  pardoc-code = chr(34) + pardoc-code + chr(34) .
     run Ui-on in this-procedure
          (input false
          ,input par-next
          ,input substitute ( "and shar-buf_ord-doc.doc-code begins &1 "
            , pardoc-code)
          ) no-error .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "ui-on"
      view-as alert-box error
    .
 apply "VALUE-CHANGED" to br-docs in frame d-all-docs.
 apply "entry" to sch-code in frame d-all-docs.
  end.
end procedure.
procedure proc-doc-date :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as date      no-undo .
  do
  on error undo, return error return-value
  :
define variable ppp as character no-undo .
display "" @ sch-code with frame d-all-docs.
display "" @ sch-fact with frame d-all-docs.
assign
  ppp =  string( day(pardoc-code)) + "/" +  string( month(pardoc-code)) + "/" +  string( year(pardoc-code)) .
     run Ui-on in this-procedure
          (input false
          ,input par-next
          ,input substitute ( "and shar-buf_ord-doc.doc-date = &1 "
            , ppp)
          ) no-error .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "ui-on"
      view-as alert-box error
    .
 apply "VALUE-CHANGED" to br-docs in frame d-all-docs.
 apply "entry" to sch-date in frame d-all-docs.
  end.
end procedure.
procedure proc-fact-date :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as date      no-undo .
  do
  on error undo, return error return-value
  :
define variable ppp as character no-undo .
display "" @ sch-code with frame d-all-docs.
display "" @ sch-date with frame d-all-docs.
assign
  ppp =  string( day(pardoc-code)) + "/" +  string(  month(pardoc-code)) + "/" +  string( year(pardoc-code)) .
     run Ui-on in this-procedure
          (input false
          ,input par-next
          ,input substitute ( "and shar-buf_ord-doc.fact-date = &1 "
            , ppp)
          ) no-error .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "ui-on"
      view-as alert-box error
    .
 apply "VALUE-CHANGED" to br-docs in frame d-all-docs.
 apply "entry" to sch-fact in frame d-all-docs.
  end.
end procedure.
procedure  proc-m_gen-1 :
  do
  on error undo, return error return-value
  :
    if num-entries(del-list) = 0 then do:
      message "Не выделено ни одного Заказа для генерации ФО !".
      return error .
    end.
    run str/gen-fl.w
    (
        input parparentproc,
        input g#host-code,
        input del-list,
        input "order"
        ) .
    assign del-list = "" .
    run UI-on in this-procedure (yes, no, '':U) .
  end.
end procedure.
procedure  proc-m_gen-1_buyer :
  do
  on error undo, return error return-value
  :
    if num-entries(del-list) = 0 then do:
      message "Не выделено ни одного Заказа для генерации ФО !".
      return error .
    end.
    run str/gen-fbuy.w
    (   input parparentproc,
        input g#host-code,
        input del-list,
        input "order"
        ) .
    assign del-list = "" .
    run UI-on in this-procedure (yes, no, '':U) .
  end.
end procedure.
PROCEDURE proc-m_gen-2 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_ord-doc for ub.ord-doc.
define variable v-i as integer no-undo.
define variable v-doc-code as integer no-undo.
do on error undo, return error return-value
:
if del-list = "" then do:
  if available shar-buf_ord-doc then assign del-list = string(recid(shar-buf_ord-doc)).
end.
define variable v-nn as integer   no-undo .
v-nn = num-entries (del-list).
v-i-cycle:
  do v-i = 1 to v-nn :
    assign v-doc-code = integer(entry (v-i, del-list)).
    find first bf_ord-doc where recid(bf_ord-doc) = v-doc-code exclusive-lock.
    if bf_ord-doc.status_ <> 'факт':U then do:
      message "Документ " bf_ord-doc.status_ " не в статусе " 'факт':U " . Пропускаем." view-as alert-box.
      next v-i-cycle.
    end.
    find first bf_sysconf where bf_sysconf.host-code = bf_ord-doc.host-code no-lock.
    if bf_ord-doc.doc-type <> 'ПО':U then do:
        if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
          message "Главная БД для фирмы по документу с кодом " bf_ord-doc.doc-code " не является текущей БД." skip
                  "Текущая БД: " v-cntxt-db-num skip "Главная БД фирмы: " bf_sysconf.firm-db-num
          view-as alert-box error.
          next v-i-cycle.
        end.
    end.
    if bf_ord-doc.cr-fo = yes then do:
      message "По документу " bf_ord-doc.doc-code " уже создавался ФО от " bf_ord-doc.fo-date " числа." view-as alert-box.
      next v-i-cycle.
    end.
    else do:
      if bf_ord-doc.need-fo = 1 or bf_ord-doc.need-fo = 2 then assign  bf_ord-doc.need-fo = 0.
      else do:
        message "Данный документ не нуждался в генерации ФО." view-as alert-box.
        next v-i-cycle.
      end.
      reposition br-docs to recid recid(bf_ord-doc) no-error.
      if not error-status:error then do:
         apply "value-changed" to br-docs in frame d-all-docs .
         display f-fo (buffer bf_ord-doc) @ v-fo  mark  with browse br-docs.
      end.
    end.
  end.
  find first bf_ord-doc where recid(bf_ord-doc) = v-doc-code no-lock no-error .
  assign del-list = "".
end.
end procedure.
PROCEDURE proc-m_gen-3 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_ord-doc for ub.ord-doc.
define variable v-i as integer no-undo.
define variable v-doc-code as integer no-undo.
define variable v-log as logical   no-undo .
do on error undo, return error return-value
:
  if del-list = "" then do:
    if available shar-buf_ord-doc then assign del-list = string(recid(shar-buf_ord-doc)).
  end.
define variable v-nn as integer   no-undo .
v-nn = num-entries (del-list).
v-i-cycle:
  do v-i = 1 to v-nn :
    assign v-doc-code = integer(entry (v-i, del-list)).
    find first bf_ord-doc where recid(bf_ord-doc) = v-doc-code exclusive-lock.
    find first bf_sysconf where bf_sysconf.host-code = bf_ord-doc.host-code no-lock.
    if lookup(bf_ord-doc.status_, 'факт':U + "," + 'поставка':U) = 0 then do:
      message "Документ " bf_ord-doc.status_ " не в статусе " 'факт':U " . Пропускаем." view-as alert-box.
      next v-i-cycle.
    end.
    if bf_ord-doc.doc-type <> 'ПО':U then do:
        if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
          message "Главная БД для фирмы по документу с кодом " bf_ord-doc.doc-code " не является текущей БД." skip
                  "Текущая БД: " v-cntxt-db-num skip   "Главная БД фирмы: " bf_sysconf.firm-db-num
          view-as alert-box error.
          next v-i-cycle.
        end.
    end.
    if bf_ord-doc.cr-fo = yes then do:
      assign
        v-log = no.
        message "По документу " bf_ord-doc.doc-code " был создан ФО от " bf_ord-doc.fo-date " ." skip
                "Вы действительно хотите снять признак, чтобы по этому документу был ФО?"
        view-as alert-box question buttons yes-no update v-log.
       if v-log <> yes then  next v-i-cycle.
       assign
         bf_ord-doc.cr-fo   = no
         bf_ord-doc.fo-date = 01/01/1990
       .
       reposition br-docs to recid recid(bf_ord-doc) no-error.
      if not error-status:error then do:
        apply "value-changed" to br-docs in frame d-all-docs .
        display f-fo (buffer bf_ord-doc) @ v-fo mark with browse br-docs.
      end.
    end.
    else do:
      message "По документу " bf_ord-doc.doc-code " не было генерации."
      view-as alert-box.
   end.
 end.
 assign del-list = "".
end.
end procedure.
PROCEDURE proc-m_gen-4 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_ord-doc for ub.ord-doc.
define variable v-i as integer no-undo.
define variable v-doc-code as integer no-undo.
define variable v-need-fo as logical no-undo.
define buffer bf_contract for ub.contract.
do on error undo, return error return-value
:
  if del-list = "" then do:
    if available shar-buf_ord-doc then assign del-list = string(recid(shar-buf_ord-doc)).
  end.
define variable v-nn as integer   no-undo .
v-nn = num-entries (del-list) .
v-i-cycle:
  do v-i = 1 to v-nn:
    assign v-doc-code = integer(entry (v-i, del-list)) .
    find first bf_ord-doc where recid(bf_ord-doc) = v-doc-code exclusive-lock.
    find first bf_sysconf where bf_sysconf.host-code = bf_ord-doc.host-code no-lock.
    if bf_ord-doc.status_ <> 'факт':U then do:
      message "Документ " bf_ord-doc.doc-code " не в статусе " 'факт':U " . Пропускаем."  view-as alert-box.
      next.
    end.
    if bf_ord-doc.doc-type <> 'ПО':U then do:
        if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
          message "Главная БД для фирмы по документу с кодом " bf_ord-doc.doc-code " не является текущей БД." skip
                  "Текущая БД: " v-cntxt-db-num skip "Главная БД фирмы: " bf_sysconf.firm-db-num
          view-as alert-box error.
          return error.
        end.
    end.
    if bf_ord-doc.need-FO = 2 then do:
      if bf_ord-doc.contract-code <> 0 then do:
        find first bf_contract where bf_contract.host-code     = bf_ord-doc.host-code   and
                                     bf_contract.contract-code = bf_ord-doc.contract-code no-lock no-error.
        if available bf_contract then do:
          if  true  then do:
            assign bf_ord-doc.need-FO = 1  .
            reposition br-docs to recid recid(bf_ord-doc) no-error.
            if not error-status:error then do:
              apply "value-changed" to br-docs in frame d-all-docs .
              display f-FO (buffer bf_ord-doc) @ v-FO  mark with browse br-docs.
            end.
          end.
          else message "По документу " bf_ord-doc.doc-code " нет договоров для генерации ФО."  view-as alert-box.
        end.
      end.
    end.
    else do:
      message "Документ " bf_ord-doc.doc-code "не имеет признака 'не опред' генерация ФО."
      view-as alert-box.
      next v-i-cycle.
    end.
  end.
  assign del-list = "" .
find first bf_ord-doc where recid(bf_ord-doc) = v-doc-code no-lock no-error .
end.
end procedure.
procedure proc-m_lkp-fo :
  do
  on error undo, return error return-value
  :
  if available shar-buf_ord-doc then do:
    run str/fi-trns.w
    (   input parparentproc,
        input shar-buf_ord-doc.host-code,
        input ?              ,
        input shar-buf_ord-doc.doc-code ,
        input "order":U
        ) .
    end.
  end.
end procedure.
PROCEDURE proc-m_gen-3-2 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_ord-doc for ub.ord-doc.
define variable v-i as integer no-undo.
define variable v-doc-code as integer no-undo.
define variable v-log as logical   no-undo .
do on error undo, return error return-value
:
  if del-list = "" then do:
    if available shar-buf_ord-doc then assign del-list = string(recid(shar-buf_ord-doc)).
  end.
define variable v-nn as integer   no-undo .
v-nn = num-entries (del-list).
v-i-cycle:
  do v-i = 1 to v-nn :
    assign v-doc-code = integer(entry (v-i, del-list)).
    find first bf_ord-doc where recid(bf_ord-doc) = v-doc-code exclusive-lock.
    if bf_ord-doc.doc-type <> 'ПО':U then next.
    find first bf_sysconf where bf_sysconf.host-code = bf_ord-doc.host-code no-lock.
    if bf_ord-doc.cr-fo2 = yes then do:
      assign
        v-log = no.
        message "По документу " bf_ord-doc.doc-code " был создан ФО от " bf_ord-doc.fo-date2 " ." skip
                "Вы действительно хотите снять признак, чтобы по этому документу был ФО?"
        view-as alert-box question buttons yes-no update v-log.
       if v-log <> yes then  next v-i-cycle.
       assign
         bf_ord-doc.cr-fo2   = no
         bf_ord-doc.fo-date2 = 01/01/1990
       .
      reposition br-docs to recid recid (bf_ord-doc) no-error.
      if not error-status:error then do:
        apply "value-changed" to br-docs in frame d-all-docs .
        display f-fo (buffer bf_ord-doc) @ v-fo mark  with browse br-docs.
      end.
    end.
    else do:
      message "По документу " bf_ord-doc.doc-code " не было генерации."
      view-as alert-box.
   end.
 end.
 assign del-list = "".
find first bf_ord-doc where recid(bf_ord-doc) = v-doc-code no-lock  no-error .
end.
end procedure.
PROCEDURE proc-m_gen-2-2 :
define buffer bf_sysconf   for ub.sysconf.
define buffer bf_ord-doc   for ub.ord-doc.
define variable v-i        as integer no-undo.
define variable v-doc-code as integer no-undo.
do on error undo, return error return-value
:
if del-list = "" then do:
  if available shar-buf_ord-doc then assign del-list = string(recid(shar-buf_ord-doc)).
end.
define variable v-nn as integer   no-undo .
v-nn = num-entries (del-list).
v-i-cycle:
  do v-i = 1 to v-nn :
    assign v-doc-code = integer(entry (v-i, del-list)).
    find first bf_ord-doc where recid(bf_ord-doc) = v-doc-code exclusive-lock.
    if bf_ord-doc.doc-type <> 'ПО':U then next.
    if bf_ord-doc.status_ <> 'факт':U then do:
      message "Документ " bf_ord-doc.status_ " не в статусе " 'факт':U " . Пропускаем." view-as alert-box.
      next v-i-cycle.
    end.
    find first bf_sysconf where bf_sysconf.host-code = bf_ord-doc.host-code no-lock.
    if bf_ord-doc.cr-fo2 = yes then do:
      message "По документу " bf_ord-doc.doc-code " уже создавался ФО от " bf_ord-doc.fo-date2 " числа." view-as alert-box.
      next v-i-cycle.
    end.
    else do:
      if bf_ord-doc.need-fo2 = 1 or bf_ord-doc.need-fo2 = 2 then assign  bf_ord-doc.need-fo2 = 0.
      else do:
        message "Данный документ не нуждался в генерации ФО." view-as alert-box.
        next v-i-cycle.
      end.
      reposition br-docs to recid recid(bf_ord-doc) no-error.
      if not error-status:error then do:
        apply "value-changed" to br-docs in frame d-all-docs .
        display f-fo (buffer bf_ord-doc) @ v-fo with browse br-docs.
        display  mark with browse br-docs.
      end.
    end.
  end.
  assign del-list = "".
find first bf_ord-doc where recid(bf_ord-doc) = v-doc-code no-lock no-error .
end.
end procedure.
PROCEDURE proc-m_gen-4-2 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_ord-doc for ub.ord-doc.
define variable v-i as integer no-undo.
define variable v-doc-code as integer no-undo.
define variable v-need-fo as logical no-undo.
define buffer bf_contract for ub.contract.
do on error undo, return error return-value
:
if del-list = "" then do:
  if available shar-buf_ord-doc then assign del-list = string(recid(shar-buf_ord-doc)).
end.
define variable v-nn as integer   no-undo .
v-nn = num-entries (del-list) .
v-i-cycle:
  do v-i = 1 to v-nn:
    assign v-doc-code = integer(entry (v-i, del-list)) .
    find first bf_ord-doc where recid(bf_ord-doc) = v-doc-code exclusive-lock.
    if bf_ord-doc.doc-type <> 'ПО':U then next.
    find first bf_sysconf where bf_sysconf.host-code = bf_ord-doc.host-code no-lock.
    if bf_ord-doc.status_ <> 'факт':U then do:
      message "Документ " bf_ord-doc.doc-code " не в статусе " 'факт':U " . Пропускаем."  view-as alert-box.
      next.
    end.
    if bf_ord-doc.need-FO2 = 2 then do:
      if bf_ord-doc.contract-code <> 0 then do:
        find first bf_contract where bf_contract.host-code     = bf_ord-doc.host-code   and
                                     bf_contract.contract-code = bf_ord-doc.contract-code no-lock no-error.
        if available bf_contract then do:
          if  true  then do:
            assign bf_ord-doc.need-FO2 = 1  .
            reposition br-docs to recid recid(bf_ord-doc) no-error.
            if not error-status:error then do:
               apply "value-changed" to br-docs in frame d-all-docs .
               display f-FO (buffer bf_ord-doc) @ v-FO   mark  with browse br-docs.
               end.
          end.
          else message "По документу " bf_ord-doc.doc-code " нет договоров для генерации ФО."  view-as alert-box.
        end.
      end.
    end.
    else do:
      message "Документ " bf_ord-doc.doc-code "не имеет признака 'не опред' генерация ФО."
      view-as alert-box.
      next v-i-cycle.
    end.
  end.
  assign del-list = "" .
find first bf_ord-doc where recid(bf_ord-doc) = v-doc-code no-lock no-error .
end.
end procedure.
procedure clip-ord :
define output parameter p-recid as recid no-undo .
define buffer buf_ord-doc  for ub.ord-doc  .
define buffer new_ord-doc  for ub.ord-doc  .
define buffer new_ord-line for ub.ord-line  .
define buffer buf_ord-line for ub.ord-line  .
define buffer bb2_ord-line for ub.ord-line.
define buffer bb_ord-line  for ub.ord-line.
define buffer bb_goods for ub.goods  .
define variable loc-ord-num as character no-undo .
  do
  on error undo, return error return-value
  :
for each tempclip-orddoc :
  delete tempclip-orddoc.
end.
find current shar-buf_ord-doc no-lock .
p-recid = recid(shar-buf_ord-doc) .
 if num-entries (del-list) < 2 then do:
    message "Для объединения в один заказ нужно выделить не менее двух заказов!"  view-as alert-box information .
    return .
 end.
define variable v-nn   as integer   no-undo .
define variable v-i    as integer   no-undo .
define variable v-str  as character no-undo .
define variable v-diff as character no-undo .
define variable v-diff-contract as character no-undo init "" .
v-nn = num-entries (del-list).
find first buf_ord-doc exclusive-lock where
      recid(buf_ord-doc) = integer ( entry (1, del-list)) no-error .
if error-status :error then return .
if buf_ord-doc.ord-int1 <> 0 then do:
   message "Нельзя объединять заказы , которые уже начали обработку по EDOC\EDI !"
   view-as alert-box information .
   return .
end.
 create tempclip-orddoc.
 buffer-copy buf_ord-doc to tempclip-orddoc .
 find first tempclip-orddoc.
define variable v-longchar as longchar no-undo .
define variable v-err-clip as logical   no-undo .
v-err-clip = false .
  do v-i = 1 to v-nn :
    find first  buf_ord-doc exclusive-lock where
         recid (buf_ord-doc) = integer ( entry (v-i, del-list))  .
         if not available buf_ord-doc then next.
    if buf_ord-doc.status_ <> 'новый':U then do:
      message "Объединять заказы  можно только в статусе НОВЫЙ !"
      view-as alert-box information .
      return .
    end.
    if buf_ord-doc.doc-type <> 'ОП':U then do:
      message "Объединять  можно только заказы ОП !"
      view-as alert-box information .
      return .
    end.
    buffer-compare tempclip-orddoc EXCEPT
      agnt
      boss
      cli-qnty
      creid
      date-sale-1
      date-sale-2
      doc-code
      doc-date
      e-method
      end-date
      exch-date
      ord-method
      out-code
      qnty
      real-date-create
      real-time-create
      start-date
      sub-par
      sum-base
      sum-cli
      sum-rubl
      sys-date
      sys-time-int
      sys-time
      tot-lines
      user-db-num
      user-name
      whole-send-news
      wrkr
      fact-num
      ps
      cli-name
      exch-date
      transport-cli-code
      transport-cli-type
      transport-condition
      transport-contract
      transport-host-code
      transport-value
      transport-VAT
      pay-day
      contract-code
      order-type
      cycle-day
      cli-out-doc
    to buf_ord-doc save result in v-diff .
    .
    if entry(1, buf_ord-doc.cli-out-doc, chr(4)) <> entry(1, tempclip-orddoc.cli-out-doc, chr(4)) then do:
      v-diff = v-diff + (if v-diff = '' then '' else chr(44)) + "cli-out-doc".
    end.
    if v-diff <> ""
    then do:
          define variable v-str2 as character no-undo .
          define variable newstr as character no-undo .
          define variable i as integer   no-undo .
          define variable l as integer   no-undo .
          v-str2 = v-diff .
          newstr = "" .
          repeat i = 1 to num-entries (v-str2) :
            l = lookup ( entry (i,v-str2) , "base-rate,base-scale,buyer-out-code,cli-code,cli-out-doc,cli-point-code,cli-point-db-num,cli-type,cons-code,contract-code,cycle-day,date-pay,deliv-subj-code,deliv-type-code,doc-type,exch-code,exch-rate,exch-scale,fact-date,fact-order,fact-time,flag_,host-code,obj-code,obj-point-code,obj-point-db-num,obj-type,ord-date1,ord-date2,ord-date3,ord-dec1,ord-dec2,ord-dec3,ord-int1,ord-int2,ord-int3,order-type,pay-code,pay-day,shift-date,shift-name,shift-num,ship-date,ship-time,slt-type,vat-type,status_,sum-service,sum-ship,transport-cli-code,transport-cli-type,transport-condition,transport-contract,transport-host-code,transport-value,transport-VAT" )  .
            newstr  = newstr + entry ( l , "Баз.валюта_м.б.,Баз.валюта_шкала,Номер по поставщику,Код Поставщика,Номер по Поставщику,Пункты доставки,Пункты доставки,Тип Поставщика,Код,Договор,Цикл,Дата платежа,Код доставки,Код доставки,Тип заказа,Валюта,Курс валюты поставщика,М.б. валюты поставщика,факт дата,факт номер,факт врем,флаг,фирма,Объект код,Доставка код,Доставка БД,Объект тип,ord-date1,ord-date2,ord-date3,ord-dec1,ord-dec2,ord-dec3,Статус Edoc-NN\EDI,ord-int2,ord-int3,тип заказа,код платежа,дней продаж,сменная дата,смена,смена №,Дата доставки (Заказ на),Время доставки,Тип НсП,Тип НДС,Статус,Сумма обслуживани,Сумма доставки,Транспортный договор (Контрагент код),Транспортный договор (Контрагент тип),Транспортный договор (условия),Транспортный договор (№ договора),Транспортный договор (код фирмы),Транспортный договор,Транспортный договор (НДС)" )  + ", " .
          end.
          newstr = trim(trim(newstr),"," ).
          v-err-clip = true .
          v-longchar = v-longchar +
          substitute ( "Нельзя объединить заказ &1 c &2 , есть несовпадения (&3)&4" ,buf_ord-doc.doc-code,tempclip-orddoc.doc-code, newstr,chr(10) ) .
    end.
    else do:
        buffer-compare tempclip-orddoc USING
          contract-code
        to buf_ord-doc save result in v-diff-contract .
          if v-diff-contract <> "" then do:
            v-diff-contract = "".
          end.
          else do:
              v-diff-contract = string (buf_ord-doc.contract-code) .
          end.
    end.
    v-str = v-str + buf_ord-doc.doc-code + ", ".
          for each  bb_ord-line no-lock where
                 bb_ord-line.doc-code = tempclip-orddoc.doc-code :
           find first bb2_ord-line no-lock where
                      bb2_ord-line.doc-code = buf_ord-doc.doc-code and
                      bb2_ord-line.gds-code = bb_ord-line.gds-code and
                      bb2_ord-line.cli-art <> bb_ord-line.cli-art
                      no-error .
            if available bb2_ord-line then do:
                find first bb_goods no-lock where
                           bb_goods.gds-code = bb2_ord-line.gds-code no-error .
                v-err-clip = true .
                v-longchar = v-longchar +
                substitute ( "Нельзя объединить заказ &1 c &2 , есть несовпадения по артикулу поставщика Товар &3 &4&5 &6 &7" ,buf_ord-doc.doc-code,tempclip-orddoc.doc-code,bb_ord-line.artic,bb_ord-line.prod-type,bb_ord-line.prod-code ,bb_goods.gds-name,chr(10)) .
            end.
           find first bb2_ord-line no-lock where
                      bb2_ord-line.doc-code = buf_ord-doc.doc-code and
                      bb2_ord-line.gds-code = bb_ord-line.gds-code and
                      bb2_ord-line.price-cli <>  bb_ord-line.price-cli
                      no-error .
            if available bb2_ord-line then do:
                find first bb_goods no-lock where
                           bb_goods.gds-code = bb2_ord-line.gds-code no-error .
                v-err-clip = true .
                v-longchar = v-longchar +
                substitute ( "Нельзя объединить заказ &1 c &2 , есть несовпадения по цене поставщика Товар &3 &4&5 &6 (&8 и &9)&7" ,buf_ord-doc.doc-code,tempclip-orddoc.doc-code,bb_ord-line.artic,bb_ord-line.prod-type,bb_ord-line.prod-code ,bb_goods.gds-name,chr(10), bb2_ord-line.price-cli , bb_ord-line.price-cli) .
            end.
        end.
  end.
  if v-err-clip = true   then do:
      run gbl/d-longchar.w (
              ?,
              'Editor_row=2\':u
            + 'title=Ошибки объединения заказов\':u
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
    return error "Заказ не может быть закрыт ! Исправьте внешние артикулы Поставщика" .
  end.
  v-str = trim(trim(v-str),"," ).
  message "Объединять заказы " v-str
          "в один ? "
          view-as alert-box question
          buttons yes-no
          update v-okk as logical
        .
  if v-okk = false then return .
define variable v-i-doc as character no-undo .
define variable vss-include-info108 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run proc-ord-code in this-procedure
 (input   'main' ,
  input   v-cntxt-db-num ,
  input   v-cntxt-obj-type ,
  input   v-cntxt-obj-code ,
  input   v-i-doc ,
  output  loc-ord-num
 ) .
  define variable v-ln as integer   no-undo .
  v-ln = 0.
  do v-i = 1 to v-nn :
    find first buf_ord-doc exclusive-lock where
         recid(buf_ord-doc) = integer ( entry (v-i, del-list))  no-error .
         if not available buf_ord-doc then next.
         run save-orddoc ( buffer buf_ord-doc , input loc-ord-num) .
          for each buf_ord-line exclusive-lock where
                   buf_ord-line.doc-code =  buf_ord-doc.doc-code by  buf_ord-line.line-num :
                   run save-ordline
                       ( input loc-ord-num ,
                         input buf_ord-line.doc-code,
                         input buf_ord-line.gds-code,
                         input buf_ord-line.cli-qnty,
                         input buf_ord-doc.order-type
                         ) no-error  .
                   if error-status :error then message
                     vss-workfile vss-revision vss-description skip
                     error-status :get-message(1) skip
                     return-value skip
                     "save-ordline"
                     view-as alert-box error
                   .
                  find first new_ord-line exclusive-lock where
                             new_ord-line.doc-code =  loc-ord-num and
                             new_ord-line.gds-code =  buf_ord-line.gds-code no-error .
                  if available new_ord-line then do:
                      new_ord-line.qnty     =  new_ord-line.qnty     + buf_ord-line.qnty .
                      new_ord-line.cli-qnty =  new_ord-line.cli-qnty + buf_ord-line.cli-qnty.
                      new_ord-line.sum-rubl =  new_ord-line.sum-rubl + buf_ord-line.sum-rubl.
                      new_ord-line.sum-base =  new_ord-line.sum-base + buf_ord-line.sum-base.
                      new_ord-line.sum-cli  =  new_ord-line.sum-cli  + buf_ord-line.sum-cli.
                      new_ord-line.sum-vat  =  new_ord-line.sum-vat  + buf_ord-line.sum-vat.
                  end.
                  else do:
                     v-ln = v-ln + 1.
                     assign
                      buf_ord-line.doc-code = loc-ord-num
                      buf_ord-line.line-num = v-ln
                      .
                  end.
            end.
  delete buf_ord-doc.
  end.
  create new_ord-doc.
  buffer-copy tempclip-orddoc to new_ord-doc
    assign
      new_ord-doc.doc-code     = loc-ord-num
      new_ord-doc.doc-date     = to-day
      new_ord-doc.contract-code = integer(v-diff-contract)
    .
    p-recid = recid ( new_ord-doc ) .
    del-list = "" .
end.
end procedure.
procedure save-orddoc :
define parameter buffer  buf_ord-doc for ub.ord-doc.
define input  parameter p-new-ord-num as character no-undo .
define variable v-new-code as character no-undo .
  do
  on error undo, return error return-value
  :
  if buf_ord-doc.order-type = 0 then return .
  assign
    tempclip-orddoc.order-type    = 4
    tempclip-orddoc.contract-code = 0
    tempclip-orddoc.cycle-day     = 0
  .
  v-new-code = p-new-ord-num + chr(4) + buf_ord-doc.doc-code .
  run orddocattr-write (
       input v-new-code
      ,input 'cycle-doc-code':U
      ,input buf_ord-doc.doc-code) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .
  run orddocattr-write (
       input v-new-code
      ,input 'cycle-day':U
      ,input string(buf_ord-doc.cycle-day)) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .
  run orddocattr-write (
       input v-new-code
      ,input 'cycle-doc-date':U
      ,input string(buf_ord-doc.doc-date , "99/99/9999" )) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .
  run orddocattr-write (
       input v-new-code
      ,input 'exch-code':U
      ,input string(buf_ord-doc.exch-code)) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .
  run orddocattr-write (
       input v-new-code
      ,input 'exch-rate':U
      ,input string(buf_ord-doc.exch-rate)) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .
  run orddocattr-write (
       input v-new-code
      ,input 'base-rate':U
      ,input string(buf_ord-doc.base-rate)) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .
  run orddocattr-write (
       input v-new-code
      ,input 'base-scale':U
      ,input string(buf_ord-doc.base-scale)) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .
  run orddocattr-write (
       input v-new-code
      ,input 'cycle-done':U
      ,input "no") no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .
  run orddocattr-write (
       input  v-new-code
      ,input 'cycle-contract-code':U
      ,input string(buf_ord-doc.contract-code)) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .
  run orddocattr-write (
       input v-new-code
      ,input 'cycle-ship-date':U
      ,input string(buf_ord-doc.ship-date, "99/99/9999" )) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .
  run orddocattr-write (
       input v-new-code
      ,input 'cycle-ship-time':U
      ,input string(buf_ord-doc.ship-time)) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .
  run orddocattr-write (
       input v-new-code
      ,input 'cycle-date1':U
      ,input string(buf_ord-doc.date-sale-1, "99/99/9999" )) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .
  run orddocattr-write (
       input v-new-code
      ,input 'cycle-date2':U
      ,input string(buf_ord-doc.date-sale-2, "99/99/9999")) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .
  end.
end procedure.
procedure save-ordline :
define input  parameter p-new-code as character no-undo .
define input  parameter p-doc-code as character no-undo .
define input  parameter p-gds-code  as integer   no-undo .
define input  parameter p-cli-qnty as decimal   no-undo .
define input  parameter p-order-type as integer   no-undo .
  do
  on error undo, return error return-value
  :
  if p-order-type = 0 then return .
  run ordlineattr-write (
       input p-new-code + chr(4) + p-doc-code
      ,input p-gds-code
      ,input 'cycle-cli-qnty':U
      ,input string(p-cli-qnty)) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из ordlineattr-write"
        view-as alert-box error
      .
  end.
end procedure.
