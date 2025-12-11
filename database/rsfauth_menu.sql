DROP PROCEDURE IF EXISTS rsfAuth.rsfauth_menu;
DELIMITER //
CREATE PROCEDURE rsfAuth.rsfauth_menu(
	aIDuser bigint
)
BEGIN
	/* --------------------------------------------------------------------------------------------------------------- */
	/* -- rsfauth_menu 																								-- */
	/* -- description   : mendapatkan data yang akan di proses ke SATUSEHAT											-- */
	/* -- spesification : select from rsfAuth.satusehat_mlocation													-- */
	/* -- sysdateLast 	: 2022-12-01 22:00 																			-- */
	/* -- useridLast  	: ss 																						-- */
	/* -- revisionCount : 1 																						-- */
	/* -- revisionNote  : 								 															-- */
	/* --------------------------------------------------------------------------------------------------------------- */
	DECLARE vresponse_stat INT;
	DECLARE vRowcount bigint;
	DECLARE vDone int;
	DECLARE vAccessToken text;
	DECLARE vSmenulevel int;
	DECLARE vSmenulevel_next int;
	DECLARE vSmenuheading int;
	DECLARE vSmenudata text;
	DECLARE vSmenulevel_before int;

	DECLARE vFullJson longtext;
	DECLARE vUtility longtext;
	DECLARE vAccessModule longtext;
	DECLARE vPermissions longtext;
	DECLARE vPermissions_selevel1 longtext;
	DECLARE vPermissions_selevel2 longtext;
	DECLARE vPermissions_selevel3 longtext;
	DECLARE vPermissions_selevel4 longtext;
	DECLARE vPermissions_selevel5 longtext;
	DECLARE vPermissions_selevel6 longtext;
	DECLARE vParentLevel1 longtext;
	DECLARE vParentLevel2 longtext;
	DECLARE vParentLevel3 longtext;
	DECLARE vParentLevel4 longtext;
	DECLARE vIDuserGrp bigint;
	DECLARE cursorUserMenus cursor for 
		select	   	-- concat(SPACE(5*(smenu.level-1)),smenu.smenu_name) as smenuname,
					users.refresh_token AS accessToken,
					smenu.level as smenulevel,
					smenu.is_heading as smenuheading,
					JSON_OBJECT('title', ifnull(mods.title,smenu.smenu_name),
								'name', smenu.smenu_name,
								'is_heading', smenu.is_heading,
								'is_active', ifnull(mods.is_active,1),
								'class_name', ifnull(mods.class_name,''),
								'bitcontrol1', ifnull(mods.bitcontrol1,''),
								'bitcontrol2', ifnull(mods.bitcontrol2,''),
								'is_icon_class', ifnull(mods.is_icon_class,0),
								'icon', ifnull(mods.icon,'fas fa-hospital-alt'),
								'link', ifnull(mods.link,'')) as smenudata,
					ifnull((	select		level
									from	modules_smenu_dtl
									where	id_smenu 	= smenu.id_smenu and
											kode_smenu  = ( select 		min(squery_dtl.kode_smenu) 
																from 	modules_smenu_dtl squery_dtl
																		left outer join (
																			select 		modules_grp.id_grp as id_grp,
																						modules.id as id_modules,
																						modules.title,
																						modules.is_active,
																						modules.class_name,
																						modules.is_icon_class,
																						modules.icon,
																						modules.link,
																						modules_grp.active_stat as active_stat,
																						modules_grp.bitcontrol1 as bitcontrol1,
																						modules_grp.bitcontrol2 as bitcontrol2
																				from	rsfAuth.modules,
																						rsfAuth.modules_grp 
																				where   modules.id 				= modules_grp.id_modules and
																						modules_grp.id_grp 		= vIDuserGrp
																		) squery_mods
																		on 	squery_mods.id_modules = squery_dtl.id_modules
																where 	squery_dtl.id_smenu 					= smenu.id_smenu and
																		ifnull(squery_mods.active_stat,1)		= 1 and
																		squery_dtl.kode_smenu 					> smenu.kode_smenu)),0) as smenulevel_next
			from	rsfAuth.users_practitioner users,
					rsfAuth.users_grp usergrp,
					modules_smenu_dtl smenu
					left outer join (
						select 		modules_grp.id_grp as id_grp,
									modules.id as id_modules,
									modules.title,
									modules.is_active,
									modules.class_name,
									modules.is_icon_class,
									modules.icon,
									modules.link,
									modules_grp.active_stat as active_stat,
									modules_grp.bitcontrol1 as bitcontrol1,
									modules_grp.bitcontrol2 as bitcontrol2
							from	rsfAuth.modules,
									rsfAuth.modules_grp 
							where   modules.id 				= modules_grp.id_modules and
									modules_grp.id_grp 		= vIDuserGrp
					) mods
					on 	mods.id_modules = smenu.id_modules
			where   usergrp.id_grp 					= users.id_grp and
					smenu.id_smenu 					= usergrp.id_smenu and
					ifnull(mods.active_stat,1)		= 1 and
					users.id 						= aIDuser
			order   by smenu.kode_smenu;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET vDone = 1;

	SET vDone 					= 0;
	SET vRowcount 				= 0;
	SET vSmenulevel_before		= 0;
	SET vPermissions 			= '[]';
	SET vPermissions_selevel1	= '[]';
	SET vPermissions_selevel2 	= '[]';
	SET vPermissions_selevel3 	= '[]';
	SET vPermissions_selevel4 	= '[]';
	SET vPermissions_selevel5 	= '[]';
	SET vPermissions_selevel6 	= '[]';
	SET vParentLevel1			= '[]';
	SET vParentLevel2 			= '[]';
	SET vParentLevel3 			= '[]';
	SET vParentLevel4 			= '[]';
	select id_grp into vIDuserGrp from users_practitioner where id = aIDuser;
	
	OPEN cursorUserMenus;
	getUserMenus: LOOP
		FETCH cursorUserMenus INTO vAccessToken, vSmenulevel, vSmenuheading, vSmenudata, vSmenulevel_next;
		set vSmenudata = JSON_UNQUOTE(vSmenudata);
		IF vDone = 1 THEN 
			LEAVE getUserMenus;
		ELSE
			SET vRowcount = vRowcount + 1;
			IF vSmenulevel_next = vSmenulevel THEN -- SELEVEL
				CASE vSmenulevel
					WHEN 1 THEN 
						IF vPermissions_selevel2 != '[]' then
							SET vSmenudata	= JSON_MERGE_PRESERVE(vSmenudata, JSON_OBJECT('children', vPermissions_selevel2));
							SET vPermissions_selevel2	= '[]';
						end if;
					WHEN 2 THEN 
						IF vPermissions_selevel3 != '[]' then
							SET vSmenudata	= JSON_MERGE_PRESERVE(vSmenudata, JSON_OBJECT('children', vPermissions_selevel3));
							SET vPermissions_selevel3	= '[]';
						end if;
					WHEN 3 THEN 
						IF vPermissions_selevel4 != '[]' then
							SET vSmenudata	= JSON_MERGE_PRESERVE(vSmenudata, JSON_OBJECT('children', vPermissions_selevel4));
							SET vPermissions_selevel4	= '[]';
						end if;
					WHEN 4 THEN 
						IF vPermissions_selevel5 != '[]' then
							SET vSmenudata	= JSON_MERGE_PRESERVE(vSmenudata, JSON_OBJECT('children', vPermissions_selevel5));
							SET vPermissions_selevel5	= '[]';
						end if;
					WHEN 5 THEN 
						IF vPermissions_selevel6 != '[]' then
							SET vSmenudata	= JSON_MERGE_PRESERVE(vSmenudata, JSON_OBJECT('children', vPermissions_selevel6));
							SET vPermissions_selevel6	= '[]';
						end if;
				END CASE;
				CASE vSmenulevel 
					WHEN 1 THEN SET vPermissions_selevel1 	= JSON_MERGE_PRESERVE(vPermissions_selevel1, vSmenudata);
					WHEN 2 THEN SET vPermissions_selevel2 	= JSON_MERGE_PRESERVE(vPermissions_selevel2, vSmenudata);
					WHEN 3 THEN SET vPermissions_selevel3 	= JSON_MERGE_PRESERVE(vPermissions_selevel3, vSmenudata);
					WHEN 4 THEN SET vPermissions_selevel4 	= JSON_MERGE_PRESERVE(vPermissions_selevel4, vSmenudata);
					WHEN 5 THEN SET vPermissions_selevel5 	= JSON_MERGE_PRESERVE(vPermissions_selevel5, vSmenudata);
				END CASE;
				IF vSmenulevel = 1 THEN
					SET vPermissions			= JSON_MERGE(vPermissions, vPermissions_selevel1);
					SET vPermissions_selevel1	= '[]';
				END IF;
			ELSE
				IF vSmenulevel_next > vSmenulevel THEN -- has children
					CASE vSmenulevel 
						WHEN 1 THEN SET vParentLevel1 = vSmenudata;
						WHEN 2 THEN SET vParentLevel2 = vSmenudata;
						WHEN 3 THEN SET vParentLevel3 = vSmenudata;
						WHEN 4 THEN SET vParentLevel4 = vSmenudata;
					END CASE;
				END IF;

				CASE vSmenulevel 
					WHEN 1 THEN SET vPermissions_selevel1 	= JSON_MERGE_PRESERVE(vPermissions_selevel1, vSmenudata);
					WHEN 2 THEN SET vPermissions_selevel2 	= JSON_MERGE_PRESERVE(vPermissions_selevel2, vSmenudata);
					WHEN 3 THEN SET vPermissions_selevel3 	= JSON_MERGE_PRESERVE(vPermissions_selevel3, vSmenudata);
					WHEN 4 THEN SET vPermissions_selevel4 	= JSON_MERGE_PRESERVE(vPermissions_selevel4, vSmenudata);
					WHEN 5 THEN SET vPermissions_selevel5 	= JSON_MERGE_PRESERVE(vPermissions_selevel5, vSmenudata);
				END CASE;

				IF vSmenulevel_next < vSmenulevel THEN -- anak terakhir
					CASE vSmenulevel 
						WHEN 1 THEN 
							SET vPermissions		 	= JSON_MERGE_PRESERVE(vPermissions, vPermissions_selevel1);
							SET vPermissions_selevel1   = '[]';
						WHEN 2 THEN
							-- SET vPermissions_selevel2 	= JSON_MERGE_PRESERVE(vPermissions_selevel2, vSmenudata);
							SET vParentLevel1 			= JSON_MERGE_PRESERVE(vParentLevel1, JSON_OBJECT('children', vPermissions_selevel2));
							SET vPermissions_selevel2	= '[]';
							SET vPermissions		 	= JSON_MERGE_PRESERVE(vPermissions, vParentLevel1);
							SET vParentLevel1           = '[]';
						WHEN 3 THEN
							-- SET vPermissions_selevel3 	= JSON_MERGE_PRESERVE(vPermissions_selevel3, vSmenudata);
							SET vParentLevel2 			= JSON_MERGE_PRESERVE(vParentLevel2, JSON_OBJECT('children', vPermissions_selevel3));
							SET vPermissions_selevel3	= '[]';
							SET vPermissions		 	= JSON_MERGE_PRESERVE(vPermissions, vParentLevel2);
							SET vParentLevel2           = '[]';
						WHEN 4 THEN
							-- SET vPermissions_selevel4 	= JSON_MERGE_PRESERVE(vPermissions_selevel4, vSmenudata);
							SET vParentLevel3 			= JSON_MERGE_PRESERVE(vParentLevel3, JSON_OBJECT('children', vPermissions_selevel4));
							SET vPermissions_selevel4	= '[]';
							SET vPermissions		 	= JSON_MERGE_PRESERVE(vPermissions, vParentLevel3);
							SET vParentLevel3           = '[]';
						WHEN 5 THEN
							-- SET vPermissions_selevel5 	= JSON_MERGE_PRESERVE(vPermissions_selevel5, vSmenudata);
							SET vParentLevel4 			= JSON_MERGE_PRESERVE(vParentLevel4, JSON_OBJECT('children', vPermissions_selevel5));
							SET vPermissions_selevel5	= '[]';
							SET vPermissions		 	= JSON_MERGE_PRESERVE(vPermissions, vParentLevel4);
							SET vParentLevel4           = '[]';
					END CASE;
				END IF;
			END IF;
		END IF;
	END LOOP getUserMenus;
	CLOSE cursorUserMenus;
	SET vFullJson 		= JSON_OBJECT('accessToken', vAccessToken);
	SET vFullJson      	= JSON_MERGE_PRESERVE(vFullJson,JSON_OBJECT('refreshToken', vAccessToken));
	SET vPermissions  	= JSON_OBJECT('permissions', vPermissions);
	SET vUtility        = 	JSON_ARRAY(
							JSON_MERGE_PRESERVE(JSON_OBJECT('id',1),
							JSON_OBJECT('name','search'),
							JSON_OBJECT('description','Pencarian Pasien'),
							JSON_OBJECT('module_entity_id',1)),
							JSON_MERGE_PRESERVE(JSON_OBJECT('id',2),
							JSON_OBJECT('name','pasienadd'),
							JSON_OBJECT('description','Tambah Pasien'),
							JSON_OBJECT('module_entity_id',2)),
							JSON_MERGE_PRESERVE(JSON_OBJECT('id',3),
							JSON_OBJECT('name','utdpendaftaran'),
							JSON_OBJECT('description','UTD Pendaftaran'),
							JSON_OBJECT('module_entity_id',3)),
							JSON_MERGE_PRESERVE(JSON_OBJECT('id',4),
							JSON_OBJECT('name','utdpemeriksaan'),
							JSON_OBJECT('description','UTD Pemeriksaan'),
							JSON_OBJECT('module_entity_id',4)),
							JSON_MERGE_PRESERVE(JSON_OBJECT('id',5),
							JSON_OBJECT('name','utddokter'),
							JSON_OBJECT('description','UTD Dokter'),
							JSON_OBJECT('module_entity_id',5)));
	-- SET vUtility		= JSON_OBJECT('utility',vUtility);
	-- SET vPermissions  	= JSON_MERGE_PRESERVE(vPermissions, vUtility);
	SET vAccessModule 	= JSON_OBJECT('module', vPermissions);
	-- SET vAccessModule 	= JSON_MERGE_PRESERVE(vAccessModule,JSON_OBJECT('iat', '1685093413'));
	-- SET vAccessModule 	= JSON_MERGE_PRESERVE(vAccessModule,JSON_OBJECT('exp', '1685094313'));
	-- SET vFullJson 		= JSON_MERGE_PRESERVE(vFullJson,JSON_OBJECT('accessModule', vAccessModule));
	-- SET vFullJson 		= JSON_OBJECT('accessModule', vAccessModule);
	SET vFullJson 		= vAccessModule;
	SET vFullJson		= REPLACE(vFullJson,'\\','');
	SET vFullJson		= REPLACE(vFullJson,'"[','[');
	SET vFullJson		= REPLACE(vFullJson,']"',']');
	SET vFullJson		= REPLACE(vFullJson,'"{','{');
	SET vFullJson		= REPLACE(vFullJson,'}"','}');
	IF (vRowcount = 0) THEN
		SELECT 		20009 as statcode,
					0 as rowcount,
					concat('GET MENU, gagal mendapatkan struktur menu. ') as statmessage,
					'{}' as data;
	ELSE
		SELECT 		0 as statcode,
					vRowcount as rowcount,
					concat('GET MENU, success. ') as statmessage,
					vFullJson as data;
	END IF;
END //
DELIMITER ;
