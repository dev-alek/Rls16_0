block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$
 
Программа генерации файла s t r - g l b l . i . Часть thbj-attr

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

Инструкции по использованию см в файле s t r - g l b l . p
 
*/
 
define input  parameter p-file-name    as character no-undo .
define output parameter p-num-lines    as character no-undo .
define output parameter p-vss-revision as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Программа генерации файла str-glbl.i".
{ cmp/vssrevis.i }
{ cmp/filwrlib.i }
{ cmp/tbl-name.i }
{ cmp/tblbname.i }
{ cmp/tblfname.i }

&glob language {1}

&glob tilda ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
&glob scop-begin ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~&
&glob scop-end   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

&if "{&language}" = "rus"  &then
  &glob lang-value        3
  &glob lang-description  4
&elseif "{&language}" = "eng" &then
  &glob lang-value        5
  &glob lang-description  6
&else
  message
    "Необходимо задать указать язык используемый для генерации str-glbl.i" skip
    "В качестве параметра компиляции необходимо задать 'rus' или 'eng'" skip
    view-as alert-box .
  return error .
&endif

run filwrlib_set-file-name in this-procedure
  (input p-file-name
  ) .

assign
  p-vss-revision = vss-revision
.
run filwrlib_append-new-line in this-procedure (input "&if defined(shattri) <> 0 or defined(attr-lib) <> 0  &then" ) .
run filwrlib_append-new-line in this-procedure (input "&scoped-define vssseq ~{&sequence~}").
run filwrlib_append-new-line in this-procedure (input 'define variable vss-include-info~{&vssseq~} as character format "x(65)" no-undo initial "' + substitute('@(#)Workfile: str-glbt.p &1 ".', trim(p-vss-revision, "$"))).
run filwrlib_append-new-line in this-procedure (input "&endif" ) .



/*имена атрибутов объектов TH*/

/*набор опций работы с продажей*/
{ cmp/cr-prep.i 1 attr-autosale                 autosale                  " " autosale }

{ cmp/cr-prepc.i 1 prop-list-attr-autosale
"automail,augetres,autocalc,autoclos,autocomp,one-curs,prcl-spl,autofbr,restdish,restingr,resttpsi,sale-filter,sale-add,neg-tpsi-weight,neg-tpsi-qnty,neg-tpsi-oper,tpsi-mode,main-tpsi,wrkr,agnt,boss,one-sale-per-day,close-day-period,close-in-rfsl,pay-gds-algo"
attr-autosale
}

/*опции закачки*/
{ cmp/cr-prep.i 1 attr-get-chk                  get-chk                   " " get-chk }
{ cmp/cr-prepc.i 1 prop-list-attr-get-chk
"cas-curs,hnum,cas-shft,v-shft,t-shft,dc-mask,ptrl-check,card-by-mask,annu-check,no-get-chk,is-100-discnt,zero-cashier,z-check"
attr-get-chk }

/*Опции интерфейса при работе с чеками*/
{ cmp/cr-prep.i 1 attr-chk-view                 chk-view                  " " chk-view }
{ cmp/cr-prepc.i 1 prop-list-attr-chk-view
"ch-bc-ck,chk-inf,chk-spfc,paycardv,dc-change"
attr-chk-view }

/*Общие опции коммуникации с кассами*/
{ cmp/cr-prep.i 1 attr-cd-sending               cd-sending                " " cd-sending }
{ cmp/cr-prepc.i 1 prop-list-attr-cd-sending
"alllstcs,noautocs,cdpcknum,dflt-cd,process-sale,mask_s-c"
attr-cd-sending }

/*Опции передачи данных на кассу*/
{ cmp/cr-prep.i 1 attr-cd-inf-send              cd-inf-send               " " cd-inf-send }
{ cmp/cr-prepc.i 1 prop-list-attr-cd-inf-send
"tax-cass,nam-2str,nam-artc,cod-pcod,name-2cd,amntdisc,cp-is-use,how-temp-disc,how-pcnt-kat,code-system"
attr-cd-inf-send }

/*Параметры работы с весами*/
{ cmp/cr-prep.i 1 attr-scale-inf                scale-inf                 " " scale-inf }
{ cmp/cr-prepc.i 1 prop-list-attr-scale-inf
"scales-type,scales-pr,scallist,sclin-ld,noauto-scls"
attr-scale-inf }

/*Параметры POS IBM*/
{ cmp/cr-prep.i 1 attr-cd-type-ibm              cd-type-ibm               " " cd-type-ibm }
{ cmp/cr-prepc.i 1 prop-list-attr-cd-type-ibm
"ibmrubc,ibmnalc,ibmspool,ibmgroup,multicurr,cd-vat,cdtaxlst,specgrp"
attr-cd-type-ibm }


