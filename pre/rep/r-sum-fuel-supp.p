using ibs.th.str.*.
block-level on error undo, throw.
define input parameter iCntxtHostCodeObj as integer   no-undo.
define input parameter iACType           as integer   no-undo.
define input parameter iTrkErr           as integer   no-undo.
define input parameter iGdsCodeList      as character no-undo.
define input parameter iSuppsList        as character no-undo.
define input parameter iOilBaseList      as character no-undo.
define input parameter iTranTimeMax      as integer   no-undo.
define input parameter iDelta-tank-ac    as logical   no-undo.
define input parameter iDelta-tank-fact  as logical   no-undo.
define input parameter i-Itog            as logical   no-undo.
define input parameter i-NoAzkItog       as logical   no-undo.
define variable vss-revision    as character     no-undo init "$ $":U .
define variable vss-author      as character     no-undo init "$ $":U .
define variable vss-date        as character     no-undo init "$ $":U .
define variable vss-workfile    as character     no-undo init "$ $":U .
define variable vss-archive     as character     no-undo init "$ $":U .
define variable vss-description as character     no-undo init "Сводный отчёт по поставкам НП".
define variable parparentproc   as widget-handle no-undo.
define variable mParamStr       as character     no-undo extent 10.
define variable mProdBcStrList  as character     no-undo.
define variable mSuppStrList    as character     no-undo.
define variable mPrim1          as character     no-undo extent 10.
define variable mPrim2          as character     no-undo extent 10.
define variable mPrim3          as character     no-undo extent 10.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-is-this-db-code returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'u'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code no-error .
if available buf_code-range then return yes.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and  buf_code-range.stts = 'a'
      and buf_code-range.first-code <= p-code
      no-error .
 if available buf_code-range then return yes.
end.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'f'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code
    no-error .
if available buf_code-range then return yes.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-code-short returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and buf_code-range.first-code <= p-code
      and buf_code-range.last-code >= p-code no-error .
  if available buf_code-range then return yes.
