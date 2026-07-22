block-level on error undo, throw.
define input parameter itog-only     as logical   no-undo .
define input parameter itog-contract as logical   no-undo .
define input parameter p-contr-code  as integer   no-undo .
define input parameter is-date       as logical   no-undo .
define input parameter is-fin        as logical   no-undo .
define input parameter is-fo         as logical   no-undo .
define input parameter is-real       as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision: 01d4914e5615, 377, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Mon Dec 28 19:14:54 2015 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-obsal2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-obsal2.p $":U .
define variable vss-description as character no-undo init "Оборотно-сальдовая ведомость по покупателям".
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
def var vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define Stream OutStream.
do
on error undo, return error
:
DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
ASSIGN parParentProc =  my-handle .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable g#report-num as integer no-undo .
run get-report-num  in parparentproc (output g#report-num).
function excel-format-dec-to-char returns char (input p-dec as decimal ).
  if num-entries(string(p-dec), '.') = 2
    then return( entry(1, string(p-dec), '.') + v-delim + entry(2, string(p-dec), '.')) .
    else return( string(p-dec)) .
end function.
function format-point-to-comma returns char (input orig as char ) .
define variable rtext as character no-undo .
define variable strt as integer no-undo .
define variable leng as integer no-undo .
assign rtext = orig .
repeat:
  strt =  index(rtext,'.').
  if strt = 0 then leave.
  leng = 1.
  substring(rtext,strt,leng,"character") = v-delim .
end.
return rtext.
end function.
function format-excel-text returns char ( input start-text as char ) :
def var  i    as int no-undo.
def var  ch   as char no-undo.
def var  n    as int no-undo.
def var  ipos as int no-undo.
  n = num-entries(trim(start-text), chr(10)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(10)).
    if ipos > 0 then
      substr( start-text, ipos, 1 ) = ' '.
  end.
  n = num-entries(trim(start-text), chr(13)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(13)).
    if ipos > 0 then
      substr( start-text, ipos, 1 ) = ' '.
  end.
  if index( start-text, '"' ) = 0 then
    start-text =  '="'   + trim( start-text) + '"'   .
    else do:
      n = num-entries(trim(start-text), '"') - 1.
      do i = 1 to n :
        ch = ch + entry(i,trim(start-text), '"' ) + '""'.
      end.
      ch = ch + entry(num-entries(trim(start-text), '"'),trim(start-text), '"' ).
      start-text = '="'  + ch  + '"' .
    end.
  return start-text.
end.
function excel-sum returns char (input p-dec as decimal ).
  return(format-excel-text(excel-format-dec-to-char(round(p-dec,2)))) .
end function.
function excel-qnty returns char (input p-dec as decimal ).
  return(format-excel-text(excel-format-dec-to-char(round(p-dec,3)))) .
end function.
function format-excel-text-macr returns char ( input start-text as char ) :
def var  i    as int no-undo.
def var  ch   as char no-undo.
def var  n    as int no-undo.
def var  ipos as int no-undo.
  n = num-entries(trim(start-text), chr(10)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(10)).
    if ipos > 0 then
      substring( start-text, ipos , 1 ) = ' '.
  end.
  n = num-entries(trim(start-text), chr(13)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(13)).
    if ipos > 0 then
      substring( start-text, ipos, 1 ) = ' '.
  end.
  if index( start-text, '"' ) = 0 then
    start-text =  '"'   + trim( start-text) + '"'   .
    else do:
      n = num-entries(trim(start-text), '"') - 1.
      do i = 1 to n :
        ch = ch + entry(i,trim(start-text), '"' ) + '""'.
      end.
      ch = ch + entry(num-entries(trim(start-text), '"'),trim(start-text), '"' ).
      start-text = '"'  + ch  + '"' .
    end.
  n = num-entries(trim(start-text), chr(10)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(10)).
    if ipos > 0 then
      substring( start-text, ipos , 1 ) = ' '.
  end.
    if num-entries(trim(start-text), chr(10)) > 1 then  message num-entries(trim(start-text), chr(10)) start-text.
  return start-text.
end.
def var vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info19 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
 define stream macr_excel .
 define variable v-file-name as character no-undo .
procedure macr_excel_char :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .
      put  stream macr_excel unformatted
        substitute('formula(&3,"r&1c&2")', p-row , p-col , format-excel-text-macr ( p-val) ) skip  .
 end.
end procedure.
procedure macr_excel_sum :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as decimal   no-undo .
 define input parameter  p-row as integer   no-undo .
 define input parameter  p-col as integer   no-undo .
 define input parameter  p-typ as integer   no-undo .
 if p-val = ? then assign p-val = 0 .
 define variable ss as character no-undo .
 assign
   ss = string( Round( p-val, p-typ) )
 .
 put  stream macr_excel unformatted
      substitute('formula(&3,"r&1c&2")', p-row , p-col , ss ) skip  .
 end.
END procedure.
procedure macr_excel_date :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .
    put stream macr_excel unformatted
          substitute('select("r&1c&2")', p-row , p-col ) + chr(10) .
    put stream macr_excel unformatted 'format.number("dd/mm/yy")' + chr(10) .
    put stream macr_excel unformatted
          substitute('formula(&3,"r&1c&2")', p-row , p-col ,  p-val ) + chr(10)  .
 end.
end procedure.
procedure macr_cell_format :
 do
 on error undo, return error return-value
 :
 define input parameter  p-size   as integer   no-undo .
 define input parameter  p-bold   as logical   no-undo .
 define input parameter  p-italic as logical   no-undo .
 define input parameter  p-color  as integer   no-undo .
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .
  if p-size = ? then p-size = 10 .
  if p-bold = ? then p-bold = false .
  if p-italic = ? then p-italic = false .
  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  put  stream macr_excel unformatted
   substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) skip .
  if p-color <> ? then do:
     put  stream macr_excel unformatted
       substitute('patterns(1,,&1,true)', p-color )  skip  .
  end.
  put  stream macr_excel unformatted
       substitute('format.font(,&1,&2,&3)' , p-size,
                                        string ( p-bold  , "true/false" ) ,
                                        string ( p-italic , "true/false" )
                                        ) skip .
 end.
end procedure.
procedure macr_cell_bordur :
 do
 on error undo, return error return-value
 :
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .
  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  put  stream macr_excel unformatted
   substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) skip .
  put  stream macr_excel unformatted
       'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  skip
       'ALIGNMENT(3 , , 4 , 4 ,)'   skip
       .
 end.
end procedure.
procedure macr_cell_merge :
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .
 do
 on error undo, return error return-value
 :
  if p-row-2 = ?
  then do:
    assign
      p-row-2 = p-row
    .
  end.
  if p-col-2 = ?
  then do:
    assign
      p-col-2 = p-col
    .
  end.
  put stream macr_excel unformatted
    substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) chr(10)
    'border(1,1,1,1,1,,0,0,0,0,0)':u chr(10)
    'alignment(7,true,2,4)':u chr(10)
    .
 end.
end procedure.
procedure macr_cell_size :
 do
 on error undo, return error return-value
 :
 define input parameter  p-w   as integer   no-undo .
 define input parameter  p-l   as integer   no-undo .
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .
  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  if p-w = ? then    p-w = 0 .
  if p-l = ? then    p-l = 0 .
 define variable s-w as character no-undo .
 define variable s-l as character no-undo .
 if p-w = 0 then s-w = "" .
            else s-w = string(p-w)  .
 if p-l = 0 then s-l = "" .
            else s-l = string(p-l)  .
put  stream macr_excel unformatted
     substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 )  skip .
put  stream macr_excel unformatted
     substitute('COLUMN.WIDTH(&1,,,,)' , s-w  )  skip.
put  stream macr_excel unformatted
     'FORMAT.TEXT(2,2,0,,,,,)'  skip.
 end.
