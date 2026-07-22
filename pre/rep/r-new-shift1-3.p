using ibs.th.str.*.
block-level on error undo, throw.
define input parameter parparentproc              as handle    no-undo.
define input parameter p-parent-handle            as handle    no-undo .
define input parameter p-log-handle               as handle    no-undo .
define input parameter p-cont-handle              as handle    no-undo .
define input parameter p-rebh                     as handle    no-undo .
define input parameter v-report-name-html         as character no-undo .
define input parameter p-xsd-file                 as character no-undo .
define input parameter p-log-file-name            as character no-undo .
define input parameter p-batch                    as integer   no-undo .
define input parameter p-codex-id                 as integer   no-undo .
define input parameter p-ruleset-id               as integer   no-undo .
define input parameter p-weight                   as logical   no-undo.
define input parameter p-param-shft-qty           as character no-undo .
define input parameter p-obj-type                 as character no-undo .
define input parameter p-obj-code                 as integer   no-undo .
define input parameter p-z-number-list            as character no-undo.
define input parameter p-tog-1-pump-one           as logical   no-undo .
define input parameter p-tog-1-whole-gds          as logical   no-undo .
define input parameter p-tog-1-out-pump-with-icnt as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "$Печать сменного отчета - лист 1 $":U.
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable var-report-r-b as character no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable sym1  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym2  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym3  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym4  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym5  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym6  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym7  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym8  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym9  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym10 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym11 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym12 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym13 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym14 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym15 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym16 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym17 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym18 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym19 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym20 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym21 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym22 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym23 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym24 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym25 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym26 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym27 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable temp1 as integer   no-undo.
define variable div# as char no-undo.
define variable fr as logical no-undo .
define variable fr0 as logical no-undo .
define variable tmp#stroka as character no-undo .
define variable tmp#stroka0 as character no-undo .
define variable v-bar-code    like ub.bar-code.b-code no-undo  .
define variable s-bar-code   as character format "x(9)" no-undo .
define temp-table tmp-gds no-undo
  field id as integer
  field name      as character  format "x(256)"
  field f-name    as character  format "x(256)"
  field node-code as integer
  field lvl       as integer
 index pi id
.
define variable NEW-vat        like ub.doc-line.vat-pc    no-undo.
define variable LAST-vat       like ub.doc-line.vat-pc    no-undo.
define variable  var-vat-pc    like ub.doc-line.vat-pc    no-undo.
define variable g-ll as integer no-undo .
define variable id as integer no-undo .
define temp-table temp-gds-list no-undo
  field gds-code  like ub.goods.gds-code
  field prod-code like ub.goods.prod-code
  field grp-name  like ub.goods.grp-name
  field gds-name  like ub.goods.gds-name
  field artic     like ub.goods.artic
  field vat-pc    as decimal
   index pi is primary unique gds-code ascending
   index i1 artic     ascending
   index i2 prod-code ascending
   index i3 grp-name  ascending
   index i33 gds-name  ascending
   index i4 vat-pc    ascending
   index i5 prod-code grp-name   ascending
   index i6 grp-name  prod-code   ascending
   .
define variable sum_1     as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable sum_2     as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b1-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b1-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b2-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b2-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bi-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bi-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bo-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bo-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table report-headert no-undo
field datetimeStart as datetime
field datetimeEnd as datetime
field report-name as character
field report-label as character
field report-id as character
field report-db-num as integer
field task-num as integer
index pi is unique primary
report-id
.
define  temp-table report-parameterst no-undo
field report-id as character
field parameter-name as character
field parameter-label as character
field parameter-value-type as character
field parameter-value as character
field parameter-index as integer
field parameter-des as character
index pi is unique primary
report-id
parameter-name
parameter-index
.
define  temp-table report-errorst no-undo
field report-id as character
field ErrNum as integer
field ErrCode as integer
field ErrSeverity as integer
field ErrMessage as character
index pi is unique primary
report-id
ErrNum.
define  temp-table report-destinationt no-undo
field report-id as character
field destination-id as character
field destination as character
field destination-details as character
index pi is unique primary
report-id
destination-id.
define shared temp-table shiftt no-undo
field obj-type as character
field obj-code as integer
field obj-name as character
field obj-address as character
field obj-phone as character
field db-num as integer
field shift-date as date
field shift-num as integer
field shift-name as character
field base-code as integer
field curr-abbr as character
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
.
define shared  temp-table shift-pgdst no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field gds-code as integer
field gds-name as character
field start-state-qnty as decimal
field start-system-qnty as decimal
field start-state-qnty-2 as decimal
field start-system-qnty-2 as decimal
field end-state-qnty as decimal
field end-system-qnty as decimal
field end-state-qnty-2 as decimal
field end-system-qnty-2 as decimal
field in-qnty as decimal
field in-qnty-2 as decimal
field icnt-out-qnty as decimal
field end-price-sale as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
gds-code
.
define shared  temp-table shift-pgds-int no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field gds-code as integer
field doc-code as character
field cli-type-code as character
field cli-name as character
field fact-qnty as decimal
field fact-qnty-2 as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
gds-code
doc-code
.
define shared  temp-table shift-pgds-outt no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field gds-code as integer
field pay-code as integer
field curr-code as integer
field cp-type as integer
field out-name as character
field fact-qnty as decimal
field fact-qnty-2 as decimal
field fact-sum as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
gds-code
pay-code
curr-code
.
define shared temp-table shift-grpt no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field grp-code as integer
field full-grp-name as character
field start-qnty as decimal
field start-sum as decimal
field end-qnty as decimal
field end-sum as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
grp-code
.
define shared temp-table shift-grp-int no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field grp-code as integer
field doc-code as character
field cli-type-code as character
field cli-name as character
field fact-qnty as decimal
field fact-cost-sum as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
grp-code
doc-code
.
define shared temp-table shift-grp-outt no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field grp-code as integer
field pay-code as integer
field curr-code as integer
field cp-type as integer
field out-name as character
field fact-qnty as decimal
field fact-sum as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
grp-code
pay-code
curr-code
.
define dataset shift-1t
for shiftt, shift-pgdst, shift-pgds-int, shift-pgds-outt, shift-grpt, shift-grp-int, shift-grp-outt,
report-headert, report-parameterst, report-errorst
data-relation r1 for shiftt, shift-pgdst
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num) nested
data-relation r2 for shiftt, shift-grpt
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num) nested
data-relation r11 for shift-pgdst, shift-pgds-outt
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num, gds-code, gds-code) nested
data-relation r12 for shift-pgdst, shift-pgds-int
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num, gds-code, gds-code) nested
data-relation r21 for shift-grpt, shift-grp-outt
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num, grp-code, grp-code) nested
data-relation r22 for shift-grpt, shift-grp-int
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num, grp-code, grp-code) nested
data-relation rh1 for report-headert, report-parameterst
relation-fields (report-id, report-id) nested
data-relation rh2 for report-headert, report-errorst
relation-fields (report-id, report-id) nested
.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gds-attr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
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
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
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
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
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
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function is-gas returns logical
        (input p-gds-code as integer):
define variable result as logical no-undo.
define variable c-value as character no-undo.
define variable c-type as character no-undo.
do on error undo, return error:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  'fuel-type':U
      ,output c-value
      ,output c-type) no-error.
end.
result = logical(c-value = 'metan':U) no-error.
return result.
end function.
procedure placelib_write-attr:
define input  parameter p-code     like ub.place-attr.attr-code .
define input  parameter p-obj-code like ub.place-attr.obj-code .
define input  parameter p-obj-type like ub.place-attr.obj-type .
define input  parameter p-pl-code  like ub.place-attr.pl-code .
define input  parameter p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if not available buf_place-attr then do :
        create buf_place-attr.
        assign
          buf_place-attr.attr-code   = p-code
          buf_place-attr.attr-value  = p-value
          buf_place-attr.obj-code    = p-obj-code
          buf_place-attr.obj-type    = p-obj-type
          buf_place-attr.pl-code     = p-pl-code
        .
        p-ok = true.
     end.
     else do:
        buf_place-attr.attr-value  = p-value .
        p-ok = true.
     end.
  end.
end.
procedure placelib_get-attr:
define input  parameter  p-code     like ub.place-attr.attr-code .
define input  parameter  p-obj-code like ub.place-attr.obj-code .
define input  parameter  p-obj-type like ub.place-attr.obj-type .
define input  parameter  p-pl-code  like ub.place-attr.pl-code .
define output parameter  p-value    like ub.place-attr.attr-value .
define output parameter  p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr no-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
       p-value = buf_place-attr.attr-value.
       p-ok = true.
     end.
     else do :
       p-ok = false.
     end.
  end.
end.
procedure placelib_del-attr:
define input parameter  p-code     like ub.place-attr.attr-code .
define input parameter  p-obj-code like ub.place-attr.obj-code .
define input parameter  p-obj-type like ub.place-attr.obj-type .
define input parameter  p-pl-code  like ub.place-attr.pl-code .
define input parameter  p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
        delete buf_place-attr.
        p-ok = true.
     end.
  end.
end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-calc as handle no-undo .
function fnc-convert-dot-to-colon returns character
    (input p-data as decimal, input p-accur as character, input p-num as integer) forward.
function fnc-convert-dot-to-colon returns character
(input p-data as decimal, input p-accur as character, input p-num as integer):
    define variable result as character no-undo.
    define variable v-str-result as character no-undo.
    if p-data = ? then p-data = 0 .
    p-data = round(p-data, p-num).
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).
    return v-str-result.
END FUNCTION.
define variable vss-include-info13 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define  temp-table t-9 no-undo
field gds-code       like ub.goods.gds-code
field gds-name       like ub.goods.gds-name
field pump-code      like ub.rvs-line-pump.pump-code
field nozzle-code    like ub.icnt-line.nozzle-code
field start-mh-qnty  like ub.rvs-line-pump.meas-mh-cnt
field end-mh-qnty    like ub.rvs-line-pump.meas-mh-cnt
field meas-qnty      like ub.rvs-line-pump.meas-mh-cnt
field prev-start-mh-qnty like ub.rvs-line-pump.meas-mh-cnt
field start-el-qnty  like ub.rvs-line-pump.meas-el-cnt
field end-el-qnty    like ub.rvs-line-pump.meas-el-cnt
field prev-start-el-qnty like ub.rvs-line-pump.meas-el-cnt
field doc-qnty       as decimal INITIAL 0
field delta          as decimal INITIAL 0
field cancell-qnty      as decimal INITIAL 0
field cancell-qnty-notot as decimal INITIAL 0
field overflow-qnty     as decimal INITIAL 0
field trans-qnty        as decimal INITIAL 0
field tech-refuell-qnty as decimal INITIAL 0
index pi is unique primary
  gds-code
  pump-code
  nozzle-code
.
function is-sug returns logical
        (input p-gds-code as integer):
define variable result as logical no-undo.
define variable c-value as character no-undo.
define variable c-type as character no-undo.
do on error undo, return error:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  'fuel-type':U
      ,output c-value
      ,output c-type) no-error.
end.
result = logical(c-value = 'lgas':U) no-error.
return result.
end function.
  define temp-table with-action no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
field t_name as character
field num_ as integer
field uniq-key-rec as character
field action as integer
field fNotChange as logical
index pi is unique primary
num_
t_name
f_name
index
Chan
fnotChange
t_name
f_name
index imain uniq-key-rec
.
procedure c-place_get-attr :
  define input parameter attr-code as character no-undo .
  define input parameter obj-code as integer no-undo .
  define input parameter obj-type as character no-undo .
  define input parameter pl-code as integer no-undo .
  define input parameter endDate as date no-undo .
  define input parameter endTime as integer no-undo .
  define output parameter attr-value as character no-undo .
  define buffer bf_c-place-attr for ub.c-place-attr .
  define variable is-place-attr as logical no-undo .
  find last bf_c-place-attr no-lock where bf_c-place-attr.pl-code = pl-code and
    bf_c-place-attr.obj-code = obj-code and
    bf_c-place-attr.obj-type = obj-type and
    bf_c-place-attr.attr-code = attr-code and
    ((bf_c-place-attr.corr-date = endDate and
    bf_c-place-attr.corr-time < endTime) or
    bf_c-place-attr.corr-date < endDate) no-error .
  if available (bf_c-place-attr) then attr-value = bf_c-place-attr.attr-value .
  else attr-value = "true" .
end procedure.
FUNCTION get_max-qnty returns decimal (
  input obj-code as integer,
  input obj-type as character,
  input pl-code as integer,
  input endDate as date,
  input endTime as integer ):
  define buffer bf_c-place     for ub.c-place .
  define buffer buf_c-place    for ub.c-place .
  define buffer bf_place       for ub.place .
  define buffer curr_c-place   for c-place .
  define buffer buf_c-plc-hist for ub.c-plc-hist .
  define variable ii      as integer no-undo init 0.
  define variable is-max-qnty as logical no-undo .
  define variable is-true as logical no-undo .
  find last curr_c-place no-lock where curr_c-place.pl-code = pl-code and
    curr_c-place.obj-code = obj-code and
    curr_c-place.obj-type = obj-type and
    ((curr_c-place.corr-date = endDate and
    curr_c-place.corr-time < endTime) or
    curr_c-place.corr-date < endDate) no-error .
  if available (curr_c-place) then
  do:
    find first buf_c-plc-hist no-lock where
      buf_c-plc-hist.obj-type = obj-type
      AND buf_c-plc-hist.obj-code = obj-code
      AND buf_c-plc-hist.pl-code = pl-code
      AND buf_c-plc-hist.subject  = "place"
      and buf_c-plc-hist.chip-num = curr_c-place.chip-num no-error .
    if available (buf_c-plc-hist) then
    do:
      define variable v-label-param as character no-undo .
      v-label-param =
        "max-qnty" + chr(4) + "Максимальное количество" + chr(4) + "" .
      run proc-full-temp-changes in this-procedure (
        input buf_c-plc-hist.action = integer('1':U)
        ,input buf_c-plc-hist.action = integer('99':U)
        ,input  buffer curr_c-place:handle
        ,input  'place':U
        ,input  "max-qnty"
        ,input  v-label-param).
    end.
  end.
  for each with-action:
    return decimal(with-action.v_new) .
  end.
  if available (curr_c-place) then
  do:
    return curr_c-place.max-qnty .
  end.
  find first bf_place no-lock where bf_place.pl-code = pl-code and
    bf_place.obj-code = obj-code and
    bf_place.obj-type = obj-type no-error .
  return bf_place.max-qnty .
end function.
FUNCTION get_meas returns logical (
  input obj-code as integer,
  input obj-type as character,
  input pl-code as integer,
  input endDate as date,
  input endTime as integer ):
  define buffer bf_c-place     for ub.c-place .
  define buffer buf_c-place    for ub.c-place .
  define buffer bf_place       for ub.place .
  define buffer curr_c-place   for c-place .
  define buffer buf_c-plc-hist for ub.c-plc-hist .
  define variable ii      as integer no-undo init 0.
  define variable is-meas as logical no-undo .
  define variable is-true as logical no-undo .
  find last curr_c-place no-lock where curr_c-place.pl-code = pl-code and
    curr_c-place.obj-code = obj-code and
    curr_c-place.obj-type = obj-type and
    ((curr_c-place.corr-date = endDate and
    curr_c-place.corr-time < endTime) or
    curr_c-place.corr-date < endDate) no-error .
  if available (curr_c-place) then
  do:
    find first buf_c-plc-hist no-lock where
      buf_c-plc-hist.obj-type = obj-type
      AND buf_c-plc-hist.obj-code = obj-code
      AND buf_c-plc-hist.pl-code = pl-code
      AND buf_c-plc-hist.subject  = "place"
      and buf_c-plc-hist.chip-num = curr_c-place.chip-num no-error .
    if available (buf_c-plc-hist) then
    do:
      define variable v-label-param as character no-undo .
      v-label-param =
        "is-meas" + chr(4) + "Измеряется приборами" + chr(4) + "" .
      run proc-full-temp-changes in this-procedure (
        input buf_c-plc-hist.action = integer('1':U)
        ,input buf_c-plc-hist.action = integer('99':U)
        ,input  buffer curr_c-place:handle
        ,input  'place':U
        ,input  "is-meas"
        ,input  v-label-param).
    end.
  end.
  for each with-action:
    return logical (with-action.v_new) .
  end.
  find first bf_place no-lock where bf_place.pl-code = pl-code and
    bf_place.obj-code = obj-code and
    bf_place.obj-type = obj-type no-error .
  return bf_place.is-meas .
