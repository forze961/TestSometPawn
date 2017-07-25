#include <amxmodx>
#include <amxmisc>
#include <nvault>
#include <colorchat>
#include <fun>
#include <cstrike>
//#include <sqlx>
//test
#define PLUGIN "order"
#define VERSION "1"
#define AUTHOR "Arctiq"
#define I_ID 7777
// d-s
new players_menu, players[32], num, i,accessmenu, iName[64], callback;
new PlayerXP[33],PlayerLevel[33],needXP[33],g_MsgHud,MaxPlayers,Msg[512],levelUp[33];
new const CLASSES[][] = {
"I_0",		// (пусто)
"I_1",		// ряд
"I_2",		// ефр
"I_3",		// млсерж
"I_4",		// серж
"I_5",		// стсерж
"I_6",		// старш
"I_7",		// прапор
"I_8",		// мллейт
"I_9",		// лейт
"I_10",		// стлейт
"I_11",		// кап
"I_12",		// май
"I_13",		// подпол
"I_14",		// полк
"I_15",		// гнмай
"I_16",		// гнлейт
"I_17",		// гнполк
"I_18",		// гнарм
"I_19"		// вгк
};
new const LEVELS[] = {
0,		// ряд
10,		// ефр
20,		// млсерж
30,		// серж
50,		// стсерж
70,		// старш
100,		// прапор
150,		// мллейт
200,		// лейт
300,		// стлейт
400,		// кап
600,		// май
800,		// подпол
1000,		// полк
1300,		// гнмай
1600,		// гнлейт
1900,		// гнполк
2200,		// гнарм
2500		// вгк
};
new const FLASH_G[] = {
0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
};
new const SMOKE_G[] = {
0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1
};
new const HE_G[] = {
0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1
};
new const NIGHT_V[] = {
0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1
};
new const ARMOR_B[] = {
0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
};
new const DEFUSE_N[] = {
0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1
};
//сохранение
/*
new Host[]     	= "78.108.83.236"
new User[]    	= "Army" 
new Pass[]     	= "79OkxiUZ"
new Db[]     	= "Army"
new Handle:g_SqlTuple
new g_Error[512]
*/
new gVault;
//new const g_szServerIP[] = "92.112.81.53";188.127.246.225
//
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_logevent( "EventRoundStart", 2, "1=Round_Start" );
	set_task(1.0, "Info", I_ID, "", 0, "b")
	g_MsgHud = CreateHudSyncObj();
	MaxPlayers = get_maxplayers();
	register_dictionary( 		"army.txt" );
	register_clcmd("say", 		"hookSay")
	register_clcmd("say_team", 	"hookSayTeam")
	register_event( "DeathMsg",	"EventDeath",      "a");
	//для исп БД
	//set_task(1.0, 			"MySql_Init")
	//
	//TeamInfo = get_user_msgid("TeamInfo");
	//SayText = get_user_msgid("SayText");
}
/*
public MySql_Init()
{
	
	g_SqlTuple = SQL_MakeDbTuple(Host,User,Pass,Db);
	new ErrorCode,Handle:SqlConnection = SQL_Connect(g_SqlTuple,ErrorCode,g_Error,charsmax(g_Error));
	if(SqlConnection == Empty_Handle)
		set_fail_state(g_Error);
	       
	new Handle:Queries;
	Queries = SQL_PrepareQuery(SqlConnection,"CREATE TABLE IF NOT EXISTS pl_data (pl_name varchar(32),pl_xp INT(11),pl_lvl INT(11))");
	if(!SQL_Execute(Queries))
	{
		SQL_QueryError(Queries,g_Error,charsmax(g_Error));
		set_fail_state(g_Error);
	}
	SQL_FreeHandle(Queries);
	SQL_FreeHandle(SqlConnection)  ; 
}  
public plugin_end()
{
	SQL_FreeHandle(g_SqlTuple);
}
public Load_MySql(id)
{
	new szName[33], szTemp[512]
	get_user_name(id, szName, charsmax(szName))
	new Data[1];
	Data[0] = id;
	format(szTemp,charsmax(szTemp),"SELECT * FROM `pl_data` WHERE (`pl_data`.`pl_name` = '%s')", szName)
	SQL_ThreadQuery(g_SqlTuple,"register_client",szTemp,Data,1)
}

public register_client(FailState,Handle:Query,Error[],Errcode,Data[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
	{
		log_amx("Load - Could not connect to SQL database.  [%d] %s", Errcode, Error)
	}
	else if(FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("Load Query failed. [%d] %s", Errcode, Error)
	}
	new id = Data[0]
	if(SQL_NumResults(Query) < 1) 
	{
		new szName[33]
		get_user_name(id, szName, charsmax(szName))
		if (equal(szName,"ID_PENDING"))
			return PLUGIN_HANDLED
		
		new szTemp[512]
		format(szTemp,charsmax(szTemp),"INSERT INTO `pl_data` ( `pl_name` , `pl_xp`, `pl_lvl`)VALUES ('%s','0','1');",szName)
		SQL_ThreadQuery(g_SqlTuple,"IgnoreHandle",szTemp)
	} 
	else 
	{
		PlayerXP[id] = SQL_ReadResult(Query, 1)
		PlayerLevel[id] = SQL_ReadResult(Query, 2)
		
	}
	return PLUGIN_HANDLED
}
public Save_MySql(id)
{
	new szName[33], szTemp[512]
	get_user_name(id, szName, charsmax(szName))
	format(szTemp,charsmax(szTemp),"UPDATE `pl_data` SET `pl_xp` = '%i',`pl_lvl` = '%i' WHERE `pl_data`.`pl_name` = '%s';",PlayerXP[id],PlayerLevel[id], szName)
	SQL_ThreadQuery(g_SqlTuple,"IgnoreHandle",szTemp)
}  
public IgnoreHandle(FailState,Handle:Query,Error[],Errcode,Data[],DataSize)
{
	SQL_FreeHandle(Query)
	return PLUGIN_HANDLED
}*/
public client_putinserver(id)
{
	load_client_data(id)
}
public client_disconnect(id)
{
	save_client_data(id);
}
public hookSay(id)
{
	if(is_user_hltv(id) || is_user_bot(id) || !is_user_connected(id))
	{
		return PLUGIN_CONTINUE;
	}
	new message[192],Len;
	read_args(message, 191);
	remove_quotes(message);
	new szName[32];
	get_user_name(id,szName,31);
	Len = format(Msg[Len], charsmax(Msg) - 1, "^4[^3%L^4] ",LANG_PLAYER,CLASSES[PlayerLevel[id]]);
	Len += format(Msg[Len], charsmax(Msg) - 1, "^3%s^4 : ",szName);
	Len += format(Msg[Len], charsmax(Msg) - 1, "^1%s",message);
	ColorChat(0,NORMAL,Msg)
	return PLUGIN_HANDLED_MAIN
}
public hookSayTeam(id)
{
	if(is_user_hltv(id) || is_user_bot(id) || !is_user_connected(id))
	{
		return PLUGIN_CONTINUE;
	}
	new message[192],Len;
	read_args(message, 191);
	remove_quotes(message);
	new szName[32];
	get_user_name(id,szName,31);
	Len = format(Msg[Len], charsmax(Msg) - 1, "(%L)",LANG_PLAYER,"SEND_TEAM");
	Len += format(Msg[Len], charsmax(Msg) - 1, "^4[^3%L^4] ",LANG_PLAYER,CLASSES[PlayerLevel[id]]);
	Len += format(Msg[Len], charsmax(Msg) - 1, "^3%s^4 : ",szName);
	Len += format(Msg[Len], charsmax(Msg) - 1, "^1%s",message);
	SendTeamMessage(Msg,get_user_team(id));
	return PLUGIN_HANDLED_MAIN
}
stock SendTeamMessage(Message[],playerTeam)
{
	for (new player = 0; player <= MaxPlayers; player++)
	{
		if (!is_user_connected(player))
		{
			continue
		}
		if(get_user_team(player) == playerTeam)
		{
			ColorChat(player,NORMAL,Message);
		}
	}
}
//
public checkLvl(id)
{
	if(PlayerLevel[id] <= 0)
	{
		PlayerLevel[id] = 1;
	}
	while(PlayerXP[id] >= LEVELS[PlayerLevel[id]]) 
	{
		PlayerLevel[id]++;
		levelUp[id] = 1;
		new szName[ 32 ];
		get_user_name( id, szName, 31 );
		static buffer[192], len;
		len = format(buffer, charsmax(buffer), "^4[^3%L^4]^1 ",LANG_PLAYER,"ARMY");
		len += format(buffer[len], charsmax(buffer) - len, "%L ",LANG_PLAYER,"PLAYER");
		len += format(buffer[len], charsmax(buffer) - len, "^4%s^1 ",szName);
		len += format(buffer[len], charsmax(buffer) - len, " %L",LANG_PLAYER,"NEW_LEVEL"); 
		len += format(buffer[len], charsmax(buffer) - len, " ^4%L^1.",LANG_PLAYER,CLASSES[PlayerLevel[id]]);
		len += format(buffer[len], charsmax(buffer) - len, "%L",LANG_PLAYER,"CONTR");
		ColorChat(0,NORMAL,buffer);
		//break;
	}
}
// ======================================== добавляем фраги ========================================
public EventDeath()
{
	new iVictim = read_data( 2 );
	new iTeam = get_user_team(iVictim);
	new iKiller = read_data( 1 );
	if(iKiller != iVictim && get_user_team(iKiller) != iTeam && is_user_connected(iKiller))
	{
		PlayerXP[iKiller]++;
	}
	checkLvl(iKiller);
	return PLUGIN_CONTINUE;
}
// ======================================== Получение бонуса =======================================
public EventRoundStart()
{
	new flash[33],he[33],smoke[33],arm[33],nv[33],def[33];
	for(new id = 1; id <= MaxPlayers; id++)
	{
		if(is_user_alive(id) && is_user_connected(id))
		{
			flash[id] = FLASH_G[PlayerLevel[id]];
			he[id] 	= HE_G[PlayerLevel[id]];
			smoke[id] = SMOKE_G[PlayerLevel[id]];
			arm[id] = ARMOR_B[PlayerLevel[id]];
			nv[id] 	= NIGHT_V[PlayerLevel[id]];
			def[id] = DEFUSE_N[PlayerLevel[id]];
			give_user_bonus(id,flash[id],he[id],smoke[id],nv[id],arm[id],def[id]);
			if(levelUp[id] == 1)
			{
				GetWeapon(id);
				levelUp[id] = 0;
			}
		}
	}
	return PLUGIN_CONTINUE;
}

