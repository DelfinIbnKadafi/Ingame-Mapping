/*
  *** easy Dialog v0.0.4 ***
  *	  by HPQ123
  *   contact Discord: HPQ123#8114
  ***	    ****		 ***
*/
#define DIALOG_SIMPLE 				5000
#define DIALOG_PAGES				5001

#define Dialog:%0(%1)				forward dialog_%0(%1); public dialog_%0(%1)
#define Dialog_Opened(%0)			dialogData[%0][DL_Status]

enum e_DIALOG_ENUM {
	DL_Status,
	DL_Collumn,
	DL_CurrentPage,
	DL_DivPage,
	DIALOG_STYLE:DL_Style,
	DL_Headers[64],
	DL_Char[64],
	DL_Caption[128],
	DL_Info[64 * 64],
	DL_Button1[32],
	DL_Button2[32]
}

new 
	dialogData[MAX_PLAYERS][e_DIALOG_ENUM],DL_String[1094],DL_String2[1094],DL_Name[MAX_PLAYERS][40 char],
	DL_RVAR[e_DIALOG_ENUM]={0,0,0,0,DIALOG_STYLE_INPUT,"",{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}," ", " ", " ", " "}
;

#define Dialog_Show(%0,%1,%2,%3,%4,%5,%6) \
	((dialogData[%0][DL_Status]=ShowPlayerDialog(%0, DIALOG_SIMPLE, %2, %3, %4, %5, %6)),strpack(DL_Name[%0], #dialog_##%1, 40 char))

#define Dialog_ShowPages(%0,%1,%2,%3,%4,%5,%6) \
	((dialogData[%0][DL_Status]=DL_internPages(%0, %2, %3, %4, %5, %6)),strpack(DL_Name[%0], #dialog_##%1, 40 char))

#define Dialog_ShowEx(%0,%1,%2,%3,%4,%5,%6,%7) \
	format(DL_String2,_,%4,%7)&&Dialog_Show(%0,%1,%2,%3,DL_String2,%5,%6)

#define Dialog_ShowPagesEx(%0,%1,%2,%3,%4,%5,%6,%7) \
	format(DL_String2,_,%4,%7)&&Dialog_ShowPages(%0,%1,%2,%3,DL_String2,%5,%6)

#define Dialog_Close(%0) \
	ShowPlayerDialog(%0, (dialogData[%0][DL_Status]=0)-1, DIALOG_STYLE_MSGBOX, " ", " ", " ", " ");

stock DL_internPages(playerid, style, caption[], info[], button1[], button2[], _default=10, lastpos=0) {
	dialogData[playerid] = DL_RVAR;
	strmid(dialogData[playerid][DL_Info], info, 0, 64 * 64);
	strmid(dialogData[playerid][DL_Caption], caption, 0, 128);
	strmid(dialogData[playerid][DL_Button1], button1, 0, 32);
	strmid(dialogData[playerid][DL_Button2], button2, 0, 32);
	dialogData[playerid][DL_Style] = style;
	dialogData[playerid][DL_DivPage] = _default;

	strmid(DL_String, info, 0, sizeof DL_String);
	dialogData[playerid][DL_Collumn] = style!=5?1:-1;
	for(;(lastpos=strfind(info, "\n", true, lastpos + 1))!=-1;) 
		if(++dialogData[playerid][DL_Collumn]%_default) continue;
		else dialogData[playerid][DL_Char][dialogData[playerid][DL_Collumn]/_default] = lastpos+1;

	dialogData[playerid][DL_Char][(dialogData[playerid][DL_Collumn]/_default)+1] = strlen(info);
	DL_String[dialogData[playerid][DL_Char][1]] = '\0';
	DL_AddButtons(playerid, _d_max(playerid));
	return ShowPlayerDialog(playerid, DIALOG_PAGES, style, caption, DL_String, button1, button2),strmid(dialogData[playerid][DL_Headers], info, 0, strfind(info, "\n", true)+1);
}

static _d_max(playerid) return (dialogData[playerid][DL_Collumn]-1)/dialogData[playerid][DL_DivPage];

stock DL_AddButtons(playerid, max=0) {
	if(dialogData[playerid][DL_CurrentPage] != max && max) strcat(DL_String, ">>\n");
	if(dialogData[playerid][DL_CurrentPage] != 0) strcat(DL_String, "<<");
	return true;
}

stock DL_fresh(playerid, current) {
	if(dialogData[playerid][DL_Style]==DIALOG_STYLE_TABLIST_HEADERS) {
		strmid(DL_String, dialogData[playerid][DL_Headers], 0, 64);
		strmid(DL_String2, dialogData[playerid][DL_Info], dialogData[playerid][DL_Char][current], dialogData[playerid][DL_Char][current+1]);
		strcat(DL_String, DL_String2);
	} else strmid(DL_String, dialogData[playerid][DL_Info], dialogData[playerid][DL_Char][current], dialogData[playerid][DL_Char][current+1]);

	DL_AddButtons(playerid, _d_max(playerid));
	return dialogData[playerid][DL_Status]=ShowPlayerDialog(playerid, DIALOG_PAGES, dialogData[playerid][DL_Style], dialogData[playerid][DL_Caption], DL_String, dialogData[playerid][DL_Button1], dialogData[playerid][DL_Button2]);
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
	strreplace(inputtext, "%", "#", false, 0, -1, strlen(inputtext));
	switch(dialogid) {
		case DIALOG_SIMPLE: {
			if(!Dialog_Opened(playerid)) return true; dialogData[playerid][DL_Status] = false;
			CallLocalFunction(DL_Name[playerid], #iiis, playerid, response, listitem, (inputtext[0])?(inputtext):("\1"));
		}
		case DIALOG_PAGES: {
			if(!Dialog_Opened(playerid)) return true; dialogData[playerid][DL_Status] = false;
			new next_page=dialogData[playerid][DL_DivPage],prev_page=next_page+1;
			if(dialogData[playerid][DL_CurrentPage] == _d_max(playerid) && _d_max(playerid)) 
				prev_page=listitem != next_page ? (dialogData[playerid][DL_Collumn]%next_page):next_page,next_page = -1;

			if(listitem == next_page || listitem == prev_page) {
				if(!response) return CallLocalFunction(DL_Name[playerid], #iiis, playerid, response, listitem, "\1");
				if(listitem == next_page) return DL_fresh(playerid, ++dialogData[playerid][DL_CurrentPage]);
				if(listitem == prev_page) return DL_fresh(playerid, --dialogData[playerid][DL_CurrentPage]);
			}
			CallLocalFunction(DL_Name[playerid], #iiis, playerid, response, listitem + (dialogData[playerid][DL_CurrentPage] * dialogData[playerid][DL_DivPage]), (inputtext[0])?(inputtext):("\1"));
		}
	}
	#if defined DL_OnDialogResponse
		return DL_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnDialogResponse
	#undef OnDialogResponse
#else
	#define _ALS_OnDialogResponse
#endif

#define OnDialogResponse DL_OnDialogResponse
#if defined DL_OnDialogResponse
	forward DL_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif