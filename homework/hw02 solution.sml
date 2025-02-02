(* Grader Outpute: 101.12% , cringe homework.. *)
(* Dan Grossman, Coursera PL, HW2 Provided Code *)

(* if you use this function to compare two strings (returns true if the same
   string), then you avoid several of the functions in problem 1 having
   polymorphic types that may be confusing *)
fun same_string(s1 : string, s2 : string) =
    s1 = s2

(* put your solutions for problem 1 here *)

(* you may assume that Num is always used with values 2, 3, ..., 10
   though it will not really come up *)
datatype suit = Clubs | Diamonds | Hearts | Spades
datatype rank = Jack | Queen | King | Ace | Num of int 
type card = suit * rank

datatype color = Red | Black
datatype move = Discard of card | Draw 

exception IllegalMove
(* put your solutions for problem 2 here *)


(* 1.a El Problema Numero I.I *)
(* string (list string) -> (list string)|NONE *)
(* return consumed ListOfString without consumed string if string happens to be in it, otherwise return NONE*)
fun all_except_option(s, lox) = 
   let fun rm_stringornone(s, lox, acc) = 
      case lox of
       [] => NONE
   |   firstlox::restlox => if same_string(s,firstlox) then let val newlist = acc@restlox in SOME newlist end else rm_stringornone(s, restlox, acc@[firstlox]) (* did a let here cuz i couldn't SOME acc@reslox.. smh*)
   in rm_stringornone(s, lox, []) end


(* 1.b EL Problema Numero I.II *)
(* string list list, string -> string list*)
(*return lists that only have string within, excluding that string from them, i guess otherwise return [] (can't reutrn NON cuz type mismatch) *)
fun get_substitutions1(listlos, s) =
   case listlos of
      [] => []
   |  lastlist::[] => let val currentlist = all_except_option(s, lastlist) in 
                                                      case currentlist of 
                                                         NONE => []
                                                      |  SOME currentlist => currentlist  end        
   |  firstlist::restlists => let val currentlist = all_except_option(s, firstlist) in
                                                      case currentlist of
                                                         NONE => get_substitutions1(restlists, s)
                                                      |  SOME currentlist => currentlist@get_substitutions1(restlists, s) end
(* 1.c EL Problema Numero I.III *)
(* get_substitutions1 with TAIL RECURSION *)                                       
fun get_substitutions2(listlos, s) =
   let fun tail_substitutions(listlos, s, acc) =
      case listlos of
         [] => acc (* which is empty *)
      |  lastlist::[] => let val currentlist = all_except_option(s, lastlist) in
                                                         case currentlist of 
                                                            NONE => acc
                                                         |  SOME currentlist => acc@currentlist end
      |  firstlist::restlists => let val currentlist = all_except_option(s, firstlist) in
                                                         case currentlist of
                                                            NONE => tail_substitutions(restlists, s, acc)
                                                         |  SOME currentlist => tail_substitutions(restlists, s, acc@currentlist) end
   in tail_substitutions(listlos, s, []) end

(* 1.d EL Problema Numero I.IV *)
(* string list list, tiple elemented record -> record list *)
(* return list of records, each record has the first name substituted with one from consumed & performed upon get_substitutions1or2 string list list*)
fun similar_names(listlos, fml_record) =
   let fun substitute(middle, last, los) =
     case los of
         [] => []
      |  firstlos::restlos => {first=firstlos, last=last, middle=middle}::substitute(middle, last, restlos)

   in case fml_record of
      {first=f,middle=m,last=l} => {first=f,middle=m,last=l}::substitute(m, l, (get_substitutions1(listlos, f))) end

(*===================================================================================================*)
(* 2.a EL Problema Numero II.I *)
(* card -> black|red*)
(* return black if consumed card is either spades or clubs, othersiw return red (for diamonds and hearts) *)

fun card_color c =
   case c of
      (Spades,_) => Black
   |  (Clubs,_) => Black
   |  _ => Red


(* 2.b EL Problemo Numera II.II *)
(* card -> int *)
(* return card value as such: numbered take their number as a value, Ace is 11, everything else is 10 *)

fun card_value c =
   case c of
      (_, Ace) => 11
   |  (_, Num num) => num
   |   _ =>   10


(* 2.c El Problemoa Numeroa II.III *)
(* card list, card, exception e -> card list*)
(* return all elements of consumed card list (cs) except card (c)
      Caveats: if c occurs more than once => only remove first isntance
               if is not in the list      => raise the exception e*)

fun remove_card(cs, c, e) =
   case cs of
         [] => raise e
     |   firstcs::restcs => if firstcs = c 
                           then restcs
                           else firstcs::remove_card(restcs, c, e)


(* 2.d Problem Num  II.IV*)
(* card list -> boolean *)
(* return true if all cards are the same color, false otherwise *)

fun all_same_color cs =
   case cs of
      [] => true
   |  _::[] => true
   | firstcs::secondcs::restcs => card_color(firstcs) = card_color(secondcs) andalso all_same_color(secondcs::restcs)

(* 2.e Problem Num II.V*)
(* card list -> int *)
(* get the sum of all cards in consumed card list 
      using tail recursion *)

fun sum_cards cs =
   let fun sum_cards_ts(cs, acc) =
      case cs of
         [] => acc
      |  firstcard::restcards => sum_cards_ts(restcards, acc + card_value(firstcard))
   in sum_cards_ts(cs, 0) end


(* 2.f Problem Num II.VI *)
(* card list, int -> int *)
(* calculate sum_cards cs, if > consumed int 
                                 then 3*(sum-goal)
                                 else goal-sum     *)

fun score(cs, goal) =
   let val sum = sum_cards(cs) 
       val same_colors = all_same_color cs
   in
   if sum > goal
   then if not same_colors then 3*(sum-goal) else (3*(sum-goal)) div 2
   else if not same_colors then goal - sum else (goal-sum) div 2
   end

(* 2.g Problem Num II.VII *)
(* card list, (list move:draw|discard), int -> int *)
(* start game with empty held cards
   depending on move: draw|discard, either draw from consumed card list
                                    or discard current card in held cards
                     if move:draw & card list empty -> stop
                        move:discard & held cards empty -> stop
                        move:discard & card to discard is not in held cards -> raise IllegalMove
                        move list list itself is empty -> stop*)
fun officiate(loc, lomov, goal) =
   let 
   fun officiatinate(loc, lomov, held_cards, goal) = 
      case lomov of
         [] => score(held_cards,goal)
      |  Discard(c)::restlomov => officiatinate(loc, restlomov, remove_card(held_cards, c, IllegalMove), goal)
      |  Draw::restlomov => case loc of
                              [] => score(held_cards,goal)
                           |  firstcard::restcards => let val try = sum_cards(held_cards@[firstcard]) in 
                                                      if try > goal
                                                      then score(held_cards@[firstcard],goal)
                                                      else officiatinate(restcards, restlomov, held_cards@[firstcard], goal) end
  in  officiatinate(loc, lomov, [], goal) end


(* Alrighty, Onto the Challenge Problemas *)
(* El Problemo Alphabitistico (a) *)

fun score_challenge(cs, goal) =
   let fun ace_found(cs) = 
      case cs of
         [] => false
      |  (_,rank)::restcards => if rank = Ace then true else ace_found restcards
      val sum_val11 = sum_cards(cs)
      val sum_val1  = sum_cards(cs) - 10
      val score_1 = score (cs, sum_val1) 
      val score_11 = score (cs, sum_val11)
   in 
   if ace_found(cs) 
   then if score_1 > score_11 then score_11  else score_1 
   else score_11
   end

fun officiate_challenge(loc, lomov, goal) =
   let 
   fun officiatinate(loc, lomov, held_cards, goal) = 
      case lomov of
         [] => score_challenge(held_cards,goal)
      |  Discard(c)::restlomov => officiatinate(loc, restlomov, remove_card(held_cards, c, IllegalMove), goal)
      |  Draw::restlomov => case loc of
                              [] => score_challenge(held_cards,goal)
                           |  firstcard::restcards => let val try = sum_cards(held_cards@[firstcard]) in 
                                                      if try > goal
                                                      then score_challenge(held_cards@[firstcard],goal)
                                                      else officiatinate(restcards, restlomov, held_cards@[firstcard], goal) end
  in  officiatinate(loc, lomov, [], goal) end

fun careful_player (card_list, goal) =
   let fun try_discard held_cards drawn_card =
      case held_cards of
      [] =>  Draw
      | card::rest_held_cards => if score ((rest_held_cards @ [drawn_card]), goal) = 0 then Discard card else try_discard rest_held_cards drawn_card
   fun gen_move_list card_list goal moves held_cards =
   case card_list of
   [] => moves @ [Draw]
(* if goal > (sum_cards held_cards + 10) then moves @ [Draw] else if score(held_cards, goal) > score((held_cards @ [card]), goal) then moves @ [Draw] else moves *)
|  card::restcards => if score(held_cards, goal) = 0 
                                then moves 
                                else let val cards_value = sum_cards (held_cards @ [card]) 
                                     in if cards_value > 10 
                                        then gen_move_list restcards goal moves held_cards 
                                        else case try_discard held_cards card of Draw => gen_move_list restcards goal (moves @ [Draw]) (held_cards @ [card]) 
                                                                                 | Discard c => gen_move_list restcards goal (moves @ [Discard c] @ [Draw]) (remove_card(held_cards, c, IllegalMove) @ [card])
                                     end
      
   in gen_move_list card_list goal [] [] end