end function.
FUNCTION get_com-vessel returns logical (
  input obj-code as integer,
  input obj-type as character,
  input attr-code as character,
  input pl-code as integer,
  input openDate as date,
  input endDate as date,
  input openTime as integer,
  input endTime as integer ):
  define buffer current_c-place-attr for c-place-attr .
  define buffer buf_c-plc-hist       for ub.c-plc-hist .
  define variable ii      as integer   no-undo init 0.
  define variable is-meas as logical   no-undo .
  define variable is-true as logical   no-undo .
  define variable v-label as character no-undo .
  define variable p-ok    as logical   no-undo .
  find last current_c-place-attr no-lock where
    current_c-place-attr.obj-type = obj-type
    AND current_c-place-attr.obj-code = obj-code
    AND current_c-place-attr.pl-code = pl-code
    and current_c-place-attr.attr-code = attr-code
    and ((current_c-place-attr.corr-date = endDate
    and current_c-place-attr.corr-time < endTime) or
    current_c-place-attr.corr-date < endDate)
    no-error .
  if avail current_c-place-attr then
  do:
    find first buf_c-plc-hist no-lock where
      buf_c-plc-hist.obj-type = obj-type
      AND buf_c-plc-hist.obj-code = obj-code
      AND buf_c-plc-hist.pl-code = pl-code
      AND buf_c-plc-hist.subject  = "place-attr"
      and buf_c-plc-hist.chip-num = current_c-place-attr.chip-num no-error .
    if available (buf_c-plc-hist) then
    do:
      define variable v-label-param as character no-undo .
      if current_c-place-attr.attr-code = "place-SI"
        or current_c-place-attr.attr-code = "place-SI-temp"
        or current_c-place-attr.attr-code = "place-SI-dens"
        or current_c-place-attr.attr-code = "place-SI-level"
        then
      do :
        v-label-param =
          "attr-value" + chr(4) + "Значение атрибута" + chr(4) + "getSIname" + chr(8)
          + "attr-code" + chr(4) + "Код атрибута" + chr(4) + "getPlaceAttrCode"   .
      end .
      else
      do :
        v-label-param =
          "attr-value" + chr(4) + "Значение атрибута" + chr(4) + "getPlaceAttrValue" + chr(8)
          + "attr-code" + chr(4) + "Код атрибута" + chr(4) + "getPlaceAttrCode" + chr(8)
          + "PS" + chr(4) + "Примечание" + chr(4) + "" + chr(8)
          + "status_" + chr(4) + "Статус" + chr(4) + ""  .
      end .
      run proc-full-temp-changes in this-procedure (
        input buf_c-plc-hist.action = integer('1':U)
        ,input buf_c-plc-hist.action = integer('99':U)
        ,input  buffer current_c-place-attr:handle
        ,input  'place-attr':U
        ,input  "attr-code,attr-value,PS,status_"
        ,input  v-label-param).
    end.
  end.
  for each with-action:
    p-ok = logical (with-action.v_new) no-error .
    if error-status:error then p-ok = false .
    return   p-ok .
  end.
  return no .
end function.
FUNCTION get_com-tanks returns character (
  input obj-code as integer,
  input obj-type as character,
  input attr-code as character,
  input pl-code as integer,
  input openDate as date,
  input endDate as date,
  input openTime as integer,
  input endTime as integer ):
  define buffer current_c-place-attr for ub.c-place-attr .
    define buffer buf_c-plc-hist       for ub.c-plc-hist .
  define variable ii        as integer   no-undo init 0.
  define variable is-meas   as logical   no-undo .
  define variable is-true   as logical   no-undo .
  define variable v-label   as character no-undo .
  define variable p-ok as character no-undo .
  find last current_c-place-attr no-lock where
    current_c-place-attr.obj-type = obj-type
    AND current_c-place-attr.obj-code = obj-code
    AND current_c-place-attr.pl-code = pl-code
    and current_c-place-attr.attr-code = attr-code
    and ((current_c-place-attr.corr-date = endDate
    and current_c-place-attr.corr-time < endTime) or
    current_c-place-attr.corr-date < endDate)
    no-error .
  if avail current_c-place-attr then
  do:
    find first buf_c-plc-hist no-lock where
      buf_c-plc-hist.obj-type = obj-type
      AND buf_c-plc-hist.obj-code = obj-code
      AND buf_c-plc-hist.pl-code = pl-code
      AND buf_c-plc-hist.subject  = "place-attr"
      and buf_c-plc-hist.chip-num = current_c-place-attr.chip-num no-error .
    if available (buf_c-plc-hist) then
    do:
      define variable v-label-param as character no-undo .
      if current_c-place-attr.attr-code = "place-SI"
        or current_c-place-attr.attr-code = "place-SI-temp"
        or current_c-place-attr.attr-code = "place-SI-dens"
        or current_c-place-attr.attr-code = "place-SI-level"
        then
      do :
        v-label-param =
          "attr-value" + chr(4) + "Значение атрибута" + chr(4) + "getSIname" + chr(8)
          + "attr-code" + chr(4) + "Код атрибута" + chr(4) + "getPlaceAttrCode"   .
      end .
      else
      do :
        v-label-param =
          "attr-value" + chr(4) + "Значение атрибута" + chr(4) + "getPlaceAttrValue" + chr(8)
          + "attr-code" + chr(4) + "Код атрибута" + chr(4) + "getPlaceAttrCode" + chr(8)
          + "PS" + chr(4) + "Примечание" + chr(4) + "" + chr(8)
          + "status_" + chr(4) + "Статус" + chr(4) + ""  .
      end .
      run proc-full-temp-changes in this-procedure (
        input buf_c-plc-hist.action = integer('1':U)
        ,input buf_c-plc-hist.action = integer('99':U)
        ,input  buffer current_c-place-attr:handle
        ,input  'place-attr':U
        ,input  "attr-code,attr-value,PS,status_"
        ,input  v-label-param).
    end.
  end.
  for each with-action:
     p-ok = with-action.v_new no-error .
     if error-status:error then p-ok = "" .
    return   p-ok .
  end.
  return "" .
end function.
function getSIname returns character (si-code as char) :
  for first sr-izmerenia no-lock where sr-izmerenia.node-code = integer(si-code) :
    return sr-izmerenia.sr-model .
  end .
end .
function  getPlaceAttrCode returns character (istr as char ):
  define variable OStr as character no-undo.
  if istr eq "disable-level-alarm"
    then
    OStr = "Сообщения о переполнении".
  else if istr eq "disable-water-alarm"
      then
      OStr = "Сообщения по воде".
    else if istr eq "place-need-RVD-rvs"
        then
        OStr = "Необходимо сделать сверку с РВД".
      else if istr eq "place-SI-level"
          then
          OStr = "Доп. средство измерения уровня".
        else if istr eq "place-SI-dens"
            then
            OStr = "Доп. средство измерения плотности".
          else if istr eq "place-SI-temp"
              then
              OStr = "Доп. средство измерения температуры".
            else if istr eq "place-SI"
                then
                OStr = "Основное средство измерения".
              else
                OStr = istr.
  return OStr.
end.
function  getPlaceAttrValue returns character (istr as char ):
  define variable OStr  as character no-undo.
  define variable vFlag as logical   no-undo.
  if    entry(1,istr,chr(4)) eq "enable"
    then
    assign
      OStr  = "Включено"
      vFlag = yes
      .
  else if    entry(1,istr,chr(4)) eq "disable"
      then
      assign
        OStr  = "Выключено"
        vFlag = yes
        .
    else
      OStr = istr.
  if     vFlag
    and num-entries (istr,chr(4)) > 2
    then
    OStr = OStr + " для смены № " + entry(3,istr,chr(4)) + " Дата " + entry(2,istr,chr(4)).
  return OStr.