/*Параметры POS IPC-SERVIS+*/
{ cmp/cr-prep.i 1 attr-cd-type-ipc-servispl     cd-type-ipc-servispl      " " cd-type-ipc-servispl }
{ cmp/cr-prepc.i 1 prop-list-attr-cd-type-ipc-servispl
"ipcsbasc,ipcspayn,ipcsdobc,ipcscpfx,ipcsccrd,ipcstcrd,ipcscurc,ipcpgpfx"
attr-cd-type-ipc-servispl }


/*Параметры POS NCR-GM*/
{ cmp/cr-prep.i 1 attr-cd-type-NCR-GM           cd-type-NCR-GM            " " cd-type-NCR-GM }
{ cmp/cr-prepc.i 1 prop-list-attr-cd-type-ncr-gm
"ncrscpfx,ncrdrank,save-param,ncrpgpfx"
attr-cd-type-ncr-gm }

/*Параметры POS NCR-AS-R*/
{ cmp/cr-prep.i 1 attr-cd-type-NCR-AS-R         cd-type-NCR-AS-R          " " cd-type-NCR-AS-R }
{ cmp/cr-prepc.i 1 prop-list-attr-cd-type-ncr-as-r
"ncrscpfx,ncrdrank,save-param,ncrpgpfx"
attr-cd-type-ncr-as-r }


/*Параметры POS MAGIA-XML*/
{ cmp/cr-prep.i 1 attr-cd-type-magia-xml        cd-type-magia-xml         " " cd-type-magia-xml }
{ cmp/cr-prepc.i 1 prop-list-attr-cd-type-magia-xml
"mag-bnal,magnopay,mag-vip,ret-item,wro-item,ret-chk,wro-chk,ret-ord,wro-ord"
attr-cd-type-magia-xml }

/*Параметры POS OMRON*/
{ cmp/cr-prep.i 1 attr-cd-type-omron            cd-type-omron             " " cd-type-omron }
{ cmp/cr-prepc.i 1 prop-list-attr-cd-type-omron
"omrbase,omrnal,omrntnl,omrpayl,omrcurl"
attr-cd-type-omron}

/*Параметры POS OMRON-NEW*/
{ cmp/cr-prep.i 1 attr-cd-type-omron-new        cd-type-omron-new         " " cd-type-omron-new }
{ cmp/cr-prepc.i 1 prop-list-attr-cd-type-omron-new
"omrnbase,omrnnal,omrnntnl,omrnpayl,omrncurl"
attr-cd-type-omron-new }

/*Параметры POS IBM-XML*/
{ cmp/cr-prep.i 1 attr-cd-type-IBM-XML          cd-type-IBM-XML           " " cd-type-IBM-XML }
{ cmp/cr-prepc.i 1 prop-list-attr-cd-type-ibm-XML
"ibmrubc,ibmnalc,ibm-ccm,ibmgroup,multicurr,cd-vat,cdtaxlst,specgrp"
attr-cd-type-IBM-XML }

/*Параметры POS r-keeper*/
{ cmp/cr-prep.i 1 attr-cd-type-r-keeper       cd-type-r-keeper         " " cd-type-r-keeper }
{ cmp/cr-prepc.i 1 prop-list-attr-cd-type-r-keeper
"cash-pay-list,dis-rule-list,date-format"
attr-cd-type-r-keeper }

/*Параметры POS IBS-TH*/
{ cmp/cr-prep.i 1 attr-cd-type-IBS-TH          cd-type-IBS-TH           " " cd-type-IBS-TH }
{ cmp/cr-prepc.i 2 prop-list-attr-cd-type-ibs-th
"ibs-th_main,ibs-th_devices,ibs-th_fisreg,ibs-th_rec-print,ibs-th_interface"
attr-cd-type-IBS-TH
cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change~
;cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address~
;cash-drawer-level,cash-pay-list,pay-names,cutter,com-port~
;max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print~
;screen-type,screen-layout-id
}

/*Параметры POS IBS-TH-MOB*/
{ cmp/cr-prep.i 1 attr-cd-type-IBS-TH-MOB          cd-type-IBS-TH-MOB           " " cd-type-IBS-TH-MOB }
{ cmp/cr-prepc.i 2 prop-list-attr-cd-type-ibs-th-MOB
"ibs-th-mob_main,ibs-th-mob_rec-print"
attr-cd-type-IBS-TH-MOB
salesman-mandatory,pos-type-for-discnt~
;rcpt-ord-slip-print,rcpt-ord-alt-print
}

/*Параметры POS MARIA*/
{ cmp/cr-prep.i 1 attr-cd-type-maria          cd-type-maria            " " cd-type-maria }
{ cmp/cr-prepc.i 1 prop-list-attr-cd-type-maria
"cdtaxlst,mariapayg,mariapayp,dr-list,drgrouprank,drgdsrank"
attr-cd-type-maria }

