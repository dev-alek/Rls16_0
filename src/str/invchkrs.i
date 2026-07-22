/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список партий мещающих резервированию

Автор: Суслов Алексей Юрьевич
Дата создания: 04/12/06
Author: Alexey Suslov
Creation date: 04/12/06

{1} - код документа
{2} - буфер parts
{3} - буфер doc-line

*/

 each {2} no-lock
        where
            (     {2}.prod-type = {3}.prod-type
              and {2}.prod-code = {3}.prod-code
              and {2}.artic     = {3}.artic
              and {2}.obj-type  = {3}.obj-type
              and {2}.obj-code  = {3}.obj-code
              and {2}.rsrv-free = true
              and {2}.status_   = false
              and {2}.out-code  <> {&free-code}
              and {2}.out-code  <> {1}
            )
            or
            (     {2}.prod-type = {3}.prod-type
              and {2}.prod-code = {3}.prod-code
              and {2}.artic     = {3}.artic
              and {2}.obj-type  = {3}.obj-type
              and {2}.obj-code  = {3}.obj-code
              and {2}.rsrv-free = false
              and {2}.status_   = false
              and {2}.out-code  <> {&output-code}
              and {2}.out-code  <> {1}
            )

/* $Workfile$ */