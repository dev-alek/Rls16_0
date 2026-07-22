block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение, установка начальных значений и проверка для атрибутов настройки - фирмы магазина

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/01/04
Author: Bakhtadze Natalya
Creation date: 10/01/04

*/

define input parameter p-mode     as character no-undo .
/*"get" попробовать получить значение если оно есть
"init" получить только начальное - если магазин из фирмы - если фирма то составить по нужным правилам
*/
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-upper-param-code like ub.thbj-attr.upper-prop-code no-undo .
/*код атриубта*/
define input parameter p-param-code like ub.thbj-attr.prop-code no-undo .
/*код параметра входящего в атрибут или (p-mode="check" значение атрибута которое хотим проверить*/
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-param-type as character no-undo .
define temp-table tt0-thbj-attr no-undo like ub.thbj-attr.
define input-output parameter table for tt0-thbj-attr append.

/*если код параметра задан то возваращается тип параметра */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Получение, установка начальных значений и проверка  для атрибутов настройки - фирмы магазина склада".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5':u, p-mode, p-obj-type, p-obj-code, p-upper-param-code, p-param-code)" }
&global-define shattri
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/thbjattr.i }

define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .              /*еще чего - нибудь*/
define variable attr-value as char no-undo .              /*для знач по умолч*/
define variable v-host as logical no-undo .
define variable v-shop as logical no-undo .
define variable v-store as logical no-undo .
define variable v-global as logical no-undo .
define variable v-db as logical no-undo .
define variable v-region as logical no-undo .
define variable v-prop-list as character no-undo .
define variable v-prop-type-list as character no-undo .
define variable v-prop-label-list as character no-undo .
define variable ii as integer no-undo .
define variable v-host-code like ub.shop.host-code no-undo .
define variable v-exist as logical no-undo .
define variable v-ibmnalc like ub.currency.curr-code no-undo .
define variable v-ipcsbasc like ub.currency.curr-code no-undo .
define variable v-omrbase like ub.currency.curr-code no-undo .
define variable v-omrnbase like ub.currency.curr-code no-undo .
define variable v-num-list as character no-undo .
define variable v-mag-basc like ub.currency.curr-code no-undo .
define variable v-obj-db-num like ub.scales.db-num no-undo .
define variable v-dop as character no-undo .
define variable v-prop-code as character no-undo .
define variable v-ii as integer no-undo .
define variable v-found as decimal no-undo .
define variable v-attr-type as character no-undo .
define variable v-upper-param-code as character no-undo .
define variable v-to-create as logical no-undo .
define variable v-need-prop-list as character no-undo .
define variable v2-param-type as character no-undo .
define variable v2-value-character as decimal no-undo .
define variable v2-value-date as date no-undo .
define variable v2-value-decimal as decimal no-undo .
define variable v2-value-integer as INTEGER no-undo .
define variable v2-value-logical AS LOGICAL no-undo .
define variable v-num-need as integer no-undo .
define variable v-num-found as integer no-undo .
define variable v-level-way as character no-undo .
define variable v-up-way as character no-undo .
define variable v-level-way-2 as character no-undo .
define variable v-to-find-upper-param-code as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-dflt-level-way as character no-undo . /*типа "obj,host,global"*/
define variable v-dflt-up-way as character no-undo .     /*соответ список названий секций*/
define variable v-start as integer no-undo .
define variable v-step as integer no-undo .
define variable v-reg-code as integer no-undo .

define buffer buf_scales for ub.scales.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_cash-pay-bnal for ub.cash-pay.
define buffer buf_cash-pay-nal for ub.cash-pay.
define buffer buf_cash-pay-ntnal for ub.cash-pay.
define buffer stt0-thbj-attr for tt0-thbj-attr.
define buffer buf_tt0-thbj-attr for tt0-thbj-attr.
define buffer buf_shop for ub.shop.
define buffer buf_firm for ub.firm.
define buffer buf_sysconf for ub.sysconf.
define buffer cli_obj for ub.clients.

do
on error undo, return error
:
  v-upper-param-code = p-upper-param-code.
  if p-obj-type <> "":U
  and p-obj-type <> {&cmp}
  and p-obj-type <> {&shop}
  and p-obj-type <> {&stock}
  and p-obj-type <> {&db}
  and p-obj-type <> {&region}
  then do:
    undo, return error substitute( "&1 &2 &3 Неверное значение p-obj-type &4"
                                  , vss-workfile
                                  , vss-revision
                                  , vss-description
                                  , p-obj-type ).
  end.
  if p-mode = "check":U then do:
    run check-param-value in this-procedure no-error .
    if error-status:error then do:
        undo, return error substitute( "&1 &2 &3 &4"
                                      , vss-workfile
                                      , vss-revision
                                      , vss-description
                                      , return-value ).
    end.
    return.
  end.
  
  assign
  v-obj-type = p-obj-type
  v-obj-code = p-obj-code
  .
  
  if p-mode = "get":U
  or p-mode = "init":U
  then do:
    run thbjattr_legacy in this-procedure ( input p-upper-param-code
                                           ,output v-dflt-level-way
                                           ,output v-dflt-up-way).
    case p-obj-type:
        when {&shop} or
        when {&stock} then do:
          v-start = 1.
        end.    
        when {&db} then do:
          if lookup("db", v-dflt-level-way) = 1 
          then v-start = 1.            
          else v-start = 2.   
        end.    
        when {&region} then do:
          v-start = 2.
        end.
        when {&cmp}
        then do:
          v-start = 2.
        end.
        when '' then do:
          v-start = 3.
        end.
    end case.                                       
                                            
    _step:
    do v-step = v-start to 3:
      if  entry(v-step, v-dflt-level-way) = '' then do:
        if v-step = v-start then do:
          /*ошибка*/
        end.
        else do:
          next _step.
        end.
      end.
      v-upper-param-code = entry(v-step, v-dflt-up-way).
      case v-step:
        when 1 then do:
          case p-obj-type:
            when {&shop} then do:
              v-obj-type = {&shop}.
              v-obj-code = v-obj-code.
            end.
            when {&stock} then do:
              v-obj-type = {&stock}.
              v-obj-code = v-obj-code.
            end.
            when {&cmp} then do:
            end.
            when {&db} then do:
              v-obj-type = {&db}.
              v-obj-code = p-obj-code.
            end.
            when '' then do:
            end.
          end case. /*case p-obj-type:*/
        end. /*when 1 then do:*/
        when 2 then do:
          case p-obj-type:
            when {&shop}
            or
            when {&stock}
            then do:
              if not v-host then next _step.
              v-obj-type = {&cmp}.
              { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
              v-obj-code = v-host-code.
            end.
            when {&cmp} then do:
              v-obj-type = {&cmp}.
              v-obj-code = p-obj-code.
            end.
            when {&db} then do:
              if lookup("region", v-dflt-level-way) = 2  
              then do:
                  v-obj-type = {&region}.
                  { gbl/regcode.i p-obj-type p-obj-code v-reg-code }
                  v-obj-code = v-reg-code.
              end.
              else do:      
                  v-obj-type = {&db}.
                  v-obj-code = p-obj-code.
              end.
            end.
            when {&region} then do:
              v-obj-type = {&region}.
              v-obj-code = p-obj-code.
            end.
            when '' then do:
            end.
          end case. /*case p-obj-type:*/
        end. /*when 2*/
        when 3 then do:
          if p-obj-type <> ''
          and not v-global then next _step.
          v-obj-type = ''.
          v-obj-code = 0.
        end. /*when 3*/
      end case. /*case v-step:*/
      v-level-way = v-level-way + (if v-level-way = '' then '' else chr(44)) + v-obj-type.
      v-level-way-2 = v-level-way-2 + (if v-level-way-2 = '' then '' else {&comma-char})  + string(v-obj-code).
      v-up-way = v-up-way + (if v-up-way = "" then "" else {&comma-char}) +  entry(v-step, v-dflt-up-way).
      
      if p-param-code = '':U then do:
        run thbjattr_get-section  in this-procedure (
                                             input v-obj-type
                                            ,input v-obj-code
                                            ,input v-upper-param-code
                                            ,input p-mode
                                            ,input-output table tt0-thbj-attr
                                            ,output v-found
                                            ) no-error.                                            
      end.
      else do:
        run thbjattr_value  in this-procedure (
                                             input v-obj-type
                                            ,input v-obj-code
                                            ,input v-upper-param-code
                                            ,input p-param-code
                                            ,output p-value-character
                                            ,output p-value-date
                                            ,output p-value-decimal
                                            ,output p-value-integer
                                            ,output p-value-logical
                                            ,output v-attr-type
                                            ,output v-found
                                            ) no-error.
      end.
      if error-status:error then do:
        undo, return error substitute( "&1 &2 &3 &4 &5"
                                      , vss-workfile
                                      , vss-revision
                                      , vss-description
                                      , error-status:get-message(1)
                                      , return-value ).

      end.
                                           
      if v-found = 1.0
      and v-step = v-start
      then do:
       /*нашли все prop*/
        return.
      end.
        run thbjattr_code_reg in this-procedure (
         input  v-upper-param-code
        ,input p-param-code
        ,output attr-label
        ,output attr-user-can-edit
        ,output attr-output-display
        ,output attr-other
        ,output v-prop-list
        ,output v-prop-type-list
        ,output v-prop-label-list
        ,output v-global
        ,output v-host
        ,output v-shop
        ,output v-store
        ,output v-db
        ,output v-region
        ) no-error .
      if error-status:error then do:
        undo, return error substitute( "&1 &2 &3 Неверное значение v-upper-param-code &4 или p-param-code &5"
                                      , vss-workfile
                                      , vss-revision
                                      , vss-description
                                      , v-upper-param-code
                                      , p-param-code
                                      ).
      end.
      v-need-prop-list = v-prop-list.
      v-num-need = num-entries(v-prop-list).
      /*нашли начальное значение из вышестоящего*/
      if v-found = 1.0 or (v-found > 0 and v-step <> v-start) then do:
        if p-param-code <> '' then return.
        if p-param-code = '':U
        and p-obj-type <> v-obj-type then do:
          for each tt0-thbj-attr
              where tt0-thbj-attr.obj-type = v-obj-type:
            if lookup(tt0-thbj-attr.prop-code,  v-need-prop-list) = 0
            and entry(1, tt0-thbj-attr.upper-prop-code, "_") = p-upper-param-code
            then do:
              delete tt0-thbj-attr.
              next.
            end.
            v-to-find-upper-param-code = (if tt0-thbj-attr.upper-prop-code <> p-upper-param-code
                                        and  num-entries(p-upper-param-code, "_") > 1
                                        and (entry(2, p-upper-param-code, "_") = "obj"
                                              or
                                              entry(2, p-upper-param-code, "_") = "host"
                                              or
                                              entry(2, p-upper-param-code, "_") = "db"
                                              or
                                              entry(2, p-upper-param-code, "_") = "region"
                                              )
                                        then p-upper-param-code
                                        else tt0-thbj-attr.upper-prop-code
                                        ).                                        
            find first buf_tt0-thbj-attr where
                    buf_tt0-thbj-attr.obj-type = p-obj-type
                and buf_tt0-thbj-attr.obj-code = p-obj-code
                and buf_tt0-thbj-attr.upper-prop-code = v-to-find-upper-param-code
                and buf_tt0-thbj-attr.prop-code = tt0-thbj-attr.prop-code no-error .
            if not available buf_tt0-thbj-attr then do:
              create buf_tt0-thbj-attr.
              buffer-copy tt0-thbj-attr except obj-type obj-code upper-prop-code
              to buf_tt0-thbj-attr
              assign
              buf_tt0-thbj-attr.obj-type = p-obj-type
              buf_tt0-thbj-attr.obj-code = p-obj-code
              buf_tt0-thbj-attr.upper-prop-code = v-to-find-upper-param-code
              .
              delete tt0-thbj-attr.
            end.
            else delete tt0-thbj-attr.
            v-num-found = v-num-found + 1.
        end.
      end.
      if v-num-need = v-num-found then do:
        return.
      end.
      end. /*v-found*/
    end. /*do v-step*/
  end. /*if p-mode = "get":U then do:*/

&scop create-thbj-attr                                                        ~
      if p-param-code = '':U or p-param-code = ~{&prop-code~} then do:       ~
        v-to-create = no.                                                      ~
      run create-thbj-attr in this-procedure ( input ~{&prop-code~} ~
                                              ,input "~{&ptype~}"     ~
                                              ,input v-level-way    ~
                                              ,input v-level-way-2  ~
                                              ,input v-up-way       ~
                                              ,output v-to-create) no-error. ~
        if v-to-create then do:                                                 ~
       if not available stt0-thbj-attr then do:                      ~
        &if "~{&ptype~}"  <> "void"  &then                             ~
          assign                                                                ~
          tt0-thbj-attr.property-value-~{&ptype~} = ~{&prop-value~}      ~
            p-value-~{&ptype~} = (if p-param-code = ~{&prop-code~}                  ~
                                then ~{&prop-value~}                   ~
                                  else p-value-~{&ptype~})  .                       ~
        &endif                                                       ~
          end.                                                                     ~
          else do:                                                                 ~
        &if "~{&ptype~}"  <> "void"  &then                             ~
            p-value-~{&ptype~} = (if p-param-code = ~{&prop-code~}                  ~
                                then stt0-thbj-attr.property-value-~{&ptype~}    ~
                                  else p-value-~{&ptype~})  .                       ~
        &endif                                                       ~
          end.                                                                      ~
        end.                                                                        ~
        else do:                                                                    ~
      &if "~{&ptype~}"  <> "void" &then                                ~
            assign                                                                  ~
            p-value-~{&ptype~} = (if p-param-code = ~{&prop-code~}                  ~
                                  then stt0-thbj-attr.property-value-~{&ptype~}    ~
                                  else p-value-~{&ptype~})  .                       ~
      &endif                                                                ~
        end.                                                                        ~
      end

  CASE p-upper-param-code:
    when {&attr-autosale} then do:
      v-prop-code = "{&bef-attr-autosale_automail},{&bef-attr-autosale_augetres},{&bef-attr-autosale_autoclos}," +
                    "{&bef-attr-autosale_autocomp},{&bef-attr-autosale_autocalc},{&bef-attr-autosale_one-curs}," +
                    "{&bef-attr-autosale_prcl-spl}," +
                    "{&bef-attr-autosale_resttpsi},{&bef-attr-autosale_sale-filter}," +
                    "{&bef-attr-autosale_neg-tpsi-weight},{&bef-attr-autosale_neg-tpsi-oper},{&bef-attr-autosale_main-tpsi},{&bef-attr-autosale_one-sale-per-day},{&bef-attr-autosale_close-day-period}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-autosale_autofbr},{&bef-attr-autosale_restdish},{&bef-attr-autosale_restingr}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype logical
&scop prop-value yes
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-autosale_neg-tpsi-qnty}".
&scop ptype decimal
&scop prop-value 0.0
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-autosale_tpsi-mode}".
&scop ptype integer
&scop prop-value 1
&scop prop-code v-prop-code
      {&create-thbj-attr}.

      v-prop-code = "{&bef-attr-autosale_close-in-rfsl}".
