block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: ":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июл 08 17:09:06 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-sl-ved.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-sl-ved.p $":U .
define variable vss-description as character no-undo init "Общая сличислительная ведомость".
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
define input parameter parParentProc   as widget-handle no-undo.
define variable v-cntxt-host-name-obj    as character no-undo .
define variable v-report-name            as character no-undo.
define variable v-period                 as character no-undo.
define variable v-short-obj-list         as character no-undo.
define variable v-choice-gds             as character no-undo.
define variable v-choice-obj             as character no-undo.
define variable v-full-path-RepView      as character no-undo.
define variable v-file-name-rep-htm      as character no-undo.
define variable v-par-type               as character no-undo.
define variable v-unit-OKEI              as integer   no-undo.
define variable v-unit-name              as char      no-undo.
define variable v-obj-code               as integer   no-undo.
define variable v-obj-type               as char      no-undo.
define variable var-x-sum-type           like doc-line-sum.sum-type no-undo.
define variable var-x-ost-sum-type       like doc-line-sum.sum-type no-undo.
define variable v-print-rubl             as logical   no-undo .
define variable v-curr-r-b               as character no-undo .
define variable num-g#                   as integer   no-undo.
define variable p-object                 as char.
define variable FixProdAttr              as character no-undo.
define variable v-izl-sum                as decimal.
define variable v-izl-qnty               as decimal.
define variable v-ned-sum                as decimal.
define variable v-ned-qnty               as decimal.
define variable v-grp-code               like ub.gds-grp.node-code no-undo.
define variable v-grp-name               like ub.goods.grp-name no-undo.
define variable ii-grp                   as integer   no-undo.
define variable v-found                  as logical   no-undo.
define variable v-temp-f-o               as decimal   no-undo .
define variable v-shift-end-fact-order   as decimal   no-undo .
define variable v-shift-start-fact-order as decimal   no-undo .
define variable v-inv-end-fact-order     as decimal   no-undo .
define variable v-inv-start-fact-order   as decimal   no-undo .
define variable p-doc-date               like trn-doc.doc-date.
define variable CurrGrpName              as character no-undo .
define variable p-doc-code               as char.
define variable v-host-code              as integer   no-undo.
define variable v-curr-code              as integer   no-undo.
define variable g#report-num             as integer   no-undo .
define variable pom-grp                  as integer.
define stream  macr_excel .
define stream  out-stream .
define stream OutStr-html.
define variable v-lvl-num       as integer.
define variable v-file-name     as character no-undo .
define variable v-file-name-ind as integer   no-undo .
define variable v-line          as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-cntxt-obj-name as character no-undo .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
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
define variable vss-include-info10 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure r-sale :
  define input parameter  p-doc-code          like ub.doc-line.doc-code          no-undo .
  define input parameter  p-artic             like ub.doc-line.artic             no-undo .
  define input parameter  p-prod-type         like ub.doc-line.prod-type         no-undo .
  define input parameter  p-prod-code         like ub.doc-line.prod-code         no-undo .
  define output parameter p-fact-qnty         like ub.ot-line.fact-qnty       no-undo .
  define output parameter p-vat-pc            like ub.doc-line.vat-pc         no-undo .
  define output parameter p-slt-pc            like ub.doc-line.slt-pc         no-undo .
  define output parameter p-sum-base          like ub.ot-line.sum-base        no-undo .
  define output parameter p-sum-rubl          like ub.ot-line.sum-rubl        no-undo .
  define output parameter p-vat-base          like ub.ot-line.vat-base        no-undo .
  define output parameter p-vat-rubl          like ub.ot-line.vat-rubl        no-undo .
  define output parameter p-slt-base          like ub.ot-line.slt-base        no-undo .
  define output parameter p-slt-rubl          like ub.ot-line.slt-rubl        no-undo .
  define output parameter p-road-tax-base     like ub.ot-line.road-tax-base   no-undo .
  define output parameter p-road-tax-rubl     like ub.ot-line.road-tax-rubl   no-undo .
  define output parameter p-transport-base    like ub.ot-line.transport-base  no-undo .
  define output parameter p-transport-rubl    like ub.ot-line.transport-rubl  no-undo .
  define output parameter p-other-base        like ub.ot-line.other-base      no-undo .
  define output parameter p-other-rubl        like ub.ot-line.other-rubl      no-undo .
  define output parameter p-excise-base       like ub.ot-line.excise-base     no-undo .
  define output parameter p-excise-rubl       like ub.ot-line.excise-rubl     no-undo .
  define variable vss-description as character no-undo initial "r-sale-01: обработка продажных цен товара".
  do
  on error undo, return error
  :
    define  variable price-rubl-with-tax-sale    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-sale    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-sale like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-sale like ub.doc-line.price-base no-undo.
    define  variable vat-base-sale               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyer              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyer              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-sale               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-sale          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-sale          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-sale            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-sale            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-sale            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-sale            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtl for ub.gds-dtl.
    define buffer out-vatp_parts       for ub.parts.
    define buffer out-vatp_sysconf     for ub.sysconf.
    define buffer out-vatp_doc-line    for ub.doc-line.
    define buffer out-vatp_goods       for ub.goods.
    define buffer out-vatp_trn-doc     for ub.trn-doc.
    define buffer out-vatp_doc-attr    for ub.doc-attr.
    define variable varprice-base-cons      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-cons      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-type         as   character                           no-undo.
    define variable varfrm-cnsv              as   character                           no-undo.
    define variable varroot-node             as   integer                             no-undo.
    define variable varempty-scale           as   logical                             no-undo.
    define variable varis-cons-parts-have    as   logical                             no-undo.
    define variable varsum-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtl        as   logical                             no-undo.
    define variable varcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprb               as   character                           no-undo.
    define variable out-vatp-have-vat-slt    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-doco  for ub.trn-doc .
    define buffer   in-vatp-partso    for ub.parts   .
    define buffer   in-vatp-doco      for ub.trn-doc .
    define buffer   in-vatp-goodso    for ub.goods   .
    define buffer   in-vatp-sysconfo  for ub.sysconf .
    define buffer   in-vatp_doc-attro for ub.doc-attr.
    define variable in-vatp-have-vat-slto       as   logical initial yes    no-undo.
    define variable vat-pc-loco                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbo                  as   character              no-undo.
    define variable slt-pc-loco                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateo              as   decimal                no-undo.
    define variable price-rubl-with-tax-loco    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loco    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loco     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loco like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loco like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loco  like ub.doc-line.price-base no-undo.
    define variable vat-base-loco               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loco               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loco           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loco         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loco         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loco          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loco             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loco             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loco              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loco          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdo             as   character              no-undo.
    define variable varinvatp-typeo             as   character              no-undo.
    define variable v-gds-dtl-fact-qnty as decimal no-undo .
    define buffer buf_gds-dtl  for ub.gds-dtl .
    define buffer buf_goods    for ub.goods .
    define buffer buf_trn-doc  for ub.trn-doc .
    define buffer buf_doc-line for ub.doc-line .
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info11 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info11 skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
        and buf_gds-dtl.artic     = buf_doc-line.artic
        and buf_gds-dtl.prod-type = buf_doc-line.prod-type
        and buf_gds-dtl.prod-code = buf_doc-line.prod-code
    on error undo, return error
    :
        if buf_trn-doc.doc-type <> 'инв':U
        then do:
            if buf_trn-doc.doc-type = 'при':U
            or buf_trn-doc.doc-type = 'возврат':U
            then do:
                assign
                    v-gds-dtl-fact-qnty = buf_gds-dtl.fact-qnty
                .
            end.
            else do:
                assign
                    v-gds-dtl-fact-qnty = - buf_gds-dtl.fact-qnty
                .
            end.
        end.
        else do:
            assign
                v-gds-dtl-fact-qnty = buf_gds-dtl.doc-qnty
            .
        end.
        if v-gds-dtl-fact-qnty <> 0
        then do:
