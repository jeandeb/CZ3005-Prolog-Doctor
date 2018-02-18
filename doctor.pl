
%BASIC FACTS AND JAVA INTERFACE FOR BUILDING RULES
%-------------------------------------------------
%-------------------------------------------------
%-------------------------------------------------


%JAVA INTERFACE RULES
%-------------------------------------------------

%JAVA MODUL USED
:- use_module( library( jpl ) ).	   		


%MOLDABLE INTERFACE USING JPL
interface( QUESTION, INPUT, SYMPTOM ) :-

	%DEFINING FRAME, LABEL AND INPUT PANEL
	jpl_new( 'javax.swing.JFrame', ['Doctor'], F ), 
	jpl_new( 'javax.swing.JLabel', ['SYMPATHETIC DOCTOR'], LBL ), 
	jpl_new( 'javax.swing.JPanel', [], Pan ), 

	%DEFNINNG THE FRAME GRAPHIC DISPLAY
	jpl_call( Pan, add, [LBL], _ ), 

	%CHOOSING DIPLAY TYPE
	( INPUT -> 
		%GETTING THE ANSWER
		jpl_call( 'javax.swing.JOptionPane', showInputDialog, [F, QUESTION], Answer ), 
		(( Answer == yes ; Answer == y ) ->
			write(QUESTION), nl,
       		assert( have( SYMPTOM )) ;
       		assert( dont_have( SYMPTOM )), false );
		jpl_call( 'javax.swing.JOptionPane', showMessageDialog, [F, QUESTION], Answer )
	 ), 
	jpl_call( F, dispose, [], _ ).


%INTERFACE WITH ANSWER NEEDED
interface_w_ans( QUESTION ) :-
	interface( QUESTION , true, null ).


%BASIC INTERFACE DISPLAY
interface_n_asw( PHRASE ) :-
	interface( PHRASE, false, null ).


%FACTS OF THE LOGIC
%-------------------------------------------------

%DIFFERENT MOODS RANKED BY AROUSAL AND THEN VALENCE
mood( 1, happy ).
mood( 2, good+energetic ).

mood( 3, serein ).
mood( 4, good-energetic ).

mood( 5, angry ).
mood( 6, bad+energetic ).

mood( 7, sad ).
mood( 8, bad+nonenergetic ).


%DIFFERENT LEVELS OF PAIN
pain( 0, nopain ).
pain( 1, little_pain ).
pain( 2, painful ).
pain( 3, very_painful ).
pain( 4, unbearable_pain ).


%QUESTIONS ACCORDING TO PAIN/MOOD INDEX, THE LESS THE BETTER THE PATIENT STATE
questions( 0, "" ).
questions( 1, "My friend, " ).
questions( 2, "My dear friend, " ).
questions( 3, "My favorite patient, " ).
questions( 4, "No worries, but " ).
questions( 5, "I will save you, but " ).
questions( 6, "Take your time, but " ).


%RULES
%-------------------------------------------------
%-------------------------------------------------
%-------------------------------------------------

%POSSIBLE SETS OF DISEASE WITH ASSOCIATED SYMPTOMS
%-------------------------------------------------

disease( Prefix, mumps ) :-
    symptoms_q( Prefix, fever  ), 
    symptoms_q( Prefix, swollen_glands  ).

disease( Prefix, chicken_pox ) :-
    symptoms_q( Prefix, fever  ), 
    symptoms_q( Prefix, chill  ), 
    symptoms_q( Prefix, body_ache  ), 
    symptoms_q( Prefix, rash ).

disease( Prefix, measles  ) :-
    symptoms_q( Prefix, fever ), 
    symptoms_q( Prefix, cough ), 
    symptoms_q( Prefix, conjunctivitis ), 
    symptoms_q( Prefix, runny_nose ), 
    symptoms_q( Prefix, rash ).

disease( Prefix, german_measles ) :-
    symptoms_q( Prefix, fever ), 
    symptoms_q( Prefix, headache ), 
    symptoms_q( Prefix, runny_nosev ), 
    symptoms_q( Prefix, rash ).
    
