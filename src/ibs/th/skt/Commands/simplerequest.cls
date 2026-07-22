/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Морозов Александр Сергеевич
Дата создания: 01/30/15
Author: Alexandr Morozov
Creation date: 01/30/15

*/
using ibs.th.skt.Commands.*.
using ibs.th.skt.HeadHttp from propath.
block-level on error undo, throw.

class ibs.th.skt.Commands.SimpleRequest inherits IRequest: 
    
   constructor public SimpleRequest (iHeadHTTP as HeadHttp  ):
      super ().
      HeadHTTP = iHeadHTTP.
   end constructor.

	destructor public SimpleRequest ( ):
      delete object HeadHTTP.
	end destructor.

end class.