end.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-role returns integer ( input p-role as character
                                                    ,input p-db-num as integer
                                                    ,input p-staff-code as integer
                                                    ,input p-date as date
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
      and buf_staff.staff-code = p-staff-code
      and buf_staff.date-end >= p-date use-index pi  no-error .
if available buf_staff then do:
  return buf_staff.psn-code.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-this-db-first-role returns integer ( input p-role as character
                                                          ,input p-db-num as integer
                                                          ,input p-date as date
                                                              ):
define buffer buf_staff for ub.staff.
define buffer buf2_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each  buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.db-num = p-db-num,
first buf2_staff no-lock where
      buf2_staff.role = p-role
  and buf2_staff.role-level = 'db':U
  and buf2_staff.staff-code = buf_staff.staff-code
  and buf2_staff.date-start <= p-date
  and buf2_staff.date-end >= p-date
by buf_staff.staff-code
by date-start descending:
  return buf_staff.staff-code.
end.
end FUNCTION.
FUNCTION gbclcode-get-db-role returns integer ( input p-role as character
                                               ,input p-db-num as integer
                                               ,input p-psn-code as integer
                                               ,input p-date as date
                                               ,output p-c-password as character
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
     and buf_staff.date-end >= p-date
     and buf_staff.psn-code = p-psn-code use-index irole-psn no-error .
if available buf_staff
then do:
  assign
  p-c-password = buf_staff.password.
  return buf_staff.staff-code.
end.
p-c-password = ''.
return 0.
end FUNCTION.
FUNCTION gbclcode-is-psn-role returns integer (
                                              input p-role as character
                                              ,input p-psn-code as integer
                                              ,input p-date as date
                                                  ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each buf_staff no-lock where
          buf_staff.psn-code = p-psn-code
     and  buf_staff.role = p-role
by buf_staff.role-level
by buf_staff.date-start
     :
  if  buf_staff.date-start <= p-date and
  buf_staff.date-end >= p-date  then do:
    return buf_staff.staff-code.
  end.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-role-name returns character ( input p-role as character):
define variable v-role-name as character no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
no-error .
return v-role-name.
END.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-get-position returns character ( input p-role as character
                                                  ,input p-role-level as character
                                                  ,input p-work-place as character
                                                  ,input p-staff-code as integer
                                                             ):
define variable v-role-name as character no-undo .
define variable v-role-level as character no-undo .
define variable v-staff-code as integer no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
v-role-level = substitute("&1 &2", entry (lookup (p-role-level, 'global,db,firm,object':U) + 1, ',':U + 'Глобально,БД,Фирма,Объект':U) , p-work-place)
v-staff-code = p-staff-code
no-error .
return substitute("&1, &2, Код &3"
                ,v-role-name
                ,v-role-level
                ,(if p-staff-code = 0 then chr(63) else string(p-staff-code))).
END.
FUNCTION gbclcode-get-work-place returns character (
                                                input p-role as character
                                               ,input p-role-level as character
                                               ,input p-db-num as integer
                                               ,input p-host-code as integer
                                               ,input p-obj-type as character
                                               ,input p-obj-code as integer
                                               ) :
define variable v-work-place as character no-undo .
define variable v-obj-type as character no-undo .
  case p-role-level:
    when 'db':U then do:
      v-work-place = string(p-db-num, "99999").
    end.
    when 'firm':U then do:
      v-work-place = string(p-host-code, "99999").
    end.
    when 'object':U then do:
      assign
      v-work-place = p-obj-type + string(p-obj-code, "999999999")
      .
    end.
  END CASE.
  return v-work-place.
END FUNCTION.
FUNCTION gbclcode-get-level-last-code returns integer (
                                                        input p-role as character
                                                      , input p-role-level as character
                                                      , input p-work-place as character
                                                      , input p-date-start as date
                                                      ):
DEFINE VARIABLE v-today as date no-undo .
define buffer buf_staff for ub.staff.
if p-work-place = chr(63) then return ?.
if p-date-start = ? then do:
  v-today = today .
end.
else do:
  v-today = p-date-start.
end.
find last buf_staff no-lock where
          buf_staff.role = p-role
     and  buf_staff.role-level = p-role-level
     and  buf_staff.work-place = p-work-place
     and  buf_staff.date-start <= v-today + 1
     and  buf_staff.date-end >= v-today + 1
     use-index pi  no-error .
if available buf_staff
then return buf_staff.staff-code.
return 0.
end FUNCTION.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared stream PrnLibStream.
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  p-user-id
  ,output v-user-name
  ) no-error .
if error-status:error
or v-user-name = ""
then do:
  return p-user-id.
end.
else do:
  return v-user-name.
end.
end function.
define temp-table tt-rep no-undo
  field col1  as character
  field obj-type as character
  field obj-code as integer
  field col2  as character
  field shift-date as date
  field shift-num as integer
  field col3  as character
  field col4  as character
  field col5  as character
  field col6  as character
  field col7  as character
  field min-pour as integer
  field col8  as character
  field col9  as character
  field col10  as character
  field col11 as character
  field col12 as character
  field col13 as character
  field col14 as character
  field col15 as character
  field col16 as character
  field gds-code as integer
  field col17 as character
  field col18 as character
  field col19 as character
  field col20 as decimal
  field col20str as character
  field col21 as decimal
  field col21str as character
  field col22 as decimal
  field col22str as character
  field col23 as decimal
  field col23str as character
  field col24 as decimal
  field col24str as character
  field col25 as decimal
  field col25str as character
  field col26 as decimal
  field col26str as character
  field col27 as decimal
  field col27str as character
  field col28 as decimal
  field col28str as character
  field col29 as decimal
  field col29str as character
  field col30 as decimal
  field col30str as character
  field col31 as decimal
  field col31str as character
  field col32 as decimal
  field col32str as character
  field col33 as decimal
  field col34 as decimal
  field col35 as character
  field col36 as decimal
  field col36str as character
  field col37 as decimal
  field col37str as character
  field col38 as decimal
  field col38str as character
  field col39 as decimal
  field col39str as character
  field col40 as decimal
  field col41 as decimal
  field col42 as decimal decimals 1
  field col43 as decimal decimals 2
  field col44 as decimal decimals 1
  field col45 as decimal decimals 2
  field col46 as decimal decimals 1
  field col47 as decimal decimals 2
  field col48 as decimal decimals 1
  field col49 as decimal decimals 1
  field col50 as character
  field col51 as character
  field delta-mass-qnty-ac as decimal
  field delta-mass-qnty-before as decimal
  field delta-mass-qnty-after as decimal
  field no-itog         as logical
  field ac-measured     as logical
  index pi as primary
    obj-code
    shift-date shift-num
    gds-code
    col3
    col17
.
define temp-table tt-itog no-undo
  field col1  as character
  field obj-type as character
  field obj-code as integer
  field col20 as decimal
  field col21 as decimal
  field col24 as decimal
  field col25 as decimal
  field col26 as decimal
  field col29 as decimal
  field col30 as decimal
  field col33 as decimal
  field col34 as decimal
  field col36 as decimal
  field col37 as decimal
  field col40 as decimal
  field col41 as decimal
  field col42 as decimal
  field col43 as decimal
  field col43red as logical
  field col44 as decimal
  field col45 as decimal
  field col45red as logical
  field col46 as decimal
  field col47 as decimal
  field col47red as logical
  field col48 as decimal
  field col49 as decimal
  index pi as primary
    obj-code
.
define temp-table tt-all-itog no-undo
  field col1  as character
  field obj-type as character
  field obj-code as integer
  field col20 as decimal
  field col21 as decimal
  field col24 as decimal
  field col25 as decimal
  field col26 as decimal
  field col29 as decimal
  field col30 as decimal
  field col33 as decimal
  field col34 as decimal
  field col36 as decimal
  field col37 as decimal
  field col40 as decimal
  field col41 as decimal
  field col42 as decimal
  field col43 as decimal
  field col43red as logical
  field col44 as decimal
  field col45 as decimal
  field col45red as logical
  field col46 as decimal
  field col47 as decimal
  field col47red as logical
  field col48 as decimal
  field col49 as decimal
  index pi as primary
    obj-code
.
define temp-table tt-rvs-line-pump-delta no-undo like ub.rvs-line-pump
  field deltaVol as decimal
  field is-err as logical
  field find-pair as logical
.
define stream sOutStr-html.
function f_disp_time returns character
   (input iTime as integer):
   define variable vHour    as integer   no-undo.
   define variable vMinute  as integer   no-undo.
   define variable vSec     as integer   no-undo.
   define variable vTimeStr as character no-undo.
   if iTime < 0 then return "".
   vHour = truncate(iTime / 3600, 0).
   vMinute = truncate((iTime - vHour * 3600) / 60, 0).
   vSec = iTime - vHour * 3600 - vMinute * 60.
   vTimeStr = trim(string(vHour, ">>>99")) + ":" +
              string(vMinute, "99")  + ":" +
              string(vSec,    "99").
   return vTimeStr.
end function.
function fDate2Str returns character
   (input idate as date,
    input iformat as char):
   define variable vdatestr as character no-undo.
   if idate = ? then
      vdatestr = "".
   else
      vdatestr = trim(string(idate, iformat)).
   return vdatestr.
end function.
function fDec2Str returns character
   (input idec as decimal,
    input iformat as char):
   define variable vdecstr as character no-undo.
   if idec = ? then
      vdecstr = "".
   else
      vdecstr = trim(string(idec, iformat)).
   return vdecstr.
end function.
function fInt2Str returns character
   (input iInt as integer,
    input iformat as char):
   define variable vIntStr as character no-undo.
   if iInt = ? then
      vIntStr = "".
   else
      vIntStr = trim(string(iInt, iformat)).
   return vIntStr.
end function.
function fStrNvl returns character
   (input iStr     as character,
    input iDefault as character):
   return if iStr > "" then iStr else iDefault.
end function.
run BeforeCalc .
run initTT .
run calc-itog .
run PrintTT .
procedure BeforeCalc:
   define variable vI       as integer   no-undo.
   define variable vJ       as integer   no-undo.
   define variable vStr     as character no-undo.
   define variable vChkCode as character no-undo.
   if x-tog-shift then do:
     vI = vI + 1.
     mParamStr[vI] = "По сменам: c " + string(X-shift-start) + " по " + string(X-shift-end).
   end.
   vI = vI + 1.
   if X-date-start = X-date-end then
     mParamStr[vI] = "За дату : " + string(X-date-start, "99.99.9999").
   else
     mParamStr[vI] = "За период c " + string(X-date-start, "99.99.9999") + " по " + string(X-date-end, "99.99.9999").
   vI = vI + 1.
   mParamStr[vI] = "Выбор объекта: ".
   for each obj-list:
     mParamStr[vI] = mParamStr[vI] + obj-list.obj-name + "," .
   end.
   mParamStr[vI] = trim(mParamStr[vI], ",").
   vI = vI + 1.
   if iGdsCodeList = "*" then do:
     mParamStr[vI] = "Вся номенклатура".
     mProdBcStrList = "*".
   end.
   else do:
     mParamStr[vI] = "Номенклатура: ".
     vStr = "".
     for each goods where
               can-do(iGdsCodeList, string(goods.gds-code))
     no-lock:
       vStr = vStr + "," + string(goods.gds-code) + "(" + goods.gds-name + ")".
       for each prod-bc where
                prod-bc.b-code = goods.gds-code
       no-lock:
         mProdBcStrList = mProdBcStrList + "," + prod-bc.b-str.
       end.
     end.
     vStr = trim(vStr, ",").
     mProdBcStrList = trim(mProdBcStrList, ",").
     mParamStr[vI] = mParamStr[vI] + vStr.
   end.
   vI = vI + 1.
   if iSuppsList = "*" then do:
     mParamStr[vI] = "Все поставщики".
     mSuppStrList = "*".
   end.
   else do:
     mParamStr[vI] = "Поставщики: ".
     vStr = "".
     for each clients where can-do(iSuppsList, string(clients.obj-code))
                        and clients.obj-type = "орг"
     no-lock:
       vStr = vStr + ", Орг" + string(clients.obj-code) + " " + clients.obj-name + "".
     end.
     vStr = trim(vStr, ", ").
     mParamStr[vI] = mParamStr[vI] + vStr.
   end.
   if iTranTimeMax > 0
   then do:
     vI = vI + 1.
     mParamStr[vI] = "Только со временем слива секции НП более " + string(iTranTimeMax) + " минут".
   end.
   if iDelta-tank-ac
   and iDelta-tank-fact
   then do :
     vI = vI + 1.
     mParamStr[vI] = "Только со сверхнормативным расхождением между резервуаром и АЦ, либо между резервуаром и принятым НП".
   end.
   else
   if iDelta-tank-ac
   then do :
     vI = vI + 1.
     mParamStr[vI] = "Только со сверхнормативным расхождением между резервуаром и АЦ".
   end.
   else
   if iDelta-tank-fact
   then do :
     vI = vI + 1.
     mParamStr[vI] = "Только со сверхнормативным расхождением между резервуаром и принятым НП".
   end.
   vI = vI + 1.
   if i-Itog
   then do :
     mParamStr[vI] = "Только итоги".
   end .
   else do :
     mParamStr[vI] = "В т.ч. итоги".
   end .
   vI = vI + 1.
   mPrim1[1] = "Объем в ИТОГО: отображается в виде справочной информации." .
   mPrim1[2] = "<u>Расчет отклонения АЦ к ТТН</u> " + fill("&nbsp;" , 11) + " <u>Расчет отклонения резервуара к АЦ</u>" .
   mPrim1[3] = "Масса = (1.25-1.21)      " + fill("&nbsp;" , 28) + "Масса = ((1.37+1.34)-1.30)-1.25" .
   mPrim1[4] = "% = (1.42/1.21*100)      " + fill("&nbsp;" , 28) + "% = (1.44/1.25*100)" .
   mPrim1[5] = "<u>Расчет отклонения между резервуаром и принятым к учету топливом</u>" .
   mPrim1[6] = "Масса = ((1.37+1.34)-1.30)-1.41" .
   mPrim1[7] = "% = (1.46/1.41*100)" .
   mPrim2[1] = "Расчет сверхнормативного расхождения между резервуаром и АЦ" .
   mPrim2[2] = "Если 1.44 < 0 1.44+Корень((1.37*Пр)^2+(1.30*Пр)^2+(1.34*Птрк)^2+(1.25*Пац)^2)/100" .
   mPrim2[3] = "Если 1.44 > 0 1.44-Корень((1.37*Пр)^2+(1.30*Пр)^2+(1.34*Птрк)^2+(1.25*Пац)^2)/100" .
   mPrim2[4] = "Пр - относительная погрешность измерения массы нефтепродукта в резервуаре (в сверках)" .
   mPrim2[5] = "Пац - погрешность измерения массы в АЦ" .
   mPrim2[6] = "Результат расчета округляется до десятых." .
   mPrim2[7] = "Птрк - погрешность ТРК, равная 0,5%" .
   mPrim3[1] = "Расчет сверхнормативного расхождения между резервуаром и принятым к учету топливом" .
   mPrim3[2] = "Если 1.46 < 0 1.46+Корень((1.37*Пр)^2+(1.34*Птрк)^2+(1.30*Пр)^2)/100" .
   mPrim3[3] = "Если 1.46 > 0 1.46-Корень((1.37*Пр)^2+(1.34*Птрк)^2+(1.30*Пр)^2)/100" .
   mPrim3[4] = "Пр - относительная погрешность измерения массы нефтепродукта в резервуаре (в сверках)" .
   mPrim3[5] = "Результат расчета округляется до десятых." .
   mPrim3[6] = "Птрк - погрешность ТРК, равная 0,5%" .
end procedure.
procedure initTT :
  define buffer buf_trn-doc       for ub.trn-doc .
  for each obj-list :
    if x-TOG-Shift
    then do :
      for each buf_trn-doc no-lock where buf_trn-doc.obj-type     = obj-list.obj-type
                                     and buf_trn-doc.obj-code     = obj-list.obj-code
                                     and buf_trn-doc.ext-doc-type = 'ie':U
                                     and buf_trn-doc.status_      = 'факт':U
                                     and can-do(iSuppsList, string(buf_trn-doc.cli-code))
                                     and (buf_trn-doc.shift-date > X-date-Start or (buf_trn-doc.shift-date = X-date-Start and buf_trn-doc.shift-num >= x-Shift-Start))
                                     and (buf_trn-doc.shift-date < X-date-End or (buf_trn-doc.shift-date = X-date-End and buf_trn-doc.shift-num <= x-Shift-End))
      :
        run processTrn(input buf_trn-doc.doc-code) .
      end .
    end .
    else do :
      for each buf_trn-doc no-lock where buf_trn-doc.obj-type     = obj-list.obj-type
                                     and buf_trn-doc.obj-code     = obj-list.obj-code
                                     and buf_trn-doc.ext-doc-type = 'ie':U
                                     and buf_trn-doc.status_      = 'факт':U
                                     and can-do(iSuppsList, string(buf_trn-doc.cli-code))
                                     and buf_trn-doc.fact-date >= X-date-Start
                                     and buf_trn-doc.fact-date <= X-date-End
      :
        run processTrn(input buf_trn-doc.doc-code) .
      end .
    end .
  end .
end procedure .
procedure processTrn :
  define input parameter p-doc-code as character no-undo .
  define buffer buf_tt-rep for tt-rep .
  define buffer buf_trn-doc       for ub.trn-doc .
  define buffer buf_goods         for ub.goods .
  define buffer buf_doc-line      for ub.doc-line .
  define buffer buf_rvs-doc       for ub.rvs-doc .
  define buffer buf_rvs-line      for ub.rvs-line .
  define buffer buf_rvs-line-attr for ub.rvs-line-attr .
  define buffer buf_clients       for ub.clients .
  define buffer buf_place         for ub.place .
  define buffer buf_doc-pl        for ub.doc-pl .
  define buffer sep_auto-tank-attr  for ub.auto-tank-attr .
  define buffer buf_rvs-line-pump for ub.rvs-line-pump .
  define buffer buf_c-place-attr  for ub.c-place-attr .
  define buffer buf2_c-place-attr for ub.c-place-attr .
  define buffer buf_pl-gds-pump   for ub.pl-gds-pump .
  define buffer buf_c-pl-gds-pump for ub.c-pl-gds-pump .
  define buffer buf2_c-pl-gds-pump for ub.c-pl-gds-pump .
  define variable v-ok                  as logical   no-undo.
  define variable is-petrolium          as logical   no-undo.
  define variable is-pieces             as logical   no-undo.
  define variable v-isKPrvs             as logical   no-undo.
  define variable v-InfoSectionsTotal   as class     InfoSectionsTotal no-undo .
  define variable v-InfoSection         as class     InfoSection no-undo .
  define variable iNum                  as integer   no-undo .
  define variable varvalue              as character no-undo .
  define variable vartype               as character no-undo .
  define variable is-ptrl-trn           as logical   no-undo .
  define variable is-sug-trn            as logical   no-undo .
  define variable is-com-tanks          as logical   no-undo .
  define variable v-num-com-tanks       as integer   no-undo .
  define variable v-is-sug-gds          as logical   no-undo .
  define variable v-nids                as character no-undo .
  define variable v-cli-name            as character no-undo .
  define variable v-auto-cli-name       as character no-undo .
  define variable v-nb-cli-name         as character no-undo .
  define variable v-user-name           as character no-undo .
  define variable v-car-num             as character no-undo .
  define variable v-driver-name         as character no-undo .
  define variable v-sep                 as character no-undo init "" .
  define variable v-place-num           as character no-undo .
  define variable v-hour-pour           as integer   no-undo .
  define variable v-min-pour            as integer   no-undo .
  define variable v-hour-start          as integer   no-undo .
  define variable v-min-start           as integer   no-undo .
  define variable v-hour-end            as integer   no-undo .
  define variable v-min-end             as integer   no-undo .
  define variable v-date-start          as date      no-undo .
  define variable v-date-end            as date      no-undo .
  define variable v-time-start          as integer   no-undo .
  define variable v-time-end            as integer   no-undo .
  define variable v-SectionName         as character no-undo .
  define variable v-delta-ac            as decimal   no-undo .
  define variable v-delta-fact          as decimal   no-undo .
  define variable v-delta-mass-qnty-ac  as decimal   no-undo .
  define variable v-avrg-dens           as decimal   no-undo .
  define variable v-tmp-time            as integer   no-undo .
  define variable v-pl-gds-pump-status_ as character no-undo .
  is-ptrl-trn = no .
  is-sug-trn = no .
  varvalue = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'is-fuel':U ,
                       output varvalue ,
                       output vartype ) no-error .
  if varvalue = "yes"
  then do:
    is-ptrl-trn = yes .
  end.
  if not is-ptrl-trn
  then do :
    varvalue = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'is-lgas':U ,
                       output varvalue ,
                       output vartype ) no-error .
    if varvalue = "yes"
    then do:
      is-sug-trn = yes .
      is-ptrl-trn = yes .
    end.
  end .
  if not is-ptrl-trn
  then do :
    varvalue = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'is-lgas-corr':U ,
                       output varvalue ,
                       output vartype ) no-error .
    if varvalue = "yes"
    then do:
      is-sug-trn = yes .
      is-ptrl-trn = yes .
    end.
  end .
  if not is-ptrl-trn
  then do :
    return .
  end .
  find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-doc-code .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'nids':U ,
                       output v-nids ,
                       output vartype ) no-error .
  for first buf_clients no-lock where buf_clients.obj-type = buf_trn-doc.cli-type
                                  and buf_clients.obj-code = buf_trn-doc.cli-code
  :
    v-cli-name = buf_clients.obj-name .
  end .
  v-user-name = usrfulnf(buf_trn-doc.creid) .
  varvalue = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'autoent':U ,
                       output varvalue ,
                       output vartype ) no-error .
  if varvalue > ""
  and num-entries(varvalue, ";") >= 2
  then do :
    for first buf_clients no-lock where buf_clients.obj-type = entry (1, varvalue, ";")
                                    and buf_clients.obj-code = integer (entry (2, varvalue, ";"))
    :
      v-auto-cli-name = buf_clients.obj-name .
    end .
  end .
  varvalue = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'ptbobj':U ,
                       output varvalue ,
                       output vartype ) no-error .
  if varvalue > ""
  and num-entries(varvalue, ";") >= 2
  then do :
    for first buf_clients no-lock where buf_clients.obj-type = entry (1, varvalue, ";")
                                    and buf_clients.obj-code = integer (entry (2, varvalue, ";"))
    :
      if not can-do(iOilBaseList, string(buf_clients.obj-code))
      then do :
        return .
      end .
      v-nb-cli-name = buf_clients.obj-name .
    end .
  end .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'car-num':U ,
                       output v-car-num ,
                       output vartype ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'fio-driver':U ,
                       output v-driver-name ,
                       output vartype ) no-error .
  if is-sug-trn
  then do :
    varvalue = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'time-start':U ,
                       output varvalue ,
                       output vartype ) no-error .
    if varvalue > ""
    then do :
      assign
        v-hour-start = integer (entry (1, varvalue, ":"))
        v-min-start  = integer (entry (2, varvalue, ":"))
      no-error .
    end .
    varvalue = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'time-end':U ,
                       output varvalue ,
                       output vartype ) no-error .
    if varvalue > ""
    then do :
      assign
        v-hour-end = integer (entry (1, varvalue, ":"))
        v-min-end  = integer (entry (2, varvalue, ":"))
      no-error .
    end .
    varvalue = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'trdcattr-date-start':U ,
                       output varvalue ,
                       output vartype ) no-error .
    if varvalue > ""
    then do :
      v-date-start = date(varvalue) no-error .
    end .
    varvalue = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'trdcattr-date-end':U ,
                       output varvalue ,
                       output vartype ) no-error .
    if varvalue > ""
    then do :
      v-date-end = date(varvalue) no-error .
    end .
    v-hour-pour = v-hour-end - v-hour-start .
    v-min-pour = v-min-end - v-min-start .
    if v-min-pour < 0
    then do :
      v-hour-pour = v-hour-pour - 1 .
      v-min-pour = v-min-pour + 60 .
    end .
    v-hour-pour = v-hour-pour + (24 * (v-date-end - v-date-start)) .
  end .
  doc-line_ :
  for each buf_doc-line no-lock where buf_doc-line.doc-code = p-doc-code,
     first buf_goods no-lock where buf_goods.artic      = buf_doc-line.artic
                               and buf_goods.prod-type  = buf_doc-line.prod-type
                               and buf_goods.prod-code  = buf_doc-line.prod-code
                               and can-do(iGdsCodeList, string(buf_goods.gds-code))
  :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_doc-line.artic
  ,  input buf_doc-line.prod-type
  ,  input buf_doc-line.prod-code
  , output is-petrolium
  , output is-pieces
  ) no-error.
    if not is-petrolium
    then do :
      next doc-line_ .
    end .
    if is-gas(buf_goods.gds-code)
    then do :
      next doc-line_ .
    end .
    v-is-sug-gds = no .
    if is-sug(buf_goods.gds-code)
    then do :
      v-is-sug-gds = yes .
    end .
    v-InfoSectionsTotal = new InfoSectionsTotal(p-doc-code, buf_goods.gds-code, "").
    if not v-is-sug-gds
    then do :
      do iNum = 1 to v-InfoSectionsTotal:SectionNum :
        v-InfoSection = v-InfoSectionsTotal:GetInfoSectionProp(iNum) .
        v-SectionName = v-InfoSection:SectionName .
        if v-InfoSection:IsKP
        then do :
          v-infoSectionsTotal:IsKP = yes .
          find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = 'перед_док':U
                                           and buf_rvs-doc.out-code = p-doc-code
                                           and num-entries(buf_rvs-doc.rvs-code, "-") = 3
                                           and entry(2, buf_rvs-doc.rvs-code, "-") = v-SectionName
                                           no-error .
          if available buf_rvs-doc
          then do :
            v-infoSectionsTotal:IsKPrvs = yes .
          end .
        end .
        if v-sep = ""
        then do :
          if v-InfoSection:TankDensity > 0
          then do :
            if not v-InfoSection:IsKP
            then do :
              v-sep = "АЦ без СЭП" .
            end .
            else do :
              if trim(v-InfoSection:AukKey) > ""
              or v-InfoSection:alarm-SGDKK
              then do :
                v-sep = "АЦ с СЭП" .
              end .
              else do :
                v-sep = "АЦ без СЭП" .
              end .
            end .
          end .
          else do :
            if v-InfoSection:KPnoMeas
            then do :
              v-sep = "АЦ без СЭП" .
            end .
            else do :
              v-sep = "АЦ с СЭП" .
            end .
          end .
          if v-sep = "АЦ с СЭП"
          and iACType = 3
          then
            return .
          if v-sep = "АЦ без СЭП"
          and iACType = 2
          then
            return .
        end .
      end .
    end .
    do iNum = 1 to v-InfoSectionsTotal:SectionNum :
      v-InfoSection = v-InfoSectionsTotal:GetInfoSectionProp(iNum) .
      v-SectionName = if v-is-sug-gds then "1" else v-InfoSection:SectionName .
      is-com-tanks  = no .
      if v-is-sug-gds
      then do :
        for first buf_doc-pl no-lock where buf_doc-pl.obj-type = buf_doc-line.obj-type
                                       and buf_doc-pl.obj-code = buf_doc-line.obj-code
                                       and buf_doc-pl.out-code = buf_doc-line.doc-code
                                       and buf_doc-pl.gds-code = buf_goods.gds-code,
            first buf_place no-lock where buf_place.pl-code = buf_doc-pl.pl-code
        :
          find last buf_c-place-attr no-lock where buf_c-place-attr.obj-type  = buf_place.obj-type
                                               and buf_c-place-attr.obj-code  = buf_place.obj-code
                                               and buf_c-place-attr.pl-code   = buf_place.pl-code
                                               and buf_c-place-attr.attr-code = "place-twice-code"
                                               and (buf_c-place-attr.corr-date < buf_trn-doc.fact-date
                                                 or buf_c-place-attr.corr-date = buf_trn-doc.fact-date and buf_c-place-attr.corr-time < buf_trn-doc.fact-time)
                                               no-error .
          if available buf_c-place-attr
          then do :
            find first buf2_c-place-attr no-lock where buf2_c-place-attr.obj-type = buf_c-place-attr.obj-type
                                                   and buf2_c-place-attr.obj-code = buf_c-place-attr.obj-code
                                                   and buf2_c-place-attr.pl-code  = buf_c-place-attr.pl-code
                                                   and buf2_c-place-attr.attr-code = buf_c-place-attr.attr-code
                                                   and buf2_c-place-attr.chip-num > buf_c-place-attr.chip-num
                                                   no-error .
            if available buf2_c-place-attr
            then do :
              if buf2_c-place-attr.attr-value > ""
              then do :
                assign v-place-num  = buf_place.loc1 + "," + buf2_c-place-attr.attr-value .
              end .
              else do :
                assign v-place-num  = buf_place.loc1 .
              end .
            end .
            else do :
              run placelib_get-attr  ( input "place-twice-code"
                ,input buf_place.obj-code
                ,input buf_place.obj-type
                ,input buf_place.pl-code
                ,output varvalue
                ,output v-ok      ) no-error.
              if varvalue <> "" then  v-place-num  = buf_place.loc1 + "," + varvalue .
              else v-place-num  = buf_place.loc1 .
            end .
          end .
          else do :
            run placelib_get-attr  ( input "place-twice-code"
              ,input buf_place.obj-code
              ,input buf_place.obj-type
              ,input buf_place.pl-code
              ,output varvalue
              ,output v-ok      ) no-error.
            if varvalue <> "" then  v-place-num  = buf_place.loc1 + "," + varvalue .
            else v-place-num  = buf_place.loc1 .
          end .
          find last buf_c-place-attr no-lock where buf_c-place-attr.obj-type  = buf_place.obj-type
                                               and buf_c-place-attr.obj-code  = buf_place.obj-code
                                               and buf_c-place-attr.pl-code   = buf_place.pl-code
                                               and buf_c-place-attr.attr-code = "place-com-tanks"
                                               and (buf_c-place-attr.corr-date < buf_trn-doc.fact-date
                                                 or buf_c-place-attr.corr-date = buf_trn-doc.fact-date and buf_c-place-attr.corr-time < buf_trn-doc.fact-time)
                                               no-error .
          if available buf_c-place-attr
          then do :
            find first buf2_c-place-attr no-lock where buf2_c-place-attr.obj-type = buf_c-place-attr.obj-type
                                                   and buf2_c-place-attr.obj-code = buf_c-place-attr.obj-code
                                                   and buf2_c-place-attr.pl-code  = buf_c-place-attr.pl-code
                                                   and buf2_c-place-attr.attr-code = buf_c-place-attr.attr-code
                                                   and buf2_c-place-attr.chip-num > buf_c-place-attr.chip-num
                                                   no-error .
            if available buf2_c-place-attr
            then do :
              if buf2_c-place-attr.attr-value > ""
              then do :
                assign
                  is-com-tanks = yes .
                  v-num-com-tanks = 1 + num-entries(buf2_c-place-attr.attr-value) .
                  v-place-num  = buf_place.loc1 + "," + buf2_c-place-attr.attr-value
                .
              end .
            end .
            else do :
              run placelib_get-attr  ( input "place-com-tanks"
                ,input buf_place.obj-code
                ,input buf_place.obj-type
                ,input buf_place.pl-code
                ,output varvalue
                ,output v-ok      ) no-error.
              if v-ok
              and varvalue > ""
              then do :
                assign
                  is-com-tanks = yes .
                  v-num-com-tanks = 1 + num-entries(varvalue) .
                  v-place-num  = buf_place.loc1 + "," + varvalue
                .
              end .
            end .
          end .
          else do :
            run placelib_get-attr  ( input "place-com-tanks"
              ,input buf_place.obj-code
              ,input buf_place.obj-type
              ,input buf_place.pl-code
              ,output varvalue
              ,output v-ok      ) no-error.
            if v-ok
            and varvalue > ""
            then do :
              assign
                is-com-tanks = yes .
                v-num-com-tanks = 1 + num-entries(varvalue) .
                v-place-num  = buf_place.loc1 + "," + varvalue
              .
            end .
          end .
        end .
      end .
      else do :
        v-place-num = v-InfoSection:ListTank .
        pl_ :
        for each buf_place no-lock where buf_place.obj-type = buf_doc-line.obj-type
                                     and buf_place.obj-code = buf_doc-line.obj-code
                                     and buf_place.loc1     = v-place-num :
          find first buf_doc-pl no-lock where buf_doc-pl.obj-type = buf_doc-line.obj-type
                                          and buf_doc-pl.obj-code = buf_doc-line.obj-code
                                          and buf_doc-pl.out-code = buf_doc-line.doc-code
                                          and buf_doc-pl.gds-code = buf_goods.gds-code
                                          and buf_doc-pl.pl-code  = buf_place.pl-code
                                          no-error .
          if available buf_doc-pl
          then do :
            leave pl_ .
          end .
        end .
        find last buf_c-place-attr no-lock where buf_c-place-attr.obj-type  = buf_place.obj-type
                                             and buf_c-place-attr.obj-code  = buf_place.obj-code
                                             and buf_c-place-attr.pl-code   = buf_place.pl-code
                                             and buf_c-place-attr.attr-code = "place-com-tanks"
                                             and (buf_c-place-attr.corr-date < buf_trn-doc.fact-date
                                               or buf_c-place-attr.corr-date = buf_trn-doc.fact-date and buf_c-place-attr.corr-time < buf_trn-doc.fact-time)
                                             no-error .
        if available buf_c-place-attr
        then do :
          find first buf2_c-place-attr no-lock where buf2_c-place-attr.obj-type = buf_c-place-attr.obj-type
                                                 and buf2_c-place-attr.obj-code = buf_c-place-attr.obj-code
                                                 and buf2_c-place-attr.pl-code  = buf_c-place-attr.pl-code
                                                 and buf2_c-place-attr.attr-code = buf_c-place-attr.attr-code
                                                 and buf2_c-place-attr.chip-num > buf_c-place-attr.chip-num
                                                 no-error .
          if available buf2_c-place-attr
          then do :
            if buf2_c-place-attr.attr-value > ""
            then do :
              assign
                is-com-tanks = yes .
                v-num-com-tanks = 1 + num-entries(buf2_c-place-attr.attr-value) .
                v-place-num  = buf_place.loc1 + "," + buf2_c-place-attr.attr-value
              .
            end .
          end .
          else do :
            run placelib_get-attr  ( input "place-com-tanks"
              ,input buf_place.obj-code
              ,input buf_place.obj-type
              ,input buf_place.pl-code
              ,output varvalue
              ,output v-ok      ) no-error.
            if v-ok
            and varvalue > ""
            then do :
              assign
                is-com-tanks = yes .
                v-num-com-tanks = 1 + num-entries(varvalue) .
                v-place-num  = buf_place.loc1 + "," + varvalue
              .
            end .
          end .
        end .
        else do :
          run placelib_get-attr  ( input "place-com-tanks"
            ,input buf_place.obj-code
            ,input buf_place.obj-type
            ,input buf_place.pl-code
            ,output varvalue
            ,output v-ok      ) no-error.
          if v-ok
          and varvalue > ""
          then do :
            assign
              is-com-tanks = yes .
              v-num-com-tanks = 1 + num-entries(varvalue) .
              v-place-num  = buf_place.loc1 + "," + varvalue
            .
          end .
        end .
        v-date-start  = v-InfoSection:DateStart .
        v-date-end    = v-InfoSection:DateEnd .
        v-hour-start = integer( truncate( v-InfoSection:TimeStart / 3600 , 0 ) ) .
        v-min-start  = integer( truncate(( v-InfoSection:TimeStart - v-hour-start * 3600 ) / 60 , 0 )).
        v-hour-end   = integer( truncate( v-InfoSection:TimeEnd / 3600 , 0 ) ).
        v-min-end    = integer( truncate(( v-InfoSection:TimeEnd - v-hour-end * 3600 ) / 60 , 0 )).
        v-hour-pour = v-hour-end - v-hour-start .
        v-min-pour = v-min-end - v-min-start .
        if v-min-pour < 0
        then do :
          v-hour-pour = v-hour-pour - 1 .
          v-min-pour = v-min-pour + 60 .
        end .
        v-hour-pour = v-hour-pour + (24 * (v-date-end - v-date-start)) .
      end .
      if v-infoSectionsTotal:IsKPrvs
      then do :
        find first tt-rep where tt-rep.obj-type   = obj-list.obj-type
                            and tt-rep.obj-code   = obj-list.obj-code
                            and tt-rep.gds-code   = buf_goods.gds-code
                            and tt-rep.col3       = buf_trn-doc.doc-code
                            and tt-rep.col15      = v-SectionName
                            and tt-rep.col17      = v-place-num
                            no-error .
      end .
      else do :
        find first tt-rep where tt-rep.obj-type   = obj-list.obj-type
                            and tt-rep.obj-code   = obj-list.obj-code
                            and tt-rep.gds-code   = buf_goods.gds-code
                            and tt-rep.col3       = buf_trn-doc.doc-code
                            and tt-rep.col17      = v-place-num
                            no-error .
      end .
      if not available tt-rep
      then do :
        create tt-rep .
        assign
          tt-rep.obj-type   = obj-list.obj-type
          tt-rep.obj-code   = obj-list.obj-code
          tt-rep.gds-code   = buf_goods.gds-code
          tt-rep.shift-date = buf_trn-doc.shift-date
          tt-rep.shift-num  = buf_trn-doc.shift-num
          tt-rep.min-pour   = (v-hour-pour * 60) + v-min-pour
          tt-rep.col1       = obj-list.obj-name
          tt-rep.col2       = string(tt-rep.shift-num) + " от " + string(tt-rep.shift-date)
          tt-rep.col3       = buf_trn-doc.doc-code
          tt-rep.col4       = v-nids
          tt-rep.col5       = string(v-date-start) + "<br>" + chr(10) + string(v-hour-start, "99") + ":" + string(v-min-start, "99") + ":00"
          tt-rep.col6       = string(v-date-end) + "<br>" + chr(10) + string(v-hour-end, "99") + ":" + string(v-min-end, "99") + ":00"
          tt-rep.col7       = string(v-hour-pour) + ":" + string(v-min-pour, "99") + ":00"
          tt-rep.col8       = v-cli-name
          tt-rep.col9       = v-auto-cli-name
          tt-rep.col10      = v-nb-cli-name
          tt-rep.col11      = v-car-num
          tt-rep.col12      = v-sep
          tt-rep.col13      = v-driver-name
          tt-rep.col14      = v-user-name
          tt-rep.col15      = v-SectionName
          tt-rep.col16      = buf_goods.gds-name
          tt-rep.col17      = v-place-num
          tt-rep.col18      = (if v-sep = "АЦ без СЭП" then "" else if v-InfoSection:alarm-SGDKK then "ВУ" else "НУ")
          tt-rep.col19      = v-InfoSection:AukKey
          tt-rep.col35      = "Нет"
          tt-rep.col50      = "Нет"
          tt-rep.col51      = "АВД"
        .
        if v-InfoSection:isKP
        then do :
          if v-InfoSection:AccMeth = 1
          then do :
            tt-rep.col50 = "Да (резервуар)" .
          end .
          else do :
            tt-rep.col50 = "Да (АЦ)" .
          end .
        end .
        if v-InfoSection:TankWeight > 0
        then
          tt-rep.ac-measured = yes
        .
        else
          tt-rep.ac-measured = no
        .
        if v-is-sug-gds
        then do :
          assign
            tt-rep.col20  = buf_doc-line.doc-qnty
            tt-rep.col21  = buf_doc-line.cli-qnty
            tt-rep.col22  = buf_doc-line.doc-density
            tt-rep.col23  = buf_doc-line.temperature
          .
          assign
            tt-rep.col24  = ?
            tt-rep.col25  = ?
            tt-rep.col26  = ?
            tt-rep.col27  = ?
            tt-rep.col28  = ?
          .
        end .
        else do :
          assign
            tt-rep.col20  = if v-InfoSection:DocVolume > 0 then v-InfoSection:DocVolume else v-InfoSection:DocQnty
            tt-rep.col21  = v-InfoSection:CliQnty
            tt-rep.col22  = v-InfoSection:DocDensity
            tt-rep.col23  = v-InfoSection:TTNTemp
          .
          assign
            tt-rep.col24  = if v-InfoSection:TankVolPomi > 0 then v-InfoSection:TankVolPomi else v-InfoSection:TankVol
            tt-rep.col25  = v-InfoSection:TankWeight
            tt-rep.col26  = v-InfoSection:NaturalLoss
            tt-rep.col27  = if v-InfoSection:TankDensityPomi > 0 then v-InfoSection:TankDensityPomi else v-InfoSection:TankDensity
            tt-rep.col28  = v-InfoSection:TankTemp
          .
        end .
        assign
          tt-rep.col20str =  fDec2Str(tt-rep.col20, "->>>>>>>>>>>9"  )
          tt-rep.col21str =  fDec2Str(tt-rep.col21, "->>>>>>>>>>>9.9")
          tt-rep.col22str =  fDec2Str(tt-rep.col22, "->>>>>>>>9.9999")
          tt-rep.col23str =  fDec2Str(tt-rep.col23, "->>>>>>>>>>>9.9")
          tt-rep.col24str =  fDec2Str(tt-rep.col24, "->>>>>>>>>>>9"  )
          tt-rep.col25str =  fDec2Str(tt-rep.col25, "->>>>>>>>>>>9.9")
          tt-rep.col26str =  fDec2Str(tt-rep.col26, "->>>>>>>>>>9.99")
          tt-rep.col27str =  fDec2Str(tt-rep.col27, "->>>>>>>>9.9999")
          tt-rep.col28str =  fDec2Str(tt-rep.col28, "->>>>>>>>>>>9.9")
        .
        assign
          tt-rep.delta-mass-qnty-before = 0.65
          tt-rep.delta-mass-qnty-after = 0.65
          tt-rep.delta-mass-qnty-ac = 0.65
        .
        v-delta-mass-qnty-ac = v-InfoSection:AccPomi .
        if v-delta-mass-qnty-ac = 0
        or v-delta-mass-qnty-ac = ?
        then do :
          v-delta-mass-qnty-ac = v-InfoSectionsTotal:PercAcc .
        end .
        if v-delta-mass-qnty-ac = 0
        or v-delta-mass-qnty-ac = ?
        then do :
          v-delta-mass-qnty-ac = 0.65 .
        end .
        if v-delta-mass-qnty-ac > 0.65 then v-delta-mass-qnty-ac = 0.65 .
        assign
          tt-rep.delta-mass-qnty-ac = v-delta-mass-qnty-ac
        .
        for each buf_place no-lock where buf_place.obj-type = buf_doc-line.obj-type
                                     and buf_place.obj-code = buf_doc-line.obj-code
                                     and buf_place.loc1     = tt-rep.col17
        :
          empty temp-table tt-rvs-line-pump-delta .
          find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = 'перед_док':U
                                           and buf_rvs-doc.out-code = buf_doc-line.doc-code
                                           and num-entries(buf_rvs-doc.rvs-code, "-") = 3
                                           and entry(2, buf_rvs-doc.rvs-code, "-") = tt-rep.col15
                                           no-error .
          if not available buf_rvs-doc
          then do :
            find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = 'перед_док':U
                                             and buf_rvs-doc.out-code = buf_doc-line.doc-code
                                             no-error .
          end .
          if available buf_rvs-doc
          then do :
            for first buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                             and buf_rvs-line.gds-code = buf_goods.gds-code
                                             and buf_rvs-line.pl-code  = buf_place.pl-code
            :
              assign
                tt-rep.col29  = buf_rvs-line.state-measure-qnty
                tt-rep.col30  = buf_rvs-line.state-measure-cli-qnty
                tt-rep.col31  = buf_rvs-line.state-density
                tt-rep.col32  = buf_rvs-line.state-temperature
              .
              assign
                tt-rep.col29str = fDec2Str(buf_rvs-line.state-measure-qnty, "->>>>>>>>>>>9")
                tt-rep.col30str = fDec2Str(buf_rvs-line.state-measure-cli-qnty, "->>>>>>>>>>>9.9")
                tt-rep.col31str = fDec2Str(buf_rvs-line.state-density, "->>>>>>>>9.9999")
                tt-rep.col32str = fDec2Str(buf_rvs-line.state-temperature, "->>>>>>>>>>>9.9")
              .
              for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                    and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                    and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                    and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                    and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                    and buf_rvs-line-attr.attr-code = "temp-izm-vol"
              :
                assign
                  tt-rep.col32 = decimal(buf_rvs-line-attr.attr-value)
                  tt-rep.col32str = fDec2Str(decimal(buf_rvs-line-attr.attr-value), "->>>>>>>>>>>9.9")
                .
              end .
              for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                    and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                    and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                    and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                    and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                    and buf_rvs-line-attr.attr-code = "delta-mass-qnty"
              :
                tt-rep.delta-mass-qnty-before = decimal(buf_rvs-line-attr.attr-value) .
              end .
              for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                    and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                    and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                    and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                    and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                    and buf_rvs-line-attr.attr-code begins "input-type"
                                                    and buf_rvs-line-attr.attr-value <> 'а'
              :
                tt-rep.col51 = "РВД" .
              end .
              for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = buf_rvs-line.rvs-code
                                                   and buf_rvs-line-pump.obj-type = buf_rvs-line.obj-type
                                                   and buf_rvs-line-pump.obj-code = buf_rvs-line.obj-code
                                                   and buf_rvs-line-pump.pl-code  = buf_rvs-line.pl-code
                                                   and buf_rvs-line-pump.gds-code = buf_rvs-line.gds-code
              :
                find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                      and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and (buf_c-pl-gds-pump.corr-date < buf_trn-doc.fact-date
                                                        or buf_c-pl-gds-pump.corr-date = buf_trn-doc.fact-date and buf_c-pl-gds-pump.corr-time < buf_trn-doc.fact-time)
                                                      no-error .
                if available buf_c-pl-gds-pump
                then do :
                  find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                          and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                          and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                          and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                          and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                          and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                          no-error .
                  if available buf2_c-pl-gds-pump
                  then do :
                    v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
                  end .
                  else do :
                    for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                        and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                        and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                        and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                        and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                    :
                      v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                    end .
                  end .
                end .
                else do :
                  for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                  :
                    v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                  end .
                end .
                if v-pl-gds-pump-status_ = 'тек':U
                then do :
                  create tt-rvs-line-pump-delta .
                  buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
                  assign
                    tt-rvs-line-pump-delta.rvs-code = "before-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
                  .
                  if tt-rvs-line-pump-delta.state-el-cnt = ?
                  or tt-rvs-line-pump-delta.state-el-cnt <= 0
                  then do :
                    tt-rvs-line-pump-delta.is-err = yes .
                  end .
                end .
              end.
            end .
          end .
          find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = 'после_док':U
                                           and buf_rvs-doc.out-code = buf_doc-line.doc-code
                                           and num-entries(buf_rvs-doc.rvs-code, "-") = 3
                                           and entry(2, buf_rvs-doc.rvs-code, "-") = tt-rep.col15
                                           no-error .
          if not available buf_rvs-doc
          then do :
            find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = 'после_док':U
                                             and buf_rvs-doc.out-code = buf_doc-line.doc-code
                                             no-error .
          end .
          if available buf_rvs-doc
          then do :
            for first buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                             and buf_rvs-line.gds-code = buf_goods.gds-code
                                             and buf_rvs-line.pl-code  = buf_place.pl-code
            :
              assign
                tt-rep.col36  = buf_rvs-line.state-measure-qnty
                tt-rep.col37  = buf_rvs-line.state-measure-cli-qnty
                tt-rep.col38  = buf_rvs-line.state-density
                tt-rep.col39  = buf_rvs-line.state-temperature
              .
              assign
                tt-rep.col36str = fDec2Str(buf_rvs-line.state-measure-qnty, "->>>>>>>>>>>9")
                tt-rep.col37str = fDec2Str(buf_rvs-line.state-measure-cli-qnty, "->>>>>>>>>>>9.9")
                tt-rep.col38str = fDec2Str(buf_rvs-line.state-density, "->>>>>>>>9.9999")
                tt-rep.col39str = fDec2Str(buf_rvs-line.state-temperature, "->>>>>>>>>>>9.9")
              .
              for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                    and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                    and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                    and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                    and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                    and buf_rvs-line-attr.attr-code = "temp-izm-vol"
              :
                assign
                  tt-rep.col39 = decimal(buf_rvs-line-attr.attr-value)
                  tt-rep.col39str = fDec2Str(decimal(buf_rvs-line-attr.attr-value), "->>>>>>>>>>>9.9")
                .
              end .
              for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                    and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                    and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                    and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                    and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                    and buf_rvs-line-attr.attr-code = "delta-mass-qnty"
              :
                tt-rep.delta-mass-qnty-after = decimal(buf_rvs-line-attr.attr-value) .
              end .
              for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                    and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                    and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                    and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                    and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                    and buf_rvs-line-attr.attr-code begins "input-type"
                                                    and buf_rvs-line-attr.attr-value <> 'а'
              :
                tt-rep.col51 = "РВД" .
              end .
              for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = buf_rvs-line.rvs-code
                                                   and buf_rvs-line-pump.obj-type = buf_rvs-line.obj-type
                                                   and buf_rvs-line-pump.obj-code = buf_rvs-line.obj-code
                                                   and buf_rvs-line-pump.pl-code  = buf_rvs-line.pl-code
                                                   and buf_rvs-line-pump.gds-code = buf_rvs-line.gds-code
              :
                find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                      and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and (buf_c-pl-gds-pump.corr-date < buf_trn-doc.fact-date
                                                        or buf_c-pl-gds-pump.corr-date = buf_trn-doc.fact-date and buf_c-pl-gds-pump.corr-time < buf_trn-doc.fact-time)
                                                      no-error .
                if available buf_c-pl-gds-pump
                then do :
                  find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                          and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                          and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                          and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                          and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                          and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                          no-error .
                  if available buf2_c-pl-gds-pump
                  then do :
                    v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
                  end .
                  else do :
                    for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                        and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                        and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                        and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                        and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                    :
                      v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                    end .
                  end .
                end .
                else do :
                  for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                  :
                    v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                  end .
                end .
                if v-pl-gds-pump-status_ = 'тек':U
                then do :
                  find first tt-rvs-line-pump-delta where tt-rvs-line-pump-delta.rvs-code    = "before-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
                                                      and tt-rvs-line-pump-delta.obj-type    = buf_rvs-line-pump.obj-type
                                                      and tt-rvs-line-pump-delta.obj-code    = buf_rvs-line-pump.obj-code
                                                      and tt-rvs-line-pump-delta.pl-code     = buf_rvs-line-pump.pl-code
                                                      and tt-rvs-line-pump-delta.gds-code    = buf_rvs-line-pump.gds-code
                                                      and tt-rvs-line-pump-delta.pump-code   = buf_rvs-line-pump.pump-code
                                                      and tt-rvs-line-pump-delta.nozzle-code = buf_rvs-line-pump.nozzle-code
                                                      no-error .
                  if not available tt-rvs-line-pump-delta
                  then do :
                    create tt-rvs-line-pump-delta .
                    buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
                    assign
                      tt-rvs-line-pump-delta.rvs-code = "after-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
                      tt-rvs-line-pump-delta.is-err = yes
                    .
                  end .
                  else do :
                    tt-rvs-line-pump-delta.find-pair = yes .
                    if tt-rvs-line-pump-delta.state-el-cnt > buf_rvs-line-pump.state-el-cnt
                    then do :
                      tt-rvs-line-pump-delta.is-err = yes .
                    end .
                    else do :
                      tt-rvs-line-pump-delta.deltaVol = buf_rvs-line-pump.state-el-cnt - tt-rvs-line-pump-delta.state-el-cnt .
                    end .
                  end .
                end .
              end .
            end .
          end .
          for each tt-rvs-line-pump-delta :
            if not tt-rvs-line-pump-delta.find-pair
            then do :
              tt-rvs-line-pump-delta.is-err = yes .
            end .
            if tt-rvs-line-pump-delta.is-err = yes
            then do :
              tt-rvs-line-pump-delta.deltaVol = 0 .
              tt-rep.col35 = "Есть" .
            end .
            tt-rep.col33 = tt-rep.col33 + tt-rvs-line-pump-delta.deltaVol .
          end .
          v-avrg-dens = (tt-rep.col31 + tt-rep.col38) / 2 .
          tt-rep.col34 = tt-rep.col33 * v-avrg-dens .
        end .
        if is-com-tanks
        and not available buf_place
        then do :
          empty temp-table tt-rvs-line-pump-delta .
          find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = 'перед_док':U
                                           and buf_rvs-doc.out-code = buf_doc-line.doc-code
                                           and num-entries(buf_rvs-doc.rvs-code, "-") = 3
                                           and entry(2, buf_rvs-doc.rvs-code, "-") = tt-rep.col15
                                           no-error .
          if not available buf_rvs-doc
          then do :
            find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = 'перед_док':U
                                             and buf_rvs-doc.out-code = buf_doc-line.doc-code
                                             no-error .
          end .
          if available buf_rvs-doc
          then do :
            for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                            and buf_rvs-line.gds-code = buf_goods.gds-code,
              first buf_place no-lock where buf_place.obj-type = buf_rvs-line.obj-type
                                        and buf_place.obj-code = buf_rvs-line.obj-code
                                        and buf_place.pl-code  = buf_rvs-line.pl-code
            :
              if not can-do(v-place-num, buf_place.loc1) then next .
              assign
                tt-rep.col29  = tt-rep.col29 + buf_rvs-line.state-measure-qnty
                tt-rep.col30  = tt-rep.col30 + buf_rvs-line.state-measure-cli-qnty
              .
              assign
                tt-rep.col29str = tt-rep.col29str + fDec2Str(buf_rvs-line.state-measure-qnty, "->>>>>>>>>>>9") + "<br>" + chr(10)
                tt-rep.col30str = tt-rep.col30str + fDec2Str(buf_rvs-line.state-measure-cli-qnty, "->>>>>>>>>>>9.9") + "<br>" + chr(10)
                tt-rep.col31str = tt-rep.col31str + fDec2Str(buf_rvs-line.state-density, "->>>>>>>>9.9999") + "<br>" + chr(10)
              .
              run placelib_get-attr  ( input "place-is-main"
                ,input buf_rvs-line.obj-code
                ,input buf_rvs-line.obj-type
                ,input buf_rvs-line.pl-code
                ,output varvalue
                ,output v-ok      ) no-error.
              if v-ok
              and varvalue > ""
              and logical(varvalue)
              then do :
                assign v-avrg-dens = buf_rvs-line.state-density .
              end .
              find first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                     and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                     and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                     and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                     and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                     and buf_rvs-line-attr.attr-code = "temp-izm-vol"
                                                     no-error .
              if available buf_rvs-line-attr
              and buf_rvs-line-attr.attr-value > ""
              then do :
                assign
                  tt-rep.col32 = tt-rep.col32 + decimal(buf_rvs-line-attr.attr-value)
                  tt-rep.col32str = tt-rep.col32str + fDec2Str(decimal(buf_rvs-line-attr.attr-value), "->>>>>>>>>>>9.9") + "<br>" + chr(10)
                .
              end .
              else do :
                assign
                  tt-rep.col32  = tt-rep.col32 + buf_rvs-line.state-temperature
                  tt-rep.col32str = tt-rep.col32str + fDec2Str(buf_rvs-line.state-temperature, "->>>>>>>>>>>9.9") + "<br>" + chr(10)
                .
              end .
              for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                    and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                    and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                    and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                    and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                    and buf_rvs-line-attr.attr-code = "delta-mass-qnty"
              :
                tt-rep.delta-mass-qnty-before = decimal(buf_rvs-line-attr.attr-value) .
              end .
              for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                    and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                    and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                    and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                    and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                    and buf_rvs-line-attr.attr-code begins "input-type"
                                                    and buf_rvs-line-attr.attr-value <> 'а'
              :
                tt-rep.col51 = "РВД" .
              end .
              for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = buf_rvs-line.rvs-code
                                                   and buf_rvs-line-pump.obj-type = buf_rvs-line.obj-type
                                                   and buf_rvs-line-pump.obj-code = buf_rvs-line.obj-code
                                                   and buf_rvs-line-pump.pl-code  = buf_rvs-line.pl-code
                                                   and buf_rvs-line-pump.gds-code = buf_rvs-line.gds-code
              :
                find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                      and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and (buf_c-pl-gds-pump.corr-date < buf_trn-doc.fact-date
                                                        or buf_c-pl-gds-pump.corr-date = buf_trn-doc.fact-date and buf_c-pl-gds-pump.corr-time < buf_trn-doc.fact-time)
                                                      no-error .
                if available buf_c-pl-gds-pump
                then do :
                  find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                          and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                          and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                          and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                          and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                          and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                          no-error .
                  if available buf2_c-pl-gds-pump
                  then do :
                    v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
                  end .
                  else do :
                    for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                        and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                        and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                        and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                        and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                    :
                      v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                    end .
                  end .
                end .
                else do :
                  for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                  :
                    v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                  end .
                end .
                if v-pl-gds-pump-status_ = 'тек':U
                then do :
                  create tt-rvs-line-pump-delta .
                  buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
                  assign
                    tt-rvs-line-pump-delta.rvs-code = "before-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
                  .
                  if tt-rvs-line-pump-delta.state-el-cnt = ?
                  or tt-rvs-line-pump-delta.state-el-cnt <= 0
                  then do :
                    tt-rvs-line-pump-delta.is-err = yes .
                  end .
                end .
              end.
            end .
            assign
              tt-rep.col31 = tt-rep.col30 / tt-rep.col29
              tt-rep.col32 = tt-rep.col32 / v-num-com-tanks
            .
          end .
          find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = 'после_док':U
                                           and buf_rvs-doc.out-code = buf_doc-line.doc-code
                                           and num-entries(buf_rvs-doc.rvs-code, "-") = 3
                                           and entry(2, buf_rvs-doc.rvs-code, "-") = tt-rep.col15
                                           no-error .
          if not available buf_rvs-doc
          then do :
            find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = 'после_док':U
                                             and buf_rvs-doc.out-code = buf_doc-line.doc-code
                                             no-error .
          end .
          if available buf_rvs-doc
          then do :
            for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                            and buf_rvs-line.gds-code = buf_goods.gds-code,
              first buf_place no-lock where buf_place.obj-type = buf_rvs-line.obj-type
                                        and buf_place.obj-code = buf_rvs-line.obj-code
                                        and buf_place.pl-code  = buf_rvs-line.pl-code
            :
              if not can-do(v-place-num, buf_place.loc1) then next .
              assign
                tt-rep.col36  = tt-rep.col36 + buf_rvs-line.state-measure-qnty
                tt-rep.col37  = tt-rep.col37 + buf_rvs-line.state-measure-cli-qnty
              .
              assign
                tt-rep.col36str = tt-rep.col36str + fDec2Str(buf_rvs-line.state-measure-qnty, "->>>>>>>>>>>9") + "<br>" + chr(10)
                tt-rep.col37str = tt-rep.col37str + fDec2Str(buf_rvs-line.state-measure-cli-qnty, "->>>>>>>>>>>9.9") + "<br>" + chr(10)
                tt-rep.col38str = tt-rep.col38str + fDec2Str(buf_rvs-line.state-density, "->>>>>>>>9.9999") + "<br>" + chr(10)
              .
              run placelib_get-attr  ( input "place-is-main"
                ,input buf_rvs-line.obj-code
                ,input buf_rvs-line.obj-type
                ,input buf_rvs-line.pl-code
                ,output varvalue
                ,output v-ok      ) no-error.
              if v-ok
              and varvalue > ""
              and logical(varvalue)
              then do :
                assign v-avrg-dens = (v-avrg-dens + buf_rvs-line.state-density) / 2 .
              end .
              find first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                     and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                     and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                     and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                     and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                     and buf_rvs-line-attr.attr-code = "temp-izm-vol"
                                                     no-error .
              if available buf_rvs-line-attr
              and buf_rvs-line-attr.attr-value > ""
              then do :
                assign
                  tt-rep.col39 = tt-rep.col39 + decimal(buf_rvs-line-attr.attr-value)
                  tt-rep.col39str = tt-rep.col39str + fDec2Str(decimal(buf_rvs-line-attr.attr-value), "->>>>>>>>>>>9.9") + "<br>" + chr(10)
                .
              end .
              else do :
                assign
                  tt-rep.col39  = tt-rep.col39 + buf_rvs-line.state-temperature
                  tt-rep.col39str = tt-rep.col39str + fDec2Str(buf_rvs-line.state-temperature, "->>>>>>>>>>>9.9") + "<br>" + chr(10)
                .
              end .
              for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                    and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                    and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                    and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                    and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                    and buf_rvs-line-attr.attr-code = "delta-mass-qnty"
              :
                tt-rep.delta-mass-qnty-after = decimal(buf_rvs-line-attr.attr-value) .
              end .
              for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                    and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                    and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                    and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                    and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                    and buf_rvs-line-attr.attr-code begins "input-type"
                                                    and buf_rvs-line-attr.attr-value <> 'а'
              :
                tt-rep.col51 = "РВД" .
              end .
              for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = buf_rvs-line.rvs-code
                                                   and buf_rvs-line-pump.obj-type = buf_rvs-line.obj-type
                                                   and buf_rvs-line-pump.obj-code = buf_rvs-line.obj-code
                                                   and buf_rvs-line-pump.pl-code  = buf_rvs-line.pl-code
                                                   and buf_rvs-line-pump.gds-code = buf_rvs-line.gds-code
              :
                find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                      and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and (buf_c-pl-gds-pump.corr-date < buf_trn-doc.fact-date
                                                        or buf_c-pl-gds-pump.corr-date = buf_trn-doc.fact-date and buf_c-pl-gds-pump.corr-time < buf_trn-doc.fact-time)
                                                      no-error .
                if available buf_c-pl-gds-pump
                then do :
                  find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                          and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                          and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                          and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                          and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                          and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                          no-error .
                  if available buf2_c-pl-gds-pump
                  then do :
                    v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
                  end .
                  else do :
                    for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                        and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                        and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                        and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                        and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                    :
                      v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                    end .
                  end .
                end .
                else do :
                  for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                  :
                    v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                  end .
                end .
                if v-pl-gds-pump-status_ = 'тек':U
                then do :
                  find first tt-rvs-line-pump-delta where tt-rvs-line-pump-delta.rvs-code    = "before-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
                                                      and tt-rvs-line-pump-delta.obj-type    = buf_rvs-line-pump.obj-type
                                                      and tt-rvs-line-pump-delta.obj-code    = buf_rvs-line-pump.obj-code
                                                      and tt-rvs-line-pump-delta.pl-code     = buf_rvs-line-pump.pl-code
                                                      and tt-rvs-line-pump-delta.gds-code    = buf_rvs-line-pump.gds-code
                                                      and tt-rvs-line-pump-delta.pump-code   = buf_rvs-line-pump.pump-code
                                                      and tt-rvs-line-pump-delta.nozzle-code = buf_rvs-line-pump.nozzle-code
                                                      no-error .
                  if not available tt-rvs-line-pump-delta
                  then do :
                    create tt-rvs-line-pump-delta .
                    buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
                    assign
                      tt-rvs-line-pump-delta.rvs-code = "after-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
                      tt-rvs-line-pump-delta.is-err = yes
                    .
                  end .
                  else do :
                    tt-rvs-line-pump-delta.find-pair = yes .
                    if tt-rvs-line-pump-delta.state-el-cnt > buf_rvs-line-pump.state-el-cnt
                    then do :
                      tt-rvs-line-pump-delta.is-err = yes .
                    end .
                    else do :
                      tt-rvs-line-pump-delta.deltaVol = buf_rvs-line-pump.state-el-cnt - tt-rvs-line-pump-delta.state-el-cnt .
                    end .
                  end .
                end .
              end .
            end .
            assign
              tt-rep.col38 = tt-rep.col37 / tt-rep.col36
              tt-rep.col39 = tt-rep.col39 / v-num-com-tanks
            .
          end .
          for each tt-rvs-line-pump-delta :
            if not tt-rvs-line-pump-delta.find-pair
            then do :
              tt-rvs-line-pump-delta.is-err = yes .
            end .
            if tt-rvs-line-pump-delta.is-err = yes
            then do :
              tt-rvs-line-pump-delta.deltaVol = 0 .
              tt-rep.col35 = "Есть" .
            end .
            tt-rep.col33 = tt-rep.col33 + tt-rvs-line-pump-delta.deltaVol .
          end .
          assign tt-rep.col34 = tt-rep.col33 * v-avrg-dens .
          assign
            tt-rep.col29str = trim(tt-rep.col29str, "<br>" + chr(10))
            tt-rep.col30str = trim(tt-rep.col30str, "<br>" + chr(10))
            tt-rep.col31str = trim(tt-rep.col31str, "<br>" + chr(10))
            tt-rep.col32str = trim(tt-rep.col32str, "<br>" + chr(10))
            tt-rep.col36str = trim(tt-rep.col36str, "<br>" + chr(10))
            tt-rep.col37str = trim(tt-rep.col37str, "<br>" + chr(10))
            tt-rep.col38str = trim(tt-rep.col38str, "<br>" + chr(10))
            tt-rep.col39str = trim(tt-rep.col39str, "<br>" + chr(10))
          .
        end .
        if tt-rep.col34 = ? then tt-rep.col34 = 0 .
        assign
          tt-rep.col40  = v-InfoSection:FactQnty
          tt-rep.col41  = v-InfoSection:FactKgQnty
        .
        if v-InfoSection:TankWeight > 0
        then do :
          assign
            tt-rep.col42  = tt-rep.col25 - tt-rep.col21
            tt-rep.col43  = tt-rep.col42 / tt-rep.col21 * 100
          .
          assign
            tt-rep.col44  = tt-rep.col37 + tt-rep.col34 - tt-rep.col30 - tt-rep.col25
            tt-rep.col45  = tt-rep.col44 / tt-rep.col25 * 100
          .
        end .
        assign
          tt-rep.col46  = tt-rep.col37 + tt-rep.col34 - tt-rep.col30 - tt-rep.col41
          tt-rep.col47  = tt-rep.col46 / tt-rep.col41 * 100
        .
        v-delta-ac = sqrt(exp((tt-rep.col37 * tt-rep.delta-mass-qnty-after), 2) + exp((tt-rep.col30 * tt-rep.delta-mass-qnty-before), 2) + exp((tt-rep.col34 * 0.5), 2) + exp((tt-rep.col25 * tt-rep.delta-mass-qnty-ac), 2)) / 100 .
        v-delta-fact = sqrt(exp((tt-rep.col37 * tt-rep.delta-mass-qnty-after), 2) + exp((tt-rep.col34 * 0.5), 2) + exp((tt-rep.col30 * tt-rep.delta-mass-qnty-before), 2)) / 100 .
        if v-delta-ac > abs(tt-rep.col44)
        then do :
          tt-rep.col48 = 0 .
        end .
        else do :
          tt-rep.col48 = abs(tt-rep.col44) - v-delta-ac .
          if tt-rep.col44 < 0
          then
            tt-rep.col48 = tt-rep.col48 * -1
          .
        end .
        if v-is-sug-gds
        then do :
          tt-rep.col48 = 0 .
        end .
        if v-delta-fact > abs(tt-rep.col46)
        then do :
          tt-rep.col49 = 0 .
        end .
        else do :
          tt-rep.col49 = abs(tt-rep.col46) - v-delta-fact .
          if tt-rep.col46 < 0
          then
            tt-rep.col49 = tt-rep.col49 * -1
          .
        end .
      end .
      else do :
        if v-InfoSection:isKP
        then do :
          if v-InfoSection:AccMeth = 1
          then do :
            tt-rep.col50 = "Да (резервуар)" .
          end .
          else do :
            tt-rep.col50 = "Да (АЦ)" .
          end .
        end .
        if v-InfoSection:TankWeight > 0
        and tt-rep.ac-measured = yes
        then
          tt-rep.ac-measured = yes
        .
        else
          tt-rep.ac-measured = no
        .
        assign
          tt-rep.col15 = tt-rep.col15 + "," + v-SectionName
          tt-rep.col18 = tt-rep.col18 + "<br>" + chr(10) + (if v-sep = "АЦ без СЭП" then "" else if v-InfoSection:alarm-SGDKK then "ВУ" else "НУ")
          tt-rep.col19 = tt-rep.col19 + "<br>" + chr(10) + v-InfoSection:AukKey
        .
        v-delta-mass-qnty-ac = v-InfoSection:AccPomi .
        if v-delta-mass-qnty-ac = 0
        or v-delta-mass-qnty-ac = ?
        then do :
          v-delta-mass-qnty-ac = v-InfoSectionsTotal:PercAcc .
        end .
        if v-delta-mass-qnty-ac = 0
        or v-delta-mass-qnty-ac = ?
        then do :
          v-delta-mass-qnty-ac = 0.65 .
        end .
        if v-delta-mass-qnty-ac > 0.65 then v-delta-mass-qnty-ac = 0.65 .
        assign
          tt-rep.delta-mass-qnty-ac = tt-rep.delta-mass-qnty-ac + v-delta-mass-qnty-ac
        .
        assign
          tt-rep.col20  = tt-rep.col20 + if v-InfoSection:DocVolume > 0 then v-InfoSection:DocVolume else v-InfoSection:DocQnty
          tt-rep.col21  = tt-rep.col21 + v-InfoSection:CliQnty
          tt-rep.col22  = tt-rep.col22 + v-InfoSection:DocDensity
          tt-rep.col23  = tt-rep.col23 + v-InfoSection:TTNTemp
        .
        assign
          tt-rep.col24  = tt-rep.col24 + (if v-InfoSection:TankVolPomi > 0 then v-InfoSection:TankVolPomi else v-InfoSection:TankVol)
          tt-rep.col25  = tt-rep.col25 + v-InfoSection:TankWeight
          tt-rep.col26  = tt-rep.col26 + v-InfoSection:NaturalLoss
          tt-rep.col27  = tt-rep.col27 + (if v-InfoSection:TankDensityPomi > 0 then v-InfoSection:TankDensityPomi else v-InfoSection:TankDensity)
          tt-rep.col28  = tt-rep.col28 + v-InfoSection:TankTemp
        .
        assign
          tt-rep.col20str = tt-rep.col20str + "<br>" + chr(10) + fDec2Str((if v-InfoSection:DocVolume > 0 then v-InfoSection:DocVolume else v-InfoSection:DocQnty), "->>>>>>>>>>>9"  )
          tt-rep.col21str = tt-rep.col21str + "<br>" + chr(10) + fDec2Str(v-InfoSection:CliQnty, "->>>>>>>>>>>9.9")
          tt-rep.col22str = tt-rep.col22str + "<br>" + chr(10) + fDec2Str(v-InfoSection:DocDensity, "->>>>>>>>9.9999")
          tt-rep.col23str = tt-rep.col23str + "<br>" + chr(10) + fDec2Str(v-InfoSection:TTNTemp, "->>>>>>>>>>>9.9")
          tt-rep.col24str = tt-rep.col24str + "<br>" + chr(10) + fDec2Str((if v-InfoSection:TankVolPomi > 0 then v-InfoSection:TankVolPomi else v-InfoSection:TankVol), "->>>>>>>>>>>9"  )
          tt-rep.col25str = tt-rep.col25str + "<br>" + chr(10) + fDec2Str(v-InfoSection:TankWeight, "->>>>>>>>>>>9.9")
          tt-rep.col26str = tt-rep.col26str + "<br>" + chr(10) + fDec2Str(v-InfoSection:NaturalLoss, "->>>>>>>>>>9.99")
          tt-rep.col27str = tt-rep.col27str + "<br>" + chr(10) + fDec2Str((if v-InfoSection:TankDensityPomi > 0 then v-InfoSection:TankDensityPomi else v-InfoSection:TankDensity), "->>>>>>>>9.9999")
          tt-rep.col28str = tt-rep.col28str + "<br>" + chr(10) + fDec2Str(v-InfoSection:TankTemp, "->>>>>>>>>>>9.9")
        .
        assign
          tt-rep.col40  = tt-rep.col40 + v-InfoSection:FactQnty
          tt-rep.col41  = tt-rep.col41 + v-InfoSection:FactKgQnty
        .
        if tt-rep.ac-measured
        then do :
          assign
            tt-rep.col42  = tt-rep.col25 - tt-rep.col21
            tt-rep.col43  = tt-rep.col42 / tt-rep.col21 * 100
          .
          assign
            tt-rep.col44  = tt-rep.col37 + tt-rep.col34 - tt-rep.col30 - tt-rep.col25
            tt-rep.col45  = tt-rep.col44 / tt-rep.col25 * 100
          .
        end .
        else do :
          assign
            tt-rep.col42  = 0
            tt-rep.col43  = 0
            tt-rep.col44  = 0
            tt-rep.col45  = 0
          .
        end .
        assign
          tt-rep.col46  = tt-rep.col37 + tt-rep.col34 - tt-rep.col30 - tt-rep.col41
          tt-rep.col47  = tt-rep.col46 / tt-rep.col41 * 100
        .
      end .
    end .
    delete object v-InfoSectionsTotal no-error .
    for each tt-rep where tt-rep.obj-type   = obj-list.obj-type
                      and tt-rep.obj-code   = obj-list.obj-code
                      and tt-rep.gds-code   = buf_goods.gds-code
                      and tt-rep.col3       = buf_trn-doc.doc-code
                      and num-entries(tt-rep.col15) > 1
    :
      assign
        tt-rep.col22  = tt-rep.col22 / num-entries(tt-rep.col15)
        tt-rep.col23  = tt-rep.col23 / num-entries(tt-rep.col15)
        tt-rep.col27  = tt-rep.col27 / num-entries(tt-rep.col15)
        tt-rep.col28  = tt-rep.col28 / num-entries(tt-rep.col15)
      .
      assign
        tt-rep.delta-mass-qnty-ac = tt-rep.delta-mass-qnty-ac / num-entries(tt-rep.col15)
      .
      v-delta-ac = sqrt(exp((tt-rep.col37 * tt-rep.delta-mass-qnty-after), 2) + exp((tt-rep.col30 * tt-rep.delta-mass-qnty-before), 2) + exp((tt-rep.col34 * 0.5), 2) + exp((tt-rep.col25 * tt-rep.delta-mass-qnty-ac), 2)) / 100 .
      v-delta-fact = sqrt(exp((tt-rep.col37 * tt-rep.delta-mass-qnty-after), 2) + exp((tt-rep.col34 * 0.5), 2) + exp((tt-rep.col30 * tt-rep.delta-mass-qnty-before), 2)) / 100 .
      if v-delta-ac > abs(tt-rep.col44)
      then do :
        tt-rep.col48 = 0 .
      end .
      else do :
        tt-rep.col48 = abs(tt-rep.col44) - v-delta-ac .
        if tt-rep.col44 < 0
        then
          tt-rep.col48 = tt-rep.col48 * -1
        .
      end .
      if v-is-sug-gds
      then do :
        tt-rep.col48 = 0 .
      end .
      if v-delta-fact > abs(tt-rep.col46)
      then do :
        tt-rep.col49 = 0 .
      end .
      else do :
        tt-rep.col49 = abs(tt-rep.col46) - v-delta-fact .
        if tt-rep.col46 < 0
        then
          tt-rep.col49 = tt-rep.col49 * -1
        .
      end .
    end .
  end .
