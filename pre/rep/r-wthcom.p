block-level on error undo, throw.
define input parameter parParentProc    AS WIDGET-HANDLE    NO-UNDO .
define input parameter p-begin-date     as date             no-undo .
define input parameter p-end-date       as date             no-undo .
define input parameter p-begin-shift    as integer          no-undo .
define input parameter p-end-shift      as integer          no-undo .
define input parameter p-cli-recid-list as character        no-undo .
define input parameter p-wth-recid-list as character        no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-wthcom.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-wthcom.p $":U .
define variable vss-description as character no-undo init "Сводный отчет о реализованных талонах".
define variable g#report-num              as integer              no-undo .
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define stream out-stream.
define variable v-obj-grp-list  as character    no-undo.
do
ON ERROR UNDO, RETURN ERROR substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
   run get-report-num in parparentproc (output g#report-num).
DEFINE TEMP-TABLE tt-grp NO-UNDO
      FIELD grp-name    as character
      FIELD grp-code    as integer
      INDEX pi IS PRIMARY UNIQUE
            grp-code
.
DEFINE TEMP-TABLE tt-wth-par NO-UNDO
      FIELD number         as integer
      FIELD wth-name       as character
      FIELD wth-par-name   as character
      FIELD wth-par-code   as integer
      FIELD wth-code       as integer
      FIELD par-rate       as decimal
      INDEX pi IS PRIMARY UNIQUE
            wth-code
            wth-par-code
      INDEX i-print
            number
.
DEFINE TEMP-TABLE tt-line NO-UNDO
      FIELD grp-code       as integer
      FIELD wth-code       as integer
      FIELD wth-par-code   as integer
      FIELD summ-4      as integer    format "->>>>>9"
      FIELD summ-5      as decimal    format "->>>>>9.999"
      FIELD summ-6      as decimal    format "->>>>>9.99"
      FIELD summ-7      as decimal    format "->>>>>9.999"
      FIELD summ-8      as decimal    format "->>>>>9.99"
      FIELD summ-9      as decimal    format "->>>>>9.999"
      FIELD summ-10     as decimal    format "->>>>>9.99"
      FIELD summ-11     as decimal    format "->>>>>9.999"
      FIELD summ-12     as decimal    format "->>>>>9.99"
      FIELD summ-15     as decimal    format "->>>>>9.999"
      FIELD summ-16     as decimal    format "->>>>>9.99"
      INDEX pi IS PRIMARY UNIQUE
            grp-code
            wth-par-code
            wth-code
.
define variable vss-include-info11 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define stream excel-line.
define stream excel-cell.
define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character
    index pi is primary unique data-key
.
define variable v-wthcom-sheet1-cur-data-row     as integer      no-undo.
define variable v-wthcom-cell-file-name       as character    no-undo.
define variable v-wthcom-data-file-name       as character    no-undo.
procedure wthcom-init :
do
on error undo, return error
:
    assign
        v-wthcom-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-wthcom-data-file-name
    ).
    output stream excel-line to value( v-wthcom-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-wthcom-cell-file-name
    ).
    output stream excel-cell to value( v-wthcom-cell-file-name ).
    run wthcom-write-cell-data in this-procedure (
          input "sheetList":U
        , input "Template":U
    ).
    if printrubl
    then do:
        run wthcom-write-cell-data in this-procedure (
              input "Template_valutCode":U
            , input "0":U
        ).
    end.
    else do:
        run wthcom-write-cell-data in this-procedure (
              input "Template_valutCode":U
            , input "1":U
        ).
    end.
    run wthcom-write-cell-data in this-procedure (
          input "Template_columnList":U
        , input "number,wth_name,wth_par_name,summ_4,summ_5,summ_6,summ_7,summ_8,summ_9,summ_10,summ_11,summ_12,summ_13,summ_14,summ_15,summ_16":U
    ).
    run wthcom-write-cell-data in this-procedure (
          input "Template_columnType":U
        , input "S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S":U
    ).
    run wthcom-write-cell-data in this-procedure (
          input "Template_subtotalList":U
        , input "":U
    ).
    run wthcom-write-cell-data in this-procedure (
          input "Template_subtotalType":U
        , input "":U
    ).
