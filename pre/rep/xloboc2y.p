block-level on error undo, throw.
define input  parameter x-store-code  like ub.clients.obj-code   no-undo .
define input  parameter x-store-type  like ub.clients.obj-type   no-undo .
define input  parameter x-base-type   like ub.currency.curr-abbr no-undo .
define input  parameter x-base-code   like ub.currency.curr-code no-undo .
define input  parameter xclassify     as character  no-undo .
define input  parameter xsorttype     as character  no-undo .
define input  parameter xsumsonly     as logical    no-undo .
define input  parameter xshowzero     as logical    no-undo .
define input  parameter xshowzero-2   as logical    no-undo .
define input  parameter xtog-obj      as logical    no-undo .
define input  parameter xshowcost     as logical    no-undo .
define input  parameter xshowcostnds  as logical    no-undo .
define input  parameter xshowcrsa     as logical    no-undo .
define input  parameter xshowcrsands  as logical    no-undo .
define input  parameter xshowsale     as logical    no-undo .
define input  parameter xshowsalends  as logical    no-undo .
define input  parameter xtog-lavel    as logical    no-undo .
define input  parameter xvar-lavel    as integer    no-undo .
define input  parameter xserv         as character  no-undo .
define input  parameter xshowmediator as logical    no-undo .
define input  parameter xshowsaleslt  as logical    no-undo .
define input  parameter x-vat         as logical    no-undo .
define input  parameter xlongname     as logical    no-undo .
define input  parameter x-tog-wt      as logical    no-undo .
define input  parameter x-tog-ms      as logical    no-undo .
define input  parameter p-is-petrol   as logical    no-undo .
define input  parameter xDens         as logical    no-undo .
define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Оборотная ведомость Execl".
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
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#gds-engl as logical   no-undo .
define variable vv-exch-rate  as decimal   no-undo .
define variable vv-exch-scale as decimal   no-undo .
define variable v-cntxt-host-name-obj as character no-undo .
if v-cntxt-level = 'object':U then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-cntxt-host-code-obj
  ,output v-cntxt-host-name-obj
  )  .
end.
if v-cntxt-level = 'firm':U then do:
  find first ub.clients no-lock where
             ub.clients.obj-type = 'орг':U and
             ub.clients.obj-code = v-cntxt-host-code-obj no-error .
if error-status :error then v-cntxt-host-name-obj = ? .
   else v-cntxt-host-name-obj = ub.clients.obj-name.
end.
if v-cntxt-level = 'object':U
or v-cntxt-level = 'firm':U
then do:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  base-code
  ,input  today
  ,output vv-exch-rate
  ,output vv-exch-scale
  ,output base-type
  )  .