/*Параметры POS autotank*/
{ cmp/cr-prep.i 1 attr-cd-type-autotank       cd-type-autotank         " " cd-type-autotank }
{ cmp/cr-prepc.i 1 prop-list-attr-cd-type-autotank
"cash-pay-list,ibmgroup,specgrp"
attr-cd-type-autotank }


/*Совместная площадка*/
{ cmp/cr-prep.i 1 attr-alias-tpsi      alias-tpsi   alias-tpsi   alias-tpsi    alias-tpsi   }
{ cmp/cr-prepc.i 1 prop-list-attr-alias-tpsi
"alias-type-price,alias-object-price"
attr-alias-tpsi }

{ cmp/cr-prep.i 1 alias-type-price-cost            1 "Учетная"                 1  "Cost"                    }
{ cmp/cr-prep.i 1 alias-type-price-crsa-p          2 "Продажная поставщика"    2  "Crsa"                    }
{ cmp/cr-prep.i 1 alias-type-price-crsa-r          3 "Продажная приемника"     3  "Crsa_reciver"            }
{ cmp/cr-prep.i 1 alias-type-price-m               4 "Цена посредника"         4  "Mediator"                }
{ cmp/cr-prep.i 1 alias-type-price-sale-doc        5 "Цена и ск-ка док.про-жи" 5  "Price and disc from sale"}

&glob alias-type-price-radio '{&bef-alias-type-price-cost-full},{&bef-alias-type-price-cost},{&bef-alias-type-price-crsa-p-full},{&bef-alias-type-price-crsa-p},{&bef-alias-type-price-crsa-r-full},{&bef-alias-type-price-crsa-r},{&bef-alias-type-price-m-full},{&bef-alias-type-price-m},{&bef-alias-type-price-sale-doc-full},{&bef-alias-type-price-sale-doc}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define alias-type-price-radio {&alias-type-price-radio}" ).

/* атрибут объекта -  гарантийный запас по АBC в днях */
{ cmp/cr-prep.i 1 attr-abc-sale-day  abc-sale-day abc-sale-day abc-sale-day abc-sale-day  }
{ cmp/cr-prepc.i 1 prop-list-attr-abc-sale-day
"A,B,C,D,E,F"
attr-abc-sale-day }

/* атрибут глобальный -  АBC общие настройки */
{ cmp/cr-prep.i 1 attr-abc-global  abc-global abc-global abc-global abc-global  }
{ cmp/cr-prepc.i 1 prop-list-attr-abc-global
"abc-mode,abc-type,abc-one,abc-two"
attr-abc-global }

/* атрибут глобальный -  ЗАКАЗЫ общие настройки */
{ cmp/cr-prep.i 1 attr-ord-global  ord-global ord-global ord-global ord-global  }
{ cmp/cr-prepc.i 1 prop-list-attr-ord-global
"ord-log,ord-ofof,ord-oobj,ord-op,ord-min-ost-day,ordshipd,ordcyclg"
attr-ord-global }

/* атрибут объектный  -  ЗАКАЗЫ настройки */
{ cmp/cr-prep.i 1 attr-ord-obj  ord-obj ord-obj ord-obj ord-obj  }
{ cmp/cr-prepc.i 1 prop-list-attr-ord-obj
"ord-askp,ord-obj-rc,ord-wgt-div-prc,ord-11,ord-comp-prc"
attr-ord-obj }

/* атрибут объектный  -  Ассортиментная политика настройки */
{ cmp/cr-prep.i 1 attr-Ass-obj  Ass-obj Ass-obj Ass-obj Ass-obj  }
{ cmp/cr-prepc.i 1 prop-list-attr-Ass-obj
"ass-srokiztdel,crit-srokgod,ass-num-days-igt,ass-proc-matr-shabl"
attr-Ass-obj }

/* атрибут глобальный  -  Ассортиментная политика настройки */
{ cmp/cr-prep.i 1 attr-Ass-global  Ass-global Ass-global Ass-global Ass-global  }
{ cmp/cr-prepc.i 1 prop-list-attr-Ass-global
"not_exist"
attr-Ass-global }

/* атрибут глобальный -  Взаиморасчеты ФО */
{ cmp/cr-prep.i 1 attr-fin-global  fin-global fin-global fin-global fin-global fin-global fin-global  }
{ cmp/cr-prepc.i 1 prop-list-attr-fin-global
"fo-buyer-nws,fo-supp-nws,fo-fact,fo-mc-mode,add-conn-avt,del-conn-avt,fo-gen"
attr-fin-global }



/* атрибут объектный -  Взаиморасчеты -Платежи
04/III-2019 не используется. Атрибуты финансовых документов перенесены в БПА
{ cmp/cr-prep.i 1 attr-fin-doc  fin-doc fin-doc fin-doc fin-doc  }
{ cmp/cr-prepc.i 1 prop-list-attr-fin-doc
"suffix-pko,prefix-pko,current-pko,suffix-rko,prefix-rko,current-rko,head-position,director,snr-accnt,cash-book,uchet,dpt-option,dpt-dflt-name,dpt-dflt-type,dpt-dflt-code"
attr-fin-doc }
*/