disease( Prefix, flu ) :-
    symptoms_q( Prefix, fever ), 
    symptoms_q( Prefix, headache ), 
    symptoms_q( Prefix, body_ache ), 
    symptoms_q( Prefix, conjunctivitis ), 
    symptoms_q( Prefix, chill ), 
    symptoms_q( Prefix, sore_throat ), 
    symptoms_q( Prefix, runny_nose ), 
    symptoms_q( Prefix, cough ).    
    
disease( Prefix, common_cold ) :-
    symptoms_q( Prefix, headache ), 
    symptoms_q( Prefix, sneezing ), 
    symptoms_q( Prefix, sore_throat ), 
    symptoms_q( Prefix, runny_nose ), 
    symptoms_q( Prefix, chill ).

disease( Prefix, measles ) :-
    symptoms_q( Prefix, cough ), 
    symptoms_q( Prefix, sneezing ), 
    symptoms_q( Prefix, runny_nose ).
    
disease( _, "UNKOWNED" ).


%PREDICATE TO GET A SYMPTOMS BOOLEAN VALUE
symptoms_q( Prefix, Symptom ) :-

	%CHECKING THE MEMORY IF THIS HAS ALREADY BEEN QUERIED
	( have(Symptom) -> true;
    	( dont_have(Symptom) -> false;

    		%BUILD THE QUERY STRING
			atom_concat( Prefix, "Do you have a ", A ),
			atom_concat( A, Symptom, B ),
			atom_concat( B, " ? yes/y or no/n.", C ),

    		%IF NOT, ASK THE PATIENT
			interface( C, true, Symptom ))).



%SEQUENCED PRINCIPAL OPERATIONS
consult :-  
			%GETTING MOOD LEVEL
        	get_mood( X ), 

        	%GETTING PAIN LEVEL
        	get_pain( Y ), 

        	%GETTING THE PREFIX TO FURTURE QUESTIONS
        	prefix( X, Y, Prefix ), 

        	%GETTING DISEASE
        	disease( Prefix, Disease ), 

        	%CREATING AMND DISPLAYING LAST STRING
        	atom_concat( Prefix, "You have ", A ),
			atom_concat( A, Disease, B ),
			atom_concat( B, "...", C ),
        	interface_n_asw( C ),
        	undo.

undo :- retract(have(_)),false. 
undo :- retract(dont_have(_)),false.
undo.

%FINDING THE PREFIX FOR A GIVEN A PAIN/MOOD INDEX
prefix( X, Y, Prefix ) :- 
	Ag is div( X+Y, 2 ), 
    questions( Ag, Prefix ).


%TREE SEARCH FOR MOOD TYPE
get_mood( X ) :-
	( interface_w_ans( 'Do you feel good ?' ) ->
		( interface_w_ans( 'Do you feel energetic ?' ) -> 
			( interface_w_ans( 'Do you feel Happy ?' ) -> mood( Y, happy );
														  mood( Y, good+energetic )
			 );
			 ( interface_w_ans( 'Do you feel Serein ?' ) -> mood( Y, serein );
															mood( Y, good-energetic )
			 )
		 );
		( interface_w_ans( 'Do you feel energetic ?' ) -> 
			( interface_w_ans( 'Do you feel Angry ?' ) -> mood( Y, angry );
														  mood( Y, bad+energetic )
			 );
			 ( interface_w_ans( 'Do you feel Sad ?' ) -> mood( Y, sad );
												   		 mood( Y, bad+nonenergetic )
			 )
		 )
	 ), X is Y.

%TREE SEARCH FOR PAIN LEVEL	
get_pain( Y ) :-
	( interface_w_ans( 'Do you feel pain ?' ) ->
		( interface_w_ans( 'Do you feel a lot of pain ?' ) -> 
			( interface_w_ans( 'Is it unbearable ?' ) -> pain( X, unbearable_pain );
														 pain( X, very_painful )
			 );
			 ( interface_w_ans( 'Is very little ?' ) -> pain( X, little_pain );
												  		pain( X, painful )
			 )
		 );
		pain( X, nopain ) ), 
		Y is X.













