/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/01/10
Author: Bakhtadze Natalya
Creation date: 04/01/10

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
/*
libfarhp_calc-arh-fin-doc-an                    arh-fin-doc-an
libfarhp_calc-arh-fin-doc-an-n                  arh-fin-doc-an-nal
libfarhp_calc-arh-fin-doc-contr-schet           arh-fin-doc-contr-schet
libfarhp_calc-arh-fin-doc-contr-schet-n         arh-fin-doc-contr-schet-nal
libfarhp_calc-arh-fin-doc-contr-schet-tax       arh-fin-doc-contr-schet-tax
libfarhp_calc-arh-fin-doc-contr-schet-tax-n     arh-fin-doc-c-schet-tax-nal
libfarhp_calc-arh-fin-doc-schet                 arh-fin-doc-schet
libfarhp_calc-arh-fin-doc-schet-n               arh-fin-doc-schet-nal
libfarhp_calc-arh-fin-doc-schet-tax             arh-fin-doc-schet-tax
libfarhp_calc-arh-fin-doc-schet-tax-n           arh-fin-doc-schet-tax-nal

libfarpo_calc-arh-fin-doc-contr-schet-obj       arh-fin-doc-contr-schet-obj
libfarpo_calc-arh-fin-doc-contr-schet-n-obj     arh-fin-doc-contr-s-nal-obj
libfarpo_calc-arh-fin-doc-contr-schet-tax-obj   arh-fin-doc-contr-s-tax-obj
libfarpo_calc-arh-fin-doc-contr-schet-tax-n-obj arh-fin-doc-c-s-tax-nal-obj
libfarpo_calc-arh-fin-doc-schet-obj             arh-fin-doc-schet-obj
libfarpo_calc-arh-fin-doc-schet-n-obj           arh-fin-doc-schet-nal-obj
*/

&glob arh-fin-doc-an-atom '':U

/*Итоговая в разрезе счета по коду аналитического учета*/
&glob arh-fin-doc-an-sum-an-uchet  'sum-schet-uchet':U

/*Итоговая в разрезе счета по коду целевого назначения*/
&glob arh-fin-doc-an-sum-cel-nazn  'sum-schet-cel-nazn':U

/*Итоговая в разрезе счета по корреспондирующему счету*/
&glob arh-fin-doc-an-sum-cor-acc   'sum-schet-cor-acc':U

&glob arh-fin-doc-an-nal-atom        '':U

/*суммарная без учета валюты платежа - в р у б л я х */
&glob arh-fin-doc-an-nal-sum-rubl     'sum-rubl':U

/*суммарная без учета валюты платежа - в base */
&glob arh-fin-doc-an-nal-sum-base    'sum-base':U

/*Суммарная без учета кодов и счетов*/
&glob arh-fin-doc-an-nal-without-schet     'sum-without-schet-code':U

/*Итоговая по коду аналитического учета*/
&glob arh-fin-doc-an-nal-sum-an-uchet       'sum-uchet':U

/*Итоговая по коду аналитического учета в нац вал*/
&glob arh-fin-doc-an-nal-sum-rubl-an-uchet       'sum-rubl-uchet':U

/*Итоговая по коду аналитического учета в баз вал*/
&glob arh-fin-doc-an-nal-sum-base-an-uchet       'sum-base-uchet':U

/*Итоговая по коду целевого назначения*/
&glob arh-fin-doc-an-nal-sum-cel-nazn       'sum-cel-nazn':U

/*Итоговая по коду целевого назначения в на цвал */
&glob arh-fin-doc-an-nal-sum-rubl-cel-nazn       'sum-rubl-cel-nazn':U

/*Итоговая по коду целевого назначения в баз вал */
&glob arh-fin-doc-an-nal-sum-base-cel-nazn       'sum-base-cel-nazn':U

/*Итоговая по корреспондирующему счету*/
&glob arh-fin-doc-an-nal-sum-cor-acc     'sum-cor-acc':U

/*Итоговая по корреспондирующему счету в нац вал*/
&glob arh-fin-doc-an-nal-sum-rubl-cor-acc 'sum-rubl-cor-acc':U

/*Итоговая по корреспондирующему счету в баз вал*/
&glob arh-fin-doc-an-nal-sum-base-cor-acc 'sum-base-cor-acc':U

&glob arh-fin-doc-contr-schet-atom  '':U

&glob arh-fin-doc-contr-schet-sum-contract  'sum-contract':U

&glob arh-fin-doc-contr-schet-obj-atom     '':U

&glob arh-fin-doc-contr-schet-obj-sum-contract     'sum-contract':U

&glob arh-fin-doc-contr-schet-nal-atom  '':U

&glob arh-fin-doc-contr-schet-nal-sum-contract  'sum-contract':U

&glob arh-fin-doc-contr-s-nal-obj-atom '':U

&glob arh-fin-doc-contr-s-nal-obj-sum-contract 'sum-contract':U

&glob arh-fin-doc-contr-schet-tax-atom '':U

&glob arh-fin-doc-contr-schet-tax-sum-contract 'sum-contract':U

&glob arh-fin-doc-contr-s-tax-obj-atom '':U

&glob arh-fin-doc-contr-s-tax-obj-sum-contract 'sum-contract':U

&glob arh-fin-doc-c-schet-tax-nal-atom '':U

&glob arh-fin-doc-c-schet-tax-nal-sum-contract 'sum-contract':U

&glob arh-fin-doc-c-s-tax-nal-obj-atom '':U

&glob arh-fin-doc-c-s-tax-nal-obj-sum-contract 'sum-contract':U


/*ВНИМАНИЕ!!! sum-type типа firm obj firm-wothout-obj обирают суммы согласно места платежа (ОП КАССА t t n - d o c - c o d e а не obj-type obj-code host-code*/

/*был*/
&glob arh-fin-doc-schet-atom '':U

/*добавлен*/
/*все суммы по фирме*/
&glob arh-fin-doc-schet-firm 'firm':U

/*добавлен*/
/*все суммы по фирме кроме оп касс или лок бухг*/
&glob arh-fin-doc-schet-firm-without-obj 'firm-without-obj':U

/*добавлен*/
&glob arh-fin-doc-schet-obj-atom '':U

/*добавлен*/
/*только записи опц кассы или лок бухгалт*/
&glob arh-fin-doc-schet-obj-obj 'obj':U

/*добавлен*/
/*только записи опц кассы или лок бухгалт*/
&glob arh-fin-doc-schet-obj-shift-obj 'shift-obj':U

/*был*/
&glob arh-fin-doc-schet-nal-atom '':U

/*добавлен*/
/*все суммы по фирме*/
&glob arh-fin-doc-schet-nal-firm 'firm':U

/*добавлен*/
/*все суммы по фирме кроме оп касс или лок бухг*/
&glob arh-fin-doc-schet-nal-firm-without-obj 'firm-without-obj':U


/*добавлен*/
&glob arh-fin-doc-schet-nal-obj-atom '':U

/*добавлен*/
/*только записи опц кассы или лок бухгалт*/
&glob arh-fin-doc-schet-nal-obj-obj 'obj':U

/*добавлен*/
/*только записи опц кассы или лок бухгалт*/
&glob arh-fin-doc-schet-nal-obj-shift-obj 'shift-obj':U

&glob arh-fin-doc-schet-tax-atom '':U

&glob arh-fin-doc-schet-tax-nal-atom '':U

/* $Workfile$ e n d */