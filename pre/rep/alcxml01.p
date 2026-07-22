block-level on error undo, throw.
define input  parameter parparentproc   as handle    no-undo .
define input  parameter p-dir-full-name as character no-undo .
define input  parameter p-zip-arch      as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: alcxml01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/alcxml01.p $":U .
define variable vss-description as character no-undo init "Декларация об объемах розничной продажи алкогольной продукции в XML (Москва)".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define stream xml-out.
define stream lst-out.
define stream serr.
function get-date-str return character (input p-date as date) forward.
define temp-table tt-gds no-undo like ub.goods
    field alc-type-inner-code like ub.alc-type.alc-type-inner-code
    field create-user-db-num  like ub.alc-type.create-user-db-num
    field alc-type-code       like ub.alc-type.alc-type-code
    field alc-type-name       like ub.alc-type.alc-type-name
index pi is primary unique gds-code
.
define temp-table tt-alc-report-head no-undo
  field obj-type          like ub.clients.obj-type
  field obj-code          like ub.clients.obj-code
  field doc-code          like ub.trn-doc.doc-code
  field lic-series        as character
  field lic-number        as character
  field lic-addendum      as character
  field transaction-date  as date
  field transaction-type  as integer
  field doc-date          like ub.trn-doc.fact-date
  field supplier-id       as decimal
index pi is primary unique
  obj-type
  obj-code
  doc-code
  transaction-type
.
define temp-table tt-alc-report-line no-undo
  field doc-code              like ub.trn-doc.doc-code
  field obj-type              like ub.clients.obj-type
  field obj-code              like ub.clients.obj-code
  field gds-code              like ub.goods.gds-code
  field transaction-type      as integer
  field egais-gds-code        as decimal
  field quantity              as decimal
  field is-quantity-discrete  as logical
  field doc-date              as date
  field doc-number            as character
index pi is primary unique
  obj-type
  obj-code
  doc-code
  transaction-type
  gds-code
.
define temp-table tt-xml-file no-undo
  field file-id   as integer
  field file-name as character
index pi is primary unique
  file-id
