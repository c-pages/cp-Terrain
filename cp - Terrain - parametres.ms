/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################
	
	URBA - Terrain
	Générateur de terrain a partir de relief et de splines
	
##########################################################################################################################
	
	Plugin Terrain - les rolllouts du plug --------------------
	
##########################################################################################################################

	NOTES :
	
##########################################################################################################################
	
	todo:
	
##########################################################################################################################
	
	changelog:
	*v0.1 - [30/11/2017] -----------------------------------------------------------------------------
	- Mise en place globale 
	
########################################################################################################################*/



parameters params_global 		rollout:roll_global		(
	/* 
	------- Surface		------------------
	surface_node						type:#node 								-- ui:btn_pick_surface
	surface_points_base				type:#point3Tab 		tabSize:0 		tabSizeVariable:true
	surface_points						type:#point3Tab 		tabSize:0 		tabSizeVariable:true
	
	------- Optimisations		------------------
	surface_aplanir					type:#boolean			default:true		ui:chk_aplanir
	surface_souder					type:#boolean			default:true		ui:chk_souder
	surface_orthonormer				type:#boolean			default:true		ui:chk_ortho
	surface_aligner					type:#boolean			default:true		ui:chk_aligner
	surface_projeter					type:#boolean			default:true		ui:chk_projeter
	
	------- Seuils		------------------
	surface_aplanir_seuil				type:#float				default:20.			ui:spn_aplanir
	surface_souder_seuil			type:#float				default:30.			ui:spn_souder
	surface_orthonormer_seuil		type:#float				default:100.		ui:spn_ortho
	surface_aligner_seuil				type:#float				default:50.			ui:spn_aligner
	 */
)

-------------------------------------------------------------------------------------------------------------------------------------------------
--------------- ROLLOUT  ----------------------------------------------------------------------------------------------------------------------	
-------------------------------------------------------------------------------------------------------------------------------------------------

