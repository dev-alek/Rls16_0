block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Программа генерации файла s t r - g l b l . i . Часть 4

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/13/06
Author: Bakhtadze Natalya
Creation date: 12/13/06

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

/*11=MARIA*/
{ cmp/cr-prep.i 1 ddcr-debet-pay-pcnt-discnt   debet-pay-pcnt-disc  "% Скидка при оплате топлива по дебет.ведомости" debet-pay-pcnt-disc  "Debet Petrol % discount"   }
/*12=MARIA*/
{ cmp/cr-prep.i 1 ddcr-debet-pay-abs-discnt    debet-pay-abs-disc  "ABS Скидка при оплате топлива по дебет.ведомости" debet-pay-abs-disc  "Debet Petrol Abs discount"   }
/*40=MARIA*/
{ cmp/cr-prep.i 1 ddcr-debet-pay-qnty-discnt   debet-pay-qnty-disc  "Скидка на кол-во при оплате топлива по дебет.ведомости" debet-pay-qnty-disc  "Debet Petrol Qnty discount"   }
/*41=MARIA*/
{ cmp/cr-prep.i 1 ddcr-debet-pay-sum-discnt    debet-pay-sum-disc  "Скидка на сумму при оплате топлива по дебет.ведомости" debet-pay-sum-disc  "Debet Petrol Sum discount"   }
/*50=MARIA*/
{ cmp/cr-prep.i 1 ddcr-debet-pay-free-discnt   debet-pay-free-disc  "Своб скидка при оплате топлива по дебет.ведомости" debet-pay-free-disc  "Debet Petrol Free discount"   }
/*0 - тип связи без правила*/
{ cmp/cr-prep.i 1 ddcr-dc-d-pcnt               dc-d-pcnt            "% скидка на товар по ДК" dc-d-pcnt  "% Item Discnt for DC holder"   }
/*0 - тип связи без правила*/
{ cmp/cr-prep.i 1 ddcr-dc-cash-d-pcnt          dc-cash-d-pcnt       "% скидка на итог чека по ДК" dc-cash-d-pcnt  "% Total Discnt for DC holder"   }


/*14=MARIA*/
{ cmp/cr-prep.i 1 ddcr-credit-pay-pcnt-discnt   credit-pay-pcnt-disc  "% Скидка при оплате топлива по кредит.ведомости" credit-pay-pcnt-disc  "Credit Petrol % discount"   }
/*15=MARIA*/
{ cmp/cr-prep.i 1 ddcr-credit-pay-abs-discnt   credit-pay-abs-disc  "Abs Скидка при оплате топлива по кредит.ведомости" credit-pay-abs-disc  "Credit Petrol Abs discount"   }
/*16=MARIA*/
{ cmp/cr-prep.i 1 ddcr-credit-pay-qnty-discnt   credit-pay-qnty-disc  "Скидка на кол-во при оплате топлива по кредит.ведомости" credit-pay-qnty-disc  "Credit Petrol qnty discount"   }
/*30=MARIA*/
{ cmp/cr-prep.i 1 ddcr-credit-pay-sum-discnt    credit-pay-sum-disc  "Скидка на сумму при оплате топлива по кредит.ведомости" credit-pay-sum-disc  "Credit Petrol Sum discount"   }
/*67=MARIA*/
{ cmp/cr-prep.i 1 ddcr-credit-pay-free-discnt   credit-pay-free-disc  "Своб Скидка на сумму при оплате топлива по кредит.ведомости" credit-pay-free-disc  "Credit Petrol Free discount"   }


&glob ddcr-list '~
{&bef-ddcr-debet-pay-pcnt-discnt}~
,{&bef-ddcr-debet-pay-abs-discnt}~
,{&bef-ddcr-debet-pay-qnty-discnt}~
,{&bef-ddcr-debet-pay-sum-discnt}~
,{&bef-ddcr-debet-pay-free-discnt}~
,{&bef-ddcr-dc-d-pcnt}~
,{&bef-ddcr-dc-cash-d-pcnt}~
,{&bef-ddcr-credit-pay-pcnt-discnt}~
,{&bef-ddcr-credit-pay-abs-discnt}~
,{&bef-ddcr-credit-pay-qnty-discnt}~
,{&bef-ddcr-credit-pay-sum-discnt}~
,{&bef-ddcr-credit-pay-free-discnt}~
':u

run filwrlib_append-new-line in this-procedure ( input "&global-define ddcr-list {&ddcr-list}" ).

&glob ddcr-list-full '~
{&bef-ddcr-debet-pay-pcnt-discnt-full}~
,{&bef-ddcr-debet-pay-abs-discnt-full}~
,{&bef-ddcr-debet-pay-qnty-discnt-full}~
,{&bef-ddcr-debet-pay-sum-discnt-full}~
,{&bef-ddcr-debet-pay-free-discnt-full}~
,{&bef-ddcr-dc-d-pcnt-full}~
,{&bef-ddcr-dc-cash-d-pcnt-full}~
,{&bef-ddcr-credit-pay-pcnt-discnt-full}~
,{&bef-ddcr-credit-pay-abs-discnt-full}~
,{&bef-ddcr-credit-pay-qnty-discnt-full}~
,{&bef-ddcr-credit-pay-sum-discnt-full}~
,{&bef-ddcr-credit-pay-free-discnt-full}~
':u

run filwrlib_append-new-line in this-procedure ( input "&global-define ddcr-list-full {&ddcr-list-full}" ).

