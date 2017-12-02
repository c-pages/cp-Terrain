



struct 	str_shape_outils	(
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	private
		m_debug = true,
		m_dbgPrefix ="urba | str_shape_outils",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
		
		
		
	------------ Orientation, fermeture des splines	-------------------------------------------------------------------------------------------------------------------------
	private
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


	------------ Droites, intersections et projections	-------------------------------------------------------------------------------------------------------------------------
	private
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
				[x,y]
			) else false
		),
		fn segments_intersection 	_seg1_pt1	_seg1_pt2			_seg2_pt1	_seg2_pt2	=(
			
			local result
			
			local angle_seuil = .1
			local droite1		=	creer_droite 	_seg1_pt1		_seg1_pt2
			local droite2		=	creer_droite 	_seg2_pt1		_seg2_pt2	
			local	pt_intersec = droites_intersection	droite1	droite2
			
			if pt_intersec !=	false then (
				--- on passe pt_intersec en 3D --------
				pt_intersec = [pt_intersec.x, pt_intersec.y, 0]

				local vec1_test1 	=   _seg1_pt1 - 	pt_intersec
				local vec1_test2 	=   _seg1_pt2 -	pt_intersec 
				local dot1 = dot ( normalize vec1_test2 )	(	normalize vec1_test1)
				local angle1 =  acos dot1
				
		-- 			format "angle1 : %\n" angle1
				local vec2_test1 	=   _seg2_pt1 	- 	pt_intersec
				local vec2_test2 	=   _seg2_pt2 	-	pt_intersec 
				local dot2 = dot ( normalize vec2_test2 )	(	normalize vec2_test1)
				local angle2 =  acos dot2
				
		-- 			format "angle2 : %\n" angle2
				
				if angle1 > angle_seuil and  angle2 > angle_seuil  then (
					result = pt_intersec
					
					pt=		point pos:pt_intersec	size:100 	wirecolor:yellow
				)
			)
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
				
					pt=		point pos:pt_intersec	size:100 	wirecolor:[150,150,250]
					result = pt_intersec
		-- 			format "pt : %\n" pt.name 
				)
			)
			result
			
		),
		fn seg_shape_intersection		_seg_pt1	_seg_pt2	_shape =(
			local result =#()
			
			--- tester la projection du premier segment ---
			local pt1 = getKnotPoint _shape 1 2
			local pt2 = getKnotPoint _shape 1 1
			local inter_proj = projection_seg_sur_seg 	 pt1		pt2 			_seg_pt1	_seg_pt2	
			
			
			--- intersections avec segment ---
			for k = 2 to numknots _shape do (
				local pt1 = getKnotPoint _shape 1 (k- 1)
				local pt2 = getKnotPoint _shape 1 k
				local pt_intersec = segments_intersection	_seg_pt1 	_seg_pt2		pt1 	pt2
				if pt_intersec != undefined do 
					append result pt_intersec
			)
			
			 
			--- tester la projection du dernier segment ---
			local pt1 = getKnotPoint _shape 1 ( ( numknots _shape ) - 1 )
			local pt2 = getKnotPoint _shape 1 ( numknots _shape )
			local inter_proj = projection_seg_sur_seg 	 pt1		pt2 			_seg_pt1	_seg_pt2	
			
			result
		),


	------------ Decoupage	-------------------------------------------------------------------------------------------------------------------------
		fn decoupage		_shp_cadre		_shp_decoupe		=(
			
			--- la nouvelle spline ----------
			local index_morceau 	= 1	
			local nvelleSpline 		= line	name:("decoupage " + index_morceau as string) transform:_shp_cadre.transform
			addNewSpline  nvelleSpline
			addknot nvelleSpline 1 #corner #line	(getKnotPoint _shp_cadre 1 	1)
			
			local boucle_finie = false
			local id_knot_1 = 1
			while not boucle_finie do (
				format "id_knot_1  : %\n" id_knot_1
				local pt1_1 			= getKnotPoint _shp_cadre 1 	id_knot_1
				local id_knot_2 		= if id_knot_1 == numknots _shp_cadre then 1 else id_knot_1 + 1
				local pt1_2 			= getKnotPoint _shp_cadre 1 id_knot_2
				local intersections 	= seg_shape_intersection		pt1_1	pt1_2	_shp_decoupe 
				
				if intersections.count > 0 then (
					addknot nvelleSpline 1 #corner #line	intersections[1]
				) else
					addknot nvelleSpline 1 #corner #line	pt1_2
				
				--- boucle ---------
				if id_knot_1 == numknots _shp_cadre do boucle_finie = true
				id_knot_1 += 1
			)
			
			
			updateShape nvelleSpline
			select nvelleSpline
			
			
			redrawviews ()
			
		),
		
		
		
	----------- INTERFACE -------------------------------------------------------------------------------------------------------------------------
	public
		fn preparer 	_shape	=(
			femer_splines 		_shape 	
			orienter_splines 	_shape	
			_shape
		)


) -- fon struct ------------------

delete helpers

shp_cadre 		= $'tracé cadre'
shp_decoupe 	= $'tracé decoupe'
outils_shape 	= str_shape_outils ()

clearlistener ()

outils_shape.preparer 			shp_cadre



















