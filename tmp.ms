
shp_cadre 		= $Line003
shp_decoupe 	= $Line004

shp1 = $Line006
shp2 = $Line005

redrawviews ()
fn creer_droite 	_pt1	_pt2	= (
	local a = (_pt1.y - _pt2.y ) / (_pt1.x - _pt2.x)
	local b = _pt1.y - a * _pt1.x
	struct droite	(	a,b	)
	droite a:a	b:b
)
fn droites_intersection		_droite1		_droite2 =(
	if _droite1.a  != _droite2.a then (
		x 	= (_droite2.b - _droite1.b) / (_droite1.a - _droite2.a)
		y 	= 	_droite1.a * x + _droite1.b
		[x,y]
	) else false
)
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
		
		if angle1 > angle_seuil and  angle2 > angle_seuil  then
			result = pt_intersec
	) 
)
clearlistener ()
delete helpers
for i = 1 to numknots shp_cadre do (
	
	local pt1_1 = getKnotPoint shp_cadre 1 i
	local j = if i == numknots shp_cadre then 1 else i + 1
	local pt1_2 = getKnotPoint shp_cadre 1 j
	
	for k = 2 to numknots shp_decoupe do (
	
		local pt2_1 = getKnotPoint shp_decoupe 1 (k- 1)
		local pt2_2 = getKnotPoint shp_decoupe 1 k
		
		local pt_intersec = segments_intersection	pt1_1 	pt1_2		pt2_1 	pt2_2
		if pt_intersec != undefined do (
			format "i : %, j : %, k : %\n" i j k
			local pt = point pos:pt_intersec	size:100
			format "pt : %\n" pt.name
		)
	)
)
	



/* 
pt_intersec = segments_intersection	( getKnotPoint shp1 1 1 ) ( getKnotPoint shp1 1 2 )		( getKnotPoint shp2 1 1 ) ( getKnotPoint shp2 1 2 )
if pt_intersec != undefined do 
	point pos:pt_intersec	size:100
	 */
/* 
droite1	=	get_paramsDroite ( getKnotPoint shp1 1 1 ) ( getKnotPoint shp1 1 2 )
droite2	=	get_paramsDroite ( getKnotPoint shp2 1 1 ) ( getKnotPoint shp2 1 2 )
pt_intersec = droites_intersection	droite1	droite2
point pos:[pt_intersec.x, pt_intersec.y,0]


 */
-- y = ax + b

/* 

fn get_intersection_segment	_segPt1		_segPt2			=(
	
	local k	= -( a * _segPt1.x 		+	b * _segPt1.y 	+	c * _segPt1.z 	+ d ) 	/	( a * ( _segPt2.x -  _segPt1.x ) + b * ( _segPt2.y -  _segPt1.y )  + c * ( _segPt2.z -  _segPt1.z )  )

	local ptResult 	= [0,0,0]
	ptResult.x 			=  _segPt1.x + k * ( _segPt2.x 	-  _segPt1.x )
	ptResult.y 			=  _segPt1.y + k * ( _segPt2.y 	-  _segPt1.y )
	ptResult.z 			=  _segPt1.z + k * ( _segPt2.z 	-  _segPt1.z )
	
	ptResult
	
)
fn coupe_segment	_segPt1		_segPt2			=(
	
	local pointIntersect = get_intersection_segment 	_segPt1		_segPt2 		
	-- debug-------
-- 			point pos:pointIntersect isSelected:true
	
	local vecSeg 	= _segPt2 - _segPt1
	local vecInter = pointIntersect - _segPt1
	
	if dot vecSeg vecInter >0 and length vecSeg > length vecInter then
		true
	else
		false
	
)

 */



/* 
geo = str_geometrie ()
-- pts = #([-522.447,109.032,0], [-95.4033,672.366,0], [767.77,-190.807,0], [-149.919,-590.592,0])


-- select $Line002 


pts = #()
for i = 1 to numKnots $Line002 do
	append pts ( getKnotPoint $Line002 1 i )

select $Plane003





geo.dalle	pts		50		nd_cible:$Plane003

 */





