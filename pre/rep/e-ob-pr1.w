def var vss-revision    as character no-undo init "$Revision$":u .
def var vss-author      as character no-undo init "$Author$":u .
def var vss-date        as character no-undo init "$Date$":u .
def var vss-workfile    as character no-undo init "$Workfile$":u .
def var vss-archive     as character no-undo init "$Archive$":u .
def var vss-description as character no-undo init "Задание колонок в отчете" .
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
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable gdsgrp_recids      as character no-undo.
define  shared variable fin-schet-recid    as character no-undo.
define  shared variable v-d-report-handle  as handle    no-undo .
define  shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define  shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define  shared temp-table tmp#grp no-undo
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
define  shared temp-table gds-list no-undo like ub.goods
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
define   shared  temp-table gds-list-hist no-undo
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
 shared
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
define  shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.
define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define   shared variable str1   as character  no-undo.
define   shared variable str2   as character  no-undo.
define   shared variable str3   as character  no-undo.
define   shared variable str4   as character  no-undo.
define   shared variable ReportNAme   as character  no-undo.
define   shared variable ReportProc   as character  no-undo.
define   shared variable ReportHeader as character  no-undo.
define   shared variable ReportPageWidth  as integer no-undo.
define   shared variable ReportPageHeight as integer no-undo.
define   shared variable ReportFontNum    as integer no-undo.
define   shared variable my-request as logical  init false no-undo.
define   shared variable v-delim as character no-undo .
define   shared variable v-sdate as character no-undo initial "/":U.
define   shared variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .
define   shared variable my-handle  as handle no-undo .
define   shared variable parent-handle  as handle no-undo .
define   shared variable v-show-all-goods as logical  no-undo .
define   shared variable params-only      as logical   no-undo .
define   shared variable params-only-mode as character no-undo .
define   shared variable place-call       as character no-undo .
define   shared variable x-Goods-Editor   as character  no-undo .
define   shared variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
define   shared variable x-Date-End       as date format "99/99/9999":u   no-undo .
define   shared variable x-Date-Start     as date format "99/99/9999":u   no-undo .
define   shared variable x-Shift-Alone    as integer format ">9":u         no-undo .
define   shared variable x-Shift-End      as integer format ">9":u         no-undo .
define   shared variable x-Shift-Start    as integer format ">9":u         no-undo .
define   shared variable x-SelectGood     as integer                      no-undo .
define   shared variable x-SelectObject   as character                          no-undo .
define   shared variable x-SET_PAY_TYPE   as integer  no-undo .
define   shared variable x-SET_val_TYPE   as integer  no-undo .
define   shared variable x-TOG-Shift      as logical  no-undo .
define   shared variable x-Radio-Task     as integer  no-undo .
define   shared variable x-TOG-Excel      as logical  no-undo .
define   shared variable x-TOG-list-hist  as logical  no-undo .
define   shared variable x-text-1 as character  no-undo .
define   shared variable x-text-2 as character  no-undo .
define   shared variable x-text-3 as character  no-undo .
define   shared variable x-text-4 as character  no-undo .
define   shared variable init-date-start  like x-date-start  no-undo .
define   shared variable init-date-end    like x-date-end    no-undo .
define   shared variable init-date-alone  like x-date-alone  no-undo .
define   shared variable init-shift-alone like x-shift-alone no-undo .
define   shared variable init-shift-start like x-shift-start no-undo .
define   shared variable init-shift-end   like x-shift-end   no-undo .
define   shared variable init-set_pay_type like x-set_pay_type   no-undo .
define   shared variable init-set_val_type like x-set_val_type   no-undo .
define   shared variable ref_date-start    as character   no-undo .
define   shared variable ref_date-end      as character   no-undo .
define   shared variable ref_date-alone    as character   no-undo .
define   shared work-table TDEDT  no-undo
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
define   shared variable str-obj-type as character  no-undo.
define   shared variable str-obj-code as character  no-undo.
define   shared variable str-obj-name as character  no-undo.
define   shared variable str-obj      as character  no-undo.
define   shared variable link#        as logical  no-undo init false.
define   shared variable  Verify-Arc-ot      as logical  no-undo init false.
define   shared variable  Verify-Arc-stk     as logical  no-undo init false.
define   shared variable  Verify-Arc-supp    as logical  no-undo init false.
define   shared variable  Verify-Arc-hold    as logical  no-undo init false.
define   shared variable  Verify-Arc-aht     as logical  no-undo init false.
define   shared variable  Verify-send-check  as logical  no-undo init false.
define   shared variable  Verify-Arc-fin     as logical  no-undo init false.
define   shared variable  Verify-Arc-strong  as logical  no-undo init false.
define   shared variable  Show-Crsa         as logical  no-undo init false.
define   shared variable  Show-Cost         as logical  no-undo init false.
define   shared variable  Show-Sale         as logical  no-undo init false.
define   shared variable  Name-Sale-price   as character no-undo .
define   shared variable  Format-Folder     as logical no-undo .
define   shared variable  Print-List-Hist   as logical no-undo init false.
define   shared variable Make-Excel     as logical  no-undo init false.
define   shared variable Make-Excel-com as logical  no-undo init false.
define   shared stream ForExcel.
define   shared variable Use-column   as logical extent 256 no-undo .
define   shared variable right-column as logical extent 256 no-undo .
define shared  temp-table Sheetf no-undo
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
find first sheetf where sheet-num = 1 no-error.
define variable l-stroka as character no-undo .
define   shared  variable ch#ExcelApplication as com-handle no-undo .
define   shared  variable ch#Workbook         as com-handle no-undo .
define   shared  variable ch#Worksheet        as com-handle no-undo .
define   shared  variable Num#Str#            as integer no-undo.
define   shared  variable Number-List         as integer no-undo init 1.
define   shared  variable v-excel-file        as character no-undo .
define variable Col-name as character  extent 256.
define variable Col-format as character  extent 256.
define variable Col-Post-format as character  extent 256.
run proc-page0-assign in this-procedure .
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable var-report-r-b as character no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
  DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
  ASSIGN parParentProc =  my-handle .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var Log-Res1     as  log            no-undo.