public GetWeapon(id)
{
	new szText[700 char];
	formatex( szText, charsmax( szText ), "%L", id, "GW_TITLE");
	new menu = menu_create( szText, "gw_menu" );
	//==================================================================================================
	formatex( szText, charsmax( szText ), "AWP");
	menu_additem( menu, szText, "1", 0 );
//
	formatex( szText, charsmax( szText ), "AK-47");
	menu_additem( menu, szText, "2", 0 );
//
	formatex( szText, charsmax( szText ), "M16");
	menu_additem( menu, szText, "3", 0 );
//
	formatex( szText, charsmax( szText ), "Famas");
	menu_additem( menu, szText, "4", 0 );
	//==================================================================================================
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, menu,0);
	return PLUGIN_CONTINUE;
}
public gw_menu(id,menu,item)
{
	if( item == MENU_EXIT )
	{
		return PLUGIN_HANDLED;
	}
	
	new data[ 6 ], iName[ 64 ], access, callback;
	menu_item_getinfo( menu, item, access, data, charsmax( data ), iName, charsmax( iName ), callback );
	new key = str_to_num( data );
	switch( key )
	{
		case 1:
		{
			give_item(id,"weapon_awp");
			cs_set_user_bpammo( id, CSW_AWP, 100);
		}
		case 2:
		{
			give_item(id,"weapon_ak47");
			cs_set_user_bpammo( id, CSW_AK47, 200);
		}
		case 3:
		{
			give_item(id,"weapon_m4a1");
			cs_set_user_bpammo( id, CSW_M4A1, 200);
		}
		case 4:
		{
			give_item(id,"weapon_famas");
			cs_set_user_bpammo( id, CSW_FAMAS, 200);
		}
	}
	
	return PLUGIN_HANDLED;
}

