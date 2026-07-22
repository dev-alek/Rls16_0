block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: alcdcl06.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/alcdcl06.p $":U .
define variable vss-description as character no-undo init "Декларация об объемах розничной продажи алкогольной продукции (Нижегородская область)".
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
define variable vss-include-info10 as character format "X(65)" no-undo
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
def var vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-prg-bar_cb-handle     as handle             no-undo .
  procedure prg-bar_init-cb-handle :
    define input  parameter p-cb-handle as handle    no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle( p-cb-handle )
    then do:
      assign
        v-prg-bar_cb-handle = p-cb-handle
      .
    end.
    else do:
      assign
        v-prg-bar_cb-handle = ?
      .
    end.
  end.
  end procedure.
  procedure prg-bar_new :
    define input  parameter p-min as int64   no-undo .
    define input  parameter p-max as int64   no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_new-progress-bar in v-prg-bar_cb-handle ( input p-min , input p-max ).
    end.
  end.
  end procedure.
  procedure prg-bar_delete :
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_delete-progress-bar in v-prg-bar_cb-handle .
    end.
  end.
  end procedure.
  procedure prg-bar_show :
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_show-progress-bar in v-prg-bar_cb-handle .
    end.
  end.
  end procedure.
  procedure prg-bar_increment :
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_increment-progress-bar in v-prg-bar_cb-handle.
    end.
  end.
  end procedure.
  procedure prg-bar_title :
    define input  parameter p-str as character no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_title-progress-bar in v-prg-bar_cb-handle ( input p-str ) .
    end.
  end.
  end procedure.
  procedure prg-bar_stepto :
    define input  parameter p-val as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_stepto-progress-bar in v-prg-bar_cb-handle ( input p-val ) .
    end.
  end.
  end procedure.
def var vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable g#report-num   as integer no-undo .
run get-report-num in my-handle (output g#report-num).
define variable vss-include-info19 as character format "X(65)" no-undo
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
    field npp           as character
    field alctypename   as character
    field alctypecode   as character
    field cliname       as character
    field cliinn        as character
    field cliaddress    as character
    field licnum        as character
    field licgive       as character
    field quantity      as character
index pi is primary unique
        xl-line-id
.
define temp-table temp_sheet2_line-data no-undo
    field sheet-name    as character
    field xl-line-id    as integer
    field npp2          as character
    field alctypename2  as character
    field alctypecode2  as character
    field ostbeg2       as character
    field pritot2       as character
    field proprod2      as character
    field proiorg2      as character
    field saletot2      as character
    field salelocprod2  as character
    field ostend2       as character
index pi is primary unique
        xl-line-id
.
define variable v-alc06xl-sheet1-cur-data-row  as integer      no-undo.
define variable v-alc06xl-sheet2-cur-data-row  as integer      no-undo.
define variable v-alc06xl-cell-file-name       as character    no-undo.
define variable v-alc06xl-data-file-name       as character    no-undo.
procedure alc06xl-init :
do
on error undo, return error
:
    assign
        v-alc06xl-sheet1-cur-data-row = 0
        v-alc06xl-sheet2-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-alc06xl-data-file-name
    ).
    output stream excel-line to value( v-alc06xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-alc06xl-cell-file-name
    ).
    output stream excel-cell to value( v-alc06xl-cell-file-name ).
    run alc06xl-write-cell-data in this-procedure (
          input "sheetList":U
        , input "Закупка,Продажа":U
    ).
    if printrubl
    then do:
        run alc06xl-write-cell-data in this-procedure (
              input "Закупка_valutCode":U
            , input "0":U
        ).
    end.
    else do:
        run alc06xl-write-cell-data in this-procedure (
              input "Закупка_valutCode":U
            , input "1":U
        ).
    end.
    run alc06xl-write-cell-data in this-procedure (
          input "Закупка_columnList":U
        , input "npp,alctypename,alctypecode,cliname,cliinn,cliaddress,licnum,licgive,quantity":U
    ).
    run alc06xl-write-cell-data in this-procedure (
          input "Закупка_columnType":U
        , input "S,S,S,S,S,S,S,S,S":U
    ).
    run alc06xl-write-cell-data in this-procedure (
          input "Закупка_subtotalList":U
        , input "":U
    ).
    run alc06xl-write-cell-data in this-procedure (
          input "Закупка_subtotalType":U
        , input "":U
    ).
    if printrubl
    then do:
        run alc06xl-write-cell-data in this-procedure (
              input "Продажа_valutCode":U
            , input "0":U
        ).
    end.
    else do:
        run alc06xl-write-cell-data in this-procedure (
              input "Продажа_valutCode":U
            , input "1":U
        ).
    end.
    run alc06xl-write-cell-data in this-procedure (
          input "Продажа_columnList":U
        , input "npp2,alctypename2,alctypecode2,ostbeg2,pritot2,proprod2,proiorg2,saletot2,salelocprod2,ostend2":U
    ).
    run alc06xl-write-cell-data in this-procedure (
          input "Продажа_columnType":U
        , input "S,S,S,S,S,S,S,S,S,S":U
    ).
    run alc06xl-write-cell-data in this-procedure (
          input "Продажа_subtotalList":U
        , input "":U
    ).
    run alc06xl-write-cell-data in this-procedure (
          input "Продажа_subtotalType":U
        , input "":U
    ).
end.
end procedure.
procedure alc06xl-sheet1-write-line-data :
  define input parameter p-npp           as character  no-undo .
  define input parameter p-alctypename   as character  no-undo .
  define input parameter p-alctypecode   as character  no-undo .
  define input parameter p-cliname       as character  no-undo .
  define input parameter p-cliinn        as character  no-undo .
  define input parameter p-cliaddress    as character  no-undo .
  define input parameter p-licnum        as character  no-undo .
  define input parameter p-licgive       as character  no-undo .
  define input parameter p-quantity      as character  no-undo .
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
        v-alc06xl-sheet1-cur-data-row         = v-alc06xl-sheet1-cur-data-row + 1
        buf_temp_sheet1_line-data.sheet-name  = "Закупка":U
        buf_temp_sheet1_line-data.xl-line-id  = v-alc06xl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.npp         = p-npp
        buf_temp_sheet1_line-data.alctypename = p-alctypename
        buf_temp_sheet1_line-data.alctypecode = p-alctypecode
        buf_temp_sheet1_line-data.cliname     = p-cliname
        buf_temp_sheet1_line-data.cliinn      = p-cliinn
        buf_temp_sheet1_line-data.cliaddress  = p-cliaddress
        buf_temp_sheet1_line-data.licnum      = p-licnum
        buf_temp_sheet1_line-data.licgive     = p-licgive
        buf_temp_sheet1_line-data.quantity    = p-quantity
    .
    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        CHR(9)   "DTA":U
        CHR(9)   buf_temp_sheet1_line-data.npp
        CHR(9)   buf_temp_sheet1_line-data.alctypename
        CHR(9)   buf_temp_sheet1_line-data.alctypecode
        CHR(9)   buf_temp_sheet1_line-data.cliname
        CHR(9)   buf_temp_sheet1_line-data.cliinn
        CHR(9)   buf_temp_sheet1_line-data.cliaddress
        CHR(9)   buf_temp_sheet1_line-data.licnum
        CHR(9)   buf_temp_sheet1_line-data.licgive
        CHR(9)   buf_temp_sheet1_line-data.quantity
        chr(10)
    .