/* атрибут глобальный -  Договор в накладных */
{ cmp/cr-prep.i 1 attr-contr-in  contr-in contr-in contr-in contr-in  }
{ cmp/cr-prepc.i 1 prop-list-attr-contr-in
"contr-in-income-NP,contr-in-income,contr-in-expense-NP,contr-in-expense,contr-qnty-spec,contr-recount"
attr-contr-in }

/* атрибутЫ накладных от глобального к объекту  */
{ cmp/cr-prep.i 1 attr-nakl_par  nakl_par nakl_par nakl_par nakl_par  }
{ cmp/cr-prepc.i 1 prop-list-attr-nakl_par
"date-close-period,stfactdt,type-vat,type-slt,intprmvq,minusprt,avail-on-date,proxycrd,factorrt,inp_sum,reasonm,back-date,not-ord,reasonme,neg-ask,vat-goods,inv-ship,round-vat-sum,gtd-to-imp-prod,exc-max-qnty,mark-alchol,attr-PN,attr-mandatory-gds-in-wayb,attr-mandatory-gds-ret-wayb,attr-mandatory-gds-exp-wayb,edit-fact-wayb,reasons-for-return,reasons-write-off"
attr-nakl_par }

/*Планируемые цифры */
{ cmp/cr-prep.i  1 attr-fin-plan fin-plan " " fin-plan }
{ cmp/cr-prepc.i 1 prop-list-attr-fin-plan
"fin-ostatok-start,fin-plan-pri,fin-proch,fin-proch-ras"
attr-fin-plan }

/* Значения по умолчанию для накладных, создаваемых через Радиотерминал */
{ cmp/cr-prep.i  1 attr-rt-trn-doc rt-trn-doc " " rt-trn-doc }
{ cmp/cr-prepc.i 1 prop-list-attr-rt-trn-doc
 "wrkr,agnt,boss"
attr-rt-trn-doc }

/*набор опций работы со справочником товаров*/
{ cmp/cr-prep.i 1 attr-gds-ref                 gds-ref                  " " gds-ref }

{ cmp/cr-prepc.i 1 prop-list-attr-gds-ref
"dif-nam1,dif-nam2,dpl-off,dif-pdbc,pbc-veto,tnvedimp,shema-foto,dfltggrp,gds-copy,gdsscrvw,unq-artc,is-scgb"
attr-gds-ref
}

/*набор опций работы со справочником товаров в контексте объекта*/ /*chg-bcod = логический параметр: работа с баркодами разрешена/запрещена. ТН-3098 2014г. Арн.*/
{ cmp/cr-prep.i 1 attr-gds-ref_obj                 gds-ref_obj                 " " gds-ref_obj }

{ cmp/cr-prepc.i 1 prop-list-attr-gds-ref_obj
"dfltggrp,gdsscrvw,chg-bcod,image-dir"
attr-gds-ref_obj
}

/*набор опций работы со справочником ДК*/
{ cmp/cr-prep.i 1 attr-dc-ref                      dc-ref                  " " dc-ref }


{ cmp/cr-prepc.i 1 prop-list-attr-dc-ref
"l-zeros,l-mask"
attr-dc-ref
}

/*набор опций работы со справочником клиентов*/
{ cmp/cr-prep.i 1 attr-cli-all                 cli-all                  " " cli-all }

{ cmp/cr-prepc.i 1 prop-list-attr-cli-all
"inn-uniq,nocorinn"
attr-cli-all
}

/*набор опций работы со справочником типа кассовых платежей*/
{ cmp/cr-prep.i 1 attr-cashpays                 cashpays                  " " cashpays }

{ cmp/cr-prepc.i 1 prop-list-attr-cashpays
"cpgrpnam"
attr-cashpays
}
 /*набор опций работы с  МЦ*/
{ cmp/cr-prep.i 1 attr-wthdoc                 wthdoc                  " " wthdoc }

{ cmp/cr-prepc.i 1 prop-list-attr-wthdoc
"clsfact,prsdoc"
attr-wthdoc
}
 /*набор опций работы с  МЦ*/
{ cmp/cr-prep.i 1 attr-wthdoc_obj                 wthdoc_obj                  " " wthdoc_obj }

{ cmp/cr-prepc.i 1 prop-list-attr-wthdoc_obj
"stfactpref,rangerule,clsfact,inobjauto,inwpcode,numsfact,prsdoc"
attr-wthdoc_obj
}

/* атрибут глобальный - Глобальные настройки для работы с МЦ */
{ cmp/cr-prep.i 1 attr-wthrep  attr-wthrep attr-wthrep attr-wthrep attr-wthrep  }
{ cmp/cr-prepc.i 1 prop-list-attr-wthrep
"cligrplist,docdstnws"
attr-wthrep }


