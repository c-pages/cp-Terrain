



struct str_result_intersection (
	est_projection = false,
	pos,
	distance,
	knot_1,
	knot_2
)


struct 	str_shape_outils	(
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	private
		m_debug = true,
		m_dbgPrefix ="urba | str_shape_outils",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
		
		
		
	public		
	----- boucler id knots	 -------------
		fn boucler 	_shape	_id_spline	_id_a_boucler		=(
			if _id_a_boucler >	numKnots	_shape	_id_spline		do _id_a_boucler = mod _id_a_boucler (numKnots	_shape	_id_spline)
			if _id_a_boucler < 1 do _id_a_boucler += numKnots	_shape	_id_spline
			_id_a_boucler as integer
			
		),
		
		
		
	------------ Orientation, fermeture des splines	-------------------------------------------------------------------------------------------------------------------------

		
		fn pointLePlusHautsurY 		_shape	_idSpline	=(
			local pt1 = getKnotPoint _shape _idSpline 1
			local maxi = pt1.y
			local result_id = 1
			for i = 1 to numKnots _shape _idSpline	do (
				local pt = getKnotPoint _shape _idSpline i
				if  pt.y > maxi do ( 
					maxi = pt.y
					result_id = i
				)
			)
			result_id
		),
		fn est_sensPositif 				_shape 	_idSpline	=(
			
			local result 			= true
			local id_pointHaut 	=  pointLePlusHautsurY  	_shape	_idSpline
			
			local	id_pt_1 		= id_pointHaut - 1 	---- le point d'avant
			local	id_pt_ori 	= id_pointHaut 		---- le point origine
			local	id_pt_2 		= id_pointHaut + 1	---- le point d'apres
			
			-- Boucler limite nombre des points
			if id_pt_1 < 1 do id_pt_1 = numKnots _shape	_idSpline
			if id_pt_2 > numKnots _shape	_idSpline  do id_pt_2 = 1
			
			local	pt_1 		= getKnotPoint _shape _idSpline 	id_pt_1
			local	pt_ori 	= getKnotPoint _shape _idSpline 	id_pt_ori
			local	pt_2 		= getKnotPoint _shape _idSpline 	id_pt_2

			local	vec1 =  normalize ( pt_1 - pt_ori )
			local	vec2 =  normalize ( pt_2 - pt_ori )
			
			if vec2.x < vec1.X do result = not result
			
			result
			
		),
		fn orienter_splines 				_shape	=(
			for id_spline = 1 to numsplines _shape do
				if not est_sensPositif 	_shape 	id_spline do 
					reverse shp_cadre 	id_spline
			updateShape shp_cadre
		),
		fn fermer_splines 				_shape 	=(
			for id_spline = 1 to numsplines _shape do
				if not isClosed _shape id_spline do (
					close _shape id_spline 
				)
		),

	------- Angles ---------------------------------
		fn angle_from_points 	_pt_sommet	_pt1 	_pt2	=(
			
			local 	vec1 		= _pt1 - _pt_sommet
			local 	vec2 		= _pt2 - _pt_sommet
			
			local 	norm1	= normalize vec1
			local 	norm2	= normalize vec2
			
			
			local axeRot 		= 	normalize (cross vec2 vec1)
			local angleRot 	= 	acos (dot norm2 norm1)
			local angleQuat 	=	quat	angleRot		axeRot


			local 	result 	=  angleQuat
			
			result
			
		),
		
		
	------------ Droites, intersections et projections	-------------------------------------------------------------------------------------------------------------------------
		
		fn creer_droite 	_pt1	_pt2	= (
			local a = (_pt1.y - _pt2.y ) / (_pt1.x - _pt2.x)
			local b = _pt1.y - a * _pt1.x
			struct droite	(	a,b	)
			droite a:a	b:b
		),
		fn droites_intersection		_droite1		_droite2 =(
			if _droite1.a  != _droite2.a then (
				x 	= (_droite2.b - _droite1.b) / (_droite1.a - _droite2.a)
				y 	= 	_droite1.a * x + _droite1.b
				
				
-- 				point pos:[x, y, 0]	size:100 	wirecolor:red 	cross:false	box:true
				
				[x,y]
			) else false
		),
		fn segments_intersection 		_seg1_pt1	_seg1_pt2			_seg2_pt1	_seg2_pt2	=(
			
-- 		 	debug  "segments_intersection" 
			
			local result
			
			local angle_seuil = .1
			local droite1		=	creer_droite 	_seg1_pt1		_seg1_pt2
			local droite2		=	creer_droite 	_seg2_pt1		_seg2_pt2	
			local	pt_intersec = droites_intersection	droite1	droite2
			
			
			if pt_intersec !=	false then (
				
				--- on passe pt_intersec en 3D --------
				pt_intersec = [pt_intersec.x, pt_intersec.y, 0]
				
				local angle1 =  angle_from_points 	pt_intersec		_seg1_pt1 	_seg1_pt2
				
				
				local angle2 =  angle_from_points 	pt_intersec		_seg2_pt1 		_seg2_pt2
				
-- 		 		debug  "angle1" var:angle1.angle
-- 		 		debug  "angle2" var:angle2.angle
				local est_surSeg_1 = ( abs (angle1.angle - 180 ) ) < angle_seuil
				local est_surSeg_2 = ( abs (angle2.angle - 180 ) ) < angle_seuil
				
				
-- 		 		debug  "est_surSeg_1" var:est_surSeg_1
-- 		 		debug  "est_surSeg_2" var:est_surSeg_2
				
				if est_surSeg_1 and  est_surSeg_2  then (
					result = pt_intersec
					
					pt=		point pos:pt_intersec	size:150 	wirecolor:yellow	 cross:true 	box:false
					debug "helper" var:pt.name
				)
			)
			
-- 		 	debug  "result - segments_intersection" var:result
-- 			break ()
			
			result
		),
		fn projection_seg_sur_seg		_seg1_pt1	_seg1_pt2			_seg2_pt1	_seg2_pt2	=(
			
			local result 
			local angle_seuil = .3
			
			local droite1		=	creer_droite 	_seg1_pt1		_seg1_pt2
			local droite2		=	creer_droite 	_seg2_pt1		_seg2_pt2	
			local	pt_intersec = droites_intersection	droite1	droite2
			
			if pt_intersec !=	false then (
				
				local project_test_1 = false
				local project_test_2 = false
				
				pt_intersec = [pt_intersec.x, pt_intersec.y, 0]

				local vec1_test1 	=   _seg1_pt2 - _seg1_pt1
				local vec1_test2 	=   pt_intersec - _seg1_pt1
				local dot1 = dot ( normalize vec1_test2 )	(	normalize vec1_test1)
				local angle1 =  acos dot1
				
		-- 		format "angle1 : %\n" angle1
				
				if angle1 < angle_seuil and length vec1_test1 < length vec1_test2 do
					project_test_1 = true
		-- 		format "project_test_1 : %\n" project_test_1
				
				local vec2_test1 	=   _seg2_pt1 	- 	pt_intersec
				local vec2_test2 	=   _seg2_pt2 	-	pt_intersec 
				local dot2 = dot ( normalize vec2_test2 )	(	normalize vec2_test1)
				local angle2 =  acos dot2
				
		-- 		format "angle2 : %\n" angle2
				
					
				if angle2 > 180 - angle_seuil do
					project_test_2 = true
		-- 		format "project_test_2 : %\n" project_test_2
				
				if project_test_1 and  project_test_2  then  (
		-- 			format "			###projection OK###\n" 
				
					pt=		point pos:pt_intersec	size:150 	wirecolor:[150,150,250] cross:true 	box:false
					result = pt_intersec
		-- 			format "pt : %\n" pt.name 
				)
			)
			result
			
		),
		
		fn projection_vec_sur_shape 	 	_vec_pt1		_vec_pt2 			_shape 	_id_spline	=(
			
			local result =#()
			
			--- tester la projection du premier segment ---
			if not isClosed		_shape	_id_spline	do (
				local pt1 = getKnotPoint _shape _id_spline 2
				local pt2 = getKnotPoint _shape _id_spline 1
				local inter_proj = projection_seg_sur_seg 	_vec_pt1	 _vec_pt2	pt1		pt2 		
				if inter_proj != undefined do 	(
					local projec_result = str_result_intersection		est_projection:true	pos:inter_proj		knot_1:1	knot_2:2	 distance:(length (inter_proj- _vec_pt1 ))
					append result projec_result
				)
			)
			
			--- intersections avec segment ---
			for k = 2 to numknots _shape do (
				local pt1 = getKnotPoint _shape _id_spline (k- 1)
				local pt2 = getKnotPoint _shape _id_spline k
				local inter_proj = projection_seg_sur_seg 	_vec_pt1	 _vec_pt2	pt1		pt2 		
				if inter_proj != undefined do 	(
					local projec_result = str_result_intersection		est_projection:true	pos:inter_proj		knot_1:(k- 1)	knot_2:k		distance:(length (inter_proj- _vec_pt1 ))
					append result projec_result
				)
			)
			
			--- tester la projection du dernier segment ---
			if  isClosed		_shape	_id_spline	do (
				local pt1 = getKnotPoint _shape _id_spline ( numknots _shape )
				local pt2 = getKnotPoint _shape _id_spline 1
				local inter_proj = projection_seg_sur_seg 	_vec_pt1	 _vec_pt2	pt1		pt2 		
				if inter_proj != undefined do 	(
					local projec_result = str_result_intersection		est_projection:true	pos:inter_proj		knot_1:( numknots _shape ) 	knot_2:1		distance:(length (inter_proj- _vec_pt1 ))
					append result projec_result
				)
			)
			
			
			---- on classe les resultat par distance ---------
			fn compareFN 		v1 	v2 	= (
				
				local d = v1.distance	-	v2.distance
				case of
				(
					(d < 0.): -1
					(d > 0.): 1
					default: 0
				)
			)
			qsort 	result 	compareFN
			
			
			-- retour ------------
			if result.count>0	then 	result[1] 
									else 		undefined
		),
		
		
		fn seg_shape_intersection		_seg_pt1	_seg_pt2	_shape 		_id_spline	=(
			
-- 			debug "---> intersection ?"
			
			local result =#()
			
			--- tester la projection du premier segment ---
			if not isClosed		_shape	_id_spline	do (
-- 				debug "		tester la projection du premier segment" 
				local pt1 = getKnotPoint _shape _id_spline 2
				local pt2 = getKnotPoint _shape _id_spline 1
				local inter_proj = projection_seg_sur_seg 	 pt1		pt2 			_seg_pt1	_seg_pt2	
				if inter_proj != undefined do 	(
-- 					debug "---> intersection TROUVEE projection, k" var:k
					local projec_result = str_result_intersection		est_projection:true	pos:inter_proj		knot_1:1 knot_2:2	distance:(length (inter_proj- _seg_pt1 ))
					append result projec_result
				)
			)
			
			--- intersections avec segment ---
			for k = 2 to numknots _shape do (
				local pt1 = getKnotPoint _shape _id_spline (k- 1)
				local pt2 = getKnotPoint _shape _id_spline k
-- 				debug "---------------------"
-- 				debug "k" var:k
				
				local pt_intersec = segments_intersection	_seg_pt1 	_seg_pt2		pt1 	pt2
				
-- 				debug "pt_intersec" var:pt_intersec
				if pt_intersec != undefined do (					
-- 					debug "---> intersection TROUVEE, k" var:k
					local intersec_result = str_result_intersection	pos:pt_intersec		knot_1:(k- 1)	 	knot_2:k	distance:(length (pt_intersec- _seg_pt1 ))
					append result 		intersec_result
				)
			)
			
-- 				debug "---------------------"
			--- tester la projection du dernier segment ---
			if not isClosed		_shape	_id_spline	then (
-- 				debug "		projection du dernier segment" 
				local pt1 = getKnotPoint _shape _id_spline ( ( numknots _shape ) - 1 )
				local pt2 = getKnotPoint _shape _id_spline ( numknots _shape )
				local inter_proj = projection_seg_sur_seg 	 pt1		pt2 			_seg_pt1	_seg_pt2	
				if inter_proj != undefined do 	(
-- 					debug "---> intersection TROUVEE projection, k" var:k
					local projec_result = str_result_intersection		est_projection:true	pos:inter_proj		knot_1:( numknots _shape - 1 )	 	knot_2:( numknots _shape )		distance:(length (inter_proj- _seg_pt1 ))
					append result projec_result
				)
			) else (
-- 				debug "		interseciotn  du dernier point au premier" 
				local pt1 = getKnotPoint _shape _id_spline ( numknots _shape )
				local pt2 = getKnotPoint _shape _id_spline 1
				local pt_intersec = segments_intersection	_seg_pt1 	_seg_pt2		pt1 	pt2
				if pt_intersec != undefined do (			
-- 					debug "---> intersection TROUVEE, k"		 var:k
					local intersec_result = str_result_intersection	pos:pt_intersec		knot_1:( numknots _shape )	 	knot_2:1		distance:(length (pt_intersec- _seg_pt1 ))
					append result 		intersec_result
				)
			)
			
			
			---- on classe les resultat par distance ---------
			fn compareFN 		v1 	v2 	= (				
				local d = v1.distance	-	v2.distance
				case of	(
					(d < 0.): -1
					(d > 0.): 1
					default: 0
				)
			)			
			qsort 	result 	compareFN
			
			-- retour ------------
			if result.count>0	then 	result[1] 
									else 		undefined
			
		)



) -- fon struct ------------------




