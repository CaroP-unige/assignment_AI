;Header and description

(define (domain batteria)

;remove requirements that are not needed
(:requirements :strips :fluents :durative-actions :timed-initial-literals :typing :conditional-effects :negative-preconditions :duration-inequalities :equality)

(:types 
    robot
    base
    crate
    loader
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
    (pick_load ?l - loader ?c - crate)
    (free_base ?b - base)
    (on_belt ?c - crate)

;todo: define predicates here
)


(:functions 
    
    (battery ?r - robot)
    (distance ?c - crate ?b - base)
    (velocity)
    (weight ?c - crate)
    (max_battery)
;todo: define numeric functions here
)

;define actions here

    (:durative-action move_to_crate
        :parameters (?r - robot ?c - crate ?b - base)
        :duration (= ?duration (/(distance ?c ?b)(velocity)))
        :condition (and 
            (at start (and 
                (at_base ?r ?b)
                (free ?r)
            ))
            (over all (and 
                
                (pickable_crate ?c)
                (> (battery ?r) 15)
                (free ?r)
                (<= (weight ?c) 50)
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
            ))
        )
        :effect (and 
            (at end (and 
                (carry ?r ?c)
                (not (pickable_crate ?c))
                (decrease (battery ?r) 1)
                (not (free ?r))
            ))
        )
    )
    
    (:durative-action drop
        :parameters (?b - base ?c - crate ?r - robot)
        :duration (= ?duration 1)
        :condition (and 
            (at start (and 
                (carry ?r ?c)
                (free_base ?b)
            ))
            (over all (and 
                (at_base ?r ?b)
                (<= (weight ?c) 50)
                
            ))
        )
        :effect (and 
            (at start (and 
                
                (not (carry ?r ?c))
                (not (free_base ?b))
            ))
            (at end (and 
                (at ?c ?b)
                (free ?r)
                (decrease (battery ?r) 1)
                
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
            (at end (and 
                (carry ?r1 ?c)
                (carry ?r2 ?c)
                (not (pickable_crate ?c))
                (decrease (battery ?r1) 1)
                (decrease (battery ?r2) 1)
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
                (free_base ?b)
            ))
        )
        :effect (and 
            (at start (and 
                
                (not (carry ?r1 ?c))
                (not (carry ?r2 ?c))
            ))
            (at end (and 
                (at ?c ?b)
                (free ?r1)
                (decrease (battery ?r1) 1)
                (free ?r2)
                (decrease (battery ?r2) 1)
                (not (free_base ?b))
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

)