&scop ptype integer
&scop prop-value 0
&scop prop-code v-prop-code
      {&create-thbj-attr}.


      v-prop-code = "{&bef-attr-autosale_wrkr},{&bef-attr-autosale_agnt},{&bef-attr-autosale_boss}".
&scop ptype integer
&scop prop-value ?
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-autosale_sale-add}".
      v-dop = '':U.
      do ii = 1 to num-entries({&sale-add-kinds}) :
         v-dop = v-dop + (if v-dop = '':U then '':U else ';') + entry(ii, {&sale-add-kinds}) + fill({&comma-char}, 2).
      end.

&scop ptype character
&scop prop-value v-dop
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code = "{&bef-attr-autosale_pay-gds-algo}".
      v-dop = '':U.

&scop ptype character
&scop prop-value v-dop
&scop prop-code v-prop-code

      {&create-thbj-attr}.

    end.
    when {&attr-get-chk} then do:
      v-prop-code = "{&bef-attr-get-chk_cas-curs},{&bef-attr-get-chk_hnum},{&bef-attr-get-chk_cas-shft}," +
                    "{&bef-attr-get-chk_dc-mask},{&bef-attr-get-chk_card-by-mask},{&bef-attr-get-chk_annu-check},{&bef-attr-get-chk_z-check}," +
                    "{&bef-attr-get-chk_ptrl-check},{&bef-attr-get-chk_no-get-chk},{&bef-attr-get-chk_is-100-discnt}".

&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-get-chk_v-shft},{&bef-attr-get-chk_t-shft},{&bef-attr-get-chk_zero-cashier}".

&scop ptype integer
&scop prop-value 0
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.
    when {&attr-chk-view} then do:
      v-prop-code =  "{&bef-attr-chk-view_ch-bc-ck},{&bef-attr-chk-view_chk-spfc},{&bef-attr-chk-view_dc-change}".
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code =  "{&bef-attr-chk-view_chk-inf}".

&scop ptype logical
&scop prop-value yes
&scop prop-code v-prop-code

      {&create-thbj-attr}.


      v-prop-code =  "{&bef-attr-chk-view_paycardv}".
&scop ptype character
&scop prop-value '':U
&scop prop-code v-prop-code

      {&create-thbj-attr}.

    end.
    when {&attr-cd-sending} then do:
      v-prop-code =  "{&bef-attr-cd-sending_alllstcs},{&bef-attr-cd-sending_noautocs},{&bef-attr-cd-sending_process-sale}".
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code =  "{&bef-attr-cd-sending_cdpcknum}".
&scop ptype integer
&scop prop-value 200
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-sending_dflt-cd}".

&scop ptype character
&scop prop-value ~{&cd-type-IBM-XML}
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-sending_mask_s-c}".

&scop ptype character
&scop prop-value ""
&scop prop-code v-prop-code

      {&create-thbj-attr}.
    end.
    when {&attr-cd-inf-send} then do:
      v-prop-code =  "{&bef-attr-cd-inf-send_nam-2str},{&bef-attr-cd-inf-send_nam-artc}," +
                     "{&bef-attr-cd-inf-send_cod-pcod},{&bef-attr-cd-inf-send_cp-is-use}".
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      
      v-prop-code =  "{&bef-attr-cd-inf-send_tax-cass}".
&scop ptype logical
&scop prop-value yes
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code =  "{&bef-attr-cd-inf-send_name-2cd}".
&scop ptype character
&scop prop-value "name"
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-inf-send_amntdisc}".
&scop ptype integer
&scop prop-value 0
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-inf-send_code-system}".
&scop ptype character
&scop prop-value ""
&scop prop-code v-prop-code

      {&create-thbj-attr}.
      
      v-prop-code =  "{&bef-attr-cd-inf-send_how-temp-disc}".
&scop ptype character
&scop prop-value ~{&dgr-temp-disc~}
&scop prop-code v-prop-code

      do v-ii = 1 to num-entries(v-prop-code):
      {&create-thbj-attr}.
      end.

      v-prop-code =  "{&bef-attr-cd-inf-send_how-pcnt-kat}".
&scop ptype character
&scop prop-value ~{&dgr-pcnt-kat~}
&scop prop-code v-prop-code

      do v-ii = 1 to num-entries(v-prop-code):
      {&create-thbj-attr}.
      end.



    end.
    when {&attr-scale-inf} then do:
      v-prop-code =  "{&bef-attr-scale-inf_scales-type}".

&scop ptype character
&scop prop-value ~{&scales-type~}
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-scale-inf_scales-pr}".

&scop ptype character
&scop prop-value ~{&scales-pr~}
&scop prop-code v-prop-code

      {&create-thbj-attr}.

       { gbl/objdbnum.i p-obj-type p-obj-code v-obj-db-num }
       for each buf_scales NO-LOCK where buf_scales.db-num = v-obj-db-num:
          ASSIGN
          v-num-list = v-num-list + (IF v-num-list = "":U THEN "":U else {&comma-char}) + STRING(buf_scales.scales-num).
       end.

      v-prop-code =  "{&bef-attr-scale-inf_scallist}".

&scop ptype character
&scop prop-value v-num-list
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-scale-inf_sclin-ld}".

&scop ptype integer
&scop prop-value 0
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-scale-inf_noauto-scls}".

&scop ptype logical
&scop prop-value yes
&scop prop-code v-prop-code

      {&create-thbj-attr}.

    end.
    when {&attr-cd-type-ibm} then do:
      { gbl/r-b-curr.i v-host-code v-ibmnalc }
      v-prop-code =  "{&bef-attr-cd-type-ibm_ibmgroup},{&bef-attr-cd-type-ibm_multicurr}".

&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code =  "{&bef-attr-cd-type-ibm_ibmrubc}".

&scop ptype integer
&scop prop-value 99
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-ibm_ibmnalc},{&bef-attr-cd-type-ibm_cd-vat}".

&scop ptype integer
&scop prop-value 0
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code =  "{&bef-attr-cd-type-ibm_ibmspool}".

&scop ptype integer
&scop prop-value 3
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-ibm_cdtaxlst},{&bef-attr-cd-type-ibm_specgrp}".

&scop ptype character
&scop prop-value '':U
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.
    when {&attr-cd-type-ipc-servispl} then do:
      { gbl/r-b-curr.i v-host-code v-ipcsbasc }
      find first buf_cash-pay no-lock where
                buf_cash-pay.curr-code = v-ipcsbasc and buf_cash-pay.is-cash  no-error .

      v-prop-code =  "{&bef-attr-cd-type-ipc-servispl_ipcsbasc}".

&scop ptype integer
&scop prop-value v-ipcsbasc
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-ipc-servispl_ipcspayn}".
&scop ptype integer
&scop prop-value (if available buf_cash-pay then buf_cash-pay.cdpay-code  else 0)
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-ipc-servispl_ipcsdobc}".

