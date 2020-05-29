{#############################################################################
####  File name: ELEVATOR.PAS
####  Module name: MSC-elevator.
####  Support modules reqd: <NONE>.
####  Run time environment:   Digital Research's CP/M
####                          8080 CPU.
####  Compile time environment: Digital Research's Pascal/MT+ 5.2
####  Copyright (c) 1981 by Lawrence Adkins.
####  Program development history:
####    29-Apr-82  Program created.
####     1-May-82  Changes made to allow scheduling of non-busy elevators, and
####               to idle those that are both non_busy and not scheduled.
####     3-May-82  More improvements to the scheduling algorithms.
####    (Last update on: 03-May-82)
##############################################################################}

{##############################################################################
####  This program simulates a system of several elevators all in operation
####  within a high-rise building.  The program cannot do any special I/O,
####  and is therefore unable to replace the conventional relay networks
####  presently controlling most elevators.  The program runs in batch mode.
####  1-May changes: Any passengerless, unassigned elevator
####  (during each time interval) will be assigned any most extreme floor 
####  (should one exist) where a floor call has been made which originated
####  at a floor in the direction of the elevator, but which indicated that the
####  direction had to be reverse. I.e, curr_floor = 6, direction = down, call
####  from floor 2 to to go up.  Passengerless elevators which see
####  no floor calls originating and indicating the current direction (i.e.,
####  curr_floor = 6, direction = down, call from 3 to go down), did not prev-
####  iously assign themselves, nor cannot currently assign themselves a floor
####  would be required to cease motion.  Once any elevator opens its doors at
####  a floor, and both button lights go out, that floor's assigned elevator
####  field must be reset to zero.
##############################################################################}



PROGRAM elevator_system (* VAR input, output: text *);

CONST
  bottom_floor = 1;     { lowest floor elevator goes to }
  top_floor = 15;       { highest floor elevator goes to }
  max_elevators = 3;    { number of elevators in the system }

TYPE
  motion = (down, up);  { the only two ways an elevator moves }
  action = (door_open, in_motion); { ... and the only two states... }
  t_elevator_info = RECORD
    curr_floor : bottom_floor..top_floor;
    fire_exit  : bottom_floor..top_floor;
    direction  : motion;
    status     : action;
    button_bank: ARRAY [bottom_floor..top_floor] OF boolean;
    END;
  t_floor_info = RECORD
    up_button  : boolean;
    down_button: boolean;
    prob_up_button_pushed: real;
    prob_down_button_pushed: real;
    prob_this_floor_is_destination: real;
    nb_elev_serving_this_request: 0..max_elevators;
    END;
  

VAR
  elev_cars : ARRAY [1..max_elevators] OF t_elevator_info;
                    { our three elevator cars and associated shafts }
  elev_foyers: ARRAY [bottom_floor..top_floor] OF t_floor_info;
                    { our foyers on fifteen stories each with
                      three elevator entrances and a pair of buttons }
  clock: integer;   { measures intervals of (lets say) five seconds }
  bldg_on_fire: boolean;  { at this point always false, but if there
                       was a sensor, would bring elevators to exit floor }
  max_time: integer; { our elevator cannnot run forever- it must cease to
                       to function when clock exceeds this value }
  shaft: integer;    { a temporary holding an elevator/shaft number }
  seed_for_random_number_generator: real;
  infil: text;
  outfil: text;

{##############################################################################
####    Assumed structure of input text data file...
####   The first three inputs are integers indicating the floor where each
####     elevator will be initially positioned. (Preferably fire exit floors.)
####   The next fifteen pairs of inputs are real floating point numbers 
####     representing the probabilities of the 'UP' and 'DOWN' buttons in
####     that order) being pushed for the respective floors 1..15.
####   The next fifteen inputs are real floating point numbers representing
####     the probabilities of the buttons in the elevators, for floors 1 thru
####     15, respectively, whenever passengers enter the elevator.
####   The next input is an integer representing the number of time units for
####     which to run the simulation.
####   The last expected input is an integer between 1 and 65256 to be used
####     as an initial seed for the random number generator.
##############################################################################}




PROCEDURE initialize (VAR input, output: text); FORWARD;
  PROCEDURE init_elev_cars (VAR input, output: text); FORWARD;
  PROCEDURE print_legend (VAR output: text); FORWARD;
  PROCEDURE init_up_down_probabilities (VAR input, output: text); FORWARD;
  PROCEDURE init_floor_selection_probabilities (VAR input,output:text);FORWARD;
PROCEDURE print_status_board (VAR output: text); FORWARD;
  PROCEDURE print_elev_car_status (VAR output: text); FORWARD;
PROCEDURE h1andle_requests_for_elevator_usage (VAR output: text); FORWARD;
  FUNCTION  random_num (VAR seed: real): real; FORWARD;
PROCEDURE perform_a_single_operation (shaft: integer; VAR output:text);FORWARD;
  FUNCTION listed_in_floor_table (shaft: integer; VAR floor: integer)
          : boolean; FORWARD;
  FUNCTION  must_continue_in_same_direction (shaft: integer): boolean; FORWARD;
  FUNCTION  against_stops (shaft: integer): boolean; FORWARD;
  FUNCTION  no_passengers (shaft: integer): boolean; FORWARD;
  FUNCTION  reason_to_open_door (shaft: integer): boolean; FORWARD;
  FUNCTION  other_floor_calls (shaft: integer): boolean; FORWARD;
  PROCEDURE h2andle_an_emergency (shaft: integer; VAR output: text); FORWARD;
  PROCEDURE open_elevator_door (shaft: integer; VAR output: text); FORWARD;
    PROCEDURE pick_destination_floors (shaft: integer;VAR output:text);FORWARD;
  FUNCTION  could_provide_service (shaft: integer): boolean; FORWARD;      







{##############################################################################
####  Initialize probabilities by reading from data file. 
####  Data file is read from only at initialization time.
####  Range checking is done on most read-in values, with errors
####  generating messages and replacing with arbitrary permissable values.
####  Initialize elevator system data structures.
##############################################################################}
PROCEDURE initialize (* VAR input, output: text *);

  BEGIN
  writeln (output, ' ---- SIMULATION OF AN ELEVATOR SYSTEM. ---- ');
  writeln (output);
  print_legend (output);
  writeln (output);
  init_elev_cars (input, output);
  writeln (output);
  init_up_down_probabilities (input, output);
  writeln (output);
  init_floor_selection_probabilities (input, output);
  writeln (output);
  read (input, max_time);
  IF (max_time < 0) OR (max_time > 1000)
  THEN BEGIN
       writeln (output, 'Data error. Illegal MAX_TIME of ', max_time:6);
       max_time := 5
       END;
  writeln (output, 'MAX_TIME is ', max_time:6);
  read (input, seed_for_random_number_generator);
  IF (seed_for_random_number_generator < 1.0)
    OR (seed_for_random_number_gernerator > 65256.0)
  THEN BEGIN
       writeln (output, 'Data error. Illegal SEED of ',
             seed_for_random_number_generator:15);
       seed_for_random_number_generator := 127.0
       END;
  writeln (output, 'Random number generator SEED is ',
             seed_for_random_number_generator:15);
  bldg_on_fire := false
  END;



PROCEDURE print_legend (* VAR output: text *);
  
  BEGIN
  writeln (output, 'In the maps which follow the following legend applies:');
  writeln (output, ' Given this sample output,');
  writeln (output,
    '1  floor       1    2    3    4    5    6    7    8    9   10...');
  writeln (output, '2');
  writeln (output,
    '3  up calls    >    .    .    .    .    >    .    .    .    .');
  writeln (output, '4');
  writeln (output,   
    '5   car 1 ->   .    1    .    .    .    .    .    .    .    +');
  writeln (output,
    '6   car 2 ->   .    .    .    .    .    .    .    2    +    .');
  writeln (output,
    '7   car 3 <-   +    .    .    <    .    .    .    .    .    .');
  writeln (output,'8');
  writeln (output,
    '9   down calls .    .    .    <    .    .    .    .    .    .');
  writeln (output);
  writeln (output,'where, in lines 3 and 9 the arrows represent calls, and');
  writeln (output,'dots represent no calls.  In lines 5 thru 7, plusses');
  writeln (output,'represent buttons pushed within the elevator, digits');
  writeln (output,'represent elevators which have opened their doors, while');
  writeln (output,'arrows here represent elevators passing by a floor w/o');
  writeln (output,'stopping.  Dots here indicate no elevators or buttons ');
  writeln (output,'not pushed from within the elevator.');
  END;


{##############################################################################
####  Initialization of the elev_cars array.  Probabilities read from input 
####  file, other fields initialized with predetermined values.
##############################################################################}
PROCEDURE init_elev_cars (* VAR input, output: text *);

  VAR shaft, floor, pres_floor: integer;
  BEGIN
  writeln (output, 'Initial elevator floor assignments. ');
  writeln (output, 'elevator':10, 'floor':10);
  FOR shaft := 1 TO max_elevators
  DO WITH elev_cars [shaft]
     DO BEGIN
        read (input, pres_floor);
        IF (pres_floor < bottom_floor) OR (pres_floor > top_floor)
        THEN BEGIN
             writeln (output, 'Data error. Illegal initial floor # ', 
               pres_floor:3, ' for elevator ', shaft:2);
             pres_floor := bottom_floor
             END;
         curr_floor := pres_floor;
         writeln (output, shaft:10, curr_floor:10);
         direction := up;
         status := door_open;
         fire_exit := curr_floor;
         FOR floor := bottom_floor TO top_floor
         DO button_bank [floor] := false
         END
  END;



{##############################################################################
####  Initialize most portions of the elev_foyer array, with probabilities
####  read from the input file, and other fields assigned predetermined values.
##############################################################################}
PROCEDURE init_up_down_probabilities (* VAR input, output: text *);

  VAR floor: integer;
  BEGIN
  writeln (output, 'Initial elevator foyer up-down button probability',
      ' assignments.');
  writeln (output, 'floor':10, 'up':15, 'down':15);
  FOR floor := bottom_floor TO top_floor
  DO WITH elev_foyers [floor]
     DO BEGIN
        up_button := false;
        down_button := false;
        nb_elev_serving_this_request := 0;
        read (input, prob_up_button_pushed, prob_down_button_pushed);
        IF (prob_up_button_pushed < 0.0) OR (prob_up_button_pushed > 1.0)
        THEN BEGIN
             writeln (output, 'Data error.  Illegal UP selection probability',
               ' of ', prob_up_button_pushed:15, ' for floor ', floor:3);
             prob_up_button_pushed := 0.0
             END;
        IF (prob_down_button_pushed < 0.0) OR (prob_down_button_pushed > 1.0)
        THEN BEGIN
             writeln (output, 'Data error.  Illegal DOWN selection',
               ' probability of ', prob_down_button_pushed:15, ' for floor ',
               floor:3);
             prob_down_button_pushed := 0.0
             END;
        writeln (output, floor:10, prob_up_button_pushed:15,
          prob_down_button_pushed:15)
        END
  END; 



{##############################################################################
####  Read one more set of probabilities from the input text file.
##############################################################################}
PROCEDURE init_floor_selection_probabilities (* VAR input, output: text *);

  VAR floor: integer;
  BEGIN
  writeln (output, 'Initial floor selection probability assignments. ');
  writeln (output, 'floor':10, 'selection':15);
  FOR floor := bottom_floor TO top_floor
  DO WITH elev_foyers [floor]
     DO BEGIN
        read (input, prob_this_floor_is_destination);
        IF (prob_this_floor_is_destination < 0.0)
          OR (prob_this_floor_is_destination > 1.0)
        THEN BEGIN
             writeln (output, 'Data error. Illegal FLOOR selection ',
               'probability of ', prob_this_floor_is_destination:15,
               ' for floor ', floor:3);
             prob_this_floor_is_destination := 0.0
             END;
         writeln (output, floor:10, prob_this_floor_is_destination:15)
         END
  END;




{##############################################################################
####  Give a sort of pictorial view of the status of the elevator system,
####  showing present positions, floors where buttons were pushed, etc.
####  Given this sample output,
###1   floor      1    2    3    4    5    6    7    8    9   10...
###2
###3   up calls   >    .    .    .    .    >    .    .    .    .
###4   
###5   car 1 ->   .    1    .    .    .    .    .    .    .    +
###6   car 2 ->   .    .    .    .    .    .    .    2    +    .
###7   car 3 <-   .    .    .    <    .    .    .    .    .    .
###8
###9   down calls .    .    .    <    .    .    .    .    .    .
####
####  where, in lines 3 and 9 the arrows represent calls, and dots represent
####  no calls.  In lines 5 thru 7, plusses represent buttons pushed within
####  the elevator, digits represent elevators which have opened their doors,
####  while arrows here represent elevators passing by a floor w/o stopping.
##############################################################################}
PROCEDURE print_status_board (* VAR output: text *);

  CONST s = 3;        { so that board fits on 80 column screen. }
  VAR floor: integer;
  BEGIN
  writeln (output); writeln (output);
  write (output, 'floor':15);
  FOR floor := bottom_floor TO top_floor
  DO write (output, floor:4);
  writeln (output); writeln (output);
  
  write (output, 'up calls':15);
  FOR floor := bottom_floor TO top_floor
  DO WITH elev_foyers [floor]
     DO IF up_button
        THEN write (output, '>':s)
        ELSE write (output, '.':s);
  writeln (output); writeln (output);

  print_elev_car_status (output);

  write (output, 'down calls':15);
  FOR floor := bottom_floor TO top_floor
  DO WITH elev_foyers [floor]
     DO IF down_button
        THEN write (output, '<':s)
        ELSE write (output, '.':s);
  writeln (output); writeln (output); writeln (output)
  END;



{##############################################################################
####  Print a line pertaining to the status of a single elevator car.
##############################################################################}
PROCEDURE print_elev_car_status (* VAR output: text *);

  CONST s = 3;        { so that board fits in 80 cols on screen }
  VAR shaft, floor: integer;
  BEGIN
  FOR shaft := 1 TO max_elevators
  DO WITH elev_cars [shaft]
     DO BEGIN
        write (output, 'car ':8, shaft:2);
        IF direction = up
        THEN write (output, '->':5)
        ELSE write (output, '<-':5);
        FOR floor := bottom_floor TO top_floor
        DO IF (curr_floor = floor)
           THEN IF status = door_open
                THEN write (output, shaft:4)
                ELSE IF direction = up
                     THEN write (output, '>':s)
                     ELSE write (output, '<':s)
           ELSE IF button_bank [floor]
                THEN write (output, '+':s)
                ELSE write (output, '.':s);
         writeln (output)
         END;
  writeln (output)
  END;



{##############################################################################
####  Figure out which buttons were pressed in every foyer (what I call the
####  hall space the elevators open into).
##############################################################################}
PROCEDURE h1andle_requests_for_elevator_usage (* VAR output: text *);

  VAR floor,shaft: integer;
      r: real;
      b: boolean;
  BEGIN
  FOR floor := bottom_floor TO top_floor
  DO WITH elev_foyers [floor]
     DO BEGIN
        r := random_num (seed_for_random_number_generator);
        IF r < prob_up_button_pushed
        THEN BEGIN
             up_button := true;
             writeln (output, 'Up call on floor ', floor:4)
             END;
        r := random_num (seed_for_random_number_generator);
        IF r < prob_down_button_pushed
        THEN BEGIN
             down_button := true;
             writeln (output, 'Down call on floor ', floor:4)
             END
        END;
  FOR shaft := 1 TO max_elevators
  DO b:= could_provide_service (shaft)
  END;



{##############################################################################
#### Generate the pseudo random number such that 0 <= random_num <= 1 
##############################################################################}
FUNCTION  random_num (* VAR seed: real): real *);

  CONST modulus = 65536.0;
        multiplier = 25173.0;
        increment = 13849.0;
  VAR temp: real;
  BEGIN
  temp := ((multiplier * seed) + increment);     { MOD modulus }
  temp := temp / modulus;
  seed := (temp - trunc (temp)) * modulus; 
  random_num := seed / modulus
  END;



{##############################################################################
####  Do what is considered a legal operation for an elevator within the 
####  time interval assumed (say, 5 secs.)
##############################################################################}
PROCEDURE perform_a_single_operation (* shaft: integer; VAR output: text *);

  VAR i, floor1: integer; 
      busy : boolean;
  BEGIN
  busy := true; i := 0;
  REPEAT
    i := i + 1;
    WITH elev_cars [shaft]
    DO IF bldg_on_fire
       THEN h2andle_an_emergency (shaft, output)
       ELSE IF reason_to_open_door (shaft)
            THEN open_elevator_door (shaft, output)
            ELSE IF must_continue_in_same_direction (shaft)
                    OR (no_passengers (shaft) 
                       AND NOT against_stops (shaft)
                       AND listed_in_floor_table (shaft, floor1))
                 THEN BEGIN   { move a floor up or down }
                      status := in_motion;
                      IF direction = down
                      THEN curr_floor := curr_floor - 1
                      ELSE curr_floor := curr_floor + 1
                      END
                 ELSE IF busy
                      THEN BEGIN   { turn around, but dont move }
                           busy := false;
                           status := in_motion;
                           IF direction = down
                           THEN direction := up
                           ELSE direction := down
                           END
  UNTIL busy OR (i = 2)
  END;



{##############################################################################
####  Return true if elevator (shaft) scheduled to stop at any floor along its
####  path
##############################################################################}
FUNCTION listed_in_floor_table (* shaft:integer; VAR floor:integer):boolean *);

  VAR b: boolean;
  BEGIN
  floor := bottom_floor - 1;
  REPEAT
    floor := floor + 1;
    b := elev_foyers [floor].nb_elev_serving_this_request = shaft
  UNTIL (floor >= top_floor) OR b;
  listed_in_floor_table := b;
  END;



{##############################################################################
####  Determine if we must travel further before turning direction.
####  Normally, when the elevator is busy, we return true only if there are
####  people in the foyers of the floors in the elevator's current direction
####  waiting to travel further on in the same direction.
##############################################################################}
FUNCTION  must_continue_in_same_direction (* shaft: integer) : boolean *);

  VAR b: boolean;
      floor: integer;
  BEGIN
  b:= false;
  IF NOT against_stops (shaft)
  THEN  WITH elev_cars[shaft]
        DO IF direction = up
           THEN FOR floor := curr_floor+1 TO top_floor
                DO b := b OR button_bank [floor]
                          OR elev_foyers [floor].up_button
           ELSE FOR floor := curr_floor-1 DOWNTO bottom_floor
                DO b := b OR button_bank [floor]
                          OR elev_foyers [floor].down_button;
  must_continue_in_same_direction := b;
  END;




{##############################################################################
####  Determine if the elevator cannot go any further in the same direction.
##############################################################################}
FUNCTION  against_stops (* shaft: integer): boolean *); 

  BEGIN
  WITH elev_cars [shaft]
  DO against_stops := ((curr_floor = bottom_floor) AND (direction = down))
                   OR ((curr_floor = top_floor   ) AND (direction = up))
  END;



{##############################################################################
####  Return true if NO buttons remain lit (unserviced) within the elevator car
##############################################################################}
FUNCTION  no_passengers (* shaft: integer): boolean *);
 
  VAR floor: integer;
      b: boolean;
  BEGIN
  b := false;
  WITH elev_cars [shaft]
  DO FOR floor := bottom_floor TO top_floor
     DO b := b OR button_bank [floor];
  no_passengers := NOT b;
  END;



{##############################################################################
####  Return true if there stands good reason why the door should be opened.
####  Either a passenger wants to get out, or people outside want a ride along
####  the current direction.
##############################################################################}
FUNCTION  reason_to_open_door (* shaft: integer): boolean *); 

  BEGIN
  WITH elev_cars [shaft]
  DO reason_to_open_door := button_bank [curr_floor]
       OR ((direction = up) AND elev_foyers [curr_floor]. up_button)
       OR ((direction = down) AND elev_foyers [curr_floor]. down_button)
  END;



{##############################################################################
####  Return true if floor calls are pending that could not be detected by the
####  must_continue_in_same_direction function.
####  The calls examined are those originating in the current direction of the
####  elevator, but whose direction indicate that the people want to travel
####  in the reverse direction.
##############################################################################}
FUNCTION  other_floor_calls (* shaft: integer): boolean *);

  VAR b: boolean;
      floor: integer;
  BEGIN
  b:= false;
  IF NOT against_stops (shaft)
  THEN WITH elev_cars[shaft]
       DO IF direction = up
          THEN FOR floor := curr_floor+1 TO top_floor
               DO b := b OR elev_foyers [floor].down_button
          ELSE FOR floor := curr_floor-1 DOWNTO bottom_floor
               DO b := b OR elev_foyers [floor].up_button;
  other_floor_calls := b;
  END;
  


{##############################################################################
####  Routine executed whenever a building emergency occurs.
##############################################################################}
PROCEDURE h2andle_an_emergency (* shaft: integer; VAR output: text *);
  
  BEGIN
  WITH elev_cars [shaft]
  DO BEGIN
     button_bank [fire_exit] := true;
     IF curr_floor = fire_exit
     THEN BEGIN
          open_elevator_door (shaft, output);
          writeln (output, '***  Elevator # ',shaft:3, ' out of service.  ***')
          END
     ELSE IF curr_floor > fire_exit
          THEN BEGIN
               status := in_motion;
               direction := down;
               curr_floor := curr_floor - 1
               END
          ELSE BEGIN
               status := in_motion;
               direction := up;
               curr_floor := curr_floor + 1
               END
      END
  END;


{##############################################################################
####  Open the doors on the elevator and simulate the actions of the new
####  passengers pushing floor buttons.
##############################################################################}
PROCEDURE open_elevator_door (* shaft: integer; VAR output: text *);

  VAR current_floor: integer;
  BEGIN
  WITH elev_cars [shaft]
  DO BEGIN
     status := door_open;
     current_floor := curr_floor
     END;
  WITH elev_foyers [current_floor]
  DO BEGIN
     IF up_button OR down_button
     THEN pick_destination_floors (shaft, output);
     IF elev_cars [shaft]. direction = up
     THEN  up_button := false
     ELSE  down_button := false;
     IF NOT (up_button OR down_button)
     THEN BEGIN
          nb_elev_serving_this_request := 0;
          END
     END;
  WITH elev_cars [shaft]
  DO BEGIN
     IF button_bank [curr_floor]
     THEN BEGIN
          button_bank [curr_floor] := false;
          writeln ('Passengers let off elevator ',shaft:2, ' on floor ',
             curr_floor:4)
          END
     END
  END;



{##############################################################################
####  Routine to simulate the action of passengers selecting the floors where
####  they want to go.  If this were my elevator, Any floor selection would 
####  be recognized (but perhaps not untilany of those in the path of the
####  present direction were visited first.)
##############################################################################}
PROCEDURE pick_destination_floors (* shaft: integer; VAR output: text *);

  CONST this_was_my_elevator = false;
  VAR floor : integer;
  PROCEDURE push_floor_selection_button;
    VAR r: real;
    BEGIN
    WITH elev_cars [shaft]
    DO BEGIN
       r := random_num (seed_for_random_number_generator);
       IF r < elev_foyers [floor]. prob_this_floor_is_destination
       THEN BEGIN
            button_bank [floor] := true;
            write (output, floor:3, ' , ')
            END
       END
     END;

  BEGIN
  WITH elev_cars [shaft]
  DO BEGIN
     write (output, 'Passengers picked up by elevator ',shaft:2, ' at floor ',
       curr_floor:4,' to go to floors ');
     IF this_was_my_elevator
     THEN FOR floor := bottom_floor TO top_floor
          DO push_floor_selection_button
     ELSE IF NOT against_stops (shaft)
          THEN IF direction = up
               THEN FOR floor := curr_floor + 1 TO top_floor
                    DO push_floor_selection_button
               ELSE FOR floor := curr_floor - 1 DOWNTO bottom_floor
                    DO push_floor_selection_button;
     writeln (output)
     END
  END;



{##########################################################################
####  Figure out if the elevator has no passengers, whether there is a floor
####  call from in your direction to go in the reverse direction, and then 
####  assign the closest elevator that meets these qualifications to the
####  floor call closest to either the top or bottom of the shaft.
##########################################################################}
FUNCTION  could_provide_service (* shaft: integer): boolean *);

  VAR b, b1: boolean; floor: integer;
  FUNCTION find_floor_unassigned_to_elevator (scale: integer): boolean;
    VAR b: boolean; elev_assigned_previously: boolean;
    BEGIN
    REPEAT
      floor := floor + scale;
      WITH elev_foyers [floor]
      DO BEGIN
         elev_assigned_previously :=  NOT no_passengers (shaft)
             OR ((nb_elev_serving_this_request > 0)
             AND (abs (elev_cars [nb_elev_serving_this_request]. curr_floor
                                                                       - floor)
                < abs (elev_cars [shaft]. curr_floor - floor)));
         IF NOT elev_assigned_previously
            AND (((elev_cars [shaft].direction = up) AND (down_button))
              OR ((elev_cars [shaft].direction = down) AND (up_button)))
         THEN nb_elev_serving_this_request := shaft;
         b := (nb_elev_serving_this_request = shaft)
         END
    UNTIL b OR elev_assigned_previously 
            OR (floor = elev_cars [shaft]. curr_floor);
    find_floor_unassigned_to_elevator := b
    END;

  BEGIN
  b := (NOT listed_in_floor_table (shaft, floor))
        AND other_floor_calls (shaft);
  IF b
  THEN IF elev_cars [shaft]. direction = up
       THEN BEGIN
            floor := top_floor + 1;
            b1 := find_floor_unassigned_to_elevator (-1)
            END
       ELSE BEGIN
            floor := bottom_floor - 1;
            b1 := find_floor_unassigned_to_elevator (+1)
            END;
  could_provide_service := b AND b1;
  END;




BEGIN  { main program }
assign (infil, 'b:elevator.dat');
reset (infil);
assign (outfil, 'CON:');
rewrite (outfil);
initialize (infil, outfil);          {init probability and other stuff }
clock := 1;
print_status_board (outfil);
REPEAT                               { for each time interval,...}
  writeln (outfil);
  writeln (outfil, ' ':30, 'Time Interval: ', clock:4);
  h1andle_requests_for_elevator_usage (outfil);
  FOR shaft := 1 TO max_elevators
  DO perform_a_single_operation (shaft, outfil);
  clock := clock + 1;
  print_status_board (outfil);
UNTIL clock > max_time;  { sorry, even computerized els go out of order }
writeln (outfil, 'Simulation complete. ')
END.




