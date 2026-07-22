block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: alcdcl04.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/alcdcl04.p $":U .
define variable vss-description as character no-undo init "Декларация об объемах розничной продажи алкогольной продукции (Псков)".
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
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
define variable var-report-r-b as character no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure ost-line :
  define input  parameter x-store-code like ub.clients.obj-code    no-undo .
  define input  parameter x-store-type like ub.clients.obj-type    no-undo .
  define input  parameter x-artic      like ub.stk-line.artic      no-undo .
  define input  parameter x-prod-code  like ub.stk-line.prod-code  no-undo .
  define input  parameter x-prod-type  like ub.stk-line.prod-type  no-undo .
  define input  parameter x-tog-shift  as logical no-undo .
  define input  parameter x-fact-order like ub.stk-line.fact-order no-undo .
  define input  parameter x-sum-type   like ub.stk-line.sum-type   no-undo .
  define input  parameter x-cat-id     like ub.stk-line.cat-id     no-undo .
  define input  parameter xtog-obj     as logical no-undo .
  define output parameter quantity     like ub.stk-line.fact-qnty  no-undo .
  define output parameter coast_r      like ub.stk-line.sum-rubl   no-undo .
  define output parameter coast_v      like ub.stk-line.sum-rubl   no-undo .
  define output parameter vat_r        like ub.stk-line.sum-rubl   no-undo .
  define output parameter vat_v        like ub.stk-line.sum-rubl   no-undo .
  define output parameter slt_r        like ub.stk-line.sum-rubl   no-undo .
  define output parameter slt_v        like ub.stk-line.sum-rubl   no-undo .
  define buffer buff-obj-list  for obj-list .
  define buffer buff-stk-line  for ub.stk-line .
  assign
    Quantity = 0
    Coast_R  = 0
    Coast_V  = 0
    VAT_R    = 0
    VAT_V    = 0
    SLT_R    = 0
    SLT_V    = 0
  .
  if  x-tog-shift = false then do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  = 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
        .
      end.
    end.
  end.
  else do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  > 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
        .
      end.
    end.
  end.
end procedure.
procedure ost-lineother-tax :
  define input  parameter x-store-code like ub.clients.obj-code      no-undo.
  define input  parameter x-store-type like ub.clients.obj-type      no-undo.
  define input  parameter x-artic      like ub.stk-line.artic        no-undo.
  define input  parameter x-prod-code  like ub.stk-line.prod-code    no-undo.
  define input  parameter x-prod-type  like ub.stk-line.prod-type    no-undo.
  define input  parameter x-tog-shift  as logical no-undo .
  define input  parameter x-fact-order like ub.stk-line.fact-order   no-undo.
  define input  parameter x-sum-type   like ub.stk-line.sum-type     no-undo.
  define input  parameter x-type-id    like ub.stk-line.cat-id       no-undo.
  define input  parameter xTog-obj     as logical no-undo .
  define output parameter Quantity     like ub.stk-line.fact-qnty   no-undo.
  define output parameter Coast_R      like ub.stk-line.sum-rubl    no-undo.
  define output parameter Coast_V      like ub.stk-line.sum-rubl    no-undo.
  define output parameter VAT_R        like ub.stk-line.sum-rubl    no-undo.
  define output parameter VAT_V        like ub.stk-line.sum-rubl    no-undo.
  define output parameter SLT_R        like ub.stk-line.sum-rubl    no-undo.
  define output parameter SLT_V        like ub.stk-line.sum-rubl    no-undo.
  define output parameter other_R      like ub.stk-line.sum-rubl    no-undo.
  define output parameter other_V      like ub.stk-line.sum-rubl    no-undo.
  define buffer buff-obj-list  for obj-list .
  define buffer buff-stk-line  for ub.stk-line .
  assign
    Quantity = 0
    Coast_R  = 0
    Coast_V  = 0
    VAT_R    = 0
    VAT_V    = 0
    SLT_R    = 0
    SLT_V    = 0
    other_R  = 0
    other_V  = 0
  .
  if  x-tog-shift = false then do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  = 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
          other_R  = other_R  +  buff-stk-line.other-rubl
          other_V  = other_V  +  buff-stk-line.other-base
        .
      end.
    end.
  end.
  else do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  > 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
          other_R = other_R   +  buff-stk-line.other-rubl
          other_V = other_V   +  buff-stk-line.other-base
        .
      end.
    end.
  end.
end procedure.
procedure ost-line-kg :
  define  input parameter p-obj-code    like ub.stk-line.obj-code   no-undo .
  define  input parameter p-obj-type    like ub.stk-line.obj-type   no-undo .
  define  input parameter p-artic       like ub.stk-line.artic      no-undo .
  define  input parameter p-prod-code   like ub.stk-line.prod-code  no-undo .
  define  input parameter p-prod-type   like ub.stk-line.prod-type  no-undo .
  define  input parameter p-fact-order  like ub.stk-line.fact-order no-undo .
  define output parameter p-quantity-kg like ub.stk-line.fact-qnty  no-undo initial 0.00 .
  define buffer buff-obj-list  for obj-list .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_inv-line for ub.inv-line .
  do
  on error undo, return error
  :
    for each buf_doc-line no-lock where
             buf_doc-line.obj-type    = p-obj-type   and
             buf_doc-line.obj-code    = p-obj-code   and
             buf_doc-line.prod-type   = p-prod-type  and
             buf_doc-line.prod-code   = p-prod-code  and
             buf_doc-line.artic       = p-artic      and
             buf_doc-line.status_     = 'факт':U      and
             buf_doc-line.fact-order <= p-fact-order
          by buf_doc-line.fact-order    descending
    :
      find first buf_inv-line no-lock where
                 buf_inv-line.doc-code  = buf_doc-line.doc-code  and
                 buf_inv-line.artic     = buf_doc-line.artic     and
                 buf_inv-line.prod-type = buf_doc-line.prod-type and
                 buf_inv-line.prod-code = buf_doc-line.prod-code no-error .
      if available buf_inv-line
      then do:
        if buf_inv-line.after-cli-qnty <> ?
        then do:
          assign
            p-quantity-kg = buf_inv-line.after-cli-qnty
          .
          leave .
        end.
      end.
    end.
    if p-quantity-kg = ?
    then do:
      assign
        p-quantity-kg = 0
      .
    end.
  end.
end procedure.
def var vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define temp-table tt-allsum-line      no-undo
field sum-type           as   character
field fact-qnty          like ub.doc-line.fact-qnty
field cli-qnty           like ub.doc-line.cli-qnty
field sum-dsc-base-doc   like ub.doc-line.price-base
field sum-dsc-rubl-doc   like ub.doc-line.price-base
field dsc-base-doc       like ub.doc-line.price-base
field dsc-rubl-doc       like ub.doc-line.price-base
field vat-base-doc       like ub.doc-line.price-base
field vat-rubl-doc       like ub.doc-line.price-base
field vat-base-buyer-doc like ub.doc-line.price-base
field vat-rubl-buyer-doc like ub.doc-line.price-base
field slt-base-doc       like ub.doc-line.price-base
field slt-rubl-doc       like ub.doc-line.price-base
field road-tax-base-doc  like ub.doc-line.price-base
field road-tax-rubl-doc  like ub.doc-line.price-base
field excise-base-doc    like ub.doc-line.price-base
field excise-rubl-doc    like ub.doc-line.price-base
field sum-dsc-base-acc   like ub.doc-line.price-base
field sum-dsc-rubl-acc   like ub.doc-line.price-base
field sum-dsc-cli-acc    like ub.doc-line.price-cli
field dsc-base-acc       like ub.doc-line.price-base
field dsc-rubl-acc       like ub.doc-line.price-base
field dsc-cli-acc        like ub.doc-line.price-cli
field vat-base-acc       like ub.doc-line.price-base
field vat-rubl-acc       like ub.doc-line.price-base
field vat-cli-acc        like ub.doc-line.price-cli
field slt-base-acc       like ub.doc-line.price-base
field slt-rubl-acc       like ub.doc-line.price-base
field slt-cli-acc        like ub.doc-line.price-cli
field road-tax-base-acc  like ub.doc-line.price-base
field road-tax-rubl-acc  like ub.doc-line.price-base
field road-tax-cli-acc   like ub.doc-line.price-cli
field excise-base-acc    like ub.doc-line.price-base
field excise-rubl-acc    like ub.doc-line.price-base
field excise-cli-acc     like ub.doc-line.price-cli
field transport-base-acc like ub.doc-line.price-base
field transport-rubl-acc like ub.doc-line.price-base
field transport-cli-acc  like ub.doc-line.price-cli
field other-base-acc     like ub.doc-line.price-base
field other-rubl-acc     like ub.doc-line.price-base
field other-cli-acc      like ub.doc-line.price-cli
field sum-dsc-base-cur   like ub.doc-line.price-base
field sum-dsc-rubl-cur   like ub.doc-line.price-base
field dsc-base-cur       like ub.doc-line.price-base
field dsc-rubl-cur       like ub.doc-line.price-base
field vat-base-cur       like ub.doc-line.price-base
field vat-rubl-cur       like ub.doc-line.price-base
field vat-base-buyer-cur like ub.doc-line.price-base
field vat-rubl-buyer-cur like ub.doc-line.price-base
field slt-base-cur       like ub.doc-line.price-base
field slt-rubl-cur       like ub.doc-line.price-base
field road-tax-base-cur  like ub.doc-line.price-base
field road-tax-rubl-cur  like ub.doc-line.price-base
field excise-base-cur    like ub.doc-line.price-base
field excise-rubl-cur    like ub.doc-line.price-base
index sum-type is primary unique sum-type.
.
define temp-table tt-allsum no-undo
field sum-type           as   character
field fact-qnty             as decimal
field cli-qnty              as decimal
field sum-dsc-base-doc      as decimal
field sum-dsc-rubl-doc      as decimal
field dsc-base-doc          as decimal
field dsc-rubl-doc          as decimal
field vat-base-doc          as decimal
field vat-rubl-doc          as decimal
field vat-base-buyer-doc    as decimal
field vat-rubl-buyer-doc    as decimal
field slt-base-doc          as decimal
field slt-rubl-doc          as decimal
field road-tax-base-doc     as decimal
field road-tax-rubl-doc     as decimal
field excise-base-doc       as decimal
field excise-rubl-doc       as decimal
field sum-dsc-base-acc      as decimal
field sum-dsc-rubl-acc      as decimal
field sum-dsc-cli-acc       as decimal
field dsc-base-acc          as decimal
field dsc-rubl-acc          as decimal
field dsc-cli-acc           as decimal
field vat-base-acc          as decimal
field vat-rubl-acc          as decimal
field vat-cli-acc           as decimal
field slt-base-acc          as decimal
field slt-rubl-acc          as decimal
field slt-cli-acc           as decimal
field road-tax-base-acc     as decimal
field road-tax-rubl-acc     as decimal
field road-tax-cli-acc      as decimal
field excise-base-acc       as decimal
field excise-rubl-acc       as decimal
field excise-cli-acc        as decimal
field transport-base-acc    as decimal
field transport-rubl-acc    as decimal
field transport-cli-acc     as decimal
field other-base-acc        as decimal
field other-rubl-acc        as decimal
field other-cli-acc         as decimal
field sum-dsc-base-cur      as decimal
field sum-dsc-rubl-cur      as decimal
field dsc-base-cur          as decimal
field dsc-rubl-cur          as decimal
field vat-base-cur          as decimal
field vat-rubl-cur          as decimal
field vat-base-buyer-cur    as decimal
field vat-rubl-buyer-cur    as decimal
field slt-base-cur          as decimal
field slt-rubl-cur          as decimal
field road-tax-base-cur     as decimal
field road-tax-rubl-cur     as decimal
field excise-base-cur       as decimal
field excise-rubl-cur       as decimal
index sum-type is primary unique sum-type.
define temp-table tt-clcparts no-undo like ub.parts
field part-cur-base like ub.gds-dtl.price-base
field part-cur-road-tax like ub.gds-dtl.price-base
field part-cur-excise like ub.gds-dtl.price-base
.
define variable v-calcbypart as log no-undo.
procedure clcprtsl_calc-parts :
define input parameter parrec-parts        as   recid                   no-undo.
define input parameter paris-doc           as   logical                 no-undo.
define input parameter paris-cur           as   logical                 no-undo.
define input parameter parroad-tax         like ub.doc-line.road-tax    no-undo.
define input parameter parexcise           like ub.doc-line.excise      no-undo.
define input parameter parvat-pc           like ub.doc-line.vat-pc      no-undo.
define input parameter parcons-vat-pc      like ub.doc-line.cons-vat-pc no-undo.
define input parameter parslt-pc           like ub.doc-line.slt-pc      no-undo.
define input parameter parbase-rate        like ub.trn-doc.base-rate    no-undo.
define input parameter parbase-scale       like ub.trn-doc.base-scale   no-undo.
define input parameter parr-b              as   character               no-undo.
define input parameter parcur-base         like ub.gds-dtl.cur-base     no-undo.
define input parameter parcurroad-tax      like ub.doc-line.road-tax    no-undo.
define input parameter parcurexcise        like ub.doc-line.excise      no-undo.
define input parameter parcurvat-pc        like ub.doc-line.vat-pc      no-undo.
define input parameter parcurcons-vat-pc   like ub.doc-line.cons-vat-pc no-undo.
define input parameter parcurslt-pc        like ub.doc-line.slt-pc      no-undo.
define variable parartic        like ub.parts.artic         no-undo.
define variable parprod-type    like ub.parts.prod-type     no-undo.
define variable parprod-code    like ub.parts.prod-code     no-undo.
define variable pardoc-type     like ub.parts.doc-type      no-undo.
define variable pardoc-code     like ub.parts.out-code      no-undo.
define variable parobj-type     like ub.parts.obj-type      no-undo.
define variable parobj-code     like ub.parts.obj-code      no-undo.
define variable parprice-base   like ub.gds-dtl.price-base  no-undo.
define variable parprice-rubl   like ub.gds-dtl.price-rubl  no-undo.
define variable pardiscnt-base  like ub.gds-dtl.discnt-base no-undo.
define variable pardiscnt-rubl  like ub.gds-dtl.discnt-rubl no-undo.
define variable parfact-qnty    like ub.parts.fact-qnty     no-undo.
define variable parcli-qnty     like ub.parts.cli-qnty      no-undo.
define variable pardoc-qnty     like ub.parts.qnty          no-undo.
define variable parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define variable parcurartic        like ub.parts.artic         no-undo.
define variable parcurprod-type    like ub.parts.prod-type     no-undo.
define variable parcurprod-code    like ub.parts.prod-code     no-undo.
define variable parcurdoc-type     like ub.parts.doc-type      no-undo.
define variable parcurdoc-code     like ub.parts.out-code      no-undo.
define variable parcurobj-type     like ub.parts.obj-type      no-undo.
define variable parcurobj-code     like ub.parts.obj-code      no-undo.
define variable parcurprice-base   like ub.gds-dtl.price-base  no-undo.
define variable parcurprice-rubl   like ub.gds-dtl.price-rubl  no-undo.
define variable parcurdiscnt-base  like ub.gds-dtl.discnt-base no-undo.
define variable parcurdiscnt-rubl  like ub.gds-dtl.discnt-rubl no-undo.
define variable parcurfact-qnty    like ub.parts.fact-qnty     no-undo.
define variable parcurcli-qnty     like ub.parts.cli-qnty      no-undo.
define variable parcurdoc-qnty     like ub.parts.qnty          no-undo.
define variable parcurbase-rate    like ub.trn-doc.base-rate   no-undo.
define variable parcurbase-scale   like ub.trn-doc.base-scale  no-undo.
define variable parcurext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define buffer bf_tt-allsum     for tt-allsum.
define buffer bfs_tt-allsum    for tt-allsum.
define buffer bfpc_tt-allsum   for tt-allsum.
define buffer bfspc_tt-allsum  for tt-allsum.
define buffer bfacc_tt-allsum  for tt-allsum.
define buffer bfsacc_tt-allsum for tt-allsum.
define buffer cl_tt-clcparts   for tt-clcparts.
define buffer bf_trn-doc       for ub.trn-doc.
define buffer bf_sysconf       for ub.sysconf.
    define buffer   in-vatp-trn-doccl  for ub.trn-doc .
    define buffer   in-vatp-partscl    for ub.parts   .
    define buffer   in-vatp-doccl      for ub.trn-doc .
    define buffer   in-vatp-goodscl    for ub.goods   .
    define buffer   in-vatp-sysconfcl  for ub.sysconf .
    define buffer   in-vatp_doc-attrcl for ub.doc-attr.
    define variable in-vatp-have-vat-sltcl       as   logical initial yes    no-undo.
    define variable vat-pc-loccl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbcl                  as   character              no-undo.
    define variable slt-pc-loccl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-ratecl              as   decimal                no-undo.
    define variable price-rubl-with-tax-loccl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loccl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loccl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loccl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loccl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loccl  like ub.doc-line.price-base no-undo.
    define variable vat-base-loccl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loccl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loccl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loccl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loccl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loccl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loccl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loccl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loccl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loccl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loccl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loccl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loccl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loccl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loccl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loccl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdcl             as   character              no-undo.
    define variable varinvatp-typecl             as   character              no-undo.
    define  variable price-rubl-with-tax-salecl    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-salecl    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-salecl like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-salecl like ub.doc-line.price-base no-undo.
    define  variable vat-base-salecl               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-salecl               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyercl              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyercl              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-salecl               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-salecl               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-salecl          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-salecl          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-salecl            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-salecl            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-salecl            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-salecl            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlcl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlcl for ub.gds-dtl.
    define buffer out-vatp_partscl       for ub.parts.
    define buffer out-vatp_sysconfcl     for ub.sysconf.
    define buffer out-vatp_doc-linecl    for ub.doc-line.
    define buffer out-vatp_goodscl       for ub.goods.
    define buffer out-vatp_trn-doccl     for ub.trn-doc.
    define buffer out-vatp_doc-attrcl    for ub.doc-attr.
    define variable varprice-base-conscl      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-conscl      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typecl         as   character                           no-undo.
    define variable varfrm-cnsvcl              as   character                           no-undo.
    define variable varroot-nodecl             as   integer                             no-undo.
    define variable varempty-scalecl           as   logical                             no-undo.
    define variable varis-cons-parts-havecl    as   logical                             no-undo.
    define variable varsum-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpcl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpcl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpcl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpcl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntycl             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntycl             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlcl        as   logical                             no-undo.
    define variable varcurclprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurclprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurcldiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcldiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbcl               as   character                           no-undo.
    define variable out-vatp-have-vat-sltcl    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-dococl  for ub.trn-doc .
    define buffer   in-vatp-partsocl    for ub.parts   .
    define buffer   in-vatp-dococl      for ub.trn-doc .
    define buffer   in-vatp-goodsocl    for ub.goods   .
    define buffer   in-vatp-sysconfocl  for ub.sysconf .
    define buffer   in-vatp_doc-attrocl for ub.doc-attr.
    define variable in-vatp-have-vat-sltocl       as   logical initial yes    no-undo.
    define variable vat-pc-lococl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbocl                  as   character              no-undo.
    define variable slt-pc-lococl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateocl              as   decimal                no-undo.
    define variable price-rubl-with-tax-lococl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-lococl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-lococl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-lococl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-lococl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-lococl  like ub.doc-line.price-base no-undo.
    define variable vat-base-lococl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-lococl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-lococl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-lococl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-lococl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-lococl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-lococl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-lococl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-lococl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-lococl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-lococl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-lococl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-lococl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-lococl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-lococl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-lococl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdocl             as   character              no-undo.
    define variable varinvatp-typeocl             as   character              no-undo.
    define  variable price-rubl-with-tax-salecur    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-salecur    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-salecur like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-salecur like ub.doc-line.price-base no-undo.
    define  variable vat-base-salecur               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-salecur               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyercur              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyercur              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-salecur               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-salecur               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-salecur          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-salecur          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-salecur            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-salecur            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-salecur            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-salecur            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlcur     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlcur for ub.gds-dtl.
    define buffer out-vatp_partscur       for ub.parts.
    define buffer out-vatp_sysconfcur     for ub.sysconf.
    define buffer out-vatp_doc-linecur    for ub.doc-line.
    define buffer out-vatp_goodscur       for ub.goods.
    define buffer out-vatp_trn-doccur     for ub.trn-doc.
    define buffer out-vatp_doc-attrcur    for ub.doc-attr.
    define variable varprice-base-conscur      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-conscur      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typecur         as   character                           no-undo.
    define variable varfrm-cnsvcur              as   character                           no-undo.
    define variable varroot-nodecur             as   integer                             no-undo.
    define variable varempty-scalecur           as   logical                             no-undo.
    define variable varis-cons-parts-havecur    as   logical                             no-undo.
    define variable varsum-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpcur  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpcur   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpcur  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpcur   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntycur             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntycur             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlcur        as   logical                             no-undo.
    define variable varcurcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbcur               as   character                           no-undo.
    define variable out-vatp-have-vat-sltcur    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-dococur  for ub.trn-doc .
    define buffer   in-vatp-partsocur    for ub.parts   .
    define buffer   in-vatp-dococur      for ub.trn-doc .
    define buffer   in-vatp-goodsocur    for ub.goods   .
    define buffer   in-vatp-sysconfocur  for ub.sysconf .
    define buffer   in-vatp_doc-attrocur for ub.doc-attr.
    define variable in-vatp-have-vat-sltocur       as   logical initial yes    no-undo.
    define variable vat-pc-lococur                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbocur                  as   character              no-undo.
    define variable slt-pc-lococur                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateocur              as   decimal                no-undo.
    define variable price-rubl-with-tax-lococur    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-lococur    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-lococur     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-lococur like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-lococur like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-lococur  like ub.doc-line.price-base no-undo.
    define variable vat-base-lococur               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-lococur               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-lococur                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-lococur               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-lococur               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-lococur                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-lococur          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-lococur          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-lococur           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-lococur         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-lococur         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-lococur          like ub.doc-line.price-rubl no-undo.
    define variable other-base-lococur             like ub.doc-line.price-base no-undo.
    define variable other-rubl-lococur             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-lococur              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-lococur          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdocur             as   character              no-undo.
    define variable varinvatp-typeocur             as   character              no-undo.