if buf_trn-doc.ext-doc-type = 'ot':U or
   buf_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and out-vatp_doc-attr.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attr then do:
    assign
      out-vatp-have-vat-slt = yes.
  end.
  else do:
     out-vatp-have-vat-slt = no.
  end.
end.
find first out-vatp_goods where out-vatp_goods.artic     = buf_doc-line.artic     and
                                   out-vatp_goods.prod-type = buf_doc-line.prod-type and
                                   out-vatp_goods.prod-code = buf_doc-line.prod-code no-lock.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-node
  ,input  'empty-scale=request'
  ,output varempty-scale
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * buf_trn-doc.base-rate / buf_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = buf_trn-doc.doc-code
       and out-vatp_doc-line.artic      = buf_doc-line.artic
       and out-vatp_doc-line.prod-type  = buf_doc-line.prod-type
       and out-vatp_doc-line.prod-code  = buf_doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = buf_trn-doc.doc-code
                               and out-vatp_parts.obj-type   = buf_trn-doc.obj-type
                               and out-vatp_parts.obj-code   = buf_trn-doc.obj-code
                               and out-vatp_parts.artic      = buf_doc-line.artic
                               and out-vatp_parts.prod-type  = buf_doc-line.prod-type
                               and out-vatp_parts.prod-code  = buf_doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbo
  )  .
  if out-vatp_parts.out-code = 'free-zone':U     or
     out-vatp_parts.out-code = 'out-zone':U   or
     out-vatp_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slto = yes.
  end.
  else do:
    find first in-vatp_doc-attro no-lock
      where in-vatp_doc-attro.doc-code  = out-vatp_parts.out-code
        and in-vatp_doc-attro.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attro then do:
      assign
        in-vatp-have-vat-slto = yes.
    end.
    else do:
         in-vatp-have-vat-slto = no.
    end.
  end.
  assign
   price-cli-with-tax-loco = out-vatp_parts.price-cli
   cli-base-rateo          = out-vatp_parts.cli-base-rate.
  ASSIGN   road-tax-base-loco  = (if out-vatp_parts.road-tax-base  = ? then 0 else out-vatp_parts.road-tax-base)
           road-tax-rubl-loco  = (if out-vatp_parts.road-tax-rubl  = ? then 0 else out-vatp_parts.road-tax-rubl).
  ASSIGN  transport-base-loco = (if out-vatp_parts.transport-base = ? then 0 else out-vatp_parts.transport-base)
          transport-rubl-loco = (if out-vatp_parts.transport-rubl = ? then 0 else out-vatp_parts.transport-rubl)
          other-base-loco     = (if out-vatp_parts.other-base     = ? then 0 else out-vatp_parts.other-base)
          other-rubl-loco     = (if out-vatp_parts.other-rubl     = ? then 0 else out-vatp_parts.other-rubl)
          vat-pc-loco         = (if out-vatp_parts.vat-pc         = ? then 0 else out-vatp_parts.vat-pc)
          slt-pc-loco         = (if out-vatp_parts.slt-pc         = ? then 0 else out-vatp_parts.slt-pc).
          ASSIGN   slt-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
    ASSIGN   slt-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
  assign
    exch-rate-cli-loco = (out-vatp_parts.price-rubl - transport-rubl-loco - other-rubl-loco - road-tax-rubl-loco - (if out-vatp_parts.vat-type <> 'в т. ч.':U then vat-rubl-loco else 0) - (if out-vatp_parts.slt-type <> 'в т. ч.':U then slt-rubl-loco else 0)) / out-vatp_parts.price-cli .
  assign
    slt-cli-loco        = slt-rubl-loco       / exch-rate-cli-loco
    vat-cli-loco        = vat-rubl-loco       / exch-rate-cli-loco
    road-tax-cli-loco   = road-tax-rubl-loco  / exch-rate-cli-loco
    transport-cli-loco  = 0
    other-cli-loco      = 0
  .
ASSIGN
          price-base-without-tax-loco = price-base-with-tax-loco - vat-base-loco - slt-base-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))
    price-rubl-without-tax-loco = price-rubl-with-tax-loco - vat-rubl-loco - slt-rubl-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))
.
      assign
        varprice-base-cons = varprice-base-cons + (price-base-with-tax-loco - (if road-tax-base-loco = ? then 0 else road-tax-base-loco))* out-vatp_parts.fact-qnty
        varprice-rubl-cons = varprice-rubl-cons + (price-rubl-with-tax-loco - (if road-tax-rubl-loco = ? then 0 else road-tax-rubl-loco))* out-vatp_parts.fact-qnty.
      assign
        varis-cons-parts-have = yes
        varcons-qnty          = varcons-qnty + out-vatp_parts.fact-qnty.
    end.
    assign
      varfact-qnty = varfact-qnty + out-vatp_parts.fact-qnty.
  end.
end.
assign
  varprice-base-cons = varprice-base-cons / varcons-qnty
  varprice-rubl-cons = varprice-rubl-cons / varcons-qnty.
if varprice-base-cons = ? then do:
  assign
    varprice-base-cons = 0.
end.
if varprice-rubl-cons = ? then do:
  assign
    varprice-rubl-cons = 0.
end.
assign
    slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-base-sale            = buf_gds-dtl.discnt-base
  price-base-with-tax-sale    = (buf_gds-dtl.price-base - buf_gds-dtl.discnt-base)
    slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-rubl-sale            = buf_gds-dtl.discnt-rubl
  price-rubl-with-tax-sale    = (buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl)
  .
if buf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty = buf_gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty = buf_gds-dtl.fact-qnty.
end.
if varis-cons-parts-have = no then do:
  assign
        vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
        vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc).
end.
else do:
  if buf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
  else do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-base-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-rubl-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
