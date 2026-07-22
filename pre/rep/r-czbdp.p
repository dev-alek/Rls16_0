block-level on error undo, throw.
define input parameter  parParentProc as WIDGET-HANDLE    no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-czbdp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-czbdp.p $":U .
define variable vss-description as character no-undo init "Служебная записка о выдаче денежных средств".
define variable g#report-num as integer no-undo .
define variable glob-page as integer no-undo .
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info13, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info13, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
define variable vss-include-info15 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_p-fmt_string-part no-undo
    field str-key       as integer
    field string-part   as character
    index pi is primary unique
        str-key
.
define variable v-p-fmt-15-str-key    as integer      no-undo.
FUNCTION center-field RETURNS INTEGER (INPUT iStartPix AS INTEGER, iEndPix AS INTEGER,
                                  iInput AS INTEGER).
  def var v-start-print as integer no-undo .
  if (iStartPix < 0) or (iEndPix < iStartPix) then return 0.
  assign
    v-start-print = INTEGER(iStartPix + ((iEndPix - iStartPix) / 2) - (iInput / 2))
  .
  RETURN v-start-print .
END FUNCTION.
FUNCTION right-field RETURNS INTEGER ( iEndPix AS INTEGER,
                                  iInput AS INTEGER).
  def var v-start-print as integer no-undo .
  assign
    v-start-print = INTEGER(iEndPix - 1 - iInput)
  .
  if v-start-print < 0 then return 0.
  RETURN v-start-print .
END FUNCTION.
function p-fmt-align-string returns character (
      p-in-string      as character
    , p-page-width     as integer
    , p-align-type     as character
).
    define variable v-string-length     as integer      no-undo.
    define variable v-out-string        as character    no-undo.
    assign
        v-string-length = length( trim( p-in-string ) )
    .
    if v-string-length >= p-page-width
    then do:
        assign
            v-out-string = trim( p-in-string )
        .
    end.
    else do:
        case p-align-type
        :
            when 'left':U
            then do:
                assign
                    v-out-string = trim( p-in-string )
                .
            end.
            when 'right':U
            then do:
                assign
                    v-out-string = fill( " ":U, p-page-width - v-string-length ) + trim( p-in-string )
                .
            end.
            when 'center':U
            then do:
                assign
                    v-out-string = fill( " ":U, integer( ( p-page-width - v-string-length ) / 2 ) ) + trim( p-in-string )
                .
            end.
        end case.
    end.
    return v-out-string .
end function.
procedure p-fmt-split-string :
define input parameter p-source-string  as character        no-undo.
define input parameter p-split-length   as integer          no-undo.
define output parameter p-string-1      as character        no-undo.
define output parameter p-string-2      as character        no-undo.
do
on error undo, return error
:
    define variable v-space-pos    as integer      no-undo.
    if length( p-source-string ) <= p-split-length
    then do:
        assign
            p-string-1 = p-source-string
        .
    end.
    else do:
        assign
            v-space-pos = r-index( p-source-string, " ":U, p-split-length )
        .
        if v-space-pos = 0
        then do:
            assign
                v-space-pos = index( p-source-string, " ":U )
            .
        end.
        if v-space-pos = 0
        then do:
            assign
                p-string-1 = substring( p-source-string, 1, p-split-length )
                p-string-2 = trim( substring( p-source-string, p-split-length, p-split-length ) )
            .
        end.
        else do:
            assign
                p-string-1 = substring( p-source-string, 1, v-space-pos )
                p-string-2 = trim( substring( p-source-string, v-space-pos ) )
            .
        end.
    end.
end.
end procedure.
procedure p-fmt-round :
define input parameter p-qnty               as decimal          no-undo.
define input parameter p-price-no-VAT       as decimal          no-undo.
define input parameter p-VAT                as decimal          no-undo.
define input parameter p-SLT                as decimal          no-undo.
define input parameter p-road-tax           as decimal          no-undo.
define output parameter p-new-price-no-VAT  as decimal          no-undo.
define output parameter p-new-VAT           as decimal          no-undo.
define output parameter p-new-SLT           as decimal          no-undo.
define output parameter p-new-sum-VAT       as decimal          no-undo.
define output parameter p-new-sum-SLT       as decimal          no-undo.
define output parameter p-new-sum-road-tax  as decimal          no-undo.
define output parameter p-new-sum-no-VAT    as decimal          no-undo.
define output parameter p-new-sum-full      as decimal          no-undo.
    define variable v-vat-pc    as decimal      no-undo.
    define variable v-slt-pc    as decimal      no-undo.
do
on error undo, return error
:
    if p-price-no-VAT = 0
    then do:
        assign
            p-new-price-no-VAT = 0.0
            p-new-VAT          = ?
            p-new-SLT          = ?
            p-new-sum-VAT      = 0.0
            p-new-sum-SLT      = 0.0
            p-new-sum-no-VAT   = 0.0
            p-new-sum-road-tax = 0.0
            p-new-sum-full     = 0.0
        .
    end.
    else do:
        assign
            v-vat-pc            = p-VAT / p-price-no-VAT
            v-slt-pc            = p-SLT / ( p-price-no-VAT + p-VAT )
            p-new-price-no-VAT  = round( p-price-no-VAT, 2 )
            p-new-VAT           = round( p-new-price-no-VAT * v-vat-pc, 2 )
            p-new-SLT           = round( ( p-new-price-no-VAT + p-new-VAT ) * v-slt-pc, 2 )
            p-new-sum-VAT       = round( p-new-VAT          * p-qnty, 2 )
            p-new-sum-SLT       = round( ( p-new-price-no-VAT + p-new-VAT ) * p-qnty * v-slt-pc, 2 )
            p-new-sum-no-VAT    = round( p-new-price-no-VAT * p-qnty, 2 )
            p-new-sum-road-tax  = round( p-road-tax * p-qnty, 2 )
            p-new-sum-full      = round( ( p-new-price-no-VAT + p-new-VAT + p-new-SLT + p-road-tax ) * p-qnty, 2 )
        .
    end.
end.
end procedure.
procedure p-fmt-split :
define input parameter p-in-string      as character        no-undo.
define input parameter p-split-length   as integer          no-undo.
    define variable v-start-pos     as integer      no-undo.
    define variable v-end-pos       as integer      no-undo.
    define buffer buf_temp_p-fmt_string-part        for temp_p-fmt_string-part.
