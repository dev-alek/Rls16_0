block-level on error undo, throw.
define input parameter parparentproc    as handle no-undo.
define input parameter DcardMode        as character no-undo.
define input parameter FixDCard         as character no-undo.
define input parameter ProdMode         as integer no-undo.
define input parameter T-zeros          as logical no-undo.
define input parameter T-legacy         as logical no-undo.
define input parameter T-subsid         as logical no-undo.
define input parameter t-imp            as logical no-undo.
define input parameter p-T-obj-detal    as logical no-undo.
define input parameter UpLevel          as decimal format "->>>,>>>,>>9.99":U no-undo.
define input parameter selectcard       as character no-undo.
define input parameter p-curr-r-b       as character no-undo.
define variable vss-revision    as character no-undo init "$Revision: a8e2cf75ddf6, 2506, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июл 08 17:09:06 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-xldcr2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-xldcr2.p $":U .
define variable vss-description as character no-undo init "Отчёт по Картам клиентов".
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
define   shared variable gdsgrp_recids      as character no-undo.
define   shared variable fin-schet-recid    as character no-undo.
define   shared variable v-d-report-handle  as handle    no-undo .
define   shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define   shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define   shared temp-table tmp#grp no-undo
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
define   shared temp-table gds-list no-undo like ub.goods
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
define    shared  temp-table gds-list-hist no-undo
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
define   shared temp-table X-init_obj-list no-undo
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function breakstr returns character ( input        for-name    as character,
                                      input        line-length as integer,
                                      input-output line1       as character,
                                      input-output line2       as character ) :
  define variable ii as integer no-undo.
  if length( for-name ) > line-length then do:
    assign ii    = 1
           line1 = "":u
           line2 = "":u.
    if length( entry( ii, for-name , " ":u ) ) > line-length then do:
      assign line1 =       substring( for-name, 1, line-length     )
             line2 = trim( substring( for-name,    line-length + 1 ) ).
    end.                                                     else do:
      do while length( line1 + entry( ii, for-name, " ":u ) ) < ( line-length + 1 ) :
        assign line1 = line1 + entry( ii, for-name, " ":u ) + " ":u
               ii    = ii    + 1.
        if length( entry( ii, for-name, " ":u ) ) > line-length then do:
          assign line1 = line1 + substring( for-name, length( line1 ), line-length - length( line1 ) + 1 ).
        end.
      end.
      assign line2 = trim( substring( for-name, length( line1 ) ) ).
    end.
  end.                                else do:
    assign line1 = for-name
           line2 = "":u.
  end.
  return ( line1 ).
end function.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-d-pcnt RETURNS CHARACTER
  ( buffer loc-dis-card for ub.dis-card,
    input parhost-code as integer,
    input parobj-type as character,
    input parobj-code as integer,
    input p-discnt-role as character,
    output loc-d-v as decimal) :
define variable v-node-code as integer no-undo .
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_dis-card-property for ub.dis-card-property.
find first buf_dis-card-type no-lock where
          buf_dis-card-type.type = loc-dis-card.type
      and buf_dis-card-type.emitent-host-code = loc-dis-card.emitent-host-code
      and buf_dis-card-type.host-code = 0
      and buf_dis-card-type.obj-type = '':U
      and buf_dis-card-type.obj-code = 0 no-error.
if available buf_dis-card-type then do:
  case p-discnt-role:
    when 'def-pcnt':U  then do:
      assign
      v-node-code = 1.
    end.
    when 'def-cash-pcnt':U then do:
      assign
      v-node-code = 2.
    end.
    when 'def-categ':U then do:
      assign
      v-node-code = 3.
    end.
  end.
  if buf_dis-card-type.d-pcnt-byshop then do:
   find first buf_dis-card-property no-lock where
             buf_dis-card-property.d-card = loc-dis-card.d-card
         and buf_dis-card-property.dtm-code = 26
         and buf_dis-card-property.host-code = parhost-code
         and buf_dis-card-property.obj-type = parobj-type
         and buf_dis-card-property.obj-code = parobj-code
         and buf_dis-card-property.node-code = v-node-code no-error.
   if available buf_dis-card-property then do:
     if p-discnt-role = 'def-categ':U then do:
       assign
       loc-d-v = buf_dis-card-property.property-value-integer.
     end.
     else do:
       assign
       loc-d-v = buf_dis-card-property.property-value-decimal.
     end.
   end.
    if loc-d-v = ? then do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  loc-dis-card.type
  ,input  loC-dis-card.emitent-host-code
  ,input  parhost-code
  ,input  parobj-type
  ,input  parobj-code
  ,input  p-discnt-role
  ,output loc-d-v
  ) no-error .
    end.
    if loc-d-v = ? then do:
      find first buf_dis-card-property no-lock where
                buf_dis-card-property.d-card = loc-dis-card.d-card
            and buf_dis-card-property.dtm-code = 26
            and buf_dis-card-property.host-code = parhost-code
            and buf_dis-card-property.obj-type = ''
            and buf_dis-card-property.obj-code = 0
            and buf_dis-card-property.node-code = v-node-code no-error.
      if available buf_dis-card-property then do:
        if p-discnt-role = 'def-categ':U then do:
          assign
          loc-d-v = buf_dis-card-property.property-value-integer.
        end.
        else do:
          assign
          loc-d-v = buf_dis-card-property.property-value-decimal.
        end.
      end.
    end.
    if loc-d-v = ? then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  loc-dis-card.type
  ,input  loC-dis-card.emitent-host-code
  ,input  parhost-code
  ,input  ''
  ,input  0
  ,input  p-discnt-role
  ,output loc-d-v
  ) no-error .
    end.
    if loc-d-v = ? then do:
      case p-discnt-role:
        when 'def-categ':U then do:
          loc-d-v = loc-dis-card.category.
        end.
        when 'def-pcnt':U then do:
          loc-d-v = loc-dis-card.d-pcnt.
        end.
        when 'def-cash-pcnt':U then do:
          loc-d-v = loc-dis-card.cash-d-pcnt.
        end.
      end case.
    end.
    if p-discnt-role = 'def-categ':U then do:
      return substitute("(i) &1", string(loc-d-v, ">>>9")).
    end.
    else do:
      return substitute("(i) &1", string(loc-d-v, "->9.99%")).
    end.
  end.
end.
else do:
 return "ОШИБКА-НЕТ ТИПА".
end.
case p-discnt-role:
  when 'def-categ':U then do:
     loc-d-v = loc-dis-card.category.
     return string(loc-d-v, ">>>9").
  end.
  when 'def-pcnt':U then do:
    loc-d-v = loc-dis-card.d-pcnt.
    return string(loc-d-v, "->9.99%").
  end.
  when 'def-cash-pcnt':U then do:
    loc-d-v = loc-dis-card.cash-d-pcnt.
    return string(loc-d-v, "->9.99%").
  end.
end case.
END FUNCTION.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared  temp-table dc-list no-undo like ub.dis-card
  field to-del as logical
  field order-num as integer
  field fdec as decimal
  field fint as integer
  field flog as logical
  field fchar as character
  index pi  is primary unique d-card
  index cn      card-num
  index cli cli-type cli-code
  index host-dscnt  emitent-host-code status_ d-pcnt
  index host-type  emitent-host-code type d-pcnt
  index oi order-num
  .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared   temp-table dc-list-hist no-undo
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
define variable vss-include-info17 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table dcards  no-undo
field obj-type      as character
field obj-code      as integer
field obj-name      as character
field chk-doc-code  like ub.chk-doc.doc-code
field chk-date      like ub.chk-doc.chk-date
field shift-date    like ub.chk-doc.shift-date
field d-card        like ub.dis-card.d-card
field card-num-chr  as character
field card-num      like ub.dis-card.card-num
field sourced-card  like ub.dis-card.sourced-card
field main-card     like ub.dis-card.main-card
field first-card    like ub.dis-card.first-card
field first-main-card like ub.dis-card.first-main-card
field cli-type-code as character
field artic         like ub.goods.artic
field b-code        like ub.bar-code.b-code
field node-code     like ub.gds-prt.node-code
field prod-type     like ub.clients.obj-type
field prod-code     like ub.clients.obj-code
field sale-price    like ub.price-list.price-sale
field doc-qnty      like ub.chk-gds.doc-qnty
field grp-goods     as character
field grp-lvl       as integer
field upper-code    like gds-grp.upper-code
field gds-name      like ub.goods.gds-name
field gds-code      like ub.goods.gds-code
field sum           as decimal
field discount      as decimal
field counter       as integer
field grp-code like ub.goods.grp-code
field sum-withdisc  as decimal
field qnty-bonus as decimal
INDEX pi            IS PRIMARY obj-type obj-code d-card
index p4            first-card
index p5            main-card
index p6            first-main-card
index html_1        grp-lvl artic
index upper_code    d-card upper-code
index dcard         d-card
.
do:
end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable new-doc as logical no-undo.
define variable v-prod-type as character no-undo.
define variable v-prod-code as integer no-undo.
define variable v-grp-code like ub.gds-grp.node-code no-undo.
define variable v-gds-code like ub.goods.gds-code no-undo.
define variable v-grp-name like ub.goods.grp-name no-undo.
define variable v-card-num-chr as character no-undo.
define variable ii-grp as integer no-undo.
define variable v-found as logical no-undo.
define variable v-count as integer no-undo.
define variable v-shift-on as logical no-undo.
define variable v-grp-gds as character no-undo.
define variable is-petrol as logical no-undo.
define variable is-pieces as logical no-undo.
define variable v-for-netto as decimal no-undo.
define variable v-prodmode2 as character no-undo.
define variable FixProdAttr as character no-undo.
define variable sym1 as character initial ":" no-undo.
define variable sym2 as character initial ":" no-undo.
define variable Line as character no-undo.
define variable NotInc as logical no-undo.
define variable only-one-card-per-cli as integer no-undo.
define variable only-one-card-per-leg as integer no-undo.
define variable for-name as character no-undo.
define variable namebuf1 as character no-undo.
define variable namebuf2 as character no-undo.
define variable v-full-path-RepView as character no-undo.
define variable v-file-name-rep-htm as character no-undo.
define variable g#report-num as integer no-undo.
define variable v-report-name as character no-undo.
define variable v-period as character no-undo.
define variable v-msg-noAllChk as character no-undo.
define variable v-short-obj-list as character no-undo.
define variable v-sel-card-string as character no-undo.
define variable v-sel-gds-string as character no-undo.
define variable v-prod-mode-string as character no-undo.
define variable v-legacy-string as character no-undo.
define variable v-subsid-string as character no-undo.
define variable v-dcard_doc-qnty as decimal no-undo.
define variable v-dcard_sum-withoutdisc as decimal no-undo.
define variable v-dcard_sum-withdisc as decimal no-undo.
define variable v-dcard_discount as decimal no-undo.
define variable v-obj_doc-qnty as decimal no-undo.
define variable v-obj_sum-withoutdisc as decimal no-undo.
define variable v-obj_sum-withdisc as decimal no-undo.
define variable v-obj_discount as decimal no-undo.
define variable v-first-of-d-card as logical no-undo.
define variable v-obj-chk-counter as integer no-undo.
define variable v-obj-type as character format "X(3)" no-undo.
define variable v-obj-code as integer no-undo.
define variable v-obj-name as character no-undo.
define variable num-g#              as integer no-undo.
define variable for-d-pcnt          as character no-undo.
define variable loc-d-pcnt          like ub.dis-card.d-pcnt no-undo.
define variable v-header-base-curr  as character no-undo.
define variable accum-counter       as integer no-undo.
define variable accum-qnty          as decimal no-undo.
define variable accum-sum           as decimal no-undo.
define variable accum-discount      as decimal no-undo.
define variable accum-netto         as decimal no-undo.
define variable accum-counter-cli   as integer no-undo.
define variable accum-qnty-cli      as decimal no-undo.
define variable accum-sum-cli       as decimal no-undo.
define variable accum-discount-cli  as decimal no-undo.
define variable accum-netto-cli     as decimal no-undo.
define variable accum-counter-leg   as integer no-undo.
define variable accum-qnty-leg      as decimal no-undo.
define variable accum-sum-leg       as decimal no-undo.
define variable accum-discount-leg  as decimal no-undo.
define variable accum-netto-leg     as decimal no-undo.
define variable accum-counter-crd   as integer no-undo.
define variable accum-qnty-crd      as decimal no-undo.
define variable accum-sum-crd       as decimal no-undo.
define variable accum-discount-crd  as decimal no-undo.
define variable accum-netto-crd     as decimal no-undo.
define variable v-d-card            like ub.dis-card.d-card no-undo.
define variable v-ii                as integer no-undo.
define variable stream-pos          as integer no-undo.
define variable v-root-card         like ub.dis-card.d-card no-undo.
define variable v-cli-code          like ub.dis-card.cli-code no-undo.
define variable v-cli-type          like ub.dis-card.cli-type no-undo.
define variable v-cli-type-code     as character no-undo.
define variable v-cli-name          like ub.clients.obj-name no-undo.
define variable v-show-d-card       like ub.dis-card.d-card no-undo.
define variable ii                  as integer no-undo.
define variable v-base-code         like ub.sysconf.base-code no-undo.
define variable v-mes-noAll-chk     as character no-undo.
define variable v-accur-13          as character initial "->>>>>>>>>>>>9.99" no-undo.
define buffer buf_clients for ub.clients.
define buffer buf2_clients for ub.clients.
define buffer buf3_clients for ub.clients.
define buffer buf_currency for ub.currency.
define temp-table my-table no-undo
    field note1 as character
    field note2 as character
    field note3 as character
    field note4 as character
    field note5 as character
    field note6 as character
    field note7 as character
    field note8 as character
    field note9 as character
    field note10 as character
    field note11 as character