end.
assign
price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
            ASSIGN
                p-fact-qnty           = p-fact-qnty     + v-gds-dtl-fact-qnty
                p-sum-base            = p-sum-base      + price-base-with-tax-sale  * v-gds-dtl-fact-qnty
                p-sum-rubl            = p-sum-rubl      + price-rubl-with-tax-sale  * v-gds-dtl-fact-qnty
                p-vat-base            = p-vat-base      + vat-base-sale             * v-gds-dtl-fact-qnty
                p-vat-rubl            = p-vat-rubl      + vat-rubl-sale             * v-gds-dtl-fact-qnty
                p-slt-base            = p-slt-base      + slt-base-sale             * v-gds-dtl-fact-qnty
                p-slt-rubl            = p-slt-rubl      + slt-rubl-sale             * v-gds-dtl-fact-qnty
                p-road-tax-base       = p-road-tax-base + road-tax-base-sale        * v-gds-dtl-fact-qnty
                p-road-tax-rubl       = p-road-tax-rubl + road-tax-rubl-sale        * v-gds-dtl-fact-qnty
                p-excise-base         = p-excise-base   + excise-base-sale          * v-gds-dtl-fact-qnty
                p-excise-rubl         = p-excise-rubl   + excise-rubl-sale          * v-gds-dtl-fact-qnty
                p-other-base          = p-other-base    + discnt-base-sale          * v-gds-dtl-fact-qnty
                p-other-rubl          = p-other-rubl    + discnt-rubl-sale          * v-gds-dtl-fact-qnty
            .
        end.
    end.
    assign
        p-transport-base      = 0
        p-transport-rubl      = 0
        p-vat-pc              = buf_doc-line.vat-pc
        p-slt-pc              = buf_doc-line.slt-pc
    .
  end.
  if p-fact-qnty      = ?
  or p-vat-pc         = ?
  or p-slt-pc         = ?
  or p-sum-base       = ?
  or p-sum-rubl       = ?
  or p-vat-base       = ?
  or p-vat-rubl       = ?
  or p-slt-base       = ?
  or p-slt-rubl       = ?
  or p-road-tax-base  = ?
  or p-road-tax-rubl  = ?
  or p-transport-base = ?
  or p-transport-rubl = ?
  or p-other-base     = ?
  or p-other-rubl     = ?
  or p-excise-base    = ?
  or p-excise-rubl    = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      vss-include-info11 skip
      "Получены неопределенные значения" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "fact-qnty     " p-fact-qnty      skip
      "vat-pc        " p-vat-pc         skip
      "slt-pc        " p-slt-pc         skip
      "sum-base      " p-sum-base       skip
      "sum-rubl      " p-sum-rubl       skip
      "vat-base      " p-vat-base       skip
      "vat-rubl      " p-vat-rubl       skip
      "slt-base      " p-slt-base       skip
      "slt-rubl      " p-slt-rubl       skip
      "road-tax-base " p-road-tax-base  skip
      "road-tax-rubl " p-road-tax-rubl  skip
      "transport-base" p-transport-base skip
      "transport-rubl" p-transport-rubl skip
      "other-base    " p-other-base     skip
      "other-rubl    " p-other-rubl     skip
      "excise-base   " p-excise-base    skip
      "excise-rubl   " p-excise-rubl    skip
      view-as alert-box error .
    undo, return error .
  end.
end procedure.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-sys-key as character no-undo.
define buffer buf_units    for units.
define buffer buf_trn-doc  for trn-doc.
define buffer buf_doc-line for doc-line.
define buffer buf_goods    for goods.
define temp-table temp-doc no-undo
    field number     as integer
    field gds-code   like goods.gds-code
    field gds-name   like goods.gds-name
    field izl-sum    as decimal
    field izl-qnty   as decimal
    field ned-sum    as decimal
    field ned-qnty   as decimal
    field obj-code   as integer
    field obj-type   as char
    field doc-code   as char
    field OKEI       as integer
    field grp-code   like goods.grp-code
    field unit-name  as char
    field grp-lvl    as integer
    field lvl-num    as integer
    field upper-code as integer
    field lvl        as integer
    INDEX tt-doc is primary doc-code obj-code obj-type
    index tt-grp            grp-lvl  obj-type obj-code
    .
function fnc-DD-MM-YYYY returns character
    (input p-dat-date as date) forward.
function fnc-convert-dot-to-colon returns character
    (input p-data as decimal, input p-accur as character) forward.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currsysk in g#library
  (output v-sys-key
  ) no-error .
if error-status :error then
do:
    message
        vss-workfile vss-revision vss-description skip
        "Ошибка при чтении параметра конфигурации" '"sys-key"' skip
        error-status :get-message( 1 ) skip
        return-value skip
        view-as alert-box error .
    return.
end.
if error-status :error then
do:
    message
        vss-workfile vss-revision vss-description skip
        "Ошибка при чтении параметра конфигурации" '"sys-key"' skip
        error-status :get-message( 1 ) skip
        return-value skip
        view-as alert-box error .
    return.
end.
do
    for buf_trn-doc
    , buf_doc-line
    on error undo, return error
    :
if session :set-wait-state( "compiler" ) then.
end.
case X-selectgood:
    when 2 then
        do:
            for each tmp#grp no-lock
                :
                num-g# = num-g# + 1.
                if num-g# = 1 then FixProdAttr = string(tmp#grp.node-code).
                if num-g# > 1 then leave.
            end.
        end.
end case.
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
define variable x-date-start-t like stk-tot.shift-date no-undo.
run ostatok (
    input 0  ,
    input ""  ,yes,
    input x-date-start - 1 ,
    input date('')      ,  x-Shift-Start,x-Shift-End,
    input 'crsa':U   ,
    input '##,##':U,
    input false ,
    output  v-temp-f-o  ,
    output  v-temp-f-o   ,
    output  v-temp-f-o   ,
    output  v-temp-f-o     ,
    output  v-temp-f-o     ,
    output  v-shift-start-fact-order ).
run ostatok (
    input 0  ,
    input ""  ,yes,
    input x-date-start  ,
    input x-date-end    ,  x-Shift-Start,x-Shift-End,
    input 'crsa':U   ,
    input '##,##':U,
    input false ,
    output  v-temp-f-o  ,
    output  v-temp-f-o   ,
    output  v-temp-f-o   ,
    output  v-temp-f-o     ,
    output  v-temp-f-o     ,
    output  v-shift-end-fact-order ).
for each obj-list
    :
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  obj-list.obj-type
  ,input  obj-list.obj-code
  ,output v-cntxt-host-code-obj
  ,output v-cntxt-host-name-obj
  )  .
    for each ub.trn-doc where
        ub.trn-doc.obj-type = obj-list.obj-type and
        ub.trn-doc.obj-code = obj-list.obj-code
        and
        trn-doc.fact-order  <= v-shift-end-fact-order and
        trn-doc.fact-order   > v-shift-start-fact-order
        :
        case x-SET_PAY_TYPE :
            when 2 then
                do:
                    assign
                        var-x-sum-type     = 'cost':U
                        var-x-ost-sum-type = 'cost':U
                        .
                end.
            when 1 then
                do:
                    assign
                        var-x-sum-type     = 'crsa':U
                        var-x-ost-sum-type = 'crsa':U
                        .
                end.
            when 3 then
                do:
                    assign
                        var-x-sum-type     = 'sale':U
                        var-x-ost-sum-type = 'crsa':U
                        .
                end.
            otherwise
            do:
                assign
                    var-x-sum-type     = 'cost':U
                    var-x-ost-sum-type = 'cost':U
                    .
            end.
        end case.
        run doc-calc.
    end.
    run transform-tt-level.
end.
run get-full-path-RepViewer(output v-full-path-RepView).
run get-report-num in parParentProc(output g#report-num).
run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).
run create-file(v-file-name-rep-htm).
v-report-name = "Общая сличительная ведомость".
run proc-create-HTML (input v-file-name-rep-htm
    ,input v-cntxt-host-name-obj
    ,input v-report-name
    ,input p-doc-code
    ,input p-doc-date
    ,input p-object
    ,input v-izl-sum
    ,input v-izl-qnty
    ,input v-ned-sum
    ,input v-ned-qnty
    ).
run search-full-path-Report(input v-file-name-rep-htm).
run Report-Viewer(input v-full-path-RepView, input v-file-name-rep-htm).
procedure doc-calc:
    define variable p-gds-name    as character.
    define variable p-grp-code    as integer.
    define variable p-gds-code    as integer.
    define variable v-gds-name    as char.
    define variable p-okei        as integer.
    define variable p-ned-qnty    as decimal.
    define variable p-unit-name   as char.
    define variable p-ned-sum     as decimal.
    define variable p-izl-sum     as decimal.
    define variable p-izl-qnty    as decimal.
    define variable p-unit-base   as char.
    define variable help-grp-code as integer.