do
for buf_temp_p-fmt_string-part
on error undo, return error
:
    empty temp-table buf_temp_p-fmt_string-part.
    if p-split-length < 1
    then do:
        undo, return error substitute( "p-fmt-split: Строка не может быть разбита на &1 частей", p-split-length ).
    end.
    assign
        p-in-string                 = trim( p-in-string )
        v-p-fmt-15-str-key   = 0
        v-start-pos                 = 1
        v-end-pos                   = length( p-in-string )
    .
    run p-fmt-get-string-range in this-procedure (
          input p-in-string
        , input p-split-length
        , input v-start-pos
        , output v-start-pos
        , output v-end-pos
    ).
    do while v-end-pos <> 0
    :
        create buf_temp_p-fmt_string-part.
        assign
            v-p-fmt-15-str-key = v-p-fmt-15-str-key + 1
        .
        assign
            buf_temp_p-fmt_string-part.str-key      = v-p-fmt-15-str-key
            buf_temp_p-fmt_string-part.string-part  = substring( p-in-string, v-start-pos, v-end-pos - v-start-pos )
        .
        assign
            v-start-pos = v-end-pos + 1
        .
        run p-fmt-get-string-range in this-procedure (
              input p-in-string
            , input p-split-length
            , input v-start-pos
            , output v-start-pos
            , output v-end-pos
        ).
    end.
end.
end procedure.
procedure p-fmt-get-string-range :
define input parameter p-in-string      as character        no-undo.
define input parameter p-split-length   as integer          no-undo.
define input parameter p-old-start-pos  as integer          no-undo.
define output parameter p-start-pos     as integer          no-undo.
define output parameter p-end-pos       as integer          no-undo.
    define variable v-init-string    as character    no-undo.
    define variable v-temp-char      as character    no-undo.
    define variable v-temp-pos       as integer      no-undo.
    define variable v-counter        as integer      no-undo.
do
on error undo, return error
:
    assign
        p-start-pos   = p-old-start-pos
        v-init-string = substring( p-in-string, p-start-pos )
    no-error.
    if error-status :error
    or trim( v-init-string ) = "":U
    then do:
        assign
            p-end-pos = 0
        .
        undo, return .
    end.
    assign
        v-temp-char   = substring( v-init-string, 1, 1 )
    .
    do
    while trim( v-temp-char ) = "":U
    :
        assign
            p-start-pos     = p-start-pos + 1
            v-init-string   = substring( p-in-string, p-start-pos )
            v-temp-char     = substring( v-init-string, 1, 1 )
        .
    end.
    assign
        v-temp-pos  = p-split-length
        v-temp-char = substring( v-init-string, v-temp-pos, 1 )
        v-counter   = 0
    .
    search-word-end:
    do
    while trim( v-temp-char ) <> "":U
    :
        assign
            v-counter   = v-counter + 1
        .
        if v-counter > 20
        then do:
            assign
                v-temp-pos  = p-split-length
            .
            leave search-word-end.
        end.
        assign
            v-temp-pos  = v-temp-pos - 1
            v-temp-char = substring( v-init-string, v-temp-pos, 1 )
        .
    end.
    assign
        p-end-pos = p-start-pos + v-temp-pos - 1
    .
end.
end procedure.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
 do
 on error undo, return error return-value
 :
define variable date_string     as      char    no-undo.
define variable for-time as char.
x-date-start = x-date-alone .
define temp-table temp-t no-undo
field cli-name as character
field cli-type as character
field cli-code as integer
field obj-type as character
field obj-code as integer
field sum-p    as decimal
field sum-fo   as decimal
field sum-op   as decimal
index pi
      obj-type
      obj-code
      cli-name
      cli-type
      cli-code
      .
define temp-table temp-obj no-undo like clients
field nn as integer
field sum-obj as decimal
field sum-obj-arh as decimal
.
define variable sum-ostatok-start as decimal no-undo init 0.
define variable sum-plan-pri      as decimal no-undo init 0 .
define variable sum-proch         as decimal no-undo init 0 .
define variable sum-proch-ras         as decimal no-undo init 0 .
define variable all-summ-dec-razd-1 as decimal no-undo init 0 .
define variable all-summ-dec-razd-2 as decimal no-undo init 0 .
define variable all-summ-dec-razd-3 as decimal no-undo init 0 .
define temp-table temp-cli no-undo like clients
field summ as decimal
.
define variable v-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable num#col#    as integer no-undo .
define variable C-c    as integer no-undo .
define variable C-str  as character no-undo .
define variable str--1 as character Format "x(60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var  as integer no-undo .
define variable var-1  as integer no-undo .
define variable var-2  as integer no-undo .
define variable num-ln as integer   no-undo .
define variable i as int no-undo.
define variable j as int no-undo.
define variable Counter1 as integer init 0  no-undo .
define variable LineBuf       as char    no-undo.
define variable Line       as char    no-undo.
define variable UndLine    as char    no-undo.
define variable     Lines_Counter as   int  init 0  no-undo.
define variable     Tmp_Counter   as   int  init 0  no-undo.
define variable fact-order-2 as decimal no-undo .
define variable v-host-code as integer no-undo .
define variable v-obj-code as integer no-undo .
define variable v-obj-type as character no-undo .
define variable v-curr as integer no-undo .
define variable var-calc-page as integer no-undo .
define variable var-page as integer no-undo .
define buffer buf_clients  for clients .
define buffer buf_contract for contract.
define buffer b1_beznal_arh-fin for arh-fin-doc-contr-schet-obj.
define buffer b2_beznal_arh-fin for arh-fin-doc-contr-schet-obj.
define buffer b1_nal_arh-fin    for arh-fin-doc-contr-s-nal-obj.
define buffer b2_nal_arh-fin    for arh-fin-doc-contr-s-nal-obj.
define buffer b3_nal_arh-fin    for arh-fin-doc-contr-s-nal-obj.
define buffer b4_nal_arh-fin    for arh-fin-doc-contr-s-nal-obj.
define buffer b1_arh-fin-ob-obj for arh-fin-ob-contr-obj.
define buffer b2_arh-fin-ob-obj for arh-fin-ob-contr-obj.
define buffer buf_fin-doc for fin-doc.
define variable v-summ-obj as decimal no-undo init 0.
define variable v-vvdec as decimal no-undo .
run factord-end-day in this-procedure (input x-date-alone  , output  fact-order-2 ) .
run get-report-num in parParentProc(output g#report-num ) .
v-host-code  = v-cntxt-host-code-obj.
v-obj-type   = v-cntxt-obj-type .
v-obj-code   = v-cntxt-obj-code .
if x-SET_val_TYPE = 1 then v-curr = 0 .
   else do:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-curr
  )  .
   end.
define stream  macr_excel .
DEFINE FRAME prt-frame
  HEADER  date_string AT 5 format "X(35)"
          string( "Страница " ) format "X(9)" AT 50 PAGE-NUMBER( PrnLibStream) AT 70 FORMAT ">>>>9" SKIP
          Line format "X(116)" AT 1
          with width 232 down stream-io use-text
          .
    Line = fill("-", 146).
    date_string = cur-time-print() .