end procedure.
procedure end-proc :
 do
 on error undo, return error return-value
 :
  v-file-name = ( string( session:temp-directory + "rpt" + string( g#report-num ) ) + ".t-t").
  OUTPUT to VALUE (v-file-name) .
  for each temp-param :
    export  temp-param  .
  end.
 end.
end procedure.
  define variable  v-fact-order-start     as decimal   no-undo .
  define variable  v-fact-order-end       as decimal   no-undo .
  define variable v-ind                  as integer   no-undo .
  define variable ind                    as integer   no-undo .
  define variable ind1                   as integer   no-undo .
  define variable ii                     as integer initial 0  no-undo .
  define variable jj                     as integer initial 0  no-undo .
  define variable kk                     as integer initial 0  no-undo .
  define variable Counter1               as integer   no-undo .
  define variable Line                   as character no-undo .
  define variable v-contract-code        as integer   no-undo .
  define variable s-val as character no-undo .
  if x-SET_val_TYPE = 1 then assign s-val = "рубл." .
  else                       assign s-val = "б.вал." .
  define variable v-contr         as integer   no-undo .
  define variable v-sm1-contr     as decimal   no-undo .
  define variable v-sm2-contr     as decimal   no-undo .
  define variable v-sm3-contr     as decimal   no-undo .
  define variable v-sm4-contr     as decimal   no-undo .
  define variable v-sm1-cli       as decimal   no-undo .
  define variable v-sm2-cli       as decimal   no-undo .
  define variable v-sm3-cli       as decimal   no-undo .
  define variable v-sm4-cli       as decimal   no-undo .
  define variable v-sum-e       as decimal   no-undo .
  define variable v-sum-i       as decimal   no-undo .
  define variable v-row as integer   no-undo .
  define variable v-str  as CHAR  no-undo .
  define variable par-type  as CHAR  no-undo .
  define variable num-col as integer initial 0  no-undo .
  if is-real then assign num-col = num-col + 1 .
  if is-fo   then assign num-col = num-col + 1 .
  if is-fin  then assign num-col = num-col + 1 .
  DEFINE temp-table temp-doc no-undo
    field   sum2          as decimal
    field   sum3          as decimal
    field   sum4          as decimal
    field   num2          as integer
    field   num3          as integer
    field   num4          as integer
    field   contr         as integer
    field   contr-name    as character
    field   cli-type      as character
    field   cli-code      as integer
    INDEX pi  IS PRIMARY   cli-type cli-code contr
  .
  DEFINE temp-table temp-sum no-undo
    field   sum          as decimal
    field   contr        as integer
    field   dat          as date
    field   num          as character
    field   styp         as character
    field   type         as integer
    field   ind          as integer
    field   cli-type      as character
    field   cli-code      as integer
    field   fact-order    as decimal
    INDEX pi  IS PRIMARY   cli-type cli-code contr  dat ind type
    INDEX pi1 cli-type cli-code contr fact-order ind type
  .
  DEFINE temp-table temp-date no-undo
    field   cli-type      as character
    field   cli-code      as integer
    field   contr         as integer
    field   dat           as date
    field   num1          as integer
    field   num2          as integer
    field   num3          as integer
    field   num4          as integer
    INDEX pi  IS PRIMARY  dat
  .
  DEFINE temp-table temp-cli no-undo
    field   sum2          as decimal
    field   sum3          as decimal
    field   sum4          as decimal
    field   obj-type      as character
    field   obj-code      as integer
    field   obj-name      as character
    INDEX pi  IS PRIMARY   obj-type obj-code
  .
  define temp-table temp-obj-firm no-undo
    field obj-code      as integer
    field obj-type      as char
    field err           as logical
    index pi is primary unique obj-code obj-type
  .
  define buffer buf_shop for shop .
  define buffer buf_store for store .
  define buffer buf_trn-doc for trn-doc .
  for each buf_shop no-lock where buf_shop.host-code = v-cntxt-host-code-obj :
    run clntattr-value in this-procedure  (input 'маг':U,input buf_shop.obj-code, input  'arh-trn-doc-contract':U, output v-str, output par-type) no-error .
    if v-str = "yes" then do:
      message "Неправильные архивы arh-trn-doc-contract по магазину " string(buf_shop.obj-code) " . Отчет по этому магазину не будет выведен."  view-as alert-box.
      next.
    end.
    create temp-obj-firm.
    assign
      temp-obj-firm.obj-code = buf_shop.obj-code
      temp-obj-firm.obj-type = 'маг':U
    .
  end.
  for each buf_store no-lock where buf_store.host-code = v-cntxt-host-code-obj :
    run clntattr-value in this-procedure  (input 'скл':U,input buf_store.obj-code, input  'arh-trn-doc-contract':U, output v-str, output par-type) no-error .
    if v-str = "yes" then do:
      message "Неправильные архивы arh-trn-doc-contract по складу " string(buf_store.obj-code) " . Отчет по этому складу не будет выведен."  view-as alert-box.
      next.
    end.
    create temp-obj-firm.
    assign
      temp-obj-firm.obj-code = buf_store.obj-code
      temp-obj-firm.obj-type = 'скл':U
    .
  end.
  define variable v-curr-r-b as integer   no-undo .
  if x-SET_val_TYPE = 1  then assign v-curr-r-b = 0 .
  else do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run r-b-curr in g#library
  (input  v-cntxt-host-code-obj
  ,output v-curr-r-b
  )  .
  end.
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
assign v-account = ( if integer( 50 ) = 0 then 100 else integer( 50 ) ).
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
  define buffer buf_contract for contract .
  define buffer buf_clients  for clients .
  define buffer buf_fin-ob   for fin-ob .
  define buffer buf_fin-doc  for fin-doc .
  define buffer buf_arh-trn-doc-contract  for arh-trn-doc-contract .
  define buffer prev_arh-trn-doc-contract for arh-trn-doc-contract .
  define buffer buf_arh-fin-ob-contr for arh-fin-ob-contr .
  define buffer buf_arh-fin-doc-contr-schet for arh-fin-doc-contr-schet .
  define buffer buf_arh-fin-doc-contr-schet-nal for arh-fin-doc-contr-schet-nal .
  if p-contr-code > 0 then do:
    if itog-contract then do:
      define variable dd as date  no-undo .
      assign dd = 1/1/1900 .
      find first fin-ob no-lock
        where fin-ob.host-code     = v-cntxt-host-code-obj
          and fin-ob.contract-code = p-contr-code
          and fin-ob.status_       = 'факт':U
      no-error .
      if available fin-ob then  if fin-ob.fact-date < dd then assign dd = fin-ob.fact-date .
      find first fin-doc no-lock
        where fin-doc.host-code     = v-cntxt-host-code-obj
          and fin-doc.contract-code = p-contr-code
          and fin-doc.status_       = 'факт':U
      no-error .
      if available fin-doc then  if fin-doc.fact-date < dd then assign dd = fin-doc.fact-date .
      run day-begin-fact-order in this-procedure ( input dd,        output v-fact-order-start ).
      assign dd = today .
      find last fin-ob no-lock
        where fin-ob.host-code     = v-cntxt-host-code-obj
          and fin-ob.contract-code = p-contr-code
          and fin-ob.status_       = 'факт':U
      no-error .
      if available fin-ob then  if fin-ob.fact-date > dd then assign dd = fin-ob.fact-date .
      find last fin-doc no-lock
        where fin-doc.host-code     = v-cntxt-host-code-obj
          and fin-doc.contract-code = p-contr-code
          and fin-doc.status_       = 'факт':U
      no-error .
      if available fin-doc then  if fin-doc.fact-date > dd then assign dd = fin-doc.fact-date .
      run day-begin-fact-order in this-procedure ( input ( dd + 1 ),  output v-fact-order-end ).
    end.
    else do:
      run day-begin-fact-order in this-procedure ( input x-date-start,        output v-fact-order-start ).
      run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),  output v-fact-order-end ).
    end.
    find first buf_contract no-lock where buf_contract.host-code = v-cntxt-host-code-obj and buf_contract.contract-code = p-contr-code .
    assign v-contract-code = buf_contract.contract-code .
    create temp-cli .
    assign
      temp-cli.obj-type = buf_contract.cli-type
      temp-cli.obj-code = buf_contract.cli-code
    .
define variable vss-include-info21 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  create temp-doc .
  assign
    temp-doc.contr      = v-contract-code
    temp-doc.cli-type   = temp-cli.obj-type
    temp-doc.cli-code   = temp-cli.obj-code
  .
  if v-contract-code > 0 then assign temp-doc.contr-name = "Договор № " + buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date) + " (усл.ген. " + buf_contract.usl-opl + ")" .
  else                        assign temp-doc.contr-name = "Без договора" .
  if is-real then do:
    for each temp-obj-firm :
      for each buf_trn-doc no-lock
        where buf_trn-doc.host-code     = v-cntxt-host-code-obj
          and buf_trn-doc.contract-code = v-contract-code
          and buf_trn-doc.obj-type      = temp-obj-firm.obj-type
          and buf_trn-doc.obj-code      = temp-obj-firm.obj-code
          and buf_trn-doc.fact-order    <  v-fact-order-end
       by buf_trn-doc.fact-order :
        if x-SET_val_TYPE = 1 then do:
          if buf_trn-doc.tot-rubl = 0 or buf_trn-doc.tot-rubl = ? then next .
        end.
        else do:
          if buf_trn-doc.tot-doc = 0 or buf_trn-doc.tot-doc = ? then next .
        end.
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
        if buf_trn-doc.fact-order < v-fact-order-start then do:
          case buf_trn-doc.ext-doc-type :
            when 'ee':U or
            when 'es':U or
            when 'we':U or
            when 'wm':U or
            when 'ee':U  or
            when 'vt':U  or
            when 'vp':U then do:
              if x-SET_val_TYPE = 1  then assign  temp-doc.sum2 = temp-doc.sum2 + buf_trn-doc.tot-rubl .
              else                        assign  temp-doc.sum2 = temp-doc.sum2 + buf_trn-doc.tot-doc .
            end.
            when 're':U or
            when 'rs':U then do:
              if x-SET_val_TYPE = 1  then assign  temp-doc.sum2 = temp-doc.sum2 - buf_trn-doc.tot-rubl .
              else                        assign  temp-doc.sum2 = temp-doc.sum2 - buf_trn-doc.tot-doc .
            end.
          end.
        end.
        else do:
          case buf_trn-doc.ext-doc-type :
            when 'ee':U or
            when 'es':U or
            when 'we':U or
            when 'wm':U or
            when 'ee':U  or
            when 'vt':U  or
            when 'vp':U then do:
              create temp-sum .
              assign
                temp-sum.contr      = v-contract-code
                temp-sum.dat        = buf_trn-doc.fact-date
                temp-sum.num        = buf_trn-doc.doc-code
                temp-sum.cli-type   = temp-cli.obj-type
                temp-sum.cli-code   = temp-cli.obj-code
                temp-sum.fact-order = buf_trn-doc.fact-order
                temp-sum.type       = 2
              .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run docextnm in g#library
  (input  temp-sum.num
  ,output temp-sum.styp
  )  .
              if temp-sum.styp = "??" then assign temp-sum.styp = "" .
              if x-SET_val_TYPE = 1  then assign  temp-sum.sum = buf_trn-doc.tot-rubl .
              else                        assign  temp-sum.sum = buf_trn-doc.tot-doc .
            end.
            when 're':U or
            when 'rs':U then do:
              create temp-sum .
              assign
                temp-sum.contr      = v-contract-code
                temp-sum.dat        = buf_trn-doc.fact-date
                temp-sum.num        = buf_trn-doc.doc-code
                temp-sum.cli-type   = temp-cli.obj-type
                temp-sum.cli-code   = temp-cli.obj-code
                temp-sum.fact-order = buf_trn-doc.fact-order
                temp-sum.type       = 2
              .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run docextnm in g#library
  (input  temp-sum.num
  ,output temp-sum.styp
  )  .
              if temp-sum.styp = "??" then assign temp-sum.styp = "" .
              if x-SET_val_TYPE = 1  then assign  temp-sum.sum = - buf_trn-doc.tot-rubl .
              else                        assign  temp-sum.sum = - buf_trn-doc.tot-doc .
            end.
          end.
        end.
      end.
    end.
    assign  temp-cli.sum2 = temp-cli.sum2 + temp-doc.sum2 .
    for each temp-sum where temp-sum.contr = v-contract-code break by temp-sum.fact-order :
      if is-date then run new-date in this-procedure .
      else do:
        assign  temp-sum.ind = temp-doc.num2      temp-doc.num2 = temp-doc.num2 + 1 .
      end.
    end.
  end.
  if is-fo then do:
    find last buf_arh-fin-ob-contr no-lock
      where buf_arh-fin-ob-contr.host-code      = v-cntxt-host-code-obj
        and buf_arh-fin-ob-contr.contract-code  = v-contract-code
        and buf_arh-fin-ob-contr.calc-curr-code = v-curr-r-b
        and buf_arh-fin-ob-contr.fin-ext-doc-type = 'при':U
        and buf_arh-fin-ob-contr.sum-type       = ""
        and buf_arh-fin-ob-contr.fact-order    <= v-fact-order-start
        and buf_arh-fin-ob-contr.cli-type       = temp-cli.obj-type
        and buf_arh-fin-ob-contr.cli-code       = temp-cli.obj-code
    no-error .
    if available buf_arh-fin-ob-contr then
      assign
        temp-doc.sum3 = temp-doc.sum3 + (if available buf_contract and buf_contract.doc-type = 'рас':U then (buf_arh-fin-ob-contr.expense - buf_arh-fin-ob-contr.income) else (buf_arh-fin-ob-contr.income - buf_arh-fin-ob-contr.expense))
        temp-cli.sum3 = temp-cli.sum3 + temp-doc.sum3
      .
    for each buf_fin-ob no-lock
      where buf_fin-ob.host-code     = v-cntxt-host-code-obj
        and buf_fin-ob.contract-code = v-contract-code
        and buf_fin-ob.status_       = 'факт':U
        and buf_fin-ob.fact-order    >= v-fact-order-start
        and buf_fin-ob.fact-order    <  v-fact-order-end
      :
      if v-contract-code = 0 then do:
         if (  (buf_fin-ob.receiver-type <> temp-cli.obj-type or buf_fin-ob.receiver-code <> temp-cli.obj-code)
           and (buf_fin-ob.payer-type    <> temp-cli.obj-type or buf_fin-ob.payer-code <> temp-cli.obj-code ) ) then next .
      end.
      create temp-sum .
      assign
        temp-sum.contr = v-contract-code
        temp-sum.dat   = buf_fin-ob.fact-date
        temp-sum.num   = buf_fin-ob.prn-doc-code
        temp-sum.type  = 3
        temp-sum.cli-type   = temp-cli.obj-type
        temp-sum.cli-code   = temp-cli.obj-code
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
      if x-SET_val_TYPE = 1  then assign temp-sum.sum = buf_fin-ob.sum-rubl .
      else                        assign temp-sum.sum = buf_fin-ob.sum-base .
      if  temp-sum.sum <= 0 then assign temp-sum.styp = "ПФО" .
      else                       assign temp-sum.styp = "РФО" .
      if is-date then run new-date in this-procedure .
      else assign   temp-sum.ind   = temp-doc.num3   temp-doc.num3  = temp-doc.num3 + 1  .
    end.
  end.
  if is-fin then do:
    run CalcOstatFin(input 'ппп':U  , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then v-sum-e else 0 - v-sum-e) .
    run CalcOstatFin(input 'рпп':U , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then 0 - v-sum-i else v-sum-i) .
    run CalcOstatFinNal(input 'пко':U   , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then v-sum-e else 0 - v-sum-e)  .
    run CalcOstatFinNal(input 'рко':U  , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then 0 - v-sum-i else v-sum-i) .
    run CalcOstatFinNal(input 'апп':U , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then v-sum-e else 0 - v-sum-e) .
    run CalcOstatFinNal(input 'апр':U, output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then 0 - v-sum-i else v-sum-i) .
    assign temp-cli.sum4 = temp-cli.sum4 + temp-doc.sum4 .
    for each buf_fin-doc no-lock
      where buf_fin-doc.host-code     = v-cntxt-host-code-obj
        and buf_fin-doc.contract-code = v-contract-code
        and buf_fin-doc.status_       = 'факт':U
        and buf_fin-doc.fact-order    >= v-fact-order-start
        and buf_fin-doc.fact-order    <  v-fact-order-end
      :
      if v-contract-code = 0 then do:
         if (  (buf_fin-doc.receiver-type <> temp-cli.obj-type or buf_fin-doc.receiver-code <> temp-cli.obj-code)
           and (buf_fin-doc.payer-type    <> temp-cli.obj-type or buf_fin-doc.payer-code    <> temp-cli.obj-code ) ) then next .
      end.
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
      create temp-sum .
      assign
        temp-sum.contr = v-contract-code
        temp-sum.dat   = buf_fin-doc.fact-date
        temp-sum.num   = buf_fin-doc.prn-doc-code
        temp-sum.styp  = buf_fin-doc.fin-ext-doc-type
        temp-sum.type  = 4
        temp-sum.cli-type   = temp-cli.obj-type
        temp-sum.cli-code   = temp-cli.obj-code
      .
      if x-SET_val_TYPE = 1  then assign temp-sum.sum = buf_fin-doc.sum-rubl .
      else                        assign temp-sum.sum = buf_fin-doc.sum-base .
      if buf_fin-doc.fin-ext-doc-type = 'ппп':U or buf_fin-doc.fin-ext-doc-type = 'пко':U or buf_fin-doc.fin-ext-doc-type = 'апп':U then assign temp-sum.sum = - temp-sum.sum .
       if available buf_contract and buf_contract.doc-type = 'рас':U then assign temp-sum.sum = - temp-sum.sum .
      if is-date then run new-date in this-procedure .
      else assign   temp-sum.ind   = temp-doc.num4   temp-doc.num4  = temp-doc.num4 + 1  .
    end.
  end.
  if p-contr-code = 0 then do:
    if is-date then do:
      if temp-doc.sum2 = 0 and temp-doc.sum3 = 0 and temp-doc.sum4 = 0 then do:
        find first temp-date
          where temp-date.dat      = temp-sum.dat
            and temp-date.cli-type = temp-sum.cli-type
            and temp-date.cli-code = temp-sum.cli-code
            and temp-date.contr    = temp-sum.contr
        no-error .
        if not available temp-date then delete temp-doc .
      end.
    end.
    else do:
      if temp-doc.sum2 = 0 and temp-doc.sum3 = 0 and temp-doc.sum4 = 0 and
         temp-doc.num2 = 0 and temp-doc.num3 = 0 and temp-doc.num4 = 0 then delete temp-doc .
    end.
  end.
  end.
  else do:
    run day-begin-fact-order in this-procedure ( input x-date-start,        output v-fact-order-start ).
    run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),  output v-fact-order-end ).
    find first G#CUSTOMER no-error .
    if not available G#CUSTOMER then do:
      for each buf_clients no-lock :
        if buf_clients.sup-gds = no and buf_clients.sup-cons = no and buf_clients.sup-serv = no then next .
        create temp-cli .
        assign
          temp-cli.obj-type = buf_clients.obj-type
          temp-cli.obj-code = buf_clients.obj-code
          temp-cli.obj-name = buf_clients.obj-name
        .
        assign v-contract-code = 0 .