.
define temp-table obj-host no-undo
    field host-code like ub.sysconf.host-code
index pi is primary unique host-code.
define temp-table tt-selCliObjList no-undo
    field dbname-cliobjname as character
.
define temp-table tt-CliObjType no-undo
    field producer-name as character
.
define temp-table tt-selectgood no-undo
    field collection-name as character
    field collection-element as character
.
define temp-table tt-selGrpCds no-undo
    field GrpCds-name as character
.
define temp-table tt-selGdsList no-undo
    field gds-string as character
.
define buffer buf_shop for ub.shop.
define buffer buf_store for ub.store.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_dcards for dcards.
define buffer buf-crd_dcards for dcards.
define buffer buf-crd2_dcards for dcards.
define buffer buf-obj_dcards for dcards.
define buffer buf-obj1_dcards for dcards.
define buffer buf-obj3_dcards for dcards.
define buffer X_dis-card for ub.dis-card.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_CHK-GDS for ub.chk-gds.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_payment for ub.payment.
define buffer buf_payment-attr for ub.payment-attr.
define buffer buf_obj-list for obj-list.
define stream OutStr-html.
define stream MyWatch-strm.
function fnc-DD-MM-YYYY returns character
(input p-dat-date as date) forward.
function fnc-convert-dot-to-colon returns character
(input p-data as decimal, p-accur as character) forward.
run My-Rep.
run waitfram-hide in this-procedure .
procedure calc-chk:
    v-first-of-d-card = no.
    do:
        if dcardmode = "ONE":U then
        do:
            if not buf_chk-doc.d-card = FixDCard then return.
        end.
        if dcardmode = "list":U then
        do:
            find first dc-list where
            dc-list.d-card = buf_chk-doc.d-card no-error.
            if not available dc-list then return.
        end.
    end.
    process events.
    v-count = v-count + 1.
    if (v-count  modulo 10) = 0
    and  v-count >= 10 then
    do:
        run waitfram-show in this-procedure (input substitute("&1&2 обработано чеков &3"
                                                                ,obj-list.obj-type
                                                                ,obj-list.obj-code
                                                                ,v-count))
        .
    end.
    new-doc = yes.
    if p-T-obj-detal = yes  then
    do:
        v-obj-type = obj-list.obj-type.
        v-obj-code = obj-list.obj-code.
        v-obj-name = obj-list.obj-name.
    end.
    else
    do:
        v-obj-type = "".
        v-obj-code = 0.
        v-obj-name = "".
    end.
    do:
    end.
    do:
    end.
    do:
        _chk: for each buf_chk-gds where buf_chk-gds.doc-code = buf_chk-doc.doc-code
              ,
              first buf_bar-code no-lock where
                    buf_bar-code.b-code = buf_chk-gds.b-code
              ,
              first buf_goods no-lock where
                    buf_goods.gds-code = buf_bar-code.gds-code
        :
            do:
            end.
            if buf_chk-gds.write-off-code <> ? and
               buf_chk-gds.write-off-code > 0 then next _CHk.
                if prodmode = 3 then
                do:
                    if not can-find(first g#cli no-lock where
                                          g#cli.obj-type = buf_goods.prod-type and
                                          g#cli.obj-code = buf_goods.prod-code) then next _chk.
                end.
                if prodmode = 2 then
                do:
                    assign
                        v-grp-name = ""
                        v-found = no
                    .
                    _ii-grp: do ii-grp = 1 to num-entries(buf_goods.grp-name, chr(47)) - 1
                    :
                        assign
                            v-grp-name = v-grp-name + entry(ii-grp, buf_goods.grp-name, chr(47)) + chr(47)
                        .
                        if can-find(first tmp#grp no-lock where
                                          tmp#grp.grp-name = v-grp-name) then
                        do:
                            assign v-found = yes.
                            leave _ii-grp.
                        end.
                    end.
                    if not v-found then next _chk.
                end.
                if prodmode = 4 then
                do:
                    if not can-find(first gds-list no-lock where
                                          gds-list.gds-code = buf_goods.gds-code) then next _chk.
                end.
            do:
            end.
            find first dcards where
                       dcards.obj-type = v-obj-type and
                       dcards.obj-code = v-obj-code and
                       dcards.chk-date = buf_chk-doc.chk-date and
                       dcards.d-card = buf_chk-doc.d-card and
                       dcards.b-code = buf_bar-code.b-code
            no-error.
            if not available dcards then
            do:
                create dcards.
                assign
                    dcards.obj-type     = v-obj-type
                    dcards.obj-code     = v-obj-code
                    dcards.obj-name     = v-obj-name
                    dcards.chk-date     = buf_chk-doc.chk-date
                    dcards.shift-date   = buf_chk-doc.shift-date
                    dcards.chk-doc-code = buf_chk-doc.doc-code
                    dcards.d-card       = buf_chk-doc.d-card
                    dcards.artic        = buf_goods.artic
                    dcards.gds-name     = buf_goods.gds-name
                    dcards.b-code       = buf_bar-code.b-code
                    dcards.prod-type    = buf_goods.prod-type
                    dcards.prod-code    = buf_goods.prod-code
                    dcards.doc-qnty     = 0
                    dcards.grp-code     = buf_goods.grp-code
                    dcards.gds-code     = buf_goods.gds-code
                .
                if t-legacy or t-subsid then
                do:
                    find first buf_dis-card no-lock where
                               buf_dis-card.d-card = buf_chk-doc.d-card
                    no-error.
                    if available buf_dis-card then
                    do:
                        assign
                            v-card-num-chr = (if t-legacy and t-subsid then buf_dis-card.first-main-card
                                                else (if t-legacy and not t-subsid then buf_dis-card.first-card
                                                        else buf_dis-card.main-card))
                        .
                        assign
                            dcards.d-card          = buf_dis-card.d-card
                            dcards.card-num-chr    = v-card-num-chr
                            dcards.first-card      = buf_dis-card.first-card
                            dcards.main-card       = buf_dis-card.main-card
                            dcards.first-main-card = buf_dis-card.first-main-card
                            dcards.cli-type-code   = buf_dis-card.cli-type + string(buf_dis-card.cli-code)
                            dcards.card-num        = buf_dis-card.card-num
                        .
                    end.
                end.
                else
                do:
                    if buf_chk-doc.cli-type = ?
                    or buf_chk-doc.cli-code = ?
                    or buf_chk-doc.cli-type = '':U
                    or buf_chk-doc.cli-code = 0 then
                    do:
                        find first buf_dis-card no-lock where
                        buf_dis-card.d-card = buf_chk-doc.d-card no-error.
                        if available buf_dis-card then
                        do:
                            assign
                                dcards.cli-type-code = buf_dis-card.cli-type + string(buf_dis-card.cli-code)
                            .
                        end.
                    end.
                    else
                    do:
                        assign
                            dcards.cli-type-code = buf_chk-doc.cli-type + string(buf_chk-doc.cli-code)
                        .
                    end.
                end.
            end.
            v-first-of-d-card = yes.
            assign
                dcards.doc-qnty = dcards.doc-qnty + buf_chk-gds.doc-qnty
                dcards.sale-price = buf_chk-gds.price-base
                dcards.counter = dcards.counter + 1
                dcards.sum = dcards.sum + (buf_chk-gds.doc-qnty * dcards.sale-price)
                dcards.discount = dcards.discount + (buf_chk-gds.doc-qnty *
                                  (buf_chk-gds.discnt +
                                  (buf_chk-gds.price-base - buf_chk-gds.price-base)))
                dcards.sum-withdisc = dcards.sum - dcards.discount
                new-doc = no
            .
        end.
        if v-first-of-d-card = yes  then
        do:
            find first buf-crd_dcards where
                       buf-crd_dcards.grp-lvl = 1000 and
                       buf-crd_dcards.obj-type = v-obj-type and
                       buf-crd_dcards.obj-code = v-obj-code and
                       buf-crd_dcards.d-card = dcards.d-card and
                       buf-crd_dcards.cli-type-code = dcards.cli-type-code
            no-lock no-error.
            if not available buf-crd_dcards then
            do:
                create buf-crd_dcards.
                assign
                    buf-crd_dcards.grp-lvl = 1000
                    buf-crd_dcards.obj-type = v-obj-type
                    buf-crd_dcards.obj-code = v-obj-code
                    buf-crd_dcards.d-card = dcards.d-card
                    buf-crd_dcards.cli-type-code = dcards.cli-type-code
                .
            end.
            if available buf-crd_dcards then
            do:
                buf-crd_dcards.counter = buf-crd_dcards.counter + 1.
            end.
        end.
    end.
end procedure.
procedure My-Rep:
do:
end.
    run get-full-path-RepViewer(output v-full-path-RepView).
    run get-report-num in parParentProc(output g#report-num).
    run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).
    run create-file(v-file-name-rep-htm).
    define frame X123
        sym1                column-label ":!:" format "X(1)"
        dcards.chk-date     column-label "Дата!покупки" format "99/99/9999"
        dcards.artic        column-label "Артикул! " format "X(16)"
        dcards.b-code       column-label "Баркод!" format ">>>>>>>>>>>>9"
        ub.goods.gds-name   format "X(25)"
        buf3_clients.obj-name   column-label "Производитель!(поставщик)" format "X(38)"
        dcards.sale-price   column-label "Цена!отпускная" format ">,>>>,>>9.99"
        dcards.doc-qnty         column-label "Количество  ! " format "->>>>>>9.<<<"
        dcards.sum          column-label "Получено! " format "->>,>>>,>>>,>>9.99"
        dcards.discount     column-label "Скидка! " format "->>,>>>,>>9.99"
        v-for-netto         column-label "Сумма!нетто" format "->>>,>>>,>>9.99"
        sym2                column-label ":!:" format "X(1)"
        header
        v-header-base-curr  format "X(40)" at 50
        "Страница " at 100 page-number( PrnLibStream ) at 110 format ">>>>9" skip
        Line format "X(184)" at 1
        with width 232 down stream-io use-text
    .
    case X-selectgood:
        when 3 then
        do:
            for each g#cli no-lock
            :
                num-g# = num-g# + 1.
                if num-g# = 1 then FixProdAttr = g#cli.obj-type + string(g#cli.obj-code).
                if num-g# > 1 then leave.
            end.
        end.
        when 2 then
        do:
            for each tmp#grp no-lock
            :
                num-g# = num-g# + 1.
                if num-g# = 1 then FixProdAttr = string(tmp#grp.node-code).
                if num-g# > 1 then leave.
            end.
        end.
        when 4 or when 5 then
        do:
            for each gds-list no-lock
            :
                num-g# = num-g# + 1.
                if num-g# = 1 then
                FixProdAttr = string(gds-list.gds-code).
                if num-g# > 1 then leave.
            end.
        end.
    end case.
    run waitfram-show in this-procedure ("Подождите ...").
    do:
    end.
        if prodmode = 3 then
        do:
            assign
                v-prod-type = Substr(FixProdAttr, 1, 3)
                v-prod-code = integer(substr(FixProdAttr, 4))
            .
        end.
        if prodmode = 2 then
        do:
            assign
                v-grp-code = integer(FixProdAttr)
            .
            run grplib-get-full-name in this-procedure (
                                                         input v-grp-code
                                                        ,output v-grp-name)
            .
        end.
        if prodmode = 5 then
        do:
            assign
                v-gds-code = integer(FixProdAttr)
            .
        end.
    for each obj-host:
        delete obj-host.
    end.
    create obj-host.
    assign
        obj-host.host-code = 0
    .
    _obj: for each obj-list
    :
        if obj-list.obj-type = 'маг':U then
        do:
            find first buf_shop no-lock where
            buf_shop.obj-code = obj-list.obj-code.
            find first obj-host no-lock where
            obj-host.host-code = buf_shop.host-code no-error.
            if not available obj-host then
            do:
                create obj-host.
                assign
                    obj-host.host-code = buf_shop.host-code
                .
            end.
        end.
        else
        do:
            find first buf_store no-lock where
            buf_store.obj-code = obj-list.obj-code.
            find first obj-host no-lock where
            obj-host.host-code = buf_store.host-code no-error.
            if not available obj-host then
            do:
                create obj-host.
                assign
                    obj-host.host-code = buf_store.host-code
                .
            end.
        end.
        if x-TOG-Shift = yes then
        do:
            if can-find(first ub.chk-doc where
            ub.chk-doc.obj-type = obj-list.obj-type and
            ub.chk-doc.obj-code = obj-list.obj-code and
            (ub.chk-doc.shift-date >= X-date-Start) and
            (ub.chk-doc.shift-date <= X-date-End) and
            ub.chk-doc.d-card <> "" and
            ub.chk-doc.out-code <> ?) then
                do:
                    _chk-doc1: for each buf_chk-doc no-lock where
                    buf_chk-doc.obj-type = obj-list.obj-type and
                    buf_chk-doc.obj-code = obj-list.obj-code and
                    (buf_chk-doc.shift-date > X-date-Start or (buf_chk-doc.shift-date = X-date-Start and buf_chk-doc.shift-num >= x-Shift-Start)) and
                    (buf_chk-doc.shift-date < X-date-End or (buf_chk-doc.shift-date = X-date-End and buf_chk-doc.shift-num <= x-Shift-End)) and
                    buf_chk-doc.d-card <> "":U and
                    buf_chk-doc.out-code <> ?
                    :
                        do:
                            if lookup(string(buf_chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,69,101,106,108,169,196,114,115,116,117,111,112,136,113,101,106,108,208,2,3,4,5,7,43,44':U) > 0 then next _chk-doc1.
                            run calc-chk.
                        end.
                    end.
                end.
        end.
        else
        do:
            if can-find(first chk-doc where
            chk-doc.obj-type = obj-list.obj-type and
            chk-doc.obj-code = obj-list.obj-code and
            chk-doc.chk-date >= X-date-Start and
            chk-doc.chk-date <= X-date-End and
            chk-doc.d-card <> "" and
            chk-doc.out-code <> ?) then
            do:
                _chk-doc: for each buf_chk-doc no-lock where
                buf_chk-doc.obj-type = obj-list.obj-type and
                buf_chk-doc.obj-code = obj-list.obj-code and
                buf_chk-doc.chk-date >= X-date-Start and
                buf_chk-doc.chk-date <= X-date-End and
                buf_chk-doc.d-card <> "":U and
                buf_chk-doc.out-code <> ?
                :
                    do:
                        if lookup(string(buf_chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,69,101,106,108,169,196,114,115,116,117,111,112,136,113,101,106,108,208,2,3,4,5,7,43,44':U) > 0 then next _chk-doc.
                        run calc-chk.
                    end.
                end.
            end.
        end.
        if  p-T-obj-detal = yes  then
        do:
            if can-find(first dcards) then
            do:
                assign
                    v-obj-chk-counter = 0
                    v-obj_doc-qnty = 0
                    v-obj_sum-withoutdisc = 0
                    v-obj_sum-withdisc = 0
                    v-obj_discount = 0
                .
                for each buf-obj_dcards where
                         buf-obj_dcards.obj-type = obj-list.obj-type and
                         buf-obj_dcards.obj-code = obj-list.obj-code and
                         buf-obj_dcards.grp-lvl = 0
                break
                    by buf-obj_dcards.d-card
                :
                    if first-of(buf-obj_dcards.d-card) then
                    do:
                        run transform-tt-level(input buf-obj_dcards.obj-type, input buf-obj_dcards.obj-code, input buf-obj_dcards.d-card  ).
                        do:
                            assign
                                v-dcard_doc-qnty = 0
                                v-dcard_sum-withoutdisc = 0
                                v-dcard_sum-withdisc = 0
                                v-dcard_discount = 0
                            .
                        end.
                    end.
                    assign
                        v-dcard_doc-qnty = v-dcard_doc-qnty + buf-obj_dcards.doc-qnty
                        v-dcard_sum-withoutdisc = v-dcard_sum-withoutdisc + buf-obj_dcards.sum
                        v-dcard_sum-withdisc = v-dcard_sum-withdisc + buf-obj_dcards.sum-withdisc
                        v-dcard_discount = v-dcard_discount + buf-obj_dcards.discount
                    .
                    assign
                        v-obj_sum-withoutdisc = v-obj_sum-withoutdisc + buf-obj_dcards.sum
                        v-obj_sum-withdisc = v-obj_sum-withdisc + buf-obj_dcards.sum-withdisc
                        v-obj_discount = v-obj_discount + buf-obj_dcards.discount
                    .
                    if last-of(buf-obj_dcards.d-card) then
                    do:
                        find first buf-crd_dcards where
                                   buf-crd_dcards.grp-lvl = 1000 and
                                   buf-crd_dcards.obj-type = buf-obj_dcards.obj-type and
                                   buf-crd_dcards.obj-code = buf-obj_dcards.obj-code and
                                   buf-crd_dcards.d-card = buf-obj_dcards.d-card and
                                   buf-crd_dcards.cli-type-code = buf-obj_dcards.cli-type-code
                        no-error.
                        for first buf_clients where
                                  buf_clients.obj-type = substring(buf-obj_dcards.cli-type-code, 1, 3) and
                                  buf_clients.obj-code = integer(substring(buf-obj_dcards.cli-type-code, 4))
                        :
                            buf-crd_dcards.gds-name = buf_clients.obj-name.
                        end.
                        assign
                            buf-crd_dcards.doc-qnty = v-dcard_doc-qnty
                            buf-crd_dcards.sum = v-dcard_sum-withoutdisc
                            buf-crd_dcards.sum-withdisc = v-dcard_sum-withdisc
                            buf-crd_dcards.discount = v-dcard_discount
                        .
                        v-obj-chk-counter = v-obj-chk-counter + buf-crd_dcards.counter.
                    end.
                end.
                find first buf-obj1_dcards where
                          buf-obj1_dcards.grp-lvl = 2000 and
                          buf-obj1_dcards.obj-type = obj-list.obj-type and
                          buf-obj1_dcards.obj-code = obj-list.obj-code and
                          buf-obj1_dcards.obj-name = obj-list.obj-name
                no-lock no-error.
                if not available buf-obj1_dcards then
                do:
                    create buf-obj1_dcards.
                    assign
                        buf-obj1_dcards.grp-lvl = 2000
                        buf-obj1_dcards.obj-type = obj-list.obj-type
                        buf-obj1_dcards.obj-code = obj-list.obj-code
                        buf-obj1_dcards.obj-name = obj-list.obj-name
                    .
                end.
                if available buf-obj1_dcards then
                do:
                    assign
                        buf-obj1_dcards.counter = v-obj-chk-counter
                        buf-obj1_dcards.sum = v-obj_sum-withoutdisc
                        buf-obj1_dcards.sum-withdisc = v-obj_sum-withdisc
                        buf-obj1_dcards.discount = v-obj_discount
                    .
                end.
            end.
        end.
    end.
    if p-T-obj-detal = no  then
    do:
        if can-find(first dcards) then
        do:
            assign
                v-obj_doc-qnty = 0
                v-obj_sum-withoutdisc = 0
                v-obj_sum-withdisc = 0
                v-obj_discount = 0
            .
            for each buf-obj3_dcards where
                     buf-obj3_dcards.grp-lvl = 0
            break
                by buf-obj3_dcards.d-card
            :
                if first-of(buf-obj3_dcards.d-card) then
                do:
                    run transform-tt-level(input buf-obj3_dcards.obj-type, input buf-obj3_dcards.obj-code, input buf-obj3_dcards.d-card  ).
                    do:
                        assign
                            v-dcard_doc-qnty = 0
                            v-dcard_sum-withoutdisc = 0
                            v-dcard_sum-withdisc = 0
                            v-dcard_discount = 0
                        .
                    end.
                end.
                assign
                    v-dcard_doc-qnty = v-dcard_doc-qnty + buf-obj3_dcards.doc-qnty
                    v-dcard_sum-withoutdisc = v-dcard_sum-withoutdisc + buf-obj3_dcards.sum
                    v-dcard_sum-withdisc = v-dcard_sum-withdisc + buf-obj3_dcards.sum-withdisc
                    v-dcard_discount = v-dcard_discount + buf-obj3_dcards.discount
                .
                assign
                    v-obj_sum-withoutdisc = v-obj_sum-withoutdisc + buf-obj3_dcards.sum
                    v-obj_sum-withdisc = v-obj_sum-withdisc + buf-obj3_dcards.sum-withdisc
                    v-obj_discount = v-obj_discount + buf-obj3_dcards.discount
                .
                if last-of(buf-obj3_dcards.d-card) then
                do:
                    find first buf-crd_dcards where
                               buf-crd_dcards.grp-lvl = 1000 and
                               buf-crd_dcards.obj-type = buf-obj3_dcards.obj-type and
                               buf-crd_dcards.obj-code = buf-obj3_dcards.obj-code and
                               buf-crd_dcards.d-card = buf-obj3_dcards.d-card and
                               buf-crd_dcards.cli-type-code = buf-obj3_dcards.cli-type-code
                    no-lock no-error.
                    if available buf-crd_dcards then
                    do:
                        for first buf_clients where
                                  buf_clients.obj-type = substring(buf-obj3_dcards.cli-type-code, 1, 3) and
                                  buf_clients.obj-code = integer(substring(buf-obj3_dcards.cli-type-code, 4))
                        :
                            buf-crd_dcards.gds-name = buf_clients.obj-name.
                        end.
                        assign
                            buf-crd_dcards.doc-qnty = v-dcard_doc-qnty
                            buf-crd_dcards.sum = v-dcard_sum-withoutdisc
                            buf-crd_dcards.sum-withdisc = v-dcard_sum-withdisc
                            buf-crd_dcards.discount = v-dcard_discount
                        .
                        v-obj-chk-counter = v-obj-chk-counter + buf-crd_dcards.counter.
                    end.
                end.
            end.
            if can-find(first dcards) then
            do:
                create buf-obj1_dcards.
                assign
                    buf-obj1_dcards.obj-name = "ИТОГО"
                    buf-obj1_dcards.grp-lvl = 2000
                    buf-obj1_dcards.counter = v-obj-chk-counter
                    buf-obj1_dcards.sum = v-obj_sum-withoutdisc
                    buf-obj1_dcards.sum-withdisc = v-obj_sum-withdisc
                    buf-obj1_dcards.discount = v-obj_discount
                .
                release buf-obj1_dcards.
            end.
        end.
    end.
    if T-zeros  then
    do:
        if can-find(first dcards) then
        do:
            case dcardmode:
                when "LIST":U then
                do:
                    for each dc-list no-lock
                    :
                        if not can-find(first dcards no-lock where
                            dcards.d-card = dc-list.d-card) then
                        do:
                            create dcards.
                            assign
                                dcards.chk-date         = 01/01/1990
                                dcards.d-card           = dc-list.d-card
                                dcards.artic            = "":U
                                dcards.b-code           = 0
                                dcards.prod-type        = "":U
                                dcards.prod-code        = 0
                                dcards.doc-qnty         = 0
                                dcards.node-code        = 0
                                dcards.cli-type-code    = dc-list.cli-type + string(dc-list.cli-code)
                                dcards.card-num         = dc-list.card-num
                                dcards.grp-lvl          = 1000
                            .
                            if t-legacy or t-subsid then
                            do:
                                assign
                                    v-card-num-chr = (if t-legacy and t-subsid
                                                      then dc-list.first-main-card
                                                      else (if t-legacy and not t-subsid
                                                            then dc-list.first-card
                                                            else dc-list.main-card))
                                .
                                assign
                                    dcards.d-card           = dc-list.d-card
                                    dcards.card-num-chr     = v-card-num-chr
                                    dcards.first-card       = dc-list.first-card
                                    dcards.main-card        = dc-list.main-card
                                    dcards.first-main-card  = dc-list.first-main-card
                                    dcards.cli-type-code    = dc-list.cli-type + string(dc-list.cli-code)
                                .
                            end.
                        end.
                    end.
                end.
                when "ALL":U then
                do:
                    for each X_dis-card no-lock
                    :
                        if X_dis-card.emitent-host-code <> 0 and
                           not can-find(first obj-host no-lock where obj-host.host-code = X_dis-card.emitent-host-code)
                        then next.
                        if not can-find(first dcards no-lock where
                           dcards.d-card = X_dis-card.d-card) then
                        do:
                            create dcards.
                            assign
                                dcards.chk-date         = 01/01/1990
                                dcards.d-card           = X_dis-card.d-card
                                dcards.artic            = "":U
                                dcards.b-code           = 0
                                dcards.prod-type        = "":U
                                dcards.prod-code        = 0
                                dcards.doc-qnty         = 0
                                dcards.node-code        = 0
                                dcards.cli-type-code    = X_dis-card.cli-type + string(X_dis-card.cli-code)
                                dcards.card-num         = X_dis-card.card-num
                                dcards.grp-lvl          = 1000
                            .
                            if t-legacy then
                            do:
                                assign
                                    v-card-num-chr = (if t-legacy and t-subsid
                                                      then X_dis-card.first-main-card
                                                      else (if t-legacy and not t-subsid
                                                            then X_dis-card.first-card
                                                            else X_dis-card.main-card))
                                .
                                assign
                                    dcards.d-card          = X_dis-card.d-card
                                    dcards.card-num-chr    = v-card-num-chr
                                    dcards.first-card      = X_dis-card.first-card
                                    dcards.main-card       = X_dis-card.main-card
                                    dcards.first-main-card = X_dis-card.first-main-card
                                    dcards.cli-type-code = X_dis-card.cli-type + string(X_dis-card.cli-code)
                                .
                            end.
                        end.
                        else
                        do:
                        end.
                    end.
                end.
                when "ONE":U then
                do:
                end.
            end case.
        end.
    end.
    if t-imp = yes then
    do:
        if can-find(first dcards) then
        do:
            assign
                v-obj_doc-qnty = 0
                v-obj_sum-withoutdisc = 0
                v-obj_sum-withdisc = 0
                v-obj_discount = 0
            .
            for each obj-host where
                     obj-host.host-code > 0
            :
                _chk-payment: for each buf_payment no-lock where
                                       buf_payment.host-code = obj-host.host-code
                                   and (buf_payment.fact-date >= X-date-Start)
                                   and (buf_payment.fact-date <= X-date-End)
                                   and buf_payment.d-card > ""
                                   and buf_payment.status_ = 'факт':U
                                   and buf_payment.source-type = 'касс':U + chr(44) + 'import':U
                :
                    do:
                        if dcardmode = "list" then
                        do:
                            find first dc-list where
                                dc-list.d-card = buf_payment.d-card no-error
                            .
                            if not available dc-list then
                            do:
                                next _chk-payment.
                            end.
                        end.
                    end.
                    do:
                    end.
                    process events.
                    do:
                        v-count = v-count + 1.
                        if (v-count modulo 10) = 0
                            and v-count >= 10 then
                        do:
                            run waitfram-show in this-procedure (input substitute("&1 обработано чеков &2"
                                                                        ,obj-host.host-code
                                                                        ,v-count))
                            .
                        end.
                    end.
                    new-doc = yes.
                    find first buf_dis-card no-lock where
                               buf_dis-card.d-card = buf_payment.d-card no-error
                    .
                    if t-legacy or t-subsid then
                    do:
                        if available buf_dis-card then
                        do:
                            assign
                                v-card-num-chr = (if t-legacy and t-subsid
                                                  then buf_dis-card.first-main-card
                                                  else (if t-legacy and not t-subsid
                                                        then buf_dis-card.first-card
                                                        else buf_dis-card.main-card))
                            .
                        end.
                    end.
                    do:
                    end.
                    do:
                        find first dcards where
                                   dcards.d-card        = buf_payment.d-card
                               and dcards.b-code        = 0
                               and dcards.sale-price    = 0
                               and dcards.grp-lvl       = 1000
                               and dcards.artic         = "импорт из ВС"
                        no-error.
                        if not available dcards then
                        do:
                            create dcards.
                            assign
                                dcards.d-card       = buf_payment.d-card
                                dcards.b-code       = 0
                                dcards.sale-price   = 0
                                dcards.grp-lvl      = 1000
                                dcards.artic        = "Импорт из ВС"
                                dcards.doc-qnty     = 0
                                dcards.sum          = 0
                            .
                            if t-legacy or t-subsid then
                            do:
                                assign
                                    dcards.d-card           = buf_dis-card.d-card
                                    dcards.card-num-chr     = v-card-num-chr
                                    dcards.first-card       = buf_dis-card.first-card
                                    dcards.main-card        = buf_dis-card.main-card
                                    dcards.first-main-card  = buf_dis-card.first-main-card
                                    dcards.cli-type-code    = buf_dis-card.cli-type + string(buf_dis-card.cli-code)
                                    dcards.card-num         = buf_dis-card.card-num
                                .
                            for first buf_clients where
                                      buf_clients.obj-type = substring(dcards.cli-type-code, 1, 3) and
                                      buf_clients.obj-code = integer(substring(dcards.cli-type-code, 4))
                            :
                                dcards.gds-name = buf_clients.obj-name.
                            end.
                            end.
                            else
                            do:
                                if available buf_dis-card then
                                do:
                                    assign
                                        dcards.cli-type-code = buf_dis-card.cli-type + string(buf_dis-card.cli-code)
                                    .
                                end.
                                else
                                do:
                                    assign
                                        dcards.cli-type-code = buf_payment.cli-type + string(buf_payment.cli-code)
                                    .
                                end.
                            end.
                        end.
                        assign
                            dcards.doc-qnty     = 0
                            dcards.sale-price   = 0
                            dcards.sum          = dcards.sum + buf_payment.tot-cli
                            dcards.counter      = (if new-doc then dcards.counter + 1 else dcards.counter)
                        .
                        if new-doc = yes then
                        do:
                            v-obj_doc-qnty = v-obj_doc-qnty + 1.
                            v-obj_sum-withoutdisc = v-obj_sum-withoutdisc + buf_payment.tot-cli.
                        end.
                        new-doc = no.
                    end.
                    do:
                        if p-T-obj-detal = yes then
                        do:
                            find first dcards where
                                       dcards.b-code        = 0
                                   and dcards.sale-price    = 0
                                   and dcards.grp-lvl       = 2000
                                   and dcards.artic         = "Итого Импорт из ВС"
                            no-error.
                        end.
                        else
                        do:
                            find first dcards where
                                       dcards.d-card        = buf_payment.d-card
                                   and dcards.b-code        = 0
                                   and dcards.sale-price    = 0
                                   and dcards.grp-lvl       = 1
                                   and dcards.upper-code    = 1
                                   and dcards.gds-name      = "ВС"
                                   and dcards.artic         = "Импорт из ВС"
                            no-error.
                        end.
                        if not available dcards then
                        do:
                            if p-T-obj-detal = yes then
                            do:
                                create dcards.
                                assign
                                    dcards.d-card       = ""
                                    dcards.b-code       = 0
                                    dcards.sale-price   = 0
                                    dcards.grp-lvl      = 2000
                                    dcards.artic        = "Итого Импорт из ВС"
                                    dcards.doc-qnty     = 0
                                .
                            end.
                            else
                            do:
                                create dcards.
                                assign
                                    dcards.d-card       = buf_payment.d-card
                                    dcards.b-code       = 0
                                    dcards.sale-price   = 0
                                    dcards.grp-lvl      = 1
                                    dcards.doc-qnty     = 0
                                    dcards.upper-code   = 1
                                    dcards.gds-name     = "ВС"
                                    dcards.artic        = "Импорт из ВС"
                                .
                            end.
                        end.
                        if available dcards then
                        do:
                            assign
                                dcards.doc-qnty     = 0
                                dcards.sale-price   = 0
                                dcards.sum          = dcards.sum + buf_payment.tot-cli
                                dcards.counter      = (dcards.counter + 1)
                            .
                        end.
                    end.
                end.
            end.
            do:
                for first buf-obj1_dcards where
                          buf-obj1_dcards.obj-name   = "ИТОГО" and
                          buf-obj1_dcards.grp-lvl    = 2000
                no-lock
                :
                    assign
                        buf-obj1_dcards.counter = buf-obj1_dcards.counter + v-obj_doc-qnty
                        buf-obj1_dcards.sum = buf-obj1_dcards.sum + v-obj_sum-withoutdisc
                    .
                    release buf-obj1_dcards.
                end.
            end.
        end.
    end.
    do:
    end.
    run waitfram-hide in this-procedure.
    if can-find(first dcards) then
    do:
        run prn-lib-open-stream in this-procedure (
                                                     input my-handle
                                                    ,input 43
                                                    ,input yes
                                                    ,input no
                                                   ).
        Line = fill("-", 200).
        form header
            line format "X(184)" at 1 skip
            "Продолжение - на следующей странице" at 30 skip
            with frame BottomFrame width 232 page-bottom no-labels no-box
        .
        view stream PrnLibStream frame BottomFrame.
        assign
            v-report-name = "Отчет по картам клиентам"
        .
        assign
            v-period = str1
        .
        assign
            v-msg-noAllChk = (if NotInc then "(сформирован НЕ ПО ВСЕМ ЧЕКАМ)" else "")
        .
        put stream PrnLibStream
            space(40) "Отчет по продажам постоянным клиентам" skip
            space(40) str1 format "X(60)" skip
            space(20) (if NotInc then "(сформирован НЕ ПО ВСЕМ ЧЕКАМ)" else " ") format "x(40)" skip
            space(20) "По объектам :"
        .
        _short-list: for each obj-list no-lock
        :
            find first buf_clients where
                       buf_clients.obj-type = obj-list.obj-type and
                       buf_clients.obj-code = obj-list.obj-code no-lock
            .
            find first ub.db where
                       ub.db.db-num = buf_clients.db-num no-lock
            .
            do:
            end.
            do:
                v-short-obj-list = v-short-obj-list + (if length(v-short-obj-list) > 0 then ";  " else "") +  buf_clients.obj-name.
                if length(v-short-obj-list) > 100 then
                do:
                    v-short-obj-list = substring(v-short-obj-list, 1, 100) + "...".
                    leave _short-list.
                end.
            end.
            do:
            end.
        end.
        do:
        end.
        case DcardMode:
            when "ALL":U then
            do:
                v-sel-card-string = "По ВСЕМ картам.".
                do:
                end.
            end.
            when "ONE":U then
            do:
            end.
            when "LIST":U then
            do:
                ii = 0.
                for each dc-list no-lock
                :
                    ii = ii + 1.
                end.
                v-sel-card-string = "По сформированному списку карт" + "(в списке " + string(ii) + " кар.)".
                do:
                    put stream PrnLibStream
                        space(10) string("По сформированному списку карт") format "x(50)" skip
                        substitute("В списке &1 карт", ii) skip
                    .
                end.
            end.
        end case.
        if X-SelectGood = 1 then
        do:
            create tt-selectgood.
            tt-selectgood.collection-name = "По ВСЕМ производителям (поставщикам).".
            do:
                put stream PrnLibStream
                    space(20) "По ВСЕМ производителям (поставщикам)." format "x(40)" skip(1)
                .
            end.
        end.
        else
        do:
            case X-selectgood:
                when 3 then
                do:
                    do:
                        put stream PrnLibStream
                        space(20) "По производителям: " format "x(80)" skip(0).
                    end.
                    _g#cli: for each g#cli
                    :
                        do:
                            put stream PrnLibStream
                                space(20) g#cli.obj-name format "x(80)" skip(0)
                            .
                        end.
                        if available tt-selectgood then
                        do:
                            if tt-selectgood.collection-element = g#cli.obj-name then next.
                        end.
                        else
                        do:
                            create tt-selectgood.
                        end.
                        if available tt-selectgood then
                        do:
                            tt-selectgood.collection-element = tt-selectgood.collection-element + g#cli.obj-name + "; ".
                            if length(tt-selectgood.collection-element) > 100 then
                            do:
                                tt-selectgood.collection-element = substring(tt-selectgood.collection-element, 1, 100).
                                tt-selectgood.collection-element = right-trim(tt-selectgood.collection-element, " ").
                                tt-selectgood.collection-element = right-trim(tt-selectgood.collection-element, ";").
                                tt-selectgood.collection-element = tt-selectgood.collection-element + "...".
                                leave _g#cli.
                            end.
                        end.
                    end.
                    find first tt-selectgood no-lock no-error.
                    if not available tt-selectgood then
                    do:
                        create tt-selectgood.
                    end.
                    tt-selectgood.collection-name = "По производителям:".
                end.
                when 2 then
                do:
                    do:
                        put stream PrnLibStream
                            space(20) "По группам товаров: " format "x(80)" skip(0)
                        .
                    end.
                    _tmp#grp: for each tmp#grp
                    :
                        do:
                            put stream PrnLibStream
                                space(20) tmp#grp.grp-name format "x(80)" skip(0)
                            .
                        end.
                        if available tt-selectgood then
                        do:
                            if tt-selectgood.collection-element = tmp#grp.grp-name then next.
                        end.
                        else
                        do:
                            create tt-selectgood.
                        end.
                        if available tt-selectgood then
                        do:
                            tt-selectgood.collection-element = tt-selectgood.collection-element + tmp#grp.grp-name + "; ".
                            if length(tt-selectgood.collection-element) > 100 then
                            do:
                                tt-selectgood.collection-element = substring(tt-selectgood.collection-element, 1, 100).
                                tt-selectgood.collection-element = right-trim(tt-selectgood.collection-element, " ").
                                tt-selectgood.collection-element = right-trim(tt-selectgood.collection-element, ";").
                                tt-selectgood.collection-element = tt-selectgood.collection-element + "...".
                                leave _tmp#grp.
                            end.
                        end.
                    end.
                    find first tt-selectgood no-lock no-error.
                    if not available tt-selectgood then
                    do:
                        create tt-selectgood.
                    end.
                    tt-selectgood.collection-name = "По группам товаров:".
                end.
                when 4 then
                do:
                    ii = 0.
                    for each gds-list
                    :
                        ii = ii + 1.
                    end.
                    create tt-selectgood.
                    tt-selectgood.collection-name = "По сформированному списку товаров " + "(В списке " + string(ii) + " товаров).".
                    do:
                        put stream PrnLibStream
                            space(10) "По сформированному списку товаров " format "x(50)"
                            substitute("(В списке &1 товаров)", ii) skip
                        .
                    end.
                end.
                when 5 then
                do:
                    find first gds-list
                    .
                    create tt-selectgood.
                    tt-selectgood.collection-name = "По товару:".
                    tt-selectgood.collection-element = string(gds-list.artic) + chr(32) +
                                                      gds-list.prod-type + string(gds-list.prod-code) +
                                                      chr(32) + gds-list.gds-name
                    .
                    do:
                        put stream PrnLibStream
                            space(20) "По товару: " format "x(10)"
                            gds-list.artic chr(32) gds-list.prod-type gds-list.prod-code chr(32) gds-list.gds-name skip(0)
                        .
                    end.
                end.
            end case.
        end.
        do:
        end.
        if t-legacy or t-subsid then
        do:
            if t-legacy then v-legacy-string = "С учетом перевыпуска карт (приведены номера карт ПОСЛЕДНЕГО ВЫПУСКА).".
            if t-subsid then v-subsid-string = "С учетом дополнительных карт (приведены номера ОСНОВНЫХ карт).".
            do:
                put stream PrnLibStream unformatted
                    (if t-legacy then "С учетом перевыпуска карт (приведены номера карт ПОСЛЕДНЕГО ВЫПУСКА)"
                     else '':U)
                    (if t-subsid then "С учетом дополнительных карт (приведены номера ОСНОВНЫХ карт)"
                     else '':U)
                                skip (1)
                .
            end.
        end.
        do:
        end.
        do:
        end.
        run proc-create-HTML(
                                 input v-file-name-rep-htm
                                ,input v-report-name
                                ,input v-period
                            ).
        run search-full-path-Report(input v-file-name-rep-htm).
        run Report-Viewer(input v-full-path-RepView, input v-file-name-rep-htm).
        do:
        end.
    end.
    else
    do:
        message
            "На выбранных Вами объектах" skip
            "не было продаж постоянным клиентам" skip
            "в течение заданного Вами периода времени."
        view-as alert-box information.
        for each dcards:
            delete dcards.
        end.
    end.
end procedure.
procedure proc-create-HTML:
    define input parameter p-file-name-rep-htm as character no-undo.
    define input parameter p-report-name as character no-undo.
    define input parameter p-period as character no-undo.
    define variable v-message as character no-undo.
    define buffer buf-html_clients for ub.clients.
    define buffer buf-obj2_dcards for dcards.
    define buffer buf-crd2_dcards for dcards.
    define buffer buf-crd-imp_dcards for dcards.
    do:
        output stream OutStr-html to value(p-file-name-rep-htm) append convert target 'UTF-8'.
            put stream OutStr-html unformatted
                "<!DOCTYPE HTML>" skip
                ' <html>' skip
                '  <head>' skip
                '   <meta charset="utf-8">' skip
                '    <style type="text/css">' skip
                '      table ' + chr(123) + ' border-collapse: collapse; font-size: 9pt; table-layout: fixed; width: 1157px; padding: 14px; ' + chr(125) skip
                '      td ' + chr(123) ' border: 1px black ridge; word-wrap:break-word; ' + chr(125) skip
                '      htm' skip
                '      .rotate ' + chr(123) skip
                '        -webkit-transform: rotate(-90deg);' skip
                '        -moz-transform: rotate(-90deg);' skip
                '        -ms-transform: rotate(-90deg);' skip
                '        -o-transform: rotate(-90deg);' skip
                '        transform: rotate(-90deg);' skip
                '        -webkit-transform-origin: 50% 50%;' skip
                '        -moz-transform-origin: 50% 50%;' skip
                '        -ms-transform-origin: 50% 50%;' skip
                '        -o-transform-origin: 50% 50%;' skip
                '        transform-origin: 50% 50%;' skip
                '        filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);' skip
                '          ' + chr(125) skip
                '            th' + ' ' + chr(123) skip
                '            border: 1px black solid;' skip
                '            word-wrap: break-word;' skip
                '          ' + chr(125) skip
                '   </style>' skip
                '  </head>' skip
            .
    end.
    do:
            put stream OutStr-html unformatted
                ' <body>' skip
                '   <table name="Лист1" outline_below="false">' skip
                '     <thead>' skip
                '       <tr class="set_columns">' skip
                '         <td style="width: 130px; border: none;"></td>' skip
                '         <td style="width: 170px; border: none;"></td>' skip
                '         <td style="width: 77px; border: none;"></td>' skip
                '         <td style="width: 77px; border: none;"></td>' skip
                '         <td style="width: 77px; border: none;"></td>' skip
                '         <td style="width: 77px; border: none;"></td>' skip
                '       </tr>' skip
            .
    end.
    do:
            put stream OutStr-html unformatted
                '       <tr>' skip
                '         <td style="border: none; height: 14px"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td colspan="6" style="border: none; height: 14px; font-weight: bold; text-align: center">' + p-report-name + '</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td colspan="6" style="border: none; height: 14px; font-weight: bold; text-align: center">' + v-period + '</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <td style="border: none; height: 14px; font-weight: bold"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
            .
            if NotInc then
            do:
                run msg-html-noAllChk(output v-message).
                put stream OutStr-html unformatted
                    v-message
                .
            end.
            put stream OutStr-html unformatted
                '       <tr>' skip
                '         <td colspan="6" style="border: none; height: 14px; font-weight: bold">По объектам:</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
            .
            do:
            end.
            put stream OutStr-html unformatted
                '       <tr>' skip
                '         <td colspan="6" style="border: none; height: 14px">' + v-short-obj-list + '</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
            .
            put stream OutStr-html unformatted
                '       <tr>' skip
                '         <td style="border: none; height: 14px"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
            .
            put stream OutStr-html unformatted
                '       <tr>' skip
                '         <td colspan="6" style="border: none; height: 14px">' + v-sel-card-string + '</td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
            .
            if  X-SelectGood <> 1 then
            do:
                put stream OutStr-html unformatted
                    '       <tr>' skip
                    '         <td style="border: none; height: 14px"></td>' skip
                    '         <td style="border: none"></td>' skip
                    '         <td style="border: none"></td>' skip
                    '         <td style="border: none"></td>' skip
                    '         <td style="border: none"></td>' skip
                    '         <td style="border: none"></td>' skip
                    '       </tr>' skip
                .
            end.
            find first tt-selectgood no-lock no-error.
            if available tt-selectgood then
            do:
                if tt-selectgood.collection-name <> ? or tt-selectgood.collection-name <> "":U then
                do:
                    put stream OutStr-html unformatted
                        '       <tr>' skip
                        '         <td colspan="6" style="border: none; height: 14px">' + tt-selectgood.collection-name + '</td>' skip
                        '         <td style="border: none"></td>' skip
                        '         <td style="border: none"></td>' skip
                        '         <td style="border: none"></td>' skip
                        '         <td style="border: none"></td>' skip
                        '         <td style="border: none"></td>' skip
                        '       </tr>' skip
                    .
                end.
            end.
            if X-SelectGood <> 1 then
            do:
                define variable v-nn as integer initial 0 no-undo.
                for each tt-selectgood no-lock where
                :
                    if tt-selectgood.collection-element <> ? or tt-selectgood.collection-element <> "" then
                    do:
                        v-nn = v-nn + 1.
                        put stream OutStr-html unformatted
                            '       <tr>' skip
                            '         <td colspan="6" style="border: none; height: 14px">' + tt-selectgood.collection-element + '</td>' skip
                            '         <td style="border: none"></td>' skip
                            '         <td style="border: none"></td>' skip
                            '         <td style="border: none"></td>' skip
                            '         <td style="border: none"></td>' skip
                            '         <td style="border: none"></td>' skip
                            '       </tr>' skip
                        .
                    end.
                end.
                if v-nn > 0 and (t-legacy or t-subsid) then
                do:
                    put stream OutStr-html unformatted
                        '       <tr>' skip
                        '         <td style="border: none; height: 14px"></td>' skip
                        '         <td style="border: none"></td>' skip
                        '         <td style="border: none"></td>' skip
                        '         <td style="border: none"></td>' skip
                        '         <td style="border: none"></td>' skip
                        '         <td style="border: none"></td>' skip
                        '       </tr>' skip
                    .
                end.
            end.
            if t-legacy then
            do:
                put stream OutStr-html unformatted
                    '       <tr>' skip
                    '         <td colspan="6" style="border: none; height: 14px">' + v-legacy-string + '</td>' skip
                    '         <td style="border: none"></td>' skip
                    '         <td style="border: none"></td>' skip
                    '         <td style="border: none"></td>' skip
                    '         <td style="border: none"></td>' skip
                    '         <td style="border: none"></td>' skip
                    '       </tr>' skip
                .
            end.
            if t-subsid then
            do:
                put stream OutStr-html unformatted
                    '       <tr>' skip
                    '         <td colspan="6" style="border: none; height: 14px">' + v-subsid-string + '</td>' skip
                    '         <td style="border: none"></td>' skip
                    '         <td style="border: none"></td>' skip
                    '         <td style="border: none"></td>' skip
                    '         <td style="border: none"></td>' skip
                    '         <td style="border: none"></td>' skip
                    '       </tr>' skip
                .
            end.
            put stream OutStr-html unformatted
                '       <tr>' skip
                '         <td style="border: none; height: 14px"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '         <td style="border: none"></td>' skip
                '       </tr>' skip
            .
    end.
    do:
            put stream OutStr-html unformatted
                '     <tbody>' skip
                '       <tr>' skip
                '         <th style="text-align: center; height: 30px">Номер Карты / Артикул товара</th>' skip
                '         <th style="text-align: center;">Наименование</th>' skip
                '         <th style="text-align: center;">Кол-во чеков</th>' skip
                '         <th style="text-align: center;">Сумма</th>' skip
                '         <th style="text-align: center;">Скидка</th>' skip
                '         <th style="text-align: center;">Сумма нетто</th>' skip
                '       </tr>' skip
                '       <tr>' skip
                '         <th num="" style="text-align: center">1</th>' skip
                '         <th num="" style="text-align: center">2</th>' skip
                '         <th num="" style="text-align: center">3</th>' skip
                '         <th num="" style="text-align: center">4</th>' skip
                '         <th num="" style="text-align: center">5</th>' skip
                '         <th num="" style="text-align: center">6</th>' skip
                '       </tr>' skip
            .
        output stream OutStr-html close.
    end.
    do:
        output stream OutStr-html to value(p-file-name-rep-htm) append convert target 'UTF-8'.
        if p-T-obj-detal then
        do:
            for each buf-obj2_dcards where
                     buf-obj2_dcards.grp-lvl = 2000 and
                     buf-obj2_dcards.artic = "" no-lock
            :
                do:
                    put stream OutStr-html unformatted
                        '       <tr level="1">' skip
                        '         <td style="display: yes; text-align: left; height: 20px; font-weight: bold">' + "Объект: " + (if buf-obj2_dcards.obj-name = ? then "" else buf-obj2_dcards.obj-name) + '</td>' skip
                        '         <td style="display: yes; text-align: left; font-weight: bold"></td>' skip
                        '         <td num="0" style="display: yes; text-align: right; font-weight: bold">' + string(buf-obj2_dcards.counter) + '</td>' skip
                        '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-obj2_dcards.sum) + '"' + '>' +
                                    fnc-convert-dot-to-colon(buf-obj2_dcards.sum, v-accur-13) + '</td>' skip
                        '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-obj2_dcards.discount) + '"' + '>' +
                                    fnc-convert-dot-to-colon(buf-obj2_dcards.discount, v-accur-13) + '</td>' skip
                        '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-obj2_dcards.sum-withdisc) + '"' + '>' +
                                    fnc-convert-dot-to-colon(buf-obj2_dcards.sum-withdisc, v-accur-13) + '</td>' skip
                        '       </tr>' skip
                    .
                end.
                for each buf-crd2_dcards where
                         buf-crd2_dcards.obj-type = buf-obj2_dcards.obj-type and
                         buf-crd2_dcards.obj-code = buf-obj2_dcards.obj-code and
                         buf-crd2_dcards.grp-lvl  = 1000 and
                         buf-crd2_dcards.artic    = ""
                no-lock
                :
                    do:
                        put stream OutStr-html unformatted
                            '       <tr level="2">' skip
                            '         <td style="display: yes; text-align: left; height: 20px; font-weight: bold; padding-left: 10px">' +  string(fill(" ", (4))) +  (if buf-crd2_dcards.d-card <> ? then buf-crd2_dcards.d-card else "?") + '</td>' skip
                            '         <td style="display: yes; text-align: left; font-weight: bold">' +  buf-crd2_dcards.gds-name + " (" + buf-crd2_dcards.cli-type-code + ")" + '</td>' skip
                            '         <td num="0" style="display: yes; text-align: right; font-weight: bold">' + string(buf-crd2_dcards.counter) + '</td>' skip
                            '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-crd2_dcards.sum) + '"' + '>' +
                                        fnc-convert-dot-to-colon(buf-crd2_dcards.sum, v-accur-13) + '</td>' skip
                            '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-crd2_dcards.discoun) + '"' + '>' +
                                        fnc-convert-dot-to-colon(buf-crd2_dcards.discount, v-accur-13) + '</td>' skip
                            '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-crd2_dcards.sum-withdisc) + '"' + '>' +
                                        fnc-convert-dot-to-colon(buf-crd2_dcards.sum-withdisc, v-accur-13) + '</td>' skip
                            '       </tr>' skip
                        .
                    end.
                    if available buf-crd2_dcards then
                    do:
                        run tt-print-line (input buf-crd2_dcards.obj-type, input buf-crd2_dcards.obj-code, input buf-crd2_dcards.d-card, input 1, input 3).
                    end.
                end.
            end.
            if t-imp = yes then
            do:
                for each buf-obj2_dcards where
                         buf-obj2_dcards.grp-lvl = 2000 and
                         buf-obj2_dcards.artic = "Итого Импорт из ВС" no-lock
                :
                    do:
                        put stream OutStr-html unformatted
                            '       <tr level="1">' skip
                            '         <td style="display: yes; text-align: left; height: 20px; font-weight: bold">'  + (if buf-obj2_dcards.artic = ? then "" else buf-obj2_dcards.artic) + ":" + '</td>' skip
                            '         <td style="display: yes; text-align: left; font-weight: bold"></td>' skip
                            '         <td num="0" style="display: yes; text-align: right; font-weight: bold">' + string(buf-obj2_dcards.counter) + '</td>' skip
                            '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-obj2_dcards.sum) + '"' + '>' +
                                        fnc-convert-dot-to-colon(buf-obj2_dcards.sum, v-accur-13) + '</td>' skip
                            '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-obj2_dcards.discount) + '"' + '>' +
                                        fnc-convert-dot-to-colon(buf-obj2_dcards.discount, v-accur-13) + '</td>' skip
                            '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-obj2_dcards.sum-withdisc) + '"' + '>' +
                                        fnc-convert-dot-to-colon(buf-obj2_dcards.sum-withdisc, v-accur-13) + '</td>' skip
                            '       </tr>' skip
                        .
                    end.
                    for each buf-crd2_dcards where
                             buf-crd2_dcards.grp-lvl = 1000 and
                             buf-crd2_dcards.artic = "импорт из ВС" no-lock
                    :
                        do:
                            put stream OutStr-html unformatted
                                '       <tr level="2">' skip
                                '         <td style="display: yes; text-align: left; height: 20px; font-weight: bold; padding-left: 10px">' +  string(fill(" ", (4))) +  (if buf-crd2_dcards.d-card <> ? then buf-crd2_dcards.d-card else "?") + '</td>' skip
                                '         <td style="display: yes; text-align: left; font-weight: bold">' +  buf-crd2_dcards.gds-name + " (" + buf-crd2_dcards.cli-type-code + ")" + '</td>' skip
                                '         <td num="0" style="display: yes; text-align: right; font-weight: bold">' + string(buf-crd2_dcards.counter) + '</td>' skip
                                '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-crd2_dcards.sum) + '"' + '>' +
                                            fnc-convert-dot-to-colon(buf-crd2_dcards.sum, v-accur-13) + '</td>' skip
                                '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-crd2_dcards.discount) + '"' + '>' +
                                            fnc-convert-dot-to-colon(buf-crd2_dcards.discount, v-accur-13) + '</td>' skip
                                '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-crd2_dcards.sum-withdisc) + '"' + '>' +
                                            fnc-convert-dot-to-colon(buf-crd2_dcards.sum-withdisc, v-accur-13) + '</td>' skip
                                '       </tr>' skip
                            .
                        end.
                    end.
                end.
            end.
        end.
        else
        do:
            for each buf-obj2_dcards where
                      buf-obj2_dcards.grp-lvl = 2000 and
                      buf-obj2_dcards.gds-name <> "ВС" and
                      buf-obj2_dcards.artic <> "Импорт из ВС" no-lock
            :
                put stream OutStr-html unformatted
                    '       <tr level="1">' skip
                    '         <td style="display: yes; text-align: left; height: 20px; font-weight: bold">' + "Итого по всем ДКартам: " + '</td>' skip
                    '         <td style="display: yes; text-align: left; font-weight: bold"></td>' skip
                    '         <td num="0" style="display: yes; text-align: right; font-weight: bold">' + string(buf-obj2_dcards.counter) + '</td>' skip
                    '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-obj2_dcards.sum) + '"' + '>' +
                                fnc-convert-dot-to-colon(buf-obj2_dcards.sum, v-accur-13) + '</td>' skip
                    '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-obj2_dcards.discount) + '"' + '>' +
                                fnc-convert-dot-to-colon(buf-obj2_dcards.discount, v-accur-13) + '</td>' skip
                    '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-obj2_dcards.sum-withdisc) + '"' + '>' +
                                fnc-convert-dot-to-colon(buf-obj2_dcards.sum-withdisc, v-accur-13) + '</td>' skip
                    '       </tr>' skip
                .
                for each buf-crd2_dcards where
                         buf-crd2_dcards.grp-lvl = 1000
                no-lock
                :
                    do:
                        put stream OutStr-html unformatted
                            '       <tr level="2">' skip
                            '         <td style="display: yes; text-align: left; height: 20px; font-weight: bold; padding-left: 10px">' +  string(fill(" ", (4))) +  (if buf-crd2_dcards.d-card <> ? then buf-crd2_dcards.d-card else "?") + '</td>' skip
                            '         <td style="display: yes; text-align: left; font-weight: bold">' +  buf-crd2_dcards.gds-name + " (" + buf-crd2_dcards.cli-type-code + ")" + '</td>' skip
                            '         <td num="0" style="display: yes; text-align: right; font-weight: bold">' + string(buf-crd2_dcards.counter) + '</td>' skip
                            '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-crd2_dcards.sum) + '"' + '>' +
                                        fnc-convert-dot-to-colon(buf-crd2_dcards.sum, v-accur-13) + '</td>' skip
                            '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-crd2_dcards.discount) + '"' + '>' +
                                        fnc-convert-dot-to-colon(buf-crd2_dcards.discount, v-accur-13) + '</td>' skip
                            '         <td num="0.00" style="display: yes; text-align: right; font-weight: bold" val="' + string(buf-crd2_dcards.sum-withdisc) + '"' + '>' +
                                        fnc-convert-dot-to-colon(buf-crd2_dcards.sum-withdisc, v-accur-13) + '</td>' skip
                            '       </tr>' skip
                        .
                    end.
                    if available buf-crd2_dcards then
                    do:
                        run tt-print-line (input buf-crd2_dcards.obj-type, input buf-crd2_dcards.obj-code, input buf-crd2_dcards.d-card, input 1, input 3).
                    end.
                end.
            end.
        end.
    end.
    do:
                put stream OutStr-html unformatted
                '     </tbody>' skip
                '   </table>' skip
                '  </body>' skip
                ' </html>' skip
                .
        output stream OutStr-html close.
    end.
end procedure.
procedure msg-html-noAllChk:
    define output parameter p-message as character no-undo.
        p-message =
                '       <tr>' + chr(10) +
                '         <td style="border: none; height: 14px; font-weight: bold"></td>' + chr(10) +
                '         <td colspan="9" style="border: none">' + "сформирован НЕ ПО ВСЕМ ЧЕКАМ" + '</td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '       </tr>' + chr(10) +
                '       <tr>' + chr(10) +
                '         <td style="border: none; height: 14px; font-weight: bold"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '         <td style="border: none"></td>' + chr(10) +
                '       </tr>' + chr(10)
        .
end procedure.
procedure get-full-path-RepViewer:
    define output parameter p-fill-path-RepView as character no-undo.
    if search("exe\ReportViewer\reportviewer.exe") <> ? then
    do:
        p-fill-path-RepView = search("exe\ReportViewer\reportviewer.exe").
    end.
    else
    do:
        message "Не найдена программа просмотра отчёта!" view-as alert-box error.
    end.
end procedure.
procedure define-full-path-Report:
    define input parameter p-rep-num as integer no-undo.
    define output parameter p-file-name-rep-htm as character no-undo.
    p-file-name-rep-htm = session:temp-directory + "rpt" + string(p-rep-num) + ".html".
end procedure.
procedure search-full-path-Report:
    define input parameter p-file-name as character no-undo.
    if search(p-file-name) = ? then
        do:
            message "Не найден файл отчёта: " p-file-name view-as alert-box error.
        end.
    else
        do:
            p-file-name = search(p-file-name).
        end.
end procedure.
procedure Report-Viewer:
    define input parameter p-full-path-RepView as character no-undo.
    define input parameter p-file-name-rep-htm as character no-undo.
os-command no-wait value(p-full-path-RepView + " true " + search(p-file-name-rep-htm)).
end procedure.
procedure create-file:
    define input parameter p-file-name as character no-undo.
    output to value(string(p-file-name)).
    output close.
end procedure.
procedure tt-print-line:
    define input parameter p-obj-type as character no-undo.
    define input parameter p-obj-code as integer no-undo.
    define input parameter p-d-card as character no-undo.
    define input parameter p-upper-code like ub.gds-grp.upper-code no-undo.
    define input parameter p-print-lvl as integer no-undo.
    define variable v-display as character no-undo.
    define buffer buf3_dcards for dcards.
    for each buf3_dcards where
             buf3_dcards.upper-code = p-upper-code and
             buf3_dcards.obj-type = p-obj-type and
             buf3_dcards.obj-code = p-obj-code and
             buf3_dcards.d-card = p-d-card
    no-lock
    :
        if p-print-lvl < 3 then
        do:
            v-display = "yes".
        end.
        else
        do:
            v-display = "none".
        end.
        do:
            if buf3_dcards.grp-lvl <> 0 then
            do:
                put stream OutStr-html unformatted
                    '       <tr level="' + string(p-print-lvl) + '">' skip
                    '         <td style="display: ' + v-display + '; text-align: left; height: 20px; padding-left: ' + string((p-print-lvl - 0) * 10) + 'px; font-weight: bold">' + string(fill(" ", ((p-print-lvl - 1 ) * 4))) + buf3_dcards.artic + '</td>' skip
                    '         <td style="display: ' + v-display + '; text-align: left; font-weight: bold">' + buf3_dcards.gds-name + '</td>' skip
                    '         <td num="0" style="display: ' + v-display + '; text-align: right; font-weight: bold">' + (if buf3_dcards.counter = 0 then "" else (string(if buf3_dcards.counter <> ? then string (buf3_dcards.counter) else "?"))) + '</td>' skip
                    '         <td num="0.00" style="display: ' + v-display + '; text-align: right; font-weight: bold">' + if buf3_dcards.sum <> ? then fnc-convert-dot-to-colon(buf3_dcards.sum, v-accur-13) + '</td>' else "?" + '</td>' skip
                    '         <td num="0.00" style="display: ' + v-display + '; text-align: right; font-weight: bold">' + if buf3_dcards.discount <> ? then fnc-convert-dot-to-colon(buf3_dcards.discount, v-accur-13) + '</td>' else "?" + '</td>' skip
                    '         <td num="0.00" style="display: ' + v-display + '; text-align: right; font-weight: bold">' + if buf3_dcards.sum-withdisc <> ? then fnc-convert-dot-to-colon(buf3_dcards.sum-withdisc, v-accur-13) + '</td>' else "?" + '</td>' skip
                    '       </tr>' skip
                .
            end.
            else
            do:
                put stream OutStr-html unformatted
                    '       <tr level="' + string(p-print-lvl) + '">' skip
                    '         <td style="display: ' + v-display + '; text-align: left; height: 20px; padding-left: ' + string((p-print-lvl - 0) * 10) + 'px">' + string(fill(" ", ((p-print-lvl - 1 ) * 4))) + buf3_dcards.artic + '</td>' skip
                    '         <td style="display: ' + v-display + '; text-align: left">' + buf3_dcards.gds-name + '</td>' skip
                    '         <td num="0" style="display: ' + v-display + '; text-align: right">' + (if buf3_dcards.counter = 0 then "" else (string(if buf3_dcards.counter <> ? then string (buf3_dcards.counter) else "?"))) + '</td>' skip
                    '         <td num="0.00" style="display: ' + v-display + '; text-align: right">' + if buf3_dcards.sum <> ? then fnc-convert-dot-to-colon(buf3_dcards.sum, v-accur-13) + '</td>' else "?" + '</td>' skip
                    '         <td num="0.00" style="display: ' + v-display + '; text-align: right">' + if buf3_dcards.discount <> ? then fnc-convert-dot-to-colon(buf3_dcards.discount, v-accur-13) + '</td>' else "?" + '</td>' skip
                    '         <td num="0.00" style="display: ' + v-display + '; text-align: right">' + if buf3_dcards.sum-withdisc <> ? then fnc-convert-dot-to-colon(buf3_dcards.sum-withdisc, v-accur-13) + '</td>' else "?" + '</td>' skip
                    '       </tr>' skip
                .
            end.
        end.
        if buf3_dcards.grp-lvl <> 0 then run tt-print-line (input p-obj-type, input p-obj-code, input p-d-card, input buf3_dcards.grp-code, input p-print-lvl + 1).
    end.
end procedure.
procedure transform-tt-level:
    define input parameter p-obj-type as character no-undo.
    define input parameter p-obj-code as integer no-undo.
    define input parameter p-d-card like ub.dis-card.d-card no-undo.
    define variable v-doc-qnty as decimal no-undo.
    define variable v-sum-withoutdisc as decimal no-undo.
    define variable v-sum-withdisc as decimal no-undo.
    define variable v-discount as decimal no-undo.
    define variable v-gds-grp-name as character no-undo.
    define variable v-cur-lvl as integer no-undo.
    define variable v-upper-code as integer initial ? no-undo.
    define variable v-first-of as logical no-undo.
    define variable v-last-of as logical no-undo.
    define variable v-cur-recid as recid no-undo.
    define buffer buf1_dcards for dcards.
    define buffer buf2_dcards for dcards.
    define buffer bufobj_dcards for dcards.
    define buffer bufobj2_dcards for dcards.
    do while v-upper-code <> 0
    :
        v-upper-code = 0.
        v-gds-grp-name = ''.
        for each buf1_dcards where
                 buf1_dcards.grp-lvl  = v-cur-lvl and
                 buf1_dcards.obj-type = p-obj-type and
                 buf1_dcards.obj-code = p-obj-code and
                 buf1_dcards.d-card   = p-d-card
        break
            by buf1_dcards.grp-code
        :
            if first-of(buf1_dcards.grp-code) then
            do:
                assign
                    v-doc-qnty = 0
                    v-sum-withoutdisc = 0
                    v-sum-withdisc = 0
                    v-discount = 0
                .
                find first ub.gds-grp where
                           ub.gds-grp.node-code = buf1_dcards.grp-code
                no-lock no-error.
                if available ub.gds-grp then
                do:
                    assign
                        v-upper-code = ub.gds-grp.upper-code
                        v-gds-grp-name = ub.gds-grp.node-name
                    .
                end.
            end.
            buf1_dcards.upper-code = if buf1_dcards.grp-lvl = 0 then buf1_dcards.grp-code else v-upper-code.
            if buf1_dcards.grp-lvl <> 0 then
            do:
                assign
                    buf1_dcards.gds-name = v-gds-grp-name
                    buf1_dcards.artic = string(buf1_dcards.grp-code)
                .
            end.
            assign
                v-doc-qnty = v-doc-qnty + buf1_dcards.doc-qnty
                v-sum-withoutdisc = v-sum-withoutdisc + buf1_dcards.sum
                v-sum-withdisc = v-sum-withdisc + buf1_dcards.sum-withdisc
                v-discount = v-discount + buf1_dcards.discount
            .
            if last-of (buf1_dcards.grp-code) then
            do:
                create buf2_dcards.
                assign
                    buf2_dcards.grp-code =
                        (if buf1_dcards.grp-lvl = 0 then buf1_dcards.grp-code
                         else v-upper-code)
                    buf2_dcards.doc-qnty = v-doc-qnty
                    buf2_dcards.sum = v-sum-withoutdisc
                    buf2_dcards.sum-withdisc = v-sum-withdisc
                    buf2_dcards.discount = v-discount
                    buf2_dcards.grp-lvl = buf1_dcards.grp-lvl + 1
                    buf2_dcards.obj-type = p-obj-type
                    buf2_dcards.obj-code = p-obj-code
                    buf2_dcards.d-card = p-d-card
                .
            end.
        end.
        v-cur-lvl = v-cur-lvl + 1.
    end.
end procedure.
procedure my-watch-table:
    define variable v-full-file-name as character no-undo.
    define variable v-message as character no-undo.
    define variable v-table-handle as handle no-undo.
    define variable v-cnt-field as integer no-undo.
    define variable v-list-field-name as character no-undo.
    define variable v-list-field-label as character no-undo.
    define variable v-list-field-type as character no-undo.
    define buffer dcards for dcards.
    v-table-handle = buffer dcards:handle.
    v-cnt-field = v-table-handle:num-fields.
    do v-ii = 1 to v-cnt-field:
        v-list-field-name =
            (if v-list-field-name <> "" then
               v-list-field-name + "$" + v-table-handle:buffer-field(v-ii):name
            else
                v-table-handle:buffer-field(v-ii):name).
        v-list-field-label =
            (if v-list-field-label <> "" then
               v-list-field-label + "$" + v-table-handle:buffer-field(v-ii):label
            else
                v-table-handle:buffer-field(v-ii):label).
        v-list-field-type =
            (if v-list-field-type <> "" then
               v-list-field-type + "$" + v-table-handle:buffer-field(v-ii):data-type
            else
                v-table-handle:buffer-field(v-ii):data-type).
    end.
    v-full-file-name = "C:\work15_0\my-watch-dcards.txt".
    if search(v-full-file-name) = ? then
        do:
            message "Не найден файл отчёта: " v-full-file-name view-as alert-box error.
        end.
    output stream MyWatch-strm to value(v-full-file-name)   convert target "utf-8".
        put stream MyWatch-strm unformatted
            today format "99.99.9999" " " string(time, "HH:MM") " " "Исследуемая таблица: " "dcards" "." skip
            v-list-field-label skip
            v-list-field-name skip
            v-list-field-type skip
        .
        if not can-find(first dcards) then
        do:
            v-message = "Исследуемая таблица dcards пуста!".
            put stream MyWatch-strm unformatted
                v-message
            .
            message "My-watch-table: " v-message view-as alert-box information.
        end.
            for each  dcards no-lock:
                export stream MyWatch-strm delimiter "$"  dcards.
            end.
    output stream MyWatch-strm close.
end procedure.
procedure watch_dc-list:
    define variable v-full-file-name as character no-undo.
    define variable v-message as character no-undo.
    define variable v-table-handle as handle no-undo.
    define variable v-cnt-field as integer no-undo.
    define variable v-list-field-name as character no-undo.
    define variable v-list-field-label as character no-undo.
    define variable v-list-field-type as character no-undo.
    define buffer dc-list for dc-list.
    do:
        v-table-handle = buffer dc-list:handle.
        v-cnt-field = v-table-handle:num-fields.
        do v-ii = 1 to v-cnt-field:
            v-list-field-name =
                (if v-list-field-name <> "" then
                   v-list-field-name + "$" + v-table-handle:buffer-field(v-ii):name
                else
                    v-table-handle:buffer-field(v-ii):name).
            v-list-field-label =
                (if v-list-field-label <> "" then
                   v-list-field-label + "$" + v-table-handle:buffer-field(v-ii):label
                else
                    v-table-handle:buffer-field(v-ii):label).
            v-list-field-type =
                (if v-list-field-type <> "" then
                   v-list-field-type + "$" + v-table-handle:buffer-field(v-ii):data-type
                else
                    v-table-handle:buffer-field(v-ii):data-type).
        end.
    end.
    v-full-file-name = "C:\work15_0\my-watch_dc-list.txt".
    if search(v-full-file-name) = ? then
        do:
            message "Не найден файл отчёта: " v-full-file-name view-as alert-box error.
        end.
    output stream MyWatch-strm to value(v-full-file-name)   convert target "utf-8".
        put stream MyWatch-strm unformatted
            today format "99.99.9999" " " string(time, "HH:MM") " " "Исследуемая таблица: " "dc-list" "." skip
            v-list-field-label skip
            v-list-field-name skip
            v-list-field-type skip
        .
        if not can-find(first dc-list) then
        do:
            v-message = "Исследуемая таблица dc-list пуста!".
            put stream MyWatch-strm unformatted
                v-message
            .
            message "My-watch-table: " v-message view-as alert-box information.
        end.
            for each  dc-list no-lock:
                export stream MyWatch-strm delimiter "$"  dc-list.
            end.
    output stream MyWatch-strm close.
end procedure.
procedure old-code:
    for each dcards where (UpLevel = 0 or dcards.sum >= UpLevel)
    ,
    first dis-card no-lock where dis-card.d-card = dcards.d-card
    break
        by dcards.cli-type-code
        by dcards.card-num-chr
        by dcards.d-card
        by dcards.chk-date
    :
        if (not t-legacy and not t-subsid)
            or first-of (dcards.cli-type-code) then
        do:
            find first buf2_clients no-lock where
                       buf2_clients.obj-type = dis-card.cli-type
                   and buf2_clients.obj-code = dis-card.cli-code no-error
            .
            if available buf2_clients then
            do:
                assign
                    v-cli-name = buf2_clients.obj-name
                    v-cli-type-code = dis-card.cli-type + string(dis-card.cli-code)
                .
            end.
            else
            do:
                assign
                    v-cli-name = dis-card.cli-type + string(dis-card.cli-code)
                    v-cli-type-code = dis-card.cli-type + string(dis-card.cli-code)
                .
            end.
        end.
        if first-of (dcards.cli-type-code) then
        do:
            assign
                accum-counter-cli       = 0
                accum-qnty-cli          = 0
                accum-sum-cli           = 0
                accum-discount-cli      = 0
                accum-netto-cli         = 0
                only-one-card-per-cli   = 0
            .
        end.
        if first-of(dcards.card-num-chr) then
        do:
            assign
                accum-counter-leg       = 0
                accum-qnty-leg          = 0
                accum-sum-leg           = 0
                accum-discount-leg      = 0
                accum-netto-leg         = 0
                only-one-card-per-leg   = 0
            .
        end.
        if first-of(dcards.d-card) then
        do:
            assign
                accum-counter-crd       = 0
                accum-qnty-crd          = 0
                accum-sum-crd           = 0
                accum-discount-crd      = 0
                accum-netto-crd         = 0
            .
        end.
        assign
            accum-counter         = accum-counter      + dcards.counter
            accum-qnty            = accum-qnty         + dcards.doc-qnty
            accum-sum             = accum-sum          + dcards.sum
            accum-discount        = accum-discount     + dcards.discount
            accum-netto           = accum-netto        + dcards.sum - dcards.discount
            accum-counter-cli     = accum-counter-cli  + dcards.counter
            accum-qnty-cli        = accum-qnty-cli     + dcards.doc-qnty
            accum-sum-cli         = accum-sum-cli      + dcards.sum
            accum-discount-cli    = accum-discount-cli + dcards.discount
            accum-netto-cli       = accum-netto-cli    + dcards.sum - dcards.discount
            accum-counter-leg     = accum-counter-leg  + dcards.counter
            accum-qnty-leg        = accum-qnty-leg     + dcards.doc-qnty
            accum-sum-leg         = accum-sum-leg      + dcards.sum
            accum-discount-leg    = accum-discount-leg + dcards.discount
            accum-netto-leg       = accum-netto-leg    + dcards.sum - dcards.discount
            accum-counter-crd     = accum-counter-crd  + dcards.counter
            accum-qnty-crd        = accum-qnty-crd     + dcards.doc-qnty
            accum-sum-crd         = accum-sum-crd      + dcards.sum
            accum-discount-crd    = accum-discount-crd + dcards.discount
            accum-netto-crd       = accum-netto-crd    + dcards.sum - dcards.discount
        .
        if t-legacy or t-subsid then
        do:
            if only-one-card-per-leg = 0 then
            do:
                only-one-card-per-leg = 1.
            end.
            else
            do:
                only-one-card-per-leg = 2.
            end.
            if first-of(dcards.card-num-chr) then
            do:
                assign
                    v-show-d-card = dcards.card-num-chr
                .
            end.
        end.
        if first-of(dcards.d-card) then
        do:
            if first(dcards.d-card) then
            do:
                down stream PrnLibStream 1 with frame X123.
            end.
            only-one-card-per-cli = only-one-card-per-cli + 1.
            for-d-pcnt = get-d-pcnt(
                                     buffer dis-card
                                    ,input v-cntxt-host-code-obj
                                    ,input v-cntxt-obj-type
                                    ,input v-cntxt-obj-code
                                    ,input 'def-pcnt':U
                                    ,output loc-d-pcnt
                                    ).
            put stream PrnLibStream space(10)
                substitute ("№ карты: &1 &2 / &3 (&4) / Процент скидки: &5"
                            ,(if t-legacy or t-subsid then ("~{" + v-show-d-card + "~}") else "":U)
                            ,trim(dcards.d-card)
                            ,trim(v-cli-name)
                            ,(if t-legacy or t-subsid then dcards.cli-type-code else v-cli-type-code)
                            ,for-d-pcnt) format "x(100)" skip
                .
            underline stream PrnLibStream
                dcards.chk-date
                dcards.artic
                buf3_clients.obj-name
                goods.gds-name
                dcards.b-code
                dcards.sale-price
                dcards.doc-qnty
                dcards.sum
                dcards.discount
                v-for-netto
            with frame X123.
            do:
                if dcards.b-code <> 0 then
                do:
                    find first buf3_clients where buf3_clients.obj-type = dcards.prod-type and
                               buf3_clients.obj-code = dcards.prod-code no-lock
                    .
                    find first ub.goods where
                               ub.goods.artic = dcards.artic and
                               ub.goods.prod-type = dcards.prod-type and
                               ub.goods.prod-code = dcards.prod-code no-lock
                    .
                    find first ub.gds-prt where
                               ub.gds-prt.node-code = dcards.node-code no-lock no-error
                    .
                    if available ub.gds-prt and
                        not ub.gds-prt.node-name = '_Пустая шкала':U then
                    do:
                        for-name = string(ub.goods.gds-name, "X(25)") + "\" + ub.gds-prt.node-name.
                    end.
                    else
                    do:
                        for-name = ub.goods.gds-name.
                    end.
                    namebuf1 = breakstr(for-name, 25, input-output namebuf1, input-output namebuf2).
                    display stream PrnLibStream
                        sym1
                        dcards.chk-date
                        dcards.artic
                        dcards.b-code
                        buf3_clients.obj-name
                        namebuf1 @ ub.goods.gds-name
                        dcards.sale-price
                        dcards.doc-qnty
                        dcards.sum
                        dcards.discount
                        (dcards.sum - dcards.discount) @ v-for-netto
                        sym2
                    with frame X123.
                    down stream PrnLibStream 1 with frame X123.
                    if namebuf2 <> "" then
                    do:
                        display stream PrnLibStream
                            sym1
                             namebuf2 @ goods.gds-name
                            sym2
                            with frame X123
                        .
                        down stream PrnLibStream 1 with frame X123.
                    end.
                end.
                else
                do:
                    if dcards.artic > "" then
                    do:
                        display stream PrnLibStream
                            sym1
                            dcards.chk-date
                            dcards.artic
                            (if dcards.artic = 'СТ' then "Сопутствующие товары" else '') @ ub.goods.gds-name
                            dcards.sum
                            dcards.discount
                            (dcards.sum - dcards.discount) @ v-for-netto
                            sym2
                        with frame X123.
                        down stream PrnLibStream 1 with frame X123.
                    end.
                end.
            end.
            do:
            end.
        end.
        if last-of(dcards.d-card) then
        do:
            do:
                underline stream PrnLibStream
                    dcards.chk-date
                    dcards.artic
                    dcards.b-code
                    buf3_clients.obj-name
                    goods.gds-name
                    dcards.sale-price
                    dcards.doc-qnty
                    dcards.sum
                    dcards.discount
                    v-for-netto
                    with frame X123
                .
            end.
            display stream PrnLibStream
                sym1
                "Итого" @ dcards.chk-date
                "по карте" @ dcards.artic
                ("чеков: " + string(accum-counter-crd)) @ buf3_clients.obj-name
                dcards.d-card @ goods.gds-name
                ACCUM-sum-crd @ dcards.sum
                ACCUM-discount-crd @ dcards.discount
                ACCUM-netto-crd @ v-for-netto
                sym2
            with frame X123.
            do:
                display stream PrnLibStream
                    (ACCUM-qnty-crd) @ dcards.doc-qnty
                with frame X123.
            end.
            underline stream PrnLibStream
                dcards.chk-date
                dcards.artic
                dcards.b-code
                buf3_clients.obj-name
                goods.gds-name
                dcards.sale-price
                dcards.doc-qnty
                dcards.sum
                dcards.discount
                v-for-netto
            with frame X123.
        end.
        if t-legacy or t-subsid then
        do:
            if last-of(dcards.card-num-chr) then
            do:
            end.
            if last-of(dcards.card-num-chr) and only-one-card-per-leg = 2 then
            do:
                do:
                    underline stream PrnLibStream
                        dcards.chk-date
                        dcards.artic
                        dcards.b-code
                        buf3_clients.obj-name
                        goods.gds-name
                        dcards.sale-price
                        dcards.doc-qnty
                        dcards.sum
                        dcards.discount
                        v-for-netto
                    with frame X123.
                end.
                display stream PrnLibStream
                    sym1
                    "Итого" @ dcards.chk-date
                    substitute("~{&1~}", substring(v-show-d-card, 1, 14)) @  dcards.artic
                    ("чеков: " + string(ACCUM-counter-leg)) @ buf3_clients.obj-name
                    (trim( v-cli-name ) +
                    " (" +
                    (if t-legacy or t-subsid then dcards.cli-type-code else v-cli-type-code) +
                    " )" ) @ goods.gds-name
                    ACCUM-sum-leg  @ dcards.sum
                    ACCUM-discount-leg @ dcards.discount
                    ACCUM-netto-leg @ v-for-netto
                    sym2
                with frame X123.
                do:
                    display stream PrnLibStream
                        (ACCUM-qnty-leg) @ dcards.doc-qnty
                    with frame X123.
                end.
                underline stream PrnLibStream
                    dcards.chk-date
                    dcards.artic
                    dcards.b-code
                    buf3_clients.obj-name
                    goods.gds-name
                    dcards.sale-price
                    dcards.doc-qnty
                    dcards.sum
                    dcards.discount
                    v-for-netto
                with frame X123.
            end.
        end.
        if last-of(dcards.cli-type-code) and only-one-card-per-cli > 1 then
        do:
            do:
                underline stream PrnLibStream
                    dcards.chk-date
                    dcards.artic
                    dcards.b-code
                    buf3_clients.obj-name
                    goods.gds-name
                    dcards.sale-price
                    dcards.doc-qnty
                    dcards.sum
                    dcards.discount
                    v-for-netto
                with frame X123.
            end.
            display stream PrnLibStream
                sym1
                "Итого" @ dcards.chk-date
                "по клиенту"  @  dcards.artic
                ("чеков: " + string(ACCUM-counter-cli)) @ buf3_clients.obj-name
                (trim(v-cli-name) +
                " (" +
                (if t-legacy or t-subsid then dcards.cli-type-code else v-cli-type-code) +
                " )") @ goods.gds-name
                ACCUM-sum-cli  @ dcards.sum
                ACCUM-discount-cli @ dcards.discount
                ACCUM-netto-cli @ v-for-netto
                sym2
            with frame X123.
            do:
                display stream PrnLibStream
                    (ACCUM-qnty-cli) @ dcards.doc-qnty
                with frame X123.
            end.
            underline stream PrnLibStream
                dcards.chk-date
                dcards.artic
                dcards.b-code
                buf3_clients.obj-name
                goods.gds-name
                dcards.sale-price
                dcards.doc-qnty
                dcards.sum
                dcards.discount
                v-for-netto
            with frame X123.
        end.
        if last(dcards.d-card) and FixDCard = "" then
        do:
            display stream PrnLibStream
                sym1
                "Итого" @ dcards.chk-date
                "по ВСЕМ" @ dcards.artic
                ("чеков: " + string(ACCUM-counter)) @ buf3_clients.obj-name
                ACCUM-sum @ dcards.sum
                ACCUM-discount @ dcards.discount
                ACCUM-netto @ v-for-netto
                sym2
            with frame X123.
            do:
                display stream PrnLibStream
                    (ACCUM-qnty) @ dcards.doc-qnty
                with frame X123.
            end.
            underline stream PrnLibStream
                dcards.chk-date
                dcards.artic
                dcards.b-code
                buf3_clients.obj-name
                goods.gds-name
                dcards.sale-price
                dcards.doc-qnty
                dcards.sum
                dcards.discount
                v-for-netto
            with frame X123.
        end.
    end.
end procedure.
procedure new-code:
    for each dcards where (UpLevel = 0 or dcards.sum >= UpLevel)
    ,
    first dis-card no-lock where dis-card.d-card = dcards.d-card
    break by dcards.cli-type-code
          by dcards.card-num-chr
          by dcards.d-card
          by dcards.chk-date
    :
        if (not t-legacy and not t-subsid)
            or first-of (dcards.cli-type-code) then
        do:
            find first buf2_clients no-lock where
                       buf2_clients.obj-type = dis-card.cli-type
                   and buf2_clients.obj-code = dis-card.cli-code no-error
            .
            if available buf2_clients then
            do:
                assign
                    v-cli-name = buf2_clients.obj-name
                    v-cli-type-code = dis-card.cli-type + string(dis-card.cli-code)
                .
            end.
            else
            do:
                assign
                    v-cli-name = dis-card.cli-type + string(dis-card.cli-code)
                    v-cli-type-code = dis-card.cli-type + string(dis-card.cli-code)
                .
            end.
        end.
        assign
            accum-counter         = accum-counter      + dcards.counter
            accum-qnty            = accum-qnty         + dcards.doc-qnty
            accum-sum             = accum-sum          + dcards.sum
            accum-discount        = accum-discount     + dcards.discount
            accum-netto           = accum-netto        + dcards.sum - dcards.discount
        .
        if t-legacy or t-subsid then
        do:
            if only-one-card-per-leg = 0 then
            do:
                only-one-card-per-leg = 1.
            end.
            else
            do:
                only-one-card-per-leg = 2.
            end.
            if first-of(dcards.card-num-chr) then
            do:
                assign
                    v-show-d-card = dcards.card-num-chr
                .
            end.
        end.
        if first-of(dcards.d-card) then
        do:
            if first(dcards.d-card) then
            do:
                down stream PrnLibStream 1 with frame X123.
            end.
            only-one-card-per-cli = only-one-card-per-cli + 1.
            for-d-pcnt = get-d-pcnt(
                                     buffer dis-card
                                    ,input v-cntxt-host-code-obj
                                    ,input v-cntxt-obj-type
                                    ,input v-cntxt-obj-code
                                    ,input 'def-pcnt':U
                                    ,output loc-d-pcnt
                                    ).
            put stream PrnLibStream space(10)
                substitute ("№ карты: &1 &2 / &3 (&4) / Процент скидки: &5"
                            ,(if t-legacy or t-subsid then ("~{" + v-show-d-card + "~}") else "":U)
                            ,trim(dcards.d-card)
                            ,trim(v-cli-name)
                            ,(if t-legacy or t-subsid then dcards.cli-type-code else v-cli-type-code)
                            ,for-d-pcnt) format "x(100)" skip
                .
        end.
    end.
end.
function fnc-convert-dot-to-colon returns character
(input p-data as decimal, input p-accur as character):
    define variable result as character no-undo.
    define variable v-str-result as character no-undo.
    if p-data = ? then
    do:
        v-str-result = "?".
    end.
    else
    do:
        p-data = round(p-data, 2).
        v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).
    end.
    return v-str-result.
end function.
function fnc-DD-MM-YYYY returns character
(input p-dat-date as date):
    define variable result as character no-undo.
    define variable p-str-date as character no-undo.
    p-str-date = replace(string(p-dat-date,'99.99.9999'), "/", ".").
        return p-str-date.
end function.
