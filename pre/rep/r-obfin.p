block-level on error undo, throw.
define input parameter p-radio-schet as integer   no-undo .
define input parameter p-curr-code   as integer   no-undo .
define input parameter p-type        as integer   no-undo .
define input parameter p-nal         as logical   no-undo .
define input parameter p-akt         as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-obfin.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-obfin.p $":U .
define variable vss-description as character no-undo init "Оборот финансов с разбивкой по основаниям за период".
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
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define Stream OutStream.
do
on error undo, return error
:
DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
ASSIGN parParentProc =  my-handle .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-curr-r-b as integer   no-undo .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output v-curr-r-b
  )  .
  define variable ii as integer initial 0  no-undo .
  DEFINE temp-table temp-schet no-undo
    field   r-schet      as character
    field   bank         as character
    field   code         as integer
    field   curr         as integer
    field   s-curr       as character
    field   sum1         as decimal
    field   sum2         as decimal
    INDEX pi  IS PRIMARY   code
  .
  DEFINE temp-table temp-code no-undo
    field   num          as character
    field   name         as character
    field   code         as integer
    field   lavel1       as integer
    field   lavel2       as integer
    field   lavel3       as integer
    INDEX pi  IS PRIMARY   num
    INDEX pi1              code
    INDEX pi2              lavel1
    INDEX pi3              lavel2
    INDEX pi4              lavel3
  .
  DEFINE temp-table temp-sum no-undo
    field   sum-in       as decimal
    field   sum-out      as decimal
    field   sum-in-rubl  as decimal
    field   sum-in-base  as decimal
    field   sum-out-rubl as decimal
    field   sum-out-base as decimal
    field   code-fin     as integer
    field   code-schet   as integer
    INDEX pi  IS PRIMARY   code-fin
    INDEX pi1              code-schet
  .
  define variable  v-fact-order-start     as decimal   no-undo .
  define variable  v-fact-order-end       as decimal   no-undo .
  run day-begin-fact-order in this-procedure ( input x-date-start,        output v-fact-order-start ).
  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),  output v-fact-order-end ).
  define variable v-ind             as integer   no-undo .
  define variable Counter1               as integer   no-undo .
  define variable Line                   as character no-undo .
  define variable jj as integer initial 0 no-undo .
  define variable is-null as logical   no-undo .
  define variable s-val as character no-undo .
   define variable ost-beg-rubl    as decimal no-undo .
   define variable ost-beg-base    as decimal no-undo .
   define variable ost-end-rubl    as decimal no-undo .
   define variable ost-end-base    as decimal no-undo .
   define variable sum1            as decimal no-undo .
   define variable sum2            as decimal no-undo .
   define variable sum-rubl     as decimal no-undo .
   define variable sum-base     as decimal no-undo .
  assign  Counter1 = 0 .
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
assign v-account = ( if integer( 10 ) = 0 then 100 else integer( 10 ) ).
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
  define buffer buf_arh-fin-doc-schet   for arh-fin-doc-schet .
  define buffer buf_arh-fin-doc-an      for arh-fin-doc-an .
  define buffer buf_arh-fin-doc-an-nal  for arh-fin-doc-an-nal .
  define buffer buf_fin-schet           for fin-schet .
  define buffer buf_fin-bank            for fin-bank .
  define buffer buf_currency            for currency .
  define buffer b_fin-code-cor-acc for fin-code-cor-acc .
  if p-radio-schet <> 7 then assign p-curr-code = 0 .
  case p-radio-schet :
    when 7 or when 5 then do:
      for each buf_fin-schet no-lock
        where buf_fin-schet.host-code = v-cntxt-host-code-obj
          and buf_fin-schet.cli-code  = v-cntxt-host-code-obj
          and buf_fin-schet.cli-type  = 'орг':U
          and buf_fin-schet.curr-code = p-curr-code :
define variable vss-include-info17 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  find first buf_currency no-lock where buf_currency.curr-code = buf_fin-schet.curr-code .
  find first buf_fin-bank no-lock where buf_fin-bank.host-code = buf_fin-schet.host-code and buf_fin-bank.code-bank = buf_fin-schet.code-bank .
  create temp-schet .
  assign
    temp-schet.r-schet = buf_fin-schet.r-schet
    temp-schet.code    = buf_fin-schet.code-schet
    temp-schet.curr    = buf_fin-schet.curr-code
    temp-schet.s-curr  = buf_currency.curr-abbr
    temp-schet.bank    = buf_fin-bank.short-name
    jj = jj + 1
  .
  assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
  run CalcOst (input 'ппп':U, input buf_fin-schet.curr-code, input v-fact-order-start, output sum1) .
  assign temp-schet.sum1 = sum1 .
  run CalcOst (input 'ппп':U, input 0, input v-fact-order-start, output sum1) .
  assign  ost-beg-rubl = ost-beg-rubl + sum1 .
  run CalcOst (input 'ппп':U, input v-curr-r-b, input v-fact-order-start, output sum1) .
  assign  ost-beg-base = ost-beg-base + sum1 .
  run CalcOst (input 'рпп':U, input buf_fin-schet.curr-code, input v-fact-order-start, output sum1) .
  assign temp-schet.sum1 = temp-schet.sum1 - sum1 .
  run CalcOst (input 'рпп':U, input 0, input v-fact-order-start, output sum1) .
  assign  ost-beg-rubl = ost-beg-rubl - sum1 .
  run CalcOst (input 'рпп':U, input v-curr-r-b, input v-fact-order-start, output sum1) .
  assign  ost-beg-base = ost-beg-base - sum1 .
  run CalcOst (input 'ппп':U, input buf_fin-schet.curr-code, input v-fact-order-end, output sum1) .
  assign temp-schet.sum2 = sum1 .
  run CalcOst (input 'ппп':U, input 0, input v-fact-order-end, output sum1) .
  assign  ost-end-rubl = ost-end-rubl + sum1 .
  run CalcOst (input 'ппп':U, input v-curr-r-b, input v-fact-order-end, output sum1) .
  assign  ost-end-base = ost-end-base + sum1 .
  run CalcOst (input 'рпп':U, input buf_fin-schet.curr-code, input v-fact-order-end, output sum1) .
  assign temp-schet.sum2 = temp-schet.sum2 - sum1 .
  run CalcOst (input 'рпп':U, input 0, input v-fact-order-end, output sum1) .
  assign  ost-end-rubl = ost-end-rubl - sum1 .
  run CalcOst (input 'рпп':U, input v-curr-r-b, input v-fact-order-end, output sum1) .
  assign  ost-end-base = ost-end-base - sum1 .
      end.
    end.
    when 3 or when 4 then do:
      do ii = 1 to num-entries ( fin-schet-recid ) :
        find first buf_fin-schet no-lock where recid(buf_fin-schet) = int(entry(ii,fin-schet-recid)) .