do on error undo, return error return-value :
find first cl_tt-clcparts where recid(cl_tt-clcparts) = parrec-parts no-lock.
for each bf_tt-allsum on error undo, return error return-value :
  delete bf_tt-allsum.
end.
assign
  price-rubl-with-tax-loccl = cl_tt-clcparts.price-rubl
  price-base-with-tax-loccl = cl_tt-clcparts.price-base
.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbcl
  )  .
  if cl_tt-clcparts.out-code = 'free-zone':U     or
     cl_tt-clcparts.out-code = 'out-zone':U   or
     cl_tt-clcparts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltcl = yes.
  end.
  else do:
    find first in-vatp_doc-attrcl no-lock
      where in-vatp_doc-attrcl.doc-code  = cl_tt-clcparts.out-code
        and in-vatp_doc-attrcl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrcl then do:
      assign
        in-vatp-have-vat-sltcl = yes.
    end.
    else do:
         in-vatp-have-vat-sltcl = no.
    end.
  end.
  assign
   price-cli-with-tax-loccl = cl_tt-clcparts.price-cli
   cli-base-ratecl          = cl_tt-clcparts.cli-base-rate.
  ASSIGN   road-tax-base-loccl  = (if cl_tt-clcparts.road-tax-base  = ? then 0 else cl_tt-clcparts.road-tax-base)
           road-tax-rubl-loccl  = (if cl_tt-clcparts.road-tax-rubl  = ? then 0 else cl_tt-clcparts.road-tax-rubl).
  ASSIGN  transport-base-loccl = (if cl_tt-clcparts.transport-base = ? then 0 else cl_tt-clcparts.transport-base)
          transport-rubl-loccl = (if cl_tt-clcparts.transport-rubl = ? then 0 else cl_tt-clcparts.transport-rubl)
          other-base-loccl     = (if cl_tt-clcparts.other-base     = ? then 0 else cl_tt-clcparts.other-base)
          other-rubl-loccl     = (if cl_tt-clcparts.other-rubl     = ? then 0 else cl_tt-clcparts.other-rubl)
          vat-pc-loccl         = (if cl_tt-clcparts.vat-pc         = ? then 0 else cl_tt-clcparts.vat-pc)
          slt-pc-loccl         = (if cl_tt-clcparts.slt-pc         = ? then 0 else cl_tt-clcparts.slt-pc).
          ASSIGN   slt-base-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-base-with-tax-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl)))                           * slt-pc-loccl / (100 + slt-pc-loccl))                        vat-base-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-base-with-tax-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl))) * (1 - slt-pc-loccl / (100 + slt-pc-loccl)) * vat-pc-loccl / (100 + vat-pc-loccl)).
    ASSIGN   slt-rubl-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-rubl-with-tax-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl)))                           * slt-pc-loccl / (100 + slt-pc-loccl))                        vat-rubl-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-rubl-with-tax-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl))) * (1 - slt-pc-loccl / (100 + slt-pc-loccl)) * vat-pc-loccl / (100 + vat-pc-loccl)).
  assign
    exch-rate-cli-loccl = (cl_tt-clcparts.price-rubl - transport-rubl-loccl - other-rubl-loccl - road-tax-rubl-loccl - (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-rubl-loccl else 0) - (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-rubl-loccl else 0)) / cl_tt-clcparts.price-cli .
  assign
    slt-cli-loccl        = slt-rubl-loccl       / exch-rate-cli-loccl
    vat-cli-loccl        = vat-rubl-loccl       / exch-rate-cli-loccl
    road-tax-cli-loccl   = road-tax-rubl-loccl  / exch-rate-cli-loccl
    transport-cli-loccl  = 0
    other-cli-loccl      = 0
  .
ASSIGN
          price-base-without-tax-loccl = price-base-with-tax-loccl - vat-base-loccl - slt-base-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl))
    price-rubl-without-tax-loccl = price-rubl-with-tax-loccl - vat-rubl-loccl - slt-rubl-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl))
.
if paris-doc then do:
  assign
    parartic     = cl_tt-clcparts.artic
    parprod-type = cl_tt-clcparts.prod-type
    parprod-code = cl_tt-clcparts.prod-code
    pardoc-type  = cl_tt-clcparts.doc-type
    pardoc-code  = cl_tt-clcparts.out-code
    parobj-type  = cl_tt-clcparts.obj-type
    parobj-code  = cl_tt-clcparts.obj-code.
if parext-doc-type = 'ot':U or
   parext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltcl = yes.
end.
else do:
  find first out-vatp_doc-attrcl no-lock
    where out-vatp_doc-attrcl.doc-code  = pardoc-code
      and out-vatp_doc-attrcl.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrcl then do:
    assign
      out-vatp-have-vat-sltcl = yes.
  end.
  else do:
     out-vatp-have-vat-sltcl = no.
  end.
end.
find first out-vatp_goodscl where out-vatp_goodscl.artic     = parartic     and
                                   out-vatp_goodscl.prod-type = parprod-type and
                                   out-vatp_goodscl.prod-code = parprod-code no-lock.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  parartic
  ,input  parprod-type
  ,input  parprod-code
  ,output varroot-nodecl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" parartic parprod-type parprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodecl
  ,input  'empty-scale=request'
  ,output varempty-scalecl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" parartic parprod-type parprod-code skip
    "Признак" varroot-nodecl skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbcl
  )  .
if varoutvprbcl = "base":u then do:
  assign
        road-tax-base-salecl    =  (if parroad-tax = ? then 0 else parroad-tax * 1)
    excise-base-salecl      =  (if parexcise   = ? then 0 else parexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-salecl    =  (if parroad-tax = ? then 0 else parroad-tax / parbase-rate * parbase-scale)
    excise-base-salecl      =  (if parexcise   = ? then 0 else parexcise   / parbase-rate * parbase-scale)
  .
end.
if varoutvprbcl = "rubl":u then do:
  assign
        road-tax-rubl-salecl    = (if parroad-tax = ? then 0 else parroad-tax * 1)
    excise-rubl-salecl      = (if parexcise   = ? then 0 else parexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-salecl    = (if parroad-tax = ? then 0 else parroad-tax * parbase-rate / parbase-scale)
    excise-rubl-salecl      = (if parexcise   = ? then 0 else parexcise   * parbase-rate / parbase-scale) .
end.
assign
  varis-cons-parts-havecl =  no.
assign
  varfact-qntycl       = 0
  varcons-qntycl       = 0
  varprice-base-conscl = 0
  varprice-rubl-conscl = 0.
find first out-vatp_doc-linecl where
           out-vatp_doc-linecl.doc-code   = pardoc-code
       and out-vatp_doc-linecl.artic      = parartic
       and out-vatp_doc-linecl.prod-type  = parprod-type
       and out-vatp_doc-linecl.prod-code  = parprod-code no-lock no-error.
if available out-vatp_doc-linecl           and
  (out-vatp_doc-linecl.status_ = 'запрос':U or out-vatp_goodscl.gds-type = 'у':U) then do:
  assign
    varfact-qntycl = out-vatp_doc-linecl.fact-qnty.
end.
else do:
  for each out-vatp_partscl where out-vatp_partscl.out-code   = pardoc-code
                               and out-vatp_partscl.obj-type   = parobj-type
                               and out-vatp_partscl.obj-code   = parobj-code
                               and out-vatp_partscl.artic      = parartic
                               and out-vatp_partscl.prod-type  = parprod-type
                               and out-vatp_partscl.prod-code  = parprod-code no-lock :
    if out-vatp_partscl.purch-code = 2 then do:
assign
  price-rubl-with-tax-lococl = out-vatp_partscl.price-rubl
  price-base-with-tax-lococl = out-vatp_partscl.price-base
.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbocl
  )  .
  if out-vatp_partscl.out-code = 'free-zone':U     or
     out-vatp_partscl.out-code = 'out-zone':U   or
     out-vatp_partscl.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltocl = yes.
  end.
  else do:
    find first in-vatp_doc-attrocl no-lock
      where in-vatp_doc-attrocl.doc-code  = out-vatp_partscl.out-code
        and in-vatp_doc-attrocl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrocl then do:
      assign
        in-vatp-have-vat-sltocl = yes.
    end.
    else do:
         in-vatp-have-vat-sltocl = no.
    end.
  end.
  assign
   price-cli-with-tax-lococl = out-vatp_partscl.price-cli
   cli-base-rateocl          = out-vatp_partscl.cli-base-rate.
  ASSIGN   road-tax-base-lococl  = (if out-vatp_partscl.road-tax-base  = ? then 0 else out-vatp_partscl.road-tax-base)
           road-tax-rubl-lococl  = (if out-vatp_partscl.road-tax-rubl  = ? then 0 else out-vatp_partscl.road-tax-rubl).
  ASSIGN  transport-base-lococl = (if out-vatp_partscl.transport-base = ? then 0 else out-vatp_partscl.transport-base)
          transport-rubl-lococl = (if out-vatp_partscl.transport-rubl = ? then 0 else out-vatp_partscl.transport-rubl)
          other-base-lococl     = (if out-vatp_partscl.other-base     = ? then 0 else out-vatp_partscl.other-base)
          other-rubl-lococl     = (if out-vatp_partscl.other-rubl     = ? then 0 else out-vatp_partscl.other-rubl)
          vat-pc-lococl         = (if out-vatp_partscl.vat-pc         = ? then 0 else out-vatp_partscl.vat-pc)
          slt-pc-lococl         = (if out-vatp_partscl.slt-pc         = ? then 0 else out-vatp_partscl.slt-pc).
          ASSIGN   slt-base-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-base-with-tax-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl)))                           * slt-pc-lococl / (100 + slt-pc-lococl))                        vat-base-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-base-with-tax-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl))) * (1 - slt-pc-lococl / (100 + slt-pc-lococl)) * vat-pc-lococl / (100 + vat-pc-lococl)).
    ASSIGN   slt-rubl-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-rubl-with-tax-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl)))                           * slt-pc-lococl / (100 + slt-pc-lococl))                        vat-rubl-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-rubl-with-tax-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl))) * (1 - slt-pc-lococl / (100 + slt-pc-lococl)) * vat-pc-lococl / (100 + vat-pc-lococl)).
  assign
    exch-rate-cli-lococl = (out-vatp_partscl.price-rubl - transport-rubl-lococl - other-rubl-lococl - road-tax-rubl-lococl - (if out-vatp_partscl.vat-type <> 'в т. ч.':U then vat-rubl-lococl else 0) - (if out-vatp_partscl.slt-type <> 'в т. ч.':U then slt-rubl-lococl else 0)) / out-vatp_partscl.price-cli .
  assign
    slt-cli-lococl        = slt-rubl-lococl       / exch-rate-cli-lococl
    vat-cli-lococl        = vat-rubl-lococl       / exch-rate-cli-lococl
    road-tax-cli-lococl   = road-tax-rubl-lococl  / exch-rate-cli-lococl
    transport-cli-lococl  = 0
    other-cli-lococl      = 0
  .
ASSIGN
          price-base-without-tax-lococl = price-base-with-tax-lococl - vat-base-lococl - slt-base-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl))
    price-rubl-without-tax-lococl = price-rubl-with-tax-lococl - vat-rubl-lococl - slt-rubl-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl))
.
      assign
        varprice-base-conscl = varprice-base-conscl + (price-base-with-tax-lococl - (if road-tax-base-lococl = ? then 0 else road-tax-base-lococl))* out-vatp_partscl.fact-qnty
        varprice-rubl-conscl = varprice-rubl-conscl + (price-rubl-with-tax-lococl - (if road-tax-rubl-lococl = ? then 0 else road-tax-rubl-lococl))* out-vatp_partscl.fact-qnty.
      assign
        varis-cons-parts-havecl = yes
        varcons-qntycl          = varcons-qntycl + out-vatp_partscl.fact-qnty.
    end.
    assign
      varfact-qntycl = varfact-qntycl + out-vatp_partscl.fact-qnty.
  end.
end.
assign
  varprice-base-conscl = varprice-base-conscl / varcons-qntycl
  varprice-rubl-conscl = varprice-rubl-conscl / varcons-qntycl.
if varprice-base-conscl = ? then do:
  assign
    varprice-base-conscl = 0.
end.
if varprice-rubl-conscl = ? then do:
  assign
    varprice-rubl-conscl = 0.
end.
assign
  varsum-base-factovpcl     = 0
  varslt-base-factovpcl     = 0
  varvat-base-factovpcl     = 0
  varvatcons-base-factovpcl = 0
  vardsc-base-factovpcl     = 0
  varsum-base-docovpcl      = 0
  varslt-base-docovpcl      = 0
  varvat-base-docovpcl      = 0
  varvatcons-base-docovpcl  = 0
  vardsc-base-docovpcl      = 0
  varsum-rubl-factovpcl     = 0
  varslt-rubl-factovpcl     = 0
  varvat-rubl-factovpcl     = 0
  varvatcons-rubl-factovpcl = 0
  vardsc-rubl-factovpcl     = 0
  varsum-rubl-docovpcl      = 0
  varslt-rubl-docovpcl      = 0
  varvat-rubl-docovpcl      = 0
  varvatcons-rubl-docovpcl  = 0
  vardsc-rubl-docovpcl      = 0.
assign
  varis-one-gds-dtlcl = no.
find first out-vatp_gds-dtlcl where out-vatp_gds-dtlcl.doc-code  = pardoc-code  and
                                     out-vatp_gds-dtlcl.artic     = parartic     and
                                     out-vatp_gds-dtlcl.prod-type = parprod-type and
                                     out-vatp_gds-dtlcl.prod-code = parprod-code no-lock no-error.
