/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/05/07
Author: Bakhtadze Natalya
Creation date: 05/05/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ cmp/hst-bush.i }
define temp-table rrdb-option no-undo
field first-table-name as character
field second-table-name as character
field third-table-name as character
field fourth-table-name as character
field fifth-table-name as character
field sixth-table-name as character
field first-table-export as logical init yes
field second-table-export as logical init yes
field third-table-export as logical init yes
field fourth-table-export as logical init yes
field fifth-table-export as logical init yes
field sixth-table-export as logical init yes
field if-buffer-num as integer init 1
field where-phrase as character
field if-phrase as character
field dump-point as character
field subject-group as character
field obj-fields as character
field des as character
field id as integer
index pi is unique primary
id
index isubject subject-group
index ipoint dump-point
.

define variable rest-rdb_id                as integer   no-undo .
define variable table-ref as character no-undo .
define variable table-ref-where as character no-undo .
define variable table-ref-if-cond as character no-undo .
define variable table-obj as character no-undo .
define variable table-obj-where as character no-undo .
define variable table-obj-if-cond as character no-undo .
define variable table-host-obj as character no-undo .
define variable table-host-obj-where as character no-undo .
define variable table-host-obj-if-cond as character no-undo .
define variable table-xobj as character no-undo .
define variable table-xobj-where as character no-undo .
define variable table-xobj-if-cond as character no-undo .
define variable table-xobj-fields   as character no-undo .
define variable table-firm-db       as character no-undo .
define variable table-firm-db-no    as character no-undo .
define variable table-firm-db-where as character no-undo .
define variable table-firm-db-if-cond as character no-undo .
define variable table-db       as character no-undo .
define variable table-db-where as character no-undo .
define variable table-db-if-cond as character no-undo .
define variable table-erprn as character no-undo .
&glob all-query-buffers (buf_rrdb-option.first-table-name + "," + ~
                         buf_rrdb-option.second-table-name + "," + ~
                         buf_rrdb-option.third-table-name + "," + ~
                         buf_rrdb-option.fourth-table-name + "," + ~
                         buf_rrdb-option.fifth-table-name + "," + ~
                         buf_rrdb-option.sixth-table-name)

&glob all-query-buffers-export (string(buf_rrdb-option.first-table-export) + "," + ~
                         string(buf_rrdb-option.second-table-export) + "," + ~
                         string(buf_rrdb-option.third-table-export) + "," + ~
                         string(buf_rrdb-option.fourth-table-export) + "," + ~
                         string(buf_rrdb-option.fifth-table-export) + "," + ~
                         string(buf_rrdb-option.sixth-table-export))



assign table-ref = '~
assortment-matrix~
,assortment-matrix-goods~
,alc-type~
,c-alc-type~
,alc-type-attr~
,c-alc-type-attr~
,alc-type-gds~
,c-alc-type-gds~
,alc-type-gds-attr~
,alc-sale-lic~
,c-alc-sale-lic~
,alc-sale-lic-attr~
,c-alc-sale-lic-attr~
,alc-sale-lic-type~
,c-alc-sale-lic-type~
,alc-sale-lic-type-attr~
,alc-supp-lic~
,c-alc-supp-lic~
,alc-supp-lic-attr~
,c-alc-supp-lic-attr~
,alc-supp-lic-type~
,c-alc-supp-lic-type~
,alc-supp-lic-type-attr~
,arh-wth-cli~
,arh-wth-cli-doc~
,arh-wth-cli-tot~
,attr-prop~
,auto-tank~
,auto-section~
,auto-section-table~
,bar-code-attr~
,c-bar-code-attr~
,c-auto-tank~
,c-auto-section~
,c-auto-section-table~
,auto-tank-meas~
,buyer-group~
,c-buyer-group~
,buyer-in-buyer-group~
,c-buyer-in-buyer-group~
,cash-pay~
,c-cash-pay~
,cash-pay-attr~
,c-cash-pay-attr~
,cd-events~
,cd-events-attr~
,cd-video-link~
,cd-video-link-attr~
,cli-grp~
,c-cli-grp~
,clients~
,code-range~
,condition-keeping~
,c-condition-keeping~
,contract~
,contract-line~
,contract-specif~
,contract-specif-attr~
,country~
,c-country~
,criterion-analysis~
,curr-accnt~
,c-curr-accnt~
,curr-bank~
,c-curr-bank~
,currency~
,c-currency~
,custom-labels~
,db~
,db-attr~
,db-grp-obj-price~
,deliv-type-cond-keep~
,c-deliv-type-cond-keep~
,delivery-subject~
,c-delivery-subject~
,delivery-type~
,c-delivery-type~
,delivery-type-subject~
,c-delivery-type-subject~
,dis-card-mask~
,dis-card-mask-attr~
,dis-card-type~
,dis-card-type-attr~
,dis-dct-rule~
,dis-cfg-rule~
,c-dis-cfg-rule~
,dis-time-rule~
,drt-prop~
,c-drt-prop~
,ex-mark~
,c-ex-mark~
,ext-artic~
,c-ext-artic~
,ext-artic-attr~
,c-ext-artic-attr~
,ext-classif~
,c-ext-classif~
,fin-bank~
,fin-schet~
,firm~
,gds-add-charges~
,gds-add-charges-attr~
,gds-grp~
,c-gds-grp~
,gds-grp-attr~
,gds-grp-obj~
,c-gds-grp-obj~
,gds-host-attr~
,gds-prt~
,c-gds-prt~
,gds-obj-prop~
,global-state~
,c-global-state~
,global-state-attr~
,c-global-state-attr~
,goods~
,goods-attr~
,group-period-validity~
,c-group-period-validity~
,grp-obj-price~
,host-grp-obj-price~
,layout~
,layout-elem~
,layout-elem-attr~
,layout-elem-rule~
,lvl-name~
,obj-grp-obj-price~
,pay-type~
,c-pay-type~
,person~
,place-io~
,c-place-io~
,point-io~
,c-point-io~
,point-place-rel~
,c-point-place-rel~
,point-point-rel~
,c-point-point-rel~
,profile-by-profile~
,c-profile-by-profile~
,prop-head~
,prop-map~
,prop-ref~
,prop-ref-call~
,prop-ruleset~
,prop-script~
,pscript-ruleset~
,qnty-group~
,c-qnty-group~
,qnty-in-qnty-group~
,c-qnty-in-qnty-group~
,recipe~
,recipe-gds~
,regions~
,c-regions~
,rp-by-call~
,rp-rule-param~
,c-rp-by-call~
,rule~
,rule-by-call~
,rule-by-profile~
,rule-by-set~
,rule-call-param~
,rule-i-script~
,rule-profile~
,rule-process~
,rule-script~
,rule-trans-memo~
,ruledict~
,ruledict-param~
,ruleset~
,s-coeff~
,schedule~
,schedule-attr~
,sert~
,c-sert~
,sert-join~
,shop~
,stop-list~
,c-stop-list~
,stop-list-line~
,c-stop-list-line~
,store~
,sum-group~
,c-sum-group~
,sum-grp~
,c-sum-grp~
,sum-in-sum-group~
,c-sum-in-sum-group~
,sysconf~
,tare~
,c-tare~
,tax~
,c-tax~
,tax-rate~
,tax-rate-attr~
,c-tax-rate~
,tax-rate-gds~
,tax-rate-gds-grp~
,tax-rate-value~
,tax-units~
,c-tax-units~
,thbj-attr~
,c-thbj-attr~
,tnv-in-turnover-group~
,c-tnv-in-turnover-group~
,trn-reason~
,c-trn-reason~
,trn-reason-host~
,c-trn-reason-host~
,trn-reason-obj~
,c-trn-reason-obj~
,turnover-buyer~
,turnover-buyer-gds~
,turnover-buyer-main~
,turnover-group~
,c-turnover-group~
,units~
,c-units~
,upgrade~
,user-account~
,var-deliv-gr-per-val~
,c-var-deliv-gr-per-val~
,variant-delivery~
,c-variant-delivery~
,wealth~
,c-wealth~
,wi-mode~
,wi-mode-attr~
,wth-gds~
,c-wth-gds~
,wth-par~
,c-wth-par~
,wth-ser~
,c-wth-ser~
,wth-parts~
,code~
':U
table-ref-where = fill({&delim-par}, num-entries(table-ref) - 1 )
table-ref =  table-ref + '~
,dis-rule~
,dis-gds-rule~
,dis-grp-rule_1~
,c-dis-grp-rule_1~
,dis-grp-rule_2~
,c-dis-grp-rule_2~
,dis-thbj-rule~
,c-dis-thbj-rule~
,dis-cp-rule~
,c-dis-cp-rule
,fbr-gds-grp~
,c-fbr-gds-grp~
,fbr-gds-grp-attr~
,c-fbr-gds-grp-attr~
,c-sert~
,staff~
,clob-bind~
,clob-bind_1~
,c-ruledict~
,c-layout~
,c-layout-elem-rule~
,bar-code-obj-attr~
,c-bar-code-obj-attr~
,c-prop-head~
,c-utd-head~
,c-utd~
,c-utd-attr~
,c-Utd-err~
,c-Utd-lines~
,c-Utd-marking-lines~
,c-Utd-err-attr~
,c-Utd-lines-attr~
,c-Utd-marking-lines-attr~
':U
table-ref-where = table-ref-where + {&delim-par} + " ub.dis-rule.host-code = 0 and ub.dis-rule.obj-type = '' and ub.dis-rule.obj-code = 0 "
table-ref-where = table-ref-where + {&delim-par} + " ub.dis-gds-rule.obj-type = '' and ub.dis-gds-rule.obj-code = 0 "
table-ref-where = table-ref-where + {&delim-par} + " dis-grp-rule_1.classif-type = {&table_gds-grp} and dis-grp-rule_1.obj-type = '' and dis-grp-rule_1.obj-code = 0 "
table-ref-where = table-ref-where + {&delim-par} + " c-dis-grp-rule_1.classif-type = {&table_gds-grp} and c-dis-grp-rule_1.obj-type = '' and c-dis-grp-rule_1.obj-code = 0 "
table-ref-where = table-ref-where + {&delim-par} + " dis-grp-rule_2.classif-type = {&table_sum-grp} and dis-grp-rule_2.obj-type = '' and dis-grp-rule_2.obj-code = 0 "
table-ref-where = table-ref-where + {&delim-par} + " c-dis-grp-rule_2.classif-type = {&table_sum-grp} and c-dis-grp-rule_2.obj-type = '' and c-dis-grp-rule_2.obj-code = 0 "
table-ref-where = table-ref-where + {&delim-par} + " (ub.dis-thbj-rule.obj-type = '' and ub.dis-thbj-rule.obj-code = 0) or ub.dis-thbj-rule.host-code = 0 "
table-ref-where = table-ref-where + {&delim-par} + " (ub.c-dis-thbj-rule.obj-type = '' and ub.c-dis-thbj-rule.obj-code = 0) or ub.c-dis-thbj-rule.host-code = 0 "
table-ref-where = table-ref-where + {&delim-par} + " (ub.dis-cp-rule.obj-type = '' and ub.dis-cp-rule.obj-code = 0) or ub.dis-cp-rule.host-code = 0 "
table-ref-where = table-ref-where + {&delim-par} + " (ub.c-dis-cp-rule.obj-type = '' and ub.c-dis-cp-rule.obj-code = 0) or ub.c-dis-cp-rule.host-code = 0 "
table-ref-where = table-ref-where + {&delim-par} + " ub.fbr-gds-grp.obj-type = '' and ub.fbr-gds-grp.obj-code = 0 and ub.fbr-gds-grp.upper-code > 0"
table-ref-where = table-ref-where + {&delim-par} + " ub.c-fbr-gds-grp.obj-type = '' and ub.c-fbr-gds-grp.obj-code = 0 "
table-ref-where = table-ref-where + {&delim-par} + " ub.fbr-gds-grp-attr.obj-type = '' and ub.fbr-gds-grp-attr.obj-code = 0 "
table-ref-where = table-ref-where + {&delim-par} + " ub.c-fbr-gds-grp-attr.obj-type = '' and ub.c-fbr-gds-grp-attr.obj-code = 0 "
table-ref-where = table-ref-where + {&delim-par} + "ub.c-sert.b-code = 0"
table-ref-where = table-ref-where + {&delim-par} + "ub.staff.db-num = - 1"
table-ref-where = table-ref-where + {&delim-par} + "ub.clob-bind.resource-type = {&lob-res-gate}"
table-ref-where = table-ref-where + {&delim-par} + "clob-bind_1.resource-type = {&lob-res-ref}"
table-ref-where = table-ref-where + {&delim-par} + substitute("ub.c-ruledict.entry-id = 0 and (ub.c-ruledict.corr-user-db-num = &1 or ub.c-ruledict.corr-user-db-num = 0)", p-db-num)
table-ref-where = table-ref-where + {&delim-par} + substitute("ub.c-layout.corr-user-db-num = &1", p-db-num)
table-ref-where = table-ref-where + {&delim-par} + substitute("ub.c-layout-elem-rule.corr-user-db-num = &1", p-db-num)
table-ref-where = table-ref-where + {&delim-par} + substitute("ub.bar-code-obj-attr.obj-type = '' and ub.bar-code-obj-attr.obj-code = 0")
table-ref-where = table-ref-where + {&delim-par} + substitute("ub.c-bar-code-obj-attr.obj-type = '' and ub.c-bar-code-obj-attr.obj-code = 0")
table-ref-where = table-ref-where + {&delim-par} + substitute("ub.c-prop-head.subject > {&table_prop-ref} or ub.c-prop-head.subject < {&table_prop-ref}")
table-ref-where = table-ref-where + {&delim-par} + substitute("ub.c-utd-head.corr-user-db-num = &1 ", p-db-num)
table-ref-where = table-ref-where + {&delim-par} + substitute("ub.c-utd.corr-user-db-num = &1 ", p-db-num)
table-ref-where = table-ref-where + {&delim-par} + substitute("ub.c-utd-attr.corr-user-db-num = &1 ", p-db-num)
table-ref-where = table-ref-where + {&delim-par} + substitute("ub.c-utd-err.corr-user-db-num = &1 ", p-db-num)
table-ref-where = table-ref-where + {&delim-par} + substitute("ub.c-utd-lines.corr-user-db-num = &1 ", p-db-num)
table-ref-where = table-ref-where + {&delim-par} + substitute("ub.c-utd-marking-lines.corr-user-db-num = &1 ", p-db-num)
table-ref-where = table-ref-where + {&delim-par} + substitute("ub.c-utd-err-attr.corr-user-db-num = &1 ", p-db-num)
table-ref-where = table-ref-where + {&delim-par} + substitute("ub.c-utd-lines-attr.corr-user-db-num = &1 ", p-db-num)
table-ref-where = table-ref-where + {&delim-par} + substitute("ub.c-utd-marking-lines-attr.corr-user-db-num = &1 ", p-db-num)

