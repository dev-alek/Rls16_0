/*

$Revision: 6298093c26d2, 2419, rls $
$Author: druban $
$Date: Ср июн 10 21:13:46 2020 +0300 $
$Workfile: all-docs.w $
$Archive: str/all-docs.w $

Список документов

Автор: Чернова Светлана Александровна
Дата создания: 10/09/06
Author: Svetlana Chernova
Creation date: 10/09/06

create Суслов Алексей Юрьевич

*/

define input  parameter parparentproc   as   handle               no-undo.
define input  parameter par-host-code   as   integer     no-undo .
define input  parameter par-obj-type    as   character no-undo .
define input  parameter par-obj-code    as   integer   no-undo .
define input  parameter parlist-mode    as   character            no-undo.
define input  parameter parstat         as   character            no-undo.
define input  parameter partype         as   character            no-undo.
define input  parameter parflag         as   logical              no-undo.
define input  parameter parinternal     as   logical              no-undo.
define input  parameter bttns           as   character            no-undo.
define input  parameter parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define input  parameter paris-hold      as   logical              no-undo.
define input  parameter pardoc-rec      as   recid                no-undo.
define output parameter mark-list       as   character            no-undo.

define variable vss-revision    as character no-undo initial "$Revision: 6298093c26d2, 2419, rls $":U .
define variable vss-author      as character no-undo initial "$Author: druban $":U .
define variable vss-date        as character no-undo initial "$Date: Ср июн 10 21:13:46 2020 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: all-docs.w $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/all-docs.w $":U .
define variable vss-description as character no-undo initial "Список документов":U .

{ cmp/vssrevis.i "substitute('&1|&2',bttns,parext-doc-type)"  }
{ cmp/showinf.i    }
{ str/get-pr.i def }
{ cmp/str-glbl.i   }
{ gbl/key-rec.i    }
{ gbl/fltfield.i   }
{ str/tt-tax.i new }
{ cmp/library.i    }
{ str/lib-trn.i    }
{ trg/partslib.i }
{ str/libbcrcn.i }
{ str/doc-code.i }
{ str/lib-farh.i   }
{ gbl/waitfram.i   noprocess }
{ cmp/gds-list.i gds-list def "new shared"}
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i def }
{ str/getctxtp.i get }
{ str/trdcalib.i     }
{ gbl/usr-flt.i      }
{ gbl/fltopend.i defproc }
{ cmp/strcodec.i }
{str\utdreturn.i}
{ str/invMulti.i }
{ ref/gds-attr.i }
{ gbl/color.i }

define variable v-sale             as   logical               no-undo.
define variable bcol                                as   handle                        extent no-undo.
define variable hBrowse                             as   handle                        no-undo.
define variable ii                                  as   integer                       no-undo.
  define buffer bf_trn-doc        for ub.trn-doc .
  define buffer buf_doc-line      for ub.doc-line .

{ str/all-docs.i }
{ str/all-docc.i }
{ str/all-doc1.i }
{ str/all-doca.i {&bef-trdcattr-dov           } }
{ str/all-doca.i {&bef-trdcattr-dids          } }
{ str/all-doca.i {&bef-trdcattr-nids          } }
{ str/all-doca.i {&bef-trdcattr-ddog          } }
{ str/all-doca.i {&bef-trdcattr-ndog          } }
{ str/all-doca.i {&bef-trdcattr-dsf           } }
{ str/all-doca.i {&bef-trdcattr-nsf           } }
{ str/all-doca.i {&bef-trdcattr-addsum        } }
{ str/all-doca.i {&bef-trdcattr-clcasol       } }
{ str/all-doca.i {&bef-trdcattr-clcaswt       } }
{ str/all-doca.i {&bef-trdcattr-scanfile      } }
{ str/all-doca.i {&bef-trdcattr-indoclnsum    } }
{ str/all-doca.i {&bef-trdcattr-purchlimit    } }
{ str/all-doca.i {&bef-trdcattr-purchcodelist } }
{ str/all-doca.i {&bef-trdcattr-expense_own   } }
{ str/all-doca.i {&bef-trdcattr-hold-part-code } }
{ str/all-doca.i {&bef-trdcattr-envd           } }
{ str/all-doca.i {&bef-trdcattr-ord_time       } }
{ str/all-doca.i {&bef-trdcattr-dchek          } }
{ str/all-doca.i {&bef-trdcattr-befpay         } }
{ str/all-doca.i {&bef-trdcattr-ord_nchek      } }
{ str/all-doca.i {&bef-trdcattr-deliv          } }
{ str/all-doca.i {&bef-trdcattr-sumwrk         } }
{ str/all-doca.i {&bef-trdcattr-sumsrk         } }
{ str/all-doca.i {&bef-trdcattr-ord_adr        } }
{ str/all-doca.i {&bef-trdcattr-ord_hwo        } }
{ str/all-doca.i {&bef-trdcattr-fbroperator    } }
{ str/all-doca.i {&bef-trdcattr-fbrauto        } }
{ str/all-doca.i {&bef-trdcattr-rsrv-doc-list  } }
{ str/all-doca.i {&bef-trdcattr-postdchek      } }
{ str/all-doca.i {&bef-trdcattr-postpay        } }
{ str/all-doca.i {&bef-trdcattr-postNchek      } }
{ str/all-doca.i {&bef-trdcattr-frsrv-date     } }
{ str/all-doca.i {&bef-trdcattr-ord_phone      } }
{ str/all-doca.i {&bef-trdcattr-ord_dl         } }
{ str/all-doca.i {&bef-trdcattr-ord_contact    } }
{ str/all-doca.i {&bef-trdcattr-m-inc          } }
{ str/all-doca.i {&bef-trdcattr-qntyplace      } }
{ str/all-doca.i {&bef-trdcattr-discnt-stop    } }
{ str/all-doca.i {&bef-trdcattr-discnt-other   } }
{ str/all-doca.i {&bef-trdcattr-dfindoc        } }
{ str/all-doca.i {&bef-trdcattr-nfindoc        } }
{ str/all-doca.i {&bef-trdcattr-place-storage  } }
{ str/all-doca.i {&bef-trdcattr-packer         } }
{ str/all-doca.i {&bef-trdcattr-dispath        } }
{ str/all-doca.i {&bef-trdcattr-price-target   } }
{ str/all-doca.i {&bef-trdcattr-edi            } }
{ str/all-doca.i {&bef-trdcattr-ddov           } }
{ str/all-doca.i {&bef-trdcattr-ndov           } }
{ str/all-doca.i {&bef-trdcattr-recipient      } }
{ str/all-doca.i {&bef-trdcattr-shipper        } }
{ str/all-doca.i {&bef-trdcattr-auto           } }
{ str/all-doca.i {&bef-trdcattr-driver         } }
{ str/all-doca.i {&bef-trdcattr-print-num      } }
{ str/all-doca.i {&bef-trdcattr-idCountryContr } }
{ str/all-doca.i {&bef-trdcattr-oldsuppcntr    } }
{ str/all-doca.i {&bef-trdcattr-nosn           } }
{ str/all-doca.i {&bef-trdcattr-acc-ship       } }
{ str/all-doca.i {&bef-trdcattr-delivery-date  } }
{ str/is-mes.i }

define variable v-is-lgas as logical no-undo.
define variable p-par as character no-undo .
define new shared buffer t-doc for ub.trn-doc.

{ cmp/doc-list.i  doc-list def "new shared" }

define new shared buffer temp-trn-doc for doc-list  .
define temp-table tt-line like ub.doc-line .
define variable r-2 as integer   no-undo init 1 .

define temp-table tt-gds-list no-undo like ub.goods
field nn as integer
field doc-qnty as decimal
field fact-qnty as decimal
field itog-qnty as decimal
index by-nn nn
index by_gds-code gds-code
.

define temp-table tt-gds-list2 no-undo like ub.goods
field nn as integer
field doc-qnty as decimal
field fact-qnty as decimal
field itog-qnty as decimal
index by-nn nn
index by_gds-code gds-code
.

create doc-list.
doc-list.doc-code = "" .
release doc-list .


/*  {&cntxt-global} {&cntxt-firm} {&cntxt-object} */
if v-cntxt-level = {&cntxt-object}    then do:
if (par-host-code <> 0 and par-host-code <> ? and
    par-obj-type = "" or par-obj-type = ? ) then do:
   /*Контрагент
   "ОПЛАТА" {&company} {&confuse} */
end.

if (par-host-code = 0 or par-host-code = ? and
    par-obj-type = "" or par-obj-type = ? ) then
    assign
      par-host-code = v-cntxt-host-code-obj
      par-obj-type = v-cntxt-obj-type
      par-obj-code = v-cntxt-obj-code
    .
if ( par-obj-type <> "" and par-obj-type <> ? ) then  do:
    define variable ver-host-code as integer   no-undo .
    { gbl/hostcode.i
      par-obj-type
      par-obj-code
      ver-host-code
       }
      if ver-host-code  <> par-host-code then
      assign
        par-host-code = ver-host-code
      .
    end.
end.
if v-cntxt-level = {&cntxt-firm}    then do:
if (par-host-code = 0 or par-host-code = ? and
    par-obj-type = "" or par-obj-type = ? ) then
    assign
      par-host-code = v-cntxt-host-code-obj
    .
end.


define variable v-cntxt-passwd as character no-undo.
run get-user-password in ParParentProc ( output v-cntxt-passwd ).

&Scop if-not-true ~
if varlog <> yes then do: ~
  find t-doc no-lock where recid( t-doc ) = pardoc-rec. ~
  return no-apply. ~
end.

&Scop net-proc ~
find current t-doc no-lock no-error. ~
if not available t-doc then do: ~
   return no-apply. ~
end. ~
assign pardoc-rec = recid (t-doc). ~
do on stop undo, return no-apply : ~
  find t-doc where recid (t-doc) = pardoc-rec exclusive.  /* сетевая проверка */ ~
end. ~
if t-doc.status_      = {&fact}                     or       ~
   t-doc.status_      = {&ready}                    or       ~
   t-doc.status_      = {&rejected}                 or       ~
   t-doc.status_      = {&doc-froze}                or       ~
   t-doc.status_      = {&manufactured}             or       ~
   t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}     or       ~
   t-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} then do: ~
   find t-doc where recid (t-doc) = pardoc-rec no-lock. ~
   message "Данный документ закрыт по факту или не может быть обработан в этом списке." view-as alert-box. ~
   return no-apply. ~
end.
&Scop net-del ~
if not available t-doc then do: ~
  return no-apply. ~
end. ~
assign pardoc-rec = recid (t-doc). ~
do on stop undo, return no-apply : ~
  find t-doc where recid (t-doc) = pardoc-rec exclusive.  /* сетевая проверка */ ~
end. ~
if t-doc.status_      = {&doc-froze}                or       ~
   t-doc.status_      = {&manufactured}             or       ~
   t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}     or       ~
   t-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} or       ~
   t-doc.ext-doc-type = {&TDEDT_Chg_Purch_Code}     or       ~
   t-doc.ext-doc-type = {&TDEDT_Pri_Object}         or       ~
   t-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}          and varhold-doc = yes or ~
   t-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}      and varhold-doc = yes or ~
   (t-doc.ext-doc-type = {&TDEDT_Corr_Minus_Parts}  and not (t-doc.status_ = {&inquiry} and not t-doc.flag )) or       ~
   (t-doc.ext-doc-type = {&TDEDT_Pri_Perem}         and not (t-doc.status_ = {&inquiry} and not t-doc.flag )) or       ~
   t-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem}      or       ~
   (t-doc.status_ = {&fact} and t-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price})  or       ~
   (t-doc.status_ = {&fact} and t-doc.ext-doc-type = {&TDEDT_Pri_Perem})       or       ~
   (t-doc.status_ = {&fact} and t-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem})   or       ~
   (t-doc.status_ = {&fact} and t-doc.ext-doc-type = {&TDEDT_Ras_Prvo})        or       ~
   (t-doc.status_ = {&fact} and t-doc.ext-doc-type = {&TDEDT_Spi_Prvo})        or       ~
   (t-doc.status_ = {&fact} and t-doc.ext-doc-type = {&TDEDT_Pri_Prvo})                 ~
   then do: ~
   find t-doc where recid (t-doc) = pardoc-rec no-lock. ~
   message "Данный документ не может быть удален." view-as alert-box. ~
   return no-apply. ~
end.


&Scop WINDOW-NAME d-all-docs
&Scop FRAME-NAME     d-all-docs
&Scop BROWSE-NAME br-docs


define variable br-handle as handle no-undo.
define variable bf-handle as handle no-undo.

define variable v-doc-rec as recid no-undo .
define variable hcolumn as handle extent 100  no-undo.
/* для жесткого фильтра по оплате */
define new shared buffer sch-pay for ub.pay-type.

/* для жесткого фильтра по валюте */
define new shared buffer sch-curr for ub.currency.

/* для жесткого фильтра по контр., м-ру, исп-лю, кл-ку */
define new shared buffer sch-cli for ub.clients.

/* для списка мешающих документов по инвентаризации */
define new shared buffer sch-inv for ub.trn-doc.

define variable  v-order-column as character no-undo .
define variable  v-spis-size   as character no-undo .
define variable  v-spis-vis    as character no-undo .

define new shared variable varext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define new shared variable varis-hold      as   logical                 no-undo.

assign
  varext-doc-type = parext-doc-type
  varis-hold      = paris-hold.

define buffer cli-buf for ub.clients.  /* для вывода м-ра, исп-ля, кл-ка */
define buffer t-d-b   for ub.trn-doc.  /* для поиска по номеру, дате, факт */

/* список recid для внешней программы (кнопка b-ext) */
define temp-table temp_recid-list no-undo
    field string-trn-doc-recid as character
    index pi is primary unique string-trn-doc-recid
.

define variable sch-field as character no-undo.
/* define variable mark-list as character no-undo. */
define variable mark     as character no-undo.
{ gbl/flt-def.i }

define variable chg-qnty      like ub.gds-dtl.doc-qnty no-undo.
define variable choice        as   logical          no-undo initial ?.
define variable objects       as   integer          no-undo.
define variable is-finvalue   as   character        no-undo.
define variable is-fintype    as   character        no-undo.
define variable is-bgevalue   as   character        no-undo.
define variable is-bgetype    as   character        no-undo.
define variable varfact-date  as   date             no-undo.
define variable varshift-date as   date             no-undo.
define variable varshift-num  as   integer          no-undo.
define variable varshift-name as character no-undo.
define buffer exp_trn-doc for ub.trn-doc.
define buffer ret-doc     for ub.trn-doc.

define variable varcheck-return    as   logical               no-undo.
define variable varpost            as   character             no-undo.
define variable varrealiz          as   character             no-undo.
define variable varbuyer           as   character             no-undo.
define variable varfactur          as   character             no-undo.
define variable v-ext-button-label as   character             no-undo.
define variable v_shift            as   character             no-undo initial ?. /* учет по сменам на объекте */
define variable v_data-type        as   character             no-undo initial ?.
define variable varhold            as   character             no-undo.
define variable varhold-type       as   character             no-undo.
define variable varpar-type        as   character             no-undo.
define variable sort-column-name   as   character             no-undo.
define variable filter-point       as   character             no-undo.
define variable filter-label       as   character             no-undo.
define variable l-query-was-opened as   logical               no-undo.
define variable sort-column-phrase as   character             no-undo.
define variable parschdoc-code     like ub.trn-doc.doc-code   no-undo.
define variable parschcurr-code    like ub.currency.curr-code no-undo.
define variable parschobj-code     like ub.clients.obj-code   no-undo.
define variable parschcli-type     like ub.clients.obj-type   no-undo.
define variable parschcli-code     like ub.clients.obj-code   no-undo.

define variable varlog             as   logical               no-undo.
define variable varnext-prev       as   logical               no-undo.
define variable vardoc-mode        as   character             no-undo.
define variable varline-rec        as   recid                 no-undo.
define variable is-finby as logical   no-undo .
define variable par-is-finby as character no-undo .
define variable par-type as character no-undo .
/* ----------------------------  верхний ряд батонов  -------------------------------- */

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход ":L
     SIZE 8 BY 1.

DEFINE BUTTON b-sel
     LABEL "Вы&бор ":L
     SIZE 8 BY 1.

DEFINE BUTTON b-rep
     LABEL "О&тчеты":L
     SIZE 9 BY 1.

DEFINE BUTTON b-sch
     LABEL "&Фильтр":L
     SIZE 3 BY 1.

DEFINE BUTTON b-bc
     LABEL "&Ценник":L
     SIZE 9 BY 1.

DEFINE BUTTON b-akt
     LABEL "АПерео&ц":L
     SIZE 8 BY 1.

DEFINE BUTTON b-pay
     LABEL "Генерац&.":L
     SIZE 9 BY 1.

DEFINE BUTTON b-ext
     LABEL "Запус&к":L
     SIZE 8 BY 1.

define button b-covdocs
     label "СопрДок":l
     size 8 by 1
     tooltip "Сопроводительные документы".

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.

/* ----------------------------  нижний ряд батонов  -------------------------------- */

DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 9.5 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE 9.5 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 9 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 9 BY 1.

DEFINE BUTTON b-close
     LABEL "&Закрыть":L
     SIZE 8 BY 1.

DEFINE BUTTON b-open
     LABEL "&Открыть":L
     SIZE 8 BY 1.

DEFINE BUTTON b-copy
     LABEL "&Копия":L
     SIZE 8 BY 1.

DEFINE BUTTON b-unrv
     LABEL "Р&езерв":L
     SIZE 9 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 3 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1.

DEFINE BUTTON b-exp
     LABEL "&Экспорт":L
     SIZE 8 BY 1.

DEFINE BUTTON b-history
     LABEL "Истори&я":L
     SIZE 3 BY 1.

DEFINE BUTTON b-f-ed
     LABEL "Основ&ан.":L
     SIZE 9 BY 1.

DEFINE BUTTON b-to-inv
     LABEL "В инвен.":L
     SIZE 9 BY 1 
     TOOLTIP "Объединение документов в итоговую инвентаризацию" . 

DEFINE BUTTON b-to-update
     LABEL "Обнов.":L
     tooltip "Обновить интерфейс"
     SIZE 7 BY 1. 
          
DEFINE BUTTON b-uf
     image file "cmp/b-must.bmp":u
     tooltip "Настройка колонок в таблице для пользователя"
     SIZE 3 BY 1.

DEFINE BUTTON b-filter-ext
     image file "cmp/b-schef.bmp":u
     tooltip "Расширенный фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON b-scaner
     image file "cmp/b-scaner.bmp":u
     tooltip "Сканирование и просмотр бумажного носителя"
     SIZE 3 BY 1.

DEFINE RECTANGLE R-scaner
     EDGE-PIXELS 0
     SIZE 3 BY 1.1
     BGCOLOR 14 .

DEFINE VARIABLE agnt-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 18 BY 1 NO-UNDO.

DEFINE VARIABLE wrkr-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 18 BY 1 NO-UNDO.

DEFINE VARIABLE v-user-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE boss-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 19 BY 1 NO-UNDO.

DEFINE VARIABLE obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 34 BY 1 NO-UNDO.

DEFINE VARIABLE ed-notes AS CHARACTER
     VIEW-AS EDITOR
     SIZE 98.6 BY 2 NO-UNDO.

define MENU m-export
    MENU-ITEM m-export-1 LABEL "формат XML"
    MENU-ITEM m-export-2 LABEL "формат Моб.сканера"
    .
define MENU m-scaner
    MENU-ITEM m-scaner-add  LABEL "Сканировать"
    MENU-ITEM m-scaner-file LABEL "Взять из файла"
    rule
    MENU-ITEM m-scaner-del LABEL "Удалить изображение"
    MENU-ITEM m-scaner-lkp LABEL "Просмотр изображения"
    .

DEFINE MENU m-rep
    MENU-ITEM m-rep-1 LABEL "По документам"                      ACCELERATOR "ALT-1"
    MENU-ITEM m-rep-3 LABEL "По документам (в ценах документа)"  ACCELERATOR "ALT-3"
    MENU-ITEM m-rep-2 LABEL "По товарам документов"              ACCELERATOR "ALT-2"
    /*MENU-ITEM m-rep-4 LABEL "ТТН "                               ACCELERATOR "ALT-4"*/
    .

DEFINE MENU POPUP-MENU-b-pay
  MENU-ITEM m_gen-6  LABEL "ФО по поставщикам (генерация)"
  MENU-ITEM m_gen-22 LABEL "ФО от покупателей (генерация)"
  MENU-ITEM m_gen-8  LABEL "Отказаться от генерации финобязательств по поставке"
  MENU-ITEM m_gen-9  LABEL "Отказаться от генерации финобязательств по реализации"
  MENU-ITEM m_gen-19 LABEL "Отказаться от генерации финобязательств покупателей"
  MENU-ITEM m_gen-11 LABEL "Снять признак - есть генерация финобязательств по поставке"
  MENU-ITEM m_gen-12 LABEL "Снять признак - есть генерация финобязательств по реализации"
  MENU-ITEM m_gen-20 LABEL "Снять признак - есть генерация финобязательств покупателей"
  MENU-ITEM m_gen-13 LABEL "Снять 'не опред' по поставке"
  MENU-ITEM m_gen-14 LABEL "Снять 'не опред' по реализации"
  MENU-ITEM m_gen-21 LABEL "Снять 'не опред' по покупателям"
  RULE
  MENU-ITEM m_gen-15 LABEL "Счета-фактуры"
  MENU-ITEM m_gen-16 LABEL "Отказаться от генерации счета-фактуры"
  MENU-ITEM m_gen-17 LABEL "Снять признак - есть генерация счета-фактуры"
  MENU-ITEM m_gen-18 LABEL "Снять 'не опред'"
  RULE
  MENU-ITEM m_gen-23 LABEL "УПД"
.

DEFINE MENU POPUP-MENU-b-f-ed
       MENU-ITEM m_fact-edit-1 LABEL "Изменить причину создания тек.документа"     ACCELERATOR "ALT-1"
       MENU-ITEM m_fact-edit-2 LABEL "Изменить причину создания отмеченных документов" ACCELERATOR "ALT-2"
.

define new shared variable sch-code    like ub.trn-doc.doc-code no-undo.
define new shared variable sch-date    as   date view-as fill-in size 9 by 1 no-undo.
define new shared variable sch-fact    as   date view-as fill-in size 9 by 1 no-undo.
define new shared variable sch-objtype like ub.clients.obj-type no-undo.
define new shared variable sch-objcode like ub.clients.obj-code no-undo.
define new shared variable sch-sum     like ub.trn-doc.tot-fact no-undo.
define new shared variable sch-num     as   integer view-as fill-in size 3 by 1 no-undo.
define new shared query br-docs for t-doc except  , temp-trn-doc scrolling.

&scop label-clmn_1-br-dtl  '*'
&scop sort-clmn_1-br-dtl   mark-string (recid(t-doc))
&scop dyn_sort-clmn_1-br-dtl   substitute('dynamic-function(&1mark-string&1, ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_2-br-dtl  'Т'
&scop sort-clmn_2-br-dtl   first-symb-type (recid(t-doc))
&scop dyn_sort-clmn_2-br-dtl   substitute('dynamic-function(&1first-symb-type&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_3-br-dtl  'Стат'
&scop sort-clmn_3-br-dtl   t-doc.status_
&scop label-clmn_4-br-dtl  'OK'
&scop sort-clmn_4-br-dtl   t-doc.flag_
&scop label-clmn_5-br-dtl  'Номер'
&scop sort-clmn_5-br-dtl   t-doc.doc-code
&scop label-clmn_6-br-dtl  'Дата'
&scop sort-clmn_6-br-dtl   t-doc.doc-date
&scop label-clmn_7-br-dtl  'Факт'
&scop sort-clmn_7-br-dtl   t-doc.fact-date
&scop label-clmn_8-br-dtl  'Смена'
&scop sort-clmn_8-br-dtl   shift-day-month (recid(t-doc))
&scop dyn_sort-clmn_8-br-dtl   substitute('dynamic-function(&1shift-day-month&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_9-br-dtl  '№'
&scop sort-clmn_9-br-dtl   shift-name (recid(t-doc))
&scop dyn_sort-clmn_9-br-dtl   substitute('dynamic-function(&1shift-name&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop sort-clmn_9000-br-dtl  t-doc.shift-name
&scop label-clmn_10-br-dtl 'В'
&scop sort-clmn_10-br-dtl  t-doc.internal
&scop label-clmn_11-br-dtl 'Контрагент'
&scop sort-clmn_11-br-dtl  fcli-name (recid(t-doc))
&scop dyn_sort-clmn_11-br-dtl  substitute('dynamic-function(&1fcli-name&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_12-br-dtl 'Объект'
&scop sort-clmn_12-br-dtl  object-label (recid(t-doc))
&scop dyn_sort-clmn_12-br-dtl  substitute('dynamic-function(&1object-label&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_13-br-dtl 'У'
&scop sort-clmn_13-br-dtl  t-doc.office
&scop label-clmn_14-br-dtl 'Кол-во по док.'
&scop sort-clmn_14-br-dtl  total-doc-qnty (recid(t-doc))
&scop dyn_sort-clmn_14-br-dtl  substitute('dynamic-function(&1total-doc-qnty&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_15-br-dtl 'Кол-во факт'
&scop sort-clmn_15-br-dtl  total-fact-qnty (recid(t-doc))
&scop dyn_sort-clmn_15-br-dtl  substitute('dynamic-function(&1total-fact-qnty&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_16-br-dtl '$'
&scop sort-clmn_16-br-dtl  t-doc.print-rubl
&scop label-clmn_17-br-dtl 'Сумма по док'
&scop sort-clmn_17-br-dtl  total-sum (recid(t-doc))
&scop dyn_sort-clmn_17-br-dtl  substitute('dynamic-function(&1total-sum&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_18-br-dtl 'Скидка по док'
&scop sort-clmn_18-br-dtl  total-dsc (recid(t-doc))
&scop dyn_sort-clmn_18-br-dtl  substitute('dynamic-function(&1total-dsc&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_19-br-dtl 'Сумма факт'
&scop sort-clmn_19-br-dtl  total-fact (recid(t-doc))
&scop dyn_sort-clmn_19-br-dtl  substitute('dynamic-function(&1total-fact&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_20-br-dtl 'Скидка факт'
&scop sort-clmn_20-br-dtl  total-dsc-fact (recid(t-doc))
&scop dyn_sort-clmn_20-br-dtl  substitute('dynamic-function(&1total-dsc-fact&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_21-br-dtl 'К оплате факт'
&scop sort-clmn_21-br-dtl  total-pay-fact (recid(t-doc))
&scop dyn_sort-clmn_21-br-dtl  substitute('dynamic-function(&1total-pay-fact&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_22-br-dtl 'НДС'
&scop sort-clmn_22-br-dtl  total-vat (recid(t-doc))
&scop dyn_sort-clmn_22-br-dtl  substitute('dynamic-function(&1total-vat&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_23-br-dtl 'Сумма учет.'
&scop sort-clmn_23-br-dtl  total-acc (recid(t-doc))
&scop dyn_sort-clmn_23-br-dtl  substitute('dynamic-function(&1total-acc&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_24-br-dtl 'Скидка (%)'
&scop sort-clmn_24-br-dtl  t-doc.discnt-pc
&scop label-clmn_25-br-dtl 'Тип скидки'
&scop sort-clmn_25-br-dtl  t-doc.discnt-type
&scop label-clmn_26-br-dtl 'Курс'
&scop sort-clmn_26-br-dtl  t-doc.base-rate
&scop label-clmn_27-br-dtl 'А'
&scop sort-clmn_27-br-dtl  t-doc.ov
&scop label-clmn_28-br-dtl 'Авт. переоц. (прод.)'
&scop sort-clmn_28-br-dtl  t-doc.tot-ov
&scop label-clmn_29-br-dtl 'Инв.'
&scop sort-clmn_29-br-dtl  t-doc.inv-num
&scop label-clmn_30-br-dtl 'Запрос'
&scop sort-clmn_30-br-dtl  t-doc.ord-num
&scop label-clmn_31-br-dtl 'Отгрузка приход'
&scop sort-clmn_31-br-dtl  t-doc.ship-num
&scop label-clmn_32-br-dtl 'Дата отгр'
&scop sort-clmn_32-br-dtl  t-doc.ship-date
&scop label-clmn_33-br-dtl 'На док-т'
&scop sort-clmn_33-br-dtl  t-doc.out-code
&scop label-clmn_34-br-dtl 'Внеш.сист'
&scop sort-clmn_34-br-dtl  t-doc.acc-date
&scop label-clmn_35-br-dtl 'Экспорт'
&scop sort-clmn_35-br-dtl  t-doc.bge-date
&scop label-clmn_36-br-dtl 'Резерв отгрузка'
&scop sort-clmn_36-br-dtl  t-doc.rsrv-date
&scop label-clmn_37-br-dtl 'ФО поставка'
&scop sort-clmn_37-br-dtl  fo-postavka (recid(t-doc))
&scop dyn_sort-clmn_37-br-dtl  substitute('dynamic-function(&1fo-postavka&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_38-br-dtl 'ФО реализация'
&scop sort-clmn_38-br-dtl  fo-realiz (recid(t-doc))
&scop dyn_sort-clmn_38-br-dtl  substitute('dynamic-function(&1fo-realiz&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_39-br-dtl 'Счет-фактура'
&scop sort-clmn_39-br-dtl  factur (recid(t-doc))
&scop dyn_sort-clmn_39-br-dtl  substitute('dynamic-function(&1factur&1 , ( recid(t-doc)) )' , ~{&double-quote~})
&scop label-clmn_40-br-dtl 'ФО покупателя'
&scop sort-clmn_40-br-dtl  fo-buyer (recid(t-doc))
&scop dyn_sort-clmn_40-br-dtl  substitute('dynamic-function(&1fo-buyer&1 , ( recid(t-doc)) )' , ~{&double-quote~})

&scop attr-code trdcattr-hold-part-code
&scop attr-n 41
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl      f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop attr-code trdcattr-dov
&scop attr-n 42
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-dids
&scop attr-n 43
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-nids
&scop attr-n 44
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-ddog
&scop attr-n 45
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-ndog
&scop attr-n 46
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-dsf
&scop attr-n 47
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-nsf
&scop attr-n 48
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-addsum
&scop attr-n 49
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-clcasol
&scop attr-n 50
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-clcaswt
&scop attr-n 51
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-scanfile
&scop attr-n 52
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-indoclnsum
&scop attr-n 53
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-purchlimit
&scop attr-n 54
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-purchcodelist
&scop attr-n 55
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-expense_own
&scop attr-n 56
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-envd
&scop attr-n 57
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-ord_time
&scop attr-n 58
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-dchek
&scop attr-n 59
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-befpay
&scop attr-n 60
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-ord_nchek
&scop attr-n 61
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-deliv
&scop attr-n 62
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-sumwrk
&scop attr-n 63
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-sumsrk
&scop attr-n 64
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-ord_adr
&scop attr-n 65
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-ord_hwo
&scop attr-n 66
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-fbroperator
&scop attr-n 67
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-fbrauto
&scop attr-n 68
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-rsrv-doc-list
&scop attr-n 69
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-postdchek
&scop attr-n 70
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-postpay
&scop attr-n 71
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-postNchek
&scop attr-n 72
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-frsrv-date
&scop attr-n 73
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-ord_phone
&scop attr-n 74
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-ord_dl
&scop attr-n 75
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-ord_contact
&scop attr-n 76
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-m-inc
&scop attr-n 77
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-qntyplace
&scop attr-n 78
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-discnt-stop
&scop attr-n 79
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-discnt-other
&scop attr-n 80
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-dfindoc
&scop attr-n 81
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-nfindoc
&scop attr-n 82
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-place-storage
&scop attr-n 83
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-packer
&scop attr-n 84
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-dispath
&scop attr-n 85
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-price-target
&scop attr-n 86
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-edi
&scop attr-n 87
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-ddov
&scop attr-n 88
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-ndov
&scop attr-n 89
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-recipient
&scop attr-n 90
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-auto
&scop attr-n 91
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-driver
&scop attr-n 92
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-print-num
&scop attr-n 93
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-oldsuppcntr
&scop attr-n 94
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-nosn
&scop attr-n 95
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-n 96
&scop label-clmn_96-br-dtl 'Дата изменения'
&scop sort-clmn_96-br-dtl  t-doc.sys-date
&scop attr-n 97
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')
&scop attr-code trdcattr-shipper
&scop attr-n 98
&scop label-clmn_98-br-dtl 'Закрыт задним числом'
&scop sort-clmn_98-br-dtl closed-backdated (recid(t-doc))
&scop attr-code trdcattr-delivery-date
&scop attr-n 99
&scop format-clmn_{&attr-n}  {&fillin_width-{&attr-code}}
&scop label-clmn_{&attr-n}-br-dtl {&label-{&attr-code}}
&scop sort-clmn_{&attr-n}-br-dtl  f-{&bef-{&attr-code}}  (recid(t-doc))
&scop dyn_sort-clmn_{&attr-n}-br-dtl  substitute('dynamic-function( &1f-&2&1 , (recid(t-doc)))' ,  ~{&double-quote~} , '{&bef-{&attr-code}}')

 define variable head-col as character no-undo .
head-col =
   {&label-clmn_1-br-dtl}   + '#' +
   {&label-clmn_2-br-dtl}   + '#' +
   {&label-clmn_3-br-dtl}   + '#' +
   {&label-clmn_4-br-dtl}   + '#' +
   {&label-clmn_5-br-dtl}   + '#' +
   {&label-clmn_6-br-dtl}   + '#' +
   {&label-clmn_7-br-dtl}   + '#' +
   {&label-clmn_8-br-dtl}   + '#' +
   {&label-clmn_9-br-dtl}   + '#' +
   {&label-clmn_10-br-dtl}  + '#' +
   {&label-clmn_11-br-dtl}  + '#' +
   {&label-clmn_12-br-dtl}  + '#' +
   {&label-clmn_13-br-dtl}  + '#' +
   {&label-clmn_14-br-dtl}  + '#' +
   {&label-clmn_15-br-dtl}  + '#' +
   {&label-clmn_16-br-dtl}  + '#' +
   {&label-clmn_17-br-dtl}  + '#' +
   {&label-clmn_18-br-dtl}  + '#' +
   {&label-clmn_19-br-dtl}  + '#' +
   {&label-clmn_20-br-dtl}  + '#' +
   {&label-clmn_21-br-dtl}  + '#' +
   {&label-clmn_22-br-dtl}  + '#' +
   {&label-clmn_23-br-dtl}  + '#' +
   {&label-clmn_24-br-dtl}  + '#' +
   {&label-clmn_25-br-dtl}  + '#' +
   {&label-clmn_26-br-dtl}  + '#' +
   {&label-clmn_27-br-dtl}  + '#' +
   {&label-clmn_28-br-dtl}  + '#' +
   {&label-clmn_29-br-dtl}  + '#' +
   {&label-clmn_30-br-dtl}  + '#' +
   {&label-clmn_31-br-dtl}  + '#' +
   {&label-clmn_32-br-dtl}  + '#' +
   {&label-clmn_33-br-dtl}  + '#' +
   {&label-clmn_34-br-dtl}  + '#' +
   {&label-clmn_35-br-dtl}  + '#' +
   {&label-clmn_36-br-dtl}  + '#' +
   {&label-clmn_37-br-dtl}  + '#' +
   {&label-clmn_38-br-dtl}  + '#' +
   {&label-clmn_39-br-dtl}  + '#' +
   {&label-clmn_40-br-dtl}  + '#' +
   {&label-clmn_41-br-dtl}  + '#' +
   {&label-clmn_42-br-dtl}  + '#' +
   {&label-clmn_43-br-dtl}  + '#' +
   {&label-clmn_44-br-dtl}  + '#' +
   {&label-clmn_45-br-dtl}  + '#' +
   {&label-clmn_46-br-dtl}  + '#' +
   {&label-clmn_47-br-dtl}  + '#' +
   {&label-clmn_48-br-dtl}  + '#' +
   {&label-clmn_49-br-dtl}  + '#' +
   {&label-clmn_50-br-dtl}  + '#' +
   {&label-clmn_51-br-dtl}  + '#' +
   {&label-clmn_52-br-dtl}  + '#' +
   {&label-clmn_53-br-dtl}  + '#' +
   {&label-clmn_54-br-dtl}  + '#' +
   {&label-clmn_55-br-dtl}  + '#' +
   {&label-clmn_56-br-dtl}  + '#' +
   {&label-clmn_57-br-dtl}  + '#' +
   {&label-clmn_58-br-dtl}  + '#' +
   {&label-clmn_59-br-dtl}  + '#' +
   {&label-clmn_60-br-dtl}  + '#' +
   {&label-clmn_61-br-dtl}  + '#' +
   {&label-clmn_62-br-dtl}  + '#' +
   {&label-clmn_63-br-dtl}  + '#' +
   {&label-clmn_64-br-dtl}  + '#' +
   {&label-clmn_65-br-dtl}  + '#' +
   {&label-clmn_66-br-dtl}  + '#' +
   {&label-clmn_67-br-dtl}  + '#' +
   {&label-clmn_68-br-dtl}  + '#' +
   {&label-clmn_69-br-dtl}  + '#' +
   {&label-clmn_70-br-dtl}  + '#' +
   {&label-clmn_71-br-dtl}  + '#' +
   {&label-clmn_72-br-dtl}  + '#' +
   {&label-clmn_73-br-dtl}  + '#' +
   {&label-clmn_74-br-dtl}  + '#' +
   {&label-clmn_75-br-dtl}  + '#' +
   {&label-clmn_76-br-dtl}  + '#' +
   {&label-clmn_77-br-dtl}  + '#' +
   {&label-clmn_78-br-dtl}  + '#' +
   {&label-clmn_79-br-dtl}  + '#' +
   {&label-clmn_80-br-dtl}  + '#' +
   {&label-clmn_81-br-dtl}  + '#' +
   {&label-clmn_82-br-dtl}  + '#' +
   {&label-clmn_83-br-dtl}  + '#' +
   {&label-clmn_84-br-dtl}  + '#' +
   {&label-clmn_85-br-dtl}  + '#' +
   {&label-clmn_86-br-dtl}  + '#' +
   {&label-clmn_87-br-dtl}  + '#' +
   {&label-clmn_88-br-dtl}  + '#' +
   {&label-clmn_89-br-dtl}  + '#' +
   {&label-clmn_90-br-dtl}  + '#' +
   {&label-clmn_91-br-dtl}  + '#' +
   {&label-clmn_92-br-dtl}  + '#' +
   {&label-clmn_93-br-dtl}  + '#' +
   {&label-clmn_94-br-dtl}  + '#' +
   {&label-clmn_95-br-dtl}  + '#' +
   {&label-clmn_96-br-dtl}  + '#' +
   {&label-clmn_97-br-dtl}  + '#' +
   {&label-clmn_98-br-dtl}  + '#' +
   {&label-clmn_99-br-dtl}
  .

define browse br-docs query br-docs no-lock display
      {&sort-clmn_1-br-dtl}  column-label {&label-clmn_1-br-dtl}  format "x(1)"
      {&sort-clmn_2-br-dtl}  column-label {&label-clmn_2-br-dtl}  format "x(1)"
      {&sort-clmn_3-br-dtl}  column-label {&label-clmn_3-br-dtl}  format "x(4)"
      {&sort-clmn_4-br-dtl}  column-label {&label-clmn_4-br-dtl}  format "+/-"
      {&sort-clmn_5-br-dtl}  column-label {&label-clmn_5-br-dtl}  format "x(14)"
      {&sort-clmn_6-br-dtl}  column-label {&label-clmn_6-br-dtl}  format "99/99/99"
      {&sort-clmn_7-br-dtl}  column-label {&label-clmn_7-br-dtl}
      {&sort-clmn_8-br-dtl}  column-label {&label-clmn_8-br-dtl}  format "x(5)"
      {&sort-clmn_9-br-dtl}  column-label {&label-clmn_9-br-dtl}  format "x(6)"
      {&sort-clmn_10-br-dtl} column-label {&label-clmn_10-br-dtl} format "+/-"
      {&sort-clmn_11-br-dtl} column-label {&label-clmn_11-br-dtl} format "x(70)" width 26
      {&sort-clmn_12-br-dtl} column-label {&label-clmn_12-br-dtl} format "x(9)"
      {&sort-clmn_13-br-dtl} column-label {&label-clmn_13-br-dtl} format "+/-"
      {&sort-clmn_14-br-dtl} column-label {&label-clmn_14-br-dtl} FORMAT "->>,>>>,>>9.<<<"
      {&sort-clmn_15-br-dtl} column-label {&label-clmn_15-br-dtl} FORMAT "->>,>>>,>>9.<<<"
      {&sort-clmn_16-br-dtl} column-label {&label-clmn_16-br-dtl} format "-/$"
      {&sort-clmn_17-br-dtl} column-label {&label-clmn_17-br-dtl} format "->,>>>,>>>,>>>,>>9.99"
      {&sort-clmn_18-br-dtl} column-label {&label-clmn_18-br-dtl} format "->,>>>,>>>,>>>,>>9.99"
      {&sort-clmn_19-br-dtl} column-label {&label-clmn_19-br-dtl} format "->,>>>,>>>,>>>,>>9.99"
      {&sort-clmn_20-br-dtl} column-label {&label-clmn_20-br-dtl} format "->,>>>,>>>,>>>,>>9.99"
      {&sort-clmn_21-br-dtl} column-label {&label-clmn_21-br-dtl} format "x(21)"
      {&sort-clmn_22-br-dtl} column-label {&label-clmn_22-br-dtl} format "->,>>>,>>>,>>>,>>9.99"
      {&sort-clmn_23-br-dtl} column-label {&label-clmn_23-br-dtl} format "->,>>>,>>>,>>>,>>9.99"
      {&sort-clmn_24-br-dtl} column-label {&label-clmn_24-br-dtl} format "->,>>9.99"
      {&sort-clmn_25-br-dtl} column-label {&label-clmn_25-br-dtl}
      {&sort-clmn_26-br-dtl} column-label {&label-clmn_26-br-dtl}
      {&sort-clmn_27-br-dtl} column-label {&label-clmn_27-br-dtl}
      {&sort-clmn_28-br-dtl} column-label {&label-clmn_28-br-dtl} format "->,>>>,>>>,>>>,>>9.99"
      {&sort-clmn_29-br-dtl} column-label {&label-clmn_29-br-dtl}
      {&sort-clmn_30-br-dtl} column-label {&label-clmn_30-br-dtl}
      {&sort-clmn_31-br-dtl} column-label {&label-clmn_31-br-dtl}
      {&sort-clmn_32-br-dtl} column-label {&label-clmn_32-br-dtl}
      {&sort-clmn_33-br-dtl} column-label {&label-clmn_33-br-dtl}
      {&sort-clmn_34-br-dtl} column-label {&label-clmn_34-br-dtl}
      {&sort-clmn_35-br-dtl} column-label {&label-clmn_35-br-dtl}
      {&sort-clmn_36-br-dtl} column-label {&label-clmn_36-br-dtl}
      {&sort-clmn_37-br-dtl} @ varpost   column-label {&label-clmn_37-br-dtl} format "x(8)"
      {&sort-clmn_38-br-dtl} @ varrealiz column-label {&label-clmn_38-br-dtl} format "x(8)"
      {&sort-clmn_39-br-dtl} @ varfactur column-label {&label-clmn_39-br-dtl} format "x(8)"
      {&sort-clmn_40-br-dtl} @ varbuyer  column-label {&label-clmn_40-br-dtl} format "x(8)"
      {&sort-clmn_41-br-dtl} column-label {&label-clmn_41-br-dtl} format "x({&format-clmn_41})"
      {&sort-clmn_42-br-dtl} column-label {&label-clmn_42-br-dtl} format "x({&format-clmn_42})"
      {&sort-clmn_43-br-dtl} column-label {&label-clmn_43-br-dtl} format "x({&format-clmn_43})"
      {&sort-clmn_44-br-dtl} column-label {&label-clmn_44-br-dtl} format "x({&format-clmn_44})"
      {&sort-clmn_45-br-dtl} column-label {&label-clmn_45-br-dtl} format "x({&format-clmn_45})"
      {&sort-clmn_46-br-dtl} column-label {&label-clmn_46-br-dtl} format "x({&format-clmn_46})"
      {&sort-clmn_47-br-dtl} column-label {&label-clmn_47-br-dtl} format "x({&format-clmn_47})"
      {&sort-clmn_48-br-dtl} column-label {&label-clmn_48-br-dtl} format "x({&format-clmn_48})"
      {&sort-clmn_49-br-dtl} column-label {&label-clmn_49-br-dtl} format "x({&format-clmn_49})"
      {&sort-clmn_50-br-dtl} column-label {&label-clmn_50-br-dtl} format "x({&format-clmn_50})"
      {&sort-clmn_51-br-dtl} column-label {&label-clmn_51-br-dtl} format "x({&format-clmn_51})"
      {&sort-clmn_52-br-dtl} column-label {&label-clmn_52-br-dtl} format "x({&format-clmn_52})"
      {&sort-clmn_53-br-dtl} column-label {&label-clmn_53-br-dtl} format "x({&format-clmn_53})"
      {&sort-clmn_54-br-dtl} column-label {&label-clmn_54-br-dtl} format "x({&format-clmn_54})"
      {&sort-clmn_55-br-dtl} column-label {&label-clmn_55-br-dtl} format "x({&format-clmn_55})"
      {&sort-clmn_56-br-dtl} column-label {&label-clmn_56-br-dtl} format "x({&format-clmn_56})"
      {&sort-clmn_57-br-dtl} column-label {&label-clmn_57-br-dtl} format "x({&format-clmn_57})"
      {&sort-clmn_58-br-dtl} column-label {&label-clmn_58-br-dtl} format "x({&format-clmn_58})"
      {&sort-clmn_59-br-dtl} column-label {&label-clmn_59-br-dtl} format "x({&format-clmn_59})"
      {&sort-clmn_60-br-dtl} column-label {&label-clmn_60-br-dtl} format "x({&format-clmn_60})"
      {&sort-clmn_61-br-dtl} column-label {&label-clmn_61-br-dtl} format "x({&format-clmn_61})"
      {&sort-clmn_62-br-dtl} column-label {&label-clmn_62-br-dtl} format "x({&format-clmn_62})"
      {&sort-clmn_63-br-dtl} column-label {&label-clmn_63-br-dtl} format "x({&format-clmn_63})"
      {&sort-clmn_64-br-dtl} column-label {&label-clmn_64-br-dtl} format "x({&format-clmn_64})"
      {&sort-clmn_65-br-dtl} column-label {&label-clmn_65-br-dtl} format "x({&format-clmn_65})"
      {&sort-clmn_66-br-dtl} column-label {&label-clmn_66-br-dtl} format "x({&format-clmn_66})"
      {&sort-clmn_67-br-dtl} column-label {&label-clmn_67-br-dtl} format "x({&format-clmn_67})"
      {&sort-clmn_68-br-dtl} column-label {&label-clmn_68-br-dtl} format "x({&format-clmn_68})"
      {&sort-clmn_69-br-dtl} column-label {&label-clmn_69-br-dtl} format "x({&format-clmn_69})"
      {&sort-clmn_70-br-dtl} column-label {&label-clmn_70-br-dtl} format "x({&format-clmn_70})"
      {&sort-clmn_71-br-dtl} column-label {&label-clmn_71-br-dtl} format "x({&format-clmn_71})"
      {&sort-clmn_72-br-dtl} column-label {&label-clmn_72-br-dtl} format "x({&format-clmn_72})"
      {&sort-clmn_73-br-dtl} column-label {&label-clmn_73-br-dtl} format "x({&format-clmn_73})"
      {&sort-clmn_74-br-dtl} column-label {&label-clmn_74-br-dtl} format "x({&format-clmn_74})"
      {&sort-clmn_75-br-dtl} column-label {&label-clmn_75-br-dtl} format "x({&format-clmn_75})"
      {&sort-clmn_76-br-dtl} column-label {&label-clmn_76-br-dtl} format "x({&format-clmn_76})"
      {&sort-clmn_77-br-dtl} column-label {&label-clmn_77-br-dtl} format "x({&format-clmn_77})"
      {&sort-clmn_78-br-dtl} column-label {&label-clmn_78-br-dtl} format "x({&format-clmn_78})"
      {&sort-clmn_79-br-dtl} column-label {&label-clmn_79-br-dtl} format "x({&format-clmn_79})"
      {&sort-clmn_80-br-dtl} column-label {&label-clmn_80-br-dtl} format "x({&format-clmn_80})"
      {&sort-clmn_81-br-dtl} column-label {&label-clmn_81-br-dtl} format "x({&format-clmn_81})"
      {&sort-clmn_82-br-dtl} column-label {&label-clmn_82-br-dtl} format "x({&format-clmn_82})"
      {&sort-clmn_83-br-dtl} column-label {&label-clmn_83-br-dtl} format "x({&format-clmn_83})"
      {&sort-clmn_84-br-dtl} column-label {&label-clmn_84-br-dtl} format "x({&format-clmn_84})"
      {&sort-clmn_85-br-dtl} column-label {&label-clmn_85-br-dtl} format "x({&format-clmn_85})"
      {&sort-clmn_86-br-dtl} column-label {&label-clmn_86-br-dtl} format "x({&format-clmn_86})"
      {&sort-clmn_87-br-dtl} column-label {&label-clmn_87-br-dtl} format "x({&format-clmn_87})"
      {&sort-clmn_88-br-dtl} column-label {&label-clmn_88-br-dtl} format "x({&format-clmn_88})"
      {&sort-clmn_89-br-dtl} column-label {&label-clmn_89-br-dtl} format "x({&format-clmn_89})"
      {&sort-clmn_90-br-dtl} column-label {&label-clmn_90-br-dtl} format "x({&format-clmn_90})"
      {&sort-clmn_91-br-dtl} column-label {&label-clmn_91-br-dtl} format "x({&format-clmn_91})"
      {&sort-clmn_92-br-dtl} column-label {&label-clmn_92-br-dtl} format "x({&format-clmn_92})"
      {&sort-clmn_93-br-dtl} column-label {&label-clmn_93-br-dtl} format "x({&format-clmn_93})"
      {&sort-clmn_94-br-dtl} column-label {&label-clmn_94-br-dtl} format "x({&format-clmn_94})"
      {&sort-clmn_95-br-dtl} column-label {&label-clmn_95-br-dtl} format "x({&format-clmn_95})"
      {&sort-clmn_96-br-dtl} column-label {&label-clmn_96-br-dtl}
      {&sort-clmn_97-br-dtl} column-label {&label-clmn_97-br-dtl} format "x({&format-clmn_97})"
      {&sort-clmn_98-br-dtl} column-label {&label-clmn_98-br-dtl}
      {&sort-clmn_99-br-dtl} column-label {&label-clmn_99-br-dtl} format "9999/99/99"

    enable {&sort-clmn_32-br-dtl} with size 98.5 by 13.5 separators.

/* ************************  Frame Definitions  *********************** */
DEFINE FRAME {&frame-name}
     /* 1-й ряд батонов */
     b-quit AT ROW 1 COL  2
     b-mark AT ROW 1 COL 10
     b-sel  AT ROW 1 COL 13
     b-rep  AT ROW 1 COL 21
     b-bc   AT ROW 1 COL 30
     b-akt  AT ROW 1 COL 39
     b-ext  AT ROW 1 COL 47
     b-pay  AT ROW 1 COL 55


     b-sch  AT ROW 1 COL 90
     b-help AT ROW 1 COL 90
     /* 2-й ряд батонов */
     b-add    AT ROW 2.3 COL  2
     b-lkp    AT ROW 2.3 COL 11.5
     b-chg    AT ROW 2.3 COL 21
     b-del    AT ROW 2.3 COL 30
     b-close  AT ROW 2.3 COL 39
     b-open   AT ROW 2.3 COL 47
     b-copy   AT ROW 2.3 COL 92
     b-unrv   AT ROW 2.3 COL 55
     b-exp    AT ROW 2.3 COL 64
     b-f-ed   AT ROW 2.3 COL 72
     b-to-inv AT ROW 2.3 COL 81
     b-to-update AT ROW 2.3 COL 90
     b-covdocs AT ROW 2.3 COL  81
     b-history    AT ROW 2.3 COL 90
     b-print  AT ROW 2.3 COL 98
     b-uf     AT ROW 1 COL 82
     b-filter-ext     AT ROW 1 COL 85
     b-scaner         AT ROW 2.3 COL 98
     r-scaner         AT ROW 2.3   COL 98
     br-docs  AT ROW 3.5 COL 1
     sch-code at row 19 col 2 label "&Начало номера"   VIEW-AS FILL-IN SIZE 15 BY 1 fgcolor 4
     sch-date at row 19 col 33 label "Д&ата"
     sch-fact at row 19 col 51 label "Фа&кт"   VIEW-AS FILL-IN SIZE 10 BY 1 fgcolor 4
     sch-objcode at row 19 col 70 label "&Контрагент" VIEW-AS FILL-IN SIZE 11.5 BY 1 fgcolor 4
     sch-objtype at row 19 col 94 no-label
     sch-sum at row 20.1 col 2 label "&Сумма факт   "    VIEW-AS FILL-IN SIZE 15 BY 1 fgcolor 4
     sch-num at row 19 col 80 label "Найдено" fgcolor 12
     ub.pay-type.obj-name at row 17 col 5 COLON-ALIGNED LABEL "Опл" VIEW-AS FILL-IN SIZE 34 BY 1 fgcolor 4
     obj-name at row 17 col 55 COLON-ALIGNED LABEL "Объект" VIEW-AS FILL-IN SIZE 34 BY 1 fgcolor 4
     boss-name at row 18 col 5 COLON-ALIGNED LABEL "М-р" VIEW-AS FILL-IN SIZE 19 BY 1 fgcolor 4
     agnt-name at row 18 col 30 COLON-ALIGNED LABEL "Исп" VIEW-AS FILL-IN SIZE 18 BY 1 fgcolor 4
     wrkr-name at row 18 col 55 COLON-ALIGNED LABEL "Кл-к" VIEW-AS FILL-IN SIZE 18 BY 1 fgcolor 4
     v-user-name at row 18 col 80 COLON-ALIGNED LABEL "Опер" VIEW-AS FILL-IN SIZE 16 BY 1 fgcolor 4
     ed-notes AT ROW 21.2 COL 1 no-label bgcolor 8 fgcolor 4
     /*SPACE(0) SKIP(0.5) */
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
         DEFAULT-BUTTON b-quit.

{ gbl/srt-clmd.i
&browse-name = {&browse-name}
&frame-name  = {&frame-name}
&table-name = "t-doc"
&ext-col = 98
&start-column  = 1
&label-clmn_1  = "{&label-clmn_1-br-dtl}"
&sort-clmn_1   = "{&sort-clmn_1-br-dtl}"
&dyn_sort-clmn_1 = "{&dyn_sort-clmn_1-br-dtl}"
&label-clmn_2  = "{&label-clmn_2-br-dtl}"
&sort-clmn_2   = "{&sort-clmn_2-br-dtl}"
&dyn_sort-clmn_2  = "{&dyn_sort-clmn_2-br-dtl}"
&label-clmn_3  = "{&label-clmn_3-br-dtl}"
&sort-clmn_3   = "{&sort-clmn_3-br-dtl}"
&label-clmn_4  = "{&label-clmn_4-br-dtl}"
&sort-clmn_4   = "{&sort-clmn_4-br-dtl}"
&label-clmn_5  = "{&label-clmn_5-br-dtl}"
&sort-clmn_5   = "{&sort-clmn_5-br-dtl}"
&label-clmn_6  = "{&label-clmn_6-br-dtl}"
&sort-clmn_6   = "{&sort-clmn_6-br-dtl}"
&label-clmn_7  = "{&label-clmn_7-br-dtl}"
&sort-clmn_7   = "{&sort-clmn_7-br-dtl}"
&label-clmn_8  = "{&label-clmn_8-br-dtl}"
&sort-clmn_8   = "{&sort-clmn_8-br-dtl}"
&dyn_sort-clmn_8   = "{&dyn_sort-clmn_8-br-dtl}"
&label-clmn_9  = "{&label-clmn_9-br-dtl}"
&sort-clmn_9   = "{&sort-clmn_9000-br-dtl}"
&dyn_sort-clmn_9   = "{&dyn_sort-clmn_9-br-dtl}"
&label-clmn_10 = "{&label-clmn_10-br-dtl}"
&sort-clmn_10  = "{&sort-clmn_10-br-dtl}"
&label-clmn_11 = "{&label-clmn_11-br-dtl}"
&sort-clmn_11  = "{&sort-clmn_11-br-dtl}"
&dyn_sort-clmn_11  = "{&dyn_sort-clmn_11-br-dtl}"
&label-clmn_12 = "{&label-clmn_12-br-dtl}"
&sort-clmn_12  = "{&sort-clmn_12-br-dtl}"
&dyn_sort-clmn_12  = "{&dyn_sort-clmn_12-br-dtl}"
&label-clmn_13 = "{&label-clmn_13-br-dtl}"
&sort-clmn_13  = "{&sort-clmn_13-br-dtl}"
&label-clmn_14 = "{&label-clmn_14-br-dtl}"
&sort-clmn_14  = "{&sort-clmn_14-br-dtl}"
&dyn_sort-clmn_14  = "{&dyn_sort-clmn_14-br-dtl}"
&label-clmn_15 = "{&label-clmn_15-br-dtl}"
&sort-clmn_15  = "{&sort-clmn_15-br-dtl}"
&dyn_sort-clmn_15  = "{&dyn_sort-clmn_15-br-dtl}"
&label-clmn_16 = "{&label-clmn_16-br-dtl}"
&sort-clmn_16  = "{&sort-clmn_16-br-dtl}"
&label-clmn_17 = "{&label-clmn_17-br-dtl}"
&sort-clmn_17  = "{&sort-clmn_17-br-dtl}"
&dyn_sort-clmn_17  = "{&dyn_sort-clmn_17-br-dtl}"
&label-clmn_18 = "{&label-clmn_18-br-dtl}"
&sort-clmn_18  = "{&sort-clmn_18-br-dtl}"
&dyn_sort-clmn_18  = "{&dyn_sort-clmn_18-br-dtl}"
&label-clmn_19 = "{&label-clmn_19-br-dtl}"
&sort-clmn_19  = "{&sort-clmn_19-br-dtl}"
&dyn_sort-clmn_19  = "{&dyn_sort-clmn_19-br-dtl}"
&label-clmn_20 = "{&label-clmn_20-br-dtl}"
&sort-clmn_20  = "{&sort-clmn_20-br-dtl}"
&dyn_sort-clmn_20  = "{&dyn_sort-clmn_20-br-dtl}"
&label-clmn_21 = "{&label-clmn_21-br-dtl}"
&sort-clmn_21  = "{&sort-clmn_21-br-dtl}"
&dyn_sort-clmn_21  = "{&dyn_sort-clmn_21-br-dtl}"
&label-clmn_22 = "{&label-clmn_22-br-dtl}"
&sort-clmn_22  = "{&sort-clmn_22-br-dtl}"
&dyn_sort-clmn_22  = "{&dyn_sort-clmn_22-br-dtl}"
&label-clmn_23 = "{&label-clmn_23-br-dtl}"
&sort-clmn_23  = "{&sort-clmn_23-br-dtl}"
&dyn_sort-clmn_23  = "{&dyn_sort-clmn_23-br-dtl}"
&label-clmn_24 = "{&label-clmn_24-br-dtl}"
&sort-clmn_24  = "{&sort-clmn_24-br-dtl}"
&label-clmn_25 = "{&label-clmn_25-br-dtl}"
&sort-clmn_25  = "{&sort-clmn_25-br-dtl}"
&label-clmn_26 = "{&label-clmn_26-br-dtl}"
&sort-clmn_26  = "{&sort-clmn_26-br-dtl}"
&label-clmn_27 = "{&label-clmn_27-br-dtl}"
&sort-clmn_27  = "{&sort-clmn_27-br-dtl}"
&label-clmn_28 = "{&label-clmn_28-br-dtl}"
&sort-clmn_28  = "{&sort-clmn_28-br-dtl}"
&label-clmn_29 = "{&label-clmn_29-br-dtl}"
&sort-clmn_29  = "{&sort-clmn_29-br-dtl}"
&label-clmn_30 = "{&label-clmn_30-br-dtl}"
&sort-clmn_30  = "{&sort-clmn_30-br-dtl}"
&label-clmn_31 = "{&label-clmn_31-br-dtl}"
&sort-clmn_31  = "{&sort-clmn_31-br-dtl}"
&label-clmn_32 = "{&label-clmn_32-br-dtl}"
&sort-clmn_32  = "{&sort-clmn_32-br-dtl}"
&label-clmn_33 = "{&label-clmn_33-br-dtl}"
&sort-clmn_33  = "{&sort-clmn_33-br-dtl}"
&label-clmn_34 = "{&label-clmn_34-br-dtl}"
&sort-clmn_34  = "{&sort-clmn_34-br-dtl}"
&label-clmn_35 = "{&label-clmn_35-br-dtl}"
&sort-clmn_35  = "{&sort-clmn_35-br-dtl}"
&label-clmn_36 = "{&label-clmn_36-br-dtl}"
&sort-clmn_36  = "{&sort-clmn_36-br-dtl}"
&label-clmn_37 = "{&label-clmn_37-br-dtl}"
&sort-clmn_37  = "{&sort-clmn_37-br-dtl}"
&dyn_sort-clmn_37  = "{&dyn_sort-clmn_37-br-dtl}"
&label-clmn_38 = "{&label-clmn_38-br-dtl}"
&sort-clmn_38  = "{&sort-clmn_38-br-dtl}"
&dyn_sort-clmn_38  = "{&dyn_sort-clmn_38-br-dtl}"
&label-clmn_39 = "{&label-clmn_39-br-dtl}"
&sort-clmn_39  = "{&sort-clmn_39-br-dtl}"
&dyn_sort-clmn_39  = "{&dyn_sort-clmn_39-br-dtl}"
&label-clmn_40 = "{&label-clmn_40-br-dtl}"
&sort-clmn_40  = "{&sort-clmn_40-br-dtl}"
&dyn_sort-clmn_40  = "{&dyn_sort-clmn_40-br-dtl}"
&label-clmn_41 = '{&label-clmn_41-br-dtl}'
&sort-clmn_41  = "{&sort-clmn_41-br-dtl}"
&dyn_sort-clmn_41  = "{&dyn_sort-clmn_41-br-dtl}"
&label-clmn_42 = '{&label-clmn_42-br-dtl}'
&sort-clmn_42  = "{&sort-clmn_42-br-dtl}"
&dyn_sort-clmn_42  = "{&dyn_sort-clmn_42-br-dtl}"
&label-clmn_43 = '{&label-clmn_43-br-dtl}'
&sort-clmn_43  = "{&sort-clmn_43-br-dtl}"
&dyn_sort-clmn_43  = "{&dyn_sort-clmn_43-br-dtl}"
&label-clmn_44 = '{&label-clmn_44-br-dtl}'
&sort-clmn_44  = "{&sort-clmn_44-br-dtl}"
&dyn_sort-clmn_44  = "{&dyn_sort-clmn_44-br-dtl}"
&label-clmn_45 = '{&label-clmn_45-br-dtl}'
&sort-clmn_45  = "{&sort-clmn_45-br-dtl}"
&dyn_sort-clmn_45  = "{&dyn_sort-clmn_45-br-dtl}"
&label-clmn_46 = '{&label-clmn_46-br-dtl}'
&sort-clmn_46  = "{&sort-clmn_46-br-dtl}"
&dyn_sort-clmn_46  = "{&dyn_sort-clmn_46-br-dtl}"
&label-clmn_47 = '{&label-clmn_47-br-dtl}'
&sort-clmn_47  = "{&sort-clmn_47-br-dtl}"
&dyn_sort-clmn_47  = "{&dyn_sort-clmn_47-br-dtl}"
&label-clmn_48 = '{&label-clmn_48-br-dtl}'
&sort-clmn_48  = "{&sort-clmn_48-br-dtl}"
&dyn_sort-clmn_48  = "{&dyn_sort-clmn_48-br-dtl}"
&label-clmn_49 = '{&label-clmn_49-br-dtl}'
&sort-clmn_49  = "{&sort-clmn_49-br-dtl}"
&dyn_sort-clmn_49  = "{&dyn_sort-clmn_49-br-dtl}"
&label-clmn_50 = '{&label-clmn_50-br-dtl}'
&sort-clmn_50  = "{&sort-clmn_50-br-dtl}"
&dyn_sort-clmn_50  = "{&dyn_sort-clmn_50-br-dtl}"
&label-clmn_51 = '{&label-clmn_51-br-dtl}'
&sort-clmn_51  = "{&sort-clmn_51-br-dtl}"
&dyn_sort-clmn_51  = "{&dyn_sort-clmn_51-br-dtl}"
&label-clmn_52 = '{&label-clmn_52-br-dtl}'
&sort-clmn_52  = "{&sort-clmn_52-br-dtl}"
&dyn_sort-clmn_52  = "{&dyn_sort-clmn_52-br-dtl}"
&label-clmn_53 = '{&label-clmn_53-br-dtl}'
&sort-clmn_53  = "{&sort-clmn_53-br-dtl}"
&dyn_sort-clmn_53  = "{&dyn_sort-clmn_53-br-dtl}"
&label-clmn_54 = '{&label-clmn_54-br-dtl}'
&sort-clmn_54  = "{&sort-clmn_54-br-dtl}"
&dyn_sort-clmn_54  = "{&dyn_sort-clmn_54-br-dtl}"
&label-clmn_55 = '{&label-clmn_55-br-dtl}'
&sort-clmn_55  = "{&sort-clmn_55-br-dtl}"
&dyn_sort-clmn_55  = "{&dyn_sort-clmn_55-br-dtl}"
&label-clmn_56 = '{&label-clmn_56-br-dtl}'
&sort-clmn_56  = "{&sort-clmn_56-br-dtl}"
&dyn_sort-clmn_56  = "{&dyn_sort-clmn_56-br-dtl}"
&label-clmn_57 = '{&label-clmn_57-br-dtl}'
&sort-clmn_57  = "{&sort-clmn_57-br-dtl}"
&dyn_sort-clmn_57  = "{&dyn_sort-clmn_57-br-dtl}"
&label-clmn_58 = '{&label-clmn_58-br-dtl}'
&sort-clmn_58  = "{&sort-clmn_58-br-dtl}"
&dyn_sort-clmn_58  = "{&dyn_sort-clmn_58-br-dtl}"
&label-clmn_59 = '{&label-clmn_59-br-dtl}'
&sort-clmn_59  = "{&sort-clmn_59-br-dtl}"
&dyn_sort-clmn_59  = "{&dyn_sort-clmn_59-br-dtl}"
&label-clmn_60 = '{&label-clmn_60-br-dtl}'
&sort-clmn_60  = "{&sort-clmn_60-br-dtl}"
&dyn_sort-clmn_60  = "{&dyn_sort-clmn_60-br-dtl}"
&label-clmn_61 = '{&label-clmn_61-br-dtl}'
&sort-clmn_61  = "{&sort-clmn_61-br-dtl}"
&dyn_sort-clmn_61  = "{&dyn_sort-clmn_61-br-dtl}"
&label-clmn_62 = '{&label-clmn_62-br-dtl}'
&sort-clmn_62  = "{&sort-clmn_62-br-dtl}"
&dyn_sort-clmn_62  = "{&dyn_sort-clmn_62-br-dtl}"
&label-clmn_63 = '{&label-clmn_63-br-dtl}'
&sort-clmn_63  = "{&sort-clmn_63-br-dtl}"
&dyn_sort-clmn_63  = "{&dyn_sort-clmn_63-br-dtl}"
&label-clmn_64 = '{&label-clmn_64-br-dtl}'
&sort-clmn_64  = "{&sort-clmn_64-br-dtl}"
&dyn_sort-clmn_64  = "{&dyn_sort-clmn_64-br-dtl}"
&label-clmn_65 = '{&label-clmn_65-br-dtl}'
&sort-clmn_65  = "{&sort-clmn_65-br-dtl}"
&dyn_sort-clmn_65  = "{&dyn_sort-clmn_65-br-dtl}"
&label-clmn_66 = '{&label-clmn_66-br-dtl}'
&sort-clmn_66  = "{&sort-clmn_66-br-dtl}"
&dyn_sort-clmn_66  = "{&dyn_sort-clmn_66-br-dtl}"
&label-clmn_67 = '{&label-clmn_67-br-dtl}'
&sort-clmn_67  = "{&sort-clmn_67-br-dtl}"
&dyn_sort-clmn_67  = "{&dyn_sort-clmn_67-br-dtl}"
&label-clmn_68 = '{&label-clmn_68-br-dtl}'
&sort-clmn_68  = "{&sort-clmn_68-br-dtl}"
&dyn_sort-clmn_68  = "{&dyn_sort-clmn_68-br-dtl}"
&label-clmn_69 = '{&label-clmn_69-br-dtl}'
&sort-clmn_69  = "{&sort-clmn_69-br-dtl}"
&dyn_sort-clmn_69  = "{&dyn_sort-clmn_69-br-dtl}"
&label-clmn_70 = '{&label-clmn_70-br-dtl}'
&sort-clmn_70  = "{&sort-clmn_70-br-dtl}"
&dyn_sort-clmn_70  = "{&dyn_sort-clmn_70-br-dtl}"
&label-clmn_71 = '{&label-clmn_71-br-dtl}'
&sort-clmn_71  = "{&sort-clmn_71-br-dtl}"
&dyn_sort-clmn_71  = "{&dyn_sort-clmn_71-br-dtl}"
&label-clmn_72 = '{&label-clmn_72-br-dtl}'
&sort-clmn_72  = "{&sort-clmn_72-br-dtl}"
&dyn_sort-clmn_72  = "{&dyn_sort-clmn_72-br-dtl}"
&label-clmn_73 = '{&label-clmn_73-br-dtl}'
&sort-clmn_73  = "{&sort-clmn_73-br-dtl}"
&dyn_sort-clmn_73  = "{&dyn_sort-clmn_73-br-dtl}"
&label-clmn_74 = '{&label-clmn_74-br-dtl}'
&sort-clmn_74  = "{&sort-clmn_74-br-dtl}"
&dyn_sort-clmn_74  = "{&dyn_sort-clmn_74-br-dtl}"
&label-clmn_75 = '{&label-clmn_75-br-dtl}'
&sort-clmn_75  = "{&sort-clmn_75-br-dtl}"
&dyn_sort-clmn_75  = "{&dyn_sort-clmn_75-br-dtl}"
&label-clmn_76 = '{&label-clmn_76-br-dtl}'
&sort-clmn_76  = "{&sort-clmn_76-br-dtl}"
&dyn_sort-clmn_76  = "{&dyn_sort-clmn_76-br-dtl}"
&label-clmn_77 = '{&label-clmn_77-br-dtl}'
&sort-clmn_77  = "{&sort-clmn_77-br-dtl}"
&dyn_sort-clmn_77  = "{&dyn_sort-clmn_77-br-dtl}"
&label-clmn_78 = '{&label-clmn_78-br-dtl}'
&sort-clmn_78  = "{&sort-clmn_78-br-dtl}"
&dyn_sort-clmn_78  = "{&dyn_sort-clmn_78-br-dtl}"
&label-clmn_79 = '{&label-clmn_79-br-dtl}'
&sort-clmn_79  = "{&sort-clmn_79-br-dtl}"
&dyn_sort-clmn_79  = "{&dyn_sort-clmn_79-br-dtl}"
&label-clmn_80 = '{&label-clmn_80-br-dtl}'
&sort-clmn_80  = "{&sort-clmn_80-br-dtl}"
&dyn_sort-clmn_80  = "{&dyn_sort-clmn_80-br-dtl}"
&label-clmn_81 = '{&label-clmn_81-br-dtl}'
&sort-clmn_81  = "{&sort-clmn_81-br-dtl}"
&dyn_sort-clmn_81  = "{&dyn_sort-clmn_81-br-dtl}"
&label-clmn_82 = '{&label-clmn_82-br-dtl}'
&sort-clmn_82  = "{&sort-clmn_82-br-dtl}"
&dyn_sort-clmn_82  = "{&dyn_sort-clmn_82-br-dtl}"
&label-clmn_83 = '{&label-clmn_83-br-dtl}'
&sort-clmn_83  = "{&sort-clmn_83-br-dtl}"
&dyn_sort-clmn_83  = "{&dyn_sort-clmn_83-br-dtl}"
&label-clmn_84 = '{&label-clmn_84-br-dtl}'
&sort-clmn_84  = "{&sort-clmn_84-br-dtl}"
&dyn_sort-clmn_84  = "{&dyn_sort-clmn_84-br-dtl}"
&label-clmn_85 = '{&label-clmn_85-br-dtl}'
&sort-clmn_85  = "{&sort-clmn_85-br-dtl}"
&dyn_sort-clmn_85  = "{&dyn_sort-clmn_85-br-dtl}"
&label-clmn_86 = '{&label-clmn_86-br-dtl}'
&sort-clmn_86  = "{&sort-clmn_86-br-dtl}"
&dyn_sort-clmn_86  = "{&dyn_sort-clmn_86-br-dtl}"
&label-clmn_87 = '{&label-clmn_87-br-dtl}'
&sort-clmn_87  = "{&sort-clmn_87-br-dtl}"
&dyn_sort-clmn_87  = "{&dyn_sort-clmn_87-br-dtl}"
&label-clmn_88 = '{&label-clmn_88-br-dtl}'
&sort-clmn_88  = "{&sort-clmn_88-br-dtl}"
&dyn_sort-clmn_88  = "{&dyn_sort-clmn_88-br-dtl}"
&label-clmn_89 = '{&label-clmn_89-br-dtl}'
&sort-clmn_89  = "{&sort-clmn_89-br-dtl}"
&dyn_sort-clmn_89  = "{&dyn_sort-clmn_89-br-dtl}"
&label-clmn_90 = '{&label-clmn_90-br-dtl}'
&sort-clmn_90  = "{&sort-clmn_90-br-dtl}"
&dyn_sort-clmn_90  = "{&dyn_sort-clmn_90-br-dtl}"
&open-query = "run ui-on ('open')."
&open-query-otherwise = "run ui-on ('open')."
&re-move-clmn = "yes"
&mv-brw-default = "yes"
&sort-column-name     = "sort-column-name"
}

/* ***************  Runtime Attributes and UIB Settings  ************** */
ASSIGN
  FRAME {&FRAME-NAME} :SCROLLABLE       = FALSE
 FRAME {&FRAME-NAME} :visible      = FALSE
.
ASSIGN b-exp :POPUP-MENU IN FRAME {&frame-name} = MENU m-export :HANDLE.
ASSIGN b-exp :MENU-MOUSE = 1.

ASSIGN b-scaner :POPUP-MENU IN FRAME {&frame-name} = MENU m-scaner :HANDLE.
ASSIGN b-scaner :MENU-MOUSE = 1.

ASSIGN b-rep :POPUP-MENU IN FRAME {&frame-name} = MENU m-rep :HANDLE.
ASSIGN b-rep :MENU-MOUSE = 1.

ASSIGN b-pay :POPUP-MENU IN FRAME {&FRAME-NAME} = MENU POPUP-MENU-b-pay :HANDLE.
ASSIGN b-pay :MENU-MOUSE = 1.
ASSIGN b-pay :MENU-KEY   = "RETURN":U.

ASSIGN b-f-ed :POPUP-MENU IN FRAME {&FRAME-NAME} = MENU POPUP-MENU-b-f-ed :HANDLE.
ASSIGN b-f-ed :MENU-MOUSE = 1.
ASSIGN b-f-ed :MENU-KEY   = "RETURN":U.

/* ************************  Control Triggers  ************************ */
ON CHOOSE OF MENU-ITEM m-export-1 in menu m-export DO:
  if available t-doc then
   run local-export in this-procedure .
end.
ON CHOOSE OF MENU-ITEM m-export-2 in menu m-export DO:
   if available t-doc then   do:
     if t-doc.doc-type = {&inventory}  then
        run cus/z-tot2.p ( parParentProc, "trn-doc" , "inv" , t-doc.doc-code ) .
     else
        run cus/z-tot2.p ( parParentProc, "trn-doc" , "fact" , t-doc.doc-code ) .
   end.
end.

ON CHOOSE OF MENU-ITEM m-rep-1 in menu m-rep DO:  /* шапки */
  define variable buf-handle as handle no-undo .
  define variable q-handle as handle no-undo .
  buf-handle = buffer t-doc :handle .
  q-handle   = query br-docs :handle .
  run rep/rep-par.w (input  parparentproc , input   frame {&frame-name}:title , input  q-handle , input buf-handle ).
  run UI-on ("open").
  choice = ?.
END.

ON CHOOSE OF MENU-ITEM m-rep-3 in menu m-rep DO:  /* шапки */
    run rep/rep-paro.w
      (input parparentproc
      ,input frame {&frame-name}:title
      ).
    choice = ?.
END.


ON CHOOSE OF MENU-ITEM m-rep-2 in menu m-rep DO:  /* товары */
  run rep/r-docgds.w (parparentproc, objects, frame {&frame-name}:title, partype, parstat, parinternal).
  choice = ?.
END.

/*
ON CHOOSE OF MENU-ITEM m-rep-4 in menu m-rep DO:  /* ттн */
  run rep/r-ttn.p ( input mark-list ).
  choice = ?.
END.
*/

on choose of b-to-inv do: /* в инвентаризацию */
  if not available t-doc then do:
    message "Неправильно выбран документ." view-as alert-box.
    return no-apply.
  end.
  run proc-m_to-inv in this-procedure.
  return no-apply.
end.

on choose of b-to-update do: /* обновить */
run UI-on          in this-procedure ('open').
run init-browse-p  in this-procedure .
end.
on choose of menu-item m_fact-edit-1 in menu POPUP-MENU-b-f-ed do: /* текущий */
  if not available t-doc then do:
    message "Неправильно выбран документ." view-as alert-box.
    return no-apply.
  end.
  run proc-m_fact-edit-1 in this-procedure.
  return no-apply.
end.

on choose of menu-item m_fact-edit-2 in menu POPUP-MENU-b-f-ed do: /* список */
  run proc-m_fact-edit-2 in this-procedure.
  return no-apply.
end.

on choose of b-mark in frame {&frame-name} do:
  RUN local-mark.
  varlog = {&browse-name}:select-next-row ().
  apply "entry" to {&browse-name} in frame {&frame-name}.
end.

/* для устранения подвисания при неправильных нажатиях */
on any-printable of br-docs in frame {&frame-name} do:
  assign
    sch-code:screen-value = sch-code:screen-value + last-event:label.
  apply "entry" to sch-code in frame {&frame-name}.
end.

on ctrl-j of sch-code in frame {&frame-name} /* номеру */
do:
  run proc-find-code in this-procedure(yes, input frame {&frame-name} sch-code).
end.

on return of sch-code in frame {&frame-name} /* номеру */
do:
  run proc-find-code in this-procedure(no, input frame {&frame-name} sch-code).
  return no-apply.
end.

on ctrl-j of sch-date in frame {&frame-name} /* дате */
do:
  run proc-find-date in this-procedure(yes, input frame {&frame-name} sch-date, "doc-date").
end.

on return of sch-date in frame {&frame-name} /* дате */
DO:
  run proc-find-date in this-procedure(no, input frame {&frame-name} sch-date, "doc-date":U).
  return no-apply.
END.

on ctrl-j of sch-fact in frame {&frame-name}
do:
  run proc-find-date in this-procedure(yes, input frame {&frame-name} sch-fact, "fact-date":u).
end.

on return of sch-fact in frame {&frame-name} /* дате факт */
do:
  run proc-find-date in this-procedure(no, input frame {&frame-name} sch-fact, "fact-date":u).
  return no-apply.
end.

on ctrl-j of sch-objtype in frame {&frame-name}
do:
  run proc-find-cli in this-procedure(input frame {&frame-name} sch-objtype, input frame {&frame-name} sch-objcode).
end.

on return of sch-objtype in frame {&frame-name}
do:
  run proc-find-cli in this-procedure(input frame {&frame-name} sch-objtype, input frame {&frame-name} sch-objcode).
  return no-apply.
end.

on ctrl-j of sch-objcode in frame {&frame-name}
do:
  run proc-find-cli in this-procedure(input frame {&frame-name} sch-objtype, input frame {&frame-name} sch-objcode).
end.

on return of sch-objcode in frame {&frame-name}
do:
  run proc-find-cli in this-procedure(input frame {&frame-name} sch-objtype, input frame {&frame-name} sch-objcode).
  return no-apply.
end.

on ctrl-j of sch-sum in frame {&frame-name}
do:
  run proc-find-sum in this-procedure(input frame {&frame-name} sch-sum).
end.

on return of sch-sum in frame {&frame-name}
do:
  run proc-find-sum in this-procedure(input frame {&frame-name} sch-sum).
  return no-apply.
end.

on choose of b-add in frame {&frame-name} /* Добав */
do:

  vardoc-mode = {&add-def}.
  run local-add in this-procedure no-error.
  if pardoc-rec <> ? then do:
    reposition {&browse-name} to recid pardoc-rec no-error.
  end.
end.

    ON ROW-DISPLAY OF br-docs IN FRAME {&frame-name}
      DO:
        define buffer color_inv-doc-attr for ub.inv-doc-attr .  
        if AVAILABLE (t-doc) and t-doc.status_ = {&inquiry} then 
        do:   
          find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
            ub.inv-doc-attr.attr-code = "isManual" and ub.inv-doc-attr.attr-value = string(true) no-error .
          if available (ub.inv-doc-attr) then 
          do:  
            find first color_inv-doc-attr no-lock where color_inv-doc-attr.doc-code = t-doc.doc-code and
            color_inv-doc-attr.attr-code = "ManualTSD" and ub.inv-doc-attr.attr-value <> "" no-error .
            if available (color_inv-doc-attr) then do:
            do ii = 1 to extent (bcol):  
              if valid-handle (bcol[ii]) 
                then 
              do:
                assign
                  bcol[ii]:fgcolor = BROWN_COLOR.
              end.
            end.               
            end.
            else do:
            do ii = 1 to extent (bcol):  
              if valid-handle (bcol[ii]) 
                then 
              do:
                assign
                  bcol[ii]:fgcolor = BLUE_COLOR.
              end.
            end.
            end.
          end.
          find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
            ub.inv-doc-attr.attr-code = "isManualError" and ub.inv-doc-attr.attr-value = string(true) no-error .
          if available (ub.inv-doc-attr) then 
          do:  
            
            do ii = 1 to extent (bcol):  
              if valid-handle (bcol[ii]) 
                then 
              do:
                assign
                  bcol[ii]:fgcolor = RED_COLOR.
              end.
            end.
          end.      
          find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
            ub.inv-doc-attr.attr-code = "invMultDevice" and ub.inv-doc-attr.attr-value = string(true) no-error .
          if available (ub.inv-doc-attr) then 
          do:  
            find first color_inv-doc-attr no-lock where color_inv-doc-attr.doc-code = t-doc.doc-code and
            color_inv-doc-attr.attr-code = "MultiTSD" and ub.inv-doc-attr.attr-value <> "" no-error .
            if available (color_inv-doc-attr) then do:
            do ii = 1 to extent (bcol):  
              if valid-handle (bcol[ii]) 
                then 
              do:
                assign
                  bcol[ii]:fgcolor = BROWN_COLOR.
              end.
            end.               
            end.
            else do:
            
            do ii = 1 to extent (bcol):  
              if valid-handle (bcol[ii]) 
                then 
              do:
                assign
                  bcol[ii]:fgcolor = DARK_BLUE_COLOR.
              end.
              end.
            end.
          end.       
        end.
      end.

on choose of b-copy in frame {&frame-name}
do:
  vardoc-mode = {&add-copy}.
  run local-add in this-procedure no-error.
  if pardoc-rec <> ? then do:
    reposition {&browse-name} to recid pardoc-rec no-error.
  end.
end.

ON CHOOSE OF b-chg IN FRAME {&frame-name} /* Изм */
DO:
  run proc-b-chg in this-procedure.
END.

ON CHOOSE OF b-del IN FRAME {&frame-name} /* Удал */ DO:
  run proc-b-del no-error .
  if error-status :error then return no-apply.
  run UI-on ("open").
end.

ON CHOOSE OF b-unrv IN FRAME {&frame-name} /* {&rsrv-dtl_action_reserv} */
DO:
  run proc-b-unrv in this-procedure.
END.

on choose of b-sch in frame {&frame-name} do:
  run proc-b-sch in this-procedure.
end.

ON CHOOSE OF b-akt IN FRAME {&frame-name} /* Просмотр авт переоценки */
DO:
  run proc-b-akt no-error.
  if error-status:error then return no-apply.
END.

ON CHOOSE OF b-lkp IN FRAME {&frame-name} /* Просмотр */
DO:
  run proc-b-lkp no-error.
  if error-status:error then return no-apply.
END.

ON CHOOSE OF b-print IN FRAME {&frame-name} /* {&print} */
DO:
  run proc-b-print no-error.
  if error-status:error then return no-apply.
END.

ON CHOOSE OF b-history IN FRAME {&frame-name} /* История */
DO:
  run proc-history no-error.
  if error-status :error then do: return no-apply. end.
END.

ON CHOOSE OF b-bc IN FRAME {&frame-name} /* Бар-код */
DO:
  if not available t-doc then do:
    message "Неправильный выбор документа.".
    return no-apply.
  end.
  pardoc-rec = recid (t-doc).
  run rep/tick-doc.p (parparentproc, pardoc-rec, "trn", 1, no, no).
  apply "entry" to br-docs in frame {&frame-name}.
END.


on choose of menu-item m_gen-6 in menu popup-menu-b-pay do: /* Фин обязательства */
  
  define variable g-log as logical no-undo .
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-liability_add-def':U
  {&cntxt-firm}
  par-host-code
  '':U
  0
  0
  0
  0
  true
  g-log
}
if not g-log then  return .
  run proc-m_gen-6 no-error .
  if error-status :error then return no-apply.
end.

on choose of menu-item m_gen-22 in menu popup-menu-b-pay do: /* Фин обязательства */
  run proc-m_gen-22 no-error .
  if error-status :error then return no-apply.
end.


on choose of menu-item m_gen-8 in menu popup-menu-b-pay do:
  run proc-m_gen-8 no-error .
  if error-status :error then return no-apply.
  assign
    pardoc-rec = recid(t-doc).
  run UI-on ("open").
end.

on choose of menu-item m_gen-9 in menu popup-menu-b-pay do:
  run proc-m_gen-9 no-error .
  if error-status :error then return no-apply.
  assign
    pardoc-rec = recid(t-doc).
  run UI-on ("open").
end.

on choose of menu-item m_gen-19 in menu popup-menu-b-pay do:
  run proc-m_gen-19 no-error .
  if error-status :error then return no-apply.
  assign
    pardoc-rec = recid(t-doc).
  run UI-on ("open").
end.


on choose of menu-item m_gen-11 in menu popup-menu-b-pay do:
  run proc-m_gen-11 no-error .
  if error-status :error then return no-apply.
  assign
    pardoc-rec = recid(t-doc).
  run UI-on ("open").
end.

on choose of menu-item m_gen-12 in menu popup-menu-b-pay do:
  run proc-m_gen-12 no-error .
  if error-status :error then return no-apply.
  assign
    pardoc-rec = recid(t-doc).
  run UI-on ("open").
end.

on choose of menu-item m_gen-20 in menu popup-menu-b-pay do:
  run proc-m_gen-20 no-error .
  if error-status :error then return no-apply.
  assign
    pardoc-rec = recid(t-doc).
  run UI-on ("open").
end.


on choose of menu-item m_gen-13 in menu popup-menu-b-pay do:
  run proc-m_gen-13 no-error .
  if error-status :error then return no-apply.
  assign
    pardoc-rec = recid(t-doc).
  run UI-on ("open").
end.

on choose of menu-item m_gen-14 in menu popup-menu-b-pay do:
  run proc-m_gen-14 no-error .
  if error-status :error then return no-apply.
  assign
    pardoc-rec = recid(t-doc).
  run UI-on ("open").
end.

on choose of menu-item m_gen-21 in menu popup-menu-b-pay do:
  run proc-m_gen-21 no-error .
  if error-status :error then return no-apply.
  assign
    pardoc-rec = recid(t-doc).
  run UI-on ("open").
end.

on choose of menu-item m_gen-15 in menu popup-menu-b-pay do:
  run proc-m_gen-15 no-error .
  if error-status :error then return no-apply.
  assign
    pardoc-rec = recid(t-doc).
  run UI-on ("open").
end.

on choose of menu-item m_gen-16 in menu popup-menu-b-pay do:
  run proc-m_gen-16 no-error .
  if error-status :error then return no-apply.
  assign
    pardoc-rec = recid(t-doc).
  run UI-on ("open").
end.

on choose of menu-item m_gen-17 in menu popup-menu-b-pay do:
  run proc-m_gen-17 no-error .
  if error-status :error then return no-apply.
  assign
    pardoc-rec = recid(t-doc).
  run UI-on ("open").
end.

on choose of menu-item m_gen-18 in menu popup-menu-b-pay do:
  run proc-m_gen-18 no-error .
  if error-status :error then return no-apply.
  assign
    pardoc-rec = recid(t-doc).
  run UI-on ("open").
end.

on choose of menu-item m_gen-23 in menu popup-menu-b-pay do:
  if crUtdReturn(t-doc.doc-code)
  then 
     message "Созданы документы УПД" 
     view-as alert-box.
  else
     message "По документу нет марок" 
     view-as alert-box.
  run local-value-changed .
  {&SetCursorno}
end.


ON CHOOSE OF b-ext IN FRAME {&frame-name} /* Запуск внешней программы */
DO:
  run proc-b-ext no-error .
  if error-status :error then return no-apply.
END.

ON CHOOSE OF b-rep IN FRAME {&frame-name} /* {&reports} */
DO:
  if choice = ? then do:
    run gbl/pop-up.p (self:handle, no) no-error.
    if error-status:error then return no-apply.
  end.
END.

on choose of b-exp in frame {&frame-name} /* Экспорт */
do:
  if choice = ? then do:
    run gbl/pop-up.p (self:handle, no) no-error.
    if error-status:error then return no-apply.
  end.
end.

ON CHOOSE OF b-sel IN FRAME {&frame-name} /* {&choose} */
DO:
 run local-sel in this-procedure.
END.

ON CHOOSE OF b-covdocs IN FRAME {&frame-name} /* Сопроводительные документы */
DO:
  run proc-b-covdocs no-error .
  if error-status :error then return no-apply.
END.

ON CHOOSE OF b-quit IN FRAME {&frame-name} /* Выход */
DO:
define variable v-list-new as character no-undo .
assign
  v-list-new = v-order-column +  {&delim-par}
              + v-spis-size  +  {&delim-par}
              + v-spis-vis   +  {&delim-par}
              .
  assign
  pardoc-rec = ?
  mark-list = '':U
  .
END.

ON CHOOSE OF b-uf IN FRAME {&frame-name} /* Редактирование броуса */
DO:
  run gbl/vi-coll.w ( input Parparentproc, input this-procedure , input {&uf-all-docs} , input  head-col ) .
END.

ON CHOOSE OF b-filter-ext IN FRAME {&frame-name} /* Редактирование броуса */
DO:

  if r-2 = 1 then r-2 = 2 .
             else r-2 = 1.

  if r-2 = 2 then do:
    /* установим расширенный фильтр красный */

     find first doc-list where doc-list.doc-code = "" no-error .
     if available doc-list then delete doc-list.
     release doc-list .
    run str/fext-trn.w
        ( parparentproc ,
        v-cntxt-host-code-obj,
        v-cntxt-obj-type,
        v-cntxt-obj-code
        ).
    if not can-find (first doc-list ) then  do:
        create doc-list.
        doc-list.doc-code = "" .
        release doc-list .
        message "Расширенный фильтр пуст!" view-as alert-box information .
    end.
    b-filter-ext:LOAD-IMAGE ("cmp/b-sche.bmp") .
     find last doc-list-hist.

     b-filter-ext:tooltip =  doc-list-hist.des .

  end.
  else do:
  /* снять фильтр  синий */
     b-filter-ext:LOAD-IMAGE ("cmp/b-schef.bmp") .
     b-filter-ext:tooltip = "Расширенный фильтр не установлен" .
  end.
  run OpenBr in this-procedure ( yes, no, '':U, 'open':U) .
END.

ON CHOOSE OF MENU-ITEM m-scaner-file in menu m-scaner DO:

define variable v-blob-uniq-key-rec as character no-undo .
define variable v-part-num as integer   no-undo .
define variable v-blob-db-num as integer   no-undo .
define variable v-int64-id as int64 no-undo .
define variable v-file-imafe-name as character no-undo .

  if not available t-doc then return .
  message
    'Вы хотите изображение из файла  записать  в БД по документу №' t-doc.doc-code
    '?'
    view-as alert-box question
    buttons yes-no
    update v-ok as logical
    .
    if v-ok = false then return .
      define variable glog as logical   no-undo .

      system-dialog get-file v-file-imafe-name
        title "Выберите файл с изображением"
            filters "jpg" "*.jpg"
            update glog.
      if not glog then return.
{&SetCursorWait}
    run gen-key-rec in this-procedure (
         input  {&table_trn-doc}
        ,input  buffer t-doc:handle
        ,output v-blob-uniq-key-rec ).

      v-blob-db-num = ? .
      v-int64-id = 0 .

      run gbl/file2blb.p ( input {&add-def}
                          ,input  "yes"
                          ,input (buffer t-doc:handle)
                          ,input v-blob-uniq-key-rec
                          ,input {&blob-trn-doc-image} /*p-field-*/
                          ,input {&blob-trn-doc-image}
                          ,input-output v-part-num
                          ,input {&lob-res-data} /*p-resource-type*/
                          ,input-output v-blob-db-num
                          ,input-output v-int64-id
                          ,input v-file-imafe-name
                          ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "Ошибка записи BLOB в БД"
          view-as alert-box error
        .
      end.
run local-value-changed .
{&SetCursorno}
END.


ON CHOOSE OF MENU-ITEM m-scaner-add in menu m-scaner DO:

define variable v-blob-uniq-key-rec as character no-undo .
define variable v-part-num as integer   no-undo .
define variable v-blob-db-num as integer   no-undo .
define variable v-int64-id as int64 no-undo .
define variable p-exe-name as character no-undo .
define variable p-fl-name as character no-undo .
define variable p-jpg-name as character no-undo .

  p-exe-name = string(session :temp-directory) + 'qscan.exe' .
  p-fl-name  = string(session :temp-directory) + 'qs_done.dat' .
  p-jpg-name = string(session :temp-directory) + 'qs.jpg' .

  if not available t-doc then return .

  message
    'Вы хотите сканировать бумажный носитель и записать его изображение в БД по документу №' t-doc.doc-code
    '?'
    view-as alert-box question
    buttons yes-no
    update v-ok as logical
    .

    if v-ok = false then return .
    assign
      FILE-INFO :FILE-NAME = p-exe-name
    .
    IF INDEX(FILE-INFO:FILE-TYPE, "F")  = 0 then  do:
      message 'Не обнаружено программы для сканирования '
      p-exe-name
      view-as alert-box information .
      return .
    end.

{&SetCursorWait}
    define variable chr-res    as character no-undo .
    define variable v-cmd-line as character no-undo .
    define variable v-tmp-f as character no-undo .
    v-cmd-line =  substitute(p-exe-name + ' ShowUI filename &1&2&1' ,  {&double-quote} , p-jpg-name ) .

    run gbl/syn6.p
      (input v-cmd-line
      ,input p-fl-name
      ,input "Ждите! ..."
      ,output chr-res
      ) no-error .

    run gen-key-rec in this-procedure (
         input  {&table_trn-doc}
        ,input  buffer t-doc:handle
        ,output v-blob-uniq-key-rec ).

      v-blob-db-num = ? .
      v-int64-id = 0 .
      run gbl/file2blb.p ( input {&add-def}
                          ,input  "yes"
                          ,input (buffer t-doc:handle)
                          ,input v-blob-uniq-key-rec
                          ,input {&blob-trn-doc-image} /*p-field-*/
                          ,input {&blob-trn-doc-image}
                          ,input-output v-part-num
                          ,input {&lob-res-data} /*p-resource-type*/
                          ,input-output v-blob-db-num
                          ,input-output v-int64-id
                          ,input p-jpg-name
                          ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "Ошибка записи BLOB в   БД"
          view-as alert-box error
        .
      end.
      run local-value-changed .
{&SetCursorno}
END.

ON CHOOSE OF MENU-ITEM m-scaner-del in menu m-scaner DO:
/* пока это только удаление временного файла  */

define variable v-blob-uniq-key-rec as character no-undo .
define variable v-part-num as integer   no-undo .
define variable v-blob-db-num as integer   no-undo .
define variable v-int64-id as int64 no-undo .
define variable p-jpg-name as character no-undo .

p-jpg-name = string(session :temp-directory) + 'qs.jpg' .

if not available t-doc then return .
{&SetCursorWait}
 os-delete value( string(session :temp-directory) + 'tempBlob.jpg'  ) .

    run gen-key-rec in this-procedure (
         input  {&table_trn-doc}
        ,input  buffer t-doc:handle
        ,output v-blob-uniq-key-rec ).

      v-blob-db-num = ? .
      v-int64-id = 0 .
      v-part-num = 1 .

      run gbl/file2blb.p ( input {&deletion}
                          ,input  "leave"
                          ,input (buffer t-doc:handle)
                          ,input v-blob-uniq-key-rec
                          ,input {&blob-trn-doc-image} /*p-field-*/
                          ,input {&blob-trn-doc-image}
                          ,input-output v-part-num
                          ,input {&lob-res-data} /*p-resource-type*/
                          ,input-output v-blob-db-num
                          ,input-output v-int64-id
                          ,input p-jpg-name
                          ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "Ошибка записи BLOB в   БД"
          view-as alert-box error
        .
      end.

      run local-value-changed .
{&SetCursorno}
END.

ON CHOOSE OF MENU-ITEM m-scaner-lkp in menu m-scaner DO:

define variable v-blob-uniq-key-rec as character no-undo .
define variable v-part-num as integer   no-undo .
define buffer   buf_blob-bind for ub.blob-bind  .
v-part-num = 1.

  if not available t-doc then return .

    run gen-key-rec in this-procedure (
         input  {&table_trn-doc}
        ,input  buffer t-doc:handle
        ,output v-blob-uniq-key-rec ).
    find first  buf_blob-bind no-lock where
                buf_blob-bind.uniq-key-rec = v-blob-uniq-key-rec and
                buf_blob-bind.field-name_  = {&blob-trn-doc-image} and
                buf_blob-bind.part-num     = v-part-num
    no-error .
    if not available buf_blob-bind then do:
       message 'Нет изображения по документу' t-doc.doc-code  view-as alert-box information .
       return .
    end.

define variable v-blob-db-num as integer no-undo .
define variable v-int64-id as int64 no-undo .

v-blob-db-num = buf_blob-bind.db-num   .
v-int64-id    = buf_blob-bind.int64-id .

    run gbl/file2blb.p ( input {&lookup}
                        ,input  yes
                        ,input (buffer t-doc:handle)
                        ,input v-blob-uniq-key-rec
                        ,input {&blob-trn-doc-image} /*p-field-*/
                        ,input {&blob-trn-doc-image}
                        ,input-output v-part-num
                        ,input {&lob-res-data} /*p-resource-type*/
                        ,input-output v-blob-db-num
                        ,input-output v-int64-id
                        ,input ?
                        ) no-error .
      if error-status :error then do:
         message
           vss-workfile vss-revision vss-description skip
           error-status :get-message(1) skip
           return-value skip
           "Ошибка при чтении из BLOB"
           view-as alert-box error
         .
      end.
END.

on entry of ed-notes in frame {&frame-name}
do:
  run entry-notes in this-procedure.
end.

on leave of ed-notes in frame {&frame-name}
do:
  run local-notes.
end.

on return, mouse-select-dblclick of ed-notes in frame {&frame-name} do:
  apply "entry" to br-docs in frame {&frame-name}.
  return no-apply.
end.

on return, mouse-select-dblclick of br-docs in frame {&frame-name} do:
  apply "choose" to b-lkp in frame {&frame-name}.
end.

on value-changed of br-docs do:
  run local-value-changed.
end.

{ str/trn-clos.i }

{ gbl/hot-key.i b-print }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-close }
{ gbl/hot-key.i b-open }
{ gbl/hot-key.i b-unrv }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-mark }
/* ***************************  Main Block  *************************** */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.
/* F1 */
{ gbl/app_help.i }
 /* F5 */
{ gbl/brwrefre.i " assign v-doc-rec = ?. ~
if available t-doc then v-doc-rec = recid(t-doc). ~
run UI-on in this-procedure ('open') . ~
reposition br-docs to recid v-doc-rec no-error. ~
apply 'entry' to br-docs. " }


main-block:
do on error   undo main-block, leave main-block
   on end-key undo main-block, leave main-block:


  define variable tt as integer   no-undo .
  tt = time.
  run local-start-main in this-procedure.
  run local-conf-rd    in this-procedure.

run init-browse-p  in this-procedure .
{ gbl/mv-clmn.i
 &ext-col = 99
 &frame-name = "{&frame-name}"
 &browse-name = "{&browse-name}"
 &table-name = "t-doc"
 &start-column = 1
 &prev-order-column_1 = v-order-column
 &prev-order-column-condition_1 = " true = true "
}

  run local-enable     in this-procedure.
  /* Просмотр продажи возможен ? */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_sale_lookup':U
    {&cntxt-object}
    par-host-code
    par-obj-type
    par-obj-code
    0
    0
    0
    false
    v-sale
  }

/*-- Проверка, нужна ли кнопка для внешней программы. Если нужна, включаем b-ext ---*/
/*--------------------Проверка Нужна ли кнопка СОЗДАНИЕ РАСХОДНЫХ ВНУТРЕННИХ ЗАПРОСОВ------------------------------- */
run create-button  in this-procedure .
  extent (bcol) = ?.
  hbrowse = browse {&BROWSE-NAME}:handle.
  extent (bcol) = hbrowse:num-columns.
  bcol[1] = hbrowse:first-column.
  do ii = 1 to extent (bcol).  
    bcol[ii] = hbrowse:get-browse-column (ii).
  end.
run UI-on          in this-procedure ('open').
/* message time - tt. */
WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-docs.
end.

RUN disable_UI.

/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME {&frame-name}.
END PROCEDURE.

PROCEDURE UI-on :
define input parameter fnc as character no-undo.
assign {&sort-clmn_32-br-dtl}:read-only in browse {&browse-name} = yes.
/* ------------------------------------------------------------------------------------------------------------ */
if fnc = "open" then do:
  frame {&frame-name}:title = "ВСЕ  ДОКУМЕНТЫ".
  sch-num = 0.
  hide sch-num in frame {&frame-name}.
end.
else do:
  assign
    pardoc-rec = ?.
end.
&scop list-valid-modes '{&bef-work},{&bef-company},{&bef-g___object},{&bef-choose},{&bef-type},{&bef-status},~
{&bef-flag},{&bef-in_},{&bef-shipping},invert,status-all,status-all-hold':U
if lookup( parlist-mode, {&list-valid-modes} ) > 0 then do:
  run enb-1 (fnc).
end.
else
if lookup( parlist-mode, '{&bef-invoice}-host,{&bef-invoice}-obj':U ) = 0 then do:
  run enb-2 (fnc).
end.

if fnc <> "open"   and
   available t-d-b then do:
  assign
    pardoc-rec = recid (t-d-b).
end.
run openbr( yes, no, '':U, fnc).
end procedure.

PROCEDURE local-mark:
  if not available t-doc then do:
    message "Неправильный выбор строки.".
    return error.
  end.
  { gbl/markstrn.i t-doc mark-list }
  {&browse-name}:refresh() in frame {&frame-name}.
END PROCEDURE.

procedure proc-b-sch :
assign
  tbl      = 'trn-doc'
  join-tbl = 't-doc'
  fld      = ""
  lab      = ""
  spr      = ""
  dim      = '0'
.
run fltfield-add in this-procedure('doc-type', 'Тип', 'trn-type', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статус', 'trn-stat', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('flag_', 'OK', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-code', 'Номер', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-date', 'Дата док-та', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', 'Дата факт', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-date', 'Дата смены', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-name', 'Номер смены', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-num', 'Порядок смены', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-type{&delim-flt}cli-code', 'Контрагент', 'cli', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ext-doc-type', 'Расширенный тип', 'ext-doc-type', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
if parlist-mode = {&work} or
   parlist-mode = {&company} or
   parlist-mode = {&confuse} or
   parlist-mode = {&acc-office-all} or
   parlist-mode = {&ext-acc-office-all} or
   parlist-mode = "ВАЛЮТА" or
   parlist-mode = "МЕНЕДЖЕР" or
   parlist-mode = "КЛАДОВЩИК" or
   parlist-mode = {&client-cmp} or
   parlist-mode = {&invoice} + "-host" then do:
run fltfield-add in this-procedure('obj-type', 'Тип объекта', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
end.
run fltfield-add in this-procedure('rsrv-date', 'Резерв отгрузка', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('boss', 'Менеджер', 'cli',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-qnty', 'Кол-во по док.', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-qnty', 'Кол-во факт', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-doc', 'Сумма (вал)', '',     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-calc', 'Скидка (вал)', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-rubl', 'Сумма ({&abbr_rub})', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt-rubl', 'Скидка ({&abbr_rub})', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt-pc', 'Скидка (%)', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt-type', 'Тип скидки', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-fact', 'Сумма (факт)', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-code', 'Код оплаты', 'pay',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('internal', 'Внутренняя', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-name', 'Название контр-а', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('creid', 'Создал', 'usr',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('agnt', 'Исполнитель', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('wrkr', 'Кладовщик', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('out-code', 'На док-т', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('base-rate', 'Курс', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('inv-num', 'Инвойс', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ord-num', 'Заказ', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('office', 'Услуги', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('print-rubl', '{&abbr_rublevy_firstshift}', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ship-num', 'Отгрузка', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ship-date', 'Дата отгрузки', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ov', 'Акт', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-ov', 'Сумма акта', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('exch-code', 'Валюта', 'curr',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-num', 'Порядок закрытия', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('PS', 'Примечание', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('purch-code', 'Тип приобретения', 'purch-code',
                                                        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('reason-code',   'Код основания (причины)', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
   ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
   ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
run gbl/filter.w ( parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
RUN OpenBr in this-procedure ( yes, no, '':U, 'open':U).
END. /* Filter-Block */
end procedure.

procedure OpenBr :
define input parameter p-open-query     as logical   no-undo .
define input parameter p-find-next      as logical   no-undo .
define input parameter p-find-condition as character no-undo .
define input parameter fnc              as character no-undo.


case sort-column-name :
when "" then do:
assign
  sort-column-phrase = ""
.
end.
otherwise do:
assign
  sort-column-phrase = "by " + sort-column-name
.
end.
end case.

assign
  parschdoc-code  = (if available sch-inv  then sch-inv.doc-code   else ?)
  parschcurr-code = (if available sch-curr then sch-curr.curr-code else ?)
  parschobj-code  = (if available sch-pay  then sch-pay.obj-code   else ?)
  parschcli-type  = (if available sch-cli  then sch-cli.obj-type   else ?)
  parschcli-code  = (if available sch-cli  then sch-cli.obj-code   else ?)
.


&scop flt-open-open-query open query br-docs for each t-doc

&scop flt-open-dyn_open-query  FOR EACH t-doc

&scop flt-open-query-handle query br-docs:handle

&scop flt-open-find-buffer-name t-doc

&scop flt-open-open-query-tail   , first temp-trn-doc where (r-2 = 1 or t-doc.doc-code = temp-trn-doc.doc-code )

&scop flt-open-dyn_open-query-tail   substitute(' , first temp-trn-doc where (&1 = 1 or t-doc.doc-code = temp-trn-doc.doc-code ) ' , r-2 )

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-debug-file

&scop flt-open-indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name t-doc

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid pardoc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-def find first temp-trn-doc no-error .  r-2 = 1.


define variable l-open-query as logical   no-undo .
if v-is-lgas then do:

  run modes-lgas (
    p-open-query     ,
    p-find-next      ,
    p-find-condition ,
    fnc              ).
end.
  else do:
  if can-do ({&work} + "," + {&company} + "," + {&g___object} + "," + {&choose}, parlist-mode) then do:
    run modes-1-a (
      p-open-query     ,
      p-find-next      ,
      p-find-condition ,
      fnc              ).
  end.
  else do:
    if can-do ({&type} + "," + {&status} + "," + 'status-all' +  "," + 'status-all-hold' + "," + {&flag} + "," + {&in_} + "," + {&shipping} + "," + "invert":u, parlist-mode) then do:
      run modes-1-b (
        p-open-query     ,
        p-find-next      ,
        p-find-condition ,
        fnc              ).
    end.
    else do:
      if can-do( {&invoice} + "-host," + {&invoice} + "-obj"  + ",no-def,yes-gen-incfo,yes-gen-expfo,yes-gen-fo,yes-gen-buyer" , parlist-mode ) then do:
        run modes-2 (
          p-open-query     ,
          p-find-next      ,
          p-find-condition ,
          fnc              ).
      end.
      else do:
        if parlist-mode = "client-income":u then do:
          if fnc = "open" then do:
            assign
              frame {&frame-name}:title = "Приходы от контрагента : " + sch-cli.obj-name
              objects = 1
            .
            assign filter-point = parlist-mode + {&delim-par} + parlist-mode + {&delim-par} + "yes".
  
  
            { gbl/fltopend.i
              &where-cond = "t-doc.cli-type  = parschcli-type  ~
                           and t-doc.cli-code  = parschcli-code ~
                           and t-doc.host-code = par-host-code  ~
                           and t-doc.ext-doc-type = parext-doc-type ~
                             "
              &dyn_where-cond = " substitute ( ' ~
                               t-doc.cli-type  = &1&2&1  ~
                           and t-doc.cli-code  = &3 ~
                           and t-doc.host-code = &4  ~
                           and t-doc.ext-doc-type = &1&5&1 ~
                           ', ~{&double-quote~}, parschcli-type , parschcli-code, par-host-code , parext-doc-type  )"
  
               &use-indFIRST = " use-index cli-date "
              }
          end.
        end.
        else do:
          run modes-3 (
            p-open-query     ,
            p-find-next      ,
            p-find-condition ,
            fnc              ).
        end.
      end.
    end.
  end.
end.
if pardoc-rec <> ? then do:
  if fnc <> "open" then do:
    sch-num = sch-num + 1.
    disp sch-num with frame {&frame-name}.
  end.
  reposition br-docs to recid pardoc-rec no-error.
end.
else do:
  if fnc <> "open" then do:
    message "Документ не найден.".
    sch-num = 0.
  end.
end.
run waitfram-hide in this-procedure .
apply "value-changed" to br-docs in frame {&frame-name}.
apply "entry" to br-docs.

end procedure.

procedure modes-3:
define input parameter p-open-query     as logical   no-undo .
define input parameter p-find-next      as logical   no-undo .
define input parameter p-find-condition as character no-undo .
define input parameter fnc              as character no-undo.
    case parlist-mode :
      /* ---------------------------------------------------------------------------------------------------------------- */
      when {&confuse} then do:
        if fnc = "open" then do:
          if p-open-query then frame {&frame-name}:title = "Документы, мешающие инвентаризации № " + string (sch-inv.doc-code).
          assign
          p-par = sch-inv.doc-code .
          assign
           filter-point = "мешают" + {&delim-par} + "мешают" + {&delim-par} + "yes".
          { gbl/fltopend.i
            &where-cond = " t-doc.inv-num = p-par "
            &dyn_where-cond = " substitute ( ' t-doc.inv-num  = &1&2&1 ', ~{&double-quote~}, p-par )"
            &use-ind    = " "
          }
        end.
      end.

      when "no-gen-fo":u then do:
        if fnc = "open" then do:

            if p-open-query then frame {&frame-name}:title = "Нет финансовых обязательств по фирме " + string(par-host-code).
            objects = 2.
          assign
            filter-point = parlist-mode + {&delim-par} + parlist-mode + {&delim-par} + "yes".
          { gbl/fltopend.i
            &where-cond = "t-doc.host-code     = par-host-code and
                           t-doc.cr-incorexpfo = no and
                           t-doc.status_ = {&fact}
                       "
            &dyn_where-cond = " substitute ( ' ~
                                t-doc.status_           = &1&2&1  ~
                                and t-doc.host-code     = &3 ~
                                and t-doc.cr-incorexpfo = no ~
                                ', ~{&double-quote~}, ~{&fact~} , par-host-code )"

            &use-ind = " "
          }
        end.

      end.
      when "no-gen-incfo":u then do:
        if fnc = "open" then do:

            if p-open-query then frame {&frame-name}:title = "Нет сгенеренных финансовых обязательств поставки по фирме " + string(par-host-code).
            objects = 2.
          assign
            filter-point = parlist-mode + {&delim-par} + parlist-mode + {&delim-par} + "yes".
          { gbl/fltopend.i
            &where-cond = "t-doc.host-code  = par-host-code and
                           t-doc.need-incfo = 1 and
                           t-doc.cr-incfo   = no and
                           t-doc.status_    = {&fact}
                       "
            &dyn_where-cond = " substitute ( ' ~
                                t-doc.status_        = &1&2&1  ~
                                and t-doc.host-code  = &3 ~
                                and t-doc.cr-incfo   = no ~
                                and t-doc.need-incfo = 1 ~
                                ', ~{&double-quote~}, ~{&fact~} , par-host-code )"

            &use-ind = "  "
          }
        end.
      end.
      when "no-gen-expfo":u then do:
        if fnc = "open" then do:

            if p-open-query then frame {&frame-name}:title = "Нет сгенеренных финансовых обязательств по реализации по фирме " + string(par-host-code).
            objects = 2.
          assign
            filter-point = parlist-mode + {&delim-par} + parlist-mode + {&delim-par} + "yes".
          { gbl/fltopend.i
            &where-cond = "t-doc.host-code  = par-host-code and
                           t-doc.need-expfo = 1 and
                           t-doc.cr-expfo   = no and
                           t-doc.status_    = {&fact}
                       "
            &dyn_where-cond = " substitute ( ' ~
                            t-doc.host-code  = &3 ~
                        and t-doc.need-expfo = 1 ~
                        and t-doc.cr-expfo   = no ~
                        and t-doc.status_    = &1&2&1  ~
                        ', ~{&double-quote~}, ~{&fact~} , par-host-code )"

            &use-ind = "  "
          }
        end.
      end.
      when "no-gen-buyer":u then do:
        if fnc = "open" then do:

            if p-open-query then frame {&frame-name}:title = "Нет сгенеренных финансовых обязательств по покупателям по фирме " + string(par-host-code).
            objects = 2.
          assign
            filter-point = parlist-mode + {&delim-par} + parlist-mode + {&delim-par} + "yes".
          { gbl/fltopend.i
            &where-cond = "t-doc.host-code  = par-host-code and
                           t-doc.need-buyer = 1 and
                           t-doc.cr-fo-buyer = no and
                           t-doc.status_    = {&fact}
                       "
            &dyn_where-cond = " substitute ( ' ~
                            t-doc.host-code   = &3 ~
                        and t-doc.need-buyer  = 1 ~
                        and t-doc.cr-fo-buyer = no ~
                        and t-doc.status_    = &1&2&1  ~
                        ', ~{&double-quote~}, ~{&fact~} , par-host-code )"

            &use-ind = "  "
          }
        end.
      end.

      when {&ext-acc-office-all} then do:
        if fnc = "open" then do:

          if p-open-query then frame {&frame-name}:title = "НАКЛАДНЫЕ  БЕЗ  ПРОВОДОК  по ФИРМЕ           (кроме продаж)".
          objects = 1.
          assign
            filter-point = parlist-mode + {&delim-par} + parlist-mode + {&delim-par} + "yes".
          { gbl/fltopend.i
            &where-cond = " t-doc.status_ = {&fact} ~
                        and t-doc.bge-date = ?      ~
                        and t-doc.host-code = par-host-code ~
                        and t-doc.discnt-type <> {&cash-desk} ~
                        "

            &dyn_where-cond = " substitute ( ' ~
                            t-doc.host-code   = &3 ~
                        and t-doc.bge-date    = date(?) ~
                        and t-doc.status_     = &1&2&1  ~
                        and t-doc.discnt-type  <> &1&4&1  ~
                        ', ~{&double-quote~}, ~{&fact~} , par-host-code , ~{&cash-desk~} )"

            &use-indFIRST = " use-index bge-host "
          }
        end.
      end.
      when "ВАЛЮТА" then do:
        if fnc = "open" then do:

           if p-open-query then  frame {&frame-name}:title = "Валюта : " + sch-curr.curr-abbr + " " + sch-curr.curr-name.
          assign
            filter-point = parlist-mode + {&delim-par} + parlist-mode + {&delim-par} + "yes".
          { gbl/fltopend.i
            &where-cond = " t-doc.exch-code = sch-curr.curr-code "
            &dyn_where-cond = " substitute ( ' t-doc.exch-code = &1 ', sch-curr.curr-code  )"
            &use-ind    = " "
          }
        end.
      end.
      when "ОПЛАТА" then do:
        if fnc = "open" then do:

          if p-open-query then   frame {&frame-name}:title = "Оплата : " + sch-pay.obj-name.
          assign
            filter-point = parlist-mode + {&delim-par} + parlist-mode + {&delim-par} + "yes".
          { gbl/fltopend.i
            &where-cond = " t-doc.pay-code = sch-pay.obj-code "
            &dyn_where-cond = " substitute ( ' ~
                          t-doc.pay-code = &2 ~
                        ', ~{&double-quote~}, sch-pay.obj-code)"

            &use-ind    = " "
          }
        end.
      end.
      when "МЕНЕДЖЕР" then do:
        if fnc = "open" then do:

          if p-open-query then   frame {&frame-name}:title = "Менеджер : " + sch-cli.obj-name.
          assign
            filter-point = parlist-mode + {&delim-par} + parlist-mode + {&delim-par} + "yes".
          { gbl/fltopend.i
            &where-cond = "t-doc.boss = parschcli-code "
            &dyn_where-cond = " substitute ( ' ~
                          t-doc.boss = &2   ~
                        ', ~{&double-quote~}, parschcli-code  )"

            &use-indFIRST = "use-index boss-code "
          }
        end.
      end.
      when "ИСПОЛНИТЕЛЬ" then do:
        if fnc = "open" then do:

          if p-open-query then   frame {&frame-name}:title = "Исполнитель : " + sch-cli.obj-name.
          assign
            filter-point = parlist-mode + {&delim-par} + parlist-mode + {&delim-par} + "yes".
          { gbl/fltopend.i
            &where-cond = " t-doc.agnt = parschcli-code "
            &dyn_where-cond = " substitute ( ' ~
                          t-doc.agnt = &2
                        ', ~{&double-quote~}, parschcli-code  )"

            &use-ind    = " "
          }
        end.
      end.

      when "КЛАДОВЩИК" then do:
        if fnc = "open" then do:

          if p-open-query then   frame {&frame-name}:title = "Кладовщик : " + sch-cli.obj-name.
          assign
            filter-point = parlist-mode + {&delim-par} + parlist-mode + {&delim-par} + "yes".
          { gbl/fltopend.i
            &where-cond = "t-doc.wrkr = parschcli-code "
            &dyn_where-cond = " substitute ( ' t-doc.wrkr = &2 ', ~{&double-quote~}, parschcli-code ) "
            &use-ind    = " "
          }
        end.
      end.
      when {&client-cmp} then do:
        if fnc = "open" then do:

            if p-open-query then frame {&frame-name}:title = "Контрагент : " + sch-cli.obj-name.
            objects = 1.
          assign
            filter-point = parlist-mode + {&delim-par} + parlist-mode + {&delim-par} + "yes".
          { gbl/fltopend.i
            &where-cond = "t-doc.cli-type  = parschcli-type
                       and t-doc.cli-code  = parschcli-code
                       and t-doc.host-code = par-host-code
                       "

            &dyn_where-cond = " substitute ( ' ~
                          t-doc.host-code = &2
                          and t-doc.cli-type  = &1&3&1
                          and t-doc.cli-code  = &4
                        ', ~{&double-quote~}, par-host-code  , parschcli-type  , parschcli-code )"

             &use-indFIRST = "use-index cli-date "
          }
        end.
      end.
    end case.
end.


procedure modes-2:
define input parameter p-open-query     as logical   no-undo .
define input parameter p-find-next      as logical   no-undo .
define input parameter p-find-condition as character no-undo .
define input parameter fnc              as character no-undo.
IF parlist-mode = {&invoice} + "-obj"  THEN DO:
  IF fnc = "open" THEN DO:
    ASSIGN
      FRAME {&FRAME-NAME} :TITLE =
        "НАКЛАДНЫЕ  БЕЗ  СЧЕТОВ-ФАКТУР  по  " + par-obj-type + " ":U + STRING( par-obj-code )
      objects = 2
    .
    assign
      filter-point = parlist-mode + {&delim-par} + parlist-mode + {&delim-par} + "yes".

    { gbl/fltopend.i
      &where-cond = "t-doc.obj-type  = par-obj-type
                 and t-doc.obj-code  = par-obj-code
                 and t-doc.scf-date  = ?
                 and t-doc.status_   = {&fact}
                 and t-doc.fact-date > 12/31/96
                 "
            &dyn_where-cond = " substitute ( ' ~
                              t-doc.obj-type = &1&2&1 ~
                          and t-doc.obj-code = &3  ~
                          and t-doc.scf-date  = ?  ~
                          and t-doc.status  = &1&4&1 ~
                          and t-doc.fact-date > 12/31/1996  ~
                        ', ~{&double-quote~}, par-obj-type , par-obj-code ,  ~{&fact~})"

       &use-indFIRST = "use-index scf-obj "
    }
  end.
end.
if parlist-mode = {&invoice} + "-host" then do:
  if fnc = "open" then do:
    assign
      frame {&frame-name} :title =
        "НАКЛАДНЫЕ  БЕЗ  СЧЕТОВ-ФАКТУР  по  ФИРМЕ: " + string(par-host-code)
      objects = 1
    .
    assign
      filter-point = parlist-mode + {&delim-par} + parlist-mode + {&delim-par} + "yes".
    { gbl/fltopend.i
      &where-cond = "t-doc.host-code = par-host-code
                 and t-doc.scf-date  = ?
                 and t-doc.status_   = {&fact}
                 and t-doc.fact-date > 12/31/96
                 "
            &dyn_where-cond = " substitute ( ' ~
                              t-doc.host-code = &2 ~
                          and t-doc.scf-date  = ?  ~
                          and t-doc.status_  = &1&3&1 ~
                          and t-doc.fact-date > 12/31/1996  ~
                        ', ~{&double-quote~}, par-host-code ,  ~{&fact~})"

      &use-indFIRST = "use-index scf-host "
    }
  end.
end.

if parlist-mode =  "no-def":u then do:
        if fnc = "open" then do:

            if p-open-query then frame {&frame-name}:title = "Без определенных условий по фирме " + string(par-host-code).
            objects = 2.
          assign
            filter-point = parlist-mode + {&delim-par} + parlist-mode + {&delim-par} + "yes".
          { gbl/fltopend.i
            &where-cond = "t-doc.host-code = par-host-code and
                           t-doc.need-incorexpfo = 2 and
                           t-doc.status_    = {&fact}
                       "
            &dyn_where-cond = " substitute ( ' ~
                           t-doc.host-code = &2 and
                           t-doc.need-incorexpfo = 2 and
                           t-doc.status_    = &1&3&1
                       ', ~{&double-quote~}, par-host-code ,  ~{&fact~})"

            &use-ind = " "
          }
        end.
      end.

if parlist-mode =   "yes-gen-fo":u then do:
        if fnc = "open" then do:

            if p-open-query then frame {&frame-name}:title = "Все с финансовыми обязательствами по фирме " + string(par-host-code).
            objects = 2.
          assign
            filter-point = parlist-mode + {&delim-par} + parlist-mode + {&delim-par} + "yes".
          { gbl/fltopend.i
            &where-cond = "t-doc.host-code = par-host-code and
                           t-doc.cr-incorexpfo = yes and
                           t-doc.status_ = {&fact}
                       "
            &dyn_where-cond = " substitute ( ' ~
                           t-doc.host-code = &2 and
                           t-doc.cr-incorexpfo = yes and
                           t-doc.status_    = &1&3&1
                       ', ~{&double-quote~}, par-host-code ,  ~{&fact~})"

            &use-ind = "  "
          }
        end.

      end.

if parlist-mode =   "yes-gen-expfo":u then do:
        if fnc = "open" then do:

            if p-open-query then frame {&frame-name}:title = "C финансовыми обязательствами по реализации по фирме " + string(par-host-code).
            objects = 2.
          assign
            filter-point = parlist-mode + {&delim-par} + parlist-mode + {&delim-par} + "yes".
          { gbl/fltopend.i
            &where-cond = "t-doc.host-code = par-host-code and
                           t-doc.cr-expfo = yes and
                           t-doc.status_ = {&fact} "
            &dyn_where-cond = " substitute ( ' ~
                           t-doc.host-code = &2 and
                           t-doc.cr-expfo = yes and
                           t-doc.status_    = &1&3&1
                       ', ~{&double-quote~}, par-host-code ,  ~{&fact~})"

            &use-indFIRST = "use-index gen-expfo "
          }
        end.
      end.
if parlist-mode =   "yes-gen-buyer":u then do:
        if fnc = "open" then do:

            if p-open-query then frame {&frame-name}:title = "C финансовыми обязательствами по покупателям по фирме " + string(par-host-code).
            objects = 2.
          assign
            filter-point = parlist-mode + {&delim-par} + parlist-mode + {&delim-par} + "yes".
          { gbl/fltopend.i
            &where-cond = "t-doc.host-code = par-host-code and
                           t-doc.cr-fo-buyer = yes and
                           t-doc.status_ = {&fact}
                       "
            &dyn_where-cond = " substitute ( ' ~
                           t-doc.host-code = &2 and
                           t-doc.cr-fo-buyer = yes and
                           t-doc.status_    = &1&3&1
                       ', ~{&double-quote~}, par-host-code ,  ~{&fact~})"

            &use-ind = "  "
          }
        end.
      end.


if parlist-mode =   "yes-gen-incfo":u then do:
        if fnc = "open" then do:

            if p-open-query then frame {&frame-name}:title = "C финансовыми обязательствами по поставки по фирме " + string(par-host-code).
            objects = 2.
          assign
            filter-point = parlist-mode + {&delim-par} + parlist-mode + {&delim-par} + "yes".
          { gbl/fltopend.i
            &where-cond = "t-doc.host-code = par-host-code and
                           t-doc.cr-incfo = yes and
                           t-doc.status_ = {&fact}
                           "
            &dyn_where-cond = " substitute ( ' ~
                           t-doc.host-code = &2 and
                           t-doc.cr-incfo = yes and
                           t-doc.status_    = &1&3&1
                       ', ~{&double-quote~}, par-host-code ,  ~{&fact~})"

             &use-indFIRST = "use-index gen-incfo "
          }
        end.
      end.
end.

procedure modes-lgas :
define input parameter p-open-query     as logical   no-undo .
define input parameter p-find-next      as logical   no-undo .
define input parameter p-find-condition as character no-undo .
define input parameter fnc              as character no-undo.
  def var v-list-trn-doc-code as character no-undo.
  def buffer d-a for ub.doc-attr.
  
  
  for each d-a no-lock where d-a.attr-code = {&trdcattr-is-lgas}:
    v-list-trn-doc-code = v-list-trn-doc-code + d-a.doc-code + {&delim-par}.
  end.
  
  v-list-trn-doc-code = right-trim(v-list-trn-doc-code,{&delim-par}).
  
  if p-open-query then frame {&frame-name}:title = "Объект : " + par-obj-type + " " + string (par-obj-code).
  objects = 2.
  assign
    filter-point = parlist-mode .
  { gbl/fltopend.i
    &where-cond = "t-doc.obj-type = par-obj-type and
                    t-doc.obj-code = par-obj-code and t-doc.status_ = parstat and lookup (t-doc.doc-code, v-list-trn-doc-code, {&delim-par}) > 0 
                     "
    &dyn_where-cond = " substitute ( ' ~
                        t-doc.obj-type = &1&2&1 and
                        t-doc.obj-code = &3
                     ', ~{&double-quote~}, par-obj-type , par-obj-code)"

    &use-indFIRST = "use-index obj-date "
  }


end.

procedure modes-1-a :
define input parameter p-open-query     as logical   no-undo .
define input parameter p-find-next      as logical   no-undo .
define input parameter p-find-condition as character no-undo .
define input parameter fnc              as character no-undo.
case parlist-mode :
  when {&work} then do:
    if fnc = "open" then do:
        if p-open-query then frame {&frame-name}:title = "ВСЕ ДОКУМЕНТЫ"   .
        assign
        filter-point = parlist-mode + {&delim-par} + parlist-mode + {&delim-par} + "yes".

      { gbl/fltopend.i
        &where-cond = " true "
        &dyn_where-cond = " 'true' "
       /* &by         = "  "      */
       }
    end.
  end.

  when {&company} then do:
    if fnc = "open" then do:

         if p-open-query then frame {&frame-name}:title = "Фирма : " + string(par-host-code).
         objects = 1.
      assign
        filter-point = {&work} + {&delim-par} + {&work} + {&delim-par} + "yes".
      { gbl/fltopend.i
        &where-cond = " t-doc.host-code = par-host-code  "
        &dyn_where-cond = " substitute ( ' t-doc.host-code = &2 ', ~{&double-quote~}, par-host-code )"
        &use-indFIRST = " use-index host-date "
      }
    end.
  end.
  when {&g___object} then do:
    if fnc = "open" then do:
        if p-open-query then frame {&frame-name}:title = "Объект : " + par-obj-type + " " + string (par-obj-code).
        objects = 2.
      assign
        filter-point = parlist-mode + {&delim-par} + parlist-mode + {&delim-par} + "yes".
      { gbl/fltopend.i
        &where-cond = " t-doc.obj-type = par-obj-type and
                        t-doc.obj-code = par-obj-code
                         "
        &dyn_where-cond = " substitute ( ' ~
                            t-doc.obj-type = &1&2&1 and
                            t-doc.obj-code = &3
                         ', ~{&double-quote~}, par-obj-type , par-obj-code )"

        &use-indFIRST = "use-index obj-date "
      }
    end.
  end.
  when {&choose} then do:
    if fnc = "open" then do:

        if p-open-query then frame {&frame-name}:title = "Объект : " + par-obj-type + " " + string (par-obj-code).
        objects = 2.
      assign
        filter-point = {&g___object} + {&delim-par} + {&g___object} + {&delim-par} + "yes".
      { gbl/fltopend.i
        &where-cond = " t-doc.obj-type = par-obj-type and
                        t-doc.obj-code = par-obj-code
                        "
        &dyn_where-cond = " substitute ( ' ~
                            t-doc.obj-type = &1&2&1 and
                            t-doc.obj-code = &3
                         ', ~{&double-quote~}, par-obj-type , par-obj-code )"

        &use-indFIRST = "use-index obj-date "
      }
    end.
  end.
end.
end procedure.

procedure modes-1-b :
define input parameter p-open-query     as logical   no-undo .
define input parameter p-find-next      as logical   no-undo .
define input parameter p-find-condition as character no-undo .
define input parameter fnc              as character no-undo.

case parlist-mode :
  when {&type} then do:
    if varhold <> "yes" then do:
      if fnc = "open" then do:
          if p-open-query then frame {&frame-name}:title = "Объект : " + par-obj-type + " " + string (par-obj-code)
                                    + "  " + string (parinternal, "внутр/внеш")
                                    + "  Тип : " + partype + " Расширенный тип: " + entry(lookup (parext-doc-type, {&TDEDT_List}), {&TDEDT_List-full}).
        objects = 2.
        assign filter-point = {&all} + partype + {&delim-par} + {&all} + partype + {&delim-par} + "yes".
        { gbl/fltopend.i
          &where-cond = "  t-doc.obj-type     = par-obj-type
                       and t-doc.obj-code     = par-obj-code
                       and t-doc.internal     = parinternal
                       and t-doc.doc-type     = partype
                       and t-doc.ext-doc-type = parext-doc-type
                       "
        &dyn_where-cond = " substitute ( ' ~
                           t-doc.obj-type = &1&2&1  ~
                       and t-doc.obj-code = &3      ~
                       and t-doc.internal     = &4  ~
                       and t-doc.doc-type     = &1&5&1 ~
                       and t-doc.ext-doc-type = &1&6&1 ~
                         ', ~{&double-quote~}, par-obj-type , par-obj-code , parinternal , partype , parext-doc-type ) "


          &use-indFIRST = "use-index type-date "
        }
      end.
    end.
    else do:
      if paris-hold = no then do:
        if fnc = "open" then do:
          if p-open-query then frame {&frame-name}:title = "Объект : " + par-obj-type + " " + string (par-obj-code)
                                                    + "  " + string (parinternal, "внутр/внеш")
                                                    + "  Тип : " + partype + " Расширенный тип: " + entry(lookup (parext-doc-type, {&TDEDT_List}), {&TDEDT_List-full}).
          objects = 2.
          assign
           filter-point = {&all} + partype + {&delim-par} + {&all} + partype + {&delim-par} + "yes".
          { gbl/fltopend.i
            &where-cond = " t-doc.obj-type = par-obj-type and ~
                          t-doc.obj-code = par-obj-code and ~
                          t-doc.internal = parinternal  and ~
                          t-doc.doc-type = partype and ~
                          t-doc.ext-doc-type = parext-doc-type ~
                          and ( t-doc.hold-doc-code-child = ''  or  t-doc.hold-doc-code-child = 'no-hold' ) ~
                          and ( t-doc.hold-doc-code-parent = '' or  t-doc.hold-doc-code-parent = 'no-hold' ) ~
                          "
        &dyn_where-cond = " substitute ( ' ~
                           t-doc.obj-type = &1&2&1  ~
                       and t-doc.obj-code = &3      ~
                       and t-doc.internal     = &4  ~
                       and t-doc.doc-type     = &1&5&1 ~
                       and t-doc.ext-doc-type = &1&6&1 ~
                       and ( t-doc.hold-doc-code-child = &1&1  or  t-doc.hold-doc-code-child  = &1no-hold&1 ) ~
                       and ( t-doc.hold-doc-code-parent = &1&1 or  t-doc.hold-doc-code-parent = &1no-hold&1 ) ~
                         ', ~{&double-quote~}, par-obj-type , par-obj-code , parinternal , partype , parext-doc-type  ) "

              &use-indFIRST = "use-index type-date "
          }
        end.
      end.
      else do:
        if fnc = "open" then do:

          if p-open-query then frame {&frame-name}:title = "Объект : " + par-obj-type + " " + string (par-obj-code)
                                                  + "  " + string (parinternal, "внутр/внеш")
                                                  + "  Тип : " + partype + " Расширенный тип: " + entry(lookup (parext-doc-type, {&TDEDT_List}), {&TDEDT_List-full}).
          objects = 2.
          assign
            filter-point = {&all} + partype + {&delim-par} + {&all} + partype + {&delim-par} + "yes".
          { gbl/fltopend.i
            &where-cond = " t-doc.obj-type  = par-obj-type
                         and t-doc.obj-code = par-obj-code
                         and t-doc.internal = parinternal
                         and t-doc.doc-type = partype
                         and t-doc.ext-doc-type = parext-doc-type
                         and (t-doc.hold-doc-code-child  <> '' and t-doc.hold-doc-code-child  <> 'no-hold' or
                              t-doc.hold-doc-code-parent <> '' and t-doc.hold-doc-code-parent <> 'no-hold')"

        &dyn_where-cond = " substitute ( ' ~
                           t-doc.obj-type = &1&2&1  ~
                       and t-doc.obj-code = &3      ~
                       and t-doc.internal     = &4  ~
                       and t-doc.doc-type     = &1&5&1 ~
                       and t-doc.ext-doc-type = &1&6&1 ~
                       and (( t-doc.hold-doc-code-child <> &1&1  and  t-doc.hold-doc-code-child  <> &1no-hold&1 ) or ~
                           ( t-doc.hold-doc-code-parent <> &1&1 and  t-doc.hold-doc-code-parent <> &1no-hold&1 )) ~
                         ', ~{&double-quote~}, par-obj-type , par-obj-code , parinternal , partype , parext-doc-type  ) "

            &use-indFIRST = "use-index type-date "
          }
        end.
      end.
    end.
  end.
  when "invert":u then do:
    if fnc = "open" then do:

      if p-open-query then   frame {&frame-name}:title = "Контрагент : " + par-obj-type + " " + string (par-obj-code)
                                  + "  " + string (parinternal, "внутр/внеш")
                                  + "  Тип : " + partype + " Расширенный тип: " + entry(lookup (parext-doc-type, {&TDEDT_List}), {&TDEDT_List-full}).
      objects = 2.
      assign filter-point = "invert":u + {&delim-par} + "invert":u + {&delim-par} + "yes".

      { gbl/fltopend.i
        &where-cond = "  t-doc.host-code    = par-host-code
        and t-doc.cli-type     = par-obj-type
        and t-doc.cli-code     = par-obj-code
        and t-doc.internal     = parinternal
        and t-doc.doc-type     = partype
        and t-doc.status_      = parstat
        and t-doc.flag_        = parflag
        and t-doc.ext-doc-type = parext-doc-type
        "
        &dyn_where-cond = " substitute ( ' ~
              t-doc.host-code    = &7
          and t-doc.cli-type = &1&2&1  ~
          and t-doc.cli-code = &3      ~
          and t-doc.internal     = &4  ~
          and t-doc.doc-type     = &1&5&1 ~
          and t-doc.status_      = &1&8&1 ~
          and t-doc.flag_        = &9 ~
          and t-doc.ext-doc-type = &1&6&1 ~
            ', ~{&double-quote~}, par-obj-type , par-obj-code , parinternal , partype , parext-doc-type , par-host-code , parstat , parflag ) "

        &use-ind = "  "
        /*by t-doc.doc-date descending */
      }
    end.
  end.
  when 'status-all' then do:
      if fnc = "open" then do:
        if p-open-query then
        frame {&frame-name}:title = "Объект : " + par-obj-type + " " + string (par-obj-code)
                            + "  " + string (parinternal, "внутр/внеш")
                            + "  Тип : " + partype + " Расширенный тип: " + entry(lookup (parext-doc-type, {&TDEDT_List}), {&TDEDT_List-full})
                            + "  Статус : " + parstat .
        objects = 2.
        assign
          filter-point = {&all} + partype + {&delim-par} + {&all} + partype + {&delim-par} + "yes".
        { gbl/fltopend.i
          &where-cond = " t-doc.obj-type = par-obj-type
                      and t-doc.obj-code = par-obj-code
                      and t-doc.internal = parinternal
                      and t-doc.doc-type = partype
                      and t-doc.status_  = parstat
                      and t-doc.ext-doc-type = parext-doc-type "
        &dyn_where-cond = " substitute ( ' ~
              t-doc.obj-type = &1&2&1  ~
          and t-doc.obj-code = &3      ~
          and t-doc.internal     = &4  ~
          and t-doc.doc-type     = &1&5&1 ~
          and t-doc.status_      = &1&7&1 ~
          and t-doc.ext-doc-type = &1&6&1 ~
            ', ~{&double-quote~}, par-obj-type , par-obj-code , parinternal , partype , parext-doc-type , parstat ) "

          &use-indFIRST = "use-index stat-date "
        }
     end.
  end.

  when 'status-all-hold' then do:
      if fnc = "open" then do:
        if p-open-query then
        frame {&frame-name}:title = "Объект : " + par-obj-type + " " + string (par-obj-code)
                            + "  " + string (parinternal, "внутр/внеш")
                            + "  Тип : " + partype + " Расширенный тип: " + entry(lookup (parext-doc-type, {&TDEDT_List}), {&TDEDT_List-full})
                            .
        objects = 2.
        assign
          filter-point = {&all} + partype .
        { gbl/fltopend.i
          &where-cond = " t-doc.obj-type = par-obj-type
                      and t-doc.obj-code = par-obj-code
                      and t-doc.internal = parinternal
                      and t-doc.doc-type = partype
                      and t-doc.ext-doc-type = parext-doc-type "

        &dyn_where-cond = " substitute ( ' ~
              t-doc.obj-type = &1&2&1  ~
          and t-doc.obj-code = &3      ~
          and t-doc.internal     = &4  ~
          and t-doc.doc-type     = &1&5&1 ~
          and t-doc.ext-doc-type = &1&6&1 ~
            ', ~{&double-quote~}, par-obj-type , par-obj-code , parinternal , partype , parext-doc-type , parstat ) "

          &use-indFIRST = "use-index stat-date "
        }
     end.
  end.

  when {&status} then do:
    if varhold <> "yes" then do:
      if fnc = "open" then do:
        if p-open-query then
        frame {&frame-name}:title = "Объект : " + par-obj-type + " " + string (par-obj-code)
                                                  + "  " + string (parinternal, "внутр/внеш")
                                                  + "  Тип : " + partype + " Расширенный тип: " + entry(lookup (parext-doc-type, {&TDEDT_List}), {&TDEDT_List-full})
                                                  + "  Статус : " + parstat .
        objects = 2.
        assign
          filter-point = {&all} + partype + {&delim-par} + {&all} + partype + {&delim-par} + "yes".
        { gbl/fltopend.i
          &where-cond = " t-doc.obj-type = par-obj-type
                      and t-doc.obj-code = par-obj-code
                      and t-doc.internal = parinternal
                      and t-doc.doc-type = partype
                      and t-doc.status_  = parstat
                      and t-doc.ext-doc-type = parext-doc-type
                      "
        &dyn_where-cond = " substitute ( ' ~
              t-doc.obj-type = &1&2&1  ~
          and t-doc.obj-code = &3      ~
          and t-doc.internal     = &4  ~
          and t-doc.doc-type     = &1&5&1 ~
          and t-doc.status_      = &1&7&1 ~
          and t-doc.ext-doc-type = &1&6&1 ~
            ', ~{&double-quote~}, par-obj-type , par-obj-code , parinternal , partype , parext-doc-type , parstat ) "

          &use-indFIRST = "use-index stat-date "
        }
      end.
    end.
    else do:
      if paris-hold = no then do:
        if fnc = "open" then do:
          if p-open-query then
            frame {&frame-name}:title = "Объект : " + par-obj-type + " " + string (par-obj-code)
                                      + "  " + string (parinternal, "внутр/внеш")
                                      + "  Тип : " + partype + " Расширенный тип: " + entry(lookup (parext-doc-type, {&TDEDT_List}), {&TDEDT_List-full})
                                      + "  Статус : " + parstat .
            objects = 2.
          assign
            filter-point = {&all} + partype + {&delim-par} + {&all} + partype + {&delim-par} + "yes".
          { gbl/fltopend.i
            &where-cond = " t-doc.obj-type = par-obj-type
                       and  t-doc.obj-code = par-obj-code
                       and  t-doc.internal = parinternal
                       and  t-doc.doc-type = partype
                       and  t-doc.status_  = parstat
                       and  t-doc.ext-doc-type = parext-doc-type
                       and (t-doc.hold-doc-code-child  = '' or t-doc.hold-doc-code-child  = 'no-hold')
                       and (t-doc.hold-doc-code-parent = '' or t-doc.hold-doc-code-parent = 'no-hold')
                       "
        &dyn_where-cond = " substitute ( ' ~
                           t-doc.obj-type = &1&2&1  ~
                       and t-doc.obj-code = &3      ~
                       and t-doc.internal     = &4  ~
                       and t-doc.doc-type     = &1&5&1 ~
                       and t-doc.status_      = &1&7&1 ~
                       and t-doc.ext-doc-type = &1&6&1 ~
                       and ( t-doc.hold-doc-code-child  = &1&1  or  t-doc.hold-doc-code-child = &1no-hold&1 ) ~
                       and ( t-doc.hold-doc-code-parent = &1&1 or  t-doc.hold-doc-code-parent = &1no-hold&1 ) ~
                         ', ~{&double-quote~}, par-obj-type , par-obj-code , parinternal , partype , parext-doc-type ,parstat  ) "

            &use-indFIRST = "use-index stat-date "
          }
        end.
      end.
      else do:
        if fnc = "open" then do:
          if p-open-query then
          frame {&frame-name}:title = "Объект : " + par-obj-type + " " + string (par-obj-code)
                                                  + "  " + string (parinternal, "внутр/внеш")
                                                  + "  Тип : " + partype + " Расширенный тип: " + entry(lookup (parext-doc-type, {&TDEDT_List}), {&TDEDT_List-full})
                                                  + "  Статус : " + parstat .
          objects = 2.
          assign
            filter-point = {&all} + partype + {&delim-par} + {&all} + partype + {&delim-par} + "yes".
          { gbl/fltopend.i
            &where-cond = " t-doc.obj-type    = par-obj-type
                       and t-doc.obj-code     = par-obj-code
                       and t-doc.internal     = parinternal
                       and t-doc.doc-type     = partype
                       and t-doc.status_      = parstat
                       and t-doc.ext-doc-type = parext-doc-type
                       and (t-doc.hold-doc-code-child  <> '' and t-doc.hold-doc-code-child  <> 'no-hold' or
                            t-doc.hold-doc-code-parent <> '' and t-doc.hold-doc-code-parent <> 'no-hold')
                       and (r-2 = 1 or t-doc.doc-code = temp-trn-doc.doc-code ) "
        &dyn_where-cond = " substitute ( ' ~
                           t-doc.obj-type = &1&2&1  ~
                       and t-doc.obj-code = &3      ~
                       and t-doc.internal     = &4  ~
                       and t-doc.doc-type     = &1&5&1 ~
                       and t-doc.status_      = &1&7&1 ~
                       and t-doc.ext-doc-type = &1&6&1 ~
                       and ( t-doc.hold-doc-code-child  <> &1&1 and t-doc.hold-doc-code-child <> &1no-hold&1 ) ~
                       or  ( t-doc.hold-doc-code-parent <> &1&1 and t-doc.hold-doc-code-parent <> &1no-hold&1 ) ~
                         ', ~{&double-quote~}, par-obj-type , par-obj-code , parinternal , partype , parext-doc-type ,parstat  ) "

            &use-indFIRST = "use-index stat-date "
          }
        end.
      end.
    end.
  end.
  when {&flag} then do:
    if varhold <> "yes" then do:
      if fnc = "open" then do:
        if p-open-query then
        frame {&frame-name}:title = "Объект : " + par-obj-type + " " + string (par-obj-code)
                                                  + "  " + string (parinternal, "внутр/внеш")
                                                  + "  Тип : " + partype + " Расширенный тип: " + entry(lookup (parext-doc-type, {&TDEDT_List}), {&TDEDT_List-full})
                                                  + "  Статус : " + parstat
                                                  + "  OK : " + string (parflag, "да/нет") .
        objects = 2.
        assign
          filter-point = {&all} + partype + {&delim-par} + {&all} + partype + {&delim-par} + "yes".
        { gbl/fltopend.i
          &where-cond = " t-doc.obj-type    = par-obj-type
                     and t-doc.obj-code     = par-obj-code
                     and t-doc.doc-type     = partype
                     and t-doc.status_      = parstat
                     and t-doc.flag_        = parflag
                     and t-doc.internal     = parinternal
                     and t-doc.ext-doc-type = parext-doc-type
                     "
        &dyn_where-cond = " substitute ( ' ~
                           t-doc.obj-type = &1&2&1  ~
                       and t-doc.obj-code = &3      ~
                       and t-doc.internal     = &4  ~
                       and t-doc.doc-type     = &1&5&1 ~
                       and t-doc.status_      = &1&7&1 ~
                       and t-doc.ext-doc-type = &1&6&1 ~
                      ', ~{&double-quote~}, par-obj-type , par-obj-code , parinternal , partype , parext-doc-type ,parstat  ) "

          &use-ind = " "
        }
      end.
    end.
    else do:
      if paris-hold = no then do:
        if fnc = "open" then do:
          if p-open-query then
          frame {&frame-name}:title = "Объект : " + par-obj-type + " " + string (par-obj-code)
                                                  + "  " + string (parinternal, "внутр/внеш")
                                                  + "  Тип : " + partype + " Расширенный тип: " + entry(lookup (parext-doc-type, {&TDEDT_List}), {&TDEDT_List-full})
                                                  + "  Статус : " + parstat
                                                  + "  OK : " + string (parflag, "да/нет").
          objects = 2.
          assign
            filter-point = {&all} + partype + {&delim-par} + {&all} + partype + {&delim-par} + "yes".
          { gbl/fltopend.i
            &where-cond = "t-doc.obj-type = par-obj-type
                       and t-doc.obj-code = par-obj-code
                       and t-doc.doc-type = partype
                       and t-doc.status_  = parstat
                       and t-doc.flag_    = parflag
                       and t-doc.internal = parinternal
                       and t-doc.ext-doc-type = parext-doc-type
                       and (t-doc.hold-doc-code-child  = '' or t-doc.hold-doc-code-child  = 'no-hold')
                       and (t-doc.hold-doc-code-parent = '' or t-doc.hold-doc-code-parent = 'no-hold')
                       "
        &dyn_where-cond = " substitute ( ' ~
                           t-doc.obj-type = &1&2&1  ~
                       and t-doc.obj-code = &3      ~
                       and t-doc.internal     = &4  ~
                       and t-doc.doc-type     = &1&5&1 ~
                       and t-doc.status_      = &1&7&1 ~
                       and t-doc.ext-doc-type = &1&6&1 ~
                       and ( t-doc.hold-doc-code-child  = &1&1 or t-doc.hold-doc-code-child  = &1no-hold&1 ) ~
                       and ( t-doc.hold-doc-code-parent = &1&1 or t-doc.hold-doc-code-parent = &1no-hold&1 ) ~
                         ', ~{&double-quote~}, par-obj-type , par-obj-code , parinternal , partype , parext-doc-type ,parstat  ) "

            &use-ind = " "
          }
        end.
      end.
      else do:
        if fnc = "open" then do:
          if p-open-query then
          frame {&frame-name}:title = "Объект : " + par-obj-type + " " + string (par-obj-code)
                                                  + "  " + string (parinternal, "внутр/внеш")
                                                  + "  Тип : " + partype + " Расширенный тип: " + entry(lookup (parext-doc-type, {&TDEDT_List}), {&TDEDT_List-full})
                                                  + "  Статус : " + parstat
                                                  + "  OK : " + string (parflag, "да/нет").
          objects = 2.
          assign
            filter-point = {&all} + partype + {&delim-par} + {&all} + partype + {&delim-par} + "yes".
          { gbl/fltopend.i
            &where-cond = " t-doc.obj-type = par-obj-type
                       and t-doc.obj-code  = par-obj-code
                       and t-doc.doc-type  = partype
                       and t-doc.status_   = parstat
                       and t-doc.flag_     = parflag
                       and t-doc.internal  = parinternal
                       and t-doc.ext-doc-type = parext-doc-type
                       and (t-doc.hold-doc-code-child  <> '' and t-doc.hold-doc-code-child  <> 'no-hold' or
                            t-doc.hold-doc-code-parent <> '' and t-doc.hold-doc-code-parent <> 'no-hold' )
                            "
        &dyn_where-cond = " substitute ( ' ~
                           t-doc.obj-type = &1&2&1  ~
                       and t-doc.obj-code = &3      ~
                       and t-doc.internal     = &4  ~
                       and t-doc.doc-type     = &1&5&1 ~
                       and t-doc.status_      = &1&7&1 ~
                       and t-doc.ext-doc-type = &1&6&1 ~
                       and ( t-doc.hold-doc-code-child  <> &1&1 and t-doc.hold-doc-code-child <> &1no-hold&1 ) or ~
                           ( t-doc.hold-doc-code-parent <> &1&1 and t-doc.hold-doc-code-parent <> &1no-hold&1 ) ~
                         ', ~{&double-quote~}, par-obj-type , par-obj-code , parinternal , partype , parext-doc-type ,parstat  ) "

            &use-ind = " "
          }
        end.
      end.
    end.
  end.
  when {&in_} then do:
    if fnc = "open" then do:
      if p-open-query then
      frame {&frame-name}:title = "Объект : " + par-obj-type + " " + string (par-obj-code)
                                                + "  " + string (parinternal, "внутр/внеш").
      objects = 2.
      assign
       filter-point = parlist-mode + {&delim-par} + parlist-mode + {&delim-par} + "yes".

      { gbl/fltopend.i
        &where-cond = "t-doc.obj-type = par-obj-type
                   and t-doc.obj-code = par-obj-code
                   and t-doc.internal = parinternal
                   "
        &dyn_where-cond = " substitute ( ' ~
                           t-doc.obj-type = &1&2&1  ~
                       and t-doc.obj-code = &3      ~
                       and t-doc.internal     = &4  ~
                      ', ~{&double-quote~}, par-obj-type , par-obj-code , parinternal ) "
        &use-ind = " "
      }
    end.
  end.

  when {&shipping} then do:
    if fnc = "open" then do:
      if p-open-query then
        frame {&frame-name}:title = "График отгрузки по объекту : " + par-obj-type + " " + string (par-obj-code).
        objects = 2.
      assign
        filter-point = parlist-mode + {&delim-par} + parlist-mode + {&delim-par} + "yes".

      { gbl/fltopend.i
        &where-cond = "t-doc.obj-type = par-obj-type
                   and t-doc.obj-code = par-obj-code
                   and t-doc.status_ = {&permitted}
                   and (t-doc.doc-type = {&expense} or t-doc.doc-type = {&write-off})
                   "
        &dyn_where-cond = " substitute ( ' ~
                           t-doc.obj-type  = &1&2&1  ~
                       and t-doc.obj-code  = &3      ~
                       and t-doc.status_   = &1&4&1  ~
                       and (t-doc.doc-type =  &1&5&1 or t-doc.doc-type =  &1&6&1 ) ~
                      ', ~{&double-quote~}, par-obj-type , par-obj-code , ~{&permitted~} , ~{&expense~}, ~{&write-off~} ) "

        &use-indFIRST = "use-index obj-load "
      }
    end.
  end.
end.
end procedure.


PROCEDURE enb-1 :
define input parameter fnc as character no-undo.
case parlist-mode :
  /* ---------------------------------------------------------------------------------------------------------------- */
  when {&g___object} then do:
    if fnc = "open" then do:
      enable b-chg b-del b-close b-open b-unrv with frame {&frame-name}.
      if not (varis-hold = yes                     and
              paris-hold = yes                     and
              parext-doc-type = {&TDEDT_Pri_Vnesh} )   then do:
        enable b-add with frame {&frame-name}.
      end.
    end.
  end.
  when "invert":u then do:
    if fnc = "open" then do:
      enable b-open with frame {&frame-name}.
    end.
  end.
  when {&type} then do:
    if varhold <> "yes" then do:
      if fnc = "open" then do:
        enable b-chg b-del b-add b-close b-open b-unrv with frame {&frame-name}.
      end.
    end.
    else do:
      if paris-hold = no then do:
        if fnc = "open" then do:
          enable b-chg b-del b-close b-add b-open b-unrv with frame {&frame-name}.
        end.
      end.
      else do:
        if fnc = "open" then do:
          enable b-chg b-del b-close b-open b-unrv with frame {&frame-name}.
          if parext-doc-type <> {&TDEDT_Pri_Vnesh} then do:
            enable b-add with frame {&frame-name}.
          end.
        end.
      end.
    end.
  end.
  when 'status-all' then do:
      if fnc = "open" then do:
        enable b-chg b-del b-add b-close b-open b-unrv WITH FRAME {&frame-name}.
      end.
  end.
  when 'status-all-hold' then do:
      if fnc = "open" then do:
/*        enable b-chg b-del b-add b-close b-open b-unrv WITH FRAME {&frame-name}.*/
      end.
  end.

  when {&status} then do:
    if varhold <> "yes" then do:
      if fnc = "open" then do:
        enable b-chg b-del b-add b-close b-open b-unrv WITH FRAME {&frame-name}.
      end.
    end.
    else do:
      if paris-hold = no then do:
        if fnc = "open" then do:
          enable b-chg b-del b-add b-close b-open b-unrv with frame {&frame-name}.
        end.
      end.
      else do:
        if fnc = "open" then do:
          enable b-chg b-del b-close b-open b-unrv with frame {&frame-name}.
          if parext-doc-type <> {&TDEDT_Pri_Vnesh} then do:
            enable b-add with frame {&frame-name}.
          end.
        end.
      end.
    end.
  end.
  when {&flag} then do:
    if varhold <> "yes" then do:
      if fnc = "open" then do:
        enable b-chg b-add b-del b-close b-open b-unrv with frame {&frame-name}.
      end.
    end.
    else do:
      if paris-hold = no then do:
        if fnc = "open" then do:
          enable b-chg b-del b-close b-add b-open b-unrv with frame {&frame-name}.
        end.
      end.
      else do:
        if fnc = "open" then do:
          enable b-chg b-del b-close b-open b-unrv with frame {&frame-name}.
          if parext-doc-type <> {&TDEDT_Pri_Vnesh}    then do:
            enable b-add with frame {&frame-name}.
          end.
        end.
      end.
    end.
  end.
  when {&in_} then do:
    if fnc = "open" then do:
      enable b-chg b-del b-close b-open b-unrv with frame {&frame-name}.
      if not (varis-hold = yes                     and
              paris-hold = yes                     and
              parext-doc-type = {&TDEDT_Pri_Vnesh} )   then do:
        enable b-add with frame {&frame-name}.
      end.
    end.
  end.
end case.

if parext-doc-type = {&TDEDT_Pri_Vnesh} and b-add:sensitive in frame {&frame-name} = true
then do:
  enable b-copy with frame {&frame-name}.
  display b-copy with frame {&frame-name}.
end.

end procedure.

procedure enb-2 :
define input parameter fnc as character no-undo.
if parlist-mode = {&confuse} then do:
 if fnc = "open" then do:
   ENABLE b-chg b-del b-close b-open b-unrv WITH FRAME {&frame-name}.
 end.
end.
end procedure.

PROCEDURE proc-find-code :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code like ub.inkas.inkas-code no-undo.
display
"  /  /":U @ sch-date
"  /  /":U @ sch-fact
'' @ sch-objtype
'' @ sch-objcode
'' @ sch-sum
with frame {&frame-name}.
assign
pardoc-code = {&double-quote} + pardoc-code + {&double-quote}.
run OpenBr in this-procedure
  (input false /* p-open-query */
  ,input par-next  /* p-find-next  */
  ,input substitute(" and t-doc.doc-code   begins &1 ", pardoc-code)
  ,input "open"
  ).
apply "entry":u to sch-code in frame {&frame-name} .
end procedure.

procedure proc-find-date :
/*------------------------------------------------------------------------------
  purpose:
  parameters:  <none>
  notes:
------------------------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter par-date like ub.inkas.doc-date no-undo.
define input parameter parwhat-date as character no-undo.

define variable var-datechr as character no-undo.
display
'':u @ sch-code
'':u @ sch-objcode
'':u @ sch-objtype
'':u @ sch-sum
with frame {&frame-name}.

assign
var-datechr = string(day(par-date)) + {&slash-char} +
              string(month(par-date)) + {&slash-char} +
              string(year(par-date)).

case parwhat-date:
  when "doc-date":u then do:
    display
    "  /  /":u @ sch-fact
    with frame {&frame-name}.
    run openbr in this-procedure
    (input false /* p-open-query */
    ,input true  /* p-find-next  */
    ,input substitute("and t-doc.doc-date = &1 "
      , var-datechr)
    , "open"
    ).
    apply "entry":u to sch-date in frame {&frame-name}.
  end.
  when "fact-date":u then do:
    display
    "  /  /":u @ sch-date
    with frame {&frame-name}.
    run openbr in this-procedure
      (input false /* p-open-query */
      ,input true  /* p-find-next  */
      ,input substitute("and t-doc.fact-date = &1 "
      , var-datechr)
      , "open"
      ).
    apply "entry":u to sch-fact in frame {&frame-name}.
  end.

end.

end procedure.

PROCEDURE proc-find-cli :
define input parameter parcli-type like ub.clients.obj-type no-undo.
define input parameter parcli-code like ub.clients.obj-code no-undo.
display
'':u @ sch-code
"  /  /":U @ sch-date
"  /  /":U @ sch-fact
'':u  @ sch-sum
with frame {&frame-name}.
run OpenBr in this-procedure
  (input false /* p-open-query */
  ,input yes  /* p-find-next  */
  ,input substitute("and t-doc.cli-type = '&1' and t-doc.cli-code = &2", parcli-type, parcli-code)
  ,input "open"
  ).
apply "entry":u to sch-objtype in frame {&frame-name} .
end procedure.
PROCEDURE proc-find-sum :
define input parameter parsum as decimal no-undo.
display
'':u @ sch-code
"  /  /":U @ sch-date
"  /  /":U @ sch-fact
'':u @ sch-objtype
'':u @ sch-objcode
with frame {&frame-name}.
run OpenBr in this-procedure
  (input false /* p-open-query */
  ,input yes  /* p-find-next  */
  ,input substitute("and (t-doc.print-rubl = yes and round(t-doc.tot-sale, 2) = &1 or t-doc.print-rubl = no and round(t-doc.tot-fact, 2) = &1)", parsum)
  ,input "open"
  ).
apply "entry":u to sch-sum in frame {&frame-name} .
end procedure.

PROCEDURE set-filter-name :
  define input parameter p-filter-name as character no-undo .

  do with frame {&frame-name}:
    if p-filter-name > "" then do:
      assign
        frame {&frame-name}:title
          = frame {&frame-name}:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :TOOLTIP = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :TOOLTIP = ""
      .
    end.
  end. /* do with frame */
END PROCEDURE.

procedure local-add:
define buffer bf_clients for ub.clients.
define buffer bf_sysconf for ub.sysconf.

define variable varis-active as logical   no-undo.
define variable v-dead-doc   as character no-undo initial no.
define variable v-type       as character no-undo initial ?.
define variable varno-change-cli-cntr as logical              no-undo.
define variable varcli-type           as character            no-undo.
define variable varcli-code           as integer              no-undo.
define variable varcontract-code      as integer              no-undo.
define variable varset-cli-contr      as logical              no-undo.

{ gbl/conf-rd.i
  "'dead-doc'"
  "''"
  "''"
  0
  "''"
  "''"
  "''"
  no
  v-dead-doc
  v-type
  no-error
}
if  error-status :error  = false then do:
    if v-dead-doc = "yes"  then  do:
      message "В системе установлен запрет на ввод документов!"
      view-as alert-box error .
      return error  .
    end.
end.


if not vardoc-mode = {&add-copy} 
  then assign vardoc-mode = {&add-def}.
if parinternal then do:
  if partype = ? or partype = "?" then
    partype = {&expense}.
  if partype = {&return} then do:
    message "Для внутреннего перемещения можно создать только расход."
                    "Приход и возврат создаются автоматически.".
    return error.
  end.
end.
if parext-doc-type = {&TDEDT_Pri_Object} then do:
  message "Для внутриобъектного перемещения можно создать только расход."
                    "Приход создаётся автоматически."
  view-as alert-box.
  return error.
end. 
if parext-doc-type = {&TDEDT_Ras_Prvo}     or
   parext-doc-type = {&TDEDT_Spi_Prvo}     or
   parext-doc-type = {&TDEDT_Pri_Prvo}     then do:
  message "Документ производство нельзя добавить из данного интерфейса." view-as alert-box.
  return error.
end.
if parext-doc-type = {&TDEDT_Ras_Vnesh_Kass}     or
   parext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} then do:
  message "Складские документы 'продажа-возврат по кассе' генерятся автоматически из документов продажи."
  view-as alert-box.
  return error.
end.
if parext-doc-type = {&TDEDT_Chg_Purch_Code} then do:
  message "Документ коррекциии типа приобретения генерится автоматически при реализации товара."
  view-as alert-box.
  return error.
end.
if parext-doc-type = {&TDEDT_Corr_Minus_Parts} then do:
  message "Документ корректировки отрицательных партий генерится автоматически при приходе товара от поставщика."
  view-as alert-box.
  return error.
end.

if parext-doc-type = {&TDEDT_Corr_Acc_Price} then do:
  find first bf_clients where bf_clients.obj-type = par-obj-type and
                              bf_clients.obj-code = par-obj-code no-lock.
  { gbl/objat.i
    bf_clients.obj-type
    bf_clients.obj-code
    "'active=request'"
    varis-active
  }
  if varis-active = no then do:
    message "Документ коррекции учетной цены создается на активной стороне."
    view-as alert-box.
    return error.
  end.
end.
if parext-doc-type = {&TDEDT_Peresort} then do:
  find first bf_clients where bf_clients.obj-type = par-obj-type and
                              bf_clients.obj-code = par-obj-code no-lock.
  { gbl/objat.i
    bf_clients.obj-type
    bf_clients.obj-code
    "'active=request'"
    varis-active
  }
  if varis-active = no then do:
    message "Документ пересортицы создается на активной стороне."
    view-as alert-box.
    return error.
  end.
end.

if partype <> ? and partype <> "?" then do:
  if parext-doc-type = {&TDEDT_Corr_Acc_Price}
  then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_corr-acc-pr-view_preparation':U
      {&cntxt-object}
      par-host-code
      par-obj-type
      par-obj-code
      0
      0
      0
      true
      varlog
    }
  end.
  else do:
    if parext-doc-type = {&TDEDT_Peresort}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_tdedt-peresort_preparation':U
        {&cntxt-object}
        par-host-code
        par-obj-type
        par-obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    else do:
      if  parext-doc-type = {&TDEDT_Ras_Vnesh}
      and paris-hold
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_hold-expense_preparation':U
          {&cntxt-object}
          par-host-code
          par-obj-type
          par-obj-code
          0
          0
          0
          true
          varlog
        }
      end.
      else do:
        case partype :
          when {&income}
          then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_income_preparation':U
              {&cntxt-object}
              par-host-code
              par-obj-type
              par-obj-code
              0
              0
              0
              true
              varlog
            }
          end.
          when {&expense}
          then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_expense_preparation':U
              {&cntxt-object}
              par-host-code
              par-obj-type
              par-obj-code
              0
              0
              0
              true
              varlog
            }
          end.
          when {&return}
          then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_return_preparation':U
              {&cntxt-object}
              par-host-code
              par-obj-type
              par-obj-code
              0
              0
              0
              true
              varlog
            }
          end.
          when {&write-off}
          then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_write-off_preparation':U
              {&cntxt-object}
              par-host-code
              par-obj-type
              par-obj-code
              0
              0
              0
              true
              varlog
            }
          end.
          when {&inventory}
          then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_inventory_add':U
              {&cntxt-object}
              par-host-code
              par-obj-type
              par-obj-code
              0
              0
              0
              true
              varlog
            }
          end.

          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Неизвестный тип документа" skip
              "Тип документа" partype skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end case .
      end.
    end.
  end.
  if not varlog then return error.
end.
case partype :
when {&income} then do:
  if parstat = ? or parstat = "?" then do:
    if parinternal then do:
      assign
        parstat = {&inquiry}.
    end.
    else do:
      assign
        parstat = {&wayb}.
    end.
  end.
  if parstat = {&inquiry} then do:
    if not parinternal and v-cntxt-db-num <> 0 then do:
      message "Добавление внешнего приходного запроса возможно только из ГБД.".
      return no-apply.
    end.
    varlog = yes.
    message "Внимание !  Создаю новый ЗАПРОС !" skip (2)
                    "Продолжать ?" view-as alert-box question buttons OK-Cancel update varlog.
    if not varlog then return no-apply.
  end.
  if can-do ({&wayb_inquiry}, parstat) then do:
    if not parinternal then do:
      if vardoc-mode = {&add-copy}
      then pardoc-rec = recid (t-doc).
      run str/in-doc.w (input parparentproc, input-output pardoc-rec, input vardoc-mode, input {&income}, input no, input-output varnext-prev,input parext-doc-type, input paris-hold, input-output varline-rec, input br-handle, input bf-handle, input parstat).
    end.
    else do:
      run str/out-doc.w (input parparentproc,
                     input-output pardoc-rec,
                     input vardoc-mode,
                     input ?,
                     input {&income},
                     input yes,
                     input-output varnext-prev,
                     input parext-doc-type,
                     input paris-hold,
                     input-output varline-rec,
                     input br-handle,
                     input bf-handle,
                     input parstat).
    end.
  end.
  else do:
    message "Добавление нового документа не работает в этом списке,"
            "т.к. в нем не тот (или неизвестен) Статус документа.".
    return no-apply.
  end.
end.
when {&expense}   or
when {&return}    or
when {&write-off} then do:
  if parstat = ? or parstat = "?" then do:
    if v-cntxt-db-num = v-cntxt-db-num-obj then do:
      assign
        parstat = {&wayb}.
    end.
    else do:
      assign
        parstat = {&inquiry}.
    end.
  end.
  if parstat = {&inquiry} then do:
    varlog = yes.
    message "Внимание !  Создаю новый ЗАПРОС !" skip (2)
                    "Продолжать ?" view-as alert-box question buttons OK-Cancel update varlog.
    if not varlog then return no-apply.
  end.
  if can-do ({&wayb_inquiry}, parstat) then do:
      run str/out-doc.w (input parparentproc,
                     input-output pardoc-rec,
                     input vardoc-mode,
                     input ?,
                     input partype,
                     input parinternal,
                     input-output varnext-prev,
                     input parext-doc-type,
                     input paris-hold,
                     input-output varline-rec,
                     input br-handle,
                     input bf-handle,
                     input parstat).
  end.
  else do:
    message "Добавление нового документа не работает в этом списке,"
            "т.к. в нем не тот (или неизвестен) Статус документа.".
    return no-apply.
  end.
end.
when {&inventory} then do:
  if parstat = ? or parstat = "?" then do:
    parstat = {&wayb}.
  end.
  if parstat = {&wayb} then do:
    case parext-doc-type :
    when {&TDEDT_Inv} then do:
      run str/inv-doc.w (input parparentproc, input-output pardoc-rec, input vardoc-mode, input {&inventory}, input no, input-output varnext-prev, input parext-doc-type, input paris-hold, input-output varline-rec, input br-handle, input bf-handle).
    end.
    when {&TDEDT_Peresort} then do:
        run str/chs-cli.w
             (input  parparentproc,
              input  par-obj-type,
              input  par-obj-code,
              output varno-change-cli-cntr,
              output varcli-type,
              output varcli-code,
              output varcontract-code,
              output varset-cli-contr
              ) no-error.
        if varset-cli-contr = yes then do:
          run str/peresort.w
             (input        parparentproc,
              input-output pardoc-rec,
              input        {&add-def},
              input        {&TDEDT_Peresort},
              input-output varnext-prev,
              input-output varline-rec,
              input        br-handle,
              input        bf-handle,
              input        par-obj-type,
              input        par-obj-code,
              input        varcli-type,
              input        varcli-code,
              input        varno-change-cli-cntr,
              input        varcontract-code
              ) .
        end.
      end.
      when {&TDEDT_Corr_Acc_Price} then do:
            run str/corparts.w
              ( input        parparentproc,
                input-output pardoc-rec,
                input        vardoc-mode,
                input        parext-doc-type,
                input        paris-hold,
                input-output varnext-prev,
                input-output varline-rec,
                input        br-handle ,
                input        bf-handle
                ) no-error  .
                if error-status :error then message
                  vss-workfile vss-revision vss-description skip
                  error-status :get-message(1) skip
                  return-value skip
                  ""
                  view-as alert-box error
                .
      end.
      otherwise do:
        return no-apply.
      end.
    end.
  end.
  else do:
    message "Добавление нового документа не работает в этом списке,"
            "т.к. в нем не тот (или неизвестен) Статус документа.".
    return no-apply.
  end.
end.
otherwise do:
  message "Не задан Тип документа (при, рас, возврат, спи, инв) -"
          "непонятно, какой документ добавлять." skip (2)
          "Для добавления выберите список документов нужного ТИПа и СТАТУСа.".
  return error.
end.
end case.
if pardoc-rec = ? then do:
  return error.
end.
run UI-on ("open").
end procedure.

procedure proc-b-del :
do on error undo, return error return-value :

define variable del-rec          as recid     no-undo.  /* recid for reposition */
define variable unrv-qnty        as decimal   no-undo.  /* количество из gds-dtl, по которому снимаются резервы перед удалением */
define variable varmes           as character no-undo.
define variable v-user-action    as character no-undo.
define variable v-printed        as logical   no-undo.
define variable varchip-num-main as integer   no-undo.
define variable varchip-num      as integer   no-undo.

define buffer bf-acp_trn-doc for ub.trn-doc.
define buffer bf-stp_trn-doc for ub.trn-doc.
define buffer bf-pri_trn-doc for ub.trn-doc.
define buffer bf-vzv_trn-doc for ub.trn-doc.
define buffer bf-irv_trn-doc for ub.trn-doc.
define buffer bf-irs_trn-doc for ub.trn-doc.
define buffer bf-del_trn-doc for ub.trn-doc.
define buffer bf_clients     for ub.clients.
define buffer bf-c_clients   for ub.clients.

define variable vardel-rec as recid no-undo.
define variable vardel-doc-code like ub.trn-doc.doc-code no-undo.
define variable varhold-doc as logical no-undo.
define variable vDocCode    as character no-undo .

{ gbl/hold-doc.i  t-doc.doc-code varhold-doc no-error }
{&net-del}
if can-do ({&wayb_inquiry}, t-doc.status_) and t-doc.flag_ then do:
    if not is-mes(t-doc.doc-code) then do:
    varlog = no.
    message "Редактирование документа уже закончено. Вы уверены, что хотите удалить его?"
                    view-as alert-box question buttons OK-Cancel update varlog.
    {&if-not-true}
    end.
end.
else do:
  if t-doc.status_ = {&fact} then do:
    assign
    varlog = no.
    message "Документ закрыт на 'ФАКТ'." skip
            "Удаление документа повлечет за собой пересчет данных, связанных с данным документом."
            "Удалить документ№" t-doc.doc-code "?   Вы уверены ?"
            view-as alert-box question buttons OK-Cancel update varlog.
    {&if-not-true}
  end.
  else do:
    assign
    varlog = no.
    if t-doc.doc-type = {&inventory} and t-doc.status_ = {&permitted} then do:
        find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
            ub.inv-doc-attr.attr-code = 'invMultDevice' and ub.inv-doc-attr.attr-value = string(true) no-error .
    if available (ub.inv-doc-attr) then do:  
    assign
    varlog = no.
    message "После удаления данной инвентаризации все связанные" skip
            "с ней документы в статусе 'запрос' будут удалены," skip
            "а отправленные на ТСД не будут обработаны." skip
            "Вы уверены ?"
            view-as alert-box question buttons OK-Cancel update varlog.
    {&if-not-true}     
    for each bf-del_trn-doc exclusive-lock where bf-del_trn-doc.doc-code begins t-doc.doc-code and
    bf-del_trn-doc.status_ = {&inquiry}:
        delete bf-del_trn-doc .
    end.
    
    /*создание атрибута, чтобы не было сообщений, после удалить его*/
    find first ub.inv-doc-attr exclusive-lock where ub.inv-doc-attr.attr-code = 'notMes' and
    ub.inv-doc-attr.doc-code = t-doc.doc-code no-error .
    if not available (ub.inv-doc-attr) then do:
    create ub.inv-doc-attr .
    assign
      ub.inv-doc-attr.doc-code   = t-doc.doc-code
      ub.inv-doc-attr.attr-code  = 'notMes' .
    end.
      ub.inv-doc-attr.attr-value = string(true)
      .    
    
       { gbl/int-open.i
    parparentproc
    t-doc.doc-code
    gds-list
    no-error
  }
  vDocCode = t-doc.doc-code .
      run proc-b-del no-error .
  if error-status :error then return no-apply.
  find first ub.inv-doc-attr exclusive-lock where ub.inv-doc-attr.attr-code = 'notMes' and
    ub.inv-doc-attr.doc-code = vDocCode no-error .
    if available (ub.inv-doc-attr) then delete ub.inv-doc-attr .
    return .
    end. 
    end.
    if t-doc.status_ = {&inquiry} then do:
    if t-doc.doc-type = {&inventory} then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_inventory_del-fact':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    if not varlog then
          { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_inventory_delete':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    
    if not varlog then return .
    find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = "ItogInv" and
    ub.inv-doc-attr.attr-value = entry(1,t-doc.doc-code,"/") no-error .
    if available (ub.inv-doc-attr) then do:
      message "Документ нельзя удалить"
      view-as alert-box.
      return.
    end.
    if not is-mes(t-doc.doc-code) then do:
    message "Удалить документ №" t-doc.doc-code "?   Вы уверены ?"
            view-as alert-box question buttons OK-Cancel update varlog.
    {&if-not-true}      
    end.
    end.      
    else do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_expense_del-inquiry':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    message "Удалить документ №" t-doc.doc-code "?   Вы уверены ?"
            view-as alert-box question buttons OK-Cancel update varlog.
    {&if-not-true}      
    end.
    end.
    else do:
    message "Удалить документ №" t-doc.doc-code "?   Вы уверены ?"
            view-as alert-box question buttons OK-Cancel update varlog.
    {&if-not-true}
    end.
  end.
end.

br-handle = br-docs:handle in frame {&frame-name} .
bf-handle = buffer t-doc :handle in frame {&frame-name} .

assign
  vardel-rec = recid (t-doc).
if valid-handle (br-handle) then do:
  varlog = br-handle:select-next-row().
  bf-handle = buffer t-doc :handle in frame {&frame-name} .
  if not varlog then varlog = br-handle:select-prev-row().
  pardoc-rec = recid(t-doc).
end.
if search ("del-doc.err") <> ? then do:
  os-delete "del-doc.err".
end.
assign
  varchip-num-main = next-value (s-corr-chip, {&db-name_schema}).
find first t-doc where recid(t-doc) = vardel-rec.
assign
  vardel-doc-code = t-doc.doc-code.

 define variable vardoc-hold as logical no-undo.
  { gbl/hold-doc.i
    t-doc.doc-code
    vardoc-hold
  }
/* МФ перемещения fact */
if vardoc-hold = true and t-doc.status_      = {&fact}  then do:

 case t-doc.ext-doc-type :
    when {&TDEDT_Ras_vnesh}
    then do: /*--------------------*/
      run str/delmfdoc.p (
            parparentproc  ,
            varchip-num-main,
            varchip-num   ,
            v-user-action  ,
            v-printed       )
      no-error .
      if error-status :error then do:
          message vss-workfile vss-revision vss-description skip
                "Ошибка при удалении документа МФ расхода." skip
                return-value skip
                trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                view-as alert-box error.
          return error.
      end.
      return.
    end.  /*--------------------*/

    when {&TDEDT_Ras_Vnesh_VP}
    then do: /*--------------------*/
      run str/delmvvz.p (
            parparentproc  ,
            varchip-num-main,
            varchip-num   ,
            v-user-action  ,
            v-printed       )
      no-error .
      if error-status :error then do:
          message vss-workfile vss-revision vss-description skip
                "Ошибка при удалении документа МФ возврата поставщику." skip
                return-value skip
                trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                view-as alert-box error.
          return error.
      end.
      return.
    end.  /*--------------------*/

    otherwise do:
       message "Удалить можно только цепочку документов МФ перемещения начиная с РН" view-as alert-box error .
       return.
    end.
 end case.

end.

if (t-doc.ext-doc-type = {&TDEDT_Ras_Perem} or
   t-doc.ext-doc-type = {&TDEDT_Ras_Object}) and
   t-doc.status_      = {&fact}            then do:

  find first bf_clients where bf_clients.obj-type = t-doc.obj-type and
                              bf_clients.obj-code = t-doc.obj-code no-lock.
  find first bf-c_clients where bf-c_clients.obj-type = t-doc.cli-type and
                                bf-c_clients.obj-code = t-doc.cli-code no-lock.
  if bf_clients.db-num <> bf-c_clients.db-num then do:
    if  can-find (first ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code  ) then do:
        message substitute("*Во внутреннем документе &1 по объекту &2 &3 базы данных &4 контрагентом является объект &5 &6 базы данных &7. Нельзя удалять внутренние документы относящиеся к разным базам данных.",
                                t-doc.doc-code,
                                t-doc.obj-type,
                                t-doc.obj-code,
                                bf_clients.db-num,
                                t-doc.cli-type,
                                t-doc.cli-code,
                                bf-c_clients.db-num
                                ) view-as alert-box error.
        return error.
    end.
  end.

  find first bf-pri_trn-doc where bf-pri_trn-doc.out-code     = t-doc.doc-code     and
                                  (bf-pri_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} or
                                   bf-pri_trn-doc.ext-doc-type = {&TDEDT_Pri_Object}) exclusive-lock no-error .
  if available bf-pri_trn-doc then do:
  if bf-pri_trn-doc.status_ = {&fact} then do:
    find first bf-vzv_trn-doc where bf-vzv_trn-doc.out-code     = bf-pri_trn-doc.doc-code and
                                    bf-vzv_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem}  exclusive-lock no-error.
    if available bf-vzv_trn-doc then do:
      if bf-vzv_trn-doc.status_ = {&fact} then do:
        run str/del-doc.p
          ( input parparentproc,
            input bf-vzv_trn-doc.doc-code,
            input v-cntxt-db-num,
            input "del-doc.err",
            input ?,
            input ?,
            input v-cntxt-userid,
            input 0,
            input  varchip-num-main,
            output varchip-num )
          no-error.
        if error-status:error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при удалении документа возврата." skip
            return-value skip


            view-as alert-box error.
          if search ("del-doc.err") <> ? then do:
            run gbl/prnfilen.w
              (input  "Ошибки при удалении документа"
              ,input  0
              ,input  "del-doc.err"
              ,input 7
              ,output v-user-action
              ,output v-printed
              ).
          end.
          return error.
        end.
      end.
      else do:
        message "Имеется открытый документ внутреннего возврата по данному внутреннему расходу." skip
                "Номер документа: " bf-vzv_trn-doc.doc-code skip
        view-as alert-box error.
        return error.
      end.
    end.
    run str/del-doc.p
      ( input  parparentproc,
        input  bf-pri_trn-doc.doc-code,
        input  v-cntxt-db-num,
        input  "del-doc.err",
        input  ?,
        input  ?,
        input  v-cntxt-userid,
        input  0,
        input  varchip-num-main,
        output varchip-num )
      no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при удалении документа прихода." skip
        return-value skip


        view-as alert-box error.
      if search ("del-doc.err") <> ? then do:
        run gbl/prnfilen.w
          (input  "Ошибки при удалении документа"
          ,input  0
          ,input  "del-doc.err"
          ,input  7
          ,output v-user-action
          ,output v-printed
          ).
      end.
      return error.
    end.
  end.
  else do:
    message "Имеется открытый документ внутреннего прихода по данному внутреннему расходу." skip
            "Номер документа: " bf-pri_trn-doc.doc-code skip
    view-as alert-box error.
    return error.
  end.
  end.
  else do:
    /* документ прихода не найден - кривизна значит */
      assign
        t-doc.is-del = true
      .
      run trg/trndocdl.p
        ( input t-doc.doc-code
          ,input dynamic-next-value('s-corr-chip':U, '{&db-name_schema}':U)
        ) no-error .
       if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            ""
            view-as alert-box error
          .
          return error .
       end.
          for each ub.parts
            where ub.parts.out-code = t-doc.doc-code
          on error undo, return error
          :
            delete ub.parts.
          end.
          delete t-doc.
       return .
  end.
end.
find first bf-acp_trn-doc where bf-acp_trn-doc.out-code     = vardel-doc-code           and
                                bf-acp_trn-doc.ext-doc-type = {&TDEDT_Corr_Minus_Parts} no-lock no-error.
if available bf-acp_trn-doc then do:
  find first bf-stp_trn-doc where bf-stp_trn-doc.out-code     = bf-acp_trn-doc.doc-code and
                                  bf-stp_trn-doc.ext-doc-type = {&TDEDT_Chg_Purch_Code} no-lock no-error.
  run str/del-doc.p
  ( input  parparentproc,
    input  bf-acp_trn-doc.doc-code,
    input  v-cntxt-db-num,
    input  "del-doc.err",
    input  ?,
    input  ?,
    input  v-cntxt-userid,
    input  vardel-doc-code,
    input  varchip-num-main,
    output varchip-num )
  no-error.
  if error-status:error then do:
     message
       vss-workfile vss-revision vss-description skip
       "Ошибка при удалении документа." skip
       return-value
       view-as alert-box error.
     if search ("del-doc.err") <> ? then do:
       run gbl/prnfilen.w
         (input  "Ошибки при удалении документа"
         ,input  0
         ,input  "del-doc.err"
         ,input  7
         ,output v-user-action
         ,output v-printed
         ).
     end.
     return error.
  end.
  if available bf-stp_trn-doc then do:
    run str/del-doc.p
    ( input  parparentproc,
      input  bf-stp_trn-doc.doc-code,
      input  v-cntxt-db-num,
      input  "del-doc.err",
      input  ?,
      input  ?,
      input  v-cntxt-userid,
      input  vardel-doc-code,
      input  varchip-num-main,
      output varchip-num )
    no-error.
    if error-status:error then do:
       message
         vss-workfile vss-revision vss-description skip
         "Ошибка при удалении документа." skip
         return-value skip
         view-as alert-box error.
       if search ("del-doc.err") <> ? then do:
         run gbl/prnfilen.w
           (input  "Ошибки при удалении документа"
           ,input  0
           ,input  "del-doc.err"
           ,input  7
           ,output v-user-action
           ,output v-printed
           ).
       end.
       return error.
    end.
  end.

end.

if t-doc.ext-doc-type = {&TDEDT_Inv} then do:
  find first bf-irv_trn-doc where bf-irv_trn-doc.out-code     = t-doc.doc-code     and
                                  bf-irv_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} no-lock no-error.
  find first bf-irs_trn-doc where bf-irs_trn-doc.out-code     = t-doc.doc-code     and
                                  bf-irs_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} no-lock no-error.
  if available bf-irv_trn-doc
    or available bf-irs_trn-doc
  then do:
    message substitute( "К инвентаризации &1 привязаны документы (списание и/или возврат). Нельзя удалять такую инвентаризацию.",
                        t-doc.doc-code
                       ) view-as alert-box error.
    return error.
  end.
end.

run str/del-doc.p
  ( input  parparentproc,
    input  t-doc.doc-code,
    input  v-cntxt-db-num,
    input  "del-doc.err",
    input  ?,
    input  ?,
    input  v-cntxt-userid,
    input  0,
    input  varchip-num-main,
    output varchip-num )
no-error.
if error-status:error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при удалении документа." skip
    return-value
    view-as alert-box error.
  if search ("del-doc.err") <> ? then do:
    run gbl/prnfilen.w
      (input  "Ошибки при удалении документа"
      ,input  0
      ,input  "del-doc.err"
      ,input  7
      ,output v-user-action
      ,output v-printed
      ).
  end.
  return error.
end.
find first bf-acp_trn-doc where bf-acp_trn-doc.out-code     = vardel-doc-code         and
                                bf-acp_trn-doc.ext-doc-type = {&TDEDT_Chg_Purch_Code} no-lock no-error.
if available bf-acp_trn-doc then do:
  run str/del-doc.p
  ( input  parparentproc,
    input  bf-acp_trn-doc.doc-code,
    input  v-cntxt-db-num,
    input  "del-doc.err",
    input  ?,
    input  ?,
    input  v-cntxt-userid,
    input  vardel-doc-code,
    input  varchip-num-main,
    output varchip-num )
  no-error.
  if error-status:error then do:
     message
       vss-workfile vss-revision vss-description skip
       "Ошибка при удалении документа." skip
       return-value
       view-as alert-box error.
     if search ("del-doc.err") <> ? then do:
       run gbl/prnfilen.w
         (input  "Ошибки при удалении документа"
         ,input  0
         ,input  "del-doc.err"
         ,input  7
         ,output v-user-action
         ,output v-printed
         ).
     end.
     return error.
  end.
end.
end. /* do */
end procedure. /* proc-b-del */


procedure proc-b-ext :
 do
 on error undo, return error return-value
 :
    define variable v-list-index     as integer   no-undo .
    define variable v-trn-doc-recid  as recid     no-undo .

    for each temp_recid-list
    :
      delete temp_recid-list.
    end.
    if available t-doc
    then do:
      assign
        v-trn-doc-recid = recid( t-doc )
      .
      do v-list-index = 1 to num-entries( mark-list )
      :
        create temp_recid-list .
        assign
          temp_recid-list.string-trn-doc-recid = entry( v-list-index, mark-list )
        .
      end.
    end.
    else do:
      assign
        v-trn-doc-recid = 0
      .
    end.
    run str/run-ext.p
      (input  v-trn-doc-recid
      ,input  table temp_recid-list
      ,input  {&documents}
      ,input  ""
      ,output v-ext-button-label
      ) no-error.
    if error-status :error
    then do:
      /* Ошибка при выполнении внешней программы или нет прав */
      undo, return error return-value .
    end.
 end. /* do */
end procedure. /* proc-b-ext */



procedure proc-b-chg :
 do
 on error undo, return error return-value
 :
define variable varno-change-cli-cntr as logical   no-undo.
define variable varvalue-oldsuppcntr  as character no-undo.
define variable vartype-oldsuppcntr   as character no-undo.
{&net-proc}
if t-doc.status_ <> {&wayb} then do:
    find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
    (ub.inv-doc-attr.attr-code = 'invMultDevice' or ub.inv-doc-attr.attr-code begins 'isManual') and
    ub.inv-doc-attr.attr-value = string(true) no-error .
    if available (ub.inv-doc-attr) then do:
      message "Редактирование запрещено! Инвентаризация разрешена только на ТСД"
      view-as alert-box.
      return .
    end.
end.    
if ( t-doc.status_ = {&wayb}  and  t-doc.flag_ = false ) or
     t-doc.status_ = {&inquiry}  then do:
  case t-doc.ext-doc-type
  :
    when {&TDEDT_Corr_Acc_Price}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_corr-acc-pr-view_preparation':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    when {&TDEDT_Peresort}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_tdedt-peresort_preparation':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    when {&TDEDT_Ras_Vnesh}
    then do:
      if paris-hold
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_hold-expense_preparation':U
          {&cntxt-object}
          t-doc.host-code
          t-doc.obj-type
          t-doc.obj-code
          0
          0
          0
          true
          varlog
        }
      end.
      else do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_expense_preparation':U
          {&cntxt-object}
          t-doc.host-code
          t-doc.obj-type
          t-doc.obj-code
          0
          0
          0
          true
          varlog
        }
      end.
    end.
    otherwise do:
      case t-doc.doc-type :
        when {&income}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_income_preparation':U
            {&cntxt-object}
            t-doc.host-code
            t-doc.obj-type
            t-doc.obj-code
            0
            0
            0
            true
            varlog
          }
        end.
        when {&expense}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_expense_preparation':U
            {&cntxt-object}
            t-doc.host-code
            t-doc.obj-type
            t-doc.obj-code
            0
            0
            0
            true
            varlog
          }
        end.
        when {&return}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_return_preparation':U
            {&cntxt-object}
            t-doc.host-code
            t-doc.obj-type
            t-doc.obj-code
            0
            0
            0
            true
            varlog
          }
        end.
        when {&write-off}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_write-off_preparation':U
            {&cntxt-object}
            t-doc.host-code
            t-doc.obj-type
            t-doc.obj-code
            0
            0
            0
            true
            varlog
          }
        end.
        when {&inventory}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_inventory_preparation':U
            {&cntxt-object}
            t-doc.host-code
            t-doc.obj-type
            t-doc.obj-code
            0
            0
            0
            true
            varlog
          }
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный тип документа" skip
            "Тип документа" partype skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case.
    end.
  end case.
end.

else do: /* корректировка факт-количества */
  case t-doc.doc-type :
    when {&income}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_income_chgfact':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    when {&expense}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_expense_chgfact':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    when {&return}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_return_chgfact':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    when {&write-off}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_write-off_chgfact':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    when {&inventory}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_inventory_chgfact':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестный тип документа" skip
        "Тип документа" partype skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case.
end.
if not varlog then return .

assign
  vardoc-mode = {&update}
  .
case t-doc.doc-type :
  when {&income} then do:
    if t-doc.internal = yes then do:
      run str/out-doc.w
          ( input        parparentproc
          , input-output pardoc-rec
          , input        vardoc-mode
          , input        ?
          , input        {&income}
          , input        yes
          , input-output varnext-prev
          , input        parext-doc-type
          , input        paris-hold
          , input-output varline-rec
          , input        br-handle
          , input        bf-handle
          , input        t-doc.status_   ).
    end.
    else do:
      run str/in-doc.w
        ( input        parparentproc
        , input-output pardoc-rec
        , input        vardoc-mode
        , input        {&income}
        , input        no
        , input-output varnext-prev
        , input        t-doc.ext-doc-type
        , input        paris-hold
        , input-output varline-rec
        , input        br-handle
        , input        bf-handle
        , input        t-doc.status_).
    end.
  end.
  when {&expense}   or
  when {&return}    or
  when {&write-off} then do:
    /* пересчитаем запрос */
    if t-doc.status_ = {&inquiry} then do:
      run gbl/calc-trn.p (input parparentproc, input recid(t-doc)).
    end.
    if t-doc.is-flora = true then do:
       message "Заказ на исполнение. Корректируется в соответствующем режиме." view-as alert-box information .
       return .
    end .
    else do:
      run str/out-doc.w (input parparentproc,
               input-output pardoc-rec,
               input vardoc-mode,
               input ?,
               input t-doc.doc-type,
               input yes,
               input-output varnext-prev,
               input t-doc.ext-doc-type,
               input paris-hold,
               input-output varline-rec,
               input br-handle,
               input bf-handle,
               input t-doc.status_).
    end.
  end.
  when {&inventory} then do:
      case t-doc.ext-doc-type :
          when {&TDEDT_Inv} then do:
              if t-doc.status_ = {&permitted} then run proc-check-inv .
              run str/inv-doc.w
                (input parparentproc,
                 input-output pardoc-rec,
                 input vardoc-mode,
                 input {&inventory},
                 input no,
                 input-output varnext-prev,
                 input parext-doc-type,
                 input paris-hold,
                 input-output varline-rec,
                 input br-handle,
                 input bf-handle
                 ) no-error.
          end.
          when {&TDEDT_Peresort} then do:
              { str/tdat-val.i
                t-doc.doc-code
                {&trdcattr-oldsuppcntr}
                varvalue-oldsuppcntr
                vartype-oldsuppcntr
                no-error}
              run str/peresort.w
                      (input       parparentproc,
                      input-output pardoc-rec,
                      input        {&update},
                      input        {&TDEDT_Peresort},
                      input-output varnext-prev,
                      input-output varline-rec,
                      input        br-handle,
                      input        bf-handle,
                      input        t-doc.obj-type,
                      input        t-doc.obj-code,
                      input        t-doc.cli-type,
                      input        t-doc.cli-code,
                      input        (if varvalue-oldsuppcntr = "yes":u then yes else no),
                      input        t-doc.contract-code
                      ) no-error.
            end.
            otherwise do:
                  run str/corparts.w
                    ( input        parparentproc,
                      input-output pardoc-rec,
                      input        vardoc-mode,
                      input        parext-doc-type,
                      input        paris-hold,
                      input-output varnext-prev,
                      input-output varline-rec,
                      input        br-handle ,
                      input        bf-handle
                      ) no-error  .
                      if error-status :error then message
                        vss-workfile vss-revision vss-description skip
                        error-status :get-message(1) skip
                        return-value skip
                        ""
                        view-as alert-box error
                      .
            end.
      end.
  end.
end.
if available t-doc then do:
  if t-doc.creid <> v-cntxt-userid or true then do:
    run str/trn-hist.p
      (buffer t-doc ,
      input  par-obj-type ,
      input  par-obj-code ,
      input  "Изменение документа"
      ) no-error .
    if error-status :error
    then do:
      message
        error-status :get-message(1) skip
        return-value skip
        "Внимание"
        view-as alert-box error .
    end.
  end.
end.

apply "entry" to br-docs in frame {&frame-name}.
if error-status:error then do:
  find t-doc where recid (t-doc) = pardoc-rec no-lock.  /* буфер ломается при return error */
  return error.
end.

run UI-on ("open").


 end. /* do */
end procedure. /* proc-b-chg */



procedure proc-b-unrv :
 do
 on error undo, return error return-value
 :
define variable rid-list as character no-undo.

define buffer bf_doc-line for ub.doc-line.
define buffer bf_gds-dtl  for ub.gds-dtl.

define variable varchg-inv  as logical   no-undo.
define variable v-is-ptrl   as character no-undo.
define variable v-data-type as character no-undo.
define variable is-petrol   as logical   no-undo.
define variable is-pieces   as logical   no-undo.

{&net-proc}
/* 5555 Кнопка РЕЗЕРВ*/
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_doc-reserv':U
        {&cntxt-object}
        par-host-code
        par-obj-type
        par-obj-code
        0
        0
        0
        true
        varlog
      }
if not varlog then return .
/* смена объекта внутреннего ПРИходного запроса */
if t-doc.doc-type = {&income} and
   t-doc.internal             and
   t-doc.status_ = {&inquiry} and
   not t-doc.flag_            then do:
   varlog = no.
   message "Документ №" t-doc.doc-code skip "Смена объекта и закрытие запроса ?   Вы уверены ?"
   view-as alert-box question buttons OK-Cancel update varlog.
   {&if-not-true}
   run ref/cli-all.w (parparentproc
                 ,  "b-sel"
                 , {&stock}
                 , ?
                 , ?
                 , ?
                 , ?
                 , ?
                , output rid-list) .
   find t-doc where recid (t-doc) = pardoc-rec.
   if rid-list = "" then do:
     find t-doc where recid (t-doc) = pardoc-rec no-lock.
     message "Новый объект не выбран.".
     return error.
   end.
   find ub.clients where recid (ub.clients) = integer (rid-list) no-lock.
   if ub.clients.obj-type <> {&stock} and ub.clients.obj-type <> {&shop} then do:
     find t-doc where recid (t-doc) = pardoc-rec no-lock.
     message "Нужно выбрать склад или магазин.".
     return error.
   end.
   if ub.clients.obj-type = par-obj-type and ub.clients.obj-code = par-obj-code then do:
     find t-doc where recid (t-doc) = pardoc-rec no-lock.
     message "Выбран текущий объект.".
     return error.
   end.
   tr:
   do transaction on error undo tr, return error return-value :
     assign
       t-doc.flag_ = yes
       t-doc.cli-code = par-obj-code
       t-doc.cli-type = par-obj-type
       t-doc.obj-code = ub.clients.obj-code
       t-doc.obj-type = ub.clients.obj-type.
     for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code
                          on error undo tr, return error
                          on stop  undo tr, return error :
         assign bf_doc-line.obj-type = t-doc.obj-type
                bf_doc-line.obj-code = t-doc.obj-code.
     end.
     for each bf_gds-dtl where bf_gds-dtl.doc-code = t-doc.doc-code
                          on error undo tr, return error
                          on stop  undo tr, return error :
         assign bf_gds-dtl.obj-type = t-doc.obj-type
                bf_gds-dtl.obj-code = t-doc.obj-code.
     end.
   end.
end.
else do:
  if t-doc.doc-type = {&inventory}
  then do:
    if t-doc.fact-date <> ? and  t-doc.fact-date < today then do:
      message "Для документа , закрываемого задним числом эта функция недоступна " view-as alert-box .
      return.
    end.

    if t-doc.ext-doc-type = {&TDEDT_Inv}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_inventory_permission':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }

      if not varlog
      then do:
        return error .
      end.
      assign
        varlog = no
      .
      if  t-doc.status_ = {&wayb}
      and not t-doc.flag_
      then do:
        message
          "Недопустимая функция резерв в статусе накл -"
          view-as alert-box.
        return error.
      end.
      if t-doc.status_ = {&permitted} and not t-doc.flag_ then do:
         message
          "Документ №" t-doc.doc-code skip (2)
          "Переход к документу инвентаризации (Статус разр+)?" skip
          "Вы уверены?"
          view-as alert-box question buttons OK-Cancel update varlog .
      end.
      else do:
         message
          "Документ №" t-doc.doc-code skip (2)
          "Переход к документу пересортицы (Статус разр-)?" skip
          "Вы уверены?"
          view-as alert-box question buttons OK-Cancel update varlog .
      end.
      {&if-not-true}
      run str/trn-stat.p (input parparentproc,
                      input this-procedure ,
                      input {&reserv-doc},
                      input t-doc.doc-code,
                      input ?,
                      input v-cntxt-db-num,
                      input ?,
                      input ?,
                      input ?,
                      input ?,
                      input yes,
                      output varchg-inv,
                      output table gds-list) no-error.
      if error-status:error then do:
         message "Ошибка при операции с инвентаризацией " t-doc.doc-code skip
         return-value skip
         error-status :get-message(1) skip
         error-status :get-message(2)
         view-as alert-box error.
         return error.
      end.
      if varchg-inv = yes then do:
         assign varlog = no.
         message "За время пребывания в статусе разр- было движение товаров, участвующих в инвентаризации." SKIP
         "Показать список товаров по которым было движение?"
          view-as alert-box question buttons yes-no update varlog .
         if varlog then run str/gds-list.w (input parparentproc, input par-host-code, input par-obj-type, input par-obj-code).
      end.
    end.
    else do:
       message
         vss-workfile vss-revision vss-description skip
         "Данная функция недопустима для документа с расширенным типом: " t-doc.ext-doc-type skip
         return-value
         view-as alert-box error.
       undo, return no-apply .
    end.
  end.
  else do:
    run str/out-unrv.w (input parparentproc, input t-doc.doc-code).
  end.
end.
find t-doc where recid (t-doc) = pardoc-rec no-lock.
run str/trn-hist.p
  (buffer t-doc ,
  input  par-obj-type ,
  input  par-obj-code ,
  input  "Резерв"
  ) no-error .
if error-status :error then
message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "Ошибка"
  view-as alert-box error
.
find t-doc where recid (t-doc) = pardoc-rec no-lock.
run UI-on ("open").
end. /* do */
end procedure. /* proc-b-unrv */



procedure proc-b-akt :
 do
 on error undo, return error return-value
:

varnext-prev = no.
br-handle = br-docs:handle in frame {&frame-name} .
do while varnext-prev <> ?:
  if not available t-doc then do:
    message "Неправильный выбор документа.".
    return error.
  end.
  if t-doc.doc-type = {&inventory} then do:
     message "Данный документ являлся инвентаризацией или коррекцией партий. Переоценка не возможна."
     view-as alert-box.
     return error.
  end.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_overvalue_lookup':U
    {&cntxt-object}
    t-doc.host-code
    t-doc.obj-type
    t-doc.obj-code
    0
    0
    0
    true
    varlog
  }
  if not varlog then return no-apply.
  bf-handle = buffer t-doc:handle in frame {&frame-name} .
   run str/trn-pr.w
     (input parparentproc ,
      input recid(t-doc) ,
      input {&lookup} ,
      input-output varnext-prev ,
      input ? ,
      input ? ,
      input ? ,
      input br-handle ,
      input bf-handle)
      no-error .
 if error-status :error then do:
   message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     ""
     view-as alert-box error
   .
   return error return-value .
 end.
end.
if br-handle = ? then reposition br-docs to recid pardoc-rec no-error.
apply "entry" to br-docs in frame {&frame-name}.
apply "iteration-changed" to br-docs in frame {&frame-name}.


 end. /* do */
end procedure. /* proc-b-akt */



procedure proc-b-lkp :
define variable varvalue-oldsuppcntr as character no-undo.
define variable vartype-oldsuppcntr  as character no-undo.
 do
 on error undo, return error return-value
 :

varnext-prev = no.
br-handle = br-docs:handle  in frame {&frame-name} .
bf-handle = buffer t-doc:handle in frame {&frame-name} .
do while varnext-prev <> ?:
  if not available t-doc then do:
    message "Неправильный выбор документа.".
    return error.
  end.
  case t-doc.doc-type :
    when {&income}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_income_lookup':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    when {&expense}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_expense_lookup':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    when {&return}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_return_lookup':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    when {&write-off}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_write-off_lookup':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    when {&inventory}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_inventory_lookup':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестный тип документа" skip
        "Тип документа" partype skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case.

  if not varlog
  then do:
    return error.
  end.
  if t-doc.ext-doc-type  = {&TDEDT_Ras_Vnesh_Kass}
  or t-doc.ext-doc-type  = {&TDEDT_Vozvrat_Vnesh_Kass}
  then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_sale_lookup':U
      {&cntxt-object}
      t-doc.host-code
      t-doc.obj-type
      t-doc.obj-code
      0
      0
      0
      true
      varlog
    }
  end.
  if not varlog then
    return error.
  assign
    pardoc-rec = recid (t-doc)
    vardoc-mode = {&lookup}
  .
  case t-doc.doc-type:
    when {&income} then do:
      if t-doc.internal then do:
        run str/out-doc.w (input parparentproc,
                       input-output pardoc-rec,
                       input vardoc-mode,
                       input ?,
                       input {&income},
                       input yes,
                       input-output varnext-prev,
                       input parext-doc-type,
                       input paris-hold,
                       input-output varline-rec,
                       input br-handle,
                       input bf-handle,
                       input t-doc.status_).
      end.
      else do:
        run str/in-doc.w (input parparentproc, input-output pardoc-rec, input vardoc-mode, input {&income}, input no, input-output varnext-prev, input t-doc.ext-doc-type, input paris-hold, input-output varline-rec, input br-handle, input bf-handle, input t-doc.status_) .
      end.
    end.
    when {&expense} or when {&write-off} or when {&return} then do:
      run str/out-doc.w (input parparentproc,
               input-output pardoc-rec,
               input vardoc-mode,
               input ?,
               input t-doc.doc-type,
               input yes,
               input-output varnext-prev,
               input t-doc.ext-doc-type,
               input paris-hold,
               input-output varline-rec,
               input br-handle,
               input bf-handle,
               input t-doc.status_
               ).
    end.
    when {&inventory} then do:
      if t-doc.ext-doc-type = {&TDEDT_Inv} then do:
        find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = "isManualError" and
        ub.inv-doc-attr.doc-code = t-doc.doc-code and
        ub.inv-doc-attr.attr-value = string(true) no-error .
        if available (ub.inv-doc-attr) then run str/inv-doc-err.w  (input parparentproc, input-output pardoc-rec, input vardoc-mode, input {&inventory}, input no, input-output varnext-prev, input t-doc.ext-doc-type, input paris-hold, input-output varline-rec, input br-handle, input bf-handle) .
        else do:
          if t-doc.status_ = {&permitted} then run proc-check-inv .
          run str/inv-doc.w  (input parparentproc, input-output pardoc-rec, input vardoc-mode, input {&inventory}, input no, input-output varnext-prev, input t-doc.ext-doc-type, input paris-hold, input-output varline-rec, input br-handle, input bf-handle) .
        end.
      end.
      else do:
        if t-doc.ext-doc-type = {&TDEDT_Peresort} then do:
           { str/tdat-val.i
            t-doc.doc-code
            {&trdcattr-oldsuppcntr}
            varvalue-oldsuppcntr
            vartype-oldsuppcntr
            no-error}
          run str/peresort.w (input        parparentproc,
                          input-output pardoc-rec,
                          input        {&lookup},
                          input        {&TDEDT_Peresort},
                          input-output varnext-prev,
                          input-output varline-rec,
                          input        br-handle,
                          input        bf-handle,
                          input        t-doc.obj-type,
                          input        t-doc.obj-code,
                          input        t-doc.cli-type,
                          input        t-doc.cli-code,
                          input        (if varvalue-oldsuppcntr = "yes":u then yes else no),
                          input        t-doc.contract-code    ) .
        end.
        else do:
          run str/corparts.w (input parparentproc, input-output pardoc-rec, input vardoc-mode, input parext-doc-type, input paris-hold, input-output varnext-prev, input-output varline-rec, input br-handle , input bf-handle).
        end.
      end.
    end.
  end.
end.
if br-handle = ? then reposition br-docs to recid pardoc-rec no-error.
apply "entry" to br-docs in frame {&frame-name}.
apply "iteration-changed" to br-docs in frame {&frame-name}.


 end. /* do */
end procedure. /* proc-b-lkp */



procedure proc-b-print :
 do
 on error undo, return error return-value
 :

if not available t-doc then do:
  message "Неправильный выбор документа.".
  return error.
end.
pardoc-rec = recid (t-doc).

  case t-doc.doc-type :
    when {&income}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_income_print':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    when {&expense}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_expense_print':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    when {&return}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_return_print':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    when {&write-off}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_write-off_print':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    when {&inventory}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_inventory_print':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестный тип документа" skip
        "Тип документа" partype skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case.

if not varlog then return no-apply.
find t-doc where recid (t-doc) = pardoc-rec no-lock.
run rep/doc-prn.p (
      input parparentproc
    , input this-procedure
    , input pardoc-rec
).
apply "entry" to br-docs in frame {&frame-name}.
end. /* do */
end procedure. /* proc-b-print */

procedure proc-history :
  define variable loc-ref-list as character no-undo.
  define variable loc-doc-save as recid     no-undo.
  define variable loc-mode     as character no-undo.
  define variable loc#stat     as character no-undo.
  define variable loc#type     as character no-undo.
  define variable loc#internal as logical   no-undo.

  do on error undo, return error return-value :
    if not available t-doc then do:
      message "Неправильный выбор документа." view-as alert-box.
      return error.
    end.
    assign
      pardoc-rec   = recid( t-doc )
      loc-doc-save = pardoc-rec
    .

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_c-documents_all':U
      {&cntxt-object}
      par-host-code
      par-obj-type
      par-obj-code
      0
      0
      0
      true
      varlog
    }

    if varlog <> yes then do: return error. end.
    loc-mode = "doc".
    run str/calldocs.w ( input  parparentproc,
                     input  loc-mode,
                     input  loc#stat,
                     input  loc#type,
                     input  ?,
                     input  loc#internal,
                     input  "":U,
                     input  (if loc-mode = "doc" then t-doc.doc-code else "":U),
                     input  ?,
                     input  pardoc-rec,
                     input  t-doc.obj-type,
                     input  t-doc.obj-code,
                     output loc-ref-list ).
    assign pardoc-rec      = loc-doc-save
           loc-doc-save = ?.
    find t-doc no-lock where recid( t-doc ) = pardoc-rec.
    apply "ENTRY":U to br-docs in frame {&frame-name}.
  end. /* do */
end procedure. /* proc-history */

procedure proc-b-covdocs :
  do on error undo, return error return-value :
    if not available t-doc then do:
      message "Неправильный выбор документа.".
      return error.
    end.
    if lookup(t-doc.doc-type, {&expense_income_return_write-off}) > 0 then do:
      pardoc-rec = recid (t-doc).
      run str/d-alcdoc.w (pardoc-rec).
    end.
    apply "entry" to br-docs in frame {&frame-name}.
  end. /* do */
end procedure. /* proc-b-covdocs */

procedure proc-m_gen-6 :
 do
 on error undo, return error return-value
 :
 if num-entries(mark-list) = 0 then do:
    message "Не выделено ни одной накладной для генерации финансовых обязательств !".
    return error .
 end.
 run str/gen-fl.w (
     input parparentproc,
     input par-host-code,
     input mark-list,
     input ""
 )   .

  assign
    mark-list = ""
    .
 run UI-on ("open").
 end. /* do */
end procedure. /* proc-m_gen-6 */
procedure proc-m_gen-22 :
 do
 on error undo, return error return-value
 :
 if num-entries(mark-list) = 0 then do:
    message "Не выделено ни одной накладной для генерации финансовых обязательств !".
    return error .
 end.
 run str/gen-fbuy.w (
     input parparentproc,
     input par-host-code,
     input mark-list,
     input ""
 )   .

  assign
    mark-list = ""
    .
 run UI-on ("open").
 end. /* do */
end procedure. /* proc-m_gen-22 */


procedure proc-m_gen-8 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_trn-doc for ub.trn-doc.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
do
on error undo, return error return-value
:
if mark-list = "" then do:
  if available t-doc then do:
    assign
      mark-list = string(recid(t-doc)).
  end.
end.
vari-cycle:
do vari = 1 to num-entries (mark-list):
  assign
    vardoc-code = integer(entry (vari, mark-list)).
  find first bf_trn-doc where recid(bf_trn-doc) = vardoc-code exclusive-lock.
  if bf_trn-doc.status_ <> {&fact} then do:
    message "Документ " bf_trn-doc.status_ " не в статусе " {&fact} " . Пропускаем."
    view-as alert-box.
    next vari-cycle.
  end.
  find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
  if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
    message "Главная БД для фирмы по документу с кодом " bf_trn-doc.doc-code " не является текущей БД." skip
            "Текущая БД: " v-cntxt-db-num skip
            "Главная БД фирмы: " bf_sysconf.firm-db-num
    view-as alert-box error.
    next vari-cycle.
  end.
  if bf_trn-doc.cr-incfo = yes then do:
    message "По документу " bf_trn-doc.doc-code " уже генерилось финансовое обязательство от " bf_trn-doc.incfo-date " числа."
    view-as alert-box.
    next vari-cycle.
  end.
  else do:
    if bf_trn-doc.need-incfo = 1 or
       bf_trn-doc.need-incfo = 2 then do:
      assign
        bf_trn-doc.need-incfo = 0.
      if bf_trn-doc.need-expfo = 0 then do:
        assign
          bf_trn-doc.need-incorexpfo = 0.
      end.
    end.
    else do:
      message "Данный документ не нуждался в генерации финобязательств по поставке."
      view-as alert-box.
      next vari-cycle.
    end.
    reposition {&browse-name} to recid recid(bf_trn-doc) no-error.
    if not error-status:error then do:
      display fo-postavka (recid( bf_trn-doc)) @ varpost with browse {&browse-name}.
    end.
  end.
end.
assign
  mark-list = "".
end.
end.

procedure proc-m_gen-9 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_trn-doc for ub.trn-doc.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
do
on error undo, return error return-value
:
if mark-list = "" then do:
  if available t-doc then do:
    assign
      mark-list = string(recid(t-doc)).
  end.
end.
vari-cycle:
do vari = 1 to num-entries (mark-list):
  assign
    vardoc-code = integer(entry (vari, mark-list)).
  find first bf_trn-doc where recid(bf_trn-doc) = vardoc-code exclusive-lock.
  find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
  if bf_trn-doc.status_ <> {&fact} then do:
    message "Документ " bf_trn-doc.status_ " не в статусе " {&fact} " . Пропускаем."
    view-as alert-box.
    next vari-cycle.
  end.
  if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
    message "Главная БД для фирмы по документу с кодом " bf_trn-doc.doc-code " не является текущей БД." skip
            "Текущая БД: " v-cntxt-db-num skip
            "Главная БД фирмы: " bf_sysconf.firm-db-num
    view-as alert-box error.
    next vari-cycle.
  end.
  if bf_trn-doc.cr-expfo = yes then do:
    message "По документу " bf_trn-doc.doc-code " уже генерилось финансовое обязательство от " bf_trn-doc.expfo-date " числа."
    view-as alert-box.
    next vari-cycle.
  end.
  else do:
    if bf_trn-doc.need-expfo = 1 or
       bf_trn-doc.need-expfo = 2 then do:
      assign
        bf_trn-doc.need-expfo = 0.
      if bf_trn-doc.need-incfo = 0 then do:
        assign
          bf_trn-doc.need-incorexpfo = 0.
      end.
    end.
    else do:
      message "Данный документ не нуждался в генерации финобязательств по реализации."
      view-as alert-box.
      next vari-cycle.
    end.
    reposition {&browse-name} to recid recid(bf_trn-doc) no-error.
    if not error-status:error then do:
      display fo-postavka (recid( bf_trn-doc)) @ varpost with browse {&browse-name}.
    end.
  end.
end.
assign
  mark-list = "".
end.
end.

procedure proc-m_gen-19 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_trn-doc for ub.trn-doc.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
do
on error undo, return error return-value
:
if mark-list = "" then do:
  if available t-doc then do:
    assign
      mark-list = string(recid(t-doc)).
  end.
end.
vari-cycle:
do vari = 1 to num-entries (mark-list):
  assign
    vardoc-code = integer(entry (vari, mark-list)).
  find first bf_trn-doc where recid(bf_trn-doc) = vardoc-code exclusive-lock.
  find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
  if bf_trn-doc.status_ <> {&fact} then do:
    message "Документ " bf_trn-doc.status_ " не в статусе " {&fact} " . Пропускаем."
    view-as alert-box.
    next vari-cycle.
  end.
  if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
    message "Главная БД для фирмы по документу с кодом " bf_trn-doc.doc-code " не является текущей БД." skip
            "Текущая БД: " v-cntxt-db-num skip
            "Главная БД фирмы: " bf_sysconf.firm-db-num
    view-as alert-box error.
    next vari-cycle.
  end.
  if bf_trn-doc.cr-fo-buyer = yes then do:
    message "По документу " bf_trn-doc.doc-code " уже генерилось финансовое обязательство от " bf_trn-doc.buyer-fo-date " числа."
    view-as alert-box.
    next vari-cycle.
  end.
  else do:
    if bf_trn-doc.need-buyer = 1 or
       bf_trn-doc.need-buyer = 2 then do:
      assign
        bf_trn-doc.need-buyer = 0.
    end.
    else do:
      message "Данный документ не нуждался в генерации финобязательств по покупателю."
      view-as alert-box.
      next vari-cycle.
    end.
    reposition {&browse-name} to recid recid(bf_trn-doc) no-error.
    if not error-status:error then do:
      display fo-buyer (recid(bf_trn-doc)) @ varbuyer with browse {&browse-name}.
    end.
  end.
end.
assign
  mark-list = "".
end.
end.

procedure proc-m_gen-11 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_trn-doc for ub.trn-doc.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
define variable varcr-incfo as logical no-undo.
define variable varinc-exp  as integer no-undo.
define buffer buf_parts    for ub.parts.
define buffer buf_contract for ub.contract.

do
on error undo, return error return-value
:
if mark-list = "" then do:
  if available t-doc then do:
    assign
      mark-list = string(recid(t-doc)).
  end.
end.
vari-cycle:
do vari = 1 to num-entries (mark-list):
  assign
    vardoc-code = integer(entry (vari, mark-list)).
  find first bf_trn-doc where recid(bf_trn-doc) = vardoc-code exclusive-lock.
  find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
  if bf_trn-doc.status_ <> {&fact} then do:
    message "Документ " bf_trn-doc.status_ " не в статусе " {&fact} " . Пропускаем."
    view-as alert-box.
    next vari-cycle.
  end.
  if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
    message "Главная БД для фирмы по документу с кодом " bf_trn-doc.doc-code " не является текущей БД." skip
            "Текущая БД: " v-cntxt-db-num skip
            "Главная БД фирмы: " bf_sysconf.firm-db-num
    view-as alert-box error.
    next vari-cycle.
  end.
  if bf_trn-doc.cr-incfo = yes then do:
    assign
      varlog = no.
    message "По документу " bf_trn-doc.doc-code " было создано финансовое обязательство от " bf_trn-doc.incfo-date " ." skip
            "Вы действительно хотите снять признак, что по этому документу было создано фин. обязательство?"
    view-as alert-box question buttons yes-no update varlog.
    if varlog <> yes then do:
      next vari-cycle.
    end.
    assign
      bf_trn-doc.cr-incfo   = no
      bf_trn-doc.incfo-date = 01/01/1990.
    if bf_trn-doc.cr-incfo = no and
       bf_trn-doc.cr-expfo = no then do:
      assign
        bf_trn-doc.cr-incorexpfo = no.
    end.
    reposition {&browse-name} to recid recid(bf_trn-doc) no-error.
    if not error-status:error then do:
      display fo-postavka (recid( bf_trn-doc)) @ varpost with browse {&browse-name}.
    end.
  end.
  else do:
    message "По документу " bf_trn-doc.doc-code " не было генерации по поставке."
    view-as alert-box.
  end.
end.
assign
  mark-list = "".
end.
end.

procedure proc-m_gen-12 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_trn-doc for ub.trn-doc.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
define variable varcr-expfo as logical no-undo.
define variable varinc-exp  as integer no-undo.
define buffer buf_parts    for ub.parts.
define buffer buf_contract for ub.contract.

do
on error undo, return error return-value
:
if mark-list = "" then do:
  if available t-doc then do:
    assign
      mark-list = string(recid(t-doc)).
  end.
end.
vari-cycle:
do vari = 1 to num-entries (mark-list):
  assign
    vardoc-code = integer(entry (vari, mark-list)).
  find first bf_trn-doc where recid(bf_trn-doc) = vardoc-code exclusive-lock.
  if bf_trn-doc.status_ <> {&fact} then do:
    message "Документ " bf_trn-doc.status_ " не в статусе " {&fact} " . Пропускаем."
    view-as alert-box.
    next vari-cycle.
  end.
  find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
  if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
    message "Главная БД для фирмы по документу с кодом " bf_trn-doc.doc-code " не является текущей БД." skip
            "Текущая БД: " v-cntxt-db-num skip
            "Главная БД фирмы: " bf_sysconf.firm-db-num
    view-as alert-box.
    next vari-cycle.
  end.
  if bf_trn-doc.cr-expfo = yes then do:
    assign
      varlog = no.
    message "По документу " bf_trn-doc.doc-code " было создано финансовое обязательство от " bf_trn-doc.incfo-date " ." skip
            "Вы действительно хотите снять признак, что по этому документу было создано фин. обязательство?"
    view-as alert-box question buttons yes-no update varlog.
    if varlog <> yes then do:
      next vari-cycle.
    end.
    assign
      bf_trn-doc.cr-expfo   = no
      bf_trn-doc.expfo-date = 01/01/1990.
    if bf_trn-doc.cr-incfo = no and
       bf_trn-doc.cr-expfo = no then do:
      assign
        bf_trn-doc.cr-incorexpfo = no.
    end.
    reposition {&browse-name} to recid recid(bf_trn-doc) no-error.
    if not error-status:error then do:
      display fo-realiz (recid(bf_trn-doc)) @ varrealiz with browse {&browse-name}.
    end.
  end.
  else do:
    message "По документу " bf_trn-doc.doc-code " не было генерации по реализации."
    view-as alert-box.
  end.
end.
assign
  mark-list = "".
end.
end.
procedure proc-m_gen-20 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_trn-doc for ub.trn-doc.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
define variable varcr-fo-buyer as logical no-undo.
define variable varinc-exp  as integer no-undo.
define buffer buf_parts    for ub.parts.
define buffer buf_contract for ub.contract.

do
on error undo, return error return-value
:
if mark-list = "" then do:
  if available t-doc then do:
    assign
      mark-list = string(recid(t-doc)).
  end.
end.
vari-cycle:
do vari = 1 to num-entries (mark-list):
  assign
    vardoc-code = integer(entry (vari, mark-list)).
  find first bf_trn-doc where recid(bf_trn-doc) = vardoc-code exclusive-lock.
  if bf_trn-doc.status_ <> {&fact} then do:
    message "Документ " bf_trn-doc.status_ " не в статусе " {&fact} " . Пропускаем."
    view-as alert-box.
    next vari-cycle.
  end.
  find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
  if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
    message "Главная БД для фирмы по документу с кодом " bf_trn-doc.doc-code " не является текущей БД." skip
            "Текущая БД: " v-cntxt-db-num skip
            "Главная БД фирмы: " bf_sysconf.firm-db-num
    view-as alert-box.
    next vari-cycle.
  end.
  if bf_trn-doc.cr-fo-buyer = yes then do:
    assign
      varlog = no.
    message "По документу " bf_trn-doc.doc-code " было создано финансовое обязательство от " bf_trn-doc.buyer-fo-date " ." skip
            "Вы действительно хотите снять признак, что по этому документу было создано фин. обязательство?"
    view-as alert-box question buttons yes-no update varlog.
    if varlog <> yes then do:
      next vari-cycle.
    end.
    assign
      bf_trn-doc.cr-fo-buyer   = no
      bf_trn-doc.buyer-fo-date = 01/01/1990.
    reposition {&browse-name} to recid recid(bf_trn-doc) no-error.
    if not error-status:error then do:
      display fo-buyer (recid(bf_trn-doc)) @ varbuyer with browse {&browse-name}.
    end.
  end.
  else do:
    message "По документу " bf_trn-doc.doc-code " не было генерации по покупателю."
    view-as alert-box.
  end.
end.
assign
  mark-list = "".
end.
end.

procedure proc-m_gen-13 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_trn-doc for ub.trn-doc.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
define variable varneed-incfo as logical no-undo.
define buffer bf_parts    for ub.parts.
define buffer bf_contract for ub.contract.
do
on error undo, return error return-value
:
if mark-list = "" then do:
  if available t-doc then do:
    assign
      mark-list = string(recid(t-doc)).
  end.
end.
vari-cycle:
do vari = 1 to num-entries (mark-list):
  assign
    vardoc-code = integer(entry (vari, mark-list)).
  find first bf_trn-doc where recid(bf_trn-doc) = vardoc-code exclusive-lock.
  find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
  if bf_trn-doc.status_ <> {&fact} then do:
    message "Документ " bf_trn-doc.status_ " не в статусе " {&fact} " . Пропускаем."
    view-as alert-box.
    next.
  end.
  if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
    message "Главная БД для фирмы по документу с кодом " bf_trn-doc.doc-code " не является текущей БД." skip
            "Текущая БД: " v-cntxt-db-num skip
            "Главная БД фирмы: " bf_sysconf.firm-db-num
    view-as alert-box error.
    return error.
  end.
  if bf_trn-doc.need-incfo = 2 then do:
    assign
      varneed-incfo = no.
    for each bf_parts where bf_parts.out-code = bf_trn-doc.doc-code on error undo, return error return-value :
      if bf_parts.contract-code <> 0 then do:
        find first bf_contract where bf_contract.host-code     = bf_trn-doc.host-code   and
                                     bf_contract.contract-code = bf_parts.contract-code no-lock no-error.
        if available bf_contract then do:
          if lookup (bf_contract.usl-opl, {&o-postavka}) > 0 then do:
            assign
              varneed-incfo = yes.
          end.
        end.
      end.
    end.
    if varneed-incfo then do:
      assign
        bf_trn-doc.need-incfo      = 1
        bf_trn-doc.need-expfo      = 0
        bf_trn-doc.need-incorexpfo = 1
      .
      reposition {&browse-name} to recid recid(bf_trn-doc) no-error.
      if not error-status:error then do:
        display fo-postavka (recid( bf_trn-doc)) @ varpost
                fo-realiz (recid( bf_trn-doc)) @ varrealiz with browse {&browse-name}.
      end.
    end.
    else do:
      message "По документу " bf_trn-doc.doc-code " нет договоров для генерации ФО по поставке."
      view-as alert-box.
    end.
  end.
  else do:
    message "Документ " bf_trn-doc.doc-code "не имеет признака 'не опред' генерация ФО по поставке."
    view-as alert-box.
    next vari-cycle.
  end.
end.
assign
  mark-list = "".
end.
end procedure.

procedure proc-m_gen-14 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_trn-doc for ub.trn-doc.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
define variable varneed-expfo as logical no-undo.
define buffer bf_parts    for ub.parts.
define buffer bf_contract for ub.contract.
do
on error undo, return error return-value
:
if mark-list = "" then do:
  if available t-doc then do:
    assign
      mark-list = string(recid(t-doc)).
  end.
end.
vari-cycle:
do vari = 1 to num-entries (mark-list):
  assign
    vardoc-code = integer(entry (vari, mark-list)).
  find first bf_trn-doc where recid(bf_trn-doc) = vardoc-code exclusive-lock.
  find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
  if bf_trn-doc.status_ <> {&fact} then do:
    message "Документ " bf_trn-doc.status_ " не в статусе " {&fact} " . Пропускаем."
    view-as alert-box.
    next.
  end.
  if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
    message "Главная БД для фирмы по документу с кодом " bf_trn-doc.doc-code " не является текущей БД." skip
            "Текущая БД: " v-cntxt-db-num skip
            "Главная БД фирмы: " bf_sysconf.firm-db-num
    view-as alert-box error.
    return error.
  end.
  if bf_trn-doc.need-expfo = 2 then do:
    assign
      varneed-expfo = no.
    for each bf_parts where bf_parts.out-code = bf_trn-doc.doc-code on error undo, return error return-value :
      if bf_parts.contract-code <> 0 then do:
        find first bf_contract where bf_contract.host-code     = bf_trn-doc.host-code   and
                                     bf_contract.contract-code = bf_parts.contract-code no-lock no-error.
        if available bf_contract then do:
          if lookup (bf_contract.usl-opl, {&o-realiz}) > 0 then do:
            assign
              varneed-expfo = yes.
          end.
        end.
      end.
    end.
    if varneed-expfo then do:
      assign
        bf_trn-doc.need-expfo      = 1
        bf_trn-doc.need-incfo      = 0
        bf_trn-doc.need-incorexpfo = 1
      .
      reposition {&browse-name} to recid recid(bf_trn-doc) no-error.
      if not error-status:error then do:
        display fo-postavka (recid(bf_trn-doc)) @ varpost fo-realiz (recid(bf_trn-doc)) @ varrealiz with browse {&browse-name}.
      end.
    end.
    else do:
      message "По документу " bf_trn-doc.doc-code " нет договоров для генерации ФО по реализации."
      view-as alert-box.
    end.
  end.
  else do:
    message "Документ " bf_trn-doc.doc-code "не имеет признака 'не опред' генерация ФО по реализации."
    view-as alert-box.
    next vari-cycle.
  end.
end.
assign
  mark-list = "".
end.
end procedure.

procedure proc-m_gen-21 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_trn-doc for ub.trn-doc.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
define variable varneed-buyer as logical no-undo.
define buffer bf_parts    for ub.parts.
define buffer bf_contract for ub.contract.
do
on error undo, return error return-value
:
if mark-list = "" then do:
  if available t-doc then do:
    assign
      mark-list = string(recid(t-doc)).
  end.
end.
vari-cycle:
do vari = 1 to num-entries (mark-list):
  assign
    vardoc-code = integer(entry (vari, mark-list)).
  find first bf_trn-doc where recid(bf_trn-doc) = vardoc-code exclusive-lock.
  find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
  if bf_trn-doc.status_ <> {&fact} then do:
    message "Документ " bf_trn-doc.status_ " не в статусе " {&fact} " . Пропускаем."
    view-as alert-box.
    next.
  end.
  if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
    message "Главная БД для фирмы по документу с кодом " bf_trn-doc.doc-code " не является текущей БД." skip
            "Текущая БД: " v-cntxt-db-num skip
            "Главная БД фирмы: " bf_sysconf.firm-db-num
    view-as alert-box error.
    return error.
  end.
  if bf_trn-doc.need-buyer = 2 then do:
    assign
      varneed-buyer = no.
    for each bf_parts where bf_parts.out-code = bf_trn-doc.doc-code on error undo, return error return-value :
      if bf_parts.contract-code <> 0 then do:
        find first bf_contract where bf_contract.host-code     = bf_trn-doc.host-code   and
                                     bf_contract.contract-code = bf_parts.contract-code no-lock no-error.
        if available bf_contract then do:
          if lookup (bf_contract.usl-opl, {&o-buyer-trn}) > 0 then do:
            assign
              varneed-buyer = yes.
          end.
        end.
      end.
    end.
    if varneed-buyer then do:
      assign
        bf_trn-doc.need-buyer      = 1
      .
      reposition {&browse-name} to recid recid(bf_trn-doc) no-error.
      if not error-status:error then do:
        display fo-buyer (recid(bf_trn-doc)) @ varbuyer with browse {&browse-name}.
      end.
    end.
    else do:
      message "По документу " bf_trn-doc.doc-code " нет договоров для генерации ФО по покупателю."
      view-as alert-box.
    end.
  end.
  else do:
    message "Документ " bf_trn-doc.doc-code "не имеет признака 'не опред' генерация ФО по покупателю."
    view-as alert-box.
    next vari-cycle.
  end.
end.
assign
  mark-list = "".
end.
end procedure.


procedure proc-m_gen-15 :
define variable v-doc-db-num as integer   no-undo .
  do on error undo, return error return-value :
    if num-entries(mark-list) = 0 then do:
      message "Не выделено ни одной накладной для генерации счетов-фактур !".
      return error .
    end.

    define buffer bf_trn-doc for ub.trn-doc.
    define variable vari as integer no-undo.
    define variable vardoc-code as integer no-undo.
    varlog = yes.
    message "Выбрано " + string( num-entries( mark-list)  ) + " накладных. Провести генерацию счетов-фактур?" skip
    view-as alert-box question buttons OK-Cancel update varlog.
    if not varlog then return no-apply.

    do vari = 1 to num-entries (mark-list):
      assign vardoc-code = integer(entry (vari, mark-list)).
      find first bf_trn-doc where recid(bf_trn-doc) = vardoc-code no-lock.
      if bf_trn-doc.status_ <> {&fact} then do:
        message "Документ " bf_trn-doc.doc-code " статус " bf_trn-doc.status_ " не в статусе " {&fact} " . Пропускаем." view-as alert-box.
        next .
      end.
      { gbl/objdbnum.i
        bf_trn-doc.obj-type
        bf_trn-doc.obj-code
        v-doc-db-num
        }
      if v-doc-db-num <> v-cntxt-db-num then do:
        message "БД документа с кодом " bf_trn-doc.doc-code " не coвпадает с текущей БД." skip
              "Текущая БД: " v-cntxt-db-num skip "БД док-та: " v-doc-db-num
        view-as alert-box error.
        next.
      end.
      if bf_trn-doc.cr-factur = yes then do:
         message "По документу " bf_trn-doc.doc-code " уже создавался счет-фактура от " bf_trn-doc.factur-date " числа." view-as alert-box.
      end.
      else do:
        define variable v-list as character no-undo .
        run str/gen-scf.p ( input parParentProc, input vardoc-code, "trn-doc", output v-list) no-error .
        if error-status:error then do:
          message "Ошибка создания счета-фактуры по накладной "  bf_trn-doc.doc-code return-value  view-as alert-box.
        end.
      end.
    end.
    assign mark-list = "" .
    run UI-on ("open").
  end. /* do */
end procedure.

procedure proc-m_gen-16 :
define buffer bf_trn-doc for ub.trn-doc.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
define variable v-doc-db-num as integer   no-undo .
do
on error undo, return error return-value
:
  if mark-list = "" then do:
    if available t-doc then assign mark-list = string(recid(t-doc)).
  end.
vari-cycle:
  do vari = 1 to num-entries (mark-list):
    assign vardoc-code = integer(entry (vari, mark-list)).
    find first bf_trn-doc where recid(bf_trn-doc) = vardoc-code exclusive-lock.
    if bf_trn-doc.status_ <> {&fact} then do:
      message "Документ " bf_trn-doc.status_ " не в статусе " {&fact} " . Пропускаем." view-as alert-box.
      next vari-cycle.
    end.
    { gbl/objdbnum.i
      bf_trn-doc.obj-type
      bf_trn-doc.obj-code
      v-doc-db-num
      }

    if v-doc-db-num <> v-cntxt-db-num then do:
      message "БД документа с кодом " bf_trn-doc.doc-code " не coвпадает с текущей БД." skip
              "Текущая БД: " v-cntxt-db-num skip "БД док-та: " v-doc-db-num
      view-as alert-box error.
      next vari-cycle.
    end.
    if bf_trn-doc.cr-factur = yes then do:
      message "По документу " bf_trn-doc.doc-code " уже генерился счет-фактура от " bf_trn-doc.factur-date " числа." view-as alert-box.
      next vari-cycle.
    end.
    else do:
      if bf_trn-doc.need-factur = 1 or bf_trn-doc.need-factur = 2 then assign  bf_trn-doc.need-factur = 0.
      else do:
        message "Данный документ не нуждался в генерации счета-фактуры." view-as alert-box.
        next vari-cycle.
      end.
      reposition {&browse-name} to recid recid(bf_trn-doc) no-error.
      if not error-status:error then do:
        display factur (recid(bf_trn-doc)) @ varfactur with browse {&browse-name}.
      end.
    end.
  end.
  assign mark-list = "".
end.
end.


procedure proc-m_gen-17 :
define buffer bf_trn-doc for ub.trn-doc.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
define variable varcr-incfo as logical no-undo.
define variable varinc-exp  as integer no-undo.
define buffer buf_parts    for ub.parts.
define buffer buf_contract for ub.contract.
define variable v-doc-db-num as integer   no-undo .
do
on error undo, return error return-value
:
  if mark-list = "" then do:
    if available t-doc then assign mark-list = string(recid(t-doc)).
  end.

vari-cycle:
  do vari = 1 to num-entries (mark-list):
    assign vardoc-code = integer(entry (vari, mark-list)).
    find first bf_trn-doc where recid(bf_trn-doc) = vardoc-code exclusive-lock.
    if bf_trn-doc.status_ <> {&fact} then do:
      message "Документ " bf_trn-doc.status_ " не в статусе " {&fact} " . Пропускаем." view-as alert-box.
      next vari-cycle.
    end.
      { gbl/objdbnum.i
        bf_trn-doc.obj-type
        bf_trn-doc.obj-code
        v-doc-db-num
        }

    if v-doc-db-num <> v-cntxt-db-num then do:
      message "БД документа с кодом " bf_trn-doc.doc-code " не coвпадает с текущей БД." skip
              "Текущая БД: " v-cntxt-db-num skip "БД док-та: " v-doc-db-num
      view-as alert-box error.
      next vari-cycle.
    end.
    if bf_trn-doc.cr-factur = yes then do:
      assign
        varlog = no.
        message "По документу " bf_trn-doc.doc-code " был создан счет-фактура от " bf_trn-doc.factur-date " ." skip
                "Вы действительно хотите снять признак, что по этому документу был счет-фактура?"
        view-as alert-box question buttons yes-no update varlog.
       if varlog <> yes then  next vari-cycle.
       assign
         bf_trn-doc.cr-factur   = no
         bf_trn-doc.factur-date = 01/01/1990
       .
       reposition {&browse-name} to recid recid(bf_trn-doc) no-error.
      if not error-status:error then do:
        display factur (recid(bf_trn-doc)) @ varfactur with browse {&browse-name}.
      end.
    end.
    else do:
      message "По документу " bf_trn-doc.doc-code " не было генерации счета-фактуры."
      view-as alert-box.
   end.
 end.
 assign mark-list = "".
end.
end.


procedure proc-m_gen-18 :
define buffer bf_trn-doc for ub.trn-doc.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
define variable varneed-factur as logical no-undo.
define buffer bf_contract for ub.contract.
do
on error undo, return error return-value
:
  if mark-list = "" then do:
    if available t-doc then assign mark-list = string(recid(t-doc)).
  end.

vari-cycle:
  do vari = 1 to num-entries (mark-list):
    assign vardoc-code = integer(entry (vari, mark-list)) .
    find first bf_trn-doc where recid(bf_trn-doc) = vardoc-code exclusive-lock.
    if bf_trn-doc.status_ <> {&fact} then do:
      message "Документ " bf_trn-doc.status_ " не в статусе " {&fact} " . Пропускаем."  view-as alert-box.
      next vari-cycle.
    end.
    if bf_trn-doc.cr-db-num <> v-cntxt-db-num then do:
      message "БД документа с кодом " bf_trn-doc.doc-code " не coвпадает с текущей БД." skip
              "Текущая БД: " v-cntxt-db-num skip "БД док-та: " bf_trn-doc.cr-db-num  " . Пропускаем."
      view-as alert-box error.
      next vari-cycle.
    end.
    if bf_trn-doc.need-factur = 2 then do:
      if bf_trn-doc.contract-code <> 0 then do:
        find first bf_contract where bf_contract.host-code     = bf_trn-doc.host-code   and
                                     bf_contract.contract-code = bf_trn-doc.contract-code no-lock no-error.
        if available bf_contract then do:
          if bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} and
            ( bf_contract.gen-factur = 1 or bf_contract.gen-factur = 11 or bf_contract.gen-factur = 101 or bf_contract.gen-factur = 111 )
           or bf_trn-doc.ext-doc-type = {&TDEDT_Chg_Purch_Code} and
            ( bf_contract.gen-factur = 4 or bf_contract.gen-factur = 14 or bf_contract.gen-factur = 104 or bf_contract.gen-factur = 114 )
            then do:
            assign bf_trn-doc.need-factur = 1  .
            reposition {&browse-name} to recid recid(bf_trn-doc) no-error.
            if not error-status:error then display factur (recid(bf_trn-doc)) @ varfactur with browse {&browse-name}.
          end.
          else message "По документу " bf_trn-doc.doc-code " нет договоров для генерации счета-фактуры."  view-as alert-box.
        end.
      end.
    end.
    else do:
      message "Документ " bf_trn-doc.doc-code "не имеет признака 'не опред' генерация счета-фактуры."
      view-as alert-box.
      next vari-cycle.
    end.
  end.
  assign mark-list = "" .
end.
end procedure.


procedure local-export :
  define variable varxmldocfl      as character no-undo.
  define variable varxmldocfl-type as character no-undo.
define variable v-file-name as character no-undo .
  if not available t-doc then do:
    message "Неправильный выбор документа." view-as alert-box error.
    return no-apply.
  end.
  run str/xml-doc.p ( input t-doc.doc-code, input ? ) no-error.
  if error-status :error
  then do:
    if error-status :get-message( 1 ) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове программы xml-doc.p" skip
        error-status :get-message( 1 ) skip
        return-value
      view-as alert-box error .
    end.
    else do:
      message
        return-value
      view-as alert-box information .
    end.
    return no-apply .
  end.
assign
v-file-name =  str-encode ( replace(t-doc.doc-code , "*", "$") /*p-init-string*/
                          , "" /*p-encode-char    */
                          , {&file-name-invalid-char}  /* p-special-char-list */
                          ) + ".xml".

  if search( "xml-doc.bat" ) <> ? then do:
    define variable v-sys-key   as character         no-undo.
    { gbl/currsysk.i
      v-sys-key
      no-error
    }
    os-command silent value(search ("xml-doc.bat") + {&space-char} + {&double-quote} +  v-file-name + {&double-quote} + {&space-char}  + v-sys-key + {&space-char} + v-cntxt-userid ).
  end.
  else do:
    if search( v-file-name ) <> ? then do:
    message
    substitute("Документ выгружен в файл &1"
                ,v-file-name
              )
    view-as alert-box.
    end.
  end.
end procedure. /* local-export */

procedure entry-notes :
if not available t-doc then do:
  message "Неправильный выбор документа.".
  return no-apply.
end.
pardoc-rec = recid (t-doc).
if t-doc.status_ <> {&fact} and t-doc.discnt-type <> {&cash-desk} and substring (t-doc.PS, 1, 1) = "@" then
  message "Чтобы программа не могла заново переписать Ваше примечание, удалите знак @.".
end.

procedure local-notes:
define variable v-updated as logical no-undo .
do on stop undo, return no-apply:
  find t-d-b where recid (t-d-b) = pardoc-rec exclusive no-error no-wait.
  if not available t-d-b then do:
     message "Запись захвачена другим пользователем." skip
             "Редактирование запрещено."
     view-as alert-box.
  end.
  else do:
    if t-d-b.status_ <> {&fact}
    and ((t-d-b.discnt-type = {&cash-desk}
         or LOOKUP(t-d-b.ext-doc-type, {&sale-add-ext-doc-types}) > 0)
         and
         t-d-b.PS begins {&delim-par})  then do:
      message
      "Примечание к данному документу в данном статусе не может быть отредактировано пользователем."
      view-as alert-box.
    end.
    else
    assign
    t-d-b.PS = input frame {&frame-name} ed-notes
    v-updated = yes
    .
  end.
  if not v-updated then do:
    ed-notes:edit-undo().
  end.
end.
end procedure.

procedure local-value-changed :
if available t-doc then do:
  find cli-buf where cli-buf.obj-type = {&prs} and cli-buf.obj-code = t-doc.boss no-lock no-error.
  if available cli-buf then boss-name = cli-buf.obj-name. else boss-name = ?.
  find cli-buf where cli-buf.obj-type = {&prs} and cli-buf.obj-code = t-doc.agnt no-lock no-error.
  if available cli-buf then agnt-name = cli-buf.obj-name. else agnt-name = ?.
  find cli-buf where cli-buf.obj-type = {&prs} and cli-buf.obj-code = t-doc.wrkr no-lock no-error.
  if available cli-buf then wrkr-name = cli-buf.obj-name. else wrkr-name = ?.
  { gbl/usrfulnm.i
    t-doc.creid
    v-user-name }
  find ub.pay-type where ub.pay-type.obj-code = t-doc.pay-code no-lock no-error.
  if available ub.pay-type then disp ub.pay-type.obj-name with frame {&frame-name}.
  else disp ? @ ub.pay-type.obj-name with frame {&frame-name}.
  ed-notes = t-doc.PS.
  find cli-buf where cli-buf.obj-type = t-doc.obj-type and cli-buf.obj-code = t-doc.obj-code no-lock no-error.
  if available cli-buf then obj-name = cli-buf.obj-name. else obj-name = ?.
  disp ed-notes obj-name boss-name agnt-name wrkr-name  v-user-name with frame {&frame-name}.
  if pardoc-rec <> recid (t-doc) then do:
    sch-num = 0.
    hide sch-num in frame {&frame-name}.
  end.

 define buffer buf_blob-bind for ub.blob-bind  .
 define variable v-blob-uniq-key-rec as character no-undo .

  run gen-key-rec in this-procedure (
       input  {&table_trn-doc}
      ,input  buffer t-doc:handle
      ,output v-blob-uniq-key-rec ).


 if can-find (first buf_blob-bind no-lock where
                buf_blob-bind.uniq-key-rec = v-blob-uniq-key-rec and
                buf_blob-bind.field-name_  = {&blob-trn-doc-image} ) then
    display r-scaner with frame {&frame-name} .
    else hide r-scaner in frame {&frame-name} .
end.
else
   hide r-scaner in frame {&frame-name} .
end procedure.

procedure local-sel :
if not available t-doc then do:
  message "Неправильный выбор документа.".
  return error.
end.
if mark-list <> "" then do:
  assign pardoc-rec = recid (t-doc).
end.
else do:
  mark-list = string(recid(t-doc)).
  assign pardoc-rec = recid (t-doc).
end.
apply "go" to frame {&frame-name}.
end procedure.

procedure local-start-main :
/* для жесткого фильтра по оплате */
find sch-pay where recid (sch-pay) = pardoc-rec no-lock no-error.
/* для жесткого фильтра по валюте */
find sch-curr where recid (sch-curr) = pardoc-rec no-lock no-error.
/* для жесткого фильтра по контр., м-ру, исп-лю, кл-ку */
find sch-cli where recid (sch-cli) = pardoc-rec no-lock no-error.
/* чтобы не усложнять условие жесткого фильтра и использовать в нем par-host-code */
if parlist-mode = {&client-cmp} and available sch-cli and (sch-cli.obj-type = {&stock} or sch-cli.obj-type = {&shop}) then do:
  if sch-cli.obj-type = {&stock} then do:
    find ub.store where ub.store.obj-code = sch-cli.obj-code no-lock.
    if ub.store.host-code <> par-host-code then do:
      message "Список документов, в которых данный склад является контрагентом, смотрите из той фирмы, к которой он относится.".
      return error.
    end.
  end.
  else do:
    find ub.shop where ub.shop.obj-code = sch-cli.obj-code no-lock.
    if ub.shop.host-code <> par-host-code then do:
      message "Список документов, в которых данный магазин является контрагентом, смотрите из той фирмы, к которой он относится.".
      return error.
    end.
  end.
end.
/* для списка мешающих документов по инвентаризации */
find sch-inv where recid (sch-inv) = pardoc-rec no-lock no-error.
if can-do ({&confuse} + ",МЕНЕДЖЕР,ИСПОЛНИТЕЛЬ,КЛАДОВЩИК," + {&client-cmp} + ",ВАЛЮТА,ОПЛАТА",
               parlist-mode) then
  pardoc-rec = ?.
end procedure.

procedure local-conf-rd:
define buffer bf_clients for ub.clients.
define buffer bf_shop    for ub.shop.
define buffer bf_store   for ub.store.
{ gbl/conf-rd.i  "'is-bge'"   "''" "''" 0 "''" "''" "''" no is-bgevalue is-bgetype   no-error }
{ gbl/conf-rd.i  "'is-fin'"   "''" "''" 0 "''" "''" "''" no is-finvalue is-fintype   no-error }
{ gbl/conf-rd.i  "'holding'"  "''" "''" 0 "''" "''" "''" no varhold     varhold-type no-error }
if par-obj-type <> "" and
   par-obj-code <> 0  then do:
  find first bf_clients where bf_clients.obj-type = par-obj-type and
                              bf_clients.obj-code = par-obj-code no-lock.
  if bf_clients.obj-type = {&shop} then do:
    find first bf_shop where bf_shop.obj-code = bf_clients.obj-code no-lock.
    assign
      v_shift = string(bf_shop.shift-on).
  end.
  else do:
    find first bf_store where bf_store.obj-code = bf_clients.obj-code no-lock.
    assign
      v_shift = string(bf_store.shift-on).
  end.
end.
else do:
  assign
    v_shift = "no":u.
end.
end procedure.

procedure local-enable :
define variable v-alcohol-value as character no-undo.
define variable v-alcohol-type  as character no-undo.

ENABLE
b-mark when lookup("b-mark":U, bttns) > 0
b-sel when lookup("b-sel":U, bttns) > 0
b-quit b-lkp b-print b-exp b-history b-sch b-help br-docs b-rep b-f-ed
sch-code sch-date sch-fact sch-objtype sch-objcode sch-sum ed-notes b-uf b-filter-ext b-scaner
b-akt WITH FRAME {&frame-name}.
hide b-copy in FRAME {&frame-name}.
if parext-doc-type = {&TDEDT_Inv} then do:
  enable b-to-inv b-to-update with frame {&frame-name} .
end.
else do:
  hide b-to-inv b-to-update in frame {&frame-name} .
end.
assign
  v-is-lgas = true when lookup({&trdcattr-is-lgas-corr}, bttns) > 0.

/* НЕ ЗНАЮ КОГДА ОН ВИДЕН */
run make-sf-button.
if is-bgevalue = "yes" or is-finvalue = "yes" then do:
  enable b-pay with frame {&frame-name}.
  if is-finvalue = "no" then do:
    assign menu-item m_gen-6 :sensitive  in menu popup-menu-b-pay = no.
    assign menu-item m_gen-8 :sensitive  in menu popup-menu-b-pay = no.
    assign menu-item m_gen-9 :sensitive  in menu popup-menu-b-pay = no.
    assign menu-item m_gen-19 :sensitive  in menu popup-menu-b-pay = no.
    assign menu-item m_gen-11 :sensitive in menu popup-menu-b-pay = no.
    assign menu-item m_gen-12 :sensitive in menu popup-menu-b-pay = no.
    assign menu-item m_gen-20 :sensitive in menu popup-menu-b-pay = no.
    menu-item m_gen-22 :sensitive in menu POPUP-MENU-b-pay = false.
    menu-item m_gen-19 :sensitive in menu POPUP-MENU-b-pay = false.
    menu-item m_gen-21 :sensitive in menu POPUP-MENU-b-pay = false.

  end.
  else do:
  if v-cntxt-db-num <> 0 then
  assign
    MENU-ITEM m_gen-6  :sensitive in menu POPUP-MENU-b-pay = false
    MENU-ITEM m_gen-8  :sensitive in menu POPUP-MENU-b-pay = false
    MENU-ITEM m_gen-9  :sensitive in menu POPUP-MENU-b-pay = false
    MENU-ITEM m_gen-11 :sensitive in menu POPUP-MENU-b-pay = false
    MENU-ITEM m_gen-12 :sensitive in menu POPUP-MENU-b-pay = false
    MENU-ITEM m_gen-13 :sensitive in menu POPUP-MENU-b-pay = false
    MENU-ITEM m_gen-14 :sensitive in menu POPUP-MENU-b-pay = false
  .

{ gbl/conf-rd.i "'is-finby'" "''" "''" 0 "''" "''" "''" no par-is-finby par-type no-error }
if error-status :error then
  assign
    par-is-finby = 'no' .
  .


  assign
    is-finby = lookup(par-is-finby, "true,yes":U) > 0
  .
  if is-finby = false then
      assign
        menu-item m_gen-22 :sensitive in menu POPUP-MENU-b-pay = false
        menu-item m_gen-19 :sensitive in menu POPUP-MENU-b-pay = false
        menu-item m_gen-20 :sensitive in menu POPUP-MENU-b-pay = false
        menu-item m_gen-21 :sensitive in menu POPUP-MENU-b-pay = false
      .


    /*hide b-akt in frame {&frame-name} .*/
    run make-fo-button.
  end.
END.
if parext-doc-type = {&TDEDT_Pri_Vnesh} or parext-doc-type = {&TDEDT_Chg_Purch_Code} then do:
  assign menu-item m_gen-15 :sensitive in menu popup-menu-b-pay = yes.
  assign menu-item m_gen-16 :sensitive in menu popup-menu-b-pay = yes.
  assign menu-item m_gen-17 :sensitive in menu popup-menu-b-pay = yes.
  assign menu-item m_gen-18 :sensitive in menu popup-menu-b-pay = yes.
end.
else do:
  assign menu-item m_gen-15 :sensitive in menu popup-menu-b-pay = no.
  assign menu-item m_gen-16 :sensitive in menu popup-menu-b-pay = no.
  assign menu-item m_gen-17 :sensitive in menu popup-menu-b-pay = no.
  assign menu-item m_gen-18 :sensitive in menu popup-menu-b-pay = no.
end.

if par-obj-type = {&stock} or par-obj-type = {&shop} then do:
  enable b-bc WITH FRAME {&frame-name}.
end.
/*---START--------- Проверка, нужна ли кнопка для внешней программы. Если нужна, включаем b-ext ---------------------*/
run str/run-ext.p ( input ?
                , input table temp_recid-list
                , input {&documents}
                , input "init"
                , output v-ext-button-label
                ) no-error.
if error-status :error
then do:        /* Не выводим кнопку, ошибка при инициализации или нет прав */
    assign
        b-ext :visible   = no
    .
        hide b-ext in frame {&frame-name} .
end.
else do:
    assign
        b-ext :label     = v-ext-button-label
        b-ext :visible   = yes
        b-ext :sensitive = yes
    .
end.

/* Чтобы не пересечься с кнопкой РАСХ+ для внутр прих запросов */
if not(
 parinternal = true        and
 partype     = {&income}   and
 parstat     = {&inquiry} )
then do:
  /* Показываем кнопку "Сопроводительные документы", если включен
     продажный параметр alcohol */
  { gbl/conf-rd.i
    "'alcohol':u"
    "0"
    "''"
    0
    "''"
    "''"
    "''"
    no
    v-alcohol-value
    v-alcohol-type
    no-error
  }
  if (not error-status:error) and (lookup(v-alcohol-value, 'true,yes':u)) > 0 then do:
    enable b-covdocs WITH FRAME {&frame-name}.
  end.
  else do:
    hide b-covdocs in FRAME {&frame-name}.
  end.
end.

end procedure.



procedure make-fo-button :
 do
 on error undo, return error return-value
 :

define variable  but-fo  as widget-handle.
   create button but-fo
   assign
      row = 1
      column = 64
      HEIGHT-CHARS = 1
      WIDTH-CHARS = 9
      label = "Фин.Об&яз"
      tooltip = "Список Фин.обязательств по накладной"
      frame = frame {&frame-name}:handle
      sensitive = true
      visible = true
        triggers:
          on choose persistent run list-fo.
        end triggers.


 end. /* do */
end procedure. /* make-fo-button */



procedure list-fo :
 do
 on error undo, return error return-value
 :
find current t-doc no-lock no-error .
if available t-doc then
run str/fi-trns.w (
    input parparentproc,
    input par-host-code,
    input ?              ,
    input t-doc.doc-code ,
    input "trn-doc":U
    ) .


 end. /* do */
end procedure. /* list-fo */
procedure make-sf-button :
 do
 on error undo, return error return-value
 :

define variable  but-sf  as widget-handle.
   create button but-sf
   assign
      row = 1
      column = 73
      HEIGHT-CHARS = 1
      WIDTH-CHARS = 9
      label = "СчетФакт"
      tooltip = "Список Счетов-фактур по накладной"
      frame = frame {&frame-name}:handle
      sensitive = true
      visible = true
        triggers:
          on choose persistent run list-sf.
        end triggers.


 end. /* do */
end procedure. /* make-fo-button */

procedure list-sf :
 do
 on error undo, return error return-value
 :
define variable v-rid-list as character no-undo .
find current t-doc no-lock no-error .
if available t-doc then
  run str/s-f-docs.w
    ( input parparentproc,
      input par-host-code,
      ?,
      ?,
      ?,
      "td" ,
      t-doc.ext-doc-type,
      t-doc.doc-code,
      "" ,
      input "in-doc",
      input-output v-rid-list
      ) no-error .
 end. /* do */
end procedure. /* list-fo */

procedure create-button :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
 /* Кнопочка РАСХ+ */

/* Только по внутр прих запросам */

if not(
 parinternal = true        and
 partype     = {&income}   and
 parstat     = {&inquiry} ) then return .


define variable  but1  as widget-handle.
   create button but1
   assign
      row = 2.3
      column = 92
      height-chars = 1
      width-chars = 7
      label = "Рас&х+"
      tooltip = "Формирование внут.расходного запроса"
      frame = frame {&frame-name}:handle
      sensitive = true
      visible = true
        triggers:
          on choose persistent run proc-rash-zapr.
        end triggers.
 end. /* do */
end procedure. /* cr-button */


procedure proc-rash-zapr :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
 find current t-doc no-lock no-error .
    if available t-doc then  do:
        run cus/ord-mrz.p
           ( input parparentproc ,
             input recid(t-doc))
             .
    end.
 end. /* do */
end procedure. /* proc-rash-zapr */

procedure proc-m_to-inv :
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer bf_trn-doc  for ub.trn-doc .
  define variable ii          as integer   no-undo .
  define variable ll          as integer   no-undo .
  define variable list-trn    as character no-undo .
  define variable trnDocCode  as character no-undo .
  define variable errorTrnDoc as character no-undo .
  define variable misTrnDoc   as character no-undo .
  define variable glog        as logical   no-undo .
  define variable isManual    as logical   no-undo .
  define variable isMultiTSD  as logical   no-undo .
  define variable trn-doc     as character no-undo .
  define variable isItogInv   as recid no-undo init ?.
  
  define buffer error_inv-doc-attr for ub.inv-doc-attr .
  define buffer error_trn-doc for ub.trn-doc .
  do on error undo, return error return-value :
    if not available t-doc and mark-list = "" then 
    do:
      message "Не выбран документ." view-as alert-box.
      return error.
    end.
    if mark-list = "" then 
    do:
      assign 
        pardoc-rec = recid( t-doc ).

        find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
            ub.inv-doc-attr.attr-code = 'invMultDevice' and ub.inv-doc-attr.attr-value = string(true) no-error .
        if available (ub.inv-doc-attr) then 
        do:
            isMultiTSD = true .
            find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
                ub.inv-doc-attr.attr-code = 'isManual' and ub.inv-doc-attr.attr-value = string(true) no-error .
            if available (ub.inv-doc-attr) then 
            do:
                message "Выбранный документ уже включен в итоговую инвентаризацию"
                    view-as alert-box.
                return error .
            end.     
        end.
      else 
      do:
        find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
          ub.inv-doc-attr.attr-code = 'isManual' and ub.inv-doc-attr.attr-value = string(true) no-error .
        if available (ub.inv-doc-attr) then isManual = true .
      end.
      if isMultiTSD and not isManual then do:
      find first buf_trn-doc no-lock where t-doc.doc-code = entry(1,buf_trn-doc.doc-code,"/") and 
      num-entries(buf_trn-doc.doc-code,"/") > 1 and buf_trn-doc.status_ = {&inquiry} and 
      not buf_trn-doc.flag_ no-error .
      if not available (buf_trn-doc) then 
      do:
        message "У выбранного документа нет документов для объединения"
          view-as alert-box.
        return error .
      end.
      else 
      do:
        for each bf_trn-doc no-lock where t-doc.doc-code = entry(1,bf_trn-doc.doc-code,"/") and 
          num-entries(buf_trn-doc.doc-code,"/") > 1 and bf_trn-doc.status_ = {&inquiry} and not bf_trn-doc.flag_:
          list-trn = list-trn + "," + string(bf_trn-doc.doc-code) .
        end. 
        list-trn = trim(list-trn,",") .
      end.
      trnDocCode = t-doc.doc-code .         
      end.
      if isManual and not isMultiTSD then do:
        find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
        ub.inv-doc-attr.attr-code = "ManualTSD" no-error .
        if available (ub.inv-doc-attr) then do:
          message "На основе документа инвентаризации " + string(t-doc.doc-code) + " уже сформирована итоговая инвентаризация" view-as alert-box.
          mark-list = "" .
          run UI-on in this-procedure ( input "open" ).
          return error.
        end.
        list-trn = t-doc.doc-code .
      end.
      if isManual and isMultiTSD then do:
          message "Выбранные документы относятся к разным инвентаризациям"  view-as alert-box.
          mark-list = "" .
          run UI-on in this-procedure ( input "open" ).
          return error.           
      end.
      if t-doc.status_ <> {&fact} then do:
      message "После создания итогового документа по инвентаризации " + list-trn + " все включенные документы будут заблокированы." skip
        "Внести изменения в полученный документ инвентаризации можно будет вручную или с помощью корректирующего документа, созданного на ТСД" skip
        "Продолжить?"
        view-as alert-box QUESTION buttons YES-NO update glog.
      if not glog then 
      do:
        mark-list = "" .
        run UI-on in this-procedure ( input "open" ).
        return .
      end.
      end.
    end.
    else 
    do:
      do ii = 1 to num-entries(mark-list):
        find first buf_trn-doc no-lock where recid(buf_trn-doc) = integer(entry(ii,mark-list)) no-error .
        if not available (buf_trn-doc) then 
        do:
          message "Не найден документ." view-as alert-box.
          mark-list = "" .
          run UI-on in this-procedure ( input "open" ).
          return error.
        end.

        if buf_trn-doc.status_ = {&inquiry} and not buf_trn-doc.flag_ then 
        do:

      find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
        ub.inv-doc-attr.attr-code = 'invMultDevice' and ub.inv-doc-attr.attr-value = string(true) no-error .
      if available (ub.inv-doc-attr) then do:
      isMultiTSD = true .
         find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
          ub.inv-doc-attr.attr-code = 'isManual' and ub.inv-doc-attr.attr-value = string(true) no-error .
        if available (ub.inv-doc-attr) then do:
            message "Выбранный документ уже включен в итоговую инвентаризацию"
            view-as alert-box.
            return error .
        end.     
      end.
      else do:
        find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
          ub.inv-doc-attr.attr-code = 'isManual' and ub.inv-doc-attr.attr-value = string(true) no-error .
        if available (ub.inv-doc-attr) then isManual = true .
        else do:
        find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
          ub.inv-doc-attr.attr-code = 'isManualError' and ub.inv-doc-attr.attr-value = string(true) no-error .
        if available (ub.inv-doc-attr) then do:
        do ll = 1 to num-entries(mark-list):
          find first error_trn-doc no-lock where recid(error_trn-doc) = integer(entry(ll,mark-list)) no-error .
          if available (error_trn-doc) then do:  
          for first error_inv-doc-attr no-lock where error_inv-doc-attr.doc-code = error_trn-doc.doc-code and
          error_inv-doc-attr.attr-code = 'isManualError' and error_inv-doc-attr.attr-value = string(true):
          if errorTrnDoc = '' then errorTrnDoc = error_inv-doc-attr.doc-code .
          else errorTrnDoc = errorTrnDoc + ", "  + error_inv-doc-attr.doc-code .
          end.  
          end.
        end.        
              message "Выбраны документы" + errorTrnDoc + ", не подлежащие включению в итоговую инвентаризацию! Инвентаризация не создана!"  view-as alert-box.
              mark-list = "" .
              run UI-on in this-procedure ( input "open" ).
              return error.                    
        end.
        else do:
              message "Выбраны документы, не подлежащие включению в итоговую инвентаризацию! Инвентаризация не создана!"  view-as alert-box.
              mark-list = "" .
              run UI-on in this-procedure ( input "open" ).
              return error.                    
        end.          
        end.        
      end.

          if isManual and isMultiTSD then 
          do:
              message "Выбранные документы относятся к разным инвентаризациям"  view-as alert-box.
              mark-list = "" .
              run UI-on in this-procedure ( input "open" ).
              return error.           
          end.
        if  isMultiTSD and not isManual then do:
          if trnDocCode = "" then trnDocCode = entry(1,buf_trn-doc.doc-code,"/").
          else 
          do:
            if trnDocCode <> entry(1,buf_trn-doc.doc-code,"/") then 
            do:
              message "Выбранные документы относятся к разным инвентаризациям"  view-as alert-box.
              mark-list = "" .
              run UI-on in this-procedure ( input "open" ).
              return error.              
            end.
          end.
          end.
        end.
        else 
        do:
      
      find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
        (ub.inv-doc-attr.attr-code = 'ItogInvManual' or ub.inv-doc-attr.attr-code = 'ItogInv') and ub.inv-doc-attr.attr-value <> "" no-error .
      if available (ub.inv-doc-attr) and buf_trn-doc.status_ = {&permitted} and isItogInv = ? then 
      isItogInv = recid(buf_trn-doc) .
      else 
      do:
          message "Выбраны документы, не подлежащие включению в итоговую инвентаризацию! Инвентаризация не создана!" view-as alert-box.
          mark-list = "" .
          run UI-on in this-procedure ( input "open" ).
          return error.
        end.
        end.
        if isManual and not isMultiTSD then do:
        find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
        ub.inv-doc-attr.attr-code = "ManualTSD" no-error .
        if available (ub.inv-doc-attr) then do:
          message "На основе документа инвентаризации " + string(buf_trn-doc.doc-code) + " уже сформирована итоговая инвентаризация" view-as alert-box.
          mark-list = "" .
          run UI-on in this-procedure ( input "open" ).
          return error.
        end.
        end.
        if isItogInv <> recid(buf_trn-doc) then
        list-trn = list-trn + "," + string(buf_trn-doc.doc-code) .
      end.
      list-trn = trim(list-trn,",").
       
      if isMultiTSD then do:
      find first bf_trn-doc no-lock where bf_trn-doc.doc-code = trnDocCode no-error .
      if not available (bf_trn-doc) then do:
          message "По инвентаризации " + string(trnDocCode) + " уже создана итоговая инвентаризация " + string(trnDocCode) + "/и" skip
          "Необходимые изменения можно внести вручную в " + string(trnDocCode) + "/и"
           view-as alert-box.
          mark-list = "" .
          run UI-on in this-procedure ( input "open" ).
          return error.        
      end.  
      for each bf_trn-doc no-lock where trnDocCode = entry(1,bf_trn-doc.doc-code,"/") and 
      num-entries(buf_trn-doc.doc-code,"/") > 1 and bf_trn-doc.status_ = {&inquiry} and not bf_trn-doc.flag_: 
        if lookup(string(bf_trn-doc.doc-code),list-trn) = 0 then 
        do:
          misTrnDoc = misTrnDoc + ", "  + bf_trn-doc.doc-code .
        end.
      end. 
      if misTrnDoc <> "" then 
      do:
        list-trn <> trim(misTrnDoc,", ") .
        message "По инвентаризации " + trnDocCode + " есть другие загруженные документы:" + misTrnDoc skip
          "При продолжении они будут проигнорированы." skip
          "Продолжить?"
          view-as alert-box QUESTION buttons YES-NO update glog.
        if not glog then 
        do:
          mark-list = "" .
          run UI-on in this-procedure ( input "open" ).
          return .
        end.
      end. 
        message "После создания итогового документа по инвентаризации " + trnDocCode + " все включенные документы будут заблокированы." skip
        "Внести изменения в полученный документ инвентаризации можно будет вручную или с помощью корректирующего документа, созданного на ТСД" skip
        "Продолжить?"
          view-as alert-box QUESTION buttons YES-NO update glog.
        if not glog then 
        do:
          mark-list = "" .
          run UI-on in this-procedure ( input "open" ).
          return .
        end.
      end.
    end.
    
    
    
    list-trn = trim(list-trn,",").

    if isManual and isItogInv = ? then run itogInvDocManual(list-trn, output pardoc-rec).
    else if isManual and isItogInv <> ? then run correctItogInvDoc(isItogInv, list-trn, output pardoc-rec).
    else run itogInvDoc(trnDocCode, list-trn, output pardoc-rec).
    mark-list = "" .
    apply "ENTRY":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
    if error-status :error then 
    do:
      find t-doc no-lock where recid( t-doc ) = pardoc-rec. /* буфер ломается при return error */
      return error.
    end.
    
    find t-doc no-lock where recid( t-doc ) = pardoc-rec.

    run UI-on in this-procedure ( input "open" ).
  end. /* on error */
end procedure. /* proc-m_to-inv */

procedure itogInvDocManual :
  define input parameter par-list as character no-undo .
  define output parameter pardoc-rec as recid no-undo .
  
  define variable vardoc-code  as character no-undo .
  define variable ii           as integer   no-undo .
  define variable line-rec     as recid     no-undo .
  define variable old-line-rec as recid     no-undo .
  define variable chg-qnty     like ub.doc-line.fact-qnty no-undo .
  define buffer buf_trn-doc       for ub.trn-doc .
  define buffer bf_trn-doc        for ub.trn-doc .
  define buffer buf_doc-line      for ub.doc-line .
  define buffer bf_doc-line       for ub.doc-line .
  define buffer old_doc-line      for ub.doc-line .
  define buffer buf_trn-doc-sum   for ub.trn-doc-sum .
  define buffer buf_doc-line-sum  for ub.doc-line-sum .
  define buffer bf_curr-accnt     for ub.curr-accnt .
  define buffer bf_sysconf        for ub.sysconf .
  define buffer buf_marking-lines for ub.marking-lines .
  define variable vismsg         as logical   no-undo init true.
  define variable lns-cnt        as integer   no-undo.
  define variable v-marking-type as character no-undo.
  define variable v-type         as character no-undo.
  define variable v-is-marking   as logical   no-undo init false.
  define variable vartime        as integer   no-undo.
  define variable varmessage     as character no-undo.
  
  
  define variable nn as integer no-undo .
  do on error undo, return error return-value : 

    empty temp-table tt-gds-list .
  { str/adinvdoc.i
        v-cntxt-obj-type
        v-cntxt-obj-code
        v-cntxt-userid
        pardoc-rec
        no-error
      }
    if error-status :error then 
    do:
      return error.
    end.

    find bf_trn-doc where recid(bf_trn-doc) = pardoc-rec .
    assign
      bf_trn-doc.tot-calc = ?.

    assign
      bf_trn-doc.PS      = par-list
      .
    create ub.inv-doc-attr .
    assign
      ub.inv-doc-attr.doc-code   = bf_trn-doc.doc-code
      ub.inv-doc-attr.attr-code  = 'ItogInvManual'
      ub.inv-doc-attr.attr-value = par-list
      .
    /*создание атрибута, чтобы не было сообщений, после удалить его*/
    create ub.inv-doc-attr .
    assign
      ub.inv-doc-attr.doc-code   = bf_trn-doc.doc-code
      ub.inv-doc-attr.attr-code  = 'notMes'
      ub.inv-doc-attr.attr-value = string(true)
      .
      
    assign
      vartime = time
      lns-cnt = 0
      .

      do ii = 1 to num-entries(par-list):
        for each buf_doc-line no-lock where buf_doc-line.doc-code = entry(ii,par-list,","):
          find first tt-gds-list where tt-gds-list.artic = buf_doc-line.artic and
          tt-gds-list.prod-code = buf_doc-line.prod-code and
          tt-gds-list.prod-type = buf_doc-line.prod-type no-error .
          if not available (tt-gds-list) then do:
            nn = nn + 1 .
            find first ub.goods no-lock where ub.goods.artic = buf_doc-line.artic and
            ub.goods.prod-code = buf_doc-line.prod-code and
            ub.goods.prod-type = buf_doc-line.prod-type no-error .
            create tt-gds-list.
              BUFFER-COPY ub.goods to tt-gds-list .
              assign tt-gds-list.nn = nn .

          assign
          tt-gds-list.doc-qnty = tt-gds-list.doc-qnty + buf_doc-line.doc-qnty
          tt-gds-list.fact-qnty = tt-gds-list.fact-qnty + buf_doc-line.fact-qnty
          .
          tt-gds-list.itog-qnty = tt-gds-list.doc-qnty - tt-gds-list.fact-qnty .
          end.
          else do:
          assign
          tt-gds-list.doc-qnty = tt-gds-list.doc-qnty + buf_doc-line.doc-qnty 
          tt-gds-list.fact-qnty = tt-gds-list.doc-qnty - tt-gds-list.itog-qnty
          .   
          end.
        end.
      end.
    tr:
    for each tt-gds-list
      break by tt-gds-list.nn
      on error undo tr, next tr
      :
      find ub.goods no-lock
        where  ub.goods.gds-code = tt-gds-list.gds-code .

      assign
        lns-cnt = lns-cnt + 1
        .

      run gds-attr-value (
        input ub.goods.gds-code,
        input {&attr-mark-type},
        output v-marking-type,
        output v-type
        ).

      
      if can-find (first ub.doc-line where ub.doc-line.doc-code = bf_trn-doc.doc-code)
        then 
      do:
        if v-marking-type <> "" and v-marking-type <> "not-type" and
          ((not ObjSrv:Env:ParametrsOfSection:GetSectionEDO(bf_trn-doc.obj-type, bf_trn-doc.obj-code):GetIsMarkingForType(v-marking-type) and (v-is-marking = true))
          or (ObjSrv:Env:ParametrsOfSection:GetSectionEDO(bf_trn-doc.obj-type, bf_trn-doc.obj-code):GetIsMarkingForType(v-marking-type) and v-is-marking = false))
          then 
        do:
          message
            substitute("Ошибка при добавлении строки инвентаризации. Совместное добавление товаров, подлежащих маркировке и не подлежащих маркировке, запрещено.") skip
            view-as alert-box error .
          undo tr, next tr.
        end.
      end.
      else 
      do: 
        if v-marking-type <> "" and v-marking-type <> "not-type" then 
        do:
          if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(bf_trn-doc.obj-type, bf_trn-doc.obj-code):GetIsMarkingForType(v-marking-type)
            then v-is-marking = true.
        end.  
      end. 
      
      find first bf_doc-line where
        bf_doc-line.doc-code  = bf_trn-doc.doc-code         and
        bf_doc-line.artic     = ub.goods.artic     and
        bf_doc-line.prod-type = ub.goods.prod-type and
        bf_doc-line.prod-code = ub.goods.prod-code no-error.
      if available bf_doc-line then 
      do:
        undo tr, next tr.
      end.
      run waitfram-join in this-procedure (  input "Добавление товаров в документ инвентаризации.",
        input substitute( " Добавлено &1.", lns-cnt - 1 ),
        input substitute( " Время &1.", string( time - vartime, "hh:mm:ss":U ) ),
        output varmessage ).
      run waitfram-show in this-procedure (  input varmessage ).
      { str/adinvlin.i
          parparentproc
          bf_trn-doc.doc-code
          ub.goods.artic
          ub.goods.prod-type
          ub.goods.prod-code
          line-rec
          no-error
      }
      if error-status :error then 
      do:
        run waitfram-hide in this-procedure.
        message
          vss-workfile vss-revision vss-description skip
          substitute("Ошибка при добавлении строки инвентаризации") skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo tr, next tr.
      end.
      find first ub.doc-line where recid( ub.doc-line ) = line-rec.
      assign
        ub.doc-line.prt-OK = ?
        .
      if t-doc.status_ = {&permitted} and
        t-doc.flag_   = no           then 
      do:
      { str/filinvln.i
            ub.doc-line.doc-code
            ub.doc-line.artic
            ub.doc-line.prod-type
            ub.doc-line.prod-code
            this-procedure:handle
            no-error
        }
        if error-status :error then 
        do:
          run waitfram-hide in this-procedure.
          message "Ошибка при заполнении сумм по строке товара: "
            ub.doc-line.artic " " ub.doc-line.prod-type " " ub.doc-line.prod-code skip
            return-value skip
            view-as alert-box error.
          undo tr, next tr .
        end.
      end.
    end.

          { gbl/int-clos.i
    parparentproc
    bf_trn-doc.doc-code
    gds-list
    no-error
  }
  if error-status :error then do:
    return .
  end.
            { gbl/int-clos.i
    parparentproc
    bf_trn-doc.doc-code
    gds-list
    no-error
  }
    if error-status :error then do:
    return .
  end.

  for each tt-gds-list:
    for first ub.doc-line exclusive-lock where ub.doc-line.doc-code = bf_trn-doc.doc-code and
    ub.doc-line.artic = tt-gds-list.artic and ub.doc-line.prod-code = tt-gds-list.prod-code and
    ub.doc-line.prod-type = tt-gds-list.prod-type:

              if tt-gds-list.fact-qnty <> 0 then 
      do:

        find first ub.goods no-lock where ub.goods.artic = doc-line.artic and
          ub.goods.prod-code = doc-line.prod-code and
          ub.goods.prod-type = doc-line.prod-type no-error .
        line-rec = recid(doc-line) .
      
        find first old_doc-line no-lock where old_doc-line.doc-code = bf_trn-doc.doc-code and
          old_doc-line.artic = ub.doc-line.artic and
          old_doc-line.prod-code = ub.doc-line.prod-code and
          old_doc-line.prod-type = ub.doc-line.prod-type no-error .
        old-line-rec = recid(old_doc-line) .
        
        find first ub.units   no-lock where ub.units.unit-name    = ub.goods.unit-base.
        find       ub.gds-prt no-lock where ub.gds-prt.upper-code = ub.goods.prt-root.

        run invMulti(
          input parparentproc,
          input pardoc-rec,
          input line-rec,
          input recid(ub.goods),
          input recid (ub.gds-prt),
          input tt-gds-list.fact-qnty,
          input {&g#root}).
                     
      end.

    end.
      
    end.
    run str/clcsumga.p ( input bf_trn-doc.doc-code ).

      for first ub.inv-doc-attr exclusive-lock where
    ub.inv-doc-attr.doc-code = bf_trn-doc.doc-code and
    ub.inv-doc-attr.attr-code = "notMes":
      delete ub.inv-doc-attr .
    end. 
    do ii = 1 to num-entries (par-list):
    create ub.inv-doc-attr .
    assign
    ub.inv-doc-attr.doc-code = entry(ii,par-list)
    ub.inv-doc-attr.attr-code = "ManualTSD"
    ub.inv-doc-attr.attr-value = bf_trn-doc.doc-code .
    end.
  end. /* on error */
end procedure. /* itogInvDocManual */

procedure correctItogInvDoc :
    define input parameter par-ItogInv as recid no-undo .
    define input parameter par-list as character no-undo .
    define output parameter pardoc-rec as recid no-undo .
  
    define variable vardoc-code  as character no-undo .
    define variable ii           as integer   no-undo .
    define variable line-rec     as recid     no-undo .
    define variable old-line-rec as recid     no-undo .
    define variable chg-qnty     like ub.doc-line.fact-qnty no-undo .
    define buffer buf_trn-doc       for ub.trn-doc .
    define buffer bf_doc-line       for ub.doc-line .
    define buffer old_doc-line      for ub.doc-line .
    define buffer buf_trn-doc-sum   for ub.trn-doc-sum .
    define buffer buf_doc-line-sum  for ub.doc-line-sum .
    define buffer bf_curr-accnt     for ub.curr-accnt .
    define buffer bf_sysconf        for ub.sysconf .
    define buffer buf_marking-lines for ub.marking-lines .
    define variable vismsg                     as logical   no-undo init true.
    define variable lns-cnt                    as integer   no-undo.
    define variable v-marking-type             as character no-undo.
    define variable v-type                     as character no-undo.
    define variable v-is-marking               as logical   no-undo init false.
    define variable vartime                    as integer   no-undo.
    define variable varmessage                 as character no-undo.
    define variable p-question                 as integer   no-undo .
    define variable p-first                    as logical   no-undo .
    define variable nn                         as integer   no-undo .
    define variable is-Manual                  as logical   no-undo .
    
    define variable i-total-parts_fact-baseold as decimal   no-undo.
    define variable i-total-parts_fact-rublold as decimal   no-undo.
    define variable i-total-parts_fact-qntyold as decimal   no-undo.

    do on error undo, return error return-value : 

        empty temp-table tt-gds-list .
        empty temp-table tt-gds-list2 .
        
        find bf_trn-doc where recid(bf_trn-doc) = par-ItogInv .
        pardoc-rec = par-ItogInv.
    
        assign
            bf_trn-doc.tot-calc = ?.

        if bf_trn-doc.PS = "" then bf_trn-doc.PS      = par-list .
        else bf_trn-doc.PS      = bf_trn-doc.PS + "," + par-list .
    if num-entries (par-list) > 1 then do:
    run gbl/d-askw_inv.w (
                 input "Корректировка документа"
                ,input "Корректировка документа итоговой инвентаризации " + bf_trn-doc.doc-code + ". " + {&new-line} + {&new-line} + "При использовании нескольких корректирующих документов одновременно функция «Заменить» не доступна. Для использования функции «Заменить» — вам необходимо применять документы коррекции по одному, последовательно." 
                ,input "|"
                ,input "Объединить|Отмена"
                ,input "Суммировать значения по строкам документа коррекции " + par-list + " и итогового документа инвентаризации|Отказ от корректировки итоговой инвентаризации"
                ,input 1
                ,input 2
                ,output p-question).        
                if p-question = 2 then p-question = 3 .
    end.
    else do:
    run gbl/d-askw_inv.w (
                 input "Корректировка документа"
                ,input "Корректировка документа итоговой инвентаризации " + bf_trn-doc.doc-code 
                ,input "|"
                ,input "Объединить|Заменить|Отмена"
                ,input "Суммировать значения по строкам документа коррекции " + par-list + " и итогового документа инвентаризации|Заменить значения по строкам итогового документа инвентаризации на значения по строкам документа коррекции  " + par-list + "|Отказ от корректировки итоговой инвентаризации"
                ,input 1
                ,input 3
                ,output p-question).
     end.           
                
/*        message "Итоговую инвентаризацию " + bf_trn-doc.doc-code + " корректировать: " skip*/
/*            "ДА - добавлять кол-во к кол-ву по товару" skip                                */
/*            "НЕТ - обновлять кол-во по товару" skip                                        */
/*            "ОТМЕНА - отказаться от корректировки итоговой инвентаризации"                 */
/*            view-as alert-box question buttons yes-no-cancel update p-question.            */
/*        if p-question = ? then return .                                                    */
    
if p-question = 3 then return . 
        /*создание атрибута, чтобы не было сообщений, после удалить его*/
        create ub.inv-doc-attr .
        assign
            ub.inv-doc-attr.doc-code   = bf_trn-doc.doc-code
            ub.inv-doc-attr.attr-code  = 'notMes'
            ub.inv-doc-attr.attr-value = string(true)
            .

        create ub.inv-doc-attr .
        assign
            ub.inv-doc-attr.doc-code   = bf_trn-doc.doc-code
            ub.inv-doc-attr.attr-code  = 'correctItogInv'
            ub.inv-doc-attr.attr-value = string(true)
            .

        assign
            vartime = time
            lns-cnt = 0
            .

        for each buf_doc-line no-lock where buf_doc-line.doc-code = bf_trn-doc.doc-code:
            find first ub.goods no-lock where ub.goods.artic = buf_doc-line.artic and
                ub.goods.prod-code = buf_doc-line.prod-code and
                ub.goods.prod-type = buf_doc-line.prod-type no-error .
            create tt-gds-list.
            BUFFER-COPY ub.goods to tt-gds-list .

            assign
                tt-gds-list.doc-qnty  = buf_doc-line.doc-qnty
                tt-gds-list.fact-qnty = buf_doc-line.fact-qnty
                .
            tt-gds-list.itog-qnty = tt-gds-list.doc-qnty - tt-gds-list.fact-qnty .
            nn = nn + 1 .
        end.
      find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = bf_trn-doc.doc-code and
        (ub.inv-doc-attr.attr-code = 'ItogInvManual' or ub.inv-doc-attr.attr-code = 'ItogInv') and ub.inv-doc-attr.attr-value <> "" no-error .
      if available (ub.inv-doc-attr) then do:
          if ub.inv-doc-attr.attr-code = 'ItogInvManual' then do:
              is-Manual = true .
              do ii = 1 to num-entries (par-list):
                  create ub.inv-doc-attr .
                  assign
                      ub.inv-doc-attr.doc-code   = entry(ii,par-list)
                      ub.inv-doc-attr.attr-code  = "ManualTSD"
                      ub.inv-doc-attr.attr-value = bf_trn-doc.doc-code .
              end.
          end.
          else do:
              is-Manual = false .
              do ii = 1 to num-entries (par-list):
                  create ub.inv-doc-attr .
                  assign
                      ub.inv-doc-attr.doc-code   = entry(ii,par-list)
                      ub.inv-doc-attr.attr-code  = "MultiTSD"
                      ub.inv-doc-attr.attr-value = bf_trn-doc.doc-code .
                  create inv-doc-attr .
                  assign
                      inv-doc-attr.doc-code   = entry(ii,par-list)
                      inv-doc-attr.attr-code  = "invMultDevice"
                      inv-doc-attr.attr-value = string(true) .
              end.
          end.
      end.

    assign 
    bf_trn-doc.status_ = {&wayb}
    bf_trn-doc.flag_ = yes
    .
    release bf_trn-doc.
    find bf_trn-doc where recid(bf_trn-doc) = par-ItogInv .

        do ii = 1 to num-entries(par-list):
            for each buf_doc-line no-lock where buf_doc-line.doc-code = entry(ii,par-list,","):
          
                find first tt-gds-list2 where tt-gds-list2.artic = buf_doc-line.artic and
                    tt-gds-list2.prod-code = buf_doc-line.prod-code and
                    tt-gds-list2.prod-type = buf_doc-line.prod-type no-error .
                if not available (tt-gds-list2) then 
                do:
                    nn = nn + 1 .
                    find first ub.goods no-lock where ub.goods.artic = buf_doc-line.artic and
                        ub.goods.prod-code = buf_doc-line.prod-code and
                        ub.goods.prod-type = buf_doc-line.prod-type no-error .
                    create tt-gds-list2.
                    BUFFER-COPY ub.goods to tt-gds-list2 .
                    assign 
                        tt-gds-list2.nn = nn .

                    assign
                        tt-gds-list2.doc-qnty  = tt-gds-list2.doc-qnty + buf_doc-line.doc-qnty
                        tt-gds-list2.fact-qnty = tt-gds-list2.fact-qnty + buf_doc-line.fact-qnty
                        .
                    tt-gds-list2.itog-qnty = tt-gds-list2.doc-qnty - tt-gds-list2.fact-qnty .
                end.
                else 
                do:
                    assign
                        tt-gds-list2.doc-qnty  = tt-gds-list2.doc-qnty + buf_doc-line.doc-qnty 
                        tt-gds-list2.fact-qnty = tt-gds-list2.doc-qnty - tt-gds-list2.itog-qnty
                        .             
                end. 
            end.
        end.
      
      
        for each tt-gds-list2 no-lock:
            find first tt-gds-list where tt-gds-list.gds-code = tt-gds-list2.gds-code no-error .
            if not available (tt-gds-list) then 
            do:
                create tt-gds-list .
                buffer-copy tt-gds-list2 to tt-gds-list .
            end.
            else 
            do:
                if p-question = 1 then 
                do:
                    assign
                        tt-gds-list.doc-qnty  = tt-gds-list.doc-qnty + tt-gds-list2.doc-qnty 
                        tt-gds-list.fact-qnty = tt-gds-list.doc-qnty - tt-gds-list.itog-qnty
                        .     
                end.
                else 
                do:
                    assign
                        tt-gds-list.doc-qnty  = tt-gds-list2.doc-qnty
                        tt-gds-list.fact-qnty = tt-gds-list2.fact-qnty
                        .
                    tt-gds-list.itog-qnty = tt-gds-list.doc-qnty - tt-gds-list.fact-qnty .              
                end.            
            end.
        end.

   
        for each buf_doc-line exclusive-lock where buf_doc-line.doc-code = bf_trn-doc.doc-code:
            find first ub.goods where ub.goods.artic     = buf_doc-line.artic     and
                ub.goods.prod-type = buf_doc-line.prod-type and
                ub.goods.prod-code = buf_doc-line.prod-code no-lock.
            for each ub.marking-attr exclusive-lock where (ub.marking-attr.attr-code = "inv-doc" or ub.marking-attr.attr-code = "inv-doc-scan")
                and can-find (first ub.marking where ub.marking.mark = ub.marking-attr.mark and ub.marking.gds-code = ub.goods.gds-code):
                delete ub.marking-attr.
            end.
            for each ub.utd no-lock where ub.utd.doc-code = buf_doc-line.doc-code:
                for each ub.utd-lines exclusive-lock where ub.utd-lines.db-num = ub.utd.db-num
                    and ub.utd-lines.doc-id =  ub.utd.doc-id and ub.utd-lines.gds-code = ub.goods.gds-code:
                    for each ub.utd-lines-attr exclusive-lock where ub.utd-lines-attr.db-num = ub.utd-lines.db-num
                        and ub.utd-lines-attr.doc-id = ub.utd-lines.doc-id
                        and ub.utd-lines-attr.LineNum = ub.utd-lines.LineNum:
                        delete ub.utd-lines-attr.
                    end.
                    for each ub.utd-marking-lines exclusive-lock where ub.utd-marking-lines.db-num = ub.utd-lines.db-num
                        and ub.utd-marking-lines.doc-id = ub.utd-lines.doc-id
                        and ub.utd-marking-lines.LineNum = ub.utd-lines.LineNum:
                        delete ub.utd-marking-lines.
                    end.
                    delete ub.utd-lines.
                end.
            end.
            run local-reclcinv in this-procedure ( input "old":U ).
            run local-reclcinv in this-procedure ( input "delete":U ).

            run str/dellninv.p ( buffer buf_doc-line ).
        end.

        tr:
        for each tt-gds-list
            break by tt-gds-list.nn
            on error undo tr, next tr
            :
            find ub.goods no-lock
                where  ub.goods.gds-code = tt-gds-list.gds-code .

            assign
                lns-cnt = lns-cnt + 1
                .

            run gds-attr-value (
                input ub.goods.gds-code,
                input {&attr-mark-type},
                output v-marking-type,
                output v-type
                ).

      
            if can-find (first ub.doc-line where ub.doc-line.doc-code = bf_trn-doc.doc-code)
                then 
            do:
                if v-marking-type <> "" and v-marking-type <> "not-type" and
                    ((not ObjSrv:Env:ParametrsOfSection:GetSectionEDO(bf_trn-doc.obj-type, bf_trn-doc.obj-code):GetIsMarkingForType(v-marking-type) and (v-is-marking = true))
                    or (ObjSrv:Env:ParametrsOfSection:GetSectionEDO(bf_trn-doc.obj-type, bf_trn-doc.obj-code):GetIsMarkingForType(v-marking-type) and v-is-marking = false))
                    then 
                do:
                    message
                        substitute("Ошибка при добавлении строки инвентаризации. Совместное добавление товаров, подлежащих маркировке и не подлежащих маркировке, запрещено.") skip
                        view-as alert-box error .
                    undo tr, next tr.
                end.
            end.
            else 
            do: 
                if v-marking-type <> "" and v-marking-type <> "not-type" then 
                do:
                    if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(bf_trn-doc.obj-type, bf_trn-doc.obj-code):GetIsMarkingForType(v-marking-type)
                        then v-is-marking = true.
                end.  
            end. 
      
            find first bf_doc-line where
                bf_doc-line.doc-code  = bf_trn-doc.doc-code         and
                bf_doc-line.artic     = ub.goods.artic     and
                bf_doc-line.prod-type = ub.goods.prod-type and
                bf_doc-line.prod-code = ub.goods.prod-code no-error.
            if available bf_doc-line then 
            do:
                undo tr, next tr.
            end.
            run waitfram-join in this-procedure (  input "Добавление товаров в документ инвентаризации.",
                input substitute( " Добавлено &1.", lns-cnt - 1 ),
                input substitute( " Время &1.", string( time - vartime, "hh:mm:ss":U ) ),
                output varmessage ).
            run waitfram-show in this-procedure (  input varmessage ).
      { str/adinvlin.i
          parparentproc
          bf_trn-doc.doc-code
          ub.goods.artic
          ub.goods.prod-type
          ub.goods.prod-code
          line-rec
          no-error
      }
            if error-status :error then 
            do:
                run waitfram-hide in this-procedure.
                message
                    vss-workfile vss-revision vss-description skip
                    substitute("Ошибка при добавлении строки инвентаризации") skip
                    error-status :get-message(1) skip
                    return-value skip
                    view-as alert-box error .
                undo tr, next tr.
            end.
            find first ub.doc-line where recid( ub.doc-line ) = line-rec.
            assign
                ub.doc-line.prt-OK = ?
                .

            if bf_trn-doc.status_ = {&permitted} and
                bf_trn-doc.flag_   = no           then 
            do:
      { str/filinvln.i
            ub.doc-line.doc-code
            ub.doc-line.artic
            ub.doc-line.prod-type
            ub.doc-line.prod-code
            this-procedure:handle
            no-error
        }
                if error-status :error then 
                do:
                    run waitfram-hide in this-procedure.
                    message "Ошибка при заполнении сумм по строке товара: "
                        ub.doc-line.artic " " ub.doc-line.prod-type " " ub.doc-line.prod-code skip
                        return-value skip
                        view-as alert-box error.
                    undo tr, next tr .
                end.
            end.
        end.
    
    assign 
    bf_trn-doc.status_ = {&permitted}
    bf_trn-doc.flag_ = yes
    .
    release bf_trn-doc.
    find bf_trn-doc where recid(bf_trn-doc) = par-ItogInv .

        for each tt-gds-list:
            for first ub.doc-line exclusive-lock where ub.doc-line.doc-code = bf_trn-doc.doc-code and
                ub.doc-line.artic = tt-gds-list.artic and ub.doc-line.prod-code = tt-gds-list.prod-code and
                ub.doc-line.prod-type = tt-gds-list.prod-type:

                if tt-gds-list.fact-qnty <> 0 then 
                do:

                    find first ub.goods no-lock where ub.goods.artic = doc-line.artic and
                        ub.goods.prod-code = doc-line.prod-code and
                        ub.goods.prod-type = doc-line.prod-type no-error .
                    line-rec = recid(doc-line) .
      
                    find first old_doc-line no-lock where old_doc-line.doc-code = bf_trn-doc.doc-code and
                        old_doc-line.artic = ub.doc-line.artic and
                        old_doc-line.prod-code = ub.doc-line.prod-code and
                        old_doc-line.prod-type = ub.doc-line.prod-type no-error .
                    old-line-rec = recid(old_doc-line) .
        
                    find first ub.units   no-lock where ub.units.unit-name    = ub.goods.unit-base.
                    find       ub.gds-prt no-lock where ub.gds-prt.upper-code = ub.goods.prt-root.

                    run invMulti(
                        input parparentproc,
                        input pardoc-rec,
                        input line-rec,
                        input recid(ub.goods),
                        input recid (ub.gds-prt),
                        input tt-gds-list.fact-qnty,
                        input {&g#root}).
                end.
                for each gds-obj exclusive-lock where gds-obj.artic = doc-line.artic and
                    gds-obj.prod-code = doc-line.prod-code and
                    gds-obj.prod-type = doc-line.prod-type and
                    gds-obj.obj-code = doc-line.obj-code and
                    gds-obj.obj-type = doc-line.obj-type:
                    assign
                        gds-obj.inv-on = true 
                        gds-obj.in-ov  = true .
                end.

      { str/filinvln.i
            ub.doc-line.doc-code
            ub.doc-line.artic
            ub.doc-line.prod-type
            ub.doc-line.prod-code
            this-procedure:handle
            no-error
        }
                if error-status :error then 
                do:
                    run waitfram-hide in this-procedure.
                    message "Ошибка при заполнении сумм по строке товара: "
                        ub.doc-line.artic " " ub.doc-line.prod-type " " ub.doc-line.prod-code skip
                        return-value skip
                        view-as alert-box error.
                end.
            end.
            
        end.

        run str/clcsumga.p ( input bf_trn-doc.doc-code ).

        for first ub.inv-doc-attr exclusive-lock where
            ub.inv-doc-attr.doc-code = bf_trn-doc.doc-code and
            ub.inv-doc-attr.attr-code = "notMes":
            delete ub.inv-doc-attr .
        end. 
        for first ub.inv-doc-attr exclusive-lock where
            ub.inv-doc-attr.doc-code = bf_trn-doc.doc-code and
            ub.inv-doc-attr.attr-code = "correctItogInv":
            delete ub.inv-doc-attr .
        end.     


    end. /* on error */
end procedure. /* correctItogInvDoc */

procedure itogInvDoc :
  define input parameter par-docCode as character no-undo .
  define input parameter par-list as character no-undo .
  define output parameter pardoc-rec   as recid     no-undo .
  define variable vardoc-code  as character no-undo .
  define variable ii           as integer   no-undo .
  
  define variable line-rec     as recid     no-undo .
  define variable old-line-rec as recid     no-undo .
  define variable chg-qnty     like ub.doc-line.fact-qnty no-undo .
  define variable p-document-fact-order like ub.trn-doc.fact-order no-undo .
  
  define variable can-process   as logical no-undo .
  define variable p-fact-close  as logical no-undo .
  define variable p-is-news     as logical no-undo .
  define variable l-reserv-pl-code as logical no-undo .
  define variable v-rvs-list    as character no-undo .
  define variable p-check-inv   as logical no-undo init yes.
  define variable vErrorMessage as character no-undo .
  
  define buffer buf_trn-doc      for ub.trn-doc .
  define buffer bf_trn-doc       for ub.trn-doc .
  define buffer buf_doc-line     for ub.doc-line .
  define buffer bf_doc-line      for ub.doc-line .
  define buffer old_doc-line     for ub.doc-line .
  define buffer buf_trn-doc-sum  for ub.trn-doc-sum .
  define buffer buf_doc-line-sum for ub.doc-line-sum .
  define buffer bf_inv-doc-attr  for ub.inv-doc-attr .
  define buffer buf_goods        for ub.goods .
  define buffer buf_gds-obj      for ub.gds-obj .
  define buffer buf_rvs-doc      for ub.rvs-doc .
  define buffer buf_doc-pl       for ub.doc-pl .
  define buffer inv_doc-line     for ub.doc-line .
  define buffer inv_trn-doc      for ub.trn-doc .
  do on error undo, return error return-value : 
    find first buf_trn-doc exclusive-lock where buf_trn-doc.doc-code = par-docCode no-error .
    if not available (buf_trn-doc) then do:
      message "Не выбран документ для создания итогового документа"
        view-as alert-box.
        return error .
    end.
    if num-entries (buf_trn-doc.doc-code,"/") > 0 then vardoc-code
     = entry (1,buf_trn-doc.doc-code,"/") + "/и" .
    else vardoc-code = buf_trn-doc.doc-code + "/и" .
    if buf_trn-doc.status_ = {&wayb} then 
    do:
    /*Проверка на ошибки в документах запрос*/
    end.
    /*Создание итогового документа в статусе*/
 
    create ub.trn-doc .
    assign
      ub.trn-doc.doc-code = vardoc-code 
      ub.trn-doc.out-code = buf_trn-doc.doc-code
      . 
    if buf_trn-doc.status_ = {&wayb} then 
    do:
      ub.trn-doc.status_ = {&wayb}.
      ub.trn-doc.flag_    = no .
    end.
    else 
    do:
      ub.trn-doc.status_ = {&wayb}.
      ub.trn-doc.flag_    = true .      
    end.

    buffer-copy buf_trn-doc except doc-code status_ flag_ out-code to ub.trn-doc .    
    release ub.trn-doc .
    create ub.inv-doc-attr .
    assign
      ub.inv-doc-attr.doc-code   = vardoc-code
      ub.inv-doc-attr.attr-code  = 'ItogInv'
      ub.inv-doc-attr.attr-value = par-docCode
      .
    /*создание атрибута, чтобы не было сообщений, после удалить его*/
    create ub.inv-doc-attr .
    assign
      ub.inv-doc-attr.doc-code   = vardoc-code
      ub.inv-doc-attr.attr-code  = 'notMes'
      ub.inv-doc-attr.attr-value = string(true)
      .
    do ii = 1 to num-entries (par-list):
    create ub.inv-doc-attr .
    assign
    ub.inv-doc-attr.doc-code = entry(ii,par-list)
    ub.inv-doc-attr.attr-code = "MultiTSD"
    ub.inv-doc-attr.attr-value = vardoc-code .
    end.
    
    /* копирование атрибутов из исходной инвентаризации */
    for each bf_inv-doc-attr no-lock where bf_inv-doc-attr.doc-code = buf_trn-doc.doc-code and
    bf_inv-doc-attr.attr-code <> "invMultDevice":
        create ub.inv-doc-attr.
        assign
        ub.inv-doc-attr.doc-code = vardoc-code
        ub.inv-doc-attr.attr-code = bf_inv-doc-attr.attr-code
        ub.inv-doc-attr.attr-value = bf_inv-doc-attr.attr-value
        .
    end.
    
    /* создание строк */
    for each buf_doc-line no-lock where buf_doc-line.doc-code = par-docCode:
      create ub.doc-line .
      assign
        ub.doc-line.doc-code  = vardoc-code
        ub.doc-line.artic     = buf_doc-line.artic
        ub.doc-line.prod-code = buf_doc-line.prod-code
        ub.doc-line.prod-type = buf_doc-line.prod-type
        ub.doc-line.line-num  = buf_doc-line.line-num
        .
      buffer-copy buf_doc-line except doc-code artic prod-code prod-type line-num to ub.doc-line .
      create tt-line.
      tt-line.fact-qnty = - buf_doc-line.doc-qnty .
      tt-line.doc-qnty  = 0 .
      buffer-copy ub.doc-line except doc-qnty fact-qnty to tt-line . 
      for first ub.gds-obj exclusive-lock where ub.gds-obj.artic = buf_doc-line.artic and
      ub.gds-obj.prod-code = buf_doc-line.prod-code and
      ub.gds-obj.prod-type = buf_doc-line.prod-type and
      ub.gds-obj.obj-code = buf_doc-line.obj-code and
      ub.gds-obj.obj-type = buf_doc-line.obj-type:
        ub.gds-obj.inv-on = false .
      end.
      release ub.doc-line .
    end.
    
      for each ub.parts exclusive-lock where ub.parts.in-code = par-docCode :
      delete ub.parts .
      end. 
    /* Проставляем фактическое значение из накладных запрос*/
/*    if not buf_trn-doc.status_ = {&wayb} then*/
/*    do:                                      */
      { gbl/int-clos.i
    parparentproc
    vardoc-code
    gds-list
    no-error
  }
  if error-status:error then return error .
/*    end.*/
    do ii = 1 to num-entries(par-list):
      for each bf_doc-line no-lock where bf_doc-line.doc-code = entry(ii,par-list):
        find first tt-line exclusive-lock where 
          tt-line.doc-code = vardoc-code and
          tt-line.artic = bf_doc-line.artic and
          tt-line.prod-code = bf_doc-line.prod-code and
          tt-line.prod-type = bf_doc-line.prod-type no-error .
        if not available(tt-line) then 
        do:
        end.
        tt-line.doc-qnty = tt-line.doc-qnty + bf_doc-line.doc-qnty .
        tt-line.fact-qnty = tt-line.fact-qnty + bf_doc-line.doc-qnty .
      end.
    end.
    
    find first buf_trn-doc no-lock where buf_trn-doc.doc-code = vardoc-code .
    pardoc-rec = recid(buf_trn-doc) .
    
    /*Проверка на товары в других инвентаризациях*/
    
    for each tt-line no-lock where tt-line.doc-code = buf_trn-doc.doc-code:
      find first ub.goods no-lock where ub.goods.artic = tt-line.artic and
        ub.goods.prod-code = tt-line.prod-code and
        ub.goods.prod-type = tt-line.prod-type no-error .
      
      /*если остаток не равен 0*/
      if tt-line.fact-qnty <> 0 then 
      do:
        find first ub.doc-line no-lock where ub.doc-line.doc-code = tt-line.doc-code and
          ub.doc-line.artic = tt-line.artic and
          ub.doc-line.prod-code = tt-line.prod-code and
          ub.doc-line.prod-type = tt-line.prod-type no-error .
        if not available (ub.doc-line) then 
        do:
          /*Нет товара в начальной инвентаризации*/
          next .
        end.
        find first ub.goods no-lock where ub.goods.artic = doc-line.artic and
          ub.goods.prod-code = doc-line.prod-code and
          ub.goods.prod-type = doc-line.prod-type no-error .
        line-rec = recid(doc-line) .
      
        find first old_doc-line no-lock where old_doc-line.doc-code = par-docCode and
          old_doc-line.artic = ub.doc-line.artic and
          old_doc-line.prod-code = ub.doc-line.prod-code and
          old_doc-line.prod-type = ub.doc-line.prod-type no-error .
        old-line-rec = recid(old_doc-line) .

        find first ub.units   no-lock where ub.units.unit-name    = ub.goods.unit-base.
        find       ub.gds-prt no-lock where ub.gds-prt.upper-code = ub.goods.prt-root.

        run invMulti(
          input parparentproc,
          input pardoc-rec,
          input line-rec,
          input recid(ub.goods),
          input recid (ub.gds-prt),
          input tt-line.fact-qnty,
          input {&g#root}).
      end.


    end.

/*Проверка целостности товара*/
  for each buf_doc-line no-lock
    where buf_doc-line.doc-code = vardoc-code
  :

    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Документ" buf_doc-line.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return error .
    end.


    { gbl/gdsobjcr.i
      buf_doc-line.obj-type
      buf_doc-line.obj-code
      buf_doc-line.artic
      buf_doc-line.prod-type
      buf_doc-line.prod-code
      buf_gds-obj
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно найти gds-obj" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return error .
    end.

    find current buf_gds-obj exclusive-lock .
    release buf_gds-obj .

    /* проверяем целостность товара
        gds-obj совпадает с корневым prt-obj  и
        с партиями свободной зоны и зарезервированными из свободной зоны
    */
    { gbl/gdscheck.i
      buf_doc-line.obj-type
      buf_doc-line.obj-code
      buf_doc-line.artic
      buf_doc-line.prod-type
      buf_doc-line.prod-code
      ?
      "''"
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при проверке целостности товара" skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        error-status :get-message(1) skip
        view-as alert-box .
      return error .
    end.

    { str/gdnorsrv.i
        buf_doc-line.artic
        buf_doc-line.prod-type
        buf_doc-line.prod-code
        buf_doc-line.doc-code
        can-process
        no-error
    }
    if ( error-status :error
         or can-process <> yes
       )
      and p-fact-close = true
      and p-is-news    = false
    then do:
      { gbl/gdsobjat.i
        buf_doc-line.obj-type
        buf_doc-line.obj-code
        buf_doc-line.artic
        buf_doc-line.prod-type
        buf_doc-line.prod-code
        "'place-rsrv=request'"
        l-reserv-pl-code
        no-error
      }

      /* проверяем, что товары, которые резервируются по складским местам не заблокированы */
      if l-reserv-pl-code = yes then do:
        assign
          v-rvs-list = "":U
        .
        if buf_trn-doc.doc-type = {&income} then do:
          for each buf_rvs-doc no-lock
            where buf_rvs-doc.out-code = buf_trn-doc.doc-code
          on error undo, return error return-value
          :
            if v-rvs-list <> "":U then do:
              assign
                v-rvs-list = v-rvs-list + {&comma-char}
              .
            end.
            assign
              v-rvs-list = v-rvs-list + substitute( "&1", buf_rvs-doc.rvs-code )
            .
          end.
        end.
        for each buf_doc-pl no-lock
          where buf_doc-pl.obj-type = buf_doc-line.obj-type
            and buf_doc-pl.obj-code = buf_doc-line.obj-code
            and buf_doc-pl.out-code = buf_doc-line.doc-code
            and buf_doc-pl.gds-code = buf_goods.gds-code
        on error undo, return error return-value
        :
          run trg/lockplgd.p
            ( input buf_doc-line.obj-type  /* p-obj-type          */
            , input buf_doc-line.obj-code  /* p-obj-code          */
            , input buf_doc-pl.pl-code     /* p-pl-code           */
            , input buf_goods.gds-code     /* p-gds-code          */
            , input "check-rvs-on=false"   /* p-action            */
            , input v-rvs-list             /* p-no-check-rvs-code */
            , input false                  /* p-is-berate         */
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Товар заблокирован на складском месте" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            return error .
          end. /* error */
        end. /* for each buf_doc-pl */
      end. /* if l-reserv-pl-code */
    end. /* if p-fact-close and not p-is-news */

    if p-check-inv = yes then do:
      /* проверяем, нет ли инвентаризации "разр +" по данному товару для данного объекта
      */
      define variable l-inv-on as logical no-undo .
      { gbl/gdsobjat.i
        buf_doc-line.obj-type
        buf_doc-line.obj-code
        buf_doc-line.artic
        buf_doc-line.prod-type
        buf_doc-line.prod-code
        "'inv-on=request'"
        l-inv-on
        no-error
      }
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка получения признака товара на объекте" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return no-apply .
      end.

      if l-inv-on then do:

        define variable v-doc-with-inv as logical no-undo .

        assign
          v-doc-with-inv = false
        .

        for each inv_doc-line no-lock
          where ( inv_doc-line.obj-type      = buf_doc-line.obj-type
                  and inv_doc-line.obj-code  = buf_doc-line.obj-code
                  and inv_doc-line.artic     = buf_doc-line.artic
                  and inv_doc-line.prod-type = buf_doc-line.prod-type
                  and inv_doc-line.prod-code = buf_doc-line.prod-code
                  and inv_doc-line.status_   = {&permitted}
                )
             or ( inv_doc-line.obj-type      = buf_doc-line.obj-type
                  and inv_doc-line.obj-code  = buf_doc-line.obj-code
                  and inv_doc-line.artic     = buf_doc-line.artic
                  and inv_doc-line.prod-type = buf_doc-line.prod-type
                  and inv_doc-line.prod-code = buf_doc-line.prod-code
                  and inv_doc-line.status_   = {&rvs-froze}
                )
        ,first inv_trn-doc no-lock
          where inv_trn-doc.doc-code     = inv_doc-line.doc-code
        :
          if inv_trn-doc.doc-type     = {&inventory}
            and ( inv_trn-doc.status_    = {&permitted}
                  or inv_trn-doc.status_ = {&rvs-froze}
                )
            and inv_trn-doc.flag_        = true
            and inv_trn-doc.ext-doc-type = {&TDEDT_Inv}
          then do:
            if inv_trn-doc.doc-code begins buf_trn-doc.out-code /* игнорируем документы привязанные к инвентаризации */
            then do:
              assign
                v-doc-with-inv = true
              .
            end.
            else do:
              find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'invMultDevice' and
              ub.inv-doc-attr.doc-code = inv_trn-doc.doc-code and
              ub.inv-doc-attr.attr-value = string(true) no-error .
              if not available(ub.inv-doc-attr) then do:
              vErrorMessage = substitute(
                "Товар: &1 &2 &3~n&4~nна объекте &5 &6~nсейчас в инвентаризации (Документ № &7).",
                buf_goods.artic,
                buf_goods.prod-type,
                buf_goods.prod-code,
                buf_goods.gds-name,
                inv_doc-line.obj-type,
                inv_doc-line.obj-code,
                inv_doc-line.doc-code
              ).
                message vErrorMessage view-as alert-box information .
              return error vErrorMessage.
            end.
          end.
        end.
        end.
        for each inv_doc-line no-lock
          where inv_doc-line.obj-type  = buf_doc-line.obj-type
            and inv_doc-line.obj-code  = buf_doc-line.obj-code
            and inv_doc-line.artic     = buf_doc-line.artic
            and inv_doc-line.prod-type = buf_doc-line.prod-type
            and inv_doc-line.prod-code = buf_doc-line.prod-code
            and inv_doc-line.status_   = {&wayb}
        ,first inv_trn-doc no-lock
          where inv_trn-doc.doc-code     = inv_doc-line.doc-code
            and inv_trn-doc.doc-type     = {&inventory}
            and inv_trn-doc.status_      = {&wayb}
            and inv_trn-doc.flag_        = false
            and inv_trn-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price}
        :
          vErrorMessage = substitute(
                "Товар: &1 &2 &3~n&4~nна объекте &5 &6~nсейчас в коррекции учетных цен (Документ № &7).",
                buf_goods.artic,
                buf_goods.prod-type,
                buf_goods.prod-code,
                buf_goods.gds-name,
                inv_doc-line.obj-type,
                inv_doc-line.obj-code,
                inv_doc-line.doc-code
              ).
            message vErrorMessage view-as alert-box information .
          return error vErrorMessage.
        end.
        for each inv_doc-line no-lock
          where inv_doc-line.obj-type  = buf_doc-line.obj-type
            and inv_doc-line.obj-code  = buf_doc-line.obj-code
            and inv_doc-line.artic     = buf_doc-line.artic
            and inv_doc-line.prod-type = buf_doc-line.prod-type
            and inv_doc-line.prod-code = buf_doc-line.prod-code
            and inv_doc-line.status_   = {&wayb}
        ,first inv_trn-doc no-lock
          where inv_trn-doc.doc-code     = inv_doc-line.doc-code
            and inv_trn-doc.doc-type     = {&inventory}
            and inv_trn-doc.status_      = {&wayb}
            and inv_trn-doc.flag_        = false
            and inv_trn-doc.ext-doc-type = {&TDEDT_Peresort}
        : 
          vErrorMessage = substitute(
            "Товар :&1 &2 &3~n&4~nна объекте &5 &6~nсейчас в пересортице (Документ № &7).",
            buf_goods.artic,
            buf_goods.prod-type,
            buf_goods.prod-code,
            buf_goods.gds-name, 
            inv_doc-line.obj-type, 
            inv_doc-line.obj-code,
            inv_doc-line.doc-code).
              message vErrorMessage view-as alert-box information .
          return error vErrorMessage.
        end.

        if v-doc-with-inv = false then do:
          vErrorMessage = substitute(
                "Товар: &1 &2 &3~nна объекте &4 &5~nотмечен, как принадлежащий документу с типом инвентаризация~n~
Документ коррекции учетных цен не найден.",
                buf_goods.artic,
                buf_goods.prod-type,
                buf_goods.prod-code,
                inv_doc-line.obj-type,
                inv_doc-line.obj-code
              ).
            message vErrorMessage view-as alert-box information .
          return error vErrorMessage.
        end.
      end.
    end.


    if false /* p-check-inv-rasr-minus */ then do:


      for each inv_doc-line no-lock
        where inv_doc-line.obj-type     = buf_doc-line.obj-type
          and inv_doc-line.obj-code     = buf_doc-line.obj-code
          and inv_doc-line.artic        = buf_doc-line.artic
          and inv_doc-line.prod-type    = buf_doc-line.prod-type
          and inv_doc-line.prod-code    = buf_doc-line.prod-code
          and inv_doc-line.ext-doc-type = {&TDEDT_Inv}
          and inv_doc-line.status_      = {&permitted}
          and inv_doc-line.doc-code     <> vardoc-code
      ,first ub.trn-doc no-lock
        where ub.trn-doc.doc-code       = inv_doc-line.doc-code
          and ub.trn-doc.flag_          = no
      :
        vErrorMessage = substitute(
          "На объекте &1 &2~nсуществует инвентаризация (Документ №&3) по товару~n&4 &5 &6~n&7~nНаходящаяся в статусе ~"&8&9~".",
          inv_doc-line.obj-type,
          inv_doc-line.obj-code,
          inv_doc-line.doc-code,
          buf_goods.artic,
          buf_goods.prod-type,
          buf_goods.prod-code,
          buf_goods.gds-name,
          STRING(ub.trn-doc.status_),
          STRING(ub.trn-doc.flag_, "+/-")
        ).
            message vErrorMessage view-as alert-box information .
        return error vErrorMessage.
      end.
    end.

  end. /* for each buf_doc-line */
    for each buf_doc-line no-lock
    where buf_doc-line.doc-code = vardoc-code
  :
      for each gds-obj exclusive-lock where gds-obj.artic = buf_doc-line.artic and
        gds-obj.prod-code = buf_doc-line.prod-code and
        gds-obj.prod-type = buf_doc-line.prod-type and
        gds-obj.obj-code = buf_doc-line.obj-code and
        gds-obj.obj-type = buf_doc-line.obj-type:
        assign
          gds-obj.inv-on = true 
          gds-obj.in-ov  = true .
      end.
    end.

    run str/clcsumga.p ( input buf_trn-doc.doc-code ).
    find first t-doc where t-doc.doc-code = vardoc-code no-error .
/*    apply "CHOOSE" to b-close IN FRAME {&FRAME-NAME} .*/
    for first ub.inv-doc-attr exclusive-lock where
    ub.inv-doc-attr.doc-code = vardoc-code and
    ub.inv-doc-attr.attr-code = "notMes":
      delete ub.inv-doc-attr .
    end. 

    find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
      ub.inv-doc-attr.attr-code = 'ItogInv' no-error .
    if available(ub.inv-doc-attr) then 
    do:
      for each ub.trn-doc exclusive-lock where ub.trn-doc.doc-code = ub.inv-doc-attr.attr-value:
        delete ub.trn-doc .
      end.
    end.
  end. /* on error */
end procedure. /* itogInvDoc */

procedure loc-cr-gds-dtl :
  define variable n-c like ub.gds-prt.node-code          no-undo.
  find first ub.gds-dtl where
             ub.gds-dtl.doc-code  = ub.doc-line.doc-code  and
             ub.gds-dtl.artic     = ub.doc-line.artic     and
             ub.gds-dtl.prod-code = ub.doc-line.prod-code and
             ub.gds-dtl.prod-type = ub.doc-line.prod-type no-error.
  if not available ub.gds-dtl then do:
    { gbl/termnode.i ub.goods.prt-root n-c }
    { str/crgdsdtl.i
        ub.doc-line.obj-code
        ub.doc-line.obj-type
        t-doc.doc-code
        ub.doc-line.artic
        ub.doc-line.prod-code
        ub.doc-line.prod-type
        n-c
        yes
    }
    find first ub.gds-dtl where
               ub.gds-dtl.doc-code  = ub.doc-line.doc-code  and
               ub.gds-dtl.artic     = ub.doc-line.artic     and
               ub.gds-dtl.prod-code = ub.doc-line.prod-code and
               ub.gds-dtl.prod-type = ub.doc-line.prod-type and
               ub.gds-dtl.prt-code  = n-c.
    assign
      ub.gds-dtl.fact-qnty = ub.doc-line.doc-qnty
      ub.gds-dtl.doc-qnty  = 0
    .
  end. /* if not available ub.gds-dtl */
end procedure. /* loc-cr-gds-dtl */


procedure proc-m_fact-edit-1 :
define variable varvalue-oldsuppcntr  as character no-undo.
define variable vartype-oldsuppcntr   as character no-undo.
  define variable j_old-rsn like ub.trn-reason.reason-code no-undo.

  do on error undo, return error return-value :
    if not available t-doc then do:
      message "Не выбран документ." view-as alert-box.
      return error.
    end.
    assign pardoc-rec = recid( t-doc ).
    do on stop undo, return error return-value :
      find t-doc exclusive-lock where recid( t-doc ) = pardoc-rec. /* сетевая проверка */
    end.

    assign vardoc-mode = '{&bef-lookup}{&delim-flt}reason-code':U.
    assign j_old-rsn   = t-doc.reason-code.
    case t-doc.doc-type :
      when {&income} then do:
        if t-doc.internal = yes then do:
          run str/out-doc.w ( input        parparentproc,
                              input-output pardoc-rec,
                              input        vardoc-mode,
                              input        ?,
                              input        {&income},
                              input        yes,
                              input-output varnext-prev,
                              input        parext-doc-type,
                              input        paris-hold,
                              input-output varline-rec,
                              input        br-handle,
                              input        bf-handle,
                              input        t-doc.status_        ).
        end. /* internal */
        else do: /* external */
          run str/in-doc.w ( input        parparentproc,
                             input-output pardoc-rec,
                             input        vardoc-mode,
                             input        {&income},
                             input        no,
                             input-output varnext-prev,
                             input        t-doc.ext-doc-type,
                             input        paris-hold,
                             input-output varline-rec,
                             input        br-handle,
                             input        bf-handle,
                             input        t-doc.status_           ).
        end. /* external */
      end. /* {&income} */
      when {&expense}   or
      when {&return}    or
      when {&write-off} then do:
        run str/out-doc.w ( input        parparentproc,
                            input-output pardoc-rec,
                            input        vardoc-mode,
                            input        ?,
                            input        t-doc.doc-type,
                            input        yes,
                            input-output varnext-prev,
                            input        t-doc.ext-doc-type,
                            input        paris-hold,
                            input-output varline-rec,
                            input        br-handle,
                            input        bf-handle,
                            input        t-doc.status_           ).
      end. /* {&expense} */
      when {&inventory} then do:
        if t-doc.ext-doc-type = {&TDEDT_Inv} then do:
          run str/inv-doc.w  ( input        parparentproc,
                               input-output pardoc-rec,
                               input        vardoc-mode,
                               input        {&inventory},
                               input        no,
                               input-output varnext-prev,
                               input        parext-doc-type,
                               input        paris-hold,
                               input-output varline-rec,
                               input        br-handle,
                               input        bf-handle
                           ).
        end. /* t-doc.ext-doc-type = {&TDEDT_Inv} */
        else do:
          if t-doc.ext-doc-type = {&TDEDT_Peresort} then do:
            { str/tdat-val.i
              t-doc.doc-code
              {&trdcattr-oldsuppcntr}
              varvalue-oldsuppcntr
              vartype-oldsuppcntr
              no-error }
            run str/peresort.w
                (input        parparentproc,
                 input-output pardoc-rec,
                 input        vardoc-mode,
                 input        {&TDEDT_Peresort},
                 input-output varnext-prev,
                 input-output varline-rec,
                 input        br-handle,
                 input        bf-handle,
                 input        t-doc.obj-type,
                 input        t-doc.obj-code,
                 input        t-doc.cli-type,
                 input        t-doc.cli-code,
                 input        (if varvalue-oldsuppcntr = "yes":u then yes else no),
                 input        t-doc.contract-code    ) .
          end.
          else do:
            run str/corparts.w
              ( input        parparentproc,
                input-output pardoc-rec,
                input        vardoc-mode,
                input        parext-doc-type,
                input        paris-hold,
                input-output varnext-prev,
                input-output varline-rec,
                input        br-handle ,
                input        bf-handle
                ) no-error  .
                if error-status :error then message
                  vss-workfile vss-revision vss-description skip
                  error-status :get-message(1) skip
                  return-value skip
                  ""
                  view-as alert-box error
                .
          end.
        end.
      end. /* {&inventory} */
    end case. /* t-doc.doc-type */
    apply "ENTRY":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
    if error-status :error then do:
      find t-doc no-lock where recid( t-doc ) = pardoc-rec. /* буфер ломается при return error */
      return error.
    end.
    find t-doc no-lock where recid( t-doc ) = pardoc-rec.

    if t-doc.reason-code <> j_old-rsn and t-doc.status_ = {&fact} then do:
      run str/trn-hist.p
        (buffer t-doc ,
        input  par-obj-type ,
        input  par-obj-code ,
        input  "Изменение причины документа"
        ) no-error .
      if error-status :error then do:
        message
          error-status :get-message(1) skip
          return-value skip
          "Внимание"
          view-as alert-box error .
      end.
    end.

    run UI-on in this-procedure ( input "open" ).
  end. /* on error */
end procedure. /* proc-m_fact-edit-1 */

procedure proc-m_fact-edit-2 :
  define variable jj         as integer no-undo.
  define variable j_rsn-code as integer no-undo.
  define variable j_found    as integer no-undo.
  define variable j_changed  as integer no-undo.
  define variable j_num      as integer no-undo.
  define variable rec-t-doc  as recid   no-undo.
  define variable l_log      as logical no-undo.

  define buffer bf_t-doc  for ub.trn-doc.
  define buffer bf_reason for ub.trn-reason.

  do on error undo, return error return-value :
    assign pardoc-rec = ( if available t-doc then recid( t-doc ) else ? ) no-error.
    assign j_num = num-entries( mark-list ) no-error.
    if error-status :error or mark-list = ? or mark-list = "":U or j_num = 0 then do:
      message "Список не определен." view-as alert-box error.
      return.
    end.
    run str/trn-reas.w ( input parparentproc, input {&choose}, input-output j_rsn-code ).
    find bf_reason no-lock where
         bf_reason.reason-code = j_rsn-code no-error.
    if not available bf_reason then do:
      assign l_log = no.
      message {&tabulation} "Код не выбран." skip
              "Хотите обнулить все коды оснований (причин) из списка?"
      view-as alert-box question buttons yes-no update l_log.
      if l_log = yes then do: assign j_rsn-code = 0. end.
                     else do: return. end.
    end.
    {&SetCursorWait}
    do jj = 1 to j_num :
      assign rec-t-doc = integer( entry( jj, mark-list ) ) no-error.
      if error-status :error then do: next. end.
      find first bf_t-doc exclusive-lock where recid( bf_t-doc ) = rec-t-doc no-error.
      if not available bf_t-doc then do: next. end.
      if bf_t-doc.reason-code <> j_rsn-code then do:
        if bf_t-doc.status_ = {&fact} then do:
          run str/trn-hist.p
            (buffer bf_t-doc ,
            input  par-obj-type ,
            input  par-obj-code ,
            input  "Изменение причины документа"
            ) no-error .
          if error-status :error then do:
            message
              error-status :get-message(1) skip
              return-value skip
              "Внимание"
              view-as alert-box error .
          end.

          if error-status :error then do:
            assign j_found = j_found + 1.
            next.
          end.
        end.
        assign bf_t-doc.reason-code = j_rsn-code
               j_changed            = j_changed  + 1.
      end.
      find first bf_t-doc        no-lock where recid( bf_t-doc ) = rec-t-doc no-error.
      assign j_found = j_found + 1.
    end.
    assign mark-list = "":U.
    run UI-on in this-procedure ( input "open" ).
    {&SetCursorNo}
    message "Изменение кодов оснований (причин) создания документов по выбранным документам завершено." skip( 0 )
            {&tabulation} "Всего документов в списке:"   j_num                 skip( 0 )
            {&tabulation} "Найдено:"                     j_found               skip( 0 )
            {&tabulation} "Изменено:"                              j_changed   skip( 0 )
            {&tabulation} "Совпало кодов:"             ( j_found - j_changed ) skip( 0 )
    view-as alert-box information.
    {&SetCursorNo}
  end. /* on error */
end procedure. /* proc-m_fact-edit-2 */

procedure init-browse-p :
/* Настройки экрана по пользователю */
  do
  on error undo, return error return-value
  :

define variable cur-clmn-loc as integer   no-undo .
define variable column-handle as handle no-undo .


  assign
    cur-clmn-loc  = 1
    column-handle = {&browse-name}:first-column   in frame {&frame-name}
    hcolumn [cur-clmn-loc] = column-handle
  .

  do while valid-handle(column-handle) :
    if cur-clmn-loc = {&browse-name}:num-columns then do:
      leave .
    end.
    assign
      column-handle = column-handle:NEXT-COLUMN
      cur-clmn-loc  = cur-clmn-loc + 1
      hcolumn [cur-clmn-loc] = column-handle
    .
  end.

run uf-get in this-procedure (
     input  {&uf-all-docs}
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
    ) no-error  .
    if error-status :error then message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "e"
      view-as alert-box error
    .

v-order-column  =  (entry(1, v-uf-List_ ,{&delim-par})) no-error.
v-spis-size     =  (entry(2, v-uf-List_ ,{&delim-par})) no-error.
v-spis-vis      =  (entry(3, v-uf-List_ ,{&delim-par})) no-error.

/*
message 'проверим что в uf' {&uf-all-docs} v-cntxt-userid skip
'v-order-column ' v-order-column skip
'v-spis-size    ' v-spis-size    skip
'v-spis-vis     ' v-spis-vis     skip
"кол-во кол" {&browse-name} :NUM-COLUMNS  in frame {&frame-name}
.
*/

if v-order-column  = ? or v-order-column  = "" or error-status :error  then  v-order-column = {&all-docs-p-ord}.
if v-spis-size     = ? or v-spis-size    = ""  or error-status :error  then  v-spis-size    = {&all-docs-p-siz}.
if v-spis-vis      = ? or v-spis-vis     = ""  or error-status :error  then  v-spis-vis     = {&bef-all-docs-p-vis}.

define variable col-h as handle no-undo .
define variable ii as integer   no-undo .
define variable dd as integer   no-undo .

repeat ii = 1 to cur-clmn-loc   :
    col-h = hcolumn [ ii ]  .
    dd = decimal(entry(ii,v-spis-size)) no-error .
    if dd = 0 then message "Обнаружена новая колонка с длиной = 0 !".
    col-h:width  = decimal(entry(ii,v-spis-size))   no-error .
    col-h:visible  = logical(entry(ii,v-spis-vis))  no-error .
 end.

  end.

end procedure. /* init-browse-p */
procedure proc-l-b :
  do
  on error undo, return error return-value
  :
define variable cur-clmn-loc as integer   no-undo .
define variable column-handle as handle no-undo .
define variable v-list as character no-undo .
define variable v-list-size as character no-undo .
define variable v-list-name as character no-undo .
define variable v-list-vis as character no-undo .

  assign
    cur-clmn-loc  = 1
    column-handle = {&browse-name}:first-column   in frame {&frame-name}
    v-list        = column-handle:label + ","
    v-list-size   = string(column-handle:width) + ","
    v-list-vis    = string(column-handle:visible) + ","
    hcolumn [cur-clmn-loc] = column-handle
  .

  do while valid-handle(column-handle) :
    if cur-clmn-loc = {&browse-name}:num-columns then do:
      leave .
    end.
    assign
      column-handle = column-handle:NEXT-COLUMN
      cur-clmn-loc  = cur-clmn-loc + 1
      v-list        = v-list + column-handle:label + ","
      v-list-size   = v-list-size + string(column-handle:width) + ","
      v-list-vis    = v-list-vis + string(column-handle:visible) + ","
      hcolumn [cur-clmn-loc] = column-handle
    .
  end.
  end.

end procedure. /* proc-l-b */


procedure get-browse-buffer-handle :
define output parameter p-browse-buffer-handle      as handle           no-undo.

do
on error undo, return error
:
    assign
        p-browse-buffer-handle = buffer t-doc :handle in frame {&frame-name}
    .
end.
end procedure. /* get-browse-buffer-handle */


procedure get-browse-query-handle :
define output parameter p-browse-query-handle      as handle           no-undo.

do
on error undo, return error
:
    assign
        p-browse-query-handle = query br-docs :handle in frame {&frame-name}
    .
end.
end procedure. /* get-browse-buffer-handle */

procedure proc-check-inv : /* проверка товаров в инвентаризации на кол-во = 0 и было ли движение товара */
    define buffer buf_trn-doc  for ub.trn-doc .
    define buffer buf_doc-line for ub.doc-line .
    define buffer buf_parts    for ub.parts .
    define buffer buf_goods    for ub.goods .
    do
        on error undo, return error return-value
        :
        EMPTY TEMP-TABLE tt-gds-line-err .

        for each buf_doc-line no-lock where buf_doc-line.doc-code = t-doc.doc-code 
            and (buf_doc-line.doc-qnty - buf_doc-line.fact-qnty) = 0 and buf_doc-line.doc-qnty > 0:
            /* Проверка, если кол-во было = 0, посмотреть было ли движение у товара на объекте */

            find first buf_parts where buf_parts.obj-code = t-doc.obj-code and
                buf_parts.obj-type = t-doc.obj-type and buf_parts.artic = buf_doc-line.artic and
                buf_parts.prod-code = buf_doc-line.prod-code and buf_parts.prod-type = buf_doc-line.prod-type and
                buf_parts.out-code <> t-doc.doc-code no-error .
                if not available (buf_parts) then
            do:
                find first buf_goods no-lock where buf_goods.artic = buf_doc-line.artic and
                    buf_goods.prod-code = buf_doc-line.prod-code and buf_goods.prod-type = buf_doc-line.prod-type no-error .
                create tt-gds-line-err .
                assign
                    tt-gds-line-err.artic       = buf_doc-line.artic
                    tt-gds-line-err.prod-code   = buf_doc-line.prod-code
                    tt-gds-line-err.prod-type   = buf_doc-line.prod-type
                    tt-gds-line-err.qnty-tsd    = buf_doc-line.doc-qnty
                    tt-gds-line-err.date-report = today
                    tt-gds-line-err.time-report = time .
                tt-gds-line-err.gds-name = if available (buf_goods) then buf_goods.gds-name else '' .
            
            end.
        end.
        if can-find (tt-gds-line-err) then 
        do:
            define variable v-name-txt as character no-undo .
            v-name-txt = session:temp-directory + '/' + 'errors-inv' + ".txt".
            
            if search(v-name-txt) <> ? then
            do:
                os-delete value(v-name-txt ).
            end.
            output to value(v-name-txt) .
            for each tt-gds-line-err:
                export string (tt-gds-line-err.date-report,"99/99/9999") string (tt-gds-line-err.time-report,"HH:MM:SS") "Ошибка при загрузке в инвентаризацию товара: " string (tt-gds-line-err.gds-name) 
                    "Артикул: " string (tt-gds-line-err.artic) "кол-во: " string (tt-gds-line-err.qnty-tsd) .
            end.
            output close .
        
       
            message "Не все товары загружены в документ инвентаризации " + t-doc.doc-code + "!" skip 
                "Список незагруженных товаров выведен в файл " + v-name-txt + "" skip
                view-as alert-box.
                
           if search(v-name-txt) <> ? then os-command no-wait value(v-name-txt).
           else 
           do:
               message "Файл " + v-name-txt + " не найден"
                   view-as alert-box.
           end.
              
/*            run rep/errors-inv.p (                    */
/*                input parparentproc,                  */
/*                input table tt-gds-line-err) no-error.*/
    
        end.
    end. /* do */
end procedure. /*  proc-check-inv */

procedure proc-close-inv : /* проверка товаров в инвентаризации на кол-во = 0 и было ли движение товара */
    define output parameter v-show-err-message as logical no-undo .
    define buffer buf_trn-doc  for ub.trn-doc .
    define buffer buf_doc-line for ub.doc-line .
    define buffer buf_parts    for ub.parts .
    define buffer buf_goods    for ub.goods .

    do
        on error undo, return error return-value
        :
        v-show-err-message = true .

        EMPTY TEMP-TABLE tt-gds-line-err .

        for each buf_doc-line no-lock where buf_doc-line.doc-code = t-doc.doc-code 
            and (buf_doc-line.doc-qnty - buf_doc-line.fact-qnty) = 0 and buf_doc-line.doc-qnty > 0:
            /* Проверка, если кол-во было = 0, посмотреть было ли движение у товара на объекте */

            find first buf_parts where buf_parts.obj-code = t-doc.obj-code and
                buf_parts.obj-type = t-doc.obj-type and buf_parts.artic = buf_doc-line.artic and
                buf_parts.prod-code = buf_doc-line.prod-code and buf_parts.prod-type = buf_doc-line.prod-type and
                buf_parts.out-code <> t-doc.doc-code no-error .
                if not available (buf_parts) then 
            do:
                find first buf_goods no-lock where buf_goods.artic = buf_doc-line.artic and
                    buf_goods.prod-code = buf_doc-line.prod-code and buf_goods.prod-type = buf_doc-line.prod-type no-error .
                create tt-gds-line-err .
                assign
                    tt-gds-line-err.artic       = buf_doc-line.artic
                    tt-gds-line-err.prod-code   = buf_doc-line.prod-code
                    tt-gds-line-err.prod-type   = buf_doc-line.prod-type
                    tt-gds-line-err.qnty-tsd    = buf_doc-line.doc-qnty
                    tt-gds-line-err.date-report = today
                    tt-gds-line-err.time-report = time .
                tt-gds-line-err.gds-name = if available (buf_goods) then buf_goods.gds-name else '' .
            
            end.    
        end.
        if can-find (tt-gds-line-err) then 
        do:
            define variable v-name-txt as character no-undo .
            v-name-txt = session:temp-directory + '/' + 'errors-inv' + ".txt".
            
            if search(v-name-txt) <> ? then
            do:
                os-delete value(v-name-txt ).
            end.
            output to value(v-name-txt) .
            for each tt-gds-line-err:
                export string (tt-gds-line-err.date-report,"99/99/9999") string (tt-gds-line-err.time-report,"HH:MM:SS") "Ошибка при загрузке в инвентаризацию товара: " string (tt-gds-line-err.gds-name) 
                    "Артикул: " string (tt-gds-line-err.artic) "кол-во: " string (tt-gds-line-err.qnty-tsd) .
            end.
            output close .
        
       
            message "Не все товары загружены в документ инвентаризации " + t-doc.doc-code + "!" skip 
                "Список незагруженных товаров выведен в файл " + v-name-txt + "" skip
                "Вы уверены, что хотите закрыть документ инвентаризации до «факта»?"
                view-as alert-box question buttons yes-no update v-show-err-message .
            if not v-show-err-message then do:
            run rep/errors-inv.p (
                input parparentproc,
                input table tt-gds-line-err) no-error.
            end.
        end.
    end. /* do */
end procedure. /*  proc-close-inv */

procedure local-reclcinv :
  define input parameter parmode as character no-undo.

  do on error undo, return error return-value :
    { str/reclcinv.i
        parmode
        recid(buf_doc-line)
        bf_trn-doc.doc-code
        bf_trn-doc.tot-doc
        bf_trn-doc.tot-rubl
        bf_trn-doc.tot-ov
        bf_trn-doc.fact-rubl
        bf_trn-doc.fact-base
        bf_trn-doc.fact-qnty
        bf_trn-doc.doc-qnty
        bf_trn-doc.cli-qnty
        i-total-parts_fact-baseold
        i-total-parts_fact-rublold
        i-total-parts_fact-qntyold
    }
  end. /* on error */
end procedure. /* local-reclcinv */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-mark-list W-Win
PROCEDURE get-mark-list :
/* -----------------------------------------------------------
  Purpose: возвращается список отмеченных накладных по колбеку
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-mark-list as character no-undo .
  p-mark-list = mark-list .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&UNDEFINE BROWSE-NAME
&UNDEFINE FRAME-NAME
&UNDEFINE WINDOW-NAME