end.
end procedure.
procedure wthcom-sheet1-write-line-data :
define buffer buf_tt-line     for tt-line .
define buffer buf_tt-grp      for tt-grp .
define buffer buf_tt-wth-par  for tt-wth-par .
define variable v-summ-4-it  as decimal format "->>>>>9"     no-undo .
define variable v-summ-5-it  as decimal format "->>>>>9.999" no-undo .
define variable v-summ-6-it  as decimal format "->>>>>9.99"  no-undo .
define variable v-summ-7-it  as decimal format "->>>>>9.999" no-undo .
define variable v-summ-8-it  as decimal format "->>>>>9.99"  no-undo .
define variable v-summ-9-it  as decimal format "->>>>>9.999" no-undo .
define variable v-summ-10-it as decimal format "->>>>>9.99"  no-undo .
define variable v-summ-11-it as decimal format "->>>>>9.999" no-undo .
define variable v-summ-12-it as decimal format "->>>>>9.99"  no-undo .
define variable v-summ-13-it as decimal format "->>>>>9.999" no-undo .
define variable v-summ-14-it as decimal format "->>>>>9.99"  no-undo .
define variable v-summ-15-it as decimal format "->>>>>9.999" no-undo .
define variable v-summ-16-it as decimal format "->>>>>9.99"  no-undo .
define variable v-summ-4-vs  as decimal format "->>>>>9"     no-undo .
define variable v-summ-5-vs  as decimal format "->>>>>9.999" no-undo .
define variable v-summ-6-vs  as decimal format "->>>>>9.99"  no-undo .
define variable v-summ-7-vs  as decimal format "->>>>>9.999" no-undo .
define variable v-summ-8-vs  as decimal format "->>>>>9.99"  no-undo .
define variable v-summ-9-vs  as decimal format "->>>>>9.999" no-undo .
define variable v-summ-10-vs as decimal format "->>>>>9.99"  no-undo .
define variable v-summ-11-vs as decimal format "->>>>>9.999" no-undo .
define variable v-summ-12-vs as decimal format "->>>>>9.99"  no-undo .
define variable v-summ-13-vs as decimal format "->>>>>9.999" no-undo .
define variable v-summ-14-vs as decimal format "->>>>>9.99"  no-undo .
define variable v-summ-15-vs as decimal format "->>>>>9.999" no-undo .
define variable v-summ-16-vs as decimal format "->>>>>9.99"  no-undo .
do
on error undo, return error
:
   for each buf_tt-grp
      :
      put stream excel-line unformatted
                            "Template":U
            CHR(9)   "DTA":U
            CHR(9)   buf_tt-grp.grp-name
            CHR(9)   " "
            CHR(9)   " "
            CHR(9)   " "
            CHR(9)   " "
            CHR(9)   " "
            CHR(9)   " "
            CHR(9)   " "
            CHR(9)   " "
            CHR(9)   " "
            CHR(9)   " "
            CHR(9)   " "
            CHR(9)   " "
            CHR(9)   " "
            CHR(9)   " "
            CHR(9)   " "
            chr(10)
      .
      put stream excel-line unformatted
                        "Template":U
         CHR(9)  "FMT":U
         CHR(9)   "Заголовок1"
         chr(10)
      .
      assign
         v-summ-4-it  = 0
         v-summ-5-it  = 0
         v-summ-6-it  = 0
         v-summ-7-it  = 0
         v-summ-8-it  = 0
         v-summ-9-it  = 0
         v-summ-10-it = 0
         v-summ-11-it = 0
         v-summ-12-it = 0
         v-summ-13-it = 0
         v-summ-14-it = 0
         v-summ-15-it = 0
         v-summ-16-it = 0
      .
      FOR EACH buf_tt-wth-par
          by number
         :
         FOR each buf_tt-line
            where buf_tt-line.grp-code       = buf_tt-grp.grp-code
              and buf_tt-line.wth-code       = buf_tt-wth-par.wth-code
              and buf_tt-line.wth-par-code   = buf_tt-wth-par.wth-par-code
            :
            put stream excel-line unformatted
                                  "Template":U
                  CHR(9)   "DTA":U
                  CHR(9)    buf_tt-wth-par.number
                  CHR(9)    buf_tt-wth-par.wth-name
                  CHR(9)    buf_tt-wth-par.wth-par-name
                  CHR(9)       buf_tt-line.summ-4                                 format "->>>>>>>>>>9"
                  CHR(9)       buf_tt-line.summ-5                                 format "->>>>>>>>>>9.999"
                  CHR(9)       buf_tt-line.summ-6                                 format "->>>>>>>>>>9.99"
                  CHR(9)       buf_tt-line.summ-7                                 format "->>>>>>>>>>9.999"
                  CHR(9)       buf_tt-line.summ-8                                 format "->>>>>>>>>>9.99"
                  CHR(9)       buf_tt-line.summ-9                                 format "->>>>>>>>>>9.999"
                  CHR(9)       buf_tt-line.summ-10                                format "->>>>>>>>>>9.99"
                  CHR(9)       buf_tt-line.summ-11                                format "->>>>>>>>>>9.999"
                  CHR(9)       buf_tt-line.summ-12                                format "->>>>>>>>>>9.99"
                  CHR(9)     ( buf_tt-line.summ-5        - buf_tt-line.summ-9  )  format "->>>>>>>>>>9.999"
                  CHR(9)     ( buf_tt-line.summ-6        - buf_tt-line.summ-10 )  format "->>>>>>>>>>9.99"
                  CHR(9)       buf_tt-line.summ-15                                format "->>>>>>>>>>9.999"
                  CHR(9)       buf_tt-line.summ-16                                format "->>>>>>>>>>9.99"
                  chr(10)
            .
            assign
               v-summ-4-it  = v-summ-4-it   +   buf_tt-line.summ-4
               v-summ-5-it  = v-summ-5-it   +   buf_tt-line.summ-5
               v-summ-6-it  = v-summ-6-it   +   buf_tt-line.summ-6
               v-summ-7-it  = v-summ-7-it   +   buf_tt-line.summ-7
               v-summ-8-it  = v-summ-8-it   +   buf_tt-line.summ-8
               v-summ-9-it  = v-summ-9-it   +   buf_tt-line.summ-9
               v-summ-10-it = v-summ-10-it  +   buf_tt-line.summ-10
               v-summ-11-it = v-summ-11-it  +   buf_tt-line.summ-11
               v-summ-12-it = v-summ-12-it  +   buf_tt-line.summ-12
               v-summ-13-it = v-summ-13-it  + ( buf_tt-line.summ-5        - buf_tt-line.summ-9  )
               v-summ-14-it = v-summ-14-it  + ( buf_tt-line.summ-6        - buf_tt-line.summ-10 )
               v-summ-15-it = v-summ-15-it  +   buf_tt-line.summ-15
               v-summ-16-it = v-summ-16-it  +   buf_tt-line.summ-16
               v-summ-4-vs  = v-summ-4-vs   +   buf_tt-line.summ-4
               v-summ-5-vs  = v-summ-5-vs   +   buf_tt-line.summ-5
               v-summ-6-vs  = v-summ-6-vs   +   buf_tt-line.summ-6
               v-summ-7-vs  = v-summ-7-vs   +   buf_tt-line.summ-7
               v-summ-8-vs  = v-summ-8-vs   +   buf_tt-line.summ-8
               v-summ-9-vs  = v-summ-9-vs   +   buf_tt-line.summ-9
               v-summ-10-vs = v-summ-10-vs  +   buf_tt-line.summ-10
               v-summ-11-vs = v-summ-11-vs  +   buf_tt-line.summ-11
               v-summ-12-vs = v-summ-12-vs  +   buf_tt-line.summ-12
               v-summ-13-vs = v-summ-13-vs  + ( buf_tt-line.summ-5        - buf_tt-line.summ-9  )
               v-summ-14-vs = v-summ-14-vs  + ( buf_tt-line.summ-6        - buf_tt-line.summ-10 )
               v-summ-15-vs = v-summ-15-vs  +   buf_tt-line.summ-15
               v-summ-16-vs = v-summ-16-vs  +   buf_tt-line.summ-16
           .
         END.
      end.
      put stream excel-line unformatted
                            "Template":U
            CHR(9)   "DTA":U
            CHR(9)   ""
            CHR(9)   "  ИТОГО:"
            CHR(9)   " "
            CHR(9)   v-summ-4-it   format "->>>>>>>>>>>9"
            CHR(9)   v-summ-5-it   format "->>>>>>>>>>>9.999"
            CHR(9)   v-summ-6-it   format "->>>>>>>>>>>9.99"
            CHR(9)   v-summ-7-it   format "->>>>>>>>>>>9.999"
            CHR(9)   v-summ-8-it   format "->>>>>>>>>>>9.99"
            CHR(9)   v-summ-9-it   format "->>>>>>>>>>>9.999"
            CHR(9)   v-summ-10-it  format "->>>>>>>>>>>9.99"
            CHR(9)   v-summ-11-it  format "->>>>>>>>>>>9.999"
            CHR(9)   v-summ-12-it  format "->>>>>>>>>>>9.99"
            CHR(9)   v-summ-13-it  format "->>>>>>>>>>>9.999"
            CHR(9)   v-summ-14-it  format "->>>>>>>>>>>9.99"
            CHR(9)   v-summ-15-it  format "->>>>>>>>>>>9.999"
            CHR(9)   v-summ-16-it  format "->>>>>>>>>>>9.99"
            chr(10)
      .
   end.
   put stream excel-line unformatted
                           "Template":U
         CHR(9)   "DTA":U
         CHR(9)   ""
         CHR(9)   "  ВСЕГО:"
         CHR(9)   " "
         CHR(9)   v-summ-4-vs    format "->>>>>>>>>>>>>9"
         CHR(9)   v-summ-5-vs    format "->>>>>>>>>>>>>9.999"
         CHR(9)   v-summ-6-vs    format "->>>>>>>>>>>>>9.99"
         CHR(9)   v-summ-7-vs    format "->>>>>>>>>>>>>9.999"
         CHR(9)   v-summ-8-vs    format "->>>>>>>>>>>>>9.99"
         CHR(9)   v-summ-9-vs    format "->>>>>>>>>>>>>9.999"
         CHR(9)   v-summ-10-vs   format "->>>>>>>>>>>>>9.99"
         CHR(9)   v-summ-11-vs   format "->>>>>>>>>>>>>9.999"
         CHR(9)   v-summ-12-vs   format "->>>>>>>>>>>>>9.99"
         CHR(9)   v-summ-13-vs   format "->>>>>>>>>>>>>9.999"
         CHR(9)   v-summ-14-vs   format "->>>>>>>>>>>>>9.99"
         CHR(9)   v-summ-15-vs   format "->>>>>>>>>>>>>9.999"
         CHR(9)   v-summ-16-vs   format "->>>>>>>>>>>>>9.99"
         chr(10)
   .
