(define (domain definitivo)

;remove requirements that are not needed
(:requirements :strips :fluents :durative-actions :timed-initial-literals :typing :conditional-effects :negative-preconditions :duration-inequalities :equality)

;Types define categories of objects (e.g. robot, crate, room) and help to specify the entities involved in the domain.
(:types 
    robot
    base
    crate
    loader
    loader_leggero
)

;Predicates represent properties or relationships between objects, evaluated as true or false in a given state of the world.
(:predicates 
        (at_base ?r - robot ?b - base) ; the robot is at the base
        (free ?r - robot) ; the robot is free
        (pickable_crate ?c - crate) ; the crate can be transported by the robot
        (at_crate ?r - robot ?c - crate) ; the robot is at the crate
        (carry ?r - robot ?c - crate) ; robot is carrying the crate
        (at ?c - crate ?b - base) ; crate is at the base (ready to be loaded)
        (free_loader ?l - loader) ; loader is free
        (pick_load ?l - loader ?c - crate) ; loader has picked up the crate;
        (on_belt ?c - crate) ; crate is on the belt

        ; predicates to make the two robots work together (in case of heavy, fragile, or light crates to be faster)
        (not_working_together) ; two robots are not working together
        (working_together) ; two robots are working together

        ; extension 1: 'Some crates go together'
        (groupA ?c - crate) ; crate belongs to group A
        (groupB ?c - crate) ; crate belongs to group B
        (no_group ?c - crate) ; crate does not belong to any group

        ; extension 2: 'There are 2 loaders'
        (free_loader_leggero ?ll - loader_leggero) ; loader_leggero is free
        (pick_load_leggero ?ll - loader_leggero ?c - crate) ; loader_leggero has picked a crate (in this case, a light crate) 

        ; extension 3: 'Mover robots need recharging'
        (free_charger ?b - base) ; charging station is free

        ; extension 4: 'This is fragile!'
        (fragile ?c - crate) ; crate is fragile
        (not_fragile ?c - crate) ; crate is not fragile
)


(:functions 
    (velocity) ; velocity of the robot during the movement (go to the crate, back to the base)
    (free_base) ; Indicates whether the base is free (i.e., not occupied by any box).
    ; This predicate is useful to determine if the robot can perform a drop action.
    ; At most, only one box can be on the base at a time.
    (weight ?c - crate) ; weight of the crate(useful tp determine if the crate is light or heavy)
    (distance ?c - crate ?b - base) ; distance between the crate and the base
        
    ; extension 1
    (priority) ; priority between crates 
    (max_priority) ; max priority of the crates
        
    ; extension 3
    (battery ?r - robot) ; robot battery
    (max_battery) ; max battery of the robot
)

; ACTIONS DEFINED FOR WHEN A SINGLE ROBOT CAN TRANSPORT THE CRATE: the crate must be light (<= (weight ?c) 50) and not fragile (not_fragile ?c).
; Note: the drop has the additional characteristic of being performed only for crates that do not belong to any group, otherwise the actions 'drop_A' and 'drop_B' come into play.

; Description: movement of the robot from its position to the assigned crate.
; Requirements: allowed only for light and non-fragile crates.;
; Duration: calculated based on the distance between the robot and the crate and the speed of the robot.
    (:durative-action move_to_crate
        :parameters (?r - robot ?c - crate ?b - base)
        :duration (= ?duration (/(distance ?c ?b)(velocity)))
        :condition (and 
            (at start (and 
                (at_base ?r ?b)
            ))
            (over all (and 
                
                (pickable_crate ?c)
                (> (battery ?r) 15) ; robot needs to have enough battery to reach the crate
                (free ?r)
                (<= (weight ?c) 50)
                (not_fragile ?c)
            ))
        )
        :effect (and 
            (at start (and 
            (not (at_base ?r ?b))
            (not_working_together) ; robot is working alone
            (not (working_together))
            ))
            (at end (and 
                (at_crate ?r ?c)(decrease (battery ?r) (/(distance ?c ?b)(velocity))) ; deacrease battery
            ))  
        )
    )

    ; Description: pick up of the assigned box for the robot. 
    ; Requirements: allowed only for light and non-fragile crates. 
    ; Duration: action duration 1.
    (:durative-action pick_up
        :parameters (?c - crate ?r - robot)
        :duration (= ?duration 1)
        :condition (and 
            (at start (and 
                (free ?r )
                
            ))
            (over all (and 
                (at_crate ?r ?c)
                (pickable_crate ?c)
                (<= (weight ?c) 50)
                (not_fragile ?c)
            ))
        )
        :effect (and 
            (at start (and
                (not (pickable_crate ?c))
            ))
            (at end (and 
                (carry ?r ?c) ; start the carrying of the crate
                (not (free ?r))
            ))
        )
    )

    ; Description: movement of the robot from the assigned crate to the base.
    ; Requirements: allowed only for light and non-fragile crates.
    ; Duration: calculated based on the distance between the robot and the crate, the weight of the crate, and all divided by 100 (value assigned by the problem).
    (:durative-action move_back
        :parameters (?c - crate ?b - base ?r - robot)
        :duration (= ?duration  (/ (* (distance ?c ?b)(weight ?c)) 100))
        :condition (and 
            (at start (and 
                (at_crate ?r ?c)
                (not_working_together)
            ))
            (over all (and 
                (carry ?r ?c)
                (<= (weight ?c) 50)
                (not_fragile ?c)
                
            ))
        )
        :effect (and 
            (at start 
                (not (at_crate ?r ?c))
            )
            (at end (and 
                (at_base ?r ?b)
                (decrease (battery ?r) (/ (* (distance ?c ?b)(weight ?c)) 100)) ; decreasement of the battery
            ))
        )
    )

    ; Description: drop of the box assigned to the robot. 
    ; Requirements: allowed only for lightweight and non-fragile boxes. In addition, the base must be free (<(free_base)2) and must not belong to any group (no_group ?c). 
    ; Duration: action duration 1.
    (:durative-action drop
        :parameters (?b - base ?c - crate ?r - robot)
        :duration (= ?duration 1)
        :condition (and 
            (at start (and 
                (carry ?r ?c)
            ))
            (over all (and 
                (at_base ?r ?b)
                (<= (weight ?c) 50)
                (not_fragile ?c)
                (<(free_base)2) ; to continue the drop action , base need to be free
                (=(priority)(max_priority)) ; assignment of the max priority to the crates
                (no_group ?c) ; crate does not belong to any group
            ))
        )
        :effect (and 
            (at start (and 
                
                (not (carry ?r ?c)) ; crate is not carried anymore
                (increase (free_base) 1) ; increases the value of the number of boxes at the base (free_base) by one, to prevent too many boxes from being dropped at the base.            ))
            ))
            (at end (and 
                (at ?c ?b)
                (free ?r) ; robot is free to continue working
            ))
        )
    )

    ; ACTIONS DEFINED FOR WHEN MORE ROBOTS CAN TRANSPORT THE CRATE: for heavy, fragile crates and for light crates (if you want to speed up the execution of the return to base).

    ; Description: movement of the two robots from their position to the assigned crate.
    ; Requirements: both robots must have enough battery (> (battery ?r1) 15) and (> (battery ?r2) 15).
    ; Duration: calculated based on the distance between the robot and the crate and the speed of the robot.
    (:durative-action move_two_robot_to_crate
        :parameters (?r1 - robot ?r2 - robot ?c - crate ?b - base)
        :duration (= ?duration (/(distance ?c ?b)(velocity)))
        :condition (and 
            (at start (and 
                (at_base ?r1 ?b)
                (at_base ?r2 ?b)
                (free ?r1)
                (free ?r2)
            ))
            (over all (and 
                
                (pickable_crate ?c)
                (> (battery ?r1) 15) ; check battery of the first robot
                (> (battery ?r2) 15) ; check battery of the second robot

            ))
        )
        :effect (and 
            (at start (and 
                (not (at_base ?r1 ?b))
                (not (at_base ?r2 ?b))
                (working_together) ; robots are working together
                (not(not_working_together))
                ))
                
            (at end (and 
                (at_crate ?r1 ?c)
                (at_crate ?r2 ?c)
                (decrease (battery ?r1) (/(distance ?c ?b)(velocity))) ; decrease battery
                (decrease (battery ?r2) (/(distance ?c ?b)(velocity))) ; decrease battery
            ))  
        )
    )

    ; Description: pickup of the crate assigned to the two robots. 
    ; Requirements: both robots must be free and have reached the available crate (pickable_crate ?c).
    ; Duration: instantaneous action.
    (:durative-action pick_up_two_robot
        :parameters (?c - crate ?r1 - robot ?r2 - robot)
        :duration (= ?duration 1)
        :condition (and 
            (at start (and 
                (free ?r1 )
                (free ?r2 )
                
            ))
            (over all (and 
                (at_crate ?r1 ?c)
                (at_crate ?r2 ?c)
                (pickable_crate ?c)
            ))
        )
        :effect (and 
            (at start (and
                (not (pickable_crate ?c))
            ))
            (at end (and 
                (carry ?r1 ?c) ; start the carrying of the crate
                (carry ?r2 ?c) ; start the carrying of the crate
                
                (not (free ?r1))
                (not (free ?r2))
            ))
        )
    )

    ; Description: movement of the two robots from the assigned crate to the base.
    ; Requirements: the crate must have already been taken (the transportation has started 'carry ?r1 ?c' and carry ?r2 ?c) and that the two robots are working together (working_together).
    ; Duration: calculated based on the distance between the robot and the crate, the speed of the robot, all divided by 100 (value assigned by the problem).
    (:durative-action move_back_two_robot
        :parameters (?c - crate ?b - base ?r1 - robot ?r2 - robot)
        :duration (= ?duration  (/ (* (distance ?c ?b)(weight ?c)) 100))
        :condition (and 
            (at start (and 
                (at_crate ?r1 ?c)
                (at_crate ?r2 ?c)
                
            ))
            (over all (and 
                (carry ?r1 ?c)
                (carry ?r2 ?c)
                (working_together)
            ))
        )
        :effect (and 
            (at start (and
                (not (at_crate ?r2 ?c))
                (not (at_crate ?r1 ?c))
            ))
            (at end (and 
                (at_base ?r1 ?b)
                (at_base ?r2 ?b)
                (decrease (battery ?r1) (/ (* (distance ?c ?b)(weight ?c)) 100)) ; decrease battery
                (decrease (battery ?r2) (/ (* (distance ?c ?b)(weight ?c)) 100)) ; decrease battery
            ))
        )
    )
    
    ; Description: movement of the two robots from the assigned crate to the base. 
    ; Requirements: the crate must have already been picked up (the transport has started 'carry ?r1 ?c' and carry ?r2 ?c), that the two robots are working together (working_together). 
    ; Furthermore, this action is specific for transporting light crates because it is represented by a faster execution (/ (* (distance ?c ?b)(weight ?c)) 150) 
    ; Duration: calculated based on the distance between the robot and the crate, the speed of the robot, all divided by 150 (value assigned by the problem).
    (:durative-action move_back_two_robot_leggero
        :parameters (?c - crate ?b - base ?r1 - robot ?r2 - robot)
        :duration (= ?duration  (/ (* (distance ?c ?b)(weight ?c)) 150))
        :condition (and 
            (at start (and 
                (at_crate ?r1 ?c)
                (at_crate ?r2 ?c)
                
            ))
            (over all (and 
                (carry ?r1 ?c)
                (carry ?r2 ?c)
                (<(weight ?c) 50)
                (working_together)
            ))
        )
        :effect (and 
            (at start (and
                (not (at_crate ?r2 ?c))
                (not (at_crate ?r1 ?c))
            ))
            (at end (and 
                (at_base ?r1 ?b)
                (at_base ?r2 ?b)
                (decrease (battery ?r1) (/ (* (distance ?c ?b)(weight ?c)) 100))
                (decrease (battery ?r2) (/ (* (distance ?c ?b)(weight ?c)) 100))
            ))
        )
    )

    ; Description: drop of the box assigned to the two robots. 
    ; Requirements: allowed only when the base is free (<(free_base)2) and the box does not belong to any group (no_group ?c). 
    ; Duration: instantaneous action.
    (:durative-action drop_two_robot
        :parameters (?b - base ?c - crate ?r1 - robot ?r2 - robot)
        :duration (= ?duration 1)
        :condition (and 
            (at start (and 
                (carry ?r1 ?c)
                (carry ?r2 ?c)
            ))
            (over all (and 
                (at_base ?r1 ?b)
                (at_base ?r2 ?b)
                (<(free_base)2)
                (no_group ?c) ; a crate do not belongs to any group
                (=(priority)(max_priority)) ; "The crate must have the maximum priority for the drop to happen."
            ))
        )
        :effect (and 
            (at start (and 
                
                (not (carry ?r1 ?c))
                (not (carry ?r2 ?c))
                (increase (free_base) 1) ; Increase the crate count on the base (free_base) by one to prevent too many crates from being dropped onto the base.

            ))
            (at end (and 
                (at ?c ?b)
                (free ?r1)
                (free ?r2)
            ))
        )
    )

    ; ACTIONS TO DEFINE THE LOADING MOVEMENT OF THE BOXES FROM THE BASE TO THE BELT BY THE MAIN LOADER.
    ; Note: the action 'loading' is specific for non-fragile boxes because for fragile crates the loader will need to pay more attention (taking more time),
    ; thus a specific function has been defined: 'loading_fragile'.

    ; Description: movement of picking up the crate by the loader.
    ; Requirements: there must be a crate on the base and the loader must be free.
    ; Duration: instantaneous action.
    (:action grasp
        :parameters (?c - crate ?b - base ?l - loader)
        :precondition (and 
            (at ?c ?b)
            (free_loader ?l)
        )
        :effect (and 
            (not (at ?c ?b))
            (not (free_loader ?l))
            (pick_load ?l ?c) ; loader has picked up the crate 
            (decrease (priority) 1) ; decrease the priority of the crate
        )
    )
    
    ; Description: loading movement of the box onto the belt by the loader. 
    ; Requirements: the box must have been taken from the main loader and must not be fragile. 
    ; Duration: lasting action, with a value of 4 (defined by the problem).
    (:durative-action loading
        :parameters (?l - loader ?c - crate ?b - base)
        :duration (= ?duration 4)
        :condition (and 
            (over all (and 
                (pick_load ?l ?c)
                (not_fragile ?c) ; specific for non-fragile crates
            ))
        )
        :effect (and 
            (at end (and 
                (on_belt ?c) ; crate is on the belt
                (free_loader ?l) ; loader can continue working
                (not (pick_load ?l ?c)) ; loader has not any crates assigned 
                (decrease (free_base) 1) ; on the base there is a space for a new crate
            ))
        )
    )
       
    ; ACTIONS FOR SEQUENCED TRANSPORT OF BOXES BELONGING TO THE SAME GROUP: extension 1.
    ; Two different drop actions have been defined for the specific group in case only one robot is involved in the transport ('drop_A', 'drop_B') and two other different drop actions for the specific group in case two different robots are necessary (case of heavy, fragile, or light boxes) ('drop_two_robot_A', 'drop_two_robot_B').

    ; Description: drop of the box belonging to group A assigned to a single robot.
    ; Requirements: allowed only for light and non-fragile boxes. Additionally, the base must be free (<(free_base)2) and belong to group A.
    ; Duration: action lasts for 1 second.
    (:durative-action drop_A
        :parameters (?b - base ?c - crate ?r - robot)
        :duration (= ?duration 1)
        :condition (and 
            (at start (and 
                (carry ?r ?c)
            ))
            (over all (and 
                (at_base ?r ?b)
                (<= (weight ?c) 50)
                (not_fragile ?c)
                (<(free_base)2)
                (groupA ?c)
            ))
        )
        :effect (and 
            (at start (and 
                
                (not (carry ?r ?c))
                (increase (free_base) 1)
            ))
            (at end (and 
                (at ?c ?b)
                (free ?r)
                
                
            ))
        )
    )
    
    ; Description: drop of the box belonging to group B assigned to a single robot.
    ; Requirements: allowed only for lightweight and non-fragile boxes. Additionally, the base must be free (<(free_base)2) and belong to group B.
    ; Duration: action duration of 1 second.
    (:durative-action drop_B
        :parameters (?b - base ?c - crate ?r - robot)
        :duration (= ?duration 1)
        :condition (and 
            (at start (and 
                (carry ?r ?c)
            ))
            (over all (and 
                (at_base ?r ?b)
                (<= (weight ?c) 50)
                (not_fragile ?c)
                (<(free_base)2)
                (<=(priority)0) ; 0-Priority for crates belonging to group B
                (groupB ?c) ; belongs to group B
            ))
        )
        :effect (and 
            (at start (and 
                
                (not (carry ?r ?c))
                (increase (free_base) 1)
            ))
            (at end (and 
                (at ?c ?b)
                (free ?r)
                
            ))
        )
    )
    
    ; Description: drop of the box belonging to group A assigned to two different robots. 
    ; Requirements: The base must be free (<(free_base)2) and belong to group A. 
    ; Duration: action duration of 1 second.
    (:durative-action drop_two_robot_A
        :parameters (?b - base ?c - crate ?r1 - robot ?r2 - robot)
        :duration (= ?duration 1)
        :condition (and 
            (at start (and 
                (carry ?r1 ?c)
                (carry ?r2 ?c)
            ))
            (over all (and 
                (at_base ?r1 ?b) ; robot 1 is at the base
                (at_base ?r2 ?b) ; robot 2 is at the base
                (<(free_base)2)
                (groupA ?c) ; crate belongs to group A
            ))
        )
        :effect (and 
            (at start (and 
                
                (not (carry ?r1 ?c))
                (not (carry ?r2 ?c))
                (increase (free_base) 1) ; Increase the crate count on the base (free_base) by one to prevent too many crates from being dropped onto the base.

            ))
            (at end (and 
                (at ?c ?b) ; crate is at the base
                (free ?r1)            
                (free ?r2)              
            ))
        )
    )
    ; Description: drop of the box belonging to group B assigned to two different robots.
    ; Requirements: The base must be free (<(free_base)2) and belong to group B.
    ; Duration: action duration of 1 second.
    (:durative-action drop_two_robot_B
        :parameters (?b - base ?c - crate ?r1 - robot ?r2 - robot)
        :duration (= ?duration 1)
        :condition (and 
            (at start (and 
                (carry ?r1 ?c)
                (carry ?r2 ?c)
            ))
            (over all (and 
                (at_base ?r1 ?b) ; robot 1 is at the base
                (at_base ?r2 ?b) ; robot 2 is at the base
                (<(free_base)2)
                (groupB ?c) ; crate belongs to group B
                (<=(priority)0) ; 0-Priority for crates belonging to group B
            ))
        )
        :effect (and 
            (at start (and 
                
                (not (carry ?r1 ?c))
                (not (carry ?r2 ?c))
                (increase (free_base) 1) ; Increase the crate count on the base (free_base) by one to prevent too many crates from being dropped onto the base.
            ))
            (at end (and 
                (at ?c ?b)
                (free ?r1)
                (free ?r2)                
            ))
        )
    )

    ; ACTIONS FOR THE SECOND LOADER: extension 2
    ; Note: the secondary loader is allowed to load only light boxes.

    ; Description: movement of grasping the box by the secondary loader.
    ; Requirements: there must be a box on the base and the secondary loader must be free. 
    ; Duration: instantaneous action.
    (:action grasp_leggero
        :parameters (?c - crate ?b - base ?ll - loader_leggero)
        :precondition (and 
            (at ?c ?b)
            (free_loader_leggero ?ll)
            (<(weight ?c) 50) ; action is specific for light boxes
        )
        :effect (and 
            (not (at ?c ?b))
            (not (free_loader_leggero ?ll))
            (pick_load_leggero ?ll ?c)
            (decrease (priority) 1) ; decrease the priority of the crate
        )
    )
    
    ; Description: loading movement of the box onto the belt by the secondary loader. 
    ; Requirements: the box must have been taken by the secondary loader, it must be light and not fragile (in this case 'light_frangible_loading' applies). 
    ; Duration: ongoing action, with a value of 4 (defined by the problem).
    (:durative-action loading_leggero
        :parameters (?ll - loader_leggero ?c - crate ?b - base)
        :duration (= ?duration 4)
        :condition (and 
            (over all (and 
                (pick_load_leggero ?ll ?c)
                (<(weight ?c) 50)
                (not_fragile ?c) ; specific for non-fragile crates
            ))
        )
        :effect (and 
            (at end (and 
                (on_belt ?c)
                (free_loader_leggero ?ll)
                (not (pick_load_leggero ?ll ?c))
                (decrease (free_base) 1)
            ))
        )
    )

    ; ACTIONS FOR THE ROBOT RECHARGE: extension 3

    ; Description: robot recharge.
    ; Requirements: the robot must be free and the charging base must be free.
    ; Duration: calculated based on the robot's battery and the maximum battery value (20), in this way the action will only finish when the robot is completely charged.

    (:durative-action charging
       :parameters (?r - robot ?b - base)
        :duration (= ?duration (-(max_battery)(battery ?r)))
        :condition (and 
        (at start (and 
               (at_base ?r ?b)
               (free ?r)
               (free_charger ?b)
        ))
        
    )
        :effect (and 
           (at start (and
               (not (free ?r))
               (not (free_charger ?b)) ; charging base is not free
        ))
           (at end (and 
               (assign (battery ?r) 20) ; battery is fully charged
               (free ?r) ; robot is ready to continue working
               (free_charger ?b)
        ))
    )
)
 

    ; ACTION FOR FRAGILE CASES: extension 4

    ; Description: loading movement of the case onto the belt by the main loader.
    ; Requirements: the case must have been taken by the main loader and must be fragile.
    ; Duration: enduring action, with a value of 6 (defined by the issue in cases of fragility because the loader must pay greater attention).
    (:durative-action loading_fragile
        :parameters (?l - loader ?c - crate ?b - base)
        :duration (= ?duration 6)
        :condition (and 
            (over all (and 
                (pick_load ?l ?c)
                (fragile ?c)
            ))
        )
        :effect (and 
            (at end (and 
                (on_belt ?c)
                (free_loader ?l)
                (not (pick_load ?l ?c))
                (decrease (free_base) 1)
            ))
        )
    )

    ; Description: movement of loading the crate onto the conveyor by the secondary loader for light and fragile crates.
    ; Requirements: the crate must have been picked up by the secondary loader, and it must be light and fragile.
    ; Duration: durative action, with a duration of 6 (defined in the problem).
    (:durative-action loading_leggero_fragile
        :parameters (?ll - loader_leggero ?c - crate ?b - base)
        :duration (= ?duration 6)
        :condition (and 
            (over all (and 
                (pick_load_leggero ?ll ?c)
                (<(weight ?c) 50)
                (fragile ?c)
            ))
        )
        :effect (and 
            (at start 
                (decrease (free_base) 1)
            )
            (at end (and 
                (on_belt ?c)
                (free_loader_leggero ?ll)
                (not (pick_load_leggero ?ll ?c))
            ))
        )
    )

)