table-ref-if-cond = fill({&delim-par}, num-entries(table-ref) - 1)
.

/* выгрузка истории goods cli dc общие таблицы и части относящиеся к системе в ЦЕЛОМ -
за исключением подтверждений изменения записей в другой БД */
assign
table-ref = table-ref + "~
,c-bar-code~
,c-bar-code-attr~
,c-clients~
,c-clients-attr~
,c-dis-card-mask~
,c-dis-card-type~
,c-dis-card-type-attr~
,c-dis-time-rule~
,c-dis-dct-rule~
,c-dis-rule~
,c-firm~
,c-gds-host-attr~
,c-goods~
,c-goods-attr~
,c-person~
,c-prod-bc~
,c-prop-ref~
,c-recipe~
,c-recipe-gds~
,c-rule-by-call~
,c-shop~
,c-store~
,c-staff~
,c-sysconf~
":U
table-ref-where   = table-ref-where +
                    fill({&delim-par}, num-entries(table-ref)  - num-entries(table-ref-where, {&delim-par}))
table-ref-if-cond = table-ref-if-cond
                  + {&delim-par} + "if-simple"
                  + {&delim-par} + "if-simple"
                  + {&delim-par} + "if-simple"
                  + {&delim-par} + "if-simple"
                  + {&delim-par} + "if-simple"
                  + {&delim-par} + "if-simple"
                  + {&delim-par} + "if-simple"
                  + {&delim-par} + "if-simple"
                  + {&delim-par} + "if-simple-and-global"
                  + {&delim-par} + "if-simple-and-global"
                  + {&delim-par} + "if-simple"
                  + {&delim-par} + "if-simple"
                  + {&delim-par} + "if-simple"
                  + {&delim-par} + "if-simple"
                  + {&delim-par} + "if-simple"
                  + {&delim-par} + "if-simple"
                  + {&delim-par} + "if-simple"
                  + {&delim-par} + "if-simple"
                  + {&delim-par} + "if-simple"
                  + {&delim-par} + "if-simple"
                  + {&delim-par} + "if-simple"
                  + {&delim-par} + "if-simple"
                  + {&delim-par} + "if-db-num-1"
                  + {&delim-par} + "if-simple"
.
assign
table-obj = '~
bar-code-obj-attr~
,c-bar-code-obj-attr~
,cd-clu~
,c-cd-clu~
,cd-dlu~
,c-cd-dlu~
,cd-doc~
,c-cd-doc~
,cd-doc-line~
,c-cd-doc-line~
,cd-grp~
,c-cd-grp~
,cd-plu~
,c-cd-plu~
,cd-trans~
,curr-shop~
,dis-cp-rule~
,c-dis-cp-rule~
,dis-gds-rule~
,c-dis-gds-rule~
,dis-rule~
,c-dis-rule~
,dis-thbj-rule~
,c-dis-thbj-rule~
,fbr-gds-grp~
,c-fbr-gds-grp~
,fbr-gds-grp-attr~
,c-fbr-gds-grp-attr~
,fbr-gds-obj~
,c-fbr-gds-obj~
,gds-obj~
,gds-obj-attr~
,c-gds-obj-attr~
,c-gds-obj-ref~
,nozzle~
,c-nozzle~
,nozzle-attr~
,c-nozzle-attr~
,obj-date~
,pl-gds~
,c-pl-gds~
,pl-gds-pump~
,c-pl-gds-pump~
,pl-pump~
,c-pl-pump~
,pl-pump-nozzle~
,c-pl-pump-nozzle~
,place~
,c-place~
,pump~
,c-pump~
,pump-nozzle~
,c-pump-nozzle~
,scales-gds~
,c-scales-gds~
,shift-cash~
,shift-obj~
,c-shift-obj~
,shift-staff~
,c-shift-staff~
,sum-grp-obj~
,c-sum-grp-obj~
,dis-grp-rule_3~
,c-dis-grp-rule_3~
,varianty-delivery-gds-obj~
,c-varianty-delivery-gds-obj~
,wth-obj~
,wth-place~
,wth-pobj~
':U
table-obj-where = fill({&delim-par}, num-entries(table-obj) - 1 )
table-obj-if-cond = fill({&delim-par}, num-entries(table-obj) - 1)
.

/* сюда пишем таблицы в которых кероме obj-type obj-code впереди стоит host-code */
assign
table-host-obj = '~
arh-fin-doc-contr-schet-obj~
,arh-fin-doc-contr-s-nal-obj~
,arh-fin-doc-contr-s-tax-obj~
,arh-fin-doc-c-s-tax-nal-obj~
,arh-fin-doc-schet-obj~
,arh-fin-doc-schet-nal-obj~
':U
table-host-obj-where = fill({&delim-par}, num-entries(table-host-obj) - 1 )
table-host-obj-if-cond = fill({&delim-par}, num-entries(table-host-obj) - 1)
.

/* сюда пишем таблицы в которых obj-type obj-code присутствуют под ДРУГИМИ ИМЕНАМИ но имеют смысл obj-type и obj-code */
assign
table-Xobj        = '':U
table-Xobj-fields = '':U
table-Xobj-where  = fill( {&delim-par}, num-entries( table-Xobj ) - 1 )
table-Xobj-if-cond  = fill( {&delim-par}, num-entries( table-Xobj ) - 1 )
.


/*надо выгружать если firm-db-num = p-db-num или объект находится в в P-db-num а host-code = 0*/
assign
table-firm-db = '~
arh-fin-doc-an~
,arh-fin-doc-an-nal~
,arh-fin-doc-c-schet-tax-nal~
,arh-fin-doc-contr-schet~
,arh-fin-doc-contr-schet-nal~
,arh-fin-doc-contr-schet-tax~
,arh-fin-doc-schet~
,arh-fin-doc-schet-nal~
,arh-fin-doc-schet-tax~
,arh-fin-doc-schet-tax-nal~
,arh-fin-ob-contr~
,c-contract~
,c-contract-specif~
,factur-connect~
,factur-connect-line~
,c-fin-bank~
,fin-code-an-uchet~
,fin-code-cel-nazn~
,fin-code-cor-acc~
,fin-connect~
,fin-doc~
,c-fin-doc~
,fin-doc-attr~
,c-fin-doc-attr~
,fin-doc-tax~
,c-fin-doc-tax~
,c-fin-schet~
,fin-statement~
,c-fin-statement~
,fin-statement-attr~
,c-fin-statement-attr~
,fin-statement-line~
,c-fin-statement-line~
,schet-fact-doc~
,c-schet-fact-doc~
,schet-fact-line~
,c-schet-fact-line~
':U
table-firm-db-where = fill({&delim-par}, num-entries(table-firm-db) - 1)
table-firm-db-if-cond = fill({&delim-par}, num-entries(table-firm-db) - 1)

/*а эти таблицы надо выгружать ТОЛЬКО если firm-db-num = p-db-num */
table-firm-db-no = "~
fin-doc~
,c-fin-doc~
,fin-doc-attr~
,c-fin-doc-attr~
,fin-doc-tax~
,c-fin-doc-tax~
,fin-statement~
,c-fin-statement~
,fin-statement-attr~
,c-fin-statement-attr~
,fin-statement-line~
,c-fin-statement-line~
":U
.

assign
table-db       = '
action-post~
,action-post-host~
,action-post-menu-group~
,action-post-obj~
,action-post-role~
,action-post-user-login~
,action-role~
,action-role-item~
,action-role-item-gds~
,action-role-item-gds-grp~
,cash-desk~
,c-cash-desk~
,cash-desk-attr~
,c-cash-desk-attr~
,cd-event-log~
,cd-event-log-attr~
,config~
,fbr-prn~
,c-fbr-prn~
,fbr-prn-gds~
,c-fbr-prn-gds~
,fbr-prn-grp~
,c-fbr-prn-grp~
,menu-user~
,scales~
,c-scales~
,scales-attr~
,c-scales-attr~
,scales-grp~
,c-scales-grp~
,staff~
,c-staff~
,user-context-history~
,user-host~
,user-login~
,user-login-action-item~
,user-login-action-role~
,user-login-attr~
,user-menu-group~
,user-obj~
':U
table-db-where = fill({&delim-par}, num-entries(table-db) - 1)
table-db-if-cond = fill({&delim-par}, num-entries(table-db) - 1)
.
assign table-erprn    = '
goods~
,goods-attr~
,gds-host-attr~
,gds-obj-prop~
,recipe~
,recipe-gds~
,dis-gds-rule~
,c-dis-gds-rule~
,gds-obj~
,gds-obj-attr~
,c-gds-obj-attr~
,c-gds-obj-ref~
,code-range~
,contract~
,contract-line~
,contract-specif~
':U.

