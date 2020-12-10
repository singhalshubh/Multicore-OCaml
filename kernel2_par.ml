let scale = try int_of_string Sys.argv.(1) with _ -> 12

let edgefactor = try int_of_string Sys.argv.(2) with _ -> 10

let startVertex = try int_of_string Sys.argv.(3) with _ -> 0

let num_domains = try int_of_string Sys.argv.(4) with _ -> 1

module T = Domainslib.Task


let rec printList lst = 
	match lst with
	[] -> None |
	hd::tl -> Printf.printf "%d" (fst hd); printList tl

let rec bfs adjMatrix level queue = 
	if Lockfree.MSQueue.is_empty queue = true then ()
else
	match Lockfree.MSQueue.pop queue with
	None -> () |
	Some root -> 
		match Lockfree.Hash.find adjMatrix root with
			None -> () |
			Some lst ->
				let pool = T.setup_pool ~num_domains:(num_domains - 1) in
				(*Printf.printf "Root : %d\n" root;
				let _ = Array.iter (fun i -> Printf.printf "%d" i) level in
				Printf.printf "\n"; 
				let _ = printList lst in
				Printf.printf "\n";*)
				T.parallel_for pool ~start:0 ~finish:(List.length lst - 1) 
				~body:(	fun i -> 
						if level.((fst (List.nth lst i))) != (-1) then ()
								 else begin 
									(*Printf.printf "efjewfjef\n";*)
									level.((fst (List.nth lst i))) <- level.(root) + 1;
									(*Printf.printf "jk";*)
									Lockfree.MSQueue.push queue (fst (List.nth lst i))
									end 
				);
				T.teardown_pool pool;
				bfs adjMatrix level queue

let kernel2 () = 
  	let ans = Kernel1_par.linkKronecker () in
  	let adjMatrix = fst ans in
  	let n = snd ans in
  	let level = Array.make n (-1) in
  	level.(startVertex) <- 0;
	let queue = Lockfree.MSQueue.create () in
	let _ = Lockfree.MSQueue.push queue startVertex in
	let _ = bfs adjMatrix level queue in
	let _ = Array.iter (fun i -> Printf.printf "%d" i) level in 
	level

let _ = kernel2 ()