if available out-vatp_gds-dtlcl then do:
  find first buf_out-vatp_gds-dtlcl where buf_out-vatp_gds-dtlcl.doc-code  =  pardoc-code                and
                                           buf_out-vatp_gds-dtlcl.artic     =  parartic                   and
                                           buf_out-vatp_gds-dtlcl.prod-type =  parprod-type               and
                                           buf_out-vatp_gds-dtlcl.prod-code =  parprod-code               and
                                           recid(buf_out-vatp_gds-dtlcl)    <> recid(out-vatp_gds-dtlcl) no-lock no-error.
  if not available buf_out-vatp_gds-dtlcl then do:
    assign
      varis-one-gds-dtlcl = yes.
  end.
  if varoutvprbcl = "base":u then do:
    assign
      varcurclprice-base = out-vatp_gds-dtlcl.cur-base
      varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base * ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)).
  end.
  else do:
    assign
      varcurclprice-base = out-vatp_gds-dtlcl.cur-base / ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base))
      varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base.
  end.
  if varempty-scalecl    = yes or
     varis-one-gds-dtlcl = yes   then do:
    assign
                price-base-with-tax-salecl    = (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)
        slt-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)
        vat-base-buyercl              = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)
        discnt-base-salecl            = out-vatp_gds-dtlcl.discnt-base
                price-rubl-with-tax-salecl    = (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)
        slt-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)
        vat-rubl-buyercl              = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)
        discnt-rubl-salecl            = out-vatp_gds-dtlcl.discnt-rubl
        .
    if pardoc-type = 'инв':U then do:
      ASSIGN
                vat-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
                vat-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
        .
    end.
    else do:
      ASSIGN
                vat-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl ) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
                vat-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
        .
    end.
  end.
  else do:
    for each out-vatp_gds-dtlcl where out-vatp_gds-dtlcl.doc-code  = pardoc-code  and
                                       out-vatp_gds-dtlcl.artic     = parartic     and
                                       out-vatp_gds-dtlcl.prod-type = parprod-type and
                                       out-vatp_gds-dtlcl.prod-code = parprod-code no-lock :
      if varoutvprbcl = "base":u then do:
        assign
          varcurclprice-base = out-vatp_gds-dtlcl.cur-base
          varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base * ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)).
      end.
      else do:
        assign
          varcurclprice-base = out-vatp_gds-dtlcl.cur-base / ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base))
          varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base.
      end.
      assign
             varsum-base-factovpcl = varsum-base-factovpcl + (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)                 * out-vatp_gds-dtlcl.fact-qnty
       varslt-base-factovpcl = varslt-base-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvat-base-factovpcl = varvat-base-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvatcons-base-factovpcl = varvatcons-base-factovpcl + (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-base-factovpcl = vardsc-base-factovpcl + out-vatp_gds-dtlcl.discnt-base * out-vatp_gds-dtlcl.fact-qnty
       varsum-base-docovpcl  = varsum-base-docovpcl  + (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)                 * out-vatp_gds-dtlcl.doc-qnty
       varslt-base-docovpcl  = varslt-base-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvat-base-docovpcl  = varvat-base-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvatcons-base-docovpcl  = varvatcons-base-docovpcl  + (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-base-docovpcl  = vardsc-base-docovpcl  + out-vatp_gds-dtlcl.discnt-base * out-vatp_gds-dtlcl.doc-qnty
      .
      assign
             varsum-rubl-factovpcl = varsum-rubl-factovpcl + (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)                 * out-vatp_gds-dtlcl.fact-qnty
       varslt-rubl-factovpcl = varslt-rubl-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvat-rubl-factovpcl = varvat-rubl-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvatcons-rubl-factovpcl = varvatcons-rubl-factovpcl + (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-rubl-factovpcl = vardsc-rubl-factovpcl + out-vatp_gds-dtlcl.discnt-rubl * out-vatp_gds-dtlcl.fact-qnty
       varsum-rubl-docovpcl  = varsum-rubl-docovpcl  + (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)                 * out-vatp_gds-dtlcl.doc-qnty
       varslt-rubl-docovpcl  = varslt-rubl-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvat-rubl-docovpcl  = varvat-rubl-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvatcons-rubl-docovpcl  = varvatcons-rubl-docovpcl  + (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-rubl-docovpcl  = vardsc-rubl-docovpcl  + out-vatp_gds-dtlcl.discnt-rubl * out-vatp_gds-dtlcl.doc-qnty   .
    end.
    if pardoc-type = 'инв':U then do:
      ASSIGN
                price-base-with-tax-salecl    = varsum-base-docovpcl / varfact-qntycl
        slt-base-salecl               = varslt-base-docovpcl / varfact-qntycl
        vat-base-buyercl              = varvat-base-docovpcl / varfact-qntycl
        discnt-base-salecl            = vardsc-base-docovpcl / varfact-qntycl
        vat-base-salecl               = varvatcons-base-docovpcl / varfact-qntycl
                price-rubl-with-tax-salecl    = varsum-rubl-docovpcl / varfact-qntycl
        slt-rubl-salecl               = varslt-rubl-docovpcl / varfact-qntycl
        vat-rubl-buyercl              = varvat-rubl-docovpcl / varfact-qntycl
        discnt-rubl-salecl            = vardsc-rubl-docovpcl / varfact-qntycl
        vat-rubl-salecl               = varvatcons-rubl-docovpcl / varfact-qntycl.
    end.
    else do:
      ASSIGN
                price-base-with-tax-salecl    = varsum-base-factovpcl / varfact-qntycl
        slt-base-salecl               = varslt-base-factovpcl / varfact-qntycl
        vat-base-buyercl              = varvat-base-factovpcl / varfact-qntycl
        discnt-base-salecl            = vardsc-base-factovpcl / varfact-qntycl
        vat-base-salecl               = varvatcons-base-factovpcl / varfact-qntycl
                price-rubl-with-tax-salecl    = varsum-rubl-factovpcl / varfact-qntycl
        slt-rubl-salecl               = varslt-rubl-factovpcl / varfact-qntycl
        vat-rubl-buyercl              = varvat-rubl-factovpcl / varfact-qntycl
        discnt-rubl-salecl            = vardsc-rubl-factovpcl / varfact-qntycl
        vat-rubl-salecl               = varvatcons-rubl-factovpcl / varfact-qntycl.
    end.
  end.
end.
assign
  price-base-without-tax-salecl = price-base-with-tax-salecl - vat-base-salecl - slt-base-salecl - road-tax-base-salecl
  price-rubl-without-tax-salecl = price-rubl-with-tax-salecl - vat-rubl-salecl - slt-rubl-salecl - road-tax-rubl-salecl.
end.
if paris-cur then do:
  assign
    parcurartic      = cl_tt-clcparts.artic
    parcurprod-type  = cl_tt-clcparts.prod-type
    parcurprod-code  = cl_tt-clcparts.prod-code
    parcurdoc-type   = cl_tt-clcparts.doc-type
    parcurdoc-code   = cl_tt-clcparts.out-code
    parcurobj-type   = cl_tt-clcparts.obj-type
    parcurobj-code   = cl_tt-clcparts.obj-code.
  if parr-b = "base" then do:
    assign
      parcurprice-base = parcur-base
      parcurprice-rubl = parcur-base * parbase-rate / parbase-scale.
  end.
  else do:
    assign
      parcurprice-base = parcur-base / parbase-rate * parbase-scale
      parcurprice-rubl = parcur-base.
  end.
  assign
    parcurbase-rate   = parbase-rate
    parcurbase-scale  = parbase-scale
    parcurdiscnt-base = 0
    parcurdiscnt-rubl = 0
    parcurfact-qnty   = cl_tt-clcparts.fact-qnty
    parcurcli-qnty    = cl_tt-clcparts.cli-qnty
    parcurdoc-qnty    = cl_tt-clcparts.qnty.
if parcurext-doc-type = 'ot':U or
   parcurext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltcur = yes.
end.
else do:
  find first out-vatp_doc-attrcur no-lock
    where out-vatp_doc-attrcur.doc-code  = parcurdoc-code
      and out-vatp_doc-attrcur.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrcur then do:
    assign
      out-vatp-have-vat-sltcur = yes.
  end.
  else do:
     out-vatp-have-vat-sltcur = no.
  end.
end.
find first out-vatp_goodscur where out-vatp_goodscur.artic     = parcurartic     and
                                   out-vatp_goodscur.prod-type = parcurprod-type and
                                   out-vatp_goodscur.prod-code = parcurprod-code no-lock.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  parcurartic
  ,input  parcurprod-type
  ,input  parcurprod-code
  ,output varroot-nodecur
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" parcurartic parcurprod-type parcurprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodecur
  ,input  'empty-scale=request'
  ,output varempty-scalecur
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" parcurartic parcurprod-type parcurprod-code skip
    "Признак" varroot-nodecur skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbcur
  )  .
if varoutvprbcur = "base":u then do:
  assign
        road-tax-base-salecur    =  (if parcurroad-tax = ? then 0 else parcurroad-tax * 1)
    excise-base-salecur      =  (if parcurexcise   = ? then 0 else parcurexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-salecur    =  (if parcurroad-tax = ? then 0 else parcurroad-tax / parcurbase-rate * parcurbase-scale)
    excise-base-salecur      =  (if parcurexcise   = ? then 0 else parcurexcise   / parcurbase-rate * parcurbase-scale)
  .
end.
if varoutvprbcur = "rubl":u then do:
  assign
        road-tax-rubl-salecur    = (if parcurroad-tax = ? then 0 else parcurroad-tax * 1)
    excise-rubl-salecur      = (if parcurexcise   = ? then 0 else parcurexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-salecur    = (if parcurroad-tax = ? then 0 else parcurroad-tax * parcurbase-rate / parcurbase-scale)
    excise-rubl-salecur      = (if parcurexcise   = ? then 0 else parcurexcise   * parcurbase-rate / parcurbase-scale) .
end.
assign
  varis-cons-parts-havecur =  no.
assign
  varfact-qntycur       = 0
  varcons-qntycur       = 0
  varprice-base-conscur = 0
  varprice-rubl-conscur = 0.
if cl_tt-clcparts.purch-code = 2 then do:
assign
  price-rubl-with-tax-lococur = cl_tt-clcparts.price-rubl
  price-base-with-tax-lococur = cl_tt-clcparts.price-base
.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbocur
  )  .
  if cl_tt-clcparts.out-code = 'free-zone':U     or
     cl_tt-clcparts.out-code = 'out-zone':U   or
     cl_tt-clcparts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltocur = yes.
  end.
  else do:
    find first in-vatp_doc-attrocur no-lock
      where in-vatp_doc-attrocur.doc-code  = cl_tt-clcparts.out-code
        and in-vatp_doc-attrocur.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrocur then do:
      assign
        in-vatp-have-vat-sltocur = yes.
    end.
    else do:
         in-vatp-have-vat-sltocur = no.
    end.
  end.
  assign
   price-cli-with-tax-lococur = cl_tt-clcparts.price-cli
   cli-base-rateocur          = cl_tt-clcparts.cli-base-rate.
  ASSIGN   road-tax-base-lococur  = (if cl_tt-clcparts.road-tax-base  = ? then 0 else cl_tt-clcparts.road-tax-base)
           road-tax-rubl-lococur  = (if cl_tt-clcparts.road-tax-rubl  = ? then 0 else cl_tt-clcparts.road-tax-rubl).
  ASSIGN  transport-base-lococur = (if cl_tt-clcparts.transport-base = ? then 0 else cl_tt-clcparts.transport-base)
          transport-rubl-lococur = (if cl_tt-clcparts.transport-rubl = ? then 0 else cl_tt-clcparts.transport-rubl)
          other-base-lococur     = (if cl_tt-clcparts.other-base     = ? then 0 else cl_tt-clcparts.other-base)
          other-rubl-lococur     = (if cl_tt-clcparts.other-rubl     = ? then 0 else cl_tt-clcparts.other-rubl)
          vat-pc-lococur         = (if cl_tt-clcparts.vat-pc         = ? then 0 else cl_tt-clcparts.vat-pc)
          slt-pc-lococur         = (if cl_tt-clcparts.slt-pc         = ? then 0 else cl_tt-clcparts.slt-pc).
          ASSIGN   slt-base-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-base-with-tax-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur)))                           * slt-pc-lococur / (100 + slt-pc-lococur))                        vat-base-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-base-with-tax-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur))) * (1 - slt-pc-lococur / (100 + slt-pc-lococur)) * vat-pc-lococur / (100 + vat-pc-lococur)).
    ASSIGN   slt-rubl-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-rubl-with-tax-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur)))                           * slt-pc-lococur / (100 + slt-pc-lococur))                        vat-rubl-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-rubl-with-tax-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur))) * (1 - slt-pc-lococur / (100 + slt-pc-lococur)) * vat-pc-lococur / (100 + vat-pc-lococur)).
  assign
    exch-rate-cli-lococur = (cl_tt-clcparts.price-rubl - transport-rubl-lococur - other-rubl-lococur - road-tax-rubl-lococur - (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-rubl-lococur else 0) - (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-rubl-lococur else 0)) / cl_tt-clcparts.price-cli .
  assign
    slt-cli-lococur        = slt-rubl-lococur       / exch-rate-cli-lococur
    vat-cli-lococur        = vat-rubl-lococur       / exch-rate-cli-lococur
    road-tax-cli-lococur   = road-tax-rubl-lococur  / exch-rate-cli-lococur
    transport-cli-lococur  = 0
    other-cli-lococur      = 0
  .
ASSIGN
          price-base-without-tax-lococur = price-base-with-tax-lococur - vat-base-lococur - slt-base-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur))
    price-rubl-without-tax-lococur = price-rubl-with-tax-lococur - vat-rubl-lococur - slt-rubl-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur))
.
  assign
    varprice-base-conscur    = varprice-base-conscur + (price-base-with-tax-lococur - (if road-tax-base-lococur = ? then 0 else road-tax-base-lococur))* cl_tt-clcparts.fact-qnty
    varprice-rubl-conscur    = varprice-rubl-conscur + (price-rubl-with-tax-lococur - (if road-tax-rubl-lococur = ? then 0 else road-tax-rubl-lococur))* cl_tt-clcparts.fact-qnty
    varis-cons-parts-havecur = yes
    varcons-qntycur          = varcons-qntycur + cl_tt-clcparts.fact-qnty.
end.
assign
  varfact-qntycur = cl_tt-clcparts.fact-qnty.
assign
  varprice-base-conscur = varprice-base-conscur / varcons-qntycur
  varprice-rubl-conscur = varprice-rubl-conscur / varcons-qntycur.
if varprice-base-conscur = ? then do:
  assign
    varprice-base-conscur = 0.
end.
if varprice-rubl-conscur = ? then do:
  assign
    varprice-rubl-conscur = 0.
end.
assign
    slt-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc)
  vat-base-buyercur              = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc)
  discnt-base-salecur            = parcurdiscnt-base
  price-base-with-tax-salecur    = (parcurprice-base - parcurdiscnt-base)
    slt-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc)
  vat-rubl-buyercur              = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc)
  discnt-rubl-salecur            = parcurdiscnt-rubl
  price-rubl-with-tax-salecur    = (parcurprice-rubl - parcurdiscnt-rubl)
  .
if parcurdoc-type = 'инв':U then do:
  assign
    varfact-qntycur = parcurdoc-qnty.
end.
else do:
  assign
    varfact-qntycur = parcurfact-qnty.
end.
if varis-cons-parts-havecur = no then do:
  assign
        vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc)
        vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc).
end.
else do:
  if parcurdoc-type = 'инв':U then do:
    assign
            vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur - varprice-base-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurdoc-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc) * parcurdoc-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
            vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur - varprice-rubl-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurdoc-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc) * parcurdoc-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
     .
  end.
  else do:
    assign
            vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur - varprice-base-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurfact-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - varprice-base-conscur) * parcurvat-pc / (100 + parcurvat-pc) * parcurfact-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
            vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur - varprice-rubl-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurfact-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - varprice-rubl-conscur) * parcurvat-pc / (100 + parcurvat-pc) * parcurfact-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
     .
  end.
end.
assign
price-base-without-tax-salecur = price-base-with-tax-salecur - vat-base-salecur - slt-base-salecur - road-tax-base-salecur
price-rubl-without-tax-salecur = price-rubl-with-tax-salecur - vat-rubl-salecur - slt-rubl-salecur - road-tax-rubl-salecur.
end.
create bf_tt-allsum.
assign
  bf_tt-allsum.sum-type = 'основная_сумма':U.
