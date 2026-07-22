 
/*------------------------------------------------------------------------
   File        : pargdsoattr
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : asmorozov
   Created     : Wed Oct 10 23:20:50 MSK 2018
   Notes       : 
 ----------------------------------------------------------------------*/

using Progress.Lang.*.
block-level on error undo, throw.


class ibs.th.ref.pargdsoattr:
  
  define property GdsCode  as integer      no-undo get. set.
  define property ObjType  as character    no-undo get. set.
  define property ObjCode  as integer      no-undo get. set.
  define property OnDate   as date         no-undo init ? get. set.
  define property FromInvDate as date   no-undo get. set.
  define property ToInvDate   as date   no-undo get. set.
  define property FromInvFQKg as decimal   no-undo get. set.
  define property PlCode      as integer   no-undo get. set. 

end class.