/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Препроцессинги и определения для утилиты испорта-экспорта локальных таблиц УБД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/09/05
Author: Bakhtadze Natalya
Creation date: 09/09/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable v-log-gap as logical no-undo .
define variable v-user-name    as character    no-undo.
define variable v-grp-name    as character    no-undo.
define variable v-arm-code    as character    no-undo.

&GLOBAL  ie-data-groups "rht,gen,flt,pbc,scl,usr,seq,cdr,cdk,thb,pet":U
&Global  ie-rht 1
&Global  ie-gen 2
&Global  ie-flt 3
&Global  ie-pbc 4
&Global  ie-scl 5
&Global  ie-usr 6
&Global  ie-seq 7
&Global  ie-cdrg 8
&Global  ie-cdk  9
&Global  ie-thb  10
&Global  ie-pet  11

&global  ie-sys-ctrl-fields     buf-sys-ctrl.cut-date ~
                                buf-sys-ctrl.db-num ~
                                buf-sys-ctrl.sys-date

&global  ie-config-fields       buf-config.conf-type ~
                                buf-config.host-code ~
                                buf-config.obj-code ~
                                buf-config.obj-type ~
                                buf-config.param-code ~
                                buf-config.param-encoded ~
                                buf-config.param-type ~
                                buf-config.param-value

&global  ie-config-fields-123   buf-config.conf-type ~
                                v-log-gap            ~
                                buf-config.host-code ~
                                buf-config.obj-code ~
                                buf-config.obj-type ~
                                buf-config.param-code ~
                                buf-config.param-encoded ~
                                buf-config.param-type ~
                                buf-config.param-value

&global  ie-config-fields-14    v-arm-code ~
                                buf-config.conf-type ~
                                v-grp-name ~
                                buf-config.host-code ~
                                buf-config.obj-code ~
                                buf-config.obj-type ~
                                buf-config.param-code ~
                                buf-config.param-encoded ~
                                buf-config.param-type ~
                                buf-config.param-value ~
                                v-user-name

&global  ie-filter-fields       buf-Filter.Fields-sort-rus ~
                                buf-Filter.Fields-sort ~
                                buf-Filter.Flds ~
                                buf-Filter.Naim ~
                                buf-Filter.Num-flt ~
                                buf-Filter.Tbl ~
                                buf-Filter.Where-ysl-rus ~
                                buf-Filter.Where-ysl ~
                                buf-Filter.call-point ~
                                buf-Filter.lst-cend

&global  ie-prod-bc-fields      buf-prod-bc.b-code ~
                                buf-prod-bc.b-str ~
                                buf-prod-bc.bc-on

&global  ie-gds-obj-attr-fields buf-gds-obj-attr.gds-code ~
                                buf-gds-obj-attr.obj-type ~
                                buf-gds-obj-attr.obj-code ~
                                buf-gds-obj-attr.attr-code ~
                                buf-gds-obj-attr.attr-value

&global  ie-scales-fields       buf-scales.address ~
                                buf-scales.db-num ~
                                buf-scales.master ~
                                buf-scales.max-gds ~
                                buf-scales.max-plu ~
                                buf-scales.scales-name ~
                                buf-scales.scales-num ~
                                buf-scales.scales-type ~
                                buf-scales.to-send ~
                                buf-scales.tot-gds ~
                                buf-scales.unit-base ~
                                buf-scales.wt-cart  ~
                                buf-scales.remote

&global  ie-scales-fields-141   buf-scales.address ~
                                buf-scales.master ~
                                buf-scales.max-gds ~
                                buf-scales.max-plu ~
                                buf-scales.scales-name ~
                                buf-scales.scales-num ~
                                buf-scales.scales-type ~
                                buf-scales.to-send ~
                                buf-scales.tot-gds ~
                                buf-scales.unit-base ~
                                buf-scales.wt-cart  ~
                                buf-scales.remote

&global  ie-scales-fields-123   buf-scales.address ~
                                buf-scales.master ~
                                buf-scales.max-gds ~
                                buf-scales.max-plu ~
                                buf-scales.scales-name ~
                                buf-scales.scales-num ~
                                buf-scales.scales-type ~
                                buf-scales.to-send ~
                                buf-scales.tot-gds ~
                                buf-scales.unit-base ~
                                buf-scales.wt-cart  ~

&global  ie-scales-gds-fields-123   buf-scales-gds.PLU-code ~
                                buf-scales-gds.b-code ~
                                buf-scales-gds.deadline ~
                                buf-scales-gds.obj-code ~
                                buf-scales-gds.obj-type ~
                                buf-scales-gds.scales-num ~
                                buf-scales-gds.to-del ~
                                buf-scales-gds.to-send ~
                                buf-scales-gds.wt-cart