&scop ptype character
&scop prop-value ";"
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-ipc-servispl_ipcscpfx}".

&scop ptype integer
&scop prop-value 23
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-ipc-servispl_ipcpgpfx}".

&scop ptype integer
&scop prop-value 24
&scop prop-code v-prop-code

      {&create-thbj-attr}.


      v-prop-code =  "{&bef-attr-cd-type-ipc-servispl_ipcsccrd},{&bef-attr-cd-type-ipc-servispl_ipcstcrd},{&bef-attr-cd-type-ipc-servispl_ipcscurc}".

&scop ptype character
&scop prop-value '':U
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.
    when {&attr-cd-type-ncr-gm}
    or when {&attr-cd-type-ncr-as-r}
    then do:
      v-prop-code =  "{&bef-attr-cd-type-ncr-gm_ncrscpfx}".

&scop ptype integer
&scop prop-value 23
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-ncr-gm_ncrpgpfx}".

&scop ptype integer
&scop prop-value 24
&scop prop-code v-prop-code

      {&create-thbj-attr}.


      v-prop-code =  "{&bef-attr-cd-type-ncr-gm_ncrdrank}".

&scop ptype character
&scop prop-value "TXD"
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-ncr-gm_save-param}".

&scop ptype character
&scop prop-value "no"
&scop prop-code v-prop-code

      {&create-thbj-attr}.
    end.
    when {&attr-cd-type-magia-xml} then do:
      { gbl/r-b-curr.i v-host-code v-mag-basc }
      find first buf_cash-pay-bnal no-lock where
                buf_cash-pay-bnal.curr-code = v-mag-basc
            and buf_cash-pay-bnal.is-cash  = no
            and buf_cash-pay-bnal.is-credit-card = no
            and buf_cash-pay-bnal.is-debet-card = no
            and buf_cash-pay-bnal.is-credit = no
            and buf_cash-pay-bnal.is-advance = no   no-error .

        v-prop-code =  "{&bef-attr-cd-type-magia-xml_magnopay},{&bef-attr-cd-type-magia-xml_mag-vip}".

&scop ptype integer
&scop prop-value 0
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code =  "{&bef-attr-cd-type-magia-xml_ret-item}".

&scop ptype character
&scop prop-value "6,Возврат блюда/товара"
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-magia-xml_wro-item}".

&scop ptype character
&scop prop-value "5,Списание блюда/товара"
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-magia-xml_ret-chk}".

&scop ptype character
&scop prop-value "2,Возврат чека"
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-magia-xml_wro-chk}".

&scop ptype character
&scop prop-value "1,Списание чека"
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-magia-xml_ret-ord}".

&scop ptype character
&scop prop-value "4,Возврат заказа"
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-magia-xml_wro-ord}".

&scop ptype character
&scop prop-value "3,Списание заказа"
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-magia-xml_mag-bnal}".

&scop ptype integer
&scop prop-value  (if available buf_cash-pay-bnal  then buf_cash-pay-bnal.cdpay-code else 0)
&scop prop-code v-prop-code

      {&create-thbj-attr}.

    end.
    when {&attr-cd-type-omron} then do:
      { gbl/r-b-curr.i v-host-code v-omrbase }
      find first buf_cash-pay-nal no-lock where
                buf_cash-pay-nal.curr-code = v-omrbase
            and buf_cash-pay-nal.is-cash  = yes  no-error .
      find first buf_cash-pay-ntnal no-lock where
                buf_cash-pay-ntnal.curr-code = v-omrbase
            and buf_cash-pay-ntnal.is-cash  = no
            and buf_cash-pay-ntnal.is-credit-card = no
            and buf_cash-pay-ntnal.is-debet-card = no
            and buf_cash-pay-ntnal.is-credit = no
            and buf_cash-pay-ntnal.is-advance = no   no-error .
      v-prop-code =  "{&bef-attr-cd-type-omron_omrbase}".

&scop ptype integer
&scop prop-value  v-omrbase
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-omron_omrnal}".

&scop ptype integer
&scop prop-value  (if available buf_cash-pay-nal then buf_cash-pay-nal.cdpay-code  else 0)
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-omron_omrntnl}".

&scop ptype integer
&scop prop-value  (if available buf_cash-pay-ntnal then buf_cash-pay-ntnal.cdpay-code  else 0)
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-omron_omrpayl},{&bef-attr-cd-type-omron_omrcurl}".

&scop ptype character
&scop prop-value  '':U
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
       {&create-thbj-attr}.
      end.
    end.
    when {&attr-cd-type-omron-new} then do:
      { gbl/r-b-curr.i v-host-code v-omrnbase }
      find first buf_cash-pay-nal no-lock where
                buf_cash-pay-nal.curr-code = 0 /*оказ у них 0*/
            and buf_cash-pay-nal.is-cash  = yes  no-error .
      find first buf_cash-pay-ntnal no-lock where
                buf_cash-pay-ntnal.curr-code = v-omrnbase
            and buf_cash-pay-ntnal.is-cash  = no
            and buf_cash-pay-ntnal.is-credit-card = no
            and buf_cash-pay-ntnal.is-debet-card = no
            and buf_cash-pay-ntnal.is-credit = no
            and buf_cash-pay-ntnal.is-advance = no   no-error .
      v-prop-code =  "{&bef-attr-cd-type-omron-new_omrnbase}".

&scop ptype integer
&scop prop-value  0
&scop prop-code  v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-omron-new_omrnnal}".

&scop ptype integer
&scop prop-value  (if available buf_cash-pay-nal then buf_cash-pay-nal.cdpay-code else 0)
&scop prop-code  v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-omron-new_omrnntnl}".

&scop ptype integer
&scop prop-value  (if available buf_cash-pay-ntnal then buf_cash-pay-ntnal.cdpay-code else 0)
&scop prop-code  v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-omron-new_omrnpayl},{&bef-attr-cd-type-omron-new_omrncurl}".

&scop ptype character
&scop prop-value  '':U
&scop prop-code  entry(v-ii, v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.
    when {&attr-cd-type-IBM-XML} then do:
      v-prop-code =  "{&bef-attr-cd-type-ibm-xml_cdtaxlst},{&bef-attr-cd-type-ibm-xml_specgrp}".

&scop ptype character
&scop prop-value  '':U
&scop prop-code  entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code =  "{&bef-attr-cd-type-ibm-xml_ibmnalc}".

&scop ptype integer
&scop prop-value  v-ibmnalc
&scop prop-code  v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-ibm-xml_ibm-ccm}".

&scop ptype integer
&scop prop-value  0
&scop prop-code  v-prop-code

      {&create-thbj-attr}.


      v-prop-code = "{&bef-attr-cd-type-ibm-xml_ibmrubc}".

&scop ptype integer
&scop prop-value  99
&scop prop-code  v-prop-code

      {&create-thbj-attr}.

      v-prop-code = "{&bef-attr-cd-type-ibm-xml_ibmspool}".

&scop ptype integer
&scop prop-value  3
&scop prop-code  v-prop-code

      {&create-thbj-attr}.

      v-prop-code = "{&bef-attr-cd-type-ibm-xml_ibmgroup},{&bef-attr-cd-type-IBM-XML_multicurr}".

&scop ptype logical
&scop prop-value  no
&scop prop-code  entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-cd-type-ibm-xml_cd-vat}".

&scop ptype integer
&scop prop-value  0
&scop prop-code  v-prop-code

      {&create-thbj-attr}.

    end.
    when {&attr-cd-type-r-keeper} then do:


      v-prop-code = "{&bef-attr-cd-type-r-keeper_cash-pay-list}".

&scop ptype character
&scop prop-value  '':U
&scop prop-code  v-prop-code

      {&create-thbj-attr}.

      v-prop-code = "{&bef-attr-cd-type-r-keeper_dis-rule-list}".

&scop ptype character
&scop prop-value  '':U
&scop prop-code  v-prop-code

      {&create-thbj-attr}.

      v-prop-code = "{&bef-attr-cd-type-r-keeper_date-format}".

&scop ptype character
&scop prop-value  "dd.mm.yyyy"
&scop prop-code  v-prop-code

      {&create-thbj-attr}.

      /*скидки пока только одного типа*/
    end.
    when {&attr-cd-type-maria} then do:

      v-prop-code =  "{&bef-attr-cd-type-maria_cdtaxlst}".

&scop ptype character
&scop prop-value  '':U
&scop prop-code  v-prop-code

      {&create-thbj-attr}.


      v-prop-code =  "{&bef-attr-cd-type-maria_mariapayg}".

&scop ptype character
&scop prop-value  '1/1,0;2/0,0;3/0,0;4/0,0':U
&scop prop-code  v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-maria_mariapayp}".

&scop ptype character
&scop prop-value  '1,0/1,0;2,0/0,0;3,0/0,0':U
&scop prop-code  v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-maria_dr-list}".

&scop ptype character
&scop prop-value  '':U
&scop prop-code  v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-maria_drgrouprank}".

&scop ptype character
&scop prop-value  '%-46,%сумма-49':U
&scop prop-code  v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  "{&bef-attr-cd-type-maria_drgdsrank}".

&scop ptype character
&scop prop-value  '%/std-discnt-rule,abs/abs-discnt-rule,%кол-во/qnty-discnt-rule,%сумма/tot-discnt-rule':U
&scop prop-code  v-prop-code

      {&create-thbj-attr}.
    end.
    when {&attr-cd-type-autotank} then do:

      v-prop-code = "{&bef-attr-cd-type-autotank_cash-pay-list}".

&scop ptype character
&scop prop-value  '0,Наличные/1,0;1,Банковская карта/?,?;2,Топливная карта/?,?;3,Наличные со скидкой/?,?;4,Банковская карта со скидкой/?,?;5,Кошелек Элекснет/?,?;6,Мобильное приложение/?,?'
&scop prop-code  v-prop-code

      {&create-thbj-attr}.

      v-prop-code = "{&bef-attr-cd-type-autotank_ibmgroup}".

&scop ptype logical
&scop prop-value  no
&scop prop-code  v-prop-code

      {&create-thbj-attr}.

      v-prop-code = "{&bef-attr-cd-type-autotank_specgrp}".

&scop ptype character
&scop prop-value  ''
&scop prop-code  v-prop-code

      {&create-thbj-attr}.

      /*скидки пока только одного типа*/
    end.
    when {&attr-alias-tpsi} then do:
      v-prop-code =  {&attr-alias-tpsi_alias-type-price}.

&scop ptype integer
&scop prop-value  0
&scop prop-code  v-prop-code

      {&create-thbj-attr}.

      v-prop-code =  {&attr-alias-tpsi_alias-object-price}.

&scop ptype character
&scop prop-value '':U
&scop prop-code  v-prop-code

      {&create-thbj-attr}.


    end.

    when {&attr-abc-sale-day} then do:
      v-prop-code = {&prop-list-attr-abc-sale-day} .

&scop ptype integer
&scop prop-value  0
&scop prop-code  entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.


    when {&attr-contr-in} then do:
      v-prop-code = {&prop-list-attr-contr-in} .