/* глобальный контекст для rum - машина правил - встраиваемые процедуры*/
{ cmp/cr-prep.i 1 attr-rum                 rum                  " " rum }

{ cmp/cr-prepc.i 1 prop-list-attr-rum
"goods,clients,gds-grp,cli-grp,chk-doc_ibs-th,chk-doc_ibs-th-mob,edoc,thref,pdf,rep,ord,cmb,fdoc"
attr-rum
}

/* объектный контекст для rum - машина правил - встраиваемые процедуры*/
{ cmp/cr-prep.i 1 attr-rum_obj                 rum_obj                  " " rum_obj }

{ cmp/cr-prepc.i 1 prop-list-attr-rum_obj
"chk-doc_ibs-th,chk-doc_ibs-th-mob,rep"
attr-rum_obj
}


/*набор опций работы с EasyFuel*/
{ cmp/cr-prep.i 1 attr-easyfuel             easyfuel             " " easyfuel }

{ cmp/cr-prepc.i 1 prop-list-attr-easyfuel
"master-key"
attr-easyfuel
}


/* атрибутЫ переоценок */
{ cmp/cr-prep.i  1 attr-overval  overval overval overval overval  }
{ cmp/cr-prepc.i 1 prop-list-attr-overval
"~
pr-abs-d,~
pr-altex,~
pr-clt-q,~
pr-discm,~
pr-dpl-q,~
pr-dscnt,~
pr-equ-dq,~
pr-incpc,~
pr-list,~
pr-notls,~
pr-parex,~
pr-print,~
pr-rdc-q,~
pr-rndbs,~
pr-rndmt,~
pr-sclex,~
pr-sigma,~
pr-goods,~
pr-goods0,~
pr-nogds,~
pr-nogds0~
"
attr-overval }


/* атрибут глобальный -  ИНВЕНТАРИЗАЦИЯ общие настройки */
{ cmp/cr-prep.i 1 attr-inv-global inv-global inv-global inv-global inv-global }
{ cmp/cr-prepc.i 1 prop-list-attr-inv-global
"invclcas,invclcwt,inv-prs"
attr-inv-global }

/* атрибут объектный  -  ИНВЕНТАРИЗАЦИЯ настройки */
{ cmp/cr-prep.i 1 attr-inv-obj  inv-obj inv-obj inv-obj inv-obj }
{ cmp/cr-prepc.i 1 prop-list-attr-inv-obj
"invclcsp,invdnull,mxpcdcp,mxpcicp,mxsmdcp,mxsmicp,pstunqtn,wastage,pstgrp,pstunit,izlcstpr,minus"
attr-inv-obj }
/* атрибут глобальный -  АРХИВЫ */
{ cmp/cr-prep.i 1 attr-arh-global arh-global arh-global arh-global arh-global }
{ cmp/cr-prepc.i 1 prop-list-attr-arh-global
"apusharh,btprskip"
attr-arh-global }
/* атрибут глобальный -  Резервирование */
{ cmp/cr-prep.i 1 attr-rezerv-global rezerv-global rezerv-global rezerv-global rezerv-global }
{ cmp/cr-prepc.i 1 prop-list-attr-rezerv-global
"parts-bc"
attr-rezerv-global }

/* атрибут объектный  -  Резервирование */
{ cmp/cr-prep.i 1 attr-rezerv-obj  rezerv-obj rezerv-obj rezerv-obj rezerv-obj }
{ cmp/cr-prepc.i 1 prop-list-attr-rezerv-obj
"invngbeg,invngend,negmanuf,negparts,prcshfc0,prcshrs0,prcshrs1,prdocfc0,prdocrs0,prdocrs1,prsalpr"
attr-rezerv-obj }

/* атрибут глобальный  -  Складские документы */
{ cmp/cr-prep.i 1 attr-nakl-glob  nakl-glob nakl-glob nakl-glob nakl-glob }
{ cmp/cr-prepc.i 1 prop-list-attr-nakl-glob
"nocurbas,chk-prs,convimp,curcli,is-bcdoc,is-ov,multdtyp,noapndsc,part-prc,prc-exp,rnd-znk,slt-ext,vat-ext,vat-sum"
attr-nakl-glob }

{ cmp/cr-prep.i 1 attr-images                images                  " " images }
{ cmp/cr-prepc.i 1 prop-list-attr-images
"imgorder"
attr-images
}

/* атрибут глобальный  -  Печать форм */
{ cmp/cr-prep.i 1 attr-prt-glob  prt-glob prt-glob prt-glob prt-glob }
{ cmp/cr-prepc.i 1 prop-list-attr-prt-glob
"invprn0,outprncd,outrecv,sort-prd,torg2-no,outprops,rep-artic"
attr-prt-glob }