end.
run get-report-num in my-handle ( output g#report-num ).
run get-gds-engl in my-handle ( output g#gds-engl ) .
define variable x-db-num    like ub.clients.db-num   no-undo.
define variable v-nn        as integer   no-undo .
define variable v-name-type as character no-undo .
define variable long-p      as logical   no-undo .
define work-table temp#sum-type no-undo
    field sum-type as char
    field xi as int.
define variable m         as integer no-undo.
define variable l         as integer no-undo.
define variable i-str     as integer no-undo.
define variable icolumn   as integer no-undo.
define variable ccolumn   as character no-undo.
define variable crange    as character no-undo.
define variable allcol    as int no-undo.
define variable  null-str#      as decimal  no-undo.
define variable  null-str2#     as decimal  no-undo.
define variable  b1-null-str#   as decimal  no-undo.
define variable  b1-null-str2#  as decimal  no-undo.
define variable  b2-null-str#   as decimal  no-undo.
define variable  b2-null-str2#  as decimal  no-undo.
define variable t-time   as integer  no-undo .
define variable  tprintrubl as log no-undo.
define stream  instream  .
define stream  outstream  .
define stream  outstream2  .
make-excel-com = false .
make-excel     = true  .
define stream  macr_excel .
define variable v-file-name as character no-undo .
define variable p-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable c-c      as integer no-undo .
define variable c-str    as character no-undo .
define variable str--1   as character format "x(60)" no-undo.
define variable str--2   as integer no-undo .
define variable c-i      as integer no-undo .
define variable p-var    as integer no-undo .
define variable num#col# as integer no-undo .
define variable var-1    as integer no-undo .
define variable var-2    as integer no-undo .
define variable objname        as   char no-undo.
define variable select-good    as   integer no-undo.
define variable chosedtype     as   integer no-undo.
define variable paytype        as   integer no-undo.
define variable retclassify    as   char  no-undo.
define variable retsorttype    as   char  no-undo.
define variable show-negativ   as   logical  no-undo.
define variable show-negativ-2 as   logical  no-undo.
define variable sums-only      as   logical  no-undo.
define variable valtype        as   integer no-undo.
define variable line           as   char        no-undo.
define variable firstline      as   logical     no-undo.
define variable nk as integer no-undo .
define variable lp as int no-undo.
define variable mp as int no-undo.
define variable mp-1 as int no-undo.
define variable tot_tqnty as decimal  no-undo.
define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.
define variable stat     as log no-undo .
define variable inperror as log no-undo .
define variable i        as integer no-undo .
define variable p        as integer no-undo init 0 .
define variable kk       as integer no-undo init 0 .
define variable old-page as integer no-undo .
define variable new-page as integer no-undo .
define variable rid-list as character no-undo .
define variable gds-zap-unit-base     like ub.goods.unit-base    no-undo .
define variable gds-zap-prt-root      like ub.goods.prt-root     no-undo .
define variable gds-zap-gds-name      like ub.goods.gds-name     no-undo .
define variable gds-zap-gds-long-name  as character format "x(120)" no-undo .
define variable gds-zap-prod-type     like ub.goods.prod-type    no-undo .
define variable gds-zap-prod-code     like ub.goods.prod-code    no-undo .
define variable gds-zap-artic         like ub.goods.artic        no-undo .
define variable gds-zap-b-code        like ub.bar-code.b-code    no-undo .
define variable gds-type              as char no-undo .
define variable gds-zap-type          like ub.goods.gds-type    no-undo .
define variable gds-zap-grp-name      like ub.goods.grp-name    no-undo .
define variable gds-zap-prod-name     like ub.clients.obj-name  no-undo .
define variable gds-zap-price-base    like ub.stk-tot.sum-base  no-undo .
define variable gds-zap-stoim-base    like ub.stk-tot.sum-base  no-undo .
define variable gds-zap-qnty          like ub.stk-tot.fact-qnty no-undo .
define variable gds-zap-nds           like ub.stk-tot.sum-base  no-undo .
define variable gds-zap-np            like ub.stk-tot.sum-base  no-undo .
define variable f-ostatok-start    as   char  no-undo.
define variable f-ostatok-end      as   char  no-undo.
define variable ostatok-start      as   decimal extent 13  format "->>>>>>>>>>>9.<<<" no-undo.
define variable ostatok-end        as   decimal extent 13  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b1-ostatok-start   as   decimal extent 13  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b1-ostatok-end     as   decimal extent 13  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b2-ostatok-start   as   decimal extent 13  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b2-ostatok-end     as   decimal extent 13  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bi-ostatok-start   as   decimal extent 13  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bi-ostatok-end     as   decimal extent 13  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bo-ostatok-start   as   decimal extent 13  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bo-ostatok-end     as   decimal extent 13  format "->>>>>>>>>>>9.<<<" no-undo.
define variable mediator-host-code as integer no-undo .
define variable f-flag             as logical no-undo .
define variable v-gds-num          as integer no-undo .
define variable gds-wt-base        like ub.goods.wt-base      no-undo .
define variable gds-ms-base        like ub.goods.ms-base      no-undo .
define buffer kg-obj-list for obj-list .
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
define variable  c-oborot-ie as widget-handle no-undo.
define variable  f-oborot-ie as character no-undo.
define variable    oborot-ie as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-ie as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-ie as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-ie as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-ie as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-ee as widget-handle no-undo.
define variable  f-oborot-ee as character no-undo.
define variable    oborot-ee as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-ee as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-ee as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-ee as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-ee as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-ep as widget-handle no-undo.
define variable  f-oborot-ep as character no-undo.
define variable    oborot-ep as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-ep as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-ep as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-ep as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-ep as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-es as widget-handle no-undo.
define variable  f-oborot-es as character no-undo.
define variable    oborot-es as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-es as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-es as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-es as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-es as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-re as widget-handle no-undo.
define variable  f-oborot-re as character no-undo.
define variable    oborot-re as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-re as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-re as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-re as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-re as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-rs as widget-handle no-undo.
define variable  f-oborot-rs as character no-undo.
define variable    oborot-rs as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-rs as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-rs as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-rs as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-rs as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-we as widget-handle no-undo.
define variable  f-oborot-we as character no-undo.
define variable    oborot-we as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-we as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-we as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-we as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-we as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-vt as widget-handle no-undo.
define variable  f-oborot-vt as character no-undo.
define variable    oborot-vt as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-vt as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-vt as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-vt as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-vt as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-iv as widget-handle no-undo.
define variable  f-oborot-iv as character no-undo.
define variable    oborot-iv as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-iv as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-iv as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-iv as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-iv as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-ev as widget-handle no-undo.
define variable  f-oborot-ev as character no-undo.
define variable    oborot-ev as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-ev as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-ev as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-ev as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-ev as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-rv as widget-handle no-undo.
define variable  f-oborot-rv as character no-undo.
define variable    oborot-rv as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-rv as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-rv as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-rv as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-rv as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-em as widget-handle no-undo.
define variable  f-oborot-em as character no-undo.
define variable    oborot-em as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-em as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-em as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-em as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-em as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-wm as widget-handle no-undo.
define variable  f-oborot-wm as character no-undo.
define variable    oborot-wm as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-wm as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-wm as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-wm as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-wm as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-im as widget-handle no-undo.
define variable  f-oborot-im as character no-undo.
define variable    oborot-im as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-im as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-im as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-im as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-im as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-ot as widget-handle no-undo.
define variable  f-oborot-ot as character no-undo.
define variable    oborot-ot as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-ot as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-ot as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-ot as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-ot as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-pc as widget-handle no-undo.
define variable  f-oborot-pc as character no-undo.
define variable    oborot-pc as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-pc as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-pc as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-pc as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-pc as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-ap as widget-handle no-undo.
define variable  f-oborot-ap as character no-undo.
define variable    oborot-ap as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-ap as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-ap as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-ap as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-ap as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-disc as widget-handle no-undo.
define variable  f-oborot-disc as character no-undo.
define variable    oborot-disc as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-disc as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-disc as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-disc as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-disc as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-eff as widget-handle no-undo.
define variable  f-oborot-eff as character no-undo.
define variable    oborot-eff as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-eff as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-eff as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-eff as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-eff as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-prc as widget-handle no-undo.
define variable  f-oborot-prc as character no-undo.
define variable    oborot-prc as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-prc as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-prc as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-prc as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-prc as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-sum-cost as widget-handle no-undo.
define variable  f-oborot-sum-cost as character no-undo.
define variable    oborot-sum-cost as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-sum-cost as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-sum-cost as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-sum-cost as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-sum-cost as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-sum-crsa as widget-handle no-undo.
define variable  f-oborot-sum-crsa as character no-undo.
define variable    oborot-sum-crsa as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-sum-crsa as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-sum-crsa as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-sum-crsa as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-sum-crsa as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-sum-sale as widget-handle no-undo.
define variable  f-oborot-sum-sale as character no-undo.
define variable    oborot-sum-sale as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-sum-sale as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-sum-sale as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-sum-sale as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-sum-sale as decimal   extent 13 format "->>>>>>>>>>>9.<<<":U no-undo .
  define temp-table tt-obj-list no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is primary unique obj-type obj-code
    index name obj-name
    .
function func-vat returns decimal (
    input p-gds-code as integer  ,
    input p-obj-type as character ,
    input p-obj-code as integer  ).
define variable i-vat-pc as decimal no-undo .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  p-gds-code
  ,input  '1':U
  ,input  x-Date-End
  ,input  v-cntxt-host-code-obj
  ,input  p-obj-type
  ,input  p-obj-code
  ,output i-vat-pc
  ) no-error .
if error-status :error then return 0 .
else return i-vat-pc.
end function .
def var vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable nn      as   int  no-undo.
define variable report1 as int no-undo.
define variable report2 as int no-undo.
define variable errorlevel as int no-undo.
define variable first-lavel as integer no-undo .
define variable sf1 as handle .
define variable sf2 as handle .
create editor sf1 .
create editor sf2 .
define variable  fact-order-1   like ub.stk-tot.fact-order no-undo.
define variable  quantity1      like ub.stk-tot.fact-qnty  no-undo.
define variable  coast_r1       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_v1       like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_r1         like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_v1         like ub.stk-tot.sum-rubl   no-undo.
define variable  fact-order-2   like ub.stk-tot.fact-order no-undo.
define variable  quantity2      like ub.stk-tot.fact-qnty  no-undo.
define variable  coast2         like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_r2       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_v2       like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_r2         like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_v2         like ub.stk-tot.sum-rubl   no-undo.
define variable  quantity    like ub.stk-tot.fact-qnty  no-undo.
define variable  coast       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_r     like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_v     like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_r       like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_v       like ub.stk-tot.sum-rubl   no-undo.
define variable  slt_r       like ub.stk-tot.sum-rubl   no-undo.
define variable  slt_v       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast3       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast4       like ub.stk-tot.sum-rubl   no-undo.
define variable  temp-str as char no-undo.
define variable  temp-str-2 as char no-undo.
define variable str as char format "x(60)" no-undo.
define variable i#i as int no-undo.
define variable xlavel as int  no-undo.
define variable list-field as char no-undo.
define variable str10 as char no-undo.
define variable rn as character no-undo .
  rn = "Оборотная ведомость по всем типам в excel" .
  allcol = num-entries(sizes) - 1 .
assign v-account = ( if integer( 25 ) = 0 then 100 else integer( 25 ) ).
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
IF ( i-str modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(rn)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(rn)
    .
 Assign
    v-kol-spice = (50 - LENGTH(objname)) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string(objname)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              i-str @ RecordsDone
              RecordsString   @ RecordsString
              RecordsString2  @ RecordsString2
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
 t-time = time.
     assign
        number-list    = 1
        i              = 0
        xlavel         = xvar-lavel
        select-good    = x-selectgood
        paytype        = x-set_pay_type
        retclassify    = xclassify
        retsorttype    = xsorttype
        sums-only      = xsumsonly
        show-negativ   = xshowzero
        show-negativ-2   = xshowzero-2
        x-selectobject = "".
        firstline      = false.
        valtype        = if (paytype = 1) then 0  else x-set_val_type.
  if p-is-petrol = true  then
  assign
    Select-Good  = 4
    x-SelectGood = 4
  .
    if x-vat then x-vat = false .
            else x-vat = true .
    if x-vat then v-name-type = "учет.".
    else  v-name-type = "учет-НДС".
  if  x-date-end  - x-date-start > 400
      then long-p = true    .
      else  long-p = false     .
  find first ub.gds-grp where  ub.gds-grp.upper-code = 0 no-lock no-error .
  if available ub.gds-grp then  first-lavel = ub.gds-grp.node-code.
                          else first-lavel = 0.
  valtype  = if (paytype = 1) then 0  else x-set_val_type.
  if (valtype = 0 and x-base-code = 0)  or valtype = 1
    then assign tprintrubl = yes .
    else assign tprintrubl = no .
  run make-tt-ed in this-procedure .
  run find-mediator  in this-procedure ( input v-cntxt-host-code-obj ,input xshowmediator, output mediator-host-code, output f-flag) .
  if f-flag = false then return.
        run report-execute in this-procedure .
FUNCTION n-lavel RETURNS char (INPUT grp-name as char, INPUT lavel# as int ).
define variable  str  as char format "X(60)"  no-undo.
define variable  str2 as char no-undo.
define variable v-r as character no-undo init "" .
define variable  i#i as int no-undo.
STR = "".
repeat i#i =1 to lavel#:
    if i#i =1 then str   = entry(1,grp-name, chr(47)) .
    else do:
        str2 = entry(i#i,grp-name, chr(47)) no-error.
        if not error-status:error  and str2 <> "":u then
               str = str +  chr(47) +  entry(i#i,grp-name, chr(47)) no-error .
        end.
end.
if str <> ? then do:
v-r = str + chr(47) .
end.
RETURN v-r .
END FUNCTION.
procedure report-execute :
  if (valtype=0 and x-base-code=0)  or valtype=1
                                then   assign tprintrubl = yes .
                                else   assign tprintrubl = no .
    p-file-name =  string( session:temp-directory +
                                  "rpt" + string( g#report-num ) + ".txt" ) .
    output stream outstream to value( string( session:temp-directory +
                                  "rpt" + string( g#report-num ) ) )      .
    output stream outstream2 to value(p-file-name).
    run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
    output stream macr_excel to value(v-file-name)   .
                put stream  outstream  "1" format "x(100)" skip .
    v-ind = 1    .
    num#str# = 0 .
      num#str# = num#str# + 1 .
      num#col# =  1 .
      run macr_excel_char_with_format( reportname , num#str# , num#col#  ).
      run macr_cell_format
          ( 12    ,
            true  ,
            false ,
            ?     ,
            num#str# ,
            num#col# ,
            ? ,
            ?         ) .
define variable l-ii  as integer no-undo .
define variable l-jj  as integer no-undo .
define variable l-len as integer no-undo .
define variable l-m   as integer no-undo .
v-nn = num-entries( str1 , "chr(10)"  )   .   do l-ii = 1 to v-nn  :        l-len = length (entry( l-ii , str1  , "chr(10)")) .                       l-m = integer( l-len / 220 ) + 1 .                                                      do l-jj = 1 to  l-m  :                                                                      num#str# = num#str# + 1 .                                                               run macr_excel_char_with_format(                                                                        substring(entry( l-ii , str1  , "chr(10)") , (( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .      end.                                                                                                         end.
v-nn = num-entries( str2 , "chr(10)"  )   .   do l-ii = 1 to v-nn  :        l-len = length (entry( l-ii , str2  , "chr(10)")) .                       l-m = integer( l-len / 220 ) + 1 .                                                      do l-jj = 1 to  l-m  :                                                                      num#str# = num#str# + 1 .                                                               run macr_excel_char_with_format(                                                                        substring(entry( l-ii , str2  , "chr(10)") , (( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .      end.                                                                                                         end.
v-nn = num-entries( str3 , "chr(10)"  )   .   do l-ii = 1 to v-nn  :        l-len = length (entry( l-ii , str3  , "chr(10)")) .                       l-m = integer( l-len / 220 ) + 1 .                                                      do l-jj = 1 to  l-m  :                                                                      num#str# = num#str# + 1 .                                                               run macr_excel_char_with_format(                                                                        substring(entry( l-ii , str3  , "chr(10)") , (( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .      end.                                                                                                         end.
v-nn = num-entries( str4 , "chr(10)"  )   .   do l-ii = 1 to v-nn  :        l-len = length (entry( l-ii , str4  , "chr(10)")) .                       l-m = integer( l-len / 220 ) + 1 .                                                      do l-jj = 1 to  l-m  :                                                                      num#str# = num#str# + 1 .                                                               run macr_excel_char_with_format(                                                                        substring(entry( l-ii , str4  , "chr(10)") , (( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .      end.                                                                                                         end.
v-nn = num-entries( reportheader , "chr(10)"  )   .   do l-ii = 1 to v-nn  :        l-len = length (entry( l-ii , reportheader  , "chr(10)")) .                       l-m = integer( l-len / 220 ) + 1 .                                                      do l-jj = 1 to  l-m  :                                                                      num#str# = num#str# + 1 .                                                               run macr_excel_char_with_format(                                                                        substring(entry( l-ii , reportheader  , "chr(10)") , (( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .      end.                                                                                                         end.
  num#str# = num#str# + 1.
  num#col# = 1.
  run macr_excel_char_with_format(
        cur-time-print() +
      " Цены указаны в " +
      (if tprintrubl then "РУБ" else x-base-type )
      , num#str#
      , num#col#
        ) .
define variable old-s as integer no-undo .
define variable old-s2 as integer no-undo .
assign
old-s =   num#str#
.
run make-col.
assign
old-s2 =   num#str#
.
   num#str# = old-s + 1.
   run proc-print-header.
   num#str# = old-s2.
   define variable gj as integer no-undo init 0.
   if xtog-obj  then do:
      for each obj-list no-lock:
          x-store-type = obj-list.obj-type.
          x-store-code = obj-list.obj-code.
          run report-exec1 in this-procedure .
          gj = gj + 1 .
      end.
      if gj > 1 then   run display-bo in this-procedure .
      end.
   else  run report-exec1 in this-procedure .
   output stream outstream close.
   output stream outstream2 close.
  output stream macr_excel  close .
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
    run paramls-write in this-procedure
      (input "file"
      ,input string(v-ind)
      ,input v-file-name
      ) .
  define variable v-temp-str as character no-undo .
  define variable v-ii    as integer no-undo .
  define variable v-jj    as integer no-undo .
  v-temp-str = "" .
  v-jj = 0 .
  if use-column [1] then
    assign
     v-jj = 1
    .
  repeat v-ii = 2 to 5 :
   if use-column [v-ii] then do :
      v-jj = v-jj + 1 .
      v-temp-str = v-temp-str + string(v-jj) + "," .
      end.
  end.
  v-temp-str = substring(v-temp-str , 1 , LENGTH(v-temp-str) - 1 ) .
    if v-temp-str <> "" then do:
        run paramls-write in this-procedure
        (input "charcol"
        ,input ""
        ,input v-temp-str
        ) .
   end.
  run end-proc .
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
  run rep/runexcel.p (p-file-name ).
end procedure.
procedure foreach :
define buffer buf_goods for ub.goods  .
find first  buf_goods no-lock where buf_goods.gds-code = gds-zap-b-code no-error .
  assign
    gds-zap-gds-long-name = substring ((if buf_goods.engl-name <> ? then trim(buf_goods.engl-name) else "" ) +
                          ( if buf_goods.label-name <> ? then trim(buf_goods.label-name) else ""), 1,120)
    p-price-med = 0
    i-str = i-str + 1
    null-str# = 1
    null-str2# = 1
    gds-ms-base        = if buf_goods.ms-base = ? then 0 else buf_goods.ms-base
    gds-wt-base        = if buf_goods.wt-base = ? then 0 else buf_goods.wt-base
  .
  if xshowmediator = true then do :
       run find-last-prise-med in this-procedure (
          input gds-zap-artic ,
          input gds-zap-prod-type ,
          input gds-zap-prod-code ,
          input mediator-host-code ,
          output p-price-med   )
          .
    end.
IF ( i-str modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(rn)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(rn)
    .
 Assign
    v-kol-spice = (50 - LENGTH(objname)) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string(objname)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              i-str @ RecordsDone
              RecordsString   @ RecordsString
              RecordsString2  @ RecordsString2
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
  run clear-item  in this-procedure .
run ost-line in this-procedure
               (input   x-store-code  ,
                input   x-store-type  ,
                input   gds-zap-artic     ,
                input   gds-zap-prod-code ,
                input   gds-zap-prod-type ,
                input   x-tog-shift       ,
                input   fact-order-1               ,
                input   'cost':U            ,
                input   '##,##':U    ,
                input   xtog-obj    ,
                output  quantity    ,
                output  coast_r     ,
                output  coast_v     ,
                output  vat_r       ,
                output  vat_v       ,
                output  slt_r       ,
                output  slt_v       ).
assign
  ostatok-start [1 + 0]   = quantity
 ostatok-start [2 + 0]   = if tprintrubl then coast_r else coast_v
 ostatok-start [3 + 0]   = if tprintrubl then vat_r   else vat_v
 b1-ostatok-start [1 + 0] =  b1-ostatok-start [1 + 0] + ostatok-start [1 + 0]
 b1-ostatok-start [2 + 0] =  b1-ostatok-start [2 + 0] + ostatok-start [2 + 0]
 b1-ostatok-start [3 + 0] =  b1-ostatok-start [3 + 0] + ostatok-start [3 + 0]
 b2-ostatok-start [1 + 0] =  b2-ostatok-start [1 + 0] + ostatok-start [1 + 0]
 b2-ostatok-start [2 + 0] =  b2-ostatok-start [2 + 0] + ostatok-start [2 + 0]
 b2-ostatok-start [3 + 0] =  b2-ostatok-start [3 + 0] + ostatok-start [3 + 0]
 .
 assign
  bi-ostatok-start [1 + 0] =  bi-ostatok-start [1 + 0] + ostatok-start [1 + 0]
  bi-ostatok-start [2 + 0] =  bi-ostatok-start [2 + 0] + ostatok-start [2 + 0]
  bi-ostatok-start [3 + 0] =  bi-ostatok-start [3 + 0] + ostatok-start [3 + 0]
 .
  if p-is-petrol then do:
quantity = 0 .
for each kg-obj-list no-lock
   where xtog-obj = false
      or (kg-obj-list.obj-type = x-store-type and kg-obj-list.obj-code = x-store-code )
      :
    run ost-line-kg in this-procedure
     (input   kg-obj-list.obj-code  ,
      input   kg-obj-list.obj-type  ,
      input   gds-zap-artic     ,
      input   gds-zap-prod-code ,
      input   gds-zap-prod-type ,
      input   fact-order-1               ,
      output  quantity    ) .
assign
  ostatok-start [11]   = ostatok-start [11] +  quantity
 b1-ostatok-start [11] =  b1-ostatok-start [11] + quantity
 b2-ostatok-start [11] =  b2-ostatok-start [11] + quantity
 bo-ostatok-start [11] =  bo-ostatok-start [11] + quantity
 .
 assign
  bi-ostatok-start [11] =  bi-ostatok-start [11] + quantity
 .
end.
  end.
if xshowcrsa or xshowcrsands or use-column[23] or use-column[24] or xshowmediator then do:
run ost-line in this-procedure
               (input   x-store-code  ,
                input   x-store-type  ,
                input   gds-zap-artic     ,
                input   gds-zap-prod-code ,
                input   gds-zap-prod-type ,
                input   x-tog-shift       ,
                input   fact-order-1               ,
                input   'crsa':U            ,
                input   '##,##':U    ,
                input   xtog-obj    ,
                output  quantity    ,
                output  coast_r     ,
                output  coast_v     ,
                output  vat_r       ,
                output  vat_v       ,
                output  slt_r       ,
                output  slt_v       ).
assign
  ostatok-start [4]        = round(ostatok-start [1] *  p-price-med , 2)
 ostatok-start [2 + 3]   = if tprintrubl then coast_r else coast_v
 ostatok-start [3 + 3]   = if tprintrubl then vat_r   else vat_v
 b1-ostatok-start [1 + 3] =  b1-ostatok-start [1 + 3] + ostatok-start [1 + 3]
 b1-ostatok-start [2 + 3] =  b1-ostatok-start [2 + 3] + ostatok-start [2 + 3]
 b1-ostatok-start [3 + 3] =  b1-ostatok-start [3 + 3] + ostatok-start [3 + 3]
 b2-ostatok-start [1 + 3] =  b2-ostatok-start [1 + 3] + ostatok-start [1 + 3]
 b2-ostatok-start [2 + 3] =  b2-ostatok-start [2 + 3] + ostatok-start [2 + 3]
 b2-ostatok-start [3 + 3] =  b2-ostatok-start [3 + 3] + ostatok-start [3 + 3]
 .
 assign
  bi-ostatok-start [1 + 3] =  bi-ostatok-start [1 + 3] + ostatok-start [1 + 3]
  bi-ostatok-start [2 + 3] =  bi-ostatok-start [2 + 3] + ostatok-start [2 + 3]
  bi-ostatok-start [3 + 3] =  bi-ostatok-start [3 + 3] + ostatok-start [3 + 3]
 .
   end.
if xshowsale or xshowsalends or xshowsaleslt then do:
run ost-line in this-procedure
               (input   x-store-code  ,
                input   x-store-type  ,
                input   gds-zap-artic     ,
                input   gds-zap-prod-code ,
                input   gds-zap-prod-type ,
                input   x-tog-shift       ,
                input   fact-order-1               ,
                input   'crsa':U            ,
                input   '##,##':U    ,
                input   xtog-obj    ,
                output  quantity    ,
                output  coast_r     ,
                output  coast_v     ,
                output  vat_r       ,
                output  vat_v       ,
                output  slt_r       ,
                output  slt_v       ).
assign
  ostatok-start [1 + 6]   = quantity
 ostatok-start [2 + 6]   = if tprintrubl then coast_r else coast_v
 ostatok-start [3 + 6]   = if tprintrubl then vat_r   else vat_v
 ostatok-start [10]        = if tprintrubl then slt_r   else slt_v
 b1-ostatok-start [1 + 6] =  b1-ostatok-start [1 + 6] + ostatok-start [1 + 6]
 b1-ostatok-start [2 + 6] =  b1-ostatok-start [2 + 6] + ostatok-start [2 + 6]
 b1-ostatok-start [3 + 6] =  b1-ostatok-start [3 + 6] + ostatok-start [3 + 6]
 b2-ostatok-start [1 + 6] =  b2-ostatok-start [1 + 6] + ostatok-start [1 + 6]
 b2-ostatok-start [2 + 6] =  b2-ostatok-start [2 + 6] + ostatok-start [2 + 6]
 b2-ostatok-start [3 + 6] =  b2-ostatok-start [3 + 6] + ostatok-start [3 + 6]
 b1-ostatok-start [10] =  b1-ostatok-start [10] + ostatok-start [10]
 b2-ostatok-start [10] =  b2-ostatok-start [10] + ostatok-start [10]
 .
 assign
  bi-ostatok-start [1 + 6] =  bi-ostatok-start [1 + 6] + ostatok-start [1 + 6]
  bi-ostatok-start [2 + 6] =  bi-ostatok-start [2 + 6] + ostatok-start [2 + 6]
  bi-ostatok-start [3 + 6] =  bi-ostatok-start [3 + 6] + ostatok-start [3 + 6]
  bi-ostatok-start [10] =  bi-ostatok-start [10] + ostatok-start [10]
 .
   end.
run ost-line in this-procedure
               (input   x-store-code  ,
                input   x-store-type  ,
                input   gds-zap-artic     ,
                input   gds-zap-prod-code ,
                input   gds-zap-prod-type ,
                input   x-tog-shift       ,
                input   fact-order-2               ,
                input   'cost':U            ,
                input   '##,##':U    ,
                input   xtog-obj    ,
                output  quantity    ,
                output  coast_r     ,
                output  coast_v     ,
                output  vat_r       ,
                output  vat_v       ,
                output  slt_r       ,
                output  slt_v       ).
assign
  ostatok-end [1 + 0]   = quantity
 ostatok-end [2 + 0]   = if tprintrubl then coast_r else coast_v
 ostatok-end [3 + 0]   = if tprintrubl then vat_r   else vat_v
 b1-ostatok-end [1 + 0] =  b1-ostatok-end [1 + 0] + ostatok-end [1 + 0]
 b1-ostatok-end [2 + 0] =  b1-ostatok-end [2 + 0] + ostatok-end [2 + 0]
 b1-ostatok-end [3 + 0] =  b1-ostatok-end [3 + 0] + ostatok-end [3 + 0]
 b2-ostatok-end [1 + 0] =  b2-ostatok-end [1 + 0] + ostatok-end [1 + 0]
 b2-ostatok-end [2 + 0] =  b2-ostatok-end [2 + 0] + ostatok-end [2 + 0]
 b2-ostatok-end [3 + 0] =  b2-ostatok-end [3 + 0] + ostatok-end [3 + 0]
 .
 assign
  bi-ostatok-end [1 + 0] =  bi-ostatok-end [1 + 0] + ostatok-end [1 + 0]
  bi-ostatok-end [2 + 0] =  bi-ostatok-end [2 + 0] + ostatok-end [2 + 0]
  bi-ostatok-end [3 + 0] =  bi-ostatok-end [3 + 0] + ostatok-end [3 + 0]
 .
    if p-is-petrol then do:
quantity = 0 .
for each kg-obj-list no-lock
   where xtog-obj = false
      or (kg-obj-list.obj-type = x-store-type and kg-obj-list.obj-code = x-store-code )
      :
    run ost-line-kg in this-procedure
     (input   kg-obj-list.obj-code  ,
      input   kg-obj-list.obj-type  ,
      input   gds-zap-artic     ,
      input   gds-zap-prod-code ,
      input   gds-zap-prod-type ,
      input   fact-order-2               ,
      output  quantity    ) .
assign
  ostatok-end [11]   = ostatok-end [11] +  quantity
 b1-ostatok-end [11] =  b1-ostatok-end [11] + quantity
 b2-ostatok-end [11] =  b2-ostatok-end [11] + quantity
 bo-ostatok-end [11] =  bo-ostatok-end [11] + quantity
 .
 assign
  bi-ostatok-end [11] =  bi-ostatok-end [11] + quantity
 .
end.
    end.
if xshowcrsa or xshowcrsands or use-column[23] or use-column[24]  or xshowmediator then do:
run ost-line in this-procedure
               (input   x-store-code  ,
                input   x-store-type  ,
                input   gds-zap-artic     ,
                input   gds-zap-prod-code ,
                input   gds-zap-prod-type ,
                input   x-tog-shift       ,
                input   fact-order-2               ,
                input   'crsa':U            ,
                input   '##,##':U    ,
                input   xtog-obj    ,
                output  quantity    ,
                output  coast_r     ,
                output  coast_v     ,
                output  vat_r       ,
                output  vat_v       ,
                output  slt_r       ,
                output  slt_v       ).
assign
  ostatok-end [4]        = round(ostatok-end [1] *  p-price-med , 2)
 ostatok-end [2 + 3]   = if tprintrubl then coast_r else coast_v
 ostatok-end [3 + 3]   = if tprintrubl then vat_r   else vat_v
 b1-ostatok-end [1 + 3] =  b1-ostatok-end [1 + 3] + ostatok-end [1 + 3]
 b1-ostatok-end [2 + 3] =  b1-ostatok-end [2 + 3] + ostatok-end [2 + 3]
 b1-ostatok-end [3 + 3] =  b1-ostatok-end [3 + 3] + ostatok-end [3 + 3]
 b2-ostatok-end [1 + 3] =  b2-ostatok-end [1 + 3] + ostatok-end [1 + 3]
 b2-ostatok-end [2 + 3] =  b2-ostatok-end [2 + 3] + ostatok-end [2 + 3]
 b2-ostatok-end [3 + 3] =  b2-ostatok-end [3 + 3] + ostatok-end [3 + 3]
 .
 assign
  bi-ostatok-end [1 + 3] =  bi-ostatok-end [1 + 3] + ostatok-end [1 + 3]
  bi-ostatok-end [2 + 3] =  bi-ostatok-end [2 + 3] + ostatok-end [2 + 3]
  bi-ostatok-end [3 + 3] =  bi-ostatok-end [3 + 3] + ostatok-end [3 + 3]
 .
   end.
if xshowsale or xshowsalends or xshowsaleslt then do:
run ost-line in this-procedure
               (input   x-store-code  ,
                input   x-store-type  ,
                input   gds-zap-artic     ,
                input   gds-zap-prod-code ,
                input   gds-zap-prod-type ,
                input   x-tog-shift       ,
                input   fact-order-2               ,
                input   'crsa':U            ,
                input   '##,##':U    ,
                input   xtog-obj    ,
                output  quantity    ,
                output  coast_r     ,
                output  coast_v     ,
                output  vat_r       ,
                output  vat_v       ,
                output  slt_r       ,
                output  slt_v       ).
assign
  ostatok-end [1 + 6]   = quantity
 ostatok-end [2 + 6]   = if tprintrubl then coast_r else coast_v
 ostatok-end [3 + 6]   = if tprintrubl then vat_r   else vat_v
 ostatok-end [10]        = if tprintrubl then slt_r   else slt_v
 b1-ostatok-end [1 + 6] =  b1-ostatok-end [1 + 6] + ostatok-end [1 + 6]
 b1-ostatok-end [2 + 6] =  b1-ostatok-end [2 + 6] + ostatok-end [2 + 6]
 b1-ostatok-end [3 + 6] =  b1-ostatok-end [3 + 6] + ostatok-end [3 + 6]
 b2-ostatok-end [1 + 6] =  b2-ostatok-end [1 + 6] + ostatok-end [1 + 6]
 b2-ostatok-end [2 + 6] =  b2-ostatok-end [2 + 6] + ostatok-end [2 + 6]
 b2-ostatok-end [3 + 6] =  b2-ostatok-end [3 + 6] + ostatok-end [3 + 6]
 b1-ostatok-end [10] =  b1-ostatok-end [10] + ostatok-end [10]
 b2-ostatok-end [10] =  b2-ostatok-end [10] + ostatok-end [10]
 .
 assign
  bi-ostatok-end [1 + 6] =  bi-ostatok-end [1 + 6] + ostatok-end [1 + 6]
  bi-ostatok-end [2 + 6] =  bi-ostatok-end [2 + 6] + ostatok-end [2 + 6]
  bi-ostatok-end [3 + 6] =  bi-ostatok-end [3 + 6] + ostatok-end [3 + 6]
  bi-ostatok-end [10] =  bi-ostatok-end [10] + ostatok-end [10]
 .
   end.
   if gds-zap-type = 'т':U then
run ob-line  in this-procedure (
input x-store-code ,
input x-store-type ,
input gds-zap-artic ,
input gds-zap-prod-code ,
input gds-zap-prod-type ,
input fact-order-1 ,
input fact-order-2 ,
input 'cost':U ,
input '##,##':U,
input '' ,
input xtog-obj) .
                                  else
run ob-line  in this-procedure (
input x-store-code ,
input x-store-type ,
input gds-zap-artic ,
input gds-zap-prod-code ,
input gds-zap-prod-type ,
input fact-order-1 ,
input fact-order-2 ,
input 'cssr':U ,
input '##,##':U,
input '' ,
input xtog-obj) .
   run calc-sub-itog  in this-procedure (0).
   if xshowcrsa or xshowcrsands or use-column[23] or use-column[24]  or xshowmediator   then do:
      if gds-zap-type = 'т':U  then
run ob-line  in this-procedure (
input x-store-code ,
input x-store-type ,
input gds-zap-artic ,
input gds-zap-prod-code ,
input gds-zap-prod-type ,
input fact-order-1 ,
input fact-order-2 ,
input 'crsa':U ,
input '##,##':U,
input '' ,
input xtog-obj) .
                                      else
run ob-line  in this-procedure (
input x-store-code ,
input x-store-type ,
input gds-zap-artic ,
input gds-zap-prod-code ,
input gds-zap-prod-type ,
input fact-order-1 ,
input fact-order-2 ,
input 'cgsr':U ,
input '##,##':U,
input '' ,
input xtog-obj) .
     run calc-sub-itog in this-procedure  (3).
  end.
   if xshowsale or xshowsalends
      or use-column[21] or use-column[23] or use-column[24]   or xshowmediator  then do:
      if gds-zap-type = 'т':U  then
run ob-line  in this-procedure (
input x-store-code ,
input x-store-type ,
input gds-zap-artic ,
input gds-zap-prod-code ,
input gds-zap-prod-type ,
input fact-order-1 ,
input fact-order-2 ,
input 'sale':U ,
input '##,##':U,
input '' ,
input xtog-obj) .
                                      else
run ob-line  in this-procedure (
input x-store-code ,
input x-store-type ,
input gds-zap-artic ,
input gds-zap-prod-code ,
input gds-zap-prod-type ,
input fact-order-1 ,
input fact-order-2 ,
input 'sasr':U ,
input '##,##':U,
input '' ,
input xtog-obj) .
     run calc-sub-itog in this-procedure  (6).
  end.
    if not show-negativ then  run null-str-pr in this-procedure .
    if not show-negativ-2 then  run null-str-pr2  in this-procedure .
if x-tog-wt then do :
    run calc-ms-wt in this-procedure ( input ostatok-start[1]                                     , input gds-wt-base                                     , input-output    ostatok-start[11]                                     , input-output bi-ostatok-start[11]                                     , input-output bo-ostatok-start[11]                                     , input-output b1-ostatok-start[11]                                     , input-output b2-ostatok-start[11]                                     ) .
    run calc-ms-wt in this-procedure ( input ostatok-end[1]                                     , input gds-wt-base                                     , input-output    ostatok-end[11]                                     , input-output bi-ostatok-end[11]                                     , input-output bo-ostatok-end[11]                                     , input-output b1-ostatok-end[11]                                     , input-output b2-ostatok-end[11]                                     ) .
    run calc-ms-wt in this-procedure ( input oborot-ie[1]                                     , input gds-wt-base                                     , input-output    oborot-ie[11]                                     , input-output bi-oborot-ie[11]                                     , input-output bo-oborot-ie[11]                                     , input-output b1-oborot-ie[11]                                     , input-output b2-oborot-ie[11]                                     ) .
  run calc-pt-ob in this-procedure ( input 'ie' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-ie[11] , input-output bi-oborot-ie[11] , input-output bo-oborot-ie[11] , input-output b1-oborot-ie[11] , input-output b2-oborot-ie[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-ee[1]                                     , input gds-wt-base                                     , input-output    oborot-ee[11]                                     , input-output bi-oborot-ee[11]                                     , input-output bo-oborot-ee[11]                                     , input-output b1-oborot-ee[11]                                     , input-output b2-oborot-ee[11]                                     ) .
  run calc-pt-ob in this-procedure ( input 'ee' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-ee[11] , input-output bi-oborot-ee[11] , input-output bo-oborot-ee[11] , input-output b1-oborot-ee[11] , input-output b2-oborot-ee[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-ep[1]                                     , input gds-wt-base                                     , input-output    oborot-ep[11]                                     , input-output bi-oborot-ep[11]                                     , input-output bo-oborot-ep[11]                                     , input-output b1-oborot-ep[11]                                     , input-output b2-oborot-ep[11]                                     ) .
  run calc-pt-ob in this-procedure ( input 'ep' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-ep[11] , input-output bi-oborot-ep[11] , input-output bo-oborot-ep[11] , input-output b1-oborot-ep[11] , input-output b2-oborot-ep[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-es[1]                                     , input gds-wt-base                                     , input-output    oborot-es[11]                                     , input-output bi-oborot-es[11]                                     , input-output bo-oborot-es[11]                                     , input-output b1-oborot-es[11]                                     , input-output b2-oborot-es[11]                                     ) .
  run calc-pt-ob in this-procedure ( input 'es' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-es[11] , input-output bi-oborot-es[11] , input-output bo-oborot-es[11] , input-output b1-oborot-es[11] , input-output b2-oborot-es[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-re[1]                                     , input gds-wt-base                                     , input-output    oborot-re[11]                                     , input-output bi-oborot-re[11]                                     , input-output bo-oborot-re[11]                                     , input-output b1-oborot-re[11]                                     , input-output b2-oborot-re[11]                                     ) .
  run calc-pt-ob in this-procedure ( input 're' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-re[11] , input-output bi-oborot-re[11] , input-output bo-oborot-re[11] , input-output b1-oborot-re[11] , input-output b2-oborot-re[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-rs[1]                                     , input gds-wt-base                                     , input-output    oborot-rs[11]                                     , input-output bi-oborot-rs[11]                                     , input-output bo-oborot-rs[11]                                     , input-output b1-oborot-rs[11]                                     , input-output b2-oborot-rs[11]                                     ) .
  run calc-pt-ob in this-procedure ( input 'rs' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-rs[11] , input-output bi-oborot-rs[11] , input-output bo-oborot-rs[11] , input-output b1-oborot-rs[11] , input-output b2-oborot-rs[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-we[1]                                     , input gds-wt-base                                     , input-output    oborot-we[11]                                     , input-output bi-oborot-we[11]                                     , input-output bo-oborot-we[11]                                     , input-output b1-oborot-we[11]                                     , input-output b2-oborot-we[11]                                     ) .
  run calc-pt-ob in this-procedure ( input 'we' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-we[11] , input-output bi-oborot-we[11] , input-output bo-oborot-we[11] , input-output b1-oborot-we[11] , input-output b2-oborot-we[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-vt[1]                                     , input gds-wt-base                                     , input-output    oborot-vt[11]                                     , input-output bi-oborot-vt[11]                                     , input-output bo-oborot-vt[11]                                     , input-output b1-oborot-vt[11]                                     , input-output b2-oborot-vt[11]                                     ) .
  run calc-pt-ob in this-procedure ( input 'vt' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-vt[11] , input-output bi-oborot-vt[11] , input-output bo-oborot-vt[11] , input-output b1-oborot-vt[11] , input-output b2-oborot-vt[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-iv[1]                                     , input gds-wt-base                                     , input-output    oborot-iv[11]                                     , input-output bi-oborot-iv[11]                                     , input-output bo-oborot-iv[11]                                     , input-output b1-oborot-iv[11]                                     , input-output b2-oborot-iv[11]                                     ) .
  run calc-pt-ob in this-procedure ( input 'iv' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-iv[11] , input-output bi-oborot-iv[11] , input-output bo-oborot-iv[11] , input-output b1-oborot-iv[11] , input-output b2-oborot-iv[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-ev[1]                                     , input gds-wt-base                                     , input-output    oborot-ev[11]                                     , input-output bi-oborot-ev[11]                                     , input-output bo-oborot-ev[11]                                     , input-output b1-oborot-ev[11]                                     , input-output b2-oborot-ev[11]                                     ) .
  run calc-pt-ob in this-procedure ( input 'ev' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-ev[11] , input-output bi-oborot-ev[11] , input-output bo-oborot-ev[11] , input-output b1-oborot-ev[11] , input-output b2-oborot-ev[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-rv[1]                                     , input gds-wt-base                                     , input-output    oborot-rv[11]                                     , input-output bi-oborot-rv[11]                                     , input-output bo-oborot-rv[11]                                     , input-output b1-oborot-rv[11]                                     , input-output b2-oborot-rv[11]                                     ) .
  run calc-pt-ob in this-procedure ( input 'rv' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-rv[11] , input-output bi-oborot-rv[11] , input-output bo-oborot-rv[11] , input-output b1-oborot-rv[11] , input-output b2-oborot-rv[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-em[1]                                     , input gds-wt-base                                     , input-output    oborot-em[11]                                     , input-output bi-oborot-em[11]                                     , input-output bo-oborot-em[11]                                     , input-output b1-oborot-em[11]                                     , input-output b2-oborot-em[11]                                     ) .
  run calc-pt-ob in this-procedure ( input 'em' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-em[11] , input-output bi-oborot-em[11] , input-output bo-oborot-em[11] , input-output b1-oborot-em[11] , input-output b2-oborot-em[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-im[1]                                     , input gds-wt-base                                     , input-output    oborot-im[11]                                     , input-output bi-oborot-im[11]                                     , input-output bo-oborot-im[11]                                     , input-output b1-oborot-im[11]                                     , input-output b2-oborot-im[11]                                     ) .
  run calc-pt-ob in this-procedure ( input 'im' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-im[11] , input-output bi-oborot-im[11] , input-output bo-oborot-im[11] , input-output b1-oborot-im[11] , input-output b2-oborot-im[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-ot[1]                                     , input gds-wt-base                                     , input-output    oborot-ot[11]                                     , input-output bi-oborot-ot[11]                                     , input-output bo-oborot-ot[11]                                     , input-output b1-oborot-ot[11]                                     , input-output b2-oborot-ot[11]                                     ) .
  run calc-pt-ob in this-procedure ( input 'ot' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-ot[11] , input-output bi-oborot-ot[11] , input-output bo-oborot-ot[11] , input-output b1-oborot-ot[11] , input-output b2-oborot-ot[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-ap[1]                                     , input gds-wt-base                                     , input-output    oborot-ap[11]                                     , input-output bi-oborot-ap[11]                                     , input-output bo-oborot-ap[11]                                     , input-output b1-oborot-ap[11]                                     , input-output b2-oborot-ap[11]                                     ) .
  run calc-pt-ob in this-procedure ( input 'ap' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-ap[11] , input-output bi-oborot-ap[11] , input-output bo-oborot-ap[11] , input-output b1-oborot-ap[11] , input-output b2-oborot-ap[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-pc[1]                                     , input gds-wt-base                                     , input-output    oborot-pc[11]                                     , input-output bi-oborot-pc[11]                                     , input-output bo-oborot-pc[11]                                     , input-output b1-oborot-pc[11]                                     , input-output b2-oborot-pc[11]                                     ) .
  run calc-pt-ob in this-procedure ( input 'pc' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-pc[11] , input-output bi-oborot-pc[11] , input-output bo-oborot-pc[11] , input-output b1-oborot-pc[11] , input-output b2-oborot-pc[11] ) .
end.
if x-tog-ms then do :
    run calc-ms-wt in this-procedure ( input ostatok-start[1]                                     , input gds-ms-base                                     , input-output    ostatok-start[12]                                     , input-output bi-ostatok-start[12]                                     , input-output bo-ostatok-start[12]                                     , input-output b1-ostatok-start[12]                                     , input-output b2-ostatok-start[12]                                     ) .
    run calc-ms-wt in this-procedure ( input ostatok-end[1]                                     , input gds-ms-base                                     , input-output    ostatok-end[12]                                     , input-output bi-ostatok-end[12]                                     , input-output bo-ostatok-end[12]                                     , input-output b1-ostatok-end[12]                                     , input-output b2-ostatok-end[12]                                     ) .
    run calc-ms-wt in this-procedure ( input oborot-ie[1]                                     , input gds-ms-base                                     , input-output    oborot-ie[12]                                     , input-output bi-oborot-ie[12]                                     , input-output bo-oborot-ie[12]                                     , input-output b1-oborot-ie[12]                                     , input-output b2-oborot-ie[12]                                     ) .
    run calc-ms-wt in this-procedure ( input oborot-ee[1]                                     , input gds-ms-base                                     , input-output    oborot-ee[12]                                     , input-output bi-oborot-ee[12]                                     , input-output bo-oborot-ee[12]                                     , input-output b1-oborot-ee[12]                                     , input-output b2-oborot-ee[12]                                     ) .
    run calc-ms-wt in this-procedure ( input oborot-ep[1]                                     , input gds-ms-base                                     , input-output    oborot-ep[12]                                     , input-output bi-oborot-ep[12]                                     , input-output bo-oborot-ep[12]                                     , input-output b1-oborot-ep[12]                                     , input-output b2-oborot-ep[12]                                     ) .
    run calc-ms-wt in this-procedure ( input oborot-es[1]                                     , input gds-ms-base                                     , input-output    oborot-es[12]                                     , input-output bi-oborot-es[12]                                     , input-output bo-oborot-es[12]                                     , input-output b1-oborot-es[12]                                     , input-output b2-oborot-es[12]                                     ) .
    run calc-ms-wt in this-procedure ( input oborot-re[1]                                     , input gds-ms-base                                     , input-output    oborot-re[12]                                     , input-output bi-oborot-re[12]                                     , input-output bo-oborot-re[12]                                     , input-output b1-oborot-re[12]                                     , input-output b2-oborot-re[12]                                     ) .
    run calc-ms-wt in this-procedure ( input oborot-rs[1]                                     , input gds-ms-base                                     , input-output    oborot-rs[12]                                     , input-output bi-oborot-rs[12]                                     , input-output bo-oborot-rs[12]                                     , input-output b1-oborot-rs[12]                                     , input-output b2-oborot-rs[12]                                     ) .
    run calc-ms-wt in this-procedure ( input oborot-we[1]                                     , input gds-ms-base                                     , input-output    oborot-we[12]                                     , input-output bi-oborot-we[12]                                     , input-output bo-oborot-we[12]                                     , input-output b1-oborot-we[12]                                     , input-output b2-oborot-we[12]                                     ) .
    run calc-ms-wt in this-procedure ( input oborot-vt[1]                                     , input gds-ms-base                                     , input-output    oborot-vt[12]                                     , input-output bi-oborot-vt[12]                                     , input-output bo-oborot-vt[12]                                     , input-output b1-oborot-vt[12]                                     , input-output b2-oborot-vt[12]                                     ) .
    run calc-ms-wt in this-procedure ( input oborot-iv[1]                                     , input gds-ms-base                                     , input-output    oborot-iv[12]                                     , input-output bi-oborot-iv[12]                                     , input-output bo-oborot-iv[12]                                     , input-output b1-oborot-iv[12]                                     , input-output b2-oborot-iv[12]                                     ) .
    run calc-ms-wt in this-procedure ( input oborot-ev[1]                                     , input gds-ms-base                                     , input-output    oborot-ev[12]                                     , input-output bi-oborot-ev[12]                                     , input-output bo-oborot-ev[12]                                     , input-output b1-oborot-ev[12]                                     , input-output b2-oborot-ev[12]                                     ) .
    run calc-ms-wt in this-procedure ( input oborot-rv[1]                                     , input gds-ms-base                                     , input-output    oborot-rv[12]                                     , input-output bi-oborot-rv[12]                                     , input-output bo-oborot-rv[12]                                     , input-output b1-oborot-rv[12]                                     , input-output b2-oborot-rv[12]                                     ) .
    run calc-ms-wt in this-procedure ( input oborot-em[1]                                     , input gds-ms-base                                     , input-output    oborot-em[12]                                     , input-output bi-oborot-em[12]                                     , input-output bo-oborot-em[12]                                     , input-output b1-oborot-em[12]                                     , input-output b2-oborot-em[12]                                     ) .
    run calc-ms-wt in this-procedure ( input oborot-im[1]                                     , input gds-ms-base                                     , input-output    oborot-im[12]                                     , input-output bi-oborot-im[12]                                     , input-output bo-oborot-im[12]                                     , input-output b1-oborot-im[12]                                     , input-output b2-oborot-im[12]                                     ) .
    run calc-ms-wt in this-procedure ( input oborot-ot[1]                                     , input gds-ms-base                                     , input-output    oborot-ot[12]                                     , input-output bi-oborot-ot[12]                                     , input-output bo-oborot-ot[12]                                     , input-output b1-oborot-ot[12]                                     , input-output b2-oborot-ot[12]                                     ) .
    run calc-ms-wt in this-procedure ( input oborot-ap[1]                                     , input gds-ms-base                                     , input-output    oborot-ap[12]                                     , input-output bi-oborot-ap[12]                                     , input-output bo-oborot-ap[12]                                     , input-output b1-oborot-ap[12]                                     , input-output b2-oborot-ap[12]                                     ) .
    run calc-ms-wt in this-procedure ( input oborot-pc[1]                                     , input gds-ms-base                                     , input-output    oborot-pc[12]                                     , input-output bi-oborot-pc[12]                                     , input-output bo-oborot-pc[12]                                     , input-output b1-oborot-pc[12]                                     , input-output b2-oborot-pc[12]                                     ) .
end.
if xDens then do :
      run calc-dens in this-procedure ( input ostatok-start[1]                                     , input ostatok-start[11]                                     , input-output    ostatok-start[13]                                     , input-output bi-ostatok-start[13]                                     , input-output bo-ostatok-start[13]                                     , input-output b1-ostatok-start[13]                                     , input-output b2-ostatok-start[13]                                     ) .
    run calc-dens in this-procedure ( input ostatok-end[1]                                     , input ostatok-end[11]                                     , input-output    ostatok-end[13]                                     , input-output bi-ostatok-end[13]                                     , input-output bo-ostatok-end[13]                                     , input-output b1-ostatok-end[13]                                     , input-output b2-ostatok-end[13]                                     ) .
    run calc-density in this-procedure ( input 'ie' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-ie[13] , input-output bi-oborot-ie[13] , input-output bo-oborot-ie[13] , input-output b1-oborot-ie[13] , input-output b2-oborot-ie[13] ) .
    run calc-density in this-procedure ( input 'ee' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-ee[13] , input-output bi-oborot-ee[13] , input-output bo-oborot-ee[13] , input-output b1-oborot-ee[13] , input-output b2-oborot-ee[13] ) .
    run calc-density in this-procedure ( input 'ep' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-ep[13] , input-output bi-oborot-ep[13] , input-output bo-oborot-ep[13] , input-output b1-oborot-ep[13] , input-output b2-oborot-ep[13] ) .
    run calc-density in this-procedure ( input 'es' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-es[13] , input-output bi-oborot-es[13] , input-output bo-oborot-es[13] , input-output b1-oborot-es[13] , input-output b2-oborot-es[13] ) .
    run calc-density in this-procedure ( input 're' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-re[13] , input-output bi-oborot-re[13] , input-output bo-oborot-re[13] , input-output b1-oborot-re[13] , input-output b2-oborot-re[13] ) .
    run calc-density in this-procedure ( input 'rs' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-rs[13] , input-output bi-oborot-rs[13] , input-output bo-oborot-rs[13] , input-output b1-oborot-rs[13] , input-output b2-oborot-rs[13] ) .
    run calc-density in this-procedure ( input 'we' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-we[13] , input-output bi-oborot-we[13] , input-output bo-oborot-we[13] , input-output b1-oborot-we[13] , input-output b2-oborot-we[13] ) .
    run calc-density in this-procedure ( input 'vt' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-vt[13] , input-output bi-oborot-vt[13] , input-output bo-oborot-vt[13] , input-output b1-oborot-vt[13] , input-output b2-oborot-vt[13] ) .
    run calc-density in this-procedure ( input 'iv' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-iv[13] , input-output bi-oborot-iv[13] , input-output bo-oborot-iv[13] , input-output b1-oborot-iv[13] , input-output b2-oborot-iv[13] ) .
    run calc-density in this-procedure ( input 'ev' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-ev[13] , input-output bi-oborot-ev[13] , input-output bo-oborot-ev[13] , input-output b1-oborot-ev[13] , input-output b2-oborot-ev[13] ) .
    run calc-density in this-procedure ( input 'rv' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-rv[13] , input-output bi-oborot-rv[13] , input-output bo-oborot-rv[13] , input-output b1-oborot-rv[13] , input-output b2-oborot-rv[13] ) .
    run calc-density in this-procedure ( input 'em' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-em[13] , input-output bi-oborot-em[13] , input-output bo-oborot-em[13] , input-output b1-oborot-em[13] , input-output b2-oborot-em[13] ) .
    run calc-density in this-procedure ( input 'im' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-im[13] , input-output bi-oborot-im[13] , input-output bo-oborot-im[13] , input-output b1-oborot-im[13] , input-output b2-oborot-im[13] ) .
    run calc-density in this-procedure ( input 'ot' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-ot[13] , input-output bi-oborot-ot[13] , input-output bo-oborot-ot[13] , input-output b1-oborot-ot[13] , input-output b2-oborot-ot[13] ) .
    run calc-density in this-procedure ( input 'ap' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-ap[13] , input-output bi-oborot-ap[13] , input-output bo-oborot-ap[13] , input-output b1-oborot-ap[13] , input-output b2-oborot-ap[13] ) .
    run calc-density in this-procedure ( input 'pc' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-pc[13] , input-output bi-oborot-pc[13] , input-output bo-oborot-pc[13] , input-output b1-oborot-pc[13] , input-output b2-oborot-pc[13] ) .
end.
end procedure.
procedure display-line :
  i = i + 1.
   if not  (not show-negativ and null-str# = 0 ) then do:
       if not  (not show-negativ-2 and null-str2# = 0  ) then do:
        if not sums-only then do:
            if fr0 = true then do:
              num#str# = num#str# + 1.
              num#col# = 1.
              run macr_excel_char_with_format( string(tmp#stroka0)  , num#str# , num#col#  ) .
              run macr_cell_format
              ( 10    ,
                true  ,
                true  ,
                33    ,
                num#str# ,
                num#col# ,
                num#str# ,
                5 ) .
              fr0 = false .
            end.
            if fr = true then do:
                num#str# = num#str# + 1.
                num#col# = 2.
                run macr_excel_char_with_format( string(caps(temp-str))  , num#str# , num#col#  ) .
                run macr_cell_format
                  ( 10    ,
                    true  ,
                    true  ,
                    36    ,
                    num#str# ,
                    num#col# ,
                    num#str# ,
                    5 ) .
              fr = false .
            end.
            run display-str1 in this-procedure .
            run new-tmp-page .
            end.
        end.
    end.
end procedure.
procedure print-header :
if not firstline then   do: end.
    firstline = true .
    if xtog-obj and   x-selectobject <> "currency":u   then  do:
     num#str# = num#str# + 1.
     num#col# = 1.
     run macr_excel_char_with_format(
     string(  "ПО ОБЪЕКТУ : " + ObjName)
      , num#str# , num#col#  ) .
     num#col# = num#col# + 3.
     run macr_excel_char_with_format(
     string(  x-store-type + " " + string(x-store-code)  )
      , num#str# , num#col#  ) .
     num#col# = num#col# + 1.
     run macr_excel_char_with_format(
     string( "УБД " + string(x-db-num)  )
      , num#str# , num#col#  ) .
    end.
      run clear-b1 in this-procedure .
      run clear-b2 in this-procedure .
      run clear-bi in this-procedure .
      break_group = true.
      break_group1 = true.
   end procedure.
procedure print-footer :
     num#str# = num#str# + 1.
     num#col# = 1.
     run macr_excel_char_with_format( string("ИТОГО"  )  , num#str# , num#col#  ) .
     run display-bi in this-procedure .
end procedure.
procedure run2 :
case select-good :
  when 1  then do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj THEN DO :
    for each gds-obj  where
          gds-obj.obj-type = x-store-type  and
          gds-obj.obj-code = x-store-code
          and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock,
          First goods  where  gds-obj.gds-code   = goods.gds-code
no-lock
BREAK
      BY (gds-obj.grp-name)
    BY (goods.gds-code) :
      run item-goods ( "3" , "goods" ) .
      if return-value <> "" then NEXT.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
    End.
  END.
  Else DO:
   For each obj-list no-lock :
                  FOR EACH gds-obj where
                gds-obj.obj-type = obj-list.obj-type    and
                gds-obj.obj-code = obj-list.obj-code
                and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock :
                if NOT can-find(First temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) Then do:
                    find first goods no-lock  where goods.gds-code  = gds-obj.gds-code .
                    Create temp-gds-list.
                    Assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                End.
            End.
  End.
  for each temp-gds-list no-lock
    , First goods     where goods.gds-code  = temp-gds-list.gds-code no-lock
      BREAK
BY (gds-obj.grp-name)
    BY goods.gds-code :
    run item-goods ( "3" , "goods" ) .
      if return-value <> "" then NEXT.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
  End.
End.
   end.
  when 2  then do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  if x-selectobject = "currency":u  or  xtog-obj then do:
      for  each gds-obj
                  where gds-obj.obj-code   = x-store-code
                   and  gds-obj.obj-type   = x-store-type
                        and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                        no-lock ,
              first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
              first goods       where gds-obj.gds-code   = goods.gds-code  no-lock
                  break
                  by gds-obj.grp-name
                  by goods.gds-code :
                  run item-goods ( input "3" , input "goods" ) .
                  if return-value <> "" then next.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
      end.
  end.
  else do:
      for each obj-list no-lock :
            for  each gds-obj
              where  gds-obj.obj-code   = obj-list.obj-code
                and  gds-obj.obj-type   = obj-list.obj-type
                     and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
              no-lock ,
              first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
              first goods       where gds-obj.gds-code   = goods.gds-code  no-lock :
                    if not can-find(first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                        create temp-gds-list.
                        assign
                          temp-gds-list.prod-code = gds-obj.prod-code
                          temp-gds-list.grp-name  = gds-obj.grp-name
                          temp-gds-list.gds-name  = goods.grp-name
                          temp-gds-list.gds-code  = gds-obj.gds-code
                          temp-gds-list.artic     = gds-obj.artic
                        .
                    end.
            end.
    end.
  for each temp-gds-list no-lock
    , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock
      break
        by gds-obj.grp-name
    by goods.gds-code :
    run item-goods ( "3" , "goods" ) .
      if return-value <> "" then next.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
  end.
end.
   end.
  when 3 then do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if x-selectobject = "currency":u  or  xtog-obj then do:
  for  each gds-obj
      where  gds-obj.obj-code   = x-store-code
        and  gds-obj.obj-type   = x-store-type
              and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
              no-lock ,
  first g#cli
        where gds-obj.prod-code  = g#cli.obj-code
        and  gds-obj.prod-type   = g#cli.obj-type
        no-lock,
  first goods
        where gds-obj.gds-code = goods.gds-code no-lock
        break
        by (gds-obj.grp-name)
        by goods.gds-code :
        run item-goods ( "3" , "goods" ) .
        if return-value <> "" then next.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
      end.
  end.
  else do:
    for each obj-list no-lock :
          for  each gds-obj
            where  gds-obj.obj-code   = obj-list.obj-code
              and  gds-obj.obj-type   = obj-list.obj-type
                    and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                    no-lock ,
          first g#cli
              where gds-obj.prod-code  = g#cli.obj-code
              and  gds-obj.prod-type   = g#cli.obj-type
              no-lock,
          first goods
              where gds-obj.gds-code = goods.gds-code no-lock :
                if not can-find (first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                    create temp-gds-list.
                    assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                end.
          end.
    end.
      for each temp-gds-list no-lock
        , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock
          break
            by (gds-obj.grp-name)
            by goods.gds-code :
        run item-goods ( "3" , "goods" ) .
          if return-value <> "" then next.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
      end.
end.
   end.
  otherwise do:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj THEN DO :
    for each gds-obj  where
          gds-obj.obj-type = x-store-type  and
          gds-obj.obj-code = x-store-code
          and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock,
          First goods  where  gds-obj.gds-code   = goods.gds-code
      no-lock,
First gds-list  where gds-obj.gds-code  = gds-list.gds-code
no-lock
BREAK
      BY (gds-list.grp-name)
    BY (gds-list.gds-code) :
      run item-goods ( "3" , "gds-list" ) .
      if return-value <> "" then NEXT.
        If Last-of(gds-list.grp-name) Then Do:
        If String(Entry(2,"gds-list.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
    End.
  END.
  Else DO:
   For each obj-list no-lock :
                  FOR EACH gds-obj where
                gds-obj.obj-type = obj-list.obj-type    and
                gds-obj.obj-code = obj-list.obj-code
                and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock,
          First gds-list  where gds-obj.gds-code  = gds-list.gds-code
                no-lock :
                if NOT can-find(First temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) Then do:
                    find first goods no-lock  where goods.gds-code  = gds-obj.gds-code .
                    Create temp-gds-list.
                    Assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                End.
            End.
  End.
  for each temp-gds-list no-lock
    , First gds-list  where gds-list.gds-code  = temp-gds-list.gds-code no-lock
      BREAK
BY (gds-list.grp-name)
    BY gds-list.gds-code :
    run item-goods ( "3" , "gds-list" ) .
      if return-value <> "" then NEXT.
        If Last-of(gds-list.grp-name) Then Do:
        If String(Entry(2,"gds-list.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
  End.
End.
  end.
end case.
end procedure.
procedure calcitog :
    run ostatok  in this-procedure (
        input x-store-code  ,
        input x-store-type  , x-tog-shift ,
        input x-date-start - 1 ,
        input date('')      , x-Shift-Start,x-Shift-End,
        input 'crsa':U   ,
        input '##,##':U,
        input xtog-obj ,
        output  quantity1  ,
        output  coast_r1   ,
        output  coast_v1   ,
        output  vat_r1     ,
        output  vat_v1     ,
        output  fact-order-1 ).
    run ostatok  in this-procedure (
        input x-store-code  ,
        input x-store-type  , x-tog-shift ,
        input x-date-start  ,
        input x-date-end    , x-Shift-Start,x-Shift-End,
        input 'crsa':U   ,
        input '##,##':U,
        input xtog-obj ,
        output  quantity1  ,
        output  coast_r1   ,
        output  coast_v1   ,
        output  vat_r1     ,
        output  vat_v1     ,
        output  fact-order-2 ).
          quantity1  = 0.
          coast_r1   = 0.
          coast_v1   = 0.
          vat_r1     = 0.
          vat_v1     = 0.
end procedure.
procedure display-str1  :
define variable ll as int no-undo.
  assign
    num#str# = num#str# + 1
    num#col# = 0
    v-gds-num = v-gds-num + 1
  .
  if use-column[28] then do: assign num#col#  = num#col# + 1 .   run macr_excel_dec ( v-gds-num , num#str# , num#col#   ) .   end.
  if use-column[1]  then do: assign num#col#  = num#col# + 1 .   run macr_excel_dec ( gds-zap-b-code , num#str# , num#col#   ) .   end.
  if use-column[2]  then do: assign num#col#  = num#col# + 1 .   run macr_excel_char ( gds-zap-artic, num#str# , num#col#   )   .   end.
  if use-column[3]  then do: assign num#col#  = num#col# + 1 .   run macr_excel_char ( if xlongName then gds-zap-gds-long-name else gds-zap-gds-name, num#str# , num#col#   ) .  end.
  if use-column[4]  then do: assign num#col#  = num#col# + 1 .   run macr_excel_char ( gds-zap-unit-base, num#str# , num#col#   ) . end.
  if use-column[5]  then do: assign num#col#  = num#col# + 1 .   run macr_excel_char ( gds-zap-type, num#str# , num#col#   ) .      end.
if use-column[21] then do: Assign num#col#  = num#col#  + 1.   run macr_excel_dec ( Round(oborot-disc [1],2 ), num#str# , num#col#   ).     end.
if use-column[23] then do: Assign num#col#  = num#col#  + 1.   run macr_excel_dec ( Round(oborot-eff  [1],2 ), num#str# , num#col#   ).     end.
if use-column[24] then do: Assign num#col#  = num#col#  + 1.   run macr_excel_dec ( Round(oborot-prc  [1],2 ), num#str# , num#col#   ).     end.
def var l-nk as integer no-undo .
  Assign
    LL = 0
    KK = 1
  .
  if xShowCost      Then DO: KK = KK + 1. End.
  if xShowCostNDS   Then DO: KK = KK + 1. End.
  if xShowCrsa      Then DO: KK = KK + 1. End.
  if xShowCrsaNds   Then DO: KK = KK + 1. End.
  if xShowSale      Then DO: KK = KK + 1. End.
  if xShowSaleNds   Then DO: KK = KK + 1. End.
  if xShowSaleslt   Then DO: KK = KK + 1. End.
  if xShowmediator  Then DO: KK = KK + 1. End.
  if x-tog-wt       then do: KK = KK + 1. End.
  if x-tog-ms       then do: KK = KK + 1. End.
  if xDens          then do: KK = KK + 1. End.
  repeat i = 1 to 13 :
    if i = 7 then next.
    if NOT xShowCost      and i = 2   Then  next.
    if NOT xShowCostNDS   and i = 3   Then  next.
    if NOT xShowCrsa      and i = 5   Then  next.
    if NOT xShowCrsaNds   and i = 6   Then  next.
    if NOT xShowSale      and i = 8   Then  next.
    if NOT xShowSaleNds   and i = 9   Then  next.
    if NOT xShowSaleSlt   and i = 10  Then  next.
    if NOT xShowmediator  and i = 4   Then  next.
    if not x-tog-wt       and i = 11  then  next.
    if not x-tog-ms       and i = 12  then  next.
    if not xDens          and i = 13  then  next.
    assign
      LL = LL + 1
      l-nk = mp-1
    .
  if x-vat or i <> 2  then do:
  if use-column[6]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , ostatok-start                          [i] ,  i). end.
  if use-column[7]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , oborot-ie          [i] ,  i). end.
  if use-column[8]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , oborot-iv          [i] ,  i). end.
  if use-column[9]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , oborot-im           [i] ,  i). end.
  if use-column[10] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , oborot-ee          [i] ,  i). end.
  if use-column[11] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , oborot-ev          [i] ,  i). end.
  if use-column[12] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , oborot-em           [i] ,  i). end.
  if use-column[13] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , oborot-we          [i] ,  i). end.
  if use-column[14] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , oborot-es     [i] ,  i). end.
  if use-column[15] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , oborot-rs [i] ,  i). end.
  if use-column[16] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , oborot-re      [i] ,  i). end.
  if use-column[17] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , oborot-ep       [i] ,  i). end.
  if use-column[18] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , oborot-rv      [i] ,  i). end.
  if use-column[19] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , oborot-vt                [i] ,  i). end.
  if use-column[20] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , oborot-ot           [i] ,  i). end.
  if use-column[22] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , ostatok-end                            [i] ,  i). end.
  if use-column[25] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , oborot-ap [i] ,  i). end.
  if use-column[26] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , oborot-pc [i] ,  i). end.
  if i = 13 then do:
    if "" = "b1-" or "" = "b2-" or "" = "bi-" or "" = "bo-" then do:
       if use-column[27] then do: l-nk = l-nk + 1 .  run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , 0 ,  i). end.
    end.
    else do:
      if use-column[27] then do: l-nk = l-nk + 1 .  run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , ( if ABS(oborot-ee         [1] +
                                                                                                                                    oborot-re     [1] +
                                                                                                                                    oborot-es    [1] +
                                                                                                                                    oborot-rs[1] ) <> 0
                                                                                                                            then
                                                                                                                                ABS(oborot-ee         [11] +
                                                                                                                                    oborot-re     [11] +
                                                                                                                                    oborot-es    [11] +
                                                                                                                                    oborot-rs[11] )
                                                                                                                                /
                                                                                                                                ABS(oborot-ee         [1] +
                                                                                                                                    oborot-re     [1] +
                                                                                                                                    oborot-es    [1] +
                                                                                                                                    oborot-rs[1] )
                                                                                                                            else 0 )
      ,  i). end.
    end.
  end.
  else do:
  if use-column[27] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , (oborot-ee         [i] +
                                                                                                                        oborot-re     [i] +
                                                                                                                        oborot-es    [i] +
                                                                                                                        oborot-rs[i] )
  ,  i). end.
  end.
  end.
  if x-vat = false  and i = 2 then do:
  if use-column[6]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( ostatok-start                          [i] -  ostatok-start                          [3] ),  i). end.
  if use-column[7]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( oborot-ie          [i] -  oborot-ie          [3] ),  i). end.
  if use-column[8]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( oborot-iv          [i] -  oborot-iv          [3] ),  i). end.
  if use-column[9]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( oborot-im           [i] -  oborot-im           [3] ),  i). end.
  if use-column[10] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( oborot-ee          [i] -  oborot-ee          [3] ),  i). end.
  if use-column[11] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( oborot-ev          [i] -  oborot-ev          [3] ),  i). end.
  if use-column[12] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( oborot-em           [i] -  oborot-em           [3] ),  i). end.
  if use-column[13] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( oborot-we          [i] -  oborot-we          [3] ),  i). end.
  if use-column[14] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( oborot-es     [i] -  oborot-es     [3] ),  i). end.
  if use-column[15] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( oborot-rs [i] -  oborot-rs [3] ),  i). end.
  if use-column[16] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( oborot-re      [i] -  oborot-re      [3] ),  i). end.
  if use-column[17] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( oborot-ep       [i] -  oborot-ep       [3] ),  i). end.
  if use-column[18] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( oborot-rv      [i] -  oborot-rv      [3] ),  i). end.
  if use-column[19] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( oborot-vt                [i] -  oborot-vt                [3] ),  i). end.
  if use-column[20] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( oborot-ot           [i] -  oborot-ot           [3] ),  i). end.
  if use-column[22] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( ostatok-end                            [i] -  ostatok-end                            [3] ),  i). end.
  if use-column[25] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( oborot-ap [i] -  oborot-ap[3] ),  i). end.
  if use-column[26] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( oborot-pc [i] -  oborot-pc[3] ),  i). end.
  if i = 13 then do :
    if use-column[27] then do: l-nk = l-nk + 1 . run ex-display in this-procedure (mp-1 + ll + (kk * (l-nk - mp))  , 0  , i ). end.
  end.
  else do:
    if use-column[27] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,
    (                                                                                      (oborot-ee         [i] +
                                                                                            oborot-re     [i] +
                                                                                            oborot-es    [i] +
                                                                                            oborot-rs[i]) -
                                                                                          (oborot-ee         [3] +
                                                                                            oborot-re     [3] +
                                                                                            oborot-es    [3] +
                                                                                            oborot-rs[3] ) ) , i ). end.
  end.
  end.
  end.
 run new-tmp-page .
end procedure.
procedure display-bi  :
define variable ll as int no-undo.
define variable kk as int no-undo.
  num#col#  = 0 .
  if use-column[28] then assign num#col#  = num#col#  + 1 .
  if use-column[1] then  assign num#col#  = num#col#  + 1 .
  if use-column[2] then  assign num#col#  = num#col#  + 1 .
  if use-column[3] then  assign num#col#  = num#col#  + 1 .
  if use-column[4] then  assign num#col#  = num#col#  + 1 .
  if use-column[5] then  assign num#col#  = num#col#  + 1 .
  run macr_cell_format
                              ( 10    ,
                                true  ,
                                false ,
                                ?    ,
                                num#str# ,
                                1 ,
                                num#str# ,
                                (mp + ll + (kk * (27 - 8)))
                                ) .
if use-column[21] then do: Assign num#col#  = num#col#  + 1.   run macr_excel_dec ( Round(bi-oborot-disc [1],2 ), num#str# , num#col#   ).     end.
if use-column[23] then do: Assign num#col#  = num#col#  + 1.   run macr_excel_dec ( Round(bi-oborot-eff  [1],2 ), num#str# , num#col#   ).     end.
if use-column[24] then do: Assign num#col#  = num#col#  + 1.   run macr_excel_dec ( Round(bi-oborot-prc  [1],2 ), num#str# , num#col#   ).     end.
def var l-nk as integer no-undo .
  Assign
    LL = 0
    KK = 1
  .
  if xShowCost      Then DO: KK = KK + 1. End.
  if xShowCostNDS   Then DO: KK = KK + 1. End.
  if xShowCrsa      Then DO: KK = KK + 1. End.
  if xShowCrsaNds   Then DO: KK = KK + 1. End.
  if xShowSale      Then DO: KK = KK + 1. End.
  if xShowSaleNds   Then DO: KK = KK + 1. End.
  if xShowSaleslt   Then DO: KK = KK + 1. End.
  if xShowmediator  Then DO: KK = KK + 1. End.
  if x-tog-wt       then do: KK = KK + 1. End.
  if x-tog-ms       then do: KK = KK + 1. End.
  if xDens          then do: KK = KK + 1. End.
  repeat i = 1 to 13 :
    if i = 7 then next.
    if NOT xShowCost      and i = 2   Then  next.
    if NOT xShowCostNDS   and i = 3   Then  next.
    if NOT xShowCrsa      and i = 5   Then  next.
    if NOT xShowCrsaNds   and i = 6   Then  next.
    if NOT xShowSale      and i = 8   Then  next.
    if NOT xShowSaleNds   and i = 9   Then  next.
    if NOT xShowSaleSlt   and i = 10  Then  next.
    if NOT xShowmediator  and i = 4   Then  next.
    if not x-tog-wt       and i = 11  then  next.
    if not x-tog-ms       and i = 12  then  next.
    if not xDens          and i = 13  then  next.
    assign
      LL = LL + 1
      l-nk = mp-1
    .
  if x-vat or i <> 2  then do:
  if use-column[6]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bi-ostatok-start                          [i] ,  i). end.
  if use-column[7]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bi-oborot-ie          [i] ,  i). end.
  if use-column[8]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bi-oborot-iv          [i] ,  i). end.
  if use-column[9]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bi-oborot-im           [i] ,  i). end.
  if use-column[10] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bi-oborot-ee          [i] ,  i). end.
  if use-column[11] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bi-oborot-ev          [i] ,  i). end.
  if use-column[12] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bi-oborot-em           [i] ,  i). end.
  if use-column[13] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bi-oborot-we          [i] ,  i). end.
  if use-column[14] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bi-oborot-es     [i] ,  i). end.
  if use-column[15] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bi-oborot-rs [i] ,  i). end.
  if use-column[16] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bi-oborot-re      [i] ,  i). end.
  if use-column[17] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bi-oborot-ep       [i] ,  i). end.
  if use-column[18] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bi-oborot-rv      [i] ,  i). end.
  if use-column[19] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bi-oborot-vt                [i] ,  i). end.
  if use-column[20] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bi-oborot-ot           [i] ,  i). end.
  if use-column[22] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bi-ostatok-end                            [i] ,  i). end.
  if use-column[25] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bi-oborot-ap [i] ,  i). end.
  if use-column[26] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bi-oborot-pc [i] ,  i). end.
  if i = 13 then do:
    if "bi-" = "b1-" or "bi-" = "b2-" or "bi-" = "bi-" or "bi-" = "bo-" then do:
       if use-column[27] then do: l-nk = l-nk + 1 .  run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , 0 ,  i). end.
    end.
    else do:
      if use-column[27] then do: l-nk = l-nk + 1 .  run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , ( if ABS(bi-oborot-ee         [1] +
                                                                                                                                    bi-oborot-re     [1] +
                                                                                                                                    bi-oborot-es    [1] +
                                                                                                                                    bi-oborot-rs[1] ) <> 0
                                                                                                                            then
                                                                                                                                ABS(bi-oborot-ee         [11] +
                                                                                                                                    bi-oborot-re     [11] +
                                                                                                                                    bi-oborot-es    [11] +
                                                                                                                                    bi-oborot-rs[11] )
                                                                                                                                /
                                                                                                                                ABS(bi-oborot-ee         [1] +
                                                                                                                                    bi-oborot-re     [1] +
                                                                                                                                    bi-oborot-es    [1] +
                                                                                                                                    bi-oborot-rs[1] )
                                                                                                                            else 0 )
      ,  i). end.
    end.
  end.
  else do:
  if use-column[27] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , (bi-oborot-ee         [i] +
                                                                                                                        bi-oborot-re     [i] +
                                                                                                                        bi-oborot-es    [i] +
                                                                                                                        bi-oborot-rs[i] )
  ,  i). end.
  end.
  end.
  if x-vat = false  and i = 2 then do:
  if use-column[6]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bi-ostatok-start                          [i] -  bi-ostatok-start                          [3] ),  i). end.
  if use-column[7]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bi-oborot-ie          [i] -  bi-oborot-ie          [3] ),  i). end.
  if use-column[8]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bi-oborot-iv          [i] -  bi-oborot-iv          [3] ),  i). end.
  if use-column[9]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bi-oborot-im           [i] -  bi-oborot-im           [3] ),  i). end.
  if use-column[10] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bi-oborot-ee          [i] -  bi-oborot-ee          [3] ),  i). end.
  if use-column[11] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bi-oborot-ev          [i] -  bi-oborot-ev          [3] ),  i). end.
  if use-column[12] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bi-oborot-em           [i] -  bi-oborot-em           [3] ),  i). end.
  if use-column[13] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bi-oborot-we          [i] -  bi-oborot-we          [3] ),  i). end.
  if use-column[14] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bi-oborot-es     [i] -  bi-oborot-es     [3] ),  i). end.
  if use-column[15] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bi-oborot-rs [i] -  bi-oborot-rs [3] ),  i). end.
  if use-column[16] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bi-oborot-re      [i] -  bi-oborot-re      [3] ),  i). end.
  if use-column[17] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bi-oborot-ep       [i] -  bi-oborot-ep       [3] ),  i). end.
  if use-column[18] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bi-oborot-rv      [i] -  bi-oborot-rv      [3] ),  i). end.
  if use-column[19] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bi-oborot-vt                [i] -  bi-oborot-vt                [3] ),  i). end.
  if use-column[20] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bi-oborot-ot           [i] -  bi-oborot-ot           [3] ),  i). end.
  if use-column[22] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bi-ostatok-end                            [i] -  bi-ostatok-end                            [3] ),  i). end.
  if use-column[25] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bi-oborot-ap [i] -  bi-oborot-ap[3] ),  i). end.
  if use-column[26] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bi-oborot-pc [i] -  bi-oborot-pc[3] ),  i). end.
  if i = 13 then do :
    if use-column[27] then do: l-nk = l-nk + 1 . run ex-display in this-procedure (mp-1 + ll + (kk * (l-nk - mp))  , 0  , i ). end.
  end.
  else do:
    if use-column[27] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,
    (                                                                                      (bi-oborot-ee         [i] +
                                                                                            bi-oborot-re     [i] +
                                                                                            bi-oborot-es    [i] +
                                                                                            bi-oborot-rs[i]) -
                                                                                          (bi-oborot-ee         [3] +
                                                                                            bi-oborot-re     [3] +
                                                                                            bi-oborot-es    [3] +
                                                                                            bi-oborot-rs[3] ) ) , i ). end.
  end.
  end.
  end.
 run new-tmp-page .