&scop ptype logical
&scop prop-value  no
&scop prop-code  entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.


    when {&attr-nakl_par} then do:
      v-prop-code = "{&bef-attr-nakl_par_type-vat}" .
&scop ptype integer
&scop prop-value 1
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-nakl_par_type-slt}" .
&scop ptype integer
&scop prop-value 2
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.


      v-prop-code = "{&bef-attr-nakl_par_proxycrd}" .
&scop ptype logical
&scop prop-value no
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-nakl_par_factorrt}" .
&scop ptype decimal
&scop prop-value 0.0
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.


      v-prop-code = "{&bef-attr-nakl_par_date-close-period}" .
&scop ptype date
&scop prop-value date('')
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-nakl_par_stfactdt},{&bef-attr-nakl_par_intprmvq},{&bef-attr-nakl_par_minusprt},{&bef-attr-nakl_par_avail-on-date},{&bef-attr-nakl_par_inp_sum},{&bef-attr-nakl_par_reasonm},{&bef-attr-nakl_par_back-date},{&bef-attr-nakl_par_not-ord},{&bef-attr-nakl_par_neg-ask},{&bef-attr-nakl_par_vat-goods},{&bef-attr-nakl_par_inv-ship},{&bef-attr-nakl_par_round-vat-sum},{&bef-attr-nakl_par_gtd-to-imp-prod},{&bef-attr-nakl_par_exc-max-qnty},{&bef-attr-nakl_par_mark-alchol},{&bef-attr-nakl_par_edit-fact-wayb}" .
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

          v-prop-code = "{&bef-attr-nakl_par_reasonme}" .
&scop ptype character
&scop prop-value '':U
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

          v-prop-code = "{&bef-attr-nakl_par_attr-PN}" .
&scop ptype character
&scop prop-value 'dids,nids':U
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
     
          v-prop-code = "{&bef-attr-nakl_par_attr-mandatory-gds-in-wayb}" .
&scop ptype character
&scop prop-value 'dids,nids':U
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
     
          v-prop-code = "{&bef-attr-nakl_par_attr-mandatory-gds-ret-wayb}" .
&scop ptype character
&scop prop-value '':U
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
     
          v-prop-code = "{&bef-attr-nakl_par_attr-mandatory-gds-exp-wayb}" .
&scop ptype character
&scop prop-value '':U
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      
          v-prop-code = "{&bef-attr-nakl_par_reasons-for-return}" .
&scop ptype character
&scop prop-value '':U
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      
          v-prop-code = "{&bef-attr-nakl_par_reasons-write-off}" .
&scop ptype character
&scop prop-value '':U
&scop prop-code  entry(v-ii,v-prop-code)


      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
     end.

    when {&attr-nakl-glob} then do:
      v-prop-code = "{&bef-attr-nakl-glob_rnd-znk}" .
&scop ptype integer
&scop prop-value 2
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-nakl-glob_slt-ext},{&bef-attr-nakl-glob_vat-ext}" .
&scop ptype character
&scop prop-value ''
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-nakl-glob_nocurbas}" .
&scop ptype character
&scop prop-value 'no'
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-nakl-glob_prc-exp}" .
&scop ptype decimal
&scop prop-value 0.0
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-nakl-glob_chk-prs},{&bef-attr-nakl-glob_convimp},{&bef-attr-nakl-glob_curcli},{&bef-attr-nakl-glob_is-bcdoc},{&bef-attr-nakl-glob_is-ov},{&bef-attr-nakl-glob_multdtyp},{&bef-attr-nakl-glob_part-prc},{&bef-attr-nakl-glob_vat-sum},{&bef-attr-nakl-glob_noapndsc}" .
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.


    when {&attr-overval} then do:
      v-prop-code = "{&bef-attr-overval_pr-rndbs},{&bef-attr-overval_pr-sigma},{&bef-attr-overval_pr-incpc}" .
&scop ptype decimal
&scop prop-value 0
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-overval_pr-discm},{&bef-attr-overval_pr-list},{&bef-attr-overval_pr-rndmt},{&bef-attr-overval_pr-goods},{&bef-attr-overval_pr-goods0},{&bef-attr-overval_pr-nogds},{&bef-attr-overval_pr-nogds0}" .
&scop ptype character
&scop prop-value entry(v-ii,"cost,Товар,pr-round-off,1.нет запрета,1.нет запрета,0,0,2")
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

v-prop-code = "{&bef-attr-overval_pr-abs-d},{&bef-attr-overval_pr-altex},{&bef-attr-overval_pr-clt-q},{&bef-attr-overval_pr-dpl-q},{&bef-attr-overval_pr-dscnt},{&bef-attr-overval_pr-notls},{&bef-attr-overval_pr-parex},{&bef-attr-overval_pr-print},{&bef-attr-overval_pr-rdc-q},{&bef-attr-overval_pr-sclex}" .
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-overval_pr-equ-dq}" .
&scop ptype integer
&scop prop-value 2
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

end.

    when {&attr-abc-global} then do:
      v-prop-code = {&prop-list-attr-abc-global} .

&scop ptype character
&scop prop-value entry(v-ii,'simple,ABC,20/70/100,80/20;50/80;0.01':U)
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.
    
    when {&attr-gisMT} then do:
      v-prop-code = "{&bef-attr-gisMT_adressPort}".
&scop ptype character
&scop prop-value ''
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-gisMT_dopParam}".
&scop ptype character
&scop prop-value ''
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-gisMT_gisAdress}".
&scop ptype character
&scop prop-value 'https://markirovka.sandbox.crptech.ru/api/v4/true-api/codes/check'
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-gisMT_proxyLogin}".
&scop ptype character
&scop prop-value ''
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-gisMT_proxyPswd}".
&scop ptype character
&scop prop-value ''
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-gisMT_maxTime}".
&scop ptype integer
&scop prop-value 72
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-gisMT_regKey}".
&scop ptype character
&scop prop-value ''
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-gisMT_timeFalStart}".
&scop ptype integer
&scop prop-value 24
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-gisMT_waitTime}".
&scop ptype decimal
&scop prop-value 4
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.   
      v-prop-code = "{&bef-attr-gisMT_crashSituat}".
&scop ptype logical
&scop prop-value no
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end. 
      v-prop-code = "{&bef-attr-gisMT_banDate}".
&scop ptype integer
&scop prop-value 5
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.    
      v-prop-code = "{&bef-attr-gisMT_cdnTurnOn}".
&scop ptype logical
&scop prop-value yes
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.      
      v-prop-code = "{&bef-attr-gisMT_cdnAdress}".
&scop ptype character
&scop prop-value 'https://cdn.crpt.ru/api/v4/true-api/cdn/info'
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.    
      v-prop-code = "{&bef-attr-gisMT_cdnRepeat}".
&scop ptype logical
&scop prop-value yes
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-gisMT_cdnChange}".
&scop ptype logical
&scop prop-value yes
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-gisMT_cdnTimeUpdate}".
&scop ptype integer
&scop prop-value 24
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-gisMT_UpdateRequest}".
&scop ptype logical
&scop prop-value yes
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.      
      v-prop-code = "{&bef-attr-gisMT_OflineAdress}".
&scop ptype character
&scop prop-value 'http://127.0.0.1:5995/api/v2'
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end. 
      v-prop-code = "{&bef-attr-gisMT_OflineLogin}".
&scop ptype character
&scop prop-value ''
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-gisMT_OflinePswd}".
&scop ptype character
&scop prop-value ''
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.      
      v-prop-code = "{&bef-attr-gisMT_MACC_Timeout}".
&scop ptype decimal
&scop prop-value 0
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end. 
      v-prop-code = "{&bef-attr-gisMT_Resp_TH_required}".
&scop ptype integer
&scop prop-value 1
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-gisMT_LmCHzPort}".
&scop ptype character
&scop prop-value '5995'
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-gisMT_TH_IP}".
&scop ptype character
&scop prop-value ''
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end. 
      v-prop-code = "{&bef-attr-gisMT_TH_Port}".
&scop ptype character
&scop prop-value '1500'
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.  
      v-prop-code = "{&bef-attr-gisMT_AddTimeoutPIoT}".
&scop ptype decimal
&scop prop-value 1
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-gisMT_MaxApiToken}".
&scop ptype character
&scop prop-value ''
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end. 
      v-prop-code = "{&bef-attr-gisMT_AgeConfirm}".
&scop ptype integer
&scop prop-value 0
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.  
    end.    
    when {&attr-marking} then do:
      v-prop-code = "{&bef-attr-marking_marking-EDO}".
&scop ptype logical
&scop prop-value no
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-marking_marking-EDO-NotMark}".
&scop ptype logical
&scop prop-value no
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.      
      v-prop-code = "{&bef-attr-marking_checkBlock}".
&scop ptype character
&scop prop-value ''
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.               
      v-prop-code = "{&bef-attr-marking_checkDate}".
&scop ptype character
&scop prop-value ''
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.    
      v-prop-code = "{&bef-attr-marking_checkMRC}".
&scop ptype character
&scop prop-value ''
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.    
      v-prop-code = "{&bef-attr-marking_checkOwner}".
&scop ptype character
&scop prop-value ''
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.       
      v-prop-code = "{&bef-attr-marking_checkStatusKM}".
&scop ptype character
&scop prop-value ''
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-marking_checkTracking}".
&scop ptype character
&scop prop-value ''
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.           
      v-prop-code = "{&bef-attr-marking_marking-type},{&bef-attr-marking_marking-type-edo},{&bef-attr-marking_marking-type-artic},{&bef-attr-marking_marking-type-transitional},{&bef-attr-marking_marking-type-blockCashUnMark},{&bef-attr-marking_marking-type-saleUPD},{&bef-attr-marking_marking-type-onlySale},{&bef-attr-marking_marking-type-saleReturn}".
&scop ptype character
&scop prop-value ''
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-marking_gray_zone_qnty}".
&scop ptype integer
&scop prop-value 0
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.      
      v-prop-code = "{&bef-attr-marking_marking-manual}".
&scop ptype logical
&scop prop-value no
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
     v-prop-code = "{&bef-attr-marking_ban-recipes},{&bef-attr-marking_rus-key}".
&scop ptype logical
&scop prop-value no
&scop prop-code  entry(v-ii,v-prop-code)
     do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
     end. 
     v-prop-code = "{&bef-attr-marking_ban-altr}".
&scop ptype logical
&scop prop-value no
&scop prop-code  entry(v-ii,v-prop-code)
     do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
     end.       
     v-prop-code = "{&bef-attr-marking_bar-code}".
&scop ptype logical
&scop prop-value no
&scop prop-code  entry(v-ii,v-prop-code)
     do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
     end.     
    end.    
    
    when {&attr-ord-global} then do:
      v-prop-code = "{&bef-attr-ord-global_ord-log},{&bef-attr-ord-global_ord-ofof},{&bef-attr-ord-global_ord-oobj},{&bef-attr-ord-global_ord-op},{&bef-attr-ord-global_ord-min-ost-day},{&bef-attr-ord-global_ordcyclg}" .