/* атрибут по фирме  -  Печать форм*/
{ cmp/cr-prep.i 1 attr-prt-firm  prt-firm prt-firm prt-firm prt-firm }
{ cmp/cr-prepc.i 1 prop-list-attr-prt-firm
"factur01,incurrat,tick-w"
attr-prt-firm }

/* атрибут по объектам  -  Печать форм*/
{ cmp/cr-prep.i 1 attr-prt-obj  prt-obj prt-obj prt-obj prt-obj }
{ cmp/cr-prepc.i 1 prop-list-attr-prt-obj
"fgdsnind,in-docpr,outappr,outdate,outdisc,outegrp,outhold,outnum,outobj,outprim,outrubl,outssdoc,outsubs,outt12,outares,outsend,outasend,outR,outB,outogr,outC"
attr-prt-obj }

/* атрибут глобальный  -  ОТЧЕТЫ */
{ cmp/cr-prep.i 1 attr-report-glob  report-glob report-glob report-glob report-glob }
{ cmp/cr-prepc.i 1 prop-list-attr-report-glob
"actuate,ardecldt,rep-sort,sum-from,sum-step,sum-to,sumvals,alcgrpgd,cplot,rep-shift-format,cdens,rep-password,rep-excel"
attr-report-glob }

/* атрибут по фирме  -  ОТЧЕТЫ */
{ cmp/cr-prep.i 1 attr-report-firm  report-firm report-firm report-firm report-firm }
{ cmp/cr-prepc.i 1 prop-list-attr-report-firm
"xl-delim"
attr-report-firm }

/* атрибут по объектам  -  ОТЧЕТЫ  */
{ cmp/cr-prep.i 1 attr-report-obj  report-obj report-obj report-obj report-obj }
{ cmp/cr-prepc.i 1 prop-list-attr-report-obj
"prt-z-no,shft-qty"
attr-report-obj }



/* диапазоны кодов*/
{ cmp/cr-prep.i 1 attr-code-range             code-range             " " code-range }

{ cmp/cr-prepc.i 1 prop-list-attr-code-range
"cdrgbcgb,cdrgctgb,cdrgdcgb,cdrgdrgb,cdrgfmgb,cdrgpngb,cdrgscgb,cdrgsclc,cdrgsslc,cdrgssgb,cdrgcagb,cdrgpglc,cdrgfdgb"
attr-code-range
}

/* Настройки для экспорта */
{ cmp/cr-prep.i 1 attr-bge-export bge-export " " bge-export }

{ cmp/cr-prepc.i 1 prop-list-attr-bge-export
"bgeclall,bgedcard,bgedict,bgeflnm,bgeflold,bgefmt,bgeshift,bgecliiv"
attr-bge-export
}

/* Настройки СПН*/
{ cmp/cr-prep.i 1 attr-auto-task             auto-task             " " auto-task }

{ cmp/cr-prepc.i 1 prop-list-attr-auto-task
"send-msg-to-email,user-list,maxColMarks"
attr-auto-task
}

/* Настройки рамеров окон */
{ cmp/cr-prep.i 1 attr-wnd-size wnd-size " " wnd-size }

{ cmp/cr-prepc.i 1 prop-list-attr-wnd-size
"max,store"
attr-wnd-size
}

/* Настройки дат на объекте */
{ cmp/cr-prep.i 1 attr-obj-date obj-date " " obj-date }

{ cmp/cr-prepc.i 1 prop-list-attr-obj-date
"autodate,autodtsh,newordsh,diffshft,difftime"
attr-obj-date
}

/* Настройки дат на объекте */
{ cmp/cr-prep.i 1 attr-fbrattr fbrattr " " fbrattr }

{ cmp/cr-prepc.i 1 prop-list-attr-fbrattr
"fbr-frcp,fbr-ioff,fbr-qntc,fbrrcpgb,fbrhstlv,fbr-mrgn-min,fbr-mrgn-max"
attr-fbrattr
}

/* Настройки работы с топливом*/
{ cmp/cr-prep.i 1 attr-petrol petrol " " petrol }

{ cmp/cr-prepc.i 1 prop-list-attr-petrol
"rvsnmter,denstclc,autopump-izm,autopump,avtinvpm,inpptrl,expptrl,invclipt,olddens,algrvspt,temp-for-pomi,rvs-wt-email,CriticalDif,algoincome,mand-choice-autocar,Delta-mass-horiz,Delta-mass-vert,dop-info,otkl-fact-volue,otkl-temp,otkl-density,otkl-water,CriticalDifInLgas,calc-free-vol,trn-reas-sug,rvd-own-nb,sec-fields,qr-scan-time,trnscanqr,block-nozzle,timeout-block-nozzle,calc-free-vol-sug,autopump-skip-time"
attr-petrol
}