end.
PROCEDURE proc-full-temp-changes :
  define input  parameter p-act-create as logical   no-undo .
  define input  parameter p-act-delete as logical   no-undo .
  define input  parameter p-hst-handle as handle    no-undo .
  define input  parameter p-main-table as character no-undo .
  define input  parameter p-field-list as character no-undo .
  define input  parameter p-label-form as character no-undo .
  define variable h-new-buf         as handle    no-undo .
  define variable h-main-buf        as handle    no-undo .
  define variable h-for-comp        as handle    no-undo .
  define variable v-inform          as character no-undo .
  define variable v-ind             as integer   no-undo .
  define variable v-idx-field-qnty  as integer   no-undo .
  define variable v-num-entries     as integer   no-undo .
  define variable fh                as handle    no-undo .
  define variable fh-main           as handle    no-undo .
  define variable fh-old            as handle    no-undo .
  define variable fh-new            as handle    no-undo .
  define variable v-field-name      as character no-undo .
  define variable v-field-lvl       as character no-undo .
  define variable v-field-form      as character no-undo .
  define variable v-search-exp      as character no-undo .
  define variable v-srch-main       as character no-undo .
  define variable v-word-link       as character no-undo .
  define variable v-av-chip-num     as logical   no-undo .
  define variable v-main-pi-fld-lst as character no-undo .
  define variable v-main-fld-lst    as character no-undo .
  define variable v-delim-list      as character no-undo .
  define variable v-label           as character no-undo .
  define variable v-old-value       as character no-undo case-sensitive.
  define variable v-new-value       as character no-undo case-sensitive.
  define variable v-chg-fields      as character no-undo.
  for each with-action:
    delete with-action.
  end.
  if not p-hst-handle:available then
  do:
    return .
  end.
  create buffer h-new-buf  for table p-hst-handle .
  create buffer h-main-buf for table p-main-table .
  assign
    v-inform = h-main-buf:index-information(1)
    v-ind    = 2
    .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
    assign
      v-inform = h-main-buf:index-information( v-ind )
      v-ind    = v-ind + 1
      .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
    then
  do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, h-main-buf:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
    .
  if v-idx-field-qnty < 2 then
  do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, h-main-buf:name ).
  end.
  assign
    v-srch-main   = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
    v-delim-list  = "":U
    .
  do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
    assign
      v-field-name      = entry( 4 + v-ind, v-inform, ",":U )
      fh                = p-hst-handle:buffer-field( v-field-name )
      fh-main           = h-main-buf:buffer-field( v-field-name )
      v-srch-main       = substitute( "&1 &2 &3.&4 =", v-srch-main, v-word-link, fh-main:table, v-field-name )
      v-main-pi-fld-lst = v-main-pi-fld-lst + v-delim-list + v-field-name
      .
    if fh:data-type ="character":U then
    do:
      assign
        v-srch-main = substitute( '&1 "&2"', v-srch-main, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
        .
    end.
    else
    do:
      assign
        v-srch-main = substitute( "&1 &2", v-srch-main, fh:buffer-value() )
        .
    end.
    if v-delim-list = "":U then
    do:
      assign
        v-delim-list = ",":U
        .
    end.
    if v-word-link = "":U then
    do:
      assign
        v-word-link = "and":U
        .
    end.
  end.
  assign
    v-delim-list = "":U
    .
  do v-ind = 1 to h-main-buf:num-fields
    on error undo, return error
    :
    assign
      fh-main      = h-main-buf:buffer-field( v-ind )
      v-field-name = fh-main:name
      .
    assign
      v-main-fld-lst = v-main-fld-lst + v-delim-list + v-field-name
      .
    if v-delim-list = "":U then
    do:
      assign
        v-delim-list = ",":U
        .
    end.
  end.
  assign
    v-inform = p-hst-handle:index-information(1)
    v-ind    = 2
    .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
    assign
      v-inform = p-hst-handle:index-information( v-ind )
      v-ind    = v-ind + 1
      .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
    then
  do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, p-hst-handle:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
    .
  if v-idx-field-qnty < 2 then
  do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, p-hst-handle:name ).
  end.
  assign
    v-search-exp  = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
    .
  do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
    assign
      v-field-name = entry( 4 + v-ind, v-inform, ",":U )
      fh           = p-hst-handle:buffer-field( v-field-name )
      v-search-exp = substitute( "&1 &2 &3.&4", v-search-exp, v-word-link, fh:table, v-field-name )
      .
    if v-field-name = "chip-num":U then
    do:
      assign
        v-search-exp  = substitute( "&1 >", v-search-exp )
        v-av-chip-num = true
        .
    end.
    else
    do:
      assign
        v-search-exp = substitute( "&1 =", v-search-exp )
        .
    end.
    if fh:data-type ="character":U then
    do:
      assign
        v-search-exp = substitute( '&1 "&2"', v-search-exp, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
        .
    end.
    else
    do:
      assign
        v-search-exp = substitute( '&1 &2', v-search-exp, fh:buffer-value() )
        .
    end.
    if v-word-link = "":U then
    do:
      assign
        v-word-link = "and":U
        .
    end.
  end.
  if v-av-chip-num = false then
  do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Таблица &2 не содержит поля chip-num.", vss-workfile, p-hst-handle:name ) skip
      "Использование данной процедуры невозможно!" skip
      view-as alert-box error .
    return error .
  end.
  h-new-buf:find-first( v-search-exp, no-lock ) no-error .
  if not h-new-buf:available then
  do:
    h-main-buf:find-first( v-srch-main, no-lock ) no-error .
    if not h-main-buf:available then
    do:
      assign
        h-for-comp = ?
        .
    end.
    else
    do:
      assign
        h-for-comp = h-main-buf
        .
    end.
  end.
  else
  do:
    assign
      h-for-comp = h-new-buf
      .
  end.
  assign
    v-num-entries = num-entries( v-main-fld-lst, ",":U )
    .
  do v-ind = 1 to v-num-entries
    on error undo, return error return-value
    :
    assign
      v-field-name = entry( v-ind, v-main-fld-lst )
      fh-old       = p-hst-handle:buffer-field( v-field-name )
      v-old-value  = fh-old:buffer-value()
      v-label      = trim( fh-old:label )
      .
    if ( trim( p-field-list ) <> "":U
      and lookup( v-field-name, p-field-list ) > 0
      )
      or trim( p-field-list ) = "":U
      then
    do:
      if h-for-comp <> ? then
      do:
        assign
          fh-new      = h-for-comp:buffer-field( v-field-name )
          v-new-value = fh-new:buffer-value()
          .
      end.
      else
      do:
        assign
          v-new-value = "":U
          .
      end.
      if p-act-create = true then
      do:
        assign
          v-old-value = "":U
          .
      end.
      if p-act-delete = true then
      do:
        assign
          v-new-value = "":U
          .
      end.
      if v-old-value <> v-new-value
        then
      do:
        create with-action.
        assign
          with-action.t_name     = p-main-table
          with-action.f_name     = v-field-name
          with-action.l_name     = replace( v-label, "&":U, "":U )
          with-action.v_old      = trim( v-old-value )
          with-action.v_new      = trim( v-new-value )
          with-action.num_       = 0
          with-action.fNotChange = v-old-value eq v-new-value
          .
      end.
    end.
  end.
  assign
    v-num-entries = num-entries( p-label-form, chr(8) )
    .
  do v-ind = 1 to v-num-entries
    on error undo, return error return-value
    :
    if num-entries( entry( v-ind, p-label-form, chr(8) ), chr(4) ) = 3 then
    do:
      assign
        v-field-name = entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-lvl  = entry( 2, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-form = entry( 3, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        .
      find first with-action
        where with-action.f_name = v-field-name
        no-error .
      if available with-action then
      do:
        if trim( v-field-lvl ) <> "":U then
        do:
          assign
            with-action.l_name = v-field-lvl
            .
        end.
        if trim( v-field-form ) <> "":U then
        do:
          assign
            with-action.v_old = dynamic-function( v-field-form, with-action.v_old )
            .
          if h-for-comp <> ? then
          do:
            assign
              with-action.v_new = dynamic-function( v-field-form, with-action.v_new )
              .
          end.
        end.
      end.
    end.
    else
    do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка! Список должен содержать три поля с разделителем delim-par!" skip
        substitute( "список для поля '&1': '&2'"
        ,entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        ,entry( v-ind, p-label-form, chr(8) )
        ) skip
        substitute( "полный список: &2", p-label-form ) skip
        view-as alert-box error .
    end.
  end.
  delete object h-new-buf .
  delete object h-main-buf .
END PROCEDURE.
  define variable v-stfactpl          as character no-undo initial "":U .
  define variable v-data-type         as character no-undo initial "":U .
  define variable v-update            as logical   no-undo initial yes  .
  define variable v-revision          as logical   no-undo initial no   .
  define variable v-percrev           as decimal   no-undo initial ?    .
  define variable v-auto-tank         as logical   no-undo initial no   .
  define variable v-percauto          as decimal   no-undo initial ?    .
  define variable v-inv               as logical   no-undo initial no   .
  define variable v-percinv           as decimal   no-undo initial ?    .
  define variable v-inv-set           as logical   no-undo initial no   .
  define variable v-rn-algo           as logical   no-undo initial no   .
  define variable stfactplvalue       as character no-undo .
  define variable stfactpltype        as character no-undo .
  define variable v-InfoSectionsTotal as class     InfoSectionsTotal no-undo .
  define variable v-InfoSection       as class     InfoSection       no-undo .
  define variable iNum                as integer   no-undo .
  define shared stream Prnlibstream.
  procedure on-same-page :
    define input parameter p-line-number as integer no-undo .
    if p-line-number > page-size( PrnLibstream )
    then do:
      return .
    end.
    if line-counter( PrnLibstream ) + p-line-number > page-size( PrnLibstream )
    then do:
      page stream PrnLibstream .
    end.
  end procedure.
  define variable last-gds-code            as integer no-undo initial 0.
  define variable accum-by-pl-code-pol3-l  as decimal no-undo.
  define variable accum-by-pl-code-pol3-kg as decimal no-undo.
  define variable accum-pol7               as decimal no-undo.
  define variable accum-by-pl-code-pol7    as decimal no-undo.
  define variable v-gds-print              as logical no-undo.
  define variable v-bc-print               as logical no-undo .
  define variable pobj-type                like ub.stk-tot.obj-type no-undo .
  define variable pobj-code                like ub.stk-tot.obj-code no-undo .
  define variable pshift-date              like ub.stk-tot.shift-date no-undo .
  define variable pshift-num               like ub.stk-tot.shift-num no-undo .
  define variable pshift-date1             like ub.stk-tot.shift-date no-undo .
  define variable pshift-num1              like ub.stk-tot.shift-num no-undo .
  define variable v-qnty-row               as integer no-undo .
  define variable v-qnty-row1              as integer no-undo .
  define buffer previous-rvs-doc       for ub.rvs-doc.
  define buffer previous-rvs-line      for ub.rvs-line.
  define buffer previous-rvs-line-pump for ub.rvs-line-pump.
  define buffer last-rvs-doc           for ub.rvs-doc.
  define buffer last-rvs-line          for ub.rvs-line.
  define buffer last-rvs-line-pump     for ub.rvs-line-pump.
  define buffer control-rvs-doc        for ub.rvs-doc.
  define buffer control-rvs-line-pump  for ub.rvs-line-pump.
  define buffer buf_shift-pgds         for shift-pgdst.
  define buffer buf_rvs-line-attr      for ub.rvs-line-attr.
  define buffer buf_prev-rvs-line-attr for ub.rvs-line-attr.
  define buffer buf_control-rvs-doc    for ub.rvs-doc.
  define variable i-rvs-code  as character no-undo.
  define variable p-host-code as integer   no-undo.
  define variable v-sign      as decimal   no-undo .
  define temp-table tt-pump-nozzle no-undo
    field gds-code    like ub.rvs-line.gds-code
    field pump-code   like ub.rvs-line-pump.pump-code
    field nozzle-code like ub.rvs-line-pump.nozzle-code
    index pi as unique primary
    gds-code
    pump-code
    nozzle-code
    .
  define temp-table temp-line-pump no-undo
    field gds-code              like ub.rvs-line.gds-code
    field pump-code             like ub.rvs-line-pump.pump-code
    field nozzle-code           like ub.rvs-line-pump.nozzle-code
    field state-mh-cnt          like ub.rvs-line-pump.state-mh-cnt
    field state-el-cnt          like ub.rvs-line-pump.state-el-cnt
    field previous-state-mh-cnt like previous-rvs-line-pump.state-mh-cnt
    field previous-state-el-cnt like previous-rvs-line-pump.state-el-cnt
    field pol6                  like ub.rvs-line-pump.state-mh-cnt format '>>9.99'
    field pol7                  like ub.rvs-line-pump.state-mh-cnt
    field pol8-l                as decimal
    field pol8-kg               as decimal
    field pol9-l                as decimal
    field pol9-kg               as decimal
    field pol10                 as decimal
    field pol11                 as decimal
    field pol12                 as decimal
    field pl-code               like ub.rvs-line-pump.pl-code
    field loc1                  as character
    field log_                  as logical
    field error-19              like ub.rvs-line-pump.state-el-cnt
    index pi as unique primary
    gds-code
    pl-code
    loc1
    nozzle-code
    pump-code
    .
  define VARIABLE num-pol8-l   as DECIMAL no-undo .
  define VARIABLE num-pol8-kg  as DECIMAL no-undo .
  define VARIABLE num-pol20-l  as DECIMAL no-undo .
  define VARIABLE num-pol20-kg as DECIMAL no-undo .
  define temp-table temp-rvs-line no-undo LIKE UB.RVS-LINE
    field gds-name         like ub.goods.gds-name
    field place_loc1       like ub.place.loc1 initial "??"
    field nozzle-code      like ub.rvs-line-pump.nozzle-code
    field pump-code        like ub.rvs-line-pump.pump-code
    field artic            as character
    field prod-type        as character
    field prod-code        as integer
    field shift-date       as date
    field shift-num        as integer
    field v-bar-code       as integer
    field pol4-l-state     as decimal
    field pol4-kg-state    as decimal
    field pol4-l-system    as decimal
    field pol4-kg-system   as decimal
    field itog-pol4-l      as decimal
    field itog-pol4-kg     as decimal
    field pol5-l           as decimal
    field pol5-kg          as decimal
    field itog-pol5-l      as decimal
    field itog-pol5-kg     as decimal
    field pol6             as decimal
    field pol61            as decimal
    field pol62            as logical
    field itog-pol6        as decimal
    field pol7-l           as decimal
    field itog-pol7-l      as decimal
    field pol8-l           as decimal
    field itog-pol8-l      as decimal
    field pol7-kg          as decimal
    field itog-pol7-kg     as decimal
    field pol8-kg          as decimal
    field itog-pol8-kg     as decimal
    field pol9             as decimal
    field itog-pol9        as decimal
    field pol10            as decimal
    field itog-pol10       as decimal
    field pol11            as decimal
    field itog-pol11       as decimal
    field pol12            as decimal
    field itog-pol12       as decimal
    field pol13            as decimal
    field itog-pol13       as decimal
    field pol14            as decimal
    field pol15            as decimal
    field pol16            as decimal
    field itog-pol16       as decimal
    field pol16-l          as decimal
    field itog-pol16-l     as decimal
    field pol16-kg         as decimal
    field itog-pol16-kg    as decimal
    field pol17-l          as decimal
    field pol17-kg         as decimal
    field itog-pol17-l     as decimal
    field itog-pol17-kg    as decimal
    field pol18            as decimal
    field itog-pol18       as decimal
    field pol19            as decimal
    field pol20-l          as decimal
    field itog-pol20-l     as decimal
    field pol20-kg         as decimal
    field itog-pol20-kg    as decimal
    field pol21-l          as decimal
    field pol21-kg         as decimal
    field itog-pol21-l     as decimal
    field itog-pol21-kg    as decimal
    field pol22            as decimal
    field fact-pl          as decimal
    field pol21_tech       as decimal
    field pol21_nebal      as decimal
    field itog-pol21_tech  as decimal
    field itog-pol21_nebal as decimal
    .
  define temp-table temp-rvs-line-itog no-undo like ub.rvs-line
    field gds-name      like ub.goods.gds-name
    field place_loc1    like ub.place.loc1 initial "??"
    field nozzle-code   like ub.rvs-line-pump.nozzle-code
    field pump-code     like ub.rvs-line-pump.pump-code
    field artic         as character
    field prod-type     as character
    field prod-code     as integer
    field shift-date    as date
    field shift-num     as integer
    field v-bar-code    as integer
    field itog-pol4-l   as decimal
    field itog-pol4-kg  as decimal
    field itog-pol5-l   as decimal
    field itog-pol5-kg  as decimal
    field itog-pol6     as decimal
    field itog-pol7-l   as decimal
    field itog-pol8-kg  as decimal
    field itog-pol7-kg  as decimal
    field itog-pol8-l   as decimal
    field itog-pol9     as decimal
    field itog-pol10    as decimal
    field itog-pol11    as decimal
    field itog-pol12    as decimal
    field itog-pol13    as decimal
    field itog-pol16    as decimal
    field itog-pol17-l  as decimal
    field itog-pol17-kg as decimal
    field itog-pol18    as decimal
    field itog-pol20-l  as decimal
    field itog-pol20-kg as decimal
    .
  define variable v-count   as integer no-undo .
  define variable v-count2  as integer no-undo .
  define variable ii        as integer no-undo .
  define variable v-tot-cnt as integer no-undo .
  define buffer buf_rvs-line-pump for ub.rvs-line-pump .
  define buffer buf_temp-rvs-line for temp-rvs-line .
  define buffer buf_chk-gds       for ub.chk-gds .
  define buffer buf_bar-code      for ub.bar-code .
  define buffer buf_chk-doc       for ub.chk-doc .
  define buffer buf_goods         for ub.goods .
  define buffer buf_place         for ub.place .
  define buffer bf_temp-rvs-line  for temp-rvs-line .
  define buffer buf_rvs-doc       for ub.rvs-doc .
  define variable v-counter        as integer no-undo.
  define variable v-fact-order-inv as decimal no-undo .
  define buffer buf_temp-line-pump for temp-line-pump .
  define buffer com_temp-rvs-line  for temp-rvs-line .
  define stream Out-Stream.
  define stream OutStr-html.
  assign
    pobj-type    = p-obj-type
    pobj-code    = p-obj-code
    pshift-date  = x-date-Start
    pshift-num   = x-shift-Start
    pshift-date1 = x-date-End
    pshift-num1  = x-shift-End
    .
define buffer end_shift-obj      for ub.shift-obj .
define buffer previous-shift-obj for ub.shift-obj.
define variable fo      as decimal no-undo init 0.
define variable prev-fo as decimal no-undo init 0.
define variable moving  as logical no-undo init yes.
find first end_shift-obj share-lock
  where end_shift-obj.obj-type   = pobj-type
    and end_shift-obj.obj-code   = pobj-code
    and end_shift-obj.shift-date = pshift-date1
    and end_shift-obj.shift-num  = pshift-num1
    no-error.
if not available end_shift-obj then do:
  message
    vss-workfile vss-revision vss-description skip
    substitute("Не найдена смена с порядковым номером &1 от &2 для объекта &3 &4", pshift-num1, pshift-date1, pobj-type, pobj-code ) skip
    view-as alert-box error .
  return error.
end.
else do:
  assign
    fo = end_shift-obj.fact-order
  .
end.
find last previous-shift-obj share-lock
  where previous-shift-obj.obj-type = pobj-type
    and previous-shift-obj.obj-code = pobj-code
    and (( previous-shift-obj.shift-date = pshift-date
           and previous-shift-obj.shift-num < pshift-num
         )
         or previous-shift-obj.shift-date < pshift-date
        )
    use-index pi no-error.
if available previous-shift-obj then do:
    assign
      prev-fo = previous-shift-obj.fact-order
    .
end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output p-host-code
  )  .
  v-InfoSectionsTotal = new InfoSectionsTotal().
  v-InfoSection = new InfoSection().
  define buffer buf_trn-doc for ub.trn-doc .
  find first last-rvs-doc no-lock
    where last-rvs-doc.obj-type   = p-obj-type
    and last-rvs-doc.obj-code   = p-obj-code
    and last-rvs-doc.shift-date = x-date-end
    and last-rvs-doc.shift-num  = x-shift-end
    and last-rvs-doc.status_    = 'факт':U
    and last-rvs-doc.rvs-type   = 'смена':U
    no-error.
  if not available last-rvs-doc then
  do:
      if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("&1 &2 &3&4Не найдена сменная сверка&4объект &5&6 смена &7 &8"                                 ,vss-workfile                                 ,vss-revision                                 ,vss-description                                ,chr(10)                                ,p-obj-type                                 ,p-obj-code                                 ,string(x-date-End, "99/99/9999")                                ,x-shift-end )).    end.    else do:       run write-to-log in p-log-handle ( input substitute("&1 &2 &3&4Не найдена сменная сверка&4объект &5&6 смена &7 &8"                                 ,vss-workfile                                 ,vss-revision                                 ,vss-description                                ,chr(10)                                ,p-obj-type                                 ,p-obj-code                                 ,string(x-date-End, "99/99/9999")                                ,x-shift-end )).    end.
    if valid-handle(p-parent-handle)
      and lookup("cb_write-report-error", p-parent-handle:internal-entries) > 0
      and valid-handle(p-rebh) then
    do:
      run cb_write-report-error in p-parent-handle ( input p-rebh
        ,input v-report-name-html
        ,input ?
        ,input '3':U
        ,input substitute("&1 &2 &3&4Не найдена сменная сверка&4объект &5&6 смена &7 &8"                                 ,vss-workfile                                 ,vss-revision                                 ,vss-description                                ,chr(10)                                ,p-obj-type                                 ,p-obj-code                                 ,string(x-date-End, "99/99/9999")                                ,x-shift-end )).
    end.
    return error.
  END.
  if available previous-shift-obj then
  do:
    find first previous-rvs-doc no-lock
      where previous-rvs-doc.obj-type   = p-obj-type
      and previous-rvs-doc.obj-code   = p-obj-code
      and previous-rvs-doc.shift-date = previous-shift-obj.shift-date
      and previous-rvs-doc.shift-num  = previous-shift-obj.shift-num
      and previous-rvs-doc.status_    = 'факт':U
      and previous-rvs-doc.rvs-type   = 'смена':U
      no-error.
  end.
  define temp-table temp-shift-obj no-undo like ub.shift-obj
    FIELD num as integer
    INDEX ii IS UNIQUE num
    .
  for each ub.rvs-doc no-lock
    where ub.rvs-doc.obj-type   = p-obj-type
    and ub.rvs-doc.obj-code   = p-obj-code
    and ub.rvs-doc.shift-date >= x-date-Start
    and ub.rvs-doc.shift-date <= x-date-End
    and ub.rvs-doc.status_    = 'факт':U
    and ub.rvs-doc.rvs-type   = 'смена':U
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    :
    if ub.rvs-doc.shift-date = x-date-Start and ub.rvs-doc.shift-num < x-Shift-Start then next .
    if ub.rvs-doc.shift-date = x-date-End   and ub.rvs-doc.shift-num > x-Shift-End then next .
    for each ub.rvs-line no-lock
      where ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
      :
      find first temp-rvs-line
        where temp-rvs-line.pl-code  = ub.rvs-line.pl-code
        and temp-rvs-line.gds-code = ub.rvs-line.gds-code
        no-error .
      if not available temp-rvs-line then
      do:
        create temp-rvs-line .
        buffer-copy ub.rvs-line to temp-rvs-line .
        find first ub.goods no-lock
          where ub.goods.gds-code = ub.rvs-line.gds-code
          no-error.
        assign
          temp-rvs-line.gds-name   = ub.goods.gds-name
          temp-rvs-line.artic      = ub.goods.artic
          temp-rvs-line.prod-type  = ub.goods.prod-type
          temp-rvs-line.prod-code  = ub.goods.prod-code
          temp-rvs-line.shift-date = ub.rvs-doc.shift-date
          temp-rvs-line.shift-num  = ub.rvs-doc.shift-num
          .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  ub.goods.gds-code
  ,input  ?
  ,output temp-rvs-line.v-bar-code
  )  .
        find first ub.place no-lock
          where ub.place.obj-code = p-obj-code
          and ub.place.obj-type = p-obj-type
          and ub.place.pl-code  = ub.rvs-line.pl-code
          no-error.
        if available ub.place then
        do:
          assign
            temp-rvs-line.place_loc1 = ub.place.loc1
            .
        end.
      end.
      else
      do:
        if temp-rvs-line.shift-date < ub.rvs-doc.shift-date
          or ( temp-rvs-line.shift-date = ub.rvs-doc.shift-date
          and temp-rvs-line.shift-num  < ub.rvs-doc.shift-num
          )
          then
        do:
          buffer-copy ub.rvs-line to temp-rvs-line .
        end.
      end.
    end.
  end.
  for each temp-rvs-line
    break by temp-rvs-line.gds-code by temp-rvs-line.pl-code
    on error undo, return error return-value
    :
    v-fact-order-inv = 0 .
    find last ub.doc-line no-lock where
      ub.doc-line.fact-order <= fo
      and ub.doc-line.obj-code = temp-rvs-line.obj-code
      and ub.doc-line.obj-type = temp-rvs-line.obj-type
      and ub.doc-line.prod-code = temp-rvs-line.prod-code
      and ub.doc-line.prod-type = temp-rvs-line.prod-type
      and ub.doc-line.artic = temp-rvs-line.artic
      and ub.doc-line.status_ = 'факт':U
      and ub.doc-line.ext-doc-type = 'vt':U no-error .
    if available (ub.doc-line) then v-fact-order-inv = ub.doc-line.fact-order .
    assign
      temp-rvs-line.pol5-l  = 0
      temp-rvs-line.pol5-kg = 0
      .
    for each tt-pump-nozzle
      on error undo, return error return-value
      :
      delete tt-pump-nozzle.
    end.
    if p-tog-1-whole-gds = true then
    do:
      assign
        v-count   = 0
        v-tot-cnt = 0
        .
      for each buf_temp-rvs-line
        where buf_temp-rvs-line.gds-code = temp-rvs-line.gds-code
        break by buf_temp-rvs-line.pl-code
        on error undo, return error return-value
        :
        if first-of( buf_temp-rvs-line.pl-code ) then
        do:
          assign
            v-count2 = 2
            .
          for each buf_rvs-line-pump no-lock
            where buf_rvs-line-pump.rvs-code = buf_temp-rvs-line.rvs-code
            and buf_rvs-line-pump.obj-code = buf_temp-rvs-line.obj-code
            and buf_rvs-line-pump.obj-type = buf_temp-rvs-line.obj-type
            and buf_rvs-line-pump.pl-code  = buf_temp-rvs-line.pl-code
            and buf_rvs-line-pump.gds-code = buf_temp-rvs-line.gds-code
            break by buf_rvs-line-pump.pl-code
            on error undo, return error return-value
            :
            assign
              v-count2 = v-count2 + 1
              .
          end.
          if v-count = 0
            and v-count2 < 4
            then
          do:
            assign
              v-count2 = 4
              .
          end.
          assign
            v-count   = v-count + v-count2
            v-tot-cnt = v-tot-cnt + 1
            .
        end.
      end.
      if v-tot-cnt > 1 then
      do:
        assign
          v-count = v-count + 2
          .
      end.
    end.
    if available previous-rvs-doc then
    do:
      find first previous-rvs-line  no-lock
        where previous-rvs-line.rvs-code = previous-rvs-doc.rvs-code
        and previous-rvs-line.gds-code = temp-rvs-line.gds-code
        and previous-rvs-line.obj-code = temp-rvs-line.obj-code
        and previous-rvs-line.obj-type = temp-rvs-line.obj-type
        and previous-rvs-line.pl-code  = temp-rvs-line.pl-code
        no-error .
    end.
    for each ub.rvs-line-pump no-lock
      where ub.rvs-line-pump.rvs-code = temp-rvs-line.rvs-code
      and ub.rvs-line-pump.gds-code = temp-rvs-line.gds-code
      and ub.rvs-line-pump.obj-code = temp-rvs-line.obj-code
      and ub.rvs-line-pump.obj-type = temp-rvs-line.obj-type
      and ub.rvs-line-pump.pl-code  = temp-rvs-line.pl-code
      :
      for each ub.pl-gds-pump no-lock where ub.pl-gds-pump.pump-code = ub.rvs-line-pump.pump-code
        and ub.pl-gds-pump.pl-code = ub.rvs-line-pump.pl-code
        :
        find first temp-line-pump where temp-line-pump.gds-code = rvs-line-pump.gds-code and temp-line-pump.pl-code = rvs-line-pump.pl-code and temp-line-pump.loc1
          = temp-rvs-line.place_loc1 and temp-line-pump.pump-code    = ub.rvs-line-pump.pump-code and
          temp-line-pump.nozzle-code  = ub.rvs-line-pump.nozzle-code no-error.
        if not AVAILABLE temp-line-pump then
        do:
          create temp-line-pump .
          assign
            temp-line-pump.gds-code     = ub.rvs-line-pump.gds-code
            temp-line-pump.pl-code      = ub.rvs-line-pump.pl-code
            temp-line-pump.state-mh-cnt = ub.rvs-line-pump.state-mh-cnt
            temp-line-pump.state-el-cnt = ub.rvs-line-pump.state-el-cnt
            temp-line-pump.pol6         = temp-line-pump.state-mh-cnt
            temp-line-pump.loc1         = temp-rvs-line.place_loc1
            temp-line-pump.pump-code    = ub.rvs-line-pump.pump-code
            temp-line-pump.nozzle-code  = ub.rvs-line-pump.nozzle-code
            .
        end.
        else
        do:
          assign
            temp-line-pump.state-mh-cnt = ub.rvs-line-pump.state-mh-cnt
            temp-line-pump.state-el-cnt = ub.rvs-line-pump.state-el-cnt
            temp-line-pump.pol6         = temp-line-pump.pol6 + temp-line-pump.state-mh-cnt
            .
        end.
        if available previous-rvs-doc then
        do:
          Find FIRST previous-rvs-line-pump  No-LOCK WHERE
            previous-rvs-line-pump.rvs-code = previous-rvs-doc.rvs-code AND
            previous-rvs-line-pump.obj-code = temp-rvs-line.obj-code  and
            previous-rvs-line-pump.obj-type = temp-rvs-line.obj-type  and
            previous-rvs-line-pump.pl-code  = temp-rvs-line.pl-code AND
            previous-rvs-line-pump.pump-code = ub.rvs-line-pump.pump-code AND
            previous-rvs-line-pump.nozzle-code = ub.rvs-line-pump.nozzle-code No-ERROR.
          IF available previous-rvs-line-pump then
          do:
            assign
              temp-line-pump.previous-state-mh-cnt = previous-rvs-line-pump.state-mh-cnt
              temp-line-pump.previous-state-el-cnt = previous-rvs-line-pump.state-el-cnt
              temp-line-pump.pol7                  = temp-line-pump.pol7 + temp-line-pump.previous-state-mh-cnt
              .
          end.
        end.
        if not available previous-rvs-doc
          or not available previous-rvs-line-pump
          then
        do:
          for each control-rvs-doc no-lock
            where control-rvs-doc.obj-type   = p-obj-type
            and control-rvs-doc.obj-code   = p-obj-code
            and control-rvs-doc.shift-date = x-date-start
            and control-rvs-doc.shift-num  = x-shift-start
            and control-rvs-doc.status_    = 'факт':U
            and control-rvs-doc.rvs-type   = 'контроль':U
            ,first control-rvs-line-pump no-lock
            where control-rvs-line-pump.rvs-code = control-rvs-doc.rvs-code
            and control-rvs-line-pump.gds-code = temp-rvs-line.gds-code
            and control-rvs-line-pump.obj-code = temp-rvs-line.obj-code
            and control-rvs-line-pump.obj-type = temp-rvs-line.obj-type
            and control-rvs-line-pump.pl-code  = temp-rvs-line.pl-code
            and control-rvs-line-pump.pump-code = ub.rvs-line-pump.pump-code
            and control-rvs-line-pump.nozzle-code = ub.rvs-line-pump.nozzle-code
            by control-rvs-doc.fact-order
            :
            assign
              temp-line-pump.previous-state-mh-cnt = control-rvs-line-pump.state-mh-cnt
              temp-line-pump.previous-state-el-cnt = control-rvs-line-pump.state-el-cnt
              temp-line-pump.pol7                  = temp-line-pump.pol7 + temp-line-pump.previous-state-mh-cnt
              .
            leave.
          end.
        end.
      end.
    END.
    _shift-chk:
    FOR EACH buf_chk-doc
      WHERE buf_chk-doc.obj-type = temp-rvs-line.obj-type
      AND   buf_chk-doc.obj-code = temp-rvs-line.obj-code
      AND   buf_chk-doc.shift-date >= x-date-Start
      AND   buf_chk-doc.shift-date <= x-date-End
      NO-LOCK
      :
      IF ( buf_chk-doc.shift-date = x-Date-Start
        AND  buf_chk-doc.shift-num  < x-Shift-Start)
        OR ( buf_chk-doc.shift-date = x-Date-End
        AND  buf_chk-doc.shift-num  > x-Shift-End)
        THEN
      dO:
        NEXT _shift-chk.
      END.
      run add-chk in this-procedure (
        input buf_chk-doc.obj-type
        , input buf_chk-doc.obj-code
        , input buf_chk-doc.doc-code
        , input buf_chk-doc.chk-type
        , input temp-rvs-line.gds-code
        , input temp-rvs-line.pl-code
        , input temp-rvs-line.place_loc1
        ) .
    END.
    if last-of(temp-rvs-line.pl-code ) then
    do:
      for each ub.trn-doc no-lock
        where ub.trn-doc.obj-type   = temp-rvs-line.obj-type
        and ub.trn-doc.obj-code   = temp-rvs-line.obj-code
        and ub.trn-doc.shift-date >= x-date-Start
        and ub.trn-doc.shift-date <= x-date-End
        and ub.trn-doc.status_    = 'факт':U
        and ub.trn-doc.doc-type   = 'при':U
        on error undo, return error return-value
        :
        if ub.trn-doc.shift-date = x-date-Start and ub.trn-doc.shift-num < x-Shift-Start then next .
        if ub.trn-doc.shift-date = x-date-End   and ub.trn-doc.shift-num > x-Shift-End then next .
        for each ub.doc-pl no-lock
          where ub.doc-pl.gds-code = temp-rvs-line.gds-code
          and ub.doc-pl.obj-code = temp-rvs-line.obj-code
          and ub.doc-pl.obj-type = temp-rvs-line.obj-type
          and ub.doc-pl.out-code = ub.trn-doc.doc-code
          and ub.doc-pl.pl-code  = temp-rvs-line.pl-code
          on error undo, return error return-value
          :
          assign
            temp-rvs-line.pol5-l  = temp-rvs-line.pol5-l + ub.doc-pl.fact-qnty
            temp-rvs-line.pol5-kg = temp-rvs-line.pol5-kg + ub.doc-pl.cli-fact-qnty
            .
        end.
      end.
      for each buf_trn-doc no-lock
        where buf_trn-doc.obj-type   = temp-rvs-line.obj-type
        and buf_trn-doc.obj-code   = temp-rvs-line.obj-code
        and buf_trn-doc.shift-date <= x-date-End
        and buf_trn-doc.shift-num <= x-Shift-End
        and buf_trn-doc.status_    = 'факт':U
        and buf_trn-doc.doc-type   = 'при':U
        and buf_trn-doc.fact-order > v-fact-order-inv
        on error undo, return error return-value
        :
        for each ub.doc-pl no-lock
          where ub.doc-pl.gds-code = temp-rvs-line.gds-code
          and ub.doc-pl.obj-code = temp-rvs-line.obj-code
          and ub.doc-pl.obj-type = temp-rvs-line.obj-type
          and ub.doc-pl.out-code = buf_trn-doc.doc-code
          and ub.doc-pl.pl-code  = temp-rvs-line.pl-code
          on error undo, return error return-value
          :
          v-InfoSectionsTotal:Initialization(buf_trn-doc.doc-code, temp-rvs-line.gds-code).
          v-InfoSectionsTotal:GetDBAllAttr().
          do iNum = 1 to v-InfoSectionsTotal:SectionNum:
            assign
              temp-rvs-line.pol21_tech = temp-rvs-line.pol21_tech + v-InfoSectionsTotal:GetInfoSectionProp(iNum):TPNorm
              .
          end.
        end.
      end.
      assign
        temp-rvs-line.pol4-l-state   = 0
        temp-rvs-line.pol4-kg-state  = 0
        temp-rvs-line.pol4-l-system  = 0
        temp-rvs-line.pol4-kg-system = 0
        .
      if available previous-rvs-line then
      do:
        assign
          temp-rvs-line.pol4-l-state   = previous-rvs-line.state-measure-qnty + previous-rvs-line.state-add-qnty
          temp-rvs-line.pol4-kg-state  = previous-rvs-line.state-measure-cli-qnty + previous-rvs-line.state-add-qnty * previous-rvs-line.state-density
          temp-rvs-line.pol4-l-system  = previous-rvs-line.system-qnty
          temp-rvs-line.pol4-kg-system = previous-rvs-line.system-cli-qnty
          .
      end.
      Assign
        temp-rvs-line.pol4-l-system  = (if p-param-shft-qty = "system":U then temp-rvs-line.pol4-l-system else temp-rvs-line.pol4-l-state)
        temp-rvs-line.pol4-kg-system = (if p-param-shft-qty = "system":U then temp-rvs-line.pol4-kg-system else  temp-rvs-line.pol4-kg-state)
        .
      find first last-rvs-line no-lock
        where last-rvs-line.rvs-code = last-rvs-doc.rvs-code
        and last-rvs-line.gds-code = temp-rvs-line.gds-code
        and last-rvs-line.obj-code = temp-rvs-line.obj-code
        and last-rvs-line.obj-type = temp-rvs-line.obj-type
        and last-rvs-line.pl-code  = temp-rvs-line.pl-code
        no-error .
      if available last-rvs-line
        and ( p-param-shft-qty = "system":U
        or p-param-shft-qty = "state-all-per":U
        )
        then
      do:
        assign
          temp-rvs-line.pol20-l  = last-rvs-line.system-qnty
          temp-rvs-line.pol20-kg = last-rvs-line.system-cli-qnty
          .
      end.
      else
      do:
        if p-param-shft-qty = "state":U then
        do:
          assign
            temp-rvs-line.pol20-l  = temp-rvs-line.pol4-l-state
            temp-rvs-line.pol20-kg = temp-rvs-line.pol4-kg-state
            .
        end.
        else
        do:
          assign
            temp-rvs-line.pol20-l  = temp-rvs-line.pol4-l-system
            temp-rvs-line.pol20-kg = temp-rvs-line.pol4-kg-system
            .
        end.
        for each ub.trn-doc no-lock
          where ub.trn-doc.obj-type   = temp-rvs-line.obj-type
          and ub.trn-doc.obj-code   = temp-rvs-line.obj-code
          and ub.trn-doc.shift-date >= x-date-Start
          and ub.trn-doc.shift-date <= x-date-End
          and ub.trn-doc.status_    = 'факт':U
          on error undo, return error return-value
          :
          if ub.trn-doc.shift-date = x-date-Start and ub.trn-doc.shift-num < x-Shift-Start then next .
          if ub.trn-doc.shift-date = x-date-End   and ub.trn-doc.shift-num > x-Shift-End then next .
          for each ub.doc-pl no-lock
            where ub.doc-pl.gds-code = temp-rvs-line.gds-code
            and ub.doc-pl.obj-code = temp-rvs-line.obj-code
            and ub.doc-pl.obj-type = temp-rvs-line.obj-type
            and ub.doc-pl.out-code = ub.trn-doc.doc-code
            and ub.doc-pl.pl-code  = temp-rvs-line.pl-code
            on error undo, return error return-value
            :
            if lookup( ub.trn-doc.ext-doc-type, 'ee,ep,es,we,ev,em,wm,eo':U ) > 0 then
            do:
              assign
                v-sign = -1.0
                .
            end.
            else
            do:
              assign
                v-sign = 1.0
                .
              if lookup( ub.trn-doc.ext-doc-type, 'ie,re,rs,vt,vp,ap,mp,pc,iv,rv,im,io':U ) = 0 then
              do:
                undo, return error substitute( '&1. Тип "&2" не внесен в списки документов уменьшающих(увеличивающих) остатки!', vss-workfile, ub.trn-doc.ext-doc-type).
              end.
            end.
            if ( p-param-shft-qty = "state":U
              and ub.trn-doc.doc-type <> 'инв':U
              )
              or p-param-shft-qty = "system":U
              or p-param-shft-qty = "state-all-per":U
              then
            do:
              assign
                temp-rvs-line.pol20-l  = temp-rvs-line.pol20-l + ub.doc-pl.fact-qnty * v-sign
                temp-rvs-line.pol20-kg = temp-rvs-line.pol20-kg + ub.doc-pl.cli-fact-qnty * v-sign
                .
            end.
          end.
        end.
      end.
      define variable is-vir  as logical   no-undo.
      define variable v-value as character no-undo.
      define variable v-ok    as logical   no-undo.
      run placelib_get-attr(input "place-virtual"
        ,input temp-rvs-line.obj-code
        ,input temp-rvs-line.obj-type
        ,input temp-rvs-line.pl-code
        ,output v-value
        ,output v-ok) no-error.
      is-vir = if (v-ok and logical(v-value)) then true else false.
      if is-vir then
      do:
        if available last-rvs-line then
        do:
          temp-rvs-line.pol20-l = last-rvs-line.system-qnty.
          temp-rvs-line.pol20-kg = last-rvs-line.system-cli-qnty.
        end.
      end.
      assign
        temp-rvs-line.pol18    = temp-rvs-line.state-density
        temp-rvs-line.pol17-l  = temp-rvs-line.state-measure-qnty + temp-rvs-line.state-add-qnty
        temp-rvs-line.pol17-kg = temp-rvs-line.state-measure-cli-qnty + temp-rvs-line.state-add-qnty * temp-rvs-line.pol18
        temp-rvs-line.pol13    = temp-rvs-line.state-add-qnty
        .
      temp-rvs-line.pol21-l = temp-rvs-line.pol17-l - temp-rvs-line.pol20-l .
      temp-rvs-line.pol21-kg = temp-rvs-line.pol17-kg - temp-rvs-line.pol20-kg .
      find first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-code = temp-rvs-line.obj-code
        and buf_rvs-line-attr.obj-type = temp-rvs-line.obj-type
        and buf_rvs-line-attr.gds-code = temp-rvs-line.gds-code
        and buf_rvs-line-attr.pl-code = temp-rvs-line.pl-code
        and buf_rvs-line-attr.rvs-code = temp-rvs-line.rvs-code
        and buf_rvs-line-attr.attr-code = "delta-mass-qnty" no-error .
      if AVAILABLE buf_rvs-line-attr then
      do:
        temp-rvs-line.pol22 = (temp-rvs-line.pol17-kg * decimal(buf_rvs-line-attr.attr-value)) / 100 .
      end.
    End.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'stfactpl'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output stfactplvalue
  ,output stfactpltype
  ) no-error .
    if stfactplvalue <> ""  then
    do:
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_chkqtpl in g#lib-calc
  (  input stfactplvalue
  , output v-update
  , output v-revision
  , output v-percrev
  , output v-auto-tank
  , output v-percauto
  , output v-inv
  , output v-percinv
  , output v-inv-set
  ) no-error .
      if error-status :error then
      do:
        message
          vss-workfile vss-revision vss-description skip
          "Разборе строки параметра stfactpl" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return error .
      end.
    end.
    if v-percauto <> ? then
    do:
      assign
        temp-rvs-line.fact-pl = v-percauto
        .
    end.
    else
      assign
        temp-rvs-line.fact-pl = 0.65
        .
  end.
  run print-total .
  run print-sug .