end procedure .
procedure calc-itog :
  for each tt-rep :
    tt-rep.no-itog = no .
    if iDelta-tank-ac
    and iDelta-tank-fact
    then do :
      if tt-rep.col48 = 0
      and tt-rep.col49 = 0
      then tt-rep.no-itog = yes .
    end .
    else
    if iDelta-tank-ac
    then do :
      if tt-rep.col48 = 0 then tt-rep.no-itog = yes .
    end .
    else
    if iDelta-tank-fact
    then do :
      if tt-rep.col49 = 0 then tt-rep.no-itog = yes .
    end .
    if iTranTimeMax > 0
    then do :
      if tt-rep.min-pour <= iTranTimeMax then tt-rep.no-itog = yes .
    end .
    if (iTrkErr = 2 and tt-rep.col35 = "Нет")
    or (iTrkErr = 3 and tt-rep.col35 = "Есть")
    then do :
      tt-rep.no-itog = yes .
    end .
  end .
  for each tt-rep where not tt-rep.no-itog :
    if not i-NoAzkItog
    then do :
      find first tt-itog where tt-itog.obj-type = tt-rep.obj-type
                           and tt-itog.obj-code = tt-rep.obj-code
                           no-error .
      if not available tt-itog
      then do :
        create tt-itog .
        assign
          tt-itog.obj-type = tt-rep.obj-type
          tt-itog.obj-code = tt-rep.obj-code
          tt-itog.col1     = tt-rep.col1
          tt-itog.col43red = no
          tt-itog.col45red = no
          tt-itog.col47red = no
        .
      end .
      assign
        tt-itog.col20 = tt-itog.col20 + tt-rep.col20
        tt-itog.col21 = tt-itog.col21 + tt-rep.col21
        tt-itog.col24 = tt-itog.col24 + (if tt-rep.col24 = ? then 0 else tt-rep.col24)
        tt-itog.col25 = tt-itog.col25 + (if tt-rep.col25 = ? then 0 else tt-rep.col25)
        tt-itog.col26 = tt-itog.col26 + (if tt-rep.col26 = ? then 0 else tt-rep.col26)
        tt-itog.col29 = tt-itog.col29 + (if tt-rep.col29 = ? then 0 else tt-rep.col29)
        tt-itog.col30 = tt-itog.col30 + (if tt-rep.col30 = ? then 0 else tt-rep.col30)
        tt-itog.col33 = tt-itog.col33 + (if tt-rep.col33 = ? then 0 else tt-rep.col33)
        tt-itog.col34 = tt-itog.col34 + (if tt-rep.col34 = ? then 0 else tt-rep.col34)
        tt-itog.col36 = tt-itog.col36 + (if tt-rep.col36 = ? then 0 else tt-rep.col36)
        tt-itog.col37 = tt-itog.col37 + (if tt-rep.col37 = ? then 0 else tt-rep.col37)
        tt-itog.col40 = tt-itog.col40 + tt-rep.col40
        tt-itog.col41 = tt-itog.col41 + tt-rep.col41
        tt-itog.col42 = tt-itog.col42 + (if tt-rep.col42 = ? then 0 else tt-rep.col42)
        tt-itog.col43 = tt-itog.col42 / tt-itog.col21 * 100
        tt-itog.col44 = tt-itog.col44 + (if tt-rep.col44 = ? then 0 else tt-rep.col44)
        tt-itog.col45 = tt-itog.col44 / tt-itog.col25 * 100
        tt-itog.col46 = tt-itog.col46 + (if tt-rep.col46 = ? then 0 else tt-rep.col46)
        tt-itog.col47 = tt-itog.col46 / tt-itog.col41 * 100
        tt-itog.col48 = tt-itog.col48 + (if tt-rep.col48 = ? then 0 else tt-rep.col48)
        tt-itog.col49 = tt-itog.col49 + (if tt-rep.col49 = ? then 0 else tt-rep.col49)
      .
    end .
    find first tt-all-itog no-error .
    if not available tt-all-itog
    then do :
      create tt-all-itog .
      assign
        tt-all-itog.col43red = no
        tt-all-itog.col45red = no
        tt-all-itog.col47red = no
      .
    end .
    assign
      tt-all-itog.col20 = tt-all-itog.col20 + tt-rep.col20
      tt-all-itog.col21 = tt-all-itog.col21 + tt-rep.col21
      tt-all-itog.col24 = tt-all-itog.col24 + (if tt-rep.col24 = ? then 0 else tt-rep.col24)
      tt-all-itog.col25 = tt-all-itog.col25 + (if tt-rep.col25 = ? then 0 else tt-rep.col25)
      tt-all-itog.col26 = tt-all-itog.col26 + (if tt-rep.col26 = ? then 0 else tt-rep.col26)
      tt-all-itog.col29 = tt-all-itog.col29 + (if tt-rep.col29 = ? then 0 else tt-rep.col29)
      tt-all-itog.col30 = tt-all-itog.col30 + (if tt-rep.col30 = ? then 0 else tt-rep.col30)
      tt-all-itog.col33 = tt-all-itog.col33 + (if tt-rep.col33 = ? then 0 else tt-rep.col33)
      tt-all-itog.col34 = tt-all-itog.col34 + (if tt-rep.col34 = ? then 0 else tt-rep.col34)
      tt-all-itog.col36 = tt-all-itog.col36 + (if tt-rep.col36 = ? then 0 else tt-rep.col36)
      tt-all-itog.col37 = tt-all-itog.col37 + (if tt-rep.col37 = ? then 0 else tt-rep.col37)
      tt-all-itog.col40 = tt-all-itog.col40 + tt-rep.col40
      tt-all-itog.col41 = tt-all-itog.col41 + tt-rep.col41
      tt-all-itog.col42 = tt-all-itog.col42 + (if tt-rep.col42 = ? then 0 else tt-rep.col42)
      tt-all-itog.col43 = tt-all-itog.col42 / tt-all-itog.col21 * 100
      tt-all-itog.col44 = tt-all-itog.col44 + (if tt-rep.col44 = ? then 0 else tt-rep.col44)
      tt-all-itog.col45 = tt-all-itog.col44 / tt-all-itog.col25 * 100
      tt-all-itog.col46 = tt-all-itog.col46 + (if tt-rep.col46 = ? then 0 else tt-rep.col46)
      tt-all-itog.col47 = tt-all-itog.col46 / tt-all-itog.col41 * 100
      tt-all-itog.col48 = tt-all-itog.col48 + (if tt-rep.col48 = ? then 0 else tt-rep.col48)
      tt-all-itog.col49 = tt-all-itog.col49 + (if tt-rep.col49 = ? then 0 else tt-rep.col49)
    .
    if abs(tt-rep.col43) > tt-rep.delta-mass-qnty-ac
    then do :
      assign
        tt-itog.col43red = yes when available tt-itog
        tt-all-itog.col43red = yes
      .
    end .
    if abs(tt-rep.col45) > 0.65
    then do :
      assign
        tt-itog.col45red = yes when available tt-itog
        tt-all-itog.col45red = yes
      .
    end .
    if abs(tt-rep.col47) > 0.65
    then do :
      assign
        tt-itog.col47red = yes when available tt-itog
        tt-all-itog.col47red = yes
      .
    end .
  end .
