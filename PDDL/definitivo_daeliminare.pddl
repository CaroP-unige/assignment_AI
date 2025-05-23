
(define (domain definitivo)

    
    (:requirements :strips :fluents :durative-actions :timed-initial-literals :typing :conditional-effects :negative-preconditions :duration-inequalities :equality)
    
    Types define categories of objects (e.g. robot, crate, room) and help to specify the entities involved in the domain.
    (:types 
        robot ; mover
        base
        crate
        loader
        loader_leggero
    )

    Predicates represent properties or relationships between objects, evaluated as true or false in a given state of the world.
    (:predicates 
        (at_base ?r - robot ?b - base) the robot is at the base
        (free ?r - robot) ; the robot is free
        (pickable_crate ?c - crate) ; the crate can be transported by the robot
        (at_crate ?r - robot ?c - crate) ; the robot is at the crate
        (carry ?r - robot ?c - crate) ; il robot sta trasportando una cassa
        (at ?c - crate ?b - base) ; la cassa è alla base (pronta per essere caricata sul nastro)
        (free_loader ?l - loader) ; il loader principale è libero
        (pick_load ?l - loader ?c - crate) ; il loader principale ha preso una cassa
        (on_belt ?c - crate) ; la cassa è sul nastro

        predicates to make the two robots work together (in case of heavy, fragile, or light crates to be faster)
        (not_working_together) ; i due robot non lavorano insieme
        (working_together) ; i due robot lavorano insieme

        ; estensione 1: 'Some crates go together'
        (groupA ?c - crate) ; la cassa appartiene al gruppo A
        (groupB ?c - crate) ; la cassa appartiene al gruppo B
        (no_group ?c - crate) ; la cassa non appartiene ad alcun gruppo

        ; estensione 2: 'There are 2 loaders'
        (free_loader_leggero ?ll - loader_leggero) ; il loader secondario è libero 
        (pick_load_leggero ?ll - loader_leggero ?c - crate) ; il loader secondario ha preso una crate (in questo caso sarà sicuramente leggera) 

        ; estensione 3: 'Mover robots need recharging'
        (free_charger ?b - base) ; la stazione di ricarica è libera 

        ; estensione 4: 'This is fragile!'
        (fragile ?c - crate) ; la cassa è fragile
        (not_fragile ?c - crate) ; la cassa non è fragile
    )

    ; Le funzioni (numeriche) modellano variabili fluide, come risorse o misurazioni (es. livello batteria), che possono variare nel tempo.
    (:functions 
        (velocity) ; velocità del robot durante il movimento (andare verso la cassa, tornare verso la base)
        (free_base) ; numero di casse sulla base, utile per definire se è libera (il robot può eseguire il drop). Al massimo possono stare nella base 1 casse per volta.
        (weight ?c - crate) ; peso della cassa (permette di differenziare casse pesanti da quelle leggere)
        (distance ?c - crate ?b - base) ; distanza tra il robot e la cassa
        
        ; estensione 1
        (priority) ; priorità tra le casse 
        (max_priority) ; massima priorità tra le casse 
        
        ; estensione 3
        (battery ?r - robot) ; batteria del robot
        (max_battery) ; batteria massima 
    )

    ; AZIONI DEFINITE PER QUANDO UN SOLO ROBOT PUò ESEGUIRE IL TRASPORTO DELLA CASSA: la cassa deve essere leggera (<= (weight ?c) 50) e non fragile (not_fragile ?c).
    ; Oss: il drop ha la caratteristica aggiuntiva di essere eseguito solo per casse che non appartengono a nessun gruppo, in caso contrario intervendono le azioni 'drop_A' e 'drop_B'

    ; Descrizione: movimento del robot dalla sua posizione alla cassa assegnata. 
    ; Requisiti: consentita solo per casse leggere e non fragili. 
    ; Durata: calcolata in base alla distanza tra il robot e la crate e la velocità del robot.
    (:durative-action move_to_crate
        :parameters (?r - robot ?c - crate ?b - base)
        :duration (= ?duration (/(distance ?c ?b)(velocity))) 
        :condition (and 
            (at start (and 
                (at_base ?r ?b)
            ))
            (over all (and 
                
                (pickable_crate ?c)
                (> (battery ?r) 15) ; il robot, per agire, deve avere una batteria sufficiente a finalizzare l'azione
                (free ?r)
                (<= (weight ?c) 50)
                (not_fragile ?c)
            ))
        )
        :effect (and 
            (at start (and 
            (not (at_base ?r ?b))
            (not_working_together) ; il robot lavora da solo
            (not (working_together))
            ))
            (at end (and 
                (at_crate ?r ?c)(decrease (battery ?r) (/(distance ?c ?b)(velocity))) ; avviene un decremento della batteria perchè azione duratura
            ))  
        )
    )

    ; Descrizione: pick up della cassa assegnata al robot. 
    ; Requisiti: consentita solo per casse leggere e non fragili. 
    ; Durata: azione di durata 1.
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
                (carry ?r ?c) ; inizia l'azione di trasporto
                (not (free ?r))
            ))
        )
    )

    ; Descrizione: movimento del robot dalla cassa assegnata alla base. 
    ; Requisiti: consentita solo per casse leggere e non fragili. 
    ; Durata: calcolata in base alla distanza tra il robot e la crate, il peso della cassa e tutto diviso per 100 (valore assegnato dal problema).
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
                (decrease (battery ?r) (/ (* (distance ?c ?b)(weight ?c)) 100)) ; avviene un decremento della batteria
            ))
        )
    )

    ; Descrizione: drop della cassa assegnata al robot. 
    ; Requisiti: consentita solo per casse leggere e non fragili. In aggiunta la base deve essere libera (<(free_base)2) e non deve appartenere a nessun gruppo (no_group ?c).
    ; Durata: azione di durata 1.
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
                (<(free_base)2) ; per poter eseguire il drop la base deve essere libera.
                (=(priority)(max_priority)) ; viene assegnata la priorità massima alle casse senza gruppo
                (no_group ?c) ; la cassa in questione non deve essere stata assegnata a nessun gruppo.
            ))
        )
        :effect (and 
            (at start (and 
                (not (carry ?r ?c)) ; finisce l'azione di trasporto.
                (increase (free_base) 1) ; aumenta il valore del numero di cassa nella base (free_base) di uno, per evitare che vengano droppate troppe casse sulla base.
            ))
            (at end (and 
                (at ?c ?b)
                (free ?r) ; il robot ora è libero, può eseguire altre azioni.
            ))
        )
    )

    ; AZIONI DEFINITE PER QUANDO PIù ROBOT POSSONO ESEGUIRE IL TRASPORTO DELLA CASSA: per casse pesanti, fragile e per casse leggere (se si vuole velocizzare l'esecuzione del
    ; ritorno alla base).

    ; Descrizione: movimento dei due robot dalla loro posizione alla cassa assegnata. 
    ; Requisiti: entrambi i robot devono avere abbastanza batteria (> (battery ?r1) 15) e (> (battery ?r2) 15). 
    ; Durata: calcolata in base alla distanza tra il robot e la crate e la velocità del robot.
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
                (> (battery ?r1) 15) ; controllo batteria robot 1
                (> (battery ?r2) 15) ; controllo batteria robot 2
            ))
        )
        :effect (and 
            (at start (and 
                (not (at_base ?r1 ?b))
                (not (at_base ?r2 ?b))
                (working_together) ; i robot lavorano insieme
                (not(not_working_together))
                ))
            (at end (and 
                (at_crate ?r1 ?c)
                (at_crate ?r2 ?c)
                (decrease (battery ?r1) (/(distance ?c ?b)(velocity))) ; avviene un decremento della batteria 
                (decrease (battery ?r2) (/(distance ?c ?b)(velocity))) ; avviene un decremento della batteria 
            ))  
        )
    )

    ; Descrizione: pick up della cassa assegnata ai due robot. 
    ; Requisiti: entrambi i robot devono essere liberi ed aver raggiunto la cassa disponibile (pickable_crate ?c). 
    ; Durata: azione istantanea.
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
                (carry ?r1 ?c) ; inizio azione di trasporto
                (carry ?r2 ?c) ; inizio azione di trasporto
                (not (free ?r1))
                (not (free ?r2))
            ))
        )
    )

    ; Descrizione: movimento dei due robot dalla cassa assegnata alla base. 
    ; Requisiti: la cassa deve essere già stata presa (il trasporto è iniziato 'carry ?r1 ?c' e carry ?r2 ?c) e che i due robot lavorino insieme (working_together). 
    ; Durata: calcolata in base alla distanza tra il robot e la crate, la velocità del robot, tutto diviso per 100 (valore assegnato dal problema).
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
                (decrease (battery ?r1) (/ (* (distance ?c ?b)(weight ?c)) 100)) ; avviene un decremento della batteria 
                (decrease (battery ?r2) (/ (* (distance ?c ?b)(weight ?c)) 100)) ; avviene un decremento della batteria 
            ))
        )
    )

    ; Descrizione: movimento dei due robot dalla cassa assegnata alla base. 
    ; Requisiti: la cassa deve essere già stata presa (il trasporto è iniziato 'carry ?r1 ?c' e carry ?r2 ?c), che i due robot lavorino insieme (working_together).
    ; Inoltre questa azione è specifica per il trasporto di casse leggere perchè è rappresentata da un'esecuzione più veloce (/ (* (distance ?c ?b)(weight ?c)) 150)
    ; Durata: calcolata in base alla distanza tra il robot e la crate, la velocità del robot, tutto diviso per 150 (valore assegnato dal problema).
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

    ; Descrizione: drop della cassa assegnata ai due robot. 
    ; Requisiti: consentita solo quando la base è libera (<(free_base)2) e la cassa non appartiene a nessun gruppo (no_group ?c).
    ; Durata: azione istantanea.
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
                (no_group ?c) ; nessun gruppo di appartenenza
                (=(priority)(max_priority)) ; per avvenire il drop la cassa deve avere la priorità uguale a quella massima
            ))
        )
        :effect (and 
            (at start (and 
                (not (carry ?r1 ?c))
                (not (carry ?r2 ?c))
                (increase (free_base) 1) ; aumenta il valore del numero di cassa nella base (free_base) di uno, per evitare che vengano droppate troppe casse sulla base.
            ))
            (at end (and 
                (at ?c ?b)
                (free ?r1)
                (free ?r2)
            ))
        )
    )

    ; AZIONI PER DEFINIRE IL MOVIMENTO DI CARICAMENTO DELLE CASSE DALLA BASE AL NASTRO DA PARTE DEL LOADER PRINCIPALE.
    ; Oss: l'azione 'loading' è specifica per casse non fragili perchè per casse fragili il loader dovrà prestare maggiore attenzione (impiegando più tempo), 
    ; è stata così definita una funzione specifica: 'loading_fragile'.

    ; Descrizione: movimento di presa della cassa da parte del loader. 
    ; Requisiti: ci deve essere una cassa sulla base ed il loader deve essere libero. 
    ; Durata: azione istantanea.
    (:action grasp
        :parameters (?c - crate ?b - base ?l - loader)
        :precondition (and 
            (at ?c ?b)
            (free_loader ?l)
        )
        :effect (and 
            (not (at ?c ?b))
            (not (free_loader ?l))
            (pick_load ?l ?c) ; il loader ha preso la cassa assegnata.
            (decrease (priority) 1) ; decremento della priorità assegnata genericamente alle casse
        )
    )
    
    ; Descrizione: movimento di caricamento della cassa sul nastro da parte del loader. 
    ; Requisiti: la cassa deve essere stata presa dal loader principale e non deve essere fragile. 
    ; Durata: azione durativa, di valore 4 (definito dal problema).
    (:durative-action loading
        :parameters (?l - loader ?c - crate ?b - base)
        :duration (= ?duration 4)
        :condition (and 
            (over all (and 
                (pick_load ?l ?c)
                (not_fragile ?c) ; azione specifica per casse non fragili
            ))
        )
        :effect (and 
            (at end (and 
                (on_belt ?c) ; la cassa è stata caricata sul nastro trasportatore
                (free_loader ?l) ; il loader ora puo' eseguire altre azioni
                (not (pick_load ?l ?c)) ; il loader non ha piu' la cassa assegnata
                (decrease (free_base) 1) ; sulla base si è liberato uno spazio per una nuova cassa.
            ))
        )
    )

    ; AZIONI PER IL TRASPORTO IN SEQUENZA DI CASSA APPARTENENTI ALLO STESSO GRUPPO: estensione 1.
    ; Sono state definite due differenti azioni di drop relative al gruppo specifico in caso intervenga nel trasporto un solo robot ('drop_A', 'drop_B') e altre due differenti 
    ; azioni di drop relative a gruppo specifico in caso siano dovuti intervenire due differenti robot (caso di casse pesanti, fragili o leggere) ('drop_two_robot_A', 'drop_two_robot_B')

    ; Descrizione: drop della cassa appartenente al gruppo A assegnata ad un solo robot. 
    ; Requisiti: consentita solo per casse leggere e non fragili. In aggiunta la base deve essere libera (<(free_base)2) ed appartenete al gruppo A.
    ; Durata: azione durata di 1 secondo.
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
                (groupA ?c) ; appartenente al gruppo A.
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

    ; Descrizione: drop della cassa appartenente al gruppo B assegnata ad un solo robot. 
    ; Requisiti: consentita solo per casse leggere e non fragili. In aggiunta la base deve essere libera (<(free_base)2) ed appartenete al gruppo B.
    ; Durata: azione durata di 1 secondo.
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
                (<=(priority)0) ; priorità 0 per le casse appartenenti al gruppo B
                (groupB ?c) ; appartenente al gruppo B.
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

    ; Descrizione: drop della cassa appartenente al gruppo A assegnata a due differenti robot. 
    ; Requisiti: La base deve essere libera (<(free_base)2) ed appartenete al gruppo A.
    ; Durata: azione durata di 1 secondo..
    (:durative-action drop_two_robot_A
        :parameters (?b - base ?c - crate ?r1 - robot ?r2 - robot)
        :duration (= ?duration 1)
        :condition (and 
            (at start (and 
                (carry ?r1 ?c)
                (carry ?r2 ?c)
            ))
            (over all (and 
                (at_base ?r1 ?b) ; robot 1 alla base
                (at_base ?r2 ?b) ; robot 2 alla base
                (<(free_base)2)
                (groupA ?c) ; la cassa appartiene al gruppo A
            ))
        )
        :effect (and 
            (at start (and 
                (not (carry ?r1 ?c))
                (not (carry ?r2 ?c))
                (increase (free_base) 1) ; aumenta il valore del numero di cassa nella base (free_base) di uno, per evitare che vengano droppate troppe casse sulla base.
            ))
            (at end (and 
                (at ?c ?b) ; la cassa è alla base
                (free ?r1)
                (free ?r2)
            ))
        )
    )

    ;Descrizione: drop della cassa appartenente al gruppo B assegnata a due differenti robot. 
    ; Requisiti: La base deve essere libera (<(free_base)2) ed appartenete al gruppo B.
    ; Durata: azione durata di 1 secondo..
    (:durative-action drop_two_robot_B
        :parameters (?b - base ?c - crate ?r1 - robot ?r2 - robot)
        :duration (= ?duration 1)
        :condition (and 
            (at start (and 
                (carry ?r1 ?c)
                (carry ?r2 ?c)
            ))
            (over all (and 
                (at_base ?r1 ?b) ; robot 1 alla base
                (at_base ?r2 ?b) ; robot 2 alla base
                (<(free_base)2)
                (groupB ?c) ; la cassa appartiene al gruppo B
                (<=(priority)0) ; priorità 0 per le casse appartenenti al gruppo B
            ))
        )
        :effect (and 
            (at start (and 
                
                (not (carry ?r1 ?c))
                (not (carry ?r2 ?c))
                (increase (free_base) 1) ; aumenta il valore del numero di cassa nella base (free_base) di uno, per evitare che vengano droppate troppe casse sulla base.
            ))
            (at end (and 
                (at ?c ?b)
                (free ?r1)
                (free ?r2)
            ))
        )
    )
        
    ; AZIONI PER IL SECONDO LOADER: estensione 2
    ; Oss: al loader secondario è permesso il caricamento di sole casse leggere.

    ; Descrizione: movimento di presa della cassa da parte del loader secondario. 
    ; Requisiti: ci deve essere una cassa sulla base ed il loader secondario deve essere libero. 
    ; Durata: azione istantanea.
    (:action grasp_leggero
        :parameters (?c - crate ?b - base ?ll - loader_leggero)
        :precondition (and 
            (at ?c ?b)
            (free_loader_leggero ?ll)
            (<(weight ?c) 50) ; azione solo per casse leggere
        )
        :effect (and 
            (not (at ?c ?b))
            (not (free_loader_leggero ?ll))
            (pick_load_leggero ?ll ?c)
            (decrease (priority) 1) ; decremento della priorità assegnata alle casse.
        )
    )

    ; Descrizione: movimento di caricamento della cassa sul nastro da parte del loader secondario. 
    ; Requisiti: la cassa deve essere stata presa dal loader secondario, deve essere leggera e non fragile (in questo caso interviene 'loading_leggero_fragile'). 
    ; Durata: azione durativa, di valore 4 (definito dal problema).
    (:durative-action loading_leggero
        :parameters (?ll - loader_leggero ?c - crate ?b - base)
        :duration (= ?duration 4)
        :condition (and 
            (over all (and 
                (pick_load_leggero ?ll ?c)
                (<(weight ?c) 50)
                (not_fragile ?c) ; azione specifica per casse leggere e fragili
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

    ; AZIONI PER LA RICARICA DEL ROBOT: estensione 3

    ; Descrizione: ricarica del robot. 
    ; Requisiti: il robot deve essere libero e la base di ricarica deve essere libera.
    ; Durata: calcolata in base alla batteria del robot ed al massimo valore della batteria(20), in questo modo l'azione finirà solo qunado il robot sarà completamente carico.
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
                (not (free_charger ?b)) ; la base di ricarica è occupata.
            ))
            (at end (and 
                (assign (battery ?r) 20) ; batteria al massimo valore.
                (free ?r) ; il robot è pronto per continuare le azioni in programma.
                (free_charger ?b)
            ))
        )
    )

    ; AZIONE PER CASSE FRAGILI: estensione 4
    
    ; Descrizione: movimento di caricamento della cassa sul nastro da parte del loader principale. 
    ; Requisiti: la cassa deve essere stata presa dal loader principale e deve essere fragile. 
    ; Durata: azione durativa, di valore 6 (definito dal problema in caso di casse fragili perchè il loader deve prestare maggiore attenzione).
    (:durative-action loading_fragile
        :parameters (?l - loader ?c - crate ?b - base)
        :duration (= ?duration 6)
        :condition (and 
            (over all (and 
                (pick_load ?l ?c)
                (fragile ?c) ; azione specifica per casse fragili
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

    ; Descrizione: movimento di caricamento della cassa sul nastro da parte del loader secondario per casse leggere e fragili. 
    ; Requisiti: la cassa deve essere stata presa dal loader secondario, deve essere leggera e fragile. 
    ; Durata: azione durativa, di valore 6 (definito dal problema).
    (:durative-action loading_leggero_fragile
        :parameters (?ll - loader_leggero ?c - crate ?b - base)
        :duration (= ?duration 6)
        :condition (and 
            (over all (and 
                (pick_load_leggero ?ll ?c)
                (<(weight ?c) 50)
                (fragile ?c) ; azione specifica per casse leggere e fragili
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