&scop ptype logical
&scop prop-value logical(entry(v-ii,'no,no,yes,no,no,no':U))
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-ord-global_ordshipd}" .

&scop ptype integer
&scop prop-value 0
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

    end.
    when {&attr-inv-global} then do:
      v-prop-code = "{&attr-inv-global-invclcas},{&attr-inv-global-invclcwt}" .

&scop ptype logical
&scop prop-value logical(entry(v-ii,'no,no':U))
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&attr-inv-global-inv-prs}" .

&scop ptype integer
&scop prop-value integer(entry(v-ii,'0':U))
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

    end.


    when {&attr-arh-global} then do:
      v-prop-code = "{&bef-attr-arh-global_apusharh}" .
&scop ptype logical
&scop prop-value no
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-arh-global_btprskip}" .
&scop ptype character
&scop prop-value ''
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

    end.



    when {&attr-fin-global} then do:
      v-prop-code = "{&bef-attr-fin-global_fo-buyer-nws},{&bef-attr-fin-global_fo-supp-nws},{&bef-attr-fin-global_fo-mc-mode},{&bef-attr-fin-global_fo-gen}".
&scop ptype integer
&scop prop-value 0
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-fin-global_fo-fact}" .
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.

/* 26/II-2019 не используется. Атрибуты финансовых документов перенесены в БПА
    when {&attr-fin-doc} then do:
      v-prop-code = "{&bef-attr-fin-doc_suffix-pko},{&bef-attr-fin-doc_suffix-rko}" .
&scop ptype character
&scop prop-value ({&slash-char} + string(p-obj-code))
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      
      v-prop-code = "{&bef-attr-fin-doc_prefix-pko},{&bef-attr-fin-doc_prefix-rko},{&bef-attr-fin-doc_dpt-dflt-name},{&bef-attr-fin-doc_dpt-dflt-type}" .
&scop ptype character
&scop prop-value ''
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-fin-doc_dpt-option}" .
&scop ptype character
&scop prop-value 'blank'
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-fin-doc_dpt-dflt-code}" .
&scop ptype integer
&scop prop-value 0
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-fin-doc_director}" .
      define variable v-director as character no-undo .
      v-director = ''.
      case v-obj-type:
        when {&shop}
        or when {&stock}
        then do:
          v-director = "dir_obj".
        end.
        when {&cmp} then do:
          v-director = "ruk_firm".
        end.
      end case.
&scop ptype character
&scop prop-value v-director
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-fin-doc_head-position}" .
      define variable v-head-position as character no-undo .
      v-head-position = ''.
      case v-obj-type:
        when {&shop} then do:
          v-head-position = "director".
        end.
        when {&stock} then do:
          v-head-position = "zavsklad".
        end.
        when {&cmp} then do:
          v-head-position = "ruk_firm".
        end.
      end case.
&scop ptype character
&scop prop-value v-head-position
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-fin-doc_snr-accnt}" .
      define variable v-snr-accnt as character no-undo .
      v-snr-accnt = ''.
      case v-obj-type:
        when {&shop} then do:
          v-snr-accnt = "buh_obj".
        end.
        when {&stock}
        or
        when {&cmp} then do:
          v-snr-accnt = "glbuh_firm".
        end.
      end case.
&scop ptype character
&scop prop-value v-snr-accnt
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-fin-doc_current-pko},{&bef-attr-fin-doc_current-rko}" .
&scop ptype integer
&scop prop-value 0
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      
      v-prop-code = "{&bef-attr-fin-doc_cash-book}" .
&scop ptype    integer
&scop prop-value integer(~{&cash-book-firm~})
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

            v-prop-code = "{&bef-attr-fin-doc_uchet}" .
&scop ptype    character
&scop prop-value "smen"
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end. /*attr-fin-doc*/
*/
    when {&attr-ord-obj} then do:
      v-prop-code = "{&bef-attr-ord-obj_ord-askp},{&bef-attr-ord-obj_ord-11}" .
&scop ptype logical
&scop prop-value no
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-ord-obj_ord-obj-rc}" .
&scop ptype character
&scop prop-value ''
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code =  "{&bef-attr-ord-obj_ord-wgt-div-prc}":U.
&scop ptype decimal
&scop prop-value  0.0
&scop prop-code  entry(v-ii, v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code =  "{&bef-attr-ord-obj_ord-comp-prc}":U.
&scop ptype decimal
&scop prop-value  0.0
&scop prop-code  entry(v-ii, v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.

    when {&attr-ass-obj} then do:
      v-prop-code =  "{&bef-attr-Ass-obj_ass-srokiztdel},{&bef-attr-Ass-obj_crit-srokgod},{&bef-attr-Ass-obj_ass-num-days-igt},{&bef-attr-Ass-obj_ass-proc-matr-shabl}":U.
&scop ptype integer
&scop prop-value  0
&scop prop-code  entry(v-ii, v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.

    when {&attr-inv-obj} then do:
      v-prop-code = "{&bef-attr-inv-obj_invclcsp},{&bef-attr-inv-obj_invdnull},{&bef-attr-inv-obj_pstunqtn},{&bef-attr-inv-obj_wastage},{&bef-attr-inv-obj_pstgrp},{&bef-attr-inv-obj_pstunit},{&bef-attr-inv-obj_izlcstpr},{&bef-attr-inv-obj_minus}" .
&scop ptype logical
&scop prop-value no
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-inv-obj_mxpcdcp},{&bef-attr-inv-obj_mxpcicp},{&bef-attr-inv-obj_mxsmdcp},{&bef-attr-inv-obj_mxsmicp}" .
&scop ptype decimal
&scop prop-value 0.0
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.

    when {&attr-srv-auth-ASU} then do:

      v-prop-code = "{&bef-attr-srv-auth-ASU_pko-cli},{&bef-attr-srv-auth-ASU_srv-auth-adr}" .
&scop ptype character
&scop prop-value ''
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.
    when {&attr-egais-host} then do:
      v-prop-code = "{&bef-attr-egais-host_egais-fsrar}".
&scop ptype character
&scop prop-value ''
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    v-prop-code = "{&bef-attr-egais-host_egais-utm}".
&scop ptype character
&scop prop-value ''
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-egais-host_egais-ver-xsd}".
&scop ptype character
&scop prop-value ''
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-egais-host_egais-inn}".
&scop ptype character
&scop prop-value ''
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-egais-host_egais-exsys}".
&scop ptype integer
&scop prop-value 1
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.


    end.
    when {&attr-prt-glob} then do:
      v-prop-code = "{&bef-attr-prt-glob_invprn0},{&bef-attr-prt-glob_outprncd},{&bef-attr-prt-glob_sort-prd},{&bef-attr-prt-glob_torg2-no},{&bef-attr-prt-glob_outprops},{&bef-attr-prt-glob_rep-artic}" .
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.


      v-prop-code = "{&bef-attr-prt-glob_outrecv}" .
&scop ptype character
&scop prop-value ''
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

    end.

    when {&attr-prt-firm} then do:
      v-prop-code = "{&bef-attr-prt-firm_factur01},{&bef-attr-prt-firm_tick-w},{&bef-attr-prt-firm_incurrat}" .
&scop ptype logical
&scop prop-value no
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.

    when {&attr-prt-obj} then do:
      v-prop-code = "{&bef-attr-prt-obj_FGdsNinD}" .
&scop ptype logical
&scop prop-value no
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.


      v-prop-code = "{&bef-attr-prt-obj_in-docpr},{&bef-attr-prt-obj_outappr},{&bef-attr-prt-obj_outdate},{&bef-attr-prt-obj_outdisc},{&bef-attr-prt-obj_outegrp},{&bef-attr-prt-obj_outhold},{&bef-attr-prt-obj_outnum},{&bef-attr-prt-obj_outobj},{&bef-attr-prt-obj_outprim},{&bef-attr-prt-obj_outrubl},{&bef-attr-prt-obj_outssdoc},{&bef-attr-prt-obj_outsubs},{&bef-attr-prt-obj_outt12},{&bef-attr-prt-obj_outares},{&bef-attr-prt-obj_outsend},{&bef-attr-prt-obj_outasend}" .
&scop ptype character
&scop prop-value ''
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-prt-obj_outR},{&bef-attr-prt-obj_outB},{&bef-attr-prt-obj_outogr}" .
&scop ptype character
&scop prop-value 'no_print'
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-prt-obj_outc}" .
&scop ptype character
&scop prop-value 'clad_doc'
&scop prop-code v-prop-code
      do v-ii = 1 to num-entries(v-prop-code):
      {&create-thbj-attr}.
      end.

    end. /*when {&attr-prt-obj} then do:*/


    when {&attr-report-glob} then do:
      v-prop-code = "{&bef-attr-report-glob_actuate}" .
&scop ptype logical
&scop prop-value no
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-report-glob_rep-shift-format}" .
&scop ptype integer
&scop prop-value 1
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-report-glob_rep-password}" .
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
            
      v-prop-code = "{&bef-attr-report-glob_rep-excel}" .
&scop ptype logical
&scop prop-value yes
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-report-glob_sum-from},{&bef-attr-report-glob_sum-step},{&bef-attr-report-glob_sum-to}" .
&scop ptype decimal
&scop prop-value 0.0
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-report-glob_alcgrpgd}" .
&scop ptype integer
&scop prop-value 0
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-report-glob_ardecldt}" .
&scop ptype date
&scop prop-value 01/01/2006
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-report-glob_rep-sort},{&bef-attr-report-glob_sumvals},{&bef-attr-report-glob_cplot}" .
&scop ptype character
&scop prop-value ''
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-report-glob_cdens}" .
&scop ptype integer
&scop prop-value 0
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      
    end.

    when {&attr-report-firm} then do:
      v-prop-code = "{&bef-attr-report-firm_xl-delim}" .
&scop ptype character
&scop prop-value ''
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

    end.

    when {&attr-report-obj} then do:
      v-prop-code = "{&bef-attr-report-obj_prt-z-no}" .
&scop ptype logical
&scop prop-value no
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.


      v-prop-code = "{&bef-attr-report-obj_shft-qty}" .
&scop ptype character
&scop prop-value ''
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.

    when {&attr-rezerv-obj} then do:
      v-prop-code = "{&bef-attr-rezerv-obj_prcshfc0},{&bef-attr-rezerv-obj_prdocfc0},{&bef-attr-rezerv-obj_prsalpr}" .
&scop ptype logical
&scop prop-value no
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-rezerv-obj_invngbeg},{&bef-attr-rezerv-obj_invngend}" .
&scop ptype date
&scop prop-value ?
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-rezerv-obj_negmanuf},{&bef-attr-rezerv-obj_negparts},{&bef-attr-rezerv-obj_prcshrs0},{&bef-attr-rezerv-obj_prcshrs1},{&bef-attr-rezerv-obj_prdocrs0},{&bef-attr-rezerv-obj_prdocrs1}" .
&scop ptype character
&scop prop-value ''
&scop prop-code entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.


    when {&attr-rezerv-global} then do:
      v-prop-code = "{&bef-attr-rezerv-global_parts-bc}" .