/* Настройки работы с пользователями и персоналом*/
{ cmp/cr-prep.i 1 attr-staff-options staff " " staff }
{ cmp/cr-prep.i 1 staff-options_pers pers " " pers }
{ cmp/cr-prep.i 1 staff-options_Adm Adm " " Adm }
{ cmp/cr-prepc.i 1 prop-list-attr-staff-options
"noanshftstaff,obyznumbukv,minparol,TimeAvail,TimeBlock,LastPaswd"
attr-staff-options
}


/* Настройки правил ИЖТ  */
{ cmp/cr-prep.i 1 attr-izt-rul               izt-rul               " " izt-rul }
{ cmp/cr-prepc.i 1 prop-list-attr-izt-rul
"izt-rul"
attr-izt-rul
}

/* Сервер авторизации АСУ */
{ cmp/cr-prep.i 1 attr-srv-auth-ASU srv-auth-ASU " " srv-auth-ASU }
{ cmp/cr-prepc.i 1 prop-list-attr-srv-auth-ASU
"pko-cli,srv-auth-adr"
attr-srv-auth-ASU
}


/*Параметры работы с ЕГАИС*/
{ cmp/cr-prep.i 1 attr-egais-host egais " " egais }
{ cmp/cr-prepc.i 1 prop-list-attr-egais-host
"egais-fsrar,egais-utm,egais-ver-xsd,egais-inn,egais-exsys"
attr-egais-host }

/*Настройки для подключения к ГИС МТ и проверки КМ*/
{ cmp/cr-prep.i 1 attr-gisMT gisMT " " gisMT }
{ cmp/cr-prepc.i 1 prop-list-attr-gisMT
"adressPort,dopParam,gisAdress,proxyLogin,proxyPswd,maxTime,regKey,timeFalStart,waitTime,crashSituat,banDate,cdnTurnOn,cdnAdress,cdnRepeat,cdnChange,cdnTimeUpdate,UpdateRequest,OflineAdress,OflineLogin,OflinePswd,MACC_Timeout,Resp_TH_required,LmCHzPort,TH_IP,TH_Port,AddTimeoutPIoT,MaxApiToken,AgeConfirm"
attr-gisMT }

/*Электронный документооборот*/
{ cmp/cr-prep.i 1 attr-marking marking " " marking }
{ cmp/cr-prepc.i 1 prop-list-attr-marking
"marking-EDO,marking-EDO-NotMark,marking-type,marking-manual,gray_zone_qnty,marking-type-edo,ban-recipes,ban-altr,bar-code,rus-key,marking-type-artic,marking-type-transitional,marking-type-blockCashUnMark,marking-type-saleReturn,marking-type-saleUPD,marking-type-onlySale,checkBlock,checkDate,checkMRC,checkOwner,checkStatusKM,checkTracking"
attr-marking }

/*набор опций работы с документами МЦ*/
{ cmp/cr-prep.i 1 attr-mercur                 mercur                  " " mercur }
{ cmp/cr-prepc.i 1 prop-list-attr-mercur
"apikey,login_is,login,password,manual-vcd,close,type-connect,qrcode,server,proxy-addres,proxy-login,proxy-pswd,proxy-ssl"
attr-mercur }
/* сюда добавлять новые названия атрибутов объектов TH */

run filwrlib_append-new-line in this-procedure (input "&global-define cpdoc-attr-code 'rrn,cpdoc,RTA_RefundExport,CPAgreement,CPWithdrawal,QRPay':U" ) .
run filwrlib_append-new-line in this-procedure (input "&global-define cpdoc-attr-name 'РРН,Остальные,Перевод на моб.счет(ТСО),По аннулированному чеку,Суммы для выдачи наличными,QRPay':U" ) .