end procedure .
procedure PrintTT:
   define variable vReportId     as character no-undo.
   define variable vFileNameRep  as character no-undo.
   define variable vStr          as character no-undo.
   define variable vI            as integer   no-undo.
   do on error undo, return error return-value:
      run get-report-num(output vReportId).
      vFileNameRep = session:temp-directory + string(vReportId) + ".html".
      output stream sOutStr-html to value(vFileNameRep) convert target 'UTF-8'.
      put stream sOutStr-html unformatted
"<!DOCTYPE HTML>" skip
' <html>' skip
'  <head>' skip
'   <meta charset="utf-8">' skip
'    <style type="text/css">' skip
'      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
'      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
'      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black;' + chr(125) skip
'   </style>' skip
'  </head>' skip
      .
      put stream sOutStr-html unformatted
           '<body>' skip
           '<TABLE name="1" outline_below="true" fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">' skip
           '<thead>' skip
           '<TR class="set_columns">' skip
               '<TD style="width: 100px;"></TD>' skip
               '<TD style="width:  60px;"></TD>' skip
               '<TD style="width:  80px;"></TD>' skip
               '<TD style="width:  80px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  50px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  50px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  79px;"></TD>' skip
               '<TD style="width:  82px;"></TD>' skip
               '<TD style="width:  97px;"></TD>' skip
               '<TD style="width:  60px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  60px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  90px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  90px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  90px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  90px;"></TD>' skip
               '<TD style="width:  70px;"></TD>' skip
               '<TD style="width:  90px;"></TD>' skip
           '</TR>' skip
           '<TR>' skip
               '<TD colspan="12" STYLE="font-size: 14px;">' + 'Сводный отчёт по поставкам топлива' + '</TD>'skip
               '<TD colspan="9" STYLE="font-size: 14px; font-weight:bold; ">' + 'Примечание к отчету:' + '</TD>'skip
           '</TR>' skip
           .
      do vI = 1 to extent(mParamStr):
         if mParamStr[vI] = ""
         and mPrim1[vI] = ""
         then leave .
         put stream sOutStr-html unformatted
              '<TR>' skip
                  '<TD colspan="12" STYLE="font-size: 14px;">' + mParamStr[vI] + '</TD>' skip
                  '<TD colspan="9" STYLE="font-size: 14px; font-style: italic; ">' + mPrim1[vI] + '</TD>' skip
                  '<TD colspan="14" STYLE="font-size: 14px; font-style: italic; ">' + mPrim2[vI] + '</TD>' skip
                  '<TD colspan="14" STYLE="font-size: 14px; font-style: italic; ">' + mPrim3[vI] + '</TD>' skip
              '</TR>' skip
            .
      end.
      put stream sOutStr-html unformatted
           '<TR>' skip
               '<TD colspan="14" STYLE="font-size: 14px;">Дата печати: ' + string(today, "99.99.9999") + ' ' + string(time, "HH:MM") + '</TD>' skip
           '</TR>' skip
           '</thead>' skip
         .
      put stream sOutStr-html unformatted
        '<tbody>'
        '<TR >'skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">АЗК/АЗС</TH>'                                                   skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Дата и номер смены</TH>'                                        skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Внутренний номер документа приема</TH>'                         skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Номер документа поставщика</TH>'                                skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Дата/время начала слива</TH>'                                   skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Дата/время окончания слива</TH>'                                skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Длительность приемки</TH>'                                             skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Поставщик</TH>'                                                 skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Перевозчик</TH>'                                                skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Нефтебаза</TH>'                                                 skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">АЦ</TH>'                                                        skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Тип АЦ</TH>'                                                    skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Водитель</TH>'                                                  skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Приёмщик</TH>'                                                  skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">№ секции</TH>'                                                  skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Марка НП</TH>'                                                  skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">№ резервуара</TH>'                                              skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Способ разблокировки API-адаптера</TH>'                         skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Номер ключа/код доступа</TH>'                                   skip
        '<TH text_wrap="true" rowspan="4" colspan="4" style="text-align: center; font-weight:bold; ">Параметры топлива по ТТН</TH>'                                  skip
        '<TH text_wrap="true" rowspan="4" colspan="5" style="text-align: center; font-weight:bold; ">Параметры топлива по измерениям в АЦ</TH>'                      skip
        '<TH text_wrap="true" rowspan="4" colspan="4" style="text-align: center; font-weight:bold; ">Параметры топлива по измерениям в резервуаре до слива</TH>'     skip
        '<TH text_wrap="true" rowspan="4" colspan="3" style="text-align: center; font-weight:bold; ">Реализация при сливе НП</TH>'                                   skip
        '<TH text_wrap="true" rowspan="4" colspan="4" style="text-align: center; font-weight:bold; ">Параметры топлива по измерениям в резервуаре после слива</TH>'  skip
        '<TH text_wrap="true" rowspan="4" colspan="2" style="text-align: center; font-weight:bold; ">Принято к учету</TH>'                                           skip
        '<TH text_wrap="true" rowspan="4" colspan="2" style="text-align: center; font-weight:bold; ">Отклонение АЦ к ТТН</TH>'                                       skip
        '<TH text_wrap="true" rowspan="4" colspan="2" style="text-align: center; font-weight:bold; ">Отклонение резервуара к АЦ</TH>'                                skip
        '<TH text_wrap="true" rowspan="4" colspan="2" style="text-align: center; font-weight:bold; ">Отклонение между резервуаром и  принятым к учету топливом</TH>' skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Сверхнормативные расхождения между резервуаром и АЦ, кг</TH>'   skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Сверхнормативные расхождения между резервуаром и принятым к учету топливом, кг</TH>' skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">АЦ слита с комиссией</TH>'   skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Способ ввода данных в сверке (АВД/РВД)</TH>' skip
        '</TR>'skip
        '<TR >'skip
        '</TR>'skip
        '<TR >'skip
        '</TR>'skip
        '<TR >'skip
        '</TR>'skip
        '<TR >'skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Объем, л</TH>'                        skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Масса, кг</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Плотн., г/см3</TH>'                   skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Темп., °С</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Объем, л</TH>'                        skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Масса, кг</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Масса ЕУ, кг</TH>'                    skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Плотн., г/см3</TH>'                   skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Темп., °С</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Объем, л</TH>'                        skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Масса, кг</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Плотн., г/см3</TH>'                   skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Темп., °С</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Объем, л</TH>'                        skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Масса, кг</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Ошибка данных с ТРК</TH>'             skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Объем, л</TH>'                        skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Масса, кг</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Плотн., г/см3</TH>'                   skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Темп., °С</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Объем, л</TH>'                        skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Масса, кг</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Масса, кг</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">%</TH>'                               skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Масса, кг</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">%</TH>'                               skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Масса, кг</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">%</TH>'                               skip
        '</TR>'skip
        '<TR >'skip
        '<TH style="text-align: center; font-weight:bold; ">1.1</TH>'   skip
        '<TH style="text-align: center; font-weight:bold; ">1.2</TH>'   skip
        '<TH style="text-align: center; font-weight:bold; ">1.3</TH>'   skip
        '<TH style="text-align: center; font-weight:bold; ">1.4</TH>'   skip
        '<TH style="text-align: center; font-weight:bold; ">1.5</TH>'   skip
        '<TH style="text-align: center; font-weight:bold; ">1.6</TH>'   skip
        '<TH style="text-align: center; font-weight:bold; ">1.7</TH>'   skip
        '<TH style="text-align: center; font-weight:bold; ">1.8</TH>'   skip
        '<TH style="text-align: center; font-weight:bold; ">1.9</TH>'   skip
        '<TH style="text-align: center; font-weight:bold; ">1.10</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.11</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.12</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.13</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.14</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.15</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.16</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.17</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.18</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.19</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.20</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.21</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.22</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.23</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.24</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.25</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.26</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.27</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.28</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.29</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.30</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.31</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.32</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.33</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.34</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.35</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.36</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.37</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.38</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.39</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.40</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.41</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.42</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.43</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.44</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.45</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.46</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.47</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.48</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.49</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.50</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.51</TH>'  skip
        '</TR>'skip
      .
      for each tt-rep where not tt-rep.no-itog
      break
        by tt-rep.obj-code
        by tt-rep.shift-date
        by tt-rep.shift-num
        by tt-rep.col3
        by tt-rep.gds-code
        by tt-rep.col15
      :
        if not i-Itog
        then do :
          put stream sOutStr-html unformatted
            '<TR >'skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col1, "") '</TH>'   skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col2, "") '</TH>'   skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col3, "") '</TH>'   skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col4, "") '</TH>'   skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col5, "") '</TH>'   skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col6, "") '</TH>'   skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col7, "") '</TH>'   skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col8, "") '</TH>'   skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col9, "") '</TH>'   skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col10, "") '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col11, "") '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col12, "") '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col13, "") '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col14, "") '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col15, "") '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col16, "") '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col17, "") '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col18, "") '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col19, "") '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col20str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col21str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col22str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col23str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col24str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col25str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col26str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col27str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col28str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col29str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col30str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col31str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col32str + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col33, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:normal; ">' + fDec2Str(tt-rep.col33, "->>>>>>>>>>>9"  ) + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col34, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:normal; ">' + fDec2Str(tt-rep.col34, "->>>>>>>>>>>9.9") + '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; color: ' + (if tt-rep.col35 = "Есть" then "red" else "black") + '; ">' fStrNvl(tt-rep.col35, "") '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col36str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col37str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col38str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col39str + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col40, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:normal; ">' + fDec2Str(tt-rep.col40, "->>>>>>>>>>>9"  ) + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col41, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:normal; ">' + fDec2Str(tt-rep.col41, "->>>>>>>>>>>9.9") + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col42, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:normal; color: ' + (if (abs(tt-rep.col43) > tt-rep.delta-mass-qnty-ac or not tt-rep.ac-measured) then "red" else "black") + '; ">' + fDec2Str(tt-rep.col42, "->>>>>>>>>>>9.9") + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col43, "->>>>>>>>>>9.99") + '" style="text-align: center; font-weight:normal; color: ' + (if (abs(tt-rep.col43) > tt-rep.delta-mass-qnty-ac or not tt-rep.ac-measured) then "red" else "black") + '; ">' + fDec2Str(tt-rep.col43, "->>>>>>>>>>9.99") + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col44, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:normal; color: ' + (if (abs(tt-rep.col45) > 0.65 or not tt-rep.ac-measured) then "red" else "black") + '; ">' + fDec2Str(tt-rep.col44, "->>>>>>>>>>>9.9") + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col45, "->>>>>>>>>>9.99") + '" style="text-align: center; font-weight:normal; color: ' + (if (abs(tt-rep.col45) > 0.65 or not tt-rep.ac-measured) then "red" else "black") + '; ">' + fDec2Str(tt-rep.col45, "->>>>>>>>>>9.99") + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col46, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:normal; color: ' + (if abs(tt-rep.col47) > 0.65 then "red" else "black") + '; ">' + fDec2Str(tt-rep.col46, "->>>>>>>>>>>9.9") + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col47, "->>>>>>>>>>9.99") + '" style="text-align: center; font-weight:normal; color: ' + (if abs(tt-rep.col47) > 0.65 then "red" else "black") + '; ">' + fDec2Str(tt-rep.col47, "->>>>>>>>>>9.99") + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col48, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:normal; color: ' + (if (tt-rep.col48 <> 0 or not tt-rep.ac-measured) then "red" else "black") + '; ">' + fDec2Str(tt-rep.col48, "->>>>>>>>>>>9.9") + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col49, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:normal; color: ' + (if tt-rep.col49 <> 0 then "red" else "black") + '; ">' + fDec2Str(tt-rep.col49, "->>>>>>>>>>>9.9") + '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; color: ' + (if tt-rep.col50 <> "Нет" then "red" else "black") + '; ">' fStrNvl(tt-rep.col50, "") '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col51, "") '</TH>'  skip
            '</TR>'skip
          .
        end .
        if last-of(tt-rep.obj-code) then do:
          for first tt-itog where tt-itog.obj-type = tt-rep.obj-type
                              and tt-itog.obj-code = tt-rep.obj-code
          :
            put stream sOutStr-html unformatted
              '<TR >'skip
              '<TH style="text-align: center; font-weight:bold; ">Итого по:</TH>'  skip
              '<TH style="text-align: center; font-weight:bold; ">' fStrNvl(tt-itog.col1, "") '</TH>'   skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col20, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col20, "->>>>>>>>>>>9"  ) + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col21, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col21, "->>>>>>>>>>>9.9") + '</TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col24, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col24, "->>>>>>>>>>>9"  ) + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col25, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col25, "->>>>>>>>>>>9.9") + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col26, "->>>>>>>>>>9.99") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col26, "->>>>>>>>>>9.99") + '</TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col29, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col29, "->>>>>>>>>>>9"  ) + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col30, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col30, "->>>>>>>>>>>9.9") + '</TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col33, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col33, "->>>>>>>>>>>9"  ) + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col34, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col34, "->>>>>>>>>>>9.9") + '</TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col36, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col36, "->>>>>>>>>>>9"  ) + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col37, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col37, "->>>>>>>>>>>9.9") + '</TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col40, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col40, "->>>>>>>>>>>9"  ) + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col41, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col41, "->>>>>>>>>>>9.9") + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col42, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-itog.col43red then "red" else "black") + '; ">' + fDec2Str(tt-itog.col42, "->>>>>>>>>>>9.9") + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col43, "->>>>>>>>>>9.99") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-itog.col43red then "red" else "black") + '; ">' + fDec2Str(tt-itog.col43, "->>>>>>>>>>9.99") + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col44, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-itog.col45red then "red" else "black") + '; ">' + fDec2Str(tt-itog.col44, "->>>>>>>>>>>9.9") + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col45, "->>>>>>>>>>9.99") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-itog.col45red then "red" else "black") + '; ">' + fDec2Str(tt-itog.col45, "->>>>>>>>>>9.99") + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col46, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-itog.col47red then "red" else "black") + '; ">' + fDec2Str(tt-itog.col46, "->>>>>>>>>>>9.9") + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col47, "->>>>>>>>>>9.99") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-itog.col47red then "red" else "black") + '; ">' + fDec2Str(tt-itog.col47, "->>>>>>>>>>9.99") + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col48, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-itog.col48 <> 0 then "red" else "black") + '; ">' + fDec2Str(tt-itog.col48, "->>>>>>>>>>>9.9") + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col49, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-itog.col49 <> 0 then "red" else "black") + '; ">' + fDec2Str(tt-itog.col49, "->>>>>>>>>>>9.9") + '</TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '</TR>'skip
            .
          end .
        end .
      end .
      for first tt-all-itog:
        put stream sOutStr-html unformatted
          '<TR >'skip
          '<TH style="text-align: center; font-weight:bold; ">Итого по:</TH>'  skip
          '<TH style="text-align: center; font-weight:bold; ">Всем выбранным объектам</TH>'   skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col20, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col20, "->>>>>>>>>>>9"  ) + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col21, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col21, "->>>>>>>>>>>9.9") + '</TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col24, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col24, "->>>>>>>>>>>9"  ) + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col25, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col25, "->>>>>>>>>>>9.9") + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col26, "->>>>>>>>>>9.99") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col26, "->>>>>>>>>>9.99") + '</TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col29, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col29, "->>>>>>>>>>>9"  ) + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col30, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col30, "->>>>>>>>>>>9.9") + '</TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col33, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col33, "->>>>>>>>>>>9"  ) + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col34, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col34, "->>>>>>>>>>>9.9") + '</TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col36, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col36, "->>>>>>>>>>>9"  ) + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col37, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col37, "->>>>>>>>>>>9.9") + '</TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col40, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col40, "->>>>>>>>>>>9"  ) + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col41, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col41, "->>>>>>>>>>>9.9") + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col42, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-all-itog.col43red then "red" else "black") + '; ">' + fDec2Str(tt-all-itog.col42, "->>>>>>>>>>>9.9") + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col43, "->>>>>>>>>>9.99") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-all-itog.col43red then "red" else "black") + '; ">' + fDec2Str(tt-all-itog.col43, "->>>>>>>>>>9.99") + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col44, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-all-itog.col45red then "red" else "black") + '; ">' + fDec2Str(tt-all-itog.col44, "->>>>>>>>>>>9.9") + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col45, "->>>>>>>>>>9.99") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-all-itog.col45red then "red" else "black") + '; ">' + fDec2Str(tt-all-itog.col45, "->>>>>>>>>>9.99") + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col46, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-all-itog.col47red then "red" else "black") + '; ">' + fDec2Str(tt-all-itog.col46, "->>>>>>>>>>>9.9") + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col47, "->>>>>>>>>>9.99") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-all-itog.col47red then "red" else "black") + '; ">' + fDec2Str(tt-all-itog.col47, "->>>>>>>>>>9.99") + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col48, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-all-itog.col48 <> 0 then "red" else "black") + '; ">' + fDec2Str(tt-all-itog.col48, "->>>>>>>>>>>9.9") + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col49, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-all-itog.col49 <> 0 then "red" else "black") + '; ">' + fDec2Str(tt-all-itog.col49, "->>>>>>>>>>>9.9") + '</TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '</TR>'skip
        .
      end.
      put stream sOutStr-html unformatted
         '</tbody>' skip
         '</table>' skip
         '</body>' skip
         '</html>' skip
         .
      output stream sOutStr-html close.
      run prn-lib-reportviewer in this-procedure (
          input parparentproc
          ,input vFileNameRep
          ,input ""
          ) no-error.
      if error-status:error then
      do:
          message return-value view-as alert-box.
          return .
      end.
   end.
end procedure.
PROCEDURE get-report-num :
  define output parameter p-report-num as integer no-undo .
  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.
END PROCEDURE.