end procedure.
procedure display-bo  :
define variable ll as int no-undo.
define variable kk as int no-undo.
  num#str# = num#str# + 1.
  num#col# = 1.
  run macr_excel_char_with_format( string("ИТОГО ПО ОБЪЕКТАМ")  , num#str# , num#col#  ) .
  num#col#  = 0 .
  if use-column[28] then assign num#col#  = num#col#  + 1 .
  if use-column[1] then  assign num#col#  = num#col#  + 1 .
  if use-column[2] then  assign num#col#  = num#col#  + 1 .
  if use-column[3] then  assign num#col#  = num#col#  + 1 .
  if use-column[4] then  assign num#col#  = num#col#  + 1 .
  if use-column[5] then  assign num#col#  = num#col#  + 1 .
  run macr_cell_format
      ( 10    ,
        true  ,
        false ,
        ?    ,
        num#str# ,
        1 ,
        num#str# ,
        (mp + ll + (kk * (27 - 8)))
        ) .
if use-column[21] then do: Assign num#col#  = num#col#  + 1.   run macr_excel_dec ( Round(bo-oborot-disc [1],2 ), num#str# , num#col#   ).     end.
if use-column[23] then do: Assign num#col#  = num#col#  + 1.   run macr_excel_dec ( Round(bo-oborot-eff  [1],2 ), num#str# , num#col#   ).     end.
if use-column[24] then do: Assign num#col#  = num#col#  + 1.   run macr_excel_dec ( Round(bo-oborot-prc  [1],2 ), num#str# , num#col#   ).     end.
def var l-nk as integer no-undo .
  Assign
    LL = 0
    KK = 1
  .
  if xShowCost      Then DO: KK = KK + 1. End.
  if xShowCostNDS   Then DO: KK = KK + 1. End.
  if xShowCrsa      Then DO: KK = KK + 1. End.
  if xShowCrsaNds   Then DO: KK = KK + 1. End.
  if xShowSale      Then DO: KK = KK + 1. End.
  if xShowSaleNds   Then DO: KK = KK + 1. End.
  if xShowSaleslt   Then DO: KK = KK + 1. End.
  if xShowmediator  Then DO: KK = KK + 1. End.
  if x-tog-wt       then do: KK = KK + 1. End.
  if x-tog-ms       then do: KK = KK + 1. End.
  if xDens          then do: KK = KK + 1. End.
  repeat i = 1 to 13 :
    if i = 7 then next.
    if NOT xShowCost      and i = 2   Then  next.
    if NOT xShowCostNDS   and i = 3   Then  next.
    if NOT xShowCrsa      and i = 5   Then  next.
    if NOT xShowCrsaNds   and i = 6   Then  next.
    if NOT xShowSale      and i = 8   Then  next.
    if NOT xShowSaleNds   and i = 9   Then  next.
    if NOT xShowSaleSlt   and i = 10  Then  next.
    if NOT xShowmediator  and i = 4   Then  next.
    if not x-tog-wt       and i = 11  then  next.
    if not x-tog-ms       and i = 12  then  next.
    if not xDens          and i = 13  then  next.
    assign
      LL = LL + 1
      l-nk = mp-1
    .
  if x-vat or i <> 2  then do:
  if use-column[6]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bo-ostatok-start                          [i] ,  i). end.
  if use-column[7]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bo-oborot-ie          [i] ,  i). end.
  if use-column[8]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bo-oborot-iv          [i] ,  i). end.
  if use-column[9]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bo-oborot-im           [i] ,  i). end.
  if use-column[10] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bo-oborot-ee          [i] ,  i). end.
  if use-column[11] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bo-oborot-ev          [i] ,  i). end.
  if use-column[12] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bo-oborot-em           [i] ,  i). end.
  if use-column[13] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bo-oborot-we          [i] ,  i). end.
  if use-column[14] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bo-oborot-es     [i] ,  i). end.
  if use-column[15] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bo-oborot-rs [i] ,  i). end.
  if use-column[16] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bo-oborot-re      [i] ,  i). end.
  if use-column[17] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bo-oborot-ep       [i] ,  i). end.
  if use-column[18] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bo-oborot-rv      [i] ,  i). end.
  if use-column[19] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bo-oborot-vt                [i] ,  i). end.
  if use-column[20] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bo-oborot-ot           [i] ,  i). end.
  if use-column[22] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bo-ostatok-end                            [i] ,  i). end.
  if use-column[25] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bo-oborot-ap [i] ,  i). end.
  if use-column[26] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , bo-oborot-pc [i] ,  i). end.
  if i = 13 then do:
    if "bo-" = "b1-" or "bo-" = "b2-" or "bo-" = "bi-" or "bo-" = "bo-" then do:
       if use-column[27] then do: l-nk = l-nk + 1 .  run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , 0 ,  i). end.
    end.
    else do:
      if use-column[27] then do: l-nk = l-nk + 1 .  run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , ( if ABS(bo-oborot-ee         [1] +
                                                                                                                                    bo-oborot-re     [1] +
                                                                                                                                    bo-oborot-es    [1] +
                                                                                                                                    bo-oborot-rs[1] ) <> 0
                                                                                                                            then
                                                                                                                                ABS(bo-oborot-ee         [11] +
                                                                                                                                    bo-oborot-re     [11] +
                                                                                                                                    bo-oborot-es    [11] +
                                                                                                                                    bo-oborot-rs[11] )
                                                                                                                                /
                                                                                                                                ABS(bo-oborot-ee         [1] +
                                                                                                                                    bo-oborot-re     [1] +
                                                                                                                                    bo-oborot-es    [1] +
                                                                                                                                    bo-oborot-rs[1] )
                                                                                                                            else 0 )
      ,  i). end.
    end.
  end.
  else do:
  if use-column[27] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , (bo-oborot-ee         [i] +
                                                                                                                        bo-oborot-re     [i] +
                                                                                                                        bo-oborot-es    [i] +
                                                                                                                        bo-oborot-rs[i] )
  ,  i). end.
  end.
  end.
  if x-vat = false  and i = 2 then do:
  if use-column[6]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bo-ostatok-start                          [i] -  bo-ostatok-start                          [3] ),  i). end.
  if use-column[7]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bo-oborot-ie          [i] -  bo-oborot-ie          [3] ),  i). end.
  if use-column[8]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bo-oborot-iv          [i] -  bo-oborot-iv          [3] ),  i). end.
  if use-column[9]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bo-oborot-im           [i] -  bo-oborot-im           [3] ),  i). end.
  if use-column[10] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bo-oborot-ee          [i] -  bo-oborot-ee          [3] ),  i). end.
  if use-column[11] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bo-oborot-ev          [i] -  bo-oborot-ev          [3] ),  i). end.
  if use-column[12] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bo-oborot-em           [i] -  bo-oborot-em           [3] ),  i). end.
  if use-column[13] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bo-oborot-we          [i] -  bo-oborot-we          [3] ),  i). end.
  if use-column[14] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bo-oborot-es     [i] -  bo-oborot-es     [3] ),  i). end.
  if use-column[15] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bo-oborot-rs [i] -  bo-oborot-rs [3] ),  i). end.
  if use-column[16] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bo-oborot-re      [i] -  bo-oborot-re      [3] ),  i). end.
  if use-column[17] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bo-oborot-ep       [i] -  bo-oborot-ep       [3] ),  i). end.
  if use-column[18] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bo-oborot-rv      [i] -  bo-oborot-rv      [3] ),  i). end.
  if use-column[19] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bo-oborot-vt                [i] -  bo-oborot-vt                [3] ),  i). end.
  if use-column[20] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bo-oborot-ot           [i] -  bo-oborot-ot           [3] ),  i). end.
  if use-column[22] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bo-ostatok-end                            [i] -  bo-ostatok-end                            [3] ),  i). end.
  if use-column[25] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bo-oborot-ap [i] -  bo-oborot-ap[3] ),  i). end.
  if use-column[26] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( bo-oborot-pc [i] -  bo-oborot-pc[3] ),  i). end.
  if i = 13 then do :
    if use-column[27] then do: l-nk = l-nk + 1 . run ex-display in this-procedure (mp-1 + ll + (kk * (l-nk - mp))  , 0  , i ). end.
  end.
  else do:
    if use-column[27] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,
    (                                                                                      (bo-oborot-ee         [i] +
                                                                                            bo-oborot-re     [i] +
                                                                                            bo-oborot-es    [i] +
                                                                                            bo-oborot-rs[i]) -
                                                                                          (bo-oborot-ee         [3] +
                                                                                            bo-oborot-re     [3] +
                                                                                            bo-oborot-es    [3] +
                                                                                            bo-oborot-rs[3] ) ) , i ). end.
  end.
  end.
  end.
 run new-tmp-page .