&scop ptype logical
&scop prop-value no
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.


    when {&attr-fin-plan} then do:
      v-prop-code =  "{&bef-attr-fin-plan_fin-ostatok-start},{&bef-attr-fin-plan_fin-plan-pri},{&bef-attr-fin-plan_fin-proch},{&bef-attr-fin-plan_fin-proch-ras}":U.

&scop ptype decimal
&scop prop-value  0.0
&scop prop-code  entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.
    when {&attr-rt-trn-doc} then do:
      v-prop-code =  "{&bef-attr-rt-trn-doc_wrkr},{&bef-attr-rt-trn-doc_agnt},{&bef-attr-rt-trn-doc_boss}":U.

&scop ptype integer
&scop prop-value  0
&scop prop-code  entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.
    when {&attr-gds-ref} then do:
      v-prop-code = "{&bef-attr-gds-ref_shema-foto}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype integer
&scop prop-value 1
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-gds-ref_dfltggrp}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype integer
&scop prop-value -1
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-gds-ref_gds-copy}".
&scop ptype character
&scop prop-value '0,0,0,0,0,0,0'
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-gds-ref_dif-nam1}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype logical
&scop prop-value yes
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-gds-ref_dif-nam2},{&bef-attr-gds-ref_dpl-off},{&bef-attr-gds-ref_dif-pdbc},{&bef-attr-gds-ref_pbc-veto},{&bef-attr-gds-ref_tnvedimp},{&bef-attr-gds-ref_unq-artc},{&bef-attr-gds-ref_is-scgb}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-gds-ref_gdsscrvw}".
&scop ptype character
&scop prop-value 'goods.grp-name,goods.engl-name,goods.#prod-name,goods.alpha1,goods.sert,goods.destin,goods.ps,goods.user-rule,goods.struct,goods.deadline,gds-obj.in-date,gds-obj.foto'
&scop prop-code v-prop-code

      {&create-thbj-attr}.
    end.
    when {&attr-gds-ref_obj} then do:
      v-prop-code = "{&bef-attr-gds-ref_obj_dfltggrp}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype integer
&scop prop-value -1
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-gds-ref_obj_chg-bcod}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-gds-ref_obj_gdsscrvw}".
&scop ptype character
&scop prop-value 'goods.lgrp-name,goods.engl-name,goods.#prod-name,goods.alpha1,goods.sert,goods.destin,goods.ps,goods.user-rule,goods.struct,goods.deadline,gds-obj.in-date,goods.#foto'
&scop prop-code v-prop-code

      {&create-thbj-attr}.
      v-prop-code = "{&bef-attr-gds-ref_obj_image-dir}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype character
&scop prop-value ''
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
    end.
    when {&attr-dc-ref} then do:
      v-prop-code = "{&bef-attr-dc-ref_l-zeros},{&bef-attr-dc-ref_l-mask}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
    end.
    when {&attr-cli-all} then do:
      v-prop-code = "{&bef-attr-cli-all_inn-uniq}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype integer
&scop prop-value 0
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-cli-all_nocorinn}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
    end.
    when {&attr-cashpays} then do:
      v-prop-code = "{&bef-attr-cashpays_cpgrpnam}".
&scop ptype character
&scop prop-value 'НАЛИЧНЫЕ,1,КАРТЫ,2,ТАЛОНЫ,3,ВЕДОМОСТИ,4'
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.
    when  {&attr-wthdoc} then do:
      v-prop-code = "{&bef-attr-wthdoc_prsdoc}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-wthdoc_clsfact}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
    end. /*wth-doc*/
    when  {&attr-wthdoc_obj} then do:
      v-prop-code = "{&bef-attr-wthdoc_obj_stfactpref}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype character
&scop prop-value ''
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-wthdoc_obj_rangerule}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype integer
&scop prop-value 0
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-wthdoc_obj_clsfact}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-wthdoc_obj_inobjauto}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-wthdoc_obj_inwpcode}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype integer
&scop prop-value 0
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
       v-prop-code = "{&bef-attr-wthdoc_obj_numsfact}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype integer
&scop prop-value 0
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-wthdoc_obj_prsdoc}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.

    end.
    when {&attr-rum} then do:
      v-prop-code = "{&bef-attr-rum_goods},{&bef-attr-rum_clients},{&bef-attr-rum_gds-grp},{&bef-attr-rum_cli-grp},{&bef-attr-rum_edoc},{&bef-attr-rum_thref},{&bef-attr-rum_pdf},{&bef-attr-rum_rep},{&bef-attr-rum_ord},{&bef-attr-rum_cmb},{&bef-attr-rum_fdoc}".
&scop ptype LOGICAL
&scop prop-value NO
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-rum_chk-doc_ibs-th},{&bef-attr-rum_chk-doc_ibs-th-MOB}".
&scop ptype LOGICAL
&scop prop-value yes
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

    end.
    when {&attr-rum_obj} then do:
      v-prop-code = "{&bef-attr-rum_chk-doc_ibs-th},{&bef-attr-rum_chk-doc_ibs-th-MOB},{&bef-attr-rum_obj_rep}".
&scop ptype LOGICAL
&scop prop-value NO
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.
    when  {&attr-wthrep} then do:
      v-prop-code = "{&bef-attr-wthrep_cligrplist}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype character
&scop prop-value ''
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-wthrep_docdstnws}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.

    end.
    when {&attr-easyfuel} then do:
      v-prop-code = "{&bef-attr-easyfuel_master-key}".
&scop ptype character
&scop prop-value ''
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.
    when {&attr-cd-type-ibs-th} then do:
      v-prop-code = "{&bef-attr-cd-type-ibs-th_ibs-th_main},{&bef-attr-cd-type-ibs-th_ibs-th_devices},{&bef-attr-cd-type-ibs-th_ibs-th_fisreg},{&bef-attr-cd-type-ibs-th_ibs-th_rec-print},{&bef-attr-cd-type-ibs-th_ibs-th_interface}".
&scop ptype void
&scop prop-value ''
&scop prop-code entry(v-ii, v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
        /*спускаемся на уровень вниз*/
        run adm/shattri.p (
                      input "init":U
                    , input p-obj-type
                    , input p-obj-code
                    , input entry(v-ii, v-prop-code)
                    , input ''
                    , output v2-value-character
                    , output v2-value-date
                    , output v2-value-decimal
                    , output v2-value-integer
                    , output v2-value-logical
                    , output v2-param-type
                    , INPUT-OUTPUT table  tt0-thbj-attr
                    ) no-error .
        if error-status:error then do:
          undo, return error substitute("&1&2&3"
                                        , error-status:get-message(1)
                                        , {&new-line}
                                        , return-value   ).
        end.
      end.
    end.
    when {&attr-cd-type-ibs-th_ibs-th_main} then do:
      v-prop-code = "{&bef-attr-cd-type-ibs-th_ibs-th_main_cash-shift},{&bef-attr-cd-type-ibs-th_ibs-th_main_nalc}," +
                    "{&bef-attr-cd-type-ibs-th_ibs-th_main_salesman-mandatory},{&bef-attr-cd-type-ibs-th_ibs-th_main_manual-discnt}," +
                    "{&bef-attr-cd-type-ibs-th_ibs-th_main_log-level},{&bef-attr-cd-type-ibs-th_ibs-th_main_clear-cash-counter},{&bef-attr-cd-type-ibs-th_ibs-th_main_qnty-change}".
&scop ptype integer
&scop prop-value 0
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.
    when {&attr-cd-type-ibs-th_ibs-th_devices} then do:

    /*'{&bef-attr-cd-type-IBS-TH_devices_cash-drawer-plug-port}':U   ??????*/

      v-prop-code = "{&bef-attr-cd-type-ibs-th_ibs-th_devices_cash-drawer-limit}".
&scop ptype decimal
&scop prop-value 1000000.00
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-cd-type-ibs-th_ibs-th_devices_cash-drawer-plug}," +
                    "{&bef-attr-cd-type-IBS-TH_ibs-th_devices_cash-drawer-plug-imp}," +
                    "{&bef-attr-cd-type-IBS-TH_ibs-th_devices_card-reader-plug}," +
                    "{&bef-attr-cd-type-ibs-th_ibs-th_devices_cash-drawer-open}," +
                    "{&bef-attr-cd-type-IBS-TH_ibs-th_devices_cash-drawer-plug-port}".
&scop ptype integer
&scop prop-value 1
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-cd-type-ibs-th_ibs-th_devices_cash-drawer-plug-type}," +
                    "{&bef-attr-cd-type-IBS-TH_ibs-th_devices_customer-display-plug}".
&scop ptype integer
&scop prop-value 0
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-cd-type-ibs-th_ibs-th_devices_customer-display-adv}".
&scop ptype character
&scop prop-value fill('_', 20) + ~{&delim-par~} + fill('_', 20)
&scop prop-code entry(v-ii, v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-cd-type-IBS-TH_ibs-th_devices_keyboard-type}".
&scop ptype character
&scop prop-value ''
&scop prop-code  v-prop-code
      {&create-thbj-attr}.

      v-prop-code = "{&bef-attr-cd-type-IBS-TH_ibs-th_devices_keyboard-layout-id}".
&scop ptype character
&scop prop-value ''
&scop prop-code  v-prop-code
      {&create-thbj-attr}.

      v-prop-code = "{&bef-attr-cd-type-IBS-TH_ibs-th_devices_cashless-system}".
&scop ptype character
&scop prop-value ~{&cd-cashless-sberbank~}
&scop prop-code v-prop-code
      {&create-thbj-attr}.

      v-prop-code = "{&bef-attr-cd-type-IBS-TH_ibs-th_devices_cctv-system},{&bef-attr-cd-type-IBS-TH_ibs-th_devices_cctv-system-address}".
&scop ptype character
&scop prop-value ''
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-cd-type-IBS-TH_ibs-th_devices_customer-display-type}".
&scop ptype character
&scop prop-value ''
&scop prop-code  v-prop-code
      {&create-thbj-attr}.

      v-prop-code = "{&bef-attr-cd-type-IBS-TH_ibs-th_devices_customer-display-port}".
&scop ptype character
&scop prop-value ''
&scop prop-code  v-prop-code
      {&create-thbj-attr}.

    end.
    when {&attr-cd-type-ibs-th_ibs-th_fisreg} then do:
      v-prop-code = "{&bef-attr-cd-type-ibs-th_ibs-th_fisreg_cash-drawer-level}".
&scop ptype integer
&scop prop-value 1
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-cd-type-ibs-th_ibs-th_fisreg_cash-pay-list}".

&scop ptype character
&scop prop-value ('2=' + {&delim-par} + '3=' + {&delim-par} + '4=')
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-cd-type-IBS-TH_ibs-th_fisreg_pay-names}".