run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name) .
output stream macr_excel to value(v-file-name)   .
v-ind = 1    .
num#str# = 0 .
    run prn-lib-open-stream in this-procedure (
       input parParentProc
      ,input 43
      ,input yes
      ,input no
      ).
    PUT  STREAM PrnLibStream reportname + " на " + string(x-date-alone, "99/99/9999")
         format "x(116)" SKIP .
    FORM HEADER
        Line format "X(146)" AT 1 SKIP
        "Продолжение - на следующей странице" AT 1
        date_string AT 50 format "X(35)"
        string( "Страница " ) format "X(9)" AT 90 PAGE-NUMBER( PrnLibStream) AT 100 FORMAT ">>>>9"
        with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW  STREAM PrnLibStream FRAME BottomFrame .
    FORM with FRAME prt-frame  .
    run waitfram-show in this-procedure ("Ждите печатаю...").
    run print-title in this-procedure .
    run make-tt in this-procedure .
    define variable i-page as integer no-undo .
    repeat i-page = 1 to glob-page :
        if i-page > 1 then
           Page  STREAM PrnLibStream .
        run print-1-razd in this-procedure .
        run print-2-razd in this-procedure .
        run print-3-razd in this-procedure .
        run print-ll in this-procedure .
        run print-cli in this-procedure ( input "Итого к выдаче" ,
                        input  "sum-obj-arh":U )
                      .
        run print-ll in this-procedure .
        run print-cli in this-procedure ( input "Плановый остаток на конец дня" ,
                        input  "sum-ost":U )
                      .
    end.
    HIDE  STREAM PrnLibStream FRAME BottomFrame .
    HIDE  STREAM PrnLibStream FRAME CheckList.
    output STREAM PrnLibStream CLOSE.
    output stream macr_excel  close .
    run paramls-write in this-procedure
      (input "file"
      ,input string(v-ind)
      ,input v-file-name
      ) .
    run paramls-write in this-procedure
        (input "charcol"
        ,input ""
        ,input "1"
        ) .
    run end-proc in this-procedure .
    run waitfram-hide in this-procedure .
    run prn-lib-prn-file in this-procedure (
        input parParentProc
       ,input 8
        ).
