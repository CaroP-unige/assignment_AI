;Header and description

(define (domain example2)

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
    ;todo: define predicates here
    )


    (:functions 
        (distance ?c - crate ?b - base)
        (weight ?c - crate)
        (velocity)
    ;todo: define numeric functions here
    )

    (:durative-action move_to_crate
        :parameters (?c - crate ?r - robot ?b - base)
        :duration (= ?duration (/(distance ?c ?b)(velocity)))
        :condition (and 
            (at start (and 
                (at_base ?r ?b)
                (free ?r)
            ))
            (over all (and
                (pickable_crate ?c) 
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
            ))
        )
    )

    (:action pick_up
        :parameters (?c - crate ?r - robot)
        :precondition (and 
            (at_crate ?r ?c)
            (pickable_crate ?c)
        )
        :effect (and 
            (carry ?r ?c)
            (not (pickable_crate ?c))
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
            ))
        )
        :effect (and 
            (at end (and 
                (at_base ?r ?b)
                (not (at_crate ?r ?c))
            ))
        )
    )

    (:action drop_one_robot
        :parameters (?b - base ?c - crate ?r - robot)
        :precondition (and 
            (carry ?r ?c)
            (at_base ?r ?b)
        )
        :effect (and 
            (at ?c ?b)
            (not (carry ?r ?c))
            (free ?r)
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
        :parameters (?l - loader ?c - crate)
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
            ))
        )
    )
    
    
    
    
;define actions here

)