&global  ie-scales-gds-fields   buf-scales-gds.PLU-code ~
                                buf-scales-gds.b-code ~
                                buf-scales-gds.db-num ~
                                buf-scales-gds.deadline ~
                                buf-scales-gds.obj-code ~
                                buf-scales-gds.obj-type ~
                                buf-scales-gds.scales-num ~
                                buf-scales-gds.to-del ~
                                buf-scales-gds.to-send ~
                                buf-scales-gds.wt-cart ~
                                buf-scales-gds.deaddate ~
                                buf-scales-gds.deadflag ~
                                buf-scales-gds.deadtime


&global ie-scales-grp-fields    buf-scales-grp.node-code ~
                                buf-scales-grp.scales-num

&global ie-usr-flt-fields       buf-usr-flt.Naim ~
                                buf-usr-flt.call-point ~
                                buf-usr-flt.user-name

&global ie-user-login-fields     buf-user-login.db-num ~
                                 buf-user-login.user-id ~
                                 buf-user-login.user-login ~
                                 buf-user-login.user-administrator ~
                                 buf-user-login.max-discnt ~
                                 buf-user-login.quest-print ~
                                 buf-user-login.status_

&global ie-user-account-fields   buf-user-account.user-id ~
                                 buf-user-account.status_ ~
                                 buf-user-account.first-name ~
                                 buf-user-account.second-name ~
                                 buf-user-account.last-name ~
                                 buf-user-account.company ~
                                 buf-user-account.department ~
                                 buf-user-account.e-mail ~
                                 buf-user-account.internal-phone-number ~
                                 buf-user-account.mobile-phone-number ~
                                 buf-user-account.phone-number ~
                                 buf-user-account.position ~
                                 buf-user-account.PS ~
                                 buf-user-account.room ~
                                 buf-user-account.parent-user-id ~
                                 buf-user-account.check-parent ~
                                 buf-user-account.nik

&global ie-user-obj-fields       buf-user-obj.db-num ~
                                 buf-user-obj.user-id ~
                                 buf-user-obj.obj-type ~
                                 buf-user-obj.obj-code ~
                                 buf-user-obj.host-code

&global ie-user-host-fields      buf-user-host.db-num ~
                                 buf-user-host.user-id ~
                                 buf-user-host.host-code

&global ie-user-menu-group-fields buf-user-menu-group.db-num ~
                                 buf-user-menu-group.user-id ~
                                 buf-user-menu-group.user-menu-group-code ~
                                 buf-user-menu-group.menu-code ~
                                 buf-user-menu-group.menu-group-code ~
                                 buf-user-menu-group.menu-group-id ~
                                 buf-user-menu-group.menu-group-context ~
                                 buf-user-menu-group.host-code ~
                                 buf-user-menu-group.obj-type ~
                                 buf-user-menu-group.obj-code

&global ie-user-login-action-role-fields   buf-user-login-action-role.db-num ~
                                 buf-user-login-action-role.action-head-code ~
                                 buf-user-login-action-role.user-login-role-code ~
                                 buf-user-login-action-role.user-id ~
                                 buf-user-login-action-role.action-role-code ~
                                 buf-user-login-action-role.action-role-context ~
                                 buf-user-login-action-role.host-code ~
                                 buf-user-login-action-role.obj-type ~
                                 buf-user-login-action-role.obj-code ~
                                 buf-user-login-action-role.gds-grp-code ~
                                 buf-user-login-action-role.gds-code ~
                                 buf-user-login-action-role.cli-grp-code

&global ie-action-role-fields      buf-action-role.db-num ~
                                 buf-action-role.action-head-code ~
                                 buf-action-role.action-role-code ~
                                 buf-action-role.action-role-context ~
                                 buf-action-role.action-role-name ~
                                 buf-action-role.action-role-description ~
                                 buf-action-role.whole-send-news

&global ie-action-role-item-fields buf-action-role-item.db-num ~
                                 buf-action-role-item.action-head-code ~
                                 buf-action-role-item.action-role-code ~
                                 buf-action-role-item.action-role-item-code ~
                                 buf-action-role-item.action-item-code ~
                                 buf-action-role-item.action-item-id ~
                                 buf-action-role-item.whole-send-news

&global ie-userconf-fields      buf-userconf.ARM ~
                                buf-userconf.max-discnt ~
                                buf-userconf.obj-code ~
                                buf-userconf.obj-type ~
                                buf-userconf.on-line ~
                                buf-userconf.user-name ~
                                buf-userconf.arm-host-code ~
                                buf-userconf.userid_ ~
                                buf-userconf.user-name_ ~
                                buf-userconf.password_

&global ie-userconf-fields-old  buf-userconf.ARM ~
                                buf-userconf.max-discnt ~
                                buf-userconf.obj-code ~
                                buf-userconf.obj-type ~
                                buf-userconf.on-line ~
                                buf-userconf.user-name ~
                                buf-userconf.userid_ ~
                                buf-userconf.user-name_ ~
                                buf-userconf.password_