define variable vss-include-info24 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  create temp-doc .
  assign
    temp-doc.contr      = v-contract-code
    temp-doc.cli-type   = temp-cli.obj-type
    temp-doc.cli-code   = temp-cli.obj-code
  .
  if v-contract-code > 0 then assign temp-doc.contr-name = "Договор № " + buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date) + " (усл.ген. " + buf_contract.usl-opl + ")" .
  else                        assign temp-doc.contr-name = "Без договора" .
  if is-real then do:
    for each temp-obj-firm :
      for each buf_trn-doc no-lock
        where buf_trn-doc.host-code     = v-cntxt-host-code-obj
          and buf_trn-doc.contract-code = v-contract-code
          and buf_trn-doc.obj-type      = temp-obj-firm.obj-type
          and buf_trn-doc.obj-code      = temp-obj-firm.obj-code
          and buf_trn-doc.fact-order    <  v-fact-order-end
       by buf_trn-doc.fact-order :
        if x-SET_val_TYPE = 1 then do:
          if buf_trn-doc.tot-rubl = 0 or buf_trn-doc.tot-rubl = ? then next .
        end.
        else do:
          if buf_trn-doc.tot-doc = 0 or buf_trn-doc.tot-doc = ? then next .
        end.
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
        if buf_trn-doc.fact-order < v-fact-order-start then do:
          case buf_trn-doc.ext-doc-type :
            when 'ee':U or
            when 'es':U or
            when 'we':U or
            when 'wm':U or
            when 'ee':U  or
            when 'vt':U  or
            when 'vp':U then do:
              if x-SET_val_TYPE = 1  then assign  temp-doc.sum2 = temp-doc.sum2 + buf_trn-doc.tot-rubl .
              else                        assign  temp-doc.sum2 = temp-doc.sum2 + buf_trn-doc.tot-doc .
            end.
            when 're':U or
            when 'rs':U then do:
              if x-SET_val_TYPE = 1  then assign  temp-doc.sum2 = temp-doc.sum2 - buf_trn-doc.tot-rubl .
              else                        assign  temp-doc.sum2 = temp-doc.sum2 - buf_trn-doc.tot-doc .
            end.
          end.
        end.
        else do:
          case buf_trn-doc.ext-doc-type :
            when 'ee':U or
            when 'es':U or
            when 'we':U or
            when 'wm':U or
            when 'ee':U  or
            when 'vt':U  or
            when 'vp':U then do:
              create temp-sum .
              assign
                temp-sum.contr      = v-contract-code
                temp-sum.dat        = buf_trn-doc.fact-date
                temp-sum.num        = buf_trn-doc.doc-code
                temp-sum.cli-type   = temp-cli.obj-type
                temp-sum.cli-code   = temp-cli.obj-code
                temp-sum.fact-order = buf_trn-doc.fact-order
                temp-sum.type       = 2
              .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run docextnm in g#library
  (input  temp-sum.num
  ,output temp-sum.styp
  )  .
              if temp-sum.styp = "??" then assign temp-sum.styp = "" .
              if x-SET_val_TYPE = 1  then assign  temp-sum.sum = buf_trn-doc.tot-rubl .
              else                        assign  temp-sum.sum = buf_trn-doc.tot-doc .
            end.
            when 're':U or
            when 'rs':U then do:
              create temp-sum .
              assign
                temp-sum.contr      = v-contract-code
                temp-sum.dat        = buf_trn-doc.fact-date
                temp-sum.num        = buf_trn-doc.doc-code
                temp-sum.cli-type   = temp-cli.obj-type
                temp-sum.cli-code   = temp-cli.obj-code
                temp-sum.fact-order = buf_trn-doc.fact-order
                temp-sum.type       = 2
              .
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run docextnm in g#library
  (input  temp-sum.num
  ,output temp-sum.styp
  )  .
              if temp-sum.styp = "??" then assign temp-sum.styp = "" .
              if x-SET_val_TYPE = 1  then assign  temp-sum.sum = - buf_trn-doc.tot-rubl .
              else                        assign  temp-sum.sum = - buf_trn-doc.tot-doc .
            end.
          end.
        end.
      end.
    end.
    assign  temp-cli.sum2 = temp-cli.sum2 + temp-doc.sum2 .
    for each temp-sum where temp-sum.contr = v-contract-code break by temp-sum.fact-order :
      if is-date then run new-date in this-procedure .
      else do:
        assign  temp-sum.ind = temp-doc.num2      temp-doc.num2 = temp-doc.num2 + 1 .
      end.
    end.
  end.
  if is-fo then do:
    find last buf_arh-fin-ob-contr no-lock
      where buf_arh-fin-ob-contr.host-code      = v-cntxt-host-code-obj
        and buf_arh-fin-ob-contr.contract-code  = v-contract-code
        and buf_arh-fin-ob-contr.calc-curr-code = v-curr-r-b
        and buf_arh-fin-ob-contr.fin-ext-doc-type = 'при':U
        and buf_arh-fin-ob-contr.sum-type       = ""
        and buf_arh-fin-ob-contr.fact-order    <= v-fact-order-start
        and buf_arh-fin-ob-contr.cli-type       = temp-cli.obj-type
        and buf_arh-fin-ob-contr.cli-code       = temp-cli.obj-code
    no-error .
    if available buf_arh-fin-ob-contr then
      assign
        temp-doc.sum3 = temp-doc.sum3 + (if available buf_contract and buf_contract.doc-type = 'рас':U then (buf_arh-fin-ob-contr.expense - buf_arh-fin-ob-contr.income) else (buf_arh-fin-ob-contr.income - buf_arh-fin-ob-contr.expense))
        temp-cli.sum3 = temp-cli.sum3 + temp-doc.sum3
      .
    for each buf_fin-ob no-lock
      where buf_fin-ob.host-code     = v-cntxt-host-code-obj
        and buf_fin-ob.contract-code = v-contract-code
        and buf_fin-ob.status_       = 'факт':U
        and buf_fin-ob.fact-order    >= v-fact-order-start
        and buf_fin-ob.fact-order    <  v-fact-order-end
      :
      if v-contract-code = 0 then do:
         if (  (buf_fin-ob.receiver-type <> temp-cli.obj-type or buf_fin-ob.receiver-code <> temp-cli.obj-code)
           and (buf_fin-ob.payer-type    <> temp-cli.obj-type or buf_fin-ob.payer-code <> temp-cli.obj-code ) ) then next .
      end.
      create temp-sum .
      assign
        temp-sum.contr = v-contract-code
        temp-sum.dat   = buf_fin-ob.fact-date
        temp-sum.num   = buf_fin-ob.prn-doc-code
        temp-sum.type  = 3
        temp-sum.cli-type   = temp-cli.obj-type
        temp-sum.cli-code   = temp-cli.obj-code
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
      if x-SET_val_TYPE = 1  then assign temp-sum.sum = buf_fin-ob.sum-rubl .
      else                        assign temp-sum.sum = buf_fin-ob.sum-base .
      if  temp-sum.sum <= 0 then assign temp-sum.styp = "ПФО" .
      else                       assign temp-sum.styp = "РФО" .
      if is-date then run new-date in this-procedure .
      else assign   temp-sum.ind   = temp-doc.num3   temp-doc.num3  = temp-doc.num3 + 1  .
    end.
  end.
  if is-fin then do:
    run CalcOstatFin(input 'ппп':U  , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then v-sum-e else 0 - v-sum-e) .
    run CalcOstatFin(input 'рпп':U , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then 0 - v-sum-i else v-sum-i) .
    run CalcOstatFinNal(input 'пко':U   , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then v-sum-e else 0 - v-sum-e)  .
    run CalcOstatFinNal(input 'рко':U  , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then 0 - v-sum-i else v-sum-i) .
    run CalcOstatFinNal(input 'апп':U , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then v-sum-e else 0 - v-sum-e) .
    run CalcOstatFinNal(input 'апр':U, output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then 0 - v-sum-i else v-sum-i) .
    assign temp-cli.sum4 = temp-cli.sum4 + temp-doc.sum4 .
    for each buf_fin-doc no-lock
      where buf_fin-doc.host-code     = v-cntxt-host-code-obj
        and buf_fin-doc.contract-code = v-contract-code
        and buf_fin-doc.status_       = 'факт':U
        and buf_fin-doc.fact-order    >= v-fact-order-start
        and buf_fin-doc.fact-order    <  v-fact-order-end
      :
      if v-contract-code = 0 then do:
         if (  (buf_fin-doc.receiver-type <> temp-cli.obj-type or buf_fin-doc.receiver-code <> temp-cli.obj-code)
           and (buf_fin-doc.payer-type    <> temp-cli.obj-type or buf_fin-doc.payer-code    <> temp-cli.obj-code ) ) then next .
      end.
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
      create temp-sum .
      assign
        temp-sum.contr = v-contract-code
        temp-sum.dat   = buf_fin-doc.fact-date
        temp-sum.num   = buf_fin-doc.prn-doc-code
        temp-sum.styp  = buf_fin-doc.fin-ext-doc-type
        temp-sum.type  = 4
        temp-sum.cli-type   = temp-cli.obj-type
        temp-sum.cli-code   = temp-cli.obj-code
      .
      if x-SET_val_TYPE = 1  then assign temp-sum.sum = buf_fin-doc.sum-rubl .
      else                        assign temp-sum.sum = buf_fin-doc.sum-base .
      if buf_fin-doc.fin-ext-doc-type = 'ппп':U or buf_fin-doc.fin-ext-doc-type = 'пко':U or buf_fin-doc.fin-ext-doc-type = 'апп':U then assign temp-sum.sum = - temp-sum.sum .
       if available buf_contract and buf_contract.doc-type = 'рас':U then assign temp-sum.sum = - temp-sum.sum .
      if is-date then run new-date in this-procedure .
      else assign   temp-sum.ind   = temp-doc.num4   temp-doc.num4  = temp-doc.num4 + 1  .
    end.
  end.
  if p-contr-code = 0 then do:
    if is-date then do:
      if temp-doc.sum2 = 0 and temp-doc.sum3 = 0 and temp-doc.sum4 = 0 then do:
        find first temp-date
          where temp-date.dat      = temp-sum.dat
            and temp-date.cli-type = temp-sum.cli-type
            and temp-date.cli-code = temp-sum.cli-code
            and temp-date.contr    = temp-sum.contr
        no-error .
        if not available temp-date then delete temp-doc .
      end.
    end.
    else do:
      if temp-doc.sum2 = 0 and temp-doc.sum3 = 0 and temp-doc.sum4 = 0 and
         temp-doc.num2 = 0 and temp-doc.num3 = 0 and temp-doc.num4 = 0 then delete temp-doc .
    end.
  end.
        for each buf_contract no-lock
          where buf_contract.host-code = v-cntxt-host-code-obj
            and buf_contract.cli-type  = buf_clients.obj-type
            and buf_contract.cli-code  = buf_clients.obj-code
            and buf_contract.doc-type  = 'рас':U
          :
          assign v-contract-code = buf_contract.contract-code .
