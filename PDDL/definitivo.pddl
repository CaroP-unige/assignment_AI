;Header and description

(define (domain definitivo)

;remove requirements that are not needed
(:requirements :strips :fluents :durative-actions :timed-initial-literals :typing :conditional-effects :negative-preconditions :duration-inequalities :equality)

(:types 
    robot
    base
    crate
    loader
    loader_leggero
;todo: enumerate types and their hierarchy here, e.g. car truck bus - vehicle
)

; un-comment following line if constants are needed
;(:constants )

(:predicates 
    (at_crate ?r - robot ?c - crate)
    (at_base ?r - robot ?b - base)
    (carry ?r - robot ?c - crate)
    (free ?r - robot)
    (at ?c - crate ?b - base)
    (pickable_crate ?c - crate)
    (free_charger ?b - base)
    (free_loader ?l - loader)
    (free_loader_leggero ?ll - loader_leggero) ;loader_legger
    (pick_load ?l - loader ?c - crate)
    (pick_load_leggero ?ll - loader_leggero ?c - crate) ;loader_leggero
    (on_belt ?c - crate)
    (fragile ?c - crate)
    (not_fragile ?c - crate)
    (groupA ?c - crate)
    (groupB ?c - crate)
    (no_group ?c - crate)
    

;todo: define predicates here
)


(:functions 
    
    (battery ?r - robot)
    (distance ?c - crate ?b - base)
    (velocity)
    (weight ?c - crate)
    (max_battery)
    (free_base)
    (priority)
    (max_priority)
;todo: define numeric functions here
)

;define actions here
    ;move robot to non fragile crate
    (:durative-action move_to_crate
        :parameters (?r - robot ?c - crate ?b - base)
        :duration (= ?duration (/(distance ?c ?b)(velocity)))
        :condition (and 
            (at start (and 
                (at_base ?r ?b)
            ))
            (over all (and 
                
                (pickable_crate ?c)
                (> (battery ?r) 15)
                (free ?r)
                (<= (weight ?c) 50)
                (not_fragile ?c)
            ))
        )
        :effect (and 
            (at start (and (not (at_base ?r ?b))))
            (at end (and 
                (at_crate ?r ?c)(decrease (battery ?r) (/(distance ?c ?b)(velocity)))
            ))  
        )
    )
    

    
    
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
            (not (free_charger ?b))
        ))
        (at end (and 
            (assign (battery ?r) 20)
            (free ?r)
            (free_charger ?b)
        ))
    )
)

    ;move back robot from crate to base, not fragile crate
    (:durative-action move_back
        :parameters (?c - crate ?b - base ?r - robot)
        :duration (= ?duration  (/ (* (distance ?c ?b)(weight ?c)) 100))
        :condition (and 
            (at start (and 
                (at_crate ?r ?c)
                
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
                (decrease (battery ?r) (/ (* (distance ?c ?b)(weight ?c)) 100))
            ))
        )
    )


    ;pick up a non fragile crate
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
                (carry ?r ?c) 
                (not (free ?r))
            ))
        )
    )
    
    ;drop a non fragile crate
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
                (<=(free_base)2)
                (=(priority)(max_priority))
                (no_group ?c)
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
                (<=(free_base)2)
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
                (<=(free_base)2)
                (<=(priority)0)
                (groupB ?c)
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
    

    ;TWO ROBOT ACTIONS
    
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
                (> (battery ?r1) 15)
                (> (battery ?r2) 15)

            ))
        )
        :effect (and 
            (at start (and 
                (not (at_base ?r1 ?b))
                (not (at_base ?r2 ?b))))
            (at end (and 
                (at_crate ?r1 ?c)
                (at_crate ?r2 ?c)
                (decrease (battery ?r1) (/(distance ?c ?b)(velocity)))
                (decrease (battery ?r2) (/(distance ?c ?b)(velocity)))
            ))  
        )
    )

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
                (carry ?r1 ?c)
                (carry ?r2 ?c)
                
                (not (free ?r1))
                (not (free ?r2))
            ))
        )
    )


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
                (<=(free_base)2)
                (no_group ?c)
                (=(priority)(max_priority))
            ))
        )
        :effect (and 
            (at start (and 
                
                (not (carry ?r1 ?c))
                (not (carry ?r2 ?c))
                (increase (free_base) 1)

            ))
            (at end (and 
                (at ?c ?b)
                (free ?r1)
                
                (free ?r2)
                
                
                
            ))
        )
    )

    (:durative-action drop_two_robot_A
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
                (<=(free_base)2)
                (groupA ?c)
            ))
        )
        :effect (and 
            (at start (and 
                
                (not (carry ?r1 ?c))
                (not (carry ?r2 ?c))
                (increase (free_base) 1)

            ))
            (at end (and 
                (at ?c ?b)
                (free ?r1)
                
                (free ?r2)
                
                
                
            ))
        )
    )

    (:durative-action drop_two_robot_B
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
                (<=(free_base)2)
                (groupB ?c)
                (<=(priority)0)
            ))
        )
        :effect (and 
            (at start (and 
                
                (not (carry ?r1 ?c))
                (not (carry ?r2 ?c))
                (increase (free_base) 1)
            ))
            (at end (and 
                (at ?c ?b)
                (free ?r1)
                
                (free ?r2)
                
                
                
            ))
        )
    )

    (:action grasp
        :parameters (?c - crate ?b - base ?l - loader)
        :precondition (and 
            (at ?c ?b)
            (free_loader ?l)
        )
        :effect (and 
            (not (at ?c ?b))
            (not (free_loader ?l))
            (pick_load ?l ?c)
            (decrease (priority) 1)
        )
    )
    

    ;non fragile crate loading
    (:durative-action loading
        :parameters (?l - loader ?c - crate ?b - base)
        :duration (= ?duration 4)
        :condition (and 
            (over all (and 
                (pick_load ?l ?c)
                (not_fragile ?c)
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

    ;fragile crate loading
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

    ;grasp_leggero
    (:action grasp_leggero
        :parameters (?c - crate ?b - base ?ll - loader_leggero)
        :precondition (and 
            (at ?c ?b)
            (free_loader_leggero ?ll)
            (<(weight ?c) 50)
        )
        :effect (and 
            (not (at ?c ?b))
            (not (free_loader_leggero ?ll))
            (pick_load_leggero ?ll ?c)
            (decrease (priority) 1)
        )
    )
    

    ;loading_leggero
    (:durative-action loading_leggero
        :parameters (?ll - loader_leggero ?c - crate ?b - base)
        :duration (= ?duration 4)
        :condition (and 
            (over all (and 
                (pick_load_leggero ?ll ?c)
                (<(weight ?c) 50)
                (not_fragile ?c)
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