.
define variable v-begin-date         as date      no-undo .
define variable v-end-date           as date      no-undo .
define variable v-fact-order-start   as decimal   no-undo .
define variable v-fact-order-end     as decimal   no-undo .
define variable v-par-val            as character no-undo .
define variable v-par-type           as character no-undo .
define variable v-dir-name           as character no-undo .
define variable v-unbinded-goods     as logical   no-undo .
define variable v-unbinded-suppliers as logical   no-undo .
do on error undo, return error return-value
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'report-glob':U
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
      if thbjattr_thbj-attr.prop-code = 'ardecldt' then v-par-val =  string(thbjattr_thbj-attr.property-value-date,"99/99/9999") .
  end.
  assign
    v-begin-date  = date(v-par-val)
    v-end-date    = x-Date-Alone
    v-dir-name    = replace( p-dir-full-name , "/" , "\") .
  .
  if length(v-dir-name) <> r-index( v-dir-name , "\") then do:
    assign
      v-dir-name = v-dir-name + "\" .
    .
  end .
  run day-begin-fact-order in this-procedure ( input v-begin-date
                                             , output v-fact-order-start
                                             ).
  run factord-end-day in this-procedure ( input v-end-date
                                        , output v-fact-order-end
                                        ).
  run clear-tt in this-procedure .
  run fill-tt-rep in this-procedure .
  run write-xml-files in this-procedure .
  if p-zip-arch = yes then do:
    run pack-xml-files in this-procedure no-error .
    if error-status :error then do:
      message
        error-status :get-message(1) skip(1)
        "Отчет не упакован!"
      view-as alert-box error.
    end.
  end.
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
  run clear-tt in this-procedure .
  if v-unbinded-goods = yes
  then do:
    message
      "В процессе формирования отчета были найдены товары не имеющие ЕГАИС-кода" skip
      "Подробности в файле alcdcl01.err"
    view-as alert-box error.
  end.
  if v-unbinded-suppliers = yes
  then do:
    message
      "В процессе формирования отчета были найдены поставщики не имеющие ЕГАИС-кода" skip
      "Подробности в файле alcdcl01.err"
    view-as alert-box error.
  end.
  message
    "Формирование отчета завершено."
  view-as alert-box information.
end.
procedure clear-tt :
do
on error undo, return error return-value
:
  empty temp-table tt-gds.
  empty temp-table tt-alc-report-head.
  empty temp-table tt-alc-report-line.
  empty temp-table tt-xml-file.
end.
end procedure.
procedure find-alc-goods :
do
on error undo, return error return-value
:
  define buffer buf_alc-type      for ub.alc-type.
  define buffer buf_alc-type-gds  for ub.alc-type-gds.
  define buffer buf_goods         for ub.goods.
  empty temp-table tt-gds.
  for each buf_alc-type no-lock
        where buf_alc-type.alc-type-status = 0
  :
    for each buf_alc-type-gds no-lock
          where buf_alc-type-gds.alc-type-inner-code = buf_alc-type.alc-type-inner-code
            AND buf_alc-type-gds.create-user-db-num  = buf_alc-type.create-user-db-num
      , first buf_goods no-lock
          where buf_goods.gds-code = buf_alc-type-gds.gds-code
    :
      find first tt-gds no-lock where tt-gds.gds-code = buf_goods.gds-code no-error .
      if not available tt-gds then do:
        create tt-gds.
        buffer-copy buf_goods to tt-gds
        assign
          tt-gds.alc-type-inner-code = buf_alc-type.alc-type-inner-code
          tt-gds.create-user-db-num  = buf_alc-type.create-user-db-num
          tt-gds.alc-type-code       = buf_alc-type.alc-type-code
          tt-gds.alc-type-name       = buf_alc-type.alc-type-name
        .
      end.
    end.
  end.
end.
end procedure.
procedure find-license :
  define input  parameter p-obj-type      like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code      like ub.clients.obj-code no-undo .
  define output parameter p-lic-series    as character             no-undo .
  define output parameter p-lic-number    as character             no-undo .
  define output parameter p-lic-addendum  as character             no-undo .
  define buffer buf_alc-sale-lic for ub.alc-sale-lic.
  define variable v-host-code as integer   no-undo .
do
on error undo, return error return-value
:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
  for each   buf_alc-sale-lic no-lock
       where buf_alc-sale-lic.cli-type = 'орг':U
         and buf_alc-sale-lic.cli-code = v-host-code
         and buf_alc-sale-lic.date-to  > v-end-date
       :
        assign
          p-lic-series = buf_alc-sale-lic.seria
          p-lic-number = buf_alc-sale-lic.number
        .
        return .
  end.
  assign
    p-lic-series   = ?
    p-lic-number   = ?
    p-lic-addendum = ?
  .
end.
end procedure.
procedure find-alc-egais-code :
  define input  parameter p-gds-code    like ub.goods.gds-code  no-undo .
  define output parameter p-egais-code  as character            no-undo .
  define buffer buf_egais-gds for ub.egais-gds.
do
on error undo, return error return-value
:
  find first buf_egais-gds no-lock
    where buf_egais-gds.gds-code = p-gds-code
  no-error .
  if available buf_egais-gds then do :
    assign
      p-egais-code = buf_egais-gds.alpr-code-egais
    .
  end.
  else do:
    assign
      p-egais-code = ?
    .
  end.
end.
end procedure.
procedure find-supp-egais-code :
  define input  parameter p-obj-type        like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code        like ub.clients.obj-code no-undo .
  define output parameter p-supp-egais-code as character             no-undo .
  define buffer buf_egais-clients for ub.egais-clients.
do
on error undo, return error return-value
:
  find first buf_egais-clients no-lock
    where buf_egais-clients.obj-type = p-obj-type
      and buf_egais-clients.obj-code = p-obj-code
  no-error .
  if available buf_egais-clients then do:
    assign
      p-supp-egais-code = buf_egais-clients.supp-code-egais
    .
  end.
  else do:
    assign
      p-supp-egais-code = ?
    .
  end.
end.
end procedure.
procedure get-transaction-type :
  define input  parameter p-rowid             as rowid     no-undo .
  define input  parameter p-qnty              as decimal   no-undo .
  define output parameter p-transaction-type  as integer   no-undo .
  define buffer buf_trn-doc for ub.trn-doc.
  define variable v-lic-series        as character no-undo .
  define variable v-lic-number        as character no-undo .
  define variable v-lic-addendum      as character no-undo .
do
on error undo, return error return-value
:
  find first buf_trn-doc no-lock
    where rowid(buf_trn-doc) = p-rowid
  no-error .
  if not available buf_trn-doc then do:
    assign
      p-transaction-type = ?
    .
    return.
  end.
  case buf_trn-doc.ext-doc-type :
    when 'ie':U  then do :
      assign
        p-transaction-type = 1
      .
    end.
    when 'iv':U     or
    when 'rv':U
    then do :
      run find-license in this-procedure ( input buf_trn-doc.cli-type
                                         , input buf_trn-doc.cli-code
                                         , output v-lic-series
                                         , output v-lic-number
                                         , output v-lic-addendum
                                         ) .
      assign
        p-transaction-type = if v-lic-series <> ? then 3 else 2
      .
    end.
    when 'ee':U
    then do:
      assign
        p-transaction-type = 13
      .
    end.
    when 'es':U
    then do :
      assign
        p-transaction-type = 7
      .
    end.
    when 're':U or
    when 'rs':U
    then do :
      assign
        p-transaction-type = 5
      .
    end.
    when 'ep':U then do :
      assign
        p-transaction-type = 10
      .
    end.
    when 'ev':U then do:
      run find-license in this-procedure ( input buf_trn-doc.cli-type
                                         , input buf_trn-doc.cli-code
                                         , output v-lic-series
                                         , output v-lic-number
                                         , output v-lic-addendum
                                         ) .
      assign
        p-transaction-type = if v-lic-series <> ? then 9 else 8
      .
    end.
    when 'we':U
    then do :
      assign
        p-transaction-type = 11
      .
    end.
    when 'vt':U then do:
      assign
        p-transaction-type = ( if p-qnty > 0 then 4 else 12 )
      .
    end.
    when 'vp':U or
    when 'im':U
    then do:
      assign
        p-transaction-type = ( if p-qnty > 0 then 6 else 13 )
      .
    end.
    otherwise do:
      message
        "Неизвестный тип операции о движении спиртосодержащей продукции!" skip
        buf_trn-doc.ext-doc-type
      view-as alert-box error.
    end.
  end.
end.
end procedure.
procedure fill-tt-rep :
do
on error undo, return error return-value
:
  define buffer buf_ot-line       for ub.ot-line.
  define buffer buf_trn-doc       for ub.trn-doc.
  define buffer buf_goods         for ub.goods.
  define buffer buf_doc-line-sum  for ub.doc-line-sum.
  define variable var-x-sum-type      like ub.stk-tot.sum-type  no-undo .
  define variable v-host-code         like ub.clients.host-code no-undo .
  define variable v-lic-series            as character no-undo .
  define variable v-lic-number            as character no-undo .
  define variable v-lic-addendum          as character no-undo .
  define variable v-transaction-date      as date      no-undo .
  define variable v-transaction-type      as integer   no-undo .
  define variable v-doc-date              as date      no-undo .
  define variable v-supplier-id           as integer   no-undo .
  define variable v-gds-egais-code        as decimal   no-undo .
  define variable v-quantity              as decimal   no-undo .
  define variable v-is-quantity-discrete  as logical   no-undo .
  define variable v-counter               as integer   no-undo .
  define variable v-repfrm-str            as character no-undo .
  run find-alc-goods in this-procedure .
assign v-account = ( if integer( 1 ) = 0 then 100 else integer( 1 ) ).
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
  _obj-list:
  for each obj-list :
    run find-license in this-procedure ( input obj-list.obj-type
                                       , input obj-list.obj-code
                                       , output v-lic-series
                                       , output v-lic-number
                                       , output v-lic-addendum
                                       ) .
    if v-lic-series = ? then do:
      message
        substitute( "Не найдена лицензия на объекте &1 &2 &3 &4за отчетный период с &5 по &6"
                  , obj-list.obj-type
                  , obj-list.obj-code
                  , obj-list.obj-name
                  , chr(10)
                  , v-begin-date
                  , v-end-date
                  )
      view-as alert-box information.
      next _obj-list.
    end.
    assign
      v-counter     = 0
      v-repfrm-str  = substitute( "Расчет по объекту &1 (&2 &3)"
                                , obj-list.obj-name
                                , obj-list.obj-type
                                , obj-list.obj-code
                                )
    .
IF ( v-counter modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(v-repfrm-str)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(v-repfrm-str)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              v-counter @ RecordsDone
              RecordsString   @ RecordsString
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
    _gds-line:
    for each tt-gds :
      run find-alc-egais-code in this-procedure ( input tt-gds.gds-code
                                                , output v-gds-egais-code
                                                ) .
      if v-gds-egais-code = ?
      then do :
        assign
          v-unbinded-goods = yes
        .
        run write-error in this-procedure ( substitute( "Не найден ЕГАИС код для товара &1 - &2. Товар не будет включен в отчет."
                                                      , tt-gds.artic
                                                      , tt-gds.gds-name
                                                      )
                                          ) .
        next _gds-line.
      end.
      _ot-line:
      for each buf_ot-line no-lock
            where buf_ot-line.obj-type    = obj-list.obj-type
              and buf_ot-line.obj-code    = obj-list.obj-code
              and buf_ot-line.artic       = tt-gds.artic
              and buf_ot-line.prod-type   = tt-gds.prod-type
              and buf_ot-line.prod-code   = tt-gds.prod-code
              and buf_ot-line.fact-order >= v-fact-order-start
              and buf_ot-line.fact-order <= v-fact-order-end
              and buf_ot-line.sum-type  = 'cost':U
      :
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_ot-line.doc-code
        no-error .
        if not available buf_trn-doc then do:
            message
              substitute( "Не могу найти документ &1" , buf_ot-line.doc-code )
            view-as alert-box error .
            next _ot-line.
        end.
        run get-transaction-type in this-procedure ( input  rowid(buf_trn-doc)
                                                   , input  buf_ot-line.fact-qnty
                                                   , output v-transaction-type
                                                   ) .
        find first tt-alc-report-head
          where tt-alc-report-head.obj-type         = obj-list.obj-type
            and tt-alc-report-head.obj-code         = obj-list.obj-code
            and tt-alc-report-head.doc-code         = buf_trn-doc.doc-code
            and tt-alc-report-head.transaction-type = v-transaction-type
        no-error .
        if not available tt-alc-report-head then do:
          if buf_ot-line.ext-doc-type = 'ie':U then do :
            run find-supp-egais-code in this-procedure ( input  buf_trn-doc.cli-type
                                                       , input  buf_trn-doc.cli-code
                                                       , output v-supplier-id
                                                       ) .
            if v-supplier-id = ? then do:
              assign
                v-unbinded-suppliers = yes
              .
              run write-error in this-procedure ( substitute( "Не найден ЕГАИС код для поставщика &1 &2. Строка исключена из отчета."
                                                            , buf_trn-doc.cli-type
                                                            , buf_trn-doc.cli-code
                                                            )
                                                ) .
              next _ot-line.
            end.
          end.
          else do:
            assign
              v-supplier-id = ?
            .
          end.
          assign
            v-transaction-date  = buf_trn-doc.fact-date
            v-doc-date          = buf_trn-doc.fact-date
          .
          create tt-alc-report-head.
          assign
            tt-alc-report-head.obj-type         = obj-list.obj-type
            tt-alc-report-head.obj-code         = obj-list.obj-code
            tt-alc-report-head.doc-code         = buf_trn-doc.doc-code
            tt-alc-report-head.lic-series       = v-lic-series
            tt-alc-report-head.lic-number       = v-lic-number
            tt-alc-report-head.lic-addendum     = v-lic-addendum
            tt-alc-report-head.transaction-date = v-transaction-date
            tt-alc-report-head.transaction-type = v-transaction-type
            tt-alc-report-head.doc-date         = v-doc-date
            tt-alc-report-head.supplier-id      = v-supplier-id
          .
        end.
        assign
          v-quantity             = abs( buf_ot-line.fact-qnty )
          v-is-quantity-discrete = yes
        .
        create tt-alc-report-line.
        assign
          tt-alc-report-line.doc-code             = buf_trn-doc.doc-code
          tt-alc-report-line.obj-type             = obj-list.obj-type
          tt-alc-report-line.obj-code             = obj-list.obj-code
          tt-alc-report-line.transaction-type     = v-transaction-type
          tt-alc-report-line.gds-code             = tt-gds.gds-code
          tt-alc-report-line.egais-gds-code       = v-gds-egais-code
          tt-alc-report-line.quantity             = v-quantity
          tt-alc-report-line.is-quantity-discrete = v-is-quantity-discrete
          tt-alc-report-line.doc-date             = v-doc-date
          tt-alc-report-line.doc-number           = buf_ot-line.doc-code
          v-counter                               = v-counter + 1
        .
        find first buf_doc-line-sum no-lock
          where buf_doc-line-sum.doc-code = buf_trn-doc.doc-code
            and buf_doc-line-sum.gds-code = tt-gds.gds-code
            and buf_doc-line-sum.sum-type = 'wst':U
        no-error .
        if available buf_doc-line-sum
        then do:
          if buf_doc-line-sum.fact-qnty > 0
          then do:
            assign
              v-transaction-type = 11
            .
            find first tt-alc-report-head
              where tt-alc-report-head.obj-type         = obj-list.obj-type
                and tt-alc-report-head.obj-code         = obj-list.obj-code
                and tt-alc-report-head.doc-code         = buf_trn-doc.doc-code
                and tt-alc-report-head.transaction-type = v-transaction-type
            no-error .
            if not available tt-alc-report-head then do:
              if buf_ot-line.ext-doc-type = 'ie':U then do :
                run find-supp-egais-code in this-procedure ( input  buf_trn-doc.cli-type
                                                           , input  buf_trn-doc.cli-code
                                                           , output v-supplier-id
                                                           ) .
                if v-supplier-id = ? then do:
                  assign
                    v-unbinded-suppliers = yes
                  .
                  run write-error in this-procedure ( substitute( "Не найден ЕГАИС код для поставщика &1 &2. Строка исключена из отчета."
                                                                , buf_trn-doc.cli-type
                                                                , buf_trn-doc.cli-code
                                                                )
                                                    ) .
                  next _ot-line.
                end.
              end.
              else do:
                assign
                  v-supplier-id = ?
                .
              end.
              assign
                v-transaction-date  = buf_trn-doc.fact-date
                v-doc-date          = buf_trn-doc.fact-date
              .
              create tt-alc-report-head.
              assign
                tt-alc-report-head.obj-type         = obj-list.obj-type
                tt-alc-report-head.obj-code         = obj-list.obj-code
                tt-alc-report-head.doc-code         = buf_trn-doc.doc-code
                tt-alc-report-head.lic-series       = v-lic-series
                tt-alc-report-head.lic-number       = v-lic-number
                tt-alc-report-head.lic-addendum     = v-lic-addendum
                tt-alc-report-head.transaction-date = v-transaction-date
                tt-alc-report-head.transaction-type = v-transaction-type
                tt-alc-report-head.doc-date         = v-doc-date
                tt-alc-report-head.supplier-id      = v-supplier-id
              .
            end.
            create tt-alc-report-line.
            assign
              tt-alc-report-line.doc-code             = buf_trn-doc.doc-code
              tt-alc-report-line.obj-type             = obj-list.obj-type
              tt-alc-report-line.obj-code             = obj-list.obj-code
              tt-alc-report-line.transaction-type     = v-transaction-type
              tt-alc-report-line.gds-code             = tt-gds.gds-code
              tt-alc-report-line.egais-gds-code       = v-gds-egais-code
              tt-alc-report-line.quantity             = buf_doc-line-sum.fact-qnty
              tt-alc-report-line.is-quantity-discrete = v-is-quantity-discrete
              tt-alc-report-line.doc-date             = v-doc-date
              tt-alc-report-line.doc-number           = buf_ot-line.doc-code
            .
          end.
        end.
IF ( v-counter modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(v-repfrm-str)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(v-repfrm-str)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              v-counter @ RecordsDone
              RecordsString   @ RecordsString
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
      end.
      _wast-ot-line:
      for each buf_ot-line no-lock
            where buf_ot-line.obj-type    = obj-list.obj-type
              and buf_ot-line.obj-code    = obj-list.obj-code
              and buf_ot-line.artic       = tt-gds.artic
              and buf_ot-line.prod-type   = tt-gds.prod-type
              and buf_ot-line.prod-code   = tt-gds.prod-code
              and buf_ot-line.fact-order >= v-fact-order-start
              and buf_ot-line.fact-order <= v-fact-order-end
              and buf_ot-line.sum-type  = 'crsa':U
      :
        if buf_ot-line.sum-base <> 0
        then do:
          next _wast-ot-line.
        end.
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_ot-line.doc-code
        no-error .
        if not available buf_trn-doc then do:
            message
              substitute( "Не могу найти документ &1" , buf_ot-line.doc-code )
            view-as alert-box error .
            next _wast-ot-line.
        end.
        find first buf_doc-line-sum no-lock
          where buf_doc-line-sum.doc-code = buf_trn-doc.doc-code
            and buf_doc-line-sum.gds-code = tt-gds.gds-code
            and buf_doc-line-sum.sum-type = 'wst':U
        no-error .
        if available buf_doc-line-sum
        then do:
          if buf_doc-line-sum.fact-qnty > 0
          then do:
            assign
              v-transaction-type = 11
            .
            find first tt-alc-report-head
              where tt-alc-report-head.obj-type         = obj-list.obj-type
                and tt-alc-report-head.obj-code         = obj-list.obj-code
                and tt-alc-report-head.doc-code         = buf_trn-doc.doc-code
                and tt-alc-report-head.transaction-type = v-transaction-type
            no-error .
            if not available tt-alc-report-head then do:
              if buf_ot-line.ext-doc-type = 'ie':U then do :
                run find-supp-egais-code in this-procedure ( input  buf_trn-doc.cli-type
                                                           , input  buf_trn-doc.cli-code
                                                           , output v-supplier-id
                                                           ) .
                if v-supplier-id = ? then do:
                  assign
                    v-unbinded-suppliers = yes
                  .
                  run write-error in this-procedure ( substitute( "Не найден ЕГАИС код для поставщика &1 &2. Строка исключена из отчета."
                                                                , buf_trn-doc.cli-type
                                                                , buf_trn-doc.cli-code
                                                                )
                                                    ) .
                  next _wast-ot-line.
                end.
              end.
              else do:
                assign
                  v-supplier-id = ?
                .
              end.
              assign
                v-transaction-date  = buf_trn-doc.fact-date
                v-doc-date          = buf_trn-doc.fact-date
              .
              create tt-alc-report-head.
              assign
                tt-alc-report-head.obj-type         = obj-list.obj-type
                tt-alc-report-head.obj-code         = obj-list.obj-code
                tt-alc-report-head.doc-code         = buf_trn-doc.doc-code
                tt-alc-report-head.lic-series       = v-lic-series
                tt-alc-report-head.lic-number       = v-lic-number
                tt-alc-report-head.lic-addendum     = v-lic-addendum
                tt-alc-report-head.transaction-date = v-transaction-date
                tt-alc-report-head.transaction-type = v-transaction-type
                tt-alc-report-head.doc-date         = v-doc-date
                tt-alc-report-head.supplier-id      = v-supplier-id
              .
            end.
            create tt-alc-report-line.
            assign
              tt-alc-report-line.doc-code             = buf_trn-doc.doc-code
              tt-alc-report-line.obj-type             = obj-list.obj-type
              tt-alc-report-line.obj-code             = obj-list.obj-code
              tt-alc-report-line.transaction-type     = v-transaction-type
              tt-alc-report-line.gds-code             = tt-gds.gds-code
              tt-alc-report-line.egais-gds-code       = v-gds-egais-code
              tt-alc-report-line.quantity             = buf_doc-line-sum.fact-qnty
              tt-alc-report-line.is-quantity-discrete = v-is-quantity-discrete
              tt-alc-report-line.doc-date             = v-doc-date
              tt-alc-report-line.doc-number           = buf_ot-line.doc-code
            .
          end.
        end.
      end.
    end.
  end.
end.
end procedure.
procedure write-xml-files :
  define variable v-file-counter  as integer   no-undo .
  define variable v-file-name     as character no-undo .
  define variable v-sch-file      as character no-undo .
do
on error undo, return error return-value
:
  for each tt-alc-report-head :
    assign
      v-file-counter = v-file-counter + 1
      v-file-name    = v-dir-name + string( v-file-counter , "99999999" )  + ".xml":U
      v-sch-file     = search( v-file-name ) .
    .
    if v-sch-file <> ? then do:
      message
        substitute( "В директории &1 уже есть файл с именем &2.&3Отчет не может быть сформирован.&3Переместите или удалите все файлы с расширением XML из указаной директории."
                  , v-dir-name
                  , v-file-name
                  , chr(10)
                  )
      view-as alert-box error.
      return error .
    end.
    create tt-xml-file.
    assign
      tt-xml-file.file-id   = v-file-counter
      tt-xml-file.file-name = v-file-name
    .
    output stream xml-out to value(v-file-name) convert target "utf-8".
      put stream xml-out unformatted "<?xml version='1.0' encoding='UTF-8'?>":U skip.
      put stream xml-out unformatted '<Transactions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="mosdecl-primary-document-v.1.0.xsd">':U skip.
      put stream xml-out unformatted "<SingleTransaction>":U skip.
        put stream xml-out unformatted substitute( "&1<TransactionHeader>":U , CHR(9) )skip.
            put stream xml-out unformatted substitute( "&1<TransactionLicense>":U , fill( CHR(9) , 2) )  skip.
            put stream xml-out unformatted substitute( "&1<LicSeries>&2</LicSeries>":U , fill( CHR(9) , 3) ,tt-alc-report-head.lic-series ) skip.
            put stream xml-out unformatted substitute( "&1<LicNumber>&2</LicNumber>":U , fill( CHR(9) , 3) ,tt-alc-report-head.lic-number ) skip.
            put stream xml-out unformatted substitute( "&1<LicAddendum>&2</LicAddendum>":U , fill( CHR(9) , 3) ,tt-alc-report-head.lic-addendum ) skip.
          put stream xml-out unformatted substitute( "&1</TransactionLicense>":U , fill( CHR(9) , 2) ) skip.
          put stream xml-out unformatted substitute( "&1<TransactionType>&2</TransactionType>" , fill( CHR(9) , 2) ,tt-alc-report-head.transaction-type ) skip.
          put stream xml-out unformatted substitute( "&1<TransactionDocument>":U , fill( CHR(9) , 2) ) skip.
            put stream xml-out unformatted substitute( "&1<DocDate>&2</DocDate>" , fill( CHR(9) , 3) , get-date-str( tt-alc-report-head.doc-date ) ) skip.
            put stream xml-out unformatted substitute( "&1<DocNumber>&2</DocNumber>" , fill( CHR(9) , 3) , tt-alc-report-head.doc-code ) skip.
          put stream xml-out unformatted substitute( "&1</TransactionDocument>":U , fill( CHR(9) , 2) ) skip.
          if tt-alc-report-head.supplier-id <> ? then do:
            put stream xml-out unformatted substitute( "&1<SupplierID>&2</SupplierID>" , fill( CHR(9) , 2) , tt-alc-report-head.supplier-id ) skip.
          end.
        put stream xml-out unformatted substitute( "&1</TransactionHeader>":U , CHR(9) )skip.
      for each tt-alc-report-line
        where tt-alc-report-line.obj-type         = tt-alc-report-head.obj-type
          and tt-alc-report-line.obj-code         = tt-alc-report-head.obj-code
          and tt-alc-report-line.doc-code         = tt-alc-report-head.doc-code
          and tt-alc-report-line.transaction-type = tt-alc-report-head.transaction-type
      :
        put stream xml-out unformatted substitute( "&1<TransactionLines>":U , CHR(9) ) skip.
          put stream xml-out unformatted substitute( "&1<ItemId>&2</ItemId>" , fill( CHR(9) , 2) , tt-alc-report-line.egais-gds-code ) skip.
          put stream xml-out unformatted substitute( "&1<Quantity>&2</Quantity>" , fill( CHR(9) , 2) , tt-alc-report-line.quantity ) skip.
          put stream xml-out unformatted substitute( "&1<IsQuantityDiscrete>&2</IsQuantityDiscrete>" , fill( CHR(9) , 2) , tt-alc-report-line.is-quantity-discrete ) skip.
        put stream xml-out unformatted substitute( "&1</TransactionLines>":U , CHR(9) ) skip.
      end.
      put stream xml-out unformatted "</SingleTransaction>":U skip.
      put stream xml-out unformatted "</Transactions>":U .
    output stream xml-out close.
  end.
end.
end procedure.
procedure pack-xml-files :
  define variable v-arc             as character no-undo .
  define variable v-txt             as character no-undo .
  define variable v-list-file-name  as character no-undo .
  define variable v-arc-file-name   as character no-undo .
do
on error undo, return error return-value
:
  assign
    v-arc-file-name = v-dir-name + "report.zip":U
  .
  if search( "exe/7za.exe" ) = ? then do:
    return error("Не найдена программа 7za.exe, невозможно упаковать файлы в архив.").
  end.
  v-arc = search( "exe/7za.exe" ).
  if search( v-arc-file-name ) <> ? then do:
    return error substitute ( "Файл &1 уже существует. Создание архива невозможно." , v-arc-file-name ).
  end.
  run gbl/_tmpfile.p ( "lst":u , ".txt":u , output v-list-file-name ).
  output stream lst-out to value(v-list-file-name).
  for each tt-xml-file :
    put stream lst-out unformatted tt-xml-file.file-name skip.
  end.
  output stream lst-out close.
  assign
    v-txt = substitute( "&1 a -tzip &2 @&3"
                      , v-arc
                      , v-arc-file-name
                      , v-list-file-name
                      )
  .
  os-command silent value ( v-txt ) .
  os-delete value( v-list-file-name ) .
  for each tt-xml-file :
     os-delete value( tt-xml-file.file-name ) .
  end.
end.
end procedure.
procedure write-error :
  define input  parameter p-err-message as character no-undo .
do
on error undo, return error return-value
:
  output stream serr to "alcdcl01.err" append.
  put stream serr unformatted substitute("[&1 &2] : &3"
                                        , today
                                        , string( time , "hh:mm:ss")
                                        , p-err-message
                                        ) skip(1).
  output stream serr close.
end.
end procedure.
function get-date-str return character (input p-date as date) .
  return substitute( "&1-&2-&3"
                   , year( p-date)
                   , month( p-date)
                   , day( p-date )
                   ).
end.