&global ie-usr-grpa-fields      buf-usr-grpa.arm-code ~
                                buf-usr-grpa.grp-name ~
                                buf-usr-grpa.host-code ~
                                buf-usr-grpa.user-name

&global ie-usr-grpo-fields      buf-usr-grpo.grp-name ~
                                buf-usr-grpo.obj-code ~
                                buf-usr-grpo.obj-type ~
                                buf-usr-grpo.user-name

&global  ie-grpa-fields         buf-grpa.arm-code ~
                                buf-grpa.grp-name

&global  ie-grp-acta-fields     buf-grp-acta.act ~
                                buf-grp-acta.arm-code ~
                                buf-grp-acta.grp-name ~
                                buf-grp-acta.object

&global ie-cash-desk-fields     buf-cash-desk.addr-path ~
                                buf-cash-desk.autonomy ~
                                buf-cash-desk.cash-num ~
                                buf-cash-desk.cash-on ~
                                buf-cash-desk.cash-os ~
                                buf-cash-desk.obj-code ~
                                buf-cash-desk.pos-type ~
                                buf-cash-desk.registration-code ~
                                buf-cash-desk.remote ~
                                buf-cash-desk.serial-code ~
                                buf-cash-desk.version ~
                                buf-cash-desk.fr-type

&global ie-place-fields         buf-place.add-qnty ~
                                buf-place.is-meas  ~
                                buf-place.loc1 ~
                                buf-place.loc2  ~
                                buf-place.loc3  ~
                                buf-place.loc4  ~
                                buf-place.max-qnty ~
                                buf-place.obj-code ~
                                buf-place.obj-type ~
                                buf-place.pl-code  ~
                                buf-place.pl-name  ~
                                buf-place.PS       ~
                                buf-place.status_

&global ie-pump-fields          buf-pump.obj-code  ~
                                buf-pump.obj-type  ~
                                buf-pump.PS ~
                                buf-pump.pump-code ~
                                buf-pump.status_

&global ie-nozzle-fields        buf-nozzle.nozzle-code ~
                                buf-nozzle.obj-code ~
                                buf-nozzle.obj-type ~
                                buf-nozzle.PS ~
                                buf-nozzle.status_

&global ie-pl-gds-fields        buf-pl-gds.gds-code ~
                                buf-pl-gds.max-qnty ~
                                buf-pl-gds.obj-code ~
                                buf-pl-gds.obj-type ~
                                buf-pl-gds.pl-code  ~
                                buf-pl-gds.PS       ~
                                buf-pl-gds.status_  ~
                                buf-pl-gds.tolerance

&global ie-pl-pump-fields       buf-pl-pump.obj-code ~
                                buf-pl-pump.obj-type ~
                                buf-pl-pump.pl-code  ~
                                buf-pl-pump.PS       ~
                                buf-pl-pump.pump-code ~
                                buf-pl-pump.status_

&global ie-pl-gds-pump-fields   buf-pl-gds-pump.gds-code ~
                                buf-pl-gds-pump.obj-code ~
                                buf-pl-gds-pump.obj-type ~
                                buf-pl-gds-pump.pl-code  ~
                                buf-pl-gds-pump.PS       ~
                                buf-pl-gds-pump.pump-code ~
                                buf-pl-gds-pump.status_

&global ie-pl-pump-nozzle-fields       buf-pl-pump-nozzle.nozzle-code ~
                                buf-pl-pump-nozzle.obj-code  ~
                                buf-pl-pump-nozzle.obj-type  ~
                                buf-pl-pump-nozzle.pl-code   ~
                                buf-pl-pump-nozzle.PS        ~
                                buf-pl-pump-nozzle.pump-code  ~
                                buf-pl-pump-nozzle.status_

&global ie-pump-nozzle-fields          buf-pump-nozzle.is-meas  ~
                                buf-pump-nozzle.nozzle-code ~
                                buf-pump-nozzle.obj-code    ~
                                buf-pump-nozzle.obj-type    ~
                                buf-pump-nozzle.PS          ~
                                buf-pump-nozzle.pump-code   ~
                                buf-pump-nozzle.status_


&global load-sequence           'next-report,s-doc,s-doc-type,s-file-num,':U + ~
                                's-line-num,s-petrol-code,s-reserve2':U + ~
                                ',s-spool,s-task-num,s-tax-rate,synch-cli-grp,synch-gds-grp'

&global wl run write-log-and-file in p-log-handle (                    ~
          input 1                                                      ~
        , input log-file-name                                          ~
        , input 1                                                      ~
        , input substitute( "&1 .......", ~{&err-mes~} )) .

&global waitc  run write-log-and-file in p-log-handle (                ~
          input 1                                                      ~
        , input log-file-name                                          ~
        , input 1                                                      ~
        , input substitute( "!!!&1",  ~{&wait-mess~} ) ).

/* $Workfile$ e n d */