define variable p-help-grp-code as integer.
    _chk: for each doc-line where doc-line.doc-code = trn-doc.doc-code
        and doc-line.obj-type = obj-list.obj-type
        and doc-line.obj-code = obj-list.obj-code
        and doc-line.ext-doc-type = 'vt':U
        and doc-line.status_ = 'факт':U
        and doc-line.fact-qnty <> 0
        no-lock :
        find first buf_goods where buf_goods.prod-type = doc-line.prod-type and
            buf_goods.prod-code = doc-line.prod-code and
            buf_goods.artic = doc-line.artic .
        p-gds-code = buf_goods.gds-code.
        p-grp-code = buf_goods.grp-code.
        p-gds-name = buf_goods.gds-name.
        p-unit-base = buf_goods.unit-base.
        case x-SelectGood:
            when 4 or
            when 6     or
            when 5   then
                do:
                                      run tt-lvl (input p-grp-code, output help-grp-code  ) .
                    find  first gds-list no-lock
                        where gds-list.artic     = doc-line.artic
                        and gds-list.prod-type = doc-line.prod-type
                        and gds-list.prod-code = doc-line.prod-code
                        no-error .
                    if not available gds-list then next.
                end.
            when 1  then
                do:
                  run tt-lvl (input p-grp-code, output help-grp-code  ) .
                end.
            when 2 then
                do :
                    assign
                        v-grp-name = ""
                        v-found    = no
                        .
                    _ii-grp: do ii-grp = 1 to num-entries(buf_goods.grp-name, chr(47)) - 1
                        :
                        assign
                            v-grp-name = v-grp-name + entry(ii-grp, buf_goods.grp-name, chr(47)) + chr(47)
                            .
                        if can-find(first tmp#grp no-lock where
                            tmp#grp.grp-name = v-grp-name) then
                        do:
                            v-found = yes.
                            leave _ii-grp.
                        end.
                    end.
                    if not v-found then next _chk.
                end.
            otherwise
            do:
                find  first gds-list no-lock
                    where doc-line.artic     = gds-list.artic
                    and doc-line.prod-type = gds-list.prod-type
                    and doc-line.prod-code = gds-list.prod-code no-error .
                if not available  gds-list then next.
            end.
        end case.
        if   x-SelectGood = 2 then
        do:
            run tt-grp (input buf_goods.grp-code, output p-help-grp-code) .
            help-grp-code = p-help-grp-code.
        end.
        p-doc-date =  trn-doc.doc-date.
        p-doc-code = doc-line.doc-code.
        p-object = obj-list.obj-name.
        find first temp-doc where temp-doc.gds-code = p-gds-code and
            temp-doc.obj-code = doc-line.obj-code and
            temp-doc.obj-type = doc-line.obj-type
            no-error.
        if not available temp-doc then
        do:
            create temp-doc.
            assign
                temp-doc.gds-code = p-gds-code
                temp-doc.doc-code = doc-line.doc-code
                temp-doc.obj-code = doc-line.obj-code
                temp-doc.obj-type = doc-line.obj-type
                temp-doc.gds-name = p-gds-name
                temp-doc.grp-code = help-grp-code.
            find first units no-lock
                where units.unit-name = p-unit-base.
            temp-doc.okei = units.OKEI.
            temp-doc.unit-name =  units.unit-name.
        end.
        find first doc-line-sum
            where
            doc-line-sum.doc-code = doc-line.doc-code
            and
            doc-line-sum.gds-code = p-gds-code
            and doc-line-sum.sum-type = 'gen':U
            .
        if  available doc-line-sum
            then
        do:
            if doc-line-sum.fact-qnty >= 0
                then
            do:
                assign
                    p-izl-qnty = doc-line-sum.fact-qnty
                    p-ned-qnty = 0.0
                    .
                if var-x-sum-type = 'crsa':U
                    then
                do:
                    assign
                        p-izl-sum = doc-line-sum.sale-sum-rubl
                        p-ned-sum = 0.0
                        .
                end.
                else
                do:
                    assign
                        p-izl-sum = doc-line-sum.cost-sum-rubl
                        p-ned-sum = 0.0
                        .
                end.
            end.
            else
            do:
                assign
                    p-izl-qnty = 0.0
                    p-ned-qnty = (-1) * doc-line-sum.fact-qnty
                    .
                if var-x-sum-type = 'crsa':U
                    then
                do:
                    assign
                        p-izl-sum = 0.0
                        p-ned-sum = (-1.0) * doc-line-sum.sale-sum-rubl
                        .
                end.
                else
                do:
                    assign
                        p-izl-sum = 0.0
                        p-ned-sum = (-1.0) * doc-line-sum.cost-sum-rubl
                        .
                end.
            end.
        end.
        else
        do:
            if var-x-sum-type = 'crsa':U
                then
            do:
                if doc-line.fact-qnty >= 0
                    then
                do:
                    assign
                        p-izl-qnty = doc-line.fact-qnty
                        p-ned-qnty = 0.0
                        p-izl-sum  = doc-line.price-base * doc-line.fact-qnty.
                    p-ned-sum  = 0.0
                        .
                end.
                else
                do:
                    assign
                        p-izl-qnty = 0.0
                        p-ned-qnty = (-1.0) * doc-line.fact-qnty
                        p-izl-sum  = 0.0
                        p-ned-sum  = (-1.0) * doc-line.price-base * doc-line.fact-qnty.
                    .
                end.
            end.
            else
            do:
                if doc-line.fact-qnty >= 0
                    then
                do:
                    assign
                        p-izl-qnty = doc-line.fact-qnty
                        p-ned-qnty = 0.0
                        p-izl-sum  = doc-line.price-rubl * doc-line.fact-qnty.
                    p-ned-sum  = 0.0
                        .
                end.
                else
                do:
                    assign
                        p-izl-qnty = 0.0
                        p-ned-qnty = (-1.0) * doc-line.fact-qnty
                        p-izl-sum  = 0.0
                        p-ned-sum  = (-1.0) * doc-line.price-rubl * doc-line.fact-qnty.
                end.
            end.
        end.
        temp-doc.izl-sum = p-izl-sum + temp-doc.izl-sum.
        temp-doc.izl-qnty = p-izl-qnty + temp-doc.izl-qnty.
        temp-doc.ned-sum = p-ned-sum + temp-doc.ned-sum.
        temp-doc.ned-qnty = p-ned-qnty + temp-doc.ned-qnty.
        v-izl-sum = v-izl-sum + p-izl-sum.
        v-izl-qnty = v-izl-qnty + p-izl-qnty.
        v-ned-sum = v-ned-sum + p-ned-sum.
        v-ned-qnty = v-ned-qnty + p-ned-qnty.
    end.
end procedure.
procedure tt-grp:
    define input parameter p-grp-code as integer.
    define output parameter tt-hp-grp-code as integer .
        find first gds-grp  no-lock  where gds-grp.node-code = p-grp-code   no-error.
         if available gds-grp then
        do:
    find first tmp#grp where tmp#grp.node-code  =  p-grp-code  no-error.
    if available tmp#grp then
    do:
             tt-hp-grp-code = p-grp-code.
        end.
    else
    do :
        run tt-grp(input gds-grp.upper-code, output tt-hp-grp-code).
    end.
end.
end procedure.
procedure transform-tt-level:
    define buffer buftt_temp-doc for temp-doc.
    define variable v-gds-name     as character no-undo.
    define variable v-cur-lvl      as integer   no-undo.
    define variable v-upper-code   as integer   initial ? no-undo.
    define variable v-ii           as integer   no-undo.
    define variable p-grp-izl-sum  as decimal.
    define variable v-lvl          as integer.
    define variable p-grp-izl-qnty as decimal.
    define variable p-grp-ned-sum  as decimal.
    define variable p-grp-ned-qnty as decimal.
    define buffer buftt2_temp-doc for temp-doc.
    do while v-upper-code <> 0:
        v-upper-code = 0.
        for each temp-doc where temp-doc.grp-lvl =  v-cur-lvl
            and temp-doc.obj-type = obj-list.obj-type
            and  temp-doc.obj-code = obj-list.obj-code
            use-index tt-grp
            break by temp-doc.grp-code
            :
            v-ii = v-ii + 1.
            if first-of (temp-doc.grp-code)  then
            do:
                assign
                    p-grp-izl-sum  = 0
                    p-grp-izl-qnty = 0
                    p-grp-ned-sum  = 0
                    p-grp-ned-qnty = 0.
                find first ub.gds-grp where
                    ub.gds-grp.node-code = temp-doc.grp-code
                    no-lock no-error.
                if available ub.gds-grp then
                do:
                    assign
                        v-gds-name = ub.gds-grp.node-name
                        v-lvl      = gds-grp.lvl-num.
                    v-upper-code = gds-grp.upper-code.
                end.
            end.
            assign
                p-grp-izl-sum  = p-grp-izl-sum + temp-doc.izl-sum
                p-grp-izl-qnty = p-grp-izl-qnty + temp-doc.izl-qnty
                p-grp-ned-sum  = p-grp-ned-sum + temp-doc.ned-sum
                p-grp-ned-qnty = p-grp-ned-qnty + temp-doc.ned-qnty
                .
            if  temp-doc.grp-lvl <> 0 then
            do:
                assign
                    temp-doc.gds-name = v-gds-name
                    .
            end.
            if last-of (temp-doc.grp-code) and v-upper-code <> 0  and temp-doc.gds-code <> 0  then
            do :
                find first  buftt_temp-doc where
                    buftt_temp-doc.obj-code = obj-list.obj-code and
                    buftt_temp-doc.obj-type = obj-list.obj-type and
                    buftt_temp-doc.lvl-num = 2 and
                    buftt_temp-doc.grp-lvl =  buftt_temp-doc.grp-lvl + 1 and
                    buftt_temp-doc.grp-code   =  (if temp-doc.grp-lvl = 0 then temp-doc.grp-code
                    else v-upper-code)
                    and
                    buftt_temp-doc.gds-code = 0 no-error.
                if not available  buftt_temp-doc  then
                do:
                    create buftt_temp-doc .
                    assign
                        buftt_temp-doc.lvl-num  = 2
                        buftt_temp-doc.grp-lvl  = buftt_temp-doc.grp-lvl + 1
                        buftt_temp-doc.grp-code = (if temp-doc.grp-lvl = 0 then temp-doc.grp-code
                          else v-upper-code)
                        buftt_temp-doc.obj-code = obj-list.obj-code
                        buftt_temp-doc.obj-type = obj-list.obj-type
                        buftt_temp-doc.gds-code = 0.
                end.
                assign
                    buftt_temp-doc.gds-name = v-gds-name
                    buftt_temp-doc.izl-qnty = buftt_temp-doc.izl-qnty + p-grp-izl-qnty
                    buftt_temp-doc.izl-sum  = buftt_temp-doc.izl-sum + p-grp-izl-sum
                    buftt_temp-doc.ned-qnty = buftt_temp-doc.ned-qnty + p-grp-ned-qnty
                    buftt_temp-doc.ned-sum  = buftt_temp-doc.ned-sum +  p-grp-ned-sum .
            end.
        end.
        v-cur-lvl = v-cur-lvl + 1.
    end.
    for each buftt2_temp-doc where buftt2_temp-doc.grp-code <> 0  and
        buftt2_temp-doc.gds-code = 0 and  buftt2_temp-doc.lvl-num = 2 :
        for each buftt_temp-doc where buftt_temp-doc.grp-code = buftt2_temp-doc.grp-code and buftt2_temp-doc.grp-lvl <> buftt_temp-doc.grp-lvl and   buftt2_temp-doc.lvl-num = 2 and   buftt_temp-doc.gds-code = 0   :
            assign
                buftt2_temp-doc.izl-qnty = buftt_temp-doc.izl-qnty + buftt2_temp-doc.izl-qnty
                buftt2_temp-doc.izl-sum  = buftt_temp-doc.izl-sum  +  buftt2_temp-doc.izl-sum
                buftt2_temp-doc.ned-qnty = buftt_temp-doc.ned-qnty  + buftt2_temp-doc.ned-qnty
                buftt2_temp-doc.ned-sum  = buftt_temp-doc.ned-sum + buftt2_temp-doc.ned-sum .
            delete buftt_temp-doc.
        end.
    end.
end procedure.
procedure tt-lvl:
    define input parameter p-grp-code as integer.
    define output parameter hp-grp-code as integer .
    find first gds-grp  no-lock  where gds-grp.node-code = p-grp-code  and gds-grp.upper-code <> 1  no-error.
    if available gds-grp then
    do:
        hp-grp-code = p-grp-code.
        pom-grp = hp-grp-code.
        if gds-grp.upper-code <> 1    then
        do:
            run tt-lvl(input gds-grp.upper-code, output hp-grp-code).
        end.
    end.
    else
    do :
        hp-grp-code =  pom-grp.
    end.
end procedure.
procedure proc-create-HTML:
    define input parameter p-file-name-rep-htm as character no-undo.
    define input parameter v-cntxt-host-name-obj as char.
    define input parameter p-report-name as character no-undo.
    define input parameter p-doc-code as char.
    define input parameter p-doc-date as date.
    define input parameter p-object as char.
    define input parameter v-izl-sum as decimal.
    define input parameter v-izl-qnty as decimal.
    define input parameter v-ned-sum as decimal.
    define input parameter v-ned-qnty as decimal.
    define variable p-number as integer.
    define variable v-number as integer.
    define buffer buf_temp-doc-html for temp-doc.
    p-number = 1 .
    v-number = 1.
    do:
        output stream OutStr-html to value(p-file-name-rep-htm) append convert target 'UTF-8'.
        put stream OutStr-html unformatted
            "<!DOCTYPE HTML>" skip
            ' <html>' skip
            '  <head>' skip
            '   <meta charset="utf-8">' skip
            '    <style type="text/css">' skip
            '      table ' + chr(123) + ' border-collapse: collapse; font-size:9pt; font-family:Calibri; table-layout: fixed; width: 540px; hight:  padding: 8px;  ' + chr(125) skip
            '      td ' + chr(123) ' border: 1px black solid; word-wrap:break-word; ' + chr(125) skip
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
            '     <body>' skip
            '  <A NAME="тит"><H1><EM></EM></H1></A>' skip
            '<TABLE name="тит"  fit_to_page="true" orientation="landscape" CELLSPACING="0" COLS="16" BORDER="0">'skip
            '  <COLGROUP SPAN="10" WIDTH="66">'skip
            ' <COLGROUP WIDTH="30">'skip
            '<COLGROUP WIDTH="110">'skip
            '<COLGROUP SPAN="3" WIDTH="66">'skip
            '<COLGROUP WIDTH="133"></COLGROUP>' skip
            '<TR>'skip
            '<TD  style="width: 6px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 79px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 11px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 42px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 56px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 89px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 15px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 63px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 49px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 53px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 9px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 125px; text-align: left;border: none"></TD>'skip
            '<TD style="width: 79px; text-align: left;border: none"></TD>'skip
            '<TD colspan="3" style="text-align: left;border: none"> Унифицированная форма № ИНВ-19</TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD colspan="3"style="text-align: left;border: none">Утверждена постановлением Госкомстата</TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD colspan = "3" style="text-align: left;border: none"> России от 18.08.98 № 88 </TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="18" style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="width: 42px; text-align: left;border: none"></TD>'skip
            '<TD  style="width: 73px; text-align: left;border: none"></TD>'skip
            '<TD STYLE="width: 127px; border:  1px solid black; text-align: left;">Код</TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  colspan = "2" style="text-align: right;border: none">Форма по ОКУД</TD>'skip
            '<TD STYLE="border: 1px solid black;text-align: left;">0317017</TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD COLSPAN="7"  HEIGHT="17" STYLE="border: none; border-bottom: 1px solid black; text-align: center;"> ' + v-cntxt-host-name-obj + '  </TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none">по ОКПО</TD>'skip
            '<TD STYLE="border: 1px solid black;text-align: left;"> 17863254 </TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD colspan="7" style="text-align: center; border: none"> (организация) </TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left; border: none"></TD>'skip
            '<TD STYLE="border: 1px solid black;text-align: left;"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD  COLSPAN="7" HEIGHT="17"  STYLE="border: none;border-bottom: 1px solid black; text-align: center;"> ' + p-object  +  '</TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD STYLE="border: 1px solid black;text-align: left;"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD colspan="7" style="text-align: center;border: none">(структурное подразделение)</TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD STYLE="border: 1px solid black;text-align: left;"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD STYLE="border: 1px solid black;text-align: left;"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD colspan="5" style="text-align: left;border: none">Основание для проведения инвентаризации:</TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD COLSPAN=4 style="text-align: left;border: none"> приказ,постановление,распоряжеие</TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD STYLE="border: 1px solid black ;text-align: left;">номер</TD>'skip
            '<TD STYLE="border: 1px solid black ;text-align: center;">621-02.6</TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD colspan="3" style="text-align: left;border: none">(ненужное зачеркнуть)</TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD STYLE="border: 1px solid black ;text-align: left;">дата</TD>'skip
            '<TD STYLE="border: 1px solid black ;text-align: center;">7.18.2013</TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD STYLE="border: 1px solid black;text-align: left;"></TD>'skip
            '</TR>'skip
            .
    end.
    do:
        put stream OutStr-html unformatted
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD colspan="3" style="text-align: left;border: none">Дата начала инвентаризации</TD>'skip
            '<TD STYLE="border: 1px solid black ;text-align: center;">' + fnc-DD-MM-YYYY(date(string(X-Date-Start,"99/99/9999"))) + '</TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD colspan="3" style="text-align: left;border: none"> Дата окончания инвентаризации </TD>'skip
            '<TD STYLE="border: 1px solid black ;text-align: center;"> ' + fnc-DD-MM-YYYY(date(string(p-doc-date,"99.99.9999"))) +  '</TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD colspan="2" style="text-align: left;border: none">Вид операции</TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD STYLE="border: 1px solid black ;text-align: center;"> инвентаризация </TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD  style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="18" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none">Номер документа:</TD>'skip
            '<TD colspan="2" style="text-align: left;border: none">Дата составления</TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            .
    end.
    do:
        put stream OutStr-html unformatted
            '<TR>'skip
            '<TD HEIGHT="19" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD colspan = "5" style="font-weight: bold; text-align: left; border: none"> СЛИЧИТЕЛЬНАЯ ВЕДОМОСТЬ</TD>'skip
            '<TD STYLE="border: 1px solid black; text-align: left;"> ' +  p-doc-code + '</td>' skip
            '<TD colspan="2" STYLE="border: 1px solid black; text-align: left;"> ' + fnc-DD-MM-YYYY(date(string(p-doc-date,"99.99.9999"))) + '</td>' skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD colspan ="9" style="font-weight: bold; text-align: left; border: none">результатов инвентаризации товарно-материальных ценностей</TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD colspan="12" style="text-align: left;border: none">Проведена инвентаризация фактического наличия ценностей, находящихся на ответственном хранении</TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD colspan="4" style="text-align: center; border: none;border-bottom: 1px solid black;"> Ст. оператор </TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD COLSPAN="3" STYLE="border: none;border-bottom: 1px solid black;  text-align: center;"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD colspan= "4" STYLE="border: none;border-bottom: 1px solid black; text-align: center;">(должность)</TD>'skip
            '<TD STYLE="text-align: left; border: none;"></TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '<TD colspan="4" style="text-align: center;border: none;">(фамилия, имя, отчество)</TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD colspan="4" style="text-align: center; border: none;border-bottom: 1px solid black;"> оператор </TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD COLSPAN="3" STYLE="border: none; border-bottom: 1px solid black;  text-align: center;"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD STYLE="border: none;border-bottom: 1px solid black; text-align: left;"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD colspan="4" STYLE="border: none ; text-align: center;"> (должность)</TD>'skip
            '<TD STYLE="text-align: left; border: none;"></TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '<TD style="text-align: left;border: none;"></TD>'skip
            '<TD colspan= "4" style="text-align: center;border: none">(фамилия, имя, отчество)</TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD  HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip.
    end.
    do:
        put stream OutStr-html unformatted
            '<TR>'skip
            '<TD  HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD COLSPAN=9 style="text-align: left;border: none"> по состоянию на 1 Августа 2013 г. </TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD colspan="6"style="text-align: left;border: none"> При инвентаризации установлено следующее:</TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</tr>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            '<TR>'skip
            '<TD HEIGHT="17" style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '<TD style="text-align: left;border: none"></TD>'skip
            '</TR>'skip
            .
    end.
    do:
        put stream OutStr-html unformatted
            '</tbody>'
            '   </table>' skip
            '  </body>' skip.
    end.
    do:
        put stream OutStr-html unformatted
            ' <body>' skip
            '   <table name="Слич"  outline_below="false" orientation="landscape">' skip
            '     <thead>' skip
            '       <tr class="set_columns">' skip
            '         <td style="width:20px; border: none;"></td>' skip
            '         <td style="width:135px; border: none;"></td>' skip
            '         <td style="width:48px; border: none;"></td>' skip
            '         <td style="width:25px; border: none;"></td>' skip
            '         <td style="width:39px; border: none;"></td>' skip
            '         <td style="width:35px; border: none;"></td>' skip
            '         <td style="width:30px; border: none;"></td>' skip
            '         <td style="width:47px; border: none;"></td>' skip
            '         <td style="width:65px; border: none;"></td>' skip
            '         <td style="width:47px; border: none;"></td>' skip
            '         <td style="width:65px; border: none;"></td>' skip
            '         <td style="width:40px; border: none;"></td>' skip
            '         <td style="width:40px; border: none;"></td>' skip
            '         <td style="width:40px; border: none;"></td>' skip
            '         <td style="width:34px; border: none;"></td>' skip
            '         <td style="width:37px; border: none;"></td>' skip
            '         <td style="width:43px; border: none;"></td>' skip
            '         <td style="width:45px; border: none;"></td>' skip
            '         <td style="width:52px; border: none;"></td>' skip
            '         <td style="width: 55px; border: none;"></td>' skip
            '         <td style="width: 53px; border: none;"></td>' skip
            '         <td style="width: 50px; border: none;"></td>' skip
            '         <td style="width: 55px; border: none;"></td>' skip
            '         <td style="width: 50px; border: none;"></td>' skip
            '         <td style="width: 50px; border: none;"></td>' skip
            '         <td style="width: 46px; border: none;"></td>' skip
            '         <td style="width: 45px; border: none;"></td>' skip
            '         <td style="width: 50px; border: none;"></td>' skip
            '         <td style="width: 45px; border: none;"></td>' skip
            '         <td style="width: 50px; border: none;"></td>' skip
            '         <td style="width: 50px; border: none;"></td>' skip
            '         <td style="width: 50px; border: none;"></td>' skip
            '       </tr>' skip
            .
    end.
    do:
        put stream OutStr-html unformatted
            '     <tbody>' skip
            '       <tr style="height: 30px;">' skip
            '         <th   style="background-color:#ffffcc; font-size:9pt; text-align: center;">№</th>' skip
            '         <th   colspan="2"  style="background-color:#ffffcc; font-size:9pt; text-align: center;">Товарно материальные ценности</th>' skip
            '         <th colspan="2"  style="background-color:#ffffcc; font-size:9pt;text-align: center;">Единица </th>' skip
            '         <th  colspan="2" style="background-color:#ffffcc; font-size:9pt; text-align: center;">Номер</th>' skip
            '         <th  colspan="4"  style="background-color:#ffffcc;font-size:9pt; text-align: center;">Результат инвентаризации</th>' skip
            '         <th colspan="6" style="background-color:#ffffcc; font-size:9pt; text-align: center;">Отрегулировано за счет уточнения записей в учете</th>' skip
            '         <th  colspan="6" style="background-color:#ffffcc; font-size:9pt; text-align: center;">Пересортица</th>' skip
            '         <th  colspan="3" style="background-color:#ffffcc; font-size:9pt; text-align: center;">Приходуются</th>' skip
            '         <th  colspan="6" style="background-color:#ffffcc; font-size:9pt; text-align: center;">Окончательные недостачи</th>' skip
            '</tr >'   skip
            '<tr style="height: 125px;">' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;">наименование,характеристика(вид, сорт, группа)</th>' skip
            '         <th  style="background-color:#ffffcc; font-size:9pt; text-align: center;">код(номенклатурный номер)</th>' skip
            '         <th  style="background-color:#ffffcc; font-size:9pt; text-align: center;">код по ОКЕИ</th>' skip
            '         <th  style="background-color:#ffffcc; font-size:9pt; text-align: center;">наименование</th>' skip
            '         <th style="background-color:#ffffcc;  font-size:9pt; text-align: center;">инвентарный</th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt;  text-align: center;">паспорта (документа о регистрации)</th>' skip
            '         <th colspan = "2" style="background-color:#ffffcc; font-size:9pt;  text-align: center;">излишек</th>' skip
            '         <th colspan = "2" style="background-color:#ffffcc; font-size:9pt; text-align: center;">недостача</th>' skip
            '         <th colspan = "3" style="background-color:#ffffcc; font-size:9pt; text-align: center;">излишек</th>' skip
            '         <th colspan = "3" style="background-color:#ffffcc; font-size:9pt; text-align: center;">недостача</th>' skip
            '         <th colspan = "3" style="background-color:#ffffcc; font-size:9pt; text-align: center;">излишки, зачтенные в покрытие недостач</th>' skip
            '         <th colspan = "3" style="background-color:#ffffcc;  font-size:9pt; text-align: center;">недостачи, покрытые излишками</th>' skip
            '         <th colspan = "3" style="background-color:#ffffcc; font-size:9pt; text-align: center;"></th>' skip
            '         <th colspan = "2" style="background-color:#ffffcc; font-size:9pt; text-align: center;"></th>' skip
            '         <th colspan = "2" style="background-color:#ffffcc; font-size:9pt; text-align: center;"></th>' skip
            '         <th colspan = "2" style="background-color:#ffffcc; font-size:9pt; text-align: center;"></th>' skip
            '</tr>'skip
            '<tr style="height: 112px;">' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"></th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"></th>' skip
            '         <th style="background-color:#ffffcc;  font-size:9pt;text-align: center;"></th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"></th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"></th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"></th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> количество</th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> сумма,руб. коп. </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> количество </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> сумма,руб. коп. </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> количество </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> сумма,руб. коп. </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> номер счета,статьи,заказа </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> количество </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> сумма,руб. коп. </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> номер счета,статьи,заказа </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> количество </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> сумма,руб. коп. </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> порядковый номер зачтенных излишков </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> количество </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> сумма,руб. коп. </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> порядковый номер зачтенных излишков </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> количество </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> сумма,руб. коп. </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> номер счета </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> количество </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> сумма,руб.коп. </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> количество </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> сумма,руб.коп. </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> количество </th>' skip
            '         <th style="background-color:#ffffcc; font-size:9pt; text-align: center;"> сумма,руб.коп. </th>' skip
            '</tr>'skip
            '       <tr>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">1</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">2</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">3</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">4</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">5</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">6</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">7</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">8</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">9</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">10</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">11</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">12</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">13</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">14</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">15</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">16</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">17</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">18</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">19</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">20</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">21</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">22</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">23</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">24</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">25</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">26</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">27</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">28</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">29</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">30</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">31</th>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt; text-align: center">32</th>' skip
            '       </tr>' skip.
        output stream OutStr-html close.
    end.
    do:
        output stream OutStr-html to value(p-file-name-rep-htm) append convert target 'UTF-8'.
        find first buf_temp-doc-html no-lock no-error.
        if not error-status:error and available buf_temp-doc-html then
        do:
            for each buf_temp-doc-html where buf_temp-doc-html.gds-code > 0 no-lock
                by buf_temp-doc-html.obj-type by buf_temp-doc-html.obj-code
                :
                put stream OutStr-html unformatted
                    '       <tr level="1">' skip
                    '         <td  style="display: yes; font-size:9pt; text-align: left">' + if p-number <> ? then fnc-convert-dot-to-colon( p-number, "->>>>>>>9")   + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  left">'  + buf_temp-doc-html.gds-name +  '</td>'  skip
                    '         <td style="display: yes; font-size:9pt; text-align:  left">'   + if buf_temp-doc-html.gds-code <> ? then fnc-convert-dot-to-colon( buf_temp-doc-html.gds-code, "->>>>>>>9")   + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  left">'   + if buf_temp-doc-html.OKEI <> ? then fnc-convert-dot-to-colon( buf_temp-doc-html.okei, "->>>>>>>9")  + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  left">'    +  buf_temp-doc-html.unit-name + '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  left">'  '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">'    + if buf_temp-doc-html.izl-qnty <> ? then fnc-convert-dot-to-colon( buf_temp-doc-html.izl-qnty, "->>>>>>>9.99")  + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">'   + if buf_temp-doc-html.izl-sum <> ? then fnc-convert-dot-to-colon( buf_temp-doc-html.izl-sum, "->>>>>>>9.99")  + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">'   + if buf_temp-doc-html.ned-qnty <> ? then fnc-convert-dot-to-colon( buf_temp-doc-html.ned-qnty, "->>>>>>>9.99")  + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">'  + if buf_temp-doc-html.ned-sum <> ? then fnc-convert-dot-to-colon( buf_temp-doc-html.ned-sum, "->>>>>>>9.99")  + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">'  '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">'  '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">'  '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">'  '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">'  '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
                    '         <td style="display: yes; font-size:9pt; text-align:  right">' '</td>' skip
                    '       </tr>' skip
                    .
                p-number = p-number + 1.
            end.
        end.
    end.
    do:
        put stream OutStr-html unformatted
            ' <body>' skip
            '     <thead>' skip
            '<tr>' skip
            '<TD style="text-align:  left; font-size:9pt;border: none"></TD>'skip
            '<TD style="text-align:  left; font-size:9pt; border: none"> Итого:</TD>'skip
            '<TD style="text-align:  left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align:  left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align:  left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align:  left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align:  left; font-size:9pt; border: none"></TD>'skip
            '         <td style=" text-align: right; font-size:9pt; border: 1px solid black;"> '+ if v-izl-qnty <> ? then fnc-convert-dot-to-colon( v-izl-qnty, "->>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
            '         <td style=" text-align: right; font-size:9pt; border: 1px solid black;">'+ if v-izl-sum <> ? then fnc-convert-dot-to-colon( v-izl-sum, "->>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
            '         <td style=" text-align: right; font-size:9pt; border: 1px solid black;">'+ if v-ned-qnty <> ? then fnc-convert-dot-to-colon( v-ned-qnty, "->>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
            '         <td style=" text-align: right; font-size:9pt; border: 1px solid black;">'+ if v-ned-sum <> ? then fnc-convert-dot-to-colon( v-ned-sum, "->>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '<TD style="text-align: left; font-size:9pt; border: none"></TD>'skip
            '       </tr>' skip
            '<tr>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '       </tr>' skip
            '<tr>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td colpan = "3" style="border: none;  font-size:9pt; text-align: right;"> Бухгалтер:  </td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <TD STYLE="border: none; border-bottom: 1px solid black;  font-size:9pt; text-align: left;"></TD>'skip
            '         <TD STYLE="border: none; border-bottom: 1px solid black; font-size:9pt;  text-align: left;"></TD>'skip
            '         <TD STYLE="border: none; border-bottom: 1px solid black; font-size:9pt;  text-align: left;"></TD>'skip
            '         <TD STYLE="border: none; border-bottom: 1px solid black; font-size:9pt;  text-align: left;"></TD>'skip
            '         <td colspan = "2" style="border: none; font-size:9pt;  text-align: center;"> </td>' skip
            '         <td style="border: none; font-size:9pt;  text-align: center;"></td>' skip
            '         <td style="border: none; font-size:9pt;  text-align: center;"></td>' skip
            '         <td colspan = "5" style="border: none; font-size:9pt;  text-align: left;">Материально ответственное(ые) лицо(а)</td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '       </tr>' skip
            '<tr>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '       </tr>' skip
            '<tr>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '         <td style="border: none;  font-size:9pt; text-align: center;"></td>' skip
            '       </tr>' skip.
    end.
    do:
        put stream OutStr-html unformatted
            '  </body>'
            '</thead>'skip.
    end.
    do:
        put stream OutStr-html unformatted
            '     <tbody>' skip
            '       <tr>' skip
            '         <th    style="background-color:#ffffcc;  font-size:9pt; text-align: center;">№</th>' skip
            '         <th    colspan = "2" rowspan = "3" style="background-color:#ffffcc;  font-size:9pt; text-align: center;">Группа</th>' skip
            '         <th    colspan = "8"  style="background-color:#ffffcc;  font-size:9pt; text-align: center;">Результаты инвентаризации</th>' skip
            '       </tr>' skip
            '       <tr>' skip
            '         <th      style="background-color:#ffffcc;  font-size:9pt; text-align: center;"></th>' skip
            '         <th     colspan = "5" style="background-color:#ffffcc; font-size:9pt;  text-align: center;">излишек</th>' skip
            '         <th     colspan = "3" style="background-color:#ffffcc; font-size:9pt;  text-align: center;">недостача</th>' skip
            '       </tr>' skip
            '       <tr>' skip
            '         <th     style="background-color:#ffffcc; font-size:9pt;  text-align: center;"></th>' skip
            '         <th    colspan = "2" style="background-color:#ffffcc;  font-size:9pt; text-align: center;">количество</th>' skip
            '         <th   colspan = "3"  style="background-color:#ffffcc;  font-size:9pt; text-align: center;">сумма,руб. коп.</th>' skip
            '         <th     style="background-color:#ffffcc;  font-size:9pt; text-align: center;">количество</th>' skip
            '         <th   colspan = "2"  style="background-color:#ffffcc;  font-size:9pt; text-align: center;">сумма,руб. коп.</th>' skip
            '       </tr>' skip
            '       <tr>' skip
            '         <th num="" style="background-color:#ffffcc; font-size:9pt;  text-align: center">1</th>' skip
            '         <th colspan = "2"num="" style="background-color:#ffffcc; font-size:9pt;  text-align: center">2</th>' skip
            '         <th colspan = "2" num="" style="background-color:#ffffcc;  font-size:9pt; text-align: center">3</th>' skip
            '         <th  colspan = "3" num="" style="background-color:#ffffcc;  font-size:9pt; text-align: center">4</th>' skip
            '         <th num="" style="background-color:#ffffcc;  font-size:9pt; text-align: center">5</th>' skip
            '         <th colspan = "2"  num="" style="background-color:#ffffcc;  font-size:9pt; text-align: center">6</th>' skip
            '       </tr>' skip
            .
    end.
    do:
        find first buf_temp-doc-html no-lock no-error.
        if not error-status:error and available buf_temp-doc-html then
        do:
            for each buf_temp-doc-html  where buf_temp-doc-html.lvl-num = 2 no-lock
                break by  buf_temp-doc-html.grp-code
                :
                if last-of(buf_temp-doc-html.grp-code) then
                do:
                    put stream OutStr-html unformatted
                        '       <tr level="1">' skip
                        '         <td  style="display: yes;  font-size:9pt; text-align: left">' + if v-number <> ? then fnc-convert-dot-to-colon( v-number, "->>>>>>>9")   + '</td>' else "?" + '</td>' skip
                        '         <td colspan = "2" style="display: yes;  font-size:9pt; text-align:  right">'  + buf_temp-doc-html.gds-name +  '</td>'  skip
                        '         <td colspan = "2" style="display: yes; font-size:9pt;  text-align:  right">'    + if buf_temp-doc-html.izl-qnty <> ? then fnc-convert-dot-to-colon( buf_temp-doc-html.izl-qnty, "->>>>>>>9.99")  + '</td>' else "?" + '</td>' skip
                        '         <td  colspan = "3" style="display: yes; font-size:9pt;  text-align:  right">'   + if buf_temp-doc-html.izl-sum <> ? then fnc-convert-dot-to-colon( buf_temp-doc-html.izl-sum, "->>>>>>>9.99")  + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; font-size:9pt;  text-align:  right">'   + if buf_temp-doc-html.ned-qnty <> ? then fnc-convert-dot-to-colon( buf_temp-doc-html.ned-qnty, "->>>>>>>9.99")  + '</td>' else "?" + '</td>' skip
                        '         <td colspan = "2" style="display: yes; font-size:9pt;  text-align:  right">'  + if buf_temp-doc-html.ned-sum <> ? then fnc-convert-dot-to-colon( buf_temp-doc-html.ned-sum, "->>>>>>>9.99")  + '</td>' else "?" + '</td>' skip
                        '       </tr>' skip
                        .
                    v-number = v-number + 1.
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
procedure create-file:
    define input parameter p-file-name as character no-undo.
    output to value(string(p-file-name)).
    output close.
end procedure.
procedure define-full-path-Report:
    define input parameter p-rep-num as integer no-undo.
    define output parameter p-file-name-rep-htm as character no-undo.
    p-file-name-rep-htm = session:temp-directory + "rpt" + string(p-rep-num) + ".html".
end procedure.
procedure Report-Viewer:
    define input parameter p-full-path-RepView as character no-undo.
    define input parameter p-file-name-rep-htm as character no-undo.
    os-command no-wait value(p-full-path-RepView + " true " + search(p-file-name-rep-htm)).
end procedure.
function fnc-DD-MM-YYYY returns character
    (input p-dat-date as date):
    define variable result     as character no-undo.
    define variable p-str-date as character no-undo.
    p-str-date = replace(string(p-dat-date,'99.99.9999'), "/", ".").
    return p-str-date.
end function.
function fnc-convert-dot-to-colon returns character
    (input p-data as decimal, input p-accur as character):
    define variable result       as character no-undo.
    define variable v-str-result as character no-undo.
    p-data = round(p-data, 2).
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).
    return v-str-result.
end function.