procedure print-total:
  define variable v-value         as character no-undo.
  define variable v-ok            as logical   no-undo.
  define variable v-com-tanks     as character no-undo .
  define variable v-main-tanks    as character no-undo .
  define variable v-num-com-tanks as integer   no-undo .
  output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
  put stream OutStr-html unformatted
    '<tbody>' skip
    '<tr>' skip
    '<th text_wrap="true" colspan="23" style="text-align: center;">Нефтепродукты: бензины и ДТ</th>' skip
    '</tr>' skip
    '<tr>' skip
    '<th text_wrap="true" rowspan="2" style="text-align: center;">Наим продукта</th>' skip
    '<th text_wrap="true" rowspan="2" style="text-align: center;">№ рез.</th>' skip
    '<th text_wrap="true" rowspan="2" style="text-align: center;">ед. изм.</th>' skip.
  if p-param-shft-qty = "system":U then
  do:
    put stream OutStr-html unformatted
      '<th text_wrap="true" rowspan="2" style="text-align: center;">Расчетно-книжный остаток на нач. смены, кг</th>' skip.
  end.
  else
  do:
    put stream OutStr-html unformatted
      '<th text_wrap="true" rowspan="2" style="text-align: center;">Фактич. остаток на нач. смены, л/кг</th>' skip.
  end.
  put stream OutStr-html unformatted
    '<th text_wrap="true" rowspan="2" style="text-align: center;">Поступило за смену, л/кг</th>' skip
    '<th text_wrap="true" colspan="7" style="text-align: center;">Обороты за смену</th>' skip
    '<th text_wrap="true" colspan="9" style="text-align: center;">Остаток на конец смены</th>' skip
    '<th text_wrap="true" style="text-align: center;">Небаланс фактичес кий +/-, кг </th>' skip
    '<th text_wrap="true" rowspan="2" style="text-align: center;">Погр. изм. массы в рез, ±кг</th>' skip
    '</tr>' skip
    '<tr>' skip
    '<th text_wrap="true" style="text-align: center;">Расход по счетчикам</th>' skip
    '<th text_wrap="true" style="text-align: center;">Расход по кассе</th>' skip
    '<th text_wrap="true" style="text-align: center;">Техпролив</th>' skip
    '<th text_wrap="true" style="text-align: center;">Разница</th>' skip
    '<th text_wrap="true" style="text-align: center;">Сброс (не пролито)</th>' skip
    '<th text_wrap="true" style="text-align: center;">Сброс (пролито)</th>' skip
    '<th text_wrap="true" style="text-align: center;">Перелив</th>' skip
    '<th colspan=2 text_wrap="true" style="text-align: center;">Факт объем в трубопроводе</th>' skip
    '<th text_wrap="true" style="text-align: center;">Общий уровень мм</th>' skip
    '<th text_wrap="true" style="text-align: center;">Уровень воды мм</th>' skip
    '<th text_wrap="true" style="text-align: center;">Факт объем в резервуаре</th>' skip
    '<th text_wrap="true" style="text-align: center;">Факт объем и масса всего</th>' skip
    '<th text_wrap="true" style="text-align: center;">Факт плотность г/см3</th>' skip
    '<th text_wrap="true" style="text-align: center;">Факт t, °С</th>' skip
    '<th text_wrap="true" style="text-align: center;">Расчетный остаток на конец смены, кг.</th>' skip
    '<th text_wrap="true" style="text-align: center;">Тех.потери по нормам, кг</th>' skip
    '</tr>' skip
    '<tr>' skip
    '<th style="text-align: center;">1</th>' skip
    '<th style="text-align: center;">2</th>' skip
    '<th style="text-align: center;">3</th>' skip
    '<th style="text-align: center;">4</th>' skip
    '<th style="text-align: center;">5</th>' skip
    '<th style="text-align: center;">6</th>' skip
    '<th style="text-align: center;">7</th>' skip
    '<th style="text-align: center;">8</th>' skip
    '<th style="text-align: center;">9</th>' skip
    '<th style="text-align: center;">10</th>' skip
    '<th style="text-align: center;">11</th>' skip
    '<th style="text-align: center;">12</th>' skip
    '<th colspan=2 style="text-align: center;">13</th>' skip
    '<th style="text-align: center;">14</th>' skip
    '<th style="text-align: center;">15</th>' skip
    '<th style="text-align: center;">16</th>' skip
    '<th style="text-align: center;">17</th>' skip
    '<th style="text-align: center;">18</th>' skip
    '<th style="text-align: center;">19</th>' skip
    '<th style="text-align: center;">20</th>' skip
    '<th style="text-align: center;">21</th>' skip
    '<th style="text-align: center;">22</th>' skip
    '</tr>' skip
    .
  for each temp-rvs-line break by temp-rvs-line.gds-code by temp-rvs-line.pl-code:
    if first-of(temp-rvs-line.gds-code) and not is-sug(temp-rvs-line.gds-code) then
    do:
      for each buf_temp-rvs-line where buf_temp-rvs-line.gds-code = temp-rvs-line.gds-code:
        for each temp-line-pump where buf_temp-rvs-line.gds-code = temp-line-pump.gds-code
          and temp-line-pump.pl-code = buf_temp-rvs-line.pl-code
          and temp-line-pump.loc1 = buf_temp-rvs-line.place_loc1  :
          find first buf_temp-line-pump where buf_temp-line-pump.gds-code = temp-line-pump.gds-code and buf_temp-line-pump.pump-code = temp-line-pump.pump-code
            and buf_temp-line-pump.nozzle-code = temp-line-pump.nozzle-code and buf_temp-line-pump.loc1 <> temp-line-pump.loc1 no-error .
          if available (buf_temp-line-pump) then
          do:
            if not temp-line-pump.log_ then
              assign
                buf_temp-rvs-line.pol61 = buf_temp-rvs-line.pol61 + (temp-line-pump.pol6 - temp-line-pump.pol7)
                buf_temp-line-pump.log_ = yes .
          end.
          assign
            buf_temp-rvs-line.pol6    = buf_temp-rvs-line.pol6 + (temp-line-pump.pol6 - temp-line-pump.pol7)
            buf_temp-rvs-line.pol8-l  = buf_temp-rvs-line.pol8-l + temp-line-pump.pol8-l
            buf_temp-rvs-line.pol8-kg = buf_temp-rvs-line.pol8-kg + temp-line-pump.pol8-kg
            buf_temp-rvs-line.pol10   = buf_temp-rvs-line.pol10 + temp-line-pump.pol10
            buf_temp-rvs-line.pol11   = buf_temp-rvs-line.pol11 + temp-line-pump.pol11
            buf_temp-rvs-line.pol12   = buf_temp-rvs-line.pol12 + temp-line-pump.pol12
            buf_temp-rvs-line.pol7-l  = buf_temp-rvs-line.pol7-l + temp-line-pump.pol9-l
            buf_temp-rvs-line.pol7-kg = buf_temp-rvs-line.pol7-kg + temp-line-pump.pol9-kg
            buf_temp-rvs-line.pol9    = buf_temp-rvs-line.pol8-l + buf_temp-rvs-line.pol7-l - buf_temp-rvs-line.pol6
            .
        end.
        assign
          temp-rvs-line.itog-pol6 = temp-rvs-line.itog-pol6 + buf_temp-rvs-line.pol6 - buf_temp-rvs-line.pol61 .
        if p-param-shft-qty = "system":U then
        do:
          temp-rvs-line.itog-pol4-l      = temp-rvs-line.itog-pol4-l + buf_temp-rvs-line.pol4-l-system .
          temp-rvs-line.itog-pol4-kg     = temp-rvs-line.itog-pol4-kg + buf_temp-rvs-line.pol4-kg-system .
        end.
        else
        do:
          temp-rvs-line.itog-pol4-l      = temp-rvs-line.itog-pol4-l + buf_temp-rvs-line.pol4-l-state .
          temp-rvs-line.itog-pol4-kg     = temp-rvs-line.itog-pol4-kg + buf_temp-rvs-line.pol4-kg-state .
        end.
        assign
          temp-rvs-line.itog-pol5-l      = temp-rvs-line.itog-pol5-l + buf_temp-rvs-line.pol5-l
          temp-rvs-line.itog-pol5-kg     = temp-rvs-line.itog-pol5-kg + buf_temp-rvs-line.pol5-kg
          temp-rvs-line.itog-pol8-l      = temp-rvs-line.itog-pol8-l + buf_temp-rvs-line.pol8-l
          temp-rvs-line.itog-pol8-kg     = temp-rvs-line.itog-pol8-kg + buf_temp-rvs-line.pol8-kg
          temp-rvs-line.itog-pol9        = temp-rvs-line.itog-pol9 + buf_temp-rvs-line.pol9 + buf_temp-rvs-line.pol61
          temp-rvs-line.itog-pol10       = temp-rvs-line.itog-pol10 + buf_temp-rvs-line.pol10
          temp-rvs-line.itog-pol11       = temp-rvs-line.itog-pol11 + buf_temp-rvs-line.pol11
          temp-rvs-line.itog-pol12       = temp-rvs-line.itog-pol12 + buf_temp-rvs-line.pol12
          temp-rvs-line.itog-pol13       = temp-rvs-line.itog-pol13 + buf_temp-rvs-line.pol13
          temp-rvs-line.itog-pol7-l      = temp-rvs-line.itog-pol7-l + buf_temp-rvs-line.pol7-l
          temp-rvs-line.itog-pol7-kg     = temp-rvs-line.itog-pol7-kg + buf_temp-rvs-line.pol7-kg
          temp-rvs-line.itog-pol16       = temp-rvs-line.itog-pol16 + buf_temp-rvs-line.state-brutto-qnty
          temp-rvs-line.itog-pol17-l     = temp-rvs-line.itog-pol17-l + buf_temp-rvs-line.pol17-l
          temp-rvs-line.itog-pol17-kg    = temp-rvs-line.itog-pol17-kg + buf_temp-rvs-line.pol17-kg
          temp-rvs-line.itog-pol20-l     = temp-rvs-line.itog-pol20-l + buf_temp-rvs-line.pol20-l
          temp-rvs-line.itog-pol20-kg    = temp-rvs-line.itog-pol20-kg + buf_temp-rvs-line.pol20-kg
          temp-rvs-line.itog-pol21-l     = temp-rvs-line.itog-pol21-l + buf_temp-rvs-line.pol21-l
          temp-rvs-line.itog-pol21_nebal = temp-rvs-line.itog-pol21_nebal + buf_temp-rvs-line.pol21-kg
          temp-rvs-line.itog-pol21_tech  = temp-rvs-line.itog-pol21_tech + buf_temp-rvs-line.pol21_tech .
        if temp-rvs-line.itog-pol18 = 0 then temp-rvs-line.itog-pol18 = buf_temp-rvs-line.state-density .
        else temp-rvs-line.itog-pol18    = temp-rvs-line.itog-pol17-kg / temp-rvs-line.itog-pol17-l .
      end.
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td text_wrap="true" rowspan="3" style="text-align: right;">' + temp-rvs-line.gds-name + '</td>' skip
        '<td text_wrap="true" rowspan="3" style="text-align: right;"></td>' skip
        '<td text_wrap="true" rowspan="2" style="text-align: right;">л</td>' skip .
      if p-param-shft-qty = "state" then
      do:
        put stream OutStr-html unformatted
          '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol4-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol4-l <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol4-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
          .
      end.
      else
      do:
        put stream OutStr-html unformatted
          '<td text_wrap="true" rowspan="3" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol4-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if temp-rvs-line.itog-pol4-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol4-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
          .
      end.
      put stream OutStr-html unformatted
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol5-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol5-l <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol5-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol6,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol6 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol6,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol7-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol7-l <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol7-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol8-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol8-l <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol8-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol9,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol9 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol9,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol10,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol10 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol10,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol11,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol11 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol11,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol12,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol12 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol12,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="2" colspan=2 num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol13,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol13 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol13,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="3" style="text-align: right;"></td>' skip
        '<td text_wrap="true" rowspan="3" style="text-align: right;"></td>' skip
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol16,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol16 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol16,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol17-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol17-l <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol17-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="3" num="0.0000" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol18,"->>>>>>>>>>>>>9.9999",4) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol18 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol18,"->>>>>>>>>>>9.9999",4) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="3" style="text-align: right;"></td>' skip
        '<td text_wrap="true" num="0.00" rowspan="3" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol20-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if temp-rvs-line.itog-pol20-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol20-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" rowspan="2" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol21_nebal,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if temp-rvs-line.itog-pol21_nebal <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol21_nebal,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="2" style="text-align: right;"></td>' skip
        '</tr>' skip
        '<tr></tr>' skip
        '<tr>' skip
        '<td text_wrap="true" style="text-align: right; height: 20px;">кг</td>' skip
        .
      if p-param-shft-qty = "state" then
      do:
        put stream OutStr-html unformatted
          '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol4-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol4-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol4-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
          .
      end.
      put stream OutStr-html unformatted
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol5-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol5-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol5-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol7-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol7-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol7-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol8-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol8-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol8-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" colspan=2 style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol17-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol17-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol17-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol21_tech,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol21_tech <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol21_tech,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '</tr>' skip
        .
      find first ub.shift-obj no-lock where ub.shift-obj.obj-code = p-obj-code and
        ub.shift-obj.obj-type = p-obj-type and ub.shift-obj.shift-date = x-date-end and
        ub.shift-obj.shift-num = x-shift-end no-error .
      v-main-tanks = "" .
      v-com-tanks = "" .
      for each bf_temp-rvs-line where bf_temp-rvs-line.gds-code = temp-rvs-line.gds-code  :
        if get_com-vessel(p-obj-code, p-obj-type, "place-com-vessel", bf_temp-rvs-line.pl-code, ub.shift-obj.open-date,
          ub.shift-obj.close-date, ub.shift-obj.open-time, ub.shift-obj.close-time) then
        do:
          v-com-tanks = get_com-tanks(p-obj-code, p-obj-type, "place-com-tanks", bf_temp-rvs-line.pl-code,
            ub.shift-obj.open-date, ub.shift-obj.close-date, ub.shift-obj.open-time, ub.shift-obj.close-time) .
          if v-com-tanks > "" then
          do:
            v-main-tanks = trim(v-main-tanks,",") .
            if lookup(v-main-tanks, v-com-tanks, ",") <> 0 then next .
            if not get_com-vessel(p-obj-code, p-obj-type, "place-is-main", bf_temp-rvs-line.pl-code, ub.shift-obj.open-date,
              ub.shift-obj.close-date, ub.shift-obj.open-time, ub.shift-obj.close-time) then next .
            else
            do :
              v-main-tanks = v-main-tanks + "," + bf_temp-rvs-line.place_loc1 .
              v-num-com-tanks = num-entries(v-com-tanks) + 1 .
              do ii = 1 to num-entries(v-com-tanks) :
                find first buf_place no-lock where buf_place.obj-type = bf_temp-rvs-line.obj-type
                  and buf_place.obj-code = bf_temp-rvs-line.obj-code
                  and buf_place.loc1 = entry(ii, v-com-tanks)
                  and buf_place.status_ = ""
                  no-error .
                if not available buf_place
                  then
                do :
                  undo, return error ("Не найден сообщающийся резервуар " + entry(ii, v-com-tanks)) .
                end .
                find first com_temp-rvs-line where com_temp-rvs-line.gds-code = bf_temp-rvs-line.gds-code
                  and com_temp-rvs-line.pl-code  = buf_place.pl-code
                  no-error .
                if not available com_temp-rvs-line
                  then
                do :
                end .
                else
                do :
                  bf_temp-rvs-line.pol21_nebal = bf_temp-rvs-line.pol21_nebal + com_temp-rvs-line.pol21-kg .
                  bf_temp-rvs-line.pol20-kg = bf_temp-rvs-line.pol20-kg + com_temp-rvs-line.pol20-kg .
                  bf_temp-rvs-line.pol20-l = bf_temp-rvs-line.pol20-l + com_temp-rvs-line.pol20-l .
                  bf_temp-rvs-line.pol4-l-state = bf_temp-rvs-line.pol4-l-state + com_temp-rvs-line.pol4-l-state .
                  bf_temp-rvs-line.pol4-kg-state = bf_temp-rvs-line.pol4-kg-state + com_temp-rvs-line.pol4-kg-state .
                  bf_temp-rvs-line.pol4-l-system = bf_temp-rvs-line.pol4-l-system + com_temp-rvs-line.pol4-l-system .
                  bf_temp-rvs-line.pol4-kg-system = bf_temp-rvs-line.pol4-kg-system + com_temp-rvs-line.pol4-kg-system .
                end .
              end .
              assign
                bf_temp-rvs-line.pol14       = bf_temp-rvs-line.state-level-total * 10
                bf_temp-rvs-line.pol15       = bf_temp-rvs-line.state-level-water * 10
                bf_temp-rvs-line.pol16       = bf_temp-rvs-line.state-brutto-qnty
                bf_temp-rvs-line.pol19       = bf_temp-rvs-line.state-temperature
                bf_temp-rvs-line.pol21_nebal = bf_temp-rvs-line.pol21_nebal + bf_temp-rvs-line.pol21-kg
                .
              put stream OutStr-html unformatted
                '<tr>' skip
                '<td text_wrap="true" rowspan="' + string((2 * v-num-com-tanks), ">9") + '" style="text-align: right;">   по резер.</td>' skip
                '<td text_wrap="true" rowspan="' + string((2 * v-num-com-tanks), ">9") + '" style="text-align: right;">' + bf_temp-rvs-line.place_loc1 + "," + v-com-tanks + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" style="text-align: right;">л</td>' skip .
              if p-param-shft-qty = "state" then
              do:
                put stream OutStr-html unformatted
                  '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '"  num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-l-state,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol4-l-state <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-l-state,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                  .
              end.
              else
              do:
                put stream OutStr-html unformatted
                  '<td text_wrap="true" rowspan="' + string((2 * v-num-com-tanks), ">9") + '"  num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if bf_temp-rvs-line.pol4-kg-system <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.itog-pol4-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                  .
              end.
              put stream OutStr-html unformatted
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol6 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol9 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol10 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol11 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol12 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" style="text-align: center;">' + bf_temp-rvs-line.place_loc1 + '</td>' skip
                '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol13,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol13 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol13,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol14,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol14 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol14,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol15,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol15 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol15,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol16,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol16 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol16,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" num="0.0000" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol18,"->>>>>>>>>>>>>9.9999",4) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol18 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol18,"->>>>>>>>>>>9.9999",4) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" num="0.0" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol19,"->>>>>>>>>>>>>9.9",1) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol19 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol19,"->>>>>>>>>>>9.9",1) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks * 2), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol20-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21_nebal,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol21_nebal <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21_nebal,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" style="text-align: right;"></td>' skip
                '</tr>' skip.
              do ii = 1 to num-entries(v-com-tanks) :
                find first buf_place no-lock where buf_place.obj-type = bf_temp-rvs-line.obj-type
                  and buf_place.obj-code = bf_temp-rvs-line.obj-code
                  and buf_place.loc1 = entry(ii, v-com-tanks)
                  and buf_place.status_ = ""
                  no-error .
                if not available buf_place
                  then
                do :
                  undo, return error ("Не найден сообщающийся резервуар " + entry(ii, v-com-tanks)) .
                end .
                find first com_temp-rvs-line where com_temp-rvs-line.gds-code = bf_temp-rvs-line.gds-code
                  and com_temp-rvs-line.pl-code  = buf_place.pl-code
                  no-error .
                if not available com_temp-rvs-line
                  then
                do :
                  put stream OutStr-html unformatted
                    '<tr>' skip
                    '<td text_wrap="true" style="text-align: center;">' + buf_place.loc1 + '</td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '</tr>' skip.
                end .
                else
                do :
                  assign
                    com_temp-rvs-line.pol14 = com_temp-rvs-line.state-level-total * 10
                    com_temp-rvs-line.pol15 = com_temp-rvs-line.state-level-water * 10
                    com_temp-rvs-line.pol16 = com_temp-rvs-line.state-brutto-qnty
                    com_temp-rvs-line.pol19 = com_temp-rvs-line.state-temperature
                    .
                  put stream OutStr-html unformatted
                    '<tr>' skip
                    '<td text_wrap="true" style="text-align: center;">' + buf_place.loc1 + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol13,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if com_temp-rvs-line.pol13 <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol13,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol14,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if com_temp-rvs-line.pol14 <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol14,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol15,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if com_temp-rvs-line.pol15 <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol15,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol16,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if com_temp-rvs-line.pol16 <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol16,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol17-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if com_temp-rvs-line.pol17-l <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol17-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.0000" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol18,"->>>>>>>>>>>>>9.9999",4) + '" style="text-align: right;">' + if com_temp-rvs-line.pol18 <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol18,"->>>>>>>>>>>9.9999",4) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.0" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol19,"->>>>>>>>>>>>>9.9",1) + '" style="text-align: right;">' + if com_temp-rvs-line.pol19 <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol19,"->>>>>>>>>>>9.9",1) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '</tr>' skip.
                end .
              end .
              put stream OutStr-html unformatted
                '<tr>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" style="text-align: right;">кг</td>' skip .
              if p-param-shft-qty = "state" then
              do:
                put stream OutStr-html unformatted
                  '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-state,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol4-kg-state <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-state,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                  .
              end.
              put stream OutStr-html unformatted
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string((v-num-com-tanks), ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" style="text-align: center;">' + bf_temp-rvs-line.place_loc1 + '</td>' skip
                '<td text_wrap="true" style="text-align: right;"></td>' skip
                '<td text_wrap="true" style="text-align: right;"></td>' skip
                '<td text_wrap="true" style="text-align: right;"></td>' skip
                '<td text_wrap="true" style="text-align: right;"></td>' skip
                '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" style="text-align: right;"></td>' skip
                '<td text_wrap="true" style="text-align: right;"></td>' skip
                '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21_tech,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol21_tech <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21_tech,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol22,"->>>>>>>>>>>>>9.999",3) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol22 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol22,"->>>>>>>>>>>9.999",3) + '</td>' else "" + '</td>' skip
                '</tr>' skip.
              do ii = 1 to num-entries(v-com-tanks) :
                find first buf_place no-lock where buf_place.obj-type = bf_temp-rvs-line.obj-type
                  and buf_place.obj-code = bf_temp-rvs-line.obj-code
                  and buf_place.loc1 = entry(ii, v-com-tanks)
                  and buf_place.status_ = ""
                  no-error .
                if not available buf_place
                  then
                do :
                  undo, return error ("Не найден сообщающийся резервуар " + entry(ii, v-com-tanks)) .
                end .
                find first com_temp-rvs-line where com_temp-rvs-line.gds-code = bf_temp-rvs-line.gds-code
                  and com_temp-rvs-line.pl-code  = buf_place.pl-code
                  no-error .
                if not available com_temp-rvs-line
                  then
                do :
                  put stream OutStr-html unformatted
                    '<tr>' skip
                    '<td text_wrap="true" style="text-align: center;">' + buf_place.loc1 + '</td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '</tr>' skip.
                end .
                else
                do :
                  put stream OutStr-html unformatted
                    '<tr>' skip
                    '<td text_wrap="true" style="text-align: center;">' + buf_place.loc1 + '</td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol17-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if com_temp-rvs-line.pol17-kg <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol17-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol21_tech,"->>>>>>>>>>>>>9.999",2) + '" style="text-align: right;">' + if com_temp-rvs-line.pol21_tech <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol21_tech,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol22,"->>>>>>>>>>>>>9.999",3) + '" style="text-align: right;">' + if com_temp-rvs-line.pol22 <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol22,"->>>>>>>>>>>9.999",3) + '</td>' else "" + '</td>' skip
                    '</tr>' skip.
                end .
              end .
            end.
          end.
          else
          do:
            put stream OutStr-html unformatted
              '<tr>' skip
              '<td text_wrap="true" rowspan="2" style="text-align: right;">   по резер.</td>' skip
              '<td text_wrap="true" rowspan="2" style="text-align: right;">' + bf_temp-rvs-line.place_loc1 + '</td>' skip
              '<td text_wrap="true" style="text-align: right;">л</td>' skip
              .
            if p-param-shft-qty = "state" then
            do:
              put stream OutStr-html unformatted
                '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-l-state,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol4-l-state <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-l-state,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                .
            end.
            else
            do:
              put stream OutStr-html unformatted
                '<td text_wrap="true" rowspan="2"  num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if bf_temp-rvs-line.pol4-kg-system <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                .
            end.
            put stream OutStr-html unformatted
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol6 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol9 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol10 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol11 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol12 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" colspan=2 num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol13,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol13 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol13,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol14,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol14 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol14,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol15,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol15 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol15,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol16,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol16 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol16,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" rowspan="2" num="0.0000" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol18,"->>>>>>>>>>>>>9.9999",4) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol18 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol18,"->>>>>>>>>>>9.9999",4) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" rowspan="2" num="0.0" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol19,"->>>>>>>>>>>>>9.9",1) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol19 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol19,"->>>>>>>>>>>9.9",1) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol20-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21_nebal,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol21_nebal <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21_nebal,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '</tr>' skip
              '<tr>' skip
              '<td text_wrap="true" style="text-align: right;">кг</td>' skip.
            if p-param-shft-qty = "state" then
            do:
              put stream OutStr-html unformatted
                '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-state,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol4-kg-state <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-state,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                .
            end.
            put stream OutStr-html unformatted
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" colspan=2 style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21_tech,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol21_tech <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21_tech,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol22,"->>>>>>>>>>>>>9.999",3) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol22 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol22,"->>>>>>>>>>>9.999",3) + '</td>' else "" + '</td>' skip
              '</tr>' skip
              .
          end.
        end.
        else
        do:
          assign
            bf_temp-rvs-line.pol14 = bf_temp-rvs-line.state-level-total * 10
            bf_temp-rvs-line.pol15 = bf_temp-rvs-line.state-level-water * 10
            bf_temp-rvs-line.pol16 = bf_temp-rvs-line.state-brutto-qnty
            bf_temp-rvs-line.pol19 = bf_temp-rvs-line.state-temperature
            .
          put stream OutStr-html unformatted
            '<tr>' skip
            '<td text_wrap="true" rowspan="2" style="text-align: right;">   по резер.</td>' skip
            '<td text_wrap="true" rowspan="2" style="text-align: right;">' + bf_temp-rvs-line.place_loc1 + '</td>' skip
            '<td text_wrap="true" style="text-align: right;">л</td>' skip .
          if p-param-shft-qty = "state" then
          do:
            put stream OutStr-html unformatted
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-l-state,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol4-l-state <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-l-state,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              .
          end.
          else
          do:
            put stream OutStr-html unformatted
              '<td text_wrap="true" rowspan="2"  num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if bf_temp-rvs-line.pol4-kg-system <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              .
          end.
          put stream OutStr-html unformatted
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol6 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol9 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol10 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol11 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol12 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" colspan=2 num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol13,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol13 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol13,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol14,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol14 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol14,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol15,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol15 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol15,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol16,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol16 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol16,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" rowspan="2" num="0.0000" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol18,"->>>>>>>>>>>>>9.9999",4) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol18 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol18,"->>>>>>>>>>>9.9999",4) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" rowspan="2" num="0.0" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol19,"->>>>>>>>>>>>>9.9",1) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol19 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol19,"->>>>>>>>>>>9.9",1) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol20-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol21-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td text_wrap="true" style="text-align: right;">кг</td>' skip .
          if p-param-shft-qty = "state" then
          do:
            put stream OutStr-html unformatted
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-state,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol4-kg-state <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-state,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              .
          end.
          put stream OutStr-html unformatted
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" colspan=2 style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21_tech,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol21_tech <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21_tech,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol22,"->>>>>>>>>>>>>9.999",3) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol22 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol22,"->>>>>>>>>>>9.999",3) + '</td>' else "" + '</td>' skip
            '</tr>' skip
            .
        end.
        assign
          temp-rvs-line.itog-pol4-l      = 0
          temp-rvs-line.itog-pol4-kg     = 0
          temp-rvs-line.itog-pol5-l      = 0
          temp-rvs-line.itog-pol5-kg     = 0
          temp-rvs-line.itog-pol6        = 0
          temp-rvs-line.itog-pol8-l      = 0
          temp-rvs-line.itog-pol8-kg     = 0
          temp-rvs-line.itog-pol7-l      = 0
          temp-rvs-line.itog-pol7-kg     = 0
          temp-rvs-line.itog-pol17-l     = 0
          temp-rvs-line.itog-pol17-kg    = 0
          temp-rvs-line.itog-pol16       = 0
          temp-rvs-line.itog-pol18       = 0
          temp-rvs-line.itog-pol13       = 0
          temp-rvs-line.itog-pol20-l     = 0
          temp-rvs-line.itog-pol20-kg    = 0
          temp-rvs-line.itog-pol21_nebal = 0
          temp-rvs-line.itog-pol21_tech  = 0
          .
      end.
    end.
  end.
  put stream OutStr-html unformatted
    '</tbody>' skip .
  output stream OutStr-html close.