procedure prepare-tables :
define input parameter p-table-list as character no-undo .
define input parameter p-where-list as character no-undo .
define input parameter p-if-cond as character no-undo .
define input parameter p-obj-fields as character no-undo .
define input parameter p-dump-point as character no-undo .
define input parameter p-unload-history as logical no-undo .

define variable v-ii    as integer no-undo .
define variable v-count as integer   no-undo .
define buffer buf_rrdb-option for rrdb-option.
define buffer buf_hst-bush for hst-bush.

do
on error undo, return error
:
  assign
    v-count = num-entries(p-table-list)
  .
  if v-count <> num-entries(p-where-list, {&delim-par}) then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Список таблиц (первая таблица списка &1) не соответствует списку условий (where-list)", entry(1, p-table-list) ) skip
      view-as alert-box error .
    return error.
  end.
  if v-count <> num-entries(p-if-cond, {&delim-par}) then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Список таблиц (первая таблица списка &1) не соответствует списку условий (if-cond)", entry(1, p-table-list) ) skip
      view-as alert-box error .
    return error.
  end.
  if v-count <> num-entries(p-obj-fields, {&delim-par})
    and trim(p-obj-fields) <> '':U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Список таблиц (первая таблица списка &1) не соответствует списку условий (obj-fields)", entry(1, p-table-list) ) skip
      view-as alert-box error .
    return error.
  end.
  _v-ii:
  do v-ii = 1 to v-count
  :
    if p-unload-history = no
    and entry(v-ii, p-table-list) begins "c-" then next _v-ii.
    /* Если система в режиме интеграции с ERP РН, то не все таблицы выгружаем */
    if mode-erprn and  lookup(entry(v-ii, p-table-list),table-erprn) > 0 then next _v-ii.
    create buf_rrdb-option.
    assign
    buf_rrdb-option.first-table-name = entry(v-ii, p-table-list)
    buf_rrdb-option.where-phrase     = entry(v-ii, p-where-list, {&delim-par})
    buf_rrdb-option.if-phrase        = entry(v-ii, p-if-cond,  {&delim-par})
    buf_rrdb-option.obj-fields       = (if trim(p-obj-fields) = '':U
                                        then '':U
                                        else entry(v-ii, p-obj-fields, {&delim-par})
                                        )
    buf_rrdb-option.dump-point       = p-dump-point
    buf_rrdb-option.subject-group    = '':U
    buf_rrdb-option.id = rest-rdb_id + 1
    rest-rdb_id = rest-rdb_id + 1
    .
    CASE p-dump-point:
      when "obj" then do:
        if buf_rrdb-option.where-phrase = '':U
        then do:
          buf_rrdb-option.where-phrase =  substitute(' (&1.obj-type = "&&1" and &1.obj-code = &&2) '
                                                      ,buf_rrdb-option.first-table-name
                                                     )
          .
        end.
        else do:
          buf_rrdb-option.where-phrase =  substitute('(&1) and (&2.obj-type = "&&1" and &2.obj-code = &&2 ) '
                                                    ,buf_rrdb-option.where-phrase
                                                    ,buf_rrdb-option.first-table-name
                                                     )
          .
        end.
      end.
      when "host-obj" then do:
        if buf_rrdb-option.where-phrase = '':U
        then do:
          buf_rrdb-option.where-phrase =  substitute(' (&1.host-code = &&3 and &1.obj-type = "&&1" and &1.obj-code = &&2) '
                                                      ,buf_rrdb-option.first-table-name
                                                     )
          .
        end.
        else do:
          buf_rrdb-option.where-phrase =  substitute('(&1) and (&2.host-code = &&3 and &2.obj-type = "&&1" and &2.obj-code = &&2 ) '
                                                    ,buf_rrdb-option.where-phrase
                                                    ,buf_rrdb-option.first-table-name
                                                     )
          .
        end.
      end.
      when "db" then do:
        if buf_rrdb-option.where-phrase = '':U
        then do:
          buf_rrdb-option.where-phrase =  substitute(" (&1.db-num = &2) "
                                                      ,buf_rrdb-option.first-table-name
                                                      ,p-db-num
                                                     )
          .
        end.
        else do:
          buf_rrdb-option.where-phrase =  substitute("(&1) and (&2.db-num = &3) "
                                                    ,buf_rrdb-option.where-phrase
                                                    ,buf_rrdb-option.first-table-name
                                                    ,p-db-num
                                                     )
          .
        end.
      end.
      when "firm-db" then do:
        if buf_rrdb-option.where-phrase = '':U
        then do:
          buf_rrdb-option.where-phrase =  substitute(" (&1.host-code = &&1) "
                                                      ,buf_rrdb-option.first-table-name
                                                     )
          .
        end.
        else do:
          buf_rrdb-option.where-phrase =  substitute("(&1) and (&2.host-code = &&1) "
                                                    ,buf_rrdb-option.where-phrase
                                                    ,buf_rrdb-option.first-table-name
                                                     )
          .
        end.
      end.
      when "Xobj" then do:
        if buf_rrdb-option.where-phrase = '':U
        then do:
          buf_rrdb-option.where-phrase =  substitute(' (&1.&2 = "&&1" and &1.&3 = &&2) '
                                                      ,buf_rrdb-option.first-table-name
                                                      , entry(1, buf_rrdb-option.obj-fields, {&space-char})
                                                      , entry(2, buf_rrdb-option.obj-fields, {&space-char})
                                                     )
          .

        end.
        else do:
          buf_rrdb-option.where-phrase =  substitute(' (&1) and (&2.&3 = "&&1" and &2.&4 = &&2) '
                                                      ,buf_rrdb-option.where-phrase
                                                      ,buf_rrdb-option.first-table-name
                                                      ,entry(1, buf_rrdb-option.obj-fields, {&space-char})
                                                      ,entry(2, buf_rrdb-option.obj-fields, {&space-char})
                                                     )
          .
        end.
      end.
    END CASE.
    if buf_rrdb-option.first-table-name begins "c-":U
    or lookup(buf_rrdb-option.first-table-name, {&table_tax-rate-gds} + {&comma-char} +
                                                {&table_tax-rate-value} + {&comma-char} +
                                                {&table_auto-tank-meas}) > 0
    then do:
      find first buf_hst-bush where
                buf_hst-bush.table-name = buf_rrdb-option.first-table-name
            and buf_hst-bush.is-main = yes            no-error .
      if available buf_hst-bush then do:
        if buf_rrdb-option.first-table-name <> buf_hst-bush.bush-head then do:
          assign
          buf_rrdb-option.second-table-name = buf_hst-bush.bush-head
          .
          if buf_hst-bush.joined-buffers <> '':U then do:
            if num-entries(buf_hst-bush.joined-buffers) >= 1 then do:
                assign
                buf_rrdb-option.third-table-name = entry(1, buf_hst-bush.joined-buffers)
                .
            end.
            if num-entries(buf_hst-bush.joined-buffers) >= 2 then do:
                assign
                buf_rrdb-option.fourth-table-name = entry(2, buf_hst-bush.joined-buffers)
                .
            end.
            if num-entries(buf_hst-bush.joined-buffers) >= 3 then do:
                assign
                buf_rrdb-option.fifth-table-name = entry(3, buf_hst-bush.joined-buffers)
                .
            end.
            if num-entries(buf_hst-bush.joined-buffers) >= 4 then do:
                assign
                buf_rrdb-option.sixth-table-name = entry(4, buf_hst-bush.joined-buffers)
                .
            end.
          end.
        end.
        assign
        buf_rrdb-option.where-phrase = substitute("&1 &2"
                                                  ,(if buf_rrdb-option.where-phrase <> '':U
                                                   then substitute("(&1) and "
                                                                   ,buf_rrdb-option.where-phrase )
                                                   else '':U)
                                                  ,buf_hst-bush.where-phrase)
        .
      end. /*if available buf_hst-bush then do:*/
    end.
  end.
end.

end procedure. /* prepare-tables */

procedure prepare-dc :
define input parameter p-db-num as integer no-undo .
define input parameter p-unload-history as logical no-undo .
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf0_hist-nws-option for ub.hist-nws-option.
define buffer buf_rrdb-option for rrdb-option.
define buffer buf_dis-obj for ub.dis-obj.
define buffer buf_dis-host for ub.dis-host.
define buffer buf_clients for ub.clients.

