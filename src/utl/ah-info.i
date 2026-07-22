/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Таблица, описывающая текущее состояние складского архива

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 11/13/01

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table temp-obj-arh no-undo
  field db-num                   as integer format ">9" label "БД"
  field obj-type                 like ub.clients.obj-type
  field obj-code                 like ub.clients.obj-code
  field archive-type             as character label "Архив"
  field sort-code                as integer
  field obj-deleted              as logical   label "У" format "У/ "

  field archive-calc             as logical   format "+/-":U         label 'Не рассчитан оборот'
  field archive-del              as logical   format "+/-":U         label 'Не рассчитан нач.остаток'
  field archive-disable          as logical   format "+/-":U         label 'Расчет архива запрещен'
  field archive-rest             as logical   format "+/-":U         label 'Сбой удал./восст.'
  field archive-bpexist          as logical   format "+/-":U         label 'Имеются задания на расчет'
  field archive-detail-date      as date      format '99/99/9999':u  label 'Подробный'
  field archive-start-date       as date      format '99/99/9999':u  label 'Сжатый'
  field archive-recalc-date      as date      format '99/99/9999':u  label 'Перерасчёт'
  field archive-lock-prc         as logical                          label 'Расчёт'
  field archive-execuser         like ub.batchprocess.bp_execuser_id label 'Пользователь' column-label 'Пользователь'
  field archive-execsysdate      like ub.batchprocess.bp_execsysdate label 'Дата'         column-label 'Дата'
  field archive-execsystime      like ub.batchprocess.bp_execsystime label 'Время'        column-label 'Время'
  field archive-rest-lock-prc    as logical                          label 'Расчёт'
  field archive-rest-execuser    like ub.batchprocess.bp_execuser_id label 'Пользователь' column-label 'Пользователь'
  field archive-rest-execsysdate like ub.batchprocess.bp_execsysdate label 'Дата'         column-label 'Дата'
  field archive-rest-execsystime like ub.batchprocess.bp_execsystime label 'Время'        column-label 'Время'

  index xpk is primary unique obj-type obj-code archive-type
  index ie1 db-num obj-type obj-code archive-type
.
/* $Workfile$ e n d */