rollout roll_global 		"Global" 		rolledUp:false	(
	/* 
-- 	local regle_sssurface_courant
	
	fn shape_filt 		obj = superclassof obj == shape
	
	pickbutton 'btn_pick_surface' "Pick shape" pos:[12,14] width:145 height:18 filter:shape_filt autoDisplay:true align:#left
	GroupBox 'grp9' "Surface:" pos:[4,0] width:162 height:38 align:#left

	spinner 'spn_rotation_axeP' "" pos:[87,73] width:54 height:16 range:[-360,360,0] type:#float scale:1 align:#left
	label 'lbl_axeP' "Orientation:" pos:[5,74] width:59 height:15 align:#left
	button 'btn_rotation' "+90°" pos:[138,73] width:30 height:16 align:#left
	
	label 'lbl_nbre' "Nbre. d'étages:" pos:[5,44] width:79 height:15 align:#left
	spinner 'spn_nbres' "" pos:[87,43] width:80 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	spinner 'spn_hauteur' "" pos:[87,58] width:80 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	label 'lbl_hauteur' "Htr. des étages:" pos:[5,59] width:76 height:15 align:#left
	 */
	
	fn actualiser =()
-- 	button 'btn_ajouter_division' "+" pos:[134,76] width:16 height:16 enabled:true toolTip:"surface minimum." highlightColor:(color 255 255 0) align:#left
-- 	button 'btn_supprimer_division' "-" pos:[149,76] width:16 height:16 enabled:true toolTip:"surface minimum." highlightColor:(color 255 255 0) align:#left
	
	
-- 	listbox 'lbx_divisions' "" pos:[12,92] width:153 height:5 align:#left

		
	
	
	/* --------------------  CLEANAGE --------------------
	fn actualiser =(
		
-- 		lbx_divisions.items = for sssurface in surface.regles_sssurface collect sssurface.nom
-- 		if lbx_divisions.selection != 0 then
-- 			regle_sssurface_courant	= surface.regles_sssurface[lbx_divisions.selection]
-- 		else regle_sssurface_courant = undefined
		
		spn_hauteur.enabled 			= a_un_surface
		lbl_hauteur.enabled 				= a_un_surface		
		btn_rotation.enabled 			= a_un_surface
		btn_rotation_inv.enabled 		= a_un_surface
		spn_rotation_axeP.enabled 	= a_un_surface
		lbl_axeP.enabled 					= a_un_surface
		
		local enabled =  soussurfaces_use
		chk_soussurfaces.enabled = false
		
		spn_soussurfaces_etages.enabled 	= enabled
		spn_soussurfaces_surf_min.enabled 			= enabled
		lbl_surfMin.enabled 						= enabled
		lbl_surfMax.enabled 						= enabled
		chk_soussurfaces_surf_max.enabled 	= enabled
		chk_soussurfaces_surf_min.enabled 	= enabled
		spn_soussurfaces_surf_max.enabled 	= enabled
-- 		btn_supprimer_division.enabled 		= enabled
		
		if enabled then (
			spn_soussurfaces_etages.indeterminate  		= false
			spn_soussurfaces_surf_min.indeterminate  		= false
			spn_soussurfaces_surf_max.indeterminate  	= false
-- 			spn_soussurfaces_etages.value  			= .nombre_etages
-- 			spn_soussurfaces_surf_min.value  		= regle_sssurface_courant.surface_min
-- 			spn_soussurfaces_surf_max.value  		= regle_sssurface_courant.surface_max
-- 			chk_soussurfaces_surf_max.checked  	= regle_sssurface_courant.surface_min_use
-- 			chk_soussurfaces_surf_min.checked  	= regle_sssurface_courant.surface_max_use
			
		) else (
			spn_soussurfaces_etages.indeterminate  		= true
			spn_soussurfaces_surf_min.indeterminate  		= true
			spn_soussurfaces_surf_max.indeterminate  	= true
			chk_soussurfaces_surf_max.checked  			= false
			chk_soussurfaces_surf_min.checked  			= false
			
		)
		
		
	)
	

	
		
		
		
		
		
	
	on roll_global open do
		actualiser ()
	on spn_rotation_axeP changed arg do
	(
			surface.actualiser ()
			construire.batiment 	()
		)
	on btn_rotation pressed do
	(
			axeP_orientation += 90
			surface.actualiser 			()
			construire.batiment 	()
		)
	on btn_rotation_inv pressed do
	(
			axeP_orientation -= 90
			surface.actualiser ()
			
			construire.batiment ()
		)
	on spn_nbres changed arg do
	(
			construire.batiment ()
	)
	
	on spn_hauteur changed arg do
	(
					construire.batiment ()
					
		)
	on spn_hauteur buttondown do
		flagForeground $ 	true
	on spn_hauteur buttonup do
		flagForeground $ 	false
	on spn_soussurfaces_etages changed val do
	(
-- 			regle_sssurface_courant.nombre_etages = val
			actualiser ()
-- 			surface.structs_toParam 	this
			surface.actualiser 	()
			construire.batiment 	()
		)
	on spn_soussurfaces_surf_min changed val do
	(
-- 			regle_sssurface_courant.surface_min = val
			actualiser ()
-- 			surface.structs_toParam 	this
			surface.actualiser 	()
			construire.batiment 	()
		)
	on spn_soussurfaces_surf_max changed val do
	(
-- 			regle_sssurface_courant.surface_max = val
			actualiser ()
-- 			surface.structs_toParam 	this
			surface.actualiser 	()
			construire.batiment 	()
		)
	on chk_soussurfaces_surf_max changed state do
	(
-- 			regle_sssurface_courant.surface_max_use = state
			actualiser ()
-- 			surface.structs_toParam 	this
			surface.actualiser 	()
			construire.batiment 	()
		
		)
	on chk_soussurfaces_surf_min changed state do
	(
-- 			regle_sssurface_courant.surface_min_use = state
			actualiser ()
-- 			surface.structs_toParam 	this
			surface.actualiser 	()
			construire.batiment 	()
		
		)
	on chk_soussurfaces changed state do
	(
-- 			regle_sssurface_courant.surface_max_use = state
			actualiser ()
-- 			surface.structs_toParam 	this
			surface.actualiser 	()
			construire.batiment 	()
		
		)
		
	 --------------------  CLEANAGE -------------------- */
-- /* 
-- 	on btn_pick_surface picked _shape	 do
-- 		core.assigner_surface	 	$		_shape
-- 	
-- 	on spn_nbres changed arg do
-- 		core.actualiser ()
-- 	
-- 	on spn_hauteur changed arg do
-- 		core.actualiser ()
-- 	 */
	
)
rollout roll_aPropos 		"A propos" 	rolledUp:true	(
	label 'lbl_axeP' "Urba | V0.1  |" pos:[5,2]  align:#left
	HyperLink 'hpl1' "Christophe Pagès" pos:[76,2] address:"http://c-pages.fr" color:(color 200 200 127.5) hovercolor:(color 250 250 150) visitedcolor:(color 200 200 127.5) align:#left
	HyperLink 'hpl2' "GitHub" pos:[127,17] address:"https://github.com/c-pages/cp-Urba" color:(color 200 200 127.5) hovercolor:(color 250 250 150) visitedcolor:(color 200 200 127.5) align:#left
	label 'lbl6' "2017" pos:[5,17] align:#left
)