end.
procedure print-title :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define variable l-ii  as integer no-undo .
define variable l-jj  as integer no-undo .
define variable l-len as integer no-undo .
define variable l-m   as integer no-undo .
      num#str# = num#str# + 1 .
      num#col# =  1 .
      run macr_excel_char_with_format in this-procedure ( reportname + " на " + string(x-date-alone, "99/99/9999") , num#str# , num#col#  ).
      run macr_cell_format in this-procedure
          ( 12       ,
            true     ,
            false    ,
            ?        ,
            num#str# ,
            num#col# ,
            ?        ,
            ?         ) .
num#str# = num#str# + 1.
num#col# = 1.
 end.
end procedure.
procedure print-1-razd :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define variable str as character no-undo .
define variable v-dec as decimal no-undo .
define variable num#at as integer no-undo .
define variable p-value    as character no-undo .
define variable p-type     as character no-undo .
run print-ll  in this-procedure .
  assign
    num#str# = num#str# + 1
    num#col# =  2
    num#at   =  30
  .
  for each temp-obj   where temp-obj.nn = i-page
      on error undo, return error :
      str  =  temp-obj.obj-type + " " + string(temp-obj.obj-code) .
      run macr_excel_char_with_format in this-procedure ( str , num#str# , num#col#  ).
      put stream prnlibstream unformatted p-fmt-align-string(str , 12 , 'right':U ) + "|"  at num#at format "x(13)" .
      num#col# = num#col# +  1 .
      num#at   = num#at + 13 .
  end.
  run macr_cell_format in this-procedure
      ( 10    ,
        true  ,
        true  ,
        33    ,
        num#str# ,
        1 ,
        num#str# ,
        num#col#  ) .
put stream prnlibstream   unformatted skip .
  run print-ll in this-procedure  .
  run print-h in this-procedure  ( input "Остаток на нач.дня в кассах" ,
                input   'fin-ostatok-start':U)
                .
  run print-h in this-procedure  ( input  "План прихода" ,
                input   'fin-plan-pri':U)
                .
  run print-h in this-procedure  ( input  "Прочие доходы" ,
                input  'fin-proch':U)
                .
  run print-h in this-procedure  ( input "Прочие расходы" ,
                input  'fin-proch-ras':U)
                .
  run print-ll in this-procedure  .
  run print-cli in this-procedure  ( input "Итого к распределению" ,
                  input  "sum-obj":U )
                .
  run print-ll in this-procedure  .
 end.
end procedure.
procedure make-tt :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
if not can-find( first g#customer ) then do:
   run waitfram-show in this-procedure ("Подготовка списка Поставщиков...").
   for each buf_clients no-lock where
            (buf_clients.obj-type = 'орг':U or
             buf_clients.obj-type = 'чел':U )
            :
            if
            (buf_clients.obj-type = 'орг':U and
             buf_clients.obj-code = v-host-code ) then next.
            create g#customer.
            BUFFER-COPY buf_clients to g#customer.
   end.
end.
run waitfram-show in this-procedure ("Подготовка списка Объектов...").
for each obj-list
    on error undo, return error :
    var-calc-page = var-calc-page + 1 .
    create temp-obj.
    buffer-copy obj-list to temp-obj
    assign
      temp-obj.nn = truncate ( var-calc-page / 12.1 , 0 ) + 1
      glob-page   = temp-obj.nn
    .
end.
run waitfram-show in this-procedure ("Проход по архивам...").
    for each g#customer :
        for each buf_contract no-lock where
            buf_contract.host-code = v-host-code and
            buf_contract.cli-type  = g#customer.obj-type   and
            buf_contract.cli-code  = g#customer.obj-code
            :
               run proc-body in this-procedure  (input buf_contract.contract-code ) .
        end.
        run proc-body-cli in this-procedure    .
        if not can-find(first temp-cli where temp-cli.obj-type = g#customer.obj-type   and
                                             temp-cli.obj-code = g#customer.obj-code ) then do:
            if can-find(first temp-t where temp-t.cli-type = g#customer.obj-type   and
                                           temp-t.cli-code = g#customer.obj-code ) then do:
                create temp-cli.
                BUFFER-COPY g#customer to temp-cli
                assign
                  temp-cli.summ = v-summ-obj.
                .
                v-summ-obj = 0 .
            end.
        end.
       run waitfram-show in this-procedure ("Обработан поставщик: " + g#customer.obj-name ).
    end.
    run waitfram-show in this-procedure ("Подготовка к печати" ).
 end.
end procedure.
procedure print-h :
  do
  on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
define input parameter p-str as character no-undo .
define input parameter p-prop-code as character no-undo .
define variable v-dec  as decimal no-undo init 0 .
define variable num#at as integer no-undo .
define variable p-type     as character no-undo .
define variable v-value-character like ub.thbj-attr.property-value-character no-undo .
define variable v-value-date    like ub.thbj-attr.property-value-date no-undo .
define variable v-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define variable v-value-logical like ub.thbj-attr.property-value-logical no-undo .
define variable v-value-integer like ub.thbj-attr.property-value-integer no-undo .
define variable v-type     as character no-undo .
define variable v-found as decimal no-undo .
assign
  num#str# = num#str# + 1
  num#col# =  1
  num#at   = 30
.
run macr_excel_char_with_format in this-procedure ( p-str , num#str# , num#col#  ) .
put stream prnlibstream  unformatted p-str  at 1.
num#col# = num#col# + 1 .
  for each temp-obj  where temp-obj.nn = i-page
      on error undo, return error :
      run thbjattr_value in this-procedure  (
          input   temp-obj.obj-type ,
          input   temp-obj.obj-code ,
          input   p-prop-code       ,
          input   'fin-plan':U  ,
          output  v-value-character ,
          output  v-value-date      ,
          output  v-value-decimal   ,
          output  v-value-integer   ,
          output  v-value-logical   ,
          output  v-type            ,
          output  v-found
          )
          .
      temp-obj.sum-obj = temp-obj.sum-obj + v-value-decimal .
      define variable v-temp-dec as decimal no-undo .
      case p-prop-code :
        when 'fin-ostatok-start':U then do:
          sum-ostatok-start = sum-ostatok-start + v-value-decimal.
          v-temp-dec        = sum-ostatok-start .
        end.
        when 'fin-plan-pri':U then do:
          sum-plan-pri = sum-plan-pri +  v-value-decimal .
          v-temp-dec   = sum-plan-pri .
        end.
        when 'fin-proch':U then do:
          sum-proch   = sum-proch +  v-value-decimal .
          v-temp-dec  = sum-proch .
        end.
        when 'fin-proch-ras':U then do:
          sum-proch-ras   = sum-proch-ras +  v-value-decimal .
          v-temp-dec  = sum-proch-ras .
        end.
        otherwise do:
           v-temp-dec  = 0 .
        end.
      end case.
      run macr_excel_dec in this-procedure ( v-value-decimal , num#str# , num#col#  ).
      put stream prnlibstream   unformatted v-value-decimal at num#at  format "->>>>>>>>9.99" .
      num#col# = num#col# +  1  .
      num#at   = num#at   +  13 .
  end.
  run print-itog-col in this-procedure ( v-temp-dec , num#at ) .
  put stream prnlibstream unformatted skip.
  end.
end procedure.
procedure print-cli :
  do
  on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
define input parameter p-str as character no-undo .
define input parameter p-dec as character no-undo .
define variable num#at as integer no-undo .
define variable v-dec  as decimal no-undo .
assign
  num#str# = num#str# + 1
  num#col# =  1
  num#at   = 30
.
run macr_excel_char_with_format in this-procedure ( p-str , num#str# , num#col#  ) .
put stream prnlibstream  unformatted p-str  at 1.
num#col# = num#col# + 1 .
  for each temp-obj  where temp-obj.nn = i-page
      on error undo, return error :
      case p-dec :
          when "sum-obj" then do:
            v-dec = temp-obj.sum-obj.
            all-summ-dec-razd-1 = all-summ-dec-razd-1  + v-dec .
          end.
          when "sum-obj-arh" then do:
            v-dec = temp-obj.sum-obj-arh .
            all-summ-dec-razd-2 = all-summ-dec-razd-2  + v-dec .
          end.
          when "sum-ost" then do:
              v-dec =  temp-obj.sum-obj - temp-obj.sum-obj-arh .
              all-summ-dec-razd-3 = all-summ-dec-razd-3  + v-dec .
          end.
      end case.
      run macr_excel_dec in this-procedure ( v-dec , num#str# , num#col#  ).
      put stream prnlibstream   unformatted v-dec at num#at  format "->>>>>>>>9.99" .
      num#col# = num#col# +  1  .
      num#at   = num#at   +  13 .
  end.
  if i-page = glob-page then do:
      case p-dec :
          when "sum-obj" then do:
              run macr_excel_dec in this-procedure ( all-summ-dec-razd-1 , num#str# , num#col#  ).
              put stream prnlibstream   unformatted all-summ-dec-razd-1 at num#at  format "->>>>>>>>9.99" .
           end.
          when "sum-obj-arh" then do:
              run macr_excel_dec in this-procedure ( all-summ-dec-razd-2 , num#str# , num#col#  ).
              put stream prnlibstream   unformatted all-summ-dec-razd-2 at num#at  format "->>>>>>>>9.99" .
           end.
          when "sum-ost" then do:
              run macr_excel_dec in this-procedure ( all-summ-dec-razd-3 , num#str# , num#col#  ).
              put stream prnlibstream   unformatted all-summ-dec-razd-3 at num#at  format "->>>>>>>>9.99" .
           end.
       end case.
      num#col# = num#col# +  1  .
      num#at   = num#at   +  13 .
  end.
  put stream prnlibstream unformatted skip.
  end.
end procedure.
 procedure print-ll :
  do
  on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
define variable num#at as integer no-undo .
define variable str as character no-undo .
  assign
    num#at   =  30
  .
  for each temp-obj where temp-obj.nn = i-page :
      str  = "------------+".
      put stream prnlibstream unformatted str at num#at format "x(13)" .
      num#at   = num#at + 13 .
  end.
  if i-page = glob-page then do:
     put stream prnlibstream unformatted str at num#at format "x(13)" .
  end.
  end.
 end procedure.
procedure print-itog-col :
do
on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
define input parameter v-summa as decimal no-undo .
define input parameter v-at as integer no-undo .
    if i-page = glob-page then do:
        run macr_excel_dec in this-procedure ( v-summa , num#str# , num#col#  ).
        put stream prnlibstream   unformatted v-summa at  v-at  format "->>>>>>>>9.99" .
    end.
end.
end procedure.
procedure print-2-razd :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define variable str as character no-undo .
define variable v-dec as decimal no-undo .
define variable num#at as integer no-undo .
define variable p-value    as character no-undo .
define variable p-type     as character no-undo .
run print-ll in this-procedure .
  assign
    num#str# = num#str# + 1
    num#col# =  1
    num#at   =  1
    str      = "ПЛАН ВЫПЛАТ"
  .
  run macr_excel_char_with_format in this-procedure ( str , num#str# , num#col#  ).
  put stream prnlibstream unformatted str  at num#at format "x(13)" .
  assign
    num#col# =  2
    num#at   =  30
  .
  for each temp-obj   where temp-obj.nn = i-page
      on error undo, return error :
      str  = temp-obj.obj-name .
      run macr_excel_char_with_format in this-procedure ( str , num#str# , num#col#  ).
      put stream prnlibstream unformatted p-fmt-align-string(str , 12 , 'right':U ) + "|"  at num#at format "x(13)" .
      num#col# = num#col# +  1 .
      num#at   = num#at + 13 .
  end.
  if i-page = glob-page then do:
    str =  "ИТОГО по пост.".
    run macr_excel_char_with_format in this-procedure ( str , num#str# , num#col#  ).
    put stream prnlibstream unformatted str  at num#at format "x(13)" .
  end.
  run macr_cell_format in this-procedure
      ( 10    ,
        true  ,
        true  ,
        40    ,
        num#str# ,
        1 ,
        num#str# ,
        num#col#  ) .
put stream prnlibstream   unformatted skip .
  run print-ll in this-procedure .
 end.
end procedure.
procedure print-3-razd :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define variable str as character no-undo .
define variable v-dec as decimal no-undo .
define variable num#at as integer no-undo .
define variable p-value    as character no-undo .
define variable p-type     as character no-undo .
 for each  temp-cli
     on error undo, return error  with FRAME prt-frame :
      assign
        num#str# = num#str# + 1
        num#col# =  1
        num#at   =  1
        .
      str = temp-cli.obj-name .
      run macr_excel_char_with_format in this-procedure ( str , num#str# , num#col#  ).
      put stream prnlibstream unformatted str  at num#at format "x(29)" .
      assign
        num#col# =  2
        num#at   =  30
      .
          for each temp-obj where temp-obj.nn = i-page
              on error undo, return error :
              for each temp-t where
                       temp-t.cli-type = temp-cli.obj-type and
                       temp-t.cli-code = temp-cli.obj-code and
                       temp-t.obj-type = temp-obj.obj-type and
                       temp-t.obj-code = temp-obj.obj-code :
                v-dec =  temp-t.sum-fo - temp-t.sum-p + temp-t.sum-op .
                temp-obj.sum-obj-arh = temp-obj.sum-obj-arh + v-dec .
                run macr_excel_dec in this-procedure ( v-dec , num#str# , num#col#  ).
                put stream prnlibstream unformatted v-dec  at num#at format "->>>>>>>>9.99" .
              end.
              num#col# = num#col# +  1 .
              num#at   = num#at + 13 .
          end.
      if i-page = glob-page then do:
        v-dec =  temp-cli.summ .
        run macr_excel_dec in this-procedure ( v-dec , num#str# , num#col#  ).
        put stream prnlibstream unformatted v-dec  at num#at format "->>>>>>>>9.99" .
      end.
 end.
 end.
end procedure.
procedure proc-body :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter par-contract-code as integer no-undo .
      for each temp-obj :
                    find last b1_arh-fin-ob-obj no-lock      where
                        b1_arh-fin-ob-obj.host-code           = v-host-code                and
                        b1_arh-fin-ob-obj.obj-type            = temp-obj.obj-type          and
                        b1_arh-fin-ob-obj.obj-code            = temp-obj.obj-code          and
                        b1_arh-fin-ob-obj.contract-code       = par-contract-code          and
                        b1_arh-fin-ob-obj.fin-ext-doc-type    = 'рас':U                 and
                        b1_arh-fin-ob-obj.calc-curr-code      = v-curr                     and
                        b1_arh-fin-ob-obj.sum-type            = "":U                       and
                        b1_arh-fin-ob-obj.fact-order         <= fact-order-2               and
                        b1_arh-fin-ob-obj.cli-type            = 'орг':U                     and
                        b1_arh-fin-ob-obj.cli-code            = v-host-code
                        use-index pi no-error .
                        if available b1_arh-fin-ob-obj then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-fo   = temp-t.sum-fo  + b1_arh-fin-ob-obj.expense
                                      v-summ-obj      = v-summ-obj     + b1_arh-fin-ob-obj.expense
                                  .
                        end.
                    find last b2_arh-fin-ob-obj no-lock      where
                        b2_arh-fin-ob-obj.host-code           = v-host-code                and
                        b2_arh-fin-ob-obj.obj-type            = temp-obj.obj-type          and
                        b2_arh-fin-ob-obj.obj-code            = temp-obj.obj-code          and
                        b2_arh-fin-ob-obj.contract-code       = par-contract-code          and
                        b2_arh-fin-ob-obj.fin-ext-doc-type    = 'при':U                  and
                        b2_arh-fin-ob-obj.calc-curr-code      = v-curr                     and
                        b2_arh-fin-ob-obj.sum-type            = "":U                       and
                        b2_arh-fin-ob-obj.cli-type            = 'орг':U                     and
                        b2_arh-fin-ob-obj.cli-code            = v-host-code                and
                        b2_arh-fin-ob-obj.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b2_arh-fin-ob-obj then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-fo   = temp-t.sum-fo  - b2_arh-fin-ob-obj.income
                                      v-summ-obj      = v-summ-obj     - b2_arh-fin-ob-obj.income
                                  .
                        end.
                    find last b1_beznal_arh-fin no-lock      where
                        b1_beznal_arh-fin.host-code           = v-host-code                and
                        b1_beznal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b1_beznal_arh-fin.obj-code            = temp-obj.obj-code          and
                        b1_beznal_arh-fin.contract-code       = par-contract-code and
                        b1_beznal_arh-fin.code-schet          = 0                          and
                        b1_beznal_arh-fin.fin-ext-doc-type    = 'рпп':U  and
                        b1_beznal_arh-fin.calc-curr-code      = v-curr                     and
                        b1_beznal_arh-fin.sum-type            = "sum-contract":U           and
                        b1_beznal_arh-fin.cli-type            = 'орг':U                     and
                        b1_beznal_arh-fin.cli-code            = v-host-code                and
                        b1_beznal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b1_beznal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  + b1_beznal_arh-fin.expense
                                      v-summ-obj        = v-summ-obj  - b1_beznal_arh-fin.expense
                                  .
                        end.
                    find last b2_beznal_arh-fin no-lock      where
                        b2_beznal_arh-fin.host-code           = v-host-code                and
                        b2_beznal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b2_beznal_arh-fin.obj-code            = temp-obj.obj-code          and
                        b2_beznal_arh-fin.contract-code       = par-contract-code and
                        b2_beznal_arh-fin.code-schet          = 0                          and
                        b2_beznal_arh-fin.fin-ext-doc-type    = 'ппп':U   and
                        b2_beznal_arh-fin.calc-curr-code      = v-curr                     and
                        b2_beznal_arh-fin.sum-type            = "sum-contract":U           and
                        b2_beznal_arh-fin.cli-type            = 'орг':U                     and
                        b2_beznal_arh-fin.cli-code            = v-host-code                and
                        b2_beznal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b2_beznal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type   and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  - b2_beznal_arh-fin.income
                                      v-summ-obj      = v-summ-obj    + b2_beznal_arh-fin.income
                                  .
                        end.
                    find last b1_nal_arh-fin no-lock      where
                        b1_nal_arh-fin.host-code           = v-host-code                and
                        b1_nal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b1_nal_arh-fin.obj-code            = temp-obj.obj-code          and
                        b1_nal_arh-fin.contract-code       = par-contract-code and
                        b1_nal_arh-fin.fin-code-acc        = 0                          and
                        b1_nal_arh-fin.curr-code           = 0                          and
                        b1_nal_arh-fin.fin-ext-doc-type    = 'рко':U      and
                        b1_nal_arh-fin.calc-curr-code      = v-curr                     and
                        b1_nal_arh-fin.sum-type            = "sum-contract":U           and
                        b1_nal_arh-fin.cli-type            = 'орг':U                     and
                        b1_nal_arh-fin.cli-code            = v-host-code                and
                        b1_nal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b1_nal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  + b1_nal_arh-fin.expense
                                      v-summ-obj      = v-summ-obj  - b1_nal_arh-fin.expense
                                  .
                        end.
                    find last b2_nal_arh-fin no-lock      where
                        b2_nal_arh-fin.host-code           = v-host-code                and
                        b2_nal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b2_nal_arh-fin.obj-code            = temp-obj.obj-code          and
                        b2_nal_arh-fin.contract-code       = par-contract-code          and
                        b2_nal_arh-fin.fin-code-acc        = 0                          and
                        b2_nal_arh-fin.curr-code           = 0                          and
                        b2_nal_arh-fin.fin-ext-doc-type    = 'пко':U       and
                        b2_nal_arh-fin.calc-curr-code      = v-curr                     and
                        b2_nal_arh-fin.sum-type            = "sum-contract":U           and
                        b2_nal_arh-fin.cli-type            = 'орг':U                     and
                        b2_nal_arh-fin.cli-code            = v-host-code                and
                        b2_nal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b2_nal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type   and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  - b2_nal_arh-fin.income
                                      v-summ-obj      = v-summ-obj  + b2_nal_arh-fin.income
                                  .
                        end.
                    find last b3_nal_arh-fin no-lock      where
                        b3_nal_arh-fin.host-code           = v-host-code                and
                        b3_nal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b3_nal_arh-fin.obj-code            = temp-obj.obj-code          and
                        b3_nal_arh-fin.contract-code       = par-contract-code and
                        b3_nal_arh-fin.fin-code-acc        = 0                          and
                        b3_nal_arh-fin.curr-code           = 0                          and
                        b3_nal_arh-fin.fin-ext-doc-type    = 'апр':U    and
                        b3_nal_arh-fin.calc-curr-code      = v-curr                     and
                        b3_nal_arh-fin.sum-type            = "sum-contract":U           and
                        b3_nal_arh-fin.cli-type            = 'орг':U                     and
                        b3_nal_arh-fin.cli-code            = v-host-code                and
                        b3_nal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b3_nal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  + b3_nal_arh-fin.expense
                                      v-summ-obj      = v-summ-obj  - b3_nal_arh-fin.expense
                                  .
                        end.
                    find last b4_nal_arh-fin no-lock      where
                        b4_nal_arh-fin.host-code           = v-host-code                and
                        b4_nal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b4_nal_arh-fin.obj-code            = temp-obj.obj-code          and
                        b4_nal_arh-fin.contract-code       = par-contract-code and
                        b4_nal_arh-fin.fin-code-acc        = 0                          and
                        b4_nal_arh-fin.curr-code           = 0                          and
                        b4_nal_arh-fin.fin-ext-doc-type    = 'апп':U     and
                        b4_nal_arh-fin.calc-curr-code      = v-curr                     and
                        b4_nal_arh-fin.sum-type            = "sum-contract":U           and
                        b4_nal_arh-fin.cli-type            = 'орг':U                     and
                        b4_nal_arh-fin.cli-code            = v-host-code                and
                        b4_nal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b4_nal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type   and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  - b4_nal_arh-fin.income
                                      v-summ-obj      = v-summ-obj  + b4_nal_arh-fin.income
                                  .
                        end.
      end.
 end.
end procedure.
procedure proc-body-plat :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
for each temp-obj :
  for each buf_fin-doc no-lock
      where
      buf_fin-doc.host-code = v-host-code                and
      buf_fin-doc.obj-type  = temp-obj.obj-type          and
      buf_fin-doc.obj-code  = temp-obj.obj-code          and
      buf_fin-doc.status_    <> 'факт':U              and
      buf_fin-doc.doc-date  = x-date-alone               and
     (
      (
        buf_fin-doc.receiver-type  = g#customer.obj-type        and
        buf_fin-doc.receiver-code  = g#customer.obj-code        )
        or
      (
        buf_fin-doc.payer-type = g#customer.obj-type        and
        buf_fin-doc.payer-code = g#customer.obj-code        )
        )
        :
        find first temp-t where
                    temp-t.cli-type = g#customer.obj-type and
                    temp-t.cli-code = g#customer.obj-code and
                    temp-t.obj-type = temp-obj.obj-type   and
                    temp-t.obj-code = temp-obj.obj-code  no-error .
            if not available temp-t then
              create temp-t.
                assign
                    temp-t.cli-type = g#customer.obj-type
                    temp-t.cli-code = g#customer.obj-code
                    temp-t.obj-type = temp-obj.obj-type
                    temp-t.obj-code = temp-obj.obj-code
                .
              v-vvdec = (if v-curr = 0 then buf_fin-doc.sum-rubl else buf_fin-doc.sum-base ).
            if  buf_fin-doc.fin-ext-doc-type    = 'апп':U or
                buf_fin-doc.fin-ext-doc-type    = 'пко':U or
                buf_fin-doc.fin-ext-doc-type    = 'ппп':U
              then do:
                    temp-t.sum-op    = temp-t.sum-op  + v-vvdec.
                    v-summ-obj       = v-summ-obj     + v-vvdec.
            end.
            else do:
                    temp-t.sum-op    = temp-t.sum-op - v-vvdec .
                    v-summ-obj       = v-summ-obj    - v-vvdec .
            end.
  end.
end.
 end.
end procedure.
procedure proc-body-cli :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
      for each temp-obj :
                    find last b1_arh-fin-ob-obj no-lock      where
                        b1_arh-fin-ob-obj.host-code           = v-host-code                and
                        b1_arh-fin-ob-obj.obj-type            = temp-obj.obj-type          and
                        b1_arh-fin-ob-obj.obj-code            = temp-obj.obj-code          and
                        b1_arh-fin-ob-obj.contract-code       = 0                          and
                        b1_arh-fin-ob-obj.cli-type            = g#customer.obj-type        and
                        b1_arh-fin-ob-obj.cli-code            = g#customer.obj-code        and
                        b1_arh-fin-ob-obj.fin-ext-doc-type    = 'рас':U                 and
                        b1_arh-fin-ob-obj.calc-curr-code      = v-curr                     and
                        b1_arh-fin-ob-obj.sum-type            = "":U                       and
                        b1_arh-fin-ob-obj.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b1_arh-fin-ob-obj then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type   and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-fo   = temp-t.sum-fo  + b1_arh-fin-ob-obj.income
                                      v-summ-obj      = v-summ-obj     + b1_arh-fin-ob-obj.income                                  .
                        end.
                    find last b2_arh-fin-ob-obj no-lock      where
                        b2_arh-fin-ob-obj.host-code           = v-host-code                and
                        b2_arh-fin-ob-obj.obj-type            = temp-obj.obj-type          and
                        b2_arh-fin-ob-obj.obj-code            = temp-obj.obj-code          and
                        b2_arh-fin-ob-obj.contract-code       = 0                          and
                        b2_arh-fin-ob-obj.cli-type            = g#customer.obj-type        and
                        b2_arh-fin-ob-obj.cli-code            = g#customer.obj-code        and
                        b2_arh-fin-ob-obj.fin-ext-doc-type    = 'при':U                  and
                        b2_arh-fin-ob-obj.calc-curr-code      = v-curr                     and
                        b2_arh-fin-ob-obj.sum-type            = "":U                       and
                        b2_arh-fin-ob-obj.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b2_arh-fin-ob-obj then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-fo   = temp-t.sum-fo  - b2_arh-fin-ob-obj.expense
                                      v-summ-obj      = v-summ-obj     - b2_arh-fin-ob-obj.expense
                                  .
                        end.
                    find last b1_beznal_arh-fin no-lock      where
                        b1_beznal_arh-fin.host-code           = v-host-code                and
                        b1_beznal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b1_beznal_arh-fin.obj-code            = temp-obj.obj-code          and
                        b1_beznal_arh-fin.code-schet          = 0                          and
                        b1_beznal_arh-fin.contract-code       = 0                          and
                        b1_beznal_arh-fin.cli-type            = g#customer.obj-type        and
                        b1_beznal_arh-fin.cli-code            = g#customer.obj-code        and
                        b1_beznal_arh-fin.fin-ext-doc-type    = 'рпп':U  and
                        b1_beznal_arh-fin.calc-curr-code      = v-curr                     and
                        b1_beznal_arh-fin.sum-type            = "sum-contract":U           and
                        b1_beznal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b1_beznal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  + b1_beznal_arh-fin.income
                                      v-summ-obj        = v-summ-obj    - b1_beznal_arh-fin.income
                                  .
                        end.
                    find last b2_beznal_arh-fin no-lock      where
                        b2_beznal_arh-fin.host-code           = v-host-code                and
                        b2_beznal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b2_beznal_arh-fin.obj-code            = temp-obj.obj-code          and
                        b2_beznal_arh-fin.code-schet          = 0                          and
                        b2_beznal_arh-fin.contract-code       = 0                          and
                        b2_beznal_arh-fin.cli-type            = g#customer.obj-type        and
                        b2_beznal_arh-fin.cli-code            = g#customer.obj-code        and
                        b2_beznal_arh-fin.fin-ext-doc-type    = 'ппп':U   and
                        b2_beznal_arh-fin.calc-curr-code      = v-curr                     and
                        b2_beznal_arh-fin.sum-type            = "sum-contract":U           and
                        b2_beznal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b2_beznal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type   and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  - b2_beznal_arh-fin.expense
                                      v-summ-obj        = v-summ-obj    + b2_beznal_arh-fin.expense
                                  .
                        end.
                    find last b1_nal_arh-fin no-lock      where
                        b1_nal_arh-fin.host-code           = v-host-code                and
                        b1_nal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b1_nal_arh-fin.obj-code            = temp-obj.obj-code          and
                        b1_nal_arh-fin.fin-code-acc        = 0                          and
                        b1_nal_arh-fin.curr-code           = 0                          and
                        b1_nal_arh-fin.contract-code       = 0                          and
                        b1_nal_arh-fin.cli-type            = g#customer.obj-type        and
                        b1_nal_arh-fin.cli-code            = g#customer.obj-code        and
                        b1_nal_arh-fin.fin-ext-doc-type    = 'рко':U      and
                        b1_nal_arh-fin.calc-curr-code      = v-curr                     and
                        b1_nal_arh-fin.sum-type            = "sum-contract":U           and
                        b1_nal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b1_nal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  + b1_nal_arh-fin.income
                                      v-summ-obj      = v-summ-obj  - b1_nal_arh-fin.income
                                  .
                        end.
                    find last b2_nal_arh-fin no-lock      where
                        b2_nal_arh-fin.host-code           = v-host-code                and
                        b2_nal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b2_nal_arh-fin.obj-code            = temp-obj.obj-code          and
                        b2_nal_arh-fin.fin-code-acc        = 0                          and
                        b2_nal_arh-fin.curr-code           = 0                          and
                        b2_nal_arh-fin.contract-code       = 0                          and
                        b2_nal_arh-fin.cli-type            = g#customer.obj-type        and
                        b2_nal_arh-fin.cli-code            = g#customer.obj-code        and
                        b2_nal_arh-fin.fin-ext-doc-type    = 'пко':U       and
                        b2_nal_arh-fin.calc-curr-code      = v-curr                     and
                        b2_nal_arh-fin.sum-type            = "sum-contract":U           and
                        b2_nal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b2_nal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type   and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  - b2_nal_arh-fin.expense
                                      v-summ-obj      = v-summ-obj  + b2_nal_arh-fin.expense
                                  .
                        end.
                    find last b3_nal_arh-fin no-lock      where
                        b3_nal_arh-fin.host-code           = v-host-code                and
                        b3_nal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b3_nal_arh-fin.obj-code            = temp-obj.obj-code          and
                        b3_nal_arh-fin.fin-code-acc        = 0                          and
                        b3_nal_arh-fin.curr-code           = 0                          and
                        b3_nal_arh-fin.contract-code       = 0                          and
                        b3_nal_arh-fin.cli-type            = g#customer.obj-type        and
                        b3_nal_arh-fin.cli-code            = g#customer.obj-code        and
                        b3_nal_arh-fin.fin-ext-doc-type    = 'апр':U    and
                        b3_nal_arh-fin.calc-curr-code      = v-curr                     and
                        b3_nal_arh-fin.sum-type            = "sum-contract":U           and
                        b3_nal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b3_nal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  + b3_nal_arh-fin.income
                                      v-summ-obj      = v-summ-obj  - b3_nal_arh-fin.income
                                  .
                        end.
                    find last b4_nal_arh-fin no-lock      where
                        b4_nal_arh-fin.host-code           = v-host-code                and
                        b4_nal_arh-fin.obj-type            = temp-obj.obj-type          and
                        b4_nal_arh-fin.obj-code            = temp-obj.obj-code          and
                        b4_nal_arh-fin.contract-code       = 0                          and
                        b4_nal_arh-fin.cli-type            = g#customer.obj-type        and
                        b4_nal_arh-fin.cli-code            = g#customer.obj-code        and
                        b4_nal_arh-fin.fin-code-acc        = 0                          and
                        b4_nal_arh-fin.curr-code           = 0                          and
                        b4_nal_arh-fin.fin-ext-doc-type    = 'апп':U     and
                        b4_nal_arh-fin.calc-curr-code      = v-curr                     and
                        b4_nal_arh-fin.sum-type            = "sum-contract":U           and
                        b4_nal_arh-fin.fact-order         <= fact-order-2
                        use-index pi no-error .
                        if available b4_nal_arh-fin then do:
                          find first temp-t where
                                      temp-t.cli-type = g#customer.obj-type and
                                      temp-t.cli-code = g#customer.obj-code and
                                      temp-t.obj-type = temp-obj.obj-type   and
                                      temp-t.obj-code = temp-obj.obj-code  no-error .
                              if not available temp-t then
                                create temp-t.
                                  assign
                                      temp-t.cli-type = g#customer.obj-type
                                      temp-t.cli-code = g#customer.obj-code
                                      temp-t.obj-type = temp-obj.obj-type
                                      temp-t.obj-code = temp-obj.obj-code
                                      temp-t.sum-p      = temp-t.sum-p  - b4_nal_arh-fin.expense
                                      v-summ-obj      = v-summ-obj  + b4_nal_arh-fin.expense
                                  .
                        end.
   end.
 end.
end procedure.
def var vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure macr_excel_char :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .
 if p-val = ? then p-val = "" .
    put stream macr_excel unformatted
          substitute('formula(&3,"r&1c&2")', p-row , p-col , format-excel-text-macr ( p-val) ) + chr(10)  .
 end.
end procedure.
procedure macr_excel_char_with_format :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .
 if p-val = ? then p-val = "" .
    put stream macr_excel unformatted
          substitute('select("r&1c&2")', p-row , p-col ) + chr(10) .
    put stream macr_excel unformatted 'format.number("@")' + chr(10) .
    put stream macr_excel unformatted
          substitute('formula(&3,"r&1c&2")', p-row , p-col , format-excel-text-macr ( p-val) ) + chr(10)  .
 end.
end procedure.
procedure macr_excel_cell_format :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val    as character no-undo .
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-format as character no-undo .
 if p-val = ? then p-val = "" .
    put stream macr_excel unformatted
          substitute('select("r&1c&2")', p-row , p-col ) + chr(10) .
    put stream macr_excel unformatted substitute('format.number("&1")', p-format) + chr(10) .
    put stream macr_excel unformatted
          substitute('formula(&3,"r&1c&2")', p-row , p-col , format-excel-text-macr ( p-val) ) + chr(10)  .
 end.
end procedure.
procedure macr_excel_sum :
 do
 on error undo, return error return-value
 :
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .
 define input parameter  p-row1 as integer no-undo .
 define input parameter  p-col1 as integer no-undo .
 define input parameter  p-row2 as integer no-undo .
 define input parameter  p-col2 as integer no-undo .
    put stream macr_excel unformatted
          substitute('formula("=sum(r&3c&4:r&5c&6)","r&1c&2")', p-row , p-col , p-row1 , p-col1 ,p-row2 , p-col2 ) + chr(10)  .
 end.
end procedure.
procedure macr_excel_dec :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer   no-undo .
 define input parameter  p-col as integer   no-undo .
  if p-val = ? then p-val =  "" .
   put  stream macr_excel unformatted
        substitute('formula(&3,"r&1c&2")', p-row , p-col ,  p-val )  + chr(10) .
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
   substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) + chr(10) .
  if p-color <> ? then do:
     put  stream macr_excel unformatted
       substitute('patterns(1,,&1,true)', p-color ) + chr(10)  .
  end.
  put  stream macr_excel unformatted
       substitute('format.font(,&1,&2,&3)' , p-size,
                                        string ( p-bold  , "true/false" ) ,
                                        string ( p-italic , "true/false" )
                                        ) + chr(10) .
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
procedure proc-print-header :
 do
 on error undo, return error return-value
 :
   find first sheetf .
     sheetf.excel-row-heder =  num-entries( c-str ,chr(10)) + 1.
     sheetf.excel-row-title =  num-entries( sheetf.excel-column-lable , chr(10) ).
     var-1 =  num#str# .
     repeat c-c = 1 to sheetf.excel-row-title :
     num#str# = num#str# + 1 .
     p-var = num-entries( entry (c-c, sheetf.excel-column-lable, chr(10)) , chr(44) ) .
     do c-i = 1 to p-var :
        str--1 = entry( c-i, entry (c-c,sheetf.excel-column-lable, chr(10)) , chr(44)) .
        str--2 = integer(entry( c-i, sheetf.sizes )) .
        num#col# = c-i .
        run macr_excel_char_with_format ( str--1  , num#str# , num#col#  ) .
        run macr_cell_size ( str--2 , ? , num#str# , num#col# , ?, ? ) .
     end.
    c-i = 0.
    end.
    run macr_cell_format (
        10       ,
        true     ,
        false    ,
        35       ,
        var-1 + 1,
        1        ,
        num#str# ,
        num#col# )
        .
  put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , var-1 + 1 , 1 , num#str# ,  num#col# ) + chr(10)  +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + chr(10)
       .
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
