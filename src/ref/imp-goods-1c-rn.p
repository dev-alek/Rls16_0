
/*------------------------------------------------------------------------
    File        : imp-goods-1C-RN.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Thu Oct 26 18:13:10 AST 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.gbl.*.
block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Загрузка товара из ERP 1C RN".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
{ trg/new-bcod.i }
{ ref/send-ref.i }
&glob cmd-proc-handle p-cmd-proc-handle
&glob cmd-code p-cmd-code
{ nws/temp-cmd.i "SHARED" }
{ rul/cl-hist.i "shared" }
{ rul/library-cls.i "non-class-part" }
{ gbl/key-rec.i }
{ rul/tempcxml.i "shared" }
{ gbl/gate-clb.i }
{ ref/grplib.i }
{ bge/tmpcxmlh.i }
{ str/xmllib.i }
{ gbl/xmlchar.i }
{ gbl/tmpreldf.i }
{ gbl/tmpreld2.i }
{ ref/extclass.i }
{ str/tt-tax.i "new SHARED" tt-tax full }
{ gbl/orapreps.i }
{ cmp/t-tnved.i "new"  }
{ nws/db-rec.i }
{ gbl/getcntxa.i }
{ ref/gds-attr.i}
{ ref/gdsoattr.i }
{ gbl/objsrv.i } 
{ cmp/ini-lib.i }
{ cmp/gds-list.i gds-list def "new shared" }
define input parameter p-GdsObj         as class goods .

  
define buffer buf_goods for ub.goods.
define buffer buf_goods-attr for ub.goods-attr .
      
define buffer buf_units for ub.units.
define buffer buf_units-cli for ub.units.
define buffer buf_gds-prt for ub.gds-prt .
define buffer first_gds-grp for ub.gds-grp.

define buffer base-bar-code for ub.bar-code.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_tax-rate-attr for ub.tax-rate-attr .

define buffer buf_gds-season for ub.gds-season .
define buffer buf_blob-bind for ub.blob-bind .

define variable v-barcode as class goods_barcode .
define variable v-barcodes as class subjects .
define variable v-addunits as class subjects .
define variable v-addunit as class ibs.th.bge.1crn.subjects.unit-add-code .

define variable parparentproc     as widget-handle no-undo .
define variable v-stts            as integer      no-undo .
define variable v-rid             as recid        no-undo .
define variable v-bc-rid          as recid        no-undo .
define variable v-rid-pbc         as recid        no-undo .
define variable v-gds-code        as integer      no-undo .
define variable v-gds-mode        as character    no-undo .
define variable v-node-code       as integer      no-undo .
define variable v-nbc             as integer      no-undo .
define variable v-attr-del        as logical      no-undo .
define variable v-ok              as logical      no-undo .
define variable v-err-mess        as character    no-undo .
define variable v-nds-rate-code   as integer      no-undo .
define variable v-b-str as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-taxvalue as decimal no-undo .
define variable v-bc-mode as character no-undo .
define variable ii as integer no-undo .

define variable par-recid-fbr as recid no-undo .
define buffer buf-clients for clients.

define variable v-fuel-type     as character no-undo .
define variable v-oil-grp       as character no-undo .
define variable v-srvc-type     as character no-undo .
define variable v-mark-type     as character no-undo .
define variable v-neu-l         as decimal   no-undo .
define variable v-neu-z         as decimal   no-undo .
define variable v-neu-storage-l as decimal   no-undo .
define variable v-neu-storage-z as decimal   no-undo .
define variable v-unit-spl-code as character no-undo .
define variable v-is-petrl      as logical   no-undo .
define variable v-barcode-list  as longchar  no-undo .

define variable keyrecObj as class keyrec no-undo.
define variable keyrec as character no-undo.
define variable v-dir-name as character no-undo .
define variable v-dir1-name as character no-undo .
define variable v-file-name as character no-undo .

define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .

define variable v-part-num as integer   no-undo .
define variable v-blob-db-num as integer   no-undo .
define variable v-int64-id as int64 no-undo .

define variable mem1    as memptr no-undo .
define variable v-size  as integer no-undo .

define variable v-cntxt-db-num        as integer   no-undo . /* текущая БД            */
define variable v-cntxt-userid        as character no-undo . /* текущий пользователь  */
define variable v-cntxt-level         as character no-undo . /* уровень контекста     */
define variable v-cntxt-host-code-obj as integer   no-undo . /* текущая фирма         */
define variable v-cntxt-obj-type      as character no-undo . /* тип текущего объекта  */
define variable v-cntxt-obj-code      as integer   no-undo . /* код текущего объекта  */
define variable v-cntxt-db-num-obj    as integer   no-undo . /* база текущего объекта */
define variable v-cntxt-is-admin      as logical   no-undo . /* база текущего объекта */
define variable MarkType as ibs.th.str.marking.Types no-undo.
MarkType = ObjSrv:Env:Marking:Types. 
 