define variable vss-include-info18 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  find first buf_currency no-lock where buf_currency.curr-code = buf_fin-schet.curr-code .
  find first buf_fin-bank no-lock where buf_fin-bank.host-code = buf_fin-schet.host-code and buf_fin-bank.code-bank = buf_fin-schet.code-bank .
  create temp-schet .
  assign
    temp-schet.r-schet = buf_fin-schet.r-schet
    temp-schet.code    = buf_fin-schet.code-schet
    temp-schet.curr    = buf_fin-schet.curr-code
    temp-schet.s-curr  = buf_currency.curr-abbr
    temp-schet.bank    = buf_fin-bank.short-name
    jj = jj + 1
  .
  assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
  run CalcOst (input 'ппп':U, input buf_fin-schet.curr-code, input v-fact-order-start, output sum1) .
  assign temp-schet.sum1 = sum1 .
  run CalcOst (input 'ппп':U, input 0, input v-fact-order-start, output sum1) .
  assign  ost-beg-rubl = ost-beg-rubl + sum1 .
  run CalcOst (input 'ппп':U, input v-curr-r-b, input v-fact-order-start, output sum1) .
  assign  ost-beg-base = ost-beg-base + sum1 .
  run CalcOst (input 'рпп':U, input buf_fin-schet.curr-code, input v-fact-order-start, output sum1) .
  assign temp-schet.sum1 = temp-schet.sum1 - sum1 .
  run CalcOst (input 'рпп':U, input 0, input v-fact-order-start, output sum1) .
  assign  ost-beg-rubl = ost-beg-rubl - sum1 .
  run CalcOst (input 'рпп':U, input v-curr-r-b, input v-fact-order-start, output sum1) .
  assign  ost-beg-base = ost-beg-base - sum1 .
  run CalcOst (input 'ппп':U, input buf_fin-schet.curr-code, input v-fact-order-end, output sum1) .
  assign temp-schet.sum2 = sum1 .
  run CalcOst (input 'ппп':U, input 0, input v-fact-order-end, output sum1) .
  assign  ost-end-rubl = ost-end-rubl + sum1 .
  run CalcOst (input 'ппп':U, input v-curr-r-b, input v-fact-order-end, output sum1) .
  assign  ost-end-base = ost-end-base + sum1 .
  run CalcOst (input 'рпп':U, input buf_fin-schet.curr-code, input v-fact-order-end, output sum1) .
  assign temp-schet.sum2 = temp-schet.sum2 - sum1 .
  run CalcOst (input 'рпп':U, input 0, input v-fact-order-end, output sum1) .
  assign  ost-end-rubl = ost-end-rubl - sum1 .
  run CalcOst (input 'рпп':U, input v-curr-r-b, input v-fact-order-end, output sum1) .
  assign  ost-end-base = ost-end-base - sum1 .
      end.
    end.
  end.
  create temp-code .
    assign
      temp-code.num    = ""
      temp-code.name   = "Без основания"
      temp-code.code   = 0
      temp-code.lavel1 = 0
      temp-code.lavel2 = 0
      temp-code.lavel3 = 0
    .
  case p-type :
    when 1 then do:
      for each fin-code-cor-acc no-lock where fin-code-cor-acc.host-code = v-cntxt-host-code-obj :
        find first buf_arh-fin-doc-an no-lock
          where buf_arh-fin-doc-an.host-code         = v-cntxt-host-code-obj
            and buf_arh-fin-doc-an.fin-code-cor-acc  = fin-code-cor-acc.fin-code
            and buf_arh-fin-doc-an.fact-order       >= v-fact-order-start
            and buf_arh-fin-doc-an.fact-order       <= v-fact-order-end
        no-error .
        if not available buf_arh-fin-doc-an then do:
          if (p-nal or p-akt) then do:
            find first buf_arh-fin-doc-an-nal no-lock
              where buf_arh-fin-doc-an-nal.host-code         = v-cntxt-host-code-obj
                and buf_arh-fin-doc-an-nal.fin-code-cor-acc  = fin-code-cor-acc.fin-code
                and buf_arh-fin-doc-an-nal.fact-order       >= v-fact-order-start
                and buf_arh-fin-doc-an-nal.fact-order       <= v-fact-order-end
              no-error .
            if not available buf_arh-fin-doc-an-nal then next .
          end.
          else next .
        end.
        find first temp-code where temp-code.code = fin-code-cor-acc.fin-code no-error .
        if not available temp-code then do:
          create temp-code .
          assign
            temp-code.num    = fin-code-cor-acc.code-value
            temp-code.name   = fin-code-cor-acc.descr
            temp-code.code   = fin-code-cor-acc.fin-code
            temp-code.lavel1 = fin-code-cor-acc.level-1
            temp-code.lavel2 = fin-code-cor-acc.level-2
            temp-code.lavel3 = fin-code-cor-acc.level-3
          .
        end.
      end.
    end.
    when 2 then do:
      for each fin-code-an-uchet no-lock where fin-code-an-uchet.host-code = v-cntxt-host-code-obj :
        find first buf_arh-fin-doc-an no-lock
          where buf_arh-fin-doc-an.host-code         = v-cntxt-host-code-obj
            and buf_arh-fin-doc-an.fin-code-an-uchet = fin-code-an-uchet.fin-code
            and buf_arh-fin-doc-an.fact-order       >= v-fact-order-start
            and buf_arh-fin-doc-an.fact-order       <= v-fact-order-end
        no-error .
        if not available buf_arh-fin-doc-an then do:
          if (p-nal or p-akt) then do:
            find first buf_arh-fin-doc-an-nal no-lock
              where buf_arh-fin-doc-an-nal.host-code         = v-cntxt-host-code-obj
                and buf_arh-fin-doc-an-nal.fin-code-an-uchet  = fin-code-an-uchet.fin-code
                and buf_arh-fin-doc-an-nal.fact-order       >= v-fact-order-start
                and buf_arh-fin-doc-an-nal.fact-order       <= v-fact-order-end
              no-error .
            if not available buf_arh-fin-doc-an-nal then next .
          end.
          else next .
        end.
        find first temp-code where temp-code.code = fin-code-an-uchet.fin-code no-error .
        if not available temp-code then do:
          create temp-code .
          assign
            temp-code.num    = fin-code-an-uchet.code-value
            temp-code.name   = fin-code-an-uchet.descr
            temp-code.code   = fin-code-an-uchet.fin-code
            temp-code.lavel1 = fin-code-an-uchet.level-1
            temp-code.lavel2 = fin-code-an-uchet.level-2
            temp-code.lavel3 = fin-code-an-uchet.level-3
          .
        end.
      end.
    end.
    when 3 then do:
      for each fin-code-cel-nazn no-lock where fin-code-cel-nazn.host-code = v-cntxt-host-code-obj :
        find first buf_arh-fin-doc-an no-lock
          where buf_arh-fin-doc-an.host-code         = v-cntxt-host-code-obj
            and buf_arh-fin-doc-an.fin-code-cel-nazn = fin-code-cel-nazn.fin-code
            and buf_arh-fin-doc-an.fact-order       >= v-fact-order-start
            and buf_arh-fin-doc-an.fact-order       <= v-fact-order-end
        no-error .
        if not available buf_arh-fin-doc-an then do:
          if (p-nal or p-akt) then do:
            find first buf_arh-fin-doc-an-nal no-lock
              where buf_arh-fin-doc-an-nal.host-code         = v-cntxt-host-code-obj
                and buf_arh-fin-doc-an-nal.fin-code-cel-nazn  = fin-code-cel-nazn.fin-code
                and buf_arh-fin-doc-an-nal.fact-order       >= v-fact-order-start
                and buf_arh-fin-doc-an-nal.fact-order       <= v-fact-order-end
            no-error .
            if not available buf_arh-fin-doc-an-nal then next .
          end.
          else next .
        end.
        find first temp-code where temp-code.code = fin-code-cel-nazn.fin-code no-error .
        if not available temp-code then do:
          create temp-code .
          assign
            temp-code.num    = fin-code-cel-nazn.code-value
            temp-code.name   = fin-code-cel-nazn.descr
            temp-code.code   = fin-code-cel-nazn.fin-code
            temp-code.lavel1 = fin-code-cel-nazn.level-1
            temp-code.lavel2 = fin-code-cel-nazn.level-2
            temp-code.lavel3 = fin-code-cel-nazn.level-3
          .
        end.
      end.
    end.
  end.
  if p-nal then do:
    find first buf_currency no-lock where buf_currency.curr-code = p-curr-code .
    create temp-schet .
    assign
      temp-schet.r-schet = "Наличные"
      temp-schet.code    = 0
      temp-schet.curr    = p-curr-code
      temp-schet.s-curr  = buf_currency.curr-abbr
      temp-schet.bank    = ""
      jj = jj + 1
    .
    run CalcOst1 (input 'пко':U, input p-curr-code, input 0, input v-fact-order-start, output sum1) .
    assign temp-schet.sum1 = sum1 .
    if p-curr-code = 0 then  assign ost-beg-rubl = ost-beg-rubl + sum1 .
    else do:
      run CalcOst1 (input 'пко':U, input 0, input 0, input v-fact-order-start, output sum1) .
      assign  ost-beg-rubl = ost-beg-rubl + sum1 .
    end.
    run CalcOst1 (input 'пко':U, input v-curr-r-b, input 0, input v-fact-order-start, output sum1) .
    assign  ost-beg-base = ost-beg-base + sum1 .
    run CalcOst1 (input 'рко':U, input p-curr-code, input 0, input v-fact-order-start, output sum1) .
    assign temp-schet.sum1 = temp-schet.sum1 - sum1 .
    if p-curr-code = 0 then assign ost-beg-rubl = ost-beg-rubl - sum1 .
    else do:
      run CalcOst1 (input 'рко':U, input 0, input 0, input v-fact-order-start, output sum1) .
      assign  ost-beg-rubl = ost-beg-rubl - sum1 .
    end.
    run CalcOst1 (input 'рко':U, input v-curr-r-b, input 0, input v-fact-order-start, output sum1) .
    assign  ost-beg-base = ost-beg-base - sum1 .
    run CalcOst1 (input 'пко':U, input p-curr-code, input 0, input v-fact-order-end, output sum1) .
    assign temp-schet.sum2 = sum1 .
    if p-curr-code = 0 then assign ost-end-rubl = ost-end-rubl + sum1 .
    else do:
      run CalcOst1 (input 'пко':U, input 0, input 0, input v-fact-order-end, output sum1) .
      assign  ost-end-rubl = ost-end-rubl + sum1 .
    end.
    run CalcOst1 (input 'пко':U, input v-curr-r-b, input 0, input v-fact-order-end, output sum1) .
    assign  ost-end-base = ost-end-base + sum1 .
    run CalcOst1 (input 'рко':U, input p-curr-code, input 0, input v-fact-order-end, output sum1) .
    assign temp-schet.sum2 = temp-schet.sum2 - sum1 .
    if p-curr-code = 0 then  assign ost-end-rubl = ost-end-rubl - sum1 .
    else do:
      run CalcOst1 (input 'рко':U, input 0, input 0, input v-fact-order-end, output sum1) .
      assign  ost-end-rubl = ost-end-rubl - sum1 .
    end.
    run CalcOst1 (input 'рко':U, input v-curr-r-b, input 0, input v-fact-order-end, output sum1) .
    assign  ost-end-base = ost-end-base - sum1 .
  end.
  if p-akt then do:
    find first buf_currency no-lock where buf_currency.curr-code = p-curr-code .
    create temp-schet .
    assign
      temp-schet.r-schet = "АПЗ"
      temp-schet.code    = - 1
      temp-schet.curr    = p-curr-code
      temp-schet.s-curr  = buf_currency.curr-abbr
      temp-schet.bank    = ""
      jj = jj + 1
    .
    assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
    run CalcOst1 (input 'апп':U, input p-curr-code, input 0, input v-fact-order-start, output sum1) .
    assign temp-schet.sum1 = sum1 .
    if p-curr-code = 0 then  assign ost-beg-rubl = ost-beg-rubl + sum1 .
    else do:
      run CalcOst1 (input 'апп':U, input 0, input 0, input v-fact-order-start, output sum1) .
      assign  ost-beg-rubl = ost-beg-rubl + sum1 .
    end.
    run CalcOst1 (input 'апп':U, input v-curr-r-b, input 0, input v-fact-order-start, output sum1) .
    assign  ost-beg-base = ost-beg-base + sum1 .
    run CalcOst1 (input 'апр':U, input p-curr-code, input 0, input v-fact-order-start, output sum1) .
    assign temp-schet.sum1 = temp-schet.sum1 - sum1 .
    if p-curr-code = 0 then  assign ost-beg-rubl = ost-beg-rubl - sum1 .
    else do:
      run CalcOst1 (input 'апр':U, input 0, input 0, input v-fact-order-start, output sum1) .
      assign  ost-beg-rubl = ost-beg-rubl - sum1 .
    end.
    run CalcOst1 (input 'апр':U, input v-curr-r-b, input 0, input v-fact-order-start, output sum1) .
    assign  ost-beg-base = ost-beg-base - sum1 .
    run CalcOst1 (input 'апп':U, input p-curr-code, input 0, input v-fact-order-end, output sum1) .
    assign temp-schet.sum2 = sum1 .
    if p-curr-code = 0 then  assign ost-end-rubl = ost-end-rubl + sum1 .
    else do:
      run CalcOst1 (input 'апп':U, input 0, input 0, input v-fact-order-end, output sum1) .
      assign  ost-end-rubl = ost-end-rubl + sum1 .
    end.
    run CalcOst1 (input 'апп':U, input v-curr-r-b, input 0, input v-fact-order-end, output sum1) .
    assign  ost-end-base = ost-end-base + sum1 .
    run CalcOst1 (input 'апр':U, input p-curr-code, input 0, input v-fact-order-end, output sum1) .
    assign temp-schet.sum2 = temp-schet.sum2 - sum1 .
    if p-curr-code = 0 then  assign ost-end-rubl = ost-end-rubl - sum1 .
    else do:
      run CalcOst1 (input 'апр':U, input 0, input 0, input v-fact-order-end, output sum1) .
      assign  ost-end-rubl = ost-end-rubl - sum1 .
    end.
    run CalcOst1 (input 'апр':U, input v-curr-r-b, input 0, input v-fact-order-end, output sum1) .
    assign  ost-end-base = ost-end-base - sum1 .
  end.
  define variable str as character no-undo .
  define variable len as integer   no-undo .
  assign len = 42 + (jj + 2) * 24 - 1 .
  assign str = '"X(' + string( len ) + ")" .
  for each temp-code :
    for each temp-schet :
      create temp-sum .
      assign
        temp-sum.sum-in       = 0
        temp-sum.sum-out      = 0
        temp-sum.sum-in-rubl  = 0
        temp-sum.sum-out-base = 0
        temp-sum.sum-in-rubl  = 0
        temp-sum.sum-out-base = 0
        temp-sum.code-fin     = temp-code.code
        temp-sum.code-schet   = temp-schet.code
      .
      assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
      if temp-schet.code > 0 then do:
        run CalcOborot (input 'ппп':U, input temp-schet.curr, input v-fact-order-end, output sum1) .
        assign temp-sum.sum-in = sum1 .
        run CalcOborot (input 'ппп':U, input temp-schet.curr, input v-fact-order-start, output sum1) .
        assign temp-sum.sum-in = temp-sum.sum-in - sum1 .
        run CalcOborot (input 'ппп':U, input 0, input v-fact-order-end, output sum1) .
        assign temp-sum.sum-in-rubl = sum1 .
        run CalcOborot (input 'ппп':U, input 0, input v-fact-order-start, output sum1) .
        assign temp-sum.sum-in-rubl = temp-sum.sum-in-rubl - sum1 .
        run CalcOborot (input 'ппп':U, input v-curr-r-b, input v-fact-order-end, output sum1) .
        assign temp-sum.sum-in-base = sum1 .
        run CalcOborot (input 'ппп':U, input v-curr-r-b, input v-fact-order-start, output sum1) .
        assign temp-sum.sum-in-base = temp-sum.sum-in-base - sum1 .
        run CalcOborot (input 'рпп':U, input temp-schet.curr, input v-fact-order-end, output sum1) .
        assign temp-sum.sum-out = sum1 .
        run CalcOborot (input 'рпп':U, input temp-schet.curr, input v-fact-order-start, output sum1) .
        assign temp-sum.sum-out = temp-sum.sum-out - sum1 .
        run CalcOborot (input 'рпп':U, input 0, input v-fact-order-end, output sum1) .
        assign temp-sum.sum-out-rubl = sum1 .
        run CalcOborot (input 'рпп':U, input 0, input v-fact-order-start, output sum1) .
        assign temp-sum.sum-out-rubl = temp-sum.sum-out-rubl - sum1 .
        run CalcOborot (input 'рпп':U, input v-curr-r-b, input v-fact-order-end, output sum1) .
        assign temp-sum.sum-out-base = sum1 .
        run CalcOborot (input 'рпп':U, input v-curr-r-b, input v-fact-order-start, output sum1) .
        assign temp-sum.sum-out-base = temp-sum.sum-out-base - sum1 .
      end.
      else do:
        if temp-schet.code = 0 then do:
          if p-nal then do:
            run CalcOborot1 (input 'пко':U, input 0, input temp-schet.curr, input v-fact-order-end,input "sum-rubl-", output sum1) .
            assign temp-sum.sum-in = sum1 .
            run CalcOborot1 (input 'пко':U, input 0, input temp-schet.curr, input v-fact-order-start,input "sum-rubl-", output sum1) .
            assign temp-sum.sum-in = temp-sum.sum-in - sum1 .
            if p-curr-code = 0 then assign temp-sum.sum-in-rubl = temp-sum.sum-in .
            else do:
              run CalcOborot1 (input 'пко':U, input 0, input 0, input v-fact-order-end,input "sum-", output sum1) .
              assign temp-sum.sum-in-rubl = sum1 .
              run CalcOborot1 (input 'пко':U, input 0, input 0, input v-fact-order-start,input "sum-", output sum1) .
              assign temp-sum.sum-in-rubl = temp-sum.sum-in-rubl - sum1 .
            end.
            run CalcOborot1 (input 'пко':U, input v-curr-r-b, input v-curr-r-b, input v-fact-order-end,input "sum-base-", output sum1) .
            assign temp-sum.sum-in-base = sum1 .
            run CalcOborot1 (input 'пко':U, input v-curr-r-b, input v-curr-r-b, input v-fact-order-start,input "sum-base-", output sum1) .
            assign temp-sum.sum-in-base = temp-sum.sum-in-base - sum1 .
            run CalcOborot1 (input 'рко':U, input 0, input temp-schet.curr, input v-fact-order-end,input "sum-rubl-", output sum1) .
            assign temp-sum.sum-out = sum1 .
            run CalcOborot1 (input 'рко':U, input 0, input temp-schet.curr, input v-fact-order-start,input "sum-rubl-", output sum1) .
            assign temp-sum.sum-out = temp-sum.sum-out - sum1 .
            if p-curr-code = 0 then assign temp-sum.sum-out-rubl = temp-sum.sum-out .
            else do:
              run CalcOborot1 (input 'рко':U, input 0, input 0, input v-fact-order-end,input "sum-", output sum1) .
              assign temp-sum.sum-out-rubl = sum1 .
              run CalcOborot1 (input 'рко':U, input 0, input 0, input v-fact-order-start,input "sum-", output sum1) .
              assign temp-sum.sum-out-rubl = temp-sum.sum-out-rubl - sum1 .
            end.
            run CalcOborot1 (input 'рко':U, input v-curr-r-b, input v-curr-r-b, input v-fact-order-end,input "sum-base-", output sum1) .
            assign temp-sum.sum-out-base = sum1 .
            run CalcOborot1 (input 'рко':U, input v-curr-r-b, input v-curr-r-b, input v-fact-order-start,input "sum-base-", output sum1) .
            assign temp-sum.sum-out-base = temp-sum.sum-out-base - sum1 .
          end.
        end.
        else do:
          if p-akt then do:
            run CalcOborot1 (input 'апп':U, input temp-schet.curr, input temp-schet.curr, input v-fact-order-end,input "sum-rubl-", output sum1) .
            assign temp-sum.sum-in = sum1 .
            run CalcOborot1 (input 'апп':U, input temp-schet.curr, input temp-schet.curr, input v-fact-order-start,input "sum-rubl-", output sum1) .
            assign temp-sum.sum-in = temp-sum.sum-in - sum1 .
            if p-curr-code = 0 then assign temp-sum.sum-in-rubl = temp-sum.sum-in .
            else do:
              run CalcOborot1 (input 'апп':U, input 0, input 0, input v-fact-order-end,input "sum-rubl-", output sum1) .
              assign temp-sum.sum-in-rubl = sum1 .
              run CalcOborot1 (input 'апп':U, input 0, input 0, input v-fact-order-start,input "sum-rubl-", output sum1) .
              assign temp-sum.sum-in-rubl = temp-sum.sum-in-rubl - sum1 .
            end.
            run CalcOborot1 (input 'апп':U, input v-curr-r-b, input v-curr-r-b, input v-fact-order-end,input "sum-base-", output sum1) .
            assign temp-sum.sum-in-base = sum1 .
            run CalcOborot1 (input 'апп':U, input v-curr-r-b, input v-curr-r-b, input v-fact-order-start,input "sum-base-", output sum1) .
            assign temp-sum.sum-in-base = temp-sum.sum-in-base - sum1 .
            run CalcOborot1 (input 'апр':U, input temp-schet.curr, input temp-schet.curr, input v-fact-order-end,input "sum-rubl-", output sum1) .
            assign temp-sum.sum-out = sum1 .
            run CalcOborot1 (input 'апр':U, input temp-schet.curr, input temp-schet.curr, input v-fact-order-start,input "sum-rubl-", output sum1) .
            assign temp-sum.sum-out = temp-sum.sum-out - sum1 .
            if p-curr-code = 0 then  assign temp-sum.sum-out-rubl = temp-sum.sum-out .
            else do:
              run CalcOborot1 (input 'апр':U, input 0, input 0, input v-fact-order-end,input "sum-", output sum1) .
              assign temp-sum.sum-out-rubl = sum1 .
              run CalcOborot1 (input 'апр':U, input 0, input 0, input v-fact-order-start,input "sum-", output sum1) .
              assign temp-sum.sum-out-rubl = temp-sum.sum-out-rubl - sum1 .
            end.
            run CalcOborot1 (input 'апр':U, input v-curr-r-b, input v-curr-r-b, input v-fact-order-end,input "sum-base-", output sum1) .
            assign temp-sum.sum-out-base = sum1 .
            run CalcOborot1 (input 'апр':U, input v-curr-r-b, input v-curr-r-b, input v-fact-order-start,input "sum-base-", output sum1) .
            assign temp-sum.sum-out-base = temp-sum.sum-out-base - sum1 .
          end.
        end.
      end.
    end.
  end.