stock give_user_bonus(id,f_g,h_g,s_g,n_v,a_b,d_k)
{
	if(f_g)
	{
		give_item(id,"weapon_flashbang");
	}
	if(h_g)
	{
		give_item(id,"weapon_hegrenade");
	}
	if(s_g)
	{
		give_item(id,"weapon_smokegrenade");
	}
	if(n_v)
	{
		give_item(id,"item_nvgs");
	}
	if(a_b)
	{
		give_item(id,"item_kevlar");
	}
	if(d_k)
	{
		give_item(id,"weapon_smokegrenade");
	}
	if(s_g)
	{
		give_item(id,"item_assaultsuit");
	}
}
// ======================================== Информер ===============================================
public Info()
{
	for(new id = 1; id <= MaxPlayers; id++)
	{
		needXP[id] = LEVELS[PlayerLevel[id]] - PlayerXP[id];
		set_hudmessage(100, 100, 100, 0.01, 0.13, 0, 1.0, 1.0, _, _, -1)
		static buffer[192], len;
		len = format(buffer, charsmax(buffer), "^n^n^n^n%L",LANG_PLAYER,"ZVANIE");
		len += format(buffer[len], charsmax(buffer) - len, " %L [%d лвл]",LANG_PLAYER,CLASSES[PlayerLevel[id]], PlayerLevel[id]);
		len += format(buffer[len], charsmax(buffer) - len, "^n%L %d",LANG_PLAYER,"PL_XP",PlayerXP[id]);
		len += format(buffer[len], charsmax(buffer) - len, "^n%L",LANG_PLAYER,"NEXT_LVL");
		len += format(buffer[len], charsmax(buffer) - len, " %d ",needXP[id]);
		ShowSyncHudMsg(id, g_MsgHud, "%s", buffer);
	}
	return PLUGIN_CONTINUE
}