def var Log-Res2     as  log            no-undo.
define variable ii as integer   no-undo .
DEFINE BUTTON b-help
     LABEL "&Помощь":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-exit
     LABEL "&Сохранить":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 35.5 BY 1.25.
DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 37.38 BY 1.25.
DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 73.5 BY 2.5
     BGCOLOR 8 FGCOLOR 0 .
DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 73.5 BY 3.75.
DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 73.5 BY 1.54.
DEFINE VARIABLE BenCostSum AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3.5 BY .75 NO-UNDO.
DEFINE VARIABLE BenQnty AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .75 NO-UNDO.
DEFINE VARIABLE BenSaleSum AS LOGICAL INITIAL no
     LABEL "(-скидки)"
     VIEW-AS TOGGLE-BOX
     SIZE 11.25 BY .75 NO-UNDO.
DEFINE VARIABLE DiscntSum AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .75 NO-UNDO.
DEFINE VARIABLE Effect AS LOGICAL INITIAL no
     LABEL "Эффективность":L
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY .75 NO-UNDO.
DEFINE VARIABLE InExtCostSum AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY .75 NO-UNDO.
DEFINE VARIABLE InExtQnty AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .75 NO-UNDO.
DEFINE VARIABLE OutExtCostSum AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY .75 NO-UNDO.
DEFINE VARIABLE OutExtDiscntPC AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3.5 BY .75 NO-UNDO.
DEFINE VARIABLE OutExtDiscntSum AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 3.5 BY .75 NO-UNDO.
DEFINE VARIABLE OutExtQnty AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .75 NO-UNDO.
DEFINE VARIABLE OutExtSaleSum AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY .75 NO-UNDO.
DEFINE VARIABLE PC-DiscntSum AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3.5 BY .75 NO-UNDO.
DEFINE VARIABLE RetOutCostSum AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 5 BY .75 NO-UNDO.
DEFINE VARIABLE RetOutDiscntPC AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3.5 BY .75 NO-UNDO.
DEFINE VARIABLE RetOutDiscntSum AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .75 NO-UNDO.
DEFINE VARIABLE RetOutQnty AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY .75 NO-UNDO.
DEFINE VARIABLE RetOutSaleSum AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY .75 NO-UNDO.
DEFINE VARIABLE RetPostCostSum AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 5 BY .75 NO-UNDO.
DEFINE VARIABLE RetPostQnty AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .75 NO-UNDO.
DEFINE VARIABLE SpiCostSum AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY .75 NO-UNDO.
DEFINE VARIABLE SpiQnty AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY .75 NO-UNDO.
DEFINE VARIABLE SpiSaleSum AS LOGICAL INITIAL no
     LABEL "":L
     VIEW-AS TOGGLE-BOX
     SIZE 4.5 BY .75 NO-UNDO.
