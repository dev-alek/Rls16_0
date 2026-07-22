/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

message ошибки при вызове файла

Автор: Суслов Алексей Юрьевич
Дата создания: 04/12/06
Author: Alexey Suslov
Creation date: 04/12/06

*/
&if "{2}" <> "" &then
  &scop type-message {2}
&else
  &scop type-message error
&endif
message
  vss-workfile vss-revision vss-description skip
  "{1}" skip
  "-----------Cистемная ошибка------------" skip
  return-value skip
  "------Ошибка исполнения программы------" skip
  trim(error-status :get-message(1)) +
  trim(error-status :get-message(2)) +
  trim(error-status :get-message(3)) +
  trim(error-status :get-message(4)) +
  trim(error-status :get-message(5)) skip
  view-as alert-box {&type-message} .
/* $Workfile$ e n d */