end procedure.
procedure display-b1  :
define variable ll as int no-undo.
define variable kk as int no-undo.
  b1-null-str# = 1.
  b1-null-str2# = 1.
  if not show-negativ   then  run b1-null-str-pr   in this-procedure .
  if not show-negativ-2 then  run b1-null-str-pr2  in this-procedure .
   if not     ( not show-negativ   and b1-null-str#  = 0  ) then do :
      if not  ( not show-negativ-2 and b1-null-str2# = 0  ) then do :
              if sums-only then do:
                  if fr0 = true then do:
                        num#str# = num#str# + 1     .
                        num#col# = 1.
                        run macr_excel_char_with_format(  caps(tmp#stroka0)  , num#str# , num#col#  ) .
                        run macr_cell_format
                        ( 10    ,
                          true  ,
                          true  ,
                          36    ,
                          num#str# ,
                          num#col# ,
                          num#str# ,
                          5 ) .
                      fr0 = false .
                    end.
               end.
  num#str# = num#str# + 1     .
  num#col# = 2 .
  if substitute( "&1", sf1:screen-value )  <> "?" then
    run macr_excel_char_with_format(  string(s-bar-code +
                                 sf1:screen-value +
                                 gds-zap-artic +
                                 sf2:screen-value +
                                 gds-zap-gds-name +
                                 temp-str-2    )  , num#str# , num#col#  ) .
   else
    run macr_excel_char_with_format(  string(s-bar-code +
                                 gds-zap-artic +
                                 gds-zap-gds-name +
                                 temp-str-2    )  , num#str# , num#col#  ) .
  num#col#  = 0 .
  if use-column[28] then assign num#col#  = num#col#  + 1 .
  if use-column[1] then  assign num#col#  = num#col#  + 1 .
  if use-column[2] then  assign num#col#  = num#col#  + 1 .
  if use-column[3] then  assign num#col#  = num#col#  + 1 .
  if use-column[4] then  assign num#col#  = num#col#  + 1 .
  if use-column[5] then  assign num#col#  = num#col#  + 1 .
if use-column[21] then do: Assign num#col#  = num#col#  + 1.   run macr_excel_dec ( Round(b1-oborot-disc [1],2 ), num#str# , num#col#   ).     end.
if use-column[23] then do: Assign num#col#  = num#col#  + 1.   run macr_excel_dec ( Round(b1-oborot-eff  [1],2 ), num#str# , num#col#   ).     end.
if use-column[24] then do: Assign num#col#  = num#col#  + 1.   run macr_excel_dec ( Round(b1-oborot-prc  [1],2 ), num#str# , num#col#   ).     end.
def var l-nk as integer no-undo .
  Assign
    LL = 0
    KK = 1
  .
  if xShowCost      Then DO: KK = KK + 1. End.
  if xShowCostNDS   Then DO: KK = KK + 1. End.
  if xShowCrsa      Then DO: KK = KK + 1. End.
  if xShowCrsaNds   Then DO: KK = KK + 1. End.
  if xShowSale      Then DO: KK = KK + 1. End.
  if xShowSaleNds   Then DO: KK = KK + 1. End.
  if xShowSaleslt   Then DO: KK = KK + 1. End.
  if xShowmediator  Then DO: KK = KK + 1. End.
  if x-tog-wt       then do: KK = KK + 1. End.
  if x-tog-ms       then do: KK = KK + 1. End.
  if xDens          then do: KK = KK + 1. End.
  repeat i = 1 to 13 :
    if i = 7 then next.
    if NOT xShowCost      and i = 2   Then  next.
    if NOT xShowCostNDS   and i = 3   Then  next.
    if NOT xShowCrsa      and i = 5   Then  next.
    if NOT xShowCrsaNds   and i = 6   Then  next.
    if NOT xShowSale      and i = 8   Then  next.
    if NOT xShowSaleNds   and i = 9   Then  next.
    if NOT xShowSaleSlt   and i = 10  Then  next.
    if NOT xShowmediator  and i = 4   Then  next.
    if not x-tog-wt       and i = 11  then  next.
    if not x-tog-ms       and i = 12  then  next.
    if not xDens          and i = 13  then  next.
    assign
      LL = LL + 1
      l-nk = mp-1
    .
  if x-vat or i <> 2  then do:
  if use-column[6]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b1-ostatok-start                          [i] ,  i). end.
  if use-column[7]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b1-oborot-ie          [i] ,  i). end.
  if use-column[8]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b1-oborot-iv          [i] ,  i). end.
  if use-column[9]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b1-oborot-im           [i] ,  i). end.
  if use-column[10] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b1-oborot-ee          [i] ,  i). end.
  if use-column[11] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b1-oborot-ev          [i] ,  i). end.
  if use-column[12] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b1-oborot-em           [i] ,  i). end.
  if use-column[13] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b1-oborot-we          [i] ,  i). end.
  if use-column[14] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b1-oborot-es     [i] ,  i). end.
  if use-column[15] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b1-oborot-rs [i] ,  i). end.
  if use-column[16] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b1-oborot-re      [i] ,  i). end.
  if use-column[17] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b1-oborot-ep       [i] ,  i). end.
  if use-column[18] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b1-oborot-rv      [i] ,  i). end.
  if use-column[19] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b1-oborot-vt                [i] ,  i). end.
  if use-column[20] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b1-oborot-ot           [i] ,  i). end.
  if use-column[22] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b1-ostatok-end                            [i] ,  i). end.
  if use-column[25] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b1-oborot-ap [i] ,  i). end.
  if use-column[26] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b1-oborot-pc [i] ,  i). end.
  if i = 13 then do:
    if "b1-" = "b1-" or "b1-" = "b2-" or "b1-" = "bi-" or "b1-" = "bo-" then do:
       if use-column[27] then do: l-nk = l-nk + 1 .  run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , 0 ,  i). end.
    end.
    else do:
      if use-column[27] then do: l-nk = l-nk + 1 .  run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , ( if ABS(b1-oborot-ee         [1] +
                                                                                                                                    b1-oborot-re     [1] +
                                                                                                                                    b1-oborot-es    [1] +
                                                                                                                                    b1-oborot-rs[1] ) <> 0
                                                                                                                            then
                                                                                                                                ABS(b1-oborot-ee         [11] +
                                                                                                                                    b1-oborot-re     [11] +
                                                                                                                                    b1-oborot-es    [11] +
                                                                                                                                    b1-oborot-rs[11] )
                                                                                                                                /
                                                                                                                                ABS(b1-oborot-ee         [1] +
                                                                                                                                    b1-oborot-re     [1] +
                                                                                                                                    b1-oborot-es    [1] +
                                                                                                                                    b1-oborot-rs[1] )
                                                                                                                            else 0 )
      ,  i). end.
    end.
  end.
  else do:
  if use-column[27] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , (b1-oborot-ee         [i] +
                                                                                                                        b1-oborot-re     [i] +
                                                                                                                        b1-oborot-es    [i] +
                                                                                                                        b1-oborot-rs[i] )
  ,  i). end.
  end.
  end.
  if x-vat = false  and i = 2 then do:
  if use-column[6]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b1-ostatok-start                          [i] -  b1-ostatok-start                          [3] ),  i). end.
  if use-column[7]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b1-oborot-ie          [i] -  b1-oborot-ie          [3] ),  i). end.
  if use-column[8]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b1-oborot-iv          [i] -  b1-oborot-iv          [3] ),  i). end.
  if use-column[9]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b1-oborot-im           [i] -  b1-oborot-im           [3] ),  i). end.
  if use-column[10] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b1-oborot-ee          [i] -  b1-oborot-ee          [3] ),  i). end.
  if use-column[11] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b1-oborot-ev          [i] -  b1-oborot-ev          [3] ),  i). end.
  if use-column[12] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b1-oborot-em           [i] -  b1-oborot-em           [3] ),  i). end.
  if use-column[13] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b1-oborot-we          [i] -  b1-oborot-we          [3] ),  i). end.
  if use-column[14] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b1-oborot-es     [i] -  b1-oborot-es     [3] ),  i). end.
  if use-column[15] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b1-oborot-rs [i] -  b1-oborot-rs [3] ),  i). end.
  if use-column[16] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b1-oborot-re      [i] -  b1-oborot-re      [3] ),  i). end.
  if use-column[17] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b1-oborot-ep       [i] -  b1-oborot-ep       [3] ),  i). end.
  if use-column[18] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b1-oborot-rv      [i] -  b1-oborot-rv      [3] ),  i). end.
  if use-column[19] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b1-oborot-vt                [i] -  b1-oborot-vt                [3] ),  i). end.
  if use-column[20] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b1-oborot-ot           [i] -  b1-oborot-ot           [3] ),  i). end.
  if use-column[22] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b1-ostatok-end                            [i] -  b1-ostatok-end                            [3] ),  i). end.
  if use-column[25] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b1-oborot-ap [i] -  b1-oborot-ap[3] ),  i). end.
  if use-column[26] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b1-oborot-pc [i] -  b1-oborot-pc[3] ),  i). end.
  if i = 13 then do :
    if use-column[27] then do: l-nk = l-nk + 1 . run ex-display in this-procedure (mp-1 + ll + (kk * (l-nk - mp))  , 0  , i ). end.
  end.
  else do:
    if use-column[27] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,
    (                                                                                      (b1-oborot-ee         [i] +
                                                                                            b1-oborot-re     [i] +
                                                                                            b1-oborot-es    [i] +
                                                                                            b1-oborot-rs[i]) -
                                                                                          (b1-oborot-ee         [3] +
                                                                                            b1-oborot-re     [3] +
                                                                                            b1-oborot-es    [3] +
                                                                                            b1-oborot-rs[3] ) ) , i ). end.
  end.
  end.
  end.
 run new-tmp-page .
     run macr_cell_format
                        ( 10    ,
                          true  ,
                          true  ,
                          36    ,
                          num#str# ,
                          2,
                          num#str# ,
                          num#col#  ) .
  end.
  end.
end procedure.
procedure display-b2  :
define variable ll as int no-undo.
define variable kk as int no-undo.
b2-null-str#  = 1 .
b2-null-str2# = 1 .
  if not show-negativ   then  run b2-null-str-pr   in this-procedure .
  if not show-negativ-2 then  run b2-null-str-pr2  in this-procedure .
   if not  (not show-negativ   and b2-null-str#  = 0  ) then do :
      if not  (not show-negativ-2 and b2-null-str2# = 0  ) then do :
assign
  num#str# = num#str# + 1
  num#col# = 1.
  run macr_excel_char_with_format( string( s-bar-code + ' ' + gds-zap-artic + ' ' + gds-zap-gds-name)  , num#str# , num#col#  ) .
  num#col#  = 0 .
  if use-column[28] then assign num#col#  = num#col#  + 1 .
  if use-column[1] then  assign num#col#  = num#col#  + 1 .
  if use-column[2] then  assign num#col#  = num#col#  + 1 .
  if use-column[3] then  assign num#col#  = num#col#  + 1 .
  if use-column[4] then  assign num#col#  = num#col#  + 1 .
  if use-column[5] then  assign num#col#  = num#col#  + 1 .
if use-column[21] then do: Assign num#col#  = num#col#  + 1.   run macr_excel_dec ( Round(b2-oborot-disc [1],2 ), num#str# , num#col#   ).     end.
if use-column[23] then do: Assign num#col#  = num#col#  + 1.   run macr_excel_dec ( Round(b2-oborot-eff  [1],2 ), num#str# , num#col#   ).     end.
if use-column[24] then do: Assign num#col#  = num#col#  + 1.   run macr_excel_dec ( Round(b2-oborot-prc  [1],2 ), num#str# , num#col#   ).     end.
def var l-nk as integer no-undo .
  Assign
    LL = 0
    KK = 1
  .
  if xShowCost      Then DO: KK = KK + 1. End.
  if xShowCostNDS   Then DO: KK = KK + 1. End.
  if xShowCrsa      Then DO: KK = KK + 1. End.
  if xShowCrsaNds   Then DO: KK = KK + 1. End.
  if xShowSale      Then DO: KK = KK + 1. End.
  if xShowSaleNds   Then DO: KK = KK + 1. End.
  if xShowSaleslt   Then DO: KK = KK + 1. End.
  if xShowmediator  Then DO: KK = KK + 1. End.
  if x-tog-wt       then do: KK = KK + 1. End.
  if x-tog-ms       then do: KK = KK + 1. End.
  if xDens          then do: KK = KK + 1. End.
  repeat i = 1 to 13 :
    if i = 7 then next.
    if NOT xShowCost      and i = 2   Then  next.
    if NOT xShowCostNDS   and i = 3   Then  next.
    if NOT xShowCrsa      and i = 5   Then  next.
    if NOT xShowCrsaNds   and i = 6   Then  next.
    if NOT xShowSale      and i = 8   Then  next.
    if NOT xShowSaleNds   and i = 9   Then  next.
    if NOT xShowSaleSlt   and i = 10  Then  next.
    if NOT xShowmediator  and i = 4   Then  next.
    if not x-tog-wt       and i = 11  then  next.
    if not x-tog-ms       and i = 12  then  next.
    if not xDens          and i = 13  then  next.
    assign
      LL = LL + 1
      l-nk = mp-1
    .
  if x-vat or i <> 2  then do:
  if use-column[6]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b2-ostatok-start                          [i] ,  i). end.
  if use-column[7]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b2-oborot-ie          [i] ,  i). end.
  if use-column[8]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b2-oborot-iv          [i] ,  i). end.
  if use-column[9]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b2-oborot-im           [i] ,  i). end.
  if use-column[10] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b2-oborot-ee          [i] ,  i). end.
  if use-column[11] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b2-oborot-ev          [i] ,  i). end.
  if use-column[12] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b2-oborot-em           [i] ,  i). end.
  if use-column[13] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b2-oborot-we          [i] ,  i). end.
  if use-column[14] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b2-oborot-es     [i] ,  i). end.
  if use-column[15] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b2-oborot-rs [i] ,  i). end.
  if use-column[16] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b2-oborot-re      [i] ,  i). end.
  if use-column[17] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b2-oborot-ep       [i] ,  i). end.
  if use-column[18] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b2-oborot-rv      [i] ,  i). end.
  if use-column[19] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b2-oborot-vt                [i] ,  i). end.
  if use-column[20] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b2-oborot-ot           [i] ,  i). end.
  if use-column[22] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b2-ostatok-end                            [i] ,  i). end.
  if use-column[25] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b2-oborot-ap [i] ,  i). end.
  if use-column[26] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , b2-oborot-pc [i] ,  i). end.
  if i = 13 then do:
    if "b2-" = "b1-" or "b2-" = "b2-" or "b2-" = "bi-" or "b2-" = "bo-" then do:
       if use-column[27] then do: l-nk = l-nk + 1 .  run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , 0 ,  i). end.
    end.
    else do:
      if use-column[27] then do: l-nk = l-nk + 1 .  run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , ( if ABS(b2-oborot-ee         [1] +
                                                                                                                                    b2-oborot-re     [1] +
                                                                                                                                    b2-oborot-es    [1] +
                                                                                                                                    b2-oborot-rs[1] ) <> 0
                                                                                                                            then
                                                                                                                                ABS(b2-oborot-ee         [11] +
                                                                                                                                    b2-oborot-re     [11] +
                                                                                                                                    b2-oborot-es    [11] +
                                                                                                                                    b2-oborot-rs[11] )
                                                                                                                                /
                                                                                                                                ABS(b2-oborot-ee         [1] +
                                                                                                                                    b2-oborot-re     [1] +
                                                                                                                                    b2-oborot-es    [1] +
                                                                                                                                    b2-oborot-rs[1] )
                                                                                                                            else 0 )
      ,  i). end.
    end.
  end.
  else do:
  if use-column[27] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , (b2-oborot-ee         [i] +
                                                                                                                        b2-oborot-re     [i] +
                                                                                                                        b2-oborot-es    [i] +
                                                                                                                        b2-oborot-rs[i] )
  ,  i). end.
  end.
  end.
  if x-vat = false  and i = 2 then do:
  if use-column[6]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b2-ostatok-start                          [i] -  b2-ostatok-start                          [3] ),  i). end.
  if use-column[7]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b2-oborot-ie          [i] -  b2-oborot-ie          [3] ),  i). end.
  if use-column[8]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b2-oborot-iv          [i] -  b2-oborot-iv          [3] ),  i). end.
  if use-column[9]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b2-oborot-im           [i] -  b2-oborot-im           [3] ),  i). end.
  if use-column[10] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b2-oborot-ee          [i] -  b2-oborot-ee          [3] ),  i). end.
  if use-column[11] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b2-oborot-ev          [i] -  b2-oborot-ev          [3] ),  i). end.
  if use-column[12] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b2-oborot-em           [i] -  b2-oborot-em           [3] ),  i). end.
  if use-column[13] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b2-oborot-we          [i] -  b2-oborot-we          [3] ),  i). end.
  if use-column[14] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b2-oborot-es     [i] -  b2-oborot-es     [3] ),  i). end.
  if use-column[15] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b2-oborot-rs [i] -  b2-oborot-rs [3] ),  i). end.
  if use-column[16] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b2-oborot-re      [i] -  b2-oborot-re      [3] ),  i). end.
  if use-column[17] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b2-oborot-ep       [i] -  b2-oborot-ep       [3] ),  i). end.
  if use-column[18] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b2-oborot-rv      [i] -  b2-oborot-rv      [3] ),  i). end.
  if use-column[19] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b2-oborot-vt                [i] -  b2-oborot-vt                [3] ),  i). end.
  if use-column[20] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b2-oborot-ot           [i] -  b2-oborot-ot           [3] ),  i). end.
  if use-column[22] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b2-ostatok-end                            [i] -  b2-ostatok-end                            [3] ),  i). end.
  if use-column[25] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b2-oborot-ap [i] -  b2-oborot-ap[3] ),  i). end.
  if use-column[26] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( b2-oborot-pc [i] -  b2-oborot-pc[3] ),  i). end.
  if i = 13 then do :
    if use-column[27] then do: l-nk = l-nk + 1 . run ex-display in this-procedure (mp-1 + ll + (kk * (l-nk - mp))  , 0  , i ). end.
  end.
  else do:
    if use-column[27] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,
    (                                                                                      (b2-oborot-ee         [i] +
                                                                                            b2-oborot-re     [i] +
                                                                                            b2-oborot-es    [i] +
                                                                                            b2-oborot-rs[i]) -
                                                                                          (b2-oborot-ee         [3] +
                                                                                            b2-oborot-re     [3] +
                                                                                            b2-oborot-es    [3] +
                                                                                            b2-oborot-rs[3] ) ) , i ). end.
  end.
  end.
  end.
 run new-tmp-page .
  run macr_cell_format
  ( 10    ,
    true  ,
    true  ,
    33    ,
    num#str# ,
    1 ,
    num#str# ,
    num#col# ) .
  end.
  end.
end procedure.
procedure clear-b1  :
repeat kk = 1 to 13 :
assign
b1-oborot-ie         [kk] = 0
b1-oborot-ee         [kk] = 0
b1-oborot-ep      [kk] = 0
b1-oborot-es    [kk] = 0
b1-oborot-re     [kk] = 0
b1-oborot-rs [kk] = 0
b1-oborot-we         [kk] = 0
b1-oborot-vt               [kk] = 0
b1-oborot-iv         [kk] = 0
b1-oborot-ev         [kk] = 0
b1-oborot-rv     [kk] = 0
b1-oborot-em          [kk] = 0
b1-oborot-wm          [kk] = 0
b1-oborot-im          [kk] = 0
b1-oborot-ot          [kk] = 0
b1-oborot-disc                    [kk] = 0
b1-oborot-eff                     [kk] = 0
b1-oborot-prc                     [kk] = 0
b1-ostatok-end                           [kk] = 0
b1-ostatok-start                         [kk] = 0
b1-oborot-sum-sale                       [kk] = 0
b1-oborot-sum-cost                       [kk] = 0
b1-oborot-ap [kk] = 0
b1-oborot-pc [kk] = 0
.
end.
end procedure.
procedure clear-b2  :
repeat kk = 1 to 13 :
assign
b2-oborot-ie         [kk] = 0
b2-oborot-ee         [kk] = 0
b2-oborot-ep      [kk] = 0
b2-oborot-es    [kk] = 0
b2-oborot-re     [kk] = 0
b2-oborot-rs [kk] = 0
b2-oborot-we         [kk] = 0
b2-oborot-vt               [kk] = 0
b2-oborot-iv         [kk] = 0
b2-oborot-ev         [kk] = 0
b2-oborot-rv     [kk] = 0
b2-oborot-em          [kk] = 0
b2-oborot-wm          [kk] = 0
b2-oborot-im          [kk] = 0
b2-oborot-ot          [kk] = 0
b2-oborot-disc                    [kk] = 0
b2-oborot-eff                     [kk] = 0
b2-oborot-prc                     [kk] = 0
b2-ostatok-end                           [kk] = 0
b2-ostatok-start                         [kk] = 0
b2-oborot-sum-sale                       [kk] = 0
b2-oborot-sum-cost                       [kk] = 0
b2-oborot-ap [kk] = 0
b2-oborot-pc [kk] = 0
.
end.
end procedure.
procedure clear-bi  :
repeat kk = 1 to 13 :
assign
bi-oborot-ie         [kk] = 0
bi-oborot-ee         [kk] = 0
bi-oborot-ep      [kk] = 0
bi-oborot-es    [kk] = 0
bi-oborot-re     [kk] = 0
bi-oborot-rs [kk] = 0
bi-oborot-we         [kk] = 0
bi-oborot-vt               [kk] = 0
bi-oborot-iv         [kk] = 0
bi-oborot-ev         [kk] = 0
bi-oborot-rv     [kk] = 0
bi-oborot-em          [kk] = 0
bi-oborot-wm          [kk] = 0
bi-oborot-im          [kk] = 0
bi-oborot-ot          [kk] = 0
bi-oborot-disc                    [kk] = 0
bi-oborot-eff                     [kk] = 0
bi-oborot-prc                     [kk] = 0
bi-ostatok-end                           [kk] = 0
bi-ostatok-start                         [kk] = 0
bi-oborot-sum-sale                       [kk] = 0
bi-oborot-sum-cost                       [kk] = 0
bi-oborot-ap [kk] = 0
bi-oborot-pc [kk] = 0
.
end.
end procedure.
procedure ob-line  :
define input  parameter x-store-code     like ub.clients.obj-code     no-undo.
define input  parameter x-store-type     like ub.clients.obj-type     no-undo.
define input  parameter x-artic          like ub.ot-line.artic        no-undo.
define input  parameter x-prod-code      like ub.ot-line.prod-code    no-undo.
define input  parameter x-prod-type      like ub.ot-line.prod-type    no-undo.
define input  parameter x-fact-order-1   like ub.ot-line.fact-order   no-undo.
define input  parameter x-fact-order-2   like ub.ot-line.fact-order   no-undo.
define input  parameter x-sum-type       like ub.ot-line.sum-type     no-undo.
define input  parameter x-cat-id         like ub.ot-line.cat-id       no-undo.
define input  parameter x-ext-doc-type   like ub.ot-line.ext-doc-type no-undo.
define input  parameter xtog-obj           as log no-undo.
define variable  quantity#    like ub.ot-line.fact-qnty   no-undo.
define variable  coast_r#     like ub.ot-line.sum-rubl    no-undo.
define variable  coast_v#     like ub.ot-line.sum-rubl    no-undo.
define variable  vat_r#       like ub.ot-line.sum-rubl    no-undo.
define variable  vat_v#       like ub.ot-line.sum-rubl    no-undo.
define variable  slt_r#       like ub.ot-line.sum-rubl    no-undo.
define variable  slt_v#       like ub.ot-line.sum-rubl    no-undo.
define variable  v-summa  as decimal extent 4 no-undo .
define variable  tt#          as int no-undo.
define variable v-ii as integer no-undo .
define variable slt  as decimal no-undo .
define variable disc  as decimal no-undo .
define variable xi as integer no-undo .
define variable v-tt as integer no-undo .
 if (x-sum-type = 'cost':U  or x-sum-type = 'cssr':U) then assign tt# = 0 v-tt = 0.
    else
    if (x-sum-type = 'crsa':U  or x-sum-type = 'cgsr':U) then assign tt# = 3  v-tt = 100.
    else
    assign tt# = 6  v-tt = 200.
  if long-p = false then do :
  for each obj-list no-lock:
   if  xtog-obj then
       if   not(x-store-type     = obj-list.obj-type
            and x-store-code    = obj-list.obj-code ) then next.
        for each ub.ot-line where
                  ub.ot-line.artic         = x-artic
            and   ub.ot-line.prod-code    = x-prod-code
            and   ub.ot-line.prod-type    = x-prod-type
            and   ub.ot-line.fact-order   <= x-fact-order-2
            and   ub.ot-line.fact-order   >= x-fact-order-1
            and   ub.ot-line.obj-code     = obj-list.obj-code
            and   ub.ot-line.obj-type     = obj-list.obj-type
            and   ub.ot-line.sum-type     = x-sum-type
            no-lock :
            case ub.ot-line.ext-doc-type:
  WHEN 'ie':U THEN DO:
    ASSIGN oborot-ie[1 + tt#]   = oborot-ie[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-ie[2 + tt#]   = oborot-ie[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-ie[3 + tt#]   = oborot-ie[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-ie[10]   = oborot-ie[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'ee':U THEN DO:
    ASSIGN oborot-ee[1 + tt#]   = oborot-ee[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-ee[2 + tt#]   = oborot-ee[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-ee[3 + tt#]   = oborot-ee[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-ee[10]   = oborot-ee[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'ep':U THEN DO:
    ASSIGN oborot-ep[1 + tt#]   = oborot-ep[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-ep[2 + tt#]   = oborot-ep[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-ep[3 + tt#]   = oborot-ep[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-ep[10]   = oborot-ep[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'es':U THEN DO:
    ASSIGN oborot-es[1 + tt#]   = oborot-es[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-es[2 + tt#]   = oborot-es[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-es[3 + tt#]   = oborot-es[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-es[10]   = oborot-es[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 're':U THEN DO:
    ASSIGN oborot-re[1 + tt#]   = oborot-re[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-re[2 + tt#]   = oborot-re[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-re[3 + tt#]   = oborot-re[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-re[10]   = oborot-re[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'rs':U THEN DO:
    ASSIGN oborot-rs[1 + tt#]   = oborot-rs[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-rs[2 + tt#]   = oborot-rs[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-rs[3 + tt#]   = oborot-rs[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-rs[10]   = oborot-rs[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'we':U THEN DO:
    ASSIGN oborot-we[1 + tt#]   = oborot-we[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-we[2 + tt#]   = oborot-we[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-we[3 + tt#]   = oborot-we[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-we[10]   = oborot-we[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'vt':U  OR  WHEN 'mp':U OR WHEN 'vp':U THEN DO:
    ASSIGN oborot-vt[1 + tt#]   = oborot-vt[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-vt[2 + tt#]   = oborot-vt[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-vt[3 + tt#]   = oborot-vt[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
        if tt# = 6 Then  assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-vt[10]   = oborot-vt[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'iv':U THEN DO:
    ASSIGN oborot-iv[1 + tt#]   = oborot-iv[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-iv[2 + tt#]   = oborot-iv[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-iv[3 + tt#]   = oborot-iv[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-iv[10]   = oborot-iv[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'ev':U THEN DO:
    ASSIGN oborot-ev[1 + tt#]   = oborot-ev[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-ev[2 + tt#]   = oborot-ev[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-ev[3 + tt#]   = oborot-ev[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-ev[10]   = oborot-ev[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'rv':U THEN DO:
    ASSIGN oborot-rv[1 + tt#]   = oborot-rv[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-rv[2 + tt#]   = oborot-rv[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-rv[3 + tt#]   = oborot-rv[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-rv[10]   = oborot-rv[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'wm':U  OR  WHEN 'em':U THEN DO:
    ASSIGN oborot-em[1 + tt#]   = oborot-em[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-em[2 + tt#]   = oborot-em[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-em[3 + tt#]   = oborot-em[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
        if tt# = 6 Then  assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-em[10]   = oborot-em[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'im':U THEN DO:
    ASSIGN oborot-im[1 + tt#]   = oborot-im[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-im[2 + tt#]   = oborot-im[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-im[3 + tt#]   = oborot-im[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-im[10]   = oborot-im[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'ot':U THEN DO:
    ASSIGN oborot-ot[1 + tt#]   = oborot-ot[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-ot[2 + tt#]   = oborot-ot[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-ot[3 + tt#]   = oborot-ot[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-ot[10]   = oborot-ot[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'ap':U THEN DO:
    ASSIGN oborot-ap[1 + tt#]   = oborot-ap[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-ap[2 + tt#]   = oborot-ap[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-ap[3 + tt#]   = oborot-ap[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-ap[10]   = oborot-ap[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'pc':U THEN DO:
    ASSIGN oborot-pc[1 + tt#]   = oborot-pc[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-pc[2 + tt#]   = oborot-pc[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-pc[3 + tt#]   = oborot-pc[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-pc[10]   = oborot-pc[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
            end case.
        end.
   end.
end.
else do:
xi = 1 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-ie [1 + tt#] ,output  oborot-ie [2 + tt#] ,output  oborot-ie [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-ie[10]    = oborot-ie[10]    + slt  .
xi = 2 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-ee [1 + tt#] ,output  oborot-ee [2 + tt#] ,output  oborot-ee [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-ee[10]    = oborot-ee[10]    + slt  .
xi = 3 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-ep [1 + tt#] ,output  oborot-ep [2 + tt#] ,output  oborot-ep [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-ep[10]    = oborot-ep[10]    + slt  .
xi = 4 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-es [1 + tt#] ,output  oborot-es [2 + tt#] ,output  oborot-es [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-es[10]    = oborot-es[10]    + slt  .
xi = 5 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-re [1 + tt#] ,output  oborot-re [2 + tt#] ,output  oborot-re [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-re[10]    = oborot-re[10]    + slt  .
xi = 6 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-rs [1 + tt#] ,output  oborot-rs [2 + tt#] ,output  oborot-rs [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-rs[10]    = oborot-rs[10]    + slt  .
xi = 7 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-we [1 + tt#] ,output  oborot-we [2 + tt#] ,output  oborot-we [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-we[10]    = oborot-we[10]    + slt  .
xi = 8 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-vt [1 + tt#] ,output  oborot-vt [2 + tt#] ,output  oborot-vt [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-vt[10]    = oborot-vt[10]    + slt  .
xi = 9 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-iv [1 + tt#] ,output  oborot-iv [2 + tt#] ,output  oborot-iv [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-iv[10]    = oborot-iv[10]    + slt  .
xi = 10 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-ev [1 + tt#] ,output  oborot-ev [2 + tt#] ,output  oborot-ev [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-ev[10]    = oborot-ev[10]    + slt  .
xi = 11 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-rv [1 + tt#] ,output  oborot-rv [2 + tt#] ,output  oborot-rv [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-rv[10]    = oborot-rv[10]    + slt  .
xi = 12 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-em [1 + tt#] ,output  oborot-em [2 + tt#] ,output  oborot-em [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-em[10]    = oborot-em[10]    + slt  .
xi = 13 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-im [1 + tt#] ,output  oborot-im [2 + tt#] ,output  oborot-im [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-im[10]    = oborot-im[10]    + slt  .
xi = 14 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-ot [1 + tt#] ,output  oborot-ot [2 + tt#] ,output  oborot-ot [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-ot[10]    = oborot-ot[10]    + slt  .
xi = 15 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-ap [1 + tt#] ,output  oborot-ap [2 + tt#] ,output  oborot-ap [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-ap[10]    = oborot-ap[10]    + slt  .
xi = 16 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-pc [1 + tt#] ,output  oborot-pc [2 + tt#] ,output  oborot-pc [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-pc[10]    = oborot-pc[10]    + slt  .
end.
  if tt# = 6 then do:
  if  xshowmediator = false then
      oborot-sum-cost[1] =
      oborot-ee[2]      +
      oborot-es[2] +
      oborot-re[2]  +
      oborot-rs[2]
      .
      else
      oborot-sum-cost[1] =
      oborot-ee[4]      +
      oborot-es[4] +
      oborot-re[4]  +
      oborot-rs[4]
      .
     repeat v-ii = 1 to 1 :
     v-summa[v-ii ]  =
        oborot-ie[v-ii ] + oborot-ee[v-ii ] + oborot-ep[v-ii ] +
        oborot-es[v-ii ] + oborot-re[v-ii ] + oborot-rs[v-ii ] +
        oborot-we[v-ii ] + oborot-vt[v-ii ] + oborot-iv[v-ii ] +
        oborot-ev[v-ii ] + oborot-rv[v-ii ] + oborot-em[v-ii ] +
        oborot-im[v-ii ] .
     end.
     repeat v-ii = 2 to 4 :
     v-summa[v-ii ]  =
        oborot-ie[v-ii + tt#] + oborot-ee[v-ii + tt#] + oborot-ep[v-ii + tt#] +
        oborot-es[v-ii + tt#] + oborot-re[v-ii + tt#] + oborot-rs[v-ii + tt#] +
        oborot-we[v-ii + tt#] + oborot-vt[v-ii + tt#] + oborot-iv[v-ii + tt#] +
        oborot-ev[v-ii + tt#] + oborot-rv[v-ii + tt#] + oborot-em[v-ii + tt#] +
        oborot-im[v-ii + tt#] .
     end.
      oborot-sum-sale[1] =
      oborot-ee[2 + tt#] +
      oborot-es[2 + tt#] +
      oborot-re[2 + tt#] +
      oborot-rs[2 + tt#]
      .
       assign oborot-ot[1 + tt#] = (ostatok-end[1 + tt#]  - ostatok-start[1 + tt#])  -  (v-summa[1])
        oborot-ot[2 + tt#] = (ostatok-end[2 + tt#]  - ostatok-start[2 + tt#])  -  (v-summa[2])
                                                                                                  -  oborot-disc[1]
        oborot-ot[3 + tt#] = (ostatok-end[3 + tt#]  - ostatok-start[3 + tt#])  -  (v-summa[3])
        oborot-ot[10] = (ostatok-end[10]  - ostatok-start[10])                 -  (v-summa[4])
        .
        oborot-eff[1] = -1 * (oborot-sum-sale[1] - oborot-sum-cost[1]) .
        if oborot-sum-cost[1] <>  0 then
          oborot-prc[1] = 100 * (oborot-sum-sale[1] - oborot-sum-cost[1] ) / oborot-sum-cost[1].
          else oborot-prc[1] = 0.
  end.
oborot-ie[4]   = Round(oborot-ie[1]   *  p-price-med , 2) .
oborot-ee[4]   = Round(oborot-ee[1]   *  p-price-med , 2) .
oborot-ep[4]   = Round(oborot-ep[1]   *  p-price-med , 2) .
oborot-es[4]   = Round(oborot-es[1]   *  p-price-med , 2) .
oborot-re[4]   = Round(oborot-re[1]   *  p-price-med , 2) .
oborot-rs[4]   = Round(oborot-rs[1]   *  p-price-med , 2) .
oborot-we[4]   = Round(oborot-we[1]   *  p-price-med , 2) .
oborot-vt[4]   = Round(oborot-vt[1]   *  p-price-med , 2) .
oborot-iv[4]   = Round(oborot-iv[1]   *  p-price-med , 2) .
oborot-ev[4]   = Round(oborot-ev[1]   *  p-price-med , 2) .
oborot-rv[4]   = Round(oborot-rv[1]   *  p-price-med , 2) .
oborot-em[4]   = Round(oborot-em[1]   *  p-price-med , 2) .
oborot-im[4]   = Round(oborot-im[1]   *  p-price-med , 2) .
oborot-ot[4]   = Round(oborot-ot[1]   *  p-price-med , 2) .
oborot-ap[4]   = Round(oborot-ap[1]   *  p-price-med , 2) .
oborot-pc[4]   = Round(oborot-pc[1]   *  p-price-med , 2) .
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
        Quantity = Quantity + buff-stk-line.fact-qnty
        Coast_R  = Coast_R  + buff-stk-line.sum-rubl
        Coast_V  = Coast_V  + buff-stk-line.sum-base
        VAT_R    = VAT_R    + buff-stk-line.VAT-rubl
        VAT_V    = VAT_V    + buff-stk-line.VAT-base
        SLT_R    = SLT_R    + buff-stk-line.SLT-rubl
        SLT_V    = SLT_V    + buff-stk-line.SLT-base
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
        Quantity = Quantity + buff-stk-line.fact-qnty
        Coast_R  = Coast_R  + buff-stk-line.sum-rubl
        Coast_V  = Coast_V  + buff-stk-line.sum-base
        VAT_R    = VAT_R    + buff-stk-line.VAT-rubl
        VAT_V    = VAT_V    + buff-stk-line.VAT-base
        SLT_R    = SLT_R    + buff-stk-line.SLT-rubl
        SLT_V    = SLT_V    + buff-stk-line.SLT-base
        other_R  = other_R  + buff-stk-line.other-rubl
        other_V  = other_V  + buff-stk-line.other-base
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
PROCEDURE ostatok :
def input parameter x-store-code  like ub.clients.obj-code    no-undo.
def input parameter x-store-type  like ub.clients.obj-type    no-undo.
def input parameter x-tog-shift   as   logical             no-undo.
def input parameter x-date-start  like ub.stk-tot.Fact-date   no-undo.
def input parameter x-date-end    like ub.stk-tot.Fact-date   no-undo.
def input parameter x-shift-start as integer               no-undo.
def input parameter x-shift-end   as integer               no-undo.
def input parameter x-sum-type    like ub.stk-tot.sum-type    no-undo.
def input parameter x-cat-id      like ub.stk-tot.cat-id      no-undo.
def input parameter xTog-obj   as log no-undo.
def output parameter Quantity    like ub.stk-tot.fact-qnty   no-undo.
def output parameter Coast_R     like ub.stk-tot.sum-rubl    no-undo.
def output parameter Coast_V     like ub.stk-tot.sum-rubl    no-undo.
def output parameter VAT_R       like ub.stk-tot.sum-rubl    no-undo.
def output parameter VAT_V       like ub.stk-tot.sum-rubl    no-undo.
def output parameter Fact-order  like ub.stk-tot.Fact-order  no-undo.
def var              Fact-order#   like ub.stk-tot.Fact-order  no-undo.
def var              Fact-orderS   as char  no-undo.
def var x-date-start-t  like ub.stk-tot.shift-date   no-undo.
   Assign
      Fact-order   = 0
      Quantity     = 0
      Coast_R      = 0
      Coast_V      = 0
      VAT_R        = 0
      VAT_V        = 0 .
 x-date-start-t  = x-date-start + 1 .
IF x-date-end = date('') then DO:
   Fact-order = 0 .
   for each obj-list
       where  ( not xtog-obj or
              ( x-store-type = obj-list.obj-type and x-store-code = obj-list.obj-code ))
              no-lock :
      if  x-tog-shift = false then do:
                       find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
                            ub.stk-tot.Fact-date <=  x-date-start
                            and ub.stk-tot.shift-num = 0
                            USE-INDEX fact-date no-lock no-error .
           if Available ub.stk-tot THEN  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
      End.
      Else  DO :
          find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
           (ub.stk-tot.shift-date  = x-date-start-t and
            ub.stk-tot.shift-num  < x-shift-start or
            ub.stk-tot.shift-date  < x-date-start-t  )
            and ub.stk-tot.shift-num  > 0
            USE-INDEX Shift-num no-lock no-error .
         If Available ub.stk-tot then  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
        END.
    If Fact-order < Fact-order#  and Fact-order# <> 0  THEN  Fact-order = Fact-order# .
  End.
End.
Else DO:
  For each obj-list  WHERE
     (NOT xTog-obj OR (x-store-type = obj-list.obj-type AND x-store-code = obj-list.obj-code))
      no-lock :
   IF  x-TOG-Shift = False Then DO:
       find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
            ub.stk-tot.Fact-date <= x-date-end
            and ub.stk-tot.shift-num = 0
            USE-INDEX fact-date no-lock no-error.
       if available ub.stk-tot then  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
   END.
   Else DO:
        find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
            (ub.stk-tot.shift-date  = x-date-end and
            ub.stk-tot.shift-num  <= x-shift-end or
            ub.stk-tot.shift-date  < x-date-end       ) and
            ub.stk-tot.shift-num   > 0      use-index shift-num no-lock no-error.
            if Available ub.stk-tot THEN Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
    End.
    if Fact-order < Fact-order#  THEN  Fact-order = Fact-order#.
  End.
End.
END PROCEDURE.
procedure report-exec1  :
   find first clients where x-store-type = clients.obj-type and
                            x-store-code = clients.obj-code
                            no-lock no-error.
           if available clients then assign  objname = clients.obj-name
                                             x-db-num     = clients.db-num.
                                         else  objname="объект не определен".
  run calcitog in this-procedure .
  run print-header in this-procedure .      case retclassify :
   when "grp-goods":u      then  run run2 in this-procedure .
   otherwise do:
     message "Ошибка вызова" view-as alert-box error .
   end.
   end case.
  run print-footer in this-procedure .
  end procedure.
procedure calc-sub-itog :
define input parameter tt as int no-undo.
define variable tt2 as integer no-undo .
  if tt = 6 then tt2 = 7 .
            else tt2 = tt.
repeat i# = 1 + tt to 3 + tt2 :
run sum-i (
 input oborot-vt[i#]
,input tt
,input-output b1-oborot-vt[i#]
,input-output b2-oborot-vt[i#]
,input-output bi-oborot-vt[i#]
,input-output bo-oborot-vt[i#]
,input oborot-ie[i#]
,input-output b1-oborot-ie[i#]
,input-output b2-oborot-ie[i#]
,input-output bi-oborot-ie[i#]
,input-output bo-oborot-ie[i#]
) .
run sum-i (
 input oborot-iv[i#]
,input tt
,input-output b1-oborot-iv[i#]
,input-output b2-oborot-iv[i#]
,input-output bi-oborot-iv[i#]
,input-output bo-oborot-iv[i#]
,input oborot-ee[i#]
,input-output b1-oborot-ee[i#]
,input-output b2-oborot-ee[i#]
,input-output bi-oborot-ee[i#]
,input-output bo-oborot-ee[i#]
) .
run sum-i (
 input oborot-ev[i#]
,input tt
,input-output b1-oborot-ev[i#]
,input-output b2-oborot-ev[i#]
,input-output bi-oborot-ev[i#]
,input-output bo-oborot-ev[i#]
,input oborot-ep[i#]
,input-output b1-oborot-ep[i#]
,input-output b2-oborot-ep[i#]
,input-output bi-oborot-ep[i#]
,input-output bo-oborot-ep[i#]
) .
run sum-i (
 input oborot-rv[i#]
,input tt
,input-output b1-oborot-rv[i#]
,input-output b2-oborot-rv[i#]
,input-output bi-oborot-rv[i#]
,input-output bo-oborot-rv[i#]
,input oborot-es[i#]
,input-output b1-oborot-es[i#]
,input-output b2-oborot-es[i#]
,input-output bi-oborot-es[i#]
,input-output bo-oborot-es[i#]
) .
run sum-i (
 input oborot-em[i#]
,input tt
,input-output b1-oborot-em[i#]
,input-output b2-oborot-em[i#]
,input-output bi-oborot-em[i#]
,input-output bo-oborot-em[i#]
,input oborot-re[i#]
,input-output b1-oborot-re[i#]
,input-output b2-oborot-re[i#]
,input-output bi-oborot-re[i#]
,input-output bo-oborot-re[i#]
) .
run sum-i (
 input oborot-im[i#]
,input tt
,input-output b1-oborot-im[i#]
,input-output b2-oborot-im[i#]
,input-output bi-oborot-im[i#]
,input-output bo-oborot-im[i#]
,input oborot-rs[i#]
,input-output b1-oborot-rs[i#]
,input-output b2-oborot-rs[i#]
,input-output bi-oborot-rs[i#]
,input-output bo-oborot-rs[i#]
) .
run sum-i (
 input oborot-ot[i#]
,input tt
,input-output b1-oborot-ot[i#]
,input-output b2-oborot-ot[i#]
,input-output bi-oborot-ot[i#]
,input-output bo-oborot-ot[i#]
,input oborot-we[i#]
,input-output b1-oborot-we[i#]
,input-output b2-oborot-we[i#]
,input-output bi-oborot-we[i#]
,input-output bo-oborot-we[i#]
) .
run sum-i (
 input oborot-ap[i#]
,input tt
,input-output b1-oborot-ap[i#]
,input-output b2-oborot-ap[i#]
,input-output bi-oborot-ap[i#]
,input-output bo-oborot-ap[i#]
,input oborot-pc[i#]
,input-output b1-oborot-pc[i#]
,input-output b2-oborot-pc[i#]
,input-output bi-oborot-pc[i#]
,input-output bo-oborot-pc[i#]
) .
  b1-oborot-em[ i#] = b1-oborot-em[ i#] + oborot-wm[ i#].
  b2-oborot-em[ i#] = b2-oborot-em[ i#] + oborot-wm[ i#].
  bi-oborot-em[ i#] = bi-oborot-em[ i#] + oborot-wm[ i#].
  bo-oborot-em[ i#] = bo-oborot-em[ i#] + oborot-wm[ i#].
  bo-ostatok-start[ i#]  = bo-ostatok-start[i#]  + ostatok-start[ i#]  .
  bo-ostatok-end[ i#]    = bo-ostatok-end[i#]    + ostatok-end[ i#]    .
  if i# = 7 then b1-oborot-disc[1 ]  = b1-oborot-disc[1]  + oborot-disc[1]  .
  if i# = 7 then b2-oborot-disc[1 ]  = b2-oborot-disc[1]  + oborot-disc[1]  .
  if i# = 7 then bi-oborot-disc[1 ]  = bi-oborot-disc[1]  + oborot-disc[1]  .
  if i# = 7 then bo-oborot-disc[1 ]  = bo-oborot-disc[1]  + oborot-disc[1]  .
  if i# = 8 then
    assign
      bi-oborot-sum-sale[ i#]  = bi-oborot-ee[ i#] +
                              bi-oborot-re[ i#]         +
                              bi-oborot-rs[ i#]    +
                              bi-oborot-es[ i#]
      b1-oborot-sum-sale[ i#]  = b1-oborot-ee[ i#] +
                              b1-oborot-re[ i#]         +
                              b1-oborot-rs[ i#]    +
                              b1-oborot-es[ i#]
      b2-oborot-sum-sale[ i#]  = b2-oborot-ee[ i#] +
                              b2-oborot-re[ i#]         +
                              b2-oborot-rs[ i#]    +
                              b2-oborot-es[ i#]
      bo-oborot-sum-sale[ i#]  = bo-oborot-ee[ i#] +
                              bo-oborot-re[ i#]         +
                              bo-oborot-rs[ i#]    +
                              bo-oborot-es[ i#]
      .
  if  xshowmediator = true  then do:
      if i# = 8 then b1-oborot-sum-cost[2 ]  = b1-oborot-sum-cost[2]  + oborot-sum-cost[1]  .
      if i# = 8 then b2-oborot-sum-cost[2 ]  = b2-oborot-sum-cost[2]  + oborot-sum-cost[1]  .
      if i# = 8 then bi-oborot-sum-cost[2 ]  = bi-oborot-sum-cost[2]  + oborot-sum-cost[1]  .
      if i# = 8 then bo-oborot-sum-cost[2 ]  = bo-oborot-sum-cost[2]  + oborot-sum-cost[1]  .
  end.
  if i# = 2 and xshowmediator = false  then
      assign
        bi-oborot-sum-cost[ i#]  = bi-oborot-ee[ i#] +
                                bi-oborot-re[ i#]         +
                                bi-oborot-rs[ i#]    +
                                bi-oborot-es[ i#]
        b1-oborot-sum-cost[ i#]  = b1-oborot-ee[ i#] +
                                b1-oborot-re[ i#]         +
                                b1-oborot-rs[ i#]    +
                                b1-oborot-es[ i#]
        b2-oborot-sum-cost[ i#]  = b2-oborot-ee[ i#] +
                                b2-oborot-re[ i#]         +
                                b2-oborot-rs[ i#]    +
                                b2-oborot-es[ i#]
        bo-oborot-sum-cost[ i#]  = bo-oborot-ee[ i#] +
                                bo-oborot-re[ i#]         +
                                bo-oborot-rs[ i#]    +
                                bo-oborot-es[ i#]
        .
  if i# = 8 then b1-oborot-eff[1 ]  = b1-oborot-eff[1]  + oborot-eff[1]  .
  if i# = 8 then b2-oborot-eff[1 ]  = b2-oborot-eff[1]  + oborot-eff[1]  .
  if i# = 8 then bi-oborot-eff[1 ]  = bi-oborot-eff[1]  + oborot-eff[1]  .
  if i# = 8 then bo-oborot-eff[1 ]  = bo-oborot-eff[1]  + oborot-eff[1]  .
  if i# = 8 then    if  bi-oborot-sum-cost[2] <>  0 then
                        bi-oborot-prc[1] = 100 * (bi-oborot-sum-sale[8] - bi-oborot-sum-cost[2] ) / bi-oborot-sum-cost[2] .
                   else bi-oborot-prc[1] = 0.
  if i# = 8 then    if  bo-oborot-sum-cost[2] <>  0 then
                        bo-oborot-prc[1] = 100 * (bo-oborot-sum-sale[8] - bo-oborot-sum-cost[2] ) / bo-oborot-sum-cost[2] .
                   else bo-oborot-prc[1] = 0.
  if i# = 8 then    if  b1-oborot-sum-cost[2] <>  0 then
                        b1-oborot-prc[1] = 100 * (b1-oborot-sum-sale[8] - b1-oborot-sum-cost[2] ) / b1-oborot-sum-cost[2] .
                   else b1-oborot-prc[1] = 0.
  if i# = 8 then    if  b2-oborot-sum-cost[2] <>  0 then
                        b2-oborot-prc[1] = 100 * (b2-oborot-sum-sale[8] - b2-oborot-sum-cost[2] ) / b2-oborot-sum-cost[2] .
                   else b2-oborot-prc[1] = 0.
 end.
end procedure.
procedure sum-i :
define input parameter ob like oborot-ot[1] no-undo.
define input parameter tt as int  no-undo.
define input-output parameter b1 like b1-oborot-ot[1] no-undo.
define input-output parameter b2 like b1-oborot-ot[1] no-undo.
define input-output parameter bi like b1-oborot-ot[1] no-undo.
define input-output parameter bo like b1-oborot-ot[1] no-undo.
define input parameter ob2 like oborot-ot[1] no-undo.
define input-output parameter b1- like b1-oborot-ot[1] no-undo.
define input-output parameter b2- like b1-oborot-ot[1] no-undo.
define input-output parameter bi- like b1-oborot-ot[1] no-undo.
define input-output parameter bo- like b1-oborot-ot[1] no-undo.
assign
 b1  = b1 + ob
 b2  = b2 + ob
 b1- = b1- + ob2
 b2- = b2- + ob2
 .
    assign
    bi = bi + ob
    bo = bo + ob
    bi- = bi- + ob2
    bo- = bo- + ob2
    .
end procedure.
procedure clear-item :
define variable kk as int no-undo.
 repeat kk = 1 to 13 :
 assign
    oborot-ie                 [kk]    = 0
    oborot-ee                 [kk]    = 0
    oborot-ep              [kk]    = 0
    oborot-es            [kk]    = 0
    oborot-re             [kk]    = 0
    oborot-rs        [kk]    = 0
    oborot-we                 [kk]    = 0
    oborot-vt                       [kk]    = 0
    oborot-iv                 [kk]    = 0
    oborot-ev                 [kk]    = 0
    oborot-rv             [kk]    = 0
    oborot-em                  [kk]    = 0
    oborot-wm                  [kk]    = 0
    oborot-im                  [kk]    = 0
    oborot-ot                  [kk]    = 0
    oborot-disc                             [kk]    = 0
    oborot-eff                              [kk]    = 0
    oborot-prc                              [kk]    = 0
    oborot-ap            [kk]    = 0
    oborot-pc            [kk]    = 0
    ostatok-end                                    [kk]    = 0
    ostatok-start                                  [kk]    = 0
  .
 end.
end procedure.
procedure item-goods :
 define input parameter  par-3 as char no-undo.
 define input parameter  par-4 as char no-undo.
     if par-4 = "goods":u  then  assign
                                    gds-zap-unit-base  = goods.unit-base
                                    gds-zap-prt-root   = goods.prt-root
                                    gds-zap-prod-type  = goods.prod-type
                                    gds-zap-prod-code  = goods.prod-code
                                    gds-zap-artic      = goods.artic
                                    gds-zap-type       = goods.gds-type
                                    gds-zap-grp-name   = goods.grp-name
                                    gds-zap-b-code     = goods.gds-code
                                    gds-zap-gds-name   = if g#gds-engl then goods.engl-name
                                                                       else goods.gds-name
                                    gds-zap-gds-long-name = substring ((if goods.engl-name <> ? then trim(goods.engl-name) else "" ) +
                                                            ( if goods.label-name <> ? then trim(goods.label-name) else "" ),1,120).
     if par-4 = "gds-list":u  then  assign
                                    gds-zap-unit-base  = gds-list.unit-base
                                    gds-zap-prt-root   = gds-list.prt-root
                                    gds-zap-prod-type  = gds-list.prod-type
                                    gds-zap-prod-code  = gds-list.prod-code
                                    gds-zap-artic      = gds-list.artic
                                    gds-zap-type       = gds-list.gds-type
                                    gds-zap-grp-name   = gds-list.grp-name
                                    gds-zap-b-code     = gds-list.gds-code
                                    gds-zap-gds-name   = if g#gds-engl then gds-list.engl-name
                                                                       else gds-list.gds-name
                                    gds-zap-gds-long-name = substring ((if gds-list.engl-name <> ? then trim(gds-list.engl-name) else "" ) +
                                                            ( if gds-list.label-name <> ? then trim(gds-list.label-name) else ""), 1,120).
    run foreach in this-procedure .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  gds-zap-b-code
  ,input  ?
  ,output v-bar-code
  )  .
s-bar-code = string (v-bar-code,"999999999").
    If  break_group = true  and par-3 <> "1"  then DO :
         FIND FIRST clients WHERE clients.obj-type = gds-zap-prod-type AND clients.obj-code = gds-zap-prod-code use-index pi NO-LOCK .
         gds-zap-prod-name  = clients.obj-name.
          If break_group1 = true  THEN  DO :
            if (par-3 = "3"  OR  par-3 = "5" ) and  par-3 <> "6"
              then DO: Assign temp-str = string("ГРУППА : " + gds-zap-grp-name )         b1-name = gds-zap-grp-name . end.
              else DO: Assign temp-str = string("ПРОИЗВОДИТЕЛЬ : " + gds-zap-prod-name ) b1-name = gds-zap-prod-name. end.
            if par-3 = "6"  then  dO:
               if xTog-obj = true then do:
                var-vat-pc = (func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code)) .
                end.
               else do:
                var-vat-pc = temp-gds-list.vat-pc  .
                end.
                assign
                    temp-str = string( "СТАВКА НДС : " + string(var-vat-pc) + "%" )
                    b1-name = temp-str .
                end.
            if NOT xSumsOnly or (par-3 = "4" Or par-3 = "5" ) THEN DO :
                fr0 = true .
                tmp#stroka0 = temp-str.
            End .
          End .
          IF (par-3 = "4"  OR  par-3 = "5")  THEN DO :
            if par-3 = "4"
              then Assign temp-str = string("ГРУППА : " + gds-zap-grp-name )          b2-name = gds-zap-grp-name  .
              else Assign temp-str = string("ПРОИЗВОДИТЕЛЬ : " + gds-zap-prod-name )  b2-name = gds-zap-prod-name .
            if NOT xSumsOnly THEN DO :
            fr = true .
            End.
            break_group1 = false.
          END.
       break_group = false.
    End.
    run display-line in this-procedure .
 end procedure.
procedure b1-null-str-pr :
 if (
     b1-oborot-im                 [1] = 0 and
     b1-oborot-wm                 [1] = 0 and
     b1-oborot-em                 [1] = 0 and
     b1-oborot-ie                 [1] = 0 and
     b1-oborot-ee                 [1] = 0 and
     b1-oborot-ep              [1] = 0 and
     b1-oborot-es            [1] = 0 and
     b1-oborot-re             [1] = 0 and
     b1-oborot-rs        [1] = 0 and
     b1-oborot-we                 [1] = 0 and
     b1-oborot-vt                       [1] = 0 and
     b1-oborot-iv                [1] = 0 and
     b1-oborot-ev                [1] = 0 and
     b1-oborot-rv            [1] = 0 and
     b1-oborot-ot                 [2] = 0 and
     b1-oborot-ap           [1] = 0 and
     b1-oborot-pc           [1] = 0 and
     b1-ostatok-end[1]                                    = 0 and
     b1-ostatok-start[1]                                  = 0 and
     b1-oborot-im                 [2] = 0 and
     b1-oborot-wm                 [2] = 0 and
     b1-oborot-em                 [2] = 0 and
     b1-oborot-ie                 [2] = 0 and
     b1-oborot-ee                 [2] = 0 and
     b1-oborot-ep              [2] = 0 and
     b1-oborot-es            [2] = 0 and
     b1-oborot-re             [2] = 0 and
     b1-oborot-rs        [2] = 0 and
     b1-oborot-we                 [2] = 0 and
     b1-oborot-vt                       [2] = 0 and
     b1-oborot-iv                [2] = 0 and
     b1-oborot-ev                [2] = 0 and
     b1-oborot-rv            [2] = 0 and
     b1-oborot-ap           [2] = 0 and
     b1-oborot-pc           [2] = 0 and
     b1-ostatok-end[2]                                    = 0 and
     b1-ostatok-start[2]                                  = 0
     ) then  b1-null-str# = 0    .
end procedure.
procedure b1-null-str-pr2 :
 if (
     b1-oborot-im                 [1] = 0 and
     b1-oborot-wm                 [1] = 0 and
     b1-oborot-em                 [1] = 0 and
     b1-oborot-ie                 [1] = 0 and
     b1-oborot-ee                 [1] = 0 and
     b1-oborot-ep              [1] = 0 and
     b1-oborot-es            [1] = 0 and
     b1-oborot-re             [1] = 0 and
     b1-oborot-rs        [1] = 0 and
     b1-oborot-we                 [1] = 0 and
     b1-oborot-vt                       [1] = 0 and
     b1-oborot-iv                [1] = 0 and
     b1-oborot-ev                [1] = 0 and
     b1-oborot-rv            [1] = 0 and
     b1-oborot-ap           [1] = 0 and
     b1-oborot-pc           [1] = 0 and
     b1-oborot-ot                 [1] = 0 and
     b1-oborot-ot                 [2] = 0 and
     b1-oborot-im                 [2] = 0 and
     b1-oborot-wm                 [2] = 0 and
     b1-oborot-em                 [2] = 0 and
     b1-oborot-ie                 [2] = 0 and
     b1-oborot-ee                 [2] = 0 and
     b1-oborot-ep              [2] = 0 and
     b1-oborot-es            [2] = 0 and
     b1-oborot-re             [2] = 0 and
     b1-oborot-rs        [2] = 0 and
     b1-oborot-we                 [2] = 0 and
     b1-oborot-vt                       [2] = 0 and
     b1-oborot-iv                [2] = 0 and
     b1-oborot-ev                [2] = 0 and
     b1-oborot-rv            [2] = 0 and
     b1-oborot-ap           [2] = 0 and
     b1-oborot-pc           [2] = 0
      ) then   b1-null-str2# = 0    .
    end procedure.
procedure b2-null-str-pr :
 if (
     b2-oborot-im                 [1] = 0 and
     b2-oborot-em                 [1] = 0 and
     b2-oborot-wm                 [1] = 0 and
     b2-oborot-ie                 [1] = 0 and
     b2-oborot-ee                 [1] = 0 and
     b2-oborot-ep              [1] = 0 and
     b2-oborot-es            [1] = 0 and
     b2-oborot-re             [1] = 0 and
     b2-oborot-rs        [1] = 0 and
     b2-oborot-we                 [1] = 0 and
     b2-oborot-vt                       [1] = 0 and
     b2-oborot-iv                [1] = 0 and
     b2-oborot-ev                [1] = 0 and
     b2-oborot-rv            [1] = 0 and
     b2-oborot-ap           [1] = 0 and
     b2-oborot-pc           [1] = 0 and
     b2-oborot-ot                 [2] = 0 and
     b2-ostatok-end[1]                                    = 0 and
     b2-ostatok-start[1]                                  = 0 and
     b2-oborot-im                 [2] = 0 and
     b2-oborot-em                 [2] = 0 and
     b2-oborot-wm                 [2] = 0 and
     b2-oborot-ie                 [2] = 0 and
     b2-oborot-ee                 [2] = 0 and
     b2-oborot-ep              [2] = 0 and
     b2-oborot-es            [2] = 0 and
     b2-oborot-re             [2] = 0 and
     b2-oborot-rs        [2] = 0 and
     b2-oborot-we                 [2] = 0 and
     b2-oborot-vt                       [2] = 0 and
     b2-oborot-iv                [2] = 0 and
     b2-oborot-ev                [2] = 0 and
     b2-oborot-rv            [2] = 0 and
     b2-oborot-ap           [2] = 0 and
     b2-oborot-pc           [2] = 0 and
     b2-ostatok-end[2]                                    = 0 and
     b2-ostatok-start[2]                                  = 0
          ) then  b2-null-str# = 0    .
end procedure.
procedure b2-null-str-pr2 :
 if (
     b2-oborot-im                 [1] = 0 and
     b2-oborot-wm                 [1] = 0 and
     b2-oborot-em                 [1] = 0 and
     b2-oborot-ie                 [1] = 0 and
     b2-oborot-ee                 [1] = 0 and
     b2-oborot-ep              [1] = 0 and
     b2-oborot-es            [1] = 0 and
     b2-oborot-re             [1] = 0 and
     b2-oborot-rs        [1] = 0 and
     b2-oborot-we                 [1] = 0 and
     b2-oborot-vt                       [1] = 0 and
     b2-oborot-iv                [1] = 0 and
     b2-oborot-ev                [1] = 0 and
     b2-oborot-rv            [1] = 0 and
     b2-oborot-ot                 [1] = 0 and
     b2-oborot-ap           [1] = 0 and
     b2-oborot-pc           [1] = 0 and
     b2-oborot-ot                 [2] = 0 and
     b2-oborot-im                 [2] = 0 and
     b2-oborot-wm                 [2] = 0 and
     b2-oborot-em                 [2] = 0 and
     b2-oborot-ie                 [2] = 0 and
     b2-oborot-ee                 [2] = 0 and
     b2-oborot-ep              [2] = 0 and
     b2-oborot-es            [2] = 0 and
     b2-oborot-re             [2] = 0 and
     b2-oborot-rs        [2] = 0 and
     b2-oborot-we                 [2] = 0 and
     b2-oborot-vt                       [2] = 0 and
     b2-oborot-iv                [2] = 0 and
     b2-oborot-ev                [2] = 0 and
     b2-oborot-rv            [2] = 0 and
     b2-oborot-ot                 [2] = 0 and
     b2-oborot-ap           [2] = 0 and
     b2-oborot-pc           [2] = 0
     ) then   b2-null-str2# = 0    .
end procedure.
Procedure Null-str-pr :
 if (
     oborot-im                 [1] = 0 and
     oborot-wm                 [1] = 0 and
     oborot-em                 [1] = 0 and
     oborot-ie                 [1] = 0 and
     oborot-ee                 [1] = 0 and
     oborot-ep              [1] = 0 and
     oborot-es            [1] = 0 and
     oborot-re             [1] = 0 and
     oborot-rs        [1] = 0 and
     oborot-we                 [1] = 0 and
     oborot-vt                       [1] = 0 and
     oborot-iv                [1] = 0 and
     oborot-ev                [1] = 0 and
     oborot-rv            [1] = 0 and
     oborot-ot                 [2] = 0 and
     oborot-ap            [1] = 0 and
     oborot-pc            [1] = 0 and
     ostatok-end[1]                                    = 0 and
     ostatok-start[1]                                  = 0 and
     oborot-im                 [2] = 0 and
     oborot-wm                 [2] = 0 and
     oborot-em                 [2] = 0 and
     oborot-ie                 [2] = 0 and
     oborot-ee                 [2] = 0 and
     oborot-ep              [2] = 0 and
     oborot-es            [2] = 0 and
     oborot-re             [2] = 0 and
     oborot-rs        [2] = 0 and
     oborot-we                 [2] = 0 and
     oborot-vt                       [2] = 0 and
     oborot-iv                [2] = 0 and
     oborot-ev                [2] = 0 and
     oborot-rv            [2] = 0 and
      oborot-ap           [2] = 0 and
     oborot-pc            [2] = 0 and
     ostatok-end[2]                                    = 0 and
     ostatok-start[2]                                  = 0
      ) then   Null-str# = 0    .
END PROCEDURE.
Procedure Null-str-pr2 :
 if (
     oborot-im                 [1] = 0 and
     oborot-wm                 [1] = 0 and
     oborot-em                 [1] = 0 and
     oborot-ie                 [1] = 0 and
     oborot-ee                 [1] = 0 and
     oborot-ep              [1] = 0 and
     oborot-es            [1] = 0 and
     oborot-re             [1] = 0 and
     oborot-rs        [1] = 0 and
     oborot-we                 [1] = 0 and
     oborot-vt                       [1] = 0 and
     oborot-iv                [1] = 0 and
     oborot-ev                [1] = 0 and
     oborot-rv            [1] = 0 and
     oborot-ot                 [1] = 0 and
     oborot-ot                 [2] = 0 and
     oborot-ap            [1] = 0 and
     oborot-pc            [1] = 0 and
     oborot-im                 [2] = 0 and
     oborot-wm                 [2] = 0 and
     oborot-em                 [2] = 0 and
     oborot-ie                 [2] = 0 and
     oborot-ee                 [2] = 0 and
     oborot-ep              [2] = 0 and
     oborot-es            [2] = 0 and
     oborot-re             [2] = 0 and
     oborot-rs        [2] = 0 and
     oborot-we                 [2] = 0 and
     oborot-vt                       [2] = 0 and
     oborot-iv                [2] = 0 and
     oborot-ev                [2] = 0 and
     oborot-rv            [2] = 0 and
     oborot-ap            [2] = 0 and
     oborot-pc            [2] = 0
     ) then   Null-str2# = 0    .
END PROCEDURE.
procedure ex-display :
define input parameter par-1 as int no-undo.
define input parameter par-2 like  ostatok-start[1] no-undo.
define input parameter par-i as int no-undo.
  assign num#col#  = par-1.
  if par-i = 13 then do:
    run macr_excel_dec ( round (par-2 ,4)  , num#str# , num#col#   ).
  end.
  else do:
    if par-i = 1 or par-i = 11 or par-i = 12 then do :
      run macr_excel_dec ( round (par-2 ,3)  , num#str# , num#col#   ).
    end.
    else do :
      run macr_excel_dec ( round (par-2 ,2)  , num#str# , num#col#   ).
    end.
  end.
end procedure.
procedure u-line:
end procedure.
procedure p-line:
end procedure.
procedure make-col :
 define variable l#1 as int  no-undo.
 define variable l#2 as int  no-undo.
 define variable l as int  no-undo.
  assign
    nk = 0
    kk = 0
  .
  if xshowcost     then do: kk = kk + 1. end.
  if xshowcostnds  then do: kk = kk + 1. end.
  if xshowcrsa     then do: kk = kk + 1. end.
  if xshowcrsands  then do: kk = kk + 1. end.
  if xshowsale     then do: kk = kk + 1. end.
  if xshowsalends  then do: kk = kk + 1. end.
  if xshowsaleslt  then do: kk = kk + 1. end.
  if xshowmediator then do: kk = kk + 1. end.
  if x-tog-wt      then do: kk = kk + 1. end.
  if x-tog-ms      then do: kk = kk + 1. end.
  if xDens         then do: kk = kk + 1. end.
 assign
  num#str# = num#str# + 1
  num#col#  = 0
 .
 if use-column[28] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format( "№ "              , num#str# , num#col# ) . run macr_cell_size (10, ? , num#str# , num#col# , num#str# , num#col# ). end.
 if use-column[1]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format( "Код "            , num#str# , num#col# ) . run macr_cell_size (10, ? , num#str# , num#col# , num#str# , num#col# ). end.
 if use-column[2]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format( "Артикул"         , num#str# , num#col# ) . run macr_cell_size (16, ? , num#str# , num#col# , num#str# , num#col# ). end.
 if use-column[3]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format( "Название товара" , num#str# , num#col# ) . run macr_cell_size (60, ? , num#str# , num#col# , num#str# , num#col# ). end.
 if use-column[4]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format( "Ед.изм "         , num#str# , num#col# ) . run macr_cell_size (7 , ? , num#str# , num#col# , num#str# , num#col# ). end.
 if use-column[5]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format( "т/у"             , num#str# , num#col# ) . run macr_cell_size (4 , ? , num#str# , num#col# , num#str# , num#col# ). end.
 if use-column[21] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format( "Скидка"          , num#str# , num#col# ) . run macr_cell_size (15, ? , num#str# , num#col# , num#str# , num#col# ). end.
 if use-column[23] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format( "Эффективность"   , num#str# , num#col# ) . run macr_cell_size (16, ? , num#str# , num#col# , num#str# , num#col# ). end.
 if use-column[24] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format( "% наценки"       , num#str# , num#col# ) . run macr_cell_size (13, ? , num#str# , num#col# , num#str# , num#col# ). end.
    mp = num#col#  + 1.
    mp-1 = num#col#  .
 if use-column[6]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Остаток на начало "               , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[7]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот приход внешний"            , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[8]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот приход перемещение"        , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[9]  then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот приход производство"       , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[10] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот расход внешний"            , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[11] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот расход перемещение"        , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[12] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот расход производство"       , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[13] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот  списание"                 , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[14] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот касса продажа "            , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[15] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот касса возврат"             , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[16] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот возврат внешний"           , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[17] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот возврат поставщику"        , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[18] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот возврат перемещение"       , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[19] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот  инвентаризация"           , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[20] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Оборот  переоценка"               , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[22] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Остаток на конец "                , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[25] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format('коррекция учетных цен':U       , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[26] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format('смена типа приобретения':U       , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
 if use-column[27] then  do: assign num#col#  = num#col#  + 1 nk  = nk  + 1 . run macr_excel_char_with_format("Расход-Возврат"                   , num#str# , (num#col#  + (kk * (num#col#  - mp)) ))  .   end.
    run macr_cell_size (16, ? , num#str# , mp, num#str# , (num#col#  + (kk * (num#col#  - mp)) + kk) ).
   num#str# = num#str# + 1.
   repeat l#1 = mp to nk :
         l#2 = 0.
             num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char_with_format( "количество"  , num#str# , num#col#  ) .
         if xshowcost    then do:
             l#2 = l#2 + 1.
             num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char_with_format( "учетн. сумма"  , num#str# , num#col#  ) .
             end.
         if xshowcostnds then do:
             l#2 = l#2 + 1.
             num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char_with_format( "учетн.НДС"  , num#str# , num#col#  ) .
            end.
         if xshowmediator then do:
            l#2 = l#2 + 1.
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char_with_format( "цены поср."  , num#str# , num#col#  ) .
            end.
         if xshowcrsa    then do:
            l#2 = l#2 + 1.
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char_with_format( "продаж. сумма"  , num#str# , num#col#  ) .
            end.
         if xshowcrsands then do:
            l#2 = l#2 + 1.
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char_with_format( "продаж.НДС"  , num#str# , num#col#  ) .
            end.
          if xshowsale    then do:
            l#2 = l#2 + 1.
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char_with_format( "док. сумма"  , num#str# , num#col#  ) .
            end.
         if xshowsalends then do:
            l#2 = l#2 + 1.
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char_with_format( "док.НДС"  , num#str# , num#col#  ) .
            end.
         if xshowsaleslt then do:
            l#2 = l#2 + 1.
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2  . run macr_excel_char_with_format( "док.НсП"  , num#str# , num#col#  ) .
         end.
         if x-tog-wt then do:
          assign
            l#2 = l#2 + 1
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2
          .
          run macr_excel_char_with_format( "вес"  , num#str# , num#col#  ) .
         end.
         if x-tog-ms then do:
          assign
            l#2 = l#2 + 1
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2
          .
          run macr_excel_char_with_format( "объем"  , num#str# , num#col#  ) .
         end.
         if xDens then do:
          assign
            l#2 = l#2 + 1
            num#col# =  l#1 +  (kk * (l#1 - mp))  + l#2
          .
          run macr_excel_char_with_format( "плотность"  , num#str# , num#col#  ) .
         end.
     end.
end procedure .
procedure make-tt-ed :
create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'ie':U temp#sum-type.xi = 1 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'ee':U temp#sum-type.xi = 2 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'ep':U temp#sum-type.xi = 3 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'es':U temp#sum-type.xi = 4 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 're':U temp#sum-type.xi = 5 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'rs':U temp#sum-type.xi = 6 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'we':U temp#sum-type.xi = 7 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'vt':U temp#sum-type.xi = 8 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'iv':U temp#sum-type.xi = 9 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'ev':U temp#sum-type.xi = 10. create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'rv':U temp#sum-type.xi = 11. create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'em':U temp#sum-type.xi = 12 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'wm':U temp#sum-type.xi = 12 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'im':U temp#sum-type.xi = 13 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'ot':U temp#sum-type.xi = 14 .
create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'ap':U temp#sum-type.xi = 15 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'pc':U temp#sum-type.xi = 16 .
create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'ie':U temp#sum-type.xi = 101 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'ee':U temp#sum-type.xi = 102 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'ep':U temp#sum-type.xi = 103 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'es':U temp#sum-type.xi = 104 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 're':U temp#sum-type.xi = 105 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'rs':U temp#sum-type.xi = 106 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'we':U temp#sum-type.xi = 107 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'vt':U temp#sum-type.xi = 108 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'iv':U temp#sum-type.xi = 109 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'ev':U temp#sum-type.xi = 110 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'rv':U temp#sum-type.xi = 111 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'em':U temp#sum-type.xi = 112 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'wm':U temp#sum-type.xi = 112 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'im':U temp#sum-type.xi = 113 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'ot':U temp#sum-type.xi = 114 .
create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'ap':U temp#sum-type.xi = 115 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'pc':U temp#sum-type.xi = 116 .
create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'ie':U temp#sum-type.xi = 201 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'ee':U temp#sum-type.xi = 202 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'ep':U temp#sum-type.xi = 203 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'es':U temp#sum-type.xi = 204 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 're':U temp#sum-type.xi = 205 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'rs':U temp#sum-type.xi = 206 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'we':U temp#sum-type.xi = 207 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'vt':U temp#sum-type.xi = 208 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'iv':U temp#sum-type.xi = 209 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'ev':U temp#sum-type.xi = 210 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'rv':U temp#sum-type.xi = 211 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'em':U temp#sum-type.xi = 212 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'wm':U temp#sum-type.xi = 212 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'im':U temp#sum-type.xi = 213 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'ot':U temp#sum-type.xi = 214 .
create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'ap':U temp#sum-type.xi = 215 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'pc':U temp#sum-type.xi = 216 .
end procedure.
procedure new-tmp-page :
 do
 on error undo, return error return-value
 :
    if   num#str#  >=  63000  then do:
        output stream macr_excel  close .
        run paramls-write in this-procedure
          (input "file"
          ,input string(v-ind)
          ,input v-file-name
          ) .
        run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
        output stream  macr_excel to value(v-file-name) .
        v-ind = v-ind + 1 .
        num#str# = 0 .
define variable old-s as integer no-undo .
define variable old-s2 as integer no-undo .
    assign
    old-s =   num#str#
    .
    run make-col .
    assign
      old-s2 =   num#str#
    .
   num#str# = old-s + 1  .
   run proc-print-header .
   num#str# = old-s2     .
    end.
 end.
end procedure.
procedure pp :
define input parameter ll as integer no-undo .
define input parameter uu as integer no-undo .
define input parameter ff as character no-undo .
End procedure.
procedure find-last-prise-med :
define input parameter p-artic     like ub.goods.artic no-undo .
define input parameter p-prod-type like ub.goods.prod-type no-undo .
define input parameter p-prod-code like ub.goods.prod-code no-undo .
define input parameter p-host-code like ub.gds-obj.host-code no-undo .
define output parameter  p-price   like ub.gds-obj.last-base no-undo .
define buffer p-gds-obj   for  ub.gds-obj .
define buffer buf_trn-doc for  ub.trn-doc .
define variable v-fact-order as decimal no-undo .
p-price = 0 .
  define variable v-in-date as date      no-undo .
  define variable fl as logical no-undo .
  fl = yes.
  v-fact-order = 0 .
  for each tt-obj-list no-lock break by tt-obj-list.obj-type by tt-obj-list.obj-code
  :
    find first p-gds-obj no-lock
      where p-gds-obj.artic     = p-artic         and
              p-gds-obj.prod-type = p-prod-type     and
              p-gds-obj.prod-code = p-prod-code     and
              p-gds-obj.obj-code  = tt-obj-list.obj-code and
              p-gds-obj.obj-type  = tt-obj-list.obj-type
      no-error .
    if available p-gds-obj then do:
    if p-gds-obj.in-date = ?  then next .
    if fl = yes then do:
      assign
        v-in-date = p-gds-obj.in-date
        p-price   =  if tPrintRubl then  p-gds-obj.last-rubl else  p-gds-obj.last-base
        fl = no
    .
     find first buf_trn-doc no-lock  where buf_trn-doc.doc-code = p-gds-obj.in-code no-error  .
     if available buf_trn-doc  then  v-fact-order = buf_trn-doc.fact-order .
    end.
      if p-gds-obj.in-date >= v-in-date   then do:
         if p-gds-obj.in-date = v-in-date then do:
            find first buf_trn-doc no-lock  where buf_trn-doc.doc-code = p-gds-obj.in-code no-error .
            if available buf_trn-doc  then
                if buf_trn-doc.fact-order >  v-fact-order   then do:
                  assign
                    v-fact-order = buf_trn-doc.fact-order
                    p-price   =  if tPrintRubl then  p-gds-obj.last-rubl else  p-gds-obj.last-base
                    v-in-date =   p-gds-obj.in-date
                  .
                end.
         end.
         else do:
          find first buf_trn-doc no-lock  where buf_trn-doc.doc-code = p-gds-obj.in-code no-error .
          if available buf_trn-doc  then
              assign
                p-price   =    if tPrintRubl then  p-gds-obj.last-rubl else  p-gds-obj.last-base
                v-in-date =    p-gds-obj.in-date
                v-fact-order = buf_trn-doc.fact-order .
              .
          end.
        if p-price = ? then   p-price  = 0 .
      end.
    end.
  End .
  if p-price = ? then   p-price  = 0 .
end procedure.
procedure find-mediator :
define input  parameter c-host-code as integer no-undo .
define input  parameter p-Showmediatr as logical no-undo .
define output parameter p-host-code as integer no-undo .
define output parameter p-flag as logical no-undo .
define buffer b-sysconf  for ub.sysconf.
 p-host-code = 0 .
 p-flag  = true .
    if p-Showmediatr = true then do:
    find first ub.sysconf where ub.sysconf.avrg-price = true no-lock no-error .
          if avail ub.sysconf then DO :
            p-host-code = ub.sysconf.host-code.
            if tPrintRubl = false then do:
                  find first b-sysconf where b-sysconf.host-code = c-host-code no-lock no-error .
                        if  ub.sysconf.base-code <> b-sysconf.base-code then DO:
                              p-flag  = false  .
                              message "Базовая валюта посредника и базовая валюта текущей фирмы не совпадает . Нельзя получить отчет в валюте !"
                              view-as alert-box error.
                        end.
            end.
          end.
          for each ub.shop no-lock where ub.shop.host-code = p-host-code :
              create tt-obj-list no-error .
              assign tt-obj-list.obj-type = 'маг':U
                     tt-obj-list.obj-code = ub.shop.obj-code no-error .
          end.
          for each ub.store no-lock where ub.store.host-code = p-host-code :
              create tt-obj-list no-error .
              assign tt-obj-list.obj-type = 'скл':U
                     tt-obj-list.obj-code = ub.store.obj-code no-error .
          end.
    End.
 End procedure .
PROCEDURE ob-line-stk  :
define input  parameter x-store-code     like ub.clients.obj-code      no-undo.
define input  parameter x-store-type     like ub.clients.obj-type      no-undo.
define INPUT  parameter x-artic          like ub.stk-line.artic        no-undo.
define INPUT  parameter x-prod-code      like ub.stk-line.prod-code    no-undo.
define INPUT  parameter x-prod-type      like ub.stk-line.prod-type    no-undo.
define INPUT  parameter x-Fact-order-1   like ub.stk-line.Fact-order   no-undo.
define INPUT  parameter x-Fact-order-2   like ub.stk-line.Fact-order   no-undo.
define input  parameter x-sum-type       like ub.stk-line.sum-type     no-undo.
define input  parameter x-cat-id         like ub.stk-line.cat-id       no-undo.
define input  parameter x-ext-doc-type   like ub.ot-line.ext-doc-type  no-undo.
define input  parameter xTog-obj         as log                     no-undo.
define input  parameter xi               as int                     no-undo.
define output  parameter Quntity         like ub.stk-line.fact-qnty   no-undo.
define output  parameter sum             like ub.stk-line.sum-base    no-undo.
define output  parameter vat             like ub.stk-line.sum-base    no-undo.
define output  parameter slt             like ub.stk-line.sum-base    no-undo.
define output  parameter disc            like ub.stk-line.sum-base    no-undo.
define variable  First-qnty   like ub.stk-line.fact-qnty   no-undo.
define variable  Second-qnty  like ub.stk-line.fact-qnty   no-undo.
define variable  First-sum   like ub.stk-line.sum-base   no-undo.
define variable  Second-sum  like ub.stk-line.sum-base   no-undo.
define variable  First-vat   like ub.stk-line.sum-base   no-undo.
define variable  Second-vat  like ub.stk-line.sum-base   no-undo.
define variable  First-slt   like ub.stk-line.sum-base   no-undo.
define variable  Second-slt  like ub.stk-line.sum-base   no-undo.
define variable  First-disc   like ub.stk-line.sum-base   no-undo.
define variable  Second-disc  like ub.stk-line.sum-base   no-undo.
define buffer stk-line2 for ub.stk-line .
if x-Fact-order-2 < x-Fact-order-1 Then x-Fact-order-2 = x-Fact-order-1.
 Assign
   First-qnty  = 0
   Second-qnty = 0
   Quntity     = 0
   First-sum  = 0
   Second-sum = 0
   sum        = 0
   First-vat  = 0
   Second-vat = 0
   vat        = 0
   First-slt   = 0
   Second-slt  = 0
   slt         = 0
   First-disc  = 0
   Second-disc = 0
   disc        = 0
  .
  For each obj-list  no-lock :
   if  xTog-obj THEN
       if   NOT(    x-store-type     = obj-list.obj-type
            AND    x-store-code      = obj-list.obj-code ) Then NEXT.
   FOR each temp#sum-type where temp#sum-type.xi = xi no-lock :
      find last ub.stk-line no-lock
        where ub.stk-line.obj-type   = obj-list.obj-type
          and ub.stk-line.obj-code   = obj-list.obj-code
          and ub.stk-line.artic      = x-artic
          and ub.stk-line.prod-type  = x-prod-type
          and ub.stk-line.prod-code  = x-prod-code
          and ub.stk-line.sum-type   = temp#sum-type.sum-type
          and ub.stk-line.cat-id     = '##,##':U
          and ub.stk-line.fact-order <= x-fact-order-1
        use-index category
        no-error .
      if available ub.stk-line then do:
        assign
          First-qnty = First-qnty + ub.stk-line.fact-qnty
          First-sum  = First-sum  + (if tprintrubl then ub.stk-line.sum-rubl   else ub.stk-line.sum-base  )
          First-vat  = First-vat  + (if tprintrubl then ub.stk-line.vat-rubl   else ub.stk-line.vat-base  )
          First-disc = First-disc + (if tprintrubl then ub.stk-line.other-rubl else ub.stk-line.other-base )
          First-slt  = First-slt  + (if tprintrubl then ub.stk-line.slt-rubl   else ub.stk-line.slt-base   )
        .
      end.
      find last stk-line2 no-lock
        where stk-line2.obj-code   = obj-list.obj-code
          and stk-line2.obj-type   = obj-list.obj-type
          and stk-line2.artic      = x-artic
          and stk-line2.prod-type  = x-prod-type
          and stk-line2.prod-code  = x-prod-code
          and stk-line2.sum-type   = temp#sum-type.sum-type
          and stk-line2.cat-id     = '##,##':U
          and stk-line2.fact-order <= x-fact-order-2
        use-index category
        no-error .
      if available stk-line2 then do:
        assign
          Second-qnty = Second-qnty + Stk-line2.fact-qnty
          Second-sum  = Second-sum  + (if tprintrubl then stk-line2.sum-rubl else stk-line2.sum-base    )
          Second-vat  = Second-vat  + (if tprintrubl then stk-line2.vat-rubl else stk-line2.vat-base    )
          second-disc = second-disc + (if tprintrubl then stk-line2.other-rubl else stk-line2.other-base )
          second-slt  = second-slt  + (if tprintrubl then stk-line2.slt-rubl   else stk-line2.slt-base   )
        .
      end.
   end.
 end.
 Assign
   Quntity = Second-qnty - first-qnty
   sum     = Second-sum  - first-sum
   vat     = Second-vat  - first-vat
   slt     = Second-slt  - first-slt
   disc    = Second-disc  - first-disc
   .
END PROCEDURE.
procedure calc-ms-wt :
define input        parameter p-oborot-num      as decimal   no-undo .
define input        parameter p-gds-wt-ms-base  as decimal   no-undo .
define input-output parameter p-oborot          as decimal   no-undo .
define input-output parameter p-bi-oborot       as decimal   no-undo .
define input-output parameter p-bo-oborot       as decimal   no-undo .
define input-output parameter p-b1-oborot       as decimal   no-undo .
define input-output parameter p-b2-oborot       as decimal   no-undo .
do
on error undo, return error return-value
:
if p-is-petrol = true then return .
  assign
    p-oborot    = p-oborot-num * p-gds-wt-ms-base
    p-bi-oborot = p-bi-oborot + p-oborot
    p-bo-oborot = p-bo-oborot + p-oborot
    p-b1-oborot = p-b1-oborot + p-oborot
    p-b2-oborot = p-b2-oborot + p-oborot
  .
end.
end procedure.
procedure calc-dens :
define input        parameter p-ostatok-wt       as decimal   no-undo .
define input        parameter p-ostatok          as decimal   no-undo .
define input-output parameter p-density          as decimal   no-undo .
define input-output parameter p-bi-density       as decimal   no-undo .
define input-output parameter p-bo-density       as decimal   no-undo .
define input-output parameter p-b1-density       as decimal   no-undo .
define input-output parameter p-b2-density       as decimal   no-undo .
do
on error undo, return error return-value
:
if p-is-petrol = false then return .
  assign
    p-density    = if abs(p-ostatok) < abs(p-ostatok-wt) then abs(p-ostatok / p-ostatok-wt) else 0
    p-bi-density = 0
    p-bo-density = 0
    p-b1-density = 0
    p-b2-density = 0
  .
end.
end procedure.
procedure calc-pt-ob :
define input  parameter p-ext-doc-type    as character no-undo .
define input  parameter x-store-type      as character no-undo .
define input  parameter x-store-code      as integer   no-undo .
define input  parameter p-artic           as character no-undo .
define input  parameter p-prod-type       as character no-undo .
define input  parameter p-prod-code       as integer   no-undo .
define input-output parameter p-oborot    as decimal   no-undo .
define input-output parameter p-bi-oborot as decimal   no-undo .
define input-output parameter p-bo-oborot as decimal   no-undo .
define input-output parameter p-b1-oborot as decimal   no-undo .
define input-output parameter p-b2-oborot as decimal   no-undo .
  do
  on error undo, return error return-value
  :
define variable v-oborot as decimal   no-undo .
define buffer buf_doc-line  for ub.doc-line  .
define buffer buf_inv-line  for ub.inv-line  .
define buffer buf1_obj-list for obj-list .
assign
  v-oborot = 0
.
if p-is-petrol = false   then return .
  for each buf1_obj-list no-lock :
   if  xtog-obj then
       if   not(x-store-type     = buf1_obj-list.obj-type
            and x-store-code     = buf1_obj-list.obj-code ) then next.
    for each buf_doc-line  no-lock where
          buf_doc-line.obj-type     = buf1_obj-list.obj-type and
          buf_doc-line.obj-code     = buf1_obj-list.obj-code and
          buf_doc-line.artic        = p-artic and
          buf_doc-line.prod-type    = p-prod-type and
          buf_doc-line.prod-code    = p-prod-code and
          buf_doc-line.ext-doc-type = p-ext-doc-type and
          buf_doc-line.status_      = 'факт':U        and
          buf_doc-line.fact-order   <= fact-order-2  and
          buf_doc-line.fact-order   >= fact-order-1
          :
          for each buf_inv-line  no-lock where
              buf_inv-line.doc-code     = buf_doc-line.doc-code and
              buf_inv-line.artic        = buf_doc-line.artic and
              buf_inv-line.prod-type    = buf_doc-line.prod-type and
              buf_inv-line.prod-code    = buf_doc-line.prod-code
              :
              if p-ext-doc-type = 'vt':U  then v-oborot = v-oborot + buf_doc-line.cli-qnty .
                  else do:
                  if p-ext-doc-type = 'we':U    or
                     p-ext-doc-type = 'ee':U    or
                     p-ext-doc-type = 'ev':U    or
                     p-ext-doc-type = 'ep':U or
                     p-ext-doc-type = 'em':U     or
                     p-ext-doc-type = 'wm':U     or
                     p-ext-doc-type = 'es':U   then
                        v-oborot = v-oborot - buf_inv-line.wast-cli-qnty .
                        else v-oborot = v-oborot + buf_inv-line.wast-cli-qnty .
                  end.
          end.
    end.
end.
assign
  p-oborot    = v-oborot
  p-bi-oborot = p-bi-oborot + v-oborot
  p-bo-oborot = p-bo-oborot + v-oborot
  p-b1-oborot = p-b1-oborot + v-oborot
  p-b2-oborot = p-b2-oborot + v-oborot
.
end.
end procedure.
procedure calc-density :
define input        parameter p-ext-doc-type  as character no-undo .
define input        parameter x-store-type    as character no-undo .
define input        parameter x-store-code    as integer   no-undo .
define input        parameter p-artic         as character no-undo .
define input        parameter p-prod-type     as character no-undo .
define input        parameter p-prod-code     as integer   no-undo .
define input-output parameter p-density       as decimal   no-undo .
define input-output parameter p-bi-density    as decimal   no-undo .
define input-output parameter p-bo-density    as decimal   no-undo .
define input-output parameter p-b1-density    as decimal   no-undo .
define input-output parameter p-b2-density    as decimal   no-undo .
  do
  on error undo, return error return-value
  :
define variable v-oborot    as decimal   no-undo .
define variable v-fact-qnty as decimal   no-undo .
define buffer buf_doc-line  for ub.doc-line  .
define buffer buf_inv-line  for ub.inv-line  .
define buffer buf1_obj-list for obj-list .
assign
  v-oborot     = 0
  v-fact-qnty  = 0
.
if p-is-petrol = false   then return .
  for each buf1_obj-list no-lock :
   if  xtog-obj then
       if   not(x-store-type     = buf1_obj-list.obj-type
            and x-store-code     = buf1_obj-list.obj-code ) then next.
    for each buf_doc-line  no-lock where
          buf_doc-line.obj-type     = buf1_obj-list.obj-type and
          buf_doc-line.obj-code     = buf1_obj-list.obj-code and
          buf_doc-line.artic        = p-artic and
          buf_doc-line.prod-type    = p-prod-type and
          buf_doc-line.prod-code    = p-prod-code and
          buf_doc-line.ext-doc-type = p-ext-doc-type and
          buf_doc-line.status_      = 'факт':U        and
          buf_doc-line.fact-order   <= fact-order-2  and
          buf_doc-line.fact-order   >= fact-order-1
          :
          assign v-fact-qnty = v-fact-qnty + buf_doc-line.fact-qnty.
          for each buf_inv-line  no-lock where
              buf_inv-line.doc-code     = buf_doc-line.doc-code and
              buf_inv-line.artic        = buf_doc-line.artic and
              buf_inv-line.prod-type    = buf_doc-line.prod-type and
              buf_inv-line.prod-code    = buf_doc-line.prod-code
              :
              if p-ext-doc-type = 'vt':U  then v-oborot = v-oborot + buf_doc-line.cli-qnty .
                  else do:
                  if p-ext-doc-type = 'we':U    or
                     p-ext-doc-type = 'ee':U    or
                     p-ext-doc-type = 'ev':U    or
                     p-ext-doc-type = 'ep':U or
                     p-ext-doc-type = 'em':U     or
                     p-ext-doc-type = 'wm':U     or
                     p-ext-doc-type = 'es':U   then
                        v-oborot = v-oborot - buf_inv-line.wast-cli-qnty .
                        else v-oborot = v-oborot + buf_inv-line.wast-cli-qnty .
                  end.
          end.
    end.
    assign
      p-density    = if ( v-fact-qnty <> 0 and ABS(v-oborot) < ABS(v-fact-qnty)) then ABS(v-oborot / v-fact-qnty) else 0
    .
    assign
      p-bi-density = p-density
      p-bo-density = 0
      p-b1-density = 0
      p-b2-density = 0
    .
end.
end.
end procedure.