/* список атрибутов объектов TH */
&glob thbjattr-list '{&bef-attr-autosale}~
,{&bef-attr-get-chk}~
,{&bef-attr-chk-view}~
,{&bef-attr-cd-sending}~
,{&bef-attr-cd-inf-send}~
,{&bef-attr-scale-inf}~
,{&bef-attr-cd-type-ibm}~
,{&bef-attr-cd-type-ipc-servispl}~
,{&bef-attr-cd-type-NCR-GM}~
,{&bef-attr-cd-type-NCR-AS-R}~
,{&bef-attr-cd-type-magia-xml}~
,{&bef-attr-cd-type-omron}~
,{&bef-attr-cd-type-omron-new}~
,{&bef-attr-cd-type-IBM-XML}~
,{&bef-attr-cd-type-IBS-TH}~
,{&bef-attr-cd-type-IBS-TH-MOB}~
,{&bef-attr-alias-tpsi}~
,{&bef-attr-cd-type-r-keeper}~
,{&bef-attr-cd-type-autotank}~
,{&bef-attr-cd-type-maria}~
,{&bef-attr-arh-global}~
,{&bef-attr-nakl_par}~
,{&bef-attr-contr-in}~
,{&bef-attr-rt-trn-doc}~
,{&bef-attr-overval}~
,{&bef-attr-inv-obj}~
,{&bef-attr-rezerv-obj}~
,{&bef-attr-ord-obj}~
,{&bef-attr-abc-sale-day}~
,{&bef-attr-ass-obj}~
,{&bef-attr-fin-global}~
,{&bef-attr-fin-plan}~
,{&bef-attr-fin-doc}~
,{&bef-attr-gds-ref}~
,{&bef-attr-gds-ref_obj}~
,{&bef-attr-dc-ref}~
,{&bef-attr-cli-all}~
,{&bef-attr-cashpays}~
,{&bef-attr-wthdoc}~
,{&bef-attr-wthdoc_obj}~
,{&bef-attr-wthrep}~
,{&bef-attr-rum}~
,{&bef-attr-rum_obj}~
,{&bef-attr-easyfuel}~
,{&bef-attr-images}~
,{&bef-attr-prt-glob}~
,{&bef-attr-report-glob}~
,{&bef-attr-report-obj}~
,{&bef-attr-code-range}~
,{&bef-attr-bge-export}~
,{&bef-attr-auto-task}~
,{&bef-attr-wnd-size}~
,{&bef-attr-obj-date}~
,{&bef-attr-fbrattr}~
,{&bef-attr-petrol}~
,{&bef-attr-staff-options}~
,{&bef-attr-srv-auth-ASU}~
,{&bef-attr-egais-host}~
,{&bef-attr-mercur}~
,{&bef-attr-gisMT}~
,{&bef-attr-marking}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define thbjattr-list {&thbjattr-list}" ).

/* список атрибутов объектов TH  ВСЕ*/
&glob thbjattr-list-all '{&bef-attr-autosale}~
,{&bef-attr-get-chk}~
,{&bef-attr-chk-view}~
,{&bef-attr-cd-sending}~
,{&bef-attr-cd-inf-send}~
,{&bef-attr-scale-inf}~
,{&bef-attr-cd-type-ibm}~
,{&bef-attr-cd-type-ipc-servispl}~
,{&bef-attr-cd-type-NCR-GM}~
,{&bef-attr-cd-type-NCR-AS-R}~
,{&bef-attr-cd-type-magia-xml}~
,{&bef-attr-cd-type-omron}~
,{&bef-attr-cd-type-omron-new}~
,{&bef-attr-cd-type-IBM-XML}~
,{&bef-attr-cd-type-IBS-TH}~
,{&bef-attr-cd-type-IBS-TH-MOB}~
,{&bef-attr-alias-tpsi}~
,{&bef-attr-cd-type-r-keeper}~
,{&bef-attr-cd-type-maria}~
,{&bef-attr-cd-type-autotank}~
,{&bef-attr-arh-global}~
,{&bef-attr-nakl-glob}~
,{&bef-attr-nakl_par}~
,{&bef-attr-contr-in}~
,{&bef-attr-rt-trn-doc}~
,{&bef-attr-overval}~
,{&bef-attr-inv-global}~
,{&bef-attr-inv-obj}~
,{&bef-attr-rezerv-global}~
,{&bef-attr-rezerv-obj}~
,{&bef-attr-ord-global}~
,{&bef-attr-ord-obj}~
,{&bef-attr-abc-sale-day}~
,{&bef-attr-ass-obj}~
,{&bef-attr-fin-global}~
,{&bef-attr-fin-plan}~
,{&bef-attr-fin-doc}~
,{&bef-attr-gds-ref}~
,{&bef-attr-gds-ref_obj}~
,{&bef-attr-dc-ref}~
,{&bef-attr-cli-all}~
,{&bef-attr-cashpays}~
,{&bef-attr-wthdoc}~
,{&bef-attr-wthdoc_obj}~
,{&bef-attr-wthrep}~
,{&bef-attr-rum}~
,{&bef-attr-rum_obj}~
,{&bef-attr-easyfuel}~
,{&bef-attr-images}~
,{&bef-attr-prt-glob}~
,{&bef-attr-prt-firm}~
,{&bef-attr-prt-obj}~
,{&bef-attr-report-glob}~
,{&bef-attr-report-firm}~
,{&bef-attr-report-obj}~
,{&bef-attr-code-range}~
,{&bef-attr-bge-export}~
,{&bef-attr-auto-task}~
,{&bef-attr-wnd-size}~
,{&bef-attr-obj-date}~
,{&bef-attr-fbrattr}~
,{&bef-attr-petrol}~
,{&bef-attr-staff-options}~
,{&bef-attr-srv-auth-ASU}~
,{&bef-attr-egais-host}~
,{&bef-attr-mercur}~
,{&bef-attr-gisMT}~
,{&bef-attr-marking}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define thbjattr-list-all {&thbjattr-list-all}" ).


run filwrlib_num-lines-get in this-procedure
  (output p-num-lines
  ) .