end.
end procedure.
procedure alc06xl-sheet1-write-line-format :
define input parameter p-fmt-label       as character  no-undo.
    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    put stream excel-line unformatted
                        "Закупка":U
        CHR(9)   "FMT":U
        CHR(9)   p-fmt-label
        chr(10)
    .
end.
end procedure.
procedure alc06xl-sheet2-write-line-data :
  define input parameter p-npp2          as character   no-undo .
  define input parameter p-alctypename2  as character   no-undo .
  define input parameter p-alctypecode2  as character   no-undo .
  define input parameter p-ostbeg2       as character   no-undo .
  define input parameter p-pritot2       as character   no-undo .
  define input parameter p-proprod2      as character   no-undo .
  define input parameter p-proiorg2      as character   no-undo .
  define input parameter p-saletot2      as character   no-undo .
  define input parameter p-salelocprod2  as character   no-undo .
  define input parameter p-ostend2       as character   no-undo .
  define buffer buf_temp_sheet2_line-data  for temp_sheet2_line-data.
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
        v-alc06xl-sheet2-cur-data-row           = v-alc06xl-sheet2-cur-data-row + 1
        buf_temp_sheet2_line-data.sheet-name    = "Продажа":U
        buf_temp_sheet2_line-data.xl-line-id    = v-alc06xl-sheet2-cur-data-row
        buf_temp_sheet2_line-data.npp2          = p-npp2
        buf_temp_sheet2_line-data.alctypename2  = p-alctypename2
        buf_temp_sheet2_line-data.alctypecode2  = p-alctypecode2
        buf_temp_sheet2_line-data.ostbeg2       = p-ostbeg2
        buf_temp_sheet2_line-data.pritot2       = p-pritot2
        buf_temp_sheet2_line-data.proprod2      = p-proprod2
        buf_temp_sheet2_line-data.proiorg2      = p-proiorg2
        buf_temp_sheet2_line-data.saletot2      = p-saletot2
        buf_temp_sheet2_line-data.salelocprod2  = p-salelocprod2
        buf_temp_sheet2_line-data.ostend2       = p-ostend2
    .
    put stream excel-line unformatted
                        buf_temp_sheet2_line-data.sheet-name
        CHR(9)   "DTA":U
        CHR(9)   buf_temp_sheet2_line-data.npp2
        CHR(9)   buf_temp_sheet2_line-data.alctypename2
        CHR(9)   buf_temp_sheet2_line-data.alctypecode2
        CHR(9)   buf_temp_sheet2_line-data.ostbeg2
        CHR(9)   buf_temp_sheet2_line-data.pritot2
        CHR(9)   buf_temp_sheet2_line-data.proprod2
        CHR(9)   buf_temp_sheet2_line-data.proiorg2
        CHR(9)   buf_temp_sheet2_line-data.saletot2
        CHR(9)   buf_temp_sheet2_line-data.salelocprod2
        CHR(9)   buf_temp_sheet2_line-data.ostend2
        chr(10)
    .
end.
end procedure.
procedure alc06xl-sheet2-write-line-format :
define input parameter p-fmt-label       as character  no-undo.
    define buffer buf_temp_sheet2_line-data        for temp_sheet2_line-data.
do
for buf_temp_sheet2_line-data
on error undo, return error
:
    put stream excel-line unformatted
                        "Продажа":U
        CHR(9)   "FMT":U
        CHR(9)   p-fmt-label
        chr(10)
    .
end.
end procedure.
procedure alc06xl-write-cell-data :
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
procedure alc06xl-run-excel :
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
        v-Template-file-name    = search( "exe/alcdcl06.xlt" )
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
procedure alc06xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/alcdcl06.xlt":U.
        export "exe/t_form.bas":U.
        export v-alc06xl-cell-file-name.
        export v-alc06xl-data-file-name.
    output close.
end.
end procedure.
define stream out-stream .
define temp-table tt-gds no-undo like ub.goods
  field alc-type-inner-code like ub.alc-type.alc-type-inner-code
  field create-user-db-num  like ub.alc-type.create-user-db-num
  field alc-type-code       like ub.alc-type.alc-type-code
  field alc-type-name       like ub.alc-type.alc-type-name
  field gds-man-type        as integer
index pi is primary unique
  gds-code
index alc-type
  alc-type-inner-code
  create-user-db-num
index alc-type-code
  alc-type-code
.
define temp-table tt-alc-retail no-undo
  field alc-type-code like ub.alc-type.alc-type-code
  field alc-type-name like ub.alc-type.alc-type-name
  field ost-beg       as decimal
  field pri-prod      as decimal
  field pri-org       as decimal
  field pri-tot       as decimal
  field sale-loc-prod as decimal
  field sale-tot      as decimal
  field ost-end       as decimal
index pi is primary unique
  alc-type-code
.
define temp-table tt-alc-pri no-undo
  field cli-name        like ub.clients.obj-name
  field cli-type        like ub.clients.obj-type
  field cli-code        like ub.clients.obj-code
  field cli-inn         as character
  field cli-address     as character
  field lic-num         as character
  field lic-give        as character
  field alc-type-name   like ub.alc-type.alc-type-name
  field alc-type-code   like ub.alc-type.alc-type-code
  field quantity        as decimal
index pi is primary unique
  alc-type-code
  cli-type
  cli-code
index cli
  cli-type
  cli-code
  alc-type-code
.
define temp-table tt-alc-pri-tmp no-undo
  field cli-type            like ub.clients.obj-type
  field cli-code            like ub.clients.obj-code
  field alc-type-inner-code like ub.alc-type.alc-type-inner-code
  field alc-type-code       like ub.alc-type.alc-type-code
  field alc-type-name       like ub.alc-type.alc-type-name
  field doc-code            like ub.trn-doc.doc-code
  field gds-code            like ub.goods.gds-code
  field quantity            as decimal
index pi is primary unique
  alc-type-inner-code
  cli-type
  cli-code
  doc-code
  gds-code
index cli
  cli-type
  cli-code
  alc-type-code