&glob dis-dc-rule-name entry (lookup (~~~~~~~{&dis-dc-rule-code}, {&ddcr-list}) + 1, ',' + {&ddcr-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define dis-dc-rule-name {&dis-dc-rule-name}" ).


/*57=;60=;63=*/
{ cmp/cr-prep.i 1 ddctr-calc-d-pcnt   calc-d-pcnt  "Расчет %скидки ДК на товар" calc-d-pcnt  "DC item %dicnt calc"   }

/*58=;61=;64=*/
{ cmp/cr-prep.i 1 ddctr-calc-cash-d-pcnt   calc-cash-d-pcnt  "Расчет %скидки ДК на итог" calc-cash-d-pcnt  "DC total %dicnt calc"   }

/*59=;62=;65=*/
{ cmp/cr-prep.i 1 ddctr-calc-categ   calc-categ  "Расчет категории ДК" calc-categ  "DC category calc"   }

/*66=*/

{ cmp/cr-prep.i 1 ddctr-dis-tot-flag   dis-tot-flag  "Участие в итогах по ДК" dis-tot-flag "DC TOTALs participant"   }

{ cmp/cr-prep.i 1 ddctr-def-categ  def-categ  "Категория ДК по умолчанию" def-categ "DC default category"   }

{ cmp/cr-prep.i 1 ddctr-def-pcnt   def-pcnt   "% скидки ДК на товар по умолч." def-pcnt "DC default disc.%"   }

{ cmp/cr-prep.i 1 ddctr-def-cash-pcnt  def-cash-pcnt   "% скидки ДК на итог по умолч." def-cash-pcnt "DC default cash disc.%"   }


&glob ddctr-list '{&bef-ddctr-calc-d-pcnt}~
,{&bef-ddctr-calc-cash-d-pcnt}~
,{&bef-ddctr-calc-categ}~
,{&bef-ddctr-dis-tot-flag}~
,{&bef-ddctr-def-categ}~
,{&bef-ddctr-def-pcnt}~
,{&bef-ddctr-def-cash-pcnt}~
':u

run filwrlib_append-new-line in this-procedure ( input "&global-define ddctr-list {&ddctr-list}" ).

&glob ddctr-list-full '{&bef-ddctr-calc-d-pcnt-full}~
,{&bef-ddctr-calc-cash-d-pcnt-full}~
,{&bef-ddctr-calc-categ-full}~
,{&bef-ddctr-dis-tot-flag-full}~
,{&bef-ddctr-def-categ-full}~
,{&bef-ddctr-def-pcnt-full}~
,{&bef-ddctr-def-cash-pcnt-full}~
':u

run filwrlib_append-new-line in this-procedure ( input "&global-define ddctr-list-full {&ddctr-list-full}" ).

&glob dis-dct-rule-name entry (lookup (~~~~~~~{&dis-dct-rule-code}, {&ddctr-list}) + 1, ',' + {&ddctr-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define dis-dct-rule-name {&dis-dct-rule-name}" ).

/*36=NCR_AS-R;46=MARIA*/
{ cmp/cr-prep.i 1 dggrr-pcnt   gds-grp-pcnt  "% скидка на группу товара" gds-grp-pcnt "% Group discount"   }

/*37=NCR_AS-R*/
{ cmp/cr-prep.i 1 dggrr-pcnt-kat  gds-grp-pcnt-kat  "% скидка на группу товара для кат.клиентов" gds-grp-pcnt-kat "% Group kategory discount"   }

/*47=MARIA*/
{ cmp/cr-prep.i 1 dggrr-abs  gds-grp-abs  "Abs скидка на группу товара" gds-grp-abs "Abs Group discount"   }

/*48=MARIA*/
{ cmp/cr-prep.i 1 dggrr-pcnt-qnty gds-grp-qnty  "% Скидка на группу товара по кол-ву" gds-grp-qnty "% Group discount by qnty"   }

/*49=MARIA*/
{ cmp/cr-prep.i 1 dggrr-pcnt-sum gds-grp-sum  "% Скидка на группу товара на сумму" gds-grp-sum "% Group discount by sum"   }

&glob dggrr-list '{&bef-dggrr-pcnt}~
,{&bef-dggrr-pcnt-kat}~
,{&bef-dggrr-abs}~
,{&bef-dggrr-pcnt-qnty}~
,{&bef-dggrr-pcnt-sum}~
':u

run filwrlib_append-new-line in this-procedure ( input "&global-define dggrr-list {&dggrr-list}" ).

&glob dggrr-list-full '{&bef-dggrr-pcnt-full}~
,{&bef-dggrr-pcnt-kat-full}~
,{&bef-dggrr-abs-full}~
,{&bef-dggrr-pcnt-qnty-full}~
,{&bef-dggrr-pcnt-sum-full}~
':u

run filwrlib_append-new-line in this-procedure ( input "&global-define dggrr-list-full {&dggrr-list-full}" ).

&glob dis-ggr-rule-name entry (lookup (~~~~~~~{&dis-ggr-rule-code}, {&dggrr-list}) + 1, ',' + {&dggrr-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define dis-ggr-rule-name {&dis-ggr-rule-name}" ).


/*72 - bo*/
{ cmp/cr-prep.i 1 dclgr-pcnt   cli-grp-pcnt  "% скидка на группу клиентов" cli-grp-pcnt "% Cli.Group discount"   }


&glob dclgr-list '{&bef-dclgr-pcnt}~
':u

run filwrlib_append-new-line in this-procedure ( input "&global-define dclgr-list {&dclgr-list}" ).

&glob dclgr-list-full '{&bef-dclgr-pcnt-full}~
':u

run filwrlib_append-new-line in this-procedure ( input "&global-define dclgr-list-full {&dclgr-list-full}" ).

&glob dis-clgr-rule-name entry (lookup (~~~~~~~{&dis-clgr-rule-code}, {&dclgr-list}) + 1, ',' + {&dclgr-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define dis-clgr-rule-name {&dis-clgr-rule-name}" ).


&glob dis-grp-classif-list '{&bef-table_sum-grp}~
,{&bef-table_cli-grp}~
':u

run filwrlib_append-new-line in this-procedure ( input "&global-define dis-grp-classif-list {&dis-grp-classif-list}" ).

&glob dis-grp-classif-list-full '{&bef-table_sum-grp-full}~
,{&bef-table_cli-grp-full}~
':u

run filwrlib_append-new-line in this-procedure ( input "&global-define dis-grp-classif-list-full {&dis-grp-classif-list-full}" ).


&glob dis-grp-classif-name entry (lookup (~~~~~~~{&dis-grp-classif-code}, {&dis-grp-classif-list}) + 1, ',' + {&dis-grp-classif-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define dis-grp-classif-name {&dis-grp-classif-name}" ).


&glob dis-cfg-rule-table-name-list '~
{&bef-table_dis-gds-rule}~
,{&bef-table_dis-cp-rule}~
,{&bef-table_dis-dc-rule}~
,{&bef-table_dis-dct-rule}~
,{&bef-table_dis-thbj-rule}~
,{&bef-table_dis-grp-rule}~
,{&bef-table_dis-some-rule}~
':u

run filwrlib_append-new-line in this-procedure ( input "&global-define dis-cfg-rule-table-name-list {&dis-cfg-rule-table-name-list}" ).

&glob dis-cfg-rule-table-name-list-full '~
{&bef-table_dis-gds-rule-full}~
,{&bef-table_dis-cp-rule-full}~
,{&bef-table_dis-dc-rule-full}~
,{&bef-table_dis-dct-rule-full}~
,{&bef-table_dis-thbj-rule-full}~
,{&bef-table_dis-grp-rule-full}~
,{&bef-table_dis-some-rule-full}~
':u


run filwrlib_append-new-line in this-procedure ( input "&global-define dis-cfg-rule-table-name-list-full {&dis-cfg-rule-table-name-list-full}" ).


&glob dis-cfg-rule-table-name entry (lookup (~~~~~~~{&dis-cfg-rule-table-code}, {&dis-cfg-rule-table-name-list}) + 1, ',' + {&dis-cfg-rule-table-name-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define dis-cfg-rule-table-name {&dis-cfg-rule-table-name}" ).


{ cmp/cr-prep.i 1 rdict-etype-constant          constant        " " "constant"  }
{ cmp/cr-prep.i 1 rdict-etype-operator          operator        " " "operator"  }
{ cmp/cr-prep.i 1 rdict-etype-control           control         " " "control"  }
{ cmp/cr-prep.i 1 rdict-etype-prop-name-global  prop-name_      " " "prop-name_"  }
{ cmp/cr-prep.i 1 rdict-etype-prop-name-host    prop-name_host  " " "prop-name_host"  }
{ cmp/cr-prep.i 1 rdict-etype-prop-name-obj     prop-name_obj   " " "prop-name_obj"  }
{ cmp/cr-prep.i 1 rdict-etype-node-name-global  node-name_      " " "node-name_"  }
{ cmp/cr-prep.i 1 rdict-etype-node-name-host    node-name_host  " " "node-name_host"  }
{ cmp/cr-prep.i 1 rdict-etype-node-name-obj     node-name_obj   " " "node-name_obj"  }
{ cmp/cr-prep.i 1 rdict-etype-prop-script       prop-script     " " "prop-script"  }
{ cmp/cr-prep.i 1 rdict-etype-sum-id            sum-id          " " "sum-id"  }
{ cmp/cr-prep.i 1 rdict-etype-rule              rule            " " "rule"  }
{ cmp/cr-prep.i 1 rdict-etype-rule-profile      rule-profile    " " "rule-profile"  }
{ cmp/cr-prep.i 1 rdict-etype-datatype          datatype        " " "datatype"  }
{ cmp/cr-prep.i 1 rdict-etype-parameter         parameter       " " "parameter"  }



&glob rdict-etype-list '{&bef-rdict-etype-constant}~
,{&bef-rdict-etype-operator}~
,{&bef-rdict-etype-control}~
,{&bef-rdict-etype-prop-name-global}~
,{&bef-rdict-etype-prop-name-host}~
,{&bef-rdict-etype-prop-name-obj}~
,{&bef-rdict-etype-node-name-global}~
,{&bef-rdict-etype-node-name-host}~
,{&bef-rdict-etype-node-name-obj}~
,{&bef-rdict-etype-prop-script}~
,{&bef-rdict-etype-sum-id}~
,{&bef-rdict-etype-rule}~
,{&bef-rdict-etype-rule-profile}~
,{&bef-rdict-etype-datatype}~
,{&bef-rdict-etype-parameter}~
':u

run filwrlib_append-new-line in this-procedure ( input "&global-define rdict-etype-list {&rdict-etype-list}" ).

{ cmp/cr-prep.i 1 prop-script-type-set              set             " " "set"  }
{ cmp/cr-prep.i 1 prop-script-type-get-set          get-set         " " "get-set"  }
{ cmp/cr-prep.i 1 prop-script-type-get              get             " " "get"  }
{ cmp/cr-prep.i 1 prop-script-type-get-ifunction    get-ifunction   " " "get-ifunction"  }
{ cmp/cr-prep.i 1 prop-script-type-find             find            " " "find"  }
{ cmp/cr-prep.i 1 prop-script-type-define-b         define_b        " " "define_b"  }
{ cmp/cr-prep.i 1 prop-script-type-define-tt        define_tt       " " "define_tt"  }
{ cmp/cr-prep.i 1 prop-script-type-define-h         define_h        " " "define_h"  }
{ cmp/cr-prep.i 1 prop-script-type-create           create          " " "create"  }
/*тело фнкции лежит в prop-script.script-body*/
{ cmp/cr-prep.i 1 prop-script-type-function         function        " " "function"  }
/*тело фнкции лежит в i.файле имя которого лежит в prop-script.head*/
{ cmp/cr-prep.i 1 prop-script-type-ifunction        ifunction       " " "ifunction"  }
{ cmp/cr-prep.i 1 prop-script-type-variable         variable        " " "variable"  }


&glob prop-script-type-list '{&bef-prop-script-type-set}~
,{&bef-prop-script-type-get}~
,{&bef-prop-script-type-get-ifunction}~
,{&bef-prop-script-type-get-set}~
,{&bef-prop-script-type-find}~
,{&bef-prop-script-type-define-b}~
,{&bef-prop-script-type-define-tt}~
,{&bef-prop-script-type-define-h}~
,{&bef-prop-script-type-create}~
,{&bef-prop-script-type-function}~
,{&bef-prop-script-type-ifunction}~
,{&bef-prop-script-type-variable}~
':u

run filwrlib_append-new-line in this-procedure ( input "&global-define prop-script-type-list {&prop-script-type-list}" ).

{ cmp/cr-prep.i 1 script-ptype-procedure     procedure        " " "procedure"  }
{ cmp/cr-prep.i 1 script-ptype-function      function         " " "function"  }
{ cmp/cr-prep.i 1 script-ptype-extern        extern           " " "extern"  }
{ cmp/cr-prep.i 1 script-ptype-dll-entry     dll-entry        " " "dll-entry"  }
{ cmp/cr-prep.i 1 script-ptype-main          main             " " "main"  }
{ cmp/cr-prep.i 1 script-ptype-class         class           " " "class"  }
{ cmp/cr-prep.i 1 script-ptype-data-member   data-member     " " "data-member"  }
{ cmp/cr-prep.i 1 script-ptype-property      property        " " "property"  }
{ cmp/cr-prep.i 1 script-ptype-method        method          " " "method"  }
{ cmp/cr-prep.i 1 script-ptype-constructor   constructor     " " "constructor"  }
{ cmp/cr-prep.i 1 script-ptype-destructor    destructor      " " "desctructor"  }




&glob script-ptype-list '{&bef-script-ptype-procedure}~
,{&bef-script-ptype-function}~
,{&bef-script-ptype-extern}~
,{&bef-script-ptype-dll-entry}~
,{&bef-script-ptype-main}~
,{&bef-script-ptype-class}~
,{&bef-script-ptype-data-member}~
,{&bef-script-ptype-property}~
,{&bef-script-ptype-method}~
,{&bef-script-ptype-constructor}~
,{&bef-script-ptype-destructor}~
':u

run filwrlib_append-new-line in this-procedure ( input "&global-define script-ptype-list {&script-ptype-list}" ).


&glob script-class-child-list '{&bef-script-ptype-class}~
,{&bef-script-ptype-data-member}~
,{&bef-script-ptype-property}~
,{&bef-script-ptype-method}~
,{&bef-script-ptype-constructor}~
,{&bef-script-ptype-destructor}~
':u

run filwrlib_append-new-line in this-procedure ( input "&global-define script-class-child-list {&script-class-child-list}" ).


{ cmp/cr-prep.i 1 script-parmode-input       input                  "вх"                "input"              "input"               }
{ cmp/cr-prep.i 1 script-parmode-output      output                 "вых"               "output"             "ouput"               }
{ cmp/cr-prep.i 1 script-parmode-inout       input-output           "вх-вых"            "input-output"       "input-output"        }
{ cmp/cr-prep.i 1 script-parmode-buffer      buffer                 "курсор"            "buffer"             "buffer"              }
{ cmp/cr-prep.i 1 script-parmode-intable    "input table"           "вх табл"           "input table"        "input table"         }
{ cmp/cr-prep.i 1 script-parmode-outtable   "output table"          "вых табл"          "output table"       "output table"        }
{ cmp/cr-prep.i 1 script-parmode-inouttable "input-output table"    "вх/вых табл"       "input-output table" "input-output table"  }

&glob script-parmode-list '{&bef-script-parmode-input}~
,{&bef-script-parmode-output}~
,{&bef-script-parmode-inout}~
,{&bef-script-parmode-buffer}~
,{&bef-script-parmode-intable}~
,{&bef-script-parmode-outtable}~
,{&bef-script-parmode-inouttable}~
':u

run filwrlib_append-new-line in this-procedure ( input "&global-define script-parmode-list {&script-parmode-list}" ).

&glob script-parmode-list-full '{&bef-script-parmode-input-full}~
,{&bef-script-parmode-output-full}~
,{&bef-script-parmode-inout-full}~
,{&bef-script-parmode-buffer-full}~
,{&bef-script-parmode-intable-full}~
,{&bef-script-parmode-outtable-full}~
,{&bef-script-parmode-inouttable-full}~
':u

run filwrlib_append-new-line in this-procedure ( input "&global-define script-parmode-list-full {&script-parmode-list-full}" ).

&glob script-parmode-name entry (lookup (~~~~~~~{&script-parmode}, ~{&script-parmode-list~}), ~{&script-parmode-list-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define script-parmode-name {&script-parmode-name}" ).



{ cmp/cr-prep.i 1 ABL-datatype-character      character      "строка"           "character"     "string"         }
{ cmp/cr-prep.i 1 ABL-datatype-date           date           "дата"             "date"          "date"           }
{ cmp/cr-prep.i 1 ABL-datatype-datetime       datetime       "дата-время"       "datetime"      "datetime"       }
{ cmp/cr-prep.i 1 ABL-datatype-datetime-TZ    datetime-tz    "дата-время-з"     "datetime-tz"   "datetime-tz"    }
{ cmp/cr-prep.i 1 ABL-datatype-decimal        decimal        "десятичное"       "decimal"       "decimal"        }
{ cmp/cr-prep.i 1 ABL-datatype-integer        integer        "целое"            "integer"       "integer"        }
{ cmp/cr-prep.i 1 ABL-datatype-void           void           "пусто"            "void   "       "void"           }
{ cmp/cr-prep.i 1 ABL-datatype-logical        logical        "логическое"       "logical"       "logical"        }
{ cmp/cr-prep.i 1 ABL-datatype-memptr         memptr         "память"           "memptr"        "memptr"         }
{ cmp/cr-prep.i 1 ABL-datatype-raw            raw            "двоичные"         "raw"           "raw"            }
{ cmp/cr-prep.i 1 ABL-datatype-recid          recid          "номер записи"     "recid"         "recid"          }
{ cmp/cr-prep.i 1 ABL-datatype-rowid          rowid          "Номер Записи"     "rowid"         "rowid"          }
{ cmp/cr-prep.i 1 ABL-datatype-widget-handle  widget-handle  "ссылка"           "widget-handle" "widget-handle"  }
{ cmp/cr-prep.i 1 ABL-datatype-handle         handle         "ссылка"           "handle"        "handle"         }
{ cmp/cr-prep.i 1 ABL-datatype-blob           blob           "Больш.бин.объект" "blob"          "blob"           }
{ cmp/cr-prep.i 1 ABL-datatype-clob           clob           "Больш.стр.объект" "clob"          "clob"           }
{ cmp/cr-prep.i 1 ABL-datatype-class          class          "Объект"           "class"         "class"          }
{ cmp/cr-prep.i 1 ABL-datatype-com-handle     com-handle     "COM-объект"       "com-handle"    "com-handle"     }
{ cmp/cr-prep.i 1 ABL-datatype-longchar       longchar       "Длинная строка"   "longchar"      "longchar"       }
{ cmp/cr-prep.i 1 ABL-datatype-int64          int64          "64Целое"          "int64"         "int64"          }

{ cmp/cr-prep.i 1 datatype-uniq-key-rec       uniq-key-rec   "КлючЗаписи"       "uniq-key-rec"  "RecKey"         }


&glob ABL-datatype-list '{&bef-ABL-datatype-character}~
,{&bef-ABL-datatype-date}~
,{&bef-ABL-datatype-datetime}~
,{&bef-ABL-datatype-datetime-tz}~
,{&bef-ABL-datatype-decimal}~
,{&bef-ABL-datatype-integer}~
,{&bef-ABL-datatype-void}~
,{&bef-ABL-datatype-logical}~
,{&bef-ABL-datatype-memptr}~
,{&bef-ABL-datatype-raw}~
,{&bef-ABL-datatype-recid}~
,{&bef-ABL-datatype-rowid}~
,{&bef-ABL-datatype-widget-handle}~
,{&bef-ABL-datatype-handle}~
,{&bef-ABL-datatype-blob}~
,{&bef-ABL-datatype-clob}~
,{&bef-ABL-datatype-class}~
,{&bef-ABL-datatype-com-handle}~
,{&bef-ABL-datatype-longchar}~
,{&bef-ABL-datatype-int64}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define ABL-datatype-list {&ABL-datatype-list}" ).

&glob ABL-datatype-list-full '{&bef-ABL-datatype-character-full}~
,{&bef-ABL-datatype-date-full}~
,{&bef-ABL-datatype-datetime-full}~
,{&bef-ABL-datatype-datetime-tz-full}~
,{&bef-ABL-datatype-decimal-full}~
,{&bef-ABL-datatype-integer-full}~
,{&bef-ABL-datatype-void-full}~
,{&bef-ABL-datatype-logical-full}~
,{&bef-ABL-datatype-memptr-full}~
,{&bef-ABL-datatype-raw-full}~
,{&bef-ABL-datatype-recid-full}~
,{&bef-ABL-datatype-rowid-full}~
,{&bef-ABL-datatype-widget-handle-full}~
,{&bef-ABL-datatype-handle-full}~
,{&bef-ABL-datatype-blob-full}~
,{&bef-ABL-datatype-clob-full}~
,{&bef-ABL-datatype-class-full}~
,{&bef-ABL-datatype-com-handle-full}~
,{&bef-ABL-datatype-longchar-full}~
,{&bef-ABL-datatype-int64-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define ABL-datatype-list-full {&ABL-datatype-list-full}" ).



&glob ABL-pardatatype-list '{&bef-ABL-datatype-character}~
,{&bef-ABL-datatype-date}~
,{&bef-ABL-datatype-datetime}~
,{&bef-ABL-datatype-datetime-tz}~
,{&bef-ABL-datatype-decimal}~
,{&bef-ABL-datatype-integer}~
,{&bef-ABL-datatype-void}~
,{&bef-ABL-datatype-logical}~
,{&bef-ABL-datatype-memptr}~
,{&bef-ABL-datatype-raw}~
,{&bef-ABL-datatype-recid}~
,{&bef-ABL-datatype-rowid}~
,{&bef-ABL-datatype-widget-handle}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define ABL-pardatatype-list {&ABL-pardatatype-list}" ).

&glob ABL-simple-datatype-list '{&bef-ABL-datatype-character}~
,{&bef-ABL-datatype-date}~
,{&bef-ABL-datatype-decimal}~
,{&bef-ABL-datatype-integer}~
,{&bef-ABL-datatype-logical}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define ABL-simple-datatype-list {&ABL-simple-datatype-list}" ).



&glob Abl-datatype-name (if lookup (~~~~~~~{&abl-datatype}, ~{&abl-datatype-list~}) > 0 then entry (lookup (~~~~~~~{&abl-datatype}, ~{&abl-datatype-list~}), ~{&abl-datatype-list-full~}) else ~~~~~~~{&abl-datatype})
run filwrlib_append-new-line in this-procedure ( input "&global-define abl-datatype-name {&abl-datatype-name}" ).


{ cmp/cr-prep.i 1 prop-head-gen-dis-card-type  dis-card-type  "Типы ДК"             dis-card-type    "Disc. card Types"   }
{ cmp/cr-prep.i 1 prop-head-gen-loyalty        Loyalty        "Система Лояльности"  Loyalty          "Loyalty System"     }
{ cmp/cr-prep.i 1 prop-head-gen-loyalty2       Loyalty2        "Система Лояльности" Loyalty2         "Loyalty System"     }
{ cmp/cr-prep.i 1 prop-head-gen-dc-storage     dc-storage      "Св-ва и итоги по ДК" dc-storage      "DC totals and props"     }
{ cmp/cr-prep.i 1 prop-head-gen-dc-prop        dc-prop         "Св-ва ДК"            dc-prop         "DC props"           }
{ cmp/cr-prep.i 1 prop-head-gen-goods          goods           "Товары"              goods           "Goods"              }


&glob prop-head-general-list '{&bef-prop-head-gen-dis-card-type}~
,{&bef-prop-head-gen-Loyalty}~
,{&bef-prop-head-gen-dc-storage}~
,{&bef-prop-head-gen-dc-prop}~
,{&bef-prop-head-gen-goods}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define prop-head-general-list {&prop-head-general-list}" ).

&glob prop-head-general-list-full '{&bef-prop-head-gen-dis-card-type-full}~
,{&bef-prop-head-gen-Loyalty-full}~
,{&bef-prop-head-gen-dc-storage-full}~
,{&bef-prop-head-gen-dc-prop-full}~
,{&bef-prop-head-gen-goods-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define prop-head-general-list-full {&prop-head-general-list-full}" ).

&glob prop-head-general-view-list '{&bef-prop-head-gen-dis-card-type}~
,{&bef-prop-head-gen-Loyalty}~
,{&bef-prop-head-gen-Loyalty2}~
,{&bef-prop-head-gen-dc-storage}~
,{&bef-prop-head-gen-dc-prop}~
,{&bef-prop-head-gen-goods}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define prop-head-general-view-list {&prop-head-general-view-list}" ).


&glob prop-head-general-view-list-full '{&bef-prop-head-gen-dis-card-type-full}~
,{&bef-prop-head-gen-Loyalty-full}~
,{&bef-prop-head-gen-Loyalty2-full}~
,{&bef-prop-head-gen-dc-storage-full}~
,{&bef-prop-head-gen-dc-prop-full}~
,{&bef-prop-head-gen-goods-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define prop-head-general-view-list-full {&prop-head-general-view-list-full}" ).

&glob prop-head-general-list-pairs '{&bef-prop-head-gen-dis-card-type-full},{&bef-prop-head-gen-dis-card-type}~
,{&bef-prop-head-gen-Loyalty-full},{&bef-prop-head-gen-Loyalty}~
,{&bef-prop-head-gen-dc-storage-full},{&bef-prop-head-gen-dc-storage}~
,{&bef-prop-head-gen-dc-prop-full},{&bef-prop-head-gen-dc-prop}~
,{&bef-prop-head-gen-goods-full},{&bef-prop-head-gen-goods}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define prop-head-general-list-pairs {&prop-head-general-list-pairs}" ).


&glob prop-head-general-view-list-pairs '{&bef-prop-head-gen-dis-card-type-full},{&bef-prop-head-gen-dis-card-type}~
,{&bef-prop-head-gen-Loyalty-full},{&bef-prop-head-gen-Loyalty}~
,{&bef-prop-head-gen-Loyalty2-full},{&bef-prop-head-gen-Loyalty2}~
,{&bef-prop-head-gen-dc-storage-full},{&bef-prop-head-gen-dc-storage}~
,{&bef-prop-head-gen-dc-prop-full},{&bef-prop-head-gen-dc-prop}~
,{&bef-prop-head-gen-goods-full},{&bef-prop-head-gen-goods}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define prop-head-general-view-list-pairs {&prop-head-general-view-list-pairs}" ).

&glob prop-head-general-name (if lookup (~~~~~~~{&prop-head-general-code}, ~{&prop-head-general-list~}) > 0 then entry (lookup (~~~~~~~{&prop-head-general-code}, ~{&prop-head-general-list~}), ~{&prop-head-general-list-full~}) else ~~~~~~~{&prop-head-general-code})
run filwrlib_append-new-line in this-procedure ( input "&global-define prop-head-general-name {&prop-head-general-name}" ).

&glob prop-head-general-view-name (if lookup (~~~~~~~{&prop-head-general-code}, ~{&prop-head-general-view-list~}) > 0 then entry (lookup (~~~~~~~{&prop-head-general-code}, ~{&prop-head-general-view-list~}), ~{&prop-head-general-view-list-full~}) else ~~~~~~~{&prop-head-general-code})
run filwrlib_append-new-line in this-procedure ( input "&global-define prop-head-general-view-name {&prop-head-general-view-name}" ).

{ cmp/cr-prep.i 1 sum-id-type-blank            blank          "_"                   blank          "_"   }
{ cmp/cr-prep.i 1 sum-id-type-period           period         "Период дат"          period         "Data period"   }
{ cmp/cr-prep.i 1 sum-id-type-sel-goods        sel-goods      "Опред.товары"        sel-goods      "Select.Goods"   }
{ cmp/cr-prep.i 1 sum-id-type-one-ptrl         one-ptrl       "Вид топлива"         one-ptrl       "PetrolType"   }
{ cmp/cr-prep.i 1 sum-id-type-esys-blank       esys           "ВнСист"              esys           "ExtSys"   }
{ cmp/cr-prep.i 1 sum-id-type-esys-period      esys:period    "ВнСист:Период дат"   esys:period    "ExtSys:Data period"   }
{ cmp/cr-prep.i 1 sum-id-type-esys-sel-goods   esys:sel-goods "ВнСист:Опред.товары" esys:sel-goods "ExtSys:Select.Goods"   }
{ cmp/cr-prep.i 1 sum-id-type-esys-one-ptrl    esys:one-ptrl  "ВнСист:Вид топлива"  esys:one-ptrl  "ExtSys:PetrolType"   }



&glob sum-id-type-list '~
{&bef-sum-id-type-blank}~
,{&bef-sum-id-type-period}~
,{&bef-sum-id-type-sel-goods}~
,{&bef-sum-id-type-one-ptrl}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define sum-id-type-list {&sum-id-type-list}" ).

&glob sum-id-type-list-full '~
{&bef-sum-id-type-blank-full}~
,{&bef-sum-id-type-period-full}~
,{&bef-sum-id-type-sel-goods-full}~
,{&bef-sum-id-type-one-ptrl-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define sum-id-type-list-full {&sum-id-type-list-full}" ).

&glob sum-id-type-name (if lookup (~~~~~~~{&sum-id-type-code}, ~{&sum-id-type-list~}) > 0 then entry (lookup (~~~~~~~{&sum-id-type-code}, ~{&sum-id-type-list~}), ~{&sum-id-type-list-full~}) else ~~~~~~~{&sum-id-type-code})
run filwrlib_append-new-line in this-procedure ( input "&global-define sum-id-type-name {&sum-id-type-name}" ).

{ cmp/cr-prep.i 1 rule-script-cond             COND       "Условие"             COND          "Condition"   }
{ cmp/cr-prep.i 1 rule-script-cons             CONS       "Следствие"           CONS          "Consequence" }
{ cmp/cr-prep.i 1 rule-script-goto             GOTO       "Переход"             GOTO          "Goto" }
{ cmp/cr-prep.i 1 rule-script-cycle-cond       CYCLE-COND "Цикл-усл."           CYCLE-COND    "Cycle-Cond"  }
{ cmp/cr-prep.i 1 rule-script-rule             RULE       "Подправило"          RULE          "SubRule"     }
{ cmp/cr-prep.i 1 rule-script-else-rule        ELSE-RULE  "ИначеПодправило"     ELSE-RULE     "ElseSubRule"     }

&glob rule-script-list '{&bef-rule-script-cond}~
,{&bef-rule-script-cons}~
,{&bef-rule-script-goto}~
,{&bef-rule-script-cycle-cond}~
,{&bef-rule-script-rule}~
,{&bef-rule-script-else-rule}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define rule-script-list {&rule-script-list}" ).

&glob rule-script-list-full '{&bef-rule-script-cond-full}~
,{&bef-rule-script-cons-full}~
,{&bef-rule-script-goto-full}~
,{&bef-rule-script-cycle-cond-full}~
,{&bef-rule-script-rule-full}~
,{&bef-rule-script-else-rule-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define rule-script-list-full {&rule-script-list-full}" ).

&glob rule-script-name (if lookup (~~~~~~~{&rule-script-code}, ~{&rule-script-list~}) > 0 then entry (lookup (~~~~~~~{&rule-script-code}, ~{&rule-script-list~}), ~{&rule-script-list-full~}) else ~~~~~~~{&rule-script-code})
run filwrlib_append-new-line in this-procedure ( input "&global-define rule-script-name {&rule-script-name}" ).


&glob trg-param-no-callnews 'no-callnews':U
run filwrlib_append-new-line in this-procedure ( input "&global-define trg-param-no-callnews {&trg-param-no-callnews}" ).

&glob trg-param-no-hist 'no-hist':U
run filwrlib_append-new-line in this-procedure ( input "&global-define trg-param-no-hist {&trg-param-no-hist}" ).


{ cmp/cr-prep.i 1 "stop-card"            1  "стоп-карта"                1  "stop-card" }
{ cmp/cr-prep.i 1 "stop-client"          2  "стоп-клиент"               2  "stop-client" }
{ cmp/cr-prep.i 1 "stop-card-and-client" 3  "стоп-карта;стоп-клиент"    3  "stop-card;stop-client" }
{ cmp/cr-prep.i 1 "delete-card"          4  "удал-карта"                4  "delete-card" }

&glob stop-status-codes '{&bef-stop-card}~
,{&bef-stop-client}~
,{&bef-stop-card-and-client}~
,{&bef-delete-card}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define stop-status-codes {&stop-status-codes}" ).


&glob stop-status-codes-full '{&bef-stop-card-full}~
,{&bef-stop-client-full}~
,{&bef-stop-card-and-client-full}~
,{&bef-delete-card-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define stop-status-codes-full {&stop-status-codes-full}" ).


&glob stop-status-name entry (lookup (~~~~~~~{&stop-status-code}, {&stop-status-codes}) + 1, ',':U + {&stop-status-codes-full})

run filwrlib_append-new-line in this-procedure ( input "&global-define stop-status-name {&stop-status-name}" ).

/* Параметры all-docs.w по умолчанию */
{ cmp/cr-prep.i 1 all-docs-p-ord 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99  " " 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99 }
{ cmp/cr-prep.i 1 all-docs-p-siz 1,1,6,2,14,8,8,5,3,1,20,10,1,15,15,1,15,15,15,15,15,15,15,11,10,5,1,15,4,5,10,8,16,8,8,8,9,9,9,9,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1                                                                      " " 1,1,6,2,11,8,8,5,3,1,20,10,1,15,15,1,15,15,15,15,15,15,15,11,10,5,1,15,4,5,10,8,16,8,8,8,9,9,9,9,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1                                                                     }
{ cmp/cr-prep.i 1 all-docs-p-vis "trim(fill('yes,',40) + fill('no,',59) , ',')"                                                                                                                                                                                                                                   " " "trim(fill('yes,',40)  + fill('no,',58) , ',')"                                                                                                                                                                                                                                   }

/* Параметры cli-zakz.w по умолчанию */
{ cmp/cr-prep.i 1 cli-zakzFP-p-ord 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23                              " "  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23                              }
{ cmp/cr-prep.i 1 cli-zakzFP-p-siz 1,3,1,8,20,4,7,9,12,10,10,10,3,9,9,9,12,14,1,9,10,10,10                                  " "  1,3,1,8,20,4,7,9,12,10,10,10,3,9,9,9,12,14,1,9,10,10,10                                  }
{ cmp/cr-prep.i 1 cli-zakzFP-p-vis yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,no,no,yes,yes,no,no,no   " "  yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,yes,no,no,yes,yes,no,no,no   }
{ cmp/cr-prep.i 1 cli-zakzOP-p-ord 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23                              " "  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23                              }
{ cmp/cr-prep.i 1 cli-zakzOP-p-siz 1,3,1,8,20,4,7,10,12,10,10,10,3,9,9,9,12,14,1,9,10,10,10                                 " "  1,3,1,8,20,4,7,9,12,10,10,10,3,9,9,9,12,14,1,9,10,10,10                                  }
{ cmp/cr-prep.i 1 cli-zakzOP-p-vis trim(fill('yes,',23),',')                                                                " "  trim(fill('yes,',23),',')                                                                }
{ cmp/cr-prep.i 1 cli-zakzOF-p-ord 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23                              " "  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23                              }
{ cmp/cr-prep.i 1 cli-zakzOF-p-siz 1,3,1,10,26,4,7,9,12,10,10,10,3,11,11,11,12,14,1,9,10,10,10                              " "  1,3,1,10,26,4,7,9,12,10,10,10,3,11,11,11,12,14,1,9,10,10,10                              }
{ cmp/cr-prep.i 1 cli-zakzOF-p-vis yes,yes,yes,yes,yes,no,no,no,no,no,no,no,yes,yes,yes,yes,yes,yes,yes,yes,no,no,no        " "  yes,yes,yes,yes,yes,no,no,no,no,no,no,no,yes,yes,yes,yes,yes,yes,yes,yes,no,no,no        }

/* Параметры contspec.w по умолчанию */
{ cmp/cr-prep.i 1 contspec-p-ord 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23     " "  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23  }
{ cmp/cr-prep.i 1 contspec-p-siz 1,16,16,10,30,10,17,17,4,10,5,10,5,5,10,20,6,6,6,6,6,6,6         " "  1,16,16,10,30,10,17,17,4,10,5,10,5,5,10,20,6,6,6,6,6,6,6 }
{ cmp/cr-prep.i 1 contspec-p-vis trim(fill('yes,',23),',')                                    " "  trim(fill('yes,',23),',') }


/* Параметры gds-cnts.w по умолчанию */
{ cmp/cr-prep.i 1 contspec-g-ord 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17     " "  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17   }
{ cmp/cr-prep.i 1 contspec-g-siz 1,10,14,20,9,10,17,17,10,10,4,10,10,6,10,10,16   " "  1,16,16,10,30,10,17,17,16,10,4,10,5,7,9,6,10 }
{ cmp/cr-prep.i 1 contspec-g-vis trim(fill('yes,',17),',')            " "  trim(fill('yes,',17),',')   }

{ cmp/cr-prep.i 1 "add-fields"          add-fields  "Доп.поля"                add-fields  "Add.fields" }

&glob custom-labels-codes '{&bef-add-fields}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define custom-labels-codes {&custom-labels-codes}" ).


&glob custom-labels-codes-full '{&bef-add-fields-full}~
':U


run filwrlib_append-new-line in this-procedure ( input "&global-define custom-labels-codes-full {&custom-labels-codes-full}" ).


{ cmp/cr-prep.i 1 dr-appl-object             0       "Объект<=>правило"             0          "Object<=>Rule"   }

{ cmp/cr-prep.i 1 dr-cond-object             1       "->Условие правила"            1          "->Rule Cond"   }

{ cmp/cr-prep.i 1 dr-branch-object           2       "Объект<=>Ветка правила"       2          "Object<=>Rule Branch"   }

{ cmp/cr-prep.i 1 dr-rule-ref-object         3       "Объект<=>Ссылка на правило"   3          "Object<=>Rule Ref."   }

{ cmp/cr-prep.i 1 dr-through-property       -2      "Объект<=>Свойство<=>правило"  -2          "Object<=>Property<=>Rule"   }

{ cmp/cr-prep.i 1 dr-no-rule                -1       "Объект<=>Нет правила"         -1         "Object<=>No Rule"   }

&glob dr-link-codes '{&bef-dr-appl-object}~
,{&bef-dr-cond-object}~
,{&bef-dr-branch-object}~
,{&bef-dr-rule-ref-object}~
,{&bef-dr-through-property}~
,{&bef-dr-no-rule}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define dr-link-codes {&dr-link-codes}" ).


&glob dr-link-codes-full '{&bef-dr-appl-object-full}~
,{&bef-dr-cond-object-full}~
,{&bef-dr-branch-object-full}~
,{&bef-dr-rule-ref-object-full}~
,{&bef-dr-through-property-full}~
,{&bef-dr-no-rule-full}~
':U


run filwrlib_append-new-line in this-procedure ( input "&global-define dr-link-codes-full {&dr-link-codes-full}" ).

&glob dr-link-name entry (lookup (~~~~~~~{&dr-link-code}, {&dr-link-codes}) + 1, ',':U + {&dr-link-codes-full})

run filwrlib_append-new-line in this-procedure ( input "&global-define dr-link-name {&dr-link-name}" ).

{ cmp/cr-prep.i 1 lob-res-data          data        "Данные"    data           "Data"      }
{ cmp/cr-prep.i 1 lob-res-gate          gate        "Гейт"      gate           "Gate"      }
{ cmp/cr-prep.i 1 lob-res-upgrade       upgrade     "Апгрейд"   upgrade        "Upgrade"   }
{ cmp/cr-prep.i 1 lob-res-report        report       "Отчет"       report         "Report"      }
{ cmp/cr-prep.i 1 lob-res-report-xml    report-xml   "Отчет-XML"   report-xml     "Report-XML"  }
{ cmp/cr-prep.i 1 lob-res-list          list         "Список"      list           "List"        }
{ cmp/cr-prep.i 1 lob-res-list-macro    list-macro   "Макрос формир списка"      list-macro           "List Forming Macro"        }
{ cmp/cr-prep.i 1 lob-res-ref           ref          "Справочник"  ref            "Reference"   }
{ cmp/cr-prep.i 1 lob-egais-wb          egais-wb     "Накладная ЕГАИС"  egais-wb  "EGAIS Waybill" }
{ cmp/cr-prep.i 1 lob-egais-ref-b       egais-ref-b  "Справка B ЕГАИС"  egais-ref-b "EGAIS Reference B" }
{ cmp/cr-prep.i 1 lob-egais-ab          egais-ab     "Акт постановки на баланс B ЕГАИС"  egais-ab "EGAIS ActBalance" }
{ cmp/cr-prep.i 1 lob-egais-awo         egais-awo    "Акт о списании товара B ЕГАИС"  egais-awo "EGAIS ActWriteOff" }
{ cmp/cr-prep.i 1 lob-egais-wb-act      egais-wb-act "Акт подтверждения накладной" egais-wb-act "EGAIS Waybill Act"  }
{ cmp/cr-prep.i 1 lob-egais-ticket      egais-ticket "Квитанция ЕГАИС" egais-ticket "EGAIS Ticket"  }
{ cmp/cr-prep.i 1 lob-egais-wb-ticket   egais-wb-ticket "Квитанция на акт по накладной ЕГАИС" egais-wb-ticket "EGAIS Ticket on WB Act"  }
{ cmp/cr-prep.i 1 lob-egais-ab_shop     egais-ab_shop   "Акт постановки на баланс в торговом зале ЕГАИС"  egais-ab_shop "EGAIS ActBalance_shop" }
{ cmp/cr-prep.i 1 lob-egais-awo_shop    egais-awo_shop  "Акт о списании товара из торогового зала ЕГАИС"  egais-awo_shop "EGAIS ActWriteOff_shop" }
{ cmp/cr-prep.i 1 lob-egais-tts         egais-tts    "Передача продукции в тороговый зал ЕГАИС"  egais-tts "EGAIS TransferToShop" }
{ cmp/cr-prep.i 1 lob-egais-tfs         egais-tfs    "Возврат продукции из торогового зала на склад ЕГАИС"  egais-tfs "EGAIS TransferFromShop" }
{ cmp/cr-prep.i 1 lob-egais-qb          egais-qb     "Запрос на получение штрихкода по серии и номеру марки ЕГАИС"  egais-qb "EGAIS QueryBarcode" }

&glob clob-res-codes '{&bef-lob-res-data}~
,{&bef-lob-res-gate}~
,{&bef-lob-res-upgrade}~
,{&bef-lob-res-report}~
,{&bef-lob-res-report-xml}~
,{&bef-lob-res-list}~
,{&bef-lob-res-list-macro}~
,{&bef-lob-res-ref}~
,{&bef-lob-egais-wb}~
,{&bef-lob-egais-ref-b}~
,{&bef-lob-egais-ab}~
,{&bef-lob-egais-awo}~
,{&bef-lob-egais-wb-act}~
,{&bef-lob-egais-ticket}~
,{&bef-lob-egais-wb-ticket}~
,{&bef-lob-egais-ab_shop}~
,{&bef-lob-egais-awo_shop}~
,{&bef-lob-egais-tts}~
,{&bef-lob-egais-tfs}~
,{&bef-lob-egais-qb}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define clob-res-codes {&clob-res-codes}" ).

&glob clob-res-codes-full '{&bef-lob-res-data-full}~
,{&bef-lob-res-gate-full}~
,{&bef-lob-res-upgrade-full}~
,{&bef-lob-res-report-full}~
,{&bef-lob-res-report-xml-full}~
,{&bef-lob-res-list-full}~
,{&bef-lob-res-list-macro-full}~
,{&bef-lob-res-ref-full}~
,{&bef-lob-egais-wb-full}~
,{&bef-lob-egais-ref-b-full}~
,{&bef-lob-egais-ab-full}~
,{&bef-lob-egais-awo-full}~
,{&bef-lob-egais-wb-act-full}~
,{&bef-lob-egais-ticket-full}~
,{&bef-lob-egais-wb-ticket-full}~
,{&bef-lob-egais-ab_shop-full}~
,{&bef-lob-egais-awo_shop-full}~
,{&bef-lob-egais-tts-full}~
,{&bef-lob-egais-tfs-full}~
,{&bef-lob-egais-qb-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define clob-res-codes-full {&clob-res-codes-full}" ).

&glob blob-res-codes '{&bef-lob-res-data}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define blob-res-codes {&blob-res-codes}" ).

&glob blob-res-codes-full '{&bef-lob-res-data-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define blob-res-codes-full {&blob-res-codes-full}" ).

/* Типы Blob */
&glob blob-trn-doc-image 'trn-doc-image':U
run filwrlib_append-new-line in this-procedure ( input "&global-define blob-trn-doc-image {&blob-trn-doc-image}" ).

&glob blob-collec-image 'collec-image':U
run filwrlib_append-new-line in this-procedure ( input "&global-define blob-collec-image {&blob-collec-image}" ).

&glob blob-gds-collec-image 'gds-collec-image':U
run filwrlib_append-new-line in this-procedure ( input "&global-define blob-gds-collec-image {&blob-gds-collec-image}" ).


{ cmp/cr-prep.i 1 lk-type_update-delete update-delete    "Изменение/Удаление"    update-delete           "Update/Delete"      }


&glob lk-types '{&bef-lk-type_update-delete}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define lk-types {&lk-types}" ).

&glob lk-types-full '{&bef-lk-type_update-delete-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define lk-types-full {&lk-types-full}" ).

&glob lk-type-name entry (lookup (~~~~~~~{&lk-type-code}, {&lk-types}) + 1, ',' + {&lk-types-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define lk-type-name {&lk-type-name}" ).


{ cmp/cr-prep.i 1 dct-proc_sale-close         sale-close         "Закрытие продажи на факт"       sale-close           "Sale close"             }
{ cmp/cr-prep.i 1 dct-proc_sale-delete        sale-delete        "Удаление закрытой продажи"      sale-delete          "Sale delete"            }
{ cmp/cr-prep.i 1 dct-proc_trn-doc-close      trn-doc-close      "Закрытие накл. с ДК на факт"    trn-doc-close        "Waybill close"          }
{ cmp/cr-prep.i 1 dct-proc_trn-doc-delete     trn-doc-delete     "Удаление накл. с ДК"            trn-doc-delete       "Waybill delete"         }
{ cmp/cr-prep.i 1 dct-proc_sale-xml-import    sale-xml-import    "Импорт продаж в XML виде"       sale-xml-import      "Sale XML-import"        }
{ cmp/cr-prep.i 1 dct-proc_text-import        text-import        "Импорт данных в текст.виде"     text-import          "Text import"            }
{ cmp/cr-prep.i 1 dct-proc_text-export        text-export        "Экспорт данных в текст.виде"    text-export          "Text export"            }
{ cmp/cr-prep.i 1 dct-proc_one-card-recalc    one-card-recalc    "Пересчет по одной карте"        one-card-recalc      "One card recalc"        }
{ cmp/cr-prep.i 1 dct-proc_one-card-check     one-card-check     "Проверка одной карты"           one-card-check       "One card check"         }
{ cmp/cr-prep.i 1 dct-proc_one-card-add       one-card-add       "Добавление одной карты"         one-card-add         "One card add"           }
{ cmp/cr-prep.i 1 dct-proc_batch-card-recalc  batch-card-recalc  "Пересчет карт"                  batch-card-recalc    "Batch card recalc"      }
{ cmp/cr-prep.i 1 dct-proc_stop-list-import   stop-list-import   "Импорт стоплиста"               stop-list-import     "Stoplist import"        }
{ cmp/cr-prep.i 1 dct-proc_payment-on-card    payment-on-card    "Внесение средств на карту"      payment-on-card      "Payment on card"        }
{ cmp/cr-prep.i 1 dct-proc_fin-doc-on-card    fin-doc-on-card    "Внес.пл-жа на карту через сист.взаиморасчетов"      fin-doc-on-card      "Payment on card by Bill"        }
{ cmp/cr-prep.i 1 dct-proc_delete-fin-doc-from-card    delete-fin-doc-from-card    "Удал.пл-жа с карты через сист.взаиморасчетов"      delete-fin-doc-from-card      "Delete Payment from card by Bill"        }


&glob dct-proc-list '{&bef-dct-proc_sale-close}~
,{&bef-dct-proc_sale-delete}~
,{&bef-dct-proc_trn-doc-close}~
,{&bef-dct-proc_trn-doc-delete}~
,{&bef-dct-proc_sale-xml-import}~
,{&bef-dct-proc_text-import}~
,{&bef-dct-proc_text-export}~
,{&bef-dct-proc_one-card-recalc}~
,{&bef-dct-proc_one-card-check}~
,{&bef-dct-proc_one-card-add}~
,{&bef-dct-proc_batch-card-recalc}~
,{&bef-dct-proc_stop-list-import}~
,{&bef-dct-proc_payment-on-card}~
,{&bef-dct-proc_fin-doc-on-card}~
,{&bef-dct-proc_delete-fin-doc-from-card}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define dct-proc-list {&dct-proc-list}" ).

&glob dct-proc-list-full '{&bef-dct-proc_sale-close-full}~
,{&bef-dct-proc_sale-delete-full}~
,{&bef-dct-proc_trn-doc-close-full}~
,{&bef-dct-proc_trn-doc-delete-full}~
,{&bef-dct-proc_sale-xml-import-full}~
,{&bef-dct-proc_text-import-full}~
,{&bef-dct-proc_text-export-full}~
,{&bef-dct-proc_one-card-recalc-full}~
,{&bef-dct-proc_one-card-check-full}~
,{&bef-dct-proc_one-card-add-full}~
,{&bef-dct-proc_batch-card-recalc-full}~
,{&bef-dct-proc_stop-list-import-full}~
,{&bef-dct-proc_payment-on-card-full}~
,{&bef-dct-proc_fin-doc-on-card-full}~
,{&bef-dct-proc_delete-fin-doc-from-card-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define dct-proc-list-full {&dct-proc-list-full}" ).

&glob dct-proc-name entry (lookup (~~~~~~~{&dct-proc-code}, {&dct-proc-list}) + 1, ',' + {&dct-proc-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define dct-proc-name {&dct-proc-name}" ).


{ cmp/cr-prep.i 1 goods-proc_gdsadd            gdsadd            "Добавление товара"                gdsadd               "Add Good"              }
{ cmp/cr-prep.i 1 goods-proc_gdsupdate         gdsupdate         "Изменение товара"                 gdsupdate            "Change Good"           }
{ cmp/cr-prep.i 1 goods-proc_rengdscode        rengdscode        "Смена кода товара"                rengdscode           "Rename Goods Code"     }
{ cmp/cr-prep.i 1 goods-proc_addlcode          addlcode          "Добавление лок.кода"              addlcode             "Add LocalCode"         }
{ cmp/cr-prep.i 1 goods-proc_dellcode          dellcode          "Удаление лок.кода"                dellcode             "Delete LocalCode"      }
{ cmp/cr-prep.i 1 goods-proc_updatelcode       updatelcode       "Изменение лок.кода"               updatelcode          "Update LocalCode"      }
{ cmp/cr-prep.i 1 goods-proc_addprcode         addprcode         "Добавление Доп.БК"                addprcode            "Add ProducersCode"     }
{ cmp/cr-prep.i 1 goods-proc_delprcode         delprcode         "Удаление Доп.БК"                  delprcode            "Delete ProducersCode"  }
{ cmp/cr-prep.i 1 goods-proc_updateprcode      updateprcode      "Изменение Доп.БК"                 updateprcode         "Update ProducersCode"  }
{ cmp/cr-prep.i 1 goods-proc_xml-file-import   xml-file-import   "Импорт из xml-файла"              xml-file-import      "XML-file import"       }
{ cmp/cr-prep.i 1 goods-proc_xml-esys-import   xml-esys-import   "Импорт из ВС"                     xml-esys-import      "ES import"             }
{ cmp/cr-prep.i 1 goods-proc_batchwork-export  batchwork-export  "Операции по списку-экспорт"       batchwork-export     "Batch work-export"     }
{ cmp/cr-prep.i 1 goods-proc_batchwork-routing batchwork-routing "Операции по списку-маршрутизация" batchwork-routing    "Batch work-routing"    }
{ cmp/cr-prep.i 1 goods-proc_rest-update       rest-update       "Изменение остатка"                rest-update          "Rest Update"           }
{ cmp/cr-prep.i 1 goods-proc_goods-cd-send     goods-cd-send     "Передача товаров на кассу"        goods-cd-send        "Send to POS"           }
{ cmp/cr-prep.i 1 goods-proc_goods-batchwork   goods-batchwork   "Работа в атоматическом режиме"    goods-batchwork      "Auto Mode"             }
{ cmp/cr-prep.i 1 goods-proc_add-good-to-asm   add-good-to-asm   "Добавление в асм. матрицу"        add-good-to-asm      "Add to AsM"            }
{ cmp/cr-prep.i 1 goods-proc_del-good-from-asm del-good-from-asm "Удаление из асм. матрицы"         del-good-from-asm    "Remove from AsM"       }


&glob goods-proc-list '{&bef-goods-proc_gdsadd}~
,{&bef-goods-proc_gdsupdate}~
,{&bef-goods-proc_rengdscode}~
,{&bef-goods-proc_addlcode}~
,{&bef-goods-proc_dellcode}~
,{&bef-goods-proc_updatelcode}~
,{&bef-goods-proc_addprcode}~
,{&bef-goods-proc_delprcode}~
,{&bef-goods-proc_updateprcode}~
,{&bef-goods-proc_xml-file-import}~
,{&bef-goods-proc_xml-esys-import}~
,{&bef-goods-proc_batchwork-export}~
,{&bef-goods-proc_batchwork-routing}~
,{&bef-goods-proc_rest-update}~
,{&bef-goods-proc_goods-cd-send}~
,{&bef-goods-proc_goods-batchwork}~
,{&bef-goods-proc_add-good-to-asm}~
,{&bef-goods-proc_del-good-from-asm}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define goods-proc-list {&goods-proc-list}" ).

&glob goods-proc-list-full '{&bef-goods-proc_gdsadd-full}~
,{&bef-goods-proc_gdsupdate-full}~
,{&bef-goods-proc_rengdscode-full}~
,{&bef-goods-proc_addlcode-full}~
,{&bef-goods-proc_dellcode-full}~
,{&bef-goods-proc_updatelcode-full}~
,{&bef-goods-proc_addprcode-full}~
,{&bef-goods-proc_delprcode-full}~
,{&bef-goods-proc_updateprcode-full}~
,{&bef-goods-proc_xml-file-import-full}~
,{&bef-goods-proc_xml-esys-import-full}~
,{&bef-goods-proc_batchwork-export-full}~
,{&bef-goods-proc_batchwork-routing-full}~
,{&bef-goods-proc_rest-update-full}~
,{&bef-goods-proc_goods-cd-send-full}~
,{&bef-goods-proc_goods-batchwork-full}~
,{&bef-goods-proc_add-good-to-asm}~
,{&bef-goods-proc_del-good-from-asm}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define goods-proc-list-full {&goods-proc-list-full}" ).

&glob goods-proc-name entry (lookup (~~~~~~~{&goods-proc-code}, {&goods-proc-list}) + 1, ',' + {&goods-proc-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define goods-proc-name {&goods-proc-name}" ).

{ cmp/cr-prep.i 1 clients-proc_batchwork-export  batchwork-export  "Операции по списку-экспорт"       batchwork-export     "Batch work-export"     }
{ cmp/cr-prep.i 1 clients-proc_batchwork-routing batchwork-routing "Операции по списку-маршрутизация" batchwork-routing    "Batch work-routing"    }
{ cmp/cr-prep.i 1 clients-proc_xml-file-import   xml-file-import   "Импорт из xml-файла"              xml-file-import      "XML-file import"       }
{ cmp/cr-prep.i 1 clients-proc_xml-esys-import   xml-esys-import   "Импорт из ВС"                     xml-esys-import      "ES import"             }
{ cmp/cr-prep.i 1 clients-proc_text-import       text-import       "Импорт данных в текст.виде"       text-import          "Text import"            }
{ cmp/cr-prep.i 1 clients-proc_text-export       text-export       "Экспорт данных в текст.виде"      text-export          "Text export"            }
{ cmp/cr-prep.i 1 clients-proc_cliadd            cliadd            "Добавление клиента"               cliadd               "Add Client"            }
{ cmp/cr-prep.i 1 clients-proc_cliupdate         cliupdate         "Изменение клиента"                cliupdate            "Change Client"           }



&glob clients-proc-list '~
{&bef-clients-proc_batchwork-export}~
,{&bef-clients-proc_batchwork-routing}~
,{&bef-clients-proc_xml-file-import}~
,{&bef-clients-proc_xml-esys-import}~
,{&bef-clients-proc_text-import}~
,{&bef-clients-proc_text-export}~
,{&bef-clients-proc_cliadd}~
,{&bef-clients-proc_cliupdate}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define clients-proc-list {&clients-proc-list}" ).

&glob clients-proc-list-full '~
{&bef-clients-proc_batchwork-export-full}~
,{&bef-clients-proc_batchwork-routing-full}~
,{&bef-clients-proc_xml-file-import-full}~
,{&bef-clients-proc_xml-esys-import-full}~
,{&bef-clients-proc_text-import-full}~
,{&bef-clients-proc_text-export-full}~
,{&bef-clients-proc_cliadd-full}~
,{&bef-clients-proc_cliupdate-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define clients-proc-list-full {&clients-proc-list-full}" ).

&glob clients-proc-name entry (lookup (~~~~~~~{&clients-proc-code}, {&clients-proc-list}) + 1, ',' + {&clients-proc-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define clients-proc-name {&clients-proc-name}" ).


{ cmp/cr-prep.i 1 gds-grp-proc_batchwork-export  batchwork-export  "Операции по списку-экспорт"       batchwork-export     "Batch work-export"     }
{ cmp/cr-prep.i 1 gds-grp-proc_batchwork-routing batchwork-routing "Операции по списку-маршрутизация" batchwork-routing    "Batch work-routing"    }
{ cmp/cr-prep.i 1 gds-grp-proc_xml-file-import   xml-file-import   "Импорт из xml-файла"              xml-file-import      "XML-file import"       }
{ cmp/cr-prep.i 1 gds-grp-proc_xml-esys-import   xml-esys-import   "Импорт из ВС"                     xml-esys-import      "ES import"             }


&glob gds-grp-proc-list '~
{&bef-gds-grp-proc_batchwork-export}~
,{&bef-gds-grp-proc_batchwork-routing}~
,{&bef-gds-grp-proc_xml-file-import}~
,{&bef-gds-grp-proc_xml-esys-import}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define gds-grp-proc-list {&gds-grp-proc-list}" ).

&glob gds-grp-proc-list-full '~
{&bef-gds-grp-proc_batchwork-export-full}~
,{&bef-gds-grp-proc_batchwork-routing-full}~
,{&bef-gds-grp-proc_xml-file-import-full}~
,{&bef-gds-grp-proc_xml-esys-import-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define gds-grp-proc-list-full {&gds-grp-proc-list-full}" ).

&glob gds-grp-proc-name entry (lookup (~~~~~~~{&gds-grp-proc-code}, {&gds-grp-proc-list}) + 1, ',' + {&gds-grp-proc-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define gds-grp-proc-name {&gds-grp-proc-name}" ).

{ cmp/cr-prep.i 1 cli-grp-proc_batchwork-export  batchwork-export  "Операции по списку-экспорт"       batchwork-export     "Batch work-export"     }
{ cmp/cr-prep.i 1 cli-grp-proc_batchwork-routing batchwork-routing "Операции по списку-маршрутизация" batchwork-routing    "Batch work-routing"    }
{ cmp/cr-prep.i 1 cli-grp-proc_xml-file-import   xml-file-import   "Импорт из xml-файла"              xml-file-import      "XML-file import"       }
{ cmp/cr-prep.i 1 cli-grp-proc_xml-esys-import   xml-esys-import   "Импорт из ВС"                     xml-esys-import      "ES import"             }

&glob cli-grp-proc-list '~
{&bef-cli-grp-proc_batchwork-export}~
,{&bef-cli-grp-proc_batchwork-routing}~
,{&bef-cli-grp-proc_xml-file-import}~
,{&bef-cli-grp-proc_xml-esys-import}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define cli-grp-proc-list {&cli-grp-proc-list}" ).

&glob cli-grp-proc-list-full '~
{&bef-cli-grp-proc_batchwork-export-full}~
,{&bef-cli-grp-proc_batchwork-routing-full}~
,{&bef-cli-grp-proc_xml-file-import-full}~
,{&bef-cli-grp-proc_xml-esys-import-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define cli-grp-proc-list-full {&cli-grp-proc-list-full}" ).

&glob cli-grp-proc-name entry (lookup (~~~~~~~{&cli-grp-proc-code}, {&cli-grp-proc-list}) + 1, ',' + {&cli-grp-proc-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define cli-grp-proc-name {&cli-grp-proc-name}" ).


{ cmp/cr-prep.i 1 thref-proc_batchwork-export  batchwork-export  "Операции по списку-экспорт"       batchwork-export     "Batch work-export"     }
{ cmp/cr-prep.i 1 thref-proc_batchwork-routing batchwork-routing "Операции по списку-маршрутизация" batchwork-routing    "Batch work-routing"    }
{ cmp/cr-prep.i 1 thref-proc_xml-file-import   xml-file-import   "Импорт из xml-файла"              xml-file-import      "XML-file import"       }
{ cmp/cr-prep.i 1 thref-proc_xml-esys-import   xml-esys-import   "Импорт из ВС"                     xml-esys-import      "ES import"             }
{ cmp/cr-prep.i 1 thref-proc_recadd            recadd            "Добавление записи"                recadd               "Add Record"            }
{ cmp/cr-prep.i 1 thref-proc_recupdate         recupdate         "Изменение записи"                 recupdate            "Change Record"         }
{ cmp/cr-prep.i 1 thref-proc_ref-event         ref-event         "События справочников"             ref-event            "References Event"      }



&glob thref-proc-list '~
{&bef-thref-proc_batchwork-export}~
,{&bef-thref-proc_batchwork-routing}~
,{&bef-thref-proc_xml-file-import}~
,{&bef-thref-proc_xml-esys-import}~
,{&bef-thref-proc_recadd}~
,{&bef-thref-proc_recupdate}~
,{&bef-thref-proc_ref-event}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define thref-proc-list {&thref-proc-list}" ).

&glob thref-proc-list-full '~
{&bef-thref-proc_batchwork-export-full}~
,{&bef-thref-proc_batchwork-routing-full}~
,{&bef-thref-proc_xml-file-import-full}~
,{&bef-thref-proc_xml-esys-import-full}~
,{&bef-thref-proc_recadd-full}~
,{&bef-thref-proc_recupdate-full}~
,{&bef-thref-proc_ref-event-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define thref-proc-list-full {&thref-proc-list-full}" ).

&glob thref-proc-name entry (lookup (~~~~~~~{&thref-proc-code}, {&thref-proc-list}) + 1, ',' + {&thref-proc-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define thref-proc-name {&thref-proc-name}" ).


{ cmp/cr-prep.i 1 chk-doc-proc_gline-discnt-calc  gline-discnt-calc  "Расчет скидки по строке товара"       gline-discnt-calc     "Item Line Discnt Calc"     }
{ cmp/cr-prep.i 1 chk-doc-proc_pline-discnt-calc  pline-discnt-calc  "Расчет скидки по строке оплат"        pline-discnt-calc     "Pay Line Discnt Calc"     }
{ cmp/cr-prep.i 1 chk-doc-proc_subtotal-discnt-calc subtotal-discnt-calc "Расчет скидки на подитог" subtotal-discnt-calc    "Subtotal Discnt Calc"    }

&glob chk-doc-proc-list '~
{&bef-chk-doc-proc_gline-discnt-calc}~
,{&bef-chk-doc-proc_pline-discnt-calc}~
,{&bef-chk-doc-proc_subtotal-discnt-calc}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define chk-doc-proc-list {&chk-doc-proc-list}" ).

&glob chk-doc-proc-list-full '~
{&bef-chk-doc-proc_gline-discnt-calc-full}~
,{&bef-chk-doc-proc_pline-discnt-calc-full}~
,{&bef-chk-doc-proc_subtotal-discnt-calc-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define chk-doc-proc-list-full {&chk-doc-proc-list-full}" ).

&glob chk-doc-proc-name entry (lookup (~~~~~~~{&chk-doc-proc-code}, {&chk-doc-proc-list}) + 1, ',' + {&chk-doc-proc-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define chk-doc-proc-name {&chk-doc-proc-name}" ).


{ cmp/cr-prep.i 1 edoc-proc_batchwork-export_order    batchwork-export_order    "Заказы поставщику-экспорт"               batchwork-export_order     "Supplier Orders-export"    }
{ cmp/cr-prep.i 1 edoc-proc_batchwork-routing_order   batchwork-routing_order   "Заказы поставщику-маршрутизация"         batchwork-routing_order    "Supplier Orders-routing"    }
{ cmp/cr-prep.i 1 edoc-proc_xml-esys-import_order     xml-esys-import_order     "Заказы поставщику-импорт из ВС"          xml-esys-import_order      "Supplier Orders-ES import"             }
{ cmp/cr-prep.i 1 edoc-proc_xml-file-import_order     xml-file-import_order     "Заказы поставщику-импорт из xml-файла"   xml-file-import_order      "SUpplier Orders-XML-file import"       }
{ cmp/cr-prep.i 1 edoc-proc_batchwork-export_rcv      batchwork-export_rcv      "Поставки поставщика-экспорт"             batchwork-export_order     "Supplier Rcv-export"    }
{ cmp/cr-prep.i 1 edoc-proc_batchwork-routing_rcv     batchwork-routing_rcv     "Поставки поставщика-маршрутизация"       batchwork-routing_order    "Supplier Rcv-routing"    }
{ cmp/cr-prep.i 1 edoc-proc_xml-esys-import_rcv       xml-esys-import_rcv       "Поставка поставщика-импорт из ВС"        xml-esys-import_order      "Supplier Rcv-ES import"             }
{ cmp/cr-prep.i 1 edoc-proc_xml-file-import_rcv     xml-file-import_rcv     "Поставка поставщика-импорт из xml-файла"  xml-file-import_order       "Supplier Rcv-XML-file import"       }
{ cmp/cr-prep.i 1 edoc-proc_batchwork-routing_price-doc batchwork-routing_price-doc "ДНЦ/переоценка-маршрутизация"     batchwork-routing_order     "PDF-routing"    }
{ cmp/cr-prep.i 1 edoc-proc_xml-esys-import_price-doc xml-esys-import_price-doc "ДНЦ-импорт из ВС"                        xml-esys-import_price-doc  "PDF-ES import"             }
{ cmp/cr-prep.i 1 edoc-proc_xml-esys-import_trn-doc   xml-esys-import_trn-doc   "Накладные-импорт из ВС"               xml-esys-import_trn-doc     "TRN-ES import"             }
{ cmp/cr-prep.i 1 edoc-proc_batchwork-routing_trn-doc batchwork-routing_trn-doc "Накладные-маршрутизация"              batchwork-routing_trn-doc   "TRN-routing"    }
{ cmp/cr-prep.i 1 edoc-proc_xml-esys-import_inv-doc   xml-esys-import_inv-doc   "Инвентаризации-импорт из ВС"          xml-esys-import_inv-doc     "INV-ES import"             }
{ cmp/cr-prep.i 1 edoc-proc_xml-esys-import_contract  xml-esys-import_contract  "Дог-ра и специф-ции-импорт из ВС"     xml-esys-import_contract    "Contract-ES import"        }
{ cmp/cr-prep.i 1 edoc-proc_batchwork-routing_intorder batchwork-routing_intorder "Заявки РЦ-маршрутизация"            batchwork-routing_intorder  "Distr.Center Orders-routing"    }
{ cmp/cr-prep.i 1 edoc-proc_xml-esys-import_intorder   xml-esys-import_intorder   "Заявки РЦ-импорт из ВС"             xml-esys-import_intorder    "Distr.Center Orders-ES import"             }
{ cmp/cr-prep.i 1 edoc-proc_batchwork-routing_inkas    batchwork-routing_inkas    "Док-ты продажи-маршрутизация"       batchwork-routing_inkas     "INKAS-routing"    }
{ cmp/cr-prep.i 1 edoc-proc_event_order                event_order                "Заказы поставщику-событие"          event_order                 "Supplier Orders-event"    }
{ cmp/cr-prep.i 1 edoc-proc_event_rcv                  event_rcv                  "Поставки поставщика-событие"        event_rcv                   "Supplier Rcv-event"    }
{ cmp/cr-prep.i 1 edoc-proc_event_trn-doc              event_trn-doc              "Накладные-событие"                  event_trn-doc               "Supplier Rcv-event"    }
{ cmp/cr-prep.i 1 edoc-proc_event_inv-doc              event_inv-doc              "Инвентаризация-событие"             event_inv-doc               "INV-event"    }
{ cmp/cr-prep.i 1 edoc-proc_event_intorder             event_intorder             "Заявки РЦ-событие"                  event_intorder              "Distr.Center Orders-event"    }
{ cmp/cr-prep.i 1 edoc-proc_event_price-doc            event_price-doc            "ДНЦ/переоценка-событие"             event_price-doc             "PDF-event"    }
{ cmp/cr-prep.i 1 edoc-proc_event_inkas                event_inkas                "Документ продажи-событие"           event_inkas                 "Sale document-event"    }
{ cmp/cr-prep.i 1 edoc-proc_event_rvs-doc              event_rvs-doc              "Документ сверки-событие"            event_rvs-doc               "Кevise document-event"  }
{ cmp/cr-prep.i 1 edoc-proc_event_shift                event_shift                "Документ продажи-событие"           event_shift                 "Shift-event" }
{ cmp/cr-prep.i 1 edoc-proc_event_icnt-doc             event_icnt-doc             "Документ инв. ТРК-событие"          event_icnt-doc              "ICNT-event" }
{ cmp/cr-prep.i 1 edoc-proc_event_fin-doc              event_fin-doc              "Документ финансовый-событие"        event_fin-doc               "fin-doc-event" }
{ cmp/cr-prep.i 1 edoc-proc_event_fbr-doc              event_fbr-doc              "Документ производства-событие"      event_fbr-doc               "fbr-doc-event" }
{ cmp/cr-prep.i 1 edoc-proc_event_utd                  event_utd                  "Документ УПД"                       event_utd                   "utd-event" }
{ cmp/cr-prep.i 1 edoc-proc_event_mark                 event_mark                 "Марки"                              event_mark                  "mark-event" }
{ cmp/cr-prep.i 1 edoc-proc_event_user-action          event_user-action          "История действий пользователя"      event_user-action           "user-action-event" }
{ cmp/cr-prep.i 1 edoc-proc_text-export_specif         text-export_specif         "Экспорт спецификации в текст.файл"  text-export_specif          "Specification export to text" }
{ cmp/cr-prep.i 1 edoc-proc_excel-export_specif        excel-export_specif        "Экспорт спецификации в Excel"       excel-export_specif         "Specification export to Excel" }
{ cmp/cr-prep.i 1 edoc-proc_text-import_specif         text-import_specif         "Импорт спецификации из текст.файла"  text-export_specif         "Specification import from text" }
{ cmp/cr-prep.i 1 edoc-proc_excel-import_specif        excel-import_specif        "Импорт спецификации из Excel"       excel-export_specif         "Specification import form Excel" }



&glob edoc-proc-list '~
{&bef-edoc-proc_batchwork-export_order}~
,{&bef-edoc-proc_batchwork-routing_order}~
,{&bef-edoc-proc_xml-esys-import_order}~
,{&bef-edoc-proc_xml-file-import_order}~
,{&bef-edoc-proc_batchwork-export_rcv}~
,{&bef-edoc-proc_batchwork-routing_rcv}~
,{&bef-edoc-proc_xml-esys-import_rcv}~
,{&bef-edoc-proc_xml-file-import_rcv}~
,{&bef-edoc-proc_batchwork-routing_price-doc}~
,{&bef-edoc-proc_xml-esys-import_price-doc}~
,{&bef-edoc-proc_xml-esys-import_trn-doc}~
,{&bef-edoc-proc_batchwork-routing_trn-doc}~
,{&bef-edoc-proc_xml-esys-import_inv-doc}~
,{&bef-edoc-proc_xml-esys-import_contract}~
,{&bef-edoc-proc_batchwork-routing_intorder}~
,{&bef-edoc-proc_xml-esys-import_intorder}~
,{&bef-edoc-proc_batchwork-routing_inkas}~
,{&bef-edoc-proc_event_order}~
,{&bef-edoc-proc_event_rcv}~
,{&bef-edoc-proc_event_trn-doc}~
,{&bef-edoc-proc_event_inv-doc}~
,{&bef-edoc-proc_event_intorder}~
,{&bef-edoc-proc_event_price-doc}~
,{&bef-edoc-proc_event_inkas}~
,{&bef-edoc-proc_text-export_specif}~
,{&bef-edoc-proc_excel-export_specif}~
,{&bef-edoc-proc_text-import_specif}~
,{&bef-edoc-proc_excel-import_specif}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define edoc-proc-list {&edoc-proc-list}" ).

&glob edoc-proc-list-full '~
{&bef-edoc-proc_batchwork-export_order-full}~
,{&bef-edoc-proc_batchwork-routing_order-full}~
,{&bef-edoc-proc_xml-esys-import_order-full}~
,{&bef-edoc-proc_xml-file-import_order-full}~
,{&bef-edoc-proc_batchwork-export_rcv-full}~
,{&bef-edoc-proc_batchwork-routing_rcv-full}~
,{&bef-edoc-proc_xml-esys-import_rcv-full}~
,{&bef-edoc-proc_xml-file-import_rcv-full}~
,{&bef-edoc-proc_batchwork-routing_price-doc-full}~
,{&bef-edoc-proc_xml-esys-import_price-doc-full}~
,{&bef-edoc-proc_xml-esys-import_trn-doc-full}~
,{&bef-edoc-proc_batchwork-routing_trn-doc-full}~
,{&bef-edoc-proc_xml-esys-import_inv-doc-full}~
,{&bef-edoc-proc_xml-esys-import_contract-full}~
,{&bef-edoc-proc_batchwork-routing_intorder-full}~
,{&bef-edoc-proc_xml-esys-import_intorder-full}~
,{&bef-edoc-proc_batchwork-routing_inkas-full}~
,{&bef-edoc-proc_event_order-full}~
,{&bef-edoc-proc_event_rcv-full}~
,{&bef-edoc-proc_event_trn-doc-full}~
,{&bef-edoc-proc_event_inv-doc-full}~
,{&bef-edoc-proc_event_intorder-full}~
,{&bef-edoc-proc_event_price-doc-full}~
,{&bef-edoc-proc_event_inkas-full}~
,{&bef-edoc-proc_text-export_specif-full}~
,{&bef-edoc-proc_excel-export_specif-full}~
,{&bef-edoc-proc_text-import_specif-full}~
,{&bef-edoc-proc_excel-import_specif-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define edoc-proc-list-full {&edoc-proc-list-full}" ).

&glob edoc-proc-name entry (lookup (~~~~~~~{&edoc-proc-code}, {&edoc-proc-list}) + 1, ',' + {&edoc-proc-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define edoc-proc-name {&edoc-proc-name}" ).



{ cmp/cr-prep.i 1 fdoc-proc_work_fin-doc               work_fin-doc                "Фин.док-ты-работа"           work_fin-doc                 "Fin.Doc - working"    }


&glob fdoc-proc-list '~
{&bef-fdoc-proc_work_fin-doc}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define fdoc-proc-list {&fdoc-proc-list}" ).

&glob fdoc-proc-list-full '~
{&bef-fdoc-proc_work_fin-doc-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define fdoc-proc-list-full {&fdoc-proc-list-full}" ).

&glob fdoc-proc-name entry (lookup (~~~~~~~{&fdoc-proc-code}, {&fdoc-proc-list}) + 1, ',' + {&fdoc-proc-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define fdoc-proc-name {&fdoc-proc-name}" ).


{ cmp/cr-prep.i 1 pdf-proc_pdf-main-doc-close      pdf-main-doc-close      "Закрытие ДНЦ по ГТПЛ"                   pdf-main-doc-close            "Main PDF Close"    }
{ cmp/cr-prep.i 1 pdf-proc_overvalue-act-close     overvalue-act-close     "Закрытие переоценки на факт"            overvalue-act-close           "Overvalue Act Close"    }

&glob pdf-proc-list '~
{&bef-pdf-proc_pdf-main-doc-close}~
,{&bef-pdf-proc_overvalue-act-close}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define pdf-proc-list {&pdf-proc-list}" ).

&glob pdf-proc-list-full '~
{&bef-pdf-proc_pdf-main-doc-close-full}~
,{&bef-pdf-proc_overvalue-act-close-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define pdf-proc-list-full {&pdf-proc-list-full}" ).

&glob pdf-proc-name entry (lookup (~~~~~~~{&pdf-proc-code}, {&pdf-proc-list}) + 1, ',' + {&pdf-proc-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define pdf-proc-name {&pdf-proc-name}" ).

{ cmp/cr-prep.i 1 rep-proc_rep-batchwork      batchwork      "Выполнение отчета по расписанию"   batchwork      "Scheduled Reports"   }
{ cmp/cr-prep.i 1 rep-proc_rep-close-shift    close-shift    "Выполнение отчета при закрытии смены"   close-shift   "Shift Closing Reports"   }


&glob rep-proc-list '~
{&bef-rep-proc_rep-batchwork}~
,{&bef-rep-proc_rep-close-shift}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define rep-proc-list {&rep-proc-list}" ).

&glob rep-proc-list-full '~
{&bef-rep-proc_rep-batchwork-full}~
,{&bef-rep-proc_rep-close-shift-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define rep-proc-list-full {&rep-proc-list-full}" ).

&glob rep-proc-name entry (lookup (~~~~~~~{&rep-proc-code}, {&rep-proc-list}) + 1, ',' + {&rep-proc-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define rep-proc-name {&rep-proc-name}" ).


{ cmp/cr-prep.i 1 ord-proc_ord-batchwork      batchwork      "Работа с заказами по расписанию"   batchwork      "Scheduled Orders"   }

&glob ord-proc-list '~
{&bef-ord-proc_ord-batchwork}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define ord-proc-list {&ord-proc-list}" ).

&glob ord-proc-list-full '~
{&bef-ord-proc_ord-batchwork-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define ord-proc-list-full {&ord-proc-list-full}" ).

&glob ord-proc-name entry (lookup (~~~~~~~{&ord-proc-code}, {&ord-proc-list}) + 1, ',' + {&ord-proc-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define ord-proc-name {&ord-proc-name}" ).





{ cmp/cr-prep.i 1 edoc        edoc        "Оп-рации с док-тами и эл.документооборот"   edoc "EDocument Exchange"  }
{ cmp/cr-prep.i 1 thref       thref       "Справочники и классификаторы IBS TH"   thref "IBS TH Refr and Classificators"  }
{ cmp/cr-prep.i 1 pdf         pdf         "ДНЦ и переоценки"                     pdf "Price Document Forming"  }
{ cmp/cr-prep.i 1 rep         rep         "Отчеты"                               rep "Reports"  }
{ cmp/cr-prep.i 1 ord         ord         "Заказы"                               ord "Orders"  }
{ cmp/cr-prep.i 1 cmb         cmb         "Комбинации разнотипных алгоритмов"    cmb "Combined Algos"  }
{ cmp/cr-prep.i 1 fdoc        fdoc        "Оп-рации с фин док-тами"              fdoc "Fin Documents"  }


&glob profile-type-list '~
{&bef-table_dis-card-type}~
,{&bef-table_goods}~
,{&bef-table_clients}~
,{&bef-table_gds-grp}~
,{&bef-table_cli-grp}~
,{&bef-table_chk-doc}_IBS-TH~
,{&bef-table_chk-doc}_IBS-TH-MOB~
,{&bef-edoc}~
,{&bef-thref}~
,{&bef-pdf}~
,{&bef-rep}~
,{&bef-ord}~
,{&bef-cmb}~
,{&bef-fdoc}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define profile-type-list {&profile-type-list}" ).


&glob profile-type-list-full '~
{&bef-table_dis-card-type-full}~
,{&bef-table_goods-full}~
,{&bef-table_clients-full}~
,{&bef-table_gds-grp-full}~
,{&bef-table_cli-grp-full}~
,{&bef-table_chk-doc-full}_IBS-TH~
,{&bef-table_chk-doc-full}_IBS-TH-MOB~
,{&bef-edoc-full}~
,{&bef-thref-full}~
,{&bef-pdf-full}~
,{&bef-rep-full}~
,{&bef-ord-full}~
,{&bef-cmb-full}~
,{&bef-fdoc-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define profile-type-list-full {&profile-type-list-full}" ).


&glob profile-type-name entry (lookup (~~~~~~~{&profile-type-code}, {&profile-type-list}) + 1, ',' + {&profile-type-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define profile-type-name {&profile-type-name}" ).


&glob pchain-type-list '~
{&bef-table_dis-card-type}~
,{&bef-table_goods}~
,{&bef-table_clients}~
,{&bef-table_gds-grp}~
,{&bef-table_cli-grp}~
,{&bef-table_chk-doc}~
,{&bef-edoc}~
,{&bef-thref}~
,{&bef-pdf}~
,{&bef-rep}~
,{&bef-ord}~
,{&bef-fdoc}~
':U

/*список профайлов по codex*/
&glob codex-profile-type entry (~~~~~~~{&codex-code}, '~
{&bef-table_dis-card-type}~
,{&bef-table_dis-card-type}~
,{&bef-table_dis-card-type}~
,{&bef-table_dis-card-type}~
,{&bef-table_dis-card-type}~
,{&bef-table_dis-card-type}~
,~
,~
,~
,~
,{&bef-table_goods}~
,{&bef-table_clients}~
,{&bef-table_gds-grp}~
,{&bef-table_cli-grp}~
,~
,~
,~
,{&bef-edoc}~
,{&bef-table_chk-doc}~
,{&bef-thref}~
,{&bef-pdf}~
,{&bef-rep}~
,{&bef-ord}~
,{&bef-fdoc}~
':U)


run filwrlib_append-new-line in this-procedure ( input "&global-define codex-profile-type {&codex-profile-type}" ).

run filwrlib_append-new-line in this-procedure ( input "&global-define pchain-type-list {&pchain-type-list}" ).

{ cmp/cr-prep.i 1 gds-discnt-role        gds-discnt-role        "  "   gds-discnt-role }
{ cmp/cr-prep.i 1 subtotal-discnt-role   subtotal-discnt-role   "  "   subtotal-discnt-role }
{ cmp/cr-prep.i 1 pay-discnt-role        pay-discnt-role        "  "   pay-discnt-role }

&glob calc-point-discnt-role-list '~
{&bef-gds-discnt-role}~
,{&bef-subtotal-discnt-role}~
,{&bef-pay-discnt-role}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define calc-point-discnt-role-list {&calc-point-discnt-role-list}" ).

{ cmp/cr-prep.i 1 rcv-req   "запрос"        "  "   request}
{ cmp/cr-prep.i 1 rcv-in    "in"            "  "   in}
{ cmp/cr-prep.i 1 rcv-out   "out"           "  "   out}
{ cmp/cr-prep.i 1 rcv-in_full    "внутр"    "  "   inner }
{ cmp/cr-prep.i 1 rcv-out_full   "внешн"   "  "   outer }

&glob rcv-type-all {&rcv-out},{&rcv-in},{&rcv-req}
run filwrlib_append-new-line in this-procedure ( input "&global-define rcv-type-all {&rcv-type-all}" ).

&glob rcv-type-spis '{&bef-rcv-out},{&bef-rcv-in},{&bef-rcv-req}'
run filwrlib_append-new-line in this-procedure ( input "&global-define rcv-type-spis {&rcv-type-spis}" ).

&glob rcv-type-all_full {&rcv-out_full},{&rcv-in_full},{&rcv-req}
run filwrlib_append-new-line in this-procedure ( input "&global-define rcv-type-all_full {&rcv-type-all_full}" ).

&glob rcv-type-spis_full '{&bef-rcv-out_full},{&bef-rcv-in_full},{&bef-rcv-req}'
run filwrlib_append-new-line in this-procedure ( input "&global-define rcv-type-spis_full {&rcv-type-spis_full}" ).


{ cmp/cr-prep.i 1 cdt-ach          40  "EasyFuel"                               40       "EasyFuel" }
{ cmp/cr-prep.i 1 cdt-achexp       41  "EasyFuel-расходы"                       41       "EasyFuel-expenses" }
{ cmp/cr-prep.i 1 cdt-achdata      42  "EasyFuel-данные"                        42       "EasyFuel-data" }
{ cmp/cr-prep.i 1 cdt-cfserial      5   "Фискальные счетчики-сер.№ ККМ"          5       "Fiscal Counters-Serial No" }
{ cmp/cr-prep.i 1 cdt-cfregnum      6   "Фискальные счетчики-рег.№ ККМ"          6       "Fiscal Counters-Reg No" }
{ cmp/cr-prep.i 1 cdt-cfowner       7   "Фискальные счетчики-код владельца"      7       "Fiscal Counters-Owner Code" }
{ cmp/cr-prep.i 1 cdt-cfeklzserial  8   "Фискальные счетчики-сер.№ ЭКЛЗ"         8       "Fiscal Counters-ECLZ Ser.No" }
{ cmp/cr-prep.i 1 cdt-cfzcount      9   "Фискальные счетчики-№ фиск.смены"       9       "Fiscal Counters-Fisc.ShiftNo" }
{ cmp/cr-prep.i 1 cdt-cfdate       10   "Фискальные счетчики-Дата/время ККМ"     10      "Fiscal Counters-Date/Time" }
{ cmp/cr-prep.i 1 cdt-cfxcount     11   "Фискальные счетчики-счетчик X-отчетов"  11      "Fiscal Counters-X-rep Counter" }
{ cmp/cr-prep.i 1 cdt-cfejcount    12   "Фискальные счетчики-счетчик контр.лент" 12      "Fiscal Counters-Band Counter" }
{ cmp/cr-prep.i 1 cdt-cfcash       13   "Фискальные счетчики-счетчик наличности" 13      "Fiscal Counters-Cash Counter" }
{ cmp/cr-prep.i 1 cdt-cfdoccount   14   "Фискальные счетчики-счетчик чеков"      14      "Fiscal Counters-Receipt Counter" }
{ cmp/cr-prep.i 1 cdt-cfsalesaccum 15   "Фискальные счетчики-сумма продаж"       15      "Fiscal Counters-Sales Accum" }
{ cmp/cr-prep.i 1 cdt-cfretaccum   16   "Фискальные счетчики-сумма возвратов"    16      "Fiscal Counters-Returns Accum" }
{ cmp/cr-prep.i 1 cdt-cfreg        17   "Фискальные счетчики-регистры"           17      "Fiscal Counters-Registers" }


&glob cdt-type-list '~
{&bef-cdt-ach}~
,{&bef-cdt-achexp}~
,{&bef-cdt-achdata}~
,{&bef-cdt-cfserial}~
,{&bef-cdt-cfregnum}~
,{&bef-cdt-cfowner}~
,{&bef-cdt-cfeklzserial}~
,{&bef-cdt-cfzcount}~
,{&bef-cdt-cfdate}~
,{&bef-cdt-cfxcount}~
,{&bef-cdt-cfejcount}~
,{&bef-cdt-cfcash}~
,{&bef-cdt-cfdoccount}~
,{&bef-cdt-cfsalesaccum}~
,{&bef-cdt-cfretaccum}~
,{&bef-cdt-cfreg}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define cdt-type-list {&cdt-type-list}" ).

&glob cdt-type-list-full '~
{&bef-cdt-ach-full}~
,{&bef-cdt-achexp-full}~
,{&bef-cdt-achdata-full}~
,{&bef-cdt-cfserial-full}~
,{&bef-cdt-cfregnum-full}~
,{&bef-cdt-cfowner-full}~
,{&bef-cdt-cfeklzserial-full}~
,{&bef-cdt-cfzcount-full}~
,{&bef-cdt-cfdate-full}~
,{&bef-cdt-cfxcount-full}~
,{&bef-cdt-cfejcount-full}~
,{&bef-cdt-cfcash-full}~
,{&bef-cdt-cfdoccount-full}~
,{&bef-cdt-cfsalesaccum-full}~
,{&bef-cdt-cfretaccum-full}~
,{&bef-cdt-cfreg-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define cdt-type-list-full {&cdt-type-list-full}" ).


{ cmp/cr-prep.i 1 th-pos-screen       th-pos-screen       "Экран IBS TH POS"        th-pos-screen          "IBS TH POS Screen"          }
{ cmp/cr-prep.i 1 th-pos-keyboard     th-pos-keyboard     "Клавиатура IBS TH POS"   th-pos-keyboard        "IBS TH POS Keyboard"          }


&glob layout-type-list '{&bef-th-pos-screen}~
,{&bef-th-pos-keyboard}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define layout-type-list {&layout-type-list}" ).

&glob layout-type-list-full '{&bef-th-pos-screen-full}~
,{&bef-th-pos-keyboard-full}~
':U


run filwrlib_append-new-line in this-procedure ( input "&global-define layout-type-list-full {&layout-type-list-full}" ).

&glob layout-type-name entry (lookup (~~~~~~~{&layout-type-code}, {&layout-type-list}) + 1, ',' + {&layout-type-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define layout-type-name {&layout-type-name}" ).


{ cmp/cr-prep.i 1 layout-device-IBM-50         "IBM-50"         "  "   IBM-50 }
{ cmp/cr-prep.i 1 layout-device-Screen         "Screen"         "  "   Screen }
{ cmp/cr-prep.i 1 layout-device-TouchScreen    "TouchScreen"    "  "   TouchScreen }

&glob th-pos-device-keyboard-list '{&bef-layout-device-IBM-50}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define th-pos-device-keyboard-list {&th-pos-device-keyboard-list}" ).

&glob th-pos-device-screen-list '{&bef-layout-device-Screen}~
,{&bef-layout-device-TouchScreen}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define th-pos-device-screen-list {&th-pos-device-screen-list}" ).


{ cmp/cr-prep.i 1 wi-mode-type-IBS-TH         IBS-TH              IBS-TH         IBS-TH          IBS-TH       }

&glob wi-mode-type-list '{&bef-wi-mode-type-IBS-th}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define wi-mode-type-list {&wi-mode-type-list}" ).


{ cmp/cr-prep.i 1 layout-ordinal        0                Пользовательская      0    Customary    }
{ cmp/cr-prep.i 1 layout-default        1                "Шаблон IBS TH"        1   "ISB TH Template" }
{ cmp/cr-prep.i 1 layout-mandatory      -1               Обязательная          -1   Mandatory }


&glob layout-kind-codes '{&bef-layout-ordinal}~
,{&bef-layout-default}~
,{&bef-layout-mandatory}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define layout-kind-codes {&layout-kind-codes}" ).

&glob layout-kind-codes-full '{&bef-layout-ordinal-full}~
,{&bef-layout-default-full}~
,{&bef-layout-mandatory-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define layout-kind-codes-full {&layout-kind-codes-full}" ).

&glob layout-kind-name entry (lookup (~~~~~~~{&layout-kind-code}, {&layout-kind-codes}) + 1, ',' + {&layout-kind-codes-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define layout-kind-name {&layout-kind-name}" ).


{ cmp/cr-prep.i 1 lelem-type-programmable         0               Программируемый        0   Programmable    }
{ cmp/cr-prep.i 1 lelem-type-nonprogrammable     -1               Непрограммируемый     -1   NonProgrammable }


&glob lelem-type-codes '{&bef-lelem-type-programmable}~
,{&bef-lelem-type-nonprogrammable}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define lelem-type-codes {&lelem-type-codes}" ).

&glob lelem-type-codes-full '{&bef-lelem-type-programmable-full}~
,{&bef-lelem-type-nonprogrammable-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define lelem-type-codes-full {&lelem-type-codes-full}" ).

&glob lelem-type-name entry (lookup (~~~~~~~{&lelem-type-code}, {&lelem-type-codes}) + 1, ',' + {&lelem-type-codes-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define lelem-type-name {&lelem-type-name}" ).




{ cmp/cr-prep.i 1 layout-elem-rule-ordinal        0                " "                    0   " "    }
{ cmp/cr-prep.i 1 layout-elem-rule-mandatory      1               Обязательная            1   Mandatory }


&glob layout-elem-rule-kind-codes '{&bef-layout-elem-rule-ordinal}~
,{&bef-layout-elem-rule-mandatory}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define layout-elem-rule-kind-codes {&layout-elem-rule-kind-codes}" ).

&glob layout-elem-rule-kind-codes-full '{&bef-layout-elem-rule-ordinal-full}~
,{&bef-layout-elem-rule-mandatory-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define layout-kind-codes-full {&layout-kind-codes-full}" ).

&glob layout-elem-rule-kind-name entry (lookup (~~~~~~~{&layout-elem-rule-kind-code}, {&layout-elem-rule-kind-codes}) + 1, ',' + {&layout-elem-rule-kind-codes-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define layout-elem-rule-kind-name {&layout-elem-rule-kind-name}" ).



{ cmp/cr-prep.i 1 cd-log-level-non      0   "Нет логирования"                   0   "No Log"    }
{ cmp/cr-prep.i 1 cd-log-level-low      1   "Низкий"                            1   "Low"       }
{ cmp/cr-prep.i 1 cd-log-level-medium   2   "Средний"                           2   "Medium"    }
{ cmp/cr-prep.i 1 cd-log-level-high     3   "Высокий"                           3   "High"      }

&glob cd-log-level-list '~
{&bef-cd-log-level-non}~
,{&bef-cd-log-level-low}~
,{&bef-cd-log-level-medium}~
,{&bef-cd-log-level-high}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define cd-log-level-list {&cd-log-level-list}" ).

&glob cd-log-level-list-full '~
{&bef-cd-log-level-non-full}~
,{&bef-cd-log-level-low-full}~
,{&bef-cd-log-level-medium-full}~
,{&bef-cd-log-level-high-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define cd-log-level-list-full {&cd-log-level-list-full}" ).

&glob cd-log-level-name entry (lookup (~~~~~~~{&cd-log-level-code}, {&cd-log-level-list}) + 1, ',' + {&cd-log-level-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define cd-log-level-name {&cd-log-level-name}" ).



{ cmp/cr-prep.i 1 cd-cashless-sberbank       sberbank                "Сбербанк"                    sberbank   "Sberbank"    }


&glob cd-cashless-systems '{&bef-cd-cashless-sberbank}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define cd-cashless-systems {&cd-cashless-systems}" ).

&glob cd-cashless-systems-full '{&bef-cd-cashless-sberbank-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define cd-cashless-systems-full {&cd-cashless-systems-full}" ).


&glob cd-cashless-system-name entry (lookup (~~~~~~~{&cd-cashless-system-code}, {&cd-cashless-systems}) + 1, ',' + {&cd-cashless-systems-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define cd-cashless-system-name {&cd-cashless-system-name}" ).

{ cmp/cr-prep.i 1 cd-cd-IBM-VFD        IBM-VFD                "IBM VFD"              IBM-VFD          "IBM-VFD"    }
{ cmp/cr-prep.i 1 cd-cd-Shtrih-m-a1_40 Shtrih-M_v_A1.40       "Штрих-М v.A1.40"      Shtrih-M_v_A1.40 "SHtrih-M v.A1.40" }
{ cmp/cr-prep.i 1 cd-cd-Posiflex-pd2800-320 Posiflex-pd2800-320  "Posiflex-pd2800-320"      Posiflex-pd2800-320 "Posiflex-pd2800-320" }

&glob cd-cd-types '~
{&bef-cd-cd-IBM-VFD}~
,{&bef-cd-cd-Shtrih-m-a1_40}~
,{&bef-cd-cd-Posiflex-pd2800-320}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define cd-cd-types {&cd-cd-types}" ).

&glob cd-cd-types-full '~
{&bef-cd-cd-IBM-VFD-full}~
,{&bef-cd-cd-Shtrih-m-a1_40-full}~
,{&bef-cd-cd-Posiflex-pd2800-320-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define cd-cd-types-full {&cd-cd-types-full}" ).

&glob cd-cd-type-name entry (lookup (~~~~~~~{&cd-cd-type-code}, {&cd-cd-types}) + 1, ',' + {&cd-cd-types-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define cd-cd-type-name {&cd-cd-type-name}" ).


{ cmp/cr-prep.i 1 cd-cctv-Intellect       Intellect                "Интеллект"                    Intellect   "Intellect"    }
{ cmp/cr-prep.i 1 cd-cctv-prizma          Prizma                   "Призма"                       prizma      "Prizma"    }


&glob cd-cctv-systems '~
{&bef-cd-cctv-Intellect}~
,{&bef-cd-cctv-prizma}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define cd-cctv-systems {&cd-cctv-systems}" ).

&glob cd-cctv-systems-full '~
{&bef-cd-cctv-Intellect-full}~
,{&bef-cd-cctv-prizma-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define cd-cctv-systems-full {&cd-cctv-systems-full}" ).


&glob cd-cctv-system-name entry (lookup (~~~~~~~{&cd-cctv-system-code}, {&cd-cctv-systems}) + 1, ',' + {&cd-cctv-systems-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define cd-cctv-system-name {&cd-cctv-system-name}" ).




{ cmp/cr-prep.i 1 wi-mode-ibs-th-pos   cd-IBS-TH    "Режимы работы кассы IBS TH POS"                     cd-IBS-TH  "IBS TH POS Modes"               }


&glob wi-mode-type-list '{&bef-wi-mode-ibs-th-pos}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define wi-mode-type-list {&wi-mode-type-list}" ).

&glob wi-mode-type-list-full '{&bef-wi-mode-ibs-th-pos-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define wi-mode-type-list-full {&wi-mode-type-list-full}" ).


&glob wi-mode-type-name entry (lookup (~~~~~~~{&wi-mode-type-code}, {&wi-mode-type-list}) + 1, ',' + {&wi-mode-type-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define wi-mode-type-name {&wi-mode-type-name}" ).


/* Статусы EDOC-NN (ord-int1) */
{ cmp/cr-prep.i 1 edoc-empty      0    " "                     0  " "               }
{ cmp/cr-prep.i 1 edoc-stk        1    "отправлен"             1  "send"            }
{ cmp/cr-prep.i 1 edoc-stk-ok     2    "принят"                2  "get"             }
{ cmp/cr-prep.i 1 edoc-rpl        3    "подтвержден"           3  "confirm"         }
{ cmp/cr-prep.i 1 edoc-rpl-ok     4    "подтвержденOk"         4  "confirmOk"       }
{ cmp/cr-prep.i 1 edoc-acc        5    "согласованный ушел "   5  "confirm send"    }
{ cmp/cr-prep.i 1 edoc-acc-ok     6    "принят согласованный"  6  "get confirm"     }
{ cmp/cr-prep.i 1 edoc-pst        7    "поставка пришла"       7  "go rcv"          }
{ cmp/cr-prep.i 1 edoc-pst-ok     8    "поставка принята"      8  "get rcv"         }
{ cmp/cr-prep.i 1 edoc-trn        9    "ПН отправлена"         9  "trn send "       }
{ cmp/cr-prep.i 1 edoc-err        10   "Отказ"                 10 "error"           }

/* Состояние заказа (ord-int2)  */
{ cmp/cr-prep.i 1 edoc-return     1    "вернулся"              1 "return"           }
/* Состояние поставки (ord-int2)  */
{ cmp/cr-prep.i 1 edoc-diff       2    "разница"               2 "difference"       }

{ cmp/cr-prep.i 1 edoc-ext-stk      stk      stk    stk      stk     }
{ cmp/cr-prep.i 1 edoc-ext-stk-ok   stk-ok   stk-ok stk-ok   stk-ok  }
{ cmp/cr-prep.i 1 edoc-ext-rpl      rpl      rpl    rpl      rpl     }
{ cmp/cr-prep.i 1 edoc-ext-rpl-ok   rpl-ok   rpl-ok rpl-ok   rpl-ok  }
{ cmp/cr-prep.i 1 edoc-ext-acc      acc      acc    acc      acc     }
{ cmp/cr-prep.i 1 edoc-ext-acc-ok   acc-ok   acc-ok acc-ok   acc-ok  }
{ cmp/cr-prep.i 1 edoc-ext-pst      pst      pst    pst      pst     }
{ cmp/cr-prep.i 1 edoc-ext-pst-ok   pst-ok   pst-ok pst-ok   pst-ok  }
{ cmp/cr-prep.i 1 edoc-ext-trn      trn      trn    trn      trn     }
{ cmp/cr-prep.i 1 edoc-ext-err      err      err    err      err     }

&glob edoc-spis '{&bef-edoc-empty},~
{&bef-edoc-stk},~
{&bef-edoc-stk-ok},~
{&bef-edoc-rpl},~
{&bef-edoc-rpl-ok},~
{&bef-edoc-acc},~
{&bef-edoc-acc-ok},~
{&bef-edoc-pst},~
{&bef-edoc-pst-ok},~
{&bef-edoc-trn},~
{&bef-edoc-err}'

&glob edoc-spis-e '~
{&bef-edoc-ext-stk},~
{&bef-edoc-ext-stk-ok},~
{&bef-edoc-ext-rpl},~
{&bef-edoc-ext-rpl-ok},~
{&bef-edoc-ext-acc},~
{&bef-edoc-ext-acc-ok},~
{&bef-edoc-ext-pst},~
{&bef-edoc-ext-pst-ok},~
{&bef-edoc-ext-trn},~
{&bef-edoc-ext-err}'

&glob edoc-spis-f '{&bef-edoc-empty-full},~
{&bef-edoc-stk-full},~
{&bef-edoc-stk-ok-full},~
{&bef-edoc-rpl-full},~
{&bef-edoc-rpl-ok-full},~
{&bef-edoc-acc-full},~
{&bef-edoc-acc-ok-full},~
{&bef-edoc-pst-full},~
{&bef-edoc-pst-ok-full},~
{&bef-edoc-trn-full},~
{&bef-edoc-err-full}'

&glob edoc-spis-color '14,12,?,10,10,?,?,?,?,?,4'

run filwrlib_append-new-line in this-procedure ( input "&global-define edoc-spis {&edoc-spis}" ).
run filwrlib_append-new-line in this-procedure ( input "&global-define edoc-spis-e {&edoc-spis-e}" ).
run filwrlib_append-new-line in this-procedure ( input "&global-define edoc-spis-f {&edoc-spis-f}" ).
run filwrlib_append-new-line in this-procedure ( input "&global-define edoc-spis-color {&edoc-spis-color}" ).

&glob edoc-stts-color entry (lookup (~~~~~~~{&order-stts-int1}, {&edoc-spis}) , {&edoc-spis-color})
run filwrlib_append-new-line in this-procedure ( input "&global-define edoc-stts-color {&edoc-stts-color}" ).
&glob edoc-stts-name entry (lookup (~~~~~~~{&order-stts-int1}, {&edoc-spis}) , {&edoc-spis-f})
run filwrlib_append-new-line in this-procedure ( input "&global-define edoc-stts-name {&edoc-stts-name}" ).

&glob edoc-spis-ex ',~
{&bef-edoc-ext-stk},~
{&bef-edoc-ext-stk-ok},~
{&bef-edoc-ext-rpl},~
{&bef-edoc-ext-rpl-ok},~
{&bef-edoc-ext-acc},~
{&bef-edoc-ext-acc-ok},~
{&bef-edoc-ext-pst},~
{&bef-edoc-ext-pst-ok},~
{&bef-edoc-ext-trn},~
{&bef-edoc-ext-err}'

run filwrlib_append-new-line in this-procedure ( input "&global-define edoc-spis-ex {&edoc-spis-ex}" ).

&glob edoc-stts-ex entry (lookup (~~~~~~~{&order-stts-int1}, {&edoc-spis}) , {&edoc-spis-ex})
run filwrlib_append-new-line in this-procedure ( input "&global-define edoc-stts-ex {&edoc-stts-ex}" ).

/* Статусы EDI (ord-int1) */
{ cmp/cr-prep.i 1 edi-empty       0    " "                   0  " "            }
{ cmp/cr-prep.i 1 edi-orders      1    "отправлен"           1  "send"         }
{ cmp/cr-prep.i 1 edi-orders-sts  2    "принят"              2  "get"          }
{ cmp/cr-prep.i 1 edi-ordrsp      3    "подтвержден"         3  "confirm"      }
{ cmp/cr-prep.i 1 edi-ordrsp-no   4    "подтвержден-"        4  "confirm-"     }
{ cmp/cr-prep.i 1 edi-ordrsp-yes  5    "подтвержден+"        5  "confirm+"     }
{ cmp/cr-prep.i 1 edi-ordrsp-sts  6    "подтвержденОк"       6  "confirmOk"    }
{ cmp/cr-prep.i 1 edi-desadv      7    "поставка пришла"     7  "go rcv"       }
{ cmp/cr-prep.i 1 edi-desadv-sts  8    "поставка принята"    8  "get rcv"      }
{ cmp/cr-prep.i 1 edi-recadv      9    "ПН отправлена"       9  "trn send"     }
{ cmp/cr-prep.i 1 edi-recadv-sts  11   "ПН получена"         11 "trn get"      }
{ cmp/cr-prep.i 1 edi-err         99   "Отказ"               99 "error"        }
{ cmp/cr-prep.i 1 edi-orders-deliv    12   "Доставлен"       12 "delivered"        }
{ cmp/cr-prep.i 1 edi-crit-err        13   "Ошибка"          13 "criterror"        }

/* Состояние заказа (ord-int2)  */
{ cmp/cr-prep.i 1 edi-return     1    "вернулся"              1 "return"     }
/* Состояние поставки (ord-int2)  */
{ cmp/cr-prep.i 1 edi-diff       2    "разница"               2 "difference" }

&glob edi-spis '{&bef-edi-empty},~
{&bef-edi-orders},~
{&bef-edi-orders-sts},~
{&bef-edi-ordrsp},~
{&bef-edi-ordrsp-no},~
{&bef-edi-ordrsp-yes},~
{&bef-edi-ordrsp-sts},~
{&bef-edi-desadv},~
{&bef-edi-desadv-sts},~
{&bef-edi-recadv},~
{&bef-edi-recadv-sts},~
{&bef-edi-err},~
{&bef-edi-orders-deliv},~
{&bef-edi-crit-err}'

&glob edi-spis-f '{&bef-edi-empty-full},~
{&bef-edi-orders-full},~
{&bef-edi-orders-sts-full},~
{&bef-edi-ordrsp-full},~
{&bef-edi-ordrsp-no-full},~
{&bef-edi-ordrsp-yes-full},~
{&bef-edi-ordrsp-sts-full},~
{&bef-edi-desadv-full},~
{&bef-edi-desadv-sts-full},~
{&bef-edi-recadv-full},~
{&bef-edi-recadv-sts-full},~
{&bef-edi-err-full},~
{&bef-edi-orders-deliv-full},~
{&bef-edi-crit-err-full}'

&glob edi-spis-color '14,12,?,14,?,?,10,?,?,?,?,4,10,4'

run filwrlib_append-new-line in this-procedure ( input "&global-define edi-spis {&edi-spis}" ).
run filwrlib_append-new-line in this-procedure ( input "&global-define edi-spis-e {&edi-spis-e}" ).
run filwrlib_append-new-line in this-procedure ( input "&global-define edi-spis-f {&edi-spis-f}" ).
run filwrlib_append-new-line in this-procedure ( input "&global-define edi-spis-color {&edi-spis-color}" ).

&glob edi-stts-color entry (lookup (~~~~~~~{&order-stts-int1}, {&edi-spis}) , {&edi-spis-color})
run filwrlib_append-new-line in this-procedure ( input "&global-define edi-stts-color {&edi-stts-color}" ).
&glob edi-stts-name entry (lookup (~~~~~~~{&order-stts-int1}, {&edi-spis}) , {&edi-spis-f})
run filwrlib_append-new-line in this-procedure ( input "&global-define edi-stts-name {&edi-stts-name}" ).


{ cmp/cr-prep.i 1 esys-dm-ordinal         0    "Как в СПН"                     0  "Like NTS"               }
{ cmp/cr-prep.i 1 esys-dm-nnold           1    "Не архивировать;спец.имя;FTP"  1  "No arj;Custom-name;FTP" }
{ cmp/cr-prep.i 1 esys-dm-nn              2    "Не архивировать;FTP"           2  "No arj;FTP"             }
{ cmp/cr-prep.i 1 esys-dm-oracle-retail   3    "Oracle Retail"                 3  "Oracle Retail"          }
{ cmp/cr-prep.i 1 esys-dm-CDash           4    "Не архивировать(Панель Руководителя;DKLink)"  4  "No arj(Commanders DashBoard;DKLink)"    }
{ cmp/cr-prep.i 1 esys-dm-exite-edi       5    "Exite-EDI"                                    5  "Exite-EDI"              }
{ cmp/cr-prep.i 1 esys-dm-contour-edi     9    "Контур.EDI"                                   9  "Сontour.EDI"            }
{ cmp/cr-prep.i 1 esys-dm-egais          10    "ЕГАИС"                                       10  "EGAIS"                  }
{ cmp/cr-prep.i 1 esys-dm-erp-1C-RN      11    "ERP 1С РН"                                   11  "ERP-1C-RN"              }


&glob esys-dm-list '~
{&bef-esys-dm-ordinal}~
,{&bef-esys-dm-nn}~
,{&bef-esys-dm-oracle-retail}~
,{&bef-esys-dm-CDash}~
,{&bef-esys-dm-exite-edi}~
,{&bef-esys-dm-contour-edi}~
,{&bef-esys-dm-egais}~
,{&bef-esys-dm-erp-1C-RN}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define esys-dm-list {&esys-dm-list}" ).

&glob esys-dm-list-full '~
{&bef-esys-dm-ordinal-full}~
,{&bef-esys-dm-nn-full}~
,{&bef-esys-dm-oracle-retail-full}~
,{&bef-esys-dm-CDash-full}~
,{&bef-esys-dm-exite-edi-full}~
,{&bef-esys-dm-contour-edi-full}~
,{&bef-esys-dm-egais-full}~
,{&bef-esys-dm-erp-1C-RN-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define esys-dm-list-full {&esys-dm-list-full}" ).


&glob esys-dm-name entry (lookup (~~~~~~~{&esys-dm-code}, {&esys-dm-list}) + 1, ',' + {&esys-dm-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define esys-dm-name {&esys-dm-name}" ).

/* Атрибуты свойств групп на объекте */
{ cmp/cr-prep.i 1 ggoattr-QntyAssMat       QntyAssMat     QntyAssMat    QntyAssMat      QntyAssMat    }
{ cmp/cr-prep.i 1 ggoattr-LimAssMat        LimAssMat      LimAssMat     LimAssMat       LimAssMat     }
{ cmp/cr-prep.i 1 ggoattr-QntySpecGr       QntySpecGr     QntySpecGr    QntySpecGr      QntySpecGr    }
{ cmp/cr-prep.i 1 ggoattr-LimSpecGr        LimSpecGr      LimSpecGr     LimSpecGr       LimSpecGr     }
{ cmp/cr-prep.i 1 ggoattr-NotCorrOP        NotCorrOP      NotCorrOP     NotCorrOP       NotCorrOP     }
{ cmp/cr-prep.i 1 ggoattr-alc-min-price    alc-min-price  alc-min-price alc-min-price   alc-min-price }
{ cmp/cr-prep.i 1 ggoattr-marg-pr-paraf    marg-pr-paraf  marg-pr-paraf marg-pr-paraf   marg-pr-paraf }
{ cmp/cr-prep.i 1 ggoattr-level-dis        level-dis      level-dis     level-dis       level-dis     }
{ cmp/cr-prep.i 1 ggoattr-no-inc-auto-rep    no-inc-auto-rep    no-inc-auto-rep    no-inc-auto-rep    no-inc-auto-rep    }
{ cmp/cr-prep.i 1 ggoattr-ban-sales-via-cd   ban-sales-via-cd   ban-sales-via-cd   ban-sales-via-cd   ban-sales-via-cd   } 
{ cmp/cr-prep.i 1 ggoattr-table-menu         table-menu         table-menu         table-menu         table-menu         } 
{ cmp/cr-prep.i 1 ggoattr-alchol-grp         alchol-grp         alchol-grp         alchol-grp         alchol-grp         }
{ cmp/cr-prep.i 1 ggoattr-mark-grp           mark-grp           mark-grp           mark-grp           mark-grp           }
{ cmp/cr-prep.i 1 ggoattr-sum-grps           sum-grps           sum-grps           sum-grps           sum-grps           } 
{ cmp/cr-prep.i 1 ggoattr-mark-type          gg-mark-type       gg-mark-type       gg-mark-type       gg-mark-type       }
{ cmp/cr-prep.i 1 ggoattr-emrc-type          emrc-type          emrc-type          emrc-type          emrc-type       }

/* Атрибуты свойств товаров gds-obj-prop на объекте */

/*дата изменения НА СТАТУС НА ВЫВОД ИЗ АССОРТ*/
{ cmp/cr-prep.i 1 gopattr-CorrIztDel        CorrIztDel      CorrIztDel    CorrIztDel    CorrIztDel  }

/*corrcoeff-o* на самом деле должен лежать в gds-obj-prop-attr но у этой таблицы нет истории!!
история будет в gds-obj-attr!!!
*/

/*корректирующий коэффициент для расчета кол-ва в заказах Объект-Поставщик*/
{ cmp/cr-prep.i 1 attr-corrcoeff-po       corrcoeff-po      " "         corrcoeff-po    }

&glob gdspoatr-list '~
{&bef-attr-corrcoeff-po}~
,{&bef-gopattr-CorrIztDel}~
':u
run filwrlib_append-new-line in this-procedure ( input "&global-define gdspoatr-list {&gdspoatr-list}" ).

/*нужно два отдельных списка по обекъту и фирме - потому что в gds-obj-prop могут быть записи для obj-type = {&cmp}
и следовательно когда-нибудь смогут существовать аналогичные gds-obj-prop-attr
*/

&glob gdspoatr-list-obj '~
{&bef-attr-corrcoeff-po}~
,{&bef-gopattr-CorrIztDel}~
':u
run filwrlib_append-new-line in this-procedure ( input "&global-define gdspoatr-list-obj {&gdspoatr-list-obj}" ).

&glob gdspoatr-list-spec '~
{&bef-gopattr-CorrIztDel}~
':u
run filwrlib_append-new-line in this-procedure ( input "&global-define gdspoatr-list-spec {&gdspoatr-list-spec}" ).






/* Атрибуты  Ассортиментных матриц */
{ cmp/cr-prep.i 1 assmatat-RootShablon     RootShablon    RootShablon     RootShablon       RootShablon     }


{ cmp/cr-prep.i 1 sc-gds-weight      0    "Весовой"                     0  "Weight"               }
{ cmp/cr-prep.i 1 sc-gds-pieces      1    "Штучный"                     1  "Pieces" }


&glob sc-gds-types '~
{&bef-sc-gds-weight}~
,{&bef-sc-gds-pieces}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define sc-gds-types {&sc-gds-types}" ).

&glob sc-gds-types-full '~
{&bef-sc-gds-weight-full}~
,{&bef-sc-gds-pieces-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define sc-gds-types-full {&sc-gds-types-full}" ).

&glob sc-gds-type-name entry (lookup (~~~~~~~{&sc-gds-type}, {&sc-gds-types}) + 1, ',' + {&sc-gds-types-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define sc-gds-type-name {&sc-gds-type-name}" ).


{ cmp/cr-prep.i 1 sc-gds-deadflag-days      0    "Дни"                     0  "Days" }
{ cmp/cr-prep.i 1 sc-gds-deadflag-date      1    "Дата"                    1  "Date" }


&glob sc-gds-deadflags '~
{&bef-sc-gds-deadflag-days}~
,{&bef-sc-gds-deadflag-date}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define sc-gds-deadflags {&sc-gds-deadflags}" ).

&glob sc-gds-deadflags-full '~
{&bef-sc-gds-deadflag-days-full}~
,{&bef-sc-gds-deadflag-date-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define sc-gds-deadflags-full {&sc-gds-deadflags-full}" ).

&glob sc-gds-deadflag-name entry (lookup (~~~~~~~{&sc-gds-deadflag}, {&sc-gds-deadflags}) + 1, ',' + {&sc-gds-deadflags-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define sc-gds-deadflag-name {&sc-gds-deadflag-name}" ).



/* значения параметра pr-goods*/

{ cmp/cr-prep.i 1  pr-gds-no-ban      "1.нет запрета"          " "  1.no-ban    }
{ cmp/cr-prep.i 1  pr-gds-goods       "2.на товар"             " "  2.goods     }
{ cmp/cr-prep.i 1  pr-gds-petrol      "3.на топливо"           " "  3.petrol    }
{ cmp/cr-prep.i 1  pr-gds-serv        "4.на услугу"            " "  4.serv      }
{ cmp/cr-prep.i 1  pr-gds-gds-serv    "5.на товар и услугу"    " "  5.gds-serv  }
{ cmp/cr-prep.i 1  pr-gds-gds-ptrl    "6.на товар и топливо"   " "  6.gds-ptrl  }
{ cmp/cr-prep.i 1  pr-gds-serv-ptrl   "7.на услугу и топливо"  " "  7.serv-ptrl }
{ cmp/cr-prep.i 1  pr-gds-ban         "8.запрет на все"        " "  8.ban       }
{ cmp/cr-prep.i 1  pr-gds-ino-ban      1  " "  1 }
{ cmp/cr-prep.i 1  pr-gds-igoods       2  " "  2 }
{ cmp/cr-prep.i 1  pr-gds-ipetrol      3  " "  3 }
{ cmp/cr-prep.i 1  pr-gds-iserv        4  " "  4 }
{ cmp/cr-prep.i 1  pr-gds-igds-serv    5  " "  5 }
{ cmp/cr-prep.i 1  pr-gds-igds-ptrl    6  " "  6 }
{ cmp/cr-prep.i 1  pr-gds-iserv-ptrl   7  " "  7 }
{ cmp/cr-prep.i 1  pr-gds-iban         8  " "  8 }

/* Атрибуты заказа шапка и поставки */
{ cmp/cr-prep.i 1 orddocattr-cycle-doc-code        "cycle-doc-code"       " "  "cycle-doc-code"       }
{ cmp/cr-prep.i 1 orddocattr-cycle-day             "cycle-day"            " "  "cycle-day"            }
{ cmp/cr-prep.i 1 orddocattr-cycle-contract-code   "cycle-contract-code"  " "  "cycle-contract-code"  }
{ cmp/cr-prep.i 1 orddocattr-cycle-ship-date       "cycle-ship-date"      " "  "cycle-ship-date"      }
{ cmp/cr-prep.i 1 orddocattr-cycle-ship-time       "cycle-ship-time"      " "  "cycle-ship-time"      }
{ cmp/cr-prep.i 1 orddocattr-cycle-date1           "cycle-date1"          " "  "cycle-date1"          }
{ cmp/cr-prep.i 1 orddocattr-cycle-date2           "cycle-date2"          " "  "cycle-date2"          }
{ cmp/cr-prep.i 1 orddocattr-cycle-doc-date        "cycle-doc-date"       " "  "cycle-doc-date"       }
{ cmp/cr-prep.i 1 orddocattr-cycle-done            "cycle-done"           " "  "cycle-done"           }
{ cmp/cr-prep.i 1 orddocattr-cycle-exch-code       "exch-code"            " "  "exch-code"            }
{ cmp/cr-prep.i 1 orddocattr-cycle-exch-rate       "exch-rate"            " "  "exch-rate"            }
{ cmp/cr-prep.i 1 orddocattr-cycle-exch-scale      "exch-scale"           " "  "exch-scale"           }
{ cmp/cr-prep.i 1 orddocattr-cycle-base-rate       "base-rate"            " "  "base-rate"            }
{ cmp/cr-prep.i 1 orddocattr-cycle-base-scale      "base-scale"           " "  "base-scale"           }
{ cmp/cr-prep.i 1 orddocattr-ora-exp-seq-num       "ora-exp-seq-num"      " "  "ora-exp-seq-num"      }
{ cmp/cr-prep.i 1 orddocattr-nids                  "nids"                 " "  "nids"                 }
{ cmp/cr-prep.i 1 orddocattr-dids                  "dids"                 " "  "dids"                 }
{ cmp/cr-prep.i 1 orddocattr-invoiceNumber         "invoiceNumber"        " "  "invoiceNumber"        }
{ cmp/cr-prep.i 1 orddocattr-invoiceDate           "invoiceDate"          " "  "invoiceDate"          }

/* Атрибуты заказа строки */
{ cmp/cr-prep.i 1 ordlineattr-cli-qnty    "cycle-cli-qnty"  " "  "cycle-cli-qnty"     }
{ cmp/cr-prep.i 1 ordlineattr-min-stock   "min-stock"       " "  "cycle-cli-qnty"     }
{ cmp/cr-prep.i 1 ordlineattr-gds-way     "gds-way"         " "  "cycle-cli-qnty"     }


{ cmp/cr-prep.i 1 wth-qnty-sum       "=sum"         "=Сумма" "=sum"  "=Sum" }
{ cmp/cr-prep.i 1 wth-qnty-sdoc      "=1"           "=1"     "=1"    "=1" }
{ cmp/cr-prep.i 1 wth-qnty-val-qnty  "=val-qnty"    "По номиналу и кол-ву"     "=val-qnty"    "By Nominal and Qnty" }



&glob wth-qnty-methods '~
{&bef-wth-qnty-sum}~
,{&bef-wth-qnty-sdoc}~
,{&bef-wth-qnty-val-qnty}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define wth-qnty-methods {&wth-qnty-methods}" ).


&glob wth-qnty-methods-full '~
{&bef-wth-qnty-sum-full}~
,{&bef-wth-qnty-sdoc-full}~
,{&bef-wth-qnty-val-qnty-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define wth-qnty-methods-full {&wth-qnty-methods-full}" ).



&glob wth-qnty-method-name entry (lookup (~~~~~~~{&wth-qnty-method-code}, {&wth-qnty-methods}) + 1, ',' + {&wth-qnty-methods-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define wth-qnty-method-name {&wth-qnty-method-name}" ).


/* Атрибуты спецификации */
{ cmp/cr-prep.i 1 contract-specif-bonus    "bonus"  " "  "bonus"     }
{ cmp/cr-prep.i 1 contract-specif-prc-min    "prc-min"  " "  "prc-min"     }

/* Статусы ДНЦ (ТПЛ) */
{ cmp/cr-prep.i 1 pdf-new                  0         0     0        0 }
{ cmp/cr-prep.i 1 pdf-delete               1         1     1        1 }
{ cmp/cr-prep.i 1 pdf-fact                 3         3     3        3 }
{ cmp/cr-prep.i 1 pdf-ready                4         4     4        4 }

{ cmp/cr-prep.i 1 period-type                  period-type  Период    period-type      Period }
{ cmp/cr-prep.i 1 period-type-day              day       День    day      Day }
{ cmp/cr-prep.i 1 period-type-week             week      Неделя  week     Week }
{ cmp/cr-prep.i 1 period-type-month            month     Месяц   monthg   Month }
{ cmp/cr-prep.i 1 period-type-year             year      Год     year     Year }

/* Относительные периоды */
{ cmp/cr-prep.i 1 period-type-hour            hour           "Час (текущий)"       hour             "Hour"  }
{ cmp/cr-prep.i 1 period-type-hour-last       hour-last      "Час (прошлый)"       hour-last        "Last Hour"  }
{ cmp/cr-prep.i 1 period-type-shift           shift          "Смена"               shift            "Shift"  }
{ cmp/cr-prep.i 1 period-type-shift-last      shift-last     "Смена (прошлая)"     shift-last       "Last Shift "  }
{ cmp/cr-prep.i 1 period-type-yesterday       yesterday      "Вчера"               yesterday        "Yesterday"  }
{ cmp/cr-prep.i 1 period-type-week-last       week-last      "Неделя (прошлая)"    week-last        "Last Week"  }
{ cmp/cr-prep.i 1 period-type-month-last      month-last     "Месяц (прошлый)"     month-last       "Last Month" }
{ cmp/cr-prep.i 1 period-type-year-last       year-last      "Год (прошлый)"       year-last        "Last Year"  }
{ cmp/cr-prep.i 1 period-type-halfyear        halfyear       "Полугодие"           halfyear         "Halfyear"          }
{ cmp/cr-prep.i 1 period-type-halfyear-last   halfyear-last  "Полугодие (прошлое)" halfyear-last    "Last Halfyear"     }
{ cmp/cr-prep.i 1 period-type-quarter         quarter        "Квартал"             quarter          "Quarter"           }
{ cmp/cr-prep.i 1 period-type-quarter-last    quarter-last   "Квартал (прошлый)"   quarter-last     "Last Quarter"      }


&glob period-types '~
{&bef-period-type-day}~
,{&bef-period-type-week}~
,{&bef-period-type-month}~
,{&bef-period-type-year}~
,{&bef-period-type-hour}~
,{&bef-period-type-hour-last}~
,{&bef-period-type-shift}~
,{&bef-period-type-shift-last}~
,{&bef-period-type-yesterday}~
,{&bef-period-type-week-last}~
,{&bef-period-type-month-last}~
,{&bef-period-type-year-last}~
,{&bef-period-type-halfyear}~
,{&bef-period-type-halfyear-last}~
,{&bef-period-type-quarter}~
,{&bef-period-type-quarter-last}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define period-types {&period-types}" ).


&glob period-types-full '~
{&bef-period-type-day-full}~
,{&bef-period-type-week-full}~
,{&bef-period-type-month-full}~
,{&bef-period-type-year-full}~
,{&bef-period-type-hour-full}~
,{&bef-period-type-hour-last-full}~
,{&bef-period-type-shift-full}~
,{&bef-period-type-shift-last-full}~
,{&bef-period-type-yesterday-full}~
,{&bef-period-type-week-last-full}~
,{&bef-period-type-month-last-full}~
,{&bef-period-type-year-last-full}~
,{&bef-period-type-halfyear-full}~
,{&bef-period-type-halfyear-last-full}~
,{&bef-period-type-quarter-full}~
,{&bef-period-type-quarter-last-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define period-types-full {&period-types-full}" ).

&glob period-type-name entry (lookup (~~~~~~~{&period-type-code}, {&period-types}) + 1, ',' + {&period-types-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define period-type-name {&period-type-name}" ).


&glob radio-period-list-scr '~
{&bef-period-type-year-full},{&bef-period-type-year},~
{&bef-period-type-year-last-full},{&bef-period-type-year-last},~
{&bef-period-type-halfyear-full},{&bef-period-type-halfyear},~
{&bef-period-type-halfyear-last-full},{&bef-period-type-halfyear-last},~
{&bef-period-type-quarter-full},{&bef-period-type-quarter},~
{&bef-period-type-quarter-last-full},{&bef-period-type-quarter-last},~
{&bef-period-type-month-full},{&bef-period-type-month},~
{&bef-period-type-month-last-full},{&bef-period-type-month-last},~
{&bef-period-type-week-full},{&bef-period-type-week},~
{&bef-period-type-week-last-full},{&bef-period-type-week-last},~
{&bef-period-type-day-full},{&bef-period-type-day},~
{&bef-period-type-yesterday-full},{&bef-period-type-yesterday},~
{&bef-period-type-hour-full},{&bef-period-type-hour},~
{&bef-period-type-hour-last-full},{&bef-period-type-hour-last},~
{&bef-period-type-shift-full},{&bef-period-type-shift},~
{&bef-period-type-shift-last-full},{&bef-period-type-shift-last}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define radio-period-list-scr {&radio-period-list-scr}" ).



{ cmp/cr-prep.i 1 global-int               0         Глоб                  0        Glob }
{ cmp/cr-prep.i 1 global-host-int          1         Глоб/фирма            1        Glob/Cmp }
{ cmp/cr-prep.i 1 object-int               2         Объект                2        Object }
{ cmp/cr-prep.i 1 global-host-object-int   4         Глоб/фирма/объект     4        Glob/Cmp/Obj }


{ cmp/cr-prep.i 1 output-type                  output-type ТипВывода   output-type     OutputType }
{ cmp/cr-prep.i 1 output-type-plain-text       text      Текст   text     Text }
{ cmp/cr-prep.i 1 output-type-excel            excel     Excel   excel    Excel }
{ cmp/cr-prep.i 1 output-type-xml              xml       XML     xml      XML  }
{ cmp/cr-prep.i 1 output-type-screen           screen    Экран   screen   Screen }
{ cmp/cr-prep.i 1 output-type-pdf              pdf       PDF     pdf      PDF   }

&glob output-types '~
{&bef-output-type-plain-text}~
,{&bef-output-type-excel}~
,{&bef-output-type-screen}~
,{&bef-output-type-pdf}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define output-types {&output-types}" ).

&glob output-types-full '~
{&bef-output-type-plain-text-full}~
,{&bef-output-type-excel-full}~
,{&bef-output-type-screen-full}~
,{&bef-output-type-pdf-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define output-types-full {&output-types-full}" ).

&glob output-type-name entry (lookup (~~~~~~~{&output-type-code}, {&output-types}) + 1, ',' + {&output-types-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define output-type-name {&output-type-name}" ).

{ cmp/cr-prep.i 1 repcalc-type-operator         0  Оператор   0      Operator }
{ cmp/cr-prep.i 1 repcalc-type-schedule         1  Расписание 1      Schedule }
{ cmp/cr-prep.i 1 repcalc-type-event            2  Событие    2      Event  }

&glob repcalc-types '~
{&bef-repcalc-type-operator}~
,{&bef-repcalc-type-schedule}~
,{&bef-repcalc-type-event}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define repcalc-types {&repcalc-types}" ).

&glob repcalc-types-full '~
{&bef-repcalc-type-operator-full}~
,{&bef-repcalc-type-schedule-full}~
,{&bef-repcalc-type-event-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define repcalc-types-full {&repcalc-types-full}" ).

&glob repcalc-type-name entry (lookup (~~~~~~~{&repcalc-type-code}, {&repcalc-types}) + 1, ',' + {&repcalc-types-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define repcalc-type-name {&repcalc-type-name}" ).


{ cmp/cr-prep.i 1 save-db-and-run          save-db-and-run         Сохр_в_БД-Выполн_себя      save-db-and-run        save-db-and-run }
{ cmp/cr-prep.i 1 save-install             save-install            Сохр_пакет_обновл          save-install           save-install }
{ cmp/cr-prep.i 1 save-db                  save-db                 Сохр_в_БД                  save-db                save-db }
{ cmp/cr-prep.i 1 save-disk                save-disk               Сохр_на_диск               save-disk              save-disk }
{ cmp/cr-prep.i 1 save-this-db             save-this-db            Сохр_в_тек.БД              save-this-db           save-this-db }
{ cmp/cr-prep.i 1 save-disk-and-run        save-disk-and-run       Сохр_на_диск_Выполн_себя   save-disk-and-run      save-disk-and-run }

&glob bin-send-types '~
{&bef-save-db-and-run}~
,{&bef-save-install}~
,{&bef-save-db}~
,{&bef-save-disk}~
,{&bef-save-this-db}~
,{&bef-save-disk-and-run}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define bin-send-types {&bin-send-types}" ).

&glob bin-send-types-full '~
{&bef-save-db-and-run-full}~
,{&bef-save-install-full}~
,{&bef-save-db-full}~
,{&bef-save-disk-full}~
,{&bef-save-this-db-full}~
,{&bef-save-disk-and-run-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define bin-send-types-full {&bin-send-types-full}" ).

&glob bin-send-type-name entry (lookup (~~~~~~~{&bin-send-type-code}, {&bin-send-types}) + 1, ',' + {&bin-send-types-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define bun-send-type-name {&bin-send-type-name}" ).


{ cmp/cr-prep.i 1 severity-no-error        0         Нет ошибки     1        no-error }
{ cmp/cr-prep.i 1 Severity-low             1         Некритично     1        Low }
{ cmp/cr-prep.i 1 Severity-medium          2         Слабокритично  2        Medium }
{ cmp/cr-prep.i 1 Severity-high            3         Критично       3        High }
{ cmp/cr-prep.i 1 Severity-extreme         4         Сверхритично   4        Extreme }
{ cmp/cr-prep.i 1 Severity-unknown         ?         Неизвестно     ?        Unknown }

&glob severity-types '~
{&bef-severity-no-error}~
,{&bef-severity-low}~
,{&bef-severity-medium}~
,{&bef-severity-high}~
,{&bef-severity-extreme}~
,{&bef-severity-unknown}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define severity-types {&severity-types}" ).

&glob severity-types-full '~
{&bef-severity-no-error-full}~
,{&bef-severity-low-full}~
,{&bef-severity-medium-full}~
,{&bef-severity-high-full}~
,{&bef-severity-extreme-full}~
,{&bef-severity-unknown-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define severity-types-full {&severity-types-full}" ).

&glob severity-name entry (lookup (~~~~~~~{&severity-code}, {&severity-types}) + 1, ',' + {&severity-types-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define severity-name {&severity-name}" ).


&glob gen-line-create               'N'
&glob gen-line-update               'U'
&glob gen-line-delete               'D'

{ cmp/cr-prep.i 1 gen-line-create             N         Добавить     N        ADD }
{ cmp/cr-prep.i 1 gen-line-update             U         Изменить     U        UPDATE }
{ cmp/cr-prep.i 1 gen-line-delete             D         Удалить      D        DELETE }


/* События срабатывания ИЖТ */
{ cmp/cr-prep.i 1 izt-event-ie-rest          ie-rest           "Внешний приход: остатки на объекте есть"                   ie-rest          "ie rest"      }
{ cmp/cr-prep.i 1 izt-event-ie-norest        ie-norest         "Внешний приход: остатков нет"                              ie-norest        "ie not rest"  }
{ cmp/cr-prep.i 1 izt-event-iv-rest          iv-rest           "Внутрений приход: остатки на объекте есть"                 iv-rest          "iv rest"  }
{ cmp/cr-prep.i 1 izt-event-iv-norest        iv-norest         "Внутренний приход: остатков нет"                           iv-norest        "iv not rest"  }
{ cmp/cr-prep.i 1 izt-event-mf-ie-rest       mf_ie-rest        "Межфирменный приход: остатки на объекте есть"              mf_ie-rest       "hold ie rest" }
{ cmp/cr-prep.i 1 izt-event-mf-ie-norest     mf_ie-norest      "Межфирменный приход: остатков нет"                         mf_ie-norest     "hold ie not rest"  }
{ cmp/cr-prep.i 1 izt-event-ee-rest          ee-rest           "Внешний расход: остатки  есть"                             ee-rest          "ee rest"  }
{ cmp/cr-prep.i 1 izt-event-ee-norest        ee-norest         "Внешний расход: остатков нет"                              ee-norest        "ee not rest"  }
{ cmp/cr-prep.i 1 izt-event-ev-rest          ev-rest           "Внутрений расход: остатки на объекте есть"                 ev-rest          "ev rest"  }
{ cmp/cr-prep.i 1 izt-event-ev-norest        ev-norest         "Внутренний расход: остатков нет"                           ev-norest        "ev not rest"  }
{ cmp/cr-prep.i 1 izt-event-cli-ev-rest      cli_ev-rest       "Внутрений расход: остатки на объекте приемнике есть"       cli_ev-rest      "ev rest recipient"  }
{ cmp/cr-prep.i 1 izt-event-cli-ev-norest    cli_ev-norest     "Внутренний расход: остатков на объекте приемнике нет"      cli_ev-norest    "ev not rest recipient"  }
{ cmp/cr-prep.i 1 izt-event-mf-ee-rest       mf_ee-rest        "Межфирменный расход: остатки на объекте есть"              mf_ee-rest       "hold ee rest"  }
{ cmp/cr-prep.i 1 izt-event-mf-ee-norest     mf_ee-norest      "Межфирменный расход: остатков нет"                         mf_ee-norest     "hold ee not rest"  }
{ cmp/cr-prep.i 1 izt-event-cli-mf-ee-rest   cli_mf_ee-rest    "Межфирменный расход: остатки на приемнике есть"            cli_mf_ee-rest       "hold ee rest recipient"  }
{ cmp/cr-prep.i 1 izt-event-cli-mf-ee-norest cli_mf_ee-norest  "Межфирменный расход: остатков на приемнике нет"            cli_mf_ee-norest     "hold ee not rest recipient"  }
{ cmp/cr-prep.i 1 izt-event-op-rest          ОП-rest           "Заказ ОП: остатки на объекте есть"                         OS-rest          "order OP rest"  }
{ cmp/cr-prep.i 1 izt-event-op-norest        ОП-norest         "Заказ ОП: остатков нет"                                    OS-norest        "Order OP not rest"  }
{ cmp/cr-prep.i 1 izt-event-or-rest          ОР-rest           "Заказ ОРЦ: остатки на объекте есть"                        OR-rest          "order ORC rest"     }
{ cmp/cr-prep.i 1 izt-event-or-norest        ОР-norest         "Заказ ОРЦ: остатков на объекте нет"                        OR-norest        "Order ORC not rest" }
{ cmp/cr-prep.i 1 izt-event-cli-or-rest      cli_ОР-rest       "Заказ ОРЦ: остатки на объекте приемнике есть"              cli_OR-rest      "order ORC rest recipient"     }
{ cmp/cr-prep.i 1 izt-event-cli-or-norest    cli_ОР-norest     "Заказ ОРЦ: остатков на объекте приемнике нет"              cli_OR-norest    "Order ORC not rest recipient" }
{ cmp/cr-prep.i 1 izt-event-oo-rest          ОО-rest           "Заказ ОO: остатки на объекте есть"                         OO-rest          "order OO rest"      }
{ cmp/cr-prep.i 1 izt-event-oo-norest        ОО-norest         "Заказ ОO: остатков на объекте нет"                         OO-norest        "Order OO not rest"  }
{ cmp/cr-prep.i 1 izt-event-cli-oo-rest      cli_ОО-rest       "Заказ ОO: остатки на объекте приемнике есть"               cli_OO-rest      "order OO rest recipient"  }
{ cmp/cr-prep.i 1 izt-event-cli-oo-norest    cli_ОО-norest     "Заказ ОO: остатков на объекте приемнике нет"               cli_OO-norest    "Order OO not rest recipient"  }
{ cmp/cr-prep.i 1 izt-event-of-rest          ОФ-rest           "Заказ ОФ: остатки на объекте есть"                         OF-rest          "order OF rest"  }
{ cmp/cr-prep.i 1 izt-event-of-norest        ОФ-norest         "Заказ ОФ: остатков нет"                                    OF-norest        "Order OF not rest"  }
{ cmp/cr-prep.i 1 izt-event-po-rest          ПО-rest           "Заказ Покупателя: остатки на объекте есть"                 BO-rest          "order PO rest"      }
{ cmp/cr-prep.i 1 izt-event-po-norest        ПО-norest         "Заказ Покупателя: остатков нет"                            BO-norest        "Order PO not rest"  }
{ cmp/cr-prep.i 1 izt-event-rcv-rest         rcv-rest          "Поставка (закрытие): остатки на объекте есть"              rcv-rest          "delivery rest"      }
{ cmp/cr-prep.i 1 izt-event-rcv-norest       rcv-norest        "Поставка (закрытие): остатков нет"                         rcv-norest        "delivery not rest"  }
{ cmp/cr-prep.i 1 izt-event-cli-rcv-rest     cli_rcv-rest      "Поставка (закрытие): остатки на объекте приемнике есть"    cli_rcv-rest      "delivery rest recipient"     }
{ cmp/cr-prep.i 1 izt-event-cli-rcv-norest   cli_rcv-norest    "Поставка (закрытие): остатков на объекте приемнике нет"    cli_rcv-norest    "delivery not rest recipient" }
{ cmp/cr-prep.i 1 izt-event-scu-grp-matr     scu-grp-matr      "Подсчет SCU по группам в Ассортиментной матрице"           scu-grp-matr      "calculete SCU from AssMatr"  }
{ cmp/cr-prep.i 1 izt-event-scu-grp-specif   scu-grp-specif    "Подсчет SCU по группам в Спецификации"                     scu-grp-specif    "calculete SCU from specif"  }
{ cmp/cr-prep.i 1 izt-event-delete-matr-rest    delete-matr-rest   "Удаление товара из матрицы: остатки на объекте есть"   delete-matr-rest   "delete from matrix"  }
{ cmp/cr-prep.i 1 izt-event-delete-matr-norest  delete-matr-norest "Удаление товара из матрицы: остатков на объекте нет"   delete-matr-norest "delete from matrix not rest"  }
{ cmp/cr-prep.i 1 izt-event-fp-rest          ФП-rest           "Заказ ФП: остатки на объекте есть"                         FS-rest          "order FS rest"  }
{ cmp/cr-prep.i 1 izt-event-fp-norest        ФП-norest         "Заказ ФП: остатков нет"                                    FS-norest        "Order FS not rest"  }


&glob izt-event-types '~
{&bef-izt-event-ie-rest}~
,{&bef-izt-event-ie-norest}~
,{&bef-izt-event-iv-rest}~
,{&bef-izt-event-iv-norest}~
,{&bef-izt-event-mf-ie-rest}~
,{&bef-izt-event-mf-ie-norest}~
,{&bef-izt-event-ee-rest}~
,{&bef-izt-event-ee-norest}~
,{&bef-izt-event-ev-rest}~
,{&bef-izt-event-ev-norest}~
,{&bef-izt-event-cli-ev-rest}~
,{&bef-izt-event-cli-ev-norest}~
,{&bef-izt-event-mf-ee-rest}~
,{&bef-izt-event-mf-ee-norest}~
,{&bef-izt-event-cli-mf-ee-rest}~
,{&bef-izt-event-cli-mf-ee-norest}~
,{&bef-izt-event-op-rest}~
,{&bef-izt-event-op-norest}~
,{&bef-izt-event-or-rest}~
,{&bef-izt-event-or-norest}~
,{&bef-izt-event-cli-or-rest}~
,{&bef-izt-event-cli-or-norest}~
,{&bef-izt-event-oo-rest}~
,{&bef-izt-event-oo-norest}~
,{&bef-izt-event-cli-oo-rest}~
,{&bef-izt-event-cli-oo-norest}~
,{&bef-izt-event-of-rest}~
,{&bef-izt-event-of-norest}~
,{&bef-izt-event-po-rest}~
,{&bef-izt-event-po-norest}~
,{&bef-izt-event-rcv-rest}~
,{&bef-izt-event-rcv-norest}~
,{&bef-izt-event-cli-rcv-rest}~
,{&bef-izt-event-cli-rcv-norest}~
,{&bef-izt-event-scu-grp-matr}~
,{&bef-izt-event-scu-grp-specif}~
,{&bef-izt-event-delete-matr-rest}~
,{&bef-izt-event-delete-matr-norest}~
,{&bef-izt-event-fp-rest}~
,{&bef-izt-event-fp-norest}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define izt-event-types {&izt-event-types}" ).

&glob izt-event-types-full '~
{&bef-izt-event-ie-rest-full}~
,{&bef-izt-event-ie-norest-full}~
,{&bef-izt-event-iv-rest-full}~
,{&bef-izt-event-iv-norest-full}~
,{&bef-izt-event-mf-ie-rest-full}~
,{&bef-izt-event-mf-ie-norest-full}~
,{&bef-izt-event-ee-rest-full}~
,{&bef-izt-event-ee-norest-full}~
,{&bef-izt-event-ev-rest-full}~
,{&bef-izt-event-ev-norest-full}~
,{&bef-izt-event-cli-ev-rest-full}~
,{&bef-izt-event-cli-ev-norest-full}~
,{&bef-izt-event-mf-ee-rest-full}~
,{&bef-izt-event-mf-ee-norest-full}~
,{&bef-izt-event-cli-mf-ee-rest-full}~
,{&bef-izt-event-cli-mf-ee-norest-full}~
,{&bef-izt-event-op-rest-full}~
,{&bef-izt-event-op-norest-full}~
,{&bef-izt-event-or-rest-full}~
,{&bef-izt-event-or-norest-full}~
,{&bef-izt-event-cli-or-rest-full}~
,{&bef-izt-event-cli-or-norest-full}~
,{&bef-izt-event-oo-rest-full}~
,{&bef-izt-event-oo-norest-full}~
,{&bef-izt-event-cli-oo-rest-full}~
,{&bef-izt-event-cli-oo-norest-full}~
,{&bef-izt-event-of-rest-full}~
,{&bef-izt-event-of-norest-full}~
,{&bef-izt-event-po-rest-full}~
,{&bef-izt-event-po-norest-full}~
,{&bef-izt-event-rcv-rest-full}~
,{&bef-izt-event-rcv-norest-full}~
,{&bef-izt-event-cli-rcv-rest-full}~
,{&bef-izt-event-cli-rcv-norest-full}~
,{&bef-izt-event-scu-grp-matr-full}~
,{&bef-izt-event-scu-grp-specif-full}~
,{&bef-izt-event-delete-matr-rest-full}~
,{&bef-izt-event-delete-matr-norest-full}~
,{&bef-izt-event-fp-rest-full}~
,{&bef-izt-event-fp-norest-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define izt-event-types-full {&izt-event-types-full}" ).

/* Правило ИЖТ по умолчанию */
/*event-code,izd-new,izd-com,izd-del,izd-spec,izd-empty*/
&glob izt-rul-def '~
{&bef-izt-event-ie-rest},true,true,false,true,true;~
{&bef-izt-event-ie-norest},true,true,false,true,true;~
{&bef-izt-event-iv-rest},true,true,false,true,true;~
{&bef-izt-event-iv-norest},true,true,false,true,true;~
{&bef-izt-event-mf-ie-rest},true,true,true,true,true;~
{&bef-izt-event-mf-ie-norest},true,true,false,true,true;~
{&bef-izt-event-ee-rest},true,true,true,true,true;~
{&bef-izt-event-ee-norest},true,true,false,true,true;~
{&bef-izt-event-ev-rest},true,true,true,true,true;~
{&bef-izt-event-ev-norest},true,true,false,true,true;~
{&bef-izt-event-cli-ev-rest},true,true,true,true,true;~
{&bef-izt-event-cli-ev-norest},true,true,false,true,true;~
{&bef-izt-event-mf-ee-rest},true,true,true,true,true;~
{&bef-izt-event-mf-ee-norest},true,true,false,true,true;~
{&bef-izt-event-cli-mf-ee-rest},true,true,false,true,true;~
{&bef-izt-event-cli-mf-ee-norest},true,true,false,true,true;~
{&bef-izt-event-op-rest},true,true,false,true,true;~
{&bef-izt-event-op-norest},true,true,false,true,true;~
{&bef-izt-event-or-rest},true,true,false,true,true;~
{&bef-izt-event-or-norest},true,true,false,true,true;~
{&bef-izt-event-cli-or-rest},true,true,false,true,true;~
{&bef-izt-event-cli-or-norest},true,true,false,true,true;~
{&bef-izt-event-oo-rest},true,true,false,true,true;~
{&bef-izt-event-oo-norest},true,true,false,true,true;~
{&bef-izt-event-cli-oo-rest},true,true,false,true,true;~
{&bef-izt-event-cli-oo-norest},true,true,false,true,true;~
{&bef-izt-event-of-rest},true,true,false,true,true;~
{&bef-izt-event-of-norest},true,true,false,true,true;~
{&bef-izt-event-po-rest},true,true,false,true,true;~
{&bef-izt-event-po-norest},true,true,false,true,true;~
{&bef-izt-event-rcv-rest},true,true,true,true,true;~
{&bef-izt-event-rcv-norest},true,true,false,true,true;~
{&bef-izt-event-cli-rcv-rest},true,true,false,true,true;~
{&bef-izt-event-cli-rcv-norest},true,true,false,true,true;~
{&bef-izt-event-scu-grp-matr},true,true,false,true,true;~
{&bef-izt-event-scu-grp-specif},true,true,false,true,true;~
{&bef-izt-event-delete-matr-rest},false,false,false,false,true;~
{&bef-izt-event-delete-matr-norest},false,false,true,false,true;~
{&bef-izt-event-fp-rest},true,true,false,true,true;~
{&bef-izt-event-fp-norest},true,true,false,true,true~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define izt-rul-def {&izt-rul-def}" ).

{ cmp/cr-prep.i 1 rp-parentf-ordinal         0      "_"                                  0        "_" }
{ cmp/cr-prep.i 1 rp-parentf-only-in-combo   1      "Только в составе комб.профайла"     1        "Only in combo algo" }


&glob rp-parentf-list '~
{&bef-rp-parentf-ordinal}~
,{&bef-rp-parentf-only-in-combo}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define rp-parentf-list {&rp-parentf-list}" ).

&glob FiB yes
{ cmp/cr-prep.i 1 FiB yes  "Фальсиф/брак партии" yes "defect"  }

&glob price-parts 1
{ cmp/cr-prep.i 1 price-parts 1  "Продажная цена по партиям" 1 "price sale from parts"  }


{ cmp/cr-prep.i 1 exite-edi-without-ordrsp      without-ordrsp     "Без ORDRSP"           without-ordrsp       "Without ORDRSP" }
{ cmp/cr-prep.i 1 exite-edi-with-ordrsp         with-ordrsp        "С ORDRSP"             with-ordrsp          "With ORDRSP" }
{ cmp/cr-prep.i 1 exite-edi-only-nakl           only-nakl          "Только накладные"     only-nakl            "only NAKL" }

/*методы доставки заказов  и пр*/
{ cmp/cr-prep.i 1 doc-dm-empty        0     "_"           0       "_" }
{ cmp/cr-prep.i 1 doc-dm-edoc-nn      1     "EDOC-NN"     1       "EDOC-NN" }
{ cmp/cr-prep.i 1 doc-dm-edi          2     "EDI"         2       "EDI" }

&glob doc-dm-list '~
{&bef-doc-dm-empty}~
,{&bef-doc-dm-edoc-nn}~
,{&bef-doc-dm-edi}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define doc-dm-list {&doc-dm-list}" ).

&glob doc-dm-list-full '~
{&bef-doc-dm-empty-full}~
,{&bef-doc-dm-edoc-nn-full}~
,{&bef-doc-dm-edi-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define doc-dm-list-full {&doc-dm-list-full}" ).


&glob doc-dm-name entry (lookup (~~~~~~~{&doc-dm-code}, {&doc-dm-list}) + 1, 'ERROR,' + {&doc-dm-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define doc-dm-name {&doc-dm-name}" ).


/*Статусы сравнения заказаного и пришедшего количества*/
{ cmp/cr-prep.i 1 edi-line-ordrsp-ok        1     "Совпадение"   1    "Ok"         }
{ cmp/cr-prep.i 1 edi-line-ordrsp-diff      2     "Разница"      2    "Difference" }
{ cmp/cr-prep.i 1 edi-line-ordrsp-cancel    3     "Отмена"       3    "Cancel"     }

&glob edi-line-ordrsp-list '~
{&bef-edi-line-ordrsp-ok}~
,{&bef-edi-line-ordrsp-diff}~
,{&bef-edi-line-ordrsp-cancel}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define edi-line-ordrsp-list {&edi-line-ordrsp-list}" ).

&glob edi-line-ordrsp-list-full '~
{&bef-edi-line-ordrsp-ok-full}~
,{&bef-edi-line-ordrsp-diff-full}~
,{&bef-edi-line-ordrsp-cancel-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define edi-line-ordrsp-list-full {&edi-line-ordrsp-list-full}" ).

&glob edi-line-ordrsp-name entry (lookup (~~~~~~~{&edi-line-ordrsp-code}, {&edi-line-ordrsp-list}) + 1, ',' + {&edi-line-ordrsp-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define edi-line-ordrsp-name {&edi-line-ordrsp-name}" ).

/* Атрибуты сезона */
{ cmp/cr-prep.i 1 seaattr-obj               sea-obj             "Объект сезона"           sea-obj             "Object of season"     }
{ cmp/cr-prep.i 1 gdsseaattr-season-coef    gdssea-season-coef  "Коэф. увеличения спроса" gdssea-season-coef  "Coeff. of season"     }
{ cmp/cr-prep.i 1 sea-global                sea-global          "глобальный"              sea-global          "global"               }
{ cmp/cr-prep.i 1 sea-local                 sea-local           "локальный"               sea-local            "local"               }


run filwrlib_num-lines-get in this-procedure
  (output p-num-lines
  ) .

{ cmp/cr-prep.i 1 alc-check-price 28  "содержание спирта" 28 "contents alcohol"  }

/* Типы сообщения EGAIS */
{ cmp/cr-prep.i 1 EGAIS-DictOrg    1     "Справочник организаций"    1    "Dictionary organization"   }
{ cmp/cr-prep.i 1 EGAIS-DictGds    2     "Справочник товаров"        2    "Dictionary goods"   }
{ cmp/cr-prep.i 1 EGAIS-InfoVer    3     "Уведомление сервера ЕГАИС о смене версии xsd-схем " 3    "Info Version XSD"   }
{ cmp/cr-prep.i 1 EGAIS-FormF1     4     "Справочник справок 1"       4    "FormF1"   }

/* Статусы EGAIS */
{ cmp/cr-prep.i 1 egais-act-send        0    "Акт отправлен"                  0  "Act send"            }
{ cmp/cr-prep.i 1 egais-wb-send         1    "Накладная отправлена"           1  "WB send"             }