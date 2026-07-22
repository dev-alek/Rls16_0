block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 18 июня 2022 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 18 июня 2022 г.

*/
&glob handle_only = yes
{str/imp2cd_def.i }
define input parameter iH as handle no-undo.
himp2Cd= iH.