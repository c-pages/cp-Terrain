



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
		
		
	----- boucler id knots	 -------------
		fn boucler 	_shape	_id_spline	_id_a_boucler		=(
			if _id_a_boucler >	numKnots	_shape	_id_spline		do _id_a_boucler = mod _id_a_boucler (numKnots	_shape	_id_spline)
			if _id_a_boucler < 1 do _id_a_boucler += numKnots	_shape	_id_spline
			_id_a_boucler as integer
			
		),
		
		
		
	------------ Orientation, fermeture des splines	-------------------------------------------------------------------------------------------------------------------------
	public
		
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
		fn orienter_splines 	_shape	=(
			for id_spline = 1 to numsplines _shape do
				if not est_sensPositif 	_shape 	id_spline do 
					reverse shp_cadre 	id_spline
			updateShape shp_cadre
		),
		fn femer_splines 		_shape 	=(
			for id_spline = 1 to numsplines _shape do
				if not isClosed _shape id_spline do (
					close _shape id_spline 
				)
		),
		fn chercher_pt_aDroite		_id_pt  	vec_pt		 =(
			
			local seuil = 1
			
			local vertexSurLigne = #()
			local mtrx_AP 		= m_this.axeP_mtrx
			
-- 			local id_pt_preced 	= boucler 	m_this.trace_courant	(_id_pt - 1)
			local pt 				= m_this.trace_courant[ _id_pt ] 			* 	inverse  	mtrx_AP	
-- 			local pt_preced 		= m_this.trace_courant[ id_pt_preced ] * 	inverse  	mtrx_AP	
			
-- 			local vec_pt 			= pt - pt_preced
			local norm_pt 		= normalize vec_pt
			
			local mtrx_rotateZ90	=	rotateY	(matrix3 1)	90
			local norm_test 			= norm_pt * mtrx_rotateZ90
			
			local pt_virtuel 			= pt + norm_test
			
			local a,b
			local verticale 		= false
			if (( pt.z *1000) as integer /1000  == ( pt_virtuel.z *1000) as integer /1000) then (
				-- horizontale --
				a = 0
				b = pt.z 
			) else if (( pt.x *1000) as integer /1000  == ( pt_virtuel.x *1000) as integer /1000) then (
				-- verticale --
				a 	= 1
				b 	= pt.z - pt.x
				verticale = true
			) else (
				a 	= (pt.z - pt_virtuel.z ) / (pt.x - pt_virtuel.x)
				b 	= pt.z - a*pt.x
			)		
			
			
			if not verticale then (
				for i=1 to m_this.trace_courant.count do (
					local pt_test = m_this.trace_courant[i] * 	inverse  	mtrx_AP	
					-- y = a*x + b
					if  abs ( pt_test.z - ( pt_test.x * a + b ) ) < seuil do (
						
						local dot_test_dir = dot (normalize (pt_test - pt ))  norm_test
-- 						format "dot_test_dir: %\n" dot_test_dir
-- 						format "norm_pt: %\n" (normalize vec_pt )
						if pt_test != pt and dot_test_dir > 0 do 
							append vertexSurLigne i
						
					)
				)
			) else (
				for i=1 to m_this.trace_courant.count do (
					local pt_test = m_this.trace_courant[i] * 	inverse  	mtrx_AP	
					-- y = a*x + b
					if  abs ( pt_test.x - pt.x ) < seuil  do (
						
						local dot_test_dir = dot (normalize (pt_test - pt ))  norm_test
-- 						format "dot_test_dir: %\n" dot_test_dir
-- 						format "vec_pt: %\n" (normalize vec_pt )
						if pt_test != pt and dot_test_dir > 0 do 
							append vertexSurLigne i
						
					)
				)
			)
			
-- 			format "->	vertexSurLigne: %\n" vertexSurLigne
			vertexSurLigne
			local result 
			local dist_min = 0
			for id_pt_test in vertexSurLigne do (
				local pt_test = m_this.trace_courant[ id_pt_test ] 			* 	inverse  	mtrx_AP	
				local dist_test = distance pt pt_test
				if  dist_test < dist_min or dist_min == 0 do (
					result = id_pt_test
					dist_min = dist_test
				)
			)
			
-- 			format "->	result: %\n" result
			result
			
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
-- 	private
	public
		
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
			
			
			result
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
			
		),


	------------ Decoupage	-------------------------------------------------------------------------------------------------------------------------
	public
		fn decouper		_shp_cible		_shp_decoupe			_id_spline	=(
			
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
				
				
				
				local pt_cible 			= getKnotPoint 	shape_courant 	_id_spline		 id_knot_cible
				
				---- on gere les intersections -------------------------
				local intersection 	= seg_shape_intersection		pt_courant		pt_cible		shape_test  	_id_spline
				
				---- INTERSECTION -------------
				if intersection != undefined then (
					debug "INTERSECTION"
					
					debug "intersection" 	var:intersection
					
					
					--- le nouveau sens et le premier point ---
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
				
				---- pas d'INTERSECTION -------------
				) else (	
			
					debug "CONTINUE même shape"
					
					--- iteration du knot cible ------------
					id_knot_cible 	= 	boucler  	shape_courant   	_id_spline  ( id_knot_cible + sens )
					
					
				) ----------------------
				
				
				debug "#	id_knot_cible"		var:id_knot_cible
				debug "#	id_knot_Origine"	var:id_knot_Origine
				
				debug "#	shape_courant"	var:shape_courant.name
				debug "#	shape_Origine"		var:shape_Origine.name
				
				debug "#	pt_cible"					var:pt_cible
				debug "#	pos_knot_Origine"	var:pos_knot_Origine
				
				
				--- si on a fait la boucle, ON SORT -----------
				if shape_courant == shape_Origine and pt_cible == pos_knot_Origine  then (
					
					format "\n"
					debug "FIN"
					format "\n"
					
					boucle_finie = true
					
					--- on ferme la spline ---
					close  nvelleSpline _id_spline
					
				)
				
				------- creation du  POINT	-------------------------------------------------------------------------------------------
				debug "###	creation du  POINT	###"
				addknot 		nvelleSpline 1 #corner #line	pt_cible
				pt_courant 	= pt_cible
				
				
				
				
				
				
				
				
				
				
				/* 
				--- sortie boucle ---------
			 	if id_knot_courant == 1 and sens == -1  then (						
					debug "BOUCLER id id_knot_suivant inf. à 1"
					
					if not isclosed		shape_courant 	_id_spline	do (		
						
						--- on test la projection du premier knot ----------------
						local pt1 = getKnotPoint shape_courant 	_id_spline 2
						local pt2 = getKnotPoint shape_courant 	_id_spline 1
						local inter_proj = projection_vec_sur_shape 	 pt1		pt2 			shape_test  	_id_spline
						
						
						if inter_proj.count>0  do 	(
				debug "projection" 	var:inter_proj[1]
							pt_courant = inter_proj[1].pos
							b_pointPose = true
							--- on change de shape courant -----
							local shpTmp 		= 	shape_courant
							shape_courant 	= 	shape_test
							shape_test 		= 	shpTmp
						
							if 	inter_proj[1].knot_1 < 	inter_proj[1].knot_2 then (
								
								debug	"--> sens intersection inverse"
								sens 			= -1
								
								id_knot_courant		=	inter_proj[1].knot_2	
							) else (
							
								debug	"--> sens intersection Normal"
								sens 			= 1
								id_knot_courant		=	inter_proj[1].knot_1	
							)
						)
					)
				) 
				if id_knot_courant ==  numKnots	shape_courant	_id_spline	and sens == 1 then (	
					debug "BOUCLER id_knot_suivant sup. à 1"
					
					if not isclosed		shape_courant 	_id_spline	do (							
						--- on test la projection du premier knot ----------------
						local pt1 = getKnotPoint shape_courant 	_id_spline ( ( numKnots	shape_courant	_id_spline ) - 1 )
						local pt2 = getKnotPoint shape_courant 	_id_spline ( numKnots	shape_courant	_id_spline )
						local inter_proj = projection_vec_sur_shape 	 pt1		pt2 			shape_test  	_id_spline
						if inter_proj.count>0  do 	(	
				debug "projection" 	var:inter_proj[1]
							pt_courant = inter_proj[1].pos
							
							b_pointPose = true
							--- on change de shape courant -----
							local shpTmp 		= 	shape_courant
							shape_courant 	= 	shape_test
							shape_test 		= 	shpTmp
							
							if 	inter_proj[1].knot_1 < 	inter_proj[1].knot_2 then (
								
								debug	"--> sens intersection Normal"
								sens 			= 1
								
								id_knot_courant		=	inter_proj[1].knot_1	
							) else (
							
								debug	"--> sens intersection inverse"
								sens 			= -1
								id_knot_courant		=	inter_proj[1].knot_2	
							)
						)
						
					)
					
				)  


				if not b_pointPose do (
				
					
					
					--- on gere la suite -------------------------
					local intersections 	= seg_shape_intersection		pt_courant		pt_suivant		shape_test  	_id_spline	
					
					--- cas 1 : intersection avec decoupe --------------------
					if intersections.count > 0 then (
						
						
						local intersec = intersections[1]
-- 						debug "intersec" var:intersec
						
						
						--- le nouveau sens et le premier point ---
						if intersec.est_projection then (
							
	 					debug "PROJECTION"
-- 							debug ">>> projection"
							
							debug "projection" 	var:intersec
							
							--- on change de shape courant -----
							local shpTmp 		= 	shape_courant
							shape_courant 	= 	shape_test
							shape_test 		= 	shpTmp
							
							---- projection extremités  du shape decoupe ---------------
							if intersec.knot_1 == 1 then (
	 					debug "proj. du PREMIER point"
								id_knot_courant 	= intersec.knot_1	
								sens 					= 1
							) else (
	 					debug "proj. du DERNIER point"
								id_knot_courant	=	1
								sens 					= -1
							)
	-- 						addknot nvelleSpline 1 #corner #line	pt_suivant
							
						) else (
							
							debug "INTERSECTION"
-- 							debug ">>> intersection"
							
							---- intersection avec shape decoupe ---------------
							local quat_test = angle_from_points  intersec.pos		pt_courant		 ( getKnotPoint shape_test 	_id_spline  	intersec.knot_1 )
-- 							debug "quat_test" 	var:quat_test
-- 							debug "angle quat_test" 	var:quat_test.angle
-- 							
-- 							debug "quat_test.z" 	var:quat_test.z
							
							
							
							if quat_test.z < 0 then (
								
								debug	"sens inverse"
								
								if 	intersec.knot_1 < 	intersec.knot_2 then (
									
									debug	"--> sens intersection inverse"
									sens 			= -1
									
									id_knot_courant		=	intersec.knot_2	
								) else (
								
									debug	"--> sens intersection Normal"
									sens 			= 1
									id_knot_courant		=	intersec.knot_1	
								)
									
								
							) else (
								debug	"sens correct"
								
								if 	intersec.knot_1 < 	intersec.knot_2 then (
									debug	"--> sens intersection Normal"
									sens 			= 1
									
									id_knot_courant		=	intersec.knot_1	
									
								) else (
									
									debug	"--> sens intersection inverse"
									if intersec.knot_2 == 1 then
										sens 			= 1
									else
										sens 			= -1	
								
									d_knot_courant		=	intersec.knot_1		
								)
													
							)
						
-- 							pt_courant 			= intersec.pos	
							
							
							--- on change de shape courant -----
							local shpTmp 		= 	shape_courant
							shape_courant 	= 	shape_test
							shape_test 		= 	shpTmp
							
	-- 						boucle_finie = true
						)
						
						
						--- on ajoute le point d'intersection ---------
						pt_courant = intersec.pos
	-- 					addknot nvelleSpline 1 #corner #line	intersec.pos
						
						
					--- cas 2 : on continue sur la meme spline --------------------
					) else (
						
						debug "CONTINUE sur la meme spline"
						id_knot_courant += sens
						
						if id_knot_courant < 1 do (						
							debug "BOUCLER id courant inf. à 1"
							id_knot_courant = numKnots	shape_courant	_id_spline	
						) 
						
						if id_knot_courant > numKnots	shape_courant	_id_spline	do (	
							debug "BOUCLER id courant sup. à 1"
							id_knot_courant = 1
						)  
						
						pt_courant 	= getKnotPoint shape_courant 	_id_spline	 	id_knot_courant
						
					) -- fin cas 2 --------
				
				
 				)
-- 				break ()
					
				
				local nbrePoint_nvlleSpline = numKnots	nvelleSpline	_id_spline
				if id_knot_courant == id_knot_Origine and shape_courant == shape_Origine and pt_courant == pos_knot_Origine and nbrePoint_nvlleSpline > 1 then (
					format "\n"
					debug "FIN"
					boucle_finie = true
					close  nvelleSpline _id_spline
				) 
				*/
				
				
				
				
				
				---- debug , sortir de secours ----
				if sortieDeSecours > 50 do boucle_finie = true
				if keyboard.escPressed  do boucle_finie = true
				if numKnots nvelleSpline > 10  do (
					boucle_finie = true
					debug "SORTIE DE SECOURS"
				)
				
			)	--	fin boucle ----------------------------------------------------------------------------------------------------------
			
			
			updateShape nvelleSpline
			select nvelleSpline
			
			
			redrawviews ()
			
		),
		
		
		
		/* 
		fn decouperBACK		_shp_cible		_shp_decoupe			_id_spline	=(
			
			
			
			--- la nouvelle spline ----------
			local index_morceau 	= 1	
			local nvelleSpline 		= line	name:("decoupage " + index_morceau as string) transform:_shp_cible.transform
			addNewSpline  nvelleSpline
			
			--- les shapes -------------
			local shape_courant 	= 	_shp_cible
			local shape_test 		= 	_shp_decoupe
			local shape_Origine 		= 	_shp_cible
			local id_knot_courant 	= 	1
			local id_knot_Origine 	= 	id_knot_courant
			local pt_courant 			= getKnotPoint shape_courant 	_id_spline	 	id_knot_courant
			local pos_knot_Origine 	= 	pt_courant
			local sens 					= 	1
			
			
			
			--- la boucle	-------------------------------------------------------------------------------------------
			local boucle_finie 		= 	false			
			local sortieDeSecours = 0
			while not boucle_finie do (	--------------------------------------------------------------------
				
				sortieDeSecours += 1
				
				--- On creer le point courant-------------------
				addknot nvelleSpline 1 #corner #line	pt_courant
				
				local id_knot_suivant 	= boucler 	shape_courant	_id_spline		( id_knot_courant + sens  )
				
				local pt_suivant 			= getKnotPoint shape_courant 	_id_spline		 id_knot_suivant
				
				format "\n\n-------------------------------------------------------------------------------------------------\n" 
				debug "Point numero" 	var:(numknots nvelleSpline)
				debug "shape_courant" 	var:shape_courant.name
				debug "id_knot_courant" 	var:id_knot_courant
				debug "id_knot_suivant" 	var:id_knot_suivant
				debug "sens" 	var:sens
				
				
				
				
				
				
-- 				local id_knot_suivant 	= id_knot_courant + sens 
				
				local b_pointPose = false
				
				--- sortie boucle ---------
			 	if id_knot_courant == 1 and sens == -1  then (						
					debug "BOUCLER id id_knot_suivant inf. à 1"
					
					if not isclosed		shape_courant 	_id_spline	do (		
						
						--- on test la projection du premier knot ----------------
						local pt1 = getKnotPoint shape_courant 	_id_spline 2
						local pt2 = getKnotPoint shape_courant 	_id_spline 1
						local inter_proj = projection_vec_sur_shape 	 pt1		pt2 			shape_test  	_id_spline
						
						
						if inter_proj.count>0  do 	(
				debug "projection" 	var:inter_proj[1]
							pt_courant = inter_proj[1].pos
							b_pointPose = true
							--- on change de shape courant -----
							local shpTmp 		= 	shape_courant
							shape_courant 	= 	shape_test
							shape_test 		= 	shpTmp
						
							if 	inter_proj[1].knot_1 < 	inter_proj[1].knot_2 then (
								
								debug	"--> sens intersection inverse"
								sens 			= -1
								
								id_knot_courant		=	inter_proj[1].knot_2	
							) else (
							
								debug	"--> sens intersection Normal"
								sens 			= 1
								id_knot_courant		=	inter_proj[1].knot_1	
							)
						)
					)
				) 
				if id_knot_courant ==  numKnots	shape_courant	_id_spline	and sens == 1 then (	
					debug "BOUCLER id_knot_suivant sup. à 1"
					
					if not isclosed		shape_courant 	_id_spline	do (							
						--- on test la projection du premier knot ----------------
						local pt1 = getKnotPoint shape_courant 	_id_spline ( ( numKnots	shape_courant	_id_spline ) - 1 )
						local pt2 = getKnotPoint shape_courant 	_id_spline ( numKnots	shape_courant	_id_spline )
						local inter_proj = projection_vec_sur_shape 	 pt1		pt2 			shape_test  	_id_spline
						if inter_proj.count>0  do 	(	
				debug "projection" 	var:inter_proj[1]
							pt_courant = inter_proj[1].pos
							
							b_pointPose = true
							--- on change de shape courant -----
							local shpTmp 		= 	shape_courant
							shape_courant 	= 	shape_test
							shape_test 		= 	shpTmp
							
							if 	inter_proj[1].knot_1 < 	inter_proj[1].knot_2 then (
								
								debug	"--> sens intersection Normal"
								sens 			= 1
								
								id_knot_courant		=	inter_proj[1].knot_1	
							) else (
							
								debug	"--> sens intersection inverse"
								sens 			= -1
								id_knot_courant		=	inter_proj[1].knot_2	
							)
						)
						
					)
					
				)  


				if not b_pointPose do (
				
					
					
					--- on gere la suite -------------------------
					local intersections 	= seg_shape_intersection		pt_courant		pt_suivant		shape_test  	_id_spline	
					
					--- cas 1 : intersection avec decoupe --------------------
					if intersections.count > 0 then (
						
						
						local intersec = intersections[1]
-- 						debug "intersec" var:intersec
						
						
						--- le nouveau sens et le premier point ---
						if intersec.est_projection then (
							
	 					debug "PROJECTION"
-- 							debug ">>> projection"
							
							debug "projection" 	var:intersec
							
							--- on change de shape courant -----
							local shpTmp 		= 	shape_courant
							shape_courant 	= 	shape_test
							shape_test 		= 	shpTmp
							
							---- projection extremités  du shape decoupe ---------------
							if intersec.knot_1 == 1 then (
	 					debug "proj. du PREMIER point"
								id_knot_courant 	= intersec.knot_1	
								sens 					= 1
							) else (
	 					debug "proj. du DERNIER point"
								id_knot_courant	=	1
								sens 					= -1
							)
	-- 						addknot nvelleSpline 1 #corner #line	pt_suivant
							
						) else (
							
							debug "INTERSECTION"
-- 							debug ">>> intersection"
							
							---- intersection avec shape decoupe ---------------
							local quat_test = angle_from_points  intersec.pos		pt_courant		 ( getKnotPoint shape_test 	_id_spline  	intersec.knot_1 )
-- 							debug "quat_test" 	var:quat_test
-- 							debug "angle quat_test" 	var:quat_test.angle
-- 							
-- 							debug "quat_test.z" 	var:quat_test.z
							
							
							
							if quat_test.z < 0  then (
								
								debug	"sens inverse"
								
								if 	intersec.knot_1 < 	intersec.knot_2 then (
									
									debug	"--> sens intersection inverse"
									sens 			= -1
									
									id_knot_courant		=	intersec.knot_2	
								) else (
								
									debug	"--> sens intersection Normal"
									sens 			= 1
									id_knot_courant		=	intersec.knot_1	
								)
									
								
							) else (
								debug	"sens correct"
								
								if 	intersec.knot_1 < 	intersec.knot_2 then (
									debug	"--> sens intersection Normal"
									sens 			= 1
									
									id_knot_courant		=	intersec.knot_1	
									
								) else (
									
									debug	"--> sens intersection inverse"
									if intersec.knot_2 == 1 then
										sens 			= 1
									else
										sens 			= -1	
								
									d_knot_courant		=	intersec.knot_1		
								)
													
							)
						
-- 							pt_courant 			= intersec.pos	
							
							
							--- on change de shape courant -----
							local shpTmp 		= 	shape_courant
							shape_courant 	= 	shape_test
							shape_test 		= 	shpTmp
							
	-- 						boucle_finie = true
						)
						
						
						--- on ajoute le point d'intersection ---------
						pt_courant = intersec.pos
	-- 					addknot nvelleSpline 1 #corner #line	intersec.pos
						
						
					--- cas 2 : on continue sur la meme spline --------------------
					) else (
						
						debug "CONTINUE sur la meme spline"
						id_knot_courant += sens
						
						if id_knot_courant < 1 do (						
							debug "BOUCLER id courant inf. à 1"
							id_knot_courant = numKnots	shape_courant	_id_spline	
						) 
						
						if id_knot_courant > numKnots	shape_courant	_id_spline	do (	
							debug "BOUCLER id courant sup. à 1"
							id_knot_courant = 1
						)  
						
						pt_courant 	= getKnotPoint shape_courant 	_id_spline	 	id_knot_courant
						
					) -- fin cas 2 --------
				
				
 				)
-- 				break ()
					
				
-- 				debug "shape_courant" var:shape_courant.name
				local nbrePoint_nvlleSpline = numKnots	nvelleSpline	_id_spline
				if id_knot_courant == id_knot_Origine and shape_courant == shape_Origine and pt_courant == pos_knot_Origine and nbrePoint_nvlleSpline > 1 then (
					format "\n"
					debug "FIN"
					boucle_finie = true
					close  nvelleSpline _id_spline
				) 
				
				---- debug , sortir de secours ----
				if sortieDeSecours > 50 do boucle_finie = true
				if keyboard.escPressed  do boucle_finie = true
				if numKnots nvelleSpline > 10  do (
					boucle_finie = true
					debug "SORTIE DE SECOURS"
				)
				
			)	--	fin boucle ----------------------------------------------------------------------------------------------------------
			
			
			updateShape nvelleSpline
			select nvelleSpline
			
			
			redrawviews ()
			
		),
		 */
		
	----------- INTERFACE -------------------------------------------------------------------------------------------------------------------------
	public
		fn preparer 	_shape	=(
			femer_splines 		_shape 	
			orienter_splines 	_shape	
			_shape
		)


) -- fon struct ------------------



-----------------------------------------------------------------------------------------------------------------------------------------------------------

clearlistener () 


outils_shape 	= str_shape_outils ()


----------------------------------------------------------------------------------------------------------------------------------------------------------

shp_cadre 		= $'tracé cadre'
shp_decoupe 	= $'tracé decoupe'
shp1 				= $Line001

for obj in objects do
	if obj != shp_cadre and obj != shp_decoupe and obj != shp1 do
		delete obj		
	

outils_shape.preparer 			shp_cadre
outils_shape.decouper 			shp_cadre	shp_decoupe 		1	


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