struct	str_terrain	(
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	private
		m_debug = true,
		m_dbgPrefix ="urba | str_terrain",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
		
		
	----------- MEMBRES -------------------------------------------------------------------------------------------------------------------------
	private
		---- Shapes ---------------------------------
		shp_cadre,
		shps_decoupe = #(),
		
		---- Outils pour les shapes	---------------------------------
		outils	= str_shape_outils (),
		
		---- Shapes pour manipulation 	---------------------------------
		shp_courant,
		shps_total		=	#(),
		
		--- Shapes resultant decoupe -------------
		shps_result_decoupe =#	(),
		
		
	----------- INTERFACE -------------------------------------------------------------------------------------------------------------------------
	public
		fn decouperBAK		_shp_cible		_shp_decoupe			_id_spline	=(
			
			------- DéCLARATIONS	-------------------------------------------------------------------------------------------
			--- la nouvelle spline ----------
			local index_morceau 	= 1	
			local nvelleSpline 		= line	name:("decoupage " + index_morceau as string) transform:_shp_cible.transform
			
			--- les shapes -------------
			local shape_courant 	= 	_shp_cible
			local shape_test 		= 	_shp_decoupe
			
			--- id du point cible sur le shape courant -----
			local id_knot_cible 		= 	2
			
			--- sens du parcours le long du shape courant -----
			local sens 					= 	1
			
			--- position du point courant -----
			local pt_courant 			= getKnotPoint shape_courant 	_id_spline	1
			
			--- id du point cible sur le shape courant -----
			local shape_Origine 		= 	_shp_cible
			local pos_knot_Origine 	= 	pt_courant
			local id_knot_Origine 	= 	1
			
			
			
			------- PREMIER POINT	-------------------------------------------------------------------------------------------
			addNewSpline  nvelleSpline
			addknot 		nvelleSpline 1 #corner #line	pt_courant
			
			------- LA BOUCLE	-------------------------------------------------------------------------------------------
			local boucle_finie 		= 	false			
			local sortieDeSecours 	= 0
			while not boucle_finie do (	--------------------------------------------------------------------
				
				---- DEBUG ------------
				sortieDeSecours += 1
				
				format "\n\n-------------------------------------------------------------------------------------------------\n" 
				debug "Point numero" 	var:(numknots nvelleSpline +1)
				debug "shape_courant" var:shape_courant.name
				debug "id_knot_cible" 	var:id_knot_cible
				debug "sens" 				var:sens
				---- DEBUG ------------
				
				
				
				
				
				------- Position cible -----------------------------------------------
				local pt_cible 	
				--- sinon c'est juste le point suivant du shape----------------------<
				pt_cible 			= getKnotPoint 	shape_courant 	_id_spline		 id_knot_cible
				
				---- on gere les intersections -------------------------
				local intersection 	= seg_shape_intersection		pt_courant		pt_cible		shape_test  	_id_spline
				---- ona une INTERSECTION -------------
				if intersection != undefined then (
					debug "INTERSECTION"
					
					debug "intersection" 	var:intersection
					
					sens 				= intersection.sens
					id_knot_cible	= intersection.knot_cible
					pt_cible 			= intersection.pos
					
					local shpTmp 		= 	shape_courant
					shape_courant 	= 	intersection.shape
					shape_test 		= 	shpTmp
					
				/* 
					--- Projection ----------
					if intersection.est_projection then (							
						debug "	projection"	
						
						---- projection extremités  du shape decoupe ---------------
						if intersection.knot_1 == 1 then (
							debug "		PREMIER point"
							id_knot_cible 	= 1
							sens 				= 1
						) else (
							debug "		DERNIER point"
							id_knot_cible	=	numKnots shape_courant 	_id_spline
							sens 				= -1
						)
						
					--- Intersection ----------
					) else (
						
						debug "	intersection"
						
						---- intersection avec shape decoupe ---------------
						local quat_test = angle_from_points 	 intersection.pos		pt_courant		 ( getKnotPoint shape_test 	_id_spline  	intersection.knot_1 )							
						
						if quat_test.z < 0 then (
							
							debug	"		sens correct"
							
							if 	intersection.knot_1 < 	intersection.knot_2 then (
								
								debug	"			--> sens intersection inverse"
								sens 				= -1								
								id_knot_cible	=	intersection.knot_1	
								
							) else (
								
								debug	"			--> sens intersection Normal"
								sens 				= 1
								id_knot_cible	=	intersection.knot_2
								
							)
							
						) else (
							debug	"		sens inverse"
							
							if 	intersection.knot_1 < 	intersection.knot_2 then (
								debug	"			--> sens intersection Normal"
								sens 			= 1
								
								id_knot_cible		=	intersection.knot_2	
								
							) else (
								
								debug	"			--> sens intersection inverse"
								if intersection.knot_2 == 1 then
									sens 			= 1
								else
									sens 			= -1	
							
								id_knot_cible		=	intersection.knot_2		
							)
												
						)
						
					)
			
					--- on actualise la pos du point courant -------------
					pt_cible 				= intersection.pos
					
					--- on change de shape courant -----
					local shpTmp 		= 	shape_courant
					shape_courant 	= 	shape_test
					shape_test 		= 	shpTmp
				*/
				---- pas d'INTERSECTION -------------
				) else (	
			
					debug "CONTINUE même shape"
					
					--- iteration du knot cible ------------
					id_knot_cible 	= 	boucler  	shape_courant   	_id_spline  ( id_knot_cible + sens )
					
					
				) ----------------------
				
				
				--- si on a fait la boucle, ON SORT -----------------------------------------------------
				if shape_courant == shape_Origine and pt_cible == pos_knot_Origine  then (
					
					format "\n"
					debug "FIN"
					format "\n"
					
					boucle_finie = true
					
					--- on ferme la spline ---
					close  nvelleSpline _id_spline
					
				)	else (
					
					------- sinon CREATION du  POINT	-------------------------------------------------------------
					debug "###	creation du  POINT	###"
					addknot 		nvelleSpline 1 #corner #line	pt_cible
					pt_courant 	= pt_cible
					
					
					--- si on est sur un SHAPE OUVERT ------------------
					if 	not isclosed shape_courant 	_id_spline do (
						
						--- on regarde si on vient du PREMIER KNOT ( c'est a dire qu'on cible le dernier .... ) ----------------------
						if id_knot_cible == numKnots shape_courant 	_id_spline  and sens == -1 and pt_courant == getKnotPoint shape_courant 	_id_spline  1 	then (
							
							debug "Projection PREMIER Knot"					
							
							--- on test la projection du dernier knot ----------------
							local pt1 = getKnotPoint shape_courant 	_id_spline 2
							local pt2 = getKnotPoint shape_courant 	_id_spline 1
							local inter_proj = projection_vec_sur_shape 	 pt1		pt2 			shape_test  	_id_spline
							
							--- on a une Projection ---------------------
							if inter_proj != undefined  do 	(	
								
								debug "On a une projection" 	var:inter_proj
								
								--- CREATION du  POINT projeté -----
								debug "###	creation du  POINT projeté	###"
								pt_cible 			= inter_proj.pos								
								addknot 	nvelleSpline 1 #corner #line	pt_cible
								pt_courant 	= pt_cible
								
								--- on change de shape courant -----
								local shpTmp 		= 	shape_courant
								shape_courant 	= 	shape_test
								shape_test 		= 	shpTmp
								
								--- check le nouveau sens ----------------
								if 	inter_proj.knot_1 < 	inter_proj.knot_2 then (
									
									debug	"--> sens Normal"
									sens 				= 1									
									id_knot_cible	=	inter_proj.knot_1	
									
								) else (
								
									debug	"--> sens inverse"
									sens 				= -1
									id_knot_cible	=	inter_proj.knot_2	
								)
								
							) --- fin on a une projection
							
						) ----- fin Dernier knot  ------------------------
						
						--- on regarde si on vient du DERNIER KNOT ( c'est a dire qu'on cible le premier .... ) ----------------------
						else if id_knot_cible == 1 and sens == 1  and pt_courant == getKnotPoint shape_courant 	_id_spline  (numKnots shape_courant 	_id_spline) do (
							
							debug "Projection DENIER Knot"					
							
							--- on test la projection du dernier knot ----------------
							local pt1 = getKnotPoint shape_courant 	_id_spline ( ( numKnots	shape_courant	_id_spline ) - 1 )
							local pt2 = getKnotPoint shape_courant 	_id_spline ( numKnots	shape_courant	_id_spline )
							local inter_proj = projection_vec_sur_shape 	 pt1		pt2 			shape_test  	_id_spline
							
							--- on a une Projection ---------------------
							if inter_proj != undefined  do 	(	
								
								debug "On a une projection" 	var:inter_proj
								
								--- CREATION du  POINT projeté -----
								debug "###	creation du  POINT projeté	###"
								pt_cible 			= inter_proj.pos								
								addknot 	nvelleSpline 1 #corner #line	pt_cible
								pt_courant 	= pt_cible
								
								--- on change de shape courant -----
								local shpTmp 		= 	shape_courant
								shape_courant 	= 	shape_test
								shape_test 		= 	shpTmp
								
								--- check le nouveau sens ----------------
								if 	inter_proj.knot_1 < 	inter_proj.knot_2 then (
									
									debug	"--> sens Normal"
									sens 				= 1									
									id_knot_cible	=	inter_proj.knot_1	
									
								) else (
								
									debug	"--> sens inverse"
									sens 				= -1
									id_knot_cible	=	inter_proj.knot_2	
								)
							) --- fin on a une projection
							
						) ----- fin Dernier knot  ------------------------
						
					) --- fin Shape ouvert ---------
					
					
				) -- fin creation du point	-------------------------------------------------------------------------------------------
				

				
				
				---- debug , sortir de secours ----------------
				if sortieDeSecours > 50 do boucle_finie = true
				if keyboard.escPressed  do boucle_finie = true
				if numKnots nvelleSpline > 10  do (
					boucle_finie = true
					debug "SORTIE DE SECOURS"
				)
				---- debug , sortir de secours ----------------
				
				
				
				
			)	--	fin boucle ----------------------------------------------------------------------------------------------------------
			
			
			updateShape nvelleSpline
			select nvelleSpline
			redrawviews ()
			
		),
		
		
		fn decouper =(
			
			debug "Découper"
			
			--- les shapes -----
			shp_courant 	= 	shp_cadre
			shps_total 		=  for shp in shps_decoupe collect shp
			append 	shps_total 	shp_courant
			
			--- id du point cible sur le shape courant -----
			local id_knot_cible 		= 	2
			
			--- sens du parcours le long du shape courant -----
			local sens 					= 	1
			
			--- position du point courant -----
			local pt_courant 			= getKnotPoint shp_courant 	1	1
			
			--- id du point cible sur le shape courant -----
			local shape_Origine 		= 	shp_courant
			local pos_knot_Origine 	= 	pt_courant
			local id_knot_Origine 	= 	1
			
			
			
			------- PREMIER POINT	-------------------------------------------------------------------------------------------
			local shp_result 			= line	name:		("decoupage " + ( shps_result_decoupe.count + 1 ) as string) \
														transform:	shp_cadre.transform
			append shps_result_decoupe	shp_result
			addNewSpline  shp_result
			addknot 		shp_result 	1 #corner #line	pt_courant
			
			------- LA BOUCLE	-------------------------------------------------------------------------------------------
			local boucle_finie 		= 	false			
			local sortieDeSecours 	= 0
			local nbrMaxDeBoucles = 20
			while not boucle_finie do (
				
				---- DEBUG ------------
				sortieDeSecours += 1
				
				format "\n\n-------------------------------------------------------------------------------------------------\n" 
				debug "Point numero" 	var:(numknots shp_result )
				debug "shape_courant" var:shp_courant.name
				debug "id_knot_cible" 	var:id_knot_cible
				debug "sens" 				var:sens
				---- DEBUG ------------
				
				--- On cherche le prochain point -----------
				
				------- Position cible -----------------------------------------------
				local pt_cible 			= getKnotPoint 	shape_courant 	_id_spline		 id_knot_cible
				local intersection 	= outils.seg_shape_intersection		pt_courant		pt_cible		shape_test  	_id_spline
				
				
				
				---- debug , sortir de secours ----------------
				local sortir = false
				if sortieDeSecours > nbrMaxDeBoucles do sortir = true
				if keyboard.escPressed  do sortir = true
				if sortir  do (
					boucle_finie = true
					debug "SORTIE DE SECOURS"
				)
				---- debug , sortir de secours ----------------
				
			) --- fin BOUCLE -------------------
			
			
		),
		
		fn set_cadre	_shape	=(
			outils.fermer_splines 	_shape 	
			outils.orienter_splines 	_shape	
			shp_cadre = _shape
		),
		
		fn ajouter_decoupe	_shape =(
			append 	shps_decoupe		_shape
		)
	
)










