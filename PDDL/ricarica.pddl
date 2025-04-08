;Header and description

(define (domain ricarica_batteria)

;remove requirements that are not needed
    (:requirements :strips :fluents :durative-actions :timed-initial-literals :typing :conditional-effects :negative-preconditions :duration-inequalities :equality)

    (:types 
        robot
        crate
        base
        loader
    ;todo: enumerate types and their hierarchy here, e.g. car truck bus - vehicle
    )

    ; un-comment following line if constants are needed
    ;(:constants )

    (:predicates 
        (at_base ?r - robot ?b - base)
        (pickable_crate ?c - crate)
        (at_crate ?r - robot ?c - crate)
        (free ?r - robot)
        (carry ?r - robot ?c - crate)
        (at ?c - crate ?b - base)
        (free_loader ?l - loader)
        (on_belt ?c - crate)
        (pick_load ?l - loader ?c - crate)
        (free_base ?b - base)
        (free_charge ?b - base)
    ;todo: define predicates here
    )


    (:functions 
        (distance ?c - crate ?b - base)
        (weight ?c - crate)
        (velocity)
        (battery ?r - robot)
    ;todo: define numeric functions here
    )

    

    ;Azione per la carica del robot
    (:action charging
        :parameters (?b - base ?r - robot)
        :precondition (and (< (battery ?r) 20)(at_base ?r ?b)(free ?r)(free_charge ?b))
        :effect (and 
            (not (free_charge ?b))
            (increase (battery ?r) 1)
        )
    )

    ;Rilascio della posizione di carica
    (:action fully_charged
        :parameters (?b - base ?r - robot)
        :precondition (and (=(battery)20))
        :effect (and 
            (free_charge ?b)
        )
    )
    
    

    (:durative-action move_to_crate
        :parameters (?c - crate ?r - robot ?b - base)
        :duration (= ?duration (/(distance ?c ?b)(velocity)))
        :condition (and 
            (at start (and 
                
                (at_base ?r ?b)
                (free ?r)
                (< (weight ?c) 50)
                
            ))
            (over all (and
                (pickable_crate ?c)
                (> (battery ?r) 10)
                 
            ))
        )
        :effect (and 
            (at start (and
                (not (free ?r))
            )
            )
            (at end (and 
                (at_crate ?r ?c)
                (not (at_base ?r ?b))
                (decrease (battery ?r) (/(distance ?c ?b)(velocity)))
            ))
        )
    )

    (:action pick_up
        :parameters (?c - crate ?r - robot)
        :precondition (and 
            (at_crate ?r ?c)
            (pickable_crate ?c)
            (< (weight ?c) 50)
        )
        :effect (and 
            (carry ?r ?c)
            (not (pickable_crate ?c))
            (decrease (battery ?r) 1)
        )
    )

    (:durative-action move_back
        :parameters (?c - crate ?b - base ?r - robot)
        :duration (= ?duration (/ (* (distance ?c ?b)(weight ?c)) 100))
        :condition (and 
            (at start (and 
                (at_crate ?r ?c)
                
            ))
            (over all (and 
                (carry ?r ?c)
                (< (weight ?c) 50)
            ))
        )
        :effect (and 
            (at end (and 
                (at_base ?r ?b)
                (not (at_crate ?r ?c))
                (decrease (battery ?r) (/ (* (distance ?c ?b)(weight ?c)) 100))
            ))
        )
    )

    (:action drop_one_robot
        :parameters (?b - base ?c - crate ?r - robot)
        :precondition (and 
            (carry ?r ?c)
            (at_base ?r ?b)
            (free_base ?b)
            (< (weight ?c) 50)
        )
        :effect (and 
            (at ?c ?b)
            (not (carry ?r ?c))
            (free ?r)
            (not (free_base ?b))
            (decrease (battery ?r) 1)
        )
    )
    
    (:durative-action move_two_robot
        :parameters (?r1 - robot ?r2 - robot ?c - crate ?b - base)
        :duration (= ?duration (/ (distance ?c ?b) 10))
        :condition (and 
            (at start (and 
                (>=(battery ?r1)10)
                (>=(battery ?r2)10)
                (at_base ?r1 ?b)
                (at_base ?r2 ?b)
                (free ?r2)
                (free ?r1)
            ))
            (over all (and
                (pickable_crate ?c)
            ))
        )
        :effect (and 
            (at start (and
                (not (free ?r1))
                (not (free ?r2))
            ))
            (at end (and 
                (at_crate ?r1 ?c)
                (at_crate ?r2 ?c)
                (not (at_base ?r2 ?b))
                (not (at_base ?r1 ?b))
                (decrease (battery ?r1) (/(distance ?c ?b)(velocity)))
                (decrease (battery ?r2) (/(distance ?c ?b)(velocity)))
            ))
        )
    )

    (:action pick_two_robot
        :parameters (?r1 - robot ?r2 - robot ?c - crate)
        :precondition (and
            (at_crate ?r1 ?c)
            (at_crate ?r2 ?c)
            (pickable_crate ?c)
         )
        :effect (and 
            (not (free ?r1))
            (not (free ?r2))
            (carry ?r1 ?c)
            (carry ?r2 ?c)
            (not (pickable_crate ?c))
            
        )
    )
    
    (:durative-action move_back_two_robot
        :parameters (?c - crate ?r1 - robot ?r2 - robot ?b - base)
        :duration (= ?duration (/ (* (distance ?c ?b) (weight ?c)) 100))
        :condition (and 
            (at start (and
                (at_crate ?r1 ?c)
                (at_crate ?r2 ?c)
                (> (weight ?c) 50)
            ))
            (over all (and
            (carry ?r1 ?c)
            (carry ?r2 ?c)
            ))
            
        )
        :effect (and 
            (at end (and 
                (at_base ?r1 ?b)
                (at_base ?r2 ?b)
                (not (at_crate ?r1 ?c))
                (not (at_crate ?r2 ?c))
                (decrease (battery ?r1) (/ (* (distance ?c ?b)(weight ?c)) 100))
                (decrease (battery ?r2) (/ (* (distance ?c ?b)(weight ?c)) 100))
            ))
        )
    )

    (:durative-action move_back_two_robot_light_crate
        :parameters (?c - crate ?r1 - robot ?r2 - robot ?b - base)
        :duration (= ?duration (/ (* (distance ?c ?b) (weight ?c)) 150))
        :condition (and 
            (at start (and
                (at_crate ?r1 ?c)
                (at_crate ?r2 ?c)
                (< (weight ?c) 50)
            ))
            (over all (and
            (carry ?r1 ?c)
            (carry ?r2 ?c)
            ))
            
        )
        :effect (and 
            (at end (and 
                (at_base ?r1 ?b)
                (at_base ?r2 ?b)
                (not (at_crate ?r1 ?c))
                (not (at_crate ?r2 ?c))
                (decrease (battery ?r1) (/ (* (distance ?c ?b)(weight ?c)) 150))
                (decrease (battery ?r2) (/ (* (distance ?c ?b)(weight ?c)) 150))
            ))
        )
    )
    
    (:action drop_two_robot
        :parameters (?b - base ?c - crate ?r1 - robot ?r2 - robot)
        :precondition (and 
            (free_base ?b)
            (carry ?r1 ?c)
            (carry ?r2 ?c)
            (at_base ?r1 ?b)
            (at_base ?r2 ?b)
            
        )
        :effect (and 
            (at ?c ?b)
            (not (carry ?r1 ?c))
            (not (carry ?r2 ?c))
            (free ?r1)
            (free ?r2)
            (not (free_base ?b))

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
        )
    )
    
    (:durative-action loading
        :parameters (?l - loader ?c - crate ?b - base)
        :duration (= ?duration 4)
        :condition (and 
            (over all (and 
                (pick_load ?l ?c)
            ))
        )
        :effect (and 
            (at end (and 
                (on_belt ?c)
                (free_loader ?l)
                (not (pick_load ?l ?c))
                (free_base ?b)
            ))
        )
    )
    
    
    
;define actions here

)