end procedure .
procedure print-sug:
  define variable v-value         as character no-undo.
  define variable v-ok            as logical   no-undo.
  define variable v-com-tanks     as character no-undo .
  define variable v-main-tanks    as character no-undo .
  define variable v-num-com-tanks as integer   no-undo .
  define variable is-sug as logical no-undo .
  for each temp-rvs-line:
    is-sug = is-sug(temp-rvs-line.gds-code) .
    if is-sug then leave .
  end.
  if is-sug then do:
  output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' .
  put stream OutStr-html unformatted
    '<tbody>' skip
    '<tr>' skip
    '<th text_wrap="true" colspan="22" style="text-align: center;">СУГ</th>' skip
    '</tr>' skip
    '<tr>' skip
    '<th text_wrap="true" rowspan="3" style="text-align: center;">Наим продукта</th>' skip
    '<th text_wrap="true" rowspan="3" style="text-align: center;">№ рез.</th>' skip
    '<th text_wrap="true" rowspan="3" style="text-align: center;">ед. изм.</th>' skip.
  put stream OutStr-html unformatted
    '<th text_wrap="true" rowspan="3" style="text-align: center;">Расчетный остаток на нач. смены, кг</th>' skip.
  put stream OutStr-html unformatted
    '<th text_wrap="true" rowspan="3" style="text-align: center;">Поступило за смену, л/кг</th>' skip
    '<th text_wrap="true" rowspan="2" colspan="7" style="text-align: center;">Обороты за смену</th>' skip
    '<th text_wrap="true" colspan="4" style="text-align: center;">Потери</th>' skip
    '<th text_wrap="true" rowspan="2" colspan="4" style="text-align: center;">Остаток на конец смены</th>' skip
    '<th text_wrap="true" rowspan="2" colspan="2" style="text-align: center;">Величина небаланса, кг</th>' skip
    '</tr>' skip
    '<tr>' skip
    '<th text_wrap="true" colspan="2" style="text-align: center;">к списанию</th>' skip
    '<th text_wrap="true" colspan="2" style="text-align: center;">к начислению</th>' skip
    '</tr>' skip
    '<tr>' skip
    '<th text_wrap="true" style="text-align: center;">Всего по счетчикам ГРК</th>' skip
    '<th text_wrap="true" style="text-align: center;">Расход по кассе</th>' skip
    '<th text_wrap="true" style="text-align: center;">Техпролив</th>' skip
    '<th text_wrap="true" style="text-align: center;">Разница</th>' skip
    '<th text_wrap="true" style="text-align: center;">Сброс (не пролито)</th>' skip
    '<th text_wrap="true" style="text-align: center;">Сброс (пролито)</th>' skip
    '<th text_wrap="true" style="text-align: center;">Перелив</th>' skip
    '<th text_wrap="true" style="text-align: center;">При зачистке</th>' skip
    '<th text_wrap="true" style="text-align: center;">Аварийные</th>' skip
    '<th text_wrap="true" style="text-align: center;">За смену</th>' skip
    '<th text_wrap="true" style="text-align: center;">Нарастающим итогом</th>' skip
    '<th text_wrap="true" colspan="2" style="text-align: center;">Измеренный</th>' skip
    '<th text_wrap="true" colspan="2" style="text-align: center;">Расчетный, кг.</th>' skip
    '<th text_wrap="true" style="text-align: center;">Допускаемая</th>' skip
    '<th text_wrap="true" style="text-align: center;">Фактическая</th>' skip
    '</tr>' skip
    '<tr>' skip
    '<th style="text-align: center;">23</th>' skip
    '<th style="text-align: center;">24</th>' skip
    '<th style="text-align: center;">25</th>' skip
    '<th style="text-align: center;">26</th>' skip
    '<th style="text-align: center;">27</th>' skip
    '<th style="text-align: center;">28</th>' skip
    '<th style="text-align: center;">29</th>' skip
    '<th style="text-align: center;">30</th>' skip
    '<th style="text-align: center;">31</th>' skip
    '<th style="text-align: center;">32</th>' skip
    '<th style="text-align: center;">33</th>' skip
    '<th style="text-align: center;">34</th>' skip
    '<th style="text-align: center;">35</th>' skip
    '<th style="text-align: center;">36</th>' skip
    '<th style="text-align: center;">37</th>' skip
    '<th style="text-align: center;">38</th>' skip
    '<th colspan="2" style="text-align: center;">39</th>' skip
    '<th colspan="2" style="text-align: center;">40</th>' skip
    '<th style="text-align: center;">41</th>' skip
    '<th style="text-align: center;">42</th>' skip
    '</tr>' skip
    .
  for each temp-rvs-line break by temp-rvs-line.gds-code by temp-rvs-line.pl-code:
    if first-of(temp-rvs-line.gds-code) and is-sug(temp-rvs-line.gds-code) then
    do:
      for each buf_temp-rvs-line where buf_temp-rvs-line.gds-code = temp-rvs-line.gds-code:
        for each temp-line-pump where buf_temp-rvs-line.gds-code = temp-line-pump.gds-code
          and temp-line-pump.pl-code = buf_temp-rvs-line.pl-code
          and temp-line-pump.loc1 = buf_temp-rvs-line.place_loc1  :
          find first buf_temp-line-pump where buf_temp-line-pump.gds-code = temp-line-pump.gds-code and buf_temp-line-pump.pump-code = temp-line-pump.pump-code
            and buf_temp-line-pump.nozzle-code = temp-line-pump.nozzle-code and buf_temp-line-pump.loc1 <> temp-line-pump.loc1 no-error .
          if available (buf_temp-line-pump) then
          do:
            if not temp-line-pump.log_ then
              assign
                buf_temp-rvs-line.pol61 = buf_temp-rvs-line.pol61 + (temp-line-pump.pol6 - temp-line-pump.pol7)
                buf_temp-line-pump.log_ = yes .
          end.
          assign
            buf_temp-rvs-line.pol6    = buf_temp-rvs-line.pol6 + (temp-line-pump.pol6 - temp-line-pump.pol7)
            buf_temp-rvs-line.pol8-l  = buf_temp-rvs-line.pol8-l + temp-line-pump.pol8-l
            buf_temp-rvs-line.pol8-kg = buf_temp-rvs-line.pol8-kg + temp-line-pump.pol8-kg
            buf_temp-rvs-line.pol10   = buf_temp-rvs-line.pol10 + temp-line-pump.pol10
            buf_temp-rvs-line.pol11   = buf_temp-rvs-line.pol11 + temp-line-pump.pol11
            buf_temp-rvs-line.pol12   = buf_temp-rvs-line.pol12 + temp-line-pump.pol12
            buf_temp-rvs-line.pol7-l  = buf_temp-rvs-line.pol7-l + temp-line-pump.pol9-l
            buf_temp-rvs-line.pol7-kg = buf_temp-rvs-line.pol7-kg + temp-line-pump.pol9-kg
            buf_temp-rvs-line.pol9    = buf_temp-rvs-line.pol8-l + buf_temp-rvs-line.pol7-l - buf_temp-rvs-line.pol6
            .
        end.
        assign
          temp-rvs-line.itog-pol6     = temp-rvs-line.itog-pol6 + buf_temp-rvs-line.pol6 - buf_temp-rvs-line.pol61
          temp-rvs-line.itog-pol4-l   = temp-rvs-line.itog-pol4-l + buf_temp-rvs-line.pol4-l-system
          temp-rvs-line.itog-pol4-kg  = temp-rvs-line.itog-pol4-kg + buf_temp-rvs-line.pol4-kg-system
          temp-rvs-line.itog-pol5-l   = temp-rvs-line.itog-pol5-l + buf_temp-rvs-line.pol5-l
          temp-rvs-line.itog-pol5-kg  = temp-rvs-line.itog-pol5-kg + buf_temp-rvs-line.pol5-kg
          temp-rvs-line.itog-pol8-l   = temp-rvs-line.itog-pol8-l + buf_temp-rvs-line.pol8-l
          temp-rvs-line.itog-pol8-kg  = temp-rvs-line.itog-pol8-kg + buf_temp-rvs-line.pol8-kg
          temp-rvs-line.itog-pol9     = temp-rvs-line.itog-pol9 + buf_temp-rvs-line.pol9 + buf_temp-rvs-line.pol61
          temp-rvs-line.itog-pol10    = temp-rvs-line.itog-pol10 + buf_temp-rvs-line.pol10
          temp-rvs-line.itog-pol11    = temp-rvs-line.itog-pol11 + buf_temp-rvs-line.pol11
          temp-rvs-line.itog-pol12    = temp-rvs-line.itog-pol12 + buf_temp-rvs-line.pol12
          temp-rvs-line.itog-pol13    = temp-rvs-line.itog-pol13 + buf_temp-rvs-line.pol13
          temp-rvs-line.itog-pol7-l   = temp-rvs-line.itog-pol7-l + buf_temp-rvs-line.pol7-l
          temp-rvs-line.itog-pol7-kg  = temp-rvs-line.itog-pol7-kg + buf_temp-rvs-line.pol7-kg
          temp-rvs-line.itog-pol16-l  = temp-rvs-line.itog-pol16-l + buf_temp-rvs-line.pol16-l
          temp-rvs-line.itog-pol16-kg = temp-rvs-line.itog-pol16-kg + buf_temp-rvs-line.pol16-kg
          temp-rvs-line.itog-pol17-l  = temp-rvs-line.itog-pol17-l + buf_temp-rvs-line.pol17-l
          temp-rvs-line.itog-pol17-kg = temp-rvs-line.itog-pol17-kg + buf_temp-rvs-line.pol17-kg
          temp-rvs-line.itog-pol18    = temp-rvs-line.itog-pol17-kg / temp-rvs-line.itog-pol17-l
          temp-rvs-line.itog-pol20-l  = temp-rvs-line.itog-pol20-l + buf_temp-rvs-line.pol20-l
          temp-rvs-line.itog-pol20-kg = temp-rvs-line.itog-pol20-kg + buf_temp-rvs-line.pol20-kg
          temp-rvs-line.itog-pol21-l  = temp-rvs-line.itog-pol21-l + buf_temp-rvs-line.pol21-l
          temp-rvs-line.itog-pol21-kg = temp-rvs-line.itog-pol21-kg + buf_temp-rvs-line.pol21-kg .
      end.
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td text_wrap="true" rowspan="2" style="text-align: right;">' + temp-rvs-line.gds-name + '</td>' skip
        '<td text_wrap="true" rowspan="2" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;">л</td>' skip
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol4-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if temp-rvs-line.itog-pol4-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol4-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol5-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol5-l <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol5-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol6,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol6 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol6,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol7-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol7-l <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol7-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol8-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol8-l <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol8-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol9,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol9 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol9,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol10,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol10 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol10,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol11,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol11 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol11,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol12,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol12 <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol12,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" colspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol17-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol17-l <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol17-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" colspan="2" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol20-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if temp-rvs-line.itog-pol20-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol20-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" rowspan="2" style="text-align: right;"></td>' skip
        '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol21-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if temp-rvs-line.itog-pol21-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol21-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td text_wrap="true" style="text-align: right;">кг</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol5-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol5-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol5-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol7-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol7-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol7-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol8-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol8-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol8-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" style="text-align: right;"></td>' skip
        '<td text_wrap="true" colspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(temp-rvs-line.itog-pol17-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if temp-rvs-line.itog-pol17-kg <> ? then fnc-convert-dot-to-colon(temp-rvs-line.itog-pol17-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
        '</tr>' skip
        .
      find first ub.shift-obj no-lock where ub.shift-obj.obj-code = p-obj-code and
        ub.shift-obj.obj-type = p-obj-type and ub.shift-obj.shift-date = x-date-end and
        ub.shift-obj.shift-num = x-shift-end no-error .
      for each bf_temp-rvs-line where bf_temp-rvs-line.gds-code = temp-rvs-line.gds-code:
        if get_com-vessel(p-obj-code, p-obj-type, "place-com-vessel", bf_temp-rvs-line.pl-code, ub.shift-obj.open-date,
          ub.shift-obj.close-date, ub.shift-obj.open-time, ub.shift-obj.close-time) then
        do:
          v-com-tanks = get_com-tanks(p-obj-code, p-obj-type, "place-com-tanks", bf_temp-rvs-line.pl-code,
            ub.shift-obj.open-date, ub.shift-obj.close-date, ub.shift-obj.open-time, ub.shift-obj.close-time) .
          if v-com-tanks > "" then
          do:
            v-main-tanks = trim(v-main-tanks,",") .
            if lookup(v-main-tanks, v-com-tanks, ",") <> 0 then next .
            if not get_com-vessel(p-obj-code, p-obj-type, "place-is-main", bf_temp-rvs-line.pl-code, ub.shift-obj.open-date,
              ub.shift-obj.close-date, ub.shift-obj.open-time, ub.shift-obj.close-time) then next .
            else
            do :
              v-main-tanks = v-main-tanks + "," + bf_temp-rvs-line.place_loc1 .
              v-num-com-tanks = num-entries(v-com-tanks) + 1 .
              do ii = 1 to num-entries(v-com-tanks) :
                find first buf_place no-lock where buf_place.obj-type = bf_temp-rvs-line.obj-type
                  and buf_place.obj-code = bf_temp-rvs-line.obj-code
                  and buf_place.loc1     = entry(ii, v-com-tanks)
                  and buf_place.status_  = ""
                  no-error .
                if not available buf_place
                  then
                do :
                  undo, return error ("Не найден сообщающийся резервуар " + entry(ii, v-com-tanks)) .
                end .
                find first com_temp-rvs-line where com_temp-rvs-line.gds-code = bf_temp-rvs-line.gds-code
                  and com_temp-rvs-line.pl-code  = buf_place.pl-code
                  no-error .
                if not available com_temp-rvs-line
                  then
                do :
                end .
                else
                do :
                  bf_temp-rvs-line.pol21-kg = bf_temp-rvs-line.pol21-kg + com_temp-rvs-line.pol21-kg .
                  bf_temp-rvs-line.pol20-kg = bf_temp-rvs-line.pol20-kg + com_temp-rvs-line.pol20-kg .
                  bf_temp-rvs-line.pol4-kg-system = bf_temp-rvs-line.pol4-kg-system + com_temp-rvs-line.pol4-kg-system .
                end .
              end .
              assign
                bf_temp-rvs-line.pol14    = bf_temp-rvs-line.state-level-total * 10
                bf_temp-rvs-line.pol15    = bf_temp-rvs-line.state-level-water * 10
                bf_temp-rvs-line.pol16-l  = bf_temp-rvs-line.state-brutto-qnty + bf_temp-rvs-line.state-add-qnty
                bf_temp-rvs-line.pol16-kg = (bf_temp-rvs-line.state-brutto-qnty + bf_temp-rvs-line.state-add-qnty) * bf_temp-rvs-line.density
                bf_temp-rvs-line.pol19    = bf_temp-rvs-line.state-temperature
                .
              put stream OutStr-html unformatted
                '<tr>' skip
                '<td text_wrap="true" rowspan="' + string((2 * v-num-com-tanks), ">9") + '" style="text-align: right;">   по резер.</td>' skip
                '<td text_wrap="true" rowspan="' + string((2 * v-num-com-tanks), ">9") + '" style="text-align: right;">' + bf_temp-rvs-line.place_loc1 + "," + v-com-tanks + '</td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;">л</td>' skip
                '<td text_wrap="true" rowspan="' + string((2 * v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol4-kg-system <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol6 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol9 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol10 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol11 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol12 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" style="text-align: center;">' + bf_temp-rvs-line.place_loc1 + '</td>' skip
                '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((2 * v-num-com-tanks), ">9") + '" colspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol20-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string((2 * v-num-com-tanks), ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string((2 * v-num-com-tanks), ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol21-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '</tr>' skip
                .
              do ii = 1 to num-entries(v-com-tanks) :
                find first buf_place no-lock where buf_place.obj-type = bf_temp-rvs-line.obj-type
                  and buf_place.obj-code = bf_temp-rvs-line.obj-code
                  and buf_place.loc1 = entry(ii, v-com-tanks)
                  and buf_place.status_ = ""
                  no-error .
                if not available buf_place
                  then
                do :
                  undo, return error ("Не найден сообщающийся резервуар " + entry(ii, v-com-tanks)) .
                end .
                find first com_temp-rvs-line where com_temp-rvs-line.gds-code = bf_temp-rvs-line.gds-code
                  and com_temp-rvs-line.pl-code  = buf_place.pl-code
                  no-error .
                if not available com_temp-rvs-line
                  then
                do :
                  put stream OutStr-html unformatted
                    '<tr>' skip
                    '<td text_wrap="true" style="text-align: center;">' + buf_place.loc1 + '</td>' skip
                    '<td text_wrap="true" style="text-align: center;"> - </td>' skip
                    '</tr>' skip
                    .
                end .
                else
                do :
                  assign
                    com_temp-rvs-line.pol14    = com_temp-rvs-line.state-level-total * 10
                    com_temp-rvs-line.pol15    = com_temp-rvs-line.state-level-water * 10
                    com_temp-rvs-line.pol16-l  = com_temp-rvs-line.state-brutto-qnty + com_temp-rvs-line.state-add-qnty
                    com_temp-rvs-line.pol16-kg = (com_temp-rvs-line.state-brutto-qnty + com_temp-rvs-line.state-add-qnty) * com_temp-rvs-line.density
                    com_temp-rvs-line.pol19    = com_temp-rvs-line.state-temperature
                    .
                  put stream OutStr-html unformatted
                    '<tr>' skip
                    '<td text_wrap="true" style="text-align: center;">' + buf_place.loc1 + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol17-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if com_temp-rvs-line.pol17-l <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol17-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '</tr>' skip
                    .
                end .
              end .
              put stream OutStr-html unformatted
                '<tr>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;">кг</td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" rowspan="' + string(v-num-com-tanks, ">9") + '" style="text-align: right;"></td>' skip
                '<td text_wrap="true" style="text-align: center;">' + bf_temp-rvs-line.place_loc1 + '</td>' skip
                '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                '</tr>' skip
                .
              do ii = 1 to num-entries(v-com-tanks) :
                find first buf_place no-lock where buf_place.obj-type = bf_temp-rvs-line.obj-type
                  and buf_place.obj-code = bf_temp-rvs-line.obj-code
                  and buf_place.loc1     = entry(ii, v-com-tanks)
                  and buf_place.status_  = ""
                  no-error .
                if not available buf_place
                  then
                do :
                  undo, return error ("Не найден сообщающийся резервуар " + entry(ii, v-com-tanks)) .
                end .
                find first com_temp-rvs-line where com_temp-rvs-line.gds-code = bf_temp-rvs-line.gds-code
                  and com_temp-rvs-line.pl-code  = buf_place.pl-code
                  no-error .
                if not available com_temp-rvs-line
                  then
                do :
                  put stream OutStr-html unformatted
                    '<tr>' skip
                    '<td text_wrap="true" style="text-align: center;">' + buf_place.loc1 + '</td>' skip
                    '<td text_wrap="true" style="text-align: center;"> - </td>' skip
                    '</tr>' skip
                    .
                end .
                else
                do :
                  put stream OutStr-html unformatted
                    '<tr>' skip
                    '<td text_wrap="true" style="text-align: center;">' + buf_place.loc1 + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(com_temp-rvs-line.pol17-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if com_temp-rvs-line.pol17-kg <> ? then fnc-convert-dot-to-colon(com_temp-rvs-line.pol17-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '</tr>' skip
                    .
                end .
              end .
            end .
            next .
          end .
          else
          do:
            put stream OutStr-html unformatted
              '<tr>' skip
              '<td text_wrap="true" rowspan="2" style="text-align: right;">   по резер.</td>' skip
              '<td text_wrap="true" rowspan="2" style="text-align: right;">' + bf_temp-rvs-line.place_loc1 + '</td>' skip
              '<td text_wrap="true" style="text-align: right;">л</td>' skip
              '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if bf_temp-rvs-line.pol4-kg-system <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol6 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol9 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol10 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol11 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol12 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" colspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" colspan="2" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if bf_temp-rvs-line.pol20-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" rowspan="2" style="text-align: right;"></td>' skip
              '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if bf_temp-rvs-line.pol21-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '</tr>' skip
              '<tr>' skip
              '<td text_wrap="true" style="text-align: right;">кг</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" style="text-align: right;"></td>' skip
              '<td text_wrap="true" colspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
              '</tr>' skip
              .
          end.
        end.
        else
        do:
          assign
            bf_temp-rvs-line.pol14    = bf_temp-rvs-line.state-level-total * 10
            bf_temp-rvs-line.pol15    = bf_temp-rvs-line.state-level-water * 10
            bf_temp-rvs-line.pol16-l  = bf_temp-rvs-line.state-brutto-qnty + bf_temp-rvs-line.state-add-qnty
            bf_temp-rvs-line.pol16-kg = (bf_temp-rvs-line.state-brutto-qnty + bf_temp-rvs-line.state-add-qnty) * bf_temp-rvs-line.density
            bf_temp-rvs-line.pol19    = bf_temp-rvs-line.state-temperature
            .
          put stream OutStr-html unformatted
            '<tr>' skip
            '<td text_wrap="true" rowspan="2" style="text-align: right;">   по резер.</td>' skip
            '<td text_wrap="true" rowspan="2" style="text-align: right;">' + bf_temp-rvs-line.place_loc1 + '</td>' skip
            '<td text_wrap="true" style="text-align: right;">л</td>' skip
            '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if bf_temp-rvs-line.pol4-kg-system <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol4-kg-system,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol6 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol6,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol9 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol9,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol10 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol10,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol11 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol11,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol12 <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol12,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" colspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-l <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-l,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" colspan="2" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if bf_temp-rvs-line.pol20-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol20-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" rowspan="2" style="text-align: right;"></td>' skip
            '<td text_wrap="true" rowspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; vertical-align: bottom;">' + if bf_temp-rvs-line.pol21-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol21-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td text_wrap="true" style="text-align: right;">кг</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol5-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol5-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol7-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol7-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol8-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol8-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" style="text-align: right;"></td>' skip
            '<td text_wrap="true" colspan="2" num="0.00" val="' + fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if bf_temp-rvs-line.pol17-kg <> ? then fnc-convert-dot-to-colon(bf_temp-rvs-line.pol17-kg,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '</tr>' skip
            .
        end.
        assign
          temp-rvs-line.itog-pol4-l   = 0
          temp-rvs-line.itog-pol4-kg  = 0
          temp-rvs-line.itog-pol5-l   = 0
          temp-rvs-line.itog-pol5-kg  = 0
          temp-rvs-line.itog-pol6     = 0
          temp-rvs-line.itog-pol8-l   = 0
          temp-rvs-line.itog-pol8-kg  = 0
          temp-rvs-line.itog-pol7-l   = 0
          temp-rvs-line.itog-pol7-kg  = 0
          temp-rvs-line.itog-pol17-l  = 0
          temp-rvs-line.itog-pol17-kg = 0
          temp-rvs-line.itog-pol16-l  = 0
          temp-rvs-line.itog-pol16-kg = 0
          temp-rvs-line.itog-pol18    = 0
          temp-rvs-line.itog-pol13    = 0
          temp-rvs-line.itog-pol20-l  = 0
          temp-rvs-line.itog-pol20-kg = 0
          temp-rvs-line.itog-pol21-l  = 0
          temp-rvs-line.itog-pol21-kg = 0
          v-main-tanks = ""
          v-com-tanks = ""
          .
      end.
    end.
  end.
  put stream OutStr-html unformatted
    '</tbody>' skip .
  output stream OutStr-html close.
end.
end procedure .
procedure add-chk :
  define input  parameter p-obj-type like ub.chk-doc.obj-type no-undo .
  define input  parameter p-obj-code like ub.chk-doc.obj-code no-undo .
  define input  parameter p-doc-code like ub.chk-doc.doc-code no-undo .
  define input  parameter p-chk-type like ub.chk-doc.chk-type no-undo .
  define input  parameter p-gds-code like ub.goods.gds-code   no-undo .
  define input  parameter p-pl-code  like ub.chk-gds.pl-code  no-undo .
  define input  parameter p-loc1     like ub.chk-gds.loc1     no-undo .
  define buffer buf_chk-gds  for ub.chk-gds.
  define buffer bf_chk-gds   for ub.chk-gds.
  define buffer buf_bar-code for ub.bar-code.
  define VARIABLE v-pl-code as integer no-undo .
  define buffer bf_place for ub.place .
  define variable v-qnty like ub.chk-gds.doc-qnty no-undo init 0.
  do
    on error undo, return error return-value
    :
    for each buf_chk-gds
      where buf_chk-gds.doc-code = p-doc-code
      and buf_chk-gds.pl-code = p-pl-code
      no-lock,
      first buf_bar-code
      where buf_bar-code.b-code = buf_chk-gds.b-code
      and buf_bar-code.gds-code = p-gds-code
      no-lock
      :
      find first temp-line-pump WHERE temp-line-pump.gds-code = buf_bar-code.gds-code
        and temp-line-pump.pump-code = buf_chk-gds.pump and
        temp-line-pump.nozzle-code  = buf_chk-gds.nozzle-code and
        temp-line-pump.pl-code = buf_chk-gds.pl-code
        no-error .
      if not available (temp-line-pump) then
      do:
        create temp-line-pump.
        assign
          temp-line-pump.gds-code    = buf_bar-code.gds-code
          temp-line-pump.pl-code     = buf_chk-gds.pl-code
          temp-line-pump.loc1        = buf_chk-gds.loc1
          temp-line-pump.pump-code   = buf_chk-gds.pump
          temp-line-pump.nozzle-code = buf_chk-gds.nozzle-code
          .
      end.
      v-qnty        = buf_chk-gds.doc-qnty .
      if p-chk-type = integer('17':U)
        then
      do:
        assign
          temp-line-pump.pol8-l  = temp-line-pump.pol8-l + v-qnty
          temp-line-pump.pol8-kg = temp-line-pump.pol8-kg + (v-qnty * buf_chk-gds.density)
          .
      end.
      if p-chk-type = integer('1':U) or p-chk-type = integer('6':U)
        then
      do:
        assign
          temp-line-pump.pol9-l  = temp-line-pump.pol9-l + v-qnty
          temp-line-pump.pol9-kg = temp-line-pump.pol9-kg + (v-qnty * buf_chk-gds.density)
          .
      end.
      if p-chk-type = integer('15':U) THEN
      DO:
        assign
          temp-line-pump.pol12 = temp-line-pump.pol12 + v-qnty
          .
      end.
      if p-chk-type = integer('14':U) THEN
      DO:
        if buf_chk-gds.write-off-code = 0 then
          assign
            temp-line-pump.pol10 = temp-line-pump.pol10  + v-qnty
            .
        if buf_chk-gds.write-off-code = 1 then
          assign
            temp-line-pump.pol11 = temp-line-pump.pol11 + v-qnty
            .
      end.
    end.
  end.
end procedure.