if session :set-wait-state( "compiler" ) then.
  Line = fill("-", 250).
  if len < 136 then run prn-lib-open-stream  in this-procedure (input parParentProc,input 62,input yes,input no).
  else              run prn-lib-open-stream  in this-procedure (input parParentProc,input 43,input yes,input no).
  FORM with FRAME f-doc .
  run PrintTitul in this-procedure .
  put stream PrnLibStream  "|"  "Остаток на начало"  format "X(40)" "|" at 42 .
  assign jj = 1 .
  for each temp-schet :
    put stream PrnLibStream  temp-schet.sum1 format  "->>>,>>>,>>>,>>>,>>9.99"  "|" at ( 42 + 24 * jj ) .
    assign jj = jj + 1 .
  end.
  put stream PrnLibStream  ost-beg-rubl format "->>>,>>>,>>>,>>>,>>9.99" "|" at ( 42 + 24 * jj ) .
  assign jj = jj + 1 .
  put stream PrnLibStream  ost-beg-base format "->>>,>>>,>>>,>>>,>>9.99" "|" at ( 42 + 24 * jj ) skip .
  put stream PrnLibStream  Line format str  skip  "Поступления" format "X(40)"  skip .
  for each temp-code break by temp-code.code by temp-code.lavel1 by temp-code.lavel2 by temp-code.lavel3 :
    assign is-null = yes .
    for each temp-sum where temp-sum.code-fin = temp-code.code :
      if temp-sum.sum-in <> 0 or temp-sum.sum-in-rubl <> 0 or temp-sum.sum-in-base <> 0 then do:
        assign is-null = no .
        leave .
      end.
    end.
    if is-null = yes then next .
    run prn-line in this-procedure (yes) .
  end.
  put stream PrnLibStream  Line format str  skip  "Выбытия" format "X(40)"  skip .
  for each temp-code break by temp-code.code by temp-code.lavel1 by temp-code.lavel2 by temp-code.lavel3 :
    assign is-null = yes .
    for each temp-sum where temp-sum.code-fin = temp-code.code :
      if temp-sum.sum-out <> 0 or temp-sum.sum-out-rubl <> 0 or temp-sum.sum-out-base <> 0 then do:
        assign is-null = no .
        leave .
      end.
    end.
    if is-null = yes then next .
    run prn-line in this-procedure (no) .
  end.
  put stream PrnLibStream  Line format str  skip  "|"  "Остаток на конец"  format "X(40)" "|" at 42 .
  assign jj = 1 .
  for each temp-schet :
    put stream PrnLibStream  temp-schet.sum2 format  "->>>,>>>,>>>,>>>,>>9.99"  "|" at ( 42 + 24 * jj ) .
    assign jj = jj + 1 .
  end.
  put stream PrnLibStream  ost-end-rubl format "->>>,>>>,>>>,>>>,>>9.99" "|" at ( 42 + 24 * jj ) .
  assign jj = jj + 1 .
  put stream PrnLibStream  ost-end-base format "->>>,>>>,>>>,>>>,>>9.99" "|" at ( 42 + 24 * jj ) skip Line format str  skip .
  HIDE stream PrnLibStream FRAME BottomFrame .
  OUTPUT stream PrnLibStream CLOSE.
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
if session :set-wait-state( "" ) then.
  if len < 136 then run prn-lib-prn-file in this-procedure (input parParentProc,input 0).
  else              run prn-lib-prn-file in this-procedure (input parParentProc,input 8).