&scop ptype character
&scop prop-value  'КУПОНОМ' + {&delim-par} + 'ДОП.ВИД ОПЛАТЫ' + {&delim-par} + 'ПЛАТ.КАРТОЙ'
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-cd-type-IBS-TH_ibs-th_fisreg_cutter}".
&scop ptype integer
&scop prop-value 0
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-cd-type-IBS-TH_ibs-th_fisreg_com-port}".
&scop ptype character
&scop prop-value 'COM1'
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.


    end.
    when {&attr-cd-type-ibs-th_ibs-th_rec-print} then do:
      v-prop-code = "{&bef-attr-cd-type-ibs-th_ibs-th_rec-print_max-netto}".
&scop ptype decimal
&scop prop-value 1000000.00
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-cd-type-ibs-th_ibs-th_rec-print_advert-text}".
&scop ptype character
&scop prop-value right-trim(fill((fill('-',40) + {&delim-par}), 3), {&delim-par})
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-cd-type-ibs-th_ibs-th_rec-print_cliche-lines}".
&scop ptype character
&scop prop-value right-trim(fill((fill('-',40) + {&delim-par}), 6), {&delim-par})

&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-cd-type-ibs-th_ibs-th_rec-print_print-good-code}".
&scop ptype integer
&scop prop-value 1
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-cd-type-ibs-th_ibs-th_rec-print_rmethod-type}".
&scop ptype character
&scop prop-value "MROUND"
&scop prop-code entry(v-ii, v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-cd-type-ibs-th_ibs-th_rec-print_rmethod-coeff}".
&scop ptype decimal
&scop prop-value 2
&scop prop-code entry(v-ii, v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-cd-type-ibs-th_ibs-th_rec-print_rcpt-ord-slip-print},{&bef-attr-cd-type-ibs-th_ibs-th_rec-print_rcpt-ord-alt-print}".
&scop ptype integer
&scop prop-value 0
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

    end.
    when {&attr-cd-type-ibs-th_ibs-th_interface} then do:
      v-prop-code = "{&bef-attr-cd-type-IBS-TH_ibs-th_interface_screen-type}".
&scop ptype character
&scop prop-value ~{&layout-device-Screen~}
&scop prop-code v-prop-code

      {&create-thbj-attr}.

      v-prop-code = "{&bef-attr-cd-type-IBS-TH_ibs-th_interface_screen-layout-id}".
      define buffer buf_layout for ub.layout.
      find first buf_layout no-lock where
                buf_layout.device-type = {&layout-device-Screen}
            and buf_layout.layout-type = {&th-pos-screen}
            and buf_layout.is-default = integer({&layout-mandatory}) no-error.
      if not available buf_layout then do:
        undo, return error substitute("Отсутствует обязательная раскладка IBS TH POS для устройства &1"
                                      , {&th-pos-screen}   ).
      end.
&scop ptype character
&scop prop-value buf_layout.layout-id
&scop prop-code v-prop-code

      {&create-thbj-attr}.

    end.
    when {&attr-cd-type-ibs-th-mob} then do:
      v-prop-code = "{&bef-attr-cd-type-ibs-th-mob_ibs-th-mob_main},{&bef-attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print}".
&scop ptype void
&scop prop-value ''
&scop prop-code entry(v-ii, v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
        /*спускаемся на уровень вниз*/
        run adm/shattri.p (
                      input "init":U
                    , input p-obj-type
                    , input p-obj-code
                    , input entry(v-ii, v-prop-code)
                    , input ''
                    , output v2-value-character
                    , output v2-value-date
                    , output v2-value-decimal
                    , output v2-value-integer
                    , output v2-value-logical
                    , output v2-param-type
                    , INPUT-OUTPUT table  tt0-thbj-attr
                    ) no-error .
        if error-status:error then do:
          undo, return error substitute("&1&2&3"
                                        , error-status:get-message(1)
                                        , {&new-line}
                                        , return-value   ).
        end.
      end.
    end.
    when {&attr-cd-type-ibs-th-mob_ibs-th-mob_main} then do:
      v-prop-code = "{&bef-attr-cd-type-ibs-th-mob_ibs-th-mob_main_salesman-mandatory}".
&scop ptype integer
&scop prop-value 0
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-cd-type-ibs-th-mob_ibs-th-mob_main_pos-type-for-discnt}".
&scop ptype character
&scop prop-value ~{&cd-type-ibs-th-mob~}
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.
    when {&attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print} then do:

      v-prop-code = "{&bef-attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print_rcpt-ord-slip-print},{&bef-attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print_rcpt-ord-alt-print}".
&scop ptype integer
&scop prop-value 0
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.
    when {&attr-images} then do:
      v-prop-code = "{&bef-attr-images_imgorder}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype character
&scop prop-value 'jpg,gif,tif,bmp,png,psd,ico,eps,pcx,pcd,mac,wmf,wpg,msp,cal,clp,cut,dcx,dib,ica,iff,img,jbig,lv,pct,ras,tga,wbmp,xbm,xpm,xwd'
&scop prop-code v-prop-code
        {&create-thbj-attr}.
      end.
    end.
    when {&attr-code-range} then do:
      v-prop-code = "{&bef-attr-code-range_cdrgbcgb},{&bef-attr-code-range_cdrgdcgb},{&bef-attr-code-range_cdrgcagb}".
&scop ptype integer
&scop prop-value 100000
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-code-range_cdrgctgb}".
&scop ptype integer
&scop prop-value 2000
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-code-range_cdrgdrgb},{&bef-attr-code-range_cdrgscgb},{&bef-attr-code-range_cdrgsclc},{&bef-attr-code-range_cdrgsslc},{&bef-attr-code-range_cdrgssgb},{&bef-attr-code-range_cdrgpglc},{&bef-attr-code-range_cdrgfdgb}".
&scop ptype integer
&scop prop-value 1000
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-code-range_cdrgfmgb}".
&scop ptype integer
&scop prop-value 10000
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-code-range_cdrgpngb}".
&scop ptype integer
&scop prop-value 5000
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.
    when {&attr-bge-export} then do:
      v-prop-code = "{&bef-attr-bge-export_bgeclall},"  +
                    "{&bef-attr-bge-export_bgedcard},"  +
                    "{&bef-attr-bge-export_bgedict}"    .
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-bge-export_bgeflnm},"   +
                    "{&bef-attr-bge-export_bgecliiv}"   .

&scop ptype character
&scop prop-value '':U
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-bge-export_bgeflold}"   .

&scop ptype character
&scop prop-value 'old':U
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-bge-export_bgefmt}" .

&scop ptype character
&scop prop-value 'xml':U
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-bge-export_bgeshift}" .

&scop ptype character
&scop prop-value 'no-distinct':U
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.
    when {&attr-auto-task} then do:
      v-prop-code = "{&bef-attr-auto-task_send-msg-to-email}".
&scop ptype character
&scop prop-value '':U
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
       v-prop-code = "{&bef-attr-auto-task_user-list}".
&scop ptype character
&scop prop-value 'nws':U
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
            v-prop-code = "{&bef-attr-auto-task_maxColMarks}".
&scop ptype integer
&scop prop-value 1000
&scop prop-code  entry(v-ii,v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.            
    end.
    when {&attr-wnd-size} then do:
      v-prop-code = "{&bef-attr-wnd-size_max},{&bef-attr-wnd-size_store}"  .
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

    end.
    when {&attr-obj-date} then do:
      v-prop-code = "{&bef-attr-obj-date_autodate},{&bef-attr-obj-date_autodtsh},{&bef-attr-obj-date_newordsh}"  .
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-obj-date_diffshft}".
&scop ptype integer
&scop prop-value 3
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-obj-date_difftime}".
&scop ptype integer
&scop prop-value ?
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

    end.


    when  {&attr-mercur} then do:
      v-prop-code = "{&bef-attr-mercur_apikey}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype character
&scop prop-value ''
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-mercur_login}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype character
&scop prop-value ''
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-mercur_password}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype character
&scop prop-value ''
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-mercur_qrcode}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype character
&scop prop-value ''
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-mercur_server}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype integer
&scop prop-value ?
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-mercur_manual-vcd}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-mercur_close}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-mercur_login_is}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype character
&scop prop-value ''
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-mercur_type-connect}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype integer
&scop prop-value ?
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end. 
            v-prop-code = "{&bef-attr-mercur_proxy-addres}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype character
&scop prop-value ''
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-mercur_proxy-login}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype character
&scop prop-value ''
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-mercur_proxy-pswd}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype character
&scop prop-value ''
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-mercur_proxy-ssl}".
      do v-ii = 1 to num-entries(v-prop-code):
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)
        {&create-thbj-attr}.
      end.     
    end.

    when {&attr-fbrattr} then do:
      v-prop-code = "{&bef-attr-fbrattr_fbr-frcp},{&bef-attr-fbrattr_fbr-ioff},{&bef-attr-fbrattr_fbr-qntc},{&bef-attr-fbrattr_fbrrcpgb}"  .
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-fbrattr_fbrhstlv}".
&scop ptype integer
&scop prop-value 0
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-fbrattr_fbr-mrgn-min},{&bef-attr-fbrattr_fbr-mrgn-max}".
&scop ptype decimal
&scop prop-value 0.0
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
    end.
    when {&attr-petrol} then do:
      v-prop-code = "{&bef-attr-petrol_denstclc}".
&scop ptype character
&scop prop-value 'avrg-chk':U
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-petrol_inpptrl}".
&scop ptype character
&scop prop-value {&calc-petrol-volume-plus}
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-petrol_expptrl}".
&scop ptype character
&scop prop-value {&calc-petrol-volume}
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-petrol_invclipt}".
&scop ptype integer
&scop prop-value ?
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-petrol_algrvspt}".
&scop ptype integer
&scop prop-value 1
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-petrol_temp-for-pomi}".
&scop ptype integer
&scop prop-value 1
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-petrol_rvs-wt-email}".
&scop ptype character
&scop prop-value ""
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      v-prop-code = "{&bef-attr-petrol_algoincome}".
&scop ptype integer
&scop prop-value 1
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

    v-prop-code = "{&bef-attr-petrol_otkl-fact-volue}".
 &scop ptype decimal
 &scop prop-value 0
 &scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      
    v-prop-code = "{&bef-attr-petrol_otkl-temp}".
 &scop ptype decimal
 &scop prop-value 0
 &scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

    v-prop-code = "{&bef-attr-petrol_otkl-density}".
 &scop ptype character
 &scop prop-value ""
 &scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

    v-prop-code = "{&bef-attr-petrol_otkl-water}".
 &scop ptype decimal
 &scop prop-value 0
 &scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-petrol_mand-choice-autocar}".
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-petrol_CriticalDif}".
&scop ptype integer
&scop prop-value 0
&scop prop-code entry(v-ii, v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
          {&create-thbj-attr}.
      end.
      
      v-prop-code = "{&bef-attr-petrol_CriticalDifInLgas}".
&scop ptype decimal
&scop prop-value 0.65
&scop prop-code entry(v-ii, v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
          {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-petrol_autopump-izm},{&bef-attr-petrol_autopump},{&bef-attr-petrol_avtinvpm},{&bef-attr-petrol_rvsnmter},{&bef-attr-petrol_olddens},{&bef-attr-petrol_calc-free-vol},{&bef-attr-petrol_rvd-own-nb},{&bef-attr-petrol_trnscanqr},{&bef-attr-petrol_calc-free-vol-sug}".
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-petrol_trn-reas-sug}".
&scop ptype logical
&scop prop-value yes
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-petrol_dop-info}" .
&scop ptype character
&scop prop-value 'autoent,car-num,time-income,fio-driver,ptbobj,date-income':U
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      
      v-prop-code = "{&bef-attr-petrol_sec-fields}" .
