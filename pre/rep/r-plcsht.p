block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 0ec5d11e52eb, 2015, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Sep 18 21:05:06 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-plcsht.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-plcsht.p $":U .
define variable vss-description as character no-undo init "Показания уровнемера за смену".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable var-report-r-b as character no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure lineattr-value :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value    like ub.doc-line-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value =  buf_doc-line-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure lineattr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value    like ub.doc-line-attr.attr-value no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code = p-gds-code
        buf_doc-line-attr.attr-code = p-code
      .
    end.
    assign
      buf_doc-line-attr.attr-value = p-value
    .
     release buf_doc-line-attr.
  end.
end procedure.
procedure lineattr-exist :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if  available buf_doc-line-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure lineattr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_doc-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_doc-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure lineattr-code :
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
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'parts_price-sale':U then do:     assign     p-label          = "Продажная цена партии"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Продажная цена партии"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'fl_gds-code':U then do:     assign     p-label          = "Количество по букету"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Количество по букету"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'old_other-ras':U then do:     assign     p-label          = " Первым способом из ПН Сумма дополнительных расходов по строке rubl base"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = " Первым способом из ПН Сумма дополнительных расходов по строке rubl base"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'new_other-ras':U then do:     assign     p-label          = " Способом из ДопРасх Сумма дополнительных расходов по строке rubl base"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = " Способом из ДопРасх Сумма дополнительных расходов по строке rubl base"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'flora_ps':U then do:     assign     p-label          = "Описание не товарной позиции"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Описание не товарной позиции"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'country-code':U then do:     assign     p-label          = "Страна"     p-type           = 'I':U      p-format         = "->>>>>>>>9"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Страна"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'add-line-cli':U then do:     assign     p-label          = "Курс . шкала . сумма . НДС "     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Курс . шкала . сумма . НДС "     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'corr-price-sale':U then do:     assign     p-label          = "Продажная цена в строке ПН"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Продажная цена в строке ПН"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'reason-code':U then do:     assign     p-label          = "Причина отклонения"     p-type           = 'I':U      p-format         = "->>>>>>>>9"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Причина отклонения"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'price-prod':U then do:     assign     p-label          = "Цена производителя Без НДС"     p-type           = 'D':U      p-format         = ">>>>>>>>9.99"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Цена производителя Без НДС"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'price-prodvat':U then do:     assign     p-label          = "Цена производителя c НДС"     p-type           = 'D':U      p-format         = ">>>>>>>>9.99"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Цена производителя c НДС"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут строки документа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure lineattr-value-flora-gds :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input  parameter p-bk-gds-code like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-code        like  ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value       as    decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code  + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value = decimal( buf_doc-line-attr.attr-value)
      .
    end.
    else do:
      assign
        p-value = 0
      .
    end.
  end.
end procedure.
procedure lineattr-write-flora-gds :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-prt-code    as integer   no-undo .
    define input parameter p-bk-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value    as decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(44)  + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = p-code  + chr(44)  + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value = string( p-value )
    .
  end.
end procedure.
procedure lineattr-delete-flora-gds :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input parameter p-bk-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error NO-WAIT.
    if not available buf_doc-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_doc-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure lineattr-delete-flora-all :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    for each buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code begins 'fl_gds-code':U + chr(44) + string(p-prt-code)  + chr(44)
     :
      delete buf_doc-line-attr.
    end.
 end.
end procedure.
procedure lineattr-exist-flora-gds :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input  parameter p-bk-gds-code like  ub.doc-line-attr.gds-code   no-undo .
    define output parameter p-exist as logical   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    p-exist = false .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'fl_gds-code':U  + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
       p-exist = true
      .
    end.
  end.