end.
procedure prn-line :
  do on error undo, return error return-value :
    define input  parameter p-is-in as logical   no-undo .
    run is-page in this-procedure .
    put stream PrnLibStream   "|" string( (if temp-code.lavel2 <> 0 then " " else "" ) + (if temp-code.lavel3 <> 0 then " " else "" ) + temp-code.num + " " + temp-code.name)   format "X(40)" "|" at 42 .
    assign
      sum-rubl = 0
      sum-base = 0
      jj = 1
    .
    for each temp-schet :
      find first  temp-sum where temp-sum.code-fin = temp-code.code and temp-sum.code-schet = temp-schet.code .
      put stream PrnLibStream  (if p-is-in then temp-sum.sum-in else temp-sum.sum-out) format "->>>,>>>,>>>,>>>,>>9.99" "|" at ( 42 + 24 * jj ) .
      assign
        jj = jj + 1
        sum-rubl = sum-rubl + (if p-is-in then temp-sum.sum-in-rubl else temp-sum.sum-out-rubl)
        sum-base = sum-base + (if p-is-in then temp-sum.sum-in-base else temp-sum.sum-out-base)
      .
    end.
    put stream PrnLibStream sum-rubl format "->>>,>>>,>>>,>>>,>>9.99" "|" at ( 42 + 24 * jj ) .
    assign jj = jj + 1 .
    put stream PrnLibStream sum-base format "->>>,>>>,>>>,>>>,>>9.99" "|" at ( 42 + 24 * jj ) skip .
  end.