&scop ptype character
&scop prop-value 'section-name,cli-qnty,doc-dens,group-np,list-tank,a-b-tarir,tank-density,tank-temp,dens-temp,place-si,place-si-temp,pasp-dens':U
&scop prop-code  entry(v-ii,v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
          
      v-prop-code = "{&bef-attr-petrol_Delta-mass-horiz}".
          &scop ptype character
          &scop prop-value ""
          &scop prop-code entry(v-ii, v-prop-code)
  
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-petrol_Delta-mass-vert}".
          &scop ptype character
          &scop prop-value ""
          &scop prop-code entry(v-ii, v-prop-code)
  
      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      
      v-prop-code = "{&bef-attr-petrol_qr-scan-time}".
&scop ptype integer
&scop prop-value 5000
&scop prop-code entry(v-ii, v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
          {&create-thbj-attr}.
      end.

      v-prop-code = "{&bef-attr-petrol_timeout-block-nozzle}".
&scop ptype integer
&scop prop-value 5
&scop prop-code entry(v-ii, v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
          {&create-thbj-attr}.
      end.
      
      v-prop-code = "{&bef-attr-petrol_block-nozzle}".
&scop ptype logical
&scop prop-value no
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.
      
      v-prop-code = "{&bef-attr-petrol_autopump-skip-time}".
      &scop ptype integer
      &scop prop-value 20.00
      &scop prop-code entry(v-ii, v-prop-code)
      do v-ii = 1 to num-entries(v-prop-code):
         {&create-thbj-attr}.
      end.

end.
        when {&attr-staff-options} then do:
            v-prop-code = "~
{&bef-attr-staff-options_noanshftstaff},~
{&bef-attr-staff-options_obyznumbukv},
{&bef-attr-staff-options_obyznumbukv}{&bef-staff-options_adm}".
        
        &scop ptype logical
        &scop prop-value no
        &scop prop-code entry(v-ii, v-prop-code)
        
              do v-ii = 1 to num-entries(v-prop-code):
                {&create-thbj-attr}.
              end.
            
            v-prop-code = "~
{&bef-attr-staff-options_minparol}{&bef-staff-options_adm},~
{&bef-attr-staff-options_minparol},~
{&bef-attr-staff-options_TimeAvail}{&bef-staff-options_adm},~
{&bef-attr-staff-options_TimeAvail},~
{&bef-attr-staff-options_TimeBlock}{&bef-staff-options_adm},~
{&bef-attr-staff-options_TimeBlock},~
{&bef-attr-staff-options_LastPaswd}{&bef-staff-options_adm},~
{&bef-attr-staff-options_LastPaswd}".
        &scop ptype integer
        &scop prop-value 0
        &scop prop-code entry(v-ii, v-prop-code)
        
                do v-ii = 1 to num-entries(v-prop-code):
                  {&create-thbj-attr}.
                end.
            end.
    when {&attr-izt-rul} then do:
      v-prop-code = "izt-rul".
&scop ptype character
&scop prop-value ~{&izt-rul-def~}
&scop prop-code entry(v-ii, v-prop-code)

      do v-ii = 1 to num-entries(v-prop-code):
        {&create-thbj-attr}.
      end.                  
    end.


  END CASE.
  run get-param-value in this-procedure no-error .
  if error-status:error then do:
    undo, return error substitute( "&1 &2 &3 &4"
                                  , vss-workfile
                                  , vss-revision
                                  , vss-description
                                  , return-value ).
  end.
end. /*doe*/

procedure get-param-value :
define variable v-prop-list as character no-undo .
define variable v-prop-type-list as character no-undo .
define variable v-prop-label-list as character no-undo .
define variable v-global as logical no-undo .
define variable v-host as logical no-undo .
define variable v-shop as logical no-undo .
define variable v-store as logical no-undo .
define variable v-db as logical   no-undo .
define variable v-region as logical   no-undo .

  do
  on error undo, return error
  :
    if p-param-code <> "":U then do:
      run thbjattr_code_reg  in this-procedure (
                                             input v-upper-param-code
                                            ,input '':U
                                            ,output attr-label
                                            ,output attr-user-can-edit
                                            ,output attr-output-display
                                            ,output attr-other
                                            ,output v-prop-list
                                            ,output v-prop-type-list
                                            ,output v-prop-label-list
                                            ,output v-global
                                            ,output v-host
                                            ,output v-shop
                                            ,output v-store
                                            ,output v-db
                                            ,output v-region
                                          ) no-error.
      if error-status:error then do:
        undo, return error substitute( "&1 &2 &3 &4"
                                      , vss-workfile
                                      , vss-revision
                                      , vss-description
                                      , return-value ).
      end.
      if lookup(p-param-code, v-prop-list) = 0 then do:
        return error substitute("Неверное имя параметра  &1", p-param-code).
      end.
    end. /*p-param-code <> "":U*/
  end. /*doe */

end procedure. /* get-param-value */


procedure check-param-value :
define variable v-prop-list as character no-undo .
define variable v-prop-type-list as character no-undo .
define variable v-prop-label-list as character no-undo .
define variable v-global as logical no-undo .
define variable v-host as logical no-undo .
define variable v-shop as logical no-undo .
define variable v-store as logical no-undo .
define variable v-db as logical   no-undo .
define variable v-region as logical   no-undo .
define variable v-jj as integer no-undo .
define buffer buf_tt0-thbj-attr for tt0-thbj-attr.
  do
  on error undo, return error
  :
    if attr-other = '':U then do:
      run thbjattr_code_reg  in this-procedure (
                                             input v-upper-param-code
                                            ,input '':U
                                            ,output attr-label
                                            ,output attr-user-can-edit
                                            ,output attr-output-display
                                            ,output attr-other
                                            ,output v-prop-list
                                            ,output v-prop-type-list
                                            ,output v-prop-label-list
                                            ,output v-global
                                            ,output v-host
                                            ,output v-shop
                                            ,output v-store
                                            ,output v-db
                                            ,output v-region
                                          ) no-error.
      if error-status:error then do:
        undo, return error substitute( "&1 &2 &3 &4"
                                      , vss-workfile
                                      , vss-revision
                                      , vss-description
                                      , return-value ).
      end.
      if p-obj-type = {&shop} and not v-shop
      or p-obj-type = {&stock} and not v-store
      or p-obj-type = {&cmp} and not v-host
      or p-obj-type = {&db} and not v-db
      or p-obj-type = {&region} and not v-region
      or p-obj-type = '' and not v-global then do:
        undo, return error substitute( "&1 &2 &3 &4 Не предусмотрено создание секции параметров &5 для объекта TH тип &6"
                                      , vss-workfile
                                      , vss-revision
                                      , vss-description
                                      , p-upper-param-code
                                      , p-obj-type
                                      , return-value ).
      end.
    end.

    for each tt0-thbj-attr
    by tt0-thbj-attr.prop-code
    :

      if tt0-thbj-attr.prop-code = '':U then next.
      if lookup(tt0-thbj-attr.prop-code, v-prop-list) = 0 then do:
        return error substitute("Неверное имя параметра  &1", tt0-thbj-attr.prop-code).
      end.
      if entry(lookup(tt0-thbj-attr.prop-code, v-prop-list), v-prop-type-list) <> tt0-thbj-attr.prop-value-type then do:
        return error substitute("Неверный тип параметра &1 - &2&3должен быть &4"
                                ,tt0-thbj-attr.prop-code
                                ,tt0-thbj-attr.prop-value-type
                                ,{&new-line}
                                ,entry(lookup(tt0-thbj-attr.prop-code, v-prop-list), v-prop-type-list)
                                ).
      end.


      if tt0-thbj-attr.obj-type <> p-obj-type
      or tt0-thbj-attr.obj-code <> p-obj-code then do:
        find first buf_tt0-thbj-attr where
                  buf_tt0-thbj-attr.prop-code = tt0-thbj-attr.prop-code
             and buf_tt0-thbj-attr.obj-type = p-obj-type
             and buf_tt0-thbj-attr.obj-code = p-obj-code no-error.
        if not available buf_tt0-thbj-attr then do:
          assign
          v-jj = v-jj + 1.
          .
        end.
        else do:
          delete tt0-thbj-attr.
        end.
      end.
      else do:
        v-jj = v-jj + 1.
      end.
    end.
    if num-entries(v-prop-list) <> v-jj then do:
      return error substitute("Неверное количество параметров в &1 - &2, должно быть &3"
                              , v-upper-param-code
                              , v-jj
                              , num-entries(v-prop-list)
                              ).
    end.
  end. /*doe */

end procedure. /* check-param-value */


procedure create-thbj-attr :
define input parameter p-prop-code as character no-undo .
define input parameter p-type as character no-undo .
define input parameter p-level-way as character no-undo .
define input parameter p-level-way-2 as character no-undo .
define input parameter p-up-way as character no-undo .
define output parameter v-to-create as logical no-undo .
define variable v-ii as integer no-undo .
define variable v-up-way as character no-undo .
define variable v-level-way as character no-undo .
define variable v-level-way-2 as character no-undo .
do
on error undo, return error
:
  v-to-create = no.
  _do:
  do v-ii = 1 to num-entries(p-up-way):
    assign
    v-up-way = entry(v-ii, p-up-way)
    v-level-way = entry(v-ii, p-level-way)
    v-level-way-2 = entry(v-ii, p-level-way-2)
    .
    find first stt0-thbj-attr where
              stt0-thbj-attr.prop-code = p-prop-code
          and stt0-thbj-attr.upper-prop-code = v-up-way
          and stt0-thbj-attr.obj-type = v-level-way
          and stt0-thbj-attr.obj-code = integer(v-level-way-2) no-error.
    if not available stt0-thbj-attr then do:
      if v-ii = 1 then do:
        v-to-create = yes.
      end.
    end.
    else do:
      if v-ii >= 1 then leave _do.
    end.
  end.
  if v-to-create then do:
    create tt0-thbj-attr.
    assign
    tt0-thbj-attr.obj-type = p-obj-type
    tt0-thbj-attr.obj-code = p-obj-code
    tt0-thbj-attr.upper-prop-code = p-upper-param-code
    tt0-thbj-attr.prop-code = p-prop-code
    tt0-thbj-attr.prop-value-type = p-type
    .
    if available stt0-thbj-attr then do:
      buffer-copy stt0-thbj-attr except obj-type obj-code upper-prop-code to tt0-thbj-attr.
    end.
  end.
end. /*doe*/
end procedure. /* create-thbj-attr */