stock save_client_data(id)
{
	gVault = nvault_open( "plData" );
	new Name[33];
	get_user_name(id, Name, 32);
	new vaultkey[64],vaultdata[256] 
	format(vaultkey,63,"%s-data",Name) 
	format(vaultdata,255,"%i#%i#",PlayerXP[id],PlayerLevel[id]);
	nvault_set(gVault,vaultkey,vaultdata) 
	nvault_close( gVault );
}
stock load_client_data(id)
{
	gVault = nvault_open( "plData");
	new Name[33];
	get_user_name(id, Name, 32);
	new vaultkey[64],vaultdata[256] 
	format(vaultkey,63,"%s-data",Name) 
	format(vaultdata,255,"%i#%i#",PlayerXP[id],PlayerLevel[id]);
	nvault_get(gVault,vaultkey,vaultdata,255) 
	replace_all(vaultdata, 255, "#", " ") 
	new ldr[33],lvl[33];
	parse(vaultdata, ldr, 32,lvl,32);
	PlayerXP[id] 	= str_to_num(ldr);
	PlayerLevel[id]	= str_to_num(lvl);
	nvault_close( gVault );
}
public ResetVariables(id)
{
	PlayerXP[id] = 0;
	PlayerLevel[id] = 0;
	levelUp[id] = 0;
}
public plugin_natives()
{
	register_native("get_user_exp", "native_get_user_exp", 1);
	register_native("get_user_lvl", "native_get_user_lvl", 1);
}

public native_get_user_exp(id)
{
	return PlayerXP[id];
}

public native_get_user_lvl(id)
{
	return PlayerLevel[id];
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