end procedure.
procedure PutColumnTitulExcel :
  do
  on error undo, return error return-value
  :
   end.
end procedure.
procedure is-page :
  do
  on error undo, return error return-value
  :
    if line-counter( PrnLibStream ) + 2 > page-size( PrnLibStream ) then do:
      put stream PrnLibStream  skip Line format str skip "продолжение - на следующей странице" AT 30 SKIP .
      page stream PrnLibStream .
      run PrintTitul .
    end.
  end.
end procedure.
procedure PrintTitul :
  do
  on error undo, return error return-value
  :
    PUT stream PrnLibStream SPACE(10) ReportNAme format "X(100)" SKIP .
    PUT stream PrnLibStream str1 format "X(100)" SKIP .
    put stream PrnLibStream  skip cur-time-print() format "x(35)" string( "Страница" ) AT 45 PAGE-NUMBER( PrnLibStream ) AT 55 FORMAT ">>9" SKIP .
    put stream PrnLibStream  skip  Line format str  skip   "|"  "Основание"  format "X(10)" "|" at 42 .
    assign jj = 1 .
    for each temp-schet :
      put stream PrnLibStream  temp-schet.r-schet format "X(20)" "|" at ( 42 + 24 * jj ) .
      assign jj = jj + 1 .
    end.
    put stream PrnLibStream  "Итого в руб." format "X(20)" "|" at ( 42 + 24 * jj ) .
    assign jj = jj + 1 .
    put stream PrnLibStream  "Итого в б.вал." format "X(20)" "|" at ( 42 + 24 * jj ) skip Line format str  skip .
  end.