define variable vss-include-info27 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  create temp-doc .
  assign
    temp-doc.contr      = v-contract-code
    temp-doc.cli-type   = temp-cli.obj-type
    temp-doc.cli-code   = temp-cli.obj-code
  .
  if v-contract-code > 0 then assign temp-doc.contr-name = "Договор № " + buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date) + " (усл.ген. " + buf_contract.usl-opl + ")" .
  else                        assign temp-doc.contr-name = "Без договора" .
  if is-real then do:
    for each temp-obj-firm :
      for each buf_trn-doc no-lock
        where buf_trn-doc.host-code     = v-cntxt-host-code-obj
          and buf_trn-doc.contract-code = v-contract-code
          and buf_trn-doc.obj-type      = temp-obj-firm.obj-type
          and buf_trn-doc.obj-code      = temp-obj-firm.obj-code
          and buf_trn-doc.fact-order    <  v-fact-order-end
       by buf_trn-doc.fact-order :
        if x-SET_val_TYPE = 1 then do:
          if buf_trn-doc.tot-rubl = 0 or buf_trn-doc.tot-rubl = ? then next .
        end.
        else do:
          if buf_trn-doc.tot-doc = 0 or buf_trn-doc.tot-doc = ? then next .
        end.
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
        if buf_trn-doc.fact-order < v-fact-order-start then do:
          case buf_trn-doc.ext-doc-type :
            when 'ee':U or
            when 'es':U or
            when 'we':U or
            when 'wm':U or
            when 'ee':U  or
            when 'vt':U  or
            when 'vp':U then do:
              if x-SET_val_TYPE = 1  then assign  temp-doc.sum2 = temp-doc.sum2 + buf_trn-doc.tot-rubl .
              else                        assign  temp-doc.sum2 = temp-doc.sum2 + buf_trn-doc.tot-doc .
            end.
            when 're':U or
            when 'rs':U then do:
              if x-SET_val_TYPE = 1  then assign  temp-doc.sum2 = temp-doc.sum2 - buf_trn-doc.tot-rubl .
              else                        assign  temp-doc.sum2 = temp-doc.sum2 - buf_trn-doc.tot-doc .
            end.
          end.
        end.
        else do:
          case buf_trn-doc.ext-doc-type :
            when 'ee':U or
            when 'es':U or
            when 'we':U or
            when 'wm':U or
            when 'ee':U  or
            when 'vt':U  or
            when 'vp':U then do:
              create temp-sum .
              assign
                temp-sum.contr      = v-contract-code
                temp-sum.dat        = buf_trn-doc.fact-date
                temp-sum.num        = buf_trn-doc.doc-code
                temp-sum.cli-type   = temp-cli.obj-type
                temp-sum.cli-code   = temp-cli.obj-code
                temp-sum.fact-order = buf_trn-doc.fact-order
                temp-sum.type       = 2
              .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run docextnm in g#library
  (input  temp-sum.num
  ,output temp-sum.styp
  )  .
              if temp-sum.styp = "??" then assign temp-sum.styp = "" .
              if x-SET_val_TYPE = 1  then assign  temp-sum.sum = buf_trn-doc.tot-rubl .
              else                        assign  temp-sum.sum = buf_trn-doc.tot-doc .
            end.
            when 're':U or
            when 'rs':U then do:
              create temp-sum .
              assign
                temp-sum.contr      = v-contract-code
                temp-sum.dat        = buf_trn-doc.fact-date
                temp-sum.num        = buf_trn-doc.doc-code
                temp-sum.cli-type   = temp-cli.obj-type
                temp-sum.cli-code   = temp-cli.obj-code
                temp-sum.fact-order = buf_trn-doc.fact-order
                temp-sum.type       = 2
              .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run docextnm in g#library
  (input  temp-sum.num
  ,output temp-sum.styp
  )  .
              if temp-sum.styp = "??" then assign temp-sum.styp = "" .
              if x-SET_val_TYPE = 1  then assign  temp-sum.sum = - buf_trn-doc.tot-rubl .
              else                        assign  temp-sum.sum = - buf_trn-doc.tot-doc .
            end.
          end.
        end.
      end.
    end.
    assign  temp-cli.sum2 = temp-cli.sum2 + temp-doc.sum2 .
    for each temp-sum where temp-sum.contr = v-contract-code break by temp-sum.fact-order :
      if is-date then run new-date in this-procedure .
      else do:
        assign  temp-sum.ind = temp-doc.num2      temp-doc.num2 = temp-doc.num2 + 1 .
      end.
    end.
  end.
  if is-fo then do:
    find last buf_arh-fin-ob-contr no-lock
      where buf_arh-fin-ob-contr.host-code      = v-cntxt-host-code-obj
        and buf_arh-fin-ob-contr.contract-code  = v-contract-code
        and buf_arh-fin-ob-contr.calc-curr-code = v-curr-r-b
        and buf_arh-fin-ob-contr.fin-ext-doc-type = 'при':U
        and buf_arh-fin-ob-contr.sum-type       = ""
        and buf_arh-fin-ob-contr.fact-order    <= v-fact-order-start
        and buf_arh-fin-ob-contr.cli-type       = temp-cli.obj-type
        and buf_arh-fin-ob-contr.cli-code       = temp-cli.obj-code
    no-error .
    if available buf_arh-fin-ob-contr then
      assign
        temp-doc.sum3 = temp-doc.sum3 + (if available buf_contract and buf_contract.doc-type = 'рас':U then (buf_arh-fin-ob-contr.expense - buf_arh-fin-ob-contr.income) else (buf_arh-fin-ob-contr.income - buf_arh-fin-ob-contr.expense))
        temp-cli.sum3 = temp-cli.sum3 + temp-doc.sum3
      .
    for each buf_fin-ob no-lock
      where buf_fin-ob.host-code     = v-cntxt-host-code-obj
        and buf_fin-ob.contract-code = v-contract-code
        and buf_fin-ob.status_       = 'факт':U
        and buf_fin-ob.fact-order    >= v-fact-order-start
        and buf_fin-ob.fact-order    <  v-fact-order-end
      :
      if v-contract-code = 0 then do:
         if (  (buf_fin-ob.receiver-type <> temp-cli.obj-type or buf_fin-ob.receiver-code <> temp-cli.obj-code)
           and (buf_fin-ob.payer-type    <> temp-cli.obj-type or buf_fin-ob.payer-code <> temp-cli.obj-code ) ) then next .
      end.
      create temp-sum .
      assign
        temp-sum.contr = v-contract-code
        temp-sum.dat   = buf_fin-ob.fact-date
        temp-sum.num   = buf_fin-ob.prn-doc-code
        temp-sum.type  = 3
        temp-sum.cli-type   = temp-cli.obj-type
        temp-sum.cli-code   = temp-cli.obj-code
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
      if x-SET_val_TYPE = 1  then assign temp-sum.sum = buf_fin-ob.sum-rubl .
      else                        assign temp-sum.sum = buf_fin-ob.sum-base .
      if  temp-sum.sum <= 0 then assign temp-sum.styp = "ПФО" .
      else                       assign temp-sum.styp = "РФО" .
      if is-date then run new-date in this-procedure .
      else assign   temp-sum.ind   = temp-doc.num3   temp-doc.num3  = temp-doc.num3 + 1  .
    end.
  end.
  if is-fin then do:
    run CalcOstatFin(input 'ппп':U  , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then v-sum-e else 0 - v-sum-e) .
    run CalcOstatFin(input 'рпп':U , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then 0 - v-sum-i else v-sum-i) .
    run CalcOstatFinNal(input 'пко':U   , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then v-sum-e else 0 - v-sum-e)  .
    run CalcOstatFinNal(input 'рко':U  , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then 0 - v-sum-i else v-sum-i) .
    run CalcOstatFinNal(input 'апп':U , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then v-sum-e else 0 - v-sum-e) .
    run CalcOstatFinNal(input 'апр':U, output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then 0 - v-sum-i else v-sum-i) .
    assign temp-cli.sum4 = temp-cli.sum4 + temp-doc.sum4 .
    for each buf_fin-doc no-lock
      where buf_fin-doc.host-code     = v-cntxt-host-code-obj
        and buf_fin-doc.contract-code = v-contract-code
        and buf_fin-doc.status_       = 'факт':U
        and buf_fin-doc.fact-order    >= v-fact-order-start
        and buf_fin-doc.fact-order    <  v-fact-order-end
      :
      if v-contract-code = 0 then do:
         if (  (buf_fin-doc.receiver-type <> temp-cli.obj-type or buf_fin-doc.receiver-code <> temp-cli.obj-code)
           and (buf_fin-doc.payer-type    <> temp-cli.obj-type or buf_fin-doc.payer-code    <> temp-cli.obj-code ) ) then next .
      end.
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
      create temp-sum .
      assign
        temp-sum.contr = v-contract-code
        temp-sum.dat   = buf_fin-doc.fact-date
        temp-sum.num   = buf_fin-doc.prn-doc-code
        temp-sum.styp  = buf_fin-doc.fin-ext-doc-type
        temp-sum.type  = 4
        temp-sum.cli-type   = temp-cli.obj-type
        temp-sum.cli-code   = temp-cli.obj-code
      .
      if x-SET_val_TYPE = 1  then assign temp-sum.sum = buf_fin-doc.sum-rubl .
      else                        assign temp-sum.sum = buf_fin-doc.sum-base .
      if buf_fin-doc.fin-ext-doc-type = 'ппп':U or buf_fin-doc.fin-ext-doc-type = 'пко':U or buf_fin-doc.fin-ext-doc-type = 'апп':U then assign temp-sum.sum = - temp-sum.sum .
       if available buf_contract and buf_contract.doc-type = 'рас':U then assign temp-sum.sum = - temp-sum.sum .
      if is-date then run new-date in this-procedure .
      else assign   temp-sum.ind   = temp-doc.num4   temp-doc.num4  = temp-doc.num4 + 1  .
    end.
  end.
  if p-contr-code = 0 then do:
    if is-date then do:
      if temp-doc.sum2 = 0 and temp-doc.sum3 = 0 and temp-doc.sum4 = 0 then do:
        find first temp-date
          where temp-date.dat      = temp-sum.dat
            and temp-date.cli-type = temp-sum.cli-type
            and temp-date.cli-code = temp-sum.cli-code
            and temp-date.contr    = temp-sum.contr
        no-error .
        if not available temp-date then delete temp-doc .
      end.
    end.
    else do:
      if temp-doc.sum2 = 0 and temp-doc.sum3 = 0 and temp-doc.sum4 = 0 and
         temp-doc.num2 = 0 and temp-doc.num3 = 0 and temp-doc.num4 = 0 then delete temp-doc .
    end.
  end.
        end.
      end.
    end.
    else do:
      for each G#CUSTOMER :
        find first buf_clients no-lock where buf_clients.obj-type = G#CUSTOMER.obj-type and buf_clients.obj-code = G#CUSTOMER.obj-code .
        create temp-cli .
        assign
          temp-cli.obj-type = buf_clients.obj-type
          temp-cli.obj-code = buf_clients.obj-code
          temp-cli.obj-name = buf_clients.obj-name
        .
        assign v-contract-code = 0 .
