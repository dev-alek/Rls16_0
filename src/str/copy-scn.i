/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Копирование в документ со сканера

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич


*/
&scop proc-name lib-trn_copy-scn
{&run_proc_lib-trn}
  ( input  {1}  /*parparentproc*/
   ,input  {2}  /*parrec-doc   recid документа в который копируем*/
   ,input  {3}  /*parb-code    бар-код*/
   ,input  {4}  /*b-qnty       количество*/
   ,input  {5}  /*paris-all    не задавать вопросы*/
   ,input  {6}  /*paradd-sens  кнопка "добавить" доступна*/
   ,input  {7}  /*parline-mode если введен бар-код в накладной, то "b-c"*/
   ,output {8}  /*parmes       сообщение*/
   ,output {9}  /*parok        возврат числа*/
  ) {10} .
/* $Workfile$ e n d */