end procedure.
procedure CalcOst :
  do  on error undo, return error return-value  :
    define input  parameter p-typ as character no-undo .
    define input  parameter p-cur as integer   no-undo .
    define input  parameter p-fo  as decimal   no-undo .
    define output parameter sm    as decimal   no-undo .
    assign sm = 0 .
    assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
    find last buf_arh-fin-doc-schet no-lock
      where buf_arh-fin-doc-schet.host-code        = buf_fin-schet.host-code
        and buf_arh-fin-doc-schet.code-schet       = buf_fin-schet.code-schet
        and buf_arh-fin-doc-schet.cli-code         = buf_fin-schet.host-code
        and buf_arh-fin-doc-schet.cli-type         = 'орг':U
        and buf_arh-fin-doc-schet.fin-ext-doc-type = p-typ
        and buf_arh-fin-doc-schet.calc-curr-code   = p-cur
        and buf_arh-fin-doc-schet.sum-type         = ""
        and buf_arh-fin-doc-schet.fact-order      <= p-fo
     no-error .
    if available buf_arh-fin-doc-schet then do:
      if p-typ = 'ппп':U then assign sm = buf_arh-fin-doc-schet.income .
      else                               assign sm = buf_arh-fin-doc-schet.expense .
    end.
  end.
end procedure.
procedure CalcOborot :
  do on error undo, return error return-value :
    define input  parameter p-typ as character no-undo .
    define input  parameter p-cur as integer   no-undo .
    define input  parameter p-fo  as decimal   no-undo .
    define output parameter sm    as decimal   no-undo .
    assign sm = 0 .
    assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
    case p-type :
      when 1 then do:
          find last buf_arh-fin-doc-an no-lock
            where buf_arh-fin-doc-an.host-code         = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an.code-schet        = temp-schet.code
              and buf_arh-fin-doc-an.cli-code          = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an.cli-type          = 'орг':U
              and buf_arh-fin-doc-an.fin-ext-doc-type  = p-typ
              and buf_arh-fin-doc-an.calc-curr-code    = p-cur
              and buf_arh-fin-doc-an.fact-order       <= p-fo
              and buf_arh-fin-doc-an.fin-code-cor-acc  = temp-code.code
              and buf_arh-fin-doc-an.sum-type          = "sum-schet-cor-acc"
              and buf_arh-fin-doc-an.fin-code-an-uchet = 0
              and buf_arh-fin-doc-an.fin-code-cel-nazn = 0
          no-error .
      end.
      when 2 then do:
          find last buf_arh-fin-doc-an no-lock
            where buf_arh-fin-doc-an.host-code         = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an.code-schet        = temp-schet.code
              and buf_arh-fin-doc-an.cli-code          = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an.cli-type          = 'орг':U
              and buf_arh-fin-doc-an.fin-ext-doc-type  = p-typ
              and buf_arh-fin-doc-an.calc-curr-code    = p-cur
              and buf_arh-fin-doc-an.fact-order       <= p-fo
              and buf_arh-fin-doc-an.fin-code-an-uchet = temp-code.code
              and buf_arh-fin-doc-an.sum-type          = "sum-schet-uchet"
              and buf_arh-fin-doc-an.fin-code-cor-acc  = 0
              and buf_arh-fin-doc-an.fin-code-cel-nazn = 0
           no-error .
      end.
      when 3 then do:
          find last buf_arh-fin-doc-an no-lock
            where buf_arh-fin-doc-an.host-code         = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an.code-schet        = temp-schet.code
              and buf_arh-fin-doc-an.cli-code          = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an.cli-type          = 'орг':U
              and buf_arh-fin-doc-an.fin-ext-doc-type  = p-typ
              and buf_arh-fin-doc-an.calc-curr-code    = p-cur
              and buf_arh-fin-doc-an.fact-order       <= p-fo
              and buf_arh-fin-doc-an.fin-code-cel-nazn = temp-code.code
              and buf_arh-fin-doc-an.sum-type          = "sum-schet-cel-nazn"
              and buf_arh-fin-doc-an.fin-code-cor-acc  = 0
              and buf_arh-fin-doc-an.fin-code-an-uchet = 0
          no-error .
      end.
    end.
    if available buf_arh-fin-doc-an then do:
      if p-typ = 'ппп':U then assign sm = sm + buf_arh-fin-doc-an.income .
      else                               assign sm = sm + buf_arh-fin-doc-an.expense .
    end.
  end.