define variable mImp2CdH as handle no-undo.
run str/imp2cdgeth.p(output mImp2CdH).
define variable s-gds-code as integer no-undo init 0 .
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

  parparentproc = this-procedure:handle .
  
  
  v-unit-spl-code = p-GdsObj:unit-spl-code no-error.
  if v-unit-spl-code = ? or v-unit-spl-code = "" then v-unit-spl-code = p-GdsObj:unit-code .
  
  find first ub.clients no-lock where ub.clients.db-num   = ibs.th.gbl.gbl-var:g#db-num
                                  and ub.clients.obj-type = {&shop}
                                  and ub.clients.stts = 0  no-error.
  if not available ub.clients
  then do:
      undo, return error substitute("Не найден ни один активный магазин для бд &1", ibs.th.gbl.gbl-var:g#db-num ) .
  end.                               
  
  for first buf_gds-prt field (node-code) no-lock
      where buf_gds-prt.root = true
        and buf_gds-prt.node-name = {&empty-scale} :
      assign
        v-node-code = buf_gds-prt.node-code
        v-ok = yes
      .
  end.
  if not v-ok
  then do:
      undo, return error substitute("&1 не найдена", {&empty-scale} ) .
  end.
  
  v-gds-code = integer(p-GdsObj:code_) .
  find first buf_goods no-lock where buf_goods.gds-code = v-gds-code no-error.
  if not available buf_goods
  then do :
    find first ub.prod-bc no-lock where ub.prod-bc.b-str = string(v-gds-code) no-error .
    if available (ub.prod-bc) then do:

      find first ub.goods no-lock where ub.goods.gds-code = ub.prod-bc.b-code no-error .
      v-err-mess = substitute(
        "Уже есть товар &1 &2 с доп. кодом &3 - товар &3 &4 не будет добавлен в систему &5"
        , ub.goods.gds-code
        , ub.goods.gds-name
        , v-gds-code
        , p-GdsObj:name_
        , {&new-line}
      ) .
       undo, return error v-err-mess .     
    end.
      assign
        v-gds-mode = {&add-def}
        v-rid = ?
      .
  end.
  else do :
      assign
        v-gds-mode = {&update}
        v-rid = recid(buf_goods)
      .
  end.
  
  find first buf_units no-lock where buf_units.unit-name = p-GdsObj:unit-code no-error.
  if not available buf_units
  then do :
      undo, return error ("Нет единицы измерения " + p-GdsObj:unit-code) .
  end.
  assign v-is-petrl = ( if lookup( {&petrolium}, buf_units.type ) > 0 then yes else no ).
  if lookup( {&pieces}, buf_units.type ) = 0 then do:
      if v-is-petrl = yes and lookup( {&divisional}, buf_units.type ) = 0 then do:
        undo, return error substitute( 'Неверная связка типов единиц измерения для топлива: "&1" .',
                                       buf_units.type ).
      end.
  end.
  if p-GdsObj:gds-type = "н" and not v-is-petrl
  then do :
      undo, return error ("Тип товара в файле - нефтепродукт, но указана нетопливная единица измерения. Товар с кодом " + p-GdsObj:code_) .
  end.
/*  find first buf_units-cli no-lock where buf_units-cli.OKEI = integer(p-GdsObj:unit-spl-code) no-error.*/
/*  if not available buf_units-cli                                                                       */
/*  then do :                                                                                            */
/*      undo, return error ("Нет единицы измерения с кодом ОКЕИ " + string(p-GdsObj:unit-spl-code)) .    */
/*  end.                                                                                                 */
v-nds-rate-code = ? .
if p-GdsObj:nds-code = -1 then 
do:
  for each buf_tax-rate-attr no-lock where buf_tax-rate-attr.tax-code = integer({&vat-tax-code})
    and buf_tax-rate-attr.attr-code = "envd": 
    find last ub.tax-rate-value no-lock where ub.tax-rate-value.rate-code = buf_tax-rate-attr.rate-code
      and ub.tax-rate-value.tax-code = integer({&vat-tax-code})
      and ub.tax-rate-value.status_ <> {&deleted-status} 
      use-index i-status no-error .                                    
    if available ub.tax-rate-value and v-nds-rate-code = ? then v-nds-rate-code = ub.tax-rate-value.rate-code .   
  end.     
end.  
else 
do:
  for each ub.tax-rate-value no-lock where ub.tax-rate-value.rate-value = p-GdsObj:nds-code
    and ub.tax-rate-value.tax-code = integer({&vat-tax-code})
    and ub.tax-rate-value.status_ <> {&deleted-status}
    use-index i-status by ub.tax-rate-value.corr-date desc:                
    if available ub.tax-rate-value then 
    do:
      if p-GdsObj:nds-code <> 0 and v-nds-rate-code = ? then 
      do:
        v-nds-rate-code = ub.tax-rate-value.rate-code .
      end.
      else do:
        find first buf_tax-rate-attr no-lock where buf_tax-rate-attr.tax-code = integer({&vat-tax-code})
        and buf_tax-rate-attr.attr-code = "envd" and buf_tax-rate-attr.rate-code = ub.tax-rate-value.rate-code no-error .
        if not available (buf_tax-rate-attr) and v-nds-rate-code = ? then v-nds-rate-code = ub.tax-rate-value.rate-code . 
      end.  
    end.
  end.
end.  
    for each tt-tax:
      delete tt-tax.
    end.
    run ref/dtaxgdss.p (
          input yes /*p-silent*/
        , input /*par-unit-base*/  p-GdsObj:unit-code
        , input /*par-node-code*/  v-node-code
        , input (if v-gds-mode = {&add-def} THEN ? ELSE v-rid)
        , input (if v-gds-mode = {&add-def} THEN ? ELSE v-rid)
        , input /*par-host-code*/  0
        , input /*par-obj-type*/   ''
        , input /*par-obj-code*/  0
          ) no-error.
    if error-status:error then do:
      v-err-mess = substitute("Ошибки при определении налогов на товар:&1&2&1&3"
                               , {&new-line}
                               , error-status:get-message(1)
                               , return-value ).
      undo, return error v-err-mess .
    end.
    find first tt-tax where
              tt-tax.tax-code = integer({&vat-tax-code}).

    run cur-time in this-procedure(output v-today, output v-time).
    { gbl/pftaxval.i ? tt-tax.tax-code tt-tax.rate-code v-today 0 '' 0 v-taxvalue no-error }
    if error-status:error or v-taxvalue = ? then do:
      v-err-mess = substitute("Ошибка при поиске НДС (код ставкм &5) на текущую дату для товара &1&2&3&2&4"
                                , p-GdsObj:code_
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value
                                , tt-tax.rate-code
                                ).
      undo, return error v-err-mess .
    end.
    if not v-gds-mode = {&add-def} then do:
      tt-tax.fact-date = v-today.
    end.
    assign
    tt-tax.rate-code = v-nds-rate-code
    .
    /* Проверим не изменился ли производитель. Если изменился, запустим утилититу переименования производителя. */
    if    v-gds-mode = {&update} 
      and (   p-GdsObj:prod-code ne buf_goods.prod-code 
           or p-GdsObj:artic     ne buf_goods.artic ) 
    then do:
        run utl\ren-art.p(buf_goods.gds-code,
            buf_goods.artic,
            buf_goods.prod-type,
            buf_goods.prod-code,
            p-GdsObj:artic,
            buf_goods.prod-type,
            p-GdsObj:prod-code
        ) no-error.
        if error-status:error then do:
            v-err-mess = substitute("Ошибка при смене производителя у товара  &1. &2&4 &3&2"
                                , p-GdsObj:code_
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value                                
                                ).
      undo, return error v-err-mess .
        end.     
    end.    
  run ref/goods01.p (
                    input parparentproc
                    , input v-gds-mode
                  , input no /*par-copymode */
                  , input 0 /*par-alt-bc-mode as integer нужно ли вводить ДОП БК вместе с товаром*/
                  , input no /*par-manual as logical мз карточки товара - yes*/
                  , input yes /*par-silence as logical  ругаемся вслух или ?*/
                  , input yes /* import */
                  , input no /*par-file as logical идет импоррт из файла - из карточки товара*/
                  , input no /*par-single-record as logical надо сохранить только одну запись - потом выход в справ*/
                  , input ub.clients.host-code /*par-host-code like ub.sysconf.host-code */
                  , input ub.clients.obj-type /*par-obj-type like ub.clients.obj-type */
                  , input ub.clients.obj-code /*par-obj-code like ub.clients.obj-code */
                  , input (if p-GdsObj:gds-type = {&gds-goods} or p-GdsObj:gds-type = "н":U or p-GdsObj:gds-type = "б":U or p-GdsObj:gds-type = "р":U  then  yes else no)
                  , input ? /*par-copy-rec as recid recid записи с которой копируем*/
                  , input v-gds-code
                  , input p-GdsObj:artic
                  , input "орг":U
                  , input p-GdsObj:prod-code
                  , input v-node-code
                  , input integer(p-GdsObj:grp-code)
                  , input p-GdsObj:name_
                  , input "":U /*par-saved-name like ub.buf_goods.gds-name no-undo */
                  , input p-GdsObj:eng-name /*engl-name */
                  , input p-GdsObj:label-name
                  , input p-GdsObj:chk-name
                  , input "RU" /*buf_temp-goods_.alpha1*/
                  , input p-GdsObj:unit-code /*buf_units.unit-name*/
                  , input v-unit-spl-code /*buf_units-cli.unit-name*/
                  , input 0 /*p-max-rate*/
                  , input 0 /*p-min-rate*/
                  , input p-GdsObj:unit-k 
                  , input 1 /*buf_temp-goods_.qnty-cart*/
                  , input p-GdsObj:ms
                  , input p-GdsObj:wt
                  , input 0 /*buf_temp-goods_.ms-cart*/
                  , input 0 /*buf_temp-goods_.wt-cart*/
                  , input {&pr-calc-grp}
                  , input 0 /*increase-pc*/
                  , input p-GdsObj:enbl-ne
                  , input (if p-GdsObj:gds-type = "у" then 1 else 0) /*price-base*/
                  , input (if p-GdsObj:gds-type = "у" then 1 else 0) /*price-rubl*/
                  , input "" /*buf_temp-goods_.okdp*/
                  , input "" /*buf_temp-goods_.destin*/
                  , input "" /*buf_temp-goods_.attrib*/
                  , input "" /*buf_temp-goods_.user-rule*/
                  , input "" /*buf_temp-goods_.sert*/
                  , input "" /*buf_temp-goods_.struct*/
                  , input "" /*buf_temp-goods_.deadline*/
                  , input 0 /*cond-keep-code*/
                  , input "" /*buf_temp-goods_.sort*/
                  , input 0 /*proof*/
                  , input 0 /*normal-wastage*/
                  , input 0 /*normal-waste*/
                  , input '' /*tnved*/
                  , input "" /*buf_temp-goods_.nationality*/
                  , input v-unit-spl-code /*uniq-cst*/
                  , input p-GdsObj:unit-k /*cst-base-rate*/
                  , input ? /*fbr-grp-code*/
                  , input "" /*buf_temp-goods_.PS*/
                  , input no /*unq-artc*/
                  , input no /*is-jwlr*/
                  , input no /*is-bttl*/
                  , input yes /*is-ptrl*/
                  , input "no" /*custvalue*/
                  , input no
                  , input no
                  , input no /*par-ArtDis  */
                  , input 2 /*par-BarDis  */
                  , input-output v-rid
                  , output v-nbc
                ) no-error .
  if error-status :error then do:
      v-err-mess = substitute("Ошибка при сохранении goods &1&2&3&2&4"
                                , p-GdsObj:code_
                                , {&new-line}
                                , error-status:get-message(1)
                                , replace(return-value,{&delim-par}," ") ).
      undo, return error v-err-mess .
  end.
  find first ub.goods no-lock where ub.goods.gds-code = v-gds-code no-error.
  if available ub.goods then do:  
    run fill-gds-list in mImp2CdH ( buffer ub.goods).
  end.
  
  if v-nbc = 0 or v-nbc = ? then v-nbc = v-gds-code .
  if p-GdsObj:fuel-type eq ? or p-GdsObj:fuel-type =  0
  then v-fuel-type = ? .
  else do:
     v-fuel-type = entry(p-GdsObj:fuel-type,{&prop-list-attr-fuel-type}) no-error.
     if error-status :error then do:
     v-err-mess = substitute("Ошибка при сохранении goods &1&2 Неизвестный тип топлива &3"
                                , p-GdsObj:code_
                                , {&new-line}
                                ,p-GdsObj:fuel-type ).
      undo, return error v-err-mess .
  end.
  end.
  
  if v-fuel-type <> ?
  then do :
    RUN gds-attr-write (v-nbc, {&attr-fuel-type}, v-fuel-type).  
  end.
  else do :
    RUN gds-attr-delete (v-nbc, {&attr-fuel-type}, output v-attr-del).     
  end.
  if v-is-petrl then RUN gds-attr-write (v-nbc, {&attr-dflt-insalepr}, 'yes').
  
  case p-GdsObj:srvc-type :
    when 1 then v-srvc-type = {&attr-office-type_oss-pay}.
    when 2 then v-srvc-type = {&attr-office-type_card-act} .
    when 3 then v-srvc-type = {&attr-office-type_tso-ret} . 
    otherwise v-srvc-type = ? .
  end case.
  
  if v-srvc-type <> ?
  then do :
    RUN gds-attr-write (v-nbc, {&attr-office-type}, v-srvc-type).  
  end.
  else do :
    RUN gds-attr-delete (v-nbc, {&attr-office-type}, output v-attr-del).     
  end.
  v-mark-type = MarkType:GetNameProp(p-GdsObj:mark-type) no-error.
  
  if v-mark-type <> ?
  and v-mark-type <> "not-type"
  and v-mark-type <>  "Unknow"
  then do :
    RUN gds-attr-write (v-nbc, {&attr-mark-type}, v-mark-type).  
  end.
  else do :
    RUN gds-attr-delete (v-nbc, {&attr-mark-type}, output v-attr-del).     
  end.
  
  
  if p-GdsObj:emc-type <> ?
  then do :
    define variable mEMRC as character no-undo.
    define variable mOK as logical no-undo.
    define variable merror-code as character no-undo.
    mEMRC = trim(string(int64(p-GdsObj:emc-type),">>>>>>>>>>>>>>>>999")) no-error.
    if error-status:error
    then
       mEMRC = p-GdsObj:emc-type.
    run gds-attr_check-emrc-type(v-nbc,
                              {&attr-emrc-type},
                              mEMRC,
                              {&update},
                              output mOK,
                              output merror-code).
    if not mOK
    then
       undo, return error
                (merror-code + " Товар " + p-GdsObj:code_) .

    find first ub.goods-attr no-lock where ub.goods-attr.gds-code  = v-gds-code 
                             and ub.goods-attr.attr-code = "emrc-type"
                             and ub.goods-attr.attr-value = mEMRC no-error.
    if not available ub.goods-attr then s-gds-code = v-gds-code.

    RUN gds-attr-write (v-nbc, {&attr-emrc-type}, mEMRC).  

    find first ub.goods no-lock where ub.goods.gds-code = s-gds-code no-error.
	  if available ub.goods then do:  
	     run fill-g-list in mImp2CdH ( input ub.goods.gds-code, input ?, input ?).
          end.
  end.

  else do :
    RUN gds-attr-delete (v-nbc, {&attr-emrc-type}, output v-attr-del).     
  end.
 

  if p-GdsObj:IS18Plus = 1
  then do:
    RUN gds-attr-write (v-nbc, {&attr-IS18Plus}, p-GdsObj:IS18Plus).
  end.  
  if p-GdsObj:IS18Plus = 0 or p-GdsObj:IS18Plus = ? 
  then do:
     RUN gds-attr-delete (v-nbc, {&attr-IS18Plus}, output v-attr-del).
  end.  


  if p-GdsObj:loyalty-gift = 1
   then do:
     RUN gds-attr-write (v-nbc, {&attr-loyalty-gift}, p-GdsObj:loyalty-gift).
     run fill-g-list in mImp2CdH ( input v-nbc, input ?, input ?).
  end.  

  if p-GdsObj:loyalty-gift = 0 or p-GdsObj:loyalty-gift = ? 
   then do:
    RUN gds-attr-delete (v-nbc, {&attr-loyalty-gift}, output v-attr-del).
    run fill-g-list in mImp2CdH ( input v-nbc, input ?, input ?).
  end.  


 
  if p-GdsObj:oil-grp <> ?
  then do:
    RUN gds-attr-write (v-nbc, {&attr-group-np}, p-GdsObj:oil-grp).
  end.  
  else do:
    RUN gds-attr-delete (v-nbc, {&attr-group-np}, output v-attr-del).
  end.  
  
  /* Если блюдо поставим атрибуты на объекте, что это блюдо */

  if p-GdsObj:gds-type = "б":U then do:
       for each buf-clients no-lock where buf-clients.db-num = g#db-num
                                  and buf-clients.obj-type = {&shop}
                                  and buf-clients.stts = 0 :

           find first  fbr-gds-obj where fbr-gds-obj.gds-code =  v-nbc 
                                        and fbr-gds-obj.obj-type = buf-clients.obj-type 
                                        and fbr-gds-obj.obj-code = buf-clients.obj-code 
                                        no-lock no-error. 
           par-recid-fbr    =  if available fbr-gds-obj then recid(fbr-gds-obj) else ?.   

           run ref/fgdsobj1.p (
                            input-output par-recid-fbr
                        , input (if available fbr-gds-obj
                                    then {&update}
                                    else {&add-def})
                        , input no /*p-silent*/
                        , input v-nbc
                        , input buf-clients.obj-type 
                        , input buf-clients.obj-code
                        , input if available fbr-gds-obj then fbr-gds-obj.fbr-grp-code else 0
                        , input buf-clients.obj-type
                        , input buf-clients.obj-code
                        , input if available fbr-gds-obj then fbr-gds-obj.is-cd else no
                        , input true
                        , input if available fbr-gds-obj then fbr-gds-obj.is-modificator else no
                        , input if available fbr-gds-obj then fbr-gds-obj.is-null-price else no
                        , input if available fbr-gds-obj then fbr-gds-obj.is-season else no
                        , input if available fbr-gds-obj then fbr-gds-obj.is-semi-finished else no
                        ) no-error.
                                                    
       end.                                
  end.   
  
  


  /* ----- баркоды товара ----- */

  DEFINE TEMP-TABLE ttKF NO-UNDO
  FIELD bar_code  AS INTEGER
  FIELD unit_code AS CHARACTER
  FIELD coef      AS INTEGER.

  v-barcode-list = "" .
  v-barcodes = p-GdsObj:barcode .
  if valid-object (v-barcodes)
  then do :
      find base-bar-code no-lock where
           base-bar-code.b-code = v-nbc.
      find ub.goods no-lock where
           ub.goods.gds-code = base-bar-code.gds-code.
      find ub.gds-prt no-lock where
           ub.gds-prt.node-code = base-bar-code.node-code.

      ii_ :

      do ii = 1 to v-barcodes:iCounter:

        v-barcodes:Get(ii) .
        v-barcode = cast (v-barcodes:SubjectObjCurr, goods_barcode).


         find first buf_units no-lock where buf_units.unit-name = v-barcode:unit-code no-error.
         if not available buf_units
         then do :
         undo, return error ("Нет единицы измерения " + v-barcode:unit-code) .
         end.

         if lookup( {&petrolium}, buf_units.type ) > 0 and length(v-barcode:bcode) > 2 then do:
         undo, return error substitute( 'Для топливной ед. измерения невозможно создать баркод  &1 .', v-barcode:bcode ).
         end.


         if length (v-barcode:bcode) <= 2
         then do :
              next ii_ .
              /*  undo, return error
                ("Баркод должен быть длиннее 2  символов код " +
                 v-barcode:bcode + " . Товар " + p-GdsObj:code_) .*/
            end.  
        v-barcode-list = v-barcode-list + v-barcode:bcode + "," .
        v-bc-mode = "".

        find first ub.prod-bc exclusive-lock where ub.prod-bc.b-str = v-barcode:bcode no-error.

        if not available ub.prod-bc
        then do :
     
            v-bc-mode = {&add-def} .
        end.
        else do :
            find first ub.bar-code no-lock where ub.bar-code.b-code = ub.prod-bc.b-code no-error .
            if not available ub.bar-code
            then do :
                undo, return error
                ("Ошибка при определении баркода для собственного кода " +
                 v-barcode:bcode + " . Товар " + p-GdsObj:code_) .
            end.

            else do :               
               /* проверяем совпадение кода товара и ед.изм. */
              if ub.bar-code.gds-code = v-gds-code
              and ub.bar-code.unit-cli = v-barcode:unit-code
              then do :                 

              CREATE ttKF.
              ASSIGN 
              ttKF.bar_code   = ub.bar-code.b-code
              ttKF.unit_code  = v-barcode:unit-code
              ttKF.coef       = v-barcode:coeff
              . 

                  ub.prod-bc.bc-on = true .
                  ub.prod-bc.bc-on-type = (if p-GdsObj:gds-type = "н" then {&loc-pt-code} else if v-barcode:barcode-type = 1 then {&gtin} else "").
                  v-b-str = v-barcode:bcode .
                  def var vmaken as logical no-undo.
                  vmaken = if v-barcode:barcode-type = 2 then yes else no.

                  find first prod-bc-attr where prod-bc-attr.b-str     eq v-b-str
                                            and prod-bc-attr.b-code    eq bar-code.b-code
                                           and prod-bc-attr.attr-code eq {&mark}
                  no-lock no-error.
                 if not available prod-bc-attr
                 then do: 
                    create prod-bc-attr.
                    assign
                       prod-bc-attr.b-str  = v-b-str
                       prod-bc-attr.b-code = bar-code.b-code 
                       prod-bc-attr.attr-code = {&mark}
                       prod-bc-attr.attr-value = string(vmaken)
                    .
                 end.  /*  for each buf_prod-bc  */
                 else if prod-bc-attr.attr-value ne string(vmaken)
                 then do:
                    find current prod-bc-attr exclusive-lock no-error.
                    if available prod-bc-attr
                    then
                       prod-bc-attr.attr-value = string(vmaken).
                 end.
                  v-rid-pbc = recid(ub.prod-bc).
                  if    ub.prod-bc.bc-on
                    and send-ref
                  then do:
                     run fill-pbc-list in mImp2CdH
                     (v-rid-pbc,
                     bar-code.gds-code,
                     prod-bc.b-code,
                     prod-bc.b-str,
                     prod-bc.bc-on,
                     no).
                  end.
                  next ii_ .
              end. 
              else do :                 

/*                  undo, return error                                                      */
/*                  ("Уже есть собственный код " + v-barcode:bcode +                        */
/*                   " и он пренадлежит другому товару - " + string(ub.bar-code.gds-code)) .*/


                delete ub.prod-bc no-error .
                if error-status:error
                then do :
                  undo, return error
                  ("Ошибка при удалении собственного кода " +
                   v-barcode:bcode + " товара " + string(ub.bar-code.gds-code) + " для перепривязки его к товару " + p-GdsObj:code_) .
                end .
                v-bc-mode = {&add-def} .
              end.
            end.
            if v-bc-mode = "" then v-bc-mode = {&update} .
        end.       
        if ub.goods.unit-base <> v-barcode:unit-code and v-bc-mode = {&add-def}
        then do :
            find first ub.bar-code where ub.bar-code.gds-code = v-gds-code
                                     and ub.bar-code.unit-cli = v-barcode:unit-code 
                                     no-error.

            if not available ub.bar-code 
            then do :    
              CREATE ttKF.
              ASSIGN 
              ttKF.bar_code   = v-gds-code
              ttKF.unit_code  = v-barcode:unit-code
              ttKF.coef       = v-barcode:coeff
              . 
              run ref/barcode1.p (

                                     input v-bc-mode 
                                    ,input yes /*p-silent*/
                                    ,input ""
                                    ,input ub.goods.gds-code
                                    ,input ub.gds-prt.node-code
                                    ,input base-bar-code.part-code
                                    ,input base-bar-code.in-code
                                    ,input v-barcode:unit-code
                                    ,input v-barcode:coeff
                                    ,output v-bc-rid) no-error.
                if error-status :error
                then do :
                    v-err-mess = substitute("Ошибка при сохранении бар-кода &1&2&3&2&4"
                                        , v-barcode:bcode
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value ).
                    undo, return error v-err-mess .
                end.
                find first ub.bar-code where recid(ub.bar-code) = v-bc-rid.
                if send-ref
                then do:
                   run fill-bar-code in mImp2CdH (
                                                input   ub.bar-code.b-code
                                               ,input   ub.bar-code.gds-code
                                               ,input  (if  ub.bar-code.stts_ = integer({&hn-delete})
                                                        then yes
                                                        else no)
                                               ,input   ub.bar-code.node-code
                                               ,input   ub.bar-code.in-code
                                               ,input   ub.bar-code.part-code
                                               ,input   ub.bar-code.cli-base-rate
                                               ,input   ub.bar-code.unit-cli
                                                ) no-error.
      
                end.
            end.               
            else do:
              run ref/barcode1.p (
                 input {&update} 
                ,input yes /*p-silent*/
                ,input ""
                ,input ub.goods.gds-code
                ,input ub.gds-prt.node-code
                ,input base-bar-code.part-code
                ,input base-bar-code.in-code
                ,input v-barcode:unit-code
                ,input v-barcode:coeff
                ,output v-bc-rid
              ) no-error.
              if error-status :error
              then do :
                 v-err-mess = substitute("Ошибка при обновлении бар-кода &1&2&3&2&4"
                                        , v-barcode:bcode
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value ).
                 undo, return error v-err-mess .
              end.
            end.             
            v-b-str = v-barcode:bcode .
            run trg/prod-bc2.p (
                                 input  parparentproc
                                ,input yes /*p-silent*/
                                ,input ? /* dif-pdbc */
                                ,input ? /*pbc-veto*/
                                ,input send-ref
                                ,input (if p-GdsObj:gds-type = "н" then {&loc-pt-code} else if v-barcode:barcode-type = 1 then {&gtin} else "")
                                ,input ""
                                ,buffer ub.goods
                                ,input ub.bar-code.b-code
                                ,input (if v-barcode:barcode-type = 2 then yes else no)  
                                ,input-output v-b-str
                                ,output v-rid-pbc
                                ) no-error.
            if error-status :error
            or v-rid-pbc = ? then do:
              v-err-mess = substitute("Ошибка при сохранении бар-кода &1&2&3&2&4"
                                    , v-barcode:bcode
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).
                undo, return error v-err-mess .
            end.
            else do:
              find first buf_prod-bc no-lock
                    where recid(buf_prod-bc) = v-rid-pbc.
              if  buf_prod-bc.bc-on
              and send-ref
              then do:
                 run fill-pbc-list in mImp2CdH
                     (v-rid-pbc,
                     ub.bar-code.gds-code,
                     buf_prod-bc.b-code,
                     buf_prod-bc.b-str,
                     buf_prod-bc.bc-on,
                     no).
              end.
            end.
        end.        
        if ub.goods.unit-base = v-barcode:unit-code
        then do :
            v-b-str = v-barcode:bcode .
            run trg/prod-bc2.p (
                                 input  parparentproc
                                ,input yes /*p-silent*/
                                ,input ? /* dif-pdbc */
                                ,input ? /*pbc-veto*/
                                ,input send-ref
                                ,input (if p-GdsObj:gds-type = "н" then {&loc-pt-code} else if v-barcode:barcode-type = 1 then {&gtin} else "")
                                ,input ""
                                ,buffer ub.goods
                                ,input base-bar-code.b-code
                                ,input (if v-barcode:barcode-type = 2 then yes else no) 
                                ,input-output v-b-str
                                ,output v-rid-pbc
                                ) no-error.
            if error-status :error
            or v-rid-pbc = ? then do:
              v-err-mess = substitute("Ошибка при сохранении бар-кода &1&2&3&2&4"
                                    , v-barcode:bcode
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).
                undo, return error v-err-mess .
            end.
            else do:
              find first buf_prod-bc no-lock
                    where recid(buf_prod-bc) = v-rid-pbc.
              if  buf_prod-bc.bc-on
              and send-ref
              then do:
                    run fill-pbc-list in mImp2CdH
                     (v-rid-pbc,
                     ub.goods.gds-code,
                     buf_prod-bc.b-code,
                     buf_prod-bc.b-str,
                     buf_prod-bc.bc-on,
                     no).
            
              end.  
            end.
        end.
      end.
  end.

  for each buf_bar-code no-lock where buf_bar-code.gds-code = v-gds-code,
    each buf_prod-bc exclusive-lock where buf_prod-bc.b-code = buf_bar-code.b-code :
     if lookup( buf_prod-bc.b-str, v-barcode-list ) = 0
        and length (buf_prod-bc.b-str) > 2
     then do :
       buf_prod-bc.bc-on = false .  
                 run fill-pbc-list in mImp2CdH
                     (v-rid-pbc,
                     v-gds-code,
                     buf_prod-bc.b-code,
                     buf_prod-bc.b-str,
                     buf_prod-bc.bc-on,
                     no).
     end.
  end.

/* BTS-1372 
Для каждого собственного кода (ЕИ которого есть в пакете), проверить, что в пакете у всех 
записей (бар-кодов) с ЕИ, привязанной к этому собственному коду, указан одинаковый коэффициент.
Если да, то необходимо изменить коэффициент данного собственного кода на указанный в 
пакете (секция barcodes тег coeff). 
*/

   DEFINE VARIABLE current-coef AS INTEGER   NO-UNDO.
   DEFINE VARIABLE unit-list    AS CHARACTER NO-UNDO.
   DEFINE TEMP-TABLE ttToDel
   FIELD unit_code AS CHARACTER.
   FOR EACH ttKF NO-LOCK
       BREAK BY ttKF.unit_code:
       IF FIRST-OF(ttKF.unit_code) THEN DO:
           ASSIGN current-coef = ttKF.coef.
       END.
       IF ttKF.coef <> current-coef THEN DO:
            CREATE ttToDel.
            ttToDel.unit_code = ttKF.unit_code .
           LEAVE.
       END.
   END.
    unit-list = "" .
    FOR EACH ttToDel:
    FOR EACH ttKF WHERE ttToDel.unit_code = ttKF.unit_code:
        unit-list = unit-list + ttToDel.unit_code + " = " + string(ttKF.coef) + " " .
        DELETE ttKF.
    END.
    END.

/*    if unit-list <> "" then do: 
      v-err-mess = substitute("Ошибка изменения коэфф у ед.изм. &1", unit-list).
      undo, return error v-err-mess .     
      end. 
*/ 
    run str/imp2cdgeth.p(output mImp2CdH).
    FOR EACH ttKF:
    FIND FIRST ub.bar-code exclusive-lock WHERE ub.bar-code.b-code = ttKF.bar_code no-error.
        if available (ub.bar-code) then do:  
            find first ub.goods no-lock where ub.bar-code.gds-code = ub.goods.gds-code 
                 and ub.bar-code.unit-cli <> goods.unit-base no-error.
               if available ub.goods 
               then  do:  
                  ub.bar-code.cli-base-rate = ttKF.coef .
                  run fill-g-list in mImp2CdH  ( input ub.goods.gds-code, input ?, input ?).
               END. 
        END.
    END.

   EMPTY TEMP-TABLE ttKF.
   EMPTY TEMP-TABLE ttToDel.


  /* ----- end_of баркоды товара ----- */
  
  /* ----- дополнительные единицы измерения товара ----- */
  define variable v-i-counter as integer no-undo .
  define variable v-i-num     as integer no-undo .
  define variable v-stub      as integer no-undo .
  define variable v-add-unit-name as character no-undo .
  define variable v-add-unit-k    as decimal no-undo .
  define variable v-unitsubs  as class ibs.th.str.mercury.unitsubs no-undo .
  define variable v-unitsub   as class ibs.th.str.mercury.unitsub no-undo .
  define variable v-unitstore as class ibs.th.gbl.storage.unitmercstr no-undo .
  v-addunits = p-GdsObj:unit-add-codes .
  if valid-object (v-addunits) then do :
    // буфер с импортируемым товаром мог уйти с записи в цикле создания баркодов
    find first buf_goods no-lock where buf_goods.gds-code = v-gds-code no-error .
    if not available buf_goods then
      undo, throw new Progress.Lang.AppError( substitute(
        "Потеряна импортируемая запись с кодом товара [&1]", v-gds-code
      ) ) .
  
    v-unitsubs = new ibs.th.str.mercury.unitsubs () . 
    v-i-counter = v-addunits:iCounter .
    do v-i-num = 1 to v-i-counter :
      v-stub = v-addunits:Get(v-i-num) . // возвращает кол-во элементов и переключает currItem
      v-addunit = cast(v-addunits:SubjectObjCurr, ibs.th.bge.1crn.subjects.unit-add-code) .
      assign
        v-add-unit-name = v-addunit:unit-code
        v-add-unit-k    = v-addunit:unit-k
      .
      if not can-find (first buf_units where buf_units.unit-name = v-add-unit-name) then
      undo, throw new Progress.Lang.AppError( substitute(
        "Дополнительная единица измерения [&1] товара [&2] отсутствует в справочнике единиц измерения."
        , v-add-unit-name, v-gds-code
      ) ) .
      if buf_goods.unit-base = v-add-unit-name then
      undo, throw new Progress.Lang.AppError( substitute(
        "Дополнительная единица измерения [&1] товара [&2] совпадает с учётной единицей измерения товара."
        , v-add-unit-name, v-gds-code
      ) ) .

      v-unitsub = new ibs.th.str.mercury.unitsub () .
      v-unitsub:UnitName = v-add-unit-name .
      v-unitsub:UnitCoef = v-add-unit-k .
      v-unitsubs:AddItem(v-unitsub) .
    end . // end_of_p-GdsObj:unit-add-codes[]
    
    v-unitstore = new ibs.th.gbl.storage.unitmercstr () .
    v-unitstore:writeDB(v-unitsubs, v-gds-code) .
    // ?? доп.еи, которые не пришли в пакете - стереть? 
    // unitsStr:deleteDB(p-gds-code) . - сотрёт все
    
    if valid-object (v-unitstore) then delete object v-unitstore . 
    if valid-object (v-unitsubs) then delete object v-unitsubs .
  end . // end_of valid_addunits  
  /* ----- end_of дополнительные единицы измерения товара ----- */
  
  if p-GdsObj:enbl-zc = 1
  then do :
    RUN gds-attr-write (v-nbc, {&attr-null-price}, "yes").  
  end.
  else if p-GdsObj:enbl-zc = 0
  then do :
    RUN gds-attr-delete (v-nbc, {&attr-null-price}, output v-attr-del).     
  end.
  
  if p-GdsObj:calories <> ?
  and p-GdsObj:calories <> 0
  then do :
    RUN gds-attr-write (v-nbc, {&attr-calories}, string(p-GdsObj:calories)).  
  end.
  else do :
    RUN gds-attr-delete (v-nbc, {&attr-calories}, output v-attr-del).     
  end.

  if p-GdsObj:ISCookStumped <> ?
  and p-GdsObj:ISCookStumped <> 0
  then do :
    RUN gds-attr-write (v-nbc, {&attr-time-coock}, "yes").  
  end.
  else do :
    RUN gds-attr-delete (v-nbc, {&attr-time-coock}, output v-attr-del).     
  end.

  if p-GdsObj:CommodityCode <> ""
  and p-GdsObj:CommodityCode <> ?
  then do :
    RUN gds-attr-write (v-nbc, {&attr-gds-CommodityCode}, p-GdsObj:CommodityCode).  
  end.
  else do :
    RUN gds-attr-delete (v-nbc, {&attr-gds-CommodityCode}, output v-attr-del).     
  end.
  
  if p-GdsObj:code-AIS <> ""
  and p-GdsObj:code-AIS <> ?
  then do :
    RUN gds-attr-write (v-nbc, {&attr-gds-code-AIS}, p-GdsObj:code-AIS).  
  end.
  else do :
    RUN gds-attr-delete (v-nbc, {&attr-gds-code-AIS}, output v-attr-del).     
  end.
      
  if p-GdsObj:carbohydrates <> ?
  and p-GdsObj:carbohydrates <> 0
  then do :
    RUN gds-attr-write (v-nbc, {&attr-carbohydrate}, string(p-GdsObj:carbohydrates)).  
  end.
  else do :
    RUN gds-attr-delete (v-nbc, {&attr-carbohydrate}, output v-attr-del).     
  end.
  
  if p-GdsObj:fats <> ?
  and p-GdsObj:fats <> 0
  then do :
    RUN gds-attr-write (v-nbc, {&attr-fat}, string(p-GdsObj:fats)).  
  end.
  else do :
    RUN gds-attr-delete (v-nbc, {&attr-fat}, output v-attr-del).     
  end.
  
  if p-GdsObj:proteins <> ?
  and p-GdsObj:proteins <> 0
  then do :
    RUN gds-attr-write (v-nbc, {&attr-protein}, string(p-GdsObj:proteins)).  
  end.
  else do :
    RUN gds-attr-delete (v-nbc, {&attr-protein}, output v-attr-del).     
  end.
  
  if p-GdsObj:pay-trk = 1
  then do :
    RUN gds-attr-write (v-nbc, {&attr-ptrl-as-good}, "yes").  
  end.
  else if p-GdsObj:pay-trk = 0
  then do :
    RUN gds-attr-delete (v-nbc, {&attr-ptrl-as-good}, output v-attr-del).     
  end.
  
  if p-GdsObj:min-dnsty <> ? and p-GdsObj:min-dnsty <> 0
  and p-GdsObj:max-dnsty <> ? and p-GdsObj:max-dnsty <> 0
  then do :
    RUN gds-attr-write (v-nbc, {&attr-gds-ptrl-densities}, (string(p-GdsObj:min-dnsty) + "-" + string(p-GdsObj:max-dnsty))).  
  end.
  else do :
    RUN gds-attr-delete (v-nbc, {&attr-gds-ptrl-densities}, output v-attr-del).     
  end.
  
  if p-GdsObj:neu-l <> ?
  or p-GdsObj:neu-z <> ?
  or p-GdsObj:neu-storage-l <> ?
  or p-GdsObj:neu-storage-z <> ?
  then do :
    if p-GdsObj:neu-l = ? then v-neu-l = 0 . else v-neu-l = p-GdsObj:neu-l .
    if p-GdsObj:neu-z = ? then v-neu-z = 0 . else v-neu-z = p-GdsObj:neu-z .
    if p-GdsObj:neu-storage-l = ? then v-neu-storage-l = 0 . else v-neu-storage-l = p-GdsObj:neu-storage-l .
    if p-GdsObj:neu-storage-z = ? then v-neu-storage-z = 0 . else v-neu-storage-z = p-GdsObj:neu-storage-z .
    RUN gdsoattr-write (v-nbc,
                        {&shop},
                        ub.clients.obj-code,
                        {&attr-normal-wastage-o},
                        (string(v-neu-l, "->>>>9.999") + ";" + string(v-neu-z, "->>>>9.999") + ";" + string(v-neu-storage-l, "->>>>9.999") + ";" + string(v-neu-storage-z, "->>>>9.999"))
                        ).  
  end.
  else do :
    RUN gdsoattr-delete (v-nbc, {&shop}, ub.clients.obj-code, {&attr-normal-wastage-o}, output v-attr-del).     
  end.
  
  if p-GdsObj:vad-gds = 1
  then do :
    RUN gds-attr-write (v-nbc, {&attr-mercur_FGIS}, "yes").  
  end.
  else if p-GdsObj:vad-gds = 0
  then do :
    RUN gds-attr-delete (v-nbc, {&attr-mercur_FGIS}, output v-attr-del).     
  end.
  
  if p-GdsObj:production-use = 1
  then do :
    RUN gds-attr-write (v-nbc, {&attr-production-only}, "yes").  
    /* Товары с атрибутом "Только производство" удаляем с касс */
    if v-gds-mode = {&update} 
    and available buf_goods
    then do :
      { cmp/gds-list.i gds-list assign " " buf_goods}
      run str/del-gds.p (parparentproc,this-procedure,this-procedure,string(ub.clients.obj-code) + {&delim-par} + {&question-mark}).
    end .
  end.
  else if p-GdsObj:production-use = 0
  then do :
    RUN gds-attr-delete (v-nbc, {&attr-production-only}, output v-attr-del).     
  end.
  
  if p-GdsObj:pay-flag ne ?
  then do :
    RUN gds-attr-write (v-nbc, {&attr-item-matter-mark}, string(p-GdsObj:pay-flag)).  
  end.

  if p-GdsObj:method-flag ne ?
  then do :
    RUN gds-attr-write (v-nbc, {&attr-type-method-calc}, p-GdsObj:method-flag).  
  end.
  else do :
    RUN gds-attr-delete (v-nbc, {&attr-type-method-calc}, output v-attr-del).
  end.
  
  if p-GdsObj:enbl-exc = 1
  then do :
    RUN gds-attr-write (v-nbc, {&attr-ban-bonus}, "yes").  
  end.
  else if p-GdsObj:enbl-exc = 0
  then do :
    RUN gds-attr-delete (v-nbc, {&attr-ban-bonus}, output v-attr-del).     
  end.
  
  if p-GdsObj:weighed-product = 1
  then do :
    RUN gds-attr-write (v-nbc, {&attr-weighed-gds}, "yes").  
  end.
  else if p-GdsObj:weighed-product = 0
       or p-GdsObj:weighed-product = ?
  then do :
    RUN gds-attr-delete (v-nbc, {&attr-weighed-gds}, output v-attr-del).     
  end.
  
  /* Картинки */
  {ref/imagelist.i}
  if trim(p-GdsObj:img) > ''
  then do :
    find base-bar-code no-lock where
         base-bar-code.b-code = v-nbc.
    find ub.goods no-lock where
         ub.goods.gds-code = base-bar-code.gds-code.
           
    delete object v-tth no-error.
    run adm/shattri.p (
           input "get":U
          ,input ub.clients.obj-type
          ,input ub.clients.obj-code
          ,input {&attr-gds-ref_obj}
          ,input {&attr-gds-ref_obj_image-dir}
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-value-logical
          ,output v-param-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
    delete object v-tth no-error.
    if trim(v-value-character) > ""
    then do :
      v-dir1-name = trim(v-value-character, "\") .
      v-dir1-name = trim(v-dir1-name, "/") .
      v-dir1-name = v-dir1-name + "\" .
      v-dir-name = v-dir1-name + "gds\" .
    end.
    else do :
      v-dir1-name = "C:\TB-image\" .
      v-dir-name = "C:\TB-image\gds\" .
    end.
    
    file-info:file-name = v-dir1-name .
    if file-info:full-pathname = ?
    then do :
      os-create-dir value(right-trim(v-dir1-name, "\")) .
      if os-error <> 0 then do:
        v-err-mess = substitute("Невозможно создать директорию &1 для изображений &2&3&2&4"
                                    , v-dir1-name
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).
        undo, return error v-err-mess .
      end.
    end.
    
    file-info:file-name = v-dir-name .
    if file-info:full-pathname = ?
    then do :
      os-create-dir value(right-trim(v-dir-name, "\")) .
      if os-error <> 0 then do:
        v-err-mess = substitute("Невозможно создать директорию &1 для изображений &2&3&2&4"
                                    , v-dir-name
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).
        undo, return error v-err-mess .
      end.
    end.
    
    v-file-name = v-dir-name + string(ub.goods.gds-code) + ".png" .
    
    v-size = length(p-GdsObj:img) .
    set-size(mem1) = integer(8 / 6 * v-size) + 1.
    mem1 = BASE64-DECODE(p-GdsObj:img).
    
    copy-lob from mem1 to file v-file-name no-convert no-error .
    if error-status:error
    then do :
      os-delete value(v-file-name) .
      if os-error <> 0
      then do :
        v-err-mess = substitute("Не могу обновить изображение &1&2&3&2&4"
                                    , v-file-name
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).
        undo, return error v-err-mess .
      end.
      copy-lob from mem1 to file v-file-name no-convert no-error .
      if error-status:error
      then do :
        v-err-mess = substitute("Не могу сохранить изображение &1&2&3&2&4"
                                    , v-file-name
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).
        undo, return error v-err-mess .
      end.
    end .
    
    keyrecObj = new keyrec ().
    keyrecObj:GenKeyRec({&table_goods}, buffer ub.goods:handle, output keyrec).
    delete object keyrecObj.
    
    find first buf_blob-bind exclusive-lock where buf_blob-bind.uniq-key-rec = keyrec
                                              and buf_blob-bind.field-name_  = {&blob-gds-collec-image}
                                              no-error .
    if available buf_blob-bind
    then do :
      v-blob-db-num = buf_blob-bind.db-num .
      v-int64-id = buf_blob-bind.int64-id .
      v-part-num = buf_blob-bind.part-num .

      run gbl/file2blb.p ( input {&update}
                          ,input  "override"
                          ,input (buffer ub.goods:handle)
                          ,input keyrec
                          ,input {&blob-gds-collec-image} /*p-field-*/
                          ,input {&blob-gds-collec-image}
                          ,input-output v-part-num
                          ,input {&lob-res-data} /*p-resource-type*/
                          ,input-output v-blob-db-num
                          ,input-output v-int64-id
                          ,input v-file-name
                          ) no-error .
      if error-status :error then do:
        v-err-mess = substitute("Не могу обновить изображение &1 в базе &2&3&2&4"
                                    , v-file-name
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).
        undo, return error v-err-mess .
      end.
    end.
    else do :
      v-blob-db-num = ? .
      v-int64-id = 0 .

      run gbl/file2blb.p ( input {&add-def}
                          ,input  "yes"
                          ,input (buffer ub.goods:handle)
                          ,input keyrec
                          ,input {&blob-gds-collec-image} /*p-field-*/
                          ,input {&blob-gds-collec-image}
                          ,input-output v-part-num
                          ,input {&lob-res-data} /*p-resource-type*/
                          ,input-output v-blob-db-num
                          ,input-output v-int64-id
                          ,input v-file-name
                          ) no-error .
      if error-status :error then do:
        v-err-mess = substitute("Не могу сохранить изображение &1 в базу &2&3&2&4"
                                    , v-file-name
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).
        undo, return error v-err-mess .
      end.
    end.
    
    v-blob-db-num = ? .
    v-int64-id = 0 .

    run gbl/file2blb.p ( input {&add-def}
                        ,input  "yes"
                        ,input (buffer ub.goods:handle)
                        ,input keyrec
                        ,input {&blob-gds-collec-image} /*p-field-*/
                        ,input {&blob-gds-collec-image}
                        ,input-output v-part-num
                        ,input {&lob-res-data} /*p-resource-type*/
                        ,input-output v-blob-db-num
                        ,input-output v-int64-id
                        ,input v-file-name
                        ) no-error .
    if error-status :error then do:
      v-err-mess = substitute("Не могу сохранить изображение &1 в базу &2&3&2&4"
                                    , v-file-name
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).
      undo, return error v-err-mess .
    end.
    
    find first buf_gds-season no-lock where buf_gds-season.db-num = ibs.th.gbl.gbl-var:g#db-num
                                        and buf_gds-season.gds-code = ub.goods.gds-code
                                        no-error .
    if not available buf_gds-season
    then do :
      os-delete value(v-file-name) no-error .
    end .  
    else do :
      RUN imagelist_encode IN THIS-PROCEDURE (INPUT v-file-name, OUTPUT v-file-name).
      RUN gds-attr-write (v-nbc, "image-list":U, v-file-name).
    end .                                  
  end .
  
  
  procedure mainmenu_getcntxt :
  // @FUTU дописать перечень мест, из которых вызывается данная процедура 
    define output parameter v-cntxt-db-num        as integer   no-undo . /* текущая БД            */   
    define output parameter v-cntxt-userid        as character no-undo . /* текущий пользователь  */   
    define output parameter v-cntxt-level         as character no-undo . /* уровень контекста     */   
    define output parameter v-cntxt-host-code-obj as integer   no-undo . /* текущая фирма         */   
    define output parameter v-cntxt-obj-type      as character no-undo . /* тип текущего объекта  */   
    define output parameter v-cntxt-obj-code      as integer   no-undo . /* код текущего объекта  */   
    define output parameter v-cntxt-db-num-obj    as integer   no-undo . /* база текущего объекта */   
    define output parameter v-cntxt-is-admin      as logical   no-undo . /* база текущего объекта */  
    
    v-cntxt-db-num = ibs.th.gbl.gbl-var:g#db-num .
    v-cntxt-userid = ibs.th.gbl.gbl-var:g#userid .
    v-cntxt-level = ? .
    v-cntxt-host-code-obj = ub.clients.host-code .
    v-cntxt-obj-type = ub.clients.obj-type .
    v-cntxt-obj-code = ub.clients.obj-code .
    v-cntxt-db-num-obj = ub.clients.db-num .
    v-cntxt-is-admin =  ? .
  end procedure .
  
  procedure cb_get-gds-list :
    define input parameter p-handle as handle no-undo .
    for each gds-list:
      run cb_set-gds-list in p-handle ( input (buffer gds-list:handle)).
    end.
  end procedure. /* set-gds-list */
  
  /* Для удаления с кассы товаров с атрибутом "Только производство" */
  procedure write-log-and-file :
    define input parameter p-tabs as integer no-undo .
    define input parameter p-log-file as character no-undo .
    define input parameter p-int2 as integer no-undo .
    define input parameter p-mess as character no-undo .
    
  end procedure. /* write-log-and-file */
  
  procedure show-counter :
  
  end procedure. /* show-counter */
  
  procedure write-counter :
    define input parameter p-counter-string     as character    no-undo.
  end procedure. /* show-counter */