define variable vss-include-info30 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  create temp-doc .
  assign
    temp-doc.contr      = v-contract-code
    temp-doc.cli-type   = temp-cli.obj-type
    temp-doc.cli-code   = temp-cli.obj-code
  .
  if v-contract-code > 0 then assign temp-doc.contr-name = "Договор № " + buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date) + " (усл.ген. " + buf_contract.usl-opl + ")" .
  else                        assign temp-doc.contr-name = "Без договора" .
  if is-real then do:
    for each temp-obj-firm :
      for each buf_trn-doc no-lock
        where buf_trn-doc.host-code     = v-cntxt-host-code-obj
          and buf_trn-doc.contract-code = v-contract-code
          and buf_trn-doc.obj-type      = temp-obj-firm.obj-type
          and buf_trn-doc.obj-code      = temp-obj-firm.obj-code
          and buf_trn-doc.fact-order    <  v-fact-order-end
       by buf_trn-doc.fact-order :
        if x-SET_val_TYPE = 1 then do:
          if buf_trn-doc.tot-rubl = 0 or buf_trn-doc.tot-rubl = ? then next .
        end.
        else do:
          if buf_trn-doc.tot-doc = 0 or buf_trn-doc.tot-doc = ? then next .
        end.
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
        if buf_trn-doc.fact-order < v-fact-order-start then do:
          case buf_trn-doc.ext-doc-type :
            when 'ee':U or
            when 'es':U or
            when 'we':U or
            when 'wm':U or
            when 'ee':U  or
            when 'vt':U  or
            when 'vp':U then do:
              if x-SET_val_TYPE = 1  then assign  temp-doc.sum2 = temp-doc.sum2 + buf_trn-doc.tot-rubl .
              else                        assign  temp-doc.sum2 = temp-doc.sum2 + buf_trn-doc.tot-doc .
            end.
            when 're':U or
            when 'rs':U then do:
              if x-SET_val_TYPE = 1  then assign  temp-doc.sum2 = temp-doc.sum2 - buf_trn-doc.tot-rubl .
              else                        assign  temp-doc.sum2 = temp-doc.sum2 - buf_trn-doc.tot-doc .
            end.
          end.
        end.
        else do:
          case buf_trn-doc.ext-doc-type :
            when 'ee':U or
            when 'es':U or
            when 'we':U or
            when 'wm':U or
            when 'ee':U  or
            when 'vt':U  or
            when 'vp':U then do:
              create temp-sum .
              assign
                temp-sum.contr      = v-contract-code
                temp-sum.dat        = buf_trn-doc.fact-date
                temp-sum.num        = buf_trn-doc.doc-code
                temp-sum.cli-type   = temp-cli.obj-type
                temp-sum.cli-code   = temp-cli.obj-code
                temp-sum.fact-order = buf_trn-doc.fact-order
                temp-sum.type       = 2
              .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run docextnm in g#library
  (input  temp-sum.num
  ,output temp-sum.styp
  )  .
              if temp-sum.styp = "??" then assign temp-sum.styp = "" .
              if x-SET_val_TYPE = 1  then assign  temp-sum.sum = buf_trn-doc.tot-rubl .
              else                        assign  temp-sum.sum = buf_trn-doc.tot-doc .
            end.
            when 're':U or
            when 'rs':U then do:
              create temp-sum .
              assign
                temp-sum.contr      = v-contract-code
                temp-sum.dat        = buf_trn-doc.fact-date
                temp-sum.num        = buf_trn-doc.doc-code
                temp-sum.cli-type   = temp-cli.obj-type
                temp-sum.cli-code   = temp-cli.obj-code
                temp-sum.fact-order = buf_trn-doc.fact-order
                temp-sum.type       = 2
              .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run docextnm in g#library
  (input  temp-sum.num
  ,output temp-sum.styp
  )  .
              if temp-sum.styp = "??" then assign temp-sum.styp = "" .
              if x-SET_val_TYPE = 1  then assign  temp-sum.sum = - buf_trn-doc.tot-rubl .
              else                        assign  temp-sum.sum = - buf_trn-doc.tot-doc .
            end.
          end.
        end.
      end.
    end.
    assign  temp-cli.sum2 = temp-cli.sum2 + temp-doc.sum2 .
    for each temp-sum where temp-sum.contr = v-contract-code break by temp-sum.fact-order :
      if is-date then run new-date in this-procedure .
      else do:
        assign  temp-sum.ind = temp-doc.num2      temp-doc.num2 = temp-doc.num2 + 1 .
      end.
    end.
  end.
  if is-fo then do:
    find last buf_arh-fin-ob-contr no-lock
      where buf_arh-fin-ob-contr.host-code      = v-cntxt-host-code-obj
        and buf_arh-fin-ob-contr.contract-code  = v-contract-code
        and buf_arh-fin-ob-contr.calc-curr-code = v-curr-r-b
        and buf_arh-fin-ob-contr.fin-ext-doc-type = 'при':U
        and buf_arh-fin-ob-contr.sum-type       = ""
        and buf_arh-fin-ob-contr.fact-order    <= v-fact-order-start
        and buf_arh-fin-ob-contr.cli-type       = temp-cli.obj-type
        and buf_arh-fin-ob-contr.cli-code       = temp-cli.obj-code
    no-error .
    if available buf_arh-fin-ob-contr then
      assign
        temp-doc.sum3 = temp-doc.sum3 + (if available buf_contract and buf_contract.doc-type = 'рас':U then (buf_arh-fin-ob-contr.expense - buf_arh-fin-ob-contr.income) else (buf_arh-fin-ob-contr.income - buf_arh-fin-ob-contr.expense))
        temp-cli.sum3 = temp-cli.sum3 + temp-doc.sum3
      .
    for each buf_fin-ob no-lock
      where buf_fin-ob.host-code     = v-cntxt-host-code-obj
        and buf_fin-ob.contract-code = v-contract-code
        and buf_fin-ob.status_       = 'факт':U
        and buf_fin-ob.fact-order    >= v-fact-order-start
        and buf_fin-ob.fact-order    <  v-fact-order-end
      :
      if v-contract-code = 0 then do:
         if (  (buf_fin-ob.receiver-type <> temp-cli.obj-type or buf_fin-ob.receiver-code <> temp-cli.obj-code)
           and (buf_fin-ob.payer-type    <> temp-cli.obj-type or buf_fin-ob.payer-code <> temp-cli.obj-code ) ) then next .
      end.
      create temp-sum .
      assign
        temp-sum.contr = v-contract-code
        temp-sum.dat   = buf_fin-ob.fact-date
        temp-sum.num   = buf_fin-ob.prn-doc-code
        temp-sum.type  = 3
        temp-sum.cli-type   = temp-cli.obj-type
        temp-sum.cli-code   = temp-cli.obj-code
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
      if x-SET_val_TYPE = 1  then assign temp-sum.sum = buf_fin-ob.sum-rubl .
      else                        assign temp-sum.sum = buf_fin-ob.sum-base .
      if  temp-sum.sum <= 0 then assign temp-sum.styp = "ПФО" .
      else                       assign temp-sum.styp = "РФО" .
      if is-date then run new-date in this-procedure .
      else assign   temp-sum.ind   = temp-doc.num3   temp-doc.num3  = temp-doc.num3 + 1  .
    end.
  end.
  if is-fin then do:
    run CalcOstatFin(input 'ппп':U  , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then v-sum-e else 0 - v-sum-e) .
    run CalcOstatFin(input 'рпп':U , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then 0 - v-sum-i else v-sum-i) .
    run CalcOstatFinNal(input 'пко':U   , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then v-sum-e else 0 - v-sum-e)  .
    run CalcOstatFinNal(input 'рко':U  , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then 0 - v-sum-i else v-sum-i) .
    run CalcOstatFinNal(input 'апп':U , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then v-sum-e else 0 - v-sum-e) .
    run CalcOstatFinNal(input 'апр':U, output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then 0 - v-sum-i else v-sum-i) .
    assign temp-cli.sum4 = temp-cli.sum4 + temp-doc.sum4 .
    for each buf_fin-doc no-lock
      where buf_fin-doc.host-code     = v-cntxt-host-code-obj
        and buf_fin-doc.contract-code = v-contract-code
        and buf_fin-doc.status_       = 'факт':U
        and buf_fin-doc.fact-order    >= v-fact-order-start
        and buf_fin-doc.fact-order    <  v-fact-order-end
      :
      if v-contract-code = 0 then do:
         if (  (buf_fin-doc.receiver-type <> temp-cli.obj-type or buf_fin-doc.receiver-code <> temp-cli.obj-code)
           and (buf_fin-doc.payer-type    <> temp-cli.obj-type or buf_fin-doc.payer-code    <> temp-cli.obj-code ) ) then next .
      end.
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
      create temp-sum .
      assign
        temp-sum.contr = v-contract-code
        temp-sum.dat   = buf_fin-doc.fact-date
        temp-sum.num   = buf_fin-doc.prn-doc-code
        temp-sum.styp  = buf_fin-doc.fin-ext-doc-type
        temp-sum.type  = 4
        temp-sum.cli-type   = temp-cli.obj-type
        temp-sum.cli-code   = temp-cli.obj-code
      .
      if x-SET_val_TYPE = 1  then assign temp-sum.sum = buf_fin-doc.sum-rubl .
      else                        assign temp-sum.sum = buf_fin-doc.sum-base .
      if buf_fin-doc.fin-ext-doc-type = 'ппп':U or buf_fin-doc.fin-ext-doc-type = 'пко':U or buf_fin-doc.fin-ext-doc-type = 'апп':U then assign temp-sum.sum = - temp-sum.sum .
       if available buf_contract and buf_contract.doc-type = 'рас':U then assign temp-sum.sum = - temp-sum.sum .
      if is-date then run new-date in this-procedure .
      else assign   temp-sum.ind   = temp-doc.num4   temp-doc.num4  = temp-doc.num4 + 1  .
    end.
  end.
  if p-contr-code = 0 then do:
    if is-date then do:
      if temp-doc.sum2 = 0 and temp-doc.sum3 = 0 and temp-doc.sum4 = 0 then do:
        find first temp-date
          where temp-date.dat      = temp-sum.dat
            and temp-date.cli-type = temp-sum.cli-type
            and temp-date.cli-code = temp-sum.cli-code
            and temp-date.contr    = temp-sum.contr
        no-error .
        if not available temp-date then delete temp-doc .
      end.
    end.
    else do:
      if temp-doc.sum2 = 0 and temp-doc.sum3 = 0 and temp-doc.sum4 = 0 and
         temp-doc.num2 = 0 and temp-doc.num3 = 0 and temp-doc.num4 = 0 then delete temp-doc .
    end.
  end.
        for each buf_contract no-lock
          where buf_contract.host-code = v-cntxt-host-code-obj
            and buf_contract.cli-type  = buf_clients.obj-type
            and buf_contract.cli-code  = buf_clients.obj-code
            and buf_contract.doc-type  = 'рас':U
          :
          assign v-contract-code = buf_contract.contract-code .
