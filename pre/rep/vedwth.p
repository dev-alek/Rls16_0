block-level on error undo, throw.
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-doc-code       as character        no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: vedwth.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/vedwth.p $":U .
define variable vss-description as character no-undo init "Препроводительная ведомость к сумке с денежной наличностью".
define variable g#report-num              as integer              no-undo .
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable var-report-r-b as character no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
def var vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer buf_wth-doc     for ub.wth-doc .
define stream out-stream.
FUNCTION f-wp-qnty returns character ( INPUT p-dec as decimal ) :
  define variable pr as character no-undo .
  run rep/wp-qnty.p ( input p-dec, output Pr ).
  if Pr = '' then do:
     Pr = 'Ноль'.
  end.
  RETURN ( Pr ) .
END FUNCTION.
DO
ON ERROR UNDO, RETURN ERROR substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
:
   run get-report-num in parparentproc (output g#report-num).
   run get-quest-print in parparentproc ( output g#quest-print ).
DEFINE TEMP-TABLE tt-line NO-UNDO
      FIELD curr-name   as character
      FIELD curr-code   as integer
      FIELD okv-code    as integer
      field par-val     as integer
      field par-rate    as decimal
      field par-unit    as character
      FIELD par-code    as integer
      field summ        as integer
      FIELD wth-code    as integer
      INDEX pi IS PRIMARY UNIQUE
            curr-code
            wth-code
            par-code
.
DEFINE TEMP-TABLE tt-summ NO-UNDO
      FIELD curr-code   as integer
      FIELD okv-code   as integer
      field curr-summ   as decimal
      field curr-abbr   as character
      field part-abbr   as character
      INDEX pi IS PRIMARY UNIQUE
            curr-code
.
define variable vss-include-info12 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define stream excel-line.
define stream excel-cell.
define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character
    index pi is primary unique data-key
.
define variable v-vedwthxl-sheet1-cur-data-row     as integer      no-undo.
define variable v-vedwthxl-sheet2-cur-data-row     as integer      no-undo.
define variable v-vedwthxl-sheet3-cur-data-row     as integer      no-undo.
define variable v-vedwthxl-cell-file-name       as character    no-undo.
define variable v-vedwthxl-data-file-name       as character    no-undo.
procedure vedwthxl-init :
do
on error undo, return error
:
    assign
        v-vedwthxl-sheet1-cur-data-row = 0
        v-vedwthxl-sheet2-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-vedwthxl-data-file-name
    ).
    output stream excel-line to value( v-vedwthxl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-vedwthxl-cell-file-name
    ).
    output stream excel-cell to value( v-vedwthxl-cell-file-name ).
    run vedwthxl-write-cell-data in this-procedure (
          input "sheetList":U
        , input "экз1,экз2,экз3":U
    ).
    if printrubl
    then do:
        run vedwthxl-write-cell-data in this-procedure (
              input "экз1_valutCode":U
            , input "0":U
        ).
        run vedwthxl-write-cell-data in this-procedure (
              input "экз2_valutCode":U
            , input "0":U
        ).
        run vedwthxl-write-cell-data in this-procedure (
              input "экз3_valutCode":U
            , input "0":U
        ).
    end.
    else do:
        run vedwthxl-write-cell-data in this-procedure (
              input "экз1_valutCode":U
            , input "1":U
        ).
        run vedwthxl-write-cell-data in this-procedure (
              input "экз2_valutCode":U
            , input "1":U
        ).
        run vedwthxl-write-cell-data in this-procedure (
              input "экз3_valutCode":U
            , input "1":U
        ).
    end.
    run vedwthxl-write-cell-data in this-procedure (
          input "экз1_columnList":U
        , input "curr_name,curr_code,fact_qnty,par_val,fact_sum":U
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input "экз1_columnType":U
        , input "S,S,S,S,S":U
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input "экз1_subtotalList":U
        , input "":U
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input "экз1_subtotalType":U
        , input "":U
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input "экз2_columnList":U
        , input "curr_name,curr_code,fact_qnty,par_val,fact_sum":U
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input "экз2_columnType":U
        , input "S,S,S,S,S":U
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input "экз2_subtotalList":U
        , input "":U
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input "экз2_subtotalType":U
        , input "":U
    ).
end.
end procedure.
procedure vedwthxl-sheet1-write-line-data :
define buffer buf_tt-line     for tt-line .
do
on error undo, return error
:
    for each buf_tt-line
    :
        put stream excel-line unformatted
                            "экз1":U
            CHR(9)   "DTA":U
            CHR(9)   buf_tt-line.curr-name
            CHR(9)   buf_tt-line.okv-code
            CHR(9)   (buf_tt-line.summ / buf_tt-line.par-rate)
            CHR(9)   SUBSTITUTE ("&1 &2", buf_tt-line.par-val, buf_tt-line.par-unit)
            CHR(9)   buf_tt-line.summ
            chr(10)
        .
    end.
end.
end procedure.
procedure vedwthxl-sheet3-write-line-data :
do
on error undo, return error
:
end.
end procedure.
procedure vedwthxl-sheet2-write-line-data :
define buffer buf_tt-line     for tt-line .
do
on error undo, return error
:
    for each buf_tt-line
    :
        put stream excel-line unformatted
                            "экз2":U
            CHR(9)   "DTA":U
            CHR(9)   buf_tt-line.curr-name
            CHR(9)   buf_tt-line.okv-code
            CHR(9)   (buf_tt-line.summ / buf_tt-line.par-rate)
            CHR(9)   SUBSTITUTE ("&1 &2", buf_tt-line.par-val, buf_tt-line.par-unit)
            CHR(9)   buf_tt-line.summ
            chr(10)
        .
    end.
end.
end procedure.
procedure vedwthxl-write-cell-data :
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
        CHR(9)   buf_temp_cell-data.data-value
        chr(10)
    .
end.
end procedure.
procedure vedwthxl-run-excel :
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
        v-template-file-name    = search( "exe/vedprepr.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas")
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
procedure vedwthxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/vedprepr.xlt":U.
        export "exe/t_form.bas":U.
        export v-vedwthxl-cell-file-name.
        export v-vedwthxl-data-file-name.
    output close.
end.
end procedure.
   FIND FIRST buf_wth-doc
      WHERE buf_wth-doc.doc-code = p-doc-code
      NO-LOCK
      NO-ERROR
      .
   IF NOT AVAILABLE buf_wth-doc
   THEN DO:
      MESSAGE
         "Не найден документ" p-doc-code
         SKIP
      VIEW-AS ALERT-BOX ERROR.
      RETURN ERROR SUBSTITUTE("Не найден документ &1", p-doc-code).
   END.
   run calc-summ     IN THIS-PROCEDURE ( INPUT p-doc-code ) .
   run open-stream   IN THIS-PROCEDURE .
   run print-header  IN THIS-PROCEDURE .
   run print-body    IN THIS-PROCEDURE .
   run print-footer  IN THIS-PROCEDURE .
   run close-stream  IN THIS-PROCEDURE .
end.
procedure calc-summ :
define input parameter p-doc-code       as character        no-undo.
define variable v-curr-name    as character    no-undo.
define variable v-okv-code    as integer      no-undo.
define variable v-curr-num    as integer      no-undo.
define variable v-ok    as logical      no-undo.
define buffer buf_wth-line    for ub.wth-line .
define buffer buf_wth-dtl     for ub.wth-dtl .
define buffer buf_wth-par     for ub.wth-par .
define buffer buf_wealth      for ub.wealth .
define buffer buf_currency    for ub.currency .
define buffer buf_tt-summ     for tt-summ .
define buffer buf_tt-line     for tt-line .
do
on error undo, return error
:
   FOR EACH buf_wth-line
      WHERE buf_wth-line.doc-code   = p-doc-code
      NO-LOCK
      ,
      FIRST buf_wealth
      WHERE buf_wealth.wth-code     = buf_wth-line.wth-code
        AND buf_wealth.is-money     = YES
      NO-LOCK
      BREAK BY buf_wealth.curr-code
      :
      IF FIRST-OF (buf_wealth.curr-code)
      THEN DO:
         FIND FIRST buf_currency
              WHERE buf_currency.curr-code = buf_wealth.curr-code
              NO-LOCK
              NO-ERROR
              .
         CREATE buf_tt-summ.
         ASSIGN
            buf_tt-summ.curr-code = buf_wealth.curr-code
            v-curr-num = v-curr-num + 1
         .
         IF NOT AVAILABLE buf_currency
         THEN DO:
            ASSIGN
               buf_tt-summ.curr-abbr = "???":U
               buf_tt-summ.part-abbr = "???":U
               buf_tt-summ.okv-code  = 0
            .
         END.
         ELSE DO:
            ASSIGN
               buf_tt-summ.curr-abbr = buf_currency.curr-abbr
               buf_tt-summ.part-abbr = buf_currency.part-abbr
               buf_tt-summ.okv-code  = buf_currency.okv-code
            .
         END.
      END.
      ASSIGN
         buf_tt-summ.curr-summ = buf_tt-summ.curr-summ + buf_wth-line.fact-sum
      .
   End.
   IF v-curr-num > 2
   THEN DO:
      message
         "В документе присутствует более двух валют."
         skip "В шапке документа не поместятся все суммы прописью."
         SKIP "Продолжить?"
      view-as alert-box question buttons YES-NO update v-ok.
      IF NOT v-ok
      THEN DO:
         RETURN ERROR "В документе присутствует более двух валют." .
      END.
   END.
   FOR EACH buf_wth-dtl
      WHERE buf_wth-dtl.doc-code = p-doc-code
      NO-LOCK
      ,
      FIRST buf_wth-par
      WHERE buf_wth-par.wth-code = buf_wth-dtl.wth-code
        AND buf_wth-par.par-code = buf_wth-dtl.par-code
      NO-LOCK
      ,
      FIRST buf_wealth
      WHERE buf_wealth.wth-code  = buf_wth-dtl.wth-code
        AND buf_wealth.is-money  = YES
      NO-LOCK
      :
      FIND FIRST buf_tt-line
           WHERE buf_tt-line.curr-code = buf_wealth.curr-code
             AND buf_tt-line.wth-code  = buf_wth-dtl.wth-code
             AND buf_tt-line.par-code  = buf_wth-dtl.par-code
           EXCLUSIVE-LOCK
           NO-ERROR
           .
      IF NOT AVAILABLE buf_tt-line
      THEN DO:
         FIND FIRST buf_currency
              WHERE buf_currency.curr-code = buf_wealth.curr-code
              NO-LOCK
              NO-ERROR
              .
         IF NOT AVAILABLE buf_currency
         THEN DO:
            ASSIGN
               v-curr-name = "Не найдена"
               v-okv-code = 000
            .
         END.
         ELSE DO:
            ASSIGN
               v-curr-name = buf_currency.curr-name
               v-okv-code = buf_currency.okv-code
            .
         END.
         CREATE buf_tt-line.
         ASSIGN
            buf_tt-line.curr-code = buf_wealth.curr-code
            buf_tt-line.okv-code  = v-okv-code
            buf_tt-line.wth-code  = buf_wth-dtl.wth-code
            buf_tt-line.par-code  = buf_wth-dtl.par-code
            buf_tt-line.par-rate  = buf_wth-par.par-rate
            buf_tt-line.par-unit  = buf_wth-par.par-unit
            buf_tt-line.par-val   = buf_wth-par.par-val
            buf_tt-line.curr-name = v-curr-name
         .
      END.
      ASSIGN
         buf_tt-line.summ = buf_tt-line.summ + buf_wth-dtl.fact-sum
      .
   End.
end.
end procedure.
procedure open-stream :
do
on error undo, return error
:
if session :set-wait-state( "compiler" ) then.
output stream out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
    put stream out-stream unformatted
          chr(10)
        + "Печатная форма предназначена только для вывода в Microsoft Excel."
        + chr(10)
    .
    output stream out-stream close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
    output close.
    run vedwthxl-init in this-procedure.
end.
end procedure.
procedure print-header :
do
on error undo, return error
:
    define variable v-object    as character    no-undo.
    define variable v-firm      as character    no-undo.
    define variable v-host-code as integer    no-undo.
    define variable v-client    as character    no-undo.
    define variable v-bank      as character    no-undo.
    define variable v-schet     as character    no-undo.
    define variable v-collect   as character    no-undo.
    define buffer buf_fin-bank      for ub.fin-bank .
    define buffer buf_fin-schet     for ub.fin-schet .
    define buffer buf_fin-bank-attr for ub.fin-bank-attr .
    define buffer buf_clients       for ub.clients .
    define buffer buf_tt-summ       for tt-summ .
    find first buf_clients
         where buf_clients.obj-type = buf_wth-doc.obj-type
           and buf_clients.obj-code = buf_wth-doc.obj-code
         no-lock
         no-error
         .
    IF AVAILABLE buf_clients
    THEN DO:
      assign
         v-host-code = buf_clients.host-code
         v-object = buf_clients.obj-name
      .
      find first buf_clients
            where buf_clients.obj-type = 'орг':U
            and buf_clients.obj-code   = v-host-code
            no-lock
            no-error
            .
      IF AVAILABLE buf_clients
      THEN DO:
         assign
            v-firm = buf_clients.obj-name
         .
      END.
      FIND FIRST buf_fin-schet
            WHERE buf_fin-schet.host-code = v-host-code
           no-lock
           no-error
           .
      IF NOT AVAILABLE buf_fin-schet
      THEN DO:
         MESSAGE
            "У организации" v-host-code "не найдено ни одного счета"
            SKIP
         VIEW-AS ALERT-BOX ERROR.
         RETURN ERROR SUBSTITUTE("У организации &1 не найдено ни одного счета", v-host-code).
      END.
      FIND FIRST buf_fin-bank
           WHERE buf_fin-bank.host-code = v-host-code
             and buf_fin-bank.code-bank = buf_fin-schet.code-bank
           no-lock
           no-error
           .
      IF AVAILABLE buf_fin-bank
      THEN DO:
            assign
               v-bank  =  buf_fin-bank.bank-name
               v-schet =  buf_fin-schet.r-schet
            .
      END.
      FIND FIRST buf_fin-bank-attr
           where buf_fin-bank-attr.host-code  = v-host-code
             and buf_fin-bank-attr.code-bank  = buf_fin-schet.code-bank
             and buf_fin-bank-attr.attr-code  = "collect-debt":U
           no-lock
          no-error
          .
      IF AVAILABLE buf_fin-bank-attr
      THEN DO:
         assign
            v-collect = buf_fin-bank-attr.attr-value
         .
      end.
    END.
    run vedwthxl-write-cell-data in this-procedure (
          input "экз1_date1":U
        , input buf_wth-doc.doc-date
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input "экз1_date2":U
        , input buf_wth-doc.doc-date
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input "экз1_from":U
        , input v-object
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input "экз1_to":U
        , input v-firm
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input "экз1_bank_to":U
        , input v-bank
    ).
    FIND FIRST buf_tt-summ NO-ERROR.
    IF AVAILABLE buf_tt-summ
    THEN DO:
      run vedwthxl-write-cell-data in this-procedure (
            input "экз1_summ_1":U
         , input SUBSTITUTE( "&1 &2 &3 &4 (&5)"
                           , f-wp-qnty(TRUNCATE(buf_tt-summ.curr-summ, 0))
                           , buf_tt-summ.curr-abbr
                           , STRING(TRUNCATE((buf_tt-summ.curr-summ - TRUNCATE(buf_tt-summ.curr-summ, 0)) * 100, 0), "99")
                           , buf_tt-summ.part-abbr
                           , buf_tt-summ.okv-code
                           )
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input "экз1_summ_3":U
         , input STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input "экз1_summ_5":U
         , input STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input "экз1_symb_5":U
         , input "02"
      ).
    END.
    FIND NEXT buf_tt-summ no-error.
    IF AVAILABLE buf_tt-summ
    THEN DO:
      run vedwthxl-write-cell-data in this-procedure (
            input "экз1_summ_2":U
         , input SUBSTITUTE( "&1 &2 &3 &4 (&5)"
                           , f-wp-qnty(TRUNCATE(buf_tt-summ.curr-summ, 0))
                           , buf_tt-summ.curr-abbr
                           , STRING(TRUNCATE((buf_tt-summ.curr-summ - TRUNCATE(buf_tt-summ.curr-summ, 0)) * 100, 0), "99")
                           , buf_tt-summ.part-abbr
                           , buf_tt-summ.okv-code
                           )
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input "экз1_summ_4":U
         , input  STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input "экз1_summ_6":U
         , input  STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input "экз1_symb_6":U
         , input "02"
      ).
    END.
    run vedwthxl-write-cell-data in this-procedure (
          input "экз1_account_dbt":U
        , input v-collect
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input "экз1_account_krd":U
        , input v-schet
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input "экз2_date1":U
        , input buf_wth-doc.doc-date
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input "экз2_date2":U
        , input buf_wth-doc.doc-date
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input "экз2_from":U
        , input v-object
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input "экз2_to":U
        , input v-firm
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input "экз2_bank_to":U
        , input v-bank
    ).
    FIND FIRST buf_tt-summ no-error.
    IF AVAILABLE buf_tt-summ
    THEN DO:
      run vedwthxl-write-cell-data in this-procedure (
            input "экз2_summ_1":U
         , input SUBSTITUTE( "&1 &2 &3 &4 (&5)"
                           , f-wp-qnty(TRUNCATE(buf_tt-summ.curr-summ, 0))
                           , buf_tt-summ.curr-abbr
                           , STRING(TRUNCATE((buf_tt-summ.curr-summ - TRUNCATE(buf_tt-summ.curr-summ, 0)) * 100, 0), "99")
                           , buf_tt-summ.part-abbr
                           , buf_tt-summ.okv-code
                           )
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input "экз2_summ_3":U
         , input STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input "экз2_summ_5":U
         , input STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input "экз2_symb_5":U
         , input "02"
      ).
    END.
    FIND NEXT buf_tt-summ  no-error.
    IF AVAILABLE buf_tt-summ
    THEN DO:
      run vedwthxl-write-cell-data in this-procedure (
            input "экз2_summ_2":U
         , input SUBSTITUTE( "&1 &2 &3 &4 (&5)"
                           , f-wp-qnty(TRUNCATE(buf_tt-summ.curr-summ, 0))
                           , buf_tt-summ.curr-abbr
                           , STRING(TRUNCATE((buf_tt-summ.curr-summ - TRUNCATE(buf_tt-summ.curr-summ, 0)) * 100, 0), "99")
                           , buf_tt-summ.part-abbr
                           , buf_tt-summ.okv-code
                           )
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input "экз2_summ_4":U
         , input  STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input "экз2_summ_6":U
         , input  STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input "экз2_symb_6":U
         , input "02"
      ).
    END.
    run vedwthxl-write-cell-data in this-procedure (
          input "экз2_account_dbt":U
        , input v-collect
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input "экз2_account_krd":U
        , input v-schet
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input "экз3_date1":U
        , input buf_wth-doc.doc-date
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input "экз3_from":U
        , input v-object
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input "экз3_to":U
        , input v-firm
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input "экз3_bank_to":U
        , input v-bank
    ).
    FIND FIRST buf_tt-summ no-error.
    IF AVAILABLE buf_tt-summ
    THEN DO:
      run vedwthxl-write-cell-data in this-procedure (
            input "экз3_summ_1":U
         , input SUBSTITUTE( "&1 &2 &3 &4 (&5)"
                           , f-wp-qnty(TRUNCATE(buf_tt-summ.curr-summ, 0))
                           , buf_tt-summ.curr-abbr
                           , STRING(TRUNCATE((buf_tt-summ.curr-summ - TRUNCATE(buf_tt-summ.curr-summ, 0)) * 100, 0), "99")
                           , buf_tt-summ.part-abbr
                           , buf_tt-summ.okv-code
                           )
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input "экз3_summ_3":U
         , input STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input "экз3_summ_5":U
         , input STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input "экз3_symb_5":U
         , input "02"
      ).
    END.
    FIND NEXT buf_tt-summ  no-error.
    IF AVAILABLE buf_tt-summ
    THEN DO:
      run vedwthxl-write-cell-data in this-procedure (
            input "экз3_summ_2":U
         , input SUBSTITUTE( "&1 &2 &3 &4 (&5)"
                           , f-wp-qnty(TRUNCATE(buf_tt-summ.curr-summ, 0))
                           , buf_tt-summ.curr-abbr
                           , STRING(TRUNCATE((buf_tt-summ.curr-summ - TRUNCATE(buf_tt-summ.curr-summ, 0)) * 100, 0), "99")
                           , buf_tt-summ.part-abbr
                           , buf_tt-summ.okv-code
                           )
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input "экз3_summ_4":U
         , input  STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input "экз3_summ_6":U
         , input  STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input "экз3_symb_6":U
         , input "02"
      ).
    END.
    run vedwthxl-write-cell-data in this-procedure (
          input "экз3_account_dbt":U
        , input v-collect
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input "экз3_account_krd":U
        , input v-schet
    ).
end.
end procedure.
procedure print-body :
do
on error undo, return error
:
   run vedwthxl-sheet1-write-line-data in this-procedure.
   run vedwthxl-sheet2-write-line-data in this-procedure.
end.
end procedure.
procedure print-footer :
do
on error undo, return error
:
end.
end procedure.
procedure close-stream :
do
on error undo, return error
:
if session :set-wait-state( "" ) then.
    run vedwthxl-close in this-procedure .
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 4 >= 8 then 2 else 0), 0, 0,
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