.
define variable v-i                       as integer    no-undo .
define variable v-line                    as character  no-undo .
define variable v-par-type                as character  no-undo .
define variable v-begin-date              as date       no-undo .
define variable v-end-date                as date       no-undo .
define variable v-host-code               like ub.clients.host-code  no-undo .
define variable v-host-code-2             like ub.clients.host-code  no-undo .
define variable v-alc-type-count          as integer    no-undo .
define variable v-gds-count               as integer    no-undo .
define variable v-fact-order-start        as decimal    no-undo .
define variable v-fact-order-end          as decimal    no-undo .
define variable v-firm-name     as character no-undo .
define variable v-firm-inn      as character no-undo .
define variable v-firm-address  as character no-undo .
define variable v-obj-count     as character no-undo .
define variable v-lic-info      as character no-undo .
define variable v-activity      as character no-undo .
define variable v-date-range    as character no-undo .
main-block:
do
on error undo, return error return-value
:
if session :set-wait-state( "compiler" ) then.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      if thbjattr_thbj-attr.prop-code = 'ardecldt' then v-begin-date = thbjattr_thbj-attr.property-value-date .
  end.
  find first obj-list no-lock no-error .
  if not available obj-list then do:
    message
      "Нет ни одного объекта для формирования отчета!"
    view-as alert-box error.
    return error return-value.
  end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  obj-list.obj-type
  ,input  obj-list.obj-code
  ,output v-host-code
  )  .
  for each obj-list :
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run alc06xl-init in this-procedure .
output stream out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
  put stream out-stream "Отчет выводится только в Excel..." skip.
  assign
    v-end-date    = x-Date-Alone
    v-line        = fill( "-" , 300 )
  .
  run day-begin-fact-order in this-procedure ( input v-begin-date, output v-fact-order-start ).
  run day-begin-fact-order in this-procedure ( input ( v-end-date + 1 ),   output v-fact-order-end ).
  run clear-all in this-procedure .
  run prg-bar_init-cb-handle in this-procedure (v-d-report-handle) .
  run find-alc-goods in this-procedure ( output v-gds-count ).
  run fill-tt-alc-pri in this-procedure .
  run fill-tt-alc-retail in this-procedure .
  run load-head-info in this-procedure .
  run print-alc-pri in this-procedure .
  run print-alc-retail in this-procedure .
  output stream out-stream close.
  if Make-Excel then output stream ForExcel close.
  run alc06xl-close in this-procedure .