define variable vss-include-info33 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  create temp-doc .
  assign
    temp-doc.contr      = v-contract-code
    temp-doc.cli-type   = temp-cli.obj-type
    temp-doc.cli-code   = temp-cli.obj-code
  .
  if v-contract-code > 0 then assign temp-doc.contr-name = "Договор № " + buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date) + " (усл.ген. " + buf_contract.usl-opl + ")" .
  else                        assign temp-doc.contr-name = "Без договора" .
  if is-real then do:
    for each temp-obj-firm :
      for each buf_trn-doc no-lock
        where buf_trn-doc.host-code     = v-cntxt-host-code-obj
          and buf_trn-doc.contract-code = v-contract-code
          and buf_trn-doc.obj-type      = temp-obj-firm.obj-type
          and buf_trn-doc.obj-code      = temp-obj-firm.obj-code
          and buf_trn-doc.fact-order    <  v-fact-order-end
       by buf_trn-doc.fact-order :
        if x-SET_val_TYPE = 1 then do:
          if buf_trn-doc.tot-rubl = 0 or buf_trn-doc.tot-rubl = ? then next .
        end.
        else do:
          if buf_trn-doc.tot-doc = 0 or buf_trn-doc.tot-doc = ? then next .
        end.
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
        if buf_trn-doc.fact-order < v-fact-order-start then do:
          case buf_trn-doc.ext-doc-type :
            when 'ee':U or
            when 'es':U or
            when 'we':U or
            when 'wm':U or
            when 'ee':U  or
            when 'vt':U  or
            when 'vp':U then do:
              if x-SET_val_TYPE = 1  then assign  temp-doc.sum2 = temp-doc.sum2 + buf_trn-doc.tot-rubl .
              else                        assign  temp-doc.sum2 = temp-doc.sum2 + buf_trn-doc.tot-doc .
            end.
            when 're':U or
            when 'rs':U then do:
              if x-SET_val_TYPE = 1  then assign  temp-doc.sum2 = temp-doc.sum2 - buf_trn-doc.tot-rubl .
              else                        assign  temp-doc.sum2 = temp-doc.sum2 - buf_trn-doc.tot-doc .
            end.
          end.
        end.
        else do:
          case buf_trn-doc.ext-doc-type :
            when 'ee':U or
            when 'es':U or
            when 'we':U or
            when 'wm':U or
            when 'ee':U  or
            when 'vt':U  or
            when 'vp':U then do:
              create temp-sum .
              assign
                temp-sum.contr      = v-contract-code
                temp-sum.dat        = buf_trn-doc.fact-date
                temp-sum.num        = buf_trn-doc.doc-code
                temp-sum.cli-type   = temp-cli.obj-type
                temp-sum.cli-code   = temp-cli.obj-code
                temp-sum.fact-order = buf_trn-doc.fact-order
                temp-sum.type       = 2
              .
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run docextnm in g#library
  (input  temp-sum.num
  ,output temp-sum.styp
  )  .
              if temp-sum.styp = "??" then assign temp-sum.styp = "" .
              if x-SET_val_TYPE = 1  then assign  temp-sum.sum = buf_trn-doc.tot-rubl .
              else                        assign  temp-sum.sum = buf_trn-doc.tot-doc .
            end.
            when 're':U or
            when 'rs':U then do:
              create temp-sum .
              assign
                temp-sum.contr      = v-contract-code
                temp-sum.dat        = buf_trn-doc.fact-date
                temp-sum.num        = buf_trn-doc.doc-code
                temp-sum.cli-type   = temp-cli.obj-type
                temp-sum.cli-code   = temp-cli.obj-code
                temp-sum.fact-order = buf_trn-doc.fact-order
                temp-sum.type       = 2
              .
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run docextnm in g#library
  (input  temp-sum.num
  ,output temp-sum.styp
  )  .
              if temp-sum.styp = "??" then assign temp-sum.styp = "" .
              if x-SET_val_TYPE = 1  then assign  temp-sum.sum = - buf_trn-doc.tot-rubl .
              else                        assign  temp-sum.sum = - buf_trn-doc.tot-doc .
            end.
          end.
        end.
      end.
    end.
    assign  temp-cli.sum2 = temp-cli.sum2 + temp-doc.sum2 .
    for each temp-sum where temp-sum.contr = v-contract-code break by temp-sum.fact-order :
      if is-date then run new-date in this-procedure .
      else do:
        assign  temp-sum.ind = temp-doc.num2      temp-doc.num2 = temp-doc.num2 + 1 .
      end.
    end.
  end.
  if is-fo then do:
    find last buf_arh-fin-ob-contr no-lock
      where buf_arh-fin-ob-contr.host-code      = v-cntxt-host-code-obj
        and buf_arh-fin-ob-contr.contract-code  = v-contract-code
        and buf_arh-fin-ob-contr.calc-curr-code = v-curr-r-b
        and buf_arh-fin-ob-contr.fin-ext-doc-type = 'при':U
        and buf_arh-fin-ob-contr.sum-type       = ""
        and buf_arh-fin-ob-contr.fact-order    <= v-fact-order-start
        and buf_arh-fin-ob-contr.cli-type       = temp-cli.obj-type
        and buf_arh-fin-ob-contr.cli-code       = temp-cli.obj-code
    no-error .
    if available buf_arh-fin-ob-contr then
      assign
        temp-doc.sum3 = temp-doc.sum3 + (if available buf_contract and buf_contract.doc-type = 'рас':U then (buf_arh-fin-ob-contr.expense - buf_arh-fin-ob-contr.income) else (buf_arh-fin-ob-contr.income - buf_arh-fin-ob-contr.expense))
        temp-cli.sum3 = temp-cli.sum3 + temp-doc.sum3
      .
    for each buf_fin-ob no-lock
      where buf_fin-ob.host-code     = v-cntxt-host-code-obj
        and buf_fin-ob.contract-code = v-contract-code
        and buf_fin-ob.status_       = 'факт':U
        and buf_fin-ob.fact-order    >= v-fact-order-start
        and buf_fin-ob.fact-order    <  v-fact-order-end
      :
      if v-contract-code = 0 then do:
         if (  (buf_fin-ob.receiver-type <> temp-cli.obj-type or buf_fin-ob.receiver-code <> temp-cli.obj-code)
           and (buf_fin-ob.payer-type    <> temp-cli.obj-type or buf_fin-ob.payer-code <> temp-cli.obj-code ) ) then next .
      end.
      create temp-sum .
      assign
        temp-sum.contr = v-contract-code
        temp-sum.dat   = buf_fin-ob.fact-date
        temp-sum.num   = buf_fin-ob.prn-doc-code
        temp-sum.type  = 3
        temp-sum.cli-type   = temp-cli.obj-type
        temp-sum.cli-code   = temp-cli.obj-code
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
      if x-SET_val_TYPE = 1  then assign temp-sum.sum = buf_fin-ob.sum-rubl .
      else                        assign temp-sum.sum = buf_fin-ob.sum-base .
      if  temp-sum.sum <= 0 then assign temp-sum.styp = "ПФО" .
      else                       assign temp-sum.styp = "РФО" .
      if is-date then run new-date in this-procedure .
      else assign   temp-sum.ind   = temp-doc.num3   temp-doc.num3  = temp-doc.num3 + 1  .
    end.
  end.
  if is-fin then do:
    run CalcOstatFin(input 'ппп':U  , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then v-sum-e else 0 - v-sum-e) .
    run CalcOstatFin(input 'рпп':U , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then 0 - v-sum-i else v-sum-i) .
    run CalcOstatFinNal(input 'пко':U   , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then v-sum-e else 0 - v-sum-e)  .
    run CalcOstatFinNal(input 'рко':U  , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then 0 - v-sum-i else v-sum-i) .
    run CalcOstatFinNal(input 'апп':U , output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then v-sum-e else 0 - v-sum-e) .
    run CalcOstatFinNal(input 'апр':U, output v-sum-e, output v-sum-i) .
    assign  temp-doc.sum4 = temp-doc.sum4 + (if available buf_contract and buf_contract.doc-type = 'рас':U then 0 - v-sum-i else v-sum-i) .
    assign temp-cli.sum4 = temp-cli.sum4 + temp-doc.sum4 .
    for each buf_fin-doc no-lock
      where buf_fin-doc.host-code     = v-cntxt-host-code-obj
        and buf_fin-doc.contract-code = v-contract-code
        and buf_fin-doc.status_       = 'факт':U
        and buf_fin-doc.fact-order    >= v-fact-order-start
        and buf_fin-doc.fact-order    <  v-fact-order-end
      :
      if v-contract-code = 0 then do:
         if (  (buf_fin-doc.receiver-type <> temp-cli.obj-type or buf_fin-doc.receiver-code <> temp-cli.obj-code)
           and (buf_fin-doc.payer-type    <> temp-cli.obj-type or buf_fin-doc.payer-code    <> temp-cli.obj-code ) ) then next .
      end.
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
      create temp-sum .
      assign
        temp-sum.contr = v-contract-code
        temp-sum.dat   = buf_fin-doc.fact-date
        temp-sum.num   = buf_fin-doc.prn-doc-code
        temp-sum.styp  = buf_fin-doc.fin-ext-doc-type
        temp-sum.type  = 4
        temp-sum.cli-type   = temp-cli.obj-type
        temp-sum.cli-code   = temp-cli.obj-code
      .
      if x-SET_val_TYPE = 1  then assign temp-sum.sum = buf_fin-doc.sum-rubl .
      else                        assign temp-sum.sum = buf_fin-doc.sum-base .
      if buf_fin-doc.fin-ext-doc-type = 'ппп':U or buf_fin-doc.fin-ext-doc-type = 'пко':U or buf_fin-doc.fin-ext-doc-type = 'апп':U then assign temp-sum.sum = - temp-sum.sum .
       if available buf_contract and buf_contract.doc-type = 'рас':U then assign temp-sum.sum = - temp-sum.sum .
      if is-date then run new-date in this-procedure .
      else assign   temp-sum.ind   = temp-doc.num4   temp-doc.num4  = temp-doc.num4 + 1  .
    end.
  end.
  if p-contr-code = 0 then do:
    if is-date then do:
      if temp-doc.sum2 = 0 and temp-doc.sum3 = 0 and temp-doc.sum4 = 0 then do:
        find first temp-date
          where temp-date.dat      = temp-sum.dat
            and temp-date.cli-type = temp-sum.cli-type
            and temp-date.cli-code = temp-sum.cli-code
            and temp-date.contr    = temp-sum.contr
        no-error .
        if not available temp-date then delete temp-doc .
      end.
    end.
    else do:
      if temp-doc.sum2 = 0 and temp-doc.sum3 = 0 and temp-doc.sum4 = 0 and
         temp-doc.num2 = 0 and temp-doc.num3 = 0 and temp-doc.num4 = 0 then delete temp-doc .
    end.
  end.
        end.
      end.
    end.
  end.