DEFINE VARIABLE UpFact AS LOGICAL INITIAL no
     LABEL "% факт. наценки":L
     VIEW-AS TOGGLE-BOX
     SIZE 18 BY .75 NO-UNDO.
DEFINE VARIABLE Zen-posr AS LOGICAL INITIAL no
     LABEL "Использ. цен посред. вместо учет.":L
     VIEW-AS TOGGLE-BOX
     SIZE 34.88 BY .75 NO-UNDO.
DEFINE FRAME DLGOKCAN
     B-quit AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     b-help AT ROW 1 COL 61
     InExtQnty AT ROW 4.96 COL 25.5
     InExtCostSum AT ROW 4.96 COL 36
     RetPostQnty AT ROW 6.21 COL 25.5
     RetPostCostSum AT ROW 6.21 COL 36
     OutExtQnty AT ROW 7.46 COL 25.5
     OutExtCostSum AT ROW 7.46 COL 36
     OutExtSaleSum AT ROW 7.46 COL 47.5
     OutExtDiscntSum AT ROW 7.46 COL 59.5
     OutExtDiscntPC AT ROW 7.46 COL 70
     RetOutQnty AT ROW 8.71 COL 25.5
     RetOutCostSum AT ROW 8.71 COL 36
     RetOutSaleSum AT ROW 8.71 COL 47.5
     RetOutDiscntSum AT ROW 8.71 COL 59.5
     RetOutDiscntPC AT ROW 8.71 COL 70
     BenQnty AT ROW 9.96 COL 25.5
     BenCostSum AT ROW 9.96 COL 36
     BenSaleSum AT ROW 9.96 COL 47.5
     DiscntSum AT ROW 9.96 COL 59.5
     PC-DiscntSum AT ROW 9.96 COL 70
     SpiQnty AT ROW 11.33 COL 25.38
     SpiCostSum AT ROW 11.33 COL 35.88
     SpiSaleSum AT ROW 11.33 COL 47.38
     Effect AT ROW 13 COL 2.88
     UpFact AT ROW 13 COL 19.13
     Zen-posr AT ROW 13 COL 40
     "Списание" VIEW-AS TEXT
          SIZE 9.5 BY .75 AT ROW 11.33 COL 3.88
          FGCOLOR 4
     "Кол-во" VIEW-AS TEXT
          SIZE 6.5 BY .75 AT ROW 2.71 COL 23.5
          FGCOLOR 0
     "~"Расход~" - ~"Возврат~"" VIEW-AS TEXT
          SIZE 20.25 BY .75 AT ROW 9.96 COL 4
          BGCOLOR 8 FGCOLOR 4
     "Возврат внешний" VIEW-AS TEXT
          SIZE 15.5 BY .75 AT ROW 8.71 COL 4
          FGCOLOR 4
     "Расход внешний" VIEW-AS TEXT
          SIZE 14.5 BY .75 AT ROW 7.46 COL 4
          FGCOLOR 4
     "Процент" VIEW-AS TEXT
          SIZE 8.5 BY .75 AT ROW 2.71 COL 67.5
     "Возврат поставщику" VIEW-AS TEXT
          SIZE 18 BY .75 AT ROW 6.21 COL 4
          FGCOLOR 4
     "Приход внешний" VIEW-AS TEXT
          SIZE 15 BY .75 AT ROW 4.96 COL 4
          FGCOLOR 4
     "скидок" VIEW-AS TEXT
          SIZE 7.5 BY .75 AT ROW 3.71 COL 57.5
     "скидок" VIEW-AS TEXT
          SIZE 7 BY .75 AT ROW 3.71 COL 68
     "прод. цен" VIEW-AS TEXT
          SIZE 9.75 BY .75 AT ROW 3.71 COL 45
     "учет. цен" VIEW-AS TEXT
          SIZE 9.5 BY .75 AT ROW 3.71 COL 33
     "Сумма" VIEW-AS TEXT
          SIZE 6.5 BY .75 AT ROW 2.71 COL 57.5
          FGCOLOR 0
     "Сумма" VIEW-AS TEXT
          SIZE 6 BY .75 AT ROW 2.71 COL 46
          FGCOLOR 0
     "Сумма" VIEW-AS TEXT
          SIZE 6.5 BY .75 AT ROW 2.71 COL 34
          FGCOLOR 0
     RECT-10 AT ROW 12.75 COL 1.88
     RECT-11 AT ROW 12.75 COL 38
     RECT-7 AT ROW 4.71 COL 2
     RECT-8 AT ROW 7.21 COL 2
     RECT-9 AT ROW 10.96 COL 2
     SPACE(0.99) SKIP(1.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE BGCOLOR 8 FGCOLOR 0 "Параметры по типам документов":L
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.
ASSIGN
       FRAME DLGOKCAN:SCROLLABLE       = FALSE.
ON CHOOSE OF B-quit IN FRAME DLGOKCAN
DO:
    return "NO" .
END.
ON CHOOSE OF B-exit IN FRAME DLGOKCAN
DO:
    do ii = 1 to 25 :  Assign  use-column[ii] = no . end.
    if InExtQnty:screen-value = "yes" then       assign  use-column[1] = TRUE    .
    if InExtCostSum:screen-value = "yes" then    assign  use-column[2] = TRUE    .
    if RetPostQnty:screen-value = "yes" then     assign  use-column[3] = TRUE    .
    if RetPostCostSum:screen-value = "yes" then  assign  use-column[4] = TRUE    .
    if OutExtQnty:screen-value = "yes" then      assign  use-column[5] = TRUE    .
    if OutExtCostSum:screen-value = "yes" then   assign  use-column[6] = TRUE    .
    if OutExtSaleSum:screen-value = "yes" then   assign  use-column[7] = TRUE    .
    if OutExtDiscntSum:screen-value = "yes" then assign  use-column[8] = TRUE    .
    if OutExtDiscntPC:screen-value = "yes" then  assign  use-column[9] = TRUE    .
    if RetOutQnty:screen-value = "yes" then      assign  use-column[10] = TRUE   .
    if RetOutCostSum:screen-value = "yes" then   assign  use-column[11] = TRUE   .
    if RetOutSaleSum:screen-value = "yes" then   assign  use-column[12] = TRUE   .
    if RetOutDiscntSum:screen-value = "yes" then assign  use-column[13] = TRUE   .
    if RetOutDiscntPC:screen-value = "yes" then  assign  use-column[14] = TRUE   .
    if BenQnty:screen-value = "yes" then         assign  use-column[15] = TRUE   .
    if BenCostSum:screen-value = "yes" then      assign  use-column[16] = TRUE   .
    if BenSaleSum:screen-value = "yes" then      assign  use-column[17] = TRUE   .
    if DiscntSum:screen-value = "yes" then       assign  use-column[18] = TRUE   .
    if PC-DiscntSum:screen-value = "yes" then    assign  use-column[19] = TRUE   .
    if SpiQnty:screen-value = "yes" then         assign  use-column[20] = TRUE   .
    if SpiCostSum:screen-value = "yes" then      assign  use-column[21] = TRUE   .
    if SpiSaleSum:screen-value = "yes" then      assign  use-column[22] = TRUE   .
    if Effect:screen-value = "yes" then          assign  use-column[23] = TRUE   .
    if UpFact:screen-value = "yes" then          assign  use-column[24] = TRUE   .
    if Zen-posr:screen-value = "yes" then        assign  use-column[25] = TRUE   .
   find first ubflt.usr-flt share-lock  where ubflt.usr-flt.user-name  = v-cntxt-userid and ubflt.usr-flt.call-point = "e-ob-prd":U no-error .
   if NOT avail ubflt.usr-flt then  create ubflt.usr-flt.
   define variable l-ind as integer   no-undo .
   Assign
     ubflt.usr-flt.user-name = v-cntxt-userid
     ubflt.usr-flt.call-point   = "e-ob-prd":U
     ubflt.usr-flt.list_ = ""
   .
   repeat l-ind = 1 to 25 :
     if   use-column[ l-ind ] =  true then ubflt.usr-flt.list_ = ubflt.usr-flt.list_  + string( l-ind ) + "," .
   End.
   apply "go" to frame DLGOKCAN.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME DLGOKCAN:PARENT eq ?
THEN FRAME DLGOKCAN:PARENT = ACTIVE-WINDOW.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame DLGOKCAN
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
on choose of b-help in frame DLGOKCAN
do:
  apply "help":u to frame DLGOKCAN .
end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame DLGOKCAN:width - 0.3
                fh            = frame DLGOKCAN:first-child
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
ON WINDOW-CLOSE OF FRAME DLGOKCAN APPLY "END-ERROR":U TO SELF.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    if session:set-wait-state("COMPILER") then.
    assign
        InExtQnty = use-column[1]
        InExtCostSum = use-column[2]
        RetPostQnty = use-column[3]
        RetPostCostSum = use-column[4]
        OutExtQnty = use-column[5]
        OutExtCostSum = use-column[6]
        OutExtSaleSum = use-column[7]
        OutExtDiscntSum = use-column[8]
        OutExtDiscntPC = use-column[9]
        RetOutQnty = use-column[10]
        RetOutCostSum = use-column[11]
        RetOutSaleSum = use-column[12]
        RetOutDiscntSum = use-column[13]
        RetOutDiscntPC= use-column[14]
        BenQnty = use-column[15]
        BenCostSum = use-column[16]
        BenSaleSum = use-column[17]
        DiscntSum = use-column[18]
        PC-DiscntSum = use-column[19]
        SpiQnty = use-column[20]
        SpiCostSum = use-column[21]
        SpiSaleSum = use-column[22]
        Effect = use-column[23]
        UpFact = use-column[24]
        Zen-posr = use-column[25]
    .
    RUN enable_UI.
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_document-reports-cost_print':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output Log-Res1
    )  .