if session :set-wait-state( "" ) then.
  run clear-all in this-procedure .
  os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
    value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
  .
  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
  run gbl/prnfilen.w
      (input  ""
      ,input  20
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
  empty temp-table tt-alc-pri.
  empty temp-table tt-alc-pri-tmp.
  empty temp-table tt-alc-retail.
end.
end procedure.
procedure find-alc-goods :
  define output parameter p-gds-count as integer   no-undo .
do
on error undo, return error return-value
:
  define buffer buf_alc-type      for ub.alc-type.
  define buffer buf_alc-type-gds  for ub.alc-type-gds.
  define buffer buf_goods         for ub.goods.
  define variable v-gds-type as integer   no-undo .
  empty temp-table tt-gds.
  for each buf_alc-type no-lock
        where buf_alc-type.alc-type-status = 0
  :
    _gds:
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
          v-alc-type-count           = v-alc-type-count + 1
          p-gds-count                = p-gds-count + 1
        .
      end.
    end.
  end.
end.
end procedure.
procedure fill-tt-alc-pri :
do
on error undo, return error return-value
:
  define buffer buf_doc-line    for ub.doc-line.
  define buffer buf_trn-doc     for ub.trn-doc.
  define buffer buf_parts       for ub.parts.
  define buffer buf_clients     for ub.clients.
  define buffer buf_tt-gds          for tt-gds.
  define buffer buf_tt-alc-pri      for tt-alc-pri.
  define buffer buf_tt-alc-pri-tmp  for tt-alc-pri-tmp.
  define variable v-sert            as character no-undo .
  define variable v-sert-give       as character no-undo .
  run prg-bar_new in this-procedure (1 , v-gds-count).
  run prg-bar_title in this-procedure ( input substitute( "Обработка документов типа: &1...":U
                                                        ,
                                                        entry(lookup('ie':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U), 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U)
                                                        )
                                      ).
  run prg-bar_show in this-procedure .
  for each buf_tt-gds
  :
    run prg-bar_increment in this-procedure .
    for each obj-list no-lock
    :
      for each buf_doc-line no-lock
        where buf_doc-line.artic        = buf_tt-gds.artic
          and buf_doc-line.prod-type    = buf_tt-gds.prod-type
          and buf_doc-line.prod-code    = buf_tt-gds.prod-code
          and buf_doc-line.obj-type     = obj-list.obj-type
          and buf_doc-line.obj-code     = obj-list.obj-code
          and buf_doc-line.status_      = 'факт':U
          and buf_doc-line.ext-doc-type = 'ie':U
          and buf_doc-line.fact-order   >= v-fact-order-start
          and buf_doc-line.fact-order   <  v-fact-order-end,
        first buf_trn-doc no-lock
          where buf_trn-doc.doc-code    = buf_doc-line.doc-code
      :
        find first buf_tt-alc-pri-tmp
          where buf_tt-alc-pri-tmp.alc-type-inner-code = buf_tt-gds.alc-type-inner-code
            and buf_tt-alc-pri-tmp.cli-type            = buf_trn-doc.cli-type
            and buf_tt-alc-pri-tmp.cli-code            = buf_trn-doc.cli-code
            and buf_tt-alc-pri-tmp.doc-code            = buf_trn-doc.doc-code
            and buf_tt-alc-pri-tmp.gds-code            = buf_tt-gds.gds-code
        no-error .
        if not available buf_tt-alc-pri-tmp
        then do:
          create buf_tt-alc-pri-tmp.
          assign
            buf_tt-alc-pri-tmp.alc-type-inner-code  = buf_tt-gds.alc-type-inner-code
            buf_tt-alc-pri-tmp.alc-type-code        = buf_tt-gds.alc-type-code
            buf_tt-alc-pri-tmp.alc-type-name        = buf_tt-gds.alc-type-name
            buf_tt-alc-pri-tmp.cli-type             = buf_trn-doc.cli-type
            buf_tt-alc-pri-tmp.cli-code             = buf_trn-doc.cli-code
            buf_tt-alc-pri-tmp.doc-code             = buf_trn-doc.doc-code
            buf_tt-alc-pri-tmp.gds-code             = buf_tt-gds.gds-code
            buf_tt-alc-pri-tmp.quantity             = ( buf_doc-line.fact-qnty * buf_tt-gds.ms-base / 10 )
          .
        end.
      end.
    end.
  end.
  run prg-bar_delete in this-procedure .
  run calc-ext-type-pri in this-procedure ( input 'iv':U    ) .
  run calc-ext-type-pri in this-procedure ( input 'rv':U) .
  for each buf_tt-alc-pri-tmp
    break by buf_tt-alc-pri-tmp.cli-type
          by buf_tt-alc-pri-tmp.cli-code
          by buf_tt-alc-pri-tmp.alc-type-code
  :
    find first buf_tt-alc-pri
      where buf_tt-alc-pri.alc-type-code  = buf_tt-alc-pri-tmp.alc-type-code
        and buf_tt-alc-pri.cli-type       = buf_tt-alc-pri-tmp.cli-type
        and buf_tt-alc-pri.cli-code       = buf_tt-alc-pri-tmp.cli-code
    no-error .
    if    first-of(buf_tt-alc-pri-tmp.cli-type)
      or  first-of(buf_tt-alc-pri-tmp.cli-code)
      or  first-of(buf_tt-alc-pri-tmp.alc-type-code)
    then do:
      if     first-of(buf_tt-alc-pri-tmp.cli-type)
         or  first-of(buf_tt-alc-pri-tmp.cli-code)
      then do:
        run fmtcli-get-client in this-procedure ( input buf_tt-alc-pri-tmp.cli-type, input buf_tt-alc-pri-tmp.cli-code ) .
        run find-sert in this-procedure ( input buf_tt-alc-pri-tmp.cli-type
                                        , input buf_tt-alc-pri-tmp.cli-code
                                        , input buf_tt-alc-pri-tmp.alc-type-inner-code
                                        , output v-sert
                                        , output v-sert-give ) .
      end.
      if not available buf_tt-alc-pri
      then do:
        create buf_tt-alc-pri.
        assign
          buf_tt-alc-pri.alc-type-code  = buf_tt-alc-pri-tmp.alc-type-code
          buf_tt-alc-pri.alc-type-name  = buf_tt-alc-pri-tmp.alc-type-name
          buf_tt-alc-pri.cli-type       = buf_tt-alc-pri-tmp.cli-type
          buf_tt-alc-pri.cli-code       = buf_tt-alc-pri-tmp.cli-code
          buf_tt-alc-pri.cli-name       = v-fmtcli-name
          buf_tt-alc-pri.cli-inn        = v-fmtcli-inn
          buf_tt-alc-pri.cli-address    = v-fmtcli-addres
          buf_tt-alc-pri.lic-num        = v-sert
          buf_tt-alc-pri.lic-give       = v-sert-give
        .
      end.
    end.
    assign
      buf_tt-alc-pri.quantity = buf_tt-alc-pri.quantity + buf_tt-alc-pri-tmp.quantity
    .
  end.
end.
end procedure.
procedure calc-ext-type-pri :
  define input  parameter p-ext-doc-type as character no-undo .
do
on error undo, return error return-value
:
  define buffer buf_doc-line  for ub.doc-line .
  define buffer buf_parts     for ub.parts .
  define buffer buf_trn-doc   for ub.trn-doc .
  define buffer sch_trn-doc   for ub.trn-doc.
  define buffer buf_obj-list        for obj-list.
  define buffer buf_tt-gds          for tt-gds.
  define buffer buf_tt-alc-pri-tmp  for tt-alc-pri-tmp.
  define variable v-income-doc-code as character no-undo .
  define variable v-ext-doc-type    like ub.parts-attr.ext-doc-type no-undo .
  define variable v-obj-type        like ub.parts-attr.obj-type     no-undo .
  define variable v-obj-code        like ub.parts-attr.obj-code     no-undo .
  define variable v-supp-type       like ub.parts-attr.supp-type    no-undo .
  define variable v-supp-code       like ub.parts-attr.supp-code    no-undo .
  define variable v-fact-order      like ub.parts-attr.fact-order   no-undo .
  run prg-bar_new in this-procedure (1 , v-gds-count).
  run prg-bar_title in this-procedure ( input substitute( "Обработка документов типа: &1...":U
                                                        ,
                                                        entry(lookup(p-ext-doc-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U), 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U)
                                                        )
                                      ).
  run prg-bar_show in this-procedure .
  for each buf_tt-gds
  :
    run prg-bar_increment in this-procedure .
    for each obj-list no-lock
    :
      for each buf_doc-line no-lock
        where buf_doc-line.artic      = buf_tt-gds.artic
          and buf_doc-line.prod-type  = buf_tt-gds.prod-type
          and buf_doc-line.prod-code  = buf_tt-gds.prod-code
          and buf_doc-line.obj-type   = obj-list.obj-type
          and buf_doc-line.obj-code   = obj-list.obj-code
          and buf_doc-line.status_    = 'факт':U
          and buf_doc-line.ext-doc-type = p-ext-doc-type
          and buf_doc-line.fact-order >= v-fact-order-start
          and buf_doc-line.fact-order <  v-fact-order-end
      :
          parts-cycle:
          for each buf_parts no-lock
            where buf_parts.out-code  = buf_doc-line.doc-code
              and buf_parts.obj-type  = obj-list.obj-type
              and buf_parts.obj-code  = obj-list.obj-code
              and buf_parts.artic     = buf_doc-line.artic
              and buf_parts.prod-type = buf_doc-line.prod-type
              and buf_parts.prod-code = buf_doc-line.prod-code
          :
            run find-income-doc-code in this-procedure ( input buf_parts.in-code
                                                      , input buf_tt-gds.gds-code
                                                      , input buf_parts.part-code
                                                      , output v-income-doc-code
                                                       , output v-ext-doc-type
                                                       , output v-fact-order
                                                       , output v-obj-type
                                                       , output v-obj-code
                                                       , output v-supp-type
                                                       , output v-supp-code
                                                      ).
            if v-income-doc-code = ?
            then do:
              message
                substitute("Не могу найти приходную накладную с номером: &1", buf_parts.in-code) skip
                "Отчет будет сформирован некорректно":U
              view-as alert-box error .
              next parts-cycle.
            end.
            if    v-ext-doc-type = 'ie':U
              and v-fact-order   >= v-fact-order-start
              and v-fact-order   <  v-fact-order-end
            then do:
              find first buf_obj-list no-lock
                where buf_obj-list.obj-type = v-obj-type
                  and buf_obj-list.obj-code = v-obj-code
              no-error .
              if available buf_obj-list then do :
                next parts-cycle.
              end.
            end.
            find first buf_tt-alc-pri-tmp
              where buf_tt-alc-pri-tmp.alc-type-inner-code = buf_tt-gds.alc-type-inner-code
                and buf_tt-alc-pri-tmp.cli-type            = v-supp-type
                and buf_tt-alc-pri-tmp.cli-code            = v-supp-code
                and buf_tt-alc-pri-tmp.doc-code            = v-income-doc-code
                and buf_tt-alc-pri-tmp.gds-code            = buf_tt-gds.gds-code
            no-error .
            if not available buf_tt-alc-pri-tmp
            then do:
              create buf_tt-alc-pri-tmp.
              assign
                buf_tt-alc-pri-tmp.alc-type-inner-code = buf_tt-gds.alc-type-inner-code
                buf_tt-alc-pri-tmp.alc-type-code       = buf_tt-gds.alc-type-code
                buf_tt-alc-pri-tmp.alc-type-name        = buf_tt-gds.alc-type-name
                buf_tt-alc-pri-tmp.cli-type            = v-supp-type
                buf_tt-alc-pri-tmp.cli-code            = v-supp-code
                buf_tt-alc-pri-tmp.doc-code            = v-income-doc-code
                buf_tt-alc-pri-tmp.gds-code            = buf_tt-gds.gds-code
              .
            end.
            assign
              buf_tt-alc-pri-tmp.quantity = buf_tt-alc-pri-tmp.quantity + ( buf_parts.fact-qnty * buf_tt-gds.ms-base / 10 )
            .
          end.
      end.
    end.
  end.
  run prg-bar_delete in this-procedure .
end.
end procedure.
procedure find-income-doc-code :
  define input  parameter p-in-code         like ub.parts.in-code           no-undo .
  define input  parameter p-gds-code        like ub.goods.gds-code          no-undo .
  define input  parameter p-part-code       like ub.parts.part-code         no-undo .
  define output parameter p-income-doc-code like ub.parts.in-code           no-undo .
  define output parameter p-ext-doc-type    like ub.parts-attr.ext-doc-type no-undo .
  define output parameter p-fact-order      like ub.parts-attr.fact-order   no-undo .
  define output parameter p-obj-type        like ub.parts-attr.obj-type     no-undo .
  define output parameter p-obj-code        like ub.parts-attr.obj-code     no-undo .
  define output parameter p-supp-type       like ub.parts-attr.supp-type    no-undo .
  define output parameter p-supp-code       like ub.parts-attr.supp-code    no-undo .
define buffer buf_parts-attr        for ub.parts-attr .
define buffer buf_income_parts-attr for ub.parts-attr .
do on error undo, return error return-value :
  assign
    p-income-doc-code = ?
    p-ext-doc-type    = ?
    p-fact-order      = ?
    p-obj-type        = ?
    p-obj-code        = ?
    p-supp-type       = ?
    p-supp-code       = ?
  .
  find first buf_parts-attr no-lock
    where buf_parts-attr.in-code   = p-in-code
      and buf_parts-attr.gds-code  = p-gds-code
      and buf_parts-attr.part-code = p-part-code
  no-error .
  if available buf_parts-attr
  then do:
    find first buf_income_parts-attr no-lock
      where buf_income_parts-attr.in-code   = buf_parts-attr.income-in-code
        and buf_income_parts-attr.gds-code  = buf_parts-attr.income-gds-code
        and buf_income_parts-attr.part-code = buf_parts-attr.income-part-code
      no-error .
    if available buf_income_parts-attr
    then do:
      assign
        p-income-doc-code = buf_parts-attr.income-in-code
        p-ext-doc-type    = buf_parts-attr.ext-doc-type
        p-fact-order      = buf_parts-attr.fact-order
        p-obj-type        = buf_parts-attr.obj-type
        p-obj-code        = buf_parts-attr.obj-code
        p-supp-type       = buf_parts-attr.supp-type
        p-supp-code       = buf_parts-attr.supp-code
      .
    end.
    else do:
      return .
    end.
  end.
  else do:
    return .
  end.
end.
end procedure.
procedure find-sert :
  define input  parameter p-cli-type            like ub.trn-doc.cli-type no-undo .
  define input  parameter p-cli-code            like ub.trn-doc.cli-code no-undo .
  define input  parameter p-alc-type-inner-code like ub.alc-type.alc-type-inner-code no-undo .
  define output parameter p-sert      as character          no-undo .
  define output parameter p-sert-give as character          no-undo .
define buffer buf_alc-supp-lic      for ub.alc-supp-lic.
define buffer buf_alc-supp-lic-type for ub.alc-supp-lic-type.
do
on error undo, return error return-value
:
  assign
    p-sert       = "":U
    p-sert-give  = "":U
  .
  for each buf_alc-supp-lic no-lock
    where buf_alc-supp-lic.cli-type = p-cli-type
      and buf_alc-supp-lic.cli-code = p-cli-code
      and buf_alc-supp-lic.date-to  > v-end-date
  :
    if buf_alc-supp-lic.all-type = 0
    then do:
      find first buf_alc-supp-lic-type no-lock
        where buf_alc-supp-lic-type.alc-supp-lic-code   = buf_alc-supp-lic.alc-supp-lic-code
          and buf_alc-supp-lic-type.alc-type-inner-code = p-alc-type-inner-code
      no-error.
      if not available buf_alc-supp-lic-type
      then do:
          next.
      end.
    end.
    assign
      p-sert       =  substitute( "&1 &2 от &3"
                                , buf_alc-supp-lic.seria
                                , buf_alc-supp-lic.number
                                , buf_alc-supp-lic.date-from
                                )
      p-sert-give  = substitute( "&1" , buf_alc-supp-lic.who-are-got )
    .
    return.
  end.
end.
end procedure.
procedure fill-tt-alc-retail :
do
on error undo, return error return-value
:
  define buffer buf_alc-type  for ub.alc-type.
  define buffer buf_ot-line   for ub.ot-line.
  define buffer buf_trn-doc   for ub.trn-doc.
  define buffer sch_trn-doc   for ub.trn-doc.
  define buffer buf_parts     for ub.parts.
  define buffer buf_tt-gds        for tt-gds.
  define buffer buf_obj-list      for obj-list.
  define buffer buf_tt-alc-retail for tt-alc-retail.
  define variable var-x-store-code    like ub.clients.obj-code    no-undo.
  define variable var-x-store-type    like ub.clients.obj-type    no-undo.
  define variable var-x-date-start    like ub.stk-tot.Fact-date   no-undo.
  define variable var-x-date-endt     like ub.stk-tot.Fact-date   no-undo.
  define variable var-x-sum-type      like ub.stk-tot.sum-type    no-undo.
  define variable var-x-ost-sum-type  like ub.stk-tot.sum-type    no-undo.
  define variable var-x-cat-id        like ub.stk-tot.cat-id      no-undo.
  define variable var-xTog-obj        as   logical             no-undo.
  define variable var-x-artic         like ub.stk-line.artic        no-undo.
  define variable var-x-prod-code     like ub.stk-line.prod-code    no-undo.
  define variable var-x-prod-type     like ub.stk-line.prod-type    no-undo.
  define variable var-Quantity        like ub.stk-tot.fact-qnty   initial ? no-undo.
  define variable var-Coast_R         like ub.stk-tot.sum-rubl    no-undo.
  define variable var-Coast_V         like ub.stk-tot.sum-rubl    no-undo.
  define variable var-VAT_R           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-VAT_V           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-SLT_R           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-SLT_V           like ub.stk-tot.sum-rubl    no-undo.
  define variable v-ost-begin-qnty          as decimal               no-undo .
  define variable v-ost-end-qnty            as decimal               no-undo .
  define variable v-ot-line-qnty            as decimal               no-undo .
  define variable v-parts-line-qnty         as decimal               no-undo .
  define variable v-retail-ost-beg          as decimal               no-undo .
  define variable v-retail-pri-prod         as decimal               no-undo .
  define variable v-retail-pri-org          as decimal               no-undo .
  define variable v-retail-pri-tot          as decimal               no-undo .
  define variable v-retail-sale-loc-prod    as decimal               no-undo .
  define variable v-retail-sale-tot         as decimal               no-undo .
  define variable v-retail-ost-end          as decimal               no-undo .
  define variable v-income-doc-code         as character             no-undo .
  define variable v-ext-doc-type    like ub.parts-attr.ext-doc-type  no-undo .
  define variable v-obj-type        like ub.parts-attr.obj-type      no-undo .
  define variable v-obj-code        like ub.parts-attr.obj-code      no-undo .
  define variable v-supp-type       like ub.parts-attr.supp-type     no-undo .
  define variable v-supp-code       like ub.parts-attr.supp-code     no-undo .
  define variable v-fact-order      like ub.parts-attr.fact-order    no-undo .
  define variable v-attr-val                as character             no-undo .
  define variable v-attr-type               as character             no-undo .
  define variable v-is-local-producer       as logical               no-undo .
  run prg-bar_new in this-procedure (1 , v-gds-count).
  run prg-bar_title in this-procedure ( input "Обработка...":U ).
  run prg-bar_show in this-procedure .
  for each buf_alc-type no-lock
        where buf_alc-type.alc-type-status = 0
  :
    find first buf_tt-alc-retail
      where buf_tt-alc-retail.alc-type-code = buf_alc-type.alc-type-code
    no-error .
    if not available buf_tt-alc-retail
    then do:
      create buf_tt-alc-retail.
      assign
        buf_tt-alc-retail.alc-type-code = buf_alc-type.alc-type-code
        buf_tt-alc-retail.alc-type-name = buf_alc-type.alc-type-name
      .
    end.
    assign
      v-ost-begin-qnty        = 0
      v-ost-end-qnty          = 0
      v-ot-line-qnty          = 0
      v-retail-ost-beg        = 0
      v-retail-pri-prod       = 0
      v-retail-pri-org        = 0
      v-retail-pri-tot        = 0
      v-retail-sale-loc-prod  = 0
      v-retail-sale-tot       = 0
      v-retail-ost-end        = 0
    .
    for each buf_tt-gds
      where buf_tt-gds.alc-type-inner-code = buf_alc-type.alc-type-inner-code
        and buf_tt-gds.create-user-db-num  = buf_alc-type.create-user-db-num
    :
      run prg-bar_increment in this-procedure .
      run clntattr-value in this-procedure  ( input buf_tt-gds.prod-type
                                            , input buf_tt-gds.prod-code
                                            , input 'cli-local':U
                                            , output v-attr-val
                                            , output v-attr-type
                                            ).
      assign
        v-is-local-producer = logical(v-attr-val)
      no-error .
      if error-status :error
      then do:
        assign
          v-is-local-producer = false
        .
      end.
      for each obj-list
      :
        assign
          var-x-store-code    = obj-list.obj-code
          var-x-store-type    = obj-list.obj-type
          var-x-artic         = buf_tt-gds.artic
          var-x-prod-code     = buf_tt-gds.prod-code
          var-x-prod-type     = buf_tt-gds.prod-type
          var-x-cat-id        = '##,##':U
          var-xTog-obj        = yes
          v-ost-begin-qnty    = 0
          v-ost-end-qnty      = 0
          var-x-sum-type      = 'cost':U
          var-x-ost-sum-type  = 'cost':U
        .
        run ost-line  (
            input   var-x-store-code    ,
            input   var-x-store-type    ,
            INPUT   var-x-artic         ,
            INPUT   var-x-prod-code     ,
            INPUT   var-x-prod-type     ,
            input   no                  ,
            input   v-fact-order-start  ,
            input   var-x-ost-sum-type  ,
            input   var-x-cat-id        ,
            input   var-xTog-obj        ,
            output  var-Quantity        ,
            output  var-Coast_R         ,
            output  var-Coast_V         ,
            output  var-VAT_R           ,
            output  var-VAT_V           ,
            output  var-SLT_R           ,
            output  var-SLT_V           ).
        assign
          v-ost-begin-qnty = ( var-Quantity * buf_tt-gds.ms-base ) / 10
        .
        run ost-line  (
            input   var-x-store-code    ,
            input   var-x-store-type    ,
            INPUT   var-x-artic         ,
            INPUT   var-x-prod-code     ,
            INPUT   var-x-prod-type     ,
            input   no                  ,
            input   v-fact-order-end    ,
            input   var-x-ost-sum-type  ,
            input   var-x-cat-id        ,
            input   var-xTog-obj        ,
            output  var-Quantity        ,
            output  var-Coast_R         ,
            output  var-Coast_V         ,
            output  var-VAT_R           ,
            output  var-VAT_V           ,
            output  var-SLT_R           ,
            output  var-SLT_V           ).
        assign
          v-ost-end-qnty = ( var-Quantity * buf_tt-gds.ms-base ) / 10
        .
        ot-line-cycle:
        for each buf_ot-line no-lock
          where buf_ot-line.artic        = buf_tt-gds.artic
            and buf_ot-line.prod-code    = buf_tt-gds.prod-code
            and buf_ot-line.prod-type    = buf_tt-gds.prod-type
            and buf_ot-line.fact-order   < v-fact-order-end
            and buf_ot-line.fact-order   >= v-fact-order-start
            and buf_ot-line.obj-code     = obj-list.obj-code
            and buf_ot-line.obj-type     = obj-list.obj-type
            and buf_ot-line.sum-type     = var-x-sum-type
        :
          find first buf_trn-doc no-lock
            where buf_trn-doc.doc-code = buf_ot-line.doc-code
          no-error .
          if not available buf_trn-doc then do:
            message
              vss-workfile vss-revision vss-description skip
              substitute( "Не найден складской документ &1.&2Документ не будет учтен в отчете." , buf_ot-line.doc-code , chr(10) )
            view-as alert-box error .
            next ot-line-cycle.
          end.
          assign
            v-ot-line-qnty  = abs( buf_ot-line.fact-qnty * buf_tt-gds.ms-base ) / 10
          .
          case buf_ot-line.ext-doc-type
          :
            when 'ie':U  then do :
              if ( buf_trn-doc.cli-type = buf_tt-gds.prod-type ) and
                 ( buf_trn-doc.cli-code = buf_tt-gds.prod-code )
              then do:
                assign
                  v-retail-pri-prod = v-retail-pri-prod + v-ot-line-qnty
                .
              end.
              else do:
                assign
                  v-retail-pri-org = v-retail-pri-org + v-ot-line-qnty
                .
              end.
              assign
                v-retail-pri-tot = v-retail-pri-tot + v-ot-line-qnty
              .
            end.
            when 'iv':U     or
            when 'rv':U
            then do :
              _buf_parts:
              for each buf_parts no-lock
                    where buf_parts.out-code  = buf_ot-line.doc-code
                      and buf_parts.obj-type  = buf_ot-line.obj-type
                      and buf_parts.obj-code  = buf_ot-line.obj-code
                      and buf_parts.artic     = buf_ot-line.artic
                      and buf_parts.prod-type = buf_ot-line.prod-type
                      and buf_parts.prod-code = buf_ot-line.prod-code
              :
                run find-income-doc-code in this-procedure ( input buf_parts.in-code
                                                           , input buf_tt-gds.gds-code
                                                           , input buf_parts.part-code
                                                           , output v-income-doc-code
                                                           , output v-ext-doc-type
                                                           , output v-fact-order
                                                           , output v-obj-type
                                                           , output v-obj-code
                                                           , output v-supp-type
                                                           , output v-supp-code
                                                           ).
                if v-income-doc-code = ?
                then do:
                  message
                    substitute("Не могу найти приходную накладную с номером: &1", buf_parts.in-code) skip
                    "Отчет будет сформирован некорректно":U
                  view-as alert-box error .
                  next _buf_parts.
                end.
                assign
                  v-parts-line-qnty = ( buf_parts.fact-qnty * buf_tt-gds.ms-base ) / 10
                .
                if    v-ext-doc-type = 'ie':U
                  and v-fact-order   >= v-fact-order-start
                  and v-fact-order   <= v-fact-order-end
                then do:
                  find first buf_obj-list no-lock
                    where buf_obj-list.obj-type = v-obj-type
                      and buf_obj-list.obj-code = v-obj-code
                  no-error .
                  if available buf_obj-list then do :
                    next _buf_parts.
                  end.
                end.
                if ( v-supp-type = buf_tt-gds.prod-type ) and
                   ( v-supp-code = buf_tt-gds.prod-code )
                then do:
                  assign
                    v-retail-pri-prod = v-retail-pri-prod + v-parts-line-qnty
                  .
                end.
                else do:
                  assign
                    v-retail-pri-org = v-retail-pri-org + v-parts-line-qnty
                  .
                end.
                assign
                  v-retail-pri-tot = v-retail-pri-tot + v-parts-line-qnty
                .
              end.
            end.
            when 'es':U  then do :
              if(v-is-local-producer)
              then do:
                assign
                  v-retail-sale-loc-prod  = v-retail-sale-loc-prod + v-ot-line-qnty
                .
              end.
              assign
                v-retail-sale-tot = v-retail-sale-tot + v-ot-line-qnty
              .
            end.
          end case.
        end.
        assign
          v-retail-ost-beg = v-retail-ost-beg + v-ost-begin-qnty
          v-retail-ost-end = v-retail-ost-end + v-ost-end-qnty
        .
      end.
    end.
    assign
      buf_tt-alc-retail.ost-beg       = buf_tt-alc-retail.ost-beg       + v-retail-ost-beg
      buf_tt-alc-retail.pri-prod      = buf_tt-alc-retail.pri-prod      + v-retail-pri-prod
      buf_tt-alc-retail.pri-org       = buf_tt-alc-retail.pri-org       + v-retail-pri-org
      buf_tt-alc-retail.pri-tot       = buf_tt-alc-retail.pri-tot       + v-retail-pri-tot
      buf_tt-alc-retail.sale-loc-prod = buf_tt-alc-retail.sale-loc-prod + v-retail-sale-loc-prod
      buf_tt-alc-retail.sale-tot      = buf_tt-alc-retail.sale-tot      + v-retail-sale-tot
      buf_tt-alc-retail.ost-end       = buf_tt-alc-retail.ost-end       + v-retail-ost-end
    .
  end.
  run prg-bar_delete in this-procedure .
end.
end procedure.
procedure print-alc-pri :
  define buffer buf_tt-alc-pri for tt-alc-pri.
  define variable v-npp         as integer   no-undo .
  define variable v-subtot-qnty as decimal   no-undo .
  define variable v-tot-qnty    as decimal   no-undo .
do
on error undo, return error return-value
:
  run print-alc-pri-header in this-procedure .
  for each buf_tt-alc-pri
    break by buf_tt-alc-pri.cli-type
          by buf_tt-alc-pri.cli-code
          by buf_tt-alc-pri.alc-type-code
  :
    if   first-of(buf_tt-alc-pri.cli-type)
      or first-of(buf_tt-alc-pri.cli-code)
    then do:
      assign
        v-npp         = 0
        v-subtot-qnty = 0
      .
      run alc06xl-sheet1-write-line-data in this-procedure ( input "":U
                                                           , input "":U
                                                           , input "":U
                                                           , input buf_tt-alc-pri.cli-name
                                                           , input buf_tt-alc-pri.cli-inn
                                                           , input buf_tt-alc-pri.cli-address
                                                           , input buf_tt-alc-pri.lic-num
                                                           , input buf_tt-alc-pri.lic-give
                                                           , input "":U
                                                           ) .
    end.
    assign
      v-npp         = v-npp + 1
      v-subtot-qnty = v-subtot-qnty + buf_tt-alc-pri.quantity
      v-tot-qnty    = v-tot-qnty + buf_tt-alc-pri.quantity
    .
    run alc06xl-sheet1-write-line-data in this-procedure ( input string(v-npp)
                                                         , input buf_tt-alc-pri.alc-type-name
                                                         , input string(buf_tt-alc-pri.alc-type-code)
                                                         , input "":U
                                                         , input "":U
                                                         , input "":U
                                                         , input "":U
                                                         , input "":U
                                                         , input string(buf_tt-alc-pri.quantity)
                                                         ) .
    if   last-of(buf_tt-alc-pri.cli-type)
      or last-of(buf_tt-alc-pri.cli-code)
    then do:
      run alc06xl-sheet1-write-line-data in this-procedure ( input "":U
                                                           , input "Итого":U
                                                           , input "":U
                                                           , input "":U
                                                           , input "":U
                                                           , input "":U
                                                           , input "":U
                                                           , input "":U
                                                           , input string(v-subtot-qnty)
                                                           ) .
    end.
  end.
  run alc06xl-sheet1-write-line-data in this-procedure ( input "":U
                                                       , input "Всего":U
                                                       , input "":U
                                                       , input "":U
                                                       , input "":U
                                                       , input "":U
                                                       , input "":U
                                                       , input "":U
                                                       , input string(v-tot-qnty)
                                                       ) .
  run print-alc-pri-footer in this-procedure .
end.
end procedure.
procedure print-alc-pri-header :
do
on error undo, return error return-value
:
  run alc06xl-write-cell-data in this-procedure ( input "h_firmname":U
                                                , input v-firm-name
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input "h_firminn":U
                                                , input v-firm-inn
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input "h_firmaddress":U
                                                , input v-firm-address
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input "h_objcount":U
                                                , input v-obj-count
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input "h_licinfo":U
                                                , input v-lic-info
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input "h_activity":U
                                                , input v-activity
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input "h_daterange":U
                                                , input v-date-range
                                                ).
end.
end procedure.
procedure print-alc-pri-footer :
do
on error undo, return error return-value
:
end.
end procedure.
procedure print-alc-retail :
  define buffer buf_tt-alc-retail for tt-alc-retail.
  define variable v-npp               as integer   no-undo .
  define variable v-tot-ost-beg       as decimal   no-undo .
  define variable v-tot-pri-prod      as decimal   no-undo .
  define variable v-tot-pri-org       as decimal   no-undo .
  define variable v-tot-pri-tot       as decimal   no-undo .
  define variable v-tot-sale-loc-prod as decimal   no-undo .
  define variable v-tot-sale-tot      as decimal   no-undo .
  define variable v-tot-ost-end       as decimal   no-undo .
do
on error undo, return error return-value
:
  run print-alc-retail-header in this-procedure .
  for each buf_tt-alc-retail
  :
    assign
      v-npp               = v-npp + 1
      v-tot-ost-beg       = v-tot-ost-beg       + buf_tt-alc-retail.ost-beg
      v-tot-pri-prod      = v-tot-pri-prod      + buf_tt-alc-retail.pri-prod
      v-tot-pri-org       = v-tot-pri-org       + buf_tt-alc-retail.pri-org
      v-tot-pri-tot       = v-tot-pri-tot       + buf_tt-alc-retail.pri-tot
      v-tot-sale-loc-prod = v-tot-sale-loc-prod + buf_tt-alc-retail.sale-loc-prod
      v-tot-sale-tot      = v-tot-sale-tot      + buf_tt-alc-retail.sale-tot
      v-tot-ost-end       = v-tot-ost-end       + buf_tt-alc-retail.ost-end
    .
    run alc06xl-sheet2-write-line-data in this-procedure ( input string(v-npp)
                                                         , input buf_tt-alc-retail.alc-type-name
                                                         , input string(buf_tt-alc-retail.alc-type-code)
                                                         , input string(buf_tt-alc-retail.ost-beg)
                                                         , input string(buf_tt-alc-retail.pri-tot)
                                                         , input string(buf_tt-alc-retail.pri-prod)
                                                         , input string(buf_tt-alc-retail.pri-org)
                                                         , input string(buf_tt-alc-retail.sale-tot)
                                                         , input string(buf_tt-alc-retail.sale-loc-prod)
                                                         , input string(buf_tt-alc-retail.ost-end)
                                                         ) .
  end.
  run alc06xl-sheet2-write-line-data in this-procedure ( input "":u
                                                       , input "Всего":U
                                                       , input ""
                                                       , input string(v-tot-ost-beg)
                                                       , input string(v-tot-pri-tot)
                                                       , input string(v-tot-pri-prod)
                                                       , input string(v-tot-pri-org)
                                                       , input string(v-tot-sale-tot)
                                                       , input string(v-tot-sale-loc-prod)
                                                       , input string(v-tot-ost-end)
                                                       ) .
  run print-alc-retail-footer in this-procedure .
end.
end procedure.
procedure print-alc-retail-header :
do
on error undo, return error return-value
:
  run alc06xl-write-cell-data in this-procedure ( input "h_firmname2":U
                                                , input v-firm-name
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input "h_firminn2":U
                                                , input v-firm-inn
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input "h_firmaddress2":U
                                                , input v-firm-address
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input "h_objcount2":U
                                                , input v-obj-count
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input "h_licinfo2":U
                                                , input v-lic-info
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input "h_activity2":U
                                                , input v-activity
                                                ).
  run alc06xl-write-cell-data in this-procedure ( input "h_daterange2":U
                                                , input v-date-range
                                                ).
end.
end procedure.
procedure print-alc-retail-footer :
do
on error undo, return error return-value
:
end.
end procedure.
procedure load-head-info :
define buffer buf_alc-sale-lic  for ub.alc-sale-lic.
define buffer buf_obj-list      for obj-list.
do for
buf_obj-list,
buf_alc-sale-lic
on error undo, return error return-value
:
  define variable v-i as integer   no-undo .
  find first buf_alc-sale-lic no-lock
    where buf_alc-sale-lic.cli-type   = 'орг':U
      and buf_alc-sale-lic.cli-code   = v-host-code
      and buf_alc-sale-lic.date-from  < v-begin-date
      and buf_alc-sale-lic.date-to    > v-end-date
  no-error .
  if not available buf_alc-sale-lic
  then do:
    find first buf_alc-sale-lic no-lock
      where buf_alc-sale-lic.cli-type = 'орг':U
        and buf_alc-sale-lic.cli-code = v-host-code
        and buf_alc-sale-lic.date-to  > v-end-date
    no-error .
  end.
  if available buf_alc-sale-lic
  then do:
    assign
      v-lic-info = substitute( "&1 рег. №&2 от &3 г."
                             , buf_alc-sale-lic.seria
                             , buf_alc-sale-lic.number
                             , string(buf_alc-sale-lic.date-get, "99.99.99":U)
                             )
    .
  end.
  else do:
    assign
      v-lic-info = '?':U
    .
  end.
  for each buf_obj-list :
    assign
      v-i = v-i + 1
    .
  end.
  run fmtcli-get-client in this-procedure ( input 'орг':U , v-host-code ) .
  assign
    v-firm-name     = v-fmtcli-name
    v-firm-inn      = v-fmtcli-inn
    v-firm-address  = v-fmtcli-addres
    v-obj-count     = string(v-i)
    v-activity      = "Розничная продажа алкогольной продукции":U
    v-date-range    = substitute( " с &1 по &2"
                                , string( v-begin-date, "99.99.99":U)
                                , string( v-end-date  , "99.99.99":U)
                                )
  .
end.
end procedure.