-----------------------------------------------------------------------------------------------------------------------------------------------------------

shp_cadre 		= $'tracé cadre'
shp_decoupe1	= $'tracé decoupe 1'
shp_decoupe2	= $'tracé decoupe 2'

--- vider la scene -----------
for obj in objects do
	if obj != shp_cadre and obj != shp_decoupe1 and obj != shp_decoupe2 do
		delete obj		

--- vider listener -----------
clearlistener () 

--- Terrain ----------------------------------------
mon_terrain = str_terrain ()
mon_terrain.set_cadre 				$'tracé cadre'
mon_terrain.ajouter_decoupe		$'tracé decoupe 1'
mon_terrain.ajouter_decoupe		$'tracé decoupe 2'
mon_terrain.decouper ()

	
	
	
	
	
	
----------------------------------------------------------------------------------------------------------------------------------------------------------
/* 
shp_cadre 		= $'tracé cadre'
shp_decoupe 	= $'tracé decoupe'
shp1 				= $Line001

for obj in objects do
	if obj != shp_cadre and obj != shp_decoupe and obj != shp1 do
		delete obj		
	

outils_shape.preparer 			shp_cadre
outils_shape.decouper 			shp_cadre	shp_decoupe 		1	
 */

-- shp1_pt1 = getKnotPoint shp1 1 1
-- shp1_pt2 = getKnotPoint shp1 1 2
-- outils_shape.seg_shape_intersection		shp1_pt1		shp1_pt2		shp_decoupe  	1	

-----------------------------------------------------------------------------------------------------------------------------------------------------------
	/* 

shp2 = $Shape003

shp2_pt1 = getKnotPoint shp2 1 1
shp2_pt2 = getKnotPoint shp2 1 2

vec1 = shp1_pt2 - shp1_pt1
vec2 = shp2_pt2 - shp2_pt1

outils_shape.seg_shape_intersection		shp1_pt1		shp1_pt2		shp_decoupe  	1	
-- outils_shape.angle_from_points  shp1_pt1		shp2_pt1	shp1_pt2
-- outils_shape.angle_from_points  shp1_pt1		shp2_pt2	shp1_pt2
 

  */



-----------------------------------------------------------------------------------------------------------------------------------------------------------


