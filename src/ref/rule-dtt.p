block-level on error undo, throw.
/*

$Revision: 993a05482fd8, 1104, rls $
$Author: ASMorozov $
$Date: Thu Dec 14 02:13:53 2017 +0300 $
$Workfile: rule-dtt.p $
$Archive: ref/rule-dtt.p $

Обработка сложных типов данных для параметров правил

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/16/07
Author: Bakhtadze Natalya
Creation date: 04/16/07

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-param-data-type as character no-undo .
define input parameter p-param-2-data-type as character no-undo .
define input parameter p-param-3-data-type as character no-undo .
define input parameter p-p-index as integer no-undo .
define input-output parameter p-value-character as character no-undo .
define input-output parameter p-value-data as date no-undo .
define input-output parameter p-value-decimal as decimal no-undo .
define input-output parameter p-value-integer as integer no-undo .
define input-output parameter p-value-logical as integer no-undo .
define output parameter p-ok as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: 993a05482fd8, 1104, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:53 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rule-dtt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/rule-dtt.p $":U .
define variable vss-description as character no-undo init "Обработка сложных типов данных для параметров правил".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/library.i  }
{ gbl/key-rec.i }
{ gbl/getcntxt.i def }
define variable v-rid-list as character no-undo .
define variable v-ok as logical no-undo .
define variable v-cli-type as character no-undo .
define variable v-cli-code as integer no-undo .
define variable v-mess as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define variable glog as logical no-undo .
define variable v-chk-type as character no-undo .
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable v-kk as integer no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
    if lookup(p-mode, {&verify} + {&comma-char} + {&update}) = 0 then do:
      message
      "Неправильное значение параметра p-mode" p-mode
      view-as alert-box error .
      undo, return error .
    end.
    if p-p-index = 0
    and (lookup("LIST", p-param-3-data-type) > 0
         or
         lookup("SORTED-LIST", p-param-3-data-type) > 0
         )
    then do:
       assign
       p-ok = yes.
       return '':U.
    end.
    if p-mode <> {&verify} then do:
      { gbl/getcntxt.i get }
    end.
    if p-param-2-data-type = {&table_shop}  then do:
      define buffer buf_shop for ub.shop.
      find first buf_shop no-lock where
                buf_shop.obj-code = p-value-integer no-error.
      if available buf_shop then do:
        if p-mode = {&verify} then do:
          p-ok = yes.
          return '':U.
        end.
        v-rid-list = string(recid(buf_shop)).
      end.
      else do:
        if p-mode = {&verify} then do:
          undo, return error substitute("Нет магазина с кодом &1", p-value-integer).
        end.
        v-rid-list = '':U.
      end.
      run adm/shops.w ( input parparentproc
                      , input "b-sel"
                      , input-output v-rid-list
                      , no).
      if v-rid-list = '':U
      or v-rid-list = string(recid(buf_shop)) then return error.
      find first buf_shop no-lock where
                recid(buf_shop) = integer(v-rid-list) no-error.
      if not available buf_shop then return error.
      assign
      p-value-integer = buf_shop.obj-code
      p-ok = yes
      .
    end.
if entry(1, p-param-2-data-type, "_") = {&table_sysconf} then do:
      define buffer buf_sysconf for ub.sysconf.
      find first buf_sysconf no-lock
                        where buf_sysconf.host-code = p-value-integer no-error.
      if available buf_sysconf then do:
        if p-mode = {&verify} then do:
          p-ok = yes.
          return '':U.
        end.
        v-rid-list = string(recid(buf_sysconf)).
      end.
      else do:
        if p-mode = {&verify} then do:
          if num-entries(p-param-2-data-type, "_") > 1
          and entry(2, p-param-2-data-type, "_") = "0" then do:
            p-ok = yes.
            return '':U.
          end.
          undo, return error substitute("Нет фирмы с кодом &1", p-value-integer).
        end.
        v-rid-list = '':U.
      end.
      define variable v-firm-code as integer no-undo .
      run adm/sconfs.w (
            input parParentProc
          , input "b-sel":U
          , input no
          , input 0
          , output v-firm-code
          , input-output v-rid-list
      ) no-error.
      if v-rid-list = '':U
      or v-rid-list = string(recid(buf_sysconf)) then do:
        if num-entries(p-param-2-data-type, "_") > 1
        and entry(2, p-param-2-data-type, "_") = "0" then do:
          assign
          p-value-integer = 0
          p-ok = yes
          .
          return ''.
        end.
        return error.
      end.
      find first buf_sysconf no-lock where
                recid(buf_sysconf) = integer(v-rid-list) no-error.
      if not available buf_sysconf then return error.
      assign
      p-value-integer = buf_sysconf.host-code
      p-ok = yes
      .
    end.
    if p-param-2-data-type = {&table_clients}
    or p-param-2-data-type = {&table_clients}  + "_null"
    or p-param-2-data-type = "objects"
    then do:
      define buffer buf_clients for ub.clients.
      find first buf_clients no-lock where
                buf_clients.obj-type = substring(p-value-character, 1, 3)
            and buf_clients.obj-code = integer(substring(p-value-character, 4)) no-error.
      if available buf_clients then do:
        if p-mode = {&verify} then do:
          p-ok = yes.
          return '':U.
        end.
        v-rid-list = string(recid(buf_clients)).
      end.
      else do:
        if p-mode = {&verify} then do:
          if p-param-2-data-type = {&table_clients}  + "_null"
          and p-value-character = "0" then do:
            p-ok = yes.
            return '':U.
          end.
          else do:
            undo, return error substitute("Нет клиента &1", p-value-character).
          end.
        end.
        v-rid-list = '':U.
      end.
      run ref/selcli.p (
                        input  parparentproc
                       ,input ? /* h-call-prog  */
                       ,input (if p-param-2-data-type = "objects"
                               then {&g___object}
                               else {&prs}) /*p-client-types */
                       ,input (if p-param-2-data-type = "objects"
                               then yes
                               else no) /*lock-cli-type*/
                       ,output v-ok
                       ,output v-cli-type
                       ,output v-cli-code ) no-error.
      if error-status:error then return error.
      if v-ok = no then do:
        if p-param-2-data-type = {&table_clients}  + "_null"
        then do:
          message
          "Вы хотите оставить ПУСТОЕ значение параметра?"
          view-as alert-box question buttons yes-no update glog.
          if glog then do:
              assign
              p-value-character = "0"
              p-ok = yes
              .
              return ''.
           end.
           else do:
             return error .
           end.
        end.
        else do:
          return error.
        end.
      end.
      assign
      p-value-character = v-cli-type + string(v-cli-code)
      p-ok = yes
      .
    end.
    if p-param-2-data-type = {&table_cli-grp}  then do:
      define buffer buf_cli-grp for ub.cli-grp.
      find first buf_cli-grp no-lock where
                buf_cli-grp.node-code = p-value-integer no-error.
      if available buf_cli-grp
      and not can-find(ub.cli-grp where ub.cli-grp.upper-code = buf_cli-grp.node-code) then do:
        if p-mode = {&verify} then do:
          p-ok = yes.
          return '':U.
        end.
        v-rid-list = string(recid(buf_cli-grp)).
      end.
      else do:
        if p-mode = {&verify} then do:
          undo, return error substitute("Нет группы клиентов с вн.кодом группы &1 или эта группа НЕтерминальная", p-value-integer).
        end.
        v-rid-list = '':U.
      end.
      run ref/cli-grps.w ( input parparentproc
                        ,input ({&g#term} + ",b-sel")
                        ,input-output v-rid-list ).
      if v-rid-list = '':U then return error.
      find first buf_cli-grp no-lock where
                recid(buf_cli-grp) = integer(v-rid-list) no-error.
      if not available buf_cli-grp then return error.
      assign
      p-value-integer = buf_cli-grp.node-code
      p-ok = yes
      .
    end.
    if p-param-2-data-type = {&r-b} then do:
      if p-value-character = {&r-b-rubl}
      or p-value-character = {&r-b-base} then do:
        if p-mode = {&verify} then do:
          p-ok = yes.
          return '':U.
        end.
      end.
      else do:
        if p-mode = {&verify} then do:
          undo, return error substitute("Неверное значение типа валюты продаж  = &1", p-value-character).
        end.
      end.
      run gbl/s-r-b.w ( input "Выбор типа валюты накоплений"
                      ,input-output p-value-character
                      ,output v-ok ) no-error.
      if not v-ok then return error.
      assign
      p-value-character = p-value-character
      p-ok = yes
      .
    end.
    if entry(1, p-param-2-data-type, "_") = {&period-type} then do:
      if lookup(p-value-character, {&period-types}) > 0 then do:
        if p-mode = {&verify} then do:
          p-ok = yes.
          return '':U.
        end.
      end.
      else do:
        if p-mode = {&verify} then do:
          undo, return error substitute("Неверное значение типа периода  = &1", p-value-character).
        end.
      end.
      run gbl/period-t.w ( input "Выбор типа периода"
                       ,input (if num-entries(p-param-2-data-type, "_") > 1
                         then entry(2, p-param-2-data-type, "_")
                         else '')
                      ,input-output p-value-character
                      ,output v-ok ) no-error.
      if not v-ok then return error.
      assign
      p-value-character = p-value-character
      p-ok = yes
      .
    end.
    if entry(1, p-param-2-data-type, "_") = {&output-type} then do:
      v-kk = 0.
      _ii:
      do v-ii = 1 to num-entries(p-value-character):
        do v-jj = 1 to num-entries(entry(2, p-param-2-data-type, "_")):
           if lookup(entry(v-ii, p-value-character)
                   , entry(v-jj, entry(2, p-param-2-data-type, "_"))) > 0 then do:
             v-kk = v-kk + 1.
             next _ii.
           end.
        end.
      end.
      if v-kk >= num-entries(p-value-character) then do:
        if p-mode = {&verify} then do:
          p-ok = yes.
          return '':U.
        end.
      end.
      else do:
        if p-mode = {&verify} then do:
          undo, return error substitute("Неверное значение типа периода  = &1", p-value-character).
        end.
      end.
      run gbl/output-t.w ( input "Выбор типа периода"
                       ,input (if num-entries(p-param-2-data-type, "_") > 1
                         then entry(2, p-param-2-data-type, "_")
                         else '')
                      ,input-output p-value-character
                      ,output v-ok ) no-error.
      if not v-ok then return error.
      assign
      p-value-character = p-value-character
      p-ok = yes
      .
    end.
    if p-param-2-data-type begins ({&table_dis-rule} + "_") then do:
      define variable v-sts as integer no-undo .
      define variable v-templ-rl-root as integer no-undo .
      define buffer buf_dis-rule for ub.dis-rule.
      v-templ-rl-root = integer(entry(2, p-param-2-data-type, "_")).
      find first buf_dis-rule no-lock where
                buf_dis-rule.rule-num = p-value-integer   no-error.
      if available buf_dis-rule then do:
        if p-mode = {&verify} then do:
          p-ok = yes.
          return '':U.
        end.
        v-rid-list = string(recid(buf_dis-rule)).
      end.
      else do:
        if p-mode = {&verify} then do:
          undo, return error substitute("Нет правила скидок с кодом &1", p-value-integer).
        end.
        v-rid-list = '':U.
      end.
      run ref/dis-ruls.w (   input  parparentproc
                            ,input 0 /*p-host-code*/
                            ,input '':U /*p-curr-obj-type*/
                            ,input 0 /*p-curr-obj-code*/
                            ,input "b-sel,b-add"
                            ,input "upper-rule-num"
                            ,input v-templ-rl-root
                            ,input ? /*p-time-templ-rl-root*/
                            ,input 0 /*p-b-code*/
                            ,input-output v-sts /*p-sts*/
                            ,input-OUTPUT v-rid-list) NO-ERROR.
      if v-rid-list <> '':U then do:
        find first buf_dis-rule no-lock where
                  recid(buf_dis-rule) = integer(v-rid-list) no-error.
        if not available buf_dis-rule then return error substitute("Не найдено правило скидки c recid &1", v-rid-list).
        assign
        p-value-integer = buf_dis-rule.rule-num
        p-ok = yes
        .
      end.
    end.
    if p-param-2-data-type begins ({&table_prop-ref} + "_") then do:
      define variable v-dtm-code as integer no-undo init -1.
      define buffer buf_prop-ref for ub.prop-ref.
      assign
      v-dtm-code = integer(entry(2, p-param-2-data-type, "_"))
      no-error
      .
      find first buf_prop-ref no-lock where
          buf_prop-ref.dtm-code = v-dtm-code
      and buf_prop-ref.sum-id = p-value-character no-error .
      if available buf_prop-ref then do:
        if p-mode = {&verify} then do:
          p-ok = yes.
          return '':U.
        end.
        assign
        v-rid-list = string(recid(buf_prop-ref)).
      end.
      else do:
        if p-mode = {&verify} then do:
          undo, return error substitute("Нет среза с идентификатором &1 для объекта-операнда &2", p-value-character, v-dtm-code).
        end.
        v-rid-list = '':U.
      end.
      run ref/proprefs.w (   input  parparentproc
                            ,input "b-sel,b-add"
                            ,input "dtm-code"
                            ,input  v-dtm-code
                            ,input '':U
                            ,input '':U /*p-call-id*/
                            ,input-OUTPUT v-rid-list) NO-ERROR.
      if v-rid-list <> '':U then do:
        find first buf_prop-ref no-lock where
                  recid(buf_prop-ref) = integer(v-rid-list) no-error.
        if not available buf_prop-ref then return error substitute("Не найден Итог/срез c recid &1", v-rid-list).
        assign
        p-value-character = buf_prop-ref.sum-id
        p-ok = yes
        .
      end.
    end.
    if p-param-2-data-type begins {&table_ext-system} then do:
      define variable v-uniq-key-rec as character no-undo .
      define variable v-tbl-row as rowid no-undo .
      define variable v-tbl-name as character no-undo .
      define buffer buf_ext-system for ub.ext-system.
      if p-value-integer <> 0 then do:
        find first buf_ext-system no-lock where
                  buf_ext-system.db-num = 0
              and buf_ext-system.esys-id = p-value-integer no-error.
        if available buf_ext-system
        and buf_ext-system.esys-type > integer({&openxml-type-ordinal}) /*спец*/
        and (num-entries(p-param-2-data-type, "_") = 1
             or
             buf_ext-system.esys-type = integer(entry(2,  p-param-2-data-type, "_"))
             )
        then do:
          if p-mode = {&verify} then do:
            p-ok = yes.
            return '':U.
          end.
          run gen-key-rec in this-procedure (
                                              input {&table_ext-system}
                                              ,input buffer buf_ext-system:handle
                                              ,output v-uniq-key-rec) .
        end. /*if available buf_ext-system*/
        else do:
          if p-mode = {&verify} then do:
            undo, return error substitute("Нет Внешней системы с идентификатором &1  для  ГБД", p-value-integer).
          end.
          v-rid-list = '':U.
        end. /*else if available buf_ext-system*/
      end.
      run bge/oxmlexts.p (
            input parparentproc
          , input 2                         /* 2- Единичный выбор - 0. Множественный - 1*/
          , input (if num-entries(p-param-2-data-type, "_") = 1
                   then substitute("esys-type > &1", {&openxml-type-ordinal})
                   else substitute("esys-type = &1", entry(2, p-param-2-data-type, "_" ))
                   )
                   /*p-where-string*/
          , input v-uniq-key-rec        /* То, что уже выбрано (список) */
          , output v-rid-list          /* Список выбранных подсистем ( string( db-num ) + chr(6) + string( esys-id ) )*/
          , output v-ok               /* yes, если выбор был сделан. no - Если был отказ от выбора */
      ).
      if v-ok then do:
        run gen-row-keyr in this-procedure
          ( input v-rid-list
           ,input ?
           ,input "ub"
           ,input ?
           ,input no-lock
           ,output v-tbl-row
           ,output v-tbl-name
         ).
        find first buf_ext-system no-lock where
                  rowid(buf_ext-system) = v-tbl-row.
        if num-entries(p-param-2-data-type, "_") = 1 then do:
          if not (buf_ext-system.esys-type > integer({&openxml-type-ordinal})) then do:
          message
          "Нужно выбрать ВНЕШНЮЮ СИСТЕМУ типа СПЕЦИАЛЬНЫЙ"
          view-as alert-box error .
          undo, return error.
        end.
        end. /*if num-entries(p-param-2-data-type, "_") = 1 then do:*/
        else do:
          if not (buf_ext-system.esys-type = integer(entry(2, p-param-2-data-type, "_"))) then do:
            &scop openxml-type-code entry(2, p-param-2-data-type, "_")
            message
            substitute("Нужно выбрать ВНЕШНЮЮ СИСТЕМУ типа &1", {&openxml-type-name})
            view-as alert-box error .
            undo, return error.
          end.
        end. /*else if num-entries(p-param-2-data-type, "_") = 1 then do:*/
        assign
        p-value-integer = buf_Ext-system.esys-id
        p-ok = yes
        .
      end.
    end.
    if p-param-2-data-type = "file" then do:
      define variable v-path                    as character                no-undo .
      DEFINE VARIABLE v-full-path               as character                no-undo .
      DEFINE VARIABLE v-file-name               as character                no-undo .
      DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
      DEFINE VARIABLE v-file-name-ext           as character                no-undo .

      run gbl/filename.p (
               input p-value-character
              ,output v-full-path
              ,output v-path
              ,output v-file-name
              ,output v-file-name-no-ext
              ,output v-file-name-ext
              ) no-error .
      if not error-status:error then do:
        assign
        p-ok = yes
        .
      end.
    end.
    if p-param-2-data-type = "xsd"
    and p-param-data-type = {&abl-datatype-character}
    then do:
      define buffer buf_clob-bind for ub.clob-bind.
      find first buf_clob-bind no-lock where
                buf_clob-bind.uniq-key-rec = p-value-character
            and buf_clob-bind.resource-type = {&lob-res-gate} no-error.
      if not error-status :error then do:
        assign
        p-ok = yes
        .
      end.
    end.
    if lookup(p-param-2-data-type, {&calc-point-discnt-role-list}) > 0  then do:
      if not p-call-id begins {&table_thbj-attr} then do:
        undo, return error substitute("Неверный тип-2 параметра &1 для вызова &2"
                                      , p-param-2-data-type
                                      , p-call-id).
      end.
      run gen-key-fv  in this-procedure (
                                         input p-call-id
                                        ,output v-field-list
                                        ,output v-value-list
                                        ).
      if p-mode = {&verify} then do:
        if p-value-character = '' then return.
        find first buf_dis-cfg-rule no-lock where
                  buf_dis-cfg-rule.pos-type = entry(2, entry(lookup("prop-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}), "_")
              and buf_dis-cfg-rule.discnt-role = p-value-character no-error.
        if available buf_dis-cfg-rule then do:
          assign
          p-ok = yes
          .
        end.
        return.
      end.
      define variable v-subject-type as character no-undo .
      case p-param-2-data-type:
        when {&gds-discnt-role} then do:
          assign
          v-subject-type = {&discnt-gds}.
        end.
        when {&subtotal-discnt-role} then do:
          assign
          v-subject-type = {&discnt-sub-total}.
        end.
        when {&pay-discnt-role} then do:
          assign
          v-subject-type = {&discnt-payment}.
        end.
      end case.
      run ref/dis-pos.w ( INPUT parparentproc
                            ,INPUT "b-sel":U
                            ,INPUT "rum"
                            ,INPUT 1
                            ,INPUT 1
                            ,INPUT 1
                            ,input '':U
                            ,input '':U
                            ,input v-subject-type
                            ,INPUT entry(2, entry(lookup("prop-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}), "_")
                            ,input '':U
                            ,INPUT-OUTPUT v-rid-list) NO-ERROR.
      IF ERROR-STATUS:ERROR
      OR v-rid-list = '':U THEN DO:
          RETURN.
      END.
      find first buf_dis-cfg-rule no-lock where
                recid(buf_dis-cfg-rule) =integer(v-rid-list).
      assign
      p-value-character = buf_dis-cfg-rule.discnt-role
      p-ok = yes
      .

    end.
    if p-param-2-data-type = {&table_goods}
    or p-param-2-data-type = {&table_goods} + "_null"
    then do:
      define buffer buf_goods for ub.goods.
      find first buf_goods no-lock where
                buf_goods.gds-code = p-value-integer no-error.
      if available buf_goods then do:
        if p-mode = {&verify} then do:
          p-ok = yes.
          return '':U.
        end.
        v-rid-list = string(recid(buf_goods)).
      end.
      else do:
        if p-mode = {&verify} then do:
          if p-param-2-data-type = {&table_goods} + "_null"
          and p-value-integer = 0
          then do:
            p-ok = yes.
            return '':U.
          end.
          else do:
            undo, return error substitute("Нет товара с кодом товара &1", p-value-integer).
          end.
        end.
        v-rid-list = '':U.
      end.
      run ref/gds-ref.p (    INPUT ParParentProc
                      ,  INPUT "b-sel"    /* buttons    */
                      ,  INPUT ?                  /* p-stat     */
                      ,  INPUT ?                  /* p-list     */
                      ,  INPUT ?                  /* p-cond     */
                      ,  INPUT ?                  /* p-rec      */
                      ,  INPUT ?                  /* p-grp      */
                      ,  INPUT ?                  /* p-cli-type */
                      ,  INPUT ?                  /* p-cli-code */
                      ,  INPUT ?                  /* p-obj-type */
                      ,  INPUT ?                  /* p-obj-code */
                      ,  INPUT ?                  /* p-other    */
                      , OUTPUT v-rid-list ) no-error .
      if error-status:error then return error .
      if v-rid-list = '':U then do:
        if p-param-2-data-type = {&table_goods} + "_null"
        then do:
          message
          "Вы хотите оставить ПУСТОЕ значение параметра?"
          view-as alert-box question buttons yes-no update glog.
          if glog then do:
            assign
            p-value-integer = 0
            p-ok =  yes
            .
          end.
          else do:
            return error ''.
          end.
        end.
        else do:
          return error ''.
        end.
      end.
      find first buf_goods no-lock where
                recid(buf_goods) = integer(v-rid-list) no-error.
      if not available buf_goods then return error.
      assign
      p-value-integer = buf_goods.gds-code
      p-ok = yes
      .
    end.
    if p-param-2-data-type = {&discnt-v-type-manual} then do:
      if p-value-integer = integer({&discnt-v-pcnt})
      or p-value-integer = integer({&discnt-v-sum})
      or p-value-integer = integer({&discnt-v-unknown})
      then do:
        if p-mode = {&verify} then do:
          p-ok = yes.
          return '':U.
        end.
      end.
      else do:
        if p-mode = {&verify} then do:
          undo, return error substitute("Неверный тип значения ручной скидки  = &1", p-value-integer).
        end.
      end.
      run gbl/s-dvt.w ( input "Выбор тип значения ручной скидки"
                      ,input-output p-value-integer
                      ,output v-ok ) no-error.
      if not v-ok then return error.
      assign
      p-value-integer = p-value-integer
      p-ok = yes
      .
    end.
    if p-param-2-data-type = {&table_cash-pay}
    or p-param-2-data-type = {&table_cash-pay} + "_null"
    then do:
      define buffer buf_cash-pay for ub.cash-pay.
      find first buf_cash-pay no-lock where
                buf_cash-pay.cdpay-code = integer(entry(1, p-value-character))
            and buf_cash-pay.curr-code = integer(entry(2, p-value-character))
                no-error.
      if available buf_cash-pay then do:
        if p-mode = {&verify} then do:
          p-ok = yes.
          return '':U.
        end.
        v-rid-list = string(recid(buf_cash-pay)).
      end.
      else do:
        if p-mode = {&verify} then do:
          if p-value-character = substitute("&1,&2", 0, 0)
          and p-param-2-data-type = {&table_cash-pay} + "_null" then do:
            p-ok = yes.
            return '':U.
          end.
          else do:
            undo, return error substitute("Нет типа касс.платежа с кодом &1 и кодом валюты &2"
                                        , entry(1, p-value-character)
                                        , entry(2, p-value-character)
                                        ).
          end.
        end.
        v-rid-list = '':U.
      end.
      run ref/cashpays.w (
               input parparentproc
              ,input  "b-sel":U
              ,input {&all}
              ,input 0 /*p-host-code*/
              ,input '' /*p-obj-type*/
              ,input 0 /*p-obj-code*/
              ,OUTPUT v-rid-list) NO-ERROR.
      if error-status:error then return error.
      if v-rid-list = '':U then do:
        if p-param-2-data-type = {&table_cash-pay} + "_null" then do:
          message
          "Вы хотите оставить ПУСТОЕ значение параметра?"
          view-as alert-box question buttons yes-no update glog.
          if glog then do:
            assign
            p-value-character = substitute("&1,&2", 0, 0)
            p-ok =  yes
            .
          end.
        end.
        else do:
          return error.
        end.
      end.
      find first buf_cash-pay no-lock where
                recid(buf_cash-pay) = integer(v-rid-list) no-error.
      if not available buf_cash-pay then return error.
      assign
      p-value-character = substitute("&1,&2", buf_cash-pay.cdpay-code, buf_cash-pay.curr-code)
      p-ok = yes
      .
    end.
    if p-param-2-data-type = {&table_dis-card}
    or p-param-2-data-type = {&table_dis-card}  + "_null"
    then do:
      define buffer buf_dis-card for ub.dis-card.
      find first buf_dis-card no-lock where
                buf_dis-card.d-card = p-value-character
                no-error.
      if available buf_dis-card then do:
        if p-mode = {&verify} then do:
          p-ok = yes.
          return '':U.
        end.
        v-rid-list = string(recid(buf_dis-card)).
      end.
      else do:
        if p-mode = {&verify} then do:
          if p-value-character = ""
          and p-param-2-data-type = {&table_dis-card} + "_null" then do:
            p-ok = yes.
            return '':U.
          end.
          else do:
            undo, return error substitute("Нет ДК &1"
                                        , p-value-character
                                        ).
          end.
        end.
        v-rid-list = '':U.
      end.
      run ref/discards.w (
                           input parparentproc
                          ,input "b-sel"
                          ,input {&all}
                          ,input v-cntxt-host-code-obj
                          ,input v-cntxt-obj-type
                          ,input v-cntxt-obj-code
                          ,input '' /*p-first-main-card*/
                          ,input ? /*cli-recid*/
                          ,output v-rid-list) no-error.
      if error-status:error then return error .
      if v-rid-list = '':U then do:
        if p-param-2-data-type = {&table_dis-card} + "_null" then do:
          message
          "Вы хотите оставить ПУСТОЕ значение параметра?"
          view-as alert-box question buttons yes-no update glog.
          if glog then do:
            assign
            p-value-character = ""
            p-ok =  yes
            .
          end.
        end.
        else do:
          return error.
        end.
      end.
      find first buf_dis-card no-lock where
                recid(buf_dis-card) = integer(v-rid-list) no-error.
      if not available buf_dis-card then return error.
      assign
      p-value-character = buf_dis-card.d-card
      p-ok = yes
      .
    end.
    if p-param-2-data-type = {&table_chk-doc} + "_wth-type_null"
    or p-param-2-data-type = {&table_chk-doc} + "_wth-type" then do:
      if lookup(string(p-value-integer), {&wth-receipt-codes}) > 0
      or (p-value-integer = 0 and p-param-2-data-type = {&table_chk-doc} + "_wth_type_null")
      then do:
        if p-mode = {&verify} then do:
          p-ok = yes.
          return '':U.
        end.
      end.
      else do:
        if p-mode = {&verify} then do:
          undo, return error substitute("Неверное значение типа валюты продаж  = &1", p-value-character).
        end.
      end.
      run gbl/d-list.w (
                    INPUT "b-sel":U
                    ,INPUT "Выберите тип чека МЦ"
                    ,INPUT {&comma-char} + {&wth-receipt-codes}
                    ,INPUT "Тип чека МЦ не задан" + {&comma-char} + {&wth-receipt-codes-full}
                    ,INPUT {&comma-char}
                    ,INPUT "":U
                    ,output v-chk-type).
      IF v-chk-type = "":u THEN do:
        RETURN error.
      end.
      assign
      p-value-integer = integer(v-chk-type)
      p-ok = yes
      .
    end.

    if (p-param-2-data-type begins "list_"
    or p-param-2-data-type begins "list-macro_")
    and p-param-data-type = {&abl-datatype-character}
    then do:
      define variable v-res-type as character no-undo .
      define buffer buf_clob-data for ub.clob-data.
      v-res-type = if p-param-2-data-type begins "list_"
                  then {&lob-res-list}
                  else {&lob-res-list-macro}.
      find first buf_clob-bind no-lock where
                buf_clob-bind.uniq-key-rec = entry(1, p-value-character, "_")
            and buf_clob-bind.field-name_ = entry(2, p-value-character, "_")
            and buf_clob-bind.resource-type = v-res-type no-error.
      if available buf_clob-bind then do:
       find first buf_clob-data no-lock where
                  buf_clob-data.db-num = buf_clob-bind.db-num
              and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
      end.
      if (available buf_clob-bind and available buf_clob-data and buf_clob-data.is-cs = yes)
      or p-value-character = "_"
      then do:
        if p-mode = {&verify} then do:
          assign
          p-ok = yes
          .
          return ''.
        end.
        v-rid-list = (if available buf_clob-bind then string(recid(buf_clob-bind)) else '').
      end.
      else do:
        if p-mode = {&verify} then do:
          undo, return error
          (if v-res-type = {&lob-res-list}
          then substitute("Нет СПИСКА &1 или он ДОСТУПЕН НЕ ДЛЯ ВСЕХ БД", p-value-character)
          else substitute("Нет МАКРОСА ФОРМИРОВАНИЯ СПИСКА &1 или он ДОСТУПЕН НЕ ДЛЯ ВСЕХ БД", p-value-character)
          )
          .
        end.
        v-rid-list = '':U.
      end.
      /*вызов спарвочника СПИСКОВ*/
      v-uniq-key-rec = entry(2, p-param-2-data-type, "_").
      run ref/clobbnds.w ( input parparentproc
                          ,input this-procedure:handle
                          ,input 'b-sel' /*bttns*/
                          ,input "uniq-key-rec" /*p-list-mode*/
                          ,input "" /*p-mode*/
                          ,input v-res-type
                          ,input v-uniq-key-rec /*p-unique-key-rec*/
                          ,input -1 /*p-db-num*/
                          ,input-output v-rid-list) no-error.
      if v-rid-list <> '':U then do:
        FIND FIRST buf_clob-bind NO-LOCK WHERE
                    recid(buf_clob-bind) = INTEGER(v-rid-list) NO-ERROR.
        IF not AVAILABLE buf_clob-bind THEN DO:
          if v-res-type = {&lob-res-list}
          then
          return error substitute("Не найден список c recid &1", v-rid-list).
          else
          return error substitute("Не найден макрос c recid &1", v-rid-list).
        end.
        assign
        p-value-character =  SUBSTITUTE("&1_&2"
                                      , buf_clob-bind.uniq-key-rec
                                      , buf_clob-bind.field-name_)

        p-ok = yes
        .
      end.
    end.
   if p-param-2-data-type begins "tpl_"
    and p-param-data-type = {&abl-datatype-character}
    then do:
      define buffer buf_price-list-type for ub.price-list-type.
      find first buf_price-list-type no-lock where
                buf_price-list-type.plt-id = integer(entry(1, p-value-character, "-"))
            and buf_price-list-type.db-num = integer(entry(2, p-value-character, "-")) no-error.
      if available buf_price-list-type then do:
        if p-mode = {&verify} then do:
          assign
          p-ok = yes
          .
          return ''.
        end.
        v-rid-list = string(recid(buf_price-list-type)).
      end.
      else do:
        if p-mode = {&verify} then do:
          undo, return error substitute("Нет ТПЛ &1", p-value-character).
        end.
        v-rid-list = '':U.
      end.
      /*вызов спарвочника ТПЛ*/
      v-templ-rl-root = integer(entry(2, p-param-2-data-type, "_")).
      v-rid-list = string(v-templ-rl-root).
      run ref/typepric.w (
                            input  parParentProc
                          ,INPUT "b-sel,mode=ban-discnt"
                          ,INPUT-OUTPUT v-rid-list ) NO-ERROR.

      if v-rid-list <> '':U then do:
        FIND FIRST buf_price-list-type NO-LOCK WHERE
                    recid(buf_price-list-type) = INTEGER(v-rid-list) NO-ERROR.
        IF not AVAILABLE buf_price-list-type THEN DO:
          return error substitute("Не найден ТПЛ c recid &1", v-rid-list).
        end.
        assign
        p-value-character =  SUBSTITUTE("&1-&2"
                                      , buf_price-list-type.plt-id
                                      , buf_price-list-type.plt-db-num)
        p-ok = yes
        .
      end.
    end.
    if p-param-2-data-type = "sub-type" then do:
      if p-mode = {&verify} then do:
        p-ok = yes.
        return '':U.
      end.
      assign
      p-value-character = p-value-character
      p-ok = yes
      .
    end.
    if p-param-2-data-type = "id" then do:
      if p-mode = {&verify} then do:
        p-ok = yes.
        return '':U.
      end.
      run gbl/d-prompt.w (
          'title=':u + "ВВЕДИТЕ ЗНАЧЕНИЕ" + '\':u
        + 'text1=' + substitute("ЗНАЧЕНИЕ") + '\':u
        + 'format=' + "X(40)" + '\':u
        + 'type=' + {&type-char} + '\':u
        + 'fillin_row=2\':u
        + 'fillin_col=4\':u
        + 'fillin_width=20\':u
        + 'fillin_height=1\':u
        + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
        + 'readonly=no\':u
        , input-output p-value-character
        ).
      assign
      p-ok = yes
      .
    end.
end.