end.
    if not Log-Res1 then DISABLE InExtCostSum OutExtCostSum  RetOutCostSum  SpiCostSum  RetPostCostSum  BenCostSum Effect UpFact WITH FRAME DLGOKCAN.
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_document-reports-sale_print':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output Log-Res2
    )  .
end.
    if not Log-Res2 then
        DISABLE InExtQnty OutExtQnty OutExtSaleSum OutExtDiscntSum  RetOutQnty RetOutSaleSum RetOutDiscntSum SpiQnty
           SpiSaleSum RetPostQnty DiscntSum  OutExtDiscntPC RetOutDiscntPC PC-DiscntSum BenQnty BenSaleSum WITH FRAME DLGOKCAN .
    if not ( Log-Res1 OR Log-Res2 ) then do:
      message   "У Вас недостаточно прав для" skip
                "выполнения данного действия." skip
                "Обратитесь к администратору" skip
                "системы." view-as alert-box error.
      LEAVE MAIN-BLOCK .
    end.
    find first sysconf where sysconf.avrg-price = yes no-lock no-error .
    if available sysconf then ENABLE  Zen-posr WITH FRAME DLGOKCAN .
    else do:
      assign
        Zen-posr = no
        use-column[25] = no
      .
      DISABLE Zen-posr WITH FRAME DLGOKCAN .
      DISPLAY Zen-posr WITH FRAME DLGOKCAN .
    end.
    WAIT-FOR GO OF FRAME DLGOKCAN.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME DLGOKCAN.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY InExtQnty InExtCostSum RetPostQnty RetPostCostSum OutExtQnty
          OutExtCostSum OutExtSaleSum OutExtDiscntSum OutExtDiscntPC RetOutQnty
          RetOutCostSum RetOutSaleSum RetOutDiscntSum RetOutDiscntPC BenQnty
          BenCostSum BenSaleSum DiscntSum PC-DiscntSum SpiQnty SpiCostSum
          SpiSaleSum Effect UpFact Zen-posr
      WITH FRAME DLGOKCAN.
  ENABLE B-quit B-exit b-help RECT-10 RECT-11 RECT-7 RECT-8 RECT-9
         InExtQnty InExtCostSum RetPostQnty RetPostCostSum OutExtQnty
         OutExtCostSum OutExtSaleSum OutExtDiscntSum OutExtDiscntPC RetOutQnty
         RetOutCostSum RetOutSaleSum RetOutDiscntSum RetOutDiscntPC BenQnty
         BenCostSum BenSaleSum DiscntSum PC-DiscntSum SpiQnty SpiCostSum
         SpiSaleSum Effect UpFact Zen-posr
      WITH FRAME DLGOKCAN.
END PROCEDURE.