end procedure.
procedure CalcOst1 :
  do on error undo, return error return-value :
    define input  parameter p-typ as character no-undo .
    define input  parameter p-calc as integer   no-undo .
    define input  parameter p-cur as integer   no-undo .
    define input  parameter p-fo  as decimal   no-undo .
    define output parameter sm    as decimal   no-undo .
    assign sm = 0 .
    assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
    find last buf_arh-fin-doc-an-nal no-lock
      where buf_arh-fin-doc-an-nal.host-code         = v-cntxt-host-code-obj
        and buf_arh-fin-doc-an-nal.fin-ext-doc-type  = p-typ
        and buf_arh-fin-doc-an-nal.cli-code          = v-cntxt-host-code-obj
        and buf_arh-fin-doc-an-nal.cli-type          = 'орг':U
        and buf_arh-fin-doc-an-nal.curr-code         = p-cur
        and buf_arh-fin-doc-an-nal.calc-curr-code    = p-calc
        and buf_arh-fin-doc-an-nal.sum-type          = "sum-without-schet-code"
        and buf_arh-fin-doc-an-nal.fact-order       <= p-fo
        and buf_arh-fin-doc-an-nal.fin-code-cor-acc  = 0
        and buf_arh-fin-doc-an-nal.fin-code-acc      = 0
        and buf_arh-fin-doc-an-nal.fin-code-an-uchet = 0
        and buf_arh-fin-doc-an-nal.fin-code-cel-nazn = 0
    no-error .
    if available buf_arh-fin-doc-an-nal then do:
      if p-typ = 'пко':U or p-typ = 'апп':U then assign sm = sm + buf_arh-fin-doc-an-nal.income .
      else                                                       assign sm = sm + buf_arh-fin-doc-an-nal.expense .
    end.
  end.