end procedure.
procedure lineattr-write-add-line-cli :
define input  parameter p-doc-code      like  ub.doc-line-attr.doc-code   no-undo .
define input  parameter p-gds-code      like  ub.doc-line-attr.gds-code   no-undo .
define input  parameter p-cli-type      as character no-undo .
define input  parameter p-cli-code      as integer   no-undo .
define input  parameter p-contract-code as integer   no-undo .
define input  parameter p-host-code     as integer   no-undo .
define input  parameter p-exch-code     as integer   no-undo .
define input  parameter p-exch-rate     as decimal   no-undo .
define input  parameter p-exch-scale    as integer   no-undo .
define input  parameter p-sum-cli       as decimal   no-undo .
define input  parameter p-sum-vat       as decimal   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'add-line-cli':U +
                                          chr(4) + p-cli-type +
                                          chr(4) + string(p-cli-code) +
                                          chr(4) + string(p-contract-code) +
                                          chr(4) + string(p-host-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = 'add-line-cli':U  +
                                      chr(4) + p-cli-type +
                                      chr(4) + string(p-cli-code) +
                                      chr(4) + string(p-contract-code) +
                                      chr(4) + string(p-host-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value =
      string(p-exch-code)  + chr(4) +
      string(p-exch-rate)  + chr(4) +
      string(p-exch-scale) + chr(4) +
      string(p-sum-cli)    + chr(4) +
      string(p-sum-vat)
      .
  end.
end procedure.
procedure lineattr-value-add-line-cli :
define input   parameter p-doc-code      like  ub.doc-line-attr.doc-code   no-undo .
define input   parameter p-gds-code      like  ub.doc-line-attr.gds-code   no-undo .
define input   parameter p-cli-type      as character no-undo .
define input   parameter p-cli-code      as integer   no-undo .
define input   parameter p-contract-code as integer   no-undo .
define input   parameter p-host-code     as integer   no-undo .
define output  parameter p-exch-code     as integer   no-undo .
define output  parameter p-exch-rate     as decimal   no-undo .
define output  parameter p-exch-scale    as integer   no-undo .
define output  parameter p-sum-cli       as decimal   no-undo .
define output  parameter p-sum-vat       as decimal   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'add-line-cli':U +
                                          chr(4) + p-cli-type +
                                          chr(4) + string(p-cli-code) +
                                          chr(4) + string(p-contract-code) +
                                          chr(4) + string(p-host-code)
      no-error .
    if available buf_doc-line-attr then do:
     assign
        p-exch-code  = integer ( entry (1 , buf_doc-line-attr.attr-value,  chr(4) ))
        p-exch-rate  = decimal ( entry (2 , buf_doc-line-attr.attr-value, chr(4) ))
        p-exch-scale = integer ( entry (3 , buf_doc-line-attr.attr-value, chr(4) ))
        p-sum-cli    = decimal ( entry (4 , buf_doc-line-attr.attr-value, chr(4) ))
        p-sum-vat    = decimal ( entry (5 , buf_doc-line-attr.attr-value, chr(4) ))
       .
     end.
  end.
end procedure.
function lineattr-get-reason returns character ( buffer local-doc-line for ub.doc-line ) :
  define variable v-code as character no-undo .
  define variable v-type as character no-undo .
  define variable v-gds-code as integer   no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  local-doc-line.artic
  ,input  local-doc-line.prod-type
  ,input  local-doc-line.prod-code
  ,output v-gds-code
  )  .
  run lineattr-value (
      input   local-doc-line.doc-code ,
      input   v-gds-code              ,
      input   'reason-code':U ,
      output  v-code                  ,
      output  v-type ) .
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = integer ( v-code ) no-error.
  if not available ub.trn-reason then do:
     return "" .
  end.
  else do:
     return ub.trn-reason.reason-name .
  end.
end function.
procedure lineattr-value-parts :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-part-code   as character no-undo .
    define input  parameter p_in-code     as character no-undo .
    define input  parameter p-code        like  ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value       as    decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code  + chr(4) + trim(p-part-code)  + chr(4) + trim(p_in-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value = decimal( buf_doc-line-attr.attr-value)
      .
    end.
    else do:
      assign
        p-value = 0
      .
    end.
  end.
end procedure.
procedure lineattr-write-parts :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-part-code  as character no-undo .
    define input parameter p_in-code    as character no-undo .
    define input parameter p-code       like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value      as decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(4)  + trim(p-part-code)  + chr(4) + trim(p_in-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = p-code  + chr(4)  + trim(p-part-code)  + chr(4) + trim(p_in-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value = string( p-value )
    .
  end.
end procedure.
define variable g#report-num  as integer      no-undo .
def var vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define stream excel-line.
define stream excel-cell.
define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character
    index pi is primary unique data-key
.
define temp-table temp_sheet1_line-data no-undo
    field sheet-name          as character
    field xl-line-id          as integer
    field loc1                as character
    field state-measure-qnty  as character
    field state-level-total   as character
    field state-temperature   as character
    field state-dencity       as character
    field average-dencity     as character
    index pi is primary unique
        xl-line-id
.
define temp-table temp_sheet2_line-data no-undo
    field sheet-name           as character
    field xl-line-id           as integer
    field counter              as character
    field fact-date            as character
    field fact-time            as character
    field loc1                 as character
    field gds-name             as character
    field rvs-type-outside     as character
    field state-measure-qnty   as character
    field state-level-total    as character
    field state-temperature    as character
    field state-dencity        as character
    field attr_                as character
    index pi is primary unique
        xl-line-id
.
define variable v-r-plc-xl-sheet1-cur-data-row  as integer      no-undo.
define variable v-r-plc-xl-sheet2-cur-data-row  as integer      no-undo.
define variable v-r-plc-xl-cell-file-name       as character    no-undo.
define variable v-r-plc-xl-data-file-name       as character    no-undo.
procedure r-plc-xl-init :
do
on error undo, return error
:
    assign
        v-r-plc-xl-sheet1-cur-data-row = 0
        v-r-plc-xl-sheet2-cur-data-row = 0
    .
    run gbl/_tmpfile.p
        ( input "xd"
        , input ".txt"
        , output v-r-plc-xl-data-file-name
    ).
    output stream excel-line to value( v-r-plc-xl-data-file-name ).
    run gbl/_tmpfile.p
        ( input "xc"
        , input ".txt"
        , output v-r-plc-xl-cell-file-name
    ).
    output stream excel-cell to value( v-r-plc-xl-cell-file-name ).
    run r-plc-xl-write-cell-data in this-procedure (
          input "sheetList":U
        , input "Контроль,Сверки":U
    ).
    run r-plc-xl-write-cell-data in this-procedure (
          input "Контроль_valutCode":U
        , input "0":U
    ).
    run r-plc-xl-write-cell-data in this-procedure (
          input "Контроль_columnList":U
        , input "loc1,state_measure_qnty,state_level_total,state_temperature,state_dencity,average_dencity":U
    ).
    run r-plc-xl-write-cell-data in this-procedure (
          input "Контроль_columnType":U
        , input "S,S,S,S,S,S":U
    ).
    run r-plc-xl-write-cell-data in this-procedure (
          input "Контроль_subtotalList":U
        , input "":U
    ).
    run r-plc-xl-write-cell-data in this-procedure (
          input "Контроль_subtotalType":U
        , input "":U
    ).
    run r-plc-xl-write-cell-data in this-procedure (
          input "Сверки_valutCode":U
        , input "0":U
    ).
    run r-plc-xl-write-cell-data in this-procedure (
          input "Сверки_columnList":U
        , input "counter,fact_date,fact_time,loc1,gds_name,rvs_type_outside,state_measure_qnty,state_level_total,state_temperature,state_dencity,attr_":U
    ).
    run r-plc-xl-write-cell-data in this-procedure (
          input "Сверки_columnType":U
        , input "S,S,S,S,S,S,S,S,S,S,S,S":U
    ).
    run r-plc-xl-write-cell-data in this-procedure (
          input "Сверки_subtotalList":U
        , input "":U
    ).
    run r-plc-xl-write-cell-data in this-procedure (
          input "Сверки_subtotalType":U
        , input "":U
    ).
end.
end procedure.
procedure r-plc-xl-sheet1-write-line-data :
define input parameter p-loc1                 as character        no-undo.
define input parameter p-state-measure-qnty   as character        no-undo.
define input parameter p-state-level-total    as character        no-undo.
define input parameter p-state-temperature    as character        no-undo.
define input parameter p-state-dencity        as character        no-undo.
define input parameter p-average-dencity      as character        no-undo.
define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    for each buf_temp_sheet1_line-data
    :
        delete buf_temp_sheet1_line-data.
    end.
    create buf_temp_sheet1_line-data.
    assign
        v-r-plc-xl-sheet1-cur-data-row = v-r-plc-xl-sheet1-cur-data-row + 1
    .
    assign
        buf_temp_sheet1_line-data.sheet-name          = "Контроль":U
        buf_temp_sheet1_line-data.xl-line-id          = v-r-plc-xl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.loc1                = p-loc1
        buf_temp_sheet1_line-data.state-measure-qnty  = p-state-measure-qnty
        buf_temp_sheet1_line-data.state-level-total   = p-state-level-total
        buf_temp_sheet1_line-data.state-temperature   = p-state-temperature
        buf_temp_sheet1_line-data.state-dencity       = p-state-dencity
        buf_temp_sheet1_line-data.average-dencity     = p-average-dencity
    .
    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        CHR(9)   "LD":U
        CHR(9)   buf_temp_sheet1_line-data.loc1
        CHR(9)   buf_temp_sheet1_line-data.state-measure-qnty
        CHR(9)   buf_temp_sheet1_line-data.state-level-total
        CHR(9)   buf_temp_sheet1_line-data.state-temperature
        CHR(9)   buf_temp_sheet1_line-data.state-dencity
        CHR(9)   buf_temp_sheet1_line-data.average-dencity
        chr(10)
    .
end.
end procedure.
procedure r-plc-xl-sheet2-write-line-data :
define input parameter p-counter               as character        no-undo.
define input parameter p-fact-date             as character        no-undo.
define input parameter p-fact-time             as character        no-undo.
define input parameter p-loc1                  as character        no-undo.
define input parameter p-gds-name              as character        no-undo.
define input parameter p-rvs-type-outside      as character        no-undo.
define input parameter p-state-measure-qnty    as character        no-undo.
define input parameter p-state-level-total     as character        no-undo.
define input parameter p-state-temperature     as character        no-undo.
define input parameter p-state-dencity         as character        no-undo.
define input parameter p-attr_                 as character        no-undo.
    define buffer buf_temp_sheet2_line-data        for temp_sheet2_line-data.
do
for buf_temp_sheet2_line-data
on error undo, return error
:
    for each buf_temp_sheet2_line-data
    :
        delete buf_temp_sheet2_line-data.
    end.
    create buf_temp_sheet2_line-data.
    assign
        v-r-plc-xl-sheet2-cur-data-row = v-r-plc-xl-sheet2-cur-data-row + 1
    .
    assign
        buf_temp_sheet2_line-data.sheet-name          = "Сверки":U
        buf_temp_sheet2_line-data.xl-line-id          = v-r-plc-xl-sheet2-cur-data-row
        buf_temp_sheet2_line-data.counter             = p-counter
        buf_temp_sheet2_line-data.fact-date           = p-fact-date
        buf_temp_sheet2_line-data.fact-time           = p-fact-time
        buf_temp_sheet2_line-data.loc1                = p-loc1
        buf_temp_sheet2_line-data.gds-name            = p-gds-name
        buf_temp_sheet2_line-data.rvs-type-outside    = p-rvs-type-outside
        buf_temp_sheet2_line-data.state-measure-qnty  = p-state-measure-qnty
        buf_temp_sheet2_line-data.state-level-total   = p-state-level-total
        buf_temp_sheet2_line-data.state-temperature   = p-state-temperature
        buf_temp_sheet2_line-data.state-dencity       = p-state-dencity
        buf_temp_sheet2_line-data.attr_               = p-attr_
    .
    put stream excel-line unformatted
                        buf_temp_sheet2_line-data.sheet-name
        CHR(9)   "LD":U
        CHR(9)   buf_temp_sheet2_line-data.counter
        CHR(9)   buf_temp_sheet2_line-data.fact-date
        CHR(9)   buf_temp_sheet2_line-data.fact-time
        CHR(9)   buf_temp_sheet2_line-data.loc1
        CHR(9)   buf_temp_sheet2_line-data.gds-name
        CHR(9)   buf_temp_sheet2_line-data.rvs-type-outside
        CHR(9)   buf_temp_sheet2_line-data.state-measure-qnty
        CHR(9)   buf_temp_sheet2_line-data.state-level-total
        CHR(9)   buf_temp_sheet2_line-data.state-temperature
        CHR(9)   buf_temp_sheet2_line-data.state-dencity
        CHR(9)   buf_temp_sheet2_line-data.attr_
        chr(10)
    .
end.
end procedure.
procedure r-plc-xl-write-cell-data :
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
procedure r-plc-xl-run-excel :
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
        v-template-file-name    = search( "exe/plcsht.xlt" )
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
procedure r-plc-xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/plcsht.xlt":U.
        export "exe/t_form.bas":U.
        export v-r-plc-xl-cell-file-name.
        export v-r-plc-xl-data-file-name.
    output close.
end.
end procedure.
define temp-table tt-doc no-undo
  field rvs-code           like ub.rvs-line.rvs-code
  FIELD obj-type           like ub.rvs-line.obj-type
  FIELD obj-code           like ub.rvs-line.obj-code
  field pl-code            like ub.rvs-line.pl-code
  field gds-code           like ub.rvs-line.gds-code
  FIELD shift-date         like ub.rvs-doc.shift-date
  FIELD shift-num          like ub.rvs-doc.shift-num
  FIELD status_            like ub.rvs-doc.status_
  FIELD fact-order         like ub.rvs-doc.fact-order
  field loc1               like ub.place.loc1
  field state-measure-qnty like ub.rvs-line.state-measure-qnty
  field state-temperature  like ub.rvs-line.state-temperature
  field state-dencity      like ub.rvs-line.state-density
  field average-dencity    as decimal format ">9.9999"
  FIELD fact-date          like ub.rvs-doc.fact-date
  FIELD fact-time          as character
  field gds-name           like ub.goods.gds-name
  field rvs-type           like ub.rvs-doc.rvs-type
  field rvs-type-outside   like ub.rvs-doc.rvs-type
  field state-level-total  like ub.rvs-line.state-level-total
  field attr_              as character
index by-line as primary unique
      rvs-code
      obj-type
      obj-code
      pl-code
      gds-code
index by-type
      rvs-type
      loc1
      gds-code
index by-date
      rvs-type
      fact-date
      fact-time
      loc1
      gds-name
index by-pl
      pl-code
      gds-code
.
  output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
  output close.
define variable v-counter    as integer  FORMAT ">>9"    no-undo.
define variable v-fact-order-start        as decimal              no-undo .
define variable v-fact-order-end          as decimal              no-undo .
DEFINE VARIABLE sym1  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym2  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym3  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym4  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym5  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym6  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym7  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym8  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym9  AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym10 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym11 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
DEFINE VARIABLE sym12 AS CHARACTER NO-UNDO FORMAT "x(1)":U INITIAL "|":U .
define variable v-line    as character    no-undo.
define variable v-date-begin       as character          no-undo.
define variable v-date-end         as character          no-undo.
define variable v-shift-staff      as character    no-undo.
define variable v-shift-staff-prev as character    no-undo.
define variable v-date-rvs-shift   as character     no-undo.
define variable v-time-rvs-shift   as character     no-undo.
DEFINE STREAM out-stream.
  define frame f-first
    sym1                      no-label format "X(1)"       space(0)
    tt-doc.loc1               no-label format "X(8)"       space(0)
    sym2                      no-label format "X(1)"       space(0)
    tt-doc.state-measure-qnty no-label format "->>,>>9.99" space(0)
    sym3                      no-label format "X(1)"       space(0)
    tt-doc.state-level-total  no-label format "->>>9.99"   space(0)
    sym4                      no-label format "X(1)"       space(0)
    tt-doc.state-temperature  no-label format "->>9.99"    space(0)
    sym5                      no-label format "X(1)"       space(0)
    tt-doc.state-dencity      no-label format ">9.9999"    space(0)
    sym6                      no-label format "X(1)"       space(0)
    tt-doc.average-dencity    no-label format ">9.9999"    space(0)
    sym7                      no-label format "X(1)"       space(0)
  header
    "+--------+----------+--------+-------+-------+-------+" skip
    "|    №   |  объем   | высота | темпе | Плот- | Плот- |" skip
    "| резер- |   (л)    | взлива | рату- | ность | ность |" skip
    "| вуара  |          |  (см)  | ра    |       | сред- |" skip
    "|        |          |        |  (С)  |       | няя   |" skip
  with width 54 down stream-io no-labels no-box.
  define frame f-second
    sym1                      no-label format "X(1)"       space(0)
    v-counter                 no-label format ">>9"        space(0)
    sym2                      no-label format "X(1)"       space(0)
    tt-doc.fact-date          no-label format "99/99/99"   space(0)
    sym3                      no-label format "X(1)"       space(0)
    tt-doc.fact-time          no-label format "X(8)"       space(0)
    sym4                      no-label format "X(1)"       space(0)
    tt-doc.loc1               no-label format "x(8)"       space(0)
    sym5                      no-label format "X(1)"       space(0)
    tt-doc.gds-name           no-label format "x(10)"      space(0)
    sym6                      no-label format "X(1)"       space(0)
    tt-doc.rvs-type-outside   no-label format "x(10)"      space(0)
    sym7                      no-label format "X(1)"       space(0)
    tt-doc.state-measure-qnty no-label format "->>,>>9.99" space(0)
    sym8                      no-label format "X(1)"       space(0)
    tt-doc.state-level-total  no-label format "->>9.99"    space(0)
    sym9                      no-label format "X(1)"       space(0)
    tt-doc.state-temperature  no-label format "->9.99"     space(0)
    sym10                     no-label format "X(1)"       space(0)
    tt-doc.state-dencity      no-label format "9.9999"     space(0)
    sym11                     no-label format "X(1)"       space(0)
    tt-doc.attr_              no-label format "x(150)"     space(0)
    sym12                     no-label format "X(1)"       space(0)
  header
    "+---+--------+--------+--------+----------+----------+----------+-------+------+------+------------------------------------------------------------------------------------------------------------------------------------------------------+" SKIP
    "|   |        |        |   №    |          | расшиф-  |          | Высота| Тем- | Плот-|     Данные ТТН Компания - перевозчик, № а/м,                                                                                                         |" SKIP
    "|   |        |        | резер- |   вид    | ровка    |   Объем  | взлива| пера-| ность|       ФИО водителя, плотность, температура,                                                                                                          |" SKIP
    "| № | Дата   | Время  | вуара  | топлива  | показа-  |    (л)   |  (см) | тура |      |              масса, объем (по ТТН)                                                                                                                   |" SKIP
    "|   |        |        |        |          | ний      |          |       |  (С) |      |                                                                                                                                                      |" SKIP
  with width 240 down stream-io no-labels no-box.
procedure prev-shift :
define input parameter p-obj-type   like  ub.rvs-doc.obj-type no-undo .
define input parameter p-obj-code   like  ub.rvs-doc.obj-code no-undo .
define input parameter p-shift-date like  ub.rvs-doc.shift-date no-undo .
define input parameter p-shift-num  like  ub.rvs-doc.shift-num no-undo .
define output parameter p-fact-order like ub.rvs-doc.fact-order init ? no-undo .
define buffer prev_shift-obj  for ub.shift-obj .
define buffer prev_rvs-doc    for ub.rvs-doc .
define buffer buf_shift-staff for ub.shift-staff.
do
on error undo, return error
:
   find last  prev_shift-obj
        where prev_shift-obj.obj-type = p-obj-type
          and prev_shift-obj.obj-code = p-obj-code
          and prev_shift-obj.status_  = 'зкр':U
          and ( prev_shift-obj.shift-date < p-shift-date
                or
               ( prev_shift-obj.shift-date = p-shift-date
                 and
                 prev_shift-obj.shift-num  < p-shift-num
               )
              )
   use-index stts
   no-lock
   no-error.
   if available prev_shift-obj then do:
      FOR each  buf_shift-staff
         where buf_shift-staff.obj-type    = prev_shift-obj.obj-type
            and buf_shift-staff.obj-code   = prev_shift-obj.obj-code
            and buf_shift-staff.shift-date = prev_shift-obj.shift-date
            and buf_shift-staff.shift-num  = prev_shift-obj.shift-num
            and buf_shift-staff.psn-num   >= 0
            no-lock
            :
         assign
            v-shift-staff-prev = v-shift-staff-prev + ", " + buf_shift-staff.name
         .
      end.
      assign
         v-shift-staff-prev = TRIM(v-shift-staff-prev, ",")
      .
      find first prev_rvs-doc
         where prev_rvs-doc.obj-type    = prev_shift-obj.obj-type
            and prev_rvs-doc.obj-code   = prev_shift-obj.obj-code
            and prev_rvs-doc.shift-date = prev_shift-obj.shift-date
            and prev_rvs-doc.shift-num  = prev_shift-obj.shift-num
            and prev_rvs-doc.status_    = 'факт':U
            and prev_rvs-doc.rvs-type   = 'смена':U
         no-lock
         no-error.
      if available prev_rvs-doc then do:
         assign
            p-fact-order = prev_rvs-doc.fact-order
         .
      end.
   end.
end.
end procedure.
procedure fill-doc :
define buffer buf_rvs-line    for ub.rvs-line .
define buffer buf_rvs-doc     for ub.rvs-doc  .
define buffer buf_place       for ub.place .
define buffer buf_goods       for ub.goods .
define buffer buf_trn-doc     for ub.trn-doc .
define buffer buf_doc-line    for ub.doc-line.
define buffer buf_clients     for ub.clients.
define buffer buf_tt-doc      for tt-doc.
define buffer buf_shift-staff for ub.shift-staff.
define buffer buf_shift-obj   for ub.shift-obj.
define variable v-coordl    as character    no-undo .
define variable v-attr      as character    no-undo .
define variable v-pl-code   as integer      no-undo.
define variable v-fact-order-begin like ub.rvs-doc.fact-order init ? no-undo .
define variable v-fact-order-end   like ub.rvs-doc.fact-order init ? no-undo .
define variable v-density-av    as decimal      no-undo.
DEFINE VARIABLE v-type         AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-autoent-code AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-autoent-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-car-num      AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-fio          AS CHARACTER NO-UNDO.
define variable v-autoent-name as character no-undo.
DEFINE VARIABLE v-exist AS LOGICAL   NO-UNDO.
define variable v-loc    as character    no-undo.
do
on error undo, return error
:
   find first obj-list
        no-lock
        no-error
        .
   if not available obj-list then do:
      message
         "Не определен объект для формирования отчета"
      view-as alert-box information .
      return error.
   end.
   find first buf_rvs-doc
         where  buf_rvs-doc.obj-type   = obj-list.obj-type
            and buf_rvs-doc.obj-code   = obj-list.obj-code
            and buf_rvs-doc.shift-date = X-date-Start
            and buf_rvs-doc.shift-num  = X-shift-Alone
            and buf_rvs-doc.status_    = 'факт':U
            and   buf_rvs-doc.rvs-type   = 'смена':U
         no-lock
         no-error
         .
   IF available buf_rvs-doc then do:
      assign
         v-fact-order-end = buf_rvs-doc.fact-order
         v-date-rvs-shift = STRING(buf_rvs-doc.fact-date, "99/99/99")
         v-time-rvs-shift = STRING(buf_rvs-doc.fact-time, "HH:MM:SS")
      .
   end.
   ELSE do:
      assign
         v-date-rvs-shift = "Не закрыта"
      .
   end.
   find first buf_shift-obj
        where buf_shift-obj.obj-type   = obj-list.obj-type
          and buf_shift-obj.obj-code   = obj-list.obj-code
          and buf_shift-obj.shift-date = X-date-Start
          and buf_shift-obj.shift-num  = X-shift-Alone
   no-lock
   no-error
   .
   IF NOT AVAILABLE buf_shift-obj then do:
      MESSAGE SUBSTITUTE("Неправильно выбрана смена: &1, &2, &3, &4",
               X-shift-Alone
               , X-date-Start
               , obj-list.obj-type
               , obj-list.obj-code
               )
      view-as alert-box error         .
      return error.
   end.
   Assign
      v-date-begin = IF buf_shift-obj.open-date = ?  then "Не открыта" else STRING(buf_shift-obj.open-date,  "99/99/99")
      v-date-end   = IF buf_shift-obj.close-date = ? then "Не закрыта" else STRING(buf_shift-obj.close-date, "99/99/99")
   .
   FOR each  buf_shift-staff
       where buf_shift-staff.obj-type   = obj-list.obj-type
         and buf_shift-staff.obj-code   = obj-list.obj-code
         and buf_shift-staff.shift-date = X-date-Start
         and buf_shift-staff.shift-num  = X-shift-Alone
         and buf_shift-staff.psn-num       >= 0
       no-lock
       :
       assign
         v-shift-staff = v-shift-staff + ", " + buf_shift-staff.name
       .
   end.
   assign
      v-shift-staff = TRIM(v-shift-staff, ",")
   .
   run prev-shift in this-procedure ( input  obj-list.obj-type
                                    , input  obj-list.obj-code
                                    , input  X-date-Start
                                    , input  X-shift-Alone
                                    , output v-fact-order-begin
                                    ) .
   IF v-fact-order-end = ?
   then do:
      IF v-fact-order-begin = ?
      then do:
         for each  buf_rvs-doc
            where buf_rvs-doc.obj-type     = obj-list.obj-type
               and buf_rvs-doc.obj-code     = obj-list.obj-code
               AND buf_rvs-doc.status_      = 'факт':U
            no-lock
            :
define variable vss-include-info16 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
            IF (buf_rvs-doc.rvs-type = 'после_док':U
            OR  buf_rvs-doc.rvs-type = 'перед_док':U)
            then do:
               find first buf_trn-doc
                    where buf_trn-doc.doc-code = buf_rvs-doc.out-code
                    no-lock
                    .
               v-attr = "".
            end.
            FOR each  buf_rvs-line
            where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
            no-lock
            :
               find first buf_place
                     where buf_place.obj-type = buf_rvs-doc.obj-type
                     and buf_place.obj-code = buf_rvs-doc.obj-code
                     and buf_place.pl-code  = buf_rvs-line.pl-code
                     no-lock
                     no-error
                     .
               if available buf_place then do:
                  assign
                     v-loc = buf_place.loc1
                  .
               end.
               else do:
                  assign
                     v-loc = "Не найден"
                  .
               end.
               find first buf_goods
                  where buf_goods.gds-code = buf_rvs-line.gds-code
                  no-lock
                  .
               if  available buf_trn-doc
               AND (buf_rvs-doc.rvs-type = 'после_док':U
               OR   buf_rvs-doc.rvs-type = 'перед_док':U)
               then do:
                  find first buf_doc-line
                       where buf_doc-line.doc-code  = buf_trn-doc.doc-code
                         and buf_doc-line.artic     = buf_goods.artic
                         and buf_doc-line.prod-type = buf_goods.prod-type
                         and buf_doc-line.prod-code = buf_goods.prod-code
                       no-lock
                       .
                        assign
                           v-exist = false
                        .
                        RUN get-doc-line-attr  (
                           INPUT   buf_doc-line.doc-code  ,
                           INPUT   buf_goods.gds-code,
                           INPUT   "autoent-obj-type":U ,
                           OUTPUT  v-autoent-type      ,
                           OUTPUT  v-exist       )
                           NO-ERROR .
                        IF ERROR-STATUS :ERROR
                        OR NOT v-exist
                        THEN DO:
                           assign
                              v-autoent-type = ""
                           .
                        END.
                        assign
                           v-exist = false
                        .
                        RUN get-doc-line-attr  (
                           INPUT   buf_doc-line.doc-code  ,
                           INPUT   buf_goods.gds-code,
                           INPUT   "autoent-obj-code":U ,
                           OUTPUT  v-autoent-code      ,
                           OUTPUT  v-exist       )
                           NO-ERROR .
                        IF ERROR-STATUS :ERROR
                        OR NOT v-exist
                        THEN DO:
                           assign
                              v-autoent-code = ""
                           .
                        END.
                        find first buf_clients
                              where buf_clients.obj-type = v-autoent-type
                                 and buf_clients.obj-code = INTEGER(v-autoent-code)
                              no-lock
                              no-error
                              .
                        IF AVAILABLE buf_clients then do:
                           assign
                              v-autoent-name = buf_clients.obj-name
                           .
                        end.
                        else do:
                           assign
                              v-autoent-name = "не задан":U
                           .
                        end.
                        assign
                           v-exist = false
                        .
                        RUN get-doc-line-attr  (
                           INPUT   buf_doc-line.doc-code  ,
                           INPUT   buf_goods.gds-code,
                           INPUT   "car-num":U ,
                           OUTPUT  v-car-num      ,
                           OUTPUT  v-exist       )
                           NO-ERROR .
                        IF ERROR-STATUS :ERROR
                        OR NOT v-exist
                        THEN DO:
                           assign
                              v-car-num = "не задан"
                           .
                        END.
                        assign
                           v-exist = false
                        .
                        RUN get-doc-line-attr  (
                           INPUT   buf_doc-line.doc-code  ,
                           INPUT   buf_goods.gds-code,
                           INPUT   "fio":U ,
                           OUTPUT  v-fio      ,
                           OUTPUT  v-exist       )
                           NO-ERROR .
                        IF ERROR-STATUS :ERROR
                        OR NOT v-exist
                        THEN DO:
                           assign
                              v-fio = "не заданы"
                           .
                        END.
                  assign
                     v-attr = Substitute( "Перевозчик: &1, № а/м: &2, ФИО водителя: &3, плотность: &4, температура: &5, масса: &6, объем: &7"
                                        , v-autoent-name
                                        , v-car-num
                                        , v-fio
                                        , STRING(buf_doc-line.doc-density, ">9.9999")
                                        , STRING(buf_doc-line.temperature, "->9.99")
                                        , buf_doc-line.doc-qnty * buf_doc-line.doc-density
                                        , buf_doc-line.doc-qnty
                                        )
                  .
                  release buf_doc-line.
               end.
               create tt-doc.
               assign
                  tt-doc.rvs-code           = buf_rvs-line.rvs-code
                  tt-doc.obj-type           = buf_rvs-line.obj-type
                  tt-doc.obj-code           = buf_rvs-line.obj-code
                  tt-doc.pl-code            = buf_rvs-line.pl-code
                  tt-doc.gds-code           = buf_rvs-line.gds-code
                  tt-doc.shift-date         = buf_rvs-doc.shift-date
                  tt-doc.shift-num          = buf_rvs-doc.shift-num
                  tt-doc.status_            = buf_rvs-doc.status_
                  tt-doc.fact-order         = buf_rvs-doc.fact-order
                  tt-doc.loc1               = v-loc
                  tt-doc.state-measure-qnty = buf_rvs-line.state-measure-qnty
                  tt-doc.state-temperature  = buf_rvs-line.state-temperature
                  tt-doc.state-dencity      = buf_rvs-line.state-density
                  tt-doc.fact-date          = buf_rvs-doc.fact-date
                  tt-doc.fact-time          = STRING(buf_rvs-doc.fact-time, "HH:MM:SS")
                  tt-doc.gds-name           = buf_goods.gds-name
                  tt-doc.rvs-type           = buf_rvs-doc.rvs-type
                  tt-doc.state-level-total  = buf_rvs-line.state-level-total
                  tt-doc.attr_              = v-attr
               .
               case tt-doc.rvs-type:
                  when 'после_док':U then do:
                     assign
                        tt-doc.rvs-type-outside = "после приема"
                     .
                  end.
                  when     'перед_док':U then do:
                     assign
                        tt-doc.rvs-type-outside = "до приема"
                     .
                  end.
                  when     'смена':U then do:
                     assign
                        tt-doc.rvs-type-outside = "смена"
                     .
                  end.
                  when     'контроль':U then do:
                     assign
                        tt-doc.rvs-type-outside = "контроль"
                     .
                  end.
               end case.
            if  available buf_trn-doc then do:
                release buf_trn-doc.
            end.
            end.
         end.
      end.
      else do:
         for each  buf_rvs-doc
            where buf_rvs-doc.obj-type     = obj-list.obj-type
               and buf_rvs-doc.obj-code     = obj-list.obj-code
               AND buf_rvs-doc.status_      = 'факт':U
               AND buf_rvs-doc.fact-order  >  v-fact-order-begin
            no-lock
            :
define variable vss-include-info17 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
            IF (buf_rvs-doc.rvs-type = 'после_док':U
            OR  buf_rvs-doc.rvs-type = 'перед_док':U)
            then do:
               find first buf_trn-doc
                    where buf_trn-doc.doc-code = buf_rvs-doc.out-code
                    no-lock
                    .
               v-attr = "".
            end.
            FOR each  buf_rvs-line
            where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
            no-lock
            :
               find first buf_place
                     where buf_place.obj-type = buf_rvs-doc.obj-type
                     and buf_place.obj-code = buf_rvs-doc.obj-code
                     and buf_place.pl-code  = buf_rvs-line.pl-code
                     no-lock
                     no-error
                     .
               if available buf_place then do:
                  assign
                     v-loc = buf_place.loc1
                  .
               end.
               else do:
                  assign
                     v-loc = "Не найден"
                  .
               end.
               find first buf_goods
                  where buf_goods.gds-code = buf_rvs-line.gds-code
                  no-lock
                  .
               if  available buf_trn-doc
               AND (buf_rvs-doc.rvs-type = 'после_док':U
               OR   buf_rvs-doc.rvs-type = 'перед_док':U)
               then do:
                  find first buf_doc-line
                       where buf_doc-line.doc-code  = buf_trn-doc.doc-code
                         and buf_doc-line.artic     = buf_goods.artic
                         and buf_doc-line.prod-type = buf_goods.prod-type
                         and buf_doc-line.prod-code = buf_goods.prod-code
                       no-lock
                       .
                        assign
                           v-exist = false
                        .
                        RUN get-doc-line-attr  (
                           INPUT   buf_doc-line.doc-code  ,
                           INPUT   buf_goods.gds-code,
                           INPUT   "autoent-obj-type":U ,
                           OUTPUT  v-autoent-type      ,
                           OUTPUT  v-exist       )
                           NO-ERROR .
                        IF ERROR-STATUS :ERROR
                        OR NOT v-exist
                        THEN DO:
                           assign
                              v-autoent-type = ""
                           .
                        END.
                        assign
                           v-exist = false
                        .
                        RUN get-doc-line-attr  (
                           INPUT   buf_doc-line.doc-code  ,
                           INPUT   buf_goods.gds-code,
                           INPUT   "autoent-obj-code":U ,
                           OUTPUT  v-autoent-code      ,
                           OUTPUT  v-exist       )
                           NO-ERROR .
                        IF ERROR-STATUS :ERROR
                        OR NOT v-exist
                        THEN DO:
                           assign
                              v-autoent-code = ""
                           .
                        END.
                        find first buf_clients
                              where buf_clients.obj-type = v-autoent-type
                                 and buf_clients.obj-code = INTEGER(v-autoent-code)
                              no-lock
                              no-error
                              .
                        IF AVAILABLE buf_clients then do:
                           assign
                              v-autoent-name = buf_clients.obj-name
                           .
                        end.
                        else do:
                           assign
                              v-autoent-name = "не задан":U
                           .
                        end.
                        assign
                           v-exist = false
                        .
                        RUN get-doc-line-attr  (
                           INPUT   buf_doc-line.doc-code  ,
                           INPUT   buf_goods.gds-code,
                           INPUT   "car-num":U ,
                           OUTPUT  v-car-num      ,
                           OUTPUT  v-exist       )
                           NO-ERROR .
                        IF ERROR-STATUS :ERROR
                        OR NOT v-exist
                        THEN DO:
                           assign
                              v-car-num = "не задан"
                           .
                        END.
                        assign
                           v-exist = false
                        .
                        RUN get-doc-line-attr  (
                           INPUT   buf_doc-line.doc-code  ,
                           INPUT   buf_goods.gds-code,
                           INPUT   "fio":U ,
                           OUTPUT  v-fio      ,
                           OUTPUT  v-exist       )
                           NO-ERROR .
                        IF ERROR-STATUS :ERROR
                        OR NOT v-exist
                        THEN DO:
                           assign
                              v-fio = "не заданы"
                           .
                        END.
                  assign
                     v-attr = Substitute( "Перевозчик: &1, № а/м: &2, ФИО водителя: &3, плотность: &4, температура: &5, масса: &6, объем: &7"
                                        , v-autoent-name
                                        , v-car-num
                                        , v-fio
                                        , STRING(buf_doc-line.doc-density, ">9.9999")
                                        , STRING(buf_doc-line.temperature, "->9.99")
                                        , buf_doc-line.doc-qnty * buf_doc-line.doc-density
                                        , buf_doc-line.doc-qnty
                                        )
                  .
                  release buf_doc-line.
               end.
               create tt-doc.
               assign
                  tt-doc.rvs-code           = buf_rvs-line.rvs-code
                  tt-doc.obj-type           = buf_rvs-line.obj-type
                  tt-doc.obj-code           = buf_rvs-line.obj-code
                  tt-doc.pl-code            = buf_rvs-line.pl-code
                  tt-doc.gds-code           = buf_rvs-line.gds-code
                  tt-doc.shift-date         = buf_rvs-doc.shift-date
                  tt-doc.shift-num          = buf_rvs-doc.shift-num
                  tt-doc.status_            = buf_rvs-doc.status_
                  tt-doc.fact-order         = buf_rvs-doc.fact-order
                  tt-doc.loc1               = v-loc
                  tt-doc.state-measure-qnty = buf_rvs-line.state-measure-qnty
                  tt-doc.state-temperature  = buf_rvs-line.state-temperature
                  tt-doc.state-dencity      = buf_rvs-line.state-density
                  tt-doc.fact-date          = buf_rvs-doc.fact-date
                  tt-doc.fact-time          = STRING(buf_rvs-doc.fact-time, "HH:MM:SS")
                  tt-doc.gds-name           = buf_goods.gds-name
                  tt-doc.rvs-type           = buf_rvs-doc.rvs-type
                  tt-doc.state-level-total  = buf_rvs-line.state-level-total
                  tt-doc.attr_              = v-attr
               .
               case tt-doc.rvs-type:
                  when 'после_док':U then do:
                     assign
                        tt-doc.rvs-type-outside = "после приема"
                     .
                  end.
                  when     'перед_док':U then do:
                     assign
                        tt-doc.rvs-type-outside = "до приема"
                     .
                  end.
                  when     'смена':U then do:
                     assign
                        tt-doc.rvs-type-outside = "смена"
                     .
                  end.
                  when     'контроль':U then do:
                     assign
                        tt-doc.rvs-type-outside = "контроль"
                     .
                  end.
               end case.
            if  available buf_trn-doc then do:
                release buf_trn-doc.
            end.
            end.
         end.
      end.
   end.
   else do:
      IF v-fact-order-begin = ?
      then do:
         for each  buf_rvs-doc
            where buf_rvs-doc.obj-type     = obj-list.obj-type
               and buf_rvs-doc.obj-code     = obj-list.obj-code
               AND buf_rvs-doc.status_      = 'факт':U
               AND buf_rvs-doc.fact-order  <= v-fact-order-end
            no-lock
            :
define variable vss-include-info18 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
            IF (buf_rvs-doc.rvs-type = 'после_док':U
            OR  buf_rvs-doc.rvs-type = 'перед_док':U)
            then do:
               find first buf_trn-doc
                    where buf_trn-doc.doc-code = buf_rvs-doc.out-code
                    no-lock
                    .
               v-attr = "".
            end.
            FOR each  buf_rvs-line
            where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
            no-lock
            :
               find first buf_place
                     where buf_place.obj-type = buf_rvs-doc.obj-type
                     and buf_place.obj-code = buf_rvs-doc.obj-code
                     and buf_place.pl-code  = buf_rvs-line.pl-code
                     no-lock
                     no-error
                     .
               if available buf_place then do:
                  assign
                     v-loc = buf_place.loc1
                  .
               end.
               else do:
                  assign
                     v-loc = "Не найден"
                  .
               end.
               find first buf_goods
                  where buf_goods.gds-code = buf_rvs-line.gds-code
                  no-lock
                  .
               if  available buf_trn-doc
               AND (buf_rvs-doc.rvs-type = 'после_док':U
               OR   buf_rvs-doc.rvs-type = 'перед_док':U)
               then do:
                  find first buf_doc-line
                       where buf_doc-line.doc-code  = buf_trn-doc.doc-code
                         and buf_doc-line.artic     = buf_goods.artic
                         and buf_doc-line.prod-type = buf_goods.prod-type
                         and buf_doc-line.prod-code = buf_goods.prod-code
                       no-lock
                       .
                        assign
                           v-exist = false
                        .
                        RUN get-doc-line-attr  (
                           INPUT   buf_doc-line.doc-code  ,
                           INPUT   buf_goods.gds-code,
                           INPUT   "autoent-obj-type":U ,
                           OUTPUT  v-autoent-type      ,
                           OUTPUT  v-exist       )
                           NO-ERROR .
                        IF ERROR-STATUS :ERROR
                        OR NOT v-exist
                        THEN DO:
                           assign
                              v-autoent-type = ""
                           .
                        END.
                        assign
                           v-exist = false
                        .
                        RUN get-doc-line-attr  (
                           INPUT   buf_doc-line.doc-code  ,
                           INPUT   buf_goods.gds-code,
                           INPUT   "autoent-obj-code":U ,
                           OUTPUT  v-autoent-code      ,
                           OUTPUT  v-exist       )
                           NO-ERROR .
                        IF ERROR-STATUS :ERROR
                        OR NOT v-exist
                        THEN DO:
                           assign
                              v-autoent-code = ""
                           .
                        END.
                        find first buf_clients
                              where buf_clients.obj-type = v-autoent-type
                                 and buf_clients.obj-code = INTEGER(v-autoent-code)
                              no-lock
                              no-error
                              .
                        IF AVAILABLE buf_clients then do:
                           assign
                              v-autoent-name = buf_clients.obj-name
                           .
                        end.
                        else do:
                           assign
                              v-autoent-name = "не задан":U
                           .
                        end.
                        assign
                           v-exist = false
                        .
                        RUN get-doc-line-attr  (
                           INPUT   buf_doc-line.doc-code  ,
                           INPUT   buf_goods.gds-code,
                           INPUT   "car-num":U ,
                           OUTPUT  v-car-num      ,
                           OUTPUT  v-exist       )
                           NO-ERROR .
                        IF ERROR-STATUS :ERROR
                        OR NOT v-exist
                        THEN DO:
                           assign
                              v-car-num = "не задан"
                           .
                        END.
                        assign
                           v-exist = false
                        .
                        RUN get-doc-line-attr  (
                           INPUT   buf_doc-line.doc-code  ,
                           INPUT   buf_goods.gds-code,
                           INPUT   "fio":U ,
                           OUTPUT  v-fio      ,
                           OUTPUT  v-exist       )
                           NO-ERROR .
                        IF ERROR-STATUS :ERROR
                        OR NOT v-exist
                        THEN DO:
                           assign
                              v-fio = "не заданы"
                           .
                        END.
                  assign
                     v-attr = Substitute( "Перевозчик: &1, № а/м: &2, ФИО водителя: &3, плотность: &4, температура: &5, масса: &6, объем: &7"
                                        , v-autoent-name
                                        , v-car-num
                                        , v-fio
                                        , STRING(buf_doc-line.doc-density, ">9.9999")
                                        , STRING(buf_doc-line.temperature, "->9.99")
                                        , buf_doc-line.doc-qnty * buf_doc-line.doc-density
                                        , buf_doc-line.doc-qnty
                                        )
                  .
                  release buf_doc-line.
               end.
               create tt-doc.
               assign
                  tt-doc.rvs-code           = buf_rvs-line.rvs-code
                  tt-doc.obj-type           = buf_rvs-line.obj-type
                  tt-doc.obj-code           = buf_rvs-line.obj-code
                  tt-doc.pl-code            = buf_rvs-line.pl-code
                  tt-doc.gds-code           = buf_rvs-line.gds-code
                  tt-doc.shift-date         = buf_rvs-doc.shift-date
                  tt-doc.shift-num          = buf_rvs-doc.shift-num
                  tt-doc.status_            = buf_rvs-doc.status_
                  tt-doc.fact-order         = buf_rvs-doc.fact-order
                  tt-doc.loc1               = v-loc
                  tt-doc.state-measure-qnty = buf_rvs-line.state-measure-qnty
                  tt-doc.state-temperature  = buf_rvs-line.state-temperature
                  tt-doc.state-dencity      = buf_rvs-line.state-density
                  tt-doc.fact-date          = buf_rvs-doc.fact-date
                  tt-doc.fact-time          = STRING(buf_rvs-doc.fact-time, "HH:MM:SS")
                  tt-doc.gds-name           = buf_goods.gds-name
                  tt-doc.rvs-type           = buf_rvs-doc.rvs-type
                  tt-doc.state-level-total  = buf_rvs-line.state-level-total
                  tt-doc.attr_              = v-attr
               .
               case tt-doc.rvs-type:
                  when 'после_док':U then do:
                     assign
                        tt-doc.rvs-type-outside = "после приема"
                     .
                  end.
                  when     'перед_док':U then do:
                     assign
                        tt-doc.rvs-type-outside = "до приема"
                     .
                  end.
                  when     'смена':U then do:
                     assign
                        tt-doc.rvs-type-outside = "смена"
                     .
                  end.
                  when     'контроль':U then do:
                     assign
                        tt-doc.rvs-type-outside = "контроль"
                     .
                  end.
               end case.
            if  available buf_trn-doc then do:
                release buf_trn-doc.
            end.
            end.
         end.
      end.
      else do:
         for each  buf_rvs-doc
            where buf_rvs-doc.obj-type     = obj-list.obj-type
               and buf_rvs-doc.obj-code     = obj-list.obj-code
               AND buf_rvs-doc.status_      = 'факт':U
               AND buf_rvs-doc.fact-order  >  v-fact-order-begin
               AND buf_rvs-doc.fact-order  <= v-fact-order-end
            no-lock
            :
define variable vss-include-info19 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
            IF (buf_rvs-doc.rvs-type = 'после_док':U
            OR  buf_rvs-doc.rvs-type = 'перед_док':U)
            then do:
               find first buf_trn-doc
                    where buf_trn-doc.doc-code = buf_rvs-doc.out-code
                    no-lock
                    .
               v-attr = "".
            end.
            FOR each  buf_rvs-line
            where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
            no-lock
            :
               find first buf_place
                     where buf_place.obj-type = buf_rvs-doc.obj-type
                     and buf_place.obj-code = buf_rvs-doc.obj-code
                     and buf_place.pl-code  = buf_rvs-line.pl-code
                     no-lock
                     no-error
                     .
               if available buf_place then do:
                  assign
                     v-loc = buf_place.loc1
                  .
               end.
               else do:
                  assign
                     v-loc = "Не найден"
                  .
               end.
               find first buf_goods
                  where buf_goods.gds-code = buf_rvs-line.gds-code
                  no-lock
                  .
               if  available buf_trn-doc
               AND (buf_rvs-doc.rvs-type = 'после_док':U
               OR   buf_rvs-doc.rvs-type = 'перед_док':U)
               then do:
                  find first buf_doc-line
                       where buf_doc-line.doc-code  = buf_trn-doc.doc-code
                         and buf_doc-line.artic     = buf_goods.artic
                         and buf_doc-line.prod-type = buf_goods.prod-type
                         and buf_doc-line.prod-code = buf_goods.prod-code
                       no-lock
                       .
                        assign
                           v-exist = false
                        .
                        RUN get-doc-line-attr  (
                           INPUT   buf_doc-line.doc-code  ,
                           INPUT   buf_goods.gds-code,
                           INPUT   "autoent-obj-type":U ,
                           OUTPUT  v-autoent-type      ,
                           OUTPUT  v-exist       )
                           NO-ERROR .
                        IF ERROR-STATUS :ERROR
                        OR NOT v-exist
                        THEN DO:
                           assign
                              v-autoent-type = ""
                           .
                        END.
                        assign
                           v-exist = false
                        .
                        RUN get-doc-line-attr  (
                           INPUT   buf_doc-line.doc-code  ,
                           INPUT   buf_goods.gds-code,
                           INPUT   "autoent-obj-code":U ,
                           OUTPUT  v-autoent-code      ,
                           OUTPUT  v-exist       )
                           NO-ERROR .
                        IF ERROR-STATUS :ERROR
                        OR NOT v-exist
                        THEN DO:
                           assign
                              v-autoent-code = ""
                           .
                        END.
                        find first buf_clients
                              where buf_clients.obj-type = v-autoent-type
                                 and buf_clients.obj-code = INTEGER(v-autoent-code)
                              no-lock
                              no-error
                              .
                        IF AVAILABLE buf_clients then do:
                           assign
                              v-autoent-name = buf_clients.obj-name
                           .
                        end.
                        else do:
                           assign
                              v-autoent-name = "не задан":U
                           .
                        end.
                        assign
                           v-exist = false
                        .
                        RUN get-doc-line-attr  (
                           INPUT   buf_doc-line.doc-code  ,
                           INPUT   buf_goods.gds-code,
                           INPUT   "car-num":U ,
                           OUTPUT  v-car-num      ,
                           OUTPUT  v-exist       )
                           NO-ERROR .
                        IF ERROR-STATUS :ERROR
                        OR NOT v-exist
                        THEN DO:
                           assign
                              v-car-num = "не задан"
                           .
                        END.
                        assign
                           v-exist = false
                        .
                        RUN get-doc-line-attr  (
                           INPUT   buf_doc-line.doc-code  ,
                           INPUT   buf_goods.gds-code,
                           INPUT   "fio":U ,
                           OUTPUT  v-fio      ,
                           OUTPUT  v-exist       )
                           NO-ERROR .
                        IF ERROR-STATUS :ERROR
                        OR NOT v-exist
                        THEN DO:
                           assign
                              v-fio = "не заданы"
                           .
                        END.
                  assign
                     v-attr = Substitute( "Перевозчик: &1, № а/м: &2, ФИО водителя: &3, плотность: &4, температура: &5, масса: &6, объем: &7"
                                        , v-autoent-name
                                        , v-car-num
                                        , v-fio
                                        , STRING(buf_doc-line.doc-density, ">9.9999")
                                        , STRING(buf_doc-line.temperature, "->9.99")
                                        , buf_doc-line.doc-qnty * buf_doc-line.doc-density
                                        , buf_doc-line.doc-qnty
                                        )
                  .
                  release buf_doc-line.
               end.
               create tt-doc.
               assign
                  tt-doc.rvs-code           = buf_rvs-line.rvs-code
                  tt-doc.obj-type           = buf_rvs-line.obj-type
                  tt-doc.obj-code           = buf_rvs-line.obj-code
                  tt-doc.pl-code            = buf_rvs-line.pl-code
                  tt-doc.gds-code           = buf_rvs-line.gds-code
                  tt-doc.shift-date         = buf_rvs-doc.shift-date
                  tt-doc.shift-num          = buf_rvs-doc.shift-num
                  tt-doc.status_            = buf_rvs-doc.status_
                  tt-doc.fact-order         = buf_rvs-doc.fact-order
                  tt-doc.loc1               = v-loc
                  tt-doc.state-measure-qnty = buf_rvs-line.state-measure-qnty
                  tt-doc.state-temperature  = buf_rvs-line.state-temperature
                  tt-doc.state-dencity      = buf_rvs-line.state-density
                  tt-doc.fact-date          = buf_rvs-doc.fact-date
                  tt-doc.fact-time          = STRING(buf_rvs-doc.fact-time, "HH:MM:SS")
                  tt-doc.gds-name           = buf_goods.gds-name
                  tt-doc.rvs-type           = buf_rvs-doc.rvs-type
                  tt-doc.state-level-total  = buf_rvs-line.state-level-total
                  tt-doc.attr_              = v-attr
               .
               case tt-doc.rvs-type:
                  when 'после_док':U then do:
                     assign
                        tt-doc.rvs-type-outside = "после приема"
                     .
                  end.
                  when     'перед_док':U then do:
                     assign
                        tt-doc.rvs-type-outside = "до приема"
                     .
                  end.
                  when     'смена':U then do:
                     assign
                        tt-doc.rvs-type-outside = "смена"
                     .
                  end.
                  when     'контроль':U then do:
                     assign
                        tt-doc.rvs-type-outside = "контроль"
                     .
                  end.
               end case.
            if  available buf_trn-doc then do:
                release buf_trn-doc.
            end.
            end.
         end.
      end.
   end.
   assign
      v-counter = 0
   .
   for each tt-doc
       break
       by tt-doc.pl-code
       by tt-doc.gds-code
   :
      assign
         v-counter    = v-counter + 1
         v-density-av = v-density-av + tt-doc.state-dencity
      .
      IF LAST-OF(tt-doc.gds-code) then do:
         find first buf_tt-doc
            where buf_tt-doc.rvs-type = 'смена':U
               and buf_tt-doc.pl-code  = tt-doc.pl-code
               and buf_tt-doc.gds-code = tt-doc.gds-code
            no-lock
            no-error.
         IF AVAILABLE buf_tt-doc then do:
            assign
               buf_tt-doc.average-dencity = v-density-av / v-counter
               v-density-av = 0
               v-counter    = 0
            .
         end.
         else do:
            assign
               v-density-av = 0
               v-counter    = 0
            .
         end.
      end.
   end.
end.
end procedure.
procedure print-body :
do
on error undo, return error
:
   assign
      v-counter = 0
   .
   for each tt-doc
       where  tt-doc.rvs-type   = 'смена':U
       use-index by-type
   :
      v-counter = v-counter + 1.
      display stream out-stream
         tt-doc.loc1
         tt-doc.state-measure-qnty
         tt-doc.state-level-total
         tt-doc.state-temperature
         tt-doc.state-dencity
         tt-doc.average-dencity
         sym1  sym2  sym3  sym4  sym5  sym6  sym7
      with frame f-first.
      down stream out-stream 1 with frame f-first
      .
      run r-plc-xl-sheet1-write-line-data in this-procedure (
           input tt-doc.loc1
         , input tt-doc.state-measure-qnty
         , input tt-doc.state-level-total
         , input tt-doc.state-temperature
         , input tt-doc.state-dencity
         , input tt-doc.average-dencity
      ) .
   end.
   IF v-counter = 0 then do:
      display stream out-stream
         "не закр." @ tt-doc.loc1
         sym1  sym2  sym3  sym4  sym5  sym6  sym7
      with frame f-first.
      down stream out-stream 1 with frame f-first
      .
   end.
   put stream out-stream unformatted fill( "-" , 54 ) skip.
   assign
      v-counter = 0
   .
   for each tt-doc
       where  tt-doc.rvs-type   <> 'смена':U
       use-index by-date
   :
      v-counter = v-counter + 1.
      display stream out-stream
              v-counter
         tt-doc.fact-date
         tt-doc.fact-time
         tt-doc.loc1
         tt-doc.gds-name
         tt-doc.rvs-type-outside
         tt-doc.state-measure-qnty
         tt-doc.state-level-total
         tt-doc.state-temperature
         tt-doc.state-dencity
         tt-doc.attr_
         sym1  sym2  sym3  sym4  sym5  sym6
         sym7  sym8  sym9  sym10 sym11 sym12
      with frame f-second.
      down stream out-stream 1 with frame f-second
      .
      run r-plc-xl-sheet2-write-line-data in this-procedure (
           input      v-counter
         , input tt-doc.fact-date
         , input tt-doc.fact-time
         , input tt-doc.loc1
         , input tt-doc.gds-name
         , input tt-doc.rvs-type-outside
         , input tt-doc.state-measure-qnty
         , input tt-doc.state-level-total
         , input tt-doc.state-temperature
         , input tt-doc.state-dencity
         , input tt-doc.attr_
      ).
   end.
   IF v-counter <> 0 then do:
      put stream out-stream unformatted fill( "-" , 238 ) skip.
   end.
end.
end procedure.
procedure print-header :
do
on error undo, return error
:
   put stream out-stream
      "ПОКАЗАНИЯ УРОВНЕМЕРА ЗА СМЕНУ" at 25 skip(1)
      "АЗС № " obj-list.obj-type obj-list.obj-code skip
      "Сменный отчет № " X-date-Start X-shift-Alone SKIP
      "Операторы (текущая смена): " v-shift-staff FORMAT "x(100)" skip
      "Операторы (предыдущая смена): " v-shift-staff-prev FORMAT "x(100)" SKIP
      "Дата с " v-date-begin " по " v-date-end FORMAT "x(70)" skip
      "Дата - время передачи смены: "  v-date-rvs-shift FORMAT "x(10)" " " v-time-rvs-shift SKIP(1)
   .
   run r-plc-xl-write-cell-data in this-procedure ( input "objname":U,    input Substitute("&1&2", obj-list.obj-type, obj-list.obj-code) ).
   run r-plc-xl-write-cell-data in this-procedure ( input "rep_num":U,    input Substitute("&1&2", X-date-Start, X-shift-Alone) ).
   run r-plc-xl-write-cell-data in this-procedure ( input "staff":U,      input v-shift-staff ).
   run r-plc-xl-write-cell-data in this-procedure ( input "staff_prev":U, input v-shift-staff-prev ).
   run r-plc-xl-write-cell-data in this-procedure ( input "date_begin":U, input v-date-begin ).
   run r-plc-xl-write-cell-data in this-procedure ( input "date_end":U,   input v-date-end ).
   run r-plc-xl-write-cell-data in this-procedure ( input "f_date":U,     input v-date-rvs-shift ).
   run r-plc-xl-write-cell-data in this-procedure ( input "f_time":U,     input v-time-rvs-shift ).
end.
end procedure.
procedure get-doc-line-attr :
define input parameter p-doc-code               as character        no-undo.
define input parameter p-gds-code               as integer          no-undo.
define input parameter p-attr-code              as character        no-undo.
define output parameter p-attr-value-character  as character        no-undo.
define output parameter p-attr-exists           as logical          no-undo.
    define buffer buf_doc-line-attr for ub.doc-line-attr.
do
on error undo, return error
:
    find first buf_doc-line-attr no-lock
         where buf_doc-line-attr.doc-code    = p-doc-code
           and buf_doc-line-attr.gds-code    = p-gds-code
           and buf_doc-line-attr.attr-code   = p-attr-code
    no-error.
    if available buf_doc-line-attr
    then do:
        assign
            p-attr-value-character = buf_doc-line-attr.attr-value
            p-attr-exists          = yes
        .
    end.
    else do:
        assign
            p-attr-exists          = no
        .
    end.
end.
end procedure.
do
   on error  undo , return error return-value
   on endkey undo , return error return-value
   on stop   undo , return error return-value
   :
define variable v-account as integer init 0 no-undo .
define variable v-account-lavel as character no-undo .
define variable v-button-stop as logical no-undo .
define variable v-kol-spice as integer no-undo .
define variable v-kol-spice2 as integer no-undo .
define variable v-kol-spice3 as integer no-undo .
DEFINE VARIABLE StopProcessing AS LOGICAL NO-UNDO.
DEFINE BUTTON StopBtn AUTO-END-KEY
     LABEL "Стоп"
     SIZE 10 BY 1.
DEFINE VARIABLE RecordsDone AS INTEGER FORMAT ">,>>>,>>>,>>9":U INITIAL 0
     LABEL "Обработано записей"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE RecordsString AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString2 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString3 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55.13 BY 4.46.
DEFINE FRAME InfoFrame
     StopBtn AT ROW 4.25 COL 21.75
     RecordsString AT ROW 1.21 COL 2 NO-LABEL
     RecordsString2 AT ROW 1.96 COL 2 NO-LABEL
     RecordsString3 AT ROW 2.58 COL 2 NO-LABEL
     RecordsDone AT ROW 3.42 COL 24.88 COLON-ALIGNED
     RECT-1 AT ROW 1 COL 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Процесс"
         DEFAULT-BUTTON StopBtn CANCEL-BUTTON StopBtn.
define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.
  mFramHandle = frame InfoFrame:handle.
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameRepError").
  end.
  mFrameView = not session:batch-mode and mFramHandle:visible.
  if mFrameView
  then do:
    ASSIGN
       FRAME InfoFrame:HIDDEN                           = TRUE
       StopBtn:sensitive IN FRAME InfoFrame             = TRUE.
  end.
ON CHOOSE OF StopBtn IN FRAME InfoFrame
DO:
  IF not StopProcessing THEN
    Message "Вы действительно хотите прервать" SKIP
            "процесс проверки?" view-as alert-box QUESTION BUTTONS yes-no
              UPDATE StopProcessing.
  IF StopProcessing THEN do:
     if mFrameView
     then do:
        HIDE FRAME InfoFrame.
     end.
  End.
END.
assign v-account = ( if integer( 100 ) = 0 then 100 else integer( 100 ) ).
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("ON mFrameView=" + string(mFrameView), "frameRepError").
  end.
  if not session:batch-mode then
  do:
    VIEW FRAME InfoFrame.
    mFrameView = true.
  end.
   v-button-stop = false .
      if mFrameView
      then do:
      if v-button-stop then view STOPBTN in frame InfoFrame.
                       else Hide STOPBTN in frame InfoFrame.
      end.
   run fill-doc in this-procedure .
if session :set-wait-state( "compiler" ) then.
   run get-report-num in my-handle (output g#report-num).
output stream out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
   RUN r-plc-xl-init IN THIS-PROCEDURE.
   RUN print-header IN THIS-PROCEDURE .
   run print-body in this-procedure .
   output stream out-stream close.
   RUN r-plc-xl-close IN THIS-PROCEDURE .
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
   os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )  .
   os-rename
      value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
      value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
   .
   define variable v-user-action   as character no-undo .
   define variable v-printed       as logical   no-undo .
   run gbl/prnfilen.w
         ( input  ""
         , input  8
         , input  string(session :temp-directory) + "rpt" + string( g#report-num )
         , input  ReportFontNum
         , output v-user-action
         , output v-printed
         ) .
   os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )  .
   empty temp-table tt-doc.
if session :set-wait-state( "" ) then.
END.