assign
  bf_tt-allsum.fact-qnty          =  cl_tt-clcparts.fact-qnty
  bf_tt-allsum.cli-qnty           =  cl_tt-clcparts.cli-qnty
  bf_tt-allsum.sum-dsc-base-doc   =  (if price-base-with-tax-salecl  = ? then 0 else price-base-with-tax-salecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-doc   =  (if price-rubl-with-tax-salecl  = ? then 0 else price-rubl-with-tax-salecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-doc       =  (if discnt-base-salecl          = ? then 0 else discnt-base-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-rubl-doc       =  (if discnt-rubl-salecl          = ? then 0 else discnt-rubl-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-doc       =  (if slt-base-salecl             = ? then 0 else slt-base-salecl             * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-doc       =  (if slt-rubl-salecl             = ? then 0 else slt-rubl-salecl             * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-base-buyer-doc =  (if vat-base-buyercl            = ? then 0 else vat-base-buyercl            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-buyer-doc =  (if vat-rubl-buyercl            = ? then 0 else vat-rubl-buyercl            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-doc  =  (if road-tax-base-salecl        = ? then 0 else road-tax-base-salecl        * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-doc  =  (if road-tax-rubl-salecl        = ? then 0 else road-tax-rubl-salecl        * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-doc    =  (if excise-base-salecl          = ? then 0 else excise-base-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-rubl-doc    =  (if excise-rubl-salecl          = ? then 0 else excise-rubl-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-base-cur   =  (if price-base-with-tax-salecur = ? then 0 else price-base-with-tax-salecur * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-cur   =  (if price-rubl-with-tax-salecur = ? then 0 else price-rubl-with-tax-salecur * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-cur       =  (if discnt-base-salecur         = ? then 0 else discnt-base-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-rubl-cur       =  (if discnt-rubl-salecur         = ? then 0 else discnt-rubl-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-cur       =  (if slt-base-salecur            = ? then 0 else slt-base-salecur            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-cur       =  (if slt-rubl-salecur            = ? then 0 else slt-rubl-salecur            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-base-buyer-cur =  (if vat-base-buyercur           = ? then 0 else vat-base-buyercur           * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-buyer-cur =  (if vat-rubl-buyercur           = ? then 0 else vat-rubl-buyercur           * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-cur  =  (if road-tax-base-salecur       = ? then 0 else road-tax-base-salecur       * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-cur  =  (if road-tax-rubl-salecur       = ? then 0 else road-tax-rubl-salecur       * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-cur    =  (if excise-base-salecur         = ? then 0 else excise-base-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-rubl-cur    =  (if excise-rubl-salecur         = ? then 0 else excise-rubl-salecur         * cl_tt-clcparts.fact-qnty)
  .
if cl_tt-clcparts.purch-code = integer('2':U) then do:
  assign
    bf_tt-allsum.vat-base-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecl  - road-tax-base-salecl  - slt-base-salecl  - (cl_tt-clcparts.price-base - cl_tt-clcparts.road-tax-base)) * parcons-vat-pc / (100 + parcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecl  - road-tax-rubl-salecl  - slt-rubl-salecl  - (cl_tt-clcparts.price-rubl - cl_tt-clcparts.road-tax-rubl)) * parcons-vat-pc / (100 + parcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-base-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecur - road-tax-base-salecur - slt-base-salecur - (cl_tt-clcparts.price-base - cl_tt-clcparts.road-tax-base)) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecur - road-tax-rubl-salecur - slt-rubl-salecur - (cl_tt-clcparts.price-rubl - cl_tt-clcparts.road-tax-rubl)) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    .
end.
else do:
  assign
    bf_tt-allsum.vat-base-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecl  - road-tax-base-salecl  - slt-base-salecl ) * parvat-pc / (100 + parvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecl  - road-tax-rubl-salecl  - slt-rubl-salecl ) * parvat-pc / (100 + parvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-base-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecur - road-tax-base-salecur - slt-base-salecur) * parcurvat-pc / (100 + parcurvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecur - road-tax-rubl-salecur - slt-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc) * cl_tt-clcparts.fact-qnty)
    .
end.
if bf_tt-allsum.vat-base-doc = ? then bf_tt-allsum.vat-base-doc = 0.
if bf_tt-allsum.vat-rubl-doc = ? then bf_tt-allsum.vat-rubl-doc = 0.
assign
  bf_tt-allsum.sum-dsc-base-acc     = (if price-base-with-tax-loccl    = ? then 0 else price-base-with-tax-loccl    * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-acc     = (if price-rubl-with-tax-loccl    = ? then 0 else price-rubl-with-tax-loccl    * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-cli-acc      = (if (price-cli-with-tax-loccl +
                                           road-tax-cli-loccl       +
                                           (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-cli-loccl else 0) +
                                           (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-cli-loccl else 0)
                                           ) / cli-base-ratecl = ? then 0
                                        else
                                          (price-cli-with-tax-loccl +
                                           road-tax-cli-loccl       +
                                           (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-cli-loccl else 0) +
                                           (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-cli-loccl else 0)
                                           ) / cli-base-ratecl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-acc         = 0
  bf_tt-allsum.dsc-rubl-acc         = 0
  bf_tt-allsum.dsc-cli-acc          = 0
  bf_tt-allsum.vat-base-acc         = (if vat-base-loccl      = ? then 0 else vat-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-acc         = (if vat-rubl-loccl      = ? then 0 else vat-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-cli-acc          = (if vat-cli-loccl / cli-base-ratecl      = ? then 0 else vat-cli-loccl / cli-base-ratecl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-acc         = (if slt-base-loccl      = ? then 0 else slt-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-acc         = (if slt-rubl-loccl      = ? then 0 else slt-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-cli-acc          = (if slt-cli-loccl / cli-base-ratecl      = ? then 0 else slt-cli-loccl / cli-base-ratecl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-acc    = (if road-tax-base-loccl = ? then 0 else road-tax-base-loccl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-acc    = (if road-tax-rubl-loccl = ? then 0 else road-tax-rubl-loccl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-cli-acc     = (if road-tax-cli-loccl / cli-base-ratecl = ? then 0 else road-tax-cli-loccl / cli-base-ratecl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-acc      = 0
  bf_tt-allsum.excise-rubl-acc      = 0
  bf_tt-allsum.excise-cli-acc       = 0
  bf_tt-allsum.transport-base-acc   = (if transport-base-loccl   = ? then 0 else transport-base-loccl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.transport-rubl-acc   = (if transport-rubl-loccl   = ? then 0 else transport-rubl-loccl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.transport-cli-acc    = (if transport-cli-loccl / cli-base-ratecl   = ? then 0 else transport-cli-loccl / cli-base-ratecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-base-acc       = (if other-base-loccl       = ? then 0 else other-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-rubl-acc       = (if other-rubl-loccl       = ? then 0 else other-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-cli-acc        = (if other-cli-loccl / cli-base-ratecl       = ? then 0 else other-cli-loccl     / cli-base-ratecl  * cl_tt-clcparts.fact-qnty).
create bfs_tt-allsum.
assign
  bfs_tt-allsum.sum-type = 'основная_сумма_со_знаком':U.
if pardoc-type = 'инв':U or
   pardoc-type = 'при':U    or
   pardoc-type = 'возврат':U    then do:
   buffer-copy bf_tt-allsum except bf_tt-allsum.sum-type to bfs_tt-allsum.
end.
else do:
  assign
    bfs_tt-allsum.fact-qnty           =  - bf_tt-allsum.fact-qnty
    bfs_tt-allsum.cli-qnty            =  - bf_tt-allsum.cli-qnty
    bfs_tt-allsum.sum-dsc-base-doc    =  - bf_tt-allsum.sum-dsc-base-doc
    bfs_tt-allsum.sum-dsc-rubl-doc    =  - bf_tt-allsum.sum-dsc-rubl-doc
    bfs_tt-allsum.dsc-base-doc        =  - bf_tt-allsum.dsc-base-doc
    bfs_tt-allsum.dsc-rubl-doc        =  - bf_tt-allsum.dsc-rubl-doc
    bfs_tt-allsum.vat-base-doc        =  - bf_tt-allsum.vat-base-doc
    bfs_tt-allsum.vat-rubl-doc        =  - bf_tt-allsum.vat-rubl-doc
    bfs_tt-allsum.vat-base-buyer-doc  =  - bf_tt-allsum.vat-base-buyer-doc
    bfs_tt-allsum.vat-rubl-buyer-doc  =  - bf_tt-allsum.vat-rubl-buyer-doc
    bfs_tt-allsum.slt-base-doc        =  - bf_tt-allsum.slt-base-doc
    bfs_tt-allsum.slt-rubl-doc        =  - bf_tt-allsum.slt-rubl-doc
    bfs_tt-allsum.road-tax-base-doc   =  - bf_tt-allsum.road-tax-base-doc
    bfs_tt-allsum.road-tax-rubl-doc   =  - bf_tt-allsum.road-tax-rubl-doc
    bfs_tt-allsum.excise-base-doc     =  - bf_tt-allsum.excise-base-doc
    bfs_tt-allsum.excise-rubl-doc     =  - bf_tt-allsum.excise-rubl-doc
    bfs_tt-allsum.sum-dsc-base-cur    =  - bf_tt-allsum.sum-dsc-base-cur
    bfs_tt-allsum.sum-dsc-rubl-cur    =  - bf_tt-allsum.sum-dsc-rubl-cur
    bfs_tt-allsum.dsc-base-cur        =  - bf_tt-allsum.dsc-base-cur
    bfs_tt-allsum.dsc-rubl-cur        =  - bf_tt-allsum.dsc-rubl-cur
    bfs_tt-allsum.vat-base-cur        =  - bf_tt-allsum.vat-base-cur
    bfs_tt-allsum.vat-rubl-cur        =  - bf_tt-allsum.vat-rubl-cur
    bfs_tt-allsum.vat-base-buyer-cur  =  - bf_tt-allsum.vat-base-buyer-cur
    bfs_tt-allsum.vat-rubl-buyer-cur  =  - bf_tt-allsum.vat-rubl-buyer-cur
    bfs_tt-allsum.slt-base-cur        =  - bf_tt-allsum.slt-base-cur
    bfs_tt-allsum.slt-rubl-cur        =  - bf_tt-allsum.slt-rubl-cur
    bfs_tt-allsum.road-tax-base-cur   =  - bf_tt-allsum.road-tax-base-cur
    bfs_tt-allsum.road-tax-rubl-cur   =  - bf_tt-allsum.road-tax-rubl-cur
    bfs_tt-allsum.excise-base-cur     =  - bf_tt-allsum.excise-base-cur
    bfs_tt-allsum.excise-rubl-cur     =  - bf_tt-allsum.excise-rubl-cur
    bfs_tt-allsum.sum-dsc-base-acc    =  - bf_tt-allsum.sum-dsc-base-acc
    bfs_tt-allsum.sum-dsc-rubl-acc    =  - bf_tt-allsum.sum-dsc-rubl-acc
    bfs_tt-allsum.sum-dsc-cli-acc     =  - bf_tt-allsum.sum-dsc-cli-acc
    bfs_tt-allsum.dsc-base-acc        =  - bf_tt-allsum.dsc-base-acc
    bfs_tt-allsum.dsc-rubl-acc        =  - bf_tt-allsum.dsc-rubl-acc
    bfs_tt-allsum.dsc-cli-acc         =  - bf_tt-allsum.dsc-cli-acc
    bfs_tt-allsum.vat-base-acc        =  - bf_tt-allsum.vat-base-acc
    bfs_tt-allsum.vat-rubl-acc        =  - bf_tt-allsum.vat-rubl-acc
    bfs_tt-allsum.vat-cli-acc         =  - bf_tt-allsum.vat-cli-acc
    bfs_tt-allsum.slt-base-acc        =  - bf_tt-allsum.slt-base-acc
    bfs_tt-allsum.slt-rubl-acc        =  - bf_tt-allsum.slt-rubl-acc
    bfs_tt-allsum.slt-cli-acc         =  - bf_tt-allsum.slt-cli-acc
    bfs_tt-allsum.road-tax-base-acc   =  - bf_tt-allsum.road-tax-base-acc
    bfs_tt-allsum.road-tax-rubl-acc   =  - bf_tt-allsum.road-tax-rubl-acc
    bfs_tt-allsum.road-tax-cli-acc    =  - bf_tt-allsum.road-tax-cli-acc
    bfs_tt-allsum.excise-base-acc     =  - bf_tt-allsum.excise-base-acc
    bfs_tt-allsum.excise-rubl-acc     =  - bf_tt-allsum.excise-rubl-acc
    bfs_tt-allsum.excise-cli-acc      =  - bf_tt-allsum.excise-cli-acc
    bfs_tt-allsum.transport-base-acc  =  - bf_tt-allsum.transport-base-acc
    bfs_tt-allsum.transport-rubl-acc  =  - bf_tt-allsum.transport-rubl-acc
    bfs_tt-allsum.transport-cli-acc   =  - bf_tt-allsum.transport-cli-acc
    bfs_tt-allsum.other-base-acc      =  - bf_tt-allsum.other-base-acc
    bfs_tt-allsum.other-rubl-acc      =  - bf_tt-allsum.other-rubl-acc
    bfs_tt-allsum.other-cli-acc       =  - bf_tt-allsum.other-cli-acc.
end.
create bfpc_tt-allsum.
create bfspc_tt-allsum.
case cl_tt-clcparts.purch-code :
when 1           then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_выкупу':U
    bfspc_tt-allsum.sum-type = 'сумма_по_выкупу_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 4    then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_старой_консигнации':U
    bfspc_tt-allsum.sum-type = 'сумма_по_старой_консигнации_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 3 then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_ответственному_хранению':U
    bfspc_tt-allsum.sum-type = 'сумма_по_ответственному_хранению_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 2 then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_консигнации_выгода':U
    bfspc_tt-allsum.sum-type = 'сумма_по_консигнации_выгода_со_знаком':U.
  assign
    bfpc_tt-allsum.fact-qnty           = bf_tt-allsum.fact-qnty
    bfpc_tt-allsum.cli-qnty            = bf_tt-allsum.cli-qnty
    bfpc_tt-allsum.sum-dsc-base-doc    = bf_tt-allsum.sum-dsc-base-doc    - bf_tt-allsum.sum-dsc-base-acc
    bfpc_tt-allsum.sum-dsc-rubl-doc    = bf_tt-allsum.sum-dsc-rubl-doc    - bf_tt-allsum.sum-dsc-rubl-acc
    bfpc_tt-allsum.dsc-base-doc        = bf_tt-allsum.dsc-base-doc        - bf_tt-allsum.dsc-base-acc
    bfpc_tt-allsum.dsc-rubl-doc        = bf_tt-allsum.dsc-rubl-doc        - bf_tt-allsum.dsc-rubl-acc
    bfpc_tt-allsum.vat-base-doc        = bf_tt-allsum.vat-base-doc
    bfpc_tt-allsum.vat-rubl-doc        = bf_tt-allsum.vat-rubl-doc
    bfpc_tt-allsum.vat-base-buyer-doc  = bf_tt-allsum.vat-base-buyer-doc  - bf_tt-allsum.vat-base-acc
    bfpc_tt-allsum.vat-rubl-buyer-doc  = bf_tt-allsum.vat-rubl-buyer-doc  - bf_tt-allsum.vat-rubl-acc
    bfpc_tt-allsum.slt-base-doc        = bf_tt-allsum.slt-base-doc        - bf_tt-allsum.slt-base-acc
    bfpc_tt-allsum.slt-rubl-doc        = bf_tt-allsum.slt-rubl-doc        - bf_tt-allsum.slt-rubl-acc
    bfpc_tt-allsum.road-tax-base-doc   = bf_tt-allsum.road-tax-base-doc   - bf_tt-allsum.road-tax-base-acc
    bfpc_tt-allsum.road-tax-rubl-doc   = bf_tt-allsum.road-tax-rubl-doc   - bf_tt-allsum.road-tax-rubl-acc
    bfpc_tt-allsum.excise-base-doc     = bf_tt-allsum.excise-base-doc
    bfpc_tt-allsum.excise-rubl-doc     = bf_tt-allsum.excise-rubl-doc
    bfpc_tt-allsum.sum-dsc-base-cur    = bf_tt-allsum.sum-dsc-base-cur    - bf_tt-allsum.sum-dsc-base-acc
    bfpc_tt-allsum.sum-dsc-rubl-cur    = bf_tt-allsum.sum-dsc-rubl-cur    - bf_tt-allsum.sum-dsc-rubl-acc
    bfpc_tt-allsum.dsc-base-cur        = bf_tt-allsum.dsc-base-cur        - bf_tt-allsum.dsc-base-acc
    bfpc_tt-allsum.dsc-rubl-cur        = bf_tt-allsum.dsc-rubl-cur        - bf_tt-allsum.dsc-rubl-acc
    bfpc_tt-allsum.vat-base-cur        = bf_tt-allsum.vat-base-cur
    bfpc_tt-allsum.vat-rubl-cur        = bf_tt-allsum.vat-rubl-cur
    bfpc_tt-allsum.vat-base-buyer-cur  = bf_tt-allsum.vat-base-buyer-cur  - bf_tt-allsum.vat-base-acc
    bfpc_tt-allsum.vat-rubl-buyer-cur  = bf_tt-allsum.vat-rubl-buyer-cur  - bf_tt-allsum.vat-rubl-acc
    bfpc_tt-allsum.slt-base-cur        = bf_tt-allsum.slt-base-cur        - bf_tt-allsum.slt-base-acc
    bfpc_tt-allsum.slt-rubl-cur        = bf_tt-allsum.slt-rubl-cur        - bf_tt-allsum.slt-rubl-acc
    bfpc_tt-allsum.road-tax-base-cur   = bf_tt-allsum.road-tax-base-cur   - bf_tt-allsum.road-tax-base-acc
    bfpc_tt-allsum.road-tax-rubl-cur   = bf_tt-allsum.road-tax-rubl-cur   - bf_tt-allsum.road-tax-rubl-acc
    bfpc_tt-allsum.excise-base-cur     = bf_tt-allsum.excise-base-cur
    bfpc_tt-allsum.excise-rubl-cur     = bf_tt-allsum.excise-rubl-cur
    bfpc_tt-allsum.sum-dsc-base-acc    = 0
    bfpc_tt-allsum.sum-dsc-rubl-acc    = 0
    bfpc_tt-allsum.sum-dsc-cli-acc     = 0
    bfpc_tt-allsum.dsc-base-acc        = 0
    bfpc_tt-allsum.dsc-rubl-acc        = 0
    bfpc_tt-allsum.dsc-cli-acc         = 0
    bfpc_tt-allsum.vat-base-acc        = 0
    bfpc_tt-allsum.vat-rubl-acc        = 0
    bfpc_tt-allsum.vat-cli-acc         = 0
    bfpc_tt-allsum.slt-base-acc        = 0
    bfpc_tt-allsum.slt-rubl-acc        = 0
    bfpc_tt-allsum.slt-cli-acc         = 0
    bfpc_tt-allsum.road-tax-base-acc   = 0
    bfpc_tt-allsum.road-tax-rubl-acc   = 0
    bfpc_tt-allsum.road-tax-cli-acc    = 0
    bfpc_tt-allsum.excise-base-acc     = 0
    bfpc_tt-allsum.excise-rubl-acc     = 0
    bfpc_tt-allsum.excise-cli-acc      = 0
    bfpc_tt-allsum.transport-base-acc  = 0
    bfpc_tt-allsum.transport-rubl-acc  = 0
    bfpc_tt-allsum.transport-cli-acc   = 0
    bfpc_tt-allsum.other-base-acc      = 0
    bfpc_tt-allsum.other-rubl-acc      = 0
    bfpc_tt-allsum.other-cli-acc       = 0
    .
  assign
    bfspc_tt-allsum.fact-qnty           = bfs_tt-allsum.fact-qnty
    bfspc_tt-allsum.cli-qnty            = bfs_tt-allsum.cli-qnty
    bfspc_tt-allsum.sum-dsc-base-doc    = bfs_tt-allsum.sum-dsc-base-doc    - bfs_tt-allsum.sum-dsc-base-acc
    bfspc_tt-allsum.sum-dsc-rubl-doc    = bfs_tt-allsum.sum-dsc-rubl-doc    - bfs_tt-allsum.sum-dsc-rubl-acc
    bfspc_tt-allsum.dsc-base-doc        = bfs_tt-allsum.dsc-base-doc        - bfs_tt-allsum.dsc-base-acc
    bfspc_tt-allsum.dsc-rubl-doc        = bfs_tt-allsum.dsc-rubl-doc        - bfs_tt-allsum.dsc-rubl-acc
    bfspc_tt-allsum.vat-base-doc        = bfs_tt-allsum.vat-base-doc
    bfspc_tt-allsum.vat-rubl-doc        = bfs_tt-allsum.vat-rubl-doc
    bfspc_tt-allsum.vat-base-buyer-doc  = bfs_tt-allsum.vat-base-buyer-doc  - bfs_tt-allsum.vat-base-acc
    bfspc_tt-allsum.vat-rubl-buyer-doc  = bfs_tt-allsum.vat-rubl-buyer-doc  - bfs_tt-allsum.vat-rubl-acc
    bfspc_tt-allsum.slt-base-doc        = bfs_tt-allsum.slt-base-doc        - bfs_tt-allsum.slt-base-acc
    bfspc_tt-allsum.slt-rubl-doc        = bfs_tt-allsum.slt-rubl-doc        - bfs_tt-allsum.slt-rubl-acc
    bfspc_tt-allsum.road-tax-base-doc   = bfs_tt-allsum.road-tax-base-doc   - bfs_tt-allsum.road-tax-base-acc
    bfspc_tt-allsum.road-tax-rubl-doc   = bfs_tt-allsum.road-tax-rubl-doc   - bfs_tt-allsum.road-tax-rubl-acc
    bfspc_tt-allsum.excise-base-doc     = bfs_tt-allsum.excise-base-doc
    bfspc_tt-allsum.excise-rubl-doc     = bfs_tt-allsum.excise-rubl-doc
    bfspc_tt-allsum.sum-dsc-base-cur    = bfs_tt-allsum.sum-dsc-base-cur    - bfs_tt-allsum.sum-dsc-base-acc
    bfspc_tt-allsum.sum-dsc-rubl-cur    = bfs_tt-allsum.sum-dsc-rubl-cur    - bfs_tt-allsum.sum-dsc-rubl-acc
    bfspc_tt-allsum.dsc-base-cur        = bfs_tt-allsum.dsc-base-cur        - bfs_tt-allsum.dsc-base-acc
    bfspc_tt-allsum.dsc-rubl-cur        = bfs_tt-allsum.dsc-rubl-cur        - bfs_tt-allsum.dsc-rubl-acc
    bfspc_tt-allsum.vat-base-cur        = bfs_tt-allsum.vat-base-cur
    bfspc_tt-allsum.vat-rubl-cur        = bfs_tt-allsum.vat-rubl-cur
    bfspc_tt-allsum.vat-base-buyer-cur  = bfs_tt-allsum.vat-base-buyer-cur  - bfs_tt-allsum.vat-base-acc
    bfspc_tt-allsum.vat-rubl-buyer-cur  = bfs_tt-allsum.vat-rubl-buyer-cur  - bfs_tt-allsum.vat-rubl-acc
    bfspc_tt-allsum.slt-base-cur        = bfs_tt-allsum.slt-base-cur        - bfs_tt-allsum.slt-base-acc
    bfspc_tt-allsum.slt-rubl-cur        = bfs_tt-allsum.slt-rubl-cur        - bfs_tt-allsum.slt-rubl-acc
    bfspc_tt-allsum.road-tax-base-cur   = bfs_tt-allsum.road-tax-base-cur   - bfs_tt-allsum.road-tax-base-acc
    bfspc_tt-allsum.road-tax-rubl-cur   = bfs_tt-allsum.road-tax-rubl-cur   - bfs_tt-allsum.road-tax-rubl-acc
    bfspc_tt-allsum.excise-base-cur     = bfs_tt-allsum.excise-base-cur
    bfspc_tt-allsum.excise-rubl-cur     = bfs_tt-allsum.excise-rubl-cur
    bfspc_tt-allsum.sum-dsc-base-acc    = 0
    bfspc_tt-allsum.sum-dsc-rubl-acc    = 0
    bfspc_tt-allsum.sum-dsc-cli-acc     = 0
    bfspc_tt-allsum.dsc-base-acc        = 0
    bfspc_tt-allsum.dsc-rubl-acc        = 0
    bfspc_tt-allsum.dsc-cli-acc         = 0
    bfspc_tt-allsum.vat-base-acc        = 0
    bfspc_tt-allsum.vat-rubl-acc        = 0
    bfspc_tt-allsum.vat-cli-acc         = 0
    bfspc_tt-allsum.slt-base-acc        = 0
    bfspc_tt-allsum.slt-rubl-acc        = 0
    bfspc_tt-allsum.slt-cli-acc         = 0
    bfspc_tt-allsum.road-tax-base-acc   = 0
    bfspc_tt-allsum.road-tax-rubl-acc   = 0
    bfspc_tt-allsum.road-tax-cli-acc    = 0
    bfspc_tt-allsum.excise-base-acc     = 0
    bfspc_tt-allsum.excise-rubl-acc     = 0
    bfspc_tt-allsum.excise-cli-acc      = 0
    bfspc_tt-allsum.transport-base-acc  = 0
    bfspc_tt-allsum.transport-rubl-acc  = 0
    bfspc_tt-allsum.transport-cli-acc   = 0
    bfspc_tt-allsum.other-base-acc      = 0
    bfspc_tt-allsum.other-rubl-acc      = 0
    bfspc_tt-allsum.other-cli-acc       = 0
    .
  create bfacc_tt-allsum.
  assign
    bfacc_tt-allsum.sum-type = 'сумма_по_консигнации_закупка':U.
  create bfsacc_tt-allsum.
  assign
    bfsacc_tt-allsum.sum-type = 'сумма_по_консигнации_закупка_со_знаком':U.
  assign
    bfacc_tt-allsum.fact-qnty           = bf_tt-allsum.fact-qnty
    bfacc_tt-allsum.cli-qnty            = bf_tt-allsum.cli-qnty
    bfacc_tt-allsum.sum-dsc-base-doc    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-doc    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.dsc-base-doc        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-doc        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.vat-base-doc        = 0
    bfacc_tt-allsum.vat-rubl-doc        = 0
    bfacc_tt-allsum.vat-base-buyer-doc  = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-buyer-doc  = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.slt-base-doc        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-doc        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.road-tax-base-doc   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-doc   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.excise-base-doc     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-doc     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.sum-dsc-base-cur    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-cur    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.dsc-base-cur        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-cur        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.vat-base-cur        = 0
    bfacc_tt-allsum.vat-rubl-cur        = 0
    bfacc_tt-allsum.vat-base-buyer-cur  = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-buyer-cur  = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.slt-base-cur        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-cur        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.road-tax-base-cur   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-cur   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.excise-base-cur     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-cur     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.sum-dsc-base-acc    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-acc    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.sum-dsc-cli-acc     = bf_tt-allsum.sum-dsc-cli-acc
    bfacc_tt-allsum.dsc-base-acc        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-acc        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.dsc-cli-acc         = bf_tt-allsum.dsc-cli-acc
    bfacc_tt-allsum.vat-base-acc        = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-acc        = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.vat-cli-acc         = bf_tt-allsum.vat-cli-acc
    bfacc_tt-allsum.slt-base-acc        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-acc        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.slt-cli-acc         = bf_tt-allsum.slt-cli-acc
    bfacc_tt-allsum.excise-base-acc     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-acc     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.excise-cli-acc      = bf_tt-allsum.excise-cli-acc
    bfacc_tt-allsum.road-tax-base-acc   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-acc   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.road-tax-cli-acc    = bf_tt-allsum.road-tax-cli-acc
    bfacc_tt-allsum.transport-base-acc  = bf_tt-allsum.transport-base-acc
    bfacc_tt-allsum.transport-rubl-acc  = bf_tt-allsum.transport-rubl-acc
    bfacc_tt-allsum.transport-cli-acc   = bf_tt-allsum.transport-cli-acc
    bfacc_tt-allsum.other-base-acc      = bf_tt-allsum.other-base-acc
    bfacc_tt-allsum.other-rubl-acc      = bf_tt-allsum.other-rubl-acc
    bfacc_tt-allsum.other-cli-acc       = bf_tt-allsum.other-cli-acc
    .
  assign
    bfsacc_tt-allsum.fact-qnty           = bfs_tt-allsum.fact-qnty
    bfsacc_tt-allsum.cli-qnty            = bfs_tt-allsum.cli-qnty
    bfsacc_tt-allsum.sum-dsc-base-doc    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-doc    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.dsc-base-doc        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-doc        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.vat-base-doc        = 0
    bfsacc_tt-allsum.vat-rubl-doc        = 0
    bfsacc_tt-allsum.vat-base-buyer-doc  = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-buyer-doc  = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.slt-base-doc        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-doc        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.road-tax-base-doc   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-doc   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.excise-base-doc     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-doc     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.sum-dsc-base-cur    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-cur    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.dsc-base-cur        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-cur        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.vat-base-cur        = 0
    bfsacc_tt-allsum.vat-rubl-cur        = 0
    bfsacc_tt-allsum.vat-base-buyer-cur  = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-buyer-cur  = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.slt-base-cur        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-cur        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.road-tax-base-cur   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-cur   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.excise-base-cur     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-cur     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.sum-dsc-base-acc    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-acc    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.sum-dsc-cli-acc     = bfs_tt-allsum.sum-dsc-cli-acc
    bfsacc_tt-allsum.dsc-base-acc        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-acc        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.dsc-cli-acc         = bfs_tt-allsum.dsc-cli-acc
    bfsacc_tt-allsum.vat-base-acc        = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-acc        = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.vat-cli-acc         = bfs_tt-allsum.vat-cli-acc
    bfsacc_tt-allsum.slt-base-acc        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-acc        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.slt-cli-acc         = bfs_tt-allsum.slt-cli-acc
    bfsacc_tt-allsum.excise-base-acc     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-acc     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.excise-cli-acc      = bfs_tt-allsum.excise-cli-acc
    bfsacc_tt-allsum.road-tax-base-acc   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-acc   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.road-tax-cli-acc    = bfs_tt-allsum.road-tax-cli-acc
    bfsacc_tt-allsum.transport-base-acc  = bfs_tt-allsum.transport-base-acc
    bfsacc_tt-allsum.transport-rubl-acc  = bfs_tt-allsum.transport-rubl-acc
    bfsacc_tt-allsum.transport-cli-acc   = bfs_tt-allsum.transport-cli-acc
    bfsacc_tt-allsum.other-base-acc      = bfs_tt-allsum.other-base-acc
    bfsacc_tt-allsum.other-rubl-acc      = bfs_tt-allsum.other-rubl-acc
    bfsacc_tt-allsum.other-cli-acc       = bfs_tt-allsum.other-cli-acc
    .
end.
otherwise do:
  return error substitute ("Неизвестный тип приобретения &1 по партии с кодом &2 по документу &3, порожденную документом &4 по товару &5 &6 &7.",
                           cl_tt-clcparts.purch-code,
                           cl_tt-clcparts.part-code,
                           cl_tt-clcparts.out-code,
                           cl_tt-clcparts.in-code,
                           cl_tt-clcparts.artic,
                           cl_tt-clcparts.prod-type,
                           cl_tt-clcparts.prod-code).
end.
end case.
end.
end procedure.
procedure clcprtsl_calc-line :
define input  parameter parrec-line as recid no-undo.
define variable v-tax-date         as   date                     no-undo.
define variable v-vat-pc           like ub.doc-line.vat-pc       no-undo.
define variable varr-b             as   character                no-undo.
define variable varr-btype         as   character                no-undo.
define variable varcur-base        like ub.gds-dtl.price-base    no-undo.
define variable varcur-road-tax    like ub.doc-line.road-tax     no-undo.
define variable varcur-excise      like ub.doc-line.excise       no-undo.
define variable varcur-vat-pc      like ub.doc-line.vat-pc       no-undo.
define variable varcur-cons-vat-pc like ub.doc-line.cons-vat-pc  no-undo.
define variable varcur-slt-pc      like ub.doc-line.slt-pc       no-undo.
define variable varcur-fact-qnty   like ub.gds-dtl.fact-qnty     no-undo.
define variable varb-code          like ub.bar-code.b-code       no-undo.
define variable vardoc-num         like ub.price-doc.doc-num     no-undo.
define variable varprice-sale      like ub.price-list.price-sale no-undo.
define variable varroad-tax        like ub.price-list.road-tax   no-undo.
define variable varexcise          like ub.price-list.excise     no-undo.
define variable varlastcur-base        like ub.gds-dtl.price-base no-undo.
define variable varlastcur-road-tax    like ub.gds-dtl.price-base no-undo.
define variable varlastcur-excise      like ub.gds-dtl.price-base     no-undo.
define variable v-b-pcode          like ub.bar-code.b-code     no-undo.
define variable v-varsum           as decimal                  no-undo.
define variable varprice-salef as decimal   no-undo .
define buffer bf_trn-doc             for ub.trn-doc.
define buffer bf_doc-line            for ub.doc-line.
define buffer bf_gds-dtl             for ub.gds-dtl.
define buffer bf_goods               for ub.goods.
define buffer bf_parts               for ub.parts.
define buffer bf_sysconf             for ub.sysconf.
define buffer bf_tt-allsum-line      for tt-allsum-line.
define buffer bfs_tt-allsum-line     for tt-allsum-line.
define buffer bfo_tt-allsum-line     for tt-allsum-line.
define buffer bfos_tt-allsum-line    for tt-allsum-line.
define buffer buf_parts        for ub.parts.
v-calcbypart = no.
do on error undo, return error return-value :
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
  find first bf_doc-line where recid (bf_doc-line) = parrec-line no-lock.
  find first bf_trn-doc where bf_trn-doc.doc-code = bf_doc-line.doc-code no-lock.
  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock.
  if bf_trn-doc.fact-date <> ?        then do:
    assign v-tax-date = bf_trn-doc.fact-date.
  end.
  else do:
    assign v-tax-date = ?.
  end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '1':U
  ,input  v-tax-date
  ,input  bf_trn-doc.host-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output v-vat-pc
  ) no-error .
  if error-status :error
  or v-vat-pc = ? then do:
     return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
  end.
  if bf_goods.gds-type = 'у':U or
     bf_trn-doc.status_ = 'запрос':U then do:
    for each bf_tt-allsum-line
    on error undo, return error return-value
     :
      delete bf_tt-allsum-line.
    end.
    create bf_tt-allsum-line.
    assign
     bf_tt-allsum-line.sum-type = 'основная_сумма':U.
    for each bf_gds-dtl where bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
                              bf_gds-dtl.artic     = bf_doc-line.artic     and
                              bf_gds-dtl.prod-type = bf_doc-line.prod-type and
                              bf_gds-dtl.prod-code = bf_doc-line.prod-code no-lock on error undo, return error return-value :
      assign
        bf_tt-allsum-line.fact-qnty            =  bf_tt-allsum-line.fact-qnty        + bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-doc     =  bf_tt-allsum-line.sum-dsc-base-doc + (bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-doc     =  bf_tt-allsum-line.sum-dsc-rubl-doc + (bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.dsc-base-doc         =  bf_tt-allsum-line.dsc-base-doc     + bf_gds-dtl.discnt-base * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.dsc-rubl-doc         =  bf_tt-allsum-line.dsc-rubl-doc     + bf_gds-dtl.discnt-rubl * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-cur     =  bf_tt-allsum-line.sum-dsc-base-cur + (if varr-b = "base" then bf_gds-dtl.cur-base else bf_gds-dtl.cur-base / bf_trn-doc.exch-rate * bf_trn-doc.exch-scale) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-cur     =  bf_tt-allsum-line.sum-dsc-rubl-cur + (if varr-b = "rubl" then bf_gds-dtl.cur-base else bf_gds-dtl.cur-base * bf_trn-doc.exch-rate / bf_trn-doc.exch-scale) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-acc     =  bf_tt-allsum-line.sum-dsc-base-acc + bf_doc-line.price-base * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-acc     =  bf_tt-allsum-line.sum-dsc-rubl-acc + bf_doc-line.price-rubl * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-cli-acc      =  ?
        bf_tt-allsum-line.vat-base-acc         =  bf_tt-allsum-line.vat-base-acc     + bf_doc-line.price-base * v-vat-pc / (100 + v-vat-pc) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.vat-rubl-acc         =  bf_tt-allsum-line.vat-rubl-acc     + bf_doc-line.price-rubl * v-vat-pc / (100 + v-vat-pc) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.vat-cli-acc          =  ?
        .
    end.
    assign
      bf_tt-allsum-line.cli-qnty             =  ?
      bf_tt-allsum-line.slt-base-doc         =  bf_tt-allsum-line.sum-dsc-base-doc * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.slt-rubl-doc         =  bf_tt-allsum-line.sum-dsc-rubl-doc * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.vat-base-buyer-doc   =  (bf_tt-allsum-line.sum-dsc-base-doc - bf_tt-allsum-line.slt-base-doc) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.vat-rubl-buyer-doc   =  (bf_tt-allsum-line.sum-dsc-rubl-doc - bf_tt-allsum-line.slt-rubl-doc) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.road-tax-base-doc    =  0
      bf_tt-allsum-line.road-tax-rubl-doc    =  0
      bf_tt-allsum-line.excise-base-doc      =  0
      bf_tt-allsum-line.excise-rubl-doc      =  0
      bf_tt-allsum-line.vat-base-doc         =  bf_tt-allsum-line.vat-base-buyer-doc
      bf_tt-allsum-line.vat-rubl-doc         =  bf_tt-allsum-line.vat-rubl-buyer-doc
      bf_tt-allsum-line.dsc-base-cur         =  0
      bf_tt-allsum-line.dsc-rubl-cur         =  0
      bf_tt-allsum-line.slt-base-cur         =  bf_tt-allsum-line.sum-dsc-base-cur * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.slt-rubl-cur         =  bf_tt-allsum-line.sum-dsc-rubl-cur * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.vat-base-buyer-cur   =  (bf_tt-allsum-line.sum-dsc-base-cur - bf_tt-allsum-line.slt-base-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.vat-rubl-buyer-cur   =  (bf_tt-allsum-line.sum-dsc-rubl-cur - bf_tt-allsum-line.slt-rubl-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.road-tax-base-cur    =  0
      bf_tt-allsum-line.road-tax-rubl-cur    =  0
      bf_tt-allsum-line.excise-base-cur      =  0
      bf_tt-allsum-line.excise-rubl-cur      =  0
      bf_tt-allsum-line.vat-base-cur         =  bf_tt-allsum-line.vat-base-buyer-cur
      bf_tt-allsum-line.vat-rubl-cur         =  bf_tt-allsum-line.vat-rubl-buyer-cur
      bf_tt-allsum-line.dsc-base-acc         =  0
      bf_tt-allsum-line.dsc-rubl-acc         =  0
      bf_tt-allsum-line.dsc-cli-acc          =  0
      bf_tt-allsum-line.slt-base-acc         =  0
      bf_tt-allsum-line.slt-rubl-acc         =  0
      bf_tt-allsum-line.slt-cli-acc          =  0
      bf_tt-allsum-line.road-tax-base-acc    =  0
      bf_tt-allsum-line.road-tax-rubl-acc    =  0
      bf_tt-allsum-line.road-tax-cli-acc     =  0
      bf_tt-allsum-line.excise-base-acc      =  0
      bf_tt-allsum-line.excise-rubl-acc      =  0
      bf_tt-allsum-line.excise-cli-acc       =  0
      bf_tt-allsum-line.transport-base-acc   =  0
      bf_tt-allsum-line.transport-rubl-acc   =  0
      bf_tt-allsum-line.transport-cli-acc    =  0
      bf_tt-allsum-line.other-base-acc       =  0
      bf_tt-allsum-line.other-rubl-acc       =  0
      bf_tt-allsum-line.other-cli-acc        =  0
      .
    create bfs_tt-allsum-line.
    assign
    bfs_tt-allsum-line.sum-type = 'основная_сумма_со_знаком':U.
    if bf_trn-doc.doc-type = 'инв':U or
       bf_trn-doc.doc-type = 'при':U    or
       bf_trn-doc.doc-type = 'возврат':U    then do:
       buffer-copy bf_tt-allsum-line except bf_tt-allsum-line.sum-type to bfs_tt-allsum-line.
    end.
    else do:
      assign
        bfs_tt-allsum-line.fact-qnty           =  - bf_tt-allsum-line.fact-qnty
        bfs_tt-allsum-line.cli-qnty            =  - bf_tt-allsum-line.cli-qnty
        bfs_tt-allsum-line.sum-dsc-base-doc    =  - bf_tt-allsum-line.sum-dsc-base-doc
        bfs_tt-allsum-line.sum-dsc-rubl-doc    =  - bf_tt-allsum-line.sum-dsc-rubl-doc
        bfs_tt-allsum-line.dsc-base-doc        =  - bf_tt-allsum-line.dsc-base-doc
        bfs_tt-allsum-line.dsc-rubl-doc        =  - bf_tt-allsum-line.dsc-rubl-doc
        bfs_tt-allsum-line.vat-base-doc        =  - bf_tt-allsum-line.vat-base-doc
        bfs_tt-allsum-line.vat-rubl-doc        =  - bf_tt-allsum-line.vat-rubl-doc
        bfs_tt-allsum-line.vat-base-buyer-doc  =  - bf_tt-allsum-line.vat-base-buyer-doc
        bfs_tt-allsum-line.vat-rubl-buyer-doc  =  - bf_tt-allsum-line.vat-rubl-buyer-doc
        bfs_tt-allsum-line.slt-base-doc        =  - bf_tt-allsum-line.slt-base-doc
        bfs_tt-allsum-line.slt-rubl-doc        =  - bf_tt-allsum-line.slt-rubl-doc
        bfs_tt-allsum-line.road-tax-base-doc   =  - bf_tt-allsum-line.road-tax-base-doc
        bfs_tt-allsum-line.road-tax-rubl-doc   =  - bf_tt-allsum-line.road-tax-rubl-doc
        bfs_tt-allsum-line.excise-base-doc     =  - bf_tt-allsum-line.excise-base-doc
        bfs_tt-allsum-line.excise-rubl-doc     =  - bf_tt-allsum-line.excise-rubl-doc
        bfs_tt-allsum-line.sum-dsc-base-cur    =  - bf_tt-allsum-line.sum-dsc-base-cur
        bfs_tt-allsum-line.sum-dsc-rubl-cur    =  - bf_tt-allsum-line.sum-dsc-rubl-cur
        bfs_tt-allsum-line.dsc-base-cur        =  - bf_tt-allsum-line.dsc-base-cur
        bfs_tt-allsum-line.dsc-rubl-cur        =  - bf_tt-allsum-line.dsc-rubl-cur
        bfs_tt-allsum-line.vat-base-cur        =  - bf_tt-allsum-line.vat-base-cur
        bfs_tt-allsum-line.vat-rubl-cur        =  - bf_tt-allsum-line.vat-rubl-cur
        bfs_tt-allsum-line.vat-base-buyer-cur  =  - bf_tt-allsum-line.vat-base-buyer-cur
        bfs_tt-allsum-line.vat-rubl-buyer-cur  =  - bf_tt-allsum-line.vat-rubl-buyer-cur
        bfs_tt-allsum-line.slt-base-cur        =  - bf_tt-allsum-line.slt-base-cur
        bfs_tt-allsum-line.slt-rubl-cur        =  - bf_tt-allsum-line.slt-rubl-cur
        bfs_tt-allsum-line.road-tax-base-cur   =  - bf_tt-allsum-line.road-tax-base-cur
        bfs_tt-allsum-line.road-tax-rubl-cur   =  - bf_tt-allsum-line.road-tax-rubl-cur
        bfs_tt-allsum-line.excise-base-cur     =  - bf_tt-allsum-line.excise-base-cur
        bfs_tt-allsum-line.excise-rubl-cur     =  - bf_tt-allsum-line.excise-rubl-cur
        bfs_tt-allsum-line.sum-dsc-base-acc    =  - bf_tt-allsum-line.sum-dsc-base-acc
        bfs_tt-allsum-line.sum-dsc-rubl-acc    =  - bf_tt-allsum-line.sum-dsc-rubl-acc
        bfs_tt-allsum-line.sum-dsc-cli-acc     =  - bf_tt-allsum-line.sum-dsc-cli-acc
        bfs_tt-allsum-line.dsc-base-acc        =  - bf_tt-allsum-line.dsc-base-acc
        bfs_tt-allsum-line.dsc-rubl-acc        =  - bf_tt-allsum-line.dsc-rubl-acc
        bfs_tt-allsum-line.dsc-cli-acc         =  - bf_tt-allsum-line.dsc-cli-acc
        bfs_tt-allsum-line.vat-base-acc        =  - bf_tt-allsum-line.vat-base-acc
        bfs_tt-allsum-line.vat-rubl-acc        =  - bf_tt-allsum-line.vat-rubl-acc
        bfs_tt-allsum-line.vat-cli-acc         =  - bf_tt-allsum-line.vat-cli-acc
        bfs_tt-allsum-line.slt-base-acc        =  - bf_tt-allsum-line.slt-base-acc
        bfs_tt-allsum-line.slt-rubl-acc        =  - bf_tt-allsum-line.slt-rubl-acc
        bfs_tt-allsum-line.slt-cli-acc         =  - bf_tt-allsum-line.slt-cli-acc
        bfs_tt-allsum-line.road-tax-base-acc   =  - bf_tt-allsum-line.road-tax-base-acc
        bfs_tt-allsum-line.road-tax-rubl-acc   =  - bf_tt-allsum-line.road-tax-rubl-acc
        bfs_tt-allsum-line.road-tax-cli-acc    =  - bf_tt-allsum-line.road-tax-cli-acc
        bfs_tt-allsum-line.excise-base-acc     =  - bf_tt-allsum-line.excise-base-acc
        bfs_tt-allsum-line.excise-rubl-acc     =  - bf_tt-allsum-line.excise-rubl-acc
        bfs_tt-allsum-line.excise-cli-acc      =  - bf_tt-allsum-line.excise-cli-acc
        bfs_tt-allsum-line.transport-base-acc  =  - bf_tt-allsum-line.transport-base-acc
        bfs_tt-allsum-line.transport-rubl-acc  =  - bf_tt-allsum-line.transport-rubl-acc
        bfs_tt-allsum-line.transport-cli-acc   =  - bf_tt-allsum-line.transport-cli-acc
        bfs_tt-allsum-line.other-base-acc      =  - bf_tt-allsum-line.other-base-acc
        bfs_tt-allsum-line.other-rubl-acc      =  - bf_tt-allsum-line.other-rubl-acc
        bfs_tt-allsum-line.other-cli-acc       =  - bf_tt-allsum-line.other-cli-acc
        .
    end.
    create bfo_tt-allsum-line.
    assign
      bfo_tt-allsum-line.sum-type = 'сумма_по_услуге':U.
    buffer-copy bf_tt-allsum-line except bf_tt-allsum-line.sum-type to bfo_tt-allsum-line.
    create bfos_tt-allsum-line.
    assign
      bfos_tt-allsum-line.sum-type = 'сумма_по_услуге_со_знаком':U.
    buffer-copy bfs_tt-allsum-line except bfs_tt-allsum-line.sum-type to bfos_tt-allsum-line.
  end.
  else do:
    assign
      varlastcur-base      = 0
      varlastcur-road-tax  = 0
      varlastcur-excise    = 0
      varcur-base          = 0
      varcur-road-tax      = 0
      varcur-excise        = 0
      varcur-vat-pc        = 0
      varcur-slt-pc        = 0
      varcur-fact-qnty     = 0
    .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  ?
  ,output varb-code
  )  .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcprcex in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  varb-code
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-sale
  ,output varroad-tax
  ,output varexcise
  ,output varcur-vat-pc
  ,output varcur-slt-pc
  )  .
    if varprice-sale = ?
    then do:
      assign
        varcur-vat-pc = 0
        varcur-slt-pc = 0
      .
    end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '1':U
  ,input  bf_trn-doc.fact-date
  ,input  bf_trn-doc.host-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output varcur-vat-pc
  ) no-error .
    if varcur-vat-pc = ?
    then do:
      return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3 документ &4", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_trn-doc.doc-code).
    end.
    if varcur-slt-pc = ?
    then do:
      return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3 документ &4", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_trn-doc.doc-code).
    end.
    v-calcbypart = no.
    if bf_doc-line.whole-send-news = integer('1':U)   then
    v-calcbypart = yes.
    else do:
    for each bf_gds-dtl no-lock
      where bf_gds-dtl.doc-code  = bf_doc-line.doc-code
        and bf_gds-dtl.artic     = bf_doc-line.artic
        and bf_gds-dtl.prod-type = bf_doc-line.prod-type
        and bf_gds-dtl.prod-code = bf_doc-line.prod-code
    on error undo, return error return-value
    :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  bf_gds-dtl.prt-code
  ,output varb-code
  ) no-error .
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  varb-code
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-sale
  ,output varroad-tax
  ,output varexcise
  )  .
          if varprice-sale = ?
          then do:
            assign
              varprice-sale = 0
              varroad-tax   = 0
              varexcise     = 0
            .
          end.
          assign
            varlastcur-base     = varprice-sale
            varlastcur-road-tax = varroad-tax
            varlastcur-excise   = varexcise
            varcur-base         = varcur-base      + varprice-sale * bf_gds-dtl.fact-qnty
            varcur-road-tax     = varcur-road-tax  + varroad-tax   * bf_gds-dtl.fact-qnty
            varcur-excise       = varcur-excise    + varexcise     * bf_gds-dtl.fact-qnty
            varcur-fact-qnty    = varcur-fact-qnty + bf_gds-dtl.fact-qnty
          .
      end.
    end.
    if varcur-fact-qnty = 0 then do:
      assign
        varcur-base      = varlastcur-base
        varcur-road-tax  = varlastcur-road-tax
        varcur-excise    = varlastcur-excise
      .
    end.
    else do:
      assign
        varcur-base      = varcur-base      / varcur-fact-qnty
        varcur-road-tax  = varcur-road-tax  / varcur-fact-qnty
        varcur-excise    = varcur-excise    / varcur-fact-qnty
      .
    end.
    if varcur-vat-pc = ?
    then do:
      return error substitute ("Нет текущего продажного НДС по товару &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
    end.
    if varcur-slt-pc = ?
    then do:
      return error substitute ("Нет текущего продажного НП по товару &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
    end.
    find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
    assign
      varcur-cons-vat-pc = bf_sysconf.cons-vat-pc.
    if varcur-cons-vat-pc = ? then do:
      return error substitute ("Нет текущего продажного консигнационного НДС по фирме &1", bf_trn-doc.host-code).
    end.
    define buffer buf_tt-clcparts for tt-clcparts .
    for each buf_tt-clcparts
    on error undo, return error return-value
    :
      delete buf_tt-clcparts.
    end.
    for each bf_parts no-lock
      where bf_parts.out-code  = bf_doc-line.doc-code
        and bf_parts.obj-type  = bf_doc-line.obj-type
        and bf_parts.obj-code  = bf_doc-line.obj-code
        and bf_parts.artic     = bf_doc-line.artic
        and bf_parts.prod-type = bf_doc-line.prod-type
        and bf_parts.prod-code = bf_doc-line.prod-code
    on error undo, return error return-value
    :
      create buf_tt-clcparts .
      buffer-copy bf_parts to buf_tt-clcparts .
      if v-calcbypart = yes   then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer bf_parts
  ,output v-b-pcode
  ) no-error .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  bf_parts.obj-type
  ,input  bf_parts.obj-code
  ,input  v-b-pcode
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-salef
  ,output varroad-tax
  ,output varexcise
  ) no-error .
          if varprice-sale = ?
          then do:
            assign
              varprice-salef = 0
              varroad-tax   = 0
              varexcise     = 0
            .
          end.
          assign
          part-cur-base  = varprice-salef
          part-cur-road-tax  = varroad-tax
          part-cur-excise = varexcise.
      end.
    end.
    run clcprtsl_calc-ttable in this-procedure
      (input yes,
       input yes,
       input bf_doc-line.road-tax,
       input bf_doc-line.excise,
       input bf_doc-line.vat-pc,
       input bf_doc-line.cons-vat-pc,
       input bf_doc-line.slt-pc,
       input bf_trn-doc.base-rate,
       input bf_trn-doc.base-scale,
       input varr-b,
       input varcur-base,
       input varcur-road-tax,
       input varcur-excise,
       input varcur-vat-pc,
       input varcur-cons-vat-pc,
       input varcur-slt-pc
       ) no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры clcprtsl_calc-ttable." skip
        return-value skip
        trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5)) skip
        view-as alert-box error.
      undo, return error .
    end.
  end.
end.
end.
procedure clcprtsl_calc-ttable :
define input parameter paris-doc           as   logical                 no-undo.
define input parameter paris-cur           as   logical                 no-undo.
define input parameter parroad-tax         like ub.doc-line.road-tax    no-undo.
define input parameter parexcise           like ub.doc-line.excise      no-undo.
define input parameter parvat-pc           like ub.doc-line.vat-pc      no-undo.
define input parameter parcons-vat-pc      like ub.doc-line.cons-vat-pc no-undo.
define input parameter parslt-pc           like ub.doc-line.slt-pc      no-undo.
define input parameter parbase-rate        like ub.trn-doc.base-rate    no-undo.
define input parameter parbase-scale       like ub.trn-doc.base-scale   no-undo.
define input parameter parr-b              as   character               no-undo.
define input parameter parcur-base         like ub.gds-dtl.cur-base     no-undo.
define input parameter parcur-road-tax     like ub.doc-line.road-tax    no-undo.
define input parameter parcur-excise       like ub.doc-line.excise      no-undo.
define input parameter parcur-vat-pc       like ub.doc-line.vat-pc      no-undo.
define input parameter parcurcons-vat-pc   like ub.doc-line.cons-vat-pc no-undo.
define input parameter parcurslt-pc        like ub.doc-line.slt-pc      no-undo.
define buffer bf_tt-allsum      for tt-allsum.
define buffer bf_tt-clcparts    for tt-clcparts.
define buffer bf_tt-allsum-line for tt-allsum-line.
define variable v-b-pcode          like ub.bar-code.b-code     no-undo.
define variable vardoc-num         like ub.price-doc.doc-num     no-undo.
define variable varprice-sale      like ub.price-list.price-sale no-undo.
define variable varroad-tax        like ub.price-list.road-tax   no-undo.
define variable varexcise          like ub.price-list.excise     no-undo.
do on error undo, return error return-value :
for each bf_tt-allsum-line
on error undo, return error return-value
 :
  delete bf_tt-allsum-line.
end.
for each bf_tt-allsum
on error undo, return error return-value
:
  delete bf_tt-allsum.
end.
for each bf_tt-clcparts
on error undo, return error return-value
:
if v-calcbypart then do:
          assign
          parcur-base =   bf_tt-clcparts.part-cur-base
          parcur-road-tax = bf_tt-clcparts.part-cur-road-tax
          parcur-excise =   bf_tt-clcparts.part-cur-excise
          .
end.
   run clcprtsl_calc-parts in this-procedure (
     input recid(bf_tt-clcparts),
     input paris-doc,
     input paris-cur,
     input parroad-tax,
     input parexcise,
     input parvat-pc,
     input parcons-vat-pc,
     input parslt-pc,
     input parbase-rate,
     input parbase-scale,
     input parr-b,
     input parcur-base,
     input parcur-road-tax,
     input parcur-excise,
     input parcur-vat-pc,
     input parcurcons-vat-pc,
     input parcurslt-pc
     ) no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      vss-include-info14 skip
      "Ошибка при обсчете партии" skip
      "Документ партии " bf_tt-clcparts.out-code skip
      "Товар" bf_tt-clcparts.artic bf_tt-clcparts.prod-type bf_tt-clcparts.prod-code skip
      return-value skip
      error-status:get-message(1) skip
      error-status:get-message(2) skip
      error-status:get-message(3) skip
      view-as alert-box error .
    undo, return error .
  end.
  for each bf_tt-allsum on error undo, return error return-value :
    find first bf_tt-allsum-line where bf_tt-allsum-line.sum-type = bf_tt-allsum.sum-type no-error.
    if not available bf_tt-allsum-line then do:
      create bf_tt-allsum-line.
      assign
        bf_tt-allsum-line.sum-type = bf_tt-allsum.sum-type.
    end.
    assign
      bf_tt-allsum-line.fact-qnty              = bf_tt-allsum-line.fact-qnty            + bf_tt-allsum.fact-qnty
      bf_tt-allsum-line.cli-qnty               = bf_tt-allsum-line.cli-qnty             + bf_tt-allsum.cli-qnty
      bf_tt-allsum-line.sum-dsc-base-doc       = bf_tt-allsum-line.sum-dsc-base-doc     + bf_tt-allsum.sum-dsc-base-doc
      bf_tt-allsum-line.sum-dsc-rubl-doc       = bf_tt-allsum-line.sum-dsc-rubl-doc     + bf_tt-allsum.sum-dsc-rubl-doc
      bf_tt-allsum-line.dsc-base-doc           = bf_tt-allsum-line.dsc-base-doc         + bf_tt-allsum.dsc-base-doc
      bf_tt-allsum-line.dsc-rubl-doc           = bf_tt-allsum-line.dsc-rubl-doc         + bf_tt-allsum.dsc-rubl-doc
      bf_tt-allsum-line.vat-base-doc           = bf_tt-allsum-line.vat-base-doc         + bf_tt-allsum.vat-base-doc
      bf_tt-allsum-line.vat-rubl-doc           = bf_tt-allsum-line.vat-rubl-doc         + bf_tt-allsum.vat-rubl-doc
      bf_tt-allsum-line.vat-base-buyer-doc     = bf_tt-allsum-line.vat-base-buyer-doc   + bf_tt-allsum.vat-base-buyer-doc
      bf_tt-allsum-line.vat-rubl-buyer-doc     = bf_tt-allsum-line.vat-rubl-buyer-doc   + bf_tt-allsum.vat-rubl-buyer-doc
      bf_tt-allsum-line.slt-base-doc           = bf_tt-allsum-line.slt-base-doc         + bf_tt-allsum.slt-base-doc
      bf_tt-allsum-line.slt-rubl-doc           = bf_tt-allsum-line.slt-rubl-doc         + bf_tt-allsum.slt-rubl-doc
      bf_tt-allsum-line.road-tax-base-doc      = bf_tt-allsum-line.road-tax-base-doc    + bf_tt-allsum.road-tax-base-doc
      bf_tt-allsum-line.road-tax-rubl-doc      = bf_tt-allsum-line.road-tax-rubl-doc    + bf_tt-allsum.road-tax-rubl-doc
      bf_tt-allsum-line.excise-base-doc        = bf_tt-allsum-line.excise-base-doc      + bf_tt-allsum.excise-base-doc
      bf_tt-allsum-line.excise-rubl-doc        = bf_tt-allsum-line.excise-rubl-doc      + bf_tt-allsum.excise-rubl-doc
      bf_tt-allsum-line.sum-dsc-base-cur       = bf_tt-allsum-line.sum-dsc-base-cur     + bf_tt-allsum.sum-dsc-base-cur
      bf_tt-allsum-line.sum-dsc-rubl-cur       = bf_tt-allsum-line.sum-dsc-rubl-cur     + bf_tt-allsum.sum-dsc-rubl-cur
      bf_tt-allsum-line.dsc-base-cur           = bf_tt-allsum-line.dsc-base-cur         + bf_tt-allsum.dsc-base-cur
      bf_tt-allsum-line.dsc-rubl-cur           = bf_tt-allsum-line.dsc-rubl-cur         + bf_tt-allsum.dsc-rubl-cur
      bf_tt-allsum-line.vat-base-cur           = bf_tt-allsum-line.vat-base-cur         + bf_tt-allsum.vat-base-cur
      bf_tt-allsum-line.vat-rubl-cur           = bf_tt-allsum-line.vat-rubl-cur         + bf_tt-allsum.vat-rubl-cur
      bf_tt-allsum-line.vat-base-buyer-cur     = bf_tt-allsum-line.vat-base-buyer-cur   + bf_tt-allsum.vat-base-buyer-cur
      bf_tt-allsum-line.vat-rubl-buyer-cur     = bf_tt-allsum-line.vat-rubl-buyer-cur   + bf_tt-allsum.vat-rubl-buyer-cur
      bf_tt-allsum-line.slt-base-cur           = bf_tt-allsum-line.slt-base-cur         + bf_tt-allsum.slt-base-cur
      bf_tt-allsum-line.slt-rubl-cur           = bf_tt-allsum-line.slt-rubl-cur         + bf_tt-allsum.slt-rubl-cur
      bf_tt-allsum-line.road-tax-base-cur      = bf_tt-allsum-line.road-tax-base-cur    + bf_tt-allsum.road-tax-base-cur
      bf_tt-allsum-line.road-tax-rubl-cur      = bf_tt-allsum-line.road-tax-rubl-cur    + bf_tt-allsum.road-tax-rubl-cur
      bf_tt-allsum-line.excise-base-cur        = bf_tt-allsum-line.excise-base-cur      + bf_tt-allsum.excise-base-cur
      bf_tt-allsum-line.excise-rubl-cur        = bf_tt-allsum-line.excise-rubl-cur      + bf_tt-allsum.excise-rubl-cur
      bf_tt-allsum-line.sum-dsc-base-acc       = bf_tt-allsum-line.sum-dsc-base-acc     + bf_tt-allsum.sum-dsc-base-acc
      bf_tt-allsum-line.sum-dsc-rubl-acc       = bf_tt-allsum-line.sum-dsc-rubl-acc     + bf_tt-allsum.sum-dsc-rubl-acc
      bf_tt-allsum-line.sum-dsc-cli-acc        = bf_tt-allsum-line.sum-dsc-cli-acc      + bf_tt-allsum.sum-dsc-cli-acc
      bf_tt-allsum-line.dsc-base-acc           = bf_tt-allsum-line.dsc-base-acc         + bf_tt-allsum.dsc-base-acc
      bf_tt-allsum-line.dsc-rubl-acc           = bf_tt-allsum-line.dsc-rubl-acc         + bf_tt-allsum.dsc-rubl-acc
      bf_tt-allsum-line.dsc-cli-acc            = bf_tt-allsum-line.dsc-cli-acc          + bf_tt-allsum.dsc-cli-acc
      bf_tt-allsum-line.vat-base-acc           = bf_tt-allsum-line.vat-base-acc         + bf_tt-allsum.vat-base-acc
      bf_tt-allsum-line.vat-rubl-acc           = bf_tt-allsum-line.vat-rubl-acc         + bf_tt-allsum.vat-rubl-acc
      bf_tt-allsum-line.vat-cli-acc            = bf_tt-allsum-line.vat-cli-acc          + bf_tt-allsum.vat-cli-acc
      bf_tt-allsum-line.slt-base-acc           = bf_tt-allsum-line.slt-base-acc         + bf_tt-allsum.slt-base-acc
      bf_tt-allsum-line.slt-rubl-acc           = bf_tt-allsum-line.slt-rubl-acc         + bf_tt-allsum.slt-rubl-acc
      bf_tt-allsum-line.slt-cli-acc            = bf_tt-allsum-line.slt-cli-acc          + bf_tt-allsum.slt-cli-acc
      bf_tt-allsum-line.road-tax-base-acc      = bf_tt-allsum-line.road-tax-base-acc    + bf_tt-allsum.road-tax-base-acc
      bf_tt-allsum-line.road-tax-rubl-acc      = bf_tt-allsum-line.road-tax-rubl-acc    + bf_tt-allsum.road-tax-rubl-acc
      bf_tt-allsum-line.road-tax-cli-acc       = bf_tt-allsum-line.road-tax-cli-acc     + bf_tt-allsum.road-tax-cli-acc
      bf_tt-allsum-line.excise-base-acc        = bf_tt-allsum-line.excise-base-acc      + bf_tt-allsum.excise-base-acc
      bf_tt-allsum-line.excise-rubl-acc        = bf_tt-allsum-line.excise-rubl-acc      + bf_tt-allsum.excise-rubl-acc
      bf_tt-allsum-line.excise-cli-acc         = bf_tt-allsum-line.excise-cli-acc       + bf_tt-allsum.excise-cli-acc
      bf_tt-allsum-line.transport-base-acc     = bf_tt-allsum-line.transport-base-acc   + bf_tt-allsum.transport-base-acc
      bf_tt-allsum-line.transport-rubl-acc     = bf_tt-allsum-line.transport-rubl-acc   + bf_tt-allsum.transport-rubl-acc
      bf_tt-allsum-line.transport-cli-acc      = bf_tt-allsum-line.transport-cli-acc    + bf_tt-allsum.transport-cli-acc
      bf_tt-allsum-line.other-base-acc         = bf_tt-allsum-line.other-base-acc       + bf_tt-allsum.other-base-acc
      bf_tt-allsum-line.other-rubl-acc         = bf_tt-allsum-line.other-rubl-acc       + bf_tt-allsum.other-rubl-acc
      bf_tt-allsum-line.other-cli-acc          = bf_tt-allsum-line.other-cli-acc        + bf_tt-allsum.other-cli-acc
      .
  end.
end.
end.
end procedure.
define temp-table temp-font no-undo
  field fontnum  as integer
  field fontname as character
  field fontsize as character
  field fonttype as character
  field font-h   as integer
  field font-w   as integer
  field v-row    as integer
  field v-col    as integer
  field v-row-lans as integer
  field v-col-lans as integer
index pi fontnum
.
procedure get-font-ini :
  do
  on error undo, return error return-value
  :
define variable ii as integer   no-undo .
define variable v-font7 as character no-undo .
define variable v-font as character no-undo .
define variable loc-name as character no-undo .
define variable loc-size as character no-undo .
define variable loc-type as character no-undo .
define variable old_H as integer   no-undo .
define variable old_w as integer   no-undo .
define variable old-row  as integer   no-undo .
define variable old-col  as integer   no-undo .
define variable old-row-lans  as integer   no-undo .
define variable old-col-lans  as integer   no-undo .
define variable vv as integer   no-undo .
empty temp-table temp-font.
  GET-KEY-VALUE SECTION "fonts" KEY "font7" VALUE v-font7 .
    case num-entries (v-font7) :
      when 4 then do:
          assign
            loc-name = entry ( 1 , v-font7 )
            loc-size = entry ( 2 , v-font7 )
            loc-type = entry ( 3 , v-font7 ) + "," +  entry ( 4 , v-font7 )
          .
      end.
      when 3 then do:
          assign
            loc-name = entry ( 1 , v-font7 )
            loc-size = entry ( 2 , v-font7 )
            loc-type = entry ( 3 , v-font7 )
          .
      end.
      when 2 then  do:
          assign
            loc-name = entry ( 1 , v-font7 )
            loc-size = entry ( 2 , v-font7 )
            loc-type = ""
          .
      end.
      when 1 then do:
          assign
            loc-name = trim(entry ( 1 , v-font7 ))
            loc-size = ""
            loc-type = ""
          .
      end.
    end case.
  create temp-font.
  assign
    temp-font.fontnum  = 7
    temp-font.fontname = trim(loc-name)
    temp-font.fontsize = trim(loc-size)
    temp-font.fonttype = trim(loc-type)
    temp-font.v-row    = 62
    temp-font.v-col    = 136
    temp-font.v-row-lans = 43
    temp-font.v-col-lans = 198
  .
  repeat ii = 16 to 100 :
    get-key-value section 'fonts' key 'font' + string(ii)   value v-font  .
    if v-font = "" or v-font = ? then leave.
    case num-entries (v-font) :
      when 4 then do:
          assign
            loc-name = entry ( 1 , v-font )
            loc-size = entry ( 2 , v-font )
            loc-type = entry ( 3 , v-font ) + "," +  entry ( 4 , v-font )
          .
      end.
      when 3 then do:
          assign
            loc-name = entry ( 1 , v-font )
            loc-size = entry ( 2 , v-font )
            loc-type = entry ( 3 , v-font )
          .
      end.
      when 2 then do:
          assign
            loc-name = entry ( 1 , v-font )
            loc-size = entry ( 2 , v-font )
            loc-type = ""
          .
      end.
      when 1 then do:
          assign
            loc-name = trim(entry ( 1 , v-font ))
            loc-size = ""
            loc-type = ""
          .
      end.
    end case.
  create temp-font.
  assign
    temp-font.fontnum  = ii
    temp-font.fontname = trim(loc-name)
    temp-font.fontsize = trim(loc-size)
    temp-font.fonttype = trim(loc-type)
  .
  end.
    for each temp-font :
       vv = integer(entry(2,temp-font.fontsize, "=" )) no-error .
       if  vv = ? then vv =  0 .
        run rep/exfont.p (
          input   temp-font.fontname ,
          input   vv ,
          input   temp-font.fonttype ,
          output  temp-font.font-h   ,
          output  temp-font.font-w   )
        .
    end.
find first temp-font where  temp-font.fontnum  = 7  .
old_H = temp-font.font-H .
old_w = temp-font.font-W .
old-row = temp-font.v-row .
old-col = temp-font.v-col .
old-row-lans = temp-font.v-row-lans .
old-col-lans = temp-font.v-col-lans .
    for each temp-font where
             temp-font.fontnum  <> 7 :
        assign
            temp-font.v-row    = old_H * old-row / temp-font.font-h
            temp-font.v-col    = old_W * old-col / temp-font.font-W
            temp-font.v-row-lans    = old_H * old-row-lans / temp-font.font-h
            temp-font.v-col-lans    = old_W * old-col-lans / temp-font.font-W
        .
    end.
  end.
end procedure.
PROCEDURE How-name :
define input  parameter h as integer no-undo .
define input  parameter w as integer no-undo .
define output parameter n as character  no-undo .
define variable A4port-H as integer   no-undo init 63.
define variable A4port-W as integer   no-undo init 136.
define variable A4lans-H as integer   no-undo init 43.
define variable A4lans-W as integer   no-undo init 198.
define variable Strim-W  as integer   no-undo init 278.
run define-a4-size (
     input ReportFontNum
    ,output A4port-H
    ,output A4port-W
    ,output A4lans-H
    ,output A4lans-W ).
If w >= 1 and w <= A4port-W Then DO:
  If h >= 1  and h <= A4lans-H Then n = "A4-lans":U.
  If h > A4lans-H  and h <= A4port-H Then n = "A4-port":U.
  If h > A4port-H              Then n = "to-file":U.
End.
If w > A4port-W and w <= A4lans-W Then DO:
  If h >= 1  and h <= A4lans-H Then n = "A4-lans":U.
  If h > A4lans-H  and h <= A4port-H Then n = "A3-lans":U.
  If h > A4port-H              Then n = "to-file":U.
End.
If w > A4lans-W and w <= Strim-W Then DO:
  If h >= 1  and h <= A4lans-H Then n = "to-file":U.
  If h > A4lans-H  and h <= A4port-H Then n = "A3-lans":U.
  If h > A4port-H              Then n = "to-file":U.
End.
If w > Strim-W Then DO:
   n = "to-file":U.
End.
END PROCEDURE.
PROCEDURE define-a4-size :
define input  parameter p-ReportFontNum as integer   no-undo .
define output parameter A4port-H as integer   no-undo .
define output parameter A4port-W as integer   no-undo .
define output parameter A4lans-H as integer   no-undo .
define output parameter A4lans-W as integer   no-undo .
if not can-find (first temp-font ) then do:
   run get-font-ini .
end.
find first temp-font where temp-font.fontnum = p-ReportFontNum no-error .
if available temp-font then do:
assign
  A4port-H = temp-font.v-row
  A4port-W = temp-font.v-col
  A4lans-H = temp-font.v-row-lans
  A4lans-W = temp-font.v-col-lans
.
end.
else do:
assign
  A4port-H = 63
  A4port-W = 136
  A4lans-H = 43
  A4lans-W = 198
.
end.
END PROCEDURE.
define variable vss-include-info28 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v-fmtcli-name          as character    no-undo.
define variable v-fmtcli-engl-name     as character    no-undo.
define variable v-fmtcli-addres        as character    no-undo.
define variable v-fmtcli-post-addres   as character    no-undo.
define variable v-fmtcli-full-addres   as character    no-undo.
define variable v-fmtcli-phone         as character    no-undo.
define variable v-fmtcli-inn           as character    no-undo.
define variable v-fmtcli-kpp           as character    no-undo.
define variable v-fmtcli-okpo          as character    no-undo.
define variable v-fmtcli-country       as character    no-undo.
define variable v-fmtcli-city          as character    no-undo.
define variable v-fmtcli-index         as character    no-undo.
define variable v-fmtcli-schet-exists  as logical      no-undo.
define variable v-fmtcli-bank-exists   as logical      no-undo.
define variable v-fmtcli-bank-r-schet  as character    no-undo.
define variable v-fmtcli-bank-c-schet  as character    no-undo.
define variable v-fmtcli-bank-bik      as character    no-undo.
define variable v-fmtcli-bank-name     as character    no-undo.
define variable v-fmtcli-bank-addres   as character    no-undo.
define variable v-fmtcli-bank-city     as character    no-undo.
procedure fmtcli-get-bank :
define input parameter p-host-code      as integer          no-undo.
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-curr-code      as integer          no-undo.
    define buffer buf_fin-schet     for ub.fin-schet.
    define buffer buf_fin-bank      for ub.fin-bank.
do
for buf_fin-schet
  , buf_fin-bank
on error undo, return error
:
    assign
        v-fmtcli-schet-exists       = no
        v-fmtcli-bank-exists        = no
        v-fmtcli-bank-r-schet       = "":U
        v-fmtcli-bank-c-schet       = "":U
        v-fmtcli-bank-bik           = "":U
        v-fmtcli-bank-name          = "":U
        v-fmtcli-bank-addres        = "":U
        v-fmtcli-bank-city          = "":U
    .
    search-for-schet:
    for each buf_fin-schet no-lock
       where buf_fin-schet.host-code = p-host-code
         and buf_fin-schet.cli-type  = p-obj-type
         and buf_fin-schet.cli-code  = p-obj-code
         and buf_fin-schet.curr-code = p-curr-code
    on error undo, return error
    :
        if buf_fin-schet.status_   = 'удал':U
        then do:
        end.
        else do:
            assign
                v-fmtcli-schet-exists   = yes
                v-fmtcli-bank-r-schet   = trim( buf_fin-schet.r-schet )
                v-fmtcli-bank-c-schet   = trim( buf_fin-schet.c-schet )
            .
            find first buf_fin-bank no-lock
                 where buf_fin-bank.host-code = p-host-code
                   and buf_fin-bank.code-bank = buf_fin-schet.code-bank
            no-error.
            if available buf_fin-bank
            then do:
                assign
                    v-fmtcli-bank-exists      = yes
                    v-fmtcli-bank-bik         = trim( buf_fin-bank.bik )
                    v-fmtcli-bank-name        = trim( buf_fin-bank.bank-name )
                    v-fmtcli-bank-addres      = trim(buf_fin-bank.addres)
                    v-fmtcli-bank-city      = trim(buf_fin-bank.bank-city)
                .
            end.
            else do:
                assign
                    v-fmtcli-bank-exists    = no
                    v-fmtcli-bank-bik       = "":U
                    v-fmtcli-bank-name      = "":U
                    v-fmtcli-bank-addres    = "":U
                    v-fmtcli-bank-city      = "":U
                .
            end.
            leave search-for-schet.
        end.
    end.
end.
end procedure.
procedure fmtcli-get-client :
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
    define variable v-temp-fmtcli-address      as character     no-undo.
    define variable v-num-country-city    as integer      no-undo.
    define buffer buf_clients   for ub.clients.
    define buffer buf_firm      for ub.firm.
    define buffer buf_store     for ub.store.
    define buffer buf_shop      for ub.shop.
    define buffer buf_person    for ub.person.
do
for buf_clients
  , buf_firm
  , buf_store
  , buf_shop
  , buf_person
on error undo, return error
:
    assign
        v-fmtcli-name           = "":U
        v-fmtcli-addres         = "":U
        v-fmtcli-post-addres    = "":U
        v-fmtcli-full-addres    = "":U
        v-fmtcli-phone          = "":U
        v-fmtcli-inn            = "":U
        v-fmtcli-kpp            = "":U
        v-fmtcli-okpo           = "":U
        v-fmtcli-city           = "":U
        v-fmtcli-index          = "":U
        v-fmtcli-country        = "":U
    .
    find first buf_clients no-lock
         where buf_clients.obj-type = p-obj-type
           and buf_clients.obj-code = p-obj-code
    .
    assign
        v-fmtcli-name = buf_clients.obj-name
    .
    case buf_clients.obj-type:
       when 'орг':U
       then do:
            find first buf_firm no-lock
                 where buf_firm.firm-code = buf_clients.obj-code
                 no-error
            .
            if available buf_firm
            then do:
                assign
                    v-num-country-city = num-entries( buf_firm.city )
                    v-fmtcli-engl-name = buf_firm.engl-name
                .
                if v-num-country-city > 0
                then do:
                    assign
                        v-fmtcli-country    = trim( entry( 1, buf_firm.city ) )
                    .
                end.
                if v-num-country-city > 1
                then do:
                    assign
                        v-fmtcli-city       = trim( entry( 2, buf_firm.city ) )
                    .
                end.
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-country
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-city
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input IF buf_firm.ind = 0 THEN "" ELSE string( buf_firm.ind )
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input v-fmtcli-country
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input v-fmtcli-city
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input string( buf_firm.ind )
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input substring( buf_firm.addres1, 1, 50 )
                    , input buf_firm.addres2
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-temp-fmtcli-address
                    , input substring( buf_firm.addres1, 51, 50 )
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-temp-fmtcli-address
                    , input substring( buf_firm.addres1, 101, 50 )
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                assign
                    v-fmtcli-addres = v-temp-fmtcli-address
                .
                if buf_firm.addres1 <> ?
                then do:
                    run fmtcli-concatenate-strings in this-procedure (
                          input v-fmtcli-full-addres
                        , input v-fmtcli-addres
                        , input ", ":U
                        , input 0
                        , output v-fmtcli-full-addres
                    ).
                end.
                run fmtcli-concatenate-strings in this-procedure (
                      input substring( buf_firm.post-addr1, 1, 50 )
                    , input buf_firm.post-addr2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input substring( buf_firm.post-addr1, 51, 50 )
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input substring( buf_firm.post-addr1, 101, 50 )
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                assign
                    v-fmtcli-phone         = buf_firm.phone
                    v-fmtcli-inn           = buf_firm.inn
                    v-fmtcli-kpp           = buf_firm.kpp
                    v-fmtcli-okpo          = buf_firm.okpo
                    v-fmtcli-index         = string( buf_firm.ind )
                .
            end.
       end.
       when 'маг':U
       then do:
            find first buf_shop no-lock
                 where buf_shop.obj-code = buf_clients.obj-code
            .
            if available buf_shop
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input buf_shop.addres1
                    , input buf_shop.addres2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-addres
                ).
                assign
                    v-fmtcli-full-addres = v-fmtcli-addres
                    v-fmtcli-post-addres = v-fmtcli-addres
                    v-fmtcli-phone       = buf_shop.phone
                    v-fmtcli-inn         = "":U
                    v-fmtcli-kpp         = "":U
                    v-fmtcli-okpo        = "":U
                    v-fmtcli-city        = "":U
                    v-fmtcli-index       = "":U
                .
            end.
       end.
       when 'скл':U
       then do:
            find first buf_store no-lock
                 where buf_store.obj-code = buf_clients.obj-code
            .
            if available buf_store
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input buf_store.addres1
                    , input buf_store.addres2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-addres
                ).
                assign
                    v-fmtcli-full-addres = v-fmtcli-addres
                    v-fmtcli-phone       = buf_store.phone
                    v-fmtcli-inn         = "":U
                    v-fmtcli-kpp         = "":U
                    v-fmtcli-okpo        = "":U
                    v-fmtcli-city        = "":U
                    v-fmtcli-index       = "":U
                .
            end.
       end.
       when 'чел':U
       then do:
            find first buf_person no-lock
                 where buf_person.psn-code = buf_clients.obj-code
            .
            if available buf_person
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input ( if buf_person.ind = 0 or buf_person.ind = ?
                              then "":U
                              else string( buf_person.ind, "999999")
                              )
                    , input buf_person.city
                    , input ", ":U
                    , input 0
                    , output v-fmtcli-full-addres
                ).
                assign
                    v-fmtcli-addres = buf_person.address
                .
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-addres
                    , input ", ":U
                    , input 0
                    , output v-fmtcli-full-addres
                ).
                assign
                    v-fmtcli-phone     = buf_person.phone1
                    v-fmtcli-inn       = buf_person.inn
                    v-fmtcli-kpp       = buf_person.kpp
                    v-fmtcli-okpo      = buf_person.okpo
                    v-fmtcli-city      = buf_person.city
                    v-fmtcli-index     = string( buf_person.ind )
                .
            end.
       end.
    end case.
end.
end procedure.
procedure fmtcli-concatenate-strings :
define input parameter p-string-1       as character        no-undo.
define input parameter p-string-2       as character        no-undo.
define input parameter p-delimiter      as character        no-undo.
define input parameter p-length         as integer          no-undo.
define output parameter p-out-string    as character        no-undo.
do
on error undo, return error
:
    assign
        p-out-string = ( if p-string-1 = ?
                         then "":U
                         else trim( p-string-1 ) )
    .
    assign
        p-out-string = p-out-string
                     + ( if p-out-string = "":U
                         or length( p-out-string ) = p-length
                         or p-string-2 = ?
                         or trim( p-string-2 ) = "":U
                         then "":U
                         else p-delimiter )
                     + ( if p-string-2 = ?
                         or trim( p-string-2 ) = "":U
                         then "":U
                         else trim( p-string-2 ) )
    .
end.
end procedure.
def var vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable g#report-num  as integer    no-undo .
define variable vss-include-info30 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define stream excel-line.
define stream excel-cell.
define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character
    index pi is primary unique data-key
.
define temp-table temp_sheet1_line-data no-undo
    field sheet-name    as character
    field xl-line-id    as integer
    field alc-type-num  as character
    field alc-type-name as character
    field alc-type-code as character
    field ost-begin     as character
    field purchase      as character
    field sell          as character
    field ret           as character
    field other         as character
    field ras-total     as character
    field ost-end       as character
index pi is primary unique
        xl-line-id
.
define variable v-alc04xl-sheet1-cur-data-row  as integer      no-undo.
define variable v-alc04xl-cell-file-name       as character    no-undo.
define variable v-alc04xl-data-file-name       as character    no-undo.
procedure alc04xl-init :
do
on error undo, return error
:
    assign
        v-alc04xl-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-alc04xl-data-file-name
    ).
    output stream excel-line to value( v-alc04xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-alc04xl-cell-file-name
    ).
    output stream excel-cell to value( v-alc04xl-cell-file-name ).
    run alc04xl-write-cell-data in this-procedure (
          input "sheetList":U
        , input "Декларация":U
    ).
    if printrubl
    then do:
        run alc04xl-write-cell-data in this-procedure (
              input "Декларация_valutCode":U
            , input "0":U
        ).
    end.
    else do:
        run alc04xl-write-cell-data in this-procedure (
              input "Декларация_valutCode":U
            , input "1":U
        ).
    end.
    run alc04xl-write-cell-data in this-procedure (
          input "Декларация_columnList":U
        , input "alctypenum,alctypename,alctypecode,ostbegin,purchase,sell,ret,other,rastotal,ostend":U
    ).
    run alc04xl-write-cell-data in this-procedure (
          input "Декларация_columnType":U
        , input "S,S,S,S,S,S,S,S,S,S":U
    ).
    run alc04xl-write-cell-data in this-procedure (
          input "Декларация_subtotalList":U
        , input "":U
    ).
    run alc04xl-write-cell-data in this-procedure (
          input "Декларация_subtotalType":U
        , input "":U
    ).
end.
end procedure.
procedure alc04xl-sheet1-write-line-data :
define input parameter p-alc-type-num  as character no-undo .
define input parameter p-alc-type-name as character no-undo .
define input parameter p-alc-type-code as character no-undo .
define input parameter p-ost-begin     as character no-undo .
define input parameter p-purchase      as character no-undo .
define input parameter p-sell          as character no-undo .
define input parameter p-ret           as character no-undo .
define input parameter p-other         as character no-undo .
define input parameter p-ras-total     as character no-undo .
define input parameter p-ost-end       as character no-undo .
define buffer buf_temp_sheet1_line-data  for temp_sheet1_line-data.
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
        v-alc04xl-sheet1-cur-data-row           = v-alc04xl-sheet1-cur-data-row + 1
        buf_temp_sheet1_line-data.sheet-name    = "Декларация":U
        buf_temp_sheet1_line-data.xl-line-id    = v-alc04xl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.alc-type-num  = p-alc-type-num
        buf_temp_sheet1_line-data.alc-type-name = p-alc-type-name
        buf_temp_sheet1_line-data.alc-type-code = p-alc-type-code
        buf_temp_sheet1_line-data.ost-begin     = p-ost-begin
        buf_temp_sheet1_line-data.purchase      = p-purchase
        buf_temp_sheet1_line-data.sell          = p-sell
        buf_temp_sheet1_line-data.ret           = p-ret
        buf_temp_sheet1_line-data.other         = p-other
        buf_temp_sheet1_line-data.ras-total     = p-ras-total
        buf_temp_sheet1_line-data.ost-end       = p-ost-end
    .
    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        CHR(9)   "DTA":U
        CHR(9)   buf_temp_sheet1_line-data.alc-type-num
        CHR(9)   buf_temp_sheet1_line-data.alc-type-name
        CHR(9)   buf_temp_sheet1_line-data.alc-type-code
        CHR(9)   buf_temp_sheet1_line-data.ost-begin
        CHR(9)   buf_temp_sheet1_line-data.purchase
        CHR(9)   buf_temp_sheet1_line-data.sell
        CHR(9)   buf_temp_sheet1_line-data.ret
        CHR(9)   buf_temp_sheet1_line-data.other
        CHR(9)   buf_temp_sheet1_line-data.ras-total
        CHR(9)   buf_temp_sheet1_line-data.ost-end
        chr(10)
    .
    .
end.
end procedure.
procedure alc04xl-sheet1-write-line-format :
define input parameter p-fmt-label       as character  no-undo.
    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    put stream excel-line unformatted
                        "Декларация":U
        CHR(9)   "FMT":U
        CHR(9)   p-fmt-label
        chr(10)
    .
end.
end procedure.
procedure alc04xl-write-cell-data :
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
procedure alc04xl-run-excel :
define input parameter p-header-filename    as character        no-undo.
define input parameter p-data-filename      as character        no-undo.
    define variable v-Template-file-name    as character    no-undo.
    define variable v-vb-file-name          as character    no-undo.
    define buffer buf_temp-param for temp-param .
do
for buf_temp-param
on error undo, return error
:
    create buf_temp-param.
    assign
        v-Template-file-name    = search( "exe/alcdcl04.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas")
    .
    if v-Template-file-name = ?
    or v-Template-file-name = "":U
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
        , input v-Template-file-name
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
procedure alc04xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/alcdcl04.xlt":U.
        export "exe/t_form.bas":U.
        export v-alc04xl-cell-file-name.
        export v-alc04xl-data-file-name.
    output close.
end.
end procedure.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in my-handle
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define stream out-stream.
define temp-table tt-gds no-undo like ub.goods
  field alc-type-inner-code like ub.alc-type.alc-type-inner-code
  field create-user-db-num  like ub.alc-type.create-user-db-num
  field alc-type-code       like ub.alc-type.alc-type-code
  field alc-type-name       like ub.alc-type.alc-type-name
index pi is primary unique
  gds-code
index alc-type
  alc-type-inner-code
  create-user-db-num
index alc-type-code
  alc-type-code
.
define temp-table tt-report no-undo
  field alc-type-code       like ub.alc-type.alc-type-code
  field alc-type-name       like ub.alc-type.alc-type-name
  field ost-begin           as decimal
  field purchase            as decimal
  field sell                as decimal
  field ret                 as decimal
  field other               as decimal
  field ras-total           as decimal
  field ost-end             as decimal
index pi is primary unique
  alc-type-code
.
define variable v-par-val                 as character  no-undo .
define variable v-par-type                as character  no-undo .
define variable v-line                    as character  no-undo .
define variable v-begin-date              as date       no-undo .
define variable v-end-date                as date       no-undo .
define variable v-alc-type-num            as character  no-undo .
define variable v-host-code               like ub.clients.host-code  no-undo .
define variable v-host-code-2             like ub.clients.host-code  no-undo .
define frame f-decl
    sym1                        no-label format "X(1)"                          space(0)
    v-alc-type-num              no-label format "X(4)"                   space(0)
    sym2                        no-label format "X(1)"                          space(0)
    tt-report.alc-type-name     no-label format "X(56)"                   space(0)
    sym3                        no-label format "X(1)"                          space(0)
    tt-report.alc-type-code     no-label format "X(7)"                   space(0)
    sym4                        no-label format "X(1)"                          space(0)
    tt-report.ost-begin         no-label format "->>>,>>>,>>9.9999"                   space(0)
    sym5                        no-label format "X(1)"                          space(0)
    tt-report.purchase          no-label format "->>>,>>>,>>9.9999"                   space(0)
    sym6                        no-label format "X(1)"                          space(0)
    tt-report.sell              no-label format "->>>,>>>,>>9.9999"                   space(0)
    sym7                        no-label format "X(1)"                          space(0)
    tt-report.ret               no-label format "->>>,>>>,>>9.9999"                   space(0)
    sym8                        no-label format "X(1)"                          space(0)
    tt-report.other             no-label format "->>>,>>>,>>9.9999"                   space(0)
    sym9                        no-label format "X(1)"                          space(0)
    tt-report.ras-total         no-label format "->>>,>>>,>>9.9999"                   space(0)
    sym10                       no-label format "X(1)"                          space(0)
    tt-report.ost-end           no-label format "->>>,>>>,>>9.9999"                  space(0)
    sym11                       no-label format "X(1)"                          space(0)
header
  ":----:--------------------------------------------------------:-------:-----------------:-----------------:-----------------:-----------------:-----------------:-----------------:-----------------:":U skip
  ":  1 :                              2                         :   3   :         4       :         5       :         6       :         7       :        8        :        9        :        10       :":U skip
with width 198 down stream-io no-label no-box.
form header
        v-line format "X(197)" at 1 SKIP
        "Продолжение - на следующей странице" at 1 SKIP
with frame BottomFrame width 198 PAGE-BOTTOM NO-LABELS NO-BOX .
form header
        "Стр. " + string(PAGE-NUMBER(out-stream),">>9" ) at 185
with frame topFrame width 198 PAGE-TOP NO-LABELS NO-BOX .
do on error undo, return error return-value
:
if session :set-wait-state( "compiler" ) then.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  find first obj-list no-lock .
  if not available obj-list then do:
    message
      "Нет ни одного объекта для формирования отчета!"
    view-as alert-box error.
    return error return-value.
  end.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  obj-list.obj-type
  ,input  obj-list.obj-code
  ,output v-host-code
  )  .
  for each obj-list :
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  obj-list.obj-type
  ,input  obj-list.obj-code
  ,output v-host-code-2
  )  .
    if v-host-code <> v-host-code-2 then do:
      message
        "Отчет формируется только по объектам одной фирмы."
      view-as alert-box error.
      return error return-value.
    end.
  end.
  run clear-all in this-procedure .
  assign
    v-line        = fill( "-" , 300 )
    v-begin-date  = date(v-par-val)
    v-end-date    = x-Date-Alone
  .
  run get-report-num in my-handle (output g#report-num).
output stream out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
  run alc04xl-init in this-procedure.
  run waitfram-show in this-procedure ( "Формирование данных об организации..." ) .
  run find-alc-goods in this-procedure .
  run fill-tt-report in this-procedure .
  view stream out-stream frame BottomFrame .
  view stream out-stream frame topFrame .
  run print-header in this-procedure .
  run print-report in this-procedure .
  run print-footer in this-procedure .
  run alc04xl-close in this-procedure .
  hide stream out-stream frame BottomFrame.
  output stream out-stream close.
  if Make-Excel then output stream ForExcel close.
  run clear-all in this-procedure .
  run waitfram-hide in this-procedure .
if session :set-wait-state( "" ) then.
  os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
    value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
  .
  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
  run gbl/prnfilen.w
      (input  ""
      ,input  8
      ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
      ,input  ReportFontNum
      ,output v-user-action
      ,output v-printed
      ) .
  os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )  .
end.
procedure clear-all :
do
on error undo, return error return-value
:
  empty temp-table tt-gds.
  empty temp-table tt-report.
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
procedure fill-tt-report :
  define buffer buf_alc-type    for ub.alc-type.
  define buffer buf_trn-doc     for ub.trn-doc.
  define buffer t-doc           for ub.trn-doc.
  define buffer buf_doc-line    for ub.doc-line.
  define buffer buf_parts       for ub.parts.
  define buffer buf_tt-clcparts for tt-clcparts .
  define buffer buf_goods       for ub.goods.
  define buffer buf_ot-line     for ub.ot-line.
  define buffer buf_obj-list    for obj-list.
  define variable var-x-store-code    like ub.clients.obj-code    no-undo.
  define variable var-x-store-type    like ub.clients.obj-type    no-undo.
  define variable var-x-date-start    like ub.stk-tot.Fact-date   no-undo.
  define variable var-x-date-endt     like ub.stk-tot.Fact-date   no-undo.
  define variable var-x-sum-type      like ub.stk-tot.sum-type    no-undo.
  define variable var-x-ost-sum-type  like ub.stk-tot.sum-type    no-undo.
  define variable var-x-cat-id        like ub.stk-tot.cat-id      no-undo.
  define variable var-xTog-obj        as   logical             no-undo.
  define variable var-Quantity        like ub.stk-tot.fact-qnty   initial ? no-undo.
  define variable var-Coast_R         like ub.stk-tot.sum-rubl    no-undo.
  define variable var-Coast_V         like ub.stk-tot.sum-rubl    no-undo.
  define variable var-VAT_R           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-VAT_V           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-Fact-order      like ub.stk-tot.Fact-order  no-undo.
  define variable var-x-artic         like ub.stk-line.artic        no-undo.
  define variable var-x-prod-code     like ub.stk-line.prod-code    no-undo.
  define variable var-x-prod-type     like ub.stk-line.prod-type    no-undo.
  define variable var-SLT_R           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-SLT_V           like ub.stk-tot.sum-rubl    no-undo.
  define variable v-fact-order-1      like ub.ot-line.fact-order no-undo .
  define variable v-fact-order-2      like ub.ot-line.fact-order no-undo .
  define variable v-shift-end-fact-order          as decimal    no-undo .
  define variable v-day-end-fact-order            as decimal    no-undo .
  define variable v-part-qnty                     as decimal   no-undo .
  define variable v-ot-line-qnty                  as decimal   no-undo .
  define variable v-ost-begin-qnty  as decimal   no-undo .
  define variable v-purchase-qnty   as decimal   no-undo .
  define variable v-sell-qnty       as decimal   no-undo .
  define variable v-ret-qnty        as decimal   no-undo .
  define variable v-other-qnty      as decimal   no-undo .
  define variable v-ost-end-qnty    as decimal   no-undo .
  define variable v-income-doc-code like ub.trn-doc.doc-code no-undo .
do
on error undo, return error return-value
:
  run factord in this-procedure
    ( input  v-begin-date
    , input  1
    , input  1
    , input  ?
    , input  0
    , input  false
    , output v-fact-order-1
    , output v-shift-end-fact-order
    , output v-day-end-fact-order
    ) no-error .
  if error-status:error then do:
    message error-status :get-message(1) view-as alert-box error .
    return error.
  end.
  run factord in this-procedure
    ( input  v-end-date + 1
    , input  1
    , input  1
    , input  ?
    , input  0
    , input  false
    , output v-fact-order-2
    , output v-shift-end-fact-order
    , output v-day-end-fact-order
    ) no-error .
  if error-status:error then do:
    message error-status :get-message(1) view-as alert-box error .
    return error.
  end.
  assign
    var-x-sum-type      = 'cost':U
    var-x-ost-sum-type  = 'cost':U
  .
  run waitfram-show in this-procedure ( "Расчет остатков на начало" ).
  for each buf_alc-type no-lock
        where buf_alc-type.alc-type-status = 0
  break by buf_alc-type.alc-type-code
  :
    for each obj-list no-lock ,
        each tt-gds no-lock
          where tt-gds.alc-type-code = buf_alc-type.alc-type-code
    :
        assign
          var-x-store-code  = obj-list.obj-code
          var-x-store-type  = obj-list.obj-type
          var-x-artic       = tt-gds.artic
          var-x-prod-code   = tt-gds.prod-code
          var-x-prod-type   = tt-gds.prod-type
          var-x-cat-id      = '##,##':U
          var-xTog-obj      = yes
        .
        RUN ost-line  (
            input   var-x-store-code,
            input   var-x-store-type,
            INPUT   var-x-artic     ,
            INPUT   var-x-prod-code ,
            INPUT   var-x-prod-type ,
            input   no              ,
            input   v-fact-order-1  ,
            input   var-x-ost-sum-type  ,
            input   var-x-cat-id    ,
            input   var-xTog-obj    ,
            output  var-Quantity    ,
            output  var-Coast_R     ,
            output  var-Coast_V     ,
            output  var-VAT_R       ,
            output  var-VAT_V       ,
            output  var-SLT_R       ,
            output  var-SLT_V       ).
        assign
          v-ost-begin-qnty = v-ost-begin-qnty + (var-Quantity * tt-gds.ms-base / 10 )
        .
        RUN ost-line  (
            input   var-x-store-code,
            input   var-x-store-type,
            INPUT   var-x-artic     ,
            INPUT   var-x-prod-code ,
            INPUT   var-x-prod-type ,
            input   no              ,
            input   v-fact-order-2  ,
            input   var-x-ost-sum-type  ,
            input   var-x-cat-id    ,
            input   var-xTog-obj    ,
            output  var-Quantity    ,
            output  var-Coast_R     ,
            output  var-Coast_V     ,
            output  var-VAT_R       ,
            output  var-VAT_V       ,
            output  var-SLT_R       ,
            output  var-SLT_V       ).
        assign
          v-ost-end-qnty = v-ost-end-qnty + + (var-Quantity * tt-gds.ms-base / 10 )
        .
    end.
    for each obj-list no-lock ,
        each tt-gds no-lock
          where tt-gds.alc-type-inner-code = buf_alc-type.alc-type-inner-code
            and tt-gds.create-user-db-num  = buf_alc-type.create-user-db-num ,
          each buf_ot-line no-lock
            where   buf_ot-line.artic        = tt-gds.artic
              and   buf_ot-line.prod-code    = tt-gds.prod-code
              and   buf_ot-line.prod-type    = tt-gds.prod-type
              and   buf_ot-line.fact-order   <= v-fact-order-2
              and   buf_ot-line.fact-order   >= v-fact-order-1
              and   buf_ot-line.obj-code     = obj-list.obj-code
              and   buf_ot-line.obj-type     = obj-list.obj-type
              and   buf_ot-line.sum-type     = var-x-sum-type
    :
      run waitfram-show in this-procedure (input substitute("Расчет оборота по объекту: &1" , obj-list.obj-name ) ).
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = buf_ot-line.doc-code
      no-error .
      if not available buf_trn-doc then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Не найден складской документ &1.&2Документ не будет учтен в отчете." , buf_ot-line.doc-code , chr(10) )
        view-as alert-box error .
        next.
      end.
        assign
          v-ot-line-qnty  = abs(buf_ot-line.fact-qnty * tt-gds.ms-base / 10)
        .
      case buf_ot-line.ext-doc-type:
        when 'ie':U  then do :
          assign
            v-purchase-qnty = v-purchase-qnty + v-ot-line-qnty
          .
        end.
        when 'iv':U then do :
          assign
            v-other-qnty = v-other-qnty - v-ot-line-qnty
          .
        end.
        when 'ee':U  then do :
          assign
            v-sell-qnty = v-sell-qnty + v-ot-line-qnty
          .
        end.
        when 'es':U  then do :
          assign
            v-sell-qnty = v-sell-qnty + v-ot-line-qnty
          .
        end.
        when 're':U  then do :
          assign
            v-ret-qnty = v-ret-qnty + v-ot-line-qnty
          .
        end.
        when 'rs':U  then do :
          assign
            v-ret-qnty = v-ret-qnty - v-ot-line-qnty
          .
        end.
        when 'ep':U then do :
          assign
            v-ret-qnty = v-ret-qnty + v-ot-line-qnty
          .
        end.
        when 'we':U  then do :
          assign
            v-other-qnty = v-other-qnty + v-ot-line-qnty
          .
        end.
        when 'ev':U then do :
          assign
            v-other-qnty = v-other-qnty + v-ot-line-qnty
          .
        end.
        when 'rv':U then do :
          assign
            v-other-qnty = v-other-qnty - v-ot-line-qnty
          .
        end.
        when 'vt':U or when 'vp':U or when 'im':U then do:
          assign
            v-other-qnty = v-other-qnty - v-ot-line-qnty
          .
        end.
        otherwise do:
          assign
            v-other-qnty = v-other-qnty + v-ot-line-qnty
          .
        end.
      end case.
    end.
    if last-of( buf_alc-type.alc-type-code ) then do:
      find first tt-report
        where tt-report.alc-type-code = buf_alc-type.alc-type-code
      no-error .
      if not available tt-report then do:
        create tt-report.
      end.
      assign
        tt-report.alc-type-code = buf_alc-type.alc-type-code
        tt-report.alc-type-name = buf_alc-type.alc-type-name + ( if buf_alc-type.alc-type-code = "460" then " *" else "" )
        tt-report.ost-begin     = v-ost-begin-qnty
        tt-report.purchase      = v-purchase-qnty
        tt-report.sell          = v-sell-qnty
        tt-report.ret           = v-ret-qnty
        tt-report.other         = v-other-qnty
        tt-report.ras-total     = v-sell-qnty + v-ret-qnty + v-other-qnty
        tt-report.ost-end       = v-ost-end-qnty
        v-ost-begin-qnty        = 0
        v-purchase-qnty         = 0
        v-sell-qnty             = 0
        v-ret-qnty              = 0
        v-other-qnty            = 0
        v-ost-end-qnty          = 0
      .
    end.
  end.
end.
end procedure.
procedure find-income-doc-code :
  define input  parameter p-in-code         like ub.parts.in-code    no-undo .
  define input  parameter p-gds-code        like ub.goods.gds-code   no-undo .
  define input  parameter p-part-code       like ub.parts.part-code  no-undo .
  define output parameter p-income-doc-code like ub.parts.in-code    no-undo .
define buffer buf_parts-attr        for ub.parts-attr .
define buffer buf_income_parts-attr for ub.parts-attr .
do on error undo, return error return-value :
  assign
    p-income-doc-code = ?
  .
  find first buf_parts-attr no-lock
    where buf_parts-attr.in-code   = p-in-code
      and buf_parts-attr.gds-code  = p-gds-code
      and buf_parts-attr.part-code = p-part-code
  no-error .
  if available buf_parts-attr then do:
    find first buf_income_parts-attr no-lock
      where buf_income_parts-attr.in-code   = buf_parts-attr.income-in-code
        and buf_income_parts-attr.gds-code  = buf_parts-attr.income-gds-code
        and buf_income_parts-attr.part-code = buf_parts-attr.income-part-code
      no-error .
    if available buf_income_parts-attr then do:
      assign
        p-income-doc-code = buf_parts-attr.income-in-code
      .
    end.
    else do:
      assign
        p-income-doc-code = ?
      .
    end.
  end.
  else do:
    assign
      p-income-doc-code = ?
    .
  end.
end.
end procedure.
procedure print-report :
  define variable v-alc-type-code-int       as integer   no-undo .
  define variable v-alc-type-code-int-prev  as integer   no-undo .
  define variable v-section                 as integer   no-undo .
  define variable v-subsection              as integer   no-undo .
  define variable v-ost-begin-tot-qnty      as decimal   no-undo .
  define variable v-purchase-tot-qnty       as decimal   no-undo .
  define variable v-sell-tot-qnty           as decimal   no-undo .
  define variable v-ret-tot-qnty            as decimal   no-undo .
  define variable v-other-tot-qnty          as decimal   no-undo .
  define variable v-ras-tot-qnty            as decimal   no-undo .
  define variable v-ost-end-tot-qnty        as decimal   no-undo .
  define variable v-row-counter             as integer   no-undo .
  define variable v-offset                  as integer   no-undo .
  define variable v-i                       as integer   no-undo .
  define variable v-alc-type-name           as character no-undo .
do
on error undo, return error return-value
:
  assign
    v-section                = 1
    v-subsection             = 1
    v-alc-type-num           = substitute( "&1.&2" , v-section , v-subsection )
    v-alc-type-code-int-prev = 0
  .
  for each tt-report
    break by tt-report.alc-type-code
  :
    if first-of(tt-report.alc-type-code) then do:
      assign
        v-alc-type-code-int-prev  = v-alc-type-code-int
        v-alc-type-code-int       = integer(tt-report.alc-type-code)
      no-error .
      if error-status :error then do:
        assign
          v-alc-type-code-int = 0
        .
      end.
      if v-alc-type-code-int-prev < 200 and v-alc-type-code-int >= 200 then do:
        assign
          v-alc-type-name = "Спиртные напитки, в том числе:"
        .
        display stream out-stream
          "1"  @ v-alc-type-num
          v-alc-type-name @ tt-report.alc-type-name
          "x" @ tt-report.alc-type-code
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
        with frame f-decl.
        down stream out-stream with frame f-decl.
        run alc04xl-sheet1-write-line-data in this-procedure
              ( input "1"
              , input v-alc-type-name
              , input "x"
              , input " "
              , input " "
              , input " "
              , input " "
              , input " "
              , input " "
              , input " "
              ).
      end.
      if v-alc-type-code-int-prev < 400 and v-alc-type-code-int >= 400 then do:
          assign
            v-section = v-section + 1
            v-subsection    = 1
            v-alc-type-num  = substitute( "&1.&2" , v-section , v-subsection )
            v-alc-type-name = "Вина, в том числе:"
          .
          display stream out-stream
            "2"  @ v-alc-type-num
            v-alc-type-name @ tt-report.alc-type-name
            "x" @ tt-report.alc-type-code
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
          with frame f-decl.
          down stream out-stream with frame f-decl.
          run alc04xl-sheet1-write-line-data in this-procedure
                ( input "2"
                , input v-alc-type-name
                , input "x"
                , input " "
                , input " "
                , input " "
                , input " "
                , input " "
                , input " "
                , input " "
                ).
      end.
    end.
    assign
      v-row-counter = integer( truncate( ( length(tt-report.alc-type-name) / 56 ) , 0) + 1 )
    .
    if line-counter(out-stream) + v-row-counter - 1 > page-size(out-stream) then do:
      page stream out-stream.
    end.
    do v-i = 1 to v-row-counter :
      display stream out-stream
        v-alc-type-num          when v-i = 1
        substring( tt-report.alc-type-name , (v-i - 1) * 56 + 1 , 56 ) @ tt-report.alc-type-name
        tt-report.alc-type-code when v-i = 1
        tt-report.ost-begin     when v-i = 1
        tt-report.purchase      when v-i = 1
        tt-report.sell          when v-i = 1
        tt-report.ret           when v-i = 1
        tt-report.other         when v-i = 1
        tt-report.ras-total     when v-i = 1
        tt-report.ost-end       when v-i = 1
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
      with frame f-decl.
      down stream out-stream with frame f-decl.
    end.
    run alc04xl-sheet1-write-line-data in this-procedure
          ( input v-alc-type-num
          , input tt-report.alc-type-name
          , input tt-report.alc-type-code
          , input string( tt-report.ost-begin )
          , input string( tt-report.purchase  )
          , input string( tt-report.sell      )
          , input string( tt-report.ret       )
          , input string( tt-report.other     )
          , input string( tt-report.ras-total )
          , input string( tt-report.ost-end   )
          ).
    assign
      v-ost-begin-tot-qnty = v-ost-begin-tot-qnty + tt-report.ost-begin
      v-purchase-tot-qnty  = v-purchase-tot-qnty  + tt-report.purchase
      v-sell-tot-qnty      = v-sell-tot-qnty      + tt-report.sell
      v-ret-tot-qnty       = v-ret-tot-qnty       + tt-report.ret
      v-other-tot-qnty     = v-other-tot-qnty     + tt-report.other
      v-ras-tot-qnty       = v-ras-tot-qnty       + tt-report.ras-total
      v-ost-end-tot-qnty   = v-ost-end-tot-qnty   + tt-report.ost-end
      v-subsection    = v-subsection + 1
      v-alc-type-num  = substitute( "&1.&2" , v-section , v-subsection )
    .
  end.
  if line-counter(out-stream) + 2 > page-size(out-stream) then do:
    page stream out-stream.
  end.
  put stream out-stream v-line format "X(197)" skip.
  display stream out-stream
      "ИТОГО по видам"      @ tt-report.alc-type-name
      v-ost-begin-tot-qnty  @ tt-report.ost-begin
      v-purchase-tot-qnty   @ tt-report.purchase
      v-sell-tot-qnty       @ tt-report.sell
      v-ret-tot-qnty        @ tt-report.ret
      v-other-tot-qnty      @ tt-report.other
      v-ras-tot-qnty        @ tt-report.ras-total
      v-ost-end-tot-qnty    @ tt-report.ost-end
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
  with frame f-decl.
  put stream out-stream v-line format "X(197)" skip.
  run alc04xl-write-cell-data in this-procedure ( input "Декларация_it_ostbegin":U, input v-ost-begin-tot-qnty ).
  run alc04xl-write-cell-data in this-procedure ( input "Декларация_it_purchase":U, input v-purchase-tot-qnty  ).
  run alc04xl-write-cell-data in this-procedure ( input "Декларация_it_sell":U, input v-sell-tot-qnty      ).
  run alc04xl-write-cell-data in this-procedure ( input "Декларация_it_ret":U, input v-ret-tot-qnty       ).
  run alc04xl-write-cell-data in this-procedure ( input "Декларация_it_other":U, input v-other-tot-qnty     ).
  run alc04xl-write-cell-data in this-procedure ( input "Декларация_it_rastotal":U, input v-ras-tot-qnty       ).
  run alc04xl-write-cell-data in this-procedure ( input "Декларация_it_ostend":U, input v-ost-end-tot-qnty   ).
end.
end procedure.
procedure print-header :
do
on error undo, return error return-value
:
  run fmtcli-get-client in this-procedure
            ( input  'орг':U
            , input  v-host-code
            ) .
  put stream out-stream
      v-fmtcli-name skip
      "ИНН " v-fmtcli-inn skip
      "КПП " v-fmtcli-kpp skip
      "Декларация" at 93 skip
      "о розничной продаже алкогольной продукции" at 80 skip
      "дал." at 190 skip
  "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------":U skip
  ": №  :  Наименование вида продукции                           : Код   : Остаток на на-  : Объем закупки   :                                  Расход                               : Остаток на конец:":U skip
  ": п/п:                                                        : вида  : чало отчетного  :                 :-----------------------------------------------------------------------: отчетного пери- :":U skip
  ":    :                                                        :продук-: периода         :                 :    Розничная    :     Возврат     :     Прочий      :      Всего      : ода             :":U skip
  ":    :                                                        :ции    :                 :                 :     продажа     :    продукции    :     расход      :                 :                 :":U skip
  .
  run alc04xl-write-cell-data in this-procedure ( input "firmname":U, input v-fmtcli-name ).
  run alc04xl-write-cell-data in this-procedure ( input "inn":U, input v-fmtcli-inn ).
  run alc04xl-write-cell-data in this-procedure ( input "kpp":U, input v-fmtcli-kpp ).
end.
end procedure.
procedure print-footer :
do
on error undo, return error return-value
:
  put stream out-stream
  "* - вермуты, плодово-виноградные вина, фруктово-виноградные вина, сидры, медовые вина и др.":U at 3 skip(2)
  "Руководитель" at 3 "____________________" at 40 "____________________" at 70 skip
  "(подпись)" at 45 "(ф.и.о.)" at 78  skip(1)
  "Главный бухгалтер" at 3 "____________________" at 40 "____________________" at 70  skip
  "(подпись)" at 45 "(ф.и.о.)" at 78  skip(1)
  "Уполномоченный" at 3 skip
  "представитель" at 3 "____________________" at 40 "____________________" at 70 skip
  "(подпись)" at 45 "(ф.и.о.)" at 78  skip(1)
  "Исполнитель" at 3 "________________________________________" at 40 skip(1)
  "Телефон" at 3 "________________________________________" at 40 skip(1)
  "Дата" at 3 "________________________________________" at 40 skip(1)
  .
end.
end procedure.
