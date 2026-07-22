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
{str/imp2cd_def.i  }
define output parameter oH as handle no-undo.
oH = himp2Cd.