if session :set-wait-state( "compiler" ) then.
  Line = fill("-", 250).
  assign
    make-excel = yes
    v-file-name = string(session :temp-directory) + "rpt" + string( g#report-num ) + ".txt"
  .
  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .
  if num-col > 2 then run prn-lib-open-stream  in this-procedure (input parParentProc,input 43,input yes,input no).
  else                run prn-lib-open-stream  in this-procedure (input parParentProc,input 63,input yes,input no).
  FORM with FRAME f-doc .
  run PrintTitul in this-procedure .
  run PutColumnTitulExcel in this-procedure .
  for each temp-cli :
    find first temp-doc where temp-doc.cli-type = temp-cli.obj-type and temp-doc.cli-code = temp-cli.obj-code no-error .
    if not available temp-doc then delete temp-cli .
  end.
  if p-contr-code > 0 then do:
    for each temp-doc break by temp-doc.contr:
      if first-of(temp-doc.contr) then do:
        assign
          v-sm1-contr = 0
          v-sm2-contr = 0
          v-sm3-contr = 0
          v-sm4-contr = 0
        .
        run is-page in this-procedure .
        PUT STREAM PrnLibStream  "|" at 1  temp-doc.contr-name  format string("X(" + string( num-col * 45 + 1) + ")") "|" at num-col * 45 + 18 skip .
        run macr_excel_char(temp-doc.contr-name, v-row, 1) .
        assign v-row = v-row  + 1 .
        put stream PrnLibStream  "|" at 1  "Остаток на начало:" format "X(20)" .
        run macr_excel_char("Остаток на начало:"  , v-row, 1) .
        run PrnSumCli in this-procedure ( temp-doc.sum2, temp-doc.sum3, temp-doc.sum4) .
      end.
      run prn-line in this-procedure .
      if last-of(temp-doc.contr) then do:
        put stream PrnLibStream  "|" at 1 "Итого оборот:" format "X(20)" .
        run macr_excel_char("Итого оборот:"  , v-row, 1) .
        run PrnSumCli in this-procedure ( v-sm2-contr, v-sm3-contr, v-sm4-contr) .
        put stream PrnLibStream  "|" at 1 "Остаток по договору:" format "X(22)" .
        run macr_excel_char("Остаток по договору:"  , v-row, 1) .
        run PrnSumCli in this-procedure ( temp-doc.sum2 + v-sm2-contr, temp-doc.sum3 + v-sm3-contr, temp-doc.sum4 + v-sm4-contr) .
        put stream PrnLibStream  Line format string("X(" + string( num-col * 45 + 18) + ")")  skip .
      end.
    end.
  end.
  else do:
    for each temp-cli :
      assign
        v-sm1-cli = 0
        v-sm2-cli = 0
        v-sm3-cli = 0
        v-sm4-cli = 0
      .
      PUT STREAM PrnLibStream string("| Поставщик: " + temp-cli.obj-name + " (" + temp-cli.obj-type + "#" + string(temp-cli.obj-code) + ")" ) format string("X(" + string( num-col * 45 + 1) + ")") "|" at num-col * 45 + 18 skip .
      run macr_excel_char(string("| Поставщик: " + temp-cli.obj-name + " (" + temp-cli.obj-type + "#" + string(temp-cli.obj-code) + ")" ), v-row, 1) .
      assign v-row = v-row  + 1 .
      put stream PrnLibStream  "|" at 1 "Остаток на начало:" format "X(20)" .
      run macr_excel_char("Остаток на начало:" , v-row, 1) .
      run PrnSumCli in this-procedure (temp-cli.sum2, temp-cli.sum3, temp-cli.sum4) .
      for each temp-doc where temp-doc.cli-type = temp-cli.obj-type and temp-doc.cli-code = temp-cli.obj-code break by temp-doc.contr:
        if first-of(temp-doc.contr) then do:
          assign
            v-sm1-contr = 0
            v-sm2-contr = 0
            v-sm3-contr = 0
            v-sm4-contr = 0
          .
          PUT STREAM PrnLibStream  "|" at 1  temp-doc.contr-name  format string("X(" + string( num-col * 45 + 1) + ")") "|" at num-col * 45 + 18 skip .
          run macr_excel_char(temp-doc.contr-name, v-row, 1) .
          assign v-row = v-row  + 1 .
          put stream PrnLibStream  "|" at 1  "Остаток на начало:" format "X(20)" .
          run macr_excel_char("Остаток на начало:" , v-row, 1) .
          run PrnSumCli in this-procedure ( temp-doc.sum2, temp-doc.sum3, temp-doc.sum4) .
        end.
        run prn-line in this-procedure .
        if last-of(temp-doc.contr) then do:
          put stream PrnLibStream  "|" at 1 "Итого оборот:" format "X(20)" .
          run macr_excel_char("Итого оборот:"  , v-row, 1) .
          run PrnSumCli in this-procedure ( v-sm2-contr, v-sm3-contr, v-sm4-contr) .
          put stream PrnLibStream  "|" at 1 "Остаток по договору:" format "X(22)" .
          run macr_excel_char("Остаток по договору:"  , v-row, 1) .
          run PrnSumCli in this-procedure ( temp-doc.sum2 + v-sm2-contr, temp-doc.sum3 + v-sm3-contr, temp-doc.sum4 + v-sm4-contr) .
          put stream PrnLibStream  Line format string("X(" + string( num-col * 45 + 18) + ")")  skip .
          assign
            v-sm1-cli = v-sm1-cli + v-sm1-contr
            v-sm2-cli = v-sm2-cli + v-sm2-contr
            v-sm3-cli = v-sm3-cli + v-sm3-contr
            v-sm4-cli = v-sm4-cli + v-sm4-contr
          .
        end.
      end.
      put stream PrnLibStream  "|" at 1 "Итого оборот:" format "X(20)" .
      run macr_excel_char("Итого оборот:"  , v-row, 1) .
      run PrnSumCli in this-procedure ( v-sm2-cli, v-sm3-cli, v-sm4-cli) .
      put stream PrnLibStream  "|" at 1 string("Остаток по пост." + temp-cli.obj-type + "#" + string(temp-cli.obj-code)) format "X(22)" .
      run macr_excel_char(string("Ост. по пост." + temp-cli.obj-type + "#" + string(temp-cli.obj-code)) , v-row, 1) .
      run PrnSumCli in this-procedure ( temp-cli.sum2 + v-sm2-cli, temp-cli.sum3 + v-sm3-cli, temp-cli.sum4 + v-sm4-cli) .
      put stream PrnLibStream  Line format string("X(" + string( num-col * 45 + 18) + ")")  skip .
    end.
  end.
  HIDE stream PrnLibStream FRAME BottomFrame .
  OUTPUT stream PrnLibStream CLOSE.
  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run end-proc .
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
if session :set-wait-state( "" ) then.
  if num-col > 2 then run prn-lib-prn-file in this-procedure (input parParentProc,input 8).
  else                run prn-lib-prn-file in this-procedure (input parParentProc,input 0).
end.
procedure prn-line :
  do on error undo, return error return-value :
   if is-date then do:
     for each temp-date
       where temp-date.cli-type = temp-doc.cli-type
         and temp-date.cli-code = temp-doc.cli-code
         and temp-date.contr    = temp-doc.contr
       :
       do ind = 0 to maximum( temp-date.num2, temp-date.num3, temp-date.num4) - 1 :
         assign kk = 0  .
         do jj = 2 to 4:
           if jj = 2 and not is-real then next.
           if jj = 3 and not is-fo   then next.
           if jj = 4 and not is-fin  then next.
           find first temp-sum
             where temp-sum.cli-type = temp-doc.cli-type
               and temp-sum.cli-code = temp-doc.cli-code
               and temp-sum.contr    = temp-doc.contr
               and temp-sum.dat      = temp-date.dat
               and temp-sum.ind      = ind
               and temp-sum.type     = jj
           no-error .
           if available temp-sum then do:
             if not itog-only then do:
               run is-page in this-procedure .
               put stream PrnLibStream
                 "|" at (1 + kk * 45)  temp-sum.dat    format "99/99/99"
                 "|" at (10 + kk * 45)  temp-sum.num    format "X(10)"
                 "|" at (22 + kk * 45)  temp-sum.styp   format "X(3)"
                 "|" at (26 + kk * 45)  temp-sum.sum    format "->>>,>>>,>>>,>>9.99"
               .
               run macr_excel_char(string(temp-sum.dat,"99/99/9999")  , v-row, kk * 4 + 1 ) .
               run macr_excel_char(temp-sum.num  , v-row, kk * 4 + 2) .
               run macr_excel_char(temp-sum.styp , v-row, kk * 4 + 3 ) .
               run macr_excel_sum (temp-sum.sum  , v-row, kk * 4 + 4 , 2) .
             end.
             case jj :
               when 1 then assign v-sm1-contr = v-sm1-contr + temp-sum.sum .
               when 2 then assign v-sm2-contr = v-sm2-contr + temp-sum.sum .
               when 3 then assign v-sm3-contr = v-sm3-contr + temp-sum.sum .
               when 4 then assign v-sm4-contr = v-sm4-contr + temp-sum.sum .
             end.
           end.
           else do:
             if not itog-only then do:
               run is-page in this-procedure .
               put stream PrnLibStream
                 "|" at (1 + kk * 45)
                 "|" at (10 + kk * 45)
                 "|" at (22 + kk * 45)
                 "|" at (26 + kk * 45)
               .
             end.
           end.
           assign kk = kk + 1 .
         end.
         if not itog-only then do:
           put stream PrnLibStream "|" at num-col * 45 + 1  "|" at num-col * 45 + 18   skip .
           assign v-row = v-row + 1 .
         end.
       end.
     end.
   end.
   else do:
     do ind = 0 to maximum(temp-doc.num2, temp-doc.num3, temp-doc.num4) - 1 :
       assign kk = 0  .
       do jj = 2 to 4:
         if jj = 2 and not is-real then next.
         if jj = 3 and not is-fo   then next.
         if jj = 4 and not is-fin  then next.
         find first temp-sum
           where temp-sum.cli-type = temp-doc.cli-type
             and temp-sum.cli-code = temp-doc.cli-code
             and temp-sum.contr    = temp-doc.contr
             and temp-sum.ind      = ind
             and temp-sum.type     = jj
         no-error .
         if available temp-sum then do:
           if not itog-only then do:
             run is-page in this-procedure .
             put stream PrnLibStream
               "|" at (1 + kk * 45)  temp-sum.dat    format "99/99/99"
               "|" at (10 + kk * 45)  temp-sum.num    format "X(10)"
               "|" at (22 + kk * 45)  temp-sum.styp   format "X(3)"
               "|" at (26 + kk * 45)  temp-sum.sum    format "->>>,>>>,>>>,>>9.99"
             .
             run macr_excel_char(string(temp-sum.dat,"99/99/9999")  , v-row, kk * 4 + 1 ) .
             run macr_excel_char(temp-sum.num  , v-row, kk * 4 + 2) .
             run macr_excel_char(temp-sum.styp , v-row, kk * 4 + 3 ) .
             run macr_excel_sum (temp-sum.sum  , v-row, kk * 4 + 4 , 2) .
           end.
           case jj :
             when 1 then assign v-sm1-contr = v-sm1-contr + temp-sum.sum .
             when 2 then assign v-sm2-contr = v-sm2-contr + temp-sum.sum .
             when 3 then assign v-sm3-contr = v-sm3-contr + temp-sum.sum .
             when 4 then assign v-sm4-contr = v-sm4-contr + temp-sum.sum .
           end.
         end.
         else do:
           if not itog-only then do:
             run is-page in this-procedure .
             put stream PrnLibStream
               "|" at (1 + kk * 45)
               "|" at (10 + kk * 45)
               "|" at (22 + kk * 45)
               "|" at (26 + kk * 45)
             .
           end.
         end.
         assign kk = kk + 1 .
       end.
       if not itog-only then do:
         put stream PrnLibStream "|" at num-col * 45 + 1  "|" at num-col * 45 + 18   skip .
         assign v-row = v-row + 1 .
       end.
     end.
   end.
  end.
end procedure.
procedure PutColumnTitulExcel :
  do
  on error undo, return error return-value
  :
    assign  v-row = 5 .
    run macr_excel_char (ReportNAme, 1, 2) .
    run macr_cell_format ( 11, yes, no, ?, 1, 2, 1, 2) .
    run macr_excel_char (str1, 2, 1) .
    assign ii = 1 .
    if is-real then do:
      run macr_excel_char("Реализация", 3, ii + 1) .
      run macr_excel_char("Дата факт", 4, ii) .
      run macr_cell_size (10,?, 4, ii,?,?).
      run macr_excel_char("№ док-та", 4, ii + 1) .
      run macr_cell_size (10,?, 4, ii + 1,?,?).
      run macr_excel_char("тип", 4, ii + 2) .
      run macr_cell_size (4,?, 4, ii + 2,?,?).
      run macr_excel_char(string(" Сумма (" + s-val + ")"), 4, ii + 3) .
      run macr_cell_size (16,?, 4, ii + 3,?,?).
      assign ii = ii + 4  .
    end.
    if is-fo then do:
      run macr_excel_char("Фин. обязательства", 3, ii + 1) .
      run macr_excel_char("Дата факт", 4, ii) .
      run macr_cell_size (10,?, 4, ii,?,?).
      run macr_excel_char("№ док-та", 4, ii + 1) .
      run macr_cell_size (10,?, 4, ii + 1,?,?).
      run macr_excel_char("тип", 4, ii + 2) .
      run macr_cell_size (4,?, 4, ii + 2,?,?).
      run macr_excel_char(string(" Сумма (" + s-val + ")"), 4, ii + 3) .
      run macr_cell_size (16,?, 4, ii + 3,?,?).
      assign ii = ii + 4  .
    end.
    if is-fin then do:
      run macr_excel_char("Платежи", 3, ii + 1) .
      run macr_excel_char("Дата факт", 4, ii) .
      run macr_cell_size (10,?, 4, ii,?,?).
      run macr_excel_char("№ док-та", 4, ii + 1) .
      run macr_cell_size (10,?, 4, ii + 1,?,?).
      run macr_excel_char("тип", 4, ii + 2) .
      run macr_cell_size (4,?, 4, ii + 2,?,?).
      run macr_excel_char(string(" Сумма (" + s-val + ")"), 4, ii + 3) .
      run macr_cell_size (16,?, 4, ii + 3,?,?).
      assign ii = ii + 4  .
    end.
    run macr_excel_char("Сумма долга", 3, ii) .
    run macr_cell_size (14,?, 3, ii,?,?).
    run macr_cell_bordur ( 3, 1, 4, ii) .
    run macr_cell_format ( 10, yes, no, 35, 3, 1, 4, ii) .
    put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 3 , ii    , 3 , ii ) skip .
    put  stream macr_excel unformatted 'BORDER( 0, 1, 1, 1, 0, ,0,0,0,0,0) '  skip .
    put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 4 , ii    , 4 , ii ) skip .
    put  stream macr_excel unformatted 'BORDER( 0, 1, 1, 0, 1, ,0,0,0,0,0) '  skip .
    assign ii = 1 .
    if is-real then do:
      put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 3 , ii    , 3 , ii ) skip .
      put  stream macr_excel unformatted 'BORDER( 0, 1, 0, 1, 1, ,0,0,0,0,0) '  skip .
      put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 3 , ii + 1, 3 , ii + 2 ) skip .
      put  stream macr_excel unformatted 'BORDER( 0, 0, 0, 1, 1, ,0,0,0,0,0) '  skip .
      put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 3 , ii + 3, 3 , ii + 3 ) skip .
      put  stream macr_excel unformatted 'BORDER( 0, 0, 1, 1, 1, ,0,0,0,0,0) '  skip .
      assign ii = ii + 4  .
    end.
    if is-fo then do:
      put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 3 , ii    , 3 , ii ) skip .
      put  stream macr_excel unformatted 'BORDER( 0, 1, 0, 1, 1, ,0,0,0,0,0) '  skip .
      put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 3 , ii + 1, 3 , ii + 2 ) skip .
      put  stream macr_excel unformatted 'BORDER( 0, 0, 0, 1, 1, ,0,0,0,0,0) '  skip .
      put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 3 , ii + 3, 3 , ii + 3 ) skip .
      put  stream macr_excel unformatted 'BORDER( 0, 0, 1, 1, 1, ,0,0,0,0,0) '  skip .
      assign ii = ii + 4  .
    end.
    if is-fin then do:
      put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 3 , ii    , 3 , ii ) skip .
      put  stream macr_excel unformatted 'BORDER( 0, 1, 0, 1, 1, ,0,0,0,0,0) '  skip .
      put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 3 , ii + 1, 3 , ii + 2 ) skip .
      put  stream macr_excel unformatted 'BORDER( 0, 0, 0, 1, 1, ,0,0,0,0,0) '  skip .
      put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 3 , ii + 3, 3 , ii + 3 ) skip .
      put  stream macr_excel unformatted 'BORDER( 0, 0, 1, 1, 1, ,0,0,0,0,0) '  skip .
      assign ii = ii + 4  .
    end.
   end.
