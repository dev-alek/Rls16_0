/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
repeat i# = 1 to 3:
assign
b1-oborot-{&bef-{2}}[i# + {3}]    = b1-oborot-{&bef-{2}}[i# + {3}]    +  oborot-{&bef-{2}}[i# + {3}]
b2-oborot-{&bef-{2}}[i# + {3}]    = b2-oborot-{&bef-{2}}[i# + {3}]    +  oborot-{&bef-{2}}[i# + {3}]
bi-oborot-{&bef-{2}}[i# + {3}]    = bi-oborot-{&bef-{2}}[i# + {3}]    +  oborot-{&bef-{2}}[i# + {3}].
end.