end.
end procedure.
procedure wthcom-write-cell-data :
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
procedure wthcom-run-excel :
define input parameter p-header-filename    as character        no-undo.
define input parameter p-data-filename      as character        no-undo.
define variable v-template-file-name    as character    no-undo.
define variable v-vb-file-name          as character    no-undo.
define buffer buf_temp-param for temp-param .
do
for buf_temp-param
on error undo, return error
:
    create buf_temp-param.
    assign
        v-template-file-name    = search( "exe/wth_com.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas" )
    .
    if v-template-file-name = ?
    or v-template-file-name = "":U
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
        , input v-template-file-name
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
procedure wthcom-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/wth_com.xlt" .
        export "exe/t_form.bas" .
        export v-wthcom-cell-file-name.
        export v-wthcom-data-file-name.
    output close.
end.
end procedure.
   run fill-temp-table in this-procedure .
   run open-stream     IN THIS-PROCEDURE .
   run print-header    in this-procedure .
   run print-body      in this-procedure .
   run print-footer    in this-procedure .
   run close-stream    IN THIS-PROCEDURE .
end.
PROCEDURE fill-temp-table :
define buffer buf_cli-grp     for ub.cli-grp .
define buffer buf_wealth      for ub.wealth .
define buffer buf_wth-par     for ub.wth-par .
define buffer buf_wth-parts   for ub.wth-parts .
define buffer buf_clients     for ub.clients .
define buffer find_clients    for ub.clients .
define buffer buf_tt-grp      for tt-grp .
define buffer buf_tt-wth-par  for tt-wth-par .
define buffer buf_tt-line     for tt-line .
define variable v-count    as integer      no-undo.
define variable v-num      as integer      no-undo.
do
on error undo, return error
:
   DO v-count = 1 TO NUM-ENTRIES(p-cli-recid-list)
   on error undo, next
   :
      find first buf_cli-grp
           where buf_cli-grp.node-code = INTEGER(ENTRY(v-count, p-cli-recid-list))
           no-lock
           no-error
           .
      IF AVAILABLE buf_cli-grp
      THEN DO:
         create buf_tt-grp.
         assign
            buf_tt-grp.grp-code = buf_cli-grp.node-code
            buf_tt-grp.grp-name = buf_cli-grp.node-name
         .
      END.
   END.
   assign
      v-num = 1
   .
   DO v-count = 1 TO NUM-ENTRIES(p-wth-recid-list)
   on error undo, next
   :
      find first buf_wealth
           where buf_wealth.wth-code = INTEGER(ENTRY(v-count, p-wth-recid-list))
           no-lock
           no-error
           .
      IF AVAILABLE buf_wealth
      THEN DO:
         FOR EACH  buf_wth-par
             WHERE buf_wth-par.wth-code = buf_wealth.wth-code
             no-lock
             :
             create buf_tt-wth-par.
             assign
               buf_tt-wth-par.wth-code       = buf_wealth.wth-code
               buf_tt-wth-par.wth-par-code   = buf_wth-par.par-code
               buf_tt-wth-par.wth-name       = buf_wealth.wth-name
               buf_tt-wth-par.wth-par-name   = SUBSTITUTE ("&1 &2", buf_wth-par.par-val, buf_wth-par.par-unit)
               buf_tt-wth-par.par-rate       = buf_wth-par.par-val
               buf_tt-wth-par.number         = v-num
               v-num                         = v-num + 1
             .
         END.
      END.
   end.
   FOR EACH buf_tt-wth-par
       :
       FOR each buf_tt-grp
       :
         create buf_tt-line.
         assign
            buf_tt-line.grp-code     = buf_tt-grp.grp-code
            buf_tt-line.wth-par-code = buf_tt-wth-par.wth-par-code
            buf_tt-line.wth-code     = buf_tt-wth-par.wth-code
         .
         FOR EACH  buf_clients
             WHERE buf_clients.grp-code = buf_tt-grp.grp-code
               AND buf_clients.obj-type = 'маг':U
             no-lock
             :
            FOR EACH  buf_wth-parts
               WHERE buf_wth-parts.ext-doc-type = 'ee':U
               AND buf_wth-parts.wth-code     = buf_tt-wth-par.wth-code
               AND buf_wth-parts.par-code     = buf_tt-wth-par.wth-par-code
               AND buf_wth-parts.beg-dt       >= p-begin-date
               AND buf_wth-parts.beg-dt       <= p-end-date
               AND buf_wth-parts.obj-type     = buf_clients.obj-type
               AND buf_wth-parts.obj-code     = buf_clients.obj-code
               NO-LOCK
               :
               if lookup(buf_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) <> 0
               OR buf_wth-parts.fact-order <= 0 then next.
               assign
                  buf_tt-line.summ-4 = buf_tt-line.summ-4 + buf_wth-parts.fact-qnty
                  buf_tt-line.summ-5 = buf_tt-line.summ-5 + buf_wth-parts.fact-qnty * buf_tt-wth-par.par-rate
                  buf_tt-line.summ-6 = buf_tt-line.summ-6 + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
               .
            END.
            FOR EACH  buf_wth-parts
               WHERE buf_wth-parts.ext-doc-type       = 'xc':U
               AND buf_wth-parts.type = 'рас':U
               AND buf_wth-parts.wth-code     = buf_tt-wth-par.wth-code
               AND buf_wth-parts.par-code     = buf_tt-wth-par.wth-par-code
               AND buf_wth-parts.beg-dt       >= p-begin-date
               AND buf_wth-parts.beg-dt       <= p-end-date
               AND buf_wth-parts.obj-type     = buf_clients.obj-type
               AND buf_wth-parts.obj-code     = buf_clients.obj-code
               NO-LOCK
               :
               if lookup(buf_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) <> 0
               OR buf_wth-parts.fact-order <= 0 then next.
               assign
                  buf_tt-line.summ-4 = buf_tt-line.summ-4 + buf_wth-parts.fact-qnty
                  buf_tt-line.summ-5 = buf_tt-line.summ-5 + buf_wth-parts.fact-qnty * buf_tt-wth-par.par-rate
                  buf_tt-line.summ-6 = buf_tt-line.summ-6 + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
               .
            END.
            FOR EACH  buf_wth-parts
               WHERE buf_wth-parts.ext-doc-type       = 'pz':U
               AND buf_wth-parts.wth-code     = buf_tt-wth-par.wth-code
               AND buf_wth-parts.par-code     = buf_tt-wth-par.wth-par-code
               AND buf_wth-parts.beg-dt       >= p-begin-date
               AND buf_wth-parts.beg-dt       <= p-end-date
               AND buf_wth-parts.obj-type     = buf_clients.obj-type
               AND buf_wth-parts.obj-code     = buf_clients.obj-code
               NO-LOCK
               :
               if lookup(buf_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) <> 0
               OR buf_wth-parts.fact-order <= 0 then next.
               assign
                  buf_tt-line.summ-7 = buf_tt-line.summ-7 + buf_wth-parts.fact-qnty * buf_tt-wth-par.par-rate
                  buf_tt-line.summ-8 = buf_tt-line.summ-8 + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
               .
            END.
            FOR EACH  buf_wth-parts
               WHERE buf_wth-parts.ext-doc-type    = 'xc':U
               AND buf_wth-parts.type              = 'при':U
               AND buf_wth-parts.wth-code     = buf_tt-wth-par.wth-code
               AND buf_wth-parts.par-code     = buf_tt-wth-par.wth-par-code
               AND buf_wth-parts.beg-dt       >= p-begin-date
               AND buf_wth-parts.beg-dt       <= p-end-date
               AND buf_wth-parts.obj-type     = buf_clients.obj-type
               AND buf_wth-parts.obj-code     = buf_clients.obj-code
               NO-LOCK
               :
               if lookup(buf_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) <> 0
               OR buf_wth-parts.fact-order <= 0 then next.
               assign
                  buf_tt-line.summ-7 = buf_tt-line.summ-7 + buf_wth-parts.fact-qnty * buf_tt-wth-par.par-rate
                  buf_tt-line.summ-8 = buf_tt-line.summ-8 + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
               .
            END.
            FOR EACH  buf_wth-parts
               WHERE buf_wth-parts.ext-doc-type       = 'pc':U
               AND buf_wth-parts.wth-code     = buf_tt-wth-par.wth-code
               AND buf_wth-parts.par-code     = buf_tt-wth-par.wth-par-code
               AND buf_wth-parts.beg-dt       >= p-begin-date
               AND buf_wth-parts.beg-dt       <= p-end-date
               AND buf_wth-parts.out-obj-type     = buf_clients.obj-type
               AND buf_wth-parts.out-obj-code     = buf_clients.obj-code
               NO-LOCK
               :
               if lookup(buf_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) <> 0
               OR buf_wth-parts.fact-order <= 0 then next.
               IF CAN-FIND( FIRST find_clients
                            WHERE find_clients.obj-type = buf_wth-parts.sale-obj-type
                              AND find_clients.obj-code = buf_wth-parts.sale-obj-code
                              AND find_clients.grp-code = buf_tt-grp.grp-code
                            NO-LOCK)
               THEN DO:
                  assign
                     buf_tt-line.summ-9  = buf_tt-line.summ-9  + buf_wth-parts.fact-qnty * buf_tt-wth-par.par-rate
                     buf_tt-line.summ-10 = buf_tt-line.summ-10 + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
                  .
               END.
               ELSE DO:
                  assign
                     buf_tt-line.summ-11 = buf_tt-line.summ-11 + buf_wth-parts.fact-qnty * buf_tt-wth-par.par-rate
                     buf_tt-line.summ-12 = buf_tt-line.summ-12 + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
                  .
               END.
            END.
            FOR EACH  buf_wth-parts
               WHERE buf_wth-parts.ext-doc-type       = 'ps':U
               AND buf_wth-parts.wth-code     = buf_tt-wth-par.wth-code
               AND buf_wth-parts.par-code     = buf_tt-wth-par.wth-par-code
               AND buf_wth-parts.beg-dt       >= p-begin-date
               AND buf_wth-parts.beg-dt       <= p-end-date
               AND buf_wth-parts.out-obj-type     = buf_clients.obj-type
               AND buf_wth-parts.out-obj-code     = buf_clients.obj-code
               NO-LOCK
               :
               if lookup(buf_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) <> 0
               OR buf_wth-parts.fact-order <= 0 then next.
               IF CAN-FIND( FIRST find_clients
                            WHERE find_clients.obj-type = buf_wth-parts.sale-obj-type
                              AND find_clients.obj-code = buf_wth-parts.sale-obj-code
                              AND find_clients.grp-code = buf_tt-grp.grp-code
                            NO-LOCK)
               THEN DO:
                  assign
                     buf_tt-line.summ-9  = buf_tt-line.summ-9  + buf_wth-parts.fact-qnty * buf_tt-wth-par.par-rate
                     buf_tt-line.summ-10 = buf_tt-line.summ-10 + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
                  .
               END.
               ELSE DO:
                  assign
                     buf_tt-line.summ-11 = buf_tt-line.summ-11 + buf_wth-parts.fact-qnty * buf_tt-wth-par.par-rate
                     buf_tt-line.summ-12 = buf_tt-line.summ-12 + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
                  .
               END.
            END.
            FOR EACH  buf_wth-parts
               WHERE buf_wth-parts.ext-doc-type = 'dc':U
               AND buf_wth-parts.wth-code     = buf_tt-wth-par.wth-code
               AND buf_wth-parts.w-p-code     = buf_tt-wth-par.wth-par-code
               AND buf_wth-parts.beg-dt       >= p-begin-date
               AND buf_wth-parts.beg-dt       <= p-end-date
               AND buf_wth-parts.obj-type     = buf_clients.obj-type
               AND buf_wth-parts.obj-code     = buf_clients.obj-code
               NO-LOCK
               :
               if lookup(buf_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) <> 0
               OR buf_wth-parts.fact-order <= 0 then next.
               assign
                  buf_tt-line.summ-15 = buf_tt-line.summ-15 + buf_wth-parts.fact-qnty * buf_tt-wth-par.par-rate
                  buf_tt-line.summ-16 = buf_tt-line.summ-16 + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
               .
            END.
         END.
      END.
   END.