do
on error undo, return error
:
  for each buf_Dis-card-type no-lock:
    if buf_dis-card-type.host-code > 0
    or buf_dis-card-type.obj-code > 0 then next.
    create buf_rrdb-option.
    assign
    buf_rrdb-option.first-table-name = {&table_dis-card}
    buf_rrdb-option.second-table-name = ''
    buf_rrdb-option.where-phrase = substitute(' ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2" '
                                          , buf_dis-card-type.emitent-host-code
                                          , buf_dis-card-type.type)
    buf_rrdb-option.if-phrase = ''
    buf_rrdb-option.dump-point = "ref"
    buf_rrdb-option.subject-group = "dc"
    buf_rrdb-option.id = rest-rdb_id + 1
    buf_rrdb-option.des = substitute("dis-card: type = &1", buf_dis-card-type.type)
    rest-rdb_id = rest-rdb_id + 1
    .
    create buf_rrdb-option.
    assign
    buf_rrdb-option.first-table-name = {&table_dis-card}
    buf_rrdb-option.first-table-export = no
    buf_rrdb-option.second-table-name = {&table_dis-card-long}
    buf_rrdb-option.where-phrase = substitute(' ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", ' +
                                          'each ub.dis-card-long no-lock where ub.dis-card-long.d-card = ub.dis-card.d-card '
                                          , buf_dis-card-type.emitent-host-code
                                          , buf_dis-card-type.type)
    buf_rrdb-option.if-phrase = ''
    buf_rrdb-option.dump-point = "ref"
    buf_rrdb-option.subject-group = "dc"
    buf_rrdb-option.id = rest-rdb_id + 1
    buf_rrdb-option.des = substitute("dis-card-long: type = &1", buf_dis-card-type.type)
    rest-rdb_id = rest-rdb_id + 1
    .
    create buf_rrdb-option.
    assign
    buf_rrdb-option.first-table-name = {&table_dis-card}
    buf_rrdb-option.first-table-export = no
    buf_rrdb-option.second-table-name = {&table_dis-card-property}
    buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", ' +
                                          'each ub.dis-card-property no-lock where ub.dis-card-property.d-card = ub.dis-card.d-card and ' +
                                          'ub.dis-card-property.obj-type = "&3"'
                                          , buf_dis-card-type.emitent-host-code
                                          , buf_dis-card-type.type
                                          , '':U
                                          )
    buf_rrdb-option.if-phrase = ''
    buf_rrdb-option.dump-point = "ref"
    buf_rrdb-option.subject-group = "dc"
    buf_rrdb-option.id = rest-rdb_id + 1
    buf_rrdb-option.des = substitute("dis-card-property: type = &1", buf_dis-card-type.type)
    rest-rdb_id = rest-rdb_id + 1
    .
    create buf_rrdb-option.
    assign
    buf_rrdb-option.first-table-name = {&table_dis-card}
    buf_rrdb-option.first-table-export = no
    buf_rrdb-option.second-table-name = {&table_dis-dc-rule}
    buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                          'each ub.dis-dc-rule no-lock where ub.dis-dc-rule.d-card = ub.dis-card.d-card and ' +
                                          'ub.dis-dc-rule.obj-type = "&3"'
                                          , buf_dis-card-type.emitent-host-code
                                          , buf_dis-card-type.type
                                          , '':U)
    buf_rrdb-option.if-phrase = ''
    buf_rrdb-option.dump-point = "ref"
    buf_rrdb-option.subject-group = "dc"
    buf_rrdb-option.id = rest-rdb_id + 1
    buf_rrdb-option.des = substitute("dis-dc-rule: type = &1", buf_dis-card-type.type)
    rest-rdb_id = rest-rdb_id + 1
    .
    for each buf_prop-head where
            buf_prop-head.general contains {&prop-head-gen-dis-card-type}:
      if buf_prop-head.storage-place-host = {&table_dis-host}
      then do:
        find first buf0_hist-nws-option where
                  buf0_hist-nws-option.table-name = {&table_dis-host}
              and buf0_hist-nws-option.db-num = 0
              and buf0_hist-nws-option.host-code = buf_dis-card-type.emitent-host-code
              and buf0_hist-nws-option.charkey_one = buf_Dis-card-type.type
              and buf0_hist-nws-option.charkey_two = '':U
              and buf0_hist-nws-option.charkey_three = '':U
              and buf0_hist-nws-option.key#_one = buf_prop-head.dtm-code
              and buf0_hist-nws-option.key#_two = 0
              and buf0_hist-nws-option.key#_three = 0
              and buf0_hist-nws-option.obj-type = ''
              and buf0_hist-nws-option.obj-code = 0
              no-error .
      /*ЕСЛИ НЕИЗВЕСТНО SMART или нет или ОБЫЧНО - тогда выгружаем*/
      if NOT available buf0_hist-nws-option
      or (available buf0_hist-nws-option
          and
               (buf0_hist-nws-option.smart-nws = integer({&hn-is-off})
                or buf0_hist-nws-option.smart-nws = integer({&hn-is-off-blocked}))
          )
      then do:
        for each buf_prop-ref no-lock where
                buf_prop-ref.dtm-code = buf_prop-head.dtm-code:
          create buf_rrdb-option.
          assign
          buf_rrdb-option.first-table-name = {&table_dis-card}
          buf_rrdb-option.first-table-export = no
          buf_rrdb-option.second-table-name = {&table_dis-host}
          buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                              'each ub.dis-host no-lock where ub.dis-host.d-card = ub.dis-card.d-card and ' +
                                              'ub.dis-host.dt-code = &3'
                                                , buf_dis-card-type.emitent-host-code
                                                , buf_dis-card-type.type
                                                , buf_prop-ref.dt-code
                                                )
          buf_rrdb-option.if-phrase = ''
          buf_rrdb-option.dump-point = "ref"
          buf_rrdb-option.subject-group = "dc"
          buf_rrdb-option.id = rest-rdb_id + 1
          buf_rrdb-option.des = substitute("dis-host: type = &1 dtm-code = &2 dt-code = &3"
                                          , buf_dis-card-type.type
                                          ,buf_prop-head.dtm-code
                                          ,buf_prop-ref.dt-code
                                          )
          rest-rdb_id = rest-rdb_id + 1
          .
          if p-unload-history then do:
            if not available buf0_hist-nws-option
            or buf0_hist-nws-option.get-hist-from-nws  >= 0
            or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
            create buf_rrdb-option.
            assign
            buf_rrdb-option.first-table-name = {&table_dis-card}
            buf_rrdb-option.first-table-export = no
            buf_rrdb-option.second-table-name = {&table_c-dis-host}
            buf_rrdb-option.third-table-name = {&table_c-dc-hist}
            buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                'each ub.c-dis-host no-lock where ub.c-dis-host.d-card = ub.dis-card.d-card and ' +
                                                'ub.c-dis-host.dt-code = &3, ' +
                                                'first ub.c-dc-hist no-lock where ' +
                                                'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                                'ub.c-dc-hist.corr-user-db-num = ub.c-dis-host.corr-user-db-num and ' +
                                                'ub.c-dc-hist.chip-num = ub.c-dis-host.chip-num '
                                                  , buf_dis-card-type.emitent-host-code
                                                  , buf_dis-card-type.type
                                                    , buf_prop-ref.dt-code
                                                  )
            buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                      or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                    then '':U
                                    else "if-self")
            buf_rrdb-option.if-buffer-num = 2
            buf_rrdb-option.dump-point = "ref"
            buf_rrdb-option.subject-group = "dc"
            buf_rrdb-option.id = rest-rdb_id + 1
            buf_rrdb-option.des = substitute("c-dis-host: type = &1 dtm-code = &2 dt-code = &3"
                                            , buf_dis-card-type.type
                                            ,buf_prop-head.dtm-code
                                            ,buf_prop-ref.dt-code
                                            )

            rest-rdb_id = rest-rdb_id + 1
            .
          end.
          end. /*          if p-unload-history then do:*/
        end. /*        for each buf_prop-ref no-lock where*/
      end. /*and (buf0_hist-nws-option.smart-nws = integer({&hn-is-off}) */
      if available buf0_hist-nws-option
      and (buf0_hist-nws-option.smart-nws = integer({&hn-is-on})
      or buf0_hist-nws-option.smart-nws = integer({&hn-is-on-blocked})) then do:
        for each buf_prop-ref no-lock where
                buf_prop-ref.dtm-code = buf_prop-head.dtm-code:
          find first buf_dis-host no-lock where
                      buf_Dis-host.dt-code = buf_prop-ref.dt-code no-error .
          if available buf_dis-host
          then do:
            if buf_prop-ref.dt-code > 0 then do:
            create buf_rrdb-option.
            assign
            buf_rrdb-option.first-table-name = {&table_dis-card}
            buf_rrdb-option.first-table-export = no
            buf_rrdb-option.second-table-name = {&table_dis-host}
            buf_rrdb-option.third-table-name = {&table_clients}
            buf_rrdb-option.third-table-export = no
            buf_rrdb-option.fourth-table-name = {&table_dis-obj}
            buf_rrdb-option.fourth-table-export = no
            buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                'each ub.dis-host no-lock where ub.dis-host.d-card = ub.dis-card.d-card and ' +
                                                'ub.dis-host.dt-code = &3, '  +
                                                'first ub.clients no-lock where ub.clients.db-num = &4 and ' +
                                                '(ub.dis-host.host-code = 0 or ub.clients.host-code = ub.dis-host.host-code), ' +
                                                'first ub.dis-obj no-lock where ub.dis-obj.d-card = ub.dis-card.d-card and ' +
                                                'ub.dis-obj.obj-type = ub.clients.obj-type and ub.dis-obj.obj-code = ub.clients.obj-code '
                                                , buf_dis-card-type.emitent-host-code
                                                , buf_dis-card-type.type
                                                , buf_prop-ref.dt-code
                                                , p-db-num
                                                )
            buf_rrdb-option.if-phrase = ''
            buf_rrdb-option.dump-point = "ref"
            buf_rrdb-option.subject-group = "dc"
            buf_rrdb-option.id = rest-rdb_id + 1
            buf_rrdb-option.des = substitute("dis-host: type = &1 dtm-code = &2 dt-code = &3"
                                            , buf_dis-card-type.type
                                            ,buf_prop-head.dtm-code
                                            ,buf_prop-ref.dt-code
                                            )
            rest-rdb_id = rest-rdb_id + 1
            .
            if p-unload-history then do:
              if not available buf0_hist-nws-option
              or buf0_hist-nws-option.get-hist-from-nws  >= 0
              or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
                create buf_rrdb-option.
                assign
                buf_rrdb-option.first-table-name = {&table_dis-card}
                buf_rrdb-option.first-table-export = no
                buf_rrdb-option.second-table-name = {&table_c-dis-host}
                buf_rrdb-option.third-table-name = {&table_c-dc-hist}
                buf_rrdb-option.fourth-table-name = {&table_clients}
                buf_rrdb-option.fourth-table-export = no
                buf_rrdb-option.fifth-table-name = {&table_dis-obj}
                buf_rrdb-option.fifth-table-export = no
                buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                    'each ub.c-dis-host no-lock where ub.c-dis-host.d-card = ub.dis-card.d-card and ' +
                                                    'ub.c-dis-host.dt-code = &3, ' +
                                                    'first ub.c-dc-hist no-lock where ' +
                                                    'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                                    'ub.c-dc-hist.corr-user-db-num = ub.c-dis-host.corr-user-db-num and ' +
                                                    'ub.c-dc-hist.chip-num = ub.c-dis-host.chip-num, ' +
                                                    'first ub.clients no-lock where ub.clients.db-num = &4 and ' +
                                                    '(ub.c-dis-host.host-code = 0 or ub.clients.host-code = ub.c-dis-host.host-code), ' +
                                                    'first ub.dis-obj no-lock where ub.dis-obj.d-card = ub.dis-card.d-card and ' +
                                                    'ub.dis-obj.obj-type = ub.clients.obj-type and ub.dis-obj.obj-code = ub.clients.obj-code '
                                                    , buf_dis-card-type.emitent-host-code
                                                    , buf_dis-card-type.type
                                                    , buf_prop-ref.dt-code
                                                    , p-db-num
                                                    )
                buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                            or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                        then '':U
                                        else "if-self")
                buf_rrdb-option.if-buffer-num = 2
                buf_rrdb-option.dump-point = "ref"
                buf_rrdb-option.subject-group = "dc"
                buf_rrdb-option.id = rest-rdb_id + 1
                buf_rrdb-option.des = substitute("c-dis-host: type = &1 dtm-code = &2 dt-code = &3"
                                                , buf_dis-card-type.type
                                                ,buf_prop-head.dtm-code
                                                ,buf_prop-ref.dt-code
                                                )
                rest-rdb_id = rest-rdb_id + 1
                .
                end.
              end. /*          if p-unload-history then do:*/
            end. /*if buf_prop-ref.dt-code > 0 then do:*/
            else do:
              create buf_rrdb-option.
              assign
              buf_rrdb-option.first-table-name = {&table_dis-card}
              buf_rrdb-option.first-table-export = no
              buf_rrdb-option.second-table-name = {&table_dis-host}
              buf_rrdb-option.third-table-name = {&table_clients}
              buf_rrdb-option.third-table-export = no
              buf_rrdb-option.fourth-table-name = {&table_dis-obj}
              buf_rrdb-option.fourth-table-export = no
              buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                  'each ub.dis-host no-lock where ub.dis-host.d-card = ub.dis-card.d-card and ' +
                                                  'ub.dis-host.dt-code = &3 and ub.dis-host.host-code > 0, '  +
                                                  'first ub.clients no-lock where ub.clients.db-num = &4 and ' +
                                                  '(ub.dis-host.host-code = 0 or ub.clients.host-code = ub.dis-host.host-code), ' +
                                                  'first ub.dis-obj no-lock where ub.dis-obj.d-card = ub.dis-card.d-card and ' +
                                                  'ub.dis-obj.obj-type = ub.clients.obj-type and ub.dis-obj.obj-code = ub.clients.obj-code '
                                                  , buf_dis-card-type.emitent-host-code
                                                  , buf_dis-card-type.type
                                                  , buf_prop-ref.dt-code
                                                  , p-db-num
                                                  )
              buf_rrdb-option.if-phrase = ''
              buf_rrdb-option.dump-point = "ref"
              buf_rrdb-option.subject-group = "dc"
              buf_rrdb-option.id = rest-rdb_id + 1
              buf_rrdb-option.des = substitute("dis-host: type = &1 dtm-code = &2 dt-code = &3"
                                              , buf_dis-card-type.type
                                              ,buf_prop-head.dtm-code
                                              ,buf_prop-ref.dt-code
                                              )
              rest-rdb_id = rest-rdb_id + 1
              .
              if p-unload-history then do:
                if not available buf0_hist-nws-option
                or buf0_hist-nws-option.get-hist-from-nws  >= 0
                or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
                  create buf_rrdb-option.
                  assign
                  buf_rrdb-option.first-table-name = {&table_dis-card}
                  buf_rrdb-option.first-table-export = no
                  buf_rrdb-option.second-table-name = {&table_c-dis-host}
                  buf_rrdb-option.third-table-name = {&table_c-dc-hist}
                  buf_rrdb-option.fourth-table-name = {&table_clients}
                  buf_rrdb-option.fourth-table-export = no
                  buf_rrdb-option.fifth-table-name = {&table_dis-obj}
                  buf_rrdb-option.fifth-table-export = no
                  buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                      'each ub.c-dis-host no-lock where ub.c-dis-host.d-card = ub.dis-card.d-card and ' +
                                                      'ub.c-dis-host.dt-code = &3, ' +
                                                      'first ub.c-dc-hist no-lock where ' +
                                                      'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                                      'ub.c-dc-hist.corr-user-db-num = ub.c-dis-host.corr-user-db-num and ' +
                                                      'ub.c-dc-hist.chip-num = ub.c-dis-host.chip-num, ' +
                                                      'first ub.clients no-lock where ub.clients.db-num = &4 and ' +
                                                      '(ub.c-dis-host.host-code = 0 or ub.clients.host-code = ub.c-dis-host.host-code), ' +
                                                      'first ub.dis-obj no-lock where ub.dis-obj.d-card = ub.dis-card.d-card and ' +
                                                      'ub.dis-obj.obj-type = ub.clients.obj-type and ub.dis-obj.obj-code = ub.clients.obj-code '
                                                      , buf_dis-card-type.emitent-host-code
                                                      , buf_dis-card-type.type
                                                      , buf_prop-ref.dt-code
                                                      , p-db-num
                                                      )
                  buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                            or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                          then '':U
                                          else "if-self")
                  buf_rrdb-option.if-buffer-num = 2
                  buf_rrdb-option.dump-point = "ref"
                  buf_rrdb-option.subject-group = "dc"
                  buf_rrdb-option.id = rest-rdb_id + 1
                  buf_rrdb-option.des = substitute("c-dis-host: type = &1 dtm-code = &2 dt-code = &3"
                                                  , buf_dis-card-type.type
                                                  ,buf_prop-head.dtm-code
                                                  ,buf_prop-ref.dt-code
                                                  )
                  rest-rdb_id = rest-rdb_id + 1
                  .
                end.
              end. /*if p-unload-history then do:*/
            end.
          end. /*if available buf_dis-host then do:*/
        end. /*for each buf_prop-ref no-lock where*/
      end. /*or buf0_hist-nws-option.smart-nws = integer({&hn-is-on})*/
      if available buf0_hist-nws-option
      and buf0_hist-nws-option.smart-nws >= 0 then do:
        for each buf_prop-ref no-lock where
                buf_prop-ref.dtm-code = buf_prop-head.dtm-code
            and buf_prop-ref.dt-code = 0
                :
          /* только глобальные и с dt-code = 0*/
          create buf_rrdb-option.
          assign
          buf_rrdb-option.first-table-name = {&table_dis-card}
          buf_rrdb-option.first-table-export = no
          buf_rrdb-option.second-table-name = {&table_dis-host}
          buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                              'each ub.dis-host no-lock where ub.dis-host.d-card = ub.dis-card.d-card and ' +
                                              'ub.dis-host.dt-code = &3 and ' +
                                              'ub.dis-host.host-code = 0 '
                                                , buf_dis-card-type.emitent-host-code
                                                , buf_dis-card-type.type
                                                , buf_prop-ref.dt-code
                                                )
          buf_rrdb-option.if-phrase = ''
          buf_rrdb-option.dump-point = "ref"
          buf_rrdb-option.subject-group = "dc"
          buf_rrdb-option.id = rest-rdb_id + 1
          buf_rrdb-option.des = substitute("dis-host: type = &1 dtm-code = &2 dt-code = &3"
                                          , buf_dis-card-type.type
                                          ,buf_prop-head.dtm-code
                                          ,buf_prop-ref.dt-code
                                          )
          rest-rdb_id = rest-rdb_id + 1
          .
          if p-unload-history then do:
            if (not available buf0_hist-nws-option
            or buf0_hist-nws-option.get-hist-from-nws  >= 0
            or buf0_hist-nws-option.nws-to-hist  >= 0)
            and (available buf0_hist-nws-option
            and buf0_hist-nws-option.smart-nws <> integer({&hn-is-smart2}))
            then do:
                create buf_rrdb-option.
                assign
                buf_rrdb-option.first-table-name = {&table_dis-card}
                buf_rrdb-option.first-table-export = no
                buf_rrdb-option.second-table-name = {&table_c-dis-host}
                buf_rrdb-option.third-table-name = {&table_c-dc-hist}
                buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                    'each ub.c-dis-host no-lock where ub.c-dis-host.d-card = ub.dis-card.d-card and ' +
                                                    'ub.c-dis-host.dt-code = &3 and ' +
                                                    'ub.c-dis-host.host-code = 0,' +
                                                    'first ub.c-dc-hist no-lock where ' +
                                                    'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                                    'ub.c-dc-hist.corr-user-db-num = ub.c-dis-host.corr-user-db-num and ' +
                                                    'ub.c-dc-hist.chip-num = ub.c-dis-host.chip-num '
                                                    , buf_dis-card-type.emitent-host-code
                                                    , buf_dis-card-type.type
                                                    , buf_prop-ref.dt-code
                                                    )
                buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                          or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                        then '':U
                                        else "if-self")
                buf_rrdb-option.if-buffer-num = 2
                buf_rrdb-option.dump-point = "ref"
                buf_rrdb-option.subject-group = "dc"
                buf_rrdb-option.id = rest-rdb_id + 1
                buf_rrdb-option.des = substitute("c-dis-host: type = &1 dtm-code = &2 dt-code = &3"
                                                , buf_dis-card-type.type
                                                ,buf_prop-head.dtm-code
                                                ,buf_prop-ref.dt-code
                                                )
                rest-rdb_id = rest-rdb_id + 1
                .
              end.
            end. /*if p-unload-history then do:*/
          end. /*prop-ref*/
        end. /*and buf0_hist-nws-option.smart-nws >= 0 then do:*/
      end. /*if buf_prop-head.storage-place-obj = {&table_dis-host}*/
      if buf_prop-head.storage-place-obj = {&table_dis-obj}
      then do:
        find first buf0_hist-nws-option where
                  buf0_hist-nws-option.table-name = {&table_dis-obj}
              and buf0_hist-nws-option.db-num = 0
              and buf0_hist-nws-option.host-code = buf_dis-card-type.emitent-host-code
              and buf0_hist-nws-option.charkey_one = buf_Dis-card-type.type
              and buf0_hist-nws-option.charkey_two = '':U
              and buf0_hist-nws-option.charkey_three = '':U
              and buf0_hist-nws-option.key#_one = buf_prop-head.dtm-code
              and buf0_hist-nws-option.key#_two = 0
              and buf0_hist-nws-option.key#_three = 0
              and buf0_hist-nws-option.obj-type = ''
              and buf0_hist-nws-option.obj-code = 0
              no-error .
        if NOT available buf0_hist-nws-option
        or (available buf0_hist-nws-option
            and
                (buf0_hist-nws-option.smart-nws = integer({&hn-is-off})
                  or buf0_hist-nws-option.smart-nws = integer({&hn-is-off-blocked}))
            )
        then do:
          for each buf_prop-ref no-lock where
                  buf_prop-ref.dtm-code = buf_prop-head.dtm-code:
            create buf_rrdb-option.
            assign
            buf_rrdb-option.first-table-name = {&table_dis-card}
            buf_rrdb-option.first-table-export = no
            buf_rrdb-option.second-table-name = {&table_dis-obj}
            buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                'each ub.dis-obj no-lock where ub.dis-obj.d-card = ub.dis-card.d-card and ' +
                                                'ub.dis-obj.dt-code = &3'
                                                  , buf_dis-card-type.emitent-host-code
                                                  , buf_dis-card-type.type
                                                  , buf_prop-ref.dt-code
                                                  )
            buf_rrdb-option.if-phrase = ''
            buf_rrdb-option.dump-point = "ref"
            buf_rrdb-option.subject-group = "dc"
            buf_rrdb-option.id = rest-rdb_id + 1
            buf_rrdb-option.des = substitute("dis-obj: type = &1 dtm-code = &2 dt-code = &3"
                                            , buf_dis-card-type.type
                                            ,buf_prop-head.dtm-code
                                            ,buf_prop-ref.dt-code
                                            )
            rest-rdb_id = rest-rdb_id + 1
            .
            if p-unload-history then do:
              if not available buf0_hist-nws-option
              or buf0_hist-nws-option.get-hist-from-nws  >= 0
              or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
                create buf_rrdb-option.
                assign
                buf_rrdb-option.first-table-name = {&table_dis-card}
                buf_rrdb-option.first-table-export = no
                buf_rrdb-option.second-table-name = {&table_c-dis-obj}
                buf_rrdb-option.third-table-name = {&table_c-dc-hist}
                buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                    'each ub.c-dis-obj no-lock where ub.c-dis-obj.d-card = ub.dis-card.d-card and ' +
                                                    'ub.c-dis-obj.dt-code = &3, ' +
                                                    'first ub.c-dc-hist no-lock where ' +
                                                    'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                                    'ub.c-dc-hist.corr-user-db-num = ub.c-dis-obj.corr-user-db-num and ' +
                                                    'ub.c-dc-hist.chip-num = ub.c-dis-obj.chip-num '
                                                      , buf_dis-card-type.emitent-host-code
                                                      , buf_dis-card-type.type
                                                      , buf_prop-ref.dt-code
                                                      )
                buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                          or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                        then '':U
                                        else "if-self")
                buf_rrdb-option.if-buffer-num = 2
                buf_rrdb-option.dump-point = "ref"
                buf_rrdb-option.subject-group = "dc"
                buf_rrdb-option.id = rest-rdb_id + 1
                buf_rrdb-option.des = substitute("c-dis-obj: type = &1 dtm-code = &2 dt-code = &3"
                                                , buf_dis-card-type.type
                                                ,buf_prop-head.dtm-code
                                                ,buf_prop-ref.dt-code
                                                )

                rest-rdb_id = rest-rdb_id + 1
                .
              end.
            end. /*if p-unload-history then do:*/
          end. /*          for each buf_prop-ref no-lock where*/
        end. /*if NOT available buf0_hist-nws-option*/
        if available buf0_hist-nws-option
        and (buf0_hist-nws-option.smart-nws = integer({&hn-is-on})
             or
             buf0_hist-nws-option.smart-nws = integer({&hn-is-on-blocked})
            ) then do:
          for each buf_prop-ref no-lock where
                  buf_prop-ref.dtm-code = buf_prop-head.dtm-code:
            find first buf_dis-obj no-lock where
                    buf_dis-obj.dt-code = buf_prop-ref.dt-code no-error.
            if available buf_dis-obj then do:
              create buf_rrdb-option.
              assign
              buf_rrdb-option.first-table-name = {&table_dis-card}
              buf_rrdb-option.first-table-export = no
              buf_rrdb-option.second-table-name = {&table_dis-obj}
              buf_rrdb-option.third-table-name = {&table_clients}
              buf_rrdb-option.third-table-export = no
              buf_rrdb-option.fourth-table-name = substitute("buf_&1", {&table_dis-obj})
              buf_rrdb-option.fourth-table-export = no
              buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                  'each ub.dis-obj no-lock where ub.dis-obj.d-card = ub.dis-card.d-card and ' +
                                                  'ub.dis-obj.dt-code = &3,' +
                                                  'first ub.clients no-lock where ub.clients.db-num = &4, ' +
                                                  'first buf_dis-obj no-lock where buf_dis-obj.d-card = ub.dis-card.d-card and ' +
                                                  'buf_dis-obj.obj-type = ub.clients.obj-type and buf_dis-obj.obj-code = ub.clients.obj-code '
                                                  , buf_dis-card-type.emitent-host-code
                                                  , buf_dis-card-type.type
                                                  , buf_prop-ref.dt-code
                                                  ,p-db-num
                                                    )
              buf_rrdb-option.if-phrase = ''
              buf_rrdb-option.dump-point = "ref"
              buf_rrdb-option.subject-group = "dc"
              buf_rrdb-option.id = rest-rdb_id + 1
              buf_rrdb-option.des = substitute("dis-obj: type = &1 dtm-code = &2 dt-code = &3"
                                              , buf_dis-card-type.type
                                              ,buf_prop-head.dtm-code
                                              ,buf_prop-ref.dt-code
                                              )
              rest-rdb_id = rest-rdb_id + 1
              .
              if p-unload-history then do:
                if not available buf0_hist-nws-option
                or buf0_hist-nws-option.get-hist-from-nws  >= 0
                or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
                  create buf_rrdb-option.
                  assign
                  buf_rrdb-option.first-table-name = {&table_dis-card}
                  buf_rrdb-option.first-table-export = no
                  buf_rrdb-option.second-table-name = {&table_c-dis-obj}
                  buf_rrdb-option.third-table-name = {&table_c-dc-hist}
                  buf_rrdb-option.fourth-table-name = {&table_clients}
                  buf_rrdb-option.fourth-table-export = no
                  buf_rrdb-option.fifth-table-name = substitute("buf_&1", {&table_dis-obj})
                  buf_rrdb-option.fifth-table-export = no
                  buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                      'each ub.c-dis-obj no-lock where ub.c-dis-obj.d-card = ub.dis-card.d-card and ' +
                                                      'ub.c-dis-obj.dt-code = &3, ' +
                                                      'first ub.c-dc-hist no-lock where ' +
                                                      'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                                      'ub.c-dc-hist.corr-user-db-num = ub.c-dis-obj.corr-user-db-num and ' +
                                                      'ub.c-dc-hist.chip-num = ub.c-dis-obj.chip-num, ' +
                                                      'first ub.clients no-lock where ub.clients.db-num = &4, ' +
                                                      'first buf_dis-obj no-lock where buf_dis-obj.d-card = ub.dis-card.d-card and ' +
                                                      'buf_dis-obj.obj-type = ub.clients.obj-type and buf_dis-obj.obj-code = ub.clients.obj-code '
                                                      , buf_dis-card-type.emitent-host-code
                                                      , buf_dis-card-type.type
                                                      , buf_prop-ref.dt-code
                                                      , p-db-num
                                                      )
                  buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                          or (buf0_hist-nws-option.hist-to-nws  >= 0
                                          and buf0_hist-nws-option.get-hist-from-nws  >= 0)
                                          then '':U
                                          else "if-self")
                  buf_rrdb-option.if-buffer-num = 2
                  buf_rrdb-option.dump-point = "ref"
                  buf_rrdb-option.subject-group = "dc"
                  buf_rrdb-option.id = rest-rdb_id + 1
                  buf_rrdb-option.des = substitute("c-dis-obj: type = &1 dtm-code = &2 dt-code = &3"
                                                  , buf_dis-card-type.type
                                                  ,buf_prop-head.dtm-code
                                                  ,buf_prop-ref.dt-code
                                                  )
                  rest-rdb_id = rest-rdb_id + 1
                  .
                end.
              end. /*if p-unload-history then do:*/
            end. /*if available buf_dis-obj*/
          end. /*          for each buf_prop-ref no-lock where*/
        end. /*if available buf0_hist-nws-option and smart*/
        if available buf0_hist-nws-option
        and buf0_hist-nws-option.smart-nws = integer({&hn-is-smart2})
        then do:
          for each buf_prop-ref no-lock where
                  buf_prop-ref.dtm-code = buf_prop-head.dtm-code:
          for each buf_clients no-lock where
              buf_clients.db-num = p-db-num,
            first buf_dis-obj no-lock where
                      buf_Dis-obj.dt-code = buf_prop-ref.dt-code
                and  buf_Dis-obj.obj-type = buf_clients.obj-type
                and  buf_Dis-obj.obj-code = buf_clients.obj-code:
            leave.
            /*найдем вообще велись ли по этому опреанду итоги*/
          end. /*  for each buf_clients no-lock where*/
          if available buf_dis-obj then do:
              create buf_rrdb-option.
              assign
              buf_rrdb-option.first-table-name = {&table_dis-card}
              buf_rrdb-option.first-table-export = no
              buf_rrdb-option.second-table-name = {&table_dis-obj}
              buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                  'each ub.dis-obj no-lock where ub.dis-obj.d-card = ub.dis-card.d-card and ' +
                                                  'ub.dis-obj.dt-code = &3 and ' +
                                                  'ub.dis-obj.obj-type = "&&1" and ' +
                                                  'ub.dis-obj.obj-code = &&2 '
                                                    , buf_dis-card-type.emitent-host-code
                                                    , buf_dis-card-type.type
                                                    , buf_prop-ref.dt-code
                                                    )
              buf_rrdb-option.if-phrase = ''
              buf_rrdb-option.dump-point = "obj"
              buf_rrdb-option.subject-group = "dc"
              buf_rrdb-option.id = rest-rdb_id + 1
              buf_rrdb-option.des = substitute("dis-obj: type = &1 dtm-code = &2 dt-code = &3"
                                              , buf_dis-card-type.type
                                              ,buf_prop-head.dtm-code
                                              ,buf_prop-ref.dt-code
                                              )
              rest-rdb_id = rest-rdb_id + 1
              .
              if p-unload-history then do:
                if not available buf0_hist-nws-option
                or buf0_hist-nws-option.get-hist-from-nws  >= 0
                or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
                  create buf_rrdb-option.
                  assign
                  buf_rrdb-option.first-table-name = {&table_dis-card}
                  buf_rrdb-option.first-table-export = no
                  buf_rrdb-option.second-table-name = {&table_c-dis-obj}
                  buf_rrdb-option.third-table-name = {&table_c-dc-hist}
                  buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                      'each ub.c-dis-obj no-lock where ub.c-dis-obj.d-card = ub.dis-card.d-card and ' +
                                                      'ub.c-dis-obj.dt-code = &3 and ' +
                                                      'ub.c-dis-obj.obj-type = "&&1" and ' +
                                                      'ub.c-dis-obj.obj-code = &&2, ' +
                                                      'first ub.c-dc-hist no-lock where ' +
                                                      'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                                      'ub.c-dc-hist.corr-user-db-num = ub.c-dis-obj.corr-user-db-num and ' +
                                                      'ub.c-dc-hist.chip-num = ub.c-dis-obj.chip-num '
                                                      , buf_dis-card-type.emitent-host-code
                                                      , buf_dis-card-type.type
                                                      , buf_prop-ref.dt-code
                                                      )
                  buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                            or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                          then '':U
                                          else "if-self")
                  buf_rrdb-option.if-buffer-num = 2
                  buf_rrdb-option.dump-point = "obj"
                  buf_rrdb-option.subject-group = "dc"
                  buf_rrdb-option.id = rest-rdb_id + 1
                  buf_rrdb-option.des = substitute("c-dis-obj: type = &1 dtm-code = &2 dt-code = &3"
                                                  , buf_dis-card-type.type
                                                  ,buf_prop-head.dtm-code
                                                  ,buf_prop-ref.dt-code
                                                  )
                  rest-rdb_id = rest-rdb_id + 1
                  .
                end.
              end. /*if p-unload-history then do:*/
            end. /*if available buf_dis-obj*/
          end. /*for each prop-ref*/
        end. /*smart2*/
      end. /*if buf_prop-head.storage-place-obj = {&table_dis-obj} then do:*/
      if buf_prop-head.storage-place-obj = {&table_dis-card-property} then do:
        find first buf0_hist-nws-option where
                  buf0_hist-nws-option.table-name = {&table_dis-card-property}
              and buf0_hist-nws-option.db-num = 0
              and buf0_hist-nws-option.host-code = buf_dis-card-type.emitent-host-code
              and buf0_hist-nws-option.charkey_one = buf_Dis-card-type.type
              and buf0_hist-nws-option.charkey_two = '':U
              and buf0_hist-nws-option.charkey_three = '':U
              and buf0_hist-nws-option.key#_one = buf_prop-head.dtm-code
              and buf0_hist-nws-option.key#_two = 0
              and buf0_hist-nws-option.key#_three = 0
              and buf0_hist-nws-option.obj-type = ''
              and buf0_hist-nws-option.obj-code = 0
              no-error .
         if not available buf0_hist-nws-option
         or (available buf0_hist-nws-option
             and
              (buf0_hist-nws-option.smart-nws = integer({&hn-is-off})
               or
               buf0_hist-nws-option.smart-nws = integer({&hn-is-off-blocked})
               )
             )
         then do:
          create buf_rrdb-option.
          assign
          buf_rrdb-option.first-table-name = {&table_dis-card}
          buf_rrdb-option.first-table-export = no
          buf_rrdb-option.second-table-name = {&table_dis-card-property}
          buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                              'each ub.dis-card-property where ub.dis-card-property.d-card = ub.dis-card.d-card and ' +
                                              'ub.dis-card-property.dtm-code = &3'
                                                , buf_dis-card-type.emitent-host-code
                                                , buf_dis-card-type.type
                                                , buf_prop-head.dtm-code
                                                )
          buf_rrdb-option.if-phrase = ''
          buf_rrdb-option.dump-point = "ref"
          buf_rrdb-option.subject-group = "dc"
          buf_rrdb-option.id = rest-rdb_id + 1
          buf_rrdb-option.des = substitute("dis-card-property: type = &1 dtm-code = &2"
                                          , buf_dis-card-type.type
                                          ,buf_prop-head.dtm-code
                                          )
          rest-rdb_id = rest-rdb_id + 1
          .
          if p-unload-history then do:
            if not available buf0_hist-nws-option
            or buf0_hist-nws-option.get-hist-from-nws  >= 0
            or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
              create buf_rrdb-option.
              assign
              buf_rrdb-option.first-table-name = {&table_dis-card}
              buf_rrdb-option.first-table-export = no
              buf_rrdb-option.second-table-name = {&table_c-dis-card-property}
              buf_rrdb-option.third-table-name = {&table_c-dc-hist}
              buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                  'each ub.c-dis-card-property where ub.c-dis-card-property.d-card = ub.dis-card.d-card and ' +
                                                  'ub.c-dis-card-property.dtm-code = &3,  ' +
                                                  'first ub.c-dc-hist no-lock where ' +
                                                  'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                                  'ub.c-dc-hist.corr-user-db-num = ub.c-dis-card-property.corr-user-db-num and ' +
                                                  'ub.c-dc-hist.chip-num = ub.c-dis-card-property.chip-num '
                                                    , buf_dis-card-type.emitent-host-code
                                                    , buf_dis-card-type.type
                                                    , buf_prop-head.dtm-code
                                                    )
              buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                        or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                      then '':U
                                      else "if-self")
              buf_rrdb-option.if-buffer-num = 2
              buf_rrdb-option.dump-point = "ref"
              buf_rrdb-option.subject-group = "dc"
              buf_rrdb-option.id = rest-rdb_id + 1
              buf_rrdb-option.des = substitute("c-dis-card-property: type = &1 dtm-code = &2"
                                              , buf_dis-card-type.type
                                              ,buf_prop-head.dtm-code
                                              )
              rest-rdb_id = rest-rdb_id + 1
              .
            end.
           end. /*if p-unload-history then do:*/
         end. /*not smart*/
         if available buf0_hist-nws-option
         and
         (buf0_hist-nws-option.smart-nws = integer({&hn-is-on})
          or
          buf0_hist-nws-option.smart-nws = integer({&hn-is-on-blocked})
          )
         then do:
          create buf_rrdb-option.
          assign
          buf_rrdb-option.first-table-name = {&table_dis-card}
          buf_rrdb-option.first-table-export = no
          buf_rrdb-option.second-table-name = {&table_dis-card-property}
          buf_rrdb-option.third-table-name = {&table_clients}
          buf_rrdb-option.third-table-export = no
          buf_rrdb-option.fourth-table-name = {&table_dis-obj}
          buf_rrdb-option.fourth-table-export = no
          buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                              'each ub.dis-card-property where ub.dis-card-property.d-card = ub.dis-card.d-card and ' +
                                              'ub.dis-card-property.dtm-code = &3,' +
                                              'first ub.clients no-lock where ub.clients.db-num = &4, ' +
                                              'first ub.dis-obj no-lock where ub.dis-obj.d-card = ub.dis-card.d-card and ' +
                                              'ub.dis-obj.obj-type = ub.clients.obj-type and ub.dis-obj.obj-code = ub.clients.obj-code '
                                              , buf_dis-card-type.emitent-host-code
                                              , buf_dis-card-type.type
                                              , buf_prop-head.dtm-code
                                              , p-db-num
                                                )
          buf_rrdb-option.if-phrase = ''
          buf_rrdb-option.dump-point = "ref"
          buf_rrdb-option.subject-group = "dc"
          buf_rrdb-option.id = rest-rdb_id + 1
          buf_rrdb-option.des = substitute("dis-card-property: type = &1 dtm-code = &2"
                                          , buf_dis-card-type.type
                                          ,buf_prop-head.dtm-code
                                          )
          rest-rdb_id = rest-rdb_id + 1
          .
          if p-unload-history then do:
            if not available buf0_hist-nws-option
            or buf0_hist-nws-option.get-hist-from-nws  >= 0
            or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
              create buf_rrdb-option.
              assign
              buf_rrdb-option.first-table-name = {&table_dis-card}
              buf_rrdb-option.first-table-export = no
              buf_rrdb-option.second-table-name = {&table_c-dis-card-property}
              buf_rrdb-option.third-table-name = {&table_c-dc-hist}
              buf_rrdb-option.fourth-table-name = {&table_clients}
              buf_rrdb-option.fourth-table-export = no
              buf_rrdb-option.fifth-table-name = {&table_dis-obj}
              buf_rrdb-option.fifth-table-export = no
              buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                  'each ub.c-dis-card-property where ub.c-dis-card-property.d-card = ub.dis-card.d-card and ' +
                                                  'ub.c-dis-card-property.dtm-code = &3,  ' +
                                                  'first ub.c-dc-hist no-lock where ' +
                                                  'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                                  'ub.c-dc-hist.corr-user-db-num = ub.c-dis-card-property.corr-user-db-num and ' +
                                                  'ub.c-dc-hist.chip-num = ub.c-dis-card-property.chip-num, ' +
                                                  'first ub.clients no-lock where ub.clients.db-num = &4, ' +
                                                  'first ub.dis-obj no-lock where ub.dis-obj.d-card = ub.dis-card.d-card and ' +
                                                  'ub.dis-obj.obj-type = ub.clients.obj-type and ub.dis-obj.obj-code = ub.clients.obj-code '
                                                  , buf_dis-card-type.emitent-host-code
                                                  , buf_dis-card-type.type
                                                  , buf_prop-head.dtm-code
                                                  , p-db-num
                                                    )
              buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                        or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                      then '':U
                                      else "if-self")
              buf_rrdb-option.if-buffer-num = 2
              buf_rrdb-option.dump-point = "ref"
              buf_rrdb-option.subject-group = "dc"
              buf_rrdb-option.id = rest-rdb_id + 1
              buf_rrdb-option.des = substitute("c-dis-card-property: type = &1 dtm-code = &2"
                                              , buf_dis-card-type.type
                                              ,buf_prop-head.dtm-code
                                              )
              rest-rdb_id = rest-rdb_id + 1
              .
            end.
           end. /*if p-unload-history then do:*/
         end.
         if available buf0_hist-nws-option
         and buf0_hist-nws-option.smart-nws = integer({&hn-is-smart2}) then do:
          create buf_rrdb-option.
          assign
          buf_rrdb-option.first-table-name = {&table_dis-card}
          buf_rrdb-option.first-table-export = no
          buf_rrdb-option.second-table-name = {&table_dis-card-property}
          buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                              'each ub.dis-card-property where ub.dis-card-property.d-card = ub.dis-card.d-card and ' +
                                              'ub.dis-card-property.dtm-code = &3 and ' +
                                              'ub.dis-card-property.obj-type = "&&1" and ' +
                                              'ub.dis-card-property.obj-code = &&2 '
                                                , buf_dis-card-type.emitent-host-code
                                                , buf_dis-card-type.type
                                                , buf_prop-head.dtm-code
                                                )
          buf_rrdb-option.if-phrase = ''
          buf_rrdb-option.dump-point = "obj"
          buf_rrdb-option.subject-group = "dc"
          buf_rrdb-option.id = rest-rdb_id + 1
          buf_rrdb-option.des = substitute("dis-card-property: type = &1 dtm-code = &2"
                                          , buf_dis-card-type.type
                                          ,buf_prop-head.dtm-code
                                          )
          rest-rdb_id = rest-rdb_id + 1
          .
          if p-unload-history then do:
            if not available buf0_hist-nws-option
            or buf0_hist-nws-option.get-hist-from-nws  >= 0
            or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
              create buf_rrdb-option.
              assign
              buf_rrdb-option.first-table-name = {&table_dis-card}
              buf_rrdb-option.first-table-export = no
              buf_rrdb-option.second-table-name = {&table_c-dis-card-property}
              buf_rrdb-option.third-table-name = {&table_c-dc-hist}
              buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                  'each ub.c-dis-card-property where ub.c-dis-card-property.d-card = ub.dis-card.d-card and ' +
                                                  'ub.c-dis-card-property.dtm-code = &3 and ' +
                                                  'ub.c-dis-card-property.obj-type = "&&1" and ' +
                                                  'ub.c-dis-card-property.obj-code = &&2, ' +
                                                  'first ub.c-dc-hist no-lock where ' +
                                                  'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                                  'ub.c-dc-hist.corr-user-db-num = ub.c-dis-card-property.corr-user-db-num and ' +
                                                  'ub.c-dc-hist.chip-num = ub.c-dis-card-property.chip-num '
                                                    , buf_dis-card-type.emitent-host-code
                                                    , buf_dis-card-type.type
                                                    , buf_prop-head.dtm-code
                                                    )
              buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                        or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                      then '':U
                                      else "if-self")
              buf_rrdb-option.if-buffer-num = 2
              buf_rrdb-option.dump-point = "obj"
              buf_rrdb-option.subject-group = "dc"
              buf_rrdb-option.id = rest-rdb_id + 1
              buf_rrdb-option.des = substitute("c-dis-card-property: type = &1 dtm-code = &2"
                                              , buf_dis-card-type.type
                                              ,buf_prop-head.dtm-code
                                              )
              rest-rdb_id = rest-rdb_id + 1
              .
            end.
           end. /*if p-unload-history then do:*/
         end.
      end. /*if buf_prop-head.storage-place-obj = {&table_dis-card-property} then do:*/
      if buf_prop-head.storage-place-obj = {&table_dis-card} then do:
        find first buf0_hist-nws-option where
                  buf0_hist-nws-option.table-name = {&table_dis-card}
              and buf0_hist-nws-option.db-num = 0
              and buf0_hist-nws-option.host-code = buf_dis-card-type.emitent-host-code
              and buf0_hist-nws-option.charkey_one = buf_Dis-card-type.type
              and buf0_hist-nws-option.charkey_two = '':U
              and buf0_hist-nws-option.charkey_three = '':U
              and buf0_hist-nws-option.key#_one = buf_prop-head.dtm-code
              and buf0_hist-nws-option.key#_two = 0
              and buf0_hist-nws-option.key#_three = 0
              and buf0_hist-nws-option.obj-type = ''
              and buf0_hist-nws-option.obj-code = 0
              no-error .
          if p-unload-history then do:
            if not available buf0_hist-nws-option
            or buf0_hist-nws-option.get-hist-from-nws  >= 0
            or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
              create buf_rrdb-option.
              assign
              buf_rrdb-option.first-table-name = {&table_dis-card}
              buf_rrdb-option.first-table-export = no
              buf_rrdb-option.second-table-name = {&table_c-dis-card}
              buf_rrdb-option.third-table-name = {&table_c-dc-hist}
              buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                                  'each ub.c-dis-card where ub.c-dis-card.d-card = ub.dis-card.d-card,' +
                                                  'first ub.c-dc-hist no-lock where ' +
                                                  'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                                  'ub.c-dc-hist.corr-user-db-num = ub.c-dis-card.corr-user-db-num and ' +
                                                  'ub.c-dc-hist.chip-num = ub.c-dis-card.chip-num '
                                                    , buf_dis-card-type.emitent-host-code
                                                    , buf_dis-card-type.type
                                                    )
              buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                        or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                      then '':U
                                      else "if-self")
              buf_rrdb-option.if-buffer-num = 2
              buf_rrdb-option.dump-point = "ref"
              buf_rrdb-option.subject-group = "dc"
              buf_rrdb-option.id = rest-rdb_id + 1
              buf_rrdb-option.des = substitute("c-dis-card: type = &1"
                                              , buf_dis-card-type.type
                                              )
              rest-rdb_id = rest-rdb_id + 1
              .
          end.
        end. /*if p-unload-history then do:*/
      end. /*if buf_prop-head.storage-place-obj = {&table_dis-card} then do:*/
    end. /*    for each buf_prop-head where*/
    find first buf0_hist-nws-option where
              buf0_hist-nws-option.table-name = {&table_dis-dc-rule}
          and buf0_hist-nws-option.db-num = p-db-num
          and buf0_hist-nws-option.host-code = buf_dis-card-type.emitent-host-code
          and buf0_hist-nws-option.charkey_one = buf_Dis-card-type.type
          and buf0_hist-nws-option.charkey_two = '':U
          and buf0_hist-nws-option.charkey_three = '':U
          and buf0_hist-nws-option.key#_one = 0
          and buf0_hist-nws-option.key#_two = 0
          and buf0_hist-nws-option.key#_three = 0
          and buf0_hist-nws-option.obj-type = ''
          and buf0_hist-nws-option.obj-code = 0
          no-error .
    if not available buf0_hist-nws-option
    or (available buf0_hist-nws-option
        and
        (buf0_hist-nws-option.smart-nws = integer({&hn-is-off})
         or
         buf0_hist-nws-option.smart-nws = integer({&hn-is-off-blocked})
        )
       ) then do:
      create buf_rrdb-option.
      assign
      buf_rrdb-option.first-table-name = {&table_dis-card}
      buf_rrdb-option.first-table-export = no
      buf_rrdb-option.second-table-name = {&table_dis-dc-rule}
      buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                          'each ub.dis-dc-rule where ub.dis-dc-rule.d-card = ub.dis-card.d-card and ub.dis-dc-rule.obj-type > "&3"'
                                            , buf_dis-card-type.emitent-host-code
                                            , buf_dis-card-type.type
                                            , ''
                                            )
      buf_rrdb-option.if-phrase = ''
      buf_rrdb-option.dump-point = "ref"
      buf_rrdb-option.subject-group = "dc"
      buf_rrdb-option.id = rest-rdb_id + 1
      buf_rrdb-option.des = substitute("dis-dc-rule: type = &1"
                                      , buf_dis-card-type.type
                                      )
      rest-rdb_id = rest-rdb_id + 1
      .
      if p-unload-history then do:
        if not available buf0_hist-nws-option
        or buf0_hist-nws-option.get-hist-from-nws  >= 0
        or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
          create buf_rrdb-option.
          assign
          buf_rrdb-option.first-table-name = {&table_dis-card}
          buf_rrdb-option.first-table-export = no
          buf_rrdb-option.second-table-name = {&table_c-dis-dc-rule}
          buf_rrdb-option.third-table-name = {&table_c-dc-hist}
          buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                              'each ub.c-dis-dc-rule where ub.c-dis-dc-rule.d-card = ub.dis-card.d-card and ub.c-dis-dc-rule.obj-type > "&3", ' +
                                              'first ub.c-dc-hist no-lock where ' +
                                              'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                              'ub.c-dc-hist.corr-user-db-num = ub.c-dis-dc-rule.corr-user-db-num and ' +
                                              'ub.c-dc-hist.chip-num = ub.c-dis-dc-rule.chip-num '
                                                , buf_dis-card-type.emitent-host-code
                                                , buf_dis-card-type.type
                                                , ''
                                                )
          buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                    or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                  then '':U
                                  else "if-self")
          buf_rrdb-option.if-buffer-num = 2
          buf_rrdb-option.dump-point = "ref"
          buf_rrdb-option.subject-group = "dc"
          buf_rrdb-option.id = rest-rdb_id + 1
          buf_rrdb-option.des = substitute("c-dis-dc-rule: type = &1"
                                          , buf_dis-card-type.type
                                          )
          rest-rdb_id = rest-rdb_id + 1
          .
        end.
      end. /*if p-unload-history then do:*/
    end. /*no-smart*/
    if available buf0_hist-nws-option
    and
        (buf0_hist-nws-option.smart-nws = integer({&hn-is-on})
         or
         buf0_hist-nws-option.smart-nws = integer({&hn-is-on-blocked})
        )
     then do:
      create buf_rrdb-option.
      assign
      buf_rrdb-option.first-table-name = {&table_dis-card}
      buf_rrdb-option.first-table-export = no
      buf_rrdb-option.second-table-name = {&table_dis-dc-rule}
      buf_rrdb-option.third-table-name = {&table_clients}
      buf_rrdb-option.third-table-export = no
      buf_rrdb-option.fourth-table-name = {&table_dis-obj}
      buf_rrdb-option.fourth-table-export = no
      buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                          'each ub.dis-dc-rule where ub.dis-dc-rule.d-card = ub.dis-card.d-card, ' +
                                          'first ub.clients no-lock where ub.clients.db-num = &43  and ub.clients.obj-type = ub.dis-dc-rule.obj-type and ub.clients.obj-code = ub.dis-dc-rule.obj-code, ' +
                                          'first ub.dis-obj no-lock where ub.dis-obj.d-card = ub.dis-card.d-card and ' +
                                          'ub.dis-obj.obj-type = ub.clients.obj-type and ub.dis-obj.obj-code = ub.clients.obj-code '
                                          , buf_dis-card-type.emitent-host-code
                                          , buf_dis-card-type.type
                                          , p-db-num
                                            )
      buf_rrdb-option.if-phrase = ''
      buf_rrdb-option.dump-point = "ref"
      buf_rrdb-option.subject-group = "dc"
      buf_rrdb-option.id = rest-rdb_id + 1
      buf_rrdb-option.des = substitute("dis-dc-rule: type = &1"
                                      , buf_dis-card-type.type
                                      )
      rest-rdb_id = rest-rdb_id + 1
      .
      if p-unload-history then do:
        if not available buf0_hist-nws-option
        or buf0_hist-nws-option.get-hist-from-nws  >= 0
        or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
          create buf_rrdb-option.
          assign
          buf_rrdb-option.first-table-name = {&table_dis-card}
          buf_rrdb-option.first-table-export = no
          buf_rrdb-option.second-table-name = {&table_c-dis-dc-rule}
          buf_rrdb-option.third-table-name = {&table_c-dc-hist}
          buf_rrdb-option.fourth-table-name = {&table_clients}
          buf_rrdb-option.fourth-table-export = no
          buf_rrdb-option.fifth-table-name = {&table_dis-obj}
          buf_rrdb-option.fifth-table-export = no
          buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                              'each ub.c-dis-dc-rule where ub.c-dis-dc-rule.d-card = ub.dis-card.d-card, ' +
                                              'first ub.c-dc-hist no-lock where ' +
                                              'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                              'ub.c-dc-hist.corr-user-db-num = ub.c-dis-dc-rule.corr-user-db-num and ' +
                                              'ub.c-dc-hist.chip-num = ub.c-dis-dc-rule.chip-num, ' +
                                              'first ub.clients no-lock where ub.clients.db-num = &3 and ub.clients.obj-type = ub.c-dis-dc-rule.obj-type and ub.clients.obj-code = ub.c-dis-dc-rule.obj-code , ' +
                                              'first ub.dis-obj no-lock where ub.dis-obj.d-card = ub.dis-card.d-card and ' +
                                              'ub.dis-obj.obj-type = ub.clients.obj-type and ub.dis-obj.obj-code = ub.clients.obj-code '
                                                , buf_dis-card-type.emitent-host-code
                                                , buf_dis-card-type.type
                                                , p-db-num
                                                )
          buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                    or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                  then '':U
                                  else "if-self")
          buf_rrdb-option.if-buffer-num = 2
          buf_rrdb-option.dump-point = "ref"
          buf_rrdb-option.subject-group = "dc"
          buf_rrdb-option.id = rest-rdb_id + 1
          buf_rrdb-option.des = substitute("c-dis-dc-rule: type = &1"
                                          , buf_dis-card-type.type
                                          )
          rest-rdb_id = rest-rdb_id + 1
          .
        end.
      end. /*if p-unload-history then do:*/
    end. /*smart*/
    if available buf0_hist-nws-option
    and buf0_hist-nws-option.smart-nws = integer({&hn-is-smart2}) then do:
      create buf_rrdb-option.
      assign
      buf_rrdb-option.first-table-name = {&table_dis-card}
      buf_rrdb-option.first-table-export = no
      buf_rrdb-option.second-table-name = {&table_dis-dc-rule}
      buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                          'each ub.dis-dc-rule where ub.dis-dc-rule.d-card = ub.dis-card.d-card and ' +
                                          'ub.dis-dc-rule.obj-type = "&&1" and ' +
                                          'ub.dis-dc-rule.obj-code = &&2'
                                            , buf_dis-card-type.emitent-host-code
                                            , buf_dis-card-type.type
                                            )
      buf_rrdb-option.if-phrase = ''
      buf_rrdb-option.dump-point = "obj"
      buf_rrdb-option.subject-group = "dc"
      buf_rrdb-option.id = rest-rdb_id + 1
      buf_rrdb-option.des = substitute("dis-dc-rule: type = &1"
                                      , buf_dis-card-type.type
                                      )
      rest-rdb_id = rest-rdb_id + 1
      .
      if p-unload-history then do:
        if not available buf0_hist-nws-option
        or buf0_hist-nws-option.get-hist-from-nws  >= 0
        or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
          create buf_rrdb-option.
          assign
          buf_rrdb-option.first-table-name = {&table_dis-card}
          buf_rrdb-option.first-table-export = no
          buf_rrdb-option.second-table-name = {&table_c-dis-dc-rule}
          buf_rrdb-option.third-table-name = {&table_c-dc-hist}
          buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                              'each ub.c-dis-dc-rule where ub.c-dis-dc-rule.d-card = ub.dis-card.d-card and ' +
                                              'ub.c-dis-dc-rule.obj-type = "&&1" and ' +
                                              'ub.c-dis-dc-rule.obj-code = &&2, ' +
                                              'first ub.c-dc-hist no-lock where ' +
                                              'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                              'ub.c-dc-hist.corr-user-db-num = ub.c-dis-dc-rule.corr-user-db-num and ' +
                                              'ub.c-dc-hist.chip-num = ub.c-dis-dc-rule.chip-num '
                                                , buf_dis-card-type.emitent-host-code
                                                , buf_dis-card-type.type
                                                )
          buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                    or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                  then '':U
                                  else "if-self")
          buf_rrdb-option.if-buffer-num = 2
          buf_rrdb-option.dump-point = "obj"
          buf_rrdb-option.subject-group = "dc"
          buf_rrdb-option.id = rest-rdb_id + 1
          buf_rrdb-option.des = substitute("c-dis-dc-rule: type = &1"
                                          , buf_dis-card-type.type
                                          )

          rest-rdb_id = rest-rdb_id + 1
          .
        end.
      end. /*if p-unload-history then do:*/
    end. /*smart2*/
    find first buf0_hist-nws-option where
            buf0_hist-nws-option.table-name = {&table_dis-card-long}
        and buf0_hist-nws-option.db-num = p-db-num
        and buf0_hist-nws-option.host-code = buf_dis-card-type.emitent-host-code
        and buf0_hist-nws-option.charkey_one = buf_Dis-card-type.type
        and buf0_hist-nws-option.charkey_two = '':U
        and buf0_hist-nws-option.charkey_three = '':U
        and buf0_hist-nws-option.key#_one = 0
        and buf0_hist-nws-option.key#_two = 0
        and buf0_hist-nws-option.key#_three = 0
        and buf0_hist-nws-option.obj-type = ''
        and buf0_hist-nws-option.obj-code = 0
        no-error .
    if p-unload-history then do:
      if not available buf0_hist-nws-option
      or buf0_hist-nws-option.get-hist-from-nws  >= 0
      or buf0_hist-nws-option.nws-to-hist  >= 0 then do:
        create buf_rrdb-option.
        assign
        buf_rrdb-option.first-table-name = {&table_dis-card}
        buf_rrdb-option.first-table-export = no
        buf_rrdb-option.second-table-name = {&table_c-dis-card-long}
        buf_rrdb-option.third-table-name = {&table_c-dc-hist}
        buf_rrdb-option.where-phrase = substitute('ub.dis-card.emitent-host-code = &1 and ub.dis-card.type = "&2", '  +
                                            'each ub.c-dis-card-long where ub.c-dis-card-long.d-card = ub.dis-card.d-card, ' +
                                            'first ub.c-dc-hist no-lock where ' +
                                            'ub.c-dc-hist.d-card = ub.dis-card.d-card and ' +
                                            'ub.c-dc-hist.corr-user-db-num = ub.c-dis-card-long.corr-user-db-num and ' +
                                            'ub.c-dc-hist.chip-num = ub.c-dis-card-long.chip-num '
                                              , buf_dis-card-type.emitent-host-code
                                              , buf_dis-card-type.type
                                              )
        buf_rrdb-option.if-phrase = (if not available buf0_hist-nws-option
                                  or buf0_hist-nws-option.get-hist-from-nws  >= 0
                                then '':U
                                else "if-self")
        buf_rrdb-option.if-buffer-num = 2
        buf_rrdb-option.dump-point = "ref"
        buf_rrdb-option.subject-group = "dc"
        buf_rrdb-option.id = rest-rdb_id + 1
        buf_rrdb-option.des = substitute("c-dis-card-long: type = &1"
                                        , buf_dis-card-type.type
                                        )
        rest-rdb_id = rest-rdb_id + 1
        .
      end.
    end. /*if p-unload-history then do:*/
  end.  /*for each dis-card-type*/
end. /*doe*/

end procedure. /* prepare-dc */


/* $Workfile$ e n d */