end procedure.
procedure is-page :
  do
  on error undo, return error return-value
  :
    if line-counter( PrnLibStream ) + 3 > page-size( PrnLibStream ) then do:
      put stream PrnLibStream  skip Line format string("X(" + string( num-col * 45 + 18) + ")") skip "продолжение - на следующей странице" AT 30 SKIP .
      page stream PrnLibStream .
      run PrintTitul .
    end.
    if  ( v-row ) >= 63000 then do:
      Output stream Macr_Excel  close .
      run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .
      run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
      output stream  Macr_Excel to value(v-file-name) .
      assign
        v-ind = v-ind + 1
        v-row = 2
      .
      run PutColumnTitulExcel in this-procedure .
    end.
  end.
end procedure.
procedure PrintTitul :
  do
  on error undo, return error return-value
  :
    PUT stream PrnLibStream SPACE(10) ReportNAme format "X(100)" SKIP .
    PUT stream PrnLibStream str1 format "X(100)" SKIP .
    put stream PrnLibStream  skip cur-time-print() format "x(35)" string( "Страница" ) AT 45 PAGE-NUMBER( PrnLibStream ) AT 55 FORMAT ">>>>>9" SKIP .
    put stream PrnLibStream  skip  Line format string("X(" + string( num-col * 45 + 18) + ")")  skip .
    assign ii = 0 .
    if is-real then do:
      put stream PrnLibStream  "|" at (1 + ii * 45) "Реализация"  at (22 + ii * 45)   format "X(20)" .
      assign ii = ii + 1 .
    end.
    if is-fo then do:
      put stream PrnLibStream  "|" at (1 + ii * 45) "Фин. обязательства"  at (22 + ii * 45)   format "X(20)" .
      assign ii = ii + 1 .
    end.
    if is-fin then do:
      put stream PrnLibStream  "|" at (1 + ii * 45) "Платежи"  at (22 + ii * 45)   format "X(20)" .
      assign ii = ii + 1 .
    end.
    put stream PrnLibStream
      "|" at num-col * 45 + 1 string("Сумма долга") format "X(14)"
      "|" at num-col * 45 + 18
      skip  Line format string("X(" + string( num-col * 45 + 1) + ")")  "|" at num-col * 45 + 18 skip .
    do ii = 0 to num-col - 1 :
      put stream PrnLibStream
        "|" at (1 + ii * 45)  "Дата ф."                         format "X(8)"
        "|" at (10 + ii * 45)  "№ док-та"                        format "X(10)"
        "|" at (22 + ii * 45)  "Тип"                             format "X(3)"
        "|" at (26 + ii * 45)  string(" Сумма (" + s-val + ")")  format "X(18)"
      .
    end.
    put stream PrnLibStream  "|" at num-col * 45 + 1 string("("+ s-val + ")") format "X(10)" "|" at num-col * 45 + 18  skip  Line format string("X(" + string( num-col * 45 + 18) + ")")  skip .
  end.
end procedure.
procedure CalcOstatFin:
  do on error undo, return error return-value :
    define input  parameter p-type     as character no-undo .
    define output parameter p-sum-exp  as decimal   no-undo .
    define output parameter p-sum-inc  as decimal   no-undo .
    find last buf_arh-fin-doc-contr-schet no-lock
      where buf_arh-fin-doc-contr-schet.host-code        = v-cntxt-host-code-obj
        and buf_arh-fin-doc-contr-schet.contract-code    = v-contract-code
        and buf_arh-fin-doc-contr-schet.code-schet       = 0
        and buf_arh-fin-doc-contr-schet.cli-code         = temp-cli.obj-code
        and buf_arh-fin-doc-contr-schet.cli-type         = temp-cli.obj-type
        and buf_arh-fin-doc-contr-schet.fin-ext-doc-type = p-type
        and buf_arh-fin-doc-contr-schet.calc-curr-code   = v-curr-r-b
        and buf_arh-fin-doc-contr-schet.sum-type         = 'sum-contract':U
        and buf_arh-fin-doc-contr-schet.fact-order      < v-fact-order-start
    no-error .
    if available buf_arh-fin-doc-contr-schet then
      assign
        p-sum-exp = buf_arh-fin-doc-contr-schet.expense
        p-sum-inc = buf_arh-fin-doc-contr-schet.income
      .
  end.
end procedure.
procedure CalcOstatFinNal:
  do on error undo, return error return-value :
    define input  parameter p-type     as character no-undo .
    define output parameter p-sum-exp  as decimal   no-undo .
    define output parameter p-sum-inc  as decimal   no-undo .
    find last buf_arh-fin-doc-contr-schet-nal no-lock
      where buf_arh-fin-doc-contr-schet-nal.host-code        = v-cntxt-host-code-obj
        and buf_arh-fin-doc-contr-schet-nal.contract-code    = v-contract-code
        and buf_arh-fin-doc-contr-schet-nal.cli-code         = temp-cli.obj-code
        and buf_arh-fin-doc-contr-schet-nal.cli-type         = temp-cli.obj-type
        and buf_arh-fin-doc-contr-schet-nal.fin-code-acc     = 0
        and buf_arh-fin-doc-contr-schet-nal.fin-ext-doc-type = p-type
        and buf_arh-fin-doc-contr-schet-nal.curr-code        = v-curr-r-b
        and buf_arh-fin-doc-contr-schet-nal.calc-curr-code   = v-curr-r-b
        and buf_arh-fin-doc-contr-schet-nal.sum-type         = 'sum-contract':U
        and buf_arh-fin-doc-contr-schet-nal.fact-order      < v-fact-order-start
    no-error .
    if available buf_arh-fin-doc-contr-schet-nal then
      assign
        p-sum-exp = buf_arh-fin-doc-contr-schet-nal.expense
        p-sum-inc = buf_arh-fin-doc-contr-schet-nal.income
      .
  end.
end procedure.
procedure PrnSumCli :
  do on error undo, return error return-value :
    define input  parameter p-sm2 as decimal   no-undo .
    define input  parameter p-sm3 as decimal   no-undo .
    define input  parameter p-sm4 as decimal   no-undo .
    assign ii = 0 .
    if is-real then do:
      put stream PrnLibStream "|" at (26 + ii * 45)  p-sm2   format "->>>,>>>,>>>,>>9.99"  "|" at (46 + ii * 45) .
      run macr_excel_sum (p-sm2, v-row, ii * 4 + 4 , 2) .
      assign ii = ii + 1 .
    end.
    if is-fo then do:
      put stream PrnLibStream "|" at (26 + ii * 45)  p-sm3   format "->>>,>>>,>>>,>>9.99"  "|" at (46 + ii * 45) .
      run macr_excel_sum (p-sm3, v-row, ii * 4 + 4 , 2) .
      assign ii = ii + 1 .
    end.
    if is-fin then do:
      put stream PrnLibStream "|" at (26 + ii * 45)  p-sm4   format "->>>,>>>,>>>,>>9.99"  "|" at (46 + ii * 45) .
      run macr_excel_sum (p-sm4, v-row, ii * 4 + 4 , 2) .
      assign ii = ii + 1 .
    end.
    if is-fin and is-fo then do:
      put stream PrnLibStream   (p-sm3 - p-sm4)  format "->>>,>>>,>>9.99"   "|" at num-col * 45 + 18 skip .
      run macr_excel_sum ((p-sm3 - p-sm4), v-row, ii * 4 + 1 , 2) .
    end.
    else  put stream PrnLibStream    "|" at num-col * 45 + 18 skip .
    assign v-row = v-row + 1 .
    run is-page in this-procedure .
  end.
end procedure.
procedure new-date :
  do on error undo, return error return-value :
    find first temp-date
      where temp-date.dat      = temp-sum.dat
        and temp-date.cli-type = temp-sum.cli-type
        and temp-date.cli-code = temp-sum.cli-code
        and temp-date.contr    = temp-sum.contr
    no-error .
    if not available temp-date then do:
      create temp-date .
      assign
        temp-date.dat      = temp-sum.dat
        temp-date.cli-type = temp-sum.cli-type
        temp-date.cli-code = temp-sum.cli-code
        temp-date.contr    = temp-sum.contr
      .
    end.
    case temp-sum.type :
      when 1 then assign  temp-sum.ind = temp-date.num1   temp-date.num1 = temp-date.num1 + 1 .
      when 2 then assign  temp-sum.ind = temp-date.num2   temp-date.num2 = temp-date.num2 + 1 .
      when 3 then assign  temp-sum.ind = temp-date.num3   temp-date.num3 = temp-date.num3 + 1 .
      when 4 then assign  temp-sum.ind = temp-date.num4   temp-date.num4 = temp-date.num4 + 1 .
    end.
  end.
end procedure.