end.
END PROCEDURE.
PROCEDURE print-header :
do
on error undo, return error
:
    run wthcom-write-cell-data in this-procedure (
          input "h_date1":U
        , input SUBSTITUTE("за период с &1 по &2", p-begin-date , p-end-date )
    ).
end.
END PROCEDURE.
PROCEDURE print-body :
define buffer buf_tt-grp      for tt-grp .
define buffer buf_tt-line     for tt-line .
define buffer buf_tt-wth-par  for tt-wth-par .
do
on error undo, return error
:
   run wthcom-sheet1-write-line-data IN THIS-PROCEDURE .
end.
END PROCEDURE.
PROCEDURE print-footer :
define variable v-dir    as character    no-undo.
define variable v-glbuh    as character    no-undo.
define variable v-oper    as character    no-undo.
define buffer buf_firm           for ub.firm .
define buffer buf_sysconf        for ub.sysconf .
define buffer buf_user-account   for ub.user-account .
do
on error undo, return error
:
   find  first buf_firm
         where buf_firm.firm-code = v-cntxt-host-code-obj
         no-lock
         no-error
         .
   IF AVAILABLE buf_firm
   THEN DO:
      assign
         v-dir   = buf_firm.director
      .
   END.
   ELSE DO:
      assign
         v-dir   = " "
      .
   END.
   find  first buf_sysconf
         where buf_sysconf.host-code = v-cntxt-host-code-obj
         no-lock
         no-error
         .
   IF AVAILABLE buf_sysconf
   THEN DO:
      assign
         v-glbuh   = buf_sysconf.snr-accnt
      .
   END.
   ELSE DO:
      assign
         v-glbuh   = " "
      .
   END.
   FIND FIRST buf_user-account
        WHERE buf_user-account.user-id = v-cntxt-userid
        no-lock
        no-error
        .
   IF AVAILABLE buf_user-account
   THEN DO:
   assign
      v-oper  = SUBSTITUTE("&1 &2 &3", buf_user-account.last-name, buf_user-account.first-name, buf_user-account.second-name )
   .
   END.
   ELSE DO:
   assign
      v-oper  = " "
   .
   END.
    run wthcom-write-cell-data in this-procedure (
          input "h_dir":U
        , input v-dir
    ).
    run wthcom-write-cell-data in this-procedure (
          input "h_glbuh":U
        , input v-glbuh
    ).
    run wthcom-write-cell-data in this-procedure (
          input "h_oper":U
        , input v-oper
    ).
end.
END PROCEDURE.
procedure open-stream :
do
on error undo, return error
:
if session :set-wait-state( "compiler" ) then.
output stream out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size 62 .
    put stream out-stream unformatted
          chr(10)
        + "Печатная форма предназначена только для вывода в Microsoft Excel."
        + chr(10)
    .
    output stream out-stream close.
    run wthcom-init in this-procedure.
end.
end procedure.
procedure close-stream :
do
on error undo, return error
:
    run wthcom-close in this-procedure .
    os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )  .
    os-rename
        value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
        value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
    .
if session :set-wait-state( "" ) then.
    define variable v-user-action   as character no-undo .
    define variable v-printed       as logical   no-undo .
    define variable DisabledOptions as integer   no-undo .
    define variable v-orient-page as character no-undo .
    run gbl/prnfilen.w (
          input "":U
        , input 8
        , input string(session :temp-directory) + "rpt" + string( g#report-num )
        , input ReportFontNum
        , output v-user-action
        , output v-printed
    ).
    os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )  .
end.
end procedure.