end procedure.
procedure CalcOborot1 :
  do on error undo, return error return-value :
    define input  parameter p-typ as character no-undo .
    define input  parameter p-calc as integer   no-undo .
    define input  parameter p-cur as integer   no-undo .
    define input  parameter p-fo  as decimal   no-undo .
    define input  parameter p-sum-type as character no-undo .
    define output parameter sm    as decimal   no-undo .
    assign sm = 0 .
    assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
      case p-type :
        when 1 then do:
          assign p-sum-type = p-sum-type + "cor-acc" .
          find last buf_arh-fin-doc-an-nal no-lock
            where buf_arh-fin-doc-an-nal.host-code         = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an-nal.cli-code          = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an-nal.cli-type          = 'орг':U
              and buf_arh-fin-doc-an-nal.fin-ext-doc-type  = p-typ
              and buf_arh-fin-doc-an-nal.curr-code         = p-cur
              and buf_arh-fin-doc-an-nal.calc-curr-code    = p-calc
              and buf_arh-fin-doc-an-nal.sum-type          = p-sum-type
              and buf_arh-fin-doc-an-nal.fact-order       <= p-fo
              and buf_arh-fin-doc-an-nal.fin-code-cor-acc  = temp-code.code
              and buf_arh-fin-doc-an-nal.fin-code-acc      = 0
              and buf_arh-fin-doc-an-nal.fin-code-an-uchet = 0
              and buf_arh-fin-doc-an-nal.fin-code-cel-nazn = 0
          no-error .
        end.
        when 2 then do:
          assign p-sum-type = p-sum-type + "uchet" .
          find last buf_arh-fin-doc-an-nal no-lock
            where buf_arh-fin-doc-an-nal.host-code         = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an-nal.cli-code          = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an-nal.cli-type          = 'орг':U
              and buf_arh-fin-doc-an-nal.fin-ext-doc-type  = p-typ
              and buf_arh-fin-doc-an-nal.curr-code         = p-cur
              and buf_arh-fin-doc-an-nal.calc-curr-code    = p-calc
              and buf_arh-fin-doc-an-nal.sum-type          = p-sum-type
              and buf_arh-fin-doc-an-nal.fact-order       <= p-fo
              and buf_arh-fin-doc-an-nal.fin-code-cor-acc  = 0
              and buf_arh-fin-doc-an-nal.fin-code-acc      = 0
              and buf_arh-fin-doc-an-nal.fin-code-an-uchet = temp-code.code
              and buf_arh-fin-doc-an-nal.fin-code-cel-nazn = 0
          no-error .
        end.
        when 3 then do:
          assign p-sum-type = p-sum-type + "cel-nazn" .
          find last buf_arh-fin-doc-an-nal no-lock
            where buf_arh-fin-doc-an-nal.host-code         = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an-nal.cli-code          = v-cntxt-host-code-obj
              and buf_arh-fin-doc-an-nal.cli-type          = 'орг':U
              and buf_arh-fin-doc-an-nal.fin-ext-doc-type  = p-typ
              and buf_arh-fin-doc-an-nal.curr-code         = p-cur
              and buf_arh-fin-doc-an-nal.calc-curr-code    = p-calc
              and buf_arh-fin-doc-an-nal.sum-type          = p-sum-type
              and buf_arh-fin-doc-an-nal.fact-order       <= p-fo
              and buf_arh-fin-doc-an-nal.fin-code-cor-acc  = 0
              and buf_arh-fin-doc-an-nal.fin-code-acc      = 0
              and buf_arh-fin-doc-an-nal.fin-code-an-uchet = 0
              and buf_arh-fin-doc-an-nal.fin-code-cel-nazn = temp-code.code
          no-error .
        end.
      end.
    if available buf_arh-fin-doc-an-nal then do:
      if p-typ = 'пко':U or p-typ = 'апп':U  then assign sm = sm + buf_arh-fin-doc-an-nal.income .
      else                                                        assign sm = sm + buf_arh-fin-doc-an-nal.expense